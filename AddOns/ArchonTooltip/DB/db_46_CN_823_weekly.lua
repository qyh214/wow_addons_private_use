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

local lookup = {'Rogue-Subtlety','DeathKnight-Unholy','Warlock-Demonology','Warlock-Affliction','Evoker-Preservation','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-Marksmanship','Warrior-Fury','Warrior-Arms','Warlock-Destruction','Priest-Discipline','Druid-Balance','Priest-Holy','Paladin-Holy','Paladin-Retribution','Mage-Frost','Unknown-Unknown','Monk-Windwalker','Monk-Mistweaver','Hunter-BeastMastery','Monk-Brewmaster','DeathKnight-Blood',}
local provider = {region='CN',realm='血牙魔王',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aibe:BAAALgAECgQJBAAAAA==.Airstream:BAAALgAECgEJAQAAAA==.',
As='Astrea:BAAALgAFFAIJAwAAAA==.Asukaa:BAAALgAECgYJCgAAAA==.',
At='Atlatar:BAAALgAECgcJBwAAAA==.',
Bi='Billyzhang:BAAALgAECgYJBgAAAA==.',
Ca='Calvinkwan:BAAALgAECgQJAwAAAA==.',
Co='Coca:BAAALgAECgkJCAAAAA==.',
Da='Darknesskin:BAAALgAECgUJBQAAAA==.Davidzhuo:BAAALgAECgQJBgAAAA==.',
De='Devara:BAAALgADCgkJCAAAAA==.',
El='Elfknight:BAAALgAFFAEJAQAAAA==.',
Fi='Firenze:BAABLgAECn8fAAIBAAgJgx/3CwDXAgABAAgJgx/3CwDXAgAAAA==.',
Ga='Gadget:BAAALgAFFAMJBAAAAA==.',
Je='Jeangrey:BAAALgAECgMJAwAAAA==.',
Ld='Ldeathknight:BAAALgAECgYJAgAAAA==.',
Li='Lililala:BAAALgADCgUJBQAAAA==.',
Mi='Mione:BAABLgAFFH8GAAICAAYJ6xcjAQC6AQACAAYJ6xcjAQC6AQAAAA==.',
No='Notleaving:BAACLgAFFH8MAAIDAAQJrxZ7BwBXAQADAAQJrxZ7BwBXAQAuAAQKfxUAAwMACAkoHZ0yAEECAAMABwkoHZ0yAEECAAQAAQkAALIiAGcAAAAA.',
Pa='Patchouli:BAAALgAFFAIJBAABLgAFFAIJBQAFAGwiAA==.',
Sa='Sacredlight:BAAALgADCgcJBwAAAA==.Sampdoria:BAAALgAECgQJBAAAAA==.',
Sh='Shielder:BAAALgAECgQJBAAAAA==.',
Ti='Titansnova:BAAALgAECggJDgAAAA==.',
Tp='Tproofd:BAAALgAECgEJAQAAAA==.Tproofsm:BAAALgAFFAEJAQAAAA==.',
Va='Vampirotica:BAAALgAECgIJBAAAAA==.',
Wa='Warxx:BAAALgAECgcJBwAAAA==.',
['一程']='一程不冉:BAAALgAECgIJAgAAAA==.',
['一言']='一言不合:BAAALgAECgEJAQAAAA==.',
['万恶']='万恶海大胖:BAAALgADCgUJBQAAAA==.',
['万物']='万物生:BAAALgAECgYJCgAAAA==.',
['三加']='三加五德二:BAAALgAECgIJAQAAAA==.',
['三只']='三只熊的衣架:BAAALgAECgEJAgAAAA==.',
['三角']='三角初华:BAAALgAECgQJBAAAAA==.',
['下身']='下身丨微微凉:BAAALgAECgMJBAAAAA==.',
['不会']='不会就消费:BAAALgAECgUJBwAAAA==.',
['不够']='不够灬温柔:BAAALgAECgkJCgAAAA==.',
['不小']='不小心复活了:BAAALgAECgUJBQAAAA==.',
['丑奴']='丑奴儿:BAAALgADCgEJAQAAAA==.',
['中路']='中路对狙:BAAALgADCgcJBwAAAA==.',
['丿儸']='丿儸丶煞丨:BAAALgAECgMJAwAAAA==.',
['丿猎']='丿猎手丶儸刹:BAAALgAECgIJAwAAAA==.',
['九怒']='九怒汉:BAAALgAECgYJDQAAAA==.',
['乱一']='乱一咪一咪:BAAALgAECgIJAgAAAA==.',
['乱二']='乱二咪二咪:BAAALgAECgMJAwAAAA==.',
['二度']='二度被害:BAAALgADCgEJAQAAAA==.',
['二月']='二月十二:BAAALgADCgEJAQAAAA==.',
['二队']='二队術爺:BAAALgADCgQJBQAAAA==.',
['亚森']='亚森江:BAAALgAECgIJAgAAAA==.',
['人小']='人小子巴大:BAAALgAFFAMJBAAAAA==.',
['以德']='以德不悔:BAAALgAECgEJAQAAAA==.以德为仙:BAAALgAECgcJCwAAAA==.',
['仰扬']='仰扬:BAAALgADCgcJBwAAAA==.',
['伊利']='伊利但:BAAALgAECgIJBQAAAA==.',
['休宁']='休宁:BAAALgAECgIJBQAAAA==.',
['伸缩']='伸缩自如的愛:BAAALgAFFAEJAQAAAA==.',
['佛剣']='佛剣分說:BAAALgAECgIJAgAAAA==.',
['保安']='保安来消费:BAAALgAECgEJAQAAAA==.',
['俺们']='俺们村我最帅:BAAALgAECgMJAgAAAA==.',
['倾呈']='倾呈:BAAALgAFFAEJAQAAAA==.',
['先生']='先生很有范儿:BAAALgADCgIJAgAAAA==.',
['光是']='光是遇见你:BAAALgAECgIJBAAAAA==.',
['光火']='光火啊:BAAALgAFFAEJAQAAAQ==.',
['光能']='光能使者:BAAALgAFFAIJBAAAAA==.',
['八十']='八十一个壮汉:BAAALgAECgMJAwAAAA==.',
['公富']='公富胸猫:BAAALgAFFAEJAQAAAA==.',
['六寸']='六寸竹叶青:BAABLgAFFH8FAAIFAAIJbCLlDwDOAAAFAAIJbCLlDwDOAAAAAA==.',
['六道']='六道欧王:BAABLgAECn8aAAMGAAYJJhkwIAC8AQAGAAYJJhkwIAC8AQAHAAYJ4AjxKwDyAAAAAA==.',
['兽魔']='兽魔者:BAAALgAECgEJAQAAAA==.',
['再见']='再见爱丽丝:BAAALgAECgQJBAAAAA==.',
['冥凰']='冥凰:BAAALgAECgYJCgAAAA==.',
['冰释']='冰释:BAAALgAECgQJBAAAAA==.',
['冷月']='冷月丨娃娃:BAAALgAECgEJAgAAAA==.',
['冷韵']='冷韵幽香:BAAALgAECgUJCQAAAA==.',
['凌棂']='凌棂零:BAAALgAECgEJAgAAAA==.',
['凝柠']='凝柠:BAAALgAECgYJBgAAAA==.',
['刀师']='刀师傅:BAAALgAFFAMJAwAAAA==.',
['别逼']='别逼我变身:BAAALgADCgEJAQAAAA==.',
['十个']='十个惩戒骑:BAAALgAFFAMJBAAAAA==.',
['十使']='十使:BAAALgAECgYJCQAAAA==.',
['南山']='南山樛木:BAABLgAFFH8GAAIIAAYJcQz2AACXAQAIAAYJcQz2AACXAQAAAA==.',
['南飞']='南飞:BAAALgAECgMJBQAAAA==.',
['卡西']='卡西莫铎:BAAALgAECgYJBwAAAA==.',
['卿阳']='卿阳:BAAALgAECgEJAQAAAA==.',
['叄嫂']='叄嫂:BAAALgAECgQJBwAAAA==.',
['双刀']='双刀贼:BAAALgAECgYJCAAAAA==.',
['只是']='只是寂寞:BAAALgAECgUJBQAAAA==.',
['叫兽']='叫兽:BAABLgAECn8XAAMJAAcJHx4NIwA9AgAJAAcJrBwNIwA9AgAKAAIJRg0YMAB2AAAAAA==.',
['叮的']='叮的萌萌哒:BAAALgAECgEJAQAAAA==.',
['叶落']='叶落纷纷:BAAALgAECgkJCQAAAA==.',
['吃莽']='吃莽莽的怪兽:BAAALgAECgIJAgAAAA==.',
['吉伯']='吉伯:BAAALgAECgYJCQAAAA==.',
['吉尔']='吉尔伯特火刃:BAAALgAECgEJAgAAAA==.',
['咎儿']='咎儿:BAAALgAECgQJAwAAAA==.',
['咪咪']='咪咪猫:BAABLgAECn8RAAQEAAcJKhSvCwB/AQAEAAYJZhGvCwB/AQALAAUJmApTNQDhAAADAAIJgxVx6ACKAAAAAA==.',
['哈尼']='哈尼族:BAAALgAECgMJAwAAAA==.哈尼部落:BAAALgADCgUJBQAAAA==.',
['哈托']='哈托涅特:BAAALgAFFAMJBAAAAA==.',
['哟死']='哟死骑:BAAALgAECgYJDAAAAA==.',
['哦丶']='哦丶哈丶哟:BAAALgAECgUJCgAAAA==.',
['喵楽']='喵楽個咪:BAAALgAECgYJBwAAAA==.',
['埋伏']='埋伏你娃:BAAALgAECgIJAgAAAA==.',
['夏天']='夏天大魔王:BAACLgAFFH8KAAIMAAQJdxGxCQBEAQAMAAQJdxGxCQBEAQAuAAQKfxcAAgwABwlVHe4MAGoCAAwABwlVHe4MAGoCAAEuAAUUBgkVAA0A/xsA.夏天果果:BAAALgAECgkJCgAAAA==.',
['夜烨']='夜烨:BAAALgADCgcJCAAAAA==.',
['大乔']='大乔很翘:BAABLgAECn8XAAIJAAcJRBPXOgC6AQAJAAcJRBPXOgC6AQAAAA==.',
['大哥']='大哥来消费:BAAALgAECgYJBgAAAA==.',
['大脚']='大脚暧暧:BAAALgADCgYJBgAAAA==.',
['天丶']='天丶涯:BAAALgAECgYJCQAAAA==.',
['天启']='天启元年:BAAALgAECgcJBgAAAA==.',
['天堂']='天堂之靉:BAAALgAECgQJBQAAAA==.',
['天沐']='天沐:BAAALgAECgEJAQAAAA==.',
['天网']='天网恢恢:BAAALgADCgUJBQAAAA==.',
['天蓝']='天蓝色的外卖:BAAALgAECgYJBgAAAA==.',
['天青']='天青似禅绵:BAAALgAECgQJBAAAAA==.天青惹寂寥:BAAALgAECgcJCwAAAA==.天青染萧索:BAAALgAECgUJBQAAAA==.',
['太杀']='太杀鸡:BAABLgAECn8YAAIHAAgJaxjbJgBqAgAHAAgJaxjbJgBqAgAAAA==.',
['太阳']='太阳丶:BAAALgADCgUJBQAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8IAAIMAAQJghWoBwBhAQAMAAQJghWoBwBhAQAAAA==.',
['子灬']='子灬不語:BAABLgAFFH8FAAIOAAMJ9BJ7BQDNAAAOAAMJ9BJ7BQDNAAAAAA==.',
['子钲']='子钲:BAAALgAFFAIJAgAAAA==.',
['安东']='安东尼高壮:BAAALgAFFAIJBAAAAA==.',
['安格']='安格斯厚牛堡:BAAALgAECgYJCAAAAA==.',
['寄居']='寄居蟹十三:BAAALgAFFAQJAQAAAA==.',
['富贵']='富贵儿:BAAALgAECgMJAwAAAA==.',
['寳寳']='寳寳:BAAALgAECgEJAgAAAA==.',
['小小']='小小的天:BAAALgAFFAIJAgABLgAFFAYJCgACAGAhAA==.',
['小惡']='小惡魔丶:BAAALgAECgQJBwAAAA==.',
['小迢']='小迢迢:BAAALgAECgMJAwAAAA==.',
['小饼']='小饼啊:BAAALgAECgEJAQAAAA==.',
['就想']='就想抓个熊德:BAAALgAECgEJAgAAAA==.',
['山海']='山海:BAAALgAECgYJBgAAAA==.',
['巭大']='巭大师:BAAALgAECgIJAQAAAA==.',
['布谷']='布谷虫:BAAALgAECgQJBAAAAA==.',
['幻影']='幻影可乐:BAAALgAECgQJAwAAAA==.',
['幽冥']='幽冥:BAAALgAECgYJBwAAAA==.幽冥猎手:BAAALgAFFAEJAgAAAA==.',
['幽灵']='幽灵丸子:BAAALgAECgYJDQAAAA==.幽灵贞子:BAAALgAECgQJCwAAAA==.',
['庸医']='庸医治大病:BAAALgADCgYJBgABLgAECggJGAAHAGsYAA==.',
['弗莱']='弗莱娜:BAAALgADCgYJBgAAAA==.',
['当真']='当真就好:BAAALgAECgMJAwAAAA==.',
['徐狗']='徐狗蛋:BAAALgAECgYJBgAAAA==.',
['心里']='心里的年华:BAAALgAECgUJBgAAAA==.',
['忍野']='忍野忍:BAAALgAECgYJBQAAAA==.',
['忧郁']='忧郁的超哥:BAAALgAECgYJCQAAAA==.',
['快说']='快说你是哈别:BAAALgAECgQJBwAAAA==.',
['念霞']='念霞:BAAALgAECgEJAQAAAA==.',
['恋上']='恋上下雪天丶:BAAALgAECgUJBQAAAA==.恋上云的猪:BAAALgAECgEJAQAAAA==.',
['惡狼']='惡狼:BAAALgADCgMJAwAAAA==.',
['惩戒']='惩戒之光:BAAALgAECgEJAQAAAA==.',
['感电']='感电的大牙:BAAALgAECgEJAgAAAA==.',
['我丶']='我丶犒:BAAALgADCgEJAQAAAA==.',
['我在']='我在哪我是谁:BAAALgADCgcJAQAAAA==.',
['我是']='我是胖胖:BAAALgAECgUJBwAAAA==.',
['我真']='我真强:BAAALgAECgIJAgAAAA==.',
['戒骄']='戒骄戒躁:BAAALgAECgMJAgAAAA==.',
['执念']='执念纯情:BAAALgAECgEJAQAAAA==.',
['拒绝']='拒绝战复丶:BAAALgADCgMJAwAAAA==.拒绝无敌丶:BAACLgAFFH8JAAMPAAUJ8AwPDAAeAQAPAAQJTwgPDAAeAQAQAAMJHhvxEgCyAAAuAAQKfxcAAw8ACAnRFrsmAPQBAA8ACAnRFrsmAPQBABAABwnCGHJTAOcBAAAA.',
['持剑']='持剑今朝丶:BAAALgAECgYJBgAAAA==.',
['改日']='改日好吗:BAAALgAECgcJEwAAAA==.',
['斩神']='斩神小白:BAAALgAFFAEJAQAAAA==.',
['无痕']='无痕:BAAALgAECgYJBgAAAA==.',
['无糖']='无糖冰美式:BAAALgAECgcJBwAAAA==.',
['昂博']='昂博丽涡啵:BAAALgAECgcJEQAAAA==.',
['明明']='明明特木耳儿:BAAALgAECgYJCwAAAA==.',
['星空']='星空下的眷恋:BAAALgAECgMJAwAAAA==.',
['春日']='春日野比穹:BAAALgADCgEJAQAAAA==.',
['是可']='是可可呀:BAAALgAECgUJAQAAAA==.',
['普西']='普西芬妮:BAAALgADCgEJAQAAAA==.',
['晴钰']='晴钰雯:BAAALgADCgQJBAAAAA==.',
['曼悠']='曼悠悠:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经秒杀只鸡:BAAALgADCgUJBQAAAA==.',
['最再']='最再游记:BAABLgAECn8ZAAIRAAgJ5x/6JgDXAgARAAgJ5x/6JgDXAgAAAA==.',
['月亮']='月亮丨咕咕兽:BAAALgAFFAQJAgAAAA==.',
['月洸']='月洸:BAAALgAECgYJBAAAAA==.',
['月落']='月落挽歌:BAAALgAFFAMJAwAAAA==.',
['未云']='未云何龙:BAAALgAFFAEJAQAAAA==.',
['李丨']='李丨老师:BAAALgAFFAEJAQAAAA==.',
['果冻']='果冻嘻嘻:BAAALgADCgUJBQAAAA==.',
['果汁']='果汁:BAAALgAECgEJAQAAAA==.',
['枫城']='枫城太子:BAAALgADCgcJCwAAAA==.',
['格拉']='格拉斯赤牙:BAAALgAECgMJAwAAAA==.',
['格瑞']='格瑞特豆:BAACLgAFFH8OAAMKAAQJBB7OAAB9AQAKAAQJBB7OAAB9AQAJAAIJUg5DGQCkAAAuAAQKfxgAAwkABwlTIq0vAPEBAAkABgndH60vAPEBAAoAAwkrINgKAOIAAAAA.',
['桃谷']='桃谷小烟鬼:BAAALgAECgYJDAAAAA==.',
['梁文']='梁文音爱小磊:BAAALgAECgEJAgAAAA==.',
['欣欣']='欣欣:BAAALgADCgcJCQAAAA==.',
['正经']='正经小伙:BAAALgAECgEJAQAAAA==.',
['武樂']='武樂個僧:BAAALgAECgIJAgAAAA==.',
['比利']='比利丶海灵顿:BAAALgAECgUJBgAAAA==.',
['毛毛']='毛毛虫会咬人:BAAALgADCgUJBQAAAA==.毛毛虫菠萝:BAAALgAECgYJBwAAAA==.',
['水货']='水货奶妈:BAAALgAECgQJBAAAAA==.',
['汕海']='汕海:BAABLgAFFH8IAAICAAQJMwwHCwA4AQACAAQJMwwHCwA4AQAAAA==.',
['汤圆']='汤圆煮馄饨:BAAALgADCgQJBAAAAA==.',
['法克']='法克嗳可嘶:BAAALgAECgYJBwAAAA==.',
['泠泠']='泠泠月上风:BAAALgAECgUJBQAAAA==.',
['泡泡']='泡泡冲冲:BAAALgAECgUJAwAAAA==.',
['波希']='波希米亚大公:BAACLgAFFH8KAAIOAAQJzhzHAQBfAQAOAAQJzhzHAQBfAQAuAAQKfxYAAg4ABwnlIV4NAIICAA4ABwnlIV4NAIICAAAA.',
['洐泠']='洐泠:BAAALgAECgYJBgABLgAFFAIJAgASAAAAAA==.',
['洛欧']='洛欧:BAACLgAFFH8LAAMTAAMJKyR4AgA2AQATAAMJKyR4AgA2AQAUAAEJihM3FQBSAAAuAAQKfxgAAhMACAnqHa4IAO4CABMACAnqHa4IAO4CAAAA.',
['洛汕']='洛汕:BAAALgADCgcJFAAAAA==.',
['流氓']='流氓名羽:BAAALgAECgYJDAAAAA==.',
['海蓝']='海蓝水晶:BAAALgADCgYJBgAAAA==.',
['淡觴']='淡觴:BAAALgAECgcJCwAAAA==.',
['溜溜']='溜溜柒:BAAALgAECgEJAQAAAA==.',
['演员']='演员已就位:BAAALgAFFAEJAQAAAA==.',
['潇湘']='潇湘曲丶夜语:BAAALgAECgEJAQAAAA==.',
['灬丶']='灬丶土豆:BAAALgADCgUJBQAAAA==.',
['灬小']='灬小灬千灬:BAAALgAECgYJBgAAAA==.',
['灬辣']='灬辣辣灬:BAABLgAFFH8FAAIHAAQJ6iChCQCQAQAHAAQJ6iChCQCQAQABLgAFFAUJCwAHAF0kAA==.',
['灯等']='灯等灯等灯:BAAALgAECgYJCAAAAA==.',
['灵魂']='灵魂乌鸦:BAAALgAECgUJBQAAAA==.',
['灾厄']='灾厄:BAAALgAECgcJBwAAAA==.',
['炽天']='炽天使之翼:BAAALgAECgEJAQAAAA==.',
['热依']='热依汗古丽:BAAALgAECgQJBAAAAA==.',
['煮飯']='煮飯宅男丶:BAAALgAECgUJEQAAAA==.',
['燃烧']='燃烧军团爪牙:BAAALgADCgYJBgAAAA==.',
['牛奶']='牛奶花生丶:BAAALgAECgcJCQAAAA==.',
['牛牛']='牛牛来消费:BAAALgAECgYJBwAAAA==.',
['狂怒']='狂怒的矮子:BAAALgAECgEJAQAAAA==.',
['狂暴']='狂暴战:BAAALgADCgMJAwAAAA==.',
['狩猪']='狩猪歹徒:BAAALgAECgEJAQAAAA==.',
['猎手']='猎手来消费:BAAALgAECgYJDAAAAA==.',
['猛到']='猛到不行:BAAALgADCgcJBwAAAA==.',
['猪熊']='猪熊:BAAALgAECgUJBQAAAA==.',
['玛露']='玛露西迩:BAAALgAECgEJAQAAAA==.',
['瓦渣']='瓦渣部落:BAAALgAECgYJEAAAAA==.',
['甜到']='甜到忧伤:BAAALgAECgEJAQAAAA==.',
['白山']='白山道长:BAAALgADCgMJAwAAAA==.',
['皓雪']='皓雪落:BAAALgADCgIJAwAAAA==.',
['看一']='看一看瞧一瞧:BAAALgAECgIJAwAAAA==.',
['破法']='破法丨逆天:BAAALgADCgcJBwAAAA==.',
['祈尘']='祈尘如夢:BAAALgADCgIJAgAAAA==.',
['神圣']='神圣丶之光:BAAALgAECgkJEAAAAA==.',
['神秘']='神秘挑战者:BAAALgAECgIJAgAAAA==.',
['移动']='移动的大肉包:BAAALgADCgYJCQAAAA==.',
['箭术']='箭术训练师:BAAALgAFFAEJAQAAAA==.',
['精灵']='精灵小南:BAABLgAFFH8FAAIDAAIJBBThMACxAAADAAIJBBThMACxAAAAAA==.',
['糖球']='糖球:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门术:BAAALgAFFAIJAwAAAA==.',
['紫川']='紫川夜一:BAAALgADCgcJBwAAAA==.',
['纯爱']='纯爱牛牛:BAABLgAFFH8HAAMIAAQJgBXzDABOAQAIAAQJ5xTzDABOAQAVAAEJZh18GgBbAAAAAA==.',
['纱织']='纱织:BAAALgAECgMJBAAAAA==.',
['绘梨']='绘梨衣:BAAALgAECgMJAwAAAA==.',
['给文']='给文明以岁月:BAAALgADCgMJAwAAAA==.',
['绫波']='绫波丽零:BAAALgADCgIJAgAAAA==.',
['署妲']='署妲己:BAAALgADCgUJBQAAAA==.',
['美不']='美不美看大褪:BAAALgADCgMJAgAAAA==.',
['羽棂']='羽棂丶:BAAALgADCgMJAwAAAA==.',
['翩翩']='翩翩舞:BAAALgAFFAMJBAAAAA==.',
['老冀']='老冀:BAAALgAECgcJBgAAAA==.',
['老牛']='老牛上了天堂:BAAALgAECgEJAwAAAA==.老牛在天堂:BAAALgADCgIJAgAAAA==.',
['聖域']='聖域骑士:BAAALgAECgEJAQAAAA==.',
['肥不']='肥不肥看腰围:BAAALgADCgQJBAAAAA==.',
['艾露']='艾露恩的宠儿:BAAALgAECgMJAwAAAA==.',
['芣偷']='芣偷腥的猫:BAAALgADCgUJBQAAAA==.',
['苍佬']='苍佬湿:BAABLgAFFH8IAAIMAAMJBQ8uDgDpAAAMAAMJBQ8uDgDpAAAAAA==.',
['苏我']='苏我屠自古:BAAALgAECgEJAQAAAA==.',
['苗子']='苗子二代:BAAALgAECgYJEgAAAA==.',
['若是']='若是微凉:BAAALgAECgYJBgAAAA==.',
['茂木']='茂木夏树:BAAALgAECgEJAQAAAA==.',
['草际']='草际自浮鹅鸭:BAAALgADCgEJAQAAAA==.',
['莨劫']='莨劫:BAAALgAECgEJAQABLgAFFAIJAgASAAAAAA==.',
['莫格']='莫格莱昵:BAAALgAFFAMJAwAAAA==.',
['萨勒']='萨勒芬妮:BAAALgAECggJCAABLgAFFAkJHwAUAI4YAA==.',
['蒜鸟']='蒜鸟蒜鸟:BAAALgAECgMJAwAAAA==.',
['蓝枫']='蓝枫秋天:BAAALgAECgYJBgAAAA==.蓝枫秋筱:BAAALgAECgYJDwAAAA==.',
['蓝皮']='蓝皮骑士:BAAALgAECgIJAgAAAA==.',
['蓝血']='蓝血蛇:BAABLgAFFH8HAAIMAAMJoyItDAATAQAMAAMJoyItDAATAQAAAA==.',
['蛐蛐']='蛐蛐蛇:BAAALgAECgYJCgAAAA==.',
['蜻蜓']='蜻蜓小队长:BAAALgAECgEJAQAAAA==.',
['蟒洋']='蟒洋芋丶:BAAALgAECgYJBgAAAA==.',
['血影']='血影猎手:BAAALgAFFAMJBAAAAA==.',
['血染']='血染星辰:BAAALgADCgYJCgAAAA==.',
['血萧']='血萧:BAAALgADCgEJAQAAAA==.',
['袁华']='袁华的三叉戟:BAAALgADCgEJAQAAAA==.',
['西横']='西横塘杀牛的:BAAALgAECgUJBQAAAA==.',
['西门']='西门出来吹风:BAAALgAECgcJBwAAAA==.',
['观音']='观音桥白酒王:BAABLgAFFH8FAAMTAAQJqwatCACKAAATAAQJYgWtCACKAAAWAAEJoAm3JwA6AAAAAA==.',
['誰心']='誰心一梦:BAAALgADCgIJAQAAAA==.',
['调灬']='调灬情:BAAALgAECgYJBgAAAA==.',
['赠送']='赠送的芙蓉王:BAAALgAFFAMJAwAAAA==.',
['赤星']='赤星小嘚嘚:BAAALgAECgEJAgAAAA==.',
['赵小']='赵小小丶:BAAALgAECgEJAQAAAA==.',
['跃动']='跃动冲锋:BAAALgAECgUJBQAAAA==.',
['輪佪']='輪佪獨斷:BAAALgAECgkJEAABLgAFFAUJBQAGAP4TAA==.',
['迎风']='迎风的雏菊:BAAALgAECgUJBgAAAA==.',
['进击']='进击的神棍德:BAAALgADCgUJBQAAAA==.进击的神棍法:BAAALgAECgEJAQAAAA==.',
['郎丶']='郎丶总:BAAALgAFFAMJBAAAAA==.',
['酒馆']='酒馆掌柜:BAAALgAECgMJAwABLgAFFAMJBAASAAAAAA==.',
['钝角']='钝角乄:BAAALgAFFAIJBAAAAA==.',
['锐雯']='锐雯:BAAALgAECgEJAQAAAA==.',
['闪电']='闪电兔:BAAALgAFFAIJAwABLgAFFAQJDgAKAAQeAA==.',
['阿凌']='阿凌要努力:BAAALgAECgYJBwAAAA==.',
['阿曼']='阿曼尼影殇:BAAALgAECgYJEwAAAA==.',
['阿道']='阿道夫希粑粑:BAAALgADCgcJCwAAAA==.',
['阿里']='阿里克南尔:BAAALgAECgkJCQAAAA==.',
['阿隆']='阿隆索斯:BAAALgAFFAMJAwAAAA==.',
['陈平']='陈平安丶:BAABLgAFFH8JAAMCAAUJAxdSEgBYAQACAAQJAxdSEgBYAQAXAAEJAACXFABNAAAAAA==.',
['隔壁']='隔壁小李:BAAALgAECgEJAQAAAA==.',
['雅赫']='雅赫梵:BAAALgAECgYJCQAAAA==.',
['雕鹗']='雕鹗之志:BAAALgAECgQJCQAAAA==.',
['霜狼']='霜狼:BAAALgADCgUJBQAAAA==.',
['霧里']='霧里:BAAALgAECgcJCwAAAA==.',
['预制']='预制板:BAAALgAECgMJBgAAAA==.',
['领域']='领域丨猎爺:BAAALgAECgYJBwAAAA==.',
['颜良']='颜良文丑:BAAALgAECgUJBQAAAA==.',
['风里']='风里来雨里去:BAAALgAECgEJAQAAAA==.',
['饭猪']='饭猪:BAAALgADCgMJBAAAAA==.',
['香辣']='香辣龙肉酱:BAAALgAFFAMJAwAAAA==.',
['麦蠢']='麦蠢蠢:BAABLgAECn8aAAIRAAYJGhm5gwDKAQARAAYJGhm5gwDKAQAAAA==.',
['龙虾']='龙虾片:BAAALgAECgIJAgAAAA==.',
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
