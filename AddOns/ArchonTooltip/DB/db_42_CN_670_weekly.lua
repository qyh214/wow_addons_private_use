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
 local lookup = {'Evoker-Preservation','Evoker-Devastation','Druid-Balance','DeathKnight-Blood','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Arms','Monk-Mistweaver','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Priest-Discipline','Priest-Healing','Priest-Holy','Mage-Frost','Druid-Restoration','Unknown-Unknown','DeathKnight-Unholy','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Havoc','Warrior-Fury','Warrior-Protection','Monk-Windwalker','Shaman-Restoration','Evoker-Augmentation','Monk-Brewmaster',}; local provider = {region='CN',realm='希尔瓦娜斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aaccer:AwACCAIABAoAAA==.',Be='Bellucci:AwAICA4ABAoAAA==.',En='Envy:AwAFCAgABAoAAA==.',Ev='Evildragon:AwAECAUABRQDAQAEAQgAAQBTax4BBRQAAQAEAQgAAQBTax4BBRQAAgABAQgUGQAeHjgABRQAAA==.',Ho='Hodor:AwADCAsABRQCAwADAQjVEAAskuIABRQAAwADAQjVEAAskuIABRQAAA==.',Ni='Nickdk:AwACCAEABAoAAA==.',Pl='Playerymswob:AwACCAIABRQAAA==.',Ra='Rainyblue:AwAECAUABAoAAA==.Rapstar:AwABCAEABRQAAA==.',Se='Serpent:AwAECAIABRQCBAAIAQgkAgBeevQCBAoABAAIAQgkAgBeevQCBAoAAA==.',Tr='Tracy:AwABCAEABRQAAA==.',Ya='Yamathh:AwAHCBUABAoDBQAHAQjEKABEIV4BBAoABQAGAQjEKABGSF4BBAoABgABAQhJ3gA5YUQABAoAAA==.',['�']='一个猎手:AwAGCAwABAoAAA==.万泽:AwACCAQABAoAAQcAN/gGCAoABRQ=.三十六:AwACCAQABRQAAA==.三角初音:AwAECAQABRQAAA==.上古的低语:AwAECAQABRQAAA==.上树插狗:AwAECAIABRQAAA==.下水道恶霸:AwAECAQABRQAAA==.丘伊:AwAECAQABRQAAA==.丘栗:AwAECAQABRQAAA==.丘米芽多多:AwAECAQABAoAAA==.丶飘:AwAICAYABAoAAA==.',['�']='何妨吟啸徐行:AwAICEoABAoCCAAIAQh3AABjFRADBAoACAAIAQh3AABjFRADBAoAAA==.',['�']='依然乱劈柴:AwABCAEABRQAAA==.',['�']='倚树听风:AwAICAgABAoAAA==.',['�']='假面具:AwABCAEABRQAAA==.偶然威震天:AwABCAEABRQECQAIAQhrgQAoM2kBBAoACQAHAQhrgQAte2kBBAoACgAFAQheJQAty/oABAoACwABAQjQXgAIhQoABAoAAA==.偶然惊破天:AwABCAEABRQAAA==.',['�']='兄弟你好香:AwACCAMABRQAAA==.',['�']='凌晨三点的牛:AwAICAcABAoAAA==.凤鸣功:AwACCAIABAoAAA==.',['�']='匿名小晗:AwAICAcABAoAAA==.',['�']='千濑:AwAHCAYABAoAAQwAQV4GCAYABRQ=.半瑕:AwAECAQABRQAAA==.半颗半颗榴莲:AwAICAMABAoAAA==.半颗半颗橘子:AwAICAcABAoAAA==.卡芙卡芙卡:AwAFCAUABAoAAA==.卡辛:AwAICAgABAoAAQcAN/gGCAoABRQ=.',['�']='原来是牛马:AwAICAgABAoAAA==.',['�']='双生镜:AwAGCAIABRQCDQACAAgAAABFAQAABRQADgACAAgAAABFAQAABRQAAA==.可口岩真好吃:AwAICAEABAoAAA==.',['�']='吃饱了也不说:AwABCAEABRQAAA==.吕子云:AwACCAEABAoAAA==.吕子琪:AwABCAEABRQAAA==.君忘歌:AwAGCAYABAoAAA==.君泽辰:AwAHCAgABAoAAA==.',['�']='哈哈哥:AwACCAIABRQCDwAIAQizGwBDPgQCBAoADwAIAQizGwBDPgQCBAoAAA==.',['�']='啵老师:AwAICAgABAoAAA==.',['�']='喵仆甜心酱:AwAECAQABAoAAA==.喵哩喵气:AwAECAQABRQAAA==.',['�']='嗨丶小熊饼干:AwACCAQABRQDEAAIAQhhAABi2hEDBAoAEAAIAQhhAABi2hEDBAoAAwAFAQh5RQBP0moBBAoAAA==.',['�']='圣光鞭挞我:AwAECAYABRQDDAAEAQhEBABVOyQBBRQADAADAQhEBABVOyQBBRQADgABAQijIAAAAAAABRQAAA==.',['�']='坏蛋小妩媚:AwACCAIABRQAAA==.',['�']='墨染空城:AwAFCAQABRQAAA==.',['�']='夜丶血杀:AwABCAEABRQAAREAAAABCAEABRQ=.夜污蛋:AwABCAEABRQAAREAAAABCAEABRQ=.夜雨听风:AwAFCAUABAoAAA==.大力点丶:AwAECAQABRQAAA==.大担担:AwAECAQABRQAAA==.',['�']='奇迹喷火龙:AwAECAQABRQAAA==.奶不住丶:AwADCAMABRQAAA==.奶僧:AwABCAIABAoAAA==.好喝不过圣疗:AwAICAcABAoAAA==.',['�']='学妹留步:AwAECAQABRQAAREAAAAICAQABRQ=.',['�']='宇智波螳螂:AwAECAQABRQAAA==.安度因:AwAGCAgABAoAAA==.安眠巴德尔:AwAECAQABRQAAA==.审判之手:AwAECAQABRQAAA==.',['�']='寒曦:AwAECAMABAoAAA==.',['�']='小小的手心:AwAICAgABAoAAA==.小恶魔的萨满:AwAICAgABAoAAA==.小桃桃:AwAICAgABAoAAA==.小熊馋:AwACCAIABAoAAA==.尤格薩龍:AwAECAcABRQDBAAEAQi5BABSNBwBBRQABAAEAQi5BABSNBwBBRQAEgACAQhdGAA1wpIABRQAAA==.',['�']='局部地区有雪:AwAGCAQABRQAAA==.',['�']='巨锤:AwACCAEABRQCAQAIAQhUBgBBBRQCBAoAAQAIAQhUBgBBBRQCBAoAAA==.',['�']='强心剂丶:AwAGCAYABRQCEwAGAQi4AQAyf6UBBRQAEwAGAQi4AQAyf6UBBRQAAA==.',['�']='徐大锤儿:AwAECAQABRQAAA==.',['�']='恐怖血狼:AwAGCAYABAoAAA==.',['�']='悲伤的影子:AwABCAIABRQAAA==.',['�']='惹噜啾咪厚:AwAHCAcABAoAAA==.',['�']='慕容璇玑:AwABCAEABRQAAA==.',['�']='我化尘埃飞扬:AwAFCAoABAoAARQAQZMECAsABRQ=.',['�']='把你们豆沙咯:AwAECAQABRQAAA==.',['�']='持着弓日天灬:AwADCAMABRQAAQUAVdsICAgABRQ=.',['�']='无敌模式:AwADCAcABRQCCQADAQjJEQBFnvoABRQACQADAQjJEQBFnvoABRQAAA==.',['�']='春风吹酒醒:AwABCAEABAoAAA==.',['�']='時曦三璨乄:AwACCAcABRQDFAACAQgQHwAcjmUABRQAFAACAQgQHwAQmGUABRQAFQABAQhbGAAg3kcABRQAAA==.',['�']='最終风靡全球:AwABCAEABRQAAA==.月光影子:AwAICAcABAoAAA==.月影之殇:AwABCAEABRQAAA==.有点点丶:AwAECAgABRQCFAAEAQiXBQBUJxcBBRQAFAAEAQiXBQBUJxcBBRQAAA==.术爷讲武德:AwAGCAUABAoAAA==.朴实无华:AwAECAQABRQAAA==.',['�']='板栗鸡腿:AwAECAQABRQAAA==.',['�']='桔子汽水:AwACCAIABRQAAA==.',['�']='橘子树:AwAECAIABAoAAA==.',['�']='死大个子:AwAGCAYABRQDFgAEAQgNBgBGKvcABRQAFgAEAQgNBgA7yPcABRQAFwACAQiUCQBQBbsABRQAAA==.死大个子哟:AwAGCB8ABAoCGAAGAQjgPQBDw4kBBAoAGAAGAQjgPQBDw4kBBAoAAA==.',['�']='水龍:AwADCAMABAoAAA==.',['�']='沁逸:AwAECAQABRQAAA==.沐熊様:AwAICAsABAoAARcAOhQGCAYABRQ=.',['�']='清初雨落:AwAECAQABRQAAA==.温顺的牛肉人:AwABCAEABAoAAA==.',['�']='溟渊:AwABCAEABRQAAA==.',['�']='烟雨任平生:AwADCAMABAoAAA==.',['�']='爆炒丸子丶:AwACCAEABAoAAA==.',['�']='独自去兜风:AwABCAEABRQAAA==.',['�']='瓦塔西:AwAECAYABRQCBgAEAQgcCgBKbRYBBRQABgAEAQgcCgBKbRYBBRQAAA==.',['�']='甜食达人:AwAECAQABRQAAA==.电面具:AwABCAEABRQAAA==.',['�']='白薪焰火:AwAICAYABAoAAA==.',['�']='盘尼西林:AwAECAgABRQCGQAEAQinAwBc+DoBBRQAGQAEAQinAwBc+DoBBRQAAA==.',['�']='礼礼:AwAICAgABAoAAA==.',['�']='秋歌夜带刀:AwADCAEABAoAAA==.移动辣子鸡:AwAGCAYABAoAAREAAAAECAQABRQ=.',['�']='第十区拉温妮:AwADCAMABRQAAA==.',['�']='絮怀殇:AwAGCAYABAoAAA==.',['�']='红莲八极式:AwACCAEABRQAAA==.纯白给:AwACCAMABRQAAA==.',['�']='缺德请找我:AwAICAcABAoAAA==.',['�']='罪与爱同歌:AwAGCAkABRQDDAAGAQhUAwAu9DUBBRQADAAFAQhUAwAqsDUBBRQAEwACAQhuGwA4x04ABRQAAA==.',['�']='耗子尾支:AwAICAgABAoAAA==.',['�']='肘击之王:AwADCAcABRQEGgAIAQiDAQBeB+ICBAoAGgAIAQiDAQBc/+ICBAoABwAHAQiCCQBMwGUCBAoAGQAGAQjlNwBOX3IBBAoAAA==.',['�']='舞则天:AwAICAMABAoAAA==.',['�']='苏玛拉:AwAFCAUABAoAAA==.',['�']='茅台酒中仙:AwABCAEABRQAAA==.',['�']='莫听穿林打叶:AwACCAIABAoAAA==.莱阁拉斯:AwACCAMABRQAAA==.',['�']='菲奥雷托:AwAICBEABAoAAA==.',['�']='萌咔哇卡:AwAGCAEABAoAAA==.萌萌龘婋牝锅:AwAGCAYABAoAAA==.萨哥拉丝:AwAECAQABRQAAA==.',['�']='虚无鲩:AwADCAIABAoAAA==.',['�']='蜡笔小柚:AwAECAQABRQAAA==.',['�']='西斯督:AwAECAQABRQAAA==.',['�']='读书破万卷:AwABCAEABAoAAA==.',['�']='谭竹:AwAECAIABAoAAA==.',['�']='贫道信耶酥:AwAICAgABAoAAA==.',['�']='轩痕:AwADCAMABAoAAA==.',['�']='追风也追你:AwACCAEABRQDCAAIAQgtKAAuyZsBBAoACAAIAQgtKAAuyZsBBAoAGwABAQilagAQlDAABAoAAA==.',['�']='都神马:AwAICAYABAoAAA==.',['�']='酷酷冠希:AwAGCBQABRQCHAAGAQgyAABKN80BBRQAHAAGAQgyAABKN80BBRQAAA==.酷酷王的男人:AwADCAYABRQCDwADAQifAQBXEisBBRQADwADAQifAQBXEisBBRQAARwASjcGCBQABRQ=.酷酷百事可乐:AwACCAQABRQDAQAIAQjPAgBPYocCBAoAAQAIAQjPAgBPYocCBAoAHQABAQgABgBUfFwABAoAARwASjcGCBQABRQ=.',['�']='钢蛋丶:AwAICBgABAoCGAAIAQjaIQBCzxkCBAoAGAAIAQjaIQBCzxkCBAoAAA==.',['�']='锦绫:AwADCAMABRQAAA==.',['�']='阿杜纳:AwAECAQABRQAAA==.阿梓喵:AwAICAcABAoAAA==.阿莉森海塔尔:AwAHCAEABAoAAA==.阿黄炫阔落:AwAECAEABAoAAA==.',['�']='零八:AwAICAkABAoAAA==.零度凛冬:AwACCAIABRQAAA==.',['�']='霜语之歌:AwAFCAsABAoAAA==.霸气矮矬穷:AwAECAQABRQAAA==.',['�']='靓靓車厘子:AwAICBAABAoAAA==.面具真:AwABCAEABRQAAA==.',['�']='颜值界扛把子:AwAICAgABAoAAR4AU0EECAQABRQ=.',['�']='风清月明灬:AwAICAcABAoAAA==.风焰丶:AwAICAgABAoAAA==.',['�']='香辣麦旋风丶:AwAGCBQABAoCCAAGAQg3SAAlAvgABAoACAAGAQg3SAAlAvgABAoAAA==.',['�']='骨犟:AwAICAcABAoAAA==.',['�']='鱼璇玑:AwAICAgABAoAAA==.',['�']='鲜嫩滑鸡周丶:AwAHCBAABAoAAA==.',['�']='黑猫警长:AwAHCAcABAoAAA==.',['�']='龍戰丨騎士:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end