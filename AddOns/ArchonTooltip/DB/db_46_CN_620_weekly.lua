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

local lookup = {'Evoker-Augmentation','Warrior-Fury','Warrior-Protection','Hunter-BeastMastery','Druid-Balance','Shaman-Elemental','DemonHunter-Devourer','DemonHunter-Havoc','Paladin-Retribution','Paladin-Holy','DeathKnight-Unholy','Shaman-Restoration','Evoker-Preservation','Evoker-Devastation',}
local provider = {region='CN',realm='埃雷达尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={He='Hera:BAAALgAFFAEJAQAAAA==.',
Ki='Kiraramkiv:BAAALgAECgEJAQAAAA==.',
Lu='Luciferss:BAAALgAFFAEJAQABLgAFFAMJBgABAJUZAA==.',
Ph='Phantasos:BAAALgAECgYJCgAAAA==.',
Re='Rex:BAAALgAECgQJBAAAAA==.',
Sa='Sakra:BAABLgAFFH8FAAMCAAUJ1ABJHQCBAAACAAQJSgBJHQCBAAADAAEJcwKbEQA2AAAAAA==.',
Sk='Skirmisher:BAABLgAFFH8HAAIEAAMJrBAHDAACAQAEAAMJrBAHDAACAQAAAA==.',
Sw='Swallowyy:BAAALgAECgYJCgAAAA==.',
['一刹']='一刹花火灬:BAAALgAECgEJAgAAAA==.',
['丶聆']='丶聆聼:BAAALgAECgIJAgAAAA==.',
['你在']='你在干神魔:BAAALgADCgEJAQAAAA==.',
['你来']='你来打我啊:BAAALgADCgEJAQAAAA==.',
['你说']='你说得对:BAAALgAECgIJAgAAAA==.',
['你迟']='你迟来的爱:BAAALgAECgUJBwAAAA==.',
['加尔']='加尔的长发:BAABLgAFFH8GAAIFAAMJWRTNDQACAQAFAAMJWRTNDQACAQAAAA==.加尔福特:BAAALgAFFAEJAQAAAA==.',
['卓王']='卓王:BAAALgADCgMJAwAAAA==.',
['卡尼']='卡尼:BAAALgAECgMJAwAAAA==.',
['叁成']='叁成味火锅:BAAALgAFFAIJAgAAAA==.',
['古德']='古德猫宁:BAAALgAECgYJBgAAAA==.',
['周打']='周打爆:BAAALgAECgUJBwAAAA==.',
['哈雅']='哈雅:BAAALgAECgMJBAABLgAFFAMJBwAEAKwQAA==.',
['大吉']='大吉岭茶:BAABLgAFFH8TAAIGAAYJUB30AABBAgAGAAYJUB30AABBAgAAAA==.',
['天人']='天人:BAAALgAECgYJCAAAAA==.',
['奔放']='奔放的马:BAABLgAECn8eAAMHAAYJzxUfXQCKAQAHAAYJjxQfXQCKAQAIAAYJFBIkMgBDAQAAAA==.',
['奶丝']='奶丝:BAAALgAECgUJBgAAAA==.',
['妈妈']='妈妈:BAAALgAECgUJBQAAAA==.',
['威武']='威武的大元宝:BAAALgADCgIJAgAAAA==.',
['安娜']='安娜莉丝:BAAALgAECgQJBAAAAA==.',
['小小']='小小菜青虫:BAAALgAECgQJBQAAAA==.',
['小芒']='小芒种:BAAALgAECgkJEAAAAA==.',
['尽大']='尽大力了:BAABLgAFFH8IAAIJAAQJ6gdHEAAkAQAJAAQJ6gdHEAAkAQABLgAFFAUJDwAKADEcAA==.',
['帝龙']='帝龙:BAAALgAECgEJAQAAAA==.',
['幽冥']='幽冥之舞:BAAALgAECgMJAwAAAA==.',
['德德']='德德哋:BAAALgADCgUJBQAAAA==.',
['情歌']='情歌之后:BAABLgAECn8fAAILAAgJlR1BIgC3AgALAAgJlR1BIgC3AgAAAA==.',
['惩戒']='惩戒魅魔:BAABLgAFFH8GAAIMAAQJxAxACgAxAQAMAAQJxAxACgAxAQAAAA==.',
['愿得']='愿得一人心:BAAALgAFFAIJAgAAAA==.',
['无聊']='无聊的枫叶:BAAALgAECgQJBwAAAA==.',
['星宿']='星宿:BAAALgAECgYJBgAAAA==.',
['春秋']='春秋婵:BAAALgAECgYJBgAAAA==.',
['月葵']='月葵:BAAALgAECgkJEAAAAA==.',
['柳如']='柳如烟:BAAALgAECgUJBQAAAA==.',
['死不']='死不了骑士:BAAALgADCgEJAQAAAA==.',
['毕川']='毕川内酷:BAAALgAECgQJBAAAAA==.',
['水晶']='水晶秀秀:BAAALgAECgYJEQAAAA==.',
['氺晶']='氺晶留香:BAAALgAECgEJAgAAAA==.',
['涅磬']='涅磬苍穹:BAAALgAECgQJBQAAAA==.',
['烈焰']='烈焰魔导:BAAALgAECgYJCwAAAA==.',
['牛牛']='牛牛冲锋:BAAALgADCgcJBwAAAA==.',
['狂秒']='狂秒:BAAALgAECgUJCgAAAA==.',
['瓦利']='瓦利埃尔:BAAALgAECgIJAgAAAA==.',
['看看']='看看怎么个事:BAABLgAECn8WAAMNAAkJqSE5AQB9AwANAAkJqSE5AQB9AwAOAAYJvhNRHQBEAQABLgAFFAYJCgAMAHYKAA==.',
['真岛']='真岛吾朗:BAAALgAECgIJAgAAAA==.',
['秀雪']='秀雪嫣:BAAALgADCgMJAwAAAA==.',
['笑起']='笑起来很美:BAAALgAECgYJEAAAAA==.',
['笨蛋']='笨蛋:BAABLgAFFH8MAAILAAQJswdhHQAsAQALAAQJswdhHQAsAQAAAA==.',
['终极']='终极肉盾:BAAALgADCgEJAQAAAA==.',
['美美']='美美哒哒:BAAALgAECgQJBAAAAA==.',
['聪明']='聪明的小脑袋:BAAALgAFFAQJBAAAAA==.',
['芊芊']='芊芊随风:BAAALgAECgQJBQAAAA==.',
['莲影']='莲影:BAAALgAECgMJBgAAAA==.',
['蛋糕']='蛋糕要装起来:BAAALgAECgkJCQAAAA==.',
['铲屎']='铲屎猎人丶:BAAALgAECgQJBAAAAA==.',
['银发']='银发的雨曦:BAAALgADCgEJAgAAAA==.',
['阳谷']='阳谷坞老干部:BAAALgADCgUJBQAAAA==.',
['雨之']='雨之昊天:BAAALgAECgcJDgAAAA==.',
['风之']='风之力:BAAALgADCgUJBQAAAA==.',
['高大']='高大壮:BAAALgAECgUJBQAAAA==.',
['魔王']='魔王:BAAALgAECgEJAQAAAA==.',
['鱼尾']='鱼尾何簁簁:BAAALgAECgEJAQAAAA==.',
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
