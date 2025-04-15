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
 local lookup = {'Warrior-Protection','Unknown-Unknown','Hunter-Marksmanship','DeathKnight-Blood','Paladin-Retribution','Priest-Holy','Priest-Discipline','Shaman-Restoration','Hunter-BeastMastery','Warrior-Fury','Warlock-Demonology','Warlock-Destruction','Mage-Frost','Monk-Mistweaver','Warlock-Affliction','Priest-Shadow','Shaman-Elemental','Rogue-Assassination','Mage-Fire','DemonHunter-Havoc',}; local provider = {region='CN',realm='埃加洛尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Ambrosio:AwAICBAABAoAAQEALyoICAoABRQ=.',Ba='Babyblue:AwAICAgABAoAAA==.Badjuju:AwAECAQABRQAAA==.Baojojo:AwAICBAABAoAAA==.',Co='Connie:AwAGCAYABAoAAA==.',Hu='Huarya:AwAECAQABRQAAA==.Hunterbleach:AwAICAgABAoAAQIAAAAICAQABRQ=.',Ja='Jamila:AwAECAQABRQAAQMAVdsICAgABRQ=.',Ju='June:AwAICAgABAoAAA==.',Mo='Moouse:AwAFCAUABAoAAA==.',Si='Silas:AwAECAYABRQCBAAEAQgRDAAuU7cABRQABAAEAQgRDAAuU7cABRQAAA==.',Sz='Szh:AwABCAEABRQAAA==.',['�']='一派狐言:AwACCAMABAoAAA==.一雨天一:AwAICBYABAoCBQAIAQgnigAWvlQBBAoABQAIAQgnigAWvlQBBAoAAA==.不學灬無術:AwAGCAEABAoAAA==.丶妖小妖:AwACCAUABRQCBgACAQg6DgA4w5kABRQABgACAQg6DgA4w5kABRQAAA==.',['�']='二手玫瑰丶:AwAECAQABRQAAA==.亚历山大:AwACCAcABRQCBAACAQg7FgAW+mYABRQABAACAQg7FgAW+mYABRQAAA==.',['�']='今夕丶何夕:AwADCAMABAoAAA==.代王里天神:AwAECAUABAoAAA==.',['�']='伊森丨哈德:AwAGCAYABAoAAA==.',['�']='元祖咖喱:AwAHCBEABAoAAA==.克里兰德:AwACCAIABAoAAA==.公交霉:AwABCAEABRQAAA==.',['�']='再别無敌:AwAICAgABAoAAQcAUxgECAcABRQ=.再次抄底:AwAECAQABRQAAA==.冬天的酒:AwABCAEABRQCCAAIAQifNQAtIIkBBAoACAAIAQifNQAtIIkBBAoAAA==.',['�']='加塞拉:AwABCAEABRQAAA==.',['�']='千华留:AwACCAYABRQCCQACAQigIQA0pp4ABRQACQACAQigIQA0pp4ABRQAAA==.南小鸟:AwADCAMABAoAAA==.',['�']='叫我英雄哥:AwAICBMABAoAAQcAUxgECAcABRQ=.可喜可乐:AwAFCAUABAoAAA==.可喜可贺:AwACCAcABRQCCgACAQgWFwAu7p4ABRQACgACAQgWFwAu7p4ABRQAAA==.',['�']='咕咕鸡飛崽:AwAICAgABAoAAA==.',['�']='唯快不破丶:AwAECAQABRQDCwAIAQiJBQBN5mECBAoACwAHAQiJBQBYI2ECBAoADAAIAQh9MQAtcpEBBAoAAA==.',['�']='嘎嘎学徒:AwACCAYABRQCDQACAQgFCQBRjrYABRQADQACAQgFCQBRjrYABRQAAA==.',['�']='圣光审判者:AwAECAQABRQAAA==.地獄風聲:AwAICAgABAoAAA==.',['�']='墨墨:AwAICA8ABAoAAQ4AW1wGCAQABRQ=.',['�']='大圣没娶我:AwAGCAUABAoAAA==.大梵:AwAICAgABAoAAA==.夨吢丶:AwAICAgABAoAAA==.太大希尔:AwAGCAsABAoAAA==.太阳之鹰:AwAHCAcABAoAAA==.',['�']='奥黛丽厚本:AwADCAMABAoAAA==.',['�']='妹妹门别锁:AwAECAcABAoAAA==.',['�']='嫩非牛:AwAFCAoABAoAAA==.',['�']='守饭狗:AwAGCAkABAoAAA==.',['�']='小狗子:AwAICBAABAoAAA==.少年挺文艺:AwABCAEABAoAAA==.尤迪安丶:AwABCAEABRQAAA==.',['�']='屠戮狂杀:AwACCAIABRQAAA==.',['�']='市芄银:AwACCAIABRQAAA==.带核吃芒果:AwAICAkABAoAAA==.',['�']='幽冥寐影:AwAECAQABRQAAA==.',['�']='心累:AwAHCAwABAoAAA==.忧傷调:AwADCAcABRQDDAADAQh/DwA9oMwABRQADAADAQh/DwAp08wABRQADwACAQhuCwBDgqwABRQAAA==.',['�']='性感小么么:AwACCAIABRQAAA==.性感小摸摸:AwACCAIABRQAAA==.',['�']='恶魔之击:AwABCAEABRQAAA==.',['�']='惊羽:AwAFCAUABAoAAA==.',['�']='憨牛骑士:AwACCAIABRQAAQ0AUY4CCAYABRQ=.',['�']='懒虫灬混沌:AwAICAgABAoAAA==.',['�']='成富裕:AwAGCAoABAoAAA==.',['�']='手打柠檬冰:AwAGCAYABAoAAA==.',['�']='招财小笨猫:AwACCAQABRQAAA==.',['�']='数师:AwAICAMABRQAAA==.',['�']='晚睡的兔兔:AwABCAEABRQAAQQAFvoCCAcABRQ=.',['�']='暗黑凋零:AwABCAEABAoAAA==.暗黑破壞神:AwACCAMABRQCDQAIAQjwFgBESCcCBAoADQAIAQjwFgBESCcCBAoAAA==.',['�']='月亮祭司:AwAGCAcABRQDEAAGAQiXAQA1n6sBBRQAEAAGAQiXAQA1n6sBBRQABgABAQjrFQBdhWMABRQAAA==.',['�']='柠檬百香果:AwAICBUABAoCCgAIAQhLEwBEe1YCBAoACgAIAQhLEwBEe1YCBAoAAA==.',['�']='椿湫:AwAICAgABAoAAA==.',['�']='歧视:AwACCAIABRQAAA==.',['�']='炎菲:AwAGCAoABAoAAA==.',['�']='热血:AwACCAIABAoAAA==.',['�']='無颜之月:AwAICAgABAoAAA==.焱焰小毛豆:AwAECAQABRQAAA==.',['�']='熾天之翼:AwAECAcABRQDBwAEAQhTBABTGCMBBRQABwADAQhTBABTGCMBBRQAEAAEAQgUDQAlsdgABRQAAA==.',['�']='猎神七月:AwAICAgABAoAAA==.',['�']='王曌飞丶:AwAICBIABAoAAA==.',['�']='甜小甜:AwAGCAYABRQDDAAGAQhXAwAnHjYBBRQADAAFAQhXAwArkjYBBRQADwABAQjeEwAVS1UABRQAAA==.',['�']='番茄蛋:AwACCAUABRQCEQACAQgQDQAn6pcABRQAEQACAQgQDQAn6pcABRQAAA==.',['�']='真部落无敌:AwABCAEABRQAAA==.',['�']='破碎精灵:AwACCAUABRQCEgACAQjyDQAZPpAABRQAEgACAQjyDQAZPpAABRQAAA==.',['�']='紫色皮皮虾:AwAICAgABAoAAA==.',['�']='翻倒龟:AwAHCAsABAoAAA==.',['�']='肥大饰拳:AwABCAEABAoAAA==.',['�']='芒果木槿花:AwAICBAABAoAAA==.',['�']='茗綺小劍敏:AwACCAIABRQAAA==.',['�']='草莓味飛崽:AwAECAQABRQAAA==.',['�']='莱恩曼妮:AwAECAoABRQDDAAEAQg4EAAi3cgABRQADAADAQg4EAAi3cgABRQACwABAQhlFwAAAAAABRQAAA==.',['�']='蓝色吻:AwAECAUABAoAAA==.',['�']='褐色炭烧:AwACCAIABAoAAA==.',['�']='赵曰天大魔王:AwAECAQABRQAAA==.',['�']='过来摸摸:AwAECAQABAoAAA==.连城绝影:AwABCAEABAoAAA==.',['�']='鍃丶熱:AwABCAEABAoAAA==.',['�']='雨天的爱哭鬼:AwACCAQABRQCBgAIAQiDJgApwo0BBAoABgAIAQiDJgApwo0BBAoAAA==.',['�']='青梅嗅:AwADCAUABRQDDQAIAQhSDABUw4YCBAoADQAIAQhSDABUw4YCBAoAEwACAQh9hAAV91cABAoAAA==.非牛类:AwACCAMABRQAAA==.',['�']='鱼片儿:AwACCAIABRQCFAAIAQivHwBDBCYCBAoAFAAIAQivHwBDBCYCBAoAAA==.',['�']='麻辣香鱼片:AwAGCAYABAoAAA==.',['�']='龙逸轩:AwACCAYABRQCBQACAQjWKQAqvpMABRQABQACAQjWKQAqvpMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end