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
 local lookup = {'DemonHunter-Havoc','Rogue-Assassination','Rogue-Subtlety','Paladin-Protection','DeathKnight-Frost','Druid-Feral','Shaman-Restoration','Shaman-Elemental','Warlock-Destruction','Priest-Holy','Druid-Balance','Druid-Restoration','Shaman-Enhancement','Warlock-Demonology','Paladin-Retribution','Paladin-Holy','Mage-Frost','Mage-Arcane','Druid-Guardian','Evoker-Devastation','Priest-Shadow','DeathKnight-Blood','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Hunter-Marksmanship',}; local provider = {region='CN',realm='基尔罗格',name='CN',type='weekly',zone=44,date='2025-12-06',data={Er='Er:BAAALAAECgYIDAAAAA==.',Gr='Grommash:BAAALAAECgYIBgABLAAFFAMICQABAOgZAA==.',Ho='Holydiver:BAAALAAECgQIBAAAAA==.',Il='Illidari:BAABLAAFFH8JAAIBAAMI6Bm4GQALAQABAAMI6Bm4GQALAQAAAA==.',Ki='Kiko:BAAALAAECgYIBgAAAA==.',Le='Leeken:BAAALAADCgEIAQAAAA==.',Mo='Mo:BAABLAAFFH8KAAMCAAIIgiEgEADJAAACAAIIgiEgEADJAAADAAEIggG+IAAuAAABLAAFFAMICQABAOgZAA==.Mogul:BAAALAAECgYICAAAAA==.',Ne='Nevermind:BAAALAAFFAIIBAAAAA==.',Nj='Njoo:BAABLAAFFH8FAAIEAAIIkx1mDQCrAAAEAAIIkx1mDQCrAAAAAA==.',No='Noir:BAAALAAFFAIIAgAAAA==.Noshiro:BAAALAAECgIIAgAAAA==.',Re='Rebornmvmba:BAAALAAFFAIIAgAAAA==.',Rx='Rxe:BAABLAAFFH8MAAIFAAQIVyLMOgC8AAAFAAQIVyLMOgC8AAAAAA==.',Ti='Tinypc:BAAALAAFFAIIAgAAAA==.',Tr='Tresdin:BAAALAAECgYIBgAAAA==.',Tu='Tupac:BAAALAAECgYIBgAAAA==.',Vi='Vine:BAABLAAFFH8IAAIGAAIIoRywCQCuAAAGAAIIoRywCQCuAAAAAA==.',Wy='Wyztdjl:BAAALAADCgYIBwAAAA==.',Yy='Yy:BAAALAADCgIIAgAAAA==.',['一个']='一个橘子:BAAALAADCgUIBwAAAA==.',['一笔']='一笔丢糟:BAAALAAECgEIAQAAAA==.',['不剥']='不剥壳吃龙虾:BAAALAAFFAEIAQAAAA==.',['东之']='东之尹甸:BAAALAADCgUIBQAAAA==.',['丨初']='丨初鹤丶:BAAALAAECgYIDAAAAA==.',['丶枫']='丶枫丶:BAACLAAFFH8FAAIHAAIIFA0QYQBaAAAHAAIIFA0QYQBaAAAsAAQKfxUAAwcABgiJF7OCAHsBAAcABgiJF7OCAHsBAAgABQgTDsBMAN0AAAAA.',['亚特']='亚特兰蒂斯:BAAALAAECgQIBQAAAA==.',['亡魂']='亡魂摆渡者:BAABLAAECn8fAAIJAAgI/BypMQB1AgAJAAgI/BypMQB1AgAAAA==.',['京酱']='京酱肉丝:BAACLAAFFH8IAAMHAAIIRgXiZwBZAAAHAAIIRgXiZwBZAAAIAAIIpgntUgAsAAAsAAQKfykAAwcACAg8EESgAD4BAAcACAg8EESgAD4BAAgABggIEt44ACsBAAAA.',['人肉']='人肉轰炸机:BAAALAAFFAIIAgAAAA==.',['付费']='付费保安:BAAALAAECgYIEAAAAA==.',['伊兰']='伊兰德:BAAALAAFFAIIBAAAAA==.',['伤心']='伤心治疗者:BAAALAAECgUIBgAAAA==.',['你太']='你太火热:BAAALAAECgUICgAAAA==.',['你猜']='你猜我猜不猜:BAAALAAECgYIBwAAAA==.',['光明']='光明救赎:BAABLAAFFH8NAAIKAAYIiCQXBQB/AgAKAAYIiCQXBQB/AgAAAA==.',['兔清']='兔清云不算:BAABLAAFFH8GAAMLAAIImwucJgB4AAALAAIImwucJgB4AAAMAAIIAAcmQgBdAAAAAA==.',['农业']='农业魔斗士:BAAALAAFFAQIBAAAAA==.',['冰火']='冰火双重奏:BAAALAAECgYICAAAAA==.',['冰雨']='冰雨:BAAALAAECggICAAAAA==.',['刀刀']='刀刀:BAABLAAFFH8GAAINAAYI7gA4CQAbAAANAAYI7gA4CQAbAAABLAAFFAgICgAHAM0jAA==.',['创圣']='创圣:BAAALAADCgYIBgAAAA==.',['前后']='前后夹击:BAAALAAECgYIBgAAAA==.',['十万']='十万巫女:BAAALAAECgYIBwAAAA==.',['十六']='十六夜秋:BAABLAAFFH8MAAMOAAIIChmTJABVAAAOAAEI5RuTJABVAAAJAAEILhbrXABCAAAAAA==.',['千古']='千古幽兰:BAAALAAECgYIBgAAAA==.',['卡巴']='卡巴斯基:BAAALAADCgIIAgAAAA==.',['呲溜']='呲溜呲溜:BAABLAAFFH8JAAIHAAMIKgxHSwCGAAAHAAMIKgxHSwCGAAAAAA==.',['哈吉']='哈吉牛魔:BAAALAAFFAIIAgAAAA==.',['啊好']='啊好白:BAAALAADCgYIBgAAAA==.啊好矮:BAAALAAECgMIBQAAAA==.',['喆文']='喆文帆诣冉如:BAAALAAECgYICAAAAA==.',['喜多']='喜多川海梦:BAAALAAFFAIIAgAAAA==.',['四顾']='四顾心茫然:BAAALAAECggIDAAAAA==.',['地狱']='地狱铁:BAABLAAFFH8JAAIFAAMIOQliaAB1AAAFAAMIOQliaAB1AAAAAA==.',['墨香']='墨香铜臭:BAAALAADCgMIAwAAAA==.',['夕月']='夕月画温柔:BAAALAAECgEIAQAAAA==.',['大勇']='大勇是呆比:BAABLAAFFH8HAAIPAAIIXw1rawBAAAAPAAIIXw1rawBAAAAAAA==.',['大爱']='大爱仙尊:BAAALAAECgUIBQAAAA==.',['大猪']='大猪:BAAALAADCgYIBgAAAA==.',['天命']='天命卡佛卡:BAAALAADCgMIAwAAAA==.',['天生']='天生坏胎:BAAALAADCgIIAgAAAA==.',['奥利']='奥利萨特:BAAALAAFFAIIAgAAAA==.',['奧利']='奧利斯特:BAAALAAECgQIBAAAAA==.',['孤独']='孤独的懒猫:BAAALAAECgQIBAAAAA==.',['守护']='守护月天:BAABLAAFFH8GAAMQAAQIpQY8JAB7AAAQAAMIqgY8JAB7AAAPAAMIvgMMZQBEAAAAAA==.',['官拜']='官拜忌酒:BAAALAADCgQIBAAAAA==.',['宽窄']='宽窄:BAAALAAECgYIBgAAAA==.',['寂寞']='寂寞妇女之夜:BAAALAAFFAIIAgAAAA==.',['小王']='小王子:BAAALAADCgYIBgAAAA==.',['小趴']='小趴菜:BAABLAAECn8cAAIEAAYIMhqfFwBYAQAEAAYIMhqfFwBYAQAAAA==.',['川页']='川页君:BAAALAAECgQIBAAAAA==.',['幻化']='幻化黑洞:BAAALAAECgYIBgAAAA==.',['幻影']='幻影旅团奶妈:BAAALAAECgYIBgAAAA==.',['强人']='强人唢男:BAAALAAECgYIBgAAAA==.',['念慈']='念慈悲:BAABLAAFFH8SAAIKAAYIbyPyBQBtAgAKAAYIbyPyBQBtAgAAAA==.',['恶魔']='恶魔小旋风:BAAALAADCgcIBwAAAA==.',['懒猫']='懒猫猫:BAAALAAECgYIDgAAAA==.',['我就']='我就是要惹你:BAAALAAFFAQIBAAAAA==.',['打坤']='打坤男孩:BAAALAADCgIIAgAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8eAAIHAAYIORulFAC7AQAHAAYIORulFAC7AQAAAA==.',['挡吾']='挡吾者杀:BAAALAADCgQIBAAAAA==.',['捌條']='捌條:BAAALAAECgYIBgABLAAFFAgIHgAMACwiAA==.',['放学']='放学别走:BAAALAADCgIIAgAAAA==.',['文思']='文思豆腐:BAAALAAECgYICwAAAA==.',['无聊']='无聊的猪哥:BAABLAAFFH8ZAAIFAAYI2hSyDgDhAQAFAAYI2hSyDgDhAQABLAAFFAgICAAIACkAAA==.',['星空']='星空大领主:BAAALAADCgYIBgAAAA==.',['春十']='春十三娘:BAAALAAECgMIAwAAAA==.',['暴力']='暴力系懒蟲:BAABLAAECn8YAAIRAAYIbxaWNQCgAQARAAYIbxaWNQCgAQAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8QAAMMAAgI/xwqBwA7AgAMAAcIOxwqBwA7AgALAAEIACNvKQBqAAAAAA==.',['朝仓']='朝仓音梦:BAAALAADCggICAAAAA==.',['朴尚']='朴尚影:BAACLAAFFH8KAAISAAUISBIXMABGAQASAAUISBIXMABGAQAsAAQKfxUAAhIABghWHkAgAKwBABIABghWHkAgAKwBAAAA.朴尚英:BAAALAAECgMIAwAAAA==.',['桑娅']='桑娅:BAAALAAECgIIAgAAAA==.',['梧桐']='梧桐树:BAAALAAECgYIEAAAAA==.',['楽楽']='楽楽魔:BAAALAAFFAIIAgAAAA==.',['江珞']='江珞成额老爹:BAAALAAFFAMIAwAAAA==.',['沧桑']='沧桑的毛毛虫:BAAALAAECgYIBgAAAA==.',['油压']='油压丝啪:BAAALAAECgYIBgAAAA==.',['海海']='海海欧维欧:BAAALAADCgYIBgAAAA==.',['海肠']='海肠捞饭:BAAALAAFFAIIBAAAAA==.',['渡众']='渡众生:BAABLAAFFH8MAAIKAAYIFCRkBQB6AgAKAAYIFCRkBQB6AgAAAA==.',['渣德']='渣德:BAACLAAFFH8FAAMTAAIIeAY4CwBaAAALAAIIlgOJKQBmAAATAAIIeAY4CwBaAAAsAAQKfysABQsACAjRId8WAK4CAAsACAjRId8WAK4CABMABghdDOYhAP4AAAYABQhhC8oxAP4AAAwABwgDBROfANcAAAAA.',['潘帕']='潘帕斯巨婴:BAAALAAECgYIBgAAAA==.',['火球']='火球精通卡:BAABLAAFFH8GAAISAAIIVAQyZABuAAASAAIIVAQyZABuAAAAAA==.',['灰烬']='灰烬锤锤:BAAALAAFFAIIAgAAAA==.',['灵活']='灵活死胖子:BAAALAAECgYIDQAAAA==.',['热心']='热心网友小邱:BAAALAAECgMIBAAAAA==.',['爱菲']='爱菲:BAAALAAECgYIBgAAAA==.',['牛满']='牛满仓:BAAALAADCgIIAgAAAA==.',['狂奔']='狂奔瓜牛:BAAALAADCgMIAwAAAA==.狂奔的瓜牛:BAAALAADCgcIBwAAAA==.',['猫哆']='猫哆哩:BAAALAAECgYIBgAAAA==.',['玖帝']='玖帝:BAAALAAECgIIAgAAAA==.',['瓦尔']='瓦尔基利:BAAALAADCgcICwAAAA==.',['电竞']='电竞小年糕:BAAALAAECgYIBwAAAA==.',['男上']='男上加难:BAABLAAECn8XAAIUAAYIixKpOABuAQAUAAYIixKpOABuAQAAAA==.',['番茄']='番茄狐:BAAALAAECgYIBwAAAA==.',['白河']='白河愁:BAABLAAFFH8SAAIKAAYIfyMGBgBsAgAKAAYIfyMGBgBsAgAAAA==.',['眼大']='眼大恩子:BAAALAAECgMIAwAAAA==.',['破晓']='破晓斩月:BAAALAAECgYIEgAAAA==.',['破曉']='破曉斩月:BAACLAAFFH8IAAMKAAIIbQNtQQByAAAKAAIIbQNtQQByAAAVAAIIqQnnMQAqAAAsAAQKfxUAAxUACAiNFOYxAAECABUACAiNFOYxAAECAAoABgjTDYQ5AAQBAAAA.',['神使']='神使玄武:BAAALAADCgQIBAAAAA==.',['祷言']='祷言:BAABLAAFFH8MAAIKAAYICyRwBQB5AgAKAAYICyRwBQB5AgAAAA==.',['福人']='福人法:BAAALAAECgYICQAAAA==.',['符梨']='符梨:BAAALAAECgYIEAAAAA==.',['米卡']='米卡娅:BAAALAAECgYICwAAAA==.',['糖糖']='糖糖猫:BAAALAAECgMIAwAAAA==.糖糖龙:BAAALAADCgYIBgAAAA==.',['紫枫']='紫枫寒水:BAAALAAECgYIBgAAAA==.',['给我']='给我跑起来:BAABLAAFFH8GAAIWAAYIcgRCEADyAAAWAAYIcgRCEADyAAAAAA==.',['缦缨']='缦缨霜雪:BAAALAADCgQICAAAAA==.',['老肥']='老肥他男人:BAAALAAFFAIIAgAAAA==.',['花哭']='花哭丶花瓣飞:BAACLAAFFH8HAAISAAIIPBIDSACYAAASAAIIPBIDSACYAAAsAAQKfxQAAxIABghcICJKACcCABIABghcICJKACcCABEAAQhjD1aPAD0AAAAA.',['荆棘']='荆棘舞:BAABLAAFFH8GAAIKAAYI7RkcDgDyAQAKAAYI7RkcDgDyAQAAAA==.',['莎拉']='莎拉娜:BAABLAAECn8XAAIKAAgI0RyQHwB8AgAKAAgI0RyQHwB8AgABLAAFFAYIJAAKAMIjAA==.',['萨拉']='萨拉丁:BAAALAADCgYIBgAAAA==.',['蒙哥']='蒙哥马利:BAAALAADCgIIAgAAAA==.',['虹口']='虹口虚竹:BAABLAAFFH8WAAMXAAUIlx4WCACrAQAXAAUIlx4WCACrAQAYAAEIrgoUHgAAAAAAAA==.',['螂螂']='螂螂物语:BAAALAADCggICAAAAA==.',['血妖']='血妖之后:BAACLAAFFH8HAAISAAIImQ3tVgCJAAASAAIImQ3tVgCJAAAsAAQKfycAAhIACAiWH0slALgCABIACAiWH0slALgCAAAA.',['赞吉']='赞吉尓:BAAALAADCgIIAgAAAA==.',['跑脱']='跑脱了是蚂虾:BAAALAADCggICAAAAA==.',['辛迪']='辛迪:BAAALAAECggICAAAAA==.',['达萌']='达萌猫:BAABLAAFFH8HAAIZAAYIZBcADACEAQAZAAYIZBcADACEAQAAAA==.',['迷你']='迷你库巴:BAABLAAECn8UAAIHAAYIKBVzlABVAQAHAAYIKBVzlABVAQAAAA==.',['道法']='道法自然:BAAALAADCgEIAQAAAA==.',['金牛']='金牛:BAAALAAECgYICQAAAA==.',['陆萬']='陆萬:BAABLAAECn8fAAIaAAgI8SQeBwAwAwAaAAgI8SQeBwAwAwABLAAECggIHAAaAAsjAA==.',['雷加']='雷加坦格利安:BAAALAAECgYIDgAAAA==.',['雷碧']='雷碧城丶:BAAALAAFFAIIBAAAAA==.',['霜儿']='霜儿在地上追:BAAALAAFFAIIAgAAAA==.',['顶风']='顶风吹飞机:BAAALAAECgUIBQAAAA==.',['风火']='风火雷电猫:BAAALAAECgYIDAAAAA==.',['飘雪']='飘雪无痕:BAAALAADCgMIAwAAAA==.',['食族']='食族人:BAAALAAFFAIIAgAAAA==.',['骷髅']='骷髅手:BAACLAAFFH8qAAIJAAYIRxlFIwCOAQAJAAYIRxlFIwCOAQAsAAQKfx4AAgkACAh+HhwwAHwCAAkACAh+HhwwAHwCAAAA.',['黎明']='黎明挚爱:BAAALAAFFAIIAgAAAA==.',['黑萝']='黑萝卜:BAABLAAFFH8KAAIPAAIIiwVGXACDAAAPAAIIiwVGXACDAAAAAA==.',['齐静']='齐静春:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end