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
 local lookup = {'Druid-Balance','Druid-Restoration','Druid-Guardian','Shaman-Restoration','Warlock-Destruction','Monk-Windwalker','Shaman-Elemental',}; local provider = {region='CN',realm='阿努巴拉克',name='CN',type='weekly',zone=42,date='2025-04-15',data={Et='Eternallove:AwACCAYABRQEAQACAQgvIwASzH8ABRQAAQACAQgvIwASzH8ABRQAAgABAQiUHwAI0TEABRQAAwABAQjsBwAC5hkABRQAAA==.',['�']='不高兴:AwAECAUABRQCBAAEAQi8BgBIZBMBBRQABAAEAQi8BgBIZBMBBRQAAA==.专属猎手:AwAECAQABAoAAA==.',['�']='伊利蛋丶怒风:AwAICAsABAoAAA==.',['�']='南希:AwACCAQABRQAAA==.',['�']='只爱暷説:AwAECAYABAoAAA==.',['�']='君临:AwADCAYABAoAAA==.',['�']='命定幽影:AwAICBwABAoCBQAIAQjiDABOVnkCBAoABQAIAQjiDABOVnkCBAoAAA==.',['�']='堕落信仰:AwABCAEABAoAAA==.',['�']='天际孤星:AwABCAEABRQAAA==.',['�']='奶不住怎么办:AwACCAIABAoAAA==.',['�']='巴掌依旧:AwACCAUABRQCBgACAQjBDwA0o5gABRQABgACAQjBDwA0o5gABRQAAA==.',['�']='树法:AwAGCAEABAoAAA==.',['�']='河北菜花:AwABCAEABRQAAA==.',['�']='烟花丶已凉:AwABCAEABAoAAA==.',['�']='狂暴趴趴熊:AwAGCAYABAoAAA==.',['�']='相泽南:AwAGCAoABAoAAA==.',['�']='绯夜丶:AwAECAEABRQAAQcAVZkICAIABRQ=.',['�']='群正的骑士:AwACCAIABRQAAA==.',['�']='西红柿炒番茄:AwAECAQABRQAAA==.',['�']='贁傢尐娘孒:AwABCAEABAoAAA==.',['�']='这是个啥:AwAHCAYABAoAAA==.',['�']='那啥遭雷劈:AwAICA4ABAoAAA==.',['�']='风骚的小燕子:AwAFCAkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end