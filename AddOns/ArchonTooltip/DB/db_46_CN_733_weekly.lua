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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','Mage-Frost','Paladin-Retribution','DeathKnight-Unholy','Priest-Discipline','Priest-Holy','Evoker-Augmentation','Priest-Shadow','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','Rogue-Subtlety','Rogue-Assassination','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Fury','Warrior-Protection','Unknown-Unknown','Warrior-Arms','Shaman-Restoration','Druid-Balance','DemonHunter-Havoc','Druid-Restoration','Hunter-Survival',}
local provider = {region='CN',realm='海加尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aak:BAAALgAECgEJAQAAAA==.',
Ac='Accuracysiyi:BAAALgADCgYJAQAAAA==.',
Ap='Apacky:BAAALgAECgQJBQAAAA==.',
Bl='Bloodvva:BAAALgAECgIJAgAAAA==.',
Ca='Calmity:BAAALgAECgkJCAAAAA==.Cathy:BAAALgAECgUJBQAAAA==.',
Cd='Cdu:BAAALgADCgcJCAAAAA==.',
Co='Combust:BAABLgAECn8kAAMBAAgJ4hytLQD8AQABAAcJgR6tLQD8AQACAAMJkAo2aQCZAAAAAA==.Conp:BAAALgADCgkJCQAAAA==.',
De='Defiantpupil:BAABLgAFFH8LAAIDAAQJkyGZBgBpAQADAAQJkyGZBgBpAQAAAA==.',
Dr='Dragon:BAAALgAECgEJAQAAAA==.',
Ei='Eilda:BAECLgAFFH8SAAIEAAYJyiJgAgBnAgAEAAYJyiJgAgBnAgAuAAQKfxkAAgQACAn4IhcUADADAAQACAn4IhcUADADAAAA.',
Ev='Evilsempire:BAAALgAECgYJDQAAAA==.',
Fe='Fengrui:BAABLgAFFH8FAAIFAAMJmAwlFwD0AAAFAAMJmAwlFwD0AAAAAA==.',
Ge='Geraltzrivii:BAAALgAFFAQJBAAAAA==.',
Hu='Huakaifugui:BAAALgAECgYJCgAAAA==.Humankeeper:BAAALgAFFAIJAwAAAA==.',
Jo='Jonathan:BAAALgADCgIJAgAAAA==.',
Ki='Kimnation:BAAALgAECgYJCgAAAA==.',
Ku='Kurt:BAAALgAECgkJCQAAAA==.Kurtlol:BAABLgAECn8UAAIEAAcJ2x/KawD+AQAEAAcJ2x/KawD+AQAAAA==.',
La='Lacrimosa:BAAALgAECgQJBAAAAA==.Lanadelrey:BAAALgAECggJCwAAAA==.',
Lo='Lobita:BAAALgAECgQJBAAAAA==.',
Ma='Magicstar:BAAALgAFFAEJAgAAAA==.Markwoitz:BAAALgAECgYJBgAAAA==.',
Mi='Milla:BAAALgAECgUJBQAAAA==.',
Mo='Moonbow:BAAALgAECgMJAwAAAA==.',
Na='Nami:BAAALgAECgYJDwAAAA==.',
Ob='Oblivionis:BAAALgADCgUJBQABLgAFFAMJCgAGAEQiAA==.',
Pa='Packey:BAAALgAECgEJAQAAAA==.Packy:BAAALgAECgQJBQAAAA==.Pal:BAAALgAECgQJBAAAAA==.',
Po='Pookz:BAAALgAECgQJBQAAAA==.',
Ro='Roxette:BAAALgAECgkJCQAAAA==.',
Se='Senko:BAAALgAECgYJBgAAAA==.',
Sl='Slycroin:BAAALgAECgQJBQAAAA==.',
Sp='Spicystripws:BAAALgAFFAEJAQAAAA==.',
Su='Sukyz:BAAALgAECgQJAgAAAA==.',
Sw='Swordartol:BAAALgAECgkJCQAAAA==.',
Vi='Viego:BAAALgAECgEJAQAAAA==.Viscum:BAAALgAFFAEJAQAAAA==.',
Vo='Voyager:BAAALgAFFAMJBAAAAA==.',
Wi='Winter:BAAALgADCgEJAQAAAA==.',
Wo='Woodburn:BAAALgAECgkJCQABLgAFFAQJBQABAIMMAA==.',
Wu='Wuha:BAAALgAECgcJBQAAAA==.',
Xi='Xiaolie:BAAALgAECgEJAQAAAA==.',
Xt='Xtecklol:BAAALgAECgcJEQAAAA==.',
Yo='Yoma:BAABLgAECn8fAAMHAAgJ2glKBgCaAQAHAAgJ6AhKBgCaAQAIAAgJfQZwNwBeAQAAAA==.',
Zy='Zyp:BAAALgAECgIJAgAAAA==.',
['一丶']='一丶剩光:BAAALgADCgIJAgAAAA==.',
['一把']='一把抓:BAAALgAFFAIJAgAAAA==.',
['一拳']='一拳打鼠你:BAAALgAECgUJBgAAAA==.',
['一田']='一田一:BAAALgAECgYJCQAAAA==.',
['一级']='一级开始:BAAALgAECgEJAQAAAA==.',
['一脚']='一脚踢死你:BAABLgAECn8VAAIDAAcJBRq9IAD7AQADAAcJBRq9IAD7AQAAAA==.',
['七百']='七百酒:BAAALgAFFAcJAwAAAA==.',
['不胖']='不胖:BAAALgAECgMJBAAAAA==.',
['东京']='东京爱情故事:BAABLgAFFH8HAAIJAAMJNArWCQDkAAAJAAMJNArWCQDkAAAAAA==.',
['丶汏']='丶汏凱凱:BAAALgAECgUJCAAAAA==.',
['丶錵']='丶錵:BAABLgAFFH8FAAIFAAMJEhGZFQD+AAAFAAMJEhGZFQD+AAAAAA==.',
['为了']='为了一粒淡:BAAALgADCgYJBgAAAA==.',
['义薄']='义薄云天丶:BAAALgADCgkJDgAAAA==.',
['九百']='九百一:BAABLgAFFH8GAAIJAAQJORWDCQBXAQAJAAQJORWDCQBXAQAAAA==.',
['云雀']='云雀不渡海:BAAALgAECgkJCQAAAA==.',
['五百']='五百一:BAAALgAFFAUJAgAAAA==.',
['亡心']='亡心丨燚:BAAALgAECgEJAQAAAA==.亡心丨魍:BAAALgADCgYJBgAAAA==.',
['京香']='京香茱莉亞:BAAALgAECgYJBgAAAA==.',
['什么']='什么叫惊喜丶:BAAALgAECgUJBQAAAA==.',
['伊利']='伊利小丹丹:BAAALgAECgEJAQAAAA==.',
['伊斯']='伊斯坎布尔:BAAALgAECgUJBgAAAA==.',
['伍号']='伍号真棒:BAABLgAECn8TAAMCAAYJnyBzHwAmAgACAAYJmSBzHwAmAgABAAEJeCYAAAAAAAAAAA==.',
['傲世']='傲世孤狼:BAAALgAFFAMJAwAAAA==.',
['六百']='六百酒:BAABLgAFFH8FAAIJAAUJJhmuBAC+AQAJAAUJJhmuBAC+AQAAAA==.',
['关山']='关山难越:BAAALgADCgQJBAAAAA==.',
['其实']='其实:BAABLgAFFH8GAAIFAAMJ5xjNEQAXAQAFAAMJ5xjNEQAXAQAAAA==.',
['兽大']='兽大大兽:BAAALgADCgEJAQAAAA==.',
['内牛']='内牛满面:BAAALgAFFAEJAQAAAA==.',
['再同']='再同一个世界:BAAALgAECggJCAAAAA==.',
['再度']='再度:BAAALgAECgcJEAAAAA==.',
['冬天']='冬天的罗卜:BAAALgADCgEJAQAAAA==.',
['冰封']='冰封的回忆:BAAALgAECgQJBAAAAA==.',
['冰珑']='冰珑如玉:BAAALgAECgkJBwAAAA==.',
['冲钅']='冲钅老头:BAAALgADCgYJBgAAAA==.',
['冻梨']='冻梨子:BAABLgAECn8aAAIKAAcJNBLyKwB9AQAKAAcJNBLyKwB9AQAAAA==.',
['凌晨']='凌晨四点半:BAAALgAECgkJDgABLgAFFAYJDwAFAJghAA==.',
['凯厄']='凯厄斯:BAABLgAECn8UAAIFAAgJfhplJwCIAgAFAAgJfhplJwCIAgAAAA==.',
['凯瑟']='凯瑟琳冰儿:BAAALgAECgkJCQABLgAFFAYJCwAEAMUbAA==.',
['别划']='别划走:BAAALgAFFAIJAgAAAA==.',
['前夕']='前夕丶骑士:BAABLgAECn8UAAMFAAYJGCK5QwAZAgAFAAYJGCK5QwAZAgALAAIJ7wGijgBEAAAAAA==.',
['勤劳']='勤劳的卡比兽:BAAALgAECgkJCwAAAA==.',
['勺子']='勺子术:BAAALgAFFAIJBAAAAA==.勺子梅猫饼:BAACLgAFFH8MAAMBAAQJXiWKAAC+AQABAAQJXiWKAAC+AQACAAEJTxDTKABKAAAuAAQKfxgAAwEABwnCIY0uAPcBAAEABglLI40uAPcBAAIABwnrF4IwAK8BAAAA.勺子死骑:BAAALgAFFAIJAwAAAA==.',
['十六']='十六:BAAALgAECgYJCwAAAA==.',
['半神']='半神灬沫沫子:BAABLgAECn8VAAQMAAcJjha+EgC2AQAMAAYJDRq+EgC2AQANAAYJRBjwGwCoAQAJAAEJHATUZwAmAAAAAA==.',
['南丶']='南丶春香:BAAALgAECgMJAwAAAA==.',
['南极']='南极萨满:BAAALgAECgcJBwAAAA==.',
['卡尔']='卡尔库克:BAAALgAECgYJEwAAAA==.',
['卡翠']='卡翠娜娜:BAAALgAECgQJBAAAAA==.',
['卡蕾']='卡蕾拉晨风:BAAALgAECgIJAgABLgAECgcJFQAFAO8ZAA==.',
['厄运']='厄运先生:BAAALgAFFAEJAQAAAA==.',
['可乐']='可乐妙芙:BAAALgAECgYJBgAAAA==.',
['可以']='可以有:BAAALgAECgEJAQAAAA==.',
['史蒂']='史蒂文森:BAAALgADCgcJBwAAAA==.',
['君子']='君子见机:BAACLgAFFH8HAAMOAAMJRhI6EwCzAAAOAAMJTA86EwCzAAAPAAEJlQ79BQBeAAAuAAQKfyQAAw8ACAlDHN0CALcCAA8ACAkzGd0CALcCAA4ABgnMHBEnAMABAAAA.',
['咆哮']='咆哮的砖头:BAAALgAECgcJBwAAAA==.',
['咕德']='咕德猫呐:BAAALgAECgYJEgAAAA==.',
['哆啦']='哆啦小忽悠:BAAALgAECgYJBgAAAA==.',
['哈蒂']='哈蒂斯:BAABLgAECn8gAAIFAAgJmRIxDgC4AQAFAAgJmRIxDgC4AQAAAA==.',
['喵喵']='喵喵不是猫:BAAALgAECgQJBgAAAA==.',
['喵妖']='喵妖王:BAAALgAECgEJAQAAAA==.',
['嘤灬']='嘤灬嘤嘤:BAAALgAECgcJDAAAAA==.',
['四百']='四百一:BAAALgAFFAUJAgAAAA==.',
['困困']='困困儿:BAAALgAECgYJBgAAAA==.',
['国产']='国产凌凌漆:BAAALgADCgcJBwAAAA==.',
['圣光']='圣光普照:BAAALgAECgkJEAAAAA==.',
['复活']='复活双神:BAAALgAECgUJBgAAAA==.',
['夜青']='夜青:BAAALgAFFAIJAgAAAA==.',
['大声']='大声公:BAABLgAECn8ZAAIEAAcJWxxQWgAqAgAEAAcJWxxQWgAqAgAAAA==.',
['大鹏']='大鹏展翅:BAAALgAECgEJAQAAAA==.',
['天殊']='天殊:BAAALgADCgEJAQAAAA==.',
['好了']='好了别说了:BAAALgAFFAEJAQABLgAFFAYJEQAQANshAA==.',
['好呆']='好呆丶一坨:BAAALgAECgQJAQAAAA==.',
['好牛']='好牛丶一坨:BAAALgADCgYJBgAAAA==.',
['好萌']='好萌丶一坨:BAAALgAECgMJBgAAAA==.',
['始乱']='始乱未三:BAABLgAFFH8IAAMRAAUJhxIHBABUAQARAAQJqRQHBABUAQASAAMJGAlXJgDmAAAAAA==.始乱未二:BAABLgAFFH8XAAMRAAcJBRsvAwBsAQARAAYJDhovAwBsAQASAAUJDBdoDwBkAQAAAA==.始乱未伍:BAABLgAFFH8GAAMRAAQJShSlCwCtAAARAAQJShSlCwCtAAASAAEJPworTQBMAAAAAA==.始乱未叁:BAABLgAFFH8GAAMRAAUJNAnkBwDuAAARAAQJbQrkBwDuAAASAAIJiAUISQBTAAAAAA==.始乱未壹:BAAALgAFFAUJBAAAAA==.始乱未柒:BAAALgAFFAUJAwAAAA==.始乱未玖:BAABLgAFFH8KAAMRAAQJNxzzAgB2AQARAAQJNxzzAgB2AQASAAEJdg4bSwBQAAAAAA==.始乱未陸:BAAALgAFFAQJBAAAAA==.',
['威斯']='威斯特:BAAALgAECgMJAwAAAA==.',
['娜美']='娜美小宝儿:BAABLgAECn8UAAILAAcJiSAeEQCKAgALAAcJiSAeEQCKAgAAAA==.',
['宅妹']='宅妹她妹妹:BAAALgADCgcJBwAAAA==.',
['宅老']='宅老师:BAAALgADCgcJBwAAAA==.',
['安圣']='安圣鲁斯:BAAALgAECgQJBQAAAA==.',
['安德']='安德烈萨米罗:BAAALgADCgQJBAAAAA==.',
['安神']='安神:BAAALgADCgYJBgAAAA==.',
['完美']='完美若雪:BAACLgAFFH8LAAIEAAQJoRsLFwBtAQAEAAQJoRsLFwBtAQAuAAQKfyIAAgQABwneIQg9AIMCAAQABwneIQg9AIMCAAAA.',
['寂寞']='寂寞狐狸:BAAALgAFFAIJAwABLgAFFAQJDgAJAAATAA==.',
['寒气']='寒气:BAAALgADCgMJAwAAAA==.',
['小名']='小名叫大力:BAAALgAECgMJBQAAAA==.',
['小小']='小小愿望:BAEALgAECgkJCQABLgAFFAYJEgAEAMoiAA==.',
['小泽']='小泽马菲特:BAAALgAECgcJCQAAAA==.',
['小溪']='小溪流快回来:BAAALgAECgMJBAAAAA==.',
['小猎']='小猎很可爱:BAABLgAECn8UAAMBAAcJFBsHKwAJAgABAAYJDRsHKwAJAgACAAQJrBizVgDtAAAAAA==.',
['小疯']='小疯仔:BAAALgAECgYJBgAAAA==.',
['小蜂']='小蜂子:BAAALgAFFAEJAgAAAA==.',
['小龙']='小龙龙:BAAALgADCgcJBwAAAA==.',
['少女']='少女之手:BAAALgAECgYJCgAAAA==.',
['就扯']='就扯:BAAALgAECgUJAgAAAA==.',
['希影']='希影:BAAALgAECgMJAwAAAA==.希影乀:BAAALgAFFAEJAQAAAA==.',
['年华']='年华弹指间:BAAALgAECgQJDgAAAA==.',
['幻龙']='幻龙破苍穹:BAAALgAECgMJAwAAAA==.',
['廵警']='廵警:BAAALgAECgMJAwAAAA==.',
['弥小']='弥小猫:BAAALgAECgIJAwAAAA==.',
['心弦']='心弦乄梦:BAAALgAECgQJAQAAAA==.',
['恃酒']='恃酒而歌:BAAALgAECgIJAgAAAA==.',
['恶毒']='恶毒的心灵:BAAALgADCgcJBwAAAA==.',
['恶灵']='恶灵:BAAALgAFFAMJBAAAAA==.',
['惡丶']='惡丶:BAAALgAECgEJAQAAAA==.',
['惩戒']='惩戒:BAAALgAECgQJBAAAAA==.',
['惬意']='惬意由心丶:BAAALgADCgEJAQAAAA==.',
['慕兮']='慕兮:BAAALgAECgMJAwAAAA==.',
['慷慨']='慷慨激昂:BAABLgAECn8ZAAIBAAcJZySnCwDlAgABAAcJZySnCwDlAgAAAA==.',
['憨豆']='憨豆的畅想:BAAALgAECgUJBQAAAA==.',
['我不']='我不需要毒药:BAAALgAECgEJAQAAAA==.',
['我是']='我是小牛牛:BAAALgAECgYJDAAAAA==.',
['战神']='战神七斤:BAAALgAECgIJAgAAAA==.',
['戰熊']='戰熊:BAAALgAECgQJBAAAAA==.',
['手动']='手动打木桩:BAAALgAECgYJBwAAAA==.',
['折刃']='折刃沉水丶:BAAALgAECgEJAQAAAA==.',
['损友']='损友:BAAALgAECgcJBwAAAA==.',
['故漓']='故漓:BAAALgAECgMJBAAAAA==.',
['斩风']='斩风:BAAALgAECgEJAQABLgAFFAQJCgAEAJIGAA==.',
['断风']='断风尘:BAACLgAFFH8HAAMSAAQJLQptGwCVAAASAAMJagdtGwCVAAATAAIJKwqNAQBYAAAuAAQKfx4ABBMABwnuIagFAA4CABMABgk4IqgFAA4CABIABwkUHfxOANsBABEAAQlmE05oAEAAAAAA.',
['无极']='无极魔:BAAALgAECgEJAQAAAA==.',
['星光']='星光绒喵:BAAALgAECgEJAgAAAA==.',
['星璨']='星璨:BAAALgADCgQJBQAAAA==.',
['晓疯']='晓疯子:BAAALgAECgYJDwAAAA==.',
['晓赫']='晓赫:BAAALgAECgQJBwAAAA==.',
['暴怒']='暴怒:BAAALgAECgkJCQAAAA==.暴怒斩杀:BAABLgAECn8VAAMUAAcJ3R8xFgCbAgAUAAcJ3R8xFgCbAgAVAAEJewr+SwAlAAAAAA==.',
['朝谒']='朝谒:BAABLgAFFH8HAAMNAAUJhyJtAgD5AQANAAUJhyJtAgD5AQAJAAIJXQceGwCUAAABLgAFFAYJAwAWAAAAAA==.',
['木生']='木生水:BAACLgAFFH8IAAIVAAIJ7QTSDQBtAAAVAAIJ7QTSDQBtAAAuAAQKfzkABBUACAmoE9QSANwBABUACAmoE9QSANwBABQAAQkVBSGtAC8AABcAAQkACIpEAC8AAAAA.',
['朮學']='朮學老師:BAAALgAECgEJAgAAAA==.',
['朱厌']='朱厌:BAACLgAFFH8FAAIFAAMJQxVyFAAFAQAFAAMJQxVyFAAFAQAuAAQKfxUAAgUABwlPIe0hAKICAAUABwlPIe0hAKICAAAA.',
['机智']='机智的呆呆兽:BAAALgAFFAMJAwAAAA==.',
['杰克']='杰克斯:BAAALgAECgYJBwAAAA==.',
['林北']='林北骑士:BAAALgADCgMJAwAAAA==.',
['林子']='林子:BAAALgAECgEJAQABLgAFFAUJBAAWAAAAAA==.',
['果壳']='果壳:BAABLgAECn8UAAIYAAcJsBOQNgCpAQAYAAcJsBOQNgCpAQAAAA==.',
['梦染']='梦染白夜:BAAALgADCgEJAQAAAA==.',
['梦魇']='梦魇之翼:BAAALgAECgEJAwAAAA==.',
['梵音']='梵音若梦:BAAALgAECgcJEAAAAA==.',
['森海']='森海飞霞:BAAALgAFFAIJAwAAAA==.',
['楠枫']='楠枫莯:BAAALgAECgUJBgAAAA==.',
['檸檬']='檸檬沙拉:BAABLgAFFH8FAAIIAAUJoBWfAQCpAQAIAAUJoBWfAQCpAQAAAA==.',
['武状']='武状元:BAABLgAECn8bAAMBAAgJDxMDMQDsAQABAAgJDxMDMQDsAQACAAYJ/Ai8WADiAAAAAA==.',
['歪瑞']='歪瑞奈斯:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡一怼:BAAALgAECgMJAwAAAA==.',
['残夜']='残夜冥:BAABLgAFFH8GAAMSAAQJWgz/IgD4AAASAAMJsg7/IgD4AAATAAEJUgUUBwBMAAAAAA==.',
['毁灭']='毁灭之握:BAAALgAECgMJAwAAAA==.',
['氵木']='氵木子告魔彡:BAAALgAECgMJBgAAAA==.',
['汤小']='汤小圆:BAAALgAECgQJCQAAAA==.',
['沉默']='沉默的牧師:BAAALgAECgcJCAAAAA==.',
['沙漏']='沙漏:BAAALgAECgMJAwAAAA==.',
['没有']='没有肉:BAAALgADCgcJBwAAAA==.没有肉肉:BAAALgAECgIJAgABLgAFFAIJBAAWAAAAAA==.',
['没那']='没那么难忘:BAAALgAECgIJAgAAAA==.',
['河蟹']='河蟹橘:BAAALgADCgcJCgAAAA==.',
['沸腾']='沸腾的小蚂蚁:BAABLgAECn8XAAIGAAcJ5B9nMQByAgAGAAcJ5B9nMQByAgAAAA==.',
['油菜']='油菜花大菜子:BAAALgAECgYJBwAAAA==.',
['洪荒']='洪荒丶恋空:BAAALgAECgcJBgAAAA==.',
['洵妍']='洵妍:BAAALgAECgQJBgAAAA==.',
['流星']='流星能飞多久:BAAALgAECgIJBAAAAA==.',
['流萤']='流萤:BAABLgAFFH8JAAIZAAUJ9SJIBgCCAQAZAAUJ9SJIBgCCAQABLgAFFAUJDgAZAKMmAA==.',
['海贼']='海贼王之俊:BAAALgAECgYJBwAAAA==.',
['淡水']='淡水:BAAALgAFFAEJAQAAAA==.',
['淡泊']='淡泊:BAAALgAECgQJDAAAAA==.',
['灵汐']='灵汐雪:BAACLgAFFH8GAAMSAAMJkw4uNACqAAASAAIJ8BIuNACqAAATAAEJ2QUKBwBNAAAuAAQKfxoAAxMACAnCFy4JALMBABIACAkCFodIAPEBABMABglAGi4JALMBAAAA.',
['炉默']='炉默默:BAAALgADCgMJAwAAAA==.',
['烈焰']='烈焰冰霜:BAAALgADCgUJBQAAAA==.烈焰火鬼:BAAALgAECgYJCgAAAA==.烈焰灬灼心:BAAALgAFFAIJAgAAAA==.',
['烟头']='烟头:BAAALgAECgIJAgAAAA==.',
['烤鸭']='烤鸭帮小妹:BAAALgAECgIJAgAAAA==.',
['焉知']='焉知子非鱼:BAAALgAECgEJAQAAAA==.',
['焦糖']='焦糖玛琪朵:BAAALgAECgIJAwAAAA==.',
['然然']='然然很听话:BAAALgAECgkJCQAAAA==.',
['燃烧']='燃烧的狒狒:BAAALgAECgUJBQAAAA==.',
['爆头']='爆头专家:BAAALgAECgQJBQAAAA==.',
['爱丽']='爱丽丝塔萨:BAAALgADCgUJBQAAAA==.',
['爱吃']='爱吃炒肝:BAAALgAECgUJBAAAAA==.',
['牛霸']='牛霸儿灬:BAAALgADCgcJBwAAAA==.',
['牛黄']='牛黄豆:BAAALgAECgcJEgAAAA==.',
['牧丝']='牧丝会二段跳:BAAALgADCgUJBQAAAA==.',
['狗丨']='狗丨萨:BAAALgAECgYJBwAAAA==.',
['狗灬']='狗灬黑骑:BAAALgAFFAIJAwAAAA==.',
['猎神']='猎神二黑:BAAALgAECgEJAgAAAA==.',
['猎魔']='猎魔恶手:BAABLgAECn8VAAIaAAcJFxIrIAC8AQAaAAcJFxIrIAC8AQAAAA==.',
['珍惜']='珍惜這段情:BAAALgAECgEJAQAAAA==.',
['疯中']='疯中追风:BAACLgAFFH8OAAIJAAQJABM8CwBEAQAJAAQJABM8CwBEAQAuAAQKfyUAAgkACAlVICEIAPYCAAkACAlVICEIAPYCAAAA.',
['白如']='白如冰呀:BAAALgAECgIJAwAAAA==.',
['白胡']='白胡子亨特:BAAALgADCgIJAgAAAA==.',
['百合']='百合菡萏:BAAALgADCgIJAgAAAA==.',
['盒子']='盒子:BAAALgAECgYJBwAAAA==.',
['盘丝']='盘丝灬大仙:BAAALgAECgYJBgAAAA==.',
['眯澜']='眯澜:BAAALgAECgEJAQAAAA==.',
['离若']='离若:BAAALgADCgcJCQAAAA==.',
['秦始']='秦始皇二一四:BAAALgADCgEJAQABLgAECgkJFgAbACUdAA==.',
['穷途']='穷途:BAAALgAECgQJBAAAAA==.',
['章若']='章若楠:BAABLgAECn8aAAIEAAgJcyEQKADSAgAEAAgJcyEQKADSAgABLgAFFAMJBwAJADQKAA==.',
['竹晴']='竹晴寻:BAABLgAECn8UAAIIAAcJ3B0uEgBPAgAIAAcJ3B0uEgBPAgAAAA==.',
['笑二']='笑二号:BAAALgAFFAQJBAAAAA==.',
['笑笑']='笑笑一:BAAALgAFFAQJBAAAAA==.笑笑七:BAAALgAFFAQJAgAAAA==.笑笑乐:BAABLgAFFH8FAAIRAAUJ+BEAAgCtAQARAAUJ+BEAAgCtAQAAAA==.笑笑五:BAAALgAFFAQJBAAAAA==.笑笑六:BAABLgAFFH8GAAMRAAUJchcZBwAAAQARAAMJkBMZBwAAAQASAAMJqBglIgBaAAAAAA==.笑笑四:BAAALgAFFAQJBAAAAA==.',
['第一']='第一杯可乐:BAAALgADCgEJAQAAAA==.第一杯奶茶:BAAALgAECgUJBgAAAA==.',
['粮票']='粮票的故事:BAAALgAECgkJCQAAAA==.',
['紫女']='紫女:BAAALgAECgEJAQAAAA==.',
['綠皮']='綠皮兒法師:BAAALgADCgYJBgAAAA==.',
['繁华']='繁华灬绚丽:BAAALgADCgEJAQAAAA==.',
['纯爱']='纯爱战神在此:BAAALgADCgMJAwAAAA==.',
['细雨']='细雨无声:BAAALgAECgMJBwAAAA==.',
['维尔']='维尔汀:BAAALgAFFAEJAQAAAA==.',
['维生']='维生素二细:BAAALgAECgQJCQAAAA==.',
['缺德']='缺德萨:BAAALgAECgYJCwAAAA==.',
['罪孽']='罪孽烙印:BAAALgAECgYJCQAAAA==.',
['老五']='老五:BAAALgAECgMJAwAAAA==.',
['聪明']='聪明的可达鸭:BAAALgAECgYJBgAAAA==.',
['肉嘟']='肉嘟嘟胖呼呼:BAAALgAECgIJAgAAAA==.',
['肥狗']='肥狗:BAABLgAECn8XAAIGAAcJsReYcwCgAQAGAAcJsReYcwCgAQAAAA==.',
['自由']='自由国死骑:BAAALgAECgcJBwABLgAFFAIJAgAWAAAAAA==.',
['良玉']='良玉:BAAALgAFFAEJAQAAAA==.',
['艾欧']='艾欧妮丝晨风:BAABLgAECn8VAAIFAAcJ7xnvTwDyAQAFAAcJ7xnvTwDyAQAAAA==.',
['芊蒽']='芊蒽守卫:BAAALgADCgYJBgAAAA==.',
['花殇']='花殇紫幽幽:BAAALgAECgYJEAAAAA==.',
['英语']='英语白老师:BAAALgADCgMJAwAAAA==.',
['茫然']='茫然的潜行者:BAAALgADCgYJBgAAAA==.',
['莫菲']='莫菲:BAACLgAFFH8HAAIHAAMJvwhBDwDbAAAHAAMJvwhBDwDbAAAuAAQKfxoAAgcABwkfFhwbAL4BAAcABwkfFhwbAL4BAAAA.',
['菡萏']='菡萏香:BAAALgAECgQJBgAAAA==.',
['菲狗']='菲狗:BAAALgAECgYJBgAAAA==.',
['萌有']='萌有萌的萌法:BAAALgAECgYJCAAAAA==.',
['萌萌']='萌萌哒小兔姬:BAACLgAFFH8NAAIGAAQJrhSKFQBNAQAGAAQJrhSKFQBNAQAuAAQKfx0AAgYABwneIfkmAKACAAYABwneIfkmAKACAAAA.',
['萧瑟']='萧瑟骑士:BAABLgAFFH8FAAIGAAIJRhb+EwC6AAAGAAIJRhb+EwC6AAABLgAFFAMJCAALAM0MAA==.',
['落花']='落花狼藉丷:BAAALgAFFAIJAwABLgAFFAQJBAAWAAAAAA==.',
['葬魂']='葬魂丷:BAAALgAECgQJBAAAAA==.',
['蓝眼']='蓝眼睛的糖糖:BAAALgAECgEJAQAAAA==.',
['蓝袍']='蓝袍:BAAALgADCgcJBwAAAA==.',
['蓬门']='蓬门为君开:BAABLgAECn8WAAIbAAgJJR2SFgCCAgAbAAgJJR2SFgCCAgAAAA==.',
['虫泡']='虫泡泡:BAAALgADCgYJBgAAAA==.',
['虫虫']='虫虫冲:BAAALgADCgEJAQAAAA==.',
['蛋塔']='蛋塔王子:BAAALgAFFAIJAgAAAA==.',
['要来']='要来一杯吗:BAAALgAECgIJBAAAAA==.',
['该死']='该死的猫:BAAALgAECgYJDAAAAA==.',
['请我']='请我食麦当劳:BAAALgAECgMJAwAAAA==.',
['谜之']='谜之真相:BAABLgAECn8eAAMFAAcJoiIpHwCxAgAFAAcJoiIpHwCxAgALAAUJdw/kXgABAQABLgAFFAYJEwAFAMggAA==.',
['豆到']='豆到碗里来:BAAALgAECgYJDQAAAA==.',
['贝勒']='贝勒爷:BAAALgAECgQJBgAAAA==.',
['贝多']='贝多奋:BAAALgAECgEJAQAAAA==.',
['躺会']='躺会别战复我:BAAALgADCgcJBwAAAA==.',
['躺赢']='躺赢:BAAALgAFFAIJAwAAAA==.',
['过叶']='过叶风:BAAALgAECgUJBwAAAA==.',
['迪奧']='迪奧布蘭度:BAAALgAFFAIJAwAAAA==.',
['逍遙']='逍遙哥哥:BAAALgAECgQJBAAAAA==.',
['那个']='那个傻慢:BAAALgAECgQJBgAAAA==.那个穆斯:BAAALgADCgEJAQAAAA==.',
['邪皇']='邪皇:BAABLgAFFH8FAAIaAAMJSxKkBQD/AAAaAAMJSxKkBQD/AAAAAA==.',
['郝小']='郝小萌:BAAALgAECgcJBwAAAA==.',
['酱香']='酱香脆皮鸡:BAAALgADCgUJBQAAAA==.',
['长相']='长相思:BAAALgAECgEJAQAAAA==.',
['開鈊']='開鈊小豬:BAAALgAECgQJBAAAAA==.',
['闲云']='闲云飘渺:BAACLgAFFH8PAAIVAAQJ0wqDBgD/AAAVAAQJ0wqDBgD/AAAuAAQKfyQAAhUABwk0H/MKAGECABUABwk0H/MKAGECAAAA.',
['闻之']='闻之悠悠烷纶:BAAALgAECgMJBQAAAA==.闻之残阳落日:BAAALgAECgYJCgAAAA==.闻之风卷残雲:BAAALgAECgUJDgAAAA==.',
['集合']='集合石大哥:BAAALgAFFAQJBAAAAA==.集合石大神:BAAALgAECgcJAQAAAA==.集合石菜鸟:BAAALgAFFAQJAwAAAA==.',
['雨中']='雨中的夜壶:BAAALgAECgEJAQAAAA==.',
['零慎']='零慎:BAAALgAECgEJAQAAAA==.',
['露娜']='露娜:BAAALgADCgUJBQAAAA==.',
['霸王']='霸王小花:BAAALgADCgIJAgAAAA==.',
['非我']='非我不可:BAAALgAECgkJDAAAAA==.',
['非狗']='非狗:BAABLgAECn8UAAIGAAgJdhIoWADpAQAGAAgJdhIoWADpAQAAAA==.',
['音无']='音无大鳯:BAAALgADCgMJAwAAAA==.',
['音速']='音速飞行:BAAALgAFFAEJAQAAAA==.',
['颜丶']='颜丶:BAAALgAECgIJBAAAAA==.',
['风舞']='风舞:BAACLgAFFH8KAAIcAAQJsRYUAQB2AQAcAAQJsRYUAQB2AQAuAAQKfyQAAhwABwllIiMFAL0CABwABwllIiMFAL0CAAAA.',
['风雷']='风雷火电:BAAALgAFFAIJBAAAAA==.',
['飞狗']='飞狗:BAAALgAECgcJBwAAAA==.',
['飞腿']='飞腿儿喵:BAACLgAFFH8GAAMQAAMJvwX9DQC/AAAQAAMJvwX9DQC/AAADAAEJlAkxJQBEAAAuAAQKfxgAAhAABwkqFtcfALcBABAABwkqFtcfALcBAAAA.',
['饼干']='饼干熊:BAAALgAFFAEJAgAAAA==.',
['驯兽']='驯兽大师:BAAALgAECgEJAgAAAA==.',
['骁老']='骁老豆:BAAALgAECgcJDQABLgAFFAMJBgAFAOcYAA==.',
['高圆']='高圆圆老公:BAAALgAECgQJBgAAAA==.',
['高坂']='高坂穗乃果:BAAALgAFFAIJBAAAAA==.',
['魔兽']='魔兽我最菜:BAABLgAFFH8FAAMHAAIJfAR/FgB4AAAHAAIJiAF/FgB4AAAIAAIJfATXEwBFAAAAAA==.',
['鸽王']='鸽王之王:BAAALgADCgEJAQAAAA==.',
['默逆']='默逆:BAAALgAECgYJBgAAAA==.',
['黯然']='黯然失落:BAACLgAFFH8NAAIOAAQJIxfxBwBoAQAOAAQJIxfxBwBoAQAuAAQKfxgAAg4ACAlXGt8NAMACAA4ACAlXGt8NAMACAAAA.',
['龙云']='龙云凤:BAACLgAFFH8IAAIBAAMJ5hmOCAAeAQABAAMJ5hmOCAAeAQAuAAQKfxgABAEACAnmGbUmAB8CAAEABwncGbUmAB8CAAIABQnqE7tLACIBABwABAkMFXgeAPQAAAAA.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
