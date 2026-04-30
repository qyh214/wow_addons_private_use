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

local lookup = {'Mage-Frost','Shaman-Restoration','Paladin-Retribution','Warrior-Protection','Druid-Restoration','Unknown-Unknown','Hunter-Marksmanship','Paladin-Holy','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Druid-Balance','Priest-Shadow','Priest-Holy','DemonHunter-Devourer','Warrior-Arms','Warrior-Fury','Monk-Mistweaver','Monk-Windwalker',}
local provider = {region='CN',realm='巴尔古恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abbymilo:BAAALgAECgUJBQAAAA==.',
Al='Aleih:BAAALgAFFAQJBAAAAA==.Aleik:BAAALgAFFAQJBAAAAA==.',
Bd='Bdk:BAAALgAECgMJAwAAAA==.',
Be='Belle:BAAALgAECgUJBQAAAA==.',
Cl='Classrhodey:BAABLgAFFH8FAAIBAAIJPgSMSACeAAABAAIJPgSMSACeAAAAAA==.',
Di='Dingaling:BAAALgAECgEJAgAAAA==.',
Ha='Happiness:BAAALgADCgMJAwAAAA==.',
Hi='Hikari:BAAALgADCgUJBQAAAA==.',
Hu='Huigui:BAABLgAECn8XAAIBAAYJhBX4pgCLAQABAAYJhBX4pgCLAQAAAA==.',
Ju='Juejuezhu:BAAALgADCgkJDQAAAA==.',
Kk='Kkiss:BAAALgAFFAIJBAAAAA==.',
Ma='Makemecry:BAAALgAECggJEwAAAA==.',
Mc='Mcdonaldmage:BAABLgAFFH8RAAIBAAQJzhyeBQB0AQABAAQJzhyeBQB0AQAAAA==.',
Me='Mengd:BAAALgAECgUJCgAAAA==.',
Sh='Shadows:BAAALgAECgcJDAAAAA==.',
Th='Theshy:BAAALgAECgEJAQAAAA==.',
Wh='Whisperwindy:BAAALgAECgYJCAAAAA==.',
['一只']='一只苜蓿:BAAALgAFFAMJAwAAAA==.',
['一夕']='一夕云一:BAAALgADCgIJAgAAAA==.',
['七叶']='七叶团团:BAAALgAECgYJCAAAAA==.七叶圆圆:BAAALgAECgEJAQAAAA==.七叶梧桐:BAAALgAECgEJAQAAAA==.',
['为倪']='为倪消瘦:BAABLgAFFH8IAAICAAMJsgoXCADTAAACAAMJsgoXCADTAAAAAA==.',
['九灵']='九灵根虾仁:BAAALgAECgEJAQAAAA==.',
['亲大']='亲大爷:BAABLgAFFH8HAAIDAAYJpwGfOgBBAAADAAYJpwGfOgBBAAAAAA==.',
['以圣']='以圣光之名:BAAALgADCgEJAQAAAA==.',
['仮屋']='仮屋和奏:BAAALgAFFAIJAQAAAA==.',
['依风']='依风听雨:BAAALgAECgQJBAAAAA==.',
['倚风']='倚风听雨:BAAALgADCgIJAgAAAA==.',
['冰火']='冰火奥:BAAALgAECgYJCQAAAA==.',
['勥烎']='勥烎:BAAALgADCgMJAwAAAA==.',
['医瑟']='医瑟拉:BAAALgAECgYJBgAAAA==.',
['南城']='南城:BAAALgAECgIJAgAAAA==.南城逆流:BAACLgAFFH8HAAIEAAMJxxHNAwDdAAAEAAMJxxHNAwDdAAAuAAQKfxsAAgQABwljHrATANEBAAQABwljHrATANEBAAAA.',
['卡其']='卡其猫:BAAALgAECgcJEQAAAA==.',
['双叶']='双叶萤:BAAALgAECgQJBAAAAA==.',
['发光']='发光桂花酿:BAAALgAECgYJBgAAAA==.',
['叮当']='叮当是只猫:BAABLgAECn8aAAIFAAgJWhW/KwABAgAFAAgJWhW/KwABAgAAAA==.',
['呀哈']='呀哈哈:BAAALgAECgcJDAAAAA==.',
['咕咕']='咕咕牛:BAAALgAECgEJAQAAAA==.',
['哎欧']='哎欧娜:BAAALgAECgcJBAAAAA==.',
['善良']='善良的熊仔派:BAAALgAECgcJDQAAAA==.',
['喆喆']='喆喆的小奶嘴:BAAALgAFFAIJAwAAAA==.',
['地板']='地板之王:BAAALgAECgQJBAAAAA==.',
['夏天']='夏天的小雨:BAAALgAECgMJAwAAAA==.',
['夏孤']='夏孤离:BAAALgAECgUJCQAAAA==.',
['夜里']='夜里无眠:BAAALgAECgIJAgAAAA==.',
['大岈']='大岈:BAAALgAECgUJBQAAAA==.',
['大篱']='大篱笆:BAAALgAECgYJBgABLgAFFAIJAgAGAAAAAA==.',
['天空']='天空之泪:BAAALgAECgIJAgAAAA==.',
['奈亚']='奈亚子:BAABLgAFFH8HAAIHAAIJgRw4GgCxAAAHAAIJgRw4GgCxAAABLgAFFAcJHAAHAEkfAA==.',
['好大']='好大大鸡排:BAAALgADCgEJAQAAAA==.',
['娜贝']='娜贝拉尔:BAACLgAFFH8IAAIDAAMJqRbeCAAGAQADAAMJqRbeCAAGAQAuAAQKfxQAAwMABwncGPhlALQBAAMABwncGPhlALQBAAgABAlODYVvALwAAAAA.',
['孤问']='孤问万古愁:BAAALgAECgEJAgAAAA==.',
['孽畜']='孽畜还不跪下:BAAALgAECgUJCQAAAA==.',
['安度']='安度因洛萨:BAAALgAECgYJDwAAAA==.',
['小小']='小小龙虾:BAAALgADCgYJBgAAAA==.',
['小明']='小明明灬:BAAALgADCgMJAwAAAA==.',
['少爷']='少爷:BAAALgADCgcJBwAAAA==.',
['师妹']='师妹杀手:BAAALgAECgEJAQAAAA==.',
['帕瓦']='帕瓦:BAAALgAECgEJAQAAAA==.',
['帝花']='帝花:BAAALgADCgEJAQAAAA==.',
['幻夜']='幻夜:BAAALgADCgEJAQAAAA==.',
['幻想']='幻想少女物語:BAACLgAFFH8JAAIJAAMJcia+BQBdAQAJAAMJcia+BQBdAQAuAAQKfxsAAwkABwnzJeccAKgCAAkABwnzJeccAKgCAAoAAgk+CLhGAJsAAAAA.',
['幻舞']='幻舞羽兮:BAAALgADCgQJBAAAAA==.',
['影之']='影之岚:BAAALgADCgYJBgAAAA==.',
['怪盗']='怪盗贞德:BAAALgAECgMJBgAAAA==.',
['恶魔']='恶魔猎物:BAAALgADCgUJBQAAAA==.',
['想骑']='想骑吗真:BAAALgAECgYJBgAAAA==.',
['感谢']='感谢彦祖拉我:BAAALgAECgYJCwAAAA==.',
['我会']='我会永远爱桃:BAABLgAFFH8IAAIBAAMJyCWyHQBUAQABAAMJyCWyHQBUAQAAAA==.',
['战国']='战国英雄:BAAALgAECgQJBAAAAA==.',
['打发']='打发打发时间:BAAALgAECgYJDQABLgAFFAcJCwAFAIAZAA==.',
['撩人']='撩人浊酒:BAAALgAECgYJCgAAAA==.撩人浊酒一:BAAALgAFFAIJAwAAAA==.',
['断音']='断音呐:BAAALgAECgYJBgAAAA==.',
['旗枫']='旗枫:BAAALgAECgQJBAABLgAECgYJBgAGAAAAAA==.',
['旷工']='旷工小朋鸟:BAAALgAECgUJBQABLgAFFAEJAQAGAAAAAA==.',
['明明']='明明灬狗:BAAALgAECgMJAwAAAA==.',
['暗黑']='暗黑魔法:BAAALgAECgYJAgAAAA==.',
['月下']='月下美人:BAAALgAECgUJBAAAAA==.',
['月光']='月光姬:BAAALgAECgYJCAAAAA==.',
['月枫']='月枫神:BAAALgAECgEJAQAAAA==.',
['月满']='月满西樓:BAABLgAECn8XAAILAAcJEhZVOgDFAQALAAcJEhZVOgDFAQAAAA==.',
['有角']='有角角:BAAALgADCgYJBgAAAA==.',
['未知']='未知劣人:BAAALgAECgQJBAAAAA==.',
['村里']='村里的鹅:BAAALgADCgIJAgAAAA==.',
['来自']='来自猩猩的你:BAAALgAFFAIJBAAAAA==.',
['桂小']='桂小镁:BAAALgAECgcJDgAAAA==.',
['梦境']='梦境的米迪娅:BAAALgAECgEJAQAAAA==.',
['梦醒']='梦醒什分:BAAALgAECgIJAgAAAA==.',
['欧拉']='欧拉欧拉:BAAALgAECgEJAQAAAA==.',
['法涛']='法涛无赦:BAAALgAFFAIJAwAAAA==.',
['流萤']='流萤引:BAABLgAFFH8FAAIMAAUJIhhgBACmAQAMAAUJIhhgBACmAQAAAA==.',
['海盗']='海盗黑船:BAAALgAECgQJCwAAAA==.',
['灬伊']='灬伊尔灬:BAAALgAECgYJCQAAAA==.',
['灬威']='灬威利旺卡灬:BAACLgAFFH8HAAINAAMJ4RY+BQDyAAANAAMJ4RY+BQDyAAAuAAQKfxcAAw0ABwn4IA4bAAYCAA0ABwn4IA4bAAYCAA4ABAnqBSplAJgAAAAA.',
['灬辣']='灬辣辣灬:BAABLgAFFH8HAAIPAAUJ5w5hCAAtAQAPAAUJ5w5hCAAtAQAAAA==.',
['炽炎']='炽炎罗刹:BAAALgAECgEJAQAAAA==.',
['煤球']='煤球一德:BAABLgAFFH8FAAIFAAUJXB8QAgDgAQAFAAUJXB8QAgDgAQAAAA==.煤球七德:BAAALgAFFAQJBAAAAA==.煤球三德:BAAALgAFFAQJBAAAAA==.煤球五德:BAAALgAFFAQJBAAAAA==.',
['熊熊']='熊熊臭臭香:BAAALgAECgEJAQAAAA==.',
['牌没']='牌没有问题:BAAALgAECgEJAQAAAA==.',
['独唱']='独唱情歌:BAAALgAECgEJAQAAAA==.',
['独自']='独自风飘一:BAABLgAFFH8GAAIDAAIJSxC/JQCgAAADAAIJSxC/JQCgAAAAAA==.',
['猫爪']='猫爪子米米:BAAALgAECgEJAwAAAA==.',
['獸人']='獸人战:BAAALgAECgcJAQAAAA==.',
['玛尔']='玛尔兰:BAACLgAFFH8IAAIDAAMJjhvOBgAfAQADAAMJjhvOBgAfAQAuAAQKfxYAAgMABgkuIzouAGoCAAMABgkuIzouAGoCAAAA.',
['玥溪']='玥溪:BAAALgAECgUJBQAAAA==.',
['瑞瑞']='瑞瑞矮骑:BAAALgAECgkJCQAAAA==.',
['瓦萨']='瓦萨其:BAAALgAECgUJBQAAAA==.',
['甜豌']='甜豌豆:BAAALgAECgkJDgAAAA==.',
['电源']='电源插座:BAAALgAECgcJEQAAAA==.',
['白牛']='白牛牪犇:BAAALgAECgYJBwAAAA==.',
['皮球']='皮球:BAAALgAFFAIJAgAAAA==.',
['眷影']='眷影年华:BAAALgADCgMJAgAAAA==.',
['碎觉']='碎觉:BAAALgAECgYJBwAAAA==.',
['科塞']='科塞特斯:BAAALgAECgMJAwAAAA==.',
['童心']='童心未抿:BAAALgAECgcJCQAAAA==.',
['给我']='给我加个嗜血:BAAALgAECgcJEwAAAA==.',
['绫绡']='绫绡:BAAALgAFFAEJAQAAAA==.',
['绽枫']='绽枫:BAAALgAECgYJBgAAAA==.',
['罗木']='罗木丶奶妈:BAAALgAECgQJBAAAAA==.',
['老暴']='老暴伍:BAAALgAECgEJAQAAAA==.老暴壹:BAAALgAFFAEJAQAAAA==.老暴拾陆:BAAALgAECgMJAwAAAA==.',
['联盟']='联盟騎士:BAAALgAECgcJEAAAAA==.',
['胡须']='胡须佬:BAAALgAECgQJBAAAAA==.',
['與子']='與子偕老丶默:BAAALgAECgEJAQAAAA==.',
['舞动']='舞动的弓弦:BAACLgAFFH8IAAILAAQJIhjKAwBhAQALAAQJIhjKAwBhAQAuAAQKfxoAAwsACAlaIaARAKsCAAsACAlaIaARAKsCAAcAAQkIBbKTACYAAAAA.',
['艾雅']='艾雅:BAAALgAECgYJCwAAAA==.',
['花田']='花田半亩:BAAALgADCgIJAgAAAA==.',
['芸尛']='芸尛咿:BAAALgAECgMJBAABLgAFFAYJBAAGAAAAAA==.',
['茬别']='茬别豳默:BAAALgADCgQJBAAAAA==.',
['莉丝']='莉丝缇亚:BAAALgAECgQJBAAAAA==.',
['莫纳']='莫纳卡伊:BAAALgAECgEJAQAAAA==.',
['萨莉']='萨莉怀特迈恩:BAAALgAECgEJAQAAAA==.',
['落雨']='落雨知秋:BAAALgAECgQJBAAAAA==.',
['蒙萌']='蒙萌大叔:BAAALgAECgQJBAAAAA==.',
['蘑菇']='蘑菇头:BAAALgAECgUJCQAAAA==.',
['请叫']='请叫我芸大王:BAAALgAECgQJBQAAAA==.',
['谨言']='谨言慎行:BAAALgAECgYJCQAAAA==.',
['谷畸']='谷畸亭:BAAALgAECgYJBgAAAA==.',
['赤龙']='赤龙影:BAABLgAECn8UAAMQAAcJbxrgCwDjAQAQAAcJ9hjgCwDjAQARAAYJfRiURACSAQAAAA==.',
['赵敏']='赵敏:BAAALgAECgMJAwAAAA==.',
['超萌']='超萌小猪:BAACLgAFFH8HAAMMAAQJshjKDQACAQAMAAMJbRfKDQACAQAFAAIJ6xknFwCoAAAuAAQKfx8AAwUACAnhIugGAB0DAAUACAnhIugGAB0DAAwAAgndFxQcAF0AAAAA.',
['软绵']='软绵绵:BAAALgAECgUJCQAAAA==.',
['迟日']='迟日江山暮:BAAALgAECgIJAgAAAA==.',
['遺夨']='遺夨十年:BAABLgAFFH8FAAIDAAUJWQ8iCQBmAQADAAUJWQ8iCQBmAQAAAA==.',
['避邪']='避邪:BAAALgADCgcJBwAAAA==.',
['邪邪']='邪邪:BAAALgAECgYJEAAAAA==.',
['酩酊']='酩酊旅途:BAAALgAECgUJBQAAAA==.',
['长河']='长河落日:BAAALgADCgMJAwAAAA==.',
['阿伦']='阿伦索斯法奥:BAAALgADCgEJAQAAAA==.',
['阿瑞']='阿瑞狄斯:BAAALgADCgEJAQAAAA==.',
['陈汐']='陈汐雯大坏蛋:BAAALgADCgEJAQAAAA==.',
['雅尔']='雅尔贝德:BAACLgAFFH8IAAIBAAMJBQemFADrAAABAAMJBQemFADrAAAuAAQKfxQAAgEABgnOGtqZAKEBAAEABgnOGtqZAKEBAAAA.',
['雪乃']='雪乃深冬:BAAALgAECgYJAgAAAA==.',
['雷公']='雷公:BAAALgADCgYJBgAAAA==.',
['露普']='露普斯蕾琪娜:BAACLgAFFH8IAAIRAAMJrRgOBQAQAQARAAMJrRgOBQAQAQAuAAQKfx0AAhEABwk8Ij8eAF0CABEABwk8Ij8eAF0CAAAA.',
['青柠']='青柠檬:BAAALgAECgEJAQAAAA==.',
['青鱂']='青鱂:BAAALgAECgEJAQAAAA==.',
['青鸢']='青鸢丶罗兰:BAAALgAECgYJCgAAAA==.',
['风暴']='风暴汽水:BAACLgAFFH8HAAMSAAMJOwoPBwDHAAASAAMJOwoPBwDHAAATAAIJhwSSDgCKAAAuAAQKfx0AAxIABwmmHCsYAP4BABIABwmmHCsYAP4BABMABgnnGQhtAFwAAAAA.',
['高森']='高森奈津美:BAAALgAFFAIJAgAAAA==.',
['魔界']='魔界之圣寂:BAAALgADCgIJAgAAAA==.魔界之小德:BAAALgADCgUJBQAAAA==.魔界之游迪安:BAAALgADCgQJBwAAAA==.魔界之牛虻:BAAALgADCgcJBwAAAA==.魔界之珊莎:BAAALgADCgUJBQAAAA==.魔界之米老鼠:BAAALgADCgUJBQAAAA==.魔界之黑暗:BAAALgADCgUJBQAAAA==.魔界之鼻涕:BAAALgADCgEJAgAAAA==.',
['麦吉']='麦吉:BAAALgAECgEJAQAAAA==.',
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
