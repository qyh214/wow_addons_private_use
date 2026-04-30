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

local lookup = {'Mage-Frost','Druid-Balance','Warlock-Demonology','Unknown-Unknown','Druid-Guardian','Hunter-BeastMastery','Shaman-Restoration','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Unholy','Warrior-Protection','Monk-Brewmaster','Hunter-Marksmanship','Paladin-Retribution','Paladin-Holy','Druid-Feral','Druid-Restoration','Warrior-Fury','Warrior-Arms','Priest-Holy','Rogue-Subtlety','DeathKnight-Frost','DeathKnight-Blood',}
local provider = {region='CN',realm='风暴之眼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abscess:BAACLgAFFH8FAAIBAAQJKA6bHABZAQABAAQJKA6bHABZAQAuAAQKfxUAAgEACAnnEoloAAUCAAEACAnnEoloAAUCAAAA.',
Al='Alloyt:BAABLgAFFH8FAAICAAMJrwVdEADbAAACAAMJrwVdEADbAAAAAA==.',
Ar='Arym:BAAALgAECgYJCQAAAA==.',
Ba='Baohanjie:BAABLgAFFH8JAAIBAAQJcgapGgDtAAABAAQJcgapGgDtAAAAAA==.',
Bl='Blueblue:BAAALgAECgYJDAAAAA==.',
Br='Brynhildr:BAABLgAFFH8GAAIDAAIJag9hHwCrAAADAAIJag9hHwCrAAAAAA==.',
Ch='Choop:BAAALgADCgUJBQAAAA==.',
De='Decembers:BAAALgAECgEJAQAAAA==.',
Em='Emotions:BAAALgAECgYJBAAAAA==.',
Er='Erdtree:BAACLgAFFH8JAAIBAAQJPxN9GwBdAQABAAQJPxN9GwBdAQAuAAQKfxYAAgEACAkXHgsoANICAAEACAkXHgsoANICAAAA.',
Gr='Green:BAAALgAECgYJDAAAAA==.',
He='Heac:BAAALgADCgEJAQAAAA==.',
Jo='Journey:BAAALgAECgYJBAAAAA==.',
Ky='Kyubinaruto:BAAALgADCgcJCQAAAA==.',
Li='Light:BAAALgAECgYJCgAAAA==.',
Ly='Lyu:BAAALgAECgEJAQAAAA==.',
Mi='Miniblack:BAAALgAECgYJBgAAAA==.',
Ol='Oligeck:BAAALgAECgIJAgAAAA==.',
On='One:BAAALgAECgkJCQAAAA==.',
Pr='Prhinia:BAAALgAECgUJBgABLgAFFAMJAwAEAAAAAA==.',
Ra='Raichu:BAAALgADCgkJCgAAAA==.',
Re='Reei:BAAALgADCgEJAQAAAA==.Reirei:BAAALgADCgEJAQAAAA==.',
Sa='Samch:BAAALgAECgkJCQABLgAFFAQJBAAEAAAAAA==.',
Ve='Ventose:BAAALgAECgEJAQAAAA==.',
We='Wentasy:BAAALgAECgEJAQAAAA==.',
Ye='Yellow:BAAALgAECgYJCwAAAA==.',
['一个']='一个名字而已:BAAALgAECgYJCgAAAA==.',
['一朵']='一朵野花:BAAALgAECgMJAwAAAA==.',
['一点']='一点都不呆:BAAALgAECgYJBgAAAA==.',
['一百']='一百多个圣骑:BAAALgAECgIJBAABLgAFFAEJAQAEAAAAAA==.',
['一辉']='一辉的精灵僧:BAAALgAFFAMJAwAAAA==.',
['一醉']='一醉自救:BAAALgAECgEJAQAAAA==.',
['万中']='万中无一:BAAALgAECgEJBAAAAA==.',
['万俟']='万俟死骑:BAAALgAECgYJEAAAAA==.万俟猎手:BAAALgAECgYJDwAAAA==.',
['上古']='上古神德:BAAALgADCgIJAgAAAA==.',
['不错']='不错过:BAABLgAECn8XAAMFAAkJaBltBACuAgAFAAkJeRhtBACuAgACAAcJNhk9IQDzAQAAAA==.',
['丨带']='丨带领主:BAAALgADCgIJAgAAAA==.',
['丶佩']='丶佩罗罗奇诺:BAAALgAECgcJEwAAAA==.',
['丶射']='丶射部丨落丶:BAABLgAFFH8IAAIGAAIJKR2NEADEAAAGAAIJKR2NEADEAAAAAA==.',
['丶起']='丶起司:BAAALgAFFAIJAwAAAA==.',
['丶退']='丶退后:BAAALgAECgQJBAAAAA==.',
['主演']='主演瞟苍被抓:BAAALgAECgkJAQAAAA==.',
['乄刃']='乄刃乄:BAAALgAECgEJAQAAAA==.',
['么么']='么么可乐熊:BAAALgAECgYJCwAAAA==.',
['乌瑞']='乌瑞恩丶豆豆:BAAALgADCgUJBQAAAA==.',
['乌瑟']='乌瑟厼:BAAALgAECgIJBQAAAA==.',
['乔凝']='乔凝心:BAAALgAECgcJCAAAAA==.',
['乔幺']='乔幺叔:BAAALgAECgQJBgAAAA==.',
['五幺']='五幺二零:BAAALgADCgMJAQAAAA==.',
['五色']='五色土豆泥:BAAALgAECgUJCAAAAA==.',
['亚瑟']='亚瑟碎骨:BAAALgAECgEJAQAAAA==.',
['人间']='人间清醒:BAABLgAFFH8KAAIHAAQJPB4cBABNAQAHAAQJPB4cBABNAQAAAA==.',
['仪调']='仪调泷:BAAALgADCgIJAgAAAA==.',
['仰天']='仰天听雨:BAAALgAECgEJAQABLgAECgIJAgAEAAAAAA==.仰天怒视:BAAALgAECgUJBQABLgAECgIJAgAEAAAAAA==.',
['伊尔']='伊尔莎:BAAALgAECgYJBgAAAA==.',
['伤很']='伤很痛:BAAALgAECgEJAQAAAA==.',
['佑赫']='佑赫丷尐米粒:BAAALgAECgEJAgAAAA==.',
['体型']='体型胖:BAAALgAFFAQJBAAAAA==.',
['何曾']='何曾畏惧:BAAALgAECgIJBAAAAA==.',
['信仰']='信仰圣光丷:BAAALgAECgQJBQAAAA==.',
['倚竹']='倚竹抚琴:BAAALgAFFAEJAgAAAA==.',
['克丽']='克丽丝丶缇娜:BAAALgAECgYJBgAAAA==.',
['兰娜']='兰娜瑟尔灬:BAAALgAECgcJDgAAAA==.',
['再来']='再来一发少年:BAAALgAECgcJDQAAAA==.',
['农场']='农场主:BAAALgAECggJCAAAAA==.',
['冷将']='冷将:BAAALgAECgEJAQAAAA==.',
['凌刃']='凌刃:BAAALgAFFAIJAgAAAA==.',
['凸好']='凸好好凸:BAAALgAECgIJAwAAAA==.',
['凸宝']='凸宝宝凸:BAAALgAECgYJBwAAAA==.',
['凸愛']='凸愛愛凸:BAAALgAECgIJAgAAAA==.',
['凸白']='凸白白凸:BAAALgAECgQJBQAAAA==.',
['刘备']='刘备字亦菲:BAAALgAECgQJBwAAAA==.',
['勿念']='勿念花荼:BAAALgAECgEJAQAAAA==.',
['十一']='十一天:BAAALgADCgEJAQAAAA==.',
['十罒']='十罒:BAAALgAECgIJAgAAAA==.',
['半夏']='半夏烟雨丶:BAAALgAECgEJAQAAAA==.半夏醉流年:BAAALgAECgYJBgAAAA==.',
['双梗']='双梗杠上花:BAAALgAFFAEJAQAAAA==.',
['叮叮']='叮叮猫儿:BAAALgADCgEJAQAAAA==.',
['可儿']='可儿必思嘟嘟:BAAALgAECgkJAQABLgAFFAcJBQABANIGAA==.',
['可然']='可然:BAAALgAECgYJDwAAAA==.',
['各种']='各种伤不起:BAAALgAECgEJAgAAAA==.',
['吙锅']='吙锅茄冰:BAAALgAECgQJBAAAAA==.',
['咔啦']='咔啦咪:BAAALgAECgYJCwAAAA==.',
['哈吉']='哈吉米八:BAAALgAECgkJDQAAAA==.哈吉米六:BAAALgAECgkJCwAAAA==.',
['啸熬']='啸熬浆糊:BAAALgAECgYJBwAAAA==.',
['善良']='善良的左慈:BAAALgAECgQJBAAAAA==.',
['喵汪']='喵汪叫:BAAALgAECgEJAQAAAA==.',
['嗨丶']='嗨丶莉妹:BAAALgAECgYJDgAAAA==.',
['嘘丶']='嘘丶亲亲:BAAALgAECgEJAQAAAA==.',
['四号']='四号大菜鸟:BAAALgAECggJCAAAAA==.',
['四界']='四界飞翔:BAAALgAECgYJBgAAAA==.',
['圆桌']='圆桌骑士:BAAALgAECgkJCQAAAA==.',
['圣丶']='圣丶殇:BAAALgADCgYJBgAAAA==.',
['圣光']='圣光大妹子:BAAALgAECgYJCwAAAA==.圣光大蹄子:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱的回忆:BAAALgAECgEJAQAAAA==.',
['坏天']='坏天气:BAAALgAECgkJEAAAAA==.',
['坚心']='坚心:BAAALgAECgYJBgAAAA==.',
['增的']='增的辉常牛逼:BAACLgAFFH8YAAIIAAYJthcsAwD5AQAIAAYJthcsAwD5AQAuAAQKfxgAAwgACQkYHrMNAJoCAAgACQnKHbMNAJoCAAkABAncHwgbAFkBAAEuAAUUBwkEAAQAAAAA.',
['壹骑']='壹骑当千乄奕:BAAALgAECgYJBwAAAA==.',
['夏约']='夏约冬至:BAAALgAECgYJDwAAAA==.',
['夜下']='夜下听风:BAAALgAECgcJDQAAAA==.',
['大锤']='大锤哐哐抡:BAAALgAECgkJCQABLgAFFAUJCQAKAGomAA==.',
['奶奶']='奶奶德:BAAALgAFFAEJAQAAAA==.',
['如莱']='如莱:BAAALgAECgkJEgAAAA==.',
['威少']='威少:BAAALgAECgEJAQAAAA==.',
['娇波']='娇波媚靥:BAAALgADCgEJAQAAAA==.',
['嬰兒']='嬰兒藍:BAAALgAECgEJAQAAAA==.',
['孙雯']='孙雯:BAAALgADCgEJAQAAAA==.',
['孤风']='孤风灬逐影:BAAALgAECgcJCQAAAA==.',
['宝宝']='宝宝不坏:BAABLgAECn8VAAILAAgJSxycCQB/AgALAAgJSxycCQB/AgAAAA==.宝宝坏:BAAALgAECgUJCwAAAA==.',
['宠物']='宠物院长丶熠:BAAALgADCgEJAQAAAA==.',
['射津']='射津:BAABLgAFFH8IAAIGAAMJDh7qBgAqAQAGAAMJDh7qBgAqAQAAAA==.',
['小华']='小华子:BAAALgAECggJEwAAAA==.',
['小奶']='小奶包:BAAALgAECgkJBQAAAA==.',
['小弱']='小弱江:BAAALgAECgUJBgAAAA==.',
['小泽']='小泽爱拉丝:BAAALgAECgYJCQAAAA==.',
['小灬']='小灬火苗:BAAALgAECgMJAwAAAA==.小灬魔王:BAAALgAECgQJBAAAAA==.',
['小爽']='小爽来了:BAAALgADCgEJAQAAAA==.',
['小猪']='小猪哥哥:BAAALgAECgcJEAAAAA==.',
['小童']='小童不怕死啊:BAAALgAECgEJAQAAAA==.',
['小蜜']='小蜜桃儿:BAAALgAECgYJBgAAAA==.',
['小逗']='小逗包:BAAALgAECgYJCAAAAA==.',
['山寨']='山寨德德:BAAALgAECgIJAgAAAA==.',
['山河']='山河无恙:BAAALgADCgEJAQAAAA==.',
['巧克']='巧克力深蓝:BAAALgADCgcJAgAAAA==.',
['帅萌']='帅萌萌:BAAALgADCgIJAgAAAA==.',
['希尔']='希尔瓦奈斯:BAAALgAECgcJDgAAAA==.',
['庄方']='庄方宜:BAABLgAFFH8WAAIMAAYJshJRAgDPAQAMAAYJshJRAgDPAQAAAA==.',
['弑无']='弑无魂:BAAALgAECgYJBgAAAA==.',
['当然']='当然是原谅她:BAAALgAFFAEJAQAAAA==.',
['彩梦']='彩梦:BAAALgADCgMJAwAAAA==.',
['德芙']='德芙千夜:BAAALgAECgMJBwAAAA==.',
['心术']='心术丶:BAAALgAFFAIJAgAAAA==.',
['怪妹']='怪妹崽:BAAALgAECgYJEAAAAA==.',
['惩戒']='惩戒之路:BAAALgAECgEJAgAAAA==.',
['想看']='想看大白兔吗:BAAALgAECgIJAgAAAA==.',
['愿圣']='愿圣光忽悠你:BAAALgAECgEJAQAAAA==.',
['我买']='我买你:BAAALgAECgYJCAABLgAECgYJDQAEAAAAAA==.',
['我刚']='我刚刚睡醒:BAAALgAFFAIJAgAAAA==.',
['我发']='我发现猎物了:BAABLgAFFH8HAAINAAUJ+RVMCACWAQANAAUJ+RVMCACWAQAAAA==.',
['我是']='我是小富婆:BAAALgAECgYJBgAAAA==.我是谁是我:BAAALgAECgEJAQAAAA==.',
['我来']='我来找长明:BAAALgAECgMJBgAAAA==.我来找鹏鹏:BAAALgAECgkJCQAAAA==.',
['我滴']='我滴个乖乖:BAAALgADCgMJAwAAAA==.',
['我爱']='我爱吃串串:BAAALgAECgIJAwAAAA==.我爱默默:BAAALgADCgIJAgAAAA==.',
['战丶']='战丶筱筱:BAAALgAECgYJCgAAAA==.',
['扑棱']='扑棱蛾子:BAAALgAECgkJCQAAAA==.',
['扶苏']='扶苏苏:BAAALgAECgcJBwAAAA==.',
['提尔']='提尔丶:BAAALgADCgEJAQAAAA==.',
['摩柯']='摩柯迦叶:BAAALgAECgQJBQAAAA==.',
['放开']='放开那个罗丽:BAAALgAECgEJAQAAAA==.',
['故事']='故事的开始:BAAALgADCgUJBQAAAA==.',
['新欢']='新欢居然:BAAALgAECgcJBgAAAA==.',
['无敌']='无敌小星星:BAAALgAECgkJCQAAAA==.',
['无糖']='无糖冰块:BAAALgADCgEJAQAAAA==.',
['无聊']='无聊患者:BAAALgADCgEJAQAAAA==.',
['晚楓']='晚楓:BAAALgAECgEJAwAAAA==.',
['晚风']='晚风入梦:BAAALgAECgQJBAAAAA==.晚风微凉:BAAALgAECgQJBAAAAA==.晚风轻舞:BAAALgAECgEJAQAAAA==.',
['晨兮']='晨兮一蓝兮:BAAALgAECgEJAgAAAA==.',
['暖暖']='暖暖布丁:BAAALgADCgQJBAAAAA==.',
['暧美']='暧美莉:BAAALgAECgQJBAAAAA==.',
['暮晚']='暮晚枫林:BAAALgAECgEJAQAAAA==.',
['月半']='月半老豆:BAAALgAECgYJDQAAAA==.',
['木木']='木木夕丿丶:BAAALgAECgYJBgAAAA==.',
['杂技']='杂技少女:BAAALgAFFAEJAgAAAA==.',
['李思']='李思思:BAAALgAFFAIJAgABLgAFFAUJAQAEAAAAAA==.',
['林风']='林风笛语:BAAALgAECgQJBAAAAA==.',
['果师']='果师傅十二:BAABLgAECn8XAAMOAAkJtAfveQCGAQAOAAgJDQjveQCGAQAPAAkJMxmCUAA3AQAAAA==.',
['果达']='果达:BAAALgAECgQJCAAAAA==.',
['树缚']='树缚天葬:BAAALgAECgYJBgABLgAFFAQJCAADAJ8YAA==.',
['桥本']='桥本没菜:BAAALgAFFAIJAgABLgAFFAMJBAADADULAA==.',
['梦游']='梦游记事本:BAAALgAFFAIJAgAAAA==.',
['梧桐']='梧桐子:BAAALgADCgIJAgAAAA==.',
['欣然']='欣然跳舞:BAAALgADCgEJAQAAAA==.',
['歌舒']='歌舒吟:BAACLgAFFH8KAAMQAAMJAxKbAgAQAQAQAAMJAxKbAgAQAQARAAMJ2wvLCwDMAAAuAAQKfxYAAxAABglrF0oRAJgBABAABglrF0oRAJgBABEABglVE4JPAGcBAAAA.',
['殘灬']='殘灬念:BAAALgAECgIJAgAAAA==.',
['毛民']='毛民:BAAALgAECgYJCwAAAA==.',
['氟哌']='氟哌酸:BAAALgAECgEJAQAAAA==.',
['汐陽']='汐陽淸已泹:BAAALgADCgEJAQAAAA==.',
['沐君']='沐君:BAAALgAECgMJAwAAAA==.',
['沧海']='沧海一法:BAAALgAECgUJBQAAAA==.',
['波波']='波波媚:BAAALgADCgcJBwAAAA==.',
['泪茫']='泪茫:BAAALgAFFAEJAQAAAA==.',
['泰达']='泰达斯瓦:BAAALgADCgQJBAAAAA==.',
['流觞']='流觞丶狂:BAAALgAECgYJCgAAAA==.流觞雪:BAAALgAECgEJAgAAAA==.',
['浅岚']='浅岚色:BAAALgAECgQJBQAAAA==.',
['浮生']='浮生若尘:BAAALgAECgQJBgAAAA==.',
['浴火']='浴火玄冰:BAAALgAECgYJCgAAAA==.',
['淚淚']='淚淚丶:BAAALgAECgQJBAAAAA==.',
['淡月']='淡月流云:BAAALgADCgMJAwAAAA==.',
['深夜']='深夜滴雨露:BAAALgAECgUJBQAAAA==.',
['渣男']='渣男大湿兄:BAAALgAECgEJAQAAAA==.',
['潇湘']='潇湘蝶舞:BAAALgAECgUJCgAAAA==.',
['灬水']='灬水中月:BAAALgAECgEJAQAAAA==.',
['灰烬']='灰烬圣龙:BAAALgAECgEJAQAAAA==.灰烬守护使者:BAAALgAECgYJBgAAAA==.',
['点炮']='点炮:BAACLgAFFH8FAAIRAAIJUxiCDwCUAAARAAIJUxiCDwCUAAAuAAQKfx8AAhEACAkrIOoUAI4CABEACAkrIOoUAI4CAAAA.',
['然哥']='然哥不落教丶:BAAALgAECgUJBQAAAA==.',
['熊橘']='熊橘:BAAALgADCgEJAQAAAA==.',
['燃烧']='燃烧的大神:BAAALgADCgMJBQAAAA==.',
['爆枫']='爆枫精棂:BAAALgAECgQJBAAAAA==.',
['爱上']='爱上一匹野马:BAAALgAECgIJAgAAAA==.',
['狠角']='狠角色丶然哥:BAAALgAFFAIJBAAAAA==.',
['狮子']='狮子座流星雨:BAAALgAECggJCAAAAA==.',
['猎心']='猎心娃娃:BAAALgADCgEJAQAAAA==.',
['疏影']='疏影横波:BAAALgAECgcJBwAAAA==.',
['白夜']='白夜桑:BAAALgADCgUJDgAAAA==.',
['白薇']='白薇:BAAALgADCgEJAQAAAA==.',
['盲僧']='盲僧丶:BAACLgAFFH8KAAIMAAQJPiN8AwCpAQAMAAQJPiN8AwCpAQAuAAQKfxsAAgwACAnkJIwAAO8CAAwACAnkJIwAAO8CAAAA.',
['看我']='看我骑不骑你:BAAALgADCgMJAwAAAA==.',
['眼哥']='眼哥喊我玩:BAACLgAFFH8MAAIRAAUJ7RtwAQDQAQARAAUJ7RtwAQDQAQAuAAQKfx0AAhEABwnsIgkGADoCABEABwnsIgkGADoCAAAA.',
['瞌睡']='瞌睡又来了:BAAALgAECgYJBgAAAA==.',
['矮美']='矮美莉:BAAALgAECgEJAQAAAA==.',
['硕少']='硕少爷:BAAALgAECgYJCgAAAA==.',
['礼拜']='礼拜三三:BAAALgADCgEJAQAAAA==.',
['神沫']='神沫:BAAALgADCgEJAQAAAA==.',
['秦末']='秦末王嬴婴:BAAALgAFFAQJBAAAAA==.',
['究极']='究极体葫芦娃:BAAALgAECgEJAQAAAA==.',
['空手']='空手劈榴蓮:BAAALgAECgcJDQAAAA==.空手抡大炮:BAABLgAECn8VAAISAAkJ9h1dAwA0AgASAAkJ9h1dAwA0AgAAAA==.',
['空白']='空白格丶:BAACLgAFFH8HAAMTAAMJrRWlAwALAQATAAMJrRWlAwALAQASAAEJUxJVIABUAAAuAAQKfxoAAxMABwkuH/4EAJMCABMABwkuH/4EAJMCABIAAgkkGfWKAJMAAAAA.',
['章鱼']='章鱼精:BAAALgADCgcJBwAAAA==.',
['筱懵']='筱懵雪:BAAALgADCgUJBQAAAA==.',
['箬叶']='箬叶花吹雪:BAAALgAECgkJCwAAAA==.',
['米拉']='米拉圆滚滚:BAAALgAFFAIJBAAAAA==.',
['细雨']='细雨灬微醉:BAAALgAECgIJAgAAAA==.',
['绕指']='绕指青丝:BAAALgAECgMJAwAAAA==.',
['罒小']='罒小婐婐罒:BAAALgAECgEJAQAAAA==.',
['罗莎']='罗莎莉娅:BAAALgAFFAEJAQABLgAFFAYJAwAEAAAAAA==.',
['美特']='美特奥拉:BAAALgAECgkJCQAAAA==.',
['老何']='老何:BAAALgAECgEJAQAAAA==.',
['腮帮']='腮帮一奥雷娅:BAAALgAECgEJAQAAAA==.',
['至高']='至高颜值:BAAALgAECgUJCAAAAA==.',
['致命']='致命一板凳:BAAALgAECgYJCAAAAA==.',
['花下']='花下思雅:BAAALgADCgMJAwAAAA==.',
['花落']='花落夜思梦:BAAALgAECgYJBgAAAA==.',
['苏浅']='苏浅浅:BAAALgAECgIJAgABLgAFFAYJCAAUAA4aAA==.',
['苏莳']='苏莳芊:BAAALgAECgYJBgABLgAFFAUJDAADAK0mAA==.',
['若素']='若素:BAAALgAECgMJBAAAAA==.',
['苦苓']='苦苓林:BAAALgAECgYJCwAAAA==.',
['荼蘼']='荼蘼:BAAALgAECgQJCAABLgAFFAEJAQAEAAAAAA==.',
['莱尔']='莱尔米斯:BAAALgAECgQJBQAAAA==.',
['菠萝']='菠萝煎饼:BAAALgADCgEJAQAAAA==.',
['萌军']='萌军特种兵:BAAALgAECgEJAQAAAA==.',
['落幕']='落幕繁華:BAAALgAFFAIJAgAAAA==.',
['蒙面']='蒙面叫兽:BAAALgAECgEJAQAAAA==.',
['蓝凌']='蓝凌儿:BAAALgAECgMJAwAAAA==.',
['蓝星']='蓝星花:BAAALgAECgQJBAAAAA==.',
['蓝染']='蓝染勿右界:BAAALgAECgEJAQAAAA==.',
['薇薇']='薇薇灬乊笑:BAAALgAECgYJDgAAAA==.',
['虚空']='虚空布包:BAAALgAECgYJBgAAAA==.',
['蛋蛋']='蛋蛋时代二:BAAALgAFFAQJBAAAAA==.',
['螢火']='螢火虫:BAACLgAFFH8JAAIUAAMJrCGfBQApAQAUAAMJrCGfBQApAQAuAAQKfxYAAhQABgm4HDEiANIBABQABgm4HDEiANIBAAAA.',
['血腥']='血腥芭比:BAAALgAECgQJBAAAAA==.',
['西丶']='西丶鑫:BAAALgAECgQJBAAAAA==.',
['要你']='要你妹三千:BAAALgAECgEJAQAAAA==.',
['诸葛']='诸葛钢铁:BAAALgAECgYJBgAAAA==.',
['诺氟']='诺氟沙星:BAACLgAFFH8QAAIHAAQJwB9qBQB2AQAHAAQJwB9qBQB2AQAuAAQKfyoAAgcACAn6JMECAFQDAAcACAn6JMECAFQDAAAA.',
['贝塔']='贝塔:BAAALgAECgcJBwAAAA==.',
['贼神']='贼神归来:BAABLgAFFH8JAAIVAAQJWBUiBwAJAQAVAAQJWBUiBwAJAQAAAA==.',
['赤绝']='赤绝:BAAALgAECgYJBwAAAA==.',
['跌落']='跌落式熔断器:BAAALgAECgIJAgAAAA==.',
['跑魂']='跑魂战神:BAABLgAECn8VAAQWAAgJ+BgBBgDJAQAXAAYJyhvBEgDgAQAWAAcJgBkBBgDJAQAKAAQJZwoz3wDBAAAAAA==.',
['那个']='那个翼神回来:BAAALgAECgcJCQABLgAFFAcJAgAEAAAAAA==.',
['邪洛']='邪洛:BAAALgAECgYJBQAAAA==.',
['酷酷']='酷酷德:BAAALgAECgMJAwAAAA==.',
['鈭寧']='鈭寧雨詩:BAAALgAECgYJAQAAAA==.',
['钙铁']='钙铁锌锡:BAAALgADCgEJAQAAAA==.',
['长生']='长生天:BAAALgADCgcJBwAAAA==.',
['闪光']='闪光:BAABLgAFFH8GAAIBAAMJ8xrREwAUAQABAAMJ8xrREwAUAQAAAA==.',
['阿姆']='阿姆斯特朗:BAAALgADCgUJBQAAAA==.',
['阿彻']='阿彻鲁斯之殇:BAAALgAECgcJBwAAAA==.',
['陈宽']='陈宽宽:BAAALgAECgYJCAAAAA==.',
['陈皮']='陈皮丨白茶:BAAALgAECgcJCAAAAA==.',
['陶瓷']='陶瓷娃娃:BAAALgAECgYJBwAAAA==.',
['霍尔']='霍尔德尔:BAAALgAECgYJBgAAAA==.',
['霜糖']='霜糖苹果:BAAALgAECgYJEQAAAA==.',
['靈魂']='靈魂战車:BAAALgAECgYJCgAAAA==.',
['青鸟']='青鸟飞鱼:BAAALgAECgYJBwAAAA==.',
['静海']='静海之梦:BAAALgAECgMJAwAAAA==.',
['风暴']='风暴抉择:BAAALgAECgcJDQAAAA==.',
['飞沙']='飞沙走奶:BAAALgAECgkJBgAAAA==.',
['鬼魅']='鬼魅流觞:BAAALgAECgEJAQAAAA==.',
['鸭儿']='鸭儿鸡:BAAALgAECgcJAwAAAA==.',
['黄糖']='黄糖拿铁:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗忧伤:BAAALgAECgMJBgAAAA==.黑暗灵犀:BAAALgAECgMJBgAAAA==.',
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
