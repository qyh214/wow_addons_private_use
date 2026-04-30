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

local lookup = {'Mage-Frost','Rogue-Subtlety','Monk-Brewmaster','Hunter-Marksmanship','Paladin-Retribution','Monk-Windwalker','Hunter-BeastMastery','Hunter-Survival','Priest-Discipline','Unknown-Unknown','Warlock-Destruction','Warlock-Demonology',}
local provider = {region='CN',realm='伊森德雷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Cr='Cruise:BAAALgADCgIJAgAAAA==.',
Le='Lemon:BAAALgADCgYJBgAAAA==.',
Mi='Minke:BAAALgADCgUJBQAAAA==.',
Os='Oss:BAAALgAECgQJBAAAAA==.',
['一颗']='一颗番薯:BAAALgAECgEJAgAAAA==.',
['三十']='三十六个术爷:BAAALgAFFAIJAwAAAA==.',
['三哥']='三哥:BAAALgAECgUJBQAAAA==.',
['丶丶']='丶丶教父:BAABLgAFFH8GAAIBAAQJUAXeJgAXAQABAAQJUAXeJgAXAQAAAA==.',
['丶永']='丶永不落幕:BAAALgAECgUJBQAAAA==.',
['你压']='你压我头发了:BAABLgAECn8UAAICAAcJexxlFQBlAgACAAcJexxlFQBlAgAAAA==.',
['元神']='元神启动:BAAALgAECgUJBQAAAA==.',
['克里']='克里斯蒂亚诺:BAAALgAFFAEJAQAAAA==.',
['冬贝']='冬贝利酱:BAAALgAECgYJDAAAAA==.',
['函数']='函数:BAAALgAECgEJAwAAAA==.',
['口口']='口口:BAABLgAECn8UAAIDAAcJfxKELgCeAQADAAcJfxKELgCeAQAAAA==.',
['叶落']='叶落孤城:BAAALgAECgUJCgAAAA==.',
['四哥']='四哥:BAAALgAECgEJAQAAAA==.',
['圣火']='圣火昭昭:BAAALgAECgEJAwAAAA==.',
['地主']='地主家的儿子:BAAALgAECgYJCAAAAA==.',
['地獄']='地獄小牛:BAAALgAECgEJAwAAAA==.',
['城市']='城市病人丶:BAAALgAECgIJAwAAAA==.',
['大象']='大象三零六三:BAAALgAECgUJBQAAAA==.',
['天堂']='天堂灬寶貝:BAAALgAECgEJAwAAAA==.',
['妩媚']='妩媚儿:BAAALgAECgIJAgAAAA==.',
['娜璐']='娜璐璐:BAAALgAECgIJAQABLgAFFAQJCwAEABsiAA==.',
['娜萨']='娜萨莉莉:BAABLgAFFH8FAAIFAAMJCyKEGgDMAAAFAAMJCyKEGgDMAAAAAA==.',
['孑瓜']='孑瓜白鬼:BAAALgAECgMJBAAAAA==.',
['宏观']='宏观研究员:BAAALgAECgEJAQAAAA==.',
['寒冰']='寒冰:BAAALgAECgEJAQAAAA==.',
['小姊']='小姊妹:BAAALgADCgYJBgAAAA==.',
['小黑']='小黑手咕噜:BAABLgAECn8XAAIGAAgJChUeIQDNAQAGAAgJChUeIQDNAQAAAA==.',
['工藤']='工藤静香:BAAALgAFFAYJAQAAAA==.',
['幸勿']='幸勿相忘已:BAAALgADCgYJBgAAAA==.',
['張敏']='張敏:BAABLgAECn8WAAQHAAYJUiKZNgDUAQAHAAYJUiKZNgDUAQAIAAIJ6BCxJwB5AAAEAAEJRQBInAAJAAAAAA==.',
['我不']='我不是医生丶:BAAALgADCgcJBwAAAA==.',
['星辰']='星辰小阿姨:BAAALgAECgYJBgAAAA==.',
['月亽']='月亽:BAAALgAECgcJBwAAAA==.',
['月孛']='月孛:BAAALgAECgIJAgAAAA==.',
['某只']='某只暴力熊:BAAALgAECgIJAgAAAA==.',
['爲誰']='爲誰瘋誑:BAAALgAECgEJAQAAAA==.',
['牧云']='牧云清歌:BAAALgAECgUJBAAAAA==.',
['牧有']='牧有鱼丸:BAABLgAFFH8NAAIJAAUJThDlCQBAAQAJAAUJThDlCQBAAQAAAA==.',
['狂暴']='狂暴冰箱:BAAALgAECgEJAQAAAA==.',
['男人']='男人眼中钉:BAAALgAECgYJDAAAAA==.',
['皮皮']='皮皮好好看:BAAALgAFFAEJAQAAAA==.',
['瞅丑']='瞅丑愁:BAAALgADCgUJBQAAAA==.',
['瞪你']='瞪你咋滴:BAAALgAFFAIJAwAAAA==.',
['离析']='离析:BAAALgAECgYJAgAAAA==.',
['米大']='米大爺:BAAALgAECgQJBgAAAA==.',
['紫炁']='紫炁:BAAALgAECgUJDAAAAA==.',
['红豆']='红豆汤包:BAAALgAFFAIJBAAAAA==.',
['给牛']='给牛牛乐一个:BAAALgADCgUJBQAAAA==.',
['罗纳']='罗纳尔少:BAAALgAECgEJAQABLgAECgIJAgAKAAAAAA==.',
['耍宝']='耍宝宝:BAAALgAECgQJBAAAAA==.',
['草莽']='草莽英雄:BAAALgAECgEJAwAAAA==.',
['莱姆']='莱姆与青柠:BAAALgADCgUJBQAAAA==.',
['蛋蛋']='蛋蛋哥:BAAALgAECgQJBwAAAA==.',
['诚牧']='诚牧:BAAALgAFFAIJAgAAAA==.',
['贝欣']='贝欣:BAAALgAECgEJAQAAAA==.',
['铭刻']='铭刻诺言:BAAALgAECgYJBgAAAA==.',
['门捷']='门捷列夫:BAAALgADCgcJBwAAAA==.',
['雪糕']='雪糕糊你脸:BAACLgAFFH8UAAMLAAUJnyMwAQDlAQALAAUJUx8wAQDlAQAMAAQJbR9PEABeAQAuAAQKfyEAAwwACAkhI4sQAPYCAAwACAlyIYsQAPYCAAsABQkYIQMSALsBAAAA.',
['顾温']='顾温池:BAAALgAECgYJDwAAAA==.',
['高尔']='高尔萨姆:BAAALgAFFAIJAwAAAA==.',
['龙虎']='龙虎门杀手:BAAALgAFFAIJAQAAAA==.',
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
