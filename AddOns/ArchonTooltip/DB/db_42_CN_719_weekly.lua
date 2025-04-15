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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Arms','Unknown-Unknown','Paladin-Retribution','Priest-Shadow','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','Warrior-Fury','Paladin-Protection','Mage-Fire','Rogue-Subtlety','DeathKnight-Frost','DeathKnight-Blood',}; local provider = {region='CN',realm='森金',name='CN',type='weekly',zone=42,date='2025-04-14',data={Co='Coco:AwAICAUABAoAAA==.',Em='Embert:AwABCAEABRQAAA==.',Fo='Foreverl:AwACCAIABRQAAA==.',Fr='Freeandnil:AwADCAcABRQDAQADAQgZIAA/8aMABRQAAQACAQgZIABE+qMABRQAAgACAQjAEAA23pAABRQAAA==.',Ku='Kun:AwACCAIABAoAAA==.',Ls='Lsir:AwACCAIABRQAAA==.',Rk='Rko:AwAGCAYABRQCAwAGAQg6AABFeOkBBRQAAwAGAQg6AABFeOkBBRQAAA==.',St='Starmen:AwAECAMABRQAAA==.',Vi='Violenceper:AwAGCAYABAoAAQQAAAAICAMABRQ=.',Za='Zangxixi:AwAICAgABAoAAQQAAAAGCAIABRQ=.',['�']='不吃牛肉:AwACCAIABRQAAA==.世仁林飞:AwACCAMABRQAAA==.丢总诺伊:AwAGCAgABAoAAA==.丨鲜血圣歌丨:AwAECAQABRQAAA==.中二病没得治:AwAECAQABRQAAA==.丿璐璐丿:AwAECAQABRQAAA==.丿黯灬痕:AwAECAQABRQAAA==.',['�']='光锭喝七喜:AwADCAEABAoAAA==.',['�']='冥羽林飞:AwAICAMABAoAAA==.',['�']='只玩火法:AwAFCAMABAoAAA==.',['�']='吱吱:AwACCAIABRQAAA==.',['�']='哇哈哈:AwAECAQABRQAAA==.',['�']='圣光小花牛:AwAECAQABRQAAA==.圣光旋律:AwAECAQABRQAAA==.圣光爆裂:AwAICAMABAoAAA==.圣光老崔:AwAECAYABRQCBQAEAQhBHQAeG80ABRQABQAEAQhBHQAeG80ABRQAAA==.',['�']='墨丶语:AwAECAQABRQAAA==.',['�']='夜封钰:AwAFCAcABAoAAA==.夜空星:AwAECAQABRQAAA==.大耐:AwABCAIABRQAAA==.大苏打撒:AwACCAEABAoAAA==.',['�']='孤高的梦:AwAGCAEABAoAAA==.',['�']='小丑灬哈利:AwAGCAEABAoAAA==.',['�']='布洛克斯希加:AwAICAgABAoAAA==.',['�']='强强:AwAECAQABRQAAA==.',['�']='怜悯丶:AwAGCAYABRQDBgAGAQhnEAAjebYABRQABgADAQhnEAAuOLYABRQABwADAQhoEgANCZYABRQAAA==.',['�']='战神宇:AwAICAgABAoAAA==.',['�']='打火机:AwAECAgABRQCBQAEAQibBQBSyTEBBRQABQAEAQibBQBSyTEBBRQAAA==.',['�']='抬头看看天:AwAECAQABAoAAA==.',['�']='搅得周天寒彻:AwACCAUABRQCBQAIAQg5OwBHoxsCBAoABQAIAQg5OwBHoxsCBAoAAA==.',['�']='故城:AwACCAQABRQAAA==.',['�']='智者晓彻:AwAECAQABRQAAA==.',['�']='暗影小牧丶:AwAECAQABRQAAA==.暴金之妖孽:AwACCAUABRQCCAACAQhqEQAhSoQABRQACAACAQhqEQAhSoQABRQAAA==.',['�']='木木秋:AwAECAMABRQAAA==.末丶予:AwAECAgABRQCCQAEAQiHDAA+f/wABRQACQAEAQiHDAA+f/wABRQAAA==.',['�']='杏灬林小小:AwAGCAoABRQDBgAGAQj2AQAs35kBBRQABgAGAQj2AQAs35kBBRQABwAEAQhNBwA7E/0ABRQAAA==.',['�']='枯樹年华:AwACCAIABRQAAA==.',['�']='柠檬心:AwAICAoABAoAAA==.',['�']='樂佰氏:AwAECAEABRQAAA==.',['�']='死丨騎:AwAECAQABRQAAA==.',['�']='沐雨言诗:AwAICAgABAoAAQQAAAACCAQABRQ=.',['�']='泷囍:AwAGCAEABAoAAA==.',['�']='海螺:AwAECAQABRQAAA==.',['�']='滚滚老崔:AwAECAQABRQAAA==.',['�']='灿灬灿:AwADCAMABRQAAA==.',['�']='熊猫罐头:AwAICAgABAoAAA==.',['�']='猩红丶:AwAECAIABRQAAA==.',['�']='留恋忘返:AwAECAQABRQAAA==.',['�']='真的美滋滋:AwAECAcABRQCBwACAQjeEgAyaJMABRQABwACAQjeEgAyaJMABRQAAA==.',['�']='私欲:AwABCAEABRQDAwAIAQi6DwBHtBsCBAoAAwAHAQi6DwBHtBsCBAoACgACAQiFgABPSjwABAoAAA==.',['�']='紅樓残夢:AwAECAQABRQAAA==.',['�']='红的发黑:AwAGCAEABAoAAA==.',['�']='绿色小王子:AwAICAYABAoAAA==.',['�']='聖丨騎:AwAGCA4ABRQDCwAGAQjrAAA90JMBBRQACwAGAQjrAAA6apMBBRQABQAEAQj9EgBMd/UABRQAAA==.',['�']='艾丽丶:AwAECAQABRQAAQwAWWMGCBQABRQ=.',['�']='萨丶:AwAECAQABRQAAA==.',['�']='蕾妮拉:AwAECAQABRQAAA==.',['�']='蛋疼的旋律:AwACCAIABRQAAA==.',['�']='逐静丶:AwAECAQABRQCCQAIAQiZEQBW7okCBAoACQAIAQiZEQBW7okCBAoAAA==.',['�']='遗忘海角:AwACCAIABRQAAA==.',['�']='长岛冰茶:AwAECAQABRQAAQ0AKnMGCAUABRQ=.',['�']='陌丶域:AwAGCAYABAoAAA==.陌羽:AwAICAgABAoAAA==.',['�']='雾中遗忘:AwABCAIABRQAAA==.',['�']='风中纸灰机:AwAFCAkABAoAAA==.风之逆襲:AwAECAgABRQDDgAEAQh/AQA6ig0BBRQADgAEAQh/AQA6ig0BBRQADwAEAQiEEwAM3nwABRQAAA==.飞的黑快:AwAECAQABRQAAA==.',['�']='骑丶:AwAICA4ABAoAAA==.',['�']='魂掉地上了:AwAICBAABAoAAA==.',['�']='麒麟:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end