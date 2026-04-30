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

local lookup = {'Unknown-Unknown','Shaman-Elemental','Shaman-Restoration','Mage-Frost','Paladin-Retribution','Druid-Restoration','Paladin-Holy','Evoker-Preservation','DeathKnight-Unholy','Monk-Brewmaster','DemonHunter-Havoc','DemonHunter-Devourer','Druid-Guardian','Paladin-Protection','Evoker-Augmentation','Evoker-Devastation','Priest-Holy','Priest-Shadow','Druid-Balance','Hunter-BeastMastery','Hunter-Survival','Warrior-Fury','Priest-Discipline','Hunter-Marksmanship','Warrior-Protection','Warrior-Arms','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','Monk-Windwalker','Monk-Mistweaver','DeathKnight-Frost','Rogue-Outlaw',}
local provider = {region='CN',realm='戈提克',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Ambition:BAAALgAECgYJDwAAAA==.Amoxicillin:BAAALgAECgIJAgABLgAECgYJBgABAAAAAA==.',
An='Angieashfor:BAAALgAECggJDAAAAA==.',
Bl='Bloodwing:BAAALgAECgYJCwAAAA==.',
Br='Brollan:BAACLgAFFH8IAAICAAMJEiQeCgBBAQACAAMJEiQeCgBBAQAuAAQKfxwAAwIACAmhI/EGACMDAAIACAmhI/EGACMDAAMAAgl9AsqRAFMAAAAA.',
Ch='Chaosrain:BAAALgAFFAIJAgAAAA==.',
Cr='Crazyhold:BAAALgAFFAMJAwAAAA==.',
De='Desiny:BAAALgAECgUJCgAAAA==.',
Fe='Fedroda:BAAALgAECgEJAQAAAA==.',
Fo='Forsake:BAAALgAECgYJEQAAAA==.',
Hu='Huan:BAAALgAECgQJBAAAAA==.',
Hz='Hzalchemist:BAAALgAECgMJAwAAAA==.Hzcreolopus:BAAALgAECgcJEQAAAA==.',
In='Inga:BAAALgAECgcJBwAAAA==.',
Je='Jeesiejj:BAAALgADCgEJAQAAAA==.',
Jo='Jokerpriest:BAAALgADCgMJAwAAAA==.',
Ki='Kianakaslana:BAAALgADCgIJAgAAAA==.',
La='Larry:BAABLgAFFH8GAAIEAAIJ5A8kPgCwAAAEAAIJ5A8kPgCwAAAAAA==.',
Li='Littlef:BAAALgADCgUJBQAAAA==.',
Lu='Ludiwg:BAAALgAECgMJAwAAAA==.',
My='Mydaughterid:BAAALgADCgIJAQAAAA==.',
Ne='Nemole:BAAALgAECgMJBAAAAA==.Neroclaudius:BAACLgAFFH8SAAIFAAUJviKfAQAJAgAFAAUJviKfAQAJAgAuAAQKfx4AAgUACAkeJkMGAGkDAAUACAkeJkMGAGkDAAAA.',
Ni='Nicotine:BAAALgAECgYJDgAAAA==.',
Ol='Ollopopollo:BAAALgAECgUJCgAAAA==.',
Pe='Penis:BAAALgAECgIJAgAAAA==.Perceived:BAAALgAECgEJAgAAAA==.',
Ra='Rainfall:BAABLgAECn8ZAAIEAAgJEx1INACiAgAEAAgJEx1INACiAgABLgAFFAUJBAABAAAAAA==.',
Sc='Schoenberg:BAACLgAFFH8IAAIGAAMJzCZbBwBeAQAGAAMJzCZbBwBeAQAuAAQKfyMAAgYACAlFJXsDAFsDAAYACAlFJXsDAFsDAAAA.',
Sl='Sleepyhead:BAABLgAFFH8FAAIEAAUJyyNQBAArAgAEAAUJyyNQBAArAgAAAA==.',
Sn='Snowvilliers:BAAALgADCgEJAQAAAA==.',
So='Sonicfox:BAAALgAECgEJAQAAAA==.',
Sp='Spluseo:BAAALgADCgEJAQAAAA==.',
Sw='Swisse:BAAALgADCgUJBQAAAA==.',
Ta='Taurus:BAAALgAECgEJAQAAAA==.',
['一姐']='一姐:BAAALgAFFAEJAgAAAA==.',
['一枪']='一枪:BAAALgAECgYJDQAAAA==.',
['一颗']='一颗大白兔:BAAALgAFFAIJBAAAAA==.',
['七月']='七月爱吃西瓜:BAAALgAFFAEJAQAAAA==.',
['七生']='七生熄七:BAACLgAFFH8HAAIFAAMJEhmiEwAJAQAFAAMJEhmiEwAJAQAuAAQKfyIAAwUACAlTIHoCAJcCAAUACAlTIHoCAJcCAAcAAwmcHYhqANAAAAAA.',
['三七']='三七:BAAALgAECgYJBgAAAA==.',
['三角']='三角初华:BAAALgAFFAEJAgAAAA==.',
['上杉']='上杉姐姐:BAAALgAECgQJBgAAAA==.',
['上校']='上校鸡块:BAAALgAECgMJAwAAAA==.',
['不会']='不会变身:BAAALgADCgIJAgAAAA==.',
['不急']='不急慢慢来:BAAALgAECggJEgAAAA==.',
['不明']='不明法术:BAAALgAECgEJAgAAAA==.',
['不玩']='不玩奶龙:BAACLgAFFH8SAAIIAAUJKCBPAQC6AQAIAAUJKCBPAQC6AQAuAAQKfyUAAggACQlNIiABAIIDAAgACQlNIiABAIIDAAAA.',
['不髙']='不髙興丶:BAAALgAECgYJBgAAAA==.',
['丰川']='丰川箱子:BAABLgAFFH8FAAIJAAQJWgzyHgBbAAAJAAQJWgzyHgBbAAAAAA==.',
['为了']='为了汉堡包:BAAALgAECgYJBgAAAA==.',
['为谁']='为谁变壞:BAAALgAECgMJAwAAAA==.',
['丿尘']='丿尘埃丶:BAAALgADCgYJCgAAAA==.',
['丿灬']='丿灬稀丶饭:BAAALgAECgEJAQAAAA==.',
['乀乀']='乀乀刀来:BAABLgAFFH8FAAIKAAIJqBKuGwCPAAAKAAIJqBKuGwCPAAAAAA==.',
['乔治']='乔治布鲁斯丶:BAAALgAECgEJAgAAAA==.',
['了事']='了事了了:BAAALgAECgYJBwAAAA==.',
['五五']='五五开彦祖:BAAALgAECgQJBAAAAA==.',
['亚莎']='亚莎:BAAALgAECgcJDQAAAA==.',
['亲爱']='亲爱徳:BAAALgAECgYJBgAAAA==.',
['人心']='人心薄凉丶伤:BAABLgAFFH8FAAIGAAUJyxX5BACMAQAGAAUJyxX5BACMAQAAAA==.',
['今晚']='今晚地锅鸡:BAAALgAECgMJBAAAAA==.今晚砂锅鸡:BAAALgAECgYJBgAAAA==.',
['仿生']='仿生泪滴:BAABLgAECn8nAAMLAAgJSx2MEABeAgALAAgJSx2MEABeAgAMAAgJthIGTADEAQAAAA==.',
['伊卡']='伊卡洛斯闪电:BAAALgAECgYJCgAAAA==.',
['伤情']='伤情绝唱:BAAALgAECgUJBQAAAA==.',
['佑一']='佑一:BAAALgAECgMJAwAAAA==.',
['余小']='余小雨:BAAALgADCgIJAQAAAA==.',
['依然']='依然丶非死的:BAAALgAECgUJCQAAAA==.',
['便当']='便当制造者:BAABLgAECn8jAAINAAgJChR0FQAbAQANAAgJChR0FQAbAQAAAA==.便当配送者:BAAALgAECgUJBQAAAA==.',
['傻嗨']='傻嗨鸟:BAAALgAECgEJAQAAAA==.',
['像风']='像风一样逃跑:BAAALgAECgIJAgAAAA==.',
['光耀']='光耀右手:BAAALgAFFAEJAQAAAA==.',
['再喝']='再喝壹瓶:BAAALgAECgEJAQAAAA==.',
['再打']='再打我试试看:BAAALgADCgQJBAAAAA==.',
['冰方']='冰方块:BAAALgADCgEJAQAAAA==.',
['凉森']='凉森玲梦:BAAALgAECgYJBgAAAA==.',
['凑友']='凑友希那:BAABLgAECn8XAAIOAAgJ+CT7AABfAwAOAAgJ+CT7AABfAwAAAA==.',
['刀儿']='刀儿匠:BAAALgAECgEJAQAAAA==.',
['刂綄']='刂綄镁丶緈諨:BAAALgAECgIJAgAAAA==.',
['别跟']='别跟我瞎掰:BAAALgAECgcJBgAAAA==.',
['十九']='十九号还房贷:BAAALgADCgQJBAAAAA==.',
['千里']='千里:BAAALgAECgQJBgAAAA==.',
['半秒']='半秒圣光:BAAALgAECgYJDAAAAA==.',
['半马']='半马腰三菱:BAAALgAECgUJDgAAAA==.',
['南宫']='南宫恨:BAAALgADCgEJAQAAAA==.',
['去哪']='去哪儿浪:BAAALgAECgYJCgAAAA==.',
['取名']='取名丶新之助:BAAALgAECgMJAwAAAA==.',
['叫啥']='叫啥:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我吴温柔:BAAALgAECgIJAgAAAA==.',
['可口']='可口:BAAALgAFFAEJAQAAAA==.',
['史蒂']='史蒂芬周:BAAALgADCgUJBQAAAA==.',
['右眼']='右眼天堂:BAAALgAECgQJBQAAAA==.',
['吃口']='吃口小肥:BAAALgAFFAIJAgAAAA==.',
['吉拉']='吉拉纳斯塔兹:BAABLgAECn8oAAMPAAgJhh1jEgBXAgAPAAgJhh1jEgBXAgAQAAQJjRTlKADYAAAAAA==.',
['吉霸']='吉霸囼妲:BAAALgAECgEJAQAAAA==.',
['君一']='君一:BAABLgAECn8UAAMRAAkJ7R1HDACOAgARAAcJQiFHDACOAgASAAYJix4jFgA3AgAAAA==.',
['咆哮']='咆哮的薇薇安:BAAALgAECggJEAAAAA==.',
['咔滋']='咔滋脆鸡腿堡:BAACLgAFFH8IAAIEAAMJVB9jJQAeAQAEAAMJVB9jJQAeAQAuAAQKfyYAAgQACAlUI5cVACcDAAQACAlUI5cVACcDAAAA.',
['哈哈']='哈哈有点浪:BAABLgAFFH8IAAIFAAQJHhgOAwBnAQAFAAQJHhgOAwBnAQAAAA==.',
['啊尔']='啊尔肥诺:BAABLgAFFH8LAAIPAAUJLh48BADNAQAPAAUJLh48BADNAQAAAA==.',
['嗜血']='嗜血之墓:BAAALgAECgcJEgAAAA==.',
['嗨土']='嗨土豆:BAABLgAFFH8HAAIKAAMJFAaIFgC+AAAKAAMJFAaIFgC+AAAAAA==.',
['噗噗']='噗噗:BAACLgAFFH8IAAIHAAQJLBqMBgBuAQAHAAQJLBqMBgBuAQAuAAQKfx4AAwcABwmpIeYRAIMCAAcABwmpIeYRAIMCAAUAAQmrDgtBATQAAAAA.',
['地獄']='地獄咆哮之子:BAAALgAECgcJEwAAAA==.',
['墨然']='墨然:BAAALgAECgEJAQAAAA==.',
['士兵']='士兵男孩:BAAALgAECgkJEAAAAA==.',
['大天']='大天尊:BAAALgAECgQJBQAAAA==.',
['天笑']='天笑:BAAALgAECgQJBQAAAA==.',
['奈奈']='奈奈戈熊:BAAALgAECgYJBgAAAA==.',
['奎木']='奎木狼:BAAALgADCgUJBQAAAA==.',
['奔放']='奔放的小蚂蚁:BAAALgAECgUJBQAAAA==.',
['奥尔']='奥尔加伊兹卡:BAABLgAECn8XAAITAAgJVBdqGwAnAgATAAgJVBdqGwAnAgAAAA==.',
['好大']='好大哥:BAACLgAFFH8FAAITAAIJERk4EgCyAAATAAIJERk4EgCyAAAuAAQKfyEAAxMACAlOH8QLANsCABMACAlOH8QLANsCAAYAAgneDrOvAGYAAAAA.',
['如梦']='如梦令:BAAALgAECgYJDAAAAA==.',
['姬塔']='姬塔:BAAALgADCgEJAQAAAA==.',
['嫩牛']='嫩牛吃老草:BAABLgAECn8XAAICAAcJJxIxMgCTAQACAAcJJxIxMgCTAQAAAA==.',
['孤魂']='孤魂野鬼:BAAALgADCgIJAgAAAA==.',
['孬孬']='孬孬玩玩:BAAALgAECgEJAQAAAA==.',
['宇智']='宇智波丶刘能:BAAALgAECgIJAgAAAA==.',
['安达']='安达洛林:BAAALgAECgkJEgAAAA==.',
['安道']='安道尔:BAAALgAFFAIJAgAAAA==.',
['完颜']='完颜红猎:BAAALgAECgYJDwAAAA==.',
['宝马']='宝马标志:BAAALgAECgYJCAAAAA==.',
['宣城']='宣城虎將:BAACLgAFFH8VAAIMAAYJEBnnAgAXAgAMAAYJEBnnAgAXAgAuAAQKfyMAAgwACAmNI/MMABgDAAwACAmNI/MMABgDAAAA.',
['寂寞']='寂寞丶小強:BAABLgAFFH8IAAMUAAMJqxldBgAYAQAUAAMJqxldBgAYAQAVAAEJdAH7BwBDAAAAAA==.',
['寒風']='寒風亂舞:BAAALgAECgEJAQAAAA==.',
['对氨']='对氨基苯磺酸:BAAALgAECgcJCQAAAA==.',
['小夜']='小夜纱:BAAALgAECgEJAQAAAA==.',
['小意']='小意思呵呵:BAAALgADCgcJBwAAAA==.',
['小茶']='小茶狐:BAAALgAECgMJAwAAAA==.',
['小萨']='小萨蕉:BAAALgAECgcJBwAAAA==.',
['小阿']='小阿七:BAAALgAECgYJDAAAAA==.',
['尐尛']='尐尛丶犇爺:BAABLgAECn8UAAIWAAgJKgoFRwCIAQAWAAgJKgoFRwCIAQAAAA==.',
['尾火']='尾火虎:BAAALgAECgEJAQAAAA==.',
['崆峒']='崆峒山战士:BAAALgAECgMJAwAAAA==.',
['巨无']='巨无霸丶:BAAALgAECgEJAQAAAA==.',
['布鲁']='布鲁诺:BAAALgAECgQJBQAAAA==.',
['帝影']='帝影:BAAALgAECgEJAQAAAA==.',
['幺妹']='幺妹儿乖惨了:BAAALgAECgEJAQAAAA==.',
['幽炫']='幽炫:BAAALgAECgYJCwAAAA==.',
['弋痕']='弋痕矽:BAAALgAECgEJAQAAAA==.',
['弗洛']='弗洛洛:BAAALgAECgcJEQAAAA==.',
['弘丨']='弘丨一缕阳光:BAAALgAECgQJBAAAAA==.',
['张十']='张十九:BAAALgAECgEJAQAAAA==.',
['张尔']='张尔摩斯:BAAALgAECgUJBQAAAA==.',
['张锦']='张锦小笨蛋:BAAALgADCgYJBgAAAA==.',
['彦祖']='彦祖快奶我:BAAALgAECgUJBQAAAA==.',
['怼死']='怼死你:BAABLgAFFH8GAAIJAAMJXgsEEAD4AAAJAAMJXgsEEAD4AAAAAA==.',
['恋人']='恋人葉子:BAAALgAECgMJBAAAAA==.',
['恋月']='恋月:BAAALgADCgIJAgAAAA==.',
['惊鸿']='惊鸿第一猎:BAAALgAECgEJAQAAAA==.',
['慢点']='慢点等等我:BAAALgAECgYJCAAAAA==.',
['慯丶']='慯丶陌陌:BAACLgAFFH8FAAIJAAIJ8ww5RgCYAAAJAAIJ8ww5RgCYAAAuAAQKfxYAAgkACAm1FdJGACACAAkACAm1FdJGACACAAAA.',
['我也']='我也是老王:BAAALgAECgIJAgAAAA==.',
['我好']='我好烦耶:BAAALgAECgIJAwAAAA==.',
['我爱']='我爱蓝色:BAAALgADCgQJBAAAAA==.',
['我过']='我过的很好:BAAALgAECgEJAQAAAA==.',
['扎西']='扎西顿珠:BAAALgAFFAEJAQAAAA==.',
['承遥']='承遥:BAAALgAECgkJDgAAAA==.',
['断禁']='断禁舞步:BAAALgAECgEJAQABLgAECggJJwALAEsdAA==.',
['断罪']='断罪之花:BAAALgAECgEJAQAAAA==.',
['斯米']='斯米马赛:BAAALgAECgYJEQAAAA==.',
['星痕']='星痕若雪:BAACLgAFFH8GAAQSAAIJ6wdpCACXAAASAAIJ6wdpCACXAAAXAAIJfgcJFQCNAAARAAEJCgO6EwBGAAAuAAQKfxsABBIACAlpF6gbAAACABIABwmgGKgbAAACABcAAQk3DrNYADAAABEAAQntBLWBADAAAAAA.',
['是非']='是非不成:BAAALgADCgMJAwAAAA==.',
['晓星']='晓星:BAAALgAECggJEgAAAA==.',
['暗尘']='暗尘随去:BAAALgAECgMJAwAAAA==.',
['最伟']='最伟大的银狐:BAAALgAECgUJBQAAAA==.',
['月岛']='月岛萤:BAAALgAECgcJDAAAAA==.',
['月遇']='月遇从云:BAACLgAFFH8FAAIJAAIJQSQmMQDHAAAJAAIJQSQmMQDHAAAuAAQKfygAAgkACAl2JP4KAEMDAAkACAl2JP4KAEMDAAAA.',
['月雅']='月雅儿:BAAALgADCgUJBQABLgAFFAUJBQAXANEPAA==.',
['有容']='有容:BAAALgAECgQJBQAAAA==.',
['朝廷']='朝廷心腹大患:BAABLgAECn8hAAMUAAgJDiCCIABCAgAYAAgJixwKGQBfAgAUAAYJxiCCIABCAgAAAA==.',
['未微']='未微蓝丶:BAAALgAECgEJAQAAAA==.',
['末曰']='末曰审判丶:BAAALgADCgcJBwAAAA==.',
['朵拉']='朵拉斯丶怒风:BAAALgADCgQJBgAAAA==.',
['李亦']='李亦白:BAAALgAFFAIJAwAAAA==.',
['杨大']='杨大爷丶:BAABLgAFFH8FAAMXAAUJ7gYzGABQAAAXAAEJAAgzGABQAAARAAQJqQYAAAAAAAAAAA==.',
['格斗']='格斗快乐术:BAAALgAECgcJBgAAAA==.',
['桃夭']='桃夭白白:BAAALgAFFAIJAgAAAA==.',
['桃谷']='桃谷绘莉香:BAACLgAFFH8GAAIWAAMJ6hFiEQD8AAAWAAMJ6hFiEQD8AAAuAAQKfxwABBYABwmKHnIlAC0CABYABwl2G3IlAC0CABkABQm3GNEdAFcBABoAAQm9EGQ/ADkAAAAA.',
['梦魇']='梦魇猫猫:BAAALgAECgQJBgAAAA==.',
['楠楠']='楠楠:BAAALgAECgIJAgAAAA==.',
['榴莲']='榴莲核:BAAALgAECgEJAQABLgAECgYJBgABAAAAAA==.',
['樱花']='樱花好看不:BAAALgAECgUJBwAAAA==.',
['死后']='死后迷万人:BAAALgADCgUJBQAAAA==.',
['死神']='死神沃尔特:BAAALgAECgIJBAAAAA==.',
['毒奶']='毒奶很贴心:BAACLgAFFH8GAAITAAMJ4wUeBwDRAAATAAMJ4wUeBwDRAAAuAAQKfxcAAxMABwnHD38sAJ8BABMABwnHD38sAJ8BAAYABAmlFmtqABQBAAAA.',
['毕方']='毕方之炎:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛的胖胖鱼:BAAALgAECgYJCwAAAA==.',
['毛豆']='毛豆儿:BAAALgAECgIJAgAAAA==.',
['水水']='水水骑士:BAAALgAECgEJAQAAAA==.',
['汐见']='汐见琴音:BAAALgADCgUJBQAAAA==.',
['沁水']='沁水宫:BAAALgAECgEJAQAAAA==.',
['没丸']='没丸没了:BAAALgAECgEJAQAAAA==.',
['没事']='没事吃芒果:BAAALgAECgYJCgAAAA==.',
['流风']='流风双:BAAALgAECgcJBgAAAA==.',
['浪子']='浪子甜心:BAAALgADCgYJBwAAAA==.',
['海公']='海公牛:BAAALgAECgIJAgAAAA==.',
['深寒']='深寒魇魔:BAAALgAECgcJBwABLgAECgkJDAABAAAAAA==.',
['混口']='混口丨饭吃丶:BAAALgAECgYJCwAAAA==.',
['渣技']='渣技术请自重:BAAALgADCgYJBgAAAA==.',
['温皇']='温皇丶任飘渺:BAABLgAFFH8FAAIGAAIJMwnUHQCFAAAGAAIJMwnUHQCFAAAAAA==.',
['湛蓝']='湛蓝犄角:BAAALgAECgIJAgAAAA==.',
['溜溜']='溜溜球:BAACLgAFFH8IAAIbAAMJbyH/BAAsAQAbAAMJbyH/BAAsAQAuAAQKfycAAhsACAkXJNAAADsDABsACAkXJNAAADsDAAAA.',
['灰夜']='灰夜羽翼:BAABLgAFFH8GAAIUAAQJgBXgDgDUAAAUAAQJgBXgDgDUAAAAAA==.',
['烂橙']='烂橙子:BAAALgAECgQJBAAAAA==.',
['烂稥']='烂稥蕉:BAAALgAFFAIJBAAAAA==.',
['烤贝']='烤贝拉:BAAALgAECgQJCAAAAA==.',
['然爺']='然爺:BAAALgAFFAIJAgAAAA==.',
['煮蛋']='煮蛋:BAAALgAECgMJAgAAAA==.',
['爆了']='爆了丶香蕉:BAABLgAFFH8IAAIcAAQJeB4PGwAbAQAcAAQJeB4PGwAbAQAAAA==.',
['爱的']='爱的话:BAAALgAECgYJDQAAAA==.',
['牛德']='牛德华:BAAALgAECgYJBwAAAA==.',
['牛肉']='牛肉丸:BAAALgAFFAQJBAAAAA==.',
['狂野']='狂野的阿昆达:BAAALgAECgEJAQAAAA==.',
['狐狸']='狐狸长得丁:BAAALgAECgEJAQAAAA==.',
['狼牙']='狼牙风风拳:BAAALgAECgIJAgAAAA==.',
['猎艳']='猎艳:BAAALgAECgMJAwAAAA==.',
['猎麻']='猎麻人:BAACLgAFFH8GAAIVAAMJwgy4AgABAQAVAAMJwgy4AgABAQAuAAQKfyUAAhUACAkPF4oJAEcCABUACAkPF4oJAEcCAAAA.',
['玉玉']='玉玉小子:BAAALgAFFAIJAwAAAA==.',
['玖月']='玖月沉沦:BAACLgAFFH8HAAMRAAMJxiDqBQAhAQARAAMJxiDqBQAhAQASAAEJLwPYFgBGAAAuAAQKfyAAAxEACAl0IaENAH8CABEACAl0IaENAH8CABIACAkTGfsqAIMBAAAA.',
['玛咔']='玛咔巴卡:BAAALgAECgQJBQAAAA==.',
['琉璃']='琉璃若舞:BAAALgAECgYJDAAAAA==.',
['瑞奇']='瑞奇:BAACLgAFFH8OAAIDAAQJeh3UAgBbAQADAAQJeh3UAgBbAQAuAAQKfyoAAwMACQkDH5IDAD4DAAMACQkDH5IDAD4DAAIAAQlFDL6KAC4AAAAA.',
['生气']='生气就哼:BAAALgAECgYJBgAAAA==.',
['盖伊']='盖伊诱敌:BAAALgADCgQJBAAAAA==.',
['看我']='看我小黑手:BAAALgAECgEJAQAAAA==.看我就羊你:BAAALgAECgMJAwAAAA==.看我脸色荇事:BAAALgAECgEJAQAAAA==.',
['碳烤']='碳烤羊腿:BAABLgAECn8lAAMDAAgJ/SB+EQCLAgADAAgJ/SB+EQCLAgACAAMJbQb+cwByAAAAAA==.',
['祐天']='祐天寺若麦:BAAALgADCgYJBgAAAA==.',
['神圣']='神圣黄瓜:BAAALgAECgYJDQAAAA==.',
['神祗']='神祗篇帙:BAABLgAECn8WAAMHAAgJqCZ5AQBtAwAHAAgJqCZ5AQBtAwAFAAEJpQbeUwEpAAAAAA==.',
['神罚']='神罚之光:BAAALgAECgcJCAAAAA==.',
['窗外']='窗外雨哒哒:BAAALgAECgEJAQAAAA==.',
['笑铭']='笑铭戈叁:BAAALgADCgMJAwAAAA==.',
['箕水']='箕水豹:BAAALgADCgIJAgAAAA==.',
['糕等']='糕等数学:BAAALgAECgcJDwAAAA==.',
['糖油']='糖油果子之怒:BAAALgAECgEJAgAAAA==.',
['糖色']='糖色:BAABLgAFFH8FAAIcAAIJoxZcLwC0AAAcAAIJoxZcLwC0AAAAAA==.',
['紅茶']='紅茶獵師:BAABLgAECn8ZAAIYAAgJEgvzNACUAQAYAAgJEgvzNACUAQAAAA==.',
['素酒']='素酒慰余生:BAAALgAECgQJBAAAAA==.',
['紫夜']='紫夜凌风:BAAALgAECgEJAQAAAA==.',
['紫薯']='紫薯蛋挞:BAAALgAECgYJDgAAAA==.',
['红皮']='红皮卡丘:BAAALgAFFAIJAgABLgAFFAMJCAAEAFQfAA==.',
['给你']='给你漂漂拳:BAAALgAFFAIJAgABLgAFFAUJAgABAAAAAA==.',
['绝版']='绝版死骑:BAAALgAECgIJAgAAAA==.',
['绥绥']='绥绥:BAAALgAECgkJCQAAAA==.',
['绯弹']='绯弹的亚里亚:BAAALgAFFAEJAQAAAA==.',
['维以']='维以不永伤:BAAALgAECgQJBAAAAA==.',
['羅密']='羅密欧猪过夜:BAAALgADCgQJBAAAAA==.',
['翎丨']='翎丨羽:BAAALgAECgYJCAAAAA==.',
['翩然']='翩然一刻:BAAALgAECgYJBwAAAA==.',
['老疙']='老疙瘩:BAAALgAECgMJAwABLgAFFAIJBQATABEZAA==.',
['考终']='考终命:BAAALgADCggJCQAAAA==.',
['自闭']='自闭:BAAALgAECgMJAwAAAA==.',
['臭屁']='臭屁大王:BAACLgAFFH8GAAIJAAMJ8w86KgDyAAAJAAMJ8w86KgDyAAAuAAQKfxQAAx0ACAn6HdICANgBAAkACAn6HBgtAIQCAB0ABwkXG9ICANgBAAAA.臭屁队长:BAAALgAFFAIJAgAAAA==.',
['花妍']='花妍巧雨:BAAALgAECgQJAQABLgAFFAEJAQABAAAAAA==.',
['花槿']='花槿夜:BAAALgAECgkJCQAAAA==.',
['苏利']='苏利亚:BAAALgAECgEJAgAAAA==.',
['苏我']='苏我美雪:BAAALgAECgcJEAAAAA==.',
['苗子']='苗子僧:BAAALgAECgEJAQAAAA==.苗子骑:BAAALgAECgEJAQAAAA==.',
['莫德']='莫德里奇:BAAALgADCgUJBQAAAA==.',
['莫道']='莫道桑榆晚:BAAALgAFFAQJAgAAAA==.',
['萌萌']='萌萌哒深深酱:BAAALgAFFAEJAQAAAA==.',
['萤扰']='萤扰:BAAALgAFFAIJAwAAAA==.',
['萧萧']='萧萧黑风:BAABLgAECn8VAAIFAAkJXwIqQwB+AAAFAAkJXwIqQwB+AAAAAA==.',
['萨安']='萨安得萨:BAAALgAECgYJBgAAAA==.',
['蒜鸟']='蒜鸟:BAAALgAECgUJBQAAAA==.',
['蓝梅']='蓝梅尔:BAAALgAFFAEJAQAAAA==.',
['虎痴']='虎痴丶:BAAALgADCgEJAQAAAA==.',
['血色']='血色晶月:BAAALgAECgQJBQAAAA==.',
['血蹄']='血蹄圣德:BAAALgAECgQJBgAAAA==.',
['赛璃']='赛璃:BAAALgAECgEJAQAAAA==.',
['起床']='起床不叠被子:BAAALgAECgcJEAAAAA==.',
['超科']='超科学电磁炮:BAAALgADCgUJBQAAAA==.',
['跟着']='跟着我有肉吃:BAAALgAECgcJBwAAAA==.',
['蹑影']='蹑影追风:BAAALgADCgIJAgAAAA==.',
['边子']='边子:BAABLgAECn8ZAAMeAAgJihYuJQCtAQAeAAcJNxQuJQCtAQAfAAcJ4A8QNAAlAQAAAA==.',
['迈克']='迈克儿肖:BAAALgAECgEJAgAAAA==.',
['这条']='这条街最靓娃:BAAALgAECgcJEAAAAA==.',
['远程']='远程快停手:BAABLgAFFH8FAAIJAAMJYxBOFQCyAAAJAAMJYxBOFQCyAAAAAA==.',
['逐水']='逐水迎风:BAAALgAFFAIJAgAAAA==.',
['邪恶']='邪恶如我:BAAALgAECgUJBQAAAA==.',
['邪神']='邪神之殇:BAAALgAECgYJBwAAAA==.',
['邪能']='邪能灬弥漫:BAAALgAECgIJAgAAAA==.',
['酒杯']='酒杯:BAAALgAECgEJAQAAAA==.',
['释放']='释放灵魂:BAABLgAECn8iAAMJAAgJmBkWNABmAgAJAAgJmBkWNABmAgAgAAIJOwo4EwBfAAABLgAFFAUJCwAPAC4eAA==.',
['野猪']='野猪收割者:BAAALgADCgMJAwAAAA==.',
['钉崎']='钉崎野蔷薇:BAAALgAECgUJBQAAAA==.',
['钢镚']='钢镚:BAAALgAECgMJAwAAAA==.',
['铁掌']='铁掌:BAABLgAFFH8IAAIKAAIJQyXrCADVAAAKAAIJQyXrCADVAAAAAA==.',
['银翼']='银翼:BAAALgAECgMJBAAAAA==.',
['闪电']='闪电之舞:BAABLgAFFH8HAAMeAAMJCx/fBQAiAQAeAAMJCx/fBQAiAQAKAAIJPRtPCgC0AAAAAA==.',
['阿凡']='阿凡达的化身:BAAALgAECgQJBAAAAA==.',
['阿小']='阿小傻:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔肥諾:BAAALgADCgcJDgABLgAFFAUJCwAPAC4eAA==.',
['阿钢']='阿钢乄:BAABLgAFFH8FAAIJAAQJGhibDgBoAQAJAAQJGhibDgBoAQAAAA==.',
['陌生']='陌生灬老朋友:BAAALgAFFAIJBAAAAA==.',
['陶杰']='陶杰你妹:BAAALgADCgcJDQAAAA==.',
['随性']='随性:BAAALgAECgYJEgAAAA==.',
['随風']='随風最强:BAAALgAECgUJBwAAAA==.随風落叶无情:BAAALgAECgYJEwAAAA==.',
['雪花']='雪花女神龙:BAAALgAECggJAwAAAA==.',
['零脂']='零脂脆啵啵:BAAALgAECggJDwAAAA==.',
['霸霸']='霸霸丶:BAAALgAECgcJDwAAAA==.',
['鞭鞭']='鞭鞭有力:BAAALgADCgUJBQAAAA==.',
['風行']='風行:BAABLgAFFH8GAAIUAAIJshe5FACxAAAUAAIJshe5FACxAAAAAA==.',
['飞天']='飞天德:BAAALgAECgIJAgAAAA==.',
['飞奔']='飞奔的大骑士:BAAALgAECgMJAwAAAA==.',
['高松']='高松灯:BAAALgAECgMJBQAAAA==.',
['鬼泣']='鬼泣丶:BAAALgADCgEJAQAAAA==.',
['魁峰']='魁峰风暴烈酒:BAACLgAFFH8LAAIKAAQJZw0RDgAUAQAKAAQJZw0RDgAUAQAuAAQKfygAAwoABwkkHEUcACACAAoABwkkHEUcACACAB8AAQkBAdB3ABEAAAAA.',
['魂之']='魂之丨挽歌:BAAALgAECgEJAQAAAA==.',
['魑魅']='魑魅颺颺:BAAALgAECgcJCwAAAA==.',
['鲨鱼']='鲨鱼饵:BAABLgAFFH8HAAIhAAIJGRUrAQC2AAAhAAIJGRUrAQC2AAAAAA==.',
['黑池']='黑池:BAAALgAECgcJEQAAAA==.',
['黑白']='黑白丶:BAAALgAECgYJBgAAAA==.黑白沭:BAAALgAECgcJDQAAAA==.',
['黯疫']='黯疫:BAAALgAECgYJCwAAAA==.',
['龙傲']='龙傲雪:BAAALgAECgEJAQAAAA==.',
['龙十']='龙十三:BAAALgADCgEJAQAAAA==.',
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
