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
 local lookup = {'Priest-Discipline','Priest-Holy','Unknown-Unknown','Monk-Mistweaver','Evoker-Devastation',}; local provider = {region='CN',realm='迦罗娜',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ha='Hammerko:AwAECAQABAoAAA==.',['�']='七十八号:AwAECAQABAoAAA==.',['�']='五十几个骑士:AwAICAgABAoAAA==.',['�']='伏地魔菇:AwABCAEABAoAAA==.',['�']='八号风球:AwAECAIABRQAAA==.',['�']='冇毒:AwAECAQABRQAAA==.',['�']='千代:AwAHCAcABAoAAA==.',['�']='含盐的鱼:AwABCAEABRQAAA==.',['�']='复杂的猎手:AwACCAIABRQAAA==.大胆小鬼:AwAICAgABAoAAA==.大鸟人:AwABCAEABAoAAA==.夯夯的劣人:AwAFCAgABAoAAA==.',['�']='打倒三明治:AwACCAMABRQAAA==.',['�']='放逐灵魂:AwAFCAgABAoAAA==.',['�']='正趣果上果:AwAECAUABRQDAQAEAQiOAwBdyTwBBRQAAQAEAQiOAwBdyTwBBRQAAgABAQjcIAATljQABRQAAA==.',['�']='海尾巴:AwAGCAkABAoAAQMAAAACCAMABRQ=.海棉:AwAFCAYABAoAAA==.',['�']='清白之年:AwABCAEABRQAAA==.',['�']='熊溅溅:AwAECAgABRQCBAAEAQj/CgA7QPgABRQABAAEAQj/CgA7QPgABRQAAA==.',['�']='琬儿:AwABCAEABAoAAA==.',['�']='盗道天地人:AwAICAgABAoAAA==.',['�']='第一天增辉:AwAGCAYABRQCBQAGAQiCAQAvHrMBBRQABQAGAQiCAQAvHrMBBRQAAA==.',['�']='艳遇:AwAECAQABAoAAA==.',['�']='苏州大铁牛:AwACCAEABAoAAA==.苏州骷髅头:AwADCAYABAoAAA==.',['�']='莎莎:AwADCAMABAoAAA==.',['�']='落媛淡雪:AwABCAEABAoAAA==.',['�']='酷渣:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end