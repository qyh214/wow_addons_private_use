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

local lookup = {'Druid-Balance','Druid-Guardian','Druid-Restoration','Monk-Mistweaver','DemonHunter-Havoc','Unknown-Unknown','Warrior-Protection',}
local provider = {region='CN',realm='阿努巴拉克',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akai:BAAALgADCgEJAQAAAA==.',
Bi='Bigbully:BAAALgAECgQJBAAAAA==.',
Dk='Dka:BAAALgAECgUJCAAAAA==.',
Et='Eternallove:BAABLgAECn8bAAQBAAcJahaMKQCzAQABAAcJahaMKQCzAQACAAQJ5gsXIwCEAAADAAIJWAvhuABTAAAAAA==.',
Fi='Firefox:BAAALgADCgEJAQAAAA==.',
Zs='Zst:BAAALgAFFAEJAQAAAA==.',
['不高']='不高兴:BAAALgADCgEJAQAAAA==.',
['丿期']='丿期待灬:BAAALgAECgUJBQAAAA==.丿期待罒:BAAALgAECgEJAQAAAA==.',
['云深']='云深不知处:BAAALgADCgEJAQAAAA==.',
['以德']='以德服人:BAAALgAECgEJAQAAAA==.',
['伊兰']='伊兰:BAAALgAECgYJCwAAAA==.',
['冰点']='冰点儿:BAAALgADCgUJBQAAAA==.',
['十杯']='十杯不醉:BAABLgAECn8UAAIEAAYJ0yDRFAAiAgAEAAYJ0yDRFAAiAgAAAA==.',
['印度']='印度直升机:BAAALgAECgYJBgAAAA==.',
['君临']='君临:BAABLgAECn8VAAIFAAcJZRFrKAB/AQAFAAcJZRFrKAB/AQAAAA==.',
['周汤']='周汤豪:BAAALgAECgYJEQAAAA==.',
['命定']='命定幽影:BAAALgAECgEJBAABLgAECgQJBAAGAAAAAA==.',
['地狱']='地狱打工人:BAAALgADCgEJAQAAAA==.',
['天际']='天际孤星:BAAALgADCgEJAQAAAA==.',
['奕寒']='奕寒:BAAALgAECgcJBgAAAA==.',
['寂静']='寂静天堂:BAAALgAECgQJBAAAAA==.',
['小僧']='小僧有礼了:BAAALgAECgQJBAAAAA==.',
['小法']='小法:BAAALgAECgQJAwAAAA==.',
['巡猎']='巡猎:BAAALgAECgYJBgAAAA==.',
['德老']='德老大:BAAALgAECgEJAgAAAA==.',
['心中']='心中有树:BAAALgADCgUJCAAAAA==.',
['怪脸']='怪脸灵姝:BAAALgAECgQJBAAAAA==.',
['我是']='我是魔鬼:BAAALgADCgMJAwAAAA==.',
['扣一']='扣一扣一:BAAALgADCgUJBQAAAA==.',
['朔一']='朔一朔:BAAALgAECgYJBwAAAA==.',
['术业']='术业有专攻:BAAALgAECgMJAwAAAA==.',
['树死']='树死骑:BAAALgAECgIJAgAAAA==.',
['森林']='森林追猎者:BAAALgAECgEJAQAAAA==.',
['死神']='死神的哈士奇:BAAALgAFFAIJAgAAAA==.',
['沾满']='沾满天空的泪:BAAALgADCgYJBgAAAA==.',
['潇灑']='潇灑灬牛坏坏:BAAALgAECgEJAQAAAA==.',
['烟花']='烟花捏么凉:BAAALgAFFAEJAQAAAA==.',
['狐黄']='狐黄白柳灰:BAAALgAECgEJAQAAAA==.',
['瞧你']='瞧你那儿:BAAALgADCgUJBQAAAA==.',
['美味']='美味大紫薯:BAAALgAFFAEJAQAAAA==.',
['芬克']='芬克:BAAALgAECgYJBgAAAA==.',
['草里']='草里等妲己:BAAALgADCgEJAQAAAA==.',
['血色']='血色的石头:BAAALgAFFAQJBAABLgAFFAcJBQADAMsVAA==.',
['裸宾']='裸宾汉:BAAALgAECgEJAQAAAA==.',
['辉夜']='辉夜旋流曲:BAAALgADCgEJAQAAAA==.',
['鈺玲']='鈺玲瓏:BAAALgADCgYJCwAAAA==.',
['闹元']='闹元宵:BAAALgAECgUJBgAAAA==.',
['阿锴']='阿锴阿锴阿:BAAALgAECgQJBgAAAA==.',
['陈丶']='陈丶风暴烈酒:BAAALgAECgUJCAAAAA==.',
['限量']='限量法神:BAAALgAECgQJCQAAAA==.',
['风骚']='风骚的小燕子:BAABLgAFFH8MAAIHAAQJzw4aBgAIAQAHAAQJzw4aBgAIAQAAAA==.',
['高级']='高级坦克:BAAALgADCgEJAQAAAA==.',
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
