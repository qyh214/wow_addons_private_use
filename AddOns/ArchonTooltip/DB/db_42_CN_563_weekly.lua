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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Protection','Druid-Balance','Druid-Restoration','Unknown-Unknown','Mage-Fire','Priest-Shadow','Priest-Holy','Warrior-Fury','Warrior-Protection','DemonHunter-Havoc','Monk-Mistweaver','Warrior-Arms','Monk-Windwalker','Rogue-Assassination','Hunter-Survival','DeathKnight-Frost','DeathKnight-Unholy','Shaman-Restoration','Evoker-Preservation','Paladin-Retribution','Shaman-Enhancement','Mage-Frost','Rogue-Subtlety','DeathKnight-Blood',}; local provider = {region='CN',realm='丹莫德',name='CN',type='weekly',zone=42,date='2025-04-14',data={Be='Beauty:AwAGCAoABAoAAA==.',Co='Conjurs:AwACCAEABRQAAA==.',Dl='Dloneyear:AwAECAQABRQDAQAIAQjdBwBb2I0CBAoAAQAIAQjdBwBbG40CBAoAAgAIAQjLGABOYIECBAoAAA==.',Gu='Guerdan:AwAECAQABRQAAA==.',Hr='Hrunting:AwAICAgABAoAAA==.',Lo='Loosepusysy:AwAGCAYABRQCAwAGAQgOAgAkz0QBBRQAAwAGAQgOAgAkz0QBBRQAAA==.',Lu='Luckylife:AwAECAcABRQDBAAEAQh/EAAzm+MABRQABAAEAQh/EAAzm+MABRQABQABAQhKGAAr90EABRQAAA==.',Sh='Shelby:AwABCAIABAoAAA==.',Sp='Springmao:AwAICA4ABAoAAA==.Spyfay:AwAECAQABRQAAA==.',St='Stillawinds:AwAECAQABRQAAA==.',Th='Themoonl:AwACCAIABRQAAA==.',Tr='Traps:AwABCAIABRQAAA==.',Ys='Ys:AwAICAgABAoAAQYAAAAICAEABRQ=.',['�']='一条不归路:AwAECAQABRQAAA==.万花不点墨:AwADCAMABRQAAA==.不死不转火:AwAFCAUABAoAAA==.不西的春天:AwAICAgABAoAAA==.丨小疯丶:AwAECAUABRQCBwADAQiaJAAouZMABRQABwADAQiaJAAouZMABRQAAA==.丶张柏芝:AwAICB8ABAoDAgAIAQg8EwBW+KACBAoAAgAIAQg8EwBW+KACBAoAAQADAQiFZgAMvEUABAoAAA==.',['�']='亚煞极:AwAECAQABAoAAA==.',['�']='伟大教员:AwAHCAsABAoAAA==.',['�']='余音丶:AwAICAgABAoAAA==.',['�']='倚栏听风:AwADCAEABAoAAA==.',['�']='傻傻的馒馒:AwAECAQABRQAAA==.',['�']='像只大虾:AwAECAgABRQCBAAEAQiEBQBT1yQBBRQABAAEAQiEBQBT1yQBBRQAAA==.',['�']='先祖之父:AwAGCAYABAoAAA==.兜兜木有豆豆:AwACCAUABRQDCAACAQgyFgAedIIABRQACAACAQgyFgAedIIABRQACQABAQhDGABRr00ABRQAAA==.入戯丶冭深:AwAICBYABAoDCgAIAQhuIQA58vQBBAoACgAIAQhuIQA58vQBBAoACwACAQgyNAAWTUsABAoAAA==.',['�']='再嘘也要社:AwABCAEABRQCAgAIAQi0KwA+oSUCBAoAAgAIAQi0KwA+oSUCBAoAAA==.',['�']='剥皮小能手:AwACCAIABAoAAA==.副主编:AwACCAIABRQAAA==.',['�']='单身小阿姨:AwAECAQABRQAAA==.卡布奇诺丶丶:AwAFCAYABAoAAA==.',['�']='叶月抹茶:AwAFCAUABAoAAA==.',['�']='吗马:AwADCAkABRQDAQADAQjmBwA65ecABRQAAQADAQjmBwA5eOcABRQAAgACAQhfJAAuOpYABRQAAA==.',['�']='咪咪虾条:AwACCAIABRQAAA==.',['�']='嘉然亡命天涯:AwADCAIABAoAAA==.',['�']='囧猎囧:AwAICAsABAoAAA==.国宝囡囡:AwAFCAgABAoAAA==.',['�']='大师在此:AwABCAEABAoAAA==.大牛仔:AwAGCAUABAoAAQwATVQCCAUABRQ=.大经理:AwACCAUABRQCDQACAQjQFQBG4pwABRQADQACAQjQFQBG4pwABRQAAA==.天使会掉毛:AwAGCAYABAoAAA==.天宸:AwAGCAoABRQDCgAGAQhTAQA6pJIBBRQACgAFAQhTAQBGOJIBBRQADgABAQggEQAMVVUABRQAAA==.天海春香:AwADCAoABRQCDwADAQj0BwAzbu0ABRQADwADAQj0BwAzbu0ABRQAAA==.天线爆爆:AwAICAgABAoAAA==.',['�']='如今已然厌倦:AwAHCAcABAoAAA==.',['�']='安赛龙:AwAECAIABRQAARAATFAGCAYABRQ=.',['�']='小十七:AwAICAgABAoAAA==.小太爷孟烦了:AwAFCAUABAoAAA==.小子蛮坏:AwAICCMABAoEAQAIAQgkBwBYHJcCBAoAAQAIAQgkBwBTWZcCBAoAAgAIAQjjHgBRcmICBAoAEQACAQgBFwAlV1sABAoAAA==.小小乙:AwAFCAUABAoAAA==.小小萨鲁法尔:AwACCAMABRQAAA==.小朋友飞起来:AwACCAMABRQDEgAIAQgWDQBMsp8BBAoAEgAGAQgWDQBO3Z8BBAoAEwAFAQjBRgA4xWEBBAoAAA==.小禽獸丷:AwAGCBEABAoAAA==.',['�']='山葵不是辣根:AwAICAgABAoAAA==.',['�']='岁月兮无痕:AwAICAgABAoAAA==.',['�']='布哪那:AwAGCAYABAoAAA==.希女王丶:AwABCAEABRQAAA==.常巨庆:AwACCAMABRQAAA==.',['�']='幻世沧海:AwAECAQABRQAAA==.',['�']='强哥带你灰:AwAICAgABAoAAA==.',['�']='微风吹:AwAICBYABAoCFAAIAQg1IQBCd+wBBAoAFAAIAQg1IQBCd+wBBAoAAA==.',['�']='心灵纵火犯:AwABCAEABAoAAA==.',['�']='房裹窝:AwAECAQABRQAARUAGncGCAUABRQ=.',['�']='托米大耳朵耶:AwAFCAYABAoAAA==.托米小粗腿耶:AwAFCAkABAoAAA==.扶摇丶:AwAFCAUABAoAAA==.',['�']='拉姆丶拉错:AwACCAIABAoAAA==.',['�']='指尖流年:AwABCAEABAoAAA==.',['�']='敖小豆:AwAECAQABRQAAA==.',['�']='无尽的江:AwABCAEABRQAAA==.',['�']='明日香今日臭:AwAGCAYABAoAAA==.昼奈儿丶:AwAHCBQABAoDAwAHAQhjHQAxCT4BBAoAAwAHAQhjHQAxCT4BBAoAFgABAQgvRwEbXDkABAoAAA==.',['�']='未走的不归路:AwAFCAUABAoAAA==.',['�']='杨永信丶:AwACCAIABRQAAA==.',['�']='桃田賢斗:AwAECAIABRQAAA==.',['�']='步极:AwAECAQABRQAAA==.武武:AwAGCAoABAoAAA==.歪搜希瑞斯:AwAECAQABRQAAA==.',['�']='毁灭旋律:AwAECAQABRQAAA==.',['�']='江苏吴彦祖丶:AwAGCA8ABRQCCgAGAQjCCQAzDAcBBRQACgAGAQjCCQAzDAcBBRQAAA==.',['�']='沉默的低调:AwACCAIABRQAAA==.',['�']='法如的龙木艮:AwAECAQABRQAAA==.',['�']='清明微雨:AwAECAgABRQCFAAEAQiZBgBMbgwBBRQAFAAEAQiZBgBMbgwBBRQAARcAPEQGCAgABRQ=.',['�']='满脸狐渣:AwACCAMABRQDBwAIAQiwCwBV7q0CBAoABwAIAQiwCwBVX60CBAoAGAADAQioXgBV/8AABAoAAA==.',['�']='漂浮群岛:AwAICBYABAoCDAAIAQi8UAAVoTQBBAoADAAIAQi8UAAVoTQBBAoAAA==.',['�']='火舞灬艳阳:AwAGCAYABAoAAA==.灾厄低语:AwACCAEABRQCGQAIAQgjDQA4nRICBAoAGQAIAQgjDQA4nRICBAoAAA==.',['�']='爱发呆的笨猫:AwAECAQABRQAAA==.爵丶爷:AwACCAIABAoAAA==.',['�']='牛奶好喝丶:AwABCAEABRQAAA==.牧牧神依:AwAICAgABAoAAA==.特工小八:AwACCAIABRQAAA==.',['�']='白翼誓约:AwAHCBMABAoAAA==.',['�']='盔甲:AwAHCA0ABAoAAA==.',['�']='知天易逆天男:AwAECAUABRQDGAAEAQjTCAAkWbkABRQAGAAEAQjTCAAhZLkABRQABwABAQgIMAAeX0cABRQAAA==.',['�']='等风來灬:AwAECAMABRQAAA==.',['�']='绝版圣斗士:AwAECAIABAoAAA==.',['�']='翼橙:AwADCAgABRQDAgADAQi4FgBDD94ABRQAAgADAQi4FgA7Mt4ABRQAAQACAQgeDgA7HasABRQAAA==.',['�']='老马最马虎:AwACCAIABAoAAA==.',['�']='胭脂桃花粉:AwAGCAYABAoAAA==.',['�']='致命之剑丶:AwACCAkABRQCCgACAQjPFABBwasABRQACgACAQjPFABBwasABRQAAA==.',['�']='花户小鸠:AwAECAQABAoAAA==.',['�']='莪吥嗳伱:AwAECAoABRQDEwAEAQhGBABYXykBBRQAEwAEAQhGBABYXykBBRQAGgAEAQhvBgBH1v0ABRQAAQYAAAAICAEABRQ=.',['�']='萌萌二次元:AwAGCAYABAoAAA==.萧瑟弑光:AwACCAUABRQCDAACAQiHGgBNVKIABRQADAACAQiHGgBNVKIABRQAAA==.',['�']='许瀛龙:AwADCAMABAoAAA==.',['�']='迎春花儿开:AwAGCAYABAoAAA==.',['�']='逆天而行:AwAGCAkABAoAAA==.',['�']='部落皮卡丘:AwACCAIABAoAAA==.',['�']='雄鹰一样男人:AwAECAIABRQCBAAIAQj4LAA4cNsBBAoABAAIAQj4LAA4cNsBBAoAAA==.雪月枫:AwAICBAABAoAAA==.雪雨纷飞:AwAFCAYABAoAAA==.',['�']='风月恋:AwABCAEABRQAAA==.飘逸浩浩:AwACCAIABRQAAA==.',['�']='首席老中医:AwAGCAcABAoAAA==.',['�']='骨头是啊固:AwAECAMABRQAAA==.',['�']='鬼王达:AwABCAEABRQCDAAIAQjPIwBI/Q0CBAoADAAIAQjPIwBI/Q0CBAoAAA==.',['�']='魔预者奶咕咕:AwAFCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end