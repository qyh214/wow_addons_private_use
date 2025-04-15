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
 local lookup = {'Unknown-Unknown','Priest-Discipline','Priest-Holy','Druid-Feral','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Fury','Shaman-Enhancement','Paladin-Retribution','Monk-Windwalker','Monk-Brewmaster','Priest-Shadow','Mage-Fire',}; local provider = {region='CN',realm='自由之风',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ab='Abysstoller:AwAFCA0ABAoAAQEAAAAICAwABAo=.',As='Asky:AwAGCAYABAoAAA==.',Bl='Blameuncle:AwAICBAABAoAAA==.',Dr='Driest:AwAFCBcABAoDAgAFAQhPLwBPgkYBBAoAAwAFAQi6MgBNdVIBBAoAAgAFAQhPLwBLZkYBBAoAAA==.',Es='Essementhol:AwAFCAgABAoAAA==.',Fa='Faceless:AwADCAMABRQAAA==.',Gr='Grimoire:AwAGCAUABAoAAA==.',Je='Jearo:AwAHCAsABAoAAA==.',Lo='Lovelybaby:AwABCAEABAoAAA==.',St='Strank:AwAECAQABRQAAA==.',Tu='Turn:AwABCAEABAoAAA==.',['�']='一笑好运:AwABCAEABAoAAA==.且听風吟:AwABCAEABRQAAA==.且聽風吟:AwAECAQABRQAAA==.丧彪:AwAGCAQABRQAAA==.丶生悻哆懿:AwACCAIABRQAAA==.',['�']='久远的猫音:AwAFCAoABAoAAA==.乌瑞亚:AwAECAQABRQAAA==.',['�']='伱老婆:AwAGCAkABAoAAA==.',['�']='佟大为:AwACCAUABRQCBAACAQgAAwBIlcIABRQABAACAQgAAwBIlcIABRQAAA==.',['�']='光头:AwAHCAwABAoAAA==.克麗絲:AwAECAQABRQAAA==.',['�']='冈仁波齐:AwADCAMABAoAAA==.冰清玉洁:AwAICBsABAoCBQAIAQhzDABVxqwCBAoABQAIAQhzDABVxqwCBAoAAA==.',['�']='凰荧:AwACCAEABRQAAA==.',['�']='吃人刀丶:AwAICAIABAoAAA==.',['�']='哩咕哩咕胡了:AwAICAYABAoAAA==.',['�']='善恶有报:AwAICAcABRQDBQAEAQhQDQBCB+wABRQABQAEAQhQDQA9fuwABRQABgADAQhQGAAZ+mcABRQAAA==.',['�']='圣光小奶骑:AwADCAMABAoAAA==.圣狱酋长:AwAGCAcABAoAAA==.',['�']='夜揽星月:AwADCAMABAoAAA==.夜枫丶:AwABCAEABAoAAA==.天神山丘:AwADCAgABRQCBwADAQjUCwA3KAABBRQABwADAQjUCwA3KAABBRQAAA==.天道萌叔叔:AwAGCAkABAoAAA==.',['�']='奔雷手文泰來:AwACCAIABRQAAA==.奶粉加点糖:AwAGCAcABAoAAA==.奶糖糖:AwAGCAsABAoAAA==.奶糖苹果甜派:AwAICA8ABAoAAA==.好多鱼:AwACCAIABRQAAA==.好射:AwAECAQABRQAAA==.',['�']='如臻至极:AwABCAEABAoAAA==.',['�']='射雕大侠:AwACCAIABAoAAA==.小型车:AwABCAEABAoAAA==.小家伙:AwAHCBIABAoAAA==.小狗:AwACCAIABAoAAA==.小白糖:AwAICAYABAoAAA==.小萨满:AwAICA8ABAoAAA==.尐尐瘸:AwADCAMABAoAAA==.',['�']='希尔瓦纳缌:AwAECAkABAoAAA==.',['�']='平静之海:AwAGCAoABAoAAA==.',['�']='彼时的月光:AwAECAQABRQAAA==.',['�']='微风细语:AwAICAcABAoAAA==.',['�']='心的冬眠:AwAGCAQABRQAAA==.',['�']='思念漫太古:AwAECAMABAoAAA==.怨虎龙:AwAICAgABAoAAA==.',['�']='惘沉妖:AwAHCAoABAoAAA==.',['�']='我可以是源氏:AwAICAIABAoAAA==.我超漂亮的:AwACCAIABRQAAA==.',['�']='敏感:AwAGCA0ABAoAAA==.',['�']='无敌小小刀:AwAGCAIABRQAAA==.无敌老雷:AwAECAQABRQAAA==.',['�']='是个法師:AwABCAEABAoAAA==.',['�']='暁騎仕:AwAECAQABAoAAA==.',['�']='曼音天籁:AwAGCAQABRQAAA==.',['�']='最后一只猫:AwABCAIABRQAAA==.末藍星:AwABCAEABRQAAA==.',['�']='李二丫:AwADCAMABAoAAA==.',['�']='柠檬多多:AwAICCEABAoCCAAIAQgQAQBiLwwDBAoACAAIAQgQAQBiLwwDBAoAAA==.',['�']='梦回苍莽:AwACCAIABAoAAA==.',['�']='樱桃肥肥子:AwAECAQABAoAAA==.',['�']='此子斷不可留:AwACCAIABAoAAA==.',['�']='段誉:AwAECAQABRQAAA==.',['�']='江橙:AwAICBoABAoCCQAIAQgcTwA4m+sBBAoACQAIAQgcTwA4m+sBBAoAAA==.',['�']='洋哥:AwACCAMABRQDCgAIAQi9HAA+qNsBBAoACgAHAQi9HABIRNsBBAoACwAIAQi6DgAlDDIBBAoAAA==.',['�']='海景乄佛跳墙:AwAICAgABAoAAA==.',['�']='游泳的蝌蚪:AwABCAEABAoAAA==.',['�']='灬筱墨:AwABCAEABAoAAA==.',['�']='独幕周:AwAICAUABAoAAA==.',['�']='猴奈我何:AwAGCAcABAoAAA==.',['�']='电眼妹妹:AwAECAQABAoAAA==.电眼姐姐:AwAGCAYABAoAAA==.',['�']='疯狂小萝莉:AwAFCAYABAoAAA==.',['�']='缘妙不可言:AwACCAUABRQCCQACAQgVNQAa54AABRQACQACAQgVNQAa54AABRQAAA==.',['�']='群峰之上:AwAECAMABRQAAA==.',['�']='耀骑士临光:AwAICAgABAoAAA==.',['�']='舞雩:AwAICBkABAoDDAAIAQhnIgAsuqUBBAoADAAIAQhnIgAsuqUBBAoAAwAGAQgtTwAcp9YABAoAAA==.',['�']='荧荧小贝:AwABCAEABRQAAA==.荧荧小龙:AwAECAQABRQAAA==.',['�']='血腥币啦啦:AwAICA8ABAoDBQAHAQh6eAAc474ABAoABQAGAQh6eAAZ+74ABAoABgABAQgMWgArazQABAoAAA==.',['�']='西行妖:AwAFCAEABAoAAA==.',['�']='银瞳克蕾雅:AwAGCAYABRQCCQAGAQiLAQAsh64BBRQACQAGAQiLAQAsh64BBRQAAA==.',['�']='长崎素食:AwAECAQABRQAAA==.',['�']='闪烁:AwABCAEABAoAAA==.',['�']='零度萌萌哒:AwAGCAcABRQCDQAFAQh/JwBLWJMABRQADQAFAQh/JwBLWJMABRQAAA==.',['�']='靇靈雲霄:AwAECAQABRQAAA==.',['�']='飓嘿丨:AwAGCAYABRQCCQAGAQj0AQAlipcBBRQACQAGAQj0AQAlipcBBRQAAA==.',['�']='饭碗:AwADCAMABAoAAA==.',['�']='骑士:AwAFCAUABAoAAA==.',['�']='鬼迷星窍:AwAHCAoABAoAAA==.',['�']='黑百合:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end