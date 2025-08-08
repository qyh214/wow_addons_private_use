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
 local lookup = {'Priest-Shadow','Paladin-Retribution','Warrior-Fury','Priest-Discipline','Warlock-Destruction','Warlock-Affliction','Monk-Windwalker','Monk-Mistweaver','Evoker-Devastation','Evoker-Augmentation','Warrior-Arms','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Druid-Balance','Hunter-Marksmanship','Paladin-Protection','Shaman-Enhancement','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Demonology','Paladin-Holy',}; local provider = {region='CN',realm='伊森利恩',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Ch='Chikoritam:BAEAKgAECggIEwABKgAFFAgIbgABAJ8gAA==.',Fi='Fierambras:BAEBKgAFFH8KAAICAAUItB9NNgARAQXCCwAAAgBdAMMLAAACAF0AxAsAAAIAVADFCwAAAgA9AMYLAAACAEsAAgAFCLQfTTYAEQEFwgsAAAIAXQDDCwAAAgBdAMQLAAACAFQAxQsAAAIAPQDGCwAAAgBLAAEqAAUUCAgyAAMA2SMA.',Lo='Louise:BAECKgAFFH9PAAMBAAgI9SO6AQC5AgjBCwAAEABgAMILAAANAGMAwwsAAA4AYgDECwAACwBTAMULAAAHAGMAxgsAAAgAXgDHCwAABQBMAMgLAAAFAE8AAQAICPUjugEAuQIIwQsAABAAYADCCwAADQBjAMMLAAAOAGIAxAsAAAkAUwDFCwAABwBjAMYLAAAIAF4AxwsAAAUATADICwAABQBPAAQAAQgAAGsuAAAAAcQLAAACAC4AKgAECn88AAIBAAgIBCYLAwDzAgABAAgIBCYLAwDzAgAAAA==.',Me='Meekko:BAEAKgAFFAQIBAABKgAFFAgIFwAFAFwlAA==.',Re='Retrieving:BAEBKgAFFH8XAAMFAAgIXCXCAAD6AgjBCwAABABjAMILAAAEAGIAwwsAAAMAXADECwAAAwBhAMULAAADAGEAxgsAAAIAXwDHCwAAAgBZAMgLAAACAF8ABQAICCIlwgAA+gIIwQsAAAIAYwDCCwAAAgBeAMMLAAACAFwAxAsAAAIAYQDFCwAAAgBhAMYLAAACAF8AxwsAAAIAWQDICwAAAgBfAAYABQi2HFgAAIgBBcELAAACAGMAwgsAAAIAYgDDCwAAAQBUAMQLAAABAGEAxQsAAAEACgAAAA==.',Sa='Sarff:BAEBKgAFFH8FAAMFAAUIfw9mMgCmAAXBCwAAAQAFAMILAAABAAUAxAsAAAEAKwDHCwAAAQBRAMgLAAABAEIABQADCOwcZjIApgADxAsAAAEAKwDHCwAAAQBRAMgLAAABAEIABgACCBIClBwASgACwQsAAAEABQDCCwAAAQAFAAEqAAUUCAgyAAMA2SMA.',Se='Sekir:BAEAKgADCgIIAgAAAA==.',To='Torust:BAEBKgAFFH8GAAMHAAQIDBXZEACqAATBCwAAAgBbAMILAAACADwAwwsAAAEACQDECwAAAQAIAAcAAgjDHdkQAKoAAsELAAABAFsAwgsAAAEAPAAIAAQITw+PIQCcAATBCwAAAQARAMILAAABADkAwwsAAAEAKgDECwAAAQADAAAA.',Yi='Yiken:BAEBKgAFFH8FAAIBAAUILA9CEgDRAAXBCwAAAQArAMILAAABADUAwwsAAAEAFgDECwAAAQAYAMYLAAABACQAAQAFCCwPQhIA0QAFwQsAAAEAKwDCCwAAAQA1AMMLAAABABYAxAsAAAEAGADGCwAAAQAkAAEqAAUUCAguAAkANB0A.',['一坑']='一坑坑:BAECKgAFFH8uAAMJAAgINB0LBwAcAgjBCwAACwBMAMILAAALAFIAwwsAAAkAXADECwAABgBNAMULAAAEAC4AxgsAAAMAOADHCwAAAQBUAMgLAAABAFMACQAICOQbCwcAHAIIwQsAAAoATADCCwAACgBLAMMLAAAIAEsAxAsAAAQATQDFCwAABAAuAMYLAAADADgAxwsAAAEAVADICwAAAQBTAAoABAjIHx8BAAYBBMELAAABAEUAwgsAAAEAUgDDCwAAAQBcAMQLAAACAE0AKgAECn8wAAIJAAgI0CHODABxAgAJAAgI0CHODABxAgAAAA==.',['不能']='不能摆烂哟丶:BAEBKgAFFH8HAAMGAAUIYxwUFACdAAXECwAAAQANAMULAAABAFQAxgsAAAEAKgDHCwAAAgBZAMgLAAACAEoABQADCBQgRjIApgADxAsAAAEADQDHCwAAAgBZAMgLAAACAEoABgACCLIYFBQAnQACxQsAAAEAVADGCwAAAQAqAAEqAAUUCAgyAAMA2SMA.',['丶不']='丶不努力:BAECKgAFFH8aAAMLAAgIqyXaAgBCAgjBCwAABgBjAMILAAAEAGEAwwsAAAQAYwDECwAABQBjAMULAAADAGIAxgsAAAIAYwDHCwAAAQBgAMgLAAABAFMACwAGCIAm2gIAQgIGwQsAAAYAYwDCCwAABABhAMMLAAADAGMAxQsAAAMAYgDGCwAAAgBjAMcLAAABAGAAAwADCIEjJzEAcAADwwsAAAEAYgDECwAABQBjAMgLAAABAFMAKgAECn8iAAMLAAgI2ibFBgCnAgALAAcI1CbFBgCnAgADAAQIyybtRQBTAQAAAA==.',['冬会']='冬会初雪:BAEBKgAFFH8IAAMMAAQICSLlBQArAQTBCwAAAgBdAMILAAACAGEAwwsAAAIARgDECwAAAgBJAAwABAgJIuUFACsBBMELAAABAF0AwgsAAAIAYQDDCwAAAQBGAMQLAAABAEkADQADCNoQ3BIAjgADwQsAAAEALwDDCwAAAQAmAMQLAAABAD8AASoABRQICDIAAwDZIwA=.',['冰公']='冰公主:BAEAKgAFFAgIBAAAAA==.',['只为']='只为你微笑:BAEBKgAFFH8RAAMBAAYIJhU9AwCgAQbBCwAABABHAMILAAAEAFcAwwsAAAQASQDECwAAAwBDAMULAAABAAsAxgsAAAEAGgABAAYIJhU9AwCgAQbBCwAAAwBHAMILAAADAFcAwwsAAAMASQDECwAAAgBDAMULAAABAAsAxgsAAAEAGgAOAAQIdgstFQCXAATBCwAAAQAAAMILAAABAD4AwwsAAAEAGQDECwAAAQAwAAAA.',['啾啾']='啾啾秋:BAEBKgAFFH8JAAIFAAMImAauOACNAAPBCwAABAAXAMILAAAEABEAwwsAAAEACQAFAAMImAauOACNAAPBCwAABAAXAMILAAAEABEAwwsAAAEACQAAAA==.',['喷嘴']='喷嘴:BAEAKgAFFAQIBAAAAA==.',['在逃']='在逃小坑:BAEBKgAFFH8FAAIPAAUI5CEfBQBVAQXBCwAAAQBiAMILAAABAFcAwwsAAAEAWwDECwAAAQBSAMYLAAABAEYADwAFCOQhHwUAVQEFwQsAAAEAYgDCCwAAAQBXAMMLAAABAFsAxAsAAAEAUgDGCwAAAQBGAAEqAAUUCAguAAkANB0A.',['奶淇']='奶淇淋:BAEAKgAFFAYIAwABKgAFFAgIMgADANkjAA==.',['嫑嫑']='嫑嫑丶:BAEBKgAFFH8GAAIOAAYIDQm0EwAVAQbBCwAAAQA4AMILAAABACEAwwsAAAEADwDECwAAAQAJAMULAAABAAYAxgsAAAEABAAOAAYIDQm0EwAVAQbBCwAAAQA4AMILAAABACEAwwsAAAEADwDECwAAAQAJAMULAAABAAYAxgsAAAEABAABKgAFFAgIDQAQACwVAA==.',['宁丶']='宁丶宁:BAEBKgAFFH8cAAQBAAgIihUUBQDzAQjBCwAABgBgAMILAAAGADcAwwsAAAUAOwDECwAAAwAqAMULAAACAEsAxgsAAAIAMQDHCwAAAgAtAMgLAAACAAQAAQAICIoVFAUA8wEIwQsAAAEAYADCCwAAAQA3AMMLAAABADsAxAsAAAEAKgDFCwAAAQBLAMYLAAABADEAxwsAAAEALQDICwAAAQAEAA4ACAiyD1oNAFABCMELAAADADoAwgsAAAEAPQDDCwAABABIAMQLAAACABAAxQsAAAEACADGCwAAAQAsAMcLAAABABgAyAsAAAEACwAEAAIIlw0gHwCAAALBCwAAAgAPAMILAAAEADYAAAA=.',['安爪']='安爪:BAEBKgAFFH8IAAIRAAgIvx27AgBoAgjBCwAAAQA0AMILAAABAFgAwwsAAAEAXADECwAAAQBAAMULAAABAEkAxgsAAAEAWADHCwAAAQBOAMgLAAABADsAEQAICL8duwIAaAIIwQsAAAEANADCCwAAAQBYAMMLAAABAFwAxAsAAAEAQADFCwAAAQBJAMYLAAABAFgAxwsAAAEATgDICwAAAQA7AAAA.',['我不']='我不敢过江:BAEAKgAFFAYIAgAAAA==.',['末秋']='末秋丶:BAEBKgAFFH8NAAIQAAgILBWfBgD/AQjBCwAAAwAnAMILAAACAFkAwwsAAAIANwDECwAAAgBXAMULAAABAEYAxgsAAAEAPgDHCwAAAQAJAMgLAAABADUAEAAICCwVnwYA/wEIwQsAAAMAJwDCCwAAAgBZAMMLAAACADcAxAsAAAIAVwDFCwAAAQBGAMYLAAABAD4AxwsAAAEACQDICwAAAQA1AAAA.',['杜蓋']='杜蓋克蘭:BAEBKgAFFH8yAAIDAAgI2SPrAADtAgjBCwAABwBiAMILAAAHAGAAwwsAAAcAYQDECwAABwBhAMULAAAGAGAAxgsAAAYAXQDHCwAABQBIAMgLAAAFAFcAAwAICNkj6wAA7QIIwQsAAAcAYgDCCwAABwBgAMMLAAAHAGEAxAsAAAcAYQDFCwAABgBgAMYLAAAGAF0AxwsAAAUASADICwAABQBXAAAA.',['欣訫']='欣訫向雪:BAEAKgAECggIEAABKgAFFAgIEQABACYVAA==.',['湖畔']='湖畔萨:BAEBKgAFFH8gAAMMAAcI6ALfKwDHAAfBCwAABwANAMILAAAHAAgAwwsAAAkADgDECwAABAAAAMULAAACAAMAxgsAAAIAAADHCwAAAQADAAwABwjoAt8rAMcAB8ELAAAHAA0AwgsAAAcACADDCwAACAAOAMQLAAAEAAAAxQsAAAIAAwDGCwAAAgAAAMcLAAABAAMAEgABCOcldxUAcgABwwsAAAEAYQABKgAFFAgIAwATAAAAAA==.',['碎月']='碎月不贪微凉:BAEBKgAECn8WAAMUAAgIbg0JbQAdAQjBCwAABAAjAMILAAACABcAwwsAAAMANQDECwAAAwBEAMULAAADADAAxgsAAAQAMgDHCwAAAQAEAMgLAAACABkAFAAHCGUPCW0AHQEHwQsAAAMAIwDCCwAAAQAXAMMLAAACADUAxAsAAAIARADFCwAAAgAwAMYLAAADADIAyAsAAAEAGQAVAAgIKwMyRACsAAjBCwAAAQAJAMILAAABAAkAwwsAAAEABgDECwAAAQAFAMULAAABAAgAxgsAAAEABADHCwAAAQAEAMgLAAABAAwAASoABRQICDIAAwDZIwA=.',['秒殺']='秒殺丨丈母娘:BAEAKgAECggIBgAAAA==.',['糖糖']='糖糖瑪奇朵:BAEBKgAFFH8PAAMFAAYIoCOjCwDTAQbBCwAABABUAMILAAADAGMAwwsAAAMAXwDECwAAAwBRAMULAAABAF0AxgsAAAEAUwAFAAYIoCOjCwDTAQbBCwAAAwBUAMILAAACAGMAwwsAAAIAXwDECwAAAgBRAMULAAABAF0AxgsAAAEAUwAWAAQI5AYkCAC0AATBCwAAAQAjAMILAAABAAgAwwsAAAEACADECwAAAQA7AAEqAAUUCAgyAAMA2SMA.',['罗马']='罗马全面战争:BAEAKgAECgcIAwAAAA==.',['荼蘼']='荼蘼晚开:BAEAKgAECgcIBwABKgAFFAQIDgABAKMaAA==.',['萌萌']='萌萌哒酋长:BAECKgAFFH8FAAMRAAQIyhcSGQCvAATBCwAAAgBRAMILAAABADcAwwsAAAEALQDECwAAAQApABEABAjKFxIZAK8ABMELAAABAFEAwgsAAAEANwDDCwAAAQAtAMQLAAABACkAFwABCEQUKhQARgABwQsAAAEAMwAqAAQKf1AABBcACAidJfUBANkCABcACAidJfUBANkCABEACAh4CMwxANEAAAIABggdCnPTALMAAAAA.',['雷光']='雷光凄美啊:BAEAKgAFFAgIBAAAAA==.',['霂影']='霂影:BAEBKgAFFH8JAAMOAAgILx6NBwB8AQjBCwAAAgBAAMILAAABAEoAwwsAAAEARADECwAAAQBKAMULAAABAFMAxgsAAAEAUgDHCwAAAQBgAMgLAAABAEgADgAGCBodjQcAfAEGwQsAAAIAQADCCwAAAQBKAMMLAAABAEQAxAsAAAEASgDFCwAAAQBTAMYLAAABAFIABAACCOQgLQsAwAACxwsAAAEAYADICwAAAQBIAAAA.',['露娜']='露娜米斯:BAEAKgAFFAgIBAAAAA==.',['飘荡']='飘荡的秋千:BAEBKgAFFH8JAAILAAYILh1uEQD/AAbBCwAAAQBbAMILAAACAFIAwwsAAAIANwDECwAAAgBcAMULAAABAD4AxgsAAAEAUQALAAYILh1uEQD/AAbBCwAAAQBbAMILAAACAFIAwwsAAAIANwDECwAAAgBcAMULAAABAD4AxgsAAAEAUQABKgAFFAgIMgADANkjAA==.',['麻辣']='麻辣牛肉丶:BAEAKgAFFAYIAgABKgAFFAgIMgADANkjAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end