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
 local lookup = {'Warlock-Affliction','Warlock-Destruction','Unknown-Unknown','DeathKnight-Unholy','Paladin-Protection','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver','Druid-Restoration','Druid-Guardian','Druid-Balance','Priest-Discipline','DeathKnight-Blood','Shaman-Enhancement','Shaman-Elemental',}; local provider = {region='CN',realm='燃烧之刃',name='CN',type='subscribers',zone=42,date='2025-04-15',data={In='Incre:AwEGCAYABRQDAQAEAQheBQBBKvoABRQEwQsAAAIAV8ILAAABACrDCwAAAQBBxAsAAAIAOAEABAEIXgUAQSr6AAUUBMELAAABAFfCCwAAAQAqwwsAAAEAQcQLAAABADgCAAIBCLUmAEhlRwAFFALBCwAAAQBIxAsAAAEAMQEDAAAACAgDAAUU.',Li='Lifengdk:AwEICBsABAoCBAAIAQj5EwBNuXACBAoIwQsAAAMARsILAAADAFTDCwAAAwBgxAsAAAQATcULAAAEAEfGCwAABABHxwsAAAMAV8gLAAADAD4EAAgBCPkTAE25cAIECgjBCwAAAwBGwgsAAAMAVMMLAAADAGDECwAABABNxQsAAAQAR8YLAAAEAEfHCwAAAwBXyAsAAAMAPgA=.',My='Mysad:AwEICAgABAoAAQUALPIGCA4ABRQ=.',Yz='Yzss:AwEICA8ABAoAAQMAAAAICAMABRQ=.',Ze='Zetalili:AwEECAMABRQAAQMAAAAGCAMABRQ=.',['�']='丨长崎素世丨:AwEECAkABRQDBQAEAQjpCQA1AJ8ABRQEwQsAAAIAJMILAAADAFzDCwAAAgAdxAsAAAIAEAYABAEI+SIAJZO9AAUUBMELAAABAADCCwAAAgBcwwsAAAEAE8QLAAABAAQFAAQBCOkJACN0nwAFFATBCwAAAQAkwgsAAAEAJ8MLAAABAB3ECwAAAQAQAA==.临青:AwEGCAYABAoAAA==.丶丨混沌丨丶:AwEECAQABRQAAQUALPIGCA4ABRQ=.丶浪巫谣:AwEICBIABRQDBwAHAQhnAQA3MrwBBRQHwQsAAAMAUcILAAADAFHDCwAAAwAvxAsAAAMAOsULAAADAAzGCwAAAgAIyAsAAAEAZAcABgEIZwEALjy8AQUUBsELAAACAFHCCwAAAgBRwwsAAAIAL8QLAAACADrFCwAAAgAMxgsAAAIACAgABgEI0gIAJHN/AQUUBsELAAABAAjCCwAAAQAcwwsAAAEAAsQLAAABAETFCwAAAQBRyAsAAAEAPQA=.',['�']='久久蹦跶一下:AwEECAQABRQAAQUALPIGCA4ABRQ=.',['�']='全要:AwEBCAEABRQAAQMAAAAICAMABRQ=.',['�']='友善和蔼温柔:AwEFCBYABRQECQAFAQhHDABOWrEABRQFwQsAAAUAUsILAAAFAEfDCwAABQA8xAsAAAQAF8ULAAADAGQJAAIBCEcMAEyysQAFFALBCwAAAgBSwgsAAAUARwoAAwEIswIAFkKDAAUUA8ELAAABACrDCwAABQATxQsAAAMABAsAAgEIeSgAVdVPAAUUAsELAAACAFXECwAABAAwAA==.',['�']='吕小冰:AwEECBcABRQCCAAEAQiJBgBObiEBBRQEwQsAAAYAWcILAAAGADrDCwAABgBXxAsAAAUAUAgABAEIiQYATm4hAQUUBMELAAAGAFnCCwAABgA6wwsAAAYAV8QLAAAFAFAA.',['�']='哎哟哎哎:AwEICAIABAoAAQMAAAAICAMABRQ=.',['�']='大圣躯壳:AwEICAgABAoAAQMAAAAICAMABRQ=.',['�']='小临青:AwEDCAMABAoAAQMAAAAGCAYABAo=.小屁骑丶:AwECCAIABRQAAA==.小红手猎老板:AwEGCAQABRQAAQMAAAAICAMABRQ=.',['�']='待宵:AwEICAgABAoAAQwACowGCAYABRQ=.',['�']='暴脾气丶二叔:AwEICBAABAoAAQUALPIGCA4ABRQ=.',['�']='月儿欣欣:AwEICAgABAoAAA==.',['�']='烨嬅:AwEGCAYABRQCBAAHAQhvIABR1yACBAoHwQsAAAMAVMILAAAEAE3DCwAABABUxAsAAAQAVcULAAAFAE/GCwAABABRxwsAAAIAVAQABwEIbyAAUdcgAgQKB8ELAAADAFTCCwAABABNwwsAAAQAVMQLAAAEAFXFCwAABQBPxgsAAAQAUccLAAACAFQA.热烈马:AwEICAgABAoAAQQATbkICBsABAo=.',['�']='玛兜川美:AwEGCAwABAoAAA==.',['�']='米莉姆丶:AwEDCAYABRQCDQADAQi6CQBA3toABRQDwQsAAAMAS8ILAAACAELDCwAAAQA1DQADAQi6CQBA3toABRQDwQsAAAMAS8ILAAACAELDCwAAAQA1AA==.',['�']='花闲泪澜:AwEICAIABAoAAQUALPIGCA4ABRQ=.',['�']='葉拾壹:AwEBCAEABRQDDgAIAQh4BwBcEKoCBAoIwQsAAAQAX8ILAAADAGDDCwAAAwBUxAsAAAMAYcULAAADAF7GCwAAAwBdxwsAAAMAXMgLAAACAFYOAAgBCHgHAFwQqgIECgjBCwAAAwBfwgsAAAIAYMMLAAACAFTECwAAAgBhxQsAAAMAXsYLAAADAF3HCwAAAwBcyAsAAAIAVg8ABAEIukIARQHtAAQKBMELAAABADfCCwAAAQBZwwsAAAEAPsQLAAABADEBAwAAAAgIAwAFFA==.',['�']='路灰灰阿:AwEECAQABRQAAQMAAAAICAMABRQ=.',['�']='重铸踏风荣光:AwEGCAUABRQCBwADAQh2CwAgh88ABRQDwQsAAAIAQsILAAACAA7DCwAAAQARBwADAQh2CwAgh88ABRQDwQsAAAIAQsILAAACAA7DCwAAAQARAA==.',['�']='陈大仙:AwEECAIABRQAAQUALPIGCA4ABRQ=.',['�']='飘逸阿朵:AwEICAcABAoAAQMAAAAICAMABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end