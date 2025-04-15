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
 local lookup = {'Hunter-BeastMastery','Druid-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Shadow','DeathKnight-Unholy',}; local provider = {region='CN',realm='冰川之拳',name='CN',type='weekly',zone=42,date='2025-04-14',data={Az='Azreal:AwACCAYABRQCAQACAQh/JgArQ5EABRQAAQACAQh/JgArQ5EABRQAAA==.',Ba='Ballangel:AwAICAgABAoAAA==.',Dm='Dmevo:AwABCAEABRQAAA==.',Po='Poseidon:AwACCAUABRQCAgACAQjpEwAT42oABRQAAgACAQjpEwAT42oABRQAAA==.',Vu='Vulcano:AwABCAMABRQAAA==.',['�']='不至于:AwAHCAcABAoAAA==.丨出云丨:AwAFCAMABAoAAA==.丨吹雪丨:AwABCAEABAoAAA==.丨海风丨:AwACCAIABAoAAA==.丨深雪丨:AwAFCAcABAoAAA==.',['�']='人民的好骑士:AwAICAMABAoAAA==.',['�']='依然小悟空:AwABCAEABRQAAA==.',['�']='卟德嘹:AwABCAEABRQAAA==.',['�']='吖丨小小丨吖:AwAICBkABAoDAwAIAQiKHwBWHScCBAoAAwAIAQiKHwBWHScCBAoABAAIAQh+GAA1QJEBBAoAAA==.',['�']='奶的好:AwAHCAQABAoAAA==.',['�']='寒木春华:AwAFCAEABAoAAA==.',['�']='尕番茄丶:AwAFCAUABAoAAA==.',['�']='帅气野牛:AwAGCAkABAoAAA==.',['�']='幸运星:AwAICAsABAoAAA==.',['�']='德世一:AwAECAQABRQAAQUAN1QGCAYABRQ=.',['�']='心之所望:AwAHCAgABAoAAA==.',['�']='我一个放狗:AwACCAIABRQAAA==.',['�']='拥抱开始:AwAECAUABRQCBgAEAQgODwAikdUABRQABgAEAQgODwAikdUABRQAAA==.',['�']='擒封希于桑林:AwABCAEABRQAAA==.',['�']='月照故里:AwAFCAYABAoAAA==.',['�']='没事瞎溜达:AwADCAIABAoAAA==.',['�']='洛克洛克:AwAICAIABAoAAA==.',['�']='百变小鸡:AwABCAEABAoAAA==.',['�']='裘猫:AwABCAEABRQAAA==.',['�']='达文西:AwABCAEABRQAAA==.',['�']='过年好丫:AwAICA8ABAoAAA==.这里是哪里:AwAFCAIABAoAAA==.',['�']='部落的小神僧:AwAECAQABRQAAA==.',['�']='闹眼字:AwAECAQABRQAAA==.',['�']='风干的香蕉:AwAFCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end