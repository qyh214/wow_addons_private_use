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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Priest-Shadow','Unknown-Unknown','Warlock-Demonology','Druid-Restoration','Druid-Balance','Mage-Fire','Monk-Mistweaver','Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','Warrior-Arms','Warrior-Fury','Hunter-Survival','Evoker-Ranged','Rogue-Outlaw','Priest-Holy','Monk-Windwalker','DeathKnight-Blood','Mage-Frost','Paladin-Retribution','Monk-Brewmaster','Druid-Feral','Druid-Guardian','DemonHunter-Havoc','Warlock-Affliction','Warlock-Destruction','DemonHunter-Vengeance',}; local provider = {region='CN',realm='翡翠梦境',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Altman:AwAECAQABRQAAA==.',Ar='Arkanis:AwABCAEABRQAAA==.',Cl='Cloudyday:AwAECAYABRQDAQAEAQiLHQBDEMEABRQAAQADAQiLHQBUc8EABRQAAgADAQgkEAAhG6sABRQAAA==.',Cr='Creeperjc:AwACCAIABRQCAwAIAQgZDwBVG5YCBAoAAwAIAQgZDwBVG5YCBAoAAA==.',Cw='Cwgg:AwABCAEABRQAAA==.',El='Elenion:AwAGCA8ABAoAAA==.',Fo='Foglia:AwACCAIABAoAAA==.',Gp='Gpk:AwAECAQABRQAAA==.',Ha='Haruka:AwAICAgABAoAAA==.',Hi='Hikaruex:AwAFCAMABAoAAA==.',Ma='Martin:AwAECAUABRQDBAAEAQiKBgA1sfsABRQABAAEAQiKBgA1sfsABRQABQABAQi0DgAsI1EABRQAAA==.',Na='Nafa:AwAICAYABAoAAA==.',Ne='Nefarin:AwAGCAQABRQCBgAIAQgdHgA8hskBBAoABgAIAQgdHgA8hskBBAoAAA==.',No='Norns:AwAECAMABRQAAA==.',Pl='Playerzkszkv:AwAECAEABAoAAA==.',Sa='Sanctuary:AwABCAEABAoAAA==.Santamaria:AwAGCAQABRQAAA==.Sapphire:AwAECAQABRQAAA==.',Se='Setusna:AwACCAUABRQCAgACAQgPFgAcCHoABRQAAgACAQgPFgAcCHoABRQAAA==.',St='Styw:AwACCAIABAoAAA==.',Th='Thok:AwABCAEABRQAAQcAAAAECAQABRQ=.',To='Towningo:AwAICBcABAoCCAAIAQgQBgBKh14CBAoACAAIAQgQBgBKh14CBAoAAA==.',Ye='Yelu:AwADCAMABAoAAA==.',Zt='Ztom:AwACCAIABRQAAA==.',['�']='一只肥香肠:AwADCAMABRQAAQkAOkwGCAUABRQ=.三个太阳:AwACCAIABAoAAA==.三千雷动:AwADCAMABRQAAA==.三鹿女王柴:AwADCAEABAoAAA==.不想变成熊豹:AwAECAUABRQCCgAEAQi7EAAsG+oABRQACgAEAQi7EAAsG+oABRQAAA==.不爱吃芥末:AwAICAgABAoAAA==.不知东方即白:AwAFCAUABAoAAA==.不能掉链子:AwACCAIABAoAAA==.丨贼辣丨:AwAECAQABRQAAA==.中年大叔熊:AwACCAMABAoAAA==.临安袭初雨:AwAICAsABAoAAQsAT1sHCAUABRQ=.丶人间:AwAICBgABAoCDAAIAQjFEQBKeUkCBAoADAAIAQjFEQBKeUkCBAoAAA==.丶小元宝丶:AwAICBUABAoCAgAIAQgkCwBdoWkCBAoAAgAIAQgkCwBdoWkCBAoAAA==.丶小当家:AwAECAQABRQAAA==.丷初心丷:AwAICAgABAoAAA==.丷小白狼丷:AwAECAUABAoAAA==.',['�']='乂稀飯你的笑:AwAECAQABAoAAA==.久遠寺有珠:AwACCAQABAoAAA==.乌鸦坐飞鸡:AwAGCAcABAoAAA==.九天风狼:AwACCAIABAoAAA==.',['�']='仓鸮:AwACCAIABRQAAA==.',['�']='伊波恩:AwAGCAUABAoAAA==.',['�']='体育生:AwABCAEABRQAAA==.佟大为:AwAECAQABRQAAA==.你听我解释:AwACCAQABRQAAA==.',['�']='依修托利:AwADCAQABAoAAA==.',['�']='倾听之喃:AwAECAQABRQAAA==.',['�']='做蛋糕:AwAECAQABRQAAA==.',['�']='六道圣蹄:AwAFCAUABAoAAA==.养猪妹:AwACCAQABRQEDQAIAQiqEABOPFICBAoADQAIAQiqEABOPFICBAoADgAFAQgdewAZvqkABAoADwABAQhMVAAftD8ABAoAAA==.',['�']='再度冲锋:AwAGCAkABRQDEAAGAQiCBwAx1MUABRQAEQAEAQikDwAoK+wABRQAEAADAQiCBwBAUcUABRQAAA==.冥锋剑霜寒:AwAFCAUABAoAAA==.冬暖丨夏凉:AwAGCAsABRQCCwAGAQgSBAAzcZ4BBRQACwAGAQgSBAAzcZ4BBRQAAA==.冷白皮的芮:AwAGCAYABAoAAA==.冷風吹:AwACCAIABRQAAA==.',['�']='刀锋偏冷:AwAECAMABAoAAA==.',['�']='勇闯红绿灯:AwAECAoABRQCAQAEAQjqEwAyVfIABRQAAQAEAQjqEwAyVfIABRQAAQIAQc0GCAYABRQ=.',['�']='北月丶:AwAHCAIABAoAAA==.',['�']='十一夜堕天使:AwAECAQABRQAAA==.十三夜堕天使:AwAECAQABAoAAA==.千兆:AwAICBAABAoAAA==.千户丶:AwACCAMABRQDEgAIAQitBQBJuOgBBAoAEgAIAQitBQA5XugBBAoAAQAHAQhgTwA5xqQBBAoAAA==.半角全角:AwAECAYABRQDCgAEAQhxFwAic8UABRQACgADAQhxFwAic8UABRQACQADAQjBEgAknHoABRQAAQcAAAAGCAIABRQ=.卡芙奇诺:AwAGCAcABAoAAA==.',['�']='及魔不寂寞:AwAECAYABRQCDgAEAQgPCQA8bAABBRQADgAEAQgPCQA8bAABBRQAAQ4ANG8GCAYABRQ=.双月:AwABCAEABRQAAA==.可乐曜曜:AwAECAQABAoAAA==.可以变咸鱼:AwAECAQABRQAAA==.可可豆:AwAGCAgABAoAAA==.',['�']='吃相难看:AwAHCAgABAoAAA==.吞食天地:AwAECAUABAoAAA==.听说这职业扚:AwAHCAwABAoAAA==.',['�']='呆萌二胖:AwAFCAUABAoAAA==.告别的时代:AwACCAEABRQAAA==.',['�']='咪啪咕:AwAGCAYABAoAAA==.咬妹的射击猎:AwABCAEABRQAAA==.咬妹的骑士:AwAGCBEABAoAAA==.',['�']='哀木剃:AwAECAQABRQAAA==.哈白想:AwACCAQABRQCAwAIAQg7HwBMkSgCBAoAAwAIAQg7HwBMkSgCBAoAAA==.哦豁丶:AwAECA0ABRQCBgAEAQj3CQA/qPgABRQABgAEAQj3CQA/qPgABRQAAA==.',['�']='唐伯虎点蚊香:AwAECAQABRQAAA==.唐贰牛:AwAFCAMABAoAARMAOcgGCAYABRQ=.',['�']='喂喂听得到吗:AwAFCAMABAoAAA==.喵喵虫:AwADCAgABRQCFAADAQhiAABUaj4BBRQAFAADAQhiAABUaj4BBRQAAA==.喵眠月下:AwADCAMABAoAAA==.',['�']='圣光梅超风:AwAFCAkABAoAAA==.圣华贯天虹:AwAICAgABAoAAA==.地底恶魔:AwAECAQABRQAAA==.',['�']='壬权道:AwAICAMABAoAAA==.',['�']='夕夏丶:AwABCAEABAoAAA==.多拉贡荡斯:AwACCAQABRQAAA==.夜雨声烦:AwAICAwABAoAAA==.大屁墩:AwAFCAMABAoAAA==.大眼睛噜噜:AwADCAMABAoAAA==.大耳达尼亚:AwABCAEABRQAAA==.大雷童鞋:AwAGCAIABRQAARUAP+IICAUABRQ=.天命人残躯:AwAECAEABRQAAA==.天竺国小麻辣:AwACCAIABRQAAA==.',['�']='奥利奥麦旋风:AwADCAMABRQAAA==.女拳糕手:AwADCAUABRQCDAADAQhOCQBMTQYBBRQADAADAQhOCQBMTQYBBRQAAA==.好风凭借力:AwAECAQABRQAAA==.',['�']='如尨:AwAGCAsABAoAAA==.',['�']='宋哈娜丶:AwABCAEABRQAAA==.',['�']='小人展翅:AwAECAQABRQAAA==.小刘:AwAGCAYABAoAAA==.小可爱李哼哼:AwAGCAwABAoAAA==.小浣熊丶:AwACCAQABRQDDAAIAQiRHQA7tegBBAoADAAIAQiRHQA7tegBBAoAFgAHAQjEMwAchjIBBAoAAA==.小蝴蝶结君丶:AwAICAgABAoAAA==.小阎王:AwAGCAwABAoAAA==.小鸟丶花月:AwACCAQABRQAAA==.尼古拉丁真:AwAGCAYABAoAAA==.',['�']='嵐姬:AwACCAIABRQAAA==.',['�']='希格纳姆:AwAFCAUABAoAAA==.希芮:AwACCAEABRQAAA==.',['�']='幽猫:AwAFCAMABAoAAA==.',['�']='彩丽:AwACCAMABAoAAA==.',['�']='心碎碎的雨:AwAICAgABAoAAA==.快乐大柠檬:AwAGCAMABAoAAA==.',['�']='怪人:AwAICAgABAoAAA==.',['�']='恶魔的问候:AwACCAIABRQAAA==.',['�']='成分复杂的狼:AwAICAkABAoAAA==.我又没钱了:AwADCAkABRQCAwADAQjnDwAkLtwABRQAAwADAQjnDwAkLtwABRQAAA==.我无限嚣张:AwAICAoABAoAAA==.我无限嚣張:AwAICAgABAoAAA==.我爱喝茶:AwAECAUABRQCAgAEAQisBQBP4gIBBRQAAgAEAQisBQBP4gIBBRQAAA==.',['�']='招猫逗狗:AwAECAYABRQCAQAEAQiDFwAsWOUABRQAAQAEAQiDFwAsWOUABRQAAA==.',['�']='指间纱:AwAICAgABAoAAA==.',['�']='换形师:AwAECAYABAoAAA==.',['�']='摄像师:AwABCAEABRQCCQAIAQguGQA5W9oBBAoACQAIAQguGQA5W9oBBAoAAA==.摸鱼高手:AwADCAUABRQCFgADAQgCCQAyG+sABRQAFgADAQgCCQAyG+sABRQAAA==.',['�']='攻夫基德:AwAFCAUABAoAAA==.',['�']='无敌灵牧:AwAECAQABRQAAA==.无风丶:AwAFCAwABAoAAA==.',['�']='易山:AwACCAIABAoAAA==.星空丿落颜:AwABCAEABRQAAA==.是谁坏了天气:AwAECAIABRQAAA==.',['�']='最后的轻语:AwAFCAcABAoAAA==.月下虫虫飞:AwAECAgABRQCAQAEAQh5CgBctRsBBRQAAQAEAQh5CgBctRsBBRQAAA==.木木枭:AwACCAIABRQAAA==.',['�']='李维坦:AwACCAMABRQAAA==.',['�']='柒木沐:AwABCAEABRQAAA==.柒柒骑:AwACCAIABRQAAA==.',['�']='桀骜奶糖:AwAFCAYABAoAAA==.桃蓬蓬:AwAECA4ABRQCCgAEAQg+BgBbgiUBBRQACgAEAQg+BgBbgiUBBRQAAA==.',['�']='森海飞鰕:AwAGCAoABRQCFwAGAQhoAQA2YIMBBRQAFwAGAQhoAQA2YIMBBRQAAA==.',['�']='橙灬运:AwACCAIABRQAAA==.',['�']='欧丶皇爷:AwACCAIABAoAAA==.',['�']='武汉张学友:AwAFCAUABAoAAA==.',['�']='永恒极光:AwAECAQABRQAAA==.',['�']='求奶丶:AwAGCAgABRQCEAAGAQhLAABJruoBBRQAEAAGAQhLAABJruoBBRQAAA==.江城子:AwAECAQABAoAAA==.',['�']='沙奈朵:AwAFCAUABAoAAA==.沧海映星月:AwAFCAMABAoAAA==.',['�']='法力浮龙:AwAECAwABRQDGAAEAQh0BgA7lesABRQAGAADAQh0BgA6m+sABRQACwAEAQiRGwAiLNYABRQAAA==.法力蓝:AwAHCBsABAoCGQAHAQgpiwAq82ABBAoAGQAHAQgpiwAq82ABBAoAAA==.波枫水門:AwAFCA4ABAoAAA==.波枫水门:AwACCAQABRQAAA==.',['�']='浣熊鸭:AwAGCAYABAoAAA==.浮生:AwAFCAMABAoAAA==.',['�']='淡笑灬红颜:AwAFCAUABAoAAA==.淡笑红颜:AwACCAQABRQCGgAIAQhABABO1FcCBAoAGgAIAQhABABO1FcCBAoAAA==.',['�']='渊行:AwAGCAkABRQDBQAEAQiCBQA7kP4ABRQABQAEAQiCBQA7kP4ABRQABAACAQjXDwA04Y0ABRQAAA==.',['�']='湍汾:AwACCAIABRQAAA==.',['�']='灬丶风语:AwADCAMABAoAAA==.',['�']='点个夜宵吧:AwAECAwABRQCBgAEAQgeCQBK/P8ABRQABgAEAQgeCQBK/P8ABRQAAA==.',['�']='熊猫人:AwAECAwABRQCDAAEAQg6CgA8p/4ABRQADAAEAQg6CgA8p/4ABRQAAQcAAAAGCAQABRQ=.熊猫會武術:AwACCAMABRQDGwAIAQgMDwApg4wBBAoAGwAHAQgMDwAr84wBBAoAHAABAQhlLgAa3xsABAoAAA==.',['�']='爫灬爫:AwAECAwABRQCCgAEAQgTCwBHWQMBBRQACgAEAQgTCwBHWQMBBRQAAA==.爱疯癫:AwABCAEABRQAAA==.',['�']='牛牛不要香菜:AwAGCAcABAoAAA==.牛镇江:AwAECAQABRQAAA==.特狼莆:AwAGCAUABAoAAA==.',['�']='犇犇的爸爸:AwAICBgABAoCGQAIAQjTowATJSoBBAoAGQAIAQjTowATJSoBBAoAAA==.犹豫着堕落:AwACCAIABRQAAA==.',['�']='狂暴的小可乐:AwABCAEABRQAAA==.狂野西红柿:AwABCAEABAoAAA==.狐图图:AwADCAMABAoAAA==.狗子:AwAECAsABRQDAQAEAQhFGgBGqtgABRQAAQADAQhFGgAqAtgABRQAAgADAQgcEABESKsABRQAAA==.',['�']='猪油渣:AwAICA0ABAoAAA==.猪猪包:AwAHCAEABAoAAA==.猪猪鱼:AwAFCAUABAoAAA==.猫咪:AwAECAQABRQAAA==.猫猫狗鸡:AwACCAQABRQDAQAIAQhiFwBTdY8CBAoAAQAIAQhiFwBTMI8CBAoAEgAFAQhJEAA2jsMABAoAAA==.',['�']='玉华洞白晶晶:AwADCAMABAoAAA==.',['�']='班屉:AwAICAgABAoAAA==.',['�']='疾璇鼬:AwAECAQABAoAAA==.',['�']='白日就是做梦:AwAGCAcABAoAAA==.白鹿青崖间:AwAICAgABAoAAA==.',['�']='盏茶:AwAECAQABRQAAQcAAAAICAQABRQ=.',['�']='短笛:AwAICBkABAoCDAAIAQhyIAA5zdMBBAoADAAIAQhyIAA5zdMBBAoAAA==.',['�']='碧空清影:AwABCAEABRQAAA==.',['�']='祁月:AwAGCAEABAoAAA==.神圣的熊叔:AwAFCAMABAoAAA==.神域丶熊叔:AwAFCAMABAoAAA==.神罗烬虎:AwAICBgABAoDGgAIAQivBABNAEMCBAoAGgAIAQivBABNAEMCBAoADAAIAQgTOgAa/UQBBAoAAA==.神罗苍曜:AwAICAgABAoAAA==.',['�']='秀尔瓦娜斯:AwAICAgABAoAAA==.秋之回忆:AwAECAQABRQAAA==.',['�']='糖果灬雪雪:AwABCAEABRQCAQAIAQgSFgBQ3ZYCBAoAAQAIAQgSFgBQ3ZYCBAoAAA==.',['�']='紫靖贝勒:AwAFCAUABAoAAA==.',['�']='红双喜:AwAGCAgABAoAAA==.纳多戈拉斯:AwACCAIABRQAAA==.',['�']='绫波丽:AwAGCAYABAoAAA==.维纳妮妮:AwAFCAUABAoAAA==.',['�']='缥缈孤鸿影丨:AwADCAsABRQCDAADAQjnBQBVBikBBRQADAADAQjnBQBVBikBBRQAAA==.',['�']='翡翠小葫芦:AwACCAQABRQCAQAIAQi/HQBVdW8CBAoAAQAIAQi/HQBVdW8CBAoAAA==.',['�']='老当益壮:AwAECAQABAoAAA==.',['�']='肖晓笑:AwAECAYABRQCAwAEAQhBCgBDs/wABRQAAwAEAQhBCgBDs/wABRQAAA==.肘进科穴:AwADCAMABAoAAA==.肿么啦:AwABCAEABAoAAA==.',['�']='胖乎乎:AwAFCAUABAoAAA==.胖墩与萌兽:AwACCAIABRQAAA==.',['�']='艶舞:AwAHCAkABAoAAQ8ARZsICAUABRQ=.艾尔蒂斯:AwAHCAcABAoAAA==.',['�']='芝麻五谷豆沙:AwADCAYABAoAAA==.',['�']='苍月无痕:AwACCAIABRQAAA==.苍白边缘:AwAECAQABRQAAA==.',['�']='莆田小公举:AwABCAEABRQAAA==.莫莫拉莫拉:AwAHCA0ABAoAAA==.',['�']='萌咕咕:AwAFCAUABAoAAA==.萨拉赫丁:AwACCAIABRQCFwAIAQhcIQAqWVwBBAoAFwAIAQhcIQAqWVwBBAoAAA==.萨满大人驾到:AwAICAgABAoAAA==.萨满技师:AwAICAYABAoAAA==.',['�']='蒙眼苍蝇:AwABCAEABRQAAA==.',['�']='薛定谔之喵:AwAECAQABAoAAA==.',['�']='蛇舞:AwAECAQABAoAAA==.',['�']='要楽奈:AwACCAIABRQAAA==.',['�']='许黎:AwAICAgABAoAAA==.',['�']='贝杀:AwAICAsABAoAAA==.贪杯的灵魂:AwAECAQABRQAAQsAVEsICBAABRQ=.贵族屁屁:AwABCAEABRQCCwAIAQidHABF/z4CBAoACwAIAQidHABF/z4CBAoAAQsAMkEGCAgABRQ=.',['�']='踏歌行:AwAECAIABRQAAA==.',['�']='车迟国老北鼻:AwAICAMABAoAAA==.转运锦鲤鱼王:AwAHCBIABAoAAA==.轻轻听:AwAECAQABRQAAA==.',['�']='辛诺斯丶双刃:AwAECAQABRQAAA==.',['�']='这不是斯巴达:AwACCAIABRQCEQAIAQjiKgAr8MYBBAoAEQAIAQjiKgAr8MYBBAoAAA==.迷人的风风:AwADCAEABRQAAA==.',['�']='逐风雨:AwAICAsABAoAAA==.通常睡过头:AwAFCAMABAoAAA==.',['�']='那个:AwACCAQABRQAAA==.邪斗士:AwACCAQABRQCHQAIAQi8JgA+4AYCBAoAHQAIAQi8JgA+4AYCBAoAAA==.邪神大熊:AwAECAQABRQAAA==.邹月人呢:AwACCAIABRQAAA==.',['�']='郁术屮临疯:AwAECAwABRQEHgAEAQg0AwBZsRUBBRQAHgADAQg0AwBTbRUBBRQAHwAEAQjXBwBEEAkBBRQACAABAQigFwAAAAAABRQAAQsAM3EGCAsABRQ=.',['�']='钟无炎:AwACCAMABRQAAA==.',['�']='长耳朵兔兔:AwABCAEABRQAAA==.',['�']='阴阴月色:AwABCAEABRQCAQAHAQijPgBCk+ABBAoAAQAHAQijPgBCk+ABBAoAAA==.阿瑞斯之灵:AwACCAIABRQAAA==.阿諨丶:AwAICAgABAoAAA==.',['�']='隐居豆腐店:AwAECAgABRQDIAAEAQjOAwBN9ewABRQAHQAEAQi3CABBkRcBBRQAIAAEAQjOAwBEFewABRQAARcAPKQGCAYABRQ=.',['�']='雅原:AwACCAIABAoAAA==.雪月蝶:AwAICAgABAoAAA==.',['�']='青小凝:AwACCAIABRQAAA==.非凡大师:AwAGCAYABAoAAA==.非想天则丨:AwAECAQABRQAAA==.非酋:AwACCAEABRQAAA==.',['�']='韩大雷童鞋:AwAECAQABRQAAA==.',['�']='顾咕咕丶:AwADCAMABRQDCgAIAQicIwBETRsCBAoACgAIAQicIwBETRsCBAoACQACAQinaQAgeF0ABAoAAA==.',['�']='风暴连接大脑:AwAGCAMABRQAAA==.飞奔的煎饼:AwACCAIABRQAAA==.',['�']='骑士洛洛:AwABCAEABRQAAA==.骑猪去巡山:AwAGCAYABAoAAA==.',['�']='鱼叔丷:AwAICBYABAoEFgAIAQjhMQAfdD4BBAoAFgAIAQjhMQAfdD4BBAoAGgABAQgdJgAFUwsABAoADAACAQhgkgAAPgEABAoAAA==.',['�']='鲸鱼不可循:AwAGCAEABRQAAA==.',['�']='麦芽雪冷萃:AwAICAoABAoAAA==.',['�']='黄蓉:AwACCAEABRQAAA==.黑糖啵啵:AwAICBAABAoAAA==.黑邦虎鲸:AwACCAIABRQAAA==.黛泽:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end