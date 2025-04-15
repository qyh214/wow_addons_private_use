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
 local lookup = {'Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood','Unknown-Unknown','Druid-Restoration','Paladin-Protection','Paladin-Retribution','Warlock-Destruction','Warlock-Demonology',}; local provider = {region='CN',realm='迪托马斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Da='Dazdingo:AwAICAgABAoAAA==.',Sa='Saroti:AwABCAEABRQAAA==.',['�']='一样枫隐:AwABCAEABRQDAQAIAQivFQAtV7oBBAoAAQAIAQivFQAtV7oBBAoAAgAGAQiWIgAN++4ABAoAAA==.一样枫飞:AwAECAQABAoAAA==.丶圣皇:AwABCAEABRQAAA==.',['�']='二月的鱼:AwADCAMABAoAAA==.',['�']='伐要幫無姥卛:AwAECAMABRQAAA==.',['�']='佣兽:AwAICAEABAoAAA==.',['�']='冷酷孤影:AwAECAQABRQAAA==.',['�']='凋零夜月:AwABCAEABRQCAwAHAQiARAAfRocABAoAAwAHAQiARAAfRocABAoAAA==.',['�']='卡珊德拉:AwABCAEABAoAAA==.',['�']='史塔克:AwACCAIABAoAAA==.',['�']='嘟巿蓅氓:AwAFCAcABAoAAA==.',['�']='大丶美:AwAFCAUABAoAAA==.大腿轻轻抚:AwAGCAwABAoAAA==.',['�']='奶油小僧:AwAECAQABAoAAA==.',['�']='妞妞侠:AwAECAQABRQAAQQAAAAICAIABRQ=.',['�']='寒夜丶:AwAICAgABAoAAA==.',['�']='小碗二细:AwACCAIABAoAAA==.小雨饱饱:AwAECAQABRQAAA==.小鹿鹏程:AwAECAQABRQAAA==.小黑子:AwABCAEABRQAAA==.',['�']='幼麟:AwAECAQABRQAAA==.',['�']='恍然如夢丶:AwAGCAYABAoAAA==.',['�']='文橙功主:AwAECAQABAoAAA==.',['�']='朽沐白哉:AwACCAIABAoAAA==.',['�']='沛然舞羽:AwAECAQABRQAAA==.',['�']='流萤:AwAHCAcABAoAAA==.浩劫:AwAFCAYABAoAAA==.',['�']='爱梅特赛尔克:AwABCAEABRQAAA==.',['�']='理子:AwABCAEABRQCBQAHAQhtPwAxr/EABAoABQAHAQhtPwAxr/EABAoAAA==.',['�']='瑅里奥丶弗丁:AwAICAEABAoAAA==.',['�']='石大骑:AwAECAYABRQCBgAEAQjyBABKEfoABRQABgAEAQjyBABKEfoABRQAAA==.',['�']='神圣大救赎:AwADCAIABRQAAA==.',['�']='莫西干:AwAECAwABRQDBwAEAQh3FwA9+e8ABRQABwAEAQh3FwAuQe8ABRQABgAEAQghBwA9McoABRQAAA==.',['�']='萬戰未亡:AwAICAYABAoAAA==.',['�']='蒐姐炫拉菲:AwABCAEABRQAAA==.',['�']='豿日战:AwABCAEABRQAAA==.',['�']='鄢涩遥:AwAICAgABAoAAA==.',['�']='霍尔蒙克斯:AwAICBYABAoDCAAIAQipQAApGU8BBAoACAAHAQipQAArOU8BBAoACQACAQhnTgAaq3gABAoAAA==.霸波尔奔:AwAECAQABRQAAQQAAAAICAQABRQ=.',['�']='魔屠嚜嚜:AwAICAwABAoAAA==.',['�']='黑暗飯团:AwAGCAEABRQAAA==.黑黑球萨满:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end