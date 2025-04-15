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
 local lookup = {'Paladin-Retribution','DeathKnight-Frost','Unknown-Unknown','Mage-Fire','Warrior-Fury','Warrior-Protection','Warrior-Arms','DemonHunter-Havoc','Druid-Feral','DemonHunter-Vengeance','Paladin-Holy','Monk-Brewmaster','Druid-Balance','Mage-Frost','Druid-Guardian','Druid-Restoration','Priest-Shadow','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Protection','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Subtlety','Shaman-Elemental','Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Shaman-Enhancement','Rogue-Outlaw',}; local provider = {region='CN',realm='耐奥祖',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bl='Blackpearl:AwABCAEABAoAAA==.',Cl='Cloudcai:AwAGCAYABAoAAA==.',Di='Directordk:AwAGCAYABAoAAA==.Directorqs:AwACCAQABRQCAQAGAQi0YQBUbL0BBAoAAQAGAQi0YQBUbL0BBAoAAA==.',Ga='Gallagher:AwACCAIABRQAAA==.',Ha='Haohaa:AwAECAQABRQAAA==.',Hd='Hdeyz:AwABCAEABRQCAgAIAQhLAwBZe60CBAoAAgAIAQhLAwBZe60CBAoAAA==.',Ia='Iamchosen:AwACCAIABRQAAQMAAAAGCAQABRQ=.',Na='Nandi:AwAECAQABRQAAQQALZoICAUABRQ=.',Ni='Nicebody:AwACCAIABRQAAA==.',Sa='Sapagaagonie:AwADCAoABRQEBQADAQgXEAAdiOkABRQABQADAQgXEAAdiOkABRQABgACAQhfCQAHJVQABRQABwABAQhEFwAQUTwABRQAAA==.',Sc='Scarlett:AwAICCMABAoCCAAIAQjrEgBTBYYCBAoACAAIAQjrEgBTBYYCBAoAAQkATuEECAQABRQ=.',Si='Sisyphus:AwABCAEABAoAAA==.',Sy='Sylvan:AwAICBwABAoDCAAIAQiuOwA1cp8BBAoACAAIAQiuOwAsJZ8BBAoACgAHAQg0JAAt4DIBBAoAAQoAQtIICCMABAo=.',To='Topfive:AwAHCAcABAoAAA==.',Va='Vanéssa:AwAICCMABAoDCgAIAQjpDgBC0hECBAoACgAIAQjpDgBC0hECBAoACAADAQi/iAARBooABAoAAA==.',Ve='Verysam:AwAECAcABAoAAA==.',Vi='Viczmick:AwACCAIABRQAAA==.',['�']='一夜知秋:AwAECAQABRQAAA==.一路天黑:AwABCAEABAoAAA==.丶再见孙悟空:AwABCAEABAoAAA==.丿灬浊酒壹壶:AwAECAQABRQAAA==.',['�']='云朵:AwAECAQABRQCCwAEAQioBgApitgABRQACwAEAQioBgApitgABRQAAA==.',['�']='仙剑李逍遥:AwAICAkABAoAAA==.',['�']='伊娃丶翠瞳:AwAFCAUABAoAAA==.',['�']='何似在人间:AwAECAEABAoAAA==.你看我硬不:AwAECAQABAoAAA==.',['�']='偷腻苦茶子:AwAICAkABAoAAA==.',['�']='冷露无声:AwAECAIABRQAAQwAKp8ICAUABRQ=.',['�']='凌虚:AwAHCAwABAoAAA==.',['�']='划水不用浆:AwAHCAcABAoAAA==.初初大魔王:AwAFCAUABAoAAA==.删灬除:AwAECAcABRQCBAAEAQjDFAA+qu0ABRQABAAEAQjDFAA+qu0ABRQAAA==.',['�']='削定恶养柯基:AwAGCAYABAoAAA==.',['�']='功夫猫咪:AwAICBAABAoAAA==.助祭:AwAICAgABAoAAA==.',['�']='北尔瓦娜斯:AwAECAQABRQAAA==.',['�']='千年昏:AwAECAQABRQAAA==.午夜幽光:AwAICA4ABAoAAQ0AQiQGCAoABRQ=.',['�']='叉烧啾啾:AwABCAEABRQCDgAIAQjhDQBTkHsCBAoADgAIAQjhDQBTkHsCBAoAAA==.叉烧行星:AwABCAEABRQAAA==.叉烧黑猫:AwAICAgABAoAAA==.发疯式丶包包:AwAFCAcABAoAAA==.口少口少:AwACCAUABRQDDwAIAQhKDAArJVwBBAoADwAIAQhKDAArJVwBBAoAEAACAQgsfwAELioABAoAAA==.',['�']='含沙猎影:AwAECAQABAoAAA==.',['�']='咖啡丶玫瑰:AwACCAIABRQDEQAHAQiDHgA+isYBBAoAEQAHAQiDHgA+isYBBAoAEgADAQgRZgApS3EABAoAAA==.',['�']='哞喵:AwACCAQABRQAAA==.',['�']='啊蕉老师:AwAGCAgABRQDEwAEAQgfBwBJlhIBBRQAEwAEAQgfBwBJlhIBBRQAFAAEAQjPGQADDFoABRQAAA==.',['�']='喵星渔:AwAGCBIABAoAAA==.',['�']='圣光丨一凡:AwADCAwABRQCAQADAQiaEQBGdAEBBRQAAQADAQiaEQBGdAEBBRQAAA==.圣骑与菊魔:AwABCAIABRQDAQAIAQgTJwBOnWwCBAoAAQAHAQgTJwBZnGwCBAoAFQABAQg/XwAMoxEABAoAAA==.',['�']='夏曰牧歌丶:AwAGCAYABAoAAA==.外太空滴星星:AwAICAgABAoAAA==.大地之环:AwAFCAUABAoAAA==.',['�']='奅烦奘指头:AwABCAEABAoAAA==.奶潮链接全开:AwACCAIABRQAAA==.',['�']='嫩哆哆:AwAICAgABAoAAA==.',['�']='定逸师太:AwAECAgABRQDFgAEAQh7CQAoxdgABRQAFgAEAQh7CQAoxdgABRQAEgAEAQgOEAAU970ABRQAAA==.',['�']='富婆快乐人:AwAICAEABAoAAA==.',['�']='小小丶劣人:AwAECAQABRQCFwADAQjFKgAvMY8ABRQAFwADAQjFKgAvMY8ABRQAAA==.小花宝:AwAECAQABRQAAQQASG4ICAoABRQ=.小萌主:AwAICAgABAoAARAAOkwGCAUABRQ=.小落大叶:AwAGCAEABRQCAQABAQigOgBWgGEABRQAAQABAQigOgBWgGEABRQAAA==.小诸葛佩奇:AwACCAIABRQAAA==.',['�']='巴巴托斯:AwAECAgABRQDBwAEAQg6AwBMEBYBBRQABwAEAQg6AwBKMxYBBRQABQACAQjPHwA2SFoABRQAAQMAAAAGCAEABRQ=.',['�']='帅的后知后觉:AwAECAQABRQAAA==.',['�']='幻胖:AwAGCAoABAoAAA==.幽蓝紫月:AwACCAIABRQDFwAGAQjySABTvboBBAoAFwAGAQjySABTvboBBAoAGAABAQjfewAZLB8ABAoAAA==.幽音绝花:AwAICA0ABAoAAA==.',['�']='弓虽口阿弓虽:AwAFCAYABAoAAA==.张二牛:AwACCAIABRQAAQkATuEECAQABRQ=.张天爱:AwAICAgABAoAAA==.张无忌:AwAECAQABRQAAA==.',['�']='德才兼备灬:AwADCAoABRQCEAADAQj3AgBZkzYBBRQAEAADAQj3AgBZkzYBBRQAAA==.',['�']='恶龙咆哮丶丶:AwAGCAUABAoAAA==.',['�']='想喝冰阔落:AwAGCAsABAoAAA==.',['�']='慕雨丶夜:AwACCAQABRQAAA==.',['�']='战无霜:AwAHCBQABAoCBgAHAQgvIAAQttYABAoABgAHAQgvIAAQttYABAoAAA==.',['�']='扬尼斯:AwACCAMABRQCBQAIAQjFKgAnLMcBBAoABQAIAQjFKgAnLMcBBAoAAA==.',['�']='指尖伴流沙丶:AwAICAgABAoAAA==.',['�']='排骨:AwAICAgABAoAAA==.',['�']='撒满鸡虱:AwABCAEABRQAAA==.',['�']='放弃昨天:AwABCAEABRQAAA==.',['�']='无尽的星空:AwAFCAUABAoAAA==.无敌琪琪:AwAICAgABAoAAA==.时星星:AwAGCAcABAoAAA==.',['�']='星枢呈瑞:AwACCAIABRQCGQAGAQhuHQAn/ysBBAoAGQAGAQhuHQAn/ysBBAoAAA==.星辰坠入深海:AwACCAQABRQCFAAGAQjsFABW5tkBBAoAFAAGAQjsFABW5tkBBAoAAA==.',['�']='暮光隐:AwAECAQABAoAAA==.暮雨而桐:AwACCAIABRQAAA==.暴走的小柒:AwAGCAEABRQDAQAIAQg4rQAo5BkBBAoAAQAGAQg4rQArYhkBBAoAFQADAQilPwAaeXIABAoAAA==.',['�']='月光莫里亚:AwAFCAUABAoAAA==.',['�']='果汁糖:AwAICBAABAoAAQMAAAACCAMABRQ=.',['�']='森林格格污丶:AwACCAIABAoAAA==.',['�']='檸尛檬灬:AwAICAUABAoAAA==.',['�']='欧皇小奶牛:AwAGCAIABAoAAA==.',['�']='武浅静:AwAICAgABAoAAA==.',['�']='殺法果断:AwACCAQABRQDDgAHAQhKOgA8WV4BBAoABAAHAQgZOAAyD6cBBAoADgAGAQhKOgBDc14BBAoAAA==.殿堂级追梦人:AwACCAIABAoAAA==.',['�']='每天做丝帕:AwAECAgABRQDFgAEAQggBwBHTuoABRQAFgAEAQggBwA1QuoABRQAEgAEAQj3CgA3seYABRQAAA==.',['�']='民以食为天:AwAECAQABRQAAA==.',['�']='沉默星河:AwAHCBUABAoDGgAHAQhtKAA7xpABBAoAGgAHAQhtKAA7xpABBAoAGwAGAQjOeAAMOK8ABAoAAQQAJ70GCAoABRQ=.',['�']='深夜:AwAECA4ABRQDDQAEAQgzBgBXlyUBBRQADQAEAQgzBgBXlyUBBRQAEAAEAQgODAAXqLQABRQAAQ0ARVEHCAcABRQ=.深夜召唤人:AwAGCAgABRQEHAAFAQjmAQBPKS0BBRQAHAAEAQjmAQBUWC0BBRQAHQADAQinEQArksoABRQAHgABAQg8CwA/mV4ABRQAAQ0ARVEHCAcABRQ=.深夜料理人:AwAFCAIABAoAAQ0ARVEHCAcABRQ=.深夜赶尸人:AwAICBAABAoAAQ0ARVEHCAcABRQ=.',['�']='湾仔之火车神:AwAFCAYABAoAAA==.',['�']='漠雨晚歌:AwAICAgABAoAAA==.',['�']='炮灰四系飞舞:AwACCAMABRQDDQAHAQgtSgA6SmQBBAoADQAGAQgtSgA/MmQBBAoADwADAQj8IQAmTV4ABAoAAA==.',['�']='烟花易冷丶:AwACCAIABAoAAA==.',['�']='爱喝冰阔落:AwABCAEABRQAAA==.爱斯普莱索:AwACCAIABRQAAA==.',['�']='牛奶糖:AwACCAMABRQAAA==.牛妞立大功:AwAGCAwABAoAAA==.',['�']='狼儿:AwAHCAYABAoAAA==.',['�']='王曲奇:AwAECAQABRQAAA==.玛卡巴卡:AwAECAQABRQAAA==.玥玥大月饼:AwAECAgABRQCGAAEAQjIBABNHAoBBRQAGAAEAQjIBABNHAoBBRQAAA==.',['�']='皓燃:AwAECAIABRQAAA==.',['�']='砍了那只鸭:AwAECAQABRQAAA==.',['�']='神靈乄德铖:AwAGCAYABRQCDQAGAQiVAQAvPp0BBRQADQAGAQiVAQAvPp0BBRQAAA==.',['�']='秀色可参:AwACCAIABRQAAA==.',['�']='窒息:AwAECAQABRQAAA==.',['�']='素质三连:AwACCAIABRQAAA==.',['�']='红裤衩炮弹:AwAICAgABAoAAA==.纹身噶:AwABCAEABRQAAA==.',['�']='给我回来:AwADCAUABAoAAA==.',['�']='罗克西阿斯:AwAGCAUABRQCFwAFAQjkBQAjKUIBBRQAFwAFAQjkBQAjKUIBBRQAAA==.',['�']='羞羞的小宋:AwADCAMABAoAAA==.',['�']='舔狗饲养员:AwAECAQABRQAAA==.',['�']='芳心纵火犯:AwAFCAEABAoAAA==.',['�']='苍清雪:AwAECAQABRQAAA==.',['�']='萌蛮:AwAGCAYABAoAAA==.',['�']='虞书欣:AwABCAEABRQAAA==.',['�']='蛋黄酥:AwACCAIABRQAAQMAAAACCAMABRQ=.',['�']='调理农务系:AwAECAQABRQAAA==.',['�']='起舞弄清影:AwADCAIABAoAAA==.',['�']='辜戦:AwADCAMABAoAAA==.',['�']='那小子真险:AwAGCAYABAoAAA==.',['�']='铁蛋游击队:AwAECAQABAoAAA==.',['�']='长虹剑主虹猫:AwAECAQABRQAAR8AOigGCAoABRQ=.',['�']='闪电五连鞭:AwAECA4ABRQDIAAEAQh7CAAyDPgABRQAIAADAQh7CAAyDPgABRQAGgABAQhKGwAAAAAABRQAAA==.',['�']='陈疯豹烈酒:AwAICA4ABAoAAA==.',['�']='随风如雨:AwAECAQABRQAAA==.',['�']='雅柏菲卡:AwAECAcABAoAAA==.',['�']='青丝无名:AwEICAMABAoAAA==.',['�']='风景依然:AwACCAIABRQAAA==.',['�']='骑母猪看夕阳:AwABCAEABRQAAA==.',['�']='鱼塘空荡荡:AwADCAQABRQDGQAIAQiTCQBJ3E8CBAoAGQAIAQiTCQBH908CBAoAIQABAQgtFgA93UkABAoAAA==.鱼塘鱼多多:AwACCAIABRQAAA==.',['�']='鲁西飞:AwAGCAYABAoAAA==.',['�']='麦麦脆汁鸡:AwABCAEABRQAAA==.',['�']='黑色法棍:AwAFCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end