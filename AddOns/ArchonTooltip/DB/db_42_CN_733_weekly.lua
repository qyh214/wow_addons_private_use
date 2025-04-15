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
 local lookup = {'Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Warrior-Fury','Mage-Frost','Mage-Fire','Priest-Discipline','Priest-Holy','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Rogue-Assassination','Rogue-Subtlety','Warlock-Destruction','Warlock-Affliction','Monk-Windwalker','DeathKnight-Blood','Warlock-Demonology','Priest-Shadow','Warrior-Protection','Shaman-Elemental','DemonHunter-Havoc','Shaman-Enhancement','Shaman-Restoration','Monk-Mistweaver',}; local provider = {region='CN',realm='海加尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Calmity:AwAECAQABRQAAA==.Carrycarrie:AwABCAEABRQAAQEAAAAECAQABRQ=.',Ch='Chan:AwACCAIABRQAAA==.',Co='Combust:AwADCAgABRQDAgADAQipHAA+P7QABRQAAgACAQipHABGk7QABRQAAwABAQijFwAtl0wABRQAAA==.',Dr='Drama:AwAECAQABRQAAA==.',Fo='Foogy:AwAECAIABAoAAA==.',Ho='Holyz:AwABCAMABRQAAA==.',Ic='Iceymo:AwAECAQABRQAAQEAAAAICAQABRQ=.',Ke='Kevinnine:AwADCAYABRQDBAADAQjSBABcXyoBBRQABAADAQjSBABcXyoBBRQABQACAQiVEAAukH0ABRQAAA==.',Ku='Kurtie:AwAGCAgABRQCBgAGAQhLAAA5VNgBBRQABgAGAQhLAAA5VNgBBRQAAA==.',La='Lalaguer:AwAICAgABAoAAA==.',Li='Lionkk:AwAECAgABRQCAwAEAQgFAwBUnxcBBRQAAwAEAQgFAwBUnxcBBRQAAA==.',Lo='Lokawesa:AwAECAQABRQAAA==.',Ma='Marcel:AwAECAQABRQAAQIAKokICAIABRQ=.',Ob='Oblivionis:AwABCAEABRQAAA==.',Pa='Packy:AwAGCAEABAoAAA==.',Qu='Quiz:AwAICAgABAoAAA==.',Re='Rebroken:AwAHCAcABRQDBwAHAQgSAAA8JcQBBRQABwAGAQgSAAA5PcQBBRQACAABAAgAAABKrQAABRQAAA==.',Ro='Roxette:AwAECAoABRQDBwAEAQggBgA41eQABRQABwAEAQggBgA2X+QABRQACAAEAQh3FgAv1OAABRQAAA==.',Sa='Sandor:AwAGCAEABAoAAA==.',St='Starfang:AwAECAUABRQDCQADAQiaBwBD9PoABRQACQADAQiaBwBD9PoABRQACgACAQhvFgAHgV4ABRQAAA==.',To='Too:AwAECAQABRQAAA==.',['�']='一瞬之光:AwAGCAUABAoAAA==.专注蜀黍:AwAICBoABAoDCwAIAQjJAwBh+wwDBAoACwAIAQjJAwBh+wwDBAoADAAIAQj/HQAVGzwBBAoAAA==.丷晴朗丷:AwAGCAYABAoAAA==.',['�']='义薄云天丶:AwABCAEABRQAAA==.九有钱:AwAECAQABRQAAA==.',['�']='你五岁了吗:AwADCAUABRQCCAADAQj2GAAh6dcABRQACAADAQj2GAAh6dcABRQAAA==.你这么整是吧:AwAECAQABRQAAA==.',['�']='元元的晴朗:AwAGCAYABAoAAA==.光与暗的抉择:AwAECAQABRQAAQEAAAAGCAIABRQ=.八神月姬:AwACCAIABRQAAA==.',['�']='内牛满面:AwADCAQABRQAAA==.冬天的罗卜:AwABCAEABRQDCwAIAQhlBQBgTQADBAoACwAIAQhlBQBgTQADBAoADQABAQjkXQAKGA0ABAoAAA==.冰火洗礼:AwABCAEABRQAAA==.',['�']='准备出发:AwAECAQABRQAAA==.凯瑟琳冰儿:AwAECAQABRQAAA==.凯瑟琳咒术师:AwAICAgABAoAAA==.',['�']='勤劳的卡比兽:AwAECAQABRQCCwAIAQjEFQBgwK0CBAoACwAIAQjEFQBgwK0CBAoAAA==.勺子梅猫饼:AwADCAUABRQDAwADAQhODwA1ZpwABRQAAwACAQhODwA8EJwABRQAAgACAQh2KAAkv4wABRQAAA==.',['�']='十六:AwAECAQABRQAAA==.千里独舞:AwABCAEABRQAAA==.南极以北:AwAECAQABRQAAA==.卡脆娜娜:AwAICAgABAoAAA==.',['�']='君子见机:AwACCAMABRQDDgAIAQjyBgBXMn8CBAoADgAIAQjyBgBOuX8CBAoADwAGAQg7GQA1Fl8BBAoAAA==.',['�']='嘤灬嘤嘤:AwACCAMABRQDEAAIAQj7EwBIYj0CBAoAEAAIAQj7EwBIYj0CBAoAEQABAQjdOQA58D8ABAoAAA==.',['�']='四个雪糕棍:AwAECAEABRQAAA==.',['�']='圣辉闪耀:AwAICAgABAoAAA==.在下乘风而起:AwADCAcABRQCEgADAQh6BgA+6/4ABRQAEgADAQh6BgA+6/4ABRQAAA==.',['�']='夏日冰美式:AwAICAYABAoAAA==.大王爷:AwAICAMABAoAAA==.天使紫罗兰:AwAICAgABAoAAA==.天选的阿昆达:AwADCAMABRQCEwAIAQgHDABOB0YCBAoAEwAIAQgHDABOB0YCBAoAAA==.',['�']='好了别说了:AwAICAoABAoAAA==.',['�']='始乱未二:AwAFCAoABRQEEQAFAQiZAABNT1UBBRQAEQAEAQiZAABirlUBBRQAEAACAQgCFQAwCaAABRQAFAACAQjSDAANMFIABRQAAA==.',['�']='娜美小宝儿:AwAECAQABRQAAA==.',['�']='宁宁闹他:AwAECAgABRQCEQAEAQhyAgBPAB0BBRQAEQAEAQhyAgBPAB0BBRQAAA==.',['�']='寂寞狐狸:AwADCAgABRQDCwADAQgsCwBJKBMBBRQACwADAQgsCwBJKBMBBRQADAACAQhYBwBSv8EABRQAAA==.',['�']='小壞氮:AwAECAQABAoAAA==.小小兔宝宝:AwADCAYABRQCCwADAQhmGAAtaOQABRQACwADAQhmGAAtaOQABRQAAA==.小小武僧:AwAECAQABRQAAA==.小摸鱼的余墨:AwAICAEABAoAAA==.小象嘟嘟:AwAICAgABAoAAA==.',['�']='屁颠一路小跑:AwAICA4ABAoAAQIAShkGCA4ABRQ=.',['�']='带驴叫嚣的狗:AwAECAQABRQAAA==.',['�']='库克噜噜:AwAGCAYABRQDEAAGAQjZAQA26WwBBRQAEAAFAQjZAQA+3mwBBRQAFAABAQiMCwAXFVcABRQAAA==.库克皮皮:AwAFCAEABAoAAA==.',['�']='心弦乄梦:AwABCAEABRQAAA==.',['�']='慷慨激昂:AwABCAEABRQAAA==.',['�']='我是圣骑:AwAHCAcABAoAAA==.战斗吧少年:AwAFCA8ABRQCEgAFAQiKAQBEmZkBBRQAEgAFAQiKAQBEmZkBBRQAAA==.',['�']='插花弄玉:AwAECAQABRQAAA==.',['�']='断风尘:AwADCAYABRQDEQADAQg5BgAxKO4ABRQAEQADAQg5BgAxKO4ABRQAFAABAQj2EwAFgTIABRQAAA==.',['�']='晓疯子:AwABCAEABRQAAA==.晨晨同学:AwACCAIABAoAAA==.晴丷朗:AwAGCAYABAoAAA==.晴朗:AwAGCAYABAoAAA==.',['�']='月照心自明:AwADCAUABRQCCQADAQjKCwAr69QABRQACQADAQjKCwAr69QABRQAAA==.未始乱二:AwAECAQABRQAAA==.机智的呆呆兽:AwAECAMABRQAAA==.',['�']='树勇买买提:AwAECAQABRQAAA==.',['�']='橙玥:AwACCAIABRQCCwAIAQhYFABXS7MCBAoACwAIAQhYFABXS7MCBAoAAA==.',['�']='檸檬沙拉:AwAGCBoABAoCFQAGAQjwKgA4oFcBBAoAFQAGAQjwKgA4oFcBBAoAAA==.',['�']='死亡宅妹:AwABCAEABRQAAA==.',['�']='永広:AwAICA4ABAoAAA==.',['�']='沉默的大酋长:AwAGCAQABRQDBgAHAQj+HQBG1goCBAoABgAHAQj+HQBG1goCBAoAFgAEAQhgKAAo/4wABAoAAA==.沙漏:AwAICAcABAoAAA==.没有肉肉:AwADCAYABRQCFwADAQigBABFuv4ABRQAFwADAQigBABFuv4ABRQAAA==.',['�']='流浪刀刀:AwAECAQABRQAAA==.浓睡不醒残酒:AwAECAQABRQAAA==.',['�']='点水:AwAECAgABRQDBwAEAQjzCgAgLJ4ABRQACAAEAQg+GgAgLNEABRQABwAEAQjzCgAQ754ABRQAAA==.',['�']='烈焰灬灼心:AwADCAgABRQCGAADAQi/FAAZINYABRQAGAADAQi/FAAZINYABRQAAA==.',['�']='熊猫快快跑灬:AwAHCAcABAoAAA==.',['�']='牛毛豆:AwABCAEABAoAAA==.牛黄豆:AwACCAMABRQDGQAIAQi9DgBI308CBAoAGQAIAQi9DgBI308CBAoAGgADAQjFggAqcIoABAoAAA==.',['�']='狐小喵:AwACCAMABRQDDAAIAQinAgBYrrcCBAoADAAIAQinAgBYrrcCBAoACwABAQhHMAFPD1MABAoAAA==.',['�']='瑶瑶乐:AwAFCAEABAoAAA==.',['�']='疯中追风:AwAICAgABAoAAA==.',['�']='皤魑傀儡公:AwAFCAoABAoAAA==.',['�']='盘丝灬大仙:AwAECAQABRQAAA==.',['�']='瞬发炉石:AwAECAkABRQDFwAEAQj+BwAubNgABRQAFwAEAQj+BwAubNgABRQAGgABAQisJgAMnEEABRQAAQUAOkwGCAUABRQ=.',['�']='神圣魔幻:AwADCAMABAoAAA==.',['�']='离落霜魂:AwABCAEABRQAAA==.',['�']='秦始皇二一四:AwAECAYABRQCGgAEAQh9BQBI5RYBBRQAGgAEAQh9BQBI5RYBBRQAAA==.',['�']='粮票的故事:AwAECAQABRQAAA==.',['�']='紫月重明:AwADCAMABRQAAA==.',['�']='维克多莉雅:AwABCAEABRQAAA==.',['�']='肥肥是只喵:AwAECAUABRQCAgAEAQhxGwAPmL0ABRQAAgAEAQhxGwAPmL0ABRQAAA==.',['�']='萧瑟骑士:AwAGCAIABAoAAA==.',['�']='許鱼:AwACCAIABRQAAA==.',['�']='让我看看:AwAECAEABRQAAA==.许鱼:AwACCAMABRQAAA==.',['�']='请阅示:AwAECAQABRQAAA==.',['�']='谜之真相:AwAGCAoABAoAAA==.谢雨辰丶:AwAECAQABRQAAA==.',['�']='豆到碗里来:AwABCAEABAoAAA==.',['�']='路西法叮叮:AwAICAgABAoAAQ8AO5AGCAkABRQ=.',['�']='躺赢:AwAICAoABAoAAA==.',['�']='辉煌:AwABCAEABRQAAA==.辣炒小花蛤:AwAGCAgABRQCGwADAQgvDgApL9wABRQAGwADAQgvDgApL9wABRQAAA==.',['�']='运动牛牛:AwAECAIABRQAAA==.',['�']='队长是我呀:AwACCAIABRQAAQgALZoICAUABRQ=.',['�']='集合石大师:AwABCAEABRQAAA==.',['�']='面包熊:AwABCAEABRQAAQEAAAAECAQABRQ=.',['�']='韩能抗:AwAGCAYABAoAAA==.',['�']='飞天打卤面:AwAGCAYABAoAAQEAAAAGCAMABRQ=.',['�']='饼干熊:AwABCAEABRQAAA==.',['�']='高圆圆老公:AwAICAgABAoAAA==.',['�']='麟迴转圈圈:AwACCAMABRQCGAAIAQgfOAArBqQBBAoAGAAIAQgfOAArBqQBBAoAAA==.',['�']='黯然失落:AwABCAEABRQAAA==.',['�']='龙云凤:AwACCAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end