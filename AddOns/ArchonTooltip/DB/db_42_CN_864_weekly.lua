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
 local lookup = {'Hunter-BeastMastery','DemonHunter-Havoc','DeathKnight-Unholy','Evoker-Devastation','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Shaman-Elemental',}; local provider = {region='CN',realm='阿扎达斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ah='Ahkam:AwACCAIABRQAAA==.',Ar='Arlsa:AwAECAcABAoAAA==.',Mo='Months:AwAECAQABRQAAA==.',Ti='Tima:AwAECAgABRQCAQAEAQgsFgAxe+oABRQAAQAEAQgsFgAxe+oABRQAAA==.',['�']='伊波拉:AwAECAQABRQAAA==.伊邪那岐丶:AwAGCA4ABRQCAgAGAQh/AABXYB8CBRQAAgAGAQh/AABXYB8CBRQAAA==.',['�']='依然情殇:AwAECAQABRQAAA==.',['�']='初七:AwAECAcABAoAAA==.',['�']='劳斯丹顿:AwACCAMABRQCAwAIAQjRDgBVTpgCBAoAAwAIAQjRDgBVTpgCBAoAAA==.',['�']='只给男人发烟:AwABCAIABRQAAA==.',['�']='地狱灬:AwACCAYABRQCAwAIAQhALQA3/toBBAoAAwAIAQhALQA3/toBBAoAAA==.',['�']='大佬黄灬:AwAHCAcABAoAAA==.天心:AwAECAQABRQAAA==.',['�']='妹思他棒威:AwADCAMABAoAAA==.',['�']='姜明孓:AwADCAMABAoAAA==.',['�']='尐给给:AwAECAgABRQCBAAEAQi5CgAyWeEABRQABAAEAQi5CgAyWeEABRQAAA==.少女彐白洁:AwAECAQABRQAAA==.少女的梦:AwAECAEABAoAAA==.',['�']='影羽:AwACCAcABRQDAgACAQhsJAAhsYAABRQAAgACAQhsJAAhsYAABRQABQABAQhOFgAVkTEABRQAAA==.',['�']='性感的狗蛋:AwAGCAQABRQDBgAEAQh9BQBZLyMBBRQABgADAQh9BQBZLyMBBRQABwABAQg7GQAAAAAABRQAAA==.',['�']='战牛在野:AwAECAIABRQAAA==.',['�']='断绝末路:AwAICAkABAoAAQgAAAAICA4ABAo=.',['�']='无常美纳斯:AwABCAEABRQAAA==.',['�']='枫子:AwAFCAYABAoAAQEAVPUDCAoABRQ=.',['�']='海英特:AwAICAMABAoAAA==.',['�']='湮糖:AwAECAQABRQAAA==.',['�']='滥精灵:AwABCAEABRQAAA==.',['�']='火龙伊格尼尔:AwACCAMABRQAAA==.灬神牛:AwACCAUABRQCCQACAQgxEQAZf3oABRQACQACAQgxEQAZf3oABRQAAA==.灵魂毁灭者:AwAICAIABAoAAQgAAAAICAQABRQ=.',['�']='爱贫嘴的猫:AwAGCAYABAoAAA==.',['�']='狼铛:AwAICA4ABAoAAA==.',['�']='筱绿绿:AwABCAEABRQAAA==.',['�']='织法者:AwAICA4ABAoAAA==.',['�']='霜寒裁决使:AwACCAMABRQAAA==.',['�']='风里有詩句:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end