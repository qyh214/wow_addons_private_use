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

local lookup = {'Paladin-Holy','Warrior-Arms','Warrior-Protection','Warrior-Fury','Warlock-Demonology','Warlock-Affliction','Priest-Discipline','Mage-Frost',}
local provider = {region='CN',realm='迦顿',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Bluenile:BAAALgAECgUJBQAAAA==.',
Pl='Playerinwtpe:BAAALgADCgMJAwAAAA==.',
['三笠']='三笠酱:BAAALgAECgEJAQAAAA==.',
['不朽']='不朽的牙:BAAALgAECgcJEwAAAA==.',
['乔尼']='乔尼娜丶尼奥:BAAALgAECgQJBAAAAA==.',
['九霞']='九霞觞:BAAALgAECgEJAwAAAA==.',
['云诗']='云诗顿:BAAALgADCgEJAQAAAA==.',
['仙蒂']='仙蒂瑞拉灬:BAAALgADCgQJBAAAAA==.',
['伊萌']='伊萌萌:BAAALgAECgQJBAAAAA==.',
['信仰']='信仰灬圣光:BAAALgADCgkJCQAAAA==.',
['倒头']='倒头就睡:BAAALgAECgEJAQAAAA==.',
['傻插']='傻插晖晖:BAAALgAECgQJBAAAAA==.',
['克洛']='克洛斯战:BAAALgADCgEJAQAAAA==.',
['其实']='其实牙不长:BAAALgAECgYJBgAAAA==.',
['军团']='军团再临:BAAALgAECgQJBAAAAA==.',
['北岸']='北岸夏殇丿:BAAALgAECgQJBQAAAA==.',
['十三']='十三叔:BAAALgAECgQJBAAAAA==.十三骑士:BAAALgAECgYJDgAAAA==.',
['十月']='十月誓约:BAAALgADCgIJAgAAAA==.',
['哈牛']='哈牛魔:BAAALgADCgEJAQAAAA==.',
['嘤嘤']='嘤嘤怪是宝贝:BAAALgADCgEJAQAAAA==.',
['四个']='四个幺鸡:BAAALgADCgUJBQAAAA==.',
['圣堂']='圣堂之金色:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱修罗王:BAAALgAECgYJEAAAAA==.',
['墨子']='墨子丶:BAAALgAECgUJCAAAAA==.',
['墨寒']='墨寒:BAAALgAECgMJAwAAAA==.',
['夕阳']='夕阳下的奔跑:BAAALgAECgEJAgAAAA==.',
['夜月']='夜月贼殇:BAAALgADCgQJBAAAAA==.',
['大滋']='大滋花:BAAALgAECgEJAQAAAA==.',
['天灾']='天灾男爵:BAAALgADCgUJBQAAAA==.',
['天皓']='天皓:BAABLgAECn8UAAIBAAcJ5BYmKgDhAQABAAcJ5BYmKgDhAQAAAA==.',
['如歌']='如歌:BAAALgAECgcJEAAAAA==.',
['妖精']='妖精怀怀:BAAALgAECgUJCwAAAA==.',
['婉婉']='婉婉:BAAALgAECgYJDgAAAA==.',
['嫂子']='嫂子开门:BAAALgAECgYJDgAAAA==.',
['孤独']='孤独的根三:BAAALgAECgUJBQAAAA==.',
['宝马']='宝马的珐师:BAAALgADCgEJAQAAAA==.',
['宠爱']='宠爱:BAAALgADCgEJAQAAAA==.',
['小胖']='小胖甜暖:BAAALgAECgEJAQAAAA==.',
['小轩']='小轩:BAAALgAECgUJBQAAAA==.',
['小银']='小银仙归来:BAAALgAECgYJEgAAAA==.小银僧:BAAALgAECgYJBQAAAA==.',
['左眼']='左眼跳瞎:BAAALgAECgkJCgAAAA==.',
['巫旒']='巫旒歆:BAAALgAECgQJBQAAAA==.',
['帕秋']='帕秋莉:BAAALgADCgEJAQAAAA==.',
['开宝']='开宝马来接你:BAAALgAECgYJDQAAAA==.',
['我不']='我不帮她谁帮:BAAALgAECgMJAwAAAA==.',
['折叶']='折叶笼花:BAAALgAECgEJAQAAAA==.',
['指尖']='指尖戏人生:BAAALgAFFAEJAQAAAA==.',
['摩摩']='摩摩桑:BAAALgAECgMJAwAAAA==.',
['教黄']='教黄爷爷:BAAALgAECgUJCAAAAA==.',
['敬畏']='敬畏丨幽魂:BAAALgAECgEJAQAAAA==.',
['无鸡']='无鸡之谈:BAAALgAECgUJAwAAAA==.',
['明月']='明月凄风:BAAALgAFFAIJBAAAAA==.',
['明老']='明老湿:BAAALgAECgEJAQAAAA==.',
['星月']='星月火舞:BAAALgAECgYJDwAAAA==.',
['晓风']='晓风残月:BAAALgAFFAEJAQAAAA==.',
['智商']='智商已暴露:BAABLgAECn8UAAQCAAgJKgnmAwCTAQACAAgJeQjmAwCTAQADAAUJBQmrLgDNAAAEAAEJAABxsAAqAAAAAA==.',
['暮椋']='暮椋:BAACLgAFFH8KAAIFAAMJiBC4EgD/AAAFAAMJiBC4EgD/AAAuAAQKfygAAwUACAmnHVAiAIwCAAUACAnMHFAiAIwCAAYAAgmfJQoYALsAAAAA.',
['杨子']='杨子二:BAAALgAFFAIJBAABLgAFFAQJDgAHAHQjAA==.',
['梦幻']='梦幻水果刀:BAAALgAECgYJBgAAAA==.',
['毛毛']='毛毛大魔王:BAAALgAECgYJCAAAAA==.',
['法力']='法力残渣:BAABLgAECn8aAAIIAAgJuhJncADzAQAIAAgJuhJncADzAQAAAA==.',
['波妞']='波妞:BAAALgAECggJCwAAAA==.',
['涅法']='涅法蕾姆:BAAALgAECgEJAgAAAA==.',
['漂泊']='漂泊如风:BAAALgAECgYJCwAAAA==.',
['牵着']='牵着小手:BAAALgADCgEJAQAAAA==.',
['猎魂']='猎魂残影:BAAALgAECgEJAgAAAA==.',
['珂蕊']='珂蕊:BAAALgAECgYJDgAAAA==.',
['瑟蒂']='瑟蒂:BAAALgAECgUJBAAAAA==.',
['瑪耶']='瑪耶丶浩厄:BAAALgADCgUJBQAAAA==.',
['生前']='生前比较酷:BAAALgAECgYJBwAAAA==.生前非常帅:BAAALgAECgEJAQAAAA==.',
['电糖']='电糖:BAAALgAECgIJAgAAAA==.',
['疯狂']='疯狂糕糕狗:BAAALgADCgEJAQAAAA==.',
['目标']='目标不可选定:BAAALgADCgEJAQAAAA==.',
['破山']='破山:BAAALgAECgEJAQAAAA==.',
['粗面']='粗面鱼丸:BAAALgAECgEJAgAAAA==.',
['细雨']='细雨悲歌:BAAALgAECgUJBwAAAA==.',
['翱翔']='翱翔的蚂蚱:BAAALgADCgMJAwAAAA==.',
['老头']='老头:BAAALgADCgcJAgAAAA==.',
['艾亚']='艾亚哥斯:BAAALgAECgYJBwAAAA==.',
['花间']='花间:BAAALgADCgcJEAAAAA==.',
['花鸟']='花鸟风月:BAAALgAECgEJAQAAAA==.',
['茯叶']='茯叶:BAAALgAECgYJCwAAAA==.',
['莫无']='莫无言:BAAALgAECgYJCgAAAA==.',
['莫道']='莫道君行早:BAAALgAFFAEJAgAAAA==.',
['菲菲']='菲菲女王:BAAALgAECgMJAwAAAA==.',
['萨黯']='萨黯德萨:BAAALgADCgEJAQAAAA==.',
['蒨嬌']='蒨嬌絔媚:BAAALgAECgEJAQAAAA==.',
['蓝丶']='蓝丶语嫣:BAAALgAECgMJAgAAAA==.',
['虾仁']='虾仁水饺:BAAALgADCgQJBAAAAA==.',
['血狗']='血狗:BAAALgAECgEJAQAAAA==.',
['西门']='西门大官人:BAAALgAECgYJBgAAAA==.',
['跳糖']='跳糖:BAAALgAECgEJAQAAAA==.',
['醉晴']='醉晴儿丶:BAAALgADCgYJBgAAAA==.',
['醉里']='醉里挑灯看键:BAAALgADCgEJAQAAAA==.',
['重返']='重返艾泽拉丝:BAAALgAECgYJBgAAAA==.',
['饼干']='饼干姐姐丶:BAAALgAFFAIJAgAAAA==.',
['鬼教']='鬼教士:BAAALgAECgQJBAAAAA==.',
['鬼舞']='鬼舞凤凰:BAAALgAECgEJAwAAAA==.',
['鱼丸']='鱼丸粗面:BAAALgAECgQJBAAAAA==.',
['黑夜']='黑夜游戏:BAAALgAECgYJCQAAAA==.',
['黑皮']='黑皮体育生:BAAALgAECgcJDgAAAA==.',
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
