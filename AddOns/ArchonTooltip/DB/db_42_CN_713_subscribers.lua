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
 local lookup = {'Warlock-Affliction','Warlock-Demonology','Shaman-Enhancement','Paladin-Protection','Warlock-Destruction','DeathKnight-Frost','Unknown-Unknown','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='格瑞姆巴托',name='CN',type='subscribers',zone=42,date='2025-04-15',data={La='Lalaland:AwEGCAkABRQDAQAGAQhEAABVB5IBBRQGwQsAAAIAYMILAAACAFbDCwAAAgBSxAsAAAEAY8ULAAABAFbGCwAAAQBKAQAEAQhEAABUvpIBBRQEwQsAAAIAYMILAAACAFbDCwAAAgBSxgsAAAEASgIAAgEItAkAVilnAAUUAsQLAAABAGPFCwAAAQBWAQMAKMUICAwABRQ=.',Si='Sicklikemé:AwEICAgABAoAAQQALPIGCA4ABRQ=.',['�']='千域:AwEICAgABAoAAQQALPIGCA4ABRQ=.',['�']='奶白得雪子:AwEDCAoABRQDAQADAQh7BgA0ifEABRQDwQsAAAUANcILAAADADrDCwAAAgAtAQADAQh7BgAz1/EABRQDwQsAAAIAM8ILAAABADrDCwAAAgAtBQACAQjpGwA0PYUABRQCwQsAAAMANcILAAACADMBAwAoxQgIDAAFFA==.',['�']='小光有意:AwEECBEABRQCBgAEAQjXAABXISwBBRQEwQsAAAUAWMILAAAFAFXDCwAABABXxAsAAAMAUQYABAEI1wAAVyEsAQUUBMELAAAFAFjCCwAABQBVwwsAAAQAV8QLAAADAFEA.小动物爱吃果:AwEICAkABAoAAA==.',['�']='快雪時晴丶:AwEECAQABRQAAQMAKMUICAwABRQ=.',['�']='美味丨蟹黄堡:AwEICAwABRQCAwAIAQg0AAAoxWgCBRQIwQsAAAIAQsILAAACADbDCwAAAgAcxAsAAAIARsULAAABAAjGCwAAAQAuxwsAAAEAE8gLAAABAD0DAAgBCDQAACjFaAIFFAjBCwAAAgBCwgsAAAIANsMLAAACABzECwAAAgBGxQsAAAEACMYLAAABAC7HCwAAAQATyAsAAAEAPQA=.',['�']='苏生栗子球丶:AwECCAIABAoAAQcAAAAICAwABAo=.',['�']='铁拳凌晓雨:AwEECA4ABRQDCAAEAQjOBgBI4gABBRQEwQsAAAUAXcILAAAEAD7DCwAABAA+xAsAAAEAJAgABAEIzgYASOIAAQUUBMELAAAFAF3CCwAAAgA+wwsAAAQAPsQLAAABACQJAAEBCA0iAC+RTQAFFAHCCwAAAgAvAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end