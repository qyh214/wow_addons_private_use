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
 local lookup = {'DemonHunter-Havoc','Evoker-Devastation','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Monk-Windwalker','Monk-Brewmaster','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Unknown-Unknown','Monk-Mistweaver','Druid-Balance','Druid-Restoration','Druid-Guardian','Mage-Fire','DeathKnight-Frost','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DemonHunter-Vengeance','Warrior-Fury','DeathKnight-Unholy','Shaman-Elemental','DeathKnight-Blood','Priest-Discipline','Priest-Holy','Hunter-Survival',}; local provider = {region='CN',realm='古尔丹',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arpanda:AwABCAIABRQAAA==.',Cj='Cjlxbb:AwAECAUABRQCAQAEAQiaEAAvduoABRQAAQAEAQiaEAAvduoABRQAAA==.',Dr='Dracoaltais:AwAFCAUABRQCAgAFAQgDAgBRP3cBBRQAAgAFAQgDAgBRP3cBBRQAAA==.',El='Eliot:AwADCAMABAoAAA==.',Er='Eripmav:AwACCAIABAoAAA==.',Ho='Holybringer:AwAICBoABAoEAwAIAQjPLQBO1UoCBAoAAwAHAQjPLQBYmUoCBAoABAADAQiSNQAtZ5UABAoABQAEAQjoMwAYU5EABAoAAA==.Houology:AwABCAEABRQAAA==.houooxx:AwADCAIABAoAAQsAAAABCAEABRQ=.',Im='Imfiredup:AwAGCAoABAoAAA==.',Ir='Ironick:AwAECAQABRQAAA==.',Ju='Jud:AwABCAIABRQAAQIAUT8FCAUABRQ=.Juju:AwAECAQABRQAAA==.',Mk='Mklovenowar:AwACCAMABRQAAA==.',Mo='Moos:AwAECAQABRQDBgAIAQiqFQBAjxECBAoABgAIAQiqFQBAjxECBAoABwAIAQisDgAoZioBBAoAAQYAKkoICAYABRQ=.',Or='Orman:AwAICBkABAoDCAAIAQhsJQBL0EMCBAoACAAIAQhsJQBLQEMCBAoACQAFAQhHQAAu+9MABAoAAA==.',Po='Polluxl:AwAICBoABAoCAQAIAQg/KwA1quQBBAoAAQAIAQg/KwA1quQBBAoAAA==.',Re='Resets:AwAICBsABAoCCgAIAQjuIAA8Nu0BBAoACgAIAQjuIAA8Nu0BBAoAAA==.',Su='Suzaku:AwADCAMABAoAAA==.',Sy='Synergies:AwABCAEABRQAAA==.',Vo='Vovi:AwAGCAQABRQAAA==.',Wu='Wukong:AwACCAEABAoAAA==.',Ze='Zeinv:AwAFCAoABAoAAA==.',['�']='一个大拉:AwAICAgABAoAAA==.一朵小雏菊:AwAECAIABRQAAA==.一阑珊一:AwADCAMABAoAAA==.七月的风筝:AwADCAMABAoAAA==.三文鱼小卷:AwAECAQABRQAAA==.丨斯密达丨:AwAICAgABAoAAQEAJpkICAUABRQ=.丨李小龙丨:AwAECAQABAoAAA==.丶乖戾:AwAECAQABRQAAA==.丶仙女星人:AwABCAEABRQAAA==.丶小村姑:AwAHCAcABAoAAA==.丶慕天夏:AwAECAQABRQAAA==.丶望舒:AwAGCAYABAoAAA==.丶秋水伊人:AwAICAgABAoAAA==.丶老农民:AwABCAEABRQAAA==.丶艾米莉亚:AwAICAgABAoAAA==.丶霓裳丶:AwAHCAcABAoAAQwAH94ICAoABRQ=.丿缘缘:AwAECAUABRQDDQAEAQhUCwA7tvoABRQADQAEAQhUCwA7tvoABRQADgABAQiJGQAuMz0ABRQAAA==.',['�']='亲亲不回来:AwAECAYABAoAAA==.',['�']='仙林女巫:AwAECAQABRQAAA==.仲煌:AwACCAIABAoAAA==.',['�']='伊瑟瑞拉:AwADCAQABAoAAA==.',['�']='余八:AwAICAIABAoAAA==.你爷他手一抬:AwAICBEABAoAAA==.',['�']='傳說中的胖逹:AwADCAMABAoAAA==.',['�']='儍儍哋:AwAICBkABAoCDwAIAQj1DQAgpCoBBAoADwAIAQj1DQAgpCoBBAoAAA==.',['�']='充气玩偶:AwAGCAYABAoAAA==.兔斯基丶旺旺:AwAFCAUABAoAAA==.全肉套餐:AwAGCAYABAoAAA==.',['�']='农夫娇子:AwADCAcABAoAAA==.冰冰有你:AwABCAEABRQAAA==.冰霜不喝酒丶:AwAICAgABAoAAA==.',['�']='剑舞丶:AwADCAMABAoAAA==.',['�']='北斗双星:AwAECAQABRQAAA==.',['�']='午夜厕所男:AwAICAgABAoAAA==.午夜杀肌:AwAFCAkABAoAAA==.',['�']='发彪的丶蜗牛:AwABCAEABAoAAA==.发条橙丶:AwAECAYABRQDCAAEAQiHCQBbSxoBBRQACAAEAQiHCQBUTRoBBRQACQACAQj2DgBdKKAABRQAAA==.叮当响:AwAECAQABAoAAA==.',['�']='咸鱼烧饼:AwACCAIABAoAAA==.',['�']='唯美回忆:AwAECAQABAoAAA==.',['�']='啦拉:AwAGCAgABRQCEAAGAQiVBwBAWDABBRQAEAAGAQiVBwBAWDABBRQAARAAQ8QICAcABRQ=.啦拉啦:AwAICAgABAoAAA==.',['�']='善丶意:AwABCAEABAoAAA==.',['�']='圣洁殇刃:AwAFCAQABAoAAA==.',['�']='基拉:AwAECAQABRQAAQsAAAAGCAQABRQ=.',['�']='墨色樱花:AwADCAMABAoAAA==.墨韵秋浓丶:AwADCAMABRQAAA==.',['�']='多蒙丨卡修:AwAHCBYABAoCEQAHAQgNCwBIc8cBBAoAEQAHAQgNCwBIc8cBBAoAAA==.夜慕微霜:AwACCAIABRQCAwAIAQjQJABXym0CBAoAAwAIAQjQJABXym0CBAoAAA==.大圣丶:AwABCAEABAoAAA==.大宗师庆帝:AwACCAIABRQAAA==.大熊猫猎手:AwAECAwABRQDCAAEAQgDDgBLfQIBBRQACAAEAQgDDgBLfQIBBRQACQACAAgAAABF0AAABRQAAA==.',['�']='好硬硬:AwAFCAYABAoAAA==.',['�']='妍霜雪:AwAECAQABAoAAA==.妙手箜箜:AwAICA4ABAoAAA==.',['�']='婉南的路:AwADCAEABAoAAA==.',['�']='字母大侠:AwAHCAcABAoAAA==.',['�']='安啦安啦:AwAICAgABAoAAA==.安强姐的脚毛:AwAFCAkABAoAAA==.安德雷奥利:AwAECAEABRQAAA==.',['�']='富強福丶:AwAICAMABRQAAA==.',['�']='小兜:AwAICAgABAoAAA==.小及莫丶:AwACCAMABRQEEgAIAQiPCQBcjZQCBAoAEgAHAQiPCQBahpQCBAoAEwAEAQgcJwBapg8BBAoAFAADAQhDGwBEK/AABAoAAA==.小嘴巴抽荷花:AwAECAgABRQDFQAEAQgpCAAgxaYABRQAAQAEAQhcFgAUbMsABRQAFQAEAQgpCAAbpaYABRQAAQYAWZcGCBkABRQ=.小强的童话:AwAICAMABRQAAA==.小飞丨来了:AwAECAQABRQAAA==.',['�']='崩裂:AwAECAgABRQCFgAEAQgTCwA6EwABBRQAFgAEAQgTCwA6EwABBRQAAA==.',['�']='带头冲锋:AwADCAMABAoAAA==.带小德的猎手:AwAICAkABAoAAQkAWpYGCAgABRQ=.',['�']='床边故事:AwAGCAsABAoAAA==.应紧么老:AwACCAIABRQAAA==.应紧小羽:AwAECAQABRQAAA==.',['�']='忘不了那母牛:AwADCAMABAoAAA==.',['�']='愛情奴隶:AwAGCAYABAoAAA==.愤怒的大脸:AwAECA8ABRQCAQAEAQj8CgBK2gUBBRQAAQAEAQj8CgBK2gUBBRQAAA==.',['�']='慕容沧海丶:AwACCAIABRQAAA==.',['�']='我龙傲天无敌:AwAICAoABAoAAA==.',['�']='打得不错抱歉:AwAECAQABRQAAA==.',['�']='抠脚的备爹:AwAECAQABRQAAA==.',['�']='拿水枪滋你:AwAICBgABAoDCQAIAQh6GQAyd8sBBAoACQAIAQh6GQAwF8sBBAoACAAEAQiitQAVnY8ABAoAAA==.',['�']='换坦不嘲讽:AwADCAUABRQCFwADAQjmCAA+Zv4ABRQAFwADAQjmCAA+Zv4ABRQAAA==.',['�']='搓搓丶坏人:AwAGCAQABRQAAA==.',['�']='文体两开花:AwACCAYABRQDDQACAQicHAAuB5QABRQADQACAQicHAAuB5QABRQADgACAQgzEQApLnoABRQAAA==.',['�']='无耻求拉:AwAGCAwABAoAAA==.无需大师:AwADCAMABAoAAA==.',['�']='星黛露:AwAICBEABAoAAA==.',['�']='暗夜灬絯杍:AwACCAIABRQAAQsAAAAGCAIABRQ=.暗鬼小乔:AwAECAgABRQDFAAEAQheAQBecjQBBRQAFAAEAQheAQBecjQBBRQAEgAEAQiKDgAo89IABRQAAA==.暨然琴瑟起:AwACCAEABAoAAA==.',['�']='曲墨墨:AwADCAMABAoAAA==.替身使者肥猫:AwAECAcABAoAAA==.',['�']='极度爱路亚:AwAICAgABAoAAQYAIYsICAYABRQ=.',['�']='查无此战:AwAECAQABRQAAA==.查无此骑:AwAECAQABRQAAA==.查无此魔:AwAECAQABRQAAA==.柳迦南:AwAECAgABRQCBQAEAQg4AwBBYAMBBRQABQAEAQg4AwBBYAMBBRQAAA==.柳迦难:AwAECAQABRQAAA==.',['�']='梦靥寂梦丶:AwAHCAgABAoAAA==.',['�']='楓葉落:AwACCAIABRQAAQsAAAAECAQABRQ=.',['�']='槑丨槑:AwAICAIABAoAAA==.',['�']='死恐心也:AwABCAEABAoAAA==.',['�']='殁殁:AwABCAEABRQAAQsAAAAGCAQABRQ=.',['�']='氟米龙滴眼液:AwAGCAYABAoAAA==.水毋:AwAHCAkABAoAAA==.水流觴:AwAFCAUABRQCCgAFAQgwAwAjojEBBRQACgAFAQgwAwAjojEBBRQAAA==.',['�']='汤圆丶:AwAGCAoABAoAAA==.',['�']='没伤害:AwABCAEABAoAAA==.',['�']='泛舟泛舟:AwACCAMABRQCAwAIAQh7DQBfgtUCBAoAAwAIAQh7DQBfgtUCBAoAAA==.泱泱:AwACCAIABRQAAA==.',['�']='浩宇星辰:AwAECAQABAoAAA==.',['�']='淡写:AwAECAQABRQAAA==.',['�']='清风水萨:AwACCAYABRQDCgACAQjIGgAgQ4wABRQACgACAQjIGgAgQ4wABRQAGAACAQhLEAAWXXQABRQAAA==.',['�']='灬冰丨魂灬:AwAECAgABRQDFwAEAQhTCgA56/UABRQAFwAEAQhTCgA56/UABRQAGQAEAQiMDAAsPbMABRQAAA==.灬喵喵灬:AwAICAgABAoAAQsAAAAGCAQABRQ=.',['�']='炎焱燚焱炎:AwACCAQABRQDDQAIAQhOKQBApvABBAoADQAHAQhOKQBHpPABBAoADwABAQjMKwAWsR0ABAoAAA==.炫舞灵动:AwAICBoABAoCCQAIAQjhCQBP13ECBAoACQAIAQjhCQBP13ECBAoAAA==.点解你某老婆:AwABCAEABAoAAA==.',['�']='烤香肠:AwACCAMABRQAAA==.',['�']='無尽刹戮:AwAGCAQABRQAAA==.',['�']='熏风晗岄丶:AwAFCAIABAoAAA==.',['�']='牛德辰:AwAECAcABRQCCQAEAQiOCwAwT8oABRQACQAEAQiOCwAwT8oABRQAAA==.特肿兵小河马:AwAICBsABAoCCgAIAQh+KAA2eMUBBAoACgAIAQh+KAA2eMUBBAoAAA==.',['�']='猎手爱德华:AwAECAQABRQAAA==.猪肉荣炖排骨:AwACCAIABAoAAA==.猪肉荣炖粉条:AwAFCA4ABAoAAA==.猫猫得儿猪猪:AwAGCAYABRQCDAAEAQgJDwAj4dcABRQADAAEAQgJDwAj4dcABRQAAA==.',['�']='盗刀之盗:AwAFCAUABAoAAA==.',['�']='矮点蛋是硬:AwACCAIABAoAAA==.',['�']='神牧龍龍酱:AwAICCMABAoDGgAIAQibEQBKzRkCBAoAGgAIAQibEQBE5xkCBAoAGwAIAQisEwBDFxACBAoAAA==.',['�']='穷儒丶公羊羽:AwAICAgABAoAAA==.',['�']='粉红色体育生:AwAECAUABRQCAwAEAQj+CgBZExQBBRQAAwAEAQj+CgBZExQBBRQAAA==.粉色佩奇:AwAICAgABAoAAA==.',['�']='紫耀星辰:AwACCAIABAoAAA==.',['�']='绝望的我:AwAECAQABAoAAA==.绯音:AwABCAEABAoAAA==.',['�']='羲和丶:AwABCAEABRQAAA==.',['�']='聖乄熊猫人:AwAICAgABAoAAA==.聪明的小帅哥:AwADCAIABAoAAA==.',['�']='胖狗狗:AwAECAQABAoAAA==.胖达爱丹丹:AwACCAQABRQDCAAIAQitMQBC2QoCBAoACAAIAQitMQA/+goCBAoACQAGAQjbLAA0dUIBBAoAAA==.',['�']='艾梅拉尔妲:AwAGCAYABRQDEgAGAQi+AABf4cYBBRQAEgAFAQi+AABhVMYBBRQAEwABAQj1BwBaFWoABRQAARIAXx8ICAUABRQ=.',['�']='药问:AwADCAMABAoAAA==.',['�']='莉亚德菻:AwAGCBAABAoAAA==.莫得雷德:AwAICAsABAoAAA==.莱因哈特:AwAHCAcABAoAAA==.',['�']='菰单毛毛:AwABCAEABRQAAA==.',['�']='萌萌的奶油:AwAECAQABRQAAA==.',['�']='蒜香黄油大虾:AwAECAQABRQAAA==.',['�']='蛋蛋滴忧伤:AwABCAEABAoAAA==.',['�']='蜂花护发素:AwAICAgABAoAAA==.蜉蝣之翼:AwAECAQABRQAAA==.',['�']='蟹籽沙拉:AwACCAIABAoAAA==.',['�']='血不会:AwACCAIABAoAAA==.血刺印:AwABCAMABRQAAA==.血怒风:AwACCAIABRQAAA==.血灬泪:AwAICAYABAoAAA==.',['�']='装死很专业:AwAICAgABAoAAA==.',['�']='请叫我虾哥丶:AwACCAIABRQAAQ4APyYICAsABRQ=.',['�']='貝茵羙:AwAGCAUABAoAAA==.',['�']='轨僟:AwAECAMABAoAAA==.',['�']='迪文:AwAICAYABAoAAA==.',['�']='道亦可道:AwAICBMABAoAAA==.',['�']='里奥蕾娅:AwAGCAwABAoAAA==.野人新之助:AwAECAIABRQAAA==.',['�']='银色激流:AwADCAMABAoAAA==.',['�']='阒然猎手:AwADCAMABAoAAA==.阴影之容:AwAGCBMABAoAAA==.阿凡达戴眼镜:AwAHCAcABAoAAA==.阿墨达达:AwABCAEABRQAAA==.阿蓝丶:AwAHCAcABAoAAA==.',['�']='隔壁老王突然:AwAGCAcABRQDDQAGAQhBAwBRukABBRQADQAEAQhBAwBamEABBRQADgADAQgBCQA5AMYABRQAAQ4APyYICAsABRQ=.',['�']='雪舞丶:AwAECAQABAoAAA==.雪色丨舞曲:AwAFCAUABAoAAA==.雪诺:AwADCAUABAoAAA==.',['�']='霜夜:AwAECAQABRQAAA==.',['�']='青青子襟:AwAGCAQABRQAAA==.',['�']='飞天牛:AwAICAMABAoAAA==.飞雪衔霜:AwACCAIABRQAAA==.',['�']='马鹿西露:AwACCAQABRQAAA==.',['�']='黑青带毒:AwACCAIABRQAAA==.',['�']='龘灬龘:AwACCAQABRQEDgADAQhhMQBZsS8BBAoADgADAQhhMQBZsS8BBAoADQADAQjvZwBCZuEABAoADwABAQg7LQAYNhkABAoAAA==.龙涎香:AwAGCAYABAoAAA==.龙胆:AwAICBoABAoDCQAIAQibEABDLCICBAoACQAIAQibEABC/SICBAoAHAADAQjgEgAwR5AABAoAAA==.龙胆泻肝液:AwAICAkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end