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
 local lookup = {'DemonHunter-Havoc','Warrior-Fury','Druid-Balance','Druid-Restoration','Priest-Shadow','Priest-Holy','Priest-Discipline','DemonHunter-Vengeance','Hunter-BeastMastery','Unknown-Unknown','Mage-Fire','Monk-Mistweaver','Monk-Windwalker','Druid-Guardian','Paladin-Protection','Paladin-Retribution','Paladin-Holy','Mage-Frost','Warrior-Protection','Hunter-Marksmanship','Warlock-Destruction','Monk-Brewmaster',}; local provider = {region='CN',realm='克洛玛古斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asuka:AwABCAEABAoAAA==.',Co='Corson:AwABCAIABRQCAQAIAQgFOgA0QJsBBAoAAQAIAQgFOgA0QJsBBAoAAA==.',Dk='Dk:AwADCAMABRQAAA==.',Ge='Geminisaga:AwAICAgABAoAAA==.',He='Heiheiya:AwABCAEABAoAAA==.',Ju='Juechen:AwADCAsABRQCAgADAQgEAwBdEEUBBRQAAgADAQgEAwBdEEUBBRQAAA==.',Pu='Pugilist:AwABCAEABRQAAA==.',Va='Valkyrjja:AwAECAQABRQAAA==.',Yg='Ygiph:AwAICA4ABAoAAA==.',['�']='东京奶德:AwABCAIABRQDAwAIAQgmIABD5iYCBAoAAwAIAQgmIABD5iYCBAoABAABAQg8egAfyiwABAoAAA==.丶逍遥遥:AwAECAYABRQEBQAEAQiGDgBAF8sABRQABQADAQiGDgBVWcsABRQABgACAQjADgA5hpUABRQABwABAQjdIgAB/CsABRQAAQcAFksGCAoABRQ=.',['�']='九指战神:AwAECAQABAoAAA==.',['�']='二两三钱:AwAECAcABRQCAgAEAQjUCgA+8QEBBRQAAgAEAQjUCgA+8QEBBRQAAA==.交出你的波波:AwABCAIABRQAAA==.',['�']='以太:AwAGCAYABAoAAA==.',['�']='伊蕾娜:AwAICB0ABAoDAQAIAQgHSQAk/FYBBAoAAQAHAQgHSQAnHlYBBAoACAAIAQiULAAUw/AABAoAAA==.',['�']='凤狂神:AwAECAYABRQCCQAEAQjIGAAjFtMABRQACQAEAQjIGAAjFtMABRQAAA==.',['�']='列奥德罗:AwAGCAgABAoAAA==.',['�']='南波吐:AwADCAIABAoAAA==.卡嘉莉:AwACCAIABRQAAA==.',['�']='唐山浪打浪:AwAECAUABAoAAA==.',['�']='圣光老哥:AwABCAEABRQAAA==.',['�']='大奎:AwABCAEABRQAAQoAAAAGCAQABRQ=.天子传奇:AwAECAQABRQAAQoAAAAGCAQABRQ=.夯夯面包代购:AwAGCAcABRQCCwAGAQizAQBDyNoBBRQACwAGAQizAQBDyNoBBRQAAA==.',['�']='娜娜莫女王:AwABCAIABRQDDAAIAQgVIQA8cMYBBAoADAAIAQgVIQA8cMYBBAoADQAFAQg6SwAUIaQABAoAAA==.',['�']='存钱罐罐:AwAGCAEABAoAAA==.孤身伴月影:AwABCAEABRQDAwAIAQh0LAA5Z94BBAoAAwAIAQh0LAA5Z94BBAoABAACAQjCXgAwJ3QABAoAAA==.',['�']='寻找苹烆:AwACCAIABAoAAA==.',['�']='小夜子:AwAECAQABAoAAA==.小火慢炖:AwADCAcABRQCCwADAQgMFQAxNeUABRQACwADAQgMFQAxNeUABRQAAA==.小鱼家的包菜:AwAFCAUABAoAAA==.就爱吃面:AwABCAEABAoAAA==.',['�']='幕色精灵:AwABCAEABAoAAA==.幻月傻僈:AwAECAQABAoAAA==.',['�']='思念成殇:AwABCAIABRQCDgAHAQjvBABQGCACBAoADgAHAQjvBABQGCACBAoAAA==.急刹车:AwAECAQABRQAAA==.',['�']='我叫长棍:AwAFCAUABAoAAA==.我贼萌要奶我:AwACCAIABRQAAA==.戰神佩琪:AwABCAEABRQAAA==.',['�']='把血放出来:AwABCAIABRQAAA==.',['�']='斐迪南大公:AwACCAcABRQCDwACAQjhCABHcqIABRQADwACAQjhCABHcqIABRQAAA==.',['�']='晴天小猪:AwAICAsABAoAAA==.',['�']='有点神骑:AwAECAgABRQDEAAEAQhbBABehTwBBRQAEAAEAQhbBABehTwBBRQAEQACAQg2DAAjTYYABRQAAA==.末日飘雪:AwAECAUABAoAAA==.',['�']='果粒多丶:AwADCAMABAoAAA==.',['�']='桥本有腿:AwACCAIABRQDEgAIAQjgCgBXUZcCBAoAEgAIAQjgCgBXUZcCBAoACwAIAQj7PAAphoMBBAoAAA==.',['�']='永恒蛋挞:AwAECAQABRQAAA==.',['�']='温温坏:AwABCAEABAoAAA==.',['�']='火文:AwACCAIABRQAAA==.',['�']='無名:AwABCAIABRQDAgAIAQgOJAA4l+UBBAoAAgAIAQgOJAA4l+UBBAoAEwAEAQjPJwArbZAABAoAAA==.',['�']='狗卓:AwAHCAcABAoAAA==.狸猫乌冬面:AwABCAEABAoAAA==.',['�']='猪猪蛋:AwADCAYABRQCBgADAQjWBABBef0ABRQABgADAQjWBABBef0ABRQAAA==.',['�']='珂朵莉:AwACCAIABAoAAA==.',['�']='白的黑:AwADCAMABRQAAA==.',['�']='皓阳装饰:AwABCAEABRQAAA==.',['�']='看不見我:AwAFCAkABAoAAA==.真的汉子:AwABCAIABRQCFAAIAQjcDwBMlyoCBAoAFAAIAQjcDwBMlyoCBAoAAA==.',['�']='神吕布丶:AwAICBAABAoAAA==.神里绫华丶:AwADCAMABAoAAA==.神龙大虾:AwABCAIABRQAAA==.',['�']='秋雨醉繁华:AwAICAMABAoAAA==.',['�']='索饵:AwAECAcABAoAAA==.',['�']='红烛:AwABCAIABRQCFQAGAQg8PQBEXFcBBAoAFQAGAQg8PQBEXFcBBAoAAA==.',['�']='羞答答地玫瑰:AwAGCAEABAoAAA==.',['�']='老牛哞:AwACCAMABAoAAA==.',['�']='芙宁娜:AwADCAMABAoAAA==.',['�']='蒙牛雷达:AwAECAQABRQAAA==.',['�']='蓝萦傲魂:AwAECAQABRQAAA==.',['�']='變形琻钢:AwADCAMABAoAAA==.',['�']='贝拉露娜:AwAECAQABRQEFgAIAQiTBABTQUACBAoAFgAIAQiTBABL80ACBAoADQAHAQiKIQA/nagBBAoADAAFAQiCWgAm568ABAoAAA==.',['�']='转一下别毛了:AwAICAoABAoAAA==.',['�']='逍遥遥:AwADCAgABRQCEwADAQi+BAAYsKQABRQAEwADAQi+BAAYsKQABRQAAA==.',['�']='青涩后妈:AwACCAIABAoAAA==.面无暇:AwAHCAYABAoAAA==.',['�']='風與未來丶:AwAICAgABAoAAA==.',['�']='风云百合:AwAECAUABAoAAA==.',['�']='马库斯李:AwACCAQABRQAAA==.',['�']='黑夜之声:AwACCAIABAoAAA==.黑马弥娜:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end