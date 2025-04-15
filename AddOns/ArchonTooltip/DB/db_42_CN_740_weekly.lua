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
 local lookup = {'Paladin-Protection','Mage-Arcane','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Paladin-Retribution','Priest-Holy','Priest-Discipline','Shaman-Restoration','DeathKnight-Blood',}; local provider = {region='CN',realm='火喉',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asassainq:AwAGCAwABAoAAA==.',Ga='Gawaine:AwACCAIABAoAAA==.',Ic='Iceiceice:AwAECAQABRQAAA==.',Im='Imshaman:AwAICAoABAoAAA==.',Li='Lilian:AwADCAEABAoAAA==.',Lo='Loridad:AwAECAQABRQAAA==.',['�']='不死大腿:AwAGCAcABAoAAA==.',['�']='伊吹萃香:AwACCAIABRQAAA==.',['�']='初春饰利:AwADCAQABRQCAQAIAQinDQA/5wMCBAoAAQAIAQinDQA/5wMCBAoAAA==.',['�']='力丸:AwAFCAUABAoAAA==.',['�']='勿忘心安:AwAHCAcABAoAAA==.',['�']='半夏的留念:AwACCAIABAoAAA==.卡卡霸道婷哥:AwAECAQABRQAAA==.卡西奥佩娅:AwAECAQABRQAAA==.卡里古拉:AwABCAEABAoAAA==.',['�']='叫我亚瑟:AwAECAQABRQAAA==.',['�']='嗷呜:AwABCAEABAoAAA==.',['�']='姐姐下班我接:AwAICAgABAoAAA==.',['�']='帅比无敌发丝:AwACCAUABRQCAgACAQjbAQAcInoABRQAAgACAQjbAQAcInoABRQAAA==.',['�']='废蛙丶:AwAFCAUABAoAAA==.',['�']='恶魔安娜:AwAHCAcABAoAAA==.恶魔红叶:AwAICAgABAoAAA==.',['�']='我们是一家人:AwAICAgABAoAAA==.我藏好了:AwAECAEABRQEAwAIAQh2BgBaRrYCBAoAAwAIAQh2BgBZY7YCBAoABAACAQgGIgBV+b4ABAoABQACAQgTWABC9E8ABAoAAA==.',['�']='手指安魂曲:AwAICAgABAoAAA==.',['�']='敏儿米熊:AwAICAcABAoAAA==.',['�']='方舟骑士:AwAICAYABAoAAA==.',['�']='星星骑士:AwAECAQABRQAAA==.',['�']='暮幽:AwACCAIABRQAAA==.',['�']='月影魂殇:AwAICAgABAoAAA==.',['�']='杰森斯坦森:AwACCAIABRQCBgAIAQi/BgBf0PgCBAoABgAIAQi/BgBf0PgCBAoAAA==.',['�']='烈焰洪拳:AwAFCAgABAoAAA==.',['�']='生死有命:AwADCAMABAoAAA==.',['�']='纯情丶大表哥:AwABCAEABAoAAA==.',['�']='美女騎士:AwAHCAwABAoAAA==.',['�']='苍雪:AwAECAQABRQAAA==.',['�']='谈影空人心:AwAICAIABAoAAA==.',['�']='身高定战斗力:AwADCAUABRQCAwADAQjqCwBBqOIABRQAAwADAQjqCwBBqOIABRQAAA==.',['�']='轻描淡写灬肆:AwACCAIABAoAAA==.',['�']='达达馥裕:AwAECAIABRQAAA==.',['�']='醉爱红尘:AwACCAMABRQAAA==.',['�']='阿尔宙斯:AwABCAEABRQAAA==.',['�']='陶大奋:AwAICBgABAoDBwAIAQjLIgAw+aQBBAoABwAIAQjLIgAw+aQBBAoACAACAQiQgAAckCsABAoAAQkAJ5wFCA4ABRQ=.',['�']='随便玩玩:AwACCAIABRQAAA==.',['�']='飘杨的蒲公英:AwAECAkABRQCCgAEAQiEEAAYaZUABRQACgAEAQiEEAAYaZUABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end