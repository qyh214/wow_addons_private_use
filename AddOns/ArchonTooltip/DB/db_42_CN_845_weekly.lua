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
 local lookup = {'Mage-Frost','Paladin-Retribution','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Holy','Druid-Guardian','Druid-Feral','Evoker-Devastation','Monk-Brewmaster','Monk-Windwalker',}; local provider = {region='CN',realm='迦玛兰',name='CN',type='weekly',zone=42,date='2025-04-15',data={El='Elis:AwACCAIABRQAAA==.',Mi='Miao:AwAECAQABRQAAA==.',No='Norris:AwAGCAYABAoAAA==.',Pe='Penknife:AwADCAMABAoAAA==.',['�']='一卡卡:AwAICAgABAoAAA==.两岸统一:AwAICBcABAoCAQAIAQj3CABdvLACBAoAAQAIAQj3CABdvLACBAoAAA==.丨电闪丶雷鸣:AwAFCAgABAoAAA==.',['�']='乾坤无极:AwAHCAcABAoAAA==.',['�']='二郎险胜真君:AwABCAEABAoAAA==.',['�']='今夜不会醉:AwAECAQABRQAAA==.',['�']='佛洛狄忒:AwAGCAYABAoAAA==.',['�']='光辉岁月:AwACCAIABRQAAA==.其实我很帅:AwAICAQABAoAAA==.',['�']='冰糖番茄酱:AwAICAgABAoAAA==.冷钢:AwAFCAYABAoAAA==.',['�']='卡卡:AwAECAQABRQAAA==.',['�']='叨刀:AwACCAIABRQCAgAIAQjIFgBYGK4CBAoAAgAIAQjIFgBYGK4CBAoAAA==.叮噹貓:AwAECAQABAoAAA==.',['�']='夏蓉大发丶萨:AwAICBAABAoAAA==.大榴莲想滋人:AwAFCAgABAoAAQMAAAACCAMABRQ=.大榴莲想背刺:AwACCAMABRQAAA==.天乐:AwAFCAcABAoAAA==.',['�']='奈何与天齐:AwAECAQABAoAAA==.女射手李琪薇:AwAICBQABAoDBAAIAQhzDQBQcEwCBAoABAAIAQhzDQBQcEwCBAoABQABAQgK/QAKCxwABAoAAA==.',['�']='学石油毁一生:AwACCAIABAoAAA==.',['�']='寒月冷风:AwAGCAYABAoAAA==.',['�']='尼查德泰绅:AwAICBAABAoAAA==.',['�']='库附魔:AwACCAcABRQCBgACAQi3DwA+F5kABRQABgACAQi3DwA+F5kABRQAAA==.',['�']='影墨:AwABCAEABAoAAA==.',['�']='微风不燥:AwAGCAEABRQAAA==.',['�']='怡格:AwAFCAUABAoAAA==.',['�']='恶灵之缚:AwADCAQABAoAAA==.',['�']='折耳根丶:AwACCAMABAoAAA==.',['�']='拉克絲丶:AwAGCA4ABAoAAA==.',['�']='无趣:AwAFCAUABAoAAA==.',['�']='月华落幕:AwACCAIABAoAAA==.木木夕雨霞:AwACCAIABAoAAA==.',['�']='来个熊猫:AwAECAQABAoAAA==.',['�']='标哥:AwAECAQABAoAAA==.树忄爿:AwAICAgABAoAAA==.',['�']='椒盐锅巴:AwABCAEABAoAAA==.',['�']='毅格:AwAFCAYABAoAAA==.',['�']='法克劳斯特:AwACCAQABRQDBwAIAQjlBgBECuwBBAoABwAIAQjlBgA+sOwBBAoACAAHAQidDAA13MMBBAoAAA==.',['�']='深蓝彼岸:AwADCAcABRQCBQADAQigFAArDfAABRQABQADAQigFAArDfAABRQAAA==.',['�']='湘西猫王:AwAGCAsABAoAAA==.湮灭魔至尊:AwABCAEABRQAAA==.',['�']='灬光之子灬:AwAICA0ABAoAAA==.',['�']='爔澐:AwAICAgABAoAAA==.爱意随钟起:AwAHCAEABAoAAA==.爱的浪漫史:AwACCAIABRQAAA==.爱的罗猫史:AwADCAMABAoAAA==.',['�']='玖個灵:AwAGCAcABAoAAA==.玛里苟斯:AwAGCAYABRQCCQAGAQiBAgAdDHcBBRQACQAGAQiBAgAdDHcBBRQAAA==.',['�']='白白的女流氓:AwAECAIABAoAAA==.',['�']='神棍丨德:AwAECAEABAoAAA==.',['�']='秋晚枫:AwABCAEABRQAAA==.',['�']='第九特区:AwAGCAMABRQAAA==.',['�']='聖丶法天神霊:AwAGCAEABRQAAA==.',['�']='若叶睦:AwACCAIABRQAAA==.若无其事:AwABCAEABAoAAA==.',['�']='菠萝大神:AwABCAIABRQAAA==.',['�']='遗忘的圣骑:AwAICAgABAoAAA==.',['�']='释星魂:AwAICA0ABAoAAA==.',['�']='钩吻:AwAFCAUABRQDCgAFAQhwAwAoT7oABRQACgAEAQhwAwAybroABRQACwABAQi/FQAJ9FYABRQAAA==.',['�']='闷闷的兔仔:AwAHCAMABAoAAA==.',['�']='阿宝同学:AwACCAMABRQAAA==.阿岛:AwAECAQABAoAAA==.',['�']='風寒:AwAECAQABAoAAA==.',['�']='风行烈:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end