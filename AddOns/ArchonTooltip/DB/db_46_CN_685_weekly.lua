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

local lookup = {'Priest-Holy','Mage-Frost','Mage-Fire','Shaman-Enhancement','Shaman-Elemental','Druid-Restoration','Hunter-BeastMastery','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Hunter-Marksmanship','DeathKnight-Unholy','Warrior-Protection','Warrior-Fury','Rogue-Subtlety','Priest-Discipline','Priest-Shadow','Unknown-Unknown','DemonHunter-Havoc','Evoker-Devastation','Evoker-Augmentation','Paladin-Retribution','Shaman-Restoration','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','DemonHunter-Devourer',}
local provider = {region='CN',realm='扎拉赞恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Bananabb:BAAALgAECgQJBAAAAA==.',
Be='Berial:BAAALgAECgIJAgAAAA==.',
Bl='Bluebones:BAAALgAECgQJBQAAAA==.',
Ca='Carrotl:BAAALgAECgEJAgAAAA==.',
Do='Dogcpj:BAACLgAFFH8JAAIBAAMJdB3IBgAKAQABAAMJdB3IBgAKAQAuAAQKfx4AAgEABwlkIckOAHICAAEABwlkIckOAHICAAAA.Dogf:BAAALgADCggJBQAAAA==.Dogjpc:BAACLgAFFH8FAAICAAMJnw29LQAAAQACAAMJnw29LQAAAQAuAAQKfxgAAwIABwnGGZxfABwCAAIABwkjGZxfABwCAAMABgmgDaQGAC8BAAEuAAUUBQkGAAIANB0A.Dogs:BAAALgAFFAQJBAAAAA==.',
Ei='Einherjar:BAAALgAECgYJCgAAAA==.',
Le='Levoglucosan:BAAALgADCgEJAQAAAA==.',
Md='Mdlee:BAAALgAECgcJCAAAAA==.Mdpt:BAAALgAECgQJBAAAAA==.',
Me='Meisarah:BAAALgADCgIJAgAAAA==.Mesfs:BAAALgAECgYJBgAAAA==.',
Oo='Oops:BAAALgAFFAEJBAAAAA==.',
Ru='Rudiger:BAACLgAFFH8IAAMEAAMJUAO+AwDYAAAEAAMJMAO+AwDYAAAFAAMJ2QGKCAC9AAAuAAQKfyAAAwUACAk7EV4wAJ4BAAQABwk/E2MQALEBAAUACAlQDF4wAJ4BAAAA.',
Sa='Samularia:BAACLgAFFH8bAAICAAcJkBfhAQCAAgACAAcJkBfhAQCAAgAuAAQKfxUAAgIABwmUIWxZAC0CAAIABwmUIWxZAC0CAAEuAAUUBAkHAAYA/xQA.',
Ss='Ssmack:BAAALgAECgEJAQAAAA==.',
St='Startoverr:BAABLgAFFH8GAAIHAAIJHBBAGACmAAAHAAIJHBBAGACmAAAAAA==.',
To='Tobislz:BAAALgAECgEJAQAAAA==.',
Yl='Ylina:BAAALgAECgEJAQAAAA==.',
Za='Zayne:BAAALgAECgUJBQAAAA==.',
Zo='Zoraa:BAAALgADCgMJAwAAAA==.',
Zx='Zxiaojiang:BAAALgAECgYJBgAAAA==.',
['一个']='一个小法施:BAAALgAECgIJAgAAAA==.',
['一亿']='一亿只大猫:BAAALgAECgYJBQAAAA==.',
['一竹']='一竹布衣:BAAALgAECgEJAQAAAA==.',
['七元']='七元:BAAALgADCgYJBgAAAA==.',
['七圆']='七圆:BAAALgAFFAQJBAAAAA==.',
['万物']='万物回春:BAAALgAECgUJAQAAAA==.',
['上勾']='上勾拳船长:BAAALgAECgYJCQAAAA==.',
['不爱']='不爱吃竹叶:BAABLgAECn8XAAQIAAgJEhzqGQDtAQAIAAcJgBvqGQDtAQAJAAUJgBaGQAAWAQAKAAIJgwvhcwByAAAAAA==.',
['且听']='且听风吟丷:BAAALgAECgEJAQAAAA==.',
['丨亡']='丨亡者归来丨:BAAALgAECgEJAQAAAA==.',
['丨射']='丨射丨咪丨咪:BAABLgAFFH8GAAMLAAMJexeNGgCuAAALAAIJDxWNGgCuAAAHAAIJDRLVEgBgAAAAAA==.',
['丨红']='丨红豆丨:BAAALgAECgYJCAAAAA==.',
['丨范']='丨范迪塞尔丨:BAAALgAECgEJAQAAAA==.',
['丶不']='丶不明觉厉:BAAALgAECgYJCgAAAA==.',
['丶埃']='丶埃辛诺斯丶:BAAALgAECgQJBAAAAA==.',
['丶大']='丶大萌德:BAAALgAECgYJBgAAAA==.',
['丶寒']='丶寒羽丶:BAAALgAECgUJDAABLgAFFAUJEAACAFIlAA==.',
['丶我']='丶我才是大猫:BAAALgAFFAIJAgAAAA==.',
['丶战']='丶战我所战丿:BAAALgAECgcJDgABLgAFFAQJDgAMAOcjAA==.',
['丶景']='丶景彡:BAAALgAECgEJAQAAAA==.',
['丶神']='丶神罚丶:BAAALgAECgIJAgAAAA==.',
['丶米']='丶米拉杰:BAAALgAECgUJBQAAAA==.',
['丹阳']='丹阳子:BAAALgAECgQJBAAAAA==.',
['乂叽']='乂叽里咕噜:BAAALgADCgUJBgAAAA==.',
['九月']='九月楓叶:BAAALgAECgQJBQAAAA==.',
['乱世']='乱世大冰球:BAABLgAFFH8HAAICAAMJlgqjLgD8AAACAAMJlgqjLgD8AAAAAA==.乱世小匪:BAABLgAECn8VAAMNAAcJ0g4sJgANAQANAAYJ+AssJgANAQAOAAIJAxIYjwCCAAABLgAFFAMJBwACAJYKAA==.乱世小蹄子:BAAALgAECgMJAwAAAA==.乱世海匪:BAAALgAFFAIJAgAAAA==.乱世猎手:BAAALgADCgYJCAAAAA==.',
['人閒']='人閒大炮:BAAALgAECgMJBQAAAA==.',
['伊达']='伊达司:BAAALgAECgYJDwAAAA==.',
['伽蓝']='伽蓝之堂:BAAALgAECgkJAQAAAA==.',
['低調']='低調灬莫扎特:BAAALgAFFAIJAgAAAA==.',
['你指']='你指聢能行丶:BAAALgAECgYJBgAAAA==.',
['你没']='你没我好看:BAAALgADCgUJBgAAAA==.',
['你笑']='你笑个屁:BAAALgAECgcJBgAAAA==.',
['俺有']='俺有飞毛腿:BAAALgAECgEJAQAAAA==.',
['倾覆']='倾覆天星:BAACLgAFFH8JAAIPAAQJXBKOCABiAQAPAAQJXBKOCABiAQAuAAQKfxcAAg8ACAkyGFgRAJYCAA8ACAkyGFgRAJYCAAAA.',
['偲灬']='偲灬夜空:BAABLgAECn8VAAMQAAgJXxvODwBCAgAQAAgJXxvODwBCAgARAAEJAABPXwA6AAAAAA==.',
['公鸡']='公鸡开大巴:BAAALgADCgEJAQAAAA==.',
['兮月']='兮月:BAAALgAECgcJAwAAAA==.',
['冬月']='冬月屮枫:BAAALgAECgQJBQAAAA==.',
['冰伈']='冰伈灬:BAAALgAECgUJCAAAAA==.',
['凡尔']='凡尔赛提斯:BAABLgAECn8XAAMHAAYJPh+zIwAwAgAHAAYJPh+zIwAwAgALAAEJlhqwfgBLAAAAAA==.',
['凯蒂']='凯蒂小木木:BAAALgAECgQJAwAAAA==.',
['凶残']='凶残的熊宝宝:BAAALgAECgcJBgAAAA==.',
['凶狠']='凶狠的熊宝宝:BAAALgAECgYJCAAAAA==.',
['初代']='初代达达桑:BAAALgADCgUJBQAAAA==.',
['初戀']='初戀的滋味:BAAALgADCgIJAgAAAA==.',
['别怕']='别怕我走火:BAAALgAECgUJBwABLgAECgkJFgAHAB4mAA==.',
['加多']='加多寶:BAAALgAECgMJAwAAAA==.',
['半岛']='半岛弥音:BAAALgAECgkJCQAAAA==.',
['卖萌']='卖萌丶僦咑猎:BAAALgAECgIJAgAAAA==.',
['卡尔']='卡尔之光:BAAALgADCgkJCQAAAA==.',
['卡尼']='卡尼琳娜:BAAALgADCgYJCQAAAA==.',
['变大']='变大变粗:BAAALgAECgUJBQAAAA==.',
['叛逆']='叛逆吖:BAAALgAECgQJBAAAAA==.',
['只会']='只会一键输出:BAAALgAFFAQJAgABLgADCgcJBwASAAAAAA==.',
['可惜']='可惜不是伱:BAAALgADCgYJBwAAAA==.',
['呦灬']='呦灬奇奇:BAAALgAFFAQJBAAAAA==.呦灬尛狸:BAAALgAECggJAgAAAA==.呦灬羽涅:BAABLgAECn8bAAMQAAgJvAQtKABVAQAQAAgJvAQtKABVAQABAAMJpwDNcgBcAAAAAA==.呦灬芈芈:BAAALgADCgIJAgAAAA==.',
['咖啡']='咖啡猎手:BAAALgAECgEJAQAAAA==.',
['哥斯']='哥斯丶拉:BAAALgADCgQJBAAAAA==.',
['唇边']='唇边的印痕:BAAALgADCgIJAgAAAA==.',
['喵星']='喵星人的爸爸:BAAALgAFFAEJAQAAAA==.',
['嘟嘟']='嘟嘟丶哒哒:BAAALgAECgEJAgAAAA==.',
['囏鹯']='囏鹯皐軵:BAAALgADCgEJAQAAAA==.',
['四月']='四月天:BAAALgADCgIJAgAAAA==.',
['圣光']='圣光手电筒:BAAALgAECgIJAgAAAA==.圣光炫耀:BAAALgAECgYJBwAAAA==.圣光猫:BAAALgAECgIJAQAAAA==.圣光艾尼路:BAAALgADCgQJBAAAAA==.',
['圣殿']='圣殿鬼谷:BAAALgADCgEJAQAAAA==.',
['坚定']='坚定的信仰:BAAALgADCgYJBgAAAA==.',
['坚果']='坚果熊:BAAALgAECgkJCQAAAA==.',
['埃斯']='埃斯比:BAAALgADCgUJBQAAAA==.',
['塔榙']='塔榙:BAAALgAFFAEJAQAAAA==.',
['壹粒']='壹粒蛋丨怒逼:BAAALgAFFAIJBAAAAA==.',
['夕风']='夕风:BAAALgAECgkJCQABLgAFFAUJBQATAP4TAA==.',
['夜之']='夜之火:BAAALgAECgEJAQAAAA==.',
['夜羽']='夜羽大表哥:BAABLgAECn8aAAMUAAYJQBriEQDCAQAUAAYJQBriEQDCAQAVAAEJcQOaIwAnAAAAAA==.夜羽龙帝:BAAALgAECgYJCgAAAA==.',
['大十']='大十字军之剑:BAAALgAECgQJCQAAAA==.',
['大喜']='大喜:BAAALgADCgYJCQAAAA==.',
['奔跑']='奔跑的阿萨:BAAALgAECgQJBwAAAA==.',
['奥拉']='奥拉夫:BAAALgAECgEJAQAAAA==.',
['奥斯']='奥斯:BAAALgADCgEJAQAAAA==.',
['妆薄']='妆薄铅华浅:BAAALgAECgYJAQAAAA==.',
['妖之']='妖之骄法:BAAALgADCgIJAgAAAA==.',
['姆奶']='姆奶一:BAAALgAFFAEJAQAAAA==.',
['娘口']='娘口三十三:BAAALgAECgcJCgAAAA==.',
['嫡汎']='嫡汎:BAAALgADCggJCAAAAA==.',
['孤儿']='孤儿单扮演者:BAAALgAECgkJDgAAAA==.孤儿蛋三世:BAAALgAECgkJCQAAAA==.',
['宇智']='宇智波灬直巴:BAAALgADCgEJAQAAAA==.',
['守财']='守财财:BAAALgAECgMJAwAAAA==.',
['安灬']='安灬卡妮娜:BAAALgAECgcJAQAAAA==.',
['安迪']='安迪妮娜:BAABLgAECn8ZAAIWAAgJth6LJACVAgAWAAgJth6LJACVAgAAAA==.',
['宝芝']='宝芝林黄师傅:BAAALgAECgUJBgAAAA==.',
['小丶']='小丶浪蹄:BAAALgADCgEJAQAAAA==.',
['小凌']='小凌宝:BAACLgAFFH8JAAIXAAQJWRLuCAA+AQAXAAQJWRLuCAA+AQAuAAQKfxQAAxcABwk/HJQiAA8CABcABgnTH5QiAA8CAAUABwmxEHE3AHQBAAAA.',
['小小']='小小好可爱:BAAALgAECgkJBgAAAA==.小小的熊猫:BAAALgAFFAIJBAAAAA==.小小真可爱:BAAALgAECgcJBwABLgAFFAUJAQASAAAAAA==.',
['小苍']='小苍尤子:BAAALgADCgEJAQAAAA==.',
['小面']='小面:BAAALgAECgQJBwAAAA==.',
['尕狂']='尕狂:BAAALgAECgIJAwAAAA==.',
['尘中']='尘中磨镜人:BAAALgAFFAQJAgAAAA==.',
['就不']='就不加血:BAAALgAECgYJDQAAAA==.',
['就摸']='就摸一下:BAAALgAECgUJBgAAAA==.',
['就这']='就这样离去:BAABLgAFFH8IAAMWAAMJXxMYIACuAAAWAAIJ3RIYIACuAAAYAAEJZBQ5AwA/AAAAAA==.',
['巨木']='巨木蘸酱:BAAALgADCgQJBAAAAA==.',
['巨牧']='巨牧蘸酱:BAAALgAECgYJDwAAAA==.',
['差很']='差很多同学:BAABLgAFFH8FAAIBAAIJjhZKBQCkAAABAAIJjhZKBQCkAAAAAA==.',
['布洛']='布洛克斯希加:BAAALgAECgUJCgAAAA==.',
['帝昊']='帝昊:BAAALgADCgcJCgAAAA==.',
['幽然']='幽然若冰:BAAALgAECgYJDAAAAA==.',
['幽谷']='幽谷清竹:BAAALgAECgEJAQAAAA==.',
['张托']='张托斯:BAAALgAECgEJAgAAAA==.',
['德古']='德古喵大王:BAABLgAFFH8JAAIMAAQJNxq4DQBsAQAMAAQJNxq4DQBsAQAAAA==.',
['心云']='心云:BAAALgADCgEJAQAAAA==.',
['恶飘']='恶飘零:BAAALgAECgEJAQAAAA==.',
['悠哉']='悠哉小桃子:BAAALgAECgEJAQAAAA==.',
['悠悠']='悠悠爱:BAAALgAECgUJDAAAAA==.',
['悠然']='悠然小桃子:BAAALgADCgIJAgAAAA==.',
['悦胖']='悦胖胖:BAABLgAFFH8FAAIIAAMJ6AgSDQDUAAAIAAMJ6AgSDQDUAAAAAA==.',
['情浓']='情浓还是伱浓:BAAALgADCgUJBAAAAA==.',
['我也']='我也抓抓怪:BAAALgAECgMJAwAAAA==.',
['我們']='我們的時代:BAAALgAECgMJAwAAAA==.',
['我怕']='我怕开水烫:BAAALgAFFAEJAQAAAA==.',
['戰痞']='戰痞丨灬狂拽:BAAALgAFFAIJBAAAAA==.',
['执手']='执手:BAAALgAECgYJCwAAAA==.',
['拉风']='拉风的庸医:BAAALgAECgYJDwAAAA==.',
['捡饮']='捡饮料喝:BAAALgAFFAQJAwAAAA==.',
['撞球']='撞球骑士:BAAALgAECgUJBAAAAA==.',
['放着']='放着你来:BAAALgAFFAEJAQAAAA==.',
['新年']='新年新气象:BAAALgADCgIJAgAAAA==.',
['无尽']='无尽梦魇:BAABLgAFFH8HAAMHAAQJxhHYCAD6AAAHAAMJaw7YCAD6AAALAAIJFRasGwCnAAAAAA==.',
['无恶']='无恶:BAAALgAECgYJCgAAAA==.',
['无聊']='无聊不失优雅:BAAALgAECgYJCgAAAA==.',
['无难']='无难:BAAALgAECgYJBgAAAA==.',
['时间']='时间去哪了:BAAALgAECgEJAQAAAA==.',
['明月']='明月风清:BAAALgADCgEJAQAAAA==.',
['星塵']='星塵:BAAALgAECgEJAQAAAA==.',
['春天']='春天在哪里啊:BAAALgAECgQJBAAAAA==.',
['智哥']='智哥碧哥小龙:BAAALgAECgUJBQAAAA==.',
['暗夜']='暗夜狂魔:BAAALgAECgQJBQAAAA==.',
['暗影']='暗影彼得:BAAALgADCgcJBwAAAA==.',
['暗黑']='暗黑之影:BAAALgAFFAEJAQAAAA==.',
['暴躁']='暴躁的香蕉:BAAALgADCgEJAQAAAA==.',
['木鱼']='木鱼哥:BAABLgAFFH8HAAIMAAIJXh2TNgCuAAAMAAIJXh2TNgCuAAAAAA==.',
['本末']='本末倒置:BAAALgAECgcJDQAAAA==.',
['杰尔']='杰尔夫:BAABLgAFFH8KAAIZAAQJYSDkCACbAQAZAAQJYSDkCACbAQAAAA==.',
['柠檬']='柠檬汽水:BAAALgADCgIJAgAAAA==.柠檬矿泉水:BAAALgAECgEJAQAAAA==.',
['椿庭']='椿庭梦澜:BAAALgAECgUJBQAAAA==.',
['檀檀']='檀檀:BAAALgAECgkJAgAAAA==.',
['欧洲']='欧洲二胡王:BAAALgAECgYJBgAAAA==.',
['歆啊']='歆啊:BAAALgADCgcJBwAAAA==.',
['歆歆']='歆歆:BAAALgAECgQJBgAAAA==.歆歆啊:BAAALgADCgYJBgAAAA==.',
['死亡']='死亡光铸:BAABLgAFFH8HAAIMAAMJ1hVfJwD6AAAMAAMJ1hVfJwD6AAAAAA==.',
['水之']='水之静:BAAALgADCggJDgAAAA==.',
['水莲']='水莲心:BAAALgADCgMJAwAAAA==.',
['永恒']='永恒的德:BAAALgAECgYJBgAAAA==.',
['汪锐']='汪锐:BAAALgAECgQJBAAAAA==.',
['沐雨']='沐雨兮兮:BAAALgAECgcJBQAAAA==.沐雨兮月:BAAALgAECgcJAgAAAA==.',
['泫沄']='泫沄丨风:BAAALgAECgYJBgAAAA==.',
['洒家']='洒家戒酒了:BAAALgAECgIJAgAAAA==.',
['流云']='流云战歌:BAABLgAECn8eAAIWAAgJBhUpPgAsAgAWAAgJBhUpPgAsAgAAAA==.',
['流离']='流离指沙间:BAAALgADCgMJAwAAAA==.',
['流风']='流风德悦:BAAALgAECgYJBAAAAA==.',
['海门']='海门刘德华:BAAALgAECgcJBwAAAA==.',
['淼厸']='淼厸:BAAALgAECgQJBAAAAA==.',
['渔叉']='渔叉仙道:BAAALgAFFAEJAQAAAA==.',
['温柔']='温柔的熊宝宝:BAAALgAECgQJCAAAAA==.',
['漠北']='漠北丶天下:BAAALgADCgMJAwAAAA==.',
['潇凡']='潇凡:BAAALgADCgEJAQAAAA==.',
['灭神']='灭神弑天:BAAALgADCgUJBQAAAA==.',
['灰太']='灰太郞:BAAALgAECggJDAAAAA==.',
['灼灼']='灼灼月光:BAAALgAECgEJAQAAAA==.',
['灼眼']='灼眼克蕾雅:BAAALgAECgIJAgAAAA==.',
['烈焰']='烈焰熔炉:BAAALgAECgYJBgAAAA==.',
['烟雨']='烟雨碧落:BAACLgAFFH8MAAIBAAQJcBnOBgAJAQABAAQJcBnOBgAJAQAuAAQKfyAAAgEACQnIHZsGAOQCAAEACQnIHZsGAOQCAAAA.',
['热门']='热门战舰:BAABLgAECn8YAAIEAAgJmRnXCQA2AgAEAAgJmRnXCQA2AgAAAA==.',
['烽火']='烽火戏诸侯丨:BAABLgAFFH8OAAIKAAQJnhB6BAA2AQAKAAQJnhB6BAA2AQAAAA==.',
['無声']='無声:BAABLgAECn8UAAIWAAYJIRUfeACKAQAWAAYJIRUfeACKAQAAAA==.',
['無尽']='無尽的雨:BAAALgAECgIJAwAAAA==.',
['然繎']='然繎:BAAALgAECggJBwAAAA==.',
['燃烧']='燃烧壁垒:BAAALgAECgQJBQAAAA==.',
['爷傲']='爷傲奈我何:BAAALgAECgUJCAAAAA==.',
['狐里']='狐里胡气:BAAALgAECgUJBQAAAA==.',
['狼出']='狼出没:BAAALgAECgQJBgAAAA==.',
['狼啸']='狼啸天下:BAAALgAECgEJAQAAAA==.',
['猎猎']='猎猎风遒:BAAALgADCggJCAAAAA==.',
['瓦林']='瓦林诺:BAAALgADCgUJBQAAAA==.',
['白发']='白发小鬼:BAAALgAECgEJAQAAAA==.',
['盜愺']='盜愺亾:BAAALgAFFAEJAgAAAA==.',
['相逢']='相逢喑未语:BAAALgAFFAEJAQAAAA==.',
['知墨']='知墨:BAAALgAECgYJEwAAAA==.',
['破法']='破法:BAAALgAECgEJAwAAAA==.',
['破甲']='破甲骑士:BAAALgAECgEJAQAAAA==.',
['神圣']='神圣圈圈:BAAALgADCgIJAgAAAA==.',
['神小']='神小诺:BAAALgAECgQJAwAAAA==.',
['神的']='神的王庭:BAAALgAFFAMJAwAAAA==.',
['秦半']='秦半仙:BAAALgAECgEJAQAAAA==.',
['笑霓']='笑霓裳:BAAALgAECgEJAQAAAA==.',
['箭射']='箭射银行:BAAALgAECgEJAQAAAA==.',
['米莉']='米莉娅:BAAALgAFFAQJBAAAAA==.',
['糯米']='糯米:BAAALgAECgEJAQAAAA==.',
['红尘']='红尘逝如烟:BAAALgAECgkJCAAAAA==.',
['给看']='给看翘嘴不:BAAALgAECgUJBQAAAA==.',
['绯色']='绯色夏天:BAAALgAECgEJAQAAAA==.',
['网瘾']='网瘾治疗专家:BAACLgAFFH8SAAIFAAUJ2iIuAgDkAQAFAAUJ2iIuAgDkAQAuAAQKfysAAgUACQklJX8AAOEDAAUACQklJX8AAOEDAAAA.',
['罗睺']='罗睺星君:BAAALgAECgMJAwAAAA==.',
['罗纳']='罗纳尔敌敌威:BAAALgAECgIJAgAAAA==.',
['美髯']='美髯攻:BAAALgADCgYJBgAAAA==.',
['老寅']='老寅钱:BAAALgAECgEJAQAAAA==.',
['肉曦']='肉曦小歧势:BAAALgAECgQJBwAAAA==.',
['肉蛋']='肉蛋蛋:BAAALgAECgcJCwAAAA==.',
['肖邦']='肖邦:BAAALgAECgMJAwAAAA==.',
['肥猫']='肥猫猫:BAAALgAECgcJBwAAAA==.',
['胖胖']='胖胖咪:BAAALgAECgMJAwAAAA==.胖胖的烈酒:BAAALgAECgEJAQAAAA==.',
['胸毛']='胸毛姐姐:BAAALgADCgUJBQAAAA==.',
['至暗']='至暗将至:BAAALgAECgUJBQAAAA==.',
['艾弗']='艾弗森:BAAALgADCgQJBAAAAA==.',
['芷梦']='芷梦林夕丶:BAABLgAFFH8GAAIOAAMJoyOIDQAvAQAOAAMJoyOIDQAvAQAAAA==.',
['莱昂']='莱昂纳多:BAAALgAECgIJAwAAAA==.',
['蓝雪']='蓝雪紫幽:BAAALgAECgEJAQAAAA==.',
['薄荷']='薄荷和酒丶伍:BAAALgAECgYJBgAAAA==.薄荷和酒丶叁:BAAALgAECgYJCAAAAA==.薄荷和酒丶壹:BAAALgAFFAIJAgAAAA==.薄荷和酒丶柒:BAAALgAECgkJBgAAAA==.薄荷和酒丶肆:BAAALgAECgcJBgAAAA==.薄荷和酒丶陆:BAAALgAECgcJCwAAAA==.',
['蜗蜗']='蜗蜗喵喵:BAAALgAECgYJCAAAAA==.',
['血啸']='血啸天下:BAAALgADCgMJAwAAAA==.',
['西单']='西单小六:BAAALgAFFAEJAQAAAA==.',
['西门']='西门催血:BAAALgAECgQJBAAAAA==.',
['訫倳']='訫倳褈褈:BAAALgAECgIJAwAAAA==.',
['詩情']='詩情畵藝:BAAALgADCgQJBAAAAA==.',
['诸葛']='诸葛涨停:BAABLgAFFH8FAAICAAIJnRqQNQDAAAACAAIJnRqQNQDAAAAAAA==.',
['豆浆']='豆浆啊:BAAALgADCgEJAQAAAA==.',
['貝爾']='貝爾蒙特:BAAALgAECgEJAQAAAA==.',
['财神']='财神偏爱:BAAALgAECgIJAgAAAA==.',
['超级']='超级嘟嘟:BAAALgAECgUJBgAAAA==.超级大嘴:BAAALgAECgYJBgAAAA==.',
['身价']='身价六个万:BAAALgADCgYJBgAAAA==.',
['輕风']='輕风细語:BAAALgAECgEJAQAAAA==.',
['輪回']='輪回死骑:BAAALgAECgUJBgAAAA==.',
['這籹']='這籹籽好羙:BAAALgAECgYJBgAAAA==.',
['逼术']='逼术:BAACLgAFFH8HAAIZAAQJWhf+DgBmAQAZAAQJWhf+DgBmAQAuAAQKfxwAAxkACQmgH5QLAB4DABkACQmgH5QLAB4DABoAAwmeGTAvAP4AAAAA.',
['遗忘']='遗忘丶骑士:BAAALgADCgYJBgAAAA==.',
['遗落']='遗落丨应龙:BAAALgADCgQJBAAAAA==.',
['郭芙']='郭芙榕啊:BAAALgAECgkJDwAAAA==.',
['酸甜']='酸甜可人:BAAALgAECgUJCQAAAA==.',
['重慶']='重慶一匹狼:BAAALgADCgMJAwAAAA==.',
['银城']='银城物业保安:BAAALgAECgQJCAAAAA==.',
['锄禾']='锄禾曰荡午:BAAALgAECgQJCwAAAA==.',
['阿芙']='阿芙罗蒂特:BAAALgAECgYJCgAAAA==.',
['阿莱']='阿莱斯特:BAAALgADCgEJAgAAAA==.',
['随身']='随身带女未:BAAALgADCgEJAQAAAA==.随身带弓:BAAALgADCgIJAgAAAA==.随身带枪:BAAALgADCgQJBAAAAA==.',
['難釋']='難釋懐:BAAALgAFFAEJAQAAAA==.',
['雨花']='雨花亭:BAAALgAECgYJBgAAAA==.',
['雾里']='雾里雪:BAABLgAFFH8GAAIWAAQJixIJCwBTAQAWAAQJixIJCwBTAQAAAA==.',
['霜之']='霜之逐风:BAAALgAECgEJAgAAAA==.',
['青山']='青山长老:BAAALgADCgcJBwAAAA==.',
['青玉']='青玉案:BAAALgAECgQJBAAAAA==.',
['鞋带']='鞋带松了:BAAALgAECgMJBQAAAA==.',
['風靈']='風靈:BAAALgADCgcJCQAAAA==.',
['飘飞']='飘飞的落叶:BAAALgADCgYJBgAAAA==.',
['飛舞']='飛舞:BAABLgAECn8eAAIbAAgJahRvPAACAgAbAAgJahRvPAACAgAAAA==.',
['馬冬']='馬冬梅:BAAALgAECgMJBgAAAA==.',
['骑遍']='骑遍世界:BAAALgAECgcJDgAAAA==.',
['魅影']='魅影诱魂:BAAALgAECgUJCgAAAA==.',
['魇的']='魇的第七章:BAAALgAECgcJEAAAAA==.',
['麦卡']='麦卡伦:BAAALgAECgkJEAAAAA==.',
['黄泉']='黄泉丶:BAAALgAFFAEJAQAAAA==.',
['黑牛']='黑牛:BAAALgAECgMJAwAAAA==.',
['黑锋']='黑锋大领主:BAAALgAECggJEAAAAA==.',
['黯夜']='黯夜:BAAALgADCgUJBQAAAA==.',
['齐得']='齐得隆冬弱:BAABLgAECn8WAAICAAkJxBjnIADwAgACAAkJxBjnIADwAgAAAA==.齐得隆冬强:BAAALgAECgkJEAAAAA==.',
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
