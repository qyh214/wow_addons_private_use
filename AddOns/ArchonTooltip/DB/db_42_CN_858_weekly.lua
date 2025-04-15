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
 local lookup = {'Shaman-Restoration','Paladin-Retribution','Hunter-Marksmanship','Unknown-Unknown','DeathKnight-Unholy','Druid-Balance','Priest-Healing','Priest-Discipline','Paladin-Protection','Paladin-Holy','Monk-Windwalker','Warrior-Arms','Evoker-Devastation','Mage-Fire','Monk-Brewmaster','Hunter-BeastMastery','DeathKnight-Blood','Evoker-Preservation','Warrior-Fury','Warlock-Destruction','Warlock-Affliction','Shaman-Elemental','Rogue-Subtlety',}; local provider = {region='CN',realm='闪电之刃',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Aladdin:AwAECAQABRQAAA==.Alucard:AwAECAwABRQCAQAEAQjkDAAxQOkABRQAAQAEAQjkDAAxQOkABRQAAA==.',Ar='Aresgalaxyol:AwAECAQABRQAAA==.',Az='Azer:AwAICAgABAoAAA==.',Bl='Bloodthorn:AwAGCAYABAoAAA==.',Da='Dashtruck:AwAECAgABAoAAQIAWAsCCAIABRQ=.',He='Hersheys:AwAECAQABAoAAA==.',Hu='Huntheart:AwAECAEABRQCAwAIAQieEwBJMgsCBAoAAwAIAQieEwBJMgsCBAoAAQQAAAAGCAMABRQ=.',Ja='Janmi:AwAICAQABAoAAA==.',Mo='Moumentei:AwABCAEABRQCAQAIAQjeJwA9BM8BBAoAAQAIAQjeJwA9BM8BBAoAAA==.',Mu='Mukai:AwAECAQABRQAAA==.',Sa='Saberlisa:AwACCAIABRQAAA==.',So='Sombres:AwAECAQABRQAAA==.',St='Strongest:AwAICAgABAoAAA==.',Wa='Warryc:AwADCAMABAoAAA==.',Wu='Wuhuuz:AwAFCAcABAoAAA==.',['�']='一世灬:AwAGCAcABAoAAA==.一步两步走:AwAGCAYABAoAAA==.一逐风者一:AwACCAMABRQCBQAHAQgZPgA2UpEBBAoABQAHAQgZPgA2UpEBBAoAAA==.一队的骑士:AwAECAQABRQAAA==.世博园射手王:AwAGCAkABAoAAA==.世界花式抖腿:AwAFCAYABAoAAA==.丨倩妮迪丨:AwABCAEABRQAAA==.丨白丨:AwADCAMABAoAAA==.丶九月破晓:AwAFCAYABAoAAA==.丶二月破晓:AwAECAgABAoAAA==.丶科拉克休灬:AwABCAEABAoAAA==.丶艾尔忒弥斯:AwAICBAABAoAAA==.',['�']='乌克丽丽:AwAGCAYABAoAAA==.乔大白:AwAFCAcABAoAAA==.乖乖吃饭:AwAECAQABAoAAA==.乱窜的可可:AwAECAQABAoAAA==.',['�']='亲亲小相公:AwAECAQABRQAAQYAQiQGCAoABRQ=.',['�']='伊利灬丹:AwAFCAUABAoAAA==.',['�']='佐岐囍迦伊:AwAICAoABAoAAA==.体育西路:AwAICAgABAoAAA==.余则成:AwABCAEABAoAAA==.你是个好人:AwAICAgABAoAAA==.你的模范男友:AwAECAEABRQAAQQAAAAICAQABRQ=.',['�']='依旧丶:AwACCAIABAoAAA==.依旧丶楽天:AwAFCAUABAoAAA==.',['�']='光溜溜的阿飞:AwAHCAcABAoAAA==.光老师:AwAECAQABAoAAA==.兜里全是棍:AwAECAQABRQAAA==.六个七:AwAECAQABRQAAA==.兮兮宝宝:AwAICAgABAoAAA==.兽魂:AwABCAEABRQAAA==.',['�']='别开嗜血:AwAGCAgABAoAAA==.别追我:AwAICA8ABAoAAA==.',['�']='加勒比寶寶:AwAGCAYABAoAAA==.势不可挡骑士:AwACCAEABAoAAA==.',['�']='千灬叶:AwACCAMABAoAAA==.卜啵丶灰烬:AwADCAMABAoAAA==.',['�']='古德伊温宁丶:AwABCAEABAoAAA==.可乐戒指:AwAECAIABRQCBwACAAgAAABE8wAABRQACAACAAgAAABE8wAABRQAAA==.叽歪叽歪:AwACCAIABAoAAA==.',['�']='哈噻给:AwAECAQABRQAAA==.',['�']='唔斯卡:AwAICAgABAoAAA==.',['�']='啥钱不钱的:AwACCAIABRQAAA==.啵西卡长公主:AwAICB8ABAoDAgAIAQhAxAAb0/EABAoAAgAIAQhAxAAb0/EABAoACQAIAQgNZAAAJwQABAoAAA==.',['�']='嗷嗷芋头:AwAECAQABRQAAA==.',['�']='噢啦噢啦:AwAICBAABAoAAA==.',['�']='回忆震耳欲聋:AwAGCAcABAoAAA==.囧囧有神灬:AwAECAQABRQAAA==.',['�']='土豆炒马铃薯:AwAGCAYABAoAAA==.圣使之翼:AwAICAkABAoAAA==.圣光丶血蹄:AwACCAIABRQCAgAIAQiqIQBYC4ECBAoAAgAIAQiqIQBYC4ECBAoAAA==.圣光将熄:AwAICAgABAoAAA==.圣光忽悠着我:AwAECAMABAoAAA==.圣光重燃:AwAICAgABAoAAA==.圣光飞雪:AwAHCAcABAoAAA==.圣咣与你同在:AwAICAcABAoAAA==.',['�']='坡尔肥:AwABCAEABAoAAA==.',['�']='堕天丨真红:AwAECAQABRQAAA==.',['�']='塔兹汀苟:AwAICAcABAoAAA==.',['�']='墨蒅的樱花:AwAGCAYABAoAAA==.',['�']='壶把伤心鸟:AwAECAkABRQECgAEAQjCBQA01eQABRQACgAEAQjCBQA01eQABRQAAgAEAQh/GwAoUOMABRQACQABAQjxGAAAAAAABRQAAA==.',['�']='夏大调:AwABCAEABRQAAA==.夜来香:AwADCAMABAoAAA==.夜氵未央:AwAICAoABAoAAA==.大哥等等我:AwAFCAkABAoAAA==.大坏蛋哒哒:AwABCAEABRQAAA==.大坏蛋蒯蒯:AwABCAIABRQAAA==.大宝宝来了:AwAECAQABAoAAA==.大磊子:AwAHCA0ABAoAAA==.大米中医:AwAGCAYABAoAAA==.大舌头:AwAICAoABAoAAA==.天丨哪:AwAICAgABAoAAA==.天堂人:AwAFCAcABAoAAA==.天天圣骑:AwACCAIABAoAAA==.天秤座童虎:AwAICBoABAoCCwAIAQgoGQA3FfkBBAoACwAIAQgoGQA3FfkBBAoAAA==.头油帮丶嘉图:AwAECAQABRQAAA==.',['�']='奶茶不加冰:AwAECAoABRQCDAAEAQjeBAA2zPoABRQADAAEAQjeBAA2zPoABRQAAA==.好丶人:AwAECAQABRQAAA==.',['�']='如夢亦如幻:AwABCAEABAoAAA==.',['�']='安格隆:AwAGCAYABAoAAA==.宋慧喬:AwABCAEABAoAAA==.宝哥哥:AwACCAIABAoAAA==.',['�']='寻找龙族人:AwAECAQABAoAAA==.',['�']='小动物乱来的:AwAECAQABAoAAA==.小小的小小的:AwADCAUABAoAAA==.小恶魔僧:AwACCAIABAoAAA==.小新:AwAICAgABAoAAA==.小笼包不包:AwAGCAMABRQCDQAIAQi/HAApaKwBBAoADQAIAQi/HAApaKwBBAoAAQ0AD08ICAUABRQ=.小菊:AwAFCAUABAoAAA==.小阿达梅尔:AwABCAEABRQAAA==.小骑士:AwACCAIABRQAAA==.尐可愛:AwACCAIABRQAAA==.就拉关键胯:AwAECAQABRQAAA==.',['�']='峨眉峰:AwAICAgABAoAAA==.峰哥的干爹丶:AwAECAQABRQAAA==.',['�']='巧乐兹加冰:AwABCAEABRQAAA==.巴布豆:AwAGCBYABRQCDgAGAQgaAQBSLwsCBRQADgAGAQgaAQBSLwsCBRQAAA==.',['�']='干饭大宗师:AwAECAYABRQCDwAEAQjxAwAsyq4ABRQADwAEAQjxAwAsyq4ABRQAAA==.平心静气:AwACCAQABRQAAA==.平衡牧:AwABCAEABRQAAA==.幸福来敲门:AwAFCAkABAoAAA==.',['�']='张一壹:AwAFCAUABAoAAA==.',['�']='影伤:AwAECAQABRQAAA==.',['�']='很可怕的骑士:AwAHCAgABAoAAA==.',['�']='恩希玛就咸菜:AwAECAQABRQAAA==.恶魔十七楼:AwAECAQABRQAAA==.恶魔能变大:AwAECAQABRQAAA==.',['�']='想喝可乐:AwAECAQABRQAAA==.',['�']='我不好说:AwABCAEABAoAAA==.我不是肥猪:AwADCAMABAoAAA==.我是肥猪:AwAECAQABAoAAA==.战斗软泥:AwAGCAgABAoAAA==.',['�']='扭头不跑:AwAECAMABRQAAA==.',['�']='抠脚抠出血:AwABCAEABRQAAA==.报之以歌:AwAICAgABAoAAA==.',['�']='括约肌撕裂者:AwAICAcABAoAAA==.拾银子的猪仔:AwAICAgABAoAAA==.',['�']='收酒的:AwAICAgABAoAAA==.',['�']='敖隐:AwACCAcABRQCDQACAQi0DwBIfq0ABRQADQACAQi0DwBIfq0ABRQAAA==.',['�']='斧者乱人心:AwADCAMABAoAAA==.',['�']='明帅的大领主:AwAGCAYABAoAAA==.是小尾巴涅:AwAECAQABRQAAA==.',['�']='暖冰丶:AwAHCAcABAoAAA==.暗魔導士:AwAICAgABAoAAA==.暴风雪丶啊糗:AwAFCAUABAoAAA==.',['�']='月光下的蓝:AwAICBsABAoCAQAIAQgKLgA3ZbEBBAoAAQAIAQgKLgA3ZbEBBAoAAA==.末代丶沉睡:AwAECAgABRQCEAAEAQgbFQA1q+4ABRQAEAAEAQgbFQA1q+4ABRQAAQYADlAGCA8ABRQ=.朱祺润夏:AwAGCAwABAoAAA==.',['�']='李知嗯:AwADCAMABRQCAgAIAQghCABguvUCBAoAAgAIAQghCABguvUCBAoAAA==.村头屠夫:AwACCAQABRQDBQAIAQiGCABdFcwCBAoABQAIAQiGCABdFcwCBAoAEQABAQhNYwACABMABAoAAQQAAAAICAIABRQ=.村头裁缝:AwAECAQABRQAAA==.',['�']='林小伊:AwACCAIABAoAAA==.',['�']='染血得柒月:AwAICAgABAoAAA==.',['�']='格拉西亚:AwAFCAcABAoAAA==.',['�']='桑尼:AwAGCAYABAoAAA==.',['�']='槑毛儿:AwAICBAABAoAAA==.',['�']='欧气满满:AwACCAEABRQAAA==.',['�']='死亡军士:AwAECAQABAoAAA==.',['�']='毛丶綫:AwACCAIABRQAARIAEQYCCAUABRQ=.毛线:AwACCAUABRQDEgACAQhbBwARBmkABRQAEgACAQhbBwARBmkABRQADQABAQjbGwALCjQABRQAAA==.',['�']='江小白丶:AwAECAQABRQAAA==.',['�']='沉梦听雨:AwAICAgABAoAAA==.河北周杰伦:AwAGCAcABRQDDAAGAQgcAQAfd5gBBRQADAAGAQgcAQAbJpgBBRQAEwABAQjWIgA2R04ABRQAAA==.油纸伞:AwAFCAUABAoAAA==.',['�']='法式开嗜血:AwAICAgABAoAAA==.法狗:AwAECAQABRQAAA==.泽连思鸡:AwAECAQABAoAAA==.',['�']='深陷苍穹:AwAECAMABRQAAA==.淸风:AwAECAQABRQAAA==.',['�']='清野凛:AwAGCAYABRQDFAAGAQhEBgBKGRkBBRQAFAAEAQhEBgBEfRkBBRQAFQACAQgjDQBSg6YABRQAAA==.温特利克斯斯:AwAGCAEABAoAAQQAAAAECAQABRQ=.',['�']='灬万丈红尘灬:AwADCAgABRQCDwADAQigBQAIfX0ABRQADwADAQigBQAIfX0ABRQAAA==.灬凯特琳娜丶:AwADCAMABAoAAA==.',['�']='烈日狂徒:AwAICAgABAoAAA==.烈焰启迪:AwACCAIABAoAAA==.热忱:AwAECAQABRQAAA==.',['�']='焦糖小甜心:AwAICAgABAoAAA==.',['�']='燱想天开:AwABCAEABRQCFAAIAQiYHQBDbAMCBAoAFAAIAQiYHQBDbAMCBAoAAA==.',['�']='独角兽丶:AwAECAQABRQAAA==.',['�']='玛尔斯:AwABCAEABRQAAA==.',['�']='琉璃嫣:AwAICAgABAoAAA==.',['�']='番天圣印:AwACCAMABAoAAA==.',['�']='疯子妞:AwAECAgABAoAAA==.',['�']='白露为霜:AwAECAQABAoAAA==.',['�']='皮卡丘:AwAECAYABRQDFgAEAQiBBwA2AuYABRQAFgAEAQiBBwA2AuYABRQAAQACAQgtIgANQnQABRQAAQQAAAAGCAQABRQ=.',['�']='真圣魔之血:AwAHCAEABAoAAA==.真特么红:AwAECAQABRQAAA==.',['�']='神灬僧:AwAHCAoABAoAAA==.',['�']='福禄祥瑞:AwAECAQABRQAAA==.',['�']='箜桑:AwAICAgABAoAAA==.',['�']='米哆拉维奇:AwAICAgABAoAAA==.',['�']='索拉灬达尔:AwAGCAcABAoAAA==.',['�']='红色的草丛:AwABCAEABRQDAwAIAQhdFwA80egBBAoAAwAIAQhdFwA6iOgBBAoAEAAGAQhtdQAzLy0BBAoAAA==.红酒烩鸡灬:AwAECAQABRQAAA==.',['�']='缺德麼:AwABCAEABAoAAA==.',['�']='義成:AwABCAEABAoAAA==.',['�']='老冒逼:AwAICAgABAoAAA==.老登儿:AwACCAUABRQCBQACAQhdGQAzSpoABRQABQACAQhdGQAzSpoABRQAAA==.',['�']='聆夜:AwADCAEABAoAAA==.',['�']='肉包肉:AwAECAQABRQAAA==.肉弹冲击:AwAGCAYABAoAAA==.肖自在:AwAGCAQABRQAAA==.肯定要带个德:AwAGCA8ABAoAAQIAWAsCCAIABRQ=.',['�']='胖达就是萌:AwAECAQABAoAAA==.',['�']='臀抽筋:AwAICAgABRQCAgAEAQgfCABROCcBBRQAAgAEAQgfCABROCcBBRQAAA==.自由骑士:AwAHCAIABAoAAA==.',['�']='艺霏爸爸:AwAECAQABRQCFwAEAQijBgAyo/QABRQAFwAEAQijBgAyo/QABRQAAA==.艾瑞丽娅:AwAICBYABAoCAgAIAQjxLgBRb08CBAoAAgAIAQjxLgBRb08CBAoAAA==.',['�']='芥末伪奶茶:AwABCAEABRQAAA==.花妞:AwAFCAUABAoAAA==.花式抖腿季军:AwAECAcABAoAAA==.',['�']='茜慕:AwACCAIABAoAAA==.',['�']='荧惑丶:AwADCAMABAoAAA==.',['�']='萌量不足:AwACCAIABAoAAA==.萝卜乐思:AwAECAgABRQCAwAEAQimAgBW6CYBBRQAAwAEAQimAgBW6CYBBRQAARAATx0GCAYABRQ=.',['�']='蝴蝶泉:AwAECAQABAoAAA==.蝶殇随云:AwABCAIABRQAAA==.',['�']='血之光荣:AwAICAgABAoAAQQAAAAGCAIABRQ=.血煞之雨:AwAICAgABAoAAA==.血色妖瞳:AwAFCAUABAoAAA==.',['�']='訷吖:AwAFCAYABAoAAA==.訷话:AwAHCAcABAoAAA==.',['�']='诗尾鱼:AwAGCAYABAoAAA==.',['�']='谁不会二段跳:AwAICAwABAoAAA==.',['�']='赛文先生:AwAECAMABRQAAA==.走过的回忆:AwAFCAUABAoAAA==.',['�']='越菜越爱玩:AwAICAgABAoAAA==.',['�']='辻一:AwAECAQABAoAAA==.达啦然小霸王:AwAICAgABAoAAA==.',['�']='迟薪不该:AwAECAUABAoAAA==.迷迷离:AwAICAgABAoAAA==.',['�']='遐蝶:AwAECAQABRQAAA==.遥夜闲信步:AwAECAQABAoAAA==.',['�']='邪能紫薯:AwAECAEABRQAAA==.',['�']='野人新之助:AwABCAEABRQAAA==.',['�']='铁臂阿童木丶:AwAFCAIABAoAAA==.铁血炽炎:AwAECAQABRQAAA==.',['�']='锦衣卫丶小北:AwACCAIABAoAAA==.',['�']='長風:AwAECAQABRQAAA==.',['�']='闪电赛文:AwAFCAQABAoAAA==.',['�']='阿尔托丽娅:AwAICBAABAoAAA==.阿斯特莱亚:AwAFCAYABAoAAQQAAAAECAQABRQ=.阿斯特莱娅:AwAICBQABAoDBQAIAQgOJgBNwf8BBAoABQAIAQgOJgBNwf8BBAoAEQACAQiaXAADiikABAoAAQQAAAAECAQABRQ=.',['�']='陈荟宇:AwADCAQABAoAAA==.',['�']='随风流逝的心:AwADCAMABAoAAA==.随风流逝的爱:AwAGCAYABAoAAA==.',['�']='雪染樱:AwAECAQABRQAAA==.',['�']='霜骨逝炎:AwACCAIABAoAAA==.',['�']='靌呗吖頭:AwAICAgABAoAAA==.',['�']='项王:AwAECAQABRQAAA==.',['�']='风中密码:AwACCAIABAoAAA==.风骚小武:AwAHCAcABAoAAA==.',['�']='鲨鱼丶辣椒:AwAECAkABAoAAQIAWAsCCAIABRQ=.',['�']='鸡你太煤:AwABCAEABAoAAA==.',['�']='鹅可鹅非常鹅:AwAICAgABAoAAA==.',['�']='麻辣香猪:AwAGCAEABRQAAA==.',['�']='黑山老妖精:AwAICAwABAoAAA==.黑旗:AwAGCAQABRQAAA==.',['�']='龍鸣:AwAGCAIABRQAAA==.龙骑士:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end