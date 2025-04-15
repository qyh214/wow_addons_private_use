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
 local lookup = {'Monk-Mistweaver','Monk-Brewmaster','Priest-Holy','Priest-Discipline','Unknown-Unknown','Priest-Shadow','Mage-Fire','Warlock-Affliction','Warlock-Destruction','Shaman-Enhancement','Shaman-Restoration','Rogue-Assassination','Rogue-Subtlety',}; local provider = {region='CN',realm='罗宁',name='CN',type='subscribers',zone=42,date='2025-04-15',data={['�']='下周一定红:AwEGCAQABRQAAA==.',['�']='予伞伞:AwEECAQABRQAAA==.',['�']='喵喵布丁:AwEECAcABRQDAQAEAQjZCABL4QkBBRQEwQsAAAIASsILAAACAFvDCwAAAgA9xAsAAAEAXAEABAEI2QgAS+EJAQUUBMELAAABAErCCwAAAQBbwwsAAAEAPcQLAAABAFwCAAMBCPAFAAfrdQAFFAPBCwAAAQAMwgsAAAEABcMLAAABAAYA.',['�']='安蜜莉雅:AwEECA8ABRQDAwAEAQgcAQBfpUgBBRQEwQsAAAUAYcILAAAFAF3DCwAAAwBgxAsAAAIAQgMABAEIHAEAX6VIAQUUBMELAAAFAGHCCwAABQBdwwsAAAMAYMQLAAABAEIEAAEBCHomAAAAAAAFFAHECwAAAQAZAA==.',['�']='山石游侠:AwEICAsABAoAAQUAAAAICAwABAo=.山石骑士:AwEICAwABAoAAA==.',['�']='巡山捕熊:AwEGCAYABAoAAQUAAAAICAMABRQ=.',['�']='师大保钳工:AwEECAQABRQAAQUAAAAICAMABRQ=.',['�']='恋狐少:AwEDCAkABRQDAwADAQgzBwAz9ekABRQDwQsAAAUAT8ILAAADADvDCwAAAQAQAwADAQgzBwAz9ekABRQDwQsAAAUAT8ILAAACADvDCwAAAQAQBAABAQg3IgAJzTwABRQBwgsAAAEACQA=.',['�']='毒蔷薇:AwEECAoABRQDBgAEAQhPCABJtgcBBRQEwQsAAAMAUcILAAACAC3DCwAAAwBdxAsAAAIAMQYABAEITwgASbYHAQUUBMELAAACAFHCCwAAAgAtwwsAAAMAXcQLAAABADEDAAIBCBQcADXIQgAFFALBCwAAAQA1xAsAAAEAOgA=.比法思:AwEGCA4ABRQCBwAGAQixAgA86ccBBRQGwQsAAAQAV8ILAAAEAF7DCwAAAwBZxAsAAAEAQcULAAABAAjGCwAAAQAYBwAGAQixAgA86ccBBRQGwQsAAAQAV8ILAAAEAF7DCwAAAwBZxAsAAAEAQcULAAABAAjGCwAAAQAYAA==.',['�']='水原千鹤丶:AwEICAgABAoAAQUAAAAICAMABRQ=.',['�']='泰丶坦犽:AwEECAMABRQAAQUAAAAICAMABRQ=.',['�']='活力鱼串:AwEHCAoABRQDCAADAQghAwBfnRYBBRQDwQsAAAQAYsILAAADAGPDCwAAAwBYCAADAQghAwBWXRYBBRQDwQsAAAMAWcILAAACAFHDCwAAAwBYCQACAQiKDABjI+cABRQCwQsAAAEAYsILAAABAGMBBQAAAAgIAwAFFA==.',['�']='竹川萤:AwEBCAMABRQCCQAIAQjsEwBKBEICBAoIwQsAAAMAUcILAAADAEzDCwAABABLxAsAAAQAUcULAAADAFPGCwAABABHxwsAAAMAQMgLAAADAEEJAAgBCOwTAEoEQgIECgjBCwAAAwBRwgsAAAMATMMLAAAEAEvECwAABABRxQsAAAMAU8YLAAAEAEfHCwAAAwBAyAsAAAMAQQEFAAAACAgDAAUU.',['�']='若有鱼心:AwEDCAUABAoAAQUAAAAICAMABRQ=.',['�']='蒜欧提斯:AwEGCAoABRQDCgAGAQjtAAA6Z8kBBRQGwQsAAAIAO8ILAAACAFvDCwAAAgAjxAsAAAIAWMULAAABAB7GCwAAAQBKCgAGAQjtAAA6Z8kBBRQGwQsAAAEAO8ILAAABAFvDCwAAAQAjxAsAAAEAWMULAAABAB7GCwAAAQBKCwAEAQglFwAFo6oABRQEwQsAAAEAA8ILAAABAAvDCwAAAQABxAsAAAEAAQA=.',['�']='蕾茉妮雅:AwEDCAUABRQCAgADAQj1BQAIAHQABRQDwQsAAAMAA8ILAAABAArDCwAAAQAKAgADAQj1BQAIAHQABRQDwQsAAAMAA8ILAAABAArDCwAAAQAKAA==.',['�']='蜜甜甜:AwEDCAIABRQEAwAIAQjAHgA9OMUBBAoIwQsAAAIAJMILAAADAEfDCwAAAwBUxAsAAAMAKMULAAADAC3GCwAAAQA1xwsAAAIARMgLAAADAEMDAAgBCMAeAD04xQEECgjBCwAAAgAkwgsAAAIAR8MLAAACAFTECwAAAgAoxQsAAAIALcYLAAABADXHCwAAAQBEyAsAAAEAQwYABgEI/C0AMHZKAQQKBsILAAABADbDCwAAAQBExAsAAAEAMcULAAABAB3HCwAAAQAmyAsAAAEAMgQAAQEIKo0AD+keAAQKAcgLAAABAA8A.',['�']='这周一定红:AwEECAMABRQAAQUAAAAGCAQABRQ=.',['�']='逗比丶:AwECCAIABRQAAA==.',['�']='闷头睡大觉:AwEBCAEABRQAAQUAAAAICAMABRQ=.',['�']='食尘剑怨念物:AwEECAwABRQDDAAEAQj4BABAAg0BBRQEwQsAAAUAYsILAAADAFTDCwAAAgAIxAsAAAIAWAwABAEI+AQAQAINAQUUBMELAAADAGLCCwAAAgBUwwsAAAEACMQLAAACAFgNAAMBCGQIADPb4AAFFAPBCwAAAgBBwgsAAAEAVMMLAAABAAYA.',['�']='鸪可杀不可卤:AwEICAgABAoAAQUAAAAICAMABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end