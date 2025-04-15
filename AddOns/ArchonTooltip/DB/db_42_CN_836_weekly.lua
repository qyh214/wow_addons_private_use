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
 local lookup = {'Paladin-Retribution','Mage-Fire','Shaman-Restoration','DeathKnight-Blood','Warrior-Fury','Evoker-Preservation',}; local provider = {region='CN',realm='达基萨斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ch='Christie:AwABCAIABRQAAA==.',Sa='Saberl:AwABCAIABRQAAA==.',Sc='Scraletammo:AwACCAYABRQCAQACAQiwLwAooI8ABRQAAQACAQiwLwAooI8ABRQAAA==.',Zo='Zoltraak:AwAECA0ABRQCAgAEAQjxDwBGgv8ABRQAAgAEAQjxDwBGgv8ABRQAAA==.',['�']='二哎:AwAFCAUABAoAAQMALYgGCAYABRQ=.',['�']='你不能这么做:AwACCAQABAoAAA==.',['�']='冰农吐息:AwAECAoABRQCBAAEAQhyDAAzL74ABRQABAAEAQhyDAAzL74ABRQAAA==.',['�']='单调的夜道:AwAICAgABAoAAA==.',['�']='喵神:AwAICAEABAoAAA==.',['�']='地狱男爵:AwAECAQABAoAAA==.',['�']='多多休息:AwABCAEABRQAAA==.',['�']='奥秘:AwAECAQABRQAAA==.',['�']='娅特拉绯雪:AwABCAEABRQAAA==.',['�']='宇智波牢大:AwADCAMABAoAAA==.',['�']='左手拔刀:AwABCAIABRQAAA==.',['�']='很酷又爱笑:AwACCAUABRQCAQACAQjfJgBDY6kABRQAAQACAQjfJgBDY6kABRQAAA==.',['�']='愉悦的纸鹤:AwAICAIABAoAAA==.',['�']='成就你的梦想:AwABCAEABRQAAA==.',['�']='拉风归来骑士:AwABCAIABRQAAA==.拿破剑:AwAGCBYABAoCBQAGAQh6KABSyNMBBAoABQAGAQh6KABSyNMBBAoAAA==.',['�']='浩克:AwAFCAYABAoAAA==.',['�']='炼心行者:AwAICAgABAoAAA==.',['�']='牛吉把:AwABCAEABRQAAA==.',['�']='白衣流云:AwAICAgABAoAAA==.',['�']='石头贼:AwAFCAUABAoAAA==.',['�']='素炒胡萝卜:AwABCAEABAoAAA==.',['�']='老徳:AwAHCAkABAoAAA==.',['�']='苍龙灬揽皓月:AwACCAIABAoAAQYASrkHCAwABRQ=.',['�']='重案组之虎:AwAGCAwABAoAAA==.',['�']='阳光一兜兜:AwAHCA4ABAoAAA==.',['�']='风行者迷弟:AwAECAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end