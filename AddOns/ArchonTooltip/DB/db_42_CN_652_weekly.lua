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
 local lookup = {'DeathKnight-Unholy','Paladin-Retribution','Paladin-Holy','Mage-Frost','Druid-Balance','Shaman-Restoration','Mage-Fire',}; local provider = {region='CN',realm='安戈洛',name='CN',type='weekly',zone=42,date='2025-04-14',data={De='Deepdarkboys:AwACCAQABRQCAQAIAQihEABTpYECBAoAAQAIAQihEABTpYECBAoAAA==.',Di='Dissolute:AwACCAIABRQAAA==.',Nu='Nukoo:AwAFCA8ABAoAAA==.',Re='Reality:AwACCAIABRQAAA==.',Sa='Salmon:AwADCAUABAoAAA==.',Se='Seekingheart:AwAECAQABRQAAA==.',Su='Summers:AwAICAgABAoAAA==.',Yi='Yikecong:AwAECAQABRQAAA==.',['�']='万种风情:AwAECAYABAoAAA==.丨阿布灬:AwAGCAYABAoAAA==.丶简兮:AwAGCAYABAoAAA==.丶苍山负雪:AwACCAIABRQAAA==.',['�']='乌夜啼:AwABCAEABRQAAQIAYAQECAIABRQ=.',['�']='五条五:AwACCAIABRQAAA==.',['�']='初初:AwAECAQABRQAAA==.',['�']='哭泣的维纳斯:AwACCAIABRQCAwAHAQj2GwAv5lEBBAoAAwAHAQj2GwAv5lEBBAoAAA==.',['�']='天外飞仙一:AwABCAEABAoAAA==.',['�']='奥利给给:AwAECAQABRQAAA==.奶蓟草:AwADCAMABAoAAA==.',['�']='如梦令:AwAICAgABAoAAA==.',['�']='宴清都:AwAECAIABRQCAgAHAQijHQBgBIoCBAoAAgAHAQijHQBgBIoCBAoAAA==.',['�']='寂静的心:AwAECAQABRQAAA==.',['�']='尾巴控:AwAHCAgABAoAAA==.',['�']='微笑时好美:AwAICAwABAoAAA==.',['�']='心橙自由:AwAHCBIABAoAAA==.',['�']='我有神经冰:AwACCAIABRQCBAAGAQhiQAAuljUBBAoABAAGAQhiQAAuljUBBAoAAA==.',['�']='拿得起放得下:AwAGCBIABAoAAA==.',['�']='无限混:AwACCAIABRQCBQAHAQh7IwBLNhICBAoABQAHAQh7IwBLNhICBAoAAA==.',['�']='渐入佳境:AwACCAIABAoAAA==.',['�']='滚滚:AwAHCBwABAoCBgAHAQhUGQBSBhsCBAoABgAHAQhUGQBSBhsCBAoAAA==.',['�']='炸清:AwAECAgABRQCAgAEAQjZCQBYVRgBBRQAAgAEAQjZCQBYVRgBBRQAAA==.',['�']='田里的雪:AwAGCAYABAoAAA==.',['�']='神棍:AwACCAIABRQAAA==.神秘巨星:AwABCAEABAoAAA==.神马都是浮云:AwAGCAwABAoAAA==.',['�']='秦天:AwAGCAYABAoAAA==.',['�']='绮葛龙丶苳蔷:AwAGCAoABAoAAA==.',['�']='艾秋:AwAFCA8ABAoAAA==.',['�']='虎眼流一清玄:AwAECAcABAoAAA==.',['�']='血珊瑚:AwACCAIABRQCBwAHAQjMFgBY4V0CBAoABwAHAQjMFgBY4V0CBAoAAA==.行简丶:AwAGCAUABAoAAA==.',['�']='观硬大师:AwAECAQABAoAAA==.',['�']='诚心诚意:AwAECBAABRQCBAAEAQhMBQBAYvEABRQABAAEAQhMBQBAYvEABRQAAA==.',['�']='还是不够黑:AwABCAEABAoAAA==.',['�']='逍遥蘑菇仙人:AwABCAEABAoAAA==.',['�']='醉仙望月步:AwACCAIABRQAAA==.',['�']='阿尔托莉雅丶:AwAGCBMABAoAAA==.',['�']='风留人物:AwADCAEABRQDAgAIAQjrRgBFwPcBBAoAAgAHAQjrRgBKSPcBBAoAAwAEAQgFJgAoh/QABAoAAA==.',['�']='鱼鱼碗里来:AwACCAIABAoAAA==.',['�']='黑白辉:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end