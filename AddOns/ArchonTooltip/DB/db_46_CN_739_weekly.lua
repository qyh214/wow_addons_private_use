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

local lookup = {'Evoker-Augmentation','Druid-Balance','Druid-Guardian','DeathKnight-Unholy','Shaman-Restoration','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','DemonHunter-Devourer','Warlock-Affliction','Mage-Frost','Priest-Shadow','Paladin-Retribution','DeathKnight-Blood','Monk-Mistweaver','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival',}
local provider = {region='CN',realm='激流堡',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akagavin:BAAALgAECgYJCQAAAA==.',
Al='Alien:BAAALgADCgYJBgAAAA==.',
At='Atopes:BAAALgADCgcJBwAAAA==.',
Bo='Bobbynopeace:BAABLgAFFH8KAAIBAAYJrhx2AwDrAQABAAYJrhx2AwDrAQAAAA==.',
Co='Cover:BAAALgAECgcJCQAAAA==.',
Li='Living:BAABLgAECn8mAAMCAAgJdhqaFABtAgACAAgJdhqaFABtAgADAAQJKAsaJQB0AAAAAA==.',
Lo='Lovelesslisa:BAAALgAECgUJCAAAAA==.',
Pl='Playeruxjmte:BAAALgAECgEJAQAAAA==.',
So='Soulbreaker:BAAALgAECgEJAQAAAA==.',
Xt='Xtang:BAAALgADCgQJBAAAAA==.',
Xx='Xxs:BAAALgAECgYJCwAAAA==.',
['一之']='一之濑千鹤:BAAALgADCgMJAwAAAA==.',
['一劣']='一劣人一:BAAALgAECgIJAgAAAA==.',
['一叶']='一叶南生:BAAALgAECgMJAwAAAA==.',
['一老']='一老登一:BAAALgADCgEJAQAAAA==.',
['上去']='上去梆梆两拳:BAAALgAECgMJAwAAAA==.',
['不可']='不可斗量:BAAALgADCgYJBgAAAA==.',
['不老']='不老邪神:BAAALgADCgIJAgAAAA==.',
['东咚']='东咚咚:BAAALgAFFAEJAQAAAA==.',
['丶北']='丶北极丨德:BAAALgAECgYJCQAAAA==.丶北极丨法:BAAALgAECgYJBgAAAA==.丶北极丨牧:BAAALgAECgYJCgAAAA==.',
['丶红']='丶红烧排骨:BAAALgAECgYJDAAAAA==.',
['乖宝']='乖宝宝小语:BAAALgAECgYJBgAAAA==.',
['于很']='于很横狗蛋:BAAALgAECgYJDwAAAA==.',
['你还']='你还怕大雨吗:BAABLgAFFH8KAAIEAAQJuh3+EgBWAQAEAAQJuh3+EgBWAQAAAA==.',
['光年']='光年:BAAALgADCgMJAwAAAA==.',
['冰霜']='冰霜之心:BAABLgAFFH8MAAIEAAQJnST1AQCUAQAEAAQJnST1AQCUAQAAAA==.',
['切勿']='切勿水中捞月:BAAALgAECgUJBQAAAA==.',
['勇者']='勇者斗恶龙:BAAALgAECgEJAQAAAA==.',
['卡德']='卡德汪:BAAALgADCgEJAQAAAA==.',
['卷心']='卷心菜:BAAALgAECgIJAgAAAA==.',
['吉星']='吉星高照:BAAALgAECgYJEQAAAA==.',
['咻咻']='咻咻:BAAALgAECgEJAgAAAA==.',
['圣骑']='圣骑骑士:BAAALgAECgUJBQAAAA==.',
['夏茉']='夏茉秋初:BAAALgAECgcJDAAAAA==.',
['大叔']='大叔的庇佑:BAAALgADCgEJAQAAAA==.',
['大头']='大头杨杨:BAAALgAECgYJBwAAAA==.',
['太萌']='太萌被肘击:BAAALgADCgUJBQAAAA==.',
['妍花']='妍花伊冷:BAAALgAECgMJAwAAAA==.',
['威猛']='威猛五爷:BAAALgAECgQJBAAAAA==.',
['宫园']='宫园丶薰:BAAALgAECgEJAQAAAA==.',
['寂灭']='寂灭邪罗:BAAALgAECgEJAQAAAA==.',
['小峻']='小峻峻:BAABLgAFFH8GAAIFAAQJ2ws6FQCvAAAFAAQJ2ws6FQCvAAAAAA==.',
['小鸡']='小鸡:BAAALgAFFAIJBAAAAA==.',
['巴特']='巴特:BAAALgAECgkJEwAAAA==.',
['希斯']='希斯特莉亚:BAAALgAECgEJAQAAAA==.',
['彡彡']='彡彡夭:BAAALgAFFAIJAgAAAA==.',
['徐夕']='徐夕瑶:BAAALgAECgcJEQAAAA==.',
['德才']='德才兼备:BAAALgAECgIJAgAAAA==.',
['德拉']='德拉罗萨:BAAALgAECgUJBgAAAA==.',
['志村']='志村新二君:BAAALgAECgEJAQAAAA==.',
['悟空']='悟空:BAAALgADCgEJAQAAAA==.',
['惠山']='惠山阿喜:BAAALgADCgEJAQAAAA==.',
['撼地']='撼地者:BAABLgAECn8mAAIFAAgJrxJANgCqAQAFAAgJrxJANgCqAQAAAA==.',
['日月']='日月同辉:BAAALgAECgYJCgAAAA==.',
['明夜']='明夜:BAAALgAECgYJBgAAAA==.',
['明意']='明意:BAAALgAECgYJDAAAAA==.',
['明猎']='明猎:BAAALgAFFAQJBAAAAA==.',
['明逸']='明逸:BAAALgAECgkJCwAAAA==.',
['明雨']='明雨:BAAALgAECgkJAgAAAA==.',
['星爺']='星爺:BAAALgAECgQJBAAAAA==.',
['時丶']='時丶雨:BAABLgAFFH8MAAIGAAQJIxtpAABRAQAGAAQJIxtpAABRAQAAAA==.',
['最近']='最近的点:BAAALgAECgUJCQAAAA==.',
['松岛']='松岛菜菜鸟:BAAALgAECgYJBgAAAA==.',
['林宛']='林宛瑜:BAACLgAFFH8FAAIHAAMJch8UCgAnAQAHAAMJch8UCgAnAQAuAAQKfxQAAwgABwlJGjYMAP8BAAgABwkBGDYMAP8BAAcABgmPDXKbACIBAAAA.',
['枫之']='枫之舞:BAAALgAECgYJBQAAAA==.',
['桃之']='桃之夭夭:BAAALgAECgEJAgAAAA==.',
['概率']='概率牧:BAAALgAFFAMJAwAAAA==.',
['比赛']='比赛进不去:BAAALgAECgIJAgAAAA==.',
['永朱']='永朱波波子:BAAALgAECgcJDQABLgAFFAQJCAAJADAZAA==.',
['汉堡']='汉堡王:BAAALgADCgEJAgAAAA==.',
['沙奈']='沙奈朵:BAAALgAECgcJBwAAAA==.',
['滋电']='滋电之友友:BAAALgAFFAEJAgAAAA==.',
['炽天']='炽天使炎:BAAALgAECgQJBAAAAA==.',
['烤土']='烤土豆:BAAALgAECgQJBAAAAA==.',
['烤牛']='烤牛:BAAALgAECgUJBQAAAA==.',
['烤生']='烤生蚝:BAAALgAECgEJAQAAAA==.',
['牧渊']='牧渊:BAAALgAECgYJBgAAAA==.',
['狡诈']='狡诈的部落猪:BAABLgAECn8gAAQKAAgJbiN2BgD0AQAKAAUJXSJ2BgD0AQAHAAQJkhy7pQANAQAIAAMJ7xxULwD+AAAAAA==.',
['皇旸']='皇旸惊霆:BAAALgAECgYJBgAAAA==.',
['秘法']='秘法缘缘:BAAALgAECgYJCQAAAA==.',
['童话']='童话小诗:BAAALgAECgMJAwAAAA==.',
['筱雪']='筱雪精灵:BAAALgAECgEJAQAAAA==.',
['紫狐']='紫狐狸:BAAALgAECgUJBQAAAA==.',
['美丽']='美丽不冻人:BAAALgAECgYJBwAAAA==.',
['老蚂']='老蚂蚁:BAAALgADCgEJAQAAAA==.',
['艾小']='艾小雪:BAAALgAECgcJBwAAAA==.',
['艾斯']='艾斯卡诺:BAACLgAFFH8NAAIEAAUJrRkpBAC+AQAEAAUJrRkpBAC+AQAuAAQKfxoAAgQACAmzILEXAO0CAAQACAmzILEXAO0CAAAA.',
['艾瑞']='艾瑞柯:BAAALgAECgkJBwAAAA==.',
['花豆']='花豆神月大人:BAAALgAFFAIJAgAAAA==.',
['苏荨']='苏荨:BAAALgAFFAEJAQAAAA==.',
['苏醒']='苏醒:BAACLgAFFH8LAAILAAQJ5RPpEwD1AAALAAQJ5RPpEwD1AAAuAAQKfx8AAgsACAnaHTAoANICAAsACAnaHTAoANICAAAA.',
['茧茧']='茧茧:BAAALgAECgQJAwAAAA==.',
['茫然']='茫然骑士:BAAALgADCgEJAQAAAA==.',
['莉莉']='莉莉娅:BAAALgADCgMJAwAAAA==.',
['萝卜']='萝卜青菜:BAAALgAECgYJBgAAAA==.',
['萨滿']='萨滿祭司:BAAALgAECggJBgAAAA==.',
['蝶之']='蝶之影:BAABLgAECn8hAAIMAAgJKBipEwBWAgAMAAgJKBipEwBWAgAAAA==.',
['起手']='起手就无敌:BAABLgAFFH8IAAINAAMJ3BppFAAFAQANAAMJ3BppFAAFAQAAAA==.',
['轩轩']='轩轩呀:BAABLgAFFH8FAAIOAAUJ0A6xBQBBAQAOAAUJ0A6xBQBBAQAAAA==.',
['邪神']='邪神:BAAALgAECgMJBAAAAA==.',
['金刚']='金刚狼丶旺财:BAAALgADCgEJAQAAAA==.',
['阴霾']='阴霾暗霜:BAAALgAECgYJBgAAAA==.',
['阿奇']='阿奇:BAAALgAFFAEJAQAAAA==.',
['青丨']='青丨火:BAACLgAFFH8XAAIPAAYJfxxHAQA2AgAPAAYJfxxHAQA2AgAuAAQKfxsAAg8ACAmIIQUHAOwCAA8ACAmIIQUHAOwCAAAA.',
['青菜']='青菜萝卜:BAAALgAECgcJEQAAAA==.',
['顽山']='顽山:BAAALgAECgQJBAAAAA==.',
['顽弓']='顽弓:BAAALgAECgMJAwAAAA==.',
['顽林']='顽林:BAABLgAECn8XAAMQAAkJjBWOSwCGAQAQAAUJpxSOSwCGAQARAAQJChcPVgDwAAAAAA==.',
['顽浮']='顽浮:BAAALgAECgkJBgAAAA==.',
['顽火']='顽火:BAAALgAECgUJBQAAAA==.',
['顽蛇']='顽蛇:BAAALgAECgYJBgAAAA==.',
['顽风']='顽风:BAAALgAECgEJAQAAAA==.',
['风寂']='风寂寞雨逍遥:BAAALgAECgEJAQAAAA==.',
['风御']='风御者:BAAALgAECgQJBAAAAA==.',
['飒双']='飒双鱼:BAAALgAECgcJAgAAAA==.',
['魂守']='魂守之矢:BAABLgAECn8ZAAQQAAgJOBxaKAAWAgAQAAcJ3hxaKAAWAgARAAUJfxzKNwCEAQASAAIJkRGpJwB6AAAAAA==.',
['魅影']='魅影贫血骑士:BAAALgADCgEJAQAAAA==.',
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
