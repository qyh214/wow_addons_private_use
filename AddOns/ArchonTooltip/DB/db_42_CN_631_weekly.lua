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
 local lookup = {'Paladin-Retribution','Warlock-Affliction','Warlock-Destruction','Druid-Restoration','Mage-Frost','Mage-Fire','DeathKnight-Unholy','Warrior-Arms','Warrior-Fury','Druid-Balance','Unknown-Unknown','Monk-Mistweaver','Monk-Windwalker','Hunter-BeastMastery','Rogue-Outlaw','Rogue-Subtlety',}; local provider = {region='CN',realm='大地之怒',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Aimo:AwAHCAIABAoAAA==.',Ar='Argon:AwAICAgABAoAAA==.',Ci='Cill:AwAGCAYABAoAAA==.',Do='Doublechen:AwABCAEABRQCAQAIAQjHSgBIRu0BBAoAAQAIAQjHSgBIRu0BBAoAAA==.Doublem:AwAGCAkABAoAAA==.',Re='Reisenbeer:AwAECAwABRQDAgAEAQhnCAA1P9UABRQAAgAEAQhnCAA1DdUABRQAAwABAQhQKQAC3jkABRQAAA==.Reislin:AwAICAgABAoAAQQAKncGCAoABRQ=.',Sh='Shatan:AwAECAQABRQAAA==.',Si='Simondemon:AwAFCAcABAoAAA==.Simondragon:AwAFCAUABAoAAA==.Simonpally:AwACCAIABAoAAA==.',Sl='Slaughtermen:AwACCAQABRQAAA==.',Th='Thebs:AwACCAIABRQAAA==.',Va='Vavan:AwAICAgABAoAAA==.',Zo='Zolpidem:AwAFCAoABAoAAA==.',['�']='一只小团子丶:AwABCAEABAoAAA==.不羁的风:AwAICBYABAoDBQAIAQiXTAAU+gIBBAoABQAIAQiXTAAU+gIBBAoABgABAQjBngACRAwABAoAAA==.且弑天下:AwACCAEABAoAAA==.',['�']='九月青年:AwACCAIABRQAAA==.乱世之主:AwAGCAYABAoAAA==.',['�']='从小就缺奶:AwADCAMABAoAAA==.',['�']='克鲁索尔刃拳:AwAECAgABRQCBwAEAQgzCgA3AvYABRQABwAEAQgzCgA3AvYABRQAAA==.',['�']='冄冄乌:AwAECAgABRQDBQAEAQg/AgBMFiABBRQABQAEAQg/AgBMFiABBRQABgACAQhdKQAZHn0ABRQAAA==.',['�']='凌夜:AwACCAIABRQAAA==.',['�']='动感蜗牛:AwAFCAUABAoAAA==.',['�']='包夜不销魂:AwAICAMABAoAAA==.',['�']='卡灬卡:AwAICAgABAoAAA==.',['�']='唱歌女侠:AwADCAMABRQAAA==.',['�']='嘿丶妖気丶:AwACCAIABAoAAA==.',['�']='嚒嚒牛:AwAECAQABRQAAA==.',['�']='圣光的动力煤:AwAGCAEABAoAAA==.',['�']='塞萨里安:AwAFCAUABAoAAA==.',['�']='夏雨下鱼:AwAECAQABRQAAA==.大吧唧:AwACCAUABRQDCAACAQjSDAAWd4kABRQACAACAQjSDAAWd4kABRQACQACAQhPGgAUXogABRQAAA==.大白兔切萝卜:AwAHCAcABAoAAA==.大白兔吃萝卜:AwACCAIABRQAAA==.大霸机:AwAECAUABAoAAA==.天刀丶:AwAICAMABAoAAA==.天赐良鸡:AwAFCAUABAoAAA==.',['�']='姥姥的豆瓣酱:AwAICBIABAoAAA==.',['�']='安若丶浮生:AwACCAQABRQAAA==.',['�']='小苏苏:AwAICAQABAoAAA==.小霸王:AwACCAIABRQCCQAIAQgIJQA6It8BBAoACQAIAQgIJQA6It8BBAoAAA==.尛脸賍兮兮:AwABCAEABRQAAA==.',['�']='布莱克恺特:AwAECAQABRQAAA==.',['�']='影丢丢:AwAICAkABAoAAA==.',['�']='心袁灬懿马:AwAGCAIABRQAAA==.',['�']='我是真滴菜:AwAHCBMABAoAAA==.战神啤酒:AwAFCAcABAoAAA==.',['�']='托柒唔识转驳:AwABCAEABRQAAA==.',['�']='敬请期待:AwAICAgABAoAAA==.',['�']='无情审判丶:AwABCAEABRQAAA==.',['�']='暖月:AwAECAgABAoAAA==.暗夜之贪狼:AwAFCA8ABAoAAA==.',['�']='曦曦儿:AwAICAgABAoAAA==.',['�']='月亮方便面:AwAGCAYABAoAAA==.月光傳說:AwAICBAABAoAAA==.月落风萦:AwABCAEABRQDCQAIAQgoFQBEcUkCBAoACQAIAQgoFQBEcUkCBAoACAABAQiqWgAtTDQABAoAAA==.',['�']='果酱熊:AwAECAQABRQAAA==.',['�']='柠檬味口香糖:AwADCAMABAoAAA==.',['�']='棒棒冰:AwAECAQABRQAAA==.',['�']='洪流:AwAFCAUABAoAAA==.洲泳糠丶正邪:AwABCAEABAoAAA==.',['�']='流星神殿:AwAECAgABRQCAQAEAQgNCABW9iEBBRQAAQAEAQgNCABW9iEBBRQAAA==.浮华立夏:AwAHCAMABAoAAA==.',['�']='深海海绵怪:AwACCAIABRQAAA==.',['�']='火丨球:AwACCAIABAoAAA==.灬梦迷离灬:AwAECAMABRQAAA==.',['�']='爆米花不甜丶:AwAICBAABAoAAA==.',['�']='牛牛超硬:AwAICBIABAoAAA==.',['�']='疯狂嘘曲:AwAECAwABAoAAA==.疯狂小书生:AwAGCAQABAoAAA==.',['�']='睿睿肌肉大:AwAICAgABAoAAA==.',['�']='砍一刀:AwACCAIABRQAAA==.',['�']='祝青海:AwAECAQABRQAAA==.',['�']='离晒大谱:AwABCAEABRQAAA==.',['�']='秀气翩翩:AwAECAQABRQAAA==.',['�']='第二丶夜温柔:AwAGCAYABAoAAA==.',['�']='筱筱花椒呢:AwAICAoABAoAAA==.',['�']='米迦勒:AwABCAEABAoAAA==.',['�']='缘来梦醒:AwAGCAQABRQDBAAEAQjGCQAsiL0ABRQABAACAQjGCQA6Wr0ABRQACgACAQiVHwA0qIIABRQAAQQAPyYICAsABRQ=.',['�']='胖之煞丶:AwAGCAYABAoAAA==.',['�']='菠萝丶汽水:AwAGCAYABAoAAQsAAAAICAQABRQ=.',['�']='萌虎掌:AwAFCAYABRQDDAAFAQjnAwAnnj4BBRQADAAFAQjnAwAnnj4BBRQADQABAQgOGwANgzgABRQAAA==.萨鲁加尔雷霆:AwAECAIABRQAAA==.',['�']='虎啸山林:AwADCAMABAoAAA==.',['�']='行旅离落:AwAECAIABAoAAQ0AKkoICAYABRQ=.',['�']='西北砍王:AwAFCAYABAoAAA==.',['�']='轻雨:AwADCAgABRQCBwADAQigBgBEQw8BBRQABwADAQigBgBEQw8BBRQAAA==.',['�']='迷你呲花:AwAECAQABRQAAQ4AKokICAIABRQ=.',['�']='那什么什么了:AwADCAQABRQAAA==.',['�']='銀色的永生:AwABCAIABRQDDwAIAQjqAwBGTjICBAoADwAIAQjqAwBD/DICBAoAEAAHAQiGFAA5O6YBBAoAAA==.',['�']='阴暗的炼焦煤:AwAGCAYABAoAAA==.阿特兰斯猎风:AwAGCAYABAoAAA==.',['�']='雷欧大侠:AwAECAQABRQAAA==.',['�']='馒头猫:AwAGCAcABRQCDAAEAQjICgA4mPAABRQADAAEAQjICgA4mPAABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end