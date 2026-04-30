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

local lookup = {'Mage-Frost','DemonHunter-Havoc','Druid-Restoration','Unknown-Unknown','Paladin-Retribution','Warlock-Demonology','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Shaman-Restoration','Warrior-Arms','Hunter-BeastMastery','Warlock-Affliction','Warlock-Destruction','Hunter-Marksmanship','Monk-Brewmaster','DeathKnight-Unholy','DeathKnight-Frost','Warrior-Fury','Paladin-Holy','Mage-Arcane','Paladin-Protection','Druid-Balance','DemonHunter-Devourer','Priest-Shadow','Warrior-Protection','DemonHunter-Vengeance',}
local provider = {region='CN',realm='太阳之井',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aalam:BAAALgAECgQJBAAAAA==.',
Al='Alienarrive:BAAALgAECgEJAQAAAA==.',
Am='Amia:BAAALgAECgEJAQAAAA==.',
Ch='Charlie:BAAALgAECgEJAQAAAA==.',
Co='Coltán:BAABLgAFFH8KAAIBAAUJDA8VHABbAQABAAUJDA8VHABbAQAAAA==.Cover:BAAALgAECgEJAQAAAA==.',
Da='Davinci:BAABLgAFFH8HAAICAAMJlxgsBQAKAQACAAMJlxgsBQAKAQAAAA==.',
De='Demosatan:BAAALgADCgEJAQAAAA==.',
Do='Dontfkingdie:BAABLgAFFH8PAAIBAAUJFCZbAQDOAQABAAUJFCZbAQDOAQAAAA==.',
Em='Emosadan:BAAALgAECgYJCwAAAA==.',
Fl='Flyffly:BAAALgAECgQJBQAAAA==.',
Fo='Forcoco:BAAALgAECgYJEgAAAA==.',
Gs='Gshock:BAAALgAECgMJAwAAAA==.',
Ha='Halaien:BAAALgADCgEJAQAAAA==.',
He='Hekady:BAAALgAECgEJAQAAAA==.',
Je='Jessyschram:BAAALgAECgYJEAAAAA==.',
Lo='Lockharttifa:BAAALgAFFAEJAQAAAA==.Lokta:BAAALgAECgEJAQAAAA==.',
Ma='Magictata:BAAALgAECgYJCAAAAA==.',
Me='Menethil:BAAALgAECgEJAgAAAA==.',
Mo='Momhunter:BAAALgAECgYJCAAAAA==.Moonmage:BAAALgAFFAQJBAAAAA==.',
No='Noobzs:BAAALgADCgUJBQAAAA==.',
Qc='Qck:BAABLgAECn8WAAIDAAcJJybfAAALAwADAAcJJybfAAALAwAAAA==.Qckhm:BAAALgAECgMJAwAAAA==.',
Qt='Qtdk:BAAALgAECgYJBgAAAA==.',
Si='Siszz:BAAALgAECgYJDgAAAA==.',
Sm='Smiless:BAAALgAECgEJAQAAAA==.',
Sp='Sparta:BAAALgADCgUJBQAAAA==.Spica:BAAALgAECgcJBwABLgAECgkJDQAEAAAAAA==.',
Su='Sunbiood:BAAALgAECgEJAgAAAA==.Supfan:BAAALgADCgUJBQAAAA==.Suxivc:BAAALgAECgUJBQAAAA==.',
Ty='Tycoco:BAAALgAECgQJBgAAAA==.',
Un='Unclewang:BAAALgADCgYJBgAAAA==.',
Wu='Wuu:BAAALgAECgUJBQAAAA==.',
Za='Zaps:BAAALgAFFAEJAQAAAA==.',
Zh='Zhaobenshan:BAAALgAECgYJBgABLgAFFAMJAwAEAAAAAA==.',
['一个']='一个小瞎子:BAAALgAECgIJAQAAAA==.',
['一朵']='一朵奇葩:BAAALgAECgEJAQAAAA==.',
['一杆']='一杆枪:BAAALgAECgIJAgAAAA==.',
['一苇']='一苇尘寂:BAAALgAECgEJAQAAAA==.',
['一闪']='一闪在闪:BAABLgAECn8UAAIFAAcJsQxGIwAdAQAFAAcJsQxGIwAdAQAAAA==.',
['丁丁']='丁丁叮铛丶:BAAALgADCgYJBgAAAA==.',
['三剑']='三剑之舞:BAAALgAECgIJAgABLgAECgQJBQAEAAAAAA==.',
['三维']='三维码:BAAALgAECgEJAQAAAA==.',
['上线']='上线刷坐骑:BAAALgAECgUJBwAAAA==.',
['上街']='上街马东锡:BAAALgAECgQJCAAAAA==.',
['不想']='不想睡:BAAALgAECgEJAQAAAA==.',
['不正']='不正即是歪:BAAALgAECgMJAwAAAA==.不正可能歪:BAAALgADCgUJBQAAAA==.不正是真歪:BAAALgAECgYJDAAAAA==.',
['不齐']='不齐即是歪:BAAALgADCgYJCwAAAA==.',
['且菜']='且菜且珍惜:BAAALgADCgcJCAAAAA==.',
['丝浪']='丝浪:BAAALgAECgQJBAAAAA==.',
['两根']='两根棍:BAAALgAECgcJBwAAAA==.',
['丨亖']='丨亖月:BAAALgAECgMJAwAAAA==.',
['丨冰']='丨冰封回忆丨:BAAALgAECgcJCAAAAA==.',
['丨风']='丨风清扬灬:BAAALgAECgUJBQAAAA==.',
['中年']='中年恶霸:BAAALgAECgMJAwAAAA==.',
['丶小']='丶小铁块:BAAALgADCgMJAwAAAA==.',
['丶恶']='丶恶魔流泪:BAAALgADCgEJAQAAAA==.',
['丶晓']='丶晓晓丶:BAAALgAECgYJCQAAAA==.',
['丶毛']='丶毛老板:BAAALgAECgQJCQAAAA==.',
['丶油']='丶油条:BAAALgADCgMJAQAAAA==.',
['丷逐']='丷逐光:BAAALgAFFAEJAQAAAA==.',
['丽萨']='丽萨酷奇:BAAALgADCgEJAgAAAA==.',
['乂氼']='乂氼:BAAALgADCgEJAQAAAA==.',
['乌拉']='乌拉罗格塑山:BAAALgADCgIJAgAAAA==.',
['乔克']='乔克叔叔丶:BAAALgAECgMJAQAAAA==.',
['乖豬']='乖豬:BAABLgAECn8NAAIGAAYJRQ22KADtAAAGAAYJRQ22KADtAAAAAA==.',
['五月']='五月小雨:BAABLgAECn8aAAQHAAgJNw9GJABWAQAHAAYJHRJGJABWAQAIAAYJmAdCIgAYAQAJAAMJAAk/TgCWAAAAAA==.',
['井芹']='井芹仁菜:BAAALgADCgcJDgAAAA==.',
['亖龍']='亖龍龍亖:BAAALgADCgYJBgAAAA==.',
['今晚']='今晚吃牛牛:BAAALgAFFAQJBAAAAA==.',
['伊之']='伊之怒骑:BAAALgAECgcJCwAAAA==.',
['传说']='传说中的遜哥:BAAALgAFFAMJAwAAAA==.',
['伤心']='伤心夜灵:BAAALgAECgIJAgAAAA==.',
['低调']='低调调的狒狒:BAAALgAECgQJBAAAAA==.',
['作死']='作死不看时间:BAAALgAECgkJCQAAAA==.',
['你丶']='你丶有罪:BAAALgAECgEJAQAAAA==.',
['你别']='你别追我呀:BAAALgADCgMJAwAAAA==.',
['俊介']='俊介:BAAALgAFFAIJAgAAAA==.',
['倒车']='倒车接人:BAAALgAECgQJAQAAAA==.',
['假行']='假行者:BAAALgAECgQJBAAAAA==.',
['偶似']='偶似圣光:BAAALgAECgQJCwAAAA==.',
['克里']='克里斯汀娜:BAAALgAECgcJEAAAAA==.',
['克鲁']='克鲁克吖:BAAALgADCgMJAwAAAA==.',
['兜风']='兜风:BAAALgADCgUJBQAAAA==.',
['六月']='六月初六:BAAALgAECgEJAQAAAA==.',
['冰山']='冰山上的猎魔:BAAALgAECgcJBwAAAA==.',
['冰灬']='冰灬蓝色:BAAALgAECgQJBAAAAA==.',
['冰熊']='冰熊熊一个:BAAALgADCgEJAQAAAA==.',
['冰风']='冰风暴:BAAALgADCgEJAQAAAA==.',
['冲锋']='冲锋战神:BAAALgAECgIJAgAAAA==.',
['决明']='决明:BAAALgADCgUJBQAAAA==.',
['凛灬']='凛灬:BAAALgAFFAQJBAAAAA==.',
['凯恩']='凯恩丶血蹄:BAAALgAECgYJCgAAAA==.',
['利萨']='利萨酷奇:BAAALgADCgMJAwAAAA==.',
['别人']='别人家的牧爷:BAAALgAECgUJCAAAAA==.',
['别顺']='别顺我的火机:BAAALgAECgQJBAAAAA==.',
['前世']='前世折磨:BAAALgAECggJDwAAAA==.',
['前尘']='前尘随风逝:BAAALgAECgIJAgAAAA==.',
['勤有']='勤有功:BAAALgADCgUJBQAAAA==.',
['十岁']='十岁断奶:BAAALgAECgMJAwAAAA==.',
['卖糖']='卖糖的小伙子:BAAALgAECgUJBQAAAA==.',
['南方']='南方朱雀:BAAALgAECgIJAgAAAA==.',
['卟醉']='卟醉乄百加德:BAAALgAECgYJCgAAAA==.',
['厉飞']='厉飞雨:BAAALgADCgQJBAAAAA==.',
['双魚']='双魚理:BAABLgAFFH8KAAIBAAUJXB8jBACDAQABAAUJXB8jBACDAQABLgAFFAYJCwABAMUbAA==.',
['反者']='反者道之動:BAAALgAECgYJCAAAAA==.',
['只玩']='只玩奥法:BAAALgAECgcJAQAAAA==.',
['叫我']='叫我丶小肉肉:BAAALgAECgEJAgAAAA==.',
['可乐']='可乐崽:BAAALgAFFAIJAgAAAA==.',
['吃死']='吃死你丫的:BAAALgAECgEJAQAAAA==.',
['吮指']='吮指原味鸡:BAAALgADCgEJAQAAAA==.',
['吴家']='吴家二少爷:BAAALgAFFAEJAQAAAA==.吴家五少爷:BAAALgAECgEJAQAAAA==.',
['呆瓜']='呆瓜丶:BAAALgAECgcJCAAAAA==.',
['呆萌']='呆萌喵星人:BAAALgAECgEJAQAAAA==.',
['咩咩']='咩咩的力霸王:BAAALgADCgIJAgAAAA==.',
['喬爺']='喬爺:BAAALgAECgEJAQAAAA==.',
['嗲逼']='嗲逼:BAAALgADCgUJBQABLgAFFAIJBAAEAAAAAA==.',
['团长']='团长缺德么:BAAALgAECgkJCAAAAA==.',
['团队']='团队治疗木桩:BAAALgAECgYJBgAAAA==.',
['图们']='图们江小蘑菇:BAAALgAECgYJBgAAAA==.',
['图玛']='图玛热思:BAAALgAECgEJAQAAAA==.',
['圈圈']='圈圈灬熊:BAACLgAFFH8KAAIKAAUJUxvoAQDWAQAKAAUJUxvoAQDWAQAuAAQKfxcAAgoACAkUIkMJAOMCAAoACAkUIkMJAOMCAAAA.',
['圣瞳']='圣瞳:BAAALgAECgUJBQAAAA==.',
['圣魔']='圣魔暗血之子:BAAALgAECgYJBgAAAA==.',
['堕落']='堕落竞技场:BAAALgAECgYJCAAAAA==.',
['夜影']='夜影之煞:BAAALgAECgYJBwAAAA==.',
['夜明']='夜明砂:BAAALgAECgUJBgAAAA==.',
['夜舞']='夜舞灬小莎:BAAALgAFFAIJAwAAAA==.',
['夜跑']='夜跑飞机:BAAALgADCgMJAwAAAA==.',
['大威']='大威天龍丶:BAAALgADCgMJAwAAAA==.',
['大野']='大野龙蛇:BAAALgADCgMJAwABLgAFFAUJBwALADEdAA==.',
['天众']='天众灬龙众:BAAALgAECgYJCQAAAA==.',
['天天']='天天冰球:BAAALgADCgEJAQAAAA==.',
['天生']='天生神偷:BAAALgAECgMJAwAAAA==.',
['天真']='天真以为:BAAALgAECgYJBgAAAA==.',
['太阳']='太阳王戈温:BAAALgAFFAIJAwAAAA==.',
['奈娅']='奈娅拉托提普:BAAALgAECgYJCAAAAA==.',
['奥尔']='奥尔良烤蘿莉:BAAALgAECgYJBwAAAA==.',
['奥术']='奥术冰晶:BAAALgAFFAIJAwAAAA==.',
['奥特']='奥特馒头:BAAALgADCgUJBQAAAA==.',
['奥蕾']='奥蕾莉娅:BAAALgAECgEJAQAAAA==.',
['女武']='女武神:BAABLgAFFH8GAAIHAAMJXhhsDQAHAQAHAAMJXhhsDQAHAQAAAA==.',
['奴家']='奴家妖玛:BAAALgAECgEJAQAAAA==.',
['妍宝']='妍宝:BAAALgAECggJEAABLgAECgkJDwAEAAAAAA==.',
['妘轩']='妘轩:BAAALgAECgMJBAABLgAFFAQJCwAMAFwfAA==.',
['姬紫']='姬紫月:BAAALgAECgkJCwAAAA==.',
['娘子']='娘子请自重:BAAALgAECgEJAQAAAA==.',
['婉秋']='婉秋丨:BAAALgAECgcJBwAAAA==.',
['存男']='存男糕糕:BAAALgAECgYJCAAAAA==.',
['孫小']='孫小伊:BAAALgADCgEJAQAAAA==.孫小昊:BAAALgAECgMJAwAAAA==.',
['宇智']='宇智波派大星:BAAALgAECgYJCgAAAA==.',
['安吉']='安吉的龙丶:BAAALgAECgYJBgAAAA==.',
['安苏']='安苏雷克:BAACLgAFFH8RAAIGAAMJdR8pCQAzAQAGAAMJdR8pCQAzAQAuAAQKfyoABAYACAnxI1EeAKECAAYABwlHI1EeAKECAA0ABQlLIKgIAL4BAA4AAwmSIDEmAC4BAAAA.',
['客官']='客官来了:BAAALgADCgUJBQAAAA==.',
['小摩']='小摩托骑士:BAAALgADCgUJBQAAAA==.',
['小红']='小红手丶猎猎:BAABLgAFFH8GAAMPAAQJtQcVGgCzAAAPAAMJWAYVGgCzAAAMAAEJygs5JwBTAAAAAA==.',
['小角']='小角白牛骑士:BAABLgAFFH8HAAIFAAMJlhNaFQD/AAAFAAMJlhNaFQD/AAAAAA==.',
['小软']='小软打你呦:BAAALgAECgQJBAAAAA==.',
['小阿']='小阿他姐:BAAALgADCgEJAQAAAA==.',
['尐叮']='尐叮噹:BAAALgAECgQJBAAAAA==.',
['尘缘']='尘缘偌梦:BAAALgAECgMJAwAAAA==.尘缘渃梦:BAAALgADCgEJAQAAAA==.',
['尘风']='尘风飞扬:BAAALgAECgMJAwAAAA==.',
['尸体']='尸体在战斗:BAAALgAECgEJAQAAAA==.',
['屋里']='屋里哇仙女座:BAAALgAECgEJAQAAAA==.',
['屑狐']='屑狐狸:BAAALgAECgcJDQAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8NAAIQAAUJHxL2BgBkAQAQAAUJHxL2BgBkAQAAAA==.',
['巴布']='巴布土拨:BAAALgAECgYJEQAAAA==.',
['布狼']='布狼牙:BAAALgAECgYJCwAAAA==.',
['师太']='师太赛凤仙:BAAALgAECgQJBAAAAA==.',
['希爾']='希爾法:BAABLgAECn8WAAMRAAgJfB6wWwDfAQARAAcJWR+wWwDfAQASAAEJThniBwBPAAAAAA==.',
['干煸']='干煸柿子:BAAALgAECgMJBAAAAA==.',
['幽灵']='幽灵滢:BAAALgADCgYJBgAAAA==.',
['幽眠']='幽眠唯心:BAAALgAECgcJBAAAAA==.',
['幽默']='幽默粑粑人:BAAALgAECgQJAwAAAA==.',
['张副']='张副工長:BAAALgAFFAYJBAAAAA==.张副工长:BAABLgAFFH8IAAITAAQJixtiBwB2AQATAAQJixtiBwB2AQAAAA==.张副段长:BAAALgAFFAIJAgAAAA==.张副科長:BAABLgAFFH8KAAMTAAYJaRgoAQB9AQATAAUJkhooAQB9AQALAAEJxQ/HCQBcAAAAAA==.张副科长:BAABLgAFFH8QAAMTAAYJESCZAQDpAQATAAUJdh2ZAQDpAQALAAYJfBxUCQBfAAAAAA==.张副线長:BAABLgAFFH8MAAMLAAUJ6xiSAwANAQATAAQJfRYpCgBVAQALAAUJdhiSAwANAQAAAA==.张副线长:BAAALgAFFAUJAgAAAA==.张副组長:BAABLgAFFH8MAAMTAAYJxR6XAACTAQATAAUJUCCXAACTAQALAAEJmxjTBABiAAAAAA==.张副组长:BAAALgAFFAQJBAAAAA==.',
['张工']='张工長:BAABLgAFFH8KAAMTAAYJ+B0pAQB8AQATAAUJwSEpAQB8AQALAAEJ0Q5KBQBdAAAAAA==.张工长:BAABLgAFFH8MAAMTAAYJMRpJAwDBAQATAAUJKBhJAwDBAQALAAYJDBY5AQBMAQAAAA==.',
['张段']='张段長:BAAALgAFFAUJAgAAAA==.张段长:BAAALgAFFAYJBAAAAA==.',
['张科']='张科長:BAAALgAFFAUJBAAAAA==.张科长:BAABLgAFFH8FAAITAAUJNRCiCQBaAQATAAUJNRCiCQBaAQAAAA==.',
['张线']='张线長:BAAALgAFFAIJAgAAAA==.张线长:BAAALgAFFAIJAgAAAA==.',
['张组']='张组長:BAABLgAFFH8JAAITAAUJDiBjAQDzAQATAAUJDiBjAQDzAQAAAA==.张组长:BAAALgAFFAQJBAAAAA==.',
['弹老']='弹老狗子:BAAALgAECgEJAQAAAA==.',
['往事']='往事随闏:BAAALgADCggJCAAAAA==.',
['德洛']='德洛瑞恩:BAAALgAECgEJAQAAAA==.',
['德要']='德要配位:BAAALgAECgEJAwAAAA==.',
['心上']='心上月:BAAALgAFFAIJAgAAAA==.',
['忆雪']='忆雪霏:BAAALgADCgYJBgAAAA==.',
['忙僧']='忙僧:BAAALgADCgMJAwAAAA==.',
['怒怒']='怒怒的潮:BAAALgAECgkJDQAAAA==.',
['恶魔']='恶魔仨蛋:BAAALgAECgQJBgAAAA==.',
['悠悠']='悠悠子轩:BAAALgAECgQJBAAAAA==.',
['慕名']='慕名而来:BAAALgAECgEJAQAAAA==.',
['慢慢']='慢慢喝茶:BAAALgAFFAIJBAAAAA==.',
['懒觉']='懒觉猫:BAAALgAFFAIJAwAAAA==.',
['我叫']='我叫高小法:BAAALgAECgMJAQAAAA==.',
['我爱']='我爱吃香菜:BAAALgAECgMJAwAAAA==.',
['我要']='我要你的歌单:BAAALgADCgYJBgAAAA==.我要验牌丶:BAAALgAECgEJAQAAAA==.',
['扬眉']='扬眉刀出鞘:BAAALgAECgUJBgAAAA==.',
['拉米']='拉米亚丝:BAAALgADCgYJBgAAAA==.',
['招财']='招财进宝丿:BAAALgAECgIJAgAAAA==.',
['捌零']='捌零捌壹:BAAALgAFFAQJBAAAAA==.捌零捌陆:BAABLgAFFH8JAAIUAAUJQAx1BQCEAQAUAAUJQAx1BQCEAQAAAA==.',
['提莫']='提莫队长:BAAALgAECgYJBwAAAA==.',
['放学']='放学等我:BAAALgAECgEJAQAAAA==.',
['放开']='放开那牛:BAAALgADCgIJAgAAAA==.',
['放风']='放风筝:BAAALgAFFAEJAQAAAA==.',
['救赎']='救赎之蛋:BAAALgAECgIJAwABLgAFFAQJDAABAJQbAA==.',
['断剣']='断剣:BAABLgAFFH8LAAIMAAQJXB+CAQCOAQAMAAQJXB+CAQCOAQAAAA==.',
['斷剑']='斷剑:BAAALgADCgEJAQABLgAFFAQJCwAMAFwfAA==.',
['旅馆']='旅馆大掌柜:BAAALgADCgcJBwABLgAFFAEJAQAEAAAAAA==.',
['旖旎']='旖旎云逸:BAABLgAECn8bAAIUAAgJnBhUFwBXAgAUAAgJnBhUFwBXAgAAAA==.',
['无奈']='无奈杀戮:BAAALgAECgUJBwAAAA==.',
['时光']='时光穿梭者:BAAALgADCgEJAQAAAA==.',
['旷野']='旷野狼:BAAALgAECgYJDwAAAA==.',
['易小']='易小娟:BAAALgAECgQJBgAAAA==.',
['星宿']='星宿:BAAALgAECgMJAwAAAA==.',
['星约']='星约:BAAALgAECgYJBgAAAA==.',
['星际']='星际追猎者:BAAALgAECgcJAQAAAA==.',
['星陨']='星陨丶咕:BAAALgAECgEJAQAAAA==.',
['昨晚']='昨晚你好爆:BAAALgAECgYJBAAAAA==.',
['景彡']='景彡孑:BAAALgAECgYJCQAAAA==.',
['暗域']='暗域丶神谕者:BAAALgAFFAEJAQAAAA==.',
['暗夜']='暗夜斥候甲:BAAALgAECgMJAwAAAA==.',
['暗影']='暗影大长虫:BAAALgAECgYJCwAAAA==.',
['暗行']='暗行逍遥:BAAALgAECgUJEgAAAA==.',
['暴虐']='暴虐者:BAAALgAECgUJBQAAAA==.',
['最后']='最后的战士:BAAALgAECgYJBwAAAA==.',
['月之']='月之神奥眯:BAAALgAECgMJAwAAAA==.',
['有德']='有德:BAAALgAECgQJBAAAAA==.',
['木鱼']='木鱼丸子:BAAALgAECgIJAwAAAA==.',
['未來']='未來未曾來:BAAALgAECgQJBAAAAA==.',
['未灬']='未灬泱:BAABLgAFFH8GAAIBAAQJvxInCwBBAQABAAQJvxInCwBBAQAAAA==.',
['未闻']='未闻花茗:BAAALgADCgEJAQAAAA==.',
['本周']='本周頭条:BAAALgAECgIJAgAAAA==.',
['术引']='术引沧溟:BAAALgAECgQJBAAAAA==.',
['李木']='李木木彡:BAACLgAFFH8GAAIGAAMJsSQ/FABJAQAGAAMJsSQ/FABJAQAuAAQKfxoABAYABwlEJH4YAMICAAYABwlEJH4YAMICAA0AAQkAAMciAGcAAA4AAQkrCKNzADEAAAAA.',
['村长']='村长小法丝:BAAALgAECgkJEgABLgAFFAQJCwABACsVAA==.村长牛哄哄:BAAALgAECgkJCwAAAA==.',
['枯木']='枯木逢春:BAAALgADCgMJAwAAAA==.',
['格拉']='格拉姆血蹄:BAAALgAECgYJDQAAAA==.',
['概率']='概率牧:BAAALgAECgIJAwABLgAFFAEJAQAEAAAAAA==.',
['樂丨']='樂丨星河:BAAALgAECgUJBQAAAA==.',
['欠儿']='欠儿登:BAAALgAECgIJAwAAAA==.',
['武泰']='武泰斗丷:BAAALgAECgEJAQAAAA==.',
['死神']='死神在现:BAAALgADCgEJAQAAAA==.',
['每个']='每个骑士都有:BAAALgAECgMJBgAAAA==.',
['毒奶']='毒奶牛:BAAALgADCgQJBAAAAA==.',
['毒药']='毒药:BAAALgAECgkJBwAAAA==.',
['水氺']='水氺丨淼:BAAALgAECgYJBgAAAA==.',
['江南']='江南野:BAAALgAECgEJAQAAAA==.',
['池汐']='池汐:BAABLgAFFH8QAAMVAAQJzhRsAAD1AAABAAQJzhQ5CQBXAQAVAAMJJQ5sAAD1AAAAAA==.',
['沐雨']='沐雨清风:BAAALgAECgYJEwAAAA==.',
['河北']='河北彩伽:BAAALgAECgEJAQAAAA==.',
['治安']='治安之夜:BAAALgAFFAIJAwAAAA==.',
['法号']='法号戒烟:BAAALgAECgEJAQAAAA==.',
['法天']='法天项地:BAAALgAECgcJBgAAAA==.',
['法客']='法客油丶:BAAALgAECgcJBwAAAA==.',
['波涛']='波涛丨汹涌:BAAALgAECgUJCgAAAA==.',
['泰坦']='泰坦猎人:BAAALgAECgkJBwAAAA==.',
['活虫']='活虫且:BAAALgAECgMJAwAAAA==.',
['浓茶']='浓茶:BAAALgADCgEJAQAAAA==.',
['浮殤']='浮殤年華:BAAALgAECgEJAwAAAA==.',
['涅法']='涅法雷姆:BAAALgADCgEJAQAAAA==.',
['涉猎']='涉猎星辰:BAAALgAECgUJCAAAAA==.',
['淡淡']='淡淡记忆:BAAALgAECgQJBAAAAA==.',
['淬火']='淬火之眼:BAABLgAECn8ZAAIGAAcJTAyZcAB+AQAGAAcJTAyZcAB+AQAAAA==.',
['深白']='深白熊猫:BAAALgAECgEJAQAAAA==.',
['湖北']='湖北丶卫视:BAAALgAECgEJAQAAAA==.',
['溜溜']='溜溜:BAAALgAECgIJAgAAAA==.',
['满满']='满满的正能量:BAAALgADCgEJAQAAAA==.',
['滴滴']='滴滴答滴答:BAAALgADCgYJBgAAAA==.',
['漩乂']='漩乂涡:BAAALgAECgEJAgAAAA==.',
['漩涡']='漩涡雏田:BAAALgAFFAEJAQAAAA==.',
['潇湘']='潇湘忆:BAAALgADCgEJAQAAAA==.',
['澜羽']='澜羽丶:BAAALgAECgYJCwAAAA==.',
['灬呜']='灬呜喵王之怒:BAAALgAECgMJCAAAAA==.',
['灬塞']='灬塞尔达灬:BAAALgADCgUJBQAAAA==.',
['灬承']='灬承諾灬:BAAALgAECgYJDAAAAA==.',
['灬明']='灬明里紬灬:BAAALgAECgEJAgAAAA==.',
['灬林']='灬林克灬:BAAALgAECgEJAQAAAA==.',
['灬格']='灬格温:BAAALgAECgEJAQAAAA==.',
['灬浊']='灬浊酒灬:BAAALgAECgEJAQAAAA==.',
['灬花']='灬花无缺:BAAALgAECgYJBgAAAA==.',
['灬蕾']='灬蕾欧娜:BAACLgAFFH8KAAIWAAMJTgYuBACWAAAWAAMJTgYuBACWAAAuAAQKfxwAAxYACAkpFqAOANoBABYACAkpFqAOANoBAAUAAQmWDg09ATYAAAAA.',
['灬非']='灬非成勿扰灬:BAAALgADCgEJAQAAAA==.',
['灵魂']='灵魂链接武僧:BAAALgADCgQJBAAAAA==.',
['灼烬']='灼烬虚无:BAAALgAECgEJAQAAAA==.',
['烤牛']='烤牛肉吃:BAAALgADCgUJBQAAAA==.',
['無冕']='無冕:BAAALgAECgIJBgAAAA==.',
['爱一']='爱一点:BAAALgAECgcJDgAAAA==.',
['爱吃']='爱吃小鱼干:BAAALgAFFAMJAwAAAA==.',
['爱哭']='爱哭的小可乐:BAAALgAECgEJAgAAAA==.',
['爸吧']='爸吧:BAAALgAECgIJAwAAAA==.',
['牀殇']='牀殇壹點宏:BAAALgAECgYJDgAAAA==.',
['牛奶']='牛奶果冻:BAAALgAECgUJBQAAAA==.',
['牛浪']='牛浪汉:BAAALgAECgEJAQAAAA==.',
['牛肉']='牛肉立:BAABLgAECn8VAAIXAAcJtxYPLQCbAQAXAAcJtxYPLQCbAQAAAA==.',
['狼爷']='狼爷:BAAALgAECgYJAQAAAA==.',
['狼狼']='狼狼恶狗:BAAALgAECgEJAgAAAA==.',
['玄不']='玄不救非酋:BAAALgAECgQJBAAAAA==.',
['玄武']='玄武风暴:BAAALgAECgEJAQAAAA==.',
['王叔']='王叔术:BAAALgAECgEJAgAAAA==.',
['玖伍']='玖伍贰柒:BAAALgAECgEJAgAAAA==.',
['珩爸']='珩爸是大帅锅:BAABLgAFFH8GAAIBAAMJcRJgLAAFAQABAAMJcRJgLAAFAQAAAA==.',
['琳心']='琳心儿:BAAALgADCgcJBwAAAA==.',
['琴胆']='琴胆剑心:BAAALgADCgMJAwAAAA==.',
['瓦瑞']='瓦瑞迪斯:BAAALgAECgEJAQAAAA==.',
['甜奶']='甜奶茶:BAAALgAECgQJBAAAAA==.',
['电竞']='电竞白梦妍:BAAALgADCgYJBgAAAA==.',
['留念']='留念人间死骑:BAAALgAECgUJBQAAAA==.留念人间法:BAAALgAECgYJDAAAAA==.',
['留给']='留给你背影:BAAALgAECgEJAQAAAA==.',
['瘟逼']='瘟逼:BAAALgAFFAIJBAAAAA==.',
['瘦人']='瘦人绝不为奴:BAAALgAECgIJAgAAAA==.',
['癸巳']='癸巳:BAAALgAFFAIJAgAAAA==.',
['白夜']='白夜:BAABLgAFFH8FAAIBAAIJfQyhPwCuAAABAAIJfQyhPwCuAAAAAA==.',
['白天']='白天下你床:BAAALgAECgQJBgAAAA==.',
['皇灬']='皇灬二代:BAAALgAECgcJDgAAAA==.',
['盖亚']='盖亚拉大王:BAAALgAECgcJBwAAAA==.',
['真橙']='真橙岁月丿:BAAALgADCgUJBQAAAA==.',
['睡意']='睡意躁動:BAABLgAFFH8HAAIRAAMJCAgJLgDiAAARAAMJCAgJLgDiAAAAAA==.',
['祚威']='祚威祚福:BAAALgAECgIJAgAAAA==.',
['神明']='神明:BAAALgAECgIJAgAAAA==.',
['神楽']='神楽酱:BAAALgAECgUJBwABLgAFFAUJBQAUABYhAA==.',
['神逸']='神逸九秋:BAAALgAECgQJBAAAAA==.',
['禪音']='禪音如風:BAAALgAECgIJAgAAAA==.',
['离落']='离落:BAAALgAECgMJAwAAAA==.',
['穿越']='穿越瘋人院:BAAALgAECgIJAwAAAA==.',
['筱灬']='筱灬筱:BAAALgAFFAIJAgAAAA==.',
['筱默']='筱默:BAAALgAECgEJAgAAAA==.',
['米多']='米多多:BAAALgADCgMJAwAAAA==.',
['粉色']='粉色回忆:BAAALgAFFAIJBAAAAA==.',
['粢饭']='粢饭糕:BAAALgAFFAEJAgAAAA==.',
['糖心']='糖心心:BAAALgAECgYJCwAAAA==.',
['糖霜']='糖霜霜:BAAALgAECgYJCAAAAA==.',
['給硪']='給硪壹支煙:BAAALgAECgYJBgAAAA==.',
['红裳']='红裳罗裙浅笑:BAAALgAECgUJCQAAAA==.',
['约翰']='约翰斯特劳斯:BAAALgAECgcJDAAAAA==.',
['绚丽']='绚丽之战:BAABLgAECn8YAAITAAgJfhGyMgDhAQATAAgJfhGyMgDhAQAAAA==.绚丽圣光:BAABLgAECn8UAAIFAAgJIx5MLgBqAgAFAAgJIx5MLgBqAgAAAA==.',
['绣虎']='绣虎:BAABLgAFFH8FAAIGAAMJhhS9HwAFAQAGAAMJhhS9HwAFAQAAAA==.',
['美人']='美人醉:BAABLgAFFH8FAAMUAAIJmgQPCgCEAAAUAAIJmgQPCgCEAAAFAAEJ/RFkMQBSAAAAAA==.',
['羽安']='羽安吉:BAAALgAECgEJAQAAAA==.',
['老衲']='老衲不吃肥肉:BAAALgAFFAEJAQAAAA==.',
['老陳']='老陳丶:BAAALgAECgMJAwAAAA==.',
['老马']='老马是狗:BAAALgADCgYJBgAAAA==.',
['聖翎']='聖翎:BAAALgAECgIJAwAAAA==.',
['肥暴']='肥暴烈酒:BAAALgAECgQJCAAAAA==.',
['腿毛']='腿毛很锋利丶:BAAALgAFFAIJAgAAAA==.',
['自然']='自然睡:BAAALgADCgYJBgAAAA==.',
['舟丶']='舟丶二十:BAABLgAFFH8OAAIYAAYJdxmnBABcAQAYAAYJdxmnBABcAQAAAA==.舟丶二十二:BAABLgAFFH8LAAIYAAYJYhxIAQC1AQAYAAYJYhxIAQC1AQAAAA==.舟丶十七:BAABLgAFFH8NAAIYAAYJIhVpBABgAQAYAAYJIhVpBABgAQAAAA==.舟丶十九:BAABLgAFFH8LAAIYAAYJchQIAgCXAQAYAAYJchQIAgCXAQAAAA==.舟丶十八:BAABLgAFFH8GAAIYAAYJwAztCQCNAQAYAAYJwAztCQCNAQAAAA==.舟丶十六:BAABLgAFFH8KAAIYAAYJ3xLICQCOAQAYAAYJ3xLICQCOAQAAAA==.',
['芮芮']='芮芮:BAAALgAECgMJAgAAAA==.',
['花卷']='花卷炖馒头:BAAALgAECgcJBwAAAA==.',
['芹菜']='芹菜叶子:BAAALgAECgEJAwAAAA==.',
['苹果']='苹果梨蘸料:BAAALgAECgMJBAAAAA==.',
['荒丶']='荒丶焚:BAAALgAFFAIJAgAAAA==.荒丶芜:BAAALgAFFAEJAQAAAA==.',
['莉萨']='莉萨酷奇:BAAALgADCgEJAQAAAA==.',
['莫得']='莫得丶:BAABLgAFFH8HAAIZAAQJahIZBwBUAQAZAAQJahIZBwBUAQAAAA==.莫得感情喵:BAAALgAECgIJAwAAAA==.',
['菠菜']='菠菜先生:BAAALgAFFAIJAgAAAA==.',
['萨拉']='萨拉塔斯灬:BAAALgAECgIJAgAAAA==.',
['萨鲁']='萨鲁法尔大壬:BAAALgAECgkJBAAAAA==.',
['落灬']='落灬霞:BAAALgAECgYJDAAAAA==.',
['蒙牛']='蒙牛甩甩乳:BAAALgADCgIJAgAAAA==.',
['蓮姬']='蓮姬:BAAALgAECgEJAQAAAA==.',
['蔯总']='蔯总:BAAALgAECgQJBAAAAA==.',
['蕊睿']='蕊睿:BAAALgAECgUJCQAAAA==.',
['蕾丝']='蕾丝小晴晴:BAAALgAFFAEJAQAAAA==.',
['蝴蝶']='蝴蝶之泪:BAAALgAECgEJAQAAAA==.',
['血月']='血月琪琪:BAAALgAECgMJAgAAAA==.',
['血狂']='血狂上帝之怒:BAAALgAECgcJCAAAAA==.',
['血色']='血色布娃娃:BAAALgAECgMJAwAAAA==.',
['衷一']='衷一莲:BAAALgAECgUJBQAAAA==.',
['解忧']='解忧杂货店:BAAALgAECgkJCQAAAA==.',
['訫髃']='訫髃:BAAALgAECgUJBQAAAA==.',
['謧灬']='謧灬戨:BAAALgADCgYJBgAAAA==.',
['许仙']='许仙丶敢玩蛇:BAAALgAECgEJAgAAAA==.',
['诗情']='诗情画意:BAAALgADCgIJAgAAAA==.',
['豆芽']='豆芽菜:BAAALgAECgcJDwAAAA==.',
['贼替']='贼替:BAAALgADCgcJBwABLgAFFAMJBgAMABYgAA==.',
['赞达']='赞达尔:BAAALgAFFAIJAgAAAA==.',
['赵家']='赵家津少:BAAALgADCgEJAQAAAA==.',
['超级']='超级豆豆:BAAALgAECggJEQAAAA==.',
['跛豪']='跛豪:BAAALgAECgIJAwAAAA==.',
['路人']='路人小舞:BAAALgAECgEJAQAAAA==.',
['迅捷']='迅捷泡爷缰绳:BAAALgAECgUJBAAAAA==.',
['还是']='还是别说话了:BAAALgAECgkJCQAAAA==.',
['迦那']='迦那:BAAALgAECgMJBgAAAA==.',
['迪迦']='迪迦:BAAALgAECgYJAwABLgAECgkJCgAEAAAAAA==.',
['逆流']='逆流:BAAALgAECgEJAQAAAA==.',
['逍遥']='逍遥洳梦:BAAALgAECgQJBAAAAA==.',
['這個']='這個世界太亂:BAAALgAECgYJBwAAAA==.',
['逝水']='逝水如年:BAAALgAECgIJAwAAAA==.',
['道外']='道外小奎:BAAALgADCgMJAwAAAA==.',
['遗忘']='遗忘那殤:BAAALgAECgcJCwAAAA==.',
['邪仙']='邪仙:BAAALgAECgEJAgAAAA==.',
['部落']='部落也有矮子:BAAALgADCgYJBgAAAA==.部落的希望:BAAALgADCgYJBgAAAA==.部落铁壁:BAABLgAECn8UAAIaAAYJDQdfKgDtAAAaAAYJDQdfKgDtAAAAAA==.',
['释果']='释果宁:BAAALgAECgMJAwAAAA==.',
['量多']='量多了当面霜:BAAALgAECgIJBAAAAA==.',
['铁伽']='铁伽幔:BAAALgAECgEJAgAAAA==.',
['长河']='长河霸冷:BAAALgAECgMJBAAAAA==.',
['闪光']='闪光喷火龙:BAACLgAFFH8VAAIJAAgJWhQHAQCCAgAJAAgJWhQHAQCCAgAuAAQKfyQAAwkACQmdHuAFACYDAAkACQmdHuAFACYDAAcABgndEfMkAFABAAAA.',
['阳光']='阳光正好:BAACLgAFFH8SAAMPAAUJ2h3oBQDFAQAPAAUJEBvoBQDFAQAMAAQJ+hgyBgAaAQAuAAQKfyMAAw8ACQmBITAFAEoDAA8ACQmBITAFAEoDAAwAAQnFFbk5AFgAAAAA.',
['阿克']='阿克汉:BAAALgAECgcJBwAAAA==.',
['阿尔']='阿尔萨莉:BAAALgAECgQJDAAAAA==.',
['阿斯']='阿斯顿飞:BAAALgADCgEJAQAAAA==.',
['阿月']='阿月:BAAALgADCgMJAwAAAA==.',
['随地']='随地大小睡:BAAALgAECgcJCwAAAA==.',
['随梦']='随梦所欲:BAAALgADCgQJBAAAAA==.',
['雄喵']='雄喵老铁:BAAALgADCgQJBAAAAA==.',
['雪剑']='雪剑舞步:BAAALgAECgIJAgAAAA==.',
['零点']='零点:BAAALgADCgYJBgAAAA==.',
['零肆']='零肆妖柒:BAAALgAECgEJAgAAAA==.',
['雾吟']='雾吟灬风舞:BAAALgAECgEJAQAAAA==.',
['霜之']='霜之高兴:BAAALgAECgkJEQABLgAFFAUJAQAEAAAAAA==.',
['青衫']='青衫不改:BAAALgAECgEJAQAAAA==.',
['非主']='非主流猎手:BAAALgADCgEJAQABLgAFFAEJAQAEAAAAAA==.',
['面汤']='面汤:BAAALgAECgEJAQAAAA==.',
['風情']='風情丶:BAAALgAECgYJCAAAAA==.',
['风中']='风中偑:BAAALgAFFAEJAQAAAA==.',
['风伴']='风伴月:BAAALgAECgEJAQAAAA==.',
['风忆']='风忆天:BAABLgAFFH8IAAIUAAUJpgUFDwDmAAAUAAUJpgUFDwDmAAAAAA==.',
['风林']='风林琳:BAAALgAECgYJBgAAAA==.',
['风霖']='风霖霖:BAAALgAECgYJBgABLgAECgYJBgAEAAAAAA==.',
['风骚']='风骚的蓝霸霸:BAAALgAFFAIJAgAAAA==.',
['馒头']='馒头没有馅:BAAALgAECgcJBwABLgAFFAUJCQAOANghAA==.',
['馬卡']='馬卡大聰明:BAAALgADCgEJAQAAAA==.',
['髙松']='髙松燈:BAABLgAFFH8KAAIYAAUJlhj/CQCMAQAYAAUJlhj/CQCMAQAAAA==.',
['鬼王']='鬼王的蛋刀:BAAALgAECgYJBgAAAA==.',
['魔灬']='魔灬鬼:BAAALgADCgQJBAAAAA==.',
['魔王']='魔王丨露露:BAAALgAECgQJCgAAAA==.魔王波旬:BAAALgADCgMJAwAAAA==.',
['鮮血']='鮮血與榮耀:BAAALgAECgMJAwAAAA==.',
['鱼蛋']='鱼蛋枭枭:BAAALgADCgYJBgAAAA==.',
['黄头']='黄头发:BAAALgAFFAQJBAAAAA==.',
['黎明']='黎明脦圣光:BAAALgAECgcJBwAAAA==.',
['黑骑']='黑骑士:BAAALgAECgQJBAAAAA==.',
['默染']='默染:BAAALgADCggJCAAAAA==.',
['龍貓']='龍貓臻夏:BAACLgAFFH8TAAIYAAYJKCA5BADwAQAYAAYJKCA5BADwAQAuAAQKfxkABBgACAk6IxAMACADABgACAk6IxAMACADAAIAAQmoFCttADgAABsAAQkpDDUrADQAAAAA.',
['龘小']='龘小闲闲龘:BAAALgADCgUJBQAAAA==.',
['龙呆']='龙呆呆:BAAALgAECgcJBwAAAA==.',
['龙啸']='龙啸玖仙:BAAALgAECgEJAQAAAA==.',
['龙敦']='龙敦敦:BAAALgAECgUJBgAAAA==.',
['龙熬']='龙熬:BAAALgAFFAIJAwAAAA==.',
['龙葵']='龙葵:BAAALgADCgUJBQAAAA==.',
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
