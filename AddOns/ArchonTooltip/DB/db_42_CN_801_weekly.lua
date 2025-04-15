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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Warrior-Arms','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance',}; local provider = {region='CN',realm='艾苏恩',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ag='Aggression:AwAGCAQABRQAAA==.',Ko='Koler:AwACCAIABRQAAA==.',Le='Lezard:AwAECAQABRQAAA==.',Li='Lition:AwACCAIABRQAAA==.',Mi='Mikeos:AwAGCAcABAoAAA==.',On='Onlyfantasy:AwAGCAYABAoAAA==.',['�']='一期一会:AwAECAQABRQAAA==.',['�']='今宵有美酒:AwACCAQABRQAAA==.',['�']='俊恒水:AwABCAQABRQAAA==.',['�']='卡普拉:AwAECAQABRQAAA==.',['�']='可丨楽:AwADCAIABAoAAA==.',['�']='哞定天下:AwAICBAABAoAAA==.',['�']='团团:AwAFCAUABAoAAA==.',['�']='太曦神照:AwAECAQABRQAAA==.',['�']='守护者伊瑞尔:AwAECAIABRQAAA==.',['�']='就是爱:AwAGCAQABRQAAQEAKokICAIABRQ=.就是这样紫:AwAICAgABAoAAA==.',['�']='席尔瓦娜斯:AwAECAcABRQDAQAEAQioHwBKq7MABRQAAQACAQioHwBXm7MABRQAAgACAQi9GgAwzEwABRQAAA==.',['�']='总要有污妖:AwADCAMABAoAAA==.',['�']='惡靈灬騎士:AwAFCAUABAoAAA==.',['�']='懵逼又伤脑:AwAECAgABRQCAwAEAQj0AgBb2D4BBRQAAwAEAQj0AgBb2D4BBRQAAA==.',['�']='新能之光:AwAFCAQABRQCBAAIAQh4SABUjf0BBAoABAAIAQh4SABUjf0BBAoAAA==.',['�']='春风尽人意:AwAGCAQABAoAAA==.',['�']='来者不拒:AwAECAQABRQAAA==.',['�']='桑榆为尚:AwADCAMABAoAAA==.',['�']='榕城小虾米:AwAECAQABRQAAA==.',['�']='法玛里澳:AwAFCAUABAoAAA==.',['�']='漆黑的审判:AwAECAQABRQAAA==.',['�']='爆爆:AwAECAQABRQAAA==.',['�']='猎丶爹:AwACCAIABRQAAA==.',['�']='看什么看:AwAICAEABAoAAA==.',['�']='神开水:AwAECAQABRQAAA==.',['�']='納尔克:AwAECAQABRQAAA==.',['�']='纳言敏行:AwAECAMABRQAAA==.',['�']='苏打尐熊:AwAHCAcABAoAAA==.',['�']='葬送的芙莉莲:AwADCA0ABRQDBQADAQhTBgBFkhgBBRQABQADAQhTBgBFkhgBBRQABgACAQiTDgAyVJ0ABRQAAA==.',['�']='薅你头发:AwABCAEABRQAAA==.',['�']='西楼老公:AwAICAoABRQDBwAIAQgHAgA0aYMBBRQABwAFAQgHAgA5GYMBBRQACAAFAQheAQAou2gBBRQAAA==.',['�']='那我没办法:AwACCAIABRQAAA==.邱淑贞:AwAECAQABRQAAQkAAAAGCAQABRQ=.',['�']='阳菜:AwADCAEABAoAAA==.阿福满足:AwAHCAUABAoAAA==.',['�']='雷刃:AwACCAEABAoAAA==.',['�']='靛开水:AwAECAQABRQAAA==.',['�']='鼠鼠猫猫狗鸡:AwAECAQABRQAAA==.',['�']='凉开水:AwAECAYABRQDCgAEAQglFwAaINEABRQACgAEAQglFwAaINEABRQACwACAQjlEQAH2UkABRQAAQoAPtMGCAoABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end