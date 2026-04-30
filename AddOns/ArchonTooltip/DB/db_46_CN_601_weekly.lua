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

local lookup = {'DemonHunter-Havoc','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Shaman-Elemental','Shaman-Restoration','Evoker-Preservation','Evoker-Devastation','DemonHunter-Devourer','Warrior-Protection','Priest-Discipline','Priest-Holy','Monk-Windwalker','Monk-Brewmaster','Hunter-Survival','Unknown-Unknown','Paladin-Protection','Paladin-Retribution','DeathKnight-Blood','Druid-Balance',}
local provider = {region='CN',realm='卡珊德拉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Blast:BAAALgAECgYJDgAAAA==.',
Co='Colee:BAAALgADCgEJAQAAAA==.',
Cy='Cyanide:BAAALgAECgYJDwAAAA==.',
Da='Dannmm:BAABLgAECn8UAAIBAAYJFRLaJwCDAQABAAYJFRLaJwCDAQAAAA==.',
Ex='Extravaganza:BAAALgADCgEJAQAAAA==.',
Hl='Hlidskiaf:BAACLgAFFH8IAAICAAIJChxrLgC2AAACAAIJChxrLgC2AAAuAAQKfyAAAwMACQmdG9ggAE0BAAIABgk0GZFSANABAAMABAmhHNggAE0BAAAA.',
Na='Naoe:BAABLgAECn8ZAAQCAAcJ5CFYJQB9AgACAAcJnSFYJQB9AgAEAAIJOCFYBADHAAADAAIJeArnUwByAAAAAA==.',
Pu='Puxxymdf:BAAALgADCgcJBwAAAA==.',
Sp='Sparks:BAAALgADCgEJAQAAAA==.',
To='Touchgirl:BAAALgAECgUJBwAAAA==.',
Xi='Xianyua:BAACLgAFFH8GAAIFAAIJXgdBGACVAAAFAAIJXgdBGACVAAAuAAQKfxUAAwUACAmDDWAxAJgBAAUACAmDDWAxAJgBAAYABQkCGaw7AJMBAAAA.',
['书亦']='书亦烧仙草:BAAALgAFFAUJAwAAAA==.',
['光之']='光之律者:BAAALgAFFAQJBAAAAA==.',
['再战']='再战联盟:BAAALgAECgUJBQAAAA==.',
['刘铋']='刘铋诚:BAACLgAFFH8ZAAIHAAYJsSR0AACOAgAHAAYJsSR0AACOAgAuAAQKfx0AAwcACQnFIWEBAHQDAAcACQnFIWEBAHQDAAgAAwmmIJUjAAsBAAAA.',
['刺客']='刺客之刃:BAAALgAECgcJBwAAAA==.',
['哆一']='哆一点点:BAAALgAFFAIJAwAAAA==.',
['哒啦']='哒啦术术:BAABLgAECn8VAAMEAAcJdx5KBAA9AgAEAAcJ1x1KBAA9AgACAAUJXB3LcgB5AQAAAA==.哒啦沐沐:BAAALgAECgQJBgAAAA==.哒啦隆隆:BAAALgAECgEJAQAAAA==.',
['妖月']='妖月:BAAALgAFFAIJAgAAAA==.',
['孙荣']='孙荣锦:BAACLgAFFH8GAAIJAAIJwiJ2IADPAAAJAAIJwiJ2IADPAAAuAAQKfxoAAgkACQksHbIKAC0DAAkACQksHbIKAC0DAAAA.',
['學會']='學會忘记:BAAALgAFFAEJAQAAAA==.',
['宦海']='宦海帝国:BAAALgAECgQJBAAAAA==.',
['密雪']='密雪冰城:BAAALgAECgEJAQAAAA==.',
['小灬']='小灬萌德:BAAALgAECgUJBwAAAA==.',
['山罨']='山罨子:BAAALgAFFAMJAwAAAA==.',
['康忙']='康忙北鼻:BAAALgAECgYJBgAAAA==.',
['德艺']='德艺双馨:BAAALgAECgYJBgAAAA==.',
['忍尽']='忍尽藤:BAAALgAFFAEJAQAAAA==.',
['战四']='战四:BAABLgAFFH8GAAIKAAYJzQHFAwBNAQAKAAYJzQHFAwBNAQAAAA==.',
['扬州']='扬州炒饭:BAAALgAECgMJAwAAAA==.',
['拉布']='拉布拉多:BAAALgAECgYJDAAAAA==.',
['教练']='教练我想修仙:BAAALgAECgYJCgAAAA==.',
['望穿']='望穿秋水:BAAALgAFFAIJAgAAAA==.',
['某凡']='某凡的咸鱼:BAAALgADCgEJAQAAAA==.',
['桑克']='桑克瑞德:BAAALgADCgcJBwAAAA==.',
['欢娱']='欢娱:BAAALgAECgEJAQAAAA==.',
['欲望']='欲望作祟:BAAALgAECgEJAgAAAA==.',
['氵木']='氵木丶德:BAAALgADCgYJCwAAAA==.',
['灵魂']='灵魂共鸣:BAABLgAECn8XAAICAAcJaBorNQA3AgACAAcJaBorNQA3AgABLgAFFAUJDgALAMoKAA==.',
['炫个']='炫个骑丶:BAAALgAECgIJAgAAAA==.',
['炫四']='炫四彩丶:BAAALgAECgYJDgAAAA==.',
['烟丶']='烟丶花:BAABLgAFFH8GAAIMAAMJ8Q/KDACYAAAMAAMJ8Q/KDACYAAAAAA==.',
['热熔']='热熔白巧圣代:BAAALgAECgYJCQAAAA==.',
['玖六']='玖六:BAAALgAFFAEJAQAAAA==.玖六六:BAACLgAFFH8FAAINAAQJCA59CQDVAAANAAQJCA59CQDVAAAuAAQKfyEAAw0ACAkRItoHAPwCAA0ACAkpINoHAPwCAA4ABgnsICkbACsCAAAA.',
['甲辰']='甲辰骑:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂的老八:BAAALgAECgYJDwAAAA==.',
['白兮']='白兮兮丶:BAAALgAECgcJBwAAAA==.',
['瞳瞳']='瞳瞳犟丶:BAAALgAECgEJAQAAAA==.',
['空崎']='空崎日奈丶:BAAALgAECgUJBQABLgAFFAMJBwAPAHMSAA==.',
['粽弃']='粽弃疾:BAACLgAFFH8PAAMBAAQJJw99AwBPAQABAAQJJw99AwBPAQAJAAEJBgI/IQA9AAAuAAQKfxgAAwEABwnoEtInAIMBAAEABwknEtInAIMBAAkABglIDiaBACcBAAAA.',
['罗得']='罗得里格丝:BAAALgAECgYJEAAAAA==.',
['翱翔']='翱翔翎:BAAALgADCgIJAgABLgAECggJDAAQAAAAAA==.',
['芙莉']='芙莉德薇儿:BAAALgADCgMJAwAAAA==.芙莉德薇尔:BAABLgAECn8iAAMRAAYJlhszDgDhAQARAAYJlhszDgDhAQASAAYJ7w+7sgAeAQAAAA==.',
['菩提']='菩提小主:BAAALgAECgYJDQAAAA==.菩提尛祖:BAAALgAECgYJBgAAAA==.',
['蛋蛋']='蛋蛋王:BAAALgAECgkJBgABLgAFFAYJDAATABkYAA==.',
['血色']='血色蔓延:BAAALgAECgQJBAAAAA==.',
['豆包']='豆包:BAABLgAECn8cAAIGAAcJhxfYDQBiAQAGAAcJhxfYDQBiAQAAAA==.',
['超高']='超高校非酋:BAABLgAECn8cAAIUAAYJQhPKOABUAQAUAAYJQhPKOABUAQAAAA==.',
['这是']='这是自寻噬路:BAAALgADCgQJBAABLgAECgYJFAABABUSAA==.',
['野性']='野性之呼唤:BAAALgAFFAMJAwAAAA==.',
['闪点']='闪点:BAAALgAECgYJBgAAAA==.',
['闹闹']='闹闹卝鸿轩:BAAALgADCgcJBwAAAA==.',
['随心']='随心的风:BAAALgAFFAQJBAAAAA==.',
['难杀']='难杀:BAAALgADCgMJAwAAAA==.',
['风之']='风之律者:BAAALgAECgUJBQAAAA==.',
['鸿运']='鸿运当蛋:BAAALgAECgkJCQABLgAFFAUJDAACAK0mAA==.',
['黑暗']='黑暗灵魂:BAAALgAFFAEJAQAAAA==.',
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
