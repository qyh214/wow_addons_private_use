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
 local lookup = {'Paladin-Retribution','Druid-Balance','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Blood','DeathKnight-Unholy','Monk-Brewmaster','Warrior-Fury','Mage-Fire','Unknown-Unknown','Warrior-Arms','Monk-Mistweaver','Rogue-Subtlety','DemonHunter-Havoc','Mage-Frost','Paladin-Holy',}; local provider = {region='CN',realm='奥拉基尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Cr='Crazyfu:AwAICAYABAoAAA==.',Fe='Felix:AwACCAcABRQCAQACAQgqJwA1FZsABRQAAQACAQgqJwA1FZsABRQAAA==.',Kn='Knowknow:AwAICAgABAoAAA==.',Ll='Llsxjr:AwAGCAYABAoAAA==.',Ma='Madara:AwADCAwABRQCAgADAQhmCgA9UP8ABRQAAgADAQhmCgA9UP8ABRQAAA==.',Oc='Octfirst:AwAECAQABAoAAA==.',Re='Rebirth:AwAGCAwABAoAAA==.',Zd='Zdlovelyzzq:AwAICAoABAoAAA==.',['�']='一如一:AwAFCAUABAoAAA==.一骑丶绝尘:AwAECAMABRQAAA==.万古长存:AwAECAgABAoAAA==.三笠:AwAECAQABRQAAA==.不吃拉面:AwAICAgABAoAAA==.不打无畏契约:AwAECAIABRQAAA==.不肯過江東:AwAFCAUABAoAAA==.东方歌白:AwAICBAABAoAAA==.中年大叔:AwAECAUABAoAAA==.丶黑色的猫:AwADCAIABAoAAA==.',['�']='二十四氪纯帅:AwABCAEABAoAAA==.二玥迷迭:AwAECAcABAoAAA==.五月战歌:AwABCAEABAoAAA==.亱糾結:AwAHCAcABAoAAA==.',['�']='会溜达的萝卜:AwAECAwABRQDAwAEAQg7BgBKGfUABRQAAwAEAQg7BgA+EfUABRQABAAEAQgsEQBDufUABRQAAA==.',['�']='何以圣光:AwAGCAIABRQAAA==.',['�']='倔强骑士:AwAHCAcABAoAAA==.倾城一箭:AwAECAgABRQCAwAEAQgpAgBb5SUBBRQAAwAEAQgpAgBb5SUBBRQAAA==.',['�']='光影宗师:AwAICAgABAoAAA==.光辉之主:AwACCAIABAoAAA==.关关小圣女:AwADCAMABRQAAA==.关关小妖女:AwAGCAoABRQDBQAGAQiiCgA8UcIABRQABgACAQg+DwBJ89MABRQABQAEAQiiCgAzO8IABRQAAA==.关关小武女:AwAECAIABRQAAA==.关羽:AwAICCAABAoCAQAIAQgEHgBRgogCBAoAAQAIAQgEHgBRgogCBAoAAA==.',['�']='冈格尼尔:AwADCAMABAoAAA==.',['�']='半赎罪:AwADCAMABAoAAA==.卢克天行者:AwADCAMABAoAAA==.',['�']='叫叫:AwAICA0ABAoAAA==.可口香蕉:AwAHCAYABAoAAA==.',['�']='吥忍:AwAFCAYABAoAAA==.吾入歧途:AwAECAcABAoAAA==.',['�']='咋都行:AwAICAgABAoAAA==.',['�']='商鞅知马力:AwACCAIABRQAAA==.問天悟道:AwACCAIABAoAAA==.',['�']='圣光好耀眼:AwADCAMABAoAAA==.圣光永存:AwADCAQABAoAAA==.圣光的复仇:AwAECAQABAoAAA==.圣光老司机:AwACCAIABRQAAA==.圣诞老人:AwAECAgABAoAAA==.',['�']='夜光裤衩:AwACCAIABAoAAA==.大宗师:AwAICAgABAoAAQcAKp8ICAUABRQ=.大爱糖醋鱼:AwAECAUABAoAAA==.',['�']='奈萝:AwACCAIABRQAAA==.奥丶莫格莱尼:AwAECAQABRQAAA==.奶萨蛮:AwAFCAgABAoAAA==.',['�']='妩媚小妖精:AwAECAQABRQAAA==.',['�']='孟夢:AwAECAsABRQCCAAEAQh0AwBXSj0BBRQACAAEAQh0AwBXSj0BBRQAAA==.孤独圣光:AwAICA4ABAoAAA==.',['�']='宇宙无限:AwAHCAkABAoAAA==.审判闪到腰:AwAGCAYABAoAAA==.',['�']='小凉:AwABCAEABAoAAA==.小手丶炽热:AwAECAMABAoAAA==.小猪丶佩奇:AwAGCAYABRQCCQAGAQjsAgA2SaYBBRQACQAGAQjsAgA2SaYBBRQAAA==.小迷雾:AwAECAQABRQAAA==.尐灬萌喵:AwAFCAYABAoAAA==.尾巴有点短:AwAGCAYABAoAAA==.',['�']='屠日者:AwAGCAQABRQAAA==.',['�']='幽幽羽诺:AwAHCAEABAoAAA==.',['�']='张可以:AwAICA0ABAoAAA==.张师傅牛肉面:AwAICAgABAoAAA==.',['�']='忘尘无忧:AwAFCAYABAoAAA==.',['�']='恶灵曲:AwADCAIABAoAAA==.恶魔灵:AwAGCAYABAoAAQoAAAAICAQABRQ=.',['�']='情义迅捷:AwADCAMABAoAAA==.',['�']='慕容宫詝:AwAFCAYABAoAAA==.',['�']='懒小二:AwAFCAkABAoAAA==.',['�']='抓娃娃:AwABCAIABAoAAA==.抹茶小蛋糕:AwAHCAgABAoAAQoAAAAICA8ABAo=.',['�']='挽月破风尘:AwAECAQABRQAAQoAAAAGCAQABRQ=.挽风:AwAICA0ABAoAAA==.',['�']='提里奥布丁:AwABCAEABAoAAA==.',['�']='斯旺汽水:AwADCAMABRQAAA==.',['�']='日维睿:AwACCAIABAoAAA==.',['�']='星月靈:AwAHCAsABAoAAA==.',['�']='晓风殘月:AwAECAQABRQAAA==.',['�']='暗夜零:AwABCAEABAoAAA==.暗血夜:AwABCAEABAoAAA==.暗言:AwAECAQABRQAAQkAXUsICAwABRQ=.暮色下的回忆:AwACCAIABAoAAA==.',['�']='李云鹤:AwAECAMABAoAAA==.杨小四:AwABCAEABAoAAA==.東風谷早苗:AwAICAkABAoAAA==.',['�']='枫千雪:AwAGCAYABRQDCAAGAQjgAQAyb3kBBRQACAAFAQjgAQA6KnkBBRQACwABAQjnDwAThFsABRQAAA==.枫铮:AwAFCAUABAoAAA==.',['�']='柒幽:AwAECAcABAoAAA==.',['�']='根基:AwADCAMABAoAAA==.',['�']='楼兰五香:AwAICAgABAoAAA==.',['�']='正义的化身:AwAECAQABAoAAA==.死骑士暗:AwAECAUABAoAAA==.',['�']='氰灬岚:AwABCAIABRQCDAAIAQggLQAq+n0BBAoADAAIAQggLQAq+n0BBAoAAA==.',['�']='法宝:AwAFCAUABAoAAA==.',['�']='洋蛋蛋:AwAECAUABAoAAA==.',['�']='浓浓的奶香味:AwACCAMABRQAAA==.',['�']='温大善人:AwAICBcABAoCDQAIAQh+EAAwF+ABBAoADQAIAQh+EAAwF+ABBAoAAA==.',['�']='滑翔:AwAECAcABRQCDgAEAQhHBgBUtScBBRQADgAEAQhHBgBUtScBBRQAAA==.',['�']='灬涵语灬:AwABCAEABAoAAA==.灬筱海灬:AwAGCAUABAoAAA==.灰爱:AwAICAgABAoAAQoAAAAECAQABRQ=.灵儿:AwAGCAYABAoAAA==.灵自灵:AwACCAIABAoAAA==.',['�']='煞羽:AwAGCAsABAoAAA==.',['�']='爱喝点啤啤:AwAECAQABAoAAA==.',['�']='疃春:AwAECAQABRQAAA==.',['�']='盾之勇者丶:AwAECAQABAoAAQoAAAAFCAsABAo=.',['�']='知南而退:AwACCAIABAoAAA==.',['�']='破碎灵魂:AwAICAgABAoAAA==.',['�']='神化飞翼零:AwACCAYABRQCDwACAQhkDAAzb5IABRQADwACAQhkDAAzb5IABRQAAA==.神灬邪圣:AwAGCAoABRQDAQAEAQjLAwBbgkIBBRQAAQAEAQjLAwBbgkIBBRQAEAAEAQh1BgAbVNEABRQAAA==.祸害:AwAFCAYABAoAAA==.',['�']='离心纸土灵奶:AwAFCAUABAoAAA==.',['�']='空山清雨:AwAECAUABAoAAA==.',['�']='纽约龙须面:AwACCAQABRQAAA==.',['�']='绘里的小马尾:AwAICAYABAoAAA==.绚影:AwAHCA8ABAoAAA==.',['�']='罐头:AwABCAEABAoAAA==.',['�']='羽纤:AwAICAgABAoAAA==.',['�']='翼人之下:AwADCAMABAoAAA==.',['�']='老秃头:AwABCAEABAoAAA==.耐瑟瑞尔:AwABCAIABRQDDwAIAQjyKgAy2aYBBAoACQAIAQjEMAAsIMYBBAoADwAIAQjyKgAu3qYBBAoAAA==.',['�']='胖熊没忍住:AwACCAMABAoAAA==.',['�']='自然之心:AwAICAsABAoAAA==.',['�']='艾倩倩:AwAGCAUABAoAAA==.艾斯乄德斯:AwAECAYABRQDAwAEAQibCQBK3NoABRQAAwAEAQibCQAzVdoABRQABAACAQjNJgBKm5AABRQAAA==.',['�']='苍蓝星空:AwACCAEABAoAAA==.',['�']='菲米斯战锤:AwAICA4ABAoAAA==.',['�']='蓝天下的可乐:AwABCAEABAoAAA==.',['�']='蜗角虚名:AwABCAEABAoAAA==.',['�']='血与光荣:AwECCAIABRQAAA==.',['�']='豆包不沾:AwAFCAUABAoAAA==.豆飞鸿:AwADCAIABAoAAA==.',['�']='赛莉斯冷:AwAICAgABAoAAA==.',['�']='迪丽热九:AwAFCAUABAoAAA==.',['�']='重生拿起键盘:AwADCAMABAoAAA==.',['�']='阿加尔塔之风:AwABCAIABRQCBgAIAQjtHABD/CwCBAoABgAIAQjtHABD/CwCBAoAAA==.阿廖沙:AwADCAMABAoAAA==.阿爾托利娅:AwAHCAcABAoAAA==.',['�']='随缘吧:AwAICBgABAoCBQAIAQi5EwBEDN0BBAoABQAIAQi5EwBEDN0BBAoAAA==.随风逐影:AwABCAEABAoAAA==.',['�']='風止:AwAECAQABRQAAA==.',['�']='风之第七章:AwAECAwABRQCCQAEAQjjCABZpyIBBRQACQAEAQjjCABZpyIBBRQAAA==.',['�']='马小萨萨:AwAECAQABRQAAA==.',['�']='鱼泡泡的主人:AwAECAQABRQAAA==.',['�']='鲤仔:AwAECAIABRQAAA==.',['�']='鳳凰鳴:AwAECAYABRQCAgAEAQioBgBQeBkBBRQAAgAEAQioBgBQeBkBBRQAAA==.',['�']='黑火:AwAFCAkABAoAAA==.黯沐丶:AwAICA0ABAoAAA==.',['�']='齐天晓圣:AwADCAMABRQAAA==.',['�']='龙傲天离心支:AwAFCAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end