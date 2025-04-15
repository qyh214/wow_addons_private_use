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
 local lookup = {'Priest-Discipline','DemonHunter-Havoc','Mage-Fire','Paladin-Protection','Druid-Restoration',}; local provider = {region='CN',realm='泰拉尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ha='Harris:AwACCAIABRQAAA==.',Oo='Oom:AwACCAIABAoAAA==.',['�']='一身正气:AwAGCAYABAoAAA==.丝丝暧昧丶:AwAECAQABRQAAA==.丧尸:AwABCAEABRQAAA==.丨无灬双丨:AwADCAMABAoAAA==.',['�']='仴橆凊寒:AwACCAQABRQAAA==.仴橆靈殇:AwABCAEABRQAAA==.',['�']='伤恨寒冰枪:AwABCAEABRQAAA==.',['�']='你就是块木头:AwADCAkABRQCAQADAQj1CgApbdsABRQAAQADAQj1CgApbdsABRQAAA==.',['�']='冲锋兔:AwACCAIABAoAAA==.',['�']='可爱的熊熊:AwAFCAcABAoAAA==.',['�']='吃我一火球:AwACCAIABAoAAA==.',['�']='哔哩吧啦崩:AwAGCAYABAoAAA==.',['�']='回首暮云远:AwAECAIABRQAAA==.围攻伯拉勒斯:AwAECAQABRQAAA==.',['�']='多鸠鱼:AwADCAMABAoAAA==.夜丶风:AwAICA8ABAoAAA==.',['�']='奈何不是仙:AwABCAIABRQAAA==.奈莉莎:AwAGCAkABAoAAA==.契约之瞳:AwADCAMABAoAAA==.奥林花园:AwAICAgABAoAAA==.',['�']='孤胆胖胖:AwACCAIABAoAAA==.',['�']='影之潮汐:AwABCAEABRQAAA==.影歌之月:AwACCAQABRQCAgAIAQidFABQ+HICBAoAAgAIAQidFABQ+HICBAoAAA==.',['�']='旋风之刃:AwAECAQABRQAAA==.',['�']='晴空飞鸟:AwAECAQABRQAAA==.',['�']='林深见鹿:AwAGCAUABRQCAwAFAQh3BABCYm8BBRQAAwAFAQh3BABCYm8BBRQAAA==.',['�']='楚恋流云:AwAGCAgABRQCBAAGAQiJAQArOVkBBRQABAAGAQiJAQArOVkBBRQAAA==.',['�']='涔涔铃音:AwAGCAYABAoAAA==.涼月清風:AwAECAgABRQCAgAEAQhZEQAoPucABRQAAgAEAQhZEQAoPucABRQAAA==.',['�']='爱或伤痕:AwADCAQABAoAAA==.',['�']='睡不醒的豆豆:AwAHCAoABAoAAA==.',['�']='瞬间即逝:AwADCAUABAoAAA==.',['�']='老胡丨:AwAGCAYABAoAAA==.',['�']='装备评分:AwACCAQABRQCBQAIAQjCFAA/wvcBBAoABQAIAQjCFAA/wvcBBAoAAA==.',['�']='谁拿我圆规了:AwACCAIABRQAAA==.',['�']='雪梅初绽:AwABCAEABRQAAA==.',['�']='鬼冢英吉:AwAHCAwABAoAAA==.',['�']='麻匪豆豆:AwAFCAYABAoAAA==.',['�']='龍葵:AwAICAsABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end