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
 local lookup = {'Priest-Discipline','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Paladin-Retribution','Druid-Balance','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Shaman-Elemental','Warlock-Demonology','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Paladin-Protection','Priest-Holy','Shaman-Restoration','Warrior-Protection','Warrior-Fury',}; local provider = {region='CN',realm='屠魔山谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ch='Characow:AwAECAQABRQAAA==.',Da='Darkside:AwAECAsABRQDAQAEAQg/EwA0b5EABRQAAQADAQg/EwA345EABRQAAgABAQgCGgA7x1QABRQAAA==.',Ho='Horo:AwADCAgABRQDAwADAQiPEwBK2q0ABRQAAwACAQiPEwBKDK0ABRQABAACAQh/DQA7oZ0ABRQAAA==.',Hy='Hypgr:AwABCAEABRQAAA==.',Qn='Qnima:AwAGCAsABAoAAA==.',Si='Simulacra:AwAGCAsABRQCBQAGAQg/AQA5uaUBBRQABQAGAQg/AQA5uaUBBRQAAA==.',Ty='Tyleness:AwAHCAsABAoAAA==.',Vv='Vvmyli:AwAGCAYABAoAAA==.',['�']='一介匹夫:AwAECAYABRQCBgAEAQjODgAy0esABRQABgAEAQjODgAy0esABRQAAA==.一只死亡猎:AwAECAIABAoAAA==.一只生存骑士:AwABCAEABRQAAA==.一溜字母:AwAICBAABAoAAA==.三年级校霸:AwADCAMABRQAAA==.丨怪咖丨:AwAECAQABRQAAA==.丨癫灬狂丨:AwABCAEABRQAAA==.丶玥梦希:AwAGCAYABAoAAA==.',['�']='今朝易在梦里:AwAECAMABRQAAA==.',['�']='伊咕哔咕:AwAICAoABAoAAA==.伊洛曼希斯:AwAECAoABRQDBwAEAQiOBwBGOwcBBRQABwAEAQiOBwBGOwcBBRQACAACAQg8EwA6gn8ABRQAAA==.',['�']='信用债:AwAECAQABRQAAA==.',['�']='冰块好吃:AwAICAgABAoAAA==.',['�']='午夜:AwACCAIABAoAAA==.',['�']='古德莱克:AwAICAoABAoAAA==.可心可心:AwAGCAYABAoAAA==.叶的记忆:AwAECAcABAoAAA==.',['�']='吃不下了:AwACCAIABRQAAA==.吃宝心情好:AwADCAMABAoAAA==.合原圣骑:AwABCAIABRQAAA==.吐舌头:AwAHCBIABAoAAA==.',['�']='哞利斯塔:AwACCAIABAoAAA==.',['�']='唐门衮衮:AwABCAEABRQAAA==.',['�']='土丶灵:AwABCAEABAoAAA==.圣光永远超神:AwABCAIABRQAAA==.圣白莲:AwAGCAsABAoAAA==.',['�']='夢珂丶珂:AwACCAQABRQAAA==.大哥曾:AwAICBIABAoAAA==.',['�']='奔雷剑主大奔:AwAECAMABRQAAQkAAAAGCAIABRQ=.她永远第一:AwAICAgABAoAAA==.',['�']='宝宝的小花花:AwAICA0ABAoAAA==.',['�']='射手座:AwAICAoABAoAAA==.小咔啦米:AwAECAQABRQAAA==.小多米:AwAICAUABAoAAA==.小洗只狼:AwAICBIABAoAAA==.小霞:AwAGCAYABAoAAA==.',['�']='帅气十足风:AwAFCA0ABAoAAA==.',['�']='心灭遗言:AwACCAMABRQAAQkAAAADCAQABRQ=.念无应:AwACCAMABAoAAA==.',['�']='悦悦:AwAHCAsABAoAAA==.',['�']='我先来:AwAICAgABAoAAA==.我就嗖一下:AwAECAQABRQAAA==.我提丶一杯:AwAECAQABRQAAA==.',['�']='放開那個女孩:AwACCAUABRQCCgACAQidDQApYZMABRQACgACAQidDQApYZMABRQAAA==.',['�']='旋涡异族:AwAGCAkABAoAAA==.旋风剑主达达:AwACCAIABRQAAA==.',['�']='星野琉璃:AwAECAQABRQAAA==.昼丶酒:AwAECAQABRQAAA==.',['�']='晋南李敏镐:AwAFCAUABAoAAA==.',['�']='暖羊羊:AwAECAQABRQAAA==.暴力双鱼:AwAGCAcABAoAAA==.',['�']='朽木白哉:AwAICAgABAoAAA==.',['�']='李火旺:AwAGCAYABRQDBAAGAQg3AQAfNjoBBRQABAAFAQg3AQAkkToBBRQACwABAQhKDQAJy1EABRQAAA==.',['�']='柒璨:AwAECAQABRQAAA==.',['�']='梵小凡:AwAICAcABAoAAA==.',['�']='橹西:AwABCAEABRQDDAAIAQj1BQBQEG4CBAoADAAIAQj1BQBQEG4CBAoABQAFAQj0uQBEWPYABAoAAA==.',['�']='污药王:AwAGCAYABAoAAA==.',['�']='深情终被辜负:AwAICA4ABAoAAA==.',['�']='灬欧布:AwAECAQABRQAAA==.灬血枭坠影灬:AwADCAMABRQAAA==.',['�']='熊喵舞:AwADCAMABAoAAA==.',['�']='狂飙龙:AwAECAQABRQAAA==.',['�']='猪是谁念倒谁:AwACCAIABRQAAQkAAAAICAQABRQ=.',['�']='玛哈嘎拉:AwAGCAQABRQAAA==.玥栋:AwAGCAYABAoAAA==.',['�']='疾风怒涛之计:AwAGCAgABRQDDQAGAQiiAQAl85MBBRQADQAGAQiiAQAl85MBBRQADgACAQgPAwBbBc0ABRQAAA==.',['�']='皓宝:AwAICAYABAoAAA==.',['�']='神棍儿:AwACCAIABAoAAA==.',['�']='秋舞灬風:AwACCAIABRQEDwAIAQieNQBDjfgBBAoADwAIAQieNQBAVPgBBAoAEAAGAQjeLgAySTUBBAoAEQACAQh2EwBKjYkABAoAAA==.',['�']='糖醋面筋:AwAFCAUABAoAAA==.',['�']='紫夜之心:AwAICAkABAoAAA==.',['�']='网管李大爷:AwACCAYABRQCBgACAQhHHQAiFpAABRQABgACAQhHHQAiFpAABRQAAA==.',['�']='羽咲:AwAHCAMABRQAAA==.',['�']='肉肉大:AwAGCA0ABAoAAA==.',['�']='舞雾我:AwAECAQABRQAAA==.',['�']='莎布尼古拉斯:AwAICAYABAoAAA==.',['�']='萨瓦熊熊:AwAECAQABRQAAA==.',['�']='蔷薇猎手:AwAECAQABRQAAA==.',['�']='虎皮鹦鹉:AwAICAgABAoAAA==.',['�']='蛋丨哥:AwAECAgABAoAAA==.蛋蛋丶僧:AwAECAIABRQAAA==.蛋蛋灬忧桑:AwAFCAwABRQCEgAFAQg1BgAZUs4ABRQAEgAFAQg1BgAZUs4ABRQAAA==.',['�']='蟑螂恶霸:AwAECAQABRQAAA==.',['�']='被腐蚀的圣光:AwAFCAUABAoAAA==.',['�']='西属撒哈拉:AwAFCAEABAoAAA==.',['�']='记忆中小小:AwAICBMABAoAAA==.记忆中的想念:AwAFCAUABAoAAA==.',['�']='贰玥丶:AwAECAcABRQCDAAEAQjKAwA9ePkABRQADAAEAQjKAwA9ePkABRQAAQYAVtkGCAcABRQ=.贱小贱:AwAGCAYABAoAAA==.',['�']='赤红天使:AwAGCAUABAoAAA==.',['�']='迪萨斯:AwACCAIABAoAAA==.迪迪小微:AwADCAQABAoAAA==.',['�']='遗忘丶痛苦:AwAECAQABRQAAA==.',['�']='酸萝卜别吃:AwAGCAYABAoAAA==.',['�']='银魂:AwAICA0ABAoAAA==.',['�']='阳光丨晨歌:AwACCAIABRQAAA==.阿牧:AwABCAIABRQEAQAHAQhyPgAYUvAABAoAAQAHAQhyPgAYUvAABAoAEwAFAQiQWwASSKEABAoAAgABAQjfcAAEPBcABAoAAA==.',['�']='霓裳舞:AwABCAIABAoAAA==.',['�']='青丘丶白凤九:AwAFCAQABRQAAQkAAAAGCAQABRQ=.非法咔咔:AwABCAEABAoAAA==.非要画个妆:AwAHCAgABAoAAA==.面包制造者:AwADCAQABAoAAA==.',['�']='風凌雪:AwAICAgABAoAAA==.',['�']='风一程:AwAICAgABAoAAA==.风骚的三胖子:AwAECAQABRQAAA==.飒蠻:AwAFCAIABAoAARQANVQGCAoABRQ=.飛鳥華:AwAGCAkABAoAAA==.',['�']='饭饭:AwAFCAcABRQDFQAFAQgBAgAxYvsABRQAFQAFAQgBAgAatPsABRQAFgACAQjHFQBH2aUABRQAAQ8ASuEGCAgABRQ=.',['�']='香蕉牛奶牛:AwACCAMABAoAAA==.',['�']='魔戈莱妮:AwAICAIABAoAAQkAAAAECAQABRQ=.',['�']='麻兄弟包谷:AwACCAMABRQAAA==.',['�']='黛影:AwAECAQABRQAAA==.',['�']='龙五五:AwAGCAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end