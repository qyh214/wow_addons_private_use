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
 local lookup = {'Priest-Shadow','Priest-Discipline','Priest-Holy','Mage-Frost','Mage-Fire','Paladin-Retribution','Druid-Restoration','Druid-Balance','Paladin-Protection','Unknown-Unknown','Priest-Healing','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Enhancement','Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Evoker-Preservation','Evoker-Devastation','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Demonology','DemonHunter-Havoc','Mage-Arcane',}; local provider = {region='CN',realm='巫妖之王',name='CN',type='weekly',zone=42,date='2025-04-14',data={Be='Bearbear:AwAECAYABRQEAQAEAQixDAAoaNsABRQAAQAEAQixDAAoaNsABRQAAgABAQh1HQAsf0MABRQAAwABAAgAAAAoNwAABRQAAA==.',Co='Cornerrose:AwAICBAABAoAAA==.',Em='Embrace:AwACCAIABRQAAA==.',Fa='Faker:AwABCAIABRQAAA==.',Fu='Fusker:AwADCAQABAoAAA==.',Ga='Gavln:AwAGCAsABAoAAA==.',Im='Imelegance:AwAFCAUABAoAAA==.',Ir='Ironyquot:AwAICBoABAoDBAAIAQi6IgA3rNcBBAoABAAIAQi6IgA1UNcBBAoABQAGAQjrUQAkLREBBAoAAA==.',Ki='Kiloa:AwAECAQABRQAAA==.',Mt='Mtwhitezz:AwAFCAgABAoAAA==.',Ni='Nidalin:AwADCAMABAoAAA==.',Od='Oda:AwACCAIABRQAAA==.',Pi='Pikavi:AwAECAUABAoAAA==.',Pl='Playerlwgqrc:AwAECAMABAoAAA==.',Qq='Qqs:AwAICAgABAoAAA==.',So='Souo:AwACCAYABRQCAwACAQjBDABGQqcABRQAAwACAQjBDABGQqcABRQAAA==.',Su='Superqs:AwABCAEABRQAAA==.',Ve='Veneno:AwAHCAoABAoAAA==.',Wi='Wilt:AwAGCAYABAoAAA==.',Wy='Wysatelite:AwACCAIABAoAAA==.',Ya='Yagamilightt:AwAECAgABRQCBgAEAQgwEQBIX/wABRQABgAEAQgwEQBIX/wABRQAAA==.',Yl='Yldemon:AwAICAgABAoAAA==.',Yo='Yoen:AwAFCAUABAoAAA==.',Zo='Zoppy:AwAICAgABAoAAA==.',Zt='Ztt:AwAICAgABAoAAA==.',['�']='一川匪云:AwAHCAcABAoAAA==.一车淼淼:AwADCAgABRQDBQADAQhMHQAawb0ABRQABQADAQhMHQANhL0ABRQABAACAQiBDwAlInwABRQAAA==.一随便一:AwADCAMABRQAAA==.不丶高兴:AwAICAgABAoAAA==.两仪喵喵:AwAICAgABAoAAA==.丨血色丨:AwACCAMABRQCBgAIAQgyPABCvBgCBAoABgAIAQgyPABCvBgCBAoAAA==.丨陷阵之志丨:AwACCAIABAoAAA==.丶一抹红:AwADCAMABAoAAA==.丶乂乂:AwADCAEABRQAAA==.丶伊瑞尔丶:AwAECAgABRQCBgAEAQjWAwBfvEIBBRQABgAEAQjWAwBfvEIBBRQAAQUAQ8QICAcABRQ=.丶北栀:AwAICAIABAoAAA==.丶四季映姬:AwAECAMABAoAAA==.丶黄可爱:AwADCAMABAoAAA==.',['�']='乄玛斯:AwAHCAgABAoAAA==.乐人:AwAHCAcABAoAAQUATAYICA0ABRQ=.书嫣烈烈:AwADCAsABRQDBwADAQidBgA3DeQABRQABwADAQidBgA3DeQABRQACAADAQgeFgAWfLwABRQAAA==.',['�']='人潮中的低语:AwACCAIABRQAAA==.',['�']='仰望丶天真美:AwAICAIABRQAAA==.仲小夏:AwAGCAgABRQCCQAGAQihAABIc7QBBRQACQAGAQihAABIc7QBBRQAAA==.',['�']='你的小米糕:AwAECAwABRQDCAAEAQgJDQBBpPIABRQACAAEAQgJDQBBpPIABRQABwACAQj7EQAigXUABRQAAA==.你的小米糖:AwADCAMABRQAAA==.',['�']='俄塞里斯:AwAECAQABRQAAQoAAAAGCAIABRQ=.',['�']='光與影:AwAFCAEABRQCCwABAAgAAAAgSAAABRQAAQABAAgAAAAgSAAABRQAAA==.兔耳茶:AwAGCAgABRQDAgAGAQjVAAA89MgBBRQAAgAGAQjVAAA89MgBBRQAAwACAQgnGAA/Sk4ABRQAAA==.兴奋的母牛:AwAICBQABAoCDAAIAQhpCABSFYUCBAoADAAIAQhpCABSFYUCBAoAAA==.',['�']='农名女工:AwAECAQABRQAAQ0AVXAGCAYABRQ=.冥域浅蓝:AwAGCAYABRQCCQAGAQhSAwAXQxkBBRQACQAGAQhSAwAXQxkBBRQAAA==.冥王凌风:AwAGCAgABAoAAA==.冬天:AwADCAMABAoAAA==.冰可乐更痛快:AwAECBAABRQDDgAEAQg/AwBQiC8BBRQADgAEAQg/AwBQiC8BBRQADwACAQiZHQAapX8ABRQAAA==.',['�']='刀小刀:AwAGCAYABAoAAA==.刘玥丶:AwAICAkABAoAAQUAMkEGCAgABRQ=.',['�']='加了个比海盗:AwABCAEABRQAAA==.动感小王爺:AwADCAMABAoAAA==.',['�']='南城不知北:AwAECAIABRQAAA==.卡丹破晓者:AwAGCAYABAoAAA==.卡尓:AwAHCAgABAoAAA==.卡比兽丶:AwACCAIABRQAAA==.',['�']='古尔龙:AwAICBEABAoAAA==.古彤清月:AwABCAEABRQAAA==.',['�']='吐司椰椰:AwACCAIABAoAAA==.',['�']='嘎咋姐姐:AwAGCBAABAoAAA==.',['�']='回眸浅笑嫣然:AwAICAgABAoAAA==.囡囡低语者:AwADCAcABRQCBgADAQivGgAhRNsABRQABgADAQivGgAhRNsABRQAAA==.固执的小三台:AwAICAwABAoAAA==.',['�']='土人帮新成员:AwAECAIABRQAAA==.土人新成员:AwAGCAgABRQDEAAEAQjvBwBMGdsABRQAEAAEAQjvBwAz3NsABRQAEQAEAQhSDgA2HdMABRQAAA==.圣光小王子:AwAICA4ABAoAAA==.',['�']='塔塔可:AwAICA4ABAoAAA==.',['�']='墮丶丨萨斯穆:AwADCAMABAoAAA==.',['�']='外卖倒了:AwAICA0ABAoAAA==.外卖坏了:AwAECAQABRQAAA==.外卖来了:AwAGCAYABAoAAA==.夜修:AwAFCAUABAoAAQ4AY4gECAQABRQ=.大圣睡不醒:AwABCAIABRQAAA==.天未老情难绝:AwAGCA8ABAoAAA==.天灵:AwAGCAMABRQCEQADAQimDAAzV90ABRQAEQADAQimDAAzV90ABRQAAA==.太空翼:AwADCAQABRQAAA==.头上有鸡角:AwACCAQABRQDEgAIAQiCBABFU0cCBAoAEgAIAQiCBABFU0cCBAoAEwADAQjROgAkJ6IABAoAAA==.',['�']='她二舅:AwAGCAYABAoAAA==.好想吃汤圆:AwAECAQABAoAAA==.',['�']='姜羽彤小妹妹:AwAECAgABRQCBgAEAQiqAwBdYEQBBRQABgAEAQiqAwBdYEQBBRQAAA==.',['�']='威廉王子:AwAICA8ABAoAAA==.娜年夏天:AwAICBAABAoAAA==.',['�']='孤单吸血鬼:AwAECAQABRQAAA==.',['�']='宇佐见茶:AwAGCAQABRQAAA==.宝可梦大师:AwAECAQABRQAAQEAKGgECAYABRQ=.',['�']='寒夜丶:AwAICBQABAoDFAAIAQjvKQA9BN8BBAoAFAAHAQjvKQBA8N8BBAoAFQADAQgPSQAZdmsABAoAAA==.寒鸦劫:AwADCAMABAoAAA==.寻欢:AwAHCAcABAoAAA==.',['�']='小了白了兔:AwADCAMABAoAAA==.小夜君:AwAECAoABAoAAA==.小斐斐丶:AwAECAQABRQAAA==.小时候可牛了:AwAICAkABAoAAA==.小明快跑:AwACCAYABRQCBQACAQiuJQAmGY4ABRQABQACAQiuJQAmGY4ABRQAAA==.小木曾雪菜:AwAHCAoABAoAAA==.小术同学:AwAICBcABAoCEQAIAQiBEQBL0FACBAoAEQAIAQiBEQBL0FACBAoAAA==.小海汀:AwAECAIABRQAAA==.小火鸡丶:AwAECAQABRQAAA==.小转角:AwACCAIABAoAAA==.尢迪安:AwADCAMABAoAAA==.',['�']='山野都有霧灯:AwAECAIABRQAAA==.',['�']='巫喵之王:AwACCAEABAoAAA==.巴黎圣日尔曼:AwAECAQABRQAAQcAOkwGCAUABRQ=.',['�']='强迫症患者:AwAECAQABRQAAA==.',['�']='彩彩爱摸鱼:AwAICAgABAoAAQoAAAAFCAIABRQ=.彼岸椛:AwACCAIABRQAAA==.',['�']='德古拉男爵:AwADCAMABAoAAA==.',['�']='怒炎飞歌:AwABCAEABRQAAA==.怡晶:AwAECAQABRQAAA==.',['�']='您小子:AwABCAEABRQAAA==.悲伤时唱首歌:AwAGCAgABAoAAA==.',['�']='惩戒骑:AwACCAEABAoAAA==.',['�']='慕丨少艾:AwAHCAcABAoAAA==.',['�']='我叫磁力棒:AwAICAwABAoAAA==.我是潇洒:AwAFCAcABAoAAA==.我的圣疗呢:AwAGCAQABRQAAA==.我的好基友:AwAFCAEABAoAAQoAAAAICAwABAo=.战神阿瑞斯:AwACCAIABRQAAA==.房东的猫:AwAHCA0ABAoAAA==.',['�']='抑郁症患者:AwAICAoABAoAAA==.抗霸拽酷天:AwAECAQABRQAAA==.折戟灬沉沙:AwAHCAwABAoAAA==.',['�']='拉达曼迪斯:AwAECAQABAoAAA==.拼命六郎:AwADCAMABAoAAA==.',['�']='掉毛蒲公英:AwAGCAgABAoAAA==.',['�']='提利奥弗丁:AwAGCA0ABRQCBgAGAQhhAABOtvcBBRQABgAGAQhhAABOtvcBBRQAAA==.',['�']='无低暗影君王:AwAICAgABAoAARUAWoEECAgABRQ=.无敌牛牛大王:AwAECAgABRQDFQAEAQhMAwBagTkBBRQAFQAEAQhMAwBagTkBBRQAFAAEAQjNBwAzAwYBBRQAAA==.旧情丶:AwAECAQABRQAAA==.',['�']='明翼:AwABCAEABRQAAA==.星冰乐:AwACCAIABAoAAA==.',['�']='晓月丶残风:AwAECAgABRQCDQAEAQjXCwBInw0BBRQADQAEAQjXCwBInw0BBRQAAA==.晨曦守护者:AwABCAEABAoAAA==.晨铸:AwACCAIABRQAAQoAAAACCAIABRQ=.',['�']='暴怒修血:AwAECAQABRQAAA==.暴走的跳跳:AwAECAUABAoAAA==.',['�']='杀生院祈荒:AwAECAQABRQAAA==.李香兰:AwACCAEABAoAAA==.杜姿藤:AwAICBEABAoAAA==.',['�']='林回音:AwADCAIABAoAAA==.枫之小水:AwAHCBMABAoAAA==.枯藤老树鹌鹑:AwACCAIABAoAAA==.',['�']='柯基不要跑丶:AwAGCAEABRQAAA==.',['�']='桂圆奶酒:AwAFCAgABAoAAA==.',['�']='梦了一个梦:AwAICAgABAoAAA==.',['�']='樱小路露娜:AwAECAIABRQAAA==.樱零丨雨悴:AwAGCAwABAoAAA==.',['�']='橙丶风暴烈酒:AwAGCAgABAoAAA==.',['�']='欧皇丶小呆:AwAECAQABRQAAA==.',['�']='武器战:AwAICAwABAoAAA==.',['�']='沉沙玄晶:AwAECAQABRQAAA==.沐浴在闪电中:AwAICAgABAoAAA==.',['�']='泡泡来咯:AwAECAQABRQAAA==.泰兰徳语风:AwADCAoABRQDFgADAQh/AwBRf8AABRQAFgACAQh/AwBTOMAABRQAEQACAQgJFABKpakABRQAAA==.泰斯塔洛莎:AwAECAYABAoAAA==.',['�']='洋芋派:AwAGCAIABAoAAA==.洪银保:AwACCAIABAoAAA==.',['�']='海汀丶噫喏:AwAGCAYABRQCFQAGAQgwAQAinH8BBRQAFQAGAQgwAQAinH8BBRQAAA==.',['�']='渡月声:AwAECAQABRQAAA==.',['�']='火炎焱燚吼爹:AwAICA8ABAoAAA==.灬超大锤灬:AwAFCAYABAoAAA==.灬青麟丶:AwAGCAsABAoAAA==.灯影牛肉:AwACCAIABRQAAQYAYXwECAMABRQ=.灰机爱振翅:AwAGCAYABRQCCAAGAQhkAABFvvABBRQACAAGAQhkAABFvvABBRQAAA==.灰机飛飛:AwAECAQABRQAAA==.',['�']='煙埖灬弎曰:AwAICAYABAoAAA==.',['�']='爱吃羊驼:AwAHCAoABAoAAA==.',['�']='特点埏:AwAECAQABRQCDgAIAQgZAABjiDIDBAoADgAIAQgZAABjiDIDBAoAAA==.',['�']='猫氵:AwABCAEABAoAAA==.',['�']='瓦斯坏蛋:AwAHCAwABAoAAA==.',['�']='画船听雨眠彡:AwAGCAcABAoAAA==.',['�']='疯四儿:AwAGCAIABRQAAA==.',['�']='白雪公主驾到:AwAICA8ABAoAAA==.',['�']='真希波玛丽:AwAICBgABAoCFwAIAQgSGABLdVkCBAoAFwAIAQgSGABLdVkCBAoAAA==.眼神怼死你:AwAECAQABAoAAA==.',['�']='神威无双:AwAFCAgABAoAAA==.',['�']='离戈丶:AwAECAQABRQAAA==.',['�']='秀叹:AwACCAIABAoAAA==.',['�']='立正:AwACCAIABRQAAA==.竹丶梦魇:AwAECAUABAoAAA==.',['�']='笙如夏花:AwAICAwABAoAAA==.第柒天堂:AwADCAoABRQDEQADAQgpBgBQVxABBRQAEQADAQgpBgBQVxABBRQAEAABAQjzFwAr20gABRQAAA==.',['�']='糯米糕丶:AwAICAcABAoAAA==.',['�']='紅塵雪:AwABCAEABRQCBgAIAQgcWgA428UBBAoABgAIAQgcWgA428UBBAoAAA==.紫燕百味鸡:AwAECAYABRQDEQAEAQi3FQA2CJsABRQAEQACAQi3FQBBepsABRQAEAACAQgUGAAfJUgABRQAAREAS2wGCAYABRQ=.紫色大帝:AwAECAIABRQAAA==.紫靈:AwACCAIABAoAAA==.',['�']='给小潘洗个脚:AwAFCAgABAoAAQoAAAABCAEABRQ=.',['�']='義丨彦祖:AwAGCAYABAoAAA==.',['�']='胖胖爱猪猪:AwACCAIABRQAAA==.胡小刀:AwAICA4ABAoAAA==.胸口一撮毛:AwAECAQABAoAAA==.',['�']='臭臭泥:AwAECAYABRQCFwAEAQgoDQBAs/kABRQAFwAEAQgoDQBAs/kABRQAAA==.致命脉动:AwACCAYABRQCDQACAQiTLwAlMnEABRQADQACAQiTLwAlMnEABRQAAA==.致死丶方休:AwAICAgABAoAAA==.',['�']='舞動黑暗:AwAICA0ABAoAARcAJpkICAUABRQ=.',['�']='艳阳高照:AwAGCAYABAoAAA==.',['�']='芒果哦:AwABCAIABRQAAA==.',['�']='若汐:AwACCAIABAoAAA==.',['�']='范妮斯特鲁伊:AwAECAQABRQAAA==.茶浦:AwABCAIABRQCGAAHAQiNBABFft0BBAoAGAAHAQiNBABFft0BBAoAAA==.茹綶繧知道:AwADCAQABAoAAA==.',['�']='萌萌小虎妞:AwAICAoABAoAAA==.萨萨牧:AwAECAgABRQCAgAEAQgOBgBM0QsBBRQAAgAEAQgOBgBM0QsBBRQAAA==.落葉之秋:AwACCAIABAoAAA==.落雨笙歌:AwAECAQABRQAAA==.',['�']='葬爱家族大佬:AwABCAEABAoAAA==.',['�']='蓝头发萨满:AwAFCAEABAoAAA==.',['�']='蔓步人生:AwAICA8ABAoAAQ0ATx0GCAYABRQ=.',['�']='藍點:AwAGCAYABAoAAA==.',['�']='蘇酒兒:AwACCAIABRQAAA==.',['�']='蜻蜓支队长:AwADCAgABAoAAA==.',['�']='蠕动小奶蛆:AwAECAQABRQAAA==.',['�']='血色肚兜:AwAGCAcABAoAAA==.',['�']='西瓜必须死:AwAECAQABRQAAA==.',['�']='言初:AwAICBAABAoAAQYAYXwECAMABRQ=.言承旭:AwABCAEABRQAAA==.',['�']='谷崎兔一郎:AwAICAgABAoAAA==.',['�']='贵州周润发:AwAFCAUABAoAAA==.',['�']='赤娆:AwAECAIABAoAAQoAAAAGCAcABAo=.',['�']='輸出低还犟嘴:AwAGCAYABAoAAA==.',['�']='远辰:AwACCAIABRQAAA==.',['�']='逆者求心:AwAICAgABAoAAQcAOkwGCAUABRQ=.',['�']='遇朮臨瘋:AwAGCAYABAoAAA==.遠坂丶凛:AwAECAMABRQDBgAIAQgzBABhfAkDBAoABgAIAQgzBABhfAkDBAoACQAIAQjACwBKuiUCBAoAAA==.',['�']='醉裡挑灯看剑:AwAGCA0ABAoAAA==.醉驾的吕师傅:AwABCAEABRQAAA==.',['�']='野原银之介:AwAECAQABRQAAQ0AShkGCA4ABRQ=.',['�']='银鞍照白马丶:AwAICAMABAoAAA==.',['�']='锥锥:AwAICAgABAoAAA==.',['�']='闭月羞花嫣:AwACCAIABAoAAA==.',['�']='阿勺仔:AwAECAQABRQAAA==.阿拉丁神丁:AwAICAgABAoAAA==.',['�']='隕落殤逝:AwAECAQABRQAAA==.',['�']='雨季:AwAECAYABRQCCAADAQiPGAA3b6cABRQACAADAQiPGAA3b6cABRQAAA==.雷霆破晓:AwAGCAYABAoAAA==.',['�']='非洲惊奇男孩:AwABCAEABAoAAA==.',['�']='風沙走石:AwADCAMABAoAAA==.風飘零:AwAFCAUABAoAAA==.',['�']='风之羽:AwAHCAwABAoAAA==.风行逐风者:AwAHCAgABAoAAA==.飘渺丶:AwACCAQABRQAAA==.飞翌:AwAGCA4ABRQDDQAGAQi+FAAmVecABRQADQAEAQi+FAAtFOcABRQADAACAQj6DgAcN6AABRQAAA==.',['�']='魂绕俏佳人:AwAGCAYABAoAAA==.魔法奶昔:AwAHCAwABAoAAA==.魔王之盾:AwADCAMABAoAAA==.',['�']='鱼鱼:AwAICA8ABAoAAA==.',['�']='鸠灬:AwAGCAYABAoAAA==.鸢漓丶牧牧:AwABCAEABRQAAA==.',['�']='黑暗中的低语:AwAICAgABAoAAA==.黑桐未娜:AwACCAIABRQAAA==.',['�']='龙猫不是猫:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end