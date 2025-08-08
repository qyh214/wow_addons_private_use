local V2_TAG_NUMBER = 4

---@param v2Rankings ProviderProfileV2Rankings
---@return ProviderProfileSpec
local function convertRankingsToV1Format(v2Rankings, difficultyId, sizeId)
	---@type ProviderProfileSpec
	local v1Rankings = {}
	v1Rankings.progress = v2Rankings.progressKilled
	v1Rankings.total = v2Rankings.progressPossible
	v1Rankings.average = v2Rankings.bestAverage
	v1Rankings.spec = v2Rankings.spec
	v1Rankings.asp = v2Rankings.allStarPoints
	v1Rankings.rank = v2Rankings.allStarRank
	v1Rankings.difficulty = difficultyId
	v1Rankings.size = sizeId

	v1Rankings.encounters = {}
	for id, encounter in pairs(v2Rankings.encountersById) do
		v1Rankings.encounters[id] = {
			kills = encounter.kills,
			best = encounter.best,
		}
	end

	return v1Rankings
end

---Convert a v2 profile to a v1 profile
---@param v2 ProviderProfileV2
---@return ProviderProfile
local function convertToV1Format(v2)
	---@type ProviderProfile
	local v1 = {}
	v1.subscriber = v2.isSubscriber
	v1.perSpec = {}

	if v2.summary ~= nil then
		v1.progress = v2.summary.progressKilled
		v1.total = v2.summary.progressPossible
		v1.totalKillCount = v2.summary.totalKills
		v1.difficulty = v2.summary.difficultyId
		v1.size = v2.summary.sizeId
	else
		local bestSection = v2.sections[1]
		v1.progress = bestSection.anySpecRankings.progressKilled
		v1.total = bestSection.anySpecRankings.progressPossible
		v1.average = bestSection.anySpecRankings.bestAverage
		v1.totalKillCount = bestSection.totalKills
		v1.difficulty = bestSection.difficultyId
		v1.size = bestSection.sizeId
		v1.anySpec = convertRankingsToV1Format(bestSection.anySpecRankings, bestSection.difficultyId, bestSection.sizeId)
		for i, rankings in pairs(bestSection.perSpecRankings) do
			v1.perSpec[i] = convertRankingsToV1Format(rankings, bestSection.difficultyId, bestSection.sizeId)
		end
		v1.encounters = v1.anySpec.encounters
	end

	if v2.mainCharacter ~= nil then
		v1.mainCharacter = {}
		v1.mainCharacter.spec = v2.mainCharacter.spec
		v1.mainCharacter.average = v2.mainCharacter.bestAverage
		v1.mainCharacter.difficulty = v2.mainCharacter.difficultyId
		v1.mainCharacter.size = v2.mainCharacter.sizeId
		v1.mainCharacter.progress = v2.mainCharacter.progressKilled
		v1.mainCharacter.total = v2.mainCharacter.progressPossible
		v1.mainCharacter.totalKillCount = v2.mainCharacter.totalKills
	end

	return v1
end

---Parse a single set of rankings from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileV2Rankings
local function parseRankings(decoder, state, lookup)
	---@type ProviderProfileV2Rankings
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progressKilled = decoder.decodeInteger(state, 1)
	result.progressPossible = decoder.decodeInteger(state, 1)
	result.bestAverage = decoder.decodePercentileFixed(state)
	result.allStarRank = decoder.decodeInteger(state, 3)
	result.allStarPoints = decoder.decodeInteger(state, 2)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encountersById = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)
		local isHidden = decoder.decodeBoolean(state)

		result.encountersById[id] = { kills = kills, best = best, isHidden = isHidden }
	end

	return result
end

---Parse a binary-encoded data string into a provider profile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@param formatVersion number
---@return ProviderProfile|ProviderProfileV2|nil
local function parse(decoder, content, lookup, formatVersion) -- luacheck: ignore 211
	-- For backwards compatibility. The existing addon will leave this as nil
	-- so we know to use the old format. The new addon will specify this as 2.
	formatVersion = formatVersion or 1
	if formatVersion > 2 then
		return nil
	end

	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	---@type ProviderProfileV2
	local result = {}
	result.isSubscriber = decoder.decodeBoolean(state)
	result.summary = nil
	result.sections = {}
	result.progressOnly = false
	result.mainCharacter = nil

	local sectionsCount = decoder.decodeInteger(state, 1)
	if sectionsCount == 0 then
		---@type ProviderProfileV2Summary
		local summary = {}
		summary.zoneId = decoder.decodeInteger(state, 2)
		summary.difficultyId = decoder.decodeInteger(state, 1)
		summary.sizeId = decoder.decodeInteger(state, 1)
		summary.progressKilled = decoder.decodeInteger(state, 1)
		summary.progressPossible = decoder.decodeInteger(state, 1)
		summary.totalKills = decoder.decodeInteger(state, 2)

		result.summary = summary
	else
		for i = 1, sectionsCount do
			---@type ProviderProfileV2Section
			local section = {}
			section.zoneId = decoder.decodeInteger(state, 2)
			section.difficultyId = decoder.decodeInteger(state, 1)
			section.sizeId = decoder.decodeInteger(state, 1)
			section.partitionId = decoder.decodeInteger(state, 1) - 128
			section.totalKills = decoder.decodeInteger(state, 2)

			local specCount = decoder.decodeInteger(state, 1)
			section.anySpecRankings = parseRankings(decoder, state, lookup)

			section.perSpecRankings = {}
			for j = 1, specCount - 1 do
				local specRankings = parseRankings(decoder, state, lookup)
				table.insert(section.perSpecRankings, specRankings)
			end

			table.insert(result.sections, section)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)
	if hasMainCharacter then
		---@type ProviderProfileV2MainCharacter
		local mainCharacter = {}
		mainCharacter.zoneId = decoder.decodeInteger(state, 2)
		mainCharacter.difficultyId = decoder.decodeInteger(state, 1)
		mainCharacter.sizeId = decoder.decodeInteger(state, 1)
		mainCharacter.progressKilled = decoder.decodeInteger(state, 1)
		mainCharacter.progressPossible = decoder.decodeInteger(state, 1)
		mainCharacter.totalKills = decoder.decodeInteger(state, 2)
		mainCharacter.spec = decoder.decodeString(state, lookup)
		mainCharacter.bestAverage = decoder.decodePercentileFixed(state)

		result.mainCharacter = mainCharacter
	end

	local progressOnly = decoder.decodeBoolean(state)
	result.progressOnly = progressOnly

	if formatVersion == 1 then
		return convertToV1Format(result)
	end

	return result
end
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Unknown-Unknown','Druid-Restoration','Mage-Fire','Warrior-Arms','Warrior-Fury','Druid-Balance','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Unholy','Priest-Holy','Druid-Feral','Paladin-Retribution','Mage-Arcane','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Enhancement','DeathKnight-Frost','Shaman-Restoration','Paladin-Holy','Druid-Guardian','Monk-Mistweaver','Warlock-Affliction','Warlock-Demonology','Rogue-Assassination','Priest-Discipline','Priest-Shadow',}; local provider = {region='CN',realm='冰川之拳',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amanda:BAAAKgAECgMIAwAAAA==.',Az='Azreal:BAACKgAFFH8WAAIBAAQIQBvjHQDfAAABAAQIQBvjHQDfAAAqAAQKfyIAAwEACAjKIbAXAJwCAAEACAjKIbAXAJwCAAIAAwgbDDZ0AGkAAAAA.',Bl='Blackpastor:BAAAKgADCgEIAQAAAA==.',Ch='Chamuel:BAAAKgAECgUIBgAAAA==.',Da='Darknessy:BAAAKgAECgUICgAAAA==.',De='Deathunters:BAAAKgAECggICAAAAA==.',Dk='Dkeep:BAAAKgAECgcIDQAAAA==.',El='Electrifying:BAAAKgAECgIIAgAAAA==.',Ic='Ice:BAABKgAFFH8GAAIDAAYI7B51AwDIAQADAAYI7B51AwDIAQAAAA==.',Om='Oma:BAAAKgAFFAQIBAAAAA==.',Oo='Ootk:BAAAKgADCggIDgAAAA==.',Po='Polait:BAAAKgAFFAQIBAABKgAFFAgIAgAEAAAAAA==.Poseidon:BAACKgAFFH8PAAIFAAMIVRJMHwCvAAAFAAMIVRJMHwCvAAAqAAQKfxwAAgUACAh7GnoYANsBAAUACAh7GnoYANsBAAAA.',Pr='Pruto:BAAAKgADCggICAAAAA==.',Va='Vassieca:BAABKgAFFH8MAAMDAAYIbhuOBQCBAQADAAYIbhuOBQCBAQAGAAYIIAv5DwBGAQAAAA==.',Vu='Vulcano:BAABKgAFFH8MAAMHAAIImhO/HwCQAAAHAAIImhO/HwCQAAAIAAII5AbqIQCGAAAAAA==.',['一往']='一往而深:BAAAKgAECgEIAgAAAA==.',['七块']='七块腹肌:BAAAKgAFFAIIAgAAAA==.',['七天']='七天大圣:BAAAKgADCggICAAAAA==.',['上帝']='上帝的武装:BAAAKgADCgcIBwAAAA==.',['上班']='上班打瞌睡:BAABKgAECn8aAAMFAAgIggvQFwAGAQAFAAgIggvQFwAGAQAJAAIIowOU2AAuAAAAAA==.',['不至']='不至于:BAABKgAFFH8IAAIKAAgIbhT7CAD+AQAKAAgIbhT7CAD+AQAAAA==.',['丨信']='丨信浓丨:BAAAKgADCggICAAAAA==.',['丨出']='丨出云丨:BAAAKgAECgUIDAAAAA==.',['丨十']='丨十纱丨:BAAAKgAECgYICwAAAA==.',['丨吹']='丨吹雪丨:BAAAKgAECgEIAQAAAA==.',['丨时']='丨时雨丨:BAAAKgAECgcIBwAAAA==.',['丨海']='丨海风丨:BAAAKgAECgUIBwAAAA==.',['丨深']='丨深雪丨:BAAAKgAECgcIDgAAAA==.',['丨雪']='丨雪風丨:BAAAKgAECggIDAAAAA==.丨雪风丨:BAABKgAECn8VAAMLAAYI5QfVRgChAAAMAAUIxgYflwCkAAALAAYIpAfVRgChAAAAAA==.',['丰川']='丰川祥子:BAABKgAFFH8IAAINAAQIwg27LACRAAANAAQIwg27LACRAAAAAA==.',['丶不']='丶不醉不会:BAAAKgAFFAIIAgAAAA==.',['丹妮']='丹妮莉斯:BAAAKgADCgMIAwAAAA==.',['于她']='于她人间寻:BAABKgAFFH8IAAMJAAUImxeRKgDoAAAJAAQIwByRKgDoAAAOAAIIawfrCABNAAAAAA==.',['人民']='人民的好骑士:BAAAKgAFFAQIBAAAAA==.',['从齐']='从齐立四化志:BAAAKgADCgEIAQAAAA==.',['伊夫']='伊夫里特:BAAAKgAECgUICwAAAA==.',['依然']='依然小悟空:BAAAKgAFFAEIAQAAAA==.',['先打']='先打狗:BAAAKgADCgMIAwAAAA==.',['冰山']='冰山银岭牪犇:BAAAKgAECgEIAQAAAA==.',['冰弑']='冰弑丶凌霜:BAABKgAFFH8GAAIMAAYIMhndEQCLAQAMAAYIMhndEQCLAQAAAA==.',['凡尼']='凡尼莎:BAAAKgADCgIIAgAAAA==.',['剑魔']='剑魔苍月:BAABKgAECn8iAAIPAAgIsyAmJwBjAgAPAAgIsyAmJwBjAgAAAA==.',['十三']='十三号飞象:BAAAKgAFFAEIAQAAAA==.',['十四']='十四行诗:BAAAKgAECgIIAgAAAA==.',['卟德']='卟德嘹:BAABKgAFFH8NAAIJAAIIRQ+fLQB7AAAJAAIIRQ+fLQB7AAAAAA==.',['友谊']='友谊第一哦:BAABKgAFFH8GAAIQAAYIGxzHCgC+AQAQAAYIGxzHCgC+AQAAAA==.',['古镇']='古镇茗香:BAAAKgAECggIDQAAAA==.古镇青岚:BAAAKgAFFAIIBAAAAA==.',['可燃']='可燃乌龙茶:BAAAKgAECggICwAAAA==.',['叶小']='叶小牛:BAAAKgAFFAIIAwAAAA==.',['吖丨']='吖丨小小丨吖:BAABKgAECn8ZAAMRAAgIoSG3JgAfAgARAAgIoSG3JgAfAgASAAgI5RQ2HwCIAQAAAA==.',['嗷呜']='嗷呜努:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光侍者:BAAAKgAECgYIBwAAAA==.',['大国']='大国宝:BAAAKgAECgEIAQAAAA==.',['大车']='大车厘子:BAABKgAFFH8FAAIFAAUI9wHCDwCaAAAFAAUI9wHCDwCaAAAAAA==.',['大金']='大金鱼佬:BAAAKgAFFAQIBAABKgAFFAgICAANAHgSAA==.',['天杰']='天杰:BAAAKgAECgUIBgAAAA==.',['天灵']='天灵灵:BAAAKgAECgEIAgAAAA==.',['天籁']='天籁梵音:BAAAKgAECggIDAAAAA==.',['太小']='太小了:BAAAKgAECgYIBgAAAA==.',['奶瓶']='奶瓶不甜:BAABKgAFFH8KAAIPAAYIVR9XDQAfAQAPAAYIVR9XDQAfAQAAAA==.',['奶的']='奶的好:BAAAKgAECgcIBAAAAA==.',['姬小']='姬小月:BAAAKgADCgQIBAAAAA==.',['子言']='子言丶:BAAAKgAFFAQIBAABKgAFFAgIDwATAC4bAA==.',['寂寞']='寂寞才說愛:BAAAKgAECgEIAQAAAA==.',['寶貝']='寶貝卟哭:BAAAKgAECgEIAQAAAA==.',['小冬']='小冬瓜:BAAAKgAFFAQIBAAAAA==.',['小小']='小小月:BAABKgAECn8YAAMBAAgIXyLzDwClAgABAAgIXyLzDwClAgACAAYIxxq7KwCMAQAAAA==.',['小康']='小康娜:BAAAKgADCggICAAAAA==.',['尕番']='尕番茄丶:BAAAKgAECgUIBQAAAA==.',['崽崽']='崽崽哥:BAAAKgAFFAEIAQAAAA==.',['帅气']='帅气野牛:BAAAKgAECgYICQAAAA==.',['帝埃']='帝埃趣:BAAAKgAECgYICgAAAA==.',['年少']='年少春杉薄:BAAAKgAECgMIBAAAAA==.',['幸运']='幸运星:BAAAKgAECggIEgAAAA==.',['幼儿']='幼儿园小朋友:BAAAKgAECgcICgAAAA==.',['彻底']='彻底堕落:BAAAKgAECgcIDgAAAA==.',['德世']='德世一:BAABKgAFFH8MAAMJAAQIgiN3CQAiAQAJAAQIgiN3CQAiAQAFAAQIQwkTEACzAAAAAA==.',['德德']='德德鰢:BAAAKgADCgIIAgAAAA==.',['心之']='心之所望:BAAAKgAFFAIIAgAAAA==.',['忆不']='忆不起的泪:BAAAKgAECggICAAAAA==.',['志俊']='志俊小莎:BAAAKgADCggICAAAAA==.',['快乐']='快乐的毁灭:BAAAKgADCgIIAgAAAA==.',['念山']='念山丶:BAABKgAFFH8GAAMCAAYI4R5+AQCkAQACAAUIrSN+AQCkAQABAAEIsQu6RgBKAAAAAA==.',['我一']='我一个放狗:BAAAKgAFFAIIAgAAAA==.',['我要']='我要冲锋了:BAAAKgAECgIIAgAAAA==.',['战吼']='战吼:BAAAKgADCgIIAgAAAA==.',['扑倒']='扑倒一大片:BAAAKgAFFAEIAQAAAA==.',['拉风']='拉风犀利:BAAAKgAECgcIBAAAAA==.',['拥抱']='拥抱开始:BAABKgAFFH8HAAMMAAQIew3zGADOAAAMAAQIew3zGADOAAAUAAEIqwXyEwA0AAABKgAFFAgIGQAMAOghAA==.',['擒封']='擒封希于桑林:BAAAKgAFFAMIBAAAAA==.',['散发']='散发妖气的汪:BAABKgAFFH8GAAIVAAYInwvxEwA3AQAVAAYInwvxEwA3AQAAAA==.',['无瑕']='无瑕:BAACKgAFFH8UAAIPAAQIoSGMGQAaAQAPAAQIoSGMGQAaAQAqAAQKfxgAAg8ACAizJB0FAOECAA8ACAizJB0FAOECAAAA.',['春风']='春风一度:BAAAKgAFFAYIBAAAAA==.',['暖小']='暖小鬼:BAAAKgAECgQIBAAAAA==.',['暗中']='暗中灌茶:BAAAKgADCgIIAgAAAA==.',['暴走']='暴走萝莉:BAAAKgADCgQIBAAAAA==.',['月照']='月照故里:BAABKgAFFH8FAAIWAAMIvRjSBwDtAAAWAAMIvRjSBwDtAAAAAA==.月照故里丶:BAAAKgAECgcICQAAAA==.',['杨冪']='杨冪:BAAAKgAECggICAAAAA==.',['梦回']='梦回:BAABKgAECn8ZAAIVAAgIKg1mUQBLAQAVAAgIKg1mUQBLAQAAAA==.',['梦游']='梦游:BAAAKgAECgIIAgAAAA==.',['梦笙']='梦笙:BAAAKgADCggICAAAAA==.',['死亡']='死亡公爵:BAABKgAFFH8KAAMUAAMIPAaNDQCgAAAUAAMIKQaNDQCgAAAMAAMIfwPCQgCTAAAAAA==.',['没事']='没事瞎溜达:BAAAKgAECgcICwAAAA==.',['洛克']='洛克洛克:BAABKgAFFH8GAAIIAAYI0htaCgCmAQAIAAYI0htaCgCmAQAAAA==.',['浅语']='浅语:BAAAKgAECgMIAwAAAA==.',['海底']='海底椰:BAABKgAFFH8GAAIGAAYIGA6mCQBdAQAGAAYIGA6mCQBdAQAAAA==.',['淺笑']='淺笑安然:BAAAKgADCgUIBQAAAA==.',['熬过']='熬过寒冬:BAAAKgADCgEIAQAAAA==.',['爆一']='爆一下哦:BAAAKgADCggICAAAAA==.爆一下噻:BAACKgAFFH8NAAIGAAMIqg6NHgDbAAAGAAMIqg6NHgDbAAAqAAQKfyUAAwYACAgDHu4WAGsCAAYACAgDHu4WAGsCABAAAwhmECxwAJIAAAAA.',['牛妞']='牛妞妞:BAAAKgAECgEIAQAAAA==.',['牛牛']='牛牛冲天:BAABKgAECn8YAAQXAAgIgBlEBwCWAQAXAAgIihhEBwCWAQAOAAQI4xHbCwDpAAAJAAQIXgq9RgBnAAAAAA==.牛牛在冒险:BAAAKgAECgUIBQAAAA==.牛牛大冒险:BAAAKgAECgYICgAAAA==.',['狂岚']='狂岚:BAAAKgAECggIEQAAAA==.',['狂飙']='狂飙的阿浪:BAAAKgAECgQIBAAAAA==.',['猫猫']='猫猫仔:BAAAKgADCgcIBwAAAA==.',['猴子']='猴子精:BAAAKgADCgEIAQAAAA==.',['玩偶']='玩偶贩卖机:BAAAKgAECgIIAwAAAA==.',['瓦王']='瓦王:BAAAKgADCgIIAgAAAA==.',['百变']='百变小鸡:BAAAKgAECgMIBgAAAA==.',['真夜']='真夜哥哥:BAAAKgAECgcIBwAAAA==.',['碧空']='碧空尽:BAABKgAFFH8IAAIHAAgIiAq+AwD5AQAHAAgIiAq+AwD5AQAAAA==.',['纳尼']='纳尼:BAAAKgAECggIEQAAAA==.',['绯红']='绯红血舞:BAAAKgAECgcIDQAAAA==.',['老北']='老北京鸡肉卷:BAAAKgAECgYIBgAAAA==.',['老婆']='老婆属牛的:BAAAKgAECgMIAwAAAA==.',['若葉']='若葉睦:BAABKgAFFH8FAAIYAAUIjgxRBwA1AQAYAAUIjgxRBwA1AQAAAA==.',['荒丶']='荒丶:BAAAKgAECgIIAgAAAA==.',['萨飒']='萨飒飒:BAAAKgAECgEIAQAAAA==.',['蝴蝶']='蝴蝶的淺笑:BAAAKgADCgQIBgAAAA==.',['裘猫']='裘猫:BAABKgAECn83AAMMAAgIAB9bFABoAgAMAAgIAB9bFABoAgAUAAMIRQtXLQBdAAAAAA==.',['走肾']='走肾不走心:BAAAKgADCgIIAgAAAA==.',['达文']='达文西:BAAAKgAFFAEIAQAAAA==.',['过年']='过年好丫:BAAAKgAECggIDwAAAA==.',['这里']='这里是哪里:BAAAKgAECgUICQAAAA==.',['连续']='连续剧:BAAAKgAFFAQIBAAAAA==.',['部落']='部落的小神僧:BAAAKgAFFAYIBAAAAA==.',['铁壁']='铁壁修罗:BAABKgAFFH8IAAIIAAgIiiIOAQDmAgAIAAgIiiIOAQDmAgAAAA==.',['開雲']='開雲短:BAAAKgAECggIDwAAAA==.',['闹眼']='闹眼字:BAABKgAFFH8OAAQKAAUIVByNCgANAQAKAAQI1SKNCgANAQAZAAEI0AhmGgBRAAAaAAEIAAD3IgAAAAAAAA==.',['阿心']='阿心:BAAAKgADCgcIDQAAAA==.',['陬月']='陬月初酒:BAAAKgADCgEIAQAAAA==.',['随风']='随风入心:BAAAKgAECgUIBQAAAA==.',['风干']='风干的香蕉:BAABKgAECn8VAAIbAAgIChNzGACnAQAbAAgIChNzGACnAQAAAA==.',['香水']='香水有毒:BAAAKgAECgQIBAAAAA==.',['馲背']='馲背的艿牛:BAAAKgADCgYICgAAAA==.',['马来']='马来西亚之力:BAABKgAFFH8ZAAIIAAQIFRg+HADkAAAIAAQIFRg+HADkAAAAAA==.',['骑老']='骑老虎的猪:BAABKgAFFH8GAAIHAAYIpQ43DABLAQAHAAYIpQ43DABLAQAAAA==.',['魍灵']='魍灵小鬼:BAAAKgAECgEIAQAAAA==.',['魔洞']='魔洞闪霸:BAAAKgAFFAIIAgAAAA==.',['黎巫']='黎巫:BAAAKgADCgEIAQAAAA==.',['黑曜']='黑曜石:BAAAKgAFFAIIAgAAAA==.',['黑骑']='黑骑真壁一骑:BAAAKgAECgYICAAAAA==.',['黛染']='黛染青曦:BAAAKgAECgEIAgAAAA==.',['龍羽']='龍羽莫离:BAABKgAFFH8LAAMcAAcIABkKBgDSAQAcAAYIoxcKBgDSAQAdAAEIQiREJABrAAAAAA==.',['龙恨']='龙恨:BAAAKgAECgUIBgAAAA==.',['龙泣']='龙泣:BAAAKgADCggICAAAAA==.',['龙熙']='龙熙:BAAAKgAECggIDgAAAA==.',['龙狸']='龙狸:BAAAKgAECgEIAQAAAA==.',['龙祈']='龙祈:BAAAKgADCgEIAQAAAA==.',['龙缪']='龙缪:BAAAKgADCgEIAQAAAA==.',['龙默']='龙默:BAAAKgADCgIIAgAAAA==.',['龙龘']='龙龘:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end