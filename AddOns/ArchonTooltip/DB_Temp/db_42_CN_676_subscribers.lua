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
 local lookup = {'DeathKnight-Unholy','DemonHunter-Vengeance','DeathKnight-Blood','Monk-Mistweaver','Paladin-Retribution','Priest-Holy','Priest-Shadow','Shaman-Restoration','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','Monk-Windwalker','Shaman-Enhancement','Evoker-Augmentation','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Unknown-Unknown','Druid-Feral','Paladin-Protection','DemonHunter-Havoc',}; local provider = {region='CN',realm='影之哀伤',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Bu='Bustash:BAEAKgAFFAQIBAABKgAFFAgICAABAOgSAA==.',Da='Danisen:BAEAKgAECggIDQABKgAFFAYIBgACAAwNAA==.',De='Demonman:BAEAKgAECggIDQABKgAFFAMIHQADAOgFAA==.',Fa='Fattybombus:BAEAKgAFFAUIAwABKgAFFAgIIQAEAHQeAA==.',Hu='Huwoman:BAEAKgADCgYIBgABKgAFFAMIHQADAOgFAA==.',Lu='Lupercalia:BAECKgAFFH8FAAIBAAMIyhXmMwDHAAPBCwAAAgBEAMILAAACAE8AwwsAAAEAEgABAAMIyhXmMwDHAAPBCwAAAgBEAMILAAACAE8AwwsAAAEAEgAqAAQKfzAAAgEACAgSHzsgAEECAAEACAgSHzsgAEECAAEqAAUUCAg0AAUARiYA.',['一念']='一念小红手:BAEAKgAECgYIAgAAAA==.',['三修']='三修慕斯:BAECKgAFFH84AAMGAAgIrBpkCAChAQjBCwAADABeAMILAAAMAF8AwwsAAAwAJADECwAACQAtAMULAAAFAEoAxgsAAAMAMgDHCwAAAgBbAMgLAAABACIABgAICKwaZAgAoQEIwQsAAAoAXgDCCwAACgBfAMMLAAAHACQAxAsAAAgALQDFCwAABQBKAMYLAAADADIAxwsAAAIAWwDICwAAAQAiAAcABAhRF/0PAN8ABMELAAACAEYAwgsAAAIALwDDCwAABQA8AMQLAAABADYAKgAECn87AAMGAAgIWCY5AwDbAgAGAAgIWCY5AwDbAgAHAAYInhxAGgC4AQAAAA==.',['丶黑']='丶黑白:BAEAKgAFFAYIBAABKgAFFAgIHQAIADUXAA==.',['人民']='人民来当家啦:BAECKgAFFH9LAAIEAAgIqCVKAAD7AgjBCwAAFABiAMILAAAMAGMAwwsAAAsAWwDECwAABgBaAMULAAAFAGIAxgsAAAUAXwDHCwAACABhAMgLAAAIAF0ABAAICKglSgAA+wIIwQsAABQAYgDCCwAADABjAMMLAAALAFsAxAsAAAYAWgDFCwAABQBiAMYLAAAFAF8AxwsAAAgAYQDICwAACABdACoABAp/QwACBAAICB0lxQoAmAIABAAICB0lxQoAmAIAAAA=.人民来当家灬:BAEAKgAFFAMIAwABKgAFFAgISwAEAKglAA==.',['传奇']='传奇舰长:BAECKgAFFH8QAAIJAAMIjRHJDgDcAAPBCwAABwA3AMILAAAGADMAwwsAAAMAHAAJAAMIjRHJDgDcAAPBCwAABwA3AMILAAAGADMAwwsAAAMAHAAqAAQKfyEAAwkACAggH5MQAEkCAAkACAggH5MQAEkCAAoAAgi6DUkkAFMAAAEqAAUUAwgSAAsASB8A.',['你去']='你去保护她吧:BAEAKgAECgUIBQABKgAFFAgIGwAMAMoYAA==.',['公仔']='公仔仙人球:BAEBKgAFFH8cAAMNAAYIMyKSBADqAQbBCwAABwBgAMILAAAHAFkAwwsAAAYAUgDECwAABABdAMULAAACAFwAxgsAAAIATQANAAYIMyKSBADqAQbBCwAABgBgAMILAAAGAFkAwwsAAAUAUgDECwAAAwBdAMULAAACAFwAxgsAAAIATQAIAAQIGghbOgCbAATBCwAAAQAVAMILAAABABgAwwsAAAEADwDECwAAAQASAAEqAAUUCAgdAAgANRcA.',['南风']='南风知我億:BAEAKgAFFAYIBAAAAA==.',['双档']='双档粉丝汤:BAEAKgAECgYIBgAAAA==.',['可愛']='可愛的小只因:BAECKgAFFH9FAAMOAAgI9iMVAADjAgjBCwAACgBgAMILAAAMAGIAwwsAAAsAYQDECwAABwBfAMULAAAGAFAAxgsAAAkAVwDHCwAABQBhAMgLAAAJAFYADgAICPYjFQAA4wIIwQsAAAMAYADCCwAABQBiAMMLAAAFAGEAxAsAAAIAXwDFCwAAAQBQAMYLAAAFAFcAxwsAAAMAYQDICwAABQBWAAkACAgRHtgAAAYCCMELAAAHAFUAwgsAAAcAYADDCwAABgBSAMQLAAAFAD8AxQsAAAUANgDGCwAABAAsAMcLAAACAFoAyAsAAAQAVAAqAAQKfxwAAgkACAjDJQYPAFgCAAkACAjDJQYPAFgCAAAA.',['嗜魂']='嗜魂影行者:BAEBKgAFFH8TAAQPAAYIFRq5AQA4AQbBCwAAAwBKAMILAAAEAE8AwwsAAAQATQDECwAAAwAwAMULAAADADwAxgsAAAIAKQAPAAQIHhW5AQA4AQTBCwAAAQBKAMILAAABAE8AwwsAAAEAFADGCwAAAgApABAABAh6GHwRAN8ABMELAAACAC4AwgsAAAMAPwDDCwAAAwBNAMQLAAACADAAEQACCIUXtxMAVwACxAsAAAEAKADFCwAAAwA8AAEqAAUUCAhFAA4A9iMA.',['土豆']='土豆丸子:BAEBKgAFFH8GAAMLAAYIIgSiFAC6AAbBCwAAAQACAMILAAABABcAwwsAAAEACgDECwAAAQAPAMULAAABAA0AxgsAAAEAAgALAAQIHgWiFAC6AATBCwAAAQACAMILAAABABcAxAsAAAEADwDFCwAAAQANAAcAAgg9AhMdAIEAAsMLAAABAAgAxgsAAAEAAwABKgAFFAgICAABAOgSAA==.',['壹队']='壹队输出:BAEAKgAFFAgIBAABKgAFFAgIHQAIADUXAA==.',['奋进']='奋进新征程哇:BAEAKgADCggICAABKgAFFAgISwAEAKglAA==.',['奶茶']='奶茶萌奇奇:BAECKgAFFH9kAAISAAgI6iYGAAADAwjBCwAAEABjAMILAAAOAGQAwwsAAAwAYwDECwAADABjAMULAAAKAGMAxgsAAAkAYwDHCwAADgBkAMgLAAANAGIAEgAICOomBgAAAwMIwQsAABAAYwDCCwAADgBkAMMLAAAMAGMAxAsAAAwAYwDFCwAACgBjAMYLAAAJAGMAxwsAAA4AZADICwAADQBiACoABAp/KwACEgAICPcmawEAGQMAEgAICPcmawEAGQMAAAA=.',['官人']='官人要我灬:BAEAKgAECgcIBwAAAA==.',['寂路']='寂路同赴:BAEAKgAFFAYIAgABKgAFFAgIGwAMAMoYAA==.',['小小']='小小雪饼:BAEBKgAFFH8KAAQLAAYISxcOEAAiAQbBCwAAAgBJAMILAAACADgAwwsAAAIATwDECwAAAgBXAMULAAABABUAxgsAAAEAQwALAAUIgRYOEAAiAQXBCwAAAgBJAMILAAACADgAwwsAAAIATwDECwAAAQBGAMULAAABABUABwABCGEA+TEALwABxgsAAAEAAAAGAAEIAACBRAAAAAHECwAAAQBXAAAA.',['曾经']='曾经狂过:BAEBKgAFFH8UAAMQAAgI+CAqAQDxAQjBCwAAAwBWAMILAAADAEoAwwsAAAMAXADECwAAAwBgAMULAAAEAGAAxgsAAAIAYADHCwAAAQA9AMgLAAABAFIAEAAICPggKgEA8QEIwQsAAAMAVgDCCwAAAwBKAMMLAAADAFwAxAsAAAMAYADFCwAAAwBgAMYLAAACAGAAxwsAAAEAPQDICwAAAQBSABEAAQijDAcrAEQAAcULAAABACAAAAA=.',['浅処']='浅処:BAECKgAFFH8LAAMTAAIIXA/nOQCCAALBCwAABwAwAMILAAAEAB4AEwACCKML5zkAggACwQsAAAUAMADCCwAAAwALABQAAgjlCYNGAGYAAsELAAACABQAwgsAAAEAHgAqAAQKfxkAAxMACAjAHXlNAMoBABMABggKH3lNAMoBABQABAgnG35IAC4BAAEqAAUUBggSABUA4xoA.',['浅壮']='浅壮:BAEAKgAECgYIBgABKgAFFAYIEgAVAOMaAA==.',['炸鸡']='炸鸡馒头:BAEAKgAECgMIAwABKgAECgYICwAWAAAAAA==.',['烽火']='烽火燎塬:BAEAKgAECgIIAgABKgAFFAgIFAAQAPggAA==.',['燃燒']='燃燒的最後:BAEBKgAECn8ZAAIHAAcI2h1hGADJAQfBCwAABABSAMILAAAEAEkAwwsAAAQAXQDECwAABABjAMULAAAEAEYAxgsAAAQAUgDHCwAAAQA5AAcABwjaHWEYAMkBB8ELAAAEAFIAwgsAAAQASQDDCwAABABdAMQLAAAEAGMAxQsAAAQARgDGCwAABABSAMcLAAABADkAASoABRQICEIACQD/IAA=.',['狗狗']='狗狗吃太饱:BAEBKgAFFH8IAAMIAAgIuhEsFwAlAQjBCwAAAQA8AMILAAABAEUAwwsAAAEAQwDECwAAAQBHAMULAAABADMAxgsAAAEACQDHCwAAAQAUAMgLAAABACUACAAECLgLLBcAJQEExQsAAAEAMwDGCwAAAQAJAMcLAAABABQAyAsAAAEAJQAVAAQIQg46DADNAATBCwAAAQAuAMILAAABACsAwwsAAAEAEwDECwAAAQASAAAA.',['狸头']='狸头骑:BAECKgAFFH8dAAIDAAMI6AVXGwB9AAPBCwAADAAGAMILAAALABIAwwsAAAYAFAADAAMI6AVXGwB9AAPBCwAADAAGAMILAAALABIAwwsAAAYAFAAqAAQKfx0AAgMACAgjC2syAAYBAAMACAgjC2syAAYBAAAA.',['田园']='田园脆鸡堡:BAEBKgAFFH8MAAMNAAQIjSLdBAA3AQTBCwAAAwBgAMILAAADAFEAwwsAAAMAVwDECwAAAwBdAA0ABAiNIt0EADcBBMELAAACAGAAwgsAAAIAUQDDCwAAAgBXAMQLAAACAF0ACAAECKAisAUALQEEwQsAAAEAXQDCCwAAAQBhAMMLAAABAEoAxAsAAAEARAABKgAFFAgIHQAIADUXAA==.',['算了']='算了下亿把:BAEBKgAFFH8dAAQIAAgINRdGBwCpAQjBCwAABABTAMILAAAFAEkAwwsAAAUAAQDECwAABQAkAMULAAADAEwAxgsAAAMARgDHCwAAAgA3AMgLAAACADcACAAHCKYVRgcAqQEHwgsAAAEASQDDCwAAAQABAMQLAAABACQAxQsAAAEATADGCwAAAQBGAMcLAAABADcAyAsAAAEANwANAAgIMx7HBgCBAQjBCwAAAwBcAMILAAADAGAAwwsAAAMAPgDECwAAAwBcAMULAAACAF8AxgsAAAIASADHCwAAAQAYAMgLAAABAGEAFQAECHkOrAwAyAAEwQsAAAEAFwDCCwAAAQBDAMMLAAABABMAxAsAAAEAAwAAAA==.',['粉发']='粉发妹妹:BAEAKgAFFAYIBAABKgAFFAgIHQAIADUXAA==.',['给您']='给您拜个早年:BAEBKgAFFH8bAAIMAAgIyhgsBAARAgjBCwAACQBDAMILAAAGAFoAwwsAAAUAVADECwAAAgA4AMULAAABAC0AxgsAAAIASQDHCwAAAQAvAMgLAAABACMADAAICMoYLAQAEQIIwQsAAAkAQwDCCwAABgBaAMMLAAAFAFQAxAsAAAIAOADFCwAAAQAtAMYLAAACAEkAxwsAAAEALwDICwAAAQAjAAAA.',['翼骸']='翼骸:BAEBKgAFFH8RAAIDAAcIESOeAgBaAgfBCwAAAwBhAMILAAADAFsAwwsAAAMAYQDECwAAAwBWAMULAAACAFQAxgsAAAIAQgDHCwAAAQBkAAMABwgRI54CAFoCB8ELAAADAGEAwgsAAAMAWwDDCwAAAwBhAMQLAAADAFYAxQsAAAIAVADGCwAAAgBCAMcLAAABAGQAAAA=.',['胰岛']='胰岛素好甜:BAEBKgAFFH8GAAMVAAYIaQs8DADMAAbBCwAAAQBHAMILAAABABQAwwsAAAEAHwDECwAAAQAWAMULAAABAAUAxgsAAAEAEQAVAAQIGBA8DADMAATBCwAAAQBHAMILAAABABQAwwsAAAEAHwDECwAAAQAWAAgAAgjwBtpBAIAAAsULAAABAAkAxgsAAAEAGgABKgAFFAgIHQAIADUXAA==.',['转眼']='转眼:BAEBKgAFFH8KAAMNAAYIcBaVBwBqAQbBCwAAAgAdAMILAAACAFkAwwsAAAIAHADECwAAAgA4AMULAAABAD8AxgsAAAEASwANAAYIcBaVBwBqAQbBCwAAAQAdAMILAAABAFkAwwsAAAEAHADECwAAAQA4AMULAAABAD8AxgsAAAEASwAIAAQIbBIiMgCxAATBCwAAAQBEAMILAAABAD8AwwsAAAEACQDECwAAAQAiAAEqAAUUCAgdAAgANRcA.',['达达']='达达的跟班:BAEAKgAECgQIBAABKgAECgcIBwAWAAAAAA==.',['近战']='近战:BAEBKgAFFH8SAAMLAAMISB80EgALAQPBCwAACABWAMILAAAHAEcAwwsAAAMAUQALAAMISB80EgALAQPBCwAACABWAMILAAAHAEcAwwsAAAEAUQAHAAEIIQsJLgA9AAHDCwAAAgAcAAAA.',['选妮']='选妮蔻就对惹:BAECKgAFFH8SAAIVAAYI4xo6BgCJAQbBCwAABQBBAMILAAAFAFIAwwsAAAIAXADECwAAAgA1AMULAAACADYAxgsAAAIAMQAVAAYI4xo6BgCJAQbBCwAABQBBAMILAAAFAFIAwwsAAAIAXADECwAAAgA1AMULAAACADYAxgsAAAIAMQAqAAQKfyEAAhUACAisIesKAJACABUACAisIesKAJACAAAA.',['那你']='那你先哄她吧:BAECKgAFFH8IAAIXAAMIhRLoAgDwAAPBCwAAAwA2AMILAAADACwAwwsAAAIAKgAXAAMIhRLoAgDwAAPBCwAAAwA2AMILAAADACwAwwsAAAIAKgAqAAQKfxQAAhcACAjrGVkIAEACABcACAjrGVkIAEACAAEqAAUUCAgbAAwAyhgA.',['那是']='那是一种感觉:BAECKgAFFH8KAAMRAAgInxvuAwD4AAjBCwAAAQBXAMILAAABACQAwwsAAAIAXADECwAAAgBCAMULAAABAF0AxgsAAAEAOADHCwAAAQA8AMgLAAABAEIAEAAGCPYcQAwAyQEGwwsAAAEAXADECwAAAQBCAMULAAABAF0AxgsAAAEAOADHCwAAAQA8AMgLAAABAEIAEQAECO4Y7gMA+AAEwQsAAAEAVwDCCwAAAQAkAMMLAAABAEMAxAsAAAEAGwAqAAQKfxcAAxAACAheJDgGAMECABAACAheJDgGAMECAA8AAQg6CKVEADcAAAEqAAUUCAgdAAgANRcA.',['醉酒']='醉酒乄当歌:BAEBKgAFFH8IAAIYAAgI9h0iAwBNAgjBCwAAAQBOAMILAAABAEsAwwsAAAEAUwDECwAAAQA7AMULAAABAEsAxgsAAAEATgDHCwAAAQBJAMgLAAABAEgAGAAICPYdIgMATQIIwQsAAAEATgDCCwAAAQBLAMMLAAABAFMAxAsAAAEAOwDFCwAAAQBLAMYLAAABAE4AxwsAAAEASQDICwAAAQBIAAAA.',['问君']='问君几何:BAEBKgAFFH8IAAITAAQIyhJJOAC3AATBCwAAAgAzAMILAAACADcAwwsAAAIAJQDECwAAAgAXABMABAjKEkk4ALcABMELAAACADMAwgsAAAIANwDDCwAAAgAlAMQLAAACABcAASoABRQICAgAGAD2HQA=.',['陳小']='陳小小魚丶:BAEBKgAFFH8GAAMCAAYIDA1JCADEAAbBCwAAAQBGAMILAAABACwAwwsAAAEAIwDECwAAAQBAAMcLAAABAAQAyAsAAAEADAACAAQImxNJCADEAATBCwAAAQBGAMILAAABACwAwwsAAAEAIwDECwAAAQBAABkAAgg1A00jAKUAAscLAAABAAQAyAsAAAEADAAAAA==.',['随凤']='随凤刘:BAEAKgAECgMIBAABKgAECgYICwAWAAAAAA==.',['雪最']='雪最终会化:BAECKgAFFH8KAAMRAAYIHx1IAACRAQbBCwAAAgBbAMILAAACAGEAwwsAAAIASgDECwAAAgBTAMULAAABAEcAxgsAAAEAJQARAAUIviBIAACRAQXBCwAAAQBbAMILAAABAGEAwwsAAAEASgDECwAAAQBTAMULAAABAEcAEAAFCCsV6wUARgEFwQsAAAEAVgDCCwAAAQAsAMMLAAABADEAxAsAAAEAGwDGCwAAAQAlACoABAp/GQACEAAICKUYESAABAIAEAAICKUYESAABAIAAAA=.',['领主']='领主圣光:BAECKgAFFH80AAMFAAgIRiYHAQAEAwjBCwAADwBiAMILAAAMAGMAwwsAAAoAYgDECwAABwBeAMULAAADAGMAxgsAAAMAYQDHCwAAAQBgAMgLAAABAF8ABQAICEYmBwEABAMIwQsAAA8AYgDCCwAACgBjAMMLAAAJAGIAxAsAAAcAXgDFCwAAAwBjAMYLAAADAGEAxwsAAAEAYADICwAAAQBfABgAAghmGKYOAJUAAsILAAACAFoAwwsAAAEAIgAqAAQKfy8AAgUACAgUJqkHAP0CAAUACAgUJqkHAP0CAAAA.',['魔之']='魔之小软:BAECKgAFFH8LAAIQAAQIzRn1GgAuAQTBCwAABABWAMILAAADAC0AwwsAAAMATgDICwAAAQA1ABAABAjNGfUaAC4BBMELAAAEAFYAwgsAAAMALQDDCwAAAwBOAMgLAAABADUAKgAECn8XAAIQAAgIyR+6IgD1AQAQAAgIyR+6IgD1AQABKgAFFAgIHQAIADUXAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end