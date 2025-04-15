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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Monk-Windwalker','Paladin-Retribution','Paladin-Protection','Monk-Brewmaster','Warrior-Fury',}; local provider = {region='CN',realm='塔纳利斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ck='Ckc:AwAECAQABRQAAA==.',Dk='Dknight:AwADCAQABRQDAQAIAQhzGgBJrTsCBAoAAQAIAQhzGgBIOTsCBAoAAgAHAQhREgApekIBBAoAAA==.',Do='Domoq:AwACCAIABRQAAA==.',Ma='Maxii:AwAICAMABAoAAA==.',Mu='Muda:AwAECAQABRQAAA==.',Yi='Yiesus:AwAECAQABRQAAA==.',['�']='一天都顶起:AwACCAIABRQAAA==.临风听蝉:AwAICBAABAoAAA==.',['�']='伊暮:AwACCAIABRQAAA==.',['�']='兰卡威豪仔:AwADCAMABAoAAA==.',['�']='十二路弹腿:AwAICAgABAoAAA==.',['�']='夹心甜点:AwADCAQABRQAAA==.',['�']='寡人有请爱妃:AwAHCAcABAoAAQMAQb8ECAcABRQ=.',['�']='小三:AwABCAEABRQDBAAIAQhudAA1I4cBBAoABAAHAQhudAA53IcBBAoABQAIAQj0HwAevyUBBAoAAA==.',['�']='桐谷和人:AwAICAgABAoAAA==.',['�']='梦寐龙:AwACCAMABRQAAA==.',['�']='此牛可能无敌:AwAECAcABRQDAwAEAQh2BgBBv/4ABRQAAwAEAQh2BgBBv/4ABRQABgACAQiWBgAXkV0ABRQAAA==.',['�']='火鸟魔导士:AwAICAgABAoAAQUAKkQGCAoABRQ=.',['�']='绿魔鬼:AwAECAQABRQAAA==.',['�']='芷言:AwAECAYABAoAAA==.',['�']='萌蹄牛角包:AwAECAQABRQAAA==.萨魔:AwABCAEABRQAAA==.',['�']='薄酒灬漫星夜:AwAICAkABAoAAA==.',['�']='血域幽魂:AwAECAQABAoAAA==.血色莲华:AwAFCAEABAoAAA==.',['�']='長松落落:AwAGCAUABAoAAA==.',['�']='风间飞熊:AwAECAQABRQAAQcAP/EHCAYABRQ=.',['�']='魍罔剡薾:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end