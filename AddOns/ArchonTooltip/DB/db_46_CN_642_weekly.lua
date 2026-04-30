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

local lookup = {'Evoker-Preservation','Paladin-Retribution','Druid-Balance','Evoker-Augmentation','Evoker-Devastation','Unknown-Unknown','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Restoration','Mage-Frost','Druid-Guardian','Warrior-Arms','Warrior-Fury','DemonHunter-Havoc','DemonHunter-Devourer','DemonHunter-Vengeance','Shaman-Restoration','Priest-Discipline','Priest-Shadow','Monk-Brewmaster','Paladin-Holy',}
local provider = {region='CN',realm='奥拉基尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aether:BAAALgAECgkJEAAAAA==.',
Am='Amoris:BAAALgADCgYJBgABLgAFFAIJBgABACMNAA==.',
Bl='Blacksheep:BAAALgAECgQJBwAAAA==.Bleach:BAAALgAECgIJAwAAAA==.',
Bu='Burningsword:BAAALgADCgEJAQAAAA==.',
Co='Core:BAAALgAECgEJAQAAAA==.',
Cr='Croft:BAAALgAECgYJDgAAAA==.',
Em='Emmazhang:BAAALgAECgEJAQAAAA==.',
En='Enkhamgahan:BAAALgAECgYJBgAAAA==.',
Et='Eth:BAAALgAFFAUJBAAAAA==.',
Fe='Felix:BAACLgAFFH8IAAICAAMJKhyoEQAYAQACAAMJKhyoEQAYAQAuAAQKfxQAAgIACAmkIf4XANkCAAIACAmkIf4XANkCAAAA.',
Gr='Groott:BAAALgAFFAIJBAAAAA==.',
Ll='Llsxjr:BAAALgAECgYJBgAAAA==.',
Lu='Luckymage:BAAALgAFFAEJAQAAAA==.Luckymouse:BAAALgAECgMJBgAAAA==.Luda:BAAALgAECgUJBwAAAA==.',
Ma='Madara:BAABLgAFFH8MAAIDAAQJ2xOZAwA8AQADAAQJ2xOZAwA8AQAAAA==.',
Mo='Mokoko:BAAALgAECgEJAgAAAA==.Mortis:BAABLgAFFH8GAAQBAAIJIw3fEgCWAAABAAIJIw3fEgCWAAAEAAEJqh3jDwBcAAAFAAEJrwNoCwBLAAAAAA==.',
Ou='Oublier:BAAALgAECgEJAQABLgAECgcJCgAGAAAAAA==.',
Pe='Pepe:BAAALgAFFAIJAQAAAA==.',
Re='Rebirth:BAABLgAFFH8GAAIHAAIJFiAxMgDAAAAHAAIJFiAxMgDAAAAAAA==.',
Ro='Rockyou:BAAALgAECgcJDQAAAA==.',
Si='Silense:BAAALgADCgUJBQAAAA==.',
So='Sol:BAAALgAFFAMJAQABLgAFFAgJAQAGAAAAAA==.',
Su='Suffit:BAAALgAECgYJBgAAAA==.',
Sz='Szi:BAAALgAECgUJBwAAAA==.',
Th='Thatman:BAAALgAECgYJBgAAAA==.',
['一十']='一十六:BAABLgAFFH8HAAIEAAQJ5hszCQBbAQAEAAQJ5hszCQBbAQABLgAFFAcJCAAEAFQfAA==.',
['一地']='一地的篮子:BAAALgADCgQJBAAAAA==.',
['一射']='一射满天下:BAAALgAECgMJAwAAAA==.',
['一百']='一百一:BAABLgAFFH8FAAIEAAUJ/A86BgCYAQAEAAUJ/A86BgCYAQAAAA==.',
['一队']='一队剃:BAAALgAECgcJEAAAAA==.',
['一鸟']='一鸟一天堂:BAAALgAFFAEJAQAAAA==.',
['三十']='三十九:BAABLgAFFH8IAAIEAAUJVB85BADOAQAEAAUJVB85BADOAQAAAA==.',
['不打']='不打三角洲:BAAALgAFFAIJBAAAAA==.',
['不肯']='不肯過江東:BAAALgADCgEJAQABLgAFFAEJAwAGAAAAAA==.',
['不负']='不负昭华:BAAALgAECgQJBQAAAA==.',
['东方']='东方歌白:BAAALgAECggJCwAAAA==.',
['丨莺']='丨莺丨歌丨:BAAALgAECgMJBAAAAA==.',
['中年']='中年大叔:BAAALgAFFAEJAQAAAA==.',
['丶浅']='丶浅梦:BAAALgAECgcJCgAAAA==.',
['举剑']='举剑化身为光:BAAALgADCgEJAQAAAA==.',
['之后']='之后:BAAALgAECgEJAQAAAA==.',
['九彡']='九彡叁:BAAALgAECgIJAgAAAA==.',
['二月']='二月花开:BAAALgAECgEJAQAAAA==.',
['二营']='二营长:BAAALgAECggJDgAAAA==.',
['云岫']='云岫:BAAALgAFFAIJAwAAAA==.',
['云鬼']='云鬼氵炎:BAAALgADCgEJAQAAAA==.',
['五十']='五十五:BAAALgAFFAYJBAAAAA==.',
['亚萨']='亚萨星耀:BAAALgAFFAIJAwAAAA==.',
['享大']='享大福:BAAALgAFFAIJAwAAAA==.',
['仅仅']='仅仅一笑而过:BAAALgADCgUJBQAAAA==.',
['以乐']='以乐之名:BAAALgAECgEJAQAAAA==.',
['以床']='以床丶会友:BAAALgADCgIJAgAAAA==.',
['会溜']='会溜达的萝卜:BAABLgAECn8VAAMIAAkJkCDoBwAdAwAIAAkJPCDoBwAdAwAJAAIJMyTBmACjAAAAAA==.',
['会飞']='会飞的法尸:BAAALgAECgcJCwAAAA==.',
['传说']='传说就是哥:BAAALgAECgYJBgAAAA==.',
['伸腿']='伸腿瞪眼丸:BAAALgADCgEJAQAAAA==.',
['体面']='体面人:BAAALgADCgEJAQAAAA==.',
['你都']='你都没葱高:BAAALgAFFAEJAgAAAA==.',
['倾城']='倾城一箭:BAAALgAECgcJCQAAAA==.倾城笑靥:BAAALgAECgEJAQAAAA==.',
['偏执']='偏执:BAAALgADCgEJAQAAAA==.',
['光辉']='光辉之主:BAAALgADCgMJAwAAAA==.',
['兰斯']='兰斯络特:BAAALgAECgIJAwAAAA==.',
['关羽']='关羽:BAAALgAFFAUJBAAAAA==.',
['冈拉']='冈拉美朵:BAAALgADCgQJBAAAAA==.',
['冰封']='冰封的八氵壹:BAAALgAECgUJBgAAAA==.',
['凋零']='凋零小奶糕:BAAALgAECgYJBgAAAA==.',
['凌霄']='凌霄冲击:BAAALgAECgUJBQAAAA==.',
['凛冬']='凛冬丨将至:BAABLgAFFH8IAAIHAAIJrSOeNwCsAAAHAAIJrSOeNwCsAAAAAA==.',
['凝殇']='凝殇雨霏:BAAALgAECgQJBAAAAA==.',
['剑来']='剑来丶:BAAALgAECgQJBQAAAA==.',
['北京']='北京搞耍王:BAAALgAECgIJAwAAAA==.',
['半夜']='半夜挠墙:BAAALgADCgIJAgAAAA==.',
['卖女']='卖女孩的小花:BAAALgADCgEJAQABLgAECggJEgAGAAAAAA==.',
['原天']='原天衣:BAAALgADCgEJAQAAAA==.',
['发條']='发條橙子:BAAALgADCgEJAQAAAA==.',
['变身']='变身汤圆:BAABLgAFFH8KAAIKAAQJWyT3AwCjAQAKAAQJWyT3AwCjAQAAAA==.',
['叙缘']='叙缘:BAAALgAECgYJCQAAAA==.',
['只是']='只是天赋而已:BAAALgAECgEJAQAAAA==.',
['可口']='可口香蕉:BAABLgAECn8dAAICAAgJIB1DHgC2AgACAAgJIB1DHgC2AgAAAA==.',
['吉祥']='吉祥果果:BAAALgAFFAIJAgAAAA==.',
['呲花']='呲花带闪电:BAAALgAECgYJDAAAAA==.',
['咹卟']='咹卟哩喔啵:BAAALgADCgIJAgAAAA==.',
['啊巴']='啊巴啊巴:BAAALgADCgYJCwAAAA==.',
['喵咪']='喵咪萌萌哒:BAAALgAECgQJAwAAAA==.',
['喵喵']='喵喵皮:BAAALgAECgYJBgAAAA==.',
['嗷嗷']='嗷嗷叫唤:BAAALgAECgIJAgAAAA==.',
['四十']='四十九:BAABLgAFFH8LAAIEAAYJ6x5+AQBcAgAEAAYJ6x5+AQBcAgABLgAFFAcJCAAEAFQfAA==.',
['国服']='国服第一蓝牛:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光永存:BAAALgAECgcJEgAAAA==.圣光的复仇:BAAALgAECgUJBgAAAA==.圣光的正义:BAAALgAECgIJAgAAAA==.',
['坚强']='坚强的牙签:BAAALgAECgQJCAAAAA==.',
['堕落']='堕落的圣光:BAAALgAECgEJAgAAAA==.',
['壹玖']='壹玖贰叁:BAAALgADCgEJAQAAAA==.',
['夜雨']='夜雨风华:BAABLgAFFH8HAAIJAAMJ9RXUCgALAQAJAAMJ9RXUCgALAQABLgAFFAcJCgALAO4cAA==.',
['大威']='大威天龙:BAAALgADCgEJAQAAAA==.',
['大宗']='大宗师:BAAALgAECgEJAQAAAA==.',
['大摆']='大摆锤:BAAALgAECgUJBQAAAA==.',
['大流']='大流氓:BAAALgADCgYJBwAAAA==.',
['大爱']='大爱糖醋鱼:BAAALgAECgYJDAAAAA==.',
['大蟒']='大蟒蛇嗷呜:BAAALgAECgYJBwAAAA==.大蟒蛇嗷唔:BAAALgADCgIJAgAAAA==.',
['太寿']='太寿鸠毛:BAAALgAECgUJBQAAAA==.',
['奈烙']='奈烙:BAAALgAECgYJCAAAAA==.',
['奔翎']='奔翎:BAAALgAECgUJBQAAAA==.',
['奔跑']='奔跑的大碗茶:BAAALgAECgkJCQAAAA==.',
['奶萨']='奶萨蛮:BAAALgAECgUJBQAAAA==.',
['奶香']='奶香小桔子:BAAALgAFFAEJAQAAAA==.',
['妖妖']='妖妖凌:BAAALgAECgYJDgAAAA==.',
['孟夢']='孟夢:BAAALgAECgkJBQAAAA==.',
['孤独']='孤独圣光:BAAALgAECgYJEQAAAA==.',
['宝日']='宝日龙梅:BAAALgAECgYJCgAAAA==.',
['寅溟']='寅溟:BAABLgAFFH8HAAIMAAIJmAJPBgBIAAAMAAIJmAJPBgBIAAAAAA==.',
['寒酥']='寒酥:BAAALgAECgEJAQAAAA==.',
['小手']='小手丶炽热:BAABLgAECn8eAAMNAAgJRBZgBwBJAgANAAgJRBZgBwBJAgAOAAQJ4RT1bAACAQAAAA==.',
['小猪']='小猪丶佩奇:BAAALgAECgkJEgAAAA==.',
['小胖']='小胖丶哥哥:BAAALgAECgMJAwAAAA==.',
['屠日']='屠日者:BAAALgAFFAIJAwAAAA==.',
['峙命']='峙命:BAAALgAECgcJEgAAAA==.',
['巨无']='巨无霸:BAAALgAECgEJAQAAAA==.',
['布布']='布布汪:BAAALgADCgcJBwAAAA==.',
['幻无']='幻无殇:BAAALgAECgQJBAAAAA==.',
['廿廿']='廿廿:BAAALgADCgYJBgAAAA==.',
['弓弯']='弓弯羽落:BAAALgAECgEJAQAAAA==.',
['张可']='张可以:BAAALgAECgMJBQAAAA==.张可可:BAAALgAECgYJDQAAAA==.',
['影梦']='影梦十年:BAAALgAECgQJBAAAAA==.',
['忘却']='忘却是种思念:BAAALgAECgYJCwAAAA==.',
['忘尘']='忘尘无忧:BAAALgAECgUJBQAAAA==.',
['恶灵']='恶灵曲:BAAALgAECgkJCAAAAA==.',
['恶魔']='恶魔灵:BAAALgAECgUJBgAAAA==.',
['愷撒']='愷撒:BAAALgAECgYJBwAAAA==.',
['懒小']='懒小二:BAAALgAECgEJAQAAAA==.懒小屁:BAAALgAECgEJAQAAAA==.',
['我是']='我是战士:BAAALgAECgUJCwAAAA==.',
['我来']='我来组成档部:BAAALgAECgYJBwAAAA==.',
['战国']='战国策:BAABLgAFFH8GAAICAAMJzBXHFQD9AAACAAMJzBXHFQD9AAAAAA==.',
['抓娃']='抓娃娃:BAAALgADCgUJBQAAAA==.',
['拔都']='拔都:BAAALgAECgkJBgAAAA==.',
['挽月']='挽月破风尘:BAAALgAECgcJBwAAAA==.',
['敌法']='敌法爱你哟:BAAALgAECgYJCAAAAA==.',
['文盲']='文盲小法:BAAALgAECgYJBgAAAA==.',
['斩尽']='斩尽相思:BAAALgAECgkJCQAAAA==.',
['施华']='施华洛:BAAALgAECgYJCAAAAA==.',
['施恶']='施恶:BAAALgAFFAEJAQAAAA==.',
['旅行']='旅行雨蛙:BAAALgADCgEJAQAAAA==.',
['明月']='明月落深潭:BAAALgAECgUJBQAAAA==.',
['星坠']='星坠了无痕:BAAALgAECgcJDQAAAA==.',
['星月']='星月靈:BAABLgAECn8bAAIDAAcJ2h0rGABIAgADAAcJ2h0rGABIAgAAAA==.',
['昧丶']='昧丶天:BAAALgADCgUJBQAAAA==.',
['晓枫']='晓枫残玥:BAAALgAFFAEJAQAAAA==.',
['晚风']='晚风:BAAALgAECgIJAgAAAA==.',
['暗夜']='暗夜零:BAABLgAECn8bAAIJAAgJhiG1BQAyAwAJAAgJhiG1BQAyAwAAAA==.',
['暗影']='暗影恶魔:BAAALgAECggJEwAAAA==.',
['暗言']='暗言:BAACLgAFFH8FAAILAAUJvRAqDAC8AQALAAUJvRAqDAC8AQAuAAQKfx4AAgsACQkYIwsGAKIDAAsACQkYIwsGAKIDAAAA.',
['暗语']='暗语轻风:BAAALgAECgYJBwAAAA==.',
['月下']='月下星移:BAAALgADCgYJBgAAAA==.',
['月夜']='月夜舞者:BAAALgADCgEJAQAAAA==.',
['杀丶']='杀丶人红尘中:BAAALgAECgcJDwAAAA==.',
['李东']='李东海三十:BAAALgAFFAIJAgAAAA==.李东海二一:BAABLgAFFH8KAAMIAAQJ8BXMDgA8AQAIAAQJcRLMDgA8AQAJAAMJ7hT8IgBaAAAAAA==.李东海二七:BAAALgAFFAQJBAAAAA==.李东海二三:BAAALgAFFAMJAwAAAA==.李东海二九:BAAALgAFFAIJAgABLgAFFAQJDAAJAKQaAA==.李东海二二:BAAALgAECggJDAAAAA==.李东海二五:BAAALgAFFAQJBAABLgAFFAQJDAAJAKQaAA==.李东海二八:BAAALgAFFAIJAgABLgAFFAQJDAAJAKQaAA==.李东海二六:BAAALgAFFAQJBAAAAA==.李东海二十:BAABLgAFFH8HAAMJAAQJoxOVCQDrAAAIAAMJvRbRFAD2AAAJAAMJ4wuVCQDrAAAAAA==.李东海二四:BAABLgAFFH8MAAMJAAQJpBoPBwAPAQAIAAQJrRIjDgBCAQAJAAMJFRoPBwAPAQAAAA==.',
['杨老']='杨老师王老师:BAAALgAECgEJAQAAAA==.',
['東風']='東風谷早苗:BAAALgAECgYJAQABLgAFFAgJGgALAHwmAA==.',
['柒幽']='柒幽:BAAALgAECgIJAgAAAA==.',
['柠檬']='柠檬大叔:BAAALgAECgkJCQAAAA==.',
['柠蒙']='柠蒙:BAABLgAFFH8GAAILAAQJkwM8DwAVAQALAAQJkwM8DwAVAQAAAA==.',
['格尔']='格尔曼:BAAALgADCgIJAgAAAA==.',
['梅染']='梅染:BAAALgAECgUJBQAAAA==.',
['椎名']='椎名立希丶:BAAALgADCgQJBAABLgAFFAIJBgABACMNAA==.',
['楼兰']='楼兰五香:BAAALgAECgkJEAAAAA==.',
['榴燕']='榴燕冰:BAAALgAECgUJBQAAAA==.',
['樱羽']='樱羽艾玛:BAACLgAFFH8UAAIKAAUJCiVYAAAtAgAKAAUJCiVYAAAtAgAuAAQKfxkAAwoACAnkG8QiADICAAoABwlTHsQiADICAAMAAQmtAr2HACgAAAEuAAUUBgkHAAoAhhoA.',
['橙橙']='橙橙:BAAALgADCgMJAwAAAA==.',
['橙色']='橙色的火焰:BAAALgAECgYJBwAAAA==.',
['欲罢']='欲罢:BAAALgAECgEJAQAAAA==.',
['欺诈']='欺诈你的灵魂:BAAALgADCgEJAQAAAA==.',
['止水']='止水湖畔:BAAALgAECgUJDgAAAA==.',
['死亡']='死亡华尔滋:BAAALgADCgEJAQAAAA==.死亡汤圆:BAAALgAECgMJBgAAAA==.死亡领主:BAAALgAECgEJAQAAAA==.',
['氰灬']='氰灬岚:BAAALgAECgIJAwAAAA==.',
['水生']='水生的凛:BAAALgAECgYJBwAAAA==.',
['沙提']='沙提拉:BAABLgAECn8UAAQPAAcJiRbUIwCeAQAPAAUJDR3UIwCeAQAQAAcJFw8ZXgCGAQARAAIJRA8yJQBaAAAAAA==.',
['河原']='河原木桃香丶:BAAALgAECgEJAQABLgAFFAIJBgABACMNAA==.',
['油炸']='油炸冰棍:BAAALgAECgQJBAAAAA==.',
['法丨']='法丨師:BAAALgAECgkJEAAAAA==.',
['法宝']='法宝:BAAALgAECgYJBAAAAA==.',
['泡泡']='泡泡鱼:BAAALgAECgEJAQAAAA==.',
['泰瑞']='泰瑞达安:BAAALgAFFAMJBAAAAA==.',
['洛星']='洛星辰:BAAALgAECgcJCAABLgAECggJFAARADQVAA==.',
['深蓝']='深蓝安魂曲:BAAALgAECgEJAQAAAA==.',
['游戏']='游戏看人性:BAAALgAECgEJAQAAAA==.',
['滕小']='滕小抽:BAABLgAFFH8GAAISAAIJvSRXEgDRAAASAAIJvSRXEgDRAAAAAA==.',
['满岛']='满岛光:BAAALgAECgIJAwAAAA==.',
['灬生']='灬生死看淡灬:BAAALgAECgYJDQAAAA==.',
['灬筱']='灬筱海灬:BAAALgAECggJEgAAAA==.',
['灭火']='灭火专家:BAAALgAECgEJAQAAAA==.',
['灵巧']='灵巧儿:BAAALgAECgYJCwAAAA==.',
['炽天']='炽天使之恋:BAAALgAECgEJAQAAAA==.',
['热百']='热百搭巧克力:BAAALgAFFAIJAgAAAA==.',
['煌极']='煌极惊天拳:BAAALgADCgYJBQAAAA==.',
['熊丶']='熊丶熊:BAAALgAECgEJAwAAAA==.',
['燃烧']='燃烧小宇宙:BAAALgAECgYJBgAAAA==.',
['燚龖']='燚龖:BAAALgADCgcJBwAAAA==.',
['爆雪']='爆雪南风:BAAALgAECgEJAQAAAA==.',
['牛皮']='牛皮紙:BAAALgADCgYJBgAAAA==.',
['牛込']='牛込梨美:BAABLgAFFH8GAAMTAAIJthvKEAC8AAATAAIJthvKEAC8AAAUAAEJkxA0FABTAAAAAA==.',
['牢麦']='牢麦:BAAALgADCgQJBAAAAA==.',
['狂奔']='狂奔巴黎灬:BAAALgADCgEJAQAAAA==.',
['独家']='独家记忆:BAAALgADCgIJAgAAAA==.',
['玄奘']='玄奘:BAAALgAECgkJDwAAAA==.',
['玛雅']='玛雅圣光:BAAALgAECgcJDwAAAA==.',
['珑柒']='珑柒:BAAALgAECgQJBAAAAA==.',
['琅琅']='琅琅:BAAALgAECgYJDgABLgAECggJEwAGAAAAAA==.',
['甜甜']='甜甜妙嫣:BAAALgAECgEJAQAAAA==.',
['百鸟']='百鸟一:BAACLgAFFH8HAAIHAAUJoRuGBABtAQAHAAUJoRuGBABtAQAuAAQKfxUAAgcACQkSH2sQABoDAAcACQkSH2sQABoDAAEuAAUUBgkYAAcABSMA.百鸟三:BAAALgAFFAQJAwAAAA==.百鸟二:BAACLgAFFH8JAAIHAAUJShKEBgBXAQAHAAUJShKEBgBXAQAuAAQKfxUAAgcACQn6HOUgAL0CAAcACQn6HOUgAL0CAAEuAAUUBgkYAAcABSMA.',
['看我']='看我眼神:BAAALgAECgYJBgAAAA==.',
['真不']='真不缺德:BAAALgAECgYJBgAAAA==.',
['真神']='真神捞了:BAAALgADCgUJCAAAAA==.',
['破碎']='破碎灵魂:BAAALgAECgQJBgAAAA==.',
['穿礼']='穿礼服的野猫:BAAALgAECgQJBAAAAA==.',
['等我']='等我一会儿:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门秘术:BAAALgAECgEJAQAAAA==.',
['紫凝']='紫凝萱:BAAALgADCgEJAQAAAA==.',
['紫水']='紫水晶意志:BAAALgAFFAEJAQAAAA==.',
['紫菜']='紫菜汤:BAAALgAECgMJAwAAAA==.',
['红火']='红火:BAAALgAECgEJAgAAAA==.',
['纽约']='纽约龙须面:BAABLgAFFH8FAAIEAAMJdxi/FgCrAAAEAAMJdxi/FgCrAAAAAA==.',
['羊角']='羊角包:BAAALgAECgYJDAAAAA==.',
['義之']='義之龍耀津郕:BAAALgAECgQJBAAAAA==.',
['老哔']='老哔登:BAAALgAECgYJBgAAAA==.',
['老比']='老比登:BAAALgAECggJEgAAAA==.',
['耐瑟']='耐瑟瑞尔:BAABLgAECn8eAAILAAgJ8Bc2WgArAgALAAgJ8Bc2WgArAgAAAA==.',
['聚窟']='聚窟洲呆呆姬:BAAALgAECgYJEwAAAA==.',
['背对']='背对圣光:BAAALgAECgYJBgAAAA==.',
['自然']='自然之心:BAAALgAECgYJBgAAAA==.',
['至欢']='至欢:BAAALgADCgUJBQAAAA==.',
['艾倩']='艾倩倩:BAABLgAECn8UAAIRAAgJNBUQCQDhAQARAAgJNBUQCQDhAQAAAA==.',
['艾斯']='艾斯乄德斯:BAAALgAECgcJBwAAAA==.艾斯德斯:BAAALgAECgQJBAAAAA==.',
['艾米']='艾米朵儿:BAAALgAECgMJBAAAAA==.',
['荫雨']='荫雨纷飞:BAAALgADCgMJAwAAAA==.',
['菲尔']='菲尔德:BAABLgAFFH8IAAIVAAQJ9gIKFQDNAAAVAAQJ9gIKFQDNAAAAAA==.',
['菲米']='菲米斯战锤:BAAALgAECgIJAgAAAA==.',
['萌箭']='萌箭也骚气:BAAALgADCgUJBQAAAA==.',
['落花']='落花有意:BAAALgAECgEJAgAAAA==.',
['落阳']='落阳:BAAALgAECgQJCAAAAA==.',
['蓝天']='蓝天下的可乐:BAAALgAECgEJAgAAAA==.',
['蓝青']='蓝青春:BAAALgAECgIJAgAAAA==.',
['虎哥']='虎哥殴剔啦:BAAALgAECgEJAQAAAA==.',
['血煮']='血煮酒:BAAALgAECgEJBAAAAA==.',
['裁决']='裁决之囵:BAAALgAECgQJBQAAAA==.裁决之梼:BAAALgAECgEJAQAAAA==.',
['西街']='西街的猫:BAAALgAECgUJBQAAAA==.',
['譭丷']='譭丷灭:BAAALgAECgYJBwAAAA==.',
['诶呦']='诶呦我去大腿:BAAALgAECgcJBwAAAA==.',
['貳寳']='貳寳:BAAALgAECgQJBAAAAA==.',
['赛亚']='赛亚圣人:BAAALgADCgMJAwAAAA==.赛亚潮人:BAAALgADCgEJAQAAAA==.赛亚贼人:BAAALgAECgQJBwAAAA==.',
['赛莉']='赛莉斯冷:BAAALgAECgIJAgAAAA==.',
['越長']='越長大越孤單:BAAALgAECgEJAQAAAA==.',
['轩晨']='轩晨馨:BAAALgAFFAIJAgAAAA==.',
['轰焚']='轰焚啸焰炮:BAAALgADCgUJBQAAAA==.',
['还有']='还有人寿:BAAALgAECgYJBgAAAA==.',
['远古']='远古勇士:BAAALgADCgIJAgAAAA==.',
['远哥']='远哥丫:BAAALgAECgYJBgAAAA==.',
['迪丽']='迪丽热九:BAAALgAECgcJBwAAAA==.',
['迷迷']='迷迷鲤:BAAALgAECgkJCQAAAA==.',
['邪血']='邪血霜灭剑:BAAALgAFFAIJBAAAAA==.',
['邪魔']='邪魔退散:BAAALgAECgEJAQAAAA==.',
['采集']='采集专用:BAAALgADCgEJAQAAAA==.',
['镜中']='镜中繁花:BAAALgAECggJEwAAAA==.',
['阿库']='阿库娅:BAAALgAECgEJAQAAAA==.',
['阿爾']='阿爾托利娅:BAAALgAECgYJBgAAAA==.',
['阿肆']='阿肆丶:BAAALgAECgYJCAAAAA==.',
['随风']='随风逐影:BAAALgADCgIJAgAAAA==.',
['雷幻']='雷幻:BAAALgAECgcJAQAAAA==.',
['霓裳']='霓裳丨骑:BAAALgADCgMJAwAAAA==.',
['靈魂']='靈魂依托:BAAALgAECgcJCwAAAA==.',
['青莲']='青莲剑歌:BAAALgAECgcJBwAAAA==.',
['青鸟']='青鸟的吼吼:BAAALgAECgQJBQAAAA==.',
['顶之']='顶之座赫卡特:BAAALgAECgYJBgAAAA==.',
['颦儿']='颦儿:BAAALgADCgEJAQAAAA==.',
['风之']='风之第七章:BAAALgAECgQJBQAAAA==.',
['飒冉']='飒冉:BAAALgADCgIJAgABLgAECggJEgAGAAAAAA==.',
['飞跃']='飞跃太平洋:BAAALgAECgUJBQAAAA==.',
['香吉']='香吉:BAAALgAECgUJBgAAAA==.',
['马小']='马小萨萨:BAAALgAFFAIJBAAAAA==.',
['马思']='马思唯维豆奶:BAAALgAECgcJEwAAAA==.',
['骄傲']='骄傲的大花:BAAALgAECgYJBgAAAA==.',
['骑龟']='骑龟龟去逛街:BAAALgADCgMJAwAAAA==.',
['魂兮']='魂兮归来:BAAALgAECgEJAQABLgAECgUJDgAGAAAAAA==.',
['鱼骨']='鱼骨头砰砰枪:BAAALgAECgQJBAAAAA==.',
['鳳凰']='鳳凰鳴:BAAALgAECgMJAgAAAA==.',
['鸿蒙']='鸿蒙:BAAALgAECgIJAgAAAA==.',
['鹰爪']='鹰爪山李大嘴:BAAALgADCgEJAQAAAA==.',
['鹰目']='鹰目錵盗:BAAALgAECgUJBQAAAA==.',
['黑火']='黑火:BAAALgAECgUJCQAAAA==.',
['黯沐']='黯沐丶:BAAALgAECgcJDQAAAA==.',
['齐天']='齐天晓圣:BAAALgAECgYJBgABLgAFFAUJDwAWAAEjAA==.',
['龙组']='龙组:BAABLgAFFH8HAAIDAAIJXSBJEQDDAAADAAIJXSBJEQDDAAAAAA==.',
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
