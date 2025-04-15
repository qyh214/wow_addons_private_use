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
 local lookup = {'Warlock-Destruction','Druid-Restoration','Druid-Balance','Monk-Mistweaver','Unknown-Unknown','DeathKnight-Blood','DemonHunter-Havoc','Shaman-Elemental','Shaman-Restoration','Priest-Holy','Paladin-Protection','Priest-Discipline','Shaman-Enhancement','Mage-Fire','Paladin-Retribution','Monk-Windwalker','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Arms','Warrior-Fury',}; local provider = {region='CN',realm='萨格拉斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Animalstt:AwAECAIABAoAAA==.',['�']='丹玄子:AwACCAIABRQAAA==.',['�']='伏都:AwAECAQABRQAAQEAT7oGCA4ABRQ=.',['�']='你二姨:AwAICAgABAoAAA==.你的蕾丝:AwAICAgABAoAAA==.',['�']='克勞德:AwAFCBAABRQDAgAFAQg/AwAs4C8BBRQAAgAFAQg/AwAs4C8BBRQAAwAEAQhDEwA5WuAABRQAAA==.六七朵茉莉:AwAECAgABRQCBAAEAQhEDQA1EuoABRQABAAEAQhEDQA1EuoABRQAAA==.',['�']='凯东:AwAICAgABAoAAA==.凯恩丶猎蹄:AwAICAgABAoAAA==.',['�']='刀锋之影:AwAGCAQABAoAAA==.',['�']='匹夫:AwAECAQABRQAAQUAAAAGCAQABRQ=.',['�']='博麗霊夢:AwAICAgABRQCBgAIAQhqAAAoZuMBBRQABgAIAQhqAAAoZuMBBRQAAA==.卡玛扎尔:AwABCAEABAoAAA==.',['�']='变成土豆:AwAECAYABRQCBwAEAQjADwA3WvAABRQABwAEAQjADwA3WvAABRQAAQUAAAAGCAQABRQ=.',['�']='咔皮巴啦:AwAECAwABRQDCAAEAQh4BwAzuuYABRQACAAEAQh4BwAzuuYABRQACQAEAQgnEQAZjdQABRQAAA==.咬乳师琻度:AwAHCAcABAoAAA==.咸鱼不想翻身:AwAECAIABRQAAQoAPuAGCAcABRQ=.',['�']='垂直面:AwAICAsABAoAAA==.',['�']='堕落抉择:AwAGCAYABAoAAQUAAAAHCAQABRQ=.',['�']='夜空下的牛:AwAECAQABRQAAA==.大辫子:AwAECAQABRQAAA==.天上天下无双:AwAFCAEABAoAAA==.天天流浪汉:AwAECAQABRQAAA==.天降圣人:AwACCAIABRQAAA==.',['�']='套龙的汉子:AwAECAQABRQAAA==.',['�']='如风随影:AwAECAEABAoAAA==.',['�']='孤独扛娃娃:AwAICAgABAoAAA==.',['�']='小抄手:AwAECAQABRQAAA==.小波:AwAGCAoABRQCCwAGAQhdAgAmSEkBBRQACwAGAQhdAgAmSEkBBRQAAA==.小魄罗:AwAHCAIABAoAAA==.',['�']='布劳缪克丝:AwADCAMABRQAAA==.',['�']='恐惧降临灬灬:AwAICAEABAoAAA==.',['�']='我上了加好我:AwAECAQABRQAAA==.',['�']='扬州炒饭丶:AwAHCAcABAoAAA==.',['�']='方小猫猫:AwAECBAABRQCBAAEAQg+BgBSRCUBBRQABAAEAQg+BgBSRCUBBRQAAA==.',['�']='是也非耶:AwAECAgABRQCDAAEAQjWBQBPcRgBBRQADAAEAQjWBQBPcRgBBRQAAA==.',['�']='時廿以後:AwABCAIABRQAAA==.景之:AwACCAIABRQAAA==.',['�']='暴怒丨霜凌:AwABCAEABRQAAA==.',['�']='最后一只:AwABCAEABAoAAA==.朔阳:AwAECAQABRQAAA==.',['�']='桃丶:AwACCAUABRQDDQACAQj1DwAZyo8ABRQADQACAQj1DwAZyo8ABRQACQACAQj6IAAQi30ABRQAAA==.',['�']='森淼赑:AwAICBEABAoAAA==.',['�']='橙色葡萄酱:AwAICA4ABAoAAQ4AJ70GCAoABRQ=.',['�']='法尔肯:AwAECAQABRQAAA==.',['�']='消逝亾:AwADCAMABRQAAA==.',['�']='灵圣:AwAECAQABRQAAA==.',['�']='無心:AwAGCAEABRQCAQAIAQgBCwBZIYkCBAoAAQAIAQgBCwBZIYkCBAoAAQEAPKQHCAYABRQ=.',['�']='白斯月:AwAECAIABRQAAA==.',['�']='羅羅亞索隆:AwAGCAIABAoAAA==.',['�']='老衲说:AwAFCAEABAoAAA==.',['�']='芙拉荻蕾娜:AwAECAQABRQAAA==.',['�']='苍之流星:AwAFCAIABRQAAQQAQnAHCAwABRQ=.',['�']='莉亞徳淋:AwAECAwABRQCDwAEAQjtBABb30ABBRQADwAEAQjtBABb30ABBRQAAA==.莱维:AwAECAQABRQAAA==.',['�']='蓬莱山輝夜:AwAECAQABRQCAQAIAQiTCQBY5ZgCBAoAAQAIAQiTCQBY5ZgCBAoAAA==.',['�']='藤原萱:AwACCAIABRQAAA==.',['�']='蛋蛋特别强:AwAECAQABRQAAA==.',['�']='西园幽火:AwAECAYABRQCAgAEAQgvCQAsuc4ABRQAAgAEAQgvCQAsuc4ABRQAAQUAAAAGCAIABRQ=.西园曲水:AwAECAIABRQAAA==.',['�']='诺亚之子:AwACCAEABAoAAA==.',['�']='那咋整啊:AwAECAYABRQCBgAEAQhzBQBUPhwBBRQABgAEAQhzBQBUPhwBBRQAAA==.邬晓玫:AwAECAMABRQAAA==.',['�']='钝角:AwAECAYABRQCEAAEAQgpCQAyaekABRQAEAAEAQgpCQAyaekABRQAAA==.',['�']='销魂柔式:AwAECAQABRQAAA==.',['�']='阿尔忒鉨斯:AwAICAgABAoAAA==.',['�']='降临丶:AwACCAIABRQAAA==.',['�']='雅克西灬锈风:AwAECAYABRQDEQAEAQhCCwAtt9kABRQAEQAEAQhCCwAtt9kABRQAEgACAQgxMAAiPIAABRQAAA==.雷霆之心:AwAICAgABAoAAA==.',['�']='青青子吟:AwAICAgABAoAAA==.',['�']='魅之味:AwAHCAQABRQAAA==.',['�']='鸽以勇治:AwAECA0ABRQDEwAEAQgDCABLQ8AABRQAEwACAQgDCABOXcAABRQAFAADAQipFgA3LqkABRQAAA==.',['�']='黑店小二:AwAECAQABRQAAA==.',['�']='龙圣:AwACCAQABRQAAA==.龙小葵:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end