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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Blood','DemonHunter-Havoc','Evoker-Devastation','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Rogue-Subtlety','Unknown-Unknown','Monk-Mistweaver',}; local provider = {region='CN',realm='纳沙塔尔',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ch='Chiron:AwACCAIABRQDAQAIAQg4EgBCiRoCBAoAAQAIAQg4EgBCiRoCBAoAAgACAQge4AAT8U0ABAoAAA==.',Ir='Ireliia:AwAFCAgABRQCAwAEAQhsBgBNsgsBBRQAAwAEAQhsBgBNsgsBBRQAAQMARwgGCAkABRQ=.',Re='Recovery:AwACCAMABAoAAA==.',Yi='Yigedh:AwACCAYABRQCBAACAQiXGQBIlb8ABRQABAACAQiXGQBIlb8ABRQAAA==.',['�']='三魂之玉:AwACCAEABAoAAA==.',['�']='伊德海拉:AwAECAIABRQAAA==.',['�']='依文:AwACCAIABRQCAwAIAQgZEQBB8wcCBAoAAwAIAQgZEQBB8wcCBAoAAA==.',['�']='倦鸟余花:AwACCAIABRQAAA==.',['�']='偷塑料贼:AwADCAwABRQCBQADAQhhCABIrvUABRQABQADAQhhCABIrvUABRQAAA==.',['�']='冻感钞人:AwAICAYABAoAAA==.',['�']='凡事:AwAGCAkABAoAAA==.',['�']='半拉柯基:AwADCAcABRQDBgADAQiuDQAk1ngABRQABgACAQiuDQAh6XgABRQABAABAQjBKAAqr1MABRQAAA==.卡琳:AwACCAIABRQDAgAIAQgDPgBKAeIBBAoAAgAHAQgDPgBJN+IBBAoAAQAGAQjfLAA6pFABBAoAAA==.',['�']='吥懂:AwAECAQABRQAAA==.',['�']='周米粒:AwAICAgABAoAAA==.',['�']='四枫院夜一:AwAFCAEABRQEBwAIAQgFGQBLCx8CBAoABwAIAQgFGQBF4B8CBAoACAAGAQhhEABLrV8BBAoACQADAQimRAA+wZoABAoAAQkAVmAHCAcABRQ=.',['�']='圣光忽悠着我:AwAECAQABAoAAA==.',['�']='妈宝小周周:AwADCAMABRQAAA==.',['�']='子非雨:AwAICAgABAoAAA==.',['�']='戈德莉亚:AwABCAEABRQAAA==.我是胖子丶:AwACCAIABRQAAA==.',['�']='月丸吨:AwAECAYABRQDAQAEAQiCAQBeIUABBRQAAQAEAQiCAQBeIUABBRQAAgACAQgRKwA0go4ABRQAAA==.',['�']='杀破羊:AwACCAIABRQCCgAIAQheDwAvrfEBBAoACgAIAQheDwAvrfEBBAoAAA==.',['�']='柯基丶:AwACCAIABRQAAA==.',['�']='渐渐遠去的心:AwAHCAYABAoAAA==.',['�']='猫貓拳:AwACCAIABRQAAA==.',['�']='盆心源:AwABCAEABRQAAA==.',['�']='祈求神灵之人:AwABCAEABRQAAA==.',['�']='科斯塔:AwABCAEABRQAAA==.',['�']='繁华落尽丶:AwABCAEABRQAAA==.',['�']='纷濑绘里:AwAECAQABRQAAA==.',['�']='艾莉塔:AwAECAQABRQAAA==.',['�']='莫宁斯塔:AwAICAgABAoAAA==.莫小加:AwACCAIABRQAAA==.',['�']='虾仁猪心:AwAGCA8ABAoAAA==.',['�']='透明风:AwAGCAcABAoAAA==.',['�']='郁雪落寞:AwAECAQABRQAAA==.',['�']='释寰:AwAICAUABAoAAQsAAAAECAIABRQ=.野笔大雄:AwAECAQABRQCDAAIAQjKDABQz3cCBAoADAAIAQjKDABQz3cCBAoAAA==.',['�']='雪尘:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end