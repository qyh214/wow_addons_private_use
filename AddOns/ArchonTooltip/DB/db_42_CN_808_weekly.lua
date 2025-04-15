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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','Mage-Frost','Mage-Fire','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','Shaman-Restoration',}; local provider = {region='CN',realm='范达尔鹿盔',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Alhena:AwAECAQABRQAAA==.',Cl='Clyne:AwAGCAgABRQDAQAEAQhpEAAwXNEABRQAAQAEAQhpEAArl9EABRQAAgACAQixEAAzqo0ABRQAAA==.',Ko='Koykoy:AwABCAEABAoAAA==.',Lu='Luoluo:AwAGCAYABAoAAA==.',Lz='Lzq:AwAICAgABAoAAA==.',Po='Pooleroo:AwAHCAcABAoAAA==.',Wa='Walawaka:AwADCAMABAoAAA==.',['�']='丁神:AwAICAgABAoAAA==.丑娘娘:AwAECAQABAoAAA==.丢丢大宝贝:AwAFCAUABAoAAA==.丨吃了就睡丨:AwAECAgABRQDAgAEAQiOCQAgwM8ABRQAAgAEAQiOCQAU3s8ABRQAAQAEAQgKFAAatboABRQAAA==.丨流氓丶貔貅:AwAGCAcABAoAAA==.丶神秀開天:AwAFCAUABAoAAA==.',['�']='侢戰:AwABCAEABAoAAA==.',['�']='凉夏:AwAICAgABAoAAA==.',['�']='吃宝石长大:AwACCAIABRQAAA==.',['�']='回头一刀:AwAHCAEABAoAAA==.',['�']='圣光小则:AwAECAQABRQAAA==.',['�']='奇门遁甲:AwAECAQABRQAAA==.',['�']='寂静的黎明:AwAGCAYABAoAAA==.',['�']='小哪吒:AwABCAEABRQAAA==.小悲剧:AwAECAQABRQCAwAEAQhbBwBFY+AABRQAAwAEAQhbBwBFY+AABRQAAQQASG4ICAoABRQ=.小笠原茉由:AwACCAMABAoAAA==.小霖霖:AwAECAQABAoAAA==.就这样好了:AwACCAIABAoAAA==.',['�']='屁屁然:AwAECAQABRQAAQUAQX4GCAoABRQ=.',['�']='崩溃了:AwAGCAYABAoAAA==.',['�']='带刀蝴蝶:AwAECA4ABRQDBgAEAQj2BQBcvEEBBRQABgAEAQj2BQBcvEEBBRQABwABAQhHGgAxo04ABRQAAA==.',['�']='年年:AwAICAgABAoAAA==.',['�']='恶魔小胖:AwABCAEABRQAAA==.',['�']='教授:AwAICAgABAoAAA==.',['�']='最後的薩滿:AwAECAQABAoAAA==.月丶完美倾城:AwABCAEABAoAAA==.月夜舞霓裳:AwAECAQABRQAAA==.',['�']='杏干:AwABCAEABRQAAA==.',['�']='橙汁:AwABCAEABRQAAA==.',['�']='沉醉不知归路:AwAHCAcABAoAAA==.',['�']='洅不斬:AwAGCAYABAoAAA==.',['�']='灭世者之影:AwABCAEABRQCCAAIAQhuFgAzzLIBBAoACAAIAQhuFgAzzLIBBAoAAA==.',['�']='烧钱一号:AwAECAIABRQAAA==.',['�']='猎艳人生:AwAECAQABAoAAA==.',['�']='白巧克力豆奶:AwACCAIABRQAAA==.',['�']='离离原上谱:AwAICAgABAoAAA==.',['�']='笑鱼:AwACCAIABAoAAA==.',['�']='箭神传说:AwAGCAYABAoAAA==.',['�']='芯殇丨龙龙:AwAICA4ABAoAAA==.花仙子粉丝:AwABCAEABRQAAA==.',['�']='萌萌的艾佳:AwABCAEABAoAAA==.落苏:AwAFCAUABAoAAA==.落魄灬怒风:AwABCAEABAoAAA==.',['�']='蕊肉:AwACCAIABRQAAA==.',['�']='门捷列夫:AwAGCAYABRQCCQAGAQiCAAA79bUBBRQACQAGAQiCAAA79bUBBRQAAA==.',['�']='飞花挞:AwAICAgABAoAAA==.',['�']='鸟啊:AwAICAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end