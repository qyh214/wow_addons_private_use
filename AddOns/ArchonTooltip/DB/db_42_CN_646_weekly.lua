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
 local lookup = {'Rogue-Outlaw','Warrior-Arms','Warrior-Fury','Paladin-Retribution','Warlock-Affliction','Warlock-Destruction','DeathKnight-Unholy','Monk-Mistweaver','Mage-Frost','Mage-Fire','Druid-Restoration','Priest-Shadow','Paladin-Protection','Evoker-Devastation','Warlock-Demonology',}; local provider = {region='CN',realm='奥达曼',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acoge:AwAHCBoABAoCAQAHAQgRCwAouB8BBAoAAQAHAQgRCwAouB8BBAoAAA==.',At='Atalante:AwAFCAcABAoAAA==.',Bu='Burnteddy:AwAGCAcABRQDAgAGAQhPAQAknEkBBRQAAgAEAQhPAQAgQkkBBRQAAwADAQhVFQAuoagABRQAAA==.',Cc='Ccrbq:AwACCAIABAoAAA==.',De='Deathfeather:AwADCAMABAoAAA==.',Ec='Eclipsee:AwABCAEABRQCBAAHAQgwTABJ3ukBBAoABAAHAQgwTABJ3ukBBAoAAA==.',Li='Lifedrain:AwAHCAoABAoAAA==.',Ta='Taro:AwAICAgABAoAAA==.',Yi='Yiyu:AwAFCAUABAoAAA==.',['�']='丁真:AwACCAIABRQAAA==.万俟翔幻:AwACCAIABAoAAA==.上树野吠:AwAICAgABAoAAQQAQFwGCBAABRQ=.不惑之痒:AwADCAMABAoAAA==.不死不归:AwAICAgABAoAAA==.不玩惩戒骑:AwAECAQABRQAAA==.',['�']='云雨天寒:AwAICAUABAoAAA==.五月的图腾:AwADCAMABAoAAA==.亚琉哲:AwAICAgABAoAAA==.',['�']='优伶丨虚:AwABCAEABAoAAA==.',['�']='光光绿丶:AwABCAEABAoAAA==.',['�']='军团大当家:AwACCAEABAoAAA==.',['�']='刀妹:AwAICAgABAoAAA==.初羽艾瑞:AwAECAoABRQCBAAEAQieHAAfftAABRQABAAEAQieHAAfftAABRQAAA==.',['�']='劉鞴丈夫:AwAFCAMABAoAAA==.',['�']='半个苹果:AwAECAQABRQAAA==.卡莎尼梵蒂:AwAECAwABRQDBQAEAQj7AwBMHAYBBRQABQAEAQj7AwBLRQYBBRQABgAEAQgKCgA/fu8ABRQAAA==.',['�']='古馆魔术师忧:AwAHCA0ABAoAAA==.叶清欢:AwADCAMABAoAAA==.',['�']='告白气球:AwADCAMABAoAAA==.',['�']='和联胜丶星爷:AwAHCAwABAoAAA==.',['�']='图腾医逝:AwABCAEABAoAAA==.',['�']='地狱邮差:AwABCAIABRQAAA==.',['�']='夜丶流星丨雨:AwABCAIABRQAAA==.夜织:AwADCAIABRQAAA==.夜羽殇镜:AwABCAEABAoAAA==.',['�']='奔跑的豆子:AwAGCAYABAoAAA==.',['�']='安静潇雪:AwAECAQABRQAAA==.宋宗鸡:AwAGCAoABAoAAA==.',['�']='寂寞烟圈:AwACCAIABRQAAA==.',['�']='帅骑帅骑帅:AwAGCBUABAoCBwAGAQjoKgBhXtoBBAoABwAGAQjoKgBhXtoBBAoAAA==.',['�']='强壮的大熊:AwAECAQABRQAAA==.',['�']='德甲天下:AwAFCAUABAoAAA==.',['�']='情由天定:AwAECAQABRQAAA==.',['�']='懒得理你:AwADCAMABAoAAA==.懵萌丶小内:AwAHCAYABAoAAA==.',['�']='战争狂人:AwABCAEABRQAAA==.',['�']='斯维恩:AwAICAgABAoAAA==.方园:AwAECAUABRQCCAAEAQhXEQAVg8IABRQACAAEAQhXEQAVg8IABRQAAA==.',['�']='星辰朔影:AwAECAQABAoAAA==.',['�']='曦糯:AwACCAIABAoAAA==.',['�']='朱敛:AwAGCAEABAoAAA==.朱雀纪貂蝉:AwAECAQABRQAAA==.',['�']='李小毛:AwAECAQABRQAAA==.杨嘤:AwACCAEABAoAAA==.',['�']='橡皮擦:AwAICBYABAoDCQAIAQhBCABik7MCBAoACQAIAQhBCABik7MCBAoACgACAQiUeABErH0ABAoAAA==.',['�']='残暴熊:AwAICAYABAoAAQsAOkwGCAUABRQ=.残梦慰清愁:AwABCAEABRQCBAAIAQjhYAAz6bQBBAoABAAIAQjhYAAz6bQBBAoAAA==.',['�']='毙肾客:AwAECAIABAoAAA==.',['�']='永恒复仇的眼:AwAICAEABAoAAA==.',['�']='沪小白的拉拉:AwAGCAYABAoAAA==.',['�']='涅颜:AwAFCAQABRQAAA==.',['�']='湟源老万:AwAECAQABRQAAA==.',['�']='灬露宝牛牛:AwAECAQABRQAAA==.',['�']='烙绅:AwABCAEABRQAAA==.',['�']='爱晚睡呦:AwAICAgABAoAAA==.爱睡觉的考拉:AwAECAQABRQAAQwANuAGCAIABRQ=.',['�']='玫斯特拉:AwACCAIABAoAAA==.',['�']='生命的治疗:AwADCAMABRQAAA==.',['�']='疏影织晚意:AwAICA4ABAoAAA==.',['�']='看你的脚下:AwACCAIABRQCBAAIAQgLKQBZd1wCBAoABAAIAQgLKQBZd1wCBAoAAA==.',['�']='罗拉娜米莎凯:AwADCAMABAoAAA==.',['�']='翌日不当差:AwAICAgABAoAAA==.',['�']='肥肠道人:AwAECAQABAoAAA==.',['�']='脸接怪被锤飞:AwAGCAkABRQCDQAGAQglAQA87HwBBRQADQAGAQglAQA87HwBBRQAAA==.',['�']='芦苇笑倾城:AwAFCAUABAoAAA==.',['�']='莎莎蔓:AwAICAcABAoAAQ4AORUICAwABRQ=.莎蔓莎:AwADCAIABAoAAA==.',['�']='萌兽饲养员:AwABCAEABRQAAA==.',['�']='蚑蚑:AwABCAEABAoAAQgAFYMECAUABRQ=.',['�']='血色洗礼:AwACCAYABRQDCgACAQj1JQAe0o0ABRQACgACAQj1JQAe0o0ABRQACQABAQg0GwAY5zEABRQAAA==.',['�']='西猫:AwACCAIABRQAAA==.',['�']='貓狗雙全:AwACCAIABRQAAA==.',['�']='长崎爽世:AwAICEwABAoEBQAIAQgZCwBbKp4BBAoABgAIAQimIgBaPt8BBAoABQAGAQgZCwBHsZ4BBAoADwAFAQj4IQBJoS8BBAoAAA==.',['�']='霊儿曦諾:AwAECAYABAoAAA==.露宝之死骑:AwAFCAUABAoAAA==.霸天虎丶:AwAHCAsABAoAAA==.',['�']='顽强小猪:AwACCAIABRQAAA==.',['�']='风中摇曳桃子:AwAICAcABAoAAA==.',['�']='饱以喵拳:AwADCAUABRQCCAADAQhfFAArYqYABRQACAADAQhfFAArYqYABRQAAA==.',['�']='鸡蛋饼:AwAGCAQABAoAAA==.',['�']='黄少天丶:AwAHCAYABAoAAA==.黄昏现白骨:AwAGCAkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end