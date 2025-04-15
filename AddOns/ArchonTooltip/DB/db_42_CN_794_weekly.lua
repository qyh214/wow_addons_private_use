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
 local lookup = {'Hunter-Marksmanship','Warrior-Fury','Warrior-Arms','Mage-Frost','DeathKnight-Unholy','Paladin-Retribution','Druid-Balance','Shaman-Enhancement','Unknown-Unknown','Paladin-Protection','Hunter-BeastMastery','Monk-Mistweaver',}; local provider = {region='CN',realm='耐普图隆',name='CN',type='weekly',zone=42,date='2025-04-15',data={Af='Afatinib:AwAECAQABRQAAA==.',Er='Erinyes:AwAHCAcABAoAAA==.',Ha='Haohei:AwAGCAcABAoAAA==.',He='Hez:AwABCAEABRQAAA==.',Hi='Higher:AwAFCAgABAoAAA==.',Ko='Kotka:AwACCAIABAoAAA==.',Me='Memories:AwAGCAoABAoAAA==.',Rd='Rdss:AwAICA8ABAoAAA==.',Ta='Talone:AwACCAIABAoAAA==.',Tr='Triassicus:AwAECAQABRQAAA==.',['�']='一米六八征婚:AwAICAcABAoAAA==.三开战猎萨:AwAGCAYABRQCAQAGAQh/AAA5bqYBBRQAAQAGAQh/AAA5bqYBBRQAAA==.不充值咋变强:AwABCAEABAoAAA==.丨小可爱:AwACCAIABAoAAA==.丨百变怪丨:AwAGCBMABAoAAA==.丷小布:AwAECAQABAoAAA==.',['�']='乌鸦坐飞滴:AwACCAIABAoAAA==.',['�']='五花丶小烤肉:AwAICAgABAoAAA==.五香牛肉干:AwAICBYABAoDAgAIAQh1LAA27b4BBAoAAgAIAQh1LAAv7b4BBAoAAwAGAQg1LQA9BiMBBAoAAA==.',['�']='伊吹萃香:AwACCAIABRQAAA==.',['�']='你来追我呀丶:AwACCAIABRQAAA==.',['�']='倚泪潇湘:AwAGCAYABAoAAA==.',['�']='冬灵:AwAHCAsABAoAAA==.',['�']='剧摸:AwACCAMABRQAAA==.',['�']='南南希:AwAECAYABRQCBAAEAQhNBwBAoeEABRQABAAEAQhNBwBAoeEABRQAAA==.',['�']='哇噻:AwABCAEABAoAAA==.',['�']='夏天的风:AwAECAQABRQAAA==.',['�']='奇东呛:AwABCAEABRQAAA==.',['�']='如你所愿:AwAGCAEABAoAAA==.',['�']='嫣雨婉情:AwADCAMABAoAAA==.',['�']='守望丨魂:AwABCAEABRQAAA==.',['�']='岛田侑嘉:AwABCAEABRQAAA==.',['�']='左岸风海:AwADCAMABAoAAA==.',['�']='归来梓灬:AwACCAIABRQAAA==.',['�']='心态要放松:AwAECAYABRQCBQAEAQgQEQAaKdQABRQABQAEAQgQEQAaKdQABRQAAA==.忆晨:AwAECA4ABRQCBgAEAQiRCABS/yUBBRQABgAEAQiRCABS/yUBBRQAAA==.快去找奈非天:AwAFCAUABAoAAA==.',['�']='惊鸿:AwAECAgABRQCBgAEAQgkCABOxScBBRQABgAEAQgkCABOxScBBRQAAA==.',['�']='扁扁:AwAECAgABRQCBgAEAQh8GAAxyOwABRQABgAEAQh8GAAxyOwABRQAAA==.',['�']='挠你后背:AwAGCAYABRQCBwAGAQhNAQA27bABBRQABwAGAQhNAQA27bABBRQAAA==.',['�']='敖夜:AwAICAgABAoAAA==.',['�']='晓雪江烟:AwABCAIABRQAAA==.晴天:AwAICBYABAoCCAAIAQjZGQA+gOYBBAoACAAIAQjZGQA+gOYBBAoAAA==.晴朗:AwACCAMABRQAAA==.',['�']='梅穿苦茶:AwAICA8ABAoAAA==.',['�']='橙色木马:AwAECAQABRQAAA==.',['�']='欺负人的大王:AwABCAEABRQAAA==.',['�']='焖不熟的排骨:AwAICBAABAoAAQkAAAAGCAQABRQ=.焖得熟的排骨:AwAECAQABRQAAA==.',['�']='煮不熟的排骨:AwAHCAcABAoAAA==.',['�']='牛肉老板:AwAECAQABAoAAA==.',['�']='狮子头:AwACCAIABAoAAA==.',['�']='琪露诺:AwAICAgABAoAAA==.',['�']='瑞雯:AwACCAUABRQCBwACAQgXGwBHJ6gABRQABwACAQgXGwBHJ6gABRQAAA==.瑞雯丶:AwADCAMABAoAAA==.瑾歆:AwAECAQABRQAAA==.',['�']='皺著眉頭的你:AwAECAYABRQDCgAEAQiuCgAhXpYABRQACgAEAQiuCgAhXpYABRQABgACAQjUNQARo30ABRQAAA==.皺著眉頭看雨:AwAECAUABAoAAA==.',['�']='知无言:AwABCAEABRQAAA==.',['�']='红油辣子:AwAECAYABRQCCwAEAQitDwA2+AIBBRQACwAEAQitDwA2+AIBBRQAAA==.',['�']='能个儿:AwAFCAUABAoAAA==.',['�']='葡萄物语:AwAICAYABRQCDAAGAQjWAQA1MqQBBRQADAAGAQjWAQA1MqQBBRQAAA==.',['�']='资乄本:AwAGCAYABAoAAA==.赵小帅:AwAECAgABAoAAA==.',['�']='追火车:AwAECAQABRQAAA==.',['�']='通灵领主:AwAECAwABRQCBQAEAQgsDgA2gucABRQABQAEAQgsDgA2gucABRQAAA==.',['�']='邪恶小洢:AwAGCAkABAoAAA==.',['�']='铁血审判:AwAICBAABAoAAA==.银月城的光丨:AwACCAIABRQAAA==.',['�']='阿楠喜欢养猫:AwAECAQABRQAAA==.',['�']='霹雳双刀小吼:AwABCAEABAoAAA==.',['�']='马里奥利奥:AwAGCAkABAoAAA==.',['�']='鴆羽千夜:AwAICAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end