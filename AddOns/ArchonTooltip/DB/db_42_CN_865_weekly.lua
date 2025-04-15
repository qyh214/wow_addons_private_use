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
 local lookup = {'Paladin-Retribution','Paladin-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Hunter-BeastMastery','Monk-Mistweaver','Unknown-Unknown',}; local provider = {region='CN',realm='阿拉希',name='CN',type='weekly',zone=42,date='2025-04-15',data={He='Hellovenus:AwADCAQABAoAAA==.',Ho='Honeyhoney:AwACCAIABRQAAA==.',Lo='Longbeforz:AwAECAYABRQCAQAEAQj9GAA9FuoABRQAAQAEAQj9GAA9FuoABRQAAA==.',Ly='Lyqssr:AwAICAQABAoAAA==.',Pa='Pair:AwAECAMABRQAAA==.',Sd='Sdsadad:AwAFCAYABAoAAA==.',We='Wefrew:AwAHCAcABAoAAA==.',['�']='一壶奶茶:AwAECAQABRQAAA==.一撕就得:AwAGCAYABRQDAgAGAQj8BQAgz+EABRQAAgADAQj8BQAV1eEABRQAAQADAQgNKAAdhaQABRQAAA==.三千千:AwAICAgABAoAAA==.丶丽丽酱:AwAECAQABRQAAA==.丶欧煌:AwAICBAABAoAAA==.丿硝酸甘油丶:AwAICAkABAoAAA==.',['�']='乌合之众:AwAECAgABRQCAwAEAQjHFQAgKtgABRQAAwAEAQjHFQAgKtgABRQAAA==.',['�']='云无月:AwAICAgABAoAAA==.',['�']='仙帝:AwABCAEABAoAAA==.',['�']='你是星辰大海:AwACCAMABRQAAA==.',['�']='傷别灕灬逍遥:AwAICAcABAoAAA==.',['�']='八零扶墙输出:AwACCAMABRQAAA==.',['�']='凄凉的夢:AwAICAgABAoAAA==.',['�']='区区不才:AwAHCAUABAoAAA==.',['�']='可乐爆米花:AwAECAgABRQDBAAEAQgsBAA+wuQABRQABAAEAQgsBAA6ZeQABRQAAwAEAQgRFgAfTtcABRQAAA==.',['�']='命运终焉:AwAECAgABRQDBQAEAQiVEgAgDsQABRQABQAEAQiVEgAgDsQABRQABgADAQhnEgAKoHkABRQAAA==.',['�']='喜剧赢家:AwAECAQABRQAAQcAMUoICAgABRQ=.',['�']='圣光闪现:AwAGCA8ABAoAAA==.',['�']='夜绾绾:AwACCAIABRQAAA==.大哥灬别开炮:AwAICAcABAoAAA==.',['�']='女帝柳如烟:AwAICA8ABAoAAA==.',['�']='嬅木兰:AwADCAMABAoAAQgAXh8ECA4ABRQ=.',['�']='心情煩燥:AwACCAIABAoAAA==.',['�']='情深终化蝶:AwAICAEABAoAAA==.',['�']='收音机:AwAFCAkABAoAAA==.',['�']='救祓少女:AwAECAgABRQCAwAEAQjXCgBJswkBBRQAAwAEAQjXCgBJswkBBRQAAA==.',['�']='旅艾华侨:AwAGCAYABAoAAA==.',['�']='晨晨清颖:AwAECAIABAoAAA==.',['�']='朱元璋:AwACCAIABRQAAA==.',['�']='杨林欧:AwAICAEABAoAAA==.',['�']='梦魇幻魔:AwAICAwABAoAAA==.梵蒂冈天堂:AwAECAQABRQAAA==.',['�']='棋盘山老司机:AwAECAQABRQAAA==.',['�']='橋本:AwAICAMABAoAAA==.',['�']='注满老马:AwAGCAYABAoAAA==.',['�']='混子中的疯子:AwAHCAEABAoAAA==.',['�']='爱琴海中渔:AwAFCAgABAoAAA==.',['�']='独孤苍健:AwACCAMABRQCAQAIAQgUIwBQanwCBAoAAQAIAQgUIwBQanwCBAoAAA==.',['�']='玫猫饼丶:AwAICAYABAoAAA==.玲儿:AwAICAgABAoAAA==.',['�']='白狐妖姬:AwABCAEABRQAAA==.白色鸢尾:AwAECAQABRQCAwAIAQi0IwBTQhcCBAoAAwAIAQi0IwBTQhcCBAoAAQMAPtMGCAoABRQ=.',['�']='真丶不正常:AwAHCAEABAoAAA==.',['�']='章鱼小丸子:AwAICA4ABAoAAA==.',['�']='精术济世:AwACCAIABAoAAA==.',['�']='紫荆藤:AwAGCAUABAoAAA==.',['�']='红星二锅头:AwAFCAoABAoAAA==.',['�']='绝世关云长:AwADCAUABRQCAQADAQhYHAAhi+AABRQAAQADAQhYHAAhi+AABRQAAA==.',['�']='萌萌大咕咕:AwAECAQABRQAAA==.',['�']='蓝若林:AwAECAQABRQAAA==.',['�']='贾百万:AwABCAEABAoAAA==.',['�']='赛茜莉雅:AwAECAIABRQAAA==.',['�']='达瓦里氏:AwAECAoABRQCCQAEAQgrCwA/gPcABRQACQAEAQgrCwA/gPcABRQAAA==.',['�']='过期牛扒:AwAECAUABRQCCQAEAQg1DQAv/eoABRQACQAEAQg1DQAv/eoABRQAAA==.这是能猫人:AwAICAEABAoAAA==.远程象征:AwAECAQABRQCCAAEAQi7OAA8zFAABRQACAAEAQi7OAA8zFAABRQAAQgAQU0GCAUABRQ=.',['�']='那边那个小德:AwADCAIABAoAAA==.邪月苍炎:AwAECAQABAoAAA==.',['�']='醒时春山:AwACCAMABRQAAA==.',['�']='闹斯特麻麻:AwACCAIABRQAAA==.',['�']='雨落天晴:AwAFCAUABAoAAA==.雪之小样:AwABCAEABAoAAQoAAAAICAEABAo=.',['�']='青衫:AwABCAEABRQAAA==.',['�']='飞翔的熊猫人:AwABCAEABAoAAA==.',['�']='鬼舞天泉:AwAHCAYABAoAAA==.',['�']='鲨鱼一辣椒:AwAECAYABRQCBwAEAQjHEQAen84ABRQABwAEAQjHEQAen84ABRQAAA==.',['�']='麻药搜查官:AwAICAYABAoAAA==.',['�']='黑糖秀:AwAECAQABRQAAA==.',['�']='龘龘蛇:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end