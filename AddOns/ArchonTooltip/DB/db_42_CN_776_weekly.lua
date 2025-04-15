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
 local lookup = {'Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Affliction',}; local provider = {region='CN',realm='祖尔金',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Astrid:AwABCAEABRQAAA==.',['�']='一个白妹妹:AwACCAIABRQEAQAIAQg6IgAxDKsBBAoAAQAIAQg6IgAxDKsBBAoAAgAGAQiHOwBNCnEBBAoAAwACAQg0TAAZyGoABAoAAA==.一灯和尚:AwAECAQABAoAAA==.',['�']='今晚打老狐:AwABCAIABRQCBAAIAQh8IAAlB0UBBAoABAAIAQh8IAAlB0UBBAoAAA==.',['�']='别对我谈情:AwAICAYABAoAAA==.',['�']='卓嘎:AwACCAIABAoAAA==.',['�']='哈尼小熊:AwAECAQABRQAAQIANG8GCAYABRQ=.',['�']='夜蔓蔓:AwAECAIABRQAAA==.天使玫:AwAECAQABAoAAA==.',['�']='敌在兰若寺:AwAICAgABAoAAA==.',['�']='暴打丶葡萄:AwACCAIABAoAAA==.',['�']='枯骨:AwACCAIABAoAAA==.',['�']='汉加诺:AwAICAIABAoAAA==.',['�']='泉水姐姐:AwABCAEABAoAAA==.',['�']='白狼骚男:AwABCAIABRQAAA==.',['�']='真红戟鬼:AwAGCA0ABRQDBQAGAQjKAABUBcABBRQABQAGAQjKAABN08ABBRQABgAEAQi4AwBSFAkBBRQAAA==.',['�']='禅中说缠:AwAICAIABAoAAA==.',['�']='紫雨伊人:AwABCAEABAoAAA==.',['�']='草原秋风狂:AwACCAIABRQAAA==.',['�']='血色狂刀:AwAFCAkABAoAAA==.',['�']='贝如塔:AwACCAIABAoAAA==.',['�']='迪迦:AwABCAEABRQAAA==.',['�']='高嗒强:AwAHCAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end