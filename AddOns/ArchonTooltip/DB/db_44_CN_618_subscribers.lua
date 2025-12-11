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
 local lookup = {'DeathKnight-Frost','Mage-Arcane','Rogue-Subtlety','DemonHunter-Havoc','Mage-Fire','Paladin-Protection','Paladin-Retribution','Warlock-Destruction','Evoker-Devastation','Druid-Balance','Druid-Restoration','Priest-Holy','Priest-Shadow','Evoker-Preservation','Hunter-BeastMastery',}; local provider = {region='CN',realm='埃德萨拉',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Bl='Bloodsky:BAEBLAAFFH8TAAIBAAYIXRxICAAjAgY5DAAABgBdADsMAAACAFQAOgwAAAYAYQA8DAAAAgBDADIMAAABACgAPQwAAAIANAABAAYIXRxICAAjAgY5DAAABgBdADsMAAACAFQAOgwAAAYAYQA8DAAAAgBDADIMAAABACgAPQwAAAIANAAAAA==.',['东北']='东北奥利奥:BAEALAAECgYIBgABLAAFFAYIEAACADQTAA==.',['丨万']='丨万万丨:BAEALAAFFAIIAgABLAAFFAgICgADANkYAA==.',['如影']='如影丶:BAEBLAAFFH8IAAIEAAYIEgpZMgAKAQY5DAAAAgA9ADsMAAABABQAOgwAAAIAOQA8DAAAAQACADIMAAABAAIAPQwAAAEACQAEAAYIEgpZMgAKAQY5DAAAAgA9ADsMAAABABQAOgwAAAIAOQA8DAAAAQACADIMAAABAAIAPQwAAAEACQABLAAFFAYIEAACADQTAA==.',['布里']='布里塔利亚:BAEBLAAFFH8QAAMCAAYINBPjFQC1AQY5DAAABgBOADsMAAABADQAOgwAAAYAXwA8DAAAAQAvADIMAAABAAIAPQwAAAEAEQACAAUI2RbjFQC1AQU5DAAABgBOADsMAAABADQAOgwAAAYAXwA8DAAAAQAvAD0MAAABABEABQABCPkAYw4AOwABMgwAAAEAAgAAAA==.',['意无']='意无求:BAEBLAAFFH8OAAMGAAYIlg6aCwC5AAY5DAAABQBdADsMAAABAAQAOgwAAAUAXwA8DAAAAQAOADIMAAABAAsAPQwAAAEABAAHAAYIfQVUMQAFAQY5DAAAAQAPADsMAAABAAQAOgwAAAEAIQA8DAAAAQAOADIMAAABAAsAPQwAAAEABAAGAAII6ySaCwC5AAI5DAAABABdADoMAAAEAF8AASwABRQGCBAAAgA0EwA=.',['收拾']='收拾你的细软:BAEALAAFFAIIAgABLAAFFAYIEAACADQTAA==.',['昕风']='昕风:BAECLAAFFH8vAAIIAAcIzhrhEQAHAgc5DAAACgBYADsMAAAKAFUAOgwAAAoAVwA8DAAABgA8ADIMAAAEACAAPQwAAAYAUwA+DAAAAQArAAgABwjOGuERAAcCBzkMAAAKAFgAOwwAAAoAVQA6DAAACgBXADwMAAAGADwAMgwAAAQAIAA9DAAABgBTAD4MAAABACsALAAECn8VAAIIAAYIESGVQwAsAgAIAAYIESGVQwAsAgABLAAFFAgIOwAJABgfAA==.',['未闻']='未闻花名:BAEALAADCgEIAQABLAAFFAYIEAACADQTAA==.',['狂暴']='狂暴野猫:BAECLAAFFH8QAAMKAAYIMhPWEgBWAQY5DAAABgAwADsMAAABAD4AOgwAAAYAMwA8DAAAAQA6ADIMAAABADMAPQwAAAEAFgAKAAYIMhPWEgBWAQY5DAAAAQAwADsMAAABAD4AOgwAAAEAMwA8DAAAAQA6ADIMAAABADMAPQwAAAEAFgALAAIIGx9/IwCYAAI5DAAABQBRADoMAAAFAE0ALAAECn8bAAMLAAYIYBO8aQBXAQALAAYIYBO8aQBXAQAKAAEInhWcXwBBAAABLAAFFAYIEAACADQTAA==.',['空想']='空想之月:BAEBLAAFFH8hAAMMAAYIqx3jEQDRAQY5DAAACABTADsMAAAHAE4AOgwAAAgAWgA8DAAABABGADIMAAACADAAPQwAAAQAUwAMAAYIqx3jEQDRAQY5DAAABwBTADsMAAAGAE4AOgwAAAcAWgA8DAAAAwBGADIMAAACADAAPQwAAAQAUwANAAQIYwbCIACHAAQ5DAAAAQAHADsMAAABAAQAOgwAAAEAKwA8DAAAAQAJAAAA.',['缘宝']='缘宝丷:BAEBLAAFFH8IAAMOAAYItQcREgAEAQY5DAAAAQAPADsMAAABABUAOgwAAAEAGgA8DAAAAQAEADIMAAACACkAPQwAAAIACAAOAAUI5AgREgAEAQU5DAAAAQAPADsMAAABABUAOgwAAAEAGgAyDAAAAgApAD0MAAABAAgACQACCPMGnx0ARAACPAwAAAEAIAA9DAAAAQACAAEsAAUUCAhJAA4A6SIA.',['茶理']='茶理理子丶丨:BAEBLAAFFH8WAAIPAAYI2hNJPQBVAQY5DAAABwBQADsMAAACACMAOgwAAAcAWwA8DAAAAgBDADIMAAACAAoAPQwAAAIAEwAPAAYI2hNJPQBVAQY5DAAABwBQADsMAAACACMAOgwAAAcAWwA8DAAAAgBDADIMAAACAAoAPQwAAAIAEwABLAAFFAYIEAACADQTAA==.',['蒜荣']='蒜荣荣:BAEALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end