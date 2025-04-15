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
 local lookup = {'Unknown-Unknown','DeathKnight-Blood','Shaman-Enhancement','Paladin-Retribution','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Frost','Shaman-Restoration','Priest-Discipline','Mage-Frost','Warrior-Fury','Warlock-Destruction','Priest-Holy','Evoker-Devastation','Evoker-Preservation','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Shadow','Warrior-Arms',}; local provider = {region='CN',realm='斩魔者',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Annyy:AwAHCAcABAoAAA==.',Bi='Bigboss:AwAECAIABRQAAA==.',Bl='Blastories:AwAICAgABAoAAA==.',Co='Converter:AwAICAcABAoAAQEAAAAECAMABRQ=.',Jt='Jtr:AwAICAkABAoAAA==.',Ku='Kuro:AwABCAIABRQAAA==.',Mi='Mimiron:AwAICAYABAoAAA==.',Na='Nazgrim:AwAFCBMABRQCAgAFAQhiCQAthNAABRQAAgAFAQhiCQAthNAABRQAAA==.',To='Tohka:AwABCAEABAoAAQEAAAAECAQABRQ=.',Vo='Voodooshades:AwAFCAUABAoAAA==.',Wl='Wlsnomercy:AwAICA4ABAoAAA==.',Yi='Yicdyoubiye:AwAICAgABAoAAA==.',Zw='Zwz:AwAECAcABAoAAA==.',['�']='一叶识秋:AwAGCAcABAoAAA==.一心向善:AwABCAEABRQAAA==.不再流浪:AwAECAQABRQAAA==.不是随意:AwAFCAUABAoAAA==.丘比特之哀伤:AwAECAEABRQAAA==.丘比特之杖:AwACCAQABRQCAwAIAQg8CgBS/4ICBAoAAwAIAQg8CgBS/4ICBAoAAA==.丨古月三少丨:AwAFCAoABAoAAA==.丶冰玲丶:AwAGCAgABAoAAA==.丶福如东海:AwAICAgABAoAAA==.',['�']='乃量惊人:AwACCAQABRQAAA==.乐正绫:AwACCAIABAoAAA==.九命狐灬:AwAICAgABAoAAA==.',['�']='五姑娘:AwAGCAYABAoAAA==.',['�']='伊克贝尔多:AwAICAgABAoAAA==.伊喏玲:AwAECAQABRQAAA==.伊芙莉特:AwAECAQABRQAAA==.伊莉莎白素贞:AwAGCAwABAoAAA==.',['�']='傻蔓电死你:AwAECAEABRQAAA==.',['�']='八百里开外:AwACCAIABAoAAA==.',['�']='农夫三拳丨痛:AwACCAIABRQAAA==.农妇山拳:AwAHCAcABAoAAA==.冬刺骨春繁华:AwAGCA0ABRQDBAAGAQgRAgBBUWcBBRQABAAEAQgRAgBJX2cBBRQABQAEAQihBQAfF98ABRQAAA==.冲了前头:AwAICA8ABAoAAA==.',['�']='凶猫大人:AwAICAgABAoAAA==.',['�']='刘大少:AwAICB8ABAoDBgAIAQi9MwAv4rEBBAoABgAIAQi9MwAr6rEBBAoABwAIAQh/DwAmsHMBBAoAAA==.',['�']='南国风情:AwAGCAYABAoAAA==.印第安纳白菜:AwABCAMABRQAAA==.',['�']='压力大我先拿:AwAICAcABAoAAQMARZsICAUABRQ=.',['�']='又见小刀:AwAFCAUABAoAAA==.古树梨花:AwADCAMABAoAAA==.',['�']='吉祥三宝:AwAECAQABRQAAA==.吾生须臾:AwAGCAIABAoAAA==.',['�']='哈侠:AwAICAgABAoAAA==.哈搞咕:AwAICAQABAoAAA==.',['�']='善良的倪哥:AwAECAgABAoAAA==.喊家属来收尸:AwAICAgABAoAAA==.',['�']='圣哈哈:AwAICAsABAoAAA==.',['�']='埃拉西亚:AwADCAMABAoAAA==.',['�']='夏日第一缕风:AwAICAgABAoAAA==.大地震鸡:AwAECAgABRQCCAAEAQj2AwBSyyYBBRQACAAEAQj2AwBSyyYBBRQAAA==.大饼:AwAICBAABAoAAA==.大饼熊:AwABCAEABAoAAA==.大饼熊的墓石:AwAECAQABRQAAQkAFksGCAoABRQ=.天然气女友:AwAICAgABAoAAA==.天霸地霸咚霸:AwAGCAYABAoAAA==.',['�']='好心女孩子:AwADCAMABAoAAA==.',['�']='如果你不在:AwACCAQABRQAAA==.',['�']='孤烟:AwACCAIABAoAAA==.孤独的夜:AwAFCAgABAoAAA==.',['�']='封枝暮雪:AwACCAIABRQAAA==.将来:AwAHCAcABAoAAA==.小小孩:AwACCAIABAoAAA==.小小法强:AwADCAcABRQCCgADAQgMBgA9PeYABRQACgADAQgMBgA9PeYABRQAAA==.小尾儿摆摆:AwAECAQABAoAAA==.小当僧:AwACCAIABAoAAA==.小清流:AwAECAQABRQCCwAIAQjmCwBZ3JcCBAoACwAIAQjmCwBZ3JcCBAoAAA==.小瑜熊:AwAICAkABAoAAA==.小翘流水:AwAGCBEABAoAAA==.小软灬:AwAICBMABAoAAA==.小靓仔:AwAICAgABAoAAA==.',['�']='岳下噬魔:AwACCAMABRQAAA==.',['�']='帅是一辈子:AwADCAEABRQAAA==.希格德莉法:AwACCAEABRQAAA==.',['�']='幻梦丶唯殇:AwAECAUABRQCDAAEAQivEQAhNbwABRQADAAEAQivEQAhNbwABRQAAA==.幽暗圣灵:AwACCAcABRQCDQACAQgGDgBA5ZsABRQADQACAQgGDgBA5ZsABRQAAA==.',['�']='应采儿:AwAGCAoABAoAAA==.',['�']='张泰玩:AwAECAQABRQAAA==.',['�']='徐子凡:AwABCAEABAoAAA==.',['�']='忆中人:AwAFCAUABAoAAA==.',['�']='惊恐的鸦龙:AwADCAkABRQDDgADAQguCAA5Ku4ABRQADgADAQguCAA5Ku4ABRQADwABAQiKCQAUrjUABRQAAA==.',['�']='我很橙熟:AwAICAgABAoAAA==.',['�']='抹香鲸:AwABCAEABRQAAA==.',['�']='挽歌之殇:AwACCAcABRQCEAACAQh5IgAP+XwABRQAEAACAQh5IgAP+XwABRQAAA==.',['�']='斩青龙之戟:AwAFCAUABAoAAA==.',['�']='旅人癫疯痴狂:AwAICAgABAoAAA==.无天射手:AwAICAkABAoAAA==.无敌老钟:AwABCAEABRQAAA==.无聊帝帝鬼:AwACCAIABAoAAA==.时尚小子:AwAICBkABAoDEQAIAQhODABC7R8CBAoAEQAIAQhODAA+sB8CBAoAEgABAQi1PwBFWzMABAoAAA==.',['�']='朕慑汝無罪:AwAGCAgABAoAAA==.',['�']='柠檬小草:AwAHCAYABAoAAA==.柠檬影月:AwABCAEABAoAAA==.',['�']='欺山:AwAICAgABAoAAA==.',['�']='正义之丘比特:AwAECAUABRQCBAAEAQhJEwA0xPQABRQABAAEAQhJEwA0xPQABRQAAA==.',['�']='汐之卡米:AwACCAMABRQAAA==.汐汐:AwAGCAYABRQCDAAGAQhfAABUQf0BBRQADAAGAQhfAABUQf0BBRQAAA==.',['�']='泽拉耿:AwAGCAoABAoAAA==.泽村英梨梨:AwAFCAYABAoAAA==.',['�']='游戏人生丶:AwAECAQABRQAAA==.游龙戏凤:AwAGCAYABAoAAA==.',['�']='湘云:AwADCAMABAoAAA==.',['�']='澤老板:AwACCAIABAoAAA==.',['�']='灬妃咲灬:AwAICBAABAoAAA==.災禍:AwACCAIABRQAAA==.',['�']='烣燼使者:AwAECAQABRQAAA==.',['�']='爆炸天团:AwAICAgABAoAAA==.爱吃水果:AwACCAMABRQDEwAIAQhiDQBGAUUCBAoAEwAIAQhiDQBGAUUCBAoAFAAIAQhYPgA6adUBBAoAAA==.',['�']='牦牛奔驰:AwAICAkABAoAAA==.',['�']='琴森依旧:AwABCAEABRQAAA==.',['�']='璞鈺:AwAHCAkABAoAAA==.',['�']='甄妮玛黛劲:AwAECAQABAoAAA==.甜筒掉了:AwAICAgABAoAARUAMkwGCA0ABRQ=.',['�']='痛毁恶魔:AwABCAMABRQCDAAIAQiFHwA7NvIBBAoADAAIAQiFHwA7NvIBBAoAAA==.',['�']='百步飞箭:AwACCAIABRQAAA==.',['�']='眠浅浅:AwAECAQABRQAAA==.',['�']='砸妮家玻璃:AwAICAgABAoAAA==.',['�']='立石凛:AwAICAgABAoAAA==.',['�']='终极吸橙器:AwABCAEABAoAAA==.续完这支烟:AwAICAgABAoAAA==.',['�']='羞耻普类:AwAECAQABAoAAA==.',['�']='老婆早安:AwACCAIABAoAAA==.老钟采花:AwAFCAoABAoAAA==.',['�']='胖胖不怕胖:AwADCAYABRQCFAADAQgVGAAg09YABRQAFAADAQgVGAAg09YABRQAAA==.胖胖不是胖:AwACCAIABRQAAA==.胖胖不能胖:AwABCAMABRQAAA==.',['�']='自笑走荭尘:AwAICAgABAoAAA==.自笑走荭薼:AwAECAgABRQDFAAEAQhcDwBNovwABRQAFAAEAQhcDwBNovwABRQAEwAEAQgxCgArPNUABRQAAA==.',['�']='艾萨克尼特罗:AwADCAoABRQDCwADAQjgBQBOlCEBBRQACwADAQjgBQBOlCEBBRQAFgABAQi7EABDdVcABRQAAA==.',['�']='花间浊酒:AwAGCAYABAoAAA==.',['�']='荒漠星云:AwACCAIABRQDFQAIAQgmIQAo76YBBAoAFQAIAQgmIQAo76YBBAoADQADAQizZQAiZoEABAoAAA==.荣誉:AwACCAIABAoAAA==.',['�']='菜小蜓:AwACCAIABRQAAQEAAAAICAIABRQ=.菠萝鳖:AwACCAMABAoAAA==.菲羽凌曦:AwAECAcABRQDEwAEAQioCgAvKdIABRQAEwAEAQioCgAvKdIABRQAFAADAQiEHAAL7LUABRQAAA==.',['�']='萢咴儿:AwABCAEABAoAAA==.萨克拉:AwAGCAYABAoAAA==.落雪梨花:AwAECAcABRQEFQAEAQgBDgAgrdAABRQAFQAEAQgBDgAgrdAABRQADQABAQgcHgAYRzYABRQACQABAQgKIQARnTYABRQAARUAO50GCA4ABRQ=.落雪樱花:AwAFCAkABAoAAA==.',['�']='衢州兔头:AwAECAQABRQAAQQAPWgGCAYABRQ=.',['�']='诺文:AwAECAQABRQAAA==.诺言:AwAGCAYABAoAAA==.',['�']='豆豆的骑士:AwABCAMABRQAAA==.',['�']='费劲哥:AwAECAQABRQAAA==.',['�']='轻抚后庭花:AwABCAEABRQAAA==.',['�']='迦南:AwAICAEABRQAAA==.',['�']='遗忘的星语:AwADCAMABAoAAA==.',['�']='邪恶少女魔酱:AwADCAQABAoAAA==.',['�']='铁胩:AwAECAQABAoAAA==.铁锅炖大德:AwAECAQABRQAAA==.',['�']='间影呛咚呛:AwADCAoABRQCDQADAQjiAgBUHxoBBRQADQADAQjiAgBUHxoBBRQAAA==.闻薄阳又现雪:AwAECAIABRQAAA==.',['�']='阿努比斯杰:AwAICBcABAoDBAAIAQjjVAAzQdMBBAoABAAIAQjjVAAzQdMBBAoABQAEAQgANwAQMX8ABAoAAA==.阿涵:AwAFCAUABAoAAA==.阿耀:AwADCAkABRQCAgADAQgWDAAtB7YABRQAAgADAQgWDAAtB7YABRQAAA==.',['�']='随意大小变:AwAICAEABAoAAA==.',['�']='雀斑:AwAECAEABRQAAA==.雨落单车:AwADCAMABAoAAA==.雪语微微:AwAICAsABAoAAA==.零千魂:AwAECAQABRQAAQEAAAAICAQABRQ=.雷二:AwACCAMABAoAAA==.',['�']='霜晓寒姿:AwACCAMABRQDFgAIAQh7DwA/yx0CBAoAFgAHAQh7DwA/Ex0CBAoACwAEAQh8XgAs17IABAoAAA==.',['�']='风尘细雨:AwAGCAcABAoAAA==.飘逸丶人生:AwACCAIABAoAAA==.飞天小龙人:AwAICAgABAoAAA==.飞天激拔王:AwAECAQABAoAAA==.飞天魔猎:AwAICB4ABAoCFAAIAQgHLQA/Fh8CBAoAFAAIAQgHLQA/Fh8CBAoAAA==.',['�']='饮水机帅帅:AwACCAIABAoAAA==.饿了么搜美团:AwAGCAYABAoAAA==.',['�']='马褂不要了:AwADCAMABAoAAA==.',['�']='高级牛肉干:AwAECAQABRQAAA==.高级精兽肉干:AwAECAQABAoAAA==.高高名被占了:AwADCAMABAoAAA==.',['�']='黑虎虾:AwACCAQABRQAAA==.',['�']='龙猫殿下:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end