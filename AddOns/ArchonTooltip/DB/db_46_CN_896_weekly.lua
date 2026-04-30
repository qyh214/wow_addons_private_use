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

local lookup = {'DemonHunter-Devourer','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Elemental','Druid-Balance','Evoker-Augmentation','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Protection','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Monk-Windwalker','Monk-Brewmaster','Warrior-Fury',}
local provider = {region='CN',realm='黑暗之门',name='CN',type='weekly',zone=46,date='2026-04-25',data={De='Deathgirl:BAAALgAECgYJBwAAAA==.',
Fo='Fon:BAAALgADCgEJAQAAAA==.',
Mi='Mingsi:BAAALgAFFAEJAQAAAA==.',
To='Tolo:BAAALgAECgMJAQAAAA==.',
Vz='Vz:BAAALgAECgYJCwAAAA==.',
['一个']='一个夏雨天:BAAALgADCgMJAwAAAA==.',
['一把']='一把钝刀:BAAALgADCgIJAgAAAA==.',
['一支']='一支七匹狼:BAAALgAECgYJBwAAAA==.',
['一根']='一根大前门:BAAALgAECgcJCgAAAA==.',
['万能']='万能的耶耶:BAACLgAFFH8WAAMBAAcJNB69AACvAgABAAcJhhy9AACvAgACAAQJ2x70AQB6AQAuAAQKfykABAEACQlDJVIEAIIDAAEACQlJJFIEAIIDAAIABwnFJYIIANoCAAMAAQkDJPMlAFQAAAAA.',
['丑出']='丑出天际:BAAALgAECgEJAgAAAA==.',
['临时']='临时演员:BAAALgAECgYJDAAAAA==.',
['丶天']='丶天王盖地虎:BAAALgAECgYJDAAAAA==.',
['丸子']='丸子汤:BAAALgAECggJCQAAAA==.',
['伊维']='伊维尔:BAAALgAECgYJCQAAAA==.',
['何弃']='何弃疗:BAABLgAFFH8IAAIEAAQJThjNAwBFAQAEAAQJThjNAwBFAQAAAA==.',
['你买']='你买单我就来:BAABLgAFFH8FAAIFAAUJkQ8yBABIAQAFAAUJkQ8yBABIAQAAAA==.',
['傲天']='傲天小龙人:BAAALgADCgEJAQAAAA==.',
['冰镇']='冰镇丶西瓜汁:BAAALgAECgUJBwAAAA==.',
['凯子']='凯子哥哥:BAAALgAECgQJCQAAAA==.',
['初一']='初一:BAAALgAECgcJBgAAAA==.',
['十一']='十一锟:BAABLgAFFH8HAAIFAAQJPBMVCgBHAQAFAAQJPBMVCgBHAQAAAA==.',
['十锟']='十锟:BAABLgAFFH8JAAIFAAUJmRf1BACbAQAFAAUJmRf1BACbAQAAAA==.',
['卡萝']='卡萝淋:BAAALgAFFAEJAwAAAA==.',
['卡萨']='卡萨丁青春版:BAAALgAECgUJCgAAAA==.',
['原涞']='原涞:BAAALgADCgEJAQAAAA==.',
['只会']='只会卖萌:BAAALgAFFAIJAwAAAA==.',
['圣光']='圣光忽悠着你:BAAALgADCgEJAQAAAA==.',
['在留']='在留言后笛笙:BAAALgAECgcJBwAAAA==.',
['夏季']='夏季八曲丶:BAAALgADCgcJBwAAAA==.',
['多多']='多多快跑:BAAALgAECgEJAQAAAA==.',
['大威']='大威天龙:BAAALgAECgYJDAAAAA==.',
['大法']='大法师维克托:BAAALgAECgYJBgAAAA==.',
['大神']='大神零:BAAALgAECgEJAQAAAA==.',
['孙悟']='孙悟空:BAAALgADCgUJBQAAAA==.',
['孙王']='孙王若潼:BAAALgAECgIJAwAAAA==.',
['宝宝']='宝宝:BAAALgADCgMJAwAAAA==.',
['小小']='小小大王:BAABLgAFFH8FAAIGAAUJQwCWFADQAAAGAAUJQwCWFADQAAAAAA==.',
['小德']='小德行天下:BAAALgAECgYJDAAAAA==.',
['小绿']='小绿巨人儿:BAAALgAFFAQJAgAAAA==.',
['尹利']='尹利丹丶怒風:BAAALgAECgEJAQAAAA==.',
['幽然']='幽然若梦:BAAALgADCgIJAgAAAA==.',
['幽玥']='幽玥:BAAALgAECggJDAAAAA==.',
['心灵']='心灵震撼:BAAALgAFFAIJAgAAAA==.',
['我这']='我这小爆脾气:BAAALgADCgIJAgAAAA==.',
['教官']='教官的第四课:BAABLgAFFH8KAAMHAAUJXB8XAgC+AQAHAAUJchsXAgC+AQAIAAQJ1x2gCwB3AQAAAA==.',
['春风']='春风丶十里:BAAALgAECgEJAQAAAA==.',
['暴走']='暴走丨初号机:BAAALgAFFAQJBAAAAA==.暴走丨初號機:BAAALgAFFAQJBAAAAA==.暴走丶初号机:BAABLgAFFH8NAAIJAAUJdw9SAwBfAQAJAAUJdw9SAwBfAQAAAA==.暴走丶初號機:BAABLgAFFH8IAAIJAAQJSgWsBwDkAAAJAAQJSgWsBwDkAAAAAA==.暴走丿初号机:BAAALgAFFAQJBAAAAA==.暴走初号机:BAABLgAFFH8MAAIJAAQJXQt3AwAQAQAJAAQJXQt3AwAQAQAAAA==.暴走灬初号机:BAABLgAFFH8JAAIJAAUJeQ0MBABDAQAJAAUJeQ0MBABDAQAAAA==.暴走灬初號機:BAABLgAFFH8FAAIJAAUJzwkABgAKAQAJAAUJzwkABgAKAQAAAA==.',
['最后']='最后的大魔王:BAAALgAECgcJDQAAAA==.',
['术友']='术友请留步:BAAALgADCgEJAQAAAA==.',
['朵丶']='朵丶朵:BAAALgAECgYJBwAAAA==.',
['柠檬']='柠檬糖:BAACLgAFFH8OAAMKAAQJgCTkAQCkAQAKAAQJgCTkAQCkAQALAAEJ+iKSAgBmAAAuAAQKfyMABAoABwnTJMlIAPABAAoABQlKI8lIAPABAAwAAwmZIkUkADgBAAsAAgkoHrcYALUAAAAA.',
['柴朔']='柴朔风:BAAALgAECgUJBQAAAA==.',
['栉名']='栉名田眠:BAAALgAECgcJDQAAAA==.',
['梦境']='梦境飘雪:BAAALgAECgEJAQAAAA==.',
['梦晓']='梦晓荷:BAAALgAECgEJAQAAAA==.',
['永恩']='永恩:BAAALgADCgEJAQAAAA==.',
['江鸿']='江鸿:BAAALgAECggJCAAAAA==.',
['流氓']='流氓书生:BAAALgAECgIJAgAAAA==.流氓大块头:BAAALgAECgYJCQAAAA==.流氓小生:BAAALgADCgIJAgAAAA==.',
['浅丷']='浅丷:BAAALgAECgYJBAAAAA==.',
['灵魂']='灵魂之火:BAAALgAECgEJAQAAAA==.',
['烈焰']='烈焰燃心:BAAALgAECgcJBAAAAA==.烈焰魔剑:BAAALgAECgEJAQAAAA==.',
['烟熏']='烟熏罗马:BAAALgAECgUJBQAAAA==.',
['熊猫']='熊猫人阿达:BAABLgAECn8cAAINAAgJ3hSkBQC5AQANAAgJ3hSkBQC5AQAAAA==.',
['牡丹']='牡丹燕菜:BAAALgAFFAIJAgAAAA==.',
['狂拽']='狂拽酷炫炸天:BAAALgAECgEJAQAAAA==.',
['狐大']='狐大力:BAAALgAECgYJDAAAAA==.',
['猪猪']='猪猪公主:BAAALgAFFAQJBAAAAA==.猪猪老爷:BAACLgAFFH8OAAIOAAUJYyIDAgDeAQAOAAUJYyIDAgDeAQAuAAQKfxQAAw4ACQl2Iv8BAIEDAA4ACQkCIv8BAIEDAA0AAQnTIVlqAGUAAAAA.',
['猴子']='猴子偷桃:BAAALgAECgMJAwAAAA==.',
['玛德']='玛德绝了:BAACLgAFFH8GAAIPAAMJDyFfBQAmAQAPAAMJDyFfBQAmAQAuAAQKfx8AAw8ABwnIITAZAIICAA8ABwnIITAZAIICAAkAAQlAGZAWAE8AAAAA.',
['甘尼']='甘尼克斯:BAAALgAECgkJEwAAAA==.',
['疯吖']='疯吖头:BAAALgAECgEJAQAAAA==.',
['祢衡']='祢衡圊狂:BAAALgAECgEJAQAAAA==.',
['米迦']='米迦勒:BAAALgAECgYJBwAAAA==.',
['索拉']='索拉丁:BAABLgAECn8WAAIJAAcJpw+AGwBvAQAJAAcJpw+AGwBvAQAAAA==.',
['绝版']='绝版丸子:BAAALgADCgYJBgAAAA==.',
['老衲']='老衲法号随缘:BAAALgAECgYJBgAAAA==.',
['聴説']='聴説法丝很強:BAAALgAECgYJDAAAAA==.',
['般若']='般若诸佛:BAAALgAECgEJAQAAAA==.',
['花儿']='花儿:BAAALgAECgYJBgAAAA==.',
['苹果']='苹果嘉儿:BAAALgAECgcJCQAAAA==.',
['菲利']='菲利丶克斯:BAAALgAECgYJBgAAAA==.',
['蓝皮']='蓝皮弯腰盗:BAAALgAECgYJCAAAAA==.',
['西斯']='西斯廷神祇:BAAALgAECgYJCQAAAA==.',
['贝莉']='贝莉莎丶焰牙:BAAALgAECgUJCAAAAA==.',
['迪丽']='迪丽热巴丶:BAAALgAECgMJAwAAAA==.',
['逐暗']='逐暗者:BAAALgAECgkJCQAAAA==.',
['酋长']='酋长咆哮:BAAALgAECgYJBwAAAA==.',
['释永']='释永潼:BAAALgAECgQJBgAAAA==.',
['野蠻']='野蠻執行者:BAAALgAFFAIJAwAAAA==.',
['阐释']='阐释者:BAAALgAFFAIJAgAAAA==.',
['阳光']='阳光小母牛:BAAALgAECgYJBgAAAA==.',
['雨天']='雨天琴弦骑士:BAAALgAECgIJAgAAAA==.',
['雪见']='雪见:BAAALgAECgYJDwAAAA==.',
['飞天']='飞天大焯:BAAALgAECgcJCQAAAA==.',
['骑咕']='骑咕咕:BAAALgAECgMJAwAAAA==.',
['魏国']='魏国灬貂蝉:BAAALgAECgEJAQAAAA==.',
['魔瘾']='魔瘾:BAAALgADCgUJBQAAAA==.',
['龙泷']='龙泷隆:BAAALgAECgUJBQAAAA==.',
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
