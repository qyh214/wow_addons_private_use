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
 local lookup = {'Warlock-Destruction','Shaman-Restoration','DeathKnight-Unholy','DeathKnight-Frost','Druid-Guardian','Druid-Balance','DemonHunter-Vengeance','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Mage-Arcane','Paladin-Holy','Warrior-Fury','Warrior-Protection','Druid-Restoration','Priest-Holy','Monk-Brewmaster','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','Mage-Frost','Mage-Fire','Evoker-Preservation','Priest-Shadow','Priest-Discipline','Shaman-Elemental','Warrior-Arms','DeathKnight-Blood',}; local provider = {region='CN',realm='鲜血熔炉',name='CN',type='weekly',zone=44,date='2025-12-10',data={Al='Alessandrroo:BAAALAAECgYIDwAAAA==.',Am='Amigo:BAABLAAFFH8QAAIBAAIIEB/OMQCxAAABAAIIEB/OMQCxAAABLAAFFAUICwACAJYTAA==.',Ar='Ardth:BAACLAAFFH8KAAIDAAIINxx9DACyAAADAAIINxx9DACyAAAsAAQKfxYAAgMACAjBHyAIANUCAAMACAjBHyAIANUCAAAA.',As='Asakura:BAAALAADCgEIAQAAAA==.',By='Byakuya:BAACLAAFFH83AAIEAAcIgiTYCAB3AgAEAAcIgiTYCAB3AgAsAAQKfyMAAgQACAgrHgdAAIECAAQACAgrHgdAAIECAAAA.',Ea='Earthshaker:BAABLAAFFH8JAAMFAAMIpAPADAA3AAAGAAIIzgP8KABqAAAFAAMImQLADAA3AAAAAA==.',Fl='Flymdh:BAAALAAECgUIBQAAAA==.Flymk:BAAALAAECgYIDQAAAA==.',Id='Idoraemonl:BAAALAAECgIIAgAAAA==.',Ka='Kakarotto:BAABLAAFFH8NAAIHAAMIEw47DgBdAAAHAAMIEw47DgBdAAAAAA==.',Li='Limboash:BAAALAAECgUIBQAAAA==.Linchua:BAACLAAFFH8wAAMIAAcIMyFtAwA8AgAIAAcIMyFtAwA8AgAJAAIIYh0uDQCsAAAsAAQKf0MAAwgACAjSJZgKAMECAAgACAjSJZgKAMECAAkABggsEBJIABIBAAAA.',Mo='Morndinflame:BAAALAAECgYIBgAAAA==.',Na='Narsha:BAAALAAECgQIBQAAAA==.',No='Nonamer:BAAALAADCggICAAAAA==.',Ny='Nyx:BAABLAAFFH8LAAMHAAYIDA1ICADoAAAHAAYIagpICADoAAAKAAIIqxXMTQBNAAAAAA==.',Os='Oshmily:BAAALAAECgcIBwAAAA==.',Qa='Qaa:BAAALAAECgYIBgAAAA==.',Qz='Qzz:BAAALAAECgYIBgAAAA==.',So='Sohee:BAACLAAFFH8UAAQLAAUItBWrRwA0AQALAAUIkxWrRwA0AQAMAAII0xDIDgCNAAANAAEIARZnBwAAAAAsAAQKfx8AAwsABwg4HiB6AFQBAAwABgixFV5YAFcBAAsABgiwHiB6AFQBAAAA.',Ta='Tako:BAACLAAFFH8LAAIHAAMIzAUeEgA+AAAHAAMIzAUeEgA+AAAsAAQKfysAAgcACAhdEeEkAI4BAAcACAhdEeEkAI4BAAAA.',Th='Thunder:BAABLAAFFH8LAAICAAUIlhOCKQAfAQACAAUIlhOCKQAfAQAAAA==.',Uo='Uoffd:BAAALAADCggIFwAAAA==.',Vi='Viod:BAABLAAFFH8GAAIOAAYIMxe2CgAVAgAOAAYIMxe2CgAVAgAAAA==.',We='Weejasdeath:BAAALAAECgYIBgAAAA==.',['一飘']='一飘啊飘一:BAAALAAECgYIBwAAAA==.',['三灬']='三灬七:BAAALAADCgIIAgAAAA==.',['三鹿']='三鹿夺命奶:BAAALAAECggICAAAAA==.',['上善']='上善若牛:BAAALAAECgYIDAAAAA==.',['下巴']='下巴颏儿:BAABLAAECn8iAAMLAAgIWRkeVAA1AgALAAgIWRkeVAA1AgAMAAgIcQhzYQA5AQAAAA==.',['不洗']='不洗碗不做饭:BAAALAAECgEIAQAAAA==.',['不羁']='不羁:BAAALAAFFAMIAwAAAA==.',['东地']='东地那非:BAAALAAFFAEIAQAAAA==.',['东莞']='东莞练习生:BAABLAAFFH8MAAMIAAUI7BiMJwBEAQAIAAUI7BiMJwBEAQAPAAEINAOVKgA7AAAAAA==.',['丿月']='丿月狂:BAAALAAECgYIBgAAAA==.',['久部']='久部川内酷:BAABLAAECn8kAAIOAAYI/xW0NQA6AQAOAAYI/xW0NQA6AQAAAA==.',['乌龙']='乌龙茶灬琉璃:BAAALAAECgYIDQAAAA==.',['二十']='二十二夜听雨:BAAALAAECggICAAAAA==.',['二蛋']='二蛋大官人:BAAALAADCgYICQAAAA==.',['五五']='五五呜呜:BAAALAAECgYICwAAAA==.',['仁德']='仁德:BAAALAAECgYIBgAAAA==.',['以戰']='以戰之名:BAAALAAECggICAAAAA==.',['伊咔']='伊咔洛斯:BAAALAAECgMIAwAAAA==.',['伊武']='伊武灵:BAAALAAFFAIIBAAAAA==.',['伊波']='伊波拉:BAABLAAFFH8IAAIKAAIIGBfcRQCVAAAKAAIIGBfcRQCVAAABLAAFFAYIIgAOAIQfAA==.',['众人']='众人皆草木:BAABLAAFFH8KAAMQAAMINwqTQABlAAAQAAMINwqTQABlAAARAAIItQj8NQAtAAAAAA==.',['会喊']='会喊六六陆:BAAALAAECgYICAAAAA==.',['传说']='传说的勇者:BAAALAAECgMIAwAAAA==.',['你也']='你也是够了:BAAALAAECgEIAQAAAA==.',['俏丽']='俏丽娃:BAAALAAFFAIIAgAAAA==.',['倔强']='倔强小宝:BAAALAAECgYIBgAAAA==.',['倩丶']='倩丶:BAAALAADCgYIBgAAAA==.',['倪浩']='倪浩:BAAALAAECgYIBgAAAA==.',['傻不']='傻不拉几:BAAALAADCgMIAwAAAA==.',['元素']='元素的绽放:BAAALAAECgYICQAAAA==.',['兄弟']='兄弟等你回来:BAAALAADCggICQAAAA==.',['兜兜']='兜兜有月饼:BAAALAAFFAIIAgAAAA==.',['兽与']='兽与佛:BAABLAAECn8YAAMHAAYIoQtlGQDXAAAHAAYI3AplGQDXAAAKAAUIzAYDjQCMAAAAAA==.',['兽兽']='兽兽猎:BAAALAAECgcIEQAAAA==.',['冲锋']='冲锋牛牛:BAABLAAECn8jAAMSAAgIHBktHgDkAQASAAcILRgtHgDkAQAGAAcIkRtGGQCqAQAAAA==.',['冷烟']='冷烟丶鈊鋙:BAAALAADCgIIAgAAAA==.冷烟无所谓咯:BAAALAAECgYIEAAAAA==.',['冻死']='冻死人不偿命:BAAALAAECggICAAAAA==.',['几百']='几百万个小德:BAAALAAECgYICwAAAA==.',['凤卷']='凤卷残云:BAAALAAECgcIEAAAAA==.',['凯撒']='凯撒斯王子:BAAALAAECgUICQAAAA==.',['切克']='切克闹吆:BAAALAAFFAIIBAAAAA==.',['刘总']='刘总来了:BAAALAADCggICAAAAA==.',['刺客']='刺客信条:BAAALAAECgUIBQABLAAFFAYIIgAOAIQfAA==.',['加德']='加德斯:BAABLAAFFH8NAAISAAUI1Rb/FADRAAASAAUI1Rb/FADRAAABLAAFFAYINAATAKojAA==.',['十號']='十號事務所:BAAALAAECgIIAgAAAA==.',['卖报']='卖报小郎君:BAAALAAFFAIIAgAAAA==.',['卧槽']='卧槽无情:BAAALAAECgYICgAAAA==.',['卿武']='卿武非佯:BAACLAAFFH8KAAIIAAMI4Qx8RgCFAAAIAAMI4Qx8RgCFAAAsAAQKfxcAAggACAiXHXFgACoCAAgACAiXHXFgACoCAAAA.',['原神']='原神:BAAALAAFFAIIAgAAAA==.',['叁枝']='叁枝:BAABLAAFFH8GAAIUAAIIqQZXGwBeAAAUAAIIqQZXGwBeAAAAAA==.',['变的']='变的风而猛:BAAALAADCgYIBgAAAA==.',['只是']='只是道寻常:BAAALAAECgYIDAAAAA==.',['可乐']='可乐公主:BAAALAADCgQICAAAAA==.',['吉尔']='吉尔尼斯屠夫:BAAALAAECgIIAgAAAA==.',['后脑']='后脑勺儿:BAABLAAECn8qAAMVAAgI9RNTDgCFAQAVAAgI9RNTDgCFAQABAAEIDw28DAErAAAAAA==.',['后脚']='后脚跟儿:BAABLAAECn8ZAAIKAAgIqhhdSgBDAgAKAAgIqhhdSgBDAgAAAA==.',['后臀']='后臀尖儿:BAABLAAECn8dAAMWAAgI0hIaHwCbAQAXAAcILhKBKgDOAQAWAAgI8QsaHwCbAQAAAA==.',['君平']='君平次山:BAAALAAECgYIBgAAAA==.',['呆萌']='呆萌小宝:BAAALAAECgQIBAAAAA==.',['咔咔']='咔咔一顿捅:BAAALAADCgUIBQAAAA==.',['咲夜']='咲夜十六夜:BAABLAAFFH8HAAIEAAMIYQmAMQDWAAAEAAMIYQmAMQDWAAAAAA==.',['哈根']='哈根达斯:BAAALAAECgYIDgAAAA==.',['哎沐']='哎沐渧:BAAALAAECgMIAwAAAA==.',['哲别']='哲别风尘:BAACLAAFFH8NAAMMAAMIFhOLHQCSAAAMAAIIyxiLHQCSAAALAAMI0Qz+eAByAAAsAAQKfxQAAgwABggrGiBFAKEBAAwABggrGiBFAKEBAAAA.',['唯一']='唯一一:BAAALAAECgEIAQAAAA==.',['商盟']='商盟三十一:BAAALAAECgYIBgAAAA==.',['喝不']='喝不懂咖啡:BAAALAAECgYICgAAAA==.',['嘎嘛']='嘎嘛:BAAALAAECgYICAAAAA==.',['嚣张']='嚣张老驴:BAAALAAECgYIBgAAAA==.',['因为']='因为无聊:BAABLAAFFH8GAAILAAIIqBOMXACOAAALAAIIqBOMXACOAAAAAA==.',['国宝']='国宝:BAABLAAFFH8MAAICAAMIBR9LFgABAQACAAMIBR9LFgABAQAAAA==.',['圆润']='圆润小宝:BAAALAAECgYIBgAAAA==.',['在这']='在这狂混:BAAALAAFFAIIAgAAAA==.',['坑空']='坑空出世:BAAALAAECgIIAgAAAA==.',['埃斯']='埃斯蒂尼安:BAAALAAFFAIIBAAAAA==.',['塔里']='塔里克丶:BAABLAAFFH8KAAMJAAIIhBTLFQB+AAAIAAIIogUMWgCHAAAJAAIIhBTLFQB+AAAAAA==.',['墨千']='墨千城:BAAALAAECgYIBgAAAA==.',['墨染']='墨染殇离:BAAALAADCgUIBQAAAA==.',['夏晴']='夏晴:BAAALAADCgIIAgAAAA==.',['夜聆']='夜聆离殇:BAAALAAECgUIBQAAAA==.',['大者']='大者咧瞄不准:BAAALAAFFAIIAgAAAA==.',['大薇']='大薇薇吖:BAAALAAFFAIIAgAAAA==.',['大蟒']='大蟒蛇:BAAALAAFFAIIBAAAAA==.',['太阳']='太阳狩猎者:BAAALAAECgQIBAAAAA==.',['奥术']='奥术编织:BAABLAAFFH8FAAIOAAII5hA2TQCTAAAOAAII5hA2TQCTAAABLAAFFAUICwACAJYTAA==.',['奶酪']='奶酪:BAAALAADCgIIAgAAAA==.',['姐姐']='姐姐的大白兔:BAAALAAECgYICwAAAA==.',['季博']='季博达:BAAALAAECgYIBwAAAA==.季博达二弟:BAAALAAECgIIAgAAAA==.季博达男神:BAAALAAFFAMIAwAAAA==.',['孬孬']='孬孬:BAABLAAFFH8FAAICAAIIJAq/ZwBUAAACAAIIJAq/ZwBUAAAAAA==.',['容嬷']='容嬷嬷扎:BAABLAAFFH8IAAIOAAII3RMQRgCaAAAOAAII3RMQRgCaAAAAAA==.',['寒霜']='寒霜夜雨:BAABLAAFFH8RAAMYAAIIoQwRHAA6AAAOAAIIoQyqVwBEAAAYAAEIoQsRHAA6AAAAAA==.',['小丫']='小丫白兔:BAAALAAECgUIBQAAAA==.',['小奶']='小奶嘴大治疗:BAAALAAECggIDAAAAA==.',['小宝']='小宝栗子:BAABLAAFFH8FAAIZAAQIzwDWCQBWAAAZAAQIzwDWCQBWAAAAAA==.',['小海']='小海螺:BAAALAAFFAYIBAAAAA==.',['小灵']='小灵感:BAAALAAFFAIIAgAAAA==.',['小犄']='小犄角大邪恶:BAAALAAECgcICgAAAA==.',['小程']='小程:BAAALAAECgYIBgAAAA==.',['小腿']='小腿肚儿:BAABLAAECn8XAAMYAAgI6ggaRwBTAQAYAAgI6ggaRwBTAQAOAAQIzAJn5ACEAAAAAA==.',['小虎']='小虎丫丶:BAAALAAFFAQIAgAAAA==.',['小野']='小野新之助:BAAALAAECgEIAQAAAA==.',['小黄']='小黄人六号:BAAALAAFFAIIAgAAAA==.小黄人四号:BAABLAAFFH8GAAIEAAIIWBarewBJAAAEAAIIWBarewBJAAAAAA==.',['少生']='少生气多喝水:BAABLAAFFH8GAAIJAAII3xlYEACWAAAJAAII3xlYEACWAAAAAA==.',['尛辉']='尛辉:BAAALAAECgYIEAAAAA==.',['山岚']='山岚:BAACLAAFFH8PAAIBAAYI1hjIJQCHAQABAAYI1hjIJQCHAQAsAAQKfxwAAwEABghyHpJWAOwBAAEABggXHZJWAOwBABUAAwjoEWIjALwAAAAA.',['巜丷']='巜丷尐黑灬:BAAALAAECgMIBQAAAA==.',['巴别']='巴别塔余烬:BAAALAAFFAIIAwAAAA==.',['巴鲁']='巴鲁:BAAALAADCgcIBwAAAA==.',['帅帅']='帅帅的反派:BAAALAAFFAIIAgAAAA==.',['带带']='带带弟弟好吗:BAAALAAFFAIIBAAAAA==.',['幻境']='幻境丶:BAAALAAECgYIDQAAAA==.',['广生']='广生:BAABLAAECn8qAAMIAAgI6RYoLADlAQAIAAgI6RYoLADlAQAPAAcIGxC6GwBwAQAAAA==.',['弓月']='弓月舞者:BAABLAAFFH8GAAILAAYIxBbsOABiAQALAAYIxBbsOABiAQAAAA==.',['彼时']='彼时梨落:BAAALAAECgYICgAAAA==.',['德天']='德天赌后:BAAALAAFFAIIBAAAAA==.',['德手']='德手:BAAALAAECgYIBgAAAA==.',['德髙']='德髙望重:BAAALAAECgMIBAAAAA==.',['忄负']='忄负刂灬人:BAAALAAECgMIAwAAAA==.',['恶来']='恶来:BAAALAAECgcIBwAAAA==.',['恶魔']='恶魔城冥王:BAAALAAECgUICQAAAA==.恶魔城阎王:BAAALAADCgEIAQAAAA==.',['惊雷']='惊雷卷地:BAAALAAECgEIAQAAAA==.',['戈壁']='戈壁老王:BAAALAAFFAIIAgAAAA==.',['我家']='我家小乖:BAAALAADCggICAAAAA==.',['我的']='我的好厚米:BAABLAAFFH8iAAIQAAUIBSOrGQCaAQAQAAUIBSOrGQCaAQAAAA==.',['打枪']='打枪打枪:BAAALAADCgEIAQAAAA==.',['执洛']='执洛:BAAALAAECgYICQAAAA==.',['拼命']='拼命干上帝:BAAALAAECgIIAgAAAA==.',['拽族']='拽族谢顶:BAAALAADCgcIBwAAAA==.',['搔龙']='搔龙先生:BAAALAAECgIIAgAAAA==.',['断弦']='断弦风筝:BAAALAAECgEIAQAAAA==.',['施巴']='施巴拉古大师:BAAALAAECgQIBAAAAA==.施巴拉古太师:BAAALAAECgYIBgAAAA==.',['无形']='无形无忌:BAAALAAFFAIIBAAAAA==.',['无聊']='无聊帥哥:BAAALAAECgYICAAAAA==.',['旧雨']='旧雨:BAAALAAFFAEIAQAAAA==.',['时风']='时风曰:BAABLAAFFH8PAAIIAAMIcxQiNQCmAAAIAAMIcxQiNQCmAAAAAA==.',['星宿']='星宿老仙:BAAALAADCgIIAgAAAA==.',['星陨']='星陨丶怒风:BAAALAAECgYIBgAAAA==.星陨丶织亡者:BAAALAAFFAIIAgAAAA==.星陨丶逐日者:BAAALAAFFAIIAgAAAA==.',['晓一']='晓一:BAAALAAECgYIBgAAAA==.',['晓芮']='晓芮:BAAALAAFFAIIAgAAAA==.',['普莉']='普莉希拉:BAABLAAFFH8QAAIaAAMIqwupFwCSAAAaAAMIqwupFwCSAAAAAA==.',['暗夜']='暗夜小猎手:BAACLAAFFH8KAAILAAIIZRlZiwBJAAALAAIIZRlZiwBJAAAsAAQKfxUAAgsACAgPFe5fAIUBAAsACAgPFe5fAIUBAAAA.',['暴力']='暴力战将:BAAALAADCgIIAgAAAA==.',['曼陀']='曼陀罗三七:BAAALAAECgUIBwAAAA==.',['月光']='月光白灬琉璃:BAAALAADCggICAAAAA==.',['月沧']='月沧溟:BAAALAAECgQIBAAAAA==.',['期待']='期待还无奈:BAAALAAFFAIIAgAAAA==.',['木头']='木头懒人丶:BAAALAAECgMIAwAAAA==.',['木木']='木木是儿子:BAABLAAFFH8FAAIEAAMIzhYzXQCZAAAEAAMIzhYzXQCZAAAAAA==.',['李白']='李白:BAAALAAECgQIBAAAAA==.',['李紅']='李紅袖:BAAALAAECgQIBQAAAA==.',['来广']='来广营包打听:BAAALAAECgYIAwAAAA==.',['杯莫']='杯莫亭:BAAALAAECgMIBAAAAA==.',['林梦']='林梦宛兮:BAAALAAECgYICgAAAA==.',['果冻']='果冻布丁:BAACLAAFFH8OAAIGAAgISwDBQgASAAAGAAgISwDBQgASAAAsAAQKfx8AAhIACAiHHPkNAHcCABIACAiHHPkNAHcCAAAA.',['柒先']='柒先森:BAABLAAFFH8JAAIIAAII/QclfwAzAAAIAAII/QclfwAzAAAAAA==.',['柠檬']='柠檬糖:BAAALAAFFAIIAgAAAA==.',['核桃']='核桃露露:BAABLAAFFH8FAAICAAUIiQA8gAApAAACAAUIiQA8gAApAAAAAA==.核桃露饿了:BAAALAAECgEIAQAAAA==.',['桀骜']='桀骜血:BAAALAAFFAEIAQAAAA==.',['桃乃']='桃乃木香柰:BAAALAAECgIIAgAAAA==.',['梅里']='梅里斯丶怒风:BAACLAAFFH8HAAIKAAQINgf7OAC6AAAKAAQINgf7OAC6AAAsAAQKfxQAAgoACAi7EDd2ANkBAAoACAi7EDd2ANkBAAAA.',['梦奇']='梦奇:BAAALAAECgEIAQAAAA==.',['椰子']='椰子:BAAALAADCggICwAAAA==.椰子叶子:BAABLAAFFH8HAAIEAAIIxB56RwCpAAAEAAIIxB56RwCpAAAAAA==.',['楠木']='楠木之灵:BAAALAAECgEIAQAAAA==.楠木之炽:BAAALAAECgYIDAAAAA==.',['橙不']='橙不我欺:BAABLAAFFH8IAAILAAYIsxnCNwBlAQALAAYIsxnCNwBlAQAAAA==.',['止于']='止于初心:BAAALAAECgYIBgAAAA==.',['残年']='残年风烛:BAABLAAECn8UAAIIAAgIMiFCGAAUAwAIAAgIMiFCGAAUAwAAAA==.',['水枪']='水枪:BAAALAAFFAIIAgAAAA==.',['江山']='江山如此多骄:BAAALAAFFAIIAgAAAA==.',['沙漠']='沙漠之虎:BAAALAAECgYIDAAAAA==.',['没事']='没事的:BAAALAAECgcIBQAAAA==.',['法丨']='法丨官:BAAALAADCggICQAAAA==.',['浮生']='浮生辛诺:BAACLAAFFH8GAAIEAAIIqA+bcQCPAAAEAAIIqA+bcQCPAAAsAAQKfyQAAgQACAh8HFVYAEYCAAQACAh8HFVYAEYCAAAA.',['海边']='海边的狐:BAAALAADCgIIAgAAAA==.',['淡忘']='淡忘星雨:BAAALAAFFAIIBAAAAA==.',['清风']='清风乂流水:BAAALAAFFAIIAgAAAA==.清风乂璟暄:BAABLAAFFH8MAAITAAIICQt7QgBmAAATAAIICQt7QgBmAAAAAA==.清风乂结城:BAABLAAFFH8JAAIIAAII+B4QUABcAAAIAAII+B4QUABcAAAAAA==.清风乂赤兔:BAABLAAFFH8IAAICAAIIZweRbgBOAAACAAIIZweRbgBOAAAAAA==.',['湮灭']='湮灭残响:BAAALAAECgcIBwAAAA==.',['溜溜']='溜溜球:BAABLAAFFH8iAAMOAAYIhB+lGgC0AQAOAAYIhB+lGgC0AQAYAAEIHA+vIABBAAAAAA==.',['漫天']='漫天飞:BAAALAADCggICAAAAA==.',['灬丨']='灬丨抹乄忧伤:BAAALAAECgYIBgAAAA==.',['炽热']='炽热之辉:BAAALAAECgYIBgAAAA==.',['無丨']='無丨丨名:BAACLAAFFH8PAAIEAAMI3QijZwB/AAAEAAMI3QijZwB/AAAsAAQKfxkAAgQACAgnD989AIsBAAQACAgnD989AIsBAAAA.',['熙汶']='熙汶:BAABLAAFFH8GAAIYAAIIZhNHEQCMAAAYAAIIZhNHEQCMAAABLAAFFAMIFAALAIQVAA==.',['牛仔']='牛仔酷:BAAALAADCgEIAQAAAA==.',['牛肉']='牛肉刀削麺:BAABLAAECn8ZAAIOAAgIfw/FKAB8AQAOAAgIfw/FKAB8AQAAAA==.',['狂暴']='狂暴战:BAAALAAECgYIBgAAAA==.',['狂龙']='狂龙勿用:BAAALAAECgcICAAAAA==.',['猴子']='猴子:BAAALAAECgYIBgABLAAFFAYIBgAMAD8OAA==.',['玄霜']='玄霜踏月:BAABLAAFFH8WAAIOAAYIEBnXHwCZAQAOAAYIEBnXHwCZAQAAAA==.',['玉轩']='玉轩:BAAALAAFFAIIBAAAAA==.',['王权']='王权丶霸业:BAAALAAECgYIBgAAAA==.',['琉璃']='琉璃丶人来疯:BAAALAADCgYIBgAAAA==.琉璃丶冬河:BAAALAAECgIIBQAAAA==.琉璃丶小尾巴:BAAALAAECgYIBwAAAA==.琉璃丶武器:BAABLAAECn8XAAIQAAYIUxjLPQBlAQAQAAYIUxjLPQBlAQAAAA==.琉璃丶涟漪:BAAALAAECgYIBgAAAA==.琉璃丶筱杺:BAAALAAECgYIEgAAAA==.琉璃丶青梭:BAAALAAECgEIAQAAAA==.',['瑞穆']='瑞穆:BAAALAAFFAIIBAAAAA==.',['瑟瑟']='瑟瑟丶:BAAALAAECgUIBQAAAA==.',['璀璨']='璀璨丶光明:BAAALAAECgEIAQAAAA==.璀璨之猎:BAAALAAECgYIDgAAAA==.',['电灬']='电灬饭灬锅:BAAALAAECgYIBwAAAA==.',['番茄']='番茄姜子:BAAALAAECgIIAgAAAA==.番茄疆:BAAALAADCgEIAQAAAA==.',['疾风']='疾风旋舞:BAAALAAECgMIAwAAAA==.',['白屿']='白屿:BAABLAAFFH8EAAMVAAMIvBhaDgCoAAAVAAIIZxpaDgCoAAABAAEIaBUNWgBHAAAAAA==.',['瞎变']='瞎变:BAAALAAECgMIAwAAAA==.',['碳烤']='碳烤鹌鹑:BAABLAAFFH8UAAMSAAMIFRa5JACUAAASAAMIFRa5JACUAAAGAAMI2QnbKgBlAAAAAA==.',['神罚']='神罚:BAABLAAFFH8GAAIOAAYIahNrLQBaAQAOAAYIahNrLQBaAQAAAA==.',['禁忌']='禁忌热血:BAAALAAECgYIDgAAAA==.',['秋月']='秋月愛莉:BAAALAAECgMIBAAAAA==.',['笔记']='笔记本:BAAALAAECgYIBgAAAA==.',['終極']='終極灬大錶姐:BAABLAAECn8XAAQTAAcIOhyWFAAqAgATAAcIOhyWFAAqAgAbAAYI1RC7VgBbAQAcAAEI4AfBQgAoAAAAAA==.',['纪念']='纪念冷血毕爷:BAAALAAECggICAAAAA==.',['绮梦']='绮梦:BAAALAAECgYIBgAAAA==.',['義丶']='義丶火紅羽翼:BAAALAAECgIIAQAAAA==.',['老伙']='老伙计:BAAALAAFFAIIAgAAAA==.',['老碑']='老碑王:BAAALAADCgQIBAAAAA==.',['老鹰']='老鹰:BAAALAAFFAIIBAAAAA==.',['肚脐']='肚脐眼儿丶:BAABLAAECn8pAAIdAAgI/hrxJACIAgAdAAgI/hrxJACIAgAAAA==.',['胡力']='胡力撒:BAACLAAFFH80AAMCAAcIeRPbGACbAQACAAcIeRPbGACbAQAdAAYITRNoEwArAQAsAAQKfyAAAwIABwhQIt4xAEwCAAIABwhQIt4xAEwCAB0ABgh2GWpWALQBAAAA.',['胯骨']='胯骨轴儿:BAACLAAFFH8JAAIEAAMIjRLCZQCEAAAEAAMIjRLCZQCEAAAsAAQKfy0AAgQACAg/H6IuALgCAAQACAg/H6IuALgCAAAA.',['胳膊']='胳膊肘儿:BAABLAAECn8uAAMeAAgIKhYTEADTAQAQAAgIlhRYTwADAgAeAAgI/Q8TEADTAQAAAA==.',['艾利']='艾利桑徳:BAAALAAECgUICAAAAA==.',['艾达']='艾达微光:BAAALAAECgMIBAAAAA==.艾达疾风:BAAALAAECgQIBAAAAA==.',['花吹']='花吹雪温柔:BAAALAAECgYIBgAAAA==.',['花葬']='花葬风小泪:BAABLAAFFH8GAAIIAAIIhQw8UACSAAAIAAIIhQw8UACSAAAAAA==.',['英雄']='英雄灬拂晓:BAACLAAFFH8HAAITAAIIfBTAKgCWAAATAAIIfBTAKgCWAAAsAAQKfxsAAhMABwj0GxksADQCABMABwj0GxksADQCAAAA.',['草莓']='草莓味的夏天:BAAALAADCggICAAAAA==.',['药药']='药药切克闹:BAAALAAECgYIEwAAAA==.',['莹玉']='莹玉:BAAALAADCgIIAgAAAA==.',['菜刀']='菜刀砍電缐:BAAALAAECgYIDQAAAA==.',['萌面']='萌面小怪兽:BAAALAAECgYIBgAAAA==.',['萨奇']='萨奇尔:BAAALAAFFAIIAgAAAA==.',['萨拉']='萨拉搭斯:BAAALAAECgYIBgAAAA==.',['萨萨']='萨萨满满:BAAALAAFFAIIAwAAAA==.',['蒓磍']='蒓磍閙:BAAALAAECgYIDQAAAA==.',['蛮小']='蛮小满:BAABLAAFFH8MAAMEAAYI3xHzSQAYAQAEAAUISRXzSQAYAQAfAAEIygBtIQAOAAAAAA==.',['蠢蠢']='蠢蠢欲动:BAABLAAFFH8GAAIEAAYI9RBbeQBKAAAEAAYI9RBbeQBKAAABLAAFFAgIEAAEALUZAA==.',['血兽']='血兽来了:BAABLAAFFH8YAAIEAAYIAhsIJgCjAQAEAAYIAhsIJgCjAQABLAAFFAYIIgAOAIQfAA==.',['血月']='血月:BAAALAAFFAIIBAAAAA==.',['血色']='血色未来:BAAALAAECggICgAAAA==.',['衣裳']='衣裳湿半:BAAALAAECgYIBwAAAA==.',['表情']='表情:BAAALAAECgYIBwAAAA==.',['视水']='视水若沙:BAAALAAECgYIDgAAAA==.',['誓约']='誓约审判:BAAALAAFFAIIBAAAAA==.誓约羽月:BAAALAAFFAIIAgAAAA==.',['讪讪']='讪讪:BAAALAADCgMIAwAAAA==.',['赤斧']='赤斧布洛克斯:BAAALAAFFAYIAwAAAA==.',['超燃']='超燃冲压:BAABLAAFFH8hAAICAAYIcRaaIABeAQACAAYIcRaaIABeAQAAAA==.',['超越']='超越宋丹丹丶:BAABLAAFFH8IAAIIAAgINwN7RACMAAAIAAgINwN7RACMAAAAAA==.',['踏着']='踏着时间长河:BAAALAAECgEIAQAAAA==.',['轩尼']='轩尼丝:BAAALAAECgMIAwAAAA==.',['输入']='输入法记得你:BAAALAAECgYIEwAAAA==.',['达啦']='达啦滴答啦:BAAALAAECgEIAQAAAA==.',['迷糊']='迷糊一眼:BAAALAAECgUIBwAAAA==.',['逍遥']='逍遥一哥:BAABLAAECn8WAAIEAAYIuBakXgA1AQAEAAYIuBakXgA1AQAAAA==.逍遥哥:BAAALAAFFAYIAQAAAA==.',['通灵']='通灵者逆袭:BAAALAAECgYIBgAAAA==.',['遇见']='遇见我是福气:BAAALAAECgYIEAAAAA==.',['邪恶']='邪恶灬召唤:BAABLAAFFH8OAAIBAAgI7xcJDgAwAgABAAgI7xcJDgAwAgAAAA==.',['郭芭']='郭芭比:BAAALAAFFAIIAgAAAA==.',['醉酒']='醉酒戏红颜:BAAALAAECgIIAgAAAA==.',['野百']='野百合:BAAALAAECgYIBwAAAA==.',['錵芝']='錵芝殇:BAAALAADCgMIAwAAAA==.',['鍏鑀']='鍏鑀靌靌:BAAALAAECgYIBgAAAA==.',['鎏洸']='鎏洸尒峯:BAAALAAFFAIIAgAAAA==.',['铁板']='铁板烧大鳄:BAAALAAECgYIDgABLAAFFAMIFAALAIQVAA==.铁板烧桔子:BAAALAAECgEIAQABLAAFFAMIFAALAIQVAA==.铁板烧橘子:BAACLAAFFH8UAAMLAAMIhBWzbgCKAAALAAMIhBWzbgCKAAAMAAIIQRR6IACIAAAsAAQKfyYAAwsACAghHdgqABACAAsACAjvHNgqABACAAwAAwhEGR6AANsAAAAA.铁板烧葡萄:BAAALAAECgYIBgABLAAFFAMIFAALAIQVAA==.',['铃鹿']='铃鹿:BAACLAAFFH80AAMTAAYIqiPQCQA0AgATAAYIqiPQCQA0AgAbAAIIIwrxKABGAAAsAAQKfx8AAxMABghkJaYeAIECABMABghkJaYeAIECABsABggMFExYAFUBAAAA.',['银月']='银月灬之舞:BAAALAADCgEIAQAAAA==.',['锁甲']='锁甲收集者:BAAALAAFFAIIAgAAAA==.',['镜花']='镜花海中月:BAAALAAECgIIAgAAAA==.',['长期']='长期素食:BAAALAAFFAIIAgAAAA==.',['闇夜']='闇夜猎手:BAAALAAECgYICwAAAA==.',['闫小']='闫小美超好看:BAAALAAECgMIAwAAAA==.',['阿武']='阿武:BAABLAAFFH8JAAIYAAIIbxqiEwBLAAAYAAIIbxqiEwBLAAAAAA==.',['阿里']='阿里嘎多:BAAALAAFFAIIAgAAAA==.',['随机']='随机摩卡卡:BAAALAAFFAIIAgAAAA==.',['雅修']='雅修特拉:BAABLAAFFH8GAAIOAAIIGRg0PgChAAAOAAIIGRg0PgChAAAAAA==.',['雾乾']='雾乾真:BAAALAAECgIIAgAAAA==.',['霸天']='霸天雷:BAABLAAFFH8GAAIEAAMIjAhyaQB5AAAEAAMIjAhyaQB5AAABLAAFFAYIEQASADUUAA==.',['霸电']='霸电:BAAALAAECgYIDwAAAA==.',['青笋']='青笋:BAABLAAFFH8QAAMDAAMIwha8CwC3AAADAAIIKBy8CwC3AAAEAAMIuRTHZACHAAAAAA==.',['静谧']='静谧灬之殇:BAAALAAECgYICAABLAAECgcIFwATADocAA==.',['风哥']='风哥掉线:BAAALAAFFAIIAgAAAA==.',['风骚']='风骚如我:BAAALAAECgYIDwAAAA==.',['飞奔']='飞奔的羊驼:BAAALAAECgMIAwAAAA==.',['骑乌']='骑乌龟追导弹:BAABLAAECn8YAAQYAAYIgA2ZJgD1AAAYAAYIKA2ZJgD1AAAOAAUIvwUjXwCGAAAZAAEIyANjFwAZAAAAAA==.',['高颜']='高颜值的光头:BAAALAAECgEIAQAAAA==.',['鸡一']='鸡一般风骚:BAAALAAECgYIEQAAAA==.',['黑暗']='黑暗的咒术师:BAAALAAECgMIAwAAAA==.',['黑石']='黑石山鸫客:BAAALAAECggIDgAAAA==.',['黑闇']='黑闇戰魂:BAAALAAECgYIBwAAAA==.黑闇魔爵:BAAALAADCgUICQAAAA==.',['龙富']='龙富贵:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end