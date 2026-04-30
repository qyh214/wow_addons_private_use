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

local lookup = {'Mage-Frost','DeathKnight-Unholy','DemonHunter-Devourer','Monk-Brewmaster','Rogue-Subtlety','Paladin-Holy','Unknown-Unknown','Shaman-Elemental',}
local provider = {region='CN',realm='暮色森林',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adety:BAABLgAFFH8KAAIBAAYJJxqDAwA+AgABAAYJJxqDAwA+AgAAAA==.',
As='Asuka:BAAALgAECgEJAgAAAA==.',
Au='Augustus:BAAALgAECgUJBQAAAA==.',
Co='Cowboy:BAAALgAECgQJBAAAAA==.',
Dd='Ddlr:BAAALgAECgMJAwAAAA==.',
De='Deathme:BAAALgAECgEJAQAAAA==.Deluyi:BAAALgADCgEJAQAAAA==.',
Dh='Dhh:BAAALgADCgUJBQAAAA==.',
Ed='Edith:BAAALgAECgkJEQAAAA==.',
Ex='Existed:BAACLgAFFH8HAAICAAMJiCYYFABSAQACAAMJiCYYFABSAQAuAAQKfxwAAgIACAmnIicgAMECAAIACAmnIicgAMECAAAA.',
Fe='Fellblade:BAAALgAECgEJAQAAAA==.',
Ge='Gevjon:BAAALgAECgcJBwAAAA==.',
Lu='Lucashaman:BAAALgAECggJEQAAAA==.',
Ma='Malestorm:BAAALgAECgYJBgAAAA==.',
Na='Nagashi:BAAALgAECgUJBQAAAA==.',
No='Notexist:BAAALgAECgQJBAABLgAFFAMJBwACAIgmAA==.Notoobad:BAAALgAECgQJBQAAAA==.',
Sh='Shamanship:BAAALgAECgEJAgAAAA==.',
Su='Sulla:BAAALgAECgEJAQAAAA==.',
Sy='Syhylc:BAAALgAECgIJAgAAAA==.',
Va='Valkyrier:BAAALgADCgEJAQAAAA==.Vampire:BAAALgAECgkJEAABLgAFFAQJCAADAKsSAA==.',
['一只']='一只小水法:BAAALgAECgcJBwAAAA==.',
['一宿']='一宿梦:BAAALgAECgYJCQAAAA==.',
['一般']='一般般吧:BAAALgAECgYJCgAAAA==.',
['丁丁']='丁丁打车:BAAALgAECgIJAgAAAA==.',
['不知']='不知名的萨满:BAAALgAECgYJCwAAAA==.',
['丫丫']='丫丫宝贝妈:BAAALgAECgIJAgAAAA==.',
['丶京']='丶京多安灬:BAABLgAFFH8JAAIEAAQJugehFQDIAAAEAAQJugehFQDIAAAAAA==.',
['云衶']='云衶心:BAABLgAECn8UAAIBAAYJPw6PMgD+AAABAAYJPw6PMgD+AAAAAA==.',
['伊万']='伊万卡麦兜:BAAALgAECgEJAgAAAA==.',
['你们']='你们卡吗:BAAALgAECgIJAwAAAA==.',
['修谱']='修谱丿诺斯丨:BAAALgAFFAIJAwAAAA==.',
['倒卖']='倒卖银鳞胸甲:BAAALgAECgIJAgAAAA==.',
['儰装']='儰装灬嗳謺妳:BAAALgAECgQJBAAAAA==.',
['八块']='八块凹凸肌:BAAALgAECggJDwAAAA==.',
['再看']='再看我就揍你:BAAALgADCgEJAQAAAA==.',
['冰雨']='冰雨飘凌:BAAALgADCgUJBQAAAA==.',
['凯瑟']='凯瑟琳黎恩:BAAALgAECgMJBAAAAA==.',
['卡内']='卡内奇:BAAALgADCgEJAQAAAA==.',
['卿心']='卿心:BAAALgAECgYJBgAAAA==.',
['吃大']='吃大米长大个:BAABLgAECn8eAAICAAgJyhqiLACGAgACAAgJyhqiLACGAgAAAA==.',
['吕菲']='吕菲菲:BAAALgADCgMJAwAAAA==.',
['咕德']='咕德鹦鹉咛:BAAALgAECgEJAQAAAA==.',
['回忆']='回忆满满:BAAALgAECgEJAgAAAA==.',
['壅鑍']='壅鑍:BAAALgAECgIJAQAAAA==.',
['夏沫']='夏沫浅色:BAAALgAECgEJAQAAAA==.',
['夕诚']='夕诚:BAAALgAECgQJCAAAAA==.',
['夜之']='夜之灵影:BAAALgAECgMJAwAAAA==.',
['夜幕']='夜幕之下:BAAALgAECgEJAQAAAA==.',
['大伄']='大伄无敌:BAAALgAECgIJAgAAAA==.',
['大囚']='大囚长:BAAALgAECgEJAQAAAA==.',
['大衆']='大衆老司機:BAABLgAFFH8NAAIEAAQJsg5KDQAbAQAEAAQJsg5KDQAbAQAAAA==.',
['奋斗']='奋斗的小蜜蜂:BAAALgAECgYJBgAAAA==.',
['妮妮']='妮妮:BAAALgAECgEJAQAAAA==.',
['娜武']='娜武:BAAALgAECgIJAgAAAA==.',
['寒依']='寒依依:BAAALgAECgkJBAAAAA==.',
['小亓']='小亓不要跑:BAAALgAECgYJBgAAAA==.',
['小晓']='小晓蛸:BAAALgAECgYJBwAAAA==.',
['小母']='小母牛翻单杠:BAAALgAECgcJAwAAAA==.',
['小河']='小河豚:BAAALgAECgQJAQAAAA==.',
['小熊']='小熊软糖:BAAALgAECgIJAgAAAA==.',
['小里']='小里里:BAAALgAECgMJAwAAAA==.',
['小音']='小音哼哼:BAAALgAECgkJCQAAAA==.',
['少糖']='少糖多冰:BAAALgAECgEJAQAAAA==.',
['岭西']='岭西吴彦祖:BAAALgAFFAEJAQAAAA==.',
['帕力']='帕力:BAAALgAFFAIJAgAAAA==.',
['平安']='平安晔:BAABLgAFFH8FAAIFAAUJbw3vAwC5AQAFAAUJbw3vAwC5AQAAAA==.',
['弟弟']='弟弟救我:BAAALgADCgcJCwAAAA==.',
['德鲁']='德鲁鸡:BAAALgAFFAIJAwABLgAFFAMJCQAGALclAA==.',
['心跳']='心跳叁陸零:BAAALgAFFAEJAgAAAA==.',
['恨意']='恨意的单行道:BAAALgAECgYJCwAAAA==.',
['战如']='战如意:BAAALgAECgIJAgAAAA==.',
['指尖']='指尖的忧伤:BAAALgAECgYJDAAAAA==.指尖的疯狂:BAAALgAECgQJBwAAAA==.',
['插头']='插头:BAAALgAECgYJCAAAAA==.',
['放羊']='放羊的猩猩:BAAALgAECgUJBQAAAA==.',
['教练']='教练我想打球:BAAALgAFFAEJAQAAAA==.',
['易水']='易水寒庭:BAAALgAECgMJAwAAAA==.',
['星月']='星月瞳影:BAAALgADCgEJAQAAAA==.',
['曰落']='曰落:BAAALgAECgIJAgAAAA==.',
['月事']='月事灌血肠:BAAALgADCgEJAQAAAA==.',
['梅丶']='梅丶比斯:BAAALgADCgEJAQAAAA==.',
['梅凉']='梅凉馨:BAAALgAFFAMJBAAAAA==.',
['楚王']='楚王爷:BAAALgAECgYJCgAAAA==.',
['永和']='永和大王:BAAALgAECgMJAwAAAA==.',
['汉堡']='汉堡王:BAAALgAECgEJAQAAAA==.',
['河下']='河下文楼:BAAALgAECgYJDQAAAA==.',
['泳儿']='泳儿:BAAALgAECgEJAQAAAA==.',
['洛琪']='洛琪希:BAAALgAECgYJBgAAAA==.',
['浪裏']='浪裏小白龍:BAAALgAECgYJBwABLgAFFAQJDQAEALIOAA==.',
['滨崎']='滨崎步:BAAALgAECgQJAwAAAA==.',
['灌奶']='灌奶高手:BAAALgAECgQJBQAAAA==.',
['灬菜']='灬菜虚鲲灬:BAAALgAFFAEJAgAAAA==.',
['灰常']='灰常博爱:BAAALgAECgYJBwAAAA==.灰常爱干净:BAAALgAECgUJCwAAAA==.',
['炮灰']='炮灰式稻草:BAAALgAFFAEJAQAAAA==.',
['熊熊']='熊熊我呀:BAAALgADCgYJBwAAAA==.',
['狼灰']='狼灰:BAAALgAECgYJCAABLgAFFAQJCgAEAFgdAA==.',
['玛里']='玛里奥:BAAALgAECgEJAQAAAA==.',
['盾挡']='盾挡:BAAALgAECgMJAwAAAA==.',
['破晓']='破晓峰:BAAALgADCgMJAwAAAA==.',
['破疯']='破疯:BAAALgAECgMJBAAAAA==.',
['笨笨']='笨笨爱吃肉:BAAALgAECgMJAwAAAA==.',
['简单']='简单二号:BAAALgAECgUJBQABLgAECgYJBwAHAAAAAA==.简单亿点:BAAALgAECgUJBgABLgAECgYJBwAHAAAAAA==.',
['糖果']='糖果:BAAALgADCgYJBgAAAA==.',
['素锦']='素锦:BAAALgAECgEJAQAAAA==.',
['绿谷']='绿谷风情:BAAALgADCgYJCwAAAA==.',
['罗克']='罗克特光行者:BAAALgAECgEJAQAAAA==.',
['美利']='美利达尔:BAAALgAECgEJAQAAAA==.',
['翡悦']='翡悦:BAAALgAECgIJAgAAAA==.',
['肝道']='肝道夫:BAAALgAECgQJBgAAAA==.',
['肥仔']='肥仔快乐术:BAAALgAECgEJAQAAAA==.',
['胖胖']='胖胖的法师:BAAALgAECgQJBAAAAA==.',
['胡子']='胡子阿八:BAABLgAFFH8FAAICAAIJYgkeRACbAAACAAIJYgkeRACbAAAAAA==.',
['脆脆']='脆脆鲨:BAAALgAECgYJEAAAAA==.',
['至于']='至于你信不信:BAAALgAECgMJAwAAAA==.',
['艾利']='艾利希亚:BAAALgAECgQJBQAAAA==.',
['芝士']='芝士菌:BAAALgAECgYJDQAAAA==.',
['范克']='范克里夫佩琪:BAAALgAECgQJBgAAAA==.',
['荣耀']='荣耀之盾:BAAALgAECgUJDAAAAA==.',
['菊花']='菊花残了:BAAALgAECgYJBgAAAA==.',
['菲伦']='菲伦:BAABLgAFFH8GAAIBAAIJdAnPRACmAAABAAIJdAnPRACmAAAAAA==.',
['血无']='血无殇:BAAALgAECgEJAgAAAA==.',
['血腥']='血腥之王:BAAALgAECgYJCgAAAA==.',
['血誓']='血誓:BAAALgAECgEJAQAAAA==.',
['诺莫']='诺莫瑞根之光:BAAALgAECgQJBAAAAA==.',
['调皮']='调皮的笑笑:BAAALgAECgkJCQAAAA==.',
['超级']='超级野猪王:BAAALgAECgIJAgAAAA==.',
['那个']='那个奇士:BAAALgAECgYJBgAAAA==.',
['醉舞']='醉舞仙疯:BAAALgAECgYJBgAAAA==.',
['门糖']='门糖别喊滚:BAAALgAECgEJAQAAAA==.',
['降妖']='降妖除魔:BAAALgADCgQJCAAAAA==.',
['隠隠']='隠隠莋痛:BAAALgAFFAEJAQABLgAFFAcJBQAIANEWAA==.',
['雅玟']='雅玟:BAAALgAECgMJBAAAAA==.',
['雨喧']='雨喧:BAAALgAECgMJAwAAAA==.',
['雪尽']='雪尽苍穹:BAAALgADCgYJBgAAAA==.',
['雪满']='雪满天飞:BAAALgAECgMJAwAAAA==.',
['霜歌']='霜歌:BAAALgADCgEJAQAAAA==.',
['黑色']='黑色迪酷:BAAALgAECgYJCgAAAA==.',
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
