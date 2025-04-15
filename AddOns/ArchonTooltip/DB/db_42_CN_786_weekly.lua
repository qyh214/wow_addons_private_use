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
 local lookup = {'Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Priest-Holy','Paladin-Protection','Warlock-Destruction','Warlock-Affliction','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Warrior-Fury','Rogue-Assassination','Druid-Balance','Druid-Restoration','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Mage-Frost','DemonHunter-Vengeance','Paladin-Retribution','Warrior-Arms','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','Evoker-Augmentation','DemonHunter-Havoc','Paladin-Holy','Monk-Brewmaster','Warlock-Demonology',}; local provider = {region='CN',realm='红龙女王',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Anita:AwACCAIABRQAAA==.',Bi='Bio:AwABCAEABAoAAA==.',Br='Bronya:AwAECAgABRQCAQAEAQhGFwApJt0ABRQAAQAEAQhGFwApJt0ABRQAAA==.',Ea='Earlyrider:AwAGCAQABRQAAA==.',Gw='Gwyndolin:AwADCAMABAoAAA==.',In='Infinitelove:AwACCAMABRQCAgAHAQgvFABai2YCBAoAAgAHAQgvFABai2YCBAoAAA==.Invictus:AwACCAIABRQAAA==.',Ju='Julian:AwAFCAUABAoAAA==.',Ki='Kira:AwAECAQABRQAAA==.',La='Lakye:AwACCAQABRQAAA==.',Ll='Llonggnoll:AwAGCAcABRQCAwAFAQi1AQBFFVwBBRQAAwAFAQi1AQBFFVwBBRQAAA==.',Oq='Oqq:AwACCAIABRQAAA==.',Si='Sindweller:AwAECAQABAoAAA==.',Su='Suseven:AwAECAQABRQAAA==.',Wi='Witness:AwAHCAgABAoAAA==.',['�']='七丶六丶五:AwAHCA0ABAoAAA==.上七八可:AwAECAQABAoAAA==.下雨有伞:AwACCAMABRQCBAAIAQjnDgBKeTsCBAoABAAIAQjnDgBKeTsCBAoAAA==.不爱米莱圣骑:AwAICBgABAoCBQAIAQgDEwA8AbUBBAoABQAIAQgDEwA8AbUBBAoAAA==.不爱米莱武僧:AwAICAwABAoAAA==.中个彩票吧:AwAICBUABAoDBgAIAQg4DABTqnsCBAoABgAIAQg4DABTqnsCBAoABwABAQiWOgApID0ABAoAAA==.丶孀刄:AwAFCAQABAoAAA==.丶小瓶子丶:AwAGCAYABRQCCAAGAQhpAQAuZIcBBRQACAAGAQhpAQAuZIcBBRQAAQkAMzEICAQABRQ=.丶死鬼:AwACCAIABRQAAA==.丶猫九:AwAFCAoABAoAAA==.为啥玩个萨满:AwAECAYABAoAAA==.',['�']='之妤:AwADCAMABRQAAA==.书花婉清:AwAGCAEABAoAAA==.书花怡红:AwAICJkABAoCBAAIAQiiCABXmH8CBAoABAAIAQiiCABXmH8CBAoAAA==.书花梦蝶:AwAICA0ABAoAAA==.',['�']='二等小饼干:AwAICAgABAoAAA==.井芹仁菜:AwADCAgABRQDCgADAQgcHwBLSKcABRQACgACAQgcHwBItacABRQACwACAQitDgBHpaQABRQAAA==.',['�']='仇地:AwACCAIABAoAAA==.仙峰寺小王:AwADCAwABRQCDAADAQiSBABKmBcBBRQADAADAQiSBABKmBcBBRQAAA==.',['�']='伈里侑術:AwAFCAUABAoAAA==.优秀小学生:AwAFCAkABAoAAA==.',['�']='侍尘:AwAECAQABRQAAA==.',['�']='傲天:AwADCAMABRQAAA==.',['�']='兜兜有毒药:AwAICBIABAoAAA==.全聚德:AwACCAIABAoAAA==.',['�']='冰见晶:AwAICBQABAoCDQAIAQhlEwBErjMCBAoADQAIAQhlEwBErjMCBAoAAA==.',['�']='凝辰幻月:AwAECAQABRQAAA==.',['�']='加尔鲁神:AwABCAEABRQCDgAIAQhFJAA1W+QBBAoADgAIAQhFJAA1W+QBBAoAAA==.',['�']='勇气之霎:AwAECAQABAoAAA==.',['�']='北原雪菜:AwADCAcABRQCDgADAQgwDwAZ7OUABRQADgADAQgwDwAZ7OUABRQAAA==.匹格:AwAFCAUABAoAAA==.',['�']='十剑來十:AwAECAQABRQAAA==.午夜撸键盘:AwAECAQABRQAAA==.半醒迷糊着:AwAGCAUABRQCAQAFAQiFBAA/W20BBRQAAQAFAQiFBAA/W20BBRQAAA==.',['�']='可以吃土豆嘛:AwAFCAUABAoAAA==.',['�']='吻之觞:AwAFCAUABAoAAA==.',['�']='咪咪喵喵:AwACCAMABRQCDwAIAQgFAwBancoCBAoADwAIAQgFAwBancoCBAoAAA==.',['�']='哆尔哆:AwACCAIABRQAAA==.哥哥好厉害:AwAGCAYABAoAAA==.哥哥怀里好暖:AwAECAcABRQDEAAEAQjnAwBemTUBBRQAEAAEAQjnAwBemTUBBRQAEQABAQg4HQAK3DIABRQAAA==.',['�']='因幡巡:AwACCAIABAoAAA==.',['�']='地狱丨男爵:AwACCAQABRQAAA==.',['�']='增强真强:AwADCAMABAoAAA==.',['�']='夏娜:AwAICAgABAoAAA==.夜孤尘:AwAECAQABRQAAA==.天启:AwAFCAcABAoAAA==.天意之秋:AwAGCAsABAoAAA==.天璇:AwACCAMABRQAARIAAAAECAQABRQ=.天选之女:AwACCAIABRQAAA==.太阳丶:AwAGCAgABRQCAwAEAQhpCgAvOsUABRQAAwAEAQhpCgAvOsUABRQAARIAAAAICAEABRQ=.太阳神:AwAGCBIABAoAAA==.',['�']='奇利亚斯:AwAFCAUABAoAAA==.奕凉:AwAECAQABRQAAA==.奶牛一只:AwAECAQABRQAAA==.',['�']='宁缺:AwADCAgABRQDBgADAQj+HwAjHl4ABRQABgACAQj+HwAfkF4ABRQABwABAQjBFgAqOkwABRQAAA==.安室白:AwADCAEABAoAAA==.审判者地回忆:AwAHCAsABAoAAA==.',['�']='寒风兮兮:AwAECAQABRQAARIAAAAGCAQABRQ=.',['�']='封不觉丨:AwAECAQABRQAAA==.小小瞇糊:AwAFCAgABAoAAA==.小德德鲁:AwACCAIABAoAAA==.小护士:AwABCAIABRQDEwAIAQiGFAA7nPMBBAoAEwAIAQiGFAA7nPMBBAoAFAAHAQgbCgA8cbYBBAoAAA==.小柚丶:AwAGCAYABAoAAA==.小柠檬丶:AwAECAQABRQAAA==.小洛丽塔:AwAHCAEABAoAAA==.小雷姆丶:AwAICAgABAoAAA==.小鸟游星野:AwADCAgABRQCAgADAQjsBQBPlhUBBRQAAgADAQjsBQBPlhUBBRQAAA==.小鹿:AwADCAoABRQDAQADAQisFgAoReAABRQAAQADAQisFgAoReAABRQAFQABAQgfGgAmLzUABRQAAA==.',['�']='山丘领主:AwAGCAsABAoAAA==.',['�']='岳镇海渎:AwACCAQABRQAAA==.',['�']='巧巧揍巧巧:AwABCAEABRQAAA==.巴巴牛:AwACCAIABRQAAA==.',['�']='希尔瓦丶酸奶:AwADCAUABRQCFgADAQgGDgATUGYABRQAFgADAQgGDgATUGYABRQAAA==.',['�']='干犯人:AwAICAgABAoAAA==.幽幽子:AwADCAYABRQDFQADAQhEAQBYITQBBRQAFQADAQhEAQBYITQBBRQAAQABAQiALgA3bUwABRQAAA==.',['�']='影竹:AwAECAoABRQCDQAEAQhvBgBEPxYBBRQADQAEAQhvBgBEPxYBBRQAAA==.',['�']='御嶽海:AwAFCAMABAoAAA==.',['�']='快点长高:AwAECAgABRQCFwAEAQjkCwBLmhABBRQAFwAEAQjkCwBLmhABBRQAAA==.',['�']='慕斯:AwABCAEABAoAAA==.慕烟奕暖:AwACCAIABRQAAA==.',['�']='成都:AwAECAgABRQDFQAEAQiYBQBAg+wABRQAAQAEAQjLEAA+DfQABRQAFQAEAQiYBQA9jOwABRQAAA==.我哈哈:AwAFCAUABAoAAA==.戰神丶:AwAICA0ABAoAAA==.',['�']='救世星龙:AwADCAgABRQDEwADAQhcBQBGGBEBBRQAEwADAQhcBQBGGBEBBRQAFAACAQhPBABORKEABRQAAA==.',['�']='新堂愛:AwAECAQABAoAAA==.',['�']='早睡早起:AwABCAEABRQAAA==.',['�']='暗之忧伤:AwAICAgABAoAAA==.',['�']='有死骑选死骑:AwAECAMABRQAAA==.朝岚夕雨:AwADCAgABRQCCQADAQigCAA+UfwABRQACQADAQigCAA+UfwABRQAAA==.朝武芳乃:AwADCAgABRQCAwADAQgkBwBEYfEABRQAAwADAQgkBwBEYfEABRQAAA==.',['�']='杀生术:AwAFCAYABAoAAA==.李小浪:AwACCAIABAoAAA==.李敏:AwAGCAYABAoAAA==.',['�']='果丹皮:AwACCAIABRQAAA==.果冻的默默:AwAECAQABRQAAQ0AQnAHCAwABRQ=.',['�']='柔情似淼:AwACCAIABRQAAA==.',['�']='栉枝实乃梨:AwADCAgABRQDDAADAQiTCwASCbkABRQADAADAQiTCwASCbkABRQADQACAQjoHQAD+GIABRQAAA==.',['�']='桃乐丝:AwADCAgABRQCAQADAQhHEgA3Ne4ABRQAAQADAQhHEgA3Ne4ABRQAAA==.桥倒麻袋:AwAGCAYABAoAAA==.',['�']='梦璃夜天星:AwADCAcABRQDEAADAQj+EQBbSdwABRQAEAACAQj+EQBeINwABRQAEQACAQjCBwBeMdMABRQAAA==.梦里知花落:AwAECBAABRQDDgAEAQj/AwBZyzUBBRQADgAEAQj/AwBZyzUBBRQAGAAEAQi3AwA9gAQBBRQAAQ4AMEsGCAcABRQ=.',['�']='樱岛麻衣:AwACCAIABRQAAA==.',['�']='橙欣:AwACCAIABAoAAA==.橙醉:AwACCAIABAoAARIAAAAGCBIABAo=.',['�']='水渺渺:AwACCAIABRQAAA==.',['�']='沁血之靈:AwADCAMABAoAAA==.沫紫:AwACCAUABRQCFwACAQjfLgAdboYABRQAFwACAQjfLgAdboYABRQAAA==.',['�']='泉此方:AwAECAQABRQAAA==.泉水牛牛:AwADCAoABRQDGQADAQiQCQA9G/QABRQAGQADAQiQCQA9G/QABRQAGgABAQjrGAAGKi0ABRQAAA==.法力值不足:AwACCAIABAoAAA==.',['�']='洁世一:AwADCAcABRQCFwADAQgJDABHDhABBRQAFwADAQgJDABHDhABBRQAAA==.洋明的小胖花:AwAICBUABAoDAgAIAQieCQBY/70CBAoAAgAIAQieCQBY/70CBAoAAwAFAQjrIgBHGkMBBAoAAA==.活力:AwAECAUABRQCGwAEAQgIBwA2WAABBRQAGwAEAQgIBwA2WAABBRQAARIAAAAICAQABRQ=.',['�']='浅葱:AwADCAYABRQDBwADAQj+CQBaILwABRQABwACAQj+CQBXfLwABRQABgABAQiuHQBfZ24ABRQAARIAAAAICAQABRQ=.浓郁拿铁:AwAICAgABAoAAA==.',['�']='清荷丷拾酒:AwACCAUABRQDHAACAQh9AAAKZ1UABRQAHAACAQh9AAAKZ1UABRQAEwABAQi6GgAErSkABRQAAA==.',['�']='潶色記憶:AwAICAgABAoAAA==.',['�']='灬犇仔:AwACCAIABRQAAA==.灬番薯灬:AwAGCAYABAoAAA==.',['�']='热疯了:AwAGCAUABRQCCQAFAQikAwAtJEsBBRQACQAFAQikAwAtJEsBBRQAAA==.',['�']='爱撕:AwACCAQABRQAAA==.',['�']='玖姑娘:AwADCAMABRQAAA==.',['�']='理想与你想:AwABCAEABAoAAA==.',['�']='生如灬夏花:AwAGCAgABAoAAA==.',['�']='疯不觉:AwAECAQABRQAAA==.',['�']='盾娘也很萌:AwAECAgABRQDAwAEAQiUBABT1CABBRQAAwAEAQiUBABT1CABBRQAAgAEAQh7CgA3//QABRQAAA==.',['�']='真幽兔无双:AwAICBUABAoDEAAIAQhtMAA9y8oBBAoAEAAIAQhtMAA9y8oBBAoAEQACAQg6agAOtlQABAoAAA==.',['�']='破镜菲尔:AwAGCAgABRQCHQAGAQjBAABLFfQBBRQAHQAGAQjBAABLFfQBBRQAAA==.',['�']='碎蜂:AwAICAIABAoAAA==.',['�']='神说还有光:AwAGCAkABAoAAA==.',['�']='种痒勤暴菊:AwAGCAQABAoAAA==.秽土转生丶:AwABCAEABRQAAA==.秽翼的缇亚:AwAECAYABRQDHgADAQgZBAA+o/MABRQAHgADAQgZBAA+o/MABRQAFwACAQirJQBAb58ABRQAAA==.',['�']='空丨白:AwAHCBcABAoCAgAHAQjjMwA9FLABBAoAAgAHAQjjMwA9FLABBAoAAA==.空空荡荡:AwAGCAwABAoAAA==.',['�']='竹兰:AwAICBAABAoAAA==.',['�']='筱沁儿:AwACCAIABRQAAA==.',['�']='箭羽苍穹:AwAECAQABRQAAA==.',['�']='米奥莉奈:AwAFCAMABRQAAR0ASxUGCAgABRQ=.',['�']='绪方理奈:AwAECAQABRQAAA==.',['�']='老年练习生:AwAECAQABRQAAQMAY3oICAoABRQ=.',['�']='花椰菜咕咕:AwAHCAQABAoAAA==.',['�']='莫莫伽:AwAECAQABRQAAA==.',['�']='菘菘奶八方:AwAICA8ABAoAAA==.',['�']='萨斯阿萨德:AwAICAgABAoAAA==.',['�']='蜗牛追日:AwAHCA0ABAoAAA==.',['�']='蠢爸爸:AwACCAEABAoAAA==.',['�']='血月影彧:AwAECAYABRQCBgAEAQgPDAA94eEABRQABgAEAQgPDAA94eEABRQAAQYATegICAYABRQ=.血色丨天启:AwACCAIABAoAAA==.',['�']='西野七濑:AwAGCAMABRQDAQAIAQigLQA8cdcBBAoAAQAIAQigLQA2BtcBBAoAFQAGAQjDRgA+NhkBBAoAAA==.',['�']='誓死而归:AwAECAgABAoAAA==.',['�']='豪哥带带我:AwAECAQABRQAAA==.',['�']='辣小羊哎呀呀:AwACCAIABAoAAA==.达维安:AwAGCAEABAoAAA==.',['�']='进击的洋芋粑:AwAFCAgABAoAAR8AU0EECAQABRQ=.进击的牛肉粉:AwADCAgABRQCAwADAQjNCAA6/dgABRQAAwADAQjNCAA6/dgABRQAAR8AU0EECAQABRQ=.迷惘焖蹄:AwAGCBIABAoAAA==.迸裂:AwAGCAcABAoAAA==.',['�']='逍遥无忧:AwACCAMABAoAAA==.',['�']='邪火斩月:AwAECAQABRQAAQIAO04GCBAABRQ=.',['�']='钦钦威震天:AwADCAUABRQDCgADAQj2IgAwUJoABRQACgACAQj2IgA9vJoABRQACwABAQgLGgAVd0MABRQAAA==.钻石吗喽:AwAECAQABRQAAA==.',['�']='铃原露露:AwAECAQABRQAAA==.',['�']='长崎素时:AwAICAgABAoAAA==.',['�']='闪光少女:AwAICAgABAoAARIAAAAECAQABRQ=.问题不大:AwAICAYABAoAAA==.',['�']='阿司匹林:AwAICBEABAoAAA==.',['�']='霸道者:AwABCAEABRQAAA==.',['�']='青果喵喵:AwAFCAUABAoAAA==.青阳:AwAECAQABRQAARIAAAAGCAQABRQ=.',['�']='风鸣翼:AwADCAUABRQCAgADAQhpDwAZL9EABRQAAgADAQhpDwAZL9EABRQAAA==.',['�']='高松灯:AwADCAMABAoAARIAAAAECAQABAo=.高町奈叶:AwAECAQABRQAAA==.',['�']='鬼影忍者:AwAECAEABAoAAA==.',['�']='魔箭士艾希尔:AwAICAgABAoAAA==.',['�']='鹿目圆香:AwAECAQABAoAAA==.鹿衔:AwAECAsABRQDBgAEAQg7CABI/v0ABRQABgAEAQg7CABI/v0ABRQAIAABAQgMDQA8z1IABRQAAA==.',['�']='黑夜静悄悄:AwAFCAUABAoAAA==.黑腕泽法:AwABCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end