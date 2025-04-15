local V2_TAG_NUMBER = 3

---Parse a single set of spec data from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileSpec
local function parseSpecData(decoder, state, lookup)
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progress = decoder.decodeInteger(state, 1)
	result.partition = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.rank = decoder.decodeInteger(state, 3)
	result.average = decoder.decodeFixedFloat(state, 1, 1)
	result.asp = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encounters = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)

		result.encounters[id] = { kills = kills, best = best }
	end
	return result
end

---Parse a binary-encoded data string into a ProviderProfile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@return ProviderProfile|nil
local function parse(decoder, content, lookup) -- luacheck: ignore 211
	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	local result = {}

	-- user data
	result.subscriber = decoder.decodeInteger(state, 1)
	-- overall data
	result.progress = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.totalKillCount = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)
	result.perSpec = {}

	local specCount = decoder.decodeInteger(state, 1)
	if specCount > 0 then
		result.anySpec = parseSpecData(decoder, state, lookup)

		for _i = 1, specCount - 1 do
			local spec = parseSpecData(decoder, state, lookup)
			table.insert(result.perSpec, spec)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)

	if hasMainCharacter then
		local main = {}
		main.spec = decoder.decodeString(state, lookup)
		main.average = decoder.decodeFixedFloat(state, 1, 1)
		main.progress = decoder.decodeInteger(state, 1)
		main.total = decoder.decodeInteger(state, 1)
		main.totalKillCount = decoder.decodeInteger(state, 2)
		main.difficulty = decoder.decodeInteger(state, 1)
		main.size = decoder.decodeInteger(state, 1)
		result.mainCharacter = main
	end

	return result
end
 local lookup = {'DeathKnight-Blood','Paladin-Protection','Unknown-Unknown','DeathKnight-Unholy','Hunter-BeastMastery','Mage-Frost','Priest-Discipline','Priest-Holy','Rogue-Outlaw','Rogue-Subtlety','Evoker-Devastation','DeathKnight-Frost','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','Hunter-Marksmanship','Paladin-Retribution','Paladin-Holy','Druid-Balance','Warrior-Fury','Mage-Fire','Evoker-Preservation',}; local provider = {region='CN',realm='激流之傲',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adonis:AwAECAQABRQAAA==.',As='Asunal:AwAGCAQABRQAAA==.',De='Demononback:AwACCAIABAoAAA==.',Oc='October:AwACCAIABAoAAA==.',Qw='Qwq:AwAGCAsABAoAAA==.',St='Starboy:AwAICAgABAoAAA==.',Th='Theleoric:AwAICAgABAoAAA==.',Yz='Yzhndk:AwAGCAoABRQCAQAGAQh3AgAng0kBBRQAAQAGAQh3AgAng0kBBRQAAA==.Yzhnqs:AwAFCBUABRQCAgAFAQgUAQBSGoMBBRQAAgAFAQgUAQBSGoMBBRQAAQEAJ4MGCAoABRQ=.',['�']='一刘小臭一:AwACCAQABRQAAA==.七浠瓜籽:AwAECAQABRQAAA==.三沐狮子王:AwAECAMABRQAAA==.丶伊内斯:AwAICAsABAoAAA==.',['�']='二懵二:AwABCAEABRQAAA==.京都丨念慈庵:AwAICAgABAoAAA==.人工智能一号:AwADCAMABRQAAQMAAAAICAQABRQ=.',['�']='伐竹取道:AwABCAEABRQAAA==.优势在我:AwAGCAkABAoAAA==.',['�']='何弃疗:AwAFCAUABAoAAA==.你哥临死前:AwAGCAYABAoAAA==.',['�']='便便超人丶:AwAICAgABAoAAA==.',['�']='假的聖騎士:AwAECAQABAoAAQQASVsFCAUABRQ=.',['�']='元子:AwAFCAYABAoAAA==.兇兇的奶嘴:AwAHCAwABAoAAA==.兔你一嘴:AwAGCAYABRQCBQAGAQijAgAiEYkBBRQABQAGAQijAgAiEYkBBRQAAQUAQtgGCAoABRQ=.六磊:AwACCAMABRQAAA==.',['�']='冰轩爻魔幻:AwAFCAUABAoAAA==.冷飲:AwAECAcABRQCBgAIAQhRGQBCsxQCBAoABgAIAQhRGQBCsxQCBAoAAA==.',['�']='剩枪游侠尾巴:AwAECAEABRQAAQUAQtgGCAoABRQ=.',['�']='十一月的小德:AwAGCAIABRQAAA==.半糖:AwABCAEABRQAAA==.',['�']='厉害了我滴哥:AwACCAIABRQAAA==.',['�']='咸鱼突刺专员:AwAECAQABRQAAA==.',['�']='哀伤的秋天:AwAICAgABAoAAA==.',['�']='喵天喵地:AwAGCAQABRQAAQEAJ4MGCAoABRQ=.',['�']='嗜血红蔷薇:AwAECAQABRQAAA==.',['�']='圣耀星辉:AwAGCAwABAoAAA==.地狱狂猪佩奇:AwAECAQABRQAAA==.地蕾我最爱:AwABCAEABAoAAA==.',['�']='塡下忧樂:AwAHCAUABAoAAA==.',['�']='壹言不合:AwAICAYABAoAAA==.',['�']='多肉葡萄冻:AwAICAgABAoAAA==.大吉吉萌妹:AwACCAIABAoAAA==.大漂亮:AwAECAQABRQAAQQAONUGCAYABRQ=.大神带你们:AwACCAQABRQAAA==.天镶劫火:AwABCAEABAoAAA==.',['�']='奶少:AwABCAEABAoAAA==.',['�']='姬无命:AwAICAgABAoAAA==.',['�']='宗师小周:AwACCAIABRQAAA==.',['�']='小七:AwABCAEABRQCBAAIAQihPQAmsYYBBAoABAAIAQihPQAmsYYBBAoAAA==.小小花花尝:AwAFCAIABAoAAA==.小柱柱:AwAECAQABRQAAA==.小火车:AwAECAQABRQAAA==.小煤球快跑:AwAGCAYABAoAAA==.小芙遥:AwABCAEABRQDBwAIAQiHHAA0GrkBBAoABwAIAQiHHAAzWLkBBAoACAAGAQg3TwAavM4ABAoAAA==.小葵:AwAECAQABRQAAA==.小酸奶守护者:AwAECAQABAoAAA==.小鬼不忙:AwAECAQABRQAAA==.',['�']='巫小乖:AwAICAsABAoAAA==.',['�']='布丁大魔王:AwAICAgABAoAAA==.布丁酱:AwAECAQABRQAAA==.',['�']='库洛洛鲁西鲁:AwACCAYABRQDCQACAQg7AgBOT7sABRQACQACAQg7AgBOT7sABRQACgABAQj+DgA5iUsABRQAAA==.庭前柏子香:AwAECAQABRQAAA==.',['�']='廿一是只虎斑:AwAICAgABAoAAA==.',['�']='张小花邻居:AwAGCAYABAoAAA==.张根硕:AwAECAEABRQAAA==.弯弓似月牙:AwADCAYABAoAAA==.',['�']='情之亦心往:AwAECAQABRQAAA==.',['�']='慌的一批丶:AwACCAIABRQAAA==.',['�']='我有牛奶:AwABCAEABAoAAA==.',['�']='拔箭四顾:AwAGCAoABRQCBQAGAQj1AABC2NoBBRQABQAGAQj1AABC2NoBBRQAAA==.',['�']='掼蛋大师:AwAGCAEABRQAAQsAORUICAwABRQ=.',['�']='斌宝:AwAGCAYABAoAAQMAAAAGCAQABRQ=.施巴拉古大师:AwAECAQABRQAAA==.',['�']='无所畏惧先生:AwAFCAUABAoAAA==.',['�']='星辰丶:AwAECAIABRQAAA==.映梅来了:AwAFCAUABAoAAA==.是我惹不起:AwAGCAYABAoAAA==.',['�']='晓封:AwACCAIABRQAAA==.',['�']='暗鸦:AwAGCBAABAoAAA==.',['�']='最终之战:AwACCAIABRQAAA==.',['�']='李狗蛋超级凶:AwABCAIABRQDBAAHAQinHABYmy4CBAoABAAHAQinHABYmy4CBAoADAACAQgWLwA8rywABAoAAA==.',['�']='枫叶下的猫:AwACCAMABAoAAA==.',['�']='槑乄冷兮:AwACCAIABAoAAA==.',['�']='欻霊:AwADCAQABAoAAA==.',['�']='永恒之钽:AwAECAQABRQAAA==.永恒之银:AwAECAQABRQAAA==.永恒之镅:AwAECAQABRQAAQ0ASh4GCAcABRQ=.',['�']='求求你别说了:AwADCAMABAoAAA==.',['�']='漠御师:AwACCAUABRQCDgACAQgjGAArc5AABRQADgACAQgjGAArc5AABRQAAA==.',['�']='灬晴天灬:AwAHCAcABAoAAA==.灰色天堂:AwAECAQABRQAAQ8ATFAGCAsABRQ=.',['�']='特洛伊德:AwAGCAoABAoAAA==.',['�']='猪肉蜜饯:AwAECAQABRQAAA==.',['�']='獠刹:AwABCAEABRQAAA==.',['�']='玛德:AwACCAQABRQAAA==.',['�']='生前是圣骑:AwACCAIABRQCBAAHAQg1FgBWglgCBAoABAAHAQg1FgBWglgCBAoAAA==.',['�']='皓月苍穹:AwAECAYABRQDEAAEAQjvCgAsF9AABRQAEAAEAQjvCgAmiNAABRQABQACAQi+KAAtU4sABRQAAQMAAAAICAQABRQ=.',['�']='石盖坞皮卡丘:AwABCAEABAoAAA==.',['�']='砚寒清:AwADCAUABRQCEQADAQiIFgAwKuoABRQAEQADAQiIFgAwKuoABRQAAA==.',['�']='磁爆步兵:AwACCAIABAoAAA==.',['�']='神棍一头:AwAGCAYABAoAAA==.',['�']='筱邪鬼:AwAICAsABAoAAA==.',['�']='红手:AwADCAYABRQCEgADAQjAAQBX5SIBBRQAEgADAQjAAQBX5SIBBRQAAA==.',['�']='维多利亚:AwAICA4ABAoAAA==.',['�']='艾丶虂恩:AwAGCAYABRQCEwAGAQjqAAA0xqsBBRQAEwAGAQjqAAA0xqsBBRQAAA==.艾米莉娅:AwAICAwABAoAAA==.',['�']='莉莉娅娜:AwAECAQABRQAAA==.',['�']='赵弃疗:AwABCAEABAoAAA==.',['�']='软云:AwAICBMABAoAAA==.',['�']='邻居:AwAICAgABAoAAA==.',['�']='部落的天使:AwAICAIABAoAAA==.',['�']='重锤:AwAECAgABRQDDQAEAQhaBAAsc/QABRQADQADAQhaBAAsc/QABRQAFAAEAQgYEgARKcEABRQAAA==.',['�']='销魂置死:AwAICAgABAoAAA==.',['�']='长椿街幼儿园:AwADCAMABAoAAA==.',['�']='问剑:AwAICAgABAoAAA==.',['�']='阿桑啊:AwACCAIABAoAAA==.阿蕾克斯塔萨:AwAGCAgABRQCFQAGAQhEAwAr4psBBRQAFQAGAQhEAwAr4psBBRQAAA==.',['�']='青春你太痘:AwACCAIABAoAAA==.',['�']='飛刀:AwABCAIABRQAAA==.飞翔的砖头:AwABCAEABRQAAA==.',['�']='骑老奶过马路:AwACCAIABRQDCwAHAQjhFgBDTdgBBAoACwAHAQjhFgBDTdgBBAoAFgAHAQhuCwA17ZYBBAoAAA==.',['�']='高兄:AwAICAUABAoAAA==.',['�']='黄块块:AwAECAQABRQAAA==.黑锋:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end