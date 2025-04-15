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
 local lookup = {'Evoker-Devastation','Evoker-Preservation','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Outlaw','Paladin-Retribution','Priest-Discipline','Priest-Shadow','Shaman-Elemental','Druid-Restoration','Druid-Balance','Rogue-Assassination','Rogue-Subtlety','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Warlock-Affliction','Monk-Mistweaver','Priest-Holy','Mage-Fire','DemonHunter-Vengeance','DemonHunter-Havoc','Monk-Brewmaster','Warrior-Fury','Unknown-Unknown','Mage-Frost','DeathKnight-Unholy',}; local provider = {region='CN',realm='苏塔恩',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ad='Adamove:AwADCAUABRQDAQAIAQjBCABS+4wCBAoAAQAIAQjBCABS+4wCBAoAAgABAQi2KwAAAAAABAoAAA==.',Cr='Crouchv:AwAICAgABAoAAA==.',Do='Donk:AwAECAgABRQDAwAEAQjHAgBU7yMBBRQAAwAEAQjHAgBS2CMBBRQABAAEAQjwFAA4me8ABRQAAA==.',El='Elpsycongroo:AwACCAMABRQAAA==.',En='Enjoylife:AwADCAUABRQCBQADAQjfAQAqPecABRQABQADAQjfAQAqPecABRQAAA==.',Ex='Exelero:AwACCAUABRQCBgAIAQhWDABc+N8CBAoABgAIAQhWDABc+N8CBAoAAA==.',Ge='Gentouka:AwADCAgABRQDBwADAQhvBABQwy0BBRQABwADAQhvBABQwy0BBRQACAABAQjcGwA86VYABRQAAA==.',He='Hestia:AwAICAQABAoAAA==.',Je='Jealousy:AwAECAQABAoAAA==.',Kn='Knice:AwAHCAcABAoAAA==.',Kr='Krakenw:AwAECAQABRQAAQkAVZkICAIABRQ=.',Ma='Mattina:AwACCAIABRQAAA==.',Mu='Mummy:AwAECAQABAoAAA==.',Sl='Sladegelmir:AwAECAQABRQAAA==.',Sm='Smallhunter:AwAECAQABAoAAA==.',Su='Sunabcd:AwACCAIABAoAAA==.',Ta='Tahngarth:AwAICBEABAoAAA==.',Ve='Venturi:AwAGCAUABAoAAA==.',['�']='一只小小虫:AwAICAgABAoAAA==.七月子音:AwAFCAUABAoAAA==.东宝宝:AwACCAIABRQAAA==.丶惜年:AwAICAgABAoAAA==.丶涩龍:AwADCAMABAoAAA==.丶阿疯:AwABCAEABRQAAA==.丶青橙:AwACCAUABRQDCAAIAQgKDgBJaWUCBAoACAAIAQgKDgBJaWUCBAoABwAGAQikNwAvWhsBBAoAAA==.丷嬰儿肥丷:AwABCAEABAoAAA==.丿娜娜丶:AwABCAEABAoAAA==.',['�']='乖乖老板娘:AwAGCAYABAoAAA==.',['�']='任其逍遥:AwADCAcABRQDCgADAQieBwAzruAABRQACgADAQieBwAzruAABRQACwACAQh9JQAR92kABRQAAA==.',['�']='似曾相识:AwAECAYABAoAAA==.',['�']='但盼风雨来:AwABCAEABAoAAA==.佛罗翼德:AwAECAUABRQDDAADAQhwCwBIlLYABRQADAADAQhwCwA9n7YABRQADQABAQhIDgA0PVYABRQAAA==.你一下子就:AwABCAEABAoAAA==.',['�']='信仰之光:AwAICAkABAoAAA==.俺寻思基里馒:AwAGCBYABAoCBgAGAQi5fABIyoABBAoABgAGAQi5fABIyoABBAoAAA==.',['�']='倓莣濄去:AwABCAEABRQAAA==.',['�']='假死的杨二叔:AwABCAEABRQAAA==.',['�']='元素能进本么:AwAECAYABRQDCQAEAQhtCAA4At0ABRQACQAEAQhtCAA4At0ABRQADgACAQjpIgAG424ABRQAAA==.兜里有妖怪:AwABCAEABRQAAA==.六月飞天雪:AwACCAMABAoAAA==.',['�']='冰丶羽:AwACCAYABRQDDwAIAQjpDgBOPt0BBAoADwAGAQjpDgBLp90BBAoAEAAGAQhpNABKkYoBBAoAAA==.冷月记忆:AwAGCAQABRQAAA==.',['�']='凯飒丶大帝:AwAICAkABAoAAA==.',['�']='刘等等的奶龙:AwAECAQABRQAAA==.创口贴:AwABCAEABRQDBAAIAQh3QwAyS80BBAoABAAIAQh3QwAyS80BBAoAAwAEAQiBVQAifYkABAoAAA==.',['�']='包里有枪:AwAGCAgABAoAAA==.北原仓介:AwAGCAQABRQAAA==.北风微凉丶:AwAECAQABRQAAA==.',['�']='午後小妖:AwAICAsABAoAAA==.卡門灬芝士:AwAICAgABAoAAA==.',['�']='古美萌:AwAECAQABRQAAA==.可岚:AwAECAQABRQAAREAV3UICAgABRQ=.',['�']='吃瓜群众:AwACCAIABAoAAA==.',['�']='呆猎:AwAECAcABRQDAwAEAQhnDgAeN78ABRQAAwAEAQhnDgAaw78ABRQABAADAQguNAAKv2wABRQAAA==.',['�']='嗨丶土豆:AwAECAUABAoAAA==.',['�']='噜噜君:AwAGCAYABRQCDAAGAQiJAQAUz5EBBRQADAAGAQiJAQAUz5EBBRQAAA==.噜噜呼:AwAICA4ABAoAAA==.',['�']='圣光牛肉干:AwACCAQABRQAAA==.',['�']='塔达林坚果:AwAHCAwABAoAAA==.',['�']='墮楓:AwACCAIABAoAAA==.',['�']='壞脾气:AwAFCAUABAoAAA==.壹贰叁肆伍:AwABCAEABRQAAA==.',['�']='夆影:AwACCAYABRQEDwAIAQhVBABTT4QCBAoADwAIAQhVBABTHYQCBAoAEAAHAQhELAA+mrIBBAoAEgACAQhcMwBWDWEABAoAAA==.夜听风雨:AwAECAUABRQCEwAEAQgoFAAOR7oABRQAEwAEAQgoFAAOR7oABRQAAA==.大披风:AwACCAIABRQAAA==.大飘神:AwAECAkABAoAAA==.天堂娇花:AwAGCAkABAoAAA==.天空叶:AwAGCAgABAoAAA==.天赐发疯:AwADCAYABRQDCQADAQh4BABA2AcBBRQACQADAQh4BABA2AcBBRQADgABAQi1LAAgNjoABRQAAA==.夸父丶:AwAICA4ABAoAARQAPuAGCAcABRQ=.',['�']='奈落落:AwABCAEABAoAAA==.奥克塔蛮角:AwAGCAcABAoAAA==.奶味十足:AwAGCA0ABAoAAA==.奶糖喵喵:AwABCAEABRQAAA==.',['�']='妹子加我战网:AwACCAIABAoAAA==.',['�']='姜硬:AwAICA8ABAoAAA==.',['�']='嫣然妹妹:AwAECAQABAoAAA==.',['�']='宝宝芭比:AwAGCBAABAoAAA==.宿醉在花间:AwAFCAUABAoAAA==.',['�']='小婲笙:AwAECAgABRQCEQAEAQgjDAAxcMEABRQAEQAEAQgjDAAxcMEABRQAAA==.小强强来玩玩:AwABCAEABAoAAA==.小淮风丶:AwAGCAoABAoAAA==.小狐:AwAECAQABAoAAA==.小色奻:AwAHCAcABAoAAA==.小虎牙丢丢:AwABCAEABRQAAA==.小野喵喵:AwAGCBAABAoAAA==.小黑熊人:AwADCAMABAoAAA==.',['�']='巫马良其:AwAHCAcABAoAAA==.',['�']='帝天:AwABCAEABAoAAA==.',['�']='幻夜骑士:AwAECAQABRQAAA==.',['�']='微明:AwACCAQABRQAAA==.',['�']='心灵丶震撼:AwAGCAgABRQCFQAGAQj3AgBCLr0BBRQAFQAGAQj3AgBCLr0BBRQAAA==.念伊人:AwAECAQABAoAAA==.',['�']='恐怖馒头:AwACCAIABAoAAA==.恶魔腾飞:AwABCAEABRQDFgAIAQgGIAAnRlUBBAoAFgAIAQgGIAAnRlUBBAoAFwABAQhNtAANXysABAoAAA==.',['�']='我半藏贼溜:AwAECAgABRQCFwAEAQiaFQAf/9kABRQAFwAEAQiaFQAf/9kABRQAAA==.',['�']='扁担哥们:AwAECAQABRQAAA==.批批:AwAGCAcABAoAAA==.',['�']='拳打老师傅:AwAFCBQABAoDEwAFAQjAXwAa5aQABAoAEwAFAQjAXwAa5aQABAoAGAAFAQiFHQAE5V4ABAoAAA==.拼点没输过:AwACCAUABRQDAQACAQiOFQAN1XAABRQAAQACAQiOFQAN1XAABRQAAgABAQi+BwBepmIABRQAAA==.',['�']='斩丶白:AwADCAMABRQAAA==.',['�']='无心睡眠:AwAECAcABAoAAA==.',['�']='春去东来:AwABCAEABRQDAwAIAQjpGgAxQskBBAoAAwAIAQjpGgAxQskBBAoABAADAQitxAAnP4EABAoAAA==.',['�']='有事没事烧纸:AwAECAQABRQAAA==.木公哥:AwACCAIABAoAAA==.末世之殇:AwADCAMABRQAAA==.',['�']='李元芳:AwAECAQABRQAAA==.李奶奶:AwAECAQABRQAAA==.杏花疏影:AwAECAMABAoAAA==.杨晨晨:AwACCAIABAoAAA==.杰伦威廉姆斯:AwAICAgABAoAAA==.杰瑞卢指导:AwAICAEABAoAAA==.',['�']='柚子乄:AwAICAcABAoAAA==.柠檬吃柑橘丶:AwAICA4ABAoAAA==.',['�']='極樂凈土:AwACCAMABRQAAA==.',['�']='橙多多:AwAGCAUABAoAAA==.',['�']='水無燈里:AwAICA8ABAoAAA==.',['�']='没冇病:AwADCAgABRQCFwADAQiZEAAxzO0ABRQAFwADAQiZEAAxzO0ABRQAAA==.',['�']='泰玛:AwACCAYABRQCDgACAQgaFgBI3rIABRQADgACAQgaFgBI3rIABRQAAA==.',['�']='流光飞舞丶:AwADCAkABRQCFAADAQhPAQBeO0IBBRQAFAADAQhPAQBeO0IBBRQAAA==.海洋是粉色的:AwAGCAQABAoAAA==.',['�']='清川月白:AwAECAQABRQAAA==.渐渐伤感:AwAECAQABRQAAA==.渡你到黄泉:AwADCAIABRQAAA==.渡鴉:AwADCAMABAoAAA==.游荡怪物:AwAECAYABAoAAA==.',['�']='满月鬼门开:AwADCAMABAoAAA==.',['�']='潜龍五用:AwABCAEABRQAAA==.潜龍吾用:AwADCAMABAoAAA==.',['�']='澹灬台:AwAGCAoABRQCCAAGAQgmAQBD19ABBRQACAAGAQgmAQBD19ABBRQAAA==.',['�']='灬虾米龍灬:AwAECAYABRQCBAAEAQjsEQBJT/kABRQABAAEAQjsEQBJT/kABRQAAA==.灰牛撒嘛:AwAFCAUABAoAAA==.灰豆是只喵:AwACCAIABRQAAA==.',['�']='炎焱燚淼:AwACCAMABAoAAA==.炒饭:AwABCAEABAoAAA==.炭烧脆皮肠:AwADCAMABAoAAA==.',['�']='熊熊桑:AwAGCAwABAoAAA==.',['�']='燕麦拿铁:AwAECAQABRQAAA==.',['�']='爷爷的斧子:AwACCAIABRQAAA==.',['�']='牛牛就是牛:AwABCAEABRQCGQAIAQjLEgBIf18CBAoAGQAIAQjLEgBIf18CBAoAAA==.牛转乾坤:AwACCAMABRQCCwAIAQhPHQBIKUACBAoACwAIAQhPHQBIKUACBAoAARoAAAAICAQABRQ=.',['�']='狂龙贝勒:AwAICBkABAoCAgAIAQhYBABFjFECBAoAAgAIAQhYBABFjFECBAoAAA==.独家记忆丶:AwADCAMABAoAAA==.狼丶齿:AwABCAEABAoAAA==.',['�']='猎户者:AwAGCAwABAoAAA==.猎魂收割者:AwAICAgABAoAAA==.',['�']='瑞伯:AwAHCA8ABAoAAA==.',['�']='瓦尔基莉亚:AwABCAEABRQAAA==.',['�']='發财:AwAECAMABRQAAA==.白发有面纹:AwAGCAYABAoAAA==.白色赞美诗:AwAECAQABRQAAA==.白雾红尘:AwABCAEABRQAAA==.',['�']='真水静天:AwAGCA4ABRQCBgAGAQgRAQA6IcUBBRQABgAGAQgRAQA6IcUBBRQAARUAUhwHCAwABRQ=.',['�']='神圣厂长之锤:AwAECAQABRQAAREAV3UICAgABRQ=.神尾觀鈴:AwADCAYABAoAAA==.',['�']='秋叶为何而落:AwACCAIABAoAAA==.',['�']='精灵枪火:AwAGCAwABAoAAA==.',['�']='糕手是我装的:AwAGCAIABAoAAA==.',['�']='紫烽:AwACCAIABRQAAA==.紫颖小满妞:AwAGCAsABAoAAA==.',['�']='红辣椒:AwAICAgABAoAAA==.',['�']='绝城:AwABCAEABRQAAA==.',['�']='美萱萱:AwAECAgABAoAAA==.',['�']='联盟追猎者:AwAGCAYABAoAAA==.',['�']='肆亡蛋蛋:AwAFCAUABAoAAA==.',['�']='胜者舞帝:AwAECAQABRQAAA==.',['�']='脚踝杀手:AwADCAMABAoAAA==.',['�']='荒野夜羽:AwAHCAQABAoAAA==.',['�']='菜鸟阿仁:AwACCAIABAoAAA==.',['�']='萌萌的雨落:AwAECAQABRQAAA==.',['�']='蓝屏的钙:AwAICAgABAoAARoAAAAGCAQABRQ=.蓝拂衣:AwAECAQABRQAAA==.蓝莓丶踏风:AwAFCAUABAoAAA==.蓝莓悠悠:AwAECAQABRQAAA==.蓝莓绛紫:AwAECAQABRQAAREAV3UICAgABRQ=.',['�']='血迪克嗨皮:AwAICAgABAoAAA==.',['�']='记忆里的岁月:AwAECAoABRQDGwAEAQgaCQAjkMgABRQAGwAEAQgaCQAjkMgABRQAFQACAQgKLwANyWIABRQAAA==.',['�']='豊川祥子:AwABCAEABRQDFQAIAQhnMgAzgsUBBAoAFQAIAQhnMgAzgsUBBAoAGwAEAQjbeQAlboEABAoAAA==.',['�']='贰拾叁:AwAFCAUABAoAAA==.',['�']='起儛挵淸景彡:AwAGCAYABAoAAA==.',['�']='轩辕牛仔:AwAGCAYABAoAAA==.',['�']='这就是我:AwABCAEABRQAAA==.',['�']='道生一:AwAHCAIABAoAAA==.',['�']='還苛以:AwACCAMABRQAAA==.邕府吴彦祖:AwABCAEABAoAAA==.邪风烈刃:AwAHCAgABAoAAA==.',['�']='酷炫少女:AwABCAEABAoAAA==.酷酷的土灵:AwAICAgABAoAAA==.酷酷的法哥:AwADCAMABRQAAA==.酷酷的萨满:AwAECAQABRQAAA==.',['�']='鑫鑫尛法:AwADCAMABRQAAA==.',['�']='铁臂憨憨:AwADCAMABAoAAA==.银鸦:AwACCAUABRQCBAACAQgCKAAsUJYABRQABAACAQgCKAAsUJYABRQAAA==.',['�']='闪电小呆:AwABCAEABAoAAA==.闷骚瘦骨爹:AwAICA4ABAoAAA==.',['�']='阿不归来:AwAICAQABRQAAA==.阿替卡因:AwAICAIABAoAAA==.阿罗:AwAECAgABRQCFwAEAQizEAA0fewABRQAFwAEAQizEAA0fewABRQAAA==.',['�']='隆科多丶:AwACCAEABRQCHAAIAQg2KgBBT+kBBAoAHAAIAQg2KgBBT+kBBAoAAA==.',['�']='雪夜星瞳:AwADCAMABAoAAA==.雾岛董香:AwAECAQABRQAAA==.',['�']='青丝为谁留:AwABCAEABAoAAA==.',['�']='飞雪和美羊羊:AwAICAgABAoAAA==.',['�']='骄阳皓月:AwAECAYABRQCEAAEAQi9CQBIt/oABRQAEAAEAQi9CQBIt/oABRQAARAATegICAYABRQ=.',['�']='鬼剑:AwADCAMABAoAAA==.鬼悠悠:AwAICAgABAoAAA==.',['�']='魔幻儛歩:AwAHCAkABAoAAA==.',['�']='鹤形:AwABCAEABAoAAA==.鹿目圆:AwAICAYABAoAAA==.鹿鹿麓:AwAGCAYABAoAAA==.',['�']='黄泉丶彼岸:AwAFCAcABAoAAA==.黑暗胖胖:AwADCAEABAoAAA==.',['�']='龙武:AwAICAYABAoAAA==.龙葵诗诗:AwAICBUABAoCBgAIAQh/dQAtopABBAoABgAIAQh/dQAtopABBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end