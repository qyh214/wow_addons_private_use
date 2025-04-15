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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Warrior-Fury','Monk-Mistweaver','Mage-Fire','Mage-Frost','DeathKnight-Blood','Rogue-Assassination','DemonHunter-Vengeance','DemonHunter-Havoc',}; local provider = {region='CN',realm='埃苏雷格',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aaliyah:AwAECAYABRQCAQAEAQhnFAA1mPEABRQAAQAEAQhnFAA1mPEABRQAAA==.',At='Atreter:AwAGCAsABAoAAA==.',Bo='Boxer:AwABCAEABRQAAA==.',Ha='Hastalavista:AwABCAEABAoAAA==.',Re='Recordare:AwADCAYABRQCAgADAQiRBwAteLYABRQAAgADAQiRBwAteLYABRQAAA==.',Si='Sissipapa:AwACCAIABRQAAQMAAAAECAQABRQ=.',Te='Teardrop:AwACCAIABAoAAA==.',['�']='七月的秋刀鱼:AwAHCAoABAoAAA==.',['�']='倔强的山峰:AwAECAYABRQCBAAEAQirDwAYD98ABRQABAAEAQirDwAYD98ABRQAAQUAW1wGCAQABRQ=.',['�']='光之暗影:AwAECAQABRQAAA==.',['�']='凡灵若槿:AwAECAQABAoAAA==.',['�']='吃的好睡的香:AwABCAEABAoAAA==.',['�']='圣丶光丨:AwAGCAsABAoAAA==.',['�']='墨陌默默:AwADCAsABRQDBgADAQioCABTWCQBBRQABgADAQioCABTWCQBBRQABwABAQg9GABEyjsABRQAAA==.',['�']='夏天的风:AwAGCAwABAoAAA==.天风咲夜:AwACCAMABRQCCAAIAQjOIwAk1T0BBAoACAAIAQjOIwAk1T0BBAoAAA==.',['�']='小张真丑:AwABCAEABAoAAA==.小花:AwEECAQABRQAAQMAAAAICAMABRQ=.',['�']='布兰琪:AwAGCA0ABAoAAA==.',['�']='我不会奶:AwAECAQABAoAAA==.我不会玩:AwABCAEABAoAAA==.我就是演员:AwAHCAcABAoAAA==.',['�']='暗黑狼王:AwAGCAUABAoAAA==.',['�']='月逝星落:AwAECAQABRQAAA==.',['�']='棘骨:AwAICAgABAoAAA==.',['�']='渡厄:AwAFCAUABAoAAA==.',['�']='燃烧的冰:AwAICBcABAoCCQAIAQijBwBSnHUCBAoACQAIAQijBwBSnHUCBAoAAA==.',['�']='爱吃大西瓜:AwAICBMABAoAAA==.',['�']='珍珠:AwABCAEABRQDCgAIAQicDABI1SkCBAoACgAIAQicDABI1SkCBAoACwAEAQieWwAu6ggBBAoAAQMAAAACCAIABRQ=.',['�']='白玉:AwACCAIABRQAAA==.',['�']='瞅见你辣眼睛:AwAECAQABRQAAA==.',['�']='紫月雪:AwAICAgABAoAAA==.',['�']='罐头盒:AwADCAMABAoAAA==.',['�']='聆听雨眠:AwABCAEABAoAAA==.',['�']='菠菜二零零五:AwADCAYABAoAAA==.',['�']='萨拉塔斯:AwACCAIABAoAAA==.',['�']='蕙手:AwAGCAwABAoAAA==.',['�']='豪横:AwAICAgABAoAAA==.',['�']='贝优妮塔:AwAICA0ABAoAAA==.',['�']='键盘斗士:AwADCAUABRQDBwADAQgLEgAq9l0ABRQABgACAQilKwAXZ2YABRQABwABAQgLEgBSE10ABRQAAA==.',['�']='阳光玫瑰:AwACCAIABRQAAA==.',['�']='风中的火焰:AwAGCAwABAoAAA==.食魂者阿莱利:AwAGCAsABAoAAA==.',['�']='鬼少:AwAGCAcABAoAAA==.',['�']='黃昏的邂逅:AwACCAEABRQAAA==.黑色的沉默:AwAFCAUABAoAAA==.黯然诺诺:AwAGCAYABAoAAA==.',['�']='龙柏虎宝:AwAGCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end