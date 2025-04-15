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
 local lookup = {'Warlock-Destruction','Paladin-Protection','Unknown-Unknown','Shaman-Enhancement','Hunter-BeastMastery','Priest-Holy','Priest-Discipline','Warlock-Affliction','Warrior-Arms','Warrior-Fury','DeathKnight-Unholy','Warlock-Demonology','Shaman-Restoration','Priest-Shadow','Evoker-Devastation','Paladin-Retribution',}; local provider = {region='CN',realm='死亡之翼',name='CN',type='subscribers',zone=42,date='2025-04-15',data={Bx='Bxdest:AwEGCAMABRQCAQAIAQidAABiFxQDBAoIwQsAAAMAYcILAAADAGHDCwAAAwBixAsAAAMAYsULAAADAGPGCwAAAwBjxwsAAAMAYMgLAAADAGIBAAgBCJ0AAGIXFAMECgjBCwAAAwBhwgsAAAMAYcMLAAADAGLECwAAAwBixQsAAAMAY8YLAAADAGPHCwAAAwBgyAsAAAMAYgA=.',Da='Darkdemono:AwECCAIABAoAAQIALPIGCA4ABRQ=.',De='Depressioni:AwEICBAABAoAAQMAAAAICAMABRQ=.',Ga='Galaqs:AwEECAQABRQAAQMAAAAICAMABRQ=.',Ho='Honey:AwEFCAUABAoAAQMAAAAICAMABRQ=.',Je='Jennifer:AwEGCAYABAoAAQMAAAAICAMABRQ=.',Ji='Jieshen:AwEECAIABRQAAQMAAAAICAMABRQ=.',Pi='Pianoss:AwEECAgABRQCAQADAQhtBgBOnBcBBRQDwQsAAAQAX8ILAAADAFbDCwAAAQA1AQADAQhtBgBOnBcBBRQDwQsAAAQAX8ILAAADAFbDCwAAAQA1AA==.',Wa='Warlockshawn:AwEHCAcABAoAAQEAPZgGCAUABRQ=.',Ze='Zetall:AwEECA8ABRQCAgAEAQhxBgA9WtcABRQEwQsAAAMAO8ILAAAEAEDDCwAABAA8xAsAAAQASAIABAEIcQYAPVrXAAUUBMELAAADADvCCwAABABAwwsAAAQAPMQLAAAEAEgBAwAAAAYIAwAFFA==.',['�']='世界萨归来:AwEDCAcABRQCBAADAQggAwBaQz4BBRQDwQsAAAMAV8ILAAADAGLDCwAAAQBUBAADAQggAwBaQz4BBRQDwQsAAAMAV8ILAAADAGLDCwAAAQBUAA==.丶被谎言湮没:AwECCAIABRQAAQMAAAAICAMABRQ=.丸犊子了:AwEECAQABRQAAA==.',['�']='九千七丶德:AwEFCAUABAoAAQUAWP8DCAUABRQ=.九千七丶死:AwEFCAgABAoAAQUAWP8DCAUABRQ=.九千七丶萨:AwEHCAcABAoAAQUAWP8DCAUABRQ=.九千七丶骑:AwECCAIABRQAAQUAWP8DCAUABRQ=.',['�']='冰雪丷:AwEICA0ABAoAAQUAVnoFCBIABRQ=.',['�']='千代田桃子:AwEECAwABRQDBgAEAQi5CABiDt0ABRQEwQsAAAQAX8ILAAAEAGPDCwAAAwBjxAsAAAEAUQYAAgEIuQgAYV7dAAUUAsELAAADAF/DCwAAAwBjBwADAQjMEABPOLYABRQDwQsAAAEAO8ILAAAEAGPECwAAAQBRAA==.',['�']='呜咪灬:AwEDCAQABRQAAA==.',['�']='土豆拌番茄:AwECCAIABRQAAA==.',['�']='塔楼夜语:AwEGCAgABRQDAQAEAQiICQBHPfwABRQEwQsAAAMATsILAAADAFnDCwAAAQAtxAsAAAEALQEABAEIiAkARz38AAUUBMELAAACAE7CCwAAAgBZwwsAAAEALcQLAAABAC0IAAIBCH4RACxchgAFFALBCwAAAQAxwgsAAAEAJwEDAAAACAgDAAUU.',['�']='大北嗷:AwECCAIABAoAAQkAM6oECAoABRQ=.大酋长阿强:AwEFCAcABRQCAQAFAQgbAwA7T08BBRQFwQsAAAIATcILAAACAEHDCwAAAQBKxAsAAAEAOsYLAAABABMBAAUBCBsDADtPTwEFFAXBCwAAAgBNwgsAAAIAQcMLAAABAErECwAAAQA6xgsAAAEAEwEDAAAACAgDAAUU.',['�']='奶奶滴鲁讯:AwECCAUABRQDCQACAQg5DwAcuXYABRQCwQsAAAQAMsILAAABAAYJAAIBCDkPABy5dgAFFALBCwAAAQAywgsAAAEABgoAAQEIAiUAGOFGAAUUAcELAAADABgBAwAAAAQIBAAFFA==.',['�']='巧克力大福:AwEECAUABRQCCwAEAQjcEgAksMUABRQEwQsAAAEANsILAAACAC7DCwAAAQAIxAsAAAEASwsABAEI3BIAJLDFAAUUBMELAAABADbCCwAAAgAuwwsAAAEACMQLAAABAEsA.',['�']='幼儿园小坏蛋:AwECCAIABRQAAQMAAAAICAMABRQ=.',['�']='我就查仨数:AwEECAoABRQDCQAEAQj5BAAzqvgABRQEwQsAAAMAOMILAAADAErDCwAAAgAYxAsAAAIAUAkABAEI+QQAM6r4AAUUBMELAAACADjCCwAAAgBKwwsAAAEAGMQLAAABAFAKAAQBCCERABdx3wAFFATBCwAAAQAbwgsAAAEAHcMLAAABAA3ECwAAAQAKAA==.',['�']='最终闪光:AwEECAQABAoAAQsAJLAECAUABRQ=.术之灬尽头:AwEGCBIABRQDAQAGAQjaAQBQJo8BBRQGwQsAAAQAUsILAAAEAGLDCwAABABWxAsAAAQAMsULAAABAEHGCwAAAQBCAQAFAQjaAQBTuY8BBRQFwQsAAAQAUsILAAAEAGLDCwAABABWxAsAAAMAMsYLAAABAEIMAAIBCBULAEHbXwAFFALECwAAAQAyxQsAAAEAQQEDAAAACAgDAAUU.',['�']='猫猫软糖铺:AwEICAgABAoAAA==.',['�']='球球别奶了:AwEECAYABRQCDQAEAQiRAwBXADQBBRQEwQsAAAIAYcILAAACAFXDCwAAAQBNxAsAAAEAYA0ABAEIkQMAVwA0AQUUBMELAAACAGHCCwAAAgBVwwsAAAEATcQLAAABAGABAwAAAAgIAwAFFA==.',['�']='璞玉乘清风:AwEICBAABAoAAQMAAAAICAMABRQ=.',['�']='白鸽游酒:AwECCAMABRQEBwAIAQiWHAA9rcIBBAoIwQsAAAcAT8ILAAAGADTDCwAABgBHxAsAAAUANMULAAAEAD7GCwAABQBPxwsAAAQAPsgLAAADABYHAAgBCJYcADY8wgEECgjBCwAAAgBDwgsAAAEANMMLAAABAEfECwAAAQArxQsAAAIAPsYLAAABACjHCwAAAgA+yAsAAAIAFgYACAEIGCYANOWXAQQKCMELAAABAE/CCwAAAQAswwsAAAMAR8QLAAACADTFCwAAAQA0xgsAAAQAT8cLAAACABrICwAAAQANDgAFAQhkPQAtcOYABAoFwQsAAAQALsILAAAEADPDCwAAAgAvxAsAAAIAIsULAAABACQA.',['�']='花花家的丫鬟:AwEDCAIABRQAAA==.',['�']='苏莫遮:AwEGCAUABAoAAQIALPIGCA4ABRQ=.',['�']='蝴蝶草:AwEECAsABRQCDwAEAQggCQA+1u4ABRQEwQsAAAQASMILAAADADPDCwAAAwBBxAsAAAEAMA8ABAEIIAkAPtbuAAUUBMELAAAEAEjCCwAAAwAzwwsAAAMAQcQLAAABADAA.',['�']='越谷小鞠:AwEBCAEABRQAAQYAYg4ECAwABRQ=.',['�']='这个憎有点肥:AwEECAQABRQAAA==.这个萨有点肥:AwEICAwABAoAAQMAAAAECAQABRQ=.这个骑有点肥:AwEECAQABRQCEAAIAQiALgBb8lACBAoIwQsAAAMAXMILAAADAF3DCwAAAwBfxAsAAAMATcULAAADAGDGCwAAAwBgxwsAAAEATcgLAAABAFwQAAgBCIAuAFvyUAIECgjBCwAAAwBcwgsAAAMAXcMLAAADAF/ECwAAAwBNxQsAAAMAYMYLAAADAGDHCwAAAQBNyAsAAAEAXAEDAAAABAgEAAUU.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end