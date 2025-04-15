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
 local lookup = {'Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','DeathKnight-Blood','Mage-Fire','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Frost','DemonHunter-Vengeance','Warrior-Arms','Warrior-Fury','DemonHunter-Havoc','Evoker-Devastation','Paladin-Retribution','Paladin-Protection','DeathKnight-Unholy','Warlock-Demonology','Warlock-Affliction','Rogue-Outlaw','Rogue-Subtlety','Warlock-Destruction','Unknown-Unknown','Paladin-Holy','Monk-Windwalker','Mage-Frost','Evoker-Preservation',}; local provider = {region='CN',realm='血牙魔王',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Allicee:AwAECAMABRQAAA==.Aluba:AwAECAgABRQDAQAEAQjCBwA/qwIBBRQAAQAEAQjCBwA/qwIBBRQAAgABAQjeGwBBnlYABRQAAA==.',Am='Amaranta:AwAFCAIABRQAAA==.',Bg='Bgvrbr:AwAECAgABRQDAwAEAQjdEABI+/0ABRQAAwAEAQjdEABI+/0ABRQABAABAQgcIQAL2DIABRQAAA==.',Ca='Calvinkwan:AwAICAgABAoAAA==.',Fi='Firenze:AwAGCAYABRQCBQAGAQjnAAA3zcQBBRQABQAGAQjnAAA3zcQBBRQAAA==.',Fm='Fmruyuan:AwAECAMABRQAAA==.',Mi='Mione:AwAECAQABRQAAA==.',Pa='Patchouli:AwAGCAMABAoAAA==.',Ra='Ravenous:AwAFCAUABRQCBgAFAQjjAQBCSmUBBRQABgAFAQjjAQBCSmUBBRQAAQcAL9sGCAgABRQ=.',Re='Reverence:AwAECAIABRQAAA==.',['�']='丨乌冬丨:AwAGCAsABRQDCAAGAQgIAwATsXYBBRQACAAGAQgIAwATsXYBBRQACQAEAQjQAgA6cMkABRQAAA==.',['�']='乱一咪一咪:AwABCAIABRQCCgAIAQjcCABEhAcCBAoACgAIAQjcCABEhAcCBAoAAA==.',['�']='二队慕斯:AwAECAQABRQAAA==.云汀:AwAGCAIABRQAAA==.五百年前的刀:AwAHCAoABAoAAA==.亚瑟凯恩:AwAECAQABRQAAA==.人无再少年:AwAECAQABRQAAA==.',['�']='伊利蛋灬鲁风:AwABCAEABRQCCwAIAQhUKQAbbA4BBAoACwAIAQhUKQAbbA4BBAoAAA==.伸缩自如的愛:AwAECAEABRQAAA==.',['�']='光火啊:AwADCAcABRQDDAADAQguBgBW3NwABRQADAACAQguBgBdLNwABRQADQABAQgWHwBKPmEABRQAAA==.',['�']='冰火丶曦彧:AwAECAEABAoAAA==.',['�']='努尔哈赤丶:AwABCAEABRQAAA==.',['�']='午夜屠猪男:AwAICAgABAoAAA==.卡修:AwAICAgABAoAAA==.卡莲:AwAECAQABRQAAA==.',['�']='双刀贼:AwACCAMABRQCDgAIAQjOEQBUoI4CBAoADgAIAQjOEQBUoI4CBAoAAA==.叫兽:AwABCAEABRQDDQAIAQhmIABHsQECBAoADQAIAQhmIAA/JQECBAoADAAHAQhPHwA84ZUBBAoAAA==.叫我皮卡丘:AwAICAgABAoAAQ8AD08ICAUABRQ=.可乐不乐:AwADCAYABAoAAA==.',['�']='咸菜寶寶:AwAECAQABRQAAA==.',['�']='喵楽個咪:AwAGCAoABAoAAA==.',['�']='嘉懿的天空:AwAICAYABAoAAA==.',['�']='图灵守护者:AwAECAQABRQCEAACAQg5KAA9MqMABRQAEAACAQg5KAA9MqMABRQAAA==.',['�']='圆锥曲线:AwACCAIABAoAAA==.圣光之潮:AwAECAQABRQAAA==.地狱凯撒:AwAGCAYABRQDEAAGAQiuFgBCHfEABRQAEAAEAQiuFgA+hfEABRQAEQACAQiiCABHgrIABRQAAA==.',['�']='埋山山:AwABCAEABRQAAA==.',['�']='大壮:AwAECAcABRQCEgAEAQgDCQBCpQQBBRQAEgAEAQgDCQBCpQQBBRQAAA==.大姐姐竟然丶:AwAECAQABRQAAA==.大蕉蕉:AwAGCAYABRQDBgAGAQi9BgBMGAYBBRQABgAEAQi9BgBLKQYBBRQAEgACAQjqEQBNfc0ABRQAAA==.大饼叔叔:AwADCAMABRQAAA==.天子铭:AwAICAEABAoAAA==.天青惹寂寥:AwADCAMABAoAAA==.',['�']='奥巴羊丶:AwABCAIABRQAAA==.',['�']='娜美:AwAECAgABRQDEwAEAQg+AwAlheAABRQAEwAEAQg+AwAfPuAABRQAFAAEAQiACQAa5NAABRQAARQAPPUGCAoABRQ=.',['�']='子灬不語:AwADCAMABRQAAA==.',['�']='宝马零利息:AwAECAgABRQCDwAEAQicBQBVsRoBBRQADwAEAQicBQBVsRoBBRQAAA==.',['�']='山背后的葵花:AwABCAEABRQEBQAIAQhZGQAojJABBAoABQAIAQhZGQAojJABBAoAFQACAQidFgAK1UMABAoAFgACAQj/OQAEGB4ABAoAAA==.',['�']='年轻就该多浪:AwACCAIABRQAAA==.',['�']='异乡异客:AwABCAEABRQAAA==.',['�']='征服者康:AwACCAIABRQAAA==.',['�']='心灵导师:AwADCAMABAoAAA==.',['�']='我就爱划水:AwABCAEABRQDEwAIAQh/FwBAAIsBBAoAEwAGAQh/FwBDYYsBBAoAFwADAQjxcgArnJkABAoAAA==.战神小白:AwAICAgABAoAAA==.',['�']='持剑今朝丶:AwAGCAQABRQAAA==.',['�']='斩鬼神:AwADCAoABRQCFwADAQiEDwAsutYABRQAFwADAQiEDwAsutYABRQAAA==.施法:AwAFCBIABAoAARgAAAABCAEABRQ=.',['�']='月下醉仙酒:AwABCAEABRQAAA==.月之刃:AwACCAkABRQCBQACAQhPCwBIw7gABRQABQACAQhPCwBIw7gABRQAAA==.月夜沫语:AwAECAUABRQCEAAEAQi3CABZbiQBBRQAEAAEAQi3CABZbiQBBRQAAREARqoGCAoABRQ=.',['�']='東莞吴彦祖:AwABCAEABRQAAA==.',['�']='栀子比众木:AwADCAUABAoAAA==.格瑞特豆:AwACCAcABRQCDAACAQh8CgA1Q6wABRQADAACAQh8CgA1Q6wABRQAAA==.',['�']='梅山寻橙:AwAHCAQABAoAAA==.',['�']='汐丶芮:AwABCAEABRQAAA==.',['�']='泡椒土豆:AwACCAIABRQAAA==.波希米亚大公:AwAFCAQABAoAAA==.泰兰徳的回忆:AwAECAQABRQAAA==.泰尼恩丶鹰翼:AwAHCAwABAoAAA==.',['�']='洐泠:AwADCAgABRQCGQADAQgGBAA6uvwABRQAGQADAQgGBAA6uvwABRQAAA==.洛欧:AwAICBQABAoCGgAIAQiqCQBaFpkCBAoAGgAIAQiqCQBaFpkCBAoAAA==.',['�']='潇湘曲丶夜语:AwACCAMABRQAAA==.',['�']='濮阳冻豆浆:AwABCAEABAoAARgAAAABCAEABRQ=.',['�']='灬劣空:AwACCAIABRQDGwAIAQjgKQA6zLQBBAoAGwAIAQjgKQA5ALQBBAoABwAFAQhRTAArZjcBBAoAAA==.灵魂乌鸦:AwAGCAYABAoAAA==.',['�']='炽血丨零:AwAECAgABRQCGwAEAQirAQBWii8BBRQAGwAEAQirAQBWii8BBRQAAA==.',['�']='烟火:AwAECAQABRQAAA==.',['�']='熊孩子右踢腿:AwAGCAQABRQAAA==.',['�']='爷今年走荭:AwABCAEABRQAAA==.爷玩啥都厉害:AwAECAMABRQAAA==.',['�']='猜我是谁:AwABCAEABRQAAA==.',['�']='瑕梓:AwAICA0ABAoAAA==.',['�']='祖国的花骨朵:AwAICAgABAoAAA==.',['�']='糯香柠檬茶:AwAICAgABAoAAA==.',['�']='给你一个嘴槌:AwACCAUABRQCDgAIAQi/EwBRrX8CBAoADgAIAQi/EwBRrX8CBAoAAA==.给你一个肘击:AwABCAEABRQAAQ4AUa0CCAUABRQ=.',['�']='胖不了啦:AwADCAMABRQAAA==.',['�']='莨劫:AwAICAgABAoAAA==.',['�']='萨勒芬妮:AwAECAgABRQDDwAEAQhZCwAuht0ABRQADwAEAQhZCwAuht0ABRQAHAAEAQihAwAonsYABRQAAQgARJAICBYABRQ=.落叶木俞瑶丶:AwAECAQABRQAAA==.',['�']='血染星辰:AwAHCAEABAoAAA==.',['�']='西天丶宋仲基:AwAECAYABAoAAA==.',['�']='越塔欢乐送:AwAECAoABRQCBwAEAQhjHQAhcs4ABRQABwAEAQhjHQAhcs4ABRQAAA==.',['�']='逸尚界二一:AwAGCAcABAoAAA==.逸尚界叁号:AwAGCAcABAoAAA==.',['�']='達叔:AwACCAIABRQAAA==.',['�']='闪电兔:AwADCAMABAoAAA==.',['�']='阿克塔尼亚:AwAGCAYABRQCDAAGAQjAAAAtQbkBBRQADAAGAQjAAAAtQbkBBRQAAA==.阿凌要努力:AwAECAQABRQAAA==.阿尔托利雅丶:AwAICAgABAoAARgAAAAICAIABRQ=.',['�']='魔牛奥比:AwAICAgABAoAAA==.',['�']='黄色体育生:AwAGCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end