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

local lookup = {'Paladin-Retribution','Paladin-Holy','Monk-Mistweaver','Shaman-Elemental','Mage-Frost','Hunter-Marksmanship','DemonHunter-Havoc','Evoker-Preservation','DeathKnight-Unholy','Unknown-Unknown','Evoker-Devastation','Evoker-Augmentation','Priest-Holy','Warrior-Protection','Hunter-BeastMastery','Warlock-Demonology','Shaman-Restoration','DemonHunter-Devourer','Priest-Discipline',}
local provider = {region='CN',realm='暴风祭坛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adibil:BAAALgAFFAEJAQAAAA==.',
Al='Alam:BAAALgAECgcJDgAAAA==.',
Ar='Arcanedh:BAAALgAECgUJAwAAAA==.Arrhenius:BAAALgAECgkJDwAAAA==.',
As='Asxcv:BAAALgAECgIJAgAAAA==.',
Ch='Christopher:BAABLgAECn8UAAMBAAcJwBFHaQCtAQABAAcJwBFHaQCtAQACAAYJbAPxawDKAAAAAA==.',
De='Deathdemom:BAAALgAECgMJAwAAAA==.',
Di='Dida:BAAALgAECggJDQAAAA==.',
Ea='Eagie:BAAALgAFFAQJBAAAAA==.Ears:BAAALgAECgEJAQAAAA==.',
Ex='Exchange:BAAALgAECgMJAwAAAA==.',
Ha='Haluna:BAABLgAFFH8LAAIDAAQJnyDlBQBxAQADAAQJnyDlBQBxAQAAAA==.',
Ip='Ip:BAAALgADCgEJAQAAAA==.',
Is='Isolde:BAAALgAECgYJBgAAAA==.',
Ji='Jina:BAAALgAECgEJAQAAAA==.',
Ju='Justices:BAAALgAECgQJBAAAAA==.',
Ki='Kitakaze:BAAALgAFFAEJAQAAAA==.',
Ku='Kuroneko:BAAALgAECgMJBQAAAA==.',
La='Lalune:BAAALgAECgcJEAAAAA==.Latsiimh:BAAALgAFFAQJBAAAAA==.',
Ma='Marriott:BAAALgAECgQJBAAAAA==.',
Me='Mercy:BAACLgAFFH8IAAIEAAMJig5HBwDkAAAEAAMJig5HBwDkAAAuAAQKfxYAAgQACAm4GmMVAHECAAQACAm4GmMVAHECAAAA.',
Op='Ops:BAAALgAFFAEJAgAAAA==.',
Pk='Pk:BAAALgAFFAEJAQAAAA==.Pkdaddy:BAAALgAECgYJBQAAAA==.',
Qa='Qaq:BAAALgAECgUJDAAAAA==.',
Ro='Rotazel:BAAALgAECgYJDgAAAA==.',
Sd='Sdf:BAAALgADCgIJAgAAAA==.',
Te='Tenderness:BAAALgAECgEJAgAAAA==.',
Wa='Waiw:BAAALgADCgEJAgAAAA==.',
Wd='Wdq:BAAALgAECgQJBAAAAA==.',
Wh='Whitemoon:BAAALgADCgYJAwAAAA==.',
Wi='Wingspan:BAACLgAFFH8GAAIFAAIJfhx8NwC7AAAFAAIJfhx8NwC7AAAuAAQKfyIAAgUACAnmIw8RAEIDAAUACAnmIw8RAEIDAAAA.',
Yu='Yukikaze:BAAALgAFFAIJAwABLgAFFAQJCwADAJ8gAA==.Yummy:BAAALgAECgEJAQAAAA==.',
['一只']='一只猴子:BAAALgAECgEJAgAAAA==.',
['一吨']='一吨大师:BAAALgAFFAEJAQAAAA==.',
['一寺']='一寺一壶酒:BAAALgAFFAIJBAAAAA==.',
['万象']='万象皆杀:BAAALgADCgYJBgAAAA==.',
['上海']='上海萌牛:BAAALgAECgkJDgAAAA==.',
['不少']='不少一根骨:BAAALgADCgIJAgAAAA==.',
['丐帮']='丐帮宋远桥:BAAALgAECgUJBQAAAA==.',
['丨野']='丨野蛮教主:BAAALgAECgcJCwAAAA==.',
['丶小']='丶小甜甜:BAAALgAECgMJAwAAAA==.',
['丶柒']='丶柒囍:BAAALgAECgQJBAAAAA==.',
['乀丨']='乀丨丨乀肥:BAAALgAECgYJDAAAAA==.',
['乄尐']='乄尐荳纸:BAAALgAECgYJBgAAAA==.',
['乄蓝']='乄蓝色妖姬:BAAALgAECgQJBgAAAA==.',
['么册']='么册乌里黑了:BAAALgAECgEJAQAAAA==.',
['乔伊']='乔伊波伊:BAAALgADCgIJAgAAAA==.',
['云曦']='云曦丶:BAABLgAFFH8NAAIDAAYJDhPrAwCuAQADAAYJDhPrAwCuAQAAAA==.',
['亚尔']='亚尔德格:BAAALgAECgEJAQAAAA==.',
['人熊']='人熊猫鸟鹿树:BAAALgAECgEJAQAAAA==.',
['仄仄']='仄仄:BAAALgAFFAEJAQAAAA==.',
['仇小']='仇小烽:BAAALgAECgQJBgAAAA==.',
['今天']='今天又初恋了:BAABLgAFFH8FAAIGAAUJFApiCgByAQAGAAUJFApiCgByAQAAAA==.',
['今晩']='今晩打老虎:BAAALgAECgYJBwAAAA==.',
['仓颉']='仓颉:BAAALgAECgMJAwAAAA==.',
['他们']='他们都会:BAAALgAECgEJAQAAAA==.',
['以战']='以战止殇:BAAALgAECgYJCQAAAA==.',
['以梦']='以梦:BAAALgAECgYJBgAAAA==.',
['任云']='任云亦云:BAAALgADCgUJBQAAAA==.',
['伊利']='伊利丹风怒:BAAALgADCgYJCwAAAA==.',
['伊十']='伊十六夜:BAAALgAECgQJBQAAAA==.',
['会长']='会长来了:BAAALgAFFAIJAgAAAA==.',
['依波']='依波拉:BAAALgAFFAIJAwAAAA==.',
['修斯']='修斯登柴柴:BAACLgAFFH8NAAIHAAQJ+h7MAQB/AQAHAAQJ+h7MAQB/AQAuAAQKfyUAAgcACQmaJOcAAMEDAAcACQmaJOcAAMEDAAAA.',
['倔強']='倔強的葡萄哥:BAAALgAECgIJAgAAAA==.',
['偶尔']='偶尔修灯:BAAALgAECgIJAgAAAA==.',
['偷得']='偷得浮生半夜:BAAALgADCgMJAQAAAA==.',
['傻瓜']='傻瓜力:BAAALgAECgQJBAAAAA==.',
['像疯']='像疯一样自由:BAAALgAFFAIJAgAAAA==.',
['元素']='元素忽悠者:BAAALgAECgEJAQAAAA==.',
['八个']='八个技师同時:BAAALgAECgQJBAAAAA==.',
['其实']='其实我很靓:BAAALgADCgMJAwAAAA==.',
['冰嗱']='冰嗱铁:BAAALgAECgUJBQAAAA==.',
['冰封']='冰封柬柬:BAAALgAECgYJDQAAAA==.',
['冰血']='冰血雪:BAAALgAECgYJDgAAAA==.',
['冰雪']='冰雪影风:BAAALgAECgMJAwAAAA==.',
['冲锋']='冲锋就开怪:BAAALgAECgYJBgAAAA==.冲锋拦截援护:BAAALgADCgEJAQAAAA==.',
['冷夜']='冷夜静曲:BAAALgAECgUJBQAAAA==.',
['凤凰']='凤凰院喵真:BAAALgAECgcJBwAAAA==.',
['刘海']='刘海柱丶:BAAALgAECgQJBgAAAA==.',
['加勒']='加勒福海盗:BAAALgADCgMJAwAAAA==.',
['千秋']='千秋月未落:BAAALgADCgEJAQAAAA==.',
['单吊']='单吊绝九万:BAABLgAECn8fAAIIAAgJFB8wBgDhAgAIAAgJFB8wBgDhAgABLgAFFAUJBQAIACAMAA==.',
['卖血']='卖血吴彦祖:BAAALgAECgQJBgAAAA==.',
['卡德']='卡德乘:BAABLgAFFH8GAAIFAAIJHhVxGwCpAAAFAAIJHhVxGwCpAAAAAA==.',
['及夏']='及夏:BAAALgAECgYJDwAAAA==.',
['古月']='古月道天:BAAALgAECgUJBwAAAA==.',
['名流']='名流灬天目:BAAALgAECgEJAQAAAA==.',
['听风']='听风丶江酱:BAAALgAECgIJAgAAAA==.',
['哎呀']='哎呀喂:BAAALgAECgEJAQAAAA==.',
['哼唧']='哼唧:BAAALgADCgEJAQAAAA==.',
['唏嘘']='唏嘘的学渣:BAAALgAFFAIJAwAAAA==.',
['喂饱']='喂饱饱:BAAALgAECgQJBAAAAA==.',
['喵呜']='喵呜:BAAALgAECgYJCQAAAA==.',
['喵星']='喵星神魔:BAAALgAECgIJAgAAAA==.',
['圆圆']='圆圆萨满:BAAALgAECgYJBwAAAA==.',
['圣光']='圣光十字军:BAAALgAECgUJBwAAAA==.',
['墨染']='墨染吖:BAAALgAECgcJCAAAAA==.',
['壹粒']='壹粒蛋戮疯:BAAALgAECgEJAQAAAA==.',
['夏处']='夏处暑:BAAALgAFFAIJAgAAAA==.',
['夏大']='夏大暑:BAABLgAFFH8GAAICAAMJoRu6BAAkAQACAAMJoRu6BAAkAQAAAA==.',
['夏寒']='夏寒露:BAAALgAFFAQJBAAAAA==.',
['夏小']='夏小暑:BAABLgAFFH8LAAICAAQJfRzYBgBpAQACAAQJfRzYBgBpAQAAAA==.',
['夏白']='夏白露:BAAALgAFFAQJBAAAAA==.',
['夏秋']='夏秋分:BAAALgAFFAIJAgAAAA==.',
['夏立']='夏立秋:BAABLgAFFH8GAAICAAQJdB44BgB1AQACAAQJdB44BgB1AQAAAA==.',
['夜来']='夜来美:BAAALgADCgUJBQAAAA==.',
['夜雨']='夜雨灬声烦:BAAALgAECgUJBgAAAA==.',
['夢梅']='夢梅悅怡:BAAALgAECgMJAwAAAA==.',
['大能']='大能猫:BAAALgAECgQJBgAAAA==.',
['大馍']='大馍:BAACLgAFFH8FAAIJAAMJkhUHKAD4AAAJAAMJkhUHKAD4AAAuAAQKfyUAAgkACAkEIdASAAsDAAkACAkEIdASAAsDAAAA.',
['天使']='天使韵律:BAAALgAECgEJAQAAAA==.',
['天天']='天天小肥牛:BAAALgAECgcJEAAAAA==.天天牛肉面:BAAALgAECgYJDgAAAA==.',
['天玄']='天玄小老二:BAAALgAFFAIJAgAAAA==.',
['天黑']='天黑黑:BAAALgAECgIJAwAAAA==.',
['头上']='头上有只角:BAAALgAECgIJAwAAAA==.',
['奥本']='奥本海默:BAAALgAECgYJBgABLgAECgYJBgAKAAAAAA==.',
['奥菲']='奥菲利亚:BAABLgAECn8UAAQIAAYJGhZqHACjAQAIAAYJGhZqHACjAQALAAUJehxrFAChAQAMAAUJBRYAAAAAAAAAAA==.',
['奧茲']='奧茲諾姆:BAAALgAECgIJAgAAAA==.',
['奶油']='奶油小鬼鬼:BAAALgAFFAEJAQAAAA==.',
['如意']='如意小瓜瓜:BAAALgAFFAIJAgAAAA==.',
['妙蛙']='妙蛙种子:BAAALgAECgEJAgAAAA==.',
['妩媚']='妩媚:BAAALgAECgEJAQAAAA==.',
['姜小']='姜小牙:BAABLgAFFH8GAAINAAMJrgRLCgDBAAANAAMJrgRLCgDBAAAAAA==.',
['嫩牛']='嫩牛五方:BAAALgAECgUJBgABLgAFFAMJBwAJAL0cAA==.',
['安吉']='安吉拉丶齊格:BAAALgADCgUJBQAAAA==.',
['封戦']='封戦:BAAALgAECgIJAgAAAA==.',
['射射']='射射:BAAALgAECgUJBwAAAA==.',
['小朋']='小朋友朋友大:BAAALgAECgcJEAAAAA==.',
['小牛']='小牛战:BAABLgAFFH8FAAIOAAMJRgGECwCQAAAOAAMJRgGECwCQAAAAAA==.',
['小瓜']='小瓜瓜:BAAALgAFFAQJBAAAAA==.',
['小胖']='小胖叮:BAAALgADCgUJBQAAAA==.',
['小魚']='小魚:BAAALgAECgMJBAAAAA==.',
['小龙']='小龙包:BAAALgAECgcJBAAAAA==.',
['尘灬']='尘灬无欲:BAAALgAECgYJDAAAAA==.',
['崶印']='崶印:BAAALgAECgEJAQAAAA==.',
['幽冥']='幽冥哈迪斯:BAAALgAECgYJDgAAAA==.',
['库克']='库克阿尔森:BAAALgAECgQJBAAAAA==.',
['库蕾']='库蕾雅:BAAALgAECgQJBAAAAA==.',
['开心']='开心的开:BAAALgAECgQJBAAAAA==.',
['开无']='开无敌逃跑:BAAALgAECgUJBwAAAA==.',
['必须']='必须德:BAAALgAECgIJAgAAAA==.',
['怒风']='怒风三少:BAAALgAECgEJAgAAAA==.',
['性感']='性感升龙:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔眼棱献祭:BAAALgADCgYJBgAAAA==.',
['慕叶']='慕叶乄血小小:BAABLgAFFH8FAAIPAAUJAAC+GQAAAAAPAAUJAAC+GQAAAAAAAA==.',
['慕斯']='慕斯灬蛋糕:BAAALgAECgUJBQAAAA==.',
['戌极']='戌极:BAAALgAECgQJBgAAAA==.',
['我咋']='我咋晓得:BAABLgAFFH8DAAIQAAIJYRZ4MgCtAAAQAAIJYRZ4MgCtAAAAAA==.',
['我性']='我性暴躁:BAAALgAECgIJAgAAAA==.我性疯狂:BAAALgADCgEJAQAAAA==.',
['我才']='我才是奶龙:BAAALgAECgYJBgAAAA==.',
['我欲']='我欲独行:BAAALgADCgEJAQAAAA==.',
['戦斧']='戦斧牛排:BAAALgAECgYJBgAAAA==.',
['手心']='手心的蔷薇:BAAALgAECgUJCQAAAA==.',
['拜勒']='拜勒蒙:BAAALgAECgEJAQAAAA==.',
['拜金']='拜金者:BAABLgAFFH8FAAIRAAIJYAz1GQCTAAARAAIJYAz1GQCTAAAAAA==.',
['捷克']='捷克弗里特:BAAALgAECgYJCQAAAA==.',
['掠影']='掠影示现:BAAALgAECgQJBAAAAA==.',
['搞清']='搞清尼三:BAAALgADCgEJAQAAAA==.',
['摄魂']='摄魂之箭:BAAALgAECgUJBQAAAA==.',
['方片']='方片杰克:BAAALgADCgUJBQAAAA==.',
['无为']='无为转变:BAAALgAECgIJAQAAAA==.',
['早乙']='早乙女露依:BAAALgADCgMJAwAAAA==.',
['时间']='时间机器:BAAALgAECgYJBgAAAA==.',
['明年']='明年今日:BAAALgAECgkJCgAAAA==.',
['星星']='星星的小坎肩:BAAALgAECgMJBQAAAA==.',
['晓德']='晓德德:BAAALgAECgYJDgAAAA==.',
['暗影']='暗影契约:BAAALgADCgUJBQAAAA==.',
['暮鸦']='暮鸦:BAAALgADCgEJAQAAAA==.',
['曵忈']='曵忈:BAAALgAECgMJAwAAAA==.',
['月亮']='月亮小船:BAAALgAFFAQJBAAAAA==.',
['月满']='月满一江水:BAAALgAECgEJAQAAAA==.',
['木丶']='木丶木:BAAALgAECgEJAQAAAA==.',
['木易']='木易巾凡:BAAALgAECgQJBgAAAA==.',
['李梦']='李梦月:BAAALgAFFAIJAwAAAA==.',
['林亚']='林亚珍:BAAALgAECgYJDAABLgAECgYJFAAIABoWAA==.',
['根哥']='根哥很莽:BAAALgADCgIJAgAAAA==.',
['橘子']='橘子:BAAALgAECgIJAgAAAA==.',
['橙子']='橙子小魔王:BAAALgAECgYJDAAAAA==.',
['正版']='正版无敌小强:BAAALgAECgkJCQAAAA==.',
['母狼']='母狼夜:BAAALgAECgYJBgAAAA==.',
['水煮']='水煮鸡胸肉:BAAALgAFFAMJBAAAAA==.',
['法力']='法力浮龙:BAAALgADCgIJAgAAAA==.',
['洞庭']='洞庭碧螺春:BAAALgAECgQJBwAAAA==.',
['活煩']='活煩丶:BAAALgADCgEJAQAAAA==.',
['浪哩']='浪哩咯浪:BAAALgADCgEJAQAAAA==.',
['浪漫']='浪漫丶饭团:BAAALgAFFAIJAwAAAA==.',
['海绵']='海绵饱饱:BAAALgAFFAEJAQAAAA==.',
['清风']='清风送雨:BAAALgADCgcJBwAAAA==.',
['游侠']='游侠兒:BAAALgAECgEJAQAAAA==.',
['潇洒']='潇洒的屠夫:BAAALgADCgEJAQAAAA==.',
['火鸡']='火鸡味鍋巴:BAAALgAECgYJCwAAAA==.',
['灬季']='灬季博达丶:BAAALgAECgUJBQAAAA==.',
['灬爱']='灬爱嘤斯坦丶:BAAALgADCgEJAQAAAA==.',
['烬中']='烬中兰槎:BAAALgAECgEJAQAAAA==.',
['無尽']='無尽之旅:BAAALgADCgYJBgAAAA==.',
['煮不']='煮不烂的牛肉:BAAALgADCgMJAwAAAA==.',
['熊小']='熊小斐:BAAALgAFFAEJAQAAAA==.',
['熊霸']='熊霸天下:BAAALgAECgEJAQAAAA==.',
['燃烧']='燃烧军团卧底:BAAALgADCgYJBgAAAA==.',
['爱吃']='爱吃鱼的牛:BAAALgADCgEJAQAAAA==.',
['爱无']='爱无心:BAAALgADCgEJBAAAAA==.',
['牛村']='牛村村花萌萌:BAAALgAFFAEJAQAAAA==.',
['牛白']='牛白玉:BAAALgADCgUJBQAAAA==.',
['牧牧']='牧牧衣:BAAALgADCgMJAwAAAA==.',
['犬来']='犬来八荒吖:BAAALgAECgEJAQAAAA==.犬来八荒呢:BAAALgAECgYJBgAAAA==.',
['狐歌']='狐歌:BAAALgAECgMJBgAAAA==.',
['狐狸']='狐狸精:BAAALgAECgQJBAAAAA==.',
['狗刨']='狗刨君:BAAALgADCgIJAgAAAA==.',
['狗啊']='狗啊狗啊:BAAALgAECgYJDwABLgAFFAUJBQASAOMEAA==.',
['独夏']='独夏孤影:BAAALgAECgYJBAAAAA==.',
['猩红']='猩红之泪:BAAALgAECgkJAwABLgAFFAQJDgAFAIgeAA==.猩红王子:BAAALgAFFAEJAQAAAA==.',
['猫猫']='猫猫头:BAAALgAECgkJCgAAAA==.',
['玉奴']='玉奴:BAABLgAECn8bAAICAAkJMCU0AADVAwACAAkJMCU0AADVAwAAAA==.',
['王思']='王思聪:BAAALgAECgYJBAAAAA==.',
['璇璇']='璇璇:BAAALgAECgEJAgAAAA==.',
['生者']='生者必灭:BAAALgAECgQJBQAAAA==.',
['疯狂']='疯狂星期四:BAAALgAECgYJBgAAAA==.',
['百事']='百事可乐:BAAALgAECgUJBQAAAA==.',
['盐焗']='盐焗芽儿丶:BAAALgAECgEJAQAAAA==.',
['直港']='直港第一划:BAAALgAECgMJBQAAAA==.',
['看啥']='看啥哈:BAAALgAFFAQJAgAAAA==.',
['石桥']='石桥:BAAALgAECgYJCQAAAA==.',
['神的']='神的启示:BAAALgADCgUJBQAAAA==.',
['种西']='种西瓜:BAACLgAFFH8JAAIJAAMJUxozIgAPAQAJAAMJUxozIgAPAQAuAAQKfxUAAgkABwmJHeMzAGcCAAkABwmJHeMzAGcCAAAA.',
['笨蛋']='笨蛋狐狸:BAAALgADCgYJCQAAAA==.',
['箭鬼']='箭鬼:BAABLgAECn8YAAMPAAcJQBylHQBUAgAPAAcJQBylHQBUAgAGAAEJ/Rh4iAAzAAAAAA==.',
['粒子']='粒子特效:BAAALgAECgIJBQAAAA==.',
['紫日']='紫日:BAABLgAECn8UAAMNAAcJTxVpIgDRAQANAAcJTxVpIgDRAQATAAQJ2AfXRQCMAAAAAA==.',
['紫水']='紫水凌月:BAAALgAECgIJAgAAAA==.',
['紫色']='紫色泡芙:BAAALgAECgYJEgAAAA==.',
['红桃']='红桃杰克:BAAALgADCgMJAwAAAA==.',
['纷乱']='纷乱雪月花:BAAALgAECgEJAQAAAA==.',
['织雾']='织雾踏风酒仙:BAAALgADCgYJCwAAAA==.',
['绿痕']='绿痕:BAAALgAECgIJAgAAAA==.',
['绿野']='绿野梦德:BAAALgAECgEJAQAAAA==.',
['罓骑']='罓骑士:BAAALgAECgkJCQAAAA==.',
['翼柳']='翼柳浮洋:BAAALgAECgkJCQAAAA==.',
['老当']='老当益壮:BAAALgAECgMJBAAAAA==.',
['老衲']='老衲法号三髒:BAAALgAECgIJAgAAAA==.',
['耙脚']='耙脚猥丶:BAAALgAFFAMJBAAAAA==.',
['聖骑']='聖骑仕:BAAALgADCgMJAwAAAA==.',
['胖胖']='胖胖咕:BAAALgAECgQJBwAAAA==.',
['芝芝']='芝芝舒芙蕾:BAAALgAFFAIJAwAAAA==.',
['荼蔓']='荼蔓:BAAALgADCgYJBgAAAA==.',
['萨灼']='萨灼嗜引:BAAALgAECgIJAwAAAA==.',
['藍染']='藍染惣右介:BAAALgAECgYJDQAAAA==.',
['豹抱']='豹抱就鮑爆:BAAALgAECgEJAQAAAA==.',
['贰灬']='贰灬减:BAAALgAECgYJCQAAAA==.',
['赛伊']='赛伊德:BAAALgAFFAIJAgAAAA==.',
['赵剑']='赵剑云:BAAALgAECgEJAQAAAA==.',
['起舞']='起舞弄清影:BAAALgADCgIJAgAAAA==.',
['路灯']='路灯下水电费:BAAALgAECgUJBwAAAA==.',
['达德']='达德丶光刃:BAAALgAECgEJAgAAAA==.',
['远兮']='远兮哲别:BAAALgAECgQJAQAAAA==.',
['追星']='追星逐月:BAAALgAECgUJBgAAAA==.',
['邦比']='邦比爱塔:BAAALgAECgYJBgAAAA==.',
['邪月']='邪月吟诵者:BAAALgAECgYJBgAAAA==.',
['酥式']='酥式十八段:BAAALgAECgYJCAAAAA==.',
['钙奶']='钙奶:BAAALgAECgYJEAAAAA==.',
['钙拾']='钙拾舞霜:BAAALgAECgUJBQAAAA==.',
['钢铁']='钢铁风筝:BAAALgAECgYJCQAAAA==.',
['長泽']='長泽雅美:BAAALgAFFAIJAwAAAA==.',
['阿古']='阿古贼且捏:BAAALgAECgIJAgAAAA==.',
['阿尔']='阿尔蒂拉:BAAALgAECgMJAwAAAA==.',
['阿斯']='阿斯顿飞:BAAALgAFFAIJAgABLgAFFAgJGgAFAHwmAA==.',
['阿瓦']='阿瓦达肯大瓜:BAAALgAECgEJAgAAAA==.',
['陆丶']='陆丶风林火山:BAAALgAFFAIJAgAAAA==.',
['陈凭']='陈凭案:BAAALgAECgcJBwAAAA==.',
['陈十']='陈十四:BAAALgAFFAIJAwAAAA==.',
['雷兙']='雷兙萨:BAAALgAECgEJAQAAAA==.',
['雷声']='雷声普化天尊:BAAALgAECgUJBQAAAA==.',
['露茜']='露茜范佩尔特:BAABLgAFFH8KAAIRAAQJkRVcDgD3AAARAAQJkRVcDgD3AAAAAA==.',
['风暴']='风暴烈酒老牛:BAAALgAECgIJAgAAAA==.',
['风梳']='风梳灬烟沐:BAAALgAECgIJAgAAAA==.',
['风牧']='风牧九州:BAAALgAECgEJAQAAAA==.',
['骑幻']='骑幻:BAAALgAECgYJDQAAAA==.',
['高一']='高一高:BAAALgAECgYJCgAAAA==.',
['魅惑']='魅惑深紫:BAAALgAECgcJCgAAAA==.',
['魔丸']='魔丸:BAAALgAECgUJBQAAAA==.',
['魔鬼']='魔鬼筋肉熊:BAAALgADCgMJAwAAAA==.',
['鱼干']='鱼干爱次糖:BAAALgAECgUJCAAAAA==.',
['麦麦']='麦麦宝:BAAALgAECgcJBwAAAA==.麦麦龙:BAAALgAECggJDAAAAA==.',
['黑夜']='黑夜召唤:BAAALgAECgIJAgAAAA==.',
['黑手']='黑手二号:BAAALgAECgQJBAAAAA==.',
['黑煤']='黑煤炭丶:BAAALgAFFAIJAwAAAA==.',
['黑糖']='黑糖啵啵:BAAALgAECgEJAQAAAA==.',
['黑葡']='黑葡萄:BAAALgAECgUJCQAAAA==.',
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
