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
 local lookup = {'Shaman-Restoration','Priest-Shadow','DeathKnight-Unholy','DeathKnight-Blood','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Druid-Restoration','Paladin-Retribution','Mage-Fire','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Monk-Windwalker','Paladin-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Balance','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Warrior-Fury','Monk-Mistweaver','Warrior-Arms','Priest-Discipline','Druid-Feral','Mage-Arcane','Warrior-Protection','Monk-Brewmaster',}; local provider = {region='CN',realm='灰谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adrianmutu:AwAGCAQABRQAAA==.',Ag='Aged:AwADCAwABRQCAQADAQhgAQBg+lQBBRQAAQADAQhgAQBg+lQBBRQAAA==.',Al='Allpassedby:AwAGCAYABAoAAA==.',An='Anorlondo:AwAECAMABRQAAA==.',Aw='Awayäinätime:AwADCAUABRQCAgADAQh9DgAcbcsABRQAAgADAQh9DgAcbcsABRQAAA==.',Ba='Balancoire:AwAICAQABRQAAA==.',Co='Cocococo:AwACCAQABRQDAwAIAQjUFgBPGFMCBAoAAwAIAQjUFgBPGFMCBAoABAACAAgAAAAAAAAABAoAAA==.',Ex='Explorernine:AwABCAEABRQCAQAIAQj6OAAu1nsBBAoAAQAIAQj6OAAu1nsBBAoAAA==.',Hm='Hmm:AwAICAgABAoAAA==.',Le='Legaltoad:AwABCAIABRQAAA==.',Li='Lierenn:AwAECAUABRQDBQAEAQiyBABJoQMBBRQABQAEAQiyBABJoQMBBRQABgABAQgqOwAf20IABRQAAA==.',Lz='Lzj:AwAECAQABRQAAA==.',Ma='Mahjong:AwAECAQABRQAAA==.Martinlin:AwAICB4ABAoCBwAIAQi0BQBcZdECBAoABwAIAQi0BQBcZdECBAoAAA==.',Me='Megumi:AwAECAQABRQAAA==.',Ni='Nikko:AwAHCAwABAoAAA==.',Pa='Painsin:AwAICAgABAoAAA==.',Po='Pocket:AwAICBEABAoAAQgAPTwECAsABRQ=.',Sa='Sanna:AwACCAIABRQAAA==.',Se='Selector:AwAFCAkABAoAAA==.',St='Star:AwAICA8ABAoAAA==.',Ta='Tangyuan:AwAICAgABAoAAA==.',Va='Vavan:AwAHCAkABAoAAA==.',['�']='一布莉瑞塔一:AwAICBEABAoAAA==.七曜使者:AwAFCAUABAoAAA==.七月牙:AwAECAQABRQAAA==.东坡肉丷:AwACCAQABRQAAA==.两面都有胶:AwACCAIABRQAAA==.丨圣光丶末路:AwAECAYABRQCCQAEAQgBBABd/UABBRQACQAEAQgBBABd/UABBRQAAA==.中野四叶:AwADCAYABAoAAA==.丶千阙灬:AwACCAQABRQAAA==.丶奶大力:AwACCAMABRQAAA==.丶染月灬凄:AwAICAIABAoAAA==.丶输给微笑:AwAFCAYABAoAAA==.丶陌上傾寒:AwAGCBIABRQCCgAGAQgZAgA5AsgBBRQACgAGAQgZAgA5AsgBBRQAAA==.',['�']='乌云:AwAICBAABAoAAA==.',['�']='云里屋里:AwAICA8ABAoAAA==.云鹤:AwABCAEABRQAAA==.亚米娜:AwAFCAUABAoAAA==.亦芜小姎姎:AwAGCAcABAoAAA==.',['�']='伊欣小邪:AwADCAMABAoAAA==.伊贝鲁姆:AwAICAIABAoAAA==.会喊六的闲鱼:AwAECAQABRQDAwAIAQi8MABJmL4BBAoAAwAIAQi8MABJmL4BBAoABAAGAQjVRwAGWXAABAoAAA==.伟岸生花:AwACCAEABRQAAA==.',['�']='何必:AwAICBUABAoECwAIAQiyHgBKqvcBBAoACwAHAQiyHgBKkfcBBAoADAABAQidVABLQVgABAoADQABAQjyNgA/UkkABAoAAA==.',['�']='保安张大爷:AwAGCAsABAoAAQ4AO8cCCAQABRQ=.修罗斩:AwAFCAUABRQDCQAFAQgTHwBQbcEABRQACQADAQgTHwBMbsEABRQADwACAQh8BwBG174ABRQAAA==.俺箭伤人:AwAECAQABRQAAA==.',['�']='做个乖尐孩:AwABCAEABRQAAA==.',['�']='光影牧渣:AwAHCAYABAoAAA==.兰斯洛光:AwAHCAcABAoAAA==.兰陵小子:AwAICAYABAoAAA==.',['�']='冷彬彬:AwADCAMABAoAAA==.',['�']='刮痧张大爷:AwAICBsABAoDEAAIAQjPKQA59OsBBAoAEAAIAQjPKQA59OsBBAoAEQAFAQiyQAAXdYwABAoAAQ4AO8cCCAQABRQ=.',['�']='半城尘埃落:AwAICA4ABAoAAQsAX0oFCBcABRQ=.半鬼半仙:AwAICAgABAoAAA==.博士僧:AwACCAIABAoAAA==.卡而斯基:AwAICCYABAoCEgAIAQi4KwA3I+IBBAoAEgAIAQi4KwA3I+IBBAoAAA==.',['�']='又是夏至:AwAICBIABAoAAA==.发梢红纱丶:AwAICAoABAoAAA==.只会闪电链:AwACCAIABRQAAA==.可惜不是昨天:AwAECAEABRQAAA==.',['�']='吖头上有犄角:AwAICBAABAoAAA==.',['�']='哈里小波波:AwAECAIABRQAAA==.',['�']='啊龙吖丶:AwAFCBAABAoAAA==.',['�']='四级:AwAICAoABAoAAA==.',['�']='圣光大咕咕:AwAHCA0ABAoAAA==.圣尖刀啊利亚:AwAGCA0ABAoAAA==.圣殿领主雪儿:AwAICAgABAoAAA==.',['�']='坠星杖:AwAECAUABRQCCwAEAQiCBQBRihgBBRQACwAEAQiCBQBRihgBBRQAAA==.',['�']='堕落后的鼬:AwAICBoABAoCCQAIAQh5MgBMmDkCBAoACQAIAQh5MgBMmDkCBAoAAA==.',['�']='塞弗斯追猎者:AwAECAQABAoAAA==.',['�']='夏维安:AwACCAIABRQAAA==.夜如情漡:AwACCAYABRQCBgACAQicKwAkvIMABRQABgACAQicKwAkvIMABRQAAA==.夜如情觞:AwAHCA0ABAoAAA==.大力抽射:AwAICA0ABAoAAA==.大小:AwABCAEABRQAAA==.大德妹子:AwABCAEABAoAARMAAAABCAEABRQ=.大爷快变身:AwACCAIABRQDFAAIAQjCGgAxLLABBAoAFAAHAQjCGgAxLLABBAoAFQAIAQh+DQAjpWwBBAoAAQ4AO8cCCAQABRQ=.天下共主:AwAECAQABRQAAA==.天堑弦弓:AwAGCAkABAoAAA==.天骑士:AwAECAQABRQAAA==.',['�']='奶少:AwAGCA0ABRQDFgAGAQglAQA+G5MBBRQAFgAGAQglAQA+G5MBBRQAFwABAQgsEQADYz0ABRQAAA==.',['�']='孤城百刃:AwAICA0ABAoAAA==.孤独之杰:AwADCAUABAoAAA==.',['�']='宁凝丶:AwACCAIABRQAAA==.安焙晴明:AwAGCAcABAoAAA==.审判:AwAICAgABAoAAA==.宮本武藏:AwACCAIABRQAAA==.宽恕:AwAICAgABAoAAA==.',['�']='小东东啊:AwAFCAUABAoAAA==.小慈小悲:AwAICBgABAoCGAAIAQgoDgBGu0ICBAoAGAAIAQgoDgBGu0ICBAoAAA==.小拉格:AwAECAQABRQAAQoASekGCAwABRQ=.小机灵鬼:AwAGCAQABRQCGQAIAQihIgA0D+0BBAoAGQAIAQihIgA0D+0BBAoAAA==.小槌子:AwAGCAMABRQAAA==.小猪也怕狼:AwAFCAcABAoAAA==.小珉:AwABCAEABRQAAQMAR20CCAUABRQ=.尘埃飞舞:AwAICAgABAoAAA==.',['�']='屁神的皮卡丘:AwAECAcABAoAAA==.',['�']='峻溪:AwACCAIABAoAAQkATkoGCAYABRQ=.',['�']='巨大型二五仔:AwACCAEABRQAAA==.巴巴变:AwAHCAIABAoAAA==.',['�']='布莱克尔:AwABCAEABRQAAA==.希尔瓦娜思思:AwAICAgABAoAAA==.带血的风行者:AwAGCAkABAoAAA==.',['�']='幺妹儿:AwAICAgABAoAAA==.幼儿园大嫂:AwAHCAcABAoAAA==.幽夜吟风:AwAICCEABAoDFwAIAQhDCgBK30ICBAoAFwAIAQhDCgBEkEICBAoAFgAIAQiTDAA/BigCBAoAAA==.幽藍隨風:AwACCAIABRQDCwAIAQiQLQAxfaQBBAoACwAIAQiQLQAvEaQBBAoADAACAQiuRwAwZYQABAoAAA==.',['�']='弹跳的肉丸子:AwAICAgABAoAARMAAAAGCAQABRQ=.强总:AwAICAYABAoAAA==.',['�']='待定一生丶:AwAECAQABAoAAA==.',['�']='怕球:AwAICAgABAoAAA==.',['�']='恭喜发财:AwAGCAgABRQCCQAGAQgpAABahBgCBRQACQAGAQgpAABahBgCBRQAAA==.',['�']='想起飞不:AwAICAkABAoAAA==.想起飞咯:AwAGCA8ABAoAAA==.',['�']='愤怒哒小鸟:AwACCAMABRQAAA==.',['�']='懒洋洋:AwABCAEABAoAAA==.',['�']='我忆传奇:AwAGCAQABRQAAA==.我忆无为:AwAECAQABAoAAA==.我来变个熊:AwAICBoABAoDEgAIAQhlXgAeoQQBBAoAEgAGAQhlXgAkowQBBAoACAAFAQgwRAAoOtMABAoAAA==.',['�']='拳打义学路:AwAGCAYABAoAAA==.拳打小仙女:AwAFCAoABAoAAA==.',['�']='救赎:AwAICBAABAoAAA==.',['�']='新人物:AwACCAQABRQAAA==.',['�']='旋转的天下:AwAECAQABRQAAA==.时与空:AwACCAMABAoAAA==.',['�']='星夜的尘埃:AwAICBMABAoAAA==.星夜的羽觞:AwAICBUABAoCGgAIAQhoOQAZhz4BBAoAGgAIAQhoOQAZhz4BBAoAAA==.星璇紫夜:AwAICBAABAoAAA==.星神碎影:AwADCAMABAoAAA==.春哥护体:AwACCAEABAoAAA==.',['�']='最爱乐乐:AwAICB0ABAoCCgAIAQiLGgBG1kUCBAoACgAIAQiLGgBG1kUCBAoAAA==.最爱吃虾饺丶:AwACCAIABRQAAA==.月夜丶战神:AwAECAIABRQAAA==.月读:AwAFCAUABAoAAA==.朱若丶:AwABCAEABRQAAA==.',['�']='杉木零落:AwABCAEABAoAAA==.杨总被上了:AwAICAsABAoAARkAF38HCAgABRQ=.杨格斯又胖了:AwACCAIABRQAAA==.松原美纪:AwABCAEABAoAAA==.',['�']='果然烈:AwAICB8ABAoDBQAIAQgKBwBYgJgCBAoABQAIAQgKBwBWWpgCBAoABgAIAQjpFQBTSZACBAoAAA==.枫花恋:AwAICBQABAoCGwAIAQjeDABCjzwCBAoAGwAIAQjeDABCjzwCBAoAAA==.',['�']='梦山:AwAGCAcABAoAAA==.',['�']='歸泣:AwAGCAoABAoAAA==.',['�']='残枫三号:AwAICAoABAoAAA==.',['�']='水银大咕咕:AwAECAQABRQAAQYAKokICAIABRQ=.水银班猪:AwAECAgABRQCGgAEAQhbCgA/APQABRQAGgAEAQhbCgA/APQABRQAAA==.',['�']='汆一下:AwACCAIABAoAAA==.',['�']='泰兰戏德:AwAFCAUABAoAAA==.',['�']='流丶枫:AwAECAQABRQAAA==.流年秋水:AwABCAEABRQAAA==.流浪的神祇:AwAICBAABAoAAQUATvoDCAoABRQ=.',['�']='灰飞烟灭:AwAICAsABAoAAA==.',['�']='烛心:AwACCAIABAoAAA==.',['�']='焚城者伊耿:AwABCAIABRQAAA==.',['�']='爆冷开水:AwAECAgABRQEGAAEAQgiDQA5w6QABRQAGAADAQgiDQA1AqQABRQAHAADAQivFgAX3H8ABRQAAgABAQg9GQBO4loABRQAAA==.爷苏格拉底:AwAECAEABRQAAA==.',['�']='牛一飞了:AwAICAgABAoAAA==.牛德没话说:AwAGCAoABAoAAA==.',['�']='独射寒江雪:AwAECAQABAoAAA==.狼跑了:AwABCAEABRQAAA==.',['�']='猫之报恩:AwAECAQABRQDHQAIAQhYBQBO4WwCBAoAHQAIAQhYBQBJ12wCBAoAEgAIAQjXLABCXdwBBAoAAA==.',['�']='王春梅:AwACCAIABRQCGgAIAQhuLgArKXYBBAoAGgAIAQhuLgArKXYBBAoAAA==.',['�']='珠露:AwAICBAABAoAAA==.',['�']='琅琊灬:AwAGCAYABAoAAA==.琳琳影歌:AwABCAEABAoAAA==.',['�']='瑞秋的酒:AwABCAEABAoAAA==.瑰色星空:AwAHCAcABAoAAA==.',['�']='璧海潮生:AwABCAEABRQAAA==.',['�']='电击治疗:AwAECAMABRQAAQYAKokICAIABRQ=.',['�']='疯狂星期四:AwABCAEABAoAAA==.',['�']='百鬼散尽:AwAECAwABRQDGwAEAQjzAQBT7iwBBRQAGwAEAQjzAQBT7iwBBRQAGQAEAQjRDgAehOgABRQAAA==.',['�']='盘它:AwAGCAYABAoAAA==.盲眼獵手:AwADCAMABAoAAA==.',['�']='真希:AwAICAgABAoAAA==.',['�']='神丨姜维:AwAECAcABRQCFgAEAQiGBQBDyAABBRQAFgAEAQiGBQBDyAABBRQAAA==.',['�']='种田张大爷:AwAICCEABAoDBwAIAQgQIwA7a9UBBAoABwAIAQgQIwA7a9UBBAoAHgADAQi6EgARgHMABAoAAQ4AO8cCCAQABRQ=.',['�']='米兰的小铁酱:AwAICAgABAoAAA==.',['�']='糖一果:AwACCAIABAoAAA==.',['�']='素手研墨:AwAICAgABAoAAA==.素王:AwAECAQABRQAAA==.素素:AwAGCAcABAoAAA==.索瑞森丶大帝:AwAFCAUABAoAARMAAAAGCAQABRQ=.',['�']='繁华叶:AwAGCAQABRQAAA==.繁华飞:AwACCAIABRQAAA==.',['�']='红发张大爷:AwACCAIABRQCAwAIAQgQJwBBnu4BBAoAAwAIAQgQJwBBnu4BBAoAAQ4AO8cCCAQABRQ=.纸鸳的小蜜:AwACCAIABRQAAA==.',['�']='缪莉:AwAGCAYABAoAAA==.',['�']='翔哥的朋友:AwAICBAABAoAAA==.',['�']='老咪根:AwAECAQABAoAAA==.',['�']='肉饼战:AwAECAQABRQAAA==.肉饼骑:AwAICAMABAoAAA==.',['�']='自摸清一色:AwAECAQABRQAAA==.至高王:AwAHCAkABAoAAA==.',['�']='芝麻脸:AwACCAIABAoAAA==.花狸猫大人:AwAGCAgABAoAAA==.花香小叶:AwACCAIABRQAAA==.',['�']='苹果的铁拳:AwAGCAcABAoAAA==.',['�']='茶派:AwAGCAYABAoAAA==.',['�']='荔枝与胖多肉:AwADCAYABRQCCQADAQjqFAAwb+8ABRQACQADAQjqFAAwb+8ABRQAAA==.',['�']='莎莎呆:AwAFCAUABAoAAA==.莫得感情的豆:AwADCAYABRQDBgADAQh5FQA3HeQABRQABgADAQh5FQAxiuQABRQABQACAQhWEAAvMpMABRQAAA==.',['�']='葛炮葛炮:AwACCAIABAoAAA==.葫芦酒大人:AwADCAQABAoAAA==.',['�']='虎灬僧:AwAECAQABRQAAA==.',['�']='蛋疼的小熊猫:AwAGCBUABAoCAQAGAQhCZAAZr+IABAoAAQAGAQhCZAAZr+IABAoAAA==.',['�']='蝎子玩弹弓:AwACCAQABRQDBQAIAQjjDQBS3j8CBAoABQAIAQjjDQBM3D8CBAoABgAIAQhNLwBLshUCBAoAAA==.',['�']='裁衣匠:AwACCAIABAoAAA==.裂石飞环:AwADCAUABRQDGQADAQimDgAn5uoABRQAGQADAQimDgAfNuoABRQAHwABAQhbCQAyJkUABRQAAA==.',['�']='诗墨贝:AwAECAQABRQAAA==.诗美:AwAECAQABRQAAA==.',['�']='谏山一黄泉:AwABCAIABRQAAA==.谢青山催白发:AwAICAsABAoAAA==.',['�']='贰月贰拾柒怒:AwAICAoABAoAAA==.',['�']='超大宝:AwAECAgABAoAAA==.超欧气:AwAFCAQABAoAAA==.超越圣光:AwABCAEABRQAAA==.',['�']='跟着老子冲:AwAICBoABAoDGQAIAQi7GQBDKicCBAoAGQAIAQi7GQBDKicCBAoAHwABAQjNOQAaWysABAoAAA==.路人甲乙丙丁:AwAICA0ABAoAAA==.路小雨丶:AwACCAIABRQAAA==.路过晴天:AwAECAQABRQAAA==.路过暗夜德:AwADCAMABAoAAA==.',['�']='轻描淡写心碎:AwABCAEABRQAAA==.',['�']='辉月相生:AwACCAIABAoAAA==.',['�']='迷之泰钽:AwAFCAUABAoAAA==.',['�']='逐影追魂:AwAECAQABRQAAA==.',['�']='那就这样:AwAICAgABAoAAA==.邪老妖:AwAICAgABAoAAA==.',['�']='醉战神:AwAECAQABAoAAA==.',['�']='重低音:AwAECAQABAoAAA==.重现银河之光:AwADCAMABRQAAA==.野人也有爱:AwABCAIABRQAAA==.',['�']='钟苗苗:AwAICA4ABAoAAA==.',['�']='锐锐大魔王丶:AwAECAQABRQAAA==.',['�']='门卫张大爷:AwACCAQABRQEDgAIAQhQGAA7x/cBBAoADgAIAQhQGAA7x/cBBAoAGgAFAQiYYAAahJoABAoAIAACAQgmHQAcFlkABAoAAA==.',['�']='阿斯兰丶影歌:AwAECAEABAoAAA==.阿睿抚摸阿春:AwAICAgABAoAAA==.阿路:AwAICAwABAoAAA==.',['�']='陈诗若伊:AwAHCA4ABAoAAQMAUYsICB0ABAo=.陈霜红叶:AwAICB0ABAoDAwAIAQhmEABRi4MCBAoAAwAIAQhmEABQJoMCBAoABAABAQipUgA9xUcABAoAAA==.',['�']='随風:AwAGCAgABAoAAA==.',['�']='雨子:AwACCAIABRQAAA==.雨子一搏:AwAICAgABAoAAA==.雪中茶栈:AwAICA8ABAoAAA==.雷小满:AwAICAgABAoAAA==.雾都记忆:AwAGCAoABRQDGQAGAQhtAQA1mY0BBRQAGQAFAQhtAQBA740BBRQAGwABAQjIEAAIQ1cABRQAAA==.',['�']='青山:AwACCAIABAoAAA==.青峰大侠:AwAHCAcABAoAAA==.青梅绿茶:AwAFCAUABAoAAA==.',['�']='頂頂:AwAICBgABAoCBQAIAQhxGwAvYLoBBAoABQAIAQhxGwAvYLoBBAoAAA==.',['�']='飞机:AwAECAQABAoAAA==.飞翔的大冬瓜:AwAECAQABAoAAA==.',['�']='马报国:AwACCAIABAoAAA==.马赛圣光:AwAECAQABAoAAA==.',['�']='骁逍小德:AwADCAMABAoAAA==.',['�']='高北北灬:AwABCAEABAoAAA==.',['�']='魑媚魍魉:AwACCAQABAoAAA==.魔法存在:AwAECAQABRQAAA==.',['�']='鲜血与哈利:AwAICBMABAoAAA==.',['�']='黄半仙:AwAFCAUABAoAAA==.黄瓜惹的祸:AwAICAgABAoAAA==.黑暗中的凝视:AwAECAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end