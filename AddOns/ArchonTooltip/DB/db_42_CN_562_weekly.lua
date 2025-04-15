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
 local lookup = {'DeathKnight-Unholy','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Fire','Mage-Frost','Unknown-Unknown','Shaman-Elemental','Paladin-Retribution','Monk-Mistweaver','Evoker-Devastation','Druid-Balance','Druid-Restoration','Shaman-Restoration','DemonHunter-Havoc','Monk-Brewmaster','Warrior-Fury','DemonHunter-Vengeance','DeathKnight-Blood','Rogue-Assassination','Paladin-Protection','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Enhancement','Paladin-Holy','Warrior-Protection','Rogue-Subtlety','Warlock-Destruction','DeathKnight-Frost','Warlock-Affliction',}; local provider = {region='CN',realm='世界之树',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adore:AwAGCAYABAoAAA==.',Ag='Agoena:AwAHCA4ABAoAAA==.',As='Aslo:AwADCAcABRQCAQADAQjUCgA1QPIABRQAAQADAQjUCgA1QPIABRQAAA==.',Ba='Baby:AwAECAQABRQAAA==.',Be='Bell:AwAFCAcABRQEAgAFAQimCAAxC9YABRQAAgAEAQimCAArotYABRQAAwACAQgnEwA/b5IABRQABAABAQjNGAAPw2AABRQAAA==.',Ca='Caka:AwAICCAABAoDBQAIAQgnFwBTBlsCBAoABQAIAQgnFwBNX1sCBAoABgAIAQgrKgBAqqsBBAoAAA==.Caster:AwACCAIABAoAAA==.',Ch='Chaahk:AwACCAIABRQAAA==.Chaamoi:AwADCAIABAoAAQcAAAAECAQABRQ=.Chaser:AwAECAQABRQAAA==.',Cr='Crane:AwABCAEABRQAAA==.Crittitan:AwADCAMABAoAAA==.',Cy='Cyrbuzz:AwADCAYABRQCBgADAQhQAABjTVoBBRQABgADAQhQAABjTVoBBRQAAA==.',Dr='Drcula:AwAGCAMABAoAAA==.',Ex='Extinguished:AwABCAIABRQAAA==.',Fl='Flyly:AwAGCAYABAoAAQcAAAACCAMABRQ=.Flyy:AwAECAQABAoAAQcAAAACCAMABRQ=.Flyya:AwAHCA4ABAoAAQcAAAACCAMABRQ=.Flyz:AwADCAMABAoAAQcAAAACCAMABRQ=.',Ga='Gavind:AwABCAEABAoAAA==.',Ho='Hotfell:AwAFCAgABAoAAA==.',Im='Imf:AwAHCBIABAoAAA==.',Ir='Irene:AwAECAQABRQAAA==.',Ja='Jaychou:AwAGCAQABRQAAA==.',Ke='Kelth:AwABCAEABRQAAA==.',Ki='Killerqueenq:AwABCAEABAoAAA==.Killerxy:AwACCAIABAoAAA==.',La='Lackorange:AwAICAgABAoAAA==.Lalalala:AwACCAIABRQAAA==.',Lw='Lwoyue:AwAGCAoABAoAAA==.',Ma='Mangokk:AwACCAIABRQAAA==.Marisa:AwAECAQABRQAAA==.Marisadruid:AwAICA4ABAoAAA==.',Oi='Oicpd:AwAFCBoABRQDBQAFAQgZAwBcD58BBRQABQAFAQgZAwBcD58BBRQABgABAQhAEwBHylAABRQAAA==.',Ps='Psy:AwAGCAkABAoAAA==.',Qk='Qkyu:AwAECAgABRQCBQAEAQgzFAA35egABRQABQAEAQgzFAA35egABRQAAQUAMkEGCAgABRQ=.',Ra='Rafaela:AwAECAQABRQAAA==.',Su='Sunning:AwAICA4ABAoAAA==.',Ta='Takishiina:AwACCAIABRQCCAAIAQgWCABYOqUCBAoACAAIAQgWCABYOqUCBAoAAA==.',Wi='Windfallm:AwACCAIABAoAAA==.',Ya='Yanlan:AwAFCAkABAoAAA==.',Yu='Yur:AwAICAgABAoAAA==.Yuukyuukikan:AwABCAIABRQAAA==.',Zx='Zxn:AwAGCAYABRQCCQAEAQhkCgBPohYBBRQACQAEAQhkCgBPohYBBRQAAA==.',['�']='一个真正的鳗:AwAECAQABRQAAA==.一八六零:AwAECAQABRQCCgAGAQhSLwBLtXIBBAoACgAGAQhSLwBLtXIBBAoAAA==.一波:AwAGCAgABAoAAA==.一点都不脆:AwAICAgABAoAAA==.一琥珀封印一:AwAECAQABAoAAA==.七夜灬:AwAHCAcABAoAAA==.七夜羽:AwAECAQABRQAAA==.七星夺窍:AwAFCAgABAoAAA==.三玖天下第一:AwAECAQABRQAAA==.三花儿:AwABCAEABAoAAA==.三言两语:AwAICA4ABAoAAA==.不给嗜血:AwAECAQABRQAAA==.不要冷冰冰:AwAECAMABRQAAQsAD08ICAUABRQ=.不解风卿:AwAGCBEABAoAAA==.丝佳丽:AwAICBoABAoDDAAIAQiKOwA2ipUBBAoADAAIAQiKOwA2ipUBBAoADQAFAQiMVAAWXpQABAoAAA==.丨风清扬丨:AwABCAEABRQAAA==.',['�']='久远的武僧:AwAECAQABRQAAA==.',['�']='亚历山德里亚:AwAECAQABAoAAA==.亲斤:AwAICAgABAoAAA==.人间醉逍遥:AwADCAMABAoAAA==.',['�']='伏尔加:AwABCAIABRQAAA==.伤心辞:AwAECAQABRQAAA==.',['�']='你来助我:AwACCAIABRQCDgAIAQj4CwBUIYECBAoADgAIAQj4CwBUIYECBAoAAQcAAAADCAEABRQ=.你看看:AwADCAEABAoAAA==.你说疼没说停:AwAECAQABRQAAA==.你这瓜保熟嘛:AwAICAgABAoAAA==.',['�']='信德维拉:AwABCAIABRQCDwAIAQjSEABUJ44CBAoADwAIAQjSEABUJ44CBAoAAA==.信手拈来:AwACCAIABAoAAA==.修丽可:AwAICAgABAoAAQ0AOkwGCAUABRQ=.',['�']='偷心骑士:AwAECAQABRQAAA==.',['�']='像风如你:AwAECAQABAoAAA==.',['�']='光明猎手:AwAICAoABAoAAA==.兔老公:AwAECAcABAoAAA==.兵马大元帅:AwACCAQABRQCCQAIAQi+OQBKwyACBAoACQAIAQi+OQBKwyACBAoAAA==.',['�']='冲锋歪了刁:AwAGCAYABAoAAA==.',['�']='初代目火影:AwAICAsABAoAAA==.初辞逗你开心:AwAGCAQABRQAAA==.',['�']='勾哥玩游戏:AwAECAQABRQAAA==.',['�']='十一月雨:AwAICAgABAoAAA==.十七钻石上弯:AwAICAgABAoAAA==.十八钻石上弯:AwAECAQABRQAAA==.十点法力:AwAECAUABRQCBQAEAQjyDgBEm/sABRQABQAEAQjyDgBEm/sABRQAAA==.南风风:AwACCAIABAoAAA==.博丽霊梦:AwAGCAYABAoAAA==.印度玩蜥蜴:AwAGCAwABAoAAA==.危险光头战:AwACCAIABAoAAA==.危险大师姐:AwAGCAYABAoAAA==.危险大领主:AwAFCAgABAoAAA==.',['�']='双鱼座流星雨:AwAICBIABAoAAQcAAAAICAQABRQ=.发春的狗熊:AwAICAgABAoAAA==.叮咚细雨:AwAECAIABRQAAA==.可乐七:AwACCAIABRQAAA==.可乐六:AwACCAIABRQAAA==.可达鸭不迷路:AwAECAQABAoAAQ0ASgICCAYABRQ=.可达鸭很邪恶:AwAGCAcABAoAAQ0ASgICCAYABRQ=.可达鸭爱睡觉:AwACCAYABRQCDQACAQjOCgBKArMABRQADQACAQjOCgBKArMABRQAAA==.叶圣:AwAECBAABRQCEAAEAQhIAQBNeA8BBRQAEAAEAQhIAQBNeA8BBRQAAA==.叶月零:AwAGCBAABAoAAA==.',['�']='吉古:AwADCAMABAoAAA==.吞乁天:AwAICAoABAoAAA==.吞乂天:AwABCAIABRQAAA==.吞亽天:AwAICAwABAoAAA==.吞仐天:AwAICBgABAoCEQAIAQjsIQAwXfEBBAoAEQAIAQjsIQAwXfEBBAoAAA==.吞彡天:AwABCAEABAoAAA==.听说你们缺德:AwAHCAwABAoAAA==.',['�']='唵嘛呢叭咪吽:AwAICAUABAoAAA==.',['�']='啊西八大骑士:AwABCAEABRQAAA==.',['�']='喝多了:AwACCAIABRQAAA==.',['�']='嗷呜嗷呜嗷:AwAICAIABAoAAA==.',['�']='嘉特洛恩克:AwAICA4ABAoAAA==.',['�']='嚓吧吧:AwAFCAUABAoAAA==.',['�']='圣光审判众生:AwADCAkABRQCCQADAQj3EABBPfwABRQACQADAQj3EABBPfwABRQAAA==.圣光照亮我:AwAICA0ABAoAAA==.',['�']='坑跌僧:AwACCAIABAoAAA==.坑跌贼:AwAHCAQABAoAAA==.',['�']='堕落骑士:AwAHCAQABAoAAA==.',['�']='夜深月夜静:AwAFCAYABAoAAA==.夜雨潇湘:AwAECAIABRQAAA==.大卡了米:AwAGCAkABAoAAA==.天锁斩月:AwACCAEABAoAAA==.失落叶丶:AwAECA0ABRQCEgAEAQgCAwBGBPcABRQAEgAEAQgCAwBGBPcABRQAAQ8AN6oICAYABRQ=.',['�']='奈丝:AwAICA8ABAoAAA==.奈骑:AwAFCAkABAoAAA==.奶瓶睡不醒:AwAECAgABRQCEwAEAQjMBwA/E+UABRQAEwAEAQjMBwA/E+UABRQAAA==.奶白雪子:AwAECAQABRQAAA==.好大一头奶牛:AwAECA4ABRQDDgAEAQiGAgBcTTwBBRQADgAEAQiGAgBcTTwBBRQACAABAQjIEgAvWUoABRQAAA==.好运小子:AwAICAgABAoAAQcAAAAGCAIABRQ=.',['�']='娇病娘独卧床:AwAHCA4ABAoAAA==.',['�']='守望启示:AwACCAIABAoAAQcAAAAHCBIABAo=.守望梦境:AwABCAIABRQAAA==.安缇诺雅:AwAICCMABAoCBgAIAQhQBgBbecsCBAoABgAIAQhQBgBbecsCBAoAAA==.宗师老陈:AwACCAIABAoAAA==.',['�']='小刘特可爱:AwAICAwABAoAAA==.小小骑士:AwAGCAoABAoAAA==.小幽:AwAGCAYABRQCCQAGAQj8AAAz6LUBBRQACQAGAQj8AAAz6LUBBRQAAA==.小楼不灭:AwAECAQABRQAAA==.小波:AwACCAcABRQDBQACAQgvIQA8UZ8ABRQABQACAQgvIQA8UZ8ABRQABgABAQgdGQAstTgABRQAAA==.小狼灬:AwACCAIABRQAAA==.小猫阿咪:AwAICAQABAoAAA==.小红手兹泽:AwAFCAIABAoAAA==.小西瓜丶:AwAECAQABRQAAA==.小青龍丶:AwADCAIABAoAAA==.少时诵诗问问:AwAICAgABAoAAA==.少昊:AwAECAQABRQAAA==.尤莉卡:AwAECAQABRQAAA==.',['�']='山大王:AwABCAIABRQAAA==.',['�']='平凡:AwAICAgABAoAAA==.并非骑士:AwAICBAABAoAAA==.幻肢:AwABCAEABRQAAA==.幼儿园杠把子:AwACCAIABRQAAQcAAAAICAIABRQ=.',['�']='张二河:AwACCAIABRQAAA==.张筱溅:AwAICAgABAoAAA==.',['�']='当年明月:AwAECAQABRQAAA==.',['�']='御坂美琴的猫:AwAECAQABRQCFAAIAQhfAQBe0/ECBAoAFAAIAQhfAQBe0/ECBAoAAA==.微笑丿迪妮莎:AwAICBgABAoCDwAIAQgiHABCBj0CBAoADwAIAQgiHABCBj0CBAoAAA==.',['�']='快乐牌刀片:AwADCAMABAoAAA==.',['�']='悦容:AwAECAMABRQAAA==.悲伤的阿数:AwAICBIABAoAAA==.悲剧不是我:AwACCAIABAoAAA==.',['�']='我也是奶龙:AwAFCAEABAoAAA==.我先过去了:AwAECAQABRQAAA==.我就图个成果:AwAGCAYABAoAAA==.我是美女:AwAGCAYABAoAAA==.我来助你:AwADCAEABRQAAA==.我没颜色:AwAGCAwABAoAAA==.我要背叛圣光:AwAICBcABAoCFQAIAQglHwAgci0BBAoAFQAIAQglHwAgci0BBAoAAA==.战神妞妞:AwAECAcABAoAAA==.',['�']='扮老虎吃猪:AwACCAIABAoAAA==.',['�']='抹茶大福:AwAICBAABAoAAA==.',['�']='拾荒者丶:AwAECAQABRQAARYAPosGCA8ABRQ=.',['�']='指東打西:AwAECAIABRQAAA==.',['�']='接近于平移:AwAICAgABAoAAA==.',['�']='断了的弦:AwAICAgABAoAAA==.',['�']='无冕之影:AwAICBAABAoAAA==.无双斩:AwADCAMABAoAAA==.无敌大臭屁:AwAGCAYABAoAAA==.无糖乌龙茶:AwABCAEABRQAAA==.',['�']='星动悦沉浮:AwABCAEABRQAAA==.星星丶失眠:AwAICAIABAoAAA==.星狐:AwACCAUABRQDFwACAQiVMQAPEWEABRQAFwACAQiVMQANi2EABRQAGAABAQimGwAbbz0ABRQAAA==.星铭:AwABCAEABRQAAA==.星雾乄:AwAECAQABRQAAA==.是个神经:AwAICBAABAoAAA==.是糯糯呀:AwABCAEABAoAAA==.是薯条呦:AwAICAYABAoAAA==.',['�']='暗夜小五:AwACCAIABRQAAA==.暗夜猫娘:AwAFCAcABAoAAA==.暗影之风:AwAGCAcABAoAAA==.',['�']='月亮丶不睡:AwADCAMABAoAAA==.月半小夜曲:AwAICAoABAoAAA==.未淳:AwAGCAYABAoAAA==.本笃:AwACCAMABRQDAgAIAQiTGgA029oBBAoAAgAIAQiTGgA029oBBAoAAwADAQjRSgAwRb4ABAoAAA==.',['�']='杜姆:AwAECAkABRQCAQAEAQgkDAAwfekABRQAAQAEAQgkDAAwfekABRQAAA==.',['�']='果木烤龙:AwAICBAABAoAAA==.',['�']='染生于柒:AwABCAEABRQAAA==.柠檬养乐多:AwEICBMABAoAAA==.柠萌灬:AwAECAUABRQCBQAEAQiMGwAhOMoABRQABQAEAQiMGwAhOMoABRQAAA==.',['�']='森海灬飞霞:AwAGCA8ABAoAAA==.',['�']='歡爷灬:AwACCAIABRQAAA==.正统必胜:AwABCAEABRQAAA==.武术家:AwAECAQABAoAAA==.死鱼大狗:AwACCAUABRQDGQACAQhQCwBLD7IABRQAGQACAQhQCwBLD7IABRQACAABAQimEQBI91EABRQAAA==.死鱼安乐:AwAICB0ABAoDGgAIAQgAAwBW+K4CBAoAGgAIAQgAAwBW+K4CBAoACQAIAQgBNwBHnykCBAoAAA==.',['�']='残影紫宸丶:AwADCA8ABRQCBAADAQiWBwBNeQYBBRQABAADAQiWBwBNeQYBBRQAAA==.',['�']='毁灭咕:AwAECAQABAoAAA==.比较温柔:AwABCAIABRQAAA==.',['�']='民女李建刚:AwAICAgABAoAAA==.水丨泊:AwAECAQABRQCCgAIAQgBOAAczkUBBAoACgAIAQgBOAAczkUBBAoAAA==.',['�']='没蓝:AwAECAQABRQAAA==.没钥匙的锁:AwAICAgABAoAAA==.',['�']='洛芯:AwAGCAYABAoAAA==.洞八三牛神:AwACCAIABRQAAA==.',['�']='海盐蜃龙仙贝:AwAFCAoABRQCFwAFAQiYAgBLTooBBRQAFwAFAQiYAgBLTooBBRQAAA==.',['�']='清源妙道圣君:AwADCAcABRQCGwAIAQiOBgBJakQCBAoAGwAIAQiOBgBJakQCBAoAAA==.温柔一棒:AwABCAEABAoAAA==.温柔的继母:AwABCAEABRQAAA==.',['�']='潜不入你的心:AwAGCBQABAoDFAAGAQgSEwBTis4BBAoAFAAGAQgSEwBQqc4BBAoAHAADAQiCJQBGyMgABAoAAA==.潜行的抹茶:AwAECAQABRQAAA==.',['�']='火鸡味鍋巴:AwABCAEABRQAAA==.火麟:AwAGCAEABRQAAA==.灬小珤灬:AwAECAIABRQAARIANZAECAYABRQ=.灰土虫:AwAECAQABRQAAA==.灵泽:AwAICAYABAoAAA==.',['�']='烟之咒:AwAHCAcABAoAAA==.烟之小神韵:AwADCAMABRQAAA==.',['�']='無終:AwACCAIABAoAAA==.焦糖科比:AwAGCAYABAoAAA==.',['�']='燃冉:AwACCAQABRQAAA==.',['�']='爱吃馒头的兽:AwABCAIABRQAAA==.爱在桃花树前:AwADCAMABAoAAA==.',['�']='牛爷爷:AwABCAEABRQAAA==.牛牛丶:AwAGCAcABAoAAA==.牧之:AwAFCAUABAoAAA==.',['�']='狂怒熊熊:AwAGCAYABAoAAA==.狗尾巴草:AwAGCAwABAoAAA==.狮子是策划狗:AwAECAcABAoAAA==.',['�']='猪猪:AwAICBAABAoAAA==.',['�']='琦琦骑:AwAHCAoABAoAAA==.',['�']='甲辰:AwACCAIABAoAAA==.电梯之狼:AwAECAcABRQCEwAEAQhrBgBHTP0ABRQAEwAEAQhrBgBHTP0ABRQAAA==.',['�']='疏楼龙宿丶:AwAECAIABRQCFAAIAQhHDwBNlgMCBAoAFAAIAQhHDwBNlgMCBAoAAA==.',['�']='痛仰丶永远:AwAGCAYABAoAAA==.',['�']='白龙猫:AwAICBwABAoCFwAIAQgXCQBbe9wCBAoAFwAIAQgXCQBbe9wCBAoAAA==.百鬼妄渡川:AwAICAgABAoAAA==.',['�']='真的不会二号:AwABCAEABRQAAA==.',['�']='睡吃打肥肥:AwAGCAYABAoAAA==.',['�']='破械神的祸灵:AwABCAEABRQAAQcAAAABCAIABRQ=.',['�']='神王牙:AwAICAMABRQAAA==.神职天使:AwAECAQABRQAAA==.',['�']='秋氺寒:AwAFCAUABAoAAA==.',['�']='笑醉狂:AwABCAIABRQAAA==.',['�']='筱灬迷糊:AwAICAgABAoAAA==.',['�']='素质小子:AwAECAIABRQAAA==.紫菜芯:AwAECAIABRQAAA==.',['�']='红丸:AwAICBMABAoAAA==.约伊兹的行商:AwAECAYABRQCDgAEAQgwDAAuDuQABRQADgAEAQgwDAAuDuQABRQAAA==.纽约农场主:AwAGCAIABRQAAA==.',['�']='绳网用户:AwAECAQABRQAAA==.绿箭口臭糖:AwAECAQABAoAAA==.',['�']='网恋大领主:AwACCAIABAoAAA==.',['�']='翱翔萨:AwAGCAcABAoAAA==.',['�']='老奎:AwACCAIABRQAAA==.',['�']='肥腻的绿箭侠:AwAICA4ABAoAAA==.',['�']='能戈善武:AwABCAEABAoAAA==.',['�']='脱缰灬疯豿:AwADCAUABRQCEQADAQiqDgAfv+oABRQAEQADAQiqDgAfv+oABRQAAA==.脱缰疯够:AwADCAUABRQCHQADAQjdEQAVQLoABRQAHQADAQjdEQAVQLoABRQAAA==.脱缰疯构:AwAICAoABAoAAA==.脱缰疯芶:AwADCAkABRQDFwADAQjmBwBW0SYBBRQAFwADAQjmBwBSAiYBBRQAGAABAQiZFgBHplQABRQAAA==.脱缰疯豿:AwACCAIABRQAAA==.脱缰疯豿灬:AwADCAYABRQCCQADAQg1FAA2M/EABRQACQADAQg1FAA2M/EABRQAAA==.',['�']='臭阿狸:AwABCAIABRQAAQ4AXE0ECA4ABRQ=.',['�']='艾查恩:AwACCAIABRQAAA==.',['�']='苍牙煌:AwABCAIABRQAAA==.',['�']='茉莉乌龙:AwAECBAABRQDAQAEAQh/BwBIzAgBBRQAAQAEAQh/BwBIzAgBBRQAHgABAQi+BgBPrUMABRQAAA==.',['�']='荡漾灬水波:AwAECAYABRQCEgAEAQgRBQA1kM0ABRQAEgAEAQgRBQA1kM0ABRQAAA==.荼蘼花世了:AwAFCAEABAoAAA==.',['�']='莉雅:AwADCAMABAoAAA==.莎昔昔:AwAICAgABAoAAQcAAAAICAQABRQ=.',['�']='薯鼠泥:AwADCAUABRQCFwADAQjmDgBERv4ABRQAFwADAQjmDgBERv4ABRQAAA==.',['�']='蜜雪冰诚:AwAGCAYABAoAAA==.',['�']='螺纹钢:AwACCAIABAoAAA==.',['�']='袖手天下:AwAECAYABRQCFwAEAQjDGAA2+NMABRQAFwAEAQjDGAA2+NMABRQAAQsAORUICAwABRQ=.',['�']='裂蹄牛:AwAECAQABRQAAA==.',['�']='让路:AwAHCAkABAoAAA==.',['�']='诗雨:AwAGCAgABRQCDwAGAQhUAABSgyUCBRQADwAGAQhUAABSgyUCBRQAAA==.请叫我:AwAECAcABRQCGAAEAQiBCQAyMNsABRQAGAAEAQiBCQAyMNsABRQAAA==.',['�']='赫咔特:AwAECBAABRQDGAAEAQjgAABhSEoBBRQAGAAEAQjgAABhSEoBBRQAFwACAQjRNABQm08ABRQAAA==.走夜路:AwACCAMABRQAAA==.',['�']='超六:AwAHCAkABAoAAA==.超级牛牛:AwAECAgABRQCDAAEAQgvDgAxke0ABRQADAAEAQgvDgAxke0ABRQAAQwAQiQGCAoABRQ=.',['�']='还能再砍砍:AwABCAIABRQAAA==.这是化劲儿:AwAICAIABAoAAA==.迪迪马库斯:AwACCAEABAoAAA==.',['�']='邪心英雄:AwAICAgABAoAAA==.',['�']='鄙人不善奔跑:AwAICBMABAoAAA==.',['�']='酒巷猫未归:AwAGCAkABAoAAA==.',['�']='醉梦前尘丶:AwADCAUABAoAAA==.醉笑二千场:AwAHCAcABAoAAQUAWWMGCBQABRQ=.',['�']='重生:AwADCAYABAoAAA==.野兽仙贝:AwAICAgABAoAAA==.',['�']='长路终有归途:AwAECAQABAoAAA==.',['�']='闪光叶小哥:AwAHCAsABAoAAA==.',['�']='阿布牧牧:AwAGCAIABRQAAA==.阿波莉同学:AwAECAQABRQAAA==.',['�']='陈柏给:AwAECAQABRQAAA==.',['�']='雀德:AwAHCAcABAoAAA==.雨绵夜未央:AwAGCAkABRQDBAAEAQi0BwBIGAUBBRQABAAEAQi0BwBIGAUBBRQAAwACAQhcEQBTSZ8ABRQAAA==.雪碧不要冰:AwAECAQABRQAAA==.零丶六一八:AwAECAIABRQAAA==.雷王牙:AwAECAIABRQAARkAUmQGCBIABRQ=.',['�']='霸王龙扎克:AwAHCBMABAoAAA==.',['�']='青柠冰沙:AwAECA0ABRQCCgAEAQiqBgBYOBQBBRQACgAEAQiqBgBYOBQBBRQAAA==.青里谨:AwAFCAcABAoAARsAQBEDCAsABRQ=.面包虚无:AwAECAQABAoAAA==.',['�']='风月逸彩:AwAECAQABRQAAA==.风花雪月:AwABCAEABRQDAQAIAQihIQA/uw4CBAoAAQAIAQihIQA/uw4CBAoAEwABAQjFYwAAAAAABAoAARMAUMoICAcABRQ=.风语丶铃兰:AwAGCAUABAoAAA==.',['�']='香软小辰酱:AwADCAsABRQCGwADAQjnAQBAEQIBBRQAGwADAQjnAQBAEQIBBRQAAA==.',['�']='鱼一术:AwACCAMABRQAAR0AQWIGCAoABRQ=.',['�']='鶴舞白沙:AwAHCAUABAoAAR8AYxEGCA0ABRQ=.',['�']='鸭小没有丶:AwADCAYABAoAAQQATXkDCA8ABRQ=.鸿儒:AwAECAgABRQCCAAEAQg+BgBGHusABRQACAAEAQg+BgBGHusABRQAAA==.鸿孺:AwAGCAUABAoAAQgARh4ECAgABRQ=.',['�']='麦德琳:AwADCAQABAoAAQwANooICBoABAo=.麻瓜噜啦啦:AwAECAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end