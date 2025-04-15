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
 local lookup = {'DemonHunter-Havoc','Paladin-Holy','Druid-Restoration','Priest-Shadow','Monk-Mistweaver','Monk-Windwalker','Unknown-Unknown','Priest-Discipline','DeathKnight-Blood','Hunter-Marksmanship','Mage-Fire','DeathKnight-Unholy','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Fury','Paladin-Retribution','Evoker-Devastation','Warrior-Protection','Priest-Holy','Paladin-Protection','Shaman-Elemental','Shaman-Restoration','Druid-Balance','Warrior-Arms','Mage-Frost','Monk-Brewmaster','Druid-Guardian','DeathKnight-Frost','Rogue-Assassination',}; local provider = {region='CN',realm='霜狼',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ba='Bahamutia:AwAECAQABRQAAA==.Bamboo:AwAICAgABAoAAA==.',Bu='Bugyellow:AwAFCAUABAoAAA==.',Do='Donut:AwAFCAUABAoAAA==.',Dy='Dyinglight:AwAICAgABAoAAA==.',Ea='Eagle:AwAECBEABRQCAQAEAQi6BQBcYzMBBRQAAQAEAQi6BQBcYzMBBRQAAA==.',Ff='Ffkt:AwACCAQABRQCAgAIAQjfEAAx99UBBAoAAgAIAQjfEAAx99UBBAoAAA==.',Fr='Frezix:AwAECAMABRQAAA==.',Ge='Genkiovo:AwAECAQABRQAAQMAOkwGCAUABRQ=.',Gl='Gloriana:AwAGCAYABAoAAA==.',Gr='Gressi:AwAECAQABRQAAQQANl0GCAoABRQ=.',Hi='Hiperson:AwABCAEABRQDBQAIAQjdJAAwBrcBBAoABQAIAQjdJAAwBrcBBAoABgADAQjRSgA3kbMABAoAAQcAAAAICAIABRQ=.',Js='Js:AwACCAcABRQDCAACAQhzFgAvPI0ABRQACAACAQhzFgAvPI0ABRQABAABAQj0IAAfu0QABRQAAA==.',Kt='Ktm:AwABCAEABRQAAA==.',La='Lays:AwAECAQABRQAAA==.',Li='Littlecarol:AwABCAMABRQAAA==.',Lu='Luckychirp:AwACCAIABAoAAA==.',Mo='Mournerm:AwAGCAgABRQCCQAGAQhkAwAnvEEBBRQACQAGAQhkAwAnvEEBBRQAAA==.',Sp='Spell:AwAHCAkABAoAAQgALzwCCAcABRQ=.',Va='Valamorgulis:AwABCAEABRQAAA==.Valkyriedisr:AwAGCAgABRQCBQAEAQjUCgBFf/kABRQABQAEAQjUCgBFf/kABRQAAA==.',Yi='Yip:AwAECAgABRQCCgAEAQhgAQBdMkQBBRQACgAEAQhgAQBdMkQBBRQAAA==.',['�']='一七四七:AwAICAgABAoAAA==.一九三月三十:AwAECAQABAoAAA==.一亿个部落:AwADCAMABAoAAA==.一颗小丸子:AwAECAgABRQCCwAEAQghFwAyyOUABRQACwAEAQghFwAyyOUABRQAAQsAQ8QICAcABRQ=.七千紫玉:AwAGCAYABAoAAA==.三丰山一心:AwADCAQABRQAAA==.三叹知悟:AwAICBIABAoAAA==.三月沐沐丶:AwACCAIABAoAAA==.上官芸瑶:AwAICAgABAoAAA==.不接受指点:AwAECAQABRQAAQcAAAAGCAQABRQ=.不由己:AwADCAMABAoAAA==.丨咕噜噜:AwAICAgABAoAAQwAQ3sGCAUABRQ=.中年妇女之友:AwACCAIABRQAAA==.丶七七牌武僧:AwAGCAYABAoAAA==.丶半仙:AwAGCAYABAoAAA==.丶四季映姬:AwAICAEABAoAAA==.丶我滴个乖乖:AwAGCAQABRQAAA==.丶燕京:AwACCAQABRQDCgAIAQgpHQBBobcBBAoADQAIAQjWOgA/ze4BBAoACgAIAQgpHQAwSrcBBAoAAA==.',['�']='乃尼:AwAECAQABRQAAA==.九潭:AwAECAUABAoAAA==.习惯感冒:AwAHCBUABAoCDAAHAQiaRgAzGHABBAoADAAHAQiaRgAzGHABBAoAAA==.买小开大:AwACCAIABAoAAA==.',['�']='云澜:AwAECAQABRQAAA==.亡语行者:AwAICA0ABAoAAA==.',['�']='伊月六號:AwADCAMABAoAAA==.伊泽丶:AwABCAEABAoAAA==.伊点点:AwAFCAwABAoAAA==.伍公子:AwACCAMABRQEDgAIAQj1JwBCa8gBBAoADgAIAQj1JwAynMgBBAoADwAFAQgELAA4tAABBAoAEAADAQiaIQA01skABAoAAA==.伐开心:AwAGCAcABAoAAA==.伽尔鲁什:AwAECAgABRQCEQAEAQhcCAA+OBIBBRQAEQAEAQhcCAA+OBIBBRQAAA==.',['�']='余生安好:AwAICAgABAoAAA==.',['�']='依然茶理理:AwABCAMABRQCEgAIAQivKwBNp1sCBAoAEgAIAQivKwBNp1sCBAoAAA==.',['�']='信仰痛苦:AwAICAgABAoAAA==.',['�']='偽君子:AwAECAQABAoAAA==.',['�']='兄弟们都很强:AwAICAEABAoAARMAD08ICAUABRQ=.光刃:AwACCAIABAoAAQcAAAAGCAQABRQ=.光影双刃:AwABCAEABRQAAA==.光明贤者:AwABCAEABAoAAA==.其实不会射:AwAGCAYABAoAAA==.兽兽哥哥:AwABCAEABRQAAA==.',['�']='冰封靈魂:AwAICAgABAoAAA==.冰灬風:AwAHCAcABAoAAA==.冰障:AwAECBAABRQCFAAEAQhzAwAuZssABRQAFAAEAQhzAwAuZssABRQAAA==.冰障硬硬哒:AwACCAIABRQAAQcAAAAICAIABRQ=.冰障超硬哒:AwADCAMABRQAAA==.',['�']='凉与安之:AwAECAQABRQAAA==.凌小杨:AwAICAgABAoAAA==.',['�']='别摸了唱会巴:AwADCAoABRQDBAADAQikCABNcgQBBRQABAADAQikCABNcgQBBRQAFQABAQjUHwAnhzgABRQAAA==.',['�']='前槽肉:AwADCAMABAoAAA==.剑羽:AwAFCAkABAoAAA==.',['�']='勤奋的小亚洲:AwABCAIABAoAAA==.',['�']='卅六命穴术:AwABCAEABAoAAA==.半抹笑颜灬:AwAICAgABAoAAA==.',['�']='叁暧:AwABCAEABAoAAA==.',['�']='吾已隐身:AwACCAIABAoAAA==.',['�']='咔咔叽叽:AwAICAgABAoAAA==.咖啡鸦:AwAGCAcABAoAAA==.',['�']='哎喲喂:AwAFCAUABAoAAA==.哪个最能打:AwABCAEABRQAAA==.',['�']='唤唤:AwAICAgABAoAAA==.',['�']='善良摇粒龙:AwAICA8ABAoAAA==.',['�']='回风抚柳:AwADCAMABAoAAA==.团灭制造者:AwAGCAYABRQCCQAGAQhlBgAQrgwBBRQACQAGAQhlBgAQrgwBBRQAAA==.',['�']='圣光之傲:AwADCAMABRQAAA==.圣光永再:AwAECAQABRQAAQcAAAAICAIABRQ=.圣型尤物:AwACCAIABAoAAA==.',['�']='堇色:AwADCAMABAoAAA==.',['�']='墨淑:AwAECAEABAoAAA==.墨炎:AwAGCAgABRQDCgAGAQgfAABPV+oBBRQACgAGAQgfAABPV+oBBRQADQACAQikNgAZR1gABRQAAA==.',['�']='夏慕丶:AwAECAQABRQAAA==.夏淯:AwACCAIABRQAAQEAPtMGCAoABRQ=.夙夜黑:AwAECBAABRQEEAAEAQiIAQBiLDYBBRQAEAADAQiIAQBdqTYBBRQADwACAQjOCABgLHAABRQADgACAQijKwA4cDsABRQAAA==.大不了死死:AwACCAUABRQCDgACAQhqGAA825kABRQADgACAQhqGAA825kABRQAAA==.大光明:AwADCAMABAoAAA==.大咕咕鸡:AwEICBsABAoDEgAIAQhISABaKf0BBAoAEgAGAQhISABd1v0BBAoAFgAEAQifGABTT34BBAoAAA==.大壑:AwABCAEABAoAAA==.天朝良民:AwAECAQABRQAAQcAAAAICAIABRQ=.天涯丶圣光:AwAGCAEABAoAAA==.天灰月明:AwAHCAcABAoAAA==.天琴座:AwAECAQABAoAAA==.',['�']='奇亚娜:AwAECAEABAoAAA==.奶油丶面包:AwABCAEABRQAAA==.奶粉子:AwAGCAYABAoAAA==.',['�']='妈妈她亲我:AwADCAMABRQAAA==.妞比:AwAGCAwABAoAAA==.',['�']='寂寞素素雪糕:AwAECAQABRQAAA==.寒殇:AwAECAoABRQCEgAEAQjqAwBhm0wBBRQAEgAEAQjqAwBhm0wBBRQAAA==.',['�']='小小的老七:AwAECAcABRQDCgAEAQhCAwBQwh0BBRQACgAEAQhCAwBQBB0BBRQADQACAQjjKwBDrIwABRQAAA==.小瓜同学:AwACCAIABAoAAA==.小破烂:AwAGCBIABRQDBAAGAQjdAgAlL4sBBRQABAAGAQjdAgAlL4sBBRQACAAEAQgREAAXZr0ABRQAAQgAPiAICA4ABRQ=.小羽有沟:AwAECA4ABRQDEgAEAQi8CABQnyQBBRQAEgAEAQi8CABQnyQBBRQAAgAEAQjyBABCVu8ABRQAAA==.小鱼牌电池:AwAICBQABAoCFwAIAQjMGwA8uO8BBAoAFwAIAQjMGwA8uO8BBAoAAA==.少年阿宾:AwADCAQABRQAAA==.尛囡囡:AwACCAIABRQCEgAGAQgfigA75GIBBAoAEgAGAQgfigA75GIBBAoAAA==.尛术玛利亚丶:AwAECAIABRQAAA==.就这样落幕:AwAGCAcABAoAAA==.',['�']='巫喵王:AwAICAIABAoAAA==.己狸丶:AwAGCAcABAoAAA==.',['�']='布兜里有电:AwACCAQABRQCFwAIAQjbGwBOX+8BBAoAFwAIAQjbGwBOX+8BBAoAAQsAJ70GCAoABRQ=.布莱恩铜须:AwAECAYABRQCGAAEAQiFDwAiytwABRQAGAAEAQiFDwAiytwABRQAAA==.布莱特妞妞:AwAICBwABAoCGQAIAQgHKABC1AMCBAoAGQAIAQgHKABC1AMCBAoAAA==.师妹不够你爽:AwACCAIABRQAAA==.帝国猛虎:AwACCAYABRQCDAACAQgCGwArwpIABRQADAACAQgCGwArwpIABRQAAA==.席八:AwABCAEABRQAAA==.',['�']='幸亏时时护蛋:AwABCAEABAoAAA==.',['�']='廣州麻袋厂:AwAICA8ABAoAAA==.',['�']='强壮不是虚胖:AwAHCAoABAoAAA==.',['�']='影子海:AwAECAcABAoAAA==.彼岸丶微凉:AwAECAQABRQAAQcAAAAICAEABRQ=.',['�']='微分队长:AwAHCAcABAoAAQkANY4GCAYABRQ=.',['�']='心动藏在风中:AwACCAIABAoAAA==.忘想症丶:AwAHCA0ABAoAAA==.',['�']='怀抱杀意:AwAICAoABAoAAA==.',['�']='恶之序曲:AwADCAUABAoAAA==.恶梦前曦:AwACCAIABRQAAA==.',['�']='戈仔:AwAECAQABAoAAA==.战浮云:AwABCAMABRQDEQAIAQjLDgBTE4ECBAoAEQAIAQjLDgBTE4ECBAoAGgABAQiJXABHBzgABAoAAA==.',['�']='把妹僚机:AwAICAEABAoAAA==.抓猫的老鼠:AwAICAgABAoAARsAMpgGCAYABRQ=.抽不到:AwAICAYABAoAAA==.',['�']='拳斗萝:AwAECAgABRQDBQAEAQg0EAAib9oABRQABQAEAQg0EAAib9oABRQAHAACAQgOBgAj7XIABRQAAQcAAAAICAIABRQ=.',['�']='挟飞仙以遨游:AwAFCAUABAoAAA==.',['�']='控鹤擒龙:AwAECAQABAoAAA==.',['�']='搞起来搞起来:AwABCAIABRQAAA==.',['�']='敖嗔:AwAECA0ABAoAAA==.教授丨疯语者:AwAECAIABRQAAA==.',['�']='新垣結依:AwAGCAYABAoAAA==.',['�']='旅行家:AwAICAYABAoAAA==.无情刷本机器:AwADCAEABRQAAA==.无脑上头送:AwAECAQABAoAAA==.',['�']='是小社长啊:AwAGCAgABAoAAA==.',['�']='晓兔丨乖:AwAICAgABAoAAA==.景严:AwAECAQABAoAAA==.',['�']='暗影审判邪恶:AwAECAQABRQAAA==.暗影撕咬者:AwAECAQABRQAAA==.',['�']='月下彼端:AwACCAUABRQDCwACAQhWIgBAXqsABRQACwACAQhWIgA8aasABRQAGwABAQj/FgBa7kYABRQAAA==.月之女神:AwAECAQABRQAAQ0AVXAGCAYABRQ=.月光美少男:AwACCAIABRQAAA==.月舞云裳:AwAICAgABAoAAA==.月魔邪:AwAECAgABRQCDgAEAQi+EAAkT88ABRQADgAEAQi+EAAkT88ABRQAAA==.',['�']='条野太翔:AwAGCAcABAoAAA==.',['�']='林墨焱:AwAICAgABAoAAA==.',['�']='树尾巴:AwAGCAsABAoAAA==.格尔曼的门徒:AwACCAMABRQAAA==.格羅瑪什:AwACCAIABRQAAA==.',['�']='梵高的右耳:AwAECAQABRQAAA==.',['�']='棱儿:AwACCAIABRQAAA==.',['�']='椒盐乔治:AwADCAMABAoAAA==.',['�']='楚天千里清秋:AwABCAEABRQAAA==.',['�']='橙子快跑:AwAICAgABAoAAA==.',['�']='欧气:AwACCAIABRQAAA==.',['�']='此乃正义之言:AwACCAIABAoAAA==.死海文书:AwAECAoABRQDFQAEAQiVCgAnZc8ABRQAFQAEAQiVCgAhKc8ABRQACAACAQioFwAvhIcABRQAAA==.',['�']='残酷之炽:AwACCAIABAoAAA==.',['�']='洛坎:AwAECAQABRQAAA==.',['�']='浪漫武士:AwACCAIABAoAAA==.浮笙若梦:AwABCAEABAoAAA==.海鸟丶千梨:AwAECA8ABRQCGAAEAQhjBwBEyg4BBRQAGAAEAQhjBwBEyg4BBRQAAA==.',['�']='涛子的游侠:AwACCAIABRQAAA==.',['�']='清风丷胡匪:AwAICAgABAoAAA==.渡己:AwAECAQABRQAAA==.',['�']='溪谷子:AwACCAIABRQAAA==.',['�']='火柴棍:AwAECA0ABRQDCgAEAQjACgBUrd0ABRQACgADAQjACgBI690ABRQADQADAQj6IQBX1acABRQAAA==.灰级:AwAGCAYABAoAAA==.灵之风:AwACCAEABAoAAA==.灼热的炎爆:AwACCAIABRQEGQAIAQiLKAA7ywACBAoAGQAIAQiLKAA7ywACBAoAAwABAQjshAAPXyEABAoAHQABAQiZMwAGOAcABAoAAA==.',['�']='炉火纯基:AwAICAYABAoAAA==.炎龙大帝:AwAICA4ABAoAAA==.',['�']='烨神月:AwAECAQABRQAAA==.烨馨:AwAGCAYABAoAAA==.',['�']='無丶心:AwACCAMABAoAAA==.無麟:AwADCAMABRQAAA==.',['�']='熙若小凤凰:AwAECAYABRQCCwAEAQiUHAAgmdIABRQACwAEAQiUHAAgmdIABRQAAA==.',['�']='爫丿爫:AwAECA8ABRQDDQAEAQhRGgAlSNgABRQADQAEAQhRGgAlSNgABRQACgACAQiGGAALnGAABRQAAA==.',['�']='牛大力:AwACCAIABRQCEgAIAQhdHwBSrIsCBAoAEgAIAQhdHwBSrIsCBAoAAA==.牧秋的风:AwADCAUABAoAAA==.',['�']='狂刀三浪:AwAECAQABRQAAA==.狐丶狸:AwADCAMABAoAAA==.狼族血灵:AwAICA8ABAoAAA==.',['�']='玖紫:AwABCAEABAoAAA==.',['�']='甘草茶:AwABCAEABAoAAA==.',['�']='疾风丨虎牙:AwADCAMABAoAAA==.疾风灬牛:AwACCAMABRQAAA==.',['�']='真的跑不过:AwAGCAYABAoAAA==.眼伍兹么了:AwABCAEABAoAAQYATFAGCAsABRQ=.',['�']='督军黑手:AwAHCAcABAoAAA==.',['�']='破壁人:AwACCAIABRQAAA==.',['�']='神一样的熊人:AwAECAgABAoAAA==.',['�']='福珀斯:AwABCAEABAoAAA==.',['�']='米兰酱:AwABCAEABAoAAA==.米团团丶:AwABCAEABAoAAA==.',['�']='紫色苍蝇:AwAECAQABRQAAA==.',['�']='经典红双喜:AwADCAIABAoAAA==.绿火术:AwAFCAUABAoAAA==.',['�']='肉汁团:AwADCAQABAoAAA==.',['�']='與小田的故事:AwADCAMABAoAAA==.與老李的故事:AwAECAQABRQAAA==.與芋头的故事:AwAECAgABRQCGAAEAQh2CgA2vvcABRQAGAAEAQh2CgA2vvcABRQAAA==.',['�']='花卷是只猫:AwAECAgABRQCEgAEAQgWFABFXPkABRQAEgAEAQgWFABFXPkABRQAAA==.花小喵:AwAHCAsABAoAAA==.花开丶夜叉:AwAECAgABRQCCgAEAQjkAQBc+DYBBRQACgAEAQjkAQBc+DYBBRQAAA==.花开丶珈蓝:AwAECAYABRQCEwAEAQhHCQAyxuwABRQAEwAEAQhHCQAyxuwABRQAAA==.花开丶迦楼罗:AwACCAIABAoAAA==.花开丶阿修罗:AwADCAkABRQDDAADAQibDAA10+8ABRQADAADAQibDAA10+8ABRQACQACAQijFQAyJHsABRQAAA==.花心小銫魔:AwABCAEABRQAAA==.芳芳纯爷们:AwAECAQABRQAAA==.',['�']='苗人小凤:AwAGCAYABAoAAA==.苞谷粑粑:AwAGCAkABAoAAA==.',['�']='茶理理呢:AwAGCBEABAoAAA==.',['�']='草莓丶:AwAGCAYABAoAAA==.草莓蛋烘糕:AwADCAcABRQCEgADAQgeGQAwLuoABRQAEgADAQgeGQAwLuoABRQAAA==.',['�']='萌萌的深井冰:AwAECAQABRQAARkARu4GCAYABRQ=.萨勒芬妮:AwAECAQABAoAAA==.萨拉灬怀恩:AwABCAEABAoAAA==.落迦神女:AwADCAMABAoAAA==.落霞与孤雁:AwAHCAUABAoAAA==.',['�']='葛蕾丝:AwADCAMABAoAAA==.',['�']='蕾丝酋长:AwAICAoABAoAAA==.',['�']='蛮荒丶大酋长:AwABCAEABAoAAA==.',['�']='被和谐的勇士:AwABCAIABRQAAA==.',['�']='西冷肉眼:AwACCAIABRQAAA==.西北砍王:AwACCAIABRQCEQAIAQjpEQBJ/mcCBAoAEQAIAQjpEQBJ/mcCBAoAAA==.',['�']='让我瞅瞅:AwAECAQABRQAAA==.',['�']='谜一样的乳僧:AwAECAgABAoAAA==.谜底:AwAHCAwABAoAARsAYWICCAQABRQ=.',['�']='赏你一爪子:AwAFCAEABAoAAA==.',['�']='超市里扫货:AwAGCAYABAoAAA==.足浴上三楼:AwAGCAQABRQAAA==.',['�']='路过帝:AwAICAgABAoAAA==.跳起打你腿:AwAICAgABAoAAA==.',['�']='蹭吃的吗喽:AwAFCAUABAoAAA==.',['�']='輕描淡写:AwADCAYABRQCEQADAQiuCgA8SAYBBRQAEQADAQiuCgA8SAYBBRQAAA==.',['�']='逝湮:AwAICBYABAoCEgAIAQjGXwBHjcEBBAoAEgAIAQjGXwBHjcEBBAoAAA==.',['�']='道灬道灬道:AwADCAMABAoAAA==.',['�']='那一刻的风骚:AwABCAEABAoAAA==.那时还相信光:AwADCAMABAoAAA==.',['�']='都没有人:AwACCAIABAoAAA==.',['�']='野德天下第一:AwAECAQABAoAAA==.野猫:AwAHCAQABAoAAQcAAAAECAQABRQ=.',['�']='鋈媵鋈螽:AwACCAIABAoAAA==.',['�']='钢蛋:AwEICA0ABAoAARIAWikICBsABAo=.钮钴禄大魔王:AwACCAYABRQDDAAIAQh3CwBZ+rMCBAoADAAIAQh3CwBXw7MCBAoAHgAEAQhBHgBL8LEABAoAAQkARwgGCAkABRQ=.钱来兮:AwAICBEABAoAAA==.',['�']='长庚:AwAICAgABAoAAA==.',['�']='阿光:AwAECAYABRQCAQAEAQgqEAA/A+4ABRQAAQAEAQgqEAA/A+4ABRQAAA==.阿兽呀:AwACCAIABRQAAA==.阿兽呦:AwACCAEABRQAAA==.阿帝雷华:AwAICAgABAoAAA==.',['�']='陈大帥:AwAHCAsABAoAAA==.陸郎丨煋:AwAICBEABAoAAA==.',['�']='集合准备团灭:AwABCAIABRQAAA==.雪碧纤维加:AwACCAIABAoAAA==.雲中悍刀行:AwAECAQABRQAAA==.',['�']='青灬:AwAICAgABAoAAA==.靓仔锋:AwAECAQABRQAAA==.非酋的觉醒:AwAHCAgABAoAAA==.非酋的诅咒:AwAFCAwABAoAAA==.',['�']='风乎灬舞雩:AwAICAUABAoAAA==.风暴酋长:AwAECAUABAoAAA==.风流空心菜:AwACCAIABAoAAA==.',['�']='首席骑士:AwAECAQABRQAAA==.',['�']='鬼塚英咭:AwAFCAwABAoAAA==.',['�']='麒麟之翼:AwAECAQABRQAAA==.麥斯克丶費倫:AwACCAYABRQCHwACAQilDwAaapAABRQAHwACAQilDwAaapAABRQAAA==.麦田里的龍人:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end