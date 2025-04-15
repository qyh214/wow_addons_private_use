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
 local lookup = {'Hunter-Marksmanship','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Druid-Balance','Priest-Discipline','Paladin-Holy','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy',}; local provider = {region='CN',realm='杜隆坦',name='CN',type='weekly',zone=42,date='2025-04-14',data={Da='Darkhunter:AwAFCAUABAoAAA==.',Hu='Hunterp:AwADCAUABRQCAQADAQj5CwAc9cYABRQAAQADAQj5CwAc9cYABRQAAA==.',Ir='Iries:AwAICBAABAoAAA==.',['S�']='Sàurfang:AwAFCAUABAoAAA==.',['Y�']='Yùyc:AwAGCAYABAoAAA==.',['�']='一盏风月:AwACCAIABRQDAgAIAQiWJQBNAQMCBAoAAgAHAQiWJQBOhgMCBAoAAwAIAQg4JQAmRiABBAoAAQIAMf0GCA4ABRQ=.',['�']='九尾雪狐:AwAECAQABRQAAA==.',['�']='人族先锋:AwAICBAABAoAAA==.',['�']='列克星敦:AwAECAEABRQAAA==.利托里奥:AwADCAYABRQCBAADAQj4CQBDogUBBRQABAADAQj4CQBDogUBBRQAAA==.',['�']='和聲細語:AwAECAgABRQCBQAEAQjhDwAvH+YABRQABQAEAQjhDwAvH+YABRQAAA==.',['�']='土佬肥:AwABCAEABRQAAA==.',['�']='夜清醒:AwAECAQABRQAAA==.',['�']='左辰右米:AwAECAQABRQAAA==.',['�']='幽色玫瑰:AwACCAIABAoAAA==.',['�']='恶魔追击:AwAGCAQABRQAAA==.',['�']='无锡彭于晏丶:AwAECAQABRQAAA==.',['�']='条条:AwAECAMABRQAAQYAFksGCAoABRQ=.',['�']='柒筱柒:AwAGCAsABAoAAA==.',['�']='梅川库紫:AwABCAEABAoAAA==.梅花十三:AwADCAQABAoAAA==.',['�']='檎炎熙雨:AwAICAgABAoAAA==.',['�']='死胖子:AwAICAEABAoAAA==.',['�']='毛毛虫美女:AwAECAIABAoAAA==.',['�']='沐璃晴:AwAFCAkABAoAAA==.沫小滥:AwAFCAMABAoAAA==.',['�']='洛濏玛:AwAFCAUABAoAAA==.',['�']='澟冬將至:AwAECAQABRQAAA==.',['�']='灬糖喵喵:AwAFCAQABAoAAA==.',['�']='玛琺里奥:AwABCAIABRQAAA==.',['�']='甜炎蜜雨:AwAECAYABRQCBwAEAQhUBAA1dvEABRQABwAEAQhUBAA1dvEABRQAAQgAS6QGCAoABRQ=.',['�']='秀炎秀雨:AwAECAQABRQAAA==.',['�']='纱纱:AwAFCAEABAoAAA==.',['�']='罒尛喪黑:AwABCAEABRQAAA==.',['�']='肥嘟嘟:AwADCAEABAoAAA==.',['�']='萨拉托加:AwAICAIABAoAAA==.',['�']='董董盼盼:AwACCAMABRQAAA==.',['�']='蒜小叶:AwAECAQABRQAAA==.',['�']='要了老命:AwACCAQABRQDCQAIAQh3CQBBiOsBBAoACQAIAQh3CQBBiOsBBAoACgACAQjckwAl7GAABAoAAA==.',['�']='诸葛武侯:AwAICAgABAoAAA==.诸葛钢钉:AwAFCAUABAoAAA==.',['�']='阿猛小朋友:AwAHCAMABAoAAA==.',['�']='风雨潇潇:AwAFCAgABAoAAA==.',['�']='鬼舞日鸡:AwACCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end