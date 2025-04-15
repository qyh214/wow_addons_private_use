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
 local lookup = {'Warrior-Fury','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Paladin-Protection','Hunter-BeastMastery','Priest-Shadow','Priest-Discipline','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='伊森德雷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Az='Azazmm:AwACCAIABRQAAA==.',He='Heol:AwABCAEABAoAAA==.',Ja='Jacding:AwAFCAUABAoAAA==.',Le='Lemon:AwAICAcABAoAAA==.',['�']='何以丿为战:AwACCAIABRQAAA==.',['�']='傀麵娃娃:AwAECAQABAoAAA==.',['�']='克里斯蒂亚诺:AwACCAQABRQAAA==.',['�']='十六夜:AwAECAQABRQAAA==.',['�']='哈苏:AwAECAQABRQAAA==.',['�']='大象三零六三:AwADCAEABAoAAA==.大象九五二七:AwAICAQABAoAAA==.大象八八四八:AwAICAgABAoAAA==.天灰的像哭过:AwAFCAgABAoAAA==.',['�']='寂静的无奈:AwABCAIABRQCAQAGAQirQwAhqjABBAoAAQAGAQirQwAhqjABBAoAAA==.',['�']='小德会变身:AwAECAQABAoAAA==.小菜鸡:AwAECAQABRQAAA==.尤型玩物:AwADCAcABRQEAgAIAQhvBgBIS1ACBAoAAgAIAQhvBgBISVACBAoAAwAEAQhUUwAz3fkABAoABAABAQh2OgAgLT0ABAoAAA==.',['�']='月亮战神:AwAECAQABRQAAA==.月亽:AwAECAQABRQAAA==.术爷有专攻:AwAECAkABRQEBAAEAQgbAwBWNxEBBRQABAAEAQgbAwBI5hEBBRQAAwADAQgaDAA5F+AABRQAAgABAQiVFwAAAAAABRQAAA==.',['�']='此女无敌:AwAGCAYABAoAAA==.',['�']='浪匕透心凉:AwAHCAgABAoAAA==.',['�']='淡忘忧伤:AwAECAQABRQAAQUAQy8HCAYABRQ=.',['�']='狂暴的蚂蚁:AwAICBYABAoCBgAIAQhiKQBDJDACBAoABgAIAQhiKQBDJDACBAoAAA==.',['�']='玩什么呢啊:AwABCAEABRQAAA==.',['�']='瞪你咋滴:AwABCAEABRQCAwAIAQi0JgAxasgBBAoAAwAIAQi0JgAxasgBBAoAAA==.',['�']='神仙摘葡萄:AwABCAEABAoAAA==.神灬通:AwAICAgABAoAAA==.',['�']='离析:AwAGCAYABRQDBwAGAQgbBwBA7gwBBRQABwADAQgbBwA0ogwBBRQACAADAQghEABKfasABRQAAA==.',['�']='空心房图:AwABCAEABRQAAA==.',['�']='聖珖:AwACCAQABRQCCQAIAQjnOwBBohkCBAoACQAIAQjnOwBBohkCBAoAAA==.',['�']='肥舞之心:AwAICBYABAoCCgAIAQiRDgBKUloCBAoACgAIAQiRDgBKUloCBAoAAA==.',['�']='藏剑天涯:AwADCAcABAoAAA==.',['�']='虎胆酒:AwAGCAYABRQCCwAGAQi6AgALS2QBBRQACwAGAQi6AgALS2QBBRQAAA==.',['�']='要乃没有:AwAECAQABRQAAA==.',['�']='达一一丶:AwAFCAUABAoAAA==.',['�']='逆天姐姐:AwAICAgABAoAAA==.',['�']='阿萌:AwACCAIABRQAAA==.阿蕾娜:AwAECAQABRQAAA==.',['�']='雪山之巅:AwAGCAYABAoAAA==.雪糕糊你脸:AwADCA0ABRQCAwADAQjdAwBWrC0BBRQAAwADAQjdAwBWrC0BBRQAAA==.',['�']='风来了:AwAECAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end