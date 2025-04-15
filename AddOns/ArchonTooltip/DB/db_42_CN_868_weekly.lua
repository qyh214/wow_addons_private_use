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
 local lookup = {'Unknown-Unknown','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Druid-Restoration','Warlock-Affliction','Paladin-Retribution','Warrior-Arms','Warrior-Fury','Paladin-Holy','Warlock-Demonology','Shaman-Restoration',}; local provider = {region='CN',realm='阿曼尼',name='CN',type='weekly',zone=42,date='2025-04-15',data={At='Ataraxia:AwAICA8ABAoAAA==.',Fe='Fez:AwAFCAUABAoAAA==.',Gu='Guz:AwAECAQABRQAAQEAAAAGCAIABRQ=.',Ma='Mable:AwADCAMABAoAAA==.',Ni='Ninety:AwAECAQABRQAAA==.',Ph='Phoebe:AwACCAIABRQAAA==.',Ti='Titansange:AwAICAgABAoAAA==.',['�']='一支箭丶:AwABCAEABAoAAA==.不会无敌:AwAICA8ABAoAAA==.不动脑的老白:AwAGCAgABAoAAA==.不坦不奶不打:AwAFCAYABAoAAA==.不能說的秘密:AwABCAEABAoAAA==.丶欧气重重丶:AwAECAQABRQAAA==.丶洛神賦:AwAICBAABAoAAA==.',['�']='么么大王:AwAECAQABRQAAQIASvQICBMABRQ=.买不起牛奶:AwADCAIABAoAAA==.',['�']='五鬼天魔:AwAECAYABRQDAwAEAQjtDwAuNtwABRQAAwAEAQjtDwAtq9wABRQABAABAQgEHwAU0S8ABRQAAA==.亲缺德么:AwACCAMABRQCBQAIAQifFwBDFucBBAoABQAIAQifFwBDFucBBAoAAA==.',['�']='伍号推土机:AwAGCAEABAoAAA==.',['�']='初霁亦微暖丶:AwADCAIABRQAAA==.',['�']='南方的雪:AwAECAQABRQDAgAIAQh1EgBXpk0CBAoAAgAIAQh1EgBXpk0CBAoABgABAQj2OgA2mkAABAoAAA==.',['�']='又又的小龙人:AwAICAgABAoAAA==.又又的戒指:AwACCAIABAoAAQUAOkwGCAUABRQ=.',['�']='圣光武者:AwAECAQABRQAAA==.',['�']='埃辛诺斯乄:AwAECAQABRQAAA==.',['�']='大董来了:AwAECAIABRQAAQEAAAAGCAIABRQ=.',['�']='奥格外卖仔:AwABCAEABAoAAA==.',['�']='妹在不在:AwAGCAkABAoAAA==.',['�']='嫐嫐丶:AwADCAMABAoAAA==.',['�']='孙策:AwAECAQABRQAAA==.',['�']='寂寞术控:AwAGCAoABAoAAA==.',['�']='小小木头人:AwADCAMABAoAAA==.尛尾巴贔贔:AwAGCAYABAoAAA==.',['�']='帕拉塞尔苏斯:AwACCAIABRQAAA==.',['�']='徘徊于街角:AwAICAgABAoAAA==.',['�']='心如止水:AwADCAMABRQAAA==.',['�']='扌召贝才犭苗:AwAICAgABAoAAA==.',['�']='敌法灬李青:AwACCAIABRQAAA==.',['�']='新七:AwADCAkABRQCBwADAQiYEABFYAUBBRQABwADAQiYEABFYAUBBRQAAA==.',['�']='无冕者:AwAGCA4ABAoAAQcARjwCCAMABRQ=.无冠者:AwACCAMABRQCBwAIAQhnQABGPBQCBAoABwAIAQhnQABGPBQCBAoAAA==.无才有德:AwAGCAYABAoAAA==.',['�']='晨曦亦如初见:AwABCAEABRQCBwAIAQh/NwBDNjICBAoABwAIAQh/NwBDNjICBAoAAA==.',['�']='朱小滢:AwAECAQABRQAAA==.',['�']='柠檬可乐:AwAICAgABAoAAA==.',['�']='桃核儿:AwAHCAEABAoAAA==.',['�']='波比小佑:AwABCAEABRQAAA==.',['�']='洛薩:AwAGCAwABRQDCAAGAQhUAABC8eQBBRQACAAGAQhUAABC8eQBBRQACQAEAQjfEAAeveIABRQAAA==.',['�']='清晨睡马路:AwACCAIABAoAAA==.',['�']='灬影灬:AwAFCAQABAoAAA==.灯泡个灯:AwAECAQABRQAAA==.',['�']='無丶悠:AwAECAQABAoAAA==.',['�']='疯神再世:AwAICBAABAoAAA==.',['�']='白家老七:AwAECAgABRQDBwAEAQg6HQAsYdwABRQABwAEAQg6HQAsYdwABRQACgAEAQhDBwAcY84ABRQAAA==.',['�']='瞬间:AwAECAQABRQAAQEAAAAGCAIABRQ=.',['�']='站住等我奶你:AwABCAEABAoAAA==.',['�']='绿皮会武功:AwAGCAYABAoAAA==.',['�']='老年绝活选手:AwAECAIABRQAAA==.',['�']='肆号推土机:AwAGCAgABAoAAA==.肉肉也疯狂:AwACCAIABAoAAA==.',['�']='胆小的财财:AwAECAQABRQAAA==.胖乎乎的瞬间:AwAECAQABRQAAA==.',['�']='艾露鸽:AwADCAMABRQAAA==.',['�']='萨囧囧:AwABCAEABRQAAA==.',['�']='蒜鸟算鸟:AwAECAQABRQAAQsATtgICAsABRQ=.',['�']='起个门拉个糖:AwAHCAYABAoAAA==.',['�']='超级小思嘉:AwACCAQABRQCDAAIAQg3GwBEVxYCBAoADAAIAQg3GwBEVxYCBAoAAA==.',['�']='辰灬不二:AwAICA4ABAoAAA==.',['�']='酸奶:AwAICAMABAoAAA==.',['�']='雪月丶风华:AwAHCBEABAoAAA==.雯雯李:AwAGCAYABAoAAA==.',['�']='震撼帝:AwADCAcABRQCBAADAQgKCABFEPIABRQABAADAQgKCABFEPIABRQAAQQARfcECAwABRQ=.',['�']='風雨夜無笙:AwABCAEABRQAAA==.',['�']='魅力乱射:AwABCAEABRQAAA==.',['�']='鸿运当头丶:AwAICAQABRQAAA==.',['�']='黑痒痒:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end