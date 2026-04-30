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

local lookup = {'Priest-Shadow','Rogue-Subtlety','Priest-Discipline','Priest-Holy','DemonHunter-Devourer','Monk-Brewmaster','Monk-Mistweaver','DeathKnight-Unholy','Shaman-Elemental','Unknown-Unknown','Evoker-Preservation','DemonHunter-Havoc','Evoker-Augmentation','Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Shaman-Restoration','Monk-Windwalker','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Warlock-Destruction',}
local provider = {region='CN',realm='布莱克摩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Cr='Crossingout:BAAALgAECgEJAQAAAA==.',
Dr='Dreamfyre:BAABLgAFFH8JAAIBAAUJrgpYCABBAQABAAUJrgpYCABBAQAAAA==.',
Ha='Hamter:BAAALgADCgEJAQAAAA==.',
Il='Ilo:BAAALgAECgEJAgAAAA==.',
Me='Mercurys:BAAALgAECgEJAgAAAA==.',
Mi='Milestone:BAABLgAECn8bAAICAAcJxwqGLACaAQACAAcJxwqGLACaAQAAAA==.',
Mo='Moondancer:BAABLgAFFH8TAAMBAAYJFQ8tCABEAQABAAYJFQ8tCABEAQADAAQJwA1+CgA3AQAAAA==.',
Se='Seasmoke:BAACLgAFFH8NAAIBAAUJAhVTAwC3AQABAAUJAhVTAwC3AQAuAAQKfxUAAwMABwkNFP8fAJMBAAMABwkNFP8fAJMBAAEABwmFEPEqAIMBAAAA.',
Si='Silverwing:BAABLgAFFH8IAAMBAAUJPRLRBgBZAQABAAUJPRLRBgBZAQAEAAEJXwUGCQBIAAAAAA==.',
Su='Sunfyre:BAABLgAFFH8IAAIBAAQJwRaQBQByAQABAAQJwRaQBQByAQAAAA==.',
Sy='Syrax:BAACLgAFFH8PAAMBAAYJ/xSXAAClAQABAAYJ/xSXAAClAQADAAEJ6gMMGQBMAAAuAAQKfxYAAwEABwkfIi8QAIMCAAEABwkfIi8QAIMCAAMABwlIF08dAKoBAAAA.',
Tb='Tb:BAABLgAFFH8KAAIFAAYJwwxUGQAFAQAFAAYJwwxUGQAFAQAAAA==.',
Th='Threefour:BAAALgAECgIJAgAAAA==.',
Wa='Warlockone:BAAALgADCgMJAwAAAA==.',
Wo='Wolfback:BAAALgAECgEJAQAAAA==.',
['不碎']='不碎之靈:BAAALgAECgQJBwAAAA==.',
['东东']='东东小德:BAAALgAECgUJBQAAAA==.',
['丨踏']='丨踏焰丨:BAAALgAECgYJCQAAAA==.',
['丶椛']='丶椛晓霜:BAAALgAECggJCQAAAA==.',
['丶舞']='丶舞幽炫:BAABLgAECn8XAAMGAAcJRSG3GQA2AgAGAAcJRSG3GQA2AgAHAAIJfhHfVwBwAAABLgAFFAQJDgAIAN0cAA==.丶舞钢管:BAAALgAECgkJCQABLgAFFAYJFgAJAMUZAA==.',
['乌瑟']='乌瑟尔:BAAALgAECgYJDwAAAA==.',
['云云']='云云:BAAALgAECgkJDQAAAA==.',
['从小']='从小就浪:BAAALgAFFAQJBAAAAA==.从小就野:BAAALgAECgQJBQAAAA==.',
['任飘']='任飘渺:BAAALgADCgcJCAAAAA==.',
['体胖']='体胖心宽:BAAALgAECgEJAQAAAA==.',
['余伯']='余伯年:BAAALgADCgcJCgAAAA==.',
['克剌']='克剌斯:BAAALgAECgYJBgAAAA==.',
['卡九']='卡九万:BAAALgAECgMJAwAAAA==.',
['卡拉']='卡拉达丽娜:BAAALgADCgEJAQAAAA==.',
['卧槽']='卧槽:BAAALgAFFAQJBAAAAA==.',
['古神']='古神萨拉塔斯:BAAALgAECgYJCgAAAA==.',
['只需']='只需三分钟:BAAALgAECgQJBAABLgAECgQJBQAKAAAAAA==.',
['可乐']='可乐加冰:BAAALgAECgEJAQAAAA==.',
['名字']='名字太短:BAAALgAECgYJCgABLgAFFAYJBAAKAAAAAA==.',
['吐血']='吐血:BAAALgAECgEJAQAAAA==.',
['吴二']='吴二蛋:BAAALgAECgUJCQABLgAECgYJFQAIAMojAA==.',
['咖啡']='咖啡嘤:BAAALgAFFAIJBAAAAA==.',
['哈利']='哈利啵特别大:BAAALgAECgYJBgAAAA==.',
['哈都']='哈都跟:BAACLgAFFH8MAAQBAAQJgQwHCgAUAQABAAQJgQwHCgAUAQADAAIJtwYFFACWAAAEAAIJ8grWDgCHAAAuAAQKfxYABAEABwmqHJ4cAPYBAAEABglVIZ4cAPYBAAQAAwkNEShiAKcAAAMAAgntFpxDAJkAAAAA.',
['唐努']='唐努乌梁海:BAAALgAFFAQJBAAAAA==.',
['唱跳']='唱跳说唱篮球:BAAALgAECgYJBgABLgAFFAUJDAALAAshAA==.',
['喧嚣']='喧嚣尘世间:BAAALgAECgQJBAAAAA==.',
['喵大']='喵大大人:BAACLgAFFH8TAAMDAAUJQBvNAwC4AQADAAUJyRjNAwC4AQAEAAIJLSJSCgDBAAAuAAQKfxoAAwQABwmUIwALAJ8CAAQABwmVIgALAJ8CAAMABQmwIHwaAMQBAAAA.',
['嘭嘭']='嘭嘭西:BAAALgAECgEJAQAAAA==.',
['国产']='国产鞭妇侠:BAABLgAECn8WAAMFAAcJ2RQCXwCEAQAFAAcJVhMCXwCEAQAMAAYJ/A8lMQBJAQAAAA==.',
['圣光']='圣光邓邓:BAAALgAECgkJCQABLgAFFAYJDgANAEIXAA==.',
['基利']='基利安姆巴佩:BAAALgADCgEJAQAAAA==.',
['壮壮']='壮壮妈:BAAALgADCgQJBAAAAA==.',
['夜雨']='夜雨小梦:BAACLgAFFH8SAAIFAAUJjCYaAgA8AgAFAAUJjCYaAgA8AgAuAAQKfxcAAwUACAn4IqAKAC4DAAUACAn4IqAKAC4DAAwABAkHJCswAE8BAAAA.',
['天命']='天命人:BAABLgAFFH8PAAIGAAUJ1QXFCgAxAQAGAAUJ1QXFCgAxAQAAAA==.',
['媞娜']='媞娜:BAAALgAECgkJBAAAAA==.',
['孤魂']='孤魂野鬼丶:BAAALgAECgQJBAAAAA==.',
['宇宙']='宇宙大将军:BAAALgAECgQJBQAAAA==.',
['守四']='守四方:BAAALgADCgEJAQAAAA==.',
['安和']='安和昴:BAAALgAECgUJEAABLgAFFAUJEgAFAIwmAA==.',
['寒风']='寒风无泪:BAAALgAECgIJAwAAAA==.',
['小榄']='小榄苟王:BAAALgAECgYJBwAAAA==.',
['小沫']='小沫沐丶:BAAALgAECgQJBAAAAA==.',
['小船']='小船:BAABLgAECn8VAAIEAAcJ6xY8KACuAQAEAAcJ6xY8KACuAQAAAA==.',
['小菜']='小菜一碟:BAAALgAECgYJBwAAAA==.',
['小雨']='小雨丨离离:BAABLgAECn8iAAIOAAgJxxZKEQC4AQAOAAgJxxZKEQC4AQAAAA==.',
['小鬼']='小鬼夜巡:BAAALgAECgcJBAAAAA==.小鬼夜游:BAAALgAECgYJBgAAAA==.小鬼夜行:BAAALgAFFAEJAQAAAA==.小鬼夜袭:BAAALgAECgcJDwAAAA==.',
['就爱']='就爱吃香菜:BAAALgADCgEJAQAAAA==.',
['巨石']='巨石强森:BAAALgAECgEJAQABLgAFFAMJBAAKAAAAAA==.',
['平凡']='平凡的体验:BAAALgADCgEJAQAAAA==.',
['幻影']='幻影玫瑰:BAAALgADCgcJBwAAAA==.',
['幽客']='幽客:BAAALgAECgUJBwAAAA==.',
['庑乆']='庑乆冋堻:BAAALgAECgYJCwAAAA==.',
['影光']='影光月蝕:BAAALgAECgUJBgAAAA==.',
['微风']='微风艾儿:BAAALgAECgYJCgAAAA==.',
['心跳']='心跳滴回忆:BAAALgAECgcJBwAAAA==.',
['懿頔']='懿頔两相依:BAAALgAECgMJBgAAAA==.',
['我头']='我头上五个旋:BAAALgAECgIJAgAAAA==.',
['我要']='我要暴走:BAAALgADCgYJBgAAAA==.',
['戚曦']='戚曦:BAAALgADCgYJBgAAAA==.',
['折戟']='折戟之殇:BAAALgAECgUJCgAAAA==.',
['拉风']='拉风老爷车:BAABLgAECn8UAAQPAAcJYyEvEgCmAgAPAAcJYyEvEgCmAgAQAAMJwgMvdgBmAAARAAEJwgyGMAAxAAAAAA==.',
['排队']='排队中:BAAALgAECgEJAQAAAA==.',
['文尨']='文尨:BAAALgAECgEJAQAAAA==.',
['斑竹']='斑竹心语:BAAALgAECgYJBgAAAA==.',
['早睡']='早睡早起:BAAALgAECgUJBQAAAA==.',
['时光']='时光带走我丶:BAAALgAECgcJCwAAAA==.',
['明月']='明月照尖東:BAAALgAECgYJDgAAAA==.',
['星丶']='星丶垣:BAAALgAECgYJBgAAAA==.星丶熠:BAAALgAFFAIJAgAAAA==.星丶痕:BAAALgADCgEJAQAAAA==.星丶陨:BAAALgAECgIJAgABLgAFFAYJBwAQABANAA==.',
['春香']='春香:BAACLgAFFH8GAAISAAMJsQTJEwC/AAASAAMJsQTJEwC/AAAuAAQKfxcAAhIABgkiAjIeAJ4AABIABgkiAjIeAJ4AAAAA.',
['普通']='普通和尚:BAABLgAECn8YAAMHAAcJKRREKgBlAQAHAAcJKRREKgBlAQATAAIJpw7BaQBmAAAAAA==.',
['暗影']='暗影天驰:BAAALgAECgMJBwAAAA==.',
['暴躁']='暴躁的壶:BAAALgAECgEJAQAAAA==.',
['月卡']='月卡闲的:BAAALgAECgYJBgAAAA==.',
['欲為']='欲為诸佛龍象:BAAALgAECgYJBgAAAA==.',
['武坤']='武坤:BAAALgADCgUJBAAAAA==.',
['求生']='求生之路:BAAALgAECgEJAgAAAA==.',
['江南']='江南织造:BAAALgAECgMJBAABLgAECgUJBwAKAAAAAA==.',
['江浙']='江浙沪丶独女:BAAALgAECgcJDQAAAA==.',
['沐沐']='沐沐:BAAALgAECgYJBwAAAA==.',
['河蟹']='河蟹战皮皮虾:BAAALgADCgIJAgAAAA==.',
['沸羊']='沸羊羊:BAAALgAECgcJDQAAAA==.',
['泊尔']='泊尔修斯:BAAALgADCgEJAQAAAA==.',
['混沌']='混沌灭世:BAAALgAECgMJAwAAAA==.',
['清爽']='清爽一夏:BAAALgAECgYJCQAAAA==.',
['灬小']='灬小闹:BAAALgADCgQJBQAAAA==.',
['灵之']='灵之影:BAAALgAECgYJCAAAAA==.',
['熵能']='熵能之祸:BAAALgAECgYJBwAAAA==.',
['爱的']='爱的一切:BAAALgAECgcJDwAAAA==.',
['牧猫']='牧猫喵丶:BAAALgAECgUJBQAAAA==.',
['狡猾']='狡猾的张圆圆:BAAALgAECgEJAQAAAA==.',
['独醉']='独醉秋月:BAAALgAFFAEJAQAAAA==.',
['献身']='献身于神:BAACLgAFFH8VAAMUAAUJNx/OAACKAQAUAAUJNx/OAACKAQAVAAEJAACtDwBHAAAuAAQKfxQAAxQABwnPHw8YAIsCABQABwnPHw8YAIsCABUAAQmCE1dJACsAAAAA.',
['电一']='电一下:BAAALgAECgEJAQAAAA==.',
['碧落']='碧落挽弓:BAAALgADCgEJAQAAAA==.',
['神圣']='神圣大风车:BAAALgAECgcJDQAAAA==.',
['粉马']='粉马尾蝙蝠猫:BAAALgAECgYJCAAAAA==.',
['素手']='素手芳華:BAACLgAFFH8TAAMPAAUJPBKrAwBPAQAQAAUJQBF/CQCBAQAPAAQJuA6rAwBPAQAuAAQKfxQAAhAABwksH8IcAD4CABAABwksH8IcAD4CAAAA.',
['红莲']='红莲之魂:BAAALgAECgYJBgAAAA==.',
['美味']='美味南瓜酥:BAAALgADCgMJAwAAAA==.美味海鲜粥:BAAALgADCgIJAgAAAA==.',
['聖子']='聖子到:BAAALgAECgEJAQAAAA==.',
['脚滑']='脚滑机:BAAALgAECgQJBwAAAA==.',
['艾尔']='艾尔文宠物店:BAAALgAECgYJBwAAAA==.',
['艾斯']='艾斯蒂尔:BAAALgAECgEJAQAAAA==.',
['苍白']='苍白的正义:BAAALgAECgEJAQAAAA==.',
['茉酱']='茉酱紫:BAAALgAECgYJBgAAAA==.',
['菩萨']='菩萨蛮:BAAALgADCgYJBgAAAA==.',
['西江']='西江月:BAAALgADCgMJAwAAAA==.',
['西瓜']='西瓜勒个太狼:BAAALgAECgIJAgAAAA==.',
['诗酒']='诗酒茶:BAAALgAECgMJBAAAAA==.',
['豬豬']='豬豬儿:BAAALgAECgEJAgAAAA==.',
['赛利']='赛利卡:BAACLgAFFH8XAAIOAAYJFR/VAAD0AQAOAAYJFR/VAAD0AQAuAAQKfx8AAg4ACQnhJV8CANkDAA4ACQnhJV8CANkDAAAA.',
['赤沙']='赤沙之蝎:BAAALgAECgQJBAAAAA==.',
['踏雪']='踏雪寻煤:BAAALgAECgcJEAAAAA==.',
['辣条']='辣条外交官:BAAALgAFFAIJBAAAAA==.辣条小妹:BAAALgAECgEJAQAAAA==.',
['迈阿']='迈阿密热浪:BAABLgAECn8aAAIOAAYJmxQxpgCMAQAOAAYJmxQxpgCMAQAAAA==.',
['这就']='这就厉害了:BAAALgAFFAEJAQAAAA==.',
['逗逼']='逗逼岚波万:BAAALgAECgQJBQAAAA==.',
['那有']='那有啥子法:BAAALgAECgIJAgAAAA==.',
['采蘑']='采蘑菇的小熊:BAAALgAFFAEJAQAAAA==.',
['銀月']='銀月黯羽:BAAALgAECgQJBwAAAA==.',
['银河']='银河野性:BAAALgAECgQJBAAAAA==.',
['阿夫']='阿夫洛迪特:BAAALgAECgQJCAAAAA==.',
['阿奈']='阿奈耶识:BAAALgAFFAEJAQAAAA==.',
['阿铎']='阿铎给灬:BAAALgAECgYJDgAAAA==.',
['陌丶']='陌丶冷:BAAALgAECgYJBgAAAA==.',
['随便']='随便摸摸:BAAALgAECgIJAwAAAA==.',
['雯贝']='雯贝贝:BAAALgADCgcJBwAAAA==.',
['霜之']='霜之高兴:BAACLgAFFH8IAAIIAAMJVxDhDwD5AAAIAAMJVxDhDwD5AAAuAAQKfxgAAggACAn+DaJ3AJYBAAgACAn+DaJ3AJYBAAAA.',
['静小']='静小静:BAABLgAECn8WAAMWAAYJ1xwHbwCCAQAWAAUJ1xwHbwCCAQAXAAIJ5gaqVABwAAAAAA==.',
['非同']='非同小可:BAAALgAECgYJCgABLgAFFAQJDgASAHodAA==.',
['风之']='风之天下:BAAALgAECgYJBgAAAA==.',
['风清']='风清揚:BAAALgAECgEJAQAAAA==.',
['风过']='风过云端:BAAALgAECgcJDQAAAA==.',
['风采']='风采铃:BAAALgAECgUJBwAAAA==.',
['魅魔']='魅魔之法西路:BAAALgADCgEJAQAAAA==.',
['魔幻']='魔幻星辰:BAAALgAECgMJAwAAAA==.',
['鰻魚']='鰻魚飯:BAAALgAECgUJBQAAAA==.',
['黎明']='黎明欢悦后妈:BAAALgADCgEJAQAAAA==.黎明的勇气:BAAALgAFFAIJAwAAAA==.',
['黑白']='黑白玄月:BAAALgAECgMJAwAAAA==.',
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
