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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Monk-Windwalker','Rogue-Assassination','Warlock-Destruction','Druid-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-Marksmanship','DeathKnight-Blood','Mage-Fire','Hunter-BeastMastery','Warrior-Arms','Shaman-Restoration','DeathKnight-Unholy','Evoker-Devastation','Evoker-Preservation','Warrior-Fury','Warlock-Affliction','Warlock-Demonology','Mage-Frost','Monk-Brewmaster','Shaman-Enhancement',}; local provider = {region='CN',realm='卡德加',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alance:AwAGCAQABRQAAA==.',Bl='Blacklagoon:AwABCAEABRQAAA==.',Ci='Cielfroth:AwAECAQABRQAAA==.',Co='Codey:AwAICAoABAoAAA==.',Da='Darker:AwACCAQABRQAAA==.',De='Defendh:AwAECAQABRQAAA==.',Dr='Dreamna:AwAICBEABAoAAA==.',Ec='Ecstay:AwADCAEABAoAAA==.',Fa='Fann:AwAICAgABAoAAA==.',Go='Goudk:AwAICAgABAoAAA==.',Hy='Hykd:AwAICAYABAoAAA==.',Jo='Jolin:AwABCAIABRQDAQAIAQhgFABcVrMCBAoAAQAIAQhgFABcVrMCBAoAAgABAQhoXQAKXw4ABAoAAA==.',Ma='Magicloveu:AwACCAQABRQAAA==.',Mi='Mikasa:AwAICAgABAoAAA==.',No='Nob:AwAHCAcABAoAAA==.',Oo='Ooqvo:AwACCAQABRQCAQAIAQiUIwBTanECBAoAAQAIAQiUIwBTanECBAoAAA==.',Sh='Shayulajiao:AwAECAQABRQAAA==.',Si='Sindorin:AwAGCAcABAoAAA==.',St='Stan:AwACCAIABRQAAA==.',Ti='Tiaralyoyqs:AwAECAQABRQAAA==.Tinabranford:AwAFCAEABAoAAQMAAAACCAMABRQ=.',Yx='Yxl:AwAECAQABAoAAA==.',['�']='一二三毛:AwAGCAYABAoAAA==.一起哈啤:AwAECAQABRQAAA==.一鬼厉一:AwACCAMABAoAAA==.丨傀丨:AwAGCAsABAoAAA==.丨祈福丨:AwAICBAABAoAAQMAAAAGCAQABRQ=.丨蓝朋友丨:AwAICAIABAoAAA==.中二病怪我咯:AwACCAIABAoAAA==.丶薄荷奶绿:AwAECAQABRQAAQQAIYsICAYABRQ=.丿壹瓶丨盖:AwAICAgABAoAAA==.',['�']='么么菈哚:AwAICAwABAoAAA==.',['�']='云中鶴:AwAICAkABAoAAA==.互联网混子:AwACCAUABRQCBQACAQi7DgARZ4QABRQABQACAQi7DgARZ4QABRQAAA==.',['�']='什么名字矫情:AwADCAwABRQCBgADAQioDAA3/t0ABRQABgADAQioDAA3/t0ABRQAAA==.',['�']='伊利达雷之刃:AwACCAIABRQAAA==.',['�']='你干嘛哎哟:AwAICAgABAoAAA==.',['�']='傲慢的月亮:AwAECAQABRQAAA==.',['�']='冰王子妮可:AwAECAQABRQAAQcAPyYICAsABRQ=.冲上去就砍:AwAICAgABAoAAA==.',['�']='剑蚀丶盾藏:AwABCAEABAoAAA==.',['�']='加加布鲁跟:AwAICAgABAoAAA==.',['�']='卟想早睡:AwAICAgABAoAAA==.占戈灬云鬼:AwAICAUABAoAAA==.卡卡东森赛:AwAECAQABRQAAA==.',['�']='可乐椒麻鸡:AwABCAEABRQAAA==.',['�']='君焱:AwAECAgABRQDCAAEAQiRDgA4ovMABRQACAAEAQiRDgA4ovMABRQACQAEAQhJCgANdIoABRQAAA==.吾亦可往:AwAICAQABAoAAA==.',['�']='咪神:AwAICAgABAoAAA==.',['�']='哈彼国:AwACCAMABRQAAA==.哥战无不胜:AwACCAIABAoAAA==.',['�']='單戈乂云鬼:AwAHCAEABAoAAA==.',['�']='嗚咪:AwACCAMABRQCCgAIAQiBEABGISMCBAoACgAIAQiBEABGISMCBAoAAA==.',['�']='四十多个女生:AwAFCAwABAoAAA==.',['�']='墨染樱:AwAECAQABRQAAA==.墨魇:AwAECAkABRQCCwAEAQhhFQAHD24ABRQACwAEAQhhFQAHD24ABRQAAA==.',['�']='夜游宫:AwACCAQABRQAAA==.',['�']='奥妮奥妮:AwAECAQABRQAAA==.奶萨:AwAGCAMABAoAAA==.',['�']='季末的花絮:AwABCAEABAoAAA==.孤云独去闲丶:AwAICAIABAoAAA==.',['�']='寒绫:AwACCAEABRQAAA==.寻找火星的你:AwAGCA4ABRQCDAAGAQh+AQBEy+kBBRQADAAGAQh+AQBEy+kBBRQAAQwAT1sHCAUABRQ=.',['�']='小三丶:AwADCAMABAoAAA==.小鬼的奶妈:AwACCAIABRQAAA==.少少甜:AwAECAQABRQAAA==.少爷:AwAICAgABAoAAA==.就知道吃土:AwAECAQABRQAAQMAAAAICAMABRQ=.',['�']='幽默小黄人:AwAGCAcABAoAAA==.',['�']='开心网丶:AwAICAgABAoAAA==.开盘:AwACCAMABRQAAA==.',['�']='急速小兜子:AwACCAIABAoAAA==.急速萌萌德:AwAICAYABAoAAA==.',['�']='我想吃呷哺:AwACCAIABRQAAA==.我手残丶:AwAECAQABRQAAA==.战神幽雅:AwAFCAUABAoAAA==.',['�']='拉她丶左右手:AwAECAQABRQAAA==.拉面炒饭:AwAICAMABAoAAA==.',['�']='挺胸接榴莲:AwAHCAcABAoAAA==.',['�']='施巴拉谷大师:AwAICBAABAoAAA==.',['�']='星语:AwACCAIABRQAAA==.',['�']='晓小七:AwACCAIABRQAAA==.晓霜天晓:AwAECAQABRQAAA==.',['�']='暴走安吉娜:AwAECAQABRQAAA==.暴鸷:AwABCAEABRQAAA==.',['�']='曼哈顿博士:AwAFCAUABAoAAA==.曾经两米一:AwAGCAYABRQCDQAGAQhVAQA+VsABBRQADQAGAQhVAQA+VsABBRQAAA==.',['�']='杨了二过:AwACCAMABRQCDQAGAQhsTgBOI5sBBAoADQAGAQhsTgBOI5sBBAoAAA==.',['�']='橙味美年达:AwAICCEABAoCDgAIAQjoFAA6j+YBBAoADgAIAQjoFAA6j+YBBAoAAA==.',['�']='江先:AwAGCAQABRQAAA==.',['�']='波波沙的烦恼:AwAECAQABRQAAA==.',['�']='洛月:AwAHCAUABAoAAA==.',['�']='流浪的舞步:AwADCAEABAoAAA==.浪子阿烈:AwAECAQABRQAAA==.',['�']='液态镁:AwADCAkABRQCDAADAQhsCQBQ2hwBBRQADAADAQhsCQBQ2hwBBRQAAA==.',['�']='淡淡黄昏丶:AwAECAEABRQAAA==.',['�']='清风它自来:AwAFCAUABAoAAA==.清风明月我:AwACCAMABRQCDwAGAQihXAAqCPsABAoADwAGAQihXAAqCPsABAoAAQcAOkwGCAUABRQ=.渺灬怒:AwAFCAUABAoAAA==.',['�']='溟灭:AwAFCAEABAoAAA==.',['�']='漂亮的馒头君:AwAECAQABRQAAA==.',['�']='灬沉迷灬:AwAFCAgABAoAAA==.灬芃然欣动灬:AwACCAUABRQCDQACAQjnHwA+gqQABRQADQACAQjnHwA+gqQABRQAAA==.灬薄情:AwACCAUABRQCEAACAQjPFQA3yJ8ABRQAEAACAQjPFQA3yJ8ABRQAAA==.',['�']='炭烤鸡翅:AwAECAkABRQDEQAEAQgiCAA82O4ABRQAEQAEAQgiCAA82O4ABRQAEgADAQh7BABJZpsABRQAAA==.',['�']='熊猫荣誉会长:AwACCAIABAoAAA==.熱河:AwACCAMABRQAAA==.',['�']='牛奶冒泡泡灬:AwACCAIABRQAAA==.牛魔鬼王:AwAECAgABRQCEwAEAQh+CwAyTf4ABRQAEwAEAQh+CwAyTf4ABRQAAA==.牧芸:AwAICAgABAoAAA==.特贰的獵人:AwAECAQABRQAAA==.',['�']='狂盗金不焕:AwAICAkABAoAAA==.',['�']='玉水茗沙:AwAGCAYABRQDFAAGAQhiAAA2SWYBBRQAFAAFAQhiAABAw2YBBRQAFQABAQghDQAMYFEABRQAAA==.玛尼托尼:AwADCAMABAoAAA==.',['�']='珑籥:AwACCAMABRQAAA==.',['�']='生有何欢:AwACCAIABRQAAA==.画画的贝赑:AwAICAgABAoAAA==.',['�']='疯逗小抗:AwAICAMABAoAAQMAAAAECAQABRQ=.',['�']='百千家美滋滋:AwAICBIABAoAAA==.',['�']='相忘于江湖:AwAICAUABAoAAA==.',['�']='真心加不住:AwAECAQABRQAAA==.真黑:AwAECAIABRQAAA==.',['�']='督军归来:AwAFCAIABAoAAA==.',['�']='碧海蓝天:AwACCAIABAoAAA==.碾压小骑:AwAECAQABRQAAA==.',['�']='移动木桩:AwACCAIABRQAAA==.',['�']='程艾影丶:AwABCAEABRQAAA==.',['�']='绝代神王:AwAGCAYABAoAAA==.',['�']='耀灬火星:AwAECAQABRQAAA==.老腿哥:AwACCAUABRQCAQACAQggIQBD8rUABRQAAQACAQggIQBD8rUABRQAAA==.',['�']='肥肥狗蛋:AwABCAEABAoAAA==.',['�']='自寻死路丨:AwAFCAsABRQCCAADAQgCDABFdf8ABRQACAADAQgCDABFdf8ABRQAAA==.',['�']='艺术鉴赏家:AwAGCAwABAoAAA==.',['�']='花落丶莫相离:AwAICAgABAoAAA==.',['�']='茶饮三道:AwAECAQABRQAARYARgAHCAcABRQ=.',['�']='莣记一切:AwAHCAEABAoAAA==.',['�']='萌中带酒:AwADCAgABRQCFwADAQhwBAAacJgABRQAFwADAQhwBAAacJgABRQAAA==.萨橙橙:AwAECAMABRQCDwACAQjUGwApaIkABRQADwACAQjUGwApaIkABRQAARgAM3YICAkABRQ=.',['�']='蓝色德鲁依:AwAECAYABAoAAA==.',['�']='蔡国庆:AwAECAQABAoAAA==.',['�']='虚云:AwACCAIABRQAAA==.',['�']='蜂蜜柚子茶:AwAICAgABAoAAA==.',['�']='血杀之圣岚:AwACCAIABRQAAA==.',['�']='西格玛之子:AwAECAYABAoAAA==.西野七濑:AwADCAQABAoAAA==.',['�']='诡术妖姬丶:AwABCAEABRQAAA==.',['�']='豆豆充电宝:AwAFCAUABAoAAA==.',['�']='远坂凛:AwAICAgABAoAAA==.远方二十七:AwABCAEABRQAAA==.',['�']='酴醾:AwACCAQABRQCDAAIAQhkEwBOLHQCBAoADAAIAQhkEwBOLHQCBAoAAA==.',['�']='醉卧沙场:AwAECAQABRQAAA==.',['�']='野原广志:AwABCAEABAoAAA==.',['�']='闹闹别闹:AwADCAEABAoAAA==.',['�']='陆尹儿:AwACCAUABRQCCAACAQg4HAAuoZkABRQACAACAQg4HAAuoZkABRQAAQgAPDgGCAwABRQ=.',['�']='隐约雷鸣:AwAECAQABRQAAA==.',['�']='霜见叁柒:AwAECAgABRQCAQADAQhrCQBVFRsBBRQAAQADAQhrCQBVFRsBBRQAAA==.',['�']='青青的爱:AwACCAIABRQCDQAGAQgWZwA5vkoBBAoADQAGAQgWZwA5vkoBBAoAAA==.',['�']='颤动的睫毛:AwAICAgABAoAAA==.',['�']='高启强:AwADCAYABAoAAA==.',['�']='魂殇风雷:AwAICAgABAoAAA==.魍魉画魂:AwADCAEABAoAAQMAAAAGCAMABAo=.',['�']='麻吉弟弟:AwAECAQABRQAAA==.',['�']='黑暗的威胁:AwADCAMABRQAAA==.黑鲸丶:AwAFCAQABAoAAA==.黑龍部落灬:AwAHCAQABAoAAA==.',['�']='龌龊之奶豆:AwAECAQABRQAAA==.龙猪丶熊白白:AwAFCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end