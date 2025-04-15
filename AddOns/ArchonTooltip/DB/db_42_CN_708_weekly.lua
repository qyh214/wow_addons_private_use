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
 local lookup = {'Monk-Windwalker','Monk-Mistweaver','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Warrior-Arms','Priest-Shadow','Hunter-Survival','Priest-Discipline','Evoker-Preservation','Warrior-Fury','Hunter-BeastMastery','Warrior-Protection','Mage-Frost','Mage-Fire','Priest-Holy','Shaman-Enhancement','Shaman-Elemental','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','Paladin-Retribution','Warlock-Affliction','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Frost','Evoker-Devastation','Paladin-Protection','Warlock-Demonology','Shaman-Restoration',}; local provider = {region='CN',realm='月神殿',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Banamaster:AwAECAQABRQDAQAHAQiXFgBM4QcCBAoAAQAHAQiXFgBM4QcCBAoAAgAGAQg4SQAmrfMABAoAAA==.',Bi='Bianlin:AwAICAgABAoAAA==.',Bo='Borlar:AwAECAYABAoAAA==.',Ca='Caliil:AwAECAQABRQAAA==.',Da='Dawn:AwAFCAgABAoAAA==.',Ei='Eileener:AwADCAMABAoAAA==.',Fo='Fofofofofo:AwAGCAQABRQAAQEAIjQHCAkABRQ=.',Ir='Irises:AwAECAQABRQAAA==.',Je='Jett:AwAECAgABRQCAwAEAQh4CAAyWOIABRQAAwAEAQh4CAAyWOIABRQAAA==.',Ku='Kujojotaroe:AwAECAQABRQAAA==.',Nu='Nullms:AwACCAMABAoAAA==.',Pa='Pandia:AwAECAkABRQDBAAEAQhsHgA30YkABRQABAADAQhsHgAi/YkABRQABQABAQjNFwA5HEUABRQAAA==.',Un='Unraveled:AwAECAQABRQAAA==.Unwilling:AwAECAQABRQAAQYAIZ4GCAoABRQ=.',Up='Upup:AwABCAEABAoAAA==.',Za='Zangiefu:AwAECAQABRQAAA==.',['�']='一只橘喵:AwAECAQABRQAAQcAN1QGCAYABRQ=.一袋米扛几楼:AwAICAgABAoAAA==.上山去修道:AwACCAQABRQAAA==.不动行光:AwAGCAYABAoAAA==.世末凉子:AwAICBYABAoDCAAIAQi6AQBV+54CBAoACAAIAQi6AQBV+54CBAoAAwAEAQjKOgBEZe4ABAoAAA==.丨赫灬夕丨:AwAICAUABAoAAA==.丶曲罢:AwAGCAsABRQCBgAGAQgrAABJqgACBRQABgAGAQgrAABJqgACBRQAAA==.',['�']='乔治:AwAECAQABRQAAA==.乖乖站好丶:AwAGCBgABRQCCQAGAQi4AABGvNEBBRQACQAGAQi4AABGvNEBBRQAAA==.九转回锅肉:AwAGCAYABAoAAA==.',['�']='亲爱的酒蒙子:AwAFCAIABRQAAQoAGncGCAUABRQ=.人间無骨:AwAICBwABAoCCwAIAQiYJQAsatwBBAoACwAIAQiYJQAsatwBBAoAAA==.',['�']='伯牙:AwAECAQABRQAAA==.',['�']='你是最棒的咕:AwAGCAYABAoAAA==.',['�']='光之使者:AwAECAQABAoAAA==.全场两分钱:AwAFCBAABRQDDAAFAQhgAgAwO5UBBRQADAAFAQhgAgAuH5UBBRQAAwABAQiWGwASyz0ABRQAAA==.',['�']='冈仁波齐:AwACCAcABRQCCwACAQjPFQA8BaUABRQACwACAQjPFQA8BaUABRQAAA==.再看给你一拳:AwAICAgABAoAAA==.冰嘎冰嘎:AwAECAQABRQAAA==.',['�']='北落丿:AwABCAEABRQAAA==.匚丶东方树叶:AwAGCAYABAoAAA==.匚丶山楂树下:AwABCAMABRQDDQAIAQhSFwAggiIBBAoACwAIAQg9PwAQ7UcBBAoADQAIAQhSFwAdSyIBBAoAAA==.',['�']='厦吉丶布朗:AwABCAEABRQAAA==.',['�']='只为娱乐:AwAFCAEABAoAAA==.可乐冰冰凉:AwABCAIABRQAAA==.',['�']='吉吉国王陆宇:AwAICAUABAoAAA==.吖啼:AwABCAEABRQAAA==.',['�']='呆丶穆頭:AwACCAIABAoAAA==.周一也要玩:AwAGCAcABAoAAA==.',['�']='哈基龙:AwACCAIABRQAAA==.哈库珀:AwABCAEABRQDDgAIAQiWCABXP68CBAoADgAIAQiWCABXP68CBAoADwABAQjHlAAbSCsABAoAAA==.',['�']='唔姆唔姆:AwACCAIABAoAAA==.',['�']='喜哩哩:AwAECAQABRQAAA==.喵喵多狸:AwAECAQABAoAAA==.',['�']='圆滚滚雷滚滚:AwADCAMABRQAAA==.',['�']='天下睿行:AwAGCAkABAoAAA==.太猛了太猛了:AwAECAgABRQDDQAEAQjtBAAX2KAABRQACwAEAQjKEAAT99IABRQADQAEAQjtBAARjaAABRQAAA==.',['�']='奶萨:AwADCAMABAoAAA==.',['�']='姓字半藏半显:AwAECAQABRQAAA==.',['�']='孫悟空:AwAECAQABRQAAA==.',['�']='宝宝冲锋:AwAGCAwABAoAARAAQYgBCAEABRQ=.',['�']='寒凝露:AwAECAQABRQAAA==.',['�']='小二喜:AwAICAkABRQDEQAIAQjOAQAzdoABBRQAEQAEAQjOAQAsIYABBRQAEgAEAQi+BQA9PPIABRQAAA==.小半半:AwADCAEABAoAAA==.小福腻:AwABCAEABRQAAA==.尤志志:AwACCAMABRQAARMASw4CCAkABRQ=.就是当兵:AwABCAMABRQDFAAHAQgpJwA8++UABAoAFAAHAQgpJwA8++UABAoAFQADAQj+NwAfcSoABAoAAA==.',['�']='屠龙小子:AwAGCAsABAoAAA==.',['�']='布劳缪克斯:AwAGCAEABAoAAA==.布瑞克铁炉:AwACCAQABRQCBgAIAQieEwBA/fMBBAoABgAIAQieEwBA/fMBBAoAAA==.希兹克利夫:AwABCAEABRQCFgAIAQifPwBFnQ0CBAoAFgAIAQifPwBFnQ0CBAoAAA==.',['�']='干锅小烧卖:AwADCAsABRQCDwADAQjpFwAoN9sABRQADwADAQjpFwAoN9sABRQAAA==.平方:AwAFCAcABAoAARcATWcCCAcABRQ=.',['�']='影月之月:AwAFCAUABAoAAA==.',['�']='德莱不费功夫:AwADCAoABRQCFgADAQjDGQAxn98ABRQAFgADAQjDGQAxn98ABRQAAA==.',['�']='忘嘚芙:AwAECAQABRQAARgAAAAICAQABRQ=.忘尘一凡:AwAICBsABAoCFgAIAQjBOQEC3UcABAoAFgAIAQjBOQEC3UcABAoAAA==.',['�']='思乡的浪子:AwAICAYABAoAAA==.',['�']='恶魔十三:AwAECAQABRQAAA==.',['�']='我不这样认为:AwACCAIABRQAAA==.我爱长发飘飘:AwABCAMABRQAAA==.',['�']='折尽风前柳:AwABCAIABRQAAA==.',['�']='拉風男人丶:AwADCAMABAoAAA==.',['�']='提拉斯丶夜翼:AwAICAgABAoAAA==.',['�']='文斯莫克:AwAECAQABRQAAA==.',['�']='旋舞:AwAECAQABRQAAQ8AJ70GCAoABRQ=.',['�']='暴躁土拨鼠:AwABCAEABRQCDgAIAQiuJAAxdssBBAoADgAIAQiuJAAxdssBBAoAAA==.',['�']='曲罢:AwAGCAQABRQAAA==.',['�']='柏晨:AwAGCAEABRQCDAABAQgNMwA1yVYABRQADAABAQgNMwA1yVYABRQAAA==.',['�']='桃花面:AwAFCAUABAoAAA==.',['�']='欣仔:AwABCAIABRQDGQAIAQhJNQAySKoBBAoAGQAIAQhJNQArAKoBBAoAGgAEAQhtIQAxXI0ABAoAAA==.',['�']='水闸行动带我:AwAECAQABRQAAA==.',['�']='沐丷苒:AwACCAIABAoAAA==.河北彩伽:AwAICAIABAoAAA==.',['�']='淡若青栀:AwABCAEABRQAAA==.淡薄了流年:AwADCAkABRQCDAADAQgWGAAldNYABRQADAADAQgWGAAldNYABRQAAA==.',['�']='溷囿:AwAECAwABRQCBAAEAQg5CABPSA0BBRQABAAEAQg5CABPSA0BBRQAAQUAPyYICAsABRQ=.',['�']='火光带闪电:AwAFCAUABAoAAA==.火鸡炖锅巴:AwAECAYABAoAAA==.灬麦孖哥灬:AwAGCAwABAoAAA==.',['�']='熊无主菊自开:AwAICAIABAoAAA==.熔岩之刃:AwACCAIABAoAAA==.',['�']='獭耳獭洛斯:AwABCAIABRQCGwAIAQiTFAA7aPIBBAoAGwAIAQiTFAA7aPIBBAoAAA==.',['�']='珂珂守护者:AwACCAQABAoAAA==.班婕妤:AwABCAIABRQAAA==.',['�']='生死看蛋:AwABCAEABRQCFgAIAQg0XAAtoMABBAoAFgAIAQg0XAAtoMABBAoAAA==.',['�']='界赵云:AwABCAEABRQAAA==.',['�']='疾风怒涛之嗷:AwAECAgABAoAAA==.',['�']='白色疤痕:AwAICAgABAoAARwAI6UECAgABRQ=.',['�']='米彩:AwACCAIABRQAAA==.',['�']='素裳:AwACCAIABAoAAA==.',['�']='美团:AwABCAEABRQAARgAAAAGCAMABRQ=.',['�']='聆听丨故事:AwACCAIABRQAAA==.聊天一字六毛:AwAECAYABRQCFgAEAQh8EgA8r/cABRQAFgAEAQh8EgA8r/cABRQAAA==.',['�']='自带光环:AwAECAQABRQAAA==.',['�']='花开彼岸:AwAECAQABRQAAA==.花开锦绣:AwAECAEABRQAAA==.花无媸:AwAICAgABAoAARgAAAAICAQABRQ=.',['�']='苞苞冲锋:AwAECAcABAoAARAAQYgBCAEABRQ=.若是风华:AwAECAUABAoAAA==.',['�']='菱灬璃:AwAGCAYABAoAAA==.',['�']='葡萄:AwABCAEABRQCHQAIAQi+DwAwRsoBBAoAHQAIAQi+DwAwRsoBBAoAAA==.',['�']='蓓蓓冲锋:AwABCAEABRQCEAAIAQgNFwBBiPUBBAoAEAAIAQgNFwBBiPUBBAoAAA==.蓝色就会放电:AwAGCAYABAoAAA==.',['�']='蕾姆碳:AwAECAQABAoAAA==.',['�']='话痨牛:AwAECAQABRQAAA==.',['�']='轻装简萨:AwABCAEABRQAAA==.',['�']='迷人的保险柜:AwABCAIABRQCDAAIAQgpNwA8F/IBBAoADAAIAQgpNwA8F/IBBAoAAA==.',['�']='逍遥汤圆:AwAECAgABRQDDAAEAQjSEQA4mfIABRQADAAEAQjSEQA4mfIABRQAAwAEAQi1DQAXrbAABRQAAA==.逼兜由子:AwAGCAwABAoAAA==.',['�']='铁北酒蒙子:AwABCAIABRQCHgAIAQjZMQAw5JkBBAoAHgAIAQjZMQAw5JkBBAoAAA==.',['�']='阿佶:AwACCAIABRQAAA==.阿哩喜:AwAECAQABRQAAA==.',['�']='青阳:AwAICAMABAoAARgAAAAICAQABRQ=.',['�']='顾逸:AwACCAIABRQAAA==.',['�']='风雷之羽:AwAECAQABRQAAA==.飞丶杨:AwACCAkABRQCEwACAQh+DQBLDq0ABRQAEwACAQh+DQBLDq0ABRQAAA==.飞花如雪:AwAHCA4ABAoAAA==.',['�']='香脆奶油泡芙:AwACCAIABAoAAA==.',['�']='骑猪漫步:AwAICAgABAoAAA==.',['�']='鹿溪:AwAICAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end