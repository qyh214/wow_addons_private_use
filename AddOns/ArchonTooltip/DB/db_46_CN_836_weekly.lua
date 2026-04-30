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

local lookup = {'Mage-Frost','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','Unknown-Unknown','Monk-Brewmaster','Monk-Mistweaver','Paladin-Retribution','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Shaman-Restoration',}
local provider = {region='CN',realm='达基萨斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Blueman:BAAALgAECgEJAQAAAA==.',
Br='Bro:BAAALgAFFAMJAwAAAA==.',
Ch='Christie:BAAALgADCgQJBAAAAA==.',
Ev='Evaivy:BAAALgAECgUJBQAAAA==.',
Ho='Horry:BAAALgAECgIJAgAAAA==.',
Pr='Prometheus:BAABLgAECn8XAAIBAAcJlhb5hgDEAQABAAcJlhb5hgDEAQAAAA==.',
Sa='Saberl:BAAALgAECgkJBgAAAA==.',
Sm='Smalln:BAABLgAFFH8GAAMCAAQJeAGiDwDnAAACAAQJeAGiDwDnAAADAAIJcwjkHQCFAAAAAA==.',
Zo='Zoltraak:BAACLgAFFH8TAAIBAAYJJyFBAgBtAgABAAYJJyFBAgBtAgAuAAQKfx8AAgEACAkiJvkQAEIDAAEACAkiJvkQAEIDAAAA.',
['一周']='一周七日:BAAALgAECgEJAQAAAA==.',
['三缺']='三缺一:BAAALgAECgcJBwAAAA==.',
['专属']='专属奶妈:BAAALgADCgEJAQAAAA==.',
['丨丶']='丨丶闪耀:BAAALgAFFAIJAgAAAA==.',
['丷缱']='丷缱绻丷:BAACLgAFFH8JAAIEAAMJxhuRIAAXAQAEAAMJxhuRIAAXAQAuAAQKfxUAAgQACAlHGJ9KABMCAAQACAlHGJ9KABMCAAAA.',
['久久']='久久回味:BAAALgADCgMJAwAAAA==.',
['乔汉']='乔汉娜的辩护:BAAALgAECgQJBQAAAA==.',
['以杀']='以杀止戈熊:BAAALgAFFAIJAwAAAA==.',
['会丶']='会丶长:BAAALgADCgEJAQAAAA==.',
['伯约']='伯约:BAAALgADCgQJAwAAAA==.',
['卡特']='卡特琳娜丶:BAAALgAECgYJCAAAAA==.',
['卿卿']='卿卿:BAAALgAECgUJBQAAAA==.',
['后来']='后来的夏天:BAAALgAECgcJAgAAAA==.',
['咆哮']='咆哮:BAAALgAECgYJBgAAAA==.',
['哈基']='哈基咪灬曼波:BAAALgAECgEJAQAAAA==.哈基咪灬秀念:BAAALgADCgUJBQAAAA==.',
['哈比']='哈比:BAAALgAFFAIJBAAAAA==.',
['哟啊']='哟啊表提佛:BAAALgAFFAEJAQAAAA==.',
['唔西']='唔西迪西:BAAALgAFFAEJAQAAAA==.',
['回不']='回不去的曾经:BAAALgADCgUJBQAAAA==.',
['圣剑']='圣剑修罗:BAAALgAECgcJCgAAAA==.',
['堕落']='堕落天使:BAAALgAECgYJBwAAAA==.',
['夏日']='夏日麽么茶:BAAALgAFFAEJAwAAAA==.',
['大富']='大富:BAAALgADCgEJAQAAAA==.',
['天上']='天上一头牛:BAAALgAECgQJBAAAAA==.',
['姑蘇']='姑蘇圣:BAAALgAECgQJBwAAAA==.',
['小十']='小十一:BAAALgAECgEJAQAAAA==.小十五:BAAALgADCgcJBwAAAA==.小十六:BAAALgAECgYJBgAAAA==.小十四:BAAALgAFFAMJAwAAAA==.',
['小白']='小白同学:BAAALgAECgEJAQAAAA==.',
['尐灰']='尐灰灰:BAAALgAECgEJAwAAAA==.',
['岁月']='岁月:BAAALgAECgMJAwAAAA==.',
['左手']='左手拔刀:BAAALgADCgUJBQAAAA==.',
['幽冥']='幽冥肖雨萧:BAAALgADCgEJAQAAAA==.',
['床底']='床底下的老王:BAAALgAFFAIJAwAAAA==.床底下老王:BAAALgAECgQJBAAAAA==.',
['心生']='心生六乂:BAAALgAFFAIJAwAAAA==.',
['怼怼']='怼怼丶:BAAALgADCgcJCQAAAA==.怼怼丶丶:BAAALgAECgQJBQAAAA==.',
['拿破']='拿破剑:BAAALgAFFAEJAQAAAA==.',
['摆烂']='摆烂小羊丶:BAAALgAECgIJAgAAAA==.',
['是怼']='是怼怼呀丶:BAAALgAECgIJAgAAAA==.',
['李哥']='李哥爱鲍哥:BAAALgADCgEJAQABLgAECgEJAgAFAAAAAA==.',
['根本']='根本气宇轩昂:BAAALgAECgYJDQAAAA==.',
['汉尼']='汉尼拔:BAAALgAECgQJBQAAAA==.',
['清楼']='清楼名艺:BAAALgAECgkJEAAAAA==.',
['漏水']='漏水漏电:BAAALgAECgQJBAAAAA==.',
['烟火']='烟火的季节:BAAALgAECgUJBwAAAA==.',
['牛逼']='牛逼轰轰:BAAALgAECgIJAQAAAA==.',
['猜对']='猜对了:BAAALgADCgcJBwAAAA==.',
['琴月']='琴月阴:BAAALgAECgYJCAAAAA==.',
['疏影']='疏影横斜:BAAALgAECgMJBAAAAA==.',
['疾如']='疾如风:BAAALgAECgcJBwAAAA==.',
['的帝']='的帝德:BAABLgAECn8UAAMDAAgJgB80DADdAgADAAgJgB80DADdAgACAAUJaAebWgC4AAABLgAECgkJFAADAC8kAA==.',
['砮皂']='砮皂退休外包:BAABLgAECn8ZAAIGAAgJ8RJNJADgAQAGAAgJ8RJNJADgAQAAAA==.',
['神仙']='神仙也枉然:BAAALgADCgEJAQAAAA==.',
['神狸']='神狸大侠:BAABLgAECn8eAAIHAAgJ+RVnBgDYAQAHAAgJ+RVnBgDYAQAAAA==.',
['祭一']='祭一一四一三:BAAALgAECgEJAQAAAA==.',
['糖糖']='糖糖的奶茶:BAAALgAFFAEJAQABLgAECgYJGAAIAP8gAA==.',
['纪幕']='纪幕:BAAALgADCgEJAgAAAA==.',
['老伙']='老伙计:BAAALgAECgYJCwAAAA==.',
['老徳']='老徳:BAAALgAECgEJAgAAAA==.',
['腐朽']='腐朽者:BAAALgAFFAIJAwAAAA==.',
['艾娜']='艾娜夜歌:BAAALgAECgkJCQAAAA==.',
['花火']='花火灬灬:BAAALgAECgkJCQAAAA==.',
['英雄']='英雄:BAAALgAECgkJCQAAAA==.',
['草莓']='草莓蛋糕:BAABLgAECn8VAAQJAAYJYhxXFwDdAQAJAAYJYhxXFwDdAQAKAAIJ2RboMwB0AAALAAEJAABfVwBjAAAAAA==.',
['莫奈']='莫奈安:BAAALgAECgQJBAAAAA==.',
['菠萝']='菠萝披萨:BAAALgAECgIJAgAAAA==.菠萝蜜术:BAAALgAECgEJAQAAAA==.',
['萨拉']='萨拉斯冰皇:BAAALgADCgUJBQAAAA==.',
['薄晓']='薄晓:BAAALgAECgEJAQAAAA==.',
['血冰']='血冰凌:BAAALgAECgMJAwAAAA==.',
['读经']='读经新云:BAAALgAECgQJBAAAAA==.',
['贾柱']='贾柱睾:BAABLgAFFH8JAAIMAAQJ8RMXDAAYAQAMAAQJ8RMXDAAYAQAAAA==.',
['踏风']='踏风岚:BAAALgAECgIJAgAAAA==.',
['踩女']='踩女孩的蘑菇:BAAALgAECgEJAQAAAA==.',
['辉耀']='辉耀:BAAALgAECgUJBgAAAA==.',
['迪捷']='迪捷尔:BAAALgAECgYJBgAAAA==.',
['郦雨']='郦雨婷小钢牙:BAAALgAFFAIJAgAAAA==.',
['酒后']='酒后颠佬丶:BAAALgAFFAEJAQAAAA==.',
['醉裏']='醉裏挑燈看劍:BAAALgAECgIJAgAAAA==.',
['阳光']='阳光一兜兜:BAAALgAECgUJCAAAAA==.',
['阿古']='阿古斯星魂:BAAALgAECgYJBwAAAA==.',
['风暴']='风暴大酋长:BAAALgADCgQJBAAAAA==.',
['风神']='风神骑士:BAAALgADCgUJBQAAAA==.',
['骄傲']='骄傲的黄瓜:BAAALgADCgUJBQAAAA==.',
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
