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
 local lookup = {'Paladin-Protection','Paladin-Retribution','DeathKnight-Blood','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','Monk-Windwalker','Monk-Mistweaver','Warrior-Arms','Warlock-Demonology','Rogue-Assassination','Rogue-Subtlety','Rogue-Outlaw','DeathKnight-Unholy','Warlock-Destruction','Druid-Feral','Warrior-Fury','Priest-Discipline','Priest-Holy','Priest-Shadow','Mage-Frost','Mage-Arcane','Mage-Fire','Warrior-Protection','Evoker-Preservation','Evoker-Devastation','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Balance','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','Warlock-Affliction','Paladin-Holy',}; local provider = {region='CN',realm='阿尔萨斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ak='Akagei:AwAFCAQABRQAAA==.',Al='Alicemo:AwAHCAoABAoAAA==.',Ao='Aoy:AwAICAUABAoAAA==.',Ar='Arceus:AwAECAQABRQAAA==.',At='Atme:AwABCAEABRQAAA==.',Cr='Creelovo:AwAICBAABAoAAA==.',Cy='Cyrus:AwACCAUABAoAAA==.',Do='Downfall:AwADCAUABRQDAQADAQj7CAA+d6wABRQAAQADAQj7CAAwtKwABRQAAgABAQjXOABcum0ABRQAAQMAUsIDCAkABRQ=.',Du='Dusksting:AwADCAkABRQCAwADAQgkBQBSwiIBBRQAAwADAQgkBQBSwiIBBRQAAA==.',Ec='Echoing:AwADCAMABAoAAA==.',En='Enumaelish:AwABCAEABRQAAA==.',Fi='Firstshoot:AwAICBUABAoDBAAIAQiRFABWkwICBAoABAAHAQiRFABTvQICBAoABQAIAQirOABKPPcBBAoAAA==.',Fr='Freezed:AwACCAIABRQAAA==.',Gr='Grangers:AwACCAIABAoAAA==.',Ha='Happyfb:AwAFCAcABAoAAA==.Haunter:AwAGCAcABRQCBQAGAQiwAwAqSnYBBRQABQAGAQiwAwAqSnYBBRQAAQYAAAAICAQABRQ=.',He='Hellshadow:AwADCAYABAoAAA==.',Ho='Holdthelight:AwABCAEABAoAAA==.',Kl='Klcrs:AwABCAEABAoAAQIAVfACCAEABRQ=.',Li='Lightangel:AwACCAMABRQDBwAIAQhODwBNGloCBAoABwAIAQhODwBNGloCBAoACAAIAQh4FABK9zECBAoAAA==.',Lu='Lunkui:AwAFCAcABAoAAA==.',Ma='Magnum:AwABCAEABAoAAA==.Mayling:AwAECAQABRQAAA==.',Mi='Miracle:AwAGCAYABRQCCQAGAQirAAAwsL8BBRQACQAGAQirAAAwsL8BBRQAAA==.',Ni='Nikloo:AwADCAMABAoAAQoATtgICAsABRQ=.',Ot='Otreasureo:AwABCAEABAoAAA==.',Pa='Parapluie:AwAECAQABRQAAA==.',Pi='Pigeonc:AwAECAgABRQCCwAEAQgxBgBDu/8ABRQACwAEAQgxBgBDu/8ABRQAAA==.',Pr='Pro:AwAECAQABRQDDAAIAQgyDABKiSICBAoADAAIAQgyDABETCICBAoADQAGAQhvBwBFZaoBBAoAAA==.',Re='Remstein:AwADCAMABAoAAA==.',Sa='Sanuell:AwAICAgABAoAAA==.Sarah:AwAFCAUABAoAAA==.',Sh='Shangwai:AwAECAQABRQAAQ4AQ3QGCA0ABRQ=.',Sy='Symm:AwACCAEABRQCAgAIAQjgNgBISzMCBAoAAgAIAQjgNgBISzMCBAoAAA==.',Vi='Victini:AwAICAEABRQAAA==.',Yu='Yuimetal:AwAFCAUABAoAAA==.Yuzurihinori:AwAICAgABAoAAA==.',Ze='Zedstar:AwACCAIABRQAAA==.',['�']='一枪八百里:AwACCAIABRQDBQAIAQiqIQBLH1wCBAoABQAIAQiqIQBKPFwCBAoABAABAQhxbwAy4jsABAoAAA==.七凌若晓:AwAICAgABAoAAA==.七月晴天:AwAHCAcABAoAAA==.万解:AwACCAIABRQAAA==.三队萨满:AwABCAEABAoAAA==.不坠青云:AwACCAIABRQAAA==.不爱吃香菜:AwAFCAUABAoAAA==.丨小球球丨:AwAGCAYABRQCAgAGAQjeAABB5tMBBRQAAgAGAQjeAABB5tMBBRQAAA==.丨是个萨满丨:AwAICAgABAoAAA==.丫鬟:AwABCAEABRQAAA==.临夜吹雪:AwADCAMABAoAAA==.丶周杰伦灬:AwAICAQABRQAAA==.举个栗子丶:AwAECAQABRQAAA==.',['�']='乱世佳猎:AwAECAQABAoAAA==.',['�']='亂红莲:AwACCAQABRQCAgAIAQjhGgBUpp0CBAoAAgAIAQjhGgBUpp0CBAoAAA==.了梦无痕:AwACCAIABRQAAA==.二元镜:AwADCAMABAoAAA==.云海之上:AwAFCAkABAoAAA==.五龙转灭:AwABCAEABRQAAA==.亡亥誓德:AwAFCAUABAoAAA==.亡亥誓沭:AwAICAwABAoAAA==.',['�']='会演奏春日影:AwADCAUABAoAAA==.伽玛细胞:AwACCAUABRQCDgACAQjHHgAZfHoABRQADgACAQjHHgAZfHoABRQAAA==.',['�']='低因冰美式:AwADCAMABAoAAA==.佑汐:AwACCAIABRQDDwAIAQiKAABikhcDBAoADwAIAQiKAABikhcDBAoACgAIAQgqAwBR96MCBAoAAQ8AWvkGCAQABRQ=.',['�']='依然灬猫猫:AwADCAMABAoAAA==.',['�']='保护野生动物:AwADCAkABRQCEAADAQgYAQBQYSQBBRQAEAADAQgYAQBQYSQBBRQAAA==.',['�']='元首大人:AwAICAgABAoAAA==.先天满魂力:AwABCAEABRQAAA==.八大姑:AwAICAgABAoAAA==.八点必起:AwABCAEABAoAAA==.兽奴永不为人:AwAHCBMABAoAAA==.',['�']='冰爽洁面乳:AwACCAIABRQAAA==.冰糖柠檬丶:AwABCAEABAoAAA==.',['�']='凛冬的寒鸦号:AwAICAgABAoAAA==.',['�']='加尔鲁亻十:AwAICA4ABAoAAA==.',['�']='十一是坦克:AwAICAgABAoAAA==.南有泽:AwAECAQABAoAAA==.卡捷迪奥斯:AwABCAEABRQAAA==.',['�']='厉害的名字:AwABCAEABAoAAA==.',['�']='又土马奇士:AwACCAMABRQDAgAIAQhpaQArbqsBBAoAAgAIAQhpaQArbqsBBAoAAQABAQhrYAAKFQ4ABAoAAA==.双鱼座霜魂:AwACCAQABRQCAgAIAQh3aQA396sBBAoAAgAIAQh3aQA396sBBAoAAA==.古尓玬:AwAECAoABAoAAA==.可口可乐:AwAICAgABAoAAQUAN9MGCAkABRQ=.',['�']='吃我闪电箭:AwAECAQABAoAAA==.吆小骑一个:AwAHCAcABAoAAA==.',['�']='咖啡:AwAICAwABAoAAREAEqsECAYABRQ=.咖啡泡芙:AwACCAIABAoAAA==.',['�']='哭泣之美:AwAICCEABAoDCgAIAQgRFwAtGo4BBAoADwAIAQi0MAAn25wBBAoACgAHAQgRFwAuqY4BBAoAAA==.',['�']='唧唧复唧唧丨:AwAECAQABRQAAA==.',['�']='商参丶:AwAECAMABAoAAA==.啤酒子开瓶盖:AwABCAEABRQAAA==.',['�']='嘉兴张战:AwAECAUABAoAAA==.嘉兴血迪凯:AwAICAUABAoAAA==.',['�']='土兵:AwABCAIABRQAAA==.土屋安娜:AwAGCAoABRQEEgAGAQgnBQA4+yIBBRQAEgAEAQgnBQBXECIBBRQAEwAEAQiXCQAiCtcABRQAFAACAQjyEwAfHKEABRQAAA==.圣光拯救:AwABCAEABRQCAgAIAQhCNwBFiDICBAoAAgAIAQhCNwBFiDICBAoAAA==.圣光无畏:AwAICBAABAoAAA==.圣光象拔蚌:AwAECAQABRQAAA==.圣白莲:AwAECAQABRQAAA==.',['�']='夜见:AwAHCAUABAoAAA==.夜钗:AwAFCAUABAoAAA==.夢隊長:AwABCAEABRQAAA==.大咕噜:AwAICAgABRQDBQAIAQiuAwBDHHYBBRQABQAEAQiuAwAyYnYBBRQABAAEAQgIAwBZaiABBRQAAA==.大神涼子:AwAICBAABAoAAQ4AQ3QGCA0ABRQ=.大神轻松:AwAGCAgABAoAAA==.大西瓜:AwAICBAABAoAAA==.天喵:AwAICAgABAoAAA==.天罚之之:AwAICAwABAoAAA==.',['�']='奕剑咕星诀:AwAICAEABAoAAA==.奥纳瑞斯:AwAHCBkABAoEFQAHAQhxJwA+CcIBBAoAFQAHAQhxJwA+CcIBBAoAFgABAQheGgArWTgABAoAFwABAQg7pQAAAAAABAoAAA==.奶嗝喵喵:AwAGCAoABAoAAA==.',['�']='妙不可言:AwAICA8ABAoAAA==.',['�']='姣椛:AwAHCAcABAoAAA==.',['�']='宁舟巷大队长:AwAECAQABRQAAA==.',['�']='寂寞一风行者:AwAHCAIABAoAAA==.',['�']='小凡不凡:AwAICAgABAoAAA==.小凡凡:AwAICA8ABAoAAA==.小小米娅:AwABCAEABAoAAA==.小掰掰:AwADCAMABAoAAA==.小猪会武功:AwABCAEABAoAAA==.小猪兔:AwADCAQABAoAAA==.小猪爱喝奶茶:AwABCAEABAoAAA==.小米大麦粥:AwABCAEABRQCBQAIAQjDOQA96vIBBAoABQAIAQjDOQA96vIBBAoAAA==.小阿鲁:AwAGCAUABAoAAA==.小鱼:AwAECAQABRQAAA==.尐文:AwABCAEABAoAAA==.',['�']='山殊:AwACCAQABAoAAA==.',['�']='左眼蹦迪:AwABCAEABRQAAA==.已死过一次:AwACCAIABAoAAA==.',['�']='布隆:AwAICAgABAoAAA==.希尔瓦娜咝:AwAICAkABAoAAA==.',['�']='库洛米:AwAECAQABRQDEQAIAQi7IAA6BP8BBAoAEQAIAQi7IAA4Bf8BBAoAGAACAQjDNAAlslAABAoAAA==.',['�']='弗兰佐克:AwAICAkABAoAAQYAAAAGCAIABRQ=.强大的小小:AwAECAUABAoAAA==.',['�']='彡丶哞哞丶厶:AwACCAIABRQAAA==.彬彬就是逊啊:AwAECAQABRQAAA==.',['�']='征战:AwAHCA4ABAoAAA==.御神乐丶:AwABCAEABRQAAA==.',['�']='快来骑我吧:AwABCAEABRQDGQAIAQj4BgA/VwoCBAoAGQAIAQj4BgA/VwoCBAoAGgAHAQiBFwBJS98BBAoAAA==.',['�']='怜的佪忆:AwABCAMABRQAAA==.',['�']='恐惧气息:AwAECAEABRQAAA==.恒熏儿:AwAHCAcABAoAAA==.',['�']='惊雁落虚弦:AwAECAQABRQAAA==.惜墨:AwAECAQABAoAAA==.',['�']='懒得说再见:AwACCAMABRQCBQAIAQh4JABIlU8CBAoABQAIAQh4JABIlU8CBAoAAA==.',['�']='我不是難罠:AwAECAQABRQAAQ8APyIGCAYABRQ=.我也不是難罠:AwAHCAcABAoAAA==.我是臭大熊:AwABCAEABRQAAA==.我有钉宫病:AwAECAQABRQAAA==.',['�']='所罗门巴赫:AwAGCAkABAoAAA==.托马斯螺旋:AwADCAMABAoAAA==.',['�']='招财猫一号:AwABCAEABRQAAA==.',['�']='斐貓:AwAECAYABAoAAA==.断岩:AwADCAMABAoAAA==.',['�']='无惧:AwAECA0ABRQDCQAEAQgQBAA7hQgBBRQACQAEAQgQBAA7hQgBBRQAEQABAQjaKgAAAAAABRQAAA==.无敌战妹:AwAFCAkABAoAAA==.',['�']='星际选手:AwAICAMABAoAAA==.',['�']='暴躁的疯狂丶:AwAICCsABAoCEQAIAQg/CgBWCaoCBAoAEQAIAQg/CgBWCaoCBAoAAA==.',['�']='曰后你要想我:AwABCAEABAoAAA==.曾蔷飒:AwAECAQABAoAAA==.',['�']='最强灬:AwACCAEABRQAAA==.月奏星咏:AwAGCBAABAoDCgAGAQgSIwBHPzUBBAoACgAFAQgSIwBD8TUBBAoADwADAQhkbQAz26kABAoAAA==.月影之力:AwABCAEABRQDGwAIAQiPOQArJKkBBAoAGwAIAQiPOQArJKkBBAoAHAAIAQgCLgAVI/EABAoAAA==.月影佑汐:AwAGCAYABRQDHQAGAQg+BABLmz0BBRQAHQAEAQg+BABbEz0BBRQAHgACAQjzCABXCtAABRQAAA==.木有人:AwADCAkABRQCAgADAQhSEwBDWfsABRQAAgADAQhSEwBDWfsABRQAAA==.朵猪儿:AwABCAEABRQAAA==.',['�']='果立橙的梧桐:AwAGCAYABAoAAA==.',['�']='柏人:AwACCAIABAoAAA==.',['�']='桐楻:AwABCAMABRQAAA==.',['�']='梦恋花雨:AwAICAkABAoAAA==.梦醒心自警:AwAECAQABAoAAA==.',['�']='橘生淮南丶:AwADCAIABAoAAA==.橙汁:AwAICAgABAoAAA==.',['�']='死亡丧钟:AwADCAoABRQCAwADAQhmDAAu078ABRQAAwADAQhmDAAu078ABRQAAA==.',['�']='殇梦大爷:AwABCAEABAoAAA==.',['�']='水一样的男子:AwADCAIABRQAAA==.',['�']='泰式香蕉奶:AwADCAMABRQAAR8AOvkECAoABRQ=.泰纳瑞斯:AwAGCAsABAoAARUAPgkHCBkABAo=.',['�']='深海比目鱼:AwAGCAIABRQAAA==.',['�']='清河晨星:AwAICAoABAoAAA==.渣丶渣:AwACCAIABRQAAA==.',['�']='溪边有座矿:AwACCAMABAoAAA==.',['�']='潇潇兮:AwAICA4ABAoAAA==.',['�']='灬魔衂:AwAECAQABRQAAA==.',['�']='炒肝儿:AwAHCBQABAoDBQAHAQg4SQBEXbkBBAoABQAHAQg4SQBEXbkBBAoABAABAQjigQAAAAAABAoAAA==.',['�']='熊猫胖嘟嘟:AwABCAIABRQAAA==.',['�']='爆法户:AwACCAIABAoAAA==.爱德华忸盖特:AwAFCAUABAoAAA==.爱河中的小草:AwAGCAYABAoAAA==.',['�']='版纳胶农:AwAECAQABAoAAA==.',['�']='狂八神:AwAGCAsABAoAAA==.狂野丶诗篇:AwAICA4ABAoAAQYAAAAGCAQABRQ=.狄狄系新手:AwADCAgABAoAAA==.狼铛:AwADCAkABRQCDQADAQjxAQAjSOEABRQADQADAQjxAQAjSOEABRQAAA==.',['�']='猪嗝紧:AwAICAgABAoAAA==.',['�']='王二麦闪闪哒:AwABCAEABRQAAA==.王奶拾:AwAECAoABRQDAQAEAQjsBgA54M0ABRQAAQAEAQjsBgA54M0ABRQAAgACAQgsOAAOc3IABRQAAREAN1IICAkABRQ=.王牌变色龙:AwADCAoABRQCIAADAQhABABJkgoBBRQAIAADAQhABABJkgoBBRQAAA==.',['�']='瘦巴巴老爷们:AwAHCBEABAoAAA==.',['�']='白度兰:AwAICAoABAoAAA==.白糖裹粽子:AwAICBgABAoCAgAIAQgNRgBWXgQCBAoAAgAIAQgNRgBWXgQCBAoAAA==.',['�']='真牛哔:AwAICAgABAoAAA==.',['�']='砍王伊芙利特:AwAECAQABRQAAA==.',['�']='第一孝子:AwAICAgABAoAAA==.',['�']='米瑞玛:AwAECAUABAoAAA==.',['�']='糖静娃儿丶:AwABCAEABAoAAA==.',['�']='紫眸凝牧:AwABCAEABAoAAA==.',['�']='红专并进:AwADCAkABRQDIQADAQhHDQA2kaUABRQAIQACAQhHDQA2AaUABRQADwACAQgqIgAdGmMABRQAAA==.',['�']='终极魔兽:AwADCAsABRQDBQADAQjQHAA7uscABRQABQADAQjQHAAY7scABRQABAACAQggEABDF6sABRQAAA==.绿豆排骨:AwABCAIABRQDAgAIAQhlYQAzmb0BBAoAAgAIAQhlYQAzmb0BBAoAIgAHAQj2JAAbtggBBAoAAA==.',['�']='罰罪:AwAECAQABRQAAA==.',['�']='翠羽青衫:AwAICAgABAoAAA==.',['�']='职业奶瓶:AwAECAQABRQAAA==.',['�']='艾雅:AwABCAEABRQAAA==.',['�']='花溪子:AwAICAgABAoAAA==.',['�']='萨里萨去:AwACCAMABRQAAA==.落风之域:AwABCAEABRQAAA==.',['�']='蒜蓉小龙虾:AwAGCAYABAoAAA==.',['�']='蛋弟:AwAHCAwABAoAAA==.蛋挞学长丶:AwAICAgABAoAAA==.',['�']='血怒元素:AwAECAcABAoAAA==.血疯颠:AwAECAQABRQAAA==.',['�']='诡术龍喵:AwAFCAUABAoAAA==.',['�']='豆苗胖猫猫:AwAGCAYABRQDBAAGAQi8BgBA9foABRQABAAEAQi8BgBI4PoABRQABQACAQgVHwA1FLYABRQAAA==.',['�']='贝尔芬格:AwACCAEABAoAAA==.',['�']='赤红马格努斯:AwAECAQABRQAAR0ARVEHCAcABRQ=.',['�']='路边啃西瓜:AwAECAQABRQAAA==.',['�']='轩辕圣光剑:AwAICAMABAoAAA==.',['�']='达拉斯小法:AwABCAEABRQAAA==.',['�']='近戰灬獵人:AwAECAoABRQCBQAEAQjWEwA/SvIABRQABQAEAQjWEwA/SvIABRQAAA==.迪鲁:AwABCAEABAoAAA==.追猎者八大妈:AwABCAEABAoAAA==.',['�']='逆時針灬魔戰:AwAICA8ABAoAAA==.逝去的日子:AwACCAIABAoAAA==.逮到乱射:AwACCAIABAoAAA==.',['�']='道别哀歌:AwABCAEABRQCCQAIAQhUBABZvr0CBAoACQAIAQhUBABZvr0CBAoAAA==.',['�']='酒仙断风:AwAFCAUABAoAAA==.酒仙潘萨:AwABCAEABAoAAA==.',['�']='钝角:AwAGCAYABAoAAA==.',['�']='铁丶牛:AwAICB8ABAoCDgAIAQimIQBHlBkCBAoADgAIAQimIQBHlBkCBAoAAA==.铁甲小马丶:AwABCAEABRQAAA==.',['�']='长嬴夜之凝雨:AwABCAIABRQCIAAIAQgeFgBKSR8CBAoAIAAIAQgeFgBKSR8CBAoAARQAOKsDCAcABRQ=.',['�']='阴滋萨爽:AwAICAgABAoAAA==.阿古茹丶:AwAICCAABAoCEQAIAQh0HAA93hoCBAoAEQAIAQh0HAA93hoCBAoAAA==.阿咕咕:AwABCAEABAoAAA==.阿珏先生:AwADCAMABAoAAA==.阿蛋丶:AwAECAQABRQCBQAIAQhvHABKTnUCBAoABQAIAQhvHABKTnUCBAoAAA==.',['�']='陈丨数码相机:AwACCAQABRQCCAAIAQg8IQA7I84BBAoACAAIAQg8IQA7I84BBAoAAA==.陈皮:AwAHCBwABAoCBwAHAQgpEwBXwDQCBAoABwAHAQgpEwBXwDQCBAoAAA==.陶子你真牛熬:AwAGCAIABRQAAA==.',['�']='難罠不是我:AwAGCAYABAoAAA==.雪蒂凯:AwABCAEABRQDDgAIAQibLAA/mN0BBAoADgAHAQibLABF0N0BBAoAAwAGAQhZPQAXmKkABAoAAA==.雪见无痕:AwABCAEABRQAAA==.零度的火焰:AwABCAEABAoAAA==.雷德死亡咆哮:AwAECAQABRQAAA==.雷电法王杨:AwAFCAMABAoAAA==.',['�']='霁無瑕:AwACCAIABAoAAA==.震震:AwAFCAQABAoAAA==.霜影霁无暇:AwACCAIABAoAAA==.霜焱:AwACCAIABAoAAA==.',['�']='青青寳贝:AwAICBUABAoDAwAIAQj2GwA9GI4BBAoADgAIAQjEOAA2RqcBBAoAAwAIAQj2GwAxSY4BBAoAAA==.',['�']='韩晶:AwACCAIABAoAAA==.',['�']='风中的沉默:AwADCAQABRQDFQAIAQgtCABgs7kCBAoAFQAIAQgtCABgs7kCBAoAFwADAQiZXgBN9eEABAoAAA==.风起云涌:AwACCAIABRQAAA==.飞鸟真:AwADCAMABAoAAA==.',['�']='饿了么猎手:AwAGCAsABAoAAA==.',['�']='香克斯:AwACCAIABAoAAA==.',['�']='高俅:AwAGCAcABRQDCAAEAQiCCgA6d/wABRQACAAEAQiCCgA6d/wABRQABwABAQgzFgAmglMABRQAAQYAAAAICAIABRQ=.高斯:AwABCAEABRQAASEARzQDCAcABRQ=.',['�']='鬣丶狗:AwACCAYABRQDBAACAQgzFQA/S4EABRQABAACAQgzFQAnzYEABRQABQABAQieOQA4iU4ABRQAAA==.',['�']='魂归戰袍:AwAICA8ABAoAAQYAAAACCAEABRQ=.魔法的花生:AwADCAoABRQCGgADAQgxCQBG6u0ABRQAGgADAQgxCQBG6u0ABRQAAA==.',['�']='麦芽脆:AwAECAUABRQCAgAEAQi4EQBPVgEBBRQAAgAEAQi4EQBPVgEBBRQAAA==.麻辣丶:AwAECAQABRQAAA==.',['�']='黄昏之眼:AwACCAIABRQAAA==.黑咖啡的心情:AwAHCAoABAoAAA==.',['�']='龙多多:AwABCAEABRQAAA==.龙希希:AwAICAgABAoAAA==.龚成章:AwAFCAEABAoAAA==.龟蛇:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end