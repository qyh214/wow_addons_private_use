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
 local lookup = {'DeathKnight-Unholy','Druid-Balance','Warrior-Arms','Warrior-Fury','Warlock-Destruction','Paladin-Retribution','Druid-Feral','Shaman-Restoration','Monk-Windwalker','Unknown-Unknown','Monk-Mistweaver','Paladin-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Elemental',}; local provider = {region='CN',realm='艾森娜',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ac='Actualrisk:AwAFCAUABAoAAA==.',Ba='Banshee:AwACCAIABRQAAA==.',Ir='Ironic:AwADCAMABAoAAA==.',Pl='Playergxidub:AwADCAMABAoAAA==.',Re='Re:AwAGCAYABRQCAQAGAQi6AQArUqYBBRQAAQAGAQi6AQArUqYBBRQAAA==.',Sp='Spiky:AwAECAQABRQAAA==.',['�']='一安:AwAECAMABRQAAA==.一梦两三年:AwAECAgABRQCAgAEAQhYBwBXTRsBBRQAAgAEAQhYBwBXTRsBBRQAAQIAQiQGCAoABRQ=.不可宽恕:AwAECAQABRQAAA==.两条丶毛腿:AwACCAIABAoAAA==.',['�']='九灯灬长歌:AwAECAwABRQDAwAEAQgoBQBNO/MABRQABAAEAQjnCABAFg8BBRQAAwAEAQgoBQAyEvMABRQAAA==.',['�']='云栖松子糖:AwAECAgABRQCBQAEAQiYBwBKUAsBBRQABQAEAQiYBwBKUAsBBRQAAA==.',['�']='伊达航:AwAICBoABAoCBgAIAQj2QwBMBAoCBAoABgAIAQj2QwBMBAoCBAoAAQcAV+MFCBIABRQ=.',['�']='六月十柒:AwAHCAkABAoAAA==.',['�']='冷静点:AwAICAgABAoAAA==.',['�']='凄凉的乌米:AwAECAQABRQAAA==.',['�']='北极极:AwAICAMABAoAAA==.',['�']='千雪:AwABCAIABRQAAA==.午夜小奶嘴:AwAECAQABRQAAA==.',['�']='又一只狗:AwABCAEABRQAAA==.',['�']='吉田步美:AwAFCBIABRQCBwAFAQgnAABX450BBRQABwAFAQgnAABX450BBRQAAA==.',['�']='呢喃:AwAFCAYABAoAAQgAVToDCAcABRQ=.',['�']='和气勿喷:AwAICA4ABAoAAA==.咕嘟:AwAHCBIABAoAAQgAVToDCAcABRQ=.',['�']='圣光梵尘:AwAICA0ABAoAAA==.圣光重现:AwABCAIABRQAAA==.',['�']='夕姐:AwAECAQABRQAAA==.',['�']='妳豆子丶:AwACCAIABRQAAA==.',['�']='封印堕落:AwAECAQABRQAAA==.小橘呢:AwAICAgABAoAAA==.',['�']='布鲁斯邢:AwAECAQABAoAAA==.',['�']='平凡的平凡:AwAICAYABAoAAA==.年轻的信赖:AwAHCAgABAoAAA==.',['�']='异度装甲:AwAICA0ABAoAAA==.',['�']='影月晴空:AwABCAEABRQAAA==.',['�']='德勒克斯汀:AwADCAMABRQAAA==.',['�']='数智术:AwABCAEABRQAAA==.',['�']='断水流大湿兄:AwAICAgABAoAAQkAUbUHCAcABRQ=.',['�']='暖了个暖:AwADCAMABAoAAA==.',['�']='月落诗无痕:AwAICAgABAoAAA==.',['�']='極樂仙貝:AwADCAgABRQCBwADAQgkAQBSPiMBBRQABwADAQgkAQBSPiMBBRQAAA==.',['�']='汉鼎:AwAFCAkABAoAAA==.',['�']='沉睡的小猫:AwAECAQABRQAAA==.',['�']='法落梵尘:AwAECAQABRQAAA==.泪人:AwABCAEABRQAAA==.',['�']='溜溜球:AwACCAIABRQAAA==.',['�']='火酒灬长歌:AwAECAIABRQAAQoAAAAICAIABRQ=.',['�']='炖虾大王:AwAECAQABRQAAA==.',['�']='烟花雪:AwACCAIABRQAAA==.',['�']='爱咬人的宝宝:AwABCAEABRQCCwAIAQgaOgAaCEQBBAoACwAIAQgaOgAaCEQBBAoAAA==.爱莉希雅:AwAECAoABRQDBgAEAQjFHAA5bd4ABRQABgAEAQjFHAA3aN4ABRQADAAEAQhyDQAOaHcABRQAAA==.',['�']='狄玫:AwAICBUABAoCBgAIAQhbggAnKXMBBAoABgAIAQhbggAnKXMBBAoAAA==.',['�']='王牌技师:AwAICBAABAoAAA==.',['�']='珀琉斯晨风:AwACCAIABRQAAA==.',['�']='琴瑟:AwADCAcABRQCCAADAQgmBABVOi4BBRQACAADAQgmBABVOi4BBRQAAA==.',['�']='看死你:AwAECAcABRQCDQAEAQibCgBR6AoBBRQADQAEAQibCgBR6AoBBRQAAA==.',['�']='神圣企鹅:AwACCAMABRQCBgAIAQgONABLfj0CBAoABgAIAQgONABLfj0CBAoAAA==.',['�']='绯斯:AwAGCAQABRQAAA==.',['�']='艾蕾西娅:AwAFCAgABAoAAA==.',['�']='莫西沙星:AwAECAQABRQAAQkAUbUHCAcABRQ=.',['�']='迈克劫个色:AwAICAYABAoAAA==.这瓜保熟吗:AwAICAQABAoAAA==.',['�']='那没事了:AwAECAQABRQAAA==.',['�']='阿拉丁:AwAICAgABAoAAA==.阿笠博士:AwAICAsABAoAAQcAV+MFCBIABRQ=.',['�']='雪魂归来:AwADCAkABRQCDgADAQgJCQAco6cABRQADgADAQgJCQAco6cABRQAAA==.雷电影:AwAICBsABAoCDwAIAQjhBQBYzsgCBAoADwAIAQjhBQBYzsgCBAoAAA==.',['�']='青黛:AwAECAYABRQCAgAEAQgdDABORf0ABRQAAgAEAQgdDABORf0ABRQAAA==.',['�']='风中的弯犄角:AwAECAQABRQAAA==.',['�']='麦乐鸡贼:AwACCAMABAoAAA==.',['�']='龙母壮骨颗粒:AwAICAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end