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
 local lookup = {'Shaman-Restoration','Shaman-Enhancement','Warrior-Protection','Paladin-Retribution','Paladin-Protection','Priest-Holy','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Mage-Fire','Warlock-Destruction','Warlock-Affliction',}; local provider = {region='CN',realm='阿斯塔洛',name='CN',type='weekly',zone=42,date='2025-04-15',data={Eo='Eoii:AwAHCAoABAoAAA==.',['�']='万小雨:AwACCAIABRQAAA==.丨皮皮灬:AwADCAQABRQDAQAIAQi1RAAfJFUBBAoAAQAIAQi1RAAfJFUBBAoAAgAHAQi7MAANJhwBBAoAAA==.',['�']='伊夫利特之祭:AwAGCA0ABAoAAA==.',['�']='倒反天罡:AwABCAEABRQCAwAIAQihGAAcLB4BBAoAAwAIAQihGAAcLB4BBAoAAA==.',['�']='傲骨天生:AwACCAEABAoAAA==.',['�']='全能选手:AwACCAQABRQCBAAIAQh/MwBPVz8CBAoABAAIAQh/MwBPVz8CBAoAAA==.',['�']='减减丶:AwAECAQABRQAAA==.凯撒:AwABCAEABRQDBAAGAQgWiQBA1GUBBAoABAAGAQgWiQBA1GUBBAoABQACAQghSgAiiU8ABAoAAA==.',['�']='卓耿:AwABCAEABRQAAA==.',['�']='囡囡丶:AwACCAQABRQDBgAIAQiMIwBAkKYBBAoABgAIAQiMIwA09KYBBAoABwAGAQgIMQA8KT0BBAoAAA==.',['�']='大师兄:AwACCAMABRQAAA==.',['�']='她逼我说咸的:AwAECAMABRQAAA==.好一朵娇花:AwAECAQABRQAAA==.',['�']='安娜普尔纳:AwABCAEABAoAAA==.',['�']='小坑坑:AwABCAEABAoAAA==.',['�']='性别男爱好女:AwAICBMABAoAAA==.',['�']='我只说一次:AwACCAIABRQAAA==.战五渣小阿丁:AwAGCAMABRQAAA==.',['�']='放肆的黄瓜:AwADCAMABAoAAA==.',['�']='机智的阿狗铎:AwABCAEABRQAAA==.',['�']='梦开始的地方:AwADCAgABRQCCAADAQheGgAlidgABRQACAADAQheGgAlidgABRQAAA==.',['�']='水乄水:AwACCAIABAoAAA==.',['�']='潘嘟嘟:AwAECAQABAoAAA==.',['�']='灬歡丨:AwAICA0ABAoAAA==.灬阿德灬:AwAECAUABRQDCQADAQjaFAA/tYQABRQACAACAQiqLAA4jYoABRQACQADAQjaFAA1LIQABRQAAA==.',['�']='煌火无明:AwAECAQABAoAAA==.',['�']='爱吃披萨:AwAICAoABAoAAA==.',['�']='牛二:AwAICBgABAoCAQAIAQg8FQBPIj0CBAoAAQAIAQg8FQBPIj0CBAoAAA==.',['�']='蓝桉:AwACCAUABRQDCgACAQgFEgAVMnUABRQACgACAQgFEgAVMnUABRQACwABAQjxNwAN1zkABRQAAA==.',['�']='被窝里的射手:AwADCAMABAoAAA==.',['�']='钢管儿夺蜻蛙:AwABCAEABRQAAA==.',['�']='铲开心灵:AwAGCBcABAoDDAAGAQhCNQBHWoYBBAoADAAGAQhCNQBHWoYBBAoADQADAQhtPAANxzwABAoAAA==.',['�']='雷电法王:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end