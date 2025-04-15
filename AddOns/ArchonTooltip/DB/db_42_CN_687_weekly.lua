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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Shaman-Enhancement','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Paladin-Retribution','Priest-Shadow','Warrior-Fury','Warrior-Protection',}; local provider = {region='CN',realm='托尔巴拉德',name='CN',type='weekly',zone=42,date='2025-04-14',data={Sp='Spectral:AwAICAgABAoAAA==.',['�']='不说话:AwAICAgABAoAAA==.',['�']='人红橙多:AwAECAQABRQAAA==.',['�']='你的相好:AwAECAcABRQDAQAEAQgyBQBTSf8ABRQAAgAEAQhkCwBOJg8BBRQAAQADAQgyBQBRYP8ABRQAAA==.',['�']='光的狗腿子:AwAFCAEABAoAAA==.',['�']='凶矛无鬙:AwAGCAIABAoAAA==.',['�']='北大方小猎牛:AwAICAcABAoAAA==.北大方小雌牛:AwAICAIABAoAAA==.',['�']='卡在名字:AwAECAQABRQAAA==.卡德喵:AwABCAIABRQAAA==.',['�']='吥懂夜的黑:AwABCAEABRQAAA==.吼哟:AwACCAQABRQEAwAIAQjGDgBbGGUCBAoAAwAHAQjGDgBbXmUCBAoABAADAQilFgBTjxkBBAoABQACAQieXwAj80AABAoAAA==.',['�']='噬魂丶猎:AwAECAQABRQAAQYAS9AGCAoABRQ=.',['�']='圣息者爱萝米:AwAGCAEABRQDBwAIAQiZCABcN4ACBAoABwAIAQiZCABa6YACBAoACAAFAQhTIQBafJcBBAoAAA==.',['�']='天哪我真高啊:AwAGCAQABRQAAA==.',['�']='安妮宝贝灬:AwABCAEABRQAAA==.',['�']='布兰迪:AwACCAIABRQAAA==.',['�']='悟不空:AwAFCAcABAoAAQIASssCCAMABRQ=.',['�']='抓走小公主:AwADCAEABAoAAA==.',['�']='放肆的小飞:AwABCAIABRQCCQAIAQiUDQBWb5sCBAoACQAIAQiUDQBWb5sCBAoAAA==.',['�']='无奈的小刀:AwABCAEABRQAAA==.',['�']='月镰:AwACCAIABAoAAA==.',['�']='梦寻乄千古殇:AwACCAIABRQAAA==.',['�']='棒棒糖:AwAICAcABAoAAA==.',['�']='狼群食尸鬼:AwAICAcABAoAAA==.',['�']='猫骨头:AwAGCBIABAoAAA==.',['�']='纳芙蒂蒂:AwAECAIABRQCCgAIAQgTQABCDwsCBAoACgAIAQgTQABCDwsCBAoAAA==.',['�']='艾塔利亚:AwACCAIABRQAAA==.',['�']='萨蕾娜邪刃:AwABCAEABRQAAA==.',['�']='譬如朝露:AwAGCAYABRQDBwAGAQisCAA1gdYABRQABwAEAQisCAAmTtYABRQACwACAQgbDwBBG8UABRQAAA==.',['�']='风来王:AwACCAMABRQDDAAIAQg9GwA8BxwCBAoADAAIAQg9GwA8BxwCBAoADQAEAQgNLAARc3UABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end