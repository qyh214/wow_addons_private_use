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
 local lookup = {'Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','Druid-Restoration','Hunter-BeastMastery','Rogue-Subtlety','Rogue-Outlaw','Rogue-Assassination','Paladin-Protection','Mage-Fire','Mage-Frost','Shaman-Restoration','Shaman-Elemental','Monk-Windwalker','Warrior-Fury','Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Priest-Shadow','DeathKnight-Blood',}; local provider = {region='CN',realm='安威玛尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Dr='Drago:AwAECAQABAoAAA==.',Dy='Dyyi:AwABCAEABAoAAA==.',Fb='Fb:AwACCAcABRQCAQACAQjNJwAvFZkABRQAAQACAQjNJwAvFZkABRQAAA==.',Ja='Javne:AwAECAQABRQAAA==.',Ma='Maik:AwAGCAQABRQAAA==.',Ne='Nelg:AwAICAQABRQAAA==.',St='Staryy:AwAHCB0ABAoDAgAHAQiNIQBK4Q4CBAoAAgAHAQiNIQBK4Q4CBAoAAwACAQihKgAg6kYABAoAAA==.',Ti='Tinko:AwACCAIABAoAAA==.',Zi='Ziiki:AwAGCAYABRQCBAAGAQhsAQAgqmgBBRQABAAGAQhsAQAgqmgBBRQAAA==.Ziki:AwAGCAkABAoAAA==.',['�']='三克油:AwABCAEABAoAAA==.',['�']='今晚不睡:AwAGCAoABAoAAA==.以朕之名:AwAHCA0ABAoAAA==.',['�']='你是猎物:AwAGCBkABAoCBQAGAQgwcQAwpCwBBAoABQAGAQgwcQAwpCwBBAoAAA==.',['�']='冰极似火:AwAICAgABAoAAA==.',['�']='刀客啦啦噜:AwAICAgABAoAAA==.刃落无声:AwAHCBoABAoEBgAHAQh9FABEwqcBBAoABgAGAQh9FABKcKcBBAoABwAFAQieDAAoO/cABAoACAACAQhaMgAlFYQABAoAAA==.初見:AwAICAgABAoAAA==.',['�']='卡瓦一:AwABCAEABAoAAA==.卡索弥亚:AwAHCBsABAoDAQAHAQjTgAAq3WsBBAoAAQAHAQjTgAAq3WsBBAoACQAFAQgaQAAK32kABAoAAA==.',['�']='叮叮当当:AwAHCAcABAoAAA==.',['�']='咕德猫宁:AwACCAIABAoAAA==.',['�']='喔抱歉:AwAHCAcABAoAAA==.',['�']='圣吉列斯:AwADCAMABAoAAA==.圣斗士七曜:AwAGCAYABRQDCQAIAQj0DABG8xACBAoACQAIAQj0DABEYBACBAoAAQAIAQjQawAxnJsBBAoAAA==.',['�']='大颗粒丶:AwAICAgABAoAAA==.天使笑傻了:AwAHCB0ABAoDCgAHAQhOIQBO6RwCBAoACgAHAQhOIQBO6RwCBAoACwACAQi7ggA7kWQABAoAAA==.',['�']='奶茶小怪兽:AwAGCAkABAoAAA==.',['�']='如月爱:AwAECAQABAoAAA==.',['�']='射天射地射人:AwAICAgABAoAAA==.小牛牛:AwAICBgABAoDDAAIAQhNFwBPuSoCBAoADAAIAQhNFwBPuSoCBAoADQAIAQjwFwBHKQECBAoAAA==.',['�']='布鲁斯塔:AwAGCAYABAoAAA==.',['�']='幻影紫霞:AwAHCBsABAoCAQAHAQizUQBE99sBBAoAAQAHAQizUQBE99sBBAoAAA==.幽魂:AwAGCAsABAoAAA==.',['�']='开心果丶黑铁:AwAICAgABAoAAA==.',['�']='情傷:AwAICCIABAoCDAAIAQjxNgAzi4QBBAoADAAIAQjxNgAzi4QBBAoAAA==.',['�']='慕怜:AwAHCAcABAoAAA==.',['�']='描边大师:AwAHCAcABAoAAA==.',['�']='救赎流氓:AwADCAMABAoAAA==.',['�']='无尘:AwADCAsABRQCDgADAQjOBgA+APoABRQADgADAQjOBgA+APoABRQAAA==.',['�']='星陨之痕:AwAICAcABAoAAA==.春风花开:AwAECAQABRQAAA==.',['�']='暴力释加牟尼:AwAHCBQABAoCDwAHAQhDMQAr8JoBBAoADwAHAQhDMQAr8JoBBAoAAA==.',['�']='曦月红尘:AwABCAEABAoAAA==.',['�']='李依桐:AwACCAIABAoAAA==.条形码:AwAHCB0ABAoDEAAHAQglMgA8uY4BBAoAEAAGAQglMgA8uY4BBAoAEQADAQh1SQAvUH0ABAoAAA==.来杯冰可乐:AwAECAYABRQCCgAEAQg/FwAtsN0ABRQACgAEAQg/FwAtsN0ABRQAAA==.',['�']='柏林:AwADCAgABAoAAA==.',['�']='树不高:AwADCAMABAoAAA==.格拉海德宗师:AwAHCBIABAoAAA==.',['�']='梦幻皮宝宝:AwAICBAABAoAAA==.梦甜甜:AwAFCAUABAoAAA==.',['�']='泰蓝德语风:AwAICAgABAoAAA==.',['�']='火焰冰激凌:AwAECAQABRQAAA==.',['�']='牧不转睛:AwAECAQABRQAAA==.',['�']='独享忧愁:AwADCAMABAoAAA==.',['�']='盘古:AwACCAEABAoAAA==.',['�']='知命:AwAGCBAABAoAAA==.石头姣姣:AwAECAQABAoAAA==.',['�']='秃头爸爸:AwAICAgABAoAAA==.',['�']='第七次日落:AwAFCAYABAoAAA==.',['�']='肤如凝脂:AwACCAIABAoAAA==.',['�']='艾丽西亚韩:AwABCAEABAoAARIAAAAHCBIABAo=.',['�']='萨贝宁萨乌鸡:AwAICAgABAoAAA==.',['�']='言倩:AwEBCAEABRQAAA==.',['�']='迷路的下野:AwAHCB0ABAoCBAAHAQguJAA3R38BBAoABAAHAQguJAA3R38BBAoAAA==.追求放假:AwAGCAoABAoAAA==.',['�']='逗逗毅吖:AwAECAMABRQAAA==.',['�']='酷儿啼拉丝:AwADCAMABAoAAA==.酷酷骑:AwACCAIABRQAAA==.',['�']='霁月爫:AwAICAgABAoAAA==.',['�']='非洲张学友:AwABCAEABAoAAA==.',['�']='风雨红尘:AwABCAEABRQAAA==.',['�']='驭兽者孙晓美:AwAICAgABAoAAA==.',['�']='黄裁缝:AwACCAIABRQAARMAN1QGCAYABRQ=.黑骑士七曜:AwAICBcABAoCFAAIAQidDwBGGRICBAoAFAAIAQidDwBGGRICBAoAARIAAAAGCAQABRQ=.',['�']='龍姬:AwACCAIABAoAAA==.龙之骑:AwAICAgABAoAAA==.龙城夜如花:AwAICAgABAoAAA==.龙城夜如雪:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end