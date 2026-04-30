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

local lookup = {'Paladin-Retribution','Warrior-Protection','Unknown-Unknown','Priest-Discipline','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Elemental','Warlock-Demonology','Druid-Balance','DeathKnight-Unholy','Paladin-Holy','Warrior-Fury','Warrior-Arms',}
local provider = {region='CN',realm='祖阿曼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Bluejj:BAAALgAECgEJAQAAAA==.',
Fq='Fqxs:BAAALgAECggJEwAAAA==.',
Mi='Mikulu:BAAALgADCgcJBwAAAA==.',
Sk='Skyzero:BAAALgAECgMJAwAAAA==.',
Wi='Wishtoday:BAAALgAECgEJAQAAAA==.',
Ww='Wwa:BAAALgAFFAQJBAAAAA==.',
Yb='Ybb:BAAALgAFFAQJBAABLgAFFAUJCAABABYTAA==.',
Za='Zaa:BAABLgAFFH8IAAICAAQJ6QcMBwD0AAACAAQJ6QcMBwD0AAABLgAFFAUJCAABABYTAA==.',
['一乐']='一乐:BAAALgAECgcJCgAAAA==.',
['一抹']='一抹晨光:BAAALgAECggJBwAAAA==.一抹月光:BAAALgAECgkJCwAAAA==.一抹阳光:BAAALgAECgkJBwAAAA==.',
['丨毛']='丨毛毛雨丨:BAAALgAECgcJBgAAAA==.',
['丨铅']='丨铅丨:BAAALgAECgYJBgAAAA==.',
['丶丶']='丶丶三:BAAALgAFFAQJBAAAAA==.',
['丶乔']='丶乔巴:BAAALgAECgYJBwAAAA==.',
['丶小']='丶小青龙丶:BAAALgAECgUJBQAAAA==.',
['丶幽']='丶幽蓝蝶:BAAALgAECgIJAwAAAA==.',
['丶红']='丶红魔:BAAALgAECgEJAgAAAA==.',
['乄蒋']='乄蒋奇明:BAAALgAECgEJAQAAAA==.',
['低调']='低调的小骑:BAAALgAECgYJCQAAAA==.',
['倏忽']='倏忽如风:BAAALgAECgYJDwAAAA==.',
['兜兜']='兜兜有寶寶:BAAALgAECgIJAgAAAA==.',
['六条']='六条龙:BAAALgADCgMJAwAAAA==.',
['六罐']='六罐恶魔:BAAALgAECgEJAQAAAA==.',
['冒冒']='冒冒酱:BAAALgAECgMJAwAAAA==.',
['冰与']='冰与火之歌:BAAALgADCgEJAQAAAA==.',
['冰火']='冰火精灵:BAAALgAECgEJAQAAAA==.',
['冷风']='冷风:BAAALgAECgYJDQAAAA==.',
['刘诗']='刘诗诗:BAAALgAECgkJCQABLgAFFAUJAQADAAAAAA==.',
['剑骸']='剑骸大剑:BAAALgADCgEJAQAAAA==.',
['厨神']='厨神唐牛:BAAALgADCgYJBgAAAA==.',
['又帅']='又帅又可爱:BAAALgAFFAEJAQAAAA==.',
['叶子']='叶子一一:BAAALgAECgcJBwAAAA==.叶子一七:BAAALgAECgYJBgAAAA==.叶子一三:BAAALgAECgcJBwAAAA==.叶子一二:BAAALgAECgcJDQAAAA==.叶子一八:BAAALgAECgcJCAAAAA==.叶子一四:BAAALgAECgcJBwAAAA==.',
['名动']='名动天下:BAAALgAECgkJCQAAAA==.',
['和绅']='和绅老婆:BAAALgAECgEJAQAAAA==.',
['咸蛋']='咸蛋:BAAALgAFFAQJBAAAAA==.',
['啻媁']='啻媁崌噉:BAAALgAECgQJBAAAAA==.',
['嘿不']='嘿不弄洞:BAAALgADCgEJAQAAAA==.',
['圣光']='圣光婴宁:BAAALgAECgIJAgAAAA==.',
['圣言']='圣言律令:BAABLgAECn8WAAIBAAkJLhttFQDpAgABAAkJLhttFQDpAgABLgAFFAQJBAADAAAAAA==.',
['地域']='地域咆哮:BAAALgAECgIJAgAAAA==.',
['天堂']='天堂紫夜:BAAALgAECgEJAQAAAA==.',
['失落']='失落的悲伤:BAAALgADCgEJAQAAAA==.',
['射你']='射你个不吱声:BAAALgAECgUJBgAAAA==.',
['小伙']='小伙的秘密:BAAALgADCgQJBAAAAA==.',
['小别']='小别兔:BAAALgADCggJCAABLgAFFAQJCAAEAIcTAA==.',
['小夜']='小夜曲:BAAALgAFFAEJAQAAAA==.',
['小德']='小德哥:BAAALgADCgEJAQAAAA==.',
['小火']='小火龙:BAAALgAECggJDgAAAA==.',
['小的']='小的不会奶:BAAALgAECgYJCwAAAA==.',
['小苹']='小苹果:BAAALgAECgYJCAAAAA==.',
['小裤']='小裤衩:BAAALgAFFAEJAQAAAA==.',
['尧丶']='尧丶尧:BAAALgAECgEJAQAAAA==.',
['就是']='就是咚咚哟:BAAALgAFFAIJAgAAAA==.',
['巨型']='巨型鼠鼠:BAAALgADCgEJAQAAAA==.',
['巫灬']='巫灬妖一:BAABLgAECn8WAAICAAcJqBrxEgDaAQACAAcJqBrxEgDaAQAAAA==.巫灬妖七:BAAALgAECgcJDAAAAA==.巫灬妖三:BAAALgAECgcJCAAAAA==.巫灬妖二:BAABLgAECn8UAAICAAcJgBJmHABmAQACAAcJgBJmHABmAQAAAA==.巫灬妖五:BAAALgAECgcJDQAAAA==.巫灬妖八:BAAALgAFFAQJBAAAAA==.巫灬妖六:BAAALgAECgcJDgAAAA==.巫灬妖四:BAABLgAECn8UAAICAAcJ+RMzGACUAQACAAcJ+RMzGACUAQAAAA==.',
['干饭']='干饭熊阿树:BAAALgAECgcJDAAAAA==.',
['心匪']='心匪石:BAAALgADCgcJBwAAAA==.',
['忧伤']='忧伤:BAAALgAECgEJAQAAAA==.忧伤德:BAAALgAECgMJAwAAAA==.忧伤沫:BAAALgAECgUJBQAAAA==.忧伤牧:BAAALgAECgUJBQAAAA==.忧伤猎:BAAALgADCgYJCwAAAA==.忧伤萨满:BAAALgAECgMJAwAAAA==.忧伤骑士:BAAALgAECgQJBAAAAA==.',
['忽毙']='忽毙猎:BAABLgAFFH8GAAMFAAQJECVMBgC7AQAFAAQJECVMBgC7AQAGAAIJnBhgFQCvAAAAAA==.',
['我是']='我是坦克:BAAALgADCgEJAQAAAA==.',
['我欲']='我欲化清风:BAAALgAFFAIJAwAAAA==.',
['抱皂']='抱皂不安:BAAALgAECgYJBgAAAA==.',
['拿破']='拿破伦:BAAALgADCgkJCQAAAA==.',
['挤挤']='挤挤不露:BAAALgAECgIJAgAAAA==.挤挤布鲁:BAAALgAECgEJAgAAAA==.',
['斯人']='斯人如逝:BAAALgAECgEJAQAAAA==.',
['无情']='无情灬:BAAALgAECgMJAwAAAA==.',
['暗圣']='暗圣牧:BAAALgAECgEJAgAAAA==.',
['月半']='月半亻子:BAAALgAECgcJDQAAAA==.',
['月影']='月影星痕:BAAALgADCgcJCAAAAA==.',
['李思']='李思思:BAAALgAECgcJBwABLgAFFAUJAQADAAAAAA==.',
['林北']='林北超度兰:BAAALgAECgYJBgAAAA==.',
['果果']='果果小麻瓜:BAABLgAECn8WAAMGAAgJVxuFEwCbAgAGAAcJ4xuFEwCbAgAFAAIJLBFkcgB0AAAAAA==.',
['柚子']='柚子吃酸的:BAAALgADCgEJAQAAAA==.',
['柯圣']='柯圣:BAAALgAECgYJBgABLgAECgYJEAADAAAAAA==.',
['次级']='次级风暴元素:BAABLgAFFH8LAAIHAAQJvB15CABUAQAHAAQJvB15CABUAQAAAA==.',
['流拳']='流拳冰:BAAALgAECgYJDQAAAA==.流拳暗:BAAALgAECgcJCwAAAA==.流拳火:BAAALgAECggJCAAAAA==.流拳电:BAAALgAFFAQJBAAAAA==.',
['淘气']='淘气的小猫咪:BAAALgAECgEJAQAAAA==.',
['淡淡']='淡淡的雪花:BAAALgADCgEJAQAAAA==.',
['温吻']='温吻尔雅:BAAALgAECgMJAwAAAA==.',
['温闻']='温闻尔雅:BAAALgAECgYJEAAAAA==.',
['溜溜']='溜溜球:BAAALgAECgkJDwAAAA==.',
['無丶']='無丶过:BAAALgAFFAQJBAAAAA==.',
['燎原']='燎原妖:BAAALgAECgQJBQAAAA==.',
['爷爷']='爷爷:BAAALgAECgcJBwABLgAFFAQJCAAIAAoUAA==.',
['独搅']='独搅天下:BAAALgAFFAEJAgAAAA==.',
['王冰']='王冰冰:BAAALgAFFAIJAgABLgAFFAUJAQADAAAAAA==.',
['瑞文']='瑞文戴爾女爵:BAAALgADCgUJBwAAAA==.',
['田曦']='田曦薇:BAAALgAECgYJCQAAAA==.',
['皮蛋']='皮蛋:BAABLgAFFH8FAAIFAAUJfxHCCACOAQAFAAUJfxHCCACOAQAAAA==.',
['瞎咔']='瞎咔啦咔:BAAALgAECgYJDQAAAA==.',
['祈祷']='祈祷世界和平:BAAALgAECgYJBwAAAA==.',
['神赐']='神赐之名:BAACLgAFFH8JAAMFAAQJ2wU9GADQAAAFAAMJ4AQ9GADQAAAGAAIJMgWRGwCQAAAuAAQKfyAAAwUACAmdFUsvALcBAAUABgl/GUsvALcBAAYABgmiDthSAHABAAAA.',
['空瓶']='空瓶子:BAAALgAECgcJCQAAAA==.',
['端木']='端木若琳:BAAALgADCgEJAQAAAA==.',
['笑着']='笑着拔牙:BAAALgAECgEJAgAAAA==.',
['簡愛']='簡愛:BAAALgAECgEJAQAAAA==.',
['精神']='精神小妹:BAAALgAECgEJAQAAAA==.',
['红光']='红光满面:BAAALgAECgYJBgAAAA==.',
['红绿']='红绿灯的黄:BAAALgAECgEJAQAAAA==.',
['约翰']='约翰尼丶德普:BAAALgADCgUJBQAAAA==.',
['翼幻']='翼幻之霜:BAAALgADCgUJCAAAAA==.',
['联盟']='联盟疤痕:BAAALgAECgUJBwAAAA==.',
['苍澜']='苍澜:BAAALgAECgcJBwAAAA==.',
['蒋奇']='蒋奇明乀:BAAALgAECgIJAgAAAA==.',
['蒲公']='蒲公英的旅行:BAAALgAECgcJDwAAAA==.',
['薩了']='薩了個大滿:BAAALgAECgYJCgAAAA==.',
['蘇丶']='蘇丶阿鶏:BAABLgAECn8VAAIJAAgJ4B25DgCyAgAJAAgJ4B25DgCyAgAAAA==.',
['虚空']='虚空蕾丝:BAAALgAECgYJCAAAAA==.',
['蛊月']='蛊月:BAAALgAECgYJBgAAAA==.',
['蜘蛛']='蜘蛛泡酒:BAAALgAECgYJEgAAAA==.',
['试玩']='试玩账号:BAAALgAECgUJBQAAAA==.',
['还是']='还是哐哐呀:BAABLgAFFH8PAAIKAAUJWxVWBgCgAQAKAAUJWxVWBgCgAQAAAA==.',
['远古']='远古之力:BAAALgAECgEJAQAAAA==.',
['逆疯']='逆疯:BAAALgAECgYJBgAAAA==.',
['逆蜂']='逆蜂:BAAALgAFFAEJAQAAAA==.',
['那个']='那个萨满死下:BAAALgAECgMJAwAAAA==.',
['重生']='重生之尘魔:BAAALgAECgMJBQAAAA==.',
['银翼']='银翼之殇:BAAALgADCgQJBAAAAA==.',
['闹呢']='闹呢:BAAALgAECgEJAQAAAA==.',
['阿古']='阿古斯萨拉:BAAALgAECgcJCwAAAA==.',
['阿尔']='阿尔赛利亚:BAABLgAECn8eAAMBAAgJwBHzYQC/AQABAAgJwBHzYQC/AQALAAYJFwhXWQAWAQAAAA==.',
['难杀']='难杀:BAAALgADCgMJAwAAAA==.',
['集吙']='集吙那个武僧:BAAALgAECgEJAQAAAA==.',
['风潇']='风潇易临:BAAALgAECgcJEwAAAA==.',
['风起']='风起长林:BAAALgAECgIJAgAAAA==.',
['飞翔']='飞翔的心:BAAALgADCgMJAwAAAA==.',
['骁风']='骁风:BAABLgAFFH8OAAMMAAQJhBsGAwBeAQAMAAQJhBsGAwBeAQANAAEJRBmBCQBdAAAAAA==.',
['骑牛']='骑牛大保镖:BAAALgADCgMJAwAAAA==.',
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
