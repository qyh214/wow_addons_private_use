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
 local lookup = {'Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Rogue-Assassination','Shaman-Enhancement','Shaman-Restoration','Warlock-Affliction','Paladin-Protection','Evoker-Devastation','Warrior-Arms','Monk-Brewmaster','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Fire','Mage-Arcane','Mage-Frost','Unknown-Unknown','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Rogue-Outlaw','Warrior-Fury','Warrior-Protection','Monk-Windwalker','Paladin-Holy',}; local provider = {region='CN',realm='罗宁',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Fa='Fattyseal:BAEAKgAFFAYIBAABKgAFFAgIIQABAHQeAA==.',Lu='Luvlesshawn:BAEBKgAFFH8SAAMCAAYIPCHCBgA4AQbBCwAAAwBOAMILAAAEAFoAwwsAAAQAWQDECwAABABNAMULAAABAE4AxgsAAAIAWAACAAYIzSDCBgA4AQbBCwAAAgBJAMILAAADAFoAwwsAAAMAWQDECwAAAwBNAMULAAABAE4AxgsAAAIAWAADAAQIuBGuEQCyAATBCwAAAQBOAMILAAABABAAwwsAAAEAKADECwAAAQBHAAAA.',Ne='Nekofriends:BAEBKgAFFH8MAAIEAAgIfxvvAgCQAgjBCwAAAgBGAMILAAACAF0AwwsAAAIAXgDECwAAAgBMAMULAAABAFEAxgsAAAEAVQDHCwAAAQAWAMgLAAABAC4ABAAICH8b7wIAkAIIwQsAAAIARgDCCwAAAgBdAMMLAAACAF4AxAsAAAIATADFCwAAAQBRAMYLAAABAFUAxwsAAAEAFgDICwAAAQAuAAAA.',Ob='Obstagoon:BAECKgAFFH8GAAIFAAYIKhonAQDVAQbBCwAAAQBBAMILAAABAEYAwwsAAAEAWQDECwAAAQBQAMULAAABABMAxgsAAAEAWgAFAAYIKhonAQDVAQbBCwAAAQBBAMILAAABAEYAwwsAAAEAWQDECwAAAQBQAMULAAABABMAxgsAAAEAWgAqAAQKfxcAAgYACAiqIm8MAJQCAAYACAiqIm8MAJQCAAEqAAUUCAgnAAcAViUA.',['下周']='下周一定红:BAEBKgAFFH8IAAIEAAQIUCInFwBhAATBCwAAAgBWAMILAAACAFEAwwsAAAIAXwDECwAAAgBYAAQABAhQIicXAGEABMELAAACAFYAwgsAAAIAUQDDCwAAAgBfAMQLAAACAFgAASoABRQICAgACAAmCwA=.',['予伞']='予伞伞:BAEBKgAFFH8iAAIJAAgITR8FBQBXAgjBCwAABABOAMILAAAFAEMAwwsAAAUAXgDECwAABQBHAMULAAAFAFEAxgsAAAUASgDHCwAAAwBOAMgLAAACAFYACQAICE0fBQUAVwIIwQsAAAQATgDCCwAABQBDAMMLAAAFAF4AxAsAAAUARwDFCwAABQBRAMYLAAAFAEoAxwsAAAMATgDICwAAAgBWAAAA.',['咔咔']='咔咔就是壳:BAEBKgAFFH8IAAIKAAYI2hlrCgBmAQbBCwAAAQA/AMILAAABAD0AwwsAAAEAFgDECwAAAQA5AMULAAACAFUAxgsAAAIAYQAKAAYI2hlrCgBmAQbBCwAAAQA/AMILAAABAD0AwwsAAAEAFgDECwAAAQA5AMULAAACAFUAxgsAAAIAYQAAAA==.',['喵喵']='喵喵布丁:BAEBKgAFFH8NAAMBAAYI0xaPAgCpAQbBCwAAAwBKAMILAAADAFoAwwsAAAMAPQDECwAAAgBcAMULAAABAB8AxgsAAAEAIQABAAYI0xaPAgCpAQbBCwAAAgBKAMILAAACAFoAwwsAAAIAPQDECwAAAgBcAMULAAABAB8AxgsAAAEAIQALAAMIDgNLBwBuAAPBCwAAAQAMAMILAAABAAUAwwsAAAEABgAAAA==.',['安蜜']='安蜜莉雅:BAECKgAFFH86AAMMAAgIxCQJAQCyAgjBCwAADABiAMILAAAKAGAAwwsAAAgAYADECwAACgBfAMULAAAHAFsAxgsAAAQAVgDHCwAABABiAMgLAAADAFsADAAICMQkCQEAsgIIwQsAAAsAYgDCCwAACQBgAMMLAAAHAGAAxAsAAAkAXwDFCwAABwBbAMYLAAAEAFYAxwsAAAQAYgDICwAAAwBbAA0ABAgMAOsXAAcABMELAAABAAAAwgsAAAEAAADDCwAAAQAAAMQLAAABABkAKgAECn9KAAQMAAgIWyRGEwA4AgAMAAgIEyFGEwA4AgANAAcINCHLFQAWAgAOAAIIuxFDYwBnAAAAAA==.',['小昏']='小昏丶:BAEAKgAFFAYIAgAAAA==.',['小红']='小红手丶术吊:BAEAKgAFFAYIBAABKgAFFAgIJwAHAFYlAA==.',['山石']='山石游侠:BAEAKgAECggICwAAAA==.',['师大']='师大保钳工:BAEAKgAFFAYIBAABKgAFFAgIJwAHAFYlAA==.',['恋狐']='恋狐少:BAECKgAFFH8pAAMMAAgIIh4TBAAKAgjBCwAADQBjAMILAAAKAGAAwwsAAAgAXwDECwAABABfAMULAAACAEEAxgsAAAIAXgDHCwAAAQAeAMgLAAABADkADAAICCIeEwQACgIIwQsAAA0AYwDCCwAACQBgAMMLAAAIAF8AxAsAAAQAXwDFCwAAAgBBAMYLAAACAF4AxwsAAAEAHgDICwAAAQA5AA0AAQjUA+QpADwAAcILAAABAAkAKgAECn8wAAIMAAgIHiEJDAB2AgAMAAgIHiEJDAB2AgAAAA==.',['把鲫']='把鲫鱼煎成餅:BAEBKgAFFH8KAAIFAAYIERi5BwBmAQbBCwAAAgBXAMILAAACAE0AwwsAAAIATQDECwAAAgA9AMULAAABABIAxgsAAAEALwAFAAYIERi5BwBmAQbBCwAAAgBXAMILAAACAE0AwwsAAAIATQDECwAAAgA9AMULAAABABIAxgsAAAEALwABKgAFFAgIJwAHAFYlAA==.',['毒蔷']='毒蔷薇:BAECKgAFFH8iAAQOAAQIdiAgCwADAQTBCwAABwBRAMILAAAKAEkAwwsAAAgAXQDECwAACQBUAA4ABAh2ICALAAMBBMELAAAGAFEAwgsAAAUASQDDCwAABgBdAMQLAAAGAFQADAAECIAU+DEAfgAEwQsAAAEANQDCCwAABABDAMMLAAABACQAxAsAAAIAOgANAAMISxJkEQByAAPCCwAAAQAuAMMLAAABAC4AxAsAAAEAFAAqAAQKfzsAAw4ACAi1IWEPAGsCAA4ACAi1IWEPAGsCAAwAAwhNFfRjALMAAAEqAAUUCAgJAAwALx4A.',['比法']='比法思:BAECKgAFFH8yAAQPAAgI/SNwBADBAQjBCwAACwBjAMILAAAMAGIAwwsAAAsAYwDECwAACABiAMULAAAEAGIAxgsAAAIAWADHCwAAAQBWAMgLAAABAEoAEAAGCHUjfwcABwIGwQsAAAMAYQDCCwAAAwBZAMMLAAADAFsAxAsAAAcAYgDGCwAAAQBYAMcLAAABAFYADwAGCOUgcAQAwQEGwQsAAAgAYwDCCwAACQBiAMMLAAAFAGMAxAsAAAEAQQDFCwAABABiAMYLAAABABkAEQACCMcaRh4AQwACwwsAAAMAPgDICwAAAQBKACoABAp/OQAEDwAICM8lRgUA6QIADwAICM8lRgUA6QIAEQAFCGgYzVMAFgEAEAABCPYksCQAbgAAAAA=.',['水原']='水原千鹤丶:BAEAKgAECggICAABKgAFFAgIJwAHAFYlAA==.',['泰丶']='泰丶坦犽:BAEAKgAFFAYIAwABKgAFFAgIJwAHAFYlAA==.',['活力']='活力鱼串:BAECKgAFFH8nAAQHAAYIViWAAwBbAQbBCwAACwBiAMILAAAIAGMAwwsAAAkAWADECwAAAwBhAMULAAAFAF4AxgsAAAMAYAAHAAQIOiSAAwBbAQTBCwAABQBZAMILAAAGAGEAwwsAAAgAVwDGCwAAAgBgAAIABQhhJT4VAFkBBcELAAACAGIAwgsAAAIAYwDDCwAAAQBYAMQLAAABAGEAxgsAAAEAXwADAAMI0iFcEwCnAAPBCwAABABOAMQLAAACADsAxQsAAAUAXgAqAAQKfycAAwcACAh6JYQEAD0CAAcACAgJIoQEAD0CAAMABwj0JD0cAKMBAAAA.',['牙哈']='牙哈马塔立盖:BAEAKgAFFAgIBAABKgAFFAgIJwAHAFYlAA==.',['特红']='特红:BAEBKgAFFH8JAAIGAAYINRh4AQCfAQbBCwAAAQAjAMILAAACAEQAwwsAAAIANgDECwAAAgAiAMULAAABAE8AxgsAAAEARwAGAAYINRh4AQCfAQbBCwAAAQAjAMILAAACAEQAwwsAAAIANgDECwAAAgAiAMULAAABAE8AxgsAAAEARwABKgAFFAgIJwAHAFYlAA==.',['白色']='白色工具人:BAEBKgAFFH8PAAQOAAUIbxDzCwACAQXBCwAABQAnAMILAAAEAB0AwwsAAAQANQDECwAAAQAsAMYLAAABAC0ADgAECG8Q8wsAAgEEwQsAAAIAJwDCCwAAAgAdAMMLAAACADUAxgsAAAEALQANAAQIzhQRGgDCAATBCwAAAgApAMILAAACADgAwwsAAAIAPQDECwAAAQAXAAwAAQj7GfceAEIAAcELAAABAEIAASoABRQICE0ACACEGwA=.',['窑鸡']='窑鸡王:BAEAKgAECgIIAgABKgAFFAYIAgASAAAAAA==.',['竹川']='竹川萤:BAECKgAFFH8FAAICAAIILQwzJwByAALBCwAABAAzAMILAAABAAsAAgACCC0MMycAcgACwQsAAAQAMwDCCwAAAQALACoABAp/IAACAgAICBYgShcAOAIAAgAICBYgShcAOAIAASoABRQICCcABwBWJQA=.',['粉色']='粉色工具人:BAEBKgAFFH9NAAIIAAgIhBvdAwAoAgjBCwAADgBWAMILAAAMAF4AwwsAAA0AVwDECwAACgBgAMULAAAHAD8AxgsAAAkALQDHCwAABwA8AMgLAAAFADcACAAICIQb3QMAKAIIwQsAAA4AVgDCCwAADABeAMMLAAANAFcAxAsAAAoAYADFCwAABwA/AMYLAAAJAC0AxwsAAAcAPADICwAABQA3AAAA.',['花蝶']='花蝶风月:BAECKgAFFH8dAAQTAAgIhhz1AQDmAQjBCwAACABfAMILAAAFAFcAwwsAAAUAVADECwAABQBgAMULAAACAFsAxgsAAAIAOgDHCwAAAQAgAMgLAAABAD0AEwAHCC0f9QEA5gEHwQsAAAcAXwDCCwAAAwBXAMMLAAADAFQAxAsAAAMAYADFCwAAAgBbAMYLAAACADoAyAsAAAEAPQAUAAQIQw6BJACHAATBCwAAAQAcAMILAAACADgAwwsAAAIAGQDECwAAAgAsABUAAQidDIYgAEsAAccLAAABACAAKgAECn8pAAMTAAgIcyasAAAJAwATAAgIcyasAAAJAwAUAAEIDBlVTABEAAAAAA==.',['若有']='若有鱼心:BAEBKgAFFH8HAAMDAAQIoh9SDgDFAATBCwAAAgBPAMILAAACAFwAwwsAAAIARgDECwAAAQAyAAIABAjmHCIpAMoABMELAAABAE8AwgsAAAEAXADDCwAAAQAxAMQLAAABADIAAwADCB8XUg4AxQADwQsAAAEARADCCwAAAQAmAMMLAAABAEYAASoABRQICCcABwBWJQA=.',['苦尽']='苦尽甘來:BAEBKgAFFH8aAAMWAAYIPxytAQCeAQbBCwAABQBFAMILAAAFAFoAwwsAAAUAVQDECwAABQBfAMULAAADACYAxgsAAAMATQAWAAYIrRetAQCeAQbBCwAAAQAnAMILAAABAFAAwwsAAAEASgDECwAAAQBKAMULAAABAB4AxgsAAAEATQAEAAYIHBvDCwCQAQbBCwAABABFAMILAAAEAFoAwwsAAAQAVQDECwAABABfAMULAAACACYAxgsAAAIAPwAAAA==.',['蒜欧']='蒜欧提斯:BAEBKgAFFH8YAAMFAAYIKyHIAADyAQbBCwAABQBfAMILAAAFAFsAwwsAAAUAQgDECwAABQBgAMULAAACAF8AxgsAAAIASgAFAAYIKyHIAADyAQbBCwAABABfAMILAAAEAFsAwwsAAAQAQgDECwAABABgAMULAAACAF8AxgsAAAIASgAGAAQIMAKEHgChAATBCwAAAQADAMILAAABAAsAwwsAAAEAAQDECwAAAQABAAEqAAUUCAgIABQALREA.',['蕾茉']='蕾茉妮雅:BAECKgAFFH8FAAILAAMIGQNqBwBsAAPBCwAAAwADAMILAAABAAoAwwsAAAEACgALAAMIGQNqBwBsAAPBCwAAAwADAMILAAABAAoAwwsAAAEACgAqAAQKfxcAAgsACAjYBroWANoAAAsACAjYBroWANoAAAEqAAUUBggCABIAAAAA.',['蜜甜']='蜜甜甜:BAECKgAFFH8KAAMOAAYIehQ5EAAEAQbBCwAAAgAnAMILAAACAC0AwwsAAAIAJwDECwAAAQBLAMULAAABAFEAxgsAAAIANwAOAAYIehQ5EAAEAQbBCwAAAQAnAMILAAABAC0AwwsAAAIAJwDECwAAAQBLAMULAAABAFEAxgsAAAIANwANAAIIoRDgHACJAALBCwAAAQAyAMILAAABACIAKgAECn8cAAQOAAgI1RVMHwDcAQAOAAgI1RVMHwDcAQAMAAgI7BchJgC5AQANAAEIOAYzngAeAAAAAA==.',['西北']='西北没有风:BAEBKgAFFH8LAAIPAAQIdCMbDAA7AQTBCwAAAwBeAMILAAADAGMAwwsAAAMATgDECwAAAgBjAA8ABAh0IxsMADsBBMELAAADAF4AwgsAAAMAYwDDCwAAAwBOAMQLAAACAGMAAAA=.',['这周']='这周一定红:BAEBKgAFFH8IAAIIAAQIJguCDgCSAATBCwAAAgAbAMILAAACABAAwwsAAAIAKQDECwAAAgAVAAgABAgmC4IOAJIABMELAAACABsAwgsAAAIAEADDCwAAAgApAMQLAAACABUAAAA=.',['郝大']='郝大鸟:BAEBKgAFFH8OAAQXAAgIPBDoBgD5AQjBCwAAAgBFAMILAAACAA8AwwsAAAIACADECwAAAgA7AMULAAACAEEAxgsAAAIASQDHCwAAAQALAMgLAAABAC4AFwAICCwN6AYA+QEIwQsAAAEARQDCCwAAAQAKAMMLAAABAAQAxAsAAAEAOwDFCwAAAQATAMYLAAABAEkAxwsAAAEACwDICwAAAQAuAAoAAgjhFvIKAMQAAsULAAABAEEAxgsAAAEANAAYAAQIYQd7BwCWAATBCwAAAQAgAMILAAABAA8AwwsAAAEACADECwAAAQAMAAEqAAUUCAgnAAcAViUA.',['阿珂']='阿珂丶:BAEAKgAECgUIBQABKgAFFAYICwAZAP0VAA==.',['骑士']='骑士工具人:BAEBKgAFFH8SAAMIAAQIeh04EAADAQTBCwAABwBMAMILAAAEAE8AwwsAAAUARgDECwAAAgBeAAgABAh6HTgQAAMBBMELAAAGAEwAwgsAAAMATwDDCwAABQBGAMQLAAABAF4AGgADCBQYUBUAjAADwQsAAAEAPwDCCwAAAQA7AMQLAAABACUAASoABRQICE0ACACEGwA=.',['鸪可']='鸪可杀不可卤:BAEAKgAECggICAABKgAFFAgIJwAHAFYlAA==.',['龍龙']='龍龙希尔:BAEBKgAFFH8ZAAIJAAgImB82CAD9AQjBCwAAAwBaAMILAAAEAFoAwwsAAAQAXQDECwAABABjAMULAAAEAFQAxgsAAAQAYADHCwAAAQAuAMgLAAABAD8ACQAICJgfNggA/QEIwQsAAAMAWgDCCwAABABaAMMLAAAEAF0AxAsAAAQAYwDFCwAABABUAMYLAAAEAGAAxwsAAAEALgDICwAAAQA/AAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end