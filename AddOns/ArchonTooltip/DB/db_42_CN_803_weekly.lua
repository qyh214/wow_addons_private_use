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
 local lookup = {'Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','DeathKnight-Unholy','Warlock-Destruction','Warlock-Affliction','DemonHunter-Havoc','Paladin-Retribution','Shaman-Enhancement','Shaman-Restoration','Druid-Guardian','Druid-Feral','Druid-Balance','Druid-Restoration','Priest-Discipline','Priest-Shadow','Priest-Holy','Monk-Windwalker','Monk-Mistweaver','Paladin-Protection','Warlock-Demonology','Warrior-Fury','Mage-Fire','Mage-Frost','Shaman-Elemental',}; local provider = {region='CN',realm='艾萨拉',name='CN',type='weekly',zone=42,date='2025-04-15',data={De='Deathly:AwAECAQABRQAAA==.',Ha='Haloarcher:AwAGCAYABAoAAA==.Halolich:AwAICAgABAoAAA==.Halomana:AwAICAgABAoAAA==.',Je='Jev:AwAICAgABAoAAQEAAAAGCAMABRQ=.',Li='Lie:AwAFCAUABAoAAA==.Lies:AwAFCAkABAoAAA==.',Lr='Lr:AwAHCBkABAoEAgAHAQgpIgBHIJQBBAoAAgAHAQgpIgA8+pQBBAoAAwAFAQiRgAA7JQ4BBAoABAABAQjmHAAzDigABAoAAA==.',Mi='Miskye:AwAFCAQABRQAAQEAAAAGCAIABRQ=.',Ni='Nightreaver:AwAICBcABAoCBQAIAQi+FgBPB14CBAoABQAIAQi+FgBPB14CBAoAAQEAAAAECAIABRQ=.',Po='Po:AwAICA0ABAoAAA==.',Re='Reopenlolz:AwAICAoABAoAAA==.',St='Stanley:AwADCAcABRQDBgADAQgnGABJ3psABRQABgACAQgnGABEepsABRQABwABAQjZEwBUqGMABRQAAA==.',['�']='一夜骑九次:AwAICAkABAoAAA==.三重刘德华:AwADCAMABAoAAA==.不惑者:AwAGCAYABAoAAA==.丨瞎丨子丨:AwAGCBYABRQCCAAGAQjUAgAlTZcBBRQACAAGAQjUAgAlTZcBBRQAAA==.丿琳琅乀:AwAFCAcABAoAAA==.',['�']='亮仔无敌:AwADCAMABAoAAA==.亮坤:AwABCAEABRQAAA==.人间:AwAICAgABAoAAA==.',['�']='伊利莎白:AwAGCAYABAoAAA==.伊扎克斯:AwACCAQABRQAAA==.',['�']='你的小爷们:AwAICAYABAoAAA==.',['�']='依稀:AwAHCBAABAoAAA==.',['�']='光带闪电:AwAECAQABAoAAA==.兔兔吃蘑菇:AwAGCAYABAoAAA==.八剑初晴:AwAICA8ABAoAAA==.六号:AwAICAgABAoAAA==.兽血沸腾:AwAICAgABAoAAA==.',['�']='再小龙:AwAECAQABAoAAA==.冰雕猫:AwAGCAoABAoAAA==.冰餜:AwAICAgABAoAAA==.',['�']='准的一笔:AwADCAUABRQCAwACAQhAJwA2uJgABRQAAwACAQhAJwA2uJgABRQAAA==.',['�']='刈天之龙:AwAICA8ABAoAAA==.',['�']='千夜浮梦:AwAICAgABAoAAA==.千机蝶:AwABCAIABRQCCQAIAQiiZwAt7K8BBAoACQAIAQiiZwAt7K8BBAoAAA==.',['�']='后勤主管:AwAGCAIABRQAAA==.吻如双下雪:AwAGCAYABAoAAA==.',['�']='四季红:AwAFCAUABAoAAA==.',['�']='圣无尘:AwAECAIABRQAAA==.',['�']='夕丶芮:AwAICAcABAoAAA==.夜之絮语:AwABCAEABRQAAA==.夜杀加血:AwACCAIABAoAAA==.大灬板灬砖:AwAICAgABAoAAA==.大花:AwAGCAwABAoAAA==.',['�']='孓孑:AwAECAIABRQAAA==.',['�']='安娜罗曼诺娃:AwACCAUABRQDCgACAQjTEAAR0oIABRQACgACAQjTEAAR0oIABRQACwABAQjyLwAC+iwABRQAAA==.',['�']='小丑鱼:AwABCAEABAoAAA==.小熊焰焰:AwACCAIABRQFDAAIAQiwAQBZjMMCBAoADAAIAQiwAQBZjMMCBAoADQAEAQhQGQA22doABAoADgABAQgepwAxBEMABAoADwABAQivdQAr/D4ABAoAAA==.少御皇:AwAECAQABRQAAA==.',['�']='己陌丶虞姬:AwAECAUABRQDAwAEAQhqCwBWEhYBBRQAAwAEAQhqCwBWEhYBBRQAAgABAQjHGgAtrEwABRQAAA==.',['�']='常庆:AwAECAQABAoAAA==.',['�']='平静如水:AwAECAQABRQCCQAEAQg4CQBDnyEBBRQACQAEAQg4CQBDnyEBBRQAAA==.并非小甲:AwACCAUABRQCCAACAQgLIgAiN4sABRQACAACAQgLIgAiN4sABRQAAA==.',['�']='开心的圣光:AwAICAgABAoAAA==.强力三鞭丸:AwABCAEABRQCAwAIAQhHSgAsZLUBBAoAAwAIAQhHSgAsZLUBBAoAAA==.',['�']='彡清风思明月:AwACCAIABAoAAA==.',['�']='德芙:AwAICAgABAoAAA==.',['�']='我与天空比高:AwAGCAYABAoAAA==.我奶来了:AwAECAQABAoAAA==.我有小秘密:AwAICAgABAoAAA==.战复三队防骑:AwACCAIABAoAAA==.战复二队武僧:AwAECAMABRQCBgAIAQg5DwBKU2UCBAoABgAIAQg5DwBKU2UCBAoAAQYATegICAYABRQ=.战复四队萨满:AwAICAgABAoAAA==.战灬歌:AwAECAQABRQAAA==.',['�']='指导员:AwAICCAABAoEEAAIAQipLgApnkoBBAoAEAAHAQipLgAtsEoBBAoAEQAHAQgUMgAayCwBBAoAEgAIAQj3PQATdx0BBAoAAA==.指间的溫柔:AwAECAQABRQAAA==.',['�']='昆山玉:AwAICAgABAoAAA==.星星如画里:AwAFCAUABAoAAA==.春困秋乏:AwADCAEABAoAAA==.',['�']='晓月夜:AwAFCAkABAoAAA==.晚风心里吹:AwAECBIABRQCEQAEAQj+BABfrToBBRQAEQAEAQj+BABfrToBBRQAAA==.',['�']='月侠魅影:AwAECAQABRQAAA==.',['�']='杨影:AwAICAgABAoAAA==.板丶砖:AwAFCAUABAoAAA==.',['�']='枣哥强战:AwAECAQABAoAAA==.',['�']='柏翘:AwAHCAgABAoAAA==.',['�']='桔烟:AwABCAEABAoAAA==.',['�']='橘子汽水丶:AwAECAIABAoAAA==.橙心丨橙意:AwAICBQABAoDEwAIAQgKNwAUnR4BBAoAEwAHAQgKNwAXaB4BBAoAFAAGAQhhWAAU1r4ABAoAAA==.',['�']='此夜:AwABCAEABAoAAQEAAAAECAMABRQ=.',['�']='毛毛小狗:AwACCAMABRQDFQAIAQg7FwA0f5ABBAoAFQAIAQg7FwAzY5ABBAoACQAEAQgGHAEcRHcABAoAAA==.',['�']='汐芮:AwACCAIABAoAAA==.',['�']='沃舒古游侠:AwACCAIABRQAAA==.',['�']='泥头车小分队:AwAGCAkABAoAAA==.泥头车撞大运:AwADCAgABRQDBAADAQi5AAApwgEBBRQABAADAQi5AAApwgEBBRQAAgABAQgyHgAbkT8ABRQAAA==.',['�']='海棠花:AwABCAEABAoAAA==.',['�']='涅莫涅:AwAECAQABRQAAA==.',['�']='深淵回響:AwAICBgABAoCBQAIAQgWHwBKZCkCBAoABQAIAQgWHwBKZCkCBAoAAQUAPpAGCAgABRQ=.深院锁清秋:AwAECAIABRQAAA==.',['�']='清一色一条龙:AwAECAMABAoAAA==.清茶:AwAGCAoABRQEBwAGAQgQAQAvL0cBBRQABwAEAQgQAQAs2UcBBRQABgAEAQh1DQA1a+EABRQAFgACAQhMDAAt01oABRQAAA==.清风之影:AwAICAgABAoAAA==.温蒂:AwAECAcABAoAAA==.',['�']='灬角落安静灬:AwABCAEABRQAAA==.',['�']='燃燈:AwAGCAYABAoAAA==.',['�']='版本娘:AwAECAQABRQAAA==.',['�']='狗头萝莉:AwAICAgABAoAAA==.',['�']='猫扑的小螃蟹:AwABCAIABRQAAA==.猫本帕克维尔:AwAGCAgABRQCFwAEAQiECgBEewYBBRQAFwAEAQiECgBEewYBBRQAAA==.',['�']='瑾轩与瑕:AwAECAQABRQAAA==.',['�']='瓦立安:AwABCAEABAoAAA==.',['�']='百基拉:AwAGCAYABAoAAA==.',['�']='真瞎:AwADCAUABAoAAA==.',['�']='瞎混歸唻:AwABCAEABAoAAA==.瞎混歸来:AwAFCAUABAoAAA==.瞎混禅师:AwAECAQABAoAAA==.',['�']='破碎之花:AwADCAYABAoAAA==.',['�']='碍事梨:AwABCAEABRQDGAAIAQhPHwBITC4CBAoAGAAIAQhPHwBITC4CBAoAGQAEAQj5dAAUfIwABAoAAA==.',['�']='神之审判:AwAECAgABRQCCQAEAQhFHQAnFdwABRQACQAEAQhFHQAnFdwABRQAAREAFCYHCBEABRQ=.神之梦静:AwAICAgABAoAAA==.神圣风暴:AwAGCAwABAoAAA==.',['�']='秋夜丶:AwABCAEABAoAAA==.',['�']='稻五米:AwACCAIABRQAAA==.',['�']='简易:AwACCAIABRQAAA==.',['�']='红色跑车:AwAICAgABAoAAA==.约克十二世:AwADCAMABAoAAA==.',['�']='羊咩咩丶:AwADCAUABRQCAwADAQjcGwAfG88ABRQAAwADAQjcGwAfG88ABRQAAA==.',['�']='老牛:AwADCAQABAoAAA==.考尔快:AwAICA4ABAoAAA==.',['�']='色羽:AwADCAUABRQCCwADAQjqCABHbgEBBRQACwADAQjqCABHbgEBBRQAAQEAAAAECAMABRQ=.',['�']='茉莉二号:AwAICAgABAoAAA==.',['�']='蓝月亮:AwADCAMABAoAAA==.',['�']='虫博士:AwAECAMABRQAAA==.',['�']='赛默飞世尔:AwAFCAUABAoAAA==.',['�']='邪能噬者:AwAICAgABAoAAA==.',['�']='野蛮孩子:AwAECAQABAoAAA==.',['�']='钢弹姆:AwADCAMABRQAAA==.',['�']='长河落日圆:AwACCAIABRQAAQEAAAAGCAQABRQ=.',['�']='阿克的眼泪:AwAICB0ABAoEBgAIAQidLQBId6wBBAoABgAHAQidLQBCV6wBBAoAFgAGAQiBIAA7SkQBBAoABwADAQhvHwA+NtkABAoAAA==.阿法:AwAECAQABRQAAA==.',['�']='雅典学堂老饕:AwAGCAMABAoAAA==.雷霆与烈焰:AwAICBgABAoECgAIAQjzIwAi7YkBBAoACgAHAQjzIwAolIkBBAoACwAHAQgPVAAjLCEBBAoAGgADAQhFZQAT/mQABAoAAA==.',['�']='顶天立地:AwADCAMABAoAAA==.',['�']='风动忆流年:AwAHCAoABAoAAA==.风暴之灵:AwAGCAYABAoAAA==.',['�']='魂戒:AwAECAQABAoAAA==.',['�']='黑暗阴影丶煞:AwAECAUABAoAAA==.黑龙凯尔特:AwAICAgABAoAAA==.黑龙雨润春山:AwACCAIABRQAAA==.',['�']='龙丨神:AwABCAIABRQCFwAIAQisHwA11QYCBAoAFwAIAQisHwA11QYCBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end