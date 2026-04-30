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

local lookup = {'Druid-Restoration','DemonHunter-Devourer','Unknown-Unknown','DeathKnight-Blood','Priest-Holy','DemonHunter-Havoc','Druid-Balance','Druid-Guardian',}
local provider = {region='CN',realm='沃金',name='CN',type='weekly',zone=46,date='2026-04-25',data={Dk='Dkt:BAAALgADCgMJAwAAAA==.',
Is='Isháraá:BAABLgAFFH8FAAIBAAIJcBX/GwCMAAABAAIJcBX/GwCMAAAAAA==.',
Na='Naruto:BAABLgAFFH8FAAICAAIJ7x3QFgCxAAACAAIJ7x3QFgCxAAAAAA==.',
Tt='Ttp:BAAALgAECgIJAgABLgAECgYJDgADAAAAAA==.',
['一锅']='一锅韭黄:BAABLgAFFH8FAAIEAAUJ6gvgBAAEAQAEAAUJ6gvgBAAEAQAAAA==.',
['不想']='不想起名:BAAALgADCgQJBAAAAA==.',
['丹青']='丹青乌:BAAALgAECgEJAQAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgkJCAAAAA==.',
['全村']='全村吃饭:BAAALgADCgUJBQAAAA==.',
['劳蕾']='劳蕾尔丶光刃:BAAALgADCgQJBAAAAA==.',
['名字']='名字无法使用:BAAALgADCgEJAQAAAA==.',
['咕咕']='咕咕不咕咕:BAAALgAECgEJAQAAAA==.',
['咫尺']='咫尺毒奶:BAAALgAECgIJAgAAAA==.',
['嘟嘟']='嘟嘟不哭:BAAALgADCgUJBQAAAA==.',
['园田']='园田海未:BAAALgAECgcJBwAAAA==.',
['国木']='国木田花丸:BAAALgAECgcJBwAAAA==.',
['地狱']='地狱弑魂:BAAALgAECgIJAgAAAA==.',
['小天']='小天狼星:BAAALgAECgIJAgAAAA==.',
['小奶']='小奶牛:BAABLgAFFH8FAAIFAAMJnBSpBwDxAAAFAAMJnBSpBwDxAAAAAA==.',
['小泉']='小泉花阳:BAAALgAECgUJBQAAAA==.',
['小阿']='小阿甘:BAAALgAECgEJAgAAAA==.',
['小风']='小风波:BAAALgAECgEJAQAAAA==.',
['屈黑']='屈黑:BAAALgAECgYJBgABLgAECgYJDQADAAAAAA==.',
['平头']='平头帅哥:BAAALgAECgIJAwAAAA==.',
['幽门']='幽门螺杆君:BAAALgADCgcJBwAAAA==.',
['归兮']='归兮丶:BAAALgAECgYJBgAAAA==.',
['微微']='微微笑:BAAALgAECgEJAQAAAA==.',
['心环']='心环:BAABLgAECn8ZAAMCAAcJIxmdOwAFAgACAAcJIxmdOwAFAgAGAAMJXAC3fAAkAAABLgAFFAQJAQADAAAAAA==.',
['忧伤']='忧伤灬五花肉:BAAALgADCgcJBwAAAA==.',
['故人']='故人今依旧:BAAALgAECgUJBQAAAA==.',
['日不']='日不落:BAACLgAFFH8PAAIHAAQJPRliBABFAQAHAAQJPRliBABFAQAuAAQKfxoAAwcABwlHH38SAIMCAAcABwlHH38SAIMCAAgAAgmRCAcTACQAAAAA.',
['时木']='时木余寒:BAAALgAECgMJAwAAAA==.时木未夏:BAAALgAECgYJBwAAAA==.',
['晚风']='晚风十七:BAAALgAFFAQJBAAAAA==.晚风十五:BAABLgAFFH8IAAIBAAQJmSREAwCzAQABAAQJmSREAwCzAQAAAA==.晚风十八:BAABLgAFFH8LAAIBAAUJUSbBAAA+AgABAAUJUSbBAAA+AgAAAA==.晚风十六:BAABLgAFFH8IAAIBAAQJSCULAwC6AQABAAQJSCULAwC6AQAAAA==.',
['林深']='林深时见鹿:BAAALgAECgYJCAAAAA==.林深见鹿:BAAALgAECgYJBgAAAA==.',
['流明']='流明丶:BAAALgAECgQJBAAAAA==.',
['爬上']='爬上奶德:BAAALgAECgUJBQAAAA==.',
['牛掰']='牛掰:BAAALgAECgYJDQAAAA==.',
['猛牛']='猛牛丨乳液:BAAALgAECgYJCgAAAA==.',
['祝元']='祝元素忽悠你:BAAALgAECgEJAQAAAA==.',
['稻稻']='稻稻:BAAALgAECgEJAQAAAA==.',
['肝硬']='肝硬化:BAAALgAFFAQJBAAAAA==.',
['莎莎']='莎莎:BAAALgADCgMJBwAAAA==.',
['莯云']='莯云九戨:BAAALgAECgQJBAAAAA==.',
['萌萌']='萌萌哒的阳宝:BAAALgAECgYJBgAAAA==.',
['西门']='西门土豆:BAAALgAECgYJDgAAAA==.',
['野马']='野马不羁:BAAALgAFFAIJAwAAAA==.',
['闲潭']='闲潭梦落花:BAAALgADCgIJAgAAAA==.',
['飞行']='飞行雪绒:BAAALgAECgEJAQAAAA==.',
['马德']='马德培:BAAALgAECgEJAQAAAA==.',
['高冷']='高冷美少女:BAAALgAFFAMJBAAAAA==.',
['髭切']='髭切:BAAALgAECgEJAQAAAA==.',
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
