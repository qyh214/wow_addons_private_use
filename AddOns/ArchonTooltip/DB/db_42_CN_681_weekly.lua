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
 local lookup = {'DeathKnight-Blood','Paladin-Retribution','Paladin-Holy','Mage-Frost','Unknown-Unknown','Warrior-Fury','Monk-Windwalker','Mage-Fire','Rogue-Subtlety','Rogue-Assassination','Hunter-Marksmanship','Hunter-Survival','Priest-Holy','Priest-Shadow','Priest-Discipline','Monk-Brewmaster','Warrior-Arms','DeathKnight-Unholy','Warlock-Destruction','Warlock-Affliction','Druid-Restoration','Warlock-Demonology','Rogue-Outlaw','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-BeastMastery','DeathKnight-Frost','Druid-Balance','Monk-Mistweaver','Warrior-Protection',}; local provider = {region='CN',realm='恶魔之魂',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ao='Aowuwawa:AwAECAQABRQAAA==.',Ar='Arianrhod:AwAECAQABRQAAA==.',As='Asters:AwACCAQABRQAAA==.',Bi='Bingb:AwAECAQABAoAAA==.',Ca='Cancici:AwACCAQABRQCAQAIAQjTCwBJa0kCBAoAAQAIAQjTCwBJa0kCBAoAAA==.',Fc='Fcc:AwAECAQABRQAAA==.',He='Heart:AwACCAMABRQAAA==.Hephea:AwEICAgABAoAAA==.',Ho='Hottiger:AwABCAEABRQAAA==.',Hu='Hutten:AwAFCAUABAoAAA==.',Jo='Jogows:AwAECAQABRQAAA==.',Ku='Kuraudo:AwAICAUABAoAAA==.',Ma='Magicka:AwAECAQABAoAAA==.',Mi='Misamisa:AwABCAEABRQAAA==.',Mu='Mua:AwAECAQABAoAAA==.',Ne='Neoly:AwACCAMABRQCAgAIAQjZPQA+zxICBAoAAgAIAQjZPQA+zxICBAoAAA==.',Pr='Pricon:AwABCAEABRQAAA==.',Ra='Radiant:AwAECAQABRQDAgAIAQjLVQA9LNABBAoAAgAHAQjLVQBCUtABBAoAAwAIAQh0FQAsCZcBBAoAAA==.Razorx:AwACCAEABRQAAQQAYX8DCAIABRQ=.',So='Sole:AwEICAgABAoAAQUAAAAICAgABAo=.',To='Tonyones:AwAHCAoABAoAAA==.',Wh='Whitemanba:AwACCAQABRQAAA==.',Yc='Ycc:AwAICAIABAoAAA==.',Yh='Yhjlikes:AwAGCAYABAoAAA==.',['�']='一坐车就要吐:AwADCAMABAoAAA==.一股清风:AwAECAQABAoAAA==.一隻鬼:AwADCAQABAoAAA==.丶一介武夫:AwABCAEABRQAAA==.丶八戒:AwAICAIABAoAAA==.丶卡咔:AwABCAIABAoAAA==.丶小涛:AwABCAEABRQAAA==.丶微风香水:AwADCAMABRQAAA==.丶那个男人丶:AwAICAsABAoAAA==.丿飞飞:AwAICAgABAoAAA==.',['�']='乘除法丶:AwACCAIABAoAAA==.九霄佩环:AwAECAQABAoAAA==.',['�']='二七路旁:AwAICAgABAoAAA==.二七遛狗:AwAECAQABRQAAA==.',['�']='从此无名:AwAGCAYABRQCBgAEAQh7BwBP0hQBBRQABgAEAQh7BwBP0hQBBRQAAA==.',['�']='传说的山山:AwAICBoABAoCBAAIAQhbDgBUZ3ACBAoABAAIAQhbDgBUZ3ACBAoAAQUAAAAGCAQABRQ=.',['�']='你喷喷我吧:AwAICA8ABAoAAA==.你抱抱我吧:AwAICAkABAoAAA==.你拉拉我吧:AwAICBEABAoAAA==.你无视我吧:AwABCAEABRQAAA==.你毁灭我吧:AwAICAgABAoAAA==.你沉默我吧:AwAECAQABRQAAA==.你熊熊我吧:AwAICAYABAoAAQUAAAAICAMABRQ=.你虐待我吧:AwACCAIABRQAAQcASmkGCAYABRQ=.你锤锤我吧:AwAICAUABAoAAQgAJ70GCAoABRQ=.你震击我吧:AwACCAIABRQAAA==.你风筝我吧:AwAECAQABRQAAA==.你饶过我吧:AwAICCYABAoDCQAIAQhsBQBYXJkCBAoACQAIAQhsBQBXipkCBAoACgAIAQiJCgBGyEgCBAoAAA==.',['�']='依然哈罗:AwACCAIABAoAAA==.',['�']='傷丶龍玖:AwACCAQABRQDCwAIAQjfBQBat6sCBAoACwAIAQjfBQBYsasCBAoADAADAQicEgBJ55MABAoAAA==.',['�']='像風一樣吹過:AwACCAIABAoAAA==.',['�']='光巴灯儿:AwADCAMABAoAAA==.八度空间:AwABCAEABAoAAA==.公子世无双:AwAGCAYABAoAAA==.',['�']='冷烟凝:AwAECAQABAoAAA==.',['�']='加减法丶:AwAECAUABAoAAA==.',['�']='勇者斗美女:AwAHCAoABAoAAA==.',['�']='十二是只喵:AwAGCAoABAoAAA==.午夜悲伤:AwADCAIABRQAAA==.单纯愚乐:AwACCAIABRQAAA==.',['�']='叫我战狂丶:AwACCAIABAoAAA==.',['�']='名槲寄生:AwABCAEABAoAAA==.吸血魂丶:AwAECAwABRQDDQAEAQimBwAuud4ABRQADQAEAQimBwAuud4ABRQADgAEAQhBDwAfDsMABRQAAA==.吾為卿狂:AwADCAYABAoAAA==.',['�']='呆狐:AwACCAgABRQDDwACAQhNDgBG170ABRQADwACAQhNDgBG170ABRQADgACAQiYEwA5eJYABRQAAA==.',['�']='啊咑咑:AwABCAEABRQDEAAIAQhOBQBFnSUCBAoAEAAIAQhOBQBFnSUCBAoABwADAQjpXAAHzmEABAoAAA==.',['�']='四风谷老农:AwAECAcABAoAAA==.',['�']='地狱向左哟:AwADCAMABAoAAA==.',['�']='墨菲斯特:AwABCAEABRQAAA==.',['�']='夏娜:AwACCAQABRQDBwAIAQhXGABDu/cBBAoABwAHAQhXGABLXPcBBAoAEAACAQiNHQAX0VUABAoAAA==.夜幽:AwAECAQABAoAAA==.夜影梦清秋:AwACCAIABRQAAA==.大卫:AwAECAQABRQAAA==.大迪奥:AwABCAEABRQAAA==.天命往生:AwAHCAoABAoAAA==.天命无惧:AwABCAEABRQDBgAIAQj5IAA3rvcBBAoABgAIAQj5IAA2cfcBBAoAEQAGAQiBKQAnlTABBAoAAA==.天命无逸:AwABCAEABRQAAA==.头发里有虫子:AwABCAEABRQAAA==.',['�']='奶牧:AwAFCAUABAoAAA==.好喜欢下雪:AwABCAEABRQCEgAIAQjBCgBeH7ICBAoAEgAIAQjBCgBeH7ICBAoAAA==.',['�']='威尔一史密斯:AwACCAIABRQAAA==.',['�']='子夜妖瞳:AwABCAEABAoAAA==.子曰太阳你:AwAFCAUABAoAAA==.孙婉卿:AwAICAkABAoAAA==.孤独一笑:AwAGCAYABAoAAA==.',['�']='安闲:AwAFCAYABAoAAA==.',['�']='寒霜落雪:AwAECAQABRQAAQUAAAAECAQABRQ=.',['�']='小宁儿:AwAFCAgABAoAAA==.小强不是很强:AwABCAEABRQAAA==.小猪诺诺德:AwADCAYABAoAAA==.小盼哒:AwAFCAUABAoAAA==.小荷尖尖角:AwAECAYABRQDEwAEAQgADwA85M8ABRQAEwAEAQgADwAvj88ABRQAFAACAQjJDABQLaEABRQAAA==.小赌移情:AwAICAgABAoAAA==.小飞锤来喽丶:AwAGCAQABRQAAA==.小黑丨双蛋:AwAFCAUABAoAAA==.',['�']='山里有姑娘:AwAGCAUABAoAAA==.',['�']='平湖吴彦祖:AwABCAIABRQAAA==.幽丶魔:AwAECAQABRQAAQUAAAAGCAQABRQ=.',['�']='开坦克的贝塔:AwAICBwABAoDBgAIAQhmEABNjG4CBAoABgAIAQhmEABNI24CBAoAEQADAQhLPQA7ga0ABAoAAQUAAAAGCAIABRQ=.张老大:AwACCAUABRQCFQACAQjwDABWYJ0ABRQAFQACAQjwDABWYJ0ABRQAAA==.弥漫:AwAHCAcABAoAAQ0AOwsECAwABRQ=.弥漫哟:AwAECAUABRQDFAAEAQh1AABi814BBRQAFAAEAQh1AABi814BBRQAFgABAQizEgAg8j0ABRQAAQ0AOwsECAwABRQ=.弧父:AwABCAEABRQAAA==.',['�']='彼岸菊开:AwACCAIABAoAAA==.',['�']='心情看天气:AwAGCAoABAoAAA==.心想事成:AwAICAoABRQCCAAIAQg8AgBGQ8EBBRQACAAIAQg8AgBGQ8EBBRQAAA==.念桃:AwAECAQABRQAAA==.',['�']='情天一北北:AwAECAgABRQCAgAEAQiKDwBMswIBBRQAAgAEAQiKDwBMswIBBRQAAA==.',['�']='我宠物来咯:AwAECAQABRQAAA==.我會消失:AwACCAIABRQDCQAIAQiFCgBLJj4CBAoACQAIAQiFCgBLJj4CBAoAFwADAQhoEwAbI2wABAoAAA==.我系阿昆达:AwABCAEABRQAAA==.',['�']='打死不切奶:AwACCAgABRQEDwACAQhzDwBB6rEABRQADwACAQhzDwBB6rEABRQADgACAQihFQAlrYcABRQADQABAQg5GQBVfEUABRQAAA==.',['�']='拉夏贝尔:AwACCAIABRQAAA==.拉西:AwAGCAYABAoAAA==.',['�']='摇滚巴赫:AwACCAIABAoAAA==.',['�']='支配暗影:AwACCAMABRQDEwAIAQiCKABFxL4BBAoAEwAIAQiCKAA6ML4BBAoAFgAGAQhjGgBDhmYBBAoAAA==.',['�']='散失星辰:AwAICAgABAoAAA==.',['�']='斧親:AwAECAQABRQAAA==.',['�']='旅者之誓:AwABCAEABRQAAA==.旧梦如炽灬:AwABCAEABRQDGAAIAQh1EABTh5ECBAoAGAAIAQh1EABTh5ECBAoAGQADAQhIUwAK/0wABAoAAA==.旺仔复原乳丶:AwAECAgABRQCAgAEAQjmDgBNGgUBBRQAAgAEAQjmDgBNGgUBBRQAAA==.旺旺:AwAFCAUABAoAAA==.',['�']='星光璀璨:AwACCAMABRQDDQAIAQh5CgBUO2oCBAoADQAIAQh5CgBUO2oCBAoADwABAQg5cwA+SUgABAoAAA==.星落宇飞:AwAICAgABAoAAA==.春天的哥哥:AwABCAEABRQAAA==.',['�']='晴天丶寳寳:AwAICAgABAoAAA==.',['�']='暗杠杠不动丶:AwACCAUABRQDGgAIAQiOHABVO24CBAoAGgAIAQiOHABVO24CBAoACwABAQgGbAAlOjcABAoAAA==.',['�']='月下神灵:AwABCAEABRQAAA==.月色弥漫:AwAFCAUABAoAAQ0AOwsECAwABRQ=.月野丷兔:AwAGCAYABAoAAA==.朝日:AwAGCAEABRQCCAAIAQjYIwBJVg4CBAoACAAIAQjYIwBJVg4CBAoAAA==.',['�']='杀手空:AwACCAMABAoAAA==.',['�']='枣枣妹妹:AwAICAoABAoAAA==.',['�']='柒叶恋:AwABCAEABRQAAA==.',['�']='梅子忧伤:AwADCAIABAoAAA==.',['�']='橘子仙人:AwAFCA4ABAoAAA==.',['�']='欧贝里斯克:AwADCAMABAoAAA==.',['�']='氾凢犭:AwAGCAoABAoAAA==.',['�']='江丿岛盾子:AwAECAQABRQAAA==.',['�']='没穿鞋:AwAICAgABAoAAQ4ANl0GCAoABRQ=.沧海不为水:AwADCAIABRQDBAAIAQjVAwBhf+sCBAoABAAHAQjVAwBhf+sCBAoACAAFAQheQQBXkGoBBAoAAA==.',['�']='法不嵘情:AwAICAgABAoAAA==.',['�']='洛丹伦大孝女:AwAHCA8ABAoAAA==.洪天赐:AwAICAgABAoAAA==.',['�']='流年旧梦:AwAECAQABRQAAA==.',['�']='深夜吥睡觉:AwAECAQABRQAAA==.',['�']='湛灡:AwAECAQABRQAAA==.湫丶:AwAECAYABRQDCwAEAQgjEgA+VIYABRQACwACAQgjEgAy0oYABRQAGgACAQjbMQBVWV8ABRQAAA==.',['�']='潶濏馒頭:AwAECAgABRQDCwAEAQgkCABH++UABRQACwAEAQgkCAA9S+UABRQAGgAEAQgXFgAwzOEABRQAAA==.',['�']='灬弥漫:AwAECAwABRQDDQAEAQjtBgA7C+QABRQADQAEAQjtBgA7C+QABRQADgAEAQgFDgAlDNAABRQAAA==.灬霜之哀傷灬:AwABCAEABRQAAA==.',['�']='烏鴉归來:AwACCAIABRQAAA==.',['�']='焦山小霸王:AwACCAQABRQDCwAIAQipCQBY43QCBAoACwAIAQipCQBORnQCBAoAGgAIAQgJHwBSBmECBAoAAA==.',['�']='熊包包:AwAECAgABRQCAgAEAQgqEgA72/gABRQAAgAEAQgqEgA72/gABRQAAA==.',['�']='爱佛路笋:AwAFCAYABAoAAA==.爱意牛:AwAECAgABRQCBgAEAQiIDAAtZvgABRQABgAEAQiIDAAtZvgABRQAAA==.爱祸女戎:AwAGCAcABAoAAA==.',['�']='牛奶奶牛:AwAICAgABAoAAQ4AN1QGCAYABRQ=.牛氓白菜:AwAICAsABAoAAA==.牛气妹笄:AwACCAMABRQAAA==.牛蛋儿:AwACCAIABRQAAA==.',['�']='猎入:AwAICAgABAoAAA==.',['�']='玛卡巴卡灬:AwADCAQABAoAAA==.',['�']='瑃丶:AwAECAYABRQCEwAEAQjtBgBJ/wgBBRQAEwAEAQjtBgBJ/wgBBRQAAA==.',['�']='白銀騎士:AwAICA4ABAoAAQgAJ70GCAoABRQ=.',['�']='盐酸哌替啶:AwABCAEABRQAAA==.',['�']='祖国未来花朵:AwAFCAEABAoAAA==.',['�']='秋名山老司机:AwADCAEABAoAAA==.秋风之疾:AwACCAMABRQCCAAIAQg0JQA9QAYCBAoACAAIAQg0JQA9QAYCBAoAAA==.',['�']='稀狸狐涂:AwAGCAQABAoAAA==.',['�']='等风来:AwAGCAYABAoAAA==.',['�']='米德拉什:AwACCAIABRQAAA==.',['�']='粉红马卡龙:AwAICBAABAoAAA==.',['�']='紫雨牛牛:AwAICAcABAoAAA==.紫雨龙虾:AwADCAMABAoAAA==.',['�']='綁桑迪:AwACCAMABRQAAA==.',['�']='緣寿:AwAECAQABRQAAA==.',['�']='红米粥:AwAECAIABRQAAA==.红莲之轨迹:AwABCAEABRQAAA==.纳兰果:AwAFCAUABAoAAA==.',['�']='老乱吃生火:AwACCAIABRQCGwAIAQhACABHbg0CBAoAGwAIAQhACABHbg0CBAoAAA==.老王丶:AwAGCAYABAoAAA==.',['�']='肉搏鸟:AwAECAQABRQAAA==.',['�']='胡桃:AwABCAIABRQDGwAIAQiDBwBFESMCBAoAGwAIAQiDBwBFESMCBAoAEgABAQianwA5EUMABAoAAA==.',['�']='良品兔子:AwABCAEABRQAAA==.',['�']='芥末漱石:AwAICAgABAoAAA==.',['�']='荔枝骑:AwAECAQABRQAAA==.',['�']='莉娜因巴嘶:AwAECAQABRQAAA==.莉莉丝女王:AwAECAIABRQAAA==.莱恩:AwAECAQABRQAAA==.莱赞:AwABCAEABRQCHAAHAQjaQQA1j3kBBAoAHAAHAQjaQQA1j3kBBAoAAA==.',['�']='萌喵酱丷:AwAECAQABRQAAR0AH94ICAoABRQ=.萌汉药:AwAGCBAABAoAAA==.萌萌的筱琪:AwACCAIABRQAAA==.萨瓦迪佧:AwAECAQABRQAAA==.',['�']='葉鳳:AwAECAQABRQAAA==.葬月惊寂:AwAICAoABAoAAA==.',['�']='血夜番茄:AwACCAEABAoAAA==.',['�']='袁少丶:AwAECAQABRQAAA==.',['�']='装炮弹的贝塔:AwAICAgABAoAAA==.',['�']='贰丨朮:AwAICBEABAoAARMASDIGCAUABRQ=.',['�']='遐蝶:AwAECAgABRQCEwAEAQjQAwBaEi4BBRQAEwAEAQjQAwBaEi4BBRQAAA==.',['�']='酌酒丶独倾:AwAICBoABAoCCAAIAQgcNwA5VaMBBAoACAAIAQgcNwA5VaMBBAoAARMASDIGCAUABRQ=.酷酷小黑牛:AwABCAIABRQEBgAIAQhVHwBMwAECBAoABgAIAQhVHwBAYgECBAoAHgAGAQizEQBEDWoBBAoAEQADAQj5NQBDoNkABAoAAA==.',['�']='铁血蛮牛:AwABCAEABRQAAA==.',['�']='闪电鸡:AwABCAEABRQAAA==.',['�']='阿撒托斯丶術:AwADCAkABRQCEwADAQjyDgAk6dAABRQAEwADAQjyDgAk6dAABRQAAA==.阿棕:AwACCAUABRQDFQAIAQjUHQA4sK0BBAoAFQAIAQjUHQA4sK0BBAoAHAABAQjApwARujQABAoAAA==.',['�']='陆喵柒的崽:AwAFCAUABAoAAA==.',['�']='隆里电丝:AwACCAIABRQAAQUAAAAICAQABRQ=.随小宇:AwAGCAoABAoAAA==.',['�']='雪糕:AwAECAQABRQAAA==.',['�']='青梅煮酒丶:AwAICAoABAoAAA==.',['�']='风中丶凌乱:AwAECAQABAoAAA==.',['�']='香奈儿:AwADCAMABAoAAA==.',['�']='高压电饭煲:AwACCAQABRQAAA==.',['�']='鲜肉猎手:AwABCAEABRQAAA==.',['�']='黠糜:AwAECAUABRQCGgAEAQg/BgBbVDQBBRQAGgAEAQg/BgBbVDQBBRQAAA==.',['�']='龙叔:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end