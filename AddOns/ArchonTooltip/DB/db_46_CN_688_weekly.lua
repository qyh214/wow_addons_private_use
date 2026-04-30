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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','Druid-Balance','Druid-Feral','DemonHunter-Devourer','DemonHunter-Havoc','Evoker-Preservation','Unknown-Unknown','DeathKnight-Unholy','Shaman-Elemental','Druid-Restoration','DeathKnight-Frost','Paladin-Holy','Warlock-Demonology','Paladin-Retribution','Mage-Frost','Shaman-Enhancement','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','Monk-Mistweaver','Warlock-Destruction','Paladin-Protection','Priest-Shadow','Priest-Discipline','Druid-Guardian','Shaman-Restoration','Monk-Windwalker',}
local provider = {region='CN',realm='拉文凯斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aibu:BAAALgAFFAEJAQAAAA==.Aiub:BAAALgAECgEJAQAAAA==.',
As='Astrasolaire:BAAALgAECgcJEQAAAA==.',
Ax='Axl:BAAALgAECgMJAwAAAA==.',
Az='Azorian:BAACLgAFFH8PAAMBAAQJwCBkDwALAQABAAMJrR5kDwALAQACAAIJdSSpBwBzAAAuAAQKf0sAAwIACAn1JUoDAOsCAAIABwkdJUoDAOsCAAEAAwkAJAYyADgBAAAA.',
Ce='Cervidae:BAABLgAECn8aAAMDAAgJxg6GLACeAQADAAgJMA6GLACeAQAEAAMJKA8WJQCqAAAAAA==.',
Ch='Chione:BAAALgAECgUJCQAAAA==.',
Cr='Crazyshushi:BAAALgAFFAEJAQAAAA==.Crucio:BAAALgAFFAIJBAAAAA==.',
Cy='Cynthiax:BAAALgAECgUJBQAAAA==.',
Dd='Ddlfk:BAAALgADCgYJBgAAAA==.',
De='Deathstroke:BAAALgAECgYJBgAAAA==.',
Di='Diospada:BAABLgAECn8eAAMFAAgJixjlNwAVAgAFAAgJLhjlNwAVAgAGAAEJbRuiaQA/AAAAAA==.',
Dr='Dracaryss:BAAALgAFFAIJAwAAAA==.',
Ga='Gatanothor:BAAALgAECgcJCQAAAA==.',
He='Heimuws:BAAALgAECgcJEAAAAA==.Heimuzs:BAAALgAECgYJBgAAAA==.',
Ho='Homie:BAABLgAECn8YAAMHAAYJxhj+FwDVAQAHAAYJxhj+FwDVAQACAAUJmBDIKADZAAABLgAFFAEJAgAIAAAAAA==.',
Hu='Huashiliao:BAAALgAECgUJBQAAAA==.',
['Hê']='Hêllokitty:BAAALgAECgMJAwAAAA==.',
Ji='Jimi:BAAALgADCgIJAgAAAA==.',
Jo='Jove:BAAALgAFFAIJBAAAAA==.',
Ka='Kanye:BAAALgAECgYJCAAAAA==.Karna:BAAALgAFFAEJAQAAAA==.',
Kk='Kkay:BAABLgAECn8hAAIJAAgJ8RxhJwCdAgAJAAgJ8RxhJwCdAgAAAA==.',
Ko='Korey:BAAALgADCgYJBgABLgAFFAEJAQAIAAAAAA==.',
La='Lays:BAAALgAECgEJBQAAAA==.',
Li='Lillard:BAAALgAECgkJEAAAAA==.',
Lu='Lumin:BAAALgAECgEJAQAAAA==.',
Ma='Matrixz:BAAALgAECgcJAQAAAA==.',
Mi='Mimie:BAABLgAFFH8GAAIKAAMJZwnIEQDbAAAKAAMJZwnIEQDbAAABLgAFFAUJEgAFABEhAA==.',
Na='Naga:BAAALgAFFAMJBAAAAA==.',
No='Noong:BAAALgADCgUJBQAAAA==.',
Pd='Pdpd:BAACLgAFFH8JAAMLAAMJ2hHCEADjAAALAAMJ2hHCEADjAAADAAIJZQ0xFQCbAAAuAAQKfxQAAwsABwl2JSUTAJwCAAsABwl2JSUTAJwCAAMABgnpImA+ADkBAAEuAAUUBQkIAAEAfwwA.',
Ph='Phobia:BAAALgAECgYJCgAAAA==.',
Pr='Prihok:BAAALgAECgEJAQABLgAFFAEJAQAIAAAAAA==.',
Sa='Sapsapsap:BAAALgAECggJEwAAAA==.',
Ss='Ssdogegg:BAAALgAECgEJAQAAAA==.',
St='Stella:BAAALgAECgkJBwAAAA==.',
To='Toolman:BAAALgAFFAEJAgAAAA==.Tortugaga:BAAALgADCgUJBQAAAA==.',
Ve='Verange:BAAALgAECgEJAQAAAA==.',
Vu='Vunky:BAAALgADCgEJAQAAAA==.',
Wa='Walton:BAAALgAECgIJAgAAAA==.',
Wh='Whatcanisay:BAAALgAECgUJBQAAAA==.Whisper:BAAALgADCgEJAQAAAA==.',
Ye='Yeehok:BAAALgAFFAEJAQAAAA==.',
Zi='Ziegler:BAEALgAECgkJAQAAAA==.',
['一个']='一个小团团:BAAALgAECgYJCAAAAA==.',
['一倾']='一倾风月:BAAALgAECgUJBwAAAA==.',
['一叶']='一叶遮羞丶:BAAALgADCgEJAQAAAA==.',
['一夏']='一夏天的雨丶:BAABLgAECn8XAAMJAAgJZBzLCADxAQAJAAgJZBzLCADxAQAMAAEJmwsTCQA6AAAAAA==.',
['一招']='一招升龙拳:BAAALgAECgYJCQAAAA==.',
['一朵']='一朵小黄花:BAAALgAFFAEJAQAAAA==.',
['一来']='一来二曲:BAAALgADCgUJBQAAAA==.',
['一秋']='一秋天的风:BAAALgAECgYJBwAAAA==.',
['一顿']='一顿小点炮:BAAALgAECgUJCQAAAA==.',
['七件']='七件夏天衫:BAAALgAFFAQJBAAAAA==.',
['七省']='七省文状元:BAAALgAECgEJAQAAAA==.',
['万般']='万般皆是命丶:BAAALgADCgUJCQAAAA==.',
['三月']='三月寅时:BAAALgAECgUJBQAAAA==.',
['三爺']='三爺:BAAALgADCgMJAwAAAA==.',
['不好']='不好评价:BAAALgADCgcJBwAAAA==.',
['东七']='东七七:BAAALgAECgEJAgAAAA==.',
['丨伊']='丨伊瑟丨:BAAALgAECgcJBgAAAA==.',
['丨刺']='丨刺丶:BAAALgAECgYJBgABLgAFFAQJBAAIAAAAAA==.',
['丨哈']='丨哈基米丨:BAAALgAECggJDwAAAA==.',
['丨妖']='丨妖怪灬:BAAALgAECgYJAQAAAA==.',
['丨雨']='丨雨落盛夏丨:BAABLgAECn8XAAINAAgJ7hh+JAD/AQANAAgJ7hh+JAD/AQAAAA==.',
['中东']='中东蓬莱蕉:BAAALgAECgEJAQAAAA==.',
['丶伊']='丶伊利达雷:BAAALgAECgMJAwABLgAECgcJCgAIAAAAAA==.',
['丶凝']='丶凝风:BAAALgAECgIJAgAAAA==.',
['丶咕']='丶咕噜丶:BAAALgADCgYJCQAAAA==.',
['丶我']='丶我带你们打:BAAALgAFFAIJBAAAAA==.',
['丶花']='丶花熊丶:BAAALgAECgEJAQAAAA==.丶花馒丶:BAAALgAECgQJBAAAAA==.',
['丶药']='丶药儿:BAABLgAFFH8HAAIOAAQJnxJ/IwD2AAAOAAQJnxJ/IwD2AAAAAA==.',
['丷夏']='丷夏至丷:BAAALgADCgcJCAAAAA==.',
['丷忆']='丷忆银丷:BAAALgADCgcJCAAAAA==.',
['为了']='为了影遁:BAAALgAECgcJBgAAAA==.',
['为还']='为还愿而来:BAAALgAECgcJDAAAAA==.',
['主食']='主食吃馒头:BAAALgAECgcJDgAAAA==.',
['丿梓']='丿梓丶潇:BAACLgAFFH8LAAIPAAQJ9RgOFAAHAQAPAAQJ9RgOFAAHAQAuAAQKfxQAAg8ABwnbH2AyAFkCAA8ABwnbH2AyAFkCAAAA.',
['丿鎂']='丿鎂滋滋丿:BAAALgAECgcJBwAAAA==.',
['乔瑟']='乔瑟夫乔斯达:BAABLgAFFH8GAAIBAAMJtw9aEgDtAAABAAMJtw9aEgDtAAABLgAFFAgJFgABAH0HAA==.',
['乔迪']='乔迪奥乔斯达:BAAALgAECgEJAQAAAA==.',
['九月']='九月申时:BAAALgAECgEJAQAAAA==.',
['九约']='九约:BAAALgAECgcJBwAAAA==.',
['了不']='了不起的杉佐:BAAALgAECgUJCQAAAA==.',
['二月']='二月丑时:BAAALgAECgEJAQAAAA==.',
['于楚']='于楚小凡几:BAAALgAECgYJCQAAAA==.',
['云溪']='云溪:BAAALgAECgQJBAAAAA==.',
['亓风']='亓风:BAAALgAECgEJAQAAAA==.',
['京樂']='京樂:BAAALgAFFAEJAgAAAA==.',
['以丶']='以丶后:BAAALgADCgUJBwAAAA==.',
['仲夏']='仲夏之恋:BAAALgAECgEJAgAAAA==.',
['伈隨']='伈隨舞动:BAAALgAECgQJBAAAAA==.',
['伊波']='伊波恩莎布:BAAALgAECgYJBgAAAA==.',
['伊瑞']='伊瑞尔丶卡拉:BAABLgAFFH8FAAIPAAIJcyCvGgDKAAAPAAIJcyCvGgDKAAAAAA==.',
['会计']='会计计算器:BAAALgAECgcJCgAAAA==.',
['佫析']='佫析丶:BAAALgAECgMJAwAAAA==.',
['依然']='依然尘嚣:BAAALgAFFAMJBAAAAA==.',
['做自']='做自己该做的:BAAALgAECgkJCgAAAA==.',
['像章']='像章越来越大:BAABLgAECn8WAAIQAAcJUxjjmACjAQAQAAcJUxjjmACjAQAAAA==.',
['光转']='光转圈没有风:BAAALgAFFAIJBAAAAA==.',
['克西']='克西头打烂:BAAALgAFFAIJAgAAAA==.',
['兔兔']='兔兔突:BAAALgAECgMJBQAAAA==.',
['兔子']='兔子:BAAALgAECgQJBAAAAA==.',
['兜里']='兜里有圣光:BAAALgAFFAEJAQAAAA==.',
['公会']='公会太缺德:BAAALgAECgEJAQAAAA==.',
['公牛']='公牛没奶:BAAALgAECgIJAgAAAA==.',
['兿荑']='兿荑瓿肀:BAAALgAECgYJBgAAAA==.',
['冬至']='冬至夏末丶:BAAALgAECgEJAQAAAA==.',
['冰点']='冰点之雨:BAAALgAECgcJDgAAAA==.',
['冲锋']='冲锋龙卷风丶:BAAALgAECgIJAgAAAA==.',
['冲阵']='冲阵张三:BAAALgAECgcJEwAAAA==.',
['冷冷']='冷冷的北境:BAAALgAECgQJBAAAAA==.',
['冷水']='冷水寒:BAAALgAECgEJAQAAAA==.',
['凉风']='凉风满夏:BAABLgAECn8dAAMKAAcJCBqJIAALAgAKAAcJCBqJIAALAgARAAEJNANNLwAoAAAAAA==.',
['凝烟']='凝烟微凉:BAABLgAECn8jAAISAAgJoBxMAwAfAgASAAgJoBxMAwAfAgAAAA==.',
['刘仙']='刘仙僧:BAAALgADCgYJBgAAAA==.',
['刺杀']='刺杀之道:BAAALgADCgEJAQAAAA==.',
['刻骨']='刻骨爧煌:BAAALgAECgIJAgAAAA==.',
['动作']='动作温柔:BAAALgAECgEJAQAAAA==.',
['北鼻']='北鼻丶卡姆昂:BAAALgAECgEJAgAAAA==.',
['匹多']='匹多莫德:BAAALgAECgUJBQAAAA==.',
['十渠']='十渠不好买:BAAALgAECgYJCgAAAA==.',
['千里']='千里江涛似雪:BAABLgAECn8aAAIJAAcJ/x5FPgA+AgAJAAcJ/x5FPgA+AgAAAA==.',
['华夏']='华夏的熊猫:BAAALgAECgEJAQAAAA==.',
['南巷']='南巷清风:BAABLgAECn8jAAMTAAgJDiE+AwBfAgATAAgJDiE+AwBfAgAUAAUJkhuoOwBvAQAAAA==.',
['卡塔']='卡塔琳:BAAALgAECgEJAQAAAA==.',
['卡尔']='卡尔:BAAALgAECgcJDAAAAA==.',
['卡洛']='卡洛拉兹:BAAALgAECgYJEQAAAA==.',
['卿一']='卿一色:BAAALgAECgUJCQAAAA==.',
['压迫']='压迫众生:BAAALgAECgYJDAAAAA==.',
['双龙']='双龙母夜叉:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我仙爷:BAAALgAECgIJAgAAAA==.',
['可爱']='可爱的小饭饭:BAAALgAECgYJDAAAAA==.',
['叶晨']='叶晨:BAAALgAECgQJBwAAAA==.',
['吃货']='吃货八爪鱼:BAAALgAECgEJAQAAAA==.',
['合波']='合波:BAAALgAFFAIJAgAAAA==.',
['同淋']='同淋雪:BAAALgADCgcJDQAAAA==.',
['君天']='君天:BAAALgAECgMJAwAAAA==.',
['吥要']='吥要摸尾巴:BAAALgAECggJCQAAAA==.',
['吱吱']='吱吱呜:BAAALgAFFAEJAQAAAA==.',
['吴师']='吴师傅:BAAALgADCgcJBwAAAA==.',
['咖啡']='咖啡与糖:BAAALgAECgEJAQAAAA==.',
['哇咔']='哇咔哇咔呜呢:BAAALgAECgEJAQAAAA==.哇咔哇咔呼啦:BAAALgAECgYJCAAAAA==.',
['哈基']='哈基哈基飞:BAEALgAECgMJAwABLgAFFAQJEQAHABYmAA==.',
['哈尼']='哈尼张三:BAAALgADCgcJBwAAAA==.',
['哎哟']='哎哟喂:BAACLgAFFH8SAAMVAAUJ5RJJCwAsAQAVAAUJ5RJJCwAsAQAWAAIJxgr4EQCKAAAuAAQKfy0AAxUACAmzIsAKAN4CABUACAmzIsAKAN4CABYAAQkWE3FmADkAAAAA.',
['哔哩']='哔哩吧啦:BAAALgAECgQJBgAAAA==.',
['哞声']='哞声发财:BAAALgAECgEJAQAAAA==.',
['唥孒']='唥孒楿偲:BAAALgAECgEJAwAAAA==.',
['啃芒']='啃芒果的三千:BAAALgAECgcJCAAAAA==.',
['嗷呜']='嗷呜凹凸:BAAALgAECgEJAgAAAA==.',
['嘚呵']='嘚呵:BAAALgADCgEJAQAAAA==.',
['噬魂']='噬魂丨女爻:BAABLgAECn8WAAMOAAgJMBdOMQBHAgAOAAgJyBZOMQBHAgAXAAEJrxvxXgBSAAAAAA==.',
['囍之']='囍之郎丶:BAAALgAFFAIJAwAAAA==.',
['四二']='四二四:BAAALgAECgUJBQAAAA==.',
['四月']='四月卯时:BAAALgAECgMJBAAAAA==.',
['四爷']='四爷:BAAALgADCgEJAQAAAA==.',
['国际']='国际知名野牛:BAAALgAFFAEJAgAAAA==.',
['圣光']='圣光后裔:BAAALgADCgEJAQAAAA==.圣光舞曲:BAAALgAECgMJBAAAAA==.圣光诈骗:BAABLgAFFH8IAAIPAAQJkh+DDgA2AQAPAAQJkh+DDgA2AQAAAA==.',
['圣刃']='圣刃:BAAALgAECgYJDAAAAA==.圣刃再临:BAAALgAECgUJCAABLgAFFAMJBQADAMwIAA==.',
['圣劫']='圣劫丶兵:BAAALgAECgEJAQAAAA==.',
['圣灵']='圣灵之战:BAAALgADCgkJDQAAAA==.圣灵之殇:BAAALgADCgEJAQAAAA==.圣灵之骑:BAAALgAECgYJCAAAAA==.',
['堂堂']='堂堂的夏天:BAAALgADCgYJBgAAAA==.',
['堕天']='堕天聖黒猫:BAAALgAECgQJBAAAAA==.',
['塔克']='塔克西斯:BAAALgAECgQJBQAAAA==.',
['塔兰']='塔兰:BAAALgAECgUJBQAAAA==.',
['墨一']='墨一:BAAALgAFFAEJAQAAAA==.',
['壹丨']='壹丨骑:BAAALgAECgEJAgAAAA==.',
['壹夯']='壹夯夯:BAAALgADCgEJAQAAAA==.',
['壹巭']='壹巭猎:BAAALgADCgYJAQAAAA==.',
['壹念']='壹念壹輪回:BAAALgAECgEJAgAAAA==.',
['外婆']='外婆来了:BAAALgAECgkJAQAAAA==.',
['多云']='多云转晴:BAAALgAECgEJAQAAAA==.',
['多年']='多年以後:BAAALgAECgYJEQAAAA==.',
['多雨']='多雨转晴:BAAALgAECgMJBAAAAA==.多雨转雪:BAAALgAECgYJCAAAAA==.',
['夜雨']='夜雨阑歌:BAAALgAECgEJAQAAAA==.',
['大地']='大地生命:BAAALgAECgEJAQAAAA==.',
['大夏']='大夏龙雀:BAAALgAECgEJAQAAAA==.',
['大好']='大好人:BAACLgAFFH8HAAMYAAQJHAX+AgDGAAAYAAQJHAX+AgDGAAANAAIJXx1qEwCpAAAuAAQKfxwABBgABwmPG/oNAOUBABgABwk9GvoNAOUBAA0ABQm3H8ouAMgBAA8AAgmaFXUEAY0AAAAA.',
['大妖']='大妖精:BAAALgAECgMJAwAAAA==.',
['大王']='大王辛佑辛:BAAALgAFFAEJAgAAAA==.',
['大聖']='大聖靈:BAAALgADCgUJAQAAAA==.',
['天人']='天人合一:BAAALgAECgEJAgAAAA==.',
['天使']='天使的心跳:BAABLgAECn8XAAIZAAcJMx8KEACFAgAZAAcJMx8KEACFAgABLgAFFAQJCAAaAIcTAA==.',
['天堂']='天堂鸟小黑:BAABLgAECn8gAAIPAAgJkxaOSQAGAgAPAAgJkxaOSQAGAgAAAA==.',
['天都']='天都魅灵:BAAALgADCgUJBgAAAA==.',
['奥火']='奥火冰:BAAALgAECgcJBwAAAA==.',
['奥特']='奥特曼小怪兽:BAAALgAECgEJAQAAAA==.',
['奶德']='奶德百灵鸟:BAACLgAFFH8JAAILAAQJcxvcBQB7AQALAAQJcxvcBQB7AQAuAAQKfxcAAwsACAkZGZMeAEoCAAsACAkZGZMeAEoCAAMAAwm3BYltAGkAAAAA.',
['奶爸']='奶爸看着你:BAAALgAECgMJAwAAAA==.',
['奶白']='奶白滴雪子:BAAALgAFFAIJAwAAAA==.',
['好运']='好运天天有:BAACLgAFFH8JAAINAAQJOh+eBgBtAQANAAQJOh+eBgBtAQAuAAQKfx8AAw0ACAn6IgwHAPsCAA0ACAn6IgwHAPsCAA8AAgndDngVAW0AAAAA.',
['如果']='如果没有如果:BAAALgAFFAEJAQAAAA==.',
['妍灬']='妍灬依依:BAAALgAECgQJBQAAAA==.',
['妮可']='妮可丶猪德曼:BAAALgAECgcJBwAAAA==.',
['娇傲']='娇傲:BAAALgADCgYJBgABLgAFFAYJFgAKAMUZAA==.',
['媳妇']='媳妇我想减肥:BAABLgAFFH8IAAIUAAUJWRqKBgC2AQAUAAUJWRqKBgC2AQAAAA==.',
['子洲']='子洲:BAAALgAECgQJBAAAAA==.',
['孤帆']='孤帆疊影:BAAALgAFFAMJBAAAAA==.',
['宁杀']='宁杀错不放过:BAABLgAECn8eAAIMAAgJexZlBAAbAgAMAAgJexZlBAAbAgAAAA==.',
['宇宙']='宇宙幻影:BAAALgAECgYJCwAAAA==.',
['寒江']='寒江丶孤影:BAAALgADCgUJBQAAAA==.',
['封印']='封印灬豆丁:BAAALgADCgUJBQAAAA==.',
['封山']='封山育林:BAAALgAECgUJCAAAAA==.',
['小坚']='小坚果:BAAALgAFFAMJBAAAAA==.',
['小小']='小小妖儿:BAAALgAFFAEJAgAAAA==.',
['小恶']='小恶丶魔:BAAALgADCgIJAgAAAA==.',
['小手']='小手搓炉石:BAAALgAECgcJBwAAAA==.',
['小水']='小水狐:BAAALgAECgEJAQAAAA==.',
['小沦']='小沦:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊摊手:BAAALgAECgEJAQAAAA==.',
['小狗']='小狗肖恩:BAAALgAECgYJDAABLgAECggJCwAIAAAAAA==.',
['小猪']='小猪蹄子:BAABLgAECn8XAAIPAAgJNxx9BABYAgAPAAgJNxx9BABYAgAAAA==.',
['小王']='小王二:BAABLgAFFH8FAAINAAMJgBS2DQD9AAANAAMJgBS2DQD9AAAAAA==.',
['小甜']='小甜甜丶:BAAALgAECgYJBgAAAA==.',
['小精']='小精灵:BAAALgAECgEJAQAAAA==.',
['小耶']='小耶律可汗:BAAALgAECgYJBwAAAA==.',
['少年']='少年游:BAAALgAECgIJAgAAAA==.',
['尛兔']='尛兔丶:BAABLgAECn8WAAIJAAYJeB5jbQCvAQAJAAYJeB5jbQCvAQABLgAECgcJDQAIAAAAAA==.',
['岳大']='岳大头:BAAALgAFFAIJAgAAAA==.',
['岳绮']='岳绮罗丶:BAAALgAECgEJAQAAAA==.',
['峰之']='峰之小腿毛:BAAALgAECgYJBgAAAA==.',
['已无']='已无杀心:BAAALgAFFAIJAwAAAA==.',
['布绘']='布绘丸:BAAALgAECgYJBwAAAA==.',
['希特']='希特拉:BAAALgAECgIJAwAAAA==.',
['希露']='希露薇亚:BAAALgADCgEJAQAAAA==.',
['平安']='平安嘻乐:BAAALgAECgcJBwAAAA==.',
['年迈']='年迈带病杀戮:BAAALgAECgkJCQAAAA==.',
['幽星']='幽星觅:BAAALgAECgIJAgAAAA==.',
['底层']='底层逻辑:BAACLgAFFH8GAAIHAAIJliCmEAC7AAAHAAIJliCmEAC7AAAuAAQKfx4AAwcACAmbGhgCAAgCAAcACAmbGhgCAAgCAAEABgk1AwlJALIAAAAA.',
['弑神']='弑神丶:BAAALgAECgEJAQAAAA==.',
['张三']='张三他四叔丶:BAAALgAECgEJAQAAAA==.',
['弥赛']='弥赛亞:BAAALgAECgUJBQAAAA==.',
['往事']='往事不如烟:BAAALgAFFAQJAgAAAA==.',
['得劲']='得劲魔法:BAAALgAECgYJBwAAAA==.',
['徳不']='徳不常死:BAAALgAECgMJBAAAAA==.',
['德不']='德不常失:BAAALgADCgEJAQAAAA==.',
['德医']='德医双新:BAAALgAECgYJDQAAAA==.',
['德忆']='德忆志:BAAALgADCgcJBwAAAA==.',
['德某']='德某女:BAAALgADCgMJAwAAAA==.',
['忆久']='忆久久:BAAALgAECgcJCgAAAA==.',
['快乐']='快乐的鸡翅:BAAALgAECgEJAQAAAA==.',
['怒风']='怒风大帝:BAAALgAECgEJAQAAAA==.',
['怕拉']='怕拉没拉:BAABLgAECn8kAAIVAAgJ+hxJAgA3AgAVAAgJ+hxJAgA3AgAAAA==.',
['思念']='思念绕指柔:BAAALgADCgUJBQAAAA==.',
['恶魔']='恶魔猎手:BAACLgAFFH8SAAIFAAUJESEhBQBUAQAFAAUJESEhBQBUAQAuAAQKfy0AAwUACAlSJccKAC0DAAUACAlSJccKAC0DAAYAAwlqH3tWAI0AAAAA.',
['惡魔']='惡魔獵手:BAAALgADCgIJAgAAAA==.',
['慎独']='慎独:BAAALgAFFAUJBAAAAA==.',
['慕若']='慕若轩轩:BAABLgAECn8XAAIQAAgJaQ50FACeAQAQAAgJaQ50FACeAQAAAA==.',
['慧之']='慧之舞者:BAAALgAFFAIJAwAAAA==.',
['我心']='我心飘零:BAAALgAECggJCAAAAA==.',
['我是']='我是传奇:BAAALgAECgIJAgAAAA==.我是马小胖:BAACLgAFFH8IAAIQAAQJVgdUMADzAAAQAAQJVgdUMADzAAAuAAQKfx0AAhAACAnmFuU/AHkCABAACAnmFuU/AHkCAAAA.',
['战神']='战神归来丶:BAAALgADCgQJBAABLgADCgUJBQAIAAAAAA==.',
['打死']='打死不玩神牧:BAAALgAFFAMJAwAAAA==.',
['执刃']='执刃于巅:BAAALgADCgMJAwAAAA==.',
['批丶']='批丶准熬夜:BAAALgAECgYJBwAAAA==.',
['折梅']='折梅手丶:BAAALgAECgYJBgAAAA==.',
['护不']='护不侍郎:BAAALgAECgQJBgAAAA==.',
['抹了']='抹了油的蛛:BAAALgAECgQJAwAAAA==.',
['抽烟']='抽烟不用火:BAAALgAECgIJAgAAAA==.',
['拷贝']='拷贝快乐:BAAALgAECgYJCQAAAA==.',
['挽歌']='挽歌渡临舟:BAAALgADCgQJBAAAAA==.',
['撒狼']='撒狼嘿呦:BAABLgAFFH8HAAITAAIJEh8kEQDAAAATAAIJEh8kEQDAAAAAAA==.',
['数字']='数字信号处理:BAAALgADCgEJAQAAAA==.',
['斑衣']='斑衣彩戏:BAAALgAECgcJBwABLgAECgcJCgAIAAAAAA==.',
['斯米']='斯米达大姐夫:BAAALgAECgYJCAAAAA==.',
['无头']='无头:BAAALgAECgIJAgAAAA==.',
['无影']='无影之风:BAABLgAECn8aAAMDAAgJaxFlKwCmAQADAAcJDBJlKwCmAQALAAYJfRJuTgBqAQAAAA==.',
['无敌']='无敌是谁呀:BAAALgAECgcJDwAAAA==.',
['日月']='日月吉吉:BAAALgAECgcJDAAAAA==.',
['旺仔']='旺仔小牛奶:BAAALgAECgEJAQAAAA==.',
['明阳']='明阳夜叉:BAAALgAECgcJEgAAAA==.',
['星夜']='星夜玫瑰:BAAALgAECgEJAQAAAA==.',
['星河']='星河皓月:BAAALgADCgUJBQAAAA==.',
['春夏']='春夏秋冬:BAAALgAECgYJCwAAAA==.',
['時迁']='時迁:BAABLgAECn8gAAMGAAgJmRrEDwBpAgAGAAgJmRrEDwBpAgAFAAYJRw83HgAWAQAAAA==.',
['晟歌']='晟歌:BAAALgAECgUJBQAAAA==.',
['晨灬']='晨灬熙:BAAALgAECgYJCwAAAA==.',
['普罗']='普罗丢萨:BAAALgAECgMJBAAAAA==.',
['暗香']='暗香盈袖:BAAALgADCgYJBgAAAA==.',
['曦光']='曦光落羽:BAAALgAECgMJAwAAAA==.',
['月下']='月下独眠:BAAALgADCgEJAQAAAA==.',
['月亮']='月亮之吻:BAAALgADCgMJAwAAAA==.',
['月絮']='月絮:BAACLgAFFH8IAAILAAQJ7xbxCABEAQALAAQJ7xbxCABEAQAuAAQKfx8AAwsACQnRGDonABkCAAsACQnRGDonABkCAAMABwkxHQcgAP4BAAAA.',
['有时']='有时无语:BAAALgADCgcJBQAAAA==.',
['有的']='有的就放矢:BAAALgADCgIJAgAAAA==.',
['杜鲁']='杜鲁姆:BAAALgAECgMJBAAAAA==.',
['来此']='来此法肯够:BAAALgAECgYJBgABLgAECgYJBgAIAAAAAA==.',
['极寒']='极寒:BAAALgAECgMJAgAAAA==.',
['柠檬']='柠檬有点酸丶:BAAALgADCgkJDAAAAA==.',
['格里']='格里姆加大王:BAAALgAECgEJAQAAAA==.',
['桃花']='桃花墩墩儿:BAAALgAECgMJAwAAAA==.桃花翩翩飞:BAAALgADCgEJAQAAAA==.',
['梦幻']='梦幻跑影丶:BAAALgAECgYJBgABLgAFFAEJAQAIAAAAAA==.',
['梦魇']='梦魇丶缨:BAAALgAECgEJAQAAAA==.梦魇丶魔导师:BAAALgAECgUJCAAAAA==.',
['椰枫']='椰枫挡不住:BAAALgAECgEJAgAAAA==.',
['此人']='此人极度沉默:BAAALgADCgEJAQAAAA==.此人极度郁闷:BAAALgAFFAEJAQAAAA==.',
['死亡']='死亡葬歌:BAAALgADCgEJAQAAAA==.',
['毁灭']='毁灭白给:BAAALgAECgQJBAAAAA==.',
['水泥']='水泥墩:BAAALgAECgYJCQAAAA==.',
['永远']='永远愤怒:BAABLgAFFH8FAAQDAAMJzAhCFgCSAAADAAIJBAlCFgCSAAAbAAEJ7wbQBwApAAALAAIJphwAAAAAAAAAAA==.',
['氺儿']='氺儿:BAAALgAECgYJEAAAAA==.',
['汗脚']='汗脚老乡:BAACLgAFFH8KAAIKAAQJLBbYCABQAQAKAAQJLBbYCABQAQAuAAQKfycAAgoABwlFIwMMANoCAAoABwlFIwMMANoCAAAA.',
['江南']='江南烟雨枫:BAAALgAFFAEJAQAAAA==.',
['汤姆']='汤姆孙克鲁斯:BAACLgAFFH8LAAIQAAMJ7Q8uLgD+AAAQAAMJ7Q8uLgD+AAAuAAQKfxQAAhAACAlVFIlTAD0CABAACAlVFIlTAD0CAAAA.',
['波蒂']='波蒂斯:BAAALgADCgEJAQAAAA==.',
['注册']='注册好麻烦:BAAALgAECgkJCwAAAA==.',
['泰拉']='泰拉:BAAALgAECgkJBwAAAA==.',
['洛维']='洛维娜:BAAALgAECgYJBgAAAA==.',
['洛阿']='洛阿:BAAALgAECgEJAQAAAA==.',
['流年']='流年奈我何:BAAALgADCgEJAQAAAA==.',
['浅醉']='浅醉舞青锋:BAABLgAFFH8GAAIcAAMJhRMvDwDuAAAcAAMJhRMvDwDuAAAAAA==.',
['浜风']='浜风风:BAAALgADCgUJBQAAAA==.',
['浪漫']='浪漫的独照:BAAALgAECgMJAwAAAA==.',
['浪里']='浪里大白条:BAACLgAFFH8HAAIQAAQJnRc7JgAaAQAQAAQJnRc7JgAaAQAuAAQKfxkAAhAACAkwIX4cAAQDABAACAkwIX4cAAQDAAAA.',
['海迎']='海迎春:BAAALgAECgcJBwAAAA==.',
['混不']='混不吝:BAAALgAECgYJCAAAAA==.',
['清梦']='清梦:BAAALgADCgcJBwAAAA==.清梦压星河:BAAALgADCgMJAwAAAA==.',
['清风']='清风挽发:BAAALgAFFAEJAQAAAA==.清风斩月:BAAALgAECgYJDAAAAA==.',
['温柔']='温柔的丑男人:BAAALgAECgEJAgAAAA==.',
['游学']='游学者肖恩:BAAALgAECggJCwAAAA==.',
['游戏']='游戏结束:BAAALgADCgEJAQAAAA==.',
['潘达']='潘达莉亚的神:BAAALgAECgEJAQAAAA==.',
['灌注']='灌注白给:BAAALgAECgEJAQAAAA==.',
['火力']='火力发电站:BAAALgADCgEJAQAAAA==.',
['火暴']='火暴奶妹:BAAALgAECgQJBAAAAA==.',
['灬神']='灬神真子灬:BAAALgAECgYJDQAAAA==.',
['灬绣']='灬绣儿灬:BAAALgAECgEJAQAAAA==.',
['灯影']='灯影下的呢喃:BAAALgAECgcJAQAAAA==.',
['炒豆']='炒豆干儿:BAAALgAECgUJBQAAAA==.',
['炫彩']='炫彩:BAAALgAFFAIJAgAAAA==.',
['烬陌']='烬陌灬白羊座:BAAALgAECgMJAwAAAA==.',
['热切']='热切的圣骑土:BAAALgAECgcJDwAAAA==.',
['热砂']='热砂阿昆达:BAAALgAECgYJEQAAAA==.',
['熏武']='熏武空:BAAALgAECgMJAQAAAA==.',
['熔火']='熔火之心:BAAALgAECgYJBgAAAA==.',
['爆娃']='爆娃:BAAALgAECgEJAQAAAA==.',
['牙刷']='牙刷不见了:BAAALgADCgQJBAAAAA==.',
['牛皮']='牛皮:BAAALgAECgMJAwAAAA==.',
['狂暴']='狂暴氵怒:BAAALgAECggJEAAAAA==.',
['猎猎']='猎猎月:BAAALgAECgkJDwAAAA==.',
['猫爪']='猫爪神拳:BAACLgAFFH8GAAMDAAMJAg6IFACgAAADAAMJAg6IFACgAAALAAEJ4QHgFQAwAAAuAAQKfxgAAgMACAnBHXMQAJ0CAAMACAnBHXMQAJ0CAAAA.',
['玄冰']='玄冰之寒:BAAALgAECgEJAQAAAA==.',
['玄明']='玄明:BAAALgAECgEJAQABLgAFFAQJBAAIAAAAAA==.',
['玩火']='玩火丶杰尼龟:BAAALgAECgcJBwAAAA==.',
['玲珑']='玲珑无命:BAAALgAECgEJAQAAAA==.',
['理塘']='理塘王顶针:BAAALgADCgIJAgAAAA==.',
['琳儿']='琳儿:BAAALgAECgYJBwAAAA==.',
['琳月']='琳月瑶:BAAALgAECgYJCgAAAA==.',
['甜心']='甜心马卡龙:BAAALgAECgQJBAABLgAFFAMJBAAIAAAAAA==.',
['田半']='田半仙:BAAALgAECgEJAQAAAA==.田半锨:BAAALgAECgcJAQAAAA==.',
['电竞']='电竞路人甲:BAAALgAECggJEwAAAA==.',
['疯疯']='疯疯丶癫癫:BAAALgADCgIJAgAAAA==.',
['白发']='白发斩阎罗:BAAALgAECgUJCgAAAA==.',
['白叶']='白叶:BAAALgAECgEJAQAAAA==.',
['白晓']='白晓白:BAAALgAECgYJCwAAAA==.',
['白月']='白月丶:BAABLgAECn8lAAIQAAgJgh0cBQBlAgAQAAgJgh0cBQBlAgAAAA==.',
['白芷']='白芷昼夜:BAAALgAECgQJBAAAAA==.',
['白银']='白银后裔:BAAALgAECgEJAgAAAA==.',
['白面']='白面儿馒头:BAAALgAECgMJAwAAAA==.',
['百兽']='百兽丶凯多:BAAALgAECgEJAQAAAA==.',
['皛壄']='皛壄昭素:BAAALgAECgUJBAAAAA==.',
['盛明']='盛明兰:BAACLgAFFH8IAAMSAAQJSAwJCQDXAAASAAQJSAwJCQDXAAAaAAEJigFXHAA5AAAuAAQKfx0AAhIACAncG+wMAIYCABIACAncG+wMAIYCAAAA.',
['直接']='直接释放:BAAALgAECgcJCQAAAA==.',
['看我']='看我小拳拳:BAAALgAECgEJAQAAAA==.',
['碎光']='碎光:BAAALgAECgYJEAAAAA==.',
['神兵']='神兵:BAAALgAECgEJAQAAAA==.',
['神勇']='神勇的小白菜:BAAALgADCgYJBgAAAA==.',
['离离']='离离歌丶:BAAALgADCgQJBAAAAA==.',
['秋水']='秋水揽星河:BAAALgAFFAIJAgAAAA==.',
['穿林']='穿林海:BAAALgAECgUJBwAAAA==.',
['童渊']='童渊丨:BAAALgAFFAUJBAAAAA==.',
['竹清']='竹清:BAAALgAECgcJCgAAAA==.',
['笨小']='笨小狐狸笨:BAAALgADCgEJAQAAAA==.',
['等等']='等等我捶你:BAABLgAFFH8GAAIUAAQJ7RIgDgBDAQAUAAQJ7RIgDgBDAQABLgAFFAUJAQAIAAAAAA==.',
['米兰']='米兰的小铁匠:BAAALgADCgEJAQAAAA==.',
['米斯']='米斯提鲁:BAAALgADCgQJBAAAAA==.',
['紫色']='紫色丶妹妹:BAAALgAECgkJAgABLgAECgkJFgAOADAXAA==.',
['紫鸢']='紫鸢格格:BAABLgAECn8WAAITAAkJXBx4AwBWAgATAAkJXBx4AwBWAgAAAA==.',
['红圈']='红圈:BAABLgAFFH8FAAMVAAMJcw7gGgCTAAAVAAMJmA3gGgCTAAAdAAEJ9gRhEwBGAAAAAA==.',
['红肚']='红肚兜:BAAALgAECgIJBwAAAA==.',
['红葉']='红葉:BAAALgAFFAEJAQAAAA==.',
['绫風']='绫風:BAAALgAFFAMJAwAAAA==.',
['维迪']='维迪:BAAALgAFFAEJAQAAAA==.',
['绿冰']='绿冰:BAACLgAFFH8HAAIWAAQJxyIEAgCWAQAWAAQJxyIEAgCWAQAuAAQKfxcAAxYABgl6JNQOAGoCABYABgl6JNQOAGoCAB0AAwmMF85WALUAAAAA.',
['缅怀']='缅怀丶:BAAALgAECgEJAQAAAA==.',
['缘落']='缘落青云:BAAALgAECgYJBgABLgAFFAEJAQAIAAAAAA==.',
['缥缈']='缥缈丶信条:BAAALgAECgUJBgAAAA==.',
['羙咯']='羙咯强盗:BAAALgAECgEJAQAAAA==.',
['肉龙']='肉龙:BAAALgAECgEJAQAAAA==.',
['肥宅']='肥宅快乐战:BAAALgADCgUJBQAAAA==.肥宅快乐萨:BAAALgADCgEJAQAAAA==.',
['胖嘟']='胖嘟嘟右卫门:BAAALgAECgcJCAAAAA==.',
['胖子']='胖子你在那:BAAALgAECgQJBAAAAA==.',
['胡撸']='胡撸娃:BAAALgAECgYJCAAAAA==.',
['胡校']='胡校长:BAAALgAFFAQJAQAAAA==.',
['胡椒']='胡椒一族:BAAALgAFFAEJAQAAAA==.',
['腕豪']='腕豪:BAAALgADCgEJAQAAAA==.',
['艾莉']='艾莉娜乔斯达:BAAALgAECgYJBwAAAA==.',
['花开']='花开的那年:BAAALgAECgMJAwAAAA==.',
['花无']='花无痕:BAAALgADCgMJAwABLgAECgcJBwAIAAAAAA==.',
['花重']='花重语:BAAALgAECgcJBwAAAA==.',
['芽丶']='芽丶萸远:BAAALgAECgQJCgAAAA==.',
['若水']='若水伊人:BAAALgADCgQJBAAAAA==.',
['茉莉']='茉莉倾花香:BAAALgAECgEJAQAAAA==.',
['莉娜']='莉娜因巴斯:BAAALgAECgUJDwAAAA==.',
['莎特']='莎特拉:BAAALgAECgQJBAAAAA==.',
['莫丶']='莫丶小寒:BAAALgAFFAMJAwAAAA==.',
['莫问']='莫问丶前途:BAAALgADCgYJCAAAAA==.',
['莱埃']='莱埃泽尔:BAAALgAECgEJAQAAAA==.',
['萝卜']='萝卜:BAACLgAFFH8NAAIQAAQJ9hhTFwBsAQAQAAQJ9hhTFwBsAQAuAAQKfxwAAhAACAnuIosoANACABAACAnuIosoANACAAAA.萝卜术:BAAALgADCgUJBgAAAA==.',
['萨兰']='萨兰蒂尔:BAAALgADCgYJBgAAAA==.',
['萨菲']='萨菲拉:BAAALgAECgYJCQAAAA==.',
['落魄']='落魄山陈十一:BAAALgAECgQJBQAAAA==.',
['蓝冰']='蓝冰:BAABLgAFFH8HAAIHAAMJUCaRCQBQAQAHAAMJUCaRCQBQAQABLgAFFAQJBwAWAMciAA==.',
['蓝色']='蓝色心情:BAAALgADCgEJAgAAAA==.',
['蕾球']='蕾球:BAAALgAECgUJCAAAAA==.',
['虎虎']='虎虎僧:BAABLgAFFH8aAAIVAAYJcxuxAQD2AQAVAAYJcxuxAQD2AQAAAA==.',
['虚弱']='虚弱的卡洛斯:BAAALgAECgYJBwAAAA==.',
['蚜蠛']='蚜蠛蝶:BAABLgAFFH8IAAIcAAMJ1BeHDgD1AAAcAAMJ1BeHDgD1AAAAAA==.',
['蛋刀']='蛋刀猎手:BAAALgAECgQJBAAAAA==.',
['蜂蜜']='蜂蜜柚子茶:BAAALgADCgUJBQAAAA==.',
['蜜豆']='蜜豆冰山:BAAALgAECgYJCQAAAA==.',
['血羽']='血羽殇:BAAALgAECgIJAQAAAA==.',
['血色']='血色追猎者:BAAALgAFFAEJAQAAAA==.',
['血骑']='血骑士:BAAALgAECgEJAQAAAA==.',
['裤头']='裤头男:BAAALgAECgIJAgAAAA==.',
['西琼']='西琼艾儿:BAAALgAECgEJAQAAAA==.',
['西装']='西装暴徒:BAAALgAECgYJBgAAAA==.',
['见信']='见信而寄:BAAALgAECgEJAQAAAA==.',
['譕莜']='譕莜寤慮:BAAALgAECgUJBQAAAA==.',
['记忆']='记忆如殇:BAAALgADCgIJAgAAAA==.',
['谷二']='谷二蛋:BAABLgAFFH8FAAIGAAIJux0cBwDDAAAGAAIJux0cBwDDAAAAAA==.',
['豆孒']='豆孒包包:BAAALgAECgcJDgABLgAFFAcJHAAQAKwbAA==.',
['豆豆']='豆豆的豆豆:BAAALgAECgcJBwABLgAFFAUJEAAQAAwaAA==.',
['贝尔']='贝尔格莱德:BAAALgAECgEJAQAAAA==.',
['贝贝']='贝贝的宝宝:BAAALgADCgEJAQAAAA==.',
['超大']='超大杯乌龙:BAAALgADCgUJBQAAAA==.',
['蹲马']='蹲马步的猫:BAAALgAFFAEJAQAAAA==.',
['辉歌']='辉歌:BAAALgAECgUJBQAAAA==.',
['辉煌']='辉煌:BAAALgADCgMJAwAAAA==.',
['辛依']='辛依晨:BAAALgAECgYJBwAAAA==.',
['达克']='达克塞斯:BAAALgAECgYJBgAAAA==.',
['达闻']='达闻西:BAAALgAECgQJBAAAAA==.',
['还是']='还是打鸡:BAAALgAECgYJBgAAAA==.',
['迪奇']='迪奇米亚:BAAALgAFFAMJBAAAAA==.',
['迷儿']='迷儿迷儿丶:BAABLgAFFH8LAAIUAAQJMyGQCQB/AQAUAAQJMyGQCQB/AQAAAA==.',
['逍遥']='逍遥闲人:BAABLgAFFH8FAAIZAAMJ1xf2DQC4AAAZAAMJ1xf2DQC4AAABLgAFFAMJBQADAMwIAA==.',
['部落']='部落之父:BAAALgADCgEJAQAAAA==.',
['酱油']='酱油泰迪熊:BAAALgADCgMJAwAAAA==.',
['酸萝']='酸萝卜別吃:BAAALgAECgUJCgAAAA==.',
['醉东']='醉东风:BAAALgAECgEJAQAAAA==.',
['醋溜']='醋溜花生:BAABLgAFFH8JAAMdAAQJrxu7BQAnAQAdAAQJjgi7BQAnAQAVAAMJnR9LDgARAQAAAA==.',
['里巧']='里巧儿:BAABLgAECn8ZAAMGAAYJDQ+xMQBGAQAGAAYJDQ+xMQBGAQAFAAEJVwF29QAZAAAAAA==.',
['钦天']='钦天监监正:BAAALgAECgkJEwAAAA==.',
['铁灬']='铁灬山:BAAALgAECgMJAwAAAA==.',
['铅笔']='铅笔:BAAALgAECgcJCQAAAA==.',
['长夜']='长夜无荒:BAAALgAECgcJEAAAAA==.长夜难明:BAAALgADCgEJAQAAAA==.',
['闰土']='闰土丶逐日者:BAAALgAECgIJAwAAAA==.',
['阿飛']='阿飛的小蝴蝶:BAAALgAECgIJAgAAAA==.',
['随心']='随心魔变:BAAALgAECgUJBgAAAA==.',
['雨雪']='雨雪霁霏:BAAALgAECgIJAwAAAA==.',
['雪域']='雪域夜鹰:BAAALgAECgcJDAAAAA==.',
['零五']='零五贰五:BAAALgAECgYJDwAAAA==.',
['雷劈']='雷劈黄瓜:BAAALgAECgYJDAAAAA==.',
['雷尔']='雷尔萨斯:BAAALgADCgcJDQABLgAECgMJAwAIAAAAAA==.',
['霏雪']='霏雪葬稥魂:BAAALgAECgUJBQAAAA==.',
['霜玉']='霜玉:BAAALgAECgYJCQAAAA==.',
['霜的']='霜的独奏:BAACLgAFFH8HAAIJAAQJRxk4JwD6AAAJAAQJRxk4JwD6AAAuAAQKfxUAAgkACAmhIRYZAOYCAAkACAmhIRYZAOYCAAAA.',
['霜落']='霜落漫天:BAAALgAECgQJBAAAAA==.',
['青沐']='青沐子衿:BAAALgAECgQJBAAAAA==.',
['非职']='非职业奶妈:BAAALgAECgEJAQAAAA==.',
['顾诸']='顾诸紫笋:BAAALgADCgEJAQAAAA==.',
['風勁']='風勁角弓鳴:BAAALgAECgcJEQAAAA==.',
['风暴']='风暴雷恩:BAAALgAECgYJBgAAAA==.',
['风起']='风起天南:BAAALgAFFAEJAQAAAA==.',
['飛儿']='飛儿之追随者:BAAALgAECgcJDQAAAA==.',
['飛舞']='飛舞流髿:BAAALgADCgQJBAAAAA==.',
['飞补']='飞补肉:BAECLgAFFH8RAAIHAAQJFiZWAQC4AQAHAAQJFiZWAQC4AQAuAAQKfyAAAwcACAk1JJUCAEYDAAcACAk1JJUCAEYDAAEAAQnyFAJeAEIAAAAA.',
['饺子']='饺子一号:BAAALgAECgkJCQAAAA==.',
['香腮']='香腮暗血:BAAALgAECgEJAQAAAA==.香腮血:BAAALgAECgEJAQAAAA==.',
['鬼才']='鬼才奉孝:BAAALgAECgYJCQAAAA==.',
['鬼鬼']='鬼鬼月:BAAALgAECgIJAgAAAA==.',
['魂歌']='魂歌丶:BAAALgAECgQJBAAAAA==.',
['魔血']='魔血染青天:BAAALgADCgEJAQAAAA==.',
['鱼丸']='鱼丸丸:BAAALgADCgcJDAAAAA==.',
['鱼幼']='鱼幼微:BAAALgADCggJCAAAAA==.',
['鱼生']='鱼生:BAAALgAECgYJBgAAAA==.',
['鱼缸']='鱼缸里的猫:BAAALgADCgcJBwAAAA==.',
['鱼脸']='鱼脸:BAAALgAECgcJBwAAAA==.',
['黑冰']='黑冰:BAABLgAFFH8GAAIFAAIJlSNQIADSAAAFAAIJlSNQIADSAAABLgAFFAQJBwAWAMciAA==.',
['黑暗']='黑暗明火:BAAALgAECggJDQAAAA==.',
['黑钥']='黑钥王:BAAALgAECgEJAgAAAA==.',
['龙息']='龙息张三:BAAALgAECgcJDAAAAA==.',
['龙门']='龙门镖局:BAAALgAECgEJAQAAAA==.',
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
