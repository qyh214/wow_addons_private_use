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
 local lookup = {'Hunter-Marksmanship','Evoker-Devastation','Unknown-Unknown','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Balance','Mage-Fire','Hunter-BeastMastery','Monk-Windwalker','Warrior-Arms','Shaman-Restoration','Paladin-Retribution','Shaman-Elemental','DeathKnight-Blood','Paladin-Protection','Paladin-Holy','Priest-Holy','Priest-Shadow','DeathKnight-Unholy','Warrior-Fury','Warlock-Ranged','Warlock-Demonology','Mage-Frost','Priest-Discipline','Warlock-Destruction','Monk-Mistweaver','Warlock-Affliction','Druid-Restoration',}; local provider = {region='CN',realm='拉文凯斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Aibu:AwAECAQABRQAAA==.',As='Astraeus:AwAECAYABRQCAQAEAQiICQAtodsABRQAAQAEAQiICQAtodsABRQAAA==.Astrasolaire:AwAHCAcABAoAAA==.',Az='Azorian:AwACCAYABRQCAgACAQgSEQAxsY0ABRQAAgACAQgSEQAxsY0ABRQAAA==.',Ce='Cervidae:AwAFCAUABAoAAA==.',Di='Diospada:AwACCAMABRQAAA==.',Dr='Dreamful:AwADCAQABRQAAA==.',Ho='Hok:AwAGCA4ABAoAAA==.Homie:AwAHCAoABAoAAQMAAAABCAEABRQ=.',Ju='Justwe:AwAHCAgABAoAAA==.',Ka='Karkrand:AwADCAMABAoAAA==.Karna:AwADCAMABAoAAA==.',Li='Lili:AwACCAMABAoAAA==.',Na='Naga:AwABCAEABRQAAA==.',No='Noisiness:AwAICB0ABAoDBAAIAQhxHgAn+1cBBAoABAAIAQhxHgAnolcBBAoABQAEAQghfgApFJgABAoAAA==.',Pa='Paulyuan:AwAECAQABRQAAQYAMh4GCAoABRQ=.Paulyums:AwAICAYABAoAAQMAAAAGCAIABRQ=.',Ri='Rias:AwAGCAQABRQAAQMAAAAICAIABRQ=.',Sy='Sylaryui:AwAICAoABAoAAA==.',To='Toolman:AwABCAEABRQAAA==.',['�']='一只修狗:AwADCAMABAoAAQcAPU4ICAkABRQ=.一只蛋黄丶:AwAECAUABRQCCAAEAQhcDgBAoQEBBRQACAAEAQhcDgBAoQEBBRQAAA==.一招升龙拳:AwABCAEABRQAAA==.一顿小点炮:AwAICAgABAoAAA==.七件夏天衫:AwACCAIABRQAAQMAAAAICAIABRQ=.七夜:AwAHCAsABAoAAA==.上官小小文:AwACCAMABRQAAA==.不惑似少年:AwAGCAcABAoAAA==.不是恐虐:AwACCAIABRQAAA==.与靑:AwAGCAQABRQAAA==.丑丒醜殠:AwABCAEABRQAAQkAKkoICAYABRQ=.两仪织:AwAGCBUABAoCCgAGAQjrFQBWRt0BBAoACgAGAQjrFQBWRt0BBAoAAA==.丶药:AwABCAEABRQAAA==.丷夏至丷:AwABCAEABRQAAA==.丷大琬丷:AwAECAUABRQCCwAEAQiqDgAf6NcABRQACwAEAQiqDgAf6NcABRQAAA==.丽丽大魔王丶:AwADCAMABAoAAQMAAAAFCAgABAo=.丿梓丶潇:AwAFCAQABAoAAA==.丿熊猫烧香乀:AwAGCAYABAoAAA==.',['�']='九熊:AwAECAQABRQAAA==.',['�']='京墨:AwAICAMABAoAAQwAVXMGCAoABRQ=.京樂:AwAICBEABAoAAA==.',['�']='仲夏夜之梦:AwAICAgABAoAAA==.',['�']='伊瑞尔丶卡拉:AwAECAIABRQAAA==.会计计算器:AwAECAQABRQAAA==.伦恩血蹄:AwACCAYABRQDCwACAQgPFABLJrAABRQACwACAQgPFABLJrAABRQADQABAQhIFgAUTT0ABRQAAA==.',['�']='佑佑是我外甥:AwAICAgABAoAAA==.',['�']='依乐:AwAGCAwABAoAAA==.依然尘嚣:AwAECAYABAoAAA==.',['�']='做自己该做的:AwAECAQABRQAAA==.',['�']='光环掌握:AwAECAIABRQAAA==.兔兔突:AwAECAQABRQAAA==.',['�']='冰点之鬻:AwAECAQABAoAAA==.',['�']='别奶丶要脸:AwAHCAYABAoAAA==.',['�']='加勒比野心:AwABCAEABAoAAA==.',['�']='半夏如烟:AwAECAQABAoAAA==.卓越一击雷神:AwAHCAYABAoAAA==.南极牛魔:AwAECAEABRQAAA==.南风雁:AwADCAMABAoAAA==.卡尔:AwABCAEABRQAAA==.',['�']='双子座的神话:AwABCAEABRQAAA==.',['�']='哈雷戴维森:AwAFCAUABAoAAA==.',['�']='噬魂丨女爻:AwAICAkABAoAAA==.',['�']='囊萤映雪:AwACCAIABRQAAQMAAAAECAQABRQ=.',['�']='土木鸡德:AwAICAMABAoAAA==.圣光大宝剑:AwAECAQABRQAAA==.圣泣:AwAECAQABRQAAA==.圣骑张三:AwAFCAYABAoAAA==.',['�']='多多趣多多:AwAECAQABRQAAQ4AY3oICAoABRQ=.夜乂色:AwABCAEABRQAAA==.大好人:AwAICBQABAoEDwAIAQjREwBGcqsBBAoADwAGAQjREwBO6KsBBAoADAAGAQj2iQA+DFUBBAoAEAACAQiFMABET6UABAoAAA==.大当家:AwACCAUABRQCDAACAQgpHgBcPscABRQADAACAQgpHgBcPscABRQAAA==.大战:AwACCAIABRQAAA==.大街上站岗:AwACCAQABRQAAA==.大跳踩到翔:AwAECAcABRQCCgAEAQg1BQAZXd0ABRQACgAEAQg1BQAZXd0ABRQAAA==.大飞老师:AwEICAoABAoAAREAWB0ECBAABRQ=.天使的心跳:AwACCAEABRQCEgAIAQgKEgBKWTYCBAoAEgAIAQgKEgBKWTYCBAoAAQMAAAAGCAEABRQ=.天海翼:AwACCAIABRQAAA==.',['�']='奔跑吧趙先森:AwAECAQABRQAAA==.奥卡休斯:AwAICAgABAoAAA==.好运天天有:AwADCAsABRQDEAADAQiEAgBPXBABBRQAEAADAQiEAgBPXBABBRQADAABAQh8QwAC6jsABRQAAA==.',['�']='姬美夕:AwADCAMABAoAAA==.',['�']='娇傲:AwAICBAABAoAAA==.',['�']='媳妇我想减肥:AwAGCAcABRQCCAAGAQgVAgAxGqABBRQACAAGAQgVAgAxGqABBRQAAA==.',['�']='宅大夫:AwACCAIABRQAAA==.安娜阿玛丽娅:AwACCAIABRQAAA==.',['�']='寒冬弥红:AwABCAMABRQCEwAIAQjTHwBE/hkCBAoAEwAIAQjTHwBE/hkCBAoAAA==.',['�']='封山育林:AwACCAMABRQAAA==.小只大萌德:AwEECAQABRQAAA==.小坚果:AwAFCAcABAoAAA==.小小妖儿:AwAGCAoABAoAAA==.小布丁:AwACCAQABRQDCwAIAQi4MgAsxpUBBAoACwAIAQi4MgAsxpUBBAoADQADAQiLbwAHODMABAoAAA==.小帆子:AwAFCAIABAoAAA==.小狗肖恩:AwAECAQABAoAAA==.小猪蹄子:AwACCAIABRQAAA==.',['�']='山水作画丶:AwACCAQABRQCDAAIAQj8EwBVFrUCBAoADAAIAQj8EwBVFrUCBAoAAA==.',['�']='布偶布偶:AwACCAIABRQAAA==.',['�']='年迈带病冲锋:AwAECAcABRQCFAAEAQheDAAvwvkABRQAFAAEAQheDAAvwvkABRQAAA==.',['�']='弥赛亞:AwADCAMABAoAAA==.',['�']='当局者迷:AwACCAMABRQAAA==.彭於晏:AwABCAEABAoAAA==.',['�']='微醺凉白开:AwAECAMABRQCFQADAAgAAABMswAABRQAFgADAAgAAABMswAABRQAAA==.',['�']='心若阑珊:AwAECAQABRQAAA==.',['�']='急躁:AwABCAEABRQAAA==.',['�']='恶性僧:AwAECAQABAoAAA==.恶魔毁灭者:AwADCAIABRQAAA==.',['�']='我心飘零:AwABCAEABRQAAA==.我是传奇:AwACCAQABRQDFwAIAQjEEgBHZkkCBAoAFwAIAQjEEgBHZkkCBAoABwAEAQibeQAT/XkABAoAAA==.战伯伯:AwACCAMABRQDFAAHAQjeOAA8wmwBBAoAFAAGAQjeOAA0UmwBBAoACgADAQimMQA9ffUABAoAAA==.',['�']='抹了油的蛛:AwADCAUABRQCDAADAQg6EgA/8vgABRQADAADAQg6EgA/8vgABRQAAA==.',['�']='挚丨爱:AwAGCAYABAoAAA==.',['�']='撒狼嘿呦:AwACCAEABRQAAA==.',['�']='放下个人素质:AwAECAMABRQAAA==.',['�']='故作矜持:AwAECAQABRQAAA==.数字信号处理:AwACCAMABRQAAA==.',['�']='无影之风:AwABCAEABRQAAA==.无才丶:AwAFCAUABAoAAA==.无敌是谁呀:AwACCAIABRQAAA==.',['�']='映萱:AwAECAUABRQDAQAEAQgzBgA7uPUABRQAAQAEAQgzBgA7uPUABRQACAABAQg+RAAAAAAABRQAAQMAAAAICAQABRQ=.',['�']='晚星纱:AwAGCAYABAoAAA==.',['�']='月之银铃丶:AwACCAIABRQAAA==.有时无语:AwACCAQABRQAAA==.',['�']='来誉酒馆保安:AwADCAMABAoAAA==.',['�']='橡皮泥小萨:AwAGCAcABAoAAA==.',['�']='死騎:AwABCAEABAoAAA==.',['�']='没扯淡:AwAFCAgABAoAAA==.',['�']='流颜洛水:AwAFCAUABAoAAA==.浅色流星丶:AwACCAIABRQAAA==.浜风风:AwACCAIABRQAAA==.',['�']='淡淡的微笑:AwAHCAgABAoAAA==.',['�']='温柔的大鸟:AwAICBAABAoAAQMAAAAGCAQABRQ=.',['�']='灬筱羞花:AwAHCAcABAoAAA==.',['�']='炒豆干儿:AwAECAQABRQAAA==.',['�']='烈火注定燃烧:AwAECAcABAoAAA==.热砂阿昆达:AwACCAIABRQAAA==.',['�']='熊熊酱:AwAICBQABAoDAQAIAQgkHQBPda0BBAoACAAGAQheRwBMC7QBBAoAAQAIAQgkHQBNWq0BBAoAAA==.',['�']='牢飞奇遇记:AwEECBAABRQEEQAEAQghCwBYHbwABRQAEQACAQghCwBUOrwABRQAGAADAQjADgBXubgABRQAEgABAQgCIAAHAD8ABRQAAA==.',['�']='犭夜叉:AwAECAMABRQAAQMAAAAGCAMABRQ=.',['�']='狂躁的小牛牛:AwAECAQABAoAAA==.',['�']='猎猎月:AwAECAsABRQCAQAEAQglAgBWGCUBBRQAAQAEAQglAgBWGCUBBRQAAA==.',['�']='甜心马卡龙:AwAECAQABAoAAA==.田伴仙:AwAFCAUABAoAARMAMUoICAgABRQ=.',['�']='留有余香:AwABCAEABRQAAA==.',['�']='白月丶:AwABCAEABRQAAA==.白米粒儿:AwAGCAMABAoAAA==.',['�']='皮卡丘灬:AwAFCAUABAoAAA==.皮城小蛋糕:AwAGCAYABAoAAA==.',['�']='等风来丶:AwABCAEABRQAAA==.',['�']='紫宸:AwADCAIABAoAAA==.紫色的紫:AwAHCAEABAoAAA==.紫鸢格格:AwAGCAIABRQAAA==.紸錠尐末:AwAECAgABRQCGQAEAQiXDgAl39IABRQAGQAEAQiXDgAl39IABRQAAA==.',['�']='红羽神弓:AwAECAQABRQAAA==.红肚兜:AwACCAQABRQAAA==.',['�']='维迪:AwABCAEABRQAAA==.绿冰:AwADCAkABRQDGgADAQi8EQBXLL4ABRQAGgACAQi8EQBSKL4ABRQACQACAQigCwBPCbkABRQAAA==.',['�']='羊咩珜:AwAGCAEABAoAAA==.羽川忍:AwAECAQABRQAAA==.',['�']='聖光不閃現:AwAICAIABAoAAA==.',['�']='胖可丁:AwADCAMABAoAAA==.胡校长:AwABCAEABRQAAA==.',['�']='舒肤佳洁士:AwAFCAYABRQCDAAFAQg2AQBUt6cBBRQADAAFAQg2AQBUt6cBBRQAAA==.',['�']='苏菲玛索丶:AwABCAEABAoAAA==.',['�']='茯苓:AwAECAgABRQCGAAEAQi8DwAM764ABRQAGAAEAQi8DwAM764ABRQAAA==.茵翠斯汀:AwAGCAoABAoAAA==.',['�']='蓝山丨香烟:AwABCAEABRQAAA==.蓝色马蹄莲:AwAECAcABAoAAA==.',['�']='虎虎生威:AwAFCAwABAoAAA==.虚弱的卡洛斯:AwACCAIABRQAAA==.',['�']='蚜蠛蝶:AwACCAcABRQDCwACAQidHgANpHgABRQACwACAQidHgANpHgABRQADQACAQiiEAAKOGsABRQAAA==.',['�']='血兽来了:AwAECAQABRQAAA==.',['�']='西琼艾儿:AwAECAQABRQAAA==.',['�']='豆孒包包:AwAGCAQABRQAAA==.',['�']='费资本:AwAGCAUABAoAAA==.',['�']='超级馒头:AwAECAQABRQAAA==.超级马莉:AwADCAMABAoAAA==.',['�']='蹲马步的猫:AwABCAEABRQAAA==.',['�']='辽警小龙:AwAECAQABRQAAA==.',['�']='还是大爷:AwAECAgABRQEGQAEAQhUCwA79uYABRQAGQADAQhUCwA79uYABRQAGwACAQjaGAAVlkUABRQAFgABAQi6FgAAAAAABRQAAA==.',['�']='邀月对影丶:AwACCAQABRQAAA==.',['�']='里巧儿:AwAICBAABAoAAA==.',['�']='铅笔:AwAECAQABAoAAA==.',['�']='长的真美:AwAGCAEABAoAAA==.',['�']='问悟悟问:AwAICAwABAoAAA==.',['�']='阳一禅:AwAICAgABAoAAA==.阿塔莎:AwAECAEABAoAAA==.阿弥陀丸:AwAGCAYABAoAAA==.阿拉蕾灬:AwAICAgABAoAAA==.',['�']='陈辰辰:AwAGCAwABRQDBgAGAQh7BABBzC4BBRQABgAEAQh7BABbWi4BBRQAHAAEAQhvBQAylvkABRQAAA==.',['�']='隨风漂泊:AwAICAkABAoAAA==.',['�']='霜的独奏:AwABCAEABRQAAA==.露娜:AwAECAQABRQAAA==.',['�']='青芍:AwAGCAYABAoAAA==.非你非非你:AwAECAQABRQAAA==.',['�']='风之若宇:AwAECAQABAoAAA==.风起天南:AwAECAUABAoAAQMAAAABCAEABRQ=.',['�']='高圆圆:AwAICAIABAoAAA==.',['�']='鬼鬼月:AwAECAQABRQAAA==.',['�']='魚胖:AwAICAQABRQAAA==.魚胖子:AwAECAEABRQCCwABAQhBLQAAAAAABRQACwABAQhBLQAAAAAABRQAAQMAAAAGCAEABRQ=.',['�']='鱼生:AwABCAEABAoAAQMAAAAECAIABRQ=.',['�']='麦克枪:AwAFCAUABAoAAA==.麻瓜:AwACCAIABAoAAA==.',['�']='龙息张三:AwACCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end