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
 local lookup = {'DemonHunter-Havoc','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Retribution','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Priest-Shadow','Druid-Feral','Mage-Frost','Mage-Arcane','Monk-Mistweaver','Monk-Brewmaster','Unknown-Unknown','Druid-Balance','Shaman-Elemental','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Warlock-Destruction','Druid-Restoration','Hunter-Marksmanship','Warlock-Demonology','Priest-Discipline','Warrior-Fury','Shaman-Restoration','Shaman-Enhancement',}; local provider = {region='CN',realm='影之哀伤',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Bu='Bustash:BAEBLAAFFH80AAIBAAYIYSQXCwDwAQY5DAAADABhADsMAAAKAF8AOgwAAAwAYwA8DAAABwBhADIMAAAEAFEAPQwAAAcAVwABAAYIYSQXCwDwAQY5DAAADABhADsMAAAKAF8AOgwAAAwAYwA8DAAABwBhADIMAAAEAFEAPQwAAAcAVwAAAA==.',Lu='Lupercalia:BAECLAAFFH8lAAQCAAgIXhrcCQBpAgg5DAAACABeADsMAAAGAFsAOgwAAAgAVQA8DAAABQAtADIMAAADACgAPQwAAAQAXwA+DAAAAgA3AD8MAAABAB8AAgAICF4a3AkAaQIIOQwAAAcAXgA7DAAABgBbADoMAAAIAFUAPAwAAAUALQAyDAAAAgAoAD0MAAAEAF8APgwAAAIANwA/DAAAAQAfAAMAAQj7AQUgACMAATIMAAABAAUABAABCCgAYCEADwABOQwAAAEAAAAsAAQKfxYAAwIACAjvIqlUAE4CAAIACAjvIqlUAE4CAAQABwgQBkouAFMBAAEsAAUUBwgwAAUAEyIA.',Pl='Planbee:BAEBLAAFFH8IAAIGAAIIjyUgMwC+AAI5DAAABABgADoMAAAEAGAABgACCI8lIDMAvgACOQwAAAQAYAA6DAAABABgAAEsAAUUBggGAAIArwAA.',['Yì']='Yìr:BAEBLAAFFH8FAAMHAAUIiRIAEQD8AAU5DAAAAQA7ADsMAAABAC0AOgwAAAEANQA8DAAAAQAVAD0MAAABADkABwADCCkVABEA/AADOQwAAAEAOwA7DAAAAQAtAD0MAAABADkACAACCJoOzRQARQACOgwAAAEANQA8DAAAAQAVAAEsAAUUBwg3AAcAwh4A.',['三修']='三修慕斯:BAECLAAFFH8yAAIJAAgIRSWqAABQAwg5DAAABwBgADsMAAAFAGEAOgwAAAcAYwA8DAAABQBXADIMAAAHAGIAPQwAAAgAYwA+DAAABgBhAD8MAAAFAFYACQAICEUlqgAAUAMIOQwAAAcAYAA7DAAABQBhADoMAAAHAGMAPAwAAAUAVwAyDAAABwBiAD0MAAAIAGMAPgwAAAYAYQA/DAAABQBWACwABAp/IgADCQAICEAmrgQATAMACQAICEAmrgQATAMACgAECB8kXiIANgEAAAA=.',['世界']='世界将明未明:BAEALAAFFAEIAQABLAAFFAUIJQALAMQYAA==.',['丨心']='丨心海丶:BAEBLAAFFH8MAAMMAAIIbCMPCADHAAI5DAAABgBRADoMAAAGAGQADAACCBEjDwgAxwACOQwAAAEATwA6DAAABABkAA0AAgiCHhA1ALQAAjkMAAAFAFEAOgwAAAIASgABLAAFFAYIBgACABciAA==.',['丨暗']='丨暗海丶:BAEBLAAFFH8GAAICAAIIFyLRNQDIAAI5DAAAAwBUADoMAAADAFoAAgACCBci0TUAyAACOQwAAAMAVAA6DAAAAwBaAAAA.',['丨脑']='丨脑斧丨:BAECLAAFFH8aAAIJAAYI2iHiBAATAgY5DAAABQBeADsMAAAFAFgAOgwAAAUAXQA8DAAABABQADIMAAADAE8APQwAAAQAUwAJAAYI2iHiBAATAgY5DAAABQBeADsMAAAFAFgAOgwAAAUAXQA8DAAABABQADIMAAADAE8APQwAAAQAUwAsAAQKfxsAAgkACAhkJtsFAPgCAAkACAhkJtsFAPgCAAEsAAUUBwgzAAkAOyIA.',['人民']='人民来当家啦:BAECLAAFFH88AAMOAAgIlSGjAQCtAgg5DAAACgBiADsMAAAIAFoAOgwAAAoAXgA8DAAACABQADIMAAAHAFsAPQwAAAgATwA+DAAABgBTAD8MAAADAEYADgAICJUhowEArQIIOQwAAAgAYgA7DAAACABaADoMAAAHAF4APAwAAAgAUAAyDAAABwBbAD0MAAAIAE8APgwAAAYAUwA/DAAAAwBGAA8AAggJB34bAF0AAjkMAAACAA8AOgwAAAMAFAAsAAQKf0QAAw4ACAiiJfEBAFIDAA4ACAiiJfEBAFIDAA8ACAhaFLIMAH4BAAAA.',['何人']='何人及:BAEALAADCgEIAQABLAAECgQIBAAQAAAAAA==.',['冰柠']='冰柠萌奇奇:BAECLAAFFH82AAIGAAYIcyaXCgBDAgY5DAAACwBjADsMAAAJAGMAOgwAAAsAXwA8DAAACABjADIMAAAHAGEAPQwAAAgAYwAGAAYIcyaXCgBDAgY5DAAACwBjADsMAAAJAGMAOgwAAAsAXwA8DAAACABjADIMAAAHAGEAPQwAAAgAYwAsAAQKfx4AAgYABggFJhsxAJUCAAYABggFJhsxAJUCAAEsAAUUCAh8ABEA6iYA.',['冰淇']='冰淇淋萌奇奇:BAECLAAFFH8zAAISAAcI7SGhBQB4Agc5DAAACwBgADsMAAAIAF8AOgwAAAsAXwA8DAAABwBcADIMAAAGAF0APQwAAAcAYAA+DAAAAQAlABIABwjtIaEFAHgCBzkMAAALAGAAOwwAAAgAXwA6DAAACwBfADwMAAAHAFwAMgwAAAYAXQA9DAAABwBgAD4MAAABACUALAAECn8ZAAISAAYIGCJBMwA8AgASAAYIGCJBMwA8AgABLAAFFAgIfAARAOomAA==.',['可愛']='可愛的小只因:BAECLAAFFH8yAAQTAAgIWR9YAQCAAgg5DAAACwBdADsMAAAIAFkAOgwAAAsAYgA8DAAABwBgADIMAAAFAF0APQwAAAYAUgA+DAAAAQAuAD8MAAABACkAEwAICFkfWAEAgAIIOQwAAAoAXQA7DAAACABZADoMAAAIAGIAPAwAAAcAYAAyDAAAAgBdAD0MAAAFAFIAPgwAAAEALgA/DAAAAQApABQAAggrFOgYAI8AAjkMAAABACcAOgwAAAMAPwAVAAII9AXgGwBkAAIyDAAAAwAbAD0MAAABAAMALAAECn8nAAMUAAgIJR+VEgCdAgAUAAgI2xqVEgCdAgATAAgIBx7lBQBRAgABLAAFFAgIcAAWAIYmAA==.',['可爱']='可爱德小鸡:BAEBLAAFFH8ZAAMRAAYI+BUOEgBdAQY5DAAACABSADsMAAADAFUAOgwAAAgATQA8DAAAAwBIADIMAAABAAsAPQwAAAIABwARAAYI+BUOEgBdAQY5DAAABwBSADsMAAADAFUAOgwAAAcATQA8DAAAAwBIADIMAAABAAsAPQwAAAIABwAXAAIIrgjJPgBhAAI5DAAAAQATADoMAAABABgAASwABRQICHAAFgCGJgA=.可爱的小鸡:BAECLAAFFH8mAAIGAAgIZCNNAgBwAgg5DAAABQBjADsMAAAGAGEAOgwAAAYAXgA8DAAABgBgADIMAAAFAFoAPQwAAAYAYgA+DAAAAgA+AD8MAAACAFUABgAICGQjTQIAcAIIOQwAAAUAYwA7DAAABgBhADoMAAAGAF4APAwAAAYAYAAyDAAABQBaAD0MAAAGAGIAPgwAAAIAPgA/DAAAAgBVACwABAp/HAADBgAICNQgzysAqQIABgAGCD8mzysAqQIAGAAICBIY6EQAogEAASwABRQICHAAFgCGJgA=.',['嗜魂']='嗜魂影行者:BAECLAAFFH9wAAMWAAgIhiYkAAB4Awg5DAAADQBjADsMAAARAGMAOgwAAA8AYwA8DAAADgBjADIMAAAOAGIAPQwAAA4AYwA+DAAADQBfAD8MAAAMAGIAFgAICIYmJAAAeAMIOQwAAAsAYwA7DAAAEQBjADoMAAANAGMAPAwAAA4AYwAyDAAADgBiAD0MAAAOAGMAPgwAAA0AXwA/DAAADABiABkAAggyFHgWAJcAAjkMAAACAEAAOgwAAAIAJwAsAAQKfxkAAxYACAjkJB4KAEgDABYACAjkJB4KAEgDABkAAQimIGmOAE0AAAAA.',['土豆']='土豆丸子:BAEBLAAFFH8eAAMKAAUIlyJuEABlAQU5DAAACQBcADsMAAAFAFYAOgwAAAkAYgA8DAAABABcAD0MAAADAEkACgAFCJcibhAAZQEFOQwAAAkAXAA7DAAABQBWADoMAAAJAGIAPAwAAAQAXAA9DAAAAgBJABoAAQiDBokIADUAAT0MAAABABAAASwABRQGCDQAAQBhJAA=.',['天邊']='天邊牧雲:BAEALAAFFAMIAgAAAA==.',['奶茶']='奶茶萌奇奇:BAECLAAFFH98AAIRAAgI6iYCAACiAwg5DAAAEQBkADsMAAARAGMAOgwAABEAYwA8DAAAEABjADIMAAAQAGQAPQwAABAAZAA+DAAADgBjAD8MAAALAGIAEQAICOomAgAAogMIOQwAABEAZAA7DAAAEQBjADoMAAARAGMAPAwAABAAYwAyDAAAEABkAD0MAAAQAGQAPgwAAA4AYwA/DAAACwBiACwABAp/OgACEQAICAknSQAAoAMAEQAICAknSQAAoAMAAAA=.',['弘扬']='弘扬新思想啊:BAEBLAAFFH8IAAIXAAMI9xHqLwCvAAM5DAAAAwBIADsMAAACABcAOgwAAAMAKgAXAAMI9xHqLwCvAAM5DAAAAwBIADsMAAACABcAOgwAAAMAKgABLAAFFAgIPAAOAJUhAA==.',['弥托']='弥托黛拉:BAECLAAFFH8RAAIbAAYI8iAuBwAiAgY5DAAABgBbADsMAAACAEwAOgwAAAYAYwA8DAAAAQBbADIMAAABAFUAPQwAAAEAPAAbAAYI8iAuBwAiAgY5DAAABgBbADsMAAACAEwAOgwAAAYAYwA8DAAAAQBbADIMAAABAFUAPQwAAAEAPAAsAAQKfyAAAhsACAixIyAKAEkDABsACAixIyAKAEkDAAAA.',['忍大']='忍大炮:BAEALAAECgQIBAAAAA==.',['時光']='時光安然:BAEBLAAFFH8FAAIIAAMI8xCoEABqAAM5DAAAAgBMADoMAAACADQAPAwAAAEAAQAIAAMI8xCoEABqAAM5DAAAAgBMADoMAAACADQAPAwAAAEAAQABLAAFFAYIEQAbAPIgAA==.',['柳智']='柳智敏理想型:BAEBLAAFFH8MAAIYAAIISh7zFwCuAAI5DAAABgBNADoMAAAGAE0AGAACCEoe8xcArgACOQwAAAYATQA6DAAABgBNAAEsAAUUBggGAAIAFyIA.',['炸鸡']='炸鸡馒头:BAEALAAECgMIBQABLAAECgQIBAAQAAAAAA==.',['燃燒']='燃燒的最後:BAEBLAAFFH8qAAMKAAYIKByEDwBwAQY5DAAACgBMADsMAAAGAFEAOgwAAAsARAA8DAAABQBRADIMAAAFAC8APQwAAAUATQAKAAUIFx6EDwBwAQU5DAAABwBMADsMAAAFAFEAOgwAAAgARAA8DAAABABRAD0MAAAEAE0ACQAGCNEH5SAARwEGOQwAAAMAGgA7DAAAAQALADoMAAADABgAPAwAAAEABwAyDAAABQAkAD0MAAABAAwAASwABRQICDsAFAAYHwA=.',['米哈']='米哈游股东:BAEALAADCgYIBgAAAA==.',['给您']='给您拜个早年:BAEALAAECgMIAwABLAAFFAUIJQALAMQYAA==.',['翼骸']='翼骸:BAECLAAFFH8oAAQCAAgISyHkAgB/Agg5DAAACABiADsMAAAGAF0AOgwAAAgAYwA8DAAABgBfADIMAAAFAFMAPQwAAAUAYQA+DAAAAQBIAD8MAAABACkAAgAGCPsk5AIAfwIGOQwAAAUAYgA7DAAABQBdADoMAAAHAGMAPAwAAAUAXwAyDAAABABTAD0MAAAEAGEAAwAICD4dQwIAdwIIOQwAAAEAWAA7DAAAAQBRADoMAAABAFcAPAwAAAEAUAAyDAAAAQBIAD0MAAABAEoAPgwAAAEASAA/DAAAAQApAAQAAQg/GwYbAFYAATkMAAACAEUALAAECn8ZAAMCAAgIiiMNFwAUAwACAAgIeSMNFwAUAwAEAAQIkCPYKwBjAQAAAA==.',['肉山']='肉山大魔王:BAEALAAECgYIBgAAAA==.',['蓝山']='蓝山一号:BAEALAAECgYIDgABLAAFFAcIMwAJADsiAA==.',['薄荷']='薄荷绿工具人:BAECLAAFFH82AAMVAAgIRSSDAAA/Awg5DAAACgBiADsMAAAIAFoAOgwAAAoAYAA8DAAABwBXADIMAAAHAGMAPQwAAAcAXgA+DAAABABhAD8MAAABAE4AFQAICEUkgwAAPwMIOQwAAAcAYgA7DAAACABaADoMAAAGAGAAPAwAAAYAVwAyDAAABwBjAD0MAAAGAF4APgwAAAQAYQA/DAAAAQBOABQABAi3FIALAEcBBDkMAAADAFoAOgwAAAQAXwA8DAAAAQABAD0MAAABABgALAAECn8nAAMUAAgI3yLeCAAJAwAUAAgI3yLeCAAJAwAVAAYIyCVbCgCLAgAAAA==.',['选妮']='选妮蔻就对惹:BAEBLAAECn8YAAMSAAgIvRLwQwD2AQg5DAAAAwAyADsMAAADADgAOgwAAAMAMwA8DAAAAwBJADIMAAADADUAPQwAAAMAHwA+DAAAAwAdAD8MAAADACQAEgAICL0S8EMA9gEIOQwAAAMAMgA7DAAAAwA4ADoMAAADADMAPAwAAAMASQAyDAAAAwA1AD0MAAADAB8APgwAAAIAHQA/DAAAAgAkABwAAgg4Ic7vALgAAj4MAAABAFUAPwwAAAEAVAAAAA==.',['那你']='那你先哄她吧:BAECLAAFFH8lAAILAAUIxBgeAwC0AQU5DAAACgBRADsMAAAIAFsAOgwAAAoAQgA8DAAABQAbAD0MAAAEADEACwAFCMQYHgMAtAEFOQwAAAoAUQA7DAAACABbADoMAAAKAEIAPAwAAAUAGwA9DAAABAAxACwABAp/JQADCwAICFAd3g0AcAIACwAICFAd3g0AcAIAFwACCIALp94AQgAAAAA=.',['随凤']='随凤刘:BAEALAAECgIIAgABLAAECgQIBAAQAAAAAA==.',['领主']='领主圣光:BAECLAAFFH8wAAIFAAcIEyJ6AgBZAgc5DAAACwBjADsMAAAIAGAAOgwAAAgAYgA8DAAACABRADIMAAAEAEMAPQwAAAgAXwA+DAAAAQBHAAUABwgTInoCAFkCBzkMAAALAGMAOwwAAAgAYAA6DAAACABiADwMAAAIAFEAMgwAAAQAQwA9DAAACABfAD4MAAABAEcALAAECn8pAAIFAAgISCYjCwBUAwAFAAgISCYjCwBUAwAAAA==.',['风藤']='风藤咿咿:BAECLAAFFH8fAAMcAAYItBbrGQCTAQY5DAAABgBRADsMAAAFADUAOgwAAAYAVAA8DAAABQATADIMAAAEAC0APQwAAAUAPwAcAAYItBbrGQCTAQY5DAAAAgBRADsMAAABADUAOgwAAAIAVAA8DAAAAQATADIMAAAEAC0APQwAAAEAPwAdAAUIhxYcAwBBAQU5DAAABABCADsMAAAEAD0AOgwAAAQAQAA8DAAABAAzAD0MAAAEACsALAAECn8eAAIcAAYIMyTdEQBnAgAcAAYIMyTdEQBnAgABLAAFFAgIOwAUABgfAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end