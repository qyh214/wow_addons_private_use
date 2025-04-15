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
 local lookup = {'Warlock-Destruction','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Warrior-Arms','Warrior-Fury','Priest-Shadow','Priest-Discipline',}; local provider = {region='CN',realm='拉贾克斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Co='Cosima:AwABCAEABAoAAA==.',Sy='Sylvanassulu:AwAGCAIABRQAAQEALloHCAYABRQ=.',['�']='吴臭臭:AwADCAMABAoAAA==.',['�']='失落丶圣光:AwAICAgABAoAAA==.',['�']='孙媳妇:AwAECAQABRQAAA==.',['�']='小巴特儿:AwABCAEABAoAAA==.',['�']='御殿月将军:AwAECAQABAoAAQIAAAABCAEABRQ=.',['�']='惹噜啾咪厚:AwABCAMABRQDAwAIAQg5FABdJD8CBAoAAwAHAQg5FABcOj8CBAoABAAIAQgtFQBAAxsCBAoAAA==.',['�']='放纵:AwAICA4ABAoAAA==.',['�']='月神玥:AwAICAYABAoAAA==.',['�']='树與静风不止:AwAECAQABRQAAA==.',['�']='此生不换:AwABCAEABRQDBQAIAQiSDABAXkACBAoABQAHAQiSDABAXkACBAoABgABAQhujwAAAAAABAoAAA==.',['�']='毁灭术:AwACCAIABRQAAA==.',['�']='汤米谢尔比:AwAHCAcABAoAAA==.',['�']='流年:AwAECAQABRQAAA==.',['�']='独木秀于林:AwAECAQABRQAAA==.',['�']='聖骑士:AwAGCAoABAoAAA==.',['�']='艾丽丝丶杨:AwAICBsABAoDBwAIAQhHEABUWEcCBAoABwAHAQhHEABWmEcCBAoACAADAQh7RgA5t84ABAoAAA==.',['�']='蝌蚪绣蛤蟆:AwACCAQABAoAAA==.',['�']='银哇:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end