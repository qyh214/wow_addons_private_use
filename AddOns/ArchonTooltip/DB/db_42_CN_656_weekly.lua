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
 local lookup = {'Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Shaman-Elemental','Paladin-Retribution','Monk-Windwalker','Shaman-Restoration','DeathKnight-Blood','Druid-Balance','Unknown-Unknown','Warrior-Fury','Warrior-Arms','Hunter-Marksmanship','Rogue-Assassination','Druid-Guardian','Monk-Brewmaster','Monk-Mistweaver','Druid-Restoration','Priest-Holy','Priest-Discipline','Paladin-Protection','DemonHunter-Havoc','Hunter-BeastMastery','DeathKnight-Unholy','Paladin-Holy','Mage-Fire',}; local provider = {region='CN',realm='密林游侠',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arcadias:AwABCAEABRQAAA==.',Bf='Bfore:AwAECAgABRQEAQAEAQieBQBI7fMABRQAAQAEAQieBQA52fMABRQAAgADAQhtDABDGd8ABRQAAwABAQiWFgAAAAAABRQAAA==.',Bo='Bomber:AwAICAgABAoAAA==.',Ca='Cannonry:AwAICAgABAoAAA==.',Co='Convers:AwAECAgABRQCBAAEAQijAQBYqDQBBRQABAAEAQijAQBYqDQBBRQAAA==.',De='Decem:AwAGCAcABAoAAA==.',Dm='Dm:AwACCAcABRQDAQACAQhvCABatdQABRQAAQACAQhvCABatdQABRQAAgABAQjEKAAwpToABRQAAA==.',En='Endurance:AwAICBAABAoAAA==.',Fi='Fish:AwAHCA8ABAoAAA==.',Ir='Irokon:AwAECAYABAoAAA==.',Je='Jeannedarc:AwAGCBQABAoCBQAGAQg6kAAvsEYBBAoABQAGAQg6kAAvsEYBBAoAAA==.',Lo='Lostmm:AwAFCAIABAoAAA==.',Ls='Lslvet:AwACCAQABRQEAgAIAQjPCwBfzX4CBAoAAgAHAQjPCwBfun4CBAoAAwACAQjBLwBhOeAABAoAAQABAQjHNwBQ8kUABAoAAA==.',Mi='Minipanda:AwABCAMABRQCBgAIAQgVBQBbTc8CBAoABgAIAQgVBQBbTc8CBAoAAA==.',Ni='Nightfall:AwAECAQABRQAAA==.',Nu='Nujabes:AwAHCAcABAoAAA==.',Po='Potential:AwAECAYABAoAAA==.',Sa='Samsaraz:AwAICAgABAoAAA==.',Sp='Spaceboy:AwACCAcABRQCBwACAQhqFgA1Q58ABRQABwACAQhqFgA1Q58ABRQAAA==.',Ve='Verandern:AwACCAMABRQAAA==.',Wi='Windflowers:AwAECAQABAoAAA==.Winormiss:AwAECAYABRQCCAAEAQiTDQAloqwABRQACAAEAQiTDQAloqwABRQAAA==.',['�']='一个人玩:AwABCAEABAoAAA==.一颗橙子:AwADCAUABRQCBwADAQgVDAAq2eQABRQABwADAQgVDAAq2eQABRQAAA==.七夜之杰仔:AwAECAQABRQAAA==.上西惠:AwABCAEABAoAAA==.丝情袜意:AwAGCAQABRQAAA==.丨灰加丨:AwACCAcABRQCCQACAQjAFABUSccABRQACQACAQjAFABUSccABRQAAA==.丿桃之妖妖:AwAICAcABAoAAA==.丿绝无仅有:AwAICAgABAoAAQoAAAAGCAQABRQ=.',['�']='亨瑟西:AwABCAIABRQAAA==.',['�']='今晚打野猪:AwAGCAoABRQCCAAGAQiJEwAbKXwABRQACAAGAQiJEwAbKXwABRQAAA==.',['�']='伏迪魔:AwAFCAcABAoAAA==.',['�']='低调摇摆:AwAECAMABRQAAA==.你怎么还在这:AwADCAEABAoAAQkAX2wCCAQABRQ=.',['�']='元元吃薯条:AwADCAMABAoAAA==.',['�']='冰阿蝠:AwAICAkABAoAAA==.冷酷的黑总:AwAECAQABRQAAA==.',['�']='凌晨之冰:AwAICAUABAoAAA==.',['�']='剑惊风:AwAHCAkABAoAAA==.',['�']='北洛狮门:AwAGCAYABAoAAA==.',['�']='十二月十三:AwAFCAUABAoAAA==.十随心所欲十:AwACCAIABAoAAA==.华氏九度:AwAFCAkABAoAAA==.',['�']='厕所:AwAICAgABAoAAA==.',['�']='双持骑士王:AwAGCAgABRQDCwAGAQiECQApwggBBRQACwAEAQiECQA5WQgBBRQADAACAQitCAASYLAABRQAAQoAAAAICAQABRQ=.发财:AwAICAgABAoAAA==.右手之殇:AwACCAIABAoAAA==.',['�']='吃我两刀:AwABCAEABRQAAA==.名侦探柯北:AwAGCAIABAoAAQoAAAAICAIABAo=.',['�']='咖啡煮双采:AwAICAoABAoAAQ0AYtEGCAgABRQ=.',['�']='哇达西蛙:AwADCAQABAoAAA==.哎呀又胖惹:AwADCAMABAoAAA==.',['�']='嗜血开:AwACCAQABRQAAA==.嗷墩墩:AwACCAIABAoAAA==.',['�']='回眸一刺:AwAGCAoABRQCDgAGAQhlAABDFOQBBRQADgAGAQhlAABDFOQBBRQAAA==.',['�']='圣洁的黑总:AwAECAIABRQAAA==.',['�']='堕落冥风:AwACCAMABRQAAA==.堕落怒风:AwABCAEABRQAAA==.堕落旋风:AwABCAEABRQAAA==.堕落灵风:AwADCAUABRQCDwADAQjIAgAT9XQABRQADwADAQjIAgAT9XQABRQAAA==.堕落烈风:AwADCAUABRQCEAADAQiDBQAJS3cABRQAEAADAQiDBQAJS3cABRQAAA==.堕落神风:AwADCAQABRQAAA==.',['�']='墩墩筒筒:AwAECAQABAoAAA==.',['�']='夕莉:AwACCAcABRQDBgACAQhoEwBLAWIABRQABgABAQhoEwBW9mIABRQAEQABAQgXIAAhdUsABRQAAA==.大喵不是猫:AwAGCA0ABAoAAA==.大旅行家艾尔:AwACCAIABAoAAA==.天才:AwAECAQABRQAAA==.天知晓:AwABCAEABRQAAA==.天紫月:AwAHCAoABAoAAA==.',['�']='奥丶斯丶卡:AwABCAEABRQAAA==.奶油棉花糖:AwAECAQABRQAAA==.',['�']='娃哈蛤:AwABCAMABRQAAA==.',['�']='宁波年糕团:AwAICAgABAoAAA==.宁波德爷:AwAECAUABRQDCQAEAQjwGAAmgaQABRQACQADAQjwGAA2XqQABRQAEgACAQiPEQAiuHgABRQAAA==.宁波柱子爷:AwAICAgABAoAARIAOkwGCAUABRQ=.宁波神木丽:AwAICBIABAoAAA==.',['�']='寜檬:AwAGCAYABAoAAA==.',['�']='小恶魔:AwAECAQABAoAAA==.小样迩:AwAICAkABAoAAA==.小薄荷:AwAECAQABRQAAQ4AQxQGCAoABRQ=.小骑士丷呆呆:AwADCAUABAoAAA==.尸骑李颢:AwACCAcABRQDEwACAQjPFAAQBG0ABRQAEwACAQjPFAAQBG0ABRQAFAACAQidGQANg2cABRQAAA==.',['�']='帕拉朵珂丝:AwAECAoABRQCEQAEAQhRCgA9gvQABRQAEQAEAQhRCgA9gvQABRQAAQoAAAAGCAQABRQ=.帼寳:AwADCAMABRQAAA==.',['�']='幸运七:AwAECAgABRQDFQAEAQgTBABKLAMBBRQAFQAEAQgTBABKLAMBBRQABQAEAQj7GgAjYtkABRQAAA==.',['�']='弯弯的小路:AwAECAgABAoAAA==.',['�']='徳全:AwAHCAYABAoAAA==.',['�']='恶灵挽歌:AwABCAEABAoAAA==.',['�']='愿与愁:AwAHCAcABAoAAA==.',['�']='我已经无敌了:AwACCAcABRQCFgACAQhiFQBbytIABRQAFgACAQhiFQBbytIABRQAAA==.戮汐丶小寒:AwADCAkABRQCFwADAQimDgAyy/8ABRQAFwADAQimDgAyy/8ABRQAAA==.',['�']='搞还是你会搞:AwACCAcABRQCCwACAQhYEwBLBLQABRQACwACAQhYEwBLBLQABRQAAA==.',['�']='放牛大少爷:AwACCAcABRQDGAACAQg+EgBBQrYABRQAGAACAQg+EgBBQrYABRQACAACAQgUGQAIcEsABRQAAA==.',['�']='无源不是我:AwABCAEABAoAAQoAAAAECAQABRQ=.',['�']='星辰夜风:AwAECAQABRQAAA==.',['�']='暮夏:AwAECAMABAoAAA==.',['�']='最后一舞:AwAECAQABRQAAA==.最爱糖菓屋:AwABCAEABAoAAA==.月泽:AwACCAIABAoAAA==.',['�']='桐心:AwABCAEABRQAAA==.',['�']='梅子酒:AwACCAIABAoAAA==.',['�']='橙子橙子丶:AwAFCAUABAoAAA==.',['�']='永远的希瓦:AwAECAQABRQAAA==.',['�']='求求你项链呢:AwAICAgABAoAAA==.汪汪队闯大祸:AwACCAQABRQDFwAIAQjhOwA63t8BBAoAFwAIAQjhOwA4gd8BBAoADQAIAQgtLwAZMTMBBAoAAA==.',['�']='沃京:AwAECAgABRQCCwAEAQjfDAAtxfYABRQACwAEAQjfDAAtxfYABRQAAA==.沙僧没人爱:AwAICAgABAoAAA==.沙拉酱酱:AwAFCAgABAoAAA==.',['�']='活到老学到老:AwAECAgABRQDGAAEAQjAAgBcU0EBBRQAGAAEAQjAAgBcU0EBBRQACAAEAQiHCgAv8cQABRQAAA==.',['�']='流氓丶砍:AwAICAkABAoAAA==.海飞思:AwADCAYABAoAAA==.',['�']='淡定的超神:AwAICAgABAoAAA==.',['�']='清泉流响:AwADCAMABRQAAA==.',['�']='灬穆丶:AwAECAQABRQAAA==.灰败的蔷薇:AwABCAEABRQAAA==.灰龙:AwAFCAUABAoAAQkAVEkCCAcABRQ=.',['�']='烫木嫂:AwACCAIABAoAAA==.热血剑剑:AwAECAgABRQCBQAEAQhuFABBQ/EABRQABQAEAQhuFABBQ/EABRQAAA==.',['�']='無雙丶:AwAICAYABAoAAA==.',['�']='爆到你心跳:AwAICBwABAoCBQAIAQh+DABeztoCBAoABQAIAQh+DABeztoCBAoAAA==.爱慕剔:AwAGCAYABAoAAA==.',['�']='狂拽伏特加:AwADCAMABAoAAA==.狗二蛋:AwADCAMABRQAAA==.',['�']='瓦娜斯女王:AwAECAgABRQCCAAEAQi6BwBCuecABRQACAAEAQi6BwBCuecABRQAAA==.',['�']='白月魁:AwACCAIABAoAAA==.',['�']='砳砳:AwAICAgABAoAAA==.',['�']='神圣继承者:AwAECAcABAoAAA==.神经妇科:AwADCAkABAoAAA==.',['�']='秋月风夏:AwACCAIABRQAAA==.秋森晚:AwACCAIABRQAAA==.',['�']='稳泛沧浪空阔:AwAICAgABAoAAA==.',['�']='糖果商:AwAFCAYABAoAAA==.',['�']='紧跟潮流:AwAGCAYABAoAAA==.紫血灵:AwABCAEABAoAAA==.紫雨凝香:AwACCAcABRQDGQACAQh3DQAJYHUABRQAGQACAQh3DQAJYHUABRQAFQABAQhYEgAd7zcABRQAAA==.',['�']='繁星:AwACCAIABAoAAA==.',['�']='纳格兰的天空:AwAFCAMABAoAAA==.',['�']='绯玉丸:AwAICAIABAoAAA==.绿色天然呆:AwABCAEABRQAAA==.',['�']='美杜裟:AwADCAQABAoAAA==.',['�']='老師:AwACCAIABRQAAA==.耐奧祖:AwAICAkABAoAAA==.',['�']='舍予心:AwAGCAYABRQDCwAGAQjNAQAzMnwBBRQACwAFAQjNAQA5EnwBBRQADAABAQjGDwAbtFwABRQAAA==.',['�']='芙莉莲梦露:AwACCAcABRQCGgACAQhuHwBN3KwABRQAGgACAQhuHwBN3KwABRQAAA==.芯楠:AwAICAgABAoAAA==.',['�']='范海辛:AwAFCAoABAoAAQwAPGsDCAkABRQ=.',['�']='蓝染:AwAHCAsABAoAAA==.',['�']='装备回收:AwAICAgABAoAAA==.',['�']='触手猴:AwACCAcABRQCCAACAQjTFwAO0lgABRQACAACAQjTFwAO0lgABRQAAA==.',['�']='贾斯特杜伊特:AwACCAcABRQDDQACAQiADwAyRpoABRQADQACAQiADwAyRpoABRQAFwABAQjYOAA3O0YABRQAAA==.',['�']='远离死亡使者:AwADCAMABAoAAA==.',['�']='遵纪守法:AwAECAQABRQAAA==.',['�']='随心而激动:AwADCAMABAoAAA==.随风之曦:AwAECAQABRQAAA==.',['�']='青雷帝君:AwAICAgABAoAAA==.非常人贩:AwACCAIABRQAAA==.',['�']='马泽法克尔:AwAECAQABRQAAA==.',['�']='骑士小莺:AwAICBgABAoCBQAIAQgoMgBRKToCBAoABQAIAQgoMgBRKToCBAoAAA==.',['�']='魅影如风:AwACCAQABRQDFAAIAQhPBwBUP5ICBAoAFAAIAQhPBwBT5JICBAoAEwAIAQhpLQAvB2cBBAoAAA==.魅惑女神:AwAGCAQABAoAAA==.',['�']='鱼泡泡:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end