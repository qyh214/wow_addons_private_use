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
 local lookup = {'DeathKnight-Unholy','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','DemonHunter-Havoc','Warrior-Fury','Mage-Frost','Mage-Fire','Druid-Guardian','Priest-Discipline','Paladin-Retribution','Druid-Restoration','Druid-Balance','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Rogue-Assassination','Evoker-Preservation','DeathKnight-Frost','Paladin-Protection','DeathKnight-Blood','Rogue-Outlaw','Warrior-Protection','Shaman-Enhancement','Priest-Shadow','Priest-Holy','Warlock-Affliction','Monk-Brewmaster','Shaman-Elemental',}; local provider = {region='CN',realm='亡语者',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arcana:AwACCAIABRQAAA==.',Bl='Bloodypurity:AwACCAMABRQCAQAIAQgqHQBIMyoCBAoAAQAIAQgqHQBIMyoCBAoAAA==.',Ce='Cecilharvey:AwAICAgABAoAAA==.',Ch='Chromie:AwAGCAUABAoAAQIAAAABCAIABRQ=.',Dc='Dcdcd:AwAFCAUABAoAAA==.',Do='Domage:AwABCAEABRQAAA==.',Ew='Ewanachilles:AwAGCAwABAoAAA==.',Fa='Fakeit:AwAECAQABRQAAA==.Fallinlove:AwAGCA4ABAoAAA==.',Ga='Galenmiao:AwABCAEABAoAAA==.',He='Herrington:AwABCAEABRQAAA==.Heymia:AwAGCAYABAoAAA==.',Ho='Hoodwink:AwAGCBgABRQDAwAGAQgCAABhTTMCBRQAAwAGAQgCAABhTTMCBRQABAAEAQiVCgBfVxQBBRQAAA==.',Ic='Icerage:AwAICAgABAoAAA==.',In='Invariably:AwAECAQABRQAAA==.',Ko='Koti:AwAECAQABRQAAA==.',Le='Leoj:AwAICAoABAoAAA==.Leslie:AwAICB8ABAoCBQAIAQguLAAy27IBBAoABQAIAQguLAAy27IBBAoAAA==.',Li='Littlelemon:AwAGCAcABRQCBgAGAQj/AAA9H9YBBRQABgAGAQj/AAA9H9YBBRQAAA==.',Mo='Mooncell:AwAFCAUABAoAAA==.',Pl='Playeriubcug:AwAICBAABAoAAA==.',Ro='Royle:AwAECA4ABRQCBwAEAQgrCQBADwoBBRQABwAEAQgrCQBADwoBBRQAAA==.Roylez:AwAECAoABRQDCAAEAQjjAQBdDSYBBRQACAAEAQjjAQBETiYBBRQACQAEAQirDQBJPwEBBRQAAA==.',Sh='Shael:AwAICAgABAoAAA==.',Ta='Taoist:AwACCAIABAoAAA==.',Vi='Virulent:AwAECAQABRQAAA==.',Vo='Voilack:AwABCAIABRQCCgAIAQiCAgBTYowCBAoACgAIAQiCAgBTYowCBAoAAA==.',Ya='Yatoro:AwAICAgABAoAAA==.',Ye='Yeshoney:AwACCAIABRQAAA==.',['�']='一介平民:AwABCAEABAoAAA==.一介毛衣:AwADCAMABRQAAA==.一切无视:AwAECAQABAoAAA==.一块米花团:AwAECAQABRQAAA==.一季的天光:AwACCAIABRQAAA==.一朵小花喵丶:AwAECAQABRQAAA==.一步禅空:AwAFCAUABAoAAA==.七分害怕:AwAECAQABAoAAA==.三月七:AwABCAEABAoAAA==.不乖小猫:AwAECAgABRQCCwAEAQi3CgAujN0ABRQACwAEAQi3CgAujN0ABRQAAA==.不是猫图芽:AwAICAoABAoAAQIAAAAICAEABRQ=.不洗都吃:AwABCAEABRQAAA==.不渡人间:AwAICAgABAoAAA==.与谁问春风:AwACCAIABRQAAA==.丨吴哼哼丨:AwABCAEABRQCDAAIAQiYJQBMu2oCBAoADAAIAQiYJQBMu2oCBAoAAA==.丨李丰甶丨:AwAICAYABAoAAA==.中野一花:AwAECAQABRQAAA==.丶岁月流逝:AwAGCAUABAoAAA==.丶歲月流失:AwABCAIABRQAAA==.丽贝卡:AwAGCAQABRQAAA==.丿星期六丶:AwAECAQABRQAAA==.丿炫月丶筱静:AwACCAIABRQAAA==.',['�']='乱小乐:AwACCAIABRQAAA==.',['�']='伊凝檬:AwABCAIABRQAAA==.伍十个圣柒:AwAECAMABRQAAQEAPpAGCAgABRQ=.伍十个小德:AwAICAgABAoAAA==.',['�']='你又掉线了:AwAECAQABRQCBwAEAQgmEAAX4dkABRQABwAEAQgmEAAX4dkABRQAAA==.',['�']='修远碧玉:AwABCAIABRQAAA==.',['�']='光暗之影:AwAGCAkABAoAAA==.八月好时节:AwAICAwABAoAAA==.六色斑斓:AwACCAYABRQDDQACAQjAEQAgPXcABRQADQACAQjAEQAgPXcABRQADgABAQg4LwAEZCwABRQAAA==.',['�']='冲锋十万次:AwABCAEABRQAAA==.冷月丶葬魂:AwAGCAoABAoAAA==.',['�']='凯尔丨萨思:AwAECAQABRQAAA==.凸一一凸:AwABCAEABRQAAA==.凸二凸:AwACCAMABRQAAA==.',['�']='剪身成蝶丶:AwACCAIABRQAAQkARzEGCAkABRQ=.',['�']='北林孔工:AwAGCAUABAoAAA==.',['�']='半生皆醉:AwADCAMABAoAAA==.',['�']='叮叮:AwAECAYABRQCBgAEAQjFDwAzV+4ABRQABgAEAQjFDwAzV+4ABRQAAA==.',['�']='吃我中锤锤:AwAHCBUABAoCDAAHAQi7NwBPdCYCBAoADAAHAQi7NwBPdCYCBAoAAA==.',['�']='呆呆家的童话:AwAICAYABAoAAA==.',['�']='咕哒哒:AwAECAQABRQAAA==.',['�']='哈吉猪咪:AwABCAEABRQAAA==.哥兜里有火:AwAECAQABAoAAA==.',['�']='回嫌体正直:AwABCAIABRQAAA==.',['�']='圣光砰砰你:AwAICAoABAoAAA==.圣光赦令:AwAICAgABAoAAA==.圣骑熊熊:AwAECAQABRQAAA==.在下对不准:AwACCAIABAoAAA==.地爆天星:AwACCAQABRQDDwAIAQijIwBT4NkBBAoADwAGAQijIwBWXtkBBAoAEAADAQjXLQBMJekABAoAAA==.',['�']='堀京子:AwAICAgABAoAAA==.',['�']='墩儿:AwAFCA4ABAoAAQIAAAAECAQABRQ=.',['�']='夜泊夜泊荒唐:AwABCAEABRQAAA==.夜萧瑟:AwAICAgABAoAAA==.大庸少帅:AwABCAEABRQAAA==.失去等待:AwAGCAYABAoAAA==.',['�']='好想告诉妳:AwACCAQABRQCCQAIAQhEJABM/gsCBAoACQAIAQhEJABM/gsCBAoAAA==.',['�']='如約而至:AwAHCAcABAoAAA==.',['�']='孔雀大神:AwAECAQABRQAAA==.',['�']='宝拉:AwABCAEABAoAAA==.',['�']='小红雨:AwAICAgABAoAAA==.尘封恋影:AwAECAsABAoAAQIAAAAICAgABAo=.尘封旧事:AwAICAgABAoAAA==.',['�']='山樱吹雪:AwAICBIABAoAAA==.',['�']='弱水妄谈禅:AwAICAIABRQCEQACAQi0GgArWIQABRQAEQACAQi0GgArWIQABRQAAA==.强无敌:AwAICAgABAoAAA==.',['�']='微雨悠悠:AwAHCBoABAoCCAAHAQhbFQBTAjMCBAoACAAHAQhbFQBTAjMCBAoAAA==.德心应手:AwABCAEABRQDDgAHAQgzQAA5uoABBAoADgAGAQgzQABAnYABBAoACgABAQjiKAAXTiYABAoAAA==.',['�']='心流:AwAECAQABRQAAA==.心流丿:AwABCAEABRQAAQIAAAAGCAIABRQ=.心渊魔角:AwABCAEABRQAAA==.快冲锋二师长:AwAICAkABAoAAA==.',['�']='恐怖的小锅巴:AwAECAgABRQCBwAEAQhrDwAZJeMABRQABwAEAQhrDwAZJeMABRQAAA==.恨她:AwAECAQABRQAAA==.',['�']='悠云邪恶:AwADCAIABRQAAQIAAAAGCAQABRQ=.',['�']='情人箭:AwABCAEABRQAAA==.想不出办法:AwABCAQABRQAARIAYmYFCBEABRQ=.',['�']='懒画眉:AwABCAEABRQAAA==.',['�']='我法术位呢:AwAICA4ABAoAAA==.我要砍你的头:AwAECAQABRQAAA==.戮君:AwAGCAwABAoAAA==.',['�']='故渊:AwAGCAQABRQAAA==.散修圣骑:AwAHCA8ABAoAAA==.',['�']='斩丶一刀切:AwAICAcABAoAAA==.斩蛇穿屋:AwAGCAcABAoAAQIAAAAICA4ABAo=.',['�']='无名是也:AwAHCAIABAoAAA==.无解丶熊孩子:AwAECAUABRQCBAAEAQgtFgAqd+AABRQABAAEAQgtFgAqd+AABRQAAA==.日天日地日人:AwAICA0ABAoAAA==.',['�']='星期午:AwAFCAUABAoAAA==.星野真理:AwAECAQABRQAAA==.',['�']='晓七:AwAFCAUABAoAAA==.',['�']='最增强的一集:AwABCAEABRQAAA==.有点意思哈:AwACCAIABAoAARMAQHEBCAEABRQ=.',['�']='枯竭王:AwAGCAEABAoAAA==.',['�']='柠檬番茄:AwAECAQABRQAAA==.',['�']='梓童:AwAICAYABAoAAA==.梨花浅酒:AwAFCAUABAoAAA==.',['�']='棍棍僧:AwAGCBgABRQCEQAGAQhTAQA4jq4BBRQAEQAGAQhTAQA4jq4BBRQAAA==.森林星如海:AwAFCBQABRQCBQAFAQjqAABJnXQBBRQABQAFAQjqAABJnXQBBRQAAA==.',['�']='樱井智树丶:AwAGCAsABAoAAA==.',['�']='橙子灬:AwAECAQABAoAAA==.',['�']='武则天丶:AwACCAcABRQCBAACAQjKIgA+8poABRQABAACAQjKIgA+8poABRQAAA==.死亡四号:AwAECAIABAoAAA==.死亡裂隙:AwAECAMABAoAAA==.',['�']='毁灭之魂:AwACCAIABAoAAA==.',['�']='波西盖子:AwAECAQABRQAAA==.',['�']='浪漫血液:AwACCAIABRQAAA==.浮岚瑞螭丶:AwAICAsABAoAAA==.',['�']='淡定到蛋疼:AwADCAkABRQCFAADAQgJAgAxWPUABRQAFAADAQgJAgAxWPUABRQAAA==.淡淡的体香味:AwAECAQABAoAAA==.深秋的月光:AwAICBgABAoCDAAIAQi6LwBUlkMCBAoADAAIAQi6LwBUlkMCBAoAAA==.',['�']='清微的凯莉:AwADCAMABAoAAA==.清月一:AwAICAgABAoAAA==.清澄:AwAECAQABRQAAA==.',['�']='灬稳稳灬:AwAECAQABRQAAA==.',['�']='熊熊小饼干:AwAGCAkABAoAAA==.',['�']='爪牙牙:AwAFCBQABRQCCQAFAQgDAgBi9c0BBRQACQAFAQgDAgBi9c0BBRQAAA==.爱玩:AwABCAIABRQAAA==.',['�']='牛德蕐:AwAGCAYABAoAAA==.牛马应该给草:AwAGCAYABAoAAA==.',['�']='狐万:AwAECAUABRQCBAAEAQi9FwArsdgABRQABAAEAQi9FwArsdgABRQAAA==.',['�']='猴子:AwADCAUABRQCFQADAQjhDAAItHIABRQAFQADAQjhDAAItHIABRQAAA==.',['�']='玄武南城:AwAECAQABRQDFAAIAQhHAgBYfMsCBAoAFAAIAQhHAgBYfMsCBAoAFgAIAQjYJgAe0SUBBAoAAQIAAAAGCAQABRQ=.',['�']='琪亚娜:AwADCAkABRQCFwADAQhhAgA5qLQABRQAFwADAQhhAgA5qLQABRQAAA==.',['�']='畅饮联盟血:AwAFCAEABAoAARgALyoICAoABRQ=.',['�']='疯狂的哎:AwABCAIABRQAAA==.',['�']='白水绕东城:AwAICAgABAoAAA==.白鹿:AwAFCBcABRQCEQAFAQiPBQAcECIBBRQAEQAFAQiPBQAcECIBBRQAAA==.',['�']='破天魔龙:AwACCAIABRQAAA==.',['�']='硬不够:AwABCAEABRQAAA==.',['�']='秋瑾凉:AwAECAQABRQAAA==.',['�']='空空如也灬:AwACCAIABAoAAA==.空达万:AwAGCAgABAoAAA==.',['�']='竹海听涛:AwAGCAYABAoAAA==.',['�']='粤走佬王廿四:AwAGCAsABAoAAA==.',['�']='索伦:AwAGCAYABRQCCQAGAQgAAwAtBKMBBRQACQAGAQgAAwAtBKMBBRQAAA==.紫萱:AwAGCAQABRQDCQAIAQg1GwBM70ECBAoACQAIAQg1GwBIlEECBAoACAADAQjTeAA1lnwABAoAAA==.',['�']='红手小云非:AwAGCAQABRQAAA==.红手小非非:AwAECAQABRQAAQ4AQIkGCAUABRQ=.红色体育生:AwAGCAYABAoAAA==.纲阿纲:AwAICAgABAoAAA==.',['�']='绿皮大姐姐:AwAFCAgABAoAAA==.',['�']='羲和玄霄:AwAICAgABAoAAA==.',['�']='艾莉塔尔:AwABCAEABAoAAA==.',['�']='芬达口香糖:AwAGCAYABRQCGQAGAQjyAAA1b7oBBRQAGQAGAQjyAAA1b7oBBRQAAA==.',['�']='苍泠:AwEFCAwABRQEGgAFAQgWBAAvFz4BBRQAGgAFAQgWBAAvFz4BBRQACwACAQgpEwBGXJIABRQAGwACAQjhFAASpG0ABRQAAA==.若丶不离:AwABCAMABRQEHAAIAQiHFwA2jBEBBAoAHAAEAQiHFwA0ThEBBAoAEAADAQj1MQAwC9UABAoADwAEAQj/agArr6gABAoAAA==.',['�']='莫道:AwADCAMABAoAAA==.',['�']='華仔:AwABCAEABRQAAA==.菱纱天河:AwAECAQABRQAAA==.',['�']='萌小马:AwABCAIABRQAAA==.萨瓦迪卡:AwADCAMABAoAAA==.萨龙迪卡:AwAECAQABRQAAA==.萬巳如意:AwAICAgABAoAAA==.',['�']='蓝原柚子:AwADCAMABAoAAA==.',['�']='虫子吖:AwADCAMABAoAAA==.',['�']='蜂蜜吃着甛:AwAECAQABAoAAQIAAAAICAgABAo=.蜂蜜吃着甜:AwAECAcABAoAAA==.',['�']='装小盒里:AwAICAoABAoAAA==.',['�']='西北望:AwADCAMABAoAAA==.',['�']='观海听涛:AwAGCAYABRQCDwAGAQgvAQA01KEBBRQADwAGAQgvAQA01KEBBRQAAA==.',['�']='说来有点可笑:AwABCAEABRQAAA==.',['�']='谜之骑士:AwACCAIABRQAAA==.',['�']='费莲诺尔:AwAFCAkABAoAAA==.',['�']='超级湮灭王:AwAECAQABRQAAA==.',['�']='踩电门:AwAECAQABAoAAA==.',['�']='轻笙空杯:AwAGCAUABAoAAQIAAAABCAIABRQ=.',['�']='迎风布阵丶:AwAICA4ABAoAAA==.',['�']='逐星者:AwADCAMABAoAAA==.',['�']='邂逅:AwAECAQABRQAAA==.',['�']='郝合偕:AwACCAIABRQAAA==.',['�']='酒后少女的梦:AwABCAIABRQAAA==.酒贰拾柒:AwABCAEABRQAAA==.',['�']='锅边狐:AwABCAEABRQAAA==.',['�']='闪电侠:AwAGCAYABAoAAA==.',['�']='阿什达拉诺:AwAICBAABAoAAA==.阿爾萨斯丶:AwAFCAUABAoAAA==.阿萨姆奶茶:AwAGCAgABAoAAA==.',['�']='陈丶风暴烧酒:AwAECAUABRQCHQAEAQgSBAAeL6MABRQAHQAEAQgSBAAeL6MABRQAAA==.',['�']='随风流逝:AwABCAEABAoAAA==.',['�']='雷电芽衣:AwADCAMABAoAAA==.',['�']='青龙:AwAFCAUABAoAAA==.',['�']='风露立中宵:AwADCAkABRQCFgADAQi1CwAuzbkABRQAFgADAQi1CwAuzbkABRQAAA==.',['�']='香烟只抽牡丹:AwACCAIABRQAAA==.',['�']='骄阳之魂:AwAFCAUABAoAAA==.',['�']='高富帅丶:AwADCAgABRQDHgADAQj/DQAl75AABRQAHgACAQj/DQAo2pAABRQABQACAQjsGgAmXYwABRQAAA==.',['�']='魔幻丶笨笨:AwAICAoABAoAAA==.',['�']='黑猫教主:AwAECAQABAoAAA==.黑糖珍珠奶茶:AwACCAMABAoAAA==.黑糖珍珠牛奶:AwADCAoABRQCDgADAQi4FQAY9r8ABRQADgADAQi4FQAY9r8ABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end