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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Blood','DeathKnight-Frost','Druid-Balance','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Paladin-Holy','Priest-Discipline','Mage-Frost','Unknown-Unknown','DemonHunter-Havoc','DeathKnight-Unholy','Priest-Shadow','Druid-Restoration','Priest-Holy','Monk-Windwalker','Monk-Mistweaver','Mage-Fire','Mage-Arcane','Warrior-Arms',}; local provider = {region='CN',realm='雷霆之怒',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ar='Arronshi:AwAICAgABAoAAA==.',['�']='上帝的幻影:AwACCAIABRQAAA==.与子彤鉴:AwACCAQABRQDAQAIAQjrAABg6QgDBAoAAQAIAQjrAABg2wgDBAoAAgAEAQheggBbIwkBBAoAAA==.',['�']='乌巭星魔:AwAICAIABAoAAA==.乐融融的梦:AwABCAEABAoAAA==.乳酪戯芢:AwACCAQABRQDAwAIAQinMAAWZ+0ABAoAAwAIAQinMAAVMu0ABAoABAACAQgmKwAYV0oABAoAAA==.',['�']='兜里有熊:AwACCAYABRQCBQACAQimHwAkIZMABRQABQACAQimHwAkIZMABRQAAA==.',['�']='再睡亿分钟:AwACCAQABRQCBgAIAQiwdQAiOo8BBAoABgAIAQiwdQAiOo8BBAoAAA==.冰河葬寒心:AwAICAkABAoAAA==.冰落无心:AwACCAIABRQAAA==.',['�']='别用鼠标点我:AwAECAQABRQAAA==.',['�']='勤勤佳人:AwACCAQABAoAAA==.',['�']='化劲马保国:AwADCAQABRQEBwAIAQgOCwBRhA8CBAoABwAHAQgOCwBRUA8CBAoACAACAQgvZQBVTsIABAoACQABAQhkNwBATk8ABAoAAA==.',['�']='夢蝶:AwACCAQABRQCCgAIAQgtCgBD4i4CBAoACgAIAQgtCgBD4i4CBAoAAA==.天降胖贼:AwAECAIABRQAAA==.',['�']='小手遮天:AwABCAEABRQCBgAIAQjKaQAlyKoBBAoABgAIAQjKaQAlyKoBBAoAAA==.小胖熊:AwAECAQABRQAAA==.尐了辣了椒:AwAECAQABRQAAA==.',['�']='巧克力甜甜圈:AwAECAQABRQAAA==.',['�']='幸玉强:AwAECAQABRQAAA==.',['�']='弑壆霊韵:AwAFCAgABAoAAA==.',['�']='很御姐:AwACCAIABRQAAA==.很犀利:AwACCAYABRQCAgACAQh6IwA9EaIABRQAAgACAQh6IwA9EaIABRQAAA==.德菜兼备:AwABCAEABAoAAA==.',['�']='愤怒的影魔:AwAECAQABRQAAA==.',['�']='憨憨是只猫:AwAECAsABRQCCwAEAQhiBABZHS4BBRQACwAEAQhiBABZHS4BBRQAAA==.',['�']='我来抱抱你:AwAICAgABAoAAA==.我爱倩倩:AwAICBYABAoCDAAIAQhTSwAYmBABBAoADAAIAQhTSwAYmBABBAoAAA==.',['�']='抓只大老虎:AwAECAQABRQAAQ0AAAAICAQABRQ=.',['�']='时代:AwABCAEABAoAAA==.',['�']='最后曙光:AwAICAgABAoAAA==.朢夢鑽實:AwADCAcABAoAAA==.',['�']='柔情如此似火:AwAECAcABRQCDgAEAQgIDgA9T/cABRQADgAEAQgIDgA9T/cABRQAAA==.',['�']='橙花:AwAECAUABRQCDwAEAQiTDwAttN8ABRQADwAEAQiTDwAttN8ABRQAAA==.',['�']='正义芝士:AwABCAEABAoAARAAOp8ECAsABRQ=.',['�']='残风墨月:AwACCAQABRQDEQAIAQgyEABG1C4CBAoAEQAIAQgyEABG1C4CBAoABQABAQgStQAn3CgABAoAAA==.',['�']='毛毛大网红:AwABCAEABRQAAA==.',['�']='汐语:AwACCAIABRQAAA==.',['�']='清风不解风情:AwAFCAgABAoAAA==.温柔点:AwAICAgABAoAAA==.',['�']='潇洒哥:AwABCAEABAoAAA==.潶社会:AwACCAMABRQCDwAIAQgqOQAzxKYBBAoADwAIAQgqOQAzxKYBBAoAAA==.',['�']='灬傲丶丗灬:AwAICAgABAoAAA==.灬烈焰涂鸦灬:AwADCAMABAoAAA==.',['�']='牛逼:AwAECAQABAoAAA==.',['�']='真的好想要:AwAICAgABAoAAA==.',['�']='离人不挽丶:AwAECAQABRQAARIAPuAGCAcABRQ=.',['�']='程橙橙丶:AwAECAQABRQAAA==.',['�']='粉粉的小白脸:AwAGCA0ABAoAAA==.',['�']='红烧丸子:AwACCAQABRQDEwAIAQgDCwBO7IoCBAoAEwAIAQgDCwBO7IoCBAoAFAADAQjdUgBAJNMABAoAAA==.',['�']='耐法兰圣辉:AwABCAEABRQAAA==.耐法兰星陨:AwACCAIABRQAAA==.',['�']='肉冻大魔王:AwACCAUABRQCAwAIAQiIGwAwyJIBBAoAAwAIAQiIGwAwyJIBBAoAAA==.',['�']='芜菁沙袋:AwAECAQABRQAAA==.花落:AwACCAYABRQCCAACAQjKGQA+DZAABRQACAACAQjKGQA+DZAABRQAAA==.',['�']='莫得感情:AwABCAEABRQCBgAIAQhfZAAvybYBBAoABgAIAQhfZAAvybYBBAoAAA==.莳翎之翼:AwAECAQABAoAAA==.',['�']='萨哈哈:AwABCAEABAoAAA==.',['�']='董棒棒:AwADCAMABRQAAA==.',['�']='蕾姆:AwAGCAwABAoAAA==.',['�']='訷話丶凹凸曼:AwACCAIABRQAARMARhQICAUABRQ=.',['�']='赫利俄斯:AwACCAIABRQAAA==.',['�']='醒着梦游:AwABCAEABAoAAA==.',['�']='钱兔无量丶:AwAECAQABRQAAA==.',['�']='阿克蒙惪:AwACCAQABRQEDAAIAQhdAgBhhAEDBAoADAAIAQhdAgBhhAEDBAoAFQAGAQiYLwBQIdMBBAoAFgACAQjaFABgj20ABAoAAA==.',['�']='颖宝:AwACCAIABAoAAA==.',['�']='首席杏仁学家:AwACCAMABRQCFwAHAQjsDQBRpzgCBAoAFwAHAQjsDQBRpzgCBAoAAA==.',['�']='魂牵的小猎:AwACCAIABRQAAA==.',['�']='麽麽哒丶:AwAECAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end