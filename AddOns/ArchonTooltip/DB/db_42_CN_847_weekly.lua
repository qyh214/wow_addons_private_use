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
 local lookup = {'Warrior-Fury','Warlock-Destruction','DemonHunter-Havoc','Druid-Any','Druid-Restoration',}; local provider = {region='CN',realm='迦顿',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ac='Aceace:AwAICAIABAoAAA==.',An='Anageter:AwAFCAwABAoAAA==.',Ar='Arnold:AwABCAEABRQAAA==.',Bl='Bluenile:AwADCAMABAoAAA==.',El='Elle:AwADCAMABAoAAA==.',Qi='Qimoo:AwACCAEABRQAAA==.',['�']='丿晴天丶:AwAECAYABAoAAA==.',['�']='乱世维纳斯:AwABCAEABAoAAA==.',['�']='剑玖陆千里:AwADCAQABAoAAA==.',['�']='北落师門:AwABCAEABAoAAA==.',['�']='吼尐侠:AwACCAIABAoAAA==.',['�']='哎呀你别跑:AwAECAQABAoAAA==.',['�']='坚决拥护:AwADCAUABAoAAA==.',['�']='大哥大殁得很:AwACCAIABAoAAA==.大哥大邪得很:AwABCAEABAoAAA==.',['�']='奶妈奶爸奶牛:AwAECAQABRQAAA==.',['�']='媽媽説:AwABCAIABRQAAA==.',['�']='安度因乌瑞恩:AwABCAEABAoAAA==.',['�']='寂静寒夜:AwAECAQABAoAAA==.寡人:AwAGCAoABAoAAA==.',['�']='小小淘淘气气:AwAICAkABAoAAA==.小小狐狐:AwAECAQABRQAAA==.小小顽顽皮皮:AwAICAgABAoAAA==.小时候很洋气:AwAFCAYABAoAAA==.小葵花:AwADCAMABAoAAA==.小银仙归来:AwAHCAwABAoAAA==.',['�']='开宝马来接你:AwABCAEABAoAAA==.',['�']='很傻很水的牛:AwAFCAYABAoAAA==.',['�']='怒風:AwAECAQABAoAAA==.',['�']='愤怒啲妇焱洁:AwAHCAgABAoAAA==.',['�']='拾六厘米:AwACCAIABAoAAA==.',['�']='教黄爷爷:AwABCAEABAoAAA==.',['�']='无聊玩玩:AwAECAQABAoAAA==.',['�']='晓风残月:AwADCAMABAoAAA==.晦涩黎明:AwAFCAUABAoAAA==.智商已暴露:AwACCAUABRQCAQACAQjLHQAI5nQABRQAAQACAQjLHQAI5nQABRQAAA==.',['�']='替沧海寄巫山:AwAGCBQABAoCAgAGAQjmQQA4C0oBBAoAAgAGAQjmQQA4C0oBBAoAAA==.',['�']='未长大的面包:AwAFCAUABAoAAA==.',['�']='棘心夭夭:AwAICAgABAoAAA==.',['�']='清一色四暗刻:AwAECAIABRQAAA==.游亚旧梦:AwAFCAUABAoAAA==.',['�']='生前非常帅:AwADCAQABAoAAA==.',['�']='疯疯:AwAHCBkABAoCAwAHAQhQPAA4zpwBBAoAAwAHAQhQPAA4zpwBBAoAAA==.',['�']='硪叫哀木涕:AwABCAEABAoAAA==.',['�']='神兹巫兹:AwAICAcABAoAAA==.',['�']='秋风:AwAECAQABAoAAA==.',['�']='织语长心:AwACCAMABAoAAA==.络殇:AwAICBIABAoAAA==.',['�']='老头:AwAGCAYABAoAAA==.',['�']='胸越小心越近:AwAFCAUABAoAAA==.',['�']='脑袋瓜子:AwAECAQABRQAAA==.',['�']='艾亚哥斯:AwACCAIABRQAAA==.艾克希尔:AwAECAQABRQAAA==.',['�']='花间:AwADCAQABAoAAA==.',['�']='茜苽可苛荳:AwAGCAYABRQCBAAGAAgAAAAhfAAABRQABQAGAAgAAAAhfAAABRQAAA==.',['�']='莫无言:AwAECAQABAoAAA==.',['�']='萌萌哒花栗鼠:AwAECAIABRQAAA==.落雪:AwAICAgABAoAAA==.',['�']='蝶野真舞:AwABCAEABAoAAA==.',['�']='螺旋丸:AwABCAEABAoAAA==.',['�']='西湖龙井茶:AwAECAQABRQAAA==.西门大官人:AwACCAIABAoAAA==.',['�']='跟我走丶:AwADCAMABAoAAA==.',['�']='迎风飘去:AwAHCBEABAoAAA==.这是什么心态:AwABCAEABAoAAA==.',['�']='随便射射:AwAECAQABAoAAA==.',['�']='雨昔:AwAFCAUABAoAAA==.',['�']='青雨落白衣丶:AwAECAQABAoAAA==.',['�']='鯊魚辣椒:AwABCAEABRQAAA==.',['�']='鱼丸粗面:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end