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
 local lookup = {'Druid-Balance','Druid-Guardian','Unknown-Unknown','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Shaman-Enhancement','DeathKnight-Melee','DeathKnight-Blood','Mage-Frost','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship',}; local provider = {region='CN',realm='凤凰之神',name='CN',type='subscribers',zone=42,date='2025-04-15',data={Mu='Muyuxd:AwEDCAMABRQDAQAIAQhpGgBH208CBAoIwQsAAAUAWsILAAAEAFrDCwAAAwBHxAsAAAQAWMULAAAEAFnGCwAAAwBQxwsAAAIAOsgLAAADABUBAAgBCGkaAEfbTwIECgjBCwAABQBawgsAAAQAWsMLAAADAEfECwAABABYxQsAAAQAWcYLAAADAFDHCwAAAgA6yAsAAAEAFQIAAQEIoTEADccMAAQKAcgLAAACAA0BAQA18gQIDQAFFA==.',['�']='丨德艺双馨:AwEICAgABAoAAA==.',['�']='卑微的肉:AwEECAQABRQAAQMAAAAICAMABRQ=.南极料理人:AwEDCAIABRQAAQMAAAAICAMABRQ=.',['�']='古月方源丨:AwEDCAYABRQCBAADAQjfCQBaYfkABRQDwQsAAAIAYcILAAACAFrDCwAAAgBTBAADAQjfCQBaYfkABRQDwQsAAAIAYcILAAACAFrDCwAAAgBTAA==.',['�']='执手阳春丶:AwECCAIABRQEBQAIAQhTCwBNuAoCBAoIwQsAAAYAW8ILAAAGAFfDCwAABQBRxAsAAAUAQMULAAAFAEjGCwAABQBSxwsAAAQASMgLAAAEADcGAAgBCBIWAEb+MAIECgjBCwAAAwBUwgsAAAUAV8MLAAADAFHECwAAAwBAxQsAAAMASMYLAAADACvHCwAAAwBIyAsAAAIANgUABwEIUwsARpQKAgQKB8ELAAACAFvDCwAAAgBOxAsAAAIAO8ULAAACAEjGCwAAAgBSxwsAAAEAKsgLAAACADcHAAIBCKU2ACyDUAAECgLBCwAAAQA0wgsAAAEAJAEDAAAACAgDAAUU.',['�']='拟态软泥涡虫:AwEGCAYABRQCAQAGAQijAABBb9UBBRQGwQsAAAEAWMILAAABAFLDCwAAAQA2xAsAAAEAPMULAAABACPGCwAAAQBCAQAGAQijAABBb9UBBRQGwQsAAAEAWMILAAABAFLDCwAAAQA2xAsAAAEAPMULAAABACPGCwAAAQBCAA==.',['�']='无耻大米:AwEECAQABRQAAQMAAAAICAMABRQ=.',['�']='梦七姨:AwEECAQABRQAAQMAAAAICAMABRQ=.',['�']='没钱买电脑:AwEHCAQABAoAAQMAAAAICAMABRQ=.',['�']='牢大黑肘:AwEECAUABRQCCAAEAQhPCQAotOsABRQEwQsAAAEARsILAAACACTDCwAAAQAPxAsAAAEAGQgABAEITwkAKLTrAAUUBMELAAABAEbCCwAAAgAkwwsAAAEAD8QLAAABABkBAwAAAAgIAwAFFA==.',['�']='紅豆雙皮奶:AwEGCAIABRQCCQACAAgAAAA0dgAABRQCxQsAAAEAOcYLAAABAC4KAAIACAAAADR2AAAFFALFCwAAAQA5xgsAAAEALgEDAAAACAgDAAUU.',['�']='维斯塔瑞理:AwEICAgABAoAAA==.',['�']='菰羽翎风:AwEECAUABRQCCwAEAQhZBQBQmfQABRQEwQsAAAIAX8ILAAABADrDCwAAAQBXxAsAAAEAXAsABAEIWQUAUJn0AAUUBMELAAACAF/CCwAAAQA6wwsAAAEAV8QLAAABAFwA.',['�']='进击的细箭:AwEHCAYABAoAAQMAAAAICAUABAo=.',['�']='门口的老頭:AwEDCAMABRQAAA==.',['�']='陆捌叁叁:AwECCAUABRQCDAACAQhICABNg7AABRQCwQsAAAMATcILAAACAE0MAAIBCEgIAE2DsAAFFALBCwAAAwBNwgsAAAIATQA=.',['�']='风纪委落叶:AwEBCAEABRQAAQMAAAAICAMABRQ=.',['�']='骗喝的小婴儿:AwEDCAcABRQDDQADAQhbJAAHTZsABRQDwQsAAAEAB8ILAAADAAvDCwAAAwACDQADAQhbJAAGupsABRQDwQsAAAEAB8ILAAADAAvDCwAAAgAADgABAAgAAAACoQAABRQBwwsAAAEAAgEDAAAACAgDAAUU.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end