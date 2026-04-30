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

local lookup = {'Evoker-Preservation','Unknown-Unknown','Paladin-Retribution','Evoker-Augmentation','Druid-Feral','Monk-Windwalker','Mage-Frost','Warrior-Arms','Druid-Guardian','DeathKnight-Unholy','Druid-Restoration','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','DemonHunter-Devourer','Druid-Balance','Warlock-Ranged','Priest-Holy','Hunter-Ranged','Hunter-Survival','Paladin-Holy','Warrior-Protection','Warrior-Fury','Rogue-Subtlety','Monk-Brewmaster','Paladin-Any','Monk-Mistweaver','Shaman-Restoration','DeathKnight-Blood',}
local provider = {region='CN',realm='深渊之巢',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alex:BAAALgAECgMJBAABLgAFFAMJBgABADUkAA==.',
Ay='Ayanamirei:BAAALgAFFAQJBAAAAA==.',
Az='Azaka:BAAALgAFFAIJAgAAAA==.',
Be='Beryl:BAAALgADCgEJAQABLgAECgYJBwACAAAAAA==.',
Br='Brokenlife:BAAALgADCgIJAgABLgAFFAMJBgABADUkAA==.',
Bu='Bumo:BAABLgAECn8XAAIDAAcJNx+6MQBcAgADAAcJNx+6MQBcAgAAAA==.',
Ch='Chinchilla:BAAALgADCggJCQAAAA==.',
Da='Darkurge:BAAALgAECgMJAwAAAA==.',
Di='Discrete:BAACLgAFFH8GAAMBAAMJNSSKCwAxAQABAAMJNSSKCwAxAQAEAAEJjQmeIgBIAAAuAAQKfyMAAgEACAnlJDQAAEsDAAEACAnlJDQAAEsDAAAA.Divination:BAAALgAECgUJBgAAAA==.',
Dr='Dragprin:BAAALgADCgIJAgAAAA==.',
Eb='Ebod:BAAALgAECgIJAgAAAA==.Ebody:BAAALgAECgcJCwAAAA==.',
Ha='Hansonl:BAACLgAFFH8IAAIFAAQJ+h/UAACkAQAFAAQJ+h/UAACkAQAuAAQKfxcAAgUABwmVJGYEANYCAAUABwmVJGYEANYCAAAA.',
Hu='Humbert:BAAALgADCgEJAgAAAA==.',
Jo='Johnwick:BAAALgADCgQJBAAAAA==.',
Ka='Kakyo:BAAALgAECgcJEAAAAA==.',
Ma='Maganess:BAAALgAECgEJAQABLgAECgYJBwACAAAAAA==.Maggie:BAAALgADCgQJBAAAAA==.',
Mi='Mikiya:BAAALgAECgMJAgAAAA==.',
Mu='Mujika:BAAALgADCgMJBAAAAA==.Mushroom:BAAALgAECgcJDwAAAA==.',
Ni='Nirvaner:BAAALgAECgYJBwAAAA==.',
No='Nobody:BAAALgAECgYJBgAAAA==.',
Ot='Otman:BAAALgAECgMJAwAAAA==.',
Pi='Pidic:BAAALgAECgQJBAABLgAECgYJCQACAAAAAA==.',
Pl='Playercphtgt:BAAALgAECgQJBAAAAA==.Playerikid:BAAALgADCgIJAgAAAA==.Playerngzede:BAAALgADCgEJAgAAAA==.',
Qi='Qiqi:BAAALgAECgQJBQAAAA==.',
Ra='Raphaelplay:BAAALgAECgYJBgAAAA==.Raphaelwind:BAAALgAFFAEJAQAAAA==.',
Re='Reina:BAAALgAECgMJBAAAAA==.Relieved:BAAALgAECgYJCwABLgAFFAMJBgABADUkAA==.Reoxyo:BAABLgAECn8mAAIGAAgJXh+WCgDPAgAGAAgJXh+WCgDPAgAAAA==.',
Sa='Samsungi:BAAALgAFFAIJAgAAAA==.',
So='Soloknights:BAAALgAECgYJBgAAAA==.Sora:BAAALgADCgQJBAAAAA==.',
Sy='Syllabear:BAAALgADCgUJBQAAAA==.',
Sz='Sza:BAAALgAECgQJBAAAAA==.',
Ta='Tavr:BAAALgADCgEJAQAAAA==.',
To='Topgd:BAAALgAECgEJAgAAAA==.',
Ur='Urnotprepare:BAAALgAECgYJCgAAAA==.',
Wa='Waynenny:BAABLgAFFH8GAAIHAAQJlhlPGABpAQAHAAQJlhlPGABpAQAAAA==.',
Ye='Yeungg:BAAALgADCgcJDAAAAA==.',
Yy='Yyeung:BAABLgAFFH8JAAIIAAQJOx4iAwAgAQAIAAQJOx4iAwAgAQAAAA==.Yyf:BAAALgAECgcJDQAAAA==.',
Ze='Zenless:BAAALgADCgUJBQAAAA==.',
['一会']='一会儿叭:BAAALgAFFAIJBAAAAA==.',
['一大']='一大波武僧:BAAALgAFFAEJAQAAAA==.',
['一秋']='一秋剑月:BAAALgADCgIJAgAAAA==.',
['七个']='七个小妹子:BAAALgADCgYJBgAAAA==.',
['三小']='三小鱼:BAAALgAECgEJAQABLgAFFAQJAwACAAAAAA==.',
['三百']='三百清溪:BAAALgAECgYJCAAAAA==.',
['三色']='三色猫丶:BAAALgAECgcJCAAAAA==.',
['三边']='三边总督小汪:BAAALgAECgcJEAAAAA==.',
['不劝']='不劝:BAAALgADCgYJBgAAAA==.',
['不想']='不想玩猫猫:BAAALgAECgcJEgAAAA==.',
['不要']='不要刷了:BAAALgADCgEJAQAAAA==.',
['丑憨']='丑憨憨:BAAALgAECgEJAQAAAA==.',
['专栋']='专栋图腾:BAAALgAECgYJDwAAAA==.',
['丣夛']='丣夛:BAAALgAECgkJBwAAAA==.',
['丨小']='丨小丶樂丨:BAAALgAECgYJBgAAAA==.',
['丨航']='丨航丶宝丨:BAAALgADCgEJAQAAAA==.',
['丶世']='丶世道丶:BAACLgAFFH8HAAIJAAIJzwbLBQBXAAAJAAIJzwbLBQBXAAAuAAQKfxQAAwkACAmZD/gTADABAAkACAneDfgTADABAAUAAwlkD/kqAG8AAAAA.',
['丶入']='丶入夏:BAAALgAECgEJAQAAAA==.',
['丶刘']='丶刘亦菲:BAAALgAECgYJBwAAAA==.',
['丶小']='丶小怪丶兽:BAAALgAECgUJBQAAAA==.丶小明:BAAALgAFFAEJAQAAAA==.',
['丶有']='丶有容:BAAALgAECgEJAQABLgAFFAEJAQACAAAAAA==.',
['丶欲']='丶欲丶:BAAALgAECgcJEwAAAA==.',
['丶熊']='丶熊大:BAAALgAECgUJBQAAAA==.',
['丶若']='丶若曦:BAAALgAECgkJAwAAAA==.',
['丶野']='丶野兽:BAAALgAECgMJAwAAAA==.',
['丶雷']='丶雷诺:BAAALgAECgUJBAAAAA==.',
['主不']='主不在乎:BAAALgAECgcJBwAAAA==.',
['丽娜']='丽娜:BAAALgAECgUJBQAAAA==.',
['丿柒']='丿柒囍丶:BAAALgAECgEJAQAAAA==.',
['乌鸦']='乌鸦坐飛机:BAAALgAECgcJCwAAAA==.',
['乖丿']='乖丿咖喱给给:BAAALgAECgYJBgAAAA==.',
['九晟']='九晟丶:BAAALgAECgcJDAAAAA==.',
['乳胶']='乳胶:BAAALgADCgYJBgAAAA==.',
['二街']='二街堂红丸:BAAALgAFFAEJAgABLgAFFAIJBwAKAIsYAA==.',
['云图']='云图电瓶猎手:BAAALgAECgUJBQAAAA==.',
['云夢']='云夢彼端:BAAALgAECgYJBwAAAA==.',
['五道']='五道口王羽毛:BAAALgAECgYJCAAAAA==.',
['人生']='人生如棋:BAAALgAECgMJAwAAAA==.',
['人间']='人间嘴遁炮:BAAALgAECgEJAQAAAA==.',
['今晚']='今晚不睡觉:BAAALgADCgUJBQAAAA==.',
['以德']='以德服人熊霸:BAAALgAECgEJAQABLgAFFAEJAQACAAAAAA==.',
['伊尔']='伊尔森:BAAALgAECgcJBwAAAA==.',
['伊恩']='伊恩:BAAALgAECgkJCQAAAA==.',
['伊琏']='伊琏:BAAALgADCgcJBwAAAA==.',
['伊芙']='伊芙特莉兰祀:BAABLgAFFH8IAAILAAMJpw0+CQDNAAALAAMJpw0+CQDNAAAAAA==.',
['会元']='会元:BAAALgADCgEJAQAAAA==.',
['但偏']='但偏偏雨渐渐:BAABLgAECn8UAAMMAAYJlxTVHwCVAQAMAAYJlxTVHwCVAQANAAYJQxvACwA2AQAAAA==.',
['何晶']='何晶莹:BAAALgAECgcJDQAAAA==.',
['余霞']='余霞成绮:BAAALgAECgUJCAAAAA==.',
['你个']='你个菠萝渣渣:BAAALgADCgEJAQAAAA==.',
['你丫']='你丫上头啦:BAAALgADCgEJAQAAAA==.',
['你可']='你可能不信:BAAALgAECgYJBgAAAA==.',
['你的']='你的微笑:BAAALgADCgUJBQAAAA==.',
['你看']='你看我大不大:BAAALgAECgYJCwAAAA==.',
['倾冥']='倾冥绝恋:BAAALgAECgEJAQAAAA==.',
['偏偏']='偏偏丨雨渐渐:BAABLgAFFH8GAAIKAAQJzgH6JAABAQAKAAQJzgH6JAABAQAAAA==.',
['傲丨']='傲丨然穿越:BAABLgAECn8UAAIHAAkJsRjLMgCnAgAHAAkJsRjLMgCnAgAAAA==.',
['傲娇']='傲娇的炙心:BAABLgAECn8aAAIOAAcJOCTLCwDjAgAOAAcJOCTLCwDjAgAAAA==.',
['光辉']='光辉杀戮:BAAALgAECgMJAwAAAA==.',
['克拉']='克拉拉:BAAALgAECgEJAQABLgAECgYJCQACAAAAAA==.',
['全服']='全服人的爸爸:BAAALgAECgMJAwAAAA==.',
['全民']='全民小抄:BAAALgADCgYJBgAAAA==.',
['冬天']='冬天冷夏天热:BAAALgADCgEJAQAAAA==.',
['冰封']='冰封的小动物:BAAALgADCgMJAwAAAA==.',
['冰法']='冰法:BAAALgAECgEJAQAAAA==.',
['冲出']='冲出非洲:BAABLgAFFH8LAAMPAAUJJyE/CgAlAQAPAAQJiSQ/CgAlAQAQAAEJAhdjBABcAAAAAA==.',
['冲锋']='冲锋释放大王:BAAALgAECgEJAQAAAA==.',
['决绝']='决绝的亚希:BAAALgADCgEJAgAAAA==.',
['凌沐']='凌沐沐:BAAALgAECgkJCwAAAA==.',
['凑琦']='凑琦纱夏:BAAALgAFFAEJAgAAAA==.',
['凡丶']='凡丶人丶:BAAALgAECgQJBgAAAA==.',
['凯尔']='凯尔苏斯逐曰:BAAALgADCgIJAgAAAA==.',
['凯迪']='凯迪拉客丶:BAAALgADCgkJCQAAAA==.',
['凹凸']='凹凸瞒小怪兽:BAAALgAECgYJDAAAAA==.',
['刀虹']='刀虹醉银蟾:BAAALgAFFAEJAQAAAA==.',
['初戀']='初戀:BAAALgAFFAEJAQAAAA==.',
['别拿']='别拿奶嘴逗澄:BAAALgADCgcJBwAAAA==.',
['剑心']='剑心犹在丶:BAABLgAECn8mAAIRAAgJCSIvEAD8AgARAAgJCSIvEAD8AgAAAA==.',
['劍少']='劍少:BAAALgAECgYJBgAAAA==.',
['加加']='加加光光:BAAALgAECgYJBgAAAA==.',
['动物']='动物园馆长:BAAALgAECgUJBQAAAA==.',
['劳资']='劳资蜀道山:BAAALgAECgcJCgAAAA==.',
['北原']='北原千纱:BAAALgAFFAIJAwAAAA==.',
['北望']='北望射天狼:BAAALgAECgQJBAAAAA==.',
['千矢']='千矢:BAAALgAECgIJBAAAAA==.',
['千罅']='千罅鸢:BAAALgAECgQJBQAAAA==.',
['半夜']='半夜不睡觉:BAAALgAECgIJAwAAAA==.',
['半糖']='半糖冰沙:BAAALgAECgEJAQABLgAFFAIJAwACAAAAAA==.',
['卖萌']='卖萌的小萌萌:BAAALgAECgEJAQAAAA==.',
['卖钕']='卖钕孩的火柴:BAAALgAFFAIJAgAAAA==.',
['原谅']='原谅色喜欢吗:BAAALgAECgYJBgAAAA==.',
['发糖']='发糖:BAACLgAFFH8JAAIPAAQJhB6FCQAuAQAPAAQJhB6FCQAuAQAuAAQKfxkAAg8ACAnhHyQdAKcCAA8ACAnhHyQdAKcCAAAA.',
['变老']='变老得大二:BAAALgAECgYJCAAAAA==.',
['口里']='口里观:BAAALgAECgQJBQAAAA==.',
['另外']='另外一半:BAAALgAECgMJBAAAAA==.',
['只需']='只需要你微笑:BAAALgADCgMJAQAAAA==.',
['可可']='可可扣课:BAAALgAECgUJBgAAAA==.',
['各种']='各种呆傻萌:BAAALgAECgMJBAAAAA==.',
['吊龙']='吊龙:BAAALgAECgcJCwAAAA==.',
['吴阿']='吴阿蛮:BAAALgADCgYJBgAAAA==.',
['吼哥']='吼哥:BAAALgADCgMJAwAAAA==.',
['呂归']='呂归尘:BAAALgAECgYJBgAAAA==.',
['呆萌']='呆萌女猎手:BAAALgAECggJDgABLgAFFAUJDAAPACYTAA==.',
['咕德']='咕德咕德:BAABLgAECn8VAAQLAAcJfw+TUgBcAQALAAcJfw+TUgBcAQASAAYJLAl8TwDqAAAJAAMJFATBLQA/AAAAAA==.',
['咩酱']='咩酱:BAAALgAECgUJBQAAAA==.',
['哀木']='哀木涕的愤怒:BAAALgADCgYJAwAAAA==.',
['哈哇']='哈哇哈:BAAALgAECgMJAwAAAA==.',
['哎哟']='哎哟薇:BAAALgAECgQJCAAAAA==.',
['哥哥']='哥哥比我甜:BAAALgAFFAEJAgAAAA==.',
['唐伯']='唐伯虎点秋香:BAAALgAECggJCAAAAA==.',
['啊啦']='啊啦咧咧:BAAALgAECgEJAQAAAA==.',
['啊大']='啊大脑在颤动:BAAALgAECgcJBwABLgAFFAUJBQATAKQVAA==.',
['喔莫']='喔莫喔莫:BAAALgAFFAIJAgAAAA==.',
['喝水']='喝水长肉:BAAALgAFFAEJAQAAAA==.',
['喵芈']='喵芈:BAAALgAECgMJAwAAAA==.',
['喵龙']='喵龙梦幻桑:BAAALgAECgcJDAAAAA==.',
['嘬一']='嘬一口:BAAALgAECgYJBgAAAA==.',
['嘲讽']='嘲讽的脸:BAAALgAECgUJCwAAAA==.',
['噬魂']='噬魂:BAAALgAECgYJBwAAAA==.',
['四运']='四运大经理:BAAALgAECgYJDQAAAA==.',
['图灵']='图灵:BAAALgADCgEJAQAAAA==.',
['圆無']='圆無双:BAAALgAECgMJAwABLgAECgYJBwACAAAAAA==.',
['圣光']='圣光之女:BAAALgADCgQJBwAAAA==.圣光哈基米:BAAALgADCgEJAQAAAA==.圣光托儿:BAAALgAECgEJAQAAAA==.圣光照妖:BAAALgADCgYJBgAAAA==.',
['圣艾']='圣艾米露:BAABLgAECn8UAAMMAAYJURvoGQDKAQAMAAYJ1BroGQDKAQAUAAYJhA9wPwA7AQAAAA==.',
['地壳']='地壳:BAAALgAFFAIJBAAAAA==.',
['堕落']='堕落:BAAALgAECgIJAgAAAA==.堕落的骑士:BAAALgAECgUJBQAAAA==.',
['塔布']='塔布里斯丶薰:BAAALgAECgQJBQAAAA==.',
['塞巴']='塞巴斯蒂安丶:BAAALgADCgUJBgAAAA==.',
['复仇']='复仇的回忆:BAAALgADCgUJBQAAAA==.',
['夏丶']='夏丶初:BAAALgAECgEJAQAAAA==.',
['夏姬']='夏姬九菜:BAAALgADCgEJAQAAAA==.',
['夕阳']='夕阳流星:BAABLgAFFH8FAAIKAAIJ+SYaLADqAAAKAAIJ+SYaLADqAAAAAA==.',
['夜之']='夜之哪吒:BAAALgAFFAQJBAAAAA==.',
['夜夜']='夜夜岚珊:BAAALgAECgEJAQAAAA==.夜夜岚衫:BAAALgADCgEJAwAAAA==.',
['夜微']='夜微微凉:BAAALgAECgQJCQAAAA==.',
['大哥']='大哥哥来了:BAAALgAECggJEwAAAA==.',
['大宝']='大宝捡:BAAALgADCgYJBgAAAA==.',
['大窝']='大窝瓜:BAABLgAFFH8GAAIKAAIJcRaMGgCcAAAKAAIJcRaMGgCcAAAAAA==.大窝瓜脸:BAAALgAECgEJAQABLgAFFAIJBgAKAHEWAA==.',
['天地']='天地大冲撞:BAAALgAFFAEJAQAAAA==.',
['天才']='天才小喵喵:BAABLgAFFH8GAAIKAAMJ8hESKQD1AAAKAAMJ8hESKQD1AAAAAA==.',
['太寿']='太寿鸠毛:BAAALgAFFAEJAQAAAA==.',
['太爷']='太爷爷来了:BAAALgAECgEJAQAAAA==.',
['失心']='失心疯:BAAALgADCgYJBgAAAA==.',
['头上']='头上有大角:BAAALgAECgIJAgAAAA==.',
['奇行']='奇行种绅士:BAABLgAECn8WAAIDAAgJIBqtOgA5AgADAAgJIBqtOgA5AgAAAA==.',
['奈茶']='奈茶的雪:BAAALgAECgMJAwAAAA==.',
['奥术']='奥术冲击流:BAAALgAECgMJAwAAAA==.',
['奴婢']='奴婢威霸天:BAAALgAECgcJEAABLgAFFAUJCwAKAIwTAA==.',
['奶油']='奶油中生:BAAALgAECgQJAQAAAA==.',
['奶茶']='奶茶猫:BAAALgAFFAIJBAAAAA==.',
['她的']='她的小尾巴:BAAALgAECgEJAQAAAA==.',
['奼紫']='奼紫嫣红:BAAALgAECgUJBQAAAA==.',
['好运']='好运眷顾潮巴:BAAALgAECgkJBwAAAA==.',
['妇女']='妇女偶像托尼:BAAALgAECgYJCAAAAA==.',
['姐姐']='姐姐:BAAALgAECgMJAwAAAA==.',
['婳心']='婳心:BAAALgADCgcJDAAAAA==.',
['孀之']='孀之哀殇:BAABLgAECn8cAAIKAAkJAx4wHQDQAgAKAAkJAx4wHQDQAgAAAA==.',
['子跬']='子跬:BAAALgAECgUJBQAAAA==.',
['孤独']='孤独亦无悔:BAAALgAECgMJBAAAAA==.',
['学你']='学你玩:BAAALgADCgQJBAAAAA==.',
['守护']='守护丶甜心:BAAALgAECgYJBgAAAA==.',
['安西']='安西香二号:BAABLgAFFH8FAAIRAAQJ9ARgGAAMAQARAAQJ9ARgGAAMAQABLgAFFAYJAwACAAAAAA==.安西香半号:BAAALgAFFAYJAwAAAA==.',
['定海']='定海桥阿鹊兮:BAAALgAECgQJBAAAAA==.',
['宜兴']='宜兴薛之谦:BAABLgAFFH8FAAIVAAUJehMAAAAAAAAOAAUJehMAAAAAAAAAAA==.',
['宝乖']='宝乖:BAAALgADCgEJAQAAAA==.',
['家园']='家园:BAAALgAECgIJAgAAAA==.',
['寒意']='寒意:BAAALgAECgEJAQAAAA==.',
['封彪']='封彪:BAAALgAECgEJAQAAAA==.',
['射箭']='射箭不用钱:BAABLgAECn8cAAIWAAcJ+CCqBQCvAgAWAAcJ+CCqBQCvAgAAAA==.',
['小丶']='小丶樂:BAAALgAECgcJBwAAAA==.',
['小号']='小号怎么玩:BAAALgADCgMJAwAAAA==.',
['小挥']='小挥挥:BAAALgAECgcJDQAAAA==.',
['小泽']='小泽:BAAALgAECgMJAwAAAA==.',
['小湊']='小湊四叶丶:BAAALgAECgkJCQAAAA==.',
['小煤']='小煤毬:BAAALgADCgEJAQABLgAECgEJAQACAAAAAA==.',
['小米']='小米加步槍:BAAALgAECgEJAQAAAA==.',
['小罡']='小罡嘟:BAAALgADCgYJBgAAAA==.',
['小许']='小许:BAAALgAFFAEJAQAAAA==.',
['小锅']='小锅凉粉:BAAALgAECgcJCAAAAA==.',
['小阿']='小阿冒:BAAALgAECgUJBQAAAA==.小阿喵:BAAALgAECgEJAQAAAA==.小阿瑁:BAAALgAECgcJCgAAAA==.',
['尛姊']='尛姊丶霸占伱:BAAALgAECgEJAgAAAA==.',
['尛手']='尛手亂摸丶荭:BAAALgAECgEJAgAAAA==.',
['尛白']='尛白:BAAALgAFFAIJAgAAAA==.',
['岁月']='岁月灬聖:BAAALgAECgIJAwAAAA==.',
['岛爷']='岛爷:BAAALgAECgQJBwAAAA==.',
['岸边']='岸边露伴:BAAALgAECgcJDwAAAA==.',
['布拉']='布拉德皮特:BAAALgAECgYJDQAAAA==.',
['布鲁']='布鲁克:BAAALgADCgMJAwAAAA==.',
['弓少']='弓少爺:BAAALgADCgMJAwAAAA==.',
['弗朗']='弗朗斯西:BAAALgAECgIJAwAAAA==.',
['张黍']='张黍梦:BAABLgAFFH8MAAIGAAQJMRZrBABOAQAGAAQJMRZrBABOAQAAAA==.',
['弱弱']='弱弱的:BAAALgAFFAQJBAAAAA==.',
['强尼']='强尼:BAAALgAECgIJBAAAAA==.',
['彩色']='彩色酱:BAABLgAFFH8GAAIXAAMJlRagDQD+AAAXAAMJlRagDQD+AAAAAA==.',
['徒醉']='徒醉了清风:BAAALgAECgQJCAAAAA==.',
['微风']='微风徐徐:BAAALgADCggJCwAAAA==.',
['德不']='德不尝十:BAAALgADCgUJBQAAAA==.',
['必射']='必射客:BAAALgAECgYJBgAAAA==.',
['快灬']='快灬到碗里来:BAAALgAECgUJBAAAAA==.',
['念珩']='念珩:BAAALgADCgQJBAAAAA==.',
['怎么']='怎么变都有型:BAAALgADCgEJAQAAAA==.',
['怒苍']='怒苍山:BAAALgAECgMJAwAAAA==.',
['性感']='性感丶山羊胡:BAABLgAECn8aAAIYAAcJfQqSCQDqAAAYAAcJfQqSCQDqAAAAAA==.性感的驼背爷:BAACLgAFFH8FAAIHAAIJ+xCuPACyAAAHAAIJ+xCuPACyAAAuAAQKfxkAAgcABwneGNdeAB4CAAcABwneGNdeAB4CAAAA.',
['怨之']='怨之妇:BAAALgAECgIJAgAAAA==.',
['恐山']='恐山丶安娜:BAAALgADCgQJBAAAAA==.',
['悲伤']='悲伤的小鱼干:BAAALgAECgIJAgAAAA==.',
['意丶']='意丶寒:BAAALgAECgYJBgAAAA==.',
['愚人']='愚人:BAAALgAECgIJAgAAAA==.',
['愤怒']='愤怒的呆西:BAAALgAECgEJAQAAAA==.',
['懵懂']='懵懂少年:BAAALgAECgMJAwAAAA==.',
['我叫']='我叫锿猛体:BAAALgAECgMJAwAAAA==.',
['我寻']='我寻思能行:BAAALgAFFAEJAQAAAA==.',
['我心']='我心的花色:BAAALgAECgQJBAAAAA==.',
['我是']='我是神马叔:BAAALgAECgUJBwAAAA==.我是读书人:BAAALgAFFAEJAgAAAA==.',
['我爱']='我爱喝热水:BAAALgAECgMJAwAAAA==.我爱喝熱水:BAAALgADCgcJDAAAAA==.我爱我老婆:BAAALgAECgEJAQAAAA==.',
['我要']='我要天下无敌:BAAALgAECgUJBgAAAA==.我要验牌:BAAALgAECgUJBQABLgAFFAEJAQACAAAAAA==.',
['戨夲']='戨夲妎畊:BAAALgADCgIJAgAAAA==.',
['手发']='手发烫:BAAALgAECgYJAQAAAA==.',
['托尼']='托尼丶斯塔克:BAAALgADCgEJAQAAAA==.',
['执爱']='执爱丶:BAAALgADCgcJCgAAAA==.',
['抑扬']='抑扬千禧丶:BAAALgAFFAMJAwAAAA==.',
['抓不']='抓不到的猫:BAAALgADCgEJAQAAAA==.',
['抖怂']='抖怂:BAAALgADCgYJBgAAAA==.',
['拒绝']='拒绝杨幂七次:BAABLgAFFH8KAAMZAAYJTxaDAgDSAQAZAAUJnhqDAgDSAQAIAAEJFwXgCwBTAAAAAA==.拒绝杨幂五次:BAABLgAFFH8IAAIZAAUJ1hVkBAAdAQAZAAUJ1hVkBAAdAQAAAA==.拒绝杨幂六次:BAACLgAFFH8FAAIZAAUJxBZnAwC+AQAZAAUJxBZnAwC+AQAuAAQKfxcAAhkACQm1FPwSALcCABkACQm1FPwSALcCAAAA.',
['拯救']='拯救单身少女:BAAALgADCgYJCwAAAA==.',
['指尖']='指尖戒律:BAABLgAECn8VAAINAAYJeRV0CgBJAQANAAYJeRV0CgBJAQAAAA==.',
['探长']='探长中:BAAALgAECgQJBQAAAA==.探长华:BAAALgAFFAEJAQAAAA==.',
['放心']='放心小王:BAAALgAECgEJAQABLgAECgEJAgACAAAAAA==.',
['放过']='放过自己:BAAALgAECgIJAgAAAA==.',
['斗鬼']='斗鬼泣:BAAALgAFFAQJBAAAAA==.',
['新欢']='新欢:BAAALgAECgEJAQAAAA==.',
['施华']='施华蔻:BAAALgAFFAEJAQAAAA==.',
['无尽']='无尽丶空虚:BAAALgADCgMJAwAAAA==.',
['无心']='无心戰:BAABLgAFFH8GAAIZAAMJVxO4BQAHAQAZAAMJVxO4BQAHAQAAAA==.',
['无泪']='无泪止涧:BAAALgAFFAEJAQAAAA==.',
['无絕']='无絕:BAAALgAECgQJBAAAAA==.',
['无限']='无限郁闷:BAAALgAECgcJBwAAAA==.',
['日落']='日落大道:BAAALgADCgEJAQAAAA==.',
['星月']='星月:BAAALgAECgEJAQAAAA==.',
['星河']='星河转:BAAALgAECgQJBQAAAA==.',
['星泪']='星泪印痕:BAAALgAECgYJDAABLgAFFAMJCQAaAN0XAA==.',
['星辰']='星辰:BAAALgADCgcJBwAAAA==.',
['晨乂']='晨乂曦:BAAALgAFFAEJAQAAAA==.',
['晨星']='晨星:BAAALgAFFAMJBAAAAA==.',
['普蕾']='普蕾尔:BAAALgAECgQJBAAAAA==.',
['暗夜']='暗夜瞳:BAAALgAECgIJAQAAAA==.',
['暗影']='暗影土:BAABLgAFFH8IAAIZAAQJ0R+zBQCWAQAZAAQJ0R+zBQCWAQAAAA==.',
['暗黑']='暗黑林志玲:BAAALgAECgEJAQAAAA==.',
['最后']='最后的血统:BAAALgAECgIJAgAAAA==.',
['月下']='月下灬:BAAALgAECgUJCAAAAA==.',
['月亮']='月亮贝:BAAALgAECgUJCgAAAA==.',
['月夜']='月夜幽梦:BAAALgADCgQJBAAAAA==.',
['有容']='有容丶:BAAALgADCgcJDAABLgAFFAEJAQACAAAAAA==.',
['机智']='机智的果子狸:BAABLgAFFH8IAAIbAAMJlhj6BwDsAAAbAAMJlhj6BwDsAAAAAA==.',
['杉木']='杉木:BAAALgAECgUJBQAAAA==.',
['来追']='来追老子呀:BAAALgADCgUJBQAAAA==.',
['枫桦']='枫桦丶:BAAALgAECgIJBAAAAA==.',
['架不']='架不住臉黑:BAAALgADCgEJAQAAAA==.',
['柠檬']='柠檬可乐碎冰:BAAALgAECgEJAQAAAA==.',
['栞宝']='栞宝:BAAALgAFFAMJAwAAAA==.',
['格里']='格里恩奶萨:BAAALgAECgEJAgAAAA==.',
['桃子']='桃子不能偷:BAAALgAECgYJCgAAAA==.',
['梅林']='梅林低语:BAAALgADCgEJAQAAAA==.',
['梨花']='梨花换酒丶:BAAALgAECgYJDQAAAA==.',
['棒棒']='棒棒术:BAAALgAECgEJAQABLgAFFAIJCAAOAFsiAA==.棒棒猎:BAABLgAFFH8IAAIOAAIJWyL9DgDSAAAOAAIJWyL9DgDSAAAAAA==.棒棒象:BAAALgAECgEJAQAAAA==.',
['樊凡']='樊凡:BAAALgADCgEJAQAAAA==.',
['樊爷']='樊爷:BAAALgAECgMJAwAAAA==.',
['樹妖']='樹妖:BAAALgAECgEJAQAAAA==.',
['橙予']='橙予:BAAALgAECgEJAQAAAA==.',
['欢喜']='欢喜坨:BAAALgAECgEJAQAAAA==.',
['欣想']='欣想柿橙:BAAALgAECgQJBAAAAA==.',
['欧润']='欧润橘:BAAALgAECgIJBAAAAA==.',
['正义']='正义传说:BAAALgAECgIJAgAAAA==.',
['死亡']='死亡凹骑士:BAAALgAECgYJBgAAAA==.',
['永雏']='永雏塔菲:BAACLgAFFH8KAAIDAAUJkxa6BgCDAQADAAUJkxa6BgCDAQAuAAQKfxkAAgMACAnQIL4hAKMCAAMACAnQIL4hAKMCAAEuAAUUBQkMAA8AJhMA.',
['汉口']='汉口二零七七:BAAALgAECgUJBQAAAA==.',
['江东']='江东杰瑞:BAAALgAFFAQJBAABLgAFFAUJCAAXAAQXAA==.',
['江南']='江南烟雨留情:BAAALgAECgEJAgAAAA==.',
['沐诗']='沐诗:BAAALgADCgEJAQAAAA==.',
['沒哊']='沒哊氺的魚:BAAALgAECgEJAQAAAA==.',
['没有']='没有万一:BAAALgAECgYJEwAAAA==.',
['河北']='河北彩花丶:BAAALgAECgcJDQAAAA==.',
['波克']='波克斯基:BAAALgADCgEJAQAAAA==.',
['波波']='波波奶茶:BAAALgAECgEJAQAAAA==.',
['洛姬']='洛姬娅:BAAALgAECgYJBwAAAA==.',
['洛水']='洛水丶慕栀初:BAAALgAECgcJCQAAAA==.',
['洛秋']='洛秋凉:BAAALgAECgkJCQAAAA==.',
['浅夏']='浅夏诗韵:BAAALgADCgIJAgAAAA==.',
['海飞']='海飞丝:BAAALgAECgUJBgAAAA==.',
['涛将']='涛将军:BAAALgAECgIJAgAAAA==.',
['深感']='深感抱歉:BAAALgADCgEJAQABLgAECgEJAQACAAAAAA==.',
['游学']='游学者皮皮橙:BAABLgAECn8mAAMLAAgJzxuPCADXAQALAAgJzxuPCADXAQASAAcJ2RMbLgCTAQAAAA==.',
['湖蓝']='湖蓝:BAAALgAECgEJBAAAAA==.',
['漏网']='漏网之鱼:BAAALgAECgEJAQAAAA==.',
['漠丨']='漠丨简歌:BAACLgAFFH8FAAIPAAQJVA8CEAD0AAAPAAQJVA8CEAD0AAAuAAQKfxwAAg8ABwnEE91WAMMBAA8ABwnEE91WAMMBAAAA.',
['漩涡']='漩涡:BAAALgAECgIJAgAAAA==.',
['瀧尒']='瀧尒柒:BAAALgAECgkJEAABLgAFFAUJEAAaAC8lAA==.瀧尒沬:BAAALgAFFAQJBAAAAA==.',
['灬味']='灬味精灬:BAAALgAECgYJAQAAAA==.',
['灰荼']='灰荼靡:BAAALgAECgEJAQAAAA==.',
['炎妃']='炎妃龙:BAABLgAECn8XAAIBAAcJLxhBFQD2AQABAAcJLxhBFQD2AQAAAA==.',
['炑空']='炑空一切:BAAALgADCgEJAQAAAA==.',
['炙心']='炙心:BAAALgAECgQJBAAAAA==.',
['烈焰']='烈焰狐:BAAALgAECgEJAQAAAA==.',
['煊煊']='煊煊红:BAAALgAECgIJAgAAAA==.',
['煙雨']='煙雨沁夢:BAAALgAECgEJAQAAAA==.',
['熊转']='熊转圈圈:BAAALgAECgEJAgAAAA==.',
['爱上']='爱上杨幂一次:BAAALgAFFAcJAQAAAA==.爱上杨幂八次:BAAALgAFFAIJAgAAAA==.爱上杨幂六次:BAAALgAFFAMJAgAAAA==.',
['爱吃']='爱吃榴莲:BAAALgADCgEJAQAAAA==.爱吃牛右:BAAALgAECgYJDQAAAA==.',
['爱意']='爱意随钟起:BAAALgADCgYJBgAAAA==.',
['牛春']='牛春晖:BAAALgAECgQJBAAAAA==.',
['牛牛']='牛牛坦克来啦:BAAALgAECgYJCQAAAA==.',
['牛犇']='牛犇牜:BAAALgADCgMJAwAAAA==.',
['牛筱']='牛筱牛:BAAALgAECgcJCQAAAA==.',
['牧场']='牧场物语:BAAALgAECgYJBgAAAA==.',
['牧壶']='牧壶:BAAALgAECgQJBQAAAA==.',
['犤潁']='犤潁:BAAALgAECgQJBAAAAA==.',
['狂野']='狂野:BAAALgAECgYJBwAAAA==.',
['狂飙']='狂飙的蜗牛:BAAALgAECgkJCQAAAA==.',
['狗撒']='狗撒:BAAALgAECgIJAgAAAA==.',
['猇亭']='猇亭带投大哥:BAACLgAFFH8HAAIOAAIJ2Rw3FACyAAAOAAIJ2Rw3FACyAAAuAAQKfxkAAg4ABwl4HI4OAJABAA4ABwl4HI4OAJABAAAA.',
['王叔']='王叔叔:BAAALgAFFAEJAgAAAA==.',
['王德']='王德发啊:BAAALgADCgUJBQAAAA==.',
['王饺']='王饺子舒心:BAAALgADCgYJBgAAAA==.',
['玖刃']='玖刃的逆鳞:BAAALgADCgEJAQAAAA==.',
['瑛太']='瑛太酱:BAAALgAECgEJAQAAAA==.',
['瑝珑']='瑝珑:BAAALgADCgEJAQAAAA==.',
['瑶玲']='瑶玲:BAAALgAECgQJBAAAAA==.',
['甄茉']='甄茉:BAAALgAECgYJBgAAAA==.',
['甜甜']='甜甜小思:BAAALgAECgQJBAAAAA==.',
['用飘']='用飘柔才自信:BAACLgAFFH8MAAIHAAUJlSKdBQALAgAHAAUJlSKdBQALAgAuAAQKfygAAgcACAlSJjUJAH0DAAcACAlSJjUJAH0DAAAA.',
['甩脑']='甩脑壳:BAAALgADCgYJBgAAAA==.',
['男妈']='男妈妈:BAAALgAECgEJAgAAAA==.',
['畏缩']='畏缩是我的错:BAAALgAECgMJAwAAAA==.',
['痴顽']='痴顽:BAAALgAECgYJCQAAAA==.',
['白发']='白发照清水:BAAALgADCgMJAwAAAA==.',
['盗国']='盗国众:BAAALgAECgcJAgAAAA==.',
['目瞊']='目瞊人:BAAALgAECgYJCgAAAA==.',
['瞎子']='瞎子看报:BAAALgADCgUJBQAAAA==.',
['破面']='破面绅士:BAAALgAECgEJAgAAAA==.',
['硬奶']='硬奶:BAAALgADCgIJAgAAAA==.',
['确认']='确认过眼神:BAAALgAECgEJAQAAAA==.',
['神女']='神女应无恙:BAAALgAECgQJCAAAAA==.',
['神灬']='神灬影:BAAALgAFFAIJAgAAAA==.',
['神里']='神里绫人的狗:BAAALgADCgUJBQAAAA==.',
['祭仙']='祭仙圣:BAAALgADCgUJBQAAAA==.',
['祭兮']='祭兮夜:BAABLgAFFH8IAAIHAAQJLw3AIABCAQAHAAQJLw3AIABCAQAAAA==.',
['秋枫']='秋枫摇落叶:BAAALgAECgkJCQAAAA==.',
['笙止']='笙止:BAAALgAFFAEJAQAAAA==.',
['筱潇']='筱潇:BAAALgAECgEJAQAAAA==.',
['篾天']='篾天骸:BAACLgAFFH8FAAMZAAMJ7hTLFgCuAAAZAAIJhxbLFgCuAAAIAAEJuxEAAAAAAAAuAAQKfxUAAwgABwm5HVoJABgCAAgABwm5HVoJABgCABkABwlQClROAG0BAAAA.',
['米悠']='米悠:BAAALgADCgEJAQAAAA==.',
['糟溜']='糟溜鱼片:BAAALgAECgUJCgAAAA==.',
['紅蓮']='紅蓮業火:BAAALgAECgUJBQAAAA==.',
['紫藕']='紫藕香残:BAABLgAFFH8FAAIDAAQJqx+WBQCWAQADAAQJqx+WBQCWAQABLgAFFAcJBgAcANsXAA==.',
['红影']='红影:BAAALgAECgMJAwAAAA==.',
['红色']='红色电冰箱:BAAALgAECggJEAAAAA==.',
['绊城']='绊城烟沙丶:BAAALgAECgEJAwAAAA==.',
['绝不']='绝不能倒下:BAAALgAFFAIJBAABLgAFFAUJBAACAAAAAA==.',
['罗永']='罗永昊:BAAALgAECgIJBQAAAA==.',
['罪歌']='罪歌之母:BAAALgAECgEJAgAAAA==.',
['美瞳']='美瞳灼坏噜:BAAALgADCgcJBwAAAA==.',
['老汉']='老汉口六六:BAAALgAECgMJAgAAAA==.',
['聪明']='聪明的小妍妍:BAAALgAECgYJDAAAAA==.',
['肉酱']='肉酱拌面:BAABLgAECn8VAAIKAAgJRhIHYADTAQAKAAgJRhIHYADTAQAAAA==.',
['胖哒']='胖哒来啦:BAAALgAFFAUJAQAAAA==.',
['胖圆']='胖圆二:BAAALgAECgcJAQAAAA==.',
['胡汉']='胡汉三来了:BAAALgAECgcJBwAAAA==.',
['自己']='自己人:BAAALgAECgQJBAAAAA==.',
['至黑']='至黑之夜:BAAALgAECgQJBAAAAA==.',
['舒心']='舒心饺子王:BAAALgAFFAIJAgAAAA==.',
['色彩']='色彩哥:BAACLgAFFH8PAAIdAAYJZQteAwDBAQAdAAYJZQteAwDBAQAuAAQKfxkAAh0ACQmzHeINAHgCAB0ACQmzHeINAHgCAAAA.',
['艾莎']='艾莎:BAAALgAFFAIJBAAAAA==.',
['芙莉']='芙莉莲风歌:BAAALgAECgcJBwAAAA==.',
['花京']='花京院:BAAALgAFFAEJAQAAAA==.',
['花夜']='花夜:BAAALgAFFAIJAwAAAA==.',
['花漾']='花漾凤:BAAALgAECgEJAQAAAA==.',
['花牛']='花牛牛:BAAALgAECgEJAQAAAA==.',
['花老']='花老师:BAAALgAECgEJAQAAAA==.',
['花苴']='花苴苴:BAAALgAECgYJCAAAAA==.',
['花香']='花香浪子:BAAALgAECgYJDAAAAA==.',
['花骨']='花骨朵丶:BAAALgAECgMJAwAAAA==.',
['花魂']='花魂葬冷月:BAAALgAECgQJBAAAAA==.',
['药不']='药不然:BAABLgAFFH8IAAINAAQJWBz9BACCAQANAAQJWBz9BACCAQAAAA==.',
['莉克']='莉克钠里:BAAALgAFFAEJAQAAAA==.',
['莫格']='莫格莱尼:BAABLgAECn8ZAAIDAAkJyRwDFADzAgADAAkJyRwDFADzAgAAAA==.',
['菄雪']='菄雪蓮:BAACLgAFFH8MAAMPAAUJJhNcFwA1AQAPAAQJMxdcFwA1AQAQAAIJXgVxDgCXAAAuAAQKfx8AAw8ACAkwHfY2ADACAA8ACAm8G/Y2ADACABAABAlDGi4gAFEBAAAA.',
['萌哒']='萌哒哒的波纹:BAAALgAFFAEJAQAAAA==.',
['萌居']='萌居居帕帕:BAAALgAECgUJBwAAAA==.萌居居阿凯:BAAALgAFFAEJAQAAAA==.',
['萨塔']='萨塔里澳:BAAALgAFFAEJAQAAAA==.',
['萨達']='萨達穆:BAAALgADCgEJAQAAAA==.',
['萬物']='萬物皆有光:BAAALgAECgEJAQAAAA==.',
['落笔']='落笔丶云掩月:BAAALgAECgYJBgABLgAECgcJCQACAAAAAA==.',
['蓝帽']='蓝帽智美:BAAALgAECgcJBwAAAA==.',
['蓝莓']='蓝莓夹心饼:BAAALgAECgYJCQAAAA==.',
['蔡小']='蔡小小:BAAALgAECgEJAQAAAA==.',
['虎牙']='虎牙的敌尅:BAABLgAECn8mAAIKAAgJCCOiEQASAwAKAAgJCCOiEQASAwAAAA==.',
['蛮牛']='蛮牛冲钅:BAAALgAFFAEJAQAAAA==.',
['蜂蜂']='蜂蜂侠:BAAALgAECgYJCAABLgAFFAYJDgAPAPoiAA==.',
['血星']='血星玛莉:BAAALgAECgUJBQAAAA==.血星马莉:BAAALgADCgUJBQAAAA==.',
['被遗']='被遗忘丶传说:BAAALgAECgYJBgAAAA==.',
['装龙']='装龙做鸭:BAAALgAECgIJAgAAAA==.',
['裴白']='裴白菜:BAAALgAECgEJAQAAAA==.',
['见朕']='见朕骑姬:BAAALgAECgYJCQAAAA==.',
['许嗲']='许嗲:BAAALgAECgEJAQAAAA==.',
['诗羽']='诗羽:BAAALgAECgcJCAAAAA==.',
['诸葛']='诸葛亮:BAAALgAECgEJAQAAAA==.',
['诺基']='诺基德:BAAALgAECgkJEAAAAA==.',
['豆子']='豆子丷:BAAALgAECgQJBAAAAA==.',
['豆逼']='豆逼丶無敵:BAAALgADCgYJBgAAAA==.',
['豪爷']='豪爷:BAAALgAECgMJAwAAAA==.',
['財丶']='財丶神:BAAALgAECgMJBQAAAA==.',
['财巜']='财巜神:BAAALgAECgEJAgAAAA==.',
['财散']='财散人安乐:BAAALgAECgQJBAAAAA==.',
['贱贱']='贱贱惹人爱:BAAALgAECgEJAQAAAA==.',
['赵腊']='赵腊月:BAAALgAECgYJBwAAAA==.',
['超威']='超威蓝猫丶:BAAALgAECgQJBAABLgAFFAEJAQACAAAAAA==.',
['超神']='超神的炮灰:BAAALgAECgYJBwAAAA==.',
['达能']='达能高钙:BAAALgADCgUJBQAAAA==.',
['迪奥']='迪奥布兰度:BAABLgAFFH8FAAIKAAMJVBfrMQDCAAAKAAMJVBfrMQDCAAAAAA==.',
['迪阿']='迪阿布羅:BAAALgAECgUJBQABLgAFFAUJBQALAJkcAA==.',
['述迭']='述迭:BAABLgAFFH8FAAIPAAIJtRJlNgCmAAAPAAIJtRJlNgCmAAAAAA==.',
['速来']='速来救驾:BAAALgAECgYJCQAAAA==.',
['那个']='那个联盟:BAAALgADCgUJCQAAAA==.',
['邦邦']='邦邦一拳:BAAALgAECgEJAQAAAA==.',
['酒即']='酒即是空:BAAALgAECgIJAgAAAA==.酒即是空丶:BAAALgAECgUJBQAAAA==.',
['醜陋']='醜陋:BAAALgADCgQJBAAAAA==.',
['里美']='里美由利亚:BAAALgAECgcJEAAAAA==.',
['里达']='里达易欧:BAAALgADCgcJBwAAAA==.',
['铁佛']='铁佛:BAAALgAECgEJAQAAAA==.',
['银河']='银河之星星:BAAALgAFFAQJBAAAAA==.',
['锋刃']='锋刃刺骨寒:BAAALgAECgYJBgAAAA==.',
['锕浪']='锕浪:BAAALgAECgEJAgAAAA==.',
['锦鲤']='锦鲤抄:BAAALgAECgQJBQAAAA==.',
['阿乐']='阿乐:BAABLgAFFH8FAAIeAAMJvwhDEgDSAAAeAAMJvwhDEgDSAAAAAA==.',
['阿司']='阿司匹林:BAAALgAFFAIJAgAAAA==.',
['阿拉']='阿拉加哈:BAAALgAECgEJAQAAAA==.',
['阿瑞']='阿瑞斯之矛:BAAALgADCgEJAQAAAA==.',
['阿鲁']='阿鲁丶迪巴:BAAALgAECgQJBAAAAA==.',
['陈一']='陈一:BAAALgAECgYJBwABLgAECgYJEQACAAAAAA==.',
['陈啊']='陈啊嗯:BAAALgAECgYJDAABLgAECgYJEQACAAAAAA==.',
['随便']='随便玩玩咯:BAAALgAECgUJBQAAAA==.',
['随地']='随地大小变丨:BAAALgAECgEJAQAAAA==.',
['隐隐']='隐隐蓝海:BAAALgAFFAEJAgAAAA==.',
['雨鱼']='雨鱼之角:BAAALgAECgMJAwAAAA==.',
['雪夜']='雪夜风华:BAABLgAFFH8NAAMfAAQJPR97BwAXAQAfAAMJph97BwAXAQAKAAQJvB4RTgBWAAAAAA==.',
['雹子']='雹子死骑:BAAALgAECgEJAgAAAA==.',
['雾都']='雾都李知恩:BAAALgAECgIJAgAAAA==.',
['霜河']='霜河:BAAALgAECgUJBwAAAA==.',
['霜火']='霜火煎饼:BAAALgAECgcJCwAAAA==.',
['露西']='露西娅:BAAALgAECgcJCwABLgAFFAEJAQACAAAAAA==.',
['霹雳']='霹雳猫阿洛:BAACLgAFFH8JAAIeAAQJGRzhBwBIAQAeAAQJGRzhBwBIAQAuAAQKfxcAAh4ACAlRH+gOAKICAB4ACAlRH+gOAKICAAAA.',
['青丝']='青丝落凡尘:BAAALgAECgkJCQAAAA==.',
['青格']='青格乐:BAAALgADCgcJBwAAAA==.',
['青楼']='青楼剑舞:BAAALgADCgYJBgAAAA==.',
['青淮']='青淮:BAAALgAECgkJBwAAAA==.',
['顶尖']='顶尖:BAAALgAECgIJAwAAAA==.',
['颓废']='颓废之心:BAAALgADCgMJAwAAAA==.颓废夜:BAAALgADCggJCQAAAA==.',
['风中']='风中追忆:BAAALgAECgcJEgAAAA==.',
['风行']='风行者林夕:BAAALgAECgMJAwAAAA==.',
['飘丶']='飘丶落:BAAALgAECgMJBQAAAA==.',
['飞翔']='飞翔的大母猪:BAAALgAFFAEJAQAAAA==.',
['飞飞']='飞飞不是瓜皮:BAAALgAECgIJAwAAAA==.',
['饭饭']='饭饭电:BAAALgAFFAMJAwAAAA==.饭饭锅:BAAALgAECgcJBgAAAA==.',
['饺子']='饺子舒心王:BAABLgAFFH8GAAIKAAMJyxG9KAD2AAAKAAMJyxG9KAD2AAAAAA==.',
['馒头']='馒头丶:BAAALgAECgQJBwAAAA==.',
['首妒']='首妒:BAAALgAECgkJCwAAAA==.',
['鬼吹']='鬼吹燈:BAAALgAECgEJAQAAAA==.',
['魔兽']='魔兽争霸四呢:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法披风:BAAALgAFFAEJAQAAAA==.',
['鱼铁']='鱼铁锤:BAAALgAECgMJBQAAAA==.',
['鹧鹄']='鹧鹄菜丶:BAAALgAFFAEJAQAAAA==.',
['麻辣']='麻辣肾击:BAAALgAECgIJAgAAAA==.',
['黄忠']='黄忠:BAAALgADCgYJBgAAAA==.',
['黄瓜']='黄瓜表哥:BAAALgAECgYJCQAAAA==.',
['黑豆']='黑豆丷:BAAALgAECgYJBgAAAA==.黑豆朱古力:BAAALgAECgYJBgAAAA==.',
['黑锋']='黑锋寨小旋风:BAAALgADCgEJAQAAAA==.',
['黯夜']='黯夜咏叹調:BAAALgAECgcJBwAAAA==.',
['龙斯']='龙斯基迪凯:BAAALgAECgYJDAAAAA==.',
['龙村']='龙村人:BAAALgAFFAEJAQAAAA==.',
['龙豆']='龙豆丷:BAAALgAECgkJCQABLgAECgYJBgACAAAAAA==.',
['龙龙']='龙龙发:BAAALgAECgEJAQAAAA==.',
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
