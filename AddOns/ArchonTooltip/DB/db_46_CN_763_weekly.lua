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

local lookup = {'DeathKnight-Unholy','Mage-Frost','Shaman-Elemental','Warrior-Protection','Warrior-Fury','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Devourer','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Unknown-Unknown','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','DemonHunter-Vengeance','Priest-Shadow','Rogue-Subtlety','Evoker-Preservation',}
local provider = {region='CN',realm='瑞文戴尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bo='Boa:BAAALgAECgcJDQAAAA==.',
Ca='Cafe:BAAALgAECgEJAQAAAA==.',
Ch='Chloe:BAAALgAECgMJAwAAAA==.',
La='Lanbolol:BAAALgAECgMJAwAAAA==.',
Ma='Manman:BAAALgAFFAEJAQAAAA==.',
Me='Megalosaurus:BAAALgADCgIJAgAAAA==.',
Ro='Roommy:BAAALgAECgUJBQAAAA==.',
Sb='Sbpyfan:BAACLgAFFH8FAAIBAAIJNRmBFwCqAAABAAIJNRmBFwCqAAAuAAQKfxQAAgEABgmsHJVRAP0BAAEABgmsHJVRAP0BAAAA.',
Te='Tero:BAAALgAECgYJCAAAAA==.',
Ti='Tiffanya:BAAALgADCgMJAwAAAA==.',
Vn='Vndd:BAAALgAECgYJBgAAAA==.',
['一聆']='一聆听一:BAAALgAECgYJEAAAAA==.',
['不如']='不如就熊德:BAAALgADCgYJCwAAAA==.',
['丶上']='丶上上签灬:BAAALgAECgYJAQAAAA==.',
['久木']='久木乔一:BAAALgAFFAIJBAAAAA==.',
['二中']='二中大图腾:BAAALgADCgEJAQAAAA==.',
['五竹']='五竹:BAAALgAECgEJAQAAAA==.',
['伊丽']='伊丽傻白:BAAALgAECgUJBQAAAA==.',
['伊利']='伊利亚斯菲尔:BAAALgADCgIJAgAAAA==.伊利蛋怒刃:BAAALgAECgEJAgAAAA==.',
['伊古']='伊古尼鲁:BAAALgAECgYJEQAAAA==.',
['伊泽']='伊泽瑞尔:BAAALgAECgIJAgAAAA==.',
['传说']='传说的蛋挞:BAAALgAECggJCAAAAA==.',
['你家']='你家大爷:BAAALgAECgQJBQAAAA==.',
['克洛']='克洛罗斯:BAAALgAECgMJAwAAAA==.',
['兜兜']='兜兜缺光:BAAALgADCgYJBgAAAA==.兜兜缺箭:BAAALgADCgYJBgAAAA==.兜兜缺糖:BAAALgADCgcJBwAAAA==.',
['八月']='八月未央:BAAALgAECgkJCQAAAA==.',
['六宝']='六宝烛:BAAALgAECgcJDQAAAA==.',
['再见']='再见江湖:BAAALgADCgYJBgAAAA==.',
['冯宝']='冯宝宝:BAAALgAECgIJAgAAAA==.',
['前女']='前女友:BAAALgAECgMJAwAAAA==.',
['北陂']='北陂杏花:BAAALgAECgYJEgAAAA==.',
['卖油']='卖油条:BAAALgAECgcJCAAAAA==.',
['卖煎']='卖煎饼:BAAALgAECgMJBQAAAA==.',
['卖葫']='卖葫芦:BAAALgAECgYJBwAAAA==.',
['卖饺']='卖饺子:BAAALgAECgcJCgAAAA==.',
['卖馄']='卖馄饨:BAABLgAECn8UAAICAAcJphK6wwBeAQACAAcJphK6wwBeAQAAAA==.',
['厕所']='厕所大妈:BAAALgAFFAEJAQAAAA==.',
['又见']='又见晓风残月:BAAALgAECgcJCwAAAA==.',
['受够']='受够了宝宝:BAAALgAECgEJAQAAAA==.',
['叮咚']='叮咚小鸡:BAAALgADCgIJAgAAAA==.',
['吃栆']='吃栆药丸:BAAALgAECgkJAwABLgAFFAUJBgADAAIUAA==.',
['吉按']='吉按娜:BAAALgAECgEJAQAAAA==.',
['吥吃']='吥吃香菜:BAABLgAECn8ZAAIEAAkJ+xtiBAACAwAEAAkJ+xtiBAACAwAAAA==.',
['吼吖']='吼吖呃破丶圣:BAAALgAECgEJAQAAAA==.吼吖呃破丶猎:BAAALgADCgEJAQAAAA==.',
['咖啡']='咖啡仔:BAAALgAECgEJAQAAAA==.',
['哈里']='哈里路哑:BAAALgADCgMJAwAAAA==.',
['哒咩']='哒咩:BAAALgAECgYJDQAAAA==.',
['啊鸡']='啊鸡:BAAALgAFFAIJAwAAAA==.',
['喜茶']='喜茶:BAAALgAECgYJBwAAAA==.',
['嚼到']='嚼到你昏迷:BAAALgADCgEJAgAAAA==.',
['圣光']='圣光拉面:BAAALgAECgEJAQAAAA==.',
['地爆']='地爆天星:BAAALgAFFAEJAQAAAA==.',
['基尔']='基尔达斯:BAAALgAECgYJBgAAAA==.',
['堕落']='堕落灰尽使者:BAAALgAECgIJAgAAAA==.',
['壹波']='壹波叁折:BAAALgAECgEJAQAAAA==.',
['失去']='失去的一:BAAALgAECgcJBwABLgAFFAQJDAABAPITAA==.',
['失守']='失守至飞:BAAALgADCgEJAQAAAA==.',
['好久']='好久不见:BAAALgAECgMJAwAAAA==.',
['姬無']='姬無雙:BAAALgAECgYJDgAAAA==.',
['嫣然']='嫣然:BAAALgADCgUJBQAAAA==.',
['宗像']='宗像五月:BAAALgAECgUJCQAAAA==.',
['寂寞']='寂寞撒的谎:BAAALgADCgEJAQAAAA==.',
['小姽']='小姽婳:BAAALgAECgcJCAAAAA==.',
['就差']='就差干饭了:BAABLgAECn8VAAMFAAcJfw8ORQCQAQAFAAcJfw8ORQCQAQAGAAEJwg2NRQAtAAAAAA==.',
['左手']='左手写爱:BAAALgAECgEJAgAAAA==.',
['布偶']='布偶猫:BAAALgADCgEJAQAAAA==.',
['往事']='往事如影:BAAALgADCgQJBAAAAA==.',
['徳不']='徳不怅死:BAAALgADCgcJBwAAAA==.',
['志平']='志平大官人:BAAALgAECgEJAgAAAA==.',
['忧郁']='忧郁蓝调小八:BAABLgAFFH8GAAMFAAUJGB6qAACQAQAFAAUJGB6qAACQAQAGAAEJAADoDABMAAABLgAFFAYJBwAFAJ8WAA==.',
['怒焰']='怒焰玄冰:BAAALgAECgYJBgAAAA==.',
['怪咖']='怪咖佬:BAAALgAECgIJAgAAAA==.',
['悅神']='悅神:BAAALgAFFAEJAQAAAA==.',
['我就']='我就是坐骑控:BAAALgADCgEJAQAAAA==.',
['我是']='我是你的球迷:BAAALgAECgIJAgAAAA==.我是小松鼠:BAAALgAECgEJAQAAAA==.我是烙饼:BAAALgADCgUJBQAAAA==.',
['我本']='我本无心:BAAALgAECgYJBgAAAA==.',
['扁扁']='扁扁和闹闹:BAAALgAECgEJAQAAAA==.',
['撒镘']='撒镘:BAAALgADCgMJAwAAAA==.',
['旖旎']='旖旎战妃:BAAALgAECgMJAwAAAA==.旖旎皇妃:BAAALgAECgcJBgAAAA==.',
['无限']='无限飞弹:BAAALgAECgEJAQAAAA==.',
['旷世']='旷世枭雄:BAAALgAECgMJBQAAAA==.',
['星塵']='星塵酌月:BAAALgAECgQJCwAAAA==.',
['晚安']='晚安只对你说:BAACLgAFFH8RAAMHAAUJhRBpAwBRAQAHAAUJhRBpAwBRAQAIAAIJQAEAAAAAAAAuAAQKfxgAAwcABwmAH8QQAFsCAAcABwmAH8QQAFsCAAgAAwn8FvGpALsAAAAA.',
['晨曦']='晨曦的微涼:BAAALgAECgYJBgAAAA==.',
['暮雪']='暮雪丶:BAAALgAECgYJCQAAAA==.',
['月翼']='月翼猫头鹰:BAABLgAFFH8FAAIJAAUJLReaBACiAQAJAAUJLReaBACiAQAAAA==.',
['术术']='术术五月:BAAALgADCgUJAQAAAA==.',
['朵蕾']='朵蕾汐:BAAALgADCgUJBQAAAA==.',
['李寻']='李寻歡:BAAALgAECgcJCgAAAA==.',
['来当']='来当我宝宝:BAAALgAECgEJAQAAAA==.',
['枫飘']='枫飘棂:BAACLgAFFH8HAAMKAAQJ/xi2CAAcAQAKAAQJFRe2CAAcAQALAAEJSgkyLABCAAAuAAQKfxUAAwsABwleIH8iAA8CAAsABwleIH8iAA8CAAoAAQkuGGjAAEQAAAEuAAUUBgkPAAsACR0A.',
['梅利']='梅利凯碎风:BAAALgAECgYJDwAAAA==.',
['楚楚']='楚楚是个骑士:BAAALgAECgYJBgAAAA==.',
['橙花']='橙花花:BAAALgAECgYJCQAAAA==.',
['正一']='正一扑佳:BAAALgADCgYJCQAAAA==.',
['毛就']='毛就完了:BAAALgADCgQJAwAAAA==.',
['水吻']='水吻涟漪:BAAALgAECgIJAgAAAA==.',
['沧海']='沧海无情:BAAALgAECgEJAQAAAA==.',
['浊酒']='浊酒居士:BAAALgAECgIJAwAAAA==.',
['海蓝']='海蓝蓝:BAAALgAFFAEJAQAAAA==.',
['消失']='消失叔叔:BAAALgADCgQJAgAAAA==.',
['深蓝']='深蓝忧郁:BAAALgAECgcJDAAAAA==.',
['灬奇']='灬奇迹世代灬:BAAALgAECgYJCQAAAA==.',
['灰色']='灰色夜曲:BAAALgAECgEJAQAAAA==.',
['炽翎']='炽翎筱筱:BAAALgAECgkJAQABLgAFFAYJDgAJAP8PAA==.',
['热爱']='热爱别离:BAAALgAECgMJBAAAAA==.',
['熊猫']='熊猫棒子:BAAALgAECgIJAgAAAA==.熊猫饼干:BAAALgADCgQJBAAAAA==.',
['爱飘']='爱飘零:BAAALgAECgEJAQAAAA==.',
['狗大']='狗大户:BAAALgADCgYJBgAAAA==.',
['狼里']='狼里格浪:BAAALgAECgYJCQAAAA==.',
['猛将']='猛将之首:BAAALgAECgQJBQAAAA==.',
['王老']='王老板:BAAALgAECgUJBwAAAA==.',
['瞅你']='瞅你咋滴:BAAALgADCgMJAwAAAA==.',
['破碎']='破碎星光:BAAALgAECgQJBAAAAA==.',
['神悦']='神悦:BAABLgAFFH8FAAIMAAUJ7AOgDABHAQAMAAUJ7AOgDABHAQAAAA==.',
['第二']='第二杯半价:BAAALgADCgYJBgABLgAECgEJAQANAAAAAA==.',
['純情']='純情小火雞:BAAALgAECgYJCwAAAA==.',
['红中']='红中:BAAALgAECgIJAgAAAA==.',
['红章']='红章鱼:BAAALgAECgYJDQAAAA==.',
['纳芈']='纳芈:BAABLgAECn8YAAQOAAYJFR2WEgC3AQAOAAYJFR2WEgC3AQAPAAQJnRTNEwDzAAAQAAMJJQw24ACZAAAAAA==.',
['绝对']='绝对黑人:BAAALgADCgEJAQAAAA==.',
['绝尘']='绝尘:BAAALgAECgQJBQAAAA==.',
['维秘']='维秘超模:BAAALgAECgEJAQAAAA==.',
['维维']='维维啊:BAAALgAECgYJBwAAAA==.',
['肉米']='肉米:BAABLgAECn8ZAAIRAAgJUiTuAAA5AwARAAgJUiTuAAA5AwAAAA==.',
['自在']='自在的风:BAAALgADCgEJAQAAAA==.',
['苗若']='苗若兰:BAAALgAECgcJCwAAAA==.',
['茶小']='茶小姚:BAAALgADCgYJBgAAAA==.',
['草创']='草创未就:BAAALgADCgUJBQAAAA==.',
['萌萌']='萌萌蕾:BAACLgAFFH8OAAISAAQJUxd9AgBFAQASAAQJUxd9AgBFAQAuAAQKfxgAAhIABwkfHtcRAG0CABIABwkfHtcRAG0CAAAA.',
['萨斯']='萨斯必雷:BAAALgAECgIJAQAAAA==.',
['萬径']='萬径人踪灭:BAAALgAECgEJAQAAAA==.',
['装逼']='装逼就是一砖:BAAALgAECgcJBwAAAA==.',
['西门']='西门吟雪:BAAALgADCgIJAgAAAA==.',
['角落']='角落的尘埃:BAABLgAECn8cAAITAAgJTBZVFABxAgATAAgJTBZVFABxAgAAAA==.',
['谁是']='谁是小松鼠:BAAALgADCgMJAwAAAA==.',
['贝贝']='贝贝:BAAALgADCgEJAQAAAA==.',
['败者']='败者食尘:BAAALgAECgUJBQAAAA==.',
['赫蒂']='赫蒂:BAAALgADCgUJBQAAAA==.',
['起开']='起开我有煞气:BAAALgADCgIJAgAAAA==.',
['踏光']='踏光引雷:BAAALgADCgMJAwAAAA==.',
['蹋血']='蹋血无痕:BAAALgAECgUJDQAAAA==.',
['这份']='这份爱狠心:BAAALgAFFAEJAQAAAA==.',
['进击']='进击的冰糖:BAACLgAFFH8UAAIUAAUJ5yVNAQA1AgAUAAUJ5yVNAQA1AgAuAAQKfyYAAhQACAn/JAICAFsDABQACAn/JAICAFsDAAAA.',
['逸声']='逸声:BAAALgAECgYJCwAAAA==.',
['酸萝']='酸萝卜别吃:BAAALgAFFAEJAQAAAA==.',
['鈈吃']='鈈吃香菜:BAAALgAECgkJCQAAAA==.',
['银色']='银色战车小玖:BAAALgAECgkJBgAAAA==.',
['镜影']='镜影湖光:BAABLgAECn8bAAITAAcJjxncGwAhAgATAAcJjxncGwAhAgAAAA==.',
['随缘']='随缘箭法:BAAALgAECgEJAgAAAA==.',
['露露']='露露卡洛斯:BAAALgAFFAIJAwAAAA==.',
['音柱']='音柱天元丶:BAAALgAECgYJCwAAAA==.',
['颜王']='颜王丶梼杌:BAAALgADCgcJBwAAAA==.',
['飘香']='飘香幽梦:BAAALgADCgUJBQAAAA==.',
['驱除']='驱除鞑虏:BAAALgADCgEJAgAAAA==.',
['鱼龙']='鱼龙舞夜:BAAALgAECgUJCgAAAA==.',
['麦饺']='麦饺筒:BAACLgAFFH8IAAMHAAMJwRAQCQCmAAAHAAIJxxIQCQCmAAAIAAMJGA/BLQCPAAAuAAQKfxgAAwcABgn8IHAbAOYBAAcABgn0HHAbAOYBAAgABQmKFy9wAFQBAAAA.',
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
