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

local lookup = {'Evoker-Devastation','Mage-Frost','Druid-Restoration','Priest-Shadow','Priest-Holy','Priest-Discipline','Unknown-Unknown','Warrior-Fury','Evoker-Preservation','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Subtlety','Druid-Guardian','DemonHunter-Devourer','Warrior-Protection','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Shaman-Restoration','Paladin-Holy','Paladin-Retribution','DeathKnight-Unholy',}
local provider = {region='CN',realm='达斯雷玛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ap='Apocalypse:BAAALgAECgMJBQAAAA==.',
Av='Avenger:BAAALgAECgQJBQAAAA==.',
Ch='Chot:BAAALgAECgYJEwAAAA==.',
Da='Dabolo:BAAALgAECgYJDQAAAA==.',
Fo='Foreverjh:BAAALgADCgIJAgAAAA==.',
Ka='Kaidou:BAAALgAECgEJAgAAAA==.',
Pl='Playerkoyzyo:BAAALgADCgUJBQAAAA==.',
Ro='Roy:BAAALgAECgUJBgAAAA==.',
So='Sol:BAAALgAECgMJAwAAAA==.',
Ve='Verta:BAABLgAFFH8LAAIBAAQJhhgxAgBrAQABAAQJhhgxAgBrAQAAAA==.',
Vi='Viceer:BAAALgADCgEJAgAAAA==.',
['一之']='一之濑琴美:BAAALgAECgYJDgAAAA==.',
['一二']='一二:BAAALgAECgkJDwAAAA==.',
['一无']='一无情一:BAAALgAECgMJAwAAAA==.',
['一碗']='一碗面条:BAAALgAECgIJAwAAAA==.',
['不吃']='不吃靖哥哥:BAAALgADCgcJBwAAAA==.',
['与妮']='与妮共舞:BAABLgAECn8bAAICAAcJwx1/VAA7AgACAAcJwx1/VAA7AgABLgAFFAUJCAADAEQOAA==.',
['丶羁']='丶羁绊:BAAALgAECgEJAgAAAA==.',
['乀可']='乀可乐:BAAALgAFFAEJAQAAAA==.',
['乄黑']='乄黑眼圈乄:BAAALgAECgYJDwAAAA==.',
['九千']='九千胜:BAAALgAECgUJCQAAAA==.',
['二大']='二大妈:BAABLgAECn8VAAQEAAYJig8DLgBwAQAEAAYJig8DLgBwAQAFAAYJDAe/SwAJAQAGAAEJxACxIgAPAAAAAA==.',
['五百']='五百五十五:BAAALgAECgYJBgAAAA==.',
['亮亮']='亮亮大秃头:BAAALgADCgcJBwAAAA==.',
['什么']='什么德魯伊:BAAALgAECgIJAgAAAA==.',
['仁狐']='仁狐:BAAALgAECgcJBwAAAA==.',
['佛家']='佛家高人:BAAALgAFFAQJBAAAAA==.',
['信仰']='信仰凋零:BAAALgADCgEJAQAAAA==.',
['倚天']='倚天箭:BAABLgAFFH8HAAICAAMJnQuCJgCgAAACAAMJnQuCJgCgAAAAAA==.',
['元素']='元素轻舞:BAAALgADCgYJCwAAAA==.',
['光头']='光头睿睿:BAAALgAECgYJBwAAAA==.',
['再飞']='再飞:BAAALgADCgQJBgAAAA==.',
['冰糖']='冰糖葫璐儿:BAAALgAFFAIJAgAAAA==.',
['冰雪']='冰雪浪漫:BAAALgAECgYJBgAAAA==.',
['凝乐']='凝乐:BAAALgAECgYJCAAAAA==.',
['剑刃']='剑刃之殇:BAAALgADCgQJBAAAAA==.',
['劳资']='劳资蜀道山:BAAALgAECgEJAgAAAA==.',
['十万']='十万八千梦:BAAALgADCgEJAQAAAA==.',
['半拉']='半拉柯基:BAAALgAECgcJEwAAAA==.',
['卡布']='卡布力拓:BAAALgAECgQJBAAAAA==.',
['只会']='只会红蓝观:BAAALgAECgEJAQABLgAFFAQJBAAHAAAAAA==.',
['可爱']='可爱的小德:BAAALgADCgUJBQAAAA==.',
['吴村']='吴村第一战:BAACLgAFFH8GAAIIAAQJZAxXDQAxAQAIAAQJZAxXDQAxAQAuAAQKfxYAAggACAl8GuYIAK4BAAgACAl8GuYIAK4BAAAA.',
['咕咕']='咕咕切个奶:BAAALgADCgUJBQAAAA==.',
['哈莉']='哈莉奎茵:BAAALgAECgYJBgAAAA==.',
['哎呀']='哎呀丶蓝龙:BAABLgAFFH8NAAIJAAUJNBf6BACoAQAJAAUJNBf6BACoAQAAAA==.',
['哦鼻']='哦鼻头:BAAALgAECgUJBQAAAA==.',
['喵呜']='喵呜依丹:BAAALgADCgMJAwAAAA==.',
['墨格']='墨格莱尼:BAAALgAECgEJAQAAAA==.',
['声波']='声波:BAAALgAECgIJAgAAAA==.',
['夏尼']='夏尼马掺胡:BAAALgAECgEJAQAAAA==.',
['夏臸']='夏臸未臸:BAAALgAECgQJBAAAAA==.',
['夜雨']='夜雨风轻:BAAALgAECgIJBQAAAA==.夜雨飘零:BAAALgAECgMJAwAAAA==.',
['大叔']='大叔就是好:BAAALgAECgcJDQAAAA==.',
['大锤']='大锤丶:BAAALgAECgEJAQAAAA==.',
['天之']='天之狼子:BAAALgAECgUJCwAAAA==.',
['天败']='天败星阮小七:BAABLgAFFH8IAAIKAAQJDQ9yAQBLAQAKAAQJDQ9yAQBLAQAAAA==.',
['奔跑']='奔跑的大叔:BAAALgAECgYJCgAAAA==.',
['妖妖']='妖妖领:BAAALgAFFAEJAQAAAA==.',
['娇滴']='娇滴滴的肉丸:BAABLgAECn8dAAMLAAcJzBO7RwCTAQALAAcJzBO7RwCTAQAMAAUJpAgDVwDrAAAAAA==.',
['安妮']='安妮没有熊丶:BAAALgADCgYJBgAAAA==.',
['小乙']='小乙哥:BAAALgADCgUJBQAAAA==.',
['小女']='小女子也能射:BAAALgAECgEJAQAAAA==.',
['小树']='小树娘娘丶:BAAALgAECgYJCgAAAA==.',
['小聋']='小聋瞎:BAAALgADCgcJBwABLgAFFAEJAQAHAAAAAA==.',
['少女']='少女与鲨:BAAALgAECgEJAQAAAA==.',
['少昊']='少昊:BAAALgADCgUJBQAAAA==.',
['尘封']='尘封的眷恋:BAAALgADCgIJAgAAAA==.',
['尘暮']='尘暮夕:BAAALgAECgcJDwAAAA==.',
['帝法']='帝法瑞斯:BAAALgAECgEJAQAAAA==.',
['幻西']='幻西:BAAALgAFFAQJBAAAAA==.',
['康斯']='康斯父:BAAALgAECgQJAQAAAA==.',
['德古']='德古拉灬杀戮:BAAALgAECgcJDwAAAA==.',
['我只']='我只是个符号:BAAALgAECgQJBAAAAA==.',
['我在']='我在故我变:BAAALgAECgEJAQAAAA==.',
['我射']='我射啦:BAAALgAFFAIJBAABLgAFFAgJBQAMAEEhAA==.',
['戳萨']='戳萨:BAAALgAECgIJAgAAAA==.',
['挽歌']='挽歌轻唱:BAAALgADCgMJAwAAAA==.',
['攬雀']='攬雀尾:BAAALgAECgQJBAAAAA==.',
['改名']='改名也叫牛德:BAAALgAECgYJAgABLgAFFAIJAgAHAAAAAA==.',
['星德']='星德守月:BAABLgAECn8bAAINAAgJ1xVkFgBaAgANAAgJ1xVkFgBaAgAAAA==.',
['星群']='星群浸染:BAAALgADCgkJCQAAAA==.',
['智力']='智力:BAACLgAFFH8JAAICAAQJoRpRFgBwAQACAAQJoRpRFgBwAQAuAAQKfyUAAgIACAlyI+oRADwDAAIACAlyI+oRADwDAAAA.',
['月翼']='月翼猫头鹰:BAABLgAFFH8HAAIOAAcJJRdFAABUAgAOAAcJJRdFAABUAgAAAA==.',
['朋友']='朋友与狗:BAAALgAECgIJAgAAAA==.',
['木子']='木子:BAAALgAECgEJAQAAAA==.木子一小德:BAAALgAECgYJBgAAAA==.',
['枫林']='枫林儿:BAAALgAECgEJAQAAAA==.',
['柳如']='柳如烟:BAAALgAECgEJAgAAAA==.',
['格伦']='格伦斯塔:BAAALgADCgEJAQAAAA==.',
['梦术']='梦术:BAAALgADCgEJAQABLgAECgEJAgAHAAAAAA==.',
['毛丶']='毛丶丶:BAAALgAECgQJBAAAAA==.',
['法神']='法神灬眷恋:BAAALgAECgYJBgAAAA==.',
['波兹']='波兹尤宁:BAAALgAECgQJBAAAAA==.',
['流浪']='流浪小德:BAAALgAECgYJCAAAAA==.',
['浩劫']='浩劫之影:BAAALgADCgYJBQAAAA==.',
['涂山']='涂山红红:BAAALgAECgYJDAAAAA==.',
['濡墨']='濡墨:BAABLgAECn8UAAMPAAYJpBeiXACLAQAPAAYJpBeiXACLAQAKAAUJTxGwPQAGAQABLgAECgcJBwAHAAAAAA==.',
['灬神']='灬神棍德:BAAALgAECgYJCgAAAA==.灬神棍战:BAAALgADCgMJAwAAAA==.',
['灬阿']='灬阿桀灬:BAAALgAFFAIJAwAAAA==.',
['灰烬']='灰烬蛋园:BAAALgADCgIJAgAAAA==.',
['烟雨']='烟雨轻舞:BAAALgADCgEJAQAAAA==.',
['無上']='無上大梵天:BAAALgAECgcJCQAAAA==.',
['爱晒']='爱晒太阳的云:BAAALgADCgEJAQAAAA==.',
['狗头']='狗头人头狗:BAAALgAECgIJBAAAAA==.',
['猎头']='猎头之王:BAAALgAECgYJCgAAAA==.',
['玛嘚']='玛嘚珥:BAAALgAECgcJCAAAAA==.',
['瑞原']='瑞原明奈:BAABLgAECn8ZAAIGAAcJrSAJCwCHAgAGAAcJrSAJCwCHAgAAAA==.',
['瓦尔']='瓦尔登:BAAALgAECgYJBAAAAA==.',
['电疗']='电疗大师:BAAALgAECgYJBgAAAA==.',
['疯子']='疯子一:BAAALgAECgIJAgAAAA==.',
['白羽']='白羽帕拉丁:BAAALgAECgQJBAAAAA==.',
['皇爷']='皇爷爷:BAAALgAECgYJBwAAAA==.',
['皮了']='皮了玩:BAAALgADCgYJBgAAAA==.',
['盘古']='盘古之力:BAAALgADCgUJBQAAAA==.',
['神昭']='神昭焚天:BAAALgADCgEJAQAAAA==.',
['秀荣']='秀荣:BAAALgAECgEJAgAAAA==.',
['米奈']='米奈希尔灬灵:BAAALgAECgkJCQAAAA==.',
['罒灬']='罒灬罒:BAAALgAECgUJBQAAAA==.',
['罒轻']='罒轻舞飞扬罒:BAAALgADCgEJAQAAAA==.',
['罗科']='罗科索夫司机:BAAALgAECgEJAQAAAA==.',
['翻滾']='翻滾吧牛寶寶:BAAALgAFFAIJAgAAAA==.',
['肆分']='肆分水平:BAAALgAECgkJEAABLgAECgkJFwAQAMAcAA==.',
['苍白']='苍白玫瑰:BAAALgAECgMJAwAAAA==.',
['茶兀']='茶兀:BAAALgADCgEJAQAAAA==.',
['菜瓜']='菜瓜:BAACLgAFFH8ZAAQRAAcJwyCDAABeAgARAAYJ3yCDAABeAgASAAEJnhuhCQBfAAATAAEJBxAkFQBTAAAuAAQKfxYAAhEACAlvJkUDAGADABEACAlvJkUDAGADAAAA.',
['蓝莓']='蓝莓慕斯:BAAALgAECgcJEgAAAA==.',
['蓬莱']='蓬莱藤原妹红:BAAALgADCgIJAgAAAA==.',
['薇风']='薇风:BAAALgADCgEJAQAAAA==.',
['蜂蜜']='蜂蜜抽子:BAAALgADCgYJBgAAAA==.',
['血查']='血查理诺兰:BAAALgAECgUJCgAAAA==.',
['血色']='血色丨暗翼:BAABLgAFFH8IAAIDAAIJ4hxBFwCnAAADAAIJ4hxBFwCnAAABLgAFFAMJCAAUAPkaAA==.血色丨汐潮:BAABLgAFFH8IAAIUAAMJ+RrJCwAcAQAUAAMJ+RrJCwAcAQAAAA==.',
['袅袅']='袅袅达人:BAAALgAECgEJAgAAAA==.',
['調戲']='調戲伱:BAAALgADCgEJAQAAAA==.',
['豆鲨']='豆鲨包:BAAALgAFFAIJAgAAAA==.',
['超级']='超级大苦力:BAAALgADCgcJBwAAAA==.',
['达斯']='达斯维达:BAAALgAECgcJBQAAAA==.',
['这个']='这个世界太乱:BAAALgAECgYJBgAAAA==.',
['远眺']='远眺:BAAALgAECgEJAwAAAA==.',
['逐风']='逐风者一炮神:BAAALgAECgQJBQAAAA==.',
['逸天']='逸天:BAABLgAECn8UAAMVAAYJFxpwLgDKAQAVAAYJFxpwLgDKAQAWAAYJyRiOgQB3AQAAAA==.',
['郑阿']='郑阿伦:BAAALgAECgMJBAAAAA==.',
['醉失']='醉失风情丶失:BAAALgAFFAcJBAAAAA==.醉失风情丶醉:BAABLgAFFH8FAAIIAAUJ7htdAgDWAQAIAAUJ7htdAgDWAQAAAA==.',
['铁牢']='铁牢里的囚徒:BAAALgAECgEJAQAAAA==.',
['铁甲']='铁甲威牛:BAAALgADCgEJAQAAAA==.',
['闹一']='闹一气:BAABLgAECn8VAAICAAYJxRykeQDeAQACAAYJxRykeQDeAQAAAA==.',
['闹来']='闹来闹去:BAACLgAFFH8FAAIXAAIJeRkJNgCwAAAXAAIJeRkJNgCwAAAuAAQKfxoAAhcABwm3GupPAAICABcABwm3GupPAAICAAAA.',
['陈灬']='陈灬风暴烈酒:BAAALgAECgQJBAAAAA==.',
['陌上']='陌上花开:BAAALgAECgMJAwAAAA==.',
['雅雅']='雅雅小红手:BAAALgAFFAIJAgAAAA==.',
['霁谙']='霁谙瑚茵:BAAALgAFFAIJAgAAAA==.',
['静晓']='静晓薰:BAAALgAECgQJBQAAAA==.',
['风吹']='风吹丨雨散:BAAALgAFFAIJAgAAAA==.',
['风行']='风行者灬小角:BAAALgAECgMJAwAAAA==.',
['香莲']='香莲:BAAALgAECgYJAwAAAA==.',
['骁宝']='骁宝宝:BAAALgAECgEJAQAAAA==.',
['鬼迷']='鬼迷日眼:BAAALgAECgEJAQAAAA==.',
['魔人']='魔人啾啾:BAAALgAECgcJBwAAAA==.',
['鲁德']='鲁德牛:BAABLgAFFH8FAAIDAAMJLA0FEgDZAAADAAMJLA0FEgDZAAAAAA==.',
['鸡血']='鸡血注入:BAAALgAECgYJBgAAAA==.',
['黧绕']='黧绕:BAAALgAECgIJAgAAAA==.',
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
