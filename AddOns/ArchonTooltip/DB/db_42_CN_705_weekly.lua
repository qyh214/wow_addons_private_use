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
 local lookup = {'Shaman-Enhancement','Hunter-BeastMastery','Paladin-Retribution','Monk-Mistweaver','Hunter-Marksmanship','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Restoration','Priest-Holy','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Druid-Balance',}; local provider = {region='CN',realm='暮色森林',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ed='Edith:AwAECAQABRQAAA==.',Ex='Existing:AwACCAgABRQCAQACAQjbCgBOKLkABRQAAQACAQjbCgBOKLkABRQAAA==.',Ge='Gevjon:AwAECAYABRQCAgAEAQg8CABXXSMBBRQAAgAEAQg8CABXXSMBBRQAAA==.',Mi='Mice:AwAHCA0ABAoAAA==.',Ne='Nephalem:AwAECAQABRQAAA==.',No='Notexist:AwAECAsABRQCAwAEAQjUBgBYACgBBRQAAwAEAQjUBgBYACgBBRQAAA==.',Se='Serendipia:AwACCAIABRQAAA==.',Va='Vampire:AwAGCAwABAoAAA==.',['�']='一発入魂:AwACCAIABRQAAA==.不知名的萨满:AwAHCAkABAoAAA==.丶冷月:AwAICAkABAoAAA==.',['�']='侬册那:AwAECAYABRQCBAAEAQiqBQBNyyABBRQABAAEAQiqBQBNyyABBRQAAQUAVdsICAgABRQ=.',['�']='千早爱音樣:AwABCAIABRQDBgAIAQiuGQBI7U4CBAoABgAIAQiuGQBGoE4CBAoABwAHAQi0GgA7J3kBBAoAAA==.',['�']='吖捌蔡斯:AwAICB8ABAoCCAAIAQgnBwBUK5ICBAoACAAIAQgnBwBUK5ICBAoAAQYATK0ECA0ABRQ=.',['�']='壅鑍:AwABCAEABRQAAA==.',['�']='大衆老司機:AwAGCAYABAoAAA==.',['�']='安度因乌瑞恩:AwAGCAQABRQAAA==.安度因落萨:AwAGCAIABRQAAA==.',['�']='小犄角长尾巴:AwAICAgABAoAAA==.小鱼丸:AwAGCAYABRQDCQAGAQikCgAnLcIABRQACQAEAQikCgAT38IABRQACgACAAgAAABVzwAABRQAAA==.',['�']='岁月如刀:AwAICAEABAoAAA==.',['�']='平安晔:AwAGCAYABAoAAA==.幻紫雨林:AwAGCAgABRQECwAGAQgIAgA6sl4BBRQACwAFAQgIAgBHX14BBRQADAACAQgPEQAcWnwABRQADQABAQh2DgAH/k4ABRQAAA==.',['�']='心跳叁陸零:AwABCAEABRQAAA==.',['�']='接化发:AwAICA8ABAoAAA==.',['�']='教练我想打球:AwAICBIABAoAAA==.',['�']='殊途:AwADCAcABRQCAgADAQgnBgBbhzUBBRQAAgADAQgnBgBbhzUBBRQAAA==.',['�']='河下文楼:AwACCAIABAoAAA==.',['�']='清雾星沂:AwAFCAUABAoAAA==.清风丶雷鸣:AwAGCAYABAoAAA==.渎神腾跃:AwAECAQABRQAAA==.',['�']='漆月:AwAHCAcABAoAAA==.',['�']='灬菜虚鲲灬:AwAGCAQABAoAAA==.',['�']='炮灰式稻草:AwADCAMABRQAAA==.',['�']='睡得非常早:AwAECAQABRQAAA==.',['�']='绿谷风情:AwAECAYABAoAAA==.',['�']='美娅:AwAFCAUABAoAAA==.',['�']='胡子阿八:AwAECAQABAoAAA==.',['�']='艾利西亚:AwAGCAYABAoAAA==.',['�']='苏沐橙:AwAECAQABAoAAA==.',['�']='菲伦:AwACCAMABRQAAA==.',['�']='萨鲁法尔大王:AwAGCAMABRQAAA==.',['�']='血腥之王:AwABCAEABRQAAA==.',['�']='隠隠莋痛:AwAICAEABAoAAA==.',['�']='魂火:AwAICAwABAoAAA==.',['�']='鲜花缤纷:AwAGCAcABAoAAA==.',['�']='黑木丶黑木:AwACCAQABRQAAQ4AQiQGCAoABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end