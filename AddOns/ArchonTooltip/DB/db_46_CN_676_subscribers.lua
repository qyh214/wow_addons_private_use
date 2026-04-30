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

local lookup = {'Priest-Discipline','Monk-Mistweaver','Druid-Restoration','Evoker-Devastation','Evoker-Augmentation','Mage-Frost','DeathKnight-Unholy','Monk-Brewmaster','Monk-Windwalker','Hunter-Marksmanship','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Priest-Shadow','Unknown-Unknown','Priest-Holy','Evoker-Preservation','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Survival','DemonHunter-Devourer',}
local provider = {region='CN',realm='影之哀伤',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Fa='Fattybombus:BAECLgAFFH8OAAIBAAUJ/B/YAgDhAQVoDAAABABhAGkMAAACAEwAawwAAAMAWABqDAAAAgBiAOoMAAADADAAAQAFCfwf2AIA4QEFaAwAAAQAYQBpDAAAAgBMAGsMAAADAFgAagwAAAIAYgDqDAAAAwAwAC4ABAp/GQACAQAICeQgMAYA5wIAAQAICeQgMAYA5wIAAS4ABRQGCQoAAgBXGwA=.',
Go='Gomoga:BAEALgAECgYJBgAAAA==.',
Ta='Tarokiki:BAEALgAFFAEJAQABLgAFFAQJCQABADwWAA==.',
['一念']='一念小红手:BAEALgAECgcJCwAAAA==.',
['三修']='三修慕斯:BAEALgAFFAMJAwABLgAFFAYJFAADAJMjAA==.',
['世界']='世界鼓励宅:BAECLgAFFH8LAAIEAAMJviOaAAArAQNoDAAABABaAGkMAAAEAFQA6gwAAAMAYwAEAAMJviOaAAArAQNoDAAABABaAGkMAAAEAFQA6gwAAAMAYwAuAAQKfx4AAwQABwnQJQUDAPYCAAQABwnQJQUDAPYCAAUAAQn1I2MaAGgAAAAA.',
['丨心']='丨心海丶:BAEBLgAFFH8PAAIGAAUJviAdAwCTAQVoDAAABQBfAGkMAAADAFQAawwAAAIAPQBqDAAAAQBUAOoMAAAEAF0ABgAFCb4gHQMAkwEFaAwAAAUAXwBpDAAAAwBUAGsMAAACAD0AagwAAAEAVADqDAAABABdAAAA.',
['丨暗']='丨暗海丶:BAEBLgAFFH8LAAIHAAUJ8B+uAQAOAgVoDAAABABjAGkMAAACAFoAawwAAAEAKwBqDAAAAQBhAOoMAAADAF0ABwAFCfAfrgEADgIFaAwAAAQAYwBpDAAAAgBaAGsMAAABACsAagwAAAEAYQDqDAAAAwBdAAEuAAUUBQkPAAYAviAA.',
['丨盲']='丨盲海丶:BAEALgAFFAMJBAABLgAFFAUJDwAGAL4gAA==.',
['丨脑']='丨脑斧丨:BAEBLgAFFH8RAAIBAAUJCRjMBACeAQVoDAAABABaAGkMAAADAD8AawwAAAQAPwBqDAAAAQALAOoMAAAFAE0AAQAFCQkYzAQAngEFaAwAAAQAWgBpDAAAAwA/AGsMAAAEAD8AagwAAAEACwDqDAAABQBNAAAA.',
['人民']='人民来当家啦:BAECLgAFFH8aAAICAAYJkBxcAAAvAgZoDAAABQBRAGkMAAAFAFIAawwAAAUATQBqDAAABAAyAGwMAAACADAA6gwAAAUAYQACAAYJkBxcAAAvAgZoDAAABQBRAGkMAAAFAFIAawwAAAUATQBqDAAABAAyAGwMAAACADAA6gwAAAUAYQAuAAQKfxgAAwIACQnxHSkJAMECAAIACQnxHSkJAMECAAgABAmRDidcANMAAAAA.',
['传奇']='传奇舰长:BAEALgAFFAEJAgAAAA==.',
['低調']='低調灬莫扎特:BAEBLgAFFH8FAAIJAAUJgws8BQA2AQVoDAAAAQAGAGkMAAABADAAawwAAAEACQDqDAAAAQA/AG4MAAABABMACQAFCYMLPAUANgEFaAwAAAEABgBpDAAAAQAwAGsMAAABAAkA6gwAAAEAPwBuDAAAAQATAAEuAAUUCAkhAAUAGR8A.',
['何人']='何人及:BAEALgADCgYJBgAAAA==.',
['冰柠']='冰柠萌奇奇:BAECLgAFFH8KAAIKAAQJcROfDgA+AQRoDAAAAwApAGkMAAADADsAawwAAAEAKQDqDAAAAwA4AAoABAlxE58OAD4BBGgMAAADACkAaQwAAAMAOwBrDAAAAQApAOoMAAADADgALgAECn8kAAIKAAkJ9CBMBQBIAwAKAAkJ9CBMBQBIAwABLgAFFAgJIQALAF4gAA==.',
['冰淇']='冰淇淋萌奇奇:BAECLgAFFH8GAAIMAAQJlAZOEgDPAARoDAAAAgAaAGkMAAACAAgAawwAAAEAEQDqDAAAAQAPAAwABAmUBk4SAM8ABGgMAAACABoAaQwAAAIACABrDAAAAQARAOoMAAABAA8ALgAECn8WAAMNAAgJ4hPELwDJAQANAAgJ4hPELwDJAQAMAAcJDxWZKwC7AQABLgAFFAgJIQALAF4gAA==.',
['则代']='则代应:BAEALgAECgcJBwAAAA==.',
['双持']='双持:BAEALgAECgYJCQAAAA==.',
['可愛']='可愛的小只因:BAECLgAFFH8hAAIFAAgJGR8XAABfAghoDAAABQBjAGkMAAAFAF0AawwAAAUAYgBqDAAABQBfAGwMAAAEAFMAbQwAAAMALQDqDAAABQBKAG4MAAABAD0ABQAICRkfFwAAXwIIaAwAAAUAYwBpDAAABQBdAGsMAAAFAGIAagwAAAUAXwBsDAAABABTAG0MAAADAC0A6gwAAAUASgBuDAAAAQA9AC4ABAp/GwADBQAJCX8lYQIAKQIABAAHCVkiQAcAeAIABQAJCX8lYQIAKQIAAAA=.',
['嗜魂']='嗜魂影行者:BAECLgAFFH8RAAMOAAUJ5B7AAwDlAQVoDAAABABYAGkMAAADADgAawwAAAQAUQBqDAAAAgBfAOoMAAAEAFkADgAFCeQewAMA5QEFaAwAAAQAWABpDAAAAgA4AGsMAAADAFEAagwAAAIAXwDqDAAABABZAA8AAgk+E5IMAKcAAmkMAAABADcAawwAAAEAKgAuAAQKfxsAAw4ACQlJJU8CAKQDAA4ACQlJJU8CAKQDAA8AAQk3EdFtADkAAAEuAAUUCAkhAAUAGR8A.',
['回味']='回味鸭血粉丝:BAEBLgAECn8UAAIGAAkJMxfUMwCjAgloDAAAAgAhAGkMAAADAD0AawwAAAIAQwBqDAAAAwBQAGwMAAADAEUAbQwAAAIAPQDqDAAAAwBDAG4MAAABAEwAbwwAAAEAJQAGAAkJMxfUMwCjAgloDAAAAgAhAGkMAAADAD0AawwAAAIAQwBqDAAAAwBQAGwMAAADAEUAbQwAAAIAPQDqDAAAAwBDAG4MAAABAEwAbwwAAAEAJQABLgAFFAQJBgAGALASAA==.',
['土豆']='土豆丸子:BAEBLgAFFH8JAAMBAAQJPBY6BgD1AARoDAAABAA3AGkMAAABADEAawwAAAEAMADqDAAAAwBKAAEAAwn7EzoGAPUAA2gMAAABADcAaQwAAAEAMQBrDAAAAQAwABAAAgn0IT8NAMoAAmgMAAADAFoA6gwAAAMAUwAAAA==.',
['天邊']='天邊牧雲:BAEALgAFFAQJBAAAAA==.',
['奋进']='奋进新征程哇:BAEALgAECgMJAwABLgAFFAYJGgACAJAcAA==.',
['奶茶']='奶茶萌奇奇:BAECLgAFFH8hAAILAAgJXiAEAABqAwhoDAAABQBkAGkMAAAFAGEAawwAAAUAYgBqDAAABQBkAGwMAAAEAF8AbQwAAAMASwDqDAAABQBhAG4MAAABAA8ACwAICV4gBAAAagMIaAwAAAUAZABpDAAABQBhAGsMAAAFAGIAagwAAAUAZABsDAAABABfAG0MAAADAEsA6gwAAAUAYQBuDAAAAQAPAC4ABAp/KAACCwAJCbYmCwAAEwQACwAJCbYmCwAAEwQAAAA=.',
['姬野']='姬野的秋:BAEALgAECgkJCwABLgAFFAQJBgAGALASAA==.',
['小神']='小神龙鸡乐部:BAEBLgAECn8cAAMFAAkJQB6WFAA7AgloDAAAAwA1AGkMAAADAE8AawwAAAMAUQBqDAAABABdAGwMAAAEAF0AbQwAAAQARwDqDAAABQBaAG4MAAABAEMAbwwAAAEAUQAFAAYJmx+WFAA7AgZqDAAAAQBdAGwMAAACAF0AbQwAAAIARwDqDAAAAgBaAG4MAAABAEMAbwwAAAEAUQAEAAcJchouDgD3AQdoDAAAAwA1AGkMAAADAE8AawwAAAMAUQBqDAAAAwBCAGwMAAACAEoAbQwAAAIAMwDqDAAAAwBAAAEuAAUUCAkhAAUAGR8A.',
['尹氏']='尹氏鸡汁汤包:BAEALgAECgYJBgABLgAFFAQJBgAGALASAA==.',
['智力']='智力无法接受:BAEBLgAECn8UAAIGAAkJfyBeFwAeAwloDAAAAgBOAGkMAAACAFQAawwAAAIAWQBqDAAAAgBWAGwMAAACAEoAbQwAAAIAXADqDAAAAgBgAG4MAAADAF4AbwwAAAMANgAGAAkJfyBeFwAeAwloDAAAAgBOAGkMAAACAFQAawwAAAIAWQBqDAAAAgBWAGwMAAACAEoAbQwAAAIAXADqDAAAAgBgAG4MAAADAF4AbwwAAAMANgABLgAFFAQJBgAGALASAA==.',
['曾经']='曾经狂过:BAEBLgAFFH8FAAIOAAQJvxKVEwBNAQRoDAAAAgBVAGkMAAABADEAawwAAAEABADqDAAAAQA0AA4ABAm/EpUTAE0BBGgMAAACAFUAaQwAAAEAMQBrDAAAAQAEAOoMAAABADQAAAA=.',
['水西']='水西门盐水鸭:BAEALgAECgkJDAABLgAFFAQJBgAGALASAA==.',
['滑熊']='滑熊:BAEALgAECgMJAwABLgAFFAEJAgARAAAAAA==.',
['燃燒']='燃燒的最後:BAEBLgAECn8ZAAMSAAgJrROvKQClAQhoDAAABAA7AGkMAAAEAEcAawwAAAQAPABqDAAAAwAjAGwMAAADABgAbQwAAAEAIQDqDAAABABDAG4MAAACADMAEgAHCaQUrykApQEHaAwAAAQAOwBpDAAABABHAGsMAAADADwAagwAAAIAIwBsDAAAAgAYAOoMAAADAEMAbgwAAAEAMwAQAAYJ0gmINQA+AQZrDAAAAQAHAGoMAAABAB0AbAwAAAEAJQBtDAAAAQAVAOoMAAABACcAbgwAAAEAEwABLgAFFAUJEgATAKEXAA==.',
['狂炫']='狂炫富婆画饼:BAEBLgAFFH8PAAITAAYJix2gAAD9AQZoDAAAAwA2AGkMAAADAFEAawwAAAMAWQBqDAAAAgBGAGwMAAABAE8A6gwAAAMATQATAAYJix2gAAD9AQZoDAAAAwA2AGkMAAADAFEAawwAAAMAWQBqDAAAAgBGAGwMAAABAE8A6gwAAAMATQABLgAFFAQJBgAGALASAA==.',
['秋的']='秋的姬野:BAEBLgAFFH8GAAIGAAQJqhvhEgCBAQRoDAAAAgBZAGkMAAABAEoAawwAAAEASADqDAAAAgAuAAYABAmqG+ESAIEBBGgMAAACAFkAaQwAAAEASgBrDAAAAQBIAOoMAAACAC4AAS4ABRQECQYABgCwEgA=.',
['翼骸']='翼骸:BAECLgAFFH8QAAMHAAUJ9SU8AQAoAgVoDAAABABiAGkMAAADAGAAawwAAAMAXwBqDAAAAgBhAOoMAAAEAGIABwAFCfUlPAEAKAIFaAwAAAMAYgBpDAAAAgBgAGsMAAADAF8AagwAAAIAYQDqDAAABABiABQAAglaI+ABANoAAmgMAAABAGEAaQwAAAEAUwAuAAQKfxwAAgcACQn5I9QBAMIDAAcACQn5I9QBAMIDAAAA.',
['薄荷']='薄荷绿工具人:BAECLgAFFH8FAAITAAMJVSOlCwAwAQNoDAAAAgBhAGkMAAABAFsA6gwAAAIAUgATAAMJVSOlCwAwAQNoDAAAAgBhAGkMAAABAFsA6gwAAAIAUgAuAAQKfxgAAxMACAloIIUGANoCABMABwl0JIUGANoCAAQAAQnqAU5EACUAAAAA.',
['西祠']='西祠胡同嘈子:BAEALgAFFAQJBAABLgAFFAQJBgAGALASAA==.',
['超级']='超级暴鲤龙:BAECLgAFFH8FAAIFAAMJ5gPdFADJAANoDAAAAgAaAGkMAAACAAAA6gwAAAEAAgAFAAMJ5gPdFADJAANoDAAAAgAaAGkMAAACAAAA6gwAAAEAAgAuAAQKfxQABAUABwmsFmMgAL0BAAUABwmOFmMgAL0BAAQAAwl+BrgxAIgAABMAAgldAphCAFgAAAAA.',
['达达']='达达的骑士:BAEALgAECgcJEwAAAA==.',
['醉酒']='醉酒乄当歌:BAEALgAECgcJAwAAAA==.',
['雪饼']='雪饼咕:BAEBLgAFFH8IAAMLAAMJSA8YDwDwAANoDAAAAwAsAGkMAAACACgA6gwAAAMAIAALAAMJSA8YDwDwAANoDAAAAwAsAGkMAAACACgA6gwAAAIAIAADAAEJbwwAAAAAAAHqDAAAAQAfAAAA.',
['零丶']='零丶蝶:BAECLgAFFH8FAAIGAAUJHxEmCABfAQVoDAAAAQAdAGkMAAABACwAawwAAAEAJQBqDAAAAQAuAOoMAAABAD8ABgAFCR8RJggAXwEFaAwAAAEAHQBpDAAAAQAsAGsMAAABACUAagwAAAEALgDqDAAAAQA/AC4ABAp/HgACBgAJCSMcxhcAHAMABgAJCSMcxhcAHAMAAS4ABRQECQYABgCwEgA=.',
['零點']='零點蝶:BAECLgAFFH8GAAIGAAUJDR77CADYAQVoDAAAAgBMAGkMAAABAEgAawwAAAEARwBqDAAAAQAeAOoMAAABAFcABgAFCQ0e+wgA2AEFaAwAAAIATABpDAAAAQBIAGsMAAABAEcAagwAAAEAHgDqDAAAAQBXAC4ABAp/FgACBgAJCb8iTAYAoAMABgAJCb8iTAYAoAMAAS4ABRQECQYABgCwEgA=.',
['雾岛']='雾岛丷:BAECLgAFFH8UAAMKAAYJxRpEBgC8AQZoDAAABQBgAGkMAAADAFMAawwAAAMAEgBqDAAAAwBWAGwMAAACAEIA6gwAAAQATQAKAAUJMxlEBgC8AQVoDAAABABgAGsMAAADABIAagwAAAIAQABsDAAAAgBCAOoMAAADAEwAFQAECQYcYwYAFwEEaAwAAAEANQBpDAAAAwBTAGoMAAABAFYA6gwAAAEATQAuAAQKfyYABAoACAnYJDUKAP4CAAoACAkpIjUKAP4CABUAAwm+HiSsAGwAABYABAmcHQAAAAAAAAAA.',
['飞行']='飞行雪绒:BAEBLgAFFH8LAAIXAAMJ8yBeFAAwAQNoDAAABABfAGkMAAACAEEA6gwAAAUAXAAXAAMJ8yBeFAAwAQNoDAAABABfAGkMAAACAEEA6gwAAAUAXAABLgAFFAQJCQABADwWAA==.',
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
