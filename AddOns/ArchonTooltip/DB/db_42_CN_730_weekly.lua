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
 local lookup = {'Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','DemonHunter-Vengeance','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Priest-Shadow','Priest-Discipline','DeathKnight-Frost','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Monk-Windwalker','Shaman-Elemental','Shaman-Restoration','DeathKnight-Blood','Mage-Fire','Evoker-Devastation','Paladin-Protection','Unknown-Unknown','Paladin-Retribution','Paladin-Holy','Druid-Restoration','Druid-Balance','Druid-Guardian',}; local provider = {region='CN',realm='洛肯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Aloha:AwADCAIABAoAAA==.',Ba='Babyzz:AwAGCAYABRQCAQAGAQiEAAAuL74BBRQAAQAGAQiEAAAuL74BBRQAAA==.',Dr='Druidorange:AwAECAQABRQAAA==.',En='Enteazz:AwAECAgABRQDAgAEAQjcDwBHN/oABRQAAgAEAQjcDwBHIfoABRQAAwAEAQiXCAA2xeIABRQAAA==.',Fl='Flytothemoon:AwAECAQABRQAAA==.',Fo='Foehn:AwABCAEABRQDBAAIAQiuOAA+bqEBBAoABAAHAQiuOAA9zaEBBAoABQAGAQjnMAAjQ9cABAoAAA==.',Im='Imbaxiaoxi:AwAECAQABAoAAA==.',Lu='Lucz:AwAECAQABRQAAA==.',Pa='Paluc:AwAECAQABRQAAA==.',Ri='Riolu:AwAGCAgABRQDBgAGAQhXAABEDOsBBRQABgAGAQhXAABEDOsBBRQABwACAQj7CQBAlagABRQAAA==.',Sh='Sheesiv:AwACCAMABRQECAAIAQi8KQA6anoBBAoACAAHAQi8KQA+m3oBBAoACQAHAQgEMQAcyCkBBAoACgABAQhZegAhQjcABAoAAA==.',St='Stanowo:AwACCAQABRQAAA==.',Tu='Tuleyon:AwACCAQABRQAAA==.',Yu='Yuanpp:AwAICAgABAoAAA==.',['�']='七八六:AwAICBYABAoCCwAIAQhYDAA6H6wBBAoACwAIAQhYDAA6H6wBBAoAAA==.上下划动:AwABCAEABRQAAA==.不是死水还阴:AwAGCAoABAoAAQQAPm4BCAEABRQ=.不爱圣斗士:AwAICAoABAoAAA==.丨绯红丨:AwAECAgABRQDDAAEAQjfBABWXiABBRQADAAEAQjfBABWXiABBRQADQABAQj9FwAAAAAABRQAAA==.丶蕾欧娜:AwAICBAABAoAAA==.丶表哥抱表弟:AwACCAIABAoAAA==.',['�']='么么哒哒:AwAFCAUABAoAAQ4AIpEECAUABRQ=.乌尔的信者:AwAICAgABAoAAA==.',['�']='二狗子丶:AwACCAMABRQAAA==.交还魂:AwAICAgABAoAAQ8AKkoICAYABRQ=.',['�']='依然依然:AwAECAEABRQAAA==.',['�']='信仰圣脏吧:AwADCAIABAoAAA==.修罗浮屠:AwAGCAYABAoAAA==.',['�']='八六杠:AwACCAQABRQCAwAIAQhSDwBJVC8CBAoAAwAIAQhSDwBJVC8CBAoAAA==.关龙冥骑:AwACCAIABRQCDgAIAQiVHwBGlBsCBAoADgAIAQiVHwBGlBsCBAoAAA==.',['�']='内向凡人:AwABCAEABRQDEAAIAQjQDQBPRmQCBAoAEAAIAQjQDQBPRmQCBAoAEQAHAQjvQwAqxlEBBAoAAA==.冰火毒龍钻:AwADCAIABAoAAA==.',['�']='凡尘灬血舞:AwAECAQABRQAAQEASh4GCAcABRQ=.',['�']='别呼啦:AwAICA0ABAoAAA==.',['�']='剃快换嘲:AwAECAQABRQAAA==.',['�']='加麻加辣:AwAICB8ABAoDCwAIAQgtBgBNeUgCBAoACwAIAQgtBgBNeUgCBAoAEgAHAQjaMwAdfdIABAoAAA==.',['�']='北落丨师门:AwAECAEABAoAAA==.北落师门丨烈:AwAGCAEABAoAAA==.',['�']='华爻:AwAFCAUABAoAAA==.卡比不卡:AwACCAIABRQAAA==.',['�']='历劫祓恶:AwAFCAQABAoAAA==.',['�']='唐法:AwADCAMABAoAAA==.',['�']='啊一锤:AwABCAEABAoAAA==.',['�']='喵酱的薛定谔:AwAICAgABAoAAA==.',['�']='城風舊酒:AwAECAEABAoAAA==.',['�']='大王别灰心:AwAECAQABRQAAA==.大糖丶糖糕僧:AwABCAEABRQAAA==.大麦芽:AwADCAMABRQAAA==.天空之魂:AwAECAQABRQAAA==.',['�']='学习使我快乐:AwACCAIABRQAAA==.',['�']='安吉拉北鼻:AwADCAkABRQDAgADAQj/HAA1RrIABRQAAgACAQj/HABMR7IABRQAAwACAQhwDwAtwZsABRQAAA==.安徒生编故事:AwAHCAEABAoAAA==.',['�']='小尾巴:AwAFCAUABAoAAA==.小酌二两:AwAICAYABAoAAA==.小酷:AwAGCAUABAoAAA==.少先队大队长:AwAGCAYABRQCEwAGAQgGBQAO+1kBBRQAEwAGAQgGBQAO+1kBBRQAAA==.',['�']='布鲁斯特:AwAICAgABAoAAA==.',['�']='形销骨立:AwAECAUABAoAAA==.',['�']='心灵震撼丶:AwAICBoABAoCBAAIAQhNGABNuFgCBAoABAAIAQhNGABNuFgCBAoAAA==.',['�']='我会给树皮:AwAECAEABRQAAQkANuAGCAIABRQ=.我会给灌注:AwAECAcABRQDCQAEAQhICQA7ofYABRQACQAEAQhICQA7ofYABRQACgACAQhFFgAsGYIABRQAARQAD08ICAUABRQ=.我怕疼啊:AwADCAMABAoAAQYATFAGCAYABRQ=.我是一条鱼儿:AwAECAUABRQCFQAEAQh8CgAXII8ABRQAFQAEAQh8CgAXII8ABRQAAA==.我还会回来的:AwAECAgABRQDCwAEAQiIAQBBywsBBRQACwAEAQiIAQA9gQsBBRQAEgAEAQiXDgAfdqUABRQAAA==.戴投代鸽:AwAECAQABRQAARYAAAAGCAMABRQ=.',['�']='手搓雷:AwAHCAoABAoAAA==.',['�']='抓饭加肉:AwAECAQABRQAAA==.护悠你:AwAICAgABAoAAA==.',['�']='拉風不拉怪:AwABCAEABRQAAA==.拯救无知少女:AwAHCAIABAoAAA==.',['�']='提灯驻足:AwAFCAUABAoAAA==.',['�']='摩诃:AwAECAUABAoAAA==.',['�']='无名骑士:AwAICA0ABAoAAA==.无情霸服鸡:AwABCAEABRQAAA==.无骑骑:AwACCAIABRQAAA==.时七:AwAECAYABAoAAA==.旺仔小拳头:AwAGCAsABAoAAA==.',['�']='易燃易爆:AwACCAIABAoAAA==.',['�']='晴岚风村丶:AwAICAgABAoAAA==.',['�']='暗武逆战理综:AwAECAIABAoAAA==.',['�']='曼斯特:AwACCAIABRQAAA==.',['�']='月夜茶会:AwAGCAoABRQDFwAEAQigCABTqh8BBRQAFwAEAQigCABTqh8BBRQAGAAEAQjlAwBLzfcABRQAAA==.木子李:AwAICA8ABAoAAA==.',['�']='果糖丶安妮薇:AwAICAgABAoAAA==.',['�']='楼徳华:AwADCAMABAoAAA==.',['�']='橙子味汽水:AwABCAEABRQAAA==.',['�']='歐氣滿滿灬:AwAICAoABAoAAQwASvQICBMABRQ=.',['�']='段平安:AwACCAIABRQAAA==.',['�']='浮世笑百姿:AwADCAMABAoAARYAAAAFCAQABAo=.海狼特:AwAGCAMABAoAAA==.',['�']='湫兮丶往昔:AwACCAMABRQECQAIAQhZFAA7rx0CBAoACQAIAQhZFAA7rx0CBAoACAAEAQjWTwAZT8sABAoACgAFAQizSAAVPcYABAoAAA==.',['�']='牛杂师傅刻晴:AwAFCAkABAoAAA==.牧山:AwACCAIABRQAAA==.',['�']='猛莮落涙:AwAICBIABAoAAA==.',['�']='玛格汉捕兽夹:AwAICAgABAoAAA==.',['�']='珩宝侠:AwAECAQABRQAAA==.',['�']='璐宝儿:AwAECAQABRQAARMAPU4ICAkABRQ=.',['�']='白送:AwAECAQABRQAAA==.',['�']='盘尼西林:AwAICA4ABAoAAA==.',['�']='矮脚貓:AwACCAYABRQCFwACAQjHJAA9iqIABRQAFwACAQjHJAA9iqIABRQAAA==.',['�']='米线多放葱:AwAICAgABAoAAA==.',['�']='粉紅毛毛兔:AwAICAQABAoAAA==.',['�']='紅桃叁:AwAFCAoABAoAAQoANgYGCAYABRQ=.紫眸:AwAICAgABAoAAA==.',['�']='纳菲酱:AwABCAEABRQCGQAIAQgeBgBWJqACBAoAGQAIAQgeBgBWJqACBAoAAA==.',['�']='羽落无声:AwAHCAMABAoAAA==.',['�']='老师大帅比:AwADCAQABRQCFwAIAQjmHABZCo4CBAoAFwAIAQjmHABZCo4CBAoAAA==.',['�']='胡须佬:AwACCAIABAoAAA==.',['�']='艾米丽雅碳:AwAICBcABAoDDQAIAQhpEgBIyqwBBAoADQAIAQhpEgA+WKwBBAoADAADAQhJVwBEVusABAoAAA==.',['�']='花儿在绽放:AwABCAEABRQAAQkANuAGCAIABRQ=.花卷儿丶:AwAICCMABAoCDAAIAQj8FgBPyScCBAoADAAIAQj8FgBPyScCBAoAAA==.花圣格:AwACCAIABRQAAA==.',['�']='苏嘟咩:AwABCAIABRQCAgAHAQggRQA727wBBAoAAgAHAQggRQA727wBBAoAAA==.',['�']='萌新小红手:AwAECAQABAoAAA==.',['�']='蕤繠蘂:AwAECAQABRQAAA==.',['�']='血舞残阳:AwAECAQABRQAAA==.',['�']='西蓝花:AwAGCAcABAoAAA==.',['�']='让你一个大丨:AwAHCAsABAoAAA==.',['�']='谈枫:AwACCAcABRQCBQACAQiODAAinncABRQABQACAQiODAAinncABRQAAA==.',['�']='赛丽蒙妮:AwAECAgABRQCGgAEAQhvDAA7w/UABRQAGgAEAQhvDAA7w/UABRQAAA==.',['�']='越甲三千:AwAECAQABRQAAA==.',['�']='载酒入柴扉:AwADCAoABRQCFwADAQi0FgAvnOkABRQAFwADAQi0FgAvnOkABRQAAA==.',['�']='达奚千叶:AwACCAQABRQAAA==.',['�']='进击德胖达:AwAECA8ABRQCGwAEAQg8AABdEEABBRQAGwAEAQg8AABdEEABBRQAAA==.',['�']='逍遥丶叕:AwABCAEABRQAAA==.',['�']='邪恶大领主:AwAICAgABAoAAA==.',['�']='铃蘭:AwAECAwABRQCBAAEAQhMDgA9ZvQABRQABAAEAQhMDgA9ZvQABRQAAA==.',['�']='阿拉丁神裆:AwAFCAkABAoAAA==.',['�']='陛下何故谋反:AwAICAgABAoAAA==.',['�']='随风听海:AwAFCAQABAoAAA==.随风静听海:AwAGCAYABAoAAA==.',['�']='雨柔:AwAICAgABAoAAA==.雪代巴丶:AwAICAgABAoAAA==.',['�']='青空:AwAECAgABRQCEgAEAQhPEgAOLIYABRQAEgAEAQhPEgAOLIYABRQAAA==.',['�']='韭菜丨盒子:AwAICAgABAoAARYAAAAICAQABRQ=.',['�']='飞机达人:AwAICAgABAoAAA==.',['�']='马杀鸡:AwAGCBIABAoAAA==.',['�']='骑实喜欢你:AwACCAIABRQAARcAWQoDCAQABRQ=.',['�']='魔鬼中的天使:AwAICAsABAoAAA==.魔鱼宝宝:AwAECAIABRQAARYAAAAICAIABRQ=.',['�']='鸢尾紫之心:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end