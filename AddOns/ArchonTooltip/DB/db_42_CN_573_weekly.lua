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
 local lookup = {'Unknown-Unknown','Shaman-Enhancement','DeathKnight-Blood','DeathKnight-Unholy','Priest-Shadow','Warrior-Fury','Mage-Frost','Shaman-Restoration','Warrior-Protection','Rogue-Assassination','Warlock-Affliction','Warlock-Destruction','Paladin-Retribution','Priest-Holy','Rogue-Subtlety','Hunter-BeastMastery','Druid-Restoration','Hunter-Marksmanship','Paladin-Protection','Monk-Windwalker','Mage-Fire','Monk-Mistweaver','DemonHunter-Havoc','Priest-Discipline','Druid-Balance','Druid-Guardian','DeathKnight-Frost',}; local provider = {region='CN',realm='伊萨里奥斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Da='Dalila:AwAECAQABRQAAA==.Dantsty:AwAGCAYABAoAAA==.',Di='Diablic:AwAFCAUABAoAAA==.',Em='Emls:AwACCAIABAoAAA==.',He='Hellomrcxy:AwAGCAgABAoAAA==.',Ic='Ichliebejing:AwADCAMABAoAAQEAAAACCAMABRQ=.',Ls='Lsq:AwEECAQABRQAAQEAAAAICAMABRQ=.',My='Mydes:AwABCAEABRQAAA==.',Re='Rearso:AwAECAQABRQAAA==.',Ss='Ssriverns:AwAECAQABRQAAQIAM3YICAkABRQ=.',Ti='Timetodie:AwACCAQABRQDAwAIAQjYKgAZfgkBBAoAAwAIAQjYKgAZfgkBBAoABAABAQhvtQACSg0ABAoAAA==.Timetogo:AwACCAIABRQAAA==.',To='Tomoa:AwAECAQABRQAAQUAN6oGCAgABRQ=.',Yu='Yukirito:AwACCAMABRQCBgAIAQiiGABCYi8CBAoABgAIAQiiGABCYi8CBAoAAA==.',['�']='一副筱熊样:AwAICAgABAoAAA==.一副魈熊样:AwADCAEABRQAAA==.万雪孤城:AwACCAQABRQCBwAIAQj6DwBR42ECBAoABwAIAQj6DwBR42ECBAoAAA==.三分斋院:AwAECAQABRQAAA==.不知强不强力:AwACCAcABRQCCAACAQhGDgBcudgABRQACAACAQhGDgBcudgABRQAAQEAAAAGCAIABRQ=.不良丶懵智:AwABCAIABRQCCQAIAQgCBQBQv24CBAoACQAIAQgCBQBQv24CBAoAAA==.不良灬教父:AwAGCAwABAoAAA==.不要战猎萨啦:AwABCAEABRQAAA==.不鸣鸦山:AwACCAIABRQAAA==.东岳大帝:AwAECAIABRQAAA==.丨宁静雨丨:AwAICAgABAoAAA==.丨汞丨:AwACCAMABRQCCgAIAQgNDgBPMxQCBAoACgAIAQgNDgBPMxQCBAoAAA==.丨闹灬闹丨:AwABCAEABRQAAA==.',['�']='停止吃药:AwACCAcABRQDCwACAQjaDwAdSooABRQACwACAQjaDwAdQooABRQADAABAQgjLQAIDi4ABRQAAA==.',['�']='光铸蛋壳:AwAICAMABAoAAA==.八倍镜:AwACCAUABRQCDQACAQiiKgAuX5EABRQADQACAQiiKgAuX5EABRQAAA==.公子素:AwADCAMABAoAAA==.',['�']='冰河水寒:AwAICAkABAoAAA==.',['�']='减伤要开阿:AwAECAwABRQDDgAEAQiBCAArCNcABRQADgAEAQiBCAArCNcABRQABQABAQhdHAAc1UsABRQAAA==.',['�']='初秋夏末:AwAECAQABRQAAA==.刹那丶奥义:AwAGCAYABAoAAA==.',['�']='医学家陈二迅:AwACCAcABRQDCgACAQhJCwA+5KkABRQACgACAQhJCwA+5KkABRQADwACAQiZCwAqk5UABRQAAA==.',['�']='十月的肖邦:AwACCAIABRQCBwABAQirFABAUkcABRQABwABAQirFABAUkcABRQAAA==.千纸樱:AwAECAQABRQAAA==.卓文飘丶:AwAFCAYABAoAAA==.',['�']='厉倾城:AwAECAIABAoAAA==.',['�']='和风之弦:AwAHCAYABAoAAA==.咏舒:AwAECAQABRQAAA==.',['�']='哎择邋蟖:AwAFCAkABAoAAA==.',['�']='囍龘龘:AwAECAQABAoAAA==.回头無岸:AwAGCBsABAoCEAAGAQiAWgBIHnIBBAoAEAAGAQiAWgBIHnIBBAoAAA==.',['�']='塞纳瘤斯哇咔:AwAECAQABRQAAREAPyYICAsABRQ=.',['�']='墙外闻花香:AwAFCAYABAoAAA==.',['�']='夜猎潘:AwACCAYABRQCEgACAQgdDQBVHLgABRQAEgACAQgdDQBVHLgABRQAAA==.大丶猫:AwAECAYABRQCDQAEAQhfDgBAyAcBBRQADQAEAQhfDgBAyAcBBRQAAA==.大宇宙:AwAECAIABRQAAA==.大领主棒子:AwACCAMABRQDDQAIAQjPLgBRuEYCBAoADQAIAQjPLgBRuEYCBAoAEwABAAgAAAABAAAABAoAAA==.',['�']='妮莉绵糖:AwAICAYABAoAAA==.',['�']='安安不摸低保:AwACCAIABAoAAA==.宿醉女皇:AwABCAEABRQAAA==.',['�']='射射死你:AwACCAcABRQCEAACAQjgHQBKna0ABRQAEAACAQjgHQBKna0ABRQAAA==.射的漂亮:AwABCAEABRQAAA==.小米丿风:AwAGCAYABAoAAA==.尛尛园:AwAGCAQABAoAAA==.',['�']='布鲁斯壳:AwAGCAYABAoAARQALVwGCAoABRQ=.帅气唐哒哒:AwAGCAgABRQCFQAGAQgAAgA58s0BBRQAFQAGAQgAAgA58s0BBRQAAA==.帅熊猫:AwAICBUABAoCFgAIAQhANAAkMFgBBAoAFgAIAQhANAAkMFgBBAoAAA==.帕秋莉:AwABCAEABRQAAA==.',['�']='幽灵公主:AwAICBgABAoCFwAIAQgBQAAhtIABBAoAFwAIAQgBQAAhtIABBAoAAA==.',['�']='弥林女王:AwAGCAYABAoAAA==.',['�']='彦祖没我一半:AwABCAEABRQAAA==.',['�']='德拉古:AwAECAQABRQAAA==.',['�']='怒从心头起:AwAGCAYABAoAAA==.',['�']='我没有疯:AwAECAQABRQAAA==.战渣:AwABCAEABRQAAA==.战狼中队长:AwAECAQABRQCDQAIAQjlHgBRjYUCBAoADQAIAQjlHgBRjYUCBAoAAA==.戴娜碧桑:AwAECAQABAoAAA==.',['�']='折翼灬天使:AwACCAMABRQDEAAIAQh8IwBN60wCBAoAEAAIAQh8IwBN60wCBAoAEgAGAQgvLQAwQz8BBAoAAA==.',['�']='拓跋衅:AwAECAQABRQAAA==.',['�']='放弃治疗:AwACCAcABRQCGAACAQjJCQBiK+YABRQAGAACAQjJCQBiK+YABRQAAA==.',['�']='斐济:AwACCAQABRQCDQAIAQhFGwBUhZQCBAoADQAIAQhFGwBUhZQCBAoAAA==.',['�']='昆山夜光:AwAICAgABAoAAA==.昊天大帝:AwAECAQABRQAAA==.星痕翼:AwAGCBEABAoAAA==.星辰灬泪:AwAGCAEABAoAAA==.春日阳光:AwAECAQABAoAAA==.',['�']='普渡众牲:AwACCAQABRQCDQAIAQirGQBaHJwCBAoADQAIAQirGQBaHJwCBAoAAA==.普渡終生:AwACCAIABRQAAA==.',['�']='暗桑:AwAGCAkABAoAAA==.',['�']='曦升暮落:AwACCAUABRQEGQACAQi7IgAKmmAABRQAGQACAQi7IgAHk2AABRQAEQABAQiuHgAEiisABRQAGgABAQgpBgAP8CsABRQAAA==.',['�']='月满拦江:AwACCAIABAoAAA==.月野兔丶:AwACCAIABRQAAA==.未知:AwACCAIABAoAAA==.',['�']='桀骜斯达瑞:AwAFCAUABAoAAQYAX4wDCA0ABRQ=.桜吹雪:AwAICBcABAoDFQAIAQhJPAA2ZocBBAoAFQAIAQhJPAAxjYcBBAoABwAFAQgrWwA2y8wABAoAAA==.桶木饭吃猪排:AwAGCBgABAoDBwAGAQjsOABA31sBBAoABwAGAQjsOABA31sBBAoAFQADAQgwfwAglmgABAoAAA==.',['�']='椎名真由里:AwAECAQABRQAAA==.',['�']='楼外青楼:AwACCAUABRQCEwACAQh3DgARnV0ABRQAEwACAQh3DgARnV0ABRQAAA==.',['�']='江城绝恋:AwABCAEABAoAAA==.汤晓晓:AwAICAgABAoAAA==.',['�']='沐沐爸爸:AwACCAIABRQAAA==.没得意思:AwAECAQABRQAARUATGUGCAoABRQ=.没有密码猎手:AwACCAIABRQAAA==.',['�']='海军萨满:AwACCAMABRQAAA==.',['�']='灰色星域:AwAICAsABAoAAA==.',['�']='爱蓝莓酱辰辰:AwACCAMABRQAAA==.',['�']='牧云兮:AwABCAEABRQAAA==.',['�']='猎阳帝君:AwAECAgABRQDEgAEAQiaBgBQwPIABRQAEgAEAQiaBgBHK/IABRQAEAACAQg1GwBM3r4ABRQAARAAIV4GCAYABRQ=.猫南北丨:AwAECAQABRQAAA==.',['�']='玉爪:AwAICBAABAoAAA==.王大花:AwAFCAYABAoAAA==.王缇:AwAECAQABRQAAA==.',['�']='珍珠百香果:AwAICAgABAoAAA==.',['�']='甘露润万物:AwABCAIABRQAAA==.甜皮鸭:AwAICAwABAoAAA==.生生:AwAFCAkABAoAAA==.',['�']='白日出没:AwADCAYABRQCCQADAQj2AwAiVrUABRQACQADAQj2AwAiVrUABRQAAA==.',['�']='皮皮御风箭:AwAGCBIABAoAAA==.',['�']='真真胖真:AwAICAgABAoAAA==.',['�']='矮骑潘:AwAECAQABAoAAA==.',['�']='破壁榨汁机:AwAICBcABAoCDQAIAQg6aAAty6MBBAoADQAIAQg6aAAty6MBBAoAAA==.',['�']='糖果爸爸:AwAGCAoABRQCAgAEAQipAwBMCiYBBRQAAgAEAQipAwBMCiYBBRQAAA==.',['�']='织雾者肖:AwAICA0ABAoAAA==.绵绵:AwAGCAQABAoAAA==.',['�']='翔之天空:AwAECAQABRQAAA==.',['�']='老兵羽殇:AwAICA4ABAoAAA==.',['�']='肥猫转世:AwACCAIABAoAAA==.肥美肉块:AwABCAEABRQAAA==.',['�']='艾格希尔:AwAGCAgABRQCAwAGAQgjAgArAVEBBRQAAwAGAQgjAgArAVEBBRQAAA==.艾薇莉娅:AwAICAUABAoAAA==.',['�']='花信:AwAICAYABAoAAA==.花月正春风:AwACCAUABRQEBAACAQhfGAA5m5IABRQABAACAQhfGAAmepIABRQAGwABAQg7BgA7w0kABRQAAwABAQjFHQAFeicABRQAAA==.',['�']='苏无名:AwACCAEABRQAAA==.',['�']='落叶飘扬:AwAHCAMABAoAAA==.落叶飞扬:AwAICAsABAoAAA==.',['�']='贫尼法号灭绝:AwAGCAsABAoAAA==.',['�']='辉煌骑士:AwAGCAYABAoAAQEAAAAGCAIABRQ=.达摩院玄悲:AwAGCAIABRQAARQAIYsICAYABRQ=.',['�']='道友聊聊缘:AwAECAQABRQAAA==.',['�']='酒酿小元宵:AwACCAIABRQAAQEAAAACCAMABRQ=.',['�']='釩丶釩:AwACCAcABRQCAwACAQiyFQAbd2sABRQAAwACAQiyFQAbd2sABRQAAA==.',['�']='钰瑶公主:AwACCAIABAoAAA==.',['�']='铁胆翻车侠:AwADCAQABRQAAA==.',['�']='闻人尭月:AwAFCAUABAoAAA==.闻人灬牧月:AwACCAIABAoAAA==.',['�']='队丨长:AwAFCAkABAoAAA==.阿诗法拉诺:AwAGCAsABAoAAA==.',['�']='雙雙:AwABCAEABRQDDgAGAQg/TQAdyNUABAoADgAGAQg/TQAchNUABAoAGAACAQiVeAAHqjwABAoAAA==.雨淋夏末:AwAGCAMABAoAAA==.',['�']='霁月难逢:AwAECAoABRQCCAAEAQi6BwBAnQIBBRQACAAEAQi6BwBAnQIBBRQAAA==.',['�']='顶级鸡工一号:AwAECAQABRQAAA==.',['�']='风雅:AwACCAIABAoAAA==.风雷法王:AwAECAQABRQAAA==.飞将军:AwAFCAEABAoAAA==.',['�']='黑铁狼之:AwACCAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end