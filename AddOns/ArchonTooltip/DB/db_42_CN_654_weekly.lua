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
 local lookup = {'Druid-Balance','Druid-Restoration','Unknown-Unknown','Mage-Frost','DeathKnight-Blood','Warrior-Fury','Warrior-Arms','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution',}; local provider = {region='CN',realm='安纳塞隆',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Banshee:AwAFCAQABRQDAQAIAQhMTAAbdE4BBAoAAQAIAQhMTAAbdE4BBAoAAgAIAQjiLAAgw0gBBAoAAQMAAAAGCAIABRQ=.',Di='Dissipate:AwAGCAYABAoAAA==.',Du='Dudgeonm:AwAECAYABRQCBAAEAQgRBABM+wQBBRQABAAEAQgRBABM+wQBBRQAAA==.',Gr='Gravityy:AwAECAQABRQAAA==.',Ob='Oblivions:AwAECAYABAoAAA==.',['�']='不川苦茶子:AwADCAMABRQAAA==.',['�']='今年我十八:AwAGCAYABRQCBQAGAQgkAQA2pYQBBRQABQAGAQgkAQA2pYQBBRQAAA==.',['�']='六袋长老:AwAICAUABAoAAA==.',['�']='冬至丶戦:AwACCAIABAoAAA==.冰封牛奶:AwADCAkABRQDAgADAQgNCgAcuLsABRQAAgADAQgNCgAcuLsABRQAAQABAQj6KgAGQT8ABRQAAA==.',['�']='可惡:AwAECAQABRQAAQMAAAAGCAIABRQ=.',['�']='哈利撸呀:AwAGCAEABAoAAA==.',['�']='嫂子请抱紧沃:AwACCAUABRQDBgACAQjiGgAb6YMABRQABgACAQjiGgAWBYMABRQABwABAQiqEgApLk4ABRQAAA==.',['�']='小伙伴惊呆了:AwAECAQABRQAAA==.小猴子杂货铺:AwAGCAYABAoAAA==.',['�']='工友夸我能射:AwABCAEABAoAAA==.',['�']='帅电工:AwAICAgABAoAAA==.',['�']='我们校风很大:AwACCAIABRQAAQMAAAAICAMABRQ=.戰丨钰:AwAECAQABRQAAA==.',['�']='昊丶坤尔加丹:AwAECAQABRQAAA==.昨日倾城:AwAECAYABAoAAA==.',['�']='槽芳芳:AwAECAQABRQAAQgAMPwGCAgABRQ=.',['�']='橙色丶风暴:AwAGCAcABRQDCQAGAQghAwBCOHMBBRQACQAFAQghAwA9UXMBBRQACgACAQhiEQBLLosABRQAAQMAAAAICAIABRQ=.',['�']='死而复生丶:AwACCAIABAoAAA==.',['�']='海盗:AwACCAIABRQAAA==.海盗号角:AwADCAUABRQCCwADAQgZFgA3nOsABRQACwADAQgZFgA3nOsABRQAAA==.海鲜:AwAFCAkABAoAAA==.',['�']='烟灰:AwAICAgABAoAAA==.',['�']='爱吃豌杂面:AwABCAEABRQAAA==.',['�']='猛将兄丶:AwAICAkABAoAAA==.',['�']='纤纤青丝:AwAECAQABRQAAA==.',['�']='萧婉晴:AwABCAEABAoAAA==.落坨翔子:AwAGCAoABAoAAA==.落婲丶无痕:AwAICAgABAoAAA==.',['�']='蓝羽:AwAECAoABRQCBQAEAQjYAQBh5VgBBRQABQAEAQjYAQBh5VgBBRQAAA==.',['�']='逍遥一梦:AwAICAYABAoAAA==.',['�']='骑猪找对象:AwAGCAoABRQCCwAGAQiSCABMGB8BBRQACwAGAQiSCABMGB8BBRQAAA==.骑猪看夕阳:AwADCAMABAoAAA==.',['�']='黑暗化身丶:AwABCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end