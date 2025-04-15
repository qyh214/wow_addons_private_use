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
 local lookup = {'Warlock-Destruction','Shaman-Restoration','Hunter-BeastMastery',}; local provider = {region='CN',realm='古达克',name='CN',type='weekly',zone=42,date='2025-04-14',data={Go='Goosh:AwAECAMABRQAAA==.',Ir='Irene:AwAICA8ABAoAAA==.',Ke='Keiran:AwAFCAUABAoAAA==.',Yl='Ylz:AwAFCAUABAoAAA==.',['�']='丶泪残:AwAECAQABAoAAA==.',['�']='克丽丝叮:AwAICAgABAoAAA==.兜率陀天:AwACCAIABAoAAA==.',['�']='堕落暗影:AwAECAkABRQCAQAEAQj4CgA5PugABRQAAQAEAQj4CgA5PugABRQAAA==.',['�']='小手菇凉:AwAICBIABAoAAA==.',['�']='引英雄尽折腰:AwACCAIABAoAAA==.',['�']='惩戒神罚众生:AwAGCAcABAoAAA==.',['�']='摯热的月亮:AwAFCAkABAoAAA==.',['�']='月光德:AwAECAQABRQAAA==.',['�']='柳丶岩:AwACCAIABAoAAA==.',['�']='牛气乂十足:AwABCAIABRQCAgAIAQh1KQA1ecABBAoAAgAIAQh1KQA1ecABBAoAAA==.',['�']='脸上的小人物:AwAGCAYABAoAAA==.',['�']='艾因湿毯:AwAECAQABRQAAA==.',['�']='让哥摸一下:AwAICAwABAoAAA==.',['�']='都不能缺德:AwAICAcABAoAAA==.',['�']='鸭鸭樂:AwADCAYABRQCAwADAQg2EAA9bfgABRQAAwADAQg2EAA9bfgABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end