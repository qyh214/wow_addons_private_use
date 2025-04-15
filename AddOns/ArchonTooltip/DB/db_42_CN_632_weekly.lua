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
 local lookup = {'Warrior-Fury','Warrior-Arms','Mage-Frost','Mage-Fire','Warlock-Affliction','Warlock-Destruction',}; local provider = {region='CN',realm='大漩涡',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Baby:AwADCAMABAoAAA==.',Li='Lightsaber:AwAFCAUABAoAAA==.',Oo='Oov:AwACCAIABRQAAA==.',Pl='Playervunodj:AwAGCAYABRQDAQAGAQjWCAAvRwwBBRQAAQAEAQjWCABCuAwBBRQAAgACAQhsCQASHqkABRQAAA==.',Ti='Tiamo:AwAECAQABRQAAA==.',Wh='Whitejack:AwAECAIABRQAAA==.',['�']='丶小小潘:AwAECAQABRQAAA==.',['�']='伺机待发硬币:AwABCAEABRQAAA==.',['�']='你写吸佳佳吗:AwACCAMABRQAAA==.',['�']='卖咸鱼的老谭:AwAICBAABAoAAA==.卢云云:AwADCAQABAoAAA==.',['�']='吾的蕾蕾:AwABCAEABRQAAA==.',['�']='哎嗨唷:AwAICAEABAoAAA==.',['�']='屍臭河馬:AwAICAgABAoAAA==.',['�']='張教授:AwACCAEABRQAAA==.',['�']='星魂猎:AwABCAEABAoAAA==.',['�']='枫叶爱琦:AwAECAUABRQDAwAEAQirCAAfWLwABRQAAwADAQirCAAfWLwABRQABAABAQiYOAAAAAAABRQAAA==.',['�']='派大吐沫沫:AwAECAQABRQAAA==.',['�']='灯塔:AwAGCBAABAoAAA==.',['�']='神欲之殇:AwAECAQABRQAAA==.',['�']='色还是那个色:AwAECAQABRQAAA==.',['�']='萌萌的筱紫瞳:AwAECAgABRQDBQAEAQiEAABjkVsBBRQABQAEAQiEAABjkVsBBRQABgAEAQihBQBccxYBBRQAAA==.',['�']='過眼云烟:AwAECAQABRQAAA==.',['�']='雅琳柯德:AwADCAMABRQAAA==.',['�']='鹏骑熊跑:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end