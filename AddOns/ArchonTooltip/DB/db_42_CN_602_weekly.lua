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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Mage-Arcane','Mage-Fire','DemonHunter-Havoc','DemonHunter-Vengeance','Paladin-Retribution','Warlock-Affliction','Warlock-Destruction','Warrior-Fury','Warrior-Arms','Hunter-Marksmanship','Mage-Frost','Priest-Discipline','Unknown-Unknown','Hunter-BeastMastery',}; local provider = {region='CN',realm='厄祖玛特',name='CN',type='weekly',zone=42,date='2025-04-14',data={Av='Averl:AwAICBAABAoAAA==.',Bo='Bottega:AwAECAQABAoAAA==.',Ca='Cancanneed:AwACCAQABRQAAA==.',Eu='Eurek:AwACCAIABRQAAA==.',Ge='Getone:AwAHCAwABAoAAA==.',Jm='Jmemory:AwABCAEABRQAAA==.',La='Ladrcd:AwAGCAsABAoAAA==.Laity:AwAICAwABAoAAA==.',Po='Posthaste:AwAECAYABRQDAQAEAQj7DAAvDeUABRQAAQAEAQj7DAAtZuUABRQAAgACAQg3EgA7K4YABRQAAA==.',Sa='Sandalwood:AwAGCAYABRQDAwAGAQjcAAA3BM8ABRQABAAEAQjCDABGBwYBBRQAAwACAQjcAAAggM8ABRQAAA==.',['�']='一刀龙爷:AwAECAYABAoAAA==.一眼顶真:AwAGCBEABAoAAA==.万姩三千点:AwAGCAYABAoAAA==.下任部落酋长:AwAICBcABAoDBQAIAQjfSgAoI00BBAoABQAHAQjfSgAoA00BBAoABgAIAQjyKwAVaPMABAoAAA==.不亏就是赚:AwADCAMABAoAAQEAIpEECAUABRQ=.东方树叶:AwADCAMABRQAAA==.丨醉舞倾城丶:AwAHCAkABAoAAA==.',['�']='乎乎爸爸:AwAGCAIABRQAAA==.九黎:AwAECAQABRQAAA==.',['�']='六十六号工地:AwACCAIABAoAAA==.',['�']='刘财主丶:AwAICBEABAoAAQUAQD8GCAoABRQ=.',['�']='反手放狗:AwAICAgABAoAAA==.',['�']='名字丶孤寒:AwAICAYABAoAAA==.',['�']='咪猪:AwADCAMABAoAAA==.',['�']='哎嘿就是玩:AwADCAIABRQCBwAIAQjILQBNw0oCBAoABwAIAQjILQBNw0oCBAoAAA==.',['�']='圣丶光:AwAECAEABAoAAA==.地狱撕裂者:AwADCAMABAoAAA==.',['�']='壹厘蛋:AwACCAIABRQAAA==.',['�']='大空异:AwAECAIABRQAAA==.',['�']='宇翔呆呆:AwABCAEABAoAAA==.',['�']='射普琴科:AwAICAgABAoAAA==.小伊万:AwAECAkABRQDCAAEAQjRAQBXBCkBBRQACAAEAQjRAQBXBCkBBRQACQABAQjrJQBDw0AABRQAAQkASvQICBMABRQ=.小牛带花:AwABCAEABRQAAA==.尛筱蛋:AwAECAQABAoAAA==.',['�']='山海有鸣:AwAICAgABAoAAA==.',['�']='年轻的加摩尔:AwAECAQABRQAAA==.',['�']='恶魔去哪了:AwADCAMABAoAAA==.',['�']='想个好名难:AwAECA0ABRQDCgAEAQiQBgBG/BsBBRQACgAEAQiQBgBFyhsBBRQACwABAQhLEQAuv1UABRQAAA==.',['�']='我不是死神丶:AwAICAgABAoAAA==.',['�']='手段:AwADCAMABRQCCgAIAQhZDQBP/YkCBAoACgAIAQhZDQBP/YkCBAoAAA==.托马斯旋:AwAHCA4ABAoAAA==.',['�']='把头埋低:AwAGCAYABAoAAQwAWDwDCAgABRQ=.',['�']='无与伦比:AwADCAIABAoAAA==.',['�']='晖哥真是帅:AwAECAgABRQDDQAEAQgBBwA0VNgABRQADQADAQgBBwA0VNgABRQABAABAQhdOAAAAAAABRQAAA==.',['�']='月光寒:AwAECAYABRQCDgAEAQjtBQBPdA0BBRQADgAEAQjtBQBPdA0BBRQAAA==.',['�']='梦山狐影:AwAECAUABAoAAA==.梨噗:AwAICAIABAoAAA==.',['�']='武凡达:AwABCAEABRQAAA==.',['�']='殇丶木木:AwAECAQABAoAAA==.',['�']='流年淡漠红尘:AwAECAQABRQAAA==.浅末丨年華:AwAICAQABAoAAA==.',['�']='淡淡的仙儿:AwAFCAUABAoAAA==.',['�']='火爆小腰花:AwAECAUABAoAAA==.',['�']='焮焮丶最可爱:AwAFCAUABAoAAA==.',['�']='熊摆摆:AwADCAMABRQAAA==.',['�']='爆裂黎明:AwABCAEABAoAAA==.爲妳灬疯狂:AwAECAQABAoAAA==.',['�']='狂暴熊熊:AwAECAQABRQAAA==.',['�']='王小丹:AwADCAMABAoAAQ8AAAAGCAMABRQ=.',['�']='甘木槿:AwAHCAcABAoAAA==.',['�']='百变神牛:AwABCAEABAoAAA==.百里东君:AwAGCAEABAoAAA==.',['�']='眼罩:AwAICBEABAoAAA==.',['�']='碎蛋之击丶:AwAGCAYABAoAAA==.',['�']='神来气旺:AwABCAEABRQAAQwAWDwDCAgABRQ=.',['�']='紅蓮:AwACCAIABAoAAA==.',['�']='纠结的小熊猫:AwAECAQABAoAAA==.',['�']='练习两年了半:AwACCAIABRQAAA==.练习九百多天:AwAGCAkABAoAAA==.经典小傻嫚:AwABCAEABRQAAA==.',['�']='臻纯牛奶:AwAGCAcABAoAAA==.',['�']='艾斯艾沐:AwAFCAEABAoAAA==.',['�']='花羔红点斑鲑:AwACCAQABAoAAA==.',['�']='莫莫伽:AwADCAgABRQDDAADAQiIAQBYPDMBBRQADAADAQiIAQBYPDMBBRQAEAACAQg3JAA9mJcABRQAAA==.',['�']='薄暮的艾琳娜:AwAICAgABAoAAA==.',['�']='血舞灬:AwAHCAcABAoAAA==.',['�']='西门四泉:AwAGCAYABAoAAA==.',['�']='言多必失啊:AwAGCAUABRQCAQAFAQgbBAAZriwBBRQAAQAFAQgbBAAZriwBBRQAAA==.',['�']='趙小灯:AwAFCAUABAoAAA==.',['�']='迎春花儿粉:AwAICAgABAoAAA==.',['�']='速趴塞呀仁:AwACCAMABRQAAA==.',['�']='遙控器:AwAGCAYABAoAAA==.',['�']='酷奇布拉达:AwAECAQABAoAAA==.酸酸梅子酒:AwAICA0ABAoAAA==.',['�']='锦瑟弦:AwABCAEABRQAAA==.',['�']='離落:AwABCAEABRQAAA==.',['�']='青涩小芒果:AwAICAgABAoAAA==.',['�']='骑小猪望夕阳:AwAICAYABAoAAA==.骑小猪等夕阳:AwABCAEABRQAAA==.骑小猪追夕阳:AwAECAQABRQAAA==.',['�']='魔法炮台:AwADCAsABRQDCQADAQiaFABKY6QABRQACQACAQiaFABKdaQABRQACAABAQh9FABKQFMABRQAAA==.',['�']='麥丶克基:AwAHCAEABAoAAA==.麥克丶基:AwABCAEABRQAAA==.',['�']='黛尔瑞丶落晨:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end