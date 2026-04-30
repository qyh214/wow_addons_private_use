local V2_TAG_NUMBER = 4

---@param v2Rankings ProviderProfileV2Rankings
---@return ProviderProfileSpec
local function convertRankingsToV1Format(v2Rankings, difficultyId, sizeId)
	---@type ProviderProfileSpec
	local v1Rankings = {}
	v1Rankings.progress = v2Rankings.progressKilled
	v1Rankings.total = v2Rankings.progressPossible
	v1Rankings.average = v2Rankings.bestAverage
	v1Rankings.spec = v2Rankings.spec
	v1Rankings.asp = v2Rankings.allStarPoints
	v1Rankings.rank = v2Rankings.allStarRank
	v1Rankings.difficulty = difficultyId
	v1Rankings.size = sizeId

	v1Rankings.encounters = {}
	for id, encounter in pairs(v2Rankings.encountersById) do
		v1Rankings.encounters[id] = {
			kills = encounter.kills,
			best = encounter.best,
		}
	end

	return v1Rankings
end

---Convert a v2 profile to a v1 profile
---@param v2 ProviderProfileV2
---@return ProviderProfile
local function convertToV1Format(v2)
	---@type ProviderProfile
	local v1 = {}
	v1.subscriber = v2.isSubscriber
	v1.perSpec = {}

	if v2.summary ~= nil then
		v1.progress = v2.summary.progressKilled
		v1.total = v2.summary.progressPossible
		v1.totalKillCount = v2.summary.totalKills
		v1.difficulty = v2.summary.difficultyId
		v1.size = v2.summary.sizeId
	else
		local bestSection = v2.sections[1]
		v1.progress = bestSection.anySpecRankings.progressKilled
		v1.total = bestSection.anySpecRankings.progressPossible
		v1.average = bestSection.anySpecRankings.bestAverage
		v1.totalKillCount = bestSection.totalKills
		v1.difficulty = bestSection.difficultyId
		v1.size = bestSection.sizeId
		v1.anySpec = convertRankingsToV1Format(bestSection.anySpecRankings, bestSection.difficultyId, bestSection.sizeId)
		for i, rankings in pairs(bestSection.perSpecRankings) do
			v1.perSpec[i] = convertRankingsToV1Format(rankings, bestSection.difficultyId, bestSection.sizeId)
		end
		v1.encounters = v1.anySpec.encounters
	end

	if v2.mainCharacter ~= nil then
		v1.mainCharacter = {}
		v1.mainCharacter.spec = v2.mainCharacter.spec
		v1.mainCharacter.average = v2.mainCharacter.bestAverage
		v1.mainCharacter.difficulty = v2.mainCharacter.difficultyId
		v1.mainCharacter.size = v2.mainCharacter.sizeId
		v1.mainCharacter.progress = v2.mainCharacter.progressKilled
		v1.mainCharacter.total = v2.mainCharacter.progressPossible
		v1.mainCharacter.totalKillCount = v2.mainCharacter.totalKills
	end

	return v1
end

---Parse a single set of rankings from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileV2Rankings
local function parseRankings(decoder, state, lookup)
	---@type ProviderProfileV2Rankings
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progressKilled = decoder.decodeInteger(state, 1)
	result.progressPossible = decoder.decodeInteger(state, 1)
	result.bestAverage = decoder.decodePercentileFixed(state)
	result.allStarRank = decoder.decodeInteger(state, 3)
	result.allStarPoints = decoder.decodeInteger(state, 2)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encountersById = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)
		local isHidden = decoder.decodeBoolean(state)

		result.encountersById[id] = { kills = kills, best = best, isHidden = isHidden }
	end

	return result
end

---Parse a binary-encoded data string into a provider profile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@param formatVersion number
---@return ProviderProfile|ProviderProfileV2|nil
local function parse(decoder, content, lookup, formatVersion) -- luacheck: ignore 211
	-- For backwards compatibility. The existing addon will leave this as nil
	-- so we know to use the old format. The new addon will specify this as 2.
	formatVersion = formatVersion or 1
	if formatVersion > 2 then
		return nil
	end

	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	---@type ProviderProfileV2
	local result = {}
	result.isSubscriber = decoder.decodeBoolean(state)
	result.summary = nil
	result.sections = {}
	result.progressOnly = false
	result.mainCharacter = nil

	local sectionsCount = decoder.decodeInteger(state, 1)
	if sectionsCount == 0 then
		---@type ProviderProfileV2Summary
		local summary = {}
		summary.zoneId = decoder.decodeInteger(state, 2)
		summary.difficultyId = decoder.decodeInteger(state, 1)
		summary.sizeId = decoder.decodeInteger(state, 1)
		summary.progressKilled = decoder.decodeInteger(state, 1)
		summary.progressPossible = decoder.decodeInteger(state, 1)
		summary.totalKills = decoder.decodeInteger(state, 2)

		result.summary = summary
	else
		for i = 1, sectionsCount do
			---@type ProviderProfileV2Section
			local section = {}
			section.zoneId = decoder.decodeInteger(state, 2)
			section.difficultyId = decoder.decodeInteger(state, 1)
			section.sizeId = decoder.decodeInteger(state, 1)
			section.partitionId = decoder.decodeInteger(state, 1) - 128
			section.totalKills = decoder.decodeInteger(state, 2)

			local specCount = decoder.decodeInteger(state, 1)
			section.anySpecRankings = parseRankings(decoder, state, lookup)

			section.perSpecRankings = {}
			for j = 1, specCount - 1 do
				local specRankings = parseRankings(decoder, state, lookup)
				table.insert(section.perSpecRankings, specRankings)
			end

			table.insert(result.sections, section)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)
	if hasMainCharacter then
		---@type ProviderProfileV2MainCharacter
		local mainCharacter = {}
		mainCharacter.zoneId = decoder.decodeInteger(state, 2)
		mainCharacter.difficultyId = decoder.decodeInteger(state, 1)
		mainCharacter.sizeId = decoder.decodeInteger(state, 1)
		mainCharacter.progressKilled = decoder.decodeInteger(state, 1)
		mainCharacter.progressPossible = decoder.decodeInteger(state, 1)
		mainCharacter.totalKills = decoder.decodeInteger(state, 2)
		mainCharacter.spec = decoder.decodeString(state, lookup)
		mainCharacter.bestAverage = decoder.decodePercentileFixed(state)

		result.mainCharacter = mainCharacter
	end

	local progressOnly = decoder.decodeBoolean(state)
	result.progressOnly = progressOnly

	if formatVersion == 1 then
		return convertToV1Format(result)
	end

	return result
end
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Unknown-Unknown','Paladin-Retribution','DeathKnight-Unholy','Shaman-Restoration','Shaman-Elemental','Monk-Brewmaster','Monk-Mistweaver','Druid-Restoration','Rogue-Subtlety','Priest-Holy','Warlock-Demonology','DemonHunter-Havoc','DemonHunter-Devourer','Evoker-Preservation','Evoker-Augmentation','Druid-Balance','DeathKnight-Blood',}
local provider = {region='CN',realm='基尔加丹',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alecto:BAAALgAECgkJBwAAAA==.Alolo:BAAALgAECgYJCQAAAA==.',
Am='Amanpushcar:BAAALgAECgcJEAAAAA==.',
Au='Augenstern:BAAALgAECgYJBgAAAA==.',
Ch='Cheesekayee:BAAALgAFFAIJAwAAAA==.',
Ga='Gakki:BAAALgAFFAQJBAAAAA==.',
Gl='Glolo:BAAALgAECgYJBwABLgAECgYJCQABAAAAAA==.',
Gr='Grievous:BAABLgAECn8eAAICAAkJTh9aHADAAgACAAkJTh9aHADAAgAAAA==.',
He='Helo:BAAALgAECgEJAQAAAA==.',
Ho='Hongdie:BAABLgAFFH8JAAIDAAMJSRhZIgAOAQADAAMJSRhZIgAOAQAAAA==.',
Hu='Huangkai:BAAALgAECgUJBwAAAA==.',
Ki='Kimouhunter:BAAALgAECgYJCQAAAA==.',
Ma='Magus:BAAALgAECgUJBQAAAA==.',
Mo='Moira:BAAALgAECgEJAQAAAA==.',
Ni='Nikon:BAAALgAECgcJCQAAAA==.',
Ov='Ovoxovo:BAAALgADCgUJBQAAAA==.',
Pi='Pigeoncn:BAAALgAECgUJBwAAAA==.Pinotnoir:BAAALgAECgkJBwAAAA==.',
Pl='Playerkpozfa:BAAALgADCgEJAQAAAA==.',
Qi='Qiyan:BAAALgAECgMJAwAAAA==.',
Ra='Rayhealme:BAAALgAECgEJAQAAAA==.',
Sa='Saulh:BAAALgAECgkJDwAAAA==.',
St='Steelballrun:BAAALgAECgYJCwAAAA==.',
Ww='Wwhyc:BAAALgADCgYJBgAAAA==.',
Wz='Wzlwow:BAAALgAFFAEJAgAAAA==.',
Ye='Yeacion:BAACLgAFFH8FAAIEAAIJmhqXCgCcAAAEAAIJmhqXCgCcAAAuAAQKfx8AAwQACAm+GWwcADYCAAQACAm+GWwcADYCAAUAAwmFF45fAMUAAAAA.',
Ze='Zekex:BAAALgAECgEJAgAAAA==.',
['一只']='一只格格巫:BAAALgAECgYJDAAAAA==.',
['一煜']='一煜祺一:BAAALgAECgIJAgAAAA==.',
['七音']='七音:BAAALgAECgQJBQAAAA==.',
['不是']='不是虚胖:BAAALgAFFAIJAwAAAA==.',
['不曾']='不曾见过明天:BAAALgAECgkJDgAAAA==.',
['与我']='与我常在:BAAALgAFFAEJAQAAAA==.',
['丫大']='丫大队:BAAALgAECgYJDQAAAA==.',
['丶丶']='丶丶五:BAAALgAFFAQJBAAAAA==.丶丶六:BAAALgAFFAQJBAAAAA==.丶丶四:BAAALgAFFAQJAwAAAA==.',
['丶瞳']='丶瞳话中的晴:BAABLgAFFH8FAAIEAAMJyA/4DwDoAAAEAAMJyA/4DwDoAAAAAA==.',
['九五']='九五冲啊:BAAALgAECgYJBgAAAA==.',
['也不']='也不会比你:BAAALgAECgkJDwAAAA==.',
['二人']='二人季節:BAAALgAECgQJBAAAAA==.',
['五叶']='五叶神:BAAALgADCgEJAQAAAA==.',
['人夫']='人夫:BAAALgAFFAEJAQAAAA==.',
['今天']='今天不打莹仔:BAAALgAECgQJCAAAAA==.',
['代号']='代号灬安普莎:BAAALgADCgEJAQAAAA==.代号灬醉八仙:BAACLgAFFH8KAAIGAAQJ2yDrBACHAQAGAAQJ2yDrBACHAQAuAAQKfxsAAgYACAkDJEsHABADAAYACAkDJEsHABADAAAA.代号灬阿瑞斯:BAAALgAFFAIJAgAAAA==.',
['但丁']='但丁猎魔人:BAAALgAECgUJCQAAAA==.',
['佑铒']='佑铒盯:BAAALgADCgUJCAAAAA==.',
['保护']='保护我家鸽鸽:BAAALgAECgYJBgAAAA==.',
['再怎']='再怎么残酷:BAAALgAFFAIJAgAAAA==.',
['初夏']='初夏夜未央:BAAALgAECgkJCQAAAA==.',
['南方']='南方最南丨魔:BAAALgAECgIJAgAAAA==.',
['卡布']='卡布奇诺:BAAALgAECgQJBAAAAA==.',
['古日']='古日塔嫚之花:BAACLgAFFH8GAAIFAAMJRAgTCADSAAAFAAMJRAgTCADSAAAuAAQKfxoAAwUACQm9Ia8JAPcCAAUACAmDIa8JAPcCAAQAAgnxBRKPAFsAAAEuAAUUBQkDAAEAAAAA.',
['命脉']='命脉:BAAALgAECgcJEQAAAA==.',
['哑巴']='哑巴湖大水怪:BAAALgAECgEJAQAAAA==.',
['唤鼠']='唤鼠师:BAAALgAECgcJEQAAAA==.',
['喜羊']='喜羊羊:BAAALgAECgYJBgABLgAECgcJDQABAAAAAA==.',
['嘉康']='嘉康:BAAALgAECgYJBgAAAA==.',
['困兽']='困兽的星空:BAAALgADCgQJBAAAAA==.',
['国服']='国服第一坤坤:BAAALgAECggJCAAAAA==.国服第一太美:BAAALgAECgIJAgAAAA==.国服第一深情:BAAALgAECgkJDQAAAA==.国服第一爱坤:BAAALgAECggJCAAAAA==.国服第一鸽鸽:BAAALgAECgQJBAAAAA==.国服蔡坤坤:BAAALgAECgIJAgAAAA==.',
['圈圈']='圈圈守护战神:BAAALgAECgIJAgAAAA==.',
['土豆']='土豆不发芽:BAAALgAFFAEJAQAAAA==.',
['地狱']='地狱邪眼师:BAAALgAFFAIJAgAAAA==.',
['堕天']='堕天雨:BAAALgAECgMJBQAAAA==.',
['壹餅']='壹餅:BAAALgADCgEJAQAAAA==.',
['夏末']='夏末未央:BAAALgAFFAEJAgAAAA==.',
['大耳']='大耳朵突突:BAAALgADCgMJBAAAAA==.',
['太阳']='太阳女神:BAAALgAECggJCwAAAA==.',
['如愿']='如愿:BAAALgAFFAEJAQAAAA==.',
['安琪']='安琪儿的微笑:BAAALgAECgQJAwABLgAFFAUJCwAHAKcSAA==.安琪儿的眼泪:BAAALgAECgcJBwAAAA==.',
['宝宝']='宝宝巴士丶:BAAALgAECgQJBAAAAA==.宝宝泡泡:BAAALgAECgYJDwAAAA==.',
['家康']='家康:BAAALgAECgEJAgAAAA==.',
['小学']='小学扛把子:BAAALgAFFAEJAQAAAA==.',
['小彭']='小彭:BAAALgAFFAQJAgAAAA==.',
['小心']='小心剑气:BAAALgAECgMJAwAAAA==.',
['小时']='小时候可靓了:BAAALgAECgkJCQAAAA==.',
['小贼']='小贼猫灬:BAAALgAECgYJDAAAAA==.',
['就打']='就打那个小德:BAAALgAECgUJDQAAAA==.',
['就算']='就算我再:BAAALgAECggJAgAAAA==.',
['尼特']='尼特三三:BAAALgAECgYJDAAAAA==.',
['常世']='常世之暗:BAAALgAECgMJBAAAAA==.',
['庄方']='庄方宜:BAAALgAFFAQJAwAAAA==.',
['廿四']='廿四味:BAABLgAFFH8GAAIIAAMJRxGDCADaAAAIAAMJRxGDCADaAAAAAA==.',
['张飞']='张飞:BAAALgADCgQJBAAAAA==.',
['御魂']='御魂:BAAALgAFFAQJBAAAAA==.',
['微电']='微电机点:BAAALgAECgQJBAAAAA==.',
['德克']='德克萨斯州:BAAALgAFFAIJAgAAAA==.',
['德善']='德善:BAAALgAECgcJEQAAAA==.',
['忆无']='忆无心:BAAALgADCgcJBwAAAA==.',
['怎么']='怎么无情:BAAALgAFFAIJAgAAAA==.怎么无理取闹:BAAALgAECgkJBgAAAA==.',
['性感']='性感小圣杯:BAAALgADCgUJBQAAAA==.',
['怼怼']='怼怼:BAAALgAECgEJAQAAAA==.',
['悠然']='悠然自在心:BAAALgADCgIJAgAAAA==.',
['慢羊']='慢羊羊:BAAALgAECgQJBAABLgAECgcJDQABAAAAAA==.',
['懒羊']='懒羊羊:BAAALgAECgUJBAABLgAECgcJDQABAAAAAA==.',
['我不']='我不爱吃鱼:BAAALgAECgQJCAAAAA==.',
['我好']='我好像迷路了:BAAALgAECgYJBgAAAA==.',
['我是']='我是四脚蛇:BAAALgAECgUJBQAAAA==.',
['我本']='我本灬善人:BAABLgAFFH8KAAIJAAMJ8AZkDwD5AAAJAAMJ8AZkDwD5AAAAAA==.',
['我被']='我被打就会死:BAAALgAECgYJDAAAAA==.',
['拼音']='拼音本:BAAALgADCgcJBwAAAA==.',
['揽雀']='揽雀尾:BAABLgAFFH8JAAIHAAMJ5hPsCgD6AAAHAAMJ5hPsCgD6AAAAAA==.',
['摇摆']='摇摆的呆毛:BAAALgAECgUJCQAAAA==.',
['放牧']='放牧员:BAAALgADCgUJBQAAAA==.',
['星空']='星空之刃:BAAALgAECgkJCQAAAA==.',
['星辰']='星辰不眨眼:BAAALgAFFAIJAgAAAA==.',
['晨一']='晨一曦:BAAALgADCgQJBAAAAA==.',
['暖洋']='暖洋洋:BAAALgAECgcJDQAAAA==.',
['月光']='月光石:BAABLgAFFH8GAAIKAAMJCBMxCADmAAAKAAMJCBMxCADmAAAAAA==.',
['月羽']='月羽风行者:BAAALgAECgYJDQAAAA==.',
['李达']='李达康:BAAALgADCgMJAwAAAA==.',
['来跟']='来跟小烟儿:BAAALgAECgEJAQAAAA==.',
['格格']='格格巫六玥:BAAALgAECgYJBgABLgAFFAQJEwAIADEgAA==.格格武六月:BAAALgADCgUJBQAAAA==.',
['桃宝']='桃宝丶:BAAALgAECgEJAQAAAA==.',
['榜一']='榜一扎昆:BAAALgAECgcJCwAAAA==.',
['樱桃']='樱桃小魔丸:BAAALgAECgUJBQAAAA==.',
['残酷']='残酷的大表哥:BAAALgADCgIJAgAAAA==.',
['毁灭']='毁灭的羊皮纸:BAABLgAFFH8DAAILAAIJDxPCFgCwAAALAAIJDxPCFgCwAAAAAA==.',
['每天']='每天喝两杯:BAAALgAECgQJDAABLgAECgcJDQABAAAAAA==.',
['比比']='比比拉布:BAAALgAECgYJCQAAAA==.',
['沉睡']='沉睡的龙:BAAALgAECgUJCAAAAA==.',
['沐潆']='沐潆翾:BAAALgAECgEJAQAAAA==.',
['沸羊']='沸羊羊:BAAALgAECgIJAgAAAA==.',
['泛滥']='泛滥滴小年轻:BAAALgAECgcJDQAAAA==.',
['流萤']='流萤灬:BAABLgAFFH8GAAIEAAQJXSIWEwDIAAAEAAQJXSIWEwDIAAAAAA==.',
['流风']='流风轻云:BAAALgAECgMJAwAAAA==.',
['清平']='清平乐:BAAALgADCgEJAQAAAA==.',
['火给']='火给他一嘴巴:BAAALgAECgYJBgAAAA==.',
['灿灿']='灿灿:BAAALgAECgYJCwAAAA==.',
['熙小']='熙小格:BAACLgAFFH8LAAICAAMJ5CIcBgAtAQACAAMJ5CIcBgAtAQAuAAQKfyYAAgIACAmUJUAHAF4DAAIACAmUJUAHAF4DAAAA.',
['爱诺']='爱诺:BAAALgAECgQJBAAAAA==.',
['爱迹']='爱迹:BAAALgADCgYJBgAAAA==.',
['版本']='版本答案:BAAALgAECgYJBgAAAA==.',
['狄俄']='狄俄尼索斯:BAAALgAECgMJAwAAAA==.',
['狸沫']='狸沫:BAAALgAECgkJDwAAAA==.',
['玛尔']='玛尔斯:BAAALgAECgYJCwABLgAFFAYJDQACANkZAA==.',
['玛瑙']='玛瑙肥:BAAALgAECgYJBgAAAA==.',
['瓦奥']='瓦奥莱特:BAAALgAECgEJAQAAAA==.',
['痴情']='痴情老伯:BAAALgAFFAMJAwAAAA==.',
['真梅']='真梅扎无双:BAAALgAECgMJAwAAAA==.',
['破灭']='破灭的怀念:BAAALgAECgIJAgAAAA==.',
['硬玩']='硬玩武器:BAAALgAECgQJBQABLgAFFAIJAgABAAAAAA==.',
['磷叶']='磷叶石:BAAALgAFFAEJAQAAAA==.',
['私欲']='私欲乱人心:BAAALgAECgEJAgAAAA==.',
['秋叶']='秋叶为何而落:BAAALgAFFAEJAQAAAA==.',
['秋水']='秋水浮游丶:BAAALgAECgYJBgAAAA==.',
['科场']='科场问:BAAALgAECgYJCQAAAA==.',
['科学']='科学的低语:BAAALgADCgYJBgAAAA==.',
['立秋']='立秋骑:BAAALgADCgcJBgAAAA==.',
['笔笔']='笔笔养鼠惹:BAAALgAECgYJDAAAAA==.',
['笨鸟']='笨鸟也能高飞:BAAALgAFFAIJAwAAAA==.',
['米果']='米果天天开心:BAAALgAECgQJBgAAAA==.',
['米生']='米生花:BAAALgAECgUJBQAAAA==.',
['粤语']='粤语残片:BAAALgAECgQJBAAAAA==.',
['糊糊']='糊糊大魔王:BAAALgADCgEJAQAAAA==.',
['紫鸢']='紫鸢:BAAALgAECgEJAQAAAA==.',
['红头']='红头文件:BAAALgAECgYJBAAAAA==.',
['红岭']='红岭:BAAALgADCgMJAwAAAA==.',
['绝影']='绝影:BAABLgAFFH8IAAMMAAUJ0QkgBgDxAAAMAAMJbwsgBgDxAAANAAUJ0QUAAAAAAAAAAA==.',
['翔地']='翔地天空:BAAALgAECgYJBgAAAA==.',
['能饮']='能饮一杯无:BAAALgADCgMJAwAAAA==.',
['花鸟']='花鸟卷:BAAALgADCgEJAQAAAA==.',
['苍气']='苍气炮:BAAALgAECgYJBgAAAA==.',
['若輪']='若輪回此無悔:BAAALgAECgEJAQAAAA==.',
['英谷']='英谷莉特:BAAALgAECgMJAwAAAA==.',
['茅草']='茅草裂片:BAABLgAECn8XAAMOAAgJZBmqCwB7AgAOAAgJZBmqCwB7AgAPAAMJhRG7SAC0AAAAAA==.',
['萨莉']='萨莉雅:BAAALgAECgEJAQAAAA==.',
['蓝篮']='蓝篮路:BAABLgAECn8nAAIQAAgJ3CCxAQBeAgAQAAgJ3CCxAQBeAgAAAA==.',
['蓝莓']='蓝莓麦酥:BAAALgAECgEJAQAAAA==.',
['蛋蛋']='蛋蛋终结者:BAAALgADCgcJDQAAAA==.',
['蝴蝶']='蝴蝶来了:BAAALgADCgUJBQAAAA==.',
['融化']='融化的一滩水:BAAALgAECgcJBwAAAA==.',
['血兽']='血兽走了:BAAALgAECgcJDAABLgAFFAIJAgABAAAAAA==.',
['装了']='装了逼就跑:BAAALgADCgQJBAAAAA==.',
['貂蝉']='貂蝉在腰上:BAAALgADCgUJBQAAAA==.',
['躺尸']='躺尸老板:BAAALgAECgYJCgAAAA==.',
['轻步']='轻步独徘徊:BAAALgAECgUJBgAAAA==.',
['逆肆']='逆肆:BAAALgAECgUJBQAAAA==.',
['遥远']='遥远辰星:BAAALgADCgUJBQAAAA==.',
['那一']='那一箭的罪恶:BAAALgAECgcJDQAAAA==.',
['银河']='银河星落:BAAALgAECgYJCgAAAA==.',
['阿克']='阿克蒙徳:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔迪米亚:BAAALgAECgEJAgAAAA==.',
['阿牛']='阿牛弟:BAAALgAECgQJBQAAAA==.',
['阿肥']='阿肥:BAABLgAECn8VAAIRAAgJWRnyDQAuAgARAAgJWRnyDQAuAgAAAA==.',
['陈千']='陈千语:BAAALgAFFAMJAgAAAA==.',
['雷切']='雷切:BAAALgAFFAIJBAAAAA==.',
['青埋']='青埋:BAAALgAECgMJAwAAAA==.',
['颜希']='颜希诺丶:BAAALgAECgEJAQAAAA==.',
['风吹']='风吹旗飘扬:BAAALgADCgEJAQAAAA==.',
['风烟']='风烟愺树:BAAALgAFFAIJAwAAAA==.',
['飛龍']='飛龍在地:BAAALgAFFAEJAQAAAA==.',
['香菜']='香菜好好吃:BAAALgAECgUJCQAAAA==.',
['魅皇']='魅皇:BAAALgAECgcJAgAAAA==.',
['鸡脚']='鸡脚:BAAALgAFFAIJAgAAAA==.',
['黑择']='黑择明:BAAALgAFFAEJAQABLgAFFAMJBgAKAAgTAA==.',
['黑魔']='黑魔执事:BAAALgAECgEJAQAAAA==.',
['鼠鼠']='鼠鼠萨满:BAABLgAECn8UAAIEAAgJ7R7hCAC3AQAEAAgJ7R7hCAC3AQAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
