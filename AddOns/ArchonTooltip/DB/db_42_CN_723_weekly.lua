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
 local lookup = {'Evoker-Preservation','Paladin-Retribution','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Holy','Shaman-Restoration','Shaman-Elemental','Monk-Windwalker','Druid-Feral','Druid-Restoration','Druid-Balance','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Paladin-Holy','Priest-Discipline',}; local provider = {region='CN',realm='永夜港',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adiosamigo:AwAECAMABRQAAA==.',Ge='Gertrude:AwACCAIABRQAAA==.',Jy='Jyona:AwACCAYABRQCAQACAQiFAgBgNtsABRQAAQACAQiFAgBgNtsABRQAAQIARVgDCAcABRQ=.',Le='Leslie:AwAICAYABAoAAQMAAAAGCAQABRQ=.',Ma='Marpeter:AwAICAUABAoAAA==.',Ri='Rigel:AwAICAgABAoAAA==.',St='Starkitten:AwAHCAcABAoAAA==.',Su='Suntory:AwACCAQABRQAAA==.',Th='Thoughts:AwAICBgABAoDBAAIAQjWPQAo3IkBBAoABAAIAQjWPQAoB4kBBAoABQABAQjiYQAT7iAABAoAAA==.',['�']='临行莫回头:AwAICAcABAoAAA==.丿蘩丶:AwAECAMABRQAAA==.',['�']='仔仔:AwAICAsABAoAAA==.',['�']='伊诺鲁克:AwACCAIABRQAAA==.',['�']='偷偷打断:AwAECAQABRQAAA==.',['�']='僧傲天:AwAFCAUABAoAAA==.',['�']='千山丿鸟飞绝:AwAFCAUABAoAAA==.千山鸟飞绝:AwAECAQABRQAAA==.',['�']='可我想你了:AwADCAEABAoAAA==.',['�']='咕咕在输出了:AwABCAIABRQAAA==.',['�']='噼梨吧啦:AwACCAIABAoAAA==.',['�']='圣光永存:AwAECAEABAoAAA==.',['�']='夜君:AwABCAEABRQAAA==.天天恋佳佳:AwAECAUABRQCBgAEAQiUAwBAKBABBRQABgAEAQiUAwBAKBABBRQAAA==.',['�']='寒山远:AwACCAIABRQAAA==.',['�']='彼岸花:AwACCAMABRQAAA==.',['�']='憨豆:AwAHCAUABAoAAA==.',['�']='明天君:AwABCAEABRQDBwAIAQh2IgA8l+QBBAoABwAIAQh2IgA8l+QBBAoACAAGAQgEHgBUGswBBAoAAA==.明月如雪:AwAECAQABRQAAQkAIYsICAYABRQ=.星辰之月:AwAECAQABAoAAA==.星辰之耀:AwAFCAUABAoAAA==.',['�']='椎名林檎:AwACCAQABRQECgAIAQg0AwBdEq0CBAoACgAIAQg0AwBdEq0CBAoACwAHAQisJAA4IHwBBAoADAABAQjOqQAYnTAABAoAAA==.',['�']='沙漠中的月亮:AwAECAIABRQAAA==.',['�']='波本威士忌:AwACCAIABRQAAA==.',['�']='清源妙道真君:AwABCAEABRQCDQAIAQgXCwBRSIQCBAoADQAIAQgXCwBRSIQCBAoAAA==.',['�']='灼眼灵:AwAECAQABRQAAA==.',['�']='熊小胖:AwAICAgABAoAAA==.',['�']='爱神黑悟空:AwACCAIABAoAAA==.',['�']='狂奔的人字拖:AwACCAIABRQAAA==.',['�']='玛布鲁:AwACCAIABRQAAQ4ALloHCAYABRQ=.',['�']='珍妮玛:AwAECAgABRQCDgAEAQg6BgBRjQ8BBRQADgAEAQg6BgBRjQ8BBRQAAA==.',['�']='疏影残月:AwAECAQABRQAAA==.',['�']='白水豆腐:AwAFCAMABAoAAA==.',['�']='神仙也无敌:AwABCAEABAoAAA==.',['�']='紗音:AwACCAQABRQAAA==.紫色心情:AwAECAkABRQDCAAEAQhYBABTKQIBBRQACAAEAQhYBABTKQIBBRQABwADAQgQEAAU1s4ABRQAAA==.',['�']='红叶栖霞:AwAICAYABAoAAA==.红红的小熊:AwAICAEABAoAAA==.',['�']='舞後紅茶:AwAECAQABRQAAA==.',['�']='莉莉:AwACCAQABRQCAgAIAQirFgBZPqkCBAoAAgAIAQirFgBZPqkCBAoAAA==.',['�']='萨格丶:AwAGCAEABAoAAA==.',['�']='蘑菇雀:AwAGCAYABAoAAA==.',['�']='角海:AwAGCAEABAoAAA==.',['�']='请叫我圣炮哥:AwAICAwABAoAAA==.请叫我炮哥:AwAICBMABAoAAA==.',['�']='贴地飞行墩墩:AwAICAgABAoAAA==.',['�']='轩辕凤:AwAGCAIABAoAAA==.',['�']='迷梦沉沦:AwAHCAcABAoAAA==.',['�']='逄决:AwAECAgABRQCDwAEAQj5AgAYdc8ABRQADwAEAQj5AgAYdc8ABRQAAA==.',['�']='那个奶德:AwAECAQABRQAAA==.',['�']='钢蛋:AwAGCAYABAoAAA==.',['�']='阿斯特兰纳:AwAGCA4ABAoAAA==.阿满:AwACCAIABAoAAA==.阿蛮:AwACCAIABRQCEAAIAQhEBQBQVX0CBAoAEAAIAQhEBQBQVX0CBAoAAA==.阿里勃特大:AwAECAQABAoAAA==.',['�']='革音:AwAICAEABAoCEQABAQgZcAA6iFAABAoAEQABAQgZcAA6iFAABAoAAA==.',['�']='风乘:AwAICAYABAoAAA==.',['�']='高坂桐乃:AwACCAIABRQAAA==.',['�']='鲜蜜柠檬:AwAGCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end