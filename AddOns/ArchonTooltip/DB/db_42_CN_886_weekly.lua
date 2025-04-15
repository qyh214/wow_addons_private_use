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
 local lookup = {'Warrior-Protection','Mage-Fire','Mage-Frost','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Priest-Discipline','Rogue-Subtlety','Unknown-Unknown','Rogue-Assassination','Warrior-Fury','Priest-Holy','DemonHunter-Havoc','Warrior-Arms','Warlock-Destruction','Warlock-Demonology','Monk-Brewmaster','DeathKnight-Blood','Druid-Balance','Druid-Restoration','Priest-Shadow','Hunter-Marksmanship','DeathKnight-Unholy','Druid-Guardian','DemonHunter-Vengeance',}; local provider = {region='CN',realm='风行者',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ab='Abies:AwADCAMABAoAAA==.',Ad='Adioscowboy:AwABCAIABRQCAQAIAQi9AQBeBdoCBAoAAQAIAQi9AQBeBdoCBAoAAA==.',Av='Avid:AwAGCA8ABAoAAA==.',Aw='Awuh:AwAECAQABAoAAA==.',Ba='Baby:AwADCAMABRQAAA==.',Bl='Bloodyrose:AwAHCAEABAoAAA==.',Bu='Buffoon:AwAFCAcABAoAAA==.',Ca='Catmini:AwAGCAQABRQAAA==.',Co='Cosmogenesis:AwAICBAABAoAAA==.',Da='Dark:AwACCAIABRQAAA==.',Fu='Fuz:AwAICB4ABAoDAgAIAQhjMwBDar8BBAoAAgAIAQhjMwAwhb8BBAoAAwAGAQitNgBQrXEBBAoAAA==.',Ha='Hardrock:AwADCAIABAoAAA==.Havesk:AwAGCA4ABAoAAA==.',Hi='Hi:AwADCAMABAoAAA==.',Is='Iszeraelune:AwAECAEABRQAAQQAMnIGCAwABRQ=.',Jh='Jhwwudi:AwACCAIABAoAAA==.',Ko='Korospo:AwAFCAcABAoAAA==.',La='La:AwAECAQABRQAAA==.Lastdance:AwAECAcABRQDBAAEAQhfKgA8kJ0ABRQABAADAQhfKgBOT50ABRQABQAEAQjmDAARDX4ABRQAAA==.Lastwarrior:AwAICAgABAoAAA==.',Lo='Loen:AwAFCAUABAoAAA==.',Ne='Neytiri:AwAICBQABAoCBgAIAQinJwBJsUECBAoABgAIAQinJwBJsUECBAoAAA==.',Ny='Nymphe:AwACCAQABRQCBwAIAQieCABQ3oUCBAoABwAIAQieCABQ3oUCBAoAAA==.',Ol='Ollier:AwABCAEABAoAAA==.',Pi='Piscesangel:AwACCAIABAoAAA==.',Pl='Plzfthx:AwECCAQABRQDAwAIAQioIQA9M+MBBAoAAwAIAQioIQA9M+MBBAoAAgABAQjEnQAIBR4ABAoAAA==.',Re='Rebornlyqaq:AwABCAEABRQCCAAIAQj2BgBRIn4CBAoACAAIAQj2BgBRIn4CBAoAAA==.',Sa='Saylor:AwAECAQABAoAAQkAAAAGCAQABRQ=.',St='Stiveni:AwAICCAABAoDCgAIAQiIDQBAFyYCBAoACgAIAQiIDQBAFyYCBAoACAAHAQh9FwAhcnoBBAoAAA==.',Sy='Sylleria:AwACCAIABRQAAA==.',Us='Usezttv:AwAGCAoABAoAAA==.',Ve='Veerene:AwAICAgABAoAAA==.',Wr='Wr:AwAECAgABAoAAA==.',Xl='Xlight:AwABCAEABRQDAwAIAQgZEABVJWQCBAoAAwAIAQgZEABVJWQCBAoAAgADAQh0ewAzdXsABAoAAA==.',Yl='Ylaya:AwAECAQABRQAAA==.',Yu='Yuikk:AwACCAIABAoAAA==.',['�']='一哚小黄錵:AwAECAQABRQAAA==.一头老绵羊:AwACCAIABRQAAA==.七枷社:AwACCAIABRQAAA==.下楼买可乐:AwAICAgABAoAAA==.不想加班:AwAECAQABAoAAA==.丑兔:AwAICAgABAoAAQkAAAAGCAQABRQ=.东呀么东:AwAICAgABAoAAA==.东阳彦祖:AwABCAEABRQAAA==.两年半:AwAECAgABRQCCwAEAQimFABDprcABRQACwAEAQimFABDprcABRQAAA==.丨北风丨:AwABCAEABAoAAA==.丶爲妳而战:AwADCAUABAoAAQkAAAAGCAQABRQ=.丷看不见我丷:AwAICAgABAoAAA==.',['�']='九九堂:AwAGCAYABAoAAA==.九千七:AwAGCAIABRQAAA==.',['�']='二丈三:AwACCAMABRQAAA==.京城大叔:AwACCAIABAoAAA==.',['�']='从前有小猪:AwAICAkABAoAAA==.',['�']='伊格尼斯:AwABCAEABAoAAA==.会滑翔的阿福:AwAHCAoABAoAAA==.伪爱国青年:AwADCAMABAoAAA==.',['�']='何晨光弹道:AwABCAEABAoAAA==.',['�']='停电寄:AwAECAQABAoAAA==.',['�']='六六折:AwABCAEABAoAAA==.',['�']='冥凰:AwAHCA0ABAoAAA==.冰雪糖糖:AwAICAIABAoAAA==.冷訫在线:AwAICAgABAoAAA==.',['�']='出鞘狂刃:AwABCAEABRQAAA==.',['�']='北山冰皇:AwADCAMABAoAAA==.',['�']='十七连击坦:AwAECAYABAoAAA==.千斤墜:AwAICBoABAoCAQAIAQgSIQAKr88ABAoAAQAIAQgSIQAKr88ABAoAAA==.半糖:AwAGCAYABAoAAA==.华年:AwAECAkABRQDDAAEAQg0CwArycoABRQADAAEAQg0CwAjXMoABRQABwAEAQgHEAAUDb0ABRQAAA==.华胥灬永眠:AwACCAIABAoAAA==.卵惊天:AwAECAQABAoAAA==.',['�']='双手跳舞:AwADCAQABAoAAA==.只会大风车:AwAECAMABRQAAA==.',['�']='后悔毒药:AwACCAIABRQAAA==.听风语:AwACCAIABRQAAA==.',['�']='咩玖:AwAFCA0ABAoAAA==.',['�']='唯你是青山:AwABCAEABAoAAA==.',['�']='啊哒哒鸭:AwAFCAEABAoAAA==.',['�']='喵耳朵:AwAICAkABAoAAA==.',['�']='噼里啪啪:AwABCAEABAoAAA==.',['�']='四喜团子:AwAGCAYABAoAAA==.',['�']='土豆土豆:AwAICBAABAoAAA==.地精:AwACCAIABRQAAA==.',['�']='埖喵喵丶:AwABCAIABRQAAA==.',['�']='墨方:AwAGCAIABRQAAA==.',['�']='夕颜西:AwAGCAYABAoAAA==.夜羽:AwAECBEABRQCBgAEAQiGBgBaNzoBBRQABgAEAQiGBgBaNzoBBRQAAA==.大姨妈归来:AwAFCAkABAoAAA==.天使安琪兒:AwABCAEABAoAAA==.天辣我好酷欸:AwABCAEABRQAAA==.',['�']='奥类莉亚:AwAECAQABRQAAA==.奥雷莉亚斯:AwAECAgABRQCDQAEAQiIDwA8EfEABRQADQAEAQiIDwA8EfEABRQAAA==.',['�']='孤丨影:AwACCAQABRQDDgAIAQhCFgBHLOMBBAoADgAHAQhCFgBHuuMBBAoACwAGAQhHLwBIH64BBAoAAA==.',['�']='宇宙公司马总:AwAGCAYABRQCBAAGAQgtAQA3Z78BBRQABAAGAQgtAQA3Z78BBRQAAA==.守护神的光芒:AwAICBoABAoCDwAIAQiOKAAzacUBBAoADwAIAQiOKAAzacUBBAoAAA==.安吉拉:AwABCAEABAoAAA==.安琪不哭:AwAGCAYABRQDDwAGAQjHAgA11FkBBRQADwAFAQjHAgA7YVkBBRQAEAABAQgWDQAfoFcABRQAAA==.',['�']='小土虫:AwACCAIABRQAAA==.小艾弗:AwAECAQABRQAAQIAQ8QICAcABRQ=.小鞋匠呀:AwAICAgABAoAAA==.尨影:AwAECAQABRQAAA==.',['�']='川川欧巴:AwAFCAUABAoAAA==.',['�']='希尔瓦蕾丝:AwADCAUABAoAAA==.希尔袜娜丝:AwAICAgABAoAAQYAN9MGCAkABRQ=.希沃斯:AwADCAMABRQAAREAISQECAYABRQ=.希达:AwAECAMABRQAAA==.帝霹哎丝:AwACCAIABRQAAQYAPf8GCAkABRQ=.带带我:AwABCAIABRQCCgAIAQigDQA/ACUCBAoACgAIAQigDQA/ACUCBAoAAA==.',['�']='弹道偏左:AwACCAMABRQAAA==.',['�']='彩色小恐龙:AwAICAgABAoAAA==.彩虹捕手:AwABCAEABAoAAA==.',['�']='快来摸我蛋蛋:AwAECAQABAoAAA==.',['�']='怒之鬼眼:AwAICAcABAoAAA==.',['�']='恶魔的猫猫:AwABCAEABAoAAA==.',['�']='我是老猫:AwAECAQABRQAAA==.',['�']='打篮球的胡僧:AwAECAQABRQAAA==.托内莉可:AwADCAUABRQCBQADAQi4BgA7n9EABRQABQADAQi4BgA7n9EABRQAARIAQgcECAwABRQ=.扯丶:AwACCAIABAoAAA==.',['�']='时尚的滑板鞋:AwAECAgABRQDEwAEAQhsEAAtZ+sABRQAEwAEAQhsEAAtZ+sABRQAFAAEAQhICAA28tgABRQAAA==.时间不是解药:AwAGCAYABAoAAA==.',['�']='星芋啵啵:AwAICAgABAoAAA==.星陨:AwADCAQABRQCBgAIAQjvLQBEWSUCBAoABgAIAQjvLQBEWSUCBAoAAA==.是墓尸:AwAGCAYABAoAAQMAVSUBCAEABRQ=.',['�']='普通小栗:AwABCAEABRQAAA==.',['�']='月华如练:AwAECAQABRQAAQkAAAAGCAIABRQ=.月岛雯:AwAECAQABRQAAA==.',['�']='枪与玫瑰:AwABCAEABRQAAA==.枫芯:AwAECAUABRQCAwAEAQjvBQA5o/IABRQAAwAEAQjvBQA5o/IABRQAAA==.',['�']='柚子:AwAICAgABAoAAA==.柴四麻子:AwAECAQABRQAAA==.',['�']='梦兮绘笔谈:AwABCAEABRQDFQAIAQijGABIVvoBBAoAFQAHAQijGABIXPoBBAoADAAEAQiERgBICPgABAoAAA==.梦回故乡:AwAICAcABAoAAA==.',['�']='樱丶散落:AwAFCAUABAoAAA==.',['�']='正气水:AwACCAEABRQCBgAIAQgTFQBTVZsCBAoABgAIAQgTFQBTVZsCBAoAAA==.步布不可以:AwACCAMABRQCEgAIAQg0DABKcUsCBAoAEgAIAQg0DABKcUsCBAoAAA==.死亡丨绿皮:AwABCAEABRQDBgAIAQjPSgA/KrMBBAoABgAIAQjPSgA/KrMBBAoAFgADAQhVWQAepX0ABAoAAA==.',['�']='气势非常到位:AwAICAgABAoAAA==.',['�']='沧阑:AwAICAsABAoAAA==.河原木桃香:AwAICBcABAoDEgAIAQjYEQBAn/4BBAoAEgAIAQjYEQA/9/4BBAoAFwAIAQg9TAAkhlsBBAoAAA==.',['�']='洛里兹:AwACCAIABRQAAA==.',['�']='浪客猎心:AwABCAEABRQAAA==.',['�']='淡如清水:AwAECAQABRQAAA==.',['�']='滑蹓蹓:AwACCAEABAoAAA==.滚筒洗衣机丶:AwAICAgABAoAAA==.',['�']='激进的软泥乖:AwACCAIABAoAAA==.',['�']='灬龍影:AwAICAgABAoAAA==.灵丶:AwAICAgABAoAAQoAVK4ECAwABRQ=.灵魂的觉醒:AwAICBAABAoAAA==.',['�']='熊猫胖乎乎丶:AwAECAQABAoAAA==.',['�']='牛丶牪丶犇:AwABCAEABRQDGAAIAQi0DQBHNzwBBAoAEwAHAQgQNABIP8QBBAoAGAAIAQi0DQAk/TwBBAoAAA==.',['�']='猛地给你七下:AwADCAMABAoAAA==.',['�']='琦琦小朋友:AwAHCA4ABAoAAA==.',['�']='瓶中信仰:AwAGCAUABAoAAA==.',['�']='画斗:AwAICAgABAoAAA==.',['�']='疯狂的术虱:AwADCAMABAoAAA==.',['�']='白色纽扣:AwACCAIABAoAAA==.白鲸氵:AwAECAQABRQAAA==.百变灬:AwAECAQABRQAAA==.',['�']='皮蛋:AwAFCAwABAoAAA==.',['�']='盐语糖:AwAICBQABAoCBAAIAQgnIgBXwn8CBAoABAAIAQgnIgBXwn8CBAoAAA==.',['�']='知彼知己:AwAICAwABAoAAA==.',['�']='福将:AwAICCMABAoCBAAIAQjQDwBaPc4CBAoABAAIAQjQDwBaPc4CBAoAAA==.',['�']='稳牛:AwACCAMABRQAAA==.',['�']='空丶白:AwABCAEABAoAAA==.空白丶:AwAECAwABRQDCgAEAQhOAwBUriYBBRQACgAEAQhOAwBUriYBBRQACAAEAQipBQBGev0ABRQAAA==.',['�']='糊糊宝宝:AwACCAIABAoAAA==.',['�']='红星:AwAECAQABRQAAA==.约吗:AwAICAgABAoAAA==.约翰雪豹:AwAECAQABRQAAA==.纹身小妹:AwAECAQABAoAAA==.',['�']='织光丶:AwAECAgABRQCBwAEAQjXBQBKThgBBRQABwAEAQjXBQBKThgBBRQAAA==.',['�']='罗格姆撒恩:AwAICAgABAoAAA==.',['�']='耐信:AwADCAEABRQAAA==.',['�']='肥大民:AwAECAYABAoAAA==.',['�']='舒茉:AwAECAwABRQCEgAEAQgsCQBCB+EABRQAEgAEAQgsCQBCB+EABRQAAA==.',['�']='芯茹花木:AwAICBMABAoAAA==.',['�']='草喵喵:AwAECAUABRQDBwAEAQiCCwA1j+EABRQABwAEAQiCCwA1j+EABRQADAABAQgaIQAJ8TMABRQAAA==.草莓:AwADCAMABAoAAA==.',['�']='萨暗的萨:AwACCAIABRQAAA==.',['�']='董大胖:AwAECAQABAoAAA==.葬铭:AwACCAIABAoAAA==.',['�']='蒲牢丶:AwAGCAYABRQCEwAGAQhyAABQu/YBBRQAEwAGAQhyAABQu/YBBRQAAA==.',['�']='蕾娜莉亚:AwACCAcABRQCBwACAQhBEgBG66kABRQABwACAQhBEgBG66kABRQAAA==.',['�']='西楼梦影:AwAGCAcABAoAAA==.',['�']='詮釋神話:AwAECAQABRQCCgAEAQhRBwAuaPIABRQACgAEAQhRBwAuaPIABRQAAA==.詹尼丶:AwAECAQABRQCFgAIAQg8FgBAdvIBBAoAFgAIAQg8FgBAdvIBBAoAAQkAAAAICAQABRQ=.',['�']='誷事如风:AwAHCAcABAoAAA==.',['�']='试墨临池:AwAICBEABAoAAA==.诚诚橙:AwAGCAQABRQAAQkAAAAICAQABRQ=.诶滴盖奶:AwAECAQABRQAAQkAAAAGCAIABRQ=.',['�']='走过孤独:AwAGCAQABRQAAA==.起舞枫林间:AwADCAMABAoAAA==.',['�']='超屁:AwACCAEABAoAAA==.超级大笨蛋:AwADCAIABRQAAA==.',['�']='软席吉吉:AwAGCAwABAoAAA==.',['�']='进击的绯皇:AwACCAIABAoAAA==.',['�']='逗逼德:AwAFCAMABRQAAQkAAAAICAIABRQ=.',['�']='遐想狂:AwAGCAYABAoAAA==.',['�']='那各法湿:AwABCAEABRQAAA==.',['�']='酒浅宜深:AwABCAEABAoAAA==.',['�']='钵兰街十三妹:AwACCAMABRQCBAAIAQhRIwBRrnsCBAoABAAIAQhRIwBRrnsCBAoAAA==.',['�']='铭刻星光:AwAECAQABAoAAA==.',['�']='锂电法王:AwAECAQABRQAAA==.',['�']='镜花水月灬灬:AwAICAUABAoAAA==.',['�']='闪光的拉内特:AwACCAIABAoAAA==.闲云晓牧:AwAGCAgABAoAAQkAAAAICBAABAo=.',['�']='雪风妖精:AwAICBAABAoAAA==.',['�']='青瓷白画殇:AwAGCAYABAoAAA==.',['�']='风永远的使徒:AwABCAEABAoAAA==.',['�']='馒头墩儿:AwAECAYABRQDDQAEAQgqCABQGhsBBRQADQAEAQgqCABQGhsBBRQAGQABAQhIFQAeIDcABRQAAA==.',['�']='高文:AwADCAMABAoAAA==.',['�']='鹿小咪:AwAECAQABAoAAA==.',['�']='黑锋骑士:AwACCAIABAoAAA==.',['�']='龍影灬:AwAECAQABRQAAA==.龙啸圣骑:AwAECAQABRQAAA==.龙西:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end