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
 local lookup = {'Hunter-BeastMastery','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Paladin-Retribution','Warrior-Fury','Mage-Fire','Mage-Frost','Druid-Restoration','Hunter-Marksmanship',}; local provider = {region='CN',realm='卡珊德拉',name='CN',type='weekly',zone=42,date='2025-04-14',data={Da='Dannmm:AwABCAEABAoAAA==.',Fa='Fantastic:AwAECAcABAoAAA==.',He='Hermit:AwAGCAYABRQCAQAGAQioAQA+3bEBBRQAAQAGAQioAQA+3bEBBRQAAQIAAAAICAQABRQ=.',To='Touchgirl:AwADCAMABAoAAA==.',['�']='信仰圣光:AwAGCAYABAoAAA==.',['�']='光之律者:AwAGCAkABAoAAA==.',['�']='刘铋诚:AwADCAkABRQDAwADAQgLCwAwT9UABRQAAwADAQgLCwAwT9UABRQABAACAQhVBgAgyHMABRQAAA==.',['�']='北极的极地狐:AwAECAQABRQAAA==.',['�']='卡了卡了:AwAGCAYABAoAAA==.',['�']='哒啦术术:AwAICAsABAoAAA==.',['�']='宦海帝国:AwACCAQABRQAAA==.',['�']='小灬萌德:AwADCAMABAoAAA==.小番茄大冬瓜:AwAICAEABAoAAQUAXkICCAMABRQ=.小鹿丷:AwADCAMABAoAAA==.',['�']='幻影蛋蛋:AwAICAgABAoAAA==.',['�']='我是丶大叔:AwAECAYABRQCBgAEAQhSDgAkce0ABRQABgAEAQhSDgAkce0ABRQAAA==.',['�']='拉布拉多:AwAECAYABAoAAA==.',['�']='暗矛之音:AwAECAQABRQAAA==.',['�']='海边的卡夫卡:AwACCAEABAoAAA==.',['�']='烟丶花:AwAICBMABAoAAA==.',['�']='牛魔族大江君:AwAGCBEABAoAAA==.',['�']='猪儿虫:AwAGCAYABAoAAA==.',['�']='玖六:AwADCAQABRQDBwAIAQisJQBGsAQCBAoABwAIAQisJQBGsAQCBAoACAACAQhwmQAtBDAABAoAAA==.',['�']='瓦德拉肯之犄:AwACCAIABRQAAQkAOkwGCAUABRQ=.',['�']='罒蟹黄包:AwAECAQABRQAAA==.',['�']='芙莉德薇尔:AwABCAIABAoAAA==.',['�']='菊花中的蛋蛋:AwAGCAYABAoAAA==.菊花蛋蛋:AwAICAcABAoAAA==.',['�']='薄荷肉松:AwAGCAYABAoAAA==.',['�']='蛋蛋王:AwAICBAABAoAAA==.',['�']='貔貅貔貅:AwAECAQABAoAAA==.',['�']='追魂梦扬之心:AwABCAEABRQDAQAIAQgTIwBJ4E4CBAoAAQAIAQgTIwBJ4E4CBAoACgABAQgabgA06zEABAoAAA==.',['�']='野火哈基米:AwAECAQABAoAAA==.',['�']='阿武卵:AwACCAIABRQAAA==.',['�']='随心的风:AwAECAQABAoAAA==.',['�']='非个人:AwAFCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end