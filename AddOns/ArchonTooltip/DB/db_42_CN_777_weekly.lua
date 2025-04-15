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
 local lookup = {'Warlock-Destruction','Mage-Frost','DemonHunter-Havoc','Evoker-Devastation','Hunter-BeastMastery','Unknown-Unknown','Hunter-Marksmanship','DeathKnight-Unholy','Monk-Mistweaver','Paladin-Retribution','Paladin-Holy',}; local provider = {region='CN',realm='祖阿曼',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Aisaka:AwADCAIABAoAAA==.',Mi='Mikulu:AwAICAMABAoAAA==.',Ni='Nicholaslyx:AwACCAQABRQCAQAIAQj3EwBK6z0CBAoAAQAIAQj3EwBK6z0CBAoAAA==.',Re='Rexsparrow:AwABCAMABRQCAgAIAQhZCABVorICBAoAAgAIAQhZCABVorICBAoAAA==.',Un='Uncit:AwAGCAkABAoAAA==.',['�']='丁真:AwABCAEABRQAAA==.丶幽蓝蝶:AwACCAcABRQCAwACAQilIAAZd4YABRQAAwACAQilIAAZd4YABRQAAA==.',['�']='低调的小骑:AwADCAMABAoAAA==.',['�']='倏忽如风:AwAGCAEABAoAAA==.',['�']='别奶:AwACCAIABRQAAA==.别急有反转:AwACCAUABRQCBAACAQiGEQAnPogABRQABAACAQiGEQAnPogABRQAAA==.',['�']='大蛇丸:AwAHCAMABAoAAA==.天空的骑士:AwADCAIABAoAAA==.',['�']='妍寶:AwAICAgABAoAAA==.',['�']='娜塔亚:AwAGCAgABRQCBQAGAQioAABOG/MBBRQABQAGAQioAABOG/MBBRQAAQYAAAAICAQABRQ=.',['�']='守护:AwAECAQABRQAAA==.',['�']='斯人如逝:AwABCAEABRQAAA==.',['�']='来根梦龙:AwACCAEABRQAAA==.',['�']='果果小麻瓜:AwACCAQABRQDBwAIAQgnIwAvXIMBBAoABwAIAQgnIwAspoMBBAoABQAFAQiHnAAgML8ABAoAAA==.',['�']='污日:AwACCAQABRQAAA==.',['�']='法兰西多士:AwAECAUABRQCCAADAQiUFABHm6YABRQACAADAQiUFABHm6YABRQAAQgARtUFCA0ABRQ=.',['�']='炉钩子丶:AwADCAMABRQAAA==.',['�']='独戮天下:AwAFCAUABAoAAA==.独骑天下:AwAECAQABAoAAA==.',['�']='王源:AwAICBAABAoAAQYAAAABCAEABRQ=.',['�']='疯狂的摇滚熊:AwAHCAMABAoAAQYAAAAICAEABRQ=.',['�']='祖国昌盛:AwAGCAQABRQAAA==.',['�']='竉康:AwAICAgABAoAAA==.',['�']='花叶:AwAECAQABAoAAA==.',['�']='蜘蛛泡酒:AwAFCAUABAoAAA==.',['�']='詮釋傳說:AwAGCAEABAoAAA==.',['�']='调查她学历:AwACCAIABRQAAA==.',['�']='贰狗:AwACCAIABRQAAA==.',['�']='赵百灵:AwADCAsABRQCCQADAQhVBQBYAyUBBRQACQADAQhVBQBYAyUBBRQAAA==.',['�']='部落一哥:AwAFCAcABAoAAA==.',['�']='阿尔赛利亚:AwABCAEABRQDCgAIAQhyXwAt5rgBBAoACgAIAQhyXwAt5rgBBAoACwADAQjbOwAU0mQABAoAAA==.',['�']='鼠式坦克:AwACCAMABRQCCAAIAQj1LAA6f9ABBAoACAAIAQj1LAA6f9ABBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end