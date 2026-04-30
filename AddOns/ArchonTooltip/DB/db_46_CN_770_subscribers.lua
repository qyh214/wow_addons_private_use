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

local lookup = {'Monk-Windwalker','Paladin-Retribution','Monk-Mistweaver','Paladin-Holy','Druid-Restoration','Priest-Discipline','Mage-Frost','Unknown-Unknown','Priest-Shadow','Priest-Holy','Evoker-Augmentation','Evoker-Devastation','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Unholy','DemonHunter-Devourer','Druid-Guardian','Druid-Balance','DemonHunter-Havoc','DeathKnight-Frost','Warlock-Affliction','Warlock-Destruction','Evoker-Preservation','Shaman-Elemental','Warrior-Fury','Paladin-Protection','Monk-Brewmaster','Hunter-BeastMastery','Hunter-Marksmanship',}
local provider = {region='CN',realm='白银之手',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Az='Azariel:BAEBLgAECn8YAAIBAAcJVBMqCQBmAQdoDAAABAAvAGkMAAAEADIAawwAAAQAOwBqDAAAAwAgAGwMAAADADIA6gwAAAUARABuDAAAAQAUAAEABwlUEyoJAGYBB2gMAAAEAC8AaQwAAAQAMgBrDAAABAA7AGoMAAADACAAbAwAAAMAMgDqDAAABQBEAG4MAAABABQAAAA=.Azursky:BAEBLgAFFH8JAAICAAQJlBkoCABxAQRoDAAAAwBiAGkMAAACADMAawwAAAIAMQDqDAAAAgA+AAIABAmUGSgIAHEBBGgMAAADAGIAaQwAAAIAMwBrDAAAAgAxAOoMAAACAD4AAAA=.',
De='Dejavudruidz:BAEALgAFFAUJAgABLgAFFAYJFgADAFMmAA==.Dejavupal:BAECLgAFFH8OAAIEAAQJqyZjAQDCAQRoDAAABQBiAGkMAAAEAGMAawwAAAIAYwDqDAAAAwBiAAQABAmrJmMBAMIBBGgMAAAFAGIAaQwAAAQAYwBrDAAAAgBjAOoMAAADAGIALgAECn8iAAIEAAgJWSYIAQCFAwAEAAgJWSYIAQCFAwABLgAFFAYJFgADAFMmAA==.',
Ec='Eclipseborn:BAEBLgAFFH8LAAIFAAQJVhirCABIAQRoDAAAAwA3AGkMAAADAEkAawwAAAIANADqDAAAAwBEAAUABAlWGKsIAEgBBGgMAAADADcAaQwAAAMASQBrDAAAAgA0AOoMAAADAEQAAS4ABRQFCRIABgBvDgA=.',
Eu='Eustraeus:BAECLgAFFH8WAAIHAAUJESVrAgC0AQVoDAAABQBgAGkMAAAFAFwAawwAAAQAYQBqDAAAAwBUAOoMAAAFAFwABwAFCRElawIAtAEFaAwAAAUAYABpDAAABQBcAGsMAAAEAGEAagwAAAMAVADqDAAABQBcAC4ABAp/IAACBwAICVsmgQkAegMABwAICVsmgQkAegMAAAA=.',
Fo='Folern:BAEALgADCgEJAQABLgAECgYJCgAIAAAAAA==.',
Gs='Gspore:BAEALgAFFAIJAgAAAA==.',
He='Helbrecht:BAEALgAFFAQJAgAAAA==.',
Il='Illidens:BAEALgAFFAMJBAABLgAFFAQJCQACAJQZAA==.',
Jh='Jhfss:BAECLgAFFH8TAAIHAAYJmSRMAgBsAgZoDAAABABjAGkMAAAEAFgAawwAAAQAYABqDAAAAgBHAGwMAAABAF8A6gwAAAQAWAAHAAYJmSRMAgBsAgZoDAAABABjAGkMAAAEAFgAawwAAAQAYABqDAAAAgBHAGwMAAABAF8A6gwAAAQAWAAuAAQKfxwAAgcACAk+JdERAD0DAAcACAk+JdERAD0DAAAA.Jhzs:BAEALgAFFAIJAwABLgAFFAYJEwAHAJkkAA==.',
Jo='Joshy:BAECLgAFFH8SAAMGAAUJbw6hBQCLAQVoDAAAAwAUAGkMAAAFADUAawwAAAQAGABqDAAAAgAjAOoMAAAEADMABgAFCW8OoQUAiwEFaAwAAAMAFABpDAAABAA1AGsMAAAEABgAagwAAAIAIwDqDAAABAAzAAkAAQnkA5gWAEcAAWkMAAABAAkALgAECn8WAAMGAAcJeCKfCwB+AgAGAAcJLR6fCwB+AgAKAAcJ+BsgHQD0AQAAAA==.',
Kh='Khârn:BAEALgAFFAQJAQABLgAFFAQJAgAIAAAAAA==.',
Ma='Markcheep:BAEALgAFFAIJAgABLgAFFAIJAgAIAAAAAA==.',
Ni='Nillin:BAEALgAECgQJBQABLgAFFAUJEQAGAGMjAA==.',
Pi='Piyou:BAECLgAFFH8RAAMLAAUJUhsEBABiAQVoDAAABQBMAGkMAAAEAFgAawwAAAMARgBqDAAAAQATAOoMAAAEACwACwAECfIZBAQAYgEEaAwAAAQAPgBpDAAABABYAGsMAAADAEYA6gwAAAQALAAMAAIJ7B1IBgCrAAJoDAAAAQBMAGoMAAABABMALgAECn8pAAMLAAgJziPmBQAlAwALAAgJniLmBQAlAwAMAAgJTR8qBwB6AgAAAA==.',
Re='Realcomma:BAEALgAECgQJBwABLgAFFAQJDgANABcIAA==.',
Sh='Shaula:BAEALgAECgYJDAAAAA==.',
['Sù']='Sùprémê:BAECLgAFFH8UAAMOAAYJQB11AQD3AQZoDAAABABiAGkMAAAEAF4AawwAAAMAMQBqDAAAAwBIAGwMAAACAEcA6gwAAAQAPQAOAAUJlx11AQD3AQVoDAAABABiAGkMAAAEAF4AawwAAAMAMQBqDAAAAwBIAOoMAAAEAD0ADwABCeMbggIAawABbAwAAAIARwAuAAQKfxYAAw4ACAmVJPoHABEDAA4ACAmVJPoHABEDAA8AAQkdGdodAD4AAAAA.',
Vi='Visondk:BAEBLgAECn8WAAIQAAgJ/h5cRAAoAghoDAAAAgBYAGkMAAACAF4AawwAAAIAXABqDAAAAwA5AGwMAAADAEkAbQwAAAQAUwDqDAAABQBVAG4MAAABACUAEAAICf4eXEQAKAIIaAwAAAIAWABpDAAAAgBeAGsMAAACAFwAagwAAAMAOQBsDAAAAwBJAG0MAAAEAFMA6gwAAAUAVQBuDAAAAQAlAAEuAAUUCAkeABEA6BYA.',
Xa='Xandra:BAECLgAFFH8OAAMSAAQJOwnxAQDiAARoDAAABQAhAGkMAAADABkAawwAAAIACgDqDAAABAAZABIABAmLCPEBAOIABGgMAAACABoAaQwAAAIAGQBrDAAAAgAKAOoMAAACABkAEwADCZ8GfhAA2AADaAwAAAMAIQBpDAAAAQAEAOoMAAACAAwALgAECn8YAAMTAAgJrB1bJADaAQATAAcJZRhbJADaAQASAAQJKBnTFAAkAQAAAA==.',
Ya='Yamak:BAEALgAFFAUJBAAAAA==.',
['一抹']='一抹丶深紫:BAEALgAECgkJCQABLgAECgcJBwAIAAAAAA==.',
['一杯']='一杯奶茶丶:BAEALgAECgcJAwABLgAFFAQJBwAHAOMlAA==.',
['丨乐']='丨乐灬天丨:BAEALgAFFAIJBAAAAA==.',
['丶水']='丶水玥:BAEALgAECgUJBQABLgAECgkJHQAUANgeAA==.',
['乘月']='乘月:BAEALgAECgYJDAABLgAFFAUJEQAQABsbAA==.',
['书初']='书初:BAECLgAFFH8RAAMQAAUJGxvLBgCbAQVoDAAABABWAGkMAAAEAFcAawwAAAQAQwBqDAAAAQAAAOoMAAAEACQAEAAFCRsbywYAmwEFaAwAAAMAVgBpDAAAAwBXAGsMAAADAEMAagwAAAEAAADqDAAAAwAkABUABAmBDA8BAEQBBGgMAAABABQAaQwAAAEASgBrDAAAAQAIAOoMAAABABgALgAECn8tAAMQAAgJ6iJ2DgAnAwAQAAgJ6iJ2DgAnAwAVAAUJkxy3AgBkAQAAAA==.',
['事妤']='事妤愿违:BAEBLgAECn8XAAMCAAkJWx3+FQDlAgloDAAAAwBYAGkMAAADAE4AawwAAAMATQBqDAAAAwBbAGwMAAADAE4AbQwAAAIAOgDqDAAAAgBaAG4MAAACAFIAbwwAAAIALgACAAkJWx3+FQDlAgloDAAAAgBYAGkMAAACAE4AawwAAAIATQBqDAAAAgBbAGwMAAACAE4AbQwAAAEAOgDqDAAAAgBaAG4MAAABAFIAbwwAAAEALgAEAAgJkwoUMgC3AQhoDAAAAQAQAGkMAAABABgAawwAAAEASQBqDAAAAQAPAGwMAAABABcAbQwAAAEAFgBuDAAAAQAbAG8MAAABAAwAAAA=.',
['人宠']='人宠董思彤:BAEALgAFFAIJAgAAAA==.',
['兜兜']='兜兜转轉:BAEALgAECgcJBgABLgAFFAYJFAAOAEQdAA==.',
['凤仙']='凤仙丶:BAEBLgAFFH8IAAMUAAYJiQHRAwBHAQZoDAAAAQAFAGkMAAABAAEAawwAAAIACQBqDAAAAgADAG0MAAABAAAA6gwAAAEAAgAUAAUJ2QHRAwBHAQVoDAAAAQAFAGkMAAABAAEAawwAAAEACQBqDAAAAQACAOoMAAABAAIAEQADCd4A7x8AXQADawwAAAEAAwBqDAAAAQADAG0MAAABAAAAAAA=.',
['十小']='十小龍女十:BAEALgAFFAQJBAABLgAFFAQJBgAHALASAA==.',
['南风']='南风灬轻拂:BAEALgAECgQJBAABLgAFFAMJBAAIAAAAAA==.',
['可乐']='可乐不太冰:BAEALgAECgcJDgABLgAFFAcJFAAOAPwSAA==.',
['可爱']='可爱的丁丁:BAEALgAFFAIJAgAAAA==.可爱的捏捏:BAEALgAECgYJBgABLgAFFAIJAgAIAAAAAA==.',
['可琦']='可琦安饼饼:BAEBLgAECn8VAAIFAAkJ5RT+GwBcAgloDAAAAwBKAGkMAAADADQAawwAAAMANABqDAAAAwA6AGwMAAADAEYAbQwAAAEAHQDqDAAAAgBRAG4MAAACACwAbwwAAAEAEgAFAAkJ5RT+GwBcAgloDAAAAwBKAGkMAAADADQAawwAAAMANABqDAAAAwA6AGwMAAADAEYAbQwAAAEAHQDqDAAAAgBRAG4MAAACACwAbwwAAAEAEgABLgAFFAUJEgAKAOEhAA==.',
['叻啹']='叻啹啹:BAEALgAECgUJBQABLgAFFAIJAgAIAAAAAA==.',
['咕德']='咕德灬貓羚:BAEALgAECgEJAQABLgAFFAMJBAAIAAAAAA==.',
['四修']='四修小德:BAECLgAFFH8UAAIFAAYJkyOIAABeAgZoDAAABABjAGkMAAADAFUAawwAAAQAXQBqDAAAAwBiAGwMAAACAEkA6gwAAAQAYQAFAAYJkyOIAABeAgZoDAAABABjAGkMAAADAFUAawwAAAQAXQBqDAAAAwBiAGwMAAACAEkA6gwAAAQAYQAuAAQKfxYAAgUABwkfJiYJAP4CAAUABwkfJiYJAP4CAAAA.',
['天然']='天然屁:BAECLgAFFH8PAAIDAAcJgwytAQAbAgdoDAAAAQAOAGkMAAACABQAawwAAAIACgBqDAAAAQACAGwMAAADADIAbQwAAAIANQDqDAAABABIAAMABwmDDK0BABsCB2gMAAABAA4AaQwAAAIAFABrDAAAAgAKAGoMAAABAAIAbAwAAAMAMgBtDAAAAgA1AOoMAAAEAEgALgAECn8VAAIDAAkJdRgEDACUAgADAAkJdRgEDACUAgABLgAFFAcJFAAOAPwSAA==.',
['奶油']='奶油不太冷:BAECLgAFFH8UAAIOAAcJ/BJPAADMAQdoDAAABQBGAGkMAAAEACUAawwAAAMAKQBqDAAAAQAwAGwMAAABAEsA6gwAAAUAKgBuDAAAAQAXAA4ABwn8Ek8AAMwBB2gMAAAFAEYAaQwAAAQAJQBrDAAAAwApAGoMAAABADAAbAwAAAEASwDqDAAABQAqAG4MAAABABcALgAECn8XAAIOAAgJEiJrCgDsAgAOAAgJEiJrCgDsAgAAAA==.',
['娃哈']='娃哈哈小术神:BAECLgAFFH8GAAINAAIJnRHxMgCtAAJoDAAAAgA5AOoMAAAEACAADQACCZ0R8TIArQACaAwAAAIAOQDqDAAABAAgAC4ABAp/IAAEDQAHCdQdRhkAbQEADQAHCSscRhkAbQEAFgABCQAAPSUAXQAAFwABCeEZB2EATAAAAAA=.',
['安迪']='安迪凯鲁:BAEBLgAECn8XAAMLAAYJ7BNRKAB6AQZoDAAABABBAGkMAAAEADIAawwAAAQARQBqDAAAAwA8AGwMAAADABgA6gwAAAUALQALAAYJ7BNRKAB6AQZoDAAAAwBBAGkMAAADADIAawwAAAMARQBqDAAAAwA8AGwMAAADABgA6gwAAAMALQAYAAQJ+hFbMQDlAARoDAAAAQAxAGkMAAABACQAawwAAAEALADqDAAAAgA2AAEuAAUUAwkIABkACBkA.',
['寄寄']='寄寄辣:BAEALgAFFAQJBAAAAA==.',
['小月']='小月蝶:BAECLgAFFH8QAAIEAAUJiyQdAQAUAgVoDAAABQBdAGkMAAAEAFkAawwAAAIAYgBqDAAAAQBfAOoMAAAEAFsABAAFCYskHQEAFAIFaAwAAAUAXQBpDAAABABZAGsMAAACAGIAagwAAAEAXwDqDAAABABbAC4ABAp/KwACBAAICdElfAEAbQMABAAICdElfAEAbQMAAAA=.',
['小水']='小水无敌:BAEALgAFFAEJAQAAAA==.',
['小龙']='小龙人赵君君:BAEALgAECgMJBAABLgAFFAcJDwALAPsYAA==.',
['微醺']='微醺灬看她笑:BAECLgAFFH8FAAMWAAIJzBETBQBYAAJoDAAAAwAoAGkMAAACADIAFgABCccTEwUAWAABaQwAAAIAMgANAAEJ0Q+kMABTAAFoDAAAAwAoAC4ABAp/HgAEDQAICWQgcjMAPgIADQAGCeMhcjMAPgIAFwAECewbkh8AVQEAFgAECXEcXxEAFwEAAAA=.',
['恬玥']='恬玥:BAEALgAFFAEJAgABLgAECgkJHQAUANgeAA==.',
['愁眠']='愁眠君:BAEALgAECgcJDAAAAA==.',
['我会']='我会控制:BAEALgAFFAIJAQABLgAFFAYJCAAUAIkBAA==.',
['指尖']='指尖的邂逅:BAEALgAECgQJBQABLgAFFAIJAgAIAAAAAA==.',
['林登']='林登娜:BAEALgAFFAEJAQAAAA==.',
['柒宗']='柒宗嶵:BAEALgAECgYJEgAAAA==.',
['森林']='森林谢三枪:BAEBLgAECn8mAAMEAAgJ4CCMAQDFAghoDAAABgBfAGkMAAAGAGEAawwAAAUAVQBqDAAABQBZAGwMAAAGAE8AbQwAAAMAQADqDAAABQBSAG4MAAACAE4ABAAICeAgjAEAxQIIaAwAAAMAXwBpDAAAAwBhAGsMAAACAFUAagwAAAIAWQBsDAAAAwBPAG0MAAACAEAA6gwAAAIAUgBuDAAAAgBOAAIABwkBHetIAAgCB2gMAAADAEoAaQwAAAMATABrDAAAAwBVAGoMAAADAEIAbAwAAAMAMgBtDAAAAQBRAOoMAAADAEwAAAA=.',
['欲望']='欲望沉溺:BAEALgAECgQJBAABLgAFFAQJDgAaAJwVAA==.',
['水玥']='水玥丶:BAEALgAECgcJCQABLgAECgkJHQAUANgeAA==.',
['焰天']='焰天火雨:BAEALgAFFAIJAwABLgAFFAQJCQAaAG0YAA==.',
['燚焱']='燚焱灬炎火:BAEALgAECgEJAQABLgAFFAMJBAAIAAAAAA==.',
['白芸']='白芸:BAECLgAFFH8JAAIbAAMJGxsOAgD4AANoDAAABABFAGkMAAACADQA6gwAAAMAVgAbAAMJGxsOAgD4AANoDAAABABFAGkMAAACADQA6gwAAAMAVgAuAAQKfxcAAhsACAlNHeMHAF4CABsACAlNHeMHAF4CAAAA.',
['离巢']='离巢的乌瑞尔:BAEALgADCgYJBgABLgAECgUJCQAIAAAAAA==.离巢的瓦莉拉:BAEALgAECgUJCQAAAA==.',
['秋津']='秋津茜:BAECLgAFFH8OAAIaAAQJnBU2BABEAQRoDAAABQBEAGkMAAADAE0AawwAAAIAEwDqDAAABAA3ABoABAmcFTYEAEQBBGgMAAAFAEQAaQwAAAMATQBrDAAAAgATAOoMAAAEADcALgAECn8eAAIaAAkJ/iBRBwA0AwAaAAkJ/iBRBwA0AwAAAA==.',
['程子']='程子唤魔:BAEALgAFFAEJAQABLgAFFAMJCAAOADoVAA==.程子圣光:BAEBLgAFFH8GAAICAAIJHRDkJACiAAJoDAAAAwAfAOoMAAADADIAAgACCR0Q5CQAogACaAwAAAMAHwDqDAAAAwAyAAEuAAUUAwkIAA4AOhUA.程子复仇:BAEALgAFFAIJAgABLgAFFAMJCAAOADoVAA==.程子群晕:BAEBLgAFFH8GAAIcAAIJ2gvcEACKAAJoDAAAAwAqAOoMAAADABEAHAACCdoL3BAAigACaAwAAAMAKgDqDAAAAwARAAEuAAUUAwkIAA4AOhUA.',
['笑语']='笑语看歌:BAECLgAFFH8JAAIaAAQJbRh9BwB0AQRoDAAAAwBMAGkMAAADAGMAawwAAAEALADqDAAAAgAdABoABAltGH0HAHQBBGgMAAADAEwAaQwAAAMAYwBrDAAAAQAsAOoMAAACAB0ALgAECn8gAAIaAAcJeyLPEwCwAgAaAAcJeyLPEwCwAgAAAA==.',
['粉色']='粉色懶懶貓:BAEBLgAECn8XAAMdAAkJqSCUAgBvAwloDAAAAwBZAGkMAAADAF8AawwAAAMAYgBqDAAAAwBTAGwMAAADAEsAbQwAAAMASADqDAAAAwBiAG4MAAABAFoAbwwAAAEALwAdAAkJqSCUAgBvAwloDAAAAgBZAGkMAAACAF8AawwAAAIAYgBqDAAAAgBTAGwMAAACAEsAbQwAAAIASADqDAAAAgBiAG4MAAABAFoAbwwAAAEALwAeAAcJTwqxQgBMAQdoDAAAAQAiAGkMAAABACQAawwAAAEAJABqDAAAAQA1AGwMAAABABcAbQwAAAEACQDqDAAAAQASAAAA.',
['糕糕']='糕糕团:BAEBLgAFFH8OAAIDAAQJMR9QAwBxAQRoDAAABABLAGkMAAADAD8AawwAAAIAVwDqDAAABQBcAAMABAkxH1ADAHEBBGgMAAAEAEsAaQwAAAMAPwBrDAAAAgBXAOoMAAAFAFwAAAA=.',
['美乐']='美乐蒂:BAECLgAFFH8SAAIKAAUJ4SGKAAAGAgVoDAAABQBdAGkMAAAEAFEAawwAAAQAXABqDAAAAgBGAOoMAAADAGAACgAFCeEhigAABgIFaAwAAAUAXQBpDAAABABRAGsMAAAEAFwAagwAAAIARgDqDAAAAwBgAC4ABAp/MQADCgAJCcMlMAAA3AMACgAJCcMlMAAA3AMABgAHCUUKdwsARgEAAAA=.',
['肆意']='肆意博爱:BAEALgAFFAIJAgABLgAFFAIJAgAIAAAAAA==.',
['肉沫']='肉沫粉丶:BAEALgAECgYJDQAAAA==.',
['肥喵']='肥喵鬧鬧:BAEALgAECgYJCgABLgAFFAMJCQAbABsbAA==.',
['背景']='背景板月蝶酱:BAEALgAECgcJDQABLgAFFAUJEAAEAIskAA==.',
['芒果']='芒果嗏灬:BAEALgAECgIJAgAAAA==.',
['花開']='花開終須落:BAEALgAFFAMJBAAAAA==.',
['萌萌']='萌萌的月蝶:BAEALgAECgYJBgABLgAFFAUJEAAEAIskAA==.',
['蓝色']='蓝色鸟德:BAEALgAECgYJDAAAAA==.',
['蜜桃']='蜜桃味小熊:BAEBLgAFFH8HAAIGAAMJChWKDQDyAANoDAAAAwAnAGkMAAADADsA6gwAAAEAPgAGAAMJChWKDQDyAANoDAAAAwAnAGkMAAADADsA6gwAAAEAPgABLgAFFAUJEQAGAAkYAA==.',
['街头']='街头五星上将:BAEBLgAFFH8IAAIQAAQJNw0DGgA9AQRoDAAAAgA8AGkMAAACACYAawwAAAIAGgDqDAAAAgAJABAABAk3DQMaAD0BBGgMAAACADwAaQwAAAIAJgBrDAAAAgAaAOoMAAACAAkAAAA=.',
['言源']='言源:BAEALgADCgMJAwABLgAFFAUJEQAGAGMjAA==.',
['财高']='财高八抖:BAEALgAFFAQJBAAAAA==.',
['超天']='超天酱:BAEBLgAFFH8LAAIQAAUJOxtJDgBpAQVoDAAAAwBcAGkMAAADAFgAawwAAAIAOABsDAAAAQAcAOoMAAACAFEAEAAFCTsbSQ4AaQEFaAwAAAMAXABpDAAAAwBYAGsMAAACADgAbAwAAAEAHADqDAAAAgBRAAEuAAUUBgkIABQAiQEA.',
['辛加']='辛加斯:BAEALgAECgkJEAAAAA==.',
['辣鸡']='辣鸡面丶:BAEALgAECgQJBgABLgAECgYJDQAIAAAAAA==.',
['透明']='透明的月蝶酱:BAEALgAECgYJDAABLgAFFAUJEAAEAIskAA==.透明鸟德:BAEBLgAFFH8NAAITAAYJBRx2AADQAQZoDAAAAgBaAGkMAAACAFwAawwAAAIATABqDAAAAwBRAGwMAAACADQA6gwAAAIALgATAAYJBRx2AADQAQZoDAAAAgBaAGkMAAACAFwAawwAAAIATABqDAAAAwBRAGwMAAACADQA6gwAAAIALgABLgAECgYJDAAIAAAAAA==.',
['邪玥']='邪玥:BAEBLgAECn8dAAMUAAkJ2B7sAwA+AwloDAAABABgAGkMAAAEAFgAawwAAAQAXABqDAAABABiAGwMAAAEAFIAbQwAAAMAVQDqDAAABABhAG4MAAABABMAbwwAAAEARQAUAAkJ2B7sAwA+AwloDAAAAwBgAGkMAAADAFgAawwAAAMAXABqDAAAAwBiAGwMAAADAFIAbQwAAAMAVQDqDAAAAwBhAG4MAAABABMAbwwAAAEARQARAAYJChxnQwDmAQZoDAAAAQBGAGkMAAABAD4AawwAAAEATwBqDAAAAQBbAGwMAAABAEkA6gwAAAEASQAAAA==.',
['野程']='野程:BAECLgAFFH8IAAIOAAMJOhVQDQATAQNoDAAABAAvAGkMAAABACoA6gwAAAMASQAOAAMJOhVQDQATAQNoDAAABAAvAGkMAAABACoA6gwAAAMASQAuAAQKfxsAAg4ACAk+HHcPAK0CAA4ACAk+HHcPAK0CAAAA.',
['镜音']='镜音铃:BAEALgAECgEJAQAAAA==.',
['阿乐']='阿乐噬灭:BAEBLgAFFH8GAAIRAAYJtgAdDwD+AAZoDAAAAQABAGkMAAABAAEAawwAAAEAAgBqDAAAAQAEAGwMAAABAAAA6gwAAAEAAgARAAYJtgAdDwD+AAZoDAAAAQABAGkMAAABAAEAawwAAAEAAgBqDAAAAQAEAGwMAAABAAAA6gwAAAEAAgAAAA==.阿乐术士:BAEBLgAFFH8IAAINAAQJthSkEwBMAQRoDAAAAwBKAGkMAAABACYAawwAAAEAAQDqDAAAAwBhAA0ABAm2FKQTAEwBBGgMAAADAEoAaQwAAAEAJgBrDAAAAQABAOoMAAADAGEAAS4ABRQGCQYAEQC2AAA=.',
['隐玥']='隐玥:BAEBLgAECn8WAAIOAAcJYyBfGQA5AgdoDAAAAwBWAGkMAAADAFUAawwAAAMAYQBqDAAAAwBbAGwMAAADAFMAbQwAAAEAMQDqDAAABgBfAA4ABwljIF8ZADkCB2gMAAADAFYAaQwAAAMAVQBrDAAAAwBhAGoMAAADAFsAbAwAAAMAUwBtDAAAAQAxAOoMAAAGAF8AAS4ABAoJCR0AFADYHgA=.',
['雪花']='雪花贼:BAEALgAECgEJAQAAAA==.',
['风笛']='风笛回响:BAEALgAFFAIJAgAAAA==.',
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
