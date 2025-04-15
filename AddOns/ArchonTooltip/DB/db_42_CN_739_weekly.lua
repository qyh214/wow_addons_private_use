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
 local lookup = {'Druid-Balance','Unknown-Unknown','Rogue-Assassination','Shaman-Restoration','DeathKnight-Blood','Warlock-Destruction','Priest-Shadow',}; local provider = {region='CN',realm='激流堡',name='CN',type='weekly',zone=42,date='2025-04-14',data={Li='Living:AwAICCYABAoCAQAIAQiEGQBKoFACBAoAAQAIAQiEGQBKoFACBAoAAA==.',Lo='Lovelesslisa:AwABCAIABRQAAA==.',Sc='Scilence:AwAECAQABRQAAA==.',['�']='不为:AwAGCAcABAoAAA==.丶七堇年华:AwAICAgABAoAAA==.丶北极丨牧:AwAFCAgABAoAAA==.丿獨家丶記憶:AwAICAoABAoAAA==.',['�']='乖宝宝小语:AwABCAEABAoAAA==.',['�']='伊利达雷:AwAECAQABRQAAA==.',['�']='冰霜之心:AwAECAQABRQAAA==.',['�']='凡心凡骑:AwACCAIABAoAAQIAAAAECAQABRQ=.',['�']='大头杨杨:AwABCAEABAoAAA==.',['�']='女神:AwABCAIABRQAAA==.',['�']='学习侠:AwAICBYABAoCAwAIAQjAGQAnHXwBBAoAAwAIAQjAGQAnHXwBBAoAAA==.',['�']='小鬼们给我上:AwAECAQABRQAAA==.小鸡:AwAICAgABAoAAA==.',['�']='战天使:AwAFCAYABAoAAA==.',['�']='撼地者:AwAICB8ABAoCBAAIAQi5NwAtQoABBAoABAAIAQi5NwAtQoABBAoAAA==.',['�']='无声血:AwAECAYABAoAAA==.日帝:AwADCAMABAoAAA==.日月同辉:AwAFCAMABAoAAA==.',['�']='明珠求瑕:AwAFCAwABAoAAA==.明语:AwAICAgABAoAAA==.',['�']='時丶雨:AwACCAIABRQAAA==.',['�']='曲你妹:AwABCAEABAoAAA==.',['�']='条子来了快跑:AwAFCAUABAoAAA==.',['�']='林宛瑜:AwACCAIABRQAAA==.果味奶糖:AwAECAQABRQAAA==.',['�']='沙奈朵:AwAGCAoABRQCBQAGAQjEAAA7CKcBBRQABQAGAQjEAAA7CKcBBRQAAA==.',['�']='深秋之殇:AwAECAQABRQAAA==.',['�']='炽天使炎:AwAFCAUABAoAAA==.',['�']='牵只猫去流浪:AwAGCAYABAoAAA==.',['�']='狡诈的部落猪:AwAECAgABRQCBgAEAQhQBQBZNhoBBRQABgAEAQhQBQBZNhoBBRQAAA==.',['�']='白银之卡:AwACCAMABRQAAA==.',['�']='皇旸惊霆:AwABCAEABAoAAA==.',['�']='知男而上:AwAECAQABAoAAA==.',['�']='神秘纽头仁友:AwACCAQABRQAAA==.',['�']='菜菜鸟:AwADCAMABAoAAQIAAAAICAQABRQ=.',['�']='落英清影:AwACCAIABRQAAA==.',['�']='蝶之影:AwAICCYABAoCBwAIAQhQEQBBQT0CBAoABwAIAQhQEQBBQT0CBAoAAA==.',['�']='诗允:AwAGCAYABAoAAA==.',['�']='迷失夜色:AwAICAoABAoAAA==.',['�']='饭团刺客:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end