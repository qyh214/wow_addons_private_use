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
 local lookup = {'Paladin-Protection','Warlock-Destruction','Warlock-Affliction','Shaman-Enhancement','Priest-Discipline','Hunter-BeastMastery','Mage-Fire','Mage-Frost','Paladin-Retribution','Shaman-Elemental','Shaman-Restoration','Hunter-Marksmanship','Unknown-Unknown','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Frost','Warrior-Fury','Warrior-Protection','Rogue-Assassination','Rogue-Subtlety','Monk-Brewmaster',}; local provider = {region='CN',realm='桑德兰',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Amdyes:AwAICBQABAoCAQAIAQjCBgBQ+4QCBAoAAQAIAQjCBgBQ+4QCBAoAAA==.',Bi='Bigdandan:AwAECAEABRQAAA==.',Cu='Cua:AwADCAIABAoAAA==.',Cy='Cyy:AwAFCAcABAoAAA==.',Da='Dam:AwAECBIABRQDAgAEAQgqAwBemjoBBRQAAgAEAQgqAwBemjoBBRQAAwACAQhtDwA7eo8ABRQAAQIASvQICBMABRQ=.',Mi='Missa:AwAECAQABRQAAA==.',Ni='Nightwish:AwAICAUABAoAAA==.',Ra='Radahnstar:AwACCAIABRQAAQQAM3YICAkABRQ=.',Ro='Rodge:AwAECAQABRQAAA==.',So='Soraka:AwACCAIABRQCBQAIAQhgKAAmOGUBBAoABQAIAQhgKAAmOGUBBAoAAA==.',St='String:AwAECAQABAoAAA==.',['�']='一碗蛋炒饭:AwAHCAQABAoAAA==.上东好身体:AwAICAkABAoAAA==.与你远行:AwABCAEABAoAAA==.东方小钢炮:AwACCAIABRQCBgAIAQjOGQBP4HsCBAoABgAIAQjOGQBP4HsCBAoAAA==.丨唯灬爱丶:AwACCAIABAoAAA==.丨霜龙谣丨:AwACCAIABAoAAA==.',['�']='乄铁牛乄:AwABCAIABRQAAA==.九品:AwAECAkABRQCBgAEAQiGGQAdKs0ABRQABgAEAQiGGQAdKs0ABRQAAQcALZoICAUABRQ=.九耀星璇:AwAHCAoABAoAAA==.',['�']='你要的温柔:AwADCAMABAoAAA==.佲亽嘡丨星云:AwAICA0ABAoAAA==.',['�']='偶有爱宠:AwABCAEABRQAAA==.',['�']='内个:AwAECA0ABRQDCAAEAQj3BwBD98gABRQABwAEAQhLFAA0s+cABRQACAAEAQj3BwAx0cgABRQAAA==.',['�']='凛东之怒:AwABCAEABRQCCQAGAQjtiwBGuFEBBAoACQAGAQjtiwBGuFEBBAoAAA==.',['�']='刀疤刘三姐:AwABCAEABAoAAA==.刘书睿:AwABCAEABAoAAA==.',['�']='历史问题:AwAFCAEABAoAAA==.',['�']='又菜又爱玩吖:AwAICA8ABAoAAA==.古尓薇格:AwADCAQABAoAAA==.古法龙舌兰:AwAICAgABAoAAA==.',['�']='咆哮霸王丸:AwAHCAoABAoAAA==.',['�']='商氦寅:AwAHCAgABAoAAA==.',['�']='喜安逸的北人:AwAICAIABAoAAQIAUIwGCAYABRQ=.喵猫的守护兽:AwACCAMABRQAAA==.',['�']='噼里啪啦丶:AwAECAgABRQDCgAEAQg6AQBgJ0ABBRQACgAEAQg6AQBgJ0ABBRQACwAEAQgPEQAWsccABRQAAA==.',['�']='团长缺不缺德:AwABCAEABRQAAA==.',['�']='圣布丁:AwACCAcABRQCCQACAQiOHgBXG8QABRQACQACAQiOHgBXG8QABRQAAA==.圣斗士亮仔:AwAFCAUABAoAAA==.圣殿大领主:AwAFCAsABAoAAA==.',['�']='塞力菲:AwAHCAoABAoAAA==.',['�']='复仇之云:AwACCAIABRQAAA==.大武僧:AwAGCAcABAoAAA==.天丨佑:AwABCAEABRQAAA==.',['�']='奥蕾丶莉亚:AwAECAQABRQAAA==.女儿国小妖:AwAECAgABAoAAA==.奶豆儿:AwAHCAcABAoAAA==.',['�']='如梦般清醒:AwACCAQABRQAAA==.',['�']='守望月神:AwADCAQABRQAAA==.宝宝愛吃肉:AwAGCAQABRQAAA==.宣萱:AwAGCAsABAoAAA==.',['�']='寒冰射兽:AwAICBAABAoAAA==.',['�']='小尾巴翘翘:AwAICAgABAoAAA==.小山药:AwACCAIABAoAAA==.尛丶槑:AwAGCAYABAoAAA==.',['�']='屁威易武僧:AwAGCAYABAoAAA==.',['�']='布丁很忙:AwABCAEABAoAAA==.布拉维砍屠夫:AwAICA4ABAoAAA==.',['�']='引天行:AwAFCAUABAoAAA==.弹棉花艺术家:AwAECAwABRQDDAAEAQhFAQBbrzwBBRQADAAEAQhFAQBbrzwBBRQABgACAQi5KwAnYoIABRQAAQ0AAAAICAQABRQ=.',['�']='当哩个当当:AwABCAEABAoAAA==.影飛鳥:AwADCAMABAoAAA==.',['�']='德之魂:AwACCAIABAoAAA==.',['�']='怎么嗨了:AwABCAEABAoAAA==.思密达灬兔子:AwABCAIABRQDBgAIAQjaIQBOJFMCBAoABgAIAQjaIQBKD1MCBAoADAAGAQiNNgBNigUBBAoAAA==.',['�']='惡魔在洗澡:AwACCAIABRQAAA==.',['�']='我将直面死亡:AwABCAEABRQAAA==.我就是老赵:AwAICBMABAoAAA==.战争灬游侠:AwAICA4ABAoAAA==.戴伦坦格利安:AwAGCAcABAoAAA==.',['�']='执着的荣耀:AwAECAQABRQAAA==.',['�']='折翼的守护:AwABCAIABRQAAA==.',['�']='振翅猫头鹰:AwACCAcABRQDDgACAQhiGQA7AKIABRQADgACAQhiGQA7AKIABRQADwABAQg9HAAQTzUABRQAAA==.',['�']='摇曳的满天星:AwABCAEABAoAAA==.',['�']='斯巴拉西:AwAECA0ABRQCBgAEAQhxBgBfzDIBBRQABgAEAQhxBgBfzDIBBRQAAQ0AAAAICAQABRQ=.新不聊情:AwAHCA4ABAoAAA==.',['�']='无敌强哥:AwAICBAABAoAAA==.无痕清波:AwACCAQABRQCCQAIAQiBPABErxcCBAoACQAIAQiBPABErxcCBAoAAA==.日光倾城丶:AwABCAQABRQAAA==.时光姬:AwAICA0ABAoAAA==.',['�']='昼天空:AwAGCAYABAoAAA==.',['�']='智体美劳:AwAECAQABRQAAA==.',['�']='月影风尘:AwAECAYABAoAAA==.月舞花熙:AwAECAQABRQAAA==.未央洛洛:AwAECAQABRQAAA==.',['�']='来份蒸熊掌:AwADCAMABAoAAA==.',['�']='果酱小可爱:AwAICAgABAoAAA==.',['�']='查内母:AwAICAgABAoAAA==.',['�']='梦小妖:AwABCAEABRQAAA==.',['�']='橙色体育生:AwAECAQABRQAAA==.',['�']='死亡一凋零:AwABCAEABRQDEAAIAQhURQAfRWcBBAoAEAAIAQhURQAd4mcBBAoAEQAGAQhuFwAgjPgABAoAAA==.死亡深度:AwAECAQABAoAAA==.',['�']='殇丶戰:AwACCAIABAoAAA==.殒落之殇:AwAECAQABRQAAA==.',['�']='比例孟婆恩:AwAGCBMABRQCCQAGAQi1AAA9QssBBRQACQAGAQi1AAA9QssBBRQAAA==.',['�']='江小皮的双彩:AwABCAEABAoAAA==.',['�']='法爷邓布利多:AwABCAEABAoAAA==.波罗米亚:AwACCAIABAoAAA==.',['�']='洛云书:AwAICAgABAoAAA==.洛水之畔:AwACCAIABAoAAQ0AAAAICAgABAo=.',['�']='深海灬孤獨:AwAFCAkABAoAAA==.深秋一刻:AwAECAQABRQAAA==.深秋二刻:AwAICAYABAoAAA==.',['�']='清哲:AwAECAQABRQAAA==.',['�']='滴滴地叨叨:AwAGCAEABAoAAA==.',['�']='灬北辰诗情灬:AwADCAMABAoAAA==.灬女乃流香灬:AwAFCAUABAoAAA==.',['�']='烧阿烧冰阿冰:AwAECAcABAoAAA==.',['�']='無尘:AwAICAkABAoAAA==.',['�']='熊大力:AwABCAEABRQAAA==.',['�']='狂风矿泉水:AwADCAQABAoAAA==.',['�']='猎神慕晓:AwAECAQABRQAAA==.猛小牛:AwAECAQABRQAAA==.',['�']='王贼海:AwABCAEABRQAAA==.玩世不恭:AwAECAYABRQDEgAEAQgTDQAqY/UABRQAEgAEAQgTDQAqY/UABRQAEwACAQipBwAOSWcABRQAAA==.',['�']='瓦王丶列车:AwAGCAYABRQCAQAGAQhPAABXyf8BBRQAAQAGAQhPAABXyf8BBRQAAA==.',['�']='白鬼院凛凜蝶:AwACCAIABAoAAQ0AAAAGCAgABAo=.',['�']='知更:AwAECAIABAoAAA==.石原丶里美:AwAICA4ABAoAAA==.石门大漂亮:AwAECAQABRQAAA==.',['�']='神圣公主:AwAICAgABAoAAA==.',['�']='私人定制:AwAECAgABRQCCAAEAQjQAwBEUAgBBRQACAAEAQjQAwBEUAgBBRQAAA==.秋巴比母捏牛:AwAECA0ABRQCBQAEAQhXCQA5SOkABRQABQAEAQhXCQA5SOkABRQAAA==.',['�']='稳点疯子:AwAHCAcABAoAAA==.',['�']='翻脸猴子:AwAECAQABAoAAQ0AAAAHCBIABAo=.',['�']='老从家小熊:AwAGCAYABAoAAA==.老幕:AwABCAEABRQAAA==.老汉丶:AwAICAgABAoAAA==.',['�']='脂包肌的狼狗:AwABCAEABRQAAA==.脸比城墙厚:AwAICAwABAoAAA==.',['�']='腐臭的小白尸:AwAICAUABAoAAA==.',['�']='花葬鶄:AwAECAMABRQAAA==.芳颜木琬清:AwAGCAYABAoAAA==.',['�']='荷笠戴夕阳:AwAFCAUABAoAAA==.',['�']='莎莎:AwADCAMABAoAAA==.',['�']='萨西摩尔:AwAECAsABAoAAA==.',['�']='蓝紫色的雨:AwAHCAYABAoAAA==.',['�']='西南人:AwACCAYABRQCCwACAQgKGQAsc5MABRQACwACAQgKGQAsc5MABRQAAA==.西弗吉尼亚:AwABCAEABAoAAA==.',['�']='诗情小跟班:AwAHCA4ABAoAAA==.诺达希尔的风:AwAFCAUABAoAAA==.',['�']='谢广昆:AwAECAQABRQAAA==.',['�']='豆腐泡了:AwACCAcABRQCAQACAQh8DgAPKF0ABRQAAQACAQh8DgAPKF0ABRQAAA==.',['�']='赵瑞龙:AwAFCAUABAoAAA==.',['�']='软甜超可爱的:AwAECAQABRQDFAAIAQh3CABTPmcCBAoAFAAIAQh3CABTPmcCBAoAFQAFAQjBIwAunNwABAoAARUAUjcGCBMABRQ=.轻風之语丶:AwAECAIABRQAAA==.',['�']='辛多雷之魂:AwACCAIABAoAAA==.',['�']='酒酿十里香:AwACCAMABRQCFgAIAQiACgAypYUBBAoAFgAIAQiACgAypYUBBAoAAA==.',['�']='钱乱花:AwAECAQABRQAAA==.',['�']='长大还真壮:AwAECAEABAoAAA==.',['�']='阴阳不测:AwAECAQABRQAAA==.阿漫:AwAFCAUABAoAAA==.',['�']='雨落八月:AwAECAkABRQCDgAEAQgqDwBB7ekABRQADgAEAQgqDwBB7ekABRQAAA==.雨落無痕灬:AwACCAIABRQAAA==.雷伊诺:AwACCAIABRQAAA==.',['�']='霹雳佬头:AwAICBQABAoCCwAIAQj+DABSF3gCBAoACwAIAQj+DABSF3gCBAoAAA==.',['�']='静小娴:AwAECAQABRQAAA==.非典型孤独症:AwAECAQABRQAAA==.',['�']='鞭婦侠:AwAICAYABAoAAA==.',['�']='風吹散的承諾:AwADCAgABRQCEAADAQhWDwAxHtIABRQAEAADAQhWDwAxHtIABRQAAA==.',['�']='飘逸乄:AwAECAQABRQAAA==.',['�']='鶄爵:AwACCAIABRQAAA==.',['�']='黑猫信守:AwAICAsABAoAAA==.黑缝要塞:AwABCAEABAoAAA==.',['�']='鼠鼠猫狗鸡:AwAECAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end