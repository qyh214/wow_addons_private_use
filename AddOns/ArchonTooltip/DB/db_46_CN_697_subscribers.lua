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

local lookup = {'Paladin-Holy','Monk-Mistweaver','Monk-Windwalker','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','DemonHunter-Devourer','Mage-Frost','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','DeathKnight-Blood','Druid-Guardian','Priest-Shadow','Warrior-Arms','Warrior-Fury','Warrior-Protection',}
local provider = {region='CN',realm='无尽之海',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Ap='Apoloxd:BAEALgAFFAIJAgABLgAFFAUJEwABAJ8gAA==.',
Cr='Create:BAEALgAECgcJCgAAAA==.',
De='Dejavumist:BAECLgAFFH8WAAICAAYJUyZFAABAAgZoDAAABQBjAGkMAAAFAGMAawwAAAMAWgBqDAAAAwBjAGwMAAABAGMA6gwAAAUAYwACAAYJUyZFAABAAgZoDAAABQBjAGkMAAAFAGMAawwAAAMAWgBqDAAAAwBjAGwMAAABAGMA6gwAAAUAYwAuAAQKfxsAAwIACQkSInMEACUDAAIACAllJHMEACUDAAMAAgl/DUtnAG8AAAAA.',
Mb='Mbeumo:BAEALgAECgkJCQABLgAFFAUJDQAEAHcfAA==.',
['一品']='一品布衣:BAECLgAFFH8MAAMFAAQJJyQ5CAA/AQRoDAAABABgAGkMAAADAGEAawwAAAEATgDqDAAABABiAAUAAwkLJjkIAD8BA2gMAAAEAGAAaQwAAAMAYQDqDAAABABiAAYAAQl9HtsQAF8AAWsMAAABAE4ALgAECn8TAAMGAAcJ1SSSGACGAQAFAAUJbSTVYQCkAQAGAAQJOSKSGACGAQAAAA==.',
['佐佐']='佐佐木咲恋:BAECLgAFFH8KAAIHAAUJEyGHCgCGAQVoDAAAAQBVAGkMAAACAFkAawwAAAMAUgBqDAAAAQBEAOoMAAADAFEABwAFCRMhhwoAhgEFaAwAAAEAVQBpDAAAAgBZAGsMAAADAFIAagwAAAEARADqDAAAAwBRAC4ABAp/IwACBwAICVwiyg4ACQMABwAICVwiyg4ACQMAAS4ABRQCCQgACACeJgA=.',
['圣光']='圣光闪不起:BAECLgAFFH8TAAIBAAUJnyDbAQDqAQVoDAAABQBdAGkMAAAFAEYAawwAAAMAWABqDAAAAgBbAOoMAAAEAEoAAQAFCZ8g2wEA6gEFaAwAAAUAXQBpDAAABQBGAGsMAAADAFgAagwAAAIAWwDqDAAABABKAC4ABAp/JQADAQAICZIl2AEAZAMAAQAICZIl2AEAZAMABAABCVIm10UAcAAAAAA=.',
['小牛']='小牛白幼原:BAEBLgAFFH8KAAMJAAMJMR8MEQDKAANoDAAABABbAGkMAAADAFUA6gwAAAMAPgAJAAIJjyIMEQDKAAJoDAAABABbAGkMAAADAFUACgABCaAMTyQASAAB6gwAAAMAIAAAAA==.',
['小罗']='小罗伯强:BAECLgAFFH8WAAMLAAcJ8hpHAACqAQdoDAAABABjAGkMAAAEAGMAawwAAAQAVwBqDAAAAwBiAGwMAAABABwAbQwAAAEABwDqDAAABQBbAAsABQnfJEcAAKoBBWgMAAAEAGMAaQwAAAQAYwBrDAAAAQBXAGoMAAABAGIA6gwAAAUAWwAMAAQJCQ4VDABZAQRrDAAAAwBHAGoMAAACAEsAbAwAAAEAHABtDAAAAQAHAC4ABAp/JAADCwAICbAluwIAagMACwAICbAluwIAagMADAAHCWEiDyAAIgIAAS4ABRQHCRYADQBAJAA=.',
['必有']='必有凶年:BAEBLgAECn8gAAIOAAgJ1CIQAwAxAwhoDAAABQBiAGkMAAAFAGIAawwAAAUAYwBqDAAABQBjAGwMAAAEAFoAbQwAAAIAXwDqDAAABQBiAG4MAAABACoADgAICdQiEAMAMQMIaAwAAAUAYgBpDAAABQBiAGsMAAAFAGMAagwAAAUAYwBsDAAABABaAG0MAAACAF8A6gwAAAUAYgBuDAAAAQAqAAEuAAUUAwkHAA8ADSEA.',
['快乐']='快乐小草:BAEALgADCgQJBAAAAA==.',
['恋综']='恋综男嘉宾:BAEALgAFFAQJBAAAAA==.',
['我是']='我是傻福:BAEALgAFFAQJBAABLgAFFAMJCgAJADEfAA==.',
['曰月']='曰月齐光:BAEBLgAFFH8HAAIPAAMJDSEAAgAfAQNoDAAAAwBcAGkMAAADAFkAawwAAAEARwAPAAMJDSEAAgAfAQNoDAAAAwBcAGkMAAADAFkAawwAAAEARwAAAA==.',
['毛佛']='毛佛爺:BAEALgAFFAIJBAAAAA==.',
['江水']='江水为竭:BAEBLgAECn8UAAIIAAYJIRUgnQCcAQZoDAAAAwAtAGkMAAADAC8AawwAAAMALwBqDAAABABLAGwMAAADAEYA6gwAAAQAPAAIAAYJIRUgnQCcAQZoDAAAAwAtAGkMAAADAC8AawwAAAMALwBqDAAABABLAGwMAAADAEYA6gwAAAQAPAAAAA==.',
['神漾']='神漾:BAEALgAECgEJAQABLgAFFAQJCQAQAPgaAA==.',
['羽翼']='羽翼栗子球丶:BAEBLgAFFH8KAAIHAAUJchH7BQBJAQVoDAAAAgAXAGkMAAACACMAawwAAAIAUgBqDAAAAgBHAOoMAAACACUABwAFCXIR+wUASQEFaAwAAAIAFwBpDAAAAgAjAGsMAAACAFIAagwAAAIARwDqDAAAAgAlAAEuAAUUAgkIAAgAniYA.',
['萧筱']='萧筱雯:BAECLgAFFH8SAAMRAAUJiCNsAAABAgVoDAAABABdAGkMAAAEAF8AawwAAAQAUwBqDAAAAgA4AOoMAAAEAFsAEQAFCYgjbAAAAQIFaAwAAAIAXQBpDAAAAgBfAGsMAAACAFMAagwAAAEAOADqDAAAAgBbABIABQl2HfEDALUBBWgMAAACAFsAaQwAAAIAUwBrDAAAAgBDAGoMAAABAA8A6gwAAAIAOwAuAAQKfxcAAxIACQmrHzkeAF4CABIABgngIzkeAF4CABMABAkqFuElAA8BAAAA.',
['闹爷']='闹爷丶:BAEBLgAFFH8GAAIKAAYJ1xS2AQD2AQZoDAAAAQAiAGkMAAABABEAagwAAAEAJABsDAAAAQBLAG0MAAABAFYA6gwAAAEARgAKAAYJ1xS2AQD2AQZoDAAAAQAiAGkMAAABABEAagwAAAEAJABsDAAAAQBLAG0MAAABAFYA6gwAAAEARgABLgAFFAgJIQAJAF4gAA==.',
['雪丁']='雪丁:BAECLgAFFH8WAAINAAcJQCQNAAD3AgdoDAAABABjAGkMAAAEAFsAawwAAAQAXwBqDAAAAwBjAGwMAAABAFsAbQwAAAEAUgDqDAAABQBgAA0ABwlAJA0AAPcCB2gMAAAEAGMAaQwAAAQAWwBrDAAABABfAGoMAAADAGMAbAwAAAEAWwBtDAAAAQBSAOoMAAAFAGAALgAECn8gAAINAAgJeCWoAwBWAwANAAgJeCWoAwBWAwAAAA==.',
['魔术']='魔术栗子球丶:BAEBLgAFFH8IAAIIAAIJniZXFQDeAAJoDAAABABjAOoMAAAEAGIACAACCZ4mVxUA3gACaAwAAAQAYwDqDAAABABiAAAA.',
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
