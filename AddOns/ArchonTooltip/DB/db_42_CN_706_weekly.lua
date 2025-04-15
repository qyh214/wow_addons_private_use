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
 local lookup = {'Druid-Balance','Druid-Restoration','DeathKnight-Unholy','Druid-Feral','Druid-Guardian','Paladin-Retribution','Warlock-Destruction','Warlock-Demonology','Monk-Windwalker','Shaman-Restoration','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Evoker-Devastation','Mage-Frost','Mage-Fire','DemonHunter-Havoc','DemonHunter-Vengeance',}; local provider = {region='CN',realm='暴风祭坛',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arrhenius:AwAECAQABRQAAA==.',Ca='Cantice:AwABCAEABRQAAA==.',Ee='Eeko:AwAECAUABAoAAA==.',Ez='Ezri:AwAECAQABRQAAA==.',He='Hellscr:AwAHCAcABAoAAA==.',Ir='Ireul:AwABCAEABAoAAA==.',Ka='Kannime:AwAICBAABAoAAA==.',La='Latsiimh:AwAICAgABAoAAA==.',Yu='Yunshixd:AwAECAsABRQDAQAEAQjgAwBhfzYBBRQAAQAEAQjgAwBhfzYBBRQAAgAEAQhgCwAStq0ABRQAAA==.',['�']='一把小骨头:AwAICAgABAoAAA==.七零四张医师:AwAECAQABRQAAA==.上海萌牛:AwABCAEABRQAAA==.丶血小贱:AwABCAEABAoAAA==.丶雨诺丶:AwAECAYABRQCAwAEAQhgCQBA+PsABRQAAwAEAQhgCQBA+PsABRQAAA==.',['�']='乌拉乌拉乌拉:AwABCAEABRQEAgAIAQgeGgA8kskBBAoAAgAHAQgeGgBCW8kBBAoABAAEAQgZFgAh/vwABAoABQABAQitMQAEHwQABAoAAA==.乌龟的黑头:AwADCAEABAoAAA==.',['�']='仄仄:AwAICB8ABAoCBgAIAQjKaQA4qaABBAoABgAIAQjKaQA4qaABBAoAAA==.',['�']='优势在我:AwAICA8ABAoAAA==.',['�']='你又:AwABCAEABRQAAA==.你家鸽鸽:AwAGCAQABRQAAA==.',['�']='倔強的葡萄哥:AwABCAEABRQAAA==.',['�']='公主八个胃:AwAECAQABRQAAA==.',['�']='冖亼冖:AwABCAEABAoAAA==.冥帝:AwABCAEABRQAAA==.冰封柬柬:AwADCAIABAoAAA==.冰魄剑:AwABCAEABAoAAA==.',['�']='凝望深渊:AwABCAEABAoAAA==.凤凰院喵真:AwAGCAYABRQDBwAGAQhLAgAyclIBBRQABwAFAQhLAgA7SFIBBRQACAABAQh1DAAPHFQABRQAAA==.',['�']='剑君十二恨:AwAECAIABRQAAA==.',['�']='功夫织女:AwAECAQABAoAAA==.',['�']='卖血在上网:AwAFCAoABAoAAA==.南影倾寒:AwAECAQABRQAAA==.',['�']='及夏:AwAGCAYABAoAAA==.叮咚:AwADCAMABRQAAQkAIjQHCAkABRQ=.可乐八号:AwAGCAYABAoAAA==.',['�']='哎呦不错呦:AwAICAoABAoAAA==.',['�']='喆同学:AwAFCAUABAoAAA==.',['�']='嘉明:AwACCAUABRQCCgACAQi3HwAIT24ABRQACgACAQi3HwAIT24ABRQAAA==.嘚脆:AwAICBEABAoAAA==.',['�']='回魂:AwAFCAUABAoAAA==.',['�']='土逼南波湾:AwAECAQABAoAAA==.圣丶惩戒:AwAHCBQABAoCBgAHAQjLYABEMbQBBAoABgAHAQjLYABEMbQBBAoAAA==.',['�']='堕落丘比特:AwAFCAoABAoAAA==.',['�']='夜玹:AwACCAIABAoAAA==.夢梅悅怡:AwAECAQABRQAAA==.大只西瓜:AwACCAIABRQAAA==.天天牛肉面:AwAGCAEABAoAAA==.天籁萨:AwADCAMABRQAAA==.天菩萨:AwAECAQABAoAAA==.',['�']='奥本海默:AwAICAgABAoAAA==.奶瓶超人:AwAICA8ABAoAAA==.',['�']='安慕丶希:AwAHCBEABAoAAA==.',['�']='射射:AwAGCAYABAoAAA==.小龙人:AwAHCAcABAoAAA==.',['�']='幽冥哈迪斯:AwACCAIABAoAAA==.',['�']='库蕾雅:AwAECAQABRQAAA==.',['�']='开始即结束:AwAECAQABAoAAA==.',['�']='御神丶格格:AwAGCAYABAoAAA==.',['�']='悍匪蚊子:AwEGCAIABRQAAQsAAAAICAMABRQ=.',['�']='我叫曾轶可:AwAICB4ABAoDDAAIAQjjKwBENyQCBAoADAAIAQjjKwBENyQCBAoADQAIAQjmKgAf0k8BBAoAAA==.我性疯狂:AwABCAEABRQAAA==.我没尅:AwAECAUABAoAAA==.我真的巨厉害:AwAGCAYABAoAAA==.戦斧牛排:AwADCAwABRQCDgADAQj7FAAHgHEABRQADgADAQj7FAAHgHEABRQAAA==.',['�']='拉的翼神:AwAECAEABRQAAA==.拉链卡到毛:AwAECAMABRQAAA==.拜金者:AwABCAEABRQAAA==.',['�']='摄魂夺魄:AwAHCAcABAoAAA==.',['�']='放弃圣光:AwAECAYABAoAAA==.',['�']='无涩丶清茶:AwABCAEABRQCBgAIAQhZIABVOn8CBAoABgAIAQhZIABVOn8CBAoAAA==.无语泪奔:AwAGCAkABAoAAA==.时扳晴人:AwAICAoABAoAAA==.',['�']='春寒倒返:AwADCAYABRQCDwADAQg/DAAaO8gABRQADwADAQg/DAAaO8gABRQAAA==.',['�']='暗月旋舞:AwAGCAUABAoAAA==.',['�']='月亮小船:AwAICA8ABRQCDAAIAQgmAAA5O3wCBRQADAAIAQgmAAA5O3wCBRQAAA==.',['�']='梅塔特林:AwACCAIABRQAAA==.',['�']='泰莉亚:AwAICAgABAoAAQsAAAAICAQABRQ=.',['�']='浪漫丶饭团:AwAICBYABAoDEAAHAQikDgBefm0CBAoAEAAGAQikDgBefm0CBAoAEQACAQiTlgATFycABAoAAA==.',['�']='渊武:AwAFCAEABAoAAA==.渺小的尘埃:AwAICAwABAoAAQsAAAAECAQABRQ=.',['�']='激活打脉动:AwAGCAQABRQAAA==.',['�']='灰骑士薛帕德:AwAICAgABAoAAA==.',['�']='烈焰法神:AwABCAEABAoAAA==.烟菋弥漫:AwACCAIABAoAAA==.',['�']='無所畏懼:AwAICAgABAoAAA==.',['�']='熊气昂昂:AwABCAEABRQAAA==.',['�']='狗仔萨摩耶:AwAECAwABRQDDQAEAQjQBQBCyvkABRQADQAEAQjQBQBCyvkABRQADAAEAQhcEwA8VuwABRQAAQoANVQGCAoABRQ=.独夏孤影:AwAGCBAABAoAAA==.',['�']='猩红之泪:AwAICAoABAoAAREAP/MGCAYABRQ=.',['�']='痞子丶魔:AwAGCAYABAoAAA==.',['�']='癫火幻耀石:AwAICAgABAoAAA==.',['�']='着光:AwAFCAkABAoAAA==.',['�']='短小快枪男:AwABCAIABRQAAQsAAAACCAQABRQ=.',['�']='神奇猫猫头:AwACCAIABRQAAA==.',['�']='禅翼:AwABCAEABRQAAA==.',['�']='紫日:AwABCAEABRQAAA==.',['�']='繁华梦露:AwAICAcABAoAAREASekGCAwABRQ=.',['�']='罗慕洛斯:AwADCAYABAoAAA==.',['�']='羲和:AwADCAQABRQAAA==.',['�']='肉宝宝丶:AwABCAEABAoAAA==.',['�']='自东向西:AwAHCAoABAoAAA==.',['�']='艾雅黑掌:AwAICAsABAoAAA==.',['�']='菊魔沾酱:AwAICAgABAoAAA==.',['�']='萌烧锅:AwAICAgABAoAAA==.',['�']='贰灬减:AwAECAQABRQAAA==.',['�']='赞美太阳:AwAECAgABRQDEgAEAQhpDAA+u/0ABRQAEgAEAQhpDAA+u/0ABRQAEwACAQjvDQAU6WcABRQAAA==.',['�']='跳远运动员:AwAFCAYABAoAAA==.',['�']='逍遥无忧:AwAICAsABAoAAA==.逐风者石肤:AwAECAkABAoAAA==.通通:AwAICAgABAoAAA==.',['�']='酸甜柠檬:AwACCAIABAoAAA==.',['�']='野生动物贩子:AwABCAEABAoAAA==.',['�']='钢铁风筝:AwAFCAcABAoAAA==.',['�']='阿爾托麗雅:AwAICAgABAoAAA==.',['�']='露茜范佩尔特:AwAECAQABAoAAA==.',['�']='风御殇:AwAECAQABRQAAA==.风暴代替思考:AwAECAQABRQAARIAMf0GCA4ABRQ=.',['�']='高一高:AwADCAMABAoAAA==.',['�']='魔曦:AwAECAQABRQAAA==.',['�']='黑俊的爸爸:AwAECAgABRQCBgAEAQj/CgBNghQBBRQABgAEAQj/CgBNghQBBRQAAA==.黑桃尖丶:AwAECAQABRQAAA==.',['�']='龍小羽:AwAGCA8ABAoAAA==.龙唐尔:AwACCAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end