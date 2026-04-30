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

local lookup = {'DeathKnight-Unholy','Unknown-Unknown','Shaman-Restoration','Mage-Frost','Druid-Restoration','Hunter-BeastMastery','Paladin-Retribution','Monk-Brewmaster',}
local provider = {region='CN',realm='爱斯特纳',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aimee:BAAALgAECgIJAgAAAA==.',
Be='Benevolent:BAAALgADCgUJBQAAAA==.',
Bl='Blem:BAAALgAFFAMJBAAAAA==.',
By='Byun:BAAALgADCgIJAQAAAA==.',
Cr='Crusingnst:BAAALgAECgEJAQAAAA==.Crusuingnst:BAAALgAECgEJAgAAAA==.',
En='Envystar:BAAALgADCgcJBwAAAA==.',
Hi='Hisense:BAAALgAECgYJCQAAAA==.',
It='Itaeyeon:BAAALgAECgEJAwAAAA==.',
Ju='Justmagic:BAAALgAECgMJBgAAAA==.',
La='Lacy:BAAALgAECgEJAQAAAA==.',
Ll='Ll:BAAALgAFFAEJAQAAAA==.',
Ly='Lypj:BAAALgAECgIJAgAAAA==.',
Sk='Skullheart:BAABLgAECn8bAAIBAAgJSSONIgC1AgABAAgJSSONIgC1AgAAAA==.',
Sp='Spy:BAAALgAECgQJBAAAAA==.',
Va='Vanel:BAAALgAECgYJDwAAAA==.',
['一忘']='一忘皆空:BAAALgAFFAIJBAAAAA==.',
['一毛']='一毛丶:BAAALgAECgIJAgAAAA==.',
['一角']='一角:BAAALgAECgcJDgABLgAECgkJDwACAAAAAA==.',
['丁哥']='丁哥来咯:BAAALgAECgEJAQAAAA==.',
['万俟']='万俟丰:BAAALgADCgEJAQAAAA==.',
['三花']='三花小卷:BAAALgAECgcJCwAAAA==.',
['上班']='上班咯:BAAALgAECgIJAgABLgAFFAEJAQACAAAAAA==.',
['不铛']='不铛牛马熊:BAAALgAFFAEJAQAAAA==.',
['专职']='专职狩猎:BAAALgADCgIJAgAAAA==.',
['两开']='两开花:BAAALgAECgEJAQAAAA==.',
['丶浮']='丶浮生未歇:BAAALgADCgEJAQABLgAFFAQJBAACAAAAAA==.',
['丶西']='丶西北风丶:BAAALgADCgYJBgAAAA==.',
['丶陈']='丶陈老师:BAAALgADCgUJBQAAAA==.',
['丷烽']='丷烽火连城丷:BAAALgAFFAEJAQAAAA==.',
['仔仔']='仔仔:BAAALgAECgUJDgAAAA==.',
['伊丷']='伊丷利丹:BAAALgAECgYJBwAAAA==.',
['伊洛']='伊洛斯暗誓者:BAAALgADCgEJAQAAAA==.',
['会飞']='会飞的小胖:BAAALgAECgcJBwAAAA==.会飞的小胖子:BAAALgAECgcJBwAAAA==.',
['似水']='似水飘零小号:BAAALgADCgMJAwAAAA==.',
['你幸']='你幸运的:BAAALgAECgQJBAAAAA==.',
['依然']='依然丶不舒服:BAAALgAECgEJAQAAAA==.依然丶打谁呀:BAAALgADCgIJAgAAAA==.',
['侠肠']='侠肠无医:BAAALgAECgYJBgAAAA==.',
['俏无']='俏无双:BAAALgAECgYJCQAAAA==.',
['倒楣']='倒楣蛋:BAAALgAECgYJBgAAAA==.',
['光铸']='光铸德莱妮:BAAALgAECgMJAwAAAA==.',
['冰蝕']='冰蝕:BAAALgADCgUJBQAAAA==.',
['努力']='努力长高:BAAALgAECgYJDAAAAA==.',
['千年']='千年那天:BAAALgAECgIJAgAAAA==.',
['半夜']='半夜爱起床:BAAALgAECgcJBwAAAA==.',
['半盏']='半盏流年:BAAALgADCgYJBgAAAA==.',
['卡罗']='卡罗尔:BAAALgAFFAQJBAAAAA==.',
['卷毛']='卷毛威震天:BAAALgAECgcJBwAAAA==.',
['去死']='去死不取名:BAAALgADCgEJAQAAAA==.',
['古因']='古因达鲁:BAAALgAECgYJCAAAAA==.',
['古而']='古而单:BAAALgAECgYJBwAAAA==.',
['叶如']='叶如秋:BAAALgADCgYJBwAAAA==.',
['咕噜']='咕噜咕噜圈圈:BAAALgADCgQJBAAAAA==.',
['困兔']='困兔兔:BAAALgAECgkJDwAAAA==.',
['圣光']='圣光大忽悠:BAABLgAECn8UAAIBAAcJRRG5cgCiAQABAAcJRRG5cgCiAQAAAA==.',
['圣狄']='圣狄亚之牧:BAAALgAECgYJBgAAAA==.圣狄亚小黑子:BAAALgAECgYJDQAAAA==.',
['垂天']='垂天:BAAALgAECgIJAgAAAA==.',
['埃蒙']='埃蒙的跳虫:BAAALgADCgQJBAAAAA==.',
['夜雨']='夜雨声煩:BAAALgAECgIJAgAAAA==.',
['夜风']='夜风冷雨:BAAALgAECgUJCwAAAA==.',
['大象']='大象来了:BAAALgADCgkJCQAAAA==.',
['天兵']='天兵神折:BAAALgAECgQJBAAAAA==.',
['天边']='天边的云:BAAALgAECgYJCAAAAA==.',
['奥暖']='奥暖酱:BAACLgAFFH8FAAIDAAMJnxueCQCwAAADAAMJnxueCQCwAAAuAAQKfxYAAgMABwkTGSUqAOUBAAMABwkTGSUqAOUBAAAA.',
['妈妈']='妈妈不让说:BAAALgAECgIJAgAAAA==.',
['姜明']='姜明子:BAAALgAECgYJCgAAAA==.',
['姿色']='姿色飞扬:BAAALgAECgYJDAAAAA==.',
['嫉妒']='嫉妒她的飞:BAAALgADCgYJBgAAAA==.',
['安沐']='安沐拜艾克:BAAALgAECgYJBgAAAA==.',
['小仙']='小仙桃:BAABLgAFFH8OAAIEAAQJnQwuHwBMAQAEAAQJnQwuHwBMAQAAAA==.',
['小小']='小小可:BAAALgAECgQJBQAAAA==.',
['小德']='小德儿:BAAALgADCgcJBwAAAA==.',
['小淘']='小淘气:BAAALgADCgIJAgAAAA==.',
['小溅']='小溅德:BAAALgADCgQJBAAAAA==.',
['小熊']='小熊软糖:BAACLgAFFH8KAAIFAAQJmRopBwBhAQAFAAQJmRopBwBhAQAuAAQKfxsAAgUACAkiH5wRAKoCAAUACAkiH5wRAKoCAAAA.',
['小貮']='小貮:BAAALgAECgYJDgAAAA==.',
['小雨']='小雨雨:BAAALgAECgcJDQAAAA==.',
['小马']='小马僧:BAAALgAFFAEJAQAAAA==.小马萨:BAABLgAFFH8PAAIDAAQJ8SQdAwCpAQADAAQJ8SQdAwCpAQAAAA==.',
['庄生']='庄生大萌:BAAALgADCgUJBQAAAA==.',
['微泛']='微泛波澜:BAAALgAECgEJAQAAAA==.',
['心心']='心心零:BAAALgAECgYJDQAAAA==.',
['快乐']='快乐随心:BAAALgAECgEJAgAAAA==.',
['恐惧']='恐惧之裤:BAAALgAECgYJCQAAAA==.',
['恶魔']='恶魔遇遇:BAAALgAECgkJCQAAAA==.',
['悠然']='悠然骑士:BAAALgAECgMJAwAAAA==.',
['慕婉']='慕婉芯:BAAALgAECgIJAgAAAA==.',
['懿莘']='懿莘:BAAALgADCgEJAQAAAA==.',
['戍卒']='戍卒之役:BAABLgAECn8UAAIGAAYJdA2gXgBMAQAGAAYJdA2gXgBMAQAAAA==.',
['我只']='我只吃素:BAAALgADCgIJAwAAAA==.',
['我很']='我很潮湿:BAAALgAECgQJBQAAAA==.',
['我是']='我是鱼鹅:BAAALgAECgcJDQAAAA==.',
['我自']='我自凡尘过:BAAALgAFFAEJAQAAAA==.',
['挣钱']='挣钱给小猪花:BAAALgAECgQJAwAAAA==.',
['新垣']='新垣綾瀨:BAAALgAECgUJCQAAAA==.',
['无敌']='无敌的仔仔:BAAALgADCgcJBwAAAA==.',
['无聊']='无聊大师:BAAALgADCgYJBgAAAA==.',
['无能']='无能的丈夫:BAAALgAFFAEJAQAAAA==.',
['星斑']='星斑巨熊:BAAALgAECgYJCQABLgAFFAEJAQACAAAAAA==.',
['昨夜']='昨夜风雨:BAAALgAECgQJBAAAAA==.',
['李七']='李七夜:BAAALgAECgYJBwAAAA==.',
['杰斯']='杰斯特冲锋:BAABLgAFFH8GAAIBAAIJfRwpOACrAAABAAIJfRwpOACrAAAAAA==.',
['桂妮']='桂妮薇尔:BAAALgAECgcJBwAAAA==.',
['梓旭']='梓旭:BAABLgAFFH8IAAIBAAQJhhj4EABdAQABAAQJhhj4EABdAQAAAA==.',
['橙色']='橙色长鼻象:BAAALgAECgEJAQAAAA==.',
['武動']='武動丨乾坤:BAAALgADCgEJAQAAAA==.',
['死神']='死神的意志:BAAALgAECgcJDgAAAA==.',
['水清']='水清刘亦菲:BAAALgAECgUJBQAAAA==.',
['永恒']='永恒的三哥:BAAALgAECgQJAwAAAA==.',
['江北']='江北小鸡:BAAALgADCgcJDwAAAA==.',
['池波']='池波星辉:BAAALgADCgcJBwAAAA==.',
['汤圆']='汤圆:BAAALgAECgYJCgAAAA==.',
['没用']='没用的东西:BAAALgAECgcJCAAAAA==.',
['法神']='法神:BAAALgAECgQJBAAAAA==.',
['浪丶']='浪丶沸儿:BAAALgAECgcJEwAAAA==.',
['海潮']='海潮贤者托斯:BAAALgADCgYJCQAAAA==.',
['湛蓝']='湛蓝玫瑰:BAAALgAECgYJDwAAAA==.',
['灬星']='灬星矢灬:BAAALgADCgYJBgAAAA==.',
['灬瓦']='灬瓦里安灬:BAAALgAECggJDAAAAA==.',
['爆雨']='爆雨梨花:BAAALgAECgEJAQAAAA==.',
['爱莉']='爱莉杏菜:BAABLgAFFH8IAAIBAAQJoxqoCgB9AQABAAQJoxqoCgB9AQAAAA==.',
['狂派']='狂派丶炎龙:BAAALgAECgYJBwAAAA==.',
['百变']='百变小德:BAAALgAECgYJBgAAAA==.',
['皇枫']='皇枫灬秀:BAAALgAECgYJBgAAAA==.',
['皮卡']='皮卡皮卡秋儿:BAAALgAECgQJBQAAAA==.',
['看看']='看看这是谁:BAAALgADCgQJBAAAAA==.',
['看那']='看那东风:BAAALgAECgEJAQAAAA==.',
['神圣']='神圣的小胖:BAAALgAFFAQJBAAAAA==.',
['程黑']='程黑妞:BAAALgAECgEJAQAAAA==.',
['粉屈']='粉屈:BAACLgAFFH8IAAIHAAQJixROCQBjAQAHAAQJixROCQBjAQAuAAQKfxgAAgcABwkAJF8cAMACAAcABwkAJF8cAMACAAAA.',
['粤青']='粤青岩:BAAALgADCgUJBQAAAA==.',
['绿山']='绿山:BAAALgADCgUJBQAAAA==.',
['缅因']='缅因:BAAALgADCgYJBgAAAA==.',
['老婆']='老婆辛苦了:BAAALgAECgkJCAAAAA==.',
['老馒']='老馒头:BAAALgAECgUJBQAAAA==.',
['至暗']='至暗之夜:BAAALgADCgYJBwAAAA==.',
['艾尔']='艾尔特斯:BAAALgAECgIJAgAAAA==.',
['艾文']='艾文:BAAALgAECgQJBQAAAA==.',
['艾雯']='艾雯:BAAALgAECgIJAgAAAA==.',
['苍龍']='苍龍七宿:BAAALgAECgYJDQAAAA==.',
['苏打']='苏打水:BAAALgAECgYJDgAAAA==.',
['若癫']='若癫若狂:BAAALgAECgEJAQAAAA==.',
['莉娅']='莉娅徳琳:BAAALgADCgYJBgAAAA==.',
['莯浴']='莯浴阳光:BAAALgADCgUJBQAAAA==.',
['萬物']='萬物皆被和諧:BAAALgADCgQJBAAAAA==.',
['蓤薍']='蓤薍:BAAALgAECgkJCQAAAA==.',
['虎乸']='虎乸:BAAALgADCgYJCQAAAA==.',
['蝶忆']='蝶忆灬绽放:BAAALgAECgMJBAAAAA==.',
['西凉']='西凉河小米:BAAALgAECgQJBAAAAA==.',
['西瓜']='西瓜籽儿:BAAALgADCgcJBwAAAA==.',
['论如']='论如何喷肺火:BAAALgAECgMJBAABLgAECgUJCgACAAAAAA==.',
['走地']='走地鸡:BAAALgAFFAIJAwAAAA==.',
['跑题']='跑题大王:BAAALgAECgUJCgAAAA==.',
['踢你']='踢你两脚:BAAALgADCgUJCgAAAA==.',
['長崎']='長崎素世:BAAALgAECgEJAQAAAA==.',
['长渆']='长渆刚:BAAALgADCgEJAQAAAA==.',
['陳丶']='陳丶風暴烈酒:BAABLgAECn8UAAIIAAgJ+BPvCQBRAQAIAAgJ+BPvCQBRAQAAAA==.',
['雨宫']='雨宫莲:BAAALgAECgUJBAAAAA==.',
['雪域']='雪域风云:BAAALgADCgMJAgAAAA==.',
['非洲']='非洲美女:BAAALgAECgUJDgAAAA==.',
['风中']='风中的叹息:BAAALgAECgEJAQAAAA==.',
['风之']='风之冰霜:BAAALgAECgEJAQAAAA==.风之语灬星眸:BAAALgADCgUJAQAAAA==.',
['风暴']='风暴烈酒仔仔:BAAALgAECgYJCgAAAA==.',
['风灵']='风灵月影:BAAALgAFFAIJAgAAAA==.',
['馒头']='馒头:BAAALgADCgIJBAAAAA==.',
['香烟']='香烟吥离手:BAAALgAECgEJAQAAAA==.',
['魔界']='魔界玄武:BAAALgAECgEJAgAAAA==.',
['黑色']='黑色的小象:BAAALgAECgEJAQAAAA==.',
['黑风']='黑风岭的猎户:BAAALgADCgEJAQAAAA==.',
['齊天']='齊天胖墩:BAAALgADCgYJCAAAAA==.',
['龙城']='龙城飞将:BAAALgADCgMJAwAAAA==.',
['龙宝']='龙宝唉:BAAALgAECgYJCwAAAA==.',
['龙龙']='龙龙哦死骑:BAAALgADCgUJBQAAAA==.',
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
