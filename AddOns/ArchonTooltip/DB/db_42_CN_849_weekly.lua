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
 local lookup = {'DemonHunter-Vengeance','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Fire','Mage-Frost','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Paladin-Retribution','DeathKnight-Unholy','Warrior-Fury',}; local provider = {region='CN',realm='迪瑟洛克',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ni='Niko:AwACCAIABAoAAA==.',['�']='伊泽:AwADCAMABAoAAA==.',['�']='凭本事挨骂:AwACCAIABRQAAA==.凭本事跳怪:AwADCAYABRQCAQADAQiiBwAnv7cABRQAAQADAQiiBwAnv7cABRQAAA==.出月清风:AwADCAoABRQCAgADAQigFAAmdd0ABRQAAgADAQigFAAmdd0ABRQAAA==.',['�']='卡尔丶:AwAECAQABRQAAA==.',['�']='墨小墨:AwAGCAYABAoAAA==.',['�']='大板牙:AwACCAIABAoAAA==.天堂在我身后:AwABCAEABAoAAA==.天樄:AwACCAQABRQAAA==.天驱若若:AwADCAgABRQDAwADAQgoBABNEg8BBRQAAwADAQgoBABNEg8BBRQABAABAQiHHwAV0UkABRQAAA==.头皮发麻:AwABCAEABAoAAA==.',['�']='奥蕾莉亞丶:AwAGCAQABRQAAA==.',['�']='姬亭:AwADCAsABRQDBQADAQjTBQBKOQEBBRQABQADAQjTBQBKOQEBBRQABgABAQi2OQA//00ABRQAAA==.',['�']='安东尼的兔子:AwAECAQABRQAAA==.安尐兮:AwAICAQABRQAAA==.完美熊猫:AwADCAsABRQCAwADAQgqCQAuttoABRQAAwADAQgqCQAuttoABRQAAA==.宫崎美橞:AwAICA8ABAoAAA==.',['�']='寒衣伴楚歌:AwAGCAsABAoAAA==.',['�']='小红手霸气丶:AwABCAMABRQDBwAIAQjPIQBI9R8CBAoABwAIAQjPIQBDux8CBAoACAABAQjmhwBT5WEABAoAAA==.少年游:AwAGCAcABRQECQAGAQjTCwA8UusABRQACQAEAQjTCwBMm+sABRQACgACAQh8CQBC9tAABRQACwABAQixEAAJT00ABRQAAA==.',['�']='屠夫之瞳:AwAECAQABRQAAQwAJXQGCAUABRQ=.',['�']='心里有术:AwAECAQABAoAAA==.',['�']='怒风魔骑士:AwAHCAEABAoAAA==.',['�']='时遇:AwACCAMABRQAAA==.',['�']='月夜星晨:AwAECAQABRQAAQYANu4GCAYABRQ=.木剑小游侠:AwAECAQABRQAAA==.',['�']='杨芭乐丶:AwAECAQABRQAAA==.',['�']='汼牛很牛:AwABCAIABRQAAA==.',['�']='没头脑的家羊:AwAFCA0ABAoAAA==.油腻的师姐丶:AwADCAoABRQCDQADAQjHBABYHSsBBRQADQADAQjHBABYHSsBBRQAAA==.',['�']='法力玲珑:AwAFCAEABAoAAA==.',['�']='浊白:AwADCAsABRQDCgADAQgZDwAwEJkABRQACgACAQgZDwAtVZkABRQACQABAQjDJwA1hkQABRQAAA==.',['�']='爱不够的妖精:AwAECAYABRQCDAAEAQhzCgBDgRwBBRQADAAEAQhzCgBDgRwBBRQAAA==.',['�']='璀璨火花:AwAGCAcABAoAAA==.',['�']='直男呢阿泽:AwAGCAYABAoAAA==.',['�']='神邸丶:AwADCAsABRQCDAADAQguDABHcBUBBRQADAADAQguDABHcBUBBRQAAA==.',['�']='秀妍呢:AwADCAEABAoAAA==.',['�']='绝版菜鸟:AwADCAoABRQCDgADAQifBQBXhCkBBRQADgADAQifBQBXhCkBBRQAAA==.',['�']='羽燃:AwAGCAkABAoAAA==.',['�']='菱梦纱璃:AwAICBsABAoECQAIAQhKCwBPn4YCBAoACQAIAQhKCwBPn4YCBAoACgACAQjUKwA6iIgABAoACwABAQiSXQBBN0wABAoAAA==.',['�']='迪凯灬地狱吼:AwACCAIABRQAAA==.迪凯风暴烈酒:AwAFCAYABAoAAA==.',['�']='阿撒托斯:AwAGCAYABAoAAA==.',['�']='风雪渡归人:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end