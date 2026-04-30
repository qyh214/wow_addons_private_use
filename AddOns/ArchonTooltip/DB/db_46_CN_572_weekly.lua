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

local lookup = {'Monk-Brewmaster','Shaman-Restoration','Paladin-Retribution','Warlock-Demonology','Unknown-Unknown','Warrior-Protection','Warlock-Destruction','Druid-Feral','Shaman-Elemental','Druid-Restoration','Warrior-Fury',}
local provider = {region='CN',realm='伊莫塔尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Do='Dogeme:BAAALgAECgEJAQAAAA==.',
Fb='Fbdeekay:BAAALgAECgcJEgAAAA==.Fbdeekey:BAAALgAECgYJBgAAAA==.',
Ho='Holyblood:BAAALgAECgcJDQAAAA==.Holyshock:BAAALgAECgYJBwAAAA==.Holysmoke:BAAALgAECgQJBQAAAA==.',
Hy='Hypoxia:BAAALgAECgMJAwAAAA==.',
Je='Jeremiah:BAAALgAECgQJBgAAAA==.',
Kp='Kpoves:BAAALgAECgQJBAAAAA==.',
Pe='Pepe:BAAALgAFFAEJAgAAAA==.',
Qu='Quagmire:BAABLgAFFH8JAAIBAAQJ9gwKDgAUAQABAAQJ9gwKDgAUAQAAAA==.',
Si='Sigma:BAABLgAFFH8HAAIBAAMJ/AoJCQDTAAABAAMJ/AoJCQDTAAAAAA==.',
St='Stewie:BAABLgAFFH8JAAIBAAQJ+hBLDAAjAQABAAQJ+hBLDAAjAQAAAA==.',
Su='Sugardemon:BAABLgAFFH8HAAICAAMJixupBQAKAQACAAMJixupBQAKAQAAAA==.',
Va='Valphalk:BAAALgAECgUJBwAAAA==.',
Xd='Xdasd:BAAALgAECgQJBAAAAA==.',
['一木']='一木:BAAALgAECgIJAgAAAA==.',
['七宝']='七宝琉璃:BAAALgAECgQJBQAAAA==.',
['三六']='三六扑灭:BAAALgADCgMJAwAAAA==.',
['三宝']='三宝如意:BAAALgAECgUJBgAAAA==.',
['专属']='专属于你:BAAALgAECgMJAQAAAA==.',
['两百']='两百灵武:BAAALgAECgcJDAAAAA==.',
['丨吾']='丨吾皇丨:BAABLgAFFH8HAAIDAAMJLyS5BQA0AQADAAMJLyS5BQA0AQAAAA==.',
['丶喵']='丶喵小九:BAAALgAFFAIJAgAAAA==.',
['丶电']='丶电动亚当:BAAALgAFFAEJAQAAAA==.',
['丿丶']='丿丶尛肚兜:BAAALgAECgYJBwAAAA==.',
['九千']='九千胜:BAAALgADCgEJAQAAAA==.',
['五杀']='五杀奥拉夫:BAAALgAECgUJBgAAAA==.',
['人凄']='人凄灬有三好:BAAALgAECgkJBgAAAA==.',
['伊利']='伊利蛋小飞:BAAALgAECgUJBwAAAA==.',
['会圣']='会圣光的大虾:BAAALgAECgYJBgAAAA==.',
['依然']='依然在这里:BAAALgADCgUJCgAAAA==.',
['傲娇']='傲娇的老夫子:BAAALgAECgYJDwAAAA==.',
['兵者']='兵者丶胸器也:BAAALgAECgEJAQAAAA==.',
['再见']='再见蔡瑗瑗:BAAALgAECgEJAgAAAA==.',
['凋零']='凋零之刃:BAAALgAECgUJBQAAAA==.',
['刺猬']='刺猬的优雅:BAAALgADCgUJBAAAAA==.',
['劲风']='劲风煞:BAAALgAFFAQJBAAAAA==.',
['勿念']='勿念丶:BAAALgAFFAIJAgAAAA==.',
['千风']='千风飓:BAABLgAFFH8GAAIBAAMJogf0CADVAAABAAMJogf0CADVAAAAAA==.',
['南信']='南信双皮奶:BAAALgAECgcJCAAAAA==.',
['南风']='南风知我意:BAAALgAECgQJBgAAAA==.',
['卡恩']='卡恩牛牛:BAAALgADCgEJAQAAAA==.',
['卧龙']='卧龙崽主:BAAALgADCgkJCwAAAA==.',
['友利']='友利奈绪:BAAALgAECgcJDAAAAA==.',
['叶奈']='叶奈法:BAAALgAFFAQJBAAAAA==.',
['呆弟']='呆弟:BAAALgADCgEJAQAAAA==.',
['咕德']='咕德猫宁比尔:BAAALgAECgYJCgAAAA==.',
['啊呱']='啊呱呱:BAAALgAECggJCQABLgAFFAYJFgAEAA8mAA==.',
['嘟嘟']='嘟嘟的木事:BAAALgAECgYJAgAAAA==.',
['圣光']='圣光忽悠您:BAAALgAECgEJAQAAAA==.',
['圣琦']='圣琦琦:BAAALgADCgEJAQAAAA==.',
['墨鑫']='墨鑫辰:BAAALgAECgEJAQABLgAFFAUJBAAFAAAAAA==.',
['壳转']='壳转:BAAALgAFFAMJAgAAAA==.',
['壹戰']='壹戰成冥:BAABLgAFFH8GAAIGAAMJdgqFDACCAAAGAAMJdgqFDACCAAAAAA==.',
['多恩']='多恩保安队长:BAAALgAFFAEJAQAAAA==.',
['天芷']='天芷丶若殇:BAAALgAECgQJBQAAAA==.',
['妙白']='妙白:BAAALgADCgIJAgAAAA==.',
['娇花']='娇花妹:BAAALgAECgQJBAAAAA==.',
['寒冷']='寒冷冷:BAABLgAFFH8GAAIEAAQJBhGPCAA7AQAEAAQJBhGPCAA7AQAAAA==.',
['小鬼']='小鬼成群:BAABLgAFFH8PAAMHAAQJux/4CQC6AAAEAAIJxx+SEwDIAAAHAAIJrx/4CQC6AAAAAA==.',
['就这']='就这样可以了:BAAALgAECgYJDQAAAA==.',
['就那']='就那样:BAAALgAECgQJBgAAAA==.',
['尹娜']='尹娜的光华:BAABLgAFFH8JAAIBAAQJwAzrBQAZAQABAAQJwAzrBQAZAQAAAA==.尹娜的真言:BAABLgAFFH8KAAIBAAQJCQ7IDgANAQABAAQJCQ7IDgANAQAAAA==.',
['岛田']='岛田半藏:BAAALgAFFAEJAQAAAA==.',
['巨德']='巨德魔鲁:BAAALgADCgUJBQAAAA==.',
['巨龙']='巨龙材料库:BAAALgAECgcJDwAAAA==.',
['张飞']='张飞是也:BAABLgAFFH8JAAIGAAUJ0xbcAgB0AQAGAAUJ0xbcAgB0AQAAAA==.',
['德来']='德来不易:BAAALgAECgEJAQAAAA==.',
['心外']='心外無物:BAAALgAECgYJCgAAAA==.',
['思远']='思远:BAAALgAECgUJCAAAAA==.',
['悲剧']='悲剧的背后:BAAALgAECgQJBAABLgAFFAQJEAAIAOsiAA==.',
['感觉']='感觉萌萌的:BAAALgADCgEJAQAAAA==.',
['拉斯']='拉斯塔哈:BAAALgADCgMJAwAAAA==.',
['拉面']='拉面公子:BAAALgAFFAEJAQAAAA==.',
['拷丶']='拷丶哟:BAABLgAFFH8FAAIJAAUJdhsVAwC/AQAJAAUJdhsVAwC/AQAAAA==.',
['放开']='放开那只怪物:BAAALgAECgUJBgAAAA==.',
['文森']='文森特:BAAALgAECgYJAQAAAA==.',
['明珰']='明珰:BAAALgAECgkJDQABLgAFFAQJEwAKADEgAA==.',
['星宿']='星宿劫:BAAALgAECgEJAQAAAA==.',
['晨曦']='晨曦之刃:BAAALgAECgYJBgAAAA==.',
['月光']='月光如情:BAAALgADCgEJAQAAAA==.',
['树枝']='树枝:BAAALgAECgIJAgAAAA==.',
['梅川']='梅川小内酷:BAAALgAECgQJCgAAAA==.',
['梦里']='梦里云归何处:BAAALgAECgEJAgAAAA==.',
['楊柳']='楊柳丶丶:BAAALgAECgEJAQAAAA==.',
['榆的']='榆的传说:BAAALgADCgEJAQAAAA==.',
['次你']='次你把卵:BAAALgAECgQJAgAAAA==.',
['欧痘']='欧痘痘七号:BAAALgAECgcJBwAAAA==.欧痘痘九号:BAAALgAECgkJDwAAAA==.欧痘痘六号:BAAALgAECgkJDAAAAA==.',
['死过']='死过不怕死了:BAAALgAECgcJBwAAAA==.',
['殘丶']='殘丶葉:BAAALgAECgEJAQAAAA==.',
['水晶']='水晶紫葡萄:BAAALgADCgQJBAAAAA==.',
['法力']='法力风暴:BAAALgAECgcJDQAAAA==.',
['流木']='流木:BAAALgAECgEJAQAAAA==.',
['淡淡']='淡淡秋色浓香:BAAALgAECgIJAgAAAA==.',
['潔身']='潔身自好:BAEBLgAFFH8IAAIEAAQJEhqkHQAOAQAEAAQJEhqkHQAOAQAAAA==.',
['灵疯']='灵疯疯癫癫:BAAALgAECgQJBQAAAA==.',
['炎黄']='炎黄远征:BAAALgAECgYJDwAAAA==.',
['炒饭']='炒饭先生:BAAALgADCgMJAwAAAA==.',
['点一']='点一支烟:BAAALgAECgMJBAAAAA==.',
['為愛']='為愛戰魔:BAAALgAECgEJAQAAAA==.',
['烂不']='烂不烂问厨房:BAABLgAFFH8KAAIBAAQJMQsrDwAKAQABAAQJMQsrDwAKAQAAAA==.',
['熊猫']='熊猫猎:BAAALgADCgMJAwAAAA==.',
['牛叉']='牛叉二哥:BAAALgADCgIJAgAAAA==.',
['狠灬']='狠灬牛灬叉:BAAALgAECgMJBAAAAA==.',
['玉衡']='玉衡:BAAALgAECgQJBwAAAA==.',
['王百']='王百万:BAAALgADCgEJAQAAAA==.',
['生光']='生光:BAAALgAFFAQJAQAAAA==.',
['白夜']='白夜幽:BAAALgAECgYJBQAAAA==.',
['百兽']='百兽凯多:BAAALgAFFAIJAgAAAA==.',
['真心']='真心换真心:BAAALgAFFAEJAQAAAA==.',
['等一']='等一场雪:BAAALgAECgYJDQABLgAECgYJDwAFAAAAAA==.',
['紫丨']='紫丨沫沫:BAAALgAECgIJAgAAAA==.',
['织命']='织命:BAAALgAECgUJBwAAAA==.',
['给哥']='给哥站好:BAAALgAECgMJAwAAAA==.',
['肉皮']='肉皮冻:BAAALgADCgUJBQAAAA==.',
['胖达']='胖达:BAAALgAECgMJAwAAAA==.',
['脉脉']='脉脉不得語:BAAALgAECggJAwAAAA==.',
['菠萝']='菠萝小小黑:BAAALgAECgcJBwAAAA==.',
['術女']='術女依旧窈窕:BAAALgAECgYJDwAAAA==.',
['術朲']='術朲獸士:BAAALgAECgcJCgAAAA==.',
['裁决']='裁决使艾露妮:BAAALgAECgQJCQAAAA==.',
['试试']='试试:BAAALgADCgEJAQAAAA==.',
['诡术']='诡术:BAAALgADCgYJBgAAAA==.',
['诺诺']='诺诺罗亚丶:BAAALgAECgYJCQAAAA==.',
['谁敷']='谁敷衍了青春:BAAALgADCgEJAgAAAA==.',
['贺强']='贺强:BAAALgADCgcJCAAAAA==.',
['躺着']='躺着脑垫波:BAAALgAECgEJAQAAAA==.',
['远远']='远远:BAAALgAECgMJBAAAAA==.',
['逢敌']='逢敌必亮剑:BAAALgADCgUJBgAAAA==.',
['都鸡']='都鸡波哥们儿:BAAALgAECgEJAgAAAA==.',
['锦瑟']='锦瑟迷:BAAALgAECgEJAQAAAA==.',
['阿瑞']='阿瑞斯洋葱头:BAABLgAFFH8FAAIEAAMJ0w66KADTAAAEAAMJ0w66KADTAAAAAA==.',
['隐居']='隐居青楼:BAAALgAFFAIJAgAAAA==.',
['雷声']='雷声普化:BAAALgAECgIJAgAAAA==.',
['霍格']='霍格沃茨肄业:BAAALgAECgYJEQAAAA==.',
['霸气']='霸气虚幻哥:BAAALgAECgMJAwAAAA==.',
['鱼乐']='鱼乐不乐:BAABLgAFFH8GAAMGAAIJ2CDsCADEAAAGAAIJ2CDsCADEAAALAAEJ0wHMJQBGAAAAAA==.',
['鱼柒']='鱼柒:BAAALgAFFAMJAwAAAA==.',
['麻辣']='麻辣菟头丶:BAAALgAECgYJDQAAAA==.',
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
