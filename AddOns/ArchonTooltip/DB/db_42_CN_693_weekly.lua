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
 local lookup = {'Paladin-Holy','Paladin-Protection','Druid-Balance','Paladin-Retribution','DeathKnight-Blood','Unknown-Unknown','Shaman-Enhancement','Warrior-Fury','Warrior-Protection','Warlock-Destruction','Mage-Fire','Rogue-Subtlety','Rogue-Assassination','Mage-Frost','Hunter-BeastMastery','Shaman-Restoration','Hunter-Survival','Priest-Shadow','Hunter-Marksmanship','Warlock-Demonology','Warlock-Affliction','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Warrior-Arms','Evoker-Devastation','Evoker-Ranged',}; local provider = {region='CN',realm='提瑞斯法',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acolost:AwAECAwABRQDAQAEAQgYAwBInQUBBRQAAQAEAQgYAwBInQUBBRQAAgAEAQidBQA95d0ABRQAAA==.',Al='Alecaa:AwAECAQABRQAAA==.Aleka:AwAICAkABAoAAQMAQiQGCAoABRQ=.',Ay='Ayan:AwAICA4ABAoAAA==.',Be='Belial:AwAICAgABAoAAA==.',Bu='Bullimoes:AwABCAEABAoAAA==.',De='Deeparisen:AwAHCAcABAoAAA==.',Fu='Furrycon:AwAGCAwABAoAAA==.',Ga='Galinini:AwACCAIABRQAAA==.',Js='Jshtoday:AwAICAgABAoAAA==.',Ka='Kadles:AwACCAQABRQAAA==.',Le='Leaper:AwAHCA0ABAoAAA==.',Na='Nallra:AwAGCAYABAoAAA==.',Ne='Nellra:AwACCAIABRQAAA==.',Ni='Nickloues:AwAGCAYABAoAAA==.Niklaus:AwAICBAABAoAAA==.',Sa='Saintrow:AwAECAkABRQCBAAEAQhLCABTpyABBRQABAAEAQhLCABTpyABBRQAAA==.Say:AwADCAUABRQCBQADAQgEDQAorbAABRQABQADAQgEDQAorbAABRQAAQYAAAAGCAQABRQ=.',Wc='Wclovcm:AwAECAQABRQAAA==.',Wo='Wowgpo:AwACCAIABRQAAQcAS9AGCAoABRQ=.',['�']='一令二四:AwACCAIABRQAAA==.一個硬漢子:AwAICAgABAoAAQYAAAABCAEABRQ=.一布洛克斯一:AwACCAQABRQDCAAIAQjTKQAoL8QBBAoACAAIAQjTKQAnuMQBBAoACQAGAQjSIgAXG7YABAoAAA==.一永恒神话一:AwABCAEABAoAAA==.七荒:AwAECAEABRQAAA==.三刀流丶:AwACCAIABRQAAA==.三百:AwAGCAwABAoAAA==.三秋叶:AwAECAsABAoAAA==.三角函数:AwABCAEABRQCCgAIAQjeMgAoY4sBBAoACgAIAQjeMgAoY4sBBAoAAA==.不讲伍德:AwAGCAYABAoAAA==.丶划水大师:AwAGCAwABRQCCwAGAQiSGQBLRtQABRQACwAGAQiSGQBLRtQABRQAAA==.丶布冯:AwAGCAYABAoAAA==.丸皮思丶丨:AwABCAEABAoAAA==.',['�']='乐乐横扫饥饿:AwACCAEABRQAAA==.',['�']='亵渎:AwACCAIABRQAAA==.人面兽心:AwAICBgABAoCCAAIAQjqDgBL4nwCBAoACAAIAQjqDgBL4nwCBAoAAA==.',['�']='仁丶:AwAECAQABRQAAA==.',['�']='佳靈布佳靈:AwAICAkABAoAAA==.',['�']='信仰战丶:AwABCAEABAoAAA==.',['�']='倍氖大嘚:AwAGCAIABRQAAA==.',['�']='偷偷来一发:AwAICBwABAoDDAAIAQiVEQBHIs4BBAoADAAIAQiVEQAw7M4BBAoADQAHAQicHAA7o1kBBAoAAA==.',['�']='克洛琳德:AwAECAQABRQAAA==.八级大狂风:AwAECAQABAoAAA==.公摊面积:AwABCAEABRQAAA==.',['�']='再会芳华:AwADCAYABRQDDgADAQi0BQA7WOoABRQADgADAQi0BQA7WOoABRQACwABAQgBNAAUPzwABRQAAA==.冰火洗礼:AwADCAMABRQAAA==.冷萃咖啡丶:AwAECAYABRQCAgAEAQj4CgAWgYkABRQAAgAEAQj4CgAWgYkABRQAAA==.冷锅煎牛排:AwACCAgABRQCBAACAQh+LAAo5Y0ABRQABAACAQh+LAAo5Y0ABRQAAA==.冻柿子:AwAICAgABAoAAQsAVEsICBAABRQ=.',['�']='凌凌大魔王:AwAGCA8ABAoAAA==.',['�']='刀头:AwAGCAwABAoAAA==.切诺:AwABCAEABAoAAA==.刈阁:AwAECAQABRQAAA==.刑丶徒:AwADCAMABAoAAA==.',['�']='千羽林:AwAHCAcABAoAAA==.千里月明:AwAGCAYABAoAAA==.半支罒烟:AwAECAQABAoAAA==.卩丶小默灬:AwAGCAEABAoAAA==.',['�']='叫兽爱纯情:AwAECAQABRQAAQ8AO2AGCBQABRQ=.史真香:AwAECAQABAoAAA==.叶隐知心:AwAECAQABRQAAA==.',['�']='吃掉我:AwABCAEABRQAAA==.',['�']='哎呀下雨了:AwACCAMABRQAAA==.哎呦喂侬躺了:AwACCAIABRQAAA==.',['�']='唫角大王:AwACCAIABAoAAA==.',['�']='啪叽:AwACCAIABRQCEAAIAQhvGgBI3BQCBAoAEAAIAQhvGgBI3BQCBAoAAA==.',['�']='嘚儿灬驾丶:AwAICAgABAoAAA==.',['�']='圣光永逝:AwAICBIABAoAAA==.圣光疯男:AwAGCAYABAoAAA==.圣光缺大德:AwAGCAYABAoAAA==.',['�']='坏猫:AwAGCAYABAoAAA==.坤哥:AwADCAMABAoAAA==.',['�']='塔希尔:AwAHCBYABAoDDwAHAQh7WQA09XYBBAoADwAHAQh7WQA09XYBBAoAEQADAQgQFgATnWYABAoAAA==.',['�']='壓迫众生:AwAECAQABRQAAA==.',['�']='复苏的神:AwAGCAYABAoAAA==.夢如丶淺沫:AwAECAQABRQAAA==.大哥:AwAGCAIABRQAAA==.大猫儿丶:AwAFCAUABAoAAA==.大黑犇:AwACCAIABAoAAA==.太阳双子祭司:AwAGCAQABRQAARIAMzEICAQABRQ=.',['�']='威武霸气帅:AwAECAQABRQAAA==.',['�']='婲婲灬:AwAICBAABAoAAA==.',['�']='完美威力大:AwAGCAkABAoAAA==.宫脇丶咲良:AwAGCAYABAoAAA==.',['�']='小俊的大爷:AwAFCAEABAoAAA==.小恬儿宝宝:AwAECAQABRQAAA==.小的梦:AwACCAIABAoAAA==.小芙妮:AwACCAIABRQAAA==.小铭哥:AwAECAgABRQDEwAEAQiyAgBUQxsBBRQAEwAEAQiyAgBUQxsBBRQADwACAQj1KwAiN4EABRQAAA==.',['�']='山有扶苏:AwAECAQABRQAAQ8ANqYGCAoABRQ=.',['�']='巫山云宇:AwAGCAYABAoAAA==.',['�']='幕夕骑士:AwACCAEABAoAAA==.',['�']='很丶强:AwAICAgABAoAAA==.微凉丶记忆:AwAGCAYABAoAAA==.',['�']='总是学不会:AwAHCAcABAoAAA==.',['�']='恺撒:AwABCAMABRQECgAIAQg6KgBNxLYBBAoACgAFAQg6KgBUBLYBBAoAFAADAQhiQwA+JpMABAoAFQACAQiQLABF4nsABAoAAA==.',['�']='愛之義:AwADCA0ABRQCFgADAQiOAgBUdx8BBRQAFgADAQiOAgBUdx8BBRQAAA==.愤怒站士:AwAGCAIABRQAAA==.',['�']='我叫法師:AwACCAQABRQAAA==.我当时就懵了:AwAGCAcABAoAAA==.',['�']='托塔天王:AwAECA4ABRQCDwAEAQhSDABV2AoBBRQADwAEAQhSDABV2AoBBRQAAA==.',['�']='提防小手:AwACCAMABRQDDQAIAQj/CwBL5jICBAoADQAIAQj/CwBL5jICBAoADAAEAQglJgAd5cEABAoAAA==.',['�']='搞不搞:AwAECAcABAoAAA==.',['�']='无尽的湮灭:AwAICAgABAoAAA==.无尽的风暴:AwAECAQABRQAAA==.无法识别此人:AwAGCAEABAoAAA==.',['�']='易托箱:AwAICCEABAoDBAAIAQjfPQA6sBICBAoABAAIAQjfPQA6sBICBAoAAQADAQifQQAC2kMABAoAAA==.星皇:AwAECAQABRQAAA==.',['�']='暗堂天赐:AwACCAIABRQAAA==.',['�']='有毒的奶妈:AwAECAcABRQEFwAEAQjVBwBOpvgABRQAFwAEAQjVBwBOpvgABRQAEgABAQj/HwAGwz8ABRQAFgABAQjJIAAAAAAABRQAAQYAAAAICAIABRQ=.术学老尸:AwACCAIABRQAAA==.机灵贰拉罐:AwAICAgABAoAAA==.',['�']='根本不愿意:AwACCAIABAoAAA==.',['�']='梁朝伟丶:AwAECAQABRQAAQYAAAAGCAQABRQ=.梦初醒:AwAICAwABAoAAA==.',['�']='永暗:AwAGCAQABRQAAQYAAAAICAQABRQ=.',['�']='江湖掌柜:AwAGCA0ABRQDBQAGAQjKAgAk0kMBBRQABQAGAQjKAgAk0kMBBRQAGAADAQjSFwAbYpUABRQAAA==.',['�']='沐白的猫:AwACCAIABRQDFwAIAQh5EwA+wgYCBAoAFwAIAQh5EwA+wgYCBAoAFgABAQj/jwAAAAAABAoAAA==.',['�']='浴血战圣:AwAICBoABAoCCAAIAQhWGQBNmykCBAoACAAIAQhWGQBNmykCBAoAAA==.',['�']='渊冰:AwAGCAoABRQDDwAGAQiOAgA2powBBRQADwAGAQiOAgAtk4wBBRQAEwAEAQjvCAA0mt8ABRQAAA==.渣男熊师傅:AwAICAwABAoAAA==.',['�']='漫天小雪:AwAICBAABAoAAA==.',['�']='潮州果子狸:AwAECAsABRQDDQAEAQiqAgBX4ioBBRQADQAEAQiqAgBULioBBRQADAAEAQhDBABL0QoBBRQAAA==.',['�']='澹台经藏:AwAICA4ABAoAAA==.',['�']='火灬柴棍:AwADCAcABRQDDgADAQi0EwAgeUwABRQACwACAQjhJQAhKY0ABRQADgABAQi0EwAfGEwABRQAAA==.灬喵喵萌灬:AwAECAMABAoAAA==.灬豫淏焼灬:AwACCAMABRQAAA==.',['�']='炮舰之子:AwAECAQABRQAAA==.',['�']='無念丶:AwAECAQABRQAAA==.',['�']='熙瓜寨寨主:AwAICAEABAoAAA==.',['�']='燃烧吧胸毛:AwAECAQABAoAAA==.',['�']='爀尔墨斯:AwACCAIABAoAARkAWt4GCBgABRQ=.',['�']='牛一佰:AwAICA0ABAoAAA==.特仑苏加一:AwAICAYABAoAAA==.',['�']='狼丨术师:AwACCAIABRQDCgAIAQhNLQAy5KUBBAoACgAIAQhNLQAy5KUBBAoAFQABAQjyPwAIny4ABAoAAA==.',['�']='猛牛随变:AwAICAgABAoAAA==.',['�']='电击罗教授丶:AwAECAYABRQCEAAEAQjzBwBBBwABBRQAEAAEAQjzBwBBBwABBRQAAA==.',['�']='疾風寒雨:AwAECAQABRQAAA==.',['�']='石真香:AwAICA8ABAoAAA==.',['�']='磊磊丶:AwAECAQABRQAAQYAAAAGCAIABRQ=.',['�']='秋殇丨别恋:AwAICAgABAoAARoAYLUFCAYABRQ=.',['�']='等待的狼:AwAECAQABAoAAA==.',['�']='米库米恩:AwAHCAcABAoAAA==.',['�']='素喜:AwACCAIABRQAAA==.',['�']='纟工:AwACCAIABRQAAA==.红忠:AwABCAIABRQAAA==.纯正莽夫:AwAICAgABAoAAQYAAAAGCAQABRQ=.',['�']='维纳斯的拥抱:AwAICBkABAoCFgAIAQibEABH9ywCBAoAFgAIAQibEABH9ywCBAoAAA==.',['�']='羽月丿晨星:AwAECAQABRQAAA==.',['�']='自然之心:AwACCAIABRQAAA==.',['�']='艾木列:AwADCAMABAoAAA==.',['�']='若斐:AwAECAQABRQAAA==.',['�']='落叶飘零:AwAECAQABRQAAA==.',['�']='蓝怒:AwAICAgABAoAAA==.',['�']='褩竹:AwABCAEABRQAAQsARFgECAgABRQ=.',['�']='请客丶斩首:AwAECAQABAoAAA==.',['�']='豆腐渣:AwACCAIABRQAAA==.',['�']='走火入魔:AwADCAcABRQCAwADAQiTCQA88QQBBRQAAwADAQiTCQA88QQBBRQAAA==.',['�']='跪了个安:AwABCAEABRQAAA==.',['�']='踩鸟高手:AwADCAMABAoAAA==.',['�']='轰血殇:AwAICAgABAoAAA==.',['�']='追忆信仰:AwAICBIABAoAAA==.',['�']='逍遥狂哮:AwACCAMABRQAAA==.',['�']='那一抹丶柔情:AwACCAIABAoAAA==.邪恶熊猫人:AwAICAgABAoAAA==.',['�']='酒冰浊:AwAGCAkABAoAAA==.酱香拿铁:AwAECAMABRQAAA==.',['�']='鎏韵若龙:AwAGCAEABRQAAA==.',['�']='铭风一:AwACCAEABRQAAA==.',['�']='阿瑞斯丶丶:AwADCA0ABRQDDQADAQjEAgBPtScBBRQADQADAQjEAgBPtScBBRQADAABAQghEQAXeT0ABRQAAA==.',['�']='随风武疼兰:AwAECAwABRQCAgAEAQjjCgAVmooABRQAAgAEAQjjCgAVmooABRQAAA==.隔壁老王的熊:AwAECAcABRQCDwADAQgyDABN9wsBBRQADwADAQgyDABN9wsBBRQAARsARfcHCAcABRQ=.',['�']='霸霸冫:AwAICAgABAoAAA==.',['�']='风行者灬风怒:AwABCAEABRQAAA==.风袭:AwAGCAYABAoAAA==.',['�']='鬼舞娃娃:AwADCAEABAoAAA==.',['�']='黑焱:AwABCAEABRQAAA==.',['�']='龍丘丘飛:AwAICAgABAoAAA==.龙娘:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end