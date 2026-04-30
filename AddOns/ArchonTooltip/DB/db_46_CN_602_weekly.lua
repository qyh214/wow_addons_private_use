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

local lookup = {'Hunter-Marksmanship','Mage-Frost','Druid-Restoration','Unknown-Unknown','Evoker-Augmentation','Evoker-Devastation','Warrior-Fury','Paladin-Retribution','Hunter-BeastMastery','Paladin-Protection','Warlock-Demonology','Warrior-Arms','Warrior-Protection','DemonHunter-Devourer','Druid-Balance','Rogue-Assassination','Rogue-Subtlety','Shaman-Restoration','Monk-Mistweaver','Monk-Brewmaster','Priest-Holy','Priest-Discipline','Priest-Shadow','Shaman-Enhancement','Warlock-Affliction','Warlock-Destruction',}
local provider = {region='CN',realm='厄祖玛特',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alpharius:BAEBLgAFFH8FAAIBAAQJXiDnCQB6AQABAAQJXiDnCQB6AQAAAA==.',
Ar='Arcane:BAAALgAECgUJBQAAAA==.',
Az='Azsuth:BAAALgAECgQJBAAAAA==.',
Ch='Chanel:BAAALgAFFAIJAwAAAA==.',
De='Deff:BAAALgAECgYJDgAAAA==.',
Di='Diu:BAAALgAECgQJBAAAAA==.',
Eu='Eurek:BAACLgAFFH8LAAICAAQJzRd9GQBkAQACAAQJzRd9GQBkAQAuAAQKfxwAAgIACAm6H7MkAOACAAIACAm6H7MkAOACAAAA.',
Im='Imitation:BAAALgAECgYJDAAAAA==.',
Oi='Oilmeg:BAAALgAFFAEJAQAAAA==.Oilpalading:BAAALgADCgQJBAAAAA==.',
Pa='Pannxd:BAAALgAECgYJEAAAAA==.',
Ro='Rolypoly:BAAALgAECgQJBwAAAA==.',
Th='Theweeknd:BAABLgAFFH8FAAIDAAMJ2Q5kDACOAAADAAMJ2Q5kDACOAAAAAA==.',
Vi='Vicsanity:BAAALgAECgMJBQABLgAECgQJBwAEAAAAAA==.Victoxics:BAAALgAECgMJAwABLgAECgQJBwAEAAAAAA==.',
Vv='Vverniy:BAAALgAECgEJAQAAAA==.',
Wh='Whis:BAABLgAFFH8MAAICAAQJXRy8BAB8AQACAAQJXRy8BAB8AQAAAA==.',
Yo='Yolo:BAAALgADCgEJAgAAAA==.',
['一休']='一休:BAAALgAECgQJBQAAAA==.',
['万象']='万象城:BAAALgADCgEJAQAAAA==.',
['不争']='不争春:BAACLgAFFH8FAAMFAAIJCQxfGwCTAAAFAAIJcQtfGwCTAAAGAAEJOwR8CwBKAAAuAAQKfx8AAwYABwn5HgQIAGcCAAYABwk3HgQIAGcCAAUAAgnLGU5NAJsAAAAA.',
['不聪']='不聪明:BAAALgAFFAIJAgAAAA==.',
['丨丶']='丨丶一抹奶荼:BAAALgADCgEJAQAAAA==.',
['丶寻']='丶寻寻:BAAALgAECgIJAgAAAA==.',
['丷丷']='丷丷:BAAALgAFFAQJBAAAAA==.',
['九丶']='九丶尾:BAAALgAECgMJBQAAAA==.',
['九号']='九号契约:BAAALgAFFAMJBAAAAA==.',
['九黎']='九黎:BAABLgAECn8UAAICAAYJOSO2VQA3AgACAAYJOSO2VQA3AgAAAA==.',
['何罐']='何罐我言:BAAALgADCgEJAQAAAA==.',
['修罗']='修罗魂:BAAALgAECgEJAgAAAA==.',
['元寳']='元寳:BAABLgAFFH8HAAIHAAMJbgxqEgDzAAAHAAMJbgxqEgDzAAAAAA==.',
['兜兜']='兜兜里有红心:BAAALgAECgkJCQAAAA==.',
['全能']='全能老牛:BAAALgAFFAEJAQAAAA==.',
['八基']='八基大狂蜂:BAAALgAECgYJBwAAAA==.',
['公子']='公子阔少:BAABLgAFFH8HAAIIAAMJqxhzHQC3AAAIAAMJqxhzHQC3AAAAAA==.',
['农村']='农村妞:BAAALgADCgMJAwABLgAFFAQJBAAEAAAAAA==.',
['冷静']='冷静的像冰箱:BAAALgAECgYJBgAAAA==.',
['别躲']='别躲我好吗:BAAALgAECgkJDwAAAA==.',
['功夫']='功夫熊猫:BAAALgAECgcJBwAAAA==.',
['動我']='動我坦克試試:BAAALgAECgIJAQAAAA==.',
['千城']='千城越:BAACLgAFFH8KAAICAAQJ6wbNIQA5AQACAAQJ6wbNIQA5AQAuAAQKfxUAAgIABgklGhuUAKsBAAIABgklGhuUAKsBAAAA.',
['午夜']='午夜唉:BAAALgADCgEJAQAAAA==.',
['华华']='华华花露水:BAAALgADCgEJAQAAAA==.',
['卖小']='卖小女孩的糖:BAAALgAECgUJBQAAAA==.',
['司徒']='司徒龍:BAAALgADCgcJBwAAAA==.',
['同治']='同治:BAAALgAECgEJAQAAAA==.',
['吕布']='吕布:BAAALgAECgQJBgAAAA==.',
['吾鸽']='吾鸽勒:BAAALgAFFAQJBAAAAA==.',
['呼吸']='呼吸决定:BAABLgAECn8WAAICAAkJcR2hLgC3AgACAAkJcR2hLgC3AgAAAA==.',
['和你']='和你说不走:BAABLgAFFH8FAAIJAAMJchzrCgDFAAAJAAMJchzrCgDFAAAAAA==.',
['咕噜']='咕噜咕噜咕噜:BAAALgAECgcJCQAAAA==.',
['哈库']='哈库那玛塔塔:BAAALgAECgEJAQAAAA==.',
['哔哩']='哔哩哔哩比比:BAAALgAECgMJAwAAAA==.哔哩哔哩里:BAAALgAECgUJCgAAAA==.',
['啥强']='啥强玩啥:BAAALgAECgUJCgAAAA==.',
['喝气']='喝气泡水打嗝:BAABLgAECn8VAAMBAAkJfBkzIwAKAgABAAcJexwzIwAKAgAJAAIJfxDJmwCbAAAAAA==.',
['四号']='四号哟:BAAALgAFFAMJBAAAAA==.',
['土熊']='土熊寡惨了:BAAALgADCgUJBQAAAA==.',
['圣丶']='圣丶光:BAABLgAECn8eAAMIAAgJNwm9hwBrAQAIAAcJbgq9hwBrAQAKAAYJjgPmLQCgAAAAAA==.',
['圣光']='圣光守护者丶:BAAALgAECgEJAQAAAA==.圣光牛博一:BAAALgAECgQJBwAAAA==.圣光的挽歌:BAAALgAECgQJBAAAAA==.',
['在恒']='在恒星里逃离:BAAALgAECgIJAgAAAA==.',
['墨未']='墨未言泽:BAAALgAECgMJAwAAAA==.',
['夏凛']='夏凛:BAAALgAECgEJAQAAAA==.',
['夏短']='夏短夜长:BAAALgAECgIJBAAAAA==.',
['夜法']='夜法:BAAALgAECgQJBgAAAA==.',
['夜渊']='夜渊丶:BAAALgAECgUJCQAAAA==.',
['大祖']='大祖父:BAAALgAECgUJCgAAAA==.',
['大种']='大种牛:BAAALgADCgMJAgAAAA==.',
['女子']='女子无才:BAAALgAECgIJAgAAAA==.',
['如此']='如此灬黄泉:BAAALgADCgEJAQAAAA==.',
['妞妞']='妞妞灬牛:BAAALgAECgMJAQAAAA==.',
['嫉妒']='嫉妒的魔女:BAAALgAECgkJBAAAAA==.',
['字羊']='字羊羽:BAAALgAECgYJEwAAAA==.',
['宏哥']='宏哥的天空:BAAALgAECgYJDAAAAA==.',
['宏通']='宏通苑:BAAALgADCgcJCAAAAA==.',
['小伊']='小伊万:BAABLgAFFH8GAAILAAQJchluDQBwAQALAAQJchluDQBwAQABLgAFFAYJFgALAA8mAA==.',
['小奶']='小奶赛:BAAALgAFFAEJAQAAAA==.',
['小狐']='小狐猎:BAAALgAECgcJDAAAAA==.',
['小萌']='小萌妹:BAAALgAECgIJBQAAAA==.',
['小酌']='小酌怡情浅:BAAALgAFFAIJAwAAAA==.',
['小魃']='小魃:BAAALgAECgQJBAAAAA==.',
['小龙']='小龙人丶:BAAALgAECgIJAgAAAA==.',
['尘迦']='尘迦术:BAAALgAECgQJBAAAAA==.',
['布力']='布力啾啾:BAAALgAECgUJBQAAAA==.',
['布劳']='布劳缪克斯:BAAALgAECgkJEAAAAA==.',
['帅也']='帅也不知道:BAAALgADCgcJBwAAAA==.',
['年少']='年少的加摩尔:BAAALgADCgYJBgAAAA==.',
['幻彩']='幻彩大领主:BAAALgAECgUJBQAAAA==.',
['得过']='得过且过:BAAALgAFFAQJBAAAAA==.',
['必须']='必须六爷:BAAALgAFFAQJBAAAAA==.',
['想个']='想个好名难:BAACLgAFFH8VAAMHAAUJxiFFAQD4AQAHAAUJxiFFAQD4AQAMAAIJEhU/BwChAAAuAAQKfyAAAwcACQnIImoKAAsDAAcACAn3ImoKAAsDAAwAAwmrGRUfAPYAAAAA.',
['想淋']='想淋雨就别走:BAAALgAFFAQJBAAAAA==.',
['愿化']='愿化身石桥:BAAALgAECgUJDQAAAA==.',
['懒回']='懒回顾:BAABLgAECn8ZAAMHAAYJ+hLNTgBsAQAHAAYJmhLNTgBsAQAMAAEJxhicOwBDAAAAAA==.',
['懵犇']='懵犇:BAABLgAFFH8KAAIIAAQJvBldAgB0AQAIAAQJvBldAgB0AQAAAA==.',
['我发']='我发现你:BAAALgAECgkJDQAAAA==.',
['打不']='打不中你:BAAALgAECgQJBAAAAA==.',
['扭头']='扭头瞬间丶:BAAALgAECgYJCgAAAA==.',
['把尾']='把尾巴捡起来:BAAALgADCgIJAgAAAA==.',
['撒西']='撒西不理哒呐:BAAALgAECgQJBAAAAA==.',
['无畏']='无畏:BAAALgAECgQJBgAAAA==.',
['晨曦']='晨曦诗梦丶:BAAALgAFFAIJAgAAAA==.',
['暗夜']='暗夜德:BAAALgAECgUJCAAAAA==.',
['暗潶']='暗潶破壞神:BAAALgADCgYJBQAAAA==.',
['最後']='最後:BAAALgADCgMJAwAAAA==.',
['月痕']='月痕思琰:BAAALgAECgEJAQAAAA==.',
['木影']='木影丶风语者:BAAALgAECgEJAwAAAA==.',
['柒丿']='柒丿月:BAAALgADCgEJAQAAAA==.',
['柿子']='柿子饼:BAAALgAECgcJBwAAAA==.',
['止水']='止水:BAABLgAFFH8HAAICAAQJrxiyGgBgAQACAAQJrxiyGgBgAQAAAA==.',
['武凡']='武凡达:BAAALgADCgUJBQAAAA==.',
['死神']='死神:BAAALgAFFAEJAQAAAA==.',
['殇丶']='殇丶木木:BAAALgAECgEJAQAAAA==.',
['波波']='波波帅:BAAALgAECgYJCgAAAA==.',
['泽西']='泽西:BAAALgAECgQJBAAAAA==.',
['深蓝']='深蓝灬情殇:BAAALgAECgEJAQAAAA==.',
['清秋']='清秋丶:BAAALgAECgEJAQAAAA==.',
['清香']='清香:BAAALgAECgcJCwAAAA==.',
['渔不']='渔不再:BAAALgAECgEJAQAAAA==.',
['濑名']='濑名爱理:BAAALgAECgEJAQAAAA==.',
['火爆']='火爆小腰花:BAAALgAFFAEJAQAAAA==.',
['灬敢']='灬敢敢灬:BAABLgAFFH8SAAINAAYJ7Q9/AQBWAQANAAYJ7Q9/AQBWAQAAAA==.',
['熙熙']='熙熙见豆就吃:BAAALgAECgUJBQAAAA==.',
['爱灬']='爱灬鹊:BAAALgAECgIJAgAAAA==.',
['爲妳']='爲妳灬疯狂:BAAALgAECgYJCgAAAA==.爲妳灬痴狂:BAAALgADCgIJAgAAAA==.',
['牧尸']='牧尸:BAAALgADCgEJAQAAAA==.',
['猎天']='猎天使魔男:BAACLgAFFH8TAAIOAAUJUBgbCACjAQAOAAUJUBgbCACjAQAuAAQKfx8AAg4ACAkEG60oAGACAA4ACAkEG60oAGACAAAA.',
['瑞什']='瑞什么瑞:BAAALgAECgUJCgABLgAFFAUJCQAPAAgTAA==.',
['瓦工']='瓦工:BAAALgAFFAMJAwAAAA==.',
['甘木']='甘木槿:BAAALgADCgcJBwAAAA==.',
['白糖']='白糖乌米饭:BAAALgAECgYJDAAAAA==.',
['白色']='白色圣诞夜:BAAALgAECgIJAgAAAA==.',
['白霪']='白霪之手:BAAALgAFFAEJAQAAAA==.',
['百里']='百里东君:BAAALgAECgUJBQAAAA==.',
['眼罩']='眼罩:BAAALgAFFAEJAwAAAA==.',
['瞎子']='瞎子不迷路:BAAALgAECgUJBgAAAA==.',
['神圣']='神圣:BAAALgAECgIJAwAAAA==.',
['秋狩']='秋狩月:BAACLgAFFH8KAAMQAAMJFCThAQA9AQAQAAMJkCLhAQA9AQARAAMJRyNQCwAyAQAuAAQKfxkAAxEABwldIf8PAKYCABEABwkkIf8PAKYCABAAAQnIJVcYAG4AAAAA.',
['童凌']='童凌:BAAALgAECgIJAgAAAA==.',
['第三']='第三人:BAABLgAECn8VAAICAAgJvCH1PACEAgACAAgJvCH1PACEAgAAAA==.',
['素衣']='素衣:BAAALgAECgEJAQAAAA==.',
['繁星']='繁星尚月争荣:BAAALgAECgcJCAAAAA==.',
['纯属']='纯属丶愚乐:BAAALgADCgcJDAAAAA==.',
['经典']='经典小骑士:BAAALgADCgMJAwAAAA==.',
['绿丶']='绿丶巨人:BAAALgAECgUJDwAAAA==.',
['老三']='老三哟:BAAALgAFFAQJBAAAAA==.',
['老哥']='老哥你好:BAAALgAECgQJBAAAAA==.',
['老杰']='老杰克京剧团:BAAALgADCgUJBQAAAA==.',
['耗子']='耗子不来:BAAALgADCgIJAgAAAA==.',
['肆意']='肆意的風:BAAALgAECgIJAgAAAA==.肆意的风:BAAALgAECgYJDQAAAA==.',
['肘击']='肘击大王牢大:BAAALgAECgEJAQAAAA==.',
['股市']='股市第一韭菜:BAAALgAECgMJBAAAAA==.',
['脸大']='脸大好对焦:BAAALgAECggJDAAAAA==.',
['艾斯']='艾斯艾沐:BAABLgAFFH8FAAISAAIJGBowFAC6AAASAAIJGBowFAC6AAAAAA==.',
['艿丶']='艿丶霸:BAAALgAECgQJBAAAAA==.',
['英雄']='英雄迟暮:BAAALgAECgQJBQAAAA==.',
['莫莫']='莫莫伽:BAAALgAECgYJAwAAAA==.',
['菊花']='菊花撕碎者:BAAALgADCgcJBwAAAA==.',
['菠萝']='菠萝菠萝蜜丶:BAAALgAECgQJBQAAAA==.',
['蓝砚']='蓝砚:BAAALgAECgYJCwAAAA==.',
['蓝色']='蓝色可乐:BAAALgAECgIJBgAAAA==.',
['蔫屁']='蔫屁:BAAALgAECgIJAgAAAA==.',
['薄暮']='薄暮知秋:BAAALgAECgYJCwAAAA==.',
['蛮士']='蛮士的骄傲:BAAALgAECgcJBwAAAA==.',
['西瓜']='西瓜牛牛:BAAALgAECgcJBgAAAA==.',
['西西']='西西乱开盾墙:BAABLgAFFH8IAAINAAQJ1QmpBgD8AAANAAQJ1QmpBgD8AAAAAA==.',
['贝蛋']='贝蛋壳:BAACLgAFFH8FAAITAAIJNQ7tEACUAAATAAIJNQ7tEACUAAAuAAQKfxUAAxMABgm0HLcZAO8BABMABgm0HLcZAO8BABQAAQnWAuKPACUAAAAA.',
['贰零']='贰零伍文哥:BAAALgAFFAEJAQAAAA==.',
['赤云']='赤云凌霄:BAACLgAFFH8GAAIVAAIJbQc0DwCFAAAVAAIJbQc0DwCFAAAuAAQKfywABBUACAnBGskRAFMCABUACAk8GckRAFMCABYABQkHEnEtADIBABcAAQnsDGZeADwAAAAA.',
['趙小']='趙小灯:BAAALgAECgYJBwAAAA==.',
['迷茫']='迷茫的格鲁萨:BAABLgAFFH8GAAIYAAMJ0gm7AgCZAAAYAAMJ0gm7AgCZAAAAAA==.',
['遇术']='遇术临疯:BAAALgAECgkJCQAAAA==.',
['遙控']='遙控器:BAAALgAECgEJAQAAAA==.',
['酷奇']='酷奇:BAAALgAECgYJCAAAAA==.',
['醉世']='醉世饮花酒:BAAALgAECgcJBwAAAA==.',
['醉爱']='醉爱清欢:BAAALgAECgIJAgAAAA==.',
['金华']='金华將軍安防:BAAALgADCgcJBwAAAA==.',
['鑫泽']='鑫泽塔琼斯:BAAALgADCgMJAwAAAA==.',
['鑫血']='鑫血丨小小法:BAAALgAECgYJBgAAAA==.',
['铁锤']='铁锤儿丶:BAAALgAECgQJBwAAAA==.',
['铵屹']='铵屹锣:BAAALgADCgkJDwAAAA==.',
['阿可']='阿可可:BAAALgAECgEJAQAAAA==.',
['顾西']='顾西凉狼主:BAAALgAECgUJBQAAAA==.',
['風的']='風的气息:BAAALgAECgIJAQAAAA==.',
['風雨']='風雨随行:BAAALgAECgEJAQAAAA==.',
['风干']='风干的葡萄:BAAALgAECgEJAQAAAA==.',
['风行']='风行小中褚:BAAALgAFFAIJAgAAAA==.',
['风雨']='风雨其中:BAAALgAECgYJBgAAAA==.风雨随行:BAAALgAECgEJAQAAAA==.',
['骑个']='骑个烂摩托:BAAALgAFFAQJBAAAAA==.',
['骷髅']='骷髅血法:BAAALgADCgYJBgAAAA==.',
['魔法']='魔法炮台:BAACLgAFFH8SAAMLAAUJrxxeBwCuAQALAAUJrxxeBwCuAQAZAAEJAADKBQBVAAAuAAQKfx0AAwsACAkFIaYSAOcCAAsACAkFIaYSAOcCABoAAwnpHgA7AMgAAAAA.',
['黛尔']='黛尔瑞丶落晨:BAAALgAFFAIJAwAAAA==.',
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
