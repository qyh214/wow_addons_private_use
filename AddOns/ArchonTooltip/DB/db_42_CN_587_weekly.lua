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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Mage-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Guardian','Druid-Restoration','Warrior-Protection','Druid-Feral','Unknown-Unknown','DeathKnight-Blood','Warrior-Fury','Shaman-Restoration','Monk-Mistweaver',}; local provider = {region='CN',realm='刀塔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bo='Botdly:AwABCAEABAoAAA==.',Fe='Felix:AwACCAIABAoAAA==.',Mu='Muranyuu:AwAECAQABRQAAA==.',Se='Semmelweis:AwABCAEABRQEAQAIAQhIQgAvA0ABBAoAAQAHAQhIQgAsFkABBAoAAgADAQgnJgAl7qIABAoAAwADAQiVSgAeh3kABAoAAA==.',Su='Suga:AwAHCBAABAoAAA==.',Zh='Zhendemeiyis:AwABCAEABRQCBAAIAQjGGwBFXwMCBAoABAAIAQjGGwBFXwMCBAoAAA==.',['�']='丰川祥子:AwAICCIABAoDBQAIAQihEABB+u4BBAoABQAIAQihEAA9ou4BBAoABgAHAQj0NwA6O6UBBAoAAA==.',['�']='云门过何山:AwAICAgABAoAAA==.',['�']='俠鵺:AwAGCAYABAoAAA==.',['�']='凉栀丶丶:AwAICBcABAoCBgAGAQhGUQAwvTIBBAoABgAGAQhGUQAwvTIBBAoAAA==.凯文兄丶:AwACCAIABRQAAA==.',['�']='加二卤食:AwABCAEABRQAAA==.',['�']='匠作:AwAECAQABAoAAA==.',['�']='十四是奶骑:AwAECAQABRQAAA==.卖糖果的:AwAICAsABAoAAA==.',['�']='可日可乐:AwAECAUABAoAAA==.',['�']='夏利巴黎春雪:AwACCAQABRQDBwAIAQgLBQBF5RoCBAoABwAIAQgLBQBF5RoCBAoACAAFAQiZTgAfGaoABAoAAA==.天之剑神:AwAFCAQABAoAAA==.',['�']='奶快救我:AwAECAQABRQAAA==.',['�']='宫乄城:AwAECAQABRQAAA==.',['�']='寄风尘:AwABCAEABAoAAA==.',['�']='布莱恩铜须丶:AwAGCAYABAoAAA==.',['�']='幽灵骑士:AwAECAQABRQAAA==.',['�']='往北乄向南:AwAECAQABRQAAA==.',['�']='暗叶:AwAECAQABRQAAQkALyoICAoABRQ=.',['�']='有个拽杰:AwAFCAYABAoAAA==.',['�']='海鸥魂:AwABCAMABRQAAA==.',['�']='火箭龟:AwADCAgABRQCCgADAQhLAQBAfxgBBRQACgADAQhLAQBAfxgBBRQAAA==.',['�']='爱吃米饭:AwAICA4ABAoAAA==.',['�']='紫霞小魔仙:AwACCAIABAoAAA==.',['�']='胖虎:AwACCAQABRQAAA==.',['�']='脑中弹:AwAICAgABAoAAA==.',['�']='至尊奶妈:AwABCAEABRQAAA==.',['�']='苏菲强力吸附:AwAICAgABAoAAA==.',['�']='莱锅:AwAECAIABRQAAA==.',['�']='蒼潼:AwAGCAYABAoAAQsAAAAECAQABRQ=.',['�']='谜团:AwAECAYABRQCDAAEAQinAwBYFDIBBRQADAAEAQinAwBYFDIBBRQAAA==.谭雅丶:AwAECAkABRQCDQAEAQjCBwBHxhIBBRQADQAEAQjCBwBHxhIBBRQAAA==.',['�']='贱谍大师裹网:AwAECAgABRQCDgAEAQg7DgApV9kABRQADgAEAQg7DgApV9kABRQAAA==.',['�']='青山丶僧:AwABCAEABRQCDwAIAQiKFwBEug8CBAoADwAIAQiKFwBEug8CBAoAAA==.',['�']='魔画情:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end