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

local lookup = {'Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Warrior-Fury','Mage-Frost','Priest-Discipline','Priest-Holy','Unknown-Unknown','Shaman-Restoration','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Restoration','Druid-Balance','DemonHunter-Devourer','Paladin-Retribution','Monk-Windwalker','Monk-Brewmaster','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Vengeance','Rogue-Subtlety','Evoker-Augmentation','Evoker-Devastation','Monk-Mistweaver','DeathKnight-Blood',}
local provider = {region='CN',realm='石爪峰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Addier:BAAALgADCgYJBgAAAA==.',
An='And:BAAALgAECgEJAgAAAA==.',
Ap='Apologizelol:BAAALgAECgcJEAAAAA==.',
Ba='Babychasezz:BAAALgAFFAEJAQAAAA==.Babylikezz:BAACLgAFFH8SAAIBAAUJ/SG0CgCHAQABAAUJ/SG0CgCHAQAuAAQKfxYABAEACAnnHEsnAHQCAAEACAnnHEsnAHQCAAIAAQkAAOoyADcAAAMAAQlsCutvADYAAAAA.',
Bu='Bubbly:BAAALgADCgEJAQAAAA==.',
Dh='Dhqaq:BAAALgAECgcJBwAAAA==.',
Dr='Dragonpriest:BAAALgAECgcJBgABLgAFFAQJCgAEAF0hAA==.',
Dw='Dwake:BAAALgAFFAIJBAAAAA==.',
El='Electronic:BAAALgAECgEJAQAAAA==.Elementoria:BAAALgAECgcJAwAAAA==.',
Gc='Gcherokee:BAAALgAECggJAwAAAA==.',
Ge='Geogosh:BAAALgAECgEJAQAAAA==.',
Gu='Gundamharute:BAABLgAFFH8FAAIFAAIJExjXIwCpAAAFAAIJEhjXIwCpAAAAAA==.',
Hi='Hippy:BAAALgAECgUJCAAAAA==.',
Ho='How:BAAALgADCgQJBAAAAA==.',
Je='Je:BAAALgAECgYJEQAAAA==.',
Jo='Jo:BAAALgAECgIJAwAAAA==.',
Kb='Kbz:BAAALgAECgYJAQAAAA==.',
Ke='Kevvin:BAAALgADCgYJBgAAAA==.',
La='Lamentinn:BAAALgAECgMJBAAAAA==.Laoha:BAAALgAECgEJAQAAAA==.Lau:BAAALgAECgMJAwAAAA==.',
Lm='Lmsii:BAABLgAFFH8SAAIGAAYJUBcoAQD0AQAGAAYJUBcoAQD0AQAAAA==.Lmsiv:BAACLgAFFH8IAAIGAAQJzQ8xCgA8AQAGAAQJzQ8xCgA8AQAuAAQKfxQAAwYABwnEG+ARACcCAAYABwmPG+ARACcCAAcABgkKFWY0AG0BAAAA.Lmsix:BAAALgAFFAQJBAAAAA==.Lmslli:BAABLgAFFH8NAAIGAAUJjQx0AwCJAQAGAAUJjQx0AwCJAQAAAA==.Lmsv:BAABLgAFFH8IAAIGAAQJxw13CgA3AQAGAAQJxw13CgA3AQAAAA==.Lmsvi:BAABLgAFFH8JAAIGAAUJXhRoBACnAQAGAAUJXhRoBACnAQAAAA==.Lmsvii:BAABLgAFFH8MAAIGAAQJxBbICABQAQAGAAQJxBbICABQAQAAAA==.Lmsviil:BAABLgAFFH8PAAIGAAYJSxPxAAAHAgAGAAYJSxPxAAAHAgAAAA==.Lmsx:BAABLgAFFH8PAAIGAAYJRBgHAQABAgAGAAYJRBgHAQABAgAAAA==.Lmsxi:BAACLgAFFH8MAAIGAAQJIhTECABQAQAGAAQJIhTECABQAQAuAAQKfxQAAwYABwmfHKsRACoCAAYABwmfHKsRACoCAAcABgkmDf1EACUBAAAA.',
Lo='Loky:BAAALgAECgMJAgABLgAFFAcJBAAIAAAAAA==.Loveordeath:BAAALgADCgUJBQAAAA==.',
Lr='Lr:BAAALgAECgUJCQAAAA==.',
Lu='Luckymt:BAAALgAECgcJAgAAAA==.',
Mi='Mirajane:BAAALgAECgEJAQAAAA==.',
Ni='Ninetail:BAAALgAECgEJAQAAAA==.',
No='Nov:BAAALgAECgUJAwAAAA==.',
Oo='Ooquantum:BAAALgAECgcJCgABLgAFFAIJBQAFABMYAA==.',
Ra='Rainnineteen:BAAALgAFFAIJAgAAAA==.Rainseventee:BAAALgAFFAIJAgAAAA==.Raintwenty:BAAALgAFFAIJAgAAAA==.',
Re='Rely:BAAALgAECgUJCAAAAA==.',
Si='Sisac:BAAALgAECgYJBgAAAA==.',
St='Starluna:BAAALgAECgQJBwAAAA==.',
Sy='Syven:BAAALgADCgEJAQAAAA==.',
Va='Valor:BAAALgAECgkJCgAAAA==.Vampireh:BAAALgADCgEJAQAAAA==.',
Zi='Ziwu:BAAALgAFFAEJAQAAAA==.',
['一堆']='一堆冰淇淋:BAAALgAECgQJCAAAAA==.',
['一根']='一根都没有了:BAAALgAECgYJBgAAAA==.',
['一粒']='一粒优卡丹:BAAALgAECgYJEwAAAA==.',
['一起']='一起摇摆:BAAALgAECgYJCwAAAA==.',
['万花']='万花一品:BAAALgAFFAIJAgAAAA==.',
['不予']='不予倾城色:BAAALgAECgQJBAAAAA==.',
['东凤']='东凤吟:BAAALgADCgYJBgAAAA==.',
['丨丨']='丨丨口:BAAALgAFFAMJAwAAAA==.丨丨圣光:BAAALgAECgEJAQAAAA==.丨丨萨:BAAALgAFFAIJBAAAAA==.',
['丨圣']='丨圣光丨:BAAALgAFFAEJAQAAAA==.',
['丨猎']='丨猎狩者丨:BAAALgAECgYJCAAAAA==.',
['丨逆']='丨逆袭丨橴灀:BAACLgAFFH8OAAIJAAQJxBerBABCAQAJAAQJxBerBABCAQAuAAQKfxoAAgkACAk3GqAbADsCAAkACAk3GqAbADsCAAAA.',
['丶苏']='丶苏也:BAABLgAECn8VAAIKAAgJqyMJAgC+AgAKAAgJqyMJAgC+AgAAAA==.',
['丶萨']='丶萨菲罗斯:BAAALgAECgYJCQAAAA==.丶萨诺丶:BAAALgADCgMJBQAAAA==.',
['丶飂']='丶飂:BAABLgAFFH8HAAMLAAMJbBuJCQAVAQALAAMJbBuJCQAVAQAMAAEJyg8IJwBOAAAAAA==.',
['丶风']='丶风行者丶:BAAALgAECgQJBAAAAA==.',
['丷筱']='丷筱乄魂:BAAALgADCgcJBwAAAA==.',
['丿大']='丿大雪花丶:BAACLgAFFH8OAAINAAQJYxipCABIAQANAAQJYxipCABIAQAuAAQKfxcAAg0ABwljGpAtAPcBAA0ABwljGpAtAPcBAAAA.',
['丿浮']='丿浮生若梦丶:BAAALgAECgEJAQAAAA==.',
['乘上']='乘上骑下:BAAALgAECgQJBQAAAA==.',
['习武']='习武的必然:BAAALgADCgYJBgAAAA==.',
['乱打']='乱打滚儿:BAAALgAECgEJAQAAAA==.',
['人品']='人品总至上:BAAALgAECgYJBwAAAA==.',
['人生']='人生都太短暂:BAAALgADCgYJCAAAAA==.',
['他二']='他二舅爷啊:BAAALgAECgYJCAAAAA==.',
['令吉']='令吉:BAAALgAECgkJCAAAAA==.',
['伪装']='伪装人类:BAAALgAECggJCAAAAA==.',
['低调']='低调的落幕:BAAALgAECgYJDQAAAA==.',
['你是']='你是我的眼儿:BAAALgAECggJCAAAAA==.',
['你的']='你的莱莱:BAAALgADCgcJBwAAAA==.',
['你臀']='你臀部有只箭:BAAALgADCgUJBQAAAA==.',
['佰年']='佰年术人:BAAALgADCgIJAgAAAA==.',
['保时']='保时:BAAALgADCgQJBAAAAA==.',
['信仰']='信仰不灭:BAAALgADCgcJBwAAAA==.',
['信念']='信念之重量:BAAALgAECgEJAgAAAA==.',
['倚楼']='倚楼迎秋景丶:BAAALgADCgcJDAAAAA==.',
['倾城']='倾城的爱恋:BAAALgAECgUJBQAAAA==.',
['光辉']='光辉的璀璨:BAAALgAECgUJBQAAAA==.',
['入眼']='入眼繁星是你:BAAALgAECgQJDgAAAA==.',
['八零']='八零后女老师:BAAALgADCgYJCwAAAA==.',
['关云']='关云短丶:BAAALgAECgEJAQAAAA==.',
['关公']='关公打搅团:BAAALgAECgMJAwAAAA==.',
['再見']='再見龍門客栈:BAAALgAECgYJCwAAAA==.',
['军团']='军团宅急送:BAAALgAECgYJCAAAAA==.',
['冥影']='冥影:BAAALgAFFAIJAgAAAA==.',
['冥炎']='冥炎疾影:BAAALgAECgEJAQAAAA==.',
['冷月']='冷月葬花魂丷:BAAALgAECgYJBgAAAA==.',
['凌凌']='凌凌七:BAAALgAECgEJAQAAAA==.',
['凡人']='凡人修仙:BAAALgADCgEJAQAAAA==.凡人繁星:BAABLgAFFH8JAAIOAAUJAR2hAwC1AQAOAAUJAR2hAwC1AQAAAA==.',
['出门']='出门骑小龟:BAAALgAECgMJBAAAAA==.',
['刃舞']='刃舞风暴:BAAALgAECgIJAgAAAA==.',
['利威']='利威尔阿克曼:BAAALgAECgcJDAAAAA==.',
['劍無']='劍無惜:BAAALgAECgUJBgAAAA==.',
['加冕']='加冕为亡:BAAALgAECgMJAgAAAA==.',
['勇敢']='勇敢的贝塔:BAACLgAFFH8FAAIKAAIJUhB9QQCeAAAKAAIJUhB9QQCeAAAuAAQKfxcAAgoABwlqG7NSAPkBAAoABwlqG7NSAPkBAAAA.',
['勿抓']='勿抓丶熊宝灬:BAAALgAFFAIJBAAAAA==.',
['十八']='十八子作:BAAALgAECgYJBgAAAA==.',
['十年']='十年灬遇见:BAAALgAECgUJCQAAAA==.',
['十香']='十香软筋散:BAAALgAECgYJCAAAAA==.',
['午夜']='午夜的花裤衩:BAAALgAECggJDwAAAA==.',
['半世']='半世些许情:BAAALgAECgEJAQAAAA==.',
['厉飞']='厉飞雨:BAABLgAFFH8FAAIPAAMJPggpGwCUAAAPAAMJPggpGwCUAAAAAA==.',
['双刀']='双刀流:BAAALgAECgQJBQAAAA==.',
['变相']='变相怪德:BAAALgAECgQJBwAAAA==.',
['叫我']='叫我无名之辈:BAABLgAECn8VAAIEAAkJOgOuIwCTAAAEAAkJOgOuIwCTAAAAAA==.叫我蒙面大虾:BAAALgADCgEJAQAAAA==.',
['可乐']='可乐要加冰:BAAALgAECgIJAgAAAA==.',
['可可']='可可丶星冰乐:BAAALgAECgQJBAAAAA==.',
['台河']='台河大老李:BAABLgAECn8XAAIHAAkJpyE7AABhAwAHAAkJpyE7AABhAwAAAA==.',
['吃人']='吃人:BAAALgADCgUJBQAAAA==.',
['吉哒']='吉哒哒:BAAALgADCgUJBQAAAA==.',
['吉豆']='吉豆豆:BAAALgADCgYJBgAAAA==.',
['听的']='听的见说话:BAAALgAECgYJBgAAAA==.',
['吸财']='吸财大發:BAAALgAECgMJAwAAAA==.',
['咖啡']='咖啡加糖丶:BAAALgAECgIJAgAAAA==.',
['哈吉']='哈吉玉:BAABLgAECn8ZAAIOAAYJLSApBgDDAQAOAAYJLSApBgDDAQAAAA==.',
['唯美']='唯美的堕落:BAAALgAECgUJBgAAAA==.',
['啊姆']='啊姆斯特朗炮:BAAALgAECgYJDAAAAA==.',
['喜码']='喜码拉雅:BAAALgADCgUJBQAAAA==.',
['喝二']='喝二甲基亚砜:BAAALgAECgQJBAAAAA==.',
['嗨灬']='嗨灬二胖:BAAALgAECgcJDwAAAA==.',
['四枫']='四枫院囸一:BAAALgAFFAQJBAAAAA==.四枫院囸五:BAAALgAFFAMJAwAAAA==.四枫院囸八:BAABLgAFFH8JAAIQAAUJgRSdBQBSAQAQAAUJgRSdBQBSAQAAAA==.四枫院囸六:BAAALgAFFAQJBAAAAA==.四枫院夜十:BAAALgAFFAQJBAAAAA==.',
['四毛']='四毛钱的感情:BAAALgADCgEJAQAAAA==.',
['四风']='四风院夜十一:BAAALgAFFAQJBAAAAA==.',
['地狱']='地狱王爵:BAAALgAECgQJCAAAAA==.',
['坚持']='坚持偶像路线:BAAALgAFFAMJBAAAAA==.',
['坠落']='坠落的精灵:BAAALgAECgEJAQAAAA==.',
['塔利']='塔利萨:BAAALgADCgQJAQAAAA==.',
['复笙']='复笙呵呵:BAABLgAFFH8FAAIBAAQJXgadPwCKAAABAAQJXgadPwCKAAABLgAFFAYJDAAKALAgAA==.',
['夏小']='夏小新:BAAALgAECgEJAQAAAA==.',
['夏末']='夏末秋处:BAAALgAECgUJBgAAAA==.',
['夜影']='夜影噬魂:BAABLgAFFH8FAAIBAAIJsRPdMwCrAAABAAIJsRPdMwCrAAAAAA==.夜影魔心者:BAAALgAECgYJBgAAAA==.',
['夢魇']='夢魇追獵者丶:BAAALgAECgYJBgAAAA==.',
['大伙']='大伙丶该睡了:BAAALgADCgIJAgAAAA==.',
['大号']='大号棒棒冰:BAAALgAECgMJAwAAAA==.',
['大杀']='大杀器丶:BAABLgAFFH8GAAIKAAYJBwC9XQAWAAAKAAYJBwC9XQAWAAAAAA==.',
['大核']='大核弹:BAABLgAFFH8IAAIQAAMJLSZ6CgBZAQAQAAMJLSZ6CgBZAQAAAA==.',
['大耳']='大耳朵胡图图:BAAALgADCgMJAwAAAA==.',
['天野']='天野远子:BAACLgAFFH8SAAIQAAYJaB0BAgDyAQAQAAYJaB0BAgDyAQAuAAQKfyAAAhAACQmWJZ0BAMoDABAACQmWJZ0BAMoDAAAA.',
['头普']='头普拉斯:BAAALgADCgMJAwAAAA==.',
['奇迹']='奇迹与你:BAAALgAECgkJCwAAAA==.',
['奥术']='奥术灰烬:BAAALgADCgQJBQAAAA==.',
['女王']='女王丨麵包師:BAAALgADCgQJBgAAAA==.',
['女辅']='女辅助:BAAALgAECgEJAQAAAA==.',
['如沐']='如沐秋风:BAABLgAFFH8FAAIFAAIJowkGRACnAAAFAAIJowkGRACnAAABLgAFFAMJBwAEAIcVAA==.',
['娇小']='娇小菈妮:BAAALgAECgkJCQAAAA==.',
['孑然']='孑然一身:BAAALgAECgEJAQAAAA==.',
['宝贝']='宝贝加油:BAAALgAECgQJCAAAAA==.',
['宫野']='宫野志保:BAABLgAFFH8MAAIGAAQJuh37BgBuAQAGAAQJuh37BgBuAQAAAA==.',
['寂寞']='寂寞奶瓶:BAAALgAECgIJAgAAAA==.',
['射手']='射手就是射手:BAAALgADCgUJBQAAAA==.',
['小三']='小三丨橘子:BAAALgADCgEJAQAAAA==.',
['小乐']='小乐意:BAABLgAFFH8FAAIMAAUJhwnUAgAtAQAMAAUJhwnUAgAtAQAAAA==.',
['小付']='小付大学:BAABLgAFFH8GAAIEAAQJ2hvMCwBFAQAEAAQJ2hvMCwBFAQAAAA==.',
['小可']='小可爱一号:BAAALgAECgQJBgAAAA==.小可莉:BAAALgAECgcJCQAAAA==.',
['小影']='小影:BAAALgADCgUJBQAAAA==.',
['小术']='小术猫猫:BAAALgAECgkJBgAAAA==.',
['小毛']='小毛蛋:BAAALgAECgEJAQAAAA==.',
['小派']='小派蒙:BAAALgAFFAMJAwAAAA==.',
['小然']='小然同学:BAAALgAFFAEJAQAAAA==.',
['小陈']='小陈同学:BAAALgAECgEJAgAAAA==.',
['小霞']='小霞同学:BAAALgAFFAQJBAAAAA==.小霞大学生:BAAALgAFFAMJAwAAAA==.',
['尘海']='尘海:BAAALgAECgYJCgAAAA==.',
['屠尽']='屠尽日寇:BAAALgAFFAQJBAAAAA==.',
['岁岁']='岁岁皆安然:BAAALgADCgUJBQAAAA==.',
['巨黾']='巨黾:BAAALgAECgEJAQAAAA==.',
['巴衞']='巴衞:BAAALgAECgEJAQAAAA==.',
['布衣']='布衣判官:BAABLgAFFH8GAAILAAIJxhCoGAClAAALAAIJxhCoGAClAAAAAA==.',
['布里']='布里啾啾:BAAALgADCgkJEQAAAA==.',
['布鲁']='布鲁克斯西家:BAAALgAECgkJEAAAAA==.',
['幸運']='幸運哥哥:BAAALgAECgMJAwAAAA==.幸運弟弟:BAAALgAECgMJAwAAAA==.',
['彧惑']='彧惑:BAAALgAECgEJAQAAAA==.',
['影舞']='影舞小法:BAAALgAECgYJBAAAAA==.',
['御坂']='御坂美琴酱:BAAALgAECgQJBgAAAA==.',
['御灵']='御灵者挽歌:BAAALgAECgcJBwAAAA==.',
['德卡']='德卡嘉丶月牙:BAAALgADCgEJAQAAAA==.',
['德意']='德意洋洋:BAAALgADCgYJBgAAAA==.',
['德菜']='德菜兼备:BAAALgAECgIJAgAAAA==.',
['心瘾']='心瘾丶:BAAALgAECgcJDAAAAA==.',
['快乐']='快乐的蛐蛐:BAAALgADCgUJBQAAAA==.快乐风牛:BAAALgAECgMJBAAAAA==.',
['怼怼']='怼怼小猪囡:BAABLgAECn8eAAMBAAkJaBlVGQC9AgABAAkJaBlVGQC9AgADAAEJAAAweQAqAAAAAA==.',
['愚灬']='愚灬钝:BAAALgADCgEJAQAAAA==.',
['戏情']='戏情:BAAALgADCgIJAgAAAA==.',
['我神']='我神圣干涉呢:BAABLgAFFH8JAAIQAAQJ7RWaCABsAQAQAAQJ7RWaCABsAQAAAA==.',
['战斗']='战斗爽:BAAALgAECgYJBwAAAA==.',
['打灰']='打灰机的瞌睡:BAAALgAFFAMJAwAAAA==.',
['托尼']='托尼不带水:BAAALgAECgEJAQAAAA==.',
['执手']='执手度年华:BAAALgADCgEJAQAAAA==.',
['拉小']='拉小黑:BAAALgAECgYJCAAAAA==.',
['拔剑']='拔剑问心:BAABLgAFFH8FAAMRAAIJLxT4DwBWAAARAAEJRRj4DwBWAAASAAEJGhCeFQBPAAAAAA==.',
['掂掂']='掂掂低低:BAAALgAECgYJBQAAAA==.',
['提拉']='提拉斯丶佐莫:BAAALgAECgcJCgAAAA==.',
['搓灰']='搓灰姑娘:BAAALgAFFAQJBAAAAA==.',
['摇滚']='摇滚青年:BAABLgAECn8cAAIKAAgJ4iOzCQBPAwAKAAgJ4iOzCQBPAwAAAA==.',
['敖光']='敖光:BAAALgAECgYJCwAAAA==.',
['断雁']='断雁西风:BAAALgAFFAIJBAAAAA==.',
['斯皮']='斯皮尔博哥:BAAALgAECgIJAwAAAA==.',
['斯莫']='斯莫德:BAAALgAFFAQJBAAAAA==.',
['无敌']='无敌小牧童:BAAALgAECgcJEwAAAA==.无敌罗圈胸肌:BAAALgADCgcJBwAAAA==.',
['无法']='无法可依:BAAALgAECgUJBgAAAA==.',
['旺仔']='旺仔牛马:BAAALgAFFAEJAgAAAA==.',
['星辰']='星辰奈姆芙:BAAALgADCgYJBgAAAA==.',
['星野']='星野绮想:BAAALgAECgQJBQAAAA==.',
['星骓']='星骓:BAAALgAECgMJAwAAAA==.',
['春天']='春天的嫩芽:BAABLgAECn8WAAIEAAcJfRSLMQDmAQAEAAcJfRSLMQDmAQAAAA==.',
['是小']='是小德德啊丶:BAAALgAECgYJCgAAAA==.',
['是表']='是表哥呀:BAAALgADCgEJAQAAAA==.',
['晨光']='晨光:BAAALgAECgYJBwAAAA==.',
['普化']='普化天尊挽歌:BAAALgAECgkJBAAAAA==.',
['暗之']='暗之守月:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜魔术师:BAAALgAECgYJBgAAAA==.',
['暴躁']='暴躁白牛:BAAALgAECgQJBAAAAA==.',
['曹一']='曹一贼:BAAALgAECgMJAwAAAA==.',
['曹操']='曹操握的笔:BAAALgAECgUJBQAAAA==.',
['曼波']='曼波:BAAALgADCgUJBQAAAA==.',
['最后']='最后的丶轻语:BAAALgAECgcJAQAAAA==.最后的永恒:BAAALgAECgQJBAAAAA==.',
['月夜']='月夜嘶吼者:BAAALgAECgYJBgAAAA==.',
['月牙']='月牙:BAAALgAECgQJBgAAAA==.',
['有球']='有球庇硬:BAAALgAECgEJBQAAAA==.',
['木大']='木大嫂:BAABLgAFFH8HAAIGAAMJnhwNDAAWAQAGAAMJnhwNDAAWAQAAAA==.',
['未来']='未来有你:BAAALgAFFAMJBAAAAA==.',
['未知']='未知的旋律:BAAALgAECgIJAgAAAA==.',
['末日']='末日之光:BAAALgAECgYJBgAAAA==.末日护佑圣光:BAAALgADCgEJAQAAAA==.末日狂飙:BAAALgADCgIJAgAAAA==.',
['末曰']='末曰风语者:BAAALgADCgEJAQAAAA==.',
['朵朵']='朵朵加糖:BAAALgAECgYJBgAAAA==.',
['李下']='李下不整冠:BAAALgAECgcJCAAAAA==.',
['杰森']='杰森酱:BAABLgAECn8VAAMTAAcJcRGrDgCxAQATAAcJcRGrDgCxAQAEAAEJuRLlngBEAAAAAA==.',
['松软']='松软的小苹果:BAAALgAFFAEJAQAAAA==.',
['林粟']='林粟:BAAALgAECgEJAQAAAA==.',
['果冻']='果冻橙:BAAALgAECgMJAQAAAA==.',
['格魯']='格魯爾:BAAALgAECgIJAgAAAA==.',
['桑梓']='桑梓:BAAALgAECgYJBwAAAA==.',
['梅嘉']='梅嘉斯:BAAALgAECgYJCwAAAA==.',
['棒棒']='棒棒糖灬:BAAALgAECgYJDgAAAA==.',
['棒糖']='棒糖:BAAALgAECgEJAQAAAA==.',
['槑犇']='槑犇丶:BAAALgAFFAQJBAAAAA==.',
['樱之']='樱之:BAAALgAECgcJBwAAAA==.',
['死亡']='死亡之环:BAAALgADCgIJAgAAAA==.死亡公爵:BAAALgAFFAEJAQAAAA==.死亡契约:BAAALgAECgEJAQAAAA==.',
['死魅']='死魅:BAAALgAECgEJAQAAAA==.',
['段幺']='段幺九:BAAALgAFFAEJAQAAAA==.',
['殺手']='殺手皇后:BAAALgAECgcJBgAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8IAAIGAAQJRCByAwCJAQAGAAQJRCByAwCJAQABLgAFFAUJKgAGAP8kAA==.',
['水滴']='水滴:BAAALgADCgMJBgAAAA==.',
['水蜜']='水蜜桃:BAAALgADCgUJBQAAAA==.',
['汽车']='汽车维修员:BAAALgADCggJCAAAAA==.',
['沙丘']='沙丘领主:BAAALgAECgUJBQAAAA==.',
['治愈']='治愈系小太阳:BAAALgAECgUJCAAAAA==.',
['泛泛']='泛泛之辈:BAAALgADCgcJBwAAAA==.',
['津门']='津门小战牛:BAAALgADCgcJBwAAAA==.',
['派特']='派特:BAAALgAECgYJEAAAAA==.',
['浪漫']='浪漫乂尛尛:BAAALgAECgYJBgAAAA==.',
['浮生']='浮生的养父:BAAALgAECgcJCQAAAA==.',
['涅槃']='涅槃灬畅儿:BAAALgAECgkJCQAAAA==.',
['淡如']='淡如雾:BAAALgADCgUJBQAAAA==.',
['深渊']='深渊之血牛:BAAALgAECgQJBwAAAA==.',
['深爱']='深爱某钕子:BAAALgAECgEJAQAAAA==.',
['深蓝']='深蓝星雨:BAAALgAECgEJAgAAAA==.',
['清晨']='清晨的花裤衩:BAAALgAECggJCgAAAA==.',
['滚那']='滚那儿去:BAAALgAECgcJBwAAAA==.',
['潦草']='潦草:BAABLgAFFH8HAAIEAAMJhxW8EAABAQAEAAMJhxW8EAABAQAAAA==.',
['灬刘']='灬刘备灬:BAAALgAECggJBgAAAA==.',
['灬血']='灬血伤次灬灬:BAAALgAECgkJDgAAAA==.',
['灬贰']='灬贰尐爺灬:BAABLgAECn8YAAMUAAYJsx51IQCxAQAUAAUJ8x91IQCxAQAPAAYJuxAncwBLAQAAAA==.',
['灵魂']='灵魂歌颂者:BAAALgAECgEJAgAAAA==.',
['炽天']='炽天使:BAAALgAECgYJCQAAAA==.',
['然灭']='然灭之手:BAAALgAECgcJCwAAAA==.',
['熊灬']='熊灬炮:BAAALgADCgYJBgAAAA==.',
['爸爸']='爸爸后面脏:BAAALgADCgcJBwAAAA==.',
['爹爱']='爹爱吃:BAAALgAECgEJAQAAAA==.',
['爽歪']='爽歪歪丶:BAACLgAFFH8OAAISAAQJ1QzmBgAkAQASAAQJ1QzmBgAkAQAuAAQKfxwAAhIACAm9DZExAI0BABIACAm9DZExAI0BAAAA.',
['牛德']='牛德小:BAAALgAECgEJAQAAAA==.',
['牛蒽']='牛蒽玖:BAAALgAECgEJAQAAAA==.',
['牛霸']='牛霸霸:BAAALgAECgEJAQAAAA==.',
['狂道']='狂道丶:BAAALgAECgEJAgAAAA==.',
['狐仙']='狐仙唲:BAACLgAFFH8FAAIHAAIJwArVDgCHAAAHAAIJwArVDgCHAAAuAAQKfxUAAgcABwkGEtcoAKoBAAcABwkGEtcoAKoBAAAA.',
['狼人']='狼人阿:BAAALgAECgEJAQAAAA==.',
['猫米']='猫米的小术:BAAALgAFFAQJBAAAAA==.',
['王七']='王七:BAAALgAECgIJAgAAAA==.',
['王小']='王小新:BAAALgADCgEJAQABLgAECgEJAQAIAAAAAA==.',
['王老']='王老爷子:BAABLgAFFH8LAAIBAAQJNB4nBgBjAQABAAQJNB4nBgBjAQAAAA==.',
['珂珂']='珂珂奥义:BAAALgAECgEJAgAAAA==.',
['琛丿']='琛丿:BAABLgAFFH8IAAIJAAQJEAeHCwAgAQAJAAQJEAeHCwAgAQAAAA==.',
['甘宁']='甘宁的靴:BAAALgAECgMJAgAAAA==.',
['疯狂']='疯狂的亡师:BAAALgAECgYJDwAAAA==.',
['白人']='白人抹你黑:BAABLgAFFH8HAAINAAMJVAKOFgCtAAANAAMJVAKOFgCtAAAAAA==.',
['白眉']='白眉影王:BAAALgAFFAIJAwAAAA==.',
['白龙']='白龙马是熊猫:BAAALgADCgIJAgAAAA==.',
['目镖']='目镖嘎嘎硬:BAAALgAECgYJEQAAAA==.目镖大炮:BAAALgAECgYJBgAAAA==.目镖学中干:BAAALgAECgYJBwAAAA==.目镖小萨:BAAALgADCgEJAQAAAA==.目镖牛挺大:BAAALgAECgcJDQAAAA==.目镖牛爷爷:BAAALgAECgIJAgAAAA==.目镖骑士:BAAALgAECgMJAwAAAA==.',
['看我']='看我眼神搞事:BAACLgAFFH8NAAIUAAQJ4h++AQCCAQAUAAQJ4h++AQCCAQAuAAQKfxoABBQACAmkIS0GAAYDABQACAmkIS0GAAYDAA8ABAmxD0G3AJgAABUAAQnrHH4nAEoAAAAA.',
['真优']='真优秀:BAABLgAFFH8GAAIBAAMJYgtbJgDmAAABAAMJYgtbJgDmAAAAAA==.',
['社会']='社会好老板:BAAALgAECgkJCQAAAA==.',
['神龙']='神龙胖妹儿:BAAALgAECgEJAQAAAA==.',
['禾汐']='禾汐茉:BAAALgADCgcJBwAAAA==.',
['章魚']='章魚燒:BAAALgAFFAIJAwAAAA==.',
['答案']='答案是你身边:BAAALgADCgcJDAAAAA==.',
['简自']='简自豪:BAAALgADCgUJBQAAAA==.',
['箭来']='箭来:BAAALgAECgkJCQAAAA==.',
['米奈']='米奈希尔余烬:BAAALgADCgYJBgAAAA==.',
['米饭']='米饭丶:BAACLgAFFH8KAAIEAAQJXSHnBQCRAQAEAAQJXSHnBQCRAQAuAAQKfxcAAwQABwnjI5gSALsCAAQABwnjI5gSALsCABMAAQngAzlIACUAAAAA.',
['糖芯']='糖芯宝宝:BAABLgAFFH8NAAILAAQJiguiCAAdAQALAAQJiguiCAAdAQAAAA==.',
['糖门']='糖门郡主:BAAALgAECgEJAQAAAA==.',
['红毛']='红毛丹:BAAALgAECgYJBgAAAA==.',
['约约']='约约:BAAALgADCgMJAwAAAA==.',
['络月']='络月影殇:BAAALgAECgIJAgAAAA==.',
['绿皮']='绿皮专抓圣女:BAAALgAECgMJAwAAAA==.',
['罗将']='罗将神水姬:BAAALgAFFAMJAwAAAA==.',
['美团']='美团战神堑魈:BAAALgAFFAUJAQAAAA==.',
['翻滚']='翻滚的雪球:BAAALgAECgIJAgAAAA==.',
['老虎']='老虎出没:BAAALgAECgQJBgAAAA==.',
['耶梦']='耶梦加得:BAAALgAECgMJBAAAAA==.',
['聖戦']='聖戦舊約:BAAALgAECgkJEAABLgAFFAQJCgAWALkQAA==.',
['肉哼']='肉哼哼:BAAALgADCgEJAQAAAA==.',
['胖大']='胖大海:BAAALgAECgYJBwAAAA==.',
['腿脚']='腿脚相当好:BAAALgAECgUJBQAAAA==.',
['自家']='自家媳妇儿:BAAALgAECgMJAwAAAA==.',
['自然']='自然灵语者:BAAALgAECgYJDAAAAA==.',
['舒犊']='舒犊咩:BAABLgAFFH8IAAIXAAQJVQ9ODAA6AQAXAAQJVQ9ODAA6AQAAAA==.',
['艾丝']='艾丝蔚尔:BAABLgAECn8YAAMGAAcJ4h+9CwB8AgAGAAcJ4h+9CwB8AgAHAAQJYhpfTAAHAQAAAA==.',
['艾俐']='艾俐桑德:BAAALgAECgEJAQAAAA==.',
['节能']='节能主翊:BAABLgAFFH8JAAIXAAMJAh+jDQAmAQAXAAMJAh+jDQAmAQABLgAFFAQJDAAPAFsgAA==.',
['花开']='花开丶伊人在:BAAALgAECgcJCgAAAA==.',
['花灬']='花灬儿:BAAALgAECgYJCQAAAA==.',
['苍曜']='苍曜石:BAAALgAECgYJCQAAAA==.',
['若年']='若年华倒带丶:BAAALgAECgQJBAAAAA==.',
['英雄']='英雄丶求安慰:BAAALgAECgYJBgAAAA==.',
['苹果']='苹果好萌:BAAALgAECgEJAQAAAA==.',
['茉艾']='茉艾拉丶:BAABLgAFFH8HAAIFAAMJxgxIGgDxAAAFAAMJxgxIGgDxAAAAAA==.',
['莉亚']='莉亚灬德琳:BAAALgAECgYJBgAAAA==.',
['菇菇']='菇菇嘎嘎:BAAALgAECgQJCAABLgAFFAQJCQAYABUcAA==.',
['萌萌']='萌萌大领主:BAAALgAECgEJAgAAAA==.萌萌的面:BAABLgAECn8UAAMBAAcJSSPOGgC0AgABAAcJSSPOGgC0AgACAAEJbiO6IgBnAAAAAA==.',
['萧楚']='萧楚河:BAAALgAECgYJBgAAAA==.',
['萨满']='萨满十七号:BAAALgAFFAQJBAAAAA==.萨满十五号:BAABLgAFFH8JAAIJAAUJgwzmAgBzAQAJAAUJgwzmAgBzAQAAAA==.萨满十八号:BAAALgAFFAQJBAAAAA==.萨满十六号:BAABLgAFFH8IAAIJAAQJCxDZBQArAQAJAAQJCxDZBQArAQAAAA==.萨满十四号:BAABLgAFFH8JAAIJAAUJugw+AwBmAQAJAAUJugw+AwBmAQAAAA==.',
['萨空']='萨空:BAAALgAECgEJAQAAAA==.',
['落幕']='落幕繁华丶:BAAALgAFFAMJAwAAAA==.',
['落日']='落日有情:BAAALgAECgIJAgAAAA==.',
['落空']='落空等待:BAAALgADCgEJAQAAAA==.',
['葡萄']='葡萄柚:BAAALgADCgUJBQAAAA==.葡萄汁:BAAALgAECgEJAQAAAA==.',
['蒙恬']='蒙恬握的枪:BAAALgAECgcJDAAAAA==.蒙恬握的笔:BAAALgAECgkJDwAAAA==.',
['虚空']='虚空旅行者:BAAALgADCgMJAwAAAA==.',
['蚂蚁']='蚂蚁捡烟头:BAAALgAECgUJBQAAAA==.',
['褪色']='褪色圣光:BAAALgADCgEJAQAAAA==.',
['西南']='西南偏南:BAAALgAECgcJDgAAAA==.',
['西恩']='西恩饶舌传奇:BAAALgAECgYJBgAAAA==.',
['西瓜']='西瓜不是瓜:BAAALgAECgEJAQAAAA==.',
['说与']='说与山鬼听:BAABLgAECn8YAAIFAAgJzhqSDAAKAgAFAAgJzhqSDAAKAgAAAA==.',
['诸国']='诸国化为火:BAAALgADCgMJBAAAAA==.',
['豆包']='豆包超人:BAAALgAECgEJAQAAAA==.',
['豫星']='豫星物流:BAAALgAECgEJAgAAAA==.',
['贝纳']='贝纳雷娜:BAAALgAECgcJCQAAAA==.',
['贤贤']='贤贤:BAAALgAECggJDwAAAA==.',
['费列']='费列罗巧克力:BAACLgAFFH8JAAMYAAQJFRw5AgBqAQAYAAQJ+Bs5AgBqAQAXAAEJjhnZHgBbAAAuAAQKfxcAAxgACAnnGwsKAD4CABgACAl8GgsKAD4CABcABgkUFpAfAMUBAAAA.',
['赏春']='赏春:BAAALgAECgYJBwAAAA==.',
['超级']='超级法力药水:BAAALgAECgEJAgAAAA==.',
['车名']='车名山秋神:BAABLgAECn8UAAIQAAcJsSHQKgB5AgAQAAcJsSHQKgB5AgABLgAFFAYJEwAQAMggAA==.',
['这个']='这个逗比:BAAALgAECgQJCAAAAA==.',
['追風']='追風箏丶喽啰:BAAALgADCgMJBAAAAA==.',
['逆天']='逆天改命:BAAALgAECgQJCQAAAA==.',
['逐风']='逐风丶戏雨:BAAALgAECgMJBQAAAA==.逐风戏雨:BAAALgAECgUJBQAAAA==.',
['遛鬼']='遛鬼:BAABLgAFFH8HAAIBAAYJCB9pAwCFAQABAAYJCB9pAwCFAQAAAA==.',
['那年']='那年冬至:BAAALgAECgIJAgAAAA==.',
['邪剑']='邪剑龙煞:BAAALgAECgYJCgAAAA==.',
['醉醉']='醉醉红颜:BAAALgAECgYJBgAAAA==.',
['野蛮']='野蛮扛旗德:BAACLgAFFH8KAAIOAAQJQBIjCQBSAQAOAAQJQBIjCQBSAQAuAAQKfxYAAw4ABwnmGkwbACgCAA4ABwnmGkwbACgCAA0ABwnIEgNOAGwBAAEuAAUUBQkLAA4ACAcA.',
['银杏']='银杏化:BAAALgAECgYJCQABLgAFFAEJAgAIAAAAAA==.',
['长翅']='长翅膀的玩家:BAAALgADCgMJAwAAAA==.',
['长长']='长长耳朵:BAAALgAECgQJBAAAAA==.',
['队长']='队长大鲨臂:BAAALgAFFAIJAgAAAA==.',
['阿克']='阿克萌德:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔煞斯:BAAALgADCgIJAgAAAA==.',
['阿帛']='阿帛茨徳:BAAALgAECgEJAQAAAA==.',
['阿德']='阿德菜:BAAALgAECgEJAQAAAA==.',
['陈风']='陈风暴烈酒:BAAALgAECgQJBAAAAA==.',
['隔壁']='隔壁家老舅:BAAALgAECggJEwAAAA==.',
['集合']='集合石犇犇:BAAALgADCgUJBQAAAA==.',
['雨叶']='雨叶凋零:BAAALgADCgIJAgAAAA==.',
['雪妮']='雪妮儿:BAAALgAECgMJAwAAAA==.',
['雪碧']='雪碧大帝:BAAALgAECgQJDAAAAA==.',
['雷霆']='雷霆逐风:BAABLgAECn8UAAIEAAYJKhz3PgCoAQAEAAYJKhz3PgCoAQAAAA==.',
['霍格']='霍格沃兹:BAAALgAECgEJAQAAAA==.',
['霜之']='霜之哀伤:BAAALgAECgMJAwAAAA==.',
['霸者']='霸者艾克斯:BAAALgAECgEJAQAAAA==.',
['靈渡']='靈渡:BAAALgAECgEJAQAAAA==.',
['青春']='青春就是忆:BAAALgAECgEJAgAAAA==.青春骑士:BAAALgAECgEJAQAAAA==.',
['青眼']='青眼白龙丶:BAABLgAFFH8LAAIXAAcJIhonAABQAgAXAAcJIhonAABQAgABLgAFFAgJFgAXAH0HAA==.',
['青衣']='青衣百合:BAAALgAECgMJAwAAAA==.',
['静静']='静静小神龙:BAAALgAECgIJAgAAAA==.',
['韩墩']='韩墩墩:BAACLgAFFH8HAAIRAAQJhCB9AgCOAQARAAQJhCB9AgCOAQAuAAQKfxwAAxEACAk/IywGAB4DABEACAk/IywGAB4DABkABAnRDRhFAMoAAAEuAAUUAwkKAAoARCIA.',
['颖鸢']='颖鸢:BAAALgAECgYJBgAAAA==.',
['风骚']='风骚的小天使:BAAALgAECgYJBwAAAA==.',
['飞吧']='飞吧分钱:BAAALgAECgIJAgAAAA==.',
['飞天']='飞天牛马:BAAALgAECgQJBAAAAA==.',
['飞霄']='飞霄将军:BAAALgAFFAEJAQAAAA==.',
['香橙']='香橙葡萄:BAAALgAECgEJAQAAAA==.',
['香蕉']='香蕉君丶:BAAALgAECgMJAwAAAA==.',
['香辣']='香辣黄花鱼:BAAALgAECgIJAgAAAA==.',
['鬼眼']='鬼眼猎手:BAAALgAECgYJDgAAAA==.',
['魔丶']='魔丶界:BAAALgAECgcJCAAAAA==.',
['魔法']='魔法少女铁蛋:BAAALgAECgYJCAAAAA==.魔法精灵:BAAALgAECgIJAgAAAA==.',
['魔玉']='魔玉:BAACLgAFFH8QAAIaAAQJHBCIBAANAQAaAAQJHBCIBAANAQAuAAQKfyEAAhoACAliGOUEAJwBABoACAliGOUEAJwBAAAA.',
['魚肚']='魚肚白:BAAALgADCgEJAQAAAA==.',
['鸡肉']='鸡肉卷:BAAALgAECgYJDwAAAA==.',
['麻辣']='麻辣兔头哎:BAAALgAECgIJAgAAAA==.',
['麻酱']='麻酱丶:BAABLgAECn8UAAMBAAkJ/xQKCAASAgABAAgJ/xQKCAASAgACAAEJAACIJwBTAAAAAA==.',
['麻麻']='麻麻辛芷蕾:BAAALgAECgEJAQAAAA==.',
['黄瓜']='黄瓜娃娃丶:BAAALgAECgEJAgAAAA==.',
['黯刃']='黯刃:BAAALgADCgIJAgAAAA==.',
['龟男']='龟男:BAAALgAECgUJBQAAAA==.',
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
