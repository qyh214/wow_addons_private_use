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
 local lookup = {'Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','Priest-Holy','Monk-Mistweaver','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Druid-Balance','DeathKnight-Blood','Shaman-Elemental','Shaman-Enhancement',}; local provider = {region='CN',realm='影之哀伤',name='CN',type='subscribers',zone=42,date='2025-04-15',data={Da='Danisen:AwEICA0ABAoAAQEAAAAECAQABRQ=.',Lu='Lupercalia:AwEICB4ABAoCAgAIAQilGwBEqTkCBAoIwQsAAAYATMILAAAGAFLDCwAABQA9xAsAAAUAVcULAAADADnGCwAAAgBJxwsAAAIARMgLAAABAD0CAAgBCKUbAESpOQIECgjBCwAABgBMwgsAAAYAUsMLAAAFAD3ECwAABQBVxQsAAAMAOcYLAAACAEnHCwAAAgBEyAsAAAEAPQEDAFfuBAgQAAUU.',['�']='一念小红手:AwEGCAIABAoAAA==.三修慕斯:AwEDCAwABRQCBAADAQi5BABAwwIBBRQDwQsAAAQAPsILAAAEAF/DCwAABAAkBAADAQi5BABAwwIBBRQDwQsAAAQAPsILAAAEAF/DCwAABAAkAA==.',['�']='五方敕令:AwEHCAcABAoAAQEAAAAICAMABRQ=.人民来当家啦:AwEECA4ABRQCBQAEAQhUDwAqvdoABRQEwQsAAAYAKcILAAAEAEjDCwAAAwAOxAsAAAEAHwUABAEIVA8AKr3aAAUUBMELAAAGACnCCwAABABIwwsAAAMADsQLAAABAB8A.',['�']='传奇舰长:AwECCAQABRQDBgAIAQilDABPolMCBAoIwQsAAAMAUsILAAAEAFXDCwAABABTxAsAAAQAWcULAAADAFXGCwAABABJxwsAAAMATMgLAAADAEYGAAgBCKUMAE+iUwIECgjBCwAAAgBSwgsAAAMAVcMLAAAEAFPECwAABABZxQsAAAMAVcYLAAAEAEnHCwAAAwBMyAsAAAMARgcAAgEIbCEAIxtUAAQKAsELAAABADDCCwAAAQAVAQgAN2oCCAUABRQ=.',['�']='发电法:AwEGCAYABAoAAQEAAAAICAMABRQ=.可愛的小只因:AwEGCBEABRQCBgAGAQj/AAA4rskBBRQGwQsAAAQAVcILAAAEAFbDCwAAAwBKxAsAAAMALMULAAACABPGCwAAAQASBgAGAQj/AAA4rskBBRQGwQsAAAQAVcILAAAEAFbDCwAAAwBKxAsAAAMALMULAAACABPGCwAAAQASAA==.',['�']='嗜魂影行者:AwEGCA8ABRQECQAGAQjfAABDTEwBBRQGwQsAAAMASsILAAADAE/DCwAAAwBNxAsAAAIAMMULAAACAD7GCwAAAgApCQAEAQjfAAA2FkwBBRQEwQsAAAEASsILAAABAE/DCwAAAQAUxgsAAAIAKQoABAEIYQsAPpnqAAUUBMELAAACAC7CCwAAAgA/wwsAAAIATcQLAAACADALAAEBCLgKAD60XgAFFAHFCwAAAgA+AQYAOK4GCBEABRQ=.',['�']='土豆丸子:AwEGCAYABRQDCAAGAQhnDwAKjLoABRQGwQsAAAEAAsILAAABABfDCwAAAQAKxAsAAAEAEMULAAABAA3GCwAAAQACCAAEAQhnDwAND7oABRQEwQsAAAEAAsILAAABABfECwAAAQAQxQsAAAEADQwAAgEIeBYABX6IAAUUAsMLAAABAAfGCwAAAQADAA==.',['�']='壹队输出:AwEECAQABRQAAQEAAAAICAMABRQ=.',['�']='奶茶萌奇奇:AwEHCB0ABRQCDQAHAQgHAABhUqcCBRQHwQsAAAYAY8ILAAAGAGTDCwAABQBjxAsAAAQAY8ULAAAEAGHGCwAAAwBXxwsAAAEAZA0ABwEIBwAAYVKnAgUUB8ELAAAGAGPCCwAABgBkwwsAAAUAY8QLAAAEAGPFCwAABABhxgsAAAMAV8cLAAABAGQA.',['�']='官人要我灬:AwEHCAcABAoAAA==.',['�']='浅処:AwECCAQABRQAAA==.',['�']='烽火燎塬:AwECCAIABAoAAQEAAAACCAIABRQ=.',['�']='狗狗吃太饱:AwEECAQABRQAAA==.狸头骑:AwECCAUABRQCDgACAQh/GgAFhkYABRQCwQsAAAMABsILAAACAAQOAAIBCH8aAAWGRgAFFALBCwAAAwAGwgsAAAIABAA=.',['�']='算了下亿把:AwEECAwABRQDDwAEAQj8CABNT9IABRQEwQsAAAMAVcILAAADAFTDCwAAAwA+xAsAAAMAXBAABAEI2gkATU/jAAUUBMELAAACAFXCCwAAAgBUwwsAAAIAPsQLAAACAFwPAAQBCPwIACTa0gAFFATBCwAAAQAXwgsAAAEAQ8MLAAABABPECwAAAQACAQEAAAAICAMABRQ=.',['�']='米哈游股东:AwECCAIABRQAAA==.',['�']='胰岛素好甜:AwEGCAQABRQCDwAEAQi1CAApHdUABRQEwQsAAAEAR8ILAAABABTDCwAAAQAfxAsAAAEAFQ8ABAEItQgAKR3VAAUUBMELAAABAEfCCwAAAQAUwwsAAAEAH8QLAAABABUBAQAAAAgIAwAFFA==.',['�']='般若秋水:AwECCAIABAoAAQEAAAAICAMABRQ=.',['�']='转眼:AwEECAQABRQAAQEAAAAICAMABRQ=.',['�']='近战:AwECCAUABRQCCAACAQiKEwA3apUABRQCwQsAAAMANMILAAACADkIAAIBCIoTADdqlQAFFALBCwAAAwA0wgsAAAIAOQA=.',['�']='那你先哄她吧:AwECCAIABRQAAA==.那是一种感觉:AwEECAQABRQDCgAIAQh5BABdFNACBAoIwQsAAAMAW8ILAAADAF/DCwAAAwBgxAsAAAMAYMULAAADAGHGCwAAAgBhxwsAAAMAU8gLAAADAFoKAAgBCHkEAF0U0AIECgjBCwAAAwBbwgsAAAMAX8MLAAADAGDECwAAAwBgxQsAAAMAYcYLAAACAGHHCwAAAwBTyAsAAAIAWgkAAQEIPj0AFRo4AAQKAcgLAAABABUBAQAAAAgIAwAFFA==.',['�']='陳小小魚丶:AwEECAQABRQAAA==.',['�']='领主圣光:AwEECBAABRQCAwAEAQheBQBX7jYBBRQEwQsAAAYAYsILAAAFAFrDCwAABABKxAsAAAEARgMABAEIXgUAV+42AQUUBMELAAAGAGLCCwAABQBawwsAAAQASsQLAAABAEYA.',['�']='魔之小软:AwEBCAEABRQAAQEAAAAICAMABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end