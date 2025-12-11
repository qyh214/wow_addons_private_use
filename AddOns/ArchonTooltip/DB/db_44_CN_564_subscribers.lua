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
 local lookup = {'Rogue-Subtlety','Druid-Restoration','Paladin-Holy','Priest-Holy','Evoker-Preservation','Shaman-Restoration','Warrior-Protection','Hunter-Marksmanship','Mage-Frost','Mage-Arcane','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Unknown-Unknown',}; local provider = {region='CN',realm='主宰之剑',name='CN',type='subscribers',zone=44,date='2025-12-11',data={As='Asunao:BAEBLAAFFH8dAAIBAAYIDB/cBAC6AQY5DAAACQBZADsMAAAEAE0AOgwAAAkAYAA8DAAAAwBaADIMAAABADkAPQwAAAMAQQABAAYIDB/cBAC6AQY5DAAACQBZADsMAAAEAE0AOgwAAAkAYAA8DAAAAwBaADIMAAABADkAPQwAAAMAQQABLAAFFAYIJgACANolAA==.Asunaovo:BAEBLAAFFH8PAAIDAAMIriTRCgBGAQM5DAAABwBiADsMAAABAFQAOgwAAAcAYwADAAMIriTRCgBGAQM5DAAABwBiADsMAAABAFQAOgwAAAcAYwABLAAFFAYIJgACANolAA==.Asunaowo:BAEALAAFFAIIBAABLAAFFAYIJgACANolAA==.',Fa='Fatsloth:BAEBLAAFFH8MAAICAAMInBQwGADBAAM5DAAABQBAADsMAAACACoAOgwAAAUAMwACAAMInBQwGADBAAM5DAAABQBAADsMAAACACoAOgwAAAUAMwABLAAFFAYIGQAEAEoIAA==.',Li='Lieon:BAEALAADCgIIAgABLAAFFAMICAAFAOslAA==.',Me='Medisons:BAEBLAAFFH8ZAAIEAAYISgjdIABHAQY5DAAABwA1ADsMAAADABUAOgwAAAcAFQA8DAAAAwAFADIMAAACAAYAPQwAAAMAEwAEAAYISgjdIABHAQY5DAAABwA1ADsMAAADABUAOgwAAAcAFQA8DAAAAwAFADIMAAACAAYAPQwAAAMAEwAAAA==.',Mi='Mists:BAEALAAFFAIIBAABLAAFFAYIJgACANolAA==.Mistv:BAEBLAAFFH8GAAIEAAIIuSVwGQDgAAI5DAAAAwBiADoMAAADAF4ABAACCLklcBkA4AACOQwAAAMAYgA6DAAAAwBeAAEsAAUUBggmAAIA2iUA.Mistx:BAEBLAAFFH8RAAIGAAUIixx1DwBJAQU5DAAABgBjADsMAAADAFwAOgwAAAYAYQA8DAAAAQAlAD0MAAABACYABgAFCIscdQ8ASQEFOQwAAAYAYwA7DAAAAwBcADoMAAAGAGEAPAwAAAEAJQA9DAAAAQAmAAEsAAUUBggmAAIA2iUA.',Ni='Nintmarks:BAEALAAECgEIAQABLAAFFAMICAAFAOslAA==.Nioline:BAEALAAFFAEIAQABLAAFFAMICAAFAOslAA==.',So='Soulblast:BAEALAAECgYICwABLAAFFAYIGQAEAEoIAA==.',['三角']='三角志:BAEBLAAFFH8HAAIHAAUIwRiQEgA3AQU5DAAAAgBcADsMAAABADQAOgwAAAIAOwAyDAAAAQAZAD0MAAABAFcABwAFCMEYkBIANwEFOQwAAAIAXAA7DAAAAQA0ADoMAAACADsAMgwAAAEAGQA9DAAAAQBXAAAA.',['卢老']='卢老爺:BAEALAAFFAIIAgABLAAFFAgICgABANkYAA==.',['吸血']='吸血龙:BAEALAADCgYIDAABLAAFFAYIGAAFAO4hAA==.',['奥达']='奥达奇之怒:BAEALAAECgYIEgABLAAFFAgIDAAIAMwZAA==.',['寄生']='寄生龙:BAECLAAFFH8YAAIFAAYI7iEiBgAoAgY5DAAABgBiADsMAAAGAFMAOgwAAAYAVAA8DAAAAwBYADIMAAABAEcAPQwAAAIAXgAFAAYI7iEiBgAoAgY5DAAABgBiADsMAAAGAFMAOgwAAAYAVAA8DAAAAwBYADIMAAABAEcAPQwAAAIAXgAsAAQKfy8AAgUABwhnJNsHALkCAAUABwhnJNsHALkCAAAA.',['小处']='小处:BAEBLAAFFH8mAAICAAYI2iWCAwCRAgY5DAAACgBjADsMAAAGAGIAOgwAAAoAYwA8DAAABQBiADIMAAACAFoAPQwAAAUAXQACAAYI2iWCAwCRAgY5DAAACgBjADsMAAAGAGIAOgwAAAoAYwA8DAAABQBiADIMAAACAFoAPQwAAAUAXQAAAA==.',['尘枫']='尘枫墨言:BAEALAAECgMIAwABLAAFFAgIDAAIAMwZAA==.',['希希']='希希大魔王:BAEBLAAFFH8KAAIBAAYI2RhmBQCmAQY5DAAAAwBTADsMAAABAEQAOgwAAAMAKAA8DAAAAQA9ADIMAAABADoAPQwAAAEARQABAAYI2RhmBQCmAQY5DAAAAwBTADsMAAABAEQAOgwAAAMAKAA8DAAAAQA9ADIMAAABADoAPQwAAAEARQAAAA==.',['应欢']='应欢欢丶:BAEBLAAFFH8bAAMJAAYIBiN7BgDbAAY5DAAACABhADsMAAAFAE0AOgwAAAgAYAA8DAAAAwBiADIMAAABAE8APQwAAAIAWAAKAAYIeyIcFQDXAQY5DAAABgBhADsMAAAFAE0AOgwAAAYAWAA8DAAAAwBiADIMAAABAE8APQwAAAIAWAAJAAIIayV7BgDbAAI5DAAAAgBeADoMAAACAGAAASwABRQGCCYAAgDaJQA=.',['无敌']='无敌浩劫大王:BAEBLAAFFH8FAAILAAII7iD/JgDDAAI5DAAAAwBUADoMAAACAFQACwACCO4g/yYAwwACOQwAAAMAVAA6DAAAAgBUAAAA.',['曦曦']='曦曦大魔王:BAEALAAFFAYIBAABLAAFFAgICgABANkYAA==.',['杂环']='杂环卡宾:BAEBLAAECn8XAAQEAAYIhSJsKQBDAgY5DAAAAwBdADsMAAADAFsAOgwAAAUAYAA8DAAABQBVADIMAAAEAFgAPQwAAAMASQAEAAYIhSJsKQBDAgY5DAAAAwBdADsMAAADAFsAOgwAAAUAYAA8DAAABQBVADIMAAAEAFgAPQwAAAEASQAMAAEIQRPNOwA7AAE9DAAAAQAxAA0AAQgYCmCbADsAAT0MAAABABkAASwABRQDCAgABQDrJQA=.',['氩气']='氩气:BAECLAAFFH8OAAMOAAUIPB06IQAXAQU5DAAABABgADsMAAACAE4AOgwAAAQAWAA8DAAAAgAhAD0MAAACAE0ADgAFCDwdOiEAFwEFOQwAAAQAYAA7DAAAAgBOADoMAAADAFgAPAwAAAIAIQA9DAAAAgBNAA8AAQjcExMgAAAAAToMAAABADIALAAECn8UAAMOAAcI+R4wHgD3AQAOAAcI+R4wHgD3AQAQAAIIERe1LwB3AAABLAAFFAYIGAAFAO4hAA==.',['翼风']='翼风:BAEALAADCggICAAAAA==.',['聰明']='聰明的墨菲特:BAEALAAFFAIIAgABLAAFFAQIBAARAAAAAA==.',['言益']='言益:BAEALAAECggICQABLAAFFAMICAAFAOslAA==.',['言讷']='言讷:BAEALAAECggICAABLAAFFAMICAAFAOslAA==.',['超急']='超急大萌宝:BAECLAAFFH8xAAIEAAYI/BriBgDqAQY5DAAACwBXADsMAAAKAEYAOgwAAAoASQA8DAAACAA9ADIMAAADADIAPQwAAAcARwAEAAYI/BriBgDqAQY5DAAACwBXADsMAAAKAEYAOgwAAAoASQA8DAAACAA9ADIMAAADADIAPQwAAAcARwAsAAQKf1IAAwQACAhQJNwDACADAAQACAhQJNwDACADAAwAAwhAFT8lAL8AAAAA.',['超鸡']='超鸡大萌宝:BAEALAADCgQIBAABLAAFFAYIMQAEAPwaAA==.',['酸辣']='酸辣的土豆丝:BAEALAAFFAIIBAAAAA==.',['釷壕']='釷壕:BAEALAAFFAIIBAAAAA==.',['魔仙']='魔仙小月:BAEBLAAFFH8MAAIOAAUIoB3LLgBjAQU5DAAAAwBVADsMAAACAFcAOgwAAAMAPgA8DAAAAgA4AD0MAAACAFgADgAFCKAdyy4AYwEFOQwAAAMAVQA7DAAAAgBXADoMAAADAD4APAwAAAIAOAA9DAAAAgBYAAEsAAUUBggmAAIA2iUA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end