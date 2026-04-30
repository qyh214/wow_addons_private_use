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

local lookup = {'Druid-Restoration','Paladin-Retribution','Druid-Balance','Unknown-Unknown','Mage-Frost','Warlock-Demonology','Hunter-Marksmanship','Evoker-Augmentation','Evoker-Preservation','DemonHunter-Devourer','DeathKnight-Blood','Priest-Holy','Rogue-Subtlety',}
local provider = {region='CN',realm='拉文霍德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Areslol:BAAALgAFFAEJAgAAAA==.',
Ba='Bahumbug:BAAALgAECgUJCwAAAA==.',
Ca='Cady:BAAALgAECgYJCAAAAA==.',
Dy='Dyvoker:BAAALgAECgcJDQABLgAFFAQJDAABAFokAA==.',
Fi='Finn:BAAALgAECgcJAgAAAA==.',
Ga='Gaily:BAAALgAECgEJAQAAAA==.',
Lo='Losemind:BAAALgAECgYJCAAAAA==.',
Mi='Millaboreas:BAAALgAECgUJBQAAAA==.',
Pe='Pele:BAAALgAECgQJBQAAAA==.Perfect:BAAALgAECgEJAQAAAA==.',
Ti='Tindomiel:BAAALgADCgEJAQAAAA==.',
Ze='Zeroi:BAAALgADCgEJAQAAAA==.',
['一滴']='一滴罐头汁:BAAALgAECgUJCQAAAA==.',
['不会']='不会无敌:BAABLgAECn8WAAICAAcJFR7PLwBjAgACAAcJFR7PLwBjAgAAAA==.',
['两岸']='两岸一统:BAAALgAFFAQJAQAAAA==.',
['丨拓']='丨拓跋菩萨丨:BAAALgADCgIJBAAAAA==.',
['主宰']='主宰灬刺心:BAAALgAECgEJAQAAAA==.',
['乐一']='乐一悠:BAAALgAECgUJAwAAAA==.',
['云淡']='云淡风云:BAABLgAECn8VAAMDAAYJAhgDMgB6AQADAAYJAhgDMgB6AQABAAUJyxHEYQAsAQAAAA==.',
['以骑']='以骑挡千:BAACLgAFFH8JAAICAAMJDBsmBwAbAQACAAMJDBsmBwAbAQAuAAQKfxYAAgIABwm2Hp4uAGgCAAIABwm2Hp4uAGgCAAAA.',
['伴风']='伴风听雨:BAAALgAECgEJAQAAAA==.',
['似梦']='似梦似醒:BAAALgAECgYJCgAAAA==.',
['兰斯']='兰斯彼恩:BAAALgAECgUJAgAAAA==.',
['冰封']='冰封白夜:BAAALgAECgEJAQAAAA==.',
['凌晨']='凌晨黄昏:BAAALgAECgYJBgABLgAECgkJBwAEAAAAAA==.',
['凯瑟']='凯瑟兰斯:BAAALgADCgQJBAAAAA==.',
['劣人']='劣人小小:BAAALgAECgQJBAAAAA==.',
['北鼻']='北鼻熊熊:BAAALgAECgIJBAAAAA==.',
['双魚']='双魚理:BAABLgAFFH8IAAIFAAQJFBpcPwCvAAAFAAQJFBpcPwCvAAABLgAFFAYJCwAFAMUbAA==.',
['发条']='发条小橘子:BAAALgAECgcJBwAAAA==.',
['喔热']='喔热烈的吻:BAAALgAECgYJBgAAAA==.',
['噢丶']='噢丶在这狂混:BAAALgAECgYJDAAAAA==.',
['天丶']='天丶堂:BAAALgAECgYJBgAAAA==.',
['天山']='天山之冫:BAAALgAECgYJBgAAAA==.',
['天马']='天马行空:BAAALgAFFAEJAQABLgAFFAUJDAAGAK0mAA==.',
['寂灭']='寂灭者之镰:BAEALgADCgQJBAABLgAECgUJCgAEAAAAAA==.',
['寒夜']='寒夜影:BAAALgAECgEJAQAAAA==.',
['导半']='导半铁盒:BAAALgAECgkJCQABLgAFFAUJBwAHALciAA==.',
['小丶']='小丶扬:BAAALgAECgcJBwAAAA==.',
['小九']='小九吖:BAAALgAECgEJAQAAAA==.',
['小奶']='小奶德:BAAALgADCgcJBwAAAA==.',
['属于']='属于龙族:BAABLgAECn8VAAMIAAgJtg9qLQBWAQAIAAcJ1wtqLQBWAQAJAAYJ8QiaKQAmAQAAAA==.',
['崇灰']='崇灰虎:BAAALgAECgEJAQAAAA==.',
['布洛']='布洛妮娅:BAAALgADCgcJBwAAAA==.',
['帼歌']='帼歌响彻东京:BAABLgAFFH8IAAIKAAUJFiL8BADcAQAKAAUJFiL8BADcAQAAAA==.',
['弃天']='弃天帝:BAAALgAFFAEJAgABLgAFFAYJBQALAAcWAA==.',
['德勒']='德勒巴妮娅:BAAALgAECgcJDQAAAA==.',
['心魔']='心魔玄劫:BAAALgAECgYJBgAAAA==.',
['性感']='性感的土豆:BAAALgAECgcJBwABLgAFFAQJBAAEAAAAAA==.',
['愤怒']='愤怒的斯拉克:BAAALgAECgQJBQAAAA==.',
['慕斯']='慕斯咪:BAAALgAECgkJCQAAAA==.',
['所羅']='所羅門:BAAALgADCgQJBAAAAA==.',
['抱抱']='抱抱二二:BAAALgAFFAQJBAAAAA==.',
['收复']='收复台蜿:BAAALgAFFAQJAQAAAA==.',
['无尽']='无尽黑暗:BAAALgADCgEJAQAAAA==.',
['星河']='星河入梦:BAAALgAECgQJBAAAAA==.',
['暗黑']='暗黑西红柿:BAAALgADCgUJBQAAAA==.',
['曾经']='曾经是个骑士:BAAALgAECgEJAgAAAA==.',
['月悠']='月悠:BAAALgADCgYJBgAAAA==.',
['月渎']='月渎:BAAALgAECgYJCgAAAA==.',
['殇灬']='殇灬无痕:BAAALgAFFAIJAgAAAA==.殇灬琉璃:BAAALgAFFAIJBAAAAA==.殇灬黯舞:BAABLgAFFH8GAAIKAAIJRRH/FQCQAAAKAAIJRRH/FQCQAAAAAA==.',
['沐北']='沐北:BAAALgAECggJBgAAAA==.',
['海底']='海底捞:BAAALgADCgYJBgAAAA==.',
['熊孩']='熊孩几:BAAALgAECgEJAgAAAA==.',
['熊小']='熊小酒:BAAALgADCgUJCAAAAA==.',
['牛鼻']='牛鼻子插大葱:BAAALgADCgMJAwAAAA==.',
['狂燃']='狂燃:BAAALgAECgEJAQAAAA==.',
['狂野']='狂野的吞拿鱼:BAAALgADCgEJAQAAAA==.',
['玩世']='玩世乂不恭:BAAALgAECgYJCwAAAA==.',
['珍宝']='珍宝珠:BAAALgAECgUJBQAAAA==.',
['琴蝶']='琴蝶:BAAALgAECgYJBgAAAA==.',
['电击']='电击小子:BAAALgADCgIJAgAAAA==.',
['當我']='當我變成回憶:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂的帅鸡:BAACLgAFFH8KAAIFAAQJoAZ4FQDbAAAFAAQJoAZ4FQDbAAAuAAQKfxgAAgUACAksF85IAF0CAAUACAksF85IAF0CAAAA.',
['白沐']='白沐红尘:BAAALgAECggJBgABLgAECggJBgAEAAAAAA==.',
['皓博']='皓博迎朝阳:BAAALgAECgQJBgAAAA==.',
['真的']='真的想和你:BAAALgAECgYJBgAAAA==.',
['碧愈']='碧愈疾风:BAAALgAECgUJDAAAAA==.',
['索尔']='索尔葛林:BAAALgAECgcJCwAAAA==.',
['纳格']='纳格兰:BAAALgAECgQJBgAAAA==.',
['老一']='老一套:BAAALgAECgUJBQAAAA==.',
['聖鉧']='聖鉧神皇:BAABLgAECn8hAAIMAAgJIQ+eKACsAQAMAAgJIQ+eKACsAQAAAA==.',
['聪聪']='聪聪那年:BAAALgADCgEJAQAAAA==.',
['自愿']='自愿认罪认罚:BAAALgAECgcJBwAAAA==.',
['艾克']='艾克塞琳:BAAALgAECgcJBgAAAA==.',
['苏兹']='苏兹蒂安:BAAALgAECgEJAgAAAA==.',
['苦苦']='苦苦吖:BAAALgAFFAIJAwAAAA==.',
['莉雅']='莉雅德琳:BAEALgAECgUJCgAAAA==.',
['蒂利']='蒂利:BAAALgAECgEJAQAAAA==.',
['蒙哥']='蒙哥丶开摆了:BAAALgAFFAEJAQAAAA==.',
['起飞']='起飞的感觉:BAAALgADCgUJBQAAAA==.',
['路边']='路边小野狗:BAAALgADCgEJAQAAAA==.',
['邪恶']='邪恶之影:BAAALgAECgcJCwAAAA==.',
['都得']='都得有:BAAALgAECgUJBQAAAA==.',
['阿沐']='阿沐子:BAAALgAECgEJAQAAAA==.',
['阿萨']='阿萨斯:BAAALgAECgQJBAAAAA==.',
['阿邦']='阿邦姐:BAAALgAFFAIJBAAAAA==.',
['陆离']='陆离:BAAALgAECgEJAQAAAA==.',
['陶白']='陶白白:BAAALgAECgEJAQAAAA==.',
['雷諾']='雷諾:BAABLgAFFH8IAAINAAMJDAy2DgAFAQANAAMJDAy2DgAFAQAAAA==.',
['静默']='静默时光:BAAALgADCgYJBgAAAA==.',
['鸟飞']='鸟飞走了:BAAALgADCgQJBAABLgAECgYJAQAEAAAAAA==.',
['鸿蒙']='鸿蒙上人:BAAALgAECgEJAQAAAA==.',
['黑色']='黑色心情:BAAALgAECgUJBgAAAA==.',
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
