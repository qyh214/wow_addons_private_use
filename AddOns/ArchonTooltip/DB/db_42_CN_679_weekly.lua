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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Unholy','Hunter-Marksmanship','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Priest-Shadow','Priest-Holy','Priest-Discipline','Paladin-Retribution','Paladin-Holy','Paladin-Protection','DeathKnight-Blood',}; local provider = {region='CN',realm='恐怖图腾',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alita:AwAGCAIABRQAAA==.',Mo='Momoer:AwACCAIABAoAAA==.',Mq='Mqmqmqq:AwACCAIABRQAAA==.',Pr='Priness:AwAHCAcABAoAAA==.',Sp='Spiritwhite:AwAICAkABAoAAA==.',['�']='不存在嘚存在:AwAGCAsABAoAAA==.专业切蛋:AwAECAMABRQAAQEAVXAGCAYABRQ=.丨黑白信仰丨:AwACCAIABRQAAA==.',['�']='乃吉布吉岛:AwAECAQABAoAAA==.',['�']='云中漫步:AwABCAEABAoAAA==.云里雾理:AwACCAQABRQAAA==.',['�']='你凶个锤子:AwACCAUABRQCAgACAQj2GAAdF44ABRQAAgACAQj2GAAdF44ABRQAAA==.',['�']='傭人自擾:AwAHCAYABAoAAQMAVdsICAgABRQ=.',['�']='凤凰栖息梧桐:AwACCAMABRQAAA==.出门左转:AwAECAUABAoAAA==.',['�']='利刃风暴:AwACCAMABRQAAA==.',['�']='包健玮:AwAECAQABRQAAA==.',['�']='又见喵星人:AwACCAIABAoAAA==.叫你再凶:AwACCAIABRQAAA==.',['�']='吃个嘴子:AwADCAMABAoAAA==.',['�']='咆哮熊德:AwAECAEABRQAAA==.咔鮭咿丨小鳥:AwACCAQABRQAAA==.',['�']='团队毒瘤:AwACCAMABRQAAA==.',['�']='圣光会守护你:AwAECAQABAoAAA==.',['�']='大自在天:AwACCAIABAoAAA==.失真:AwAICA4ABAoAAA==.',['�']='奶骑玩累了:AwAGCAYABAoAAA==.',['�']='妖精美色:AwAGCAYABAoAAA==.',['�']='寂寞陪着寂寞:AwAGCAYABAoAAA==.',['�']='小盐熊崽汁:AwAECAQABRQAAA==.',['�']='惊恐的鸦熊:AwAICBgABAoEBAAIAQghFwBYqCYCBAoABAAIAQghFwBT7iYCBAoABQADAQh2IABa1ckABAoABgABAQh/VwBJz1AABAoAAA==.',['�']='扎外:AwABCAEABRQAAA==.',['�']='本波儿灞:AwABCAEABRQAAA==.机车男孩小夏:AwAFCAwABRQCAgAFAQh9AgBgekgBBRQAAgAFAQh9AgBgekgBBRQAAA==.',['�']='残月鸭:AwAECAgABRQDBwAIAQgyBQBa3c0CBAoABwAIAQgyBQBa3c0CBAoACAAGAQhGUQAXgsYABAoAAQkAFksGCAoABRQ=.',['�']='沁达利亚:AwACCAQABRQAAA==.',['�']='流月苍岚:AwACCAIABRQAAA==.浅殇止水:AwAECAoABRQDAwAEAQhJBABERAgBBRQAAwAEAQhJBABERAgBBRQAAQACAQhQKwAemYQABRQAAA==.',['�']='灬丶丨微笑:AwADCAgABRQCCgADAQhrHwARML8ABRQACgADAQhrHwARML8ABRQAAA==.灬卡特琳娜灬:AwAICBAABAoAAA==.灬活力鱼串灬:AwADCAMABRQAAA==.',['�']='無法離弃丶:AwACCAQABRQAAA==.',['�']='狂牛莫问:AwAGCAYABAoAAA==.',['�']='生鱼:AwAECAcABRQDCwAEAQh3CQAFjZ0ABRQACwADAQh3CQAFjZ0ABRQADAAEAQhiCQAgF5wABRQAAA==.',['�']='真香嗷:AwAICAgABAoAAQ0AY3oICAoABRQ=.眼镜掉了:AwAECAQABAoAAA==.',['�']='缘之空:AwAECAQABRQAAA==.',['�']='花开满:AwAECAQABAoAAA==.',['�']='苍狼啸月:AwAGCAYABAoAAA==.',['�']='茜拉:AwABCAEABAoAAA==.',['�']='虛化再造傳說:AwABCAEABAoAAA==.',['�']='触手可及:AwAECAEABRQAAA==.',['�']='超豪华一条龙:AwAGCAYABAoAAA==.',['�']='闊少爺:AwAGCAYABAoAAA==.',['�']='阔少爷:AwACCAUABRQCCgACAQh3KQAom5QABRQACgACAQh3KQAom5QABRQAAA==.',['�']='霜流刀:AwAECAQABAoAAA==.',['�']='风雨雷电:AwAECAQABRQAAA==.',['�']='鱼丸灬初面:AwAECAQABAoAAA==.',['�']='鳥鳥丶:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end