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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Monk-Mistweaver','Paladin-Retribution','Unknown-Unknown','Hunter-BeastMastery','DemonHunter-Vengeance','DemonHunter-Havoc',}; local provider = {region='CN',realm='库尔提拉斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Sm='Smilee:AwABCAEABRQAAA==.',Sz='Sznbrr:AwACCAIABRQAAA==.',Vu='Vurtne:AwAECAQABAoAAA==.',['�']='一首凉凉:AwAICAgABAoAAA==.丶柒染:AwABCAEABAoAAA==.举个手:AwAECAUABAoAAA==.',['�']='仙劍堂凝:AwAICBUABAoDAQAIAQgyOgAtd5UBBAoAAQAIAQgyOgAtd5UBBAoAAgAEAQgyTgAJzVYABAoAAA==.',['�']='伊利达雷领主:AwABCAEABAoAAA==.伊泽瑞尔:AwAFCAUABAoAAA==.',['�']='光博士:AwACCAIABRQAAA==.八极小狂风:AwAGCAoABAoAAA==.',['�']='冷冰剑雨:AwADCAMABAoAAA==.',['�']='十二個耳釘:AwAHCAgABAoAAA==.',['�']='吻之恶魔:AwABCAEABAoAAA==.',['�']='哎呦哎呦:AwABCAEABRQCAwAIAQh4LwAoa3EBBAoAAwAIAQh4LwAoa3EBBAoAAA==.',['�']='嘻哈哈:AwAECAYABAoAAA==.',['�']='坏坏:AwAICAkABAoAAA==.',['�']='墨云吹城:AwAICBQABAoCBAAIAQi9VQA9QNABBAoABAAIAQi9VQA9QNABBAoAAA==.',['�']='天启丶:AwABCAIABRQCBAAIAQhnEQBZoMECBAoABAAIAQhnEQBZoMECBAoAAA==.天堂梦影:AwAECAQABRQAAA==.',['�']='嫂子我是我哥:AwAECAQABRQAAA==.',['�']='尤克奇:AwAECAQABRQAAA==.',['�']='德得德得:AwAFCAUABAoAAA==.',['�']='意别一:AwAECAQABRQAAA==.',['�']='打劫世界:AwADCAMABAoAAA==.',['�']='欢欢不打烊丶:AwADCAMABAoAAQUAAAAICAQABRQ=.欧尼西斯:AwACCAIABAoAAQUAAAAECAQABRQ=.',['�']='沐丶清:AwAECAQABRQAAA==.沐灬清:AwACCAQABAoAAA==.',['�']='海浪:AwABCAEABAoAAA==.',['�']='清新的汪汪儿:AwAICAoABAoAAA==.游侠:AwABCAEABRQAAA==.',['�']='溪水:AwABCAEABAoAAA==.',['�']='灰烬游侠:AwAECAQABRQAAQUAAAAICAQABRQ=.',['�']='燃烟:AwACCAUABRQCBgACAQhRJQAvj5QABRQABgACAQhRJQAvj5QABRQAAA==.',['�']='猫鲨:AwAHCAIABAoAAA==.',['�']='白银纯:AwAFCAUABAoAAA==.',['�']='眬夜:AwAECAQABAoAAA==.',['�']='石头洪洪:AwABCAEABAoAAA==.',['�']='神圣小混混:AwAFCAgABAoAAA==.',['�']='糖沫沫:AwAICAkABAoAAA==.',['�']='纯黑的天空:AwAHCAoABAoAAA==.',['�']='给你个奈奈:AwABCAEABRQAAA==.绿毛野猪精:AwABCAEABRQAAA==.',['�']='联盟歼击机:AwAECAQABAoAAA==.',['�']='肚子挡住坤儿:AwAGCAYABAoAAQUAAAAICAQABRQ=.',['�']='苗子姐:AwACCAIABRQAAA==.',['�']='菊花神:AwACCAIABRQAAA==.',['�']='计都:AwAECAQABAoAAA==.许坚许坚:AwAICAsABAoAAA==.',['�']='迈克尔一奶霸:AwAFCAcABAoAAA==.',['�']='重铸:AwADCAMABAoAAA==.',['�']='钉宫萌萌哒:AwAICBgABAoDBwAIAQiDOQAZSqwABAoABwAHAQiDOQALlawABAoACAACAQjngQA6nI8ABAoAAA==.',['�']='铁柱发发法:AwADCAYABAoAAQUAAAAICAcABAo=.铁柱飞飞骑:AwAICAcABAoAAA==.',['�']='长生:AwAECAQABAoAAA==.',['�']='闪电一号:AwAECAQABAoAAA==.闭家锁:AwAICAgABAoAAA==.',['�']='霜袶丶:AwABCAEABRQAAA==.',['�']='风暴使者:AwAGCAwABAoAAA==.飘逸犄角:AwAFCAYABAoAAA==.飛華雪:AwACCAIABAoAAA==.',['�']='魏日悬:AwAGCAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end