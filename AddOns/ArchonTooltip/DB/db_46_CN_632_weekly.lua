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

local lookup = {'Mage-Frost','Shaman-Restoration','Monk-Brewmaster','Paladin-Holy','Monk-Windwalker','Paladin-Retribution','DeathKnight-Unholy','Druid-Balance','Warlock-Demonology','Unknown-Unknown','Druid-Restoration',}
local provider = {region='CN',realm='大漩涡',name='CN',type='weekly',zone=46,date='2026-04-25',data={Be='Bezaubernd:BAAALgAECgMJAwAAAA==.',
Li='Lightsaber:BAAALgAECgUJBQAAAA==.',
Mo='Mochi:BAAALgAECgYJDAABLgAFFAQJCwABACsVAA==.',
Ni='Nier:BAAALgAECgIJAgAAAA==.',
Or='Originalsin:BAAALgADCgMJAwAAAA==.',
Pa='Pact:BAAALgAECgcJBwAAAA==.',
Re='Retpal:BAAALgAECgEJAQAAAA==.',
Sa='Safari:BAAALgADCgMJAwAAAA==.',
Ty='Tytyty:BAAALgAECgQJBQAAAA==.',
Wa='Wallsay:BAAALgAFFAIJBAAAAA==.',
['万载']='万载无双:BAAALgAECgQJBwAAAA==.万载无双丶:BAAALgAECgEJAQAAAA==.',
['不能']='不能没萨满丶:BAAALgAECgMJAwAAAA==.',
['丨爵']='丨爵枼丨:BAAALgAECgYJDwAAAA==.',
['伺机']='伺机待发硬币:BAAALgAECgcJCAAAAA==.',
['元素']='元素伝說:BAABLgAECn8UAAICAAYJ+BwpKADwAQACAAYJ+BwpKADwAQAAAA==.',
['八包']='八包薯条:BAAALgADCgcJBwAAAA==.',
['六包']='六包薯条:BAABLgAECn8gAAIDAAgJyx0xGABDAgADAAgJyx0xGABDAgAAAA==.',
['冯小']='冯小怜:BAABLgAFFH8GAAIEAAYJew0MAgDiAQAEAAYJew0MAgDiAQAAAA==.',
['别理']='别理我烦着呢:BAAALgADCgEJAQAAAA==.',
['动感']='动感的巫师:BAAALgAECggJBgAAAA==.',
['叶紫']='叶紫麻灬:BAAALgAECgYJCgAAAA==.',
['吃瓜']='吃瓜群众:BAABLgAECn8ZAAIFAAcJSBvdFgAwAgAFAAcJSBvdFgAwAgAAAA==.',
['哎嗨']='哎嗨唷:BAAALgAECgMJAwAAAA==.',
['唯美']='唯美式丶恋:BAAALgADCgMJBAAAAA==.',
['大耳']='大耳朵小老頭:BAAALgAECgUJBQAAAA==.',
['大腳']='大腳板小老頭:BAAALgAECgYJDAAAAA==.',
['天堂']='天堂星辰:BAAALgADCgEJAQAAAA==.',
['妮露']='妮露可可:BAAALgAECgUJBQAAAA==.',
['妹子']='妹子养眼:BAABLgAECn8VAAIGAAcJqhjZRgAPAgAGAAcJqhjZRgAPAgAAAA==.',
['宫保']='宫保个鸡丁:BAAALgADCgEJAQAAAA==.',
['寒冰']='寒冰术师:BAAALgADCgEJAQAAAA==.',
['小小']='小小折腾丶:BAAALgAFFAQJBAAAAA==.',
['小潘']='小潘:BAAALgAECgMJAwAAAA==.',
['左旗']='左旗刷期:BAAALgAFFAQJBAAAAA==.',
['差点']='差点是美男:BAAALgADCgUJBQAAAA==.',
['帅气']='帅气的老王:BAAALgAECgYJDAAAAA==.',
['干申']='干申大那多:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁的大角牛:BAAALgADCgMJAwAAAA==.忧郁的小小吼:BAAALgADCgQJBgAAAA==.忧郁的小阿飞:BAAALgAECgEJAQAAAA==.忧郁的小鲨鱼:BAAALgAECgQJBAAAAA==.',
['我才']='我才是春哥:BAAALgAECgYJCAAAAA==.',
['我是']='我是大黑手:BAAALgADCgQJBAAAAA==.',
['我的']='我的大肚腩:BAAALgAFFAIJAgAAAA==.',
['敌丨']='敌丨法:BAAALgADCgEJAQAAAA==.',
['星辰']='星辰漂流:BAAALgAECgUJBQAAAA==.',
['晓梦']='晓梦:BAAALgAECgYJBgAAAA==.',
['枫叶']='枫叶爱熙:BAAALgAECgQJBgAAAA==.枫叶爱睿:BAAALgAECgYJCQAAAA==.',
['没有']='没有灵魂兽:BAAALgADCgYJBwAAAA==.',
['河馬']='河馬:BAABLgAFFH8IAAIHAAMJbiIQHwAgAQAHAAMJbiIQHwAgAQAAAA==.',
['焱淼']='焱淼森鑫垚:BAAALgADCgMJAwAAAA==.',
['爵枼']='爵枼丶:BAAALgAECgYJBgAAAA==.',
['独孤']='独孤冥牙:BAAALgAECgkJAQAAAA==.',
['甘雨']='甘雨:BAAALgAECgYJBgAAAA==.',
['看看']='看看人家:BAAALgAFFAEJAQAAAA==.',
['神奇']='神奇的滄寒:BAAALgAECgUJBwAAAA==.',
['穆普']='穆普利亚:BAAALgAECgQJBAAAAA==.',
['米娜']='米娜希儿:BAAALgAECgEJAQAAAA==.',
['老头']='老头:BAAALgAECgcJCwAAAA==.',
['耐力']='耐力卷轴:BAAALgAFFAIJAgAAAA==.',
['胸腺']='胸腺嘧啶:BAAALgAECgMJBgAAAA==.',
['花有']='花有重开日:BAAALgAFFAQJAQABLgAFFAUJCwAIAAgHAA==.',
['萌萌']='萌萌忻:BAAALgAFFAIJAgAAAA==.萌萌的筱紫瞳:BAABLgAFFH8CAAIJAAIJ3BjxMQCuAAAJAAIJ3BjxMQCuAAAAAA==.',
['萨萌']='萨萌德猎:BAAALgAECgEJAQAAAA==.',
['萨薇']='萨薇雅:BAAALgAECgYJBgAAAA==.',
['蓝田']='蓝田玉暖:BAAALgADCgYJBgAAAA==.',
['西多']='西多村咩咩:BAAALgADCgYJBgAAAA==.',
['追踨']='追踨者:BAAALgAECgkJBwAAAA==.',
['逆水']='逆水寒冰:BAAALgAECgYJDgAAAA==.',
['霸器']='霸器外漏:BAAALgAECgYJBwAAAA==.',
['风恋']='风恋之吻:BAAALgADCgIJAgAAAA==.',
['风暴']='风暴包包:BAAALgAECgEJAQAAAA==.',
['飘零']='飘零似浮云:BAAALgAECgkJCQAAAA==.',
['香煎']='香煎豆腐:BAAALgADCgUJBQAAAA==.',
['魔法']='魔法易伤:BAAALgAECgYJBwABLgAFFAIJAgAKAAAAAA==.',
['鹏骑']='鹏骑小清欢:BAAALgAECgMJAwAAAA==.鹏骑小牛肉:BAAALgAECgMJAwAAAA==.鹏骑熊跑:BAABLgAECn8aAAMIAAcJ9hVjKgCtAQAIAAcJ9hVjKgCtAQALAAEJUxRExgA9AAAAAA==.',
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
