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

local lookup = {'Monk-Windwalker','Evoker-Preservation','Mage-Frost','Paladin-Retribution','Warrior-Fury','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Devourer','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Warrior-Protection','Druid-Restoration','Warlock-Demonology','Priest-Shadow','Druid-Balance','Hunter-Marksmanship','Monk-Mistweaver','Monk-Brewmaster','Paladin-Holy','Priest-Discipline','Priest-Holy','Hunter-Survival',}
local provider = {region='CN',realm='弗塞雷迦',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Ams:BAAALgADCgEJAQAAAA==.',
Ar='Arthasjaina:BAAALgAECgYJBgAAAA==.Arthurx:BAAALgAECgQJBAAAAA==.',
Bl='Blusangue:BAAALgAECgEJAQAAAA==.',
De='Devilreturns:BAAALgAECgIJAgAAAA==.',
Dh='Dharmabhan:BAAALgAECgYJCAAAAA==.',
Ef='Efey:BAAALgAECgYJBwAAAA==.',
Ha='Hatsunemiku:BAABLgAECn8YAAIBAAkJKhrZFABGAgABAAkJKhrZFABGAgAAAA==.',
Ix='Ixshishi:BAAALgAECgIJAgAAAA==.',
Mi='Mikazukl:BAAALgAECgEJAQAAAA==.',
Po='Poioq:BAAALgADCgYJAQAAAA==.',
Zu='Zujin:BAAALgAECgIJAgAAAA==.',
['一点']='一点浩然气:BAAALgADCgEJAQAAAA==.',
['一琪']='一琪丗一:BAAALgAECgcJCwAAAA==.',
['一颗']='一颗小橘子:BAAALgAFFAIJBAAAAA==.',
['万龙']='万龙:BAABLgAFFH8HAAICAAMJrR7SBAAOAQACAAMJrR7SBAAOAQAAAA==.',
['丨海']='丨海盗船长丨:BAAALgAECgEJAQAAAA==.',
['丨潜']='丨潜规则丨:BAAALgAECgUJBwAAAA==.',
['临时']='临时演员:BAAALgADCgMJAwAAAA==.',
['丶迷']='丶迷糊小法師:BAAALgAECgEJAQAAAA==.',
['乀灬']='乀灬男人帮:BAAALgAECgEJAQAAAA==.',
['乃穷']='乃穷神冰:BAAALgAECgEJAQAAAA==.',
['乄傻']='乄傻馒乄:BAAALgADCgMJAwAAAA==.',
['乄神']='乄神棍德乄:BAAALgADCgYJBgAAAA==.',
['云梦']='云梦瑶:BAAALgAFFAMJAwAAAA==.',
['五年']='五年四班丶:BAAALgAECggJDgAAAA==.',
['伊洛']='伊洛玛丽:BAAALgAECgYJDQAAAA==.',
['伊莉']='伊莉娅丶晨曦:BAAALgAECgEJAQAAAA==.',
['伊邪']='伊邪钠铱:BAAALgADCgEJAQAAAA==.',
['你香']='你香信我:BAAALgAECgQJBgAAAA==.',
['依莎']='依莎貝菈:BAAALgAECgMJBQAAAA==.',
['信仰']='信仰之光:BAAALgAECgQJBAAAAA==.',
['倪久']='倪久依鲁瑟尔:BAACLgAFFH8HAAIDAAMJOBL8EQADAQADAAMJOBL8EQADAQAuAAQKfxcAAgMACAlIG0VFAGgCAAMACAlIG0VFAGgCAAAA.',
['傻哥']='傻哥:BAAALgADCgYJBgAAAA==.',
['元素']='元素灬泯灭:BAAALgAFFAIJAgAAAA==.',
['克吕']='克吕墨涅:BAABLgAFFH8FAAIEAAIJ9QLqKgB3AAAEAAIJ9QLqKgB3AAAAAA==.',
['冰战']='冰战:BAAALgADCgEJAQAAAA==.',
['冲锋']='冲锋的羊腰子:BAAALgAFFAQJBAAAAA==.',
['凯尔']='凯尔文:BAABLgAECn8cAAIFAAcJHB6hHABpAgAFAAcJHB6hHABpAgAAAA==.',
['刘美']='刘美丽:BAAALgAECgcJDQAAAA==.',
['别看']='别看我长得儒:BAAALgAECgQJBAAAAA==.别看我长得呆:BAAALgAECgMJAwAAAA==.别看我长得妖:BAAALgAECgIJAgABLgAECgMJAwAGAAAAAA==.别看我长得笪:BAAALgAECgQJBAAAAA==.别看我长的俊:BAAALgAECgYJCgAAAA==.',
['化混']='化混乱为有序:BAAALgAECgYJBgAAAA==.',
['厚礼']='厚礼蟹:BAAALgADCgIJAQAAAA==.',
['双眼']='双眼色眯眯:BAAALgADCgMJAwAAAA==.',
['可露']='可露丽:BAAALgADCgYJBgAAAA==.',
['吃战']='吃战复的妖怪:BAAALgAFFAQJBAAAAA==.吃战复的怪兽:BAABLgAFFH8FAAIFAAQJcRaaCQBaAQAFAAQJcRaaCQBaAQAAAA==.吃战复的怪物:BAAALgAFFAQJBAAAAA==.',
['呆萌']='呆萌哼特:BAAALgAECgYJBgAAAA==.',
['呦丶']='呦丶:BAACLgAFFH8HAAMHAAMJdwlEBgDsAAAHAAMJdwlEBgDsAAAIAAIJZAGSFwB1AAAuAAQKfxYABAcACAmpE50ZAPgBAAcABwmZFp0ZAPgBAAgABAlMBX04AH4AAAkAAQkGAmIwACAAAAAA.',
['咕咕']='咕咕牛:BAAALgAECgEJAQAAAA==.',
['咘舍']='咘舍依依:BAAALgAECgUJBwAAAA==.',
['喀尔']='喀尔刻:BAAALgAECgYJCgAAAA==.',
['四喜']='四喜丸子:BAACLgAFFH8HAAIKAAMJJQKGCQCyAAAKAAMJJQKGCQCyAAAuAAQKfyIAAwoACAl+DJA5AJsBAAoACAl+DJA5AJsBAAsAAglsBQAAAAAAAAAA.',
['圣光']='圣光忽悠你:BAAALgAFFAEJAQAAAA==.圣光照你丫:BAAALgAECgcJBwAAAA==.',
['圣山']='圣山之湖畔:BAABLgAFFH8FAAIEAAMJAQ7bFwDvAAAEAAMJAQ7bFwDvAAAAAA==.',
['圣敦']='圣敦敦:BAAALgAECgYJBgAAAA==.',
['堕落']='堕落七曜:BAAALgAECgcJEgAAAA==.',
['塔隆']='塔隆丨血魔:BAAALgAECgkJCgAAAA==.',
['壹等']='壹等烟民:BAAALgADCgYJBwAAAA==.',
['夙翼']='夙翼:BAABLgAECn8WAAIMAAcJPiMKEwCfAgAMAAcJPiMKEwCfAgAAAA==.',
['大威']='大威天龙:BAAALgADCgYJBgAAAA==.',
['大笨']='大笨牛牛:BAACLgAFFH8HAAINAAMJHBIFBADUAAANAAMJHBIFBADUAAAuAAQKfx8AAg0ACAn6GosLAFUCAA0ACAn6GosLAFUCAAAA.',
['天地']='天地迪迪:BAAALgAECgYJCwAAAA==.',
['孙尚']='孙尚香:BAABLgAFFH8IAAIOAAQJfgY3EADoAAAOAAQJfgY3EADoAAAAAA==.',
['安魂']='安魂夜:BAAALgAFFAIJAgAAAA==.',
['寂寞']='寂寞的收获:BAAALgAECgYJDwAAAA==.',
['寂灭']='寂灭灵魂:BAAALgADCgMJAwAAAA==.',
['小嘣']='小嘣豆:BAAALgADCggJCAAAAA==.',
['小妲']='小妲已:BAAALgAECgIJAgAAAA==.',
['小潼']='小潼潼:BAAALgAECgUJBQAAAA==.',
['小狩']='小狩人:BAAALgAECgUJBQAAAA==.',
['小猫']='小猫透透溜:BAAALgAECgQJBAAAAA==.',
['小红']='小红手吱吱:BAAALgAECgYJCQAAAA==.',
['小饿']='小饿魔:BAAALgAECgEJAgAAAA==.',
['小骨']='小骨头鱼:BAAALgADCgEJAQAAAA==.',
['小鸟']='小鸟游星野:BAABLgAECn8VAAIPAAgJeA43WQC8AQAPAAgJeA43WQC8AQAAAA==.',
['尐宇']='尐宇宙:BAAALgAECgIJAwAAAA==.',
['屠苏']='屠苏:BAABLgAFFH8HAAIQAAMJcSGwAwAdAQAQAAMJcSGwAwAdAQAAAA==.',
['帕特']='帕特拉尔:BAAALgADCgEJAgAAAA==.',
['干饭']='干饭得用盆:BAAALgAECgIJAgAAAA==.',
['幸运']='幸运小绿人:BAAALgAFFAUJBAAAAA==.',
['幽狱']='幽狱焚魂:BAAALgAECgQJBAAAAA==.',
['幽鬼']='幽鬼:BAAALgAECgEJAQAAAA==.',
['弗洛']='弗洛洛:BAAALgAFFAMJAwAAAA==.',
['御宅']='御宅族:BAAALgAECgEJAQAAAA==.',
['惊天']='惊天风骚:BAAALgAECgYJCQAAAA==.',
['想战']='想战士:BAABLgAECn8XAAMFAAkJjx0HCQAcAwAFAAkJgxwHCQAcAwANAAYJGR7RFgCkAQAAAA==.',
['意大']='意大利炮:BAAALgAECggJDwAAAA==.',
['慵懒']='慵懒的海产品:BAAALgAECgkJCQAAAA==.',
['我想']='我想抓只小德:BAAALgAECgIJAgAAAA==.',
['我是']='我是德鲁伊:BAAALgAECgEJAQAAAA==.',
['拔起']='拔起树根然后:BAACLgAFFH8HAAIRAAMJ4xrjBAAPAQARAAMJ4xrjBAAPAQAuAAQKfyAAAxEACAnzFIAeAAwCABEACAnzFIAeAAwCAA4ABglIJIwrAAICAAAA.',
['捷尔']='捷尔嘉德:BAAALgAECgEJAQAAAA==.',
['旖旎']='旖旎的羽翎:BAABLgAECn8WAAISAAcJ3AoxSAAyAQASAAcJ3AoxSAAyAQABLgADCgcJBwAGAAAAAA==.',
['无敌']='无敌小超超:BAAALgADCgcJCwAAAA==.',
['星丶']='星丶空:BAAALgAFFAEJAQAAAA==.',
['星晚']='星晚碎碎念:BAAALgADCgQJBAAAAA==.',
['晚桥']='晚桥:BAAALgAFFAMJAwABLgAFFAUJBAAGAAAAAA==.',
['月神']='月神血之舞:BAAALgAFFAEJAQAAAA==.',
['李淳']='李淳罡:BAAALgAECgYJBgAAAA==.',
['果子']='果子不加糖:BAAALgAECgEJAgAAAA==.',
['枫血']='枫血:BAAALgAECgMJAwAAAA==.',
['柒月']='柒月涅槃:BAACLgAFFH8HAAIEAAMJ6xMVFAAHAQAEAAMJ6xMVFAAHAQAuAAQKfx8AAgQACAnqHekbAMICAAQACAnqHekbAMICAAAA.',
['根本']='根本不想活:BAAALgADCgIJAgAAAA==.',
['桃塔']='桃塔罗斯:BAAALgADCgEJAQAAAA==.',
['桐谷']='桐谷和人:BAAALgADCgYJBgAAAA==.',
['椒盐']='椒盐皮皮鲁:BAAALgAECgEJAQAAAA==.',
['模拟']='模拟烤羊肉:BAAALgADCgEJAQAAAA==.',
['欧吉']='欧吉酱:BAAALgAECgIJAgAAAA==.',
['武道']='武道熊师:BAABLgAFFH8FAAITAAIJTBCNEACYAAATAAIJTBCNEACYAAAAAA==.',
['死亡']='死亡咆哮:BAAALgAECgkJCQAAAA==.',
['水域']='水域玲珑:BAAALgADCgEJAQAAAA==.',
['沾血']='沾血的黄瓜:BAAALgAECggJEAAAAA==.',
['法師']='法師娃:BAAALgAECgMJAwAAAA==.',
['法琳']='法琳:BAAALgAECgYJBwAAAA==.',
['泡椒']='泡椒水煮肉:BAAALgAECgQJBAAAAA==.',
['流氓']='流氓坏叔叔:BAAALgAECgQJBAAAAA==.',
['海蛎']='海蛎子号:BAAALgAECgcJAQAAAA==.',
['潘诺']='潘诺佩亚:BAAALgAECgUJBwAAAA==.',
['火法']='火法:BAAALgAECgEJAQAAAA==.',
['火車']='火車驶向雲外:BAAALgAECgQJBQAAAA==.',
['烤焦']='烤焦的肉:BAAALgAECgkJDgAAAA==.',
['照葫']='照葫芦華瓢:BAAALgAECgYJBgAAAA==.',
['熊猫']='熊猫滑翔者:BAABLgAECn8XAAMBAAcJZx9kGAAfAgABAAcJZx9kGAAfAgATAAYJJBB8MQA0AQAAAA==.',
['牛牛']='牛牛飞起:BAAALgAECgYJCQAAAA==.',
['牧先']='牧先生:BAAALgAECgcJBgAAAA==.',
['牧阿']='牧阿师:BAAALgAECgcJCQAAAA==.',
['犇犇']='犇犇牛:BAAALgAECgYJBgAAAA==.',
['玄灵']='玄灵之舞:BAAALgAECgQJBQAAAA==.玄灵之语:BAAALgAFFAIJAgAAAA==.',
['玫瑰']='玫瑰猎手:BAAALgADCgUJBQAAAA==.',
['番茄']='番茄炖牛腩:BAAALgAECgEJAQAAAA==.',
['疯僧']='疯僧醉菩提:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂的逍遥:BAAALgADCgEJAQAAAA==.',
['白羽']='白羽崖雪:BAAALgAFFAIJAgAAAA==.白羽芽雪:BAAALgAECgEJAQAAAA==.',
['白衣']='白衣长歌:BAAALgAFFAEJAQAAAA==.',
['真理']='真理穿孔:BAAALgAECgQJBQAAAA==.',
['禁咒']='禁咒师:BAAALgAFFAIJAQAAAA==.',
['福波']='福波斯特里安:BAAALgAECgEJAQAAAA==.',
['第二']='第二根半价:BAAALgAECgUJBgABLgAFFAMJBwAQAHEhAA==.',
['等等']='等等:BAAALgAECgUJBQAAAA==.',
['米卫']='米卫兵:BAACLgAFFH8TAAINAAUJMSJGAQDjAQANAAUJMSJGAQDjAQAuAAQKfxYAAg0ACAlIJEYCAEsDAA0ACAlIJEYCAEsDAAAA.',
['糕手']='糕手:BAACLgAFFH8HAAIUAAMJKB7gBAAtAQAUAAMJKB7gBAAtAQAuAAQKfyIAAhQACAnRIdsKAN0CABQACAnRIdsKAN0CAAAA.',
['紫菜']='紫菜团子:BAAALgAECgYJAgAAAA==.',
['红面']='红面紫牙:BAAALgAECgMJAwAAAA==.',
['纯爱']='纯爱骑士:BAAALgAECgYJBgAAAA==.',
['维纳']='维纳斯的诅咒:BAACLgAFFH8IAAIDAAMJahAXPwCvAAADAAMJahAXPwCvAAAuAAQKfxQAAgMABQkHHsiwAHwBAAMABQkHHsiwAHwBAAAA.',
['群青']='群青與熟褐:BAAALgADCgEJAQAAAA==.',
['肉肉']='肉肉宝:BAAALgAECgEJAQAAAA==.',
['胖胖']='胖胖萨满:BAAALgAECgIJAwAAAA==.',
['艾莉']='艾莉桑德:BAAALgAECgYJCQAAAA==.',
['芒芒']='芒芒露露:BAAALgADCgEJAQAAAA==.',
['苏幽']='苏幽梨:BAABLgAFFH8FAAICAAMJZA6RDgDtAAACAAMJZA6RDgDtAAAAAA==.',
['若叶']='若叶睦:BAAALgADCgMJAwAAAA==.',
['菜鸡']='菜鸡互啄:BAAALgAECgMJAwABLgAFFAUJBQAIAN8aAA==.',
['薇薇']='薇薇安:BAAALgAFFAIJAgAAAA==.',
['薛池']='薛池语:BAAALgAECgEJAQAAAA==.',
['虚空']='虚空战神:BAAALgAECgkJCgAAAA==.虚空毁灭:BAAALgAECgYJCQAAAA==.',
['血月']='血月天堂:BAAALgAECgkJCQAAAA==.',
['要乐']='要乐奈:BAAALgAFFAEJAQAAAA==.',
['要帥']='要帥一辈子:BAAALgAFFAEJAQAAAA==.',
['诗雨']='诗雨馨竹:BAABLgAECn8aAAMBAAYJAR9EBwBoAQABAAYJAR9EBwBoAQATAAMJKwvZVAB+AAAAAA==.',
['财神']='财神儿:BAAALgAECgkJBgAAAA==.',
['赛拉']='赛拉斐:BAABLgAECn8WAAMVAAgJ7QztNQCkAQAVAAgJ7QztNQCkAQAEAAEJYwYAAAAAAAAAAA==.',
['赫菲']='赫菲斯柁斯:BAAALgAECgIJAgAAAA==.',
['还是']='还是灾变:BAAALgAECgcJCgAAAA==.',
['那谁']='那谁家老谁:BAAALgAECgcJBwAAAA==.',
['邪魔']='邪魔退散:BAAALgAECgEJAQAAAA==.',
['释魂']='释魂寒风:BAAALgAECgEJAQAAAA==.',
['銳雯']='銳雯:BAAALgAFFAEJAQAAAA==.',
['鋭雯']='鋭雯:BAACLgAFFH8HAAIWAAMJPR2/CwAfAQAWAAMJPR2/CwAfAQAuAAQKfxgAAxYACAl3IiAEAB8DABYACAl3IiAEAB8DABcABglhDFhGACABAAAA.',
['钨钢']='钨钢之狼:BAACLgAFFH8IAAIKAAMJRAcNEgDVAAAKAAMJRAcNEgDVAAAuAAQKfyMAAgoABwkOHwQWAGUCAAoABwkOHwQWAGUCAAAA.',
['铯手']='铯手:BAAALgAFFAMJBAABLgAFFAMJBwAQAHEhAA==.',
['阿尔']='阿尔忒猊斯:BAAALgAECgYJDgAAAA==.',
['阿斯']='阿斯特赖亚:BAAALgAECgQJBAAAAA==.',
['阿芙']='阿芙洛狄忒:BAAALgAFFAIJBAAAAA==.',
['雨薰']='雨薰:BAAALgAECggJCAABLgAFFAUJBAAGAAAAAA==.',
['雪过']='雪过无痕:BAAALgAECgYJBgAAAA==.',
['雷迪']='雷迪呱呱:BAAALgAECgEJAQAAAA==.',
['雷霆']='雷霆牛斯拉:BAAALgAECgUJCQAAAA==.',
['靈镀']='靈镀小爺:BAAALgAECgkJEQAAAA==.',
['青玉']='青玉德德:BAACLgAFFH8HAAQYAAMJ0BqcAgAaAQAYAAMJjRWcAgAaAQASAAIJjhUcHAClAAAMAAEJdBt5HwBiAAAuAAQKfxoAAxIACAn7GqkZAFoCABIACAnWGqkZAFoCABgABQnGGHAJAAwBAAAA.',
['青面']='青面槽牙:BAAALgAECgcJCQAAAA==.',
['领悟']='领悟人生:BAAALgAECgMJAwAAAA==.',
['風之']='風之紫电:BAAALgAECgEJAQAAAA==.',
['飞鸟']='飞鸟和蝉:BAAALgAECgYJBwAAAA==.',
['香浓']='香浓一刻:BAAALgADCgEJAgAAAA==.香浓那一刻:BAAALgAFFAIJBAAAAA==.',
['马保']='马保国:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法舅妈:BAAALgAFFAEJAQAAAA==.',
['鸿蒙']='鸿蒙决战:BAAALgAECgMJAwAAAA==.',
['黑暗']='黑暗秘法规则:BAABLgAECn8QAAIPAAgJVAY/mQAmAQAPAAgJVAY/mQAmAQAAAA==.',
['黑羽']='黑羽玄墨:BAAALgAFFAIJAgAAAA==.',
['龘赑']='龘赑赑:BAAALgADCgUJBQAAAA==.',
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
