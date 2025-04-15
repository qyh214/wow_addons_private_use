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
 local lookup = {'Monk-Windwalker','Monk-Brewmaster','Paladin-Retribution','Paladin-Holy','Mage-Frost','Mage-Fire','Warrior-Fury','Shaman-Restoration','Priest-Shadow','Hunter-BeastMastery',}; local provider = {region='CN',realm='巴尔古恩',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Angelhymn:AwABCAMABRQDAQAIAQiJBQBYfsgCBAoAAQAIAQiJBQBYfsgCBAoAAgACAQjoGwAgumYABAoAAA==.',Cl='Classrhodey:AwABCAEABRQAAA==.',Cm='Cmx:AwADCAQABRQAAA==.',Hu='Huigui:AwABCAEABRQAAA==.',Ma='Mabinogihero:AwAICA8ABAoAAA==.',Mi='Mikadohana:AwADCAIABAoAAA==.',No='Novemberrain:AwACCAIABRQAAA==.',['�']='七叶海棠:AwAFCAkABAoAAA==.为倪消瘦:AwABCAEABRQAAA==.丿小虎:AwACCAQABRQDAwAIAQgVWABFe8sBBAoAAwAHAQgVWABJLssBBAoABAAGAQiDIAAxsiQBBAoAAA==.',['�']='何处觅青龙:AwAECAYABRQDBQAEAQilBwAhHs4ABRQABQAEAQilBwAhHs4ABRQABgACAQjvKAAZsIAABRQAAQMATkoGCAYABRQ=.何昕橙:AwABCAEABRQAAA==.佛老瓦:AwAECAQABAoAAA==.',['�']='傲气之法:AwAECAgABRQCBgAEAQgICQBRKyABBRQABgAEAQgICQBRKyABBRQAAA==.',['�']='光明冰砖:AwAECAQABRQAAA==.',['�']='可爱容颜倾城:AwAICAgABAoAAA==.',['�']='咧琛:AwAECAQABRQAAA==.',['�']='喆喆的小奶嘴:AwABCAEABRQAAA==.',['�']='四根一疗程:AwAGCAYABAoAAA==.',['�']='夏媞雅:AwADCAMABAoAAA==.',['�']='娜贝拉尔:AwABCAEABRQAAA==.',['�']='小牛疯了:AwACCAIABAoAAA==.小狐狸:AwAHCBIABAoAAA==.',['�']='弍公主:AwAICAgABAoAAA==.',['�']='怪盗贞德:AwABCAEABAoAAA==.',['�']='我会永远爱你:AwAGCAoABRQCBgAGAQj2AABZGAkCBRQABgAGAQj2AABZGAkCBRQAAA==.我叫霎聪君:AwAICBcABAoCBwAIAQg7HQA+xQ8CBAoABwAIAQg7HQA+xQ8CBAoAAA==.',['�']='打发打发时间:AwABCAEABRQAAA==.',['�']='明明灬狗:AwADCAIABAoAAA==.',['�']='晨曦若岚:AwAECAgABRQCCAAEAQiYBQBF5xUBBRQACAAEAQiYBQBF5xUBBRQAAA==.',['�']='未知劣人:AwABCAEABRQAAA==.',['�']='柯基小短腿:AwAECAQABAoAAA==.',['�']='梦里啥都没有:AwACCAQABRQAAA==.',['�']='毛牛:AwABCAEABAoAAA==.',['�']='清净灵珑:AwACCAIABRQAAA==.',['�']='独自风飘一:AwAGCAYABAoAAA==.',['�']='王昭:AwAECAQABRQAAA==.玛尔兰:AwABCAEABRQAAA==.',['�']='琬风似嫚:AwAECAQABAoAAA==.',['�']='瞎了狗眼:AwAGCAcABRQCCQAGAQhWEABHALcABRQACQAGAQhWEABHALcABRQAAA==.',['�']='神圣弑魂:AwAICAcABAoAAA==.',['�']='红手哥布林:AwAGCAoABAoAAA==.',['�']='耀光如炬:AwAECAMABAoAAA==.',['�']='聂庞重生:AwAFCAUABAoAAA==.联盟骑士:AwAECAQABRQAAA==.',['�']='舞动的弓弦:AwACCAUABRQCCgACAQj/JAAySpUABRQACgACAQj/JAAySpUABRQAAA==.',['�']='蘑菇头:AwACCAIABAoAAA==.',['�']='贼少:AwAGCAYABAoAAA==.',['�']='赤龙影:AwACCAIABRQCBwAIAQiLEwBLtFUCBAoABwAIAQiLEwBLtFUCBAoAAA==.',['�']='超美小猪:AwAECAEABRQAAA==.',['�']='随便整三号:AwABCAEABRQAAA==.',['�']='露普斯蕾琪娜:AwABCAEABRQAAA==.',['�']='魔界之武圣:AwACCAIABAoAAA==.魔界之法神:AwAECAYABAoAAA==.魔界之混沌:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end