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

local lookup = {'Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','DemonHunter-Devourer','Priest-Shadow','Warlock-Demonology','Druid-Guardian','Warrior-Fury','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Warlock-Affliction','Mage-Frost','Warlock-Destruction','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Frost','Shaman-Restoration','Druid-Restoration','Monk-Brewmaster','Paladin-Protection',}
local provider = {region='CN',realm='通灵学院',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akstern:BAAALgAFFAQJAgAAAA==.',
An='Annewalksky:BAAALgAECgEJAQAAAA==.',
Au='Aunbris:BAAALgAECgUJBwAAAA==.',
Bi='Bigmother:BAAALgAECgUJBgAAAA==.Bigrass:BAAALgAFFAIJAwAAAA==.',
Bl='Blazblue:BAAALgADCgMJAwAAAA==.',
Br='Bredfly:BAAALgADCgEJAQAAAA==.',
De='Deadknight:BAAALgAECgcJCgABLgAFFAEJAQABAAAAAA==.',
Dk='Dkfour:BAABLgAFFH8IAAMCAAUJYiHAEQBaAQACAAQJYiHAEQBaAQADAAEJAAA0FQBGAAAAAA==.Dkthree:BAABLgAFFH8NAAMCAAUJlSLGBgCbAQACAAQJlSLGBgCbAQADAAEJAAAQEgBiAAAAAA==.',
Ed='Edifier:BAAALgAECgEJAQAAAA==.',
Fa='Fastboot:BAAALgAECgEJAQAAAA==.',
Ga='Gabrieltosh:BAAALgAECgMJBQAAAA==.',
Gi='Ginxf:BAAALgAECgYJBAAAAA==.',
Ho='Holy:BAABLgAFFH8IAAIEAAMJORZBDQD7AAAEAAMJORZBDQD7AAAAAA==.',
Hy='Hydra:BAAALgAECgcJDQAAAA==.',
Ke='Kevind:BAAALgAECgMJBQAAAA==.',
Ky='Kyneraan:BAABLgAFFH8LAAIFAAUJJB2ZBABsAQAFAAUJJB2ZBABsAQAAAA==.',
Ly='Lycant:BAAALgAECgcJAwAAAA==.',
Me='Mekina:BAAALgAECgkJCwAAAA==.',
Oo='Oosagi:BAAALgAECgUJBQAAAA==.',
Pl='Playermilytz:BAAALgADCgIJAgAAAA==.',
Pr='Prada:BAAALgAECgUJCQAAAA==.',
Ra='Ravens:BAAALgAECgcJDQAAAA==.',
Sa='Sameul:BAAALgAECgIJAwAAAA==.Sarama:BAAALgAECgkJCQABLgAFFAMJCQAGAA0jAA==.Saulh:BAAALgAECgcJAgAAAA==.',
Sc='Scolfield:BAAALgAECgEJAQAAAA==.',
Se='Sertraline:BAAALgAECgQJBgAAAA==.',
So='Sonshine:BAAALgADCgEJAQAAAA==.Sorrowsoul:BAABLgAECn8VAAIHAAYJ7QWNOwDEAAAHAAYJ7QWNOwDEAAAAAA==.',
Sy='Sylvanase:BAAALgAECgYJBgAAAA==.',
Xi='Xiwa:BAAALgAECgEJAQAAAA==.',
Yv='Yveltall:BAAALgAECgkJBgAAAA==.',
Za='Zale:BAAALgADCgIJAgAAAA==.',
Zi='Zigui:BAACLgAFFH8YAAICAAcJXhl8AAB8AgACAAcJXhl8AAB8AgAuAAQKfyYAAgIACQlsJFgEAI8DAAIACQlsJFgEAI8DAAEuAAQKAQkBAAEAAAAA.',
['一粒']='一粒丹丶怒風:BAAALgAECgEJAQAAAA==.',
['一锤']='一锤定阴:BAAALgAECgIJAgAAAA==.',
['七梵']='七梵:BAAALgAECgMJBAAAAA==.',
['万众']='万众倾倒:BAAALgADCgYJBgAAAA==.',
['万箭']='万箭穿心:BAAALgADCgMJAwAAAA==.',
['不如']='不如清羽:BAABLgAECn8UAAIIAAYJUCChCAAhAgAIAAYJUCChCAAhAgAAAA==.',
['不是']='不是九五:BAAALgAECgMJAwAAAA==.',
['不雨']='不雨亦潇潇:BAAALgAECgQJBQAAAA==.',
['两把']='两把大砍刀:BAAALgAECgYJBQAAAA==.',
['严禁']='严禁喂食:BAAALgAFFAMJBAAAAA==.',
['丨匹']='丨匹诺曹丨:BAAALgADCgEJAQAAAA==.',
['丨女']='丨女王丨:BAAALgADCgcJBQAAAA==.',
['丨泽']='丨泽:BAAALgAFFAEJAQAAAA==.',
['丶咒']='丶咒丶:BAAALgAECgQJDAAAAA==.',
['丶夏']='丶夏天:BAAALgAECgIJAgAAAA==.',
['丶若']='丶若澄:BAAALgAECgcJCAAAAA==.丶若缡:BAAALgAECgMJBgAAAA==.',
['丶逐']='丶逐丶:BAAALgAECgMJAwAAAA==.',
['丶黑']='丶黑夜丶:BAAALgAECgMJAwAAAA==.',
['丿微']='丿微笑削肾客:BAEALgAECgQJBAABLgAECgcJCAABAAAAAA==.',
['乃么']='乃么卵:BAAALgAECgYJEgAAAA==.',
['么么']='么么儿:BAAALgAECgEJAQAAAA==.',
['乔鲁']='乔鲁诺乔巴纳:BAAALgAECgcJEQAAAA==.',
['乞巧']='乞巧:BAABLgAFFH8FAAIJAAMJpgWbEwDjAAAJAAMJpgWbEwDjAAAAAA==.',
['五队']='五队骑士:BAAALgAECgkJDgAAAA==.',
['人剑']='人剑合一:BAAALgAFFAEJAQAAAA==.',
['人性']='人性本恶:BAAALgAECgYJCAAAAA==.',
['人手']='人手一只熊猫:BAAALgADCgEJAQAAAA==.',
['人随']='人随己愿:BAAALgAECgYJCgAAAA==.',
['从开']='从开始到结束:BAAALgAECgEJAQAAAA==.',
['伽利']='伽利略:BAAALgADCgEJAQAAAA==.',
['体育']='体育老师:BAAALgAECgYJCAAAAA==.',
['何处']='何处起秋风:BAAALgADCgEJAQAAAA==.',
['你跺']='你跺你也麻七:BAAALgAECgYJBgAAAA==.你跺你也麻五:BAAALgAFFAIJAgAAAA==.你跺你也麻八:BAAALgAECgYJBAAAAA==.',
['依然']='依然尜尜:BAAALgADCgMJAwAAAA==.',
['俺姑']='俺姑姑是杨过:BAAALgAECgIJAwAAAA==.',
['俺村']='俺村我最好:BAAALgAECgcJDQAAAA==.俺村我最狂:BAAALgAECgUJAQAAAA==.',
['俺要']='俺要打拾个:BAAALgADCgMJAwAAAA==.',
['假骑']='假骑士:BAAALgAECgEJAQAAAA==.',
['八兩']='八兩:BAABLgAECn8dAAIDAAkJiAk3GQCMAQADAAkJiAk3GQCMAQAAAA==.',
['公孙']='公孙离:BAAALgADCgEJAQAAAA==.',
['六指']='六指神魔:BAAALgAECgEJAgAAAA==.',
['冰淇']='冰淇霖:BAAALgAECgcJCQAAAA==.',
['冷月']='冷月丨葬魂:BAAALgADCgEJAQAAAA==.',
['冷血']='冷血小猪包:BAAALgAECgcJDQABLgAFFAUJAQABAAAAAA==.',
['分明']='分明抢钱:BAAALgADCgEJAQAAAA==.',
['刘小']='刘小俱:BAAALgADCgMJAwAAAA==.',
['初恋']='初恋纯入血:BAAALgADCgcJBwAAAA==.',
['初澜']='初澜:BAAALgADCgEJAgAAAA==.',
['别管']='别管我自己回:BAAALgADCgIJAgAAAA==.',
['剑在']='剑在人在:BAAALgADCgEJAQAAAA==.',
['功夫']='功夫龙猫:BAAALgAFFAIJBAAAAA==.',
['勇敢']='勇敢的菠萝包:BAAALgAFFAEJAQAAAA==.',
['北极']='北极胖熊:BAAALgAECgcJEQAAAA==.',
['十六']='十六:BAAALgAECgYJCQAAAA==.',
['十方']='十方無敌:BAAALgAECgYJBgAAAA==.十方皆殺:BAAALgAECgMJAwABLgAECgkJCQABAAAAAA==.',
['千姬']='千姬:BAACLgAFFH8KAAMKAAMJ8h98CADgAAALAAMJfRgKDQD9AAAKAAMJjht8CADgAAAuAAQKfxcAAwsABwnJILkSABwCAAsABgmqHbkSABwCAAoABwn5GakfAOQBAAEuAAUUBwkcAAYAqx4A.',
['千曰']='千曰榮光:BAAALgAECgcJCwAAAA==.',
['南枫']='南枫:BAABLgAECn8ZAAMMAAgJ4BmvGABjAgAMAAgJihivGABjAgANAAQJyhxLJQAOAQAAAA==.',
['卡林']='卡林血蹄:BAAALgAECgEJAQAAAA==.',
['卢大']='卢大丝丝:BAAALgAECgcJBQAAAA==.',
['卯之']='卯之花八千流:BAAALgAECgQJCAAAAA==.',
['叁仟']='叁仟蚊够未:BAAALgAECgUJBQAAAA==.',
['双刀']='双刀斩日:BAAALgAECgQJBAAAAA==.',
['双手']='双手成就梦想:BAABLgAFFH8GAAIFAAMJJgIKFwCuAAAFAAMJJgIKFwCuAAAAAA==.',
['变熊']='变熊等死:BAAALgAECgYJCAAAAA==.',
['古耳']='古耳蛋:BAAALgAFFAIJAgAAAA==.',
['只是']='只是一死骑:BAABLgAFFH8JAAICAAMJeSOwCwAxAQACAAMJeSOwCwAxAQAAAA==.',
['只牛']='只牛是鹌鹑:BAAALgAECgkJDQAAAA==.',
['史提']='史提芬史狒堡:BAAALgAECgEJAQAAAA==.',
['吃瓜']='吃瓜小骑士:BAAALgADCgEJAQAAAA==.',
['名字']='名字超难取啊:BAAALgAFFAIJAgAAAA==.',
['吳彦']='吳彦祖:BAAALgADCgEJAQAAAA==.',
['周伯']='周伯通:BAAALgAECgMJBAAAAA==.',
['咕噜']='咕噜糖:BAAALgAECgcJCgAAAA==.',
['咕德']='咕德白鸽:BAAALgAECgEJAgAAAA==.',
['咳嗽']='咳嗽:BAAALgAFFAQJBAAAAA==.',
['咸鱼']='咸鱼腩:BAAALgAECgIJAgAAAA==.咸鱼识游水:BAABLgAECn8XAAIOAAkJvRk7DgCmAgAOAAkJvRk7DgCmAgAAAA==.',
['哀伤']='哀伤:BAAALgAECgYJCQAAAA==.',
['哀希']='哀希:BAAALgAECgEJAgAAAA==.',
['哎哟']='哎哟嗬:BAAALgAFFAIJAgAAAA==.',
['唔知']='唔知起咩名好:BAAALgAECgkJCQAAAA==.',
['嗜血']='嗜血屠夫丶:BAAALgADCgcJDQAAAA==.',
['嘿呦']='嘿呦嘿呦嘿:BAAALgAECgEJAwAAAA==.',
['嘿黑']='嘿黑牛:BAAALgADCgcJBwAAAA==.',
['嚣张']='嚣张的龙仔:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光晕晕:BAAALgAFFAQJBAAAAA==.圣光请保佑我:BAAALgAECgEJAgAAAA==.',
['圣剑']='圣剑杜兰德尔:BAAALgAECgcJBwAAAA==.',
['坂上']='坂上:BAAALgAECgcJCQAAAA==.',
['型光']='型光闪烁:BAAALgADCgcJBwAAAA==.',
['埃斯']='埃斯:BAAALgAECgUJCQAAAA==.',
['堕落']='堕落深瞳:BAABLgAECn8UAAINAAcJ6x2mGwBhAgANAAcJ6x2mGwBhAgAAAA==.',
['塞尔']='塞尔提:BAAALgADCgEJAQAAAA==.',
['塞雷']='塞雷娅:BAAALgAECgcJCgAAAA==.',
['墩墩']='墩墩子灬:BAAALgAECgEJAQAAAA==.',
['夏目']='夏目安安:BAAALgAECgIJAgAAAA==.',
['夏雪']='夏雪秋瞳:BAAALgAECgIJAgAAAA==.',
['夕阳']='夕阳下的承诺:BAAALgAECgEJAQAAAA==.',
['大灰']='大灰狼:BAACLgAFFH8KAAMHAAQJsxUpEgADAQAHAAMJ/hUpEgADAQAPAAEJ0RTvBABZAAAuAAQKfyAAAw8ACQnGGv4GAOcBAA8ABgmjGv4GAOcBAAcACQnLGXAOAMEBAAAA.',
['大跳']='大跳飞尸:BAAALgAECgEJAQAAAA==.',
['天呐']='天呐我真黑:BAAALgADCgEJAgAAAA==.',
['天廻']='天廻龙:BAAALgAECgIJAgAAAA==.',
['天才']='天才的背影:BAAALgADCgIJAgAAAA==.',
['天龙']='天龙无极:BAAALgAECgEJAQAAAA==.',
['奥拉']='奥拉丶小红手:BAABLgAECn8WAAIQAAcJIxjgqQCGAQAQAAcJIxjgqQCGAQAAAA==.',
['奶妈']='奶妈奶我啊:BAAALgAECgEJAgAAAA==.',
['妇科']='妇科医生:BAAALgAECgIJAwAAAA==.',
['姜茶']='姜茶:BAACLgAFFH8HAAIHAAIJCSX/JwDZAAAHAAIJCSX/JwDZAAAuAAQKfx0AAwcABwn+IAczAEACAAcABgn+IAczAEACABEAAwnbGyIwAPoAAAAA.',
['子时']='子时說梦话:BAAALgADCgEJAQAAAA==.',
['孤傲']='孤傲丨水仙:BAAALgAECgEJAQAAAA==.',
['孤独']='孤独丨患者:BAAALgAECgcJDQAAAA==.',
['宋智']='宋智孝:BAAALgAECgYJCAAAAA==.',
['审判']='审判魔:BAAALgAECgQJCQAAAA==.',
['小古']='小古:BAAALgAECgYJEgAAAA==.',
['小奶']='小奶茉:BAAALgAECgEJAgAAAA==.',
['小小']='小小笑骂:BAAALgAFFAIJAgAAAA==.',
['小杨']='小杨术四:BAAALgAECgYJBgAAAA==.',
['小溪']='小溪:BAAALgAECgIJAgAAAA==.',
['小猫']='小猫咪噜噜:BAAALgADCgEJAQAAAA==.小猫麦旋风:BAAALgAFFAIJAwAAAA==.',
['小能']='小能能:BAAALgAECgcJBwAAAA==.',
['少冰']='少冰三分糖:BAABLgAECn8dAAIKAAcJMRfMHwDjAQAKAAcJMRfMHwDjAQAAAA==.',
['少年']='少年牛马:BAAALgAECgEJAQAAAA==.',
['就喜']='就喜欢三真:BAAALgAECgEJAQAAAA==.就喜欢真三:BAAALgAECgEJAQAAAA==.',
['尾灯']='尾灯:BAAALgAECgMJBAAAAA==.',
['岁末']='岁末丿:BAAALgADCgUJAwAAAA==.',
['工藤']='工藤丨有希子:BAAALgADCgEJAQAAAA==.',
['巨蟹']='巨蟹座丶冷修:BAAALgAFFAMJBAAAAA==.',
['巴兰']='巴兰尼科夫:BAAALgAECgEJAgAAAA==.',
['布加']='布加拉提:BAAALgAECgYJDQAAAA==.',
['布里']='布里起司:BAACLgAFFH8IAAIEAAMJzRv6CgAMAQAEAAMJzRv6CgAMAQAuAAQKfxQAAgQABwmQHy0vAGYCAAQABwmQHy0vAGYCAAAA.',
['帕路']='帕路奇亚:BAAALgADCgMJAwABLgAECgQJBAABAAAAAA==.',
['平方']='平方为负的术:BAABLgAFFH8LAAMHAAUJaxjUDQBtAQAHAAQJpxrUDQBtAQARAAMJBQ3ZBwDwAAAAAA==.',
['幽幽']='幽幽冰心:BAAALgAECgMJAQAAAA==.',
['广州']='广州打击:BAAALgADCgUJBQAAAA==.',
['庐山']='庐山升龙霸丶:BAAALgADCgIJAgAAAA==.',
['弑魂']='弑魂战神:BAAALgAFFAIJAwAAAA==.',
['张韶']='张韶涵:BAAALgAECgIJAgAAAA==.',
['弯弯']='弯弯的睫毛:BAAALgADCgYJCQAAAA==.',
['弹头']='弹头:BAAALgAECgYJDQAAAA==.',
['彭于']='彭于晏:BAAALgAECgYJBgAAAA==.',
['影子']='影子治疗师:BAAALgAECgkJCQABLgAFFAYJEwALACwVAA==.',
['彼岸']='彼岸之光:BAAALgAECgEJAQAAAA==.彼岸之灵:BAAALgAECgEJAQAAAA==.彼岸月光:BAAALgAECgYJBgAAAA==.',
['德德']='德德睇:BAAALgAECgEJAQAAAA==.',
['德滴']='德滴德滴德:BAAALgAECgEJAQAAAA==.',
['性感']='性感黄:BAAALgAECgYJBwAAAA==.',
['恶魔']='恶魔壹锤:BAAALgAECgUJBQAAAA==.恶魔桐桐:BAAALgAECgUJCAAAAA==.',
['情歌']='情歌:BAAALgADCgMJAwAAAA==.',
['意韵']='意韵甜心:BAAALgAFFAIJAgAAAA==.',
['感觉']='感觉怪怪得:BAAALgAECgYJBwAAAA==.',
['我就']='我就系老世:BAAALgADCgcJBwAAAA==.',
['我心']='我心头有哈数:BAAALgAECgYJCgAAAA==.',
['我是']='我是个好魔女:BAAALgADCgIJAgAAAA==.',
['我还']='我还没想好丶:BAAALgAFFAQJBAAAAA==.',
['战无']='战无不胜:BAAALgAECgYJCgAAAA==.',
['摸凹']='摸凹猫:BAAALgAFFAMJAwAAAA==.',
['敌法']='敌法爱你呦:BAAALgAFFAIJAgABLgAFFAYJBgAFABsdAA==.',
['斜杨']='斜杨:BAAALgAECgYJDQAAAA==.',
['施巴']='施巴拉稀:BAAALgADCgMJAwAAAA==.',
['无丁']='无丁晨:BAAALgAECgYJCgAAAA==.',
['无敌']='无敌小婕婕:BAAALgADCgUJBQAAAA==.无敌转圈圈:BAAALgADCgEJAQAAAA==.',
['无根']='无根水:BAAALgAECgYJBgAAAA==.',
['无里']='无里安可:BAACLgAFFH8GAAIHAAIJZAVUJQCRAAAHAAIJZAVUJQCRAAAuAAQKfxcAAgcACQlbEn4yAEICAAcACQlbEn4yAEICAAAA.',
['无限']='无限回音:BAAALgAECgYJBgAAAA==.无限暴走:BAAALgAFFAMJBAAAAA==.',
['昕爷']='昕爷丶:BAAALgAECgIJAgAAAA==.',
['星之']='星之时期:BAAALgAECgUJCgAAAA==.',
['星落']='星落法:BAAALgAECgQJBQABLgAFFAUJCwAFACQdAA==.',
['晨钟']='晨钟暮鼓:BAACLgAFFH8MAAQSAAQJWhz6BgCAAQASAAQJWhz6BgCAAQATAAIJBRapFwClAAAUAAEJwgwsAwBUAAAuAAQKfxgABBIACAkbIW4GANwCABIACAkbIW4GANwCABQABwk2HmkIAF4CABMAAQmaEIdiADIAAAAA.',
['普拉']='普拉姆火鸟:BAAALgAECgEJAQAAAA==.',
['晴稚']='晴稚:BAAALgADCgUJBQAAAA==.',
['暗度']='暗度法拉:BAAALgAECgIJAgAAAA==.',
['暗黑']='暗黑之子:BAAALgADCgIJAgAAAA==.',
['暮幽']='暮幽:BAAALgAECgcJBgAAAA==.',
['曹清']='曹清华:BAAALgAECgYJDQAAAA==.',
['曾经']='曾经最美:BAAALgAECgEJAQAAAA==.',
['最大']='最大公约术:BAABLgAFFH8IAAMHAAQJSx3aGQAjAQAHAAMJIx/aGQAjAQARAAEJxhc9EwBYAAABLgAFFAYJEwAHAHEiAA==.',
['最遥']='最遥远:BAAALgADCgUJCAAAAA==.',
['月亮']='月亮猫:BAABLgAECn8VAAQGAAcJvwvpMwBJAQAGAAYJCwvpMwBJAQALAAYJbw4SKwBBAQAKAAUJNwR9WgDKAAAAAA==.',
['有女']='有女畵朱红:BAAALgAECgEJAQAAAA==.',
['有架']='有架车车:BAAALgAECgEJAQAAAA==.',
['木紫']='木紫:BAAALgADCgEJAQAAAA==.',
['机械']='机械了:BAAALgAECgcJBwAAAA==.',
['李元']='李元霸:BAAALgAECgIJAgAAAA==.',
['李雷']='李雷:BAAALgADCgYJBgAAAA==.',
['村口']='村口王师傅丶:BAAALgAECgYJDQAAAA==.',
['杜克']='杜克:BAAALgAECgEJAQAAAA==.',
['果达']='果达:BAAALgAECgEJAQAAAA==.',
['枪机']='枪机:BAAALgAECgYJDAAAAA==.',
['柔情']='柔情冰仔:BAAALgAECgUJBQAAAA==.',
['柔顺']='柔顺黑发:BAAALgADCgEJAQAAAA==.',
['止戈']='止戈流来了:BAAALgAECgIJAgABLgAFFAUJCwAFACQdAA==.',
['死亡']='死亡步伐:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛虫:BAAALgAECgYJDgAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8qAAILAAUJ/yTGAAAWAgALAAUJ/yTGAAAWAgAAAA==.',
['水果']='水果店没水果:BAAALgADCgcJBwAAAA==.',
['汪苏']='汪苏泷:BAAALgAFFAEJAQAAAA==.',
['沃特']='沃特咩冷:BAAALgAFFAEJAQAAAA==.',
['沐涵']='沐涵:BAAALgAFFAMJBAAAAA==.',
['泷泽']='泷泽伸洋:BAAALgADCgUJBQAAAA==.',
['浅歌']='浅歌下夜曲:BAAALgAFFAIJAgAAAA==.',
['淡忘']='淡忘瞬间:BAAALgAECgIJAgAAAA==.淡忘那一刻:BAAALgAFFAEJAQAAAA==.',
['添柴']='添柴少女:BAAALgAECgYJDAABLgAFFAEJAQABAAAAAA==.',
['温两']='温两碗姜茶:BAAALgAECgIJAgABLgAFFAIJBwAHAAklAA==.',
['温九']='温九碗姜茶:BAAALgAECgEJAQABLgAFFAIJBwAHAAklAA==.',
['温五']='温五碗姜茶:BAAALgAECgMJBAABLgAFFAIJBwAHAAklAA==.',
['温州']='温州陈伟霆:BAAALgAECgcJDQAAAA==.',
['温暖']='温暖的丹:BAAALgAECgEJAQAAAA==.',
['港台']='港台一枝花:BAAALgAECgYJBgAAAA==.',
['潇洒']='潇洒哥:BAACLgAFFH8HAAIEAAMJowrQFwDvAAAEAAMJowrQFwDvAAAuAAQKfxcAAgQACQm7F/4jAJgCAAQACQm7F/4jAJgCAAAA.',
['潴丨']='潴丨寶寶灬:BAAALgADCgIJAgAAAA==.',
['火锅']='火锅儿:BAAALgAECgMJBQAAAA==.火锅里的五花:BAAALgAECgYJCAAAAA==.火锅里的鱿鱼:BAAALgAECgIJAgAAAA==.',
['灬绅']='灬绅士灬:BAAALgAECgUJBgAAAA==.',
['灰烬']='灰烬丨德:BAAALgAFFAIJAgAAAA==.',
['灾难']='灾难之握:BAABLgAFFH8TAAMHAAYJcSLXAgD9AQAHAAUJLSLXAgD9AQARAAMJoxmEBgAHAQAAAA==.',
['炼狱']='炼狱毛毛虫:BAAALgAECgcJEgAAAA==.',
['烟火']='烟火的忧郁:BAAALgAECgEJAQAAAA==.',
['無限']='無限:BAAALgAECgIJAgAAAA==.',
['熊猫']='熊猫也是猫:BAAALgAECgUJBQAAAA==.',
['爱喝']='爱喝冰美:BAAALgAECgUJBgAAAA==.',
['爷就']='爷就很嚣张:BAAALgAECgQJBQAAAA==.',
['爷爷']='爷爷火了:BAAALgAECgQJBAAAAA==.',
['爹爹']='爹爹在此:BAAALgAECgQJBgAAAA==.',
['牛仔']='牛仔掋裤:BAABLgAFFH8MAAIJAAQJBBTvCABhAQAJAAQJBBTvCABhAQAAAA==.',
['牛孖']='牛孖筋:BAAALgAECgQJBQAAAA==.',
['牛牛']='牛牛是头牛:BAAALgAFFAEJAgAAAA==.',
['牛羊']='牛羊羔:BAAALgAECgcJEwAAAA==.',
['牛若']='牛若有情:BAAALgAECgIJAgAAAA==.',
['狂扣']='狂扣脚趾丫:BAAALgADCgEJAQAAAA==.',
['狂歡']='狂歡:BAABLgAECn8UAAMHAAkJxhENXwCsAQAHAAcJoxANXwCsAQARAAMJ7BNyNgDdAAAAAA==.',
['狐贼']='狐贼狸:BAAALgAECgQJBgAAAA==.',
['狸沫']='狸沫:BAAALgAECgkJEAAAAA==.',
['狼之']='狼之狠:BAAALgAECgEJAgAAAA==.',
['猪丶']='猪丶佩奇:BAAALgAECgYJCAAAAA==.',
['猫咪']='猫咪德:BAAALgAECgYJBwAAAA==.',
['猴子']='猴子灬:BAAALgADCgYJBgAAAA==.',
['玐爺']='玐爺:BAAALgAFFAIJAgAAAA==.',
['玫瑰']='玫瑰陛下:BAAALgAECgYJBwAAAA==.',
['瑺媙']='瑺媙:BAAALgAECgcJDQAAAA==.',
['瓦兰']='瓦兰克斯:BAEALgAECgMJAwABLgAECgcJCAABAAAAAA==.',
['电不']='电不死你:BAAALgAECgQJBAAAAA==.',
['电眼']='电眼逼人:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂的小白:BAAALgAECgYJDwAAAA==.',
['痣疮']='痣疮特别大:BAAALgAECgYJCgAAAA==.',
['白又']='白又白又白:BAAALgAFFAEJAQAAAA==.',
['白牛']='白牛乄灑滿:BAAALgAECgkJCQAAAA==.',
['百变']='百变大师:BAAALgAECgQJBwAAAA==.',
['的的']='的的徳:BAAALgADCgcJBwAAAA==.',
['盖一']='盖一小号:BAABLgAECn8UAAIQAAYJhBVGqwCEAQAQAAYJhBVGqwCEAQAAAA==.',
['盖棉']='盖棉被纯聊天:BAAALgAECgkJDQAAAA==.',
['相良']='相良中士:BAAALgAECgQJBAAAAA==.',
['省身']='省身慎言:BAACLgAFFH8JAAMCAAMJuhThJwD4AAACAAMJuhThJwD4AAAVAAEJ1QAwBgA+AAAuAAQKfxQAAwIACAk9EydTAPgBAAIACAmQEidTAPgBABUAAQkRDD0MAC4AAAAA.',
['真丶']='真丶古尓丹:BAAALgAECgIJAwAAAA==.',
['矮人']='矮人秉晨:BAABLgAECn8WAAIEAAcJNiPiHgCyAgAEAAcJNiPiHgCyAgABLgAFFAYJCwAQAL0cAA==.',
['石头']='石头猪:BAAALgAECgYJBQAAAA==.',
['磊哥']='磊哥大老二:BAAALgADCgMJAwAAAA==.',
['神圣']='神圣发丝:BAAALgAFFAQJAwAAAA==.神圣闪光:BAAALgAFFAEJAQAAAA==.',
['神牧']='神牧拿刀啦:BAAALgAECgEJAQAAAA==.',
['福星']='福星高照:BAAALgAECgUJBQAAAA==.',
['秋水']='秋水月缘:BAAALgAECgcJCgAAAA==.',
['符文']='符文百合:BAAALgAECgYJCgAAAA==.',
['筱灰']='筱灰机:BAAALgAECgcJBgAAAA==.',
['米凯']='米凯儿:BAAALgAECgMJAwAAAA==.',
['米开']='米开朗基啰:BAABLgAECn8VAAIWAAgJUxVLJAAFAgAWAAgJUxVLJAAFAgAAAA==.',
['糖小']='糖小猫:BAABLgAECn8XAAIXAAgJdRgLLQD6AQAXAAgJdRgLLQD6AQAAAA==.',
['紗織']='紗織:BAAALgAFFAUJAQAAAA==.',
['红提']='红提:BAAALgADCgcJBwAAAA==.',
['红色']='红色铁骑:BAAALgAFFAQJBAAAAA==.',
['给沃']='给沃擦皮鞋:BAAALgAFFAIJBAAAAA==.',
['维拉']='维拉帕米:BAAALgADCgMJAwAAAA==.',
['老哔']='老哔登:BAAALgAECgEJAQAAAA==.',
['腐蚀']='腐蚀之殇:BAABLgAECn8ZAAMHAAkJjSRMAQDCAwAHAAkJgSRMAQDCAwARAAcJxSPRAgDUAgABLgAFFAQJDQACAK4UAA==.',
['舌诊']='舌诊医生:BAAALgAECgYJBgAAAA==.',
['花妞']='花妞妞:BAAALgAECgEJAQAAAA==.',
['芳村']='芳村丶刘醒:BAAALgAECgYJBgAAAA==.',
['若溪']='若溪予依:BAAALgAFFAEJAgAAAA==.',
['范达']='范达尔丶血亏:BAAALgAECgMJAgAAAA==.',
['茶茶']='茶茶么么哒:BAAALgAECgYJCwAAAA==.',
['荣光']='荣光的贊歌:BAABLgAFFH8GAAIFAAMJmRNzHADvAAAFAAMJmRNzHADvAAAAAA==.',
['荷鲁']='荷鲁斯丶:BAAALgAECgQJAQAAAA==.',
['莫子']='莫子淼:BAAALgAECgEJAgAAAA==.',
['莫西']='莫西干马克:BAAALgADCgMJAwAAAA==.',
['萌萌']='萌萌僧:BAAALgAECgEJAQAAAA==.',
['萧尼']='萧尼素宝:BAAALgAECgUJCgAAAA==.',
['萨士']='萨士汽水:BAAALgAECgYJBAAAAA==.',
['萨澈']='萨澈庆:BAAALgAECgYJBgAAAA==.',
['萨默']='萨默海尔德:BAAALgAECgcJDAAAAA==.',
['葱丶']='葱丶条:BAAALgAECgEJAQAAAA==.',
['蘑菇']='蘑菇藤椒面:BAAALgADCgIJAgAAAA==.',
['虚了']='虚了:BAAALgAECgMJAwAAAA==.',
['蟒蛇']='蟒蛇:BAAALgAECgQJBAAAAA==.',
['血压']='血压有点高:BAAALgADCgEJAQAAAA==.',
['血色']='血色丶冰咖啡:BAABLgAFFH8GAAIKAAMJfCIKAwAoAQAKAAMJfCIKAwAoAQAAAA==.血色复审:BAAALgADCgcJCwAAAA==.血色德肉丝:BAAALgAECgYJBgAAAA==.血色闪光:BAAALgAECgYJDAAAAA==.',
['裂心']='裂心小兽阿文:BAAALgAECgYJAQAAAA==.',
['裂魂']='裂魂:BAAALgAECgQJBAAAAA==.',
['角斗']='角斗士丶天天:BAAALgAECgQJBAAAAA==.',
['言凊']='言凊:BAACLgAFFH8IAAIQAAMJigoHJwCdAAAQAAMJigoHJwCdAAAuAAQKfx4AAhAACAnvGLVSAEACABAACAnvGLVSAEACAAAA.',
['詠淇']='詠淇彡:BAAALgADCgMJAwAAAA==.',
['请叫']='请叫我小胡:BAAALgAECgYJBgAAAA==.请叫我演员:BAAALgAECgIJBAAAAA==.',
['豆豆']='豆豆不乖:BAAALgAECgEJAQAAAA==.',
['貝諾']='貝諾華:BAAALgAECgYJBgAAAA==.',
['走走']='走走道:BAAALgAECgIJAgAAAA==.',
['赵无']='赵无极:BAAALgAECgIJAgAAAA==.',
['超耐']='超耐磨大咪米:BAAALgAECgYJBgAAAA==.超耐磨牛肥肠:BAAALgADCgYJBgAAAA==.',
['趴下']='趴下唱征服:BAAALgAECgcJBgAAAA==.',
['轉角']='轉角:BAAALgAECgYJBgAAAA==.',
['辛多']='辛多雷之剑:BAAALgAECgIJAgAAAA==.',
['辣条']='辣条灬千层:BAABLgAFFH8FAAIQAAIJ6xXQIQCvAAAQAAIJ6xXQIQCvAAAAAA==.',
['边缘']='边缘刑者:BAAALgAECgEJAQAAAA==.',
['迈克']='迈克尔华兹:BAAALgAECgEJAQAAAA==.',
['迪克']='迪克去分担三:BAABLgAFFH8MAAMCAAUJDCYPAQC/AQACAAQJDCYPAQC/AQADAAEJAADJEgBcAAAAAA==.',
['追这']='追这只鹿丶:BAABLgAFFH8GAAIFAAYJaBgdAQDPAQAFAAYJaBgdAQDPAQAAAA==.',
['透明']='透明背心:BAAALgAECgQJCAAAAA==.',
['邪丨']='邪丨氏:BAAALgAECgEJAQAAAA==.',
['部落']='部落的驱逐者:BAAALgADCgUJBQAAAA==.',
['酒丶']='酒丶酒:BAAALgAECgEJAQAAAA==.',
['酒烩']='酒烩七喜:BAACLgAFFH8UAAIDAAUJux/qAQDJAQADAAUJux/qAQDJAQAuAAQKfxoAAgMABwnpIkkKAHUCAAMABwnpIkkKAHUCAAAA.',
['醉醉']='醉醉么么哒:BAABLgAECn8UAAIYAAYJ6xVLDgA1AQAYAAYJ6xVLDgA1AQAAAA==.',
['醒醒']='醒醒该睡觉了:BAAALgAECgMJAwAAAA==.',
['铁古']='铁古:BAAALgAECgMJAwAAAA==.',
['铁血']='铁血奥尔芬斯:BAABLgAECn8WAAQOAAcJpxTGMgCzAQAOAAcJpxTGMgCzAQAEAAUJ6xilgAB5AQAZAAYJ9g3ZIgDxAAAAAA==.',
['铃王']='铃王:BAAALgAECgYJBgAAAA==.',
['铣銭']='铣銭铲锂镒镬:BAAALgAECgEJAQAAAA==.',
['锕莱']='锕莱克丝塔萨:BAAALgAFFAQJBAAAAA==.',
['閼泩']='閼泩壹個蒗:BAAALgAECgUJCQAAAA==.',
['闪电']='闪电霹雳:BAAALgAECgcJBwAAAA==.',
['闲们']='闲们:BAAALgAECgUJCAABLgAECgUJDQABAAAAAA==.',
['闲門']='闲門:BAAALgAECgUJDQAAAA==.',
['队长']='队长是贼:BAAALgAFFAEJAQAAAA==.',
['阡陌']='阡陌:BAAALgAECgYJCwABLgAFFAIJBwAHAAklAA==.',
['阿尔']='阿尔萨斯丶:BAAALgAECgIJAgAAAA==.',
['阿猫']='阿猫阿狗某牧:BAAALgADCgYJBwAAAA==.',
['阿穆']='阿穆:BAAALgAECgQJBQAAAA==.',
['陈奕']='陈奕迅:BAAALgAECgYJEAABLgAFFAEJAQABAAAAAA==.',
['雨一']='雨一直下:BAABLgAFFH8NAAMHAAUJtRp7DQBwAQAHAAQJfxt7DQBwAQARAAIJpxC8DACnAAABLgAFFAYJEwAHAHEiAA==.',
['雪冷']='雪冷冰清:BAAALgAECgEJAQAAAA==.',
['静谧']='静谧丨水仙:BAAALgAECgkJCgAAAA==.',
['韩韩']='韩韩:BAAALgAECgEJAQAAAA==.',
['风语']='风语者:BAAALgADCgEJAQAAAA==.风语飘飘:BAAALgAECgEJAQAAAA==.',
['风雨']='风雨飞唐:BAAALgAECgEJAQAAAA==.',
['飘渺']='飘渺小轩轩:BAAALgAECgYJBgAAAA==.',
['馬里']='馬里奧:BAAALgAECgQJBAAAAA==.',
['高温']='高温火球:BAAALgAECgUJDQAAAA==.',
['魔骑']='魔骑:BAAALgAECgQJBAAAAA==.',
['魚丁']='魚丁糸:BAAALgADCgMJAwAAAA==.',
['魜鱼']='魜鱼:BAAALgAECgIJAgAAAA==.',
['鹌鹑']='鹌鹑很大:BAAALgAECgEJAQAAAA==.',
['鹿易']='鹿易十七:BAAALgAFFAQJBAAAAA==.鹿易十八:BAABLgAFFH8GAAIFAAYJPxTOAwD5AQAFAAYJPxTOAwD5AQAAAA==.鹿易廿一:BAABLgAFFH8GAAIFAAYJ9RSkAQCyAQAFAAYJ9RSkAQCyAQAAAA==.',
['黄獅']='黄獅虎:BAEALgAECgcJCAAAAA==.',
['黑子']='黑子:BAAALgADCgEJAQAAAA==.',
['黛懵']='黛懵:BAAALgAECgYJCgAAAA==.',
['鼠鼠']='鼠鼠一:BAAALgAECgYJAwAAAA==.鼠鼠三:BAAALgAFFAQJBAAAAA==.鼠鼠二:BAAALgAFFAQJBAAAAA==.鼠鼠五:BAAALgAECgYJCgABLgAFFAYJEwAHAHEiAA==.鼠鼠四:BAAALgAECgYJBgAAAA==.',
['齊天']='齊天夶聖:BAAALgADCgUJBQAAAA==.',
['龙飞']='龙飞是我哥:BAAALgAECgQJBAAAAA==.',
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
