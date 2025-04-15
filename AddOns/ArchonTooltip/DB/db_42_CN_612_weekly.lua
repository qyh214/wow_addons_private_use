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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Unknown-Unknown','Shaman-Restoration','Paladin-Holy','Paladin-Protection','Shaman-Enhancement','Priest-Shadow','Priest-Discipline','Priest-Holy','Warlock-Destruction','Warlock-Affliction','Evoker-Devastation','Monk-Mistweaver','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-Survival',}; local provider = {region='CN',realm='图拉扬',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aaronluo:AwAFCAYABAoAAA==.',Ba='Bagandbag:AwAICA8ABAoAAA==.',Bu='Burnning:AwAGCAYABAoAAA==.Butterfly:AwAICAsABAoAAA==.',Da='Dante:AwAICAgABAoAAA==.',Es='Escanor:AwABCAIABRQAAA==.',Fa='Fayee:AwAGCAIABRQAAA==.',Fe='Feona:AwAECAQABRQAAA==.',Fo='Fountine:AwAECAQABRQAAA==.',Fy='Fyee:AwAGCAIABRQAAA==.',Jo='Johnnie:AwAICAgABAoAAA==.',Ma='Mandriva:AwADCAwABRQDAQADAQgGEAA8gPkABRQAAQADAQgGEAA5wvkABRQAAgABAQjWGAAt0EgABRQAAA==.',Me='Memoryfan:AwACCAIABRQAAQMAAAADCAMABRQ=.',Ne='Nedavil:AwAFCAkABAoAAA==.Newi:AwACCAUABRQCBAACAQg7GgAlZo4ABRQABAACAQg7GgAlZo4ABRQAAA==.',Ol='Ollie:AwAECAQABRQAAA==.',Pa='Pallas:AwABCAEABAoAAA==.',Sc='Scarab:AwAFCAUABAoAAA==.',Sl='Slayerholy:AwAECAQABRQAAA==.',Ta='Tan:AwAECAwABRQDBQAEAQgWAwBLKgUBBRQABQAEAQgWAwBLKgUBBRQABgAEAQh7BwAvkrgABRQAAA==.Taylormomsen:AwAICAgABAoAAA==.',['�']='一朵菊花台:AwAECAQABAoAAA==.一罐可乐:AwAHCAcABAoAAA==.一路闪电火花:AwAECAgABRQDBwAEAQgwBgAtHAcBBRQABwAEAQgwBgAtHAcBBRQABAAEAQi/EwAT1rMABRQAAA==.一鸽能不鸽嘛:AwAICAgABAoAAA==.七年丶:AwAICBAABAoAAQIAVdsICAgABRQ=.与光同尘:AwAICBMABAoAAA==.东尼大木:AwAGCAcABAoAAA==.',['�']='乌尔:AwAICAgABAoAAQgALwgICAwABRQ=.',['�']='仙女儿:AwACCAIABRQAAA==.仙踪林:AwAHCAcABAoAAA==.',['�']='会飞的蝙蝠:AwAGCAgABAoAAA==.传说呢袒克:AwACCAMABRQAAA==.',['�']='你们速度灭:AwAECAQABRQAAA==.',['�']='健康第一:AwAICAgABAoAAA==.',['�']='兰斯洛特:AwAFCAEABAoAAA==.',['�']='凯瑟琳灬冷月:AwACCAUABRQDCQACAQi1EwA8U48ABRQACQACAQi1EwAw548ABRQACgABAQhbGQA7eEQABRQAAA==.',['�']='刁得一:AwAGCAcABAoAAA==.',['�']='原则上可以:AwACCAUABRQDCwACAQiuIgApqUsABRQACwABAQiuIgBAG0sABRQADAABAQi1GAATN0UABRQAAA==.',['�']='古咕谷:AwACCAIABRQAAQMAAAAECAQABRQ=.',['�']='吉尔加郭:AwAFCAUABAoAAA==.吖姐:AwAECAMABRQAAA==.吼吼哈嘿:AwAECAQABRQAAA==.',['�']='哎丶可惜啊:AwAFCAYABAoAAA==.哒哒:AwAICA0ABAoAAA==.',['�']='唉丶怎么办:AwAECAIABAoAAA==.',['�']='圣光霓裳:AwACCAQABRQAAA==.',['�']='埃辛諾斯:AwAFCAUABAoAAA==.',['�']='塔宾斯:AwAFCAUABAoAAA==.',['�']='声微丶饭否:AwACCAMABAoAAA==.',['�']='大一武一生:AwAICBIABAoAAA==.',['�']='奈斩:AwACCAMABRQCDQAIAQgqFQA21+wBBAoADQAIAQgqFQA21+wBBAoAAA==.',['�']='如太阳般闪耀:AwAICAgABAoAAA==.妨弑代行:AwADCAQABAoAAA==.',['�']='宇文婷甄:AwAGCAYABAoAAA==.安奇揦:AwADCA8ABRQCDgADAQjUAgBjBV4BBRQADgADAQjUAgBjBV4BBRQAAA==.安奇翋:AwADCAMABAoAAA==.',['�']='小小舞深:AwABCAIABRQAAA==.小狐狸齐娜:AwAECAIABRQAAA==.尕崔:AwABCAEABAoAAA==.',['�']='山下游仙:AwAICAoABAoAAA==.',['�']='归来的梦:AwACCAMABRQCDwAIAQiaIQBDWQ4CBAoADwAIAQiaIQBDWQ4CBAoAAA==.',['�']='打擦有福利气:AwADCAcABRQCBAADAQijDQAlNdwABRQABAADAQijDQAlNdwABRQAAA==.托尼灬斯塔克:AwACCAIABRQAAA==.扛把子:AwAHCAYABAoAAA==.',['�']='拉风又拉怪:AwAECAgABRQDEAAEAQhJEwAzA94ABRQAEAAEAQhJEwAiKd4ABRQAEQACAQiFCQBBm5UABRQAAA==.拥抱圣光:AwADCAwABRQECAADAQjJBQBSVh4BBRQACAADAQjJBQBSVh4BBRQACQABAQi2HQAUDUIABRQACgABAQjdGgASOz8ABRQAAQMAAAAECAQABRQ=.',['�']='故人叹:AwAFCAkABRQCBgAFAQg6AgA/pEABBRQABgAFAQg6AgA/pEABBRQAAA==.',['�']='月之影影之海:AwAGCAEABAoAAA==.月之海:AwAHCAEABAoAAA==.月梦墨瞳:AwAECAQABRQAAA==.有点儿小鸡冻:AwAICBAABAoAAA==.',['�']='橙色小葡萄:AwAICA4ABAoAAA==.',['�']='欧尼坦:AwAGCAQABRQAAA==.欧贝利斯克:AwADCAYABRQCDQADAQhkDAAi+MYABRQADQADAQhkDAAi+MYABRQAAA==.',['�']='死亡龙心:AwAECAQABRQAAA==.',['�']='毒鬼:AwAGCAkABAoAAA==.',['�']='沃什大拉基:AwACCAQABAoAAA==.没了尾巴:AwAICAQABAoAAA==.',['�']='洛冰盈:AwAFCAUABAoAAA==.',['�']='浮生若梦:AwAECAQABAoAAA==.',['�']='玄隆隆:AwACCAMABAoAAA==.',['�']='琅戟努斯:AwAECAQABRQAAA==.',['�']='疯狂咕噜:AwABCAEABAoAAA==.疯狂噜噜:AwAGCAYABAoAAA==.',['�']='百花凌风:AwAFCAUABAoAAA==.百花哲芷:AwACCAQABRQCAQAIAQi4HgBIn2ICBAoAAQAIAQi4HgBIn2ICBAoAAA==.',['�']='真水:AwADCAMABAoAAA==.',['�']='祈爱漫无天际:AwAFCAwABAoAAA==.',['�']='箜箜小喃:AwADCAMABAoAAA==.',['�']='索科洛芙:AwAHCAkABAoAAA==.',['�']='绿火葬人间:AwAECAQABRQAAA==.',['�']='美雨:AwAGCA4ABAoAAA==.',['�']='肥肥师兄:AwAHCAgABAoAAA==.',['�']='脉冲米其林:AwAECAQABRQAAA==.脑袋尖尖的:AwABCAEABAoAAA==.',['�']='腐草为萤丶:AwADCAsABRQDAQADAQgmJAApKJcABRQAAQACAQgmJAAwjJcABRQAEgABAQi2AgAaYFgABRQAAA==.',['�']='艾熙:AwAECAQABRQAAA==.艾米:AwAGCAMABRQAAQ0AD08ICAUABRQ=.',['�']='草莓蛋糕:AwAICA4ABAoAAA==.荔枝桂圆:AwAFCAUABAoAAA==.',['�']='萨格顶顶:AwACCAIABRQAAA==.萨满大王:AwAECAQABRQAAA==.',['�']='蓝宝石:AwACCAIABRQAAA==.',['�']='轨迹丨:AwAFCAYABAoAAQcANYwGCBAABRQ=.',['�']='辛弗尼尔:AwAHCA8ABAoAAA==.',['�']='量子隧穿:AwACCAcABRQCDQACAQjWEgAmkXsABRQADQACAQjWEgAmkXsABRQAAA==.',['�']='镜流:AwACCAIABAoAAA==.长夜咏叹调:AwACCAIABAoAAA==.',['�']='隔壁老必:AwAICAgABAoAAA==.',['�']='雨后百合:AwADCAUABRQCEQADAQgVBAA1/dwABRQAEQADAQgVBAA1/dwABRQAAA==.雪冰儿:AwAGCAsABAoAAA==.',['�']='风萨:AwAICAEABAoAAA==.风辰:AwACCAIABRQAAA==.飞羽归尘:AwAICAgABAoAAA==.',['�']='麦戈文:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end