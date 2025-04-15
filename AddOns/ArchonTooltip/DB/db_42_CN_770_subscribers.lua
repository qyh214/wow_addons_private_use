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
 local lookup = {'Unknown-Unknown','Warlock-Destruction','Mage-Fire','Mage-Arcane','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Restoration','Shaman-Enhancement','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','Priest-Holy','Warrior-Arms','Warrior-Fury','Shaman-Restoration',}; local provider = {region='CN',realm='白银之手',name='CN',type='subscribers',zone=42,date='2025-04-15',data={Ag='Agastopis:AwEICAQABRQAAA==.',Ch='Chaosm:AwEGCAYABAoAAQEAAAAECAQABRQ=.',Ju='Justinmonk:AwEGCAYABAoAAQEAAAAECAQABRQ=.',Lu='Luvlesshawn:AwEGCAUABRQCAgAFAQifAwA9mEIBBRQFwQsAAAEAScILAAABACnDCwAAAQBQxAsAAAEAGMYLAAABADMCAAUBCJ8DAD2YQgEFFAXBCwAAAQBJwgsAAAEAKcMLAAABAFDECwAAAQAYxgsAAAEAMwA=.',Ni='Nillin:AwEGCAQABAoAAQEAAAABCAIABRQ=.',Nt='Ntmdjjww:AwEGCAUABRQCAgAEAQjWDgA2ntoABRQEwQsAAAEAP8ILAAABACbDCwAAAgA9xAsAAAEACgIABAEI1g4ANp7aAAUUBMELAAABAD/CCwAAAQAmwwsAAAIAPcQLAAABAAoBAQAAAAgIBAAFFA==.',Oa='Oakensoulsrc:AwEDCAoABRQDAwADAQh/CwBVYRgBBRQDwQsAAAUAWcILAAADAFLDCwAAAgBUAwADAQh/CwBVYRgBBRQDwQsAAAUAWcILAAADAFLDCwAAAQBUBAABAQi6AgBFQlUABRQBwwsAAAEARQA=.',Pr='Prophetchan:AwEECAgABRQDBQAEAQj/DgBW+wUBBRQEwQsAAAIAXsILAAACAFXDCwAAAgBRxAsAAAIATwUABAEI/w4AVvsFAQUUBMELAAABAF7CCwAAAQBVwwsAAAEAUcQLAAABAEUGAAQBCIIHADyD8wAFFATBCwAAAQBdwgsAAAEALsMLAAABACrECwAAAQBPAA==.Prophethh:AwECCAIABRQAAQUAVvsECAgABRQ=.',St='Staybake:AwECCAIABRQAAQEAAAAICAQABRQ=.',['S�']='Sùprémê:AwEHCAcABAoAAA==.',['�']='丷丑牛丷:AwEICAYABRQCBwAGAQhvAABNCNwBBRQGwQsAAAEARcILAAABAFHDCwAAAQApxAsAAAEATsULAAABAGLGCwAAAQBdBwAGAQhvAABNCNwBBRQGwQsAAAEARcILAAABAFHDCwAAAQApxAsAAAEATsULAAABAGLGCwAAAQBdAA==.',['�']='再不斬丶:AwEECAQABRQAAQEAAAAICAQABRQ=.',['�']='可乐不太冰:AwEDCAMABAoAAQgARlUGCBsABRQ=.可谕:AwEBCAEABRQAAQMAMssICAMABRQ=.',['�']='复仇邪痕:AwEDCAMABAoAAQEAAAAFCAUABAo=.',['�']='如果我是张童:AwEHCAQABAoAAQEAAAAICAQABRQ=.',['�']='居居尐宝:AwEECAQABRQAAQEAAAAECAQABRQ=.',['�']='幽幽紫颡:AwEHCBQABAoCCQAHAQjEKQBc32ICBAoHwQsAAAMAX8ILAAADAF/DCwAABQBixAsAAAQAYMULAAABAFvGCwAAAgBbyAsAAAIAVAkABwEIxCkAXN9iAgQKB8ELAAADAF/CCwAAAwBfwwsAAAUAYsQLAAAEAGDFCwAAAQBbxgsAAAIAW8gLAAACAFQA.',['�']='心理作怪:AwEGCAYABRQCCgAGAQh4AQAsN7MBBRQGwQsAAAEAV8ILAAABAFnDCwAAAQAjxAsAAAEAVcULAAABAATGCwAAAQAECgAGAQh4AQAsN7MBBRQGwQsAAAEAV8ILAAABAFnDCwAAAQAjxAsAAAEAVcULAAABAATGCwAAAQAEAQEAAAAICAQABRQ=.',['�']='恰空丶:AwEGCBsABRQCCAAGAQiAAABGVfQBBRQGwQsAAAYAYcILAAAGAFnDCwAABQBPxAsAAAUARMULAAADACfGCwAAAgAtCAAGAQiAAABGVfQBBRQGwQsAAAYAYcILAAAGAFnDCwAABQBPxAsAAAUARMULAAADACfGCwAAAgAtAA==.',['�']='春风秋雨丶:AwEGCAMABRQAAQEAAAAICAQABRQ=.',['�']='杰克乔圣骑:AwEECAQABAoAAA==.',['�']='泽沅:AwEGCAYABAoAAQkAXN8HCBQABAo=.',['�']='温玖:AwEICAIABAoAAQEAAAAICAQABRQ=.',['�']='炒肝儿阿玛:AwEECAQABRQAAA==.',['�']='爱梨酱:AwEECAQABRQAAA==.',['�']='狂小月:AwEICCAABAoDCgAIAQjfKAA+S/ABBAoIwQsAAAMAQsILAAADAEvDCwAAAwAyxAsAAAMARMULAAAFAEbGCwAABgAlxwsAAAQAL8gLAAAFAFcKAAgBCN8oADor8AEECgjBCwAAAQAmwgsAAAEAS8MLAAABADHECwAAAQBExQsAAAEARsYLAAACACXHCwAAAQAvyAsAAAIAVwsACAEIMhAAJqNyAQQKCMELAAACAELCCwAAAgBFwwsAAAIAMsQLAAACADnFCwAABAAbxgsAAAQAEscLAAADABHICwAAAwAUAQgARlUGCBsABRQ=.',['�']='环印骑士直剑:AwEGCBoABRQCCgAGAQguAABYHSACBRQGwQsAAAYAY8ILAAAFAGPDCwAABABcxAsAAAUAYcULAAAEAF3GCwAAAgA4CgAGAQguAABYHSACBRQGwQsAAAYAY8ILAAAFAGPDCwAABABcxAsAAAUAYcULAAAEAF3GCwAAAgA4AA==.',['�']='神秘电击使:AwEFCAUABAoAAQwAPTgDCAIABRQ=.',['�']='笑语看歌:AwEBCAEABRQDDQAIAQhyAgBewOMCBAoIwQsAAAQAXsILAAAEAGDDCwAABABhxAsAAAMAX8ULAAADAGLGCwAAAwBVxwsAAAMAYcgLAAADAF0NAAgBCHICAF7A4wIECgjBCwAAAwBewgsAAAMAYMMLAAADAGHECwAAAQBfxQsAAAIAYsYLAAACAFXHCwAAAwBhyAsAAAEAXQ4ABwEIlCUAQu3kAQQKB8ELAAABAE3CCwAAAQBLwwsAAAEATsQLAAACAFbFCwAAAQBOxgsAAAEALsgLAAACAC0BDAA9OAMIAgAFFA==.',['�']='箭如破菊:AwEECAQABRQAAA==.',['�']='純白的信仰:AwEICCAABAoCCQAIAQhrGQBYFqMCBAoIwQsAAAQAXsILAAAEAF/DCwAABABjxAsAAAUAVsULAAAFAFrGCwAABABfxwsAAAQAWsgLAAACADQJAAgBCGsZAFgWowIECgjBCwAABABewgsAAAQAX8MLAAAEAGPECwAABQBWxQsAAAUAWsYLAAAEAF/HCwAABABayAsAAAIANAEMAD04AwgCAAUU.',['�']='红红的小苹果:AwEECAwABRQCDwAEAQgnAgBe604BBRQEwQsAAAUAX8ILAAADAGLDCwAAAwBbxAsAAAEAUw8ABAEIJwIAXutOAQUUBMELAAAFAF/CCwAAAwBiwwsAAAMAW8QLAAABAFMA.',['�']='蜜桃小表妹:AwEICAgABAoAAA==.',['�']='财高八抖:AwECCAIABRQAAA==.',['�']='辛加斯:AwEGCAcABRQDBQAGAQhWBAA6bF0BBRQGwQsAAAEAXMILAAABADLDCwAAAQBXxAsAAAIAU8ULAAABABPGCwAAAQAqBQAFAQhWBAAzRV0BBRQFwQsAAAEAXMILAAABADLECwAAAgBTxQsAAAEAE8YLAAABACoGAAEBCIAYAFcMYAAFFAHDCwAAAQBXAA==.',['�']='遠風的呢喃:AwEFCAMABAoAAQwAPTgDCAIABRQ=.',['�']='阿月冲了吗:AwEICAgABAoAAQgARlUGCBsABRQ=.',['�']='鹿鸣呦呦丶:AwEICAMABRQCAwADAQiPCgAyyyABBRQDxgsAAAEALccLAAABABjICwAAAQBSAwADAQiPCgAyyyABBRQDxgsAAAEALccLAAABABjICwAAAQBSAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end