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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Mage-Fire','Mage-Frost','Unknown-Unknown','Warrior-Fury',}; local provider = {region='CN',realm='戈古纳斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={At='Atlantls:AwAICAoABAoAAA==.',De='Deris:AwABCAEABAoAAA==.',Ko='Kongmencang:AwADCAMABAoAAA==.',Mt='Mthgh:AwAECAYABAoAAA==.',['�']='一起去爬山:AwAICAgABAoAAA==.不器:AwAGCAgABAoAAA==.不必害怕:AwACCAMABAoAAA==.不明眞相群众:AwAECAQABRQAAA==.为了联盟:AwAECAQABRQAAA==.',['�']='二牛又来了:AwAECAIABRQAAA==.',['�']='元华:AwABCAEABRQDAQAIAQiICgBYCLQCBAoAAQAIAQiICgBYCLQCBAoAAgADAQjYIQAxV4kABAoAAA==.兔丶尐术:AwAGCA4ABRQEAwAGAQj/AABOG7EBBRQAAwAFAQj/AABXnbEBBRQABAADAQjoAwBIEAcBBRQABQACAQhxCgAoEVwABRQAAA==.八级大狂疯:AwAECAQABAoAAA==.',['�']='利维坦:AwABCAEABRQAAA==.',['�']='囍刚刚:AwAGCAgABAoAAA==.',['�']='在乎的人:AwAGCAYABAoAAA==.',['�']='大占卜师:AwADCAgABRQDBgADAQhkHwAKJqwABRQABgADAQhkHwAKJqwABRQABwABAQiGGwACfzAABRQAAA==.天下大乱:AwABCAEABAoAAA==.',['�']='寂静狩猎者:AwAECAQABRQAAQgAAAAICAQABRQ=.',['�']='小凶許:AwACCAIABAoAAA==.小小笨猪:AwAHCAwABAoAAA==.',['�']='弑夜龙灵:AwAICAgABAoAAA==.',['�']='往生缘丶沉迷:AwABCAEABAoAAA==.',['�']='曦尔瓦娜斯:AwAICAgABAoAAA==.',['�']='月影梵天:AwADCAMABAoAAA==.',['�']='林允儿:AwACCAEABAoAAA==.枫红叶:AwABCAIABRQAAQMALloHCAYABRQ=.',['�']='梅琳娜:AwAECAQABRQAAQEAPpAGCAgABRQ=.',['�']='潜龙务用:AwAICAgABAoAAA==.',['�']='灬红皮灬:AwAGCAEABAoAAA==.灵狐公子:AwAICBAABAoAAA==.',['�']='点丶丶燃:AwAGCAQABRQAAA==.',['�']='爱墨奥维斯:AwADCAMABAoAAA==.',['�']='玫瑰丶瓦莉菈:AwADCAMABAoAAA==.玫瑰丶解语花:AwAFCAUABAoAAA==.',['�']='硬黝黑:AwADCAMABAoAAA==.',['�']='神圣之力:AwAGCAQABRQAAA==.',['�']='秋冷了月光:AwACCAgABRQCCQACAQhEEgBVjb8ABRQACQACAQhEEgBVjb8ABRQAAA==.',['�']='绛玥璃瑕:AwACCAIABAoAAA==.',['�']='詹姆斯丷哈登:AwABCAEABAoAAA==.',['�']='诛歌:AwAECAIABRQAAA==.',['�']='赱紅丶:AwAECAQABRQAAA==.',['�']='蹓跶:AwAICAEABAoAAA==.',['�']='遛迏:AwAGCAYABAoAAQgAAAAICAEABAo=.',['�']='锁沁:AwAECAUABAoAAA==.',['�']='阿苗:AwAICAoABAoAAA==.',['�']='露早够够:AwAICAwABAoAAA==.',['�']='风剑侠:AwACCAIABRQCAQAIAQiqFQBMN1wCBAoAAQAIAQiqFQBMN1wCBAoAAA==.',['�']='骑车去跳海:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end