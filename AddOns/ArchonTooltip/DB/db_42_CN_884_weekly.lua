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
 local lookup = {'DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Monk-Windwalker','Shaman-Enhancement','Unknown-Unknown','Mage-Fire','Mage-Frost','Shaman-Restoration','Paladin-Retribution','Warrior-Arms','Warrior-Fury','Evoker-Preservation','Evoker-Devastation','Priest-Holy','Shaman-Elemental','Monk-Mistweaver','Druid-Balance','Warlock-Affliction','Warlock-Ranged','Paladin-Holy','Priest-Discipline','Rogue-Assassination','Priest-Shadow','Druid-Restoration',}; local provider = {region='CN',realm='风暴之鳞',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ar='Arthascris:AwABCAIABAoAAA==.',Ba='Barbiee:AwAICAgABAoAAA==.',Be='Bean:AwAGCA0ABRQCAQAGAQg5AgAtyaoBBRQAAQAGAQg5AgAtyaoBBRQAAA==.',Bl='Bleachm:AwAICAgABAoAAA==.',Ch='Christos:AwAGCAYABAoAAA==.',Dd='Dd:AwAECAQABRQDAgAIAQgHdAAmMTEBBAoAAgAIAQgHdAAfJDEBBAoAAwAEAQjrZgARGlMABAoAAQIAO2AGCBQABRQ=.',Kn='Knirvanal:AwAGCAcABRQDBAAGAQjYAAAhSjIBBRQABAAFAQjYAAAc9jIBBRQABQABAQgkIwAymV0ABRQAAA==.',Ma='Manhuaba:AwABCAEABAoAAA==.',Me='Medemede:AwABCAEABAoAAA==.',Ne='Nes:AwAECA0ABRQCBgAEAQiOCQA7ONwABRQABgAEAQiOCQA7ONwABRQAAA==.Nestea:AwAFCAUABAoAAA==.',Pl='Playeraoppbk:AwAFCAcABAoAAA==.',Tu='Tunny:AwAFCAUABAoAAA==.',['�']='下一战天国:AwADCAMABRQAAA==.下雨天怎么办:AwABCAEABAoAAA==.东方睦月:AwAHCAcABAoAAQcAOhIICAYABRQ=.丶俊:AwAECAIABRQAAA==.',['�']='乱跑跑丨:AwAGCAQABRQCCAAEAQgwBQBBThgBBRQACAAEAQgwBQBBThgBBRQAAA==.',['�']='亲亲我的蓓蓓:AwAGCAYABAoAAQkAAAAGCAQABRQ=.人总是在受罪:AwAHCAoABAoAAQoAVMEGCAgABRQ=.人总是在颓废:AwAICBEABAoAAQkAAAACCAIABRQ=.',['�']='你的名字很美:AwABCAEABAoAAA==.',['�']='光影丿:AwAECAQABRQAAA==.六翼炽蛇:AwAECAYABRQDCwAEAQj9BgA5BOUABRQACwAEAQj9BgA5BOUABRQACgACAQhuLgAPwWoABRQAAA==.',['�']='冲锋陷阵:AwAICAcABAoAAA==.',['�']='刚刚就好:AwAECAQABRQAAA==.刺刺背:AwACCAIABRQAAA==.',['�']='勾栏听曲:AwAFCAUABAoAAA==.',['�']='北风啸:AwADCAMABAoAAA==.',['�']='千里江陵:AwAFCAkABAoAAA==.博文丶:AwAHCAIABAoAAA==.',['�']='吃一个数一个:AwAECAQABRQAAQgAS9AGCAoABRQ=.',['�']='呗呗丶:AwAGCA0ABAoAAA==.呗呗龙:AwAECAcABAoAAA==.',['�']='咕咕姑咕咕:AwAFCAUABAoAAA==.',['�']='喜多川海梦:AwAECAQABAoAAA==.喵咕哔哔呦:AwAICA0ABAoAAA==.',['�']='嘿嘿硬:AwAFCAUABAoAAA==.',['�']='噩梦宝宝:AwAECAQABRQAAA==.',['�']='回音岛的余晖:AwABCAIABRQCDAAIAQjVDwBPimUCBAoADAAIAQjVDwBPimUCBAoAAA==.国服第一非酋:AwADCAgABRQCBwADAQiRBQBH0BABBRQABwADAQiRBQBH0BABBRQAAA==.',['�']='地表最强老登:AwAFCAUABAoAAA==.',['�']='墓尸小妹子:AwAICAgABAoAAA==.墨漓丶:AwABCAEABAoAAA==.',['�']='夕諾:AwACCAIABAoAAA==.大月亮丶:AwAECAQABAoAAA==.天使姐姐:AwAECAQABRQAAA==.天空屮鈹寳:AwABCAEABAoAAA==.',['�']='娜扎:AwAECAQABAoAAA==.',['�']='婉拒迪丽热巴:AwABCAEABAoAAA==.',['�']='孤酒杯空影丶:AwAICAgABAoAAQ0AQfEFCA0ABRQ=.',['�']='家远路迢:AwADCAMABAoAAA==.',['�']='富婆大排档:AwAECAQABRQAAA==.',['�']='小姗姗:AwAICAgABAoAAA==.小小的心愿:AwAECAQABRQAAA==.小术也疯狂:AwAFCAgABAoAAA==.小树林捉迷藏:AwAECAQABRQAAA==.小狸猫:AwACCAIABAoAAA==.小玉西瓜:AwAECAoABRQDDgAEAQieAQBf+EsBBRQADgAEAQieAQBf+EsBBRQADwAEAQjgBQBSiSYBBRQAAA==.小龙家小林:AwAECA0ABRQDEAAEAQgnBQAHFpQABRQAEAADAQgnBQAHFpQABRQAEQABAQjBHQAAAAAABRQAAA==.',['�']='屠戮:AwACCAIABRQAARIAP+IICAUABRQ=.',['�']='帕尼尼:AwAECAwABRQCEwAEAQi/BABIFQQBBRQAEwAEAQi/BABIFQQBBRQAAA==.',['�']='异色眼柠檬心:AwAGCAQABRQAAA==.弦上春雪:AwAGCAUABAoAARQAPfAGCAwABRQ=.',['�']='德爷:AwAECAQABRQAAA==.',['�']='忘川蒹葭:AwAECAcABRQDAwAEAQimBgBKw/sABRQAAwAEAQimBgBKw/sABRQAAgABAQhHQAAUJkAABRQAARAABxYECA0ABRQ=.',['�']='惊世帅气:AwABCAEABAoAAA==.',['�']='愛笨蛋的笨蛋:AwAFCAUABAoAAA==.',['�']='我们是十七强:AwADCAMABAoAAA==.我开我开:AwAECAQABAoAAA==.',['�']='打上花火:AwABCAEABRQAAA==.扛三刀:AwADCAcABRQCDQADAQgoHgAoNdgABRQADQADAQgoHgAoNdgABRQAAA==.扬天漫雪:AwABCAEABAoAAA==.扬州刘海柱:AwACCAIABAoAAA==.扶苏:AwAECAQABRQAAA==.',['�']='技高一筹:AwAGCAYABAoAAA==.',['�']='拳王福汉:AwACCAQABRQAAA==.拽破猎猎:AwABCAEABAoAAA==.',['�']='挥挥手全是狗:AwACCAIABAoAAA==.',['�']='改个名字:AwAICAgABAoAAA==.',['�']='斩杀冲钅未归:AwAFCAYABAoAAA==.',['�']='旋转吧:AwAGCAYABRQCFQAGAQhqAABP6/kBBRQAFQAGAQhqAABP6/kBBRQAAA==.无关风月丶:AwAGCAYABAoAAA==.',['�']='晨月灬:AwAECAUABAoAAA==.晴天娃娃:AwAECAcABAoAAA==.',['�']='暗夜公决:AwABCAEABRQAAA==.暗牧:AwAECAQABRQAAA==.暗黑骑士:AwAHCAcABAoAAA==.',['�']='果菓娃:AwABCAEABAoAAA==.枫林唤雨:AwAICBEABAoAAA==.枫林沐白:AwAFCAUABAoAAA==.枫林雷鸣:AwACCAIABAoAAA==.',['�']='柠檬心:AwAECAoABRQEBQAEAQgGCQBISwABBRQABQAEAQgGCQBISwABBRQAFgACAQg/EQAzgIgABRQABAABAQi1GgAAAAAABRQAAA==.',['�']='梦影丿:AwAECAQABRQAAA==.',['�']='死缠了不用奶:AwAECAoABRQCBQAEAQj5AwBZ4DoBBRQABQAEAQj5AwBZ4DoBBRQAAA==.',['�']='沁园春丶:AwACCAIABAoAAA==.沙漏倒装回忆:AwACCAIABAoAAA==.没有我很重要:AwAECAgABRQCBwAEAQg7BgBAXwgBBRQABwAEAQg7BgBAXwgBBRQAARUAT+sGCAYABRQ=.',['�']='法力残渣:AwAICAQABAoAAA==.泰勒德顿:AwAECAQABRQAAA==.',['�']='洗月:AwAECAQABAoAAA==.洛依依:AwABCAEABRQAAA==.',['�']='流氓的术师:AwAICAgABAoAAA==.',['�']='混学带师:AwAICAgABAoAAA==.',['�']='渡火者的解脱:AwAGCAkABRQDBQAEAQguCwBJkPAABRQABQADAQguCwBBnPAABRQAFgADAQjLCQBWqssABRQAAA==.',['�']='湛岚晨辉:AwAHCAcABAoAAA==.',['�']='火雨法:AwAGCAQABRQCFwAEAAgAAAAwXAAABRQABQAEAAgAAAAwXAAABRQAAA==.灰之魔女:AwABCAEABRQAAA==.',['�']='烟雨泷:AwAECA0ABRQDAgAEAQhGHwBJo7UABRQAAgADAQhGHwBPObUABRQAAwACAQhBEgA+vpYABRQAAA==.烟雨落流星:AwABCAEABRQAAA==.烟雨龙:AwAGCAYABAoAARgAQ4MECAgABRQ=.',['�']='焚天帝:AwAGCAYABAoAAA==.',['�']='片刻安宁:AwAECA0ABRQCGQAEAQj3AwBZ6jUBBRQAGQAEAQj3AwBZ6jUBBRQAAA==.牛牛一逐风者:AwAICAQABAoAAQgAM3YICAkABRQ=.牛皮德:AwABCAEABAoAAA==.',['�']='猎天使男爵:AwABCAEABAoAAA==.猎影丿:AwAGCAYABAoAAA==.猛练:AwAECAQABAoAAA==.',['�']='琉璃西海:AwAECAQABRQAARUAT+sGCAYABRQ=.琥糖:AwACCAIABRQAAA==.',['�']='磷霖:AwABCAEABAoAAA==.',['�']='神力:AwAGCAUABRQDDgAFAQigBwBBn8QABRQADgACAQigBwA6icQABRQADwADAQiCFABItLgABRQAAA==.神慕慕:AwAGCAYABAoAAA==.',['�']='粉皮丶骑:AwADCAMABAoAAA==.',['�']='紫金之魂:AwAGCAYABAoAAA==.',['�']='红糖糍粑:AwABCAEABAoAAA==.纪念丶回忆:AwABCAIABRQAAA==.',['�']='老宫:AwADCAsABRQCGgADAQifBwA7U+8ABRQAGgADAQifBwA7U+8ABRQAAA==.耶梦伽得:AwADCAEABRQAAA==.',['�']='肥牛来一手:AwAGCAYABAoAAA==.',['�']='艾希丨灬女王:AwAFCAUABAoAAA==.',['�']='花都唐:AwACCAIABAoAAA==.',['�']='苍月厶塞亚:AwAECAQABAoAAA==.',['�']='茶妹蛋:AwAICAgABAoAAA==.',['�']='莽夫的寒冬:AwADCAMABAoAAA==.',['�']='菲米莉丝:AwAFCAwABAoAAA==.',['�']='萨不住了:AwAICA8ABAoAAA==.萨拉丁之力:AwADCAMABAoAAA==.萨爷:AwAICAgABAoAAA==.',['�']='蒂姆波顿:AwAECAYABRQDGwAEAQiuEAAWecIABRQAGwADAQiuEAAWecIABRQAGQACAQh4HgAt20wABRQAAA==.蒼瀾:AwAGCAoABAoAAA==.',['�']='血兽来了:AwAGCAYABRQCGQAGAQhRAABZ3xUCBRQAGQAGAQhRAABZ3xUCBRQAARUAT+sGCAYABRQ=.血源病注射器:AwAECA0ABRQCFQAEAQhvCwBRFwABBRQAFQAEAQhvCwBRFwABBRQAAA==.',['�']='西楚霸王项羽:AwAECAQABRQAAA==.西菛大吹雪:AwAICBwABAoCDQAIAQi/WgBD884BBAoADQAIAQi/WgBD884BBAoAAA==.',['�']='诸葛二细:AwAGCAoABAoAAQkAAAAICAMABRQ=.',['�']='贫僧丶唐三葬:AwAGCAkABAoAAA==.',['�']='踏雾:AwAECAEABAoAAA==.',['�']='辉月灬:AwAECAgABRQDGAAEAQgCBABDg/wABRQAGAAEAQgCBABDg/wABRQADQABAQhSPQAoklAABRQAAA==.',['�']='逆流而下:AwAGCAYABRQCDAAGAQh3AAA3eLoBBRQADAAGAQh3AAA3eLoBBRQAAA==.',['�']='遥遥无期:AwADCAYABRQDAgADAQi5KgAbUI8ABRQAAgACAQi5KgAlP48ABRQAAwACAQjCFwAIV2oABRQAAA==.',['�']='邪风小短短:AwAICAgABAoAAA==.',['�']='锅锅哒:AwACCAIABAoAAA==.',['�']='雅木天堂:AwAECAQABRQAAA==.雷雷宝宝打肚:AwAECA0ABRQDGwAEAQhGBABg4EwBBRQAGwAEAQhGBABg4EwBBRQAGQADAQh+CABFi/sABRQAAA==.',['�']='颓废的败家子:AwADCAMABRQAAA==.',['�']='风丶疯:AwAECAcABAoAAA==.风叔:AwADCAMABAoAAA==.风雨在途:AwACCAIABRQAARwAOkwGCAUABRQ=.风骚的大牛:AwAICAkABAoAAA==.飞翔的水牛:AwAECAQABRQAARMAVZkICAIABRQ=.',['�']='骸骨战弓:AwABCAEABRQAAA==.',['�']='黑咖双糖双奶:AwAGCAYABAoAAA==.',['�']='齋藤明日香:AwADCAcABRQCAQADAQgnFAAmH98ABRQAAQADAQgnFAAmH98ABRQAAA==.',['�']='龙啸九天:AwADCAMABAoAAA==.龙天一:AwAICAgABAoAAA==.龙骧残雪:AwAICA0ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end