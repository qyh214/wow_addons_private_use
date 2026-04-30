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

local lookup = {'Priest-Shadow','Priest-Discipline','Warlock-Demonology','Unknown-Unknown','Mage-Frost','Rogue-Subtlety','Evoker-Devastation','Warrior-Fury','Warrior-Arms','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Destruction','Monk-Windwalker','Monk-Mistweaver','Druid-Restoration','Druid-Balance','Warrior-Protection','Warlock-Affliction','Hunter-Marksmanship','Paladin-Retribution','Hunter-BeastMastery','DemonHunter-Devourer','DemonHunter-Havoc','DemonHunter-Vengeance',}
local provider = {region='CN',realm='兰娜瑟尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alissa:BAAALgAECgEJAQAAAA==.',
An='Ancient:BAAALgAFFAQJAwAAAA==.',
Ar='Arrax:BAACLgAFFH8JAAIBAAUJTRSIAwCxAQABAAUJTRSIAwCxAQAuAAQKfxUAAwEABwmsFuUjALgBAAEABwmsFuUjALgBAAIABgnmE7sqAEQBAAAA.',
As='Asidunmading:BAAALgAECgYJBgAAAA==.',
Au='Augenstern:BAAALgAFFAIJAgAAAA==.',
Ca='Canelpriest:BAAALgAECgYJDQAAAA==.Caraxes:BAABLgAFFH8OAAMBAAYJ6BDwAACUAQABAAYJ6BDwAACUAQACAAQJpA4SCgA+AQAAAA==.',
Ch='Chihiro:BAAALgAECgUJCQAAAA==.',
Da='Darkaging:BAAALgAECgYJCgAAAA==.',
Ga='Gauss:BAACLgAFFH8GAAIDAAUJdBEHCABTAQADAAUJdBEHCABTAQAuAAQKfxUAAgMACQnfGyQOAAgDAAMACQnfGyQOAAgDAAAA.',
He='Heath:BAAALgAECgEJAQABLgAECgUJBAAEAAAAAA==.',
Hi='Hideon:BAAALgADCgYJBgAAAA==.',
Im='Imonical:BAAALgAECgEJAgAAAA==.',
In='Innershadow:BAAALgAECgQJBAAAAA==.',
Ju='Juniie:BAAALgAECgQJBAAAAA==.',
Li='Lipenny:BAAALgAECgUJBAAAAA==.Littlesmart:BAABLgAFFH8FAAIFAAMJ6B82FAASAQAFAAMJ6B82FAASAQAAAA==.',
Ma='Maersk:BAAALgADCgYJBQAAAA==.Maldivâ:BAAALgAFFAQJBAAAAA==.',
Mi='Missanna:BAABLgAFFH8OAAIBAAYJ8RWZAAC0AQABAAYJ8RWZAAC0AQAAAA==.',
Ms='Msterashened:BAAALgAECgEJAQAAAA==.',
Po='Poohh:BAAALgAECgUJCAAAAA==.',
Sa='Saylove:BAAALgADCgUJBQAAAA==.',
Si='Sisibiu:BAAALgAECgYJDwAAAA==.',
Ve='Vermithor:BAABLgAFFH8MAAMBAAYJEBWQAAC2AQABAAYJEBWQAAC2AQACAAQJHhM5CQBJAQAAAA==.',
Vh='Vhagar:BAABLgAFFH8OAAMBAAYJRxI7BwBSAQABAAYJRxI7BwBSAQACAAQJlQySCgA1AQAAAA==.',
Vi='Vikram:BAAALgAECgYJDAAAAA==.',
Vx='Vxsbbhyeiame:BAABLgAFFH8KAAIGAAQJYRW3BwBqAQAGAAQJYRW3BwBqAQAAAA==.',
Wi='Wison:BAAALgAFFAEJAQABLgAFFAQJDQAHALIZAA==.',
Zi='Zinãsilenceã:BAAALgAECgYJDAAAAA==.',
['一宛']='一宛:BAAALgADCgcJBwAAAA==.',
['三十']='三十八点六度:BAAALgADCgMJAwAAAA==.',
['三彩']='三彩团子:BAABLgAECn8XAAIFAAYJHR/MXgAeAgAFAAYJHR/MXgAeAgAAAA==.',
['三把']='三把剑:BAAALgAFFAIJAgAAAA==.',
['三无']='三无劣人:BAAALgAFFAIJAgAAAA==.',
['三片']='三片大好:BAAALgAECgEJAQAAAA==.',
['不吃']='不吃猫粮的猫:BAAALgAECgYJCwAAAA==.',
['不故']='不故楚兴:BAAALgAECgUJBgAAAA==.',
['丘丘']='丘丘:BAAALgAECgYJEwAAAA==.',
['丶科']='丶科勒的匕首:BAAALgAECgcJEQAAAA==.',
['丶薇']='丶薇尔:BAAALgAECgYJBgAAAA==.',
['丶装']='丶装逼裤衩:BAAALgAECgQJBwAAAA==.',
['丶阿']='丶阿尔托利亚:BAAALgADCgEJAQAAAA==.',
['丿墓']='丿墓锺無魜:BAAALgADCgEJAQAAAA==.',
['丿安']='丿安和桥北:BAAALgADCgUJBQAAAA==.',
['久石']='久石奏:BAAALgAECgEJAwAAAA==.',
['二次']='二次元刀娃:BAAALgAECgQJCAAAAA==.',
['亨利']='亨利威廉二世:BAAALgAECgYJBwAAAA==.',
['仅仅']='仅仅只是情怀:BAAALgAECgYJEQAAAA==.',
['付轩']='付轩豪是七腿:BAABLgAFFH8IAAIIAAQJDBxKBwB3AQAIAAQJDBxKBwB3AQAAAA==.付轩豪是九腿:BAABLgAFFH8IAAIIAAQJohK8CgBQAQAIAAQJohK8CgBQAQAAAA==.付轩豪是五腿:BAABLgAFFH8MAAIIAAQJUx9iBwB2AQAIAAQJUx9iBwB2AQAAAA==.付轩豪是八腿:BAABLgAFFH8JAAMJAAUJCRvYAACzAQAJAAUJVhfYAACzAQAIAAQJ6BdZCQBcAQAAAA==.付轩豪是六腿:BAABLgAFFH8IAAIIAAQJrBJdCgBTAQAIAAQJrBJdCgBTAQAAAA==.付轩豪是四腿:BAACLgAFFH8OAAMIAAYJFhWlCQBaAQAIAAQJNRalCQBaAQAJAAYJVQ0JAwD6AAAuAAQKfxQAAggABwktHq8sAAECAAgABwktHq8sAAECAAAA.',
['以德']='以德服人:BAAALgAECgUJCgAAAA==.',
['你被']='你被牛打过:BAAALgAFFAQJBAAAAA==.',
['佳人']='佳人伴孤灯:BAAALgAFFAQJAwAAAA==.',
['使徒']='使徒丶:BAAALgADCgUJBgAAAA==.',
['信仰']='信仰冰:BAAALgAFFAIJAgAAAA==.',
['儒雅']='儒雅随和谦逊:BAABLgAFFH8GAAIKAAIJDwnXAACmAAAKAAIJDwnXAACmAAAAAA==.',
['光之']='光之勇者:BAAALgAECgEJAgABLgAECgUJBAAEAAAAAA==.',
['光芒']='光芒麦兜:BAAALgAECgIJAgAAAA==.',
['兲煞']='兲煞箛鯹:BAAALgAECgcJDwAAAA==.',
['冷静']='冷静稀饭:BAAALgAFFAEJAQAAAA==.',
['刻耳']='刻耳柏洛斯:BAAALgAFFAEJAQAAAA==.',
['剑聖']='剑聖:BAACLgAFFH8RAAMLAAUJ+SPIBgCbAQALAAQJ+SPIBgCbAQAMAAQJ3BDwBQDmAAAuAAQKfyEAAwsACAnnIaIOACYDAAsACAnnIaIOACYDAAwABAlwEbkyAKoAAAAA.',
['十万']='十万伏特:BAAALgAFFAEJAgABLgAECgYJBgAEAAAAAA==.',
['博灬']='博灬奕:BAAALgADCgUJCgAAAA==.',
['双月']='双月:BAAALgAFFAQJBAAAAA==.',
['古夫']='古夫:BAAALgAECgYJCAAAAA==.',
['叮咚']='叮咚鸡:BAABLgAFFH8FAAMNAAQJzySPCADXAAADAAIJ1iXGFgDlAAANAAIJyCOPCADXAAAAAA==.',
['可惜']='可惜:BAABLgAFFH8FAAIOAAUJdR2MDwBcAAAOAAUJdR2MDwBcAAAAAA==.',
['吴小']='吴小妞:BAAALgAECgYJCAAAAA==.',
['吴老']='吴老三:BAAALgADCgEJAQAAAA==.',
['呆瓜']='呆瓜:BAAALgAECgIJAgAAAA==.',
['咖啡']='咖啡王二七蛋:BAAALgADCgEJAQAAAA==.',
['咖喱']='咖喱欧包:BAAALgADCgEJAQAAAA==.',
['哈籁']='哈籁尼尔之雾:BAABLgAFFH8NAAIPAAUJXRUTBACpAQAPAAUJXRUTBACpAQAAAA==.',
['哈莉']='哈莉丶莉:BAAALgAECgIJAwAAAA==.',
['哈谬']='哈谬尔:BAAALgADCgIJAwAAAA==.',
['啊丶']='啊丶娇:BAAALgAECgYJBgAAAA==.',
['喜悦']='喜悦:BAAALgAFFAIJAwAAAA==.喜悦咩:BAAALgAECgcJCQAAAA==.',
['嘟嘟']='嘟嘟武僧:BAAALgAECgYJBgAAAA==.',
['噠噠']='噠噠喵:BAAALgAECgYJCwAAAA==.',
['圆滚']='圆滚:BAAALgAECgUJBQAAAA==.',
['墨尔']='墨尔本的秋天:BAAALgAECgYJCAAAAA==.',
['夏末']='夏末千寻:BAAALgAFFAMJAwAAAA==.',
['大乔']='大乔未久:BAAALgAECgIJAgAAAA==.',
['大学']='大学生活好:BAAALgAECgEJAQAAAA==.',
['大岈']='大岈:BAACLgAFFH8LAAMQAAQJSBdvEQDeAAAQAAMJQBVvEQDeAAARAAIJvwusFACfAAAuAAQKfxgAAxAABwkvJPIFADwCABAABwkvJPIFADwCABEAAQlrE0gnAD4AAAAA.',
['大愤']='大愤:BAABLgAFFH8FAAISAAMJ/g5zBQDFAAASAAMJ/g5zBQDFAAAAAA==.',
['大災']='大災變丶:BAACLgAFFH8LAAMDAAYJax00AgCcAQADAAYJSh00AgCcAQATAAIJLSABAQBmAAAuAAQKfxIAAxMABwnrGXMHANwBABMABwkMF3MHANwBAAMABgntGmt9AGABAAAA.',
['大酋']='大酋长:BAAALgAECgcJEgAAAA==.',
['大风']='大风厂:BAAALgAECgQJBAAAAA==.',
['天明']='天明:BAAALgAECgIJAgAAAA==.',
['奶酪']='奶酪块:BAAALgAECgYJDAAAAA==.',
['嫉妒']='嫉妒的罪孽:BAAALgAECgYJCwAAAA==.',
['寒江']='寒江雪:BAAALgAECgEJAQAAAA==.',
['小个']='小个子大火球:BAAALgAECgYJDwAAAA==.',
['小夜']='小夜时雨:BAAALgAFFAQJBAAAAA==.',
['小恼']='小恼腐嗷呜:BAAALgAECgEJAQAAAA==.',
['小石']='小石头萌萌:BAAALgADCgcJDQAAAA==.',
['小野']='小野:BAAALgAECgUJCwAAAA==.',
['小骨']='小骨头:BAAALgAECgQJDAAAAA==.',
['小鹿']='小鹿:BAAALgAFFAMJAwAAAA==.',
['少年']='少年派的奇幻:BAAALgAECgIJAgAAAA==.',
['山河']='山河故人:BAAALgAFFAEJAQAAAA==.',
['巅峰']='巅峰一刀斩:BAAALgAFFAEJAQAAAA==.',
['希姿']='希姿丶德尔塔:BAAALgAECgYJBgAAAA==.',
['帕普']='帕普迪玛斯:BAAALgAECgEJAgAAAA==.',
['广成']='广成子:BAAALgADCgEJAQAAAA==.',
['德国']='德国电鳗:BAAALgAECgcJCAAAAA==.',
['惡魔']='惡魔暴珺丶:BAACLgAFFH8TAAMDAAYJwhsHBADfAQADAAYJnRsHBADfAQATAAIJeR8LAQBmAAAuAAQKfxUAAwMABwmzIQAmAHoCAAMABwmzIQAmAHoCABMAAQkAAOQvAD4AAAAA.',
['感谢']='感谢团长组我:BAAALgAECgMJCQAAAA==.',
['愤怒']='愤怒的小母牛:BAAALgAECgEJAQAAAA==.',
['慕斯']='慕斯:BAAALgAECgEJAgAAAA==.',
['我一']='我一个回春术:BAAALgAECgEJAQAAAA==.',
['拔剑']='拔剑为红颜:BAAALgAECgYJCgAAAA==.',
['挥手']='挥手告别:BAAALgAECgYJBwAAAA==.',
['提前']='提前嗡嗡:BAABLgAFFH8GAAIQAAMJMxs3CQD3AAAQAAMJMxs3CQD3AAAAAA==.',
['改日']='改日一天:BAAALgAECgQJBgAAAA==.',
['故不']='故不顾:BAAALgAECggJCgAAAA==.',
['斋藤']='斋藤飞鸟:BAABLgAFFH8IAAMNAAQJwiHzCADLAAANAAIJZiLzCADLAAADAAIJHSGSKgDGAAAAAA==.',
['新之']='新之助:BAAALgADCgUJBQAAAA==.',
['方大']='方大哥最后的:BAACLgAFFH8XAAIMAAYJixnKAACuAQAMAAYJixnKAACuAQAuAAQKfxQAAgwACQlqFswPABACAAwACQlqFswPABACAAAA.',
['早上']='早上喝啥:BAAALgAFFAQJBAAAAA==.',
['明月']='明月明月啊:BAABLgAFFH8NAAIRAAYJHB85AAACAgARAAYJHB85AAACAgAAAA==.明月星星:BAAALgAFFAQJBAAAAA==.明月饭行:BAABLgAFFH8OAAIRAAYJ3htjAADcAQARAAYJ3htjAADcAQAAAA==.',
['最近']='最近没上班:BAAALgAFFAQJBAAAAA==.',
['月児']='月児弯弯:BAAALgAFFAQJBAAAAA==.',
['林野']='林野猪丶:BAACLgAFFH8LAAMDAAQJwRqHDgBpAQADAAQJwRqHDgBpAQANAAEJKQ/PFQBTAAAuAAQKfxQAAgMABwlVH9M4ACgCAAMABwlVH9M4ACgCAAAA.',
['柠檬']='柠檬柚:BAAALgAECgYJDgAAAA==.',
['格鲁']='格鲁特:BAAALgAECgMJBAAAAA==.',
['桑活']='桑活渣师傅:BAAALgAFFAEJAQAAAA==.',
['橘子']='橘子酱:BAAALgAECggJDgAAAA==.',
['此刻']='此刻无新事:BAAALgAFFAEJAgAAAA==.',
['武术']='武术大师:BAAALgAECgYJCQAAAA==.',
['武状']='武状元:BAACLgAFFH8JAAMJAAUJjR0RAwAiAQAJAAMJnRoRAwAiAQAIAAMJExrDEAABAQAuAAQKfxUAAwkACAlfJGkKAP8BAAkABQnbI2kKAP8BAAgABwkLH6UvAPEBAAAA.',
['殷靖']='殷靖昌:BAACLgAFFH8FAAILAAMJHQ/ZLwDUAAALAAMJHQ/ZLwDUAAAuAAQKfyAAAgsACAlSHHglAKcCAAsACAlSHHglAKcCAAAA.',
['毛毛']='毛毛球:BAAALgAECgcJBgAAAA==.',
['江城']='江城:BAAALgAECgcJBQAAAA==.',
['汽水']='汽水泡茶:BAAALgAFFAIJAwAAAA==.',
['波纹']='波纹牧:BAAALgAFFAEJAQAAAA==.',
['洛贰']='洛贰乌:BAAALgAFFAQJBAAAAA==.洛贰伞:BAACLgAFFH8KAAIUAAQJnRvjAQBYAQAUAAQJnRvjAQBYAQAuAAQKfxkAAhQACQlrHu8FADwDABQACQlrHu8FADwDAAAA.洛贰尔:BAABLgAFFH8IAAIUAAQJIRbqAQBXAQAUAAQJIRbqAQBXAQAAAA==.洛贰异:BAAALgAFFAQJBAAAAA==.洛贰斯:BAAALgAFFAQJBAAAAA==.洛贰柳:BAAALgAFFAIJAwAAAA==.',
['流星']='流星之源:BAAALgAFFAIJAgAAAA==.',
['清浅']='清浅梦:BAAALgAECgEJAQAAAA==.',
['滚小']='滚小键盘输出:BAAALgAECgcJDAAAAA==.',
['滚開']='滚開:BAAALgAECgQJCwAAAA==.',
['潘多']='潘多拉丶亚克:BAAALgAECgQJBAAAAA==.',
['火火']='火火冰冰:BAABLgAFFH8HAAIFAAIJ3AzPJQCiAAAFAAIJ3AzPJQCiAAAAAA==.',
['灬御']='灬御坂美琴灬:BAAALgAECgIJAgAAAA==.',
['爆怒']='爆怒大柚:BAAALgAECgEJAQAAAA==.',
['爆烈']='爆烈圣光雕:BAAALgAECgYJDwAAAA==.',
['牛骑']='牛骑:BAACLgAFFH8KAAIVAAQJbRgVCQBmAQAVAAQJbRgVCQBmAQAuAAQKfxQAAhUABgkNJMQuAGgCABUABgkNJMQuAGgCAAAA.',
['狂风']='狂风引:BAAALgADCgEJAQAAAA==.',
['狮傲']='狮傲天:BAAALgAECgEJAQAAAA==.',
['玩别']='玩别德咳嗽:BAAALgADCgUJBQAAAA==.',
['珑九']='珑九:BAAALgAECgYJBgABLgAECgYJEgAEAAAAAA==.',
['班乄']='班乄尼特乀:BAAALgAECgIJAwAAAA==.',
['琪九']='琪九:BAAALgAECgYJEgAAAA==.',
['瑠璃']='瑠璃:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂的音符:BAAALgADCgEJAQAAAA==.',
['盾牌']='盾牌:BAAALgAECgIJAgAAAA==.',
['看远']='看远放的星:BAAALgAECgYJDAAAAA==.',
['石头']='石头会喝酒吗:BAAALgAECgQJBAAAAA==.',
['离谱']='离谱的音符:BAAALgAECgUJBgAAAA==.',
['第一']='第一次玩奶:BAAALgAFFAIJBAAAAA==.',
['米尼']='米尼:BAAALgAECgEJAQAAAA==.',
['粉红']='粉红色回忆:BAAALgAECgQJBAAAAA==.',
['糯糯']='糯糯:BAAALgADCgUJBgAAAA==.',
['繁华']='繁华落尽:BAAALgADCgcJBwAAAA==.',
['繁星']='繁星明月:BAABLgAFFH8RAAIRAAUJyhx7AgBrAQARAAUJyhx7AgBrAQAAAA==.',
['纳兰']='纳兰凤鸣:BAAALgAECgQJBgAAAA==.纳兰凤鸣骑士:BAAALgADCgMJAwAAAA==.',
['老佛']='老佛爺:BAAALgAECgYJBgAAAA==.',
['老狐']='老狐狸狸:BAAALgAECgYJDAAAAA==.',
['脆哨']='脆哨洋芋:BAAALgAFFAEJAQAAAA==.',
['芥末']='芥末奶包:BAAALgAECgcJCgAAAA==.',
['花满']='花满楼:BAABLgAECn8YAAIVAAcJHwwTKwAhAQAVAAcJHwwTKwAhAQAAAA==.',
['苍穹']='苍穹:BAAALgADCgUJBQAAAA==.',
['若轩']='若轩:BAAALgAECgEJAQAAAA==.',
['茵蒂']='茵蒂克丝:BAAALgAECgYJDgAAAA==.',
['莉莉']='莉莉思:BAAALgAFFAEJAQAAAA==.',
['萝卜']='萝卜大王:BAAALgAECgIJAgAAAA==.',
['蒂纳']='蒂纳尔:BAABLgAECn8VAAIHAAYJShl3AwBFAQAHAAYJShl3AwBFAQAAAA==.',
['蒜鸟']='蒜鸟算鸟:BAAALgAECgUJBQAAAA==.',
['蛋炒']='蛋炒饭:BAAALgADCgEJAQAAAA==.',
['蜜桃']='蜜桃气泡:BAAALgAFFAQJBAAAAA==.',
['衫崎']='衫崎键:BAAALgAECgYJBgABLgAFFAUJBwAWAEEeAA==.',
['被解']='被解救的坚果:BAAALgADCgEJAQAAAA==.被解救的妖果:BAAALgADCgUJBQAAAA==.被解救的浆果:BAAALgAECgEJAQAAAA==.被解救的野果:BAAALgADCgIJAgAAAA==.',
['要什']='要什么来什么:BAAALgAECgEJAQAAAA==.',
['言葉']='言葉之庭:BAAALgAECggJDQAAAA==.',
['譕鍅']='譕鍅譕兲:BAAALgAECgcJBQAAAA==.',
['让审']='让审判飞一会:BAAALgADCgEJAQAAAA==.',
['谢谢']='谢谢侬:BAAALgAECgEJAQAAAA==.',
['超超']='超超的跟班:BAAALgAECgEJAQAAAA==.',
['躺尸']='躺尸术:BAAALgAECgkJAgAAAA==.',
['醉天']='醉天下:BAAALgAECgEJAQAAAA==.',
['钟暮']='钟暮:BAAALgAFFAIJAgAAAA==.',
['铁竹']='铁竹射手:BAAALgAECgcJBwAAAA==.',
['闺蜜']='闺蜜必须死:BAAALgAECgIJAgAAAA==.',
['阎魔']='阎魔爱:BAAALgAFFAQJBAAAAA==.',
['阿东']='阿东边丶:BAAALgADCgMJAwAAAA==.',
['阿拉']='阿拉神盯:BAAALgAECgEJAQAAAA==.',
['阿牟']='阿牟牟:BAAALgAECgIJAgABLgAFFAEJAQAEAAAAAA==.',
['风之']='风之颂:BAAALgAECgcJAgAAAA==.',
['风暴']='风暴之锤打击:BAAALgAECgYJBgAAAA==.',
['飞猪']='飞猪二号:BAAALgAECgYJBgAAAA==.',
['马思']='马思唯:BAACLgAFFH8KAAIXAAQJ+BYWCwAmAQAXAAQJ+BYWCwAmAQAuAAQKfxkABBcACAm2FJlFAN0BABcABwlcE5lFAN0BABgABQmqFvcyAD8BABkAAQkGBegrADEAAAAA.',
['鱼香']='鱼香茄子煲:BAAALgAFFAUJAwAAAA==.',
['黎雾']='黎雾:BAAALgAECgYJBgABLgAFFAEJAQAEAAAAAA==.',
['黑剑']='黑剑:BAAALgAFFAEJAQAAAA==.',
['黑暗']='黑暗游侠:BAAALgAECgEJAQAAAA==.',
['鼠鼠']='鼠鼠:BAAALgADCgEJAQAAAA==.',
['龙吟']='龙吟小纯:BAAALgAECgMJAwAAAA==.',
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
