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
 local lookup = {'Warrior-Fury','Priest-Shadow','Priest-Discipline','DemonHunter-Vengeance','Warrior-Protection','Monk-Brewmaster','Unknown-Unknown','DeathKnight-Melee','DeathKnight-Unholy','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Affliction','Warlock-Destruction','Druid-Balance','Shaman-Restoration','DeathKnight-Blood','Paladin-Retribution','Warlock-Ranged','DemonHunter-Havoc','Priest-Holy','Rogue-Subtlety','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='巴瑟拉斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aaliyah:AwAECAQABAoAAA==.',Am='Ame:AwACCAIABAoAAA==.',Bi='Bingoo:AwADCAMABAoAAA==.',Ev='Evangel:AwAGCAYABAoAAA==.',Fe='Fear:AwAGCAYABAoAAA==.',La='Latonia:AwAICAoABAoAAA==.',Pa='Patent:AwABCAMABRQAAA==.',Ra='Rainning:AwACCAMABRQCAQAIAQh1GgBBtCICBAoAAQAIAQh1GgBBtCICBAoAAA==.',Sh='Shawnmendes:AwADCAMABRQAAA==.',['�']='不加糖:AwAGCAwABRQDAgAGAQhDAQBC/LsBBRQAAgAGAQhDAQBC/LsBBRQAAwADAQj0DwBUL6wABRQAAA==.不睡觉的熠:AwAGCAoABAoAAA==.东古诺:AwACCAIABRQAAA==.两脚发软:AwAICAgABAoAAA==.丶厨子:AwAICBYABAoCBAAIAQiYEABIj+4BBAoABAAIAQiYEABIj+4BBAoAAA==.丶小饼干:AwAGCAYABRQCBQAGAQjFAAAh2UwBBRQABQAGAQjFAAAh2UwBBRQAAA==.丷麦辣鸡腿堡:AwADCAYABAoAAA==.举火烧天:AwAFCAUABAoAAA==.',['�']='乇從妗以後乇:AwABCAEABAoAAA==.九尺鹅肠:AwAECAQABRQAAA==.',['�']='交幻機:AwAICAYABAoAAA==.',['�']='他只是男闺蜜:AwAGCAgABRQCBgAEAQidAQBM7vgABRQABgAEAQidAQBM7vgABRQAAA==.',['�']='你跺你也麻:AwAHCAIABAoAAA==.',['�']='修纙道:AwABCAEABRQAAA==.',['�']='八级小狂風:AwAICA4ABAoAAQcAAAAICAMABRQ=.公正之手:AwACCAIABAoAAA==.',['�']='咕咕复咕咕:AwAHCBAABAoAAA==.咖啡丶那么苦:AwAICAQABAoAAA==.',['�']='哎呀灬蛇:AwAECAMABRQCCAADAAgAAAA6cwAABRQACQADAAgAAAA6cwAABRQAAA==.',['�']='嗜血护术宝:AwACCAIABRQAAA==.',['�']='四夕女青文:AwACCAIABRQAAQoAVZkICAIABRQ=.团团子:AwAICA0ABAoAAA==.',['�']='圣奶士:AwAHCAUABAoAAA==.',['�']='坏男人之冷:AwACCAMABRQAAA==.',['�']='墨瞳丶嘿嘿:AwADCAYABAoAAA==.',['�']='女王驾到:AwAGCAoABAoAAA==.好名字都没啦:AwAGCAYABAoAAA==.',['�']='妈个牛佬:AwABCAEABAoAAA==.',['�']='小小西:AwABCAEABAoAAA==.小小西紫:AwAECAQABRQAAQcAAAAGCAQABRQ=.尐聖骑:AwAECAQABRQAAA==.',['�']='弹葱丶:AwAECAQABAoAAA==.',['�']='念雪慕鸿:AwAECAoABRQDCwAEAQjOEgBAFe4ABRQACwAEAQjOEgBAFe4ABRQADAACAQjMFAAnTWwABRQAAA==.',['�']='惩戒之神:AwACCAIABRQAAA==.',['�']='我是叫来的人:AwAICAgABAoAAA==.',['�']='拉鸡游戏:AwAECAYABRQDDQAEAQi2AwA8NgkBBRQADQAEAQi2AwA8NgkBBRQADgABAQgfKAAqiTwABRQAAA==.',['�']='放开一只羊:AwAECAQABRQAAA==.',['�']='救赎哥:AwAECAQABRQAAA==.教主万紫千橙:AwACCAIABRQAAA==.',['�']='无心无竹:AwABCAEABAoAAA==.',['�']='曾耐超:AwAGCAEABAoAAA==.',['�']='最爱吃兽奶:AwAFCAUABAoAAA==.有点乖:AwAECAIABRQAAA==.有点呆:AwAECAIABRQAAA==.木仓:AwAGCAYABRQCDAAGAQh3AAAqo4UBBRQADAAGAQh3AAAqo4UBBRQAAA==.木子:AwAGCAQABRQAAA==.机智萨哟:AwAGCAgABAoAAA==.',['�']='松下守莎:AwAICAcABAoAAA==.',['�']='枫枼:AwACCAIABRQAAA==.',['�']='梦想之名:AwAECAIABRQAAA==.梨花先雪丶:AwAECAQABRQAAA==.',['�']='武田信玄:AwAGCAwABAoAAA==.',['�']='比狗还要菜:AwAECAQABRQAAA==.',['�']='永恒封冰:AwACCAMABAoAAA==.',['�']='洒家来一发:AwAICAkABAoAAA==.',['�']='浅一葬花:AwAGCA4ABRQCDwAGAQi/AAA+SrsBBRQADwAGAQi/AAA+SrsBBRQAAA==.浮云骑神马:AwACCAIABRQAAA==.海月白灵:AwABCAEABRQAAA==.海棠朵朵:AwAHCAcABAoAAA==.',['�']='灬紫了葡萄灬:AwADCAwABRQDEAADAQjxFwAvLJcABRQAEAACAQjxFwA455cABRQACgABAQhfFwAElDgABRQAAA==.',['�']='炉石萌新别打:AwACCAIABRQAAA==.炫顿自助:AwAFCAkABAoAAA==.',['�']='烟丶瘾:AwACCAIABRQAAA==.',['�']='煌竹:AwAGCAoABRQDAgAGAQiZAQA1BasBBRQAAgAGAQiZAQA1BasBBRQAAwAEAQjKCgAx5NwABRQAAQcAAAAICAIABRQ=.',['�']='爆浆麻薯:AwACCAUABRQCAQACAQj7EQBR1sIABRQAAQACAQj7EQBR1sIABRQAAA==.爱美女的菠萝:AwACCAQABRQAAA==.',['�']='狩猎阝灬:AwAFCAUABAoAAA==.',['�']='猪皮扫地僧:AwAHCA0ABAoAAA==.',['�']='玛丽罗斯:AwAECAUABRQCEQAEAQiOHwAq6gAABRQAEQAEAQiOHwAq6gAABRQAAA==.',['�']='白衣未央:AwAICAgABAoAAA==.',['�']='真正的鳗:AwAGCBEABAoAAA==.',['�']='睿智毛线球:AwAECAQABAoAAA==.',['�']='精神小伙:AwAECAQABRQAAA==.',['�']='纯吊:AwAECAIABRQAAA==.纯爱战神:AwAGCAwABAoAAA==.',['�']='给你吗一拳:AwAICAkABAoAAA==.给力有木有:AwAFCAQABAoAAA==.给色个:AwADCAMABRQAAA==.',['�']='羊大仙儿:AwAECAUABRQCEgAEAQhfEwA9avQABRQAEgAEAQhfEwA9avQABRQAAA==.羊大先:AwAECAQABRQAAA==.美人泪杯中酒:AwACCAIABAoAAA==.',['�']='老二在前面:AwAECAQABRQAARMAX24GCAYABRQ=.老司机的阴谋:AwACCAIABRQCDAAIAQjbEQA/ixQCBAoADAAIAQjbEQA/ixQCBAoAAA==.考拉酱:AwAGCAsABAoAAA==.',['�']='膝盖杀手:AwABCAEABAoAAA==.',['�']='芝士发丝:AwACCAIABAoAAA==.',['�']='苦逼的他:AwAGCAwABAoAAA==.',['�']='蒲尼阿摩:AwAICAgABAoAAA==.',['�']='薇尔莉特:AwAGCAcABRQCFAAEAQj2CwBIbgABBRQAFAAEAQj2CwBIbgABBRQAAA==.薩菲羅斯丶:AwAECAQABAoAAA==.',['�']='蜡笔丨小刚:AwABCAEABRQAAA==.蜡笔丨小新:AwAHCAwABAoAAA==.蜡笔丨小旧:AwAHCAgABAoAAA==.',['�']='血无情:AwABCAEABAoAAA==.血色灰壗:AwABCAEABRQAAA==.',['�']='请你忘了我:AwAECAQABRQAAA==.',['�']='超人强:AwAGCA4ABAoAAA==.',['�']='迟迟:AwAECAQABRQAAA==.迷雾:AwAICA4ABAoAAA==.',['�']='邪灵之怒:AwAECAQABAoAAA==.',['�']='野风涉:AwAECAgABRQDFQAEAQheAgBVCiMBBRQAFQAEAQheAgBVCiMBBRQAAwAEAQhGDAAmZdEABRQAAA==.',['�']='阿可蒙德之眼:AwAECAYABRQCDgAEAQg1CABKLf0ABRQADgAEAQg1CABKLf0ABRQAAA==.',['�']='雪冷萃:AwAECAQABRQAAA==.雪后初晴:AwAECAMABRQAARYAO5AGCAkABRQ=.雾仙人:AwAGCAgABRQDFwAGAQjsAAA79dgBBRQAFwAGAQjsAAA79dgBBRQAGAACAQiRGwAbVn4ABRQAAA==.',['�']='驯狐师:AwAICA0ABAoAAA==.',['�']='魔力毁灭:AwABCAEABRQCDgAIAQi4HwA6JfEBBAoADgAIAQi4HwA6JfEBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end