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
 local lookup = {'Unknown-Unknown','Evoker-Preservation','Druid-Feral','Priest-Discipline','Evoker-Ranged','Druid-Balance','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Fire','Mage-Frost','DemonHunter-Havoc','Monk-Mistweaver','Warrior-Protection','Warrior-Fury','Paladin-Retribution','Paladin-Holy','Druid-Restoration','DeathKnight-Blood','Shaman-Elemental','Shaman-Restoration','Paladin-Protection','Warrior-Arms','DemonHunter-Vengeance',}; local provider = {region='CN',realm='深渊之巢',name='CN',type='weekly',zone=42,date='2025-04-14',data={Af='Affliciliana:AwAGCAYABAoAAQEAAAAGCAkABAo=.',De='Device:AwACCAIABRQAAA==.',Di='Discrete:AwAECA8ABRQCAgAEAQhkAABhMVEBBRQAAgAEAQhkAABhMVEBBRQAAA==.Divination:AwAGCAYABAoAAA==.',Du='Duezhenjun:AwAHCA4ABAoAAA==.',Gh='Ghostornado:AwACCAEABAoAAA==.',Ha='Hansonl:AwADCAkABRQCAwADAQhcAQBO1BYBBRQAAwADAQhcAQBO1BYBBRQAAA==.',He='Hernameplz:AwAFCAUABAoAAA==.',Ho='Hollor:AwACCAIABAoAAA==.',Kr='Krone:AwAECAQABAoAAQEAAAAHCA0ABAo=.',Mi='Mieesion:AwAFCAUABAoAAA==.Minotaurzhao:AwACCAIABRQAAA==.',Re='Redemptor:AwAICAgABAoAAA==.Relieved:AwAFCAkABRQCBAAFAQgZAQBaKKcBBRQABAAFAQgZAQBaKKcBBRQAAA==.',Ri='Ritalr:AwAGCAEABAoAAQUARfcHCAcABRQ=.',So='Sora:AwABCAIABRQAAA==.Souglyboy:AwACCAIABRQAAA==.',Yy='Yyf:AwAECAgABRQCBgAEAQijEwAcE9EABRQABgAEAQijEwAcE9EABRQAAA==.',['Á']='Áfairy:AwAGCAYABAoAAA==.',['�']='一五一十:AwAGCAcABAoAAA==.一点灵犀:AwAICAgABAoAAA==.一颗石头:AwAICAgABAoAAA==.三小鱼:AwAGCAYABAoAAA==.三百清溪:AwAECAQABRQAAA==.不破鹤:AwACCAMABRQAAA==.专栋图腾:AwAECAQABRQAAA==.两两儀儀式式:AwAECAQABRQAAQcAL00GCAoABRQ=.中年少女情怀:AwAFCAYABAoAAA==.中庸之道:AwAGCAYABAoAAA==.丶刘亦菲:AwAICBAABAoAAQEAAAAICAEABRQ=.丶萧瑟丶:AwABCAEABAoAAA==.丶雷诺:AwAFCAEABAoAAA==.',['�']='五十分先生:AwAGCAkABAoAAA==.井川里予:AwAGCAYABAoAAQEAAAAICAIABRQ=.',['�']='以人为镜:AwAECAcABRQCCAAEAQhzAwBZ6xIBBRQACAAEAQhzAwBZ6xIBBRQAAA==.',['�']='伊利丶泽:AwAFCAkABAoAAA==.',['�']='你是个憨憨:AwAGCAYABAoAAA==.你缺德嘛:AwAFCAUABAoAAA==.',['�']='修閑:AwAGCAoABAoAAA==.',['�']='倾冥绝恋:AwADCAMABAoAAA==.',['�']='傲丨然穿越:AwAGCAYABAoAAA==.',['�']='克劳多:AwADCAoABRQCBwADAQhdBQBLEhsBBRQABwADAQhdBQBLEhsBBRQAAA==.克己守心:AwABCAEABRQAAA==.兰斯罗特:AwACCAQABRQAAA==.',['�']='冲锋盾墙破釜:AwADCAMABAoAAA==.',['�']='凉城听暖:AwAGCAYABAoAAA==.几儿乱甩:AwADCAMABAoAAA==.',['�']='刀锋如浪:AwACCAUABRQDCAACAQhhDgBX5qkABRQACAACAQhhDgBX5qkABRQACQABAQhJPQAbXD4ABRQAAA==.刘浩存男友丶:AwADCAUABAoAAA==.别拿奶瓶逗澄:AwADCAMABAoAAA==.',['�']='劳资蜀道山:AwABCAEABAoAAA==.',['�']='半糖冰沙:AwAECAoABRQDCgAEAQhkGABBTdkABRQACgAEAQhkGAAxw9kABRQACwABAQi7EwAzX0wABRQAAQoAU/kGCAkABRQ=.华音笑浅:AwACCAIABAoAAA==.卖钕孩的火柴:AwAICA0ABAoAAA==.卡尔猎:AwAECAEABRQAAA==.',['�']='叉坑子代表:AwAFCAUABAoAAA==.叫嚣的中士:AwACCAIABRQAAA==.',['�']='吖玛德:AwAGCAcABAoAAA==.',['�']='呆萌女猎手:AwAECAwABRQCDAAEAQitCgBF4wcBBRQADAAEAQitCgBF4wcBBRQAAA==.',['�']='咸鱼佬:AwABCAEABAoAAA==.',['�']='哇噻是基基:AwAICAgABAoAAA==.',['�']='唔摸德:AwAICBMABAoAAA==.',['�']='喝水长肉:AwAGCAkABAoAAA==.喧嚣与寂静:AwAGCAQABAoAAA==.',['�']='四运大经理:AwAECAQABRQAAA==.囧小豆:AwAECAYABRQCDQAEAQg6DAAplegABRQADQAEAQg6DAAplegABRQAAA==.',['�']='土豆爱喝拿铁:AwAECAoABRQDDgAEAQiEAwAy7cAABRQADwAEAQizDAAvXvcABRQADgAEAQiEAwArI8AABRQAAA==.圣光无用:AwAICB4ABAoCEAAIAQg7FQBZpK8CBAoAEAAIAQg7FQBZpK8CBAoAAA==.',['�']='天和:AwACCAIABRQAAA==.天堂挖坑:AwAHCAEABAoAAA==.',['�']='女嫡裂:AwACCAIABAoAAA==.好运小胖熊:AwAICAgABAoAAA==.',['�']='威尔士亲王:AwAICAkABAoAAA==.',['�']='孟川琴瑟七月:AwAECAgABAoAAA==.',['�']='守護守護:AwAGCAYABAoAAA==.审判起手:AwACCAIABAoAAA==.',['�']='小怪兽呀:AwAECAQABRQAAQEAAAAGCAIABRQ=.小牛牛就是你:AwAECAQABRQAAA==.小甜甜的暴走:AwAGCAwABAoAAA==.小逗匕:AwADCAMABAoAAA==.小鸡快跑:AwAECAQABRQAAA==.小鹌鹑:AwAICAgABAoAAA==.',['�']='山上撤也:AwAECAgABRQCEAAEAQg2GAArOeQABRQAEAAEAQg2GAArOeQABRQAAA==.',['�']='岁月灬聖:AwACCAIABAoAAA==.岩浆蹦迪:AwAICAgABAoAAA==.',['�']='帅丢丢:AwAECAQABAoAAA==.',['�']='幻想家:AwAECAkABAoAAA==.',['�']='张飞:AwAICAgABAoAAA==.弱弱的:AwADCAMABRQAAA==.',['�']='彩色酱:AwAECAUABRQDEQACAQgmCgAryZYABRQAEQACAQgmCgAryZYABRQAEAACAQgGMwATjXYABRQAAA==.',['�']='待宰的羊羔:AwAFCAUABAoAAA==.御灵渡厄:AwAFCAsABAoAAA==.德克诺维茨基:AwAFCAEABAoAAA==.',['�']='快没蓝了:AwAFCAUABAoAAA==.',['�']='性感丶山羊胡:AwABCAEABRQAAA==.',['�']='恶魔爸比:AwABCAEABAoAAA==.',['�']='惊月流云:AwAICCAABAoDCwAIAQgMBwBdQsICBAoACwAIAQgMBwBcncICBAoACgAIAQhzFABSoW0CBAoAAA==.惩灬戒灬骑:AwAICBIABAoAAA==.',['�']='愚人:AwACCAIABRQAAA==.',['�']='我们之间:AwACCAIABAoAAA==.我叫大海豹:AwAICAgABAoAAQEAAAAICA0ABAo=.我心的花色:AwACCAMABAoAAA==.我的法克:AwAICAgABAoAAA==.',['�']='扎古扎古扎:AwAECBEABRQDBgAEAQj5FABVIsYABRQABgADAQj5FABWycYABRQAEgABAQjXGgAX+DkABRQAAA==.打白糖:AwAGCAYABAoAAA==.执爱丶:AwAICAgABAoAAA==.找找跟紧我:AwAECAYABRQCEwAEAQhACAA7st4ABRQAEwAEAQhACAA7st4ABRQAAA==.',['�']='抽你长个包:AwAFCAcABAoAAQEAAAAGCAQABRQ=.',['�']='持久哥:AwAFCAUABAoAAA==.',['�']='探长华:AwAECAEABAoAAA==.',['�']='提尔物语:AwAECAQABAoAAA==.',['�']='摸鱼大王:AwACCAIABRQAAQoAJ70GCAoABRQ=.',['�']='放开那母熊:AwACCAIABRQAAA==.',['�']='斗鬼泣:AwAGCAYABRQCEgAGAQipAAA/y6wBBRQAEgAGAQipAAA/y6wBBRQAAA==.',['�']='无绝妹妹:AwAECAQABRQAAA==.时光染指红尘:AwABCAEABRQAAA==.旺仔小偷:AwAFCAUABAoAAA==.',['�']='星阙唤流云:AwAFCAUABAoAAA==.',['�']='晨乂曦:AwABCAEABRQAAA==.',['�']='木冇鱼丸:AwAECAQABRQDFAAIAQhMMgAX5zYBBAoAFAAIAQhMMgAX5zYBBAoAFQAHAQjKTQAkNy4BBAoAAA==.',['�']='枫绝尘:AwAECAQABRQAAQEAAAAGCAQABRQ=.枫逸水:AwABCAEABAoAAA==.',['�']='标普熔断:AwABCAEABAoAAA==.栞又:AwADCAcABRQDEAAIAQiUvwAZ++sABAoAEAAGAQiUvwAeUusABAoAFgAIAQh/OwAHEXsABAoAAA==.',['�']='棒棒骑:AwAECAQABRQAAA==.',['�']='欧尼尔:AwAECAQABAoAAA==.',['�']='正义传说:AwADCAMABAoAAA==.此刻寂灭之时:AwAGCAIABRQAAA==.歪小瑾:AwAECAQABRQAAA==.',['�']='永雏塔菲:AwABCAEABRQAAA==.',['�']='江东杰瑞:AwAHCAsABAoAAA==.',['�']='洛姬娅:AwAICAgABAoAAA==.',['�']='深红荆棘棘:AwAHCAcABAoAAA==.',['�']='漩涡:AwACCAIABAoAAA==.',['�']='激儿乱甩:AwACCAMABAoAAA==.',['�']='炫辉龙:AwAECAQABAoAAA==.',['�']='狂野怒风:AwAFCAcABAoAAA==.狗蛋儿:AwACCAQABAoAAA==.',['�']='猇亭带投大哥:AwACCAIABRQAAA==.',['�']='王叔叔:AwABCAEABRQAAA==.玛恩星望:AwAICAMABAoAAA==.玛迪琳丶贝莉:AwAGCAcABAoAAA==.',['�']='珊瑚宝珠:AwAECAQABRQAAA==.',['�']='瓜皮磊:AwAECAQABAoAAA==.',['�']='甜甜小骑:AwAICAgABAoAAA==.',['�']='白发照清水:AwABCAEABAoAAA==.',['�']='直男微双:AwACCAIABAoAAA==.',['�']='真北:AwACCAIABAoAAA==.真跟风青年:AwAICAgABAoAAA==.',['�']='石静:AwADCAQABAoAAA==.',['�']='破斧沉洲:AwABCAEABRQEDwAIAQiTGwBIhRoCBAoADwAIAQiTGwBIhRoCBAoADgADAQibJAAscqgABAoAFwACAQhIWAAlkDsABAoAAA==.破釜沉舟:AwAGCAIABAoAAQcAIpEECAUABRQ=.',['�']='祖国繁荣昌盛:AwABCAIABRQAAA==.',['�']='笙止:AwAHCBMABAoAAA==.',['�']='糖尸三百首:AwAICAYABAoAAA==.',['�']='素手芳华:AwACCAIABRQAAA==.紫藕香残:AwAICA8ABAoAAA==.紫雾洛風:AwABCAEABRQAAA==.',['�']='织梦行云:AwAECAQABAoAAA==.绝不能倒下:AwACCAIABRQAAA==.绿巨丶人:AwAGCAsABAoAAA==.',['�']='网恋佩奇:AwACCAIABAoAAA==.',['�']='舒心蒸饺王:AwAICAEABAoAAA==.舒心饺子王:AwABCAEABRQAAA==.舒曼:AwACCAEABAoAAQEAAAAICAkABAo=.舔狗丶:AwAECAQABRQAAA==.',['�']='芙芙天下第一:AwADCAMABAoAAA==.花夜:AwABCAEABRQAAA==.',['�']='英雄卜甘寂寞:AwACCAIABRQAAA==.',['�']='范玉欣女士:AwAICAgABAoAAA==.',['�']='药不然:AwAECAQABRQAAA==.荷叶青青:AwACCAIABAoAAA==.',['�']='莉克钠里:AwAGCBAABAoAAA==.莫格莱尼:AwAECAQABRQAAA==.',['�']='萨卡斯魔灵:AwACCAMABRQAAA==.萨塔里澳:AwAGCAcABAoAAA==.落灬猪杂:AwAGCAYABAoAAA==.',['�']='虾米没肉:AwACCAIABRQAAA==.',['�']='蛮牛冲钅:AwACCAMABRQAAA==.',['�']='蜂蜂侠:AwAECAUABRQDDAAEAQgiCwBGegQBBRQADAAEAQgiCwBGegQBBRQAGAABAQiPEgAxCT0ABRQAAQoAUhwHCAwABRQ=.',['�']='见朕骑姬:AwAGCAEABAoAAA==.',['�']='财巜神:AwABCAIABRQCCQAHAQi4JABar0YCBAoACQAHAQi4JABar0YCBAoAAA==.',['�']='超神的炮灰:AwAFCAUABAoAAA==.',['�']='踏梦怜空:AwAICAgABAoAAA==.',['�']='还德是你:AwAGCAYABAoAAA==.迪奥布兰度:AwAICAsABAoAARMAVD4ECAYABRQ=.',['�']='逸飘悠然:AwADCAMABAoAAA==.',['�']='都叫我四弟丶:AwAICAgABAoAAA==.',['�']='铭火:AwAGCAwABRQCCgAGAQgGAwAudaIBBRQACgAGAQgGAwAudaIBBRQAAA==.',['�']='问星海:AwABCAEABRQAAA==.',['�']='阿尔杰斯丶:AwACCAIABRQAAA==.',['�']='雅典娜之惊叹:AwAICAgABAoAAA==.',['�']='露西娅:AwAFCAUABAoAAQEAAAAGCAkABAo=.',['�']='顶不住就跑:AwACCAIABRQAAA==.',['�']='风拂青霜:AwAICAMABAoAAA==.风津道:AwAECAUABRQCDQAEAQgGDgAyld0ABRQADQAEAQgGDgAyld0ABRQAAQEAAAAGCAQABRQ=.飞踹的小脚:AwAICAgABAoAAA==.',['�']='饭饭电电:AwAECAgABRQCEAAEAQgxBgBN/S0BBRQAEAAEAQgxBgBN/S0BBRQAAA==.',['�']='骄纵卿:AwAECAQABRQAAA==.',['�']='鬓发婉清扬:AwADCAQABRQAAA==.',['�']='魔法失手啦:AwAECAQABRQAAA==.魔法失效啦:AwAECAIABRQAAA==.',['�']='黄昏灬夕陽:AwAICCUABAoDBgAIAQiHLgA38tMBBAoABgAHAQiHLgA/0tMBBAoAEgAGAQieSgASg7kABAoAAA==.黄瓜表哥:AwADCAEABAoAAA==.黑白照:AwACCAIABRQAAA==.黑色晴人:AwAECAQABRQAAA==.黑豆朱古力:AwAECAYABAoAAA==.黯逝隼尘:AwAHCBQABAoCEgAHAQjcLAAw9UkBBAoAEgAHAQjcLAAw9UkBBAoAAA==.',['�']='龙凤人生:AwACCAIABRQAAA==.龙龙发:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end