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
 local lookup = {'Mage-Fire','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Paladin-Protection','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','Unknown-Unknown','Paladin-Holy','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','DeathKnight-Blood','Paladin-Retribution','Monk-Windwalker','Priest-Discipline','Warlock-Affliction','Evoker-Devastation','Shaman-Enhancement','Priest-Holy','Mage-Frost',}; local provider = {region='CN',realm='试炼之环',name='CN',type='weekly',zone=42,date='2025-04-15',data={Br='Brian:AwAECAQABAoAAA==.Britney:AwAICA0ABAoAAA==.',Co='Collapse:AwAICAsABAoAAQEANG8ICAgABRQ=.Conservatism:AwAGCAYABAoAAA==.',Cr='Creamqvq:AwAGCA4ABRQCAgAGAQimAABTXQ4CBRQAAgAGAQimAABTXQ4CBRQAAA==.',De='Deathknightl:AwAECAQABRQAAA==.',Dr='Drakemoon:AwABCAEABRQAAA==.',Li='Littlecheery:AwACCAIABRQAAA==.',Ma='Mangata:AwACCAIABRQAAA==.',Ra='Raccoon:AwAECAcABAoAAA==.Rainjo:AwAECAQABAoAAA==.',Re='Red:AwAICA8ABAoAAA==.',Ro='Robing:AwAECA8ABRQDAwAEAQhlCQBMoA0BBRQAAwAEAQhlCQBICA0BBRQABAACAQhWCQBNJbUABRQAAA==.Rogerjin:AwAECAEABRQAAQIAN6oICAYABRQ=.Rogerm:AwADCAIABRQAAA==.Rogersfs:AwAECAQABRQAAA==.',Sy='Sylvanasy:AwAICAgABAoAAA==.',Th='Thunderaan:AwAICAgABAoAAA==.',Ti='Tina:AwAICAgABAoAAA==.',Vi='Violins:AwAFCAkABAoAAA==.',['�']='一只大鹅:AwADCAMABAoAAA==.一看就是奶牛:AwACCAIABRQAAA==.一色彩羽:AwAGCA4ABRQCBQAGAQgfAQA+DJMBBRQABQAGAQgfAQA+DJMBBRQAAA==.一路向北丿:AwAECAgABRQCAQAEAQgZGQAyEt8ABRQAAQAEAQgZGQAyEt8ABRQAAA==.七冥:AwAECAQABRQAAA==.七妹儿:AwABCAEABRQAAA==.三板大斧子丶:AwAECA4ABRQCAwAEAQjUAgBiI1wBBRQAAwAEAQjUAgBiI1wBBRQAAQQAN/gGCAoABRQ=.三藏狄燊:AwAGCAgABRQDBgAEAQg9BABc5BEBBRQABgAEAQg9BABP2BEBBRQABwAEAQj7DQBWHgkBBRQAAA==.三鹿好奶粉:AwADCAMABAoAAA==.上弦月之歌:AwAECAQABRQAAA==.东海:AwAICAgABAoAAA==.中产小孩:AwACCAEABAoAAA==.丶岚妍:AwACCAIABAoAAA==.丶艾迪什:AwADCAIABAoAAA==.为了灬圣光:AwAICAgABAoAAA==.',['�']='乞力马扎但丁:AwAECAQABRQAAA==.',['�']='云来到:AwACCAIABAoAAA==.',['�']='休闲小牛犊:AwAICAsABAoAAA==.',['�']='你五大爷:AwAFCAYABAoAAA==.你好丨咏:AwAECAgABRQCCAAEAQj+AQBg9lEBBRQACAAEAQj+AQBg9lEBBRQAAA==.',['�']='元神启动:AwAECAQABRQAAA==.',['�']='农夫山全:AwAECAQABAoAAA==.',['�']='凑你咋地:AwABCAEABAoAAA==.凤狂怒德:AwAECAQABAoAAA==.',['�']='刁十七:AwABCAEABRQDBAAIAQgLDwBPFSoCBAoABAAHAQgLDwBVoSoCBAoAAwAIAQi3IgA8SvQBBAoAAA==.',['�']='劍倾城:AwABCAEABAoAAA==.',['�']='北落:AwAECAQABRQAAA==.医畜圣手:AwAICAgABAoAAQkAAAAECAQABRQ=.',['�']='华美至善:AwAECAcABAoAAA==.单片机:AwAGCAIABAoAAA==.南小星:AwABCAEABAoAAA==.',['�']='厉鬼邪神:AwAFCAUABAoAAA==.',['�']='周星驰:AwAECAYABRQCCgAEAQgjBgAtBt8ABRQACgAEAQgjBgAtBt8ABRQAAA==.',['�']='喑哑:AwADCAMABAoAAA==.喜多村凯恩:AwAECAcABAoAAA==.喝酒:AwABCAEABAoAAA==.',['�']='嗯内孤:AwAGCAYABAoAAA==.',['�']='噤语:AwACCAUABRQCCwACAQgMFgBHVasABRQACwACAQgMFgBHVasABRQAAA==.',['�']='图腾的叹息:AwAGCAYABAoAAA==.',['�']='圣丶塞勒斯汀:AwAGCAQABAoAAA==.地獄小强丶:AwADCAEABRQDDAAIAQgSDQBNrHcCBAoADAAIAQgSDQBNrHcCBAoADQAEAQgCMQBC8eYABAoAAA==.',['�']='壮烈成仁:AwAICAgABRQCCwAEAQh3BwBYyBABBRQACwAEAQh3BwBYyBABBRQAAA==.',['�']='夜鶯:AwAGCAYABAoAAA==.天丶崖:AwACCAoABRQDBgACAQg+FAAxHIgABRQABgACAQg+FAAtV4gABRQABwACAQgLLgAoPocABRQAAA==.天野阳菜:AwAICAMABAoAAA==.',['�']='奶湯灬纯黑色:AwABCAEABAoAAA==.',['�']='妮奶奶灬熊猫:AwAFCAQABAoAAA==.',['�']='学术男:AwAICAgABAoAAA==.',['�']='射中了你养啊:AwAECAQABAoAAA==.小熊杜杜:AwAICAgABAoAAA==.小鱼小虾:AwAECAQABRQAAA==.尼古丁三雨:AwAGCAYABAoAAA==.',['�']='山水圣骑:AwACCAQABRQAAA==.山水梦画:AwAECAQABRQAAA==.',['�']='希望的守护者:AwAECAQABRQAAA==.',['�']='干瞪眼:AwAECAQABRQAAA==.干脆麺:AwAGCAYABAoAAA==.',['�']='廈韎丶:AwAICAUABAoAAA==.',['�']='弗拉斯:AwAICBIABAoAAA==.',['�']='心若梦尘:AwAICBAABAoAAA==.',['�']='恐虐的跌滴:AwAICAgABAoAAA==.',['�']='惊天大战神:AwAECAoABRQCDgAEAQguBwBPGBgBBRQADgAEAQguBwBPGBgBBRQAAA==.惩戒仙:AwAGCAkABAoAAA==.惩罚队友:AwABCAEABAoAAA==.',['�']='戏丨子:AwABCAEABAoAAA==.我有很多新招:AwADCAMABAoAAA==.我来劲:AwAECAQABRQAAA==.',['�']='抽烟牛牛:AwAICCAABAoCCAAIAQhaMAAvl6YBBAoACAAIAQhaMAAvl6YBBAoAAA==.',['�']='握不住的流砂:AwADCAQABAoAAA==.',['�']='放逐者影魔:AwAGCAYABAoAAQ8AQCkICAUABRQ=.',['�']='新建压缩文档:AwAECAIABRQAAA==.',['�']='无极之巅:AwADCAMABRQAAA==.',['�']='星如雨:AwAGCAQABRQAAA==.星酱可爱丶法:AwAECAQABRQAAA==.',['�']='暗影的疯狂:AwAGCAgABAoAAA==.暗殇灬波杰克:AwAICA0ABAoAAA==.',['�']='月下有佳人:AwACCAQABRQDEAAIAQguPwBGvBgCBAoAEAAIAQguPwBGvBgCBAoABQABAQivYQAJwAsABAoAAA==.有一把小豆芽:AwAICAgABAoAAA==.有德才有尸:AwAICA4ABAoAAA==.木法沙:AwADCAMABAoAAA==.朵特:AwACCAIABAoAAA==.机关枪图凸突:AwABCAEABRQAAA==.',['�']='杀鸡胡同:AwAICAwABAoAAA==.来两颗葡萄:AwAFCAYABAoAAA==.杰瑞丶:AwACCAIABRQAAA==.',['�']='枳花丶驿影:AwAGCAIABRQAAA==.',['�']='格罗丶姆:AwAGCAYABAoAAA==.',['�']='梦丷魇:AwAGCAMABRQAAA==.梦游德:AwACCAIABRQAAA==.',['�']='殇珊夏湘:AwAECAEABRQCCAABAQjaJgAekkkABRQACAABAQjaJgAekkkABRQAAA==.',['�']='毛怪强:AwAICAEABAoAAA==.',['�']='氺霛児:AwACCAIABAoAAA==.',['�']='沐陽:AwAGCAYABAoAAA==.',['�']='深渊公民:AwABCAEABAoAAA==.',['�']='清酒与茶:AwAECAQABRQAAA==.温凉:AwACCAIABRQAAA==.渺渺兮予怀丶:AwAGCAYABAoAAA==.',['�']='灬呜呜灬:AwAICAsABAoAAA==.灬坏辣灬:AwAGCA8ABAoAAA==.灬大師兄灬:AwABCAEABAoAAA==.灬干中学灬:AwACCAIABRQAAQYAQc0GCAYABRQ=.灬深海灬:AwAGCAYABAoAAA==.灬辣辣灬:AwABCAEABAoAAA==.灬飛楊灬:AwADCAMABRQAAA==.',['�']='焚焱霜天:AwAECAYABAoAAA==.',['�']='熊猫不丑:AwADCAsABRQCEQADAQjzBQBJPAsBBRQAEQADAQjzBQBJPAsBBRQAAA==.',['�']='爱射:AwAFCAUABAoAAA==.',['�']='牛欢喜:AwAFCAUABAoAAA==.',['�']='狂暴小清新:AwAFCAYABAoAAA==.狂暴巍少:AwABCAEABRQAAA==.狙馍蘸酱:AwABCAEABAoAAA==.',['�']='猫不易:AwAECAUABAoAAA==.',['�']='獨孤逍遥:AwAGCAgABAoAAA==.',['�']='班花:AwAICAgABAoAAA==.',['�']='田园小画家:AwAGCAkABAoAAA==.电男:AwACCAIABAoAAA==.',['�']='痛饮狂歌:AwAFCAgABAoAAA==.',['�']='白头山天降者:AwAGCAEABRQCAwABAQjWHwAUcFoABRQAAwABAQjWHwAUcFoABRQAAA==.白鸟丨瑞穗:AwAECAQABRQCEgAEAQiHCwAwveEABRQAEgAEAQiHCwAwveEABRQAAA==.',['�']='看不覝的星星:AwAECAQABRQAAA==.真希波:AwAECAQABRQAAA==.',['�']='祖师爷吴彦祖:AwADCAMABAoAAA==.神棵先生:AwAECAQABRQAAQkAAAAICAQABRQ=.',['�']='离之:AwAECAQABRQAAA==.',['�']='移不动:AwABCAEABRQAAA==.',['�']='空空德:AwAECAQABRQAAA==.',['�']='精靈貝貝:AwACCAIABRQAAA==.',['�']='红色体育生:AwAHCAcABAoAAA==.',['�']='绅士的肥皂:AwAECAgABRQDDAAEAQjvDABGSOQABRQADAADAQjvDABGSOQABRQAEwABAQhuHgAAAAAABRQAAA==.绝心海棠:AwAECAQABAoAAA==.绯爵爷:AwAECAgABRQCFAAEAQi/BABb7isBBRQAFAAEAQi/BABb7isBBRQAAQEAQ8QICAcABRQ=.',['�']='翠花窝窝头:AwAFCAUABAoAAA==.',['�']='老腊肉:AwAICAgABAoAAA==.老马:AwAICAgABAoAAA==.',['�']='聆听丶音域:AwAICAYABAoAAA==.',['�']='能拽会罩丶乐:AwAECAQABRQAAA==.',['�']='臭臭狐:AwAECAQABAoAAA==.',['�']='花兜兜:AwAICAgABAoAAA==.',['�']='荼白:AwADCAMABRQAAA==.',['�']='莉亚丶德琳:AwADCAMABAoAAA==.',['�']='菜园小德:AwAHCAcABAoAAQ4AN8wBCAIABRQ=.菜园滚滚:AwABCAIABRQCDgAIAQibHQA3zOgBBAoADgAIAQibHQA3zOgBBAoAAA==.',['�']='萌萌女汉子:AwAFCAUABAoAAA==.落花知多少:AwAECAQABRQAAA==.落雪哥:AwADCAoABRQCEgADAQjfBwBDwgEBBRQAEgADAQjfBwBDwgEBBRQAAA==.落雪妈咪:AwAECAgABRQCAwAEAQhoCgBAIAcBBRQAAwAEAQhoCgBAIAcBBRQAAA==.',['�']='薯片的包装袋:AwAICAgABAoAAA==.',['�']='虾仁不眨眼丶:AwACCAIABRQAAA==.',['�']='蛋堡酱:AwACCAIABRQAAA==.蛋宰派对:AwAGCAYABRQCDwAGAQhoBAAhaC8BBRQADwAGAQhoBAAhaC8BBRQAAA==.',['�']='西八喇叭:AwAECAgABRQCDgAEAQjMCQBHZgEBBRQADgAEAQjMCQBHZgEBBRQAAA==.西班牙丶梅西:AwAECAQABAoAAA==.',['�']='见习看板娘:AwAECAQABRQAAA==.',['�']='调色的星:AwAGCAwABRQDBwAEAQh4CABS8ikBBRQABwAEAQh4CABS8ikBBRQABgABAQg4IwAAAAAABRQAAA==.',['�']='贴膜寳亿:AwACCAIABRQAAA==.',['�']='赤木茂:AwADCAIABAoAAA==.赤鸦裂空破:AwABCAEABRQAAA==.赵露思:AwAECAQABRQAAA==.',['�']='轉身丿滿城雪:AwACCAQABRQDCAAIAQjFGwBD2hICBAoACAAIAQjFGwBD2hICBAoAFQADAQgfRAAnqJwABAoAAA==.轉身丿黯明月:AwACCAMABRQAAA==.',['�']='追风捷影:AwAGCAYABAoAAA==.',['�']='道道七号:AwAICAgABAoAAQkAAAADCAQABRQ=.',['�']='那个谁过来:AwACCAIABRQAAA==.',['�']='醉一斗:AwAECAYABAoAAA==.醉酒:AwAGCAgABAoAAA==.',['�']='钟薛高丶:AwABCAEABAoAAA==.',['�']='铁丶蛋:AwAECAQABAoAAA==.银色战车:AwAICAgABAoAAA==.',['�']='长路慢慢:AwAICAwABAoAAA==.',['�']='阡陌笑:AwADCAkABRQDDgADAQjzDwAnK9sABRQADgADAQjzDwAnK9sABRQAEQADAQh5DQAM9a8ABRQAAA==.阿满:AwAECAQABRQAAA==.阿鲁卡多:AwACCAIABRQAAA==.',['�']='陆小尘丶:AwADCAMABRQAAA==.',['�']='雕刻圣光:AwACCAIABRQAAQEAJ70GCAoABRQ=.',['�']='霊霊:AwAICAgABAoAAA==.霪尸作乐:AwACCAIABRQAAA==.霸气灬青玄子:AwAICAoABAoAAA==.',['�']='青色回忆:AwAICAQABAoAAA==.面若白玉:AwAICAgABAoAARYASqIECAQABRQ=.',['�']='顶级灬半月:AwAFCAUABAoAAA==.须弥真言:AwADCAMABAoAAA==.',['�']='马论:AwAGCAYABRQCDgAGAQj+AQAkNJ4BBRQADgAGAQj+AQAkNJ4BBRQAAA==.',['�']='魁丶柒:AwAICA4ABAoAAA==.魔神:AwAICAoABAoAAA==.',['�']='鯨泪:AwABCAEABRQAAA==.',['�']='鱼妖妖:AwADCAQABAoAAA==.',['�']='鲨鱼小公主:AwABCAEABRQAAA==.',['�']='鸢一折纸丶:AwACCAMABRQAAA==.',['�']='麻辣牛筋:AwADCAQABRQCFwAIAQgKDABWJZACBAoAFwAIAQgKDABWJZACBAoAAA==.',['�']='黑汤圆:AwABCAEABAoAAA==.黑腿欧巴:AwAHCA4ABAoAAA==.黑铁宋小宝:AwAICAgABAoAAQ8ARwgGCAkABRQ=.黑鲔鱼阿广:AwAICA0ABAoAAA==.黯淡的风:AwAGCAEABAoAAA==.',['�']='龙鳞胸甲五铜:AwAECAkABRQDEwAEAQhLBgA3YvIABRQAEwADAQhLBgA3YvIABRQADQABAQh8GAAAAAAABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end