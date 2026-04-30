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

local lookup = {'Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Mage-Frost','Warrior-Arms','Warrior-Protection','Unknown-Unknown','Warrior-Fury','Paladin-Retribution','Paladin-Protection','DeathKnight-Unholy','DeathKnight-Blood',}
local provider = {region='CN',realm='狂风峭壁',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amnesiac:BAAALgAECgQJBAAAAA==.',
Ap='Apolloone:BAAALgAECgIJAgAAAA==.',
Di='Diana:BAAALgADCgIJAgAAAA==.',
Gr='Grasperalove:BAAALgAECgYJBgAAAA==.',
Ho='Homelander:BAAALgAECgIJAgAAAA==.',
Ke='Kestrel:BAAALgAECgYJCwAAAA==.',
La='Lancer:BAAALgAFFAIJAwAAAA==.',
Ma='Malcanthet:BAABLgAFFH8NAAQBAAQJlxieIAABAQABAAMJ1hmeIAABAQACAAEJLhI1BgBTAAADAAEJDQnFFgBRAAAAAA==.',
Me='Mercy:BAACLgAFFH8NAAIEAAQJlR2SEwB9AQAEAAQJlR2SEwB9AQAuAAQKfxQAAgQACAlAFwdIAF8CAAQACAlAFwdIAF8CAAAA.Messi:BAAALgAFFAQJBAAAAA==.',
Se='Secretmask:BAAALgAECgEJAQAAAA==.Serendipity:BAAALgAECgUJBQAAAA==.',
Ss='Ssgt:BAAALgAECgEJAQAAAA==.',
['一亿']='一亿年太久:BAABLgAECn8pAAMFAAcJZARMLwB7AAAGAAUJWQQ2NQCdAAAFAAYJLAJMLwB7AAAAAA==.',
['一修']='一修罗一:BAAALgAECgkJCQAAAA==.',
['一斩']='一斩霏霜:BAAALgAFFAIJAwAAAA==.',
['一色']='一色彩羽丶:BAAALgAFFAQJBAAAAA==.',
['三十']='三十六的汉子:BAAALgAECgYJBwAAAA==.',
['三寸']='三寸天堂:BAAALgAECgYJBgAAAA==.',
['上班']='上班不打卡:BAAALgADCgUJBQAAAA==.',
['丨兎']='丨兎:BAAALgAECgcJDgAAAA==.',
['丶杨']='丶杨:BAAALgAECgQJBQAAAA==.',
['丷季']='丷季柏常:BAAALgAFFAEJAQAAAA==.',
['丹佛']='丹佛丶:BAAALgAFFAQJAQAAAA==.',
['丹圣']='丹圣丶:BAAALgAFFAcJBAAAAA==.',
['丹域']='丹域丶:BAAALgAFFAQJAQAAAA==.',
['丹天']='丹天丶:BAAALgAFFAYJBAAAAA==.',
['丹尼']='丹尼尔丶:BAABLgAFFH8MAAIEAAcJGBshAABbAgAEAAcJGBshAABbAgAAAA==.',
['丹神']='丹神丶:BAABLgAFFH8FAAIEAAUJ1BHmDAC1AQAEAAUJ1BHmDAC1AQAAAA==.',
['丹紫']='丹紫丶:BAABLgAFFH8GAAIEAAUJtAwODwCfAQAEAAUJtAwODwCfAQAAAA==.',
['丹红']='丹红丶:BAAALgAFFAcJAgAAAA==.',
['丹蓝']='丹蓝丶:BAAALgAFFAYJAwAAAA==.',
['丹魔']='丹魔丶:BAAALgAFFAcJAQAAAA==.',
['二十']='二十七的妹子:BAAALgAECgYJBgAAAA==.',
['伊瑟']='伊瑟垃丶梦魇:BAAALgADCgIJAgAAAA==.',
['俺莲']='俺莲莲:BAAALgAECgcJCgAAAA==.',
['倒霉']='倒霉菜菜:BAAALgADCgUJBQAAAA==.',
['偶尔']='偶尔忘喘气:BAAALgADCgcJBwAAAA==.',
['八奈']='八奈见杏菜丶:BAAALgAECgcJBwABLgAFFAQJBAAHAAAAAA==.',
['其實']='其實我愛你:BAAALgAECgcJCQAAAA==.',
['叫我']='叫我老柯就好:BAAALgAECgQJBwAAAA==.',
['吃不']='吃不饱:BAAALgAECgYJCQAAAA==.',
['含笑']='含笑半步癫:BAAALgAECgcJCAAAAA==.',
['呜喵']='呜喵王:BAAALgAECgMJBAAAAA==.',
['咖啡']='咖啡撒了:BAAALgADCgUJBQAAAA==.',
['啊哩']='啊哩哩啊哩哩:BAAALgAECgcJDgAAAA==.',
['啊牛']='啊牛哥:BAAALgAECgYJCgAAAA==.',
['嗜血']='嗜血的卫生棉:BAAALgAECgUJBQAAAA==.',
['堕天']='堕天:BAAALgADCgQJBAAAAA==.堕天丿丿伊人:BAAALgAECgYJBgAAAA==.堕天卡皮巴拉:BAAALgAECgYJBwAAAA==.',
['夏木']='夏木木丶:BAAALgAECgYJEAAAAA==.',
['大叔']='大叔大叔:BAAALgADCgYJCwAAAA==.大叔就是好:BAAALgAECgMJAwAAAA==.大叔铛铛:BAAALgAECgcJBwAAAA==.',
['大川']='大川:BAAALgAFFAEJAQAAAA==.大川丶:BAAALgAECgYJBgAAAA==.',
['大火']='大火:BAAALgAECgUJBQAAAA==.',
['大灰']='大灰狼敲你门:BAAALgAECgUJBAAAAA==.',
['大熊']='大熊比较懒:BAAALgAFFAMJAwAAAA==.',
['天天']='天天吃素:BAAALgAECgMJAgAAAA==.',
['太阳']='太阳神之女:BAAALgAECgYJDQAAAA==.',
['失误']='失误术:BAAALgAFFAEJAQAAAA==.',
['奈飞']='奈飞天:BAAALgAECgUJBgAAAA==.',
['妇科']='妇科张主任:BAAALgADCgUJBQAAAA==.',
['妹子']='妹子请你睡觉:BAAALgAECgUJBwAAAA==.',
['媚魅']='媚魅:BAAALgAECgUJCAAAAA==.',
['宝宝']='宝宝无聊:BAAALgADCgEJAQAAAA==.',
['小小']='小小飞儿:BAAALgADCgMJAwAAAA==.',
['小木']='小木哥:BAAALgAECgEJAgAAAA==.',
['小棍']='小棍棍满地插:BAAALgAECgUJBQAAAA==.',
['小白']='小白士力架:BAAALgAECgUJBAAAAA==.',
['少游']='少游:BAAALgAFFAIJAgAAAA==.',
['廿四']='廿四小时考拉:BAAALgADCgQJBAAAAA==.',
['张无']='张无忌:BAAALgAECgUJBgAAAA==.',
['强到']='强到你唔信:BAAALgAFFAQJAgAAAA==.',
['形影']='形影相随:BAAALgAECgQJBAAAAA==.',
['得加']='得加钱:BAAALgAECgEJAQAAAA==.',
['德玛']='德玛西亚亚:BAAALgADCgYJEQAAAA==.',
['愿圣']='愿圣光忽悠伱:BAAALgAECgQJBAAAAA==.',
['戈隆']='戈隆之伤:BAAALgAECgEJAQAAAA==.',
['我来']='我来抗揍:BAAALgAECgUJCgAAAA==.',
['整囊']='整囊鸡棕:BAAALgAECgEJAQAAAA==.',
['无法']='无法大魔:BAAALgAECgIJAgAAAA==.',
['无道']='无道子:BAAALgAECgEJAQAAAA==.',
['是你']='是你的林夕:BAAALgAECgEJAQAAAA==.',
['暮岚']='暮岚寒枫:BAAALgAECgYJDgAAAA==.',
['暮雨']='暮雨朝露:BAAALgAECgQJBAAAAA==.',
['月落']='月落无尘:BAAALgAFFAIJAwAAAA==.',
['月蚀']='月蚀碎碎念:BAAALgAECgUJBwAAAA==.',
['木珀']='木珀:BAAALgAECgEJAQAAAA==.',
['未语']='未语人先羞:BAAALgAECgYJCAAAAA==.',
['李与']='李与刘:BAAALgAECgQJCgAAAA==.',
['栽培']='栽培:BAAALgAECgYJDAAAAA==.',
['棉花']='棉花棒棒:BAAALgAECgQJBAAAAA==.',
['欢喜']='欢喜牛喜欢:BAAALgAECgMJAwAAAA==.',
['欢场']='欢场米妮:BAAALgAFFAIJAgAAAA==.',
['比鲁']='比鲁卡:BAAALgAECgEJAQAAAA==.',
['永乐']='永乐小碗加杂:BAAALgADCgYJBwAAAA==.',
['浅梦']='浅梦:BAABLgAFFH8LAAIIAAQJvRvMCgBPAQAIAAQJvRvMCgBPAQAAAA==.',
['海晏']='海晏河清:BAAALgAECgIJAwAAAA==.',
['清水']='清水加冰:BAABLgAFFH8HAAIBAAQJ6wbpGQAiAQABAAQJ6wbpGQAiAQAAAA==.',
['潴潴']='潴潴嫒你:BAAALgAECgYJBwAAAA==.',
['火焰']='火焰饺子:BAAALgAECgQJBAAAAA==.',
['灬转']='灬转弯的箭:BAAALgAECgYJCQAAAA==.',
['灵語']='灵語:BAAALgAECgEJAgAAAA==.',
['烈火']='烈火烟石:BAAALgADCgUJBQAAAA==.',
['爱原']='爱原始森林:BAAALgAECgYJEgAAAA==.',
['爱困']='爱困的猫:BAAALgAECgEJAgAAAA==.',
['爱雪']='爱雪花飘:BAAALgAECgUJCAAAAA==.',
['爱高']='爱高山:BAAALgAECgUJCQAAAA==.',
['玩命']='玩命的香烟:BAAALgAECgIJAwAAAA==.',
['盖世']='盖世英熊:BAAALgAECgUJBgAAAA==.',
['真德']='真德香草奶昔:BAAALgAFFAEJAQAAAA==.',
['瞧灬']='瞧灬:BAAALgAECgUJBgAAAA==.',
['秦少']='秦少游:BAABLgAFFH8NAAIEAAQJJgprIABEAQAEAAQJJgprIABEAQABLgAFFAUJAQAHAAAAAA==.',
['绝叔']='绝叔叔:BAAALgAECgQJBQAAAA==.',
['胎哥']='胎哥:BAAALgAECgEJAQAAAA==.',
['舞清']='舞清影:BAAALgAECgYJBQAAAA==.',
['艾琳']='艾琳亚德拉:BAAALgADCgYJBgAAAA==.',
['芒果']='芒果不要跑:BAAALgAECgEJAgAAAA==.',
['苏摩']='苏摩丶:BAAALgAECgEJAQAAAA==.',
['萧峰']='萧峰:BAAALgAECgIJAwAAAA==.',
['萨牟']='萨牟拉:BAAALgAFFAIJAwAAAA==.',
['蓝色']='蓝色灬晨曦:BAAALgADCgEJAQAAAA==.',
['藏藏']='藏藏:BAACLgAFFH8HAAIJAAMJbB+NEAAhAQAJAAMJbB+NEAAhAQAuAAQKfyAAAgkACQlwHKMUAO4CAAkACQlwHKMUAO4CAAAA.',
['虎虎']='虎虎浩:BAAALgAECgYJAgAAAA==.',
['蜜雪']='蜜雪冰城:BAAALgAECgQJCwAAAA==.',
['蟲蟲']='蟲蟲频道:BAAALgAECgQJBAAAAA==.',
['蟹不']='蟹不肉:BAAALgADCgEJAQAAAA==.',
['言言']='言言:BAAALgADCgkJCwAAAA==.',
['贲牛']='贲牛:BAAALgAECgcJDAAAAA==.',
['贾斯']='贾斯汀豆豆:BAAALgAECgMJAgAAAA==.',
['赏心']='赏心悦目:BAAALgADCgYJBgAAAA==.',
['迈克']='迈克沃尔夫:BAAALgAECgEJAQAAAA==.',
['道友']='道友剑影:BAAALgADCgIJAgAAAA==.道友闻香:BAAALgADCgYJCAAAAA==.道友魔刃:BAAALgADCgQJBAAAAA==.',
['釹孩']='釹孩子:BAAALgAECgcJBwAAAA==.',
['销魂']='销魂姐姐:BAAALgAECgEJAQAAAA==.销魂蜜汁:BAAALgAECgEJAQAAAA==.',
['阿丹']='阿丹丶:BAAALgAFFAQJAgAAAA==.',
['随便']='随便玩玩儿:BAABLgAECn8XAAMJAAcJRBwkMwBWAgAJAAcJRBwkMwBWAgAKAAEJewjrRgAmAAAAAA==.',
['雪露']='雪露诺姆:BAAALgAECgUJBQAAAA==.',
['韬总']='韬总:BAAALgAECgIJAgAAAA==.',
['韭菜']='韭菜炒鸡蛋:BAACLgAFFH8IAAILAAMJIR/dHwAbAQALAAMJIR/dHwAbAQAuAAQKfxoAAwsABwlBIu00AGMCAAsABgn9JO00AGMCAAwABAkDEbsyAKoAAAAA.',
['風清']='風清露寒:BAAALgAECgQJBwAAAA==.',
['风吹']='风吹蒲公英:BAAALgAECgkJDwAAAA==.',
['龍戦']='龍戦雲野丶丨:BAAALgAECgcJBwAAAA==.',
['龙人']='龙人:BAAALgAECgYJDwAAAA==.',
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
