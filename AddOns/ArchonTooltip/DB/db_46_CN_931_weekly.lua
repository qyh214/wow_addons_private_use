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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Unknown-Unknown','Monk-Brewmaster','DemonHunter-Havoc','Monk-Mistweaver','DeathKnight-Unholy','Mage-Frost',}
local provider = {region='CN',realm='塔伦米尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ch='Cheval:BAABLgAFFH8KAAMBAAYJnBODAQCzAQABAAYJ6hGDAQCzAQACAAMJawssCADnAAABLgAFFAcJAQADAAAAAA==.',
Ea='Easy:BAAALgAECgcJBwAAAA==.',
Gr='Gram:BAAALgAECgEJAgAAAA==.',
Xy='Xyt:BAAALgADCgMJAwAAAA==.',
['一笑']='一笑奈何:BAAALgADCgUJCQAAAA==.',
['世一']='世一战:BAAALgAECgQJBAAAAA==.',
['五彩']='五彩斑斓的黑:BAAALgADCgcJBwABLgAFFAQJCgAEACkdAA==.',
['俏丽']='俏丽哇:BAAALgAECgEJAQAAAA==.',
['公子']='公子丿世无双:BAAALgAFFAEJAQAAAA==.',
['兽之']='兽之战魂:BAAALgADCgQJBAAAAA==.',
['刺猬']='刺猬骑士:BAAALgAECgYJDAAAAA==.',
['北宅']='北宅:BAAALgAECgUJBQAAAA==.',
['卡拉']='卡拉瓦乔:BAAALgAECgIJAgAAAA==.',
['叶伊']='叶伊莎:BAAALgAECgYJBgAAAA==.',
['哈基']='哈基咪:BAAALgAECgYJCgAAAA==.',
['哭泣']='哭泣猫猫头:BAAALgADCgUJBQAAAA==.',
['嘉嘉']='嘉嘉小公主:BAAALgAECgMJAwAAAA==.',
['图图']='图图不吃鱼:BAAALgAECgEJAQAAAA==.',
['奶德']='奶德丶:BAAALgADCgIJAgAAAA==.',
['完美']='完美伊利单:BAAALgAFFAEJAgAAAA==.完美矮子法神:BAAALgADCgIJAgAAAA==.完美自在极意:BAABLgAFFH8FAAIFAAIJowyWBACgAAAFAAIJowyWBACgAAAAAA==.',
['幻彩']='幻彩一号:BAAALgAECgkJAgAAAA==.',
['弹一']='弹一闪:BAACLgAFFH8KAAIEAAQJKR3KAgBuAQAEAAQJKR3KAgBuAQAuAAQKfx8AAgQACAmzG5YQAJUCAAQACAmzG5YQAJUCAAAA.',
['戒骄']='戒骄戒躁:BAAALgAFFAUJAQAAAA==.',
['扣脚']='扣脚烧妇:BAAALgADCgUJBQAAAA==.',
['星辰']='星辰丶:BAAALgAECgYJCAAAAA==.',
['昨天']='昨天星期几:BAAALgAECgIJAgAAAA==.',
['术之']='术之战魂:BAAALgAECgYJBgAAAA==.',
['李莉']='李莉丝:BAAALgAECgYJCgABLgAECgcJIQAGAHQhAA==.',
['水蜜']='水蜜桃:BAAALgAECgQJBAAAAA==.',
['澳洲']='澳洲龙王:BAAALgADCgEJAQAAAA==.',
['火花']='火花骑士:BAAALgAECgQJBQAAAA==.',
['狂放']='狂放骚年:BAAALgAFFAQJBAAAAA==.',
['狂野']='狂野大猛狼:BAABLgAECn8aAAIHAAcJTRrbhwBxAQAHAAcJTRrbhwBxAQAAAA==.',
['狸沫']='狸沫:BAAALgAECgkJDwAAAA==.',
['璇音']='璇音:BAAALgAFFAMJAwAAAA==.',
['白梦']='白梦妍:BAAALgAECgUJBgAAAA==.',
['糖果']='糖果超甜:BAAALgAECgYJBgAAAA==.',
['老司']='老司机:BAABLgAECn8nAAIIAAgJyiKjBQB4AgAIAAgJyiKjBQB4AgAAAA==.',
['英雄']='英雄哥丶:BAAALgAECgYJDQAAAA==.',
['茉茉']='茉茉丶沃哈娜:BAAALgADCgUJBQAAAA==.',
['豆橛']='豆橛子:BAAALgAECgUJBQAAAA==.',
['超级']='超级猪猪侠:BAAALgADCgYJCAABLgAECgcJGgAHAE0aAA==.',
['邦邦']='邦邦给你两拳:BAAALgAECgQJBAAAAA==.',
['飞沙']='飞沙风中转:BAAALgAECgYJCQAAAA==.',
['香蕉']='香蕉:BAABLgAFFH8FAAIIAAQJywm/GAD6AAAIAAQJywm/GAD6AAAAAA==.',
['龙虾']='龙虾萌法:BAAALgADCgEJAQAAAA==.',
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
