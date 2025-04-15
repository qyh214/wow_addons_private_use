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
 local lookup = {'Mage-Fire','Mage-Frost','DeathKnight-Blood','Evoker-Devastation','Warrior-Fury','Evoker-Preservation','Unknown-Unknown','Monk-Brewmaster','Warlock-Destruction','Rogue-Subtlety','Paladin-Retribution','Shaman-Restoration','Warrior-Arms','Druid-Restoration','Druid-Balance','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','DeathKnight-Unholy','Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Elemental','DemonHunter-Vengeance','Hunter-Survival','Druid-Feral','Warrior-Protection','Druid-Guardian','Rogue-Assassination','Rogue-Outlaw','Monk-Mistweaver','Monk-Windwalker','Paladin-Holy','Paladin-Protection',}; local provider = {region='CN',realm='利刃之拳',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Amen:AwACCAIABRQAAA==.',An='Annya:AwAECAQABAoAAA==.',Ar='Arrowdeath:AwAGCAoABAoAAA==.',Bb='Bbfox:AwAICB4ABAoDAQAIAQidBABdBOkCBAoAAQAIAQidBABdBOkCBAoAAgADAQhwgQA3eWcABAoAAA==.',Bi='Biubiuubill:AwAECAgABRQCAwAEAQhDDwAdC58ABRQAAwAEAQhDDwAdC58ABRQAAA==.',Ca='Cadian:AwADCAMABAoAAQQAXjIICK0ABAo=.Catskylol:AwAECAgABRQCBQAEAQglCQA6CwoBBRQABQAEAQglCQA6CwoBBRQAAA==.Caxtons:AwAGCAsABAoAAA==.',Ci='City:AwAICAEABAoAAA==.',Da='Daddario:AwAECAQABRQAAA==.',Do='Donk:AwAICK0ABAoDBAAIAQjiAQBeMu8CBAoABAAIAQjiAQBeMu8CBAoABgAIAQhOBQBDqDACBAoAAA==.',Ea='Easonhu:AwAFCAUABAoAAA==.',Fe='Fennekin:AwAGCAsABAoAAA==.',He='Healde:AwAICAcABAoAAA==.',Ja='Janneflus:AwAECAQABRQAAA==.',La='Laprairie:AwAGCAYABAoAAA==.',Lo='Lonewolf:AwABCAEABAoAAA==.',Me='Mecraches:AwAICAgABAoAAQcAAAAECAQABRQ=.',Mo='Moneyorange:AwAFCAgABAoAAA==.',Na='Nastykikoz:AwABCAEABAoAAA==.',Ne='Neilyoyo:AwABCAEABRQAAA==.',No='Nongshali:AwAFCAUABAoAAA==.',Pa='Patek:AwACCAIABRQAAA==.',Ra='Rain:AwAECAQABRQAAA==.',Ro='Rormanti:AwAECAQABRQAAA==.Roys:AwADCAMABAoAAA==.',Sa='Sanparker:AwAICAgABAoAAA==.',Se='Senky:AwABCAEABAoAAA==.',Sm='Smash:AwAECAwABRQCBQAEAQh3CQA8VwgBBRQABQAEAQh3CQA8VwgBBRQAAA==.',So='Sososoeasy:AwADCAYABRQCCAADAQgbBgAE12gABRQACAADAQgbBgAE12gABRQAAA==.',Te='Teacherrc:AwADCAEABAoAAA==.',Va='Vanquish:AwADCAsABRQCAQADAQjWEwAwcukABRQAAQADAQjWEwAwcukABRQAAA==.',Yi='Yigefashi:AwAICAsABAoAAA==.',['�']='一刀砍死我:AwAECAQABRQAAA==.一射到天亮:AwAICAsABAoAAA==.一恐龍一:AwACCAYABRQCCQACAQgIHQAev3IABRQACQACAQgIHQAev3IABRQAAA==.一棍子点死你:AwAHCAcABAoAAA==.一水间:AwACCAIABRQAAA==.一瓶牛二:AwAICAgABAoAAA==.一竿子顶死你:AwAICA8ABAoAAA==.三胖胖:AwAICA4ABAoAAQoAE9ADCAYABRQ=.两瓶牛二:AwAICBYABAoCCwAIAQjjUgBI49gBBAoACwAIAQjjUgBI49gBBAoAAA==.丨暮色丨:AwABCAEABAoAAA==.中发白胡啦:AwAECAQABRQAAA==.丸山彩:AwAHCAkABAoAAA==.丸辣:AwAECAQABRQAAA==.丹妮利丝:AwADCAMABAoAAA==.',['�']='乱世狂刀灬:AwAICAoABAoAAA==.',['�']='亡者哭嚎:AwACCAEABAoAAA==.',['�']='仗劍天涯:AwAFCAYABAoAAA==.',['�']='伊利达雷菊座:AwAECAQABRQAAA==.伊自摸塔塔开:AwAECAQABRQAAA==.会武术的流氓:AwADCAQABAoAAA==.伟大无需多言:AwAGCBMABAoAAA==.',['�']='余额丨不足:AwABCAEABRQAAA==.',['�']='依然乄尐盟:AwACCAYABRQCDAACAQgrEgBWnL4ABRQADAACAQgrEgBWnL4ABRQAAA==.侵兽:AwAFCAYABAoAAA==.',['�']='信仰圣光的我:AwADCAMABAoAAA==.信思琦:AwADCAEABAoAAA==.修灯宰地精:AwAECAcABRQCBQAEAQj2DQAl9O8ABRQABQAEAQj2DQAl9O8ABRQAAA==.修登森疯疯:AwADCAcABRQCBQADAQiSDwAkU+EABRQABQADAQiSDwAkU+EABRQAAA==.',['�']='偷偷藏不住:AwADCAMABAoAAA==.',['�']='傲寒:AwAGCAoABAoAAA==.',['�']='元芳:AwABCAEABRQAAA==.公孵熊猫:AwAICAgABAoAAA==.',['�']='冉闵杀胡令:AwADCAMABAoAAA==.冬的街路樹:AwAECAMABAoAAA==.冰淇淋丶:AwADCAIABRQAAA==.',['�']='几梦华胥舞:AwABCAEABAoAAA==.出水福龙:AwACCAIABRQAAA==.',['�']='加安上将:AwAGCA4ABRQCDQAGAQhUAAA9D9gBBRQADQAGAQhUAAA9D9gBBRQAAA==.',['�']='十二岁小徐生:AwAGCAsABAoAAA==.十六缸发动机:AwACCAQABRQAAA==.十字路口等我:AwABCAEABRQCDAAIAQh9RwAes0QBBAoADAAIAQh9RwAes0QBBAoAAA==.十胜石旁泪:AwAGCAoABAoAAA==.千里江陵:AwADCAkABRQDDgADAQgjBABQEREBBRQADgADAQgjBABQEREBBRQADwABAQhlKQAJjUMABRQAAA==.半岛丶:AwAICBEABAoAAA==.南墙的安总:AwAICAcABAoAAA==.南風:AwAHCAgABAoAAA==.',['�']='可乐要加冰丶:AwAECAYABRQCDAAEAQhNDAAm7OMABRQADAAEAQhNDAAm7OMABRQAAA==.司危:AwACCAMABRQAAA==.',['�']='向晚丶大魔王:AwAECAQABRQAAA==.吼爷:AwAHCAEABAoAAA==.',['�']='周无语:AwAGCAYABAoAAA==.周随意:AwAHCAQABAoAAQEAWWMGCBQABRQ=.',['�']='咕尔蛋:AwABCAEABAoAAA==.咩咩灭逗比:AwAGCBIABAoAAA==.咸鱼干:AwAGCAcABAoAAA==.',['�']='响叮当:AwACCAIABRQAAA==.哟呵康康:AwADCAEABRQAAA==.',['�']='喵喵小白兔:AwAFCAcABAoAAA==.喵老师丶丶:AwABCAEABAoAAA==.',['�']='噩梦的拂晓:AwABCAIABAoAAA==.',['�']='因沃壳:AwAECAwABRQDBAAEAQilBgBD0P8ABRQABAAEAQilBgBD0P8ABRQABgADAQgNBgAktngABRQAAQkAWSEGCAEABRQ=.',['�']='圣光护佑你:AwABCAEABAoAAA==.圣光照明:AwAICAwABAoAAA==.圣光赐我力量:AwABCAEABAoAAA==.',['�']='垚垚爱狗叫:AwAICAwABAoAAA==.垫过撸蔗:AwAFCAUABAoAAA==.',['�']='城下之盟:AwACCAMABRQAAA==.',['�']='堪忧踹:AwACCAYABRQCEAACAQh6HAA3tZgABRQAEAACAQh6HAA3tZgABRQAAA==.',['�']='塔达林毁灭者:AwAICAgABAoAAA==.',['�']='夏沫丶烟雨:AwABCAEABRQAAA==.夜之魔女:AwACCAMABRQAAA==.天亮想睡觉:AwAICBEABAoAAA==.天亮还想睡:AwACCAIABAoAAA==.天授唱诗人:AwACCAIABAoAAA==.天星冲日:AwAECAIABRQAAA==.天灾幻想杀手:AwACCAEABAoAAA==.',['�']='奥术大王丶:AwABCAIABRQAAA==.奶的真是寂寞:AwACCAcABRQCEQACAQiPDwBEELAABRQAEQACAQiPDwBEELAABRQAAA==.好客的亚楠人:AwACCAYABRQCEgACAQjGFAAwPo4ABRQAEgACAQjGFAAwPo4ABRQAAA==.',['�']='妮妮小奶包:AwACCAIABRQCDAAIAQjMGQBJzRcCBAoADAAIAQjMGQBJzRcCBAoAAA==.',['�']='孤泳僧:AwABCAEABRQAAA==.',['�']='宅灬尐玥:AwAICBcABAoCEwAIAQhfKQBMmuIBBAoAEwAIAQhfKQBMmuIBBAoAAA==.安娜杰:AwACCAEABAoAAA==.安静的小木瓜:AwAECAQABRQAAA==.宝児:AwAICBkABAoDFAAIAQhwNAAcC0IBBAoAFAAIAQhwNAAcC0IBBAoAEQABAQhkiAAKNB4ABAoAAA==.宠物健身教练:AwACCAIABAoAAA==.',['�']='寒芒丶:AwACCAIABRQAAA==.',['�']='小傲娇灬:AwAICBEABAoAAA==.小兰飞天:AwAECAEABAoAAA==.小小法爷:AwABCAEABAoAAA==.小屁猫崽子:AwADCAMABAoAAA==.小朋友砍你:AwADCAMABRQAAQcAAAAGCAQABRQ=.小涛涛:AwAGCAoABAoAAA==.小花生:AwAICAgABAoAAA==.小虎鸡蛋:AwAICAkABAoAAA==.小青龙:AwACCAcABRQCBAACAQgMDABYd8oABRQABAACAQgMDABYd8oABRQAAA==.尐灬熊猫:AwABCAEABRQCEAAIAQi5JwA6qvYBBAoAEAAIAQi5JwA6qvYBBAoAAA==.尘封的记忆:AwADCAQABAoAAA==.尤朵拉丨尼克:AwACCAIABRQAAA==.就不想带宝宝:AwAICA4ABAoAAA==.尼莫茜妮:AwAICAgABAoAAA==.',['�']='岚呌哩噶:AwACCAIABRQAAA==.',['�']='巫牛王:AwAICAoABAoAAA==.',['�']='希尒瓦娜斯:AwABCAEABRQDFQAIAQiNGABCgNMBBAoAFQAIAQiNGAA81tMBBAoAFgAHAQhLYgA2jloBBAoAAA==.帝凯帝凯帝:AwADCAMABAoAAA==.带刀刺猬:AwACCAIABAoAAA==.带头大哥灬:AwAFCAkABAoAAA==.',['�']='廉颇丶老矣:AwACCAIABAoAAA==.',['�']='影灭:AwACCAIABRQAAA==.影猎:AwAECAQABRQAAA==.',['�']='徘徊丶左右:AwACCAIABAoAAA==.',['�']='心月流火:AwABCAEABRQAAA==.',['�']='性感晓鹏:AwAECAgABRQCDAAEAQgyCgA3Uu8ABRQADAAEAQgyCgA3Uu8ABRQAAA==.怪人王:AwAGCA0ABAoAAA==.',['�']='恐怖利仞:AwAICAcABAoAAA==.',['�']='悟问问悟:AwACCAIABAoAAA==.悲伤汉堡包丶:AwABCAMABRQAAA==.',['�']='想法太多:AwAECAQABRQAAA==.',['�']='懷念加點冰:AwACCAIABAoAAA==.',['�']='我超厉害的:AwACCAIABRQAAA==.战吊丶:AwABCAEABAoAAA==.',['�']='扭曲的疏逺:AwAECAQABAoAAA==.',['�']='挥手啊:AwABCAEABRQDDAAIAQhNBQBavMICBAoADAAIAQhNBQBavMICBAoAFwACAQihcQAphS0ABAoAAA==.',['�']='播种与收获啊:AwABCAEABAoAAA==.',['�']='放开那羊驼:AwACCAcABRQCGAACAQhACwArF4EABRQAGAACAQhACwArF4EABRQAAA==.放开那羊驼丶:AwAGCAYABAoAAA==.',['�']='救火隊長:AwAECAUABRQCDAAEAQgTCwAvmeoABRQADAAEAQgTCwAvmeoABRQAAA==.敖蕾莉亚大姐:AwABCAEABRQAAA==.',['�']='斯坦科维奇:AwACCAYABRQCAgACAQgxBwBiDtYABRQAAgACAQgxBwBiDtYABRQAAA==.',['�']='无情的小矮子:AwAECAUABAoAAA==.日月大人:AwAECAQABAoAAA==.',['�']='明天更美好:AwAFCAUABAoAAA==.明珠求瑕:AwACCAIABAoAAA==.',['�']='晓红:AwAFCAoABAoAAA==.晨风沐雪:AwADCAsABRQEFgADAQifEwA0ZOsABRQAFgADAQifEwAzsOsABRQAFQABAQiEGQApN0UABRQAGQABAQhQBAATkjEABRQAAA==.景元:AwAECAQABRQAAA==.',['�']='暗夜破晓:AwAFCAUABAoAAA==.',['�']='最终丨审判:AwAGCAQABRQAAQcAAAAICAQABRQ=.月摄寒江:AwABCAEABRQAAA==.月落晨曦丶:AwAFCAsABAoAAA==.',['�']='杂德头都没:AwACCAYABRQCGgACAQgbAwBQ+bQABRQAGgACAQgbAwBQ+bQABRQAAA==.村头情报组长:AwACCAIABAoAAA==.',['�']='格瑞姆芭托:AwAECAQABRQAAA==.',['�']='橙味大香槟:AwABCAEABRQCEwAIAQi1LAA4MNEBBAoAEwAIAQi1LAA4MNEBBAoAAA==.',['�']='歌烬繁崋:AwABCAEABRQDAQAIAQj4CwBZM6sCBAoAAQAIAQj4CwBWE6sCBAoAAgAGAQijNABWtHIBBAoAAQEATAYICA0ABRQ=.歐耶:AwAECAEABAoAAA==.正直又勇敢:AwAECAQABAoAAA==.死亡波比大王:AwAGCAYABAoAAA==.',['�']='每天都出:AwAGCAYABAoAAA==.',['�']='没丶头脑:AwAICAYABAoAAA==.',['�']='浅梦吟风:AwABCAEABRQAAA==.浅苍南:AwAICAgABAoAAA==.',['�']='淡月映忧伤:AwADCAMABRQAAA==.深田咏渼:AwACCAIABRQAARsALyoICAoABRQ=.',['�']='溪鱼:AwAICAgABAoAAA==.',['�']='潇洒牛牛:AwAGCAsABAoAAA==.',['�']='火鷄味锅巴:AwABCAEABAoAAA==.火鸡味锅巴:AwACCAQABRQAAA==.灬咖啡豆灬:AwACCAYABRQCHAACAQhLAwAku2MABRQAHAACAQhLAwAku2MABRQAAA==.灬舞天灬:AwAGCAcABAoAAA==.灬茴香豆灬:AwAICAgABAoAAA==.灰烬之灵丶:AwAICAgABAoAAA==.',['�']='炭熄:AwACCAIABAoAAA==.炮指导:AwAECAQABRQAAA==.',['�']='無無明亦无:AwACCAQABRQAAQcAAAAICAQABRQ=.',['�']='爆团丶:AwAECAIABRQAAA==.爆疯:AwAGCAwABAoAAA==.爆破精英:AwABCAEABRQAAA==.爱人:AwADCAUABRQCEwADAQg7EAAbd8kABRQAEwADAQg7EAAbd8kABRQAAA==.爱马仕:AwAECAIABRQAAA==.',['�']='牛也开无敌:AwAGCAYABAoAAA==.牛奶的咖啡:AwAGCAEABRQAAA==.牛牛面面哒丶:AwACCAMABRQAAA==.牛麦兜:AwAGCAYABAoAAA==.牧友治疗:AwABCAEABRQAAA==.牧溪宝贝:AwAICBAABAoAAQwAL5kECAUABRQ=.牧濑红夕莉:AwAECAQABRQDEwAIAQhUHgBFpyMCBAoAEwAIAQhUHgBFgyMCBAoAAwAIAQgGHAA0T4IBBAoAAA==.',['�']='犬太:AwAFCAUABAoAAA==.',['�']='猎杀周狗:AwAECAYABRQCCwAEAQjUHgAuJsMABRQACwAEAQjUHgAuJsMABRQAAQUARjcFCBAABRQ=.猪柳蛋:AwAECAkABAoAAA==.',['�']='王潘达:AwAICAIABAoAAA==.玛瑟伊尔:AwABCAEABAoAAA==.玩电劈断角:AwAECAQABAoAAA==.玮玮的可乐:AwACCAYABRQDHQACAQgDCwA+x6sABRQAHQACAQgDCwA+x6sABRQACgABAQh7EAAbMUEABRQAAA==.玮玮的小恶魔:AwAICAgABAoAAA==.',['�']='珍惜丶:AwACCAUABRQEHQACAQgSCwBPGasABRQAHQACAQgSCwBIZqsABRQACgABAQg5DgBPCFEABRQAHgABAQgCBQAll0YABRQAAA==.',['�']='白衣酒客:AwAGCAgABAoAAQcAAAADCAIABRQ=.百华月咏:AwACCAUABRQCAQACAQjHHgBDB7EABRQAAQACAQjHHgBDB7EABRQAAA==.',['�']='睿智的海带:AwACCAIABRQAAA==.',['�']='破丶筱:AwABCAEABAoAAA==.',['�']='祁厅:AwACCAIABRQAAA==.',['�']='秦奋:AwAECAQABRQAAA==.',['�']='箬婼:AwACCAIABAoAAA==.',['�']='粉红吹风机:AwAGCBAABAoAAA==.',['�']='糖心丶:AwAFCAUABAoAAA==.',['�']='紫苑紫苑丶:AwAECAQABRQAAA==.',['�']='红苕稀饭:AwABCAEABRQAAA==.纯牧奶:AwAECAkABRQEEgAEAQgGDQAmXtgABRQAEgAEAQgGDQAmXtgABRQAEQACAQiDEABIs6cABRQAFAACAQj8FAAlmWwABRQAAA==.纸船装满水:AwAICAgABAoAAA==.',['�']='织炎之翼:AwAHCBkABAoDAgAHAQjVMgBDQHwBBAoAAgAHAQjVMgBDQHwBBAoAAQAHAQjgQAApY20BBAoAAA==.',['�']='羊葱騎士:AwAICAgABAoAAQcAAAAECAQABRQ=.羊酱:AwACCAcABRQECAACAQjqBQAfi20ABRQACAACAQjqBQAfi20ABRQAHwABAQieHwBGLk0ABRQAIAABAQhFGwAOrTcABRQAASAAIjQHCAkABRQ=.',['�']='老牌酱油:AwAICAgABAoAAA==.',['�']='聖啉:AwAFCAoABAoAAA==.',['�']='肥娥扑火:AwAICAIABAoAAA==.肥炖炖爱吃糖:AwADCAEABAoAAA==.',['�']='胡艺莲:AwADCAYABRQDFAADAQjCBABC9P4ABRQAFAADAQjCBAA+WP4ABRQAEQACAQicDQBTs8QABRQAAA==.',['�']='艾潞丶晨星:AwACCAIABAoAAA==.',['�']='芙莉莲丶:AwACCAYABRQCAQACAQiOIABDbqMABRQAAQACAQiOIABDbqMABRQAAQcAAAADCAIABRQ=.芯甜甜:AwAICAMABAoAAA==.',['�']='苍白浅影:AwAECAIABRQAAA==.苏瑞羽:AwADCAMABAoAAA==.若山诗音:AwAICBoABAoDFgAIAQgIKgBJgS0CBAoAFgAIAQgIKgBJgS0CBAoAFQAGAAgAAAAAAAAABAoAAQcAAAAECAIABRQ=.若葉睦:AwAFCAUABAoAAA==.',['�']='荣耀黯灭:AwADCAMABRQAAA==.',['�']='莎伦:AwAICAgABAoAAA==.莫德凯撒:AwAGCAYABAoAAA==.莫莉丶:AwAFCAUABAoAAA==.莱格拉丝:AwAICA4ABAoAAA==.',['�']='菊三爷:AwAICBAABAoAAA==.',['�']='萨拉曼妲尔:AwADCAMABAoAAA==.萨满丶靓妹:AwADCAUABRQCDAADAQhhDAAp3OMABRQADAADAQhhDAAp3OMABRQAAA==.萨瓦敌卡:AwAFCAUABAoAAA==.落叶知秋:AwAICA4ABAoAAA==.落雪赏飞舞:AwAICA8ABAoAAA==.',['�']='蓝色阿秋罗:AwAECAQABAoAAA==.',['�']='蔡徐鲲:AwABCAEABAoAAA==.',['�']='薄荷水:AwACCAIABAoAAA==.',['�']='虎贲校尉:AwAICA4ABAoAAA==.',['�']='血兽请再爱我:AwAGCAcABAoAAA==.',['�']='要不散了吧:AwAGCAkABAoAAA==.',['�']='见习爱神:AwAECAYABRQDCwAEAQjECwBMzxEBBRQACwADAQjECwBMzxEBBRQAIQABAQjXEgAAAAAABRQAAA==.',['�']='記憶之殤:AwAICAgABAoAAA==.',['�']='让开我来:AwADCAIABAoAAA==.',['�']='请叫我好哇塞:AwAECAQABRQAAA==.',['�']='贰式炎雷:AwAGCAsABAoAAA==.',['�']='起名综合症:AwAHCAEABAoAAA==.',['�']='路人甲的亲戚:AwAGCAYABAoAAA==.',['�']='轻盈的翅膀:AwADCAMABAoAAA==.',['�']='迷时始祖幼龙:AwAECAQABRQAAA==.追风剑语:AwAGCAYABAoAAA==.',['�']='送便当:AwABCAEABRQCIgAIAQhUEAA49NwBBAoAIgAIAQhUEAA49NwBBAoAAA==.逾伦:AwABCAEABAoAAA==.',['�']='那一抹浅笑:AwAGCAYABAoAAA==.邪恶猫猫头:AwAHCAUABAoAAA==.',['�']='醉是凡:AwAGCAYABRQCAQAGAQjpAQBK2tEBBRQAAQAGAQjpAQBK2tEBBRQAAA==.',['�']='金龥:AwACCAIABAoAAA==.',['�']='销魂的牛:AwADCAMABAoAAA==.',['�']='阿古斯丶丶:AwACCAEABAoAAA==.阿姆罗雷:AwABCAEABRQAAA==.阿莫比:AwAICAcABAoAAA==.',['�']='隐有王霸之氣:AwACCAIABAoAAA==.',['�']='雀儿八十:AwAECAQABRQAAA==.雅哈比比:AwAHCAcABAoAAA==.雪无影:AwAECAQABRQAAA==.',['�']='靑龍:AwACCAYABRQCHwACAQgHGgAfRogABRQAHwACAQgHGgAfRogABRQAAA==.青洛丶:AwAICAgABAoAAA==.非常不动如山:AwACCAIABRQAAA==.非常不讲道理:AwAECAQABRQAAA==.非常吆姬:AwACCAIABRQAAA==.非常宝宝:AwACCAIABRQAAA==.非常懒猪:AwAHCAkABAoAAA==.非常擒兽:AwAECAQABAoAAA==.非常淡鼎:AwAECAQABRQAAA==.非常淤泥:AwACCAIABRQAAA==.非常溜:AwAECAQABRQAAA==.非常爷们:AwACCAIABRQAAA==.非常的人头木:AwAICAIABAoAAA==.面壁磨砖:AwAECAQABRQAAA==.',['�']='风暴狂啸:AwACCAUABRQCDQACAQgDCgBBQ6UABRQADQACAQgDCgBBQ6UABRQAAA==.风骚药不停:AwADCAMABAoAAA==.飛鸟与鱼丶:AwAHCAcABAoAAA==.飞雪:AwADCAMABAoAAA==.',['�']='饿了么小龙女:AwAECAQABAoAAQcAAAAGCAsABAo=.',['�']='馬童鞋:AwACCAUABRQCFgACAQh/KQAuQIkABRQAFgACAQh/KQAuQIkABRQAAA==.',['�']='魔法加點冰:AwABCAEABAoAAA==.',['�']='麦辣鸡:AwADCAgABRQDBQADAQgCEwBBTrcABRQABQACAQgCEwBFUrcABRQADQABAQi5EAA5RlcABRQAAA==.',['�']='黄前久美子:AwAGCAoABAoAAA==.黑暗狩猎:AwABCAEABRQAAA==.黑椒牛仔骨:AwAFCAEABAoAAA==.',['�']='龙城老宋:AwAHCA8ABAoAAA==.龙城铭风:AwACCAIABRQAAA==.龙西焱:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end