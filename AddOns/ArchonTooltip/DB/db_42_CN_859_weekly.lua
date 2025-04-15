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
 local lookup = {'Priest-Shadow','DemonHunter-Havoc','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Unknown-Unknown','Monk-Brewmaster','Monk-Mistweaver','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','Warrior-Fury','Priest-Holy','Priest-Discipline','Evoker-Devastation','Monk-Windwalker','Druid-Balance','Druid-Restoration','Shaman-Elemental','DeathKnight-Unholy','Rogue-Assassination','DeathKnight-Frost','Mage-Fire','Shaman-Enhancement','Shaman-Restoration','Evoker-Augmentation','Warrior-Arms','Warrior-Protection','Rogue-Subtlety',}; local provider = {region='CN',realm='阿克蒙德',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Aliezo:AwABCAEABRQAAA==.Alligatorr:AwAECAEABRQAAA==.',Bl='Blink:AwABCAEABRQAAQEANxEDCAcABRQ=.',Bo='Bodhmall:AwAECAQABRQAAA==.',Ca='Caber:AwAGCAwABRQCAgAEAQi9DQA76fkABRQAAgAEAQi9DQA76fkABRQAAA==.',Ch='Chromeheart:AwAECAQABAoAAA==.',Cs='Csmikasa:AwACCAIABRQCAwAIAQihFgBaSq8CBAoAAwAIAQihFgBaSq8CBAoAAA==.',Da='Daryldixon:AwAECAYABRQDBAAEAQibGgA7TdYABRQABAAEAQibGgAc4tYABRQABQACAQgJDwBUQrgABRQAAA==.',Ex='Exstart:AwABCAEABAoAAA==.',Fr='Frankberry:AwAFCAUABAoAAA==.',Go='Goodend:AwAICA8ABAoCBQAIAQhfGwA8DMUBBAoABQAIAQhfGwA8DMUBBAoAAA==.',He='Heavensgate:AwAHCAsABAoAAA==.',Jd='Jdxob:AwAGCAQABAoAAA==.',La='Lalisa:AwAHCA0ABAoAAA==.',Li='Lit:AwABCAEABRQCBgAIAQjwHwA+AO4BBAoABgAIAQjwHwA+AO4BBAoAAA==.',Lo='Loktarog:AwAHCA4ABAoAAA==.',Lu='Lunatism:AwAFCAUABAoAAA==.',Na='Nakhimov:AwABCAEABRQAAA==.',No='Nocl:AwACCAIABAoAAA==.Norðurljós:AwAFCAcABAoAAA==.',Pa='Paladinus:AwAFCAUABAoAAQcAAAAICAwABAo=.',Ra='Raistlin:AwAGCA4ABAoAAQcAAAAECAQABRQ=.',Ru='Ruigee:AwAGCAYABAoAAA==.',St='Stann:AwAICBAABAoAAA==.',Th='Thursday:AwAFCAUABAoAAA==.',Ur='Ursamajor:AwADCAIABRQAAA==.',['�']='一小麦一:AwAICAgABAoAAA==.三刀不能多:AwAFCA0ABAoAAA==.三月初七:AwAECAQABRQAAA==.丢猫星画:AwACCAIABAoAAA==.丨寅丸星丨:AwAHCBAABAoAAA==.丨捉影丨:AwAECAQABAoAAA==.丨欧美丨专区:AwAECAIABRQAAA==.丨费列罗丨:AwAHCAcABAoAAA==.丨龍神灬:AwACCAIABAoAAA==.丶敖凌:AwAECAEABRQAAA==.丶芍药:AwABCAIABRQCCAAIAQhXAwBR1n0CBAoACAAIAQhXAwBR1n0CBAoAAA==.举高高丶:AwADCAMABAoAAQcAAAABCAEABRQ=.',['�']='乂哞哞乂:AwACCAIABAoAAA==.久菜合子:AwABCAEABRQAAA==.乐乐汼:AwAICA8ABAoAAA==.乐心:AwADCAMABAoAAA==.乔姜:AwAFCAUABAoAAA==.九字刺印:AwABCAIABRQAAA==.',['�']='二环:AwAECAQABRQAAA==.亚哈丶囧炯囧:AwACCAYABRQCCQACAQgUGQAuLZYABRQACQACAQgUGQAuLZYABRQAAA==.人不再少年:AwACCAIABRQAAA==.',['�']='今晚熬夜么:AwADCAEABAoAAA==.今晚熬夜的:AwAFCAUABAoAAA==.',['�']='企鹅翔翔:AwACCAIABAoAAA==.',['�']='你不是个二子:AwAICAgABAoAAA==.你是阿福吗:AwAICAgABAoAAA==.',['�']='傅雨晴:AwADCAMABAoAAA==.',['�']='元方怎么看:AwAFCAkABAoAAA==.兵长:AwABCAEABRQAAA==.',['�']='再打还手了啊:AwAICAsABAoAAA==.冬凌术:AwAECAYABRQECgAEAQjqAQBb5y0BBRQACgADAQjqAQBb5y0BBRQACwACAQiIFQBa47AABRQADAABAQibFwAAAAAABRQAAA==.冰血妖狐:AwAICAgABAoAAA==.',['�']='凊氺洮孓:AwAECAIABRQAAA==.凯哥:AwAICAgABAoAAA==.',['�']='刃我狂:AwAHCAcABAoAAA==.别动我的猫:AwACCAMABRQAAA==.别压我头发了:AwAICAgABAoAAQsAUnQHCAcABRQ=.',['�']='勒格拉斯:AwAICAgABAoAAA==.動手動脚:AwAGCAIABRQAAQ0AQCkICAUABRQ=.',['�']='匹仕不仕:AwAFCAEABAoAAA==.',['�']='千年老妖:AwAECAQABAoAAA==.千语:AwAECAQABRQAAA==.卡诺卡诺:AwAICAgABAoAAA==.',['�']='叨小叨:AwAECAoABRQCAwAEAQggCQBPqCIBBRQAAwAEAQggCQBPqCIBBRQAAA==.',['�']='吉祥妞妞:AwAHCAcABAoAAA==.',['�']='咕噜咕噜哈:AwAGCAsABAoAAA==.',['�']='哈基蜜小呆鸟:AwAECAQABRQAAA==.',['�']='嘟嘟把你包围:AwAECAQABRQAAA==.',['�']='圆滚滚一一:AwADCAMABAoAAA==.圣光乄牛奶:AwAECAQABAoAAA==.圣光于我心:AwAICAgABAoAAA==.圣盾妖女:AwAICAgABAoAAA==.在外叫我丧彪:AwAECAQABRQAAA==.',['�']='塞纳牛斯:AwAICBEABAoAAA==.',['�']='墨兮陌兮:AwAECBEABRQCAwAEAQhkDgBR6Q0BBRQAAwAEAQhkDgBR6Q0BBRQAAA==.墨老师:AwADCAMABAoAAA==.',['�']='壹戦成名:AwADCAYABRQCDgADAQiPCgA5RAYBBRQADgADAQiPCgA5RAYBBRQAAA==.',['�']='夏璇晴雪:AwAECAQABRQAAA==.夜二:AwAICAgABAoAAA==.夜幕烨:AwAFCAUABAoAAA==.夜雨暮色:AwAHCA8ABAoAAA==.大喵喵会无敌:AwAECAQABRQAAQcAAAAGCAQABRQ=.大意:AwAICAUABRQCAgAFAQizBQAmmTMBBRQAAgAFAQizBQAmmTMBBRQAAA==.大超哥大领主:AwAICAgABAoAAA==.大连路小太阳:AwAICAoABAoAAA==.大造化丹:AwABCAEABAoAAA==.天舞野望:AwABCAMABRQAAA==.天选牛马:AwAECAQABRQAAA==.',['�']='娜吡很美:AwABCAEABAoAAA==.',['�']='安娜斯塔西娅:AwAECAQABRQAAA==.',['�']='密瑟拉:AwAGCAYABAoAAA==.寒月圣:AwACCAIABAoAAA==.',['�']='小可乐:AwAGCAoABRQEDwAGAQiWAQA2PToBBRQADwAFAQiWAQAtRDoBBRQAAQACAQiXEwAgrKQABRQAEAADAQheFQA+spEABRQAAREAD08ICAUABRQ=.小心脚下:AwAICB8ABAoDBQAIAQg3EwBEYRACBAoABQAIAQg3EwBC2BACBAoABAAGAQgBdgA6KywBBAoAAA==.小早川紗枝:AwAICBUABAoDAQAIAQjbFwA/FwECBAoAAQAIAQjbFwA/FwECBAoADwACAQgnXwA6z50ABAoAAA==.小栋爷:AwABCAEABRQAARIAIYsICAYABRQ=.小母牛快跑:AwACCAIABAoAAA==.小爷:AwAICAgABAoAAA==.小糖宝:AwAHCAwABAoAAA==.小翼:AwABCAIABAoAAA==.小虎骑士:AwAGCAYABAoAAA==.小鱼怕水:AwAHCAgABAoAAA==.',['�']='山丘丶:AwAFCAUABAoAAA==.山炮农庄:AwAECAQABAoAAA==.',['�']='帕秋莉诺蕾姬:AwABCAEABAoAAA==.',['�']='廿四岁是学生:AwABCAEABRQAAA==.',['�']='忆丶芒果:AwAICBkABAoCAwAIAQhWLABQRVgCBAoAAwAIAQhWLABQRVgCBAoAAA==.快乐小男孩:AwADCA8ABRQDDwADAQg9BgBE0PQABRQADwADAQg9BgBDS/QABRQAEAADAQiqCQAxyPEABRQAAA==.',['�']='怒刚正面君:AwAECAQABRQAAA==.',['�']='恶磨猎手:AwAECBEABRQCBAAEAQhaEgA1E/gABRQABAAEAQhaEgA1E/gABRQAAQUAQc0GCAYABRQ=.恶魔卷卷:AwAICBQABAoCAgAIAQhPMwAvpMUBBAoAAgAIAQhPMwAvpMUBBAoAAA==.',['�']='您缺德么:AwAICAgABAoAAA==.',['�']='情天黑:AwAECAYABRQDEwAEAQiMHQA4jpwABRQAEwADAQiMHQA5sZwABRQAFAACAQiTFgAObGMABRQAAA==.',['�']='我不要捡肥皂:AwAHCBkABAoCFQAHAQivKwAt1HkBBAoAFQAHAQivKwAt1HkBBAoAAA==.我有一双翅膀:AwAECAQABAoAAA==.我锤石你德玛:AwADCAUABRQCAgADAQgIDQAvmv0ABRQAAgADAQgIDQAvmv0ABRQAAQIAPtMGCAoABRQ=.',['�']='打你就完事:AwACCAIABRQAAA==.打的就是老四:AwAGCAoABRQCEQAGAQhwAQA94bYBBRQAEQAGAQhwAQA94bYBBRQAAA==.打败我没烦恼:AwACCAIABRQAAA==.扬眉一笑:AwAECAQABRQAAA==.',['�']='把盏几许疏狂:AwABCAEABRQAAA==.抓咕咕丨大师:AwAICA4ABAoAAA==.',['�']='拉库萨斯:AwAICBAABAoAAA==.拉文凯持:AwAGCAYABAoAAA==.拉文凯特:AwAICBEABAoAAA==.拯救老板:AwAICB0ABAoDFgAIAQjFKgBE1eYBBAoAFgAIAQjFKgBE1eYBBAoADQAIAQhrNAAOmdcABAoAAA==.',['�']='挨着啦市:AwABCAEABAoAAA==.',['�']='捕風:AwAICAkABAoAAA==.',['�']='斗丶牛士:AwAFCAQABAoAAA==.斷水流大师兄:AwAECAgABRQDFgAEAQiqCwA9kvQABRQAFgAEAQiqCwA9kvQABRQADQAEAQgrEgAYz5YABRQAAA==.',['�']='无名的阿昆达:AwAGCAYABRQCCwAEAQj0CgA6jPIABRQACwAEAQj0CgA6jPIABRQAAA==.无论如荷:AwAGCAUABRQCBQAEAQhgDgAq2b8ABRQABQAEAQhgDgAq2b8ABRQAAA==.时期狂三丶:AwABCAIABRQAAA==.',['�']='明暗交界线:AwACCAIABRQAAA==.星天一碧:AwAICBEABAoAAA==.星洛凡尘:AwAFCAUABAoAAA==.',['�']='晋哥铁马:AwABCAEABAoAAA==.晓石頭:AwACCAIABAoAAA==.',['�']='暗伤月煞:AwACCAcABRQCFwACAQi6DQAv2KIABRQAFwACAQi6DQAv2KIABRQAAA==.暗伤血咒:AwADCAMABAoAAA==.',['�']='最后的炮灰:AwABCAEABAoAAA==.最後的圣光:AwADCAgABRQCGAADAQgzAgAtjvYABRQAGAADAQgzAgAtjvYABRQAAA==.月千秋:AwAICB8ABAoCBAAIAQjGMQBHnBUCBAoABAAIAQjGMQBHnBUCBAoAAA==.月島花:AwAECAsABRQDBgAEAQidBABABwQBBRQABgAEAQidBABABwQBBRQAGQACAQjNJgAyhpYABRQAAQsAUnQHCAcABRQ=.',['�']='来瓶快乐水:AwAICAcABAoAAA==.杰克来都杀了:AwABCAEABAoAAA==.',['�']='枭萌萌:AwAECAcABRQCEwAEAQhrEgApOuMABRQAEwAEAQhrEgApOuMABRQAAA==.',['�']='查理曼丶圣光:AwAECAcABRQCAwAEAQh9DQBRQhABBRQAAwAEAQh9DQBRQhABBRQAAA==.',['�']='格格不打嗝:AwABCAEABAoAAA==.',['�']='森勺子:AwAICAgABAoAAA==.',['�']='欧琳丶霜心:AwAECAQABRQAAA==.',['�']='武神太斗:AwAECAQABRQAAA==.',['�']='残酷雪碧:AwAICBsABAoDCwAIAQhgLQAtw60BBAoACwAIAQhgLQAtw60BBAoADAABAQgWaQAU5TQABAoAAA==.',['�']='毒猫丶李维斯:AwAFCAEABAoAAA==.毒瘤术:AwAICAgABAoAAA==.毛球喵:AwAICA4ABAoAAA==.',['�']='永恒之树:AwABCAEABAoAAA==.氹仔鸡:AwAECAIABRQAAA==.',['�']='江湖啸:AwAFCAUABAoAAA==.',['�']='海森堡:AwAECAQABRQAAA==.',['�']='深山老零:AwADCAQABRQAAA==.',['�']='清秀小青年:AwAICBIABAoAAA==.',['�']='火雪心:AwAECAQABRQAAA==.灬没边儿灬:AwAECAYABRQCEAAEAQhWBQBRvB8BBRQAEAAEAQhWBQBRvB8BBRQAAA==.灬糖仇烬炀灬:AwAICAgABAoAAQcAAAAICAMABRQ=.灬莉雅灬:AwACCAIABRQDGQAIAQgKSwA0Dj4BBAoAGQAGAQgKSwAuvT4BBAoABgAEAQhXWwArj9UABAoAAA==.',['�']='炭烧积雨云:AwAECAYABRQDGgAEAQjvBQBJTA8BBRQAGgAEAQjvBQBJTA8BBRQAGwACAQjoIAAV0X0ABRQAAA==.',['�']='烈焰醒者:AwAGCAQABRQAAA==.',['�']='無限劍制:AwAECAQABRQAAA==.',['�']='熊猫一提臀:AwABCAEABAoAAA==.',['�']='王小二:AwADCAYABRQCAwADAQhoHgAiZdcABRQAAwADAQhoHgAiZdcABRQAAA==.玩个锤子:AwAECAQABRQCAwAIAQitPQBLDh0CBAoAAwAIAQitPQBLDh0CBAoAAA==.',['�']='珍珠丶:AwAFCBEABRQCDgAFAQi5AQBOno4BBRQADgAFAQi5AQBOno4BBRQAAA==.',['�']='理塘丁真:AwAICAgABAoAAA==.',['�']='瓦林青石之拳:AwAECAQABAoAAA==.',['�']='白家老大:AwACCAQABRQAAA==.白小星:AwAICAgABAoAAA==.白马非马:AwAHCAgABAoAAA==.百无聊赖:AwAGCAcABAoAAA==.',['�']='真不愿呀:AwAICAgABAoAAA==.',['�']='碎碎念晕:AwAFCAEABAoAAA==.',['�']='礑葒小聖騎:AwAICAwABAoAAA==.',['�']='神侮:AwAECAMABAoAAA==.',['�']='福特瓦纳斯:AwADCAMABRQAAA==.福生玄黄天尊:AwAICAoABAoAAA==.',['�']='秋葉:AwAGCAYABRQCGQAEAQg+DwBBIgIBBRQAGQAEAQg+DwBBIgIBBRQAAA==.',['�']='穹之殇痕:AwAECAYABRQCGwAEAQgvEAAibtgABRQAGwAEAQgvEAAibtgABRQAARUAOx8GCAQABRQ=.',['�']='童话丶亡愿:AwAICAkABAoAAA==.',['�']='筱睇:AwAECAgABRQDEwAEAQizAwBgR0UBBRQAEwAEAQizAwBgR0UBBRQAFAABAQiSIQAA+yEABRQAAA==.',['�']='米哥:AwAECAMABRQAARQAPyYICAsABRQ=.',['�']='索恩寒霜之锤:AwAGCAYABAoAAA==.',['�']='罗斯特彼弗:AwACCAIABAoAAA==.罗斯福先生:AwAGCAYABRQCAwAGAQjhAAA9b9IBBRQAAwAGAQjhAAA9b9IBBRQAAA==.',['�']='美味鸡腿:AwAICA4ABAoCHAAIAQhaAgAoeUMBBAoAHAAIAQhaAgAoeUMBBAoAAA==.美鸡味腿:AwAFCBMABRQECwAFAQggAwBK6U4BBRQACwADAQggAwBhbk4BBRQADAACAQiwEQAHWEsABRQACgABAQg+HgAAAAAABRQAAA==.',['�']='肥猪灯:AwAICAUABAoAAA==.',['�']='胖哥丶:AwAECAQABRQAAA==.',['�']='脚踩西瓜皮:AwABCAEABRQAAA==.脸萌药丸:AwAECAQABRQAAA==.',['�']='艾贝勒:AwAECAQABRQDEwAIAQiuKgA8LvQBBAoAEwAIAQiuKgA8LvQBBAoAFAACAQhDewA1uTAABAoAAA==.',['�']='若叶牧:AwAGCAYABRQDEAAGAQjxCwAvD94ABRQAEAAEAQjxCwAzh94ABRQAAQACAQhmEQA6OLsABRQAAA==.',['�']='茅拾捌:AwAICAIABAoAAA==.茯神:AwAICAgABAoAAA==.',['�']='荷鲁斯之眼:AwAICAgABAoAAA==.',['�']='莫忧愁莫回头:AwAECBAABRQECwAEAQgLDgBKlt4ABRQACwAEAQgLDgAsRt4ABRQACgADAQhcDQA7zKQABRQADAABAQheCQBbimoABRQAAQsAUnQHCAcABRQ=.莫问情仇:AwAICAoABAoAAA==.莫高雷的回响:AwADCA0ABRQEHQADAQgtCQBQzLYABRQAHQACAQgtCQBO/7YABRQADgABAQgFHwBUZGIABRQAHgABAQhyCQBUJFIABRQAAA==.',['�']='菟菟小乖:AwAICBEABAoAAQ8AVc8CCAUABRQ=.',['�']='萨小满丶:AwAHCAcABAoAAA==.萨尓居然:AwAECAQABAoAAQUAQc0GCAYABRQ=.萨拉塔斯:AwAHCAIABRQAAA==.萨拉杨:AwACCAIABAoAAA==.萨神丶:AwAECAQABRQAAA==.落幕丶风羽:AwAECAQABAoAAA==.落雪沐曦:AwABCAEABRQAAA==.',['�']='蓝带啤酒:AwABCAEABRQAAA==.',['�']='蛋黄儿是只猫:AwAECAYABRQCAwAEAQj6BwBTrigBBRQAAwAEAQj6BwBTrigBBRQAAA==.',['�']='貓的脚步声:AwAECAgABRQCCwAEAQgfDwA7XNkABRQACwAEAQgfDwA7XNkABRQAAA==.',['�']='贱义勇为:AwAGCAYABRQDFwAGAQgLAgAskWYBBRQAFwAFAQgLAgA26mYBBRQAHwABAQgFDwADLk4ABRQAAA==.',['�']='赤焰流火:AwAHCAcABAoAAA==.赤雾生:AwAECAQABAoAAA==.',['�']='越菜越爱玩:AwADCAQABAoAAA==.',['�']='輕寒細雨:AwACCAIABRQAAA==.',['�']='辣个德:AwACCAMABAoAAA==.',['�']='迷灬戀恋:AwAECA0ABRQDFAAEAQghCQAtAM8ABRQAFAADAQghCQAtAM8ABRQAEwACAQg0MgAQdjEABRQAAA==.追不上爷:AwABCAEABAoAAA==.',['�']='逗逗:AwAHCAgABAoAAA==.逗逼旭哥:AwABCAEABAoAAA==.',['�']='邪丶冥梦:AwABCAEABRQAAA==.',['�']='鄙人不善奔跑:AwABCAEABRQAAA==.',['�']='酒仙:AwAGCAcABAoAAA==.酿酿有酱酱:AwAECAQABRQAAA==.',['�']='铁血暴风:AwAICBAABAoAAA==.',['�']='闻君有两意:AwAECAQABRQAAA==.',['�']='陈雪:AwAICA8ABAoAAA==.',['�']='零时之月:AwAICBAABAoAAA==.雾非雾花非花:AwAECAQABAoAAA==.',['�']='非常无耻:AwAECAQABRQAAA==.面包圈:AwACCAgABRQDCwACAQg9HgAlMHoABRQACwACAQg9HgAlMHoABRQADAABAQgOFAAXQEIABRQAAA==.',['�']='颤元素:AwAGCAYABAoAAA==.風呼舞雩:AwABCAEABRQAAA==.風弑丶若泽:AwACCAIABRQAAA==.',['�']='风少爷丶:AwAGCAUABRQDGgAEAQiMCAAo9/cABRQAGgAEAQiMCAAo9/cABRQAGwABAQgsLwAGjjIABRQAAA==.风少爺:AwAGCAkABAoAAA==.',['�']='饮者无名:AwADCAMABAoAAA==.',['�']='马斯特鲁:AwAICAgABAoAAA==.',['�']='高伤:AwAFCAUABAoAAA==.',['�']='黄昏降临:AwABCAEABRQAAA==.黑糖:AwAECAoABRQCGQAEAQi3EgBFG/QABRQAGQAEAQi3EgBFG/QABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end