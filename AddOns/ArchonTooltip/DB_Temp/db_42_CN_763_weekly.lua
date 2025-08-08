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
 local lookup = {'Druid-Restoration','Druid-Balance','Hunter-BeastMastery','DeathKnight-Unholy','Druid-Guardian','Druid-Feral','Shaman-Restoration','Mage-Fire','Mage-Arcane','Paladin-Retribution','Hunter-Marksmanship','Shaman-Enhancement','DemonHunter-Havoc','Warrior-Fury','Warrior-Protection','DeathKnight-Blood','Monk-Mistweaver','Priest-Discipline','Priest-Holy','Unknown-Unknown','Shaman-Elemental','Monk-Windwalker','Warlock-Destruction','Paladin-Protection','Warlock-Affliction','DemonHunter-Vengeance','Priest-Shadow','Rogue-Assassination','Mage-Frost',}; local provider = {region='CN',realm='瑞文戴尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alexander:BAAAKgADCgEIAQAAAA==.',Bi='Bigmo:BAAAKgAFFAQIBAAAAA==.',De='Deathshenzhe:BAAAKgADCgEIAQAAAA==.',Do='Donkey:BAAAKgADCggICAAAAA==.',Ga='Gaerian:BAAAKgAECggICwAAAA==.',Jo='Jophy:BAAAKgAECgQIBAAAAA==.',Js='Jsp:BAAAKgAECgMIBQAAAA==.',Ma='Manman:BAABKgAECn8VAAMBAAgItA5ENABKAQABAAgItA5ENABKAQACAAcIxw/DXwBBAQAAAA==.',Mi='Milkangel:BAAAKgADCggICAAAAA==.',Na='Naibadx:BAAAKgAECgMIBAAAAA==.',Ni='Nightwu:BAAAKgAECggICAAAAA==.',Pl='Playermistog:BAAAKgAECgIIAgAAAA==.Playerorpwoq:BAAAKgADCgYIBgAAAA==.',Re='Rebel:BAABKgAFFH8IAAIDAAgI0wKnDgBAAQADAAgI0wKnDgBAAQAAAA==.',Ro='Roomny:BAABKgAFFH8OAAIDAAcICRtpEQBsAQADAAcICRtpEQBsAQAAAA==.Royalknight:BAAAKgAECgEIAQAAAA==.',Sn='Snovv:BAAAKgAECgcIBwAAAA==.',Vi='Vivipig:BAAAKgAECgQIBAAAAA==.',Wm='Wmmwwmmwwmmw:BAAAKgAECgMIAwAAAA==.',Xi='Xiaohei:BAAAKgAECgUIBQAAAA==.',Xx='Xxboy:BAAAKgADCgEIAQAAAA==.Xxffwwq:BAAAKgAECgYIBQAAAA==.',Yi='Yiyo:BAAAKgAECgEIAQAAAA==.',Ze='Zeus:BAAAKgAECgcIBQAAAA==.',['一只']='一只大老虎丶:BAABKgAFFH8IAAIEAAgIxQsHBwDlAQAEAAgIxQsHBwDlAQAAAA==.',['一船']='一船沁水:BAAAKgAECgIIAgAAAA==.',['七叶']='七叶:BAAAKgAECgEIAQAAAA==.',['九分']='九分半:BAAAKgADCgUIBQAAAA==.',['今晚']='今晚砍老虎:BAAAKgADCgEIAgAAAA==.',['伊丽']='伊丽傻白:BAABKgAECn8UAAUBAAgIGATYUQCcAAABAAgIGATYUQCcAAAFAAQICgRFOwA4AAACAAEIggho3gAlAAAGAAMIlQGaMgATAAAAAA==.',['传说']='传说的蛋挞:BAAAKgAECggICAAAAA==.',['你是']='你是谁的猴:BAACKgAFFH8QAAIHAAQI5QudFwDHAAAHAAQI5QudFwDHAAAqAAQKfxQAAgcACAjnHdYVAFECAAcACAjnHdYVAFECAAAA.',['你追']='你追不上我:BAAAKgADCggICAAAAA==.',['倾城']='倾城无双:BAABKgAFFH8MAAMBAAgIaBkuCQB0AQABAAQIwx4uCQB0AQACAAYIfA0/BABzAQAAAA==.',['偶就']='偶就素浮云:BAAAKgAECgUIBQAAAA==.',['光之']='光之心语:BAAAKgAECgMIAwAAAA==.',['八月']='八月未央:BAAAKgAFFAQIBAAAAA==.',['六合']='六合冢弥生:BAAAKgADCggICAAAAA==.',['凯兰']='凯兰崔尔:BAABKgAFFH8NAAMIAAYIwR4CCQBsAQAIAAYIwR4CCQBsAQAJAAEIgxW5JQBQAAAAAA==.',['凯尔']='凯尔文点南:BAAAKgADCgEIAQAAAA==.',['凹凸']='凹凸凹凸凸:BAAAKgAECgIIAgAAAA==.',['刀剑']='刀剑客:BAAAKgADCgEIAQAAAA==.',['加加']='加加子:BAAAKgAECggICgAAAA==.',['加斯']='加斯特:BAABKgAFFH8GAAIHAAYI/AufDwAFAQAHAAYI/AufDwAFAQAAAA==.',['勇者']='勇者无畏:BAABKgAFFH8IAAIKAAQIgx27IgDiAAAKAAQIgx27IgDiAAAAAA==.',['北大']='北大屠夫:BAAAKgADCgIIBQAAAA==.',['千味']='千味涮:BAAAKgAECgcIBwAAAA==.',['半怜']='半怜丶:BAAAKgAECgIIAgAAAA==.',['华丽']='华丽邂逅:BAAAKgADCgIIAgAAAA==.',['华庭']='华庭笙歌:BAAAKgAECgYIEAAAAA==.',['卖元']='卖元宵:BAAAKgAECgEIAQAAAA==.',['卖油']='卖油条:BAAAKgAECgEIAQAAAA==.',['卖煎']='卖煎饼:BAAAKgAECgYICwAAAA==.',['卖葫']='卖葫芦:BAAAKgAECgQIBQAAAA==.',['卖饺']='卖饺子:BAAAKgAECgMIBAAAAA==.',['危机']='危机:BAAAKgAECgYIBwAAAA==.',['厶承']='厶承喏厶:BAAAKgADCgIIAgAAAA==.',['司徒']='司徒夜月:BAAAKgADCgYIBgAAAA==.',['吃茶']='吃茶去:BAAAKgAECgEIAQAAAA==.',['名字']='名字很不重要:BAAAKgAECggIDAAAAA==.',['呆呆']='呆呆丶头:BAAAKgAECgEIAQAAAA==.',['命运']='命运木马:BAAAKgADCgIIAgAAAA==.',['喜茶']='喜茶:BAABKgAFFH8OAAMDAAYI3xvLEgBgAQADAAYI3xvLEgBgAQALAAQILxbCCwDuAAAAAA==.',['嗜血']='嗜血狂魔:BAAAKgADCggICAAAAA==.',['嚯嚯']='嚯嚯嘿嘿:BAAAKgADCgUICQAAAA==.',['夜幕']='夜幕颂葬:BAAAKgAFFAYIBAAAAA==.',['大原']='大原:BAAAKgADCgUIBQAAAA==.',['天使']='天使圣骑:BAAAKgAFFAIIAgAAAA==.',['天然']='天然擸:BAAAKgADCgMIAgAAAA==.',['天窗']='天窗:BAAAKgADCgMIAwAAAA==.',['失恋']='失恋王:BAABKgAFFH8GAAIMAAYIwwabCQA7AQAMAAYIwwabCQA7AQAAAA==.',['奈伊']='奈伊组特:BAAAKgADCggICAAAAA==.',['奥蕊']='奥蕊莉娅:BAAAKgAFFAQIBAAAAA==.',['奶不']='奶不动你的错:BAAAKgAECgYIBgAAAA==.',['姐夰']='姐夰庅覇氣彡:BAAAKgAECggIDQAAAA==.',['姬無']='姬無雙:BAAAKgAECgUIBQAAAA==.',['孙悟']='孙悟空空:BAAAKgAECgUIBQAAAA==.',['安妮']='安妮海瑟薇:BAAAKgADCgEIAQAAAA==.',['宗像']='宗像五月:BAAAKgAFFAYIBAAAAA==.',['寒月']='寒月照孤灯:BAAAKgAECggICAAAAA==.',['小二']='小二上酒:BAABKgAFFH8KAAINAAMIzxROJgDeAAANAAMIzxROJgDeAAAAAA==.',['小姽']='小姽婳:BAAAKgAECgcICAAAAA==.',['小暗']='小暗之殇:BAAAKgAECgMIAwAAAA==.',['小棉']='小棉宝贝:BAABKgAFFH8LAAICAAYIhQkBIAAgAQACAAYIhQkBIAAgAQAAAA==.小棉袄:BAAAKgAECgQIBAAAAA==.',['小野']='小野大輔:BAAAKgAECgMIBQAAAA==.',['就差']='就差干饭了:BAAAKgAECgUIBQAAAA==.',['希洛']='希洛:BAAAKgADCgEIAQAAAA==.',['席尔']='席尔洛:BAAAKgAECgIIAgAAAA==.',['幸福']='幸福的恶魔:BAAAKgADCgMIAwAAAA==.幸福的战神:BAABKgAFFH8GAAMOAAMI9xAbHgDcAAAOAAMI9xAbHgDcAAAPAAEISAFkGQAWAAAAAA==.',['弄影']='弄影:BAAAKgAECgMIAwAAAA==.',['往事']='往事如影:BAAAKgAECgIIBgAAAA==.',['微光']='微光之夜:BAAAKgADCgQIBAAAAA==.',['必理']='必理痛:BAAAKgADCggICAAAAA==.',['恩赐']='恩赐解脫:BAABKgAFFH8MAAMMAAQICxPRCgD6AAAMAAQICxPRCgD6AAAHAAQIxxlhKQDRAAAAAA==.',['惩戒']='惩戒之光:BAABKgAFFH8NAAIKAAMIYBEdVADIAAAKAAMIYBEdVADIAAAAAA==.',['我是']='我是地精:BAACKgAFFH8FAAMEAAIINgTtTgBfAAAEAAIINgTtTgBfAAAQAAEIqANdJwAqAAAqAAQKfxQAAxAACAgbEa04AOMAABAABgg4EK04AOMAAAQAAwjQD+qRALEAAAAA.我是烙饼:BAAAKgADCgUIBQAAAA==.',['我本']='我本无心:BAAAKgAECgYIDgAAAA==.',['战无']='战无汐:BAAAKgADCgQIBAAAAA==.',['拂晓']='拂晓清风:BAAAKgAFFAQIBAAAAA==.',['提子']='提子:BAAAKgAECggICAAAAA==.',['搜查']='搜查官:BAAAKgAECgIIAgAAAA==.',['擎道']='擎道京殿:BAABKgAFFH8KAAMLAAgIWxbrBwDhAQALAAgIqRPrBwDhAQADAAIIzhQAAAAAAAAAAA==.擎道柏劈:BAAAKgADCgEIAQAAAA==.擎道淳圣:BAABKgAFFH8HAAIKAAcI/hYpGACcAQAKAAcI/hYpGACcAQAAAA==.',['擱座']='擱座揚陸姫:BAABKgAFFH8HAAIRAAYIyBFIDgBCAQARAAYIyBFIDgBCAQAAAA==.',['无限']='无限飞弹:BAAAKgAFFAQIAwAAAA==.',['时光']='时光之房御:BAABKgAECn8iAAIKAAgIDx9iKgBWAgAKAAgIDx9iKgBWAgAAAA==.',['旷世']='旷世枭雄:BAAAKgAECggICAAAAA==.',['明前']='明前奶绿:BAABKgAECn8WAAMSAAgI7RYFJwCbAQASAAgIzhMFJwCbAQATAAYIIRgLTgAAAQAAAA==.',['星之']='星之塵:BAAAKgADCgMIAwAAAA==.',['晴天']='晴天小星:BAAAKgADCggICAAAAA==.',['月汐']='月汐雪翎:BAAAKgAFFAQIBAAAAA==.',['李寻']='李寻歡:BAAAKgADCggICgABKgAFFAgIAwAUAAAAAA==.',['来之']='来之天堂的我:BAAAKgAECgEIAQAAAA==.',['格噜']='格噜:BAAAKgAECgcICwAAAA==.',['梅利']='梅利凯碎风:BAAAKgADCggICAAAAA==.',['梓琪']='梓琪丨:BAABKgAFFH8GAAIOAAYIziA7CQC/AQAOAAYIziA7CQC/AQAAAA==.',['棒棒']='棒棒:BAAAKgAECgIIBAAAAA==.',['楓飘']='楓飘棂:BAABKgAFFH8PAAMDAAgIsxV2AQDnAQADAAcIGxF2AQDnAQALAAQI2RXmDgDeAAAAAA==.',['橙仙']='橙仙:BAAAKgADCggICAAAAA==.',['櫻木']='櫻木真乃:BAAAKgAECgUIBQABKgAFFAYIBwARAMgRAA==.',['水水']='水水獭:BAABKgAFFH8JAAIDAAMIABJ+NwC5AAADAAMIABJ+NwC5AAAAAA==.',['水灬']='水灬僧:BAAAKgADCggIEAAAAA==.',['江湖']='江湖再见:BAAAKgADCggICAAAAA==.',['泓兮']='泓兮化工:BAAAKgAECgcICwAAAA==.',['波灬']='波灬波:BAAAKgAECgUIBQAAAA==.',['泰迪']='泰迪熊丶:BAABKgAFFH8FAAIBAAUI1AmOCgDnAAABAAUI1AmOCgDnAAAAAA==.',['浩爷']='浩爷去哪儿:BAAAKgAFFAMIAwAAAA==.',['海妲']='海妲:BAAAKgADCggICAAAAA==.',['滑溜']='滑溜:BAAAKgADCgUIBQAAAA==.',['满仓']='满仓纳斯达克:BAAAKgAFFAEIAQAAAA==.',['灰色']='灰色夜曲:BAAAKgAECgQIBAAAAA==.',['炎枪']='炎枪素笺鸣:BAAAKgAFFAQIBAAAAA==.',['炽翎']='炽翎筱筱:BAABKgAFFH8MAAIKAAQIXRaqFgD/AAAKAAQIXRaqFgD/AAAAAA==.',['热气']='热气哈:BAAAKgADCgQIBAAAAA==.热气哦:BAABKgAFFH8IAAICAAQIBBRXGQDZAAACAAQIBBRXGQDZAAAAAA==.',['焦厚']='焦厚根:BAAAKgADCggICAAAAA==.',['熊猫']='熊猫棒子:BAACKgAFFH8RAAMHAAQIVRqzEADhAAAHAAQIVRqzEADhAAAVAAEIYQYfKQA1AAAqAAQKfxkAAgcACAilGW0lAPoBAAcACAilGW0lAPoBAAAA.',['熊骧']='熊骧猫视:BAAAKgADCggICwAAAA==.',['爱允']='爱允宝:BAAAKgAECgMIAwAAAA==.',['爱飘']='爱飘零:BAAAKgAECgMIAwAAAA==.',['爵戀']='爵戀小壞蛋:BAAAKgAFFAEIAQAAAA==.',['狐狸']='狐狸狸:BAAAKgAECgYIBwAAAA==.',['狼里']='狼里格浪:BAAAKgADCggICAAAAA==.',['猎天']='猎天使丶蕉男:BAACKgAFFH8MAAIWAAQI1w2vDQDNAAAWAAQI1w2vDQDNAAAqAAQKfxsAAxYACAi+GfYyAFoBABYABgiDF/YyAFoBABEACAg+B55IABsBAAAA.',['猎手']='猎手风暴:BAAAKgAECgYIDAAAAA==.',['猎魔']='猎魔天使丶女:BAABKgAFFH8MAAINAAYIgwmsDwBBAQANAAYIgwmsDwBBAQAAAA==.',['猛将']='猛将之首:BAAAKgAFFAIIAwAAAA==.',['猥大']='猥大的色郎:BAAAKgADCgMIAwAAAA==.',['猫雷']='猫雷最强:BAAAKgAFFAQIBAAAAA==.',['王大']='王大牛:BAAAKgAECggICAAAAA==.',['瓦鸡']='瓦鸡扎针:BAABKgAFFH8GAAIXAAYI5Qp9GwAqAQAXAAYI5Qp9GwAqAQAAAA==.',['白小']='白小纯:BAAAKgAECgQIBAAAAA==.',['百岢']='百岢:BAAAKgADCgUIBQAAAA==.',['破碎']='破碎星光:BAABKgAECn8YAAMKAAgI1Bc8ZQCSAQAKAAgI1Bc8ZQCSAQAYAAEI+AHsYgAFAAAAAA==.',['祭司']='祭司五月:BAAAKgAECgYICQAAAA==.',['秀的']='秀的氺乱流:BAAAKgAECgcICgAAAA==.',['秋名']='秋名山老司机:BAACKgAFFH8fAAIKAAQIuCSFDAAiAQAKAAQIuCSFDAAiAQAqAAQKfyEAAgoACAijJMQUAMQCAAoACAijJMQUAMQCAAAA.',['竹子']='竹子:BAAAKgAECgUIBQAAAA==.',['笙歌']='笙歌华庭:BAAAKgADCgEIAQAAAA==.笙歌启华:BAAAKgAECgcICAAAAA==.',['第五']='第五人格:BAAAKgADCgMIAwAAAA==.',['糖門']='糖門:BAAAKgADCggICAAAAA==.',['紫枫']='紫枫:BAAAKgAFFAYIBAAAAA==.',['紫色']='紫色苍蝇:BAAAKgAECgIIAgAAAA==.',['緒方']='緒方理奈:BAAAKgAFFAQIBAABKgAFFAYIBwARAMgRAA==.',['纳芈']='纳芈:BAABKgAFFH8TAAIZAAQIsCLKBgAXAQAZAAQIsCLKBgAXAQAAAA==.',['网瘾']='网瘾李大爷:BAAAKgAECgQIBAAAAA==.',['老鬼']='老鬼丶:BAABKgAFFH8GAAIKAAYIhA42FABbAQAKAAYIhA42FABbAQAAAA==.',['耳朵']='耳朵:BAAAKgADCgQIBQAAAA==.',['肉米']='肉米:BAACKgAFFH8WAAIaAAUIaiN8AwCgAQAaAAUIaiN8AwCgAQAqAAQKfyoAAhoACAiEHMETAPwBABoACAiEHMETAPwBAAAA.',['肉糜']='肉糜:BAAAKgADCgUIBQAAAA==.',['脸萌']='脸萌即使正义:BAABKgAFFH8HAAIDAAMIYyCAJwDoAAADAAMIYyCAJwDoAAAAAA==.',['至爱']='至爱米麒:BAAAKgADCgEIAQAAAA==.',['芹泽']='芹泽嘿木洱:BAAAKgADCgEIAQAAAA==.芹泽多摩雄:BAAAKgADCgMIAQAAAA==.',['若何']='若何兮洛:BAABKgAFFH8KAAIKAAYI/SHQCQAmAgAKAAYI/SHQCQAmAgAAAA==.',['若影']='若影千面:BAABKgAFFH8IAAICAAgIiQ7+CQD2AQACAAgIiQ7+CQD2AQAAAA==.',['茶大']='茶大潘丿:BAABKgAFFH8FAAIbAAMIZhQlEADeAAAbAAMIZhQlEADeAAAAAA==.',['萨满']='萨满满:BAAAKgAECggICAAAAA==.',['蕙兰']='蕙兰:BAAAKgAECgYICgAAAA==.',['薇妲']='薇妲:BAAAKgAECggICAAAAA==.',['角落']='角落的尘埃:BAACKgAFFH8TAAIcAAQIdxWGGADkAAAcAAQIdxWGGADkAAAqAAQKfy0AAhwACAjtHasLAEsCABwACAjtHasLAEsCAAAA.',['赛尔']='赛尔堤:BAABKgAFFH8GAAIQAAYI0QG8IACgAAAQAAYI0QG8IACgAAAAAA==.',['赫赫']='赫赫明明:BAAAKgADCggICAAAAA==.',['超级']='超级红手:BAAAKgAECggICAAAAA==.',['跟师']='跟师太抢秃驴:BAABKgAFFH8FAAIXAAIIwgWJRQBUAAAXAAIIwgWJRQBUAAAAAA==.',['达文']='达文西:BAAAKgADCgEIAQAAAA==.',['这份']='这份爱死心:BAABKgAFFH8GAAISAAYIyw0ZDQBEAQASAAYIyw0ZDQBEAQAAAA==.这份爱狠心:BAAAKgADCgUIBQAAAA==.',['违规']='违规昵称:BAAAKgAFFAQIBAAAAA==.',['迷途']='迷途的小猫:BAAAKgAFFAQIBAABKgAFFAgICwATAKsaAA==.',['追风']='追风筝的胖子:BAAAKgAECggICAAAAA==.',['逐风']='逐风者阿光:BAAAKgAECgEIAQAAAA==.',['醉倚']='醉倚兰轩:BAAAKgAECggICgAAAA==.',['醉卧']='醉卧幽谷:BAAAKgADCggICAAAAA==.',['野花']='野花香:BAAAKgADCggIDgAAAA==.',['错误']='错误:BAAAKgADCgUIBQAAAA==.',['镜影']='镜影湖光:BAABKgAECn8WAAIcAAgI+RPuGADDAQAcAAgI+RPuGADDAQAAAA==.',['队友']='队友祭天:BAAAKgAFFAgIBAAAAA==.',['阿凡']='阿凡猫毛:BAACKgAFFH8MAAIdAAMIHBm3DwDkAAAdAAMIHBm3DwDkAAAqAAQKfyYAAh0ACAjSHLshAAICAB0ACAjSHLshAAICAAAA.',['随风']='随风两板丶砖:BAABKgAFFH8GAAMRAAYI6w4yEQAhAQARAAQIIhEyEQAhAQAWAAIIJQsFHQBHAAAAAA==.',['雨还']='雨还在:BAAAKgADCgEIAQAAAA==.',['非洲']='非洲酋长之怒:BAAAKgAECgUIBQAAAA==.',['风哈']='风哈拉哨:BAABKgAFFH8MAAICAAgI5RpuBgBHAgACAAgI5RpuBgBHAgAAAA==.',['风暴']='风暴烈酒:BAAAKgAFFAIIAgAAAA==.',['魔法']='魔法猫粮:BAAAKgAECgMIAwAAAA==.',['鲁智']='鲁智深:BAAAKgAFFAIIAgAAAA==.',['黑风']='黑风小萨:BAABKgAFFH8QAAMHAAgIZQq/DQBzAQAHAAcIYwu/DQBzAQAVAAUIyxDqCQDfAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end