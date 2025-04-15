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
 local lookup = {'Warrior-Fury','Warrior-Arms','Paladin-Retribution','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Rogue-Assassination','DemonHunter-Havoc','Shaman-Elemental','Mage-Frost',}; local provider = {region='CN',realm='毁灭之锤',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Casnn:AwABCAIABRQDAQAIAQiqGABIHS8CBAoAAQAHAQiqGABNMS8CBAoAAgAFAQi4LAA0FRgBBAoAAA==.',Dn='Dnshaman:AwAECAEABAoAAA==.',Ei='Eilmaris:AwAGCAQABAoAAA==.',Ig='Igotitfrom:AwAECAQABRQAAA==.',Ro='Ronz:AwAGCAQABRQAAA==.',['�']='不能回头的风:AwAECAQABRQAAA==.丶奥法烨烨:AwACCAIABRQAAA==.',['�']='乄小蔷薇乄:AwABCAEABRQCAwAIAQjNDwBat8oCBAoAAwAIAQjNDwBat8oCBAoAAA==.',['�']='云无月:AwAECAQABRQAAA==.',['�']='剑来:AwADCAMABRQAAA==.',['�']='北帝暴脾气:AwAECAgABRQCAQAEAQg0BwBMpRYBBRQAAQAEAQg0BwBMpRYBBRQAAA==.',['�']='吻兒:AwAECAQABRQAAQEARjcFCBAABRQ=.',['�']='哔哩哔哩干杯:AwACCAIABRQAAA==.',['�']='天丨堂:AwAGCAYABAoAAA==.',['�']='待客如夫:AwAECAYABRQCAwAEAQi4GQApmN8ABRQAAwAEAQi4GQApmN8ABRQAAA==.',['�']='我就是牛插:AwADCAkABRQEBAADAQiwCgBHeBMBBRQABAADAQiwCgBHeBMBBRQABQABAQiWAwAmmEQABRQABgABAQgDGwAKbD8ABRQAAA==.',['�']='摸摸我的大肌:AwAGCAoABAoAAA==.',['�']='收割:AwAGCAYABAoAAA==.',['�']='暴躁的阿呆:AwAECAQABRQAAA==.',['�']='梅叶彼德:AwACCAIABAoAAA==.',['�']='法生万物:AwAECAQABRQAAA==.',['�']='灰色幽默:AwAICAgABAoAAA==.',['�']='王阿痴:AwAICAIABAoAAQcAN98ICBUABRQ=.',['�']='瑞查儿:AwAFCAQABAoAAA==.',['�']='紫露凝香:AwAECAYABRQCCAAEAQg5DABCdv4ABRQACAAEAQg5DABCdv4ABRQAAA==.',['�']='老斯基:AwAGCAMABAoAAA==.',['�']='荀彧:AwAICAgABAoAAQkAVZkICAIABRQ=.',['�']='贝呗贝极星:AwAFCAUABAoAAA==.',['�']='路过的大师:AwAECAQABRQAAA==.',['�']='身体棒棒强:AwAECAQABRQAAA==.',['�']='达拉崩巴国王:AwAFCAEABAoAAA==.',['�']='闲云野鸖:AwAECAQABRQAAA==.',['�']='阿巴丷:AwAECAQABRQCCgAIAQg5HgBG1PIBBAoACgAIAQg5HgBG1PIBBAoAAA==.',['�']='随波逐流:AwAHCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end