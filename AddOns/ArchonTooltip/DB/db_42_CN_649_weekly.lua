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
 local lookup = {'Shaman-Elemental','Paladin-Retribution','Warrior-Arms','Paladin-Protection','Evoker-Devastation','Druid-Balance','Druid-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Shaman-Restoration','Mage-Frost','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='安加萨',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ch='Choose:AwAICM8ABAoCAQAIAQi9AABg8g0DBAoAAQAIAQi9AABg8g0DBAoAAA==.',Qs='Qser:AwAECAQABAoAAA==.',['�']='一无所有:AwAECAQABAoAAA==.丶青山劉德華:AwACCAIABRQAAA==.',['�']='乄故人旧眸:AwACCAIABAoAAA==.',['�']='二手电工:AwAFCAUABAoAAA==.',['�']='倾城丶圣契:AwAECAcABRQCAgAEAQhIEwA7lPQABRQAAgAEAQhIEwA7lPQABRQAAQMAIZ4GCAoABRQ=.',['�']='假装有名字:AwAICAgABAoAAA==.',['�']='傻馒祭司:AwAECAQABRQAAA==.',['�']='可楽加牛奶:AwACCAIABRQAAA==.',['�']='哈次捏米库:AwACCAEABRQAAA==.',['�']='夜夜生戈:AwAECAQABRQAAA==.太刀侠:AwAICBAABAoAAA==.',['�']='妹妹别跑呀:AwAECAYABRQDAgAEAQh4CgBDIxYBBRQAAgAEAQh4CgBDIxYBBRQABAACAQhyDwAIlFAABRQAAA==.',['�']='姐爱加血:AwAGCAYABAoAAA==.',['�']='孙子丶丶:AwAECAQABRQAAA==.',['�']='宮脇咲良:AwACCAcABRQCBQACAQgXEgAdR4MABRQABQACAQgXEgAdR4MABRQAAA==.',['�']='小龙龙人:AwAHCA8ABAoAAA==.尘埃晓骑:AwAECAYABRQCAgAEAQj+CwBOVBABBRQAAgAEAQj+CwBOVBABBRQAAA==.就奶我:AwAECAMABRQAAA==.尼诺滴咕咕:AwABCAEABRQAAA==.',['�']='岚李斯特:AwAECAYABAoAAA==.',['�']='崔斯塔娜:AwABCAEABAoAAA==.',['�']='年年有魚:AwAECAIABRQAAA==.',['�']='康斯坦丁丶:AwAECAIABRQDBgAIAQhvFQBS2GsCBAoABgAIAQhvFQBS2GsCBAoABwAIAQipGQA3fcwBBAoAAA==.',['�']='我宝宝呢:AwAICBUABAoDCAAIAQh7HwBPvZwBBAoACQAHAQikQQBM4skBBAoACAAIAQh7HwBFmJwBBAoAAA==.',['�']='扒拉咚:AwADCAMABRQAAA==.',['�']='抹茶小蛋糕喵:AwAICAgABAoAAA==.',['�']='是风子千呀:AwAGCAYABAoAAA==.',['�']='晓芙灬丽:AwAICA0ABAoAAA==.',['�']='暁坏坏:AwAHCAwABAoAAA==.',['�']='本多二代:AwABCAEABAoAAA==.',['�']='森林狼:AwACCAIABRQDCgAIAQibAwBTjDgCBAoACgAIAQibAwBJdTgCBAoACAAHAQjFHgBP7qEBBAoAAA==.',['�']='欢乐的小淇:AwAICBQABAoCCwAIAQh3CQBYtZkCBAoACwAIAQh3CQBYtZkCBAoAAA==.',['�']='残妆丶:AwAICAgABAoAAA==.',['�']='水煮牛鞭丶:AwAGCAoABAoAAA==.',['�']='沉沦万千:AwABCAEABAoAAA==.沉默狮子:AwADCAMABAoAAA==.',['�']='法力残渣:AwAICAgABAoAAA==.',['�']='灵魂绽放:AwABCAEABRQAAA==.',['�']='皮多肉少:AwAICBwABAoCDAAIAQhfDQBP2noCBAoADAAIAQhfDQBP2noCBAoAAA==.',['�']='相见欢:AwAGCAYABAoAAA==.',['�']='笑笑:AwABCAEABRQAAA==.',['�']='给爷跪下:AwADCAMABAoAAA==.绝望的幻月:AwABCAEABRQAAA==.绿色飞翔:AwAECAYABAoAAA==.',['�']='脚指头:AwAECAQABAoAAA==.',['�']='范廸塞尔:AwADCAQABAoAAA==.',['�']='血诅咒:AwAICB4ABAoDDQAIAQiJPQAfu4ABBAoADQAIAQiJPQAfu4ABBAoADAAGAQj9VQAZud8ABAoAAA==.',['�']='软甜糯米糕:AwAECAQABRQAAA==.',['�']='迷人小陷阱:AwACCAIABAoAAA==.',['�']='释迦殿下:AwACCAIABAoAAA==.',['�']='霹雳浪味仙:AwACCAIABRQAAQ4AAAAICAQABRQ=.',['�']='鬼舞辻無惨:AwAHCAgABAoAAA==.',['�']='黑色傻猫:AwADCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end