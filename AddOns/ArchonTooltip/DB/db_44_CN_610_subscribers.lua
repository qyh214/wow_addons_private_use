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
 local lookup = {'Evoker-Devastation','Priest-Discipline','Warrior-Protection','Warrior-Fury','Hunter-BeastMastery','Shaman-Elemental','Shaman-Restoration','DeathKnight-Frost','DeathKnight-Unholy','Hunter-Marksmanship','Paladin-Retribution',}; local provider = {region='CN',realm='回音山',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Ad='Adotburr:BAECLAAFFH8fAAIBAAYIZBqtBQDhAQY5DAAADABeADsMAAACAEwAOgwAAAsAXgA8DAAAAgAiADIMAAACABsAPQwAAAIATQABAAYIZBqtBQDhAQY5DAAADABeADsMAAACAEwAOgwAAAsAXgA8DAAAAgAiADIMAAACABsAPQwAAAIATQAsAAQKf2gAAgEACAj5JZoBAHIDAAEACAj5JZoBAHIDAAAA.',Ka='Kanielle:BAEBLAAFFH8IAAICAAgIuABcBACGAAg5DAAAAQABADsMAAABAAEAOgwAAAEAAAA8DAAAAQAFADIMAAABAAUAPQwAAAEAAQA+DAAAAQAAAD8MAAABAAAAAgAICLgAXAQAhgAIOQwAAAEAAQA7DAAAAQABADoMAAABAAAAPAwAAAEABQAyDAAAAQAFAD0MAAABAAEAPgwAAAEAAAA/DAAAAQAAAAAA.',Ph='Philiph:BAEALAAECgYIDAABLAAFFAYIHwABAGQaAA==.',['丷爱']='丷爱乄内人丷:BAECLAAFFH8QAAIDAAYI/gcSGADyAAY5DAAABgAzADsMAAABAA0AOgwAAAYAEgA8DAAAAQAVADIMAAABAA4APQwAAAEAAwADAAYI/gcSGADyAAY5DAAABgAzADsMAAABAA0AOgwAAAYAEgA8DAAAAQAVADIMAAABAA4APQwAAAEAAwAsAAQKfxkAAwMABwhRFtMgAEEBAAMABwhRFtMgAEEBAAQAAwiiCG7mAI8AAAEsAAUUBgg1AAUAziMA.丷爱乄内助丷:BAECLAAFFH8eAAMGAAYIWhWXGQB3AQY5DAAACQBJADsMAAADAEIAOgwAAAkAPwA8DAAAAwA5ADIMAAADAA8APQwAAAMAMwAGAAYIWhWXGQB3AQY5DAAABwBJADsMAAADAEIAOgwAAAgAPwA8DAAAAwA5ADIMAAACAA8APQwAAAMAMwAHAAMIyQOqZwBZAAM5DAAAAgASADoMAAABAAYAMgwAAAEABAAsAAQKfxgAAwYABgjXG3JIAOUBAAYABgjXG3JIAOUBAAcABgiLDtC/AAUBAAEsAAUUBgg1AAUAziMA.丷爱乄妻子丷:BAECLAAFFH8gAAMIAAYIjRhtKQDzAAY5DAAACgBLADsMAAAFADMAOgwAAAoAVgA8DAAAAwA+ADIMAAABABQAPQwAAAMAUAAIAAYIjRhtKQDzAAY5DAAACQBLADsMAAAFADMAOgwAAAoAVgA8DAAAAwA+ADIMAAABABQAPQwAAAMAUAAJAAEI7QGaIAA+AAE5DAAAAQAEACwABAp/FAACCAAGCBogS5UA1wEACAAGCBogS5UA1wEAASwABRQGCDUABQDOIwA=.丷爱乄老婆丷:BAECLAAFFH81AAMFAAYIziN7DQAlAgY5DAAADQBfADsMAAAJAGIAOgwAAA0ATQA8DAAABwBXADIMAAAEAGEAPQwAAAcAXAAFAAYIziN7DQAlAgY5DAAACgBfADsMAAAJAGIAOgwAAAcATQA8DAAABgBXADIMAAACAGEAPQwAAAcAXAAKAAQINh+rCQAWAQQ5DAAAAwBRADoMAAAGAD8APAwAAAEAUgAyDAAAAgBbACwABAp/HwADBQAICCgklxoAYAIABQAICL4hlxoAYAIACgAGCBMiMzAABAIAAAA=.',['十二']='十二使徒:BAEBLAAFFH8JAAMIAAUIURuhUADoAAU5DAAAAwBXADsMAAABADEAOgwAAAMAVgAyDAAAAQAvAD0MAAABAE0ACAAECIsaoVAA6AAEOQwAAAMAVwA7DAAAAQAxADoMAAADAFYAMgwAAAEALwAJAAEIaB6pDwBWAAE9DAAAAQBNAAAA.',['小呆']='小呆立:BAEALAAECgYIEwABLAAECgcIFgALAKUhAA==.',['张大']='张大脑袋:BAECLAAFFH8XAAMFAAUIch/EKgDUAAU5DAAABgBaADsMAAAFAEAAOgwAAAYAUwA8DAAAAwBZAD0MAAADAEoABQAFCHIfxCoA1AAFOQwAAAYAWgA7DAAABQBAADoMAAAFAFMAPAwAAAMAWQA9DAAAAwBKAAoAAQhbCXQ3ADkAAToMAAABABcALAAECn9JAAMFAAgIJyXCCgDMAgAFAAgIJyXCCgDMAgAKAAcIRRmKNQDoAQAAAA==.',['毛不']='毛不停蹄:BAEBLAAFFH8GAAIFAAYI2RDWPQBUAQY5DAAAAQAzADsMAAABABgAOgwAAAEANgA8DAAAAQAnADIMAAABADYAPQwAAAEAIgAFAAYI2RDWPQBUAQY5DAAAAQAzADsMAAABABgAOgwAAAEANgA8DAAAAQAnADIMAAABADYAPQwAAAEAIgAAAA==.',['毛醒']='毛醒时分:BAEALAAECggIDQABLAAFFAgIBgAFANkQAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end