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

local lookup = {'Warrior-Protection','Paladin-Holy','Paladin-Retribution','Monk-Brewmaster','Shaman-Restoration','Mage-Frost','Unknown-Unknown','Priest-Discipline','Warlock-Demonology','Warrior-Fury','DemonHunter-Havoc','Monk-Windwalker',}
local provider = {region='CN',realm='奥达曼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akiyamamiov:BAACLgAFFH8HAAIBAAMJ4BLBAwDeAAABAAMJ4BLBAwDeAAAuAAQKfyEAAgEACAl4HzwGAM4CAAEACAl4HzwGAM4CAAAA.',
Cm='Cmelon:BAAALgAECgEJAQAAAA==.',
Da='Daddyfacker:BAAALgAFFAEJAgAAAA==.',
Ei='Eim:BAAALgAECgUJBQAAAA==.',
Em='Ember:BAAALgAFFAIJAwAAAA==.',
Fi='Filson:BAAALgAFFAIJAwAAAA==.',
Ha='Hawk:BAAALgAECgEJAQAAAA==.',
Hs='Hsdsx:BAAALgADCgEJAQAAAA==.',
Jb='Jbl:BAAALgADCgYJBwAAAA==.',
La='Lachesis:BAAALgAECgYJBwAAAA==.',
Li='Lihudrain:BAAALgAECgYJCwAAAA==.',
Ly='Lyp:BAAALgAECgEJAQAAAA==.',
Me='Metagalaxy:BAAALgAECgQJBAAAAA==.',
Mi='Minerva:BAABLgAFFH8FAAICAAIJGhiqFACbAAACAAIJGhiqFACbAAAAAA==.',
Mo='Mogeko:BAAALgAECgQJBAAAAA==.',
Ri='Ritatan:BAAALgAECgEJAgAAAA==.',
Se='Seki:BAAALgADCgcJDgAAAA==.',
Sk='Skyrock:BAAALgADCgEJAQAAAA==.',
Sp='Spoobb:BAAALgADCgYJBgAAAA==.',
Sw='Swallowhawk:BAAALgADCgEJAgAAAA==.',
Ur='Urmyservant:BAAALgADCgQJBAAAAA==.',
Ve='Velareth:BAAALgAECgIJAgAAAA==.',
Wa='Wa:BAAALgAECgUJBQAAAA==.',
Wy='Wyrd:BAAALgAECgUJCwAAAA==.',
Xi='Xias:BAAALgADCgYJBgAAAA==.',
Ya='Yatlantis:BAAALgAECgEJAQAAAA==.',
['一只']='一只小滴凯:BAAALgAECgMJAwAAAA==.',
['七夜']='七夜橙子:BAAALgAECgIJAwAAAA==.',
['七帝']='七帝:BAAALgADCgMJAwAAAA==.',
['万俟']='万俟翔幻:BAABLgAECn8WAAMDAAcJ0hVYXgDIAQADAAcJ0hVYXgDIAQACAAIJ1QJCjABNAAAAAA==.',
['三月']='三月:BAAALgAECgIJAwAAAA==.',
['上帝']='上帝:BAAALgAECgEJAQAAAA==.',
['不玩']='不玩惩戒骑:BAAALgAECgkJCQAAAA==.',
['不祥']='不祥的交响乐:BAAALgAFFAEJAQAAAA==.',
['丛林']='丛林之魂:BAAALgAECgYJCQAAAA==.',
['丶放']='丶放开那嫂嫂:BAABLgAFFH8JAAIEAAUJfA7OBgBmAQAEAAUJfA7OBgBmAQAAAA==.',
['丷紫']='丷紫川:BAAALgAECgkJDwAAAA==.',
['丹寳']='丹寳寳:BAAALgADCgEJAQAAAA==.',
['云语']='云语梦:BAAALgAECgYJBwAAAA==.',
['云销']='云销雨霁:BAAALgAECgkJCQABLgAFFAQJCAADAJEaAA==.',
['伊晓']='伊晓万:BAAALgADCgcJCAAAAA==.',
['伊露']='伊露维恩:BAAALgADCgcJBwAAAA==.',
['假面']='假面涅盘:BAAALgADCgEJAQAAAA==.',
['光头']='光头交好运:BAAALgAECgMJBQAAAA==.',
['光明']='光明传奇:BAAALgADCgYJBwAAAA==.',
['光頭']='光頭文:BAAALgADCgEJAQAAAA==.',
['关山']='关山月游侠儿:BAAALgADCgEJAQAAAA==.',
['军团']='军团大当家:BAAALgAECgMJAwAAAA==.',
['冬夜']='冬夜蔷薇:BAAALgAECgYJBQAAAA==.',
['冬枯']='冬枯草:BAAALgAECgcJDQAAAA==.',
['冰棒']='冰棒好冰:BAAALgAFFAEJAQAAAA==.',
['凉灬']='凉灬裂爪:BAAALgAECgYJBgAAAA==.',
['别被']='别被我忽悠:BAABLgAFFH8GAAIFAAIJxRnUFQCpAAAFAAIJxRnUFQCpAAAAAA==.',
['劉鞴']='劉鞴丈夫:BAAALgAECgMJBgAAAA==.',
['十一']='十一点:BAAALgAECgYJCAAAAA==.',
['千束']='千束:BAAALgAECgEJAgAAAA==.',
['卡多']='卡多雷之愛:BAAALgAFFAIJBAAAAA==.',
['及时']='及时护住脸:BAABLgAFFH8GAAIGAAMJww9cLgD9AAAGAAMJww9cLgD9AAAAAA==.',
['可达']='可达鸭:BAAALgAECgkJDwAAAA==.',
['叶公']='叶公龙:BAAALgAECgUJBgAAAA==.',
['叶飘']='叶飘飘:BAAALgADCgkJCwAAAA==.',
['吉矮']='吉矮娜:BAAALgAECgYJEQAAAA==.',
['吕小']='吕小布:BAAALgADCgYJBgAAAA==.',
['咿呀']='咿呀喂:BAAALgAECgUJBgAAAA==.',
['响灬']='响灬铃:BAAALgADCgEJAgAAAA==.',
['哟哟']='哟哟帅气:BAAALgAECgMJAgAAAA==.',
['哥布']='哥布林大王:BAAALgADCgYJBgAAAA==.',
['哪个']='哪个德:BAAALgADCgIJAgAAAA==.',
['唐纳']='唐纳德:BAAALgAECgEJAQABLgAECgYJBgAHAAAAAA==.',
['啊哟']='啊哟喂丶铜须:BAAALgAECgYJBwAAAA==.',
['喵呜']='喵呜虾:BAAALgAECgYJBgAAAA==.',
['喵小']='喵小调的哼鸣:BAABLgAECn8WAAIIAAYJHxlFGwC9AQAIAAYJHxlFGwC9AQAAAA==.',
['噎死']='噎死人生的人:BAABLgAECn8VAAIJAAYJpRVJbACJAQAJAAYJpRVJbACJAQAAAA==.',
['噬灵']='噬灵天火:BAAALgAECgYJCwAAAA==.',
['回归']='回归基本功:BAABLgAFFH8HAAIEAAQJXxFgCwArAQAEAAQJXxFgCwArAQAAAA==.',
['土豆']='土豆不吃牛肉:BAAALgAECgEJAQAAAA==.',
['圣丨']='圣丨骑丨士丨:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱邮差:BAAALgAECgUJCwAAAA==.',
['埃德']='埃德尼特:BAAALgAECgcJDAAAAA==.',
['城西']='城西徐工:BAABLgAECn8UAAIGAAgJzh8EHwD5AgAGAAgJzh8EHwD5AgAAAA==.',
['塔牌']='塔牌:BAAALgADCgUJBQAAAA==.',
['夏末']='夏末挽歌:BAAALgAFFAMJAwAAAA==.',
['夏花']='夏花糕点师:BAAALgAECgUJBQAAAA==.',
['夜丶']='夜丶且听风吟:BAAALgAECgEJAQAAAA==.夜丶流星丨雨:BAAALgAFFAEJAQAAAA==.',
['夜灬']='夜灬流星丨雨:BAAALgAECgEJAgAAAA==.',
['大耐']='大耐无疆:BAAALgAECgYJCAAAAA==.',
['大虾']='大虾米:BAAALgAECgEJAQAAAA==.',
['天水']='天水一方:BAAALgADCgEJAQAAAA==.',
['天涯']='天涯荣成:BAAALgAECgYJBgAAAA==.天涯轩轩:BAAALgAECgEJAQAAAA==.',
['天灵']='天灵灵:BAAALgAECgQJBAAAAA==.',
['天青']='天青的骑士:BAAALgAECgQJBQAAAA==.',
['奇迹']='奇迹我信了:BAAALgAECgQJBwAAAA==.',
['奈奎']='奈奎思特:BAAALgAECgcJAgAAAA==.',
['奥灬']='奥灬法:BAAALgAECgEJAQAAAA==.',
['奶嘴']='奶嘴:BAAALgAECgYJBwAAAA==.',
['好吃']='好吃的罐头:BAAALgADCgEJAQAAAA==.',
['姬丝']='姬丝秀忒:BAAALgAECgEJAQAAAA==.',
['安娜']='安娜贝尔:BAAALgADCgEJAwAAAA==.',
['安静']='安静忻岚:BAAALgAECgcJCAAAAA==.',
['宝囡']='宝囡囡:BAAALgADCggJCQAAAA==.',
['害怕']='害怕:BAAALgAECgYJBgAAAA==.',
['小天']='小天使宁静:BAAALgAECgEJAgAAAA==.',
['尤哥']='尤哥叫大家:BAAALgAECgYJEAAAAA==.',
['希格']='希格海勒:BAAALgAECgMJAwAAAA==.',
['库丘']='库丘林:BAAALgAECgcJCwAAAA==.',
['开水']='开水烫咕咕:BAAALgAECgEJAgAAAA==.',
['德奶']='德奶妮:BAAALgAECgIJAgAAAA==.',
['心碎']='心碎的海明威:BAAALgADCgcJCwAAAA==.',
['悠悠']='悠悠清水:BAAALgADCgEJAQAAAA==.',
['惊破']='惊破天:BAAALgAECgIJAwAAAA==.',
['惩戒']='惩戒之刃:BAAALgAECgQJBgAAAA==.',
['我会']='我会开无敌:BAACLgAFFH8FAAIDAAIJYhtBHQC4AAADAAIJYhtBHQC4AAAuAAQKfyAAAgMACAk5IyoTAPkCAAMACAk5IyoTAPkCAAAA.',
['战争']='战争狂人:BAACLgAFFH8JAAIKAAMJtxyJDwAOAQAKAAMJtxyJDwAOAQAuAAQKfyMAAwoACAl9INQIAB4DAAoACAl9INQIAB4DAAEAAQlRC+dHAC8AAAAA.',
['战魂']='战魂殤:BAAALgAECgEJAQAAAA==.',
['抵消']='抵消分录:BAAALgAECgQJCQAAAA==.',
['掏耳']='掏耳朵:BAAALgADCgQJAwAAAA==.',
['撕裂']='撕裂重罪:BAAALgAECgEJAQAAAA==.',
['斯维']='斯维恩:BAAALgAECgEJAQAAAA==.',
['无光']='无光之盾:BAAALgAECgMJBgAAAA==.',
['无敌']='无敌霹雳:BAAALgADCgYJBgAAAA==.',
['时光']='时光少年:BAAALgAECgYJCwAAAA==.',
['晨鑫']='晨鑫:BAAALgAECgEJAQAAAA==.',
['普罗']='普罗旺斯的风:BAAALgAECgQJBAAAAA==.',
['暗影']='暗影相随:BAAALgAECgcJEwAAAA==.暗影相随痛:BAAALgAECgUJBQAAAA==.',
['月半']='月半月半口达:BAAALgAECgEJAQAAAA==.',
['月微']='月微凉:BAAALgADCgYJCwAAAA==.',
['月落']='月落咕啼:BAAALgAECgEJAQAAAA==.',
['月陨']='月陨弦歌:BAAALgADCgcJCgAAAA==.',
['李小']='李小毛:BAAALgAFFAQJBAAAAA==.',
['杨嘤']='杨嘤:BAAALgAECgEJAQAAAA==.',
['棍捣']='棍捣橘芯:BAAALgADCgEJAQAAAA==.',
['樶爱']='樶爱丶蕾:BAAALgAECgYJCgAAAA==.',
['武夷']='武夷君:BAAALgADCgYJBgAAAA==.',
['水淼']='水淼丶:BAAALgADCgYJBgAAAA==.',
['永生']='永生灭:BAAALgAECgIJBQAAAA==.',
['江一']='江一沃里克:BAAALgAECgYJDgAAAA==.',
['汤汤']='汤汤不吃不吃:BAAALgAECgEJAQAAAA==.',
['沪小']='沪小白的拉拉:BAAALgAECgEJAgAAAA==.',
['法丨']='法丨丨师:BAAALgAECgYJCwAAAA==.',
['泰瑞']='泰瑞尓:BAAALgAECgYJCwAAAA==.',
['海豚']='海豚音刷新:BAAALgAECgEJAgAAAA==.',
['混沌']='混沌魅魔:BAAALgAECgEJAQAAAA==.',
['清水']='清水幽幽:BAAALgADCgYJBgAAAA==.清水悠悠:BAAALgADCgUJBQAAAA==.清水清悦:BAAALgADCggJBAAAAA==.',
['清清']='清清凉凉:BAAALgADCgEJAgAAAA==.清清晾晾:BAAALgADCgEJAQAAAA==.',
['灬壹']='灬壹怒爲紅顔:BAABLgAFFH8FAAILAAUJ5RnFAADFAQALAAUJ5RnFAADFAQAAAA==.',
['灬夏']='灬夏末丶秋至:BAAALgADCgcJBwABLgAFFAYJEwADAMggAA==.',
['灬小']='灬小保灬:BAAALgAECgYJBgAAAA==.',
['熊圈']='熊圈名媛:BAAALgAECgYJBgAAAA==.',
['熊猫']='熊猫师娘:BAAALgAECgEJAQAAAA==.熊猫爱薇:BAAALgADCgQJBAAAAA==.',
['燃烧']='燃烧的大鸡:BAAALgAECgYJBgAAAA==.',
['牛初']='牛初乳:BAAALgADCgIJAgAAAA==.',
['狂妄']='狂妄拽拽:BAABLgAFFH8GAAIDAAIJEhdeDgCwAAADAAIJEhdeDgCwAAAAAA==.',
['猎天']='猎天岚:BAAALgAECgkJEgAAAA==.',
['玉子']='玉子:BAAALgADCgQJBAAAAA==.',
['瑶光']='瑶光圣女:BAAALgADCgUJBQAAAA==.',
['白白']='白白不白白:BAABLgAECn8WAAIEAAcJUgpKPgBMAQAEAAcJUgpKPgBMAQAAAA==.',
['百鹤']='百鹤无双:BAAALgAECgEJAQAAAA==.',
['看汐']='看汐:BAAALgAECgEJAQAAAA==.',
['碧霞']='碧霞门龙鳞马:BAAALgADCgIJAgAAAA==.',
['祁有']='祁有雌理:BAACLgAFFH8GAAIGAAIJdwKtSQCaAAAGAAIJdwKtSQCaAAAuAAQKfxQAAgYABgneGoKYAKQBAAYABgneGoKYAKQBAAAA.',
['祖黎']='祖黎:BAAALgAECgMJAwAAAA==.',
['神皇']='神皇在上:BAAALgAECgEJAQAAAA==.',
['神罚']='神罚混沌:BAAALgADCgEJAQAAAA==.',
['笙枫']='笙枫:BAAALgAECgQJBgAAAA==.',
['答应']='答应不愛你:BAAALgAFFAEJAQABLgAFFAUJAQAHAAAAAA==.',
['答案']='答案:BAAALgADCgEJAgAAAA==.',
['米兰']='米兰的打铁匠:BAAALgAECgUJBQABLgAECgYJBgAHAAAAAA==.',
['糖果']='糖果有毒:BAAALgAECgQJBQAAAA==.',
['糖糖']='糖糖小菜:BAAALgADCgIJAwAAAA==.',
['紫凝']='紫凝:BAAALgAECgUJBQABLgAECgYJBgAHAAAAAA==.',
['维他']='维他柠檬茶:BAAALgAECgIJAgAAAA==.',
['罗莎']='罗莎琳德:BAAALgAECgUJBQAAAA==.',
['羽歌']='羽歌:BAAALgADCgQJBAAAAA==.',
['老董']='老董赞达拉萨:BAAALgADCgYJBgAAAA==.',
['老衲']='老衲要还俗:BAAALgADCgUJBQAAAA==.',
['聆聽']='聆聽者丨風玲:BAAALgAECgEJAQAAAA==.',
['胖虎']='胖虎:BAAALgADCgEJAQAAAA==.',
['脸大']='脸大:BAAALgAECgYJDgAAAA==.',
['艾尔']='艾尔比顺:BAAALgAECgYJCwAAAA==.',
['芬理']='芬理尔:BAAALgAECgYJEAAAAA==.',
['莎蔓']='莎蔓莎:BAABLgAFFH8HAAIMAAQJ9gfDBQAmAQAMAAQJ9gfDBQAmAQAAAA==.',
['莴苣']='莴苣女士:BAAALgAECgEJAQAAAA==.',
['萨切']='萨切斯:BAAALgADCgUJBgAAAA==.',
['薄樱']='薄樱:BAAALgAECgcJAQAAAA==.',
['蚑蚑']='蚑蚑:BAAALgAECggJDQAAAA==.',
['蟹耳']='蟹耳朵:BAAALgAECgQJBQAAAA==.',
['血色']='血色洗礼:BAACLgAFFH8XAAIGAAYJWCO0AAD9AQAGAAYJWCO0AAD9AQAuAAQKfxoAAgYACQm5I8IQAEMDAAYACQm5I8IQAEMDAAAA.',
['西优']='西优洁兰:BAAALgAECgIJBQAAAA==.',
['角落']='角落微光:BAAALgADCgEJAQAAAA==.',
['誓约']='誓约胜利之剑:BAAALgAECgYJBgAAAA==.',
['诗歌']='诗歌剧:BAAALgAECgYJCwAAAA==.',
['豪七']='豪七丶:BAAALgADCgUJJwAAAA==.',
['超级']='超级小龙人:BAAALgAECgMJAwAAAA==.',
['遥远']='遥远的心:BAAALgAECgQJAwAAAA==.',
['那法']='那法師:BAAALgADCgYJCgAAAA==.',
['部落']='部落丶话事人:BAAALgAECgUJCgAAAA==.',
['郭将']='郭将军:BAAALgADCgEJAQAAAA==.',
['鎏鑫']='鎏鑫:BAAALgAECgcJDAAAAA==.',
['铜葫']='铜葫芦:BAAALgAECgQJBAAAAA==.',
['银月']='银月之星:BAAALgAFFAIJBAAAAA==.',
['长崎']='长崎爽世:BAAALgAECgUJBQABLgAECgcJEwAHAAAAAA==.',
['阿尔']='阿尔凯特:BAAALgAECgIJAgAAAA==.',
['阿祖']='阿祖没时间:BAAALgAFFAMJAwAAAA==.',
['阿衡']='阿衡:BAAALgADCgUJBQAAAA==.',
['陆丶']='陆丶风暴烈酒:BAAALgAECgEJAQAAAA==.',
['雨丰']='雨丰:BAAALgAECgYJDwAAAA==.',
['霜月']='霜月影巅:BAAALgAECgkJDQAAAA==.',
['霜火']='霜火行者:BAAALgAECgkJCQAAAA==.',
['青莲']='青莲之炎:BAAALgAFFAEJAgAAAA==.',
['风中']='风中摇曳桃子:BAAALgADCgcJBwAAAA==.',
['风间']='风间爱:BAAALgAECgIJAgAAAA==.',
['飘摇']='飘摇的风筝:BAAALgAECgMJBAAAAA==.',
['飞龙']='飞龙一族:BAAALgAECgEJAQAAAA==.',
['魅惑']='魅惑骑士:BAAALgAECgYJBwAAAA==.',
['魑魅']='魑魅魍魉魍魉:BAAALgAECgQJBwAAAA==.',
['魔鬼']='魔鬼小情人:BAAALgAECgEJAgAAAA==.',
['鸡米']='鸡米头:BAAALgAECgEJAQAAAA==.',
['麻倉']='麻倉憂:BAAALgAECgQJBQAAAA==.',
['黄昏']='黄昏现白骨:BAAALgAECgEJAQAAAA==.',
['黎明']='黎明前的灯火:BAAALgAECgEJAQAAAA==.',
['龍鳞']='龍鳞馬:BAAALgAECgYJDgAAAA==.',
['龙鳞']='龙鳞马:BAAALgADCgIJAgAAAA==.',
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
