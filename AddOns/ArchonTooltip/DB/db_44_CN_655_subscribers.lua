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
 local lookup = {'Shaman-Restoration','Unknown-Unknown','Druid-Restoration','DeathKnight-Blood','Monk-Brewmaster','Warrior-Fury','DeathKnight-Frost','Hunter-BeastMastery','Warlock-Destruction','Druid-Guardian','Monk-Mistweaver','Evoker-Preservation','Hunter-Marksmanship','Warrior-Protection','Paladin-Protection','Paladin-Retribution','Priest-Holy','Priest-Shadow','Druid-Balance',}; local provider = {region='CN',realm='安苏',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Ko='Komplexe:BAEALAAFFAIIAgABLAAFFAQICgABAA0UAA==.',Ri='Riffrain:BAEALAAFFAIIAgABLAAFFAQICgABAA0UAA==.',St='Stigmata:BAEALAAECgYIBQABLAAFFAQICgABAA0UAA==.',Um='Umbrasword:BAEALAADCgcIBwABLAAECgMIAwACAAAAAA==.',['乄油']='乄油瞪子:BAEALAAECggIDgAAAA==.',['偷摸']='偷摸零:BAEALAAECgYIBgABLAAFFAIIAgACAAAAAA==.',['叶梦']='叶梦璇:BAEALAAECgMIAwABLAAFFAYIEgADAF8NAA==.',['哀霜']='哀霜之拥:BAECLAAFFH8fAAIEAAYIPBNzCgByAQY5DAAACwBOADsMAAAGAFYAOgwAAAkAMgA8DAAAAgAaADIMAAABAB4APQwAAAIAFwAEAAYIPBNzCgByAQY5DAAACwBOADsMAAAGAFYAOgwAAAkAMgA8DAAAAgAaADIMAAABAB4APQwAAAIAFwAsAAQKfyIAAgQACAjAHyUFAG8CAAQACAjAHyUFAG8CAAEsAAUUBwgdAAUADhEA.',['姬野']='姬野星奏:BAEALAADCggIDgABLAAFFAQICgABAA0UAA==.',['想尝']='想尝千钧一发:BAECLAAFFH8aAAIFAAYIGxAbEABOAQY5DAAACAA0ADsMAAADABMAOgwAAAYAHwA8DAAAAwA0ADIMAAACACgAPQwAAAQAMgAFAAYIGxAbEABOAQY5DAAACAA0ADsMAAADABMAOgwAAAYAHwA8DAAAAwA0ADIMAAACACgAPQwAAAQAMgAsAAQKfxcAAgUACAgzDjcTABYBAAUACAgzDjcTABYBAAEsAAUUBwgdAAUADhEA.',['永凌']='永凌啊:BAEALAAFFAIIAgAAAA==.',['洗内']='洗内一吗:BAECLAAFFH8ZAAIGAAUICBgzJABTAQU5DAAACABNADsMAAAFAD8AOgwAAAkAUgA8DAAAAgAyAD0MAAABACAABgAFCAgYMyQAUwEFOQwAAAgATQA7DAAABQA/ADoMAAAJAFIAPAwAAAIAMgA9DAAAAQAgACwABAp/LgACBgAICA8cuS4AfgIABgAICA8cuS4AfgIAAAA=.洗内一吧:BAEBLAAFFH8NAAIHAAMIbROAYwCKAAM5DAAABAArADsMAAAEACkAOgwAAAUAQAAHAAMIbROAYwCKAAM5DAAABAArADsMAAAEACkAOgwAAAUAQAABLAAFFAUIGQAGAAgYAA==.洗内一噻:BAECLAAFFH8OAAIIAAMIzBMrdQB8AAM5DAAABgAwADsMAAACABEAOgwAAAYAVgAIAAMIzBMrdQB8AAM5DAAABgAwADsMAAACABEAOgwAAAYAVgAsAAQKfxcAAggACAgNIOcYAGoCAAgACAgNIOcYAGoCAAEsAAUUBQgZAAYACBgA.洗内一鸭:BAEBLAAFFH8OAAIJAAQIthWzQgDjAAQ5DAAABQA4ADsMAAACAD8AOgwAAAUAPwA8DAAAAgAmAAkABAi2FbNCAOMABDkMAAAFADgAOwwAAAIAPwA6DAAABQA/ADwMAAACACYAASwABRQFCBkABgAIGAA=.',['熊熊']='熊熊凶:BAEBLAAFFH8HAAMDAAIIMQ71SABfAAI5DAAABAAhADoMAAADACYAAwACCDEO9UgAXwACOQwAAAEAIQA6DAAAAQAmAAoAAgh8AeYSABYAAjkMAAADAAQAOgwAAAIAAwABLAAFFAcIHQAFAA4RAA==.',['熊猫']='熊猫大仙丫:BAECLAAFFH8dAAIFAAcIDhFMCwCWAQc5DAAACgBOADsMAAAGADUAOgwAAAkAUQA8DAAAAQAIADIMAAABACcAPQwAAAEAKAA+DAAAAQADAAUABwgOEUwLAJYBBzkMAAAKAE4AOwwAAAYANQA6DAAACQBRADwMAAABAAgAMgwAAAEAJwA9DAAAAQAoAD4MAAABAAMALAAECn8nAAMFAAgI1RZTFwD5AQAFAAgI1RZTFwD5AQALAAMIzwBfWgAZAAAAAA==.',['牛奶']='牛奶草莓:BAEALAAECgYIBgABLAAFFAIIBAACAAAAAA==.',['真理']='真理与自由:BAEBLAAFFH8OAAIMAAUI3w4nDwBLAQU5DAAABABOADsMAAACAAkAOgwAAAQAVAA8DAAAAgAJAD0MAAACAAgADAAFCN8OJw8ASwEFOQwAAAQATgA7DAAAAgAJADoMAAAEAFQAPAwAAAIACQA9DAAAAgAIAAEsAAUUBwgdAAUADhEA.',['绿尸']='绿尸寒:BAEALAAECgIIAQAAAA==.',['胡行']='胡行夜班:BAEBLAAFFH8MAAMNAAIIjwIYHQAgAAI5DAAABgAJADoMAAAGAAMACAACCGoCecAAKgACOQwAAAQACQA6DAAABAACAA0AAgjCARgdACAAAjkMAAACAAUAOgwAAAIAAwABLAAFFAcIHQAFAA4RAA==.',['胸小']='胸小无脑:BAEALAAECgMIAwAAAA==.',['自由']='自由与真理:BAEBLAAFFH8SAAIFAAUIDQdUFgDYAAU5DAAABQArADsMAAAEAAwAOgwAAAUADgA8DAAAAwAIAD0MAAABAAoABQAFCA0HVBYA2AAFOQwAAAUAKwA7DAAABAAMADoMAAAFAA4APAwAAAMACAA9DAAAAQAKAAEsAAUUBwgdAAUADhEA.',['花影']='花影成双:BAEALAAFFAIIAgABLAAFFAQIBAACAAAAAA==.',['苍穹']='苍穹之战:BAEBLAAFFH8RAAIOAAYI6QZtGADuAAY5DAAABgAaADsMAAADAAcAOgwAAAUAFwA8DAAAAQAYADIMAAABAA4APQwAAAEACQAOAAYI6QZtGADuAAY5DAAABgAaADsMAAADAAcAOgwAAAUAFwA8DAAAAQAYADIMAAABAA4APQwAAAEACQABLAAFFAcIHQAFAA4RAA==.苍穹的明证:BAECLAAFFH8RAAIPAAMInQHvGwAzAAM5DAAACQAEADsMAAABAAQAOgwAAAcAAwAPAAMInQHvGwAzAAM5DAAACQAEADsMAAABAAQAOgwAAAcAAwAsAAQKfxQAAw8ABwjBA/1gAJEAAA8ABwiNAv1gAJEAABAABQhhA+RPAZAAAAEsAAUUBwgdAAUADhEA.苍穹的糖门:BAECLAAFFH8KAAIJAAUI7gtEPgANAQU5DAAAAwAzADsMAAACACEAOgwAAAMALAA8DAAAAQAPAD0MAAABAAgACQAFCO4LRD4ADQEFOQwAAAMAMwA7DAAAAgAhADoMAAADACwAPAwAAAEADwA9DAAAAQAIACwABAp/NQACCQAICMsclxIAVAIACQAICMsclxIAVAIAASwABRQHCB0ABQAOEQA=.苍穹的萨满:BAEBLAAFFH8GAAIBAAII2QB0gAAoAAI5DAAAAwACADoMAAADAAEAAQACCNkAdIAAKAACOQwAAAMAAgA6DAAAAwABAAEsAAUUBwgdAAUADhEA.苍穹的证明:BAECLAAFFH8jAAIRAAYIvximEwDAAQY5DAAACQBLADsMAAAFAC8AOgwAAAkAVAA8DAAABQA6ADIMAAACAFAAPQwAAAUAIgARAAYIvximEwDAAQY5DAAACQBLADsMAAAFAC8AOgwAAAkAVAA8DAAABQA6ADIMAAACAFAAPQwAAAUAIgAsAAQKfxYAAxEABwiZD6RkAE4BABEABwiZD6RkAE4BABIAAQjfAYCmACIAAAEsAAUUBwgdAAUADhEA.',['要楽']='要楽奈:BAEALAAECgYIBgABLAAFFAIIAgACAAAAAA==.',['迷途']='迷途花海:BAEBLAAFFH8YAAIQAAYIMBqCCADeAQY5DAAABABXADsMAAAFAE8AOgwAAAYASAA8DAAABQBNADIMAAACADcAPQwAAAIAHQAQAAYIMBqCCADeAQY5DAAABABXADsMAAAFAE8AOgwAAAYASAA8DAAABQBNADIMAAACADcAPQwAAAIAHQAAAA==.',['麦兠']='麦兠兜:BAEBLAAFFH8HAAIGAAUIQBFmKAA0AQU5DAAAAQBHADsMAAABABQAOgwAAAEAPQA8DAAAAgArAD0MAAACABcABgAFCEARZigANAEFOQwAAAEARwA7DAAAAQAUADoMAAABAD0APAwAAAIAKwA9DAAAAgAXAAEsAAUUBggSAAMAXw0A.',['麦篼']='麦篼兜:BAEBLAAFFH8SAAMDAAYIXw3+IAAcAQY5DAAABAAyADsMAAADABsAOgwAAAUAOAA8DAAAAwANADIMAAABABAAPQwAAAIAKAADAAUIxQ7+IAAcAQU5DAAAAwAyADsMAAACABsAOgwAAAQAOAA8DAAAAgANAD0MAAABACgAEwAGCE0Dfh8AzwAGOQwAAAEACAA7DAAAAQAEADoMAAABABAAPAwAAAEABAAyDAAAAQAKAD0MAAABAAYAAAA=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end