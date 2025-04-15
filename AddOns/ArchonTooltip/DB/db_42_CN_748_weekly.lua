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
 local lookup = {'Hunter-BeastMastery','Shaman-Restoration','Warrior-Arms','DeathKnight-Unholy','Mage-Frost','Unknown-Unknown','Paladin-Retribution','Mage-Fire','Warrior-Fury','Monk-Windwalker','DeathKnight-Blood','Shaman-Enhancement','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Discipline','Evoker-Devastation','DemonHunter-Havoc','Hunter-Marksmanship','Warrior-Protection','Evoker-Preservation','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Shaman-Elemental','Paladin-Holy','Rogue-Outlaw','Monk-Mistweaver','Druid-Balance','Druid-Restoration','Monk-Brewmaster','Paladin-Protection','DeathKnight-Frost',}; local provider = {region='CN',realm='熔火之心',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Anduyin:AwAECAEABRQAAA==.Angelinajoli:AwAHCAcABAoAAA==.',Bw='Bwater:AwAECAIABRQAAQEAShkGCA4ABRQ=.',Ca='Capencise:AwAICAgABAoAAA==.',De='Decad:AwAGCAsABAoAAA==.',Do='Doubled:AwACCAIABRQAAA==.',Em='Emmawong:AwAECAQABRQAAA==.',Ga='Galahads:AwAHCAIABAoAAA==.',Ha='Hawkeye:AwAGCAYABAoAAA==.',He='Hexa:AwACCAYABRQCAgACAQj7GAAzTpMABRQAAgACAQj7GAAzTpMABRQAAA==.',Ho='Houdryad:AwAICAgABAoAAQMAS5IGCBAABRQ=.Housensei:AwAECAQABRQAAA==.',Ki='Kido:AwABCAEABAoAAQQASVsFCAUABRQ=.',Le='Legendaryl:AwAECAEABAoAAA==.',Li='Lintq:AwAECAQABRQAAA==.',Ly='Lya:AwABCAIABRQAAA==.',Me='Mean:AwAFCAUABAoAAA==.Mechagnome:AwAICBEABAoAAQQAMqgICBwABAo=.',Ol='Oline:AwACCAMABRQCBQAIAQh0IwA3T9IBBAoABQAIAQh0IwA3T9IBBAoAAA==.',Or='Orcswarrior:AwAHCBMABAoAAA==.',Sa='Sakuralin:AwAECAQABRQAAA==.',Su='Suki:AwAECAQABRQAAA==.Superld:AwADCAMABAoAAA==.',Ta='Taroumati:AwAICAgABAoAAA==.',Th='Thór:AwADCAEABAoAAA==.',Um='Umbreon:AwAICAMABAoAAA==.',Vo='Voneker:AwAHCAkABAoAAA==.',Wa='Wateryo:AwAICAsABAoAAA==.',We='Wei:AwAECAYABAoAAA==.',Yi='Yizhifs:AwAECAQABRQAAQYAAAAICAQABRQ=.',Ze='Zephyr:AwAECAQABAoAAQQAMqgICBwABAo=.',Zm='Zmjkk:AwAICBwABAoCBwAIAQjPEgBXxrsCBAoABwAIAQjPEgBXxrsCBAoAAA==.',Zp='Zpf:AwAGCAwABRQDBQAGAQgfAAA+S7EBBRQABQAGAQgfAAAviLEBBRQACAAGAQiXAwAoE48BBRQAAA==.',['�']='一个石榴:AwADCAMABRQAAA==.一关雲長一:AwACCAIABAoAAA==.一路孤行也罢:AwAGCBEABAoAAA==.三三:AwADCAMABRQAAA==.三句半:AwACCAcABRQCBwACAQj9JgA9m5sABRQABwACAQj9JgA9m5sABRQAAA==.上去就是一腿:AwAECAQABRQAAA==.不会绷带:AwAICBAABAoAAA==.不吃青椒:AwACCAEABRQCCQAIAQhfIAA+fvsBBAoACQAIAQhfIAA+fvsBBAoAAA==.不见丶不散丶:AwAGCAYABAoAAA==.专治黑手:AwAICA8ABAoAAA==.丨兔子酱乄:AwAECAUABAoAAA==.丶佛爷丶:AwACCAIABAoAAA==.丶莉莉丝儿:AwADCAQABAoAAA==.丶阿蹦:AwABCAEABAoAAA==.丷信仰:AwAGCAoABAoAAA==.丹宸:AwACCAQABRQAAA==.为欲为:AwAECAQABRQAAA==.丿傻馒丶:AwABCAIABRQAAA==.',['�']='久久为功:AwAICAUABAoAAA==.九尾人柱力:AwAECAQABAoAAA==.',['�']='人定胜天:AwAECAQABRQAAA==.',['�']='今宵不惑:AwAFCA4ABAoAAA==.仨圈:AwAICAYABAoAAA==.',['�']='伊泽克森:AwAICAgABAoAAA==.会飞的羊驼:AwAICAgABAoAAA==.似水鱼心:AwAICAwABAoAAA==.',['�']='你打我会吗:AwADCAYABRQCCgADAQiXCgAYKswABRQACgADAQiXCgAYKswABRQAAA==.你看不见我:AwABCAEABRQAAA==.你给我站那:AwABCAEABRQAAA==.',['�']='依然奈你:AwAECAQABRQAAA==.',['�']='信不了半点:AwAFCAQABAoAAA==.',['�']='倔强于执着丶:AwABCAMABRQAAA==.',['�']='傻幔和哀木涕:AwACCAIABRQAAA==.',['�']='元骑满满:AwAGCAsABAoAAA==.光仔崽:AwACCAIABAoAAA==.兔桃儿:AwACCAIABRQAAA==.八云岚:AwACCAQABRQCCwAIAQgjBQBZQLoCBAoACwAIAQgjBQBZQLoCBAoAAA==.六乄六:AwAICAUABAoAAA==.兴趣使然:AwABCAEABRQDAwAIAQjeCQBNpmECBAoAAwAIAQjeCQBNpmECBAoACQACAQjJegBEakwABAoAAA==.',['�']='凉月奏:AwAGCAYABRQCDAAGAQjzAAAv0bkBBRQADAAGAQjzAAAv0bkBBRQAAQEAKokICAIABRQ=.',['�']='刁丶先生:AwADCAIABAoAAA==.刁残:AwAICBYABAoEDQAIAQiUEQBK4E8CBAoADQAIAQiUEQBK4E8CBAoADgADAQjBRgAsP4cABAoADwABAQh0PgAOuDIABAoAAA==.别叫我矮子:AwAECAgABRQCAgAEAQhTDQAlxN4ABRQAAgAEAQhTDQAlxN4ABRQAAA==.别开槍丶是我:AwAGCAYABRQDDwAGAQjQBAA2g/sABRQADwAEAQjQBABGTfsABRQADQACAQiXEgAe07QABRQAAQ0ATegICAYABRQ=.',['�']='加糖冰红茶:AwAECAgABAoAAA==.劣刃:AwABCAEABRQAAA==.',['�']='勾引我吧:AwAICBAABAoAAA==.',['�']='北国风光:AwAHCAoABAoAAA==.',['�']='千又:AwACCAIABRQAAA==.卖了熊掌的熊:AwAICAYABAoAAA==.南极甜虾:AwAICAkABAoAAA==.南烛:AwAICAkABAoAAA==.卧梅悠闻花:AwABCAEABRQAAA==.',['�']='原谅帽贩卖机:AwAICAoABAoAAA==.',['�']='古拉克:AwAGCAQABAoAAA==.史莱姆:AwAGCAEABRQAAA==.叶落而无声:AwAHCAMABAoAARAAPiAICA4ABRQ=.叶落间愁:AwABCAEABAoAAA==.',['�']='吃葡萄的阿木:AwAECAQABRQAAQYAAAAICAQABRQ=.吃顿好的:AwAECAQABRQAAA==.吊打奶德:AwACCAYABRQCAgACAQjKEABWlckABRQAAgACAQjKEABWlckABRQAAA==.名利不如闲:AwACCAIABAoAAA==.听风丶:AwAICAgABAoAAA==.',['�']='周九月:AwAECAQABRQAAA==.呵丶呵丶:AwAICA0ABAoAAA==.呼呼灬小娜娜:AwAFCAcABAoAAA==.',['�']='和曦:AwAICAgABAoAAA==.咕叽咕叽呼:AwAICAgABAoAAA==.',['�']='唯有一种感觉:AwADCAUABAoAAA==.',['�']='嗨丶巧乐兹:AwAGCAYABAoAAA==.',['�']='嘟嘟哒哒噗:AwAICAgABAoAAA==.',['�']='四季映姬:AwEECAUABRQCEAAEAQhnCQA8zOkABRQAEAAEAQhnCQA8zOkABRQAAREALGsECAYABRQ=.国服道士:AwACCAIABRQAAA==.',['�']='在逃装逼犯丶:AwADCAMABRQAAA==.',['�']='坂田丶银时:AwAECAQABRQAAA==.',['�']='墓魂:AwAICAgABAoAAA==.',['�']='壹抹淺笑:AwAICB8ABAoCEgAIAQj+DQBWzKQCBAoAEgAIAQj+DQBWzKQCBAoAAA==.',['�']='多恩诺嘉尔:AwAGCAEABAoAAA==.大師兇:AwAECAQABRQAAA==.大跳躲链子:AwAGCAIABAoAAA==.大铁牛:AwABCAEABAoAAA==.天下如此凄凉:AwAHCA4ABAoAAA==.天呐你真烧丶:AwAICAgABAoAAA==.天唐梓魔:AwAICA8ABAoAAA==.天堂丿梵觉:AwAECAwABRQCCAAEAQi8CwBMIgwBBRQACAAEAQi8CwBMIgwBBRQAAA==.',['�']='奈亚子:AwAECAkABAoAAA==.奔跑的地瓜:AwAECAQABRQAAA==.女王的鞋垫:AwAECAQABAoAAA==.',['�']='媳妇儿你先睡:AwABCAEABRQAAA==.',['�']='嫂嫂别乱来:AwAICAYABAoAAA==.',['�']='孤寂晓酌:AwABCAEABRQAAA==.孤心伴玥:AwAECAYABRQCAQAEAQg5EgA61PEABRQAAQAEAQg5EgA61PEABRQAAA==.',['�']='安德鲁丶:AwABCAEABRQDAQAIAQgRHABJi3ACBAoAAQAIAQgRHABJi3ACBAoAEwADAQj9TAAjQZoABAoAAQIASDUCCAcABRQ=.宋雨:AwABCAEABRQAAA==.',['�']='寂寥空烛:AwAICBcABAoDAwAIAQi/EwA9nfEBBAoAAwAIAQi/EwA5cfEBBAoAFAAFAQgfJAAoYqsABAoAAA==.寇塔空:AwAICAMABAoAAA==.寶寶丷:AwACCAUABRQCBAACAQgaFwAx9pkABRQABAACAQgaFwAx9pkABRQAAQQASVsFCAUABRQ=.寻渊:AwABCAEABRQAAA==.',['�']='封狼居胥:AwACCAUABRQCBAACAQiMEgBALLQABRQABAACAQiMEgBALLQABRQAAA==.小奶锤:AwAECAMABAoAAA==.小奶龙:AwAECA0ABRQCFQAEAQjjAABT/iYBBRQAFQAEAQjjAABT/iYBBRQAAA==.小布:AwAICAkABAoAAA==.小机灵鬼儿:AwAECAQABRQAAA==.小柒酱丶:AwAGCAsABAoAAA==.小欻欻:AwAECAgABRQCEgAEAQgiBwBXmh8BBRQAEgAEAQgiBwBXmh8BBRQAAA==.小湿弟:AwAECAgABRQCCgAEAQi7CwAmybcABRQACgAEAQi7CwAmybcABRQAAA==.小灬柒:AwAECAgABRQDFgAEAQhXBABSNA4BBRQAFgAEAQhXBAA/+w4BBRQAFwACAQjmCwAtAZEABRQAAA==.小红手楠哥:AwACCAIABAoAAA==.小龙哥:AwAGCBcABRQDCQAGAQgCAQBJtaMBBRQACQAFAQgCAQBQLqMBBRQAAwABAQhIDwAv0l8ABRQAAA==.少林铁头功:AwAICBAABAoAAA==.尛宝:AwAGCAYABAoAAA==.就是个干:AwAECAQABRQAAA==.尸巫术:AwAGCAYABAoAAA==.',['�']='左思右想:AwAICAkABAoAAA==.巭翠花:AwAICAgABAoAARYAOhQGCAYABRQ=.差一点成熟丶:AwABCAIABRQAAA==.巴尔的摩丶:AwAECAMABRQAAQkARjcFCBAABRQ=.巴德尔:AwAECAQABAoAAA==.',['�']='帕米菈:AwACCAQABRQCAQAIAQiwGgBTIXcCBAoAAQAIAQiwGgBTIXcCBAoAAA==.帝陨:AwAICAgABAoAAQQAVJMECAoABRQ=.',['�']='幻世圣光牛:AwAICA0ABAoAAA==.',['�']='库莱:AwAGCAQABRQAAA==.庞桶:AwAGCAYABAoAAA==.',['�']='弗瑞奥萨丶:AwAICAgABAoAAA==.张彬的巴巴:AwAICBIABAoAAA==.强爆表:AwAICBAABAoAAQcATYsGCAoABRQ=.',['�']='当街搂抱抱:AwAICBAABAoAAA==.影諾:AwADCAkABRQCFgADAQg8BwAwRegABRQAFgADAQg8BwAwRegABRQAAA==.',['�']='得来速:AwAGCAUABAoAAA==.',['�']='心声:AwAHCAcABAoAAA==.',['�']='怒火狂斩:AwABCAIABRQAAA==.',['�']='恐怖的五先生:AwAFCAkABAoAAA==.',['�']='悍雷惊天:AwAHCAEABAoAAA==.悠嘻丶猴:AwAFCAEABAoAAA==.',['�']='惩戒骑当奶用:AwAICA8ABAoAAA==.',['�']='愈合祷言:AwAICBMABAoAAA==.',['�']='懵乐儿:AwAECAEABAoAAA==.',['�']='我不认路:AwACCAIABRQAAA==.我兜兜里有糖:AwAICAgABAoAAA==.我是取款机:AwAICAgABAoAAA==.我是虾米呢:AwAICBEABAoAAA==.我最矮:AwADCAMABAoAAA==.我顶得住丶:AwADCAMABAoAAA==.戦武此人:AwAGCAcABAoAAA==.戴面纱的琴师:AwAGCAcABAoAAA==.',['�']='手法异常粗糙:AwAECAQABRQAAA==.打咩打尤:AwAICAgABAoAAA==.',['�']='抚州电网:AwABCAEABAoAAA==.抱歉打得不錯:AwAICBAABAoAAA==.',['�']='振小健:AwAICBMABAoAAA==.振翅的阿昆达:AwACCAIABRQAAA==.',['�']='捌级大狂风:AwACCAEABAoAAA==.',['�']='插棍子拉链子:AwACCAUABRQCAgACAQhcHQAUb4EABRQAAgACAQhcHQAUb4EABRQAAQEAKokICAIABRQ=.',['�']='摇头晃脑:AwADCAUABRQCBAADAQjEAgBdekABBRQABAADAQjEAgBdekABBRQAAA==.',['�']='新小岩五丁目:AwAICAgABAoAAA==.',['�']='无慯:AwAECAQABRQAAQYAAAAGCAIABRQ=.无限空冥:AwABCAIABRQAAA==.旭东黄:AwABCAEABRQAAA==.时长两年半:AwADCAMABAoAAA==.',['�']='明天晴天:AwAICA8ABAoAAA==.明月松间照:AwACCAIABRQAAA==.星辰之心:AwAICAgABAoAAA==.星际船长:AwAFCAUABAoAAA==.春华夏焰:AwABCAEABRQAARgAYXsCCAQABRQ=.',['�']='晃悠的圣光:AwACCAIABRQAAA==.',['�']='曹格:AwACCAIABRQAAQYAAAAICAEABRQ=.',['�']='最后的爸爸丨:AwAECAQABRQAAA==.月丶僰:AwABCAEABAoAAA==.朝点看远:AwAICAgABAoAAA==.朵拉之心:AwADCAIABAoAAA==.',['�']='李白丷:AwAICAcABAoAAA==.杰克斯喽法克:AwABCAIABRQAAA==.',['�']='枫圣:AwAGCAYABAoAAA==.枫恋:AwACCAcABRQCBwACAQjYKAAvlJYABRQABwACAQjYKAAvlJYABRQAAA==.',['�']='柒丶葉:AwAECAQABRQAAA==.柳梦漓:AwAICAgABAoAAA==.柳茹烟:AwAICAsABAoAAA==.',['�']='梅赛德斯:AwADCAQABAoAAA==.',['�']='楠汐:AwAFCAEABAoAAA==.',['�']='樱雪惊鸿一瞥:AwAICAwABAoAAA==.',['�']='橘子嘚秘密:AwADCAgABRQCBwADAQjPFwAqZOYABRQABwADAQjPFwAqZOYABRQAAA==.橙心如意:AwAICBAABAoAAA==.',['�']='正义的黑人:AwAHCAcABAoAAA==.死于去年夏天:AwAICAgABAoAAA==.',['�']='毅力哒泪:AwAECAQABAoAAA==.比奇堡蟹黄堡:AwACCAIABRQCGQAIAQjBGQA+0/EBBAoAGQAIAQjBGQA+0/EBBAoAAA==.',['�']='永恒德:AwAGCAIABAoAAA==.',['�']='汝红的粉头:AwABCAEABAoAAA==.',['�']='沈幼楚:AwADCAQABRQCBAAIAQiQGgBHfzsCBAoABAAIAQiQGgBHfzsCBAoAAA==.沐雨晴枫:AwACCAIABRQAAQgAQOkECAYABRQ=.没你好果子吃:AwABCAEABAoAAA==.',['�']='法爷不开门:AwAFCAYABAoAAA==.泰迪尔:AwAICBAABAoAAA==.',['�']='流光奕彩:AwAECAQABRQAAQEANu4GCAYABRQ=.浆果儿:AwAFCAUABAoAAA==.',['�']='涸丶泽:AwAICA4ABAoAAA==.',['�']='清风入梦:AwABCAQABRQAAA==.',['�']='湮灭小龙人:AwAICBEABAoAAA==.',['�']='滚肉球:AwAECAQABRQAAA==.',['�']='漆丶夜:AwAICAgABAoAAA==.',['�']='火红圣光:AwACCAQABAoAAA==.灬丹宸:AwADCAUABRQCEAADAQgHAwBZBzoBBRQAEAADAQgHAwBZBzoBBRQAAA==.灬萌牛灬:AwAECAgABRQDAgAEAQj3CAA34/gABRQAAgAEAQj3CAA34/gABRQAGQAEAQiCCQAcpsMABRQAAA==.灵魂的阴暗面:AwAECAYABRQCDQAEAQhYAwBYMzYBBRQADQAEAQhYAwBYMzYBBRQAAA==.灵鸢:AwAICAkABAoAAA==.',['�']='烣冭岁:AwAICAkABAoAAA==.烬墟:AwADCAwABRQDBwADAQhrCABU5CABBRQABwADAQhrCABU5CABBRQAGgABAQhqDwBM7UkABRQAAA==.',['�']='熊丨翎羽:AwAECAIABRQAAQEAVXAGCAYABRQ=.',['�']='爱别离:AwAICBwABAoCBAAIAQhsLQAyqM4BBAoABAAIAQhsLQAyqM4BBAoAAA==.',['�']='牛牛小刃:AwAGCAYABAoAAA==.牛蛋儿:AwABCAEABRQAAA==.牧羊少年:AwACCAEABRQAAA==.',['�']='狗孩孩样样:AwACCAIABRQAAA==.',['�']='猫尾草:AwAECAgABRQCBwAEAQhOGwAdk9gABRQABwAEAQhOGwAdk9gABRQAAA==.',['�']='王木木丶:AwABCAEABAoAAA==.王毛毛:AwABCAEABRQAAA==.玥弦丶果果:AwAICAcABAoAAA==.现状毁灭:AwADCAMABAoAAA==.',['�']='珊瑚毛毛:AwAGCAYABAoAAA==.珠泪哀歌:AwADCAcABRQEFgADAQgJCgBQlLUABRQAFgACAQgJCgBT+rUABRQAFwABAQiYDQBJx1wABRQAGwABAQgrBQAWakMABRQAAA==.',['�']='生命不断倒腾:AwAECAgABRQCEgAEAQheDQA8jPgABRQAEgAEAQheDQA8jPgABRQAAA==.',['�']='番茄是西红柿:AwAECAwABRQCHAAEAQhnCwAtxu0ABRQAHAAEAQhnCwAtxu0ABRQAAA==.',['�']='疯一样的男人:AwAECAgABRQCEgAEAQiqBQBTdi0BBRQAEgAEAQiqBQBTdi0BBRQAAA==.疯狂丶小昱哥:AwAECAgABRQDBQAEAQj+CwAqLJUABRQABQAEAQj+CwAfI5UABRQACAACAQiUJgAisosABRQAAA==.',['�']='痛痛:AwAICAgABAoAAA==.',['�']='白喵喵丶:AwACCAIABRQAAA==.白天不起床:AwAICAgABAoAAA==.白老板:AwAICAIABAoAAA==.百事么么哒:AwADCAMABAoAAA==.百事摇一摇:AwAICAgABAoAAA==.',['�']='盗版玩偶:AwAICAwABAoAAA==.',['�']='真丶大喵:AwABCAEABRQAAA==.',['�']='神明不诉疾苦:AwAGCAYABRQDHQAGAQiuDwA3sOcABRQAHQAEAQiuDwA3hecABRQAHgACAQhACABSK84ABRQAAA==.',['�']='禅棍搅红尘:AwAECAYABRQDHAAEAQgsCwAvI+4ABRQAHAAEAQgsCwAvI+4ABRQAHwACAQg9BgAg9mQABRQAAA==.',['�']='秋风拂落叶:AwAECAgABRQCCAAEAQhSJQAlN5AABRQACAAEAQhSJQAlN5AABRQAAA==.',['�']='程一鸣:AwACCAIABRQAAA==.',['�']='空山有雪:AwAECAcABRQCAgAEAQhmDwAZBNIABRQAAgAEAQhmDwAZBNIABRQAAA==.',['�']='等我一会儿:AwAFCAkABAoAAA==.筱筱同学:AwAICBUABAoCBwAIAQjqZwA2TqQBBAoABwAIAQjqZwA2TqQBBAoAAA==.',['�']='糖果丶小宇:AwACCAIABRQAAA==.',['�']='索丨瑞:AwACCAQABRQEGQAIAQhpGABIsv0BBAoAGQAHAQhpGABMuv0BBAoAAgAHAQhIWAAZHwoBBAoADAABAQiIUAA0Zk4ABAoAAA==.紫色大苍蝇:AwAECAQABRQAAA==.紫血娃娃:AwAECAQABRQAAA==.',['�']='红颜为谁妆:AwAGCAkABAoAAA==.纳格尔轰咖:AwAECAQABRQAAA==.',['�']='给我一个吻:AwAICAgABAoAAA==.绝对不可能:AwAICBAABAoAAA==.绿灬萝:AwACCAIABRQAAA==.',['�']='缇玲:AwAECAQABRQAAA==.',['�']='罂栗丨:AwAGCAYABAoAAA==.罖魂丨幽灵:AwAECAQABRQAAA==.',['�']='翱翔的小胖九:AwAGCAYABAoAAA==.',['�']='老边战:AwABCAEABRQAAA==.耂王再隔壁:AwABCAEABRQDAQAHAQioSgBBMagBBAoAAQAHAQioSgBBMagBBAoAEwABAQggfAAAAAAABAoAAA==.',['�']='聖騎士:AwAICAgABAoAAA==.',['�']='肆意寒暄:AwAICAgABAoAAA==.肉丨山:AwAICAoABAoAAA==.肉球球:AwAICAgABAoAAA==.',['�']='脸之盾:AwACCAIABRQAAA==.',['�']='至尊圣光:AwADCAMABAoAAA==.臻猪无敌:AwACCAQABRQAAA==.',['�']='艾卡西亚暴雨:AwAICBcABAoCAQAIAQhzFABRyJkCBAoAAQAIAQhzFABRyJkCBAoAAA==.艾尔撒丶:AwAHCAkABAoAAA==.艾斯空气:AwACCAIABAoAAQYAAAAICAoABAo=.',['�']='芝士汉堡丶:AwADCAsABRQDFQADAQjDAQBGpvgABRQAFQADAQjDAQBGpvgABRQAEQADAQhnDQATDrgABRQAAA==.',['�']='英国大力士:AwAFCAMABAoAAA==.',['�']='莫晓龙人:AwADCAYABAoAARAAS5kBCAEABRQ=.',['�']='董大寳:AwABCAEABRQAAA==.',['�']='蒙奇帝卡普:AwAECAQABRQAAA==.',['�']='蓝天如此耀眼:AwAECAQABRQAAA==.',['�']='薰儿:AwACCAIABAoAAA==.',['�']='虾謎:AwAECAQABRQAAA==.',['�']='蛛丝结:AwAECAQABRQDAwAIAQicFwBLqcwBBAoAAwAGAQicFwBBkMwBBAoACQAHAQhYMQA5L5kBBAoAAA==.',['�']='西行寺幽幽子:AwEECAYABRQCEQAEAQjrCgAsa9YABRQAEQAEAQjrCgAsa9YABRQAAA==.西西可哩丶:AwABCAEABAoAAA==.',['�']='豆包安娜:AwAECAQABRQAAA==.',['�']='贾斯丁:AwAGCBAABRQDDQAEAQiVAwBY0zIBBRQADQAEAQiVAwBY0zIBBRQADgABAQiqFwAAAAAABRQAAA==.',['�']='赎爱:AwAECAYABRQCBwAEAQj3EwBBiPIABRQABwAEAQj3EwBBiPIABRQAAA==.赛莉卡:AwAGCAcABAoAAA==.',['�']='超威超威蓝猫:AwACCAIABRQAAA==.',['�']='软柿子:AwACCAIABRQAAA==.',['�']='过期的白开水:AwAECAUABRQDIAAEAQjRBABFlu8ABRQAIAAEAQjRBABFlu8ABRQAGgABAQjVEAA6uEEABRQAAA==.这情况复杂了:AwAECAQABAoAAA==.迷麓:AwAECAQABRQAAA==.',['�']='逗牛:AwABCAEABRQAAA==.',['�']='邀月众人醉:AwAHCBAABAoAAA==.邪冰:AwACCAIABRQAAA==.',['�']='野德新之助丶:AwABCAEABRQAAA==.',['�']='银之匙:AwAECAEABAoAAA==.银翼天使:AwACCAIABRQAAA==.',['�']='長威:AwABCAEABAoAAA==.',['�']='闪现变绵羊:AwAICA4ABAoAAA==.',['�']='阔斯加尔:AwACCAQABAoAAA==.',['�']='陌上花开丶:AwAICAgABAoAAA==.',['�']='雀蜂雷公鞭:AwAICAwABAoAAA==.雅儿贝德丶:AwACCAIABAoAAA==.',['�']='霞诗子老师:AwAICAsABAoAAA==.霸刀无敌:AwAICA4ABAoAAQYAAAAGCAIABRQ=.',['�']='青珏丶:AwAICBgABAoDEwAIAQjWCgBcTmYCBAoAEwAIAQjWCgBcSWYCBAoAAQAIAQiePwBQNdABBAoAAA==.青花丶:AwABCAEABRQAAA==.青龙界:AwACCAIABRQDAwAIAQhCFwAxfM8BBAoAAwAIAQhCFwAxfM8BBAoACQAFAQgmZAAL554ABAoAAA==.',['�']='颂仁头丶:AwAECAgABRQCBwAEAQimCQBKCxkBBRQABwAEAQimCQBKCxkBBRQAAA==.',['�']='饥饿者弗霖凯:AwACCAIABAoAAA==.',['�']='骨尔单:AwACCAIABRQAAA==.',['�']='魅力的精灵:AwABCAEABRQAAA==.魔叶:AwAGCAwABRQEBAAGAQgEDwAqlNUABRQABAADAQgEDwAn6NUABRQAIQABAQgmCAAPVjEABRQACwAGAAgAAAAhYAAABRQAAA==.',['�']='鸢尾翼:AwADCAMABRQAAA==.',['�']='麦考尔丶:AwAECAEABRQAAA==.',['�']='黑暗骑士丶:AwACCAcABRQCAgACAQgUFABINbAABRQAAgACAQgUFABINbAABRQAAA==.',['�']='龙希尔唤魔狮:AwACCAIABAoAAA==.龙柒柒灬:AwAECAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end