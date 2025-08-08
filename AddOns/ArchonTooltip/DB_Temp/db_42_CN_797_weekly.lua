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
 local lookup = {'Unknown-Unknown','Mage-Frost','Priest-Holy','Shaman-Restoration','Priest-Discipline','Druid-Restoration','Mage-Arcane','Mage-Fire','Hunter-BeastMastery','Paladin-Protection','DeathKnight-Blood','DeathKnight-Unholy','Druid-Balance','Paladin-Retribution','Shaman-Elemental','DeathKnight-Frost','Hunter-Marksmanship','Hunter-Survival','Warlock-Destruction','Priest-Shadow','Druid-Feral','Druid-Guardian','Monk-Mistweaver','Warrior-Fury','Warrior-Arms','Evoker-Devastation','Warrior-Protection','Shaman-Enhancement','DemonHunter-Vengeance','Rogue-Outlaw','DemonHunter-Havoc','Warlock-Demonology','Warlock-Affliction','Monk-Brewmaster','Monk-Windwalker','Paladin-Holy',}; local provider = {region='CN',realm='自由之风',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abysstoller:BAAAKgAECgUIDQABKgAECggIDAABAAAAAA==.',Ap='Apocalypsy:BAAAKgADCggICAAAAA==.',As='Asky:BAAAKgAECgYIBgAAAA==.',Az='Azura:BAAAKgADCgIIAgAAAA==.',Be='Bestqing:BAAAKgADCgEIAQAAAA==.',Bl='Blameuncle:BAAAKgAECggIEQAAAA==.',Ca='Cababa:BAABKgAFFH8RAAICAAMIWyPaCQAoAQACAAMIWyPaCQAoAQAAAA==.',Da='Daladin:BAAAKgAECgYICgABKgAECggINQADAEwkAA==.',De='Devoker:BAAAKgADCggIGAABKgAECggINQADAEwkAA==.',Dh='Dhaman:BAABKgAECn8UAAIEAAgIrx9oGwAjAgAEAAgIrx9oGwAjAgABKgAECggINQADAEwkAA==.',Dr='Driest:BAABKgAECn81AAMDAAgITCTyBQC5AgADAAgIOCTyBQC5AgAFAAUI5yFZKwCBAQAAAA==.Druidd:BAABKgAECn8hAAIGAAgIih0zDgA/AgAGAAgIih0zDgA/AgABKgAECggINQADAEwkAA==.',Em='Emno:BAAAKgAECggIDQAAAA==.',Es='Essementhol:BAAAKgAECgUICAAAAA==.',Fa='Faceless:BAABKgAFFH8PAAQHAAgIBBjcBABQAgAHAAgIBBjcBABQAgAIAAQIZAcPIAC1AAACAAMIqxF5FgCBAAAAAA==.',Fo='Foxman:BAAAKgAECgcICwAAAA==.',Gr='Grimoire:BAAAKgAFFAgIAQAAAA==.',Ic='Icetea:BAAAKgAECgYIBgAAAA==.',Je='Jearo:BAABKgAFFH8oAAIJAAQI0BnNFADnAAAJAAQI0BnNFADnAAAAAA==.',Jo='Josephlee:BAAAKgAECgEIAQAAAA==.',Li='Life:BAABKgAFFH8MAAIKAAgIfhFwBgC8AQAKAAgIfhFwBgC8AQAAAA==.',Lo='Lovelybaby:BAAAKgAECgYIDwAAAA==.',Lu='Luvsicpthree:BAAAKgAECggIDAAAAA==.',Ma='Malenia:BAAAKgAECggIEAAAAA==.',Mc='Mcy:BAAAKgADCgEIAQAAAA==.',Me='Meinagano:BAABKgAFFH8GAAMLAAQIfxISKAB2AAAMAAIItBamGgCPAAALAAIISg4SKAB2AAAAAA==.Mercy:BAAAKgADCgEIAQAAAA==.',Re='Rennala:BAABKgAFFH8FAAINAAUIIgAUZgAOAAANAAUIIgAUZgAOAAAAAA==.',Sa='Sanuyuki:BAABKgAECn8ZAAIFAAgI1AsbQADrAAAFAAgI1AsbQADrAAAAAA==.Satorare:BAAAKgAECgYIBgAAAA==.',St='Strank:BAABKgAFFH8LAAIOAAYIbyOODgAaAQAOAAYIbyOODgAaAQAAAA==.',Th='Thatgirl:BAAAKgAECgIIAwAAAA==.',To='Toot:BAABKgAFFH8uAAMEAAYI9BnyHQAEAQAEAAUIyRbyHQAEAQAPAAEIZwSPJwA+AAAAAA==.',Tu='Turn:BAAAKgAECgMIBQAAAA==.Turndk:BAAAKgAECgEIAgAAAA==.Turnss:BAAAKgAECgQICAAAAA==.',Va='Vagabondz:BAABKgAECn8YAAIMAAgIxBQkNQChAQAMAAgIxBQkNQChAQAAAA==.',Vi='Vii:BAAAKgAECgMIBwAAAA==.',Xs='Xsno:BAABKgAECn8nAAIQAAgIxCJTAwC6AgAQAAgIxCJTAwC6AgAAAA==.',['一抹']='一抹绿茶的妹:BAAAKgADCggICAAAAA==.',['一无']='一无所获:BAAAKgADCgQIBgAAAA==.',['一笑']='一笑好运:BAAAKgAECgEIAQAAAA==.',['不见']='不见花海:BAABKgAFFH8rAAQRAAgIGxqRCQC+AQARAAgIfBmRCQC+AQAJAAUINxzHFQBIAQASAAEINgFsBwAnAAAAAA==.',['与友']='与友为伴:BAAAKgADCggICAAAAA==.',['专杀']='专杀泪:BAAAKgADCgEIAgAAAA==.',['且听']='且听風吟:BAABKgAECn8bAAQCAAgI7x9vGADyAQACAAcIJSBvGADyAQAHAAUI+hyCQwAyAQAIAAQIPBT6XAAAAQAAAA==.',['且聽']='且聽風吟:BAABKgAFFH8KAAMKAAYI+yXaAADMAQAKAAYI+yXaAADMAQAOAAQIDRizGgD1AAABKgAFFAgIGAAKAEwcAA==.',['东海']='东海边的小君:BAAAKgAECggIDwAAAA==.',['东风']='东风四一:BAAAKgAFFAMIAwAAAA==.',['丧彪']='丧彪:BAABKgAFFH8YAAITAAgIQiFoAQDkAQATAAgIQiFoAQDkAQAAAA==.',['丶溜']='丶溜溜:BAABKgAFFH8WAAIUAAQI/R+QDgAZAQAUAAQI/R+QDgAZAQAAAA==.',['丶生']='丶生悻哆懿:BAAAKgAFFAgIAgAAAA==.',['为了']='为了蛋总:BAAAKgAECgMIBQAAAA==.',['丿执']='丿执著丶囗囗:BAAAKgAECgIIAwAAAA==.',['久远']='久远的猫音:BAAAKgAECgYICwAAAA==.',['乌瑞']='乌瑞亚:BAAAKgAFFAYIBAABKgAFFAgICAARAB8hAA==.',['九妄']='九妄:BAAAKgAECgMIAwAAAA==.',['于浴']='于浴菊:BAAAKgADCggIBgAAAA==.',['亽氼']='亽氼太美:BAAAKgADCgYICQAAAA==.',['伊岚']='伊岚诺尔:BAAAKgAECgYIBgAAAA==.',['伊黎']='伊黎璟子:BAAAKgADCgIIAgAAAA==.',['伤心']='伤心的精灵:BAAAKgAECggIDwAAAA==.',['伱老']='伱老婆:BAAAKgAECgYICQAAAA==.',['低级']='低级法力残渣:BAAAKgAFFAIIAgAAAA==.',['佟大']='佟大为:BAACKgAFFH8JAAQVAAQISCLZAwC+AAAVAAIISSbZAwC+AAAWAAEIRRofDgA7AAANAAEIAADNagAAAAAqAAQKfycAAxUACAiDJQQBAPwCABUACAiDJQQBAPwCAA0AAgjmHTO+AEUAAAAA.',['依宇']='依宇:BAAAKgAECgEIAQAAAA==.',['值机']='值机前列线:BAABKgAFFH8GAAIRAAYIhR/1CgCnAQARAAYIhR/1CgCnAQAAAA==.',['傲风']='傲风残花:BAAAKgAECggIDwAAAA==.',['儍馒']='儍馒:BAABKgAFFH8GAAIEAAYIJAhzGQAbAQAEAAYIJAhzGQAbAQAAAA==.',['元旺']='元旺宝仔:BAABKgAFFH8IAAIXAAgImxjNBAANAgAXAAgImxjNBAANAgAAAA==.',['光头']='光头:BAABKgAECn9pAAMYAAgIHSYgAgAIAwAYAAgIHSYgAgAIAwAZAAUIbhVKQADXAAAAAA==.',['克莉']='克莉斯塔萨:BAAAKgAECgUIBQAAAA==.',['克麗']='克麗絲:BAABKgAFFH8IAAILAAgIUQ7aFQDyAAALAAgIUQ7aFQDyAAAAAA==.',['兜儿']='兜儿里有糖:BAAAKgAECgEIAQAAAA==.',['八百']='八百里开外:BAAAKgADCgIIAgAAAA==.',['八雲']='八雲橙:BAABKgAFFH8MAAMNAAQIKQ0ZQACrAAANAAQIKQ0ZQACrAAAGAAQINRK7IACnAAABKgAFFAgIBAABAAAAAA==.八雲紫:BAABKgAFFH8JAAITAAUIHRbHHQAaAQATAAUIHRbHHQAaAQABKgAFFAgIFAATALEhAA==.',['冈仁']='冈仁波齐:BAABKgAECn8ZAAIJAAgIZRK8RwCJAQAJAAgIZRK8RwCJAQAAAA==.',['冬天']='冬天:BAAAKgAECgYIDgAAAA==.',['冰丶']='冰丶紅丶嗏:BAAAKgAECgMIAwAAAA==.',['冰清']='冰清玉洁:BAABKgAECn85AAIMAAgIuSQxCADaAgAMAAgIuSQxCADaAgAAAA==.',['冰美']='冰美式:BAAAKgAECgIIAgAAAA==.',['凯尔']='凯尔特:BAAAKgADCgEIAgAAAA==.',['凰荧']='凰荧:BAACKgAFFH8HAAIaAAMIURBfJgCkAAAaAAMIURBfJgCkAAAqAAQKfx4AAhoACAiEFyAaAO0BABoACAiEFyAaAO0BAAAA.',['凵靦']='凵靦鼑菂霅凵:BAAAKgADCggICAAAAA==.',['凸凹']='凸凹凸:BAAAKgAFFAMIAwAAAA==.',['剑无']='剑无民丨灬:BAAAKgAFFAYIBAAAAA==.',['剛達']='剛達魯夫:BAAAKgAECggIEAAAAA==.',['劍雪']='劍雪飄零:BAAAKgAFFAMIAwAAAA==.',['北夜']='北夜辰:BAABKgAFFH8GAAIOAAYIdxW9IQBnAQAOAAYIdxW9IQBnAQAAAA==.',['十万']='十万伏特:BAABKgAECn8XAAMPAAcIKhvdJADLAQAPAAcIKhvdJADLAQAEAAYIhhpVSgBRAQAAAA==.',['即日']='即日启程:BAAAKgAFFAQIBAAAAA==.',['厉风']='厉风邪:BAAAKgADCggICQAAAA==.',['又黑']='又黑又猛:BAAAKgAECgYIBgAAAA==.',['变啊']='变啊变:BAAAKgAFFAMIAwAAAA==.',['古尔']='古尔卩:BAAAKgADCgQIBQAAAA==.',['叮叮']='叮叮铛丶:BAAAKgAECgMIAwAAAA==.',['叮噹']='叮噹丶:BAAAKgADCgUIBQAAAA==.',['可乐']='可乐新之柱:BAAAKgADCggICAAAAA==.',['吃人']='吃人刀丶:BAAAKgAFFAYIAgAAAA==.',['吉吉']='吉吉丨安娜:BAAAKgADCggICAAAAA==.',['名捕']='名捕铁手:BAABKgAECn8VAAIXAAgIfQ0WKwA9AQAXAAgIfQ0WKwA9AQAAAA==.',['咏春']='咏春拳:BAAAKgAECgIIAgAAAA==.',['哩咕']='哩咕哩咕胡了:BAAAKgAECggICAAAAA==.',['善恶']='善恶有报:BAACKgAFFH8SAAMMAAYIqh8LCADEAQAMAAYIqh8LCADEAQALAAUIhhC0FwDjAAAqAAQKfxgAAgwACAgoJUcJANICAAwACAgoJUcJANICAAAA.',['喵圆']='喵圆圆:BAABKgAFFH8DAAIXAAMIvheMJgCJAAAXAAMIvheMJgCJAAAAAA==.',['嘟嘟']='嘟嘟噜咕咕丶:BAABKgAFFH8JAAINAAYI0g4RGgBJAQANAAYI0g4RGgBJAQAAAA==.嘟嘟噜嘟嘟丶:BAAAKgADCggICAAAAA==.',['嘟噜']='嘟噜嘟噜噜丶:BAAAKgADCgEIAQAAAA==.',['嘤嘤']='嘤嘤阿花丶:BAABKgAFFH8KAAIMAAQITRaCMQDNAAAMAAQITRaCMQDNAAAAAA==.',['圣光']='圣光小奶骑:BAAAKgAECgMIAwAAAA==.圣光小蹄子:BAABKgAFFH8FAAIKAAUIgxKDCgDnAAAKAAUIgxKDCgDnAAAAAA==.圣光邦桑迪:BAAAKgADCggICQAAAA==.',['圣狱']='圣狱神木:BAAAKgADCgIIAgAAAA==.圣狱酋长:BAAAKgAECgYIBwAAAA==.',['堕落']='堕落人生:BAAAKgAECggIDgAAAA==.',['墨尔']='墨尔多:BAAAKgADCgEIBAAAAA==.',['墨香']='墨香哭乱冢:BAABKgAECn8aAAMYAAgIlhG4OwAwAQAYAAYIkxK4OwAwAQAbAAgIaAxIJAAKAQAAAA==.',['复仇']='复仇大苗:BAAAKgAFFAYIBAAAAA==.',['复古']='复古风:BAAAKgADCgEIAQAAAA==.',['夏天']='夏天的西瓜叶:BAAAKgAECgIIAgAAAA==.',['多多']='多多柠檬:BAABKgAECn8wAAIcAAgITCMJBADDAgAcAAgITCMJBADDAgAAAA==.',['夜影']='夜影步行者:BAABKgAFFH8JAAIJAAQIRRTTLgDOAAAJAAQIRRTTLgDOAAAAAA==.',['夜揽']='夜揽星月:BAAAKgAFFAIIAgAAAA==.',['夜无']='夜无痕:BAAAKgADCggICAAAAA==.',['夜灬']='夜灬殇丨雪丨:BAAAKgAECgEIAgAAAA==.',['夜烟']='夜烟岚:BAAAKgAFFAIIAgAAAA==.',['夜雪']='夜雪痕:BAAAKgAFFAEIAQAAAA==.',['夜鸮']='夜鸮杜尔柯:BAAAKgAECgEIAQAAAA==.',['大头']='大头东:BAABKgAECn8ZAAMMAAgIZyNxCADPAgAMAAgITSNxCADPAgALAAcIXiEUDAAyAgAAAA==.大头东东:BAABKgAECn9lAAIMAAgIESb9AQAOAwAMAAgIESb9AQAOAwAAAA==.',['大眼']='大眼睛蕾蕾:BAAAKgAFFAQIBAAAAA==.',['大虫']='大虫灬挪得慢:BAAAKgAECgMIBAAAAA==.',['天神']='天神山丘:BAACKgAFFH8sAAMYAAYI+RvXCQCxAQAYAAYI+RvXCQCxAQAZAAEIaxiGKABNAAAqAAQKfygAAxgACAjrHqgTAGoCABgACAjrHqgTAGoCABkAAQjdBqlfAC8AAAAA.',['天道']='天道萌叔叔:BAAAKgAECgYIEwAAAA==.',['头光']='头光:BAABKgAECn8nAAMZAAgINSQVAwDqAgAZAAgINSQVAwDqAgAbAAEIZAAAAAAAAAAAAA==.',['奈德']='奈德丽:BAAAKgAECggIDQAAAA==.',['奔雷']='奔雷手文泰來:BAABKgAFFH8GAAIVAAYIciBdAQDYAQAVAAYIciBdAQDYAQAAAA==.',['奥格']='奥格野汉:BAAAKgAECggIDwAAAA==.',['奶丶']='奶丶慕:BAAAKgAECggICQAAAA==.',['奶粉']='奶粉加点糖:BAAAKgAECgYIBwAAAA==.',['奶糖']='奶糖糖:BAAAKgAECgYICwAAAA==.奶糖苹果甜派:BAAAKgAECggIBwAAAA==.',['奶骑']='奶骑:BAAAKgAECgQIBAAAAA==.',['好多']='好多鱼:BAAAKgAFFAIIAwAAAA==.',['宋雨']='宋雨琦的狗:BAABKgAFFH8JAAIOAAYI+iL+FAC0AQAOAAYI+iL+FAC0AQAAAA==.',['寒烟']='寒烟柔:BAABKgAFFH8IAAIdAAgIJgjuAwBiAQAdAAgIJgjuAwBiAQAAAA==.',['将冰']='将冰山劈开:BAABKgAFFH8GAAIKAAYIDxW9CwA8AQAKAAYIDxW9CwA8AQAAAA==.将冰山融化:BAAAKgAECgQIBQAAAA==.',['小型']='小型车:BAAAKgAECgEIAQAAAA==.',['小头']='小头东东:BAAAKgAFFAEIAQAAAA==.',['小家']='小家伙:BAACKgAFFH8FAAMPAAMIGg9hGgCoAAAPAAMIUQphGgCoAAAcAAIICBL2GACAAAAqAAQKfxUABA8ABwgsF9EzAG8BAA8ABwh9FdEzAG8BABwABQjkEtRBAMQAAAQAAghlB1u2AEkAAAAA.',['小尛']='小尛紫:BAACKgAFFH8UAAICAAgIyhr7AgDnAQACAAgIyhr7AgDnAQAqAAQKfxQAAgIACAhcInYDALICAAIACAhcInYDALICAAAA.',['小时']='小时候很萌丶:BAAAKgADCgQIBAAAAA==.小时候超吊丶:BAAAKgADCgQIBAAAAA==.小时候超猛丶:BAAAKgADCgUIBQAAAA==.',['小杀']='小杀:BAABKgAFFH8IAAIOAAgIUxjOBwA4AgAOAAgIUxjOBwA4AgAAAA==.',['小柳']='小柳:BAAAKgADCgMIAwAAAA==.',['小狗']='小狗:BAAAKgAECgIIAgAAAA==.',['小白']='小白糖:BAAAKgAECggIBQAAAA==.',['小萨']='小萨满:BAAAKgAECggIDwAAAA==.',['小风']='小风车:BAAAKgADCggICAAAAA==.',['尐尐']='尐尐瘸:BAABKgAFFH8FAAILAAUIaiAwCwBeAQALAAUIaiAwCwBeAQAAAA==.',['山丘']='山丘山丘:BAAAKgAECgMIAwAAAA==.',['巫耀']='巫耀王:BAAAKgAFFAMIBAAAAA==.',['巴卫']='巴卫:BAAAKgAECggICAAAAA==.',['巴烈']='巴烈斯:BAAAKgAECgIIAQAAAA==.',['布丢']='布丢丢:BAAAKgADCggICAAAAA==.',['希尔']='希尔瓦纳缌:BAABKgAFFH8OAAMJAAMI+hlVFQDjAAAJAAMI+hlVFQDjAAARAAII7AsYRABtAAAAAA==.',['帕拉']='帕拉丁:BAAAKgADCgIIAgAAAA==.',['帕格']='帕格妮妮:BAAAKgAECgUIBQAAAA==.',['帟恋']='帟恋嗱簖情:BAAAKgAFFAMIAwAAAA==.',['平静']='平静之海:BAAAKgAECgYIDQAAAA==.',['并泥']='并泥法:BAAAKgAECggIEgAAAA==.',['幺美']='幺美特斯邦威:BAAAKgADCgUIBQAAAA==.',['幻化']='幻化丶之神:BAABKgAFFH8GAAINAAYIpxefFQBsAQANAAYIpxefFQBsAQAAAA==.',['幽幽']='幽幽雲翼:BAABKgAFFH8GAAIYAAYIhQ2qDgBpAQAYAAYIhQ2qDgBpAQAAAA==.',['影小']='影小白:BAAAKgADCgcIBwAAAA==.',['影陽']='影陽:BAAAKgADCgIIAgAAAA==.',['彳亍']='彳亍口巴:BAAAKgAFFAEIAQAAAA==.',['彼时']='彼时的月光:BAABKgAFFH8KAAMGAAYI9hgUBwCiAQAGAAYI9hgUBwCiAQANAAIIXg3gNgBFAAAAAA==.',['往事']='往事随风吹:BAAAKgAECgQIBAAAAA==.',['微风']='微风细语:BAAAKgAECggICgAAAA==.',['德国']='德国装甲车:BAAAKgAFFAQIBAAAAA==.',['心的']='心的冬眠:BAAAKgAFFAgIAgAAAA==.',['忌霞']='忌霞伤:BAABKgAECn8UAAIRAAgIrR3lGAAJAgARAAgIrR3lGAAJAgAAAA==.',['忒西']='忒西:BAAAKgADCggIEAAAAA==.',['思念']='思念漫太古:BAAAKgAECgQIBAAAAA==.',['思思']='思思韵韵:BAAAKgAECgUIBQAAAA==.',['怨虎']='怨虎龙:BAAAKgAECggICAAAAA==.',['悠悠']='悠悠晓雪:BAABKgAFFH8GAAICAAYIxxiHBgBkAQACAAYIxxiHBgBkAQAAAA==.',['惘沉']='惘沉妖:BAAAKgAECggIEwAAAA==.',['我代']='我代表联盟:BAAAKgAECgMIAwAAAA==.',['我叫']='我叫胸毛哥哥:BAAAKgAECgYIBgAAAA==.',['我可']='我可以是源氏:BAAAKgAECggIEwAAAA==.',['我超']='我超漂亮的:BAAAKgAFFAIIBAAAAA==.',['拉普']='拉普兰德:BAABKgAFFH8SAAMRAAYI1BphDwBtAQARAAYIRxhhDwBtAQAJAAYIxxM1FgBFAQABKgAFFAgIEwAJAOUdAA==.',['拾捌']='拾捌度半:BAAAKgAECgQIBQAAAA==.',['持续']='持续混吃等死:BAAAKgAECggIEwAAAA==.',['放开']='放开娜:BAAAKgADCgEIAQAAAA==.',['敏感']='敏感:BAAAKgAECgYIEAAAAA==.',['文文']='文文卫:BAABKgAFFH8IAAIJAAQI1ghxJADDAAAJAAQI1ghxJADDAAAAAA==.',['斯莱']='斯莱特林:BAAAKgADCgIIAgAAAA==.',['无敌']='无敌小小刀:BAABKgAFFH8UAAMDAAgIExptAwAhAgADAAgIExptAwAhAgAFAAYIthOkDADwAAAAAA==.无敌少女丧彪:BAAAKgADCgEIAQAAAA==.无敌老雷:BAAAKgAFFAQIBAAAAA==.',['无辜']='无辜袭击安娜:BAAAKgADCggICAAAAA==.',['易想']='易想天开:BAAAKgADCgUIBQAAAA==.',['星光']='星光下的月夜:BAAAKgADCgMIAwAAAA==.',['星空']='星空飞雪:BAAAKgADCgEIAQAAAA==.',['是个']='是个法師:BAAAKgAECgIIAgAAAA==.',['晓好']='晓好比:BAAAKgADCgIIAwAAAA==.',['普利']='普利西亚:BAACKgAFFH8IAAIOAAgIBRfTBwA3AgAOAAgIBRfTBwA3AgAqAAQKfyIAAw4ACAhwG1NZAOwBAA4ACAhwG1NZAOwBAAoAAQjsA2lhAAgAAAAA.',['暁騎']='暁騎仕:BAAAKgAECgQIBAAAAA==.',['暗夜']='暗夜小精灵:BAAAKgADCggICAAAAA==.',['暗天']='暗天强强:BAABKgAFFH8SAAMEAAgIrA+sBwDOAQAEAAgIrA+sBwDOAQAPAAEIEwjFJgBCAAAAAA==.',['暗灬']='暗灬然:BAAAKgAECgEIAQAAAA==.',['曼音']='曼音天籁:BAABKgAFFH8RAAQIAAYIoRaCHgDbAAAIAAUIUhaCHgDbAAAHAAMI0A9mKgC5AAACAAQIahIaIgB7AAABKgAFFAgICwAOAKgUAA==.',['最后']='最后一只猫:BAACKgAFFH8pAAIaAAcInBjkBwDyAQAaAAcInBjkBwDyAQAqAAQKfx0AAhoACAhCHPEmAIMBABoACAhCHPEmAIMBAAAA.',['有我']='有我要冒火:BAAAKgADCgQIBAAAAA==.',['朔风']='朔风如解意:BAABKgAFFH8GAAIFAAYI1iK0BQDdAQAFAAYI1iK0BQDdAQAAAA==.',['末藍']='末藍星:BAAAKgAFFAEIAQAAAA==.',['本尼']='本尼迪塔斯:BAAAKgADCggICAAAAA==.',['杀戮']='杀戮:BAAAKgAECgUICwAAAA==.',['李二']='李二丫:BAABKgAECn8fAAIOAAgI9RSfYACeAQAOAAgI9RSfYACeAQAAAA==.',['来杯']='来杯曾珠奶茶:BAAAKgAECgYICwAAAA==.',['林暗']='林暗草惊:BAABKgAFFH8IAAIeAAgIuwlgAQDTAQAeAAgIuwlgAQDTAQAAAA==.',['柒染']='柒染丶:BAABKgAECn8WAAIRAAgIRyB/FQBMAgARAAgIRyB/FQBMAgAAAA==.',['染红']='染红装:BAAAKgADCggICAAAAA==.',['柠檬']='柠檬多多:BAABKgAECn98AAIcAAgImibPAAAUAwAcAAgImibPAAAUAwAAAA==.',['柯豆']='柯豆:BAAAKgADCggICAAAAA==.',['梦回']='梦回苍莽:BAAAKgAECgIIAgAAAA==.',['椎名']='椎名立希:BAABKgAFFH8IAAIfAAgI2BvzBABzAgAfAAgI2BvzBABzAgAAAA==.',['樄图']='樄图图:BAAAKgADCggICAAAAA==.',['樱桃']='樱桃肥肥子:BAAAKgAECgQIBAAAAA==.',['橙宝']='橙宝石兽:BAAAKgAECgEIAQAAAA==.',['此子']='此子斷不可留:BAABKgAECn8fAAQMAAgIaRBNQQBtAQAMAAgIiw9NQQBtAQAQAAQInww8IADBAAALAAcIuAdqNgCtAAAAAA==.',['死夜']='死夜影:BAAAKgAECgQIBAAAAA==.',['死神']='死神永生:BAAAKgADCggICAAAAA==.死神的学徒:BAAAKgAFFAgIBAAAAA==.',['殇丨']='殇丨煽情:BAAAKgAECgIIAgAAAA==.',['段誉']='段誉:BAACKgAFFH8SAAMgAAYIWxvRBAApAQAgAAUIgRrRBAApAQATAAUIyxwnDQD3AAAqAAQKfxgAAhMACAgOG5weAAwCABMACAgOG5weAAwCAAAA.',['毛毛']='毛毛帽猫:BAAAKgADCggICAAAAA==.',['汀铃']='汀铃铛汀:BAAAKgAECggICAABKgAFFAgIDQAhAPsXAA==.',['江橙']='江橙:BAABKgAECn8aAAIOAAgIGBZjYADbAQAOAAgIGBZjYADbAQAAAA==.',['没有']='没有道德:BAAAKgAECgEIAQAAAA==.',['泊书']='泊书薄:BAAAKgADCgUIBQAAAA==.',['泼猴']='泼猴:BAAAKgAFFAcIAwAAAA==.',['洋哥']='洋哥:BAACKgAFFH8QAAMiAAgIoQQ+AwBGAQAiAAgIvgM+AwBGAQAjAAIIYgriFwB2AAAqAAQKfygAAyMACAg7G/4iAMcBACMACAg7G/4iAMcBACIACAh1DpARACUBAAAA.',['浅海']='浅海深蓝:BAAAKgAECgYIBwAAAA==.',['浮生']='浮生若梦:BAAAKgAFFAIIBAAAAA==.',['深兰']='深兰姐姐:BAAAKgAECgQIBAAAAA==.',['清如']='清如许:BAAAKgAECggIDgAAAA==.',['清明']='清明压星河:BAAAKgAECggICAAAAA==.',['清锋']='清锋:BAABKgAECn8vAAMCAAgIdSS4BQDQAgACAAcIZCS4BQDQAgAHAAcIgh6HIQDpAQAAAA==.',['游泳']='游泳的蝌蚪:BAABKgAFFH8gAAIQAAQI/w8KCgDKAAAQAAQI/w8KCgDKAAAAAA==.',['游离']='游离海岸线:BAAAKgAECggICAAAAA==.',['灌男']='灌男高手灬:BAAAKgAECggICAAAAA==.',['灬兇']='灬兇弚情灬:BAAAKgAECgUIBQAAAA==.',['灬摄']='灬摄扌座灬:BAAAKgAECgUIBQAAAA==.',['灬筱']='灬筱墨:BAAAKgAECgEIAQAAAA==.',['烷基']='烷基多酚:BAAAKgAECgEIAQAAAA==.',['無龍']='無龍茶:BAAAKgADCgYIBgAAAA==.',['熊悟']='熊悟空旳焽:BAAAKgAECgMIBQAAAA==.',['燃烧']='燃烧:BAAAKgAECgQIBQAAAA==.',['爱小']='爱小榆:BAABKgAECn8dAAMJAAgISRjhTQDJAQAJAAgImxbhTQDJAQARAAYIBRRQHQAxAQAAAA==.',['牛奶']='牛奶哥哥:BAAAKgAECgMIAwAAAA==.',['特雷']='特雷依祺:BAAAKgAFFAgIAgAAAA==.',['独幕']='独幕周:BAAAKgAECggIDAAAAA==.',['猛爪']='猛爪:BAAAKgAECggIEgAAAA==.',['猴奈']='猴奈我何:BAAAKgAECgYIBwAAAA==.',['王奶']='王奶娘:BAABKgAECn8VAAQDAAgISB9CDQBlAgADAAgISB9CDQBlAgAUAAUIkxtyKQA/AQAFAAEIBBdYdgBCAAAAAA==.',['王沐']='王沐:BAAAKgAECgcICAAAAA==.',['王牛']='王牛:BAABKgAECn9mAAIOAAgIzCa+AQAfAwAOAAgIzCa+AQAfAwABKgAECggIaQAYAB0mAA==.',['王甲']='王甲:BAABKgAECn8nAAIOAAgIRCVSBwD7AgAOAAgIRCVSBwD7AgAAAA==.',['王莹']='王莹:BAABKgAECn8aAAIeAAgIih/qBQAIAgAeAAgIih/qBQAIAgAAAA==.',['王走']='王走:BAABKgAECn8aAAIOAAgIvyXTAQAPAwAOAAgIvyXTAQAPAwABKgAECggIaQAYAB0mAA==.',['玫瑰']='玫瑰蔷薇:BAAAKgADCgMIAwAAAA==.',['琉风']='琉风:BAAAKgAECgYICwAAAA==.琉风夜语:BAAAKgADCgUIBQAAAA==.',['瑞克']='瑞克迪尔:BAAAKgAECgQIBAAAAA==.',['生活']='生活大爆炸:BAAAKgAECgYIAgAAAA==.',['生而']='生而平凡:BAAAKgADCggICgAAAA==.',['电眼']='电眼妹妹:BAAAKgAECgUICAAAAA==.电眼姐姐:BAAAKgAECgYIBgAAAA==.',['疯狂']='疯狂小萝莉:BAAAKgAECgUIBgAAAA==.疯狂的豆沙包:BAAAKgAECggIEAAAAA==.',['白夜']='白夜:BAAAKgADCggICAAAAA==.',['皓月']='皓月当空:BAAAKgADCgUIBQAAAA==.',['看不']='看不到我:BAAAKgAECgQIBAAAAA==.',['看怪']='看怪别看我:BAABKgAFFH8KAAMLAAYIiBwvCwBeAQALAAYIRRovCwBeAQAQAAQIKhqSCQDWAAAAAA==.',['真的']='真的找不到路:BAAAKgADCgEIAQAAAA==.',['短发']='短发梁咏琪:BAAAKgADCggIDgAAAA==.',['祖吼']='祖吼:BAAAKgAECgQIBAAAAA==.',['祭天']='祭天拜地咒汝:BAAAKgADCgEIAQAAAA==.',['秦枫']='秦枫:BAAAKgAECggICAAAAA==.',['稳如']='稳如老狗:BAAAKgAECgEIAQAAAA==.',['紫陌']='紫陌:BAAAKgAFFAQIBAAAAA==.',['纳兰']='纳兰风:BAABKgAFFH8IAAIEAAQIVx7jGACvAAAEAAQIVx7jGACvAAAAAA==.',['绝地']='绝地魔法:BAAAKgADCgIIAgAAAA==.',['绝恋']='绝恋魔鬼:BAAAKgAECgEIAQAAAA==.',['继殁']='继殁归来:BAAAKgAFFAMIAwAAAA==.',['维拉']='维拉:BAAAKgAECgEIAQAAAA==.',['缘妙']='缘妙不可言:BAACKgAFFH8aAAIOAAMIMxHwJwDIAAAOAAMIMxHwJwDIAAAqAAQKfy8AAg4ACAhhHfc2AEoCAA4ACAhhHfc2AEoCAAAA.',['罴人']='罴人:BAABKgAECn8fAAQLAAgIRgowNAC5AAAMAAcILgjWdQC8AAALAAgIIAYwNAC5AAAQAAUIPQqMLABiAAAAAA==.',['羊肉']='羊肉糊汤面丶:BAAAKgADCgIIAgAAAA==.',['羟基']='羟基多酚:BAAAKgADCggICgAAAA==.',['群峰']='群峰之上:BAAAKgAFFAcIBAAAAA==.',['耀骑']='耀骑士临光:BAAAKgAECggIBgAAAA==.',['联盟']='联盟小德:BAAAKgAECgMIAwAAAA==.',['背叛']='背叛了:BAAAKgADCgIIAgAAAA==.',['自由']='自由与风:BAAAKgADCgYIBgAAAA==.自由的乐乐:BAAAKgAECgQIBAAAAA==.自由的皮卡丘:BAAAKgADCgEIAQAAAA==.',['舞雩']='舞雩:BAABKgAECn8XAAMUAAgIhxEEKQCPAQAUAAgIhxEEKQCPAQADAAYILwu4WwDOAAAAAA==.',['航空']='航空报国:BAACKgAFFH8TAAMJAAcIyhS3FQBIAQAJAAQI5he3FQBIAQARAAMIoxBxMACtAAAqAAQKfxoAAhEACAiRG8oUACoCABEACAiRG8oUACoCAAAA.',['艾格']='艾格玟:BAABKgAFFH8FAAICAAMIBw0bDADCAAACAAMIBw0bDADCAAAAAA==.',['艾莎']='艾莎莉蕥:BAAAKgAECgYIBgAAAA==.',['苏毅']='苏毅:BAAAKgADCgYIBgAAAA==.',['苏潇']='苏潇:BAAAKgAFFAgIAgAAAA==.',['苯日']='苯日:BAAAKgADCgEIAQAAAA==.',['苹果']='苹果大树:BAAAKgAECgUIBwAAAA==.',['荧荧']='荧荧:BAAAKgAFFAIIBAAAAA==.荧荧丶:BAAAKgAFFAIIAgAAAA==.荧荧小满:BAAAKgAFFAEIAQAAAA==.荧荧小贝:BAABKgAFFH8HAAIXAAYIjxj2CQAVAQAXAAYIjxj2CQAVAQAAAA==.',['荷妹']='荷妹:BAAAKgAECgYIBgAAAA==.荷妹二号:BAAAKgAECgQICQAAAA==.',['莴笋']='莴笋开大了:BAAAKgAECgQIBAABKgAFFAgIBAABAAAAAA==.',['萝卜']='萝卜开大了:BAAAKgAFFAMIAwAAAA==.',['萧火']='萧火火:BAAAKgADCggICAAAAA==.',['萧风']='萧风:BAAAKgAECgYIBgAAAA==.',['蓝辉']='蓝辉若有意:BAAAKgAECgQIBAAAAA==.',['虚空']='虚空的行者:BAAAKgAECgIIAgAAAA==.',['蛋白']='蛋白质的忧伤:BAAAKgAECgMIAwAAAA==.',['蝶翼']='蝶翼婉儿:BAABKgAFFH8LAAIFAAgILQxWBACxAQAFAAgILQxWBACxAQAAAA==.',['血大']='血大苗:BAAAKgAFFAQIBAAAAA==.',['血腥']='血腥币啦啦:BAAAKgAECggIEgAAAA==.',['被杀']='被杀狂:BAAAKgADCggIFAAAAA==.',['被逼']='被逼着:BAAAKgAECggICAAAAA==.',['西冲']='西冲巨雕游侠:BAAAKgADCgIIAgAAAA==.',['西西']='西西妹:BAAAKgAFFAMIAwAAAA==.',['誋悥']='誋悥灬雪:BAAAKgAFFAMIAwAAAA==.',['謎鸦']='謎鸦:BAAAKgAECgYIDAAAAA==.',['谷德']='谷德茂宁:BAABKgAFFH8MAAIRAAgI6RnuBQAQAgARAAgI6RnuBQAQAgAAAA==.',['豆腐']='豆腐脑两掺丶:BAACKgAFFH8SAAMhAAgIGx3VAQCcAQAhAAYIbR3VAQCcAQATAAcIMRb6JQDbAAAqAAQKfxYAAxMABwj9HSorAG0BABMABggDHiorAG0BACAAAwjnFn1KALsAAAAA.',['豌豆']='豌豆芽:BAABKgAECn9WAAINAAgI1CV1AwABAwANAAgI1CV1AwABAwABKgAFFAYIBgANAOkUAA==.',['贺驿']='贺驿:BAAAKgADCgcIBwAAAA==.',['赛纳']='赛纳流思:BAAAKgAECgIIBAAAAA==.',['赤也']='赤也:BAABKgAFFH8GAAIfAAYIqAmnGwAiAQAfAAYIqAmnGwAiAQAAAA==.',['转身']='转身碰到頭:BAAAKgAECgYIBgAAAA==.',['辣鸡']='辣鸡玻璃渣:BAAAKgADCgQIBAAAAA==.',['迪妮']='迪妮莎丶挽歌:BAAAKgAECgQIBAAAAA==.',['逝去']='逝去的爱恋:BAABKgAFFH8GAAIFAAYIHRWvCgBrAQAFAAYIHRWvCgBrAQAAAA==.',['逢山']='逢山鬼泣:BAABKgAFFH8IAAIZAAgIthNcAgBRAgAZAAgIthNcAgBRAgAAAA==.',['逼脸']='逼脸壹刀:BAABKgAFFH8JAAIfAAgIPQzCCQDeAQAfAAgIPQzCCQDeAQAAAA==.',['酱油']='酱油嚓:BAAAKgAECgcIDgAAAA==.',['钕大']='钕大十八变:BAAAKgAECgEIAQAAAA==.',['银瞳']='银瞳克蕾雅:BAABKgAFFH8KAAIOAAYIhhYaAgDHAQAOAAYIhhYaAgDHAQAAAA==.',['长崎']='长崎素食:BAABKgAFFH8MAAITAAgIARqwBABWAgATAAgIARqwBABWAgAAAA==.',['闖禍']='闖禍的阿淼:BAAAKgADCgEIAQAAAA==.',['闪烁']='闪烁:BAAAKgAECggIEAAAAA==.',['问题']='问题不大:BAAAKgAECgYIBgAAAA==.',['阡墨']='阡墨:BAAAKgAFFAQIBAAAAA==.',['陈糊']='陈糊涂:BAAAKgADCgIIAgAAAA==.',['随欲']='随欲而鵪:BAAAKgADCggICAAAAA==.',['难在']='难在得失:BAABKgAFFH8MAAINAAYIMCE9CwDhAQANAAYIMCE9CwDhAQAAAA==.',['零度']='零度萌萌哒:BAABKgAFFH8MAAIIAAUIHiE+BgCgAQAIAAUIHiE+BgCgAQAAAA==.',['霍格']='霍格:BAAAKgAECgQIBAAAAA==.',['霜斧']='霜斧:BAAAKgAFFAcIBAAAAA==.',['靇霛']='靇霛霣霄:BAAAKgAFFAQIBAAAAA==.',['靇靈']='靇靈雲霄:BAABKgAFFH8IAAICAAQIyBywCADoAAACAAQIyBywCADoAAAAAA==.',['面包']='面包机:BAAAKgAECgEIAQAAAA==.',['颓废']='颓废是种心情:BAABKgAFFH8GAAILAAYIaQ9TEwAHAQALAAYIaQ9TEwAHAQAAAA==.',['风之']='风之行者:BAAAKgAECggIDwAAAA==.',['风梳']='风梳烟沐:BAAAKgAECgIIAgAAAA==.',['风清']='风清:BAAAKgAECgYIBgAAAA==.',['飓嘿']='飓嘿丨:BAABKgAFFH8fAAQOAAcIvSMGBQCDAgAOAAcIvSMGBQCDAgAKAAYIChi7CwA8AQAkAAEInQrEGwBGAAAAAA==.飓嘿丿:BAAAKgAECgYIBgAAAA==.',['饭碗']='饭碗:BAAAKgAECgMIAwAAAA==.',['骑你']='骑你头上:BAAAKgADCggICwAAAA==.',['骑士']='骑士:BAAAKgAECgUIBQAAAA==.',['高冷']='高冷荷妹:BAAAKgADCggICAAAAA==.',['鬼迷']='鬼迷星窍:BAABKgAECn8XAAQTAAgIdhw7PAB7AQATAAUITRo7PAB7AQAhAAMIyRv4IQDjAAAgAAMIrR22VgCTAAAAAA==.',['魑魅']='魑魅罔两:BAAAKgAECgcIDAAAAA==.魑魅迷惘:BAABKgAECn8eAAIJAAgI/hZhQAClAQAJAAgI/hZhQAClAQAAAA==.',['魔法']='魔法大苗:BAAAKgADCgcIBwAAAA==.',['魔魔']='魔魔的小眉毛:BAAAKgAECggIDwAAAA==.',['鱼子']='鱼子酱睡不饱:BAABKgAFFH8JAAMdAAYI7wTGCQCvAAAdAAYI4gLGCQCvAAAfAAMIugcZRQBoAAAAAA==.',['鸾落']='鸾落音尘:BAAAKgAFFAIIAgAAAA==.',['鹤灬']='鹤灬僧:BAABKgAFFH8XAAMjAAUIiAiRFQC7AAAjAAQIiAiRFQC7AAAXAAUIwQaPJwCEAAAAAA==.',['麻三']='麻三豆:BAAAKgAECggIDwAAAA==.',['黄桃']='黄桃安慕希:BAAAKgAFFAQIBAAAAA==.',['黑夜']='黑夜的流影:BAAAKgAECggICQAAAA==.',['黑百']='黑百合:BAAAKgAECggICAAAAA==.',['黑魔']='黑魔:BAAAKgAECgMIBQAAAA==.',['龍霄']='龍霄九淵:BAAAKgAECggIDgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end