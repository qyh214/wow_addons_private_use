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
 local lookup = {'Druid-Balance','Mage-Fire','Unknown-Unknown','Druid-Restoration','Priest-Shadow','Priest-Holy',}; local provider = {region='CN',realm='奎尔丹纳斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asunasama:AwACCAIABRQAAA==.',Cr='Crazed:AwACCAEABRQAAA==.',Mo='Moonn:AwAFCAwABAoAAA==.',Sy='Sylverster:AwACCAIABAoAAA==.',['�']='冰冷的小米:AwAECAQABAoAAA==.',['�']='凯迪不拉客:AwADCAMABAoAAA==.',['�']='努尔哈茨:AwABCAEABRQAAA==.',['�']='古辰海:AwAECAEABRQAAA==.只管卖萌:AwABCAEABRQAAA==.',['�']='吕布:AwABCAEABRQAAA==.吾不是咕咕呀:AwAICAgABAoAAQEAQIkGCAUABRQ=.',['�']='塔达:AwAICA0ABAoAAA==.',['�']='娘娘千岁:AwABCAEABRQAAA==.',['�']='小坏东西:AwABCAEABRQAAA==.',['�']='岁岁大王:AwABCAEABRQAAA==.',['�']='希儿之怒:AwAICAgABAoAAA==.',['�']='悠悠起很晚:AwADCAUABRQCAgADAQhGEAA4s/YABRQAAgADAQhGEAA4s/YABRQAAA==.',['�']='戎马一身:AwADCAMABAoAAA==.',['�']='暗夜水蜜桃:AwAECAEABAoAAA==.',['�']='木易京日天:AwADCAMABAoAAQMAAAACCAMABRQ=.',['�']='杯莫停:AwACCAMABRQAAA==.',['�']='榴莲乄千层:AwAICAgABAoAAA==.',['�']='混子不混:AwAFCAUABAoAAA==.',['�']='灰飞德熊:AwAICAgABAoAAA==.灼眼的夏亚:AwAHCAcABAoAAA==.',['�']='牛小胖:AwADCAUABRQDAQADAQiMCgBN2v4ABRQAAQADAQiMCgBN2v4ABRQABAACAQjADwA254IABRQAAQMAAAAGCAQABRQ=.',['�']='猫猫:AwAECAQABAoAAA==.',['�']='白豌豆:AwABCAEABRQAAA==.',['�']='破空大月:AwACCAIABRQAAA==.',['�']='粉嘟嘟小仙女:AwAECAcABRQCAgAEAQjtHQAPSLgABRQAAgAEAQjtHQAPSLgABRQAAA==.',['�']='缇宝:AwACCAMABRQAAA==.',['�']='自愚自乐:AwAECAoABRQDBQAEAQi9CQA6P/IABRQABQAEAQi9CQA6P/IABRQABgACAQiGEgAdTH4ABRQAAA==.',['�']='舞夜悠靈:AwABCAEABRQAAA==.',['�']='芒果乄千层:AwAICAgABAoAAA==.花言花:AwABCAIABAoAAA==.',['�']='苍穹丶无垠:AwAECAQABRQAAA==.苍穹之兵火:AwACCAIABAoAAA==.',['�']='觉非:AwAECAQABAoAAA==.',['�']='赵我说的做:AwACCAIABRQAAA==.',['�']='迷虹:AwADCAMABAoAAA==.追风赶月:AwAGCAYABRQDAQAGAQiaAwBI1DoBBRQAAQAEAQiaAwBZhDoBBRQABAACAQjABgBfAeEABRQAAQQAPyYICAsABRQ=.',['�']='阿纳拉克:AwAGCAcABAoAAA==.',['�']='陈書:AwABCAEABRQAAA==.',['�']='霓虹:AwAECAkABAoAAA==.',['�']='鹿王河:AwACCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end