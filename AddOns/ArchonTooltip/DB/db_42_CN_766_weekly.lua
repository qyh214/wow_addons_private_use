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
 local lookup = {'Paladin-Retribution','Warrior-Arms','Mage-Fire','Mage-Frost','Shaman-Restoration','Hunter-BeastMastery','Priest-Discipline','Priest-Holy','Monk-Mistweaver','Unknown-Unknown','Paladin-Protection',}; local provider = {region='CN',realm='瓦拉斯塔兹',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Amberss:AwACCAIABAoAAA==.',Ch='Chinamobile:AwABCAIABRQCAQAIAQhJFwBb/aYCBAoAAQAIAQhJFwBb/aYCBAoAAA==.',Ed='Edan:AwAECAQABRQAAA==.',La='Laknight:AwAECAQABRQAAA==.Laphy:AwACCAIABRQAAA==.',['�']='三葉丶泷:AwAICAgABAoAAA==.丷重返巅峰丷:AwAGCAYABRQCAgAGAQiFAAAse74BBRQAAgAGAQiFAAAse74BBRQAAA==.',['�']='伊珞恩:AwABCAEABRQAAA==.',['�']='勿入天堂:AwABCAEABRQDAwAIAQg8LQBAudkBBAoAAwAIAQg8LQBAudkBBAoABAADAQgLbwA5DpMABAoAAA==.',['�']='南家丨夏奈:AwAECA0ABRQDAwAEAQgdFwBCrd4ABRQAAwAEAQgdFwAuIN4ABRQABAACAQi9DAA7Lo8ABRQAAA==.',['�']='咕咕伊雯:AwAHCAoABAoAAA==.',['�']='嘿小猩猩:AwABCAEABRQCBQAHAQgbSQAs3T4BBAoABQAHAQgbSQAs3T4BBAoAAA==.',['�']='土丢丢:AwACCAIABRQAAA==.',['�']='大家说累不累:AwAGCAYABAoAAA==.',['�']='害羞的裤兜:AwAECAQABRQAAA==.',['�']='小小瑞鸡:AwAICAEABAoAAA==.少喝酒多吃肉:AwAECAgABRQCBgAEAQiOCQBDYhoBBRQABgAEAQiOCQBDYhoBBRQAAA==.尛曦:AwAECAQABRQAAA==.',['�']='无言:AwAICAgABAoAAA==.',['�']='未来:AwAICAgABAoAAA==.',['�']='桐桐丶含含:AwAECAQABAoAAA==.',['�']='毛麦坑坑:AwAECAQABRQAAA==.',['�']='泰国战狼:AwACCAIABRQAAA==.',['�']='湘南海鸥:AwAGCAgABRQDBwAGAQgQAQAwN6oBBRQABwAGAQgQAQAtT6oBBRQACAACAQiqEQA16IIABRQAAA==.',['�']='猫之轨迹:AwAECAcABRQCCQAEAQjNEAAYZ8gABRQACQAEAQjNEAAYZ8gABRQAAA==.',['�']='秋深渐入冬:AwAGCAIABAoAAA==.',['�']='粉色回忆:AwACCAIABRQAAA==.',['�']='耐瑟瑞尔:AwAECAQABRQAAQoAAAAGCAQABRQ=.',['�']='联盟招牌:AwAECAQABRQAAA==.',['�']='菩提小牧:AwADCAQABAoAAA==.',['�']='血夜圣光:AwAHCBIABAoAAA==.',['�']='那一秒丶後灬:AwAFCAgABAoAAA==.邪恶摇粒绒:AwAECAQABRQAAA==.',['�']='鬼蜮先驱:AwABCAQABRQAAA==.鬼蜮神箭手:AwABCAEABRQAAA==.',['�']='魇梦:AwAGCAYABRQCCwAGAQjFAABA5KIBBRQACwAGAQjFAABA5KIBBRQAAA==.',['�']='鵰花酒:AwAECAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end