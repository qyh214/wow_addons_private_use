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
 local lookup = {'DeathKnight-Blood','Warlock-Destruction','Paladin-Retribution','Paladin-Protection','Priest-Shadow','Hunter-BeastMastery',}; local provider = {region='CN',realm='伊莫塔尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={De='Demons:AwACCAIABAoAAA==.',['�']='一个丁老头:AwAECAQABAoAAA==.丨吾皇丨:AwABCAIABRQAAA==.丨欧皇丶附体:AwAECAgABRQCAQAEAQj7AQBgzFUBBRQAAQAEAQj7AQBgzFUBBRQAAA==.丶苏菲:AwAECAQABRQAAA==.丽丽丶:AwAICAgABAoAAA==.',['�']='于妳姝:AwAICAgABAoAAA==.',['�']='伐伽:AwAICAEABAoAAA==.',['�']='傲娇的小狮子:AwABCAEABAoAAA==.',['�']='南信双皮奶:AwAICBMABAoAAA==.',['�']='古龙桑克斯:AwAFCAcABAoAAA==.',['�']='合欢宗道子:AwAICAIABAoAAA==.',['�']='哞哞哒:AwAECAQABRQAAA==.',['�']='啊呱呱:AwAICAgABAoAAQIASvQICBMABRQ=.啾啾丶:AwAICAgABAoAAA==.',['�']='天高任鸟飞:AwAECAQABAoAAA==.',['�']='好想有人爱:AwAECAkABRQCAQAEAQjGBQBLFAkBBRQAAQAEAQjGBQBLFAkBBRQAAA==.',['�']='小柒柒:AwAGCAQABRQAAA==.',['�']='幸吾技高一筹:AwAHCAcABAoAAA==.',['�']='张大夫的大哥:AwAECAcABRQDAwAEAQiLGQAyZ98ABRQAAwADAQiLGQAyZ98ABRQABAAEAQiICwAQ3oEABRQAAA==.',['�']='春去春又回:AwABCAEABAoAAA==.',['�']='沙坪垻的风:AwAGCAIABRQAAA==.',['�']='淡淡秋色浓香:AwABCAEABAoAAA==.',['�']='焦糖咖啡:AwABCAEABRQAAA==.',['�']='生嚼花岗岩:AwADCAMABAoAAA==.',['�']='睚眦必报:AwADCAMABAoAAA==.',['�']='石破天惊拳:AwAFCAUABAoAAA==.',['�']='神諭:AwAGCAoABRQCBQAGAQi8AgAaPXcBBRQABQAGAQi8AgAaPXcBBRQAAA==.',['�']='红朱赤姬:AwACCAIABAoAAA==.',['�']='苁吥菰單:AwAECAYABRQCBgAEAQhsDwA2IvwABRQABgAEAQhsDwA2IvwABRQAAA==.',['�']='赵樱空:AwABCAEABRQAAA==.',['�']='鍀拉诺的兽稔:AwAECAQABRQAAA==.',['�']='锦瑟迷:AwAECAQABRQAAA==.',['�']='隐居青楼:AwAICAoABAoAAA==.',['�']='騰龍:AwAHCAEABAoAAA==.',['�']='魔霭:AwAICA8ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end