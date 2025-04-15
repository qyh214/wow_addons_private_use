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
 local lookup = {'Paladin-Retribution','Priest-Discipline','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Unknown-Unknown','Priest-Shadow','Priest-Holy','DemonHunter-Havoc',}; local provider = {region='CN',realm='奎尔萨拉斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Be='Beback:AwABCAEABRQAAA==.',Bi='Bitoy:AwACCAIABAoAAA==.',Ru='Runtoyou:AwAICAkABAoAAA==.',['�']='不喝牛奶:AwABCAEABAoAAA==.不爱吃香菜:AwAFCAcABAoAAA==.丷小领主丷:AwAICA8ABAoAAA==.',['�']='今天喝绿茶:AwAFCAYABAoAAA==.',['�']='六十五退休:AwACCAIABRQAAA==.',['�']='切口:AwACCAIABAoAAA==.到处乱插:AwABCAIABRQAAA==.刺盾:AwAECAgABRQCAQAEAQiKFgAtM+oABRQAAQAEAQiKFgAtM+oABRQAAA==.',['�']='只是牧牧:AwAGCAYABRQCAgAGAQh+AgAL00kBBRQAAgAGAQh+AgAL00kBBRQAAA==.',['�']='哇酷哇酷:AwACCAEABRQEAwAIAQi2CABHKSkCBAoAAwAIAQi2CAA/8ikCBAoABAAIAQg2IwA8mdwBBAoABQACAQjuJwBBQ5cABAoAAA==.',['�']='啸男蝴:AwACCAIABAoAAA==.',['�']='圣光大黑手:AwAECAQABAoAAA==.圣罗德里格斯:AwAECAYABRQCAQAEAQjvGQAqyd4ABRQAAQAEAQjvGQAqyd4ABRQAAQYAAAAICAQABRQ=.',['�']='夏天的风雪:AwABCAEABAoAAA==.夜牧降临:AwAECAgABRQDBwAEAQgODwBI5sYABRQABwADAQgODwBW0sYABRQACAADAQgAEAAzQ4sABRQAAQIAFksGCAoABRQ=.大家长:AwACCAIABRQCBAAIAQjgMwAnboYBBAoABAAIAQjgMwAnboYBBAoAAA==.大寂灭神:AwACCAEABRQAAA==.',['�']='妮露:AwAICAgABAoAAA==.',['�']='娜缇灬洸茗:AwAICAgABAoAAA==.',['�']='寂寞灬恶魔:AwABCAIABRQAAA==.',['�']='小橘皮皮丶:AwAICAgABAoAAA==.小熊饼干:AwAICA8ABAoAAA==.',['�']='张大爷:AwAGCAsABAoAAA==.',['�']='思南:AwAECAQABAoAAA==.',['�']='想明白了:AwAFCAYABAoAAA==.',['�']='明智灬左马介:AwAICAgABAoAAA==.',['�']='最爱吃炸鸡:AwAICAMABAoAAA==.机器丶猫:AwAGCAQABRQAAA==.',['�']='泪桥:AwAICAgABAoAAA==.',['�']='灬硳瞳灬:AwAECAQABRQAAQEAS6QGCAoABRQ=.',['�']='烟花不堪剪:AwABCAEABAoAAA==.烧鹅菜菜:AwACCAIABRQAAA==.',['�']='爆椒牛肉面:AwABCAEABRQAAA==.',['�']='狡诈的猎狐者:AwAECAEABRQAAA==.',['�']='祖国的绿萝:AwAECAQABAoAAA==.神圣女王:AwAECAQABAoAAA==.',['�']='繁华遗失:AwAECAgABRQDBAAEAQiYCwBCI+QABRQABAADAQiYCwA1eeQABRQABQACAQgREgBbD2sABRQAAA==.',['�']='胖叔叔的武僧:AwAGCAQABRQAAA==.',['�']='艾司唑侖:AwAICBAABAoAAA==.',['�']='言其不语:AwAICAoABAoAAA==.',['�']='辛德维拉:AwACCAcABRQCCQACAQgZHQAvjJUABRQACQACAQgZHQAvjJUABRQAAA==.达芬奇大领主:AwAICA4ABAoAAA==.',['�']='远赴人间:AwACCAMABRQAAA==.',['�']='靈魂丶擺渡者:AwAICAwABAoAAA==.',['�']='顺心如意:AwADCAMABAoAAA==.',['�']='风铃回忆:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end