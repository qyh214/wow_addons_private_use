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
 local lookup = {'Paladin-Retribution','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','Mage-Fire','Shaman-Restoration','Hunter-BeastMastery','Shaman-Enhancement','DeathKnight-Unholy',}; local provider = {region='CN',realm='狂风峭壁',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bl='Blacklilas:AwACCAMABAoAAA==.',Ce='Celestia:AwADCAMABAoAAA==.',De='Devilman:AwAICAMABAoAAA==.',Ei='Eilenngu:AwADCAMABAoAAA==.',Me='Messi:AwAECAgABRQCAQAEAQiTBABbhzoBBRQAAQAEAQiTBABbhzoBBRQAAA==.',Mv='Mvp:AwAGCAcABAoAAA==.',Oo='Oox:AwAECAQABRQAAA==.',Vi='Vip:AwAECAUABRQCAgAEAQjoEAAUUpIABRQAAgAEAQjoEAAUUpIABRQAAA==.',['Ä']='Äöäöä:AwAECAYABRQDAwAEAQgiBQBJ7wUBBRQAAwAEAQgiBQBE6wUBBRQABAACAQj6DQAsPVMABRQAAA==.',['�']='三十六的汉子:AwAFCAYABAoAAA==.不可驯服:AwAECAQABRQAAA==.丨聖光將熄丨:AwAFCAUABAoAAA==.',['�']='乖猪:AwAECAQABRQAAQUAT1sHCAUABRQ=.',['�']='偶尔忘喘气:AwABCAEABAoAAA==.',['�']='八奈见杏菜丶:AwAECAYABRQCBgAEAQhIEQAWjcUABRQABgAEAQhIEQAWjcUABRQAAQcAKokICAIABRQ=.',['�']='啊五环:AwAECAQABRQAAA==.',['�']='大块魔光碎片:AwABCAEABAoAAA==.大坦魔光碎片:AwACCAIABRQAAA==.大炮可可:AwAECAQABRQAAA==.太阳神之女:AwAGCAkABAoAAA==.失误术:AwAICAUABAoAAA==.',['�']='奈特麦尔:AwAECAQABRQAAA==.',['�']='小母牛坐火箭:AwABCAEABAoAAA==.小箜箜:AwAECAQABRQAAQUAQ8QICAcABRQ=.',['�']='岳母大人:AwAICAgABAoAAQgAM3YICAkABRQ=.',['�']='恐怖小说:AwAGCAQABAoAAA==.',['�']='感灬恩:AwACCAIABAoAAA==.',['�']='我来抗揍:AwACCAcABRQCCQACAQhXEgA/s7YABRQACQACAQhXEgA/s7YABRQAAA==.',['�']='扶器:AwADCAMABAoAAA==.',['�']='拉米亚斯:AwAECAEABRQAAA==.',['�']='未语人先羞:AwACCAIABAoAAA==.',['�']='柳如烟:AwAGCAYABAoAAA==.',['�']='桉树叶:AwAICAgABAoAAA==.',['�']='治安战:AwAECAQABRQAAA==.',['�']='法外柔情:AwAECAQABAoAAA==.',['�']='清水加冰:AwABCAEABAoAAA==.',['�']='满月寂照:AwADCAMABRQAAA==.',['�']='灬彼得堡:AwAGCAYABAoAAA==.',['�']='爱上夏天的蕓:AwAECAQABRQAAA==.爱高山:AwABCAEABAoAAA==.爺们:AwAECAQABAoAAA==.',['�']='玄幻小说:AwAFCAUABAoAAA==.王珊琪女王:AwAFCAIABAoAAA==.',['�']='璋琅:AwABCAEABAoAAA==.',['�']='秦少游:AwAGCAsABAoAAA==.',['�']='索瑞森大帝:AwACCAIABRQAAA==.',['�']='苏摩丶:AwAECAMABRQAAA==.',['�']='藏藏:AwAGCA4ABAoAAA==.',['�']='迈克沃尔夫:AwAFCAUABAoAAA==.',['�']='速猛萨:AwAECAgABRQCBgAEAQh5DgAdeNgABRQABgAEAQh5DgAdeNgABRQAAA==.',['�']='随便玩玩儿:AwACCAQABRQCAQAIAQgoMABKz0ECBAoAAQAIAQgoMABKz0ECBAoAAA==.',['�']='韭菜炒鸡蛋:AwADCAoABRQCAgADAQjrCwAtfbgABRQAAgADAQjrCwAtfbgABRQAAA==.',['�']='黑棺丶:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end