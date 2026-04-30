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

local lookup = {'Shaman-Restoration','DemonHunter-Devourer','Paladin-Retribution','DeathKnight-Unholy','Warrior-Arms','Warrior-Fury','DeathKnight-Blood','Paladin-Holy','Warrior-Protection','Unknown-Unknown','Mage-Frost','Mage-Arcane','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Priest-Shadow','Warlock-Demonology','Warlock-Destruction','Druid-Balance','Priest-Holy',}
local provider = {region='CN',realm='玛瑟里顿',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alzard:BAABLgAECn8jAAIBAAgJZh0TBQAWAgABAAgJZh0TBQAWAgAAAA==.',
Bf='Bfate:BAAALgAECgUJCAAAAA==.',
Cl='Clap:BAAALgAECgYJEQAAAA==.',
Cm='Cmbb:BAAALgAECgEJAQAAAA==.',
Co='Cocodou:BAAALgADCgYJBgAAAA==.',
Da='Dari:BAAALgADCgYJBgAAAA==.',
Du='Dualipa:BAABLgAECn8UAAICAAgJqhRhOAATAgACAAgJqhRhOAATAgAAAA==.',
Fo='Foliok:BAAALgAECgMJBAAAAA==.',
Go='Goél:BAAALgADCgcJDAAAAA==.',
Gr='Gracey:BAAALgAECgkJCQAAAA==.',
Gu='Guillotine:BAAALgAECgMJAwAAAA==.Gump:BAAALgAECgEJAQAAAA==.',
In='Infiltration:BAAALgAFFAEJAQAAAA==.',
Is='Ishtar:BAAALgAECgYJBgAAAA==.',
Je='Jeanandrew:BAAALgAECgIJAwAAAA==.',
Jo='Jokey:BAAALgADCgMJAwAAAA==.',
Le='Lemon:BAAALgAFFAIJBAAAAA==.',
Li='Linda:BAAALgAECgYJBwAAAA==.',
Ma='Martin:BAABLgAFFH8LAAIDAAQJTg1tFgD4AAADAAQJTg1tFgD4AAAAAA==.',
Mo='Momosr:BAAALgADCgcJBwAAAA==.',
Na='Nanaga:BAABLgAECn8eAAIEAAkJKxqrJQCmAgAEAAkJKxqrJQCmAgAAAA==.',
Sl='Slyb:BAAALgAECgcJDAAAAA==.',
Su='Sun:BAAALgADCgYJBgAAAA==.',
Tk='Tklord:BAAALgAECgcJBwAAAA==.',
Ty='Tyland:BAAALgAECgQJBAAAAA==.',
Va='Vampiream:BAAALgAFFAQJBAAAAA==.',
['Wé']='Wéissmel:BAAALgAECgcJCwAAAA==.',
Yh='Yharim:BAAALgAFFAIJAwAAAA==.',
['一双']='一双拖鞋:BAAALgAECgEJAQAAAA==.',
['不是']='不是我不小心:BAABLgAECn8XAAMFAAYJbRXIDwCfAQAFAAYJbRXIDwCfAQAGAAUJew+ZFAD5AAAAAA==.',
['专踹']='专踹瘸子好腿:BAACLgAFFH8HAAIDAAMJww4pFwD0AAADAAMJww4pFwD0AAAuAAQKfxgAAgMABwmLGbVfAMUBAAMABwmLGbVfAMUBAAAA.',
['两学']='两学一坐:BAABLgAFFH8FAAIEAAIJ2xjlNwCrAAAEAAIJ2xjlNwCrAAAAAA==.',
['两袖']='两袖青蛇:BAAALgAECgEJAgAAAA==.',
['丶路']='丶路子野:BAACLgAFFH8GAAIHAAIJBA+yBgCMAAAHAAIJBA+yBgCMAAAuAAQKfyYAAgcACAkfF6oSAOIBAAcACAkfF6oSAOIBAAAA.',
['亲爱']='亲爱的鬼鬼:BAAALgAECgYJBgAAAA==.',
['今夕']='今夕明月:BAAALgAECgcJCgAAAA==.',
['伴随']='伴随着你:BAABLgAFFH8NAAMIAAQJhyamAgDIAQAIAAQJhyamAgDIAQADAAEJ6Ay1NABOAAAAAA==.',
['何家']='何家欣:BAAALgADCgUJBQAAAA==.',
['俏狸']='俏狸花:BAAALgADCgYJBgAAAA==.',
['修罗']='修罗地狱:BAAALgAECgcJCwAAAA==.',
['假笑']='假笑扮从容:BAAALgAECgYJEAAAAA==.',
['冰霜']='冰霜小鲤鱼:BAAALgADCgkJBAAAAA==.',
['凌寒']='凌寒祭歌:BAAALgAECgcJBgAAAA==.',
['别再']='别再削噜:BAAALgAECgEJAQAAAA==.',
['功夫']='功夫海牛哞哞:BAAALgAECgYJCwAAAA==.',
['动感']='动感大帅锅:BAABLgAECn8XAAMGAAYJbguzWwBAAQAGAAYJiwqzWwBAAQAJAAEJWgtRRwAxAAAAAA==.动感大恶魔:BAAALgAECgYJCAAAAA==.',
['努力']='努力的饺子:BAAALgAECgkJCQAAAA==.',
['北京']='北京豌豆黄:BAAALgAECgEJAQAAAA==.',
['南玻']='南玻万:BAAALgADCgMJAwAAAA==.',
['原初']='原初祈求着:BAAALgAFFAIJAgAAAA==.',
['又要']='又要改名字:BAAALgADCgYJBgAAAA==.',
['史昂']='史昂:BAAALgAECgUJBQAAAA==.',
['叶流']='叶流云:BAAALgAECgEJAQAAAA==.',
['吃琪']='吃琪琪吧:BAAALgAECgMJAwAAAA==.',
['吉祥']='吉祥:BAAALgAECgYJBwABLgAFFAIJAgAKAAAAAA==.',
['呀吼']='呀吼:BAAALgAECgYJCwAAAA==.',
['咸味']='咸味生活:BAAALgAECgEJAgAAAA==.',
['哎呀']='哎呀抽筋啦:BAAALgAECgMJAwAAAA==.',
['啵灵']='啵灵啵灵的:BAAALgAECgYJBgAAAA==.',
['喏喏']='喏喏:BAAALgAECgYJCwAAAA==.',
['圣休']='圣休亚瑞:BAAALgAECgYJBwAAAA==.',
['堕落']='堕落老黄牛:BAABLgAECn8VAAMFAAYJ4wv9FQBOAQAFAAYJ4wv9FQBOAQAGAAYJ5wQ5ZgAaAQAAAA==.',
['夜影']='夜影之刺:BAAALgAFFAIJAgAAAA==.夜影之歌:BAAALgAECgcJBwAAAA==.夜影之谕:BAAALgAECgYJBgAAAA==.',
['夜色']='夜色中变态:BAAALgAECgMJAwAAAA==.',
['大家']='大家都跑开:BAAALgAFFAUJBAAAAA==.',
['大小']='大小丸子:BAAALgAECgMJAwAAAA==.',
['大懒']='大懒子:BAABLgAFFH8NAAMLAAQJeyQvEwB/AQALAAQJCBsvEwB/AQAMAAMJlCUNAQB2AAAAAA==.',
['大风']='大风车崴脚:BAAALgAECgcJCQAAAA==.',
['天涯']='天涯冷血:BAABLgAFFH8GAAIFAAMJfRPBAwAHAQAFAAMJfRPBAwAHAQAAAA==.天涯若风:BAACLgAFFH8GAAMNAAIJqAs6EACVAAANAAIJIQs6EACVAAAOAAIJzQTLIQCHAAAuAAQKfyMAAw4ACAlOGZIcAEACAA4ACAk5GJIcAEACAA0ABAmAC2cqALcAAAAA.',
['奎师']='奎师那:BAABLgAECn8hAAIDAAgJUyLNEAAJAwADAAgJUyLNEAAJAwAAAA==.',
['奥古']='奥古西斯:BAAALgAECgEJAQAAAA==.',
['奶不']='奶不住了:BAAALgAECgQJBwAAAA==.',
['孤月']='孤月残心:BAABLgAECn8YAAIEAAgJ4xnnSgASAgAEAAgJ4xnnSgASAgAAAA==.',
['定仙']='定仙游丶:BAAALgAECgMJAwAAAA==.',
['小头']='小头:BAAALgADCgcJBwAAAA==.',
['小幸']='小幸运丷:BAAALgAECgYJDQAAAA==.小幸运灬筱悠:BAAALgAFFAIJBAAAAA==.小幸运灬筱筱:BAAALgAFFAIJAwAAAA==.',
['小方']='小方子:BAABLgAFFH8FAAIEAAUJ8woTCwB7AQAEAAUJ8woTCwB7AQAAAA==.',
['小猪']='小猪的悲伤:BAAALgADCgUJBQAAAA==.',
['小黑']='小黑三十五号:BAABLgAFFH8FAAMOAAQJmxX0KwBDAAAOAAEJIxH0KwBDAAANAAMJGBcAAAAAAAAAAA==.',
['尐柒']='尐柒柒:BAAALgAECgEJAgAAAA==.',
['希尔']='希尔塔萨:BAAALgAECgcJDAABLgAFFAIJAgAKAAAAAA==.',
['幸福']='幸福的小白菜:BAAALgAECgEJAQAAAA==.',
['开心']='开心的西瓜:BAAALgAECgUJBwAAAA==.',
['弹道']='弹道亦是道:BAAALgAECgcJDAAAAA==.',
['影帝']='影帝一号:BAAALgAFFAQJBAAAAA==.',
['彼岸']='彼岸花事了:BAAALgAECgEJAgAAAA==.',
['往后']='往后丶余生:BAAALgAECgYJDQAAAA==.',
['德克']='德克撒斯:BAAALgAECgkJCQAAAA==.',
['心灵']='心灵痛啊痛:BAAALgAECgUJBQAAAA==.',
['恒老']='恒老板:BAACLgAFFH8NAAIEAAQJJxZiGABDAQAEAAQJJxZiGABDAQAuAAQKfxcAAgQABgkVGzh0AJ4BAAQABgkVGzh0AJ4BAAAA.',
['恶梦']='恶梦猎手:BAAALgAECgIJAwAAAA==.',
['感动']='感动常在:BAAALgAECgEJAQAAAA==.',
['执翻']='执翻剂:BAAALgADCgEJAQAAAA==.',
['把你']='把你鼠標拿開:BAAALgAFFAIJAgAAAA==.',
['抓两']='抓两咕咕:BAAALgADCgYJBgAAAA==.',
['抓鸟']='抓鸟德:BAAALgADCgYJBgAAAA==.',
['抱头']='抱头鼠窜:BAAALgAECgUJCAAAAA==.',
['摩根']='摩根士丹利:BAAALgAECgMJAwAAAA==.',
['无数']='无数个小提莫:BAAALgAECgUJBQAAAA==.',
['是牛']='是牛不是熊:BAAALgADCgUJBQAAAA==.',
['暗之']='暗之恶魔:BAAALgAECgYJBgAAAA==.暗之风暴:BAAALgAECgYJBgAAAA==.',
['有什']='有什么用咩:BAAALgAECggJBgAAAA==.',
['杏仁']='杏仁豆腐:BAAALgADCgEJAQAAAA==.',
['果子']='果子狸的悲伤:BAAALgAECgMJAwAAAA==.',
['梓冰']='梓冰:BAAALgADCgYJCAAAAA==.',
['森岛']='森岛遥:BAAALgAECgQJBwAAAA==.',
['橘子']='橘子汽水:BAABLgAECn8cAAILAAYJ1SCRWQAtAgALAAYJ1SCRWQAtAgAAAA==.',
['武器']='武器战仕:BAAALgAECgYJBwAAAA==.',
['死者']='死者意志:BAABLgAECn8XAAIEAAYJ+B9LRgAhAgAEAAYJ+B9LRgAhAgAAAA==.',
['毛毛']='毛毛球:BAAALgAFFAQJAQABLgAFFAUJKgAPAP8kAA==.',
['没弓']='没弓的饲养员:BAAALgAECgEJAQAAAA==.',
['洛洛']='洛洛宝贝:BAAALgAECgYJDwAAAA==.',
['浴血']='浴血奋戦:BAAALgAECgEJAQAAAA==.',
['灭龙']='灭龙:BAAALgAFFAIJAgAAAA==.',
['炎帝']='炎帝:BAAALgAECgIJAgAAAA==.',
['炎爆']='炎爆术:BAAALgAECgYJBgAAAA==.',
['烧卖']='烧卖姐姐:BAAALgAECggJEAAAAA==.',
['热情']='热情随雨:BAAALgAECgYJBwAAAA==.',
['猫不']='猫不会微笑:BAAALgAECgYJDQAAAA==.',
['玥垚']='玥垚:BAAALgAECgcJDAAAAA==.',
['瑞克']='瑞克十代:BAAALgAECgEJAQAAAA==.',
['瑞淇']='瑞淇曼:BAAALgAECgcJDAAAAA==.',
['盛夏']='盛夏有晴空:BAAALgAECgEJAgAAAA==.',
['眼不']='眼不见为净:BAAALgADCgcJBwAAAA==.',
['破碎']='破碎祭歌:BAAALgAFFAMJAwAAAA==.',
['破补']='破补丁:BAAALgAECgkJBQAAAA==.',
['破誓']='破誓黑骑:BAAALgAECgUJCQAAAA==.',
['祎蝶']='祎蝶血棘:BAAALgAECgQJBAAAAA==.',
['秋月']='秋月寒刀:BAAALgAECgUJBwAAAA==.',
['秋窗']='秋窗风雨夕:BAACLgAFFH8RAAIQAAcJWCM9AAC8AgAQAAcJWCM9AAC8AgAuAAQKfxoAAhAACAnoJEYDAGwDABAACAnoJEYDAGwDAAAA.',
['筱健']='筱健健丶:BAAALgADCgMJAwAAAA==.',
['米乐']='米乐星雨:BAAALgAFFAIJBAAAAA==.',
['细雨']='细雨无声:BAAALgAFFAEJAQAAAA==.',
['翠玉']='翠玉绿:BAABLgAECn8UAAMRAAcJChgQaQCRAQARAAYJChgQaQCRAQASAAIJSQI3WgBgAAAAAA==.',
['老啪']='老啪:BAAALgAECgEJAQAAAA==.',
['老婆']='老婆返咗郷下:BAABLgAECn8VAAINAAYJnhDnSgCIAQANAAYJnhDnSgCIAQAAAA==.',
['臨水']='臨水照花人:BAAALgAECgEJAQAAAA==.',
['艾瑞']='艾瑞拉:BAAALgADCgYJBgAAAA==.',
['苜蓿']='苜蓿岚杉:BAAALgADCgMJAwAAAA==.',
['茶香']='茶香:BAAALgAECgYJBwAAAA==.',
['蓝熯']='蓝熯:BAAALgAECgEJAgAAAA==.',
['蓝色']='蓝色风暴:BAAALgADCgUJBQAAAA==.',
['蕾姆']='蕾姆:BAAALgAECgUJCAABLgAECgYJBwAKAAAAAA==.',
['西柚']='西柚汁:BAAALgAECgIJAgAAAA==.',
['豆沙']='豆沙包:BAAALgAECggJDwAAAA==.',
['赤怜']='赤怜:BAAALgAECgMJAwAAAA==.',
['超级']='超级奶牛:BAABLgAECn8hAAITAAgJ6hrJEQCMAgATAAgJ6hrJEQCMAgAAAA==.',
['越狱']='越狱丶:BAAALgAECgkJEQABLgAFFAQJBAAKAAAAAA==.越狱哈提:BAAALgAECgkJDAAAAA==.',
['逗豆']='逗豆:BAAALgAECgEJAQAAAA==.',
['那时']='那时的情歌:BAAALgAECgcJBwAAAA==.',
['那由']='那由他:BAABLgAFFH8FAAILAAIJ3RFhPACzAAALAAIJ3RFhPACzAAABLgAFFAQJDQAIAIcmAA==.',
['野居']='野居大王:BAAALgAFFAEJAQAAAA==.',
['陈三']='陈三竖:BAAALgAECgQJBQAAAA==.',
['陪我']='陪我看日出:BAAALgAECgUJCAAAAA==.',
['随风']='随风落叶:BAAALgAECgQJCAAAAA==.',
['隐姓']='隐姓埋名:BAAALgAECgQJBAAAAA==.',
['隔壁']='隔壁小沈:BAAALgAFFAEJAQABLgAFFAUJCQAUAHomAA==.',
['雲天']='雲天:BAAALgAECgUJBgAAAA==.',
['雷霆']='雷霆斩:BAAALgAECgQJBQAAAA==.',
['面对']='面对疾风把:BAAALgADCgUJBQAAAA==.',
['顾叶']='顾叶寒丶:BAAALgADCgMJAwAAAA==.',
['顾点']='顾点点:BAAALgAECgcJDAAAAA==.',
['風之']='風之天際:BAAALgAECgQJBAAAAA==.',
['风中']='风中的一匹狼:BAAALgAECgEJAQAAAA==.',
['风间']='风间翼:BAAALgAECgIJAQAAAA==.',
['风魔']='风魔翼:BAAALgAECgkJCgAAAA==.',
['骑勒']='骑勒个士:BAAALgAECgMJBQAAAA==.',
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
