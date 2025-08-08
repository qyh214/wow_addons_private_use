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
 local lookup = {'DeathKnight-Blood','Priest-Discipline','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Priest-Holy','Priest-Shadow','Monk-Brewmaster','Mage-Fire','Hunter-BeastMastery','Shaman-Enhancement','Druid-Balance','Monk-Mistweaver','Warlock-Demonology','Warlock-Destruction','Paladin-Holy','Paladin-Protection','Evoker-Devastation','Evoker-Preservation','Shaman-Any','Warlock-Affliction','Druid-Restoration',}; local provider = {region='CN',realm='血色十字军',name='CN',type='subscribers',zone=42,date='2025-08-08',data={['上官']='上官吻唲:BAEBKgAFFH8HAAIBAAQIWiEFEAAlAQTBCwAAAgBdAMILAAACAFIAwwsAAAIAUADECwAAAQBTAAEABAhaIQUQACUBBMELAAACAF0AwgsAAAIAUgDDCwAAAgBQAMQLAAABAFMAASoABRQFCCoAAgBAHQA=.',['不玩']='不玩地精都菜:BAECKgAFFH8IAAIBAAMI1QZiGgCDAAPBCwAAAwAEAMILAAADABsAwwsAAAIAFQABAAMI1QZiGgCDAAPBCwAAAwAEAMILAAADABsAwwsAAAIAFQAqAAQKfygAAgEACAiGHqIMAGACAAEACAiGHqIMAGACAAAA.',['乾坤']='乾坤脉涌:BAEBKgAECn8YAAMDAAgIcB1rHwAZAgjBCwAAAwBWAMILAAADAEIAwwsAAAMAVADECwAAAwBcAMULAAADAGAAxgsAAAMALgDHCwAAAwBJAMgLAAADAEkAAwAICHAdax8AGQIIwQsAAAIAVgDCCwAAAgBCAMMLAAACAFQAxAsAAAIAXADFCwAAAgBgAMYLAAACAC4AxwsAAAIASQDICwAAAwBJAAQABwjGCVNLAPAAB8ELAAABACYAwgsAAAEALgDDCwAAAQAJAMQLAAABAC8AxQsAAAEADQDGCwAAAQAJAMcLAAABAB8AASoABRQICBoABQCeHAA=.',['凛兮']='凛兮:BAECKgAFFH8qAAQCAAUIQB2oCgAAAQXBCwAADQBcAMILAAALAFsAwwsAAAoAYQDECwAABwBaAMYLAAABABEABgADCFkapRYAAAEDwQsAAAIADADCCwAABwBbAMMLAAAHAGEAAgAFCFAUqAoAAAEFwQsAAAgAXADCCwAABAAuAMMLAAADADMAxAsAAAcAWgDGCwAAAQARAAcAAQhEFH4tAD8AAcELAAADADMAKgAECn8oAAMCAAgIsSF1CwB2AgACAAgIJSB1CwB2AgAGAAgI6hXBLwBlAQAAAA==.',['凤敏']='凤敏:BAEBKgAECn8VAAIIAAgIchU8CQC8AQjBCwAAAwBDAMILAAADAFEAwwsAAAMAPwDECwAAAwAnAMULAAADADIAxgsAAAMAPwDHCwAAAgAmAMgLAAABABIACAAICHIVPAkAvAEIwQsAAAMAQwDCCwAAAwBRAMMLAAADAD8AxAsAAAMAJwDFCwAAAwAyAMYLAAADAD8AxwsAAAIAJgDICwAAAQASAAEqAAUUBQgqAAIAQB0A.',['剑屿']='剑屿:BAEBKgAFFH8aAAMFAAgInhxJAwBtAgjBCwAABABOAMILAAAEAEEAwwsAAAMAVwDECwAAAwBWAMULAAADAEMAxgsAAAMATgDHCwAAAwBSAMgLAAADADQABQAICFQcSQMAbQIIwQsAAAIATgDCCwAAAgA8AMMLAAABAFcAxAsAAAEAVgDFCwAAAQBDAMYLAAABAE4AxwsAAAEAUgDICwAAAQA0AAEACAiaFhIDAP4BCMELAAACAEwAwgsAAAIAQQDDCwAAAgBAAMQLAAACAFAAxQsAAAIAQADGCwAAAgA2AMcLAAACABwAyAsAAAIAMgAAAA==.',['啾啾']='啾啾呀丶:BAEBKgAFFH8IAAMFAAYIxxoZBwA0AQbBCwAAAgBSAMILAAABADcAwwsAAAEAJwDECwAAAgAnAMULAAABAEgAxgsAAAEAXAAFAAQIQSAZBwA0AQTBCwAAAQBSAMQLAAABACcAxQsAAAEASADGCwAAAQBcAAEABAhRFcsOAMgABMELAAABAEQAwgsAAAEANwDDCwAAAQAnAMQLAAABABgAASoABRQICDIACQD9IwA=.',['地渊']='地渊:BAEAKgAECgUIBQAAAA==.',['大观']='大观园丶:BAEAKgAECgEIAQABKgAFFAgIEAAKAJkcAA==.',['天噫']='天噫:BAEBKgAFFH8KAAILAAYIph/vBADUAQbBCwAAAgBWAMILAAACAFUAwwsAAAIAWwDECwAAAgBUAMULAAABAEwAxgsAAAEAQAALAAYIph/vBADUAQbBCwAAAgBWAMILAAACAFUAwwsAAAIAWwDECwAAAgBUAMULAAABAEwAxgsAAAEAQAABKgAFFAgIGgAFAJ4cAA==.',['夾子']='夾子:BAEAKgAECggICAAAAA==.',['宗桑']='宗桑打滚:BAEBKgAFFH8IAAICAAQIuSTrBQA1AQTBCwAAAgBcAMILAAACAGMAwwsAAAIAWgDECwAAAgBQAAIABAi5JOsFADUBBMELAAACAFwAwgsAAAIAYwDDCwAAAgBaAMQLAAACAFAAASoABRQICAgADAA+GQA=.',['家养']='家养老多比:BAEAKgAECgcIDAABKgAFFAgIMgAJAP0jAA==.',['弑君']='弑君丶爆牌贼:BAEAKgAFFAYIAgAAAA==.',['心伊']='心伊丶:BAEAKgAECggIEgABKgAFFAUIKgACAEAdAA==.',['是芒']='是芒果味的:BAEAKgAECggIEQABKgAFFAUIKgACAEAdAA==.',['暗影']='暗影锋:BAEBKgAFFH8SAAIBAAgItBgsBAAUAgjBCwAAAgBSAMILAAADAFcAwwsAAAIANwDECwAAAwBOAMULAAADAEoAxgsAAAMAUwDHCwAAAQAXAMgLAAABACMAAQAICLQYLAQAFAIIwQsAAAIAUgDCCwAAAwBXAMMLAAACADcAxAsAAAMATgDFCwAAAwBKAMYLAAADAFMAxwsAAAEAFwDICwAAAQAjAAEqAAUUCAgaAAUAnhwA.',['游子']='游子云:BAEBKgAECn8fAAINAAgI4CBBBwCQAgjBCwAAAwBMAMILAAAEAFYAwwsAAAQAWADECwAABABaAMULAAAEAFYAxgsAAAUAVwDHCwAAAwBUAMgLAAAEAE8ADQAICOAgQQcAkAIIwQsAAAMATADCCwAABABWAMMLAAAEAFgAxAsAAAQAWgDFCwAABABWAMYLAAAFAFcAxwsAAAMAVADICwAABABPAAAA.',['灬一']='灬一叶之秋:BAEBKgAFFH8bAAMOAAYIjB4QAQBOAQbBCwAABgBWAMILAAAGAGIAwwsAAAYAXgDECwAABgA/AMULAAACAD8AxgsAAAEALwAPAAYI7h1cAwCSAQbBCwAABQBOAMILAAAFAGIAwwsAAAUAXgDECwAABQA/AMULAAABAD8AxgsAAAEALwAOAAUISxoQAQBOAQXBCwAAAQBWAMILAAABAEsAwwsAAAEANQDECwAAAQA2AMULAAABADYAASoABRQICBoABQCeHAA=.',['灰麟']='灰麟:BAEBKgAFFH8HAAMLAAQIaxtZCwD1AATBCwAAAgBKAMILAAACADgAwwsAAAIATwDECwAAAQAyAAsAAwhrG1kLAPUAA8ELAAACAEoAwgsAAAIAOADDCwAAAgBPAAQAAQgAAMwgAAAAAcQLAAABADIAASoABRQICBoABQCeHAA=.',['犬山']='犬山明里:BAEAKgAECgQIBAABKgAFFAgILwACAHYlAA==.',['白魔']='白魔仙:BAECKgAFFH8JAAMQAAUIABBxEgCtAAXBCwAAAQAnAMILAAABAA4AwwsAAAEAFQDHCwAABABHAMgLAAACADkAEAADCM4JcRIArQADwQsAAAEAJwDCCwAAAQAOAMMLAAABABUAEQACCLgHghEAawACxwsAAAQAGgDICwAAAgAMACoABAp/GgADEAAICOkcxxEA7QEAEAAICOkcxxEA7QEAEQABCGcDtG0ACQAAASoABRQFCCoAAgBAHQA=.',['绿色']='绿色喷火龙:BAEBKgAFFH8OAAMSAAYIDRe6EABWAQbBCwAAAwBVAMILAAADAEUAwwsAAAMAXQDECwAAAwBMAMULAAABABkAxgsAAAEAFQASAAYIDRe6EABWAQbBCwAAAgBVAMILAAACAEUAwwsAAAIAXQDECwAAAgBMAMULAAABABkAxgsAAAEAFQATAAQI4hc5AwDrAATBCwAAAQBQAMILAAABAEsAwwsAAAEAGgDECwAAAQBPAAAA.',['老乱']='老乱丶:BAEBKgAFFH8IAAILAAQI4wqFGACEAATBCwAAAgAAAMILAAACAC0AwwsAAAIAJgDECwAAAgAUAAsABAjjCoUYAIQABMELAAACAAAAwgsAAAIALQDDCwAAAgAmAMQLAAACABQAASoABRQICBoABQCeHAA=.',['自行']='自行车汆丸子:BAEBKgAFFH8JAAILAAUIsRsnCwD4AAXBCwAAAgBYAMILAAACAFcAwwsAAAIALwDECwAAAgBPAMULAAABADwACwAFCLEbJwsA+AAFwQsAAAIAWADCCwAAAgBXAMMLAAACAC8AxAsAAAIATwDFCwAAAQA8AAEqAAUUCAgaAAUAnhwA.',['菜刀']='菜刀飞电线:BAEBKgAFFH8GAAIUAAYIGQ0AAAAAAAbBCwAAAQASAMILAAABAEAAwwsAAAEACADECwAAAQAuAMULAAABAEYAxgsAAAEABQADAAYIGQ0AAAAAAAbBCwAAAQASAMILAAABAEAAwwsAAAEACADECwAAAQAuAMULAAABAEYAxgsAAAEABQABKgAFFAgIGgAFAJ4cAA==.',['萌萌']='萌萌的萌二蛋:BAEBKgAFFH8IAAIKAAQIHBo4GgDqAATBCwAAAgA6AMILAAACAE4AwwsAAAIAPwDECwAAAgA5AAoABAgcGjgaAOoABMELAAACADoAwgsAAAIATgDDCwAAAgA/AMQLAAACADkAASoABRQICBoABQCeHAA=.',['蜀黍']='蜀黍给你糖吃:BAEBKgAFFH8JAAQPAAYIvyK4AwCEAQbBCwAAAgBfAMILAAACAE8AwwsAAAEATgDECwAAAQBDAMULAAABAGMAxgsAAAIAWgAPAAQI2x+4AwCEAQTBCwAAAQBfAMILAAABACcAxQsAAAEAYwDGCwAAAgBaABUAAwgdIK0HAOsAA8ELAAABAFgAwgsAAAEATwDDCwAAAQBOAA4AAQgAADMjAAAAAcQLAAABAEMAASoABRQICBoABQCeHAA=.',['诸国']='诸国化为火海:BAECKgAFFH8cAAINAAgI+A8DBgC5AQjBCwAABQBGAMILAAAEADkAwwsAAAQATwDECwAAAwA+AMULAAABAAEAxgsAAAQAFADHCwAABAAvAMgLAAADAAkADQAICPgPAwYAuQEIwQsAAAUARgDCCwAABAA5AMMLAAAEAE8AxAsAAAMAPgDFCwAAAQABAMYLAAAEABQAxwsAAAQALwDICwAAAwAJACoABAp/MAACDQAICOIfpwwARAIADQAICOIfpwwARAIAAAA=.',['香辣']='香辣兰花蟹:BAEBKgAFFH8PAAMMAAYILxH4DwD7AAbBCwAABABXAMILAAADAEgAwwsAAAMADgDECwAAAwBRAMULAAABAAQAxgsAAAEAJwAMAAQIjRL4DwD7AATBCwAAAgBXAMMLAAACAA4AxAsAAAIAUQDGCwAAAQAnABYABQjFDtsOALwABcELAAACABIAwgsAAAMAUADDCwAAAQAoAMQLAAABAAQAxQsAAAEACwAAAA==.',['麦明']='麦明河丷:BAEAKgAECggICAABKgAFFAgIGgAFAJ4cAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end