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
 local lookup = {'Unknown-Unknown','Paladin-Protection','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Warrior-Fury','Warrior-Arms','Priest-Discipline',}; local provider = {region='CN',realm='冰风岗',name='CN',type='subscribers',zone=42,date='2025-04-15',data={Ju='Judger:AwEICAgABAoAAQEAAAAICAMABRQ=.',Le='Leadenlight:AwEGCAwABRQCAgAGAQjaAQAqg1MBBRQGwQsAAAIAOsILAAACAEfDCwAAAgAvxAsAAAIAE8ULAAACAAnGCwAAAgAZAgAGAQjaAQAqg1MBBRQGwQsAAAIAOsILAAACAEfDCwAAAgAvxAsAAAIAE8ULAAACAAnGCwAAAgAZAA==.Leoyw:AwEGCBIABRQEAwAGAQh2AABRFPwBBRQGwQsAAAQAUMILAAAEAF/DCwAABABXxAsAAAQASsULAAABADDGCwAAAQBcAwAGAQh2AABQGPwBBRQGwQsAAAEAUMILAAABAF/DCwAAAQBSxAsAAAEASsULAAABADDGCwAAAQBcBAADAQh3BwA8++QABRQDwQsAAAEAScILAAABABXDCwAAAQBXBQAEAQgDAwAgXdkABRQEwQsAAAIANMILAAACACrDCwAAAgABxAsAAAMAHgEBAAAACAgDAAUU.',Lx='Lxmage:AwEICAgABAoAAA==.',To='Tolossus:AwEICAwABRQDBgAGAQjmAwA/2zoBBRQGwwsAAAIAPcQLAAACACbFCwAAAgBfxgsAAAIAIccLAAACADXICwAAAgBLBgAEAQjmAwBNjjoBBRQEwwsAAAIAPcQLAAACACbFCwAAAgBfyAsAAAIASwcAAgEIbQcAK0/AAAUUAsYLAAACACHHCwAAAgA1AA==.',['�']='白白的小月亮:AwEFCBQABRQCCAAFAQiiAQBSnIcBBRQFwQsAAAYAWMILAAAFAFrDCwAABABcxAsAAAMAUsULAAACADoIAAUBCKIBAFKchwEFFAXBCwAABgBYwgsAAAUAWsMLAAAEAFzECwAAAwBSxQsAAAIAOgA=.',['�']='胜天偌水:AwEGCAkABRQDBgAGAQjIAQAowYUBBRQGwQsAAAMAXsILAAACAEHFCwAAAQASxgsAAAEAIccLAAABAArICwAAAQAWBgAEAQjIAQAyJ4UBBRQEwQsAAAMAXsILAAACAEHFCwAAAQASyAsAAAEAFgcAAgEILQgAFfS5AAUUAsYLAAABACHHCwAAAQAKAQYAP9sICAwABRQ=.',['�']='韦恩鲁尼:AwEECAQABRQAAQEAAAAICAMABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end