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
 local lookup = {'Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Unknown-Unknown','Evoker-Preservation','Evoker-Devastation','Monk-Mistweaver','Mage-Frost','Mage-Fire','Hunter-Marksmanship','DeathKnight-Unholy','Druid-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Rogue-Assassination','Paladin-Protection','Monk-Windwalker','Priest-Discipline','Warrior-Protection','Priest-Holy','Druid-Guardian','Rogue-Outlaw','Rogue-Subtlety','Druid-Balance','Paladin-Holy','Evoker-Augmentation',}; local provider = {region='CN',realm='索瑞森',name='CN',type='weekly',zone=42,date='2025-04-14',data={Au='Augenstern:AwAECAYABRQDAQAEAQj1AQBeJUYBBRQAAQAEAQj1AQBeJUYBBRQAAgACAQikDQBNbZMABRQAAQMAKokICAIABRQ=.',Bo='Bonescythe:AwAICA4ABAoAAA==.',Br='Broxigár:AwAECAQABAoAAA==.',Co='Cocoray:AwACCAIABRQAAA==.',Di='Dinsprinfall:AwADCAMABAoAAA==.',El='Elysee:AwAICAgABAoAAA==.',Es='Estrella:AwAGCAYABRQDBAAGAQg8AABCiocBBRQABAAEAQg8AABQv4cBBRQABQACAQiBDQAJuFEABRQAAQYAYjsICBwABRQ=.',Ev='Eval:AwAFCAcABAoAAA==.',Fa='Fartestt:AwABCAEABAoAAA==.',Fl='Flower:AwAHCAcABAoAAA==.Flowerco:AwAGCAMABRQAAA==.',Ju='Justice:AwAGCAYABAoAAA==.',Le='Lelecha:AwAICA4ABAoAAA==.',Ma='Magicchoi:AwAHCAsABAoAAA==.',Me='Memorably:AwAGCAgABRQDBAAFAQgBAwBWxBMBBRQABAADAQgBAwBXMxMBBRQABgACAQhcIABVeFsABRQAAA==.',Ni='Nickel:AwABCAIABRQAAA==.',Pr='Pronhub:AwAGCAcABAoAAA==.',Ro='Roselia:AwACCAMABRQAAQcAW7IDCAgABRQ=.Rouger:AwAICAgABAoAAA==.',Sa='Sarcasm:AwAGCAYABAoAAA==.',So='Sooa:AwAICAMABAoAAA==.',Sy='Sylvie:AwAECAQABRQAAA==.',Ti='Titanium:AwABCAEABRQAAA==.',Wa='Warspite:AwAECAQABRQAAA==.',Yo='Yorushikaa:AwAECAQABRQAAQgAAAAECAQABRQ=.Yourk:AwAHCBAABAoAAA==.',['�']='一只小恶魔:AwAICA0ABAoAAA==.一心牧:AwAICAcABAoAAA==.一簇野草:AwAECAUABAoAAA==.万物一口:AwAGCAYABRQDCQAGAQjbAAAk9ikBBRQACQAFAQjbAAAjnSkBBRQACgABAQjtFAAluVoABRQAAA==.三层楼那么高:AwABCAEABRQAAA==.东方即白:AwADCAMABAoAAA==.东方月缺:AwADCAQABAoAAA==.东方洛:AwAECAQABAoAAA==.丢你家窗户:AwAICA0ABAoAAA==.丨小领主丨:AwAICAgABAoAAA==.丫大咯:AwAECAMABRQAAA==.中官人:AwABCAEABRQDCgAIAQjwBwBSapACBAoACgAIAQjwBwBSapACBAoACQABAQh/JQAftjEABAoAAA==.丶不知所措:AwAECAQABRQAAA==.丿萌新丶:AwADCAMABAoAAA==.',['�']='九曜不禁:AwACCAIABRQAAA==.乳先爱:AwACCAYABRQCCwACAQhTEQBWmcMABRQACwACAQhTEQBWmcMABRQAAA==.',['�']='云谁之思:AwADCAMABAoAAA==.亞路嘉揍敵客:AwAGCAYABAoAAA==.亡魂咏叹:AwABCAEABRQDDAAIAQjxKAAuz7IBBAoADAAIAQjxKAAuz7IBBAoADQACAQiShgARflAABAoAAA==.',['�']='伍什弦:AwAECAQABRQAAA==.传说中的忘川:AwACCAIABRQAAA==.伪娘无双:AwAICBcABAoDAwAIAQinCQBf0tkCBAoAAwAIAQinCQBfMdkCBAoADgAGAQhdLQBRFj4BBAoAAA==.',['�']='你好树先生:AwAICAgABAoAAA==.你的刀比我小:AwABCAEABRQAAA==.你薇姐:AwAECAQABRQAAA==.',['�']='修罗王:AwACCAIABAoAAA==.',['�']='元元小可爱:AwAICAcABAoAAA==.先帝创业未半:AwAICAcABAoAAA==.光叔:AwACCAIABAoAAA==.光的湮灭:AwABCAEABRQCDwAIAQiFIABFOxUCBAoADwAIAQiFIABFOxUCBAoAAA==.八宝山:AwAICA0ABAoAAA==.兲憶弄秂:AwAECAEABRQAAQ0AORoICAYABRQ=.兹拉坦:AwACCAIABAoAAA==.',['�']='冰风火焰:AwAECAQABRQAARAAOkwGCAUABRQ=.冲锋扯俩蛋:AwAGCAQABRQAAA==.',['�']='利欧路:AwADCAQABRQAAA==.',['�']='勇者无惧:AwAGCAQABRQAAA==.',['�']='千古丶:AwABCAEABRQCAQAIAQhnFgBGty8CBAoAAQAIAQhnFgBGty8CBAoAAA==.千早爱音:AwAGCAwABRQCCwAEAQhfCQA5gvsABRQACwAEAQhfCQA5gvsABRQAAA==.',['�']='又来拯救世界:AwAICAgABAoAAA==.叶子的回忆:AwAICAgABAoAAA==.司澜:AwAICAgABAoAAA==.',['�']='吉光骨食:AwAGCAYABAoAAA==.名字有点长的:AwABCAEABRQDEQAIAQijJQBHxAICBAoAEQAHAQijJQBLwgICBAoAEgADAQgpMABBxdsABAoAAA==.听琦丶:AwAICAgABAoAAA==.',['�']='咕咕哒灬怒风:AwABCAEABAoAAA==.咸鱼酱:AwABCAEABRQDBQAIAQhdCgA63RACBAoABQAIAQhdCgA63RACBAoABgAIAQiXOQAfimkBBAoAAA==.咸鱼龙:AwACCAEABRQCCQAIAQiKBABHUUYCBAoACQAIAQiKBABHUUYCBAoAAA==.',['�']='哈优味:AwAECAQABRQAAA==.哈基米大王:AwAGCAYABAoAAA==.哼奇奇:AwABCAEABAoAAA==.',['�']='唐纳昇:AwADCAMABAoAAA==.',['�']='啊修罗:AwAICAsABAoAAA==.啊修罗王:AwAHCAcABAoAAA==.',['�']='喔叨呢丶:AwAICBkABAoCEwAIAQh1CgBWaqQCBAoAEwAIAQh1CgBWaqQCBAoAAA==.喜多川海梦:AwAGCAQABRQAAA==.',['�']='嗜血狂牧:AwAFCAUABAoAAA==.',['�']='团团软绵绵:AwAHCAcABAoAAA==.团团鸡哔你:AwAFCAUABAoAAQgAAAAHCAcABAo=.',['�']='圣光强袭:AwAGCAYABAoAAA==.圣谕者:AwAECAQABAoAAA==.',['�']='夜月灬幽若:AwADCAMABAoAAA==.大丶師兄:AwAICAgABAoAAA==.大甜甜:AwAICAgABAoAAA==.天然二:AwAICAgABAoAAA==.',['�']='妍宝:AwAECAQABRQAAA==.',['�']='嫂嫂带你玩:AwADCAEABAoAAA==.',['�']='季末很寂寞:AwABCAEABRQAAA==.',['�']='安妮丶霍尔:AwAECAgABRQCFAAEAQgUBABHVBIBBRQAFAAEAQgUBABHVBIBBRQAAA==.宝山大叔:AwAGCAcABAoAAA==.',['�']='导演我躺哪儿:AwAGCAYABAoAAA==.',['�']='小小赵:AwAICBcABAoCBwAIAQhEbQA3EJgBBAoABwAIAQhEbQA3EJgBBAoAAQgAAAAICAEABRQ=.小德术爷战复:AwAICAgABAoAAA==.小心爱上妮:AwABCAEABAoAAA==.小树林:AwAICAgABAoAAA==.小風波:AwAGCAYABAoAAA==.尐尐神棍:AwAGCAoABAoAAA==.尼古拉斯赵肆:AwAECAcABAoAAA==.尼娅海尤达嘉:AwAECAQABRQAAQgAAAAGCAQABRQ=.',['�']='岚脚:AwAGCAYABAoAAA==.',['�']='工会短板:AwAGCAYABRQCAwAGAQjOAgAdQoIBBRQAAwAGAQjOAgAdQoIBBRQAAA==.巨人术:AwAECAQABRQEBgAIAQj+FABOgTYCBAoABgAIAQj+FABOgTYCBAoABAADAQiOIgAwoboABAoABQACAQhxXAAuhkYABAoAAA==.',['�']='带带惩戒骑:AwADCAIABRQAAA==.',['�']='幻梦夕色:AwADCAIABRQAAA==.幻空丶:AwAGCAYABAoAAA==.幽小邪:AwABCAEABRQDBgAIAQg6FABY/jsCBAoABgAGAQg6FABYpTsCBAoABQADAQh+OABSsboABAoAAA==.',['�']='张大炮:AwABCAEABAoAAA==.',['�']='心月狐丶:AwAECAcABRQCFQAEAQgCCgAbRpQABRQAFQAEAQgCCgAbRpQABRQAAA==.',['�']='悲催的开始:AwAHCAcABAoAAA==.悲催莱纳:AwACCAIABAoAAA==.',['�']='惩戒魅魔:AwAICBIABAoAAA==.',['�']='我来玩迪凯:AwAICBAABAoAAA==.我来表演变身:AwAGCAYABAoAAA==.我滚了:AwAFCAUABRQCFgAEAQg+BgBP9gABBRQAFgAEAQg+BgBP9gABBRQAAQgAAAAGCAQABRQ=.我的风:AwABCAIABRQAAA==.',['�']='手天使:AwAGCAYABAoAAA==.手指触碰光:AwAECAQABRQAAA==.',['�']='抽抽丶:AwABCAEABRQAAA==.',['�']='拯救地絿好累:AwAICA0ABAoAAA==.',['�']='撒旦之力:AwADCAQABAoAAA==.撩汉大婶:AwABCAEABAoAAA==.',['�']='散场预演:AwAGCAYABRQDAwAIAQgfKABTkzYCBAoAAwAIAQgfKABPGjYCBAoADgAFAQhgHwBI4p0BBAoAAA==.散場預演:AwAHCAkABAoAAA==.',['�']='无尽顿悟:AwAICAgABAoAAA==.',['�']='暗夜暮影:AwAFCAoABAoAAA==.暗影尕贼:AwAICAsABAoAAA==.',['�']='有个萨满:AwABCAEABRQCAQAIAQiaGgBDzBMCBAoAAQAIAQiaGgBDzBMCBAoAAA==.有个骑士:AwAGCAQABAoAAA==.木耳杀手:AwACCAIABAoAAA==.',['�']='枫影神伤:AwAICAgABAoAAA==.枯焰生花:AwACCAQABRQCCgAIAQgpBQBbCrYCBAoACgAIAQgpBQBbCrYCBAoAAA==.',['�']='柳扶风:AwAICAgABAoAAA==.',['�']='桥多麻袋:AwAICAgABAoAAA==.',['�']='棒棒棠:AwABCAEABAoAAA==.',['�']='楚晩宁:AwAECAQABRQAAA==.',['�']='槟榔香薰:AwAICA8ABAoAAA==.',['�']='橘猫棠棠:AwADCAMABAoAAA==.橙不欺我:AwAGCAIABRQAAA==.',['�']='欧皇灞灞:AwADCAIABAoAAA==.',['�']='比格凯特:AwABCAEABRQDDgAHAQg/MAA65ywBBAoAAwAHAQgZYwAxmlcBBAoADgAGAQg/MAA1WiwBBAoAAA==.比格开特:AwAICA8ABAoAAA==.',['�']='氵货腋:AwAECAQABAoAAA==.',['�']='沁血之霊:AwAICBQABAoCAgAIAQi0CABWup0CBAoAAgAIAQi0CABWup0CBAoAAA==.沉沦无罪:AwAICAgABAoAAA==.沉睡者盖浇饭:AwAICBAABAoAAA==.沐聖光炫:AwAGCAYABRQCFwAGAQgxAQA2MpwBBRQAFwAGAQgxAQA2MpwBBRQAAA==.',['�']='洛川苹果:AwADCAEABAoAAA==.活币吊丑:AwADCAMABAoAAA==.',['�']='流浪昂克:AwACCAIABAoAAA==.浅斟丨低唱:AwAICAgABAoAAQgAAAAGCAIABRQ=.',['�']='淡淡嬷嬷茶:AwAECAQABAoAAA==.',['�']='游鸢:AwABCAEABRQDAgAIAQjmBgBVXrMCBAoAAgAIAQjmBgBVXrMCBAoAAQAIAQguRQAmUUwBBAoAAA==.',['�']='火爆飞踢:AwAHCAUABAoAAA==.灬喔喔奶糖灬:AwACCAMABAoAAA==.灰色头像:AwABCAEABAoAAA==.',['�']='热死的骨头:AwAECAQABRQAAQgAAAAICAEABRQ=.',['�']='牛背牛玄德:AwAICAgABAoAAA==.牧濑红莉栖:AwAHCA0ABAoAAQgAAAACCAIABRQ=.牧神小潘潘:AwAECAoABRQDBQAEAQgBAgA11/UABRQABQAEAQgBAgA11/UABRQABAACAQh3DwA7bI4ABRQAAA==.',['�']='狸花猫:AwAFCAUABAoAAA==.',['�']='王吸汁:AwAFCAUABAoAAA==.玛琪朶:AwAECAEABRQCBwAIAQhGYQA1MrMBBAoABwAIAQhGYQA1MrMBBAoAAA==.玩勿丧志:AwAHCAcABAoAAA==.',['�']='琪莎拉:AwACCAIABAoAAA==.',['�']='瑟里夫丶傲鬃:AwABCAEABRQCGAAIAQj0DAAzPrUBBAoAGAAIAQj0DAAzPrUBBAoAAA==.瑟里夫丶耀鬃:AwAECAcABAoAARgAMz4BCAEABRQ=.',['�']='甜奶茶的热闹:AwAECAUABRQCFwAEAQgYAwBaYDoBBRQAFwAEAQgYAwBaYDoBBRQAAA==.电波发射站长:AwAECAQABRQAAA==.男的好丑:AwAECAUABRQCEQAEAQgbDgAw/vUABRQAEQAEAQgbDgAw/vUABRQAAA==.',['�']='真的钟意你:AwAGCAMABRQCGQADAQgmEQAPsoUABRQAGQADAQgmEQAPsoUABRQAAA==.',['�']='碧空之歌:AwACCAIABAoAAA==.',['�']='神圣的西斯:AwAHCAwABAoAAA==.神奇的阿哥:AwACCAUABRQCGgACAQhrAwAfy18ABRQAGgACAQhrAwAfy18ABRQAAA==.神秘战神:AwAICAgABAoAAA==.神经领袖:AwACCAIABRQAAA==.',['�']='科里斯汀:AwAICA4ABAoAAA==.',['�']='空想猎:AwAICAgABAoAAA==.',['�']='立回:AwAICAwABAoAAA==.',['�']='糖囡囡:AwABCAEABRQCAwAIAQigNwA7p/ABBAoAAwAIAQigNwA7p/ABBAoAAA==.',['�']='納格也德:AwABCAEABRQAAA==.',['�']='红星闪耀少年:AwAECAQABRQAAA==.红灬发丨:AwAICAgABAoAAA==.',['�']='终彦:AwACCAIABAoAAA==.结束的栔约:AwAICBAABAoAAA==.绝望:AwAFCAUABAoAAQgAAAAGCAMABAo=.绝望鸭:AwAGCAMABAoAAA==.绫波丽丶:AwAICAgABAoAAA==.维络妮武:AwACCAcABRQCFgACAQjODwAqqo4ABRQAFgACAQjODwAqqo4ABRQAARYAIjQHCAkABRQ=.绿色心情:AwACCAIABAoAAA==.',['�']='聖乳奶咖:AwACCAIABAoAAA==.聖翼:AwAGCAQABRQAAA==.',['�']='肯尼迪斯科:AwAECAQABAoAAA==.肯醉拉玛:AwAICAgABAoAAA==.',['�']='脚滑狐狸:AwAICBoABAoDGwAIAQj/BgA5M68BBAoAHAAHAQjeEwA4Xa8BBAoAGwAHAQj/BgA5mK8BBAoAAA==.',['�']='至本:AwAFCAUABAoAAA==.至爱颖:AwAECAgABAoAAA==.',['�']='荀子:AwAHCAEABAoAAA==.荒凉壹梦:AwAFCAYABAoAAA==.荼白:AwACCAMABRQAAA==.',['�']='萌萌小牛:AwABCAEABRQAAA==.萨丨尔:AwAECAcABRQCAQAEAQjkEAAUqsgABRQAAQAEAQjkEAAUqsgABRQAAA==.',['�']='蒋雯眀:AwACCAQABRQAAA==.',['�']='蓝牛蛙:AwADCAMABAoAAA==.',['�']='藍蓮:AwADCAMABAoAAA==.',['�']='血之晨曦:AwACCAIABAoAAA==.',['�']='诶呀诶呀:AwAICAgABAoAAA==.',['�']='谭宇冠:AwAECAEABRQAAA==.',['�']='贝啦啦贝拉:AwAFCAUABAoAAA==.',['�']='赫拉克勒斯乄:AwAICAEABAoAAA==.起手嗜血:AwAECAQABRQAAA==.',['�']='超强元素:AwAICAgABAoAAA==.越狱兔丶:AwAGCAYABAoAAQcAW7IDCAgABRQ=.',['�']='跑的快:AwACCAQABRQAAA==.',['�']='躲猫猫袋盐人:AwAECAQABRQAAA==.',['�']='达格栏:AwAHCAcABAoAAA==.',['�']='过来:AwAECAQABRQAAA==.迷基揍敵客:AwAICAgABAoAAA==.追击猎杀:AwADCAMABAoAAA==.追风小指:AwAICAgABAoAAA==.',['�']='逆天轰鸣灬:AwAICBcABAoDHQAHAQhTNABCebcBBAoAHQAHAQhTNABCebcBBAoAEAAFAQgqOgA5QwIBBAoAAA==.逍遥熊猫人:AwADCAEABRQAAQgAAAAICAQABRQ=.',['�']='那些年的日子:AwAHCAcABAoAAA==.邪恶的果冻:AwAFCAUABAoAAA==.邪能利刃:AwAICAgABAoAAA==.邪辟罪惡:AwAGCAsABAoAAA==.',['�']='醉酒踏云织雾:AwACCAIABRQAAA==.',['�']='野顾丶丶:AwAGCBIABRQDHgAGAQgTAABJ6g0CBRQAHgAGAQgTAABJ6g0CBRQABwABAQhqPAAJXEYABRQAAQgAAAAICAEABRQ=.',['�']='银色丶子弹:AwAECAYABRQCAwAEAQhpBQBbLT0BBRQAAwAEAQhpBQBbLT0BBRQAAA==.',['�']='锡兰:AwAECAQABRQAAA==.锰男:AwACCAMABRQAAA==.',['�']='闲云:AwAICAgABAoAAA==.闹闹猫:AwAFCAUABAoAAA==.',['�']='阿哦呃:AwABCAEABAoAAA==.阿狸酱:AwABCAEABRQAAA==.',['�']='陈托蒂:AwAFCAUABAoAAA==.',['�']='随懿施法:AwAGCAIABRQAAA==.',['�']='雅仔小迷弟:AwAICAgABAoAAA==.雨下个不停:AwAICAgABAoAAA==.零落丶:AwAGCAwABAoAAA==.',['�']='霁月不遇:AwAECAQABRQAAQgAAAAGCAMABRQ=.',['�']='风尘灬尜醉:AwAICAgABAoAAA==.',['�']='骑骑子:AwACCAIABRQAAA==.',['�']='高贵的阿苏斯:AwACCAIABRQAAA==.',['�']='鬼宠:AwAECAQABAoAAA==.',['�']='魁拔之首:AwAGCAoABAoAAA==.',['�']='鲁修拉:AwAECAQABRQAAQMAPf8GCAkABRQ=.',['�']='鳳凰:AwAICAgABAoAAA==.',['�']='鹿梦辰:AwACCAIABAoAAA==.',['�']='麻烦奶一口:AwAECAQABRQAAA==.',['�']='黄四狼:AwACCAIABAoAAA==.黑夜的新途:AwADCAcABRQCBgADAQiBEQAa2b4ABRQABgADAQiBEQAa2b4ABRQAAA==.黑游侠领主:AwAICAUABAoAAA==.',['�']='龙族执法队长:AwABCAIABRQDCgAHAQh7KQAmfSUBBAoACgAHAQh7KQAmfSUBBAoAHwABAQhzCAAadhwABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end