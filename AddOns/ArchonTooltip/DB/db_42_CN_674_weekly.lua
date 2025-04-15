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
 local lookup = {'Rogue-Subtlety','Rogue-Assassination','Warrior-Arms','Shaman-Enhancement','Warrior-Fury','Unknown-Unknown','Paladin-Protection','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Paladin-Retribution','DeathKnight-Blood','DeathKnight-Unholy','Hunter-BeastMastery','Warrior-Protection',}; local provider = {region='CN',realm='库德兰',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Ann:AwAGCA4ABRQDAQAGAQjpBQAx2vgABRQAAQAEAQjpBQA/JPgABRQAAgADAQhzCgAd7LAABRQAAA==.',Ji='Jixiegeming:AwAHCAIABAoAAA==.',Ve='Ver:AwAICAgABAoAAA==.',['�']='九幽狱蝶:AwAECAQABRQAAQMAS5IGCBAABRQ=.',['�']='二十周年死骑:AwAICAgABAoAAA==.二宝耶:AwAGCBgABAoCBAAGAQjXMQAc2g0BBAoABAAGAQjXMQAc2g0BBAoAAA==.',['�']='会笑的狼:AwAICAUABRQDBQAFAQj9EQAnFcIABRQABQAEAQj9EQAggcIABRQAAwABAQgODwA60mEABRQAAA==.伶俐鬼:AwACCAIABRQAAQYAAAAGCAQABRQ=.',['�']='元素应我召唤:AwAECAQABAoAAA==.',['�']='十八翼虚空禅:AwAICAwABAoAAA==.卡琳娜斯:AwAECAEABAoAAA==.',['�']='叮叮咚:AwAHCA0ABAoAAA==.',['�']='吃又吃不饱:AwAECAEABAoAAA==.',['�']='哈娜:AwAICAkABAoAAA==.哟呵:AwAGCAYABRQCBwAGAQhEAQAwp3ABBRQABwAGAQhEAQAwp3ABBRQAAA==.',['�']='喵帕丝:AwADCAMABAoAAA==.',['�']='圣域油菜:AwAICAsABAoAAA==.地狱:AwABCAEABRQECAAIAQhGMgBBzI4BBAoACAAGAQhGMgBFK44BBAoACQAFAQg6JQAvVxsBBAoACgADAQg0IgA8JbwABAoAAA==.',['�']='奥丝法蕾亚:AwAICAgABAoAAA==.',['�']='小猪吃得饱:AwAICAgABAoAAA==.小钻风:AwACCAIABRQAAQYAAAAGCAQABRQ=.',['�']='帝辛:AwAICAgABAoAAA==.',['�']='懒之鱼鱼:AwAGCAQABRQAAA==.',['�']='或许如果可能:AwAECAQABRQAAA==.战姆斯:AwAICAQABAoAAA==.',['�']='星霜:AwAECAgABRQCCwAEAQijCwBK/REBBRQACwAEAQijCwBK/REBBRQAAA==.',['�']='暗黑圣堂:AwAECAgABRQDDAAEAQiTBwBHJ+kABRQADQAEAQhrCgBBIfUABRQADAAEAQiTBwBAxukABRQAAA==.',['�']='来疼我:AwAECAQABAoAAA==.',['�']='死神:AwAGCAUABAoAAA==.',['�']='浪花十三:AwAICAgABAoAAA==.海鲜杂烩:AwADCAMABRQAAA==.',['�']='玖拾:AwACCAcABRQCDgACAQhjIQA8zZ4ABRQADgACAQhjIQA8zZ4ABRQAAA==.',['�']='紫焱:AwABCAEABAoAAA==.',['�']='苏格兰高鸟蛋:AwAGCAYABAoAAA==.',['�']='莉雅拉:AwAHCBAABAoAAA==.',['�']='萨布里多:AwAGCBAABAoAAA==.',['�']='西红柿炒番茄:AwAECAQABRQAAA==.',['�']='跨越柒海的风:AwAICAcABAoAAA==.',['�']='邮电部诗人:AwADCAIABAoAAA==.',['�']='钉铛铛:AwABCAEABAoAAA==.',['�']='陳老师:AwACCAUABRQCDwACAQh7BgAnc4AABRQADwACAQh7BgAnc4AABRQAAA==.',['�']='雨猫:AwAHCAUABAoAAA==.',['�']='魂之挽歌:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end