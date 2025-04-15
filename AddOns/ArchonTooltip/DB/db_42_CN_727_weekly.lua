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
 local lookup = {'Shaman-Enhancement','Mage-Fire','Evoker-Devastation','Unknown-Unknown','DeathKnight-Unholy','Warrior-Fury','Monk-Windwalker','Priest-Shadow','Priest-Discipline','Priest-Holy','Paladin-Retribution','Paladin-Protection','Mage-Frost','Warrior-Arms','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','Evoker-Preservation','Evoker-Augmentation','DemonHunter-Vengeance','Warlock-Affliction','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','Rogue-Subtlety','Druid-Feral','Druid-Restoration','Rogue-Outlaw','Shaman-Restoration','Monk-Mistweaver','Druid-Balance','Paladin-Holy','DemonHunter-Havoc',}; local provider = {region='CN',realm='泰兰德',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ap='Aprious:AwACCAIABRQAAA==.',As='Aska:AwACCAMABRQCAQAHAQj6HQA9WbsBBAoAAQAHAQj6HQA9WbsBBAoAAQIAQ8QICAcABRQ=.',Ay='Ayuxd:AwAECAQABRQAAQMAQW4GCAgABRQ=.',Bi='Biglight:AwABCAEABRQAAA==.',Bl='Blassreiter:AwAECAEABRQAAQQAAAAECAQABRQ=.',Ch='Chloe:AwAECAQABRQAAA==.',Cj='Cjw:AwAECAQABRQAAA==.',Do='Donriver:AwACCAIABAoAAA==.',Du='Duskelegy:AwADCAgABRQCBQADAQiyEgBMdrIABRQABQADAQiyEgBMdrIABRQAAA==.',Ga='Garroshhell:AwACCAYABRQCBgACAQgDEwBHIrcABRQABgACAQgDEwBHIrcABRQAAA==.',Hc='Hchchch:AwAGCAQABRQAAA==.',He='Heidh:AwAGCAkABAoAAA==.',Jr='Jrs:AwADCAQABAoAAQQAAAAICAgABAo=.',Kn='Knc:AwADCAgABRQCBwADAQgkBABS/R8BBRQABwADAQgkBABS/R8BBRQAAA==.Knw:AwAECAQABAoAAA==.',Ko='Koh:AwAECA4ABRQECAAEAQgsDwAbscQABRQACAAEAQgsDwAbscQABRQACQACAQj+EgBMS5MABRQACgADAQiWEQAmfIMABRQAAA==.',La='Laogaifan:AwAGCAQABRQAAA==.',Lo='Loch:AwABCAEABRQAAA==.',Ma='Macroyan:AwABCAEABAoAAA==.Malicious:AwAECAQABRQAAA==.Matchabrowne:AwAECAQABRQDCwAIAQjKPABCSRYCBAoACwAIAQjKPABCSRYCBAoADAAIAQh8HAAlekgBBAoAAA==.',Mo='Mofasata:AwAICBEABAoAAA==.',Pi='Pipicc:AwAGCAoABAoAAA==.',Qu='Qui:AwAICA8ABAoAAA==.',Sa='Saye:AwAICAgABAoAAA==.',St='Stellaris:AwAECAgABRQDCQAEAQiTAgBe/UcBBRQACQAEAQiTAgBe/UcBBRQACAABAQg0HAAZTkwABRQAAA==.',Su='Suntony:AwAECAgABRQDDQAEAQgQAwBcthMBBRQADQAEAQgQAwBQ6BMBBRQAAgAEAQg4DAA/+AkBBRQAAA==.',Th='Thanossi:AwADCAoABRQDDgADAQhNBQBhgNoABRQABgACAQhoDwBh3eMABRQADgACAQhNBQBhr9oABRQAAA==.Thresh:AwACCAIABRQAAA==.',Ve='Vei:AwABCAEABAoAAA==.Vendettaes:AwAICBEABAoAAA==.',Vi='Vidar:AwADCAgABAoAAA==.',Wa='Wanrenonly:AwACCAIABAoAAA==.',Xi='Xiaodoudinbf:AwAICAgABAoAAA==.Xiaodoudinqs:AwAECAQABRQAAA==.',Zz='Zzpanda:AwAICAgABAoAAA==.Zzyisgood:AwAGCA4ABAoAAA==.',['�']='一十三:AwAECAEABRQDDwAIAQgJIgBK0uMBBAoADwAIAQgJIgBK0uMBBAoAEAABAQjFWABIKE4ABAoAAQQAAAAGCAQABRQ=.一半烟火:AwADCAMABAoAAA==.一只小鱼饼干:AwAGCAEABAoAAA==.一只椰子:AwAECAUABAoAAA==.一只阿梨梨:AwAFCAcABAoAAA==.一无:AwAGCAYABAoAAA==.七月核桃丶:AwAGCAIABRQAAA==.万钟涸嘉:AwAICBMABAoAAQoAXZQCCAMABRQ=.三途川渡鸦:AwABCAEABRQAAA==.上地:AwACCAIABAoAAA==.上城周润发:AwAECAQABRQAAA==.两把大砍刀:AwABCAEABRQAAA==.丨夜乄寒衣丨:AwAGCAQABRQAAA==.丶嘟着嘴的猪:AwAECAQABRQAAQQAAAAGCAQABRQ=.丿霄白:AwABCAMABRQCEQAIAQhzGwAwfIgBBAoAEQAIAQhzGwAwfIgBBAoAAA==.',['�']='九点就加钟:AwAFCAMABAoAAA==.习惯右手扣:AwAFCAUABAoAAA==.习惯左手扣:AwAHCAsABAoAAA==.',['�']='人生逆旅:AwADCAoABRQEAwADAQioDQAXprQABRQAAwADAQioDQAVGrQABRQAEgACAQiGBgAcEHAABRQAEwABAQirAAAx8EIABRQAAA==.亿笑倾城:AwAFCAIABAoAAA==.',['�']='他又掉线啦:AwACCAIABAoAAA==.',['�']='伊格尼斯丶:AwAECAQABRQAAA==.',['�']='何以为:AwADCAQABAoAAA==.',['�']='倒逆尘光:AwAICBYABAoCFAAIAQicCABRMWwCBAoAFAAIAQicCABRMWwCBAoAAA==.倾世无悔:AwABCAEABAoAAA==.',['�']='偌柳扶风:AwAICAIABAoAAA==.',['�']='光大锤:AwAICAgABAoAAA==.八丶九不离十:AwAICAgABAoAAA==.八舞夕矢:AwAECAQABRQAAA==.八重海:AwAGCAYABAoAAQQAAAACCAIABRQ=.六丿喰:AwADCAkABRQCAwADAQgyDQAW+bsABRQAAwADAQgyDQAW+bsABRQAAA==.',['�']='冰月十四:AwACCAIABRQAAQQAAAAECAQABRQ=.冲钅:AwABCAEABAoAAA==.',['�']='凝神花:AwAECAQABAoAARAANpIGCAwABRQ=.凡尘难渡:AwAECAQABAoAAA==.凯珊卓:AwACCAIABRQCFQACAQj5KgAqB4UABAoAFQACAQj5KgAqB4UABAoAAA==.',['�']='初代兔子:AwABCAEABRQAAA==.别控制:AwAGCBoABAoDAQAGAQhFOQAJftYABAoAAQAGAQhFOQAJftYABAoAFgABAQh9fAACfQoABAoAAA==.',['�']='剩僧丶:AwAECAQABAoAAA==.',['�']='加油小崔:AwAICAkABAoAAA==.',['�']='勇敢的迪凯:AwABCAEABAoAAA==.',['�']='北冥有鱼:AwACCAIABRQAAA==.北山有只橘猫:AwAICAgABAoAAA==.',['�']='博大:AwABCAEABAoAAA==.卡皮巴拉:AwAGCAoABAoAAA==.印花集:AwAFCAsABAoAAA==.卿殇:AwAICAgABAoAAA==.',['�']='去冰七分糖:AwAECAQABRQAAA==.',['�']='只会一键输出:AwAECAQABRQAAQQAAAAICAIABRQ=.',['�']='吉亦安:AwAECAQABRQDFwAIAQiqKwBSVyUCBAoAFwAIAQiqKwBGTSUCBAoAGAAIAQgRFgBRtukBBAoAAA==.吉薇乄艾尔:AwAICBgABAoDGQAIAQiqDABLzCcCBAoAGQAIAQiqDABGpScCBAoAGgAIAQiFDwA48e4BBAoAAA==.吴家之宝:AwAICAgABAoAAQgAS+0GCAYABRQ=.',['�']='呆呆村四把手:AwAICBMABAoAAA==.呆呆村熊男:AwABCAEABAoAAA==.呆汪蠢喵笨:AwACCAcABRQCDQACAQhfCgBHMqUABRQADQACAQhfCgBHMqUABRQAAA==.',['�']='咱刘姥姥:AwACCAIABRQAAA==.',['�']='哀伤之刃:AwAECAQABRQAAA==.哇袄:AwAHCAcABAoAAA==.哈吉斯恶:AwAGCAYABAoAAA==.',['�']='啥子不阔以:AwAGCAsABAoAAA==.',['�']='喵爪子挠挠:AwADCAUABRQCGwADAQjyAABOOSYBBRQAGwADAQjyAABOOSYBBRQAARwAOnwGCAYABRQ=.',['�']='嗷哟哟:AwADCAYABRQEGQADAQisBQBE2P4ABRQAGQADAQisBQBDFv4ABRQAGgABAQjeDQA4PFUABRQAHQABAQhvBABCU1QABRQAAA==.',['�']='嘉了个嘉:AwAECAIABRQAAA==.嘎嘎新:AwAECAEABAoAAA==.',['�']='回归的翡翠:AwAECA0ABRQCCwAEAQjVBgBSUCgBBRQACwAEAQjVBgBSUCgBBRQAAA==.国服亚瑟:AwAFCAUABAoAAA==.',['�']='圣光保佑你:AwABCAEABRQAAA==.圣大教主:AwACCAIABAoAAQQAAAAGCA4ABAo=.在乃了在奶了:AwADCAMABRQAAA==.地尅丶大摄王:AwABCAEABRQAAA==.',['�']='坏小孩是她:AwAECAYABRQCAgAEAQiwHAAWPMIABRQAAgAEAQiwHAAWPMIABRQAAA==.',['�']='垂眼入星辰:AwAECAMABAoAAA==.',['�']='墨色风车:AwAICBAABAoAAA==.墨隐丨未央:AwAGCAUABAoAAA==.',['�']='多喝热水:AwACCAIABAoAAA==.大君宝:AwAHCAcABAoAAA==.大地之骨:AwABCAEABAoAAA==.大耳喵神:AwACCAQABRQCBwAIAQjMDQBI72MCBAoABwAIAQjMDQBI72MCBAoAAA==.太叔绯:AwAECAgABRQCAgAEAQi0DwBJ/fgABRQAAgAEAQi0DwBJ/fgABRQAAQIAT1sHCAUABRQ=.夺命电吹风:AwACCAIABAoAAA==.',['�']='奥术冲击丶:AwAECAQABRQAAA==.奥术序曲:AwAGCAUABAoAAA==.奶又奶不动:AwABCAIABAoAAA==.',['�']='妈妈酱:AwACCAQABRQCHgAIAQjBCQBYxZYCBAoAHgAIAQjBCQBYxZYCBAoAAA==.',['�']='姚晓光:AwAICBUABAoCCwAIAQiKbAAtCZoBBAoACwAIAQiKbAAtCZoBBAoAAA==.姬野星奏:AwABCAEABRQAAA==.',['�']='寻找呀咩喋:AwADCAUABRQCBwADAQgFCwATWMQABRQABwADAQgFCwATWMQABRQAAA==.',['�']='小反射狐:AwAICAgABAoAAA==.小嘴儿抹了蜜:AwAECAQABAoAAA==.小天使狐:AwACCAIABAoAAA==.小熊仔子:AwACCAIABRQAAA==.小钢炮:AwAICA4ABAoAAA==.小闪电狐:AwAECAgABRQCAQAEAQiFBwA2FPsABRQAAQAEAQiFBwA2FPsABRQAAA==.少冰七分糖:AwAGCAQABRQAAA==.',['�']='崇宫丶澪:AwAFCAgABAoAAA==.',['�']='嵬嵬大魔王:AwABCAEABAoAAA==.',['�']='平凡的过往:AwAECAQABRQAAA==.幸福的小可爱:AwAECAQABRQAAQQAAAAICAQABRQ=.幻海同游:AwABCAEABRQAAA==.幽蓝梦魇:AwAICA0ABAoAAA==.幽默小黄人:AwADCAEABAoAAA==.',['�']='库兰德斯勋爵:AwAICBAABAoAAA==.',['�']='弃坑的王者:AwAICAgABAoAAA==.张大胖子:AwAICAgABAoAAA==.弥生花火:AwAICA4ABAoAAA==.弯角:AwAECAgABRQCBgAEAQgTDAAtx/sABRQABgAEAQgTDAAtx/sABRQAAA==.',['�']='彩虹慕斯:AwAICBQABAoDAgAIAQjuEABXy4UCBAoAAgAIAQjuEABXy4UCBAoADQADAQhFigAPslEABAoAAA==.',['�']='得意的很:AwAICAgABAoAAA==.御堂筋翔:AwAICAgABAoAAA==.',['�']='忏悔圣光:AwAGCAYABAoAAA==.',['�']='我将带头炉石:AwAECAQABRQAAR8AH94ICAoABRQ=.我就来搞事:AwACCAIABRQAAA==.',['�']='手滑一下死:AwAGCAMABAoAAA==.',['�']='拉面王:AwAICAQABAoAAA==.',['�']='指定不黑:AwACCAIABAoAAA==.挽美:AwAECAYABRQCIAAEAQjuBwBQKw8BBRQAIAAEAQjuBwBQKw8BBRQAASAAQiQGCAoABRQ=.',['�']='撒野米或:AwABCAEABRQAAA==.',['�']='文艺涛:AwAECAQABAoAAA==.',['�']='无悔丶圣:AwADCAQABRQAAA==.无赖男:AwAECAgABRQCBgAEAQjIDgAf8+kABRQABgAEAQjIDgAf8+kABRQAAA==.',['�']='昌平嫪毐:AwAECAIABRQAAA==.是一只阿鱼鸭:AwAFCAwABAoAAA==.是灰太狼:AwADCAIABRQDBQAIAQiuHgBEtyACBAoABQAIAQiuHgBEtyACBAoAEQAEAQiaSQAZrmkABAoAAA==.',['�']='月光下的后羿:AwACCAIABRQAAA==.朵朵酱:AwAECAEABRQAAA==.',['�']='林雨枫:AwACCAIABAoAAA==.枫林晚:AwABCAEABRQAAA==.',['�']='柒晔漓:AwADCAEABRQAAA==.柚子宁宁:AwAICAQABAoAAA==.',['�']='栖枝故梦:AwABCAEABRQAAA==.',['�']='欧瑞费尔:AwAECAQABRQAAA==.',['�']='死骑之神:AwAICAEABAoAAA==.',['�']='毛毛腿:AwAFCAcABAoAAA==.',['�']='法克汉姆:AwAGCAcABAoAAA==.波比灬:AwADCAMABRQAAA==.',['�']='流刃若芒:AwACCAMABRQAAA==.流炎:AwAICA4ABAoAARoAN70GCAkABRQ=.海的二女儿:AwAECAQABRQAAQIASekGCAwABRQ=.',['�']='消逝丶:AwABCAIABRQAAA==.',['�']='混沌女娲:AwAFCAUABAoAAA==.',['�']='清蒸还是红烧:AwAECAQABRQAAQQAAAAICAQABRQ=.清黎:AwAECAQABRQAAA==.',['�']='火红的小晴阳:AwAECAQABRQAAA==.灬局外人灬:AwAECAQABRQAAA==.灬波比灬:AwAECAQABRQAAA==.灭蝇师太:AwAFCAUABAoAAA==.',['�']='炙热的心殇:AwABCAEABAoAAA==.',['�']='焚天之刃:AwABCAEABRQAAA==.',['�']='爱吃芝士:AwADCAIABAoAAA==.',['�']='牛尼酱:AwABCAIABRQAAA==.',['�']='狐僧:AwAICAQABAoAAA==.独自旅行:AwAFCAkABAoAAA==.',['�']='玲娜贝尔:AwAICAgABAoAAA==.',['�']='界伊瑞尔:AwAICAoABAoAAA==.',['�']='疯狂的奶酪:AwABCAEABAoAAA==.',['�']='白白库:AwACCAMABRQAAA==.',['�']='盾爆:AwAECAQABRQAAA==.',['�']='瞧你那熊样:AwAGCAoABAoAAA==.',['�']='神圣干涉:AwAECAQABRQAAA==.神无月天狼星:AwABCAEABRQAAA==.神无月逐风者:AwACCAIABRQAAA==.',['�']='米纳斯伊希尔:AwAECAcABRQDCwAEAQgOHwAtY8EABRQACwADAQgOHwAtY8EABRQADAABAQgBFwAAAAAABRQAAA==.',['�']='紙鳶:AwAHCAcABAoAAA==.',['�']='红焖羊肉丨:AwACCAIABAoAAA==.红花会:AwAECAQABAoAAA==.纳什均衡:AwAICAgABAoAAA==.',['�']='绀野木棉季:AwACCAIABRQAAQQAAAAGCAIABRQ=.组我就不缺德:AwACCAIABRQAAA==.织田晨琳:AwACCAMABRQDCgAIAQiZAwBdlMMCBAoACgAIAQiZAwBaRsMCBAoACQAGAQhZFQBdGfYBBAoAAA==.维迪兹丶:AwAFCAEABAoAAA==.绿骑士:AwACCAIABRQAAA==.',['�']='羊驼君吖:AwABCAIABRQDCwAIAQgsTABTLOkBBAoACwAGAQgsTABf5ukBBAoAIQAFAQgTHABNx1ABBAoAAA==.',['�']='耳钉牧九:AwAECAQABRQAAA==.',['�']='肆魔:AwABCAEABRQAAA==.',['�']='花开富贵花:AwAECAQABRQAAA==.',['�']='若雪纷飞:AwAECAQABRQAAA==.',['�']='菲克休斯:AwACCAIABAoAAA==.',['�']='萌熊新猫:AwAECAUABRQCHwAEAQjmCgA24/AABRQAHwAEAQjmCgA24/AABRQAAA==.',['�']='蒙牛奶丶温婉:AwABCAEABAoAAA==.蒸羊羔:AwACCAMABAoAAA==.',['�']='西瓜茉莉茶:AwAGCBEABRQCHwAEAQglCwA36u4ABRQAHwAEAQglCwA36u4ABRQAAQQAAAAICAEABRQ=.',['�']='观星:AwAECAQABRQAAA==.觋夕莉:AwAGCAcABRQDGgAEAQhPCwAy05gABRQAGQADAQgODQA3XZkABRQAGgACAQhPCwAv5JgABRQAAA==.',['�']='让暧昧肆虐:AwABCAEABRQCGAAIAQjxBQBXeqkCBAoAGAAIAQjxBQBXeqkCBAoAAA==.',['�']='谢然然:AwAGCAUABAoAAA==.',['�']='豆豆的豆豆的:AwADCAMABAoAAA==.',['�']='赤色惑星:AwACCAQABRQAAA==.起名丨:AwAGCAoABAoAAA==.',['�']='超雄奶爸:AwAHCAIABAoAAA==.',['�']='跟你混了:AwACCAMABRQAAA==.',['�']='这专精混子多:AwAICAIABAoAAA==.',['�']='逃跑的一毛钱:AwAFCAUABAoAAA==.逝去的可丽:AwACCAQABRQAAA==.',['�']='遇兔随喜:AwACCAQABRQCCgAIAQg3OQAZbisBBAoACgAIAQg3OQAZbisBBAoAAA==.',['�']='那个老六:AwAECAQABRQAAA==.那年伊始:AwAECAQABRQAAA==.邪恶马铃薯:AwACCAIABAoAAA==.',['�']='郑大毛:AwAGCAsABRQDFwAGAQiRAABTw/wBBRQAFwAGAQiRAABTw/wBBRQAGAAEAQh3BABWvAYBBRQAAQQAAAAICAQABRQ=.',['�']='酒酿小元宵丶:AwAGCAYABRQCIgAGAQifAgAw84EBBRQAIgAGAQifAgAw84EBBRQAAA==.',['�']='銀色勺子:AwAICAgABAoAAA==.',['�']='铁蛋公主:AwADCAMABAoAAA==.',['�']='长祀祭:AwABCAEABRQDCAAIAQisMwAXcBcBBAoACAAHAQisMwAYJRcBBAoACQABAQiigAAU5CsABAoAAA==.',['�']='闪电牛牛丶:AwAECAQABRQAAA==.',['�']='阿利不背锅:AwAGCBMABAoAAA==.阿寶:AwADCAMABRQAAA==.',['�']='随轻风起舞:AwACCAQABRQDGAAIAQhpCgBUrmsCBAoAGAAIAQhpCgBRnmsCBAoAFwAGAQjJXABSAGsBBAoAAA==.',['�']='雾远:AwADCAEABAoAAA==.雾雨魔沙:AwAICAEABAoAAA==.',['�']='青丝绕橙戒:AwAECAIABRQAAA==.',['�']='风暴阴影:AwABCAMABRQAAA==.风铃一刀声:AwAECAQABRQAAA==.飞凡:AwADCAMABAoAAA==.飞去来兮:AwACCAEABAoAAA==.',['�']='饺子:AwAECAQABRQAAA==.',['�']='高圆圆:AwACCAMABRQAAA==.',['�']='魔法福音:AwAECAQABRQAAQIATgYGCAgABRQ=.魔鬼狠人:AwAGCAUABAoAAA==.',['�']='鲜奶:AwAECAYABRQDBQAEAQgsGAAnp5MABRQABQACAQgsGAA6ApMABRQAEQAEAQgzFQAHUG8ABRQAAA==.',['�']='鵺狩:AwABCAIABRQAAA==.',['�']='鹿咩咩:AwABCAQABRQCAgAIAQjNBwBcmMwCBAoAAgAIAQjNBwBcmMwCBAoAAA==.',['�']='麻辣仙人:AwAECAQABRQAAA==.',['�']='黎明之魘:AwAECAwABRQDIgAEAQhPEQApYOcABRQAIgAEAQhPEQApYOcABRQAFAACAQhpDgARMWIABRQAAA==.黎明必将到来:AwACCAMABRQAAA==.',['�']='龙霸灬天下:AwABCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end