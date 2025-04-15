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
 local lookup = {'Rogue-Assassination','Paladin-Retribution','Priest-Holy','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Vengeance','DemonHunter-Havoc','Shaman-Enhancement','Unknown-Unknown','DeathKnight-Blood','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Mage-Fire','Mage-Frost','Rogue-Subtlety','Priest-Discipline','Warrior-Fury','Druid-Balance','Shaman-Elemental','Paladin-Holy','DeathKnight-Frost','Paladin-Protection','Druid-Guardian','Monk-Mistweaver','Druid-Feral','Druid-Restoration','Monk-Windwalker','Monk-Brewmaster','Shaman-Restoration','Warrior-Protection',}; local provider = {region='CN',realm='诺莫瑞根',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ag='Agnesrei:AwABCAEABAoAAA==.',Ar='Arcy:AwAICAgABAoAAA==.Arigakki:AwABCAIABRQCAQAIAQjKBwBWVnsCBAoAAQAIAQjKBwBWVnsCBAoAAA==.Artiz:AwAECAQABRQAAQIATYsGCAoABRQ=.',Au='Augustrush:AwABCAEABAoAAA==.',Bl='Bland:AwAECAcABRQDAwAEAQiIDwBNzZsABRQAAwADAQiIDwBCzJsABRQABAABAQg1HwAYNEkABRQAAA==.',Co='Concrete:AwABCAIABRQDBQAIAQhYHwBO9WcCBAoABQAIAQhYHwBOhGcCBAoABgADAQivQgBJl9YABAoAAA==.',Du='Duoqii:AwAECAQABRQAAA==.',Er='Erxat:AwAICAgABAoAAA==.Eryrtyertu:AwAECAQABAoAAA==.',Gu='Gustaa:AwABCAEABAoAAA==.',In='Insideme:AwAECAMABAoAAA==.',Ju='Jussipussi:AwAGCBsABAoDBwAGAQi+FwBPA6MBBAoABwAGAQi+FwBPA6MBBAoACAAFAQhTYgAqvPoABAoAAA==.',Le='Lesliedhy:AwAECAQABRQAAQkARZsICAUABRQ=.',Ma='Makima:AwAICAgABAoAAA==.Matthewss:AwAECAQABRQAAA==.',Na='Narru:AwABCAEABAoAAA==.',Ne='Neekoo:AwAICAEABAoAAA==.',Oa='Oaa:AwAICAgABAoAAA==.',Pa='Palpitate:AwEICAgABAoAAQoAAAAICAMABRQ=.',Pe='Perunu:AwAGCAYABAoAAA==.',Pr='Pride:AwABCAEABRQAAA==.',Pu='Purity:AwABCAEABRQAAA==.',Sh='Shalom:AwAECAQABRQAAA==.',Sy='Sylphid:AwAECAYABRQCCwAEAQhpDAAzOL8ABRQACwAEAQhpDAAzOL8ABRQAAA==.',Te='Terminal:AwAECAQABRQAAA==.',Za='Za:AwABCAIABRQAAA==.Zalr:AwAICA8ABAoAAA==.Zaqs:AwAGCAYABAoAAA==.',['�']='一杯冻柠七:AwAICCkABAoCAgAIAQgiIABS1ocCBAoAAgAIAQgiIABS1ocCBAoAAA==.一神二坑:AwAECAgABRQCCAAEAQjwDQA/W/gABRQACAAEAQjwDQA/W/gABRQAAA==.万梦成空:AwAHCAcABAoAAA==.万生春雷:AwABCAEABAoAAA==.三七五陆:AwACCAQABRQAAA==.三五共盈盈:AwADCAMABAoAAA==.三分线滑铲:AwACCAIABAoAAA==.不变的回忆:AwABCAIABRQAAA==.不見:AwAECAQABRQAAA==.丑的无语:AwAECAEABRQEDAAIAQiZEQA6J1IBBAoADAAFAQiZEQBP8VIBBAoADQAFAQhPTAA3NRwBBAoADgAEAQjkOQAs5cEABAoAAQ0ATegICAYABRQ=.丨凌凌漆丨:AwAICAgABAoAAA==.个头矮矮的:AwADCAMABAoAAA==.丶江阿生丶:AwABCAEABRQCDwAIAQi1GABK31ACBAoADwAIAQi1GABK31ACBAoAAA==.丶法仙:AwAGCAcABRQDEAAGAQhVAwA5hbIBBRQAEAAGAQhVAwA5hbIBBRQAEQABAQheHQAYzTEABRQAAA==.丶贼爷:AwACCAcABRQCEgACAQiGCQBMRr0ABRQAEgACAQiGCQBMRr0ABRQAAA==.丹妮莉丝丨:AwABCAEABAoAAA==.丽贝卡丶阳炎:AwAECAQABRQAAA==.',['�']='乌瑞恩之力:AwAICAgABAoAAA==.',['�']='二龙:AwAICBAABAoAAA==.五竹哟:AwABCAEABAoAAA==.亚德炎:AwAECAQABAoAAA==.亡神啊:AwAGCAYABRQCEwAGAQjOAABJ5toBBRQAEwAGAQjOAABJ5toBBRQAAA==.人蛋超咸:AwAICAQABAoAAA==.',['�']='伊利玬丨怒风:AwADCAwABRQDCAADAQiLGAAUNMgABRQACAADAQiLGAAUNMgABRQABwABAQgJGAACDh8ABRQAAA==.伊犁單:AwADCAMABAoAAA==.会飞的牛:AwABCAEABRQAAA==.',['�']='佛丁萨:AwAICAYABAoAAA==.你到底想怎样:AwAICAUABAoAAA==.你在终点等我:AwACCAIABAoAAA==.佩顿尚未:AwAECAMABAoAAA==.佳芝酱酱丶:AwABCAEABRQCBwAIAQioEABCs/oBBAoABwAIAQioEABCs/oBBAoAAA==.',['�']='元气丸子:AwAGCBMABAoAAA==.兕觥:AwAGCAcABAoAAA==.八分中年:AwAECAQABRQAAA==.养猫的小小鱼:AwACCAIABAoAAA==.',['�']='冷艳的姬拉:AwACCAIABRQAAA==.',['�']='凛冬寒风:AwAGCAgABAoAAA==.凯瑟琳纳:AwABCAEABRQAAA==.凶猛变态男:AwACCAYABRQCCAACAQgIHAA/OKgABRQACAACAQgIHAA/OKgABRQAAA==.',['�']='别奶了速度死:AwADCAMABAoAAA==.别撬后盖:AwAECAQABRQAAQoAAAAGCAQABRQ=.',['�']='劍与詩:AwACCAIABAoAAA==.加班暴徒:AwACCAIABAoAAA==.加班狗儿:AwAECAQABRQAAA==.动若脱兔:AwABCAEABAoAAA==.',['�']='单脚闯天涯:AwACCAQABRQAAA==.',['�']='双花橙棍:AwACCAIABAoAAA==.双花红棍:AwAGCAwABAoAAA==.可萌可猛:AwACCAIABRQEAwAIAQgGBgBcX6UCBAoAAwAIAQgGBgBXH6UCBAoABAAGAQg+LQA3LlABBAoAEwADAQiHMgBbnTUBBAoAAA==.叽叽糯糯:AwAFCAUABAoAAA==.',['�']='呜啊呜:AwAGCAYABAoAAA==.',['�']='咏渊:AwADCAMABAoAAA==.咪绮喵喵武:AwAECAQABRQAAA==.咸鱼王:AwAICAgABAoAAA==.',['�']='哔哩哔:AwAICAgABAoAAA==.哼歌听想念:AwAHCAEABAoAAA==.',['�']='啊浪老师:AwAECBEABRQCFAAEAQgPBABY2zwBBRQAFAAEAQgPBABY2zwBBRQAAA==.啸天之龙鹰:AwAECAIABRQAARUARVEHCAcABRQ=.',['�']='喝喝茶吃饭:AwAGCAYABAoAAA==.',['�']='嘘蛐灬为零:AwAICBsABAoDDgAIAQj7BgBI+k8CBAoADgAIAQj7BgBHf08CBAoADQACAQjDkwBEBkwABAoAAA==.',['�']='噗哒嘻:AwACCAIABAoAAA==.',['�']='回首梦已逝:AwAICAoABAoAAA==.团灭杀手:AwAICA0ABAoAAA==.',['�']='圈叉圈叉:AwACCAIABAoAAA==.土豆饼:AwACCAIABAoAAA==.圣光窃贼:AwACCAIABAoAAA==.圣光背叛我丶:AwAHCBEABAoAAA==.圣女:AwAECAQABRQAAA==.',['�']='夜孤泥:AwACCAIABAoAAA==.夜月之光:AwAHCAsABAoAAA==.夜终焉:AwAGCAgABAoAAA==.大头傻馒丶:AwAECAYABRQCFgAEAQhlBQBQBfsABRQAFgAEAQhlBQBQBfsABRQAAA==.大审判者:AwAECAQABRQAAA==.大橘猫:AwAICBUABAoDDwAIAQjtRgArP28BBAoADwAHAQjtRgAtYW8BBAoACwAEAQgwRQAYRYQABAoAAA==.大浪:AwAICAkABAoAARQAWNsECBEABRQ=.大王恋泰妍:AwABCAEABRQAAA==.大王爱泰妍:AwAGCAIABRQAAA==.大黄来咯:AwAECAQABRQAAA==.天好黑黑:AwACCAEABAoAAA==.天妒木木:AwAICBAABAoAAA==.天灾:AwAICAoABAoAAA==.',['�']='奥妮克希蕥:AwAICBMABAoAAA==.奧妮克希娅:AwAICAsABAoAAA==.',['�']='如梦曾梦丶:AwAGCAYABAoAAA==.',['�']='姐曾是联盟:AwAHCBEABAoAAA==.',['�']='娜尔梅亚:AwAICBYABAoDDQAIAQgfKQAyMcIBBAoADQAIAQgfKQAyMcIBBAoADgACAQjiWgAUuFEABAoAAA==.',['�']='嫩蹄:AwAECAQABRQAARcAQFsGCAYABRQ=.',['�']='子青:AwABCAEABRQAAA==.孤独的老人:AwAGCAoABAoAAA==.孩歌:AwADCAMABAoAAA==.',['�']='安度因:AwAECAQABAoAAA==.宋哈娜啊:AwABCAIABRQDDwAIAQjnCwBcFbACBAoADwAIAQjnCwBaVLACBAoAGAAFAQg1EgBIGU4BBAoAAA==.宸极:AwAGCAcABAoAAA==.',['�']='对你放电:AwAICAYABAoAAA==.',['�']='小不点多多:AwAFCAoABAoAAA==.小丶浣熊:AwACCAIABRQAAA==.小小文的镜子:AwAGCA0ABRQDBQAGAQj7AABRAesBBRQABQAGAQj7AABRAesBBRQABgACAQjlFQBAh3wABRQAAA==.小恶魔时樱:AwADCAUABRQCCAADAQg2GgAPPbkABRQACAADAQg2GgAPPbkABRQAAA==.小松:AwAICAgABAoAAA==.小枣圆圆:AwADCAMABAoAAA==.小浪:AwAFCAUABAoAARQAWNsECBEABRQ=.小荷尖角:AwACCAMABRQAAA==.小锥锥:AwAICBAABAoAAA==.小雷斯林的萨:AwACCAIABRQAAA==.小雷斯林的黯:AwAGCAYABAoAAQoAAAACCAIABRQ=.小鸟展翅:AwAGCA0ABAoAAA==.小鹅心心:AwACCAIABRQAAA==.',['�']='工工:AwACCAUABRQCGQACAQjoEwAA6TQABRQAGQACAQjoEwAA6TQABRQAAA==.巴拉巴拉:AwAFCAUABAoAAA==.',['�']='布蘭莉婭:AwAICAcABAoAAA==.',['�']='干俊:AwAICAYABAoAAQ0ASDIGCAUABRQ=.幽黯業火:AwACCAIABRQDDQAGAQh/SQAwPSgBBAoADQAGAQh/SQAwPSgBBAoADgABAQhvbAASYysABAoAAA==.',['�']='库拉:AwABCAEABRQAAA==.',['�']='开心一生:AwACCAIABRQAAA==.开花富贵:AwAGCAgABAoAAA==.弑神之龙猎:AwADCAUABAoAAA==.弗兰克酱酱丶:AwABCAEABRQAAQcAQrMBCAEABRQ=.张震:AwABCAEABAoAAA==.',['�']='彼夏伊始:AwADCAcABRQDDQADAQiZCABLOAIBBRQADQADAQiZCABLOAIBBRQADgABAQhpEgAoEEgABRQAAA==.彼岸烟火:AwAECAQABRQAAA==.',['�']='心心向荣:AwACCAUABRQCGgACAQhjBQADdjsABRQAGgACAQhjBQADdjsABRQAAA==.快乐水:AwAECAQABRQAAA==.念昔:AwADCAQABAoAAA==.',['�']='怕是要翻水水:AwAECAQABRQAAA==.怕是要翻血血:AwAGCAYABRQCCwAGAQhgAwAkZ0IBBRQACwAGAQhgAwAkZ0IBBRQAAA==.',['�']='恋音雨空:AwAECAQABRQDAwAIAQhFIAA457sBBAoAAwAIAQhFIAA457sBBAoABAAFAQhdRQAfzbwABAoAAA==.恶魔双刃:AwACCAIABAoAAA==.',['�']='惘然酸奶:AwAHCAoABAoAAA==.惡靈:AwAICBYABAoCDQAIAQgnGgBOThgCBAoADQAIAQgnGgBOThgCBAoAAA==.惩戒山:AwABCAEABAoAAA==.想不出名字:AwACCAIABRQAAQoAAAAFCAEABRQ=.',['�']='愛木梯:AwACCAIABAoAAA==.愛綺舞:AwAICAsABAoAAA==.',['�']='慈父:AwAECA0ABRQDCAAEAQgxBABioVIBBRQACAAEAQgxBABioVIBBRQABwAEAQhsBwAnJ7kABRQAAQoAAAAICAQABRQ=.',['�']='我可耻的从了:AwACCAIABAoAAA==.我就爱贝贝:AwABCAEABRQAAA==.我开怪了哦:AwAICAgABAoAAA==.我心向北:AwAICBUABAoCGwAIAQi2IAA3wtEBBAoAGwAIAQi2IAA3wtEBBAoAAA==.我来负责发炎:AwACCAEABAoAAA==.我的比他的好:AwAICBEABAoAAA==.我躺着咋了嘛:AwAICAgABAoAAA==.战神丶阿瑞斯:AwAECAcABAoAAA==.戴利爱丽:AwAECAQABRQAAA==.',['�']='手残萌新:AwADCAMABAoAAA==.',['�']='掏包包呢牛:AwAGCAYABAoAAA==.',['�']='擎兽乱射:AwAGCAYABRQCBQAGAQg3AQA8ZdsBBRQABQAGAQg3AQA8ZdsBBRQAAA==.',['�']='斩部落无双剑:AwAGCAgABAoAAA==.断桥殘雪:AwAFCAoABAoAAA==.',['�']='旋律的风:AwAICBYABAoCBQAIAQgmKgBDcjYCBAoABQAIAQgmKgBDcjYCBAoAAA==.无为歧路:AwABCAEABRQAAA==.无赖无奈:AwAFCAYABAoAAA==.无险一惊:AwAECAUABAoAAA==.',['�']='昂狗:AwAICAgABAoAAA==.明天更漫长:AwAGCAoABRQCBAAGAQhGAQA9sMoBBRQABAAGAQhGAQA9sMoBBRQAAA==.星橙牛:AwABCAEABRQDHAAIAQgfBwA/NUcCBAoAHAAIAQgfBwA/NUcCBAoAHQABAQiVegAegjEABAoAAA==.春哥是好人:AwABCAEABRQDEgAGAQgxHwAtXxYBBAoAEgAGAQgxHwAjQhYBBAoAAQAFAQhZLQArJ7wABAoAAA==.',['�']='暗青:AwABCAEABAoAAA==.暗黑勾魂者:AwAECAYABRQCBQAEAQjsCABXxCYBBRQABQAEAQjsCABXxCYBBRQAAA==.暴走的生菜:AwAICBoABAoDHgAIAQi4KwAnPWgBBAoAHgAHAQi4KwAtnGgBBAoAHwAEAQgwIAAMAUQABAoAAA==.',['�']='最后的丶风度:AwABCAIABRQAAA==.會飛的牛:AwAHCAcABAoAAA==.月半故事:AwAICAIABAoAAA==.月狼东东:AwACCAYABRQDBgACAQgFFwAl6XEABRQABgACAQgFFwAbDXEABRQABQABAQghPAAuU0gABRQAAA==.有苦難言灬:AwAECAgABRQCFAAEAQj5CgA7CQQBBRQAFAAEAQj5CgA7CQQBBRQAAA==.术一士小安妮:AwABCAEABRQCIAAIAQgiKgA3HsQBBAoAIAAIAQgiKgA3HsQBBAoAAA==.',['�']='柑橘汁:AwAECAQABRQAAQUAKokICAIABRQ=.',['�']='桌子很滑的啦:AwABCAEABAoAAA==.',['�']='梅亦饶:AwAECAQABRQAAA==.梦魂归帝所:AwABCAEABAoAAA==.',['�']='樱灬桃桃:AwAICAoABAoAAA==.',['�']='橘子汁儿:AwAECAQABRQAAA==.',['�']='欣赏我的坏:AwAECAQABRQAAA==.欧皇一派:AwABCAEABAoAAA==.欧皇太一:AwABCAEABAoAAA==.',['�']='正经人:AwAECAUABRQCIAAEAQh0DAAzH+wABRQAIAAEAQh0DAAzH+wABRQAAA==.死骑杀手:AwAICAUABAoAAA==.',['�']='毁灭幽灵:AwAGCAQABRQCEQACAQjDDgAuSY0ABRQAEQACAQjDDgAuSY0ABRQAAA==.毁灭恶灵:AwAICAgABAoAAA==.',['�']='水瞎:AwACCAIABRQAAA==.氵水法:AwABCAEABRQAAA==.永恒冰冻:AwABCAEABAoAAA==.',['�']='求求暖娇躯:AwABCAIABRQDDwAIAQiYKAA/GvIBBAoADwAIAQiYKAA/GvIBBAoACwABAQgcYAAReCAABAoAAA==.求求暖床被:AwAECAQABAoAAA==.',['�']='沐露术风:AwACCAYABRQEDQACAQg3GgA80Y4ABRQADQACAQg3GgA80Y4ABRQADgABAQgcEQA7fEwABRQADAABAQjjGAAixUoABRQAAA==.沫舒沫:AwAECAQABAoAAA==.',['�']='泡沬:AwACCAYABRQCBgACAQhJEwAxWo8ABRQABgACAQhJEwAxWo8ABRQAAA==.',['�']='流氓神棍:AwAGCAoABAoAAA==.浅夏尣折戟:AwACCAQABRQCFAAIAQgNHAA6px0CBAoAFAAIAQgNHAA6px0CBAoAAA==.浅夏尣滚滚:AwACCAIABRQAAA==.浮光掠影:AwACCAUABRQDDgACAQjTBwAWVIQABRQADgACAQjTBwAU44QABRQADQACAQi7KQAJcD8ABRQAAA==.',['�']='涅磐緟笙:AwAICAgABAoAAA==.',['�']='清梦压星河:AwABCAEABAoAAA==.渊韵:AwADCAYABAoAAA==.渔火火:AwABCAEABAoAAA==.',['�']='溪谷:AwAFCAcABAoAAA==.',['�']='漆黑前奏曲:AwAGCAYABRQDDwACAQjCEwBWa70ABRQADwACAQjCEwBWa70ABRQACwABAQiQHQAvzTkABRQAAA==.',['�']='火焰法師:AwAICAgABAoAAA==.灵宗传令:AwAGCAgABAoAAA==.',['�']='烟雨缥缈:AwAECAQABAoAAA==.',['�']='燕十二:AwABCAEABAoAAA==.',['�']='父之名:AwAICAgABAoAAA==.',['�']='牛牛是牛:AwABCAEABRQAAA==.牧星:AwABCAIABRQDHAAIAQhaBQBNSXMCBAoAHAAIAQhaBQBNSXMCBAoAHQACAQiniAABhhcABAoAAA==.',['�']='犇犇壮壮的:AwAECAQABAoAAA==.犹豫就会败北:AwACCAIABAoAAA==.',['�']='狂怒的拳头:AwAICAgABAoAAA==.狐假魔暴龙威:AwADCAUABRQCBQADAQiFGQAq49wABRQABQADAQiFGQAq49wABRQAAA==.狐斐:AwAICAgABAoAAA==.',['�']='猛汗:AwAECAQABRQAAA==.猴皮筋大王:AwAICAgABAoAAA==.',['�']='王富貴丶:AwACCAQABAoAAA==.',['�']='琪思妙想:AwAGCAYABAoAAA==.',['�']='生气的榴莲丶:AwACCAIABAoAAQoAAAAGCAYABAo=.画乱琴弦断:AwAECAQABAoAAA==.',['�']='疵头刮脑:AwACCAUABRQCEAACAQgxKgAbkYgABRQAEAACAQgxKgAbkYgABRQAAA==.',['�']='神乐舞耶:AwAGCAgABAoAAA==.神嘎嘎:AwABCAEABRQAAA==.',['�']='秒不死你算输:AwADCAQABAoAAA==.',['�']='空白的三年:AwACCAMABRQCBQAIAQgvKgBD9jYCBAoABQAIAQgvKgBD9jYCBAoAAA==.',['�']='第三場雪:AwADCAMABAoAAQoAAAAICAQABRQ=.',['�']='簏先生:AwAICBoABAoCBQAIAQg+NAA4lgoCBAoABQAIAQg+NAA4lgoCBAoAAA==.',['�']='米米:AwAICA0ABAoAAA==.',['�']='糯糯叽叽:AwAFCAQABAoAAA==.',['�']='红尘仙:AwAFCAUABAoAAA==.',['�']='结伴同行:AwACCAMABRQCBwAHAQhASgAHcnEABAoABwAHAQhASgAHcnEABAoAAA==.',['�']='美味大粉薯:AwABCAEABAoAAA==.美墅:AwAFCAkABAoAAA==.羽衣若空:AwAFCAMABAoAAA==.',['�']='翱翔九天:AwADCAQABAoAAA==.',['�']='老九:AwACCAIABRQCIQAIAQhVJAAKlbQABAoAIQAIAQhVJAAKlbQABAoAAA==.老傅:AwAGCAYABAoAAA==.老戴:AwAICBcABAoCHAAIAQh6BgBIElgCBAoAHAAIAQh6BgBIElgCBAoAAA==.老洗浴:AwAICAYABAoAAA==.老酒爷:AwACCAMABRQAAA==.',['�']='聋龙:AwAFCAUABAoAAA==.',['�']='胖潘达:AwACCAIABRQAAA==.胖达熊:AwABCAEABRQAAA==.胜锦:AwACCAIABAoAAA==.',['�']='舒沫沫:AwAFCAUABAoAAA==.',['�']='艾德丝:AwAICAgABAoAAA==.艾萨克牛顿:AwAGCAYABRQCCwAGAQiNAgAnGVEBBRQACwAGAQiNAgAnGVEBBRQAAA==.',['�']='苏幕遮:AwABCAEABAoAAA==.苏洛北春:AwAICAgABAoAAA==.',['�']='莉亚德雅:AwAECAQABRQAAA==.',['�']='萧羽良:AwAECAQABAoAAA==.',['�']='蓝若雪:AwAECAQABRQAAA==.',['�']='蛮王玛丽:AwADCAMABAoAAA==.',['�']='蜜糖丶果果:AwAGCAYABAoAAA==.',['�']='血兽别炸之术:AwAECAQABRQAAA==.血染的星辰:AwAFCAUABAoAAA==.',['�']='说怿女美:AwABCAEABAoAAA==.',['�']='谢夫涅:AwAICAgABAoAAA==.谢耳朵:AwAECAQABRQAARAAMkEGCAgABRQ=.',['�']='贱儿饭:AwAGCAcABRQCCAAGAQgLAQBFV+sBBRQACAAGAQgLAQBFV+sBBRQAAA==.贼密斯:AwAECAsABRQCAQAEAQhUBABXpBQBBRQAAQAEAQhUBABXpBQBBRQAAA==.',['�']='起名叫王康:AwAECAQABAoAAA==.',['�']='趴趴熊丶丶:AwABCAIABRQCHQAIAQjyAwBcIcMCBAoAHQAIAQjyAwBcIcMCBAoAAA==.',['�']='跟风混子:AwABCAEABAoAAA==.',['�']='轻薄的假像:AwAECAgABRQDEQAEAQhqBwBKAt8ABRQAEQAEAQhqBwBKAt8ABRQAEAAEAQgEHAAcGtQABRQAAQoAAAAGCAQABRQ=.',['�']='远坂家的凛:AwAFCAMABAoAAA==.迷失在春的雪:AwACCAIABRQAAA==.迷途丶:AwAECAQABRQAAQoAAAAICAEABRQ=.',['�']='速冻滚滚:AwAICBsABAoCGwAIAQjTOAAb10oBBAoAGwAIAQjTOAAb10oBBAoAAA==.',['�']='酒桶之光:AwADCAMABAoAAA==.酷的一派:AwAECAgABRQDBgAEAQjSAgBTyCMBBRQABgAEAQjSAgBTyCMBBRQABQAEAQiJDwBIJQMBBRQAAA==.酷的无语:AwABCAEABRQAAA==.酸菜狗:AwACCAEABRQAAA==.',['�']='钱小钱:AwAICBEABAoAAA==.',['�']='铜锣湾话事人:AwAICAYABAoAAA==.',['�']='错就错了:AwAFCAUABAoAAA==.',['�']='长毛猴:AwAFCAUABAoAAA==.',['�']='阿七天才啊:AwABCAIABRQAAA==.阿尼马格斯:AwAECAQABRQAAR0APyYICAsABRQ=.阿布夏:AwAGCAYABAoAAA==.阿赧呀:AwABCAEABRQAAA==.',['�']='陈家驹:AwAECAIABRQAAA==.陈浩南灬:AwADCAIABRQAAQoAAAAGCAIABRQ=.陌小泪:AwABCAEABRQAAA==.',['�']='隐锋:AwACCAUABRQDFQACAQiyIgAWjIIABRQAFQACAQiyIgAWjIIABRQAHAABAQhICQACix4ABRQAAA==.隔壁熊大姐:AwAHCAcABAoAAA==.',['�']='雨夜复仇者:AwAICAgABAoAAA==.雪白的小李:AwADCAMABAoAAA==.雷一样的心:AwACCAIABAoAAA==.',['�']='青椒小炒肉:AwAICAgABAoAAA==.静夜思幽星:AwAECAEABRQAAA==.非是:AwABCAEABRQAAA==.',['�']='颅献颅座:AwABCAEABRQAAA==.颠覆你的心:AwAFCAUABAoAAA==.',['�']='风嫂小蛮腰:AwAECAQABRQAAA==.风骚小蛮腰:AwACCAUABRQCCAACAQjSIQAhW4sABRQACAACAQjSIQAhW4sABRQAAA==.飞天笑:AwADCAgABAoAAA==.',['�']='高興:AwABCAEABRQDCQAIAQg4FgA2FwcCBAoACQAIAQg4FgA2FwcCBAoAIAAIAQj/PQAjmm4BBAoAAA==.',['�']='鱼骨头:AwADCAUABAoAAA==.',['�']='黑手总教官:AwAGCAQABRQAAA==.黑板擦:AwABCAEABRQAAA==.默燃:AwAICAwABAoAAA==.黯神伤:AwAECAQABRQAAA==.',['�']='龙泽诺拉:AwACCAIABAoAAA==.龙飞:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end