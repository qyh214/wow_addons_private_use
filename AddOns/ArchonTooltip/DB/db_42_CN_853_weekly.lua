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
 local lookup = {'Warlock-Affliction','Warlock-Destruction','Paladin-Retribution','Mage-Frost','Mage-Fire','Druid-Feral','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Shaman-Enhancement','Monk-Windwalker','Paladin-Holy','Shaman-Restoration','Monk-Mistweaver','Priest-Holy','Priest-Discipline','Priest-Shadow',}; local provider = {region='CN',realm='金度',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Alisaa:AwADCAMABAoAAA==.',Ti='Tingjinl:AwAECAYABRQDAQAEAQijEgAufHQABRQAAQACAQijEgAM13QABRQAAgAEAAgAAAAufAAABRQAAA==.',['�']='一念百年:AwAICAgABAoAAA==.上京临潢府:AwAGCAUABAoAAA==.专业团队:AwAGCAQABRQAAA==.东门听雨:AwAFCAMABAoAAA==.丫头子:AwAFCAUABAoAAA==.',['�']='五十二日:AwAGCAQABAoAAA==.',['�']='余小米:AwABCAIABRQCAwAIAQglJQBS/XMCBAoAAwAIAQglJQBS/XMCBAoAAA==.',['�']='依旧那个角度:AwACCAQABRQDBAAIAQj7GgBE1w8CBAoABAAIAQj7GgBE1w8CBAoABQABAQhcpQAAAAAABAoAAA==.',['�']='倪好:AwABCAEABRQCBgAIAQj4CAA+Oh0CBAoABgAIAQj4CAA+Oh0CBAoAAA==.',['�']='别烦夏天:AwAECAEABRQAAA==.',['�']='劍來:AwAGCAEABRQDBwAIAQjIAQBhk/QCBAoABwAIAQjIAQBhk/QCBAoACAAHAQjYLwBMfasBBAoAAA==.劳伦斯:AwACCAIABAoAAA==.',['�']='十七丶风行者:AwADCAQABAoAAQkAAAAFCAUABAo=.单纯小男孩:AwACCAIABRQAAA==.',['�']='可乐不加冰丶:AwABCAEABRQAAQkAAAAICAQABRQ=.可莉頑家:AwAGCAcABRQDCgAEAQjKHABYJccABRQACgADAQjKHABYYccABRQACwADAQhcDwA1O7QABRQAAA==.司马峨嵋:AwAECAQABRQAAA==.',['�']='咘悠咘悠:AwAHCAEABAoAAA==.',['�']='哦是吗:AwAECAQABRQAAQQARe4HCAcABRQ=.',['�']='唔知小旭:AwAECAYABRQCAwAEAQhsFwA2x+8ABRQAAwAEAQhsFwA2x+8ABRQAAA==.',['�']='嘟嘟傻满丶:AwAGCAoABRQDDAAGAQhpBgA73fEABRQADAAEAQhpBgA4qvEABRQADQACAQjnCgBAqc8ABRQAAA==.',['�']='圣光大忽悠:AwACCAIABAoAAA==.圣珈堂:AwABCAEABRQAAA==.',['�']='坏壊灬孩孓气:AwAICAgABAoAAA==.',['�']='墨墨:AwACCAIABRQAAA==.',['�']='大坑:AwAGCAYABAoAAA==.天使魔心:AwADCAkABRQDCwADAQiZCgA2e94ABRQACwADAQiZCgAx8d4ABRQACgABAQjePAAwuUYABRQAAA==.天音化物:AwAECAQABRQAAA==.',['�']='奶似奶非奶:AwACCAIABRQAAA==.',['�']='小德真好玩:AwAECAQABAoAAA==.小悦毁灭世界:AwACCAIABAoAAA==.就是不奶:AwACCAIABRQAAA==.',['�']='弹跳甲鱼汤:AwAECAQABRQAAA==.',['�']='御风神兽:AwAICAMABAoAAA==.',['�']='我真不会治疗:AwAICAMABAoAAA==.',['�']='打不过就无敌:AwAECAwABRQCAwAEAQiuEwA9gfoABRQAAwAEAQiuEwA9gfoABRQAAA==.',['�']='抠脚大汉:AwAFCAMABAoAAA==.',['�']='斯卡蒂:AwAECAQABRQAAQ4ATFAGCAsABRQ=.',['�']='无奈的山芋:AwAECAQABAoAAA==.',['�']='暮雨亦成诗:AwAECAEABAoAAA==.',['�']='柒号肉老板:AwACCAIABRQAAA==.',['�']='森之灵羿:AwAICAoABAoAAA==.森之灵翼:AwAGCAYABAoAAA==.',['�']='楠丁格尔:AwACCAMABRQDAwAIAQhcfQA4F38BBAoAAwAHAQhcfQA6YH8BBAoADwACAQjMPwALGFoABAoAAA==.',['�']='武汉彭于晏丶:AwAFCAUABAoAAA==.',['�']='水中飞舞:AwAECAsABRQCAwAEAQjPCABVKCMBBRQAAwAEAQjPCABVKCMBBRQAAA==.',['�']='沃尔皮:AwACCAIABAoAAA==.没遮拦丶袭人:AwABCAEABRQCEAAIAQhPIwBApucBBAoAEAAIAQhPIwBApucBBAoAAA==.',['�']='流浪风之间:AwAECAQABRQAAA==.海战之星:AwACCAMABRQAAA==.海战之盾:AwABCAIABRQAAA==.',['�']='灬須彌的等待:AwAECAQABRQAAA==.灿歌:AwADCAMABAoAAA==.',['�']='焰凤凰:AwAECAQABAoAAA==.',['�']='爆棚福运侠:AwACCAUABRQCEQACAQjWGAAyu5cABRQAEQACAQjWGAAyu5cABRQAAA==.',['�']='狂野之弦:AwAHCAEABAoAAA==.',['�']='王嘉懿丶:AwADCAIABAoAAA==.王小明丶:AwAICAgABAoAAA==.',['�']='白河奈奈佳:AwABCAEABRQAAA==.',['�']='简单:AwAICAEABAoAAA==.',['�']='紅法:AwAECAQABRQAAA==.',['�']='翅膀:AwACCAEABAoAAA==.',['�']='老龙重装:AwAGCAYABAoAAA==.',['�']='聪明灯:AwAGCAQABRQAAQkAAAAICAQABRQ=.',['�']='花与虫:AwADCAIABAoAAA==.',['�']='苍郁丶:AwAECAQABRQAAA==.',['�']='茄汁沙丁鱼:AwACCAIABRQAAA==.',['�']='莫高雷的图腾:AwABCAIABRQAAA==.',['�']='萝莉有三宝:AwABCAEABRQAAA==.',['�']='角角子:AwACCAIABRQAAA==.',['�']='蹦跶嘚橙仔:AwACCAQABRQAAQsAQc0GCAYABRQ=.',['�']='轩辕的小圣歌:AwACCAIABRQAAA==.',['�']='迎着风:AwACCAIABRQAAA==.',['�']='逆流一死骑:AwAICAUABAoAAA==.',['�']='雪域冰封:AwAECAUABRQDBAAEAQgOBABUzQsBBRQABAAEAQgOBABUzQsBBRQABQABAQhsLwBbUl0ABRQAAA==.',['�']='风凌雪孀:AwABCAEABAoAAA==.',['�']='魔幻之旅:AwABCAIABRQDCgAIAQhmEwBYbKQCBAoACgAIAQhmEwBYbKQCBAoACwACAQgYUwA7/JEABAoAAA==.',['�']='黑巧闪闪:AwAGCAkABRQEEgAGAQgCCgAqnNQABRQAEgAFAQgCCgAPO9QABRQAEwACAQg3FgA4rY4ABRQAFAACAQheHAARhVMABRQAAA==.黑暗丶欣:AwAFCAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end