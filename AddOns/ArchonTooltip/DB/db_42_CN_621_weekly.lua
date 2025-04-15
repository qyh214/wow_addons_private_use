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
 local lookup = {'Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Arms','Warrior-Fury','Shaman-Enhancement','Druid-Restoration','Mage-Fire','Paladin-Holy','Paladin-Protection','Mage-Frost','Unknown-Unknown','Druid-Balance','Warrior-Protection','Hunter-Survival','Rogue-Subtlety','Rogue-Assassination','Druid-Guardian',}; local provider = {region='CN',realm='基尔加丹',name='CN',type='weekly',zone=42,date='2025-04-14',data={Be='Benfly:AwACCAIABAoAAA==.',Gr='Grievous:AwAICB0ABAoCAQAIAQiEEQBfFsECBAoAAQAIAQiEEQBfFsECBAoAAA==.',Ho='Hongdie:AwADCAsABRQDAgADAQhdAgAkwOcABRQAAgADAQhdAgAkwOcABRQAAwABAQgIIwAqmD4ABRQAAA==.',Hu='Huangkai:AwAICBEABAoAAA==.',Ku='Kuia:AwAECAQABAoAAA==.',Me='Megademon:AwACCAIABRQCBAAIAQgtLwA2k9ABBAoABAAIAQgtLwA2k9ABBAoAAA==.',Sd='Sd:AwAECAQABAoAAA==.',Sr='Sront:AwAICAgABAoAAA==.',St='Steelswarm:AwABCAIABRQDBQAIAQilJgBNjD0CBAoABQAIAQilJgBEjD0CBAoABgAHAQhuEwBOfAQCBAoAAA==.',Tt='Tturpin:AwADCAMABAoAAA==.',Us='Ushi:AwACCAIABRQAAA==.',Ye='Yeacion:AwAECAQABAoAAA==.',Zh='Zhldkt:AwADCAMABAoAAA==.',['�']='一只格格巫:AwAECAQABRQAAA==.一煜祺一:AwACCAIABRQAAA==.不喝假酒:AwACCAMABRQAAA==.不是虚胖:AwAICAIABAoAAA==.不要放弃吃药:AwABCAIABRQCBwAIAQgMEwBMYkgCBAoABwAIAQgMEwBMYkgCBAoAAA==.丶瞳话中的晴:AwAGCAQABRQAAA==.',['�']='乌龟骑士:AwAICAgABAoAAA==.',['�']='五块卵石:AwACCAMABRQECAAIAQhTDwBW22ECBAoACAAIAQhTDwBSw2ECBAoACQAGAQglFQBIGZMBBAoACgACAQh0KwAprYIABAoAAA==.',['�']='代号灬阿瑞斯:AwACCAQABRQAAA==.仰望丶星辰:AwAFCAUABAoAAA==.',['�']='保安丶:AwAECAYABRQDCwAEAQhuBQBSRNgABRQADAAEAQhbDAAzuPkABRQACwACAQhuBQBikdgABRQAAA==.',['�']='兔子家的小德:AwAFCAUABAoAAA==.八六上山了:AwAECAQABAoAAA==.',['�']='冥灬天天:AwACCAIABAoAAA==.',['�']='初夏夜未央:AwAECAQABRQAAA==.',['�']='劣白白:AwADCAMABAoAAA==.',['�']='勒戈拉斯:AwAHCAwABAoAAA==.',['�']='化骨绵羊:AwADCAcABAoAAA==.',['�']='原神鸣潮高手:AwAICBoABAoCBwAIAQjSHABAhAUCBAoABwAIAQjSHABAhAUCBAoAAA==.',['�']='古日塔嫚之花:AwAICBkABAoCBwAIAQh6GgBAPRQCBAoABwAIAQh6GgBAPRQCBAoAAA==.',['�']='喜羊羊:AwAGCAYABAoAAA==.',['�']='回家吃饭:AwACCAMABRQDDQAIAQgnIgAgHJIBBAoADQAIAQgnIgAgHJIBBAoABwAGAQhlbgANZcQABAoAAA==.',['�']='夜东篱:AwAICAsABAoAAA==.大米霸霸:AwABCAIABRQCBAAIAQjtCgBZu7wCBAoABAAIAQjtCgBZu7wCBAoAAA==.天命人:AwAECAQABRQAAA==.',['�']='奈扎雷克原罪:AwAECAIABRQAAA==.奶鸡的龙巴:AwACCAIABAoAAA==.',['�']='娜塔亚:AwAICBUABAoDBQAIAQgaFQBW7ZUCBAoABQAIAQgaFQBW7ZUCBAoABgACAQhbbQAY5TMABAoAAA==.',['�']='安琪儿的微笑:AwAECAQABRQAAA==.安琪儿的眼泪:AwAECAQABRQAAQ4AKncGCAoABRQ=.审判者:AwAGCAYABAoAAA==.',['�']='寒霜永恒伤感:AwAECAQABRQAAA==.',['�']='尛手微凉:AwADCAMABAoAAA==.',['�']='应天风:AwACCAIABAoAAQ8AQ7cECAYABRQ=.',['�']='廿小柒:AwAECAgABAoAAA==.',['�']='張豌豆:AwAICBQABAoDBQAIAQgraQAqBkQBBAoABQAIAQgraQAqBkQBBAoABgABAQg8egAA3QwABAoAAA==.',['�']='忆无心:AwAGCAYABAoAAA==.',['�']='愤怒的小桃子:AwACCAIABRQAAA==.愤怒的小葫芦:AwACCAIABRQAAA==.',['�']='懒羊羊:AwAICBcABAoCEAAIAQgNDwA3cuQBBAoAEAAIAQgNDwA3cuQBBAoAAA==.',['�']='我好像迷路了:AwAICAgABAoAAQUAPf8GCAkABRQ=.',['�']='承歌:AwACCAIABRQAAA==.',['�']='掂过碌蔗:AwAGCBQABAoDEAAGAQg3KAArQOMABAoAEAAFAQg3KAAszOMABAoAEQAGAQhOKQAgY90ABAoAAA==.',['�']='支持手艺人:AwAFCAUABAoAAA==.',['�']='无敌大炉石:AwAHCAEABAoAAA==.无敌小钢炮:AwAECAQABRQDDwAIAQgwDgBXj5kCBAoADwAIAQgwDgBT+5kCBAoAEgAIAQhcGQBSlhQCBAoAAA==.',['�']='星辰之刄:AwAGCAYABAoAAA==.',['�']='普希尼亚斯:AwABCAIABRQAAA==.',['�']='月羽风行者:AwABCAEABAoAAA==.',['�']='李达康:AwAECAQABAoAAA==.',['�']='格格武六月:AwAECAQABRQAAA==.',['�']='残酷的大表哥:AwAGCAUABAoAAA==.',['�']='每天喝两杯:AwACCAIABRQAAA==.',['�']='永遠的回憶:AwACCAMABAoAAA==.',['�']='污皇大帝:AwAGCAYABAoAAA==.汤圆你别跑:AwAGCAYABAoAAA==.',['�']='沐潆翾:AwAICA8ABAoAAA==.沸羊羊:AwAGCA0ABAoAAQ4APyYICAsABRQ=.油膩的師姐:AwAECAQABAoAAA==.',['�']='泛滥滴小年轻:AwAICAYABAoAARMAAAAGCAQABRQ=.泥潭捞月光:AwABCAEABRQDFAAIAQjcHABFIzsCBAoAFAAIAQjcHABFIzsCBAoADgAHAQg+HABFR7gBBAoAAA==.',['�']='涯岸:AwACCAIABRQAAA==.',['�']='漫卷忧尘:AwAGCAsABAoAAA==.漫天叶纷飞:AwAHCBcABAoDEgAHAQjpOwAm9koBBAoAEgAHAQjpOwAm9koBBAoADwACAQhOlAAG8SwABAoAAA==.',['�']='爪子东西:AwAECAQABRQAAA==.',['�']='猎丶人:AwADCAEABAoAAA==.',['�']='瑞亜:AwAECAEABAoAAA==.',['�']='瓦奥莱特:AwAICAsABAoAAA==.',['�']='破晓晨光:AwAECAUABRQDCwAIAQgrEQA8qgwCBAoACwAIAQgrEQA8qgwCBAoAFQADAQjALQAi82wABAoAAA==.破灭的怀念:AwAGCAQABRQAAA==.',['�']='磷叶石:AwACCAMABRQDBQAIAQhtHABSUG8CBAoABQAIAQhtHABSUG8CBAoAFgACAQgfFwA7g1kABAoAAA==.',['�']='神将飞蓬:AwABCAEABRQDFwAIAQjUCwA94icCBAoAFwAIAQjUCwA94icCBAoAGAACAQhvPgAQaDsABAoAAA==.',['�']='翔地天空:AwAECAgABRQCCwAEAQjVAwA7aAIBBRQACwAEAQjVAwA7aAIBBRQAAA==.',['�']='老白已戒酒丶:AwADCAMABRQAAA==.',['�']='芦笙:AwABCAEABRQCGQAIAQjBBgA9Id8BBAoAGQAIAQjBBgA9Id8BBAoAAA==.',['�']='苏筱叶:AwAICAwABAoAAA==.',['�']='茉莉乌龙茶:AwACCAIABRQAAA==.',['�']='蓝篮路:AwABCAEABRQCFAAIAQhIFQBOJGwCBAoAFAAIAQhIFQBOJGwCBAoAAA==.',['�']='誓约守护者:AwAICAgABAoAAA==.',['�']='让我躺着:AwAFCAUABAoAAA==.',['�']='象饼干:AwABCAIABRQCAQAIAQgDCABey/ECBAoAAQAIAQgDCABey/ECBAoAAA==.',['�']='追寻回忆:AwAECAQABAoAAA==.',['�']='部落頭號通緝:AwAICBUABAoCEAAIAQidEAA1wc8BBAoAEAAIAQidEAA1wc8BBAoAAA==.',['�']='银河星落:AwAICAQABAoAAA==.',['�']='阿牛弟:AwACCAMABAoAAA==.',['�']='霍比特矮子:AwAGCAoABRQCCAAGAQg5AQAnEp4BBRQACAAGAQg5AQAnEp4BBRQAAQgAXXIHCAcABRQ=.',['�']='风烟愺树:AwABCAEABRQCCwAIAQg7DgBD3CsCBAoACwAIAQg7DgBD3CsCBAoAAA==.飞虎神鹰:AwAGCAkABAoAAA==.',['�']='黎明使者:AwAGCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end