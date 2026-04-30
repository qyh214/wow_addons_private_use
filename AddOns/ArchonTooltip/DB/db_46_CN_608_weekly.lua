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

local lookup = {'DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Unknown-Unknown','Paladin-Holy','Priest-Discipline','Priest-Shadow','Warrior-Protection','Druid-Restoration','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Warrior-Arms','Warrior-Fury','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Holy','DeathKnight-Blood',}
local provider = {region='CN',realm='哈卡',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akio:BAAALgAECgYJBwAAAA==.',
Ap='Aping:BAAALgADCgIJAgAAAA==.',
At='Atziluth:BAAALgAFFAEJAQAAAA==.',
De='Deyikea:BAAALgADCgIJAgAAAA==.',
Et='Eto:BAAALgADCgYJBgAAAA==.',
Ge='Gels:BAAALgADCgYJBgAAAA==.',
La='Lastslayer:BAAALgAECgkJCQAAAA==.',
Lo='Lori:BAAALgAECgYJBgAAAA==.',
Ma='Malphas:BAAALgAECgYJCgAAAA==.',
Md='Mdi:BAAALgAECgkJBgAAAA==.',
Me='Mediocreman:BAABLgAFFH8GAAIBAAQJgx0ACQCJAQABAAQJgx0ACQCJAQABLgAFFAUJCAABAPIeAA==.',
Po='Potusa:BAAALgADCgEJAQAAAA==.',
St='Stephentrial:BAAALgAECgkJCQAAAA==.',
Sv='Sven:BAAALgAFFAEJAQAAAA==.',
Sx='Sxdtlw:BAABLgAECn8lAAMCAAgJXA/9LgC5AQACAAgJXA/9LgC5AQADAAEJAADLSwAAAAAAAA==.',
Ty='Ty:BAAALgAECgQJAwAAAA==.',
We='Weqert:BAAALgAECgQJBAAAAA==.',
Xp='Xpresstofu:BAAALgAECgcJCwAAAA==.',
['一个']='一个小胖子:BAAALgADCgIJAgAAAA==.',
['一夜']='一夜无痕:BAAALgADCgEJAQAAAA==.',
['万亿']='万亿天:BAAALgAECgMJBQAAAA==.',
['三山']='三山有杏:BAABLgAECn8dAAIEAAcJ4RcXHwBaAQAEAAcJ4RcXHwBaAQAAAA==.',
['不奶']='不奶你就完了:BAAALgAECgIJAgAAAA==.',
['丨符']='丨符文图腾丨:BAAALgAECgYJBgAAAA==.',
['临川']='临川:BAAALgAECgQJBgABLgAECgQJCQAFAAAAAA==.',
['丶不']='丶不见星空:BAAALgAECggJAgAAAA==.',
['丶浮']='丶浮白:BAAALgADCgEJAQABLgAECgQJCQAFAAAAAA==.',
['乄睡']='乄睡不醒:BAAALgADCgIJAgAAAA==.',
['以太']='以太行者:BAAALgAECgEJAQAAAA==.',
['以射']='以射止射:BAAALgADCgQJBAAAAA==.',
['伊利']='伊利灬丹丶怒:BAAALgAECgUJBQAAAA==.',
['伊鲁']='伊鲁米:BAAALgAECgcJBwAAAA==.',
['倾秋']='倾秋:BAAALgADCgEJAQAAAA==.',
['光是']='光是纽带:BAAALgADCgEJAQAAAA==.',
['再借']='再借五厘米:BAAALgAFFAQJBAABLgAFFAUJDwAGAAEjAA==.',
['冰冷']='冰冷丨办公桌:BAABLgAECn8fAAMHAAgJ3B80BwDQAgAHAAgJ3B80BwDQAgAIAAYJZhLJKwB+AQAAAA==.冰冷之吻:BAAALgADCgcJBwAAAA==.',
['冰封']='冰封丶夕阳:BAAALgAECgQJBAAAAA==.',
['冰火']='冰火奥义之王:BAAALgADCgcJBAAAAA==.',
['冰释']='冰释前嫌:BAAALgAECgYJCwAAAA==.',
['冰魂']='冰魂火魄:BAAALgADCgEJAQAAAA==.',
['凄美']='凄美流年:BAAALgAECgYJCQAAAA==.',
['初吻']='初吻給了奶嘴:BAAALgAECgMJAwAAAA==.',
['刮刮']='刮刮乐:BAAALgADCgcJBwAAAA==.',
['剁椒']='剁椒肥牛:BAAALgAECgEJAQAAAA==.',
['剑在']='剑在人在丶:BAAALgAECgIJAwAAAA==.',
['劫神']='劫神:BAAALgADCgEJAQAAAA==.',
['十月']='十月:BAAALgADCgYJBgAAAA==.',
['南北']='南北多歧路:BAAALgAECgMJAwAAAA==.',
['卡西']='卡西莫多:BAAALgAECggJDwAAAA==.',
['叫我']='叫我软爷:BAAALgAECgcJDQAAAA==.',
['可笑']='可笑的孤单:BAAALgAECgEJAQAAAA==.',
['吉泽']='吉泽灬灬明步:BAAALgAECgEJAQAAAA==.',
['后来']='后来:BAAALgAECgYJCwAAAA==.',
['吴丶']='吴丶精酿啤酒:BAAALgAECgcJBwAAAA==.',
['吴小']='吴小锤:BAAALgAECgYJBgAAAA==.',
['周星']='周星星:BAAALgAECgkJCQABLgAFFAcJDQAJAM4ZAA==.',
['咕咕']='咕咕德:BAAALgADCgIJAgAAAA==.',
['咕嘟']='咕嘟晨光:BAAALgAECgUJBQAAAA==.',
['咬人']='咬人貓:BAAALgAECgYJCQAAAA==.',
['喜多']='喜多郁代:BAAALgAECgcJBgAAAA==.',
['喵喵']='喵喵:BAAALgAECgEJAgAAAA==.',
['喵薄']='喵薄荷:BAAALgAECgYJCwAAAA==.',
['嘟哒']='嘟哒吐露嘟哒:BAAALgAECgEJAQAAAA==.',
['噢买']='噢买尬德:BAACLgAFFH8KAAIKAAMJ1RYLEADqAAAKAAMJ1RYLEADqAAAuAAQKfxsAAgoABwmgHekhADYCAAoABwmgHekhADYCAAAA.',
['圣佑']='圣佑术:BAAALgAECgEJAgAAAA==.',
['塑料']='塑料娃娃:BAACLgAFFH8IAAILAAMJ5xCJFgD4AAALAAMJ5xCJFgD4AAAuAAQKfyoAAwsACAldHewfAKwCAAsACAldHewfAKwCAAYABgn0BDxjAO8AAAAA.',
['墨與']='墨與炎:BAAALgAECgEJAQAAAA==.墨與言:BAAALgAECgYJDwAAAA==.',
['墨迹']='墨迹不墨迹:BAAALgAFFAQJBAAAAA==.',
['壹嵗']='壹嵗殧變壞:BAAALgAECgkJCgAAAA==.',
['壹歲']='壹歲殧變壞:BAAALgAECgEJAgAAAA==.',
['夏木']='夏木一雅子:BAABLgAECn8YAAILAAcJ9RdZQwAaAgALAAcJ9RdZQwAaAgAAAA==.',
['夜夜']='夜夜姬:BAAALgAECgYJCQAAAA==.',
['大狸']='大狸猫:BAACLgAFFH8KAAQMAAQJJRVvEABdAQAMAAQJmxJvEABdAQANAAEJFhpDEwBYAAAOAAEJ3wM7BwBKAAAuAAQKfx8ABAwACAnOHYI8ABsCAAwABwnOHYI8ABsCAA0AAQkAAAtlAEUAAA4AAQltEnsvAD8AAAAA.',
['大米']='大米职业选手:BAAALgAECgkJDQAAAA==.',
['大肠']='大肠刺身:BAAALgAECgYJCgAAAA==.',
['天实']='天实安德:BAAALgAECgQJBwAAAA==.',
['失落']='失落之风:BAAALgAECgUJCAAAAA==.失落伊甸园:BAABLgAFFH8HAAMPAAMJ0gw0BAD2AAAPAAMJdws0BAD2AAAQAAIJHAnbGgCdAAAAAA==.',
['如龙']='如龙:BAABLgAFFH8HAAILAAMJfR0nDADMAAALAAMJfR0nDADMAAAAAA==.',
['姬狐']='姬狐丨怜悯:BAAALgADCgYJBgABLgAECgYJBgAFAAAAAA==.姬狐丨翱翔:BAAALgAECgYJBgAAAA==.',
['子非']='子非术:BAAALgAECgYJCQAAAA==.',
['寂寞']='寂寞的心啊:BAAALgAECgEJAQAAAA==.',
['将爱']='将爱判三年:BAAALgAECgYJCAAAAA==.',
['小红']='小红帽快来:BAAALgAECgYJDQAAAA==.',
['小雪']='小雪狼:BAAALgAECgkJEQAAAA==.',
['巨人']='巨人一击:BAAALgAECgUJBwAAAA==.',
['帆婷']='帆婷淇宝宝:BAABLgAECn8XAAIRAAgJcxBFGwDnAQARAAgJcxBFGwDnAQAAAA==.',
['希丨']='希丨希:BAAALgAECgEJAgAAAA==.',
['希尔']='希尔瓦娜思:BAAALgAECgkJBwAAAA==.',
['干完']='干完闪人:BAAALgAECgcJCgAAAA==.',
['干豆']='干豆腐:BAAALgAECgYJBgAAAA==.',
['幽默']='幽默闪电人:BAAALgAECgEJAQAAAA==.',
['庸人']='庸人自扰:BAAALgAECgIJAQABLgAFFAUJCAABAPIeAA==.',
['弐貹']='弐貹:BAAALgAECgEJAQAAAA==.',
['彼丶']='彼丶方:BAAALgAECgUJCQAAAA==.',
['御第']='御第哥儿:BAAALgAECgYJBgAAAA==.',
['微光']='微光炼狱骑士:BAAALgAECgYJBgAAAA==.',
['心斐']='心斐:BAAALgADCgYJBgAAAA==.',
['心术']='心术不正:BAAALgAECgIJAgAAAA==.',
['心跳']='心跳丶哇塞:BAAALgAECgQJCAAAAA==.',
['心里']='心里有术:BAAALgAFFAIJBAAAAA==.',
['怎抹']='怎抹:BAAALgAECgQJBAAAAA==.',
['惩戒']='惩戒骑:BAAALgAFFAIJAgAAAA==.',
['意见']='意见欲:BAAALgAFFAEJAQAAAA==.',
['愛伱']='愛伱:BAAALgAECgEJAQAAAA==.',
['慕容']='慕容舞倾城:BAAALgADCgUJBgAAAA==.',
['我不']='我不知道:BAAALgAECgEJAQABLgAFFAUJCAABAPIeAA==.',
['我叫']='我叫色牛:BAABLgAFFH8GAAIKAAIJbwgJHgCEAAAKAAIJbwgJHgCEAAAAAA==.',
['扣弦']='扣弦而舞:BAAALgAECgQJBQAAAA==.',
['斬杀']='斬杀丶斬杀:BAAALgAECgcJAwAAAA==.',
['斯铭']='斯铭:BAAALgADCgIJAgAAAA==.',
['旺旺']='旺旺吉星高照:BAAALgAECggJEgAAAA==.旺旺地狱博士:BAAALgAECgcJBwABLgAECgkJIwASAN8SAA==.',
['星宿']='星宿老夹:BAAALgAECgYJCwAAAA==.',
['星痕']='星痕:BAABLgAFFH8FAAMMAAUJ/RwvDwBlAQAMAAQJRxovDwBlAQANAAEJIiX5DwBqAAAAAA==.',
['星空']='星空丶:BAAALgAECgEJAQAAAA==.',
['月落']='月落丶冬至:BAAALgAFFAIJAgABLgAFFAcJCgAEAO4cAA==.月落丶圣堂:BAAALgAECgYJBQAAAA==.月落丶影殇:BAAALgAECgYJDAAAAA==.',
['杀兔']='杀兔先锋:BAAALgAECgkJEAAAAA==.',
['松山']='松山湖典狱官:BAAALgAFFAIJAgAAAA==.',
['枫宿']='枫宿霜栖:BAAALgAECgEJAgAAAA==.',
['格兰']='格兰伲:BAAALgAFFAIJBAAAAA==.',
['梆梆']='梆梆不梆梆:BAAALgAFFAQJBAAAAA==.',
['梦境']='梦境回廊:BAAALgAFFAIJAgAAAA==.',
['梦未']='梦未央:BAAALgAECgUJBwAAAA==.',
['棉花']='棉花糖:BAAALgADCgMJAwAAAA==.',
['欌暮']='欌暮溘:BAAALgADCgIJAgAAAA==.',
['欢乐']='欢乐:BAAALgAECgEJAQAAAA==.欢乐天神:BAAALgAECgYJBgAAAA==.',
['欧气']='欧气小阿兜:BAAALgAECgUJCgAAAA==.',
['欧皇']='欧皇丶:BAABLgAFFH8GAAMIAAIJVQ+tBwCjAAAIAAIJVQ+tBwCjAAATAAEJtwEUGAAzAAAAAA==.',
['江湖']='江湖不良人:BAAALgADCgYJBgAAAA==.',
['沈佳']='沈佳宜:BAAALgAECgYJBwAAAA==.',
['沉默']='沉默圣光:BAAALgADCgEJAQAAAA==.',
['沙漠']='沙漠萌妹:BAAALgAECgEJAQAAAA==.',
['没有']='没有愛的季節:BAAALgAECgMJAwAAAA==.',
['浅丶']='浅丶忆:BAAALgAECgQJCAAAAA==.',
['混乱']='混乱之祭:BAAALgAECgYJBgAAAA==.',
['温尼']='温尼伯行者:BAAALgAECgMJAwAAAA==.',
['潇湘']='潇湘宇:BAAALgAECgEJAQAAAA==.',
['灬演']='灬演员灬:BAAALgAECgUJBQAAAA==.',
['灰烬']='灰烬天使:BAAALgAECgIJAgAAAA==.',
['点根']='点根香烟就抽:BAAALgAECgcJCwAAAA==.',
['烨影']='烨影长风:BAAALgAECgYJCwAAAA==.',
['热罗']='热罗尼莫:BAAALgAFFAIJAgAAAA==.',
['然然']='然然:BAABLgAFFH8NAAIIAAQJKhLHCAA3AQAIAAQJKhLHCAA3AQABLgAFFAQJBgAIAAcWAA==.',
['熊猫']='熊猫仙人丶:BAAALgAECgQJBgAAAA==.',
['牧丶']='牧丶小冷丿咒:BAAALgAECgYJBgAAAA==.牧丶晓宇:BAAALgAECgYJCgAAAA==.',
['狐狸']='狐狸不小:BAAALgAECgMJAwAAAA==.',
['田师']='田师傅:BAACLgAFFH8IAAIKAAQJbRrnDgD4AAAKAAQJbRrnDgD4AAAuAAQKfyMAAgoACAmAHXUbAGACAAoACAmAHXUbAGACAAAA.',
['瘋孒']='瘋孒:BAAALgAECgYJDQAAAA==.',
['白露']='白露未晞:BAAALgAECgIJAwAAAA==.',
['百医']='百医:BAACLgAFFH8GAAITAAMJ9AcKCgDGAAATAAMJ9AcKCgDGAAAuAAQKfxQAAhMABwlBEowoAKwBABMABwlBEowoAKwBAAAA.',
['盾盾']='盾盾大九:BAAALgAECgYJDgAAAA==.',
['看那']='看那小子真黑:BAAALgAECgQJBwAAAA==.',
['真理']='真理所在:BAACLgAFFH8FAAIEAAIJCxzMNgC9AAAEAAIJCxzMNgC9AAAuAAQKfxoAAgQABwlMHAJYADECAAQABwlMHAJYADECAAAA.',
['砂贺']='砂贺:BAAALgAECgkJCwAAAA==.',
['硬梆']='硬梆梆的我:BAABLgAECn8aAAIBAAcJiCNqIADAAgABAAcJiCNqIADAAgAAAA==.',
['碎骨']='碎骨还阳:BAAALgADCgEJAQAAAA==.',
['神牛']='神牛听我滴:BAAALgAECgYJDAAAAA==.',
['竹报']='竹报星宸:BAAALgAFFAEJAQAAAA==.',
['精灵']='精灵布丁:BAAALgAECgkJCQAAAA==.',
['糸影']='糸影:BAAALgAECgUJBQAAAA==.',
['終不']='終不似少年遊:BAABLgAFFH8FAAIBAAQJZAuKBwBMAQABAAQJZAuKBwBMAQAAAA==.',
['繁华']='繁华:BAAALgAECgYJCAAAAA==.',
['终焉']='终焉怒风:BAAALgADCgUJBQAAAA==.',
['美队']='美队:BAAALgAFFAIJAwAAAA==.',
['耀刃']='耀刃行歌:BAAALgAECgEJAgAAAA==.',
['老掰']='老掰:BAAALgAECgYJCQAAAA==.',
['聴风']='聴风:BAAALgADCgYJCAAAAA==.',
['肆海']='肆海凉生欢:BAAALgADCgcJBwAAAA==.',
['肆蚀']='肆蚀:BAAALgAECgEJAQAAAA==.',
['肾斗']='肾斗士性史丶:BAAALgAECgkJCQAAAA==.',
['胖墩']='胖墩墩:BAAALgAECgYJCwAAAA==.',
['芙蘭']='芙蘭朵露:BAACLgAFFH8PAAIGAAQJlSUoAwC4AQAGAAQJlSUoAwC4AQAuAAQKfyEAAgYACAnZI18DAD0DAAYACAnZI18DAD0DAAAA.',
['花谢']='花谢亦会开:BAAALgAECgEJAQAAAA==.',
['莹莹']='莹莹的狗崽子:BAAALgADCgMJAwAAAA==.',
['莽丿']='莽丿僧丶沐羽:BAAALgAECgcJBgAAAA==.',
['菊花']='菊花点穴手:BAAALgAECgEJAgAAAA==.',
['萌哒']='萌哒熊:BAAALgAECgcJCgAAAA==.',
['落叶']='落叶的期盼:BAAALgAECgEJBAAAAA==.',
['藏锋']='藏锋:BAAALgAECgMJBAAAAA==.',
['蚊子']='蚊子也是肉:BAAALgAECgcJDAAAAA==.',
['血色']='血色残锋:BAABLgAFFH8FAAILAAUJOQpIOgBDAAALAAUJOQpIOgBDAAAAAA==.',
['誓约']='誓约:BAAALgAFFAEJAQAAAA==.',
['诗雨']='诗雨落花:BAAALgAFFAEJAQAAAA==.',
['该躲']='该躲不躲:BAACLgAFFH8NAAMMAAQJ/BMMFQBEAQAMAAQJ/BMMFQBEAQAOAAEJNgUiBwBMAAAuAAQKfxoABAwACAk/FrJMAOIBAAwACAklE7JMAOIBAA4AAQnMI5IiAGcAAA0AAQkAANRuADgAAAAA.',
['请不']='请不用理我:BAAALgADCgYJBgAAAA==.',
['赤刃']='赤刃明霄:BAAALgAECgcJBwABLgAFFAUJCQANANghAA==.',
['起手']='起手爆发休息:BAAALgADCgUJBQAAAA==.',
['踏风']='踏风升:BAAALgAECgcJEwAAAA==.',
['软绵']='软绵绵的我:BAABLgAFFH8PAAMDAAUJxyUXAADKAQADAAUJxyUXAADKAQACAAQJMBB7DQBJAQAAAA==.',
['辟孕']='辟孕光环灬:BAABLgAECn8aAAMBAAgJfBulSAAZAgABAAgJfBulSAAZAgAUAAIJyweVSwAfAAAAAA==.',
['这一']='这一切的开始:BAAALgAECgEJAQAAAA==.',
['迪儿']='迪儿再临:BAAALgADCgEJAQAAAA==.',
['逐星']='逐星丶丶:BAAALgAECgQJCQAAAA==.',
['遗忘']='遗忘什么:BAACLgAFFH8IAAIEAAMJVxZTLAAFAQAEAAMJVxZTLAAFAQAuAAQKfyMAAgQACAmEIgMvALYCAAQACAmEIgMvALYCAAEuAAUUAwkKAAoA1RYA.',
['邪恶']='邪恶银渐层:BAAALgAECgEJAQAAAA==.',
['釭凶']='釭凶滴碰碰:BAAALgAECgEJAwAAAA==.',
['钢丶']='钢丶蕉:BAAALgAECgcJBwAAAA==.',
['闪电']='闪电喵变身:BAACLgAFFH8NAAIKAAQJARMFCwAtAQAKAAQJARMFCwAtAQAuAAQKfxoAAgoACAmLHuwUAI4CAAoACAmLHuwUAI4CAAAA.',
['阳光']='阳光好刺眼:BAAALgAECgEJAQAAAA==.',
['阿丽']='阿丽塔:BAAALgAECgMJBAAAAA==.',
['陌无']='陌无痕:BAAALgADCgUJBQAAAA==.',
['雅立']='雅立史卓沙:BAAALgAECgEJAQABLgAECgEJBAAFAAAAAA==.',
['雪月']='雪月风花:BAAALgAECgQJBwAAAA==.',
['雷格']='雷格西:BAAALgADCgEJAQAAAA==.',
['霜火']='霜火箭:BAAALgAECgEJAQAAAA==.',
['领着']='领着白菜逛街:BAAALgAECgYJDAAAAA==.',
['风后']='风后奇门:BAAALgADCgMJAwAAAA==.',
['风灬']='风灬过:BAAALgAECgUJBgAAAA==.',
['风雷']='风雷丿惢惢:BAAALgAECgYJBgABLgAFFAQJBAAFAAAAAA==.',
['飞扬']='飞扬世界:BAAALgAFFAQJAwAAAA==.',
['鳯若']='鳯若兮:BAAALgADCgIJAgAAAA==.',
['黄瓜']='黄瓜也疯狂:BAAALgADCgUJBQAAAA==.',
['黑夜']='黑夜游侠:BAAALgAECgYJDQAAAA==.',
['黛玉']='黛玉露鬼背:BAAALgAECgEJAQAAAA==.',
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
