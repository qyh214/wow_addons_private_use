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

local lookup = {'DeathKnight-Unholy','Unknown-Unknown','Paladin-Retribution','Mage-Frost','DemonHunter-Havoc','Priest-Discipline','Priest-Holy','Evoker-Preservation','Warlock-Demonology','Warlock-Affliction','Rogue-Subtlety','Druid-Balance','Paladin-Holy','Shaman-Restoration','Warrior-Arms','Warrior-Fury','Hunter-BeastMastery','Warlock-Destruction','Warrior-Protection','Druid-Guardian','Hunter-Marksmanship','DemonHunter-Devourer','DemonHunter-Vengeance','Shaman-Elemental','Druid-Restoration','DeathKnight-Frost','Evoker-Augmentation',}
local provider = {region='CN',realm='卡德加',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Ailuropoda:BAAALgAECgEJAQAAAA==.',
Al='Allsilent:BAAALgADCgEJAQAAAA==.',
Ar='Artanis:BAAALgAECgEJAQAAAA==.',
Bo='Boomka:BAAALgAECgUJBwAAAA==.',
Ca='Catherine:BAAALgAECgUJBQAAAA==.Cathy:BAAALgAECgMJAwAAAA==.',
Ci='Cielfroth:BAAALgAECgEJAQAAAA==.',
Ck='Cklove:BAABLgAECn8hAAIBAAgJ3BTDFABsAQABAAgJ3BTDFABsAQAAAA==.',
Cr='Crazystart:BAAALgAECgUJBQAAAA==.',
Da='Darker:BAAALgAECgYJBwAAAA==.',
Dd='Ddad:BAAALgAECgEJAgAAAA==.',
De='Defendhh:BAAALgAECgQJAwAAAA==.',
Fa='Faker:BAAALgAECgYJBgAAAA==.',
Gk='Gkurfvrst:BAACLgAFFH8SAAIBAAQJ7CZUAwDQAQABAAQJ7CZUAwDQAQAuAAQKfxgAAgEACQkUIzkGAHMDAAEACQkUIzkGAHMDAAAA.',
Ha='Hathaway:BAAALgAECgYJEAABLgAFFAIJAwACAAAAAA==.',
Hy='Hydra:BAAALgADCgUJBQAAAA==.',
Im='Imaginary:BAAALgAECgYJBgAAAA==.Imfool:BAACLgAFFH8IAAIDAAMJKBxJEQAbAQADAAMJKBxJEQAbAQAuAAQKfxcAAgMABwkiIVIrAHYCAAMABwkiIVIrAHYCAAAA.',
Ji='Jinkazama:BAAALgAECgcJEQAAAA==.',
Jo='Jolin:BAAALgAECgEJAQAAAA==.',
Ju='Junetwo:BAAALgAECgEJAQAAAA==.',
Ka='Kanan:BAAALgAECgQJBgAAAA==.',
Ki='Kitice:BAAALgAFFAEJAgAAAA==.',
Le='Lei:BAAALgADCgEJAQAAAA==.',
Ma='Magiceyes:BAAALgAECgIJBAAAAA==.Magicloveu:BAACLgAFFH8NAAIEAAQJbhULGwBfAQAEAAQJbhULGwBfAQAuAAQKfyEAAgQACAnjIC4cAAUDAAQACAnjIC4cAAUDAAAA.Marszhang:BAAALgAECgQJBAAAAA==.',
On='Onceyer:BAAALgAECgcJBwAAAA==.',
Pa='Patriarch:BAAALgAECgYJDwAAAA==.',
Pl='Plance:BAAALgAFFAQJBAABLgAFFAEJAQACAAAAAA==.',
Rd='Rdhyi:BAABLgAFFH8JAAIFAAUJsiBBAACTAQAFAAUJsiBBAACTAQAAAA==.',
Re='Revenant:BAAALgAECgMJAwAAAA==.',
Sa='Sabrina:BAAALgADCgkJCQAAAA==.',
Si='Simple:BAAALgAECgYJBgAAAA==.Sindorin:BAAALgAECgEJAgAAAA==.',
So='Sothoth:BAACLgAFFH8FAAMGAAMJYQsZDwDdAAAGAAMJWAoZDwDdAAAHAAIJHgTmDwB+AAAuAAQKfxQAAwYABwmWF8QeAJ4BAAYABwkFEMQeAJ4BAAcABgm0FKYyAHUBAAAA.',
Su='Summery:BAAALgADCgUJBQAAAA==.',
Vi='Viego:BAAALgAFFAIJAwAAAA==.',
Wa='Wakeoverlord:BAAALgAFFAQJAQAAAA==.Wakeoverlxrd:BAAALgAECgYJBgAAAA==.',
Xu='Xuesely:BAAALgADCgQJBAAAAA==.',
Yi='Yimeko:BAAALgAECgIJAgAAAA==.',
Yx='Yxl:BAAALgAECgMJBAAAAA==.',
Zd='Zdhfdk:BAAALgAFFAEJAgAAAA==.',
['一二']='一二三毛:BAAALgAECgYJCgAAAA==.',
['一会']='一会儿让你哭:BAAALgAECgYJCgAAAA==.',
['一剑']='一剑终情:BAAALgAECgQJBwAAAA==.',
['一念']='一念花开:BAAALgAECgUJBgAAAA==.',
['万般']='万般自在:BAAALgADCgMJAwAAAA==.',
['下一']='下一碗热干面:BAAALgADCgMJAwAAAA==.',
['不准']='不准跪:BAAALgAECggJCAAAAA==.',
['丨喵']='丨喵嗷呜丨:BAABLgAFFH8FAAIIAAUJfRYpBAC8AQAIAAUJfRYpBAC8AQAAAA==.',
['丨天']='丨天策上将丨:BAAALgADCgEJAQAAAA==.',
['丨蓝']='丨蓝朋友丨:BAAALgAECggJEQAAAA==.',
['中二']='中二病怪我咯:BAAALgAECgYJEAAAAA==.中二终不贰丶:BAAALgAFFAMJAwAAAA==.',
['丰川']='丰川祥子:BAAALgADCgMJAwABLgAECgYJDwACAAAAAA==.',
['丶栀']='丶栀子绿茶:BAAALgAECgIJAgAAAA==.',
['丶薄']='丶薄荷奶绿:BAAALgAECgcJDQAAAA==.',
['丶虚']='丶虚拟:BAAALgAECgUJBgAAAA==.',
['丶风']='丶风度:BAABLgAFFH8FAAMJAAMJsCAaKwDEAAAJAAIJBSIaKwDEAAAKAAEJBx4AAAAAAAAAAA==.',
['丿壹']='丿壹瓶丨盖:BAAALgAECgYJCAAAAA==.',
['丿未']='丿未知目标:BAAALgAECgYJBgAAAA==.',
['么么']='么么菈哚:BAABLgAECn8bAAIHAAcJgxHnNQBlAQAHAAcJgxHnNQBlAQAAAA==.',
['乘风']='乘风猎命:BAAALgADCgQJBAAAAA==.',
['九漏']='九漏魚:BAAALgAFFAEJAQAAAA==.',
['九葵']='九葵丷:BAAALgADCgYJCAAAAA==.九葵妹妹:BAAALgADCgIJAgAAAA==.九葵晓夜:BAAALgADCgIJAgAAAA==.',
['二小']='二小饼:BAAALgAECgEJAQAAAA==.',
['互联']='互联网混子:BAABLgAFFH8JAAILAAMJhgCiEADFAAALAAMJhgCiEADFAAAAAA==.',
['亚芙']='亚芙奈德:BAAALgAECgYJDAAAAA==.',
['京城']='京城灬小妖:BAAALgAECgEJAgAAAA==.',
['从前']='从前有个山:BAAALgAFFAIJAgAAAA==.',
['令狐']='令狐璇:BAAALgAECgQJBQAAAA==.',
['伊莉']='伊莉雅斯菲尔:BAACLgAFFH8KAAIHAAUJnhrcAACVAQAHAAUJnhrcAACVAQAuAAQKfxgAAgcABwkeGMwjAMgBAAcABwkeGMwjAMgBAAAA.',
['优雅']='优雅的卷心菜:BAAALgADCgUJBQAAAA==.',
['假装']='假装丶男爵:BAAALgADCgQJBAAAAA==.',
['八重']='八重樱:BAAALgAECgEJAQAAAA==.',
['冠军']='冠军侯霍去病:BAAALgADCgEJAQAAAA==.',
['凌夜']='凌夜:BAAALgAECgUJCQAAAA==.',
['凯恩']='凯恩碎石:BAAALgAECgcJBwABLgAFFAYJFQAMAHIhAA==.',
['列队']='列队飞行:BAAALgAECgcJEgABLgAFFAMJCAANAOEYAA==.',
['初舞']='初舞凌雪:BAAALgAECgEJAQAAAA==.',
['初长']='初长枫:BAAALgADCgYJBgAAAA==.',
['副本']='副本训练假人:BAAALgAECgYJBwAAAA==.',
['功能']='功能输出:BAAALgADCgIJAgAAAA==.',
['加不']='加不了一点:BAAALgAECgYJBgAAAA==.',
['加血']='加血加到吐:BAAALgAECgUJCAAAAA==.',
['劫数']='劫数来临:BAAALgAECgIJAgAAAA==.',
['北冰']='北冰洋棍棍儿:BAAALgADCgYJBgAAAA==.',
['北极']='北极熊猫:BAAALgAECgQJBAAAAA==.',
['十六']='十六夜月读:BAAALgADCgQJBAAAAA==.',
['卡尔']='卡尔芬肯:BAAALgAECgMJAwAAAA==.',
['卫星']='卫星区扛把子:BAAALgADCgYJBgAAAA==.',
['卷物']='卷物:BAABLgAFFH8GAAIJAAMJkwTnEwDEAAAJAAMJkwTnEwDEAAAAAA==.',
['原末']='原末魔初:BAAALgAECgEJAgAAAA==.',
['双刀']='双刀剁排骨:BAAALgAECgYJBgAAAA==.',
['取我']='取我温酒来:BAAALgAECgUJBQAAAA==.',
['叫我']='叫我楼子哥:BAAALgAECgEJAQAAAA==.',
['可乐']='可乐椒麻鸡:BAAALgAECgYJDAAAAA==.',
['叶月']='叶月青灯:BAAALgAECggJCAAAAA==.',
['吃垚']='吃垚卖萌咪:BAAALgAFFAEJAQAAAA==.',
['名門']='名門之戰:BAABLgAFFH8GAAIDAAMJcQxKCgD3AAADAAMJcQxKCgD3AAAAAA==.',
['吾亦']='吾亦可往:BAAALgAECgcJDAAAAA==.',
['吾吾']='吾吾轩轩:BAABLgAFFH8GAAIOAAMJoBMNBwDkAAAOAAMJoBMNBwDkAAAAAA==.',
['呆呆']='呆呆酱:BAAALgAECgYJBwAAAA==.',
['呵尔']='呵尔:BAABLgAFFH8MAAMPAAQJhiK6AgA3AQAPAAMJeiK6AgA3AQAQAAMJyCAcDwAUAQAAAA==.',
['命运']='命运使者:BAAALgAECgYJCwAAAA==.',
['和光']='和光同尘:BAAALgADCgEJAQAAAA==.',
['和尚']='和尚不吃肉:BAAALgAECgQJBAAAAA==.',
['咪神']='咪神:BAAALgAECgYJBgAAAA==.',
['哈基']='哈基米哈基:BAAALgAFFAQJBAAAAA==.',
['哑哑']='哑哑:BAAALgAECgEJAQAAAA==.',
['喀秋']='喀秋莎火箭炮:BAAALgAECgkJBwAAAA==.',
['喵丶']='喵丶星人:BAAALgAECgIJAQAAAA==.',
['喵菲']='喵菲斯特:BAAALgAECgYJCgAAAA==.',
['嚣张']='嚣张超:BAAALgADCgEJAQAAAA==.',
['四十']='四十多个女生:BAABLgAECn8eAAIRAAcJyxrKJgAfAgARAAcJyxrKJgAfAgAAAA==.',
['回归']='回归信仰:BAAALgAECgcJBwAAAA==.',
['回返']='回返雪月花:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光开背:BAAALgAECgEJAQAAAA==.圣光遮蔽双眼:BAAALgAECgcJBwAAAA==.',
['地狱']='地狱之天使:BAAALgAECgUJBQAAAA==.地狱火灬:BAAALgAFFAIJAgAAAA==.地狱灬使者:BAAALgAECgcJEwAAAA==.地狱灬走来:BAAALgAECgQJBAAAAA==.地狱里的咆哮:BAAALgADCgEJAQAAAA==.',
['坏蛋']='坏蛋弘弘瑾:BAAALgADCgMJAwAAAA==.',
['夜之']='夜之殇:BAAALgADCgQJBAAAAA==.',
['夜了']='夜了个夜:BAAALgAECgEJAQAAAA==.',
['夜影']='夜影之光:BAAALgAECgIJAgAAAA==.夜影之殇:BAABLgAECn8aAAMSAAgJzhISJgAuAQAJAAcJOxG1cgB5AQASAAUJfA8SJgAuAQAAAA==.',
['夜游']='夜游宫:BAAALgAECgEJAQAAAA==.',
['夜色']='夜色杀手:BAAALgAECgIJAwAAAA==.',
['大反']='大反派小清新:BAAALgADCgEJAQAAAA==.',
['大快']='大快乐丶:BAAALgAECgYJBgAAAA==.',
['大眼']='大眼萌嘟宝:BAAALgAECgQJBAAAAA==.',
['大神']='大神的小笨笨:BAAALgADCgYJDQAAAA==.',
['大豆']='大豆高粱:BAAALgADCgMJAwAAAA==.',
['大魔']='大魔导士:BAAALgAECgcJAgAAAA==.',
['天娜']='天娜:BAAALgAECgMJAwAAAA==.',
['天神']='天神下凡:BAABLgAFFH8LAAITAAQJcgnGBgD6AAATAAQJcgnGBgD6AAAAAA==.',
['头发']='头发乱了灬:BAAALgAECgQJBQAAAA==.',
['奈丶']='奈丶落:BAAALgAECgkJBQAAAA==.',
['奔流']='奔流:BAAALgAECgkJCQAAAA==.',
['奥妮']='奥妮:BAAALgAECgYJBwAAAA==.奥妮奥妮:BAAALgADCgEJAgAAAA==.',
['奶小']='奶小骑:BAAALgAECgkJDwAAAA==.',
['奶飞']='奶飞天啊:BAAALgAECgYJCAAAAA==.',
['妖姬']='妖姬:BAAALgAECgEJAQAAAA==.',
['姑姑']='姑姑过儿想你:BAAALgADCgEJAQAAAA==.',
['姑射']='姑射踏雪:BAABLgAFFH8GAAILAAMJcweDBgD8AAALAAMJcweDBgD8AAAAAA==.',
['娃丿']='娃丿娃:BAAALgAECgYJBgAAAA==.',
['富察']='富察明瑞:BAAALgAECgEJAQAAAA==.',
['寒绫']='寒绫:BAABLgAFFH8GAAIGAAMJZiGBBQAQAQAGAAMJZiGBBQAQAQAAAA==.',
['寻找']='寻找火星的你:BAAALgAFFAIJBAABLgAFFAcJDwAEANUjAA==.',
['封宜']='封宜奴:BAAALgADCgcJBwAAAA==.',
['小三']='小三丶:BAAALgAECgYJCAAAAA==.',
['小夏']='小夏微凉:BAAALgADCgEJAQAAAA==.',
['小宝']='小宝德德:BAABLgAFFH8NAAIUAAQJkgqAAgDyAAAUAAQJkgqAAgDyAAAAAA==.小宝的洋娃娃:BAAALgAECgEJAQAAAA==.',
['小爆']='小爆牙:BAAALgAECgQJCAAAAA==.',
['小珊']='小珊:BAACLgAFFH8IAAIEAAQJxhbhLAADAQAEAAQJxhbhLAADAQAuAAQKfxwAAgQACAkmIlAaAA4DAAQACAkmIlAaAA4DAAAA.',
['小鞭']='小鞭炮:BAAALgAFFAEJAQAAAA==.',
['小饼']='小饼干一号:BAAALgAFFAMJAwAAAA==.小饼干二号:BAABLgAFFH8FAAIPAAQJmg9EAgBUAQAPAAQJmg9EAgBUAQAAAA==.',
['尛火']='尛火锅:BAAALgAFFAEJAQAAAA==.',
['左鞋']='左鞋右穿:BAAALgAECgEJAQAAAA==.',
['巨石']='巨石丶雷:BAAALgAECgYJCAAAAA==.',
['布拉']='布拉奇多斯:BAAALgAECgQJCAAAAA==.',
['带浪']='带浪的大呲花:BAAALgAECgEJAgAAAA==.',
['幻羽']='幻羽倾心:BAAALgAECgcJDQAAAA==.',
['幽默']='幽默小黄人:BAAALgAECgQJBgAAAA==.',
['张望']='张望月亮:BAAALgADCgEJAQAAAA==.张望熊猫:BAAALgADCgMJAwAAAA==.',
['张筱']='张筱凡:BAAALgAECgIJAgAAAA==.',
['彩绘']='彩绘阑珊:BAAALgADCgUJBQAAAA==.',
['彩鳞']='彩鳞:BAAALgADCgEJAQAAAA==.',
['影舞']='影舞:BAAALgAECgIJAQAAAA==.',
['徐铁']='徐铁锤:BAAALgAECgYJCAAAAA==.',
['得鹿']='得鹿梦鱼:BAAALgAFFAEJAQAAAA==.',
['德菜']='德菜兼备:BAAALgAFFAEJAQAAAA==.',
['怀念']='怀念你的脸:BAAALgAFFAEJAQAAAA==.',
['思念']='思念如盗丶:BAAALgAECgcJBwAAAA==.',
['急速']='急速萌萌德:BAAALgAECgcJCAABLgAFFAUJBAACAAAAAA==.',
['性感']='性感男高:BAAALgADCgEJAQAAAA==.',
['恶霊']='恶霊丶挽歌:BAAALgAECgUJCgAAAA==.',
['恶魔']='恶魔妖姬:BAAALgADCgQJBAAAAA==.',
['情月']='情月:BAAALgAECgEJAQAAAA==.',
['惠灵']='惠灵顿牛排:BAAALgADCgMJAwAAAA==.',
['意斩']='意斩相思:BAAALgADCgEJAQAAAA==.',
['戎雀']='戎雀:BAAALgAFFAIJAgAAAA==.',
['我是']='我是大鲶鱼:BAAALgAECgMJAwAAAA==.',
['我真']='我真的很欧丶:BAAALgADCgcJCQABLgAFFAYJBQAVACQLAA==.',
['戒灵']='戒灵朱庇特:BAAALgAFFAEJAQAAAA==.',
['房山']='房山季鸟猴:BAAALgAFFAEJAQAAAA==.',
['手撕']='手撕鱿鱼:BAABLgAECn8VAAQWAAYJTx+YQQDuAQAWAAYJtBuYQQDuAQAFAAYJFR3mIwCeAQAXAAEJQBQxKgA6AAABLgAFFAYJFQAYACgVAA==.',
['执剑']='执剑傲天:BAAALgAECgYJBgAAAA==.',
['扶摇']='扶摇丶:BAAALgAECgEJAgAAAA==.',
['抛开']='抛开事实不谈:BAAALgAFFAEJAQAAAA==.',
['拉她']='拉她丶左右手:BAAALgAECgkJCQAAAA==.',
['拉胯']='拉胯水骑:BAAALgAECgIJAgAAAA==.',
['拯救']='拯救圣光:BAAALgAECgYJCwAAAA==.',
['放飞']='放飞吧希望:BAAALgAECgYJCAAAAA==.',
['文清']='文清:BAAALgAECgEJAgAAAA==.',
['无法']='无法停止的雨:BAAALgAECgYJAwAAAA==.',
['星丨']='星丨丨晴:BAAALgAECgMJAwAAAA==.星丨晴:BAAALgAECgMJAwAAAA==.',
['星光']='星光永恒:BAAALgADCgEJAQAAAA==.',
['星座']='星座灬乌龟:BAAALgAECgEJAQAAAA==.',
['暗舞']='暗舞:BAAALgAFFAEJAQAAAA==.',
['最後']='最後丶舊時光:BAAALgAECgYJDAAAAA==.最後丶龙魂:BAAALgAECgUJBQAAAA==.',
['月鵺']='月鵺兔:BAACLgAFFH8FAAIZAAIJthTEFwCjAAAZAAIJthTEFwCjAAAuAAQKfx4ABBkABwnUIykQALcCABkABwnUIykQALcCABQABQl3Eb4GANMAAAwAAgm6B0R1AE4AAAAA.',
['望江']='望江舟:BAAALgAECgUJBQAAAA==.',
['木碗']='木碗六:BAAALgAECgEJAQAAAA==.',
['朮師']='朮師:BAABLgAECn8VAAMJAAcJzxaVQwABAgAJAAcJtBaVQwABAgASAAMJzxTyPADAAAAAAA==.',
['术业']='术业专工:BAAALgAECgEJAQAAAA==.',
['李司']='李司怡:BAAALgAECgEJAQAAAA==.',
['村炮']='村炮射小鸟:BAAALgADCgEJAQAAAA==.',
['析木']='析木:BAAALgAFFAEJAQAAAA==.',
['枫秋']='枫秋半夏:BAAALgAFFAIJAwAAAA==.',
['梁慕']='梁慕橙:BAAALgAECgEJAQAAAA==.',
['梁渠']='梁渠的夏天:BAAALgAECgMJAwAAAA==.',
['梦晓']='梦晓溪:BAAALgAECgEJAQAAAA==.',
['橙味']='橙味美年达:BAAALgAECgcJCwAAAA==.',
['欧丶']='欧丶皇:BAAALgAFFAEJAQAAAA==.',
['死了']='死了也得射:BAAALgADCgYJBgAAAA==.',
['比格']='比格沃斯丶:BAAALgAECgcJBwAAAA==.',
['毛毛']='毛毛牛分身:BAAALgAECgUJBgAAAA==.',
['永恒']='永恒灬承诺:BAAALgAECgQJBwAAAA==.',
['池鱼']='池鱼归故渊:BAAALgAECgMJAwAAAA==.',
['污喵']='污喵王的马甲:BAAALgADCgEJAQAAAA==.',
['沧笙']='沧笙扬歌:BAAALgAECgEJAQAAAA==.',
['河道']='河道小术师:BAAALgAECgYJBwAAAA==.河道小骑士:BAAALgAECgcJCQAAAA==.',
['泊松']='泊松亮斑:BAAALgAECgQJCAAAAA==.',
['洅钚']='洅钚輚:BAAALgAECgEJAQAAAA==.',
['浮夸']='浮夸:BAAALgAECgEJAQAAAA==.',
['液态']='液态镁:BAACLgAFFH8RAAIEAAYJrSI0AgBvAgAEAAYJrSI0AgBvAgAuAAQKfxoAAgQACAkSJUASADoDAAQACAkSJUASADoDAAAA.',
['淡淡']='淡淡黄昏:BAABLgAFFH8GAAIRAAMJ0A21CAD9AAARAAMJ0A21CAD9AAAAAA==.',
['清一']='清一色:BAAALgAECgYJBwAAAA==.',
['清泉']='清泉尐妖:BAAALgAECgEJAwAAAA==.',
['清风']='清风它自来:BAAALgAECgEJAQAAAA==.清风无处寻:BAAALgAECgUJBQAAAA==.清风明月我:BAABLgAFFH8FAAIOAAMJXgJ9CQCzAAAOAAMJXgJ9CQCzAAAAAA==.',
['溟灭']='溟灭:BAABLgAFFH8HAAIJAAMJ4wsnJwDgAAAJAAMJ4wsnJwDgAAAAAA==.',
['滚开']='滚开凡人:BAAALgAECgUJBwAAAA==.',
['火鸡']='火鸡味糍粑:BAAALgAECgcJCAAAAA==.',
['灬沉']='灬沉迷灬:BAAALgAECgEJAQAAAA==.',
['灬聖']='灬聖十三:BAABLgAFFH8JAAIOAAUJPQ36AQCDAQAOAAUJPQ36AQCDAQABLgAFFAYJFgAYAMUZAA==.灬聖十二:BAABLgAFFH8HAAIOAAQJfQ+yCgAsAQAOAAQJfQ+yCgAsAQABLgAFFAYJFgAYAMUZAA==.灬聖十五:BAABLgAFFH8IAAIOAAQJERChAwBBAQAOAAQJERChAwBBAQABLgAFFAYJFgAYAMUZAA==.灬聖十六:BAAALgAECggJBwABLgAFFAYJFgAYAMUZAA==.灬聖十四:BAABLgAFFH8FAAIOAAQJqg5HJgA9AAAOAAQJqg5HJgA9AAAAAA==.',
['灬薄']='灬薄情:BAABLgAFFH8NAAMBAAQJdx1mCQCGAQABAAQJdx1mCQCGAQAaAAIJ4g0AAAAAAAAAAA==.',
['灬霓']='灬霓裳魅影灬:BAABLgAFFH8JAAIDAAMJvxoLEwANAQADAAMJvxoLEwANAQAAAA==.',
['炭烤']='炭烤鸡翅:BAAALgAECgcJCgAAAA==.',
['烟波']='烟波媚行:BAAALgAECgYJBgAAAA==.',
['烦人']='烦人精:BAAALgADCgEJAQAAAA==.',
['爱睡']='爱睡觉的猫:BAAALgAECgIJAgAAAA==.',
['牛奶']='牛奶冒泡泡灬:BAAALgAECgQJBAAAAA==.',
['牛拔']='牛拔山举鼎:BAAALgAECgYJBgAAAA==.',
['牛魔']='牛魔隋:BAAALgAECgEJAQAAAA==.牛魔鬼王:BAAALgAECggJBwABLgAECgkJFwATAMAcAA==.',
['牧芸']='牧芸:BAABLgAFFH8FAAMSAAUJvB3BAgB+AQASAAQJjR/BAgB+AQAJAAEJdxYGSwBQAAAAAA==.',
['猫一']='猫一:BAAALgADCgEJAQAAAA==.',
['猫系']='猫系女友:BAAALgAECgMJBgAAAA==.',
['玄骨']='玄骨:BAAALgAECgcJCQAAAA==.',
['王牌']='王牌猎户:BAAALgAECgQJBAAAAA==.',
['王隽']='王隽骑:BAABLgAFFH8FAAIDAAQJtgccEgAUAQADAAQJtgccEgAUAQAAAA==.',
['玛卡']='玛卡洛夫:BAAALgADCgQJBAAAAA==.',
['玛昕']='玛昕:BAAALgAECgcJCgAAAA==.',
['玩个']='玩个恶魔:BAAALgAECgEJAQAAAA==.',
['琉璃']='琉璃喵:BAAALgAECgIJAgAAAA==.琉璃心:BAAALgAECgUJCAAAAA==.',
['琼楼']='琼楼月:BAAALgAECgQJBAAAAA==.',
['瑟蘭']='瑟蘭迪爾:BAAALgAECgkJDAAAAA==.',
['璐灬']='璐灬崽:BAAALgAECgYJDwAAAA==.',
['甜不']='甜不辣哒丸子:BAAALgADCgYJBgAAAA==.',
['白米']='白米饭:BAAALgAFFAQJBAABLgAFFAUJAgACAAAAAA==.',
['白羽']='白羽灬丨痕丨:BAAALgADCgYJBgABLgAFFAQJBwAOAIcHAA==.',
['白色']='白色考考:BAAALgADCgEJAQAAAA==.',
['白莲']='白莲丶素还真:BAAALgADCgcJBwAAAA==.',
['白貓']='白貓:BAABLgAFFH8FAAIHAAIJfhX7CwCjAAAHAAIJfhX7CwCjAAAAAA==.',
['百千']='百千家美滋滋:BAAALgAECgUJCwAAAA==.',
['神宿']='神宿温泉:BAAALgAECgMJAwAAAA==.',
['神帝']='神帝拓拔野:BAAALgADCgMJAwAAAA==.',
['秋悲']='秋悲:BAAALgAECgMJAwAAAA==.',
['科比']='科比丶:BAAALgAECgIJAgAAAA==.',
['秦国']='秦国白起:BAAALgADCgEJAQAAAA==.',
['穿不']='穿不下小裤衩:BAAALgAFFAEJAQAAAA==.',
['等等']='等等你:BAAALgADCgEJAQAAAA==.',
['简直']='简直丧心病狂:BAAALgAFFAQJBAAAAA==.',
['精灵']='精灵灬恶魔:BAAALgAECgEJAQAAAA==.',
['紫炎']='紫炎圣骑:BAABLgAFFH8GAAIDAAMJexN4FQD/AAADAAMJexN4FQD/AAAAAA==.',
['紫鸳']='紫鸳梦鸾:BAAALgAECgcJDAAAAA==.',
['绯流']='绯流琥:BAAALgAECgkJDwAAAA==.',
['绿玩']='绿玩龙一:BAAALgAFFAYJAwAAAA==.绿玩龙三:BAAALgAFFAYJAgAAAA==.绿玩龙五:BAABLgAFFH8HAAIbAAcJrBcrAAA2AgAbAAcJrBcrAAA2AgAAAA==.绿玩龙八:BAAALgAFFAUJBAABLgAFFAcJBQAbAP4MAA==.绿玩龙六:BAABLgAFFH8NAAIbAAcJABkuAAAzAgAbAAcJABkuAAAzAgAAAA==.绿玩龙十一:BAAALgAECgIJAgABLgAFFAQJAwACAAAAAA==.',
['耀麾']='耀麾:BAAALgAECgQJBAAAAA==.',
['老婆']='老婆当家:BAAALgAECgIJAgAAAA==.',
['老肝']='老肝爹丶:BAAALgAECgYJDgAAAA==.',
['老腿']='老腿哥丶:BAAALgAECgEJAgAAAA==.',
['肉肉']='肉肉龙:BAAALgAECgkJCwAAAA==.',
['背叛']='背叛者丶戰殺:BAAALgADCgQJAQAAAA==.',
['背后']='背后捅人刀:BAAALgAECgMJAwAAAA==.',
['背时']='背时鬼:BAAALgAECgYJEAAAAA==.',
['自寻']='自寻死路丨:BAACLgAFFH8QAAMWAAQJ/B8rBABkAQAWAAQJ/B8rBABkAQAXAAIJTQygAwB5AAAuAAQKfysAAxYACAkpJfcaALECABYABwk0JPcaALECABcACAnJH3MHAA8CAAAA.',
['舞娘']='舞娘酱:BAAALgAECgkJCwAAAA==.',
['芃然']='芃然欣动:BAAALgAECgMJAwAAAA==.',
['芭妮']='芭妮萌豆沙乐:BAAALgAFFAIJBAAAAA==.',
['花开']='花开灬浅夏:BAAALgAECgIJAgAAAA==.',
['花形']='花形透:BAAALgAECgEJAQABLgAFFAMJCwALAOkgAA==.',
['花老']='花老板灬丿:BAAALgAECgEJAQAAAA==.',
['花花']='花花思密达:BAAALgADCgMJAwAAAA==.',
['苍天']='苍天小鬼:BAAALgADCgEJAQAAAA==.苍天紫木:BAAALgADCgEJAQAAAA==.苍天缚魂:BAAALgAECgUJBQAAAA==.',
['茶冷']='茶冷色淡:BAAALgAECgYJBwAAAA==.',
['茶饮']='茶饮三道:BAAALgAFFAQJBAABLgAFFAcJGQAYAJEdAA==.',
['荒芜']='荒芜之灾:BAAALgAECgEJAgAAAA==.',
['荼蘼']='荼蘼睡不醒:BAAALgADCgQJBAAAAA==.荼蘼若茶:BAAALgAECgEJAQAAAA==.荼蘼若荼:BAAALgAFFAEJAgAAAA==.',
['菲斯']='菲斯:BAAALgAFFAEJAQAAAA==.',
['葡萄']='葡萄冰柠茶:BAAALgADCgEJAQAAAA==.',
['蒙奇']='蒙奇滴路飞:BAABLgAFFH8VAAIYAAYJKBWfAQACAgAYAAYJKBWfAQACAgAAAA==.',
['蒜香']='蒜香柚子汁丶:BAAALgAECgcJBwAAAA==.',
['蓝彩']='蓝彩和:BAAALgAECgMJBAAAAA==.',
['蓝色']='蓝色德鲁依:BAAALgAECgQJCwAAAA==.',
['薄荷']='薄荷茶:BAAALgAECgYJBgAAAA==.',
['虞小']='虞小乙:BAAALgAECgQJCAAAAA==.',
['蜂蜜']='蜂蜜柚子茶:BAAALgAFFAEJAQAAAA==.',
['蜡笔']='蜡笔小葵:BAAALgAECgMJAwAAAA==.',
['蠢灬']='蠢灬萌灬骑:BAAALgAECgkJCQAAAA==.',
['血魔']='血魔狂舞:BAAALgAECgYJEAAAAA==.',
['被杀']='被杀的鸡:BAACLgAFFH8IAAIEAAMJoiO+DAAsAQAEAAMJoiO+DAAsAQAuAAQKfxkAAgQACAl1IuYsAL8CAAQACAl1IuYsAL8CAAAA.',
['西野']='西野七濑:BAACLgAFFH8LAAILAAMJ6SDXCwAmAQALAAMJ6SDXCwAmAQAuAAQKfxcAAgsACAkXHy8MANUCAAsACAkXHy8MANUCAAAA.',
['要优']='要优雅:BAAALgAECgUJBQAAAA==.',
['角落']='角落里的石头:BAAALgAECgEJAQAAAA==.',
['解脫']='解脫:BAAALgAECgIJAgAAAA==.',
['诛天']='诛天始祖剑:BAABLgAFFH8IAAINAAQJnxNVCQBAAQANAAQJnxNVCQBAAQAAAA==.',
['诲人']='诲人不惓:BAAALgAECgEJAQAAAA==.',
['诸神']='诸神黃昏:BAAALgAFFAEJAQAAAA==.',
['谓我']='谓我心忧:BAAALgAFFAEJAQAAAA==.',
['豆豆']='豆豆充电宝:BAAALgAFFAIJAgAAAA==.',
['貝阿']='貝阿朵莉切:BAAALgAECgYJCgAAAA==.',
['贝尔']='贝尔摩德:BAAALgAECgIJAgAAAA==.',
['贰柒']='贰柒贰伍:BAABLgAECn8iAAMJAAgJBxuEPQAWAgAJAAcJMRiEPQAWAgASAAMJMBHuNgDaAAAAAA==.',
['赵国']='赵国李牧:BAAALgADCgEJAQAAAA==.',
['跟着']='跟着勇哥把妹:BAAALgADCgEJAQAAAA==.',
['軍團']='軍團走狗:BAAALgAFFAIJBAAAAA==.',
['軒轅']='軒轅丶:BAAALgAECgcJCgAAAA==.',
['过去']='过去事过去心:BAAALgAECgEJAQAAAA==.',
['追风']='追风旅行者:BAAALgAECgIJAgAAAA==.',
['逆蝶']='逆蝶很美:BAAALgAECgIJAwAAAA==.',
['遇术']='遇术凛风:BAAALgAECgMJAwAAAA==.',
['遗忘']='遗忘天空:BAAALgAECgYJBAAAAA==.',
['遥望']='遥望:BAAALgAECgMJAwAAAA==.',
['遥遥']='遥遥晃晃:BAAALgAECgIJAgAAAA==.',
['银月']='银月之血杀:BAAALgAECgEJAQAAAA==.',
['长恨']='长恨似情丶:BAAALgAECggJCQAAAA==.',
['长藜']='长藜:BAAALgAECgEJAQABLgAFFAMJBQAJAJsYAA==.',
['问道']='问道:BAAALgAECgEJAQAAAA==.',
['阿拉']='阿拉纳克:BAAALgAECgQJBAAAAA==.',
['陆尹']='陆尹儿:BAACLgAFFH8IAAIWAAMJnxEXHQDrAAAWAAMJnxEXHQDrAAAuAAQKfxoAAhYACAkzF6k9AP0BABYACAkzF6k9AP0BAAAA.',
['陆屿']='陆屿森岛丶:BAAALgAFFAIJAwAAAA==.',
['雷神']='雷神天使:BAAALgAECgQJBgAAAA==.',
['雷老']='雷老虎:BAAALgAECgMJAwAAAA==.',
['霍格']='霍格大黑箭:BAABLgAFFH8MAAIRAAQJzSFuAACfAQARAAQJzSFuAACfAQAAAA==.',
['露易']='露易丝威登:BAAALgAECgYJBgAAAA==.',
['青衣']='青衣旦马:BAAALgAECgcJBwAAAA==.',
['青青']='青青的爱:BAABLgAFFH8GAAIRAAMJZAmaCQDqAAARAAMJZAmaCQDqAAAAAA==.',
['非同']='非同凡响:BAAALgAECgEJAgAAAA==.',
['颠覆']='颠覆灬凋零:BAAALgAECgEJAQAAAA==.',
['风火']='风火雷电劈:BAAALgAECgkJCQABLgAFFAUJBQAWAN8aAA==.',
['风雨']='风雨无啨:BAAALgAECgMJAwAAAA==.',
['飘零']='飘零的嘌呤:BAAALgADCgMJAwABLgAFFAYJBAACAAAAAA==.',
['飘飘']='飘飘不知:BAAALgADCgMJAwAAAA==.',
['飞天']='飞天大葫芦:BAAALgAECgcJDQAAAA==.',
['飞奔']='飞奔的花肥鹅:BAAALgAECgUJBQABLgAECgcJDQACAAAAAA==.',
['飞舞']='飞舞的花花:BAAALgADCgEJAQAAAA==.',
['首席']='首席驯兽师:BAAALgAECgEJAQAAAA==.',
['马桶']='马桶哥:BAAALgADCgEJAQAAAA==.',
['魍魉']='魍魉画魂:BAABLgAFFH8IAAIBAAQJzBeMEgBXAQABAAQJzBeMEgBXAQABLgAFFAYJFQAYACgVAA==.',
['魔之']='魔之水晶:BAAALgAECgYJDgAAAA==.',
['魔焱']='魔焱天空:BAAALgADCgcJBwAAAA==.',
['魔芋']='魔芋刀刀:BAAALgAECgUJCAAAAA==.',
['鮎川']='鮎川丸子:BAAALgAECgQJBgAAAA==.',
['鵗曦']='鵗曦:BAAALgADCgQJBAAAAA==.',
['鷆鶶']='鷆鶶:BAAALgADCgYJBgAAAA==.',
['鸭腿']='鸭腿饭丶:BAAALgADCgQJBAAAAA==.',
['鹿鸣']='鹿鸣:BAAALgAECgcJBwAAAA==.',
['黑岩']='黑岩:BAAALgAECgIJAwAAAA==.',
['黑皮']='黑皮:BAAALgADCgEJAQAAAA==.',
['黑龍']='黑龍部落灬:BAACLgAFFH8FAAMJAAMJmxiKKADUAAAJAAIJaCOKKADUAAASAAEJAgMZGgBHAAAuAAQKfxwABAkABgnyJS4jAIgCAAkABgnyJS4jAIgCABIAAwnAGxg0AOcAAAoAAQkAAFY4ABgAAAAA.',
['黯影']='黯影霜魂:BAAALgADCgIJAgAAAA==.',
['齐丹']='齐丹小青袍:BAAALgAECgEJAQAAAA==.',
['龌龊']='龌龊之奶豆:BAAALgAECgYJBgAAAA==.',
['龙之']='龙之九五:BAAALgAECgEJAQAAAA==.',
['龙猪']='龙猪丶熊白白:BAAALgAECgcJEwAAAA==.',
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
