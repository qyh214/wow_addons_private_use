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
 local lookup = {'Monk-Mistweaver','Shaman-Enhancement','Priest-Discipline','Priest-Shadow','Unknown-Unknown','Mage-Fire','Mage-Frost','DeathKnight-Unholy','Paladin-Retribution','Paladin-Protection','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Hunter-BeastMastery','Priest-Holy','Monk-Windwalker','Warrior-Arms','DemonHunter-Havoc','Warrior-Fury','Evoker-Devastation','Evoker-Preservation','Druid-Balance','Warlock-Destruction','Druid-Restoration','Warlock-Affliction','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood',}; local provider = {region='CN',realm='萨尔',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ar='Arcanemage:AwAICAwABAoAAA==.Arianrhod:AwACCAIABRQAAA==.',Bu='Buckleoflove:AwAECAQABRQAAA==.',Ca='Callmeshen:AwACCAQABRQAAA==.',Ch='Chihiro:AwAECAQABRQAAA==.',Co='Conber:AwABCAMABAoAAA==.',De='Deanerys:AwABCAEABRQAAA==.Destinyfate:AwAECAQABAoAAA==.',Dr='Drablo:AwACCAIABRQAAA==.',Fr='Freedem:AwAICAgABAoAAA==.',Ig='Ignisfatuus:AwAGCAsABAoAAA==.',Le='Legendever:AwAICAYABAoAAA==.Lemonade:AwAFCAgABAoAAA==.',Lo='Loctar:AwABCAEABAoAAA==.',Lu='Lucrezia:AwAGCAYABAoAAA==.',Ma='Maaser:AwAFCAUABAoAAA==.',Ms='Msmu:AwACCAIABAoAAA==.',Mu='Mulagir:AwADCAMABAoAAA==.',My='Myprotein:AwABCAIABRQCAQAIAQhaCwBPtoYCBAoAAQAIAQhaCwBPtoYCBAoAAA==.',No='Nokmethod:AwACCAIABAoAAA==.',Ny='Nympholepsy:AwAGCAYABRQCAgAGAQhvAQAga6UBBRQAAgAGAQhvAQAga6UBBRQAAA==.',Se='Selsa:AwAGCAgABRQDAwAGAQiQAwAq1TwBBRQAAwAFAQiQAwAkvDwBBRQABAADAQh6CAAu7gYBBRQAAA==.Seths:AwAICAgABAoAAQUAAAAICAQABRQ=.',St='Stepsofdeath:AwAECAkABRQDBgAEAQj+EQBHS/YABRQABgAEAQj+EQBHS/YABRQABwABAQg0FQAuHE8ABRQAAA==.',Su='Sundro:AwAECAYABAoAAA==.',Ta='Taicifly:AwAICAgABAoAAA==.',Tt='Ttmacover:AwAGCAYABAoAAA==.',Va='Vankouver:AwAICAgABAoAAA==.',Ve='Veel:AwAECAQABRQAAA==.Verra:AwACCAIABRQAAA==.',Za='Zaza:AwADCAMABAoAAA==.',['�']='一碗白稀饭:AwAFCAQABAoAAA==.七心海棠乀:AwAECAgABRQDBwAEAQh2AwBTohMBBRQABwAEAQh2AwBIZBMBBRQABgAEAQimFgA6VucABRQAAA==.七柒丨黑瞳:AwAECAQABRQAAA==.不屈的战魂:AwADCAQABAoAAA==.丨烟灰:AwABCAEABAoAAA==.临晨:AwAICAgABAoAAA==.丶幸运之星:AwAECAQABRQAAA==.丶我来瞧瞧看:AwAHCAEABAoAAA==.丶矜然:AwAICAEABAoAAA==.丶荭水:AwAICBYABAoCCAAIAQgVBwBeYtgCBAoACAAIAQgVBwBeYtgCBAoAAQUAAAAHCAQABRQ=.丶贪欲之罪:AwAICAgABAoAAA==.丶钢蛋:AwACCAIABRQAAA==.',['�']='亚德瑞斯:AwAICBkABAoDCQAIAQhWOwBMNCQCBAoACQAIAQhWOwBMNCQCBAoACgABAQj7UQAsnzYABAoAAA==.亮丨剑:AwAICAgABAoAAA==.',['�']='仰手接飞猱:AwACCAIABRQAAQsAVU4DCAQABRQ=.',['�']='伊利单达雷:AwAHCAEABAoAAA==.会跳舞的中指:AwAGCAYABAoAAA==.',['�']='信仰之星:AwAHCAYABAoAAQYARVcCCAYABRQ=.',['�']='儒此多交:AwAICAYABAoAAA==.',['�']='克莱汤普森:AwAGCAIABAoAAA==.兽也有人:AwADCAMABAoAAA==.',['�']='冉冰:AwACCAIABAoAAA==.册那侬覅跑:AwAECAgABRQDDAAEAQhlBgBBUfEABRQADAAEAQhlBgBBUfEABRQADQAEAQiFEQAXFdIABRQAAA==.冰雪归尘:AwAFCAUABAoAAA==.冰雪暴风:AwAICAgABAoAAA==.',['�']='凤翼天翔丶:AwAICA4ABAoAAA==.',['�']='刘经理丶:AwAICAgABAoAAA==.初醒:AwAHCAcABAoAAA==.别奶丶:AwAECAMABRQAAA==.刺客五六七:AwAECAQABRQAAA==.刺杀:AwACCAIABRQAAA==.',['�']='加尔地獄咆哮:AwAGCAYABAoAAA==.',['�']='北调八觉:AwAHCA8ABAoAAA==.',['�']='华中农业大学:AwABCAEABRQAAA==.',['�']='呆猫九:AwAHCAcABAoAAA==.呉彦祖:AwAGCAoABAoAAA==.',['�']='哈噜噜:AwAICAgABAoAAA==.哗黎的:AwAECAQABRQAAA==.',['�']='嗜血妖怪:AwAECAQABRQAAA==.嗨森大魔王:AwAGCAUABAoAAA==.',['�']='嘿撩撩啰:AwAECAQABRQAAQUAAAAICAQABRQ=.嘿糗嘿糗:AwAECAYABAoAAA==.',['�']='噗噗狼:AwAGCAYABAoAAQUAAAAICAYABAo=.噗噗猫:AwAICAYABAoAAA==.',['�']='四驱崽翀翀冲:AwAGCAYABRQCAQAGAQj6AgAY03kBBRQAAQAGAQj6AgAY03kBBRQAAA==.囡囚囨囚囨図:AwAECAkABRQDCwAEAQiiCABDmOoABRQACwAEAQiiCABA+OoABRQADgAEAQhjFwAsieUABRQAAQ4AShkGCA4ABRQ=.',['�']='土地公:AwADCAIABAoAAA==.圣光伊瑞尔:AwAECAQABRQAAA==.地牌面分:AwACCAIABAoAAA==.',['�']='埃列什基伽勒:AwAICAgABAoAAA==.',['�']='壹个大汉儿:AwACCAIABRQAAA==.壹慕倾心:AwAGCAMABAoAAQMAMX0HCA0ABRQ=.',['�']='夜丶小喵:AwACCAQABRQAAA==.夜刀神沙耶:AwAICAEABAoAAA==.夜难眠:AwAHCAMABAoAAQUAAAAICAQABRQ=.大气:AwACCAIABRQAAA==.大花狸丶:AwAECAQABRQAAQ8ANuIECAQABRQ=.大花龙丶:AwAECAQABRQEDwAIAQhsHgA24scBBAoADwAIAQhsHgA24scBBAoAAwADAQiSZgAOtG8ABAoABAABAQiZYwA6+UQABAoAAA==.大酋长阿山:AwAFCAMABRQAARAAIjQHCAkABRQ=.大领主弗丁:AwAECAQABRQAAA==.大鹏鹏:AwACCAIABRQAAA==.天丶启:AwAECAQABAoAAA==.天菜又爱玩:AwADCAMABAoAAA==.太聪明的猪:AwAFCAUABAoAAA==.头鐡:AwAICAgABAoAAA==.夿倒烫:AwAECAQABRQAAA==.',['�']='威猛的小老虎:AwABCAEABAoAAA==.',['�']='孩子她爹:AwAFCAkABAoAAA==.',['�']='安宁大王:AwAICBUABAoCEQAIAQjBCABYmnYCBAoAEQAIAQjBCABYmnYCBAoAAA==.宝宝肚肚打雷:AwACCAQABRQAAA==.',['�']='寂寞保健德:AwACCAIABRQAAA==.寂寞保健柠:AwAICBgABAoCCQAIAQgRNwBH/DMCBAoACQAIAQgRNwBH/DMCBAoAAA==.寂寞保健狸:AwACCAIABRQAAA==.富贵福:AwACCAIABRQAAA==.',['�']='将丿臣:AwAECAIABRQAAA==.小公主玥伊:AwAGCAYABAoAAA==.小凉:AwAECAIABRQAAA==.小姨妈凋零:AwAICAoABAoAAA==.小笨蛋三号:AwADCAYABRQCDQADAQhKDQAwx+YABRQADQADAQhKDQAwx+YABRQAAA==.小米多多宝:AwAGCAYABAoAAA==.小红灵巾:AwAECAQABRQAAA==.小羊失绵了:AwAGCAgABAoAAA==.小腹黑:AwABCAIABRQCCQAIAQgaRwBEKAECBAoACQAIAQgaRwBEKAECBAoAAA==.小芳猪:AwAGCAcABRQCDAAEAQjjCgAlfLsABRQADAAEAQjjCgAlfLsABRQAAA==.小魔籹:AwACCAEABAoAAA==.尤迪丶安:AwAECAMABRQAAA==.尾行的兔大爷:AwAHCAcABAoAAQoASbAGCAYABRQ=.',['�']='山下之王:AwAICAgABAoAAREAIZ4GCAoABRQ=.',['�']='崩跑吧兄弟:AwACCAQABRQAAA==.',['�']='带盾的牛牛:AwABCAEABAoAAA==.常山赵子牛:AwAICAIABRQAAA==.',['�']='平天大聖:AwAECAQABRQAAA==.平安:AwAICA4ABAoAARIARtoICAYABRQ=.',['�']='异型汹猛:AwAICAgABAoAARMAMosICAkABRQ=.式微丶:AwAECAQABRQAAA==.',['�']='微风的响声:AwABCAEABAoAAA==.德安吉洛拉塞:AwAICAgABAoAAA==.',['�']='心情愉悦:AwAECAQABRQAAA==.',['�']='怀中把妹杀:AwAECAQABRQAAA==.性感母蟑螂:AwAECAQABRQAAA==.性灬感的母牛:AwABCAEABRQAAA==.',['�']='恰雷姆:AwAICAIABAoAAA==.',['�']='悍匪李二小:AwACCAIABAoAAA==.悠悠星辰:AwAECAgABRQCDgAEAQiECgBY8xsBBRQADgAEAQiECgBY8xsBBRQAAA==.',['�']='慧眼识猪:AwAFCAcABAoAAA==.',['�']='懂王川:AwADCAYABAoAAA==.懒懒的阿水:AwACCAIABRQDFAAIAQhwIQAl5YEBBAoAFAAIAQhwIQAl5YEBBAoAFQACAQg5GQBWEK4ABAoAAA==.',['�']='我好焦灼:AwAHCA0ABAoAAA==.我来组成裆部:AwAICAkABAoAAA==.我的小熊呢:AwADCAMABRQAAA==.我等你们打:AwAICAgABAoAAA==.戒烟如见你:AwAGCAUABAoAAA==.战地记者:AwAICAgABAoAAA==.',['�']='执著:AwAGCAYABAoAAA==.',['�']='拉个面:AwAECAEABRQAAA==.拉鲁拉丝:AwAFCAkABAoAAA==.',['�']='挽歌不吃葱花:AwACCAIABRQAAA==.',['�']='提拉米苏布丁:AwAECAMABRQAAA==.',['�']='文小宝:AwAFCAUABAoAAA==.斗鱼铁人阿瑞:AwACCAQABAoAAA==.',['�']='旧厂街卖鱼强:AwAGCAYABAoAAA==.时间萧瑟:AwAICAEABAoAAA==.',['�']='易琴宸妤:AwAICAgABAoAAA==.',['�']='晚丶:AwABCAEABRQAAA==.',['�']='曜之阑:AwACCAUABRQCCQACAQgsJwBDgqcABRQACQACAQgsJwBDgqcABRQAAA==.曾经的骨头:AwACCAIABAoAAA==.',['�']='會所在逃公主:AwAICAgABAoAAA==.月灵皎:AwAICBQABAoCEwAIAQjoEABLVm8CBAoAEwAIAQjoEABLVm8CBAoAAA==.木头咕噜:AwAICAIABAoAAA==.木林森林木:AwAECAQABRQAAA==.',['�']='杀气:AwAECAQABAoAAA==.李妙笙:AwAGCAYABAoAAA==.杰克老师:AwAHCA4ABAoAAA==.',['�']='林一:AwAGCAcABAoAAA==.',['�']='柔弱男妻:AwAECAQABRQAAA==.',['�']='栗熊:AwAICCUABAoCBwAIAQiACwBXLpUCBAoABwAIAQiACwBXLpUCBAoAAA==.',['�']='梦中牛:AwAECAQABRQAAA==.',['�']='槑槑:AwAGCAYABRQCFgAGAQhUAABQ8gkCBRQAFgAGAQhUAABQ8gkCBRQAAA==.',['�']='橙色汽水:AwAICBIABAoAAA==.',['�']='次个梨吧:AwAECAIABAoAAA==.欧皇忻奕:AwAICAMABAoAAA==.',['�']='求真务实:AwACCAIABAoAAA==.江江超可爱:AwAICBAABAoAAA==.江江超爱笑:AwAECAQABRQAAA==.',['�']='没毛病找我:AwAECAEABAoAAA==.',['�']='游侠枫:AwAECAEABAoAAA==.',['�']='溜了个溜:AwAECAQABRQAAA==.',['�']='满天星不如你:AwAECAoABRQDCwAEAQh6AwBL5RkBBRQACwAEAQh6AwBHzxkBBRQADgAEAQgrEwBEz/UABRQAAA==.',['�']='灬荭丶丨:AwAECAUABAoAAA==.灰叶丶地泽:AwAICAUABAoAAA==.灰烬弑者:AwAECAQABAoAAA==.',['�']='烟在指尖缠绕:AwADCAUABAoAAA==.烟在指尖飞舞:AwAGCAcABAoAAA==.烧烤要加糖:AwAGCAYABAoAAA==.烧烤要加葱:AwAECAQABAoAAA==.烧肉:AwAHCAkABAoAAA==.热心街坊:AwAECAQABRQAAA==.',['�']='爱是永恒毁灭:AwADCAgABRQCFwADAQjXCABA0QEBBRQAFwADAQjXCABA0QEBBRQAAA==.爱莉希雅:AwAECAYABRQCCQAEAQhnDABWcxQBBRQACQAEAQhnDABWcxQBBRQAAA==.',['�']='牛哥牧:AwAECAQABRQAAA==.牛杂粉:AwAICA8ABAoAAA==.特仑灬苏:AwAICAgABAoAAA==.',['�']='王鹏飞:AwACCAIABRQAAA==.',['�']='百里爱:AwABCAEABRQAAA==.百鬼夜泣:AwAICAgABAoAAA==.',['�']='破剑苍穹:AwAGCAYABRQCEQAGAQiWAAA4W8gBBRQAEQAGAQiWAAA4W8gBBRQAAA==.破晓流砂:AwAECAQABRQAAA==.',['�']='祈荒:AwAICA4ABAoAAA==.神奇小龙人:AwAGCAQABAoAAA==.',['�']='移动钱庄:AwAGCAYABAoAAA==.',['�']='空心菜:AwAICAgABAoAAA==.',['�']='站我后面:AwAECAQABRQAAA==.',['�']='米浴:AwAICBIABAoAAA==.',['�']='精锐武进士丶:AwACCAIABAoAAA==.',['�']='紫微北极大帝:AwAICA4ABAoAAA==.',['�']='緈諨約锭:AwAICAEABAoAAA==.',['�']='绯雪纤夜:AwABCAEABRQAAQUAAAAICAIABRQ=.',['�']='缘丁于此:AwAFCAUABAoAAA==.缝衣之针:AwABCAEABAoAAA==.缱绻在眉梢丶:AwAECAgABRQCEAAEAQhiCgAlI9wABRQAEAAEAQhiCgAlI9wABRQAAQUAAAAGCAQABRQ=.',['�']='美女娇娇:AwABCAEABRQAAA==.羽涅丶:AwAICAwABAoAAA==.',['�']='老牛奶弃圣光:AwAGCAYABAoAAA==.',['�']='聖天訫夢:AwAECAQABRQAAA==.',['�']='肥熊萨萨安:AwAGCAQABRQAAA==.肮脏的果冻:AwAICAgABAoAAA==.',['�']='脆皮炸鸡丶:AwAGCBYABRQDGAAGAQidAAA91MIBBRQAGAAGAQidAAA91MIBBRQAFgAEAQgoCwBRtgIBBRQAAA==.',['�']='自在:AwAFCAMABAoAAA==.',['�']='與烟:AwABCAEABAoAAA==.',['�']='苏斐亚风语:AwAICAgABAoAAA==.',['�']='荒野大酋长:AwAICAEABAoAAA==.',['�']='莫默默:AwAECAQABAoAAA==.',['�']='萧先生丶:AwAECAIABRQAAA==.落落屋顶:AwAECAQABAoAAA==.',['�']='蓝色旗旗:AwABCAEABRQAAA==.',['�']='薯条:AwAFCAUABAoAAA==.',['�']='蚂蚁虫子:AwAECAQABRQAAA==.',['�']='蛊惑魅影:AwABCAIABRQAAA==.蛋黄酱:AwAECAQABRQAAQUAAAAFCAQABRQ=.',['�']='血之风猎:AwADCAQABAoAAA==.血影萌德:AwAECAQABRQCFgAIAQhISQArU2cBBAoAFgAIAQhISQArU2cBBAoAAA==.血腥杀戮:AwAECAQABRQAAA==.術曉羽:AwAECAQABRQAAA==.',['�']='被遗忘的风:AwAECAgABRQDGQAEAQhGBABFkQcBBRQAGQAEAQhGBABFkQcBBRQAFwAEAQiYFQAX568ABRQAAA==.',['�']='親亲的:AwAECAMABAoAAQYARVcCCAYABRQ=.',['�']='訫無杂捻:AwACCAYABRQCBgACAQiuIgBFV6gABRQABgACAQiuIgBFV6gABRQAAA==.',['�']='诺娃:AwAGCAYABAoAAA==.读书不顺:AwADCAMABAoAAA==.',['�']='谪仙乀:AwACCAIABAoAAA==.',['�']='豌豆尖:AwAICBEABAoAAA==.豪情天纵:AwABCAEABAoAAA==.',['�']='贰舅妈:AwAECAQABRQAAA==.贼中贼:AwABCAEABAoAAA==.贼蠢萌:AwAGCBAABRQDGgAGAQhFAABSdQECBRQAGgAGAQhFAABSdQECBRQAGwAEAQgRCQAbgM8ABRQAAA==.',['�']='赤偶:AwADCAEABAoAAA==.',['�']='路易斯一斩杀:AwACCAIABAoAAA==.路边的鱼:AwAHCAsABAoAAA==.',['�']='輝耀:AwAICAIABRQAAA==.',['�']='轻松槑槑:AwAECAMABAoAAA==.',['�']='辛诺斯:AwAGCAgABAoAAA==.',['�']='迷宫饭:AwAECAkABRQCAgAEAQhTBABSeSMBBRQAAgAEAQhTBABSeSMBBRQAAA==.',['�']='遮不住的低调:AwAECAsABRQDFgAEAQhVDAA7w/wABRQAFgAEAQhVDAA7w/wABRQAGAACAQj0FgAPR2AABRQAAA==.',['�']='那个邪迪凯:AwACCAIABRQAAA==.邪恶双马尾:AwAFCAYABRQCFgADAQhzDQA/yPcABRQAFgADAQhzDQA/yPcABRQAAA==.',['�']='郭成卿:AwAECAQABRQAAA==.',['�']='酒仙百哲:AwAECAQABAoAAA==.酒伴桃花乀:AwAECAQABRQAAA==.酷乐圣魂:AwAECAIABRQAAA==.',['�']='重临:AwAICAgABAoAAA==.',['�']='銮銮:AwAGCAYABRQCDgAGAQhQAQBFstQBBRQADgAGAQhQAQBFstQBBRQAAA==.',['�']='钢丝:AwADCAMABAoAAA==.钢板碎橙子:AwACCAMABRQCCQAIAQi7SwA5OPQBBAoACQAIAQi7SwA5OPQBBAoAAA==.钢珠儿:AwAGCAYABAoAAA==.钢蛋灬:AwAGCAYABRQCHAAGAQjGBwALT/YABRQAHAAGAQjGBwALT/YABRQAAA==.',['�']='铁血十字:AwAICAUABAoAAA==.铁血沙场:AwAGCAIABAoAAA==.铃仙优昙华院:AwAECAQABRQAAA==.',['�']='长谷川泰三:AwAICAgABAoAAA==.',['�']='阿卜杜拉:AwAICA0ABAoAAA==.阿咩丶:AwAICA4ABAoAAQ8ANuIECAQABRQ=.阿瓦隆的守护:AwAGCAYABAoAAA==.',['�']='隔壁的海猴:AwAECAQABRQAAA==.',['�']='音挪:AwAECAQABRQAAA==.韵欣:AwACCAIABRQAAA==.',['�']='风语小贝:AwACCAIABAoAAA==.飞羽:AwAICBAABAoAAA==.',['�']='高艾薇:AwACCAIABRQAAA==.',['�']='魅惑极光:AwAICAgABAoAAA==.魔心不凡:AwAICAIABAoAAA==.',['�']='齐天大圣:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end