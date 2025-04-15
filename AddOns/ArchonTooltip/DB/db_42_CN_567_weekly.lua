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
 local lookup = {'DeathKnight-Unholy','Shaman-Restoration','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='伊兰尼库斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={At='Atheistkk:AwAICAcABAoAAA==.',Au='Auroray:AwADCAgABRQCAQADAQgzDAAwz+kABRQAAQADAQgzDAAwz+kABRQAAA==.',Bl='Bliztwing:AwABCAEABAoAAA==.',Dz='Dzzqa:AwABCAEABRQAAA==.',Ev='Evelynn:AwABCAIABRQCAgAIAQgnKQA8McIBBAoAAgAIAQgnKQA8McIBBAoAAA==.',Tw='Twoblack:AwAHCAgABAoAAA==.',['�']='乔雯暮风:AwAICAcABAoAAQMAAAAECAQABRQ=.乔雯迅刃:AwAECAQABRQAAA==.乔雯雪晨:AwAICBAABAoAAQMAAAAECAQABRQ=.',['�']='哆啦默默:AwADCAMABRQAAA==.',['�']='圣光忽悠我:AwAECAQABRQAAA==.',['�']='基尔加蛋灬:AwAECAQABRQAAQMAAAAGCAQABRQ=.',['�']='安之的提款机:AwAGCAYABAoAAA==.',['�']='月海鱼鱼猫:AwADCAYABRQDBAADAQijCgA3BdkABRQABAADAQijCgA3BdkABRQABQABAQgYCQAbujkABRQAAA==.',['�']='极限了:AwACCAIABRQAAA==.',['�']='残颜飭戀:AwAICA4ABAoAAA==.',['�']='混沌灬奎托斯:AwAGCAgABAoAAA==.',['�']='红茶灬恋:AwAICAgABAoAAA==.',['�']='聪聪呆:AwAICBAABAoAAQIAPDEBCAIABRQ=.',['�']='薇尔莉特:AwAHCAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end