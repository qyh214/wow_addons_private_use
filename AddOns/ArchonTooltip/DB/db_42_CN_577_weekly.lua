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
 local lookup = {'DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Fire','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Frost','Rogue-Assassination','Shaman-Restoration','Warrior-Fury','Warrior-Arms','Druid-Guardian','DeathKnight-Blood','Shaman-Enhancement','Paladin-Holy','Evoker-Devastation',}; local provider = {region='CN',realm='克苏恩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alencon:AwABCAEABRQAAA==.',Av='Avatart:AwAECAQABRQAAA==.',De='Deralanmao:AwABCAEABRQDAQAIAQifDgBFCwsCBAoAAQAIAQifDgBAWwsCBAoAAgAIAQjpKQBCRusBBAoAAA==.',Ha='Haken:AwAICAcABAoAAA==.',Ju='Junzhuoll:AwAECAoABRQCAwAEAQhKDwA+w/oABRQAAwAEAQhKDwA+w/oABRQAAA==.',Ma='Maox:AwAGCAYABAoAAA==.',Ta='Tavins:AwAECAgABRQCAgAEAQisEAApbOoABRQAAgAEAQisEAApbOoABRQAAA==.',['�']='不忘初心乄:AwACCAUABRQDBAACAQhDIwA6mZkABRQABAACAQhDIwA6UJkABRQABQABAQhjGQA4tEUABRQAAA==.严查内鬼:AwAGCAEABRQAAA==.',['�']='你的男神挑逗:AwAECAQABRQAAA==.',['�']='冰冷小斧:AwACCAIABRQAAA==.冷蓝溪若:AwAFCAUABAoAAA==.',['�']='卡尔萨斯:AwABCAIABRQCBgAIAQjECgA1K84BBAoABgAIAQjECgA1K84BBAoAAA==.',['�']='变形者集群:AwABCAEABRQCBwAIAQgsDABJqS8CBAoABwAIAQgsDABJqS8CBAoAAA==.可爱的三姨太:AwAECAgABRQCCAAEAQjpBgBKEgkBBRQACAAEAQjpBgBKEgkBBRQAAA==.',['�']='圣祈:AwAFCAEABRQAAA==.',['�']='夜間飛行:AwAICAgABAoAAA==.',['�']='小心月亮:AwAECAQABRQAAA==.尘成晨:AwAGCAYABRQDCQAGAQieAgAcuE8BBRQACQAFAQieAgAhGU8BBRQACgABAQjsEAALNlYABRQAAA==.',['�']='岁月无恨:AwAFCBEABAoAAA==.',['�']='德不劳动:AwAECAQABRQAAA==.',['�']='我猜你蛋很圆:AwAECAgABRQCCQAEAQjHCQA8PgcBBRQACQAEAQjHCQA8PgcBBRQAAA==.',['�']='折袖:AwACCAIABRQAAA==.',['�']='星痕:AwABCAIABRQAAA==.',['�']='晚宁:AwAECAQABRQAAA==.',['�']='暗之刀线:AwACCAUABRQCCwACAQhgBAALD0oABRQACwACAQhgBAALD0oABRQAAA==.',['�']='没事改不掉:AwAECAQABRQAAA==.没事改过了:AwAECAQABRQAAA==.',['�']='溜溜糖:AwAECAQABRQAAA==.',['�']='灵雾燥:AwAECAgABAoAAA==.',['�']='甜心兔兔:AwAICAgABAoAAA==.',['�']='神拳无敌:AwAFCAIABAoAAA==.',['�']='空城雨落:AwAICBAABAoAAA==.',['�']='紫羽衡君:AwADCAYABRQCDAADAQgRBABVcCoBBRQADAADAQgRBABVcCoBBRQAAA==.',['�']='绿眼睛:AwADCAwABRQCDQADAQh7AgBckkkBBRQADQADAQh7AgBckkkBBRQAAA==.',['�']='肝帝:AwAECAgABRQCDAAEAQhLBwBD0u4ABRQADAAEAQhLBwBD0u4ABRQAAA==.',['�']='致命元素:AwAGCAIABAoAAA==.',['�']='见习圣光:AwAGCAQABRQAAA==.',['�']='道德天尊:AwABCAEABAoAAA==.',['�']='铮铮鈤殇:AwACCAQABRQAAA==.',['�']='问剑:AwAECAgABRQCDgAEAQhmBwAPb8AABRQADgAEAQhmBwAPb8AABRQAAA==.',['�']='雷武龙:AwAFCAUABAoAAA==.雾燥:AwADCA4ABRQCDwADAQgpBgBSrAUBBRQADwADAQgpBgBSrAUBBRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end