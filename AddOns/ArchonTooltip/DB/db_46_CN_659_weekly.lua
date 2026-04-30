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

local lookup = {'Shaman-Restoration','DeathKnight-Unholy','Druid-Balance','Monk-Mistweaver','DemonHunter-Havoc','DemonHunter-Devourer','Unknown-Unknown','Mage-Frost','Hunter-BeastMastery','Warrior-Arms','Warrior-Fury','Shaman-Elemental','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Druid-Restoration','Warlock-Demonology','Warlock-Destruction','Paladin-Holy','Hunter-Marksmanship','Rogue-Subtlety','Hunter-Survival','Monk-Brewmaster','Priest-Discipline',}
local provider = {region='CN',realm='屠魔山谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ao='Aotiantian:BAAALgAECgIJAgAAAA==.',
Cl='Clio:BAAALgAECgQJBQAAAA==.',
Co='Combo:BAAALgAFFAIJBAAAAA==.',
Da='Darkside:BAAALgAECgQJBQAAAA==.',
Dr='Dreadkinght:BAABLgAFFH8HAAIBAAMJfwscCADTAAABAAMJfwscCADTAAAAAA==.',
Fl='Flora:BAAALgAECgEJAQAAAA==.',
Fo='Fools:BAAALgAECgYJDAAAAA==.',
Go='Goliden:BAAALgADCgIJAgAAAA==.',
La='Lampdk:BAABLgAFFH8KAAICAAQJpAvLGwA1AQACAAQJpAvLGwA1AQAAAA==.',
Li='Littleseal:BAABLgAFFH8HAAIDAAMJ/xT4DQD/AAADAAMJ/xT4DQD/AAAAAA==.',
Me='Mechrev:BAAALgAECgEJAQAAAA==.',
Ne='Nexusprime:BAAALgAECgQJBAAAAA==.',
Of='Ofanim:BAAALgAECgYJDAAAAA==.',
Sa='Samap:BAAALgAFFAIJAwAAAA==.',
Sn='Snowfall:BAAALgAECgYJCwAAAA==.',
So='Sophiie:BAAALgAECgYJDAAAAA==.Sophle:BAAALgAECgQJBgAAAA==.',
Xh='Xhzac:BAABLgAFFH8GAAIEAAYJpQ88AQDOAQAEAAYJpQ88AQDOAQAAAA==.',
['一剑']='一剑东来:BAAALgAECgIJAgAAAA==.',
['一只']='一只小松鼠:BAAALgADCgIJAgAAAA==.一只竹子:BAAALgADCgUJBQAAAA==.',
['一叶']='一叶知秋丶:BAAALgAECgYJCwAAAA==.',
['一奶']='一奶王一:BAAALgAECgcJCwAAAA==.',
['一战']='一战定乾坤:BAAALgADCgYJBgAAAA==.',
['一穆']='一穆一:BAAALgAFFAIJAwAAAA==.',
['一脸']='一脸萌懂:BAAALgAECgYJAwAAAA==.',
['三文']='三文鱼杀手:BAAALgAECgIJAgAAAA==.',
['三点']='三点水的淇:BAAALgAECgcJCAAAAA==.',
['不想']='不想上班喵:BAACLgAFFH8IAAIFAAMJjAwqAgD0AAAFAAMJjAwqAgD0AAAuAAQKfyYAAwUACAmOIM4GAPkCAAUACAmOIM4GAPkCAAYAAQmdARr1ABoAAAAA.',
['不按']='不按套路来:BAAALgAECgUJBQAAAA==.',
['东东']='东东不乖:BAAALgAECgcJCAAAAA==.',
['丧彪']='丧彪:BAAALgAECgUJBgAAAA==.',
['丨怪']='丨怪咖丨:BAAALgAECgUJEgAAAA==.',
['丶仅']='丶仅有的傲气:BAAALgAECgEJAQAAAA==.',
['丶灬']='丶灬小柒:BAAALgADCgEJAQAAAA==.',
['丶祢']='丶祢豆子丶:BAAALgADCgQJBAAAAA==.',
['丶貳']='丶貳月:BAAALgAECgMJAwAAAA==.',
['丶阿']='丶阿克萌德:BAAALgAECgYJBgAAAA==.',
['二狗']='二狗狗叽:BAAALgAECgcJCwAAAA==.',
['今夕']='今夕何夕:BAAALgADCgUJBQAAAA==.',
['今朝']='今朝易在梦里:BAAALgAFFAEJAQAAAA==.',
['伊咕']='伊咕哔咕:BAAALgAFFAMJAwAAAA==.',
['你看']='你看毛阿:BAAALgAECgMJBAAAAA==.',
['依旧']='依旧堕落的片:BAAALgAECgQJBQAAAA==.',
['依然']='依然灬楓落:BAAALgADCgMJAwAAAA==.',
['克伊']='克伊斯麦艾斯:BAAALgADCgMJAwAAAA==.',
['公正']='公正法治:BAAALgAECgEJAQAAAA==.',
['冥海']='冥海无涯莹勾:BAAALgAECgcJBQAAAA==.',
['刘非']='刘非晚:BAAALgAECgEJAQAAAA==.',
['利率']='利率债:BAAALgAFFAMJAwABLgAFFAUJAgAHAAAAAA==.',
['剑丨']='剑丨圣:BAAALgAECgUJBgAAAA==.',
['加尔']='加尔赛力克:BAAALgAECgEJAQAAAA==.',
['十五']='十五术:BAAALgADCgIJAgAAAA==.',
['古德']='古德莱克:BAAALgAFFAEJAQAAAA==.',
['古或']='古或今:BAAALgADCgIJAgAAAA==.',
['可心']='可心可心:BAAALgAECgYJCQAAAA==.',
['可爱']='可爱又迷人:BAAALgAECgEJAgAAAA==.',
['吃人']='吃人晨:BAAALgAECgMJBgAAAA==.',
['吉吉']='吉吉国王:BAAALgAECgYJDAAAAA==.',
['后街']='后街丶男孩:BAAALgADCgEJAQAAAA==.',
['吴先']='吴先生:BAAALgAECgQJBwAAAA==.',
['呜喵']='呜喵不怕:BAAALgADCgcJBwAAAA==.',
['咖啡']='咖啡丶不加冰:BAACLgAFFH8KAAIIAAQJ7AkgHwBNAQAIAAQJ7AkgHwBNAQAuAAQKfxkAAggABwmCGhBsAP0BAAgABwmCGhBsAP0BAAAA.',
['哈基']='哈基咪:BAAALgAECgUJBQAAAA==.',
['唐门']='唐门衮衮:BAAALgAECgUJCQAAAA==.',
['啪叽']='啪叽一下倒地:BAAALgAFFAIJAgAAAA==.',
['啾啾']='啾啾咕:BAAALgAECgYJBgAAAA==.',
['喜之']='喜之郞果冻:BAAALgAECgUJBQAAAA==.',
['喵丶']='喵丶闪光:BAAALgADCgUJBQAAAA==.',
['回噫']='回噫曾经:BAEALgAFFAIJAwAAAA==.',
['回忆']='回忆灬逝去:BAAALgAECgEJAQAAAA==.',
['团队']='团队治疗假人:BAAALgADCgQJBAABLgAFFAIJBAAHAAAAAA==.',
['土有']='土有土的好处:BAAALgAECgkJDQAAAA==.',
['圣光']='圣光乳牛:BAAALgADCgYJBgAAAA==.圣光先生:BAAALgAECgkJBwAAAA==.',
['圣无']='圣无光:BAAALgAECgYJBgAAAA==.',
['地狱']='地狱之歌灬:BAAALgADCgUJAQAAAA==.',
['坑逼']='坑逼南波丸:BAABLgAFFH8GAAIJAAMJWhIdDAABAQAJAAMJWhIdDAABAQAAAA==.',
['埃兰']='埃兰的臭鞋:BAAALgADCgEJAQAAAA==.',
['埖塚']='埖塚:BAAALgAECgIJAgAAAA==.',
['声声']='声声漫:BAAALgAFFAEJAQAAAA==.',
['夢幻']='夢幻新寵:BAAALgADCgUJBQAAAA==.',
['大烟']='大烟:BAAALgAECgIJAgAAAA==.',
['大猫']='大猫:BAAALgAECgEJAQAAAA==.',
['天涯']='天涯若比邻:BAAALgAFFAIJAwAAAA==.',
['天降']='天降正义:BAAALgAECgEJAgAAAA==.',
['头上']='头上有犄角丶:BAAALgAECgYJBgAAAA==.',
['夺命']='夺命乌苏:BAAALgAECgIJAgAAAA==.',
['奔雷']='奔雷剑主大奔:BAABLgAFFH8HAAMKAAMJCBwuBQDEAAAKAAIJ2xouBQDEAAALAAIJkBa6FwCqAAAAAA==.',
['姆巴']='姆巴佩:BAAALgAECgIJBAAAAA==.',
['宇宙']='宇宙圣骑:BAAALgADCgIJAgAAAA==.',
['安东']='安东尼奥斯:BAAALgAECgYJCAAAAA==.',
['宫爆']='宫爆鸡丁:BAABLgAECn8eAAIBAAkJsxlJDQCyAgABAAkJsxlJDQCyAgAAAA==.',
['富强']='富强自由:BAAALgAECgEJAQAAAA==.',
['寻梦']='寻梦淑君:BAAALgADCgIJAgAAAA==.',
['寻花']='寻花千百度:BAAALgAECgcJBAABLgAFFAYJFgAMAMUZAA==.',
['封蜮']='封蜮之契:BAAALgAECgQJBAAAAA==.',
['小叶']='小叶子:BAAALgADCgEJAQAAAA==.',
['小懒']='小懒:BAAALgAECgIJAgAAAA==.',
['小熊']='小熊丶蛋包饭:BAAALgAECgQJBAAAAA==.',
['小甩']='小甩牛:BAAALgAECgEJAQAAAA==.',
['小白']='小白天:BAAALgAECgQJBwAAAA==.',
['小竹']='小竹子想熊猫:BAAALgAECgYJCQAAAA==.',
['小红']='小红薯:BAAALgADCgEJAQAAAA==.',
['小萝']='小萝莉的秘密:BAAALgAECgUJBQAAAA==.',
['小野']='小野马:BAAALgAECgMJAwAAAA==.',
['小阿']='小阿丹:BAAALgADCgEJAQABLgAECgYJCwAHAAAAAA==.小阿的女人:BAAALgAECggJCwAAAA==.',
['小非']='小非侠:BAAALgAECgYJBwAAAA==.',
['小高']='小高:BAAALgAECgQJBAAAAA==.',
['尤娜']='尤娜:BAAALgADCgEJAQAAAA==.',
['尼奥']='尼奥奥龙:BAAALgAECgcJCAAAAA==.尼奥龙:BAABLgAECn8WAAINAAkJhB6uBAAFAwANAAkJhB6uBAAFAwAAAA==.尼奥龙龙:BAAALgAECggJEQAAAA==.',
['尼尼']='尼尼奥奥龙:BAAALgAFFAMJAwAAAA==.尼尼奥奥龙龙:BAABLgAECn8ZAAQNAAgJ6RFNHQCZAQANAAcJUhRNHQCZAQAOAAYJIQEAAAAAAAAPAAEJ+Q0AAAAAAAABLgAFFAUJBQAQAJkcAA==.',
['崔小']='崔小六:BAAALgAECgQJBAAAAA==.',
['川上']='川上富江:BAAALgAECgcJDQAAAA==.',
['巧乐']='巧乐兹:BAAALgAECgIJAgAAAA==.',
['帅武']='帅武:BAAALgAECgcJBwAAAA==.',
['幽幽']='幽幽寒:BAAALgAECgIJAgAAAA==.',
['幽明']='幽明之影:BAAALgAECgcJBwAAAA==.幽明幽明:BAAALgAFFAEJAQAAAA==.幽明影鋒:BAAALgAECgYJBgABLgAFFAUJBwAGAPsWAA==.',
['康杰']='康杰丶骄子:BAAALgAFFAEJAQAAAA==.',
['恰同']='恰同学少年:BAAALgAECgEJAgAAAA==.',
['我是']='我是站湿:BAAALgADCgEJAQAAAA==.',
['战野']='战野八荒:BAAALgAECgkJBwAAAA==.',
['戰丨']='戰丨秋天:BAAALgAECgYJCAAAAA==.',
['把尼']='把尼们都鲨了:BAAALgAECgEJAQAAAA==.',
['抓只']='抓只野德:BAAALgAECgUJBQAAAA==.',
['抬手']='抬手就是一棍:BAAALgAECgEJAQAAAA==.',
['抹茶']='抹茶冰莎:BAAALgADCgIJAgAAAA==.',
['放開']='放開那個女孩:BAABLgAECn8YAAIMAAcJHB9wFAB7AgAMAAcJHB9wFAB7AgAAAA==.',
['文明']='文明和谐:BAAALgAECgEJAQAAAA==.',
['斩仇']='斩仇:BAAALgAECgMJBAAAAA==.',
['无双']='无双:BAAALgAECgYJEQAAAA==.',
['无敌']='无敌小新:BAAALgADCgQJBAAAAA==.',
['星之']='星之金幣:BAAALgAECgMJBAAAAA==.',
['星野']='星野琉璃:BAAALgAECgcJBwAAAA==.',
['晓丶']='晓丶德:BAAALgAECgUJBQAAAA==.晓丶骑士:BAAALgAFFAEJAQAAAA==.',
['晴空']='晴空:BAAALgAECgEJAQAAAA==.',
['暗影']='暗影丶梦魇:BAAALgAECgcJBwAAAA==.',
['暴打']='暴打奴隶:BAAALgAFFAEJAQAAAA==.',
['最后']='最后的最后:BAAALgAECgEJAQAAAA==.',
['朵朵']='朵朵小宝贝:BAAALgAECgEJAgAAAA==.',
['杨梅']='杨梅酪酪:BAAALgAFFAIJAwAAAA==.',
['杰羅']='杰羅特丶:BAAALgAECgMJAwAAAA==.',
['松尾']='松尾芭蕉:BAAALgAECgUJBQABLgAECgcJDQAHAAAAAA==.',
['林德']='林德霍夫堡:BAAALgADCgUJBQAAAA==.',
['柒璨']='柒璨:BAABLgAECn8YAAIGAAcJwg0dhAAfAQAGAAcJwg0dhAAfAQAAAA==.',
['核動']='核動力輪椅:BAAALgAFFAQJAwAAAA==.',
['核心']='核心价值观:BAAALgAECgQJBQAAAA==.',
['梵凡']='梵凡:BAACLgAFFH8OAAMRAAQJDRZiEQBYAQARAAQJDRZiEQBYAQASAAEJAwcAAAAAAAAuAAQKfyoAAxEACAlXIG4WAM4CABEACAm2G24WAM4CABIABQkYI9IMAPcBAAAA.',
['橘子']='橘子猫:BAAALgAFFAEJAgAAAA==.',
['武敌']='武敌:BAAALgAFFAEJAQAAAA==.',
['气定']='气定神闲:BAAALgAECgEJAwAAAA==.',
['水蓝']='水蓝色冰凌:BAAALgADCgcJDQAAAA==.',
['永恒']='永恒精灵皇:BAAALgADCgcJBwAAAA==.',
['汤卜']='汤卜利卜:BAAALgAFFAEJAQAAAA==.',
['沈阳']='沈阳虎哥:BAAALgAECgYJCwAAAA==.',
['沐雨']='沐雨橙枫:BAAALgAECgQJBAAAAA==.',
['沙漠']='沙漠死骑:BAAALgAECgYJCwAAAA==.',
['没事']='没事只想躺:BAAALgAECgYJBgAAAA==.',
['泠凰']='泠凰:BAAALgADCgEJAQAAAA==.',
['泥泥']='泥泥洋:BAAALgADCgEJAQAAAA==.',
['浅唱']='浅唱丶幽蓝:BAAALgAECgIJAgAAAA==.',
['海狗']='海狗润滑油:BAAALgAECgUJBQAAAA==.',
['清一']='清一色:BAAALgAFFAEJAQAAAA==.',
['温柔']='温柔小灵:BAAALgAECgYJCwAAAA==.温柔狂刀:BAAALgAECgEJAQAAAA==.',
['滅世']='滅世麒麟:BAAALgAECgUJBQAAAA==.',
['火之']='火之泪:BAAALgADCgQJBAAAAA==.',
['灬浴']='灬浴火重生灬:BAAALgAECgEJAQAAAA==.',
['炽焰']='炽焰晴风:BAAALgAECgYJBgAAAA==.',
['热情']='热情过了头:BAAALgAECgcJCAAAAA==.',
['無盡']='無盡的嘿炮卜:BAAALgAECgcJCwAAAA==.無盡的御无双:BAAALgAECgMJBAAAAA==.無盡的摧心魔:BAAALgAECgYJDwAAAA==.',
['無限']='無限:BAAALgADCgEJAQAAAA==.',
['熊猫']='熊猫玩转地球:BAAALgAECgcJBwAAAA==.',
['熠雪']='熠雪狂魔:BAAALgAECgUJCQAAAA==.',
['牧色']='牧色撩人:BAAALgAECgYJBwAAAA==.',
['犹格']='犹格索托斯:BAAALgAECgEJAwAAAA==.',
['狂热']='狂热的小吻:BAAALgAECgIJAgAAAA==.',
['猫猫']='猫猫啲诅咒:BAAALgAECgEJAQAAAA==.猫猫喵喵拳:BAAALgAECgYJDwAAAA==.',
['王的']='王的女人:BAAALgADCgkJEQAAAA==.',
['王维']='王维:BAAALgAECgIJBQABLgAFFAQJBwAEAE0IAA==.',
['玖玖']='玖玖召大军:BAAALgAFFAEJAQAAAA==.玖玖宝贝:BAAALgAECgYJDQAAAA==.玖玖开盾反:BAAALgADCgMJAwAAAA==.',
['玛西']='玛西:BAAALgAECgQJBAAAAA==.',
['琅琊']='琅琊丶王:BAAALgAECgQJBQAAAA==.',
['电子']='电子猪:BAAALgAECgkJCQAAAA==.',
['疾风']='疾风剑豪丶:BAAALgAECgYJCgAAAA==.',
['盗香']='盗香皴:BAAALgAFFAIJAwABLgAFFAIJBAAHAAAAAA==.',
['真是']='真是厉害:BAAALgADCgMJAwAAAA==.',
['真没']='真没死:BAAALgADCgUJBQAAAA==.',
['睑之']='睑之光:BAAALgAECggJCAAAAA==.',
['石不']='石不转:BAACLgAFFH8LAAITAAQJ9hq4BgBrAQATAAQJ9hq4BgBrAQAuAAQKfx8AAhMACAm+JNYCAEkDABMACAm+JNYCAEkDAAAA.',
['破風']='破風生霊:BAACLgAFFH8XAAMBAAYJagVBAwClAQABAAYJagVBAwClAQAMAAUJAg4HBgB6AQAuAAQKfx8AAwwACQk1IoIIAAkDAAwACAk+IoIIAAkDAAEACAlvFLguAM4BAAAA.',
['秃哥']='秃哥抱抱我:BAACLgAFFH8PAAIIAAQJFxsNBgBwAQAIAAQJFxsNBgBwAQAuAAQKfxoAAggABwlzIaYsAMACAAgABwlzIaYsAMACAAAA.秃哥玩犭昔人:BAACLgAFFH8GAAIUAAIJDBMSHQChAAAUAAIJDBMSHQChAAAuAAQKfxsAAhQABgmGIdIiAA0CABQABgmGIdIiAA0CAAAA.',
['秃头']='秃头骑士:BAABLgAFFH8FAAICAAIJPSHMPACkAAACAAIJPSHMPACkAAAAAA==.',
['站湿']='站湿:BAAALgAECgIJAgAAAA==.',
['类似']='类似香水:BAABLgAFFH8HAAIVAAQJLBG2CABhAQAVAAQJLBG2CABhAQAAAA==.',
['索隆']='索隆:BAAALgAECgUJBAAAAA==.',
['紫夜']='紫夜之心:BAAALgAECgkJBAAAAA==.',
['繁椛']='繁椛历尽:BAAALgAECgYJCQAAAA==.',
['红煌']='红煌流星:BAAALgADCgUJCQAAAA==.',
['给爺']='给爺跪着:BAAALgADCgQJBAAAAA==.',
['美女']='美女與野獸:BAAALgAECgQJBAAAAA==.',
['翩若']='翩若惊鸿:BAAALgAECgYJBgAAAA==.',
['聚光']='聚光灯在哪儿:BAAALgADCgcJBwAAAA==.',
['肉肉']='肉肉大:BAAALgADCgQJBAAAAA==.',
['胖胖']='胖胖的小花宝:BAAALgAECgMJAQAAAA==.胖胖虎:BAAALgADCgEJAQAAAA==.',
['花小']='花小颜:BAAALgAECgEJAQAAAA==.',
['花都']='花都酒剑仙:BAAALgAECgYJDgAAAA==.',
['草莓']='草莓酱板鸭:BAAALgAECgYJCQAAAA==.',
['萨满']='萨满咋回血:BAAALgADCgYJBgAAAA==.',
['蜘蛛']='蜘蛛侦探:BAAALgAFFAIJAgAAAA==.',
['螺旋']='螺旋猫:BAAALgADCgEJAgAAAA==.',
['蟑螂']='蟑螂恶霸:BAABLgAFFH8GAAQUAAMJRxWwGQC3AAAUAAIJfRuwGQC3AAAWAAEJpyIRBgBqAAAJAAEJnwi/JABXAAAAAA==.',
['血玉']='血玉麒麟:BAAALgADCgcJBwAAAA==.',
['被腐']='被腐蚀的圣光:BAAALgAECgEJAgAAAA==.',
['西属']='西属撒哈拉:BAAALgAFFAIJBAAAAA==.',
['西红']='西红柿大明星:BAABLgAECn8bAAICAAcJ1x3nRwAcAgACAAcJ1x3nRwAcAgAAAA==.',
['解散']='解散全团:BAACLgAFFH8WAAINAAUJDB13AwDPAQANAAUJDB13AwDPAQAuAAQKfxYAAw0ACQkXIJcDACUDAA0ACAkvI5cDACUDAA8AAQnlBH1AAC8AAAAA.解散门徒:BAAALgAFFAIJAgABLgAFFAUJFgANAAwdAA==.',
['觸景']='觸景傷情:BAAALgAECgEJAQAAAA==.',
['记忆']='记忆中小小:BAAALgAECgYJDAAAAA==.记忆中的怀念:BAAALgAFFAEJAQAAAA==.',
['谁是']='谁是干脆面:BAABLgAFFH8HAAIEAAQJTQhTBQACAQAEAAQJTQhTBQACAQAAAA==.',
['谦谦']='谦谦君子:BAAALgAECgIJAgAAAA==.',
['费舍']='费舍尔丶泰格:BAAALgAECgMJBAAAAA==.',
['费隆']='费隆纳斯:BAAALgAECgYJBwAAAA==.',
['赤木']='赤木茂:BAAALgAECgUJBQAAAA==.',
['赤红']='赤红天使:BAAALgAECgYJBgAAAA==.',
['输出']='输出及格线:BAACLgAFFH8IAAIEAAMJux6XCQAbAQAEAAMJux6XCQAbAQAuAAQKfxwAAgQACQl6GNUPAF0CAAQACQl6GNUPAF0CAAAA.',
['进击']='进击的小明:BAAALgAFFAEJAQABLgAFFAMJBwADAH0cAA==.',
['迷霧']='迷霧天使:BAAALgAECgIJAgAAAA==.',
['道无']='道无名:BAABLgAFFH8FAAIXAAMJeQy3FADRAAAXAAMJeQy3FADRAAAAAA==.',
['那个']='那个谁:BAAALgAECgkJAwAAAA==.',
['邪能']='邪能女子嗣:BAAALgADCgYJBgAAAA==.',
['都门']='都门帐饮无绪:BAAALgAECgEJAgAAAA==.',
['醛聚']='醛聚德:BAAALgAFFAIJBAAAAA==.',
['铁骥']='铁骥八旗:BAAALgAECgEJAQAAAA==.',
['长门']='长门有希灬:BAAALgAFFAYJAgAAAA==.',
['阿克']='阿克夏:BAAALgAECgQJBAAAAA==.',
['阿塔']='阿塔兰塔:BAAALgAECgYJBgAAAA==.',
['阿斯']='阿斯卡:BAAALgAFFAEJAQABLgAFFAIJBAAHAAAAAA==.',
['阿莱']='阿莱西斯:BAAALgADCgQJBAAAAA==.',
['陈小']='陈小雅:BAAALgAFFAIJBAAAAA==.',
['陈魁']='陈魁锋:BAAALgAECgEJAQAAAA==.',
['雪球']='雪球球:BAAALgAECgcJCAAAAA==.',
['霓裳']='霓裳舞:BAAALgAFFAIJAQAAAA==.',
['霹哩']='霹哩啪啦:BAAALgAECgIJAgAAAA==.',
['靑山']='靑山:BAAALgAECgUJBQAAAA==.',
['青丘']='青丘丶白凤九:BAAALgAECgYJBgAAAA==.',
['非要']='非要画个妆:BAAALgAECgYJDgAAAA==.',
['風凌']='風凌雪:BAAALgAECgkJBwABLgAFFAUJBQAQAJkcAA==.',
['风吟']='风吟丶:BAAALgAECgEJAQAAAA==.风吟雪啸:BAAALgAECgMJBAAAAA==.',
['风月']='风月流离:BAAALgAECgMJBgAAAA==.',
['风骚']='风骚的三胖子:BAAALgAECggJBgAAAA==.',
['飒蠻']='飒蠻:BAAALgAECgYJCgABLgAFFAcJEgAYAEEVAA==.',
['骨汤']='骨汤一号:BAABLgAFFH8JAAIXAAUJPQcaEAAAAQAXAAUJPQcaEAAAAQAAAA==.骨汤二号:BAAALgAFFAQJAwAAAA==.',
['鬼迷']='鬼迷溜眼的丨:BAAALgAECgUJCAAAAA==.',
['魔域']='魔域邪神:BAAALgAECgMJAwAAAA==.',
['魔纹']='魔纹:BAAALgAECgUJBQABLgAECgYJBgAHAAAAAA==.',
['鲁尔']='鲁尔哈姆:BAAALgADCgEJAgAAAA==.',
['黑暗']='黑暗之光:BAAALgAECgEJAQAAAA==.黑暗魔:BAAALgAECgEJAQAAAA==.',
['龙之']='龙之幽幽:BAAALgAECgEJAQAAAA==.',
['龙希']='龙希尔战坦:BAAALgAECgMJAwAAAA==.',
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
