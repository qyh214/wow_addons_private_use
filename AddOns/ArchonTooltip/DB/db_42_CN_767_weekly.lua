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
 local lookup = {'Druid-Balance','DeathKnight-Blood','Paladin-Retribution','Druid-Guardian','Shaman-Restoration',}; local provider = {region='CN',realm='瓦里玛萨斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asetulip:AwAGCAoABAoAAA==.',Io='Iotk:AwADCAMABAoAAA==.',Ti='Timmy:AwAECAQABRQAAA==.',['�']='一森林一:AwADCAgABRQCAQADAQiUDQA3sPAABRQAAQADAQiUDQA3sPAABRQAAA==.且末:AwAICAgABAoAAA==.丨遗忘丶夢:AwAECAQABAoAAA==.',['�']='九九归真:AwACCAMABRQAAA==.九宝:AwACCAMABRQAAA==.九宝琉璃塔:AwAECAQABRQAAA==.',['�']='仟丶锋:AwAFCAQABAoAAA==.',['�']='你伤不起:AwAECAQABRQAAA==.',['�']='光速任者:AwABCAEABRQAAA==.',['�']='刹月:AwAECAQABRQAAA==.',['�']='取名废:AwAHCBIABAoAAA==.',['�']='回眸筱開心:AwAICBAABAoAAA==.困死了:AwAECAQABRQAAA==.',['�']='大杰森:AwAECAQABRQAAA==.',['�']='奧妮克希亞:AwABCAEABAoAAA==.奶萨:AwAICAgABAoAAA==.奶非天:AwAFCAUABAoAAA==.',['�']='幽幽天狼:AwACCAIABAoAAA==.幽幽天行:AwAICAgABAoAAA==.',['�']='库斯卡雷:AwAGCAYABRQCAgAGAQj7CAAH2dUABRQAAgAGAQj7CAAH2dUABRQAAA==.',['�']='悠茗:AwAGCAQABAoAAA==.',['�']='想个名字先:AwAICBUABAoCAwAIAQiyBwBg2PMCBAoAAwAIAQiyBwBg2PMCBAoAAA==.',['�']='我真奶不上啊:AwAICA4ABAoAAA==.',['�']='打企鹅豆豆:AwACCAIABAoAAA==.',['�']='文夏奈尔:AwAICAYABAoAAA==.新的航行:AwAECAQABRQAAA==.',['�']='无雨之鱼:AwABCAEABAoAAA==.',['�']='月舞凝曦:AwAICAsABAoAAA==.',['�']='清风孤鸿:AwADCAMABAoAAA==.清风清风:AwACCAcABRQCBAACAQiNAwAZhVsABRQABAACAQiNAwAZhVsABRQAAA==.清风萨萨:AwABCAEABAoAAA==.',['�']='烤串大青柠:AwAICAgABAoAAA==.',['�']='特利丝杰娜:AwABCAEABAoAAA==.',['�']='相思重相忆:AwAECAQABRQAAA==.',['�']='红浪漫十六号:AwAICAMABAoAAA==.',['�']='绯色清空:AwAGCAkABAoAAA==.',['�']='老炮儿:AwAECAQABRQAAA==.',['�']='花花下的太阳:AwAECAQABRQAAA==.花花生西西:AwABCAEABRQAAA==.',['�']='莉卡茜娜:AwAGCAsABAoAAA==.',['�']='蓝色游魂:AwAECAQABRQAAA==.蓝色萨满:AwAECAYABRQCBQAEAQixCgA1AO0ABRQABQAEAQixCgA1AO0ABRQAAA==.',['�']='蜡笔不二熊:AwAGCAYABAoAAA==.',['�']='袴田日向:AwACCAYABRQCAwACAQi3IwA/KacABRQAAwACAQi3IwA/KacABRQAAA==.',['�']='诉予汹涌:AwAICBAABAoAAA==.',['�']='轻烟漫舞:AwACCAIABRQAAA==.',['�']='逝幕旳年华:AwADCAMABRQAAA==.',['�']='醉美是相遇:AwAICAoABAoAAA==.',['�']='闪电奔涌:AwAICA4ABAoAAA==.',['�']='防骑:AwACCAEABAoAAA==.阿佛洛狄忒:AwAICAgABAoAAA==.阿斯图利亚斯:AwAGCAgABAoAAA==.阿泽:AwAGCAQABRQAAA==.',['�']='马戏团出来的:AwAGCAEABAoAAA==.',['�']='骑蜗牛的猪:AwAECAQABRQAAA==.',['�']='魔兽大姨:AwACCAIABRQAAA==.',['�']='黑帝斯:AwADCAMABAoAAA==.',['�']='龙吟瑶瑶:AwAICAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end