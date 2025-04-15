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
 local lookup = {'Paladin-Retribution','Warrior-Arms','Warrior-Fury','Priest-Discipline','Priest-Shadow','Shaman-Restoration','DeathKnight-Blood',}; local provider = {region='CN',realm='火烟之谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Catiam:AwAECAQABRQAAA==.',Je='Jerox:AwAECAQABRQAAA==.',Lo='Lorabbit:AwABCAMABRQAAA==.',Ru='Rubyflame:AwAECAEABRQAAA==.',Th='Thundervice:AwABCAIABAoAAA==.',['�']='丶楼影:AwACCAIABAoAAA==.为爱战死床头:AwAECAQABRQAAA==.丿丶指间灬砂:AwAICAgABAoAAA==.',['�']='乌啦啦:AwAECAcABRQCAQAEAQgVEABLLgABBRQAAQAEAQgVEABLLgABBRQAAA==.乌鸦大人:AwACCAIABRQAAA==.',['�']='今晚吃鸡:AwAGCBAABRQDAgAGAQi7AAAmRaoBBRQAAgAGAQi7AAAkNKoBBRQAAwAFAQgWAwAZ7UMBBRQAAA==.仙熊掌和鱼:AwAECAQABRQAAA==.',['�']='侠女妙影:AwAGCBEABAoAAA==.',['�']='入夜:AwACCAMABRQAAA==.',['�']='删除记忆:AwADCAQABRQAAA==.',['�']='又待黄昏:AwAGCAwABAoAAA==.',['�']='呆贼:AwABCAEABRQAAA==.',['�']='夜之燧:AwABCAEABRQAAA==.夜之穗:AwADCAMABRQAAA==.夜之韢:AwAGCAoABAoAAA==.夜羽:AwAICAgABAoAAA==.大魔王:AwAGCAEABAoAAA==.',['�']='娜萨:AwABCAEABAoAAA==.',['�']='宁辞秋:AwACCAIABRQAAA==.',['�']='小蘿麗:AwAGCAQABRQAAA==.小馬寶莉:AwAGCA8ABRQDBAAGAQgTBAA/+igBBRQABAAGAQgTBAA/+igBBRQABQAEAQjXDAAmeNoABRQAAA==.',['�']='帅气小贼:AwAFCAgABAoAAA==.',['�']='挡你的虔诚:AwAFCA0ABAoAAA==.',['�']='文衍:AwAECAQABRQAAA==.',['�']='有根大竹子:AwADCAMABAoAAA==.木木灬:AwABCAEABAoAAA==.',['�']='桑德兰:AwAFCA0ABAoAAA==.',['�']='梧桐栖凤:AwAFCAUABAoAAA==.',['�']='湛蓝玫瑰:AwABCAEABRQAAA==.',['�']='灬浮丨云灬:AwAECAQABAoAAA==.',['�']='热烈的马:AwAGCAEABAoAAA==.',['�']='犯困的荷包蛋:AwAECAQABRQAAA==.',['�']='猎尽天下靓妞:AwAHCAcABAoAAA==.',['�']='程洁琪:AwABCAEABAoAAA==.',['�']='老奶奶过马路:AwABCAEABAoAAA==.老船长丢火车:AwACCAIABAoAAA==.',['�']='菠萝到处浪啊:AwAFCA4ABAoAAA==.',['�']='萌新小萨:AwACCAYABRQCBgACAQhVDQBhJN4ABRQABgACAQhVDQBhJN4ABRQAAA==.',['�']='躲在你的衣柜:AwAFCA0ABAoAAA==.',['�']='过期小鲜肉:AwACCAEABAoAAA==.',['�']='酋长毛结棍:AwAICAMABAoAAA==.酒亦醉情易碎:AwAECAgABRQCBwAEAQj5BgBE+PMABRQABwAEAQj5BgBE+PMABRQAAA==.',['�']='隐藏角色:AwABCAEABRQCAQAIAQhTEQBaNcICBAoAAQAIAQhTEQBaNcICBAoAAA==.',['�']='马啦啦:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end