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
 local lookup = {'Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Protection','Monk-Mistweaver','Monk-Brewmaster','Mage-Fire','Priest-Holy','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','Shaman-Restoration','Warlock-Affliction','Warrior-Fury','Hunter-Marksmanship','Mage-Frost','Paladin-Retribution',}; local provider = {region='CN',realm='布莱克摩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alydia:AwAHCAsABAoAAA==.',Ka='Kayanon:AwAFCAUABAoAAA==.',Ke='Kee:AwAECAYABRQDAQAEAQhgCwAxUeQABRQAAQAEAQhgCwAxUeQABRQAAgACAQiyFQAq7IUABRQAAQMAIV4GCAYABRQ=.',Me='Mercurys:AwAHCAcABAoAAA==.',Pl='Playerasdfgh:AwABCAEABAoAAA==.',Ro='Romeoe:AwAFCAUABAoAAA==.',Ze='Zern:AwAECAQABRQAAQQAAAAICAQABRQ=.',['�']='七枷社:AwAECAQABRQAAA==.三千越甲吞吴:AwAFCAgABAoAAA==.丨黯灬斩焱丶:AwAICBYABAoDBQAIAQh3FwBKw10CBAoABQAIAQh3FwBKw10CBAoABgABAQjqUgBCgU0ABAoAAA==.丶椛晓霜:AwAECAUABRQCBwAEAQjHAwAn17gABRQABwAEAQjHAwAn17gABRQAAA==.丶舞幽炫:AwAGCAoABRQDCAAGAQh8AgAVzHQBBRQACAAGAQh8AgAVzHQBBRQACQAEAQhsAgA4/s4ABRQAAA==.丶舞幽静:AwAICAgABAoAAA==.',['�']='云云:AwAECAQABRQAAA==.',['�']='优菈:AwABCAEABAoAAA==.',['�']='倒数从零开始:AwACCAIABAoAAA==.',['�']='傻满满:AwAGCAQABAoAAA==.',['�']='可乐加冰:AwABCAEABAoAAA==.',['�']='名字太短:AwAICAgABAoAAQoAMkEGCAgABRQ=.',['�']='咖啡嘤:AwAECBAABRQCCwAEAQjhAABemUkBBRQACwAEAQjhAABemUkBBRQAAA==.',['�']='哈都跟:AwAICAQABAoAAA==.哓丶枫叶:AwAICAgABAoAAA==.',['�']='喵大大人:AwADCAkABRQDCwADAQgPDwAu+ZIABRQACwACAQgPDwAwZ5IABRQAAgACAQj8FgAckX0ABRQAAA==.',['�']='地狱血契:AwAECAQABRQAAA==.',['�']='增幅器:AwADCAMABAoAAA==.',['�']='天命人:AwADCAoABRQCCQADAQhzBQAXvngABRQACQADAQhzBQAXvngABRQAAQgAIA0ICAMABRQ=.天涯客:AwAECAQABRQAAA==.天驱魔刀:AwAECAQABRQAAA==.',['�']='媞娜:AwAFCAQABAoAAA==.',['�']='小兔叽丶:AwADCAkABRQCCAADAQgZAwBiJVQBBRQACAADAQgZAwBiJVQBBRQAAA==.小娥:AwAGCA0ABAoAAA==.小小石头姐:AwAECAYABAoAAA==.小牛夜行:AwAICAIABAoAAA==.小船:AwABCAEABRQAAA==.小鬼夜游:AwAICB0ABAoCDAAIAQhUJQA77fgBBAoADAAIAQhUJQA77fgBBAoAAA==.小鬼夜行:AwAICCMABAoDDQAIAQhRCABOnTACBAoADQAIAQhRCABGvTACBAoADgAIAQizGgBD0g8CBAoAAA==.小鬼夜袭:AwAICBkABAoCBQAIAQheLAA0Yd4BBAoABQAIAQheLAA0Yd4BBAoAAA==.小鬼尾行:AwAGCA8ABAoAAA==.',['�']='幽客:AwACCAIABAoAAA==.',['�']='建材王哥:AwAFCAUABAoAAA==.',['�']='影光月蝕:AwAICA8ABAoAAA==.',['�']='憨豆豆:AwADCAcABRQCDwAIAQiwJAAsInwBBAoADwAIAQiwJAAsInwBBAoAAA==.',['�']='我要烧香:AwAICBQABAoCCAAIAQjtJQAt/KgBBAoACAAIAQjtJQAt/KgBBAoAARAAUC4CCAgABRQ=.',['�']='拉面阿宝:AwAICA4ABAoAAA==.',['�']='星丶痕:AwAECAQABRQAAA==.星丶陨:AwADCAQABRQAAQMAR6MICAoABRQ=.',['�']='暮丶汐:AwAECAQABRQAAA==.暮汐:AwAECAgABRQDDgAEAQjBBQBVkRUBBRQADgAEAQjBBQBTgxUBBRQAEQAEAQh+BQBBcfQABRQAAA==.',['�']='根浴圣手:AwAGCAEABRQAAA==.',['�']='欲為诸佛龍象:AwAGCAYABAoAAA==.',['�']='水元子:AwAECAIABRQAAA==.',['�']='求生之路:AwAICAwABAoAAA==.',['�']='浮殇年华:AwADCAMABAoAAA==.',['�']='灵之影:AwABCAEABAoAAA==.',['�']='爆炸克拉拉:AwAGCAkABAoAAA==.',['�']='皮圣:AwAGCAQABRQCEgAEAQiDDgAlY+sABRQAEgAEAQiDDgAlY+sABRQAAA==.',['�']='盖尔加朵:AwAICAoABAoAAA==.',['�']='粉马尾蝙蝠猫:AwAGCAcABAoAAA==.',['�']='素手芳華:AwADCAoABRQDEwADAQggEgAsm4YABRQAEwACAQggEgAhR4YABRQAAwACAQi5KgAvHoUABRQAAA==.',['�']='纳兰祺:AwAFCAUABAoAAA==.',['�']='绿玥儿:AwAICBsABAoCBQAIAQjGIgBBqxQCBAoABQAIAQjGIgBBqxQCBAoAAA==.',['�']='群殴小朋友:AwAGCAIABAoAAA==.',['�']='茉酱紫:AwAICAgABAoAAA==.',['�']='草药君别杀我:AwAGCAgABAoAAA==.',['�']='莎总:AwAGCAQABRQAAA==.',['�']='西风如笑:AwAICAMABAoAAA==.',['�']='诸神无念:AwAECAQABRQAAA==.',['�']='豪鬼:AwAGCAYABAoAAA==.豬豬點點:AwACCAIABRQAAQQAAAAICAQABRQ=.',['�']='赛利卡:AwADCAcABRQCFAADAQhLAABjH1wBBRQAFAADAQhLAABjH1wBBRQAAA==.',['�']='轩辕箭:AwACCAQABRQAAA==.',['�']='辣条小妹:AwAECAMABAoAAA==.',['�']='过敏世界:AwADCAMABRQAAQQAAAAGCAEABRQ=.',['�']='遮眼司机:AwADCAUABRQCBQADAQjsFgAQFsUABRQABQADAQjsFgAQFsUABRQAAA==.',['�']='采蘑菇的小熊:AwACCAIABRQAAA==.',['�']='钟丽婉:AwAICBUABAoCFQAIAQhcMwBOOjYCBAoAFQAIAQhcMwBOOjYCBAoAAA==.',['�']='阿诗蕶:AwAICA8ABAoAAA==.',['�']='魔鬼克星:AwAECAQABRQAAA==.',['�']='鳕鱼堡:AwAECAQABRQAAA==.',['�']='黎明的勇气:AwAICAgABAoAAA==.黑白玄月:AwAGCA8ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end