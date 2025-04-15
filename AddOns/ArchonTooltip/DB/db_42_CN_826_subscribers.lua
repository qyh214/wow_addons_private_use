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
 local lookup = {'Priest-Discipline','DeathKnight-Blood','Unknown-Unknown','Priest-Holy','Mage-Fire','Druid-Balance','Warlock-Demonology','Warlock-Destruction','Shaman-Enhancement','Shaman-Elemental','Warlock-Affliction','Monk-Mistweaver','Druid-Restoration',}; local provider = {region='CN',realm='血色十字军',name='CN',type='subscribers',zone=42,date='2025-04-15',data={He='Hera:AwEICA0ABAoAAA==.',['�']='上官吻唲:AwEDCAMABAoAAQEAUkgBCAIABRQ=.不玩地精都菜:AwEECAwABRQCAgAEAQjMDQAlmrQABRQEwQsAAAQAE8ILAAAEABvDCwAAAwBCxAsAAAEAWQIABAEIzA0AJZq0AAUUBMELAAAEABPCCwAABAAbwwsAAAMAQsQLAAABAFkA.',['�']='似笑丨非笑:AwEICAgABAoAAA==.',['�']='傲慢的毛毛:AwEBCAEABAoAAQMAAAAICAMABRQ=.',['�']='凛兮:AwEBCAIABRQDAQAIAQjwCQBSSHQCBAoIwQsAAAQAScILAAAEAGHDCwAABABbxAsAAAQAUMULAAAEAFbGCwAABABSxwsAAAQAWsgLAAAEADcBAAgBCPAJAFJIdAIECgjBCwAAAwBJwgsAAAMAYcMLAAADAFvECwAAAwBQxQsAAAMAVsYLAAADAFLHCwAAAwBayAsAAAMANwQACAEIZEQACxgAAQQKCMELAAABAAXCCwAAAQANwwsAAAEAJ8QLAAABACLFCwAAAQAFxgsAAAEAAMcLAAABAAPICwAAAQAJAA==.',['�']='剑屿:AwECCAIABRQAAQMAAAAICAMABRQ=.',['�']='啾啾呀丶:AwEECAQABRQAAQUAPOkGCA4ABRQ=.',['�']='夾子:AwEICAgABAoAAA==.',['�']='心伊丶:AwEICAgABAoAAQEAUkgBCAIABRQ=.',['�']='枭月丷:AwEDCAoABRQCBgADAQjpAgBhvVUBBRQDwQsAAAQAY8ILAAADAGDDCwAAAwBhBgADAQjpAgBhvVUBBRQDwQsAAAQAY8ILAAADAGDDCwAAAwBhAA==.',['�']='水墨箜篌引:AwEECAQABRQAAQMAAAAICAMABRQ=.',['�']='灬一叶之秋:AwEECAwABRQDBwAEAQiYAQBcIhIBBRQEwQsAAAMAVsILAAADAGLDCwAAAwBbxAsAAAMANQgABAEI9AMAWZM6AQUUBMELAAACAE7CCwAAAgBiwwsAAAIAW8QLAAACADAHAAQBCJgBAEfWEgEFFATBCwAAAQBWwgsAAAEAS8MLAAABADbECwAAAQA1AQMAAAAICAMABRQ=.灰麟:AwEECAcABRQDCQAEAQiWCABGPPcABRQEwQsAAAIASsILAAACADjDCwAAAgBPxAsAAAEAMgkAAwEIlggARjz3AAUUA8ELAAACAErCCwAAAgA4wwsAAAIATwoAAQEIfBsAAAAAAAUUAcQLAAABADIBAwAAAAgIAwAFFA==.',['�']='白魔仙:AwEHCAsABAoAAQEAUkgBCAIABRQ=.',['�']='笑丶君:AwEICAgABAoAAQMAAAAICAMABRQ=.',['�']='绿色喷火龙:AwEECAQABRQAAA==.',['�']='蜀黍给你糖吃:AwEGCAcABRQECAAGAQgLBgBXohwBBRQGwQsAAAEAWMILAAACAE/DCwAAAQBPxAsAAAEAQ8ULAAABAGPGCwAAAQBbCAADAQgLBgBM3xwBBRQDwgsAAAEAKMULAAABAGPGCwAAAQBbCwADAQiIBQBSivkABRQDwQsAAAEAWMILAAABAE/DCwAAAQBPBwABAQjKGAAAAAAABRQBxAsAAAEAQwEDAAAACAgDAAUU.',['�']='诸国化为火海:AwEHCBgABAoCDAAHAQg2FgBRzCMCBAoHwQsAAAUAVsILAAAFAGDDCwAABABfxAsAAAQAP8ULAAADAC/GCwAAAgBSxwsAAAEAUgwABwEINhYAUcwjAgQKB8ELAAAFAFbCCwAABQBgwwsAAAQAX8QLAAAEAD/FCwAAAwAvxgsAAAIAUscLAAABAFIA.',['�']='饿的两眼放光:AwECCAIABRQAAQMAAAAICAMABRQ=.',['�']='香椿:AwEICAgABAoAAQMAAAAICAMABRQ=.香辣兰花蟹:AwEGCAoABRQDBgAGAQiLFwAYWsQABRQGwQsAAAIAA8ILAAACADvDCwAAAgAOxAsAAAIAPMULAAABAATGCwAAAQAmBgAEAQiLFwATGcQABRQEwQsAAAEAA8MLAAACAA7ECwAAAQA8xgsAAAEAJg0ABAEIwQoAExfAAAUUBMELAAABAA3CCwAAAgAfxAsAAAEABMULAAABAAsA.',['�']='麦明河丷:AwEICA8ABAoAAQMAAAAICAMABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end