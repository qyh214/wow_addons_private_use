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

local lookup = {'Priest-Discipline','Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','Paladin-Holy','Mage-Frost','Monk-Mistweaver','Warlock-Demonology','DeathKnight-Blood','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Unknown-Unknown','DemonHunter-Devourer','DemonHunter-Havoc','Mage-Fire','Druid-Restoration','Paladin-Retribution','Evoker-Preservation','Priest-Holy','Warrior-Arms','Warrior-Fury','Rogue-Subtlety','Warrior-Protection','Monk-Windwalker','Shaman-Restoration','Paladin-Protection','Druid-Guardian','Evoker-Augmentation','Druid-Balance','Priest-Shadow','Mage-Arcane','DemonHunter-Vengeance','Monk-Brewmaster',}
local provider = {region='CN',realm='诺莫瑞根',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adizero:BAAALgAECgQJBwAAAA==.Adol:BAAALgADCgcJBwAAAA==.',
Ag='Agnesrei:BAAALgAECgcJBwABLgAFFAUJCQABAAsYAA==.',
Al='Allpaw:BAAALgAECgYJBgAAAA==.',
An='Andrewella:BAAALgAECgcJAwAAAA==.Anotherday:BAAALgAFFAIJBAAAAA==.Anotherdroid:BAAALgAFFAIJAwAAAA==.Anotherpal:BAAALgAFFAIJAwAAAA==.Anying:BAAALgAECgQJCAAAAA==.',
Ax='Axl:BAAALgADCgUJBQAAAA==.',
Ba='Balaner:BAAALgADCgEJAQAAAA==.',
Bl='Blazingangel:BAAALgADCgEJAgAAAA==.',
Ca='Caiadbolg:BAAALgAECgEJAQAAAA==.',
Ch='Chanelanne:BAAALgAFFAEJAgAAAA==.',
Da='Dalekskaro:BAAALgAECgQJBAAAAA==.',
De='Desirer:BAAALgAECgYJBQAAAA==.',
Do='Donkzz:BAAALgAECgcJBwAAAA==.',
Dy='Dydt:BAAALgADCgYJBwAAAA==.',
Ea='Eachyim:BAAALgADCgYJBgAAAA==.',
Ee='Eerra:BAAALgAFFAIJAgAAAA==.',
El='Elysium:BAAALgADCgYJCQAAAA==.',
Er='Eryrtyertu:BAAALgAECgQJBgAAAA==.',
Ev='Everglow:BAAALgAFFAIJAgAAAA==.Evilknight:BAAALgAECgEJAQAAAA==.',
Ga='Garnastrasza:BAAALgAECgEJAQAAAA==.',
Gd='Gdd:BAACLgAFFH8NAAQCAAUJ9R+VCQB/AQACAAQJ6yGVCQB/AQADAAIJwQ5zBgCsAAAEAAMJ6hunFgBzAAAuAAQKfxkABAIACAnxHvgVAH0CAAIACAkGHPgVAH0CAAMAAgm/IB8TAHYAAAQAAgmrJmtAAHMAAAAA.',
Gr='Grr:BAAALgAFFAEJAQAAAA==.Grubbyy:BAAALgAFFAIJAwAAAA==.',
Gu='Gusta:BAAALgADCgIJAgAAAA==.Gustaa:BAAALgAECgYJCAAAAA==.',
Ha='Halle:BAAALgAECgEJAQAAAA==.Hananel:BAAALgAECgEJAQAAAA==.',
He='Heiye:BAAALgAECgIJAgAAAA==.',
Hi='Hirozz:BAAALgAECgUJBQAAAA==.',
Ho='Honsetriven:BAABLgAECn8YAAIFAAkJiR6LBAAlAwAFAAkJiR6LBAAlAwAAAA==.',
Hu='Huntress:BAAALgAECgMJAwAAAA==.',
Jj='Jjesu:BAAALgAECgQJCAAAAA==.',
Kh='Khaleesi:BAAALgAECgkJCAAAAA==.',
Ki='Kimtaeyeon:BAAALgAECgcJBQAAAA==.',
Kt='Ktlyn:BAAALgAECgEJAQAAAA==.',
Le='Leezhiran:BAAALgAECgEJAQABLgAECgYJFAAGAAgXAA==.Leezhiranfs:BAABLgAECn8UAAIGAAYJCBf7mQChAQAGAAYJCBf7mQChAQAAAA==.Lenovip:BAAALgAECgEJAQAAAA==.Lettece:BAAALgAECgYJBgAAAA==.Lettecu:BAAALgAECgkJEQAAAA==.Lettuce:BAABLgAECn8WAAIHAAkJeBRbEQBJAgAHAAkJeBRbEQBJAgAAAA==.Lettuec:BAAALgAECgkJDwAAAA==.',
Li='Lionel:BAAALgAECgUJDQAAAA==.',
Lu='Luckye:BAAALgAECgYJBwAAAA==.Luckyi:BAAALgAECgMJAwAAAA==.Luttecu:BAAALgAECgcJDgAAAA==.Luttuce:BAAALgAECgQJBQAAAA==.',
Ma='Masdevallia:BAAALgAECgYJDgAAAA==.Matthewss:BAAALgAFFAMJBAABLgAFFAUJDAAIAK0mAA==.Maxwhj:BAAALgAECgEJAgAAAA==.',
Me='Megatrom:BAAALgAECgEJAQAAAA==.Meliisandre:BAAALgAECgUJCgAAAA==.',
Mo='Moong:BAAALgADCggJEAAAAA==.',
Ne='Nel:BAABLgAFFH8FAAIJAAUJuQkTBwAgAQAJAAUJuQkTBwAgAQAAAA==.',
Ni='Nicke:BAAALgADCgQJBAAAAA==.',
Nj='Nj:BAAALgAECgQJBAAAAA==.',
Ok='Okok:BAAALgAECgYJCwAAAA==.',
Pl='Playersnscob:BAAALgADCgMJAwAAAA==.',
Pu='Purity:BAAALgAECgQJBAAAAA==.',
Re='Remains:BAAALgADCgYJBgAAAA==.',
Ro='Roisyt:BAABLgAECn8bAAQIAAcJYBWZTwDZAQAIAAcJYBWZTwDZAQAKAAEJAABHawA8AAALAAEJAADNNwAgAAAAAA==.',
Sa='Saberlily:BAAALgAECgcJBwAAAA==.',
So='Sotobuki:BAAALgAECgkJEgAAAA==.',
St='Stellarc:BAAALgAECgkJCQAAAA==.',
Su='Sungift:BAAALgAECgEJAQAAAA==.',
Te='Terminal:BAAALgADCgQJBAAAAA==.',
Tu='Turtlemole:BAAALgAECgYJBQAAAA==.',
Yn='Ynzttah:BAAALgAECgQJBgAAAA==.',
Za='Zadekn:BAACLgAFFH8FAAIMAAIJehJVQACgAAAMAAIJehJVQACgAAAuAAQKfxUAAgwACAn5IG0VAPsCAAwACAn5IG0VAPsCAAAA.Zahuishi:BAAALgADCgYJBgABLgAECgYJBAANAAAAAA==.Zass:BAAALgAFFAIJBAAAAA==.',
['一冲']='一冲无前:BAAALgADCgMJAwAAAA==.',
['一杯']='一杯冻柠七:BAAALgAFFAIJAwAAAA==.',
['一炁']='一炁破星河安:BAAALgAFFAIJAgAAAA==.',
['一葉']='一葉落知秋:BAAALgAECgQJBwAAAA==.',
['七月']='七月十号:BAAALgADCgQJBAAAAA==.',
['万界']='万界照见:BAAALgAECgMJAgAAAA==.',
['三文']='三文鱼吃榴莲:BAAALgAECgMJBAAAAA==.三文鱼哎榴莲:BAAALgADCgQJBAAAAA==.',
['三辉']='三辉:BAAALgAECgcJBwAAAA==.',
['上婠']='上婠婉儿:BAAALgAECgQJBAAAAA==.',
['下雨']='下雨天瞎:BAACLgAFFH8FAAMOAAIJbArEHACJAAAOAAIJbArEHACJAAAPAAEJQgOFDwBGAAAuAAQKfyUAAw4ACAk/F0wXAGkBAA8ABwmCFvwgALUBAA4ACAl2FUwXAGkBAAAA.',
['不动']='不动的帕秋莉:BAAALgADCgIJAgAAAA==.',
['不变']='不变的回忆:BAAALgAECgYJBwAAAA==.',
['不如']='不如龙王一喷:BAAALgAECgIJAgAAAA==.',
['不灭']='不灭的意志:BAAALgAECgMJBAAAAA==.',
['不要']='不要叫我救你:BAAALgAECgkJEwAAAA==.',
['丑的']='丑的无语:BAAALgAECgYJDAAAAA==.',
['丨星']='丨星落丨:BAAALgAECgEJAQAAAA==.',
['丨西']='丨西柚柚丨:BAAALgAECgEJAgAAAA==.',
['丶影']='丶影子丿:BAAALgAECgUJBgAAAA==.',
['丶斩']='丶斩离丶:BAAALgAECgYJBwAAAA==.',
['丶江']='丶江阿生丶:BAABLgAECn8WAAIMAAcJRR64RAAnAgAMAAcJRR64RAAnAgABLgAFFAQJDQAMAGEZAA==.',
['丶法']='丶法仙:BAACLgAFFH8FAAIGAAMJ2h07NQDCAAAGAAMJ2h07NQDCAAAuAAQKfxsAAwYABwkmH4tHAGECAAYABgkRI4tHAGECABAAAQmRC00OAEMAAAAA.',
['丶海']='丶海王在冲浪:BAAALgAECgYJBgAAAA==.',
['丶贼']='丶贼爷:BAAALgAFFAMJBAAAAA==.',
['乌托']='乌托邦灬:BAAALgAECgcJBwAAAA==.',
['乞求']='乞求者:BAAALgAECgYJBAAAAA==.',
['二斤']='二斤半:BAAALgAECgQJBgAAAA==.',
['二次']='二次降临:BAAALgAECgEJAQAAAA==.',
['亡神']='亡神啊:BAAALgAECgcJCAAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgkJCgABLgAFFAcJBQARAMsVAA==.',
['从不']='从不开减伤:BAAALgAECgEJAQAAAA==.',
['从小']='从小爱打野:BAAALgAECgMJAgAAAA==.',
['仲夏']='仲夏星空:BAAALgAECgEJAgAAAA==.',
['伊莉']='伊莉薇儿:BAAALgAECgEJAQAAAA==.',
['伸缩']='伸缩自在的爱:BAAALgADCgMJAwAAAA==.',
['但远']='但远山长:BAAALgAECgEJAQAAAA==.',
['你断']='你断后我先走:BAABLgAFFH8FAAISAAUJ2wPCCAAjAQASAAUJ2wPCCAAjAQAAAA==.',
['你来']='你来组成头部:BAAALgAECgEJAQAAAA==.',
['你比']='你比从前快叻:BAAALgAFFAIJAwAAAA==.',
['你的']='你的大宝贝:BAAALgAECgUJDwAAAA==.',
['佩顿']='佩顿尚未:BAAALgAECgEJAQAAAA==.',
['依然']='依然丿信仰:BAAALgAECgQJBAAAAA==.依然灬信仰:BAAALgAECgQJBAAAAA==.',
['倾峸']='倾峸:BAAALgAECgUJBQAAAA==.',
['先跑']='先跑不吃亏:BAAALgAECgQJBAAAAA==.',
['光与']='光与黑:BAAALgAECgUJCAAAAA==.',
['光之']='光之幻想:BAAALgAECgUJBQAAAA==.',
['光头']='光头电锯男:BAAALgAFFAUJAQAAAA==.',
['克莉']='克莉珊娜:BAAALgAECgEJAQAAAA==.',
['兕觥']='兕觥:BAAALgAECgUJBQAAAA==.',
['兰芝']='兰芝坊:BAAALgAECgEJAQAAAA==.',
['养猫']='养猫的小小鱼:BAAALgADCgEJAQAAAA==.',
['凌七']='凌七夜:BAAALgAECgEJAQAAAA==.',
['几何']='几何:BAABLgAFFH8JAAITAAUJSRWABACzAQATAAUJSRWABACzAQAAAA==.',
['凯瑞']='凯瑞咁:BAAALgADCgEJAQAAAA==.',
['凹凸']='凹凸不慢:BAAALgAECgkJBwAAAA==.',
['刘大']='刘大头丶:BAAALgADCgEJAQAAAA==.',
['别天']='别天神丶:BAAALgAECgYJBgAAAA==.',
['别礼']='别礼:BAAALgAECgIJAgAAAA==.',
['剑与']='剑与歌:BAAALgAECgQJBgAAAA==.',
['剑誓']='剑誓:BAAALgAECgIJAgAAAA==.',
['劳柏']='劳柏莎:BAAALgADCgYJBgAAAA==.',
['劳桶']='劳桶丶:BAAALgAECgUJBQAAAA==.',
['十万']='十万巫女:BAAALgAECgEJAQABLgAFFAcJDQAMAGUkAA==.',
['半杯']='半杯白开水:BAAALgAECgEJAQAAAA==.',
['单脚']='单脚闯天涯:BAACLgAFFH8IAAMEAAMJ0yPKDQDrAAAEAAMJ0yPKDQDrAAACAAEJxB8YJABYAAAuAAQKfxsAAwQABwlbJHgYAHYCAAQABgkJI3gYAHYCAAIABgm8JekWAHQCAAAA.',
['南风']='南风忆梦:BAABLgAECn8UAAMBAAYJ5RZRCwBJAQABAAYJ5RZRCwBJAQAUAAIJigPAdwBLAAAAAA==.',
['博学']='博学的小李:BAAALgAECgEJAQAAAA==.',
['卡皮']='卡皮肤:BAAALgAECgcJDQAAAA==.',
['印度']='印度玩蛇大师:BAAALgAECgQJBQAAAA==.',
['双花']='双花红棍:BAAALgAECgcJDgAAAA==.',
['反派']='反派大王小琪:BAAALgADCgEJAQAAAA==.',
['发飙']='发飙蜗牛:BAAALgAECgEJAQAAAA==.',
['叫哥']='叫哥姐夫:BAAALgAECgcJDAAAAA==.',
['可乐']='可乐零下一度:BAAALgAFFAEJAQAAAA==.',
['可萌']='可萌可猛:BAAALgADCgcJBwAAAA==.',
['右手']='右手拿面包:BAAALgAECgkJCQABLgAFFAYJFAASAHAeAA==.',
['叽叽']='叽叽歪歪的人:BAAALgAFFAEJAQAAAA==.',
['吃饭']='吃饭睡觉打豆:BAAALgAECgMJBAAAAA==.',
['吕树']='吕树:BAAALgAFFAQJBAAAAA==.',
['君兮']='君兮:BAAALgAECgEJAQAAAA==.',
['吹茶']='吹茶仙子:BAAALgAECgIJAQAAAA==.',
['咏渊']='咏渊:BAAALgADCgEJAQAAAA==.',
['咖啡']='咖啡伴烟:BAAALgAECgYJBgAAAA==.',
['咸柠']='咸柠:BAAALgAECgcJBwAAAA==.',
['哆来']='哆来咪:BAAALgAECgQJBgAAAA==.',
['哈啦']='哈啦咻:BAAALgAECgYJDwAAAA==.',
['哈基']='哈基萨:BAAALgAECgYJBgAAAA==.',
['哈爷']='哈爷:BAAALgAFFAEJAwAAAA==.',
['哼歌']='哼歌听想念:BAAALgAECgcJEQAAAA==.',
['唯丶']='唯丶:BAAALgAECgYJDAAAAA==.',
['啊浪']='啊浪老师:BAACLgAFFH8OAAMVAAYJGBRxAAD9AQAVAAYJGBRxAAD9AQAWAAIJPwQ2HACVAAAuAAQKfxcAAxUACAmJGPwLAOIBABUABQnRIPwLAOIBABYABwmSD8c7ALYBAAAA.',
['啾咪']='啾咪酱丶:BAAALgAFFAIJAwAAAA==.',
['嗯嗯']='嗯嗯丶:BAAALgAECgUJBQAAAA==.',
['嗲兮']='嗲兮兮丶:BAAALgAECgYJCQAAAA==.',
['嘎嘎']='嘎嘎暴莉:BAAALgAECgYJCAAAAA==.',
['嘘蛐']='嘘蛐灬为零:BAAALgAECgYJBgAAAA==.',
['四明']='四明居士:BAAALgAECgEJAQAAAA==.',
['回首']='回首梦已逝:BAAALgAECgcJBwAAAA==.',
['国子']='国子监祭酒:BAAALgAECgYJDgAAAA==.',
['圆圆']='圆圆脑袋:BAAALgAECgYJBgAAAA==.',
['圈叉']='圈叉圈叉:BAAALgADCgMJAwAAAA==.',
['圣光']='圣光丶熊:BAAALgAECgEJAQAAAA==.圣光窃贼:BAAALgAECgcJDwAAAA==.圣光鸽后:BAAALgADCgEJAQAAAA==.',
['圣女']='圣女:BAAALgAECgcJCAAAAA==.',
['塞拉']='塞拉:BAAALgAECgYJBgAAAA==.',
['多芙']='多芙鹰手:BAAALgAECgcJBgAAAA==.',
['夜丨']='夜丨影风:BAACLgAFFH8HAAIXAAMJjResDAAaAQAXAAMJjResDAAaAQAuAAQKfxkAAhcACAkPHgIPALICABcACAkPHgIPALICAAAA.',
['夜琉']='夜琉璃:BAAALgAECgEJAQAAAA==.',
['大老']='大老黑丨:BAAALgAECgQJBAAAAA==.',
['大胖']='大胖德:BAAALgAECgEJAQAAAA==.',
['大角']='大角丶牛牛:BAAALgADCgEJAQABLgAECgUJBwANAAAAAA==.',
['大锅']='大锅菜:BAAALgAECgMJAwAAAA==.',
['天使']='天使爱恶魔:BAAALgAECgMJAwAAAA==.',
['天子']='天子饺子:BAAALgAECgQJBAAAAA==.',
['天野']='天野阳菜丶:BAAALgAFFAQJBAAAAA==.',
['天靑']='天靑色等烟雨:BAAALgAECgYJDgAAAA==.',
['失去']='失去以后:BAAALgADCgMJAwAAAA==.',
['女子']='女子女子女子:BAABLgAFFH8GAAIIAAQJzA6uGAArAQAIAAQJzA6uGAArAQAAAA==.',
['女拳']='女拳:BAAALgAECgYJBgAAAA==.',
['妖妖']='妖妖玖:BAAALgADCgMJAwAAAA==.',
['子凊']='子凊:BAAALgAFFAIJAgAAAA==.',
['子青']='子青:BAABLgAFFH8IAAIGAAMJGhtRKAASAQAGAAMJGhtRKAASAQAAAA==.',
['学声']='学声妹:BAAALgAECgcJAwAAAA==.',
['安可']='安可儿:BAAALgAECgMJAwAAAA==.',
['安妮']='安妮女孩:BAAALgAECgYJBgAAAA==.',
['安迪']='安迪堕落暗影:BAAALgAECgYJCgAAAA==.',
['宫水']='宫水三叶丶:BAABLgAFFH8IAAIGAAQJKghWDwA8AQAGAAQJKghWDwA8AQAAAA==.宫水四叶丶:BAAALgAECgYJBwAAAA==.',
['宸极']='宸极:BAAALgADCgIJAwAAAA==.',
['寒冰']='寒冰之霜:BAAALgAECgEJAQAAAA==.',
['小乐']='小乐敦:BAABLgAECn8dAAMYAAcJ1hKLGQCEAQAYAAcJ1hKLGQCEAQAVAAQJSQidJADIAAAAAA==.',
['小可']='小可:BAAALgAFFAIJAwAAAA==.',
['小天']='小天使时樱:BAAALgAECgYJCQAAAA==.',
['小小']='小小武僧:BAAALgAECgIJAwAAAA==.小小法神:BAAALgAECgYJDgAAAA==.',
['小手']='小手红彤彤:BAABLgAFFH8JAAIZAAQJWgpIAwAZAQAZAAQJWgpIAwAZAQAAAA==.',
['小泽']='小泽不打铁丶:BAABLgAFFH8KAAIGAAMJiB0SFAATAQAGAAMJiB0SFAATAQAAAA==.',
['小灵']='小灵儿:BAAALgAECgQJBgAAAA==.',
['小炒']='小炒肉丶:BAAALgAECgcJDAAAAA==.',
['小璐']='小璐乱撞:BAAALgADCgEJAQAAAA==.',
['小脸']='小脸红彤彤:BAAALgAFFAQJBAAAAA==.',
['小色']='小色鸟:BAABLgAFFH8FAAIRAAMJFiT2CABEAQARAAMJFiT2CABEAQAAAA==.',
['小英']='小英雄大肚腩:BAAALgAECgQJBAAAAA==.',
['小锥']='小锥锥:BAAALgAECgEJAQAAAA==.',
['小雷']='小雷斯林的狼:BAAALgAECgYJCQAAAA==.小雷斯林的萨:BAABLgAFFH8GAAIaAAIJ3xlUFgClAAAaAAIJ3xlUFgClAAAAAA==.小雷斯林的黯:BAAALgADCgYJBgABLgAFFAIJBgAaAN8ZAA==.',
['小高']='小高木同学:BAAALgAECgUJBgAAAA==.小高汀:BAAALgAFFAQJAwAAAA==.',
['小鸟']='小鸟游灬六花:BAAALgAECgEJAQAAAA==.',
['小鹅']='小鹅心心:BAAALgAECgIJBAAAAA==.',
['尕泪']='尕泪滴:BAAALgAECgcJBwAAAA==.',
['尘都']='尘都瘙零:BAAALgADCgQJBAAAAA==.',
['尜叭']='尜叭喋:BAAALgAFFAEJAQAAAA==.',
['尤莉']='尤莉蒂丝:BAAALgADCgEJAQAAAA==.',
['就喝']='就喝冰可乐:BAAALgADCgEJAQAAAA==.',
['尼姑']='尼姑庵老六:BAAALgADCgQJBgAAAA==.',
['工工']='工工:BAACLgAFFH8MAAIbAAQJPxXoAQABAQAbAAQJPxXoAQABAQAuAAQKfyIAAhsABgm6Ho0LABECABsABgm6Ho0LABECAAAA.',
['巧笑']='巧笑丶倩兮:BAAALgAECgIJAQAAAA==.',
['差不']='差不多冬至:BAAALgAECgMJBgABLgAECgYJEAANAAAAAA==.',
['布莱']='布莱恩豚鼠:BAAALgAFFAIJAwAAAA==.',
['布鲁']='布鲁比格胖:BAAALgAECgIJAgAAAA==.',
['希亚']='希亚玛特:BAAALgAECgIJAwAAAA==.',
['带小']='带小弟的帅:BAAALgAECgYJBwAAAA==.',
['幽冥']='幽冥魔帝:BAAALgAECgYJCAAAAA==.',
['幽影']='幽影之风:BAAALgAECgQJBAAAAA==.',
['应是']='应是天仙狂醉:BAAALgAECgIJAgAAAA==.',
['开赛']='开赛鹿:BAAALgAECgUJCAAAAA==.',
['弓兵']='弓兵爱近战:BAAALgAECgUJBwAAAA==.',
['张震']='张震:BAAALgAECgEJAQAAAA==.',
['强力']='强力小丁:BAAALgAECgYJCgAAAA==.',
['当你']='当你:BAABLgAECn8YAAIMAAkJbh2gFQD6AgAMAAkJbh2gFQD6AgAAAA==.',
['彩云']='彩云追魂:BAAALgAECgkJCQABLgAFFAcJBQAGANIGAA==.',
['待到']='待到云散月明:BAAALgAECgEJAQAAAA==.',
['徐汇']='徐汇小开:BAAALgAECgEJAgAAAA==.',
['御坂']='御坂猫猫:BAAALgAECgUJBQAAAA==.',
['微微']='微微甜:BAAALgAFFAEJAQAAAA==.',
['心心']='心心向荣:BAACLgAFFH8IAAIcAAMJzQUuBACQAAAcAAMJzQUuBACQAAAuAAQKfyAAAhwABgkOELcXAPwAABwABgkOELcXAPwAAAEuAAUUBAkMABsAPxUA.',
['忧郁']='忧郁症先生:BAAALgAECgMJAwABLgAFFAYJGAAdACkgAA==.',
['怕是']='怕是要翻血血:BAAALgAECgcJBgAAAA==.',
['性感']='性感囚犯:BAAALgADCgYJBgAAAA==.',
['恋音']='恋音雨空:BAACLgAFFH8OAAMUAAQJyx+EAQBtAQAUAAQJyx+EAQBtAQABAAEJGA6UGQBJAAAuAAQKfyAAAxQACQlPHzwDACoDABQACQlPHzwDACoDAAEAAwnuEHtBAKYAAAAA.',
['恒力']='恒力无限:BAAALgAFFAIJBAABLgAFFAQJDQAMACcWAA==.',
['悠木']='悠木碧:BAAALgAECgUJBQAAAA==.',
['悾柏']='悾柏:BAAALgAECgYJBAAAAA==.',
['惘然']='惘然酸奶:BAAALgAFFAMJAwAAAA==.',
['慕慕']='慕慕:BAAALgAECgMJAwAAAA==.',
['我不']='我不是宠物:BAABLgAECn8WAAMeAAgJmBRnJgDKAQAeAAgJmBRnJgDKAQARAAEJHRT2xwA6AAAAAA==.',
['我叫']='我叫小粗:BAAALgAECgEJAQAAAA==.',
['我就']='我就爱贝贝:BAABLgAECn8eAAISAAcJuyBjIQClAgASAAcJuyBjIQClAgAAAA==.',
['我心']='我心向北:BAAALgAFFAIJAgAAAA==.',
['我来']='我来负责发炎:BAAALgADCgYJBgAAAA==.',
['战丶']='战丶风暴烈酒:BAAALgADCgIJAgAAAA==.',
['战神']='战神丶阿瑞斯:BAAALgAECgQJBQAAAA==.',
['戰火']='戰火:BAAALgAECgEJAQAAAA==.',
['招畜']='招畜冲锋:BAAALgAFFAIJAgAAAA==.',
['挠你']='挠你脚心:BAAALgAECgUJCAAAAA==.',
['携琴']='携琴浪天涯:BAAALgAECgcJCQAAAA==.',
['斗宗']='斗宗强者丶:BAAALgAECgEJAQAAAA==.',
['斯奈']='斯奈德卡里姆:BAAALgADCgQJBAAAAA==.',
['斯眯']='斯眯嘛赛:BAAALgAECgEJAQAAAA==.',
['新能']='新能源储能:BAAALgAFFAIJBAAAAA==.新能源光伏:BAAALgAECgUJBQAAAA==.新能源氢能:BAAALgAFFAIJAwAAAA==.',
['方昆']='方昆:BAAALgADCgMJAwAAAA==.',
['旋律']='旋律的圣光:BAAALgAECgQJBAAAAA==.旋律的风:BAABLgAFFH8KAAMEAAMJdhiICQAVAQAEAAMJdhiICQAVAQADAAEJaQESCABAAAAAAA==.',
['旋舞']='旋舞之火:BAAALgAECgYJBgAAAA==.',
['无法']='无法抗拒:BAAALgAFFAEJAQAAAA==.无法登录:BAAALgADCgUJBQAAAA==.无法负担:BAABLgAECn8VAAIOAAcJExUhTADEAQAOAAcJExUhTADEAQAAAA==.',
['无险']='无险一惊:BAAALgAECgIJAwAAAA==.',
['昂狗']='昂狗:BAAALgAECgYJBwAAAA==.',
['昊昊']='昊昊快追:BAAALgAECgIJAgAAAA==.',
['星月']='星月依维柯:BAABLgAECn8WAAIGAAcJBhd0agABAgAGAAcJBhd0agABAgAAAA==.',
['星辰']='星辰追迹者:BAAALgAECgIJAgAAAA==.',
['晓夜']='晓夜星语:BAAALgAECgMJAwAAAA==.',
['晚风']='晚风丶:BAAALgAECgYJEAAAAA==.晚风眠:BAAALgAECgYJBgAAAA==.',
['晴日']='晴日峰战大师:BAAALgAECgkJCQAAAA==.',
['智在']='智在天下:BAAALgAECgcJCAAAAA==.',
['暴走']='暴走的生菜:BAAALgAECggJDwAAAA==.',
['曦宝']='曦宝乖乖:BAAALgADCgYJCAAAAA==.',
['曾今']='曾今无敌:BAAALgADCgQJBAAAAA==.',
['最爱']='最爱曹曦文:BAAALgAECgEJAQAAAA==.',
['月光']='月光下的精灵:BAAALgAECgQJBAAAAA==.',
['月半']='月半故事:BAAALgAECgQJBAAAAA==.',
['月狼']='月狼东东:BAAALgADCgYJBgAAAA==.',
['有苦']='有苦難言灬:BAAALgAFFAYJAgAAAA==.',
['术一']='术一士小安妮:BAABLgAFFH8FAAIaAAIJ3BEHFwCgAAAaAAIJ3BEHFwCgAAAAAA==.',
['术在']='术在起跑线:BAABLgAECn8iAAQIAAcJoR3TKQBpAgAIAAcJ9xzTKQBpAgAKAAMJtRpEMgDvAAALAAIJUxQ6GQCwAAAAAA==.',
['李丶']='李丶风暴烈酒:BAAALgAECgMJBQAAAA==.',
['李大']='李大爷灬:BAAALgAECgcJBwAAAA==.',
['李奶']='李奶奶灬:BAAALgAECgcJBwAAAA==.',
['杨枝']='杨枝伊露:BAAALgAECgYJDAAAAA==.',
['柳枝']='柳枝萧萧:BAAALgADCgEJAQAAAA==.',
['柳洳']='柳洳烟:BAAALgADCgEJAgAAAA==.',
['椋雀']='椋雀:BAAALgAECgYJCwAAAA==.',
['樱灬']='樱灬桃桃:BAABLgAECn8UAAMBAAcJahmyFwDhAQABAAcJghWyFwDhAQAUAAYJ+Bm8KQClAQAAAA==.',
['欢欢']='欢欢爱吃:BAAALgADCgcJBwAAAA==.欢欢爱玩鸡:BAAALgADCgIJAgAAAA==.',
['欧阳']='欧阳天行:BAAALgADCgUJBQAAAA==.',
['欲望']='欲望都市:BAAALgAECgEJAQAAAA==.',
['毁灭']='毁灭前祈祷:BAAALgAECgUJCQAAAA==.毁灭协奏曲:BAAALgAECgYJDAAAAA==.',
['毛毛']='毛毛球:BAAALgAECgEJAQAAAA==.',
['水瞎']='水瞎:BAABLgAFFH8GAAIPAAMJQSVmAwBRAQAPAAMJQSVmAwBRAQAAAA==.',
['氵水']='氵水法:BAABLgAECn8UAAIGAAYJfhxzcQDxAQAGAAYJfhxzcQDxAQAAAA==.',
['求求']='求求暖娇躯:BAAALgAECgIJAgAAAA==.',
['汉库']='汉库克丶:BAAALgADCgEJAQABLgADCgUJBQANAAAAAA==.',
['沙尔']='沙尔图拉:BAAALgAECgYJCwAAAA==.',
['波雅']='波雅丶漢库克:BAAALgAECgQJBAABLgAFFAQJBwACAFkSAA==.',
['泰能']='泰能:BAAALgAECgMJBQAAAA==.',
['洒水']='洒水:BAAALgAECgYJCQAAAA==.',
['流刃']='流刃一若火:BAAALgADCgMJAwAAAA==.',
['流星']='流星一瞬:BAAALgAECgYJDQAAAA==.',
['流浪']='流浪的黑貓:BAAALgADCgYJBgAAAA==.',
['浅夏']='浅夏尣折戟:BAABLgAECn8XAAMWAAcJrhehNADXAQAWAAYJDhqhNADXAQAYAAEJzwt0RwAwAAAAAA==.浅夏尣滚滚:BAAALgAFFAMJAwAAAA==.',
['浮光']='浮光掠影:BAAALgAFFAUJBAABLgAFFAYJBAANAAAAAA==.',
['海尔']='海尔布隆:BAAALgADCgUJBQAAAA==.',
['涅磐']='涅磐緟笙:BAAALgAECgEJAQAAAA==.',
['涌动']='涌动续航:BAAALgADCgEJAQAAAA==.',
['清梦']='清梦压星河:BAAALgAECgUJBQAAAA==.',
['清茗']='清茗山竹丷:BAAALgADCgUJBQAAAA==.清茗甜橙丷:BAAALgADCgMJAwAAAA==.',
['湘漓']='湘漓宝贝:BAAALgAECgYJDQAAAA==.',
['溙兰']='溙兰德语风:BAAALgADCgIJAQAAAA==.',
['漆黑']='漆黑的追迹者:BAAALgAECgIJAgAAAA==.',
['潘村']='潘村长:BAAALgADCgcJBwAAAA==.',
['火烤']='火烤冰淇淋:BAAALgAECgYJBwAAAA==.',
['灬青']='灬青灬:BAAALgADCgYJBgAAAA==.',
['灰烬']='灰烬觉醒:BAABLgAECn8YAAISAAgJsh/1IwCYAgASAAgJsh/1IwCYAgAAAA==.',
['灵儿']='灵儿小魔女:BAAALgADCgYJBwAAAA==.',
['烟熏']='烟熏狼:BAAALgAECgEJAgAAAA==.',
['热巧']='热巧克力:BAAALgAECgEJAQAAAA==.',
['然也']='然也:BAAALgADCgUJBQAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAfAAcWAA==.',
['照宝']='照宝:BAAALgAECgYJDwAAAA==.',
['熊小']='熊小小:BAAALgAECgYJCgAAAA==.',
['燕十']='燕十二:BAACLgAFFH8GAAIJAAMJ1AT3DACgAAAJAAMJ1AT3DACgAAAuAAQKfyAAAgkABgnTFcwdAFsBAAkABgnTFcwdAFsBAAEuAAUUBAkMABsAPxUA.',
['爱骑']='爱骑小马珍珠:BAAALgAECgEJAQAAAA==.',
['爷青']='爷青回:BAAALgAECgIJAgAAAA==.',
['牛丶']='牛丶牛:BAAALgAECgUJBwAAAA==.',
['牛牛']='牛牛仙人:BAAALgAECgQJBwABLgAECgUJBwANAAAAAA==.牛牛是牛:BAAALgAECgMJAwAAAA==.',
['牧光']='牧光之影:BAABLgAFFH8GAAIBAAIJCQ/xCgCeAAABAAIJCQ/xCgCeAAAAAA==.',
['牧骑']='牧骑:BAAALgAECgEJAQAAAA==.',
['牵丝']='牵丝戏:BAAALgAECgkJDwAAAA==.',
['犀利']='犀利锅:BAAALgAECgIJAwAAAA==.',
['狂奔']='狂奔的胖纸:BAAALgAECgYJDgAAAA==.',
['狂热']='狂热短裤:BAAALgAECgEJAQAAAA==.',
['狂风']='狂风八级大:BAABLgAFFH8LAAISAAQJOxGSDQA+AQASAAQJOxGSDQA+AQAAAA==.',
['独步']='独步悠然:BAAALgAECgUJBwAAAA==.',
['猊姥']='猊姥尾:BAAALgAECgEJAQAAAA==.',
['猫猫']='猫猫:BAAALgAECgUJBQAAAA==.',
['玛奇']='玛奇玛:BAAALgAFFAQJBAAAAA==.',
['球寳']='球寳寳:BAAALgAECggJDgAAAA==.',
['瑶啊']='瑶啊瑶:BAAALgAECgQJBwAAAA==.',
['甜心']='甜心假面:BAABLgAFFH8FAAIMAAIJFR7hNQCwAAAMAAIJFR7hNQCwAAAAAA==.甜心小饼干:BAAALgADCgQJBAAAAA==.',
['甜橙']='甜橙:BAAALgAFFAEJAQAAAA==.',
['生气']='生气的榴莲丶:BAAALgADCgEJAQABLgAECgUJBgANAAAAAA==.',
['生菜']='生菜小德:BAAALgAECgYJBgAAAA==.生菜小德三号:BAAALgAECgYJDAAAAA==.生菜武僧:BAAALgAECgcJEwAAAA==.生菜骑士:BAAALgAECgcJAQAAAA==.',
['疵头']='疵头刮脑:BAACLgAFFH8FAAIGAAMJmw1vQACtAAAGAAMJmw1vQACtAAAuAAQKfx4AAwYABwmfGwxqAAICAAYABwmfGwxqAAICACAAAQl2BmYgAC4AAAAA.',
['白头']='白头搔更短:BAAALgAECgEJAQAAAA==.',
['白银']='白银之手库里:BAABLgAFFH8GAAIbAAQJrwUcAwDAAAAbAAQJrwUcAwDAAAAAAA==.',
['百变']='百变的小李:BAAALgAECgMJBgAAAA==.',
['百合']='百合芊芊:BAAALgAECgEJAQAAAA==.',
['百里']='百里十雁:BAAALgAECgMJAwABLgAFFAEJAQANAAAAAA==.',
['皮皮']='皮皮妖:BAAALgAFFAIJAgAAAA==.',
['真夏']='真夏飞焰:BAACLgAFFH8GAAMEAAMJ6Qd+DQDxAAAEAAMJ6Qd+DQDxAAACAAIJewdtIACSAAAuAAQKfxUAAwQACAmuFJdYAF4BAAQABQmiFZdYAF4BAAIABwl5CVNGADsBAAAA.',
['真气']='真气波波鸭:BAAALgAECgQJBwAAAA==.',
['瞪的']='瞪的像铜铃:BAAALgADCgcJDgAAAA==.',
['硬棒']='硬棒棒:BAAALgAECgQJBwAAAA==.',
['硬玩']='硬玩复仇:BAAALgAECgIJAwAAAA==.',
['碳烤']='碳烤羊肋排:BAAALgAECgEJAQAAAA==.',
['礼赞']='礼赞黄泉:BAAALgAECgUJBQAAAA==.',
['神呱']='神呱呱:BAAALgADCgcJDQAAAA==.',
['神啰']='神啰啰:BAAALgAECgUJBQAAAA==.',
['神嘎']='神嘎嘎:BAAALgAECgYJEAAAAA==.',
['神樣']='神樣兽:BAAALgAECgkJEgAAAA==.',
['神调']='神调:BAAALgAECgYJBgAAAA==.',
['秋韵']='秋韵:BAAALgADCgIJAgAAAA==.',
['竹桃']='竹桃:BAAALgAECgMJAwAAAA==.',
['第五']='第五个季节丶:BAAALgAECgEJAQABLgAECgYJEAANAAAAAA==.',
['箫柒']='箫柒月:BAAALgADCgUJBQAAAA==.',
['簏先']='簏先生:BAABLgAFFH8FAAICAAIJehhGGwCqAAACAAIJehhGGwCqAAAAAA==.',
['米兰']='米兰小花匠:BAAALgAECgYJEAAAAA==.',
['米米']='米米:BAAALgAECgUJBQAAAA==.',
['粘粘']='粘粘丶橙:BAAALgAECgYJBgAAAA==.粘粘丶紫:BAAALgADCgYJBgABLgAECgYJBgANAAAAAA==.粘粘丶蓝:BAAALgAECgYJEAABLgAECgYJBgANAAAAAA==.',
['糖醋']='糖醋味茶叶蛋:BAAALgAECgQJBgAAAA==.',
['紫罗']='紫罗兰近卫军:BAAALgAECgYJDgAAAA==.',
['纯吾']='纯吾:BAAALgAECgEJAQAAAA==.',
['结伴']='结伴同行:BAACLgAFFH8FAAIhAAMJEQTaAgCXAAAhAAMJEQTaAgCXAAAuAAQKfx4AAiEABgnaE8MQAEQBACEABgnaE8MQAEQBAAEuAAUUBAkMABsAPxUA.',
['结局']='结局一直难改:BAAALgAECgEJAgAAAA==.',
['给我']='给我好好奶:BAAALgAECgkJCQAAAA==.',
['缥缈']='缥缈战神:BAAALgAECgEJAQAAAA==.',
['美味']='美味大术薯:BAABLgAFFH8FAAIIAAMJvSBkDQAjAQAIAAMJvSBkDQAjAQAAAA==.美味矮番薯:BAAALgAECgYJDQAAAA==.',
['美妞']='美妞变大树:BAAALgADCgQJBAAAAA==.',
['美食']='美食小露露:BAAALgADCgEJAQAAAA==.美食露露:BAAALgADCgQJBAAAAA==.',
['群星']='群星璀璨:BAAALgADCgEJAQAAAA==.',
['羽衣']='羽衣若空:BAAALgAECgkJEgAAAA==.',
['翻译']='翻译官小杰:BAAALgAFFAEJAQAAAA==.',
['老九']='老九:BAACLgAFFH8LAAIYAAQJKQqNAwAMAQAYAAQJKQqNAwAMAQAuAAQKfyIAAhgABgn1EXULAO0AABgABgn1EXULAO0AAAEuAAUUBAkMABsAPxUA.',
['老头']='老头也有奶:BAAALgAECgIJAwAAAA==.',
['老帮']='老帮瓜:BAAALgAECgcJBwAAAA==.',
['老洗']='老洗浴:BAAALgADCgYJBgAAAA==.',
['老酒']='老酒爷:BAACLgAFFH8HAAIiAAMJ+Bw6DgASAQAiAAMJ+Bw6DgASAQAuAAQKfxoAAiIABgnXG8YkANwBACIABgnXG8YkANwBAAEuAAUUBAkMABsAPxUA.',
['联盟']='联盟之刃:BAAALgAECgEJAQAAAA==.',
['聖光']='聖光炽焰:BAAALgAECgEJAQAAAA==.',
['臭臭']='臭臭宝:BAAALgAECgEJAgAAAA==.',
['艾蕾']='艾蕾什基伽尔:BAAALgAECgEJAQAAAA==.',
['花满']='花满楼丶殇:BAAALgAECgEJAQAAAA==.',
['花生']='花生酱:BAAALgADCgEJAQAAAA==.',
['花田']='花田乌龙:BAAALgAECgcJAwAAAA==.',
['花禾']='花禾:BAAALgAECgEJAQAAAA==.',
['芷曦']='芷曦:BAAALgAECgcJBwAAAA==.',
['苍渊']='苍渊翠微:BAAALgAECgUJBwAAAA==.',
['苏我']='苏我筑紫:BAAALgAFFAEJAQAAAA==.',
['荆棘']='荆棘谷的青殇:BAAALgADCgEJAQAAAA==.',
['萨满']='萨满丶小米:BAAALgAECggJDwAAAA==.',
['蓝朋']='蓝朋友:BAAALgAFFAIJAwAAAA==.',
['蓝若']='蓝若雪:BAAALgAECgIJAQAAAA==.',
['蓝雨']='蓝雨琉璃:BAAALgADCgIJAgAAAA==.',
['虚空']='虚空嘉宾:BAAALgADCgYJBgAAAA==.',
['血丶']='血丶剌:BAAALgAECgIJAgAAAA==.',
['血哥']='血哥哥:BAAALgAECgYJBgAAAA==.',
['血契']='血契子衍:BAAALgAECgQJBgAAAA==.',
['血腥']='血腥运动:BAAALgAECgYJAQAAAA==.',
['西多']='西多士:BAAALgADCgEJAQAAAA==.',
['諳兵']='諳兵沙場:BAAALgAECgcJDQAAAA==.',
['该死']='该死的教授:BAACLgAFFH8HAAMSAAQJMAmADwDeAAASAAQJMAmADwDeAAAFAAIJcg/oFwCGAAAuAAQKfxsAAxIABwnJIDspAIACABIABwnJIDspAIACAAUABgkBFzs+AIABAAAA.',
['诳野']='诳野筱暴牛:BAAALgADCgEJAQAAAA==.',
['请叫']='请叫我萨克:BAAALgAECgYJDQAAAA==.',
['豹胎']='豹胎易筋丸:BAAALgAECgMJAwAAAA==.',
['贯穿']='贯穿箭:BAAALgAECgEJAQAAAA==.',
['赛莉']='赛莉雅:BAAALgADCgEJAQAAAA==.',
['起个']='起个迪尅:BAAALgADCgEJAQAAAA==.',
['超级']='超级大章鱼:BAABLgAFFH8FAAIXAAIJpg5MFACtAAAXAAIJpg5MFACtAAAAAA==.',
['蹦跶']='蹦跶蹦跶:BAAALgADCgEJAQAAAA==.',
['躲在']='躲在碗里:BAAALgADCgcJBwAAAA==.',
['車车']='車车車龙:BAAALgAECgQJBAAAAA==.',
['轻衣']='轻衣舞袖:BAAALgAECgMJBwAAAA==.',
['达克']='达克妮斯:BAAALgAFFAEJAQAAAA==.',
['这个']='这个夏天丶:BAAALgAECgYJEAAAAA==.',
['这酒']='这酒有力气:BAAALgAECgkJDgABLgAFFAQJAwANAAAAAA==.',
['远坂']='远坂家的凛:BAACLgAFFH8IAAIIAAMJNA0iFwDiAAAIAAMJNA0iFwDiAAAuAAQKfxgAAwgACAkWE+ZCAAQCAAgACAkWE+ZCAAQCAAoAAglCBSlaAGAAAAAA.',
['远程']='远程对我有利:BAAALgADCgIJAgAAAA==.',
['迷失']='迷失在春的雪:BAAALgAECgEJAQAAAA==.',
['逐风']='逐风丶:BAAALgADCgEJAQAAAA==.',
['速冻']='速冻可乐:BAAALgAECggJCgAAAA==.',
['酒丶']='酒丶仙:BAAALgAECgQJBAAAAA==.',
['酷的']='酷的无语:BAAALgAECgcJAQAAAA==.',
['野卵']='野卵王:BAAALgAECgUJBgAAAA==.',
['钱小']='钱小钱:BAABLgAECn8UAAIGAAcJ6xJ8kACyAQAGAAcJ6xJ8kACyAQAAAA==.',
['铜蛋']='铜蛋儿:BAAALgAECgEJAQAAAA==.',
['长耳']='长耳:BAAALgAECgQJBAAAAA==.',
['阴雨']='阴雨绵绵:BAAALgAECgQJCwAAAA==.',
['阿七']='阿七天才啊:BAAALgAFFAIJBAAAAA==.',
['阿影']='阿影酱:BAAALgAECgIJAwAAAA==.',
['阿德']='阿德真缺德:BAAALgADCgcJBwAAAA==.',
['阿离']='阿离丶:BAAALgADCgYJBgAAAA==.',
['陌小']='陌小峰:BAAALgAFFAEJAQAAAA==.',
['随机']='随机学会了么:BAABLgAFFH8FAAMMAAUJsCFCAgCUAQAMAAQJsCFCAgCUAQAJAAEJAAD6DgAAAAAAAA==.',
['隐锋']='隐锋:BAAALgAECgQJBQAAAA==.',
['雪白']='雪白的小李:BAAALgAECgEJAQAAAA==.',
['雪碧']='雪碧透心凉:BAACLgAFFH8NAAIOAAQJzg0/DAAaAQAOAAQJzg0/DAAaAQAuAAQKfyUAAg4ACAmBHYsrAFECAA4ACAmBHYsrAFECAAAA.',
['零毅']='零毅徽:BAAALgAECgQJAgAAAA==.',
['霜之']='霜之酱油:BAAALgAECgYJCgAAAA==.',
['露琪']='露琪亚:BAACLgAFFH8NAAMGAAUJXiAhCQBmAQAGAAUJXiAhCQBmAQAgAAEJ5RCRAQBUAAAuAAQKfyUAAgYACQlYIg0PAE8DAAYACQlYIg0PAE8DAAAA.',
['露露']='露露:BAAALgADCgcJBwAAAA==.',
['靈丶']='靈丶:BAAALgAECgEJAQAAAA==.',
['颜值']='颜值幻强度:BAAALgAECgIJAgAAAA==.',
['風之']='風之力:BAAALgAECgYJCAAAAA==.',
['风嫂']='风嫂小蛮腰:BAAALgAECgUJBQAAAA==.',
['风舞']='风舞狂人:BAAALgAECgIJAgAAAA==.',
['风骚']='风骚奶爸:BAAALgAECgEJAQAAAA==.风骚小蛮腰:BAABLgAECn8UAAMOAAcJyxL5UwCoAQAOAAcJxRL5UwCoAQAPAAYJ+Qx8NgAtAQAAAA==.',
['飞云']='飞云:BAAALgADCgMJAwAAAA==.',
['飞狗']='飞狗:BAAALgADCgcJBwAAAA==.',
['骨质']='骨质疏松症:BAAALgAFFAEJAQAAAA==.',
['鬼魅']='鬼魅斯芬克斯:BAAALgADCgcJBwAAAA==.',
['魂狩']='魂狩:BAAALgADCggJCAAAAA==.',
['魔力']='魔力打桩机:BAAALgAECgYJDAAAAA==.魔力舞大锤:BAAALgAECgEJAQAAAA==.',
['鱼酱']='鱼酱得借个火:BAAALgADCgYJBgAAAA==.',
['鱼骨']='鱼骨头:BAAALgAECgEJAQAAAA==.',
['鲜花']='鲜花饼:BAAALgAECgQJBgABLgAECgUJBwANAAAAAA==.',
['鸠夜']='鸠夜:BAAALgAECgYJBwAAAA==.',
['鹤傲']='鹤傲天:BAABLgAFFH8KAAIiAAMJfxAADADTAAAiAAMJfxAADADTAAAAAA==.',
['黑手']='黑手:BAAALgADCgYJBgAAAA==.',
['黑暗']='黑暗贝利亚:BAAALgAECgMJAQAAAA==.',
['黑黑']='黑黑的武士:BAAALgAECgMJAwAAAA==.',
['默燃']='默燃:BAAALgAECgcJBwAAAA==.',
['龍井']='龍井虾仁:BAAALgADCgYJBgAAAA==.',
['龙咚']='龙咚咚三号:BAAALgADCgEJAQAAAA==.龙咚咚五号:BAAALgAECgEJAQAAAA==.',
['龙影']='龙影随风:BAAALgAECgEJAQAAAA==.',
['龙骑']='龙骑士尹志平:BAABLgAECn8dAAITAAcJpB5iDQBgAgATAAcJpB5iDQBgAgAAAA==.',
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
