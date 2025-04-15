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
 local lookup = {'Mage-Fire','Shaman-Elemental','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Unholy','Unknown-Unknown','Paladin-Retribution','Monk-Mistweaver','Shaman-Restoration',}; local provider = {region='CN',realm='奈法利安',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Archonsu:AwAECAIABRQAAQEAQ8QICAcABRQ=.',In='Insane:AwAECAIABAoAAA==.',Ir='Iris:AwAICAgABAoAAA==.',Ja='Jacklover:AwAICA8ABAoAAA==.',Mm='Mmekii:AwAGCAYABAoAAA==.',['�']='光之凤舞:AwAGCAYABAoAAA==.',['�']='冷夜雨:AwAHCAIABAoAAA==.',['�']='千幻丶:AwADCAcABRQCAgADAQj1CABbuMsABRQAAgADAQj1CABbuMsABRQAAA==.',['�']='壹玖玖贰:AwADCAMABRQAAA==.',['�']='奈特灵音:AwAECAEABRQAAA==.',['�']='室静蘭幽:AwAECAQABRQAAA==.',['�']='小嘴真甜:AwACCAIABAoAAA==.小巷里的拓海:AwACCAIABAoAAA==.尐死骑:AwADCAMABRQAAA==.尐灬情话:AwABCAEABRQAAA==.尐精灵:AwAECAgABRQDAwAEAQjcBQBbDvkABRQAAwADAQjcBQA1IvkABRQABAAEAQhGFQBbDgAABRQAAA==.',['�']='山海丨草東:AwACCAEABAoAAA==.',['�']='心梦缘飞:AwACCAIABAoAAA==.',['�']='恩地:AwAECAcABRQCBQAEAQhpBABZaSYBBRQABQAEAQhpBABZaSYBBRQAAA==.',['�']='懓语:AwAICAgABAoAAA==.',['�']='我你本良人:AwAFCAUABAoAAA==.我带地狱犬:AwAECAQABRQAAQYAAAAICAQABRQ=.我是防骑:AwACCAUABRQCBwACAQikJgBDzZwABRQABwACAQikJgBDzZwABRQAAA==.',['�']='旦哥:AwAHCAcABAoAAA==.',['�']='春风沐宇:AwAFCAUABAoAAA==.是猫不是熊:AwAICBQABAoCCAAIAQgBJwAuqqEBBAoACAAIAQgBJwAuqqEBBAoAAA==.',['�']='李小歪:AwAHCAwABAoAAA==.',['�']='极地冰河:AwAGCAYABAoAAA==.',['�']='棉花囡囡:AwAICA4ABAoAAA==.',['�']='毗沙门天:AwAGCAwABAoAAA==.',['�']='深海萝莉凤灬:AwAHCAEABAoAAA==.',['�']='王大炮:AwAICAgABAoAAA==.',['�']='神明灵:AwADCAQABAoAAA==.',['�']='简心记:AwAECAQABRQAAA==.',['�']='艾伦一世:AwAGCAYABAoAAA==.艾雅米诺:AwAICBoABAoCBwAIAQgANABR/jQCBAoABwAIAQgANABR/jQCBAoAAA==.',['�']='芋泥波波:AwADCAMABAoAAA==.芒果:AwAGCAYABAoAAA==.',['�']='苏沐橙:AwABCAEABRQCCQAIAQh+GQBHTxoCBAoACQAIAQh+GQBHTxoCBAoAAA==.',['�']='行于流逝的岸:AwAECAQABAoAAA==.',['�']='迪西唔西:AwAECAQABAoAAA==.迷途小姝童:AwAECAQABRQAAA==.',['�']='逐风之舞:AwAGCAQABRQAAA==.',['�']='邢捕头:AwAECAQABRQAAA==.',['�']='醉美肖梦琪:AwAHCAcABAoAAA==.',['�']='錦木千束:AwAECAQABRQAAA==.',['�']='阴阳怪氣:AwAECAIABAoAAA==.',['�']='陆上最强:AwAECAQABRQAAA==.',['�']='顶端女人:AwAECAUABAoAAA==.',['�']='鬼蜮筱丫丫:AwAECAQABRQAAQIAXG4ICAgABRQ=.',['�']='鲜血女皇:AwABCAEABAoAAA==.',['�']='黯熙徵伖:AwAECAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end