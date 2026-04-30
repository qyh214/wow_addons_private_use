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

local lookup = {'Paladin-Holy','Paladin-Retribution','DeathKnight-Unholy','Druid-Balance','Shaman-Restoration','DemonHunter-Havoc','Unknown-Unknown','DemonHunter-Devourer','Priest-Shadow','Priest-Discipline','Priest-Holy','Warrior-Fury','Druid-Guardian','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Enhancement','Warrior-Arms','Druid-Restoration','Mage-Frost','Paladin-Protection','Shaman-Elemental','DeathKnight-Frost','Rogue-Subtlety','Rogue-Assassination',}
local provider = {region='CN',realm='德拉诺',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adelais:BAAALgAECgYJBwAAAA==.',
Al='Alita:BAACLgAFFH8FAAIBAAIJgxjCFACbAAABAAIJgxjCFACbAAAuAAQKfx0AAgEACAmeF+MHAMoBAAEACAmeF+MHAMoBAAAA.',
An='Anguish:BAAALgAECgIJAgAAAA==.',
Bo='Bobstars:BAAALgADCgEJAgAAAA==.',
Ch='Chloris:BAAALgADCgEJAQAAAA==.',
De='Demeter:BAAALgAECggJDgAAAA==.',
Dp='Dptlr:BAAALgAFFAIJAgAAAA==.',
En='Engrave:BAAALgAECgEJAgAAAA==.',
Fs='Fses:BAAALgADCgcJBwAAAA==.',
Gg='Ggk:BAAALgADCgEJAQAAAA==.',
Go='Go:BAAALgAECgQJBAAAAA==.Goffy:BAABLgAFFH8GAAICAAQJHRKsCwBOAQACAAQJHRKsCwBOAQABLgAFFAQJCwADANAQAA==.Gogo:BAAALgADCgQJBAAAAA==.',
Gu='Guoguoguo:BAAALgAECgYJBwABLgAFFAYJCgAEAHUWAA==.',
Le='Leona:BAAALgAECgcJCwAAAA==.',
Mi='Mic:BAAALgAECgMJBgAAAA==.',
No='Noreternal:BAAALgAECggJCAAAAA==.',
Ny='Nyx:BAAALgADCgcJCQAAAA==.',
Sa='Sabrinalee:BAABLgAECn8XAAIFAAYJshXxQwByAQAFAAYJshXxQwByAQAAAA==.',
So='Solaray:BAAALgAECgUJBQAAAA==.',
Th='Theweak:BAAALgADCgEJAQAAAA==.',
['一只']='一只鸟儿飞:BAAALgADCgYJAwAAAA==.',
['一夜']='一夜:BAAALgAECgUJBQAAAA==.',
['一时']='一时不用禅:BAABLgAECn8ZAAIGAAgJ2RzRCgC0AgAGAAgJ2RzRCgC0AgAAAA==.',
['一杯']='一杯浓茶:BAAALgAECgcJEwAAAA==.',
['上帝']='上帝宠爱初音:BAAALgAECgcJCgAAAA==.',
['不潮']='不潮不用花钱:BAAALgAECgcJEwAAAA==.',
['丑破']='丑破天际:BAAALgADCgUJBQAAAA==.',
['丛林']='丛林飘移:BAAALgAECgEJAgAAAA==.',
['东墙']='东墙望天涌:BAAALgAECgEJAgABLgAECgMJAgAHAAAAAA==.',
['丢了']='丢了车的拓海:BAAALgAECgUJBQAAAA==.',
['丨为']='丨为了脸萌:BAAALgAECgEJAgAAAA==.',
['丨宝']='丨宝贝丨:BAAALgADCgUJBQAAAA==.',
['丨杲']='丨杲丨:BAAALgAECgUJCgAAAA==.',
['丨欧']='丨欧莱雅丨:BAABLgAECn8dAAICAAcJvB99KwB2AgACAAcJvB99KwB2AgAAAA==.',
['中泰']='中泰百货第一:BAAALgAECgIJAQAAAA==.',
['丶战']='丶战无不胜:BAAALgADCgEJAQAAAA==.',
['丶杀']='丶杀戮盛宴:BAAALgAECgcJCAAAAA==.',
['丶酷']='丶酷乐儿:BAAALgAECgYJBwAAAA==.',
['丿情']='丿情義無價灬:BAAALgADCgcJDAAAAA==.',
['丿无']='丿无处安放丶:BAAALgAFFAIJAgAAAA==.',
['乐居']='乐居:BAAALgAECgEJAQAAAA==.',
['九五']='九五:BAAALgAECgkJBgAAAA==.',
['予默']='予默:BAABLgAFFH8HAAIIAAIJlhNOJwCkAAAIAAIJlhNOJwCkAAAAAA==.',
['事了']='事了拂衣去:BAAALgAECgQJCwAAAA==.',
['二向']='二向箔:BAACLgAFFH8GAAIJAAIJwAfVEACdAAAJAAIJwAfVEACdAAAuAAQKfxwABAoABwlzEiggAJIBAAoABwlzEiggAJIBAAkABQl/BxRNAKEAAAsAAglBBv10AFUAAAAA.',
['亵渎']='亵渎与毁灭:BAAALgADCgQJBAAAAA==.',
['人中']='人中灬吕布:BAAALgAECgIJAgAAAA==.',
['仁波']='仁波切丿铁霖:BAAALgAECgMJBAAAAA==.',
['以沫']='以沫灬:BAACLgAFFH8FAAIDAAIJmRSbPQCjAAADAAIJmRSbPQCjAAAuAAQKfxkAAgMACAnFHzoZAOUCAAMACAnFHzoZAOUCAAAA.',
['伊兰']='伊兰迪尔:BAAALgAECgEJAQAAAA==.',
['伊瑞']='伊瑞尔灬主教:BAAALgAFFAEJAQAAAA==.',
['传说']='传说级工具人:BAAALgADCgQJBAAAAA==.',
['伽喱']='伽喱:BAAALgADCgYJBgAAAA==.',
['余帘']='余帘:BAAALgAECgUJCAAAAA==.',
['倚剑']='倚剑挽流沙:BAAALgADCgEJAQAAAA==.',
['做了']='做了错饭:BAAALgAECgUJAQAAAA==.',
['傍晚']='傍晚:BAAALgAFFAMJBAAAAA==.',
['傲慢']='傲慢术术:BAAALgADCgcJBwAAAA==.',
['先定']='先定个小目标:BAAALgAECgYJBgAAAA==.',
['六月']='六月的飞花:BAAALgADCgUJBQAAAA==.',
['冬瓜']='冬瓜丸子:BAAALgAECgEJAQAAAA==.',
['冰冰']='冰冰忍:BAAALgAFFAEJAQAAAA==.',
['冰凉']='冰凉丶:BAABLgAFFH8HAAIMAAIJiQc5GwCbAAAMAAIJiQc5GwCbAAAAAA==.',
['冷冰']='冷冰的心:BAAALgAECgMJAwAAAA==.',
['凝香']='凝香筱筱:BAAALgAECgQJBAAAAA==.',
['利爪']='利爪望天涌:BAAALgAECgMJAgAAAA==.',
['别打']='别打那萨满:BAAALgAFFAEJAgAAAA==.',
['别里']='别里科夫:BAAALgAECgEJAgAAAA==.',
['加尔']='加尔鲁什酋长:BAAALgAECgYJBwAAAA==.',
['化为']='化为千风:BAAALgAFFAEJAgAAAA==.',
['十骑']='十骑当一千:BAAALgAECgQJBgAAAA==.',
['千里']='千里燎烽火:BAAALgADCgcJBwAAAA==.',
['卡加']='卡加:BAAALgAECgUJBQAAAA==.',
['卡哇']='卡哇伊圻:BAAALgAECgQJBAAAAA==.',
['卡扎']='卡扎妃:BAAALgADCgEJAQAAAA==.',
['卡格']='卡格瓦意志:BAAALgAECgEJAQAAAA==.',
['卫三']='卫三爷:BAAALgAECgEJAgAAAA==.',
['双刀']='双刀狼:BAAALgAECgEJAQAAAA==.',
['合欢']='合欢冢:BAAALgAECgEJAQAAAA==.',
['吚利']='吚利丹丶怒風:BAAALgADCgQJBAAAAA==.',
['君陌']='君陌:BAAALgAECgMJAwAAAA==.',
['吼少']='吼少俠:BAAALgAECgQJBQAAAA==.',
['咆哮']='咆哮的鹌鹑:BAACLgAFFH8JAAIEAAMJ8BqQDgD3AAAEAAMJ8BqQDgD3AAAuAAQKfyQAAwQACAmEHuwMAMoCAAQACAmEHuwMAMoCAA0AAQmzCbY1AB8AAAAA.',
['咩咩']='咩咩怪:BAABLgAFFH8GAAIOAAQJ7gLuGwAWAQAOAAQJ7gLuGwAWAQAAAA==.',
['哈士']='哈士琦:BAAALgAECgUJBAAAAA==.',
['喝酒']='喝酒会发红:BAAALgAECgYJDQAAAA==.',
['喵姆']='喵姆萨斯:BAAALgAECgIJAgAAAA==.',
['嘎嘣']='嘎嘣脆儿:BAAALgADCgUJBQAAAA==.',
['四夕']='四夕若若:BAAALgAECgYJBgAAAA==.',
['四顾']='四顾剑:BAAALgAECgMJAwAAAA==.',
['国士']='国士无双:BAAALgAECgUJCAAAAA==.',
['圣光']='圣光凤梨:BAAALgAECgQJBAAAAA==.',
['地狱']='地狱咆哮:BAAALgADCgcJBwAAAA==.',
['埃辛']='埃辛诺斯戰刃:BAABLgAECn8ZAAIIAAkJJBvXEgDpAgAIAAkJJBvXEgDpAgAAAA==.',
['墨染']='墨染流年:BAAALgAECgYJBgAAAA==.',
['墨殇']='墨殇:BAAALgAECgYJDwAAAA==.',
['墨莎']='墨莎菇凉:BAAALgAECgQJBAAAAA==.',
['壮壮']='壮壮呀:BAAALgAECgMJAwAAAA==.',
['复苏']='复苏的苏:BAAALgAECgUJBQAAAA==.',
['夜愿']='夜愿:BAAALgADCgUJBQAAAA==.',
['夜月']='夜月杀:BAABLgAFFH8IAAIDAAMJfR2uIwAHAQADAAMJfR2uIwAHAQAAAA==.',
['大哥']='大哥我真抽了:BAAALgAECgcJDwAAAA==.',
['大闪']='大闪电:BAAALgAECgYJBgAAAA==.',
['大饼']='大饼卷一切:BAAALgAECgYJCAAAAA==.',
['大鱼']='大鱼破雾:BAAALgAECgEJAQAAAA==.',
['大鹅']='大鹅:BAAALgADCgYJBgAAAA==.',
['天野']='天野:BAAALgAECgEJAgAAAA==.',
['天青']='天青色瞪眼鱼:BAAALgADCgIJAgAAAA==.',
['女施']='女施主不要停:BAAALgAECgIJAgAAAA==.',
['妹妹']='妹妹不高兴:BAAALgAECgQJBAAAAA==.',
['孙殿']='孙殿英考古:BAACLgAFFH8DAAMPAAIJ1g6sFABVAAAPAAEJBxKsFABVAAAOAAEJpAtzTABOAAAuAAQKfxYABA8ACAmEHuEUAKQBAA8ABwl5F+EUAKQBAA4ABQnNHYgZAEcBABAAAQm6IQIkAGIAAAAA.',
['宇宙']='宇宙第一蝾螈:BAAALgAECgEJAgAAAA==.',
['安全']='安全第一:BAAALgADCgEJAQAAAA==.',
['完事']='完事后分手:BAAALgADCgcJBwAAAA==.',
['宝贝']='宝贝喵:BAAALgAECgEJAQAAAA==.',
['寒剑']='寒剑君子意:BAAALgADCgMJAwAAAA==.',
['寒跑']='寒跑跑:BAAALgADCgIJAgAAAA==.',
['小土']='小土星:BAAALgADCgQJBAAAAA==.',
['小小']='小小崽:BAAALgAECgIJAgAAAA==.',
['小灬']='小灬恶灬魔:BAAALgAECgUJBQAAAA==.',
['小老']='小老弟:BAAALgAECgYJBgAAAA==.',
['小聪']='小聪明闪电:BAAALgADCgYJDAAAAA==.',
['小郡']='小郡肝串串:BAAALgAECgMJAwAAAA==.',
['少年']='少年机器猫:BAAALgADCgEJAQAAAA==.',
['就差']='就差一丢丢儿:BAAALgAECgYJBgAAAA==.',
['屁桃']='屁桃酱酱:BAAALgADCgUJBQAAAA==.',
['屠戮']='屠戮东少:BAABLgAECn8jAAMRAAkJbSB+AAAEAwARAAkJWSB+AAAEAwASAAkJZxoLDQDcAgABLgAFFAQJBAAHAAAAAA==.',
['山里']='山里的尛红人:BAAALgAECgUJBgAAAA==.',
['带头']='带头大哥:BAAALgAFFAIJAgAAAA==.',
['幼儿']='幼儿园扛把子:BAAALgADCgEJAQAAAA==.',
['幽冥']='幽冥魔神:BAAALgAECgQJBAAAAA==.',
['库帕']='库帕城堡:BAABLgAFFH8HAAITAAMJPBvsAgAPAQATAAMJPBvsAgAPAQAAAA==.',
['开始']='开始了吗:BAAALgAECgEJAQAAAA==.',
['弜弜']='弜弜:BAAALgAECgMJAwAAAA==.',
['影冰']='影冰:BAAALgAECgUJBgAAAA==.',
['彻底']='彻底疯狂:BAAALgAECgEJAQAAAA==.',
['微云']='微云似梦:BAAALgAECgkJCQABLgAFFAQJBAAHAAAAAA==.',
['微灬']='微灬凉:BAACLgAFFH8FAAIOAAMJtRQpFQC6AAAOAAMJtRQpFQC6AAAuAAQKfyMAAw4ACAluHzsGABACAA4ABwmXHzsGABACAA8ABAkBEqouAAEBAAAA.',
['德尔']='德尔皮耶罗:BAAALgADCgMJAwAAAA==.',
['心中']='心中恶魔:BAAALgADCgcJCQAAAA==.',
['恒温']='恒温壶:BAAALgADCgcJBwAAAA==.',
['悲伤']='悲伤自愈:BAAALgAECgUJCQAAAA==.',
['惗丶']='惗丶旧:BAAALgAECgMJAwAAAA==.',
['愛的']='愛的戰士:BAEALgAECggJEwAAAA==.',
['慕楠']='慕楠芝:BAAALgAECgQJBAAAAA==.',
['懒肉']='懒肉球:BAAALgAECgcJDAAAAA==.',
['成为']='成为曹贼:BAAALgAECgYJBgAAAA==.',
['我哭']='我哭了来哄我:BAAALgADCgYJBwAAAA==.',
['我型']='我型我素:BAAALgADCgIJAgAAAA==.',
['我放']='我放了个屁就:BAAALgAECggJDAAAAA==.',
['我飘']='我飘啊飘啊飘:BAAALgAFFAMJAwAAAA==.',
['拉美']='拉美莫尔:BAAALgAECgYJAwAAAA==.',
['指南']='指南:BAAALgAECgEJAQAAAA==.',
['捷拉']='捷拉奥拉:BAAALgAECgYJBgAAAA==.',
['摇滚']='摇滚德:BAAALgAECgQJBwAAAA==.',
['撒汤']='撒汤小笼包:BAAALgAECgMJAgAAAA==.',
['教育']='教育网专区:BAABLgAFFH8PAAMMAAUJ+yGCAQByAQAMAAQJHh+CAQByAQAUAAIJTyYnCABxAAAAAA==.教育网专区喵:BAAALgAFFAEJAQABLgAFFAUJDwAMAPshAA==.教育网专区噗:BAAALgAECgUJCQABLgAFFAUJDwAMAPshAA==.',
['文雀']='文雀:BAAALgAECgQJCAAAAA==.',
['旁边']='旁边有雪碧:BAAALgAFFAEJAgAAAA==.',
['无法']='无法爆头:BAAALgAECgQJBAAAAA==.',
['时刻']='时刻牢记圣光:BAAALgADCgIJAgAAAA==.',
['明天']='明天再减肥:BAAALgADCggJBwAAAA==.',
['是崽']='是崽崽子啊:BAAALgAECgMJAwAAAA==.',
['晨雀']='晨雀:BAACLgAFFH8HAAIFAAMJ0h4MDAAZAQAFAAMJ0h4MDAAZAQAuAAQKfxYAAgUACAnjHJsUAHACAAUACAnjHJsUAHACAAAA.',
['暗之']='暗之右手:BAAALgAECgYJCgAAAA==.',
['暗夜']='暗夜巨魔:BAAALgAECgYJBgAAAA==.',
['暮色']='暮色收割者:BAAALgAECgQJBAAAAA==.',
['暴走']='暴走扳手:BAAALgAECgMJBQAAAA==.暴走铁锤:BAAALgAECgQJBAAAAA==.',
['曾经']='曾经的超胆侠:BAAALgAECgQJBQAAAA==.',
['月光']='月光海洋:BAAALgAECgUJBQAAAA==.',
['月影']='月影残空:BAABLgAECn8YAAQVAAcJ4wX0fgDdAAAVAAYJXgX0fgDdAAANAAYJ9gTBJQBvAAAEAAEJ1AM9iwAkAAAAAA==.',
['朕赦']='朕赦你无罪:BAAALgADCgMJAwAAAA==.',
['朕麝']='朕麝你無罪:BAAALgAECgEJAQAAAA==.',
['期待']='期待依旧空白:BAAALgAECgcJDAAAAA==.',
['杀生']='杀生成仁:BAAALgAECgIJAgAAAA==.',
['杨崽']='杨崽儿:BAAALgAECgcJEgAAAA==.',
['板板']='板板儿:BAAALgAECgEJAQAAAA==.',
['枭兽']='枭兽大火球:BAAALgADCgIJAgAAAA==.',
['枯守']='枯守青灯:BAAALgADCgYJBgAAAA==.',
['柒月']='柒月:BAAALgAECgQJBAAAAA==.',
['柯罗']='柯罗诺斯炽焰:BAAALgAECgQJBwAAAA==.',
['梨花']='梨花尽如霜:BAAALgAECgcJDQAAAA==.',
['梵月']='梵月:BAAALgAECgUJBwAAAA==.',
['椿日']='椿日:BAAALgAECgkJCwAAAA==.',
['樱辰']='樱辰花陨:BAAALgAECgEJAQAAAA==.',
['欲望']='欲望战魔:BAAALgAECgUJBwAAAA==.',
['正义']='正义使者:BAAALgADCgQJBAAAAA==.',
['武陵']='武陵桐:BAAALgAECgUJCAAAAA==.',
['毁灭']='毁灭莲心:BAAALgADCgcJBwAAAA==.',
['每天']='每天酸菜鱼:BAAALgADCgMJAwAAAA==.',
['比奇']='比奇堡扛把子:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛雨:BAAALgAECgcJBwAAAA==.',
['永恒']='永恒之握:BAAALgAECgEJAQAAAA==.永恒太阿星:BAABLgAFFH8FAAICAAIJnAWOKACWAAACAAIJnAWOKACWAAAAAA==.',
['波了']='波了:BAAALgAECgIJAgAAAA==.',
['注重']='注重思想引领:BAAALgAECgQJBAAAAA==.',
['洛迪']='洛迪亚斯:BAAALgAECgYJBwAAAA==.',
['浪人']='浪人归来:BAAALgAECgEJAQAAAA==.浪人重修:BAAALgAECgEJAQAAAA==.',
['浪灬']='浪灬人:BAAALgAECgMJAwAAAA==.',
['海之']='海之妖僧:BAAALgAECgUJCgAAAA==.',
['海军']='海军统帅:BAAALgAECgYJBwAAAA==.',
['涅娜']='涅娜:BAAALgAECgUJBgAAAA==.',
['深度']='深度冻结丶:BAABLgAECn8VAAIWAAkJWh2/GQARAwAWAAkJWh2/GQARAwAAAA==.',
['深渊']='深渊矿工:BAAALgAECgQJBAAAAA==.',
['清风']='清风月影:BAAALgAECgcJBwAAAA==.清风笑落叶:BAAALgAFFAEJAgAAAA==.',
['游小']='游小鱼:BAABLgAECn8cAAIWAAgJohadWwAnAgAWAAgJohadWwAnAgAAAA==.',
['火丸']='火丸子:BAAALgAECgEJAQAAAA==.',
['灬倾']='灬倾澜:BAAALgAECgcJCwAAAA==.',
['灬兔']='灬兔斯基灬:BAAALgAECgEJAQAAAA==.',
['灬尛']='灬尛酒窩灬:BAAALgAECgkJBwAAAA==.',
['灬运']='灬运运灬:BAAALgAECgYJDwAAAA==.',
['灵也']='灵也有天堂:BAAALgAFFAEJAQAAAA==.灵也有希望:BAABLgAFFH8OAAMXAAQJvAL8AwCdAAAXAAQJigH8AwCdAAACAAEJIwZ/OABIAAAAAA==.',
['灵小']='灵小蛮:BAAALgAECgEJAQAAAA==.',
['煎饼']='煎饼果子:BAAALgAECgEJAgAAAA==.',
['熊熊']='熊熊有责:BAAALgAECgQJBAAAAA==.',
['燚燚']='燚燚:BAAALgADCgMJAwAAAA==.',
['爆走']='爆走小德:BAAALgADCgQJBAAAAA==.爆走小术:BAAALgADCgEJAQAAAA==.',
['爱忘']='爱忘东西的我:BAAALgAECgcJDwAAAA==.',
['牛头']='牛头牌剥皮机:BAAALgAECgQJCQAAAA==.',
['狂噬']='狂噬:BAABLgAECn8VAAIOAAYJ6A5ChwBLAQAOAAYJ6A5ChwBLAQAAAA==.',
['狗二']='狗二丹:BAAALgADCgMJAwAAAA==.',
['猫咪']='猫咪不在家:BAAALgAECgYJDgAAAA==.',
['王蜀']='王蜀黍:BAACLgAFFH8FAAIFAAIJbB59FAC2AAAFAAIJbB59FAC2AAAuAAQKfx0AAxgACAlzH1MBAIUCABgACAlzH1MBAIUCAAUABgleGq8tANMBAAAA.',
['玛雅']='玛雅王:BAAALgAECgUJCwAAAA==.',
['生命']='生命猎食者:BAAALgAECgEJAQAAAA==.',
['癫火']='癫火:BAAALgAECgIJAgABLgAFFAYJBAAHAAAAAA==.',
['白天']='白天空洞洞:BAAALgAECgYJEAAAAA==.',
['白月']='白月光:BAAALgAECgEJAQAAAA==.',
['白熊']='白熊:BAABLgAFFH8LAAMDAAQJ0BDfFgBJAQADAAQJ0BDfFgBJAQAZAAEJjAQAAAAAAAAAAA==.',
['白银']='白银骑士:BAAALgAECgIJAgAAAA==.',
['眉温']='眉温如初:BAAALgAECgUJBAAAAA==.',
['真滴']='真滴很漂酿:BAAALgAECgEJAQAAAA==.',
['矼死']='矼死的魚:BAAALgAECgcJCQAAAA==.',
['砍人']='砍人是犯法的:BAAALgADCgEJAQAAAA==.',
['磨牙']='磨牙磨牙:BAABLgAFFH8IAAMKAAQJABg3FACUAAAKAAIJlw03FACUAAALAAQJABgAAAAAAAAAAA==.',
['神圣']='神圣小德:BAAALgAECgMJBAAAAA==.',
['祭汐']='祭汐:BAAALgAECggJCAAAAA==.',
['离火']='离火弈长生:BAAALgAECgYJBgABLgAFFAIJAgAHAAAAAA==.',
['秧歌']='秧歌斯达:BAAALgAECgkJCQABLgAFFAUJBAAHAAAAAA==.',
['移情']='移情丶别恋:BAABLgAFFH8HAAIaAAMJFAyhDgAGAQAaAAMJFAyhDgAGAQAAAA==.',
['穿心']='穿心:BAABLgAFFH8FAAIRAAIJ9QZeGgCcAAARAAIJ9QZeGgCcAAAAAA==.',
['第二']='第二梦:BAAALgAECgEJAQAAAA==.',
['第十']='第十个满级号:BAAALgAECgEJAgAAAA==.',
['红唛']='红唛卜鎏子:BAAALgADCgMJAwAAAA==.',
['红豆']='红豆包:BAAALgAECgYJCAAAAA==.',
['绯色']='绯色月下:BAAALgAECgEJAQABLgAECgIJBAAHAAAAAA==.',
['羽田']='羽田优:BAAALgAFFAQJBAAAAA==.',
['翡翠']='翡翠仙人:BAAALgADCgcJBwAAAA==.',
['职业']='职业老奶:BAAALgAECgYJBgAAAA==.',
['至尊']='至尊冥帝:BAAALgAECgEJAQAAAA==.',
['艾利']='艾利文:BAACLgAFFH8FAAIaAAIJghemEQC8AAAaAAIJghemEQC8AAAuAAQKfx0AAxoACAkjHdQDANYBABsABgkMHzoGABcCABoABwmwHNQDANYBAAAA.',
['艾薇']='艾薇:BAAALgAFFAEJAgAAAA==.',
['花柃']='花柃:BAAALgAECgEJAQAAAA==.',
['萨拉']='萨拉塔寺:BAAALgAECgYJBgAAAA==.',
['萨莱']='萨莱尼娅:BAAALgAECgIJAgAAAA==.',
['蒂尔']='蒂尔安妲:BAAALgADCgEJAQAAAA==.',
['虚空']='虚空多雷:BAAALgAECgIJBQAAAA==.',
['虾米']='虾米酥:BAAALgAECgYJEQAAAA==.',
['蚀光']='蚀光:BAAALgADCgYJBgAAAA==.',
['蛋那']='蛋那个蛋:BAAALgAECgYJDgAAAA==.',
['融化']='融化天僧:BAAALgADCgEJAQAAAA==.',
['西米']='西米鹿鹿:BAAALgAECgMJAwAAAA==.',
['让我']='让我来:BAABLgAECn8UAAIWAAYJlCLKYAAZAgAWAAYJlCLKYAAZAgAAAA==.',
['豆子']='豆子哥:BAAALgAECgEJAgAAAA==.',
['豹猫']='豹猫:BAAALgADCgcJBwAAAA==.',
['贱随']='贱随心动:BAAALgAECgYJCgAAAA==.',
['费斯']='费斯科:BAAALgAECgYJDwAAAA==.',
['路边']='路边的橘子:BAAALgAECgcJBwAAAA==.',
['运运']='运运:BAACLgAFFH8HAAIVAAMJBCP7CQA4AQAVAAMJBCP7CQA4AQAuAAQKfyMAAhUACAluJQABAP8CABUACAluJQABAP8CAAAA.',
['追忆']='追忆秋声:BAAALgADCgUJBQAAAA==.',
['追星']='追星逐月:BAAALgADCgcJBwAAAA==.',
['逝去']='逝去灬的秋:BAAALgAFFAIJAgABLgAFFAQJBAAHAAAAAA==.',
['速帕']='速帕塞娅人:BAAALgAECgUJBQAAAA==.',
['道士']='道士:BAAALgAECgYJBgAAAA==.',
['邪帝']='邪帝凯:BAAALgADCgIJAgAAAA==.',
['都说']='都说我瞎面咸:BAAALgAFFAEJAQAAAA==.',
['酷酷']='酷酷的叮叮:BAAALgAECgQJBAAAAA==.',
['鏡影']='鏡影:BAAALgAECgUJBQAAAA==.',
['锤锤']='锤锤暴击:BAAALgAECgMJAwAAAA==.',
['镜影']='镜影:BAABLgAECn8XAAIDAAgJrRcdQgAwAgADAAgJrRcdQgAwAgAAAA==.',
['闪电']='闪电丿杨永信:BAAALgAECgIJAgAAAA==.',
['阳春']='阳春三月:BAAALgAECgEJAQAAAA==.',
['阿斯']='阿斯卡纶:BAAALgAFFAIJAgAAAA==.',
['阿爾']='阿爾托利亞:BAAALgAFFAIJAgAAAA==.',
['陆小']='陆小凤:BAAALgAECgkJCgAAAA==.',
['集火']='集火哪个傻馒:BAAALgAECgEJAQAAAA==.',
['霜影']='霜影之伤:BAAALgAECgcJBwAAAA==.',
['霸王']='霸王怒:BAAALgAECgEJAQAAAA==.霸王橙:BAAALgAECgEJAQAAAA==.',
['靑山']='靑山:BAAALgAECgEJAQAAAA==.靑山术:BAAALgADCgIJAgAAAA==.靑山箭:BAAALgAECgEJAQAAAA==.靑山骑:BAAALgAECgUJBQAAAA==.',
['青城']='青城山莽撞人:BAAALgADCgcJBwAAAA==.',
['青空']='青空断翼:BAAALgADCgEJAwAAAA==.',
['颛瞬']='颛瞬黑白:BAAALgAECgQJBwAAAA==.',
['风洐']='风洐之翼:BAAALgAECgEJAQAAAA==.',
['风舞']='风舞龙溟:BAAALgAFFAEJAgAAAA==.',
['风行']='风行水上丶:BAAALgAECgIJBAAAAA==.',
['风过']='风过灬凄凉:BAABLgAFFH8FAAIRAAUJKhctCgDUAAARAAUJKhctCgDUAAABLgAFFAYJBQASACQLAA==.',
['饭萌']='饭萌了没:BAAALgAECgUJBQAAAA==.',
['黑锋']='黑锋丿姥姥:BAAALgAECgEJAQAAAA==.',
['黑魔']='黑魔导女孩:BAAALgAECgYJCQAAAA==.',
['鼻涕']='鼻涕猫猫:BAAALgAECgEJAwAAAA==.',
['齉齾']='齉齾爩灪纞虋:BAAALgAECgkJBwAAAA==.',
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
