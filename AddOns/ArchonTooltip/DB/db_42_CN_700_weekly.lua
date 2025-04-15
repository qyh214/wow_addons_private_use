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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Rogue-Subtlety','Rogue-Assassination','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','Monk-Mistweaver','Priest-Shadow','Shaman-Enhancement',}; local provider = {region='CN',realm='普瑞斯托',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adencol:AwACCAYABRQDAQACAQh5DgA+C04ABRQAAQABAQh5DgA/yU4ABRQAAgABAQhTIwA8TUgABRQAAA==.',Al='Alcantara:AwABCAIABRQAAA==.',Bl='Blooddagger:AwAECAcABRQDAwADAQh2CAAbMNgABRQAAwADAQh2CAAbMNgABRQABAABAQgpFQAA0BYABRQAAA==.',Du='Duhunt:AwAGCAcABAoAAA==.',Gu='Gugul:AwACCAMABRQAAA==.',Ju='Justitia:AwAECAUABAoAAA==.',Ma='Mahapralaya:AwAECAQABRQAAA==.',Te='Tend:AwAFCAQABAoAAA==.',Wa='Wanaka:AwAECAQABRQAAA==.',['�']='一念丹香:AwAECAYABRQCBQAEAQimCAA1WOEABRQABQAEAQimCAA1WOEABRQAAA==.一锤八十:AwABCAMABRQAAA==.',['�']='你无敌了:AwAECAIABAoAAA==.',['�']='十年丶:AwAECAQABRQAAA==.',['�']='吴彦筝:AwAGCAoABAoAAA==.',['�']='噫辰龙:AwACCAIABRQCBgAIAQj1MABCrg0CBAoABgAIAQj1MABCrg0CBAoAAA==.',['�']='增辉龙:AwABCAEABRQAAA==.',['�']='夜中的安琪儿:AwAECAQABRQAAA==.',['�']='奈兒:AwAHCAIABAoAAA==.她说晒黑的:AwAICBMABAoAAA==.',['�']='容赦丶姬:AwAECAQABRQAAQYAQe4ICAkABRQ=.',['�']='小手搓搓:AwAECAQABRQAAQcAAAAICAEABRQ=.小手黑黑:AwAICAgABAoAAA==.尘合:AwABCAEABRQAAA==.就打德:AwAICAgABAoAAA==.',['�']='弑魔:AwADCAQABAoAAQcAAAABCAEABRQ=.',['�']='扶老奶奶过街:AwAECAEABRQCCAAHAQjeKwA1tYQBBAoACAAHAQjeKwA1tYQBBAoAAA==.',['�']='提莫:AwAICB8ABAoDBgAIAQiHEgBXhaQCBAoABgAIAQiHEgBXhaQCBAoABQAIAQhAGABCvNYBBAoAAA==.',['�']='播播:AwAICAgABAoAAA==.',['�']='暗夜小坏:AwAGCAYABRQCBgAGAQjnAAA/7d0BBRQABgAGAQjnAAA/7d0BBRQAAA==.',['�']='月下的安琪儿:AwAECAQABRQAAA==.未定之天命:AwAECAgABRQDAwAEAQjvAwBYbQ8BBRQAAwAEAQjvAwBLYg8BBRQABAAEAQiKBgA7Z/MABRQAAA==.',['�']='浪咯里咯浪:AwAICAgABAoAAA==.',['�']='渊恸:AwAICAEABAoAAA==.',['�']='漕泾战骑:AwAECAQABRQAAQkANl0GCAoABRQ=.',['�']='烈玄:AwAICAgABAoAAA==.',['�']='燎澜:AwAECAQABRQAAA==.',['�']='猎龙专家:AwAGCAwABAoAAA==.猪猪啵:AwABCAEABRQAAA==.',['�']='玛丶里苟斯:AwAECAQABAoAAA==.',['�']='真没关系吗:AwABCAEABAoAAA==.',['�']='碧螺春:AwACCAIABRQAAA==.',['�']='紫陌阡玉:AwAECAQABAoAAA==.',['�']='线性时不变:AwAECAQABRQAAA==.',['�']='花样作死冠军:AwAFCBIABRQDBgAFAQhsHABFuLYABRQABgACAQhsHABQebYABRQABQADAQjYDQA6968ABRQAAA==.',['�']='赛博义父:AwAECAQABAoAAA==.赫里斯塔:AwAGCAEABAoAAA==.',['�']='躏鳢萎:AwABCAEABRQAAA==.',['�']='雾里寻花:AwABCAEABRQAAA==.雾雨广藿香:AwAGCAYABRQCCgAGAQjhAAA0gMABBRQACgAGAQjhAAA0gMABBRQAAA==.',['�']='青峰:AwAGCAEABAoAAA==.',['�']='魔魔天:AwACCAIABRQAAA==.',['�']='黎厉害:AwAICAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end