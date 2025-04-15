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
 local lookup = {'Unknown-Unknown','Shaman-Elemental','Shaman-Restoration','Mage-Frost','Paladin-Retribution','Paladin-Holy','Hunter-BeastMastery','DemonHunter-Havoc',}; local provider = {region='CN',realm='布鲁塔卢斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Af='Afterglow:AwACCAIABRQAAA==.',Ai='Aimdk:AwABCAEABAoAAQEAAAAGCAQABRQ=.',Al='Alanpriest:AwAGCAcABRQDAgAGAQh1AQBBvTkBBRQAAgAEAQh1AQBeuTkBBRQAAwACAQg8EwAthrYABRQAAA==.',Bi='Bigsprite:AwAGCAkABAoAAA==.',Le='Legendary:AwACCAIABRQAAQQARgAHCAcABRQ=.',Lz='Lzlzjlove:AwAICAgABAoAAA==.',Vo='Volkanovski:AwACCAIABAoAAA==.',['�']='一无:AwACCAIABRQAAA==.万倾之茫然:AwACCAQABRQAAA==.不灭饕餮:AwAICAoABAoAAA==.丷萌胖胖:AwAICAIABAoAAA==.',['�']='九条:AwADCAMABAoAAA==.',['�']='五门茜:AwADCAIABAoAAA==.',['�']='你也令人着迷:AwAICAkABAoAAA==.',['�']='初一:AwAECAQABAoAAA==.',['�']='叫我帅哥就好:AwAICBAABAoAAA==.',['�']='回眸谁浅笑丶:AwABCAEABRQAAA==.',['�']='大笨鸟:AwAICAgABAoAAA==.天灾丶怒风:AwAECAQABRQAAA==.',['�']='小发雷霆:AwAECAQABRQAAA==.小开的血圣:AwAGCAYABAoAAA==.',['�']='康斯坦丁:AwAGCAwABAoAAA==.',['�']='文雅适合我:AwAECAQABRQAAQEAAAAGCAQABRQ=.方块黑色:AwAHCAcABAoAAA==.',['�']='旋风冰雨:AwABCAEABRQAAA==.',['�']='暮秋池浅舞:AwAICAYABAoAAA==.',['�']='最爱小猪:AwACCAIABRQAAA==.',['�']='灬莫扎特:AwACCAIABAoAAA==.',['�']='烟雨荷花影:AwABCAEABAoAAA==.',['�']='王大福:AwAFCAUABAoAAA==.',['�']='稼轩:AwABCAEABRQAAA==.',['�']='第二圣:AwAECAYABRQDBQAEAQgkGAA05uUABRQABQADAQgkGAA05uUABRQABgABAQjgEgAAAAAABRQAAA==.',['�']='花石头:AwABCAEABRQAAA==.花花与三猫:AwAHCAcABAoAAA==.',['�']='莫大叔:AwAHCAwABAoAAA==.',['�']='血性男儿:AwAICBkABAoCBwAIAQjXJgBJujwCBAoABwAIAQjXJgBJujwCBAoAAA==.血燕:AwACCAIABRQAAA==.',['�']='踏云无痕:AwACCAQABRQAAQgAPDgGCAwABRQ=.踏玉:AwACCAIABRQAAA==.踏花有痕:AwACCAIABRQAAA==.',['�']='铭魂:AwAICAgABAoAAA==.',['�']='阿斯好同学:AwAFCAUABAoAAA==.',['�']='领丿袖:AwAICBIABAoAAA==.',['�']='风之神猎:AwAICAgABAoAAA==.',['�']='鲨鱼辣椒:AwAHCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end