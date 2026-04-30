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

local lookup = {'Unknown-Unknown','Evoker-Augmentation','Warrior-Fury','Warrior-Protection','Warrior-Arms','Monk-Windwalker','Warlock-Demonology','Druid-Restoration','Mage-Frost','Priest-Holy','Priest-Discipline','Shaman-Restoration','DeathKnight-Unholy','Shaman-Elemental','Paladin-Retribution','Priest-Shadow','Monk-Mistweaver','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Monk-Brewmaster','Paladin-Holy','Mage-Arcane',}
local provider = {region='CN',realm='暗影议会',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexandr:BAAALgAECgUJBQAAAA==.',
Ao='Aomu:BAAALgAECgEJAgAAAA==.',
Az='Azmodanlol:BAAALgAFFAQJBAAAAA==.',
Ba='Babekil:BAAALgAECgYJBwAAAA==.',
Cc='Cc:BAAALgAECgQJBAABLgAECgYJDAABAAAAAA==.',
Cr='Crushé:BAAALgAECgMJAwAAAA==.',
Ei='Eillenials:BAAALgAFFAIJBAAAAA==.',
Ev='Everestd:BAAALgAECgQJBAAAAA==.',
Fa='Fallenember:BAAALgAFFAIJAwAAAA==.Fatherfvck:BAAALgAECgUJBQAAAA==.',
Fi='Fireway:BAAALgAECgkJDgAAAA==.',
He='Hellnoo:BAAALgADCgYJBgAAAA==.',
Ho='Honorknight:BAAALgAFFAIJBAAAAA==.',
It='Iteyo:BAAALgAECgEJAgAAAA==.',
Jo='Jobe:BAAALgAFFAEJAQABLgAFFAMJBwACADEEAA==.',
Ju='Justcc:BAAALgAECgEJAQAAAA==.',
Ka='Karenaeye:BAAALgADCgUJBQAAAA==.',
Ki='Kimonkey:BAABLgAECn8VAAQDAAcJDghCbwD6AAADAAUJEwhCbwD6AAAEAAMJgAjROACDAAAFAAIJDgbCNwBQAAAAAA==.',
Ku='Kucy:BAAALgADCgYJBgAAAA==.Kurore:BAAALgAECgYJBgAAAA==.',
Li='Linaria:BAAALgAECgEJAQAAAA==.',
Ma='Marcovaldo:BAACLgAFFH8LAAIFAAQJnhAxAgBYAQAFAAQJnhAxAgBYAQAuAAQKfx8AAwUACAnSHY4DAMsCAAUACAloHY4DAMsCAAQAAQkrHVE/AFYAAAAA.',
Me='Megumin:BAAALgAECgQJCAAAAA==.',
Mv='Mv:BAAALgAECgEJAQABLgAECgYJDAABAAAAAA==.',
My='Mystery:BAAALgADCgEJAQAAAA==.',
Ne='Neverbreath:BAAALgAECgcJDQAAAA==.',
Ns='Ns:BAAALgAECgYJDAAAAA==.',
Oo='Oosullivan:BAAALgAECgcJEQAAAA==.',
Pi='Pietruccio:BAAALgAECgYJCgAAAA==.',
Pr='Professorfk:BAAALgAECgEJAQAAAA==.',
Pu='Puthand:BAAALgAECgEJAQAAAA==.',
Ra='Rainz:BAAALgAECgYJCQAAAA==.',
Ru='Rules:BAAALgAECgUJBQAAAA==.',
Sa='Sarahweil:BAAALgAECgQJBAAAAA==.Sargerasi:BAAALgADCgEJAQAAAA==.',
So='Sobaniteyo:BAAALgAECgEJAgAAAA==.',
Sr='Srevival:BAAALgAFFAIJBAAAAA==.',
St='Stoper:BAAALgAECgIJBQAAAA==.',
Sw='Sweety:BAAALgAECgYJCwAAAA==.Swingx:BAAALgAECgEJAgAAAA==.',
Te='Terrylau:BAAALgAFFAEJAQAAAA==.Terryliu:BAAALgAECgEJAgAAAA==.',
Ti='Tiberius:BAABLgAFFH8GAAIGAAIJ0wlPDgCPAAAGAAIJ0wlPDgCPAAAAAA==.',
Vo='Vo:BAAALgADCgIJAgAAAA==.',
['Vá']='Vájra:BAAALgAECggJEgAAAA==.',
Xe='Xellos:BAABLgAECn8XAAIHAAgJOREOUADXAQAHAAgJOREOUADXAQAAAA==.',
Za='Zady:BAAALgADCgQJBAAAAA==.Zanarkand:BAAALgAECgMJAwAAAA==.Zaoan:BAAALgAECgEJAQAAAA==.',
Zm='Zmercury:BAAALgAFFAIJBAAAAA==.',
['一夜']='一夜暴富:BAAALgADCgEJAQAAAA==.',
['一月']='一月水瓶:BAABLgAFFH8QAAIIAAUJwQ9ZAwBoAQAIAAUJwQ9ZAwBoAQAAAA==.',
['一箭']='一箭飙血:BAAALgAECgEJAgAAAA==.',
['一首']='一首小情歌:BAAALgAFFAEJAQAAAA==.',
['七彩']='七彩国风胖:BAAALgADCgIJAgAAAA==.',
['万紫']='万紫千虹:BAAALgADCgEJAQAAAA==.',
['三千']='三千劫火:BAAALgAECgYJCQAAAA==.',
['三月']='三月白羊:BAABLgAFFH8IAAIIAAQJ5wX1DQAIAQAIAAQJ5wX1DQAIAQAAAA==.',
['不吃']='不吃夜宵:BAAALgAECgcJEQAAAA==.不吃宵夜:BAAALgAECgYJBgAAAA==.',
['不恕']='不恕:BAAALgAECgYJCQAAAA==.',
['不约']='不约儿童:BAAALgAECgYJBgAAAA==.',
['丨乌']='丨乌迪尔丨:BAAALgADCgQJBQAAAA==.',
['丨若']='丨若丨:BAABLgAFFH8HAAIHAAIJZgheOgCeAAAHAAIJZgheOgCeAAAAAA==.',
['丨陨']='丨陨落丶星辰:BAAALgAECgUJBQAAAA==.',
['临枫']='临枫听雨:BAAALgADCgYJBgAAAA==.',
['乂先']='乂先生:BAAALgAECgIJAwAAAA==.',
['乔丨']='乔丨小德:BAAALgAECgUJBQAAAA==.乔丨小战:BAAALgAECgEJAQAAAA==.',
['二月']='二月双鱼:BAABLgAFFH8JAAIIAAUJ7hbaDgD5AAAIAAUJ7hbaDgD5AAAAAA==.',
['仙嵋']='仙嵋:BAAALgADCgIJAgAAAA==.',
['伈祗']='伈祗宥妳:BAAALgAECgUJCQAAAA==.',
['伊利']='伊利优酸乳:BAAALgAECgIJAgAAAA==.',
['伊爾']='伊爾明斯特:BAAALgADCgMJBAAAAA==.',
['会灰']='会灰的鱼:BAAALgAECgQJBwAAAA==.',
['你别']='你别怕我:BAAALgADCgIJAgAAAA==.',
['你吃']='你吃雪糕吗:BAAALgAFFAIJAwAAAA==.',
['你是']='你是小猪:BAAALgAECgYJDAAAAA==.',
['你的']='你的瓜皮丶:BAAALgAFFAQJBAABLgAFFAUJBQAJAGkYAA==.',
['佳莉']='佳莉娅:BAAALgAFFAIJBAAAAA==.',
['使用']='使用搞哥老拳:BAAALgADCgYJBgAAAA==.使用毛哥凝视:BAAALgADCgUJBQAAAA==.',
['依旧']='依旧蔚蓝:BAAALgAECgQJBAAAAA==.',
['俗里']='俗里俗气丶:BAAALgAFFAQJBAAAAA==.',
['修伯']='修伯特:BAAALgAECgEJAQABLgAECgcJBwABAAAAAA==.',
['倦意']='倦意濃丶:BAAALgADCgUJBQAAAA==.',
['停手']='停手放:BAAALgADCgEJAQAAAA==.',
['克里']='克里提乌斯:BAAALgAECgcJBwAAAA==.',
['公子']='公子风绝:BAAALgAECgYJBgAAAA==.',
['冒牌']='冒牌裂人:BAAALgAECgYJCQAAAA==.',
['冰燕']='冰燕麦拿铁:BAABLgAECn8VAAMKAAkJnhTmEABcAgAKAAkJnhTmEABcAgALAAEJxwn9VwAyAAAAAA==.',
['凳子']='凳子骑:BAAALgADCgEJAQAAAA==.',
['出橙']='出橙萨:BAAALgAECgQJBAAAAA==.',
['割刎']='割刎滚:BAAALgAECgMJAwAAAA==.',
['动人']='动人在变幻:BAABLgAFFH8IAAIMAAQJoxVpCABDAQAMAAQJoxVpCABDAQAAAA==.',
['动物']='动物园:BAAALgADCgYJBgAAAA==.',
['包面']='包面王子:BAABLgAFFH8KAAINAAMJwxtNIgAOAQANAAMJwxtNIgAOAQAAAA==.',
['北风']='北风之刃:BAAALgAECgEJAwAAAA==.',
['十全']='十全十美:BAAALgAECgYJBgAAAA==.',
['半夜']='半夜恶熊低语:BAAALgADCgEJAQAAAA==.',
['卜湿']='卜湿玛丽:BAAALgAECgkJDQABLgAFFAcJBQAOANEWAA==.',
['卡尔']='卡尔顿:BAAALgAFFAIJAgAAAA==.',
['卡布']='卡布镧:BAAALgAECgQJAgAAAA==.',
['印第']='印第安纳琼斯:BAAALgADCgMJAwAAAA==.',
['反转']='反转旭光:BAAALgADCgcJBwAAAA==.',
['发飙']='发飙的布尔:BAAALgAECgUJBQAAAA==.',
['口刁']='口刁那声:BAAALgAECgQJBAAAAA==.',
['古墓']='古墓丽影:BAAALgAECgEJAQAAAA==.',
['古爾']='古爾蛋:BAAALgAECgEJAQAAAA==.',
['叶落']='叶落晚枫:BAABLgAFFH8FAAIPAAQJiAsFDgA6AQAPAAQJiAsFDgA6AQAAAA==.',
['司马']='司马徽仙人:BAAALgADCgEJAQAAAA==.',
['吖腩']='吖腩:BAAALgADCgUJBQAAAA==.',
['呜呜']='呜呜喳喳:BAAALgAECgYJEgAAAA==.',
['呜喵']='呜喵汪:BAAALgADCgMJAQAAAA==.',
['哈利']='哈利道特:BAAALgAECgQJBAAAAA==.',
['啊咓']='啊咓哒啃大瓜:BAAALgADCgEJAQAAAA==.',
['啊尔']='啊尔法:BAAALgAECgYJBQAAAA==.',
['喵喵']='喵喵锤:BAAALgAECgQJBgAAAA==.',
['噬月']='噬月魔:BAABLgAFFH8GAAINAAMJXA5rQQCeAAANAAMJXA5rQQCeAAAAAA==.',
['囡笑']='囡笑娘:BAAALgAFFAEJAQABLgAFFAIJAwABAAAAAA==.',
['圣灬']='圣灬灵:BAAALgAECgYJDAAAAA==.',
['地域']='地域咆哮本人:BAAALgADCgYJBgAAAA==.',
['地魔']='地魔小妖:BAAALgAECgMJBQAAAA==.地魔小子:BAAALgAECgMJAwAAAA==.',
['埃及']='埃及小开水:BAAALgAECgQJBAAAAA==.',
['墩墩']='墩墩尊尊:BAAALgAECgYJBwAAAA==.',
['夏灬']='夏灬迩:BAAALgAFFAIJAwAAAA==.',
['夕丶']='夕丶风暴列酒:BAABLgAFFH8RAAIQAAUJSxolAgBOAQAQAAUJSxolAgBOAQAAAA==.',
['多多']='多多香雪:BAAALgAECgEJAQAAAA==.',
['夜之']='夜之锋刃:BAAALgAECgYJCAAAAA==.',
['大漠']='大漠孤烟直:BAAALgAECgYJCAAAAA==.',
['大白']='大白熊:BAAALgAECgUJBQAAAA==.',
['天凉']='天凉好個秋:BAABLgAFFH8MAAIRAAYJHRGOAgB7AQARAAYJHRGOAgB7AQAAAA==.',
['天津']='天津地下明星:BAAALgAECgEJAQAAAA==.天津曲艺家:BAAALgAECgUJBgAAAA==.',
['天边']='天边:BAAALgADCgYJBwAAAA==.',
['奥义']='奥义大师:BAAALgADCgIJAgAAAA==.',
['奥莉']='奥莉薇尔语风:BAAALgAECgIJAgAAAA==.',
['女萨']='女萨满:BAAALgAECgIJAgAAAA==.',
['奶浴']='奶浴春莉:BAAALgADCgcJBwAAAA==.',
['奶萨']='奶萨真滴好玩:BAAALgAECgEJAQAAAA==.',
['好白']='好白一头牛:BAAALgADCgcJBwAAAA==.',
['如若']='如若初见:BAAALgAECgUJBQAAAA==.',
['妙趣']='妙趣:BAAALgAFFAQJBAAAAA==.',
['妲瓦']='妲瓦安娜:BAAALgAECgYJBgAAAA==.',
['姑苏']='姑苏丶墨璃:BAAALgAECgEJAgABLgAFFAIJAgABAAAAAA==.',
['威震']='威震地:BAAALgAECgEJAgAAAA==.',
['媛妹']='媛妹:BAAALgAECgYJBwAAAA==.',
['安洁']='安洁丽尔:BAAALgAFFAIJAwAAAA==.',
['安渡']='安渡法拉:BAAALgAECgcJAQAAAA==.',
['安纳']='安纳塞隆:BAAALgAECgYJBgAAAA==.',
['寒纱']='寒纱沁涼:BAAALgAFFAEJAQAAAA==.',
['尊尊']='尊尊敦敦:BAAALgAFFAEJAQAAAA==.',
['小丽']='小丽:BAAALgAECgYJBgAAAA==.',
['小小']='小小彬:BAAALgAFFAUJBAAAAA==.小小虫:BAACLgAFFH8IAAIJAAIJzA/vGgCsAAAJAAIJzA/vGgCsAAAuAAQKfxYAAgkABgllHfNuAPYBAAkABgllHfNuAPYBAAAA.',
['小术']='小术:BAAALgAECgEJAQAAAA==.',
['小猫']='小猫:BAAALgAECgEJAQABLgAFFAUJFQAGAEUgAA==.小猫咪儿:BAAALgADCgUJBQAAAA==.',
['小白']='小白菜丨丶:BAAALgAECgYJCQAAAA==.小白菜丶:BAAALgAFFAMJBAAAAA==.',
['小神']='小神龙丶:BAAALgAECgkJAQAAAA==.',
['小翠']='小翠西:BAAALgAFFAIJAgABLgAFFAYJBgASAAkSAA==.',
['小豆']='小豆薇:BAABLgAECn8aAAMTAAkJQB1bCAAMAwATAAgJOB9bCAAMAwAUAAcJuB/ZEwCTAgAAAA==.',
['小鳳']='小鳳仙:BAAALgAECgkJEAAAAA==.',
['尐贼']='尐贼貓:BAAALgAECgMJAwAAAA==.',
['尼姑']='尼姑拉丝死骑:BAAALgAECgEJAQAAAA==.',
['屯里']='屯里的蜥蜴:BAAALgAECgMJAwAAAA==.',
['岩山']='岩山单:BAAALgAECgYJBgAAAA==.',
['巨霸']='巨霸肌肉虾:BAAALgADCgEJAQAAAA==.',
['布吉']='布吉大叔:BAAALgAECgIJAgAAAA==.布吉岛岛:BAAALgAECgIJAgAAAA==.',
['希罗']='希罗:BAAALgAECgcJEwAAAA==.',
['帝皇']='帝皇在上:BAAALgADCgYJBgABLgADCgYJBgABAAAAAA==.',
['幕乃']='幕乃伊:BAAALgAECgUJCQAAAA==.',
['年轻']='年轻不讲武德:BAACLgAFFH8FAAIPAAIJUBrDHQC2AAAPAAIJUBrDHQC2AAAuAAQKfxgAAg8ABwmPIIIOALQBAA8ABwmPIIIOALQBAAAA.',
['异形']='异形惜旻宝:BAABLgAFFH8HAAIIAAMJyRGaGACcAAAIAAMJyRGaGACcAAAAAA==.',
['张洞']='张洞:BAACLgAFFH8VAAIGAAUJRSDJAAD+AQAGAAUJRSDJAAD+AQAuAAQKfxYAAgYACAmlJewDAE8DAAYACAmlJewDAE8DAAAA.',
['彪子']='彪子:BAAALgAECgIJAgAAAA==.',
['彭于']='彭于晏丶:BAAALgAECgcJDQABLgAECgkJCQABAAAAAA==.',
['影零']='影零乱:BAAALgAECgQJBAAAAA==.',
['徐战']='徐战战:BAAALgAECgYJBAAAAA==.',
['御風']='御風而行:BAAALgADCgEJAQAAAA==.',
['德不']='德不偿失:BAAALgAECgMJCAAAAA==.',
['德丶']='德丶:BAAALgAECgYJBgAAAA==.',
['快乐']='快乐的味道:BAAALgAECgUJBQAAAA==.',
['怯战']='怯战蜥蜴丶:BAAALgAECgQJBwAAAA==.',
['恋爱']='恋爱总烂尾:BAAALgAECgYJDQAAAA==.',
['悠悠']='悠悠牧心:BAAALgAECgMJAwAAAA==.',
['悠然']='悠然一:BAAALgAFFAQJBAABLgAFFAYJBAABAAAAAA==.悠然五:BAAALgAFFAQJAwABLgAFFAYJBAABAAAAAA==.悠然六:BAAALgAFFAQJBAABLgAFFAYJBAABAAAAAA==.',
['我告']='我告老师:BAAALgAECgIJAwAAAA==.',
['我手']='我手上有枪:BAAALgAECgEJAQAAAA==.',
['我没']='我没有斩炎:BAAALgAECgQJBAAAAA==.',
['我爱']='我爱樱桃:BAAALgAECggJCQAAAA==.',
['执笔']='执笔画沙:BAAALgAECgYJBwAAAA==.',
['拉达']='拉达曼迪斯:BAAALgAECgUJCgAAAA==.',
['指尖']='指尖时光:BAAALgAECgMJAwAAAA==.',
['教主']='教主橙澄憕:BAAALgADCgEJAgAAAA==.',
['无名']='无名释:BAAALgAECgQJBwAAAA==.',
['无常']='无常真灿烂:BAABLgAFFH8GAAIMAAQJ2xGSDwDrAAAMAAQJ2xGSDwDrAAAAAA==.',
['星辰']='星辰之祈:BAAALgAECgMJAwAAAA==.',
['春上']='春上花枝:BAAALgAECgIJAgAAAA==.',
['晓糖']='晓糖:BAABLgAECn8cAAMKAAgJpw3WNABrAQAKAAgJUwfWNABrAQALAAQJoBU9MgAPAQAAAA==.',
['晓软']='晓软糖:BAABLgAECn8XAAMVAAgJ0QGzVQDOAAAVAAcJFgKzVQDOAAAIAAUJSwCP0wAsAAAAAA==.',
['晚枫']='晚枫:BAABLgAFFH8IAAIPAAQJiw1aDQBAAQAPAAQJiw1aDQBAAQAAAA==.',
['晚话']='晚话:BAABLgAFFH8IAAIPAAQJ+ArvDQA7AQAPAAQJ+ArvDQA7AQAAAA==.',
['晚风']='晚风停舟:BAAALgAFFAIJAgAAAA==.',
['暗处']='暗处放黑枪:BAAALgAECgQJBgAAAA==.',
['暗涌']='暗涌:BAABLgAFFH8NAAIMAAUJwxb/AgCsAQAMAAUJwxb/AgCsAQAAAA==.',
['暗语']='暗语镞风:BAAALgAECgIJAgAAAA==.',
['暴力']='暴力的美学:BAAALgAECgEJAQAAAA==.',
['暴躁']='暴躁战坦:BAABLgAFFH8FAAIWAAMJ2QpIFQDLAAAWAAMJ2ApIFQDLAAAAAA==.',
['月舞']='月舞之风:BAABLgAFFH8NAAIEAAYJ9g72AQCtAQAEAAYJ9g72AQCtAQAAAA==.',
['有个']='有个战土:BAAALgADCgQJBAAAAA==.',
['未眠']='未眠:BAABLgAFFH8HAAIMAAQJGhiaBwBMAQAMAAQJGhiaBwBMAQAAAA==.',
['末日']='末日余晖:BAAALgAECgEJAQAAAA==.',
['本地']='本地冬瓜:BAAALgADCgUJBQAAAA==.本地南瓜:BAAALgAECgQJBAAAAA==.',
['李佬']='李佬嘿:BAAALgAECgMJAwAAAA==.',
['束尸']='束尸:BAAALgADCgYJBgAAAA==.',
['果粒']='果粒橙灬:BAAALgAECgUJBQAAAA==.',
['枪火']='枪火谈判:BAAALgAECgYJBwAAAA==.',
['枫无']='枫无双:BAAALgAECgYJCwAAAA==.',
['枫林']='枫林:BAABLgAECn8cAAIJAAcJhBm+agAAAgAJAAcJhBm+agAAAgAAAA==.',
['柠乐']='柠乐走冰:BAAALgADCgQJBAABLgAFFAMJCQAPALQcAA==.',
['柠茶']='柠茶飞冰:BAABLgAFFH8JAAIPAAMJtBzEEgAPAQAPAAMJtBzEEgAPAQAAAA==.',
['桃花']='桃花晚照:BAAALgAECgEJAgAAAA==.',
['桔梗']='桔梗丶丶:BAAALgAFFAIJAgAAAA==.',
['梦见']='梦见鱼香肉丝:BAAALgAECgYJCQAAAA==.',
['梧桐']='梧桐半死:BAAALgAECgUJCAAAAA==.',
['森海']='森海飞霞:BAAALgAECgkJEAAAAA==.',
['橙露']='橙露沁涼:BAABLgAFFH8FAAIQAAMJzwgsDADvAAAQAAMJzwgsDADvAAAAAA==.',
['欢乐']='欢乐的二狗:BAABLgAFFH8FAAINAAIJxR6JMwC6AAANAAIJxR6JMwC6AAAAAA==.',
['欧阳']='欧阳锋:BAAALgAECgQJBAAAAA==.',
['死亡']='死亡牛牛猪:BAAALgAECgIJAwAAAA==.',
['殇之']='殇之夜:BAAALgAECgYJDQABLgAFFAIJBQANAMUeAA==.',
['毛毛']='毛毛大领主:BAAALgAFFAIJAgAAAA==.',
['水月']='水月无间:BAABLgAFFH8JAAIMAAUJKg9VBACMAQAMAAUJKg9VBACMAQAAAA==.',
['沙沙']='沙沙:BAAALgADCgEJAQAAAA==.',
['治疗']='治疗胡须不散:BAAALgADCgIJAgAAAA==.',
['法不']='法不可言:BAAALgAECgQJBgABLgAECggJCQABAAAAAA==.',
['法号']='法号三葬:BAAALgAECgEJAQAAAA==.',
['波仑']='波仑伽:BAAALgADCgEJAQAAAA==.',
['洛叁']='洛叁阡:BAAALgAECgYJEQABLgAECgkJFQAKAJ4UAA==.',
['浅间']='浅间丶智:BAAALgAECgkJBgAAAA==.',
['海珠']='海珠区丧元:BAAALgAECgYJCwABLgAFFAIJAwABAAAAAA==.',
['涅墨']='涅墨西斯语风:BAAALgAECgUJCQAAAA==.',
['淡酒']='淡酒闲茶:BAAALgADCgUJBQAAAA==.',
['深秋']='深秋带凉丶:BAAALgAECgUJBAABLgAFFAQJBgAUAK0SAA==.',
['混乱']='混乱一丁:BAAALgAECgEJAQAAAA==.',
['混沌']='混沌变身:BAAALgAECgYJEQAAAA==.',
['清云']='清云:BAAALgAECgUJCQABLgAFFAYJFQAXAEsTAA==.',
['渔渔']='渔渔喵:BAAALgAECgEJAgAAAA==.',
['渡千']='渡千雪:BAABLgAFFH8MAAIWAAQJUhsVEQD2AAAWAAQJUhsVEQD2AAAAAA==.',
['灬若']='灬若灬:BAABLgAFFH8FAAIPAAMJhwlIGADrAAAPAAMJhwlIGADrAAAAAA==.',
['炎拳']='炎拳使用专家:BAAALgAECgEJAgAAAA==.',
['烟寒']='烟寒月:BAAALgAFFAIJAwAAAA==.',
['牙齿']='牙齿有点疼:BAAALgAECgkJAwAAAA==.',
['牧野']='牧野琉璃:BAABLgAFFH8IAAINAAQJqhl5FABRAQANAAQJqhl5FABRAQAAAA==.',
['特别']='特别黑之夜:BAAALgAECgIJBgAAAA==.',
['独自']='独自在飘:BAAALgADCgMJAwAAAA==.',
['猫武']='猫武神:BAAALgADCgUJBQAAAA==.',
['猫牛']='猫牛儿:BAAALgAECgcJBwAAAA==.',
['猫猫']='猫猫可爱:BAAALgADCgIJAgAAAA==.猫猫萌萌德:BAAALgADCgQJBAAAAA==.猫猫逐光者:BAAALgADCgUJBQAAAA==.',
['玛丽']='玛丽玛丽红:BAACLgAFFH8HAAIGAAMJfxx7CQDVAAAGAAMJfxx7CQDVAAAuAAQKfxoAAwYABwl7IasNAKECAAYABwl7IasNAKECABEAAwknGcFCANYAAAAA.',
['玛珐']='玛珐里奥:BAAALgAFFAIJAgAAAA==.',
['玛蕾']='玛蕾格碧:BAAALgAECgQJBAAAAA==.',
['玫瑰']='玫瑰巷的乞儿:BAAALgAECgUJCAAAAA==.',
['环切']='环切术:BAAALgAECgEJAQAAAA==.',
['珑祈']='珑祈:BAAALgAECgMJAwAAAA==.',
['琉璃']='琉璃烟火:BAAALgAECgEJAQAAAA==.',
['瑟劲']='瑟劲满满:BAAALgADCgEJAQAAAA==.',
['甘蔗']='甘蔗糖:BAAALgAECgUJBQAAAA==.',
['生花']='生花:BAABLgAFFH8GAAIMAAUJDxbfAgCwAQAMAAUJDxbfAgCwAQAAAA==.',
['疯飒']='疯飒飒:BAAALgAECgYJCAAAAA==.',
['白骨']='白骨衣:BAAALgAECgYJDQABLgAFFAUJFQAGAEUgAA==.',
['百憮']='百憮禁忌:BAAALgADCgEJAQAAAA==.',
['百特']='百特乌曼:BAAALgAECgIJAgAAAA==.',
['知更']='知更鸟灬:BAAALgAFFAEJAgAAAA==.',
['硬得']='硬得一比:BAAALgAFFAMJAwAAAA==.',
['神之']='神之诱手:BAAALgADCgUJBQAAAA==.',
['神奇']='神奇吾王:BAAALgAECgUJCAAAAA==.',
['私奔']='私奔:BAAALgAFFAQJBAAAAA==.',
['粉红']='粉红刹妈酱:BAAALgAECgUJBgAAAA==.',
['精灵']='精灵女王:BAAALgADCgEJAQABLgADCgUJBQABAAAAAA==.',
['繁华']='繁华去冷风尽:BAAALgAFFAEJAQAAAA==.',
['纯粹']='纯粹的寂寞:BAAALgAFFAIJAgAAAA==.',
['给颗']='给颗糖就行:BAAALgAECgYJBgAAAA==.',
['绿色']='绿色好心情:BAAALgADCgEJAQAAAA==.绿色法皇:BAAALgAECgEJAQAAAA==.',
['绿蚁']='绿蚁新醅酒:BAABLgAFFH8JAAMMAAUJRQ7+AwCTAQAMAAUJRQ7+AwCTAQAOAAEJWQMAAAAAAAAAAA==.',
['缪珂']='缪珂丝:BAAALgAECgUJBQAAAA==.',
['罗雨']='罗雨萱宝宝:BAAALgAFFAIJAgAAAA==.',
['老大']='老大哥看着你:BAAALgAECgIJAgAAAA==.',
['肉弹']='肉弹师太:BAAALgAECgUJBQAAAA==.',
['能哥']='能哥:BAAALgAECgcJEAAAAA==.能哥地心之战:BAAALgAECgUJCwAAAA==.',
['苏杨']='苏杨:BAAALgAECgcJBwAAAA==.',
['若凡']='若凡:BAAALgAECgcJBwAAAA==.',
['苹果']='苹果同学:BAAALgAECgUJCgAAAA==.',
['草莓']='草莓味胳肢窝:BAAALgAECgYJDAAAAA==.',
['荣耀']='荣耀圣骑:BAAALgAECgMJBAAAAA==.',
['莎士']='莎士比亚:BAAALgAECgEJAQAAAA==.',
['菊皋']='菊皋皋:BAACLgAFFH8GAAITAAMJwBJHDAAAAQATAAMJwBJHDAAAAQAuAAQKfxkAAxMACAlpFtkfAEYCABMACAlpFtkfAEYCABQAAQldAj6YAB4AAAAA.',
['菓胨']='菓胨:BAABLgAFFH8FAAMYAAMJth/PAACnAAAJAAMJth9zNADGAAAYAAIJBhDPAACnAAAAAA==.',
['菲布']='菲布里佐:BAAALgAECgYJBgAAAA==.',
['萨尤']='萨尤啦啦:BAAALgAECgQJBQAAAA==.',
['萨满']='萨满风中转:BAABLgAFFH8GAAIMAAMJGQ69CwCNAAAMAAMJGQ69CwCNAAAAAA==.',
['萨鲁']='萨鲁小王:BAAALgADCgUJBwAAAA==.',
['落日']='落日晚枫:BAABLgAFFH8GAAIPAAQJcAcFEAAnAQAPAAQJcAcFEAAnAQAAAA==.落日晚霞:BAAALgAFFAUJAgAAAA==.',
['董卓']='董卓遇貂蝉:BAAALgADCgEJAQAAAA==.',
['蒙牛']='蒙牛丹五十风:BAAALgAECgYJBgAAAA==.蒙牛丹四七风:BAAALgAECgYJBgAAAA==.',
['蒜香']='蒜香小肋排:BAAALgAECgQJBgAAAA==.',
['蔸俚']='蔸俚侑糖:BAAALgAECgYJCAAAAA==.',
['蕾娜']='蕾娜塔亡语者:BAAALgADCgMJBgAAAA==.',
['蕾米']='蕾米莉亞:BAACLgAFFH8JAAINAAQJ9Qz/GwAzAQANAAQJ9Qz/GwAzAQAuAAQKfxgAAg0ACAmLIvoXAOwCAA0ACAmLIvoXAOwCAAAA.',
['虐死']='虐死你哦哈哈:BAAALgAECgQJBQAAAA==.',
['虚伪']='虚伪的温柔:BAAALgADCgUJBQAAAA==.',
['蛋苕']='蛋苕儿:BAAALgAECgYJDAAAAA==.',
['装糖']='装糖阴一手丶:BAAALgAECgIJAgAAAA==.',
['褪了']='褪了色的回憶:BAAALgAECgQJBQAAAA==.',
['说分']='说分就分:BAAALgADCgMJAwAAAA==.',
['賊丶']='賊丶:BAAALgAECgcJBwAAAA==.',
['赵有']='赵有种:BAAALgADCgUJBQAAAA==.',
['路卡']='路卡利欧:BAAALgAECgIJAgAAAA==.',
['辛卓']='辛卓拉莉丝:BAAALgAECgMJAwAAAA==.',
['辛多']='辛多雷挽歌:BAAALgAECgcJAQAAAA==.',
['辛瓦']='辛瓦尔:BAAALgADCgQJBAAAAA==.',
['过去']='过去的岁月:BAAALgAECgEJAgAAAA==.',
['迷失']='迷失东京:BAAALgAECgEJAQAAAA==.',
['退悠']='退悠悠:BAAALgAECgYJBgAAAA==.',
['逆光']='逆光莱:BAAALgADCgUJBQAAAA==.',
['逍遥']='逍遥海鸥:BAAALgAECgMJBgAAAA==.',
['逸兴']='逸兴湍飞:BAAALgADCgEJAQAAAA==.',
['酒醉']='酒醉的玫瑰:BAAALgAECgEJAgAAAA==.酒醉的离殇:BAAALgAECgEJAQAAAA==.',
['酱汁']='酱汁排骨:BAAALgAECgMJAwAAAA==.',
['醉舞']='醉舞封殇:BAAALgAECgcJBwAAAA==.',
['重头']='重头丶再来:BAAALgAECgEJAQAAAA==.',
['重生']='重生之我喷了:BAAALgAFFAIJAwAAAA==.',
['钱小']='钱小美:BAAALgADCgQJBAAAAA==.',
['长岛']='长岛吴彦祖:BAAALgAECgcJDQAAAA==.',
['闲茶']='闲茶淡酒:BAAALgAECgYJDQAAAA==.',
['阝等']='阝等待:BAAALgAECgUJBQAAAA==.',
['阿尔']='阿尔托莉雅:BAAALgAECgIJAgAAAA==.',
['阿库']='阿库一:BAABLgAFFH8RAAMMAAYJiyFYAQDwAQAMAAYJiyFYAQDwAQAOAAEJTwFfIQA5AAAAAA==.阿库七:BAABLgAFFH8GAAMMAAQJEhBvDwDsAAAMAAMJwwxvDwDsAAAOAAEJYwC2IQA0AAAAAA==.阿库三:BAABLgAFFH8KAAMMAAUJWRtgBgBgAQAMAAQJnhlgBgBgAQAOAAEJ3QPLDwBCAAAAAA==.阿库九:BAABLgAFFH8FAAMMAAUJUAt1CQA5AQAMAAQJ2Ql1CQA5AQAOAAEJ4wH8IAA9AAAAAA==.阿库二:BAABLgAFFH8PAAMMAAYJax7xAAC9AQAMAAUJaB3xAAC9AQAOAAEJCQbFHwBDAAAAAA==.阿库五:BAABLgAFFH8IAAMMAAUJiR17BQB0AQAMAAQJDRx7BQB0AQAOAAEJlAEzIQA6AAAAAA==.阿库八:BAAALgAFFAIJAgAAAA==.阿库六:BAABLgAFFH8GAAMMAAQJsBVYDgD3AAAMAAMJwBJYDgD3AAAOAAEJeACzIQA0AAAAAA==.阿库十:BAABLgAFFH8HAAMMAAQJcRuVDAAQAQAMAAMJfxqVDAAQAQAOAAEJnQEuIQA7AAAAAA==.阿库四:BAABLgAFFH8FAAMMAAUJaRYgBwBUAQAMAAQJoxMgBwBUAQAOAAEJkwEpIQA7AAAAAA==.',
['陌上']='陌上吟归雪:BAAALgAECgEJAQAAAA==.',
['雨之']='雨之馨:BAAALgADCgEJAQAAAA==.',
['雪域']='雪域之刃:BAAALgAFFAIJBAAAAA==.',
['雾岛']='雾岛:BAAALgAECgUJBQAAAA==.',
['霁光']='霁光:BAAALgAECgEJAgAAAA==.',
['霜星']='霜星澈:BAAALgADCgEJAQAAAA==.',
['風蔠']='風蔠的悠殇:BAAALgADCgEJAQAAAA==.',
['风歌']='风歌夜语:BAAALgAECgcJCAAAAA==.',
['香云']='香云:BAAALgADCgEJAQAAAA==.',
['香甜']='香甜小龙虾:BAAALgAECgIJAgAAAA==.',
['鬼舞']='鬼舞辻无惨:BAAALgAECgQJAwAAAA==.',
['鱼见']='鱼见见:BAAALgAECgMJAwAAAA==.',
['鲜血']='鲜血之魂:BAAALgAFFAEJAQAAAA==.',
['鸾觞']='鸾觞酌醴:BAAALgAECgMJBAAAAA==.',
['鹌东']='鹌东尼达斯:BAAALgADCgEJAQAAAA==.',
['麻辛']='麻辛:BAAALgADCgUJBQAAAA==.',
['黑泽']='黑泽志玲:BAAALgADCgIJAgAAAA==.',
['龙丶']='龙丶雪児:BAAALgAECgYJEAAAAA==.',
['龙肉']='龙肉烧饼:BAAALgADCgYJBgAAAA==.',
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
