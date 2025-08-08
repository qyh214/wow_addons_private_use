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
 local lookup = {'Paladin-Holy','Mage-Arcane','Warlock-Destruction','Druid-Restoration','Druid-Feral','Druid-Balance','Druid-Guardian','Paladin-Retribution','Mage-Fire','Mage-Frost','Shaman-Restoration','DemonHunter-Havoc','Hunter-BeastMastery','Priest-Holy','Hunter-Marksmanship','DemonHunter-Vengeance','Warrior-Fury','Warrior-Arms','Warlock-Affliction','DeathKnight-Frost','Shaman-Elemental','Rogue-Subtlety','Rogue-Assassination','Monk-Brewmaster','Monk-Windwalker','Shaman-Enhancement','Monk-Mistweaver','Warlock-Demonology','Evoker-Preservation','Paladin-Protection','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection','Unknown-Unknown','Priest-Discipline','Priest-Shadow',}; local provider = {region='CN',realm='德拉诺',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alita:BAACKgAFFH8eAAIBAAQIyxhaDADmAAABAAQIyxhaDADmAAAqAAQKf1IAAgEACAj6HYQKAEcCAAEACAj6HYQKAEcCAAAA.',Am='Ametharan:BAAAKgADCgcIBwAAAA==.',An='Annestibbers:BAABKgAFFH8KAAICAAgImQkMCgDFAQACAAgImQkMCgDFAQAAAA==.',Ap='Aphrodite:BAABKgAECn8YAAIDAAgI9Rh/CQAHAgADAAgI9Rh/CQAHAgAAAA==.',Ar='Arcticblaze:BAAAKgAECgIIAgAAAA==.Areslothar:BAAAKgADCggICAAAAA==.Artemis:BAAAKgAFFAYIBAAAAA==.',As='Astraia:BAAAKgAECgEIAQAAAA==.',Br='Breezepoet:BAAAKgAECgYICwAAAA==.',Ca='Carlbing:BAAAKgAFFAQIBAAAAA==.',Ch='Chaeles:BAAAKgAECgQICAAAAA==.',Co='Cool:BAAAKgAECggICAAAAA==.',Da='Darknessun:BAABKgAFFH8IAAIEAAgIOAtIBwCcAQAEAAgIOAtIBwCcAQAAAA==.Daylight:BAAAKgADCgcIBwAAAA==.',De='Death:BAAAKgADCgEIAgAAAA==.Demeter:BAACKgAFFH8kAAQFAAQIrhs6BQDtAAAFAAMIrhs6BQDtAAAEAAQI/xxHCwDaAAAGAAQIwQvwPQCxAAAqAAQKf0kABQUACAhyJH4DALQCAAUACAhyJH4DALQCAAcACAhHHvQCAFgCAAYABQjuFjhYAFMBAAQABAhUHdkrAE4BAAAA.Desirer:BAAAKgAFFAQIBAAAAA==.',Er='Ereshkigal:BAAAKgADCgIIAwAAAA==.',Fs='Fses:BAAAKgADCggICAAAAA==.',Gg='Ggk:BAAAKgAECgEIAQAAAA==.Ggx:BAAAKgADCggICAAAAA==.',Go='Goffy:BAACKgAFFH8SAAIIAAMIOxuvSgDZAAAIAAMIOxuvSgDZAAAqAAQKfxQAAggABwjxG4NxAHIBAAgABwjxG4NxAHIBAAAA.Gogo:BAABKgAECn8eAAMJAAgImBkPLgDoAQAJAAgIexkPLgDoAQAKAAcI5BEsSwA4AQABKgAFFAgIGAACAOchAA==.',Ha='Happyzhou:BAAAKgAECgYIBgAAAA==.',He='Hedy:BAAAKgADCgIIAwAAAA==.Heuhu:BAAAKgAFFAIIAgAAAA==.',Ho='Hotjunior:BAAAKgAECgYICAAAAA==.',Hu='Hurricane:BAAAKgADCgUIBQAAAA==.',Ja='Jashdija:BAAAKgAECggICAAAAA==.',Ki='Kivsouler:BAAAKgAFFAIIAgAAAA==.',Ku='Kurokyà:BAAAKgAECgYIBgAAAA==.',Le='Lee:BAABKgAFFH8NAAILAAcI1Qp5IgDuAAALAAcI1Qp5IgDuAAAAAA==.',Li='Lieoo:BAAAKgAFFAEIAQAAAA==.',Mi='Mic:BAAAKgAECgQIBAAAAA==.Miria:BAABKgAFFH8PAAIIAAYI5iKEDAAEAgAIAAYI5iKEDAAEAgAAAA==.',Mo='Moonvirgo:BAACKgAFFH8OAAMIAAMI1hSPTADWAAAIAAMI1hSPTADWAAABAAMIqBKLDwDFAAAqAAQKfxgAAwEABggLFYIlADMBAAEABggLFYIlADMBAAgABQhiEPzzAIEAAAAA.',Mu='Mumus:BAAAKgAECgEIAQAAAA==.Murderous:BAACKgAFFH8VAAIIAAMISAqmXwCxAAAIAAMISAqmXwCxAAAqAAQKfyIAAggACAhGGchBAPwBAAgACAhGGchBAPwBAAAA.',Na='Nattensengel:BAABKgAFFH8GAAIMAAYI2QLOFQDdAAAMAAYI2QLOFQDdAAAAAA==.',Ni='Niubi:BAAAKgAFFAQIBAABKgAFFAgICAAIAC8jAA==.',Pl='Playernwpixd:BAAAKgAECgYICAAAAA==.',Re='Remousse:BAAAKgADCgEIAQAAAA==.',Sa='Sabrinalee:BAABKgAECn8jAAILAAgI3RfFOACSAQALAAgI3RfFOACSAQAAAA==.Sarahkerrig:BAAAKgAECgYIBgAAAA==.',Sh='Shutdownboss:BAAAKgAECgUIBQAAAA==.',St='Stardust:BAAAKgADCgcIBwAAAA==.Stella:BAABKgAFFH8GAAIMAAYIRhsMEACGAQAMAAYIRhsMEACGAQAAAA==.Stinkypig:BAAAKgAECgUIBQAAAA==.',To='Tonystark:BAAAKgAFFAgIBAAAAA==.',Tr='Trinety:BAAAKgAECgMIBQAAAA==.',Uz='Uzi:BAAAKgAECgIIAgAAAA==.',Vo='Vol:BAABKgAFFH8GAAMCAAUI8AwwMwCWAAAJAAQIxQbOIwCaAAACAAII1xQwMwCWAAABKgAFFAgIEAANAKobAA==.',Yy='Yyfs:BAAAKgAECggICQAAAA==.Yyll:BAABKgAECn8XAAIIAAgInBzFRgAcAgAIAAgInBzFRgAcAgAAAA==.Yyxx:BAABKgAFFH8HAAIOAAMIjw1JGAB+AAAOAAMIjw1JGAB+AAAAAA==.',['一个']='一个裂人:BAAAKgADCgQIBAAAAA==.',['一介']='一介武夫:BAAAKgADCgUIBQAAAA==.',['一条']='一条小青龙:BAAAKgADCggICAAAAA==.',['一枪']='一枪承诺:BAABKgAFFH8IAAIPAAgIwgrjCAChAQAPAAgIwgrjCAChAQAAAA==.',['万物']='万物不仁:BAAAKgAECgEIAQAAAA==.万物复苏:BAAAKgAECgIIAgAAAA==.',['三三']='三三:BAAAKgADCgIIAgAAAA==.',['三指']='三指:BAAAKgAECgUIBQAAAA==.',['上房']='上房揭瓦囖:BAABKgAFFH8IAAIIAAgIkAcjDwCwAQAIAAgIkAcjDwCwAQAAAA==.',['不要']='不要死小强:BAAAKgAECgYIEwAAAA==.',['且行']='且行且珍重:BAAAKgADCgMIAwAAAA==.',['东熊']='东熊夏咕:BAAAKgAECgUIBQAAAA==.',['丨凸']='丨凸凸丨:BAAAKgADCgEIAQAAAA==.',['丨小']='丨小地痞丨:BAAAKgAECgMIAwAAAA==.丨小浣熊丨:BAAAKgAECgMIAwAAAA==.',['丨蛤']='丨蛤啤丨:BAAAKgAECgcICwAAAA==.',['丨雷']='丨雷三炮丨:BAAAKgAECgcIDgAAAA==.',['中泰']='中泰百货第一:BAAAKgAFFAQIBAAAAA==.',['丶侵']='丶侵略如火丶:BAAAKgADCgIIAgAAAA==.',['丶红']='丶红烧茄子:BAABKgAFFH8GAAIIAAYInxB5JABZAQAIAAYInxB5JABZAQAAAA==.',['丶聚']='丶聚散流沙:BAAAKgADCgEIAQAAAA==.',['丶释']='丶释迦:BAABKgAFFH8FAAIQAAIIKxhbGQCDAAAQAAIIKxhbGQCDAAAAAA==.',['丶青']='丶青青子衿丶:BAABKgAECn8iAAMRAAgI3B7BEQBOAgARAAgI3B7BEQBOAgASAAEIIBjrVwBIAAAAAA==.',['为你']='为你熬翔:BAABKgAFFH8MAAMDAAgI0CL6AwBNAgADAAgIZBn6AwBNAgATAAQIBSRmBQAuAQAAAA==.',['久久']='久久炎:BAAAKgAECggICwAAAA==.',['乐居']='乐居:BAAAKgAECgYIBwAAAA==.',['乔瑟']='乔瑟夫乔斯达:BAABKgAFFH8QAAIMAAgIQRtIBgBHAgAMAAgIQRtIBgBHAgAAAA==.',['九五']='九五:BAABKgAFFH8IAAIUAAQIgBuxAgD4AAAUAAQIgBuxAgD4AAAAAA==.',['乱世']='乱世枭雄:BAAAKgADCggICAAAAA==.',['二蛋']='二蛋的拳头:BAAAKgAFFAQIBAAAAA==.二蛋的腹肌:BAAAKgAECgMIAwAAAA==.',['云中']='云中谁忆:BAAAKgAFFAIIBAAAAA==.',['云止']='云止水中:BAAAKgADCgMIAwAAAA==.',['人中']='人中灬吕布:BAAAKgAECgcIDwAAAA==.',['人品']='人品有问题:BAAAKgAECgcIBwAAAA==.',['人定']='人定胜天:BAAAKgADCgUIBQAAAA==.',['人就']='人就是剑:BAABKgAFFH8GAAISAAYIjRSYCQByAQASAAYIjRSYCQByAQAAAA==.',['人造']='人造熊猫:BAAAKgADCgcIBwAAAA==.',['今天']='今天不插棍儿:BAABKgAECn8UAAMLAAgI8xJiWAAiAQALAAgI8xJiWAAiAQAVAAIIVgiTaABdAAAAAA==.',['仓井']='仓井满:BAABKgAECn8gAAIHAAgIHxdVDwCyAQAHAAgIHxdVDwCyAQAAAA==.',['伊瑞']='伊瑞尔灬主教:BAAAKgAECggIEAAAAA==.',['优菈']='优菈:BAAAKgAECgIIBAAAAA==.',['传承']='传承:BAAAKgAFFAQIBAAAAA==.',['伽喱']='伽喱:BAABKgAECn8XAAMPAAgIMBTlNgB+AQAPAAgI+BHlNgB+AQANAAYIIhMSLAAgAQAAAA==.',['何许']='何许人丶:BAABKgAFFH8IAAIIAAgIAwqgDQDIAQAIAAgIAwqgDQDIAQAAAA==.',['你没']='你没钱:BAAAKgAECgIIAwAAAA==.',['你的']='你的小龙女:BAAAKgAECgIIAgAAAA==.你的德:BAAAKgAFFAEIAQAAAA==.',['佩佩']='佩佩的小刀:BAABKgAFFH8FAAMWAAUI9A+XBwDyAAAWAAQIbBGXBwDyAAAXAAEIjAuoKABJAAAAAA==.',['侠骨']='侠骨丹心:BAAAKgAECgUIBQAAAA==.',['倚剑']='倚剑挽流沙:BAABKgAFFH8QAAMTAAUIqRxVCQCoAAADAAQIESCGJgDYAAATAAMIvxVVCQCoAAAAAA==.',['偶豆']='偶豆豆喲:BAAAKgAECgUICgAAAA==.',['傍晚']='傍晚:BAAAKgAECgUICgAAAA==.',['傲慢']='傲慢骑骑:BAAAKgADCggICAAAAA==.',['僧龍']='僧龍大俠:BAABKgAECn8bAAMYAAgIKg4PEQAtAQAYAAgIKg4PEQAtAQAZAAEILQo1dwA2AAAAAA==.',['元素']='元素萨满:BAAAKgADCgEIAgAAAA==.',['先定']='先定个小目标:BAABKgAFFH8VAAMQAAYIfRTJAABgAQAQAAYIfRTJAABgAQAMAAEIyQLGTgAoAAAAAA==.',['光头']='光头的荣耀:BAAAKgAFFAEIAQAAAA==.',['光的']='光的信仰:BAAAKgADCggIEAAAAA==.',['关你']='关你西红柿:BAAAKgADCgIIAgAAAA==.关你西虹柿:BAAAKgADCggIDAAAAA==.',['兽闪']='兽闪电:BAAAKgADCgQIBAAAAA==.',['冰凉']='冰凉丶:BAACKgAFFH8GAAIRAAIIYRu/JwCsAAARAAIIYRu/JwCsAAAqAAQKfxYAAhEABwgSHpIeAN4BABEABwgSHpIeAN4BAAAA.',['冰封']='冰封长安:BAAAKgADCggIAwAAAA==.',['冰欣']='冰欣:BAAAKgADCgIIAgAAAA==.',['冰河']='冰河葬寒心:BAAAKgAECgQIBAAAAA==.',['冰粒']='冰粒十足:BAAAKgAFFAIIAgAAAA==.',['冰糖']='冰糖葫芦娃:BAAAKgADCgYIBgAAAA==.',['冻蹄']='冻蹄子:BAAAKgAFFAIIAgAAAA==.',['凄凄']='凄凄巳时酒:BAABKgAFFH8GAAIaAAYIwBdXBwBwAQAaAAYIwBdXBwBwAQAAAA==.',['凌月']='凌月飞星:BAAAKgADCgEIAQAAAA==.',['凝渊']='凝渊羡鱼:BAAAKgADCgEIAQAAAA==.',['凝香']='凝香筱筱:BAABKgAFFH8OAAIbAAMI2xZBHgCvAAAbAAMI2xZBHgCvAAAAAA==.',['凤弓']='凤弓羽箭:BAABKgAFFH8KAAMNAAYItBfUDwB8AQANAAYItBfUDwB8AQAPAAQIZQZ7FQC2AAAAAA==.',['凵墨']='凵墨丘利凵:BAAAKgADCgEIAQAAAA==.',['凸惡']='凸惡魔獵手凸:BAAAKgADCgEIAQAAAA==.',['别打']='别打那萨满:BAAAKgAECgUICwAAAA==.',['别碰']='别碰我的豆奶:BAABKgAFFH8KAAMDAAgIjhyiDQCyAQADAAYI/xqiDQCyAQAcAAII6iU2DgBxAAAAAA==.',['前女']='前女友:BAAAKgAFFAYIBAAAAA==.',['勿怂']='勿怂从心怂勿:BAAAKgAFFAQIBAAAAA==.',['北辰']='北辰明:BAAAKgAFFAQIBAAAAA==.',['半夕']='半夕丶烟雨:BAAAKgADCggICAAAAA==.',['卓老']='卓老师:BAAAKgAECgcIDQAAAA==.',['卡加']='卡加:BAAAKgAECggICgAAAA==.',['原因']='原因未知:BAAAKgADCggIDgAAAA==.',['双刀']='双刀狼:BAAAKgADCgQIBAAAAA==.',['古怪']='古怪精:BAAAKgAECgcICQAAAA==.',['台风']='台风眼:BAAAKgAFFAQIAQAAAA==.',['史诗']='史诗之袜:BAAAKgAECgQIBwAAAA==.',['右转']='右转:BAAAKgADCgYIBgAAAA==.',['叽叽']='叽叽咕咕哒:BAAAKgAFFAYIBAAAAA==.',['吟冰']='吟冰火凤:BAAAKgAECgcIDAAAAA==.',['听到']='听到打一:BAAAKgADCggICAABKgAFFAgIGwAdAKQeAA==.',['听说']='听说奶萨很强:BAAAKgAECgcICgAAAA==.',['吼少']='吼少俠:BAAAKgAECgIIAgAAAA==.',['咆哮']='咆哮的鹌鹑:BAABKgAECn8kAAMGAAgIXCCUKwACAgAGAAgIXCCUKwACAgAHAAEIAgtjNgAdAAABKgAFFAgIUAAGABcmAA==.',['咕咕']='咕咕糖:BAAAKgAFFAQIBAAAAA==.',['哈利']='哈利波特别尛:BAAAKgAECgMIAwAAAA==.',['哈妮']='哈妮克孜:BAAAKgADCgEIAQAAAA==.',['哈库']='哈库纳玛塔塔:BAAAKgADCggICAAAAA==.',['哥来']='哥来摸妮之手:BAAAKgADCgEIAQAAAA==.',['唐丶']='唐丶吉坷德:BAACKgAFFH8WAAMeAAgIigjXBwBCAQAeAAgIigjXBwBCAQABAAIIYgdQEQB2AAAqAAQKfyAAAwEACAhHG5APAAYCAAEACAhHG5APAAYCAAgACAgGGIlbAOcBAAAA.',['啊咧']='啊咧咧啊:BAAAKgADCgEIAgAAAA==.',['嗜血']='嗜血灬残阳:BAAAKgAECgEIAQAAAA==.',['噼里']='噼里啪啦:BAABKgAFFH8KAAIaAAYIvRzVBgB/AQAaAAYIvRzVBgB/AQAAAA==.',['四十']='四十多只猫:BAABKgAFFH8MAAMPAAYI0yI0DACUAQAPAAYIiB00DACUAQANAAYINB7IDwB9AQAAAA==.',['四夕']='四夕若若:BAABKgAFFH8KAAMfAAYI3SDGDwCgAQAfAAYI3SDGDwCgAQAgAAQIcRefHAC9AAABKgAFFAgIDgAfAEoXAA==.',['圆魄']='圆魄上寒空:BAAAKgAECggIEAAAAA==.',['圣丶']='圣丶加百列:BAAAKgADCggICQAAAA==.',['圣光']='圣光凤梨:BAAAKgAECgYIDAAAAA==.圣光天赐:BAAAKgAECgYICwAAAA==.圣光忽悠着尼:BAABKgAFFH8KAAIIAAYIvQpvVwDCAAAIAAYIvQpvVwDCAAAAAA==.圣光赐我男高:BAABKgAFFH8KAAIIAAYIHRjwAQDMAQAIAAYIHRjwAQDMAQAAAA==.',['圣手']='圣手织天:BAAAKgAECgIIBAAAAA==.',['圣斗']='圣斗士:BAABKgAECn8nAAMIAAgI/xwvNwAjAgAIAAgI/xwvNwAjAgAeAAEIVAE/ZAACAAAAAA==.',['圣斯']='圣斯特骑骑:BAAAKgAECgYICgAAAA==.',['埃辛']='埃辛诺斯戰刃:BAABKgAECn80AAIMAAgI8CDNFgB9AgAMAAgI8CDNFgB9AgAAAA==.',['墨染']='墨染流年:BAAAKgAECgMIBAAAAA==.',['墨殇']='墨殇:BAAAKgAECggIAQAAAA==.',['墮落']='墮落的騎士:BAABKgAECn8hAAMIAAgIcBosHQDUAQAIAAgIcBosHQDUAQAeAAEIRQ0RJAAqAAAAAA==.',['壹辈']='壹辈子丶嚯嚯:BAAAKgAECgIIAgAAAA==.',['夏末']='夏末浅笑:BAAAKgAECggICAAAAA==.',['夏灬']='夏灬寒:BAAAKgAECgMIBgAAAA==.',['夜月']='夜月杀:BAABKgAFFH8OAAIUAAgI1xqNAQB2AgAUAAgI1xqNAQB2AgAAAA==.',['大乃']='大乃:BAAAKgADCggICAAAAA==.',['大冰']='大冰:BAABKgAFFH8JAAIUAAMIshnmCADdAAAUAAMIshnmCADdAAAAAA==.',['大哥']='大哥我真抽了:BAAAKgAECgQIBAAAAA==.',['大嗡']='大嗡嗡:BAABKgAFFH8MAAMQAAYIghghBQBTAQAQAAYIdxchBQBTAQAMAAYIcw9FGQAzAQAAAA==.',['大春']='大春丽:BAAAKgAECgMIAwAAAA==.',['大毒']='大毒屮:BAAAKgADCgEIAQAAAA==.',['大猛']='大猛战丶:BAABKgAECn8WAAIRAAgIaBjWHgDcAQARAAgIaBjWHgDcAQAAAA==.',['大罗']='大罗洞观:BAAAKgAECgIIAgAAAA==.',['大闪']='大闪电:BAAAKgAECggIBQAAAA==.',['大领']='大领主提里奥:BAAAKgADCggICAAAAA==.',['大鱼']='大鱼破雾:BAAAKgAECgYICwAAAA==.',['天呐']='天呐丶:BAAAKgAECgMIAwAAAA==.',['天国']='天国狼声:BAAAKgAECgEIAQAAAA==.',['天野']='天野:BAABKgAFFH8GAAISAAYI8BgPCACLAQASAAYI8BgPCACLAQAAAA==.',['奋斗']='奋斗的人生:BAAAKgADCgMIAwAAAA==.奋斗终生:BAAAKgADCggICAAAAA==.',['奔腾']='奔腾狼:BAAAKgAECggICAAAAA==.',['奥花']='奥花飘飘:BAAAKgADCgQIBAAAAA==.',['奲戆']='奲戆斆斸旞旣:BAAAKgAECgIIAgAAAA==.',['女主']='女主角:BAAAKgAECgYIBwAAAA==.',['如果']='如果奶:BAAAKgAECgIIAgAAAA==.',['妖精']='妖精丶契约:BAAAKgADCgQIBAAAAA==.',['妹妹']='妹妹不高兴:BAABKgAECn8YAAIIAAgIEBqKZgCPAQAIAAgIEBqKZgCPAQAAAA==.',['媇你']='媇你小手:BAABKgAFFH8KAAMEAAYI3wc4FAD+AAAEAAYI3wc4FAD+AAAGAAQIUwHQLQB6AAAAAA==.',['嫣然']='嫣然一笑:BAAAKgAECgEIAQAAAA==.嫣然晨光:BAAAKgAECgQIBAAAAA==.嫣然暮光:BAAAKgAECggIDwAAAA==.',['孤芳']='孤芳自赏:BAAAKgAECgMIAwAAAA==.',['宅字']='宅字当头:BAAAKgAECgUIDAAAAA==.',['安其']='安其啦:BAAAKgADCgEIAQAAAA==.',['安妮']='安妮的小熊:BAAAKgAFFAEIAQAAAA==.',['宝贝']='宝贝叶子:BAAAKgAECgYIEgAAAA==.',['审判']='审判长:BAAAKgADCggICAAAAA==.',['宮下']='宮下玲奈:BAAAKgAFFAgIAgAAAA==.',['寂寞']='寂寞狆哋樱花:BAAAKgAECgMIAwAAAA==.',['封面']='封面人物膧:BAAAKgAECgEIAQAAAA==.',['小倒']='小倒霉蛋儿:BAABKgAFFH8GAAIIAAYIIh6dIABtAQAIAAYIIh6dIABtAQAAAA==.',['小小']='小小崽:BAAAKgAECggICgAAAA==.',['小屁']='小屁:BAABKgAFFH8MAAMhAAgIRhmdAQAaAgAhAAgIvBidAQAaAgASAAMIeRrXFQDWAAAAAA==.',['小崽']='小崽崽:BAAAKgAECgYIBwAAAA==.',['小张']='小张向前冲:BAABKgAFFH8BAAIbAAEI6QKeNQAnAAAbAAEI6QKeNQAnAAAAAA==.',['小德']='小德不晓得:BAAAKgAECgcIEgAAAA==.',['小樹']='小樹:BAAAKgADCggICAAAAA==.',['小气']='小气包:BAAAKgADCggICAAAAA==.',['小灬']='小灬二灬货灬:BAAAKgAECgIIAgAAAA==.',['小牛']='小牛儿冰凉:BAAAKgAECggICQAAAA==.小牛剑侠:BAAAKgAFFAQIBAAAAA==.小牛总冠军吖:BAAAKgADCggICAAAAA==.',['小聪']='小聪明闪电:BAAAKgAECgUIBQAAAA==.',['小虎']='小虎:BAAAKgAFFAMIAwAAAA==.',['小飞']='小飞机小火车:BAAAKgAECggIEAABKgAFFAgIAgAiAAAAAA==.',['尘缘']='尘缘梦中人:BAAAKgADCgIIAgAAAA==.',['尛酒']='尛酒窩:BAABKgAFFH8MAAICAAYIdyF9DACfAQACAAYIdyF9DACfAQABKgAFFAgIGAAMAOUfAA==.',['山里']='山里的二营长:BAABKgAFFH8MAAIIAAgI1RkrJgBQAQAIAAgI1RkrJgBQAQAAAA==.山里的嗦了扎:BAABKgAECn8gAAMjAAgIvhzLGADUAQAjAAgIExrLGADUAQAOAAcInBjLPgA/AQAAAA==.山里的圆圆:BAACKgAFFH8QAAMIAAMIfyPULwApAQAIAAMIfyPULwApAQABAAIIHxVKDQCDAAAqAAQKfx4AAggACAiPIqkZALECAAgACAiPIqkZALECAAAA.山里的尛伙:BAAAKgAECgcIBwAAAA==.山里的尛红人:BAACKgAFFH8OAAMNAAMIMBxkFQDjAAANAAMIMBxkFQDjAAAPAAEIAwgpUwA0AAAqAAQKfyEAAw0ACAgFJfgmAFcCAA0ACAgFJfgmAFcCAA8ABAjJHHNJAPcAAAAA.山里的拨楞牛:BAAAKgAECgYICAAAAA==.山里的法爺:BAAAKgAFFAgIBAAAAA==.山里的老僧:BAAAKgAECgUIBQAAAA==.山里的老登:BAABKgAFFH8GAAIfAAMIHB2UIwAHAQAfAAMIHB2UIwAHAQAAAA==.山里的酒腻子:BAAAKgAECgQIBAAAAA==.',['岸芷']='岸芷汀兰:BAABKgAFFH8NAAMOAAQIUBr1BgABAQAOAAMIUBr1BgABAQAjAAEIAACFLgAAAAAAAA==.',['岸边']='岸边的狮子:BAAAKgAFFAYIAgAAAA==.',['左转']='左转:BAAAKgAECgIIAgAAAA==.',['巧笑']='巧笑倩美目盼:BAAAKgAECggIEAAAAA==.',['希尔']='希尔梅里亚:BAABKgAECn8eAAIPAAgIbRTHSAAtAQAPAAgIbRTHSAAtAQAAAA==.',['帝獄']='帝獄孤狼:BAABKgAECn8YAAIfAAgIPhQKOACUAQAfAAgIPhQKOACUAQAAAA==.',['干一']='干一碗恒河水:BAAAKgADCggICwAAAA==.',['幽冥']='幽冥之霜:BAAAKgAFFAQIBAAAAA==.幽冥寒霜:BAAAKgAFFAQIBAAAAA==.',['库帕']='库帕城堡:BAABKgAFFH8GAAIaAAYI3B5LBgAgAQAaAAYI3B5LBgAgAQAAAA==.',['延凌']='延凌:BAAAKgADCggICQAAAA==.',['张羽']='张羽:BAAAKgADCgQIBAAAAA==.',['影焰']='影焰幻魔:BAABKgAFFH8GAAIDAAYIjBmvEwBoAQADAAYIjBmvEwBoAQAAAA==.',['彻底']='彻底疯狂:BAAAKgAFFAQIAQAAAA==.',['得鹿']='得鹿梦鱼:BAACKgAFFH8MAAMkAAYIwB+MBwCdAQAkAAYIwB+MBwCdAQAjAAQIMCC4BwAdAQAqAAQKfxgAAg4ACAh8H/0OAFsCAA4ACAh8H/0OAFsCAAAA.',['微云']='微云似梦:BAAAKgAFFAcIBAABKgAFFAgIDAAeALQTAA==.',['心静']='心静抚涟:BAAAKgADCgMIAwAAAA==.',['快乐']='快乐得驸马爷:BAAAKgAECgYICwAAAA==.快乐熊白:BAAAKgAECgcIBwAAAA==.',['忽必']='忽必烈烈:BAAAKgADCggIDQAAAA==.',['怎么']='怎么变都有型:BAABKgAFFH8ZAAMGAAgIhg9uCgDqAQAGAAgIhg9uCgDqAQAEAAUI3gf4JgCKAAAAAA==.',['恐怖']='恐怖风车人:BAABKgAFFH8MAAISAAYIvRg9CACIAQASAAYIvRg9CACIAQAAAA==.',['恶魔']='恶魔丶杀戮者:BAAAKgAECggICwAAAA==.',['悾惧']='悾惧利刃:BAAAKgAFFAIIAgAAAA==.',['情意']='情意宝贝:BAAAKgADCggICAAAAA==.',['情歌']='情歌唱晚:BAAAKgAECgUIBQAAAA==.',['情绪']='情绪微凉:BAAAKgAFFAQIBAAAAA==.',['慕少']='慕少艾:BAAAKgADCgQIBAAAAA==.',['慕月']='慕月清风:BAABKgAECn8cAAMDAAgIWRSUIACoAQADAAgIWRSUIACoAQAcAAEICgfuhwAhAAAAAA==.',['慢炖']='慢炖:BAABKgAFFH8LAAMQAAgIDA66BgA0AQAQAAYICRG6BgA0AQAMAAUIIQncIQD4AAAAAA==.',['懒信']='懒信仰:BAAAKgAECgEIAQAAAA==.',['懒得']='懒得开门:BAABKgAFFH8GAAIDAAYInBpDGwAsAQADAAYInBpDGwAsAQAAAA==.',['我有']='我有钱:BAAAKgAECggIDQAAAA==.',['我直']='我直接射爆:BAAAKgAFFAEIAQAAAA==.',['战帝']='战帝子龍:BAAAKgADCggICAAAAA==.',['战欲']='战欲狂:BAAAKgAECggICAAAAA==.',['扈三']='扈三娘:BAAAKgADCgYIBgAAAA==.',['托桃']='托桃李天王:BAAAKgAECgcIDAAAAA==.',['扛着']='扛着圣光揍你:BAAAKgAFFAMIAwAAAA==.',['执手']='执手相看泪眼:BAAAKgAECgEIAQAAAA==.',['扶丁']='扶丁:BAAAKgADCggIEAAAAA==.',['扶瑶']='扶瑶九霄:BAABKgAFFH8GAAIEAAYIrwmWEgAKAQAEAAYIrwmWEgAKAQAAAA==.',['折耳']='折耳根:BAAAKgAFFAQIBAAAAA==.',['拉美']='拉美莫尔:BAAAKgAECgEIAQAAAA==.',['拘灵']='拘灵遣将:BAAAKgAECgYIBgAAAA==.',['拾壹']='拾壹灬:BAABKgAFFH8GAAILAAYIRBjICwCLAQALAAYIRBjICwCLAQAAAA==.',['拿铁']='拿铁女士:BAAAKgADCggICAAAAA==.',['捷拉']='捷拉奥拉:BAAAKgAFFAgIBAAAAA==.',['排骨']='排骨炖萝卜:BAABKgAECn8bAAMkAAgIQhtDGwD8AQAkAAgIQhtDGwD8AQAOAAQI1xJ5YgCPAAABKgAFFAEIAQAiAAAAAA==.',['掩饰']='掩饰:BAAAKgADCggICAAAAA==.',['携手']='携手天涯:BAAAKgAFFAQIBAAAAA==.',['撒汤']='撒汤小笼包:BAACKgAFFH8UAAMgAAYInxBhGADeAAAgAAYIMwphGADeAAAfAAQInw5XOwCwAAAqAAQKfxcAAyAACAg2EMslAFwBACAACAg2EMslAFwBAB8AAgjHCH21AGAAAAAA.',['放肆']='放肆丨为红颜:BAACKgAFFH85AAMPAAgIux5SBABCAgAPAAgIBx1SBABCAgANAAYIBxyiCwC1AQAqAAQKfxwAAw0ACAhQIM1QAL8BAA0ACAh9Fs1QAL8BAA8ABAjNIbprALMAAAAA.',['教育']='教育网专区:BAACKgAFFH8SAAQSAAYIwR5NBQAOAQASAAYILh5NBQAOAQAhAAIIuxXUDwCAAAARAAEIeR+nJgBWAAAqAAQKfzwABCEACAjXJAIEALUCACEACAilIwIEALUCABIACAg+IxYHAKICABEACAhlHn0SAHMCAAEqAAUUCAgMACEARhkA.教育网专区呀:BAAAKgAFFAMIAwABKgAFFAgIDAAhAEYZAA==.',['文艺']='文艺朮士:BAABKgAFFH8GAAMTAAYI/RvgBQAnAQATAAQIvRvgBQAnAQAcAAII/xwoJgBNAAABKgAFFAgIEAADAIkgAA==.',['旋转']='旋转的小跳蚤:BAAAKgAECgIIAgAAAA==.',['无奈']='无奈的:BAAAKgADCggICQAAAA==.',['无孪']='无孪:BAAAKgAFFAIIAgAAAA==.',['无小']='无小甜甜:BAAAKgADCggICAAAAA==.',['无敌']='无敌汤圆哥哥:BAABKgAFFH8GAAMNAAQIyg8UJgC6AAANAAQIUAcUJgC6AAAPAAIINhbeGACdAAAAAA==.',['无法']='无法爆头:BAAAKgADCgcIBwAAAA==.',['无碍']='无碍:BAAAKgAFFAUIBAABKgAFFAgIEAAkAFsKAA==.',['早饭']='早饭吃的啥丶:BAABKgAFFH8SAAIIAAMIUBzkQADvAAAIAAMIUBzkQADvAAABKgAFFAQIFAANAAgjAA==.',['明月']='明月照大江:BAABKgAFFH8GAAIfAAYIwhKIEwB+AQAfAAYIwhKIEwB+AQAAAA==.',['明箭']='明箭:BAAAKgAFFAYIAgAAAA==.',['春风']='春风随我:BAABKgAFFH8GAAIIAAMINgprNwCDAAAIAAMINgprNwCDAAAAAA==.',['晨雀']='晨雀:BAAAKgAECgUIBQAAAA==.',['暖一']='暖一杯茶:BAAAKgADCggICAAAAA==.',['暖丶']='暖丶阳:BAABKgAFFH8PAAIQAAQILQLbIABcAAAQAAQILQLbIABcAAAAAA==.',['暗之']='暗之右手:BAAAKgAECggICAAAAA==.',['暗炉']='暗炉烤地瓜:BAAAKgADCgIIAgAAAA==.',['暴走']='暴走扳手:BAAAKgAECgMIAwAAAA==.',['暴躁']='暴躁前任小陈:BAABKgAFFH8IAAIfAAgIGAjiCACrAQAfAAgIGAjiCACrAQAAAA==.',['書生']='書生奪命箭:BAAAKgADCgIIAgAAAA==.',['最爱']='最爱小粉:BAABKgAFFH8HAAQLAAUIHwadGQC9AAALAAQIrwedGQC9AAAaAAIIcAUrGABLAAAVAAEIjg1bJgBFAAAAAA==.',['最瞹']='最瞹之媛:BAABKgAFFH8GAAIIAAII0RKPcwCDAAAIAAII0RKPcwCDAAAAAA==.',['月下']='月下射天狼:BAAAKgAECggIDQAAAA==.',['月中']='月中眠:BAAAKgAFFAMIAwAAAA==.',['月光']='月光丶消魂:BAABKgAFFH8IAAMGAAQIQxeGEgDwAAAGAAQIQxeGEgDwAAAEAAQImhWqHQC4AAAAAA==.',['月随']='月随枫飞:BAABKgAFFH8IAAQOAAQIcBoQDADWAAAOAAQI6RMQDADWAAAjAAMIvh5nFAC7AAAkAAEIAR1wIQBXAAAAAA==.',['有四']='有四个棍子:BAABKgAECn8XAAILAAgIzyBDBQCDAgALAAgIzyBDBQCDAgAAAA==.',['期待']='期待依旧空白:BAAAKgAECggIEQAAAA==.',['未梦']='未梦:BAAAKgAFFAMIAwAAAA==.',['杀生']='杀生成仁:BAAAKgAECggICAAAAA==.',['杨教']='杨教授之吻:BAABKgAFFH8IAAILAAQI2R/rBwAZAQALAAQI2R/rBwAZAQABKgAFFAgIEAALACIVAA==.',['极个']='极个别同学:BAAAKgADCggICgAAAA==.',['枭枭']='枭枭乐:BAAAKgAECgcICAAAAA==.',['柒月']='柒月:BAAAKgAFFAIIAgAAAA==.',['树形']='树形闪电:BAAAKgAECgcIBwAAAA==.',['树深']='树深见鹿:BAAAKgADCggICAAAAA==.',['格斗']='格斗王灵:BAAAKgAECgMIBAAAAA==.',['格蕾']='格蕾科:BAAAKgAECgQIBQAAAA==.',['梅絍']='梅絍緈:BAAAKgAECggICAAAAA==.',['梦丨']='梦丨靥:BAAAKgADCgEIAgAAAA==.',['梦如']='梦如尘缘:BAAAKgAECgcIDwAAAA==.',['梦行']='梦行烟雨夜:BAAAKgAECgYIBgAAAA==.',['梵月']='梵月:BAAAKgAECgMIAwAAAA==.',['椰子']='椰子超甜:BAAAKgAECggIEAAAAA==.',['樱辰']='樱辰花落:BAAAKgAECggICAAAAA==.樱辰花陨:BAABKgAFFH8IAAIIAAgIKCLrAgC+AgAIAAgIKCLrAgC+AgAAAA==.',['橙沐']='橙沐:BAAAKgAECgIIAgAAAA==.',['欧皇']='欧皇附体:BAAAKgAECgUIBQAAAA==.',['欲望']='欲望战魔:BAACKgAFFH8FAAIGAAQI3iTbCgAXAQAGAAQI3iTbCgAXAQAqAAQKfxoAAgQACAjTFYsgAMQBAAQACAjTFYsgAMQBAAAA.欲望铁骑:BAAAKgAFFAEIAQAAAA==.',['正义']='正义使者:BAAAKgAECgIIAgAAAA==.',['此刻']='此刻应有烟火:BAABKgAECn8WAAMOAAgI8hOAPABJAQAOAAgIDw6APABJAQAjAAUIHhYmPAD9AAAAAA==.',['残奥']='残奥会:BAAAKgAECgYIBgAAAA==.',['每天']='每天酸菜鱼:BAAAKgAECgEIAQAAAA==.',['水是']='水是睡醒的冰:BAACKgAFFH8SAAMLAAMIlSOKFAAzAQALAAMIlSOKFAAzAQAaAAMIJAiyFQCjAAAqAAQKfxoAAgsACAjOH2wTAFUCAAsACAjOH2wTAFUCAAAA.',['水晶']='水晶乄装甲:BAABKgAFFH8FAAISAAUILgkxCQAFAQASAAUILgkxCQAFAQAAAA==.',['永恒']='永恒太阿星:BAABKgAECn8hAAMIAAgI3CONFgC9AgAIAAgI3CONFgC9AgAeAAEIAAAlcQAAAAAAAA==.永恒猎仙:BAAAKgAECgQIBAAAAA==.',['永远']='永远的豆子哥:BAAAKgAECggIDwAAAA==.',['汉尼']='汉尼巴:BAACKgAFFH8GAAIfAAYIDx78DQC1AQAfAAYIDx78DQC1AQAqAAQKfxcAAh8ACAiDEB1eAEwBAB8ACAiDEB1eAEwBAAAA.',['法力']='法力虚空:BAABKgAFFH8SAAIQAAUI7yCAAQBEAQAQAAUI7yCAAQBEAQAAAA==.',['泡泡']='泡泡二不小心:BAAAKgAECggIDwAAAA==.',['泰兰']='泰兰徳丶语风:BAAAKgAECgYIBgAAAA==.',['泰山']='泰山:BAAAKgAFFAgIAwAAAA==.',['洛丹']='洛丹伦刽子手:BAAAKgADCgYIBgAAAA==.',['洛迪']='洛迪亚斯:BAAAKgADCgQIBAAAAA==.',['洫傷']='洫傷:BAABKgAECn8dAAIOAAYIeRNRRQAjAQAOAAYIeRNRRQAjAQAAAA==.',['流水']='流水大王:BAAAKgAECggICAAAAA==.',['浅生']='浅生离:BAAAKgAECgcICQAAAA==.',['浪里']='浪里个浪:BAAAKgADCgMIAwAAAA==.',['海之']='海之妖僧:BAAAKgAECgYIBgAAAA==.',['消失']='消失之王:BAAAKgAECgEIAQAAAA==.',['淡淡']='淡淡的稻香:BAABKgAECn8ZAAIXAAgIlRcnEgDuAQAXAAgIlRcnEgDuAQAAAA==.',['深度']='深度冻结丶:BAABKgAFFH8IAAMJAAYIHRLfEQAyAQAJAAYIIAvfEQAyAQAKAAIItyAFEgCYAAAAAA==.',['清羽']='清羽潇潇:BAABKgAFFH8PAAIJAAUIgxuzEgAHAQAJAAUIgxuzEgAHAQAAAA==.',['清风']='清风月影:BAAAKgAECggICAAAAA==.',['渺怒']='渺怒:BAACKgAFFH8JAAMJAAQIziAzDwAcAQAJAAQIziAzDwAcAQAKAAEI6hSMIQA6AAAqAAQKfxsAAwkACAghHR0ZAF0CAAkACAi7HB0ZAF0CAAoABgiVE+hXAAcBAAAA.',['湖人']='湖人总冠军吖:BAAAKgAECgIIAgAAAA==.',['溜溜']='溜溜球:BAABKgAFFH8GAAIPAAYIyCTpBgD3AQAPAAYIyCTpBgD3AQAAAA==.',['火灾']='火灾:BAACKgAFFH8JAAMPAAMINwlLOwCKAAAPAAMIYAZLOwCKAAANAAIIhwqBPAB5AAAqAAQKfxQAAw0ACAj/FPNJANYBAA0ACAi8FPNJANYBAA8AAwhNETxyAG8AAAAA.',['灬小']='灬小二灬货灬:BAAAKgADCgEIAQAAAA==.',['灬尛']='灬尛酒窩灬:BAABKgAFFH8hAAMNAAgIcB5QBQBJAgANAAgIcB5QBQBJAgAPAAIIYQ/fGACdAAAAAA==.',['為了']='為了臉盟:BAAAKgAECgQIBAAAAA==.',['熊撞']='熊撞树上了:BAABKgAECn8lAAMHAAgIuwuqEwAVAQAHAAgIuwuqEwAVAQAGAAEIwgEH2gASAAAAAA==.',['熊爷']='熊爷不做奶:BAAAKgAFFAIIAgAAAA==.',['爆你']='爆你花:BAAAKgAECgIIAgAAAA==.',['爆灬']='爆灬炎:BAAAKgAECgIIAgAAAA==.',['爱忘']='爱忘东西的我:BAAAKgAECggIBwAAAA==.',['爱淇']='爱淇东西的我:BAAAKgADCggICAAAAA==.',['爷爷']='爷爷爱蛇精:BAAAKgAFFAMIAwAAAA==.',['牛孑']='牛孑精灵:BAABKgAECn8XAAIIAAgICB00SQAVAgAIAAgICB00SQAVAgAAAA==.',['牧野']='牧野天痕:BAAAKgAFFAQIBAABKgAFFAgIFAAOACcUAA==.',['狂暴']='狂暴不怕困难:BAAAKgAECgYIBgAAAA==.',['狂野']='狂野叶子:BAAAKgAECgEIAQAAAA==.',['狗卷']='狗卷棘:BAAAKgAECgQIBAAAAA==.',['独孤']='独孤善:BAABKgAFFH8FAAMDAAUILhYKCwAIAQADAAQI3BsKCwAIAQAcAAEIJQUbFwBNAAAAAA==.',['狮王']='狮王瓦里安:BAAAKgADCggICAAAAA==.',['猎手']='猎手:BAAAKgAFFAIIAgAAAA==.',['猎神']='猎神之神:BAAAKgADCggICAAAAA==.',['猫胖']='猫胖胖:BAAAKgAFFAgIAgAAAA==.',['王蜀']='王蜀黍:BAACKgAFFH8IAAMLAAQIzxvgGQCoAAALAAMInB/gGQCoAAAVAAMIgQ3+EgB8AAAqAAQKf2UAAxUACAj8IrgIAKsCABUACAj8IrgIAKsCAAsACAgJGtgoANwBAAAA.',['玛雅']='玛雅王:BAAAKgAECgIIAgAAAA==.',['珍妮']='珍妮玛一戴劲:BAAAKgADCgQIBAAAAA==.',['琥珀']='琥珀川:BAAAKgAECgcIBwAAAA==.',['甜到']='甜到爆团子:BAAAKgADCgYIBgAAAA==.',['画心']='画心:BAABKgAECn8ZAAILAAgIthNJQAB1AQALAAgIthNJQAB1AQAAAA==.',['癫火']='癫火:BAABKgAFFH8OAAMCAAYIuB8IDQCVAQAJAAUIuiMXCQCtAQACAAYI9xcIDQCVAQABKgAFFAgIAgACAAIWAA==.',['白熊']='白熊:BAACKgAFFH8YAAMfAAMI4AwMFgC2AAAfAAMI4AwMFgC2AAAUAAMI1wWaDQCfAAAqAAQKfx0AAx8ACAhSFyFPAH0BAB8ACAg0EyFPAH0BABQAAwgxFOgkALEAAAAA.',['白银']='白银之翼:BAAAKgADCgMIAgAAAA==.',['百变']='百变小小德:BAAAKgADCgMIAwAAAA==.',['看着']='看着青春走开:BAAAKgAECgUIBAAAAA==.',['矼死']='矼死的魚:BAABKgAFFH8TAAMgAAYIJyZwAwAtAgAgAAYIJyZwAwAtAgAfAAQIqSF1DQAlAQAAAA==.',['砍人']='砍人是犯法的:BAAAKgADCgQIBAAAAA==.',['磨牙']='磨牙磨牙:BAABKgAFFH8QAAMOAAYIWyOEBQDeAQAOAAYIWyOEBQDeAQAjAAQIIxPgJgBGAAAAAA==.',['祈祷']='祈祷:BAAAKgAECgYICwAAAA==.',['神之']='神之冰吻:BAAAKgAFFAgIBAAAAA==.神之笑:BAAAKgAECggIEAAAAA==.',['神泣']='神泣耶啝華:BAAAKgAECgcIBwAAAA==.',['神祈']='神祈:BAAAKgAECggIEwAAAA==.',['神采']='神采飞杨灬:BAAAKgADCggICwAAAA==.',['福娃']='福娃娃:BAAAKgADCggICAAAAA==.',['秧歌']='秧歌斯达:BAAAKgAFFAgIBAAAAA==.',['移情']='移情丶别恋:BAABKgAFFH8KAAIXAAYICxvDBwAHAQAXAAYICxvDBwAHAQAAAA==.',['空即']='空即是色:BAAAKgAECgIIAgAAAA==.',['粉色']='粉色体育生:BAAAKgAECgYICwAAAA==.',['精神']='精神高回蓝快:BAAAKgAECgUIBAAAAA==.',['糯米']='糯米帽子:BAABKgAFFH8GAAIfAAYIxhHDCgBvAQAfAAYIxhHDCgBvAQAAAA==.糯米粽子:BAABKgAFFH8GAAMUAAYIIwiUDQCfAAAUAAQIuQaUDQCfAAAfAAIIQQpKQgCVAAAAAA==.',['紫嫣']='紫嫣然:BAAAKgAFFAQIBAAAAA==.',['紫色']='紫色韵味:BAABKgAFFH8QAAMjAAgIphIeBQDvAQAjAAgIQxEeBQDvAQAOAAQIpAxGDwDFAAAAAA==.',['红发']='红发:BAAAKgADCggICAAAAA==.',['红唛']='红唛卜鎏子:BAAAKgADCggICAAAAA==.',['红月']='红月夜之猎:BAABKgAECn8+AAINAAgIkCIJDwCsAgANAAgIkCIJDwCsAgAAAA==.',['绝世']='绝世灬李:BAAAKgADCgcIBwAAAA==.',['绝命']='绝命制裁:BAAAKgAECgEIAQAAAA==.',['绯色']='绯色月下:BAAAKgAECgEIAQAAAA==.',['维也']='维也娜:BAAAKgAECgIIAgAAAA==.',['绵绵']='绵绵瓜瓞:BAAAKgADCgEIAQAAAA==.',['绿茶']='绿茶:BAAAKgAECgcIBwAAAA==.',['缘定']='缘定三修:BAAAKgADCgEIAQAAAA==.',['罪爱']='罪爱之爰:BAAAKgAECgMIAwAAAA==.',['羽锋']='羽锋:BAABKgAFFH8GAAMjAAQIWB0AFAC/AAAjAAMIWx8AFAC/AAAkAAEIcwsTJQBKAAAAAA==.',['翩翩']='翩翩起舞:BAABKgAFFH8GAAIQAAYICBfBBABjAQAQAAYICBfBBABjAQAAAA==.',['职业']='职业萨满:BAABKgAFFH8GAAILAAYIwg7GEABPAQALAAYIwg7GEABPAQAAAA==.',['聖光']='聖光丶惩戒者:BAAAKgAECgEIAQAAAA==.',['胖子']='胖子:BAAAKgAECgEIAQAAAA==.',['艾格']='艾格丽丝:BAAAKgAECgMIAwAAAA==.',['艾薇']='艾薇:BAACKgAFFH8fAAMNAAQIJh7GJAD0AAANAAQIJh7GJAD0AAAPAAEIiQh6VAAwAAAqAAQKfzMAAw8ACAgRIE4VAE8CAA8ACAi8Hk4VAE8CAA0ACAi2GyAUAOkBAAAA.',['花心']='花心小美:BAAAKgAECgIIAgAAAA==.',['花舞']='花舞花落泪:BAABKgAFFH8HAAIIAAcIKQfKEgBxAQAIAAcIKQfKEgBxAQAAAA==.',['苏栈']='苏栈:BAAAKgAECgcICAAAAA==.',['英勇']='英勇怒火:BAAAKgADCgcIBwAAAA==.',['苹果']='苹果熊:BAAAKgAECgMIBAAAAA==.',['莉尔']='莉尔妮芙:BAAAKgADCgIIAgAAAA==.',['莫比']='莫比迪克:BAABKgAFFH8GAAIVAAYIlBWYBwBhAQAVAAYIlBWYBwBhAQAAAA==.',['菲菲']='菲菲尔:BAAAKgAECgcIBwAAAA==.',['营养']='营养快线丶:BAAAKgADCgcIBwAAAA==.',['萨拉']='萨拉卡斯:BAAAKgAFFAYIAgAAAA==.萨拉塔寺:BAAAKgAECggIDAAAAA==.',['萨洛']='萨洛之锋:BAAAKgAECgMIAwAAAA==.',['萨萨']='萨萨罗:BAABKgAECn8jAAIVAAgILhdtIADrAQAVAAgILhdtIADrAQAAAA==.',['萨那']='萨那也路:BAAAKgAECgIIAgAAAA==.',['落日']='落日几倦:BAABKgAFFH8KAAIeAAYIqx6YBgD6AAAeAAYIqx6YBgD6AAAAAA==.',['葫芦']='葫芦娃斗蛇精:BAAAKgAFFAMIAwAAAA==.',['蓝之']='蓝之魅:BAAAKgAECgMIAwAAAA==.',['虚空']='虚空一号:BAAAKgADCggIEAAAAA==.虚空丶小劣人:BAAAKgAECgEIAQAAAA==.',['虹雨']='虹雨夜:BAAAKgAECggICAAAAA==.',['蛇精']='蛇精爱爷爷:BAAAKgAECgEIAQAAAA==.',['蛋那']='蛋那个蛋:BAAAKgAECgcIEQAAAA==.',['被猫']='被猫挠的鱼:BAAAKgADCgcIBwAAAA==.',['西格']='西格里夫:BAAAKgADCggICAAAAA==.',['让我']='让我绿了你:BAAAKgAFFAEIAQAAAA==.',['谁主']='谁主沉浮:BAABKgAFFH8GAAIOAAYIMxhGDQBRAQAOAAYIMxhGDQBRAQAAAA==.',['谁特']='谁特麼买小米:BAABKgAFFH8UAAMPAAQIDB+VCAADAQAPAAQIbByVCAADAQANAAQI/Bo1FgD2AAAAAA==.',['调车']='调车信号:BAAAKgAECgYIBgAAAA==.',['谷雨']='谷雨:BAAAKgADCgMIAwAAAA==.',['败者']='败者食尘:BAAAKgAFFAgIAwAAAA==.',['贪婪']='贪婪之袜:BAABKgAFFH8GAAMIAAYIDQxYWgC8AAAIAAMIBhBYWgC8AAABAAMIoQygFQCIAAAAAA==.',['贫僧']='贫僧法号三葬:BAAAKgAECgYIDAAAAA==.',['贰爺']='贰爺丶慕斯:BAAAKgAECggIDAAAAA==.',['费斯']='费斯科:BAAAKgAECgUIBQAAAA==.',['赤脊']='赤脊山的猪:BAAAKgAECgcICQAAAA==.',['超级']='超级五花肉:BAAAKgAECgUIBQAAAA==.超级大满贯:BAABKgAFFH8GAAILAAYIIxp/DACDAQALAAYIIxp/DACDAQAAAA==.',['软甜']='软甜:BAAAKgAECggICAAAAA==.',['辛普']='辛普雷:BAAAKgAFFAEIAQAAAA==.',['运运']='运运:BAABKgAECn8yAAMEAAgIEB+LCgBpAgAEAAgIEB+LCgBpAgAGAAcInQ2pZQAtAQAAAA==.',['还我']='还我爬爬:BAAAKgAECgcIBwAAAA==.',['迷螨']='迷螨:BAAAKgAFFAIIAgAAAA==.',['迷雾']='迷雾:BAAAKgAFFAMIAwAAAA==.',['追寻']='追寻:BAAAKgAECggICQAAAA==.',['追求']='追求梦想:BAAAKgAFFAIIAgAAAA==.',['追风']='追风丶叨叨:BAAAKgADCggICAAAAA==.追风丶小僧:BAAAKgADCgEIAQAAAA==.',['逆水']='逆水寒参上:BAAAKgAECgUIBQAAAA==.',['逐风']='逐风丶阿萨斯:BAAAKgAECgEIAQAAAA==.',['遥望']='遥望远帆:BAAAKgAECgIIAgAAAA==.',['那一']='那一抹灬残阳:BAAAKgAECgEIAQAAAA==.',['邪恶']='邪恶攻击:BAAAKgADCgUIBQAAAA==.',['郑氵']='郑氵华仔:BAAAKgAFFAYIAgAAAA==.',['部落']='部落小霸王:BAAAKgAECgcIEQAAAA==.',['都说']='都说我瞎面咸:BAAAKgAECgUIBQAAAA==.',['鄙人']='鄙人不善言辞:BAAAKgAECgUIBQAAAA==.鄙人不擅奔跑:BAAAKgAFFAIIAgAAAA==.',['酷酷']='酷酷的叮叮:BAABKgAFFH8KAAIPAAYIjBRSCwDxAAAPAAYIjBRSCwDxAAAAAA==.',['醉萌']='醉萌德:BAAAKgADCgIIAgAAAA==.',['采菊']='采菊东篱下:BAAAKgADCggICAAAAA==.',['野比']='野比雄:BAAAKgAECgQIBAAAAA==.',['鑫鑫']='鑫鑫:BAAAKgAECggICAAAAA==.',['钟无']='钟无月:BAABKgAFFH8IAAIPAAgI4wwVCwClAQAPAAgI4wwVCwClAQAAAA==.',['锐眼']='锐眼穿杨:BAAAKgADCgIIAgAAAA==.',['长相']='长相依灬:BAAAKgAFFAgIAgAAAA==.',['闲云']='闲云野德:BAAAKgAFFAYIAQABKgAFFAgIAgAiAAAAAA==.',['阮中']='阮中蕐:BAACKgAFFH8GAAQcAAIIpQ0UHABCAAATAAEIyA7LHABKAAAcAAEIbQsUHABCAAADAAEIggxLMwA+AAAqAAQKfzoABAMACAijHaAYAC8CAAMACAgaHaAYAC8CABwABwhMF80kAHABABMAAQiIGS87AEUAAAAA.',['阴阳']='阴阳交错神功:BAAAKgADCgYIBgAAAA==.',['阿克']='阿克留斯:BAAAKgAECggICAAAAA==.',['阿塔']='阿塔兰歆:BAAAKgAECggIEAAAAA==.',['阿巴']='阿巴阿巴:BAAAKgAECggIBgAAAA==.',['阿曼']='阿曼凡布伦:BAABKgAECn8jAAMNAAYI+B5oGQCxAQANAAYI+B5oGQCxAQAPAAEIWQYjlgAfAAAAAA==.阿曼多:BAAAKgAECgcIDAAAAA==.',['阿莎']='阿莎蓓尔:BAAAKgADCggICAAAAA==.',['阿莫']='阿莫西林:BAAAKgADCggICAAAAA==.',['陳平']='陳平安:BAAAKgAECgEIAQAAAA==.',['随我']='随我婆娑:BAAAKgAECgQIBAAAAA==.',['雨落']='雨落:BAAAKgAECgMIAwAAAA==.',['雷诺']='雷诺塔希克斯:BAAAKgADCgEIAQAAAA==.',['雾殇']='雾殇:BAACKgAFFH8gAAIIAAgI9hGvEwC+AQAIAAgI9hGvEwC+AQAqAAQKf0UAAwgACAjiIv0/AC8CAAgACAjiIv0/AC8CAB4ACAjkCB4uAOsAAAAA.',['霜火']='霜火影锋:BAAAKgAFFAQIBAAAAA==.',['露琪']='露琪卡:BAAAKgAECgEIAQAAAA==.',['霸気']='霸気丨殺神:BAABKgAFFH8GAAIfAAYIDBPvFQBsAQAfAAYIDBPvFQBsAQAAAA==.霸気丨鳥大:BAAAKgAECgcIBwAAAA==.',['青城']='青城山莽撞人:BAAAKgAECgYIBwAAAA==.',['青山']='青山做客:BAAAKgADCggICAAAAA==.',['青空']='青空断翼:BAABKgAECn9ZAAIGAAgICCTyBAC2AgAGAAgICCTyBAC2AgAAAA==.',['顾尔']='顾尔蛋:BAAAKgADCgQIBAAAAA==.',['風灬']='風灬崭:BAAAKgAECgQIBQAAAA==.風灬芈:BAAAKgAECgMIAwAAAA==.',['风后']='风后奇门:BAAAKgAFFAMIAwAAAA==.',['风满']='风满楼枫紫:BAAAKgADCgQIBAAAAA==.',['风雨']='风雨之霸:BAAAKgAECggICgAAAA==.风雨飞:BAAAKgAECggICAAAAA==.',['飞云']='飞云:BAAAKgAECgIIAgAAAA==.',['马维']='马维娜的施展:BAAAKgAECgIIAwAAAA==.',['骑驴']='骑驴漂流:BAAAKgADCgMIAwAAAA==.',['鬼舞']='鬼舞辻无惨:BAAAKgADCgUIBQAAAA==.',['魔法']='魔法飞吻你:BAAAKgAECgcIDgAAAA==.',['魔牙']='魔牙魔牙:BAAAKgAECgYIBgAAAA==.',['魔界']='魔界:BAAAKgADCggIEAAAAA==.',['鴩丶']='鴩丶灰烬使者:BAAAKgAECgIIAgAAAA==.',['麻辣']='麻辣小钢珠:BAABKgAFFH8SAAIIAAgI4x7OBQBxAgAIAAgI4x7OBQBxAgAAAA==.',['黎玥']='黎玥儿:BAABKgAECn8aAAIMAAgIpx8rJADnAQAMAAgIpx8rJADnAQAAAA==.',['黑傻']='黑傻馒:BAABKgAECn8pAAILAAgIXx3qFwA5AgALAAgIXx3qFwA5AgAAAA==.',['黑喵']='黑喵大侠:BAAAKgAFFAEIAQAAAA==.',['黑暗']='黑暗堡垒:BAAAKgADCgEIAQAAAA==.黑暗美骑:BAAAKgAFFAYIAgAAAA==.',['黑炎']='黑炎血翼:BAAAKgADCgMIAwAAAA==.',['黑锋']='黑锋丿姥姥:BAABKgAFFH8GAAIgAAYIrQlSGADeAAAgAAYIrQlSGADeAAAAAA==.',['默小']='默小羽:BAAAKgADCggICAAAAA==.',['齉齾']='齉齾爩灪纞虋:BAABKgAFFH8fAAMfAAgI1h0yAwCTAgAfAAgI1h0yAwCTAgAgAAIIuBV1GACPAAAAAA==.',['龙泉']='龙泉小密:BAAAKgAECgQIBAAAAA==.',['龙蛇']='龙蛇战野:BAAAKgAECgcICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end