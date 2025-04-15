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
 local lookup = {'Druid-Restoration','Priest-Holy','Warrior-Protection','Warrior-Arms','Unknown-Unknown','Mage-Fire','Mage-Frost','DeathKnight-Unholy','DemonHunter-Vengeance','DemonHunter-Havoc','Paladin-Retribution','Shaman-Restoration','Druid-Balance','Priest-Discipline','Warlock-Destruction','DeathKnight-Blood','Monk-Mistweaver',}; local provider = {region='CN',realm='加里索斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ge='Gestorben:AwACCAQABAoAAQEAOtUDCAcABRQ=.',He='Headshoot:AwABCAEABAoAAA==.',Po='Popcorn:AwADCAMABAoAAA==.',Ro='Rousally:AwAECAQABRQAAA==.',['�']='一只小德:AwAGCAgABAoAAA==.一记闪电箭丶:AwAECAQABRQAAA==.七夕:AwACCAIABRQAAA==.七宝宝欺七七:AwADCAkABRQCAgADAQiCAwBLXhEBBRQAAgADAQiCAwBLXhEBBRQAAA==.三寸灰丶:AwABCAEABAoAAA==.上官慕容:AwAGCAkABAoAAA==.世界牧:AwAGCAEABAoAAA==.丨岸边丨:AwAGCAYABAoAAA==.丨無畏丨:AwAECAQABRQAAA==.丶熊吉君:AwAGCBUABAoCAwAGAQibDQBMFqkBBAoAAwAGAQibDQBMFqkBBAoAAA==.为你羞死:AwAECAQABRQAAA==.丿寶小爺:AwAICAgABAoAAA==.',['�']='乄勺滇滇乄:AwAHCAQABAoAAA==.',['�']='代达罗斯之殇:AwAECAIABRQAAA==.',['�']='倾城微微一笑:AwAFCAQABAoAAA==.',['�']='养啥死啥:AwAICAoABAoAAA==.',['�']='冰蓝的华尔兹:AwACCAQABRQCBAAGAQiRHQBE+pcBBAoABAAGAQiRHQBE+pcBBAoAAA==.冰雁:AwAICAgABAoAAQUAAAACCAIABRQ=.',['�']='凉拌折耳根:AwADCAMABAoAAA==.凝光者丶芷翾:AwADCAMABRQAAA==.',['�']='别的熊没我纯:AwABCAEABRQAAA==.',['�']='包夜伍千:AwABCAEABRQAAA==.包蓉兴灬:AwAECAIABRQAAA==.北落长空:AwAGCAYABRQCBgAGAQiOAwAlGZEBBRQABgAGAQiOAwAlGZEBBRQAAA==.',['�']='千寻丶晗香:AwAICAgABAoAAA==.南宫刃锋:AwAHCAcABAoAAA==.博丶哥:AwABCAEABAoAAA==.',['�']='只想快乐玩:AwABCAEABRQAAA==.',['�']='吞天噬地:AwAECAQABAoAAA==.吴杰超:AwABCAEABRQAAA==.',['�']='呆贼丶:AwAECAQABRQAAA==.',['�']='噬丨影:AwAGCAYABAoAAA==.',['�']='圣光的乐章:AwAICAgABAoAAA==.',['�']='堕落灬摩羯座:AwACCAIABRQAAA==.',['�']='塔拉夏丶:AwAECAgABRQDBwAEAQjMAABhMkIBBRQABwAEAQjMAABgAEIBBRQABgAEAQjfCABWxyIBBRQAAQYAWWMGCBQABRQ=.',['�']='夏沫离殇:AwAFCAkABAoAAA==.夏玧沫丶:AwAHCAYABAoAAA==.',['�']='奇异果益菌多:AwAGCAkABAoAAA==.',['�']='嫒橹蒽:AwADCAMABAoAAA==.',['�']='安使尊者:AwAGCAsABAoAAA==.安屠生:AwAECAEABRQAAA==.宵雀:AwAHCAcABAoAAA==.家有仙喵丶:AwAECAQABRQAAA==.',['�']='小别兔别又别:AwAECAQABRQAAA==.小田原的飞鸟:AwABCAEABRQAAQgAR9MCCAQABRQ=.小老壮:AwAGCAYABAoAAA==.小胡胡:AwACCAMABAoAAA==.小苹果动物园:AwAECAIABRQAAQUAAAAGCAQABRQ=.小苹果贼红手:AwAICAcABAoAAA==.小黃的大鬍子:AwACCAIABRQAAA==.',['�']='山狗子:AwACCAIABRQAAA==.',['�']='市丸影:AwAECAEABRQAAA==.帽子戏法:AwABCAEABRQAAA==.',['�']='彼界:AwADCAMABRQAAA==.彼界恶魔:AwADCAwABRQCCQADAQgHCAAd4KgABRQACQADAQgHCAAd4KgABRQAAA==.',['�']='快乐肥宅咕:AwAECAIABRQAAA==.',['�']='恒源祥丶:AwAECAQABRQAAQYAWWMGCBQABRQ=.恶魔不是猎手:AwAECAQABRQAAA==.',['�']='悲鸣屿丶行鸣:AwAECAIABRQAAQcANI0GCA8ABRQ=.',['�']='我叫明月儿:AwABCAEABRQAAA==.',['�']='掀起你的辫子:AwABCAEABRQAAA==.',['�']='故事的尐黄花:AwAICA4ABAoAAA==.',['�']='旋转棒棒糖:AwAECAQABRQAAA==.旋转的熊猫:AwACCAIABAoAAA==.时光之翼:AwACCAQABRQCBwAIAQiuDABaB4ICBAoABwAIAQiuDABaB4ICBAoAAA==.',['�']='晨峰寒:AwAECAQABAoAAA==.晨枫:AwAGCAYABAoAAA==.',['�']='暗月凋零:AwACCAIABRQAAA==.',['�']='月光熊猫:AwAICAgABAoAAA==.月魂星眸:AwAGCAYABAoAAA==.有火没烟:AwAHCAEABAoAAA==.有這麼一個人:AwACCAMABRQCBAAHAQg8FgBCkNkBBAoABAAHAQg8FgBCkNkBBAoAAA==.',['�']='枫之吉哑:AwACCAIABAoAAA==.',['�']='梅塔特隆:AwAICBAABAoAAA==.梦游:AwAGCAoABAoAAA==.',['�']='樱桃蓝莓酱:AwACCAIABAoAAA==.',['�']='橙装蛋:AwABCAEABAoAAA==.',['�']='河马爸爸:AwAHCAoABAoAAA==.',['�']='泾河滩:AwAECAQABRQAAA==.',['�']='流逝晓落:AwAGCAsABAoAAA==.',['�']='淡淡烟味:AwAFCAUABAoAAA==.深渊邪圣:AwAECAQABAoAAA==.',['�']='温蕾萨:AwAGCAYABAoAAA==.',['�']='湘江北上:AwAICAMABAoAAQYAJ70GCAoABRQ=.湮之暮色:AwAECAQABAoAAA==.',['�']='演武坪买醉:AwAHCA4ABAoAAA==.',['�']='火之狂舞丶:AwAECAQABRQAAA==.灭世白骨:AwABCAEABAoAAA==.',['�']='炫光:AwAECAQABRQAAA==.',['�']='無魚不歡:AwAICAgABAoAAA==.',['�']='爱老婆:AwACCAQABRQCCgAIAQixFQBN5moCBAoACgAIAQixFQBN5moCBAoAAA==.',['�']='牺牲:AwAECAYABAoAAA==.',['�']='王语琦:AwACCAUABRQCCwACAQjJJgA85JwABRQACwACAQjJJgA85JwABRQAAA==.玩喜怒哀:AwAECAgABRQCDAAEAQgYDAAqEOQABRQADAAEAQgYDAAqEOQABRQAAA==.玩情丧心:AwAGCAQABRQAAA==.玩铁大佬:AwAECAQABRQAAA==.',['�']='白丶桑:AwAICAgABAoAAA==.白天嚒嚒嗒:AwAICAkABAoAAA==.白马不是马:AwADCAcABRQDAQADAQgSBgA61e0ABRQAAQADAQgSBgA61e0ABRQADQABAAgAAAAzIAAABRQAAA==.',['�']='睡毛起来嗨:AwAECAQABRQAAQUAAAAECAQABRQ=.',['�']='石昊:AwAICAgABAoAAA==.',['�']='神圣:AwAECAEABRQAAA==.',['�']='筱霏妩:AwAICAgABAoAAA==.',['�']='粉口爱的老鼠:AwAECAYABRQCDgAEAQgaCABC9vUABRQADgAEAQgaCABC9vUABRQAAA==.',['�']='素素树:AwAGCAUABRQCDwAEAQiBDAA4vN4ABRQADwAEAQiBDAA4vN4ABRQAAA==.素衣:AwABCAEABRQAAA==.',['�']='绿川花:AwABCAMABRQAAA==.',['�']='肥肥骑士:AwAECAQABRQAAA==.',['�']='胖鸡玩猫巴丶:AwAECAQABRQAAA==.',['�']='花生牛戈糖:AwACCAUABRQCDAACAQiWEgBSHLsABRQADAACAQiWEgBSHLsABRQAAA==.',['�']='苏格兰小香猪:AwAFCAUABAoAAA==.',['�']='荆棘谷的山:AwAHCBYABAoCEAAHAQjEIwAvVj0BBAoAEAAHAQjEIwAvVj0BBAoAAA==.草莓元素:AwAGCAYABAoAAA==.',['�']='莫古利:AwAHCAkABAoAAA==.莫问余生:AwABCAEABRQAAA==.',['�']='蘇丶尛飒:AwABCAEABAoAAA==.',['�']='证道菩提:AwAICAIABAoAAA==.',['�']='贼兮兮:AwAICAgABAoAAA==.',['�']='路人张:AwABCAIABRQAAA==.',['�']='迷失幻觉:AwAECAQABAoAAA==.',['�']='邦邦:AwAHCAcABAoAAA==.',['�']='酒神归来:AwAHCAkABAoAAA==.',['�']='银耳雪梨羹:AwAGCAYABAoAAA==.',['�']='阿蒙丶神:AwACCAIABRQAAA==.阿鲁卡卡:AwAICAgABAoAAA==.',['�']='随地汏小棍:AwAECAQABAoAAA==.隐月珂珂:AwAECAQABRQAAA==.',['�']='霹雳无敌闪电:AwAECAQABRQAAA==.',['�']='青山下:AwAHCBEABAoAAA==.',['�']='飞廉:AwAECAQABRQAAA==.飞翔的德叔:AwADCAMABAoAAA==.',['�']='鲁魔:AwAICAoABAoAAA==.鲸鱼台风:AwACCAUABRQCEQACAQjJGgAVuoMABRQAEQACAQjJGgAVuoMABRQAAA==.',['�']='黑人专治宫寒:AwAFCAkABAoAAA==.',['�']='龘龖:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end