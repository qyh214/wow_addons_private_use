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

local lookup = {'Unknown-Unknown','Druid-Restoration','Druid-Balance','Mage-Frost','Mage-Arcane','Druid-Guardian','Hunter-BeastMastery','DeathKnight-Unholy','Paladin-Holy','Paladin-Retribution','Shaman-Restoration',}
local provider = {region='CN',realm='阿迦玛甘',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Airage:BAAALgAECgEJAQAAAA==.',
Ay='Ayesha:BAAALgAECgEJAwAAAA==.',
El='Elvin:BAAALgAECgQJBQAAAA==.',
Eo='Eowynn:BAAALgAECgEJAQAAAA==.',
Fr='Freedruid:BAAALgAFFAEJAgAAAA==.',
Hi='Highflybird:BAAALgAECgQJCQAAAA==.',
Hy='Hydruid:BAAALgAECgQJBQABLgAFFAUJAwABAAAAAA==.',
Im='Imfireup:BAAALgAECgEJAQAAAA==.',
Ku='Kumo:BAAALgAFFAQJBAAAAA==.',
Lu='Lumeng:BAAALgAECgEJAgAAAA==.',
Ma='Mandy:BAAALgAECgUJBgAAAA==.',
Me='Metatron:BAAALgAECgEJAwAAAA==.',
Ph='Phxsuns:BAAALgAECgYJDAAAAA==.',
Se='Seraphim:BAAALgAECgEJAgAAAA==.',
Si='Silentwings:BAAALgADCgEJAgAAAA==.',
Sm='Smoggy:BAAALgADCgIJAwAAAA==.',
Zs='Zsmj:BAABLgAECn8UAAMCAAYJTxueFQBFAQACAAYJTxueFQBFAQADAAEJAAAbiQAmAAAAAA==.',
['一只']='一只反派熊猫:BAAALgAECgYJBgAAAA==.',
['一岁']='一岁就很猛:BAAALgADCgEJAgAAAA==.',
['一生']='一生不醉醒:BAAALgAECgIJAgAAAA==.',
['一直']='一直很饿:BAAALgAECgYJBgAAAA==.',
['一羽']='一羽雪一:BAAALgAECgEJAQAAAA==.',
['乛釖']='乛釖閊:BAAALgAECgUJBQAAAA==.',
['九尾']='九尾:BAAALgAECgYJCAAAAA==.',
['二郎']='二郎顯聖真君:BAAALgAECgQJBAAAAA==.',
['亡者']='亡者之墙:BAAALgAECgYJDwAAAA==.',
['从前']='从前从前:BAAALgAECgEJAQAAAA==.',
['余晖']='余晖:BAAALgADCgEJAQAAAA==.',
['你这']='你这个小傻瓜:BAAALgAECgUJBQAAAA==.',
['信仰']='信仰:BAAALgAECgEJAgAAAA==.',
['傻而']='傻而不蛮:BAAALgADCgcJBwAAAA==.',
['元宝']='元宝咪咪猫:BAAALgAECgcJAwAAAA==.',
['全村']='全村人的希望:BAAALgAFFAMJAwAAAA==.',
['冰释']='冰释之尘:BAAALgAFFAIJBAAAAA==.',
['冰魔']='冰魔邪皇:BAABLgAECn8VAAMEAAcJ0Q7powCQAQAEAAcJEw7powCQAQAFAAMJ7go+FACCAAAAAA==.',
['冷雨']='冷雨清风:BAAALgAECgUJBgAAAA==.',
['凡心']='凡心:BAAALgADCgYJBgAAAA==.',
['刘备']='刘备丶:BAAALgAECgQJBAAAAA==.',
['剑舞']='剑舞悲风:BAAALgAECgQJBwAAAA==.',
['功夫']='功夫阿熊:BAAALgAECgIJAgAAAA==.',
['动态']='动态丶:BAAALgAECgUJBQAAAA==.',
['半本']='半本论语:BAAALgADCgEJAQAAAA==.',
['印第']='印第安纳:BAAALgAECgYJCwAAAA==.',
['史诗']='史诗坏女人:BAAALgAECgIJAgAAAA==.',
['唯壹']='唯壹一天天:BAAALgAECgUJDAAAAA==.',
['噬渊']='噬渊:BAAALgAECgcJBwAAAA==.',
['四枫']='四枫院里奇奥:BAABLgAECn8UAAQCAAcJVgi2HAAHAQACAAcJVgi2HAAHAQADAAUJTAduWwC1AAAGAAEJ8A00MwAoAAAAAA==.',
['圣光']='圣光之主:BAAALgADCgcJBwAAAA==.圣光你个骗子:BAAALgAECgQJBAAAAA==.圣光奶骑:BAAALgAECgMJBAAAAA==.',
['地獄']='地獄霸王丸:BAAALgAECgcJCgAAAA==.',
['增不']='增不了一点辉:BAAALgAECgEJAQAAAA==.',
['墨王']='墨王:BAAALgAECgYJBgAAAA==.',
['夏之']='夏之炎烈:BAAALgAECgcJBgAAAA==.',
['大腿']='大腿转砖转:BAAALgAECgEJAQAAAA==.',
['大辫']='大辫子小姑娘:BAAALgAECgUJBgAAAA==.',
['大静']='大静喜:BAAALgAECgUJCAAAAA==.',
['天空']='天空之骑:BAAALgAECgEJAgAAAA==.',
['奔騰']='奔騰小野豬:BAAALgAECgMJAwAAAA==.',
['妖孽']='妖孽般的崛起:BAAALgAFFAIJAwAAAA==.',
['姜同']='姜同学:BAAALgAECgMJAwAAAA==.',
['宇智']='宇智波萨:BAAALgAFFAEJAQAAAA==.',
['宗麟']='宗麟昭彰:BAAALgADCgEJAQAAAA==.',
['寶貝']='寶貝你好香:BAAALgAECgMJAwAAAA==.',
['小斩']='小斩:BAAALgADCgEJAQAAAA==.',
['小新']='小新:BAAALgAECgYJCQAAAA==.',
['小燚']='小燚乄龘德:BAAALgAECgEJAQAAAA==.',
['小美']='小美嘉:BAAALgAECgIJAgAAAA==.',
['小胖']='小胖豆:BAAALgAECgIJAgAAAA==.',
['小面']='小面加蛋:BAAALgADCgkJDAAAAA==.',
['小飞']='小飞棍:BAAALgAECgYJBgAAAA==.',
['希望']='希望之光:BAAALgADCgEJAQAAAA==.',
['带不']='带不带派老铁:BAAALgAFFAQJBAAAAA==.',
['弓月']='弓月:BAABLgAFFH8GAAIHAAMJ0xP3CwADAQAHAAMJ0xP3CwADAQAAAA==.',
['得瑟']='得瑟:BAAALgAFFAEJAQAAAA==.',
['想入']='想入非非:BAAALgAECgYJCAAAAA==.',
['戈登']='戈登费小曼:BAAALgADCgYJBwAAAA==.戈登阿喀琉斯:BAAALgAFFAEJAQAAAA==.戈登雅典娜:BAAALgAECgEJAQAAAA==.',
['我手']='我手冷:BAAALgAECgkJEgAAAA==.',
['我用']='我用双手:BAAALgAFFAQJBAAAAA==.',
['我都']='我都萌出血啦:BAAALgAECgEJAQAAAA==.',
['扔冰']='扔冰棍的石头:BAAALgAECgUJBwAAAA==.',
['拔刀']='拔刀千人亡:BAABLgAECn8cAAIIAAcJ8x0EFwB0AQAIAAcJ8x0EFwB0AQAAAA==.拔刀千人劫:BAAALgAECgMJAwAAAA==.',
['探姬']='探姬:BAAALgAECgQJBQAAAA==.',
['探险']='探险家黑眼:BAAALgAECgYJEAAAAA==.',
['提尔']='提尔之握:BAAALgAECgYJBgAAAA==.',
['摩挞']='摩挞罗迦:BAAALgAECgIJAgAAAA==.',
['救赎']='救赎丶:BAAALgAFFAEJAQAAAA==.',
['斧子']='斧子来了:BAAALgADCgMJAwAAAA==.',
['无心']='无心花恋雨:BAAALgADCgUJBQAAAA==.',
['明月']='明月昭昭:BAAALgAECgIJAgAAAA==.',
['星辰']='星辰紫玥:BAAALgAECgQJBwAAAA==.',
['春風']='春風十里:BAAALgAECgYJCwAAAA==.',
['月夜']='月夜灰:BAAALgAECgEJAQAAAA==.',
['月樱']='月樱:BAAALgAECgkJCQABLgAFFAMJCAAJAM0MAA==.',
['月魁']='月魁:BAAALgAECgYJBgAAAA==.',
['有药']='有药儿:BAAALgADCgUJBQAAAA==.',
['未来']='未来:BAAALgAECgYJBgAAAA==.',
['李连']='李连跪:BAAALgAECgEJAQAAAA==.',
['来了']='来了老弟:BAAALgADCgUJBQAAAA==.',
['来杯']='来杯酒:BAAALgAECgIJAgAAAA==.',
['杰兰']='杰兰特:BAABLgAECn8UAAIKAAYJ4RF8mABMAQAKAAYJ4RF8mABMAQAAAA==.',
['松树']='松树恶霸:BAAALgADCgQJBAAAAA==.',
['梦中']='梦中残蝶:BAAALgADCgIJAgAAAA==.',
['樱释']='樱释:BAAALgAECgEJAQAAAA==.',
['橙孑']='橙孑骑士:BAABLgAFFH8IAAIKAAMJ6hPLFAACAQAKAAMJ6hPLFAACAQAAAA==.',
['死亡']='死亡旋律:BAAALgAECgUJBQAAAA==.',
['毛茸']='毛茸茸的团子:BAAALgAECgcJBwAAAA==.',
['水漾']='水漾涟漪:BAAALgAFFAUJAQAAAA==.',
['浊酒']='浊酒倾觞:BAAALgADCgEJAQAAAA==.',
['海螺']='海螺头:BAAALgADCgYJBgAAAA==.',
['淡淡']='淡淡的味道:BAAALgAECgYJBgAAAA==.',
['溯洄']='溯洄水之湄:BAAALgAECgcJDwAAAA==.',
['灬指']='灬指尖流年灬:BAAALgAECgEJAQAAAA==.',
['燃烧']='燃烧太阳:BAAALgADCgIJAgAAAA==.',
['爱到']='爱到你想逃:BAAALgAECgEJAQAAAA==.',
['爵少']='爵少灬語楓:BAAALgAECgEJAgAAAA==.',
['爻叶']='爻叶:BAAALgAECgEJAQAAAA==.',
['牛腻']='牛腻牛腻:BAAALgAFFAIJBAAAAA==.',
['狼魂']='狼魂:BAAALgAFFAEJAQAAAA==.',
['神里']='神里绫华:BAAALgAECgIJAgAAAA==.',
['秋香']='秋香丶:BAAALgAECgQJAQAAAA==.',
['簌簌']='簌簌微风:BAAALgAECgcJBwAAAA==.',
['米粒']='米粒的米粒:BAAALgADCgYJDQAAAA==.',
['红橙']='红橙绿青蓝紫:BAAALgAECgcJDQAAAA==.',
['终不']='终不似:BAAALgAECgEJAgAAAA==.',
['绯雨']='绯雨潇潇:BAABLgAECn8YAAIEAAYJ1h3PYgAUAgAEAAYJ1h3PYgAUAgAAAA==.',
['胧幻']='胧幻月:BAAALgAECgQJBwABLgAECgUJCgABAAAAAA==.',
['艾拉']='艾拉哈:BAAALgAECgEJAgAAAA==.',
['花下']='花下晒爪子:BAABLgAFFH8FAAIDAAUJhwrUBgB2AQADAAUJhwrUBgB2AQAAAA==.',
['花落']='花落灬莫相离:BAAALgAECgcJDgAAAA==.',
['花间']='花间绕:BAAALgADCgYJBgAAAA==.',
['莉雅']='莉雅德琳:BAAALgAECgEJAQAAAA==.',
['莱恩']='莱恩:BAAALgAECgEJAwAAAA==.',
['萌面']='萌面大盗:BAABLgAFFH8GAAIIAAIJsRkWHwCkAAAIAAIJsRkWHwCkAAAAAA==.',
['虚影']='虚影之殇:BAAALgAECgIJBQAAAA==.',
['血债']='血债血偿:BAAALgAECgQJBwAAAA==.',
['西柚']='西柚大大人:BAAALgAECgQJBAAAAA==.',
['让我']='让我予你救赎:BAAALgAECgEJAQAAAA==.',
['贪财']='贪财吝鬼:BAAALgAECgUJBQAAAA==.',
['赛卓']='赛卓利昂:BAAALgAECgcJBwAAAA==.',
['赤影']='赤影:BAAALgAECgUJCgAAAA==.',
['逍遥']='逍遥纵横:BAAALgAFFAEJAQAAAA==.',
['醉舞']='醉舞流雲:BAAALgADCgEJAQAAAA==.',
['鋼鐵']='鋼鐵姬:BAAALgAECgMJBAAAAA==.',
['阳光']='阳光的果粒橙:BAAALgADCgYJBgAAAA==.',
['雪丶']='雪丶恋:BAABLgAECn8ZAAILAAcJjyP4CgDNAgALAAcJjyP4CgDNAgAAAA==.',
['雪地']='雪地的蚂蚱:BAAALgADCggJCQAAAA==.',
['雪香']='雪香凝树:BAAALgAECgUJBQAAAA==.',
['霜凛']='霜凛月:BAAALgAECgUJCgAAAA==.',
['風情']='風情萬種:BAAALgADCgUJBQAAAA==.',
['风暴']='风暴之人:BAAALgAECgQJBAAAAA==.',
['风行']='风行者飘渺:BAAALgAECgYJCwAAAA==.',
['飓风']='飓风行者:BAAALgAECgUJBQAAAA==.',
['飘渺']='飘渺风行者:BAAALgAECgQJBAAAAA==.',
['飘雪']='飘雪的海面:BAAALgADCgYJBgAAAA==.',
['魂念']='魂念:BAAALgAECgYJCAAAAA==.',
['魑魅']='魑魅魍魉魁:BAAALgAECgMJAwAAAA==.',
['麒麟']='麒麟重生:BAAALgAECgEJAQAAAA==.',
['黄总']='黄总:BAAALgAECgQJBAAAAA==.',
['黄昏']='黄昏的宁静:BAAALgADCgYJBwAAAA==.',
['黑暗']='黑暗的神父:BAAALgAECgIJAgAAAA==.',
['黑芝']='黑芝麻糖:BAAALgAECgEJAQAAAA==.',
['黑锅']='黑锅我来背吧:BAAALgAECgEJAQAAAA==.',
['鼎仔']='鼎仔:BAAALgAECgEJAQAAAA==.',
['鼠鼠']='鼠鼠猫猫狗鸡:BAAALgAFFAEJAQAAAA==.',
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
