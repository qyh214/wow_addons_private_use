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
 local lookup = {'Mage-Frost','Mage-Fire','Unknown-Unknown','DeathKnight-Blood','Warrior-Fury','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Arms','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','Warrior-Protection','Warlock-Destruction','Priest-Shadow','Priest-Discipline','Evoker-Devastation','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='风暴之怒',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ab='Absolution:AwADCAMABAoAAA==.',Ac='Acmestorm:AwAECAMABRQAAA==.',An='Andystar:AwAECAQABRQAAA==.',Ar='Aragakiyui:AwACCAMABRQAAA==.',Be='Beast:AwAICAgABAoAAA==.',Dw='Dwarfmage:AwACCAIABAoAAA==.',El='Elapsed:AwACCAMABRQAAA==.',Er='Erica:AwAECAgABRQCAQAEAQggBwBONeMABRQAAQAEAQggBwBONeMABRQAAA==.',Fo='Forillidan:AwAHCAcABAoAAA==.',Ga='Gazz:AwAICAoABRQCAgAGAQgFAgBIbuABBRQAAgAGAQgFAgBIbuABBRQAAA==.',Ha='Hardy:AwABCAEABRQAAA==.',Ho='Holylight:AwAECAQABRQAAA==.Holyraven:AwAICAkABAoAAQMAAAAGCAQABRQ=.',Ja='Jane:AwAECAQABRQAAA==.',Kt='Ktcxwsm:AwAICBIABAoAAA==.',Ky='Kyogree:AwAFCAEABAoAAA==.',Le='Leonwon:AwAICAsABAoAAA==.',Ma='Mansteinn:AwAHCAQABAoAAA==.',Mo='Mooncoo:AwAFCAYABAoAAA==.',Ne='Nefeltari:AwAECAQABRQAAA==.',Ni='Nickolas:AwACCAIABRQAAA==.',Pi='Picco:AwAECAgABRQCBAAEAQiDAgBgWVIBBRQABAAEAQiDAgBgWVIBBRQAAA==.',Sa='Sandyv:AwAECAQABAoAAA==.',Su='Supershawn:AwAECAIABRQAAA==.',Ve='Vei:AwABCAIABRQCBQAIAQjwLQAmN7YBBAoABQAIAQjwLQAmN7YBBAoAAA==.',Vv='Vvallopriest:AwAHCAEABAoAAA==.',Xm='Xmen:AwAGCAcABAoAAA==.',Zj='Zjsm:AwAICAcABAoAAA==.',['�']='一别打我一:AwAECAgABRQDBgAEAQgIEwAz7+EABRQABgAEAQgIEwAz7+EABRQABwADAQiqEQAseIAABRQAAA==.一年起步:AwAECAQABRQAAA==.一怒乱红尘:AwAGCAgABAoAAA==.一怒吼韧一:AwAECA4ABRQDCAAEAQhJGAAusOIABRQACAADAQhJGAAusOIABRQACQACAQiLHwAW7joABRQAAA==.一眼千年:AwAECAQABRQAAA==.三二一二三:AwAICBYABAoCBwAIAQhuGgA9LNABBAoABwAIAQhuGgA9LNABBAoAAA==.三年起步:AwAICAUABAoAAA==.丨猴哥丨:AwACCAIABAoAAA==.丨翻滚吧丨:AwACCAMABRQAAA==.丶丶啦啦琳:AwAGCAQABAoAAA==.丶凉茶:AwAFCAUABAoAAA==.',['�']='乄天灰乄:AwAECAQABRQAAA==.九指德神:AwABCAEABAoAAA==.',['�']='二年起步:AwAECAEABRQAAA==.二得则:AwAICAgABAoAAA==.云儿轻轻飞呀:AwAECAQABRQAAA==.云霄战将:AwAECAQABRQAAA==.五九九:AwAECAQABRQAAA==.亚萨:AwAGCAkABAoAAA==.',['�']='伍思凯:AwAICAgABAoAAQMAAAAHCAQABRQ=.伦道夫卡特:AwADCAMABRQAAA==.',['�']='你好贪吃啊:AwAICAgABAoAAA==.',['�']='依尔柳霸:AwAECAQABRQAAA==.',['�']='倒流时间:AwAECAQABRQAAA==.',['�']='偷拐抢骗:AwACCAMABRQAAA==.',['�']='八百年不许变:AwACCAIABRQAAA==.兰斯博顿:AwAGCAYABRQCAgAGAQhlAQBOev4BBRQAAgAGAQhlAQBOev4BBRQAAA==.',['�']='冷杀:AwADCAMABAoAAA==.',['�']='凫地魔:AwADCAEABRQAAQgAShkGCA4ABRQ=.',['�']='刘小兔:AwAECAEABRQAAA==.刘羽禅:AwAGCAIABRQAAA==.初级元素法師:AwAGCAUABAoAAQIAL9sGCAgABRQ=.',['�']='北海龍王:AwACCAIABRQAAQMAAAAICAQABRQ=.',['�']='半仙:AwAICAgABAoAAA==.半城烟沙丶:AwAICAgABAoAAA==.南风知我意:AwAFCAUABAoAAQoASFcCCAQABRQ=.卵壳:AwACCAIABRQAAA==.',['�']='原味鸡堡:AwAICAIABAoAAA==.',['�']='叶落知球:AwABCAEABRQDCwAIAQibOQAomn8BBAoACwAIAQibOQAomn8BBAoADAAEAQiiTwAnGLEABAoAAA==.',['�']='合欢宗小师妹:AwAFCAYABAoAAA==.吱唔猪:AwADCAMABRQAAA==.吹夢到西洲:AwAICAYABAoAAQoASFcCCAQABRQ=.',['�']='呆毛守护者:AwABCAEABAoAAA==.',['�']='咕噜喵:AwABCAEABAoAAA==.',['�']='哒萌奶牛:AwAGCAYABAoAAA==.',['�']='唯一的狼:AwACCAcABRQCDQACAQiNNwAQM3UABRQADQACAQiNNwAQM3UABRQAAA==.',['�']='喧瑄渲:AwAECAQABAoAAA==.喵德是我偶像:AwAECAIABAoAAA==.',['�']='嘴哥是个萨满:AwABCAEABRQAAA==.',['�']='团灭了剩骑士:AwAECAQABRQAAA==.',['�']='圆润润:AwABCAEABRQAAA==.圣光小地瓜:AwAECAQABRQAAA==.圣十叁:AwACCAQABRQAAA==.圣拾壹:AwACCAIABAoAAA==.',['�']='坠落彼岸:AwAECAQABAoAAA==.坠落彼岸丶:AwACCAIABRQAAA==.',['�']='城塚翡翠:AwAFCAYABAoAAA==.',['�']='复制人:AwAFCAgABAoAAA==.夏晴天:AwAHCA0ABAoAAA==.夙愿丶:AwABCAEABRQAAQMAAAAECAMABRQ=.大肉咕噜:AwAECAQABRQAAA==.大鹅:AwAECAQABRQAAA==.天冷的可可贝:AwABCAEABAoAAA==.天國星墜:AwAECAQABRQAAA==.天是那天:AwAECAUABRQCAgAEAQhvGAAyEOIABRQAAgAEAQhvGAAyEOIABRQAAA==.天罚之罪:AwAICA4ABAoAAA==.',['�']='奥蒂卡:AwAECAQABRQAAA==.奸奇冠军勇士:AwAECAQABRQAAA==.好好的奶爸:AwAGCAEABAoAAA==.好家伙:AwADCAEABAoAAA==.好风凭借力:AwAECAgABRQCDgAEAQjGBgBE4RUBBRQADgAEAQjGBgBE4RUBBRQAAA==.',['�']='孙小毛丶:AwACCAUABRQCBQACAQiJHAAUlIQABRQABQACAQiJHAAUlIQABRQAAA==.',['�']='封之冬:AwACCAIABRQAAA==.小二浪:AwACCAMABRQAAA==.小刀哈斯卡:AwAECAQABRQAAA==.小师弟先进:AwABCAEABAoAAA==.小獸:AwAECAQABAoAAA==.小蛮夭儿:AwACCAIABAoAAA==.小阔爱:AwAGCAYABRQCCgAGAQheAABF8N0BBRQACgAGAQheAABF8N0BBRQAAA==.尛萘柰灬:AwACCAIABRQCCwACAQhLFQBFBLgABRQACwACAQhLFQBFBLgABRQAAA==.',['�']='島田半藏:AwABCAEABRQAAA==.',['�']='崇高必堕落:AwACCAIABRQAAQoASFcCCAQABRQ=.',['�']='巫喵王冲鸭:AwAICAgABRQDDwAEAQiaAgA0wucABRQADwAEAQiaAgAzaOcABRQADgAEAQjzEAAnENUABRQAAA==.',['�']='布拉德皮套:AwAECAQABRQAAA==.布罗尔熊皮:AwABCAIABRQAAA==.帕拉桀:AwAECAQABAoAAA==.',['�']='并不是锅:AwAHCAkABAoAAA==.幸福牛牛:AwABCAEABRQAAA==.幽魂灬祭:AwAECAEABAoAAA==.',['�']='很牛:AwAICBAABAoAAA==.很酷的年轻人:AwACCAQABRQAAA==.微笑的眼睛:AwAICBUABAoDCAAIAQhLOgA4//ABBAoACAAIAQhLOgA4//ABBAoACQADAQgkVwAfHYMABAoAAA==.',['�']='心言手语:AwACCAIABRQAAA==.',['�']='恐怖的死神:AwAECAQABRQDBQAIAQj+FQBFHUgCBAoABQAIAQj+FQBFHUgCBAoAEAABAQjSQgABjQMABAoAAA==.',['�']='情系寳寶:AwAICAgABAoAAA==.惡棍德:AwAECAQABAoAAA==.想揍它一拳:AwADCAMABRQAAA==.',['�']='我咋死了呢:AwAFCAUABAoAAA==.我家的狐狸啊:AwABCAEABRQAAA==.我要变强丶:AwAICAgABAoAAA==.',['�']='打断鬼才:AwAGCA0ABAoAAA==.',['�']='抱抱:AwAECAgABRQCDgAEAQgRBABZvjUBBRQADgAEAQgRBABZvjUBBRQAAA==.抹茶红豆派:AwAECAQABRQAAA==.抹茶虾球球:AwAECAQABRQAAA==.',['�']='指上叹冰:AwAECAQABAoAAA==.',['�']='敏敏特穆尔:AwAGCAYABAoAAA==.',['�']='无业游民:AwACCAIABRQAAA==.时光之泪:AwAICBAABAoAAA==.时晴时雨:AwAICAgABAoAAREAURkGCAkABRQ=.时间差不多喽:AwABCAEABAoAAA==.',['�']='星之魂:AwABCAEABRQAAA==.星星之怒:AwACCAIABRQAAA==.是五花肉哇:AwAHCAcABAoAAA==.',['�']='晚分吹行舟:AwAFCAUABAoAAA==.',['�']='暧乂昧:AwAGCAYABAoAAA==.暴力灬嘟嘟法:AwAECAQABRQAAQIARzEGCAkABRQ=.',['�']='月玲珑:AwAGCAQABRQAAQMAAAAICAIABRQ=.木南:AwAGCBAABRQDEgAGAQjwAABG79wBBRQAEgAGAQjwAABG79wBBRQAEwADAQiWFgAzP4wABRQAARQAIOMICAUABRQ=.',['�']='林深时雾起:AwAECAQABRQAAA==.',['�']='桀拉斯:AwAFCAYABAoAAA==.',['�']='梓轩丶:AwADCAQABAoAAA==.',['�']='楊家怪萝莉:AwACCAYABRQCCAAIAQg8RAAzEMoBBAoACAAIAQg8RAAzEMoBBAoAAA==.',['�']='橘子:AwAICBMABAoAAA==.',['�']='死亡体育生:AwADCAMABAoAAA==.',['�']='残乁恋:AwAICAgABAoAAA==.残乁梦:AwADCAUABRQCBQADAQj/EAAasOAABRQABQADAQj/EAAasOAABRQAAA==.',['�']='泷麒麟:AwABCAEABAoAAA==.',['�']='淮扬:AwABCAEABRQAAA==.深度求索:AwAICBAABAoAAA==.',['�']='清若游离丶:AwAECAQABRQAAA==.',['�']='灬烈刃:AwABCAMABRQDCAAIAQiEOABGHPcBBAoACAAIAQiEOABGHPcBBAoACQACAQi+XgA0LmwABAoAAA==.灬霸霸灬:AwABCAEABAoAAA==.灭日圣骑:AwACCAQABRQAAA==.灭日猎手:AwACCAQABRQAAA==.',['�']='熔岩芝士探员:AwAECAQABRQAAA==.',['�']='爆炒唔西迪西:AwAGCAYABAoAAA==.爆裂螺旋:AwACCAQABRQDDAAIAQjNAwBc++ECBAoADAAIAQjNAwBc++ECBAoACwAEAQh0QgBU0FwBBAoAAA==.',['�']='牛无双:AwAICAgABAoAAA==.',['�']='犀利小球:AwAECAQABRQAAA==.',['�']='狂暴思密达:AwAECAQABRQAAA==.独钓寒江:AwABCAEABRQAAA==.',['�']='玄月灬凨华:AwACCAMABRQCDQAIAQiIRwBBJf8BBAoADQAIAQiIRwBBJf8BBAoAAA==.王思思:AwAGCAEABRQAAA==.玲一歼灭天使:AwACCAIABAoAAA==.',['�']='疯狂小奶牛:AwAFCAUABAoAAA==.疾风天降:AwAICA4ABAoAAA==.',['�']='白芝麻熊:AwAICAgABAoAAQMAAAAICAIABRQ=.',['�']='眼里有激光:AwAECAQABRQAARUAPtMGCAoABRQ=.',['�']='破万法:AwAGCAYABAoAAA==.',['�']='碧蓝打击:AwACCAMABRQAAA==.',['�']='稔知丶:AwACCAIABAoAAA==.',['�']='空白灬悲伤:AwACCAIABAoAAA==.',['�']='笨大个儿:AwABCAEABAoAAA==.',['�']='筱丶梦:AwABCAIABRQAAA==.',['�']='粒粒皆辛苦:AwACCAMABRQAAA==.精灵丨兰兰:AwAECAIABAoAAA==.精灵丨喵喵:AwACCAIABRQAAA==.精灵丨妖妖:AwAFCAIABAoAAA==.精灵丨沐沐:AwAICAgABAoAAA==.精灵丨琪琪:AwACCAIABRQAAA==.精灵丨琳琳:AwACCAIABRQAAA==.精灵丨胖胖:AwAECAUABAoAAA==.精灵丨莎莎:AwAECAQABAoAAA==.精灵丨萌萌:AwACCAIABRQAAA==.',['�']='繁星:AwAECAQABAoAAA==.',['�']='红叶初雨:AwAECAQABRQAAA==.纤指素缘:AwAGCAYABRQCAQAGAQgFAABTNxACBRQAAQAGAQgFAABTNxACBRQAAA==.',['�']='给你一锤:AwABCAIABRQAAA==.',['�']='美卡琪:AwADCAMABAoAAA==.',['�']='耗子尾汁猎:AwAICAgABAoAAA==.',['�']='职业半仙丶:AwAECAQABRQAAA==.',['�']='胖坨坨:AwABCAEABRQAAA==.胡绪栋丷:AwAGCAMABRQAAA==.',['�']='莫丶:AwAICAgABAoAAA==.',['�']='菜批:AwACCAIABRQAAA==.',['�']='萨满鸡丝:AwAGCAYABAoAAA==.萨贝宁:AwAECAQABAoAAA==.',['�']='血蹄村村会计:AwAHCAwABAoAAA==.街溜子:AwAGCAYABAoAAA==.',['�']='謝垚:AwAECAgABRQCBQAEAQjqBABXxTEBBRQABQAEAQjqBABXxTEBBRQAAA==.',['�']='诸顺遂:AwADCAgABRQDFgADAQjkCAAhp9UABRQAFgADAQjkCAAR79UABRQAFwACAQj2DQAnkaAABRQAAA==.',['�']='谁不正經:AwAGCAYABAoAAA==.谁与争锋:AwABCAEABAoAAA==.',['�']='贪杯:AwACCAMABRQAAA==.',['�']='赠我空七喜:AwAECAUABRQCFwAEAQgUCAAx0ukABRQAFwAEAQgUCAAx0ukABRQAAA==.',['�']='趣多多丿:AwAGCAwABAoAAA==.',['�']='身板脆滚的快:AwAICAIABAoAAA==.',['�']='輕奏离殇:AwAECAcABAoAAA==.',['�']='转过身就能懂:AwAICAgABAoAAA==.轻咬你的耳朵:AwAECAQABRQAAA==.',['�']='辉煌之德:AwAGCAEABAoAAA==.',['�']='逆嶙:AwACCAMABRQAAA==.進化的小秃豆:AwAECAEABRQAAA==.',['�']='部落大松师:AwACCAIABRQAAA==.都交给你了:AwAECAQABRQAAA==.',['�']='酒酒鎏:AwAICAgABAoAAA==.',['�']='醉血天狼:AwAGCAYABAoAAA==.',['�']='重丶来:AwAGCAYABRQCAgAGAQipAwAvNagBBRQAAgAGAQipAwAvNagBBRQAAA==.野牛冲撞:AwACCAIABRQAAQMAAAAGCAIABRQ=.',['�']='锅包呦:AwAGCAQABRQAAA==.',['�']='长耳贼:AwAFCAYABAoAAQMAAAAGCAQABRQ=.',['�']='阿尒托莉雅:AwAGCAgABRQCDQAEAQgYEABJvQYBBRQADQAEAQgYEABJvQYBBRQAAA==.阿斯顿大帝:AwACCAIABRQAAA==.阿杜不喝澡水:AwACCAIABRQAAA==.',['�']='雪域之水:AwAGCAYABAoAAA==.',['�']='青栀琉璃裙:AwAGCBAABAoAAA==.',['�']='项羽:AwAECAQABRQAAA==.',['�']='风暴奋激隐士:AwAHCAcABAoAAA==.飘流的北风:AwABCAEABRQAAA==.飘渺梦魔:AwACCAIABRQAAA==.',['�']='饭还是得吃的:AwAICAkABRQCAgAEAQhZEQA9TvkABRQAAgAEAQhZEQA9TvkABRQAAQIASG4ICAoABRQ=.',['�']='驯龙女巫:AwAGCAYABAoAAA==.',['�']='骑士小肥圆:AwAICAgABAoAAA==.',['�']='高白白丶:AwACCAQABRQDCgAIAQjDDABIV0YCBAoACgAIAQjDDABGf0YCBAoABQAGAQiLPQA2R1sBBAoAAA==.高素质玩家功:AwAGCAcABAoAAA==.高素质玩家陈:AwADCAMABAoAAA==.',['�']='魔欣儿:AwACCAcABRQCEQACAQgdHwAYtXUABRQAEQACAQgdHwAYtXUABRQAAA==.',['�']='鱼香榴莲:AwAHCAcABAoAAA==.',['�']='鳝饿终有鲍:AwAICAYABAoAAQMAAAAGCAQABRQ=.',['�']='默读忧伤:AwAECAQABRQAAA==.',['�']='齁喉吼厚:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end