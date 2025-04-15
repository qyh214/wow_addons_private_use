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
 local lookup = {'Priest-Discipline','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Holy','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','Evoker-Devastation','DeathKnight-Unholy','Priest-Shadow','Warrior-Arms','Warrior-Fury','Paladin-Holy','Mage-Fire','Warrior-Protection','Monk-Mistweaver','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Mage-Frost','Warlock-Destruction','Druid-Balance','Druid-Restoration','Shaman-Enhancement','Druid-Guardian','Shaman-Restoration','Shaman-Elemental','Monk-Brewmaster','Monk-Windwalker','Warlock-Demonology',}; local provider = {region='CN',realm='血吼',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ak='Akibiv:AwACCAIABRQAAA==.',An='Anotherdáy:AwAHCAEABAoAAA==.',Ar='Aragorn:AwAICAkABAoAAA==.',Au='Aureablade:AwAGCAYABRQCAQAGAQgaAQBC3MQBBRQAAQAGAQgaAQBC3MQBBRQAAA==.',Ba='Batzz:AwADCAMABAoAAA==.',Ce='Celina:AwABCAEABRQDAgAIAQg9OQAnT6oBBAoAAgAIAQg9OQAmnKoBBAoAAwAGAQj7NQAckccABAoAAA==.',Cl='Clearlove:AwAICAwABAoAAA==.',Fo='Forrevenge:AwADCAMABRQAAA==.',Gg='Ggbondd:AwABCAEABRQAAA==.',Ma='Mangos:AwACCAYABRQCAgAIAQhKGgBIWlICBAoAAgAIAQhKGgBIWlICBAoAAA==.',Mo='Mortal:AwAGCAYABAoAAA==.',No='Noname:AwAICAcABAoAAA==.',Pr='Projoker:AwACCAIABRQAAA==.',Se='Severusx:AwABCAEABRQAAA==.',Sw='Sweep:AwAECAgABRQDAQAEAQjyCgBATOYABRQAAQAEAQjyCgBATOYABRQABAAEAQgiCwAb4coABRQAAA==.',Th='Theuglyboy:AwACCAIABRQAAA==.',Ya='Yap:AwAGCAQABRQAAA==.Yapzor:AwADCAMABAoAAA==.',['�']='一品香牛肉面:AwACCAIABRQAAA==.一记腻光啪飞:AwACCAIABRQAAA==.一骑当仟:AwADCAMABAoAAA==.一骨头一:AwACCAIABRQAAA==.七月乱射:AwACCAEABRQAAA==.三儿爸:AwACCAIABRQAAA==.三角酷儿:AwABCAEABRQAAQUAAAAICAEABRQ=.上半身是天使:AwACCAIABRQAAA==.丨宙斯丨:AwAICAgABAoAAA==.丨贪念丨:AwAECAgABRQDBgAEAQj2AgBQTyEBBRQABgAEAQj2AgBQTyEBBRQABwAEAQjXFAAtCO8ABRQAAA==.丨黑米粥丶:AwABCAMABRQAAA==.丶古月丶:AwACCAMABRQAAA==.丶圣傲天:AwAICAQABAoAAA==.丶殘轌:AwABCAIABRQDCAAHAQiVhAAqBW4BBAoACAAHAQiVhAAqBW4BBAoACQABAQisZQAAAAAABAoAAA==.丶沉寂:AwAGCAYABAoAAA==.丶萧瑟:AwAECAQABRQAAA==.丶麦旋旋风:AwAGCAgABAoAAA==.丹妮坦格利安:AwAICBQABAoCCgAIAQhKKAAhWUQBBAoACgAIAQhKKAAhWUQBBAoAAA==.举个大栗子:AwAECAcABRQCCwAEAQgKCgBMTv0ABRQACwAEAQgKCgBMTv0ABRQAAA==.丿豆灬豆:AwABCAEABAoAAA==.',['�']='乌兰巴托的夜:AwACCAIABRQAAA==.乐安:AwAGCAYABAoAAA==.习惯被依赖:AwADCAQABAoAAA==.',['�']='今天没灌注:AwAGCAgABRQCDAAEAQjDDwAbdswABRQADAAEAQjDDwAbdswABRQAAA==.代达罗斯丶:AwAECAgABRQCBgAEAQjpDgBN1bkABRQABgAEAQjpDgBN1bkABRQAAA==.',['�']='何必愁眉苦脸:AwADCAQABAoAAA==.你该罚:AwACCAUABRQDDQAIAQhNIgA+fnsBBAoADQAFAQhNIgBAA3sBBAoADgAGAQgHPQA1wV4BBAoAAA==.',['�']='倚剑醉清风:AwAICBYABAoDCAAIAQgdaQA1CqsBBAoACAAIAQgdaQA1CqsBBAoADwAEAQg0OgAfvnkABAoAAA==.',['�']='催肥你是我:AwABCAEABRQAAA==.傲雪之霸气:AwAHCA8ABAoAAA==.傻馒的主人:AwAICAEABAoAAA==.',['�']='儭儭汏洃哴丶:AwADCAEABAoAAA==.',['�']='全城死爱:AwACCAEABRQAAA==.',['�']='再举起个栗子:AwAICAgABAoAAA==.',['�']='刘玉玲:AwAHCAUABAoAAA==.利维:AwAECAQABRQAAA==.刷好这个防骑:AwABCAEABAoAAA==.',['�']='北极熊的弟弟:AwAGCA0ABAoAAA==.北风继续吹:AwADCAMABAoAAA==.',['�']='升竜拳丶:AwABCAEABRQAAA==.',['�']='叫我靓仔:AwAECAQABRQAAA==.可爱秋秋:AwAGCAYABAoAARAAMkEGCAgABRQ=.',['�']='吃我一发闪电:AwAFCAUABAoAAA==.吾乃哀木涕:AwACCAYABRQCEQAIAQgtGgAZnA4BBAoAEQAIAQgtGgAZnA4BBAoAAA==.',['�']='呀灭跌一枝花:AwAICBgABAoDCAAIAQhpdwAr1YwBBAoACAAHAQhpdwAxeIwBBAoACQABAQilYQAKAAsABAoAAA==.呔筱張:AwAGCAYABAoAAA==.呜喵喵:AwAICAUABAoAAA==.',['�']='咔皮巴拉:AwAECAQABRQAAA==.',['�']='哎呦喂灬:AwACCAIABAoAAA==.哎哟脑壳疼:AwAECAQABRQAAA==.',['�']='唐老师暗:AwAECAQABRQAAA==.唔西丶迪西:AwAECAgABRQCEgAEAQggEAAjgtoABRQAEgAEAQggEAAjgtoABRQAAQUAAAAGCAQABRQ=.',['�']='啾咪啾咪:AwABCAEABRQCCwAHAQhMLgBPMtUBBAoACwAHAQhMLgBPMtUBBAoAAA==.',['�']='善恶丶:AwAECAQABRQAAA==.',['�']='嗨皮圣姐:AwAECAQABRQAAA==.嗳星星的小孩:AwABCAEABRQAAA==.',['�']='嘲讽丶猫:AwABCAEABAoAAA==.',['�']='噜噜:AwACCAMABRQDAwAIAQhzCgBNAVcCBAoAAwAIAQhzCgBNAVcCBAoAAgAEAQgUawAm49wABAoAAA==.噬血无极:AwACCAIABRQAAA==.',['�']='困魂玫瑰:AwAICAkABAoAAA==.',['�']='圈圈法神:AwAECAQABRQAAA==.圣洁的阿昆达:AwABCAEABRQAAA==.',['�']='坂崎良:AwAHCAsABAoAAA==.',['�']='基情丶萧磊:AwACCAIABRQAAA==.',['�']='墨仙:AwAHCAsABAoAAA==.墨染青衣颜:AwAECAYABRQCCAAEAQhgEABIxAYBBRQACAAEAQhgEABIxAYBBRQAAA==.墨玦丶:AwAGCAYABAoAAA==.',['�']='壬水苍龙:AwAECAQABRQAAA==.',['�']='大丨乔:AwACCAIABRQAAA==.大姐:AwAICBAABAoAAA==.大恐龙丶:AwAICAQABAoAAA==.大船長:AwAECAgABRQEEwAEAQi4BAA8oQcBBRQAEwADAQi4BAA8oQcBBRQAFAACAQjyEQBP/WEABRQAFQABAQiYBgAAAAAABRQAAA==.大锤的壹号:AwAFCAUABAoAAA==.',['�']='奥尔瑟亚:AwAFCAUABAoAAQUAAAAICAoABAo=.好运:AwAFCAgABAoAAA==.',['�']='宁姚:AwABCAEABRQAAA==.宁波西劈精:AwACCAIABAoAAA==.安娜貝尔:AwAECAQABRQAAA==.定不離:AwACCAIABAoAAA==.宫保灬鸡丁:AwABCAEABRQAAA==.',['�']='寒彻:AwACCAIABRQCCwAIAQj9IABOCB0CBAoACwAIAQj9IABOCB0CBAoAAA==.寒月中的北风:AwACCAIABAoAAA==.',['�']='小丑女:AwACCAUABRQCFgAIAQiKHABB6QQCBAoAFgAIAQiKHABB6QQCBAoAAA==.小傻馒灬:AwADCAUABAoAAA==.小太羊:AwAFCAUABAoAAA==.小流云:AwAICA4ABAoAAA==.小罗嗦:AwAICAYABAoAAA==.小萌醤:AwACCAIABRQAAA==.小蘑菇采菇凉:AwAECAQABRQAAA==.小颜颜的小胸:AwAICAgABAoAAQUAAAAICAQABRQ=.',['�']='居然小蓝蓝:AwABCAEABRQAAQUAAAABCAEABRQ=.山上山:AwAFCAkABAoAAA==.山治:AwAECAUABRQDFAAEAQi9BwAmAu4ABRQAFAAEAQi9BwAmAu4ABRQAEwABAQj7EgAAAAAABRQAAA==.山治治:AwABCAEABAoAARIAOigGCAoABRQ=.',['�']='帅爆的彬哥:AwAECAQABAoAAA==.师傅在线刮痧:AwABCAEABRQCEgAIAQj1AQBf6fICBAoAEgAIAQj1AQBf6fICBAoAAA==.希尓瓦纳斯:AwAGCAcABAoAAA==.希尔瓦小斯:AwAECAQABAoAAA==.带个恶魔逛街:AwADCAYABRQCFwADAQiyCgBALvQABRQAFwADAQiyCgBALvQABRQAAA==.',['�']='弃夢:AwACCAgABRQDBAACAQjAFwANeGUABRQAAQACAQhYGwANeHAABRQABAACAQjAFwAFJ2UABRQAAA==.张迷人呀丶:AwACCAYABRQDDQAIAQi5EgBVogUCBAoADQAFAQi5EgBbnQUCBAoADgAGAQjtLwBHYaoBBAoAAA==.强壮的兔七八:AwAICAgABAoAAQUAAAAICAEABRQ=.',['�']='影流成劫:AwAECAIABAoAAA==.',['�']='德美丽:AwAICAoABAoAAA==.',['�']='忠孝勇恭廉:AwACCAQABAoAAA==.快乐就对了鸭:AwAGCBEABAoAAA==.',['�']='恰杯红茶:AwAECAQABRQAAA==.',['�']='悬笔一绝丶:AwAICAEABAoAAA==.',['�']='我不吃辣椒:AwADCAMABRQAAA==.我才是奶龙:AwAGCAYABAoAAA==.我真不是牛牛:AwAHCAgABAoAAA==.战禾:AwAICAYABAoAAA==.',['�']='打包带走:AwAICAEABAoAAA==.打暴蛋蛋:AwACCAIABAoAAA==.执跨:AwAGCAoABRQCFwAGAQjYAQAoypABBRQAFwAGAQjYAQAoypABBRQAAA==.',['�']='把头发盘起来:AwADCAMABAoAAA==.抬杠:AwAECAQABAoAAA==.抹了油的猪:AwAECAYABRQCGAAEAQj8DQA5N/UABRQAGAAEAQj8DQA5N/UABRQAAQUAAAAGCAQABRQ=.',['�']='拜见猫大人:AwAHCAQABAoAAA==.',['�']='按摩小妹星星:AwAICAcABAoAAA==.按摩小妹桂桂:AwAHCBAABAoAAA==.按摩小妹露露:AwAHCBAABAoAAA==.',['�']='掏出来给你看:AwAICAgABAoAAA==.',['�']='无敌小贝壳:AwADCAMABAoAAA==.旺爸爸真帅:AwAECAQABRQAAA==.',['�']='明兮:AwAICA0ABAoAAA==.昔日灬冥:AwAECAQABRQAAA==.星爆棄療斬灬:AwAGCAoABRQDGAAGAQhmCQA1SA0BBRQAGAAEAQhmCQBMlQ0BBRQAGQACAQjhCgAyZ74ABRQAARkAPyYICAsABRQ=.',['�']='暗灬血血:AwACCAUABRQCEAACAQinJQA12ZoABRQAEAACAQinJQA12ZoABRQAAA==.暴仇雪恨丶:AwACCAMABRQCAgAIAQiXGgBLqVACBAoAAgAIAQiXGgBLqVACBAoAAA==.暴力果子狸:AwAICCIABAoDDQAIAQgDJwAtBlMBBAoADQAFAQgDJwAtdVMBBAoADgAFAQhNUAAsLvoABAoAAA==.暴怒之憎恨:AwABCAEABAoAAA==.',['�']='曉灯灯:AwACCAIABRQAAA==.曲终注定人散:AwACCAYABRQDBwACAQgsHgBUgLwABRQABwACAQgsHgBUgLwABRQABgABAQhSHAA6MEYABRQAAQ4AM58DCAUABRQ=.曼森大叔:AwADCAMABAoAAA==.',['�']='有多麻蛙:AwAGCAYABRQCGgAGAQhDAgAQjXYBBRQAGgAGAQhDAgAQjXYBBRQAAA==.木师也疯狂:AwAICBAABAoAAA==.',['�']='李宇春的哥哥:AwABCAEABRQAAA==.',['�']='柒汐吖丷:AwABCAIABRQCGwAHAQjSCwA4kmYBBAoAGwAHAQjSCwA4kmYBBAoAAA==.',['�']='桃夭丶坤灵:AwAGCAoABRQCDgAGAQjhAAAnhbUBBRQADgAGAQjhAAAnhbUBBRQAAA==.',['�']='梅菜扣肉饭:AwACCAIABRQAAA==.梦的起源:AwAECAQABRQAAA==.',['�']='椰子阿良:AwACCAIABRQAAA==.椰汁糯米团:AwAECAIABRQAAA==.',['�']='樊梵凡先森犽:AwABCAEABAoAAA==.',['�']='死胖子:AwAICAgABAoAAA==.',['�']='沫染丶:AwAICAgABAoAAA==.',['�']='流云:AwAECAEABAoAAA==.流亡岛:AwACCAIABAoAAQUAAAABCAEABRQ=.浅倉南:AwACCAUABRQCBAACAQhUFAAaVn4ABRQABAACAQhUFAAaVn4ABRQAAA==.浮生若梦:AwADCAMABAoAAA==.海浪噢:AwACCAYABRQCHAAIAQgbFwBK9jACBAoAHAAIAQgbFwBK9jACBAoAAA==.',['�']='清洛:AwAFCAkABAoAAA==.',['�']='漂亮的回旋踢:AwAECAYABRQCEgAEAQi8DAAu7u0ABRQAEgAEAQi8DAAu7u0ABRQAAA==.漆黑灬前奏曲:AwAGCAYABRQCCQAGAQhfAQAymn8BBRQACQAGAQhfAQAymn8BBRQAAA==.',['�']='潮音:AwAECAQABRQAAA==.',['�']='澄星:AwACCAUABRQCFgACAQiCCQBWPsMABRQAFgACAQiCCQBWPsMABRQAAA==.',['�']='火舞冰灵:AwACCAQABRQAAA==.灭龙魔导士:AwADCAMABAoAAA==.',['�']='無所喂:AwAHCAcABAoAAA==.',['�']='燊怒:AwAECAQABRQAAA==.',['�']='爆鸟转转圈:AwAICAgABAoAAA==.爱吃鱼的懒猫:AwACCAIABRQAAA==.',['�']='牧尸的萨满:AwAGCAMABRQDHQAIAQgQFgBM0yACBAoAHQAIAQgQFgBElSACBAoAGgAGAQiYIABCe6oBBAoAAA==.',['�']='狂霸拽布丁:AwAICAgABAoAAA==.',['�']='猫冬丶:AwABCAEABAoAAA==.',['�']='王泊棠:AwABCAIABRQAAA==.玥唲:AwAECAIABRQAAA==.',['�']='生气然然:AwACCAIABRQAAA==.',['�']='痞子暴:AwABCAIABRQAAA==.',['�']='登里个登:AwAECAQABRQCFAAEAQiiBQBGUAUBBRQAFAAEAQiiBQBGUAUBBRQAAA==.',['�']='眔恚:AwADCAIABAoAAA==.',['�']='瞎基尔黯:AwAFCAUABAoAAQUAAAAICAoABAo=.瞎康康:AwABCAEABRQAAA==.',['�']='砂糖橘:AwAECAoABRQDCAAEAQi3GgAxgeUABRQACAAEAQi3GgAxgeUABRQACQABAQj8FQALWykABRQAAA==.',['�']='突出一个萌:AwADCAMABAoAAA==.',['�']='笑笑:AwABCAIABRQCFwAHAQijNQAv1YQBBAoAFwAHAQijNQAv1YQBBAoAAA==.笑靥繁花:AwADCAYABRQCFAADAQgSCQAs59kABRQAFAADAQgSCQAs59kABRQAAA==.',['�']='粉蝴蝶丶:AwAICAgABAoAAA==.',['�']='红豆团子:AwAHCAoABAoAAA==.红鲤鱼绿鲤鱼:AwAECAQABRQAAA==.纯情小蛋蛋:AwABCAIABRQAAA==.纯白之黑:AwAGCAkABAoAAA==.',['�']='给我圣疗:AwACCAIABRQAAA==.维也呐:AwACCAIABAoAAA==.',['�']='缭乱星棘:AwADCAMABAoAAA==.缺爱的宝宝:AwACCAYABRQCBgAIAQiyDwBPojICBAoABgAIAQiyDwBPojICBAoAAA==.',['�']='罗绮岳:AwAECAgABRQDAQAEAQimBwBMpgMBBRQAAQAEAQimBwBMpgMBBRQABAAEAQgNEQACmo4ABRQAAQEAMX0HCA0ABRQ=.',['�']='美杜灬莎:AwACCAQABRQAAA==.',['�']='翘首以盼:AwAICAgABAoAAA==.',['�']='老骑士暮野:AwAECAQABRQAAA==.',['�']='胖达胖胖哒:AwAECAgABRQDHgAEAQjBAQBIu/oABRQAHgAEAQjBAQBIu/oABRQAHwAEAQjNBwA4X/YABRQAAA==.',['�']='花輪:AwAGCAkABRQCEgAGAQifAQArerABBRQAEgAGAQifAQArerABBRQAAQUAAAAICAEABRQ=.',['�']='若不棄:AwACCAIABRQAARAAMkEGCAgABRQ=.',['�']='茉莉酱:AwACCAIABRQAAA==.',['�']='荆轲:AwABCAEABRQAAA==.',['�']='莉莉酱:AwABCAEABRQAAA==.莫非公主:AwAECAUABAoAAA==.',['�']='菲狄亚斯:AwAGCAkABAoAAA==.',['�']='萨美丽:AwAICA0ABAoAAA==.',['�']='蓼筱筱女王:AwAECAIABRQAAQoAD08ICAUABRQ=.',['�']='薛定谔的猫貓:AwACCAMABRQAAA==.',['�']='衍法:AwAICAgABAoAAA==.',['�']='裤裤酱:AwADCAYABRQCEAADAQiNCQBWMCoBBRQAEAADAQiNCQBWMCoBBRQAAA==.',['�']='诸事皆顺:AwAECAUABAoAAA==.',['�']='辣个小德丶:AwAICA4ABAoAAA==.辣椒超肉:AwAFCAUABAoAAA==.',['�']='那个小猫:AwACCAIABAoAAA==.那个邪迪凯:AwAICAgABAoAARIAI60GCAcABRQ=.那小小骑:AwACCAIABRQAAA==.',['�']='酒浕:AwAECAQABRQAARkAOskICAgABRQ=.',['�']='鑫宝宝:AwAGCAEABAoAAA==.',['�']='锈水巨鳄:AwAFCAUABAoAAA==.',['�']='阿亨:AwAGCAEABAoAAA==.阿里桑德拉:AwABCAEABRQAAQcAN9MGCAkABRQ=.',['�']='雪碧透心靓:AwAFCAEABAoAAA==.零忄玥:AwAECAQABRQAAA==.雷纳斯:AwACCAQABRQAAA==.',['�']='霜丨降丶:AwAFCAEABAoAAA==.露西莉莎:AwAHCAcABAoAAA==.',['�']='靈魂碎片:AwAECAQABRQAARcATegICAYABRQ=.青丝如墨丶:AwADCAMABAoAAA==.青云冷戦飞:AwAECAcABAoAAA==.',['�']='风会来:AwAHCAYABAoAAA==.风干的大爷:AwADCAIABRQAAA==.风干的白黛:AwAECAQABRQAAA==.飞翔的河马:AwAGCAYABAoAAA==.',['�']='马康:AwAECAQABRQAAA==.',['�']='鬼迷心窍丶:AwAGCAYABRQDFwAGAQj9BgAgoREBBRQAFwAFAQj9BgAZBxEBBRQAIAABAQhJCwA/DF4ABRQAAA==.',['�']='黑色眼圈:AwACCAQABRQEDQAIAQgdDQBEBUICBAoADQAHAQgdDQBEBUICBAoADgAEAQgpZAAlt6YABAoAEQADAQiSOgAK9zIABAoAAA==.黑风尼:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end