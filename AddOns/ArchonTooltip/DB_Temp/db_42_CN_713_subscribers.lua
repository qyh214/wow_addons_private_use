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
 local lookup = {'Mage-Frost','Mage-Fire','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Shaman-Enhancement','Paladin-Holy','Paladin-Protection','Evoker-Devastation','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','Hunter-Marksmanship','Mage-Arcane','Shaman-Restoration','Druid-Balance','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='格瑞姆巴托',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Ca='Cappuccinoq:BAEBKgAFFH8OAAMBAAgIaBWoAQAgAgjBCwAAAgA+AMILAAACAFgAwwsAAAIAVwDECwAAAgAqAMULAAACAFIAxgsAAAIAJQDHCwAAAQAKAMgLAAABAA4AAQAICGgVqAEAIAIIwQsAAAEAPgDCCwAAAQBYAMMLAAABAFcAxAsAAAEAKgDFCwAAAQBSAMYLAAABACUAxwsAAAEACgDICwAAAQAOAAIABgh+B3YSACwBBsELAAABABYAwgsAAAEAJwDDCwAAAQAJAMQLAAABABoAxQsAAAEAEgDGCwAAAQAGAAAA.',La='Lalaland:BAEBKgAFFH8MAAQDAAcIHR94AAB6AQfBCwAAAgBgAMILAAACAFYAwwsAAAIAUgDECwAAAQBjAMULAAACAFUAxgsAAAIASQDHCwAAAQA2AAMABAj+IHgAAHoBBMELAAACAGAAwgsAAAIAVgDDCwAAAgBSAMYLAAABAEkABAADCGQYcwgAIQEDxQsAAAEAVADGCwAAAQAwAMcLAAABADYABQACCJEh1hAAYAACxAsAAAEAYwDFCwAAAQBVAAEqAAUUCAgMAAYADhAA.',['化石']='化石翼龍:BAEBKgAECn8UAAMHAAgI5hdODwAJAgjBCwAAAgBCAMILAAACADIAwwsAAAIATQDECwAAAgAqAMULAAACAFEAxgsAAAIATgDHCwAABAAnAMgLAAAEACEABwAICOYXTg8ACQIIwQsAAAEAQgDCCwAAAQAyAMMLAAABAE0AxAsAAAEAKgDFCwAAAQBRAMYLAAABAE4AxwsAAAEAJwDICwAAAQAhAAgACAgNE2cdAG4BCMELAAABACwAwgsAAAEANwDDCwAAAQAYAMQLAAABAE4AxQsAAAEAJwDGCwAAAQBAAMcLAAADADMAyAsAAAMAPQABKgAFFAYIBgAJAHAkAA==.',['千面']='千面避役:BAEAKgAECgEIAQABKgAFFAYIBgAJAHAkAA==.',['哈克']='哈克龍:BAEBKgAFFH8GAAIJAAYIcCQbCgDSAQbBCwAAAQBjAMILAAABAGAAwwsAAAEAXgDECwAAAQBJAMULAAABAFQAxgsAAAEAWwAJAAYIcCQbCgDSAQbBCwAAAQBjAMILAAABAGAAwwsAAAEAXgDECwAAAQBJAMULAAABAFQAxgsAAAEAWwAAAA==.',['喵黎']='喵黎黎:BAECKgAFFH8GAAIKAAYITxq4DwCmAQbBCwAAAQBZAMILAAABAEgAwwsAAAEAOgDECwAAAQBCAMULAAABAEIAxgsAAAEAMgAKAAYITxq4DwCmAQbBCwAAAQBZAMILAAABAEgAwwsAAAEAOgDECwAAAQBCAMULAAABAEIAxgsAAAEAMgAqAAQKfyAAAwoACAjiGKBUAPcBAAoACAjiGKBUAPcBAAcACAjwGOYXAKsBAAEqAAUUCAgMAAYADhAA.',['大堃']='大堃法:BAEAKgADCgYIBgAAAA==.',['奶白']='奶白得雪子:BAECKgAFFH88AAQDAAcIJiBBAwAbAQfBCwAADQBUAMILAAANAFsAwwsAAA0AXADECwAACgBVAMULAAAGAFoAxgsAAAMAVgDHCwAAAgAwAAMABQgGI0EDABsBBcELAAAKAFQAwgsAAAoAWwDDCwAADQBcAMQLAAAHAFUAxQsAAAEAWgAEAAQIeBdJIwCDAATBCwAAAwA1AMILAAADADMAxgsAAAMAVgDHCwAAAgAwAAUAAghtH3kjAFMAAsQLAAADACwAxQsAAAUAUAAqAAQKfyUABAQACAg9IQ8hAP4BAAQABwjsGA8hAP4BAAMAAwgJINEgAOsAAAUAAwi2HptWAJQAAAEqAAUUCAgMAAYADhAA.',['小光']='小光有意:BAECKgAFFH9hAAMLAAgI6SUsAAD0AgjBCwAAEgBhAMILAAAPAGMAwwsAABAAYgDECwAADABRAMULAAAJAGMAxgsAAAoAYQDHCwAACQBgAMgLAAAIAFoACwAICOklLAAA9AIIwQsAABIAYQDCCwAADwBjAMMLAAAQAGIAxAsAAAsAUQDFCwAACQBjAMYLAAAKAGEAxwsAAAkAYADICwAACABaAAwAAQgAAA4kAAAAAcQLAAABAEYAKgAECn9CAAMLAAgIzyZ8AAAQAwALAAgIzyZ8AAAQAwAMAAMIaCPoVQAgAQAAAA==.',['小动']='小动物爱吃果:BAECKgAFFH8HAAINAAYIkh6UIQDsAAbBCwAAAQBKAMILAAABAF0AwwsAAAIAUQDECwAAAQBWAMULAAABAF0AxgsAAAEAMAANAAYIkh6UIQDsAAbBCwAAAQBKAMILAAABAF0AwwsAAAIAUQDECwAAAQBWAMULAAABAF0AxgsAAAEAMAAqAAQKfxgAAg0ACAiWIgYRAHECAA0ACAiWIgYRAHECAAEqAAUUCAgIAA4A+BUA.',['尘枫']='尘枫:BAEBKgAFFH8IAAIOAAgI+BU3BgA0AgjBCwAAAQAuAMILAAABAEEAwwsAAAEARQDECwAAAQBBAMULAAABADIAxgsAAAEASgDHCwAAAQAgAMgLAAABADYADgAICPgVNwYANAIIwQsAAAEALgDCCwAAAQBBAMMLAAABAEUAxAsAAAEAQQDFCwAAAQAyAMYLAAABAEoAxwsAAAEAIADICwAAAQA2AAAA.',['快雪']='快雪時晴丶:BAEBKgAFFH8RAAQDAAYIViWzAgB6AQbBCwAAAwBjAMILAAADAGIAwwsAAAMAYgDECwAAAwBiAMULAAACAFcAxgsAAAMAXgAEAAYI0yC6EACHAQbBCwAAAQBbAMILAAABAFUAwwsAAAEAVQDECwAAAQAeAMULAAABAFcAxgsAAAIARgADAAUIGyazAgB6AQXBCwAAAgBjAMILAAACAGIAwwsAAAIAYgDECwAAAgBiAMYLAAABAF4ABQABCAcbZiYATAABxQsAAAEARQABKgAFFAgIDAAGAA4QAA==.',['我好']='我好急啊:BAEBKgAFFH8IAAMGAAQIIRXvCQABAQTBCwAAAgAyAMILAAACADwAwwsAAAIAMwDECwAAAgAlAAYABAghFe8JAAEBBMELAAABADIAwgsAAAEAPADDCwAAAQAzAMQLAAABACUADwAECJkGvxoAtwAEwQsAAAEADQDCCwAAAQAgAMMLAAABAAQAxAsAAAEAAwABKgAFFAgIDAAGAA4QAA==.',['拇指']='拇指小哥:BAEAKgAFFAMIAwABKgAFFAgIDAAGAA4QAA==.',['暖暖']='暖暖豬:BAEAKgAECggICAABKgAFFAYIBgAJAHAkAA==.',['江南']='江南追忆:BAEAKgAFFAYIAQABKgAFFAgIDAAGAA4QAA==.',['綠毛']='綠毛蟲:BAEBKgAFFH8IAAIQAAQIqiVfCwAUAQTBCwAAAgBgAMILAAACAGIAwwsAAAIAXgDECwAAAgBjABAABAiqJV8LABQBBMELAAACAGAAwgsAAAIAYgDDCwAAAgBeAMQLAAACAGMAASoABRQGCAYACQBwJAA=.',['美味']='美味丨蟹黄堡:BAEBKgAFFH8MAAIGAAgIDhBiAABcAgjBCwAAAgBCAMILAAACADYAwwsAAAIAHADECwAAAgBGAMULAAABAAgAxgsAAAEAMADHCwAAAQATAMgLAAABAD4ABgAICA4QYgAAXAIIwQsAAAIAQgDCCwAAAgA2AMMLAAACABwAxAsAAAIARgDFCwAAAQAIAMYLAAABADAAxwsAAAEAEwDICwAAAQA+AAAA.',['翠峰']='翠峰茉莉:BAEAKgAFFAYIAwABKgAFFAgIDAAGAA4QAA==.',['苏生']='苏生栗子球丶:BAEAKgAECgIIAgAAAA==.',['观鯤']='观鯤鹏於北溟:BAEBKgAFFH8GAAIEAAYIsxokEwBtAQbBCwAAAQBfAMILAAABAA4AwwsAAAEAUADECwAAAQBiAMULAAABAEsAxgsAAAEATAAEAAYIsxokEwBtAQbBCwAAAQBfAMILAAABAA4AwwsAAAEAUADECwAAAQBiAMULAAABAEsAxgsAAAEATAABKgAFFAgIDAAGAA4QAA==.',['铁拳']='铁拳凌晓雨:BAECKgAFFH9DAAMRAAgIJCGjAgBxAgjBCwAAEQBdAMILAAAOAF8AwwsAAAsAVADECwAABgBQAMULAAAEAFYAxgsAAAQAUADHCwAABgBDAMgLAAAFAFUAEQAICCQhowIAcQIIwQsAAA8AXQDCCwAACgBfAMMLAAAKAFQAxAsAAAUAUADFCwAAAgBWAMYLAAACAFAAxwsAAAMAQwDICwAAAQBVABIACAjPDcgMAFgBCMELAAACADMAwgsAAAQALwDDCwAAAQAzAMQLAAABACMAxQsAAAIACADGCwAAAgADAMcLAAADACIAyAsAAAQAMQAqAAQKfzQAAxEACAj0JCEQAGUCABEACAj0JCEQAGUCABIABggnGv81AHEBAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end