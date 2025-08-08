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
 local lookup = {'Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Evoker-Devastation','Mage-Arcane','Warlock-Affliction','Shaman-Elemental','Shaman-Enhancement','Hunter-Marksmanship','Paladin-Protection','Paladin-Retribution','Shaman-Restoration','Hunter-BeastMastery','Priest-Holy','Priest-Discipline','Priest-Shadow','DeathKnight-Frost','Warlock-Demonology','Warrior-Arms','Warrior-Fury','Warrior-Protection','Evoker-Preservation','Druid-Balance','Druid-Restoration',}; local provider = {region='CN',realm='死亡之翼',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Bx='Bxdest:BAECKgAFFH8TAAIBAAgIsyGeBgApAgjBCwAAAgBEAMILAAACAFwAwwsAAAIAXgDECwAAAwBjAMULAAADAGIAxgsAAAMAYwDHCwAAAgBYAMgLAAACAD8AAQAICLMhngYAKQIIwQsAAAIARADCCwAAAgBcAMMLAAACAF4AxAsAAAMAYwDFCwAAAwBiAMYLAAADAGMAxwsAAAIAWADICwAAAgA/ACoABAp/GwACAQAICFomAQEADQMAAQAICFomAQEADQMAAAA=.',De='Demonssouls:BAEBKgAFFH8SAAMCAAgIOhteDQC7AQjBCwAAAwBcAMILAAADAF8AwwsAAAMAYgDECwAAAwA0AMULAAACAFEAxgsAAAIATwDHCwAAAQANAMgLAAABABsAAgAGCPciXg0AuwEGwQsAAAIAXADCCwAAAgBfAMMLAAACAGIAxAsAAAIAMADFCwAAAQBRAMYLAAABAE8AAwAICGsN0AQAnQEIwQsAAAEAKQDCCwAAAQAtAMMLAAABADwAxAsAAAEANADFCwAAAQAkAMYLAAABAA8AxwsAAAEADQDICwAAAQAbAAEqAAUUCAgYAAEANRMA.',Ho='Honey:BAEAKgAFFAgIAgABKgAFFAgIGAABADUTAA==.',Ji='Jieshen:BAEAKgAFFAQIAgABKgAFFAgIGAABADUTAA==.',Mi='Mirrak:BAEBKgAFFH8GAAIEAAYIqhatDwBmAQbBCwAAAQBUAMILAAABAFMAwwsAAAEAMQDECwAAAQANAMULAAABADkAxgsAAAEAEAAEAAYIqhatDwBmAQbBCwAAAQBUAMILAAABAFMAwwsAAAEAMQDECwAAAQANAMULAAABADkAxgsAAAEAEAABKgAFFAYIKwAFABkhAA==.',Pi='Pianoss:BAECKgAFFH8OAAMBAAMIXyFlCAAiAQPBCwAABgBfAMILAAAFAFkAwwsAAAMARgABAAMIHyFlCAAiAQPBCwAABQBfAMILAAAFAFkAwwsAAAIARAAGAAII6xf8FwB/AALBCwAAAQAzAMMLAAABAEYAKgAECn8kAAMBAAgIsyWfAwDjAgABAAgIrCWfAwDjAgAGAAMIZiGuGQAiAQAAAA==.',Ve='Vexshaman:BAECKgAFFH9dAAMHAAgIuyCDAgBIAgjBCwAAEwBdAMILAAARAGAAwwsAAA8AXADECwAADwBYAMULAAAJAFgAxgsAAAYANQDHCwAABgBTAMgLAAAGAE8ABwAHCKQfgwIASAIHwQsAAAgAXQDCCwAABgBgAMMLAAAJAFsAxAsAAA8AWADFCwAAAQApAMcLAAAGAFMAyAsAAAYATwAIAAUIGSCdBQCxAQXBCwAACwBXAMILAAALAFoAwwsAAAYAXADFCwAACABYAMYLAAAGADUAKgAECn87AAMHAAgIHCVKEQBiAgAIAAgIziQADgBpAgAHAAcIxCNKEQBiAgAAAA==.',Wa='Warlockshawn:BAEAKgAFFAgIAgAAAA==.',Xi='Xiaov:BAEBKgAFFH8GAAIJAAYIZyAkDQCHAQbBCwAAAQBbAMILAAABAFwAwwsAAAEAXQDECwAAAQBZAMULAAABADAAxgsAAAEAVwAJAAYIZyAkDQCHAQbBCwAAAQBbAMILAAABAFwAwwsAAAEAXQDECwAAAQBZAMULAAABADAAxgsAAAEAVwABKgAFFAgIGAABADUTAA==.',Yo='Yongsinsfury:BAEAKgAFFAIIAgABKgAFFAgIGAABADUTAA==.',Ze='Zetalive:BAEBKgAFFH8GAAICAAYIVBGJDAAKAQbBCwAAAQBXAMILAAABAEEAwwsAAAEAIgDECwAAAQAiAMULAAABAA0AxgsAAAEAFQACAAYIVBGJDAAKAQbBCwAAAQBXAMILAAABAEEAwwsAAAEAIgDECwAAAQAiAMULAAABAA0AxgsAAAEAFQABKgAFFAYIEwAKACAVAA==.Zetall:BAECKgAFFH8TAAMKAAYIIBUhCQDPAAbBCwAABABZAMILAAAFAFUAwwsAAAQAPADECwAABABIAMULAAABABQAxgsAAAEADgAKAAYIEREhCQDPAAbBCwAAAwA7AMILAAAEAD8AwwsAAAQAPADECwAABABIAMULAAABABQAxgsAAAEADgALAAIIMCJrYQCtAALBCwAAAQBZAMILAAABAFUAKgAECn8WAAMLAAgITSX8FQDAAgALAAgITSX8FQDAAgAKAAEIPxGpWwA0AAAAAA==.Zetatotem:BAEAKgADCgYIBgABKgAFFAYIEwAKACAVAA==.',['世界']='世界萨归来:BAECKgAFFH8NAAIIAAMIkSUHBABTAQPBCwAABQBjAMILAAAFAGIAwwsAAAMAWgAIAAMIkSUHBABTAQPBCwAABQBjAMILAAAFAGIAwwsAAAMAWgAqAAQKf0gAAggACAhQJs0AABEDAAgACAhQJs0AABEDAAAA.',['丶被']='丶被谎言湮没:BAEAKgAFFAYIAgABKgAFFAgIGAABADUTAA==.',['丸犊']='丸犊子了:BAECKgAFFH8JAAMHAAUITRowFADLAAXBCwAAAgBDAMILAAACAFMAwwsAAAIAGwDECwAAAgBWAMYLAAABAFsABwAECDMXMBQAywAEwQsAAAEAQwDCCwAAAQBTAMMLAAABABsAxAsAAAEAVgAMAAUI8wm3FwDGAAXBCwAAAQAZAMILAAABACkAwwsAAAEACgDECwAAAQAKAMYLAAABABgAKgAECn8WAAMMAAgIXRqKIwADAgAMAAgIXRqKIwADAgAHAAYIawtnUgDQAAABKgAFFAgIFAABACMiAA==.',['九千']='九千七丶德:BAEAKgAECgUIBQABKgAFFAMICAANAMAkAA==.九千七丶死:BAEAKgAECgUICAABKgAFFAMICAANAMAkAA==.九千七丶猎:BAECKgAFFH8IAAINAAMIwCTvBwBIAQPBCwAAAwBfAMILAAADAFoAwwsAAAIAXwANAAMIwCTvBwBIAQPBCwAAAwBfAMILAAADAFoAwwsAAAIAXwAqAAQKfxYAAg0ACAi7JuIBABgDAA0ACAi7JuIBABgDAAAA.九千七丶贼:BAEAKgADCgQIBAABKgAFFAMICAANAMAkAA==.',['仮面']='仮面超人:BAEBKgAFFH8GAAIBAAYIqxo7EQCBAQbBCwAAAQAEAMILAAABAF4AwwsAAAEARQDECwAAAQA2AMULAAABAFUAxgsAAAEAVwABAAYIqxo7EQCBAQbBCwAAAQAEAMILAAABAF4AwwsAAAEARQDECwAAAQA2AMULAAABAFUAxgsAAAEAVwABKgAFFAgIGAABADUTAA==.',['你脚']='你脚下有居居:BAEBKgAFFH8QAAQOAAgINiLdAADAAgjBCwAAAgBjAMILAAACAGEAwwsAAAIAXwDECwAAAgBWAMULAAACAFsAxgsAAAIANADHCwAAAgBhAMgLAAACAE0ADgAICCci3QAAwAIIwQsAAAEAYwDCCwAAAQBgAMMLAAABAF8AxAsAAAEAVgDFCwAAAQBbAMYLAAABADQAxwsAAAEAYQDICwAAAQBNAA8ABggaEXILAPkABsELAAABAD8AwgsAAAEAYQDDCwAAAQAUAMQLAAABAEIAxwsAAAEAEgDICwAAAQASABAAAgjtDnEWALAAAsULAAABABgAxgsAAAEAMwAAAA==.',['你说']='你说个鸡毛:BAEBKgAFFH8IAAIMAAQI5w2oFgDLAATBCwAAAgAsAMILAAACACAAwwsAAAIAHQDECwAAAgArAAwABAjnDagWAMsABMELAAACACwAwgsAAAIAIADDCwAAAgAdAMQLAAACACsAASoABRQICBgAAQA1EwA=.',['元素']='元素控:BAEAKgAFFAcIAgABKgAFFAgIGAABADUTAA==.',['冰雪']='冰雪丷:BAEAKgAECggIDQABKgAFFAgIHAANANogAA==.',['北极']='北极熊是真熊:BAEBKgAFFH8MAAMNAAQIASS+HwAPAQTBCwAABABhAMILAAAEAGMAwwsAAAMATwDECwAAAQBbAA0ABAgBJL4fAA8BBMELAAAEAGEAwgsAAAQAYwDDCwAAAgBPAMQLAAABAFsACQABCNIMNCYASAABwwsAAAEAIAAAAA==.',['千代']='千代田桃子:BAECKgAFFH8vAAMPAAgIdiUdCACgAQjBCwAACgBfAMILAAAJAGMAwwsAAAcAYwDECwAABgBjAMULAAAEAGMAxgsAAAMAYgDHCwAABQBhAMgLAAADAFEADwAGCB0iHQgAoAEGwQsAAAEAOgDCCwAACQBjAMQLAAAGAGMAxQsAAAQAYwDHCwAABQBhAMgLAAADAFEADgADCDkmEBIAIQEDwQsAAAkAXwDDCwAABwBjAMYLAAADAGIAKgAECn8jAAIOAAgI/CB0DQBpAgAOAAgI/CB0DQBpAgAAAA==.',['呜咪']='呜咪灬:BAEBKgAFFH8vAAMDAAgISx6IBwCpAQjBCwAACwBVAMILAAAKAE8AwwsAAAsAUQDECwAACQA/AMULAAADAEYAxgsAAAEAPgDHCwAAAQBJAMgLAAABAFkAAwAGCK4diAcAqQEGwQsAAAkAVQDCCwAACgBPAMMLAAAKAFEAxAsAAAkAPwDFCwAAAwBGAMYLAAABAD4AEQAECGIcRAYAJAEEwQsAAAIAVQDDCwAAAQAqAMcLAAABAEkAyAsAAAEAWQAAAA==.',['土豆']='土豆拌番茄:BAEBKgAFFH8KAAICAAYI4h9DCwDZAQbBCwAAAwBGAMILAAADAFsAwwsAAAEARgDECwAAAQBLAMULAAABAE0AxgsAAAEAYgACAAYI4h9DCwDZAQbBCwAAAwBGAMILAAADAFsAwwsAAAEARgDECwAAAQBLAMULAAABAE0AxgsAAAEAYgAAAA==.土豆炖烩菜:BAEAKgAFFAgIBAABKgAFFAgICgACAOIfAA==.土豆烧山药:BAEAKgAECggIAQABKgAFFAgICgACAOIfAA==.',['塔楼']='塔楼夜语:BAEBKgAFFH8MAAQSAAQIyyHtAQAsAQTBCwAABABeAMILAAAEAFkAwwsAAAIASwDECwAAAgBNABIABAhOIe0BACwBBMELAAABAF4AwgsAAAEAVQDDCwAAAQBLAMQLAAABAE0AAQAECNEbjQ4A7wAEwQsAAAIATgDCCwAAAgBZAMMLAAABAC0AxAsAAAEALQAGAAIIOhHOFQB7AALBCwAAAQAwAMILAAABACcAASoABRQICBgAAQA1EwA=.',['大酋']='大酋长阿强:BAEBKgAFFH8YAAQBAAgINROFBABpAQjBCwAABABNAMILAAAFAF4AwwsAAAQASgDECwAABABHAMULAAADADcAxgsAAAIAFADHCwAAAQAJAMgLAAABAAwAAQAICDARhQQAaQEIwQsAAAQATQDCCwAABQBeAMMLAAAEAEoAxAsAAAMAOgDFCwAAAQATAMYLAAACABQAxwsAAAEACQDICwAAAQAMABIAAQi/FeYSAFkAAcULAAACADcABgABCAAAuSMAAAABxAsAAAEARwAAAA==.',['奶奶']='奶奶滴鲁讯:BAECKgAFFH8IAAMTAAUIqQl9FABwAAXBCwAABAAyAMILAAABAAYAwwsAAAEALgDFCwAAAQALAMYLAAABAAgAEwAECJMHfRQAcAAEwQsAAAEAMgDCCwAAAQAGAMULAAABAAsAxgsAAAEACAAUAAII2Q12KwBFAALBCwAAAwAYAMMLAAABAC4AKgAECn8fAAQUAAgITxqFJgD1AQAUAAgIqxWFJgD1AQATAAYITxYLNgDtAAAVAAEIZAAAAAAAAAABKgAFFAgIDAAWAHIdAA==.奶奶滴龙玉涛:BAEBKgAFFH8MAAMWAAgIch3NAwACAQjBCwAAAgBXAMILAAACAF4AwwsAAAIAVQDECwAAAgBeAMULAAABAFgAxgsAAAEADADHCwAAAQBOAMgLAAABAFEAFgADCD4gzQMAAgEDxQsAAAEAWADHCwAAAQBOAMgLAAABAFEABAAFCGwcug4A3AAFwQsAAAIASwDCCwAAAgBQAMMLAAACADoAxAsAAAIAWgDGCwAAAQBNAAAA.',['小船']='小船儿:BAEBKgAFFH8GAAILAAYIZhgzHACDAQbBCwAAAQBZAMILAAABAFEAwwsAAAEANADECwAAAQAdAMULAAABAEkAxgsAAAEADgALAAYIZhgzHACDAQbBCwAAAQBZAMILAAABAFEAwwsAAAEANADECwAAAQAdAMULAAABAEkAxgsAAAEADgABKgAFFAgIGAABADUTAA==.',['巧克']='巧克力大福:BAECKgAFFH8MAAICAAQIWhgWEgDxAATBCwAAAgA2AMILAAAEAFYAwwsAAAMALQDECwAAAwBSAAIABAhaGBYSAPEABMELAAACADYAwgsAAAQAVgDDCwAAAwAtAMQLAAADAFIAKgAECn8ZAAICAAgIAiN+EgCTAgACAAgIAiN+EgCTAgAAAA==.',['幼儿']='幼儿园小坏蛋:BAEBKgAFFH8HAAQGAAYIohZ1AAB7AQbBCwAAAgBaAMILAAABAF8AwwsAAAEAKgDECwAAAQBRAMULAAABABUAxgsAAAEAKAAGAAUIPBp1AAB7AQXBCwAAAQBaAMILAAABAF8AwwsAAAEAKgDECwAAAQBRAMYLAAABACgAEgABCDoIzBUAUQABxQsAAAEAFQABAAEIDB9zSgBCAAHBCwAAAQBPAAEqAAUUCAgYAAEANRMA.',['张宪']='张宪:BAEAKgAFFAYIBAAAAA==.',['术之']='术之灬尽头:BAEBKgAFFH8UAAMBAAgIRR/RAwCAAQjBCwAABABSAMILAAAEAGIAwwsAAAQAVgDECwAABAAzAMULAAABAEIAxgsAAAEAQgDHCwAAAQBcAMgLAAABAEIAAQAHCCYg0QMAgAEHwQsAAAQAUgDCCwAABABiAMMLAAAEAFYAxAsAAAMAMwDGCwAAAQBCAMcLAAABAFwAyAsAAAEAQgASAAII+xmhEgBaAALECwAAAQAyAMULAAABAEIAASoABRQICBgAAQA1EwA=.',['枭木']='枭木:BAEBKgAECn8WAAIWAAgIBRIDCQCEAQjBCwAAAwA8AMILAAAEADIAwwsAAAQARQDECwAAAwAyAMULAAADAEIAxgsAAAMALgDHCwAAAQAXAMgLAAABAAYAFgAICAUSAwkAhAEIwQsAAAMAPADCCwAABAAyAMMLAAAEAEUAxAsAAAMAMgDFCwAAAwBCAMYLAAADAC4AxwsAAAEAFwDICwAAAQAGAAEqAAUUBwgxABAAoRkA.',['树狗']='树狗不懂武僧:BAEAKgADCggICAAAAA==.',['烟雨']='烟雨青嘤:BAEBKgAECn8cAAMBAAgIjxdkJwDcAQjBCwAAAwA4AMILAAAEAFcAwwsAAAQAVADECwAABABPAMULAAADAD0AxgsAAAQAKQDHCwAAAwAxAMgLAAADACgAAQAICI8XZCcA3AEIwQsAAAMAOADCCwAABABXAMMLAAAEAFQAxAsAAAMATwDFCwAAAwA9AMYLAAAEACkAxwsAAAMAMQDICwAAAwAoABIAAQgAAB6PAAAAAcQLAAABABcAASoABRQICBgAAQA1EwA=.',['猫猫']='猫猫蛋挞屋:BAEBKgAFFH8OAAMIAAYIgRU+CABaAQbBCwAAAwA4AMILAAADAD8AwwsAAAMANgDECwAAAwArAMULAAABACUAxgsAAAEAPwAIAAYIgRU+CABaAQbBCwAAAwA4AMILAAADAD8AwwsAAAMANgDECwAAAgArAMULAAABACUAxgsAAAEAPwAHAAEIAAA6LQAAAAHECwAAAQADAAAA.猫猫软糖铺:BAEAKgAFFAYIBAABKgAFFAYIDgAIAIEVAA==.',['球球']='球球别奶了:BAEBKgAFFH8GAAIMAAQI/CGhBQAtAQTBCwAAAgBiAMILAAACAFUAwwsAAAEATQDECwAAAQBgAAwABAj8IaEFAC0BBMELAAACAGIAwgsAAAIAVQDDCwAAAQBNAMQLAAABAGAAASoABRQICBgAAQA1EwA=.',['白鸽']='白鸽游酒:BAECKgAFFH8xAAQQAAcIoRn5BAD2AQfBCwAADgBcAMILAAANAEYAwwsAAAsATgDECwAABwBeAMYLAAACAFoAxwsAAAEACwDICwAAAQAyABAABwihGfkEAPYBB8ELAAAIAFwAwgsAAAYARgDDCwAACwBOAMQLAAAHAF4AxgsAAAIAWgDHCwAAAQALAMgLAAABADIADwACCCQQ9iIAaAACwQsAAAEAAADCCwAABwBRAA4AAQiBIeseAGQAAcELAAAFAFUAKgAECn9TAAQPAAgIzCOmFAAgAgAOAAgIdCDOEgAvAgAPAAgI6humFAAgAgAQAAcIGxqpGwCsAQAAAA==.',['神偷']='神偷鲁讯:BAEAKgADCggICAABKgAFFAgIDAAWAHIdAA==.',['腐蚀']='腐蚀劝退:BAEAKgAFFAQIBAABKgAFFAgIGAABADUTAA==.',['花花']='花花家的丫鬟:BAEBKgAFFH8WAAMCAAYIuiW3BwAUAgbBCwAABQBgAMILAAAFAGEAwwsAAAQAYQDECwAABQBaAMULAAACAFwAxgsAAAEAYQACAAYIuiW3BwAUAgbBCwAAAgBgAMILAAACAGEAwwsAAAIAYQDECwAAAwBaAMULAAABAFwAxgsAAAEAYQADAAUILhB1GgDOAAXBCwAAAwA7AMILAAADAD0AwwsAAAIAKgDECwAAAgAzAMULAAABAAIAAAA=.',['苏文']='苏文蔚:BAEBKgAFFH8IAAIIAAQIGR4SCQBIAQTFCwAAAgBeAMYLAAACAFYAxwsAAAIAOADICwAAAgBHAAgABAgZHhIJAEgBBMULAAACAF4AxgsAAAIAVgDHCwAAAgA4AMgLAAACAEcAASoABRQICBgAAQA1EwA=.',['蛮牛']='蛮牛缴斗士:BAEBKgAFFH8GAAIUAAYI0BZ5DACEAQbBCwAAAQBTAMILAAABADAAwwsAAAEAWADECwAAAQBBAMULAAABACwAxgsAAAEAGgAUAAYI0BZ5DACEAQbBCwAAAQBTAMILAAABADAAwwsAAAEAWADECwAAAQBBAMULAAABACwAxgsAAAEAGgAAAA==.',['蝴蝶']='蝴蝶草:BAECKgAFFH8oAAIEAAgIrB4vBAB1AgjBCwAACgBiAMILAAAIAF8AwwsAAAkAWgDECwAABwBjAMULAAADAEIAxgsAAAEAXgDHCwAAAQBUAMgLAAABABQABAAICKweLwQAdQIIwQsAAAoAYgDCCwAACABfAMMLAAAJAFoAxAsAAAcAYwDFCwAAAwBCAMYLAAABAF4AxwsAAAEAVADICwAAAQAUACoABAp/KgACBAAICF0i3xMAKQIABAAICF0i3xMAKQIAAAA=.',['越谷']='越谷小鞠:BAECKgAFFH8OAAILAAcI+RgCCwDzAQfBCwAAAgA6AMILAAADAE8AwwsAAAMATQDECwAAAwAmAMULAAABAEUAxwsAAAEANgDICwAAAQAsAAsABwj5GAILAPMBB8ELAAACADoAwgsAAAMATwDDCwAAAwBNAMQLAAADACYAxQsAAAEARQDHCwAAAQA2AMgLAAABACwAKgAECn8VAAILAAgINiIcJQCGAgALAAgINiIcJQCGAgABKgAFFAgILwAPAHYlAA==.',['这个']='这个德有點肥:BAEBKgAFFH8IAAMXAAYIPhkEFwBhAQbBCwAAAQBJAMILAAABAD4AwwsAAAEAMwDECwAAAQAoAMULAAACAEoAxgsAAAIAPAAXAAYIPhkEFwBhAQbBCwAAAQBJAMILAAABAD4AwwsAAAEAMwDECwAAAQAoAMULAAABAEoAxgsAAAEAPAAYAAIIMAwwEQCsAALFCwAAAQAlAMYLAAABABgAASoABRQICBAADgA2IgA=.这个憎有点肥:BAEAKgAFFAQIBAABKgAFFAgIEAAOADYiAA==.这个萨有点肥:BAEBKgAFFH8IAAMHAAYIIRrABgB4AQbBCwAAAQBEAMILAAABAGIAwwsAAAEAVgDECwAAAQAzAMULAAACABsAxgsAAAIANQAHAAYIIRrABgB4AQbBCwAAAQBEAMILAAABAGIAwwsAAAEAVgDECwAAAQAzAMULAAABABsAxgsAAAEANQAIAAIIsQXTEACnAALFCwAAAQATAMYLAAABAAkAASoABRQICBAADgA2IgA=.这个騎有点肥:BAEBKgAFFH8GAAIDAAYIFhTjDwAmAQbBCwAAAQA9AMILAAABAC8AwwsAAAEAOQDECwAAAQAyAMULAAABADYAxgsAAAEAJQADAAYIFhTjDwAmAQbBCwAAAQA9AMILAAABAC8AwwsAAAEAOQDECwAAAQAyAMULAAABADYAxgsAAAEAJQABKgAFFAgIEAAOADYiAA==.这个骑有点肥:BAEBKgAECn8UAAILAAgI7iOUOwA8AgjBCwAAAwBcAMILAAADAF0AwwsAAAMAXwDECwAAAwBOAMULAAADAGAAxgsAAAMAYADHCwAAAQBNAMgLAAABAFwACwAICO4jlDsAPAIIwQsAAAMAXADCCwAAAwBdAMMLAAADAF8AxAsAAAMATgDFCwAAAwBgAMYLAAADAGAAxwsAAAEATQDICwAAAQBcAAEqAAUUCAgQAA4ANiIA.',['这这']='这这雷迪克:BAEAKgAFFAYIAwABKgAFFAgIDgABAF8hAA==.',['鲁讯']='鲁讯小紫毛:BAEAKgADCgMIAgABKgAFFAgIDAAWAHIdAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end