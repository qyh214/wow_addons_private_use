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
 local lookup = {'Paladin-Retribution','Warlock-Affliction','Druid-Balance','Priest-Discipline','Priest-Shadow','Warrior-Fury','Paladin-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Rogue-Subtlety','Mage-Fire','Mage-Frost','Warrior-Arms',}; local provider = {region='CN',realm='达斯雷玛',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ma='Makoto:AwAICBcABAoCAQAIAQgVLwBGL04CBAoAAQAIAQgVLwBGL04CBAoAAA==.',Xx='Xxiao:AwADCAMABAoAAA==.',['�']='一无情一:AwAECAMABAoAAA==.一黄金太阳一:AwAECAQABAoAAA==.不吃靖哥哥:AwAICAgABAoAAA==.丶青莲剑歌:AwAHCAcABAoAAA==.',['�']='仁狐:AwAGCBUABAoCAgAGAQj/KAAGd5kABAoAAgAGAQj/KAAGd5kABAoAAA==.仙咕丶:AwACCAQABRQCAwAIAQhIOQAqjasBBAoAAwAIAQhIOQAqjasBBAoAAA==.',['�']='你压我头发了:AwAECAQABRQAAA==.你又:AwACCAIABAoAAA==.你还有遗憾吗:AwADCAEABAoAAA==.',['�']='倚天箭:AwAHCAcABAoAAA==.',['�']='元宝大神:AwACCAIABAoAAA==.关云短灬:AwAECAQABRQAAA==.',['�']='再长一百斤:AwAECAQABRQAAA==.冰糖葫璐儿:AwADCAQABAoAAA==.',['�']='凝乐:AwAICAcABAoAAA==.',['�']='别特耀跳了:AwAGCAYABAoAAA==.',['�']='勤瘦:AwAICAwABAoAAA==.勥丨夜殇:AwAHCAMABAoAAA==.勥丨審判:AwAGCA8ABAoAAA==.',['�']='千万伏特:AwACCAIABRQAAA==.',['�']='叶子要飞了:AwADCAMABAoAAA==.',['�']='后半夜的鱼:AwAECAIABRQAAA==.',['�']='哎呀丶难顶:AwAECA8ABRQDBAAEAQhpCwBTJeIABRQABAADAQhpCwBhbuIABRQABQABAQjkGwA8TVYABRQAAA==.',['�']='夜雨风轻:AwACCAMABAoAAA==.大叔就是好:AwAHCAcABAoAAA==.大司命:AwADCAMABRQAAA==.大胡子:AwAGCA4ABRQDBAAGAQirAABG3OgBBRQABAAGAQirAABG3OgBBRQABQAEAQgcDAA0zecABRQAAA==.',['�']='妖妖零:AwAECAoABRQCBgAEAQhGDAA+Bf4ABRQABgAEAQhGDAA+Bf4ABRQAAA==.',['�']='娇滴滴的肉丸:AwABCAEABRQAAA==.',['�']='守门大爷:AwADCAQABAoAAA==.',['�']='寂寞长天:AwACCAIABAoAAA==.',['�']='小豆角:AwAICAgABAoAAA==.尘暮夕:AwADCAEABAoAAA==.',['�']='屠龙刀:AwAGCAkABAoAAA==.',['�']='扎个双马尾丶:AwAGCAEABAoAAA==.打个栗子:AwAICB8ABAoCAQAIAQhvLwBP+k0CBAoAAQAIAQhvLwBP+k0CBAoAAA==.',['�']='改名也叫牛德:AwABCAEABAoAAA==.',['�']='星耀梵空:AwAICAgABAoAAA==.',['�']='月丶夜神:AwAGCBMABAoAAA==.木子:AwAECAQABAoAAA==.木子一小德:AwACCAIABAoAAA==.木子一恶魔:AwADCAMABAoAAA==.木子一牧:AwAGCAIABAoAAA==.',['�']='梦里回梦如她:AwAICDYBBAoDAQAIAQjeAABjpScDBAoAAQAIAQjeAABjpScDBAoABwACAQhPVAAaqS4ABAoAAA==.',['�']='清蒸狮子头:AwAICAYABAoAAA==.',['�']='灬孽魂:AwAFCAUABAoAAA==.',['�']='爆射你的狗头:AwAECAQABRQAAA==.',['�']='版本福利:AwAECAQABRQAAA==.',['�']='简娜:AwAECA0ABRQDCAAEAQjrFwAbsMwABRQACAAEAQjrFwAbsMwABRQACQACAQjpEQAEFUkABRQAAA==.',['�']='米奈希尔灬灵:AwAECAYABRQDCgAEAQgVFAAUt7oABRQACgAEAQgVFAATc7oABRQACwACAQhcHAAEukAABRQAAA==.',['�']='索大爷:AwAECAIABAoAAA==.',['�']='红葱哥:AwAECAQABRQAAQwAAAAICAQABRQ=.',['�']='绅士疯范:AwADCAMABAoAAA==.',['�']='芝士小猫:AwAICAMABAoAAA==.',['�']='菜瓜:AwAECAQABRQAAA==.',['�']='薇尔麗特:AwAECAQABRQAAA==.',['�']='血祭天涯:AwAICBcABAoDCgAIAQjcKABSevABBAoACgAIAQjcKABSevABBAoACwAGAQjKRAAMVYYABAoAAQ0AQKsECAYABRQ=.',['�']='調戲伱:AwAGCAkABAoAAA==.',['�']='诺基亚:AwACCAIABAoAAA==.诺米叔叔:AwADCAgABRQDDgADAQg4HgAZmckABRQADgADAQg4HgAZmckABRQADwABAQg1HwAD/RwABRQAAA==.',['�']='闹来闹去:AwAICA4ABAoAAA==.',['�']='青岛大姨:AwAGCA0ABRQDEAAGAQipAAAxw8ABBRQAEAAGAQipAAAwb8ABBRQABgAEAQg3CwA6ggMBBRQAAA==.',['�']='麦淇酪灬幻西:AwAICAkABAoAAA==.',['�']='黑旋风儿:AwAICA8ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end