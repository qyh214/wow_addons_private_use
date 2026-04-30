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

local lookup = {'Mage-Frost','Hunter-Marksmanship','Paladin-Retribution','Warrior-Fury','Warrior-Arms','Unknown-Unknown','Shaman-Restoration','DeathKnight-Unholy','Druid-Restoration','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Hunter-BeastMastery','Priest-Holy','Priest-Discipline','Paladin-Holy','Priest-Shadow','Shaman-Elemental',}
local provider = {region='CN',realm='恐怖图腾',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alita:BAAALgAECgIJAgAAAA==.Alwaysqing:BAAALgAECgMJAwAAAA==.',
Ar='Arolurker:BAAALgAECgMJAwAAAA==.',
Ce='Cezanne:BAAALgAFFAMJAgAAAA==.',
Ha='Harborwlc:BAAALgAECgIJAgAAAA==.',
Li='Liangfs:BAAALgAECgYJDgAAAA==.',
Na='Nazha:BAAALgAECgcJEgAAAA==.',
Nz='Nz:BAAALgAECgEJAQAAAA==.',
Yu='Yuutsu:BAABLgAECn8ZAAIBAAkJ1xrAHwD2AgABAAkJ1xrAHwD2AgAAAA==.',
['上海']='上海一九四三:BAAALgAECgQJCQAAAA==.',
['不存']='不存在嘚存在:BAAALgAECgQJBgAAAA==.',
['专业']='专业切蛋:BAAALgAECgYJCwABLgAFFAUJEQACAOIjAA==.',
['丨娜']='丨娜扎丨:BAABLgAECn8VAAIDAAcJtR7XKQB9AgADAAcJtR7XKQB9AgAAAA==.',
['中意']='中意你丶:BAAALgAECgYJCAAAAA==.',
['丶你']='丶你中噫:BAAALgAFFAIJAgAAAA==.丶你中奕:BAAALgAECgYJCQAAAA==.丶你钟意:BAABLgAFFH8IAAIDAAMJJhf5EwAHAQADAAMJJhf5EwAHAQAAAA==.',
['乄哈']='乄哈妮足乄:BAAALgAECgEJAQAAAA==.',
['以和']='以和为贵丶:BAACLgAFFH8TAAMEAAUJOgfEAwAwAQAEAAUJOgfEAwAwAQAFAAEJAAAzDgAsAAAuAAQKfxoAAwQACAmqE6YuAPYBAAQACAmqE6YuAPYBAAUAAQnPEDU/ADoAAAAA.',
['伍月']='伍月:BAAALgAECgYJCQAAAA==.',
['依城']='依城雪:BAAALgADCgkJCQAAAA==.',
['僧吉']='僧吉士:BAAALgAECgIJAgABLgAFFAEJAgAGAAAAAA==.',
['全部']='全部都得死:BAAALgAECgUJBwAAAA==.',
['冬天']='冬天不冻脚:BAAALgAECgYJCQAAAA==.',
['凤凰']='凤凰栖息梧桐:BAAALgAFFAIJBAAAAA==.',
['单调']='单调:BAAALgADCgUJBQAAAA==.单调丶:BAAALgADCgYJBgAAAA==.',
['又见']='又见喵星人:BAAALgAECgIJAgAAAA==.',
['发如']='发如雪乄:BAAALgAECgIJAgAAAA==.',
['吉祥']='吉祥赶猪棒:BAAALgAECgUJBwAAAA==.',
['吴散']='吴散弹:BAAALgAFFAEJAQAAAA==.',
['咔鮭']='咔鮭咿丨小鳥:BAABLgAFFH8GAAIDAAQJDB+yBQCVAQADAAQJDB+yBQCVAQAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgAECgEJAQAAAA==.',
['哎呀']='哎呀叶子:BAAALgAFFAEJAQAAAA==.',
['喵翠']='喵翠花:BAABLgAFFH8FAAIHAAUJogNNBwBQAQAHAAUJogNNBwBQAQAAAA==.',
['团队']='团队毒瘤:BAAALgAECgUJBgAAAA==.',
['图咔']='图咔:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光炕土豆:BAAALgAECgMJBAAAAA==.',
['坠落']='坠落的猎手:BAAALgAECgMJAwAAAA==.',
['夜夜']='夜夜丿声歌:BAAALgAECgYJDAAAAA==.',
['大手']='大手子:BAABLgAFFH8OAAIIAAQJAiABDAB1AQAIAAQJAiABDAB1AQAAAA==.',
['大耳']='大耳朵图图:BAAALgAECgMJBAAAAA==.',
['天涯']='天涯风:BAAALgAECgEJAQAAAA==.',
['天灾']='天灾风起云涌:BAAALgAFFAcJBAAAAA==.',
['失真']='失真:BAAALgADCgEJAQAAAA==.',
['奔放']='奔放的小伙子:BAAALgAECgYJBwAAAA==.',
['奥瑞']='奥瑞克:BAAALgAECgIJAwAAAA==.',
['奥魂']='奥魂神奥魂:BAAALgAECgQJBgAAAA==.',
['好可']='好可爱啊:BAAALgAECgEJAQAAAA==.',
['妖精']='妖精美色:BAAALgAFFAIJBAAAAA==.',
['孜然']='孜然之力:BAABLgAFFH8QAAIJAAQJGBwkBwBiAQAJAAQJGBwkBwBiAQAAAA==.',
['寂寞']='寂寞陪着寂寞:BAAALgADCgUJBQAAAA==.',
['导演']='导演我想火:BAAALgAECgEJAQAAAA==.',
['小丘']='小丘:BAAALgAECgcJBwAAAA==.',
['小娜']='小娜娜:BAAALgADCgUJBQAAAA==.',
['小浣']='小浣熊丶:BAABLgAFFH8JAAIJAAQJAQwuEgDYAAAJAAQJAQwuEgDYAAAAAA==.',
['幽径']='幽径独行迷:BAAALgAFFAIJAgAAAA==.',
['彤彤']='彤彤:BAAALgADCgQJBAAAAA==.彤彤的小德:BAAALgAECgMJAwAAAA==.',
['恐怖']='恐怖钟馗:BAAALgAECgMJAwAAAA==.',
['慕希']='慕希妞:BAAALgAECgIJAgAAAA==.',
['我要']='我要飞的更高:BAACLgAFFH8FAAIKAAMJyxZ5DQAGAQAKAAMJyxZ5DQAGAQAuAAQKfxQABAoABwmnIl0UAAACAAoABwmnIl0UAAACAAsAAgm8DZgxAIkAAAwAAQkgCmxhADYAAAAA.',
['戛爽']='戛爽:BAAALgAECgQJBAAAAA==.',
['摇摇']='摇摇晃摇:BAAALgAFFAEJAgAAAA==.',
['斩杀']='斩杀骑士:BAAALgAECgMJBAAAAA==.',
['无限']='无限挑战:BAAALgADCgEJAQAAAA==.',
['晓肥']='晓肥肥:BAAALgADCgYJBgAAAA==.',
['本波']='本波儿灞:BAAALgAFFAMJAwAAAA==.',
['机车']='机车男孩小夏:BAABLgAFFH8JAAIIAAQJeiSuBAC2AQAIAAQJeiSuBAC2AQABLgAFFAYJFAAIAAslAA==.',
['松下']='松下裤带:BAAALgAECgcJEQAAAA==.',
['梧桐']='梧桐御风:BAAALgAECgMJBAAAAA==.',
['死亡']='死亡大哥哥:BAAALgAECgEJAQAAAA==.',
['毒甜']='毒甜心:BAAALgAECgUJBQAAAA==.',
['江海']='江海寄余生:BAAALgAECgMJBQAAAA==.',
['河北']='河北一彩花:BAAALgADCgUJBQAAAA==.',
['流月']='流月苍岚:BAAALgAFFAQJBAAAAA==.',
['浅殇']='浅殇止水:BAABLgAFFH8FAAMCAAUJdhLYEgAOAQACAAMJ2BbYEgAOAQANAAIJFA58GQChAAAAAA==.',
['温言']='温言予时光:BAAALgAECgQJBAAAAA==.',
['潇洒']='潇洒狂刀:BAACLgAFFH8GAAIIAAMJMgssLgDhAAAIAAMJMgssLgDhAAAuAAQKfxUAAggACAkRFIRVAPEBAAgACAkRFIRVAPEBAAAA.潇洒黑锋骑:BAAALgADCgQJBAAAAA==.',
['灬卡']='灬卡特琳娜灬:BAAALgADCgMJAwAAAA==.',
['牛德']='牛德滑:BAAALgAECgEJAgAAAA==.',
['犇弹']='犇弹:BAAALgAFFAEJAQAAAA==.',
['狂牛']='狂牛莫问:BAAALgAECgYJDAAAAA==.',
['玩好']='玩好猎仁:BAAALgAECgYJCAAAAA==.',
['瑛瑶']='瑛瑶其质:BAAALgAECgEJAQAAAA==.',
['璃沫']='璃沫寧夏:BAAALgAECgUJCAAAAA==.',
['生鱼']='生鱼:BAAALgAFFAMJAwAAAA==.',
['破风']='破风之骑:BAAALgAECgIJAgAAAA==.',
['科罗']='科罗娜:BAAALgAECgMJAwAAAA==.',
['筋钢']='筋钢大:BAAALgAECgcJCAAAAA==.',
['箭多']='箭多识广:BAAALgAECgIJAgAAAA==.',
['紫龙']='紫龙:BAAALgAECggJBwAAAA==.',
['终极']='终极老萨:BAAALgAFFAEJAgAAAA==.',
['自然']='自然的叹息:BAAALgAECgEJAQAAAA==.',
['苍之']='苍之怒:BAAALgAECgYJBwAAAA==.',
['苍络']='苍络灵馨:BAAALgAECgMJBgAAAA==.',
['若葉']='若葉牧:BAABLgAECn8VAAMOAAcJohf6JADBAQAOAAcJeRT6JADBAQAPAAcJuxO0IACOAQABLgAFFAUJCQAOAHomAA==.',
['茨木']='茨木童子:BAAALgAECgMJAwAAAA==.',
['萌之']='萌之麻友友:BAAALgAFFAIJBAAAAA==.',
['萧萧']='萧萧瑟瑟:BAAALgAECgYJCgAAAA==.',
['蒙面']='蒙面咖啡猫:BAAALgAECgQJBQAAAA==.',
['蛋黄']='蛋黄派派:BAAALgAECgEJAQAAAA==.',
['蜃楼']='蜃楼:BAAALgADCgQJBAAAAA==.',
['血圣']='血圣天使:BAAALgAFFAIJBAAAAA==.',
['触手']='触手可及:BAAALgAECgkJDgABLgAFFAcJBwAQADwVAA==.',
['让爷']='让爷射一个:BAAALgAECgEJAQAAAA==.',
['赤道']='赤道以北:BAAALgAECgIJAgAAAA==.',
['起床']='起床吃饭呢:BAAALgADCgcJBwAAAA==.',
['酱油']='酱油:BAAALgAECgUJBwAAAA==.',
['钟意']='钟意你丶:BAABLgAECn8WAAIEAAYJvB5SKAAcAgAEAAYJvB5SKAAcAgAAAA==.',
['钥匙']='钥匙:BAAALgAECgEJAQAAAA==.',
['门板']='门板糊脸:BAAALgAECgYJDQAAAA==.',
['阔少']='阔少爷:BAAALgAFFAIJAwAAAA==.',
['阿哒']='阿哒:BAAALgAECgEJAQAAAA==.',
['隐居']='隐居江湖:BAAALgADCgEJAQAAAA==.',
['雨田']='雨田木羽:BAAALgADCgcJBwAAAA==.',
['雪子']='雪子奶白:BAAALgAECgYJBgAAAA==.',
['霜雨']='霜雨琪月:BAAALgAECgYJBwAAAA==.',
['风吟']='风吟一舞:BAAALgADCgUJBQAAAA==.',
['风雨']='风雨雷电:BAAALgAECgIJAQAAAA==.',
['馒头']='馒头馅:BAAALgAFFAIJAgAAAA==.',
['魅影']='魅影阑珊:BAAALgAECgUJBgAAAA==.',
['魔法']='魔法掌控:BAAALgAECgIJAwAAAA==.',
['鳥鳥']='鳥鳥丶:BAABLgAFFH8OAAIRAAQJaCOuAACaAQARAAQJaCOuAACaAQAAAA==.',
['鳩摩']='鳩摩智:BAAALgAECgEJAQAAAA==.',
['鳳凰']='鳳凰:BAAALgAECgYJDAAAAA==.',
['黑旋']='黑旋风李李逵:BAAALgAECgYJBgAAAA==.',
['龟龟']='龟龟大貔貅:BAABLgAFFH8GAAIJAAQJKAjQEwDKAAAJAAQJKAjQEwDKAAAAAA==.龟龟枪下鬼:BAABLgAFFH8FAAIIAAIJzhNHOQCpAAAIAAIJzhNHOQCpAAAAAA==.龟龟隆地动:BAABLgAFFH8FAAISAAIJwxIiFQCmAAASAAIJwxIiFQCmAAAAAA==.',
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
