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
 local lookup = {'Monk-Windwalker','Priest-Shadow','Rogue-Subtlety','Mage-Arcane','Mage-Fire','Mage-Frost','Druid-Balance','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Fury','Warrior-Arms','Warrior-Protection','Hunter-BeastMastery','DeathKnight-Blood','Shaman-Elemental','Priest-Holy','Shaman-Restoration','DemonHunter-Havoc','Druid-Restoration','Monk-Mistweaver','Evoker-Augmentation','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','Evoker-Devastation','Evoker-Preservation','Paladin-Protection','Paladin-Holy','Priest-Discipline','Druid-Feral',}; local provider = {region='CN',realm='伊森利恩',name='CN',type='subscribers',zone=44,date='2025-12-11',data={As='Astarte:BAECLAAFFH8jAAIBAAUIByWPAwDoAQU5DAAACABWADsMAAAIAGEAOgwAAAkAYwA8DAAABQBiAD0MAAAFAFsAAQAFCAcljwMA6AEFOQwAAAgAVgA7DAAACABhADoMAAAJAGMAPAwAAAUAYgA9DAAABQBbACwABAp/PQACAQAICLAligIAZgMAAQAICLAligIAZgMAAAA=.',Lo='Louise:BAECLAAFFH81AAICAAgILyXvAQCzAgg5DAAACQBiADsMAAAKAF4AOgwAAAkAYwA8DAAACABeADIMAAAFAFgAPQwAAAYAYgA+DAAAAwBfAD8MAAADAF0AAgAICC8l7wEAswIIOQwAAAkAYgA7DAAACgBeADoMAAAJAGMAPAwAAAgAXgAyDAAABQBYAD0MAAAGAGIAPgwAAAMAXwA/DAAAAwBdACwABAp/OAACAgAICGom8wEAfQMAAgAICGom8wEAfQMAAAA=.',Se='Sekir:BAEBLAAFFH8mAAIDAAgIxCEKAQC7Agg5DAAABQBgADsMAAAGAFUAOgwAAAUAYQA8DAAABgBXADIMAAAGAF4APQwAAAYATAA+DAAAAgBGAD8MAAACAFIAAwAICMQhCgEAuwIIOQwAAAUAYAA7DAAABgBVADoMAAAFAGEAPAwAAAYAVwAyDAAABgBeAD0MAAAGAEwAPgwAAAIARgA/DAAAAgBSAAAA.Semage:BAECLAAFFH8yAAMEAAgIaSQcAABnAwg5DAAACABjADsMAAAGAGQAOgwAAAgAYwA8DAAABwBeADIMAAAGAGIAPQwAAAcAYwA+DAAABQBgAD8MAAADADkABAAICGMkHAAAZwMIOQwAAAUAYwA7DAAAAgBjADoMAAAFAGMAPAwAAAYAXgAyDAAAAgBiAD0MAAAGAGMAPgwAAAQAYAA/DAAAAgA5AAUACAiIH6sAAHoCCDkMAAADAGEAOwwAAAQAZAA6DAAAAwBbADwMAAABADsAMgwAAAQAXAA9DAAAAQBeAD4MAAABADgAPwwAAAEANAAsAAQKfykABAQACAjtJgoCAIEDAAQACAjtJgoCAIEDAAUACAhXJtYAAFADAAYAAQgaJquHAFMAAAAA.',Su='Summernude:BAEALAADCgYIEgAAAA==.',Yi='Yiken:BAEALAAFFAYIAwABLAAFFAgIEgAHAM0IAA==.',['上林']='上林何赋:BAECLAAFFH86AAMIAAgIPSalAQD6Agg5DAAADABiADsMAAAKAGIAOgwAAAoAYwA8DAAACABjADIMAAAGAGMAPQwAAAgAYwA+DAAAAwBgAD8MAAABAFsACAAICD0mpQEA+gIIOQwAAAgAYgA7DAAACgBiADoMAAAGAGMAPAwAAAgAYwAyDAAABgBjAD0MAAAIAGMAPgwAAAMAYAA/DAAAAQBbAAkAAghrJrgFAOAAAjkMAAAEAGIAOgwAAAQAYQAsAAQKfzwABAgACAiJJsoIAFEDAAgACAiDJsoIAFEDAAkABgiXJd4PAIECAAoAAgiWFe4tAIIAAAAA.',['丶不']='丶不努力:BAECLAAFFH9EAAMLAAcI2yZkAQCoAgc5DAAADQBjADsMAAAMAGMAOgwAAA4AYwA8DAAACwBkADIMAAAHAGMAPQwAAAoAYwA+DAAAAQBhAAsABwjbJmQBAKgCBzkMAAANAGMAOwwAAAwAYwA6DAAADABjADwMAAALAGQAMgwAAAcAYwA9DAAACgBjAD4MAAABAGEADAABCBMmpgYAbwABOgwAAAIAYQAsAAQKfzAABAsACAjYJlIXAPwCAAsACAjYJlIXAPwCAA0AAQhXJQmGAG0AAAwAAQh9JHAyAGYAAAAA.',['丶干']='丶干嘛:BAEBLAAFFH8eAAIOAAYIgSGJIAC2AQY5DAAABgBaADsMAAAFAFUAOgwAAAYAWwA8DAAABQBRADIMAAADAFAAPQwAAAUAVgAOAAYIgSGJIAC2AQY5DAAABgBaADsMAAAFAFUAOgwAAAYAWwA8DAAABQBRADIMAAADAFAAPQwAAAUAVgABLAAFFAgIXgADAMUlAA==.',['丿海']='丿海的女婿:BAEBLAAFFH8JAAIPAAUIpxWiDgAhAQU5DAAAAgA+ADsMAAABADYAOgwAAAMARAA8DAAAAQAkAD0MAAACADYADwAFCKcVog4AIQEFOQwAAAIAPgA7DAAAAQA2ADoMAAADAEQAPAwAAAEAJAA9DAAAAgA2AAEsAAUUBwhFAA0A5yYA.',['丿阿']='丿阿佳:BAEBLAAFFH8SAAIIAAYINh1jGwC6AQY5DAAAAwBVADsMAAADAFYAOgwAAAMAUAA8DAAAAwAmADIMAAADAFQAPQwAAAMASAAIAAYINh1jGwC6AQY5DAAAAwBVADsMAAADAFYAOgwAAAMAUAA8DAAAAwAmADIMAAADAFQAPQwAAAMASAABLAAFFAYIGwAQADkiAA==.',['六二']='六二七:BAEALAAECgcICgAAAA==.',['冰公']='冰公主:BAEALAAECggICAAAAA==.',['只为']='只为你微笑:BAEBLAAFFH8PAAMRAAYILgwnHwBYAQY5DAAABAAwADsMAAACAB0AOgwAAAMANgA8DAAAAgAWADIMAAACAAUAPQwAAAIAGQARAAYILgwnHwBYAQY5DAAABAAwADsMAAACAB0AOgwAAAMANgA8DAAAAQAWADIMAAACAAUAPQwAAAIAGQACAAEIbAPOLgA6AAE8DAAAAQAIAAEsAAUUCAgKABIAsR4A.',['哈基']='哈基坑:BAEBLAAFFH8IAAIQAAYIUQPdKQD8AAY5DAAAAgAJADsMAAABAAUAOgwAAAIAEAA8DAAAAQAGADIMAAABAAUAPQwAAAEABgAQAAYIUQPdKQD8AAY5DAAAAgAJADsMAAABAAUAOgwAAAIAEAA8DAAAAQAGADIMAAABAAUAPQwAAAEABgABLAAFFAgIEgAHAM0IAA==.',['啾啾']='啾啾秋:BAEBLAAFFH8tAAIIAAYIrQsYNABJAQY5DAAADQBAADsMAAAHACEAOgwAAA0AIgA8DAAABQAQADIMAAACAAcAPQwAAAUAFgAIAAYIrQsYNABJAQY5DAAADQBAADsMAAAHACEAOgwAAA0AIgA8DAAABQAQADIMAAACAAcAPQwAAAUAFgAAAA==.',['四十']='四十打个佯攻:BAEALAAFFAIIAgABLAAFFAcITQATANcgAA==.',['在逃']='在逃小坑:BAEBLAAFFH8SAAMHAAgIzQigGgAIAQg5DAAABQBGADsMAAADAAoAOgwAAAUALwA8DAAAAQARADIMAAABABcAPQwAAAEABwA+DAAAAQABAD8MAAABAAEABwAGCJkLoBoACAEGOQwAAAUARgA7DAAAAwAKADoMAAAFAC8APAwAAAEAEQAyDAAAAQAXAD0MAAABAAcAFAACCDIAgWQABQACPgwAAAEAAAA/DAAAAQABAAAA.',['地下']='地下堡:BAEBLAAECn8dAAMBAAcIfh+LFgBdAgc5DAAABABTADsMAAAEAF8AOgwAAAUAUAA8DAAABQBXADIMAAAFAEkAPQwAAAUAXAA+DAAAAQAzAAEABwh+H4sWAF0CBzkMAAACAFMAOwwAAAIAXwA6DAAAAgBQADwMAAACAFcAMgwAAAMASQA9DAAABQBcAD4MAAABADMAFQAFCCIXaioAUAEFOQwAAAIAOQA7DAAAAgArADoMAAADAEIAPAwAAAMAOQAyDAAAAgBHAAEsAAUUCAgzABYAIh0A.',['宁丶']='宁丶宁:BAECLAAFFH8XAAMCAAYILxnvDABoAQY5DAAABgBTADsMAAAFADgAOgwAAAcASwA8DAAAAgBNADIMAAACACEAPQwAAAEAPQACAAUIkBvvDABoAQU5DAAABABTADsMAAAEADgAOgwAAAQASwA8DAAAAgBNAD0MAAABAD0AEQAECGoLLhsA2QAEOQwAAAIAJAA7DAAAAQAVADoMAAADADcAMgwAAAIAAwAsAAQKfxwAAwIABgjbE5ZVAGABAAIABgjbE5ZVAGABABEABgi5CQd8AAoBAAEsAAUUCAgLAA4ArhYA.',['安爪']='安爪:BAEBLAAFFH8QAAIXAAcIohRmBwDvAQc5DAAAAwBZADsMAAADACYAOgwAAAMAUAA8DAAAAgA6ADIMAAACAFAAPQwAAAIAFQA+DAAAAQABABcABwiiFGYHAO8BBzkMAAADAFkAOwwAAAMAJgA6DAAAAwBQADwMAAACADoAMgwAAAIAUAA9DAAAAgAVAD4MAAABAAEAAAA=.',['小丶']='小丶璐:BAEBLAAFFH8SAAMYAAYI5xsTBgBDAgY5DAAABABeADsMAAAEADoAOgwAAAQAYwA8DAAAAwBNADIMAAABAEkAPQwAAAIAGAAYAAYIXBsTBgBDAgY5DAAAAQBcADsMAAACADQAOgwAAAQAYwA8DAAAAwBNADIMAAABAEkAPQwAAAIAGAAZAAII+h2ECQDMAAI5DAAAAwBeADsMAAACADoAASwABRQICAsADgCuFgA=.',['小坑']='小坑团子:BAEALAADCggIFgABLAAFFAgIEgAHAM0IAA==.',['弯弯']='弯弯德:BAEALAAFFAMIAwABLAAFFAYIGwAFAMwdAA==.',['彩色']='彩色粉笔:BAEBLAAFFH8ZAAINAAYIEgxcFAAkAQY5DAAABgBDADsMAAAFABEAOgwAAAcALAA8DAAAAwAVADIMAAACABYAPQwAAAIACwANAAYIEgxcFAAkAQY5DAAABgBDADsMAAAFABEAOgwAAAcALAA8DAAAAwAVADIMAAACABYAPQwAAAIACwAAAA==.',['我先']='我先启动了:BAECLAAFFH8lAAIOAAcITCVsBwB5Agc5DAAABwBiADsMAAAHAGMAOgwAAAcAYwA8DAAABgBbADIMAAADAGEAPQwAAAYAWgA+DAAAAQBaAA4ABwhMJWwHAHkCBzkMAAAHAGIAOwwAAAcAYwA6DAAABwBjADwMAAAGAFsAMgwAAAMAYQA9DAAABgBaAD4MAAABAFoALAAECn8aAAIOAAgIrybaAQATAwAOAAgIrybaAQATAwAAAA==.',['欣訫']='欣訫向雪:BAEBLAAFFH8KAAISAAYIsR6DDAARAgY5DAAAAwBKADsMAAABACsAOgwAAAMAYAA8DAAAAQBgADIMAAABAEgAPQwAAAEAVwASAAYIsR6DDAARAgY5DAAAAwBKADsMAAABACsAOgwAAAMAYAA8DAAAAQBgADIMAAABAEgAPQwAAAEAVwAAAA==.',['海毛']='海毛虫:BAECLAAFFH8zAAQWAAgIIh11AwDlAQg5DAAACABaADsMAAAHAE8AOgwAAAcAVgA8DAAACABaADIMAAAFAAAAPQwAAAYARQA+DAAABQBZAD8MAAAFAFkAFgAHCBMadQMA5QEHOQwAAAMAVwA7DAAAAQBPADoMAAADAFQAPAwAAAEAQgA9DAAAAQAKAD4MAAACADEAPwwAAAQAWQAaAAcIkxtQBwC/AQc5DAAABQBaADsMAAAEAEIAOgwAAAMAVgA8DAAABQBaADIMAAABAAAAPQwAAAMARQA+DAAAAwBZABsABgjYEy4HAHUBBjsMAAACADcAOgwAAAEAOAA8DAAAAgBHADIMAAAEAC8APQwAAAIAHwA/DAAAAQApACwABAp/JwAEGgAICAUkoQsA6AIAGgAICKEioQsA6AIAFgAFCNUg6QkA1gEAGwAFCNUY1x4AeAEAAAA=.',['灬阿']='灬阿佳:BAEBLAAFFH8SAAIYAAYIeRJuMgB4AQY5DAAAAwA9ADsMAAADACwAOgwAAAMASgA8DAAAAwA6ADIMAAADACIAPQwAAAMACQAYAAYIeRJuMgB4AQY5DAAAAwA9ADsMAAADACwAOgwAAAMASgA8DAAAAwA6ADIMAAADACIAPQwAAAMACQABLAAFFAYIGwAQADkiAA==.',['电你']='电你一下如何:BAEBLAAFFH8GAAIQAAYIYR7pEgCqAQY5DAAAAQBTADsMAAABAFAAOgwAAAEAXAA8DAAAAQBUAD4MAAABAEoAPwwAAAEAMQAQAAYIYR7pEgCqAQY5DAAAAQBTADsMAAABAFAAOgwAAAEAXAA8DAAAAQBUAD4MAAABAEoAPwwAAAEAMQAAAA==.',['神仙']='神仙板丶:BAEBLAAFFH8IAAIEAAYIcw3XNwAXAQY5DAAAAgBCADsMAAABAAAAOgwAAAIANAA8DAAAAQARADIMAAABADMAPQwAAAEAEQAEAAYIcw3XNwAXAQY5DAAAAgBCADsMAAABAAAAOgwAAAIANAA8DAAAAQARADIMAAABADMAPQwAAAEAEQAAAA==.',['秒殺']='秒殺丨丈母娘:BAECLAAFFH8pAAITAAYIMiRgDAANAgY5DAAACQBdADsMAAAIAF0AOgwAAAgAYQA8DAAACABfADIMAAACAFcAPQwAAAYAWQATAAYIMiRgDAANAgY5DAAACQBdADsMAAAIAF0AOgwAAAgAYQA8DAAACABfADIMAAACAFcAPQwAAAYAWQAsAAQKfxsAAhMABwigIzk0AIwCABMABwigIzk0AIwCAAAA.',['罗马']='罗马全面战争:BAECLAAFFH8JAAMcAAgItgyACQAhAQg5DAAAAgBOADsMAAABAEUAOgwAAAEAMQA8DAAAAQAeADIMAAABABQAPQwAAAEAAQA+DAAAAQABAD8MAAABAAoAHAAICLYMgAkAIQEIOQwAAAEATgA7DAAAAQBFADoMAAABADEAPAwAAAEAHgAyDAAAAQAUAD0MAAABAAEAPgwAAAEAAQA/DAAAAQAKABcAAQjnCDlpAEkAATkMAAABABYALAAECn8xAAMXAAgI2yGKGgA/AgAXAAgI2yGKGgA/AgAdAAYItxAiTAAnAQAAAA==.',['萌萌']='萌萌哒酋长:BAECLAAFFH80AAMdAAcIEx//AwB2Agc5DAAADQBfADsMAAAJAEsAOgwAAA0AUwA8DAAABwBeADIMAAAEAEMAPQwAAAUATgA+DAAAAQA9AB0ABwgTH/8DAHYCBzkMAAANAF8AOwwAAAkASwA6DAAADQBTADwMAAAGAF4AMgwAAAQAQwA9DAAABQBOAD4MAAABAD0AFwABCCAHE20AQAABPAwAAAEAEgAsAAQKfzEAAx0ACAjNImcGAAQDAB0ACAjNImcGAAQDABwABghgG/YTAIABAAAA.',['萧丶']='萧丶瑟:BAEBLAAFFH8LAAIOAAYIrhZbRAA/AQY5DAAAAgBUADsMAAACAFUAOgwAAAIAUAA8DAAAAgAiADIMAAABAAEAPQwAAAIAPQAOAAYIrhZbRAA/AQY5DAAAAgBUADsMAAACAFUAOgwAAAIAUAA8DAAAAgAiADIMAAABAAEAPQwAAAIAPQAAAA==.',['角斗']='角斗士瓦里安:BAEBLAAFFH8OAAILAAYIuR2VFAC6AQY5DAAAAwBhADsMAAACAFoAOgwAAAQAUQA8DAAAAgA/ADIMAAABACMAPQwAAAIAWAALAAYIuR2VFAC6AQY5DAAAAwBhADsMAAACAFoAOgwAAAQAUQA8DAAAAgA/ADIMAAABACMAPQwAAAIAWAABLAAFFAcIOAAYAJIlAA==.',['超萌']='超萌丶柯基牧:BAECLAAFFH86AAMCAAYI2iPOAwA/AgY5DAAACQBdADsMAAAKAF0AOgwAAAsAXAA8DAAACgBbADIMAAAKAFwAPQwAAAgAVgACAAYI2iPOAwA/AgY5DAAACQBdADsMAAAKAF0AOgwAAAsAXAA8DAAACgBbADIMAAAJAFwAPQwAAAgAVgAeAAEI4A67BwBBAAEyDAAAAQAmACwABAp/JwACAgAICI8kkQ8A9wIAAgAICI8kkQ8A9wIAASwABRQICFEAAgBLJQA=.',['过与']='过与罚:BAEALAAECgIIBAAAAA==.',['阿丶']='阿丶佳佳:BAEBLAAFFH8YAAITAAYIRxtpFgC6AQY5DAAABABcADsMAAAEAE8AOgwAAAQAVAA8DAAABAA/ADIMAAAEAB4APQwAAAQARAATAAYIRxtpFgC6AQY5DAAABABcADsMAAAEAE8AOgwAAAQAVAA8DAAABAA/ADIMAAAEAB4APQwAAAQARAABLAAFFAYIGwAQADkiAA==.',['阿丿']='阿丿佳:BAEBLAAFFH8YAAILAAYISCLfDQDvAQY5DAAABABXADsMAAAEAFAAOgwAAAQAYAA8DAAABABaADIMAAAEAFoAPQwAAAQAUQALAAYISCLfDQDvAQY5DAAABABXADsMAAAEAFAAOgwAAAQAYAA8DAAABABaADIMAAAEAFoAPQwAAAQAUQABLAAFFAYIGwAQADkiAA==.',['阿佳']='阿佳丿:BAEBLAAFFH8bAAIQAAYIOSIyDADxAQY5DAAABABSADsMAAAFAFgAOgwAAAQAWwA8DAAABQBeADIMAAAEAF8APQwAAAUASQAQAAYIOSIyDADxAQY5DAAABABSADsMAAAFAFgAOgwAAAQAWwA8DAAABQBeADIMAAAEAF8APQwAAAUASQAAAA==.阿佳呀:BAEBLAAFFH8YAAMHAAYIrh9hCQDTAQY5DAAABABTADsMAAAEAFIAOgwAAAQATwA8DAAABABLADIMAAAEAFkAPQwAAAQATQAHAAYIrh9hCQDTAQY5DAAAAgBTADsMAAACAFIAOgwAAAIATwA8DAAAAgBLADIMAAACAFkAPQwAAAIATQAfAAYIQhSHBAB6AQY5DAAAAgBAADsMAAACADEAOgwAAAIASgA8DAAAAgATADIMAAACAD4APQwAAAIAJwABLAAFFAYIGwAQADkiAA==.',['露娜']='露娜米斯:BAEBLAAFFH8GAAICAAYI+g3XFQAjAQY5DAAAAQAnADsMAAABACsAOgwAAAEANwA8DAAAAQAhADIMAAABACkAPQwAAAEAAQACAAYI+g3XFQAjAQY5DAAAAQAnADsMAAABACsAOgwAAAEANwA8DAAAAQAhADIMAAABACkAPQwAAAEAAQAAAA==.',['香嘛']='香嘛:BAEBLAAFFH8GAAIEAAQI2hbzPADhAAQ5DAAAAgA8ADsMAAABAD0AOgwAAAIAVAA8DAAAAQAbAAQABAjaFvM8AOEABDkMAAACADwAOwwAAAEAPQA6DAAAAgBUADwMAAABABsAAAA=.',['驭雷']='驭雷者摩戈尔:BAEBLAAFFH8GAAIQAAYImRYCGQB6AQY5DAAAAQBAADsMAAABAE0AOgwAAAEAJAA8DAAAAQApADIMAAABAFsAPQwAAAEAIwAQAAYImRYCGQB6AQY5DAAAAQBAADsMAAABAE0AOgwAAAEAJAA8DAAAAQApADIMAAABAFsAPQwAAAEAIwABLAAFFAcIOAAYAJIlAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end