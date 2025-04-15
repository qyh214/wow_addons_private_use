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
 local lookup = {'Unknown-Unknown','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Restoration','Monk-Mistweaver','Paladin-Retribution','Hunter-BeastMastery','Druid-Balance','Druid-Feral','Druid-Restoration','Priest-Shadow','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Priest-Discipline','Priest-Holy','Warrior-Fury','Warrior-Arms','Hunter-Marksmanship','Paladin-Protection','Paladin-Holy','Druid-Guardian','DemonHunter-Havoc',}; local provider = {region='CN',realm='格雷迈恩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ae='Aerfengs:AwADCAMABRQAAA==.',Ch='Chaosfiend:AwADCAUABAoAAA==.',Ci='Cilantro:AwAECAQABRQAAA==.',Da='Daredevil:AwAHCBIABAoAAQEAAAAECAQABRQ=.',De='Deviharris:AwAECAQABRQAAA==.',Di='Dishike:AwAHCAwABAoAAA==.',Es='Eshic:AwAECAQABRQAAA==.',Fo='Forvictory:AwACCAIABRQAAA==.',Fr='Frankcaprio:AwAICA4ABAoAAQIAT1sHCAUABRQ=.',Hi='Hisashi:AwADCAMABRQAAA==.',Je='Jeffqs:AwACCAIABRQAAA==.',Ko='Koishi:AwABCAEABRQAAA==.',La='Laurentina:AwAECAcABAoAAA==.',Ma='Makabaka:AwAFCAUABAoAAA==.',Me='Melbisty:AwAECAQABRQAAA==.Mercuryer:AwADCAUABAoAAA==.',Ms='Mscasd:AwAICAoABAoAAA==.',Mu='Murkshadow:AwAICBoABAoDAwAIAQiEMQA0KLoBBAoAAwAIAQiEMQAxs7oBBAoABAAIAQhVIQAp7lEBBAoAAA==.',Od='Odeadbloodo:AwABCAIABRQCBQAIAQjgJABAHdcBBAoABQAIAQjgJABAHdcBBAoAAA==.',Sa='Sausagepp:AwAECAUABAoAAA==.',Sh='Shinichi:AwAECAQABRQAAA==.Shiyoux:AwAECAQABAoAAA==.',Si='Sinp:AwAGCAQABRQAAA==.',Sm='Sml:AwAICAgABAoAAA==.',Su='Suai:AwAGCAcABAoAAA==.Sundynasty:AwAECAcABRQCBQAEAQiaCgA3L+0ABRQABQAEAQiaCgA3L+0ABRQAAA==.',Sw='Sweetaltman:AwABCAEABAoAAA==.',Va='Vampiredamon:AwAFCBAABAoAAA==.',Wa='Wangren:AwACCAIABAoAAA==.',['�']='一小月儿一:AwABCAEABRQAAA==.万佳人:AwAFCAUABAoAAA==.不丶讲道理:AwABCAEABRQAAA==.不知云过:AwAGCAYABRQCBgAGAQiPAgASqG0BBRQABgAGAQiPAgASqG0BBRQAAA==.不穿袜子:AwAICAYABAoAAA==.不饮醉花阴:AwAHCAcABAoAAA==.丑到拖网速:AwAECAIABRQAAA==.丨假职业丨:AwAGCAMABAoAAA==.丶云端咆哮:AwAHCA0ABAoAAA==.丶小秋月丶:AwAECAgABAoAAA==.丶当红头牌:AwAGCAoABRQCBwAGAQhlAABQiPUBBRQABwAGAQhlAABQiPUBBRQAAA==.丿辰之雾灬:AwADCAIABRQAAA==.',['�']='乀邪道:AwAHCBEABAoAAA==.乌龙鲨鱼辣椒:AwAECAQABRQAAA==.乖巧乖巧:AwAICAgABAoAAA==.',['�']='人中一竖:AwAECAQABAoAAA==.',['�']='今晚吃串串:AwAICAgABAoAAA==.',['�']='伊卡璐斯:AwAECAgABRQCCAAEAQhpEwA5vuwABRQACAAEAQhpEwA5vuwABRQAAA==.会泡面德大叔:AwADCAQABRQDCQAIAQi7DgBU55wCBAoACQAIAQi7DgBU55wCBAoACgACAQh4HQA6tKAABAoAAA==.',['�']='低保老大爷:AwAICAsABAoAAA==.你不是我的肉:AwAGCAcABAoAAA==.',['�']='冬奎:AwABCAEABRQCCAAIAQjwVAAmMoUBBAoACAAIAQjwVAAmMoUBBAoAAA==.冰美式加冰:AwABCAEABAoAAA==.冰龟罗克:AwAHCAcABAoAAA==.',['�']='凛冬之寒:AwAECAQABRQAAA==.凯莉佩利:AwACCAIABRQAAA==.',['�']='划水队长:AwAGCAYABAoAAA==.刚勇鎭西一:AwAECAQABRQAAA==.别死我面前:AwAFCAsABAoAAA==.',['�']='力口尔鲁什:AwAICA4ABAoAAA==.',['�']='十九开始:AwAECAYABRQDCQAEAQi/DAA8E/QABRQACQAEAQi/DAA8E/QABRQACwACAQi/EgAbqHEABRQAAQwANuAGCAIABRQ=.十年水流东:AwAHCAcABAoAAA==.卡拉赞毕业:AwAECAQABRQAAA==.',['�']='原地飞升:AwAECAgABRQEDQAEAQjOAQA5VvwABRQADQAEAQjOAQA5VvwABRQADgACAQhAIAAJx1wABRQADwACAQiUGgAJJDwABRQAAA==.',['�']='叫我可爱虎:AwAECA0ABRQDAwAEAQjFFAAuRaUABRQAAwACAQjFFAA+UaUABRQABAADAQggGAAMLlUABRQAAA==.可罗:AwABCAEABRQDCQAIAQgiIwBMCxQCBAoACQAIAQgiIwBMCxQCBAoACwACAQhiVwA8Y4sABAoAAA==.可莉同学:AwAICAcABAoAAA==.',['�']='听雨:AwADCAMABAoAAA==.',['�']='唇情灬小久久:AwACCAIABRQAAA==.唐西西:AwABCAEABAoAAA==.唯受:AwAFCAUABAoAAA==.',['�']='四爸爸:AwAFCAUABAoAAA==.四顾:AwAECAkABRQDAwAEAQh8CwA5b+4ABRQAAwAEAQh8CwAzwu4ABRQABAAEAQg/DgAjt6cABRQAAA==.',['�']='圣光永恒:AwAGCAcABAoAAA==.圣火喵喵教主:AwABCAEABAoAAA==.',['�']='夜蓝非天:AwAICAoABAoAAA==.大丶都督:AwACCAIABRQAAA==.大刘同学:AwAECAQABAoAAA==.大小小教不会:AwAHCAcABAoAAA==.大水牛:AwACCAIABAoAAA==.大灬哥大:AwAECAgABRQEDwAEAQgaAwBTeRIBBRQADwADAQgaAwBPtBIBBRQADgADAQj0CQBON/AABRQADQABAQgJFQAAAAAABRQAAA==.大熊本熊:AwAICAQABRQAAA==.天下一滴雨:AwAHCCIABAoEEAAHAQiAIgA9v44BBAoAEAAGAQiAIgA34I4BBAoAEQAHAQgrMgAtX00BBAoADAAGAQijMwAm9hcBBAoAAA==.太阳月亮星星:AwAGCBIABAoAAA==.央墨:AwAICAgABAoAAA==.',['�']='如果风可以飘:AwAGCAIABAoAAA==.',['�']='孙艺珍啊:AwACCAIABAoAAA==.',['�']='宝可梦大师:AwADCAMABAoAAA==.',['�']='小小疯牛:AwAECAQABRQAAA==.小柴胡:AwABCAEABAoAAA==.小火猴:AwAECAQABRQAAA==.小豆角儿:AwAGCAgABAoAAA==.尼尼胡:AwAGCAYABAoAAQEAAAAGCAIABRQ=.',['�']='左手丶倒影:AwAICAgABAoAAA==.',['�']='希瓦猎夜:AwAECAEABAoAAA==.',['�']='年年糕:AwAECAMABRQAAA==.年糕戰士:AwAFCAYABAoAAA==.年糕蜀师:AwAFCAgABAoAAA==.幸福计算法:AwAFCAQABAoAAA==.幸運快車:AwAHCBEABAoAAA==.幸運猫小魅:AwAECAQABAoAAA==.幸運靓术:AwAECAQABAoAAA==.',['�']='张小天最可爱:AwAHCAgABAoAAA==.张雕:AwABCAIABRQAAA==.弹头丶:AwAGCAkABAoAAA==.',['�']='影歌的忧伤:AwAICA4ABAoAAA==.',['�']='徊年丶念然:AwAGCAIABRQAAA==.德莱格:AwAECAQABRQAAA==.',['�']='心颖:AwAFCAcABAoAAA==.快跑:AwAECAgABAoAAA==.快躲开:AwADCAMABAoAAA==.',['�']='我乃罔两也:AwABCAEABAoAAA==.我小名叫不服:AwAICA4ABAoAAA==.我怎么趴不下:AwAICBAABAoAAA==.我煮面给你吃:AwAECAQABRQAAA==.',['�']='扎斯木屋:AwABCAEABRQAAA==.',['�']='拾又壹年:AwAECAQABAoAAA==.',['�']='指尖丨若相惜:AwACCAMABAoAAA==.',['�']='提里凹弗丁:AwACCAIABAoAAA==.',['�']='摸鱼王:AwAICBEABAoAAA==.',['�']='撒旦的小羊:AwAICAgABAoAAA==.撒旦的爪牙:AwACCAIABAoAAA==.',['�']='方圆于心:AwACCAIABAoAAA==.',['�']='旋转不跳跃:AwAGCAQABRQAAA==.无情:AwAFCAUABAoAAA==.无敌大笨熊:AwABCAIABRQAAA==.无痕之湮:AwAFCAUABAoAAA==.无聊是种习惯:AwAFCAcABAoAAA==.无芯:AwAFCAQABAoAAA==.无限丶暴击:AwAECAQABRQAAA==.',['�']='晚点拯救世界:AwAICA0ABAoAAA==.',['�']='暗矛西瓜汁:AwAICAwABAoAAA==.',['�']='月神殿城主:AwAICCMABAoDCwAIAQiZCQBOyHMCBAoACwAIAQiZCQBOyHMCBAoACQABAQgAtQAJhBcABAoAAA==.朽雨:AwAECAQABRQAAA==.',['�']='果粒橙:AwACCAIABRQAAA==.',['�']='某惩戒骑:AwAGCAYABAoAAA==.柒號:AwAECAUABRQDEgADAQgkDABARPoABRQAEgADAQgkDAA0KvoABRQAEwACAQgrCwA3qJsABRQAAA==.',['�']='桃香乌龙茶:AwAICAgABAoAAA==.桖牙:AwAECAgABRQDDwAEAQh5CAAYZtQABRQADwAEAQh5CAAXXtQABRQADgACAQh9HgAT1mkABRQAAA==.桖芽:AwACCAQABRQAAQgAPf8GCAkABRQ=.',['�']='槐雪如风:AwAICAgABAoAAA==.',['�']='樱丿語:AwAGCAIABRQAAQEAAAAICAQABRQ=.',['�']='歲月無聲:AwAICAgABAoAAA==.',['�']='残月枫丶蒙罗:AwAGCAYABAoAAA==.殺手不太冷:AwAGCAYABAoAAA==.',['�']='沁芯:AwAECAQABRQAAA==.沉醉不知歸路:AwAECAQABRQAAA==.油呛臭牛皮:AwACCAQABRQAAA==.',['�']='洛櫻:AwAICB0ABAoCFAAIAQgiHwAsKZ8BBAoAFAAIAQgiHwAsKZ8BBAoAAA==.活泼的海底捞:AwABCAEABRQAAA==.',['�']='浣浣:AwAECAQABRQAAA==.浮云过客:AwAECAgABRQDAwAEAQi6CABHK/8ABRQAAwAEAQi6CABHK/8ABRQABAAEAQhgFQAGtW4ABRQAAA==.海岛小胡子:AwADCAMABRQAAA==.',['�']='溜溜球灬:AwAGCAYABAoAAA==.',['�']='潜行路人甲:AwAGCAkABAoAAA==.',['�']='濒湖猫社社长:AwAFCAUABAoAAA==.',['�']='灬奥利奥:AwAGCAwABAoAAA==.灬晴空末岛:AwAGCBUABAoDEQAGAQhhRwApSusABAoAEQAGAQhhRwApSusABAoADAABAQihYQAur0IABAoAAA==.灬神挡杀神灬:AwAGCAYABAoAAA==.灵妹:AwACCAIABRQAAA==.',['�']='熊喵蜀黍:AwAECAQABRQAAA==.熟睡的丈夫:AwAECAQABAoAAA==.',['�']='爱用舒肤佳:AwAGCAEABRQAAA==.爱静静的一天:AwAICAgABAoAAA==.爻乙口:AwAGCAcABAoAAA==.',['�']='牧养人:AwAGCAgABAoAAA==.',['�']='狐狸骑猫:AwAICBIABAoAAA==.',['�']='猜东里猜:AwAECAIABAoAAA==.',['�']='獸人永不为奴:AwADCAEABAoAAA==.',['�']='玄叶的爱妃:AwABCAEABAoAAA==.',['�']='珍妮玛灬戴紟:AwAICAgABAoAAA==.',['�']='璎丶:AwAICAgABAoAAA==.',['�']='甘鳕熊:AwABCAEABRQAAA==.',['�']='白衣:AwAHCAcABAoAAA==.',['�']='瞞天:AwACCAIABRQAAA==.',['�']='知凡丶欣光:AwAFCAUABAoAAA==.',['�']='祈秋秋:AwADCAMABRQAAA==.',['�']='空穴来風:AwAECAQABAoAAA==.',['�']='第四丶苜蓿:AwAECAQABAoAAA==.',['�']='糖塚:AwAHCBQABAoCBwAHAQjzfgAugW8BBAoABwAHAQjzfgAugW8BBAoAAA==.',['�']='紫丨枫:AwAECAcABRQEFQAEAQg5CQAjvJ4ABRQAFQAEAQg5CQAjvJ4ABRQAFgACAQiNDAATp4MABRQABwABAQjsPgAEtkIABRQAAA==.紫云小白:AwADCAIABRQDEQAIAQgFPgAgXhMBBAoAEQAHAQgFPgAbRhMBBAoADAAFAQjhNwA3k/wABAoAAA==.紫色的黎明:AwABCAEABAoAAA==.紫色瞳孔丶:AwAICAQABAoAAA==.',['�']='緃火的树哥丶:AwAFCAkABAoAAA==.',['�']='终极杀戮彡:AwAICAgABAoAAA==.绮丶念:AwAICAIABAoAAA==.绿豆天上飞:AwADCAMABAoAAA==.',['�']='美丽的万物:AwACCAIABAoAAA==.美杜莎灬女王:AwAECAQABRQAAA==.美蛙鱼头:AwACCAIABRQAAA==.',['�']='老鸽:AwAECAQABRQAAA==.',['�']='膏仁义燈:AwABCAIABRQCFwAIAQh2AwBPHWACBAoAFwAIAQh2AwBPHWACBAoAAA==.',['�']='苏蔓:AwAICAwABAoAAA==.',['�']='荭内内:AwABCAEABAoAAA==.',['�']='莫得法:AwAICAgABAoAAA==.',['�']='落零星:AwABCAEABRQAAA==.',['�']='蒋姑娘:AwACCAIABAoAAA==.',['�']='藤崎诗织:AwABCAEABRQAAA==.',['�']='血兽的小马喽:AwAICAoABRQCAwAGAQiBAABBg9wBBRQAAwAGAQiBAABBg9wBBRQAAA==.',['�']='覆己负卿:AwADCAMABAoAAA==.',['�']='角卷绵芽:AwAHCAcABAoAAQEAAAABCAIABRQ=.',['�']='该吃火锅:AwAFCAUABAoAAA==.',['�']='谦让:AwAECAQABRQAAQMAONUGCAYABRQ=.',['�']='豹子头零充:AwACCAUABRQCGAACAQjNIwAJnnAABRQAGAACAQjNIwAJnnAABRQAAA==.',['�']='赖着想死:AwAGCAYABAoAAA==.赞达拉魔术师:AwABCAEABAoAAA==.',['�']='超威重装王:AwACCAIABRQAAA==.',['�']='进化后的喵咪:AwABCAEABAoAAA==.',['�']='逐日追风:AwAICAgABAoAAA==.',['�']='郁闷了喝牛奶:AwAECAsABRQDCQAEAQi8BABV3isBBRQACQAEAQi8BABV3isBBRQACwABAQgvGwAS/jkABRQAAA==.',['�']='酒笙清栀:AwAECAQABRQAAA==.',['�']='重庆周润发:AwABCAEABRQAAA==.',['�']='闪现冰箱:AwAICA8ABAoAAA==.',['�']='阿斯特蕾雅:AwAGCA4ABRQDEgAGAQhEEAAtKNgABRQAEgAEAQhEEAAUIdgABRQAEwAGAAgAAAAtKAAABRQAAA==.阿瑞西娅:AwABCAEABAoAAA==.',['�']='随风而逝:AwAICAoABAoAAA==.隔壁的那只鸡:AwABCAIABRQAAA==.',['�']='雪域男爵:AwAECAQABRQAAA==.雪夜无憾:AwAICAgABAoAAA==.雪舞残阳:AwADCAMABRQAAA==.雷军的恐怖:AwAHCAcABAoAAA==.',['�']='靖立青:AwAFCAgABAoAAA==.非洲小白脸吖:AwAGCAYABAoAAA==.面条牛牛:AwAGCAsABAoAAA==.',['�']='风雪之城城主:AwAFCAUABAoAAA==.飞主牛丶:AwACCAIABRQAAA==.飞飞:AwACCAIABRQAAA==.',['�']='魔力鸭:AwAICAgABAoAAA==.',['�']='麦当劳大叔:AwACCAIABRQAAA==.麦辣鸡腿汉堡:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end