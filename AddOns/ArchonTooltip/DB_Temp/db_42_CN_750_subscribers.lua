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
 local lookup = {'Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Shaman-Enhancement','DeathKnight-Unholy','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Paladin-Protection','Monk-Windwalker','Monk-Mistweaver','Druid-Balance','Druid-Restoration','Druid-Guardian','Mage-Frost','Mage-Arcane','Mage-Fire','DeathKnight-Blood','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Warlock-Demonology',}; local provider = {region='CN',realm='燃烧之刃',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Fa='Fattycapybar:BAEBKgAFFH8PAAIBAAgIBRdfBQDfAQjBCwAAAwBQAMILAAADAFcAwwsAAAMAUQDECwAAAgBgAMULAAABAC0AxgsAAAEAIQDHCwAAAQAvAMgLAAABACUAAQAICAUXXwUA3wEIwQsAAAMAUADCCwAAAwBXAMMLAAADAFEAxAsAAAIAYADFCwAAAQAtAMYLAAABACEAxwsAAAEALwDICwAAAQAlAAAA.',In='Incre:BAECKgAFFH8GAAMCAAQIfhluBwDtAATBCwAAAgBXAMILAAABACoAwwsAAAEAQQDECwAAAgA3AAIABAh+GW4HAO0ABMELAAABAFcAwgsAAAEAKgDDCwAAAQBBAMQLAAABADcAAwACCEccrC8ARwACwQsAAAEASADECwAAAQAxACoABAp/FAACAwAICN4gixUAQwIAAwAICN4gixUAQwIAASoABRQICB4ABABdFwA=.',Li='Lifengdk:BAEBKgAECn8bAAIFAAgIXh5cGwBcAgjBCwAAAwBGAMILAAADAFQAwwsAAAMAYADECwAABABNAMULAAAEAEcAxgsAAAQARwDHCwAAAwBXAMgLAAADAD4ABQAICF4eXBsAXAIIwQsAAAMARgDCCwAAAwBUAMMLAAADAGAAxAsAAAQATQDFCwAABABHAMYLAAAEAEcAxwsAAAMAVwDICwAAAwA+AAAA.',Rg='Rgdruu:BAEAKgAFFAQIBAAAAA==.',Yz='Yzss:BAEAKgAFFAUIBAABKgAFFAgIHgAEAF0XAA==.',Ze='Zetalili:BAEBKgAFFH8JAAMDAAYI0RM6GQC8AAbBCwAAAgBBAMILAAADAAkAwwsAAAEAJQDECwAAAQAHAMULAAABAEoAxgsAAAEAQgADAAYIBhM6GQC8AAbBCwAAAQA5AMILAAABAAYAwwsAAAEAJQDECwAAAQAHAMULAAABAEoAxgsAAAEAQgACAAIIog5NFQCAAALBCwAAAQBBAMILAAACAAkAAAA=.',['一念']='一念月落乌啼:BAEBKgAECn8fAAMGAAgIpBwZFQAkAgjBCwAAAwBJAMILAAAFAEgAwwsAAAQARADECwAAAwBHAMULAAADAEYAxgsAAAUATQDHCwAABAA7AMgLAAAEAFsABgAICKQcGRUAJAIIwQsAAAIASQDCCwAAAwBIAMMLAAADAEQAxAsAAAIARwDFCwAAAgBGAMYLAAAEAE0AxwsAAAMAOwDICwAAAwBbAAEACAgKGXk2AKwBCMELAAABADgAwgsAAAIAOgDDCwAAAQBCAMQLAAABAEEAxQsAAAEALADGCwAAAQBFAMcLAAABAFcAyAsAAAEAQAABKgAFFAgIHgAEAF0XAA==.',['丨纯']='丨纯田真奈丨:BAEBKgAFFH8MAAMHAAQIASG+EQAGAQTBCwAAAwBTAMILAAADAFQAwwsAAAMAVADECwAAAwBWAAcABAidHr4RAAYBBMELAAACAEEAwgsAAAIAVADDCwAAAgBUAMQLAAACAFYACAAECFIVnDAArAAEwQsAAAEAUwDCCwAAAQAqAMMLAAABACUAxAsAAAEAKwABKgAFFAgIJwAJAEUjAA==.',['丨长']='丨长崎素世丨:BAECKgAFFH8nAAMJAAgIRSNtBwBQAgjBCwAABwBfAMILAAAIAGEAwwsAAAcAXwDECwAABwBPAMULAAADAF0AxgsAAAMASQDHCwAAAgBQAMgLAAACAGAACQAICEUjbQcAUAIIwQsAAAQAXwDCCwAABQBhAMMLAAAEAF8AxAsAAAQATwDFCwAAAwBdAMYLAAADAEkAxwsAAAIAUADICwAAAgBgAAoABAhEDpENAJoABMELAAADACQAwgsAAAMAKADDCwAAAwAgAMQLAAADABQAKgAECn8WAAIJAAgIkiYJHACoAgAJAAgIkiYJHACoAgAAAA==.',['丶浪']='丶浪巫谣:BAEBKgAFFH8YAAMLAAcIIRs4AgCpAQfBCwAABABRAMILAAAEAFEAwwsAAAQAMQDECwAABABdAMULAAAEABEAxgsAAAMAVwDICwAAAQBkAAsABgi+GDgCAKkBBsELAAADAFEAwgsAAAMAUQDDCwAAAwAxAMQLAAADAF0AxQsAAAMAEQDGCwAAAwBXAAwABghsDnIEAHQBBsELAAABAAgAwgsAAAEAHADDCwAAAQACAMQLAAABAEQAxQsAAAEAUQDICwAAAQA/AAAA.',['全要']='全要:BAEBKgAFFH8FAAIDAAQIRxzHLQC3AATBCwAAAgBYAMILAAABAEEAwwsAAAEAPwDECwAAAQASAAMABAhHHMctALcABMELAAACAFgAwgsAAAEAQQDDCwAAAQA/AMQLAAABABIAASoABRQICB4ABABdFwA=.',['友善']='友善和蔼温柔:BAECKgAFFH8sAAQNAAgIuBfUGgBDAQjBCwAACQBaAMILAAAHAF4AwwsAAAgAEwDECwAABQAwAMULAAAFAFIAxgsAAAUABADHCwAAAwBWAMgLAAACAC8ADQAFCPIV1BoAQwEFwQsAAAMAWgDECwAABAAwAMULAAABAFIAxgsAAAIABADICwAAAQAvAA4ABQi0EDcIAPsABcELAAAFAFIAwgsAAAcARwDECwAAAQAPAMYLAAACAAcAxwsAAAMACgAPAAUI8gWpAwCBAAXBCwAAAQAqAMMLAAAIABMAxQsAAAQABADGCwAAAQAEAMgLAAABAAQAKgAECn8ZAAQNAAgISyBlKQAbAgANAAgISyBlKQAbAgAOAAcIixX9LABzAQAPAAEIFAjuMgAlAAAAAA==.',['吕小']='吕小冰:BAEBKgAFFH8dAAIMAAYI+CCGCACnAQbBCwAABwBZAMILAAAHAGIAwwsAAAcAVgDECwAABgBQAMULAAABADwAxgsAAAEAVQAMAAYI+CCGCACnAQbBCwAABwBZAMILAAAHAGIAwwsAAAcAVgDECwAABgBQAMULAAABADwAxgsAAAEAVQABKgAFFAYIIwAQAHQhAA==.',['哈弄']='哈弄弄:BAEBKgAFFH8jAAQQAAYIdCGJBgBkAQbBCwAABwBfAMILAAAHAFwAwwsAAAcAWQDECwAABgBWAMULAAAEAFIAxgsAAAQAQwARAAYIexzfDgB7AQbBCwAAAQBSAMILAAABAFwAwwsAAAEAWQDECwAAAQBOAMULAAABAB8AxgsAAAEAQwAQAAYIwhuJBgBkAQbBCwAAAQBfAMILAAABADoAwwsAAAEAUADECwAAAQAuAMULAAABAFIAxgsAAAEAJgASAAYIyhTEDQBfAQbBCwAABQA2AMILAAAFAFkAwwsAAAUAUwDECwAABABWAMULAAACABwAxgsAAAIACgAAAA==.',['哎哟']='哎哟哎哎:BAEAKgAECggICAABKgAFFAgIHgAEAF0XAA==.',['境外']='境外:BAEBKgAFFH8JAAMFAAgISBdnBABEAgjBCwAAAQBYAMILAAABAAQAwwsAAAEAVADECwAAAQA9AMULAAABAD0AxgsAAAIAVgDHCwAAAQAgAMgLAAABADkABQAICEgXZwQARAIIwQsAAAEAWADCCwAAAQAEAMMLAAABAFQAxAsAAAEAPQDFCwAAAQA9AMYLAAABAFYAxwsAAAEAIADICwAAAQA5ABMAAQjSB1QUADEAAcYLAAABABQAASoABRQICB4ABABdFwA=.',['夜色']='夜色沉寂丶:BAEBKgAECn8VAAIEAAgI5SQbAgD5AgjBCwAAAwBfAMILAAADAFoAwwsAAAMAYQDECwAAAgBhAMULAAADAGEAxgsAAAMAYADHCwAAAgBhAMgLAAACAFYABAAICOUkGwIA+QIIwQsAAAMAXwDCCwAAAwBaAMMLAAADAGEAxAsAAAIAYQDFCwAAAwBhAMYLAAADAGAAxwsAAAIAYQDICwAAAgBWAAEqAAUUBggLAAsA/RUA.',['天然']='天然鸽:BAEBKgAFFH8GAAINAAYIbyLiEACYAQbBCwAAAQBgAMILAAABAF0AwwsAAAEAUwDECwAAAQBdAMULAAABAFoAxgsAAAEATAANAAYIbyLiEACYAQbBCwAAAQBgAMILAAABAF0AwwsAAAEAUwDECwAAAQBdAMULAAABAFoAxgsAAAEATAABKgAFFAgICAAFAOgSAA==.',['奥巴']='奥巴咕丶:BAEBKgAFFH8KAAINAAQIcBOyFwDfAATBCwAAAwAtAMILAAADACsAwwsAAAIAOwDECwAAAgA1AA0ABAhwE7IXAN8ABMELAAADAC0AwgsAAAMAKwDDCwAAAgA7AMQLAAACADUAAAA=.',['宝贝']='宝贝灬宠儿:BAEBKgAFFH8GAAIHAAYIHRRXFgBFAQbBCwAAAQBJAMILAAABABMAwwsAAAEAUQDECwAAAQBRAMULAAABADEAxgsAAAEAIQAHAAYIHRRXFgBFAQbBCwAAAQBJAMILAAABABMAwwsAAAEAUQDECwAAAQBRAMULAAABADEAxgsAAAEAIQABKgAFFAgIBAAUAAAAAA==.',['小屁']='小屁骑丶:BAEBKgAFFH8IAAIJAAQIAB58QgDqAATBCwAAAgBhAMILAAACAEQAwwsAAAIAQADECwAAAgBAAAkABAgAHnxCAOoABMELAAACAGEAwgsAAAIARADDCwAAAgBAAMQLAAACAEAAASoABRQICAoADQBwEwA=.小屁龙丶:BAEAKgAFFAIIAgABKgAFFAgICgANAHATAA==.',['小红']='小红手猎老板:BAEBKgAFFH8KAAMHAAYIPR3qDgCHAQbBCwAAAgBZAMILAAACAFQAwwsAAAIAMADECwAAAgA0AMULAAABAEkAxgsAAAEATgAHAAYIPR3qDgCHAQbBCwAAAQBZAMILAAABAFQAwwsAAAEAMADECwAAAQA0AMULAAABAEkAxgsAAAEATgAIAAQIexXKEQDQAATBCwAAAQA5AMILAAABAFIAwwsAAAEAGADECwAAAQAPAAEqAAUUCAgeAAQAXRcA.',['待宵']='待宵:BAEBKgAFFH8IAAMFAAgI6BI6GQDMAAjBCwAAAQAaAMILAAABAAAAwwsAAAEAHwDECwAAAQAGAMULAAABACoAxgsAAAEAXADHCwAAAQBJAMgLAAABAEkABQAGCAgPOhkAzAAGwQsAAAEAGgDCCwAAAQAAAMMLAAABAB8AxAsAAAEABgDFCwAAAQAqAMYLAAABAFwAEwACCJccHyEAnQACxwsAAAEASQDICwAAAQBJAAAA.',['月儿']='月儿欣欣:BAEAKgAECggIEgAAAA==.',['泰瑞']='泰瑞莉亚:BAEBKgAFFH8hAAIJAAYIZiZQAAAvAgbBCwAABwBjAMILAAAHAGMAwwsAAAcAYwDECwAABgBjAMULAAADAGMAxgsAAAMAXQAJAAYIZiZQAAAvAgbBCwAABwBjAMILAAAHAGMAwwsAAAcAYwDECwAABgBjAMULAAADAGMAxgsAAAMAXQABKgAFFAYIIwAQAHQhAA==.',['烨嬅']='烨嬅:BAECKgAFFH8GAAITAAYIWhz1AADPAQbBCwAAAQBMAMILAAABAFQAwwsAAAEAUwDECwAAAQBQAMULAAABABkAxgsAAAEAXAATAAYIWhz1AADPAQbBCwAAAQBMAMILAAABAFQAwwsAAAEAUwDECwAAAQBQAMULAAABABkAxgsAAAEAXAAqAAQKfyYAAgUACAjtHooqAAwCAAUACAjtHooqAAwCAAAA.',['米莉']='米莉姆丶:BAECKgAFFH8pAAITAAcIMSPqAwAbAgfBCwAACwBaAMILAAAKAGEAwwsAAAkAYQDECwAABgBWAMULAAACAF8AxgsAAAIAVwDHCwAAAQBIABMABwgxI+oDABsCB8ELAAALAFoAwgsAAAoAYQDDCwAACQBhAMQLAAAGAFYAxQsAAAIAXwDGCwAAAgBXAMcLAAABAEgAKgAECn8iAAITAAgIhCTZBADPAgATAAgIhCTZBADPAgAAAA==.',['罗马']='罗马王子:BAEAKgAFFAIIAgAAAA==.',['葉拾']='葉拾壹:BAECKgAFFH8eAAMEAAgIXRdKBQDBAQjBCwAABwBhAMILAAAHAFwAwwsAAAcAVADECwAABQBRAMULAAABADcAxgsAAAEAOwDHCwAAAQAIAMgLAAABABUABAAICF0XSgUAwQEIwQsAAAYAYQDCCwAABgBcAMMLAAAGAFQAxAsAAAIANADFCwAAAQA3AMYLAAABADsAxwsAAAEACADICwAAAQAVAAYABAiZElMMAMkABMELAAABACoAwgsAAAEAMwDDCwAAAQAwAMQLAAADAFEAKgAECn8jAAQEAAgIfCTqBwCtAgAEAAgIfCTqBwCtAgABAAQIhRsKbADoAAAGAAQI9RrKTgDgAAAAAA==.',['虾粥']='虾粥:BAEAKgAECgQIBAABKgAFFAYIBgATAFocAA==.',['西格']='西格格:BAEBKgAFFH8iAAMVAAYIqyWOAQDxAQbBCwAABgBaAMILAAAHAGMAwwsAAAcAYQDECwAABgBjAMULAAAEAF4AxgsAAAQAZAAWAAYI/iJHAgDyAQbBCwAAAQBXAMILAAABAGMAwwsAAAEAWwDECwAAAQBaAMULAAABAEUAxgsAAAEAZAAVAAYI1CSOAQDxAQbBCwAABQBaAMILAAAGAFoAwwsAAAYAYQDECwAABQBjAMULAAADAF4AxgsAAAMAYQABKgAFFAYIIwAQAHQhAA==.',['诸葛']='诸葛钢子:BAEBKgAFFH8IAAIHAAgInANxFQBKAQjBCwAAAQAbAMILAAABABYAwwsAAAEAAADECwAAAQAFAMULAAABAAQAxgsAAAEAAgDHCwAAAQADAMgLAAABAAQABwAICJwDcRUASgEIwQsAAAEAGwDCCwAAAQAWAMMLAAABAAAAxAsAAAEABQDFCwAAAQAEAMYLAAABAAIAxwsAAAEAAwDICwAAAQAEAAEqAAUUCAgeAAQAXRcA.',['路灰']='路灰灰阿:BAEAKgAFFAQIBAABKgAFFAgIHgAEAF0XAA==.',['重铸']='重铸踏风荣光:BAECKgAFFH8LAAILAAMI/RWpDgDEAAPBCwAABABOAMILAAAEAD8AwwsAAAMAGgALAAMI/RWpDgDEAAPBCwAABABOAMILAAAEAD8AwwsAAAMAGgAqAAQKfzsAAgsACAivJB4GANACAAsACAivJB4GANACAAAA.',['难捱']='难捱:BAEAKgADCggICAABKgAFFAgIDgADAIwfAA==.',['风之']='风之雨:BAEBKgAFFH8KAAQCAAYInRjXAABUAQbBCwAAAgBgAMILAAACAGMAwwsAAAIAYADECwAAAgBhAMULAAABAAwAxgsAAAEACQACAAQIKybXAABUAQTBCwAAAQBgAMILAAABAGMAwwsAAAEAYADECwAAAQBhAAMABQh6EGAgAAUBBcELAAABAEUAwgsAAAEAVgDDCwAAAQACAMQLAAABAEoAxgsAAAEACQAXAAEIwAQXLgA/AAHFCwAAAQAMAAEqAAUUCAgeAAQAXRcA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end