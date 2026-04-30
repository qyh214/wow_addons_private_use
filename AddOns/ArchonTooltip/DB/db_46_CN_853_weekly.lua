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

local lookup = {'Shaman-Restoration','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Monk-Brewmaster','Mage-Frost','Paladin-Retribution','Druid-Restoration','Druid-Guardian','Shaman-Elemental','Druid-Balance','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Paladin-Holy','Paladin-Protection','Priest-Holy',}
local provider = {region='CN',realm='金度',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Aresmars:BAAALgADCgUJBgAAAA==.',
Ba='Bareheaded:BAAALgAECgQJAgAAAA==.',
Be='Benidruid:BAAALgAECgcJDwAAAA==.Benimage:BAAALgAFFAEJAQAAAA==.Benimonk:BAAALgAECgQJBAAAAA==.Benishaman:BAABLgAECn8WAAIBAAgJaiLSAAACAwABAAgJaiLSAAACAwABLgAFFAEJAQACAAAAAA==.',
Ca='Carroth:BAAALgAECgYJDwAAAA==.',
Co='Costeafs:BAAALgAECgEJAgAAAA==.',
Fe='Fenria:BAAALgAECgYJEgAAAA==.',
Go='Goosip:BAAALgAECgcJEgAAAA==.',
Ki='Kinman:BAAALgAECgUJBQAAAA==.',
Lu='Lush:BAAALgAECgEJAQAAAA==.',
Mz='Mzero:BAAALgAECgEJAQAAAA==.',
Sh='Shark:BAAALgAECgUJBgAAAA==.',
So='Sombre:BAAALgADCgYJBgAAAA==.',
Ta='Tasse:BAAALgAECgEJAQAAAA==.',
Th='Theseue:BAAALgADCgYJBgAAAA==.',
Ze='Zea:BAAALgADCgUJBwAAAA==.',
['一个']='一个劣人:BAAALgAECgYJCQAAAA==.',
['一粒']='一粒子弹:BAAALgAECgUJBQAAAA==.',
['一零']='一零一:BAAALgAECgEJAQAAAA==.',
['上京']='上京临潢府:BAAALgAECgYJEAAAAA==.',
['专治']='专治各种不服:BAABLgAECn8XAAMDAAcJrgvNTACDAQADAAcJrgvNTACDAQAEAAMJ5wHRewBUAAAAAA==.',
['东门']='东门听雨:BAAALgAECgEJAQAAAA==.',
['丨瞳']='丨瞳橙丶:BAAALgAECgQJBwAAAA==.',
['丽丽']='丽丽俪:BAABLgAFFH8FAAIFAAIJJhAlEwCcAAAFAAIJJhAlEwCcAAAAAA==.',
['五行']='五行缺鑫:BAAALgAECgcJBwAAAA==.',
['亚莉']='亚莉安洛德:BAAALgAECgYJBgAAAA==.',
['亚薇']='亚薇薇:BAAALgAECgMJAwAAAA==.',
['人像']='人像三要素:BAAALgAECgUJBQAAAA==.',
['伊达']='伊达哥:BAAALgAECgIJAgAAAA==.',
['似是']='似是故人來:BAABLgAFFH8MAAIGAAQJwiQxAwCxAQAGAAQJwiQxAwCxAQAAAA==.',
['伽楠']='伽楠:BAAALgAECgEJAQAAAA==.',
['依旧']='依旧那个角度:BAACLgAFFH8IAAIHAAQJMx8qEwB/AQAHAAQJMx8qEwB/AQAuAAQKfx0AAgcACAntIdYWACEDAAcACAntIdYWACEDAAAA.',
['倪好']='倪好:BAAALgAECgcJDQAAAA==.',
['傾國']='傾國傾城:BAAALgAECgcJEAAAAA==.',
['光丶']='光丶:BAAALgAECgYJDgAAAA==.',
['兔兔']='兔兔的兔兔:BAAALgADCgYJCwAAAA==.',
['八不']='八不尔崩:BAAALgAECgYJCgAAAA==.',
['六月']='六月小镇:BAAALgADCgEJAQAAAA==.',
['冬瓜']='冬瓜小猎手:BAAALgAECgYJDwAAAA==.',
['冰中']='冰中飞舞:BAAALgADCgUJBQAAAA==.',
['冰帝']='冰帝剋:BAAALgAECgQJAwAAAA==.',
['冰涔']='冰涔涔:BAAALgAECgYJCwAAAA==.',
['冰的']='冰的寂寞:BAAALgAFFAEJAQAAAA==.',
['冰碴']='冰碴子:BAAALgAECgEJAQAAAA==.',
['冲鸭']='冲鸭卡比丘:BAABLgAECn8gAAIIAAgJaBciGACHAQAIAAgJaBciGACHAQAAAA==.',
['凡圣']='凡圣:BAAALgAECgYJBgAAAA==.',
['刻希']='刻希亚:BAAALgAECgEJAQAAAA==.',
['劳伦']='劳伦斯:BAAALgAECgYJBwAAAA==.',
['勒布']='勒布朗詹奉先:BAAALgAECgIJAgAAAA==.',
['原味']='原味食物:BAAALgAECgYJBgAAAA==.',
['双刀']='双刀小游子:BAAALgADCgkJCgAAAA==.',
['取名']='取名要随机:BAAALgAECgYJCgAAAA==.',
['叫米']='叫米幺幺零:BAAALgAECgYJCAAAAA==.',
['可乐']='可乐不加冰丶:BAAALgAFFAIJAwABLgAFFAYJFwAIAN0fAA==.',
['吥會']='吥會訫動:BAAALgADCgQJBAAAAA==.',
['呆毛']='呆毛大魔王:BAAALgAECgYJCQAAAA==.',
['呆狗']='呆狗的灞灞:BAAALgAECgMJAwAAAA==.',
['呜啦']='呜啦啦:BAAALgADCgMJAwAAAA==.',
['咬否']='咬否:BAAALgAECgEJAQAAAA==.',
['哈士']='哈士奇:BAAALgAECgYJBwAAAA==.',
['哈里']='哈里撕:BAAALgADCgYJBgAAAA==.',
['唔知']='唔知小旭:BAAALgAECgUJBwAAAA==.',
['嗜血']='嗜血丹:BAAALgAECgMJAwAAAA==.嗜血子爵:BAAALgAECgEJAQAAAA==.',
['嘟嘟']='嘟嘟猫头鹰:BAABLgAECn8UAAMJAAcJtQozYgArAQAJAAcJtQozYgArAQAKAAcJpA7BFQAWAQAAAA==.',
['嘿小']='嘿小胖:BAAALgAECgEJAQAAAA==.',
['嘿胖']='嘿胖:BAAALgAECgIJAgAAAA==.',
['囡娃']='囡娃娃灬:BAAALgAECgYJCQAAAA==.',
['圆月']='圆月弯刀丁鹏:BAAALgAECgYJBwAAAA==.',
['圣光']='圣光胜于打码:BAAALgADCgQJBAAAAA==.',
['圣珈']='圣珈堂:BAABLgAECn8fAAIIAAcJoCGXJwCHAgAIAAcJoCGXJwCHAgAAAA==.',
['坏壊']='坏壊灬孩孓气:BAABLgAECn8UAAILAAkJwABCcwB1AAALAAkJwABCcwB1AAAAAA==.',
['垚铭']='垚铭:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落之仭:BAAALgAECgcJBwAAAA==.',
['天宇']='天宇法:BAAALgAECgUJBgAAAA==.天宇牧:BAAALgAECgIJAgAAAA==.天宇龙:BAAALgADCgcJBwAAAA==.',
['天贞']='天贞:BAAALgAECgMJAwAAAA==.',
['太子']='太子俊:BAAALgADCgcJBwAAAA==.',
['夶丶']='夶丶洣:BAAALgAECgEJAQAAAA==.',
['奶似']='奶似奶非奶:BAAALgADCgYJBgAAAA==.',
['她永']='她永远是第一:BAAALgAECgIJAgAAAA==.',
['好运']='好运奶妈:BAAALgAECgcJDAAAAA==.',
['宇宙']='宇宙小章鱼:BAAALgAECgEJAQAAAA==.',
['守备']='守备官:BAAALgAECgYJCgAAAA==.',
['富冈']='富冈义勇:BAAALgAECgcJCAAAAA==.',
['寒冰']='寒冰射手艾希:BAAALgAECgUJBQAAAA==.',
['小兵']='小兵一零四:BAAALgAECgcJCgAAAA==.',
['小小']='小小爱豆豆:BAAALgAECgIJAgAAAA==.',
['尐脚']='尐脚亂踢:BAABLgAFFH8MAAIHAAQJvA8rHABaAQAHAAQJvA8rHABaAQAAAA==.',
['就打']='就打德丶:BAAALgAECgYJCwAAAA==.',
['就是']='就是个干:BAAALgAECgYJCgAAAA==.就是哐哐抽:BAAALgAFFAMJAwAAAA==.就是嗤嗤刨:BAAALgAFFAQJBAAAAA==.就是砰砰槌:BAAALgAECgkJCQAAAA==.就是铛铛敲:BAAALgAFFAQJBAAAAA==.',
['岁月']='岁月丨:BAAALgAFFAIJAwAAAA==.',
['帅麒']='帅麒:BAAALgAECgcJBwAAAA==.',
['帕拉']='帕拉丁:BAAALgAECgYJDAAAAA==.',
['广智']='广智:BAAALgAECgMJAwAAAA==.',
['弹跳']='弹跳甲鱼汤:BAAALgAFFAMJBAAAAA==.',
['徒手']='徒手拆高达丶:BAAALgADCgYJBgAAAA==.',
['思念']='思念的人哪:BAAALgADCgEJAQAAAA==.',
['恋人']='恋人炉丶:BAAALgAECgcJEAAAAA==.',
['恐怖']='恐怖的红鱼:BAAALgAECgEJAQAAAA==.',
['恐惧']='恐惧你怕了吗:BAAALgADCgUJBQAAAA==.',
['愿此']='愿此刻永恒:BAAALgAECgYJBwAAAA==.',
['折磨']='折磨:BAAALgAECgEJAQAAAA==.',
['抠脚']='抠脚大汉:BAAALgAECgUJBAAAAA==.',
['敌棱']='敌棱道长:BAAALgADCgYJBgAAAA==.',
['教父']='教父:BAAALgAECgUJCQAAAA==.',
['文总']='文总:BAABLgAFFH8NAAIMAAUJmSOcAQAGAgAMAAUJmSOcAQAGAgAAAA==.',
['斯卡']='斯卡蒂:BAABLgAFFH8IAAINAAQJrxGiCwAyAQANAAQJrxGiCwAyAQAAAA==.',
['无形']='无形丶:BAAALgAECgQJBQAAAA==.',
['无锁']='无锁:BAAALgAECgYJDwAAAA==.',
['旭光']='旭光:BAAALgAECgYJCAAAAA==.',
['时空']='时空妖灵:BAAALgAECgQJBAAAAA==.',
['星缘']='星缘影子:BAAALgAECgQJBAAAAA==.星缘梦魇:BAAALgAECgQJCAAAAA==.',
['昨夜']='昨夜小楼东风:BAAALgAECgYJBgAAAA==.',
['是梦']='是梦里啊一:BAABLgAECn8VAAMOAAkJbR1JCgAaAgAPAAkJIhnnHACoAgAOAAcJzhxJCgAaAgAAAA==.是梦里啊二:BAAALgAECgkJCwAAAA==.',
['普通']='普通的冰蒂凯:BAAALgAECgYJBgAAAA==.',
['景甜']='景甜:BAAALgAECgEJAQAAAA==.',
['暖宝']='暖宝珩阳:BAAALgAFFAIJBAAAAA==.',
['曓轌']='曓轌風櫊铜须:BAAALgAECgEJAQAAAA==.',
['月影']='月影追風:BAAALgAECgMJBAAAAA==.',
['月无']='月无泪:BAAALgAECgYJCQAAAA==.',
['月色']='月色归来:BAAALgAECgYJCQAAAA==.',
['有无']='有无敌我怕啥:BAAALgAECgIJAQAAAA==.',
['李寻']='李寻歡:BAAALgAFFAIJAgAAAA==.',
['李思']='李思思:BAAALgAFFAQJBAABLgAFFAUJAQACAAAAAA==.',
['来自']='来自海克泰尔:BAABLgAFFH8GAAIQAAQJnB6iAQBuAQAQAAQJnB6iAQBuAQAAAA==.',
['极饿']='极饿小栗帽:BAAALgAECgYJBgAAAA==.',
['柳眠']='柳眠棠丶:BAAALgAECgcJBwAAAA==.',
['柳若']='柳若烟:BAAALgADCgQJBAAAAA==.',
['椅剑']='椅剑撒旦:BAAALgAECgQJCgAAAA==.',
['楠丁']='楠丁格尔:BAACLgAFFH8IAAMRAAQJFRyKDAAVAQARAAMJAh2KDAAVAQAIAAEJiw7aMwBPAAAuAAQKfxwAAxEACAkdFygMAJ4BABEACAkdFygMAJ4BAAgAAwkQEA70AKkAAAAA.',
['橘子']='橘子皮:BAAALgADCgIJAgAAAA==.',
['歩行']='歩行上天镗:BAAALgAECgEJAQAAAA==.',
['残梦']='残梦丨清墩墩:BAAALgAECgQJBAAAAA==.',
['毛发']='毛发旺盛:BAAALgAFFAQJBAAAAA==.',
['毛毛']='毛毛爱娜娜:BAAALgAECgQJBAAAAA==.',
['水中']='水中飞舞:BAAALgAECgcJEgAAAA==.',
['沃尔']='沃尔皮:BAAALgADCgMJAwAAAA==.',
['沉默']='沉默:BAAALgADCgUJBQAAAA==.',
['沪爷']='沪爷冲击丶:BAAALgAECgYJBgAAAA==.',
['泡泡']='泡泡骑屮:BAAALgAECgYJBgAAAA==.',
['洛丹']='洛丹伦勇士:BAAALgAECgYJDAAAAA==.',
['洛昭']='洛昭言:BAABLgAFFH8FAAIHAAUJBBk+CADgAQAHAAUJBBk+CADgAQAAAA==.',
['流浪']='流浪风之间:BAAALgADCgcJAgAAAA==.',
['流苏']='流苏六月一:BAAALgAFFAQJBAAAAA==.',
['浅漓']='浅漓:BAAALgAECgYJBgAAAA==.',
['海战']='海战之盾:BAAALgAECgYJCAAAAA==.',
['海格']='海格摩尼亚:BAAALgAECgYJBgAAAA==.',
['海绵']='海绵布布:BAAALgAECgEJAQAAAA==.',
['淘气']='淘气的小野:BAAALgAECgUJAQAAAA==.',
['湮滅']='湮滅淵:BAAALgAECgQJCAAAAA==.',
['灬以']='灬以箭之名灬:BAAALgAECgYJDAAAAA==.',
['灬須']='灬須彌的等待:BAAALgAFFAUJAgAAAA==.',
['無情']='無情丶:BAAALgAECgkJCQAAAA==.',
['無言']='無言獨上西樓:BAAALgAECgEJAQAAAA==.',
['熊熊']='熊熊壹号:BAAALgADCgYJBgAAAA==.',
['牛犇']='牛犇犇:BAABLgAECn8WAAMIAAcJ5wzLhQBuAQAIAAcJ5wzLhQBuAQASAAYJEQIyMQCLAAAAAA==.',
['猛牛']='猛牛乳夜:BAAALgAECgMJAwAAAA==.',
['獨焮']='獨焮:BAAALgADCgcJBwAAAA==.',
['獨馫']='獨馫:BAAALgAECgEJAQAAAA==.',
['王冰']='王冰冰:BAAALgAFFAIJAgABLgAFFAUJAQACAAAAAA==.',
['王小']='王小明丶:BAAALgAECgkJCwAAAA==.',
['瑰魅']='瑰魅:BAAALgAFFAIJAgAAAA==.',
['瑶瑶']='瑶瑶:BAAALgADCgIJAgAAAA==.',
['瓜一']='瓜一:BAABLgAFFH8FAAMDAAUJYRvUDwDJAAAEAAMJshaMFQDvAAADAAIJESDUDwDJAAAAAA==.',
['瓶子']='瓶子妖:BAAALgAFFAMJAwAAAA==.',
['用力']='用力捅:BAAALgAECgEJAQAAAA==.',
['皂皂']='皂皂丶:BAAALgAFFAMJAwAAAA==.',
['皓月']='皓月骑士:BAAALgADCgYJCwAAAA==.',
['盖拉']='盖拉德丽尔:BAAALgADCgEJAQAAAA==.',
['看我']='看我眼色动手:BAAALgADCgUJBQAAAA==.',
['石中']='石中玉:BAACLgAFFH8IAAIBAAQJmRd0BgAhAQABAAQJmRd0BgAhAQAuAAQKfx8AAgEACAmyIGoKANQCAAEACAmyIGoKANQCAAAA.',
['硬汉']='硬汉乔山:BAAALgAECgEJAQAAAA==.',
['祗淰']='祗淰丶那过佉:BAAALgAECgEJAQAAAA==.',
['章鱼']='章鱼哥哥:BAAALgAECgEJAgAAAA==.',
['红杏']='红杏丶:BAAALgADCgcJBwAAAA==.',
['红桃']='红桃七七:BAAALgAECgEJAgAAAA==.',
['红袖']='红袖满楼招:BAAALgAECgcJCwAAAA==.',
['纯净']='纯净:BAAALgAECgQJBAAAAA==.',
['纯烬']='纯烬:BAAALgAECgEJAQAAAA==.',
['纳兹']='纳兹乌罗:BAAALgAECgIJAgAAAA==.',
['纸飞']='纸飞机:BAAALgAECgYJBwAAAA==.',
['绝区']='绝区零糕手:BAAALgAFFAEJAQAAAA==.',
['维罗']='维罗娜拉:BAAALgADCgEJAQABLgAFFAYJCAATAA4aAA==.',
['罗斯']='罗斯杰克逊:BAAALgADCgUJBQAAAA==.',
['考雷']='考雷斯特拉兹:BAAALgADCgcJBwAAAA==.',
['艾林']='艾林哈籁五号:BAAALgADCgkJEAAAAA==.',
['艾露']='艾露莎:BAAALgAECgMJAwAAAA==.',
['花与']='花与虫:BAAALgAECgMJAwAAAA==.',
['花满']='花满楼:BAAALgAECgIJAwAAAA==.',
['苍郁']='苍郁丶:BAAALgAECgcJBwAAAA==.',
['苏郁']='苏郁:BAAALgADCgYJBgAAAA==.',
['苦艾']='苦艾酒:BAAALgAFFAIJAwAAAA==.',
['茉艾']='茉艾拉丶:BAAALgADCgUJBQAAAA==.',
['莫问']='莫问北丶:BAAALgAECgEJAgAAAA==.',
['萌喵']='萌喵的肉球:BAAALgAECgcJDQAAAA==.',
['萌龟']='萌龟龟:BAAALgAECgYJBgAAAA==.',
['萝莉']='萝莉有三宝:BAABLgAFFH8HAAINAAIJoxcFOgCoAAANAAIJoxcFOgCoAAAAAA==.',
['蕾切']='蕾切尔晨光:BAAALgAECgcJDQAAAA==.',
['薇琪']='薇琪:BAAALgAECgcJCQAAAA==.',
['薛迪']='薛迪凯丶:BAAALgAECgEJAQAAAA==.',
['虚空']='虚空打工人:BAAALgAECgQJBQABLgAFFAMJCgARAOERAA==.',
['虹霓']='虹霓儿:BAAALgAECgcJEwAAAA==.',
['西門']='西門吹雪:BAAALgAECgYJBwAAAA==.',
['調泄']='調泄了:BAAALgAECgYJBwAAAA==.',
['诗和']='诗和远方的你:BAAALgAECgIJAgAAAA==.',
['豁酨']='豁酨偒霞:BAAALgAECgcJDAAAAA==.',
['贫僧']='贫僧夜探青喽:BAAALgAECgIJBQAAAA==.',
['蹦跶']='蹦跶嘚橙仔:BAAALgAFFAEJAQAAAA==.',
['辰陨']='辰陨:BAAALgADCgEJAQAAAA==.',
['运气']='运气很重要:BAAALgAECgYJBgAAAA==.',
['还有']='还有哦哦哟:BAAALgAFFAQJBAAAAA==.',
['这游']='这游戏:BAAALgADCgcJBwAAAA==.',
['迷魂']='迷魂记:BAAALgAECgIJAgAAAA==.',
['逆流']='逆流一死骑:BAAALgAECgYJBgAAAA==.逆流一萨:BAAALgAECgYJBgAAAA==.',
['遙遠']='遙遠的回憶:BAAALgAECgYJDgAAAA==.',
['醬油']='醬油飯:BAAALgAFFAIJAgAAAA==.',
['队长']='队长我中枪了:BAAALgAECgEJAwAAAA==.',
['阿克']='阿克萌徳:BAAALgAECgcJEwAAAA==.',
['阿瓦']='阿瓦达啃西瓜:BAAALgAECgYJCwAAAA==.',
['陈风']='陈风暴烈酒:BAAALgAECgUJBAAAAA==.',
['陶瓷']='陶瓷猫:BAAALgAECgEJAQAAAA==.',
['雨珞']='雨珞:BAAALgAECgcJEgAAAA==.',
['雨霖']='雨霖铃:BAAALgAECgUJBgAAAA==.',
['雨露']='雨露俊俊:BAAALgAECgYJBwAAAA==.',
['雨鱼']='雨鱼之战:BAAALgAECgcJCwAAAA==.',
['雪域']='雪域冰封:BAACLgAFFH8JAAIHAAQJYRqhEAAuAQAHAAQJYRqhEAAuAQAuAAQKfxoAAgcABgnHIr9KAFcCAAcABgnHIr9KAFcCAAAA.',
['顽劣']='顽劣:BAAALgAECgYJDQAAAA==.',
['飞向']='飞向宇宙:BAAALgAECgcJEQAAAA==.',
['香蕉']='香蕉恶霸:BAAALgAECgEJAQAAAA==.',
['骑士']='骑士道:BAAALgADCgMJAwAAAA==.',
['高圆']='高圆圆:BAAALgAECgcJBwABLgAFFAUJAQACAAAAAA==.',
['魔幻']='魔幻之旅:BAABLgAFFH8FAAIDAAMJ6hTaCgALAQADAAMJ6hTaCgALAQAAAA==.',
['黑娘']='黑娘子:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗空間:BAAALgAECgQJBwAAAA==.',
['默默']='默默墨:BAAALgAECgYJCQAAAA==.',
['黯冽']='黯冽:BAAALgAECgEJAQAAAA==.',
['龙晓']='龙晓吟:BAAALgAECgQJAQAAAA==.',
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
