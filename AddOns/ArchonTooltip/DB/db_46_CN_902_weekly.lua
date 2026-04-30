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

local lookup = {'Mage-Frost','Priest-Discipline','Warrior-Arms','DeathKnight-Unholy','Shaman-Restoration','Evoker-Preservation','Druid-Restoration','Warlock-Demonology','Hunter-Survival',}
local provider = {region='CN',realm='黑锋哨站',name='CN',type='weekly',zone=46,date='2026-04-25',data={Fi='Figor:BAAALgAECgcJDAAAAA==.',
Ha='Hawk:BAAALgADCgcJBwAAAA==.',
He='Hedy:BAAALgAECgEJAQAAAA==.',
Iv='Ivurtnel:BAAALgADCgEJAQAAAA==.',
Ly='Lynne:BAAALgAECgcJCwAAAA==.',
Pu='Purcotton:BAAALgADCgMJAwAAAA==.',
Sd='Sder:BAAALgAECgQJBgAAAA==.',
Ss='Ssder:BAAALgAECgEJAQAAAA==.',
['一呆']='一呆槑呆二:BAAALgADCgcJBwAAAA==.',
['丶點']='丶點:BAAALgAECgYJCwAAAA==.',
['乐玲']='乐玲利:BAAALgAECgEJAQAAAA==.',
['云落']='云落天垟:BAAALgADCgIJAgAAAA==.',
['卡露']='卡露琪亚:BAABLgAECn8mAAIBAAgJMyBoKQDNAgABAAgJMyBoKQDNAgAAAA==.',
['只要']='只要有你:BAAALgAECgcJDwAAAA==.',
['听雨']='听雨望云:BAAALgAECgkJBgAAAA==.',
['圣斗']='圣斗:BAAALgAECgEJAQAAAA==.',
['圣骑']='圣骑没有奶:BAAALgAECgEJAQAAAA==.',
['夏小']='夏小寒:BAAALgAECgcJAQAAAA==.夏小满:BAAALgAECgkJBwAAAA==.',
['夏惊']='夏惊蛰:BAAALgAFFAQJBAAAAA==.',
['夏春']='夏春分:BAAALgAFFAQJBAAAAA==.',
['夏未']='夏未:BAAALgAFFAQJBAAAAA==.',
['夏清']='夏清明:BAAALgAFFAQJAwAAAA==.',
['夏立']='夏立夏:BAAALgAFFAMJAwAAAA==.夏立春:BAAALgAFFAQJAgAAAA==.',
['夏芒']='夏芒种:BAAALgAFFAIJAgAAAA==.',
['外特']='外特法:BAAALgAECgYJCAAAAA==.',
['多米']='多米诺:BAAALgAECgEJAgAAAA==.',
['大炮']='大炮哥:BAAALgADCgEJAQAAAA==.',
['大熊']='大熊:BAAALgAECgEJAQAAAA==.',
['嫂子']='嫂子:BAAALgAECgYJCwAAAA==.',
['小小']='小小孑凡人:BAAALgAECgQJBAAAAA==.',
['小懒']='小懒虫:BAABLgAFFH8TAAICAAYJixYaAgAEAgACAAYJixYaAgAEAgAAAA==.',
['小時']='小時候可牛了:BAAALgAECgkJEAABLgAFFAYJCgADAH4fAA==.',
['小鱼']='小鱼蛋:BAAALgAECgYJBgABLgAFFAQJBgAEAGkQAA==.',
['尼格']='尼格法:BAACLgAFFH8HAAIBAAMJWRnkJwATAQABAAMJWRnkJwATAQAuAAQKfx0AAgEACAmmIcQkAN8CAAEACAmmIcQkAN8CAAAA.',
['山高']='山高人为峰:BAAALgAECgQJCAAAAA==.',
['峰丶']='峰丶:BAAALgAECgEJAQAAAA==.',
['弗拉']='弗拉梅尔:BAAALgAECgYJBgAAAA==.',
['张飞']='张飞牛肉:BAAALgAECgQJAwAAAA==.',
['恋爱']='恋爱达人:BAAALgAECgEJAgAAAA==.',
['撼地']='撼地神牛:BAAALgAECgEJAgAAAA==.',
['未知']='未知目标:BAAALgAECgYJCQAAAA==.',
['杨超']='杨超越丶:BAABLgAECn8VAAIFAAYJ4SDOHwAgAgAFAAYJ4SDOHwAgAgAAAA==.',
['柴薪']='柴薪雲羽:BAAALgAECgEJAQAAAA==.',
['死判']='死判丶抠脚:BAAALgAECgEJAQAAAA==.',
['沁龙']='沁龙:BAAALgAECgIJAgAAAA==.',
['浩空']='浩空:BAAALgAECgcJBwAAAA==.',
['混元']='混元形意掌门:BAAALgADCgIJAgAAAA==.',
['爱家']='爱家的汉子:BAAALgAECgEJAQAAAA==.',
['牛逼']='牛逼王:BAAALgAECgEJAgAAAA==.',
['科尔']='科尔沁:BAAALgADCgMJAwAAAA==.',
['糍粑']='糍粑辣子鸡:BAABLgAFFH8JAAIGAAUJhBKYAgCQAQAGAAUJhBKYAgCQAQAAAA==.',
['紧道']='紧道岩:BAAALgAECgYJCQAAAA==.',
['组我']='组我发财:BAABLgAFFH8IAAIHAAQJ7RtgCABMAQAHAAQJ7RtgCABMAQAAAA==.',
['花翎']='花翎月:BAAALgAECgEJAQAAAA==.',
['路山']='路山彦:BAAALgAECgUJBQAAAA==.',
['雨落']='雨落青檐:BAAALgAECgMJBAABLgAFFAMJBwAIAAAJAA==.',
['霞之']='霞之丘诗羽:BAAALgAECgMJAwAAAA==.',
['青椒']='青椒回锅肉:BAABLgAFFH8JAAIGAAUJfhfXAQCzAQAGAAUJfhfXAQCzAQAAAA==.',
['靖水']='靖水空:BAABLgAECn8cAAIJAAcJNxsOCQBSAgAJAAcJNxsOCQBSAgAAAA==.',
['黄飞']='黄飞冯:BAAALgAECgcJBQAAAA==.',
['點點']='點點丶:BAAALgAECgYJBgAAAA==.',
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
