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
 local lookup = {'Paladin-Retribution','Paladin-Holy','Mage-Frost','Mage-Fire','Monk-Windwalker','DeathKnight-Blood','Unknown-Unknown','DeathKnight-Unholy','Priest-Discipline','Priest-Shadow','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation',}; local provider = {region='CN',realm='古加尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Du='Dugg:AwAECAQABRQAAA==.',Gi='Gilgil:AwAECAQABRQAAA==.',Hu='Hunterhh:AwAICAgABAoAAA==.',Mm='Mms:AwAHCAIABAoAAA==.',Mq='Mqs:AwACCAIABRQCAQAHAQhPMwBZQjYCBAoAAQAHAQhPMwBZQjYCBAoAAA==.',No='Noberad:AwAICDQABAoCAgAIAQinCABV9T4CBAoAAgAIAQinCABV9T4CBAoAAA==.',['�']='一炬:AwABCAEABRQAAA==.丶法灬殇:AwAECAQABRQDAwAIAQhvMgAtA34BBAoAAwAIAQhvMgAtA34BBAoABAAIAQiuYAAHbc8ABAoAAA==.',['�']='也许是的:AwAECAQABAoAAA==.',['�']='以记忆为眸丶:AwAICAgABAoAAA==.',['�']='兜里有枪:AwACCAEABAoAAA==.',['�']='农夫桑拳:AwAICAgABAoAAA==.',['�']='剃头的影子:AwAGCAYABAoAAA==.',['�']='吹逼术:AwAICBAABAoAAA==.',['�']='圣血魔骑:AwAHCAcABAoAAA==.',['�']='天外飞仙:AwAECAQABRQAAA==.天空没有极限:AwAICAgABAoAAA==.',['�']='奶德:AwAICA0ABAoAAQUAKkoICAYABRQ=.',['�']='孔雀东南飞:AwACCAQABRQAAQYAUMoICAcABRQ=.',['�']='小木:AwAECAQABRQAAA==.',['�']='左边忧伤:AwADCAgABRQCAQADAQiLBgBZyCoBBRQAAQADAQiLBgBZyCoBBRQAAQcAAAAECAQABRQ=.',['�']='我不管我最萌:AwAICAYABAoAAQgAL00GCAoABRQ=.',['�']='才活不久:AwAICAkABAoAAA==.扶伤丶不救死:AwAHCAcABAoAAA==.',['�']='挪威朗拿度:AwACCAIABRQAAA==.',['�']='柚柚:AwAECAQABRQAAQcAAAAICAQABRQ=.',['�']='根号肆:AwAICAgABAoAAA==.',['�']='樱花丶宝儿:AwAICBsABAoDAQAIAQjvPwBCtgwCBAoAAQAIAQjvPwBCtgwCBAoAAgAIAQgDFAAvoqYBBAoAAA==.',['�']='灰来灰气:AwACCAIABRQAAA==.',['�']='炬一:AwAFCAcABAoAAA==.',['�']='爆护小欧皇:AwAGCAUABAoAAA==.',['�']='白雪酥酥:AwAGCA0ABAoAAA==.百厮不嘚骑姐:AwABCAIABRQAAA==.',['�']='真红奈奈娜:AwADCAsABRQCCQADAQiJCABDRvEABRQACQADAQiJCABDRvEABRQAAA==.真红梅莉娜:AwACCAIABAoAAA==.',['�']='秋秋吖:AwAFCAUABRQCCgAFAQgmCQAIu/cABRQACgAFAQgmCQAIu/cABRQAAA==.',['�']='老衲只用力士:AwADCAMABRQAAA==.老陈冲钅:AwAECAQABRQAAA==.',['�']='艾尔奎特:AwAECAEABRQDCQAIAQgcCgBRWG0CBAoACQAIAQgcCgBRWG0CBAoACwAIAQhOLQAsuWcBBAoAAA==.',['�']='螃蟹丶:AwAECAQABRQAAQQAGscGCAcABRQ=.',['�']='豿看家貓鎭宅:AwACCAMABRQCCwAIAQi8IQAzyaoBBAoACwAIAQi8IQAzyaoBBAoAAA==.',['�']='这种族真丑:AwAICA0ABAoAAA==.',['�']='陈八八:AwAECAgABRQDDAAEAQieBQBeKjoBBRQADAAEAQieBQBaXToBBRQADQAEAQjYAgBVThkBBRQAAA==.限量鈑嘚嗳:AwAECAQABAoAAA==.',['�']='雨天不打伞:AwABCAEABRQAAA==.',['�']='静静太淘气:AwABCAEABRQCDgAIAQjzAQBV1KkCBAoADgAIAQjzAQBV1KkCBAoAAA==.',['�']='须臾之梦:AwADCAgABRQCDAADAQiQDABFqgkBBRQADAADAQiQDABFqgkBBRQAAA==.',['�']='齊天大圣:AwAFCAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end