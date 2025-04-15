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
 local lookup = {'Monk-Mistweaver','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DeathKnight-Blood','Unknown-Unknown','Druid-Balance','Mage-Frost','Mage-Fire','Priest-Discipline','Paladin-Retribution','Paladin-Protection','DeathKnight-Unholy','Evoker-Devastation','Warrior-Fury','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','Evoker-Preservation','Shaman-Restoration','Monk-Windwalker','Shaman-Elemental','Rogue-Assassination','Mage-Arcane','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Shadow',}; local provider = {region='CN',realm='卡拉赞',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bo='Booming:AwAECAQABAoAAA==.',Ca='Catiman:AwADCAgABRQCAQADAQjiBABPkysBBRQAAQADAQjiBABPkysBBRQAAA==.Catman:AwAICBsABAoCAgAIAQjpEwA/vQACBAoAAgAIAQjpEwA/vQACBAoAAQEAT5MDCAgABRQ=.',Cu='Curelove:AwAICAsABAoAAA==.',Db='Dbtrkygaly:AwAFCAIABAoAAA==.',De='Demonlord:AwABCAEABRQEAwAIAQjeGwBIRQgCBAoAAwAIAQjeGwBIFQgCBAoABAAFAQj3JABDMxwBBAoABQABAQhmPQATxTUABAoAAA==.',Ei='Eictcle:AwADCAEABAoAAA==.',Gr='Grimbatore:AwADCAUABRQCBgADAQipDgAglqQABRQABgADAQipDgAglqQABRQAAA==.',Ha='Harry:AwAICAUABAoAAQcAAAAGCAIABRQ=.',Ko='Korvash:AwADCAMABAoAAA==.',Ma='Mako:AwAICAgABAoDCAAIAQiIVQBFySYBBAoACAAGAQiIVQBEcSYBBAoAAgACAQhKbQAJu0wABAoAAQcAAAAGCAIABRQ=.',Me='Medeargirl:AwACCAIABRQAAA==.',Ro='Rocsun:AwAICAIABAoAAA==.',Th='Thorn:AwAECAQABAoAAQcAAAAHCBAABAo=.',Tm='Tmoon:AwAHCAsABAoAAA==.',Vi='Vila:AwADCAUABRQDCQADAQiLCgAvfqIABRQACQACAQiLCgA7n6IABRQACgABAQgUMQAXPUQABRQAAA==.',['�']='一路贰到底:AwAICAgABAoAAA==.不会治疗的牧:AwAECAQABRQAAQsAUJsGCA4ABRQ=.丨糖丨:AwADCAcABRQCAwADAQhwEwAQd64ABRQAAwADAQhwEwAQd64ABRQAAA==.丨霸天虎丨:AwAECAQABRQAAA==.丫抢我爽歪歪:AwABCAEABRQAAA==.丶任羽逍遥:AwAECAQABRQAAA==.丶旺仔小馒头:AwAHCB4ABAoDDAAHAQiTbgBA9pUBBAoADAAHAQiTbgBA9pUBBAoADQAGAQhbMwAQpqAABAoAAA==.丿只会无敌:AwAICAoABAoAAQcAAAAECAQABRQ=.丿贪狼:AwAECAQABRQAAA==.',['�']='云缨:AwAGCAEABAoAAA==.',['�']='会飞的萝卜:AwAECAgABRQCCgAEAQgIHQAWt8AABRQACgAEAQgIHQAWt8AABRQAAA==.',['�']='偶尔的神:AwACCAIABRQAAA==.',['�']='兄弟情义重:AwACCAQABRQAAA==.八六年健力宝:AwAICCUABAoDDgAIAQhFFABQc2UCBAoADgAIAQhFFABQc2UCBAoABgAFAQgCOAAq87sABAoAAA==.养猪能手铁根:AwAICBIABAoAAA==.',['�']='冠辰:AwAICA4ABAoAAA==.',['�']='凉拌见手青:AwAECAQABRQAAA==.凶猛又天眞:AwADCAUABRQCDwADAQjmDAAdo8AABRQADwADAQjmDAAdo8AABRQAAA==.',['�']='劉二狗:AwABCAEABRQDDAAIAQhsFgBY6KoCBAoADAAIAQhsFgBY6KoCBAoADQACAQgVOAA6mooABAoAAA==.',['�']='千圣丶:AwAGCAEABAoAAA==.千年回忆:AwAICBUABAoDEAAIAQgsMAAqVKEBBAoAEAAIAQgsMAAjFqEBBAoAEQAHAQhqJAAjDVsBBAoAAA==.',['�']='古唲丹:AwACCAMABRQDBAAIAQisBgBKOEwCBAoABAAIAQisBgBKOEwCBAoAAwAGAQhWTQA4LBEBBAoAAA==.可燃冰绿茶:AwAGCAEABAoAAA==.',['�']='吥好吥坏:AwADCAMABRQAAQcAAAAGCAQABRQ=.吼吼哦哦:AwACCAIABRQAAA==.',['�']='因幡巡:AwAECAYABAoAAA==.',['�']='圆滚滚萨:AwAICAgABAoAAA==.',['�']='堕落丨灬信仰:AwADCAUABRQDEgADAQi1FwAhn9kABRQAEgADAQi1FwAhn9kABRQAEwABAQgYGgAyXUMABRQAAA==.',['�']='备用牛排:AwADCAUABRQDAgADAQgzCgAcArkABRQAAgADAQgzCgAcArkABRQACAACAQj6JAAD7k8ABRQAAA==.天之降临:AwAGCAEABAoAAA==.天命之人:AwAHCAEABAoAAA==.天翔龙闪:AwAICAgABAoAAA==.',['�']='女拳:AwACCAIABAoAAA==.女拳击手:AwAICA4ABAoAAA==.',['�']='妈妈省的:AwADCAQABAoAAA==.',['�']='威廉迪特:AwAHCAcABAoAAA==.',['�']='孤狼的挽歌:AwACCAQABRQDEgAHAQiLFwBd+YgCBAoAEgAHAQiLFwBd+YgCBAoAEwABAQiVagBDxjoABAoAAA==.',['�']='安卡拉刚:AwAGCAoABAoAAA==.安颜:AwAICBQABAoCDAAIAQjdKQBY3lkCBAoADAAIAQjdKQBY3lkCBAoAAA==.宸谐音尘:AwAECAQABRQAAA==.',['�']='小小马奇士:AwACCAQABRQAAA==.小尛花:AwAECAgABRQCFAAEAQhoBQAyDuIABRQAFAAEAQhoBQAyDuIABRQAAA==.小浣龙:AwAECAYABRQCFQAEAQhOAwApgMcABRQAFQAEAQhOAwApgMcABRQAAA==.小浪蹄子丶:AwAHCBAABAoAAA==.小灬天:AwAECAQABRQAAA==.小灰蝶:AwAECAEABRQAAA==.小白菇凉丶:AwAECAQABRQAAA==.尐翾:AwACCAQABRQAAA==.少年游:AwABCAEABRQCEgAIAQikEABavK4CBAoAEgAIAQikEABavK4CBAoAAA==.',['�']='左在存:AwACCAMABRQAAA==.',['�']='帅七七丶:AwADCAMABAoAAA==.',['�']='平衡动力学:AwACCAUABRQCAQACAQiSHAAMInQABRQAAQACAQiSHAAMInQABRQAAA==.',['�']='开在太阳下丶:AwAGCAYABRQCDgAGAQj/AAA0pbgBBRQADgAGAQj/AAA0pbgBBRQAAA==.强力萨满:AwAICBYABAoCFgAIAQjXIwA6Ld0BBAoAFgAIAQjXIwA6Ld0BBAoAAQcAAAADCAMABRQ=.',['�']='影魂丨:AwADCAUABRQCDAADAQiJAwBfaEYBBRQADAADAQiJAwBfaEYBBRQAAA==.',['�']='德胜:AwAICAYABAoAAA==.德鲁狂人:AwABCAEABAoAAA==.',['�']='心之航海图:AwAECAQABRQAAA==.志在止戈:AwAHCAUABAoAAA==.',['�']='我没有单抬:AwABCAEABRQAAA==.',['�']='抹茶小懒:AwAGCAkABAoAAA==.',['�']='拳頭妹妹丶:AwAFCAsABAoAAA==.',['�']='挥剑舞忧伤:AwAECAQABRQAAA==.',['�']='放电的牛奶奶:AwACCAIABAoAAA==.',['�']='斩炎丶:AwACCAIABRQAAA==.施翮:AwABCAEABAoAAA==.',['�']='无心灬残月:AwABCAEABRQAAA==.',['�']='末影暮色:AwACCAUABRQCFwACAQh1DABMXasABRQAFwACAQh1DABMXasABRQAAA==.术业专攻:AwAFCA4ABAoAAA==.',['�']='果滋果心:AwACCAIABRQAAA==.枪乄火:AwADCAMABRQAAA==.',['�']='梁志超的奶奶:AwAFCAgABAoAAA==.',['�']='母鸡啊:AwAECAUABAoAAA==.',['�']='永不停日:AwAECAQABAoAAA==.',['�']='沐川內枯:AwAECAcABRQDEAAEAQgFEQBd3c8ABRQAEAAEAQgFEQBd3c8ABRQAEQABAQhQEABEM1kABRQAAA==.没糖的周末丶:AwACCAUABRQCCgACAQiwIQA7+Z0ABRQACgACAQiwIQA7+Z0ABRQAAA==.',['�']='淡慕:AwAGCAYABAoAAA==.',['�']='灬呼哈灬:AwAHCAwABAoAAA==.',['�']='烟雨流年灬:AwAECAQABRQAAA==.烽谐大刚:AwADCAUABRQCDgADAQjIBwBJowYBBRQADgADAQjIBwBJowYBBRQAAQcAAAAGCAIABRQ=.',['�']='爱吃土豆丝:AwADCAQABAoAAA==.爷傲奈我何:AwAICAcABAoAAA==.',['�']='牛肉面:AwACCAQABRQCEwAIAQiGDQBdW0QCBAoAEwAIAQiGDQBdW0QCBAoAAQ8AKG8FCAUABRQ=.',['�']='狐尔萨斯:AwAICAgABAoAAA==.独孤月影:AwAECAQABAoAAA==.狮子歌歌:AwAICAYABAoAAA==.',['�']='王淳煜:AwADCAQABAoAAA==.现场直播:AwACCAQABRQDEQAIAQj2GwBWo6UBBAoAEQAFAQj2GwBQ4aUBBAoAEAAEAQhwSgBXJQwBBAoAAA==.',['�']='珈灬珈:AwADCAIABAoAAA==.',['�']='疯狂屠戮:AwABCAEABAoAAA==.',['�']='白鸽乌鸦:AwADCAMABAoAAA==.',['�']='看看啊:AwACCAMABRQAAA==.',['�']='碳烤小黄牛:AwAECAIABRQAARgAVZkICAIABRQ=.',['�']='笔墨染流年:AwAECAQABRQCDAAIAQjuHABaJo0CBAoADAAIAQjuHABaJo0CBAoAAA==.',['�']='等你下钟:AwADCAcABRQCEAADAQiKFAAzxK0ABRQAEAADAQiKFAAzxK0ABRQAAA==.',['�']='糖棉花:AwADCAUABRQCGQADAQiBBgAxC/QABRQAGQADAQiBBgAxC/QABRQAAA==.糖糖果:AwACCAUABRQCDAACAQjgLQAiDYkABRQADAACAQjgLQAiDYkABRQAAA==.',['�']='紫禁摇摆:AwAECAQABRQAAA==.',['�']='缔造辉煌:AwACCAIABRQAAA==.缶夬彳惪:AwAGCAoABAoAAA==.',['�']='老子是个狐狸:AwADCAMABAoAAA==.',['�']='艾莉娅史塔克:AwAECAQABRQAAA==.艾莎妮娅逐星:AwACCAMABRQAAA==.',['�']='芝士聋人:AwAFCAUABRQCDwAFAQjaAgAob0sBBRQADwAFAQjaAgAob0sBBRQAAA==.芬必德:AwAICBEABAoAAA==.花無凋零之時:AwADCAMABRQAAA==.芹菜:AwAGCAQABRQAAA==.',['�']='苏誉:AwAGCAYABAoAAA==.英维安娜:AwAECAcABRQCDAAEAQgqFAAwJPIABRQADAAEAQgqFAAwJPIABRQAAA==.',['�']='莫一夕:AwAHCAQABAoAAA==.',['�']='菈妮丨:AwADCAUABRQCDAADAQjQHgAUiMMABRQADAADAQjQHgAUiMMABRQAAA==.',['�']='萧丶瑟:AwAGCAwABRQDCAAGAQhOAQA3iowBBRQACAAGAQhOAQA3iowBBRQAAgABAQigHQAJkDEABRQAAA==.落花流水:AwAICAIABAoAAQcAAAAECAQABRQ=.',['�']='血色天涯:AwACCAMABRQECQAIAQjKPwBDazgBBAoACQAGAQjKPwA2zDgBBAoACgAFAQiXVwAs/fYABAoAGgADAQhPDQBHPcoABAoAAA==.',['�']='袖缠云:AwAICAgABAoAAA==.',['�']='观緈:AwAICAgABAoAAA==.解冻冰虫:AwAECAYABRQCGwAEAQibDwA2Me4ABRQAGwAEAQibDwA2Me4ABRQAAA==.',['�']='计都罗睺:AwADCAIABAoAAA==.',['�']='谜醉丶:AwADCAMABRQAAA==.',['�']='貓貓愛吃魚:AwAFCAkABAoAAA==.',['�']='赖赖乎:AwACCAUABRQCHAACAQhXDQAeT24ABRQAHAACAQhXDQAeT24ABRQAAA==.',['�']='逆水风寒:AwAFCAUABRQDBQAFAQhXBQAgj/YABRQABQAEAQhXBQAoffYABRQABAABAQjTDQAIxk8ABRQAAA==.逍遥枭妖:AwACCAIABRQAAA==.',['�']='遇见夏天:AwABCAEABRQCHQAHAQhGFwBJBgACBAoAHQAHAQhGFwBJBgACBAoAAA==.',['�']='那个武僧:AwAICAQABAoAAA==.',['�']='长发飘飘:AwAFCAkABAoAAA==.',['�']='阵发性噪狂:AwAHCAgABRQDDgAHAQggAwBNVTkBBRQADgADAQggAwBEejkBBRQABgAEAQjhAwBWMS4BBRQAAA==.阿布团:AwAECAQABRQAAA==.阿纳贝尔卡多:AwADCAUABRQDBQADAQj7CgBO1bAABRQABQACAQj7CgA5KLAABRQAAwACAQiJFABFYqQABRQAAA==.阿葵娅莉阿斯:AwAECAIABRQAAA==.',['�']='陆月中暑:AwAECAQABRQAAA==.',['�']='零度之吻:AwADCAMABAoAAA==.',['�']='青城:AwAICAoABAoAAA==.',['�']='顺仔大帅比:AwAICBUABAoCDAAIAQiFHQBSxIsCBAoADAAIAQiFHQBSxIsCBAoAAA==.',['�']='风行零度:AwAICAgABAoAAQcAAAAGCAQABRQ=.',['�']='鬼不曾伤害我:AwABCAEABRQDEgAIAQjDPAA1otwBBAoAEgAIAQjDPAA1otwBBAoAEwACAQhTZQAOgUkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end