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
 local lookup = {'Paladin-Retribution','Warrior-Fury','Hunter-BeastMastery','Monk-Windwalker','DemonHunter-Vengeance','Paladin-Holy','Hunter-Marksmanship','DeathKnight-Unholy',}; local provider = {region='CN',realm='雷霆号角',name='CN',type='weekly',zone=42,date='2025-04-15',data={He='Hellcons:AwABCAEABAoAAA==.',Mo='Mozei:AwAGCAYABAoAAA==.',Oc='Octc:AwAECAYABRQCAQAEAQizHAAs2d4ABRQAAQAEAQizHAAs2d4ABRQAAA==.',St='Sten:AwACCAIABAoAAA==.',['�']='上帝曰了:AwECCAIABAoAAQIATGkECAIABRQ=.',['�']='义父:AwACCAIABAoAAA==.',['�']='伽勒比海带:AwAHCAkABAoAAQMAN9MGCAkABRQ=.',['�']='八码之外:AwAICAgABAoAAA==.',['�']='刘太医:AwABCAEABRQAAA==.别十一:AwAICAYABAoAAA==.',['�']='卡佳利丝:AwAFCAYABAoAAA==.',['�']='吹波糖:AwAGCA0ABAoAAA==.',['�']='周纸弱:AwAECAQABRQAAA==.',['�']='啊库娜玛塔塔:AwAGCAoABAoAAA==.啤酒:AwACCAIABRQAAA==.',['�']='夜深人静:AwAGCAsABAoAAA==.大美丽丶:AwAECAQABRQAAA==.天天没饭吃:AwAFCAEABAoAAA==.天青色等烟雨:AwACCAIABRQAAA==.',['�']='如果云知道:AwAICAMABAoAAA==.如梦如影:AwACCAIABAoAAA==.',['�']='小竹姐:AwAECAQABRQAAA==.小红手菈妮:AwACCAIABRQAAA==.小贝:AwAFCAUABAoAAA==.',['�']='巫祝:AwAGCA0ABAoAAA==.',['�']='希纳瓦尔斯:AwABCAEABAoAAA==.',['�']='幽冥纱幔:AwACCAIABAoAAA==.',['�']='彩色的肉弹:AwAICBAABAoAAQQAKkoICAYABRQ=.',['�']='德德灰:AwADCAMABAoAAA==.',['�']='愤青:AwACCAIABAoAAA==.',['�']='持枪抢钱:AwACCAEABAoAAA==.',['�']='无名晓猎:AwACCAIABAoAAA==.',['�']='月倾浅丶:AwAGCAIABRQAAA==.月瞳灬:AwADCAYABRQCBQADAQizCAAgCasABRQABQADAQizCAAgCasABRQAAA==.',['�']='欧款:AwABCAEABRQAAA==.',['�']='汀烟轻冉冉:AwAICAgABAoAAA==.',['�']='泰瑞娜丝:AwAECAgABRQCBgAEAQgCBwAeN9MABRQABgAEAQgCBwAeN9MABRQAAA==.',['�']='浮焰丶:AwACCAIABAoAAA==.',['�']='火鸡味锅笆:AwAECAQABRQAAA==.灬淡然:AwADCAcABRQDAwADAQhVGwA63tIABRQAAwADAQhVGwAiuNIABRQABwACAQhiEQBEWZ0ABRQAAA==.',['�']='無念:AwACCAIABRQAAA==.',['�']='破心:AwACCAQABRQAAA==.',['�']='翻白眼的船:AwACCAIABRQAAA==.',['�']='见手青:AwAECAgABRQCCAADAQi/EgAepsYABRQACAADAQi/EgAepsYABRQAAA==.',['�']='赞美圣光:AwAICAgABAoAAA==.',['�']='里奥哟西:AwAICAgABAoAAA==.',['�']='闪闪亮亮:AwADCAMABAoAAA==.',['�']='雕刻时光:AwAICAgABAoAAA==.',['�']='青丘皮卡丘:AwACCAIABRQAAA==.靓仔开个门:AwADCAMABAoAAA==.非法行医:AwADCAMABAoAAA==.',['�']='鬼影缠身:AwAHCAoABAoAAA==.',['�']='黑胡子船长:AwAECAQABAoAAA==.',['�']='龙王山炸天歌:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end