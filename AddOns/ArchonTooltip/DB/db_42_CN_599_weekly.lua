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
 local lookup = {'Mage-Fire','Evoker-Devastation','DemonHunter-Havoc','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Unknown-Unknown','Warrior-Fury','Warlock-Destruction','Priest-Holy','Priest-Shadow','Shaman-Elemental','DemonHunter-Vengeance','Druid-Balance','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='卡扎克',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Allenmage:AwAGCAoABRQCAQAGAQhmAgA557oBBRQAAQAGAQhmAgA557oBBRQAAA==.',Az='Azdaja:AwABCAIABRQCAgAIAQiuFAA5wvEBBAoAAgAIAQiuFAA5wvEBBAoAAA==.',Bo='Bountye:AwAICAgABAoAAA==.',El='Elsulw:AwAICA0ABAoAAA==.',Ex='Expecto:AwAFCAUABAoAAA==.',Fr='Friedlljh:AwABCAIABRQCAwAIAQjVFwBL8lsCBAoAAwAIAQjVFwBL8lsCBAoAAA==.',Gu='Guldamn:AwAECAQABRQAAA==.',Ni='Nightservant:AwABCAIABRQDBAAIAQi1EABdh4ACBAoABAAHAQi1EABdPYACBAoABQAGAQhzEgBame0BBAoAAQIAOcIBCAIABRQ=.',Ov='Oversize:AwAFCAgABAoAAA==.',Sa='Samelex:AwABCAEABRQCBgAHAQjYDQA/zaYBBAoABgAHAQjYDQA/zaYBBAoAAA==.',St='Stourin:AwAFCAwABAoAAA==.',['�']='一一点红:AwABCAIABRQEBwAIAQg8UAA9AN4BBAoABwAHAQg8UABFON4BBAoACAAIAQiTFgAsh4sBBAoACQAGAQiwLQAMnLkABAoAAA==.一叶风吹:AwABCAEABRQAAA==.专打小怪兽灬:AwAECAQABAoAAA==.丨小喬丨:AwAHCA0ABAoAAA==.丨德拉卡丨:AwACCAIABRQAAQoAAAAECAQABRQ=.丨疯癫丨:AwADCAoABRQCCwADAQjwDwAh39wABRQACwADAQjwDwAh39wABRQAAA==.',['�']='九啸:AwAFCAYABAoAAA==.',['�']='伍柒零叁:AwAICBEABAoAAA==.众生绝离:AwAHCAYABAoAAA==.伴生桥亭:AwAICAgABAoAAA==.',['�']='储墨:AwAGCAUABRQCDAAEAQgjBwBK5gYBBRQADAAEAQgjBwBK5gYBBRQAAQwATegICAYABRQ=.',['�']='六只婧婧:AwAECAQABRQAAA==.',['�']='凉皮:AwAECAQABRQAAA==.',['�']='剪辑再临:AwAGCAYABRQCDAAGAQjjAAAtr7kBBRQADAAGAQjjAAAtr7kBBRQAAA==.',['�']='卜存哉:AwAICAgABAoAAA==.',['�']='只影天涯:AwAFCAUABAoAAA==.',['�']='周星星:AwAECAQABRQAAA==.',['�']='哪像坭:AwAICAgABAoAAA==.哪像妳:AwADCAMABAoAAA==.哪像妳灬:AwADCAMABAoAAA==.',['�']='回首多次:AwAECAQABAoAAA==.',['�']='大雨吗:AwADCAQABAoAAA==.',['�']='她说是晒黑的:AwAFCAUABAoAAA==.',['�']='宁仙儿:AwACCAIABRQDDQAHAQjCHABJ5MoBBAoADQAHAQjCHABJ5MoBBAoADgABAQiQcwABaQUABAoAAA==.宋噗噗:AwACCAIABAoAAA==.宋扑扑:AwAECAQABAoAAA==.宏先生:AwAICBAABAoAAA==.',['�']='寒江夜:AwABCAIABAoAAA==.',['�']='小月饼:AwABCAEABAoAAA==.',['�']='山中老牛:AwABCAIABRQCDwAIAQiCFQBAZRcCBAoADwAIAQiCFQBAZRcCBAoAAA==.',['�']='希里:AwAECAQABRQAAA==.',['�']='感伤围城:AwABCAIABRQDEAAIAQgcEQA9GucBBAoAEAAIAQgcEQA9GucBBAoAAwAEAQjClQAL6WEABAoAAA==.愤怒的马哥:AwAGCAQABRQAAA==.',['�']='掺水的孟婆汤:AwAICCMABAoCEQAIAQh8EABSn48CBAoAEQAIAQh8EABSn48CBAoAAA==.',['�']='斗志昂扬:AwAGCAMABAoAAA==.',['�']='星球杯:AwAECAYABAoAAA==.星辰月影:AwABCAIABRQCEgAIAQitCwBN5FoCBAoAEgAIAQitCwBN5FoCBAoAAA==.',['�']='曲歌:AwAFCAUABRQCDgAFAQguAgBRV5EBBRQADgAFAQguAgBRV5EBBRQAAA==.曼彻斯特传奇:AwABCAIABRQCCwAIAQjpAQBgLgcDBAoACwAIAQjpAQBgLgcDBAoAAA==.曼神射手:AwABCAIABRQCEgAIAQhaCgBOPmwCBAoAEgAIAQhaCgBOPmwCBAoAAA==.',['�']='未来打手九号:AwAHCBAABAoAAA==.',['�']='枫之语:AwABCAEABRQDEwAHAQjDRwBKtrIBBAoAEwAHAQjDRwBGn7IBBAoAEgAGAQjfJABAYncBBAoAAA==.',['�']='梆击大地:AwAECAQABRQAAA==.梦离:AwAHCAEABAoAAA==.',['�']='殺戮:AwAICAwABAoAAREAWBgCCAcABRQ=.',['�']='毛缪缪:AwAICAgABAoAAQoAAAAECAQABRQ=.',['�']='没有常识的人:AwACCAIABAoAAA==.',['�']='温酒煎雪:AwACCAIABAoAAA==.',['�']='牛鬼也疯狂:AwAECAQABRQAAA==.',['�']='玄奘:AwACCAIABRQAAA==.',['�']='珝玥婲:AwABCAEABRQAAA==.',['�']='神之爱:AwAICAgABAoAAA==.',['�']='给斋饭也要打:AwABCAIABRQDFAAIAQiWEgBHtDECBAoAFAAIAQiWEgBHtDECBAoAFQAHAQjzJQA7pagBBAoAAA==.绝岭:AwADCAMABAoAAA==.继光香香咕:AwABCAEABRQAAA==.',['�']='美的没得比:AwADCAMABAoAAA==.',['�']='肥妞我:AwABCAEABAoAAA==.',['�']='菟纸丨酱:AwAICAYABAoAAA==.',['�']='虚空灬圣:AwAICAgABAoAAA==.',['�']='蛮荒九哮:AwAHCAkABAoAAA==.蛮荒九啸:AwACCAQABRQAAQEAORoICAYABRQ=.',['�']='逐日之沙:AwABCAEABAoAAA==.',['�']='销魂震荡波:AwABCAEABRQAAA==.',['�']='陷阵营:AwACCAIABAoAAA==.',['�']='青衫依旧:AwACCAIABAoAAA==.',['�']='鮪魚:AwAGCA8ABAoAAA==.',['�']='鱼儿爸爸:AwAICAsABAoAAQQAQ3QGCA0ABRQ=.',['�']='鹌鹑蛋蛋:AwAICAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end