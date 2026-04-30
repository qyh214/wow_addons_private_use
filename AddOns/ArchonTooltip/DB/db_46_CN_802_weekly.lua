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

local lookup = {'Warrior-Fury','Warlock-Demonology','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Druid-Restoration','Druid-Feral','Druid-Balance','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Paladin-Retribution','Warrior-Protection','Shaman-Restoration','Druid-Guardian','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Rogue-Assassination',}
local provider = {region='CN',realm='艾莫莉丝',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Ais:BAAALgAECgcJCwAAAA==.',
Ar='Arilia:BAAALgAECgYJEQAAAA==.',
As='Asffa:BAAALgAECgcJCgAAAA==.Astrogirl:BAAALgAECgUJBQAAAA==.',
Ca='Carrey:BAAALgAFFAQJAgAAAA==.Carryorange:BAAALgAECgcJBwAAAA==.',
Dk='Dkbaba:BAAALgAECgEJAQAAAA==.',
Do='Dolls:BAAALgAECgMJAwAAAA==.',
El='Eleanor:BAAALgAECgMJAwAAAA==.',
Gh='Ghroth:BAABLgAFFH8IAAIBAAQJ1RnaCABiAQABAAQJ1RnaCABiAQAAAA==.Ghrother:BAAALgAFFAQJBAAAAA==.Ghrothsan:BAAALgAFFAQJBAAAAA==.',
Ly='Lylwlw:BAAALgAECgQJBAAAAA==.',
Ma='Mageslayer:BAAALgAECgQJBgAAAA==.',
Mc='Mccree:BAAALgAECgcJDAAAAA==.',
Ne='Neililu:BAAALgAECgIJAgAAAA==.',
Ph='Phunter:BAAALgAECgEJAQAAAA==.',
Pk='Pknight:BAAALgAECgIJAgAAAA==.',
Ri='Ripkobe:BAAALgAECgMJAwAAAA==.',
Ro='Rockydoggy:BAAALgAECgEJAQAAAA==.',
Si='Siacy:BAAALgAECgYJCAAAAA==.',
So='Solitarylin:BAAALgAECgIJAgAAAA==.',
St='Steverogers:BAAALgAECgcJDAAAAA==.Stjimmy:BAAALgAECgQJBwAAAA==.',
Sy='Sys:BAAALgADCgEJAQAAAA==.',
Ti='Timoa:BAAALgAFFAMJAwAAAA==.',
Tp='Tpm:BAAALgAECgIJAgAAAA==.',
Uz='Uzi:BAAALgADCgYJBgAAAA==.',
Xm='Xmm:BAAALgAFFAEJAQAAAA==.',
['一一']='一一萌萌哒:BAAALgAECgYJCwAAAA==.',
['一不']='一不行:BAAALgAFFAEJAQAAAA==.',
['一小']='一小桥流水一:BAAALgAECgMJAwAAAA==.',
['一条']='一条龙那个:BAAALgAECgEJAQAAAA==.',
['一鹿']='一鹿向前:BAAALgAFFAEJAgAAAA==.',
['万物']='万物皆虚:BAABLgAECn8XAAICAAgJURa6OAApAgACAAgJURa6OAApAgAAAA==.',
['三月']='三月三曰:BAAALgADCgUJBQAAAA==.',
['上官']='上官燚遐:BAAALgAFFAMJBAAAAA==.',
['上门']='上门收购剩饭:BAAALgADCgQJBAAAAA==.',
['上霜']='上霜:BAAALgAECgEJAQAAAA==.',
['下关']='下关烧饵块:BAAALgAFFAEJAQAAAA==.',
['东京']='东京的夏天热:BAAALgAECgMJAwAAAA==.',
['丨慕']='丨慕鸢:BAAALgAECgMJAwAAAA==.丨慕鸢丶:BAAALgAECgUJBQAAAA==.',
['丶亻']='丶亻昔口:BAAALgAFFAEJAQAAAA==.',
['丶素']='丶素弦挽流光:BAAALgAECgEJAQAAAA==.',
['丶长']='丶长脚:BAABLgAFFH8FAAMDAAMJ2haKBgCiAAADAAIJsRCKBgCiAAAEAAEJKiOAHQBqAAAAAA==.',
['丶黯']='丶黯:BAAALgAECgcJDAAAAA==.',
['丷天']='丷天若澜丷:BAACLgAFFH8PAAIFAAQJRCFHFwACAQAFAAQJRCFHFwACAQAuAAQKfyIAAgUACAmaJNIWACEDAAUACAmaJNIWACEDAAAA.',
['乌尔']='乌尔奇奥拉:BAAALgADCgEJAQAAAA==.',
['二哥']='二哥:BAAALgAECgYJBgAAAA==.',
['五更']='五更鸢梦丶:BAAALgAECgYJCgAAAA==.',
['人民']='人民当家做主:BAAALgAECgQJBAAAAA==.',
['任性']='任性熊猫:BAAALgAFFAIJBAAAAA==.',
['伊鲁']='伊鲁德变变:BAAALgAECgYJCQAAAA==.',
['依然']='依然殇:BAAALgADCgYJBgAAAA==.',
['假若']='假若时光有眼:BAAALgAFFAEJAQAAAA==.假若时光有限:BAAALgAECgQJBAAAAA==.',
['假装']='假装努力:BAAALgADCgYJBgAAAA==.',
['偏爱']='偏爱邓丽欣:BAAALgAECgEJAgAAAA==.',
['健身']='健身教头:BAAALgAECgYJCwAAAA==.',
['傲视']='傲视魔天下:BAAALgADCgYJBgAAAA==.',
['優秀']='優秀啲玳表:BAAALgADCgMJAwAAAA==.',
['光头']='光头强和熊大:BAAALgAECgQJBQAAAA==.',
['克洛']='克洛斯蒂娜:BAAALgAECgMJAwAAAA==.',
['克里']='克里斯的妈妈:BAAALgAECgYJEgAAAA==.',
['兔斯']='兔斯鸡丶:BAAALgAECgMJAwAAAA==.',
['八尺']='八尺苍月海:BAAALgAECgkJCgAAAA==.',
['六边']='六边形:BAAALgAECgYJBgAAAA==.',
['兰周']='兰周拉面:BAAALgAECgYJBgAAAA==.',
['冻柠']='冻柠茶:BAAALgADCgYJBgAAAA==.',
['刘丶']='刘丶焰心:BAAALgAECgEJAQAAAA==.',
['刘亦']='刘亦菲:BAAALgAECgcJBQAAAA==.',
['初一']='初一滚滚:BAAALgADCgQJBAAAAA==.',
['初春']='初春在鹿野:BAABLgAFFH8IAAIGAAQJ0RpUBwBfAQAGAAQJ0RpUBwBfAQAAAA==.',
['利爪']='利爪之傲:BAACLgAFFH8IAAIHAAQJIg2pAABiAQAHAAQJIg2pAABiAQAuAAQKfxUAAgcACAmbE88KABgCAAcACAmbE88KABgCAAAA.',
['别吵']='别吵:BAAALgAECgYJBwAAAA==.',
['刹风']='刹风:BAAALgAECgkJCQABLgAFFAUJCQAIAAgTAA==.',
['加尓']='加尓鲁什酋长:BAAALgAECgEJAwAAAA==.',
['十一']='十一点睡不着:BAABLgAECn8wAAIGAAcJ9CR9DwC9AgAGAAcJ9CR9DwC9AgAAAA==.',
['十分']='十分爱邓丽欣:BAAALgAECgYJBwAAAA==.',
['卡迪']='卡迪南冥刃:BAAALgAECgEJAQAAAA==.',
['古尔']='古尔亶:BAAALgAFFAIJBAAAAA==.',
['吃肉']='吃肉也吃素:BAAALgAECgEJAQAAAA==.',
['吃饭']='吃饭睡觉:BAAALgAECgkJEwABLgAFFAQJBAAJAAAAAA==.',
['呀丶']='呀丶壁咚:BAAALgAECgUJCAAAAA==.',
['呜啦']='呜啦啦火车笛:BAAALgAECgYJDAAAAA==.',
['周豪']='周豪宇:BAAALgAECgcJCwAAAA==.',
['哈尔']='哈尔扎克:BAAALgADCgUJBQAAAA==.',
['哈弄']='哈弄:BAAALgAECgQJBAAAAA==.',
['哗啦']='哗啦啦哗啦啦:BAAALgAECgEJAQAAAA==.',
['嗳洋']='嗳洋芋:BAAALgAECgIJAgAAAA==.',
['嘟嘟']='嘟嘟丶:BAAALgAECgcJDAAAAA==.',
['圣印']='圣印莲华:BAAALgAECgMJAwAAAA==.',
['圣骑']='圣骑丶龙少丿:BAAALgADCgEJAQAAAA==.',
['在睡']='在睡会:BAAALgAECgQJBAAAAA==.',
['地域']='地域咆哮:BAAALgAECgYJDAAAAA==.',
['坨坨']='坨坨:BAAALgAECgIJAgAAAA==.',
['墨缘']='墨缘再现:BAAALgAECgQJBAAAAA==.',
['墨霖']='墨霖丶:BAAALgADCgUJBQAAAA==.',
['夏弥']='夏弥:BAABLgAECn8ZAAQKAAcJ2QsSHgA+AQAKAAYJ7w0SHgA+AQALAAYJcgEUOACqAAAMAAEJbwFrawAbAAAAAA==.',
['夏沫']='夏沫君临天下:BAAALgADCgcJBwABLgAFFAYJEwANAMggAA==.夏沫小情歌:BAAALgAFFAIJAgAAAA==.',
['夕照']='夕照神灬:BAAALgAECgEJAQAAAA==.',
['多拉']='多拉贡荡斯:BAAALgAECgYJBgAAAA==.',
['夜丨']='夜丨战魂:BAABLgAECn8WAAIOAAYJpQwOJQAWAQAOAAYJpQwOJQAWAQAAAA==.夜丨肥肥:BAAALgAFFAEJAQAAAA==.',
['夜丶']='夜丶青楼:BAAALgADCgIJAgAAAA==.',
['夜月']='夜月残影:BAAALgAECgIJAwAAAA==.',
['夜神']='夜神玥:BAAALgAECgYJDAAAAA==.',
['夜血']='夜血杀:BAAALgAECgUJAgAAAA==.',
['大概']='大概是个汉子:BAAALgAFFAMJBAAAAA==.',
['天使']='天使色心:BAAALgAFFAIJAwAAAA==.',
['天凉']='天凉好个球球:BAAALgAECgUJBwAAAA==.天凉好个酋酋:BAAALgAECgMJAwAAAA==.',
['失误']='失误老鸟:BAAALgAECgYJCQAAAA==.',
['套路']='套路当深情:BAAALgAECgEJAQAAAA==.',
['奥斯']='奥斯汀先生:BAAALgADCgUJBQAAAA==.',
['奥莱']='奥莱瑞娅:BAABLgAECn8cAAIFAAgJ6hnoTgBKAgAFAAgJ6hnoTgBKAgAAAA==.',
['奥露']='奥露希娅:BAAALgADCgUJBQAAAA==.',
['奶白']='奶白色:BAAALgAECgkJAwAAAA==.',
['妖歌']='妖歌灬夏天:BAAALgAECgUJBgAAAA==.',
['娘了']='娘了个舅:BAAALgAECgQJBAAAAA==.',
['孫家']='孫家小娘子:BAAALgADCgEJAQAAAA==.',
['孬氼']='孬氼刂:BAAALgAECgEJAgAAAA==.',
['安婕']='安婕莉娜:BAAALgAECgEJAQABLgAECgIJAgAJAAAAAA==.',
['安琪']='安琪拉粑粑:BAAALgADCgUJBQAAAA==.',
['安由']='安由心生:BAAALgAECgQJBQAAAA==.安由轻轻:BAAALgAECgYJBQAAAA==.',
['宙宙']='宙宙:BAAALgAECgEJAQAAAA==.',
['寂靜']='寂靜喧囂:BAAALgAECgIJAwAAAA==.',
['寻麓']='寻麓:BAAALgAECgQJBAAAAA==.',
['小乐']='小乐意:BAAALgAECgcJAQAAAA==.',
['小子']='小子不要走:BAAALgAFFAIJAwAAAA==.',
['小易']='小易笙:BAAALgAECgYJCwAAAA==.',
['小白']='小白熊猫:BAAALgAFFAEJAQAAAA==.',
['小绿']='小绿皮人:BAAALgAFFAEJAQAAAA==.',
['小羊']='小羊羊早安:BAAALgADCgEJAQAAAA==.',
['小艺']='小艺圣:BAAALgAECgYJEwAAAA==.',
['尤利']='尤利亚:BAAALgADCgEJAQAAAA==.',
['岁杪']='岁杪:BAAALgAECgQJBQAAAA==.',
['巨熊']='巨熊擅长变大:BAAALgAECgYJCgAAAA==.',
['巴拉']='巴拉那:BAAALgADCgQJBAAAAA==.',
['幻夜']='幻夜圣殇:BAAALgAECgIJAgAAAA==.',
['幽香']='幽香小罩子:BAABLgAFFH8GAAIPAAIJ3RePDQClAAAPAAIJ3RePDQClAAAAAA==.',
['异灵']='异灵术:BAAALgAECgQJBQAAAA==.',
['归离']='归离乀:BAAALgAECgUJBQAAAA==.',
['待续']='待续:BAAALgADCgkJCwAAAA==.',
['御心']='御心随风:BAAALgAECgUJCgAAAA==.',
['微微']='微微丶安:BAAALgAFFAIJAgAAAA==.',
['德德']='德德先生:BAAALgADCgYJBgAAAA==.',
['德鲁']='德鲁四:BAAALgADCgIJAgAAAA==.',
['心小']='心小辰:BAAALgADCgEJAQAAAA==.',
['快乐']='快乐风暴:BAAALgAECgUJBQAAAA==.',
['戏脸']='戏脸壳:BAAALgAECgUJBwAAAA==.',
['我不']='我不是小德:BAAALgAFFAEJAQAAAA==.',
['战斗']='战斗牛王:BAAALgAECgQJBAAAAA==.',
['战炮']='战炮:BAAALgADCgIJAgAAAA==.',
['手心']='手心里空空:BAAALgAECgYJCwAAAA==.',
['打完']='打完这把点菜:BAAALgAFFAIJAgAAAA==.',
['折袖']='折袖:BAAALgAECgYJAwAAAA==.',
['披凉']='披凉皮的狼:BAAALgAECgEJAgAAAA==.',
['拂晓']='拂晓丶满尘埃:BAAALgAECgEJAgAAAA==.',
['指尖']='指尖繁华:BAAALgAECgMJAwAAAA==.',
['撒旦']='撒旦:BAAALgAECgYJDAAAAA==.',
['文哥']='文哥哥丶:BAAALgAECgEJAQAAAA==.',
['斜丿']='斜丿刘海:BAAALgAFFAIJBAAAAA==.',
['无夜']='无夜:BAAALgAECgYJBgAAAA==.',
['无聊']='无聊满天:BAAALgAECgEJAQAAAA==.无聊满逐渐:BAAALgAECgEJAgAAAA==.无聊狂人:BAAALgAECgMJAwAAAA==.',
['昊丶']='昊丶:BAAALgAECgUJBQAAAA==.',
['昶冽']='昶冽:BAAALgAECgYJCQAAAA==.',
['显卡']='显卡克星:BAAALgAECgIJAwAAAA==.',
['暗影']='暗影蘑菇:BAAALgAECggJDQAAAA==.',
['暗黑']='暗黑魔阴:BAAALgAECgQJBQAAAA==.',
['暮灬']='暮灬光丶嘉嘉:BAAALgAECgUJAwAAAA==.',
['曼艾']='曼艾尔:BAAALgAECgYJBgAAAA==.',
['最可']='最可爱的人:BAAALgADCgQJBAAAAA==.',
['最爱']='最爱邓丽欣:BAAALgAECgEJAQAAAA==.',
['月神']='月神之箭:BAAALgAECgEJAgAAAA==.',
['月翼']='月翼猫头鹰:BAABLgAFFH8GAAIQAAYJBxGKAAB+AQAQAAYJBxGKAAB+AQAAAA==.',
['有个']='有个水友:BAACLgAFFH8GAAMRAAIJ3RE+FABWAAARAAEJdxQ+FABWAAACAAEJRA8mSgBRAAAuAAQKfx4AAxEACAmRH6YPANQBAAIACAmLH/ktAFUCABEABQm5HqYPANQBAAAA.',
['有時']='有時探戈:BAAALgAECgMJBgAAAA==.',
['术丶']='术丶龙:BAAALgAECgEJAQAAAA==.',
['来两']='来两个杀壹双:BAAALgAECgQJAQAAAA==.',
['枪杆']='枪杆:BAAALgAECgYJBwAAAA==.',
['柒月']='柒月柒:BAAALgAECgEJAQAAAA==.',
['椛天']='椛天狂骨:BAAALgAECgIJAQAAAA==.',
['楽伊']='楽伊梨:BAAALgAECgMJAwAAAA==.',
['橙咖']='橙咖啡:BAACLgAFFH8FAAIQAAIJSAONBgBCAAAQAAIJSAONBgBCAAAuAAQKfxgAAxAACAkfCPEKAJMAAAcABAkPCbEjALgAABAACAlyBPEKAJMAAAAA.',
['残暴']='残暴的小师叔:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛哒:BAAALgAECgYJBgAAAA==.',
['毛胖']='毛胖球:BAAALgAFFAQJBAAAAA==.',
['汤圆']='汤圆儿:BAAALgAFFAEJAQABLgAFFAYJBwADABANAA==.',
['波雅']='波雅丶汉库克:BAAALgAECgQJBwAAAA==.',
['泽芯']='泽芯丶:BAAALgAFFAEJAQAAAA==.',
['洋芋']='洋芋:BAAALgAECgcJBwAAAA==.洋芋殇:BAAALgAECgcJCgAAAA==.',
['浅夏']='浅夏伊人恋花:BAAALgADCgYJBgAAAA==.',
['淘气']='淘气灵儿:BAACLgAFFH8IAAISAAQJzAreCwAvAQASAAQJzAreCwAvAQAuAAQKfyEAAhIACAnuH0gcANUCABIACAnuH0gcANUCAAAA.',
['淡扫']='淡扫娥眉:BAAALgAECgYJDQAAAA==.',
['深海']='深海孤鸿:BAAALgAFFAIJAgAAAA==.',
['温天']='温天仁:BAAALgAECgEJAQAAAA==.',
['漂亮']='漂亮的菊花:BAAALgAECgMJAwAAAA==.',
['漆黑']='漆黑之刃:BAAALgAECgUJBgAAAA==.',
['灬兔']='灬兔子兔灬:BAAALgAFFAIJAgAAAA==.',
['灬果']='灬果子果灬:BAAALgAECgEJAQAAAA==.',
['灬桃']='灬桃子桃灬:BAAALgAECgcJCQAAAA==.',
['灵虚']='灵虚:BAAALgAECgIJAwAAAA==.',
['炮灬']='炮灬皇:BAAALgAECgYJCwAAAA==.',
['無敵']='無敵大坏蛋灬:BAAALgADCgQJBAAAAA==.',
['狐小']='狐小仙儿:BAABLgAFFH8GAAISAAIJIgZZJQCRAAASAAIJIgZZJQCRAAAAAA==.',
['猫筌']='猫筌笙丶:BAAALgAECgEJAQAAAA==.',
['獨領']='獨領風騷:BAAALgAECgQJBAAAAA==.',
['王总']='王总与公主:BAAALgAECgEJAgAAAA==.',
['瑟莉']='瑟莉丝:BAAALgAFFAEJAQAAAA==.',
['番茄']='番茄加西红柿:BAACLgAFFH8RAAMSAAUJphmGCABKAQASAAQJphmGCABKAQATAAEJAAA6GgAzAAAuAAQKfyMAAhIACAmmJBgVAP0CABIACAmmJBgVAP0CAAAA.',
['疯狂']='疯狂圣牛:BAAALgAECgEJAQAAAA==.疯狂的牛儿:BAAALgAFFAIJAwAAAA==.',
['相当']='相当大的冰棍:BAAALgAFFAEJAQAAAA==.',
['看我']='看我发型:BAAALgAECgEJAgAAAA==.',
['真羽']='真羽千夜:BAABLgAECn8UAAISAAYJKRNWiQBuAQASAAYJKRNWiQBuAQAAAA==.',
['睡不']='睡不醒的木偶:BAAALgAECgUJBQAAAA==.',
['瞰簢']='瞰簢烘:BAAALgADCgYJBgAAAA==.',
['确认']='确认完毕:BAAALgAECgYJBgAAAA==.',
['碧萝']='碧萝黄泉:BAAALgAFFAEJAQAAAA==.',
['碳酸']='碳酸饮料拜拜:BAAALgAECgYJBgAAAA==.',
['神仙']='神仙:BAAALgAECgYJCwAAAA==.',
['神戟']='神戟:BAAALgAECgkJEAAAAA==.',
['神罚']='神罚圣焰:BAAALgAECgkJCQAAAA==.',
['离恨']='离恨随风:BAAALgAECgIJAgAAAA==.',
['空山']='空山不见人:BAAALgAECgEJAQAAAA==.',
['竺葵']='竺葵天儿:BAAALgAECgEJAQAAAA==.',
['笨笨']='笨笨芥:BAAALgAECgEJAQAAAA==.',
['第五']='第五贰贰:BAAALgAECgQJBAAAAA==.',
['米椒']='米椒灬:BAAALgAECgQJBAAAAA==.',
['糖果']='糖果守护:BAAALgAECgEJAQAAAA==.',
['絕對']='絕對絕命:BAAALgAECgEJAQAAAA==.',
['红烧']='红烧肉杀手:BAAALgAECgcJAQAAAA==.',
['织鸢']='织鸢丶:BAAALgAECgIJAgAAAA==.',
['经典']='经典兽术:BAAALgAECgEJAQAAAA==.',
['羊仙']='羊仙儿:BAAALgAFFAEJAQAAAA==.',
['羊水']='羊水面包:BAAALgAECgUJBQAAAA==.',
['羞咸']='羞咸纨家:BAAALgADCgEJAgAAAA==.',
['老乄']='老乄费:BAAALgAECgEJAgAAAA==.',
['老张']='老张头:BAAALgAECgUJBgAAAA==.',
['肥膘']='肥膘:BAAALgAECgYJBgAAAA==.',
['艾荦']='艾荦娜:BAAALgADCgEJAQAAAA==.',
['艾达']='艾达丶氺:BAAALgAECgYJBwAAAA==.',
['芃芃']='芃芃:BAAALgAECgQJAwAAAA==.',
['芒果']='芒果酸牛奶:BAAALgAECgEJAQAAAA==.',
['花痴']='花痴大帅比丶:BAAALgADCgYJBgAAAA==.花痴大脸僧丶:BAAALgADCgIJAQAAAA==.花痴大脸叔丶:BAAALgADCgcJCwAAAA==.花痴大脸术丶:BAAALgAECgYJCwAAAA==.',
['茶茶']='茶茶丸:BAAALgAECgYJCAAAAA==.',
['药王']='药王菩萨:BAAALgAFFAQJBAAAAA==.',
['莫得']='莫得伤害:BAAALgAECgQJBAAAAA==.',
['莫法']='莫法批风:BAAALgAECgQJBAAAAA==.',
['藏龙']='藏龙卧虎:BAAALgAECgcJBwAAAA==.',
['蘇曉']='蘇曉:BAABLgAFFH8OAAISAAQJ/A+OGABDAQASAAQJ/A+OGABDAQAAAA==.',
['蛋疼']='蛋疼小公主:BAAALgAECgYJEAAAAA==.',
['袖里']='袖里乾坤:BAAALgAECgUJAgAAAA==.',
['西溪']='西溪吼吼:BAAALgAECgcJBwAAAA==.',
['要啥']='要啥有啥丶:BAAALgADCgEJAQAAAA==.',
['试试']='试试就逝世:BAAALgAECgIJAgAAAA==.',
['起名']='起名字真烦:BAABLgAFFH8HAAINAAMJ/w8VDgD0AAANAAMJ/w8VDgD0AAAAAA==.',
['转身']='转身后微笑:BAAALgAFFAEJAQAAAA==.',
['轻轻']='轻轻舞:BAAALgADCgYJCgAAAA==.',
['这女']='这女人叫小美:BAAALgAECgQJBAAAAA==.',
['这小']='这小鬼有大冰:BAAALgAFFAIJAgAAAA==.',
['通天']='通天巨物:BAAALgAFFAEJAgAAAA==.',
['遇术']='遇术灵疯:BAAALgAECgYJBgAAAA==.',
['部落']='部落尛混子:BAAALgAECgYJCgAAAA==.',
['都别']='都别理我:BAAALgAECgQJBAAAAA==.',
['酷爱']='酷爱耍酷:BAAALgADCgUJBQAAAA==.',
['醉笑']='醉笑浮生:BAAALgAECgQJBwAAAA==.',
['錐苼']='錐苼零:BAAALgADCgEJAgAAAA==.',
['錵天']='錵天狂骨:BAAALgAECgYJEQAAAA==.',
['锅炉']='锅炉房王老汉:BAAALgAECgYJAQAAAA==.',
['长廊']='长廊听雨:BAAALgAECgIJAgAAAA==.',
['阿里']='阿里卡牛:BAAALgAECgQJBwAAAA==.',
['阿鬼']='阿鬼教你电:BAAALgAECgkJBAAAAA==.',
['陆大']='陆大善人:BAAALgAECgkJDgAAAA==.',
['陈丶']='陈丶疯暴烈酒:BAAALgADCgUJBgAAAA==.',
['陈平']='陈平安丶:BAABLgAFFH8GAAIUAAYJJw5EAAAYAgAUAAYJJw5EAAAYAgAAAA==.',
['陌小']='陌小妖:BAAALgAECgEJAQAAAA==.',
['陌麽']='陌麽:BAAALgAECgYJBgAAAA==.',
['难哄']='难哄章若楠:BAAALgAECgIJAwAAAA==.',
['雲溪']='雲溪:BAAALgAECgEJAgAAAA==.',
['零陵']='零陵上将军:BAAALgAECgEJAQAAAA==.',
['雷炮']='雷炮:BAAALgADCgUJBQAAAA==.',
['霹雳']='霹雳小旋风:BAAALgAECgQJCAAAAA==.',
['青丘']='青丘心月:BAAALgAECgkJCQAAAA==.',
['青潇']='青潇潇易水寒:BAABLgAECn8VAAIBAAYJsBotNgDPAQABAAYJsBotNgDPAQAAAA==.',
['青灬']='青灬椒:BAAALgAECgEJAgABLgAECgQJBAAJAAAAAA==.',
['青青']='青青子矜:BAAALgAECgQJBAAAAA==.',
['顶级']='顶级魅魔:BAACLgAFFH8MAAISAAQJERM8FgBLAQASAAQJERM8FgBLAQAuAAQKfxQAAhIACAkAG4E+AD0CABIACAkAG4E+AD0CAAAA.',
['风向']='风向之水瓶:BAAALgAECgIJAgAAAA==.',
['风崖']='风崖:BAAALgAECgYJCAAAAA==.',
['风影']='风影残痕:BAAALgADCgcJBwAAAA==.',
['风竹']='风竹猎影:BAAALgAECgEJAQAAAA==.',
['风雪']='风雪之花:BAAALgADCgEJAQAAAA==.',
['风韵']='风韵犹存:BAAALgAECgEJAwAAAA==.',
['飘逸']='飘逸小猪:BAAALgAECgMJAwAAAA==.',
['餐桌']='餐桌术卷轴:BAAALgAFFAEJAQAAAA==.',
['鲁丨']='鲁丨西西丶:BAAALgAECgYJBQAAAA==.',
['鳕靇']='鳕靇:BAAALgAECgMJAQAAAA==.',
['鹤硬']='鹤硬:BAAALgADCgEJAQAAAA==.',
['麦氪']='麦氪拉斯:BAAALgAECgIJAgAAAA==.',
['黄飞']='黄飞鸿:BAAALgADCgQJBAAAAA==.',
['黑白']='黑白之间:BAAALgAECgQJBQAAAA==.',
['黑鹳']='黑鹳五号:BAAALgAECgYJCgAAAA==.',
['默灬']='默灬爷丶:BAAALgAECgEJAQAAAA==.',
['齐先']='齐先生:BAAALgADCgEJAQAAAA==.',
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
