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
 local lookup = {'Shaman-Enhancement','Shaman-Restoration','Paladin-Protection','Paladin-Retribution','Hunter-BeastMastery','Monk-Brewmaster','Monk-Mistweaver','Evoker-Devastation','Evoker-Preservation','Unknown-Unknown','Druid-Balance','Druid-Restoration','Priest-Shadow',}; local provider = {region='CN',realm='达隆米尔',name='CN',type='weekly',zone=42,date='2025-04-15',data={Aj='Aj:AwAGCAEABAoAAA==.',Cp='Cpdd:AwABCAEABAoAAA==.',Er='Ergergsdf:AwAGCAYABAoAAA==.',Ha='Han:AwAECAQABAoAAA==.',Ki='Kimtang:AwAGCAcABAoAAA==.',Pi='Pino:AwAECAcABAoAAA==.',Pr='Prussia:AwAGCAYABAoAAA==.',Vi='Vic:AwAGCA8ABRQDAQAGAQj9AAA8LcQBBRQAAQAGAQj9AAA8LcQBBRQAAgAEAQjxEAAg/tUABRQAAA==.',['�']='世界萨彡:AwAECAUABAoAAA==.丨沛艾丨:AwAHCAEABAoAAA==.中煎人:AwABCAEABAoAAA==.丶沙奈朵:AwAECAQABRQAAA==.',['�']='二十四孝:AwAGCAYABAoAAA==.',['�']='估算师:AwACCAIABRQAAA==.',['�']='低语:AwACCAMABAoAAA==.你们冲我掩护:AwAGCAwABAoAAA==.',['�']='倒霉蛋儿:AwAECAQABRQAAQMASiMGCAYABRQ=.',['�']='元述:AwAICA8ABAoAAA==.兎笓:AwAHCAsABAoAAA==.',['�']='冰糖雪梨丶:AwAECAYABAoAAA==.冰霜大领主:AwAGCAYABAoAAA==.决明:AwAICAkABAoAAA==.',['�']='出逃玫瑰:AwAICAgABAoAAA==.',['�']='刘瑾优:AwAHCAEABAoAAA==.',['�']='南瓜豆豆:AwAHCA4ABAoAAA==.',['�']='叛逆魯魯:AwAECAQABRQCBAAEAQitBABbPkIBBRQABAAEAQitBABbPkIBBRQAAA==.',['�']='咖啡苦酒:AwAECAQABAoAAA==.',['�']='噬心隐为者:AwAECAYABRQCBQAEAQgDGAAxpOMABRQABQAEAQgDGAAxpOMABRQAAA==.',['�']='太平洋的眼泪:AwADCAIABRQAAA==.失落的人:AwADCAMABAoAAA==.',['�']='奥帝努斯:AwAGCAEABAoAAA==.',['�']='妖祸喰:AwAICAYABAoAAA==.',['�']='娶灬紅太狼:AwAGCAsABAoAAA==.',['�']='学长不凶:AwACCAQABRQCBgAIAQgKEQAYEAsBBAoABgAIAQgKEQAYEAsBBAoAAA==.',['�']='小吉湾:AwAGCAYABAoAAA==.',['�']='德德哋:AwAECAQABAoAAA==.',['�']='心宽体更胖:AwADCAIABRQDBgAIAQihBgBBPv8BBAoABgAIAQihBgBBPv8BBAoABwACAQiPawAhtX4ABAoAAA==.',['�']='悠闲:AwAECAQABRQAAA==.悲殤述裞微笑:AwAECAQABAoAAA==.',['�']='我妚哠訴你:AwADCAYABAoAAA==.',['�']='新兵蛋子:AwAECAQABAoAAA==.',['�']='无所谓去:AwACCAIABRQAAA==.',['�']='晓寒轻:AwAECAQABRQAAA==.景中水月:AwAICAkABAoAAA==.',['�']='李葵:AwACCAMABAoAAA==.',['�']='林夕龙二:AwAICA4ABAoAAA==.枫天璇:AwABCAEABAoAAA==.',['�']='森林中的美女:AwACCAIABRQAAA==.棱丶镜:AwADCAMABAoAAA==.',['�']='正方形铁板:AwAECAcABAoAAA==.',['�']='漆黑之王:AwACCAIABRQAAA==.',['�']='灬圣光灬:AwAFCAUABAoAAA==.灭炎:AwAHCAEABAoAAA==.灵韵之风:AwAHCAEABAoAAA==.',['�']='燃烧:AwACCAMABAoAAA==.',['�']='爆打红烧肉:AwAHCAEABAoAAA==.爹地:AwAGCAwABRQDCAAGAQgMBAApHjsBBRQACAAFAQgMBAAuZTsBBRQACQAFAQiRAQAdbwsBBRQAAQgAXZEICAwABRQ=.',['�']='狼鸢狩:AwABCAEABRQAAQoAAAAICAQABRQ=.',['�']='王叔:AwAFCAYABAoAAA==.玛卡巴卡欣:AwAGCAEABAoAAA==.',['�']='种星星:AwAICBEABAoAAA==.',['�']='米浆粑粑:AwADCAcABRQDCwADAQhsGAAOib0ABRQACwADAQhsGAAOib0ABRQADAACAQg1EAA2KYsABRQAAA==.',['�']='紫灵:AwAGCAYABRQCDQAGAQgrAQBIlM4BBRQADQAGAQgrAQBIlM4BBRQAAA==.',['�']='纵享丝滑:AwADCAMABAoAAA==.',['�']='美如的德:AwAGCAYABAoAAA==.',['�']='茉莉雨:AwAICBEABAoAAA==.',['�']='菈妮:AwAHCAEABAoAAA==.',['�']='萨满中的矮子:AwAECAQABRQAAA==.',['�']='请叫我倾城君:AwAGCAEABAoAAA==.请叫我黑哥哥:AwAECAQABRQAAA==.',['�']='豆沙:AwABCAEABAoAAA==.',['�']='赞赞猪:AwAICAkABAoAAA==.',['�']='那個武僧:AwACCAIABRQAAA==.',['�']='非常迷幻:AwABCAEABAoAAA==.',['�']='风怒丹利伊:AwAECAkABAoAAA==.风羽燕归来:AwABCAEABRQAAA==.风般的美男子:AwACCAMABRQAAA==.',['�']='龍拳果实:AwAICBEABAoAAA==.龙与玫瑰:AwAFCAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end