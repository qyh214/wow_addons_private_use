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
 local lookup = {'DemonHunter-Havoc','Unknown-Unknown','DeathKnight-Blood','Rogue-Subtlety','Druid-Balance','Druid-Feral','Evoker-Augmentation','Evoker-Devastation','Rogue-Assassination','Priest-Discipline','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Shadow','Monk-Mistweaver','Hunter-Marksmanship','Warrior-Fury','Paladin-Retribution','Druid-Restoration','Hunter-BeastMastery','Paladin-Protection','Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','Mage-Fire','Warrior-Arms','Evoker-Preservation',}; local provider = {region='CN',realm='梅尔加尼',name='CN',type='weekly',zone=42,date='2025-04-14',data={Da='Darkgirl:AwAECAgABRQCAQAEAQhFDwA3ivAABRQAAQAEAQhFDwA3ivAABRQAAA==.Darnassia:AwADCAQABAoAAA==.',Fr='Frierenamy:AwACCAIABRQAAQIAAAAGCAIABRQ=.',Gr='Gracefulboy:AwAECAYABRQCAwAEAQiPAgBdM0YBBRQAAwAEAQiPAgBdM0YBBRQAAA==.',Ho='Holyassasin:AwAGCAQABRQAAA==.',Im='Imnmnmn:AwAGCAYABRQCBAAEAQiPCAAfftYABRQABAAEAQiPCAAfftYABRQAAA==.',Jo='Joevy:AwACCAIABAoAAA==.',Li='Lileonerd:AwADCAUABRQDBQADAQgRFgAlcrwABRQABQADAQgRFgAUSbwABRQABgABAQi5BQBbqFsABRQAAA==.Limerence:AwAICBAABAoAAA==.',Lu='Lucelly:AwAICAgABAoAAA==.Lucy:AwACCAIABRQAAA==.',Ni='Nien:AwAFCAUABAoAAA==.',Ol='Olalala:AwAICAgABAoAAA==.',Se='Secretxcsy:AwAGCAYABAoAAA==.',Su='Sunobeach:AwADCAMABAoAAA==.',Sy='Sylanna:AwAICBkABAoDBwAIAQhMAQA/rLoBBAoABwAGAQhMAQBEA7oBBAoACAAFAQh2OAAu0bMABAoAAA==.',On='onlyfans:AwADCAMABRQAAA==.',['�']='一点点:AwAFCAUABAoAAA==.下壹站天後:AwAECAQABRQAAA==.不知名的酱某:AwACCAMABRQDCQAIAQh3BgBXc4YCBAoACQAIAQh3BgBXc4YCBAoABAAEAQhxIQA3DPgABAoAAA==.丨言射丨:AwADCAEABAoAAA==.丶云中君:AwABCAEABRQAAA==.丶尐楊哥哥:AwAGCAYABAoAAA==.丶尛楊哥哥:AwAECAQABAoAAA==.丶时光:AwAFCAUABAoAAA==.丶绯弹:AwAECAQABRQAAA==.',['�']='乌鸦君:AwAGCAoABRQCCQAGAQgVAABTfR4CBRQACQAGAQgVAABTfR4CBRQAAA==.九十六:AwAECAcABAoAAA==.九月微澜:AwACCAIABAoAAA==.九龄:AwAECAQABRQAAA==.',['�']='云霄:AwAICAgABAoAAA==.五仁冰激凌:AwAICAcABAoAAA==.',['�']='伏魔御厨:AwAICAMABAoAAA==.',['�']='低语丶小明:AwACCAIABAoAAA==.',['�']='侵她国做她王:AwAICAgABAoAAA==.',['�']='偊多雷:AwAGCAYABAoAAQoAUJsGCA4ABRQ=.',['�']='傻逗:AwACCAIABRQECwAIAQj3HgBaKvUBBAoACwAGAQj3HgBcFfUBBAoADAAEAQiIKABX3QcBBAoADQACAQiwLABTG3oABAoAAQ4AVMAECAgABRQ=.',['�']='僧格林沁:AwABCAEABAoAAA==.',['�']='元气少女张飞:AwAECAQABRQAAA==.光散落地方:AwAICAoABAoAAA==.光明大天使:AwABCAEABRQAAA==.全家桶:AwACCAYABRQCDwACAQgMFABMUKkABRQADwACAQgMFABMUKkABRQAARAAVEkDCAwABRQ=.',['�']='冲锋只需勇气:AwAECAoABRQCEQAEAQhMBQBKRSYBBRQAEQAEAQhMBQBKRSYBBRQAAA==.',['�']='凌风:AwAHCAEABAoAAA==.',['�']='别问灬一波拉:AwAGCAEABAoAAA==.',['�']='剑锋所指:AwACCAMABRQAAA==.',['�']='北冥冇鱼:AwACCAIABRQCEgAIAQiJFQBXwK4CBAoAEgAIAQiJFQBXwK4CBAoAAA==.',['�']='原神高手:AwAECAMABRQAAA==.',['�']='呜啦呜啦啦:AwAECAQABAoAAA==.',['�']='和风轻舞:AwAECAgABRQCEgAEAQhQEgBCPPgABRQAEgAEAQhQEgBCPPgABRQAAREARjcFCBAABRQ=.咕咕菇孤城:AwAECAYABRQDBQAEAQhWCwA4j/oABRQABQAEAQhWCwA4j/oABRQAEwABAQiyGAAp1UAABRQAAA==.咖啡卜佳棠:AwACCAUABRQCDwACAQgpGwAT74EABRQADwACAQgpGwAT74EABRQAAA==.',['�']='哀伤的糖:AwAECAEABRQAAA==.哈喽疯帅:AwAICAcABAoAAA==.',['�']='噬魂摄魄:AwAICA8ABAoAAA==.',['�']='圣光巧克力:AwAICAMABAoAAA==.地狱的毁灭:AwAECAgABRQDCwAEAQiNDAArEt4ABRQACwAEAQiNDAAqNN4ABRQADQADAQjuCAAaPswABRQAAA==.',['�']='墨菲定律:AwAGCAIABRQAAA==.',['�']='夜幕美美:AwAGCAsABAoAAA==.大锤师太:AwAICAgABAoAAA==.大马哥:AwAGCAEABRQAAA==.天上白玉京冫:AwAICAgABAoAAA==.天外妃仙:AwAFCAkABAoAAA==.',['�']='如履薄冰冰:AwAECAQABRQAAA==.如意馨享:AwAHCAcABAoAAA==.',['�']='孟根巴特:AwAECAQABRQAAA==.',['�']='富婆追猎者:AwAGCAoABRQDEAAGAQgpAABHJcwBBRQAEAAGAQgpAABHJcwBBRQAFAAEAQhmFQA2C+QABRQAAA==.',['�']='小卜丶:AwACCAIABAoAAA==.小对钩:AwACCAMABRQAAA==.小树暖暖:AwAECAgABRQDDgAEAQgUBgBUwBoBBRQADgADAQgUBgBUwBoBBRQACgADAQhhEABHMagABRQAAA==.尼古拉斯凯萨:AwAICAgABAoAAA==.',['�']='屈服丶信仰:AwAGCAoABRQDFQAGAQghAwBAASEBBRQAFQAGAQghAwAaGiEBBRQAEgAEAQj3DQBcFwgBBRQAAA==.',['�']='岑水:AwABCAEABRQAAA==.',['�']='巴黎世家:AwAECAQABRQAAA==.',['�']='弗拉迪米尔:AwAICAQABRQAAA==.',['�']='心脏起搏器:AwACCAMABRQAAA==.',['�']='我好脆弱:AwAICAgABAoAAA==.我既圣光:AwAECAIABRQAAA==.我要吃鱼:AwAICAoABAoAAA==.',['�']='把你刻在掌心:AwACCAUABRQCBQACAQiqGQBGiaEABRQABQACAQiqGQBGiaEABRQAAA==.把泪寄給海:AwADCAcABRQCFgADAQgDAQBgNEkBBRQAFgADAQgDAQBgNEkBBRQAAA==.把泪寄给海:AwAICAYABAoAAA==.',['�']='揪下猫耳:AwAECAQABRQAAA==.',['�']='斗牛爱馉頭:AwAECAMABRQAAQIAAAAICAQABRQ=.',['�']='日番谷冬狮郎:AwAECAQABRQAAA==.时光与月丶:AwAECAcABRQCAwAEAQjmFQAFpmoABRQAAwAEAQjmFQAFpmoABRQAAA==.',['�']='星街彗星:AwACCAIABRQAAA==.昨夜清风:AwAGCAYABAoAAA==.',['�']='暗影国度:AwAICA4ABAoAAA==.暗牧不玩球了:AwAICAgABAoAAA==.',['�']='曾经很嚣张:AwAECAQABRQAAA==.',['�']='枫与铃:AwACCAUABRQCEgACAQjTKwArNY4ABRQAEgACAQjTKwArNY4ABRQAARAAVEkDCAwABRQ=.枫之记忆:AwAICBQABAoDFgAIAQh8HwA2E8ABBAoAFgAIAQh8HwA2E8ABBAoAFwAGAQi1ZQAiFt4ABAoAAA==.',['�']='柒丶月:AwAGCAcABAoAAA==.柠檬糖:AwACCAIABRQAAA==.',['�']='梦回蝶恋:AwAECAQABRQAAA==.梦境客:AwABCAEABRQAAA==.',['�']='樱丨桃:AwAHCA0ABAoAAA==.',['�']='歡喜佛:AwAECAEABAoAAA==.',['�']='残花殇祭:AwAICAoABRQDFwAIAQiKDAA2ceIABRQAFwAEAQiKDAAp1OIABRQAGAAGAQgACgA6+tQABRQAAA==.',['�']='永恒琴絃:AwAGCAQABRQAAA==.',['�']='沙漠涙痕:AwAECAUABRQDBQAIAQiGDwBX9JYCBAoABQAIAQiGDwBX9JYCBAoABgABAQg2KgAqai4ABAoAAA==.没毛的乌鸦:AwAGCAYABAoAAA==.',['�']='泛舟当歌:AwAECAgABRQCFAAEAQhtCABU1SEBBRQAFAAEAQhtCABU1SEBBRQAAQIAAAAICAQABRQ=.',['�']='深森丶:AwADCAUABRQCGQADAQj/EgA0w+wABRQAGQADAQj/EgA0w+wABRQAAA==.',['�']='澄澄爸爸:AwADCAQABAoAAA==.',['�']='灬蜗丶牛灬:AwADCAMABAoAAA==.灰烬之末:AwAGCAYABAoAAA==.',['�']='炎爆丶术:AwACCAIABRQAAA==.',['�']='無浪丨劣銫:AwABCAEABRQCFAAIAQgQNAA+af8BBAoAFAAIAQgQNAA+af8BBAoAAA==.焱灬淼:AwAICAkABAoAAA==.',['�']='牙丸千军:AwAGCAoABAoAAA==.',['�']='狂啃蟑螂脚:AwAICBAABAoAAA==.',['�']='王权冨贵:AwAICAgABAoAAA==.玛其萨:AwAECAQABRQAAA==.',['�']='琴月陽:AwAECAwABRQDEAAEAQg9BABY5ggBBRQAEAAEAQg9BABMAggBBRQAFAADAQj0HQBalq0ABRQAAA==.',['�']='瑶海丶笙歌:AwAECAMABRQAAA==.',['�']='疏琉月影:AwAECAEABRQAAA==.',['�']='白琻耳环:AwAECAQABRQAAA==.',['�']='直通天命:AwAGCAcABRQDEQAGAQjAAQA2FH4BBRQAEQAFAQjAAQA2BX4BBRQAGgABAQhDDwA2Ul8ABRQAAA==.',['�']='睡十:AwAECAQABRQAAA==.',['�']='知挚:AwACCAEABAoAAA==.',['�']='秘密:AwAICAsABAoAAA==.',['�']='筱湜伊:AwAICAgABAoAAA==.',['�']='糖门不要滚:AwADCAMABAoAAA==.',['�']='紫咲诗音:AwAECAQABRQAAA==.',['�']='胡桃大王:AwADCAQABRQAAA==.',['�']='脱脂龙奶:AwAGCAIABRQCGwACAQhiBgAmkXIABRQAGwACAQhiBgAmkXIABRQAAA==.',['�']='自由丶天棠鸟:AwAICBEABAoAAA==.',['�']='航航贝贝:AwAECAQABRQAAA==.',['�']='苏小肆:AwACCAIABRQAAA==.',['�']='草台班子核心:AwAECAQABRQAAA==.草莓大侦探:AwAICAgABAoAAA==.',['�']='萌面歹徒:AwAECAQABRQAAA==.落天歌:AwAECAgABRQCBQAEAQgMBwBO6BYBBRQABQAEAQgMBwBO6BYBBRQAAA==.',['�']='蛮鼠皮卡丘:AwADCAwABRQDEAADAQj3AQBUSSkBBRQAEAADAQj3AQBUSSkBBRQAFAACAQh/IgBIi5sABRQAAA==.',['�']='袖中棉绒:AwAICAgABAoAAA==.',['�']='豆包儿:AwAFCAEABAoAAA==.豕巴拉谷:AwAECAQABRQAAA==.豪森布鲁斯:AwACCAIABRQAAA==.',['�']='赵日天:AwAFCAcABAoAAA==.',['�']='轻装简僧:AwABCAEABRQCDwAIAQjVCwBQaXwCBAoADwAIAQjVCwBQaXwCBAoAAA==.',['�']='辛多雷摄政王:AwAECAQABAoAAA==.',['�']='迎风怖阵:AwACCAQABRQAAA==.',['�']='邪刃屠灵:AwABCAEABAoAAA==.',['�']='野寇崽:AwABCAEABRQDFAAIAQiwMgA84QUCBAoAFAAIAQiwMgA84QUCBAoAEAACAQieYgAXE1EABAoAAA==.',['�']='阿布无敌丨法:AwAICAgABAoAAA==.阿布无敌丨萨:AwAECAQABRQAAA==.阿比亚斯:AwAECAQABRQAAA==.阿苏油盐卷:AwADCAwABRQCFgADAQhyBwAskd8ABRQAFgADAQhyBwAskd8ABRQAAA==.',['�']='陌丶尕成:AwACCAQABRQAARMAPyYICAsABRQ=.',['�']='雨落儿:AwACCAEABRQAAA==.雷霆霹雳酒桶:AwAICBAABAoAAA==.',['�']='霜火追忆:AwADCAMABRQAAA==.霸粑:AwAICAkABAoAAA==.',['�']='静的守护骑士:AwAGCAYABAoAAA==.',['�']='风舞轻杨:AwABCAEABAoAAA==.风落眼前花:AwAICAcABAoAARQAPf8GCAkABRQ=.',['�']='骑科多飙车:AwAECAQABRQAAA==.骑驴看大海:AwAHCAYABAoAAA==.骚气灬蓬勃:AwAICAYABAoAARgAS9AGCAoABRQ=.',['�']='鸡歪怪马桶漏:AwAECAQABAoAAA==.',['�']='麦克阿瑟大校:AwAICAgABAoAAA==.麦趣鸡盒:AwADCAgABRQCAQADAQjsEwAmU9sABRQAAQADAQjsEwAmU9sABRQAARAAVEkDCAwABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end