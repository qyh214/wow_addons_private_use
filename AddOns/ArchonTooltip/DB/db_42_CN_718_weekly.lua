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
 local lookup = {'Evoker-Devastation','Hunter-BeastMastery','Druid-Restoration','Druid-Balance','Mage-Fire','Monk-Windwalker','Shaman-Enhancement','Hunter-Marksmanship','Shaman-Restoration','DeathKnight-Blood','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Arms','Warrior-Protection','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Frost','Mage-Frost','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Monk-Mistweaver','Shaman-Elemental','Unknown-Unknown','Priest-Holy','Priest-Discipline','Paladin-Retribution','Druid-Guardian','Priest-Shadow','Monk-Brewmaster',}; local provider = {region='CN',realm='梦境之树',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ag='Agito:AwAECAQABRQAAA==.',Ay='Ayudragon:AwAGCAgABRQCAQAGAQilAABBbt8BBRQAAQAGAQilAABBbt8BBRQAAA==.',Bi='Bigboom:AwAECAQABRQAAA==.',Bl='Blackzxz:AwAGCA0ABRQCAgAFAQgRBQAqdUEBBRQAAgAFAQgRBQAqdUEBBRQAAA==.',Bo='Bovinee:AwACCAQABRQCAwAIAQh6DQBNIUICBAoAAwAIAQh6DQBNIUICBAoAAA==.',Br='Bror:AwABCAIABRQAAA==.',Ca='Calmly:AwACCAMABRQAAA==.',Cj='Cjj:AwAECAQABAoAAA==.',Dk='Dkld:AwAGCAYABAoAAA==.',Ed='Edada:AwAGCAYABAoAAA==.',El='Elzayork:AwABCAEABRQAAA==.',Ja='Jaghatai:AwAECAcABRQCBAAEAQhUJgAazUsABRQABAAEAQhUJgAazUsABRQAAQUAQ8QICAcABRQ=.',Ju='Juso:AwAECAYABRQCBgAEAQgyCQArCeAABRQABgAEAQgyCQArCeAABRQAAA==.',Ke='Keaz:AwADCAUABRQCBAADAQgNEAAp2OUABRQABAADAQgNEAAp2OUABRQAAA==.',La='Lazrael:AwAECAQABAoAAA==.',Lo='Lovelisa:AwACCAQABRQAAA==.Loveynana:AwACCAIABRQAAQcAPEQGCAgABRQ=.',Mi='Miku:AwAICDAABAoDAgAIAQg+GQBVTX4CBAoAAgAIAQg+GQBTp34CBAoACAACAQgFTgBAnpYABAoAAA==.',Ni='Nightelfhunt:AwAGCAgABAoAAA==.Nightgale:AwAECAQABRQAAA==.nikka:AwACCAIABRQAAA==.',No='Noonecity:AwAECAUABRQCCQAEAQhwDQAkv90ABRQACQAEAQhwDQAkv90ABRQAAA==.',Oo='Ookami:AwADCA0ABRQCCgADAQgdAwBb2T0BBRQACgADAQgdAwBb2T0BBRQAAA==.',Pe='Peashooter:AwADCAMABAoAAA==.',Pu='Pussinboot:AwAECAQABRQAAQMAN/cGCAYABRQ=.',Re='Remote:AwAFCAcABRQCCwAFAQjEAgBAWHYBBRQACwAFAQjEAgBAWHYBBRQAAA==.',Sh='Shadowlight:AwAGCAYABAoAAA==.Shionne:AwAICAgABAoAAA==.',So='Soyo:AwAECAQABRQAAA==.',Su='Superbiadht:AwADCA8ABRQCDAADAQg0AwBGLvIABRQADAADAQg0AwBGLvIABRQAAA==.Superbiaplad:AwAECAgABAoAAQwARi4DCA8ABRQ=.',Ti='Tingnan:AwACCAIABAoAAA==.',To='Topeulleque:AwAECAIABRQAAA==.',Va='Vadesaas:AwAECAYABAoAAQ0AL7QCCAIABRQ=.Vadesas:AwACCAIABRQEDQAIAQirHAAvtJ8BBAoADQAHAQirHAAw4p8BBAoADgAGAQhfGgAwtQIBBAoADwABAQiyhQAR6jEABAoAAA==.',Wo='Wowhunterq:AwACCAIABAoAAA==.',Zu='Zues:AwABCAEABAoAAA==.',Ev='evilxiaowei:AwAICA8ABAoAAA==.',['�']='一只小咕咕:AwAGCAsABAoAAA==.一只小锤锤丶:AwAGCAIABAoAAA==.一场久别重逢:AwACCAIABRQAAA==.一拳:AwACCAMABRQAAA==.一梦星河:AwAICAoABAoAAA==.一粒落尘:AwAFCAEABAoAAA==.不会就是不会:AwAGCBcABAoCCQAGAQgLawAT0s0ABAoACQAGAQgLawAT0s0ABAoAAA==.不羁的橙子:AwADCAMABRQAAA==.世君:AwAECAQABRQAAA==.世界第一骑士:AwAECAQABRQAAA==.丘芭比姆涅牛:AwAICAgABAoAAA==.东北森姐:AwAFCAUABAoAAA==.丨冬乄至丶:AwAECAQABRQAAQUAMkEGCAgABRQ=.丨拱拱丨:AwAFCAUABAoAAA==.丶戰前女神:AwAECAcABRQDAgAEAQjjHQAh260ABRQAAgAEAQjjHQAUuK0ABRQACAACAQhsGAAkWUkABRQAAA==.丸辣:AwAICBYABAoDCwAIAQg4HQBKIjUCBAoACwAIAQg4HQBKIjUCBAoADAAEAQgRMgBCj9EABAoAAA==.丿莫问:AwAGCAYABAoAAA==.',['�']='乄镜影乄:AwAGCAsABAoAAA==.乐千言:AwACCAIABAoAAA==.九天添天添:AwAHCAcABAoAAA==.',['�']='二月六:AwACCAIABRQAAA==.二月战:AwAFCAEABAoAAA==.二月的春水:AwAGCAEABAoAAA==.云野:AwACCAQABRQCDwAIAQi7EABNBGsCBAoADwAIAQi7EABNBGsCBAoAAA==.五线乐谱:AwACCAIABRQAAA==.亚顿之矛丶:AwAGCAYABAoAAA==.人海中的孤影:AwAGCAgABAoAAA==.人间正道:AwABCAEABAoAAA==.',['�']='仿身泪滴:AwABCAEABRQAAA==.',['�']='伊云言:AwAICA0ABAoAAA==.伊利达雷之怒:AwAECAQABRQAAA==.伊厉丹之影:AwABCAEABRQAAA==.伊尔的执着:AwAECAQABAoAAA==.伊格诺斯:AwACCAQABRQCCwAIAQhlGgBIT0oCBAoACwAIAQhlGgBIT0oCBAoAAA==.似水如鱼:AwAECAQABRQAAQQAMF4GCAwABRQ=.',['�']='修罗大宗师:AwACCAIABRQAAQoAGX4ECAwABRQ=.',['�']='六爺的城:AwAGCAkABAoAAA==.',['�']='凝阶似花积:AwAICAgABAoAAA==.击剑小药娘:AwAECAQABRQAAA==.',['�']='别打我我胆小:AwAFCAUABAoAAA==.刹那清欢:AwACCAMABRQAAA==.',['�']='力强如智:AwAECAQABRQAAA==.',['�']='勾世:AwAGCAkABAoAAQ0AS5IGCBAABRQ=.',['�']='医院有毕超:AwADCAMABAoAAA==.',['�']='千万千万:AwADCAUABAoAAA==.千指喵哲:AwACCAIABRQAAA==.卓越的犇犇:AwACCAIABRQAAA==.单面体:AwAECAIABRQAAA==.南岸靑栀:AwAICCYABAoDEAAIAQhGBQBeEOQCBAoAEAAIAQhGBQBeEOQCBAoAEQAEAQh9IAA8tJUABAoAAA==.卿云:AwACCAIABRQAAA==.',['�']='受祝福的牛牛:AwAFCAUABAoAAA==.叮咬:AwAHCAoABAoAAA==.',['�']='吃我一摔绊:AwAICAgABAoAAA==.吃茄子的狼丶:AwAGCAkABAoAAA==.吃饱了睡:AwABCAEABAoAAA==.听南:AwADCAMABAoAAA==.',['�']='哆嗦小萌猎:AwADCAMABRQAAA==.哈骷纳玛他她:AwAGCAgABAoAAA==.',['�']='啊坤:AwAICA8ABAoAAA==.',['�']='困阿:AwADCAcABRQDEgADAQgvBQA0ePMABRQAEgADAQgvBQA0ePMABRQABQABAQiSMQAYokMABRQAAA==.',['�']='圆融圣光:AwAECAcABAoAAA==.圆融恶魔:AwAICBUABAoCDAAIAQjLIQAjljoBBAoADAAIAQjLIQAjljoBBAoAAA==.土豆白菜:AwAHCAoABAoAAA==.圣光大熊喵:AwAGCAkABAoAAA==.圣光守护者:AwAFCAUABAoAAA==.圣白炽焰:AwAECAQABRQAAA==.',['�']='埃尔霖分:AwAICBgABAoCCQAIAQjDNwAtOYABBAoACQAIAQjDNwAtOYABBAoAAQUAJ70GCAoABRQ=.',['�']='夏夏韭菜丶:AwAGCAEABRQAAA==.夜梦:AwAGCAoABAoAAA==.夜青澜:AwAGCAUABAoAAA==.大松树:AwAGCAYABAoAAA==.太谷饼:AwABCAEABRQAAA==.',['�']='奶霸李维斯:AwABCAEABRQAAA==.好大的凶器:AwAGCAUABAoAAA==.',['�']='孙六空:AwAFCAgABAoAAA==.孤寡老仁:AwAFCAIABAoAAA==.孤独时代的梦:AwAGCAkABAoAAA==.孤高的杰克:AwAECAQABRQAAA==.',['�']='宇佐见莲子:AwABCAEABAoAAA==.守猎时光:AwABCAEABRQAAA==.安斧天高辽:AwAICAcABAoAAA==.官人丨哈酒:AwABCAEABRQAAA==.官人丨想要:AwABCAEABRQAAA==.实习浪客:AwAICAgABAoAAA==.害羞七:AwAHCAcABAoAAA==.',['�']='小七别吃了:AwABCAEABAoAAA==.小七真能犟:AwAHCAcABAoAAA==.小五的小栗子:AwAHCAcABAoAAA==.小小糯米团:AwAGCAYABAoAAA==.小昭杨:AwAGCAEABAoAAA==.小橘猫的笑容:AwADCAgABRQCDwADAQgeEAATQ9oABRQADwADAQgeEAATQ9oABRQAAA==.小法花:AwACCAIABAoAAA==.小狗飞踢:AwAECAgABRQCEQAEAQgZAgAqLvMABRQAEQAEAQgZAgAqLvMABRQAAA==.小红是我的:AwADCAMABAoAAA==.小萨壹号:AwAECAQABRQAAA==.尽死生之力:AwABCAEABRQDEgAIAQjQOgA6ClEBBAoABQAIAQg4PgAh9nwBBAoAEgAHAQjQOgA3f1EBBAoAAA==.',['�']='屁嗝嗝:AwAECAQABRQAAQQARTUHCAcABRQ=.屑屑河野华:AwAECAQABRQAAA==.屡德:AwADCAEABRQAAA==.山上那头驴:AwAHCBYABAoEEwAHAQgIOAA8nHEBBAoAEwAGAQgIOABAiHEBBAoAFAABAAgAAAAo/QAABAoAFQABAQjdbwAAAAAABAoAAA==.',['�']='巅峰哥:AwAECAQABAoAAA==.',['�']='布湿戈门:AwABCAEABRQAAA==.希昀:AwABCAEABRQAAA==.',['�']='幻化三生:AwACCAUABRQCBgACAQhoDwAvk5EABRQABgACAQhoDwAvk5EABRQAAA==.幽涧白龙:AwAGCBAABAoAAA==.幽默术:AwAFCAYABAoAAA==.',['�']='开心厚抹灬:AwAECBIABRQCFgAEAQjiAgBidVsBBRQAFgAEAQjiAgBidVsBBRQAAA==.弑魂黑骑:AwAGCAUABAoAAA==.张喜喜:AwAICAYABAoAAA==.张喜喜丶:AwAICAgABAoAAA==.弥诺陶洛斯:AwAECAQABRQAAA==.',['�']='德朗尼:AwAECAQABAoAAA==.德溘逝:AwAFCAEABAoAAA==.德莱娅:AwABCAEABRQAAA==.',['�']='心生法生:AwAICAgABAoAAA==.',['�']='恩静:AwAFCAUABAoAAA==.',['�']='悲伤的恋人:AwAECAQABRQAAA==.',['�']='愿无忧:AwADCAMABRQAAA==.愿无惑:AwABCAEABRQAAA==.',['�']='慕銫:AwAICA8ABAoAAA==.',['�']='憨憨的壹休:AwAFCAUABAoAAA==.',['�']='我是你的眼睛:AwAGCAoABAoAAA==.战场原荡漾:AwAECAUABRQCCAAEAQgbCgAybtYABRQACAAEAQgbCgAybtYABRQAAQgAVdsICAgABRQ=.战神乌鸦:AwABCAEABRQAAA==.戾刃:AwAICBAABAoAAA==.',['�']='托遗响于悲风:AwACCAIABRQAAA==.执笔丨话她:AwAICBYABAoDCQAIAQjHKgA0t7oBBAoACQAIAQjHKgA0t7oBBAoAFwABAQh5fgAAAAAABAoAAA==.执笔丶话她:AwACCAIABRQCCAAIAQieEgBEzwwCBAoACAAIAQieEgBEzwwCBAoAAA==.扳手大王:AwACCAIABAoAARgAAAABCAIABRQ=.',['�']='投河自尽的鱼:AwAICAgABAoAAA==.折镜:AwAECAgABRQCBQAEAQgWHAAWW8YABRQABQAEAQgWHAAWW8YABRQAAA==.',['�']='按住那北鼻丶:AwABCAEABRQDGQAIAQjQEABFtSoCBAoAGQAIAQjQEABFtSoCBAoAGgADAQhYawAqU1wABAoAAA==.',['�']='斟一杯温柔:AwAECAwABRQCFgAEAQiIBwBMTQwBBRQAFgAEAQiIBwBMTQwBBRQAAA==.新一代东东:AwAICAgABAoAAA==.',['�']='无敌华哥:AwAECAEABRQCAgAIAQgZFgBUPZACBAoAAgAIAQgZFgBUPZACBAoAAA==.旺旺屁:AwABCAEABAoAAA==.',['�']='明朝流苏:AwABCAEABRQAAA==.星空落子:AwAECAQABRQAAA==.',['�']='暗夜竹:AwAGCAcABAoAAA==.暨言千百回:AwABCAEABAoAAA==.',['�']='曾经游龙戏凤:AwAICAgABAoAAA==.',['�']='月下弥音:AwABCAEABAoAAA==.月映殘雪:AwAECAQABRQAAA==.有点小忙:AwAICAgABAoAAA==.有猫饼:AwACCAMABRQAAA==.',['�']='杜言她:AwAICAgABAoAAA==.来一打怪:AwAFCAUABAoAAA==.杨刀刀:AwAECAUABRQDCwAEAQhoEAAtyusABRQACwAEAQhoEAAtyusABRQADAABAQhdFAAZfDMABRQAAA==.杨如画:AwAICCYABAoDAgAIAQjEGQBPs3wCBAoAAgAIAQjEGQBPs3wCBAoACAADAQhMSwAvM6EABAoAAA==.',['�']='梓哲:AwAICBEABAoAAA==.梦若丶风:AwACCAIABRQDGgAIAQhSJQAzanoBBAoAGgAIAQhSJQAsaHoBBAoAGQAEAQgWXAA0Yp8ABAoAAA==.',['�']='欧拉欧拉丶:AwAGCAYABAoAAA==.',['�']='步丶惊云:AwAICA4ABAoAAA==.死亡之龙:AwAGCAcABAoAAA==.死掉的木头:AwAGCAsABAoAAA==.',['�']='殷端午:AwAGCAwABAoAAA==.',['�']='毕尤就完事了:AwABCAIABRQDBQAHAQjPKQBKJewBBAoABQAHAQjPKQBKJewBBAoAEgACAQjDhAAz0l8ABAoAAA==.毛企鹅:AwAGCAkABAoAAA==.毛琉:AwAGCAgABAoAAA==.',['�']='水晶饺:AwAGCAYABAoAAA==.',['�']='沅芷澧兰:AwAFCAUABAoAAA==.沉默无言:AwAFCAUABAoAARgAAAAGCAYABAo=.沙莉:AwAECAQABRQAAA==.',['�']='海绵丨宝宝:AwAICBcABAoCGwAIAQhDKABO6V8CBAoAGwAIAQhDKABO6V8CBAoAAA==.',['�']='淇云云丶:AwACCAIABRQAAA==.深海狮子:AwACCAMABRQAAA==.',['�']='清纯女大学生:AwAHCAwABAoAAA==.游魂:AwACCAQABRQAAA==.',['�']='灵魂汁子:AwAICBQABAoCEQAIAQi6BwBDrB4CBAoAEQAIAQi6BwBDrB4CBAoAAA==.',['�']='炎之十月:AwABCAMABRQCEwAIAQjAKQAxqrgBBAoAEwAIAQjAKQAxqrgBBAoAAA==.炭烧苏妲己:AwAGCAoABAoAAA==.',['�']='热爱学习:AwABCAMABRQAAA==.',['�']='爱力丝:AwAICBQABAoCEAAIAQhjIQBCIA8CBAoAEAAIAQhjIQBCIA8CBAoAAA==.爱生活的大牛:AwAICAgABAoAAA==.',['�']='牛顿一二三:AwADCAYABRQCFwADAQgjBQBBGvgABRQAFwADAQgjBQBBGvgABRQAAA==.牧灬圣光:AwAHCAcABAoAAA==.',['�']='狂龙之怒:AwACCAMABRQCDwAIAQg9BgBaf9ACBAoADwAIAQg9BgBaf9ACBAoAAA==.狄克推多鷉:AwABCAEABRQCHAAIAQjZBwA7YrkBBAoAHAAIAQjZBwA7YrkBBAoAAA==.狐尾瓜:AwAHCBAABAoAAA==.狐狸麦麦:AwAGCAkABAoAAA==.',['�']='玉蟾:AwACCAIABRQAAA==.王大牛:AwAFCAUABRQDEgAFAQi3AwA7WQkBBRQAEgAEAQi3AwBM3gkBBRQABQABAQjWLQAGzE4ABRQAAQUAGscGCAcABRQ=.',['�']='珊蒂斯羽月:AwAECAQABRQAAA==.',['�']='疯狂的胡图图:AwACCAIABRQAAA==.',['�']='盘丝洞花蜘蛛:AwAHCAsABAoAAA==.相川步:AwADCAkABRQCGwADAQj4AwBe5EEBBRQAGwADAQj4AwBe5EEBBRQAAA==.',['�']='睇唔到咯:AwAFCAwABAoAAA==.',['�']='碎蛋不留情:AwACCAIABRQAAQoAGX4ECAwABRQ=.',['�']='磐石丶蛮锤:AwAECAQABAoAAA==.',['�']='积极洋洋的:AwACCAIABAoAAA==.',['�']='笑笑太妃糖:AwAGCAYABAoAAA==.第一深情:AwAECAQABRQAAA==.',['�']='米利暗:AwAICAgABAoAAA==.',['�']='糖多多:AwAGCAUABAoAAA==.糖糖豆:AwAFCAUABAoAAA==.',['�']='索蘭尼亞戰歌:AwAGCAYABAoAARgAAAAECAQABRQ=.紫丨秋:AwAICAIABAoAAA==.紫夜:AwABCAEABAoAAA==.紫色的大拉锁:AwAECAQABAoAAA==.',['�']='红桥磕粉:AwABCAEABRQAAA==.红花村偷猪贼:AwAICAgABAoAAA==.纪律严明:AwADCAIABAoAAA==.纵使困顿难行:AwADCAMABAoAAA==.纸昕:AwADCAcABRQCEAADAQhlDgAr/toABRQAEAADAQhlDgAr/toABRQAAA==.',['�']='缇菈娜:AwADCAQABRQAAA==.',['�']='羊鹿鹿:AwABCAIABRQAAA==.',['�']='肚肚打雷了:AwAICAgABAoAAA==.',['�']='胖女巫:AwAECAQABRQAAA==.胡小来:AwAGCAYABAoAAA==.',['�']='腰颜货重:AwAGCAYABRQCBQAGAQiiAgAy7rEBBRQABQAGAQiiAgAy7rEBBRQAAA==.',['�']='艾大灰:AwABCAEABAoAAA==.艾尓雯:AwACCAIABAoAAA==.艾琳范克里夫:AwAICAkABAoAAA==.',['�']='芝士不如知非:AwAGCAoABRQCHQAGAQg9AgAqT48BBRQAHQAGAQg9AgAqT48BBRQAAA==.花也:AwAGCAoABRQCAgAGAQj4AABFr9kBBRQAAgAGAQj4AABFr9kBBRQAAA==.花凋人未央丶:AwAECAIABAoAAA==.',['�']='苍梧之野:AwAHCAcABAoAAA==.',['�']='荔小知:AwAICAgABAoAAA==.',['�']='莎布鱼神潘:AwAECAQABRQAAA==.',['�']='菈雯妲:AwAHCAYABAoAAA==.菠萝可乐达:AwABCAEABAoAAA==.',['�']='萌新玩部落:AwAGCAMABAoAAA==.萝卜炖蓝猫:AwADCAIABRQAAA==.',['�']='蓝彩蝶:AwAECAIABRQAAA==.',['�']='虚空之神:AwABCAEABRQAAA==.',['�']='蚂蚁赦了:AwAICA0ABAoAAA==.',['�']='蛟爷爱吃鱼:AwACCAIABRQAAA==.',['�']='蝴蝶型的小学:AwAECAQABRQAAA==.',['�']='血狸:AwACCAIABRQAAA==.',['�']='观察员先生:AwAGCAkABAoAAA==.',['�']='贿赂地狱:AwAGCAYABAoAAA==.',['�']='赤炎之语:AwABCAEABRQEHQAIAQi6HgAvLrsBBAoAHQAIAQi6HgAvLrsBBAoAGgABAQhmfwAUxy0ABAoAGQABAQgKhgAJcCoABAoAAA==.',['�']='超成:AwAECAQABAoAAQYAVU4ECAwABRQ=.超苏维:AwACCAIABAoAAA==.',['�']='踏梦寻芳:AwABCAQABRQCDAAIAQhTJwAiYBEBBAoADAAIAQhTJwAiYBEBBAoAAA==.',['�']='转么么:AwAHCAcABAoAAA==.转转小马车:AwAICAgABAoAAA==.',['�']='辰灬小柒:AwAECAQABRQAAA==.',['�']='迪凯晒太阳:AwAICA4ABAoAAA==.迪菲亚悟道者:AwAECAgABRQCHgAEAQh1BAAbFpgABRQAHgAEAQh1BAAbFpgABRQAAA==.',['�']='逍遥无忧:AwACCAIABRQAAA==.逐露:AwAECAIABRQAAA==.逼王范德彪:AwAICAkABAoAAA==.',['�']='遮沙蔽风了:AwADCAcABRQDAwADAQi+BwBepdQABRQAAwACAQi+BwBcDtQABRQABAABAQirJQAgkk0ABRQAAA==.',['�']='那个戦士:AwADCAUABAoAAA==.',['�']='银沙王:AwAICAgABAoAAA==.',['�']='锤你一脸:AwACCAIABRQAAA==.',['�']='闪光的猪:AwAGCAYABRQCGwAGAQjXGwArdNUABRQAGwAGAQjXGwArdNUABRQAAA==.闲心逛:AwAICAoABAoAAA==.',['�']='阳光十九:AwABCAEABRQAAA==.阿升的低潮期:AwAGCAkABAoAAA==.阿巴克:AwAGCA8ABAoAAQMAXqUDCAcABRQ=.',['�']='陨丨落:AwABCAEABRQAAA==.',['�']='隰有游龙:AwAECAQABRQAAA==.',['�']='雪狸:AwACCAIABRQAAA==.零星一点:AwAHCAwABAoAAA==.',['�']='霜露:AwAGCAYABAoAAA==.',['�']='青丘山白狐狸:AwAICAgABAoAAA==.青眼白龙:AwAGCAYABAoAAA==.',['�']='香麝小雪狸:AwAICBQABAoCBwAIAQgAEgBMxC0CBAoABwAIAQgAEgBMxC0CBAoAAA==.',['�']='魔剑萨满:AwAECAgABRQDFwAEAQg6BwArluEABRQAFwAEAQg6BwArluEABRQACQACAQhgFQBKtqYABRQAAA==.',['�']='鱼无姬:AwAECAQABRQAARgAAAAGCAMABRQ=.',['�']='鲨琪玛:AwAGCAsABAoAAA==.',['�']='鸡楠:AwACCAIABRQAAA==.',['�']='黑色的白:AwAICAwABAoAAA==.',['�']='龍庫庫:AwAGCAoABAoAAA==.龙城乄九天:AwADCAUABAoAAQUAVMEGCAgABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end