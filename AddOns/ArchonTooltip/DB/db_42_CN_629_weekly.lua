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
 local lookup = {'Unknown-Unknown','Priest-Discipline','Priest-Holy','Priest-Shadow','Druid-Restoration','Warrior-Fury','Shaman-Restoration','Shaman-Enhancement','DeathKnight-Blood','DemonHunter-Vengeance','Paladin-Protection','Mage-Frost','Paladin-Holy','Monk-Mistweaver','Paladin-Retribution','Druid-Balance','DeathKnight-Unholy','Mage-Fire','Monk-Windwalker','Monk-Brewmaster','Warrior-Protection',}; local provider = {region='CN',realm='夏维安',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alele:AwAECAQABRQAAA==.',Ay='Ayueyue:AwAECAQABRQAAQEAAAAECAQABRQ=.',Ca='Carando:AwEECAQABRQAAQEAAAAECAQABRQ=.',De='Deathdirge:AwAECAQABAoAAA==.Deepray:AwAECAgABRQDAgAEAQiMCwAtd9YABRQAAgAEAQiMCwAtd9YABRQAAwAEAQjtDQAEqJwABRQAAQQAO50GCA4ABRQ=.Devilone:AwAICBMABAoAAA==.',Di='Dijin:AwAECAkABAoAAA==.',Ex='Excelsior:AwADCAIABAoAAA==.',Fa='Faeries:AwADCAMABRQAAQUAPyYICAsABRQ=.',Fe='Fearmonger:AwAECAQABAoAAA==.',Ka='Kay:AwADCAMABAoAAA==.',Mo='Monesy:AwACCAIABRQAAA==.',Ne='Neverflee:AwACCAQABRQCBgAIAQgyGwA9thwCBAoABgAIAQgyGwA9thwCBAoAAA==.',Ol='Oldwong:AwAICBUABAoCBgAIAQiFHwA2IwACBAoABgAIAQiFHwA2IwACBAoAAA==.',Qi='Qingdao:AwAECAQABRQAAA==.',Qu='Quin:AwAGCAYABAoAAA==.',Th='Thunderbolt:AwACCAIABAoAAA==.',Up='Uplift:AwAICAgABAoAAA==.',Wa='Waitforyou:AwACCAIABAoAAA==.',Zi='Zireal:AwABCAEABAoAAA==.',['�']='三莜:AwAECAUABRQCBwAEAQiJBwBAFwQBBRQABwAEAQiJBwBAFwQBBRQAAQgAM3YICAkABRQ=.不可言语:AwAICAgABAoAAA==.专门逮螃蟹:AwAICAoABAoAAA==.丨八喜丨:AwAGCAkABAoAAA==.丨灵魂之翼丨:AwAFCAEABAoAAA==.丨饺子:AwADCAgABRQCCQADAQixGQADPEQABRQACQADAQixGQADPEQABRQAAA==.丶一身貓餅:AwAICAgABAoAAA==.丶亵渎:AwACCAIABRQCCgAIAQi/HwAn0kwBBAoACgAIAQi/HwAn0kwBBAoAAA==.丶小语:AwACCAcABRQCAwACAQg9EwAdHnkABRQAAwACAQg9EwAdHnkABRQAAA==.为梦而战:AwAFCAEABAoAAA==.丿永灬恒丶:AwAFCAUABAoAAA==.丿魍灬魉丶:AwAECAIABRQAAA==.',['�']='九龙湖墩哥:AwAGCBcABAoCCwAGAQj4KwAedssABAoACwAGAQj4KwAedssABAoAAA==.书童灬小贼:AwADCAMABAoAAA==.',['�']='五岛灭九:AwABCAEABRQAAA==.亖极度深寒亖:AwAECAQABRQAAA==.',['�']='优秀潜力股:AwABCAIABRQAAA==.',['�']='克莱斯顿:AwACCAMABRQAAA==.',['�']='再见老恶魔:AwAICAgABAoAAA==.军团再临:AwABCAEABRQCDAAHAQi2OQArnVcBBAoADAAHAQi2OQArnVcBBAoAAA==.冬天的冬:AwAECAQABRQAAA==.冰冷的热血:AwACCAIABRQAAQQAXloECAEABRQ=.冷淡夜风:AwACCAcABRQCCgACAQgtCwArk4IABRQACgACAQgtCwArk4IABRQAAA==.',['�']='几十个李宇春:AwAICAUABAoAAA==.',['�']='刃丶殇情:AwAFCAUABAoAAA==.初小帅:AwADCAMABAoAAA==.',['�']='十年乄如一:AwAGCBoABAoCDQAGAQi2JQAohPcABAoADQAGAQi2JQAohPcABAoAAA==.千早愛音:AwAICBEABAoAAA==.半糖小天才:AwAGCAgABAoAAA==.',['�']='叶丹:AwAGCAsABAoAAQ4AG6MGCAsABRQ=.司马夏侯:AwAICAgABAoAAA==.',['�']='吃干锅:AwAICAwABAoAAA==.',['�']='周大褔:AwACCAIABAoAAA==.',['�']='回忆无限:AwAICAgABAoAAA==.',['�']='地狱吼丨甜瓜:AwAGCAYABAoAAA==.',['�']='夜守求的野望:AwAGCAEABAoAAQEAAAAICBMABAo=.大帝的阿妮斯:AwAGCAoABAoAAA==.大暖龙:AwACCAIABAoAAA==.大甜瓜:AwAECAQABAoAAA==.天达尔卡门:AwADCAMABAoAAA==.',['�']='威廉香皇一世:AwABCAEABAoAAA==.',['�']='小咣头:AwAICAgABAoAAA==.小害怕:AwAECAIABRQAAA==.小猪木哈哈:AwAECAYABRQCDQAEAQhYAwBObAEBBRQADQAEAQhYAwBObAEBBRQAAQ8AS6QGCAoABRQ=.小角的熊喵:AwAECAgABRQCEAAEAQj5CwBIXPgABRQAEAAEAQj5CwBIXPgABRQAAA==.尼飞比特:AwAGCAYABAoAAA==.',['�']='希尔梅丽雅:AwAECAEABRQAAA==.希里亚斯:AwAICAYABAoAAA==.帘后的月光:AwAECAQABAoAAA==.帯灵魂漫步:AwABCAEABAoAAA==.',['�']='幸以:AwAICAMABAoAAA==.幻影棒棒糖:AwAGCAoABAoAAA==.',['�']='德了罢:AwAFCAUABAoAAA==.',['�']='忄牛大:AwADCAQABRQCDwAIAQicPABQEBYCBAoADwAIAQicPABQEBYCBAoAAA==.',['�']='愤怒的豆腐:AwABCAEABAoAAA==.',['�']='我是个墓师:AwAHCBgABAoCEQAHAQgmOgBCtJUBBAoAEQAHAQgmOgBCtJUBBAoAAA==.我是大牛哥:AwAICAgABAoAAA==.我是奶豆贼:AwAECAQABAoAAA==.我是幻影圣狙:AwAGCAYABAoAAQEAAAAGCAoABAo=.',['�']='执酒醉迷离丶:AwAECAQABAoAAA==.',['�']='拉斯塔哈大王:AwAECAQABRQAAA==.',['�']='散板:AwAFCAcABAoAAA==.',['�']='无名法神:AwABCAEABAoAAA==.无尽屠戮:AwAECAQABRQAAA==.无心制裁:AwAECAUABAoAAA==.',['�']='明人不说暗话:AwAGCAYABAoAAA==.星河长明:AwABCAEABAoAAA==.',['�']='最爱书宝呗:AwABCAIABRQAAA==.',['�']='来真德:AwAECAgABRQCEAAEAQgRBgBbAR4BBRQAEAAEAQgRBgBbAR4BBRQAAA==.',['�']='枫叶微黄:AwADCAMABAoAAA==.',['�']='柏云:AwADCAQABAoAAA==.柯妮丽娅:AwAECAsABRQCDQAEAQhtAgBaZRIBBRQADQAEAQhtAgBaZRIBBRQAAA==.',['�']='栀意乌龙茶:AwAICAgABAoAAQEAAAAECAQABRQ=.',['�']='梦飛雪:AwADCAYABAoAAA==.',['�']='森之黑山羊:AwACCAIABRQAAA==.',['�']='樱落灬天堂:AwAECAQABRQAAA==.',['�']='橘小美分美:AwADCAMABAoAAA==.',['�']='毁梦:AwADCAUABAoAAA==.毛乐:AwAGCAgABRQDEAAGAQgPAgAaX1kBBRQAEAAGAQgPAgAaX1kBBRQABQABAQh/FwA9pkkABRQAAA==.',['�']='沉睡的美杜莎:AwABCAIABRQAAA==.没虱子的牛:AwAFCAUABAoAAA==.油炸土克勒:AwAGCAgABAoAAA==.',['�']='法力值不足:AwAICBkABAoDAgAIAQhrGgA3F8sBBAoAAgAIAQhrGgA3F8sBBAoAAwAGAQhjSwAhptwABAoAAA==.',['�']='海洋的堕落:AwAECAoABRQDEAAEAQiqEQAsIN4ABRQAEAAEAQiqEQAsIN4ABRQABQABAQgAHQAK8zMABRQAAA==.',['�']='溜溜哥不得溜:AwACCAIABAoAAA==.',['�']='漫漫:AwACCAIABAoAAA==.',['�']='灬玄玉:AwABCAEABRQAAA==.',['�']='炖鸡喔:AwAECAQABRQAAA==.',['�']='爱吃汉堡王:AwAGCAYABAoAAA==.爱吃肯德基:AwACCAQABRQAAA==.爱小熊:AwAGCAcABAoAAA==.',['�']='牛奶会有的:AwAECAQABRQAAA==.牢底坐穿:AwAGCAoABAoAAA==.牧小雅:AwABCAUABRQDAgABAQjWHAA8uUUABRQAAgABAQjWHAA8uUUABRQAAwABAQh3HwANODEABRQAAA==.',['�']='琪琪与牛牛:AwABCAEABRQAAA==.',['�']='真水幽香:AwAGCBoABAoDDAAGAQhxMwBGh3gBBAoADAAGAQhxMwBGh3gBBAoAEgAFAQhXaQAUI64ABAoAAA==.真理在射程内:AwAICAkABAoAAA==.',['�']='祸祸牛:AwABCAEABAoAAA==.',['�']='科雷负能量:AwAECAQABRQAAA==.',['�']='穿心丶:AwAICAgABAoAAA==.',['�']='织雾潘达:AwACCAMABRQCDgAIAQj5DwBMAFMCBAoADgAIAQj5DwBMAFMCBAoAAA==.',['�']='罐头瓶:AwAECAQABAoAAA==.罒鳕熊罒:AwAICAMABAoAAA==.',['�']='若萌初醒:AwAFCAwABAoAAA==.英皇丶美屡:AwAECAQABRQAAA==.',['�']='草莓酱:AwAECAQABRQAAA==.',['�']='落幕之舞:AwADCAYABRQCCQADAQhOGwAA2zkABRQACQADAQhOGwAA2zkABRQAAA==.',['�']='蓉城大熊猫:AwAGCAEABAoAARMALVwGCAoABRQ=.蓝怒:AwADCAMABAoAAA==.',['�']='西何庄吴彦祖:AwAGCAcABAoAAA==.西敏寺的夜:AwAGCAYABAoAAA==.',['�']='诸法:AwEECAQABRQAAA==.',['�']='达蕾妮亚:AwAECAQABAoAAA==.',['�']='迷途的未来:AwAFCAUABAoAAA==.',['�']='阿尔卑斯暴风:AwAECAQABRQAAA==.阿爾蕯斯:AwAECAUABRQCEQAEAQhhCAA95AIBBRQAEQAEAQhhCAA95AIBBRQAAA==.',['�']='陌丄花开丶:AwADCAgABRQCFAADAQg4BQAMJn8ABRQAFAADAQg4BQAMJn8ABRQAARUALyoICAoABRQ=.陌寒烟:AwACCAIABRQAAA==.',['�']='隔壁王大爷:AwAHCAIABAoAAA==.',['�']='雨帆儿:AwABCAEABAoAAA==.',['�']='霜之哀痕:AwABCAEABRQAAA==.霸气小翅膀:AwAICAgABAoAAA==.',['�']='风吹雪:AwACCAQABRQAAA==.风神的神德:AwAICAUABAoAAA==.飒飒伊香:AwAHCAcABAoAAA==.飞鸟:AwACCAQABRQCDAAIAQgkBwBb7sECBAoADAAIAQgkBwBb7sECBAoAAA==.',['�']='马革裹尸:AwAGCAYABAoAAA==.驯麓:AwABCAEABRQAAA==.',['�']='魏淑芬:AwAECAgABRQCBgAEAQg1AwBdXkEBBRQABgAEAQg1AwBdXkEBBRQAARIAMkEGCAgABRQ=.',['�']='鹿鸣之什:AwAGCAQABRQAAA==.',['�']='黑白:AwAFCAUABRQCDgAFAQi3AQBMy5oBBRQADgAFAQi3AQBMy5oBBRQAAA==.',['�']='龙女神月:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end