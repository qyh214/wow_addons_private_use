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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Retribution','Druid-Balance','Evoker-Devastation','DeathKnight-Blood','Priest-Holy','Priest-Discipline','Shaman-Restoration','Warlock-Destruction','Druid-Guardian','DemonHunter-Havoc','Shaman-Enhancement',}; local provider = {region='CN',realm='壁炉谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Aloy:AwACCAIABRQDAQAIAQhGAgBdSegCBAoAAQAIAQhGAgBdSegCBAoAAgAFAQj3SgBWU6cBBAoAAA==.',Co='Convincing:AwAECAQABRQAAA==.',Cr='Crystalclaw:AwAECAQABRQAAA==.',Do='Doomcryer:AwABCAEABRQAAA==.',Dy='Dylanotto:AwABCAEABRQAAQMAVHAECBIABRQ=.',Fe='Felinaemagic:AwAECAQABRQAAA==.',Ho='Hopebringer:AwADCAMABRQAAQQATf8FCBAABRQ=.',Il='Ilidans:AwABCAEABRQAAA==.',Na='Nabunaduo:AwAHCAIABAoAAA==.',Pl='Playerekqzta:AwAICAUABAoAAA==.',Si='Singularity:AwADCAYABRQCBQADAQj2AgBejkgBBRQABQADAQj2AgBejkgBBRQAAQQATf8FCBAABRQ=.',Vi='Virtue:AwAICAgABAoAAA==.',Yo='Younieer:AwAECAYABRQCBgAEAQjICgAvqcEABRQABgAEAQjICgAvqcEABRQAAA==.',['�']='一个大壁兜:AwAICAgABAoAAA==.一书术:AwACCAIABAoAAA==.七月在宇:AwABCAEABRQAAA==.万箭穿心:AwACCAIABAoAAA==.丨丶迈朦嘚儿:AwAGCAMABAoAAA==.丨月黑之时丨:AwAICAgABAoAAA==.',['�']='伊璞哒啦:AwAECAgABRQDAQAEAQg/CgAq8NUABRQAAQAEAQg/CgAq8NUABRQAAgACAQiRLgAauHcABRQAAA==.',['�']='八意永琳:AwAECA0ABRQDBwAEAQhbBQBESfYABRQABwAEAQhbBQBESfYABRQACAABAQiFHwAsTDwABRQAAA==.',['�']='凌度丶心寒:AwACCAUABRQCCQACAQiXHQAS+YAABRQACQACAQiXHQAS+YAABRQAAA==.',['�']='剥开插入:AwACCAEABAoAAA==.',['�']='华笙:AwAECAQABRQDAgAIAQgyLgBGMRoCBAoAAgAIAQgyLgBC1xoCBAoAAQAEAQieSwA2B6AABAoAAA==.',['�']='圣光之誓:AwAICAgABAoAAA==.地心之战:AwAGCAYABAoAAA==.',['�']='坊屋春道丶:AwAECAQABRQAAA==.',['�']='天堂烤鸭:AwACCAEABRQAAA==.',['�']='宝宝瀦:AwABCAEABRQAAA==.家属谢礼奶:AwABCAIABRQAAA==.家有一包:AwAICAgABAoAAA==.',['�']='小人物:AwAHCA0ABAoAAA==.小资风驰电掣:AwAHCAcABAoAAA==.小软害你呦:AwABCAIABRQAAA==.小鱼干:AwAFCAcABAoAAA==.尘之念一:AwADCAYABRQCBwADAQhfDABBm6wABRQABwADAQhfDABBm6wABRQAAA==.',['�']='布兜里有馒头:AwACCAMABRQDBwAIAQg3FABFtAwCBAoABwAIAQg3FABFtAwCBAoACAADAQisagATSV4ABAoAAA==.帅哥不乖:AwACCAIABRQAAA==.',['�']='幻想玄天:AwABCAIABRQAAA==.幻想玄黄:AwABCAEABAoAAA==.',['�']='康桑阿密达:AwAICAIABAoAAA==.',['�']='必须爆:AwABCAEABRQAAA==.必须爆的影子:AwAGCAYABAoAAA==.念宝睡不醒:AwAICAcABAoAAA==.',['�']='怒怒海马獭人:AwAGCA4ABAoAAA==.',['�']='打不过就跪:AwAHCAEABAoAAA==.',['�']='新巴唧:AwAECAgABRQCAgAEAQjREwAwDOoABRQAAgAEAQjREwAwDOoABRQAAA==.',['�']='旅行精灵:AwAECAQABRQAAA==.',['�']='星星河:AwAECAEABAoAAA==.是小狸花:AwAICAoABAoAAA==.',['�']='木子小小:AwADCAEABRQAAA==.',['�']='某人的圣光:AwAICAMABAoAAA==.',['�']='楚雨荨:AwAICAsABAoAAA==.',['�']='水蓝姬韵:AwACCAMABAoAAA==.',['�']='法力值已耗尽:AwAECAQABRQAAA==.泥鸽歧视:AwACCAIABAoAAA==.',['�']='流星乱坠:AwAECAEABAoAAA==.',['�']='潇洒乂戈:AwAECAQABAoAAA==.潋滟沧行:AwAECAQABRQAAA==.',['�']='瀟灑鄒蘙獩:AwAFCAUABAoAAA==.',['�']='牙医:AwAICAgABAoAAA==.',['�']='狂奔的蛋卷:AwACCAQABRQCCgAIAQjRGQBCwxUCBAoACgAIAQjRGQBCwxUCBAoAAA==.',['�']='琪琪大魔王:AwAECAQABRQAAA==.',['�']='眠河:AwAHCAEABAoAAA==.',['�']='矫情丶祥子:AwAICAYABAoAAA==.',['�']='神的力量阿:AwADCAMABAoAAA==.祭血之魂:AwAFCAkABAoAAA==.',['�']='秋丨秋:AwAECAMABRQAAA==.',['�']='第一美人:AwAICAIABAoAAA==.第五个火槍手:AwAICAgABAoAAA==.',['�']='糖豆儿:AwACCAEABRQAAA==.',['�']='红色火龙果:AwACCAIABAoAAA==.',['�']='耳朵萌萌德:AwABCAIABRQCCwAIAQi5CAAzmJ8BBAoACwAIAQi5CAAzmJ8BBAoAAA==.',['�']='艾辛诺斯战刃:AwADCAYABRQCDAADAQj4EwAhE9sABRQADAADAQj4EwAhE9sABRQAAA==.',['�']='花落执何手:AwAHCAYABRQCDQAGAQigAAA8YdkBBRQADQAGAQigAAA8YdkBBRQAAA==.花飞飞:AwAFCAMABAoAAA==.',['�']='苏格兰校办韦:AwAECAQABRQAAA==.苦痛与哀难:AwACCAIABAoAAA==.',['�']='萧瑟:AwADCAMABRQAAA==.萨满移动荣誉:AwAFCAQABAoAAA==.',['�']='跳起来打你哦:AwAECAQABRQAAA==.',['�']='遇雨欲语:AwACCAMABRQAAA==.',['�']='都给朕跪下:AwACCAIABRQAAA==.',['�']='里徳宾:AwAFCAYABAoAAA==.重生之就打德:AwAICAYABAoAAA==.',['�']='锤比乃大:AwAGCAYABAoAAA==.',['�']='飞霄:AwAECAQABRQAAA==.',['�']='魔贯光杀炮:AwACCAUABRQCDAACAQiBHgAqzI8ABRQADAACAQiBHgAqzI8ABRQAAA==.',['�']='鸕鷀:AwACCAIABAoAAA==.',['�']='黄花大牦牛:AwAECAQABRQAAA==.黑命贵:AwAECAQABRQAAA==.默默茶:AwAECAgABRQCAwAEAQgJBwBZLycBBRQAAwAEAQgJBwBZLycBBRQAAA==.黯炎瑟米欧斯:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end