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

local lookup = {'Paladin-Retribution','Unknown-Unknown','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Unholy','Mage-Frost','Monk-Brewmaster','Paladin-Protection','Druid-Balance','Shaman-Restoration','Priest-Holy','Priest-Discipline','Monk-Windwalker','Monk-Mistweaver','Warrior-Fury','Rogue-Subtlety','DemonHunter-Devourer','DemonHunter-Havoc',}
local provider = {region='CN',realm='刺骨利刃',name='CN',type='weekly',zone=46,date='2026-04-25',data={Af='Afdjhl:BAABLgAFFH8JAAIBAAMJbSDyDwAnAQABAAMJbSDyDwAnAQAAAA==.',
Am='Amacat:BAAALgADCgYJBgAAAA==.',
An='Andrabelia:BAAALgAFFAQJBAAAAA==.',
Ay='Ayije:BAAALgADCgYJBgABLgAFFAYJAQACAAAAAA==.',
Cc='Ccrazy:BAABLgAFFH8HAAIDAAMJtB64BwAnAQADAAMJtB64BwAnAQAAAA==.',
Cl='Clince:BAAALgAECggJCAAAAA==.',
De='Delics:BAAALgADCgEJAQAAAA==.',
Do='Dollar:BAAALgADCgUJBQAAAA==.',
El='Elohims:BAAALgAECgUJBwAAAA==.',
Er='Eriol:BAAALgAFFAEJAgAAAA==.',
Gi='Gianfilippo:BAAALgAFFAEJAQAAAA==.',
Ha='Happenis:BAAALgAFFAEJAgAAAA==.',
Ho='Holylight:BAAALgAECgMJAwAAAA==.',
Il='Illusionika:BAAALgAECgYJDAAAAA==.',
Je='Jetaimelock:BAAALgAECgEJAQAAAA==.Jetaimeun:BAAALgAECgUJBQAAAA==.',
La='Lanbao:BAAALgAFFAIJAwAAAA==.',
Li='Lightmare:BAAALgAECgYJBwAAAA==.',
Lo='Lonely:BAAALgADCgcJCQAAAA==.',
Ma='Marleiarlee:BAABLgAECn8WAAMEAAgJ3R20MQBFAgAEAAcJ3R20MQBFAgAFAAIJHRKlTACHAAAAAA==.',
Mi='Mirage:BAAALgAFFAIJAgAAAA==.',
Mo='Monstr:BAAALgADCgYJCgAAAA==.',
Ni='Nishuo:BAAALgAFFAIJBAAAAA==.',
Nu='Nuclear:BAAALgAFFAIJAwAAAA==.',
Ol='Oliverquinn:BAAALgAECgYJCAAAAA==.',
Pa='Palatinus:BAAALgAECgEJAQAAAA==.',
Pe='Persephone:BAAALgADCgEJAQAAAA==.',
Pl='Playerxdlvys:BAAALgAECgEJAQAAAA==.Playerxjjkwf:BAAALgADCgYJCwAAAA==.',
Se='Seaxuan:BAAALgAECgQJBgAAAA==.',
Sh='Shinning:BAAALgAECgIJAgAAAA==.',
['一依']='一依然逆风一:BAABLgAECn8XAAMGAAkJ3x9tBAAFAwAGAAkJ3x9tBAAFAwAHAAgJXhj3WwDeAQAAAA==.',
['一月']='一月黑风高一:BAACLgAFFH8JAAIIAAUJWyUTBAAwAgAIAAUJWyUTBAAwAgAuAAQKfykAAggACQnWJiYAAA8EAAgACQnWJiYAAA8EAAAA.',
['一枕']='一枕清风:BAAALgAECgQJBAAAAA==.',
['一点']='一点寒芒后到:BAAALgAECgUJCQAAAA==.',
['一生']='一生何求:BAAALgAECgQJBAAAAA==.',
['一黯']='一黯稥一:BAAALgAECgIJAgAAAA==.',
['七只']='七只南南:BAAALgAECgYJCwAAAA==.',
['上海']='上海豪门:BAAALgADCgMJAwAAAA==.',
['不能']='不能太长:BAAALgADCgEJAQAAAA==.',
['丨岚']='丨岚丨:BAAALgAECgYJBgAAAA==.',
['丶血']='丶血色玫瑰:BAAALgAECgEJAQAAAA==.',
['丹霞']='丹霞赫冲:BAAALgAECgYJCgAAAA==.',
['为叔']='为叔者萌也:BAAALgAECgQJBwAAAA==.',
['乌瑟']='乌瑟尔丶神明:BAAALgAECgYJCAAAAA==.',
['乖啵']='乖啵啵:BAAALgAFFAIJAgAAAA==.',
['乱舞']='乱舞的旋律:BAAALgAECgMJAwAAAA==.',
['云柒']='云柒:BAAALgAECgUJBQAAAA==.',
['今夜']='今夜我很乖:BAAALgADCgUJBQAAAA==.',
['从小']='从小就亮:BAAALgADCgUJBQAAAA==.从小就慢:BAAALgAECgEJAQAAAA==.从小就懵:BAAALgAFFAIJAwAAAA==.',
['休丶']='休丶杰克曼:BAAALgAECgUJCAAAAA==.',
['伯瓦']='伯瓦尔丶神明:BAAALgAECgYJCgAAAA==.',
['倦乀']='倦乀涩:BAAALgAECgEJAQAAAA==.',
['假象']='假象灬:BAAALgAECgEJAQAAAA==.',
['克里']='克里斯提娜丶:BAAALgADCgYJBgAAAA==.',
['冥渊']='冥渊:BAABLgAFFH8FAAIJAAIJVBcsGgCZAAAJAAIJVBcsGgCZAAAAAA==.',
['冰影']='冰影丶:BAABLgAECn8WAAIIAAcJsgzJqgCFAQAIAAcJsgzJqgCFAQAAAA==.',
['冰霜']='冰霜死骑:BAAALgAECgYJCAAAAA==.',
['冲锋']='冲锋屁屁:BAAALgAECgEJAgAAAA==.',
['凌霄']='凌霄:BAAALgAECgEJAQAAAA==.',
['凛冬']='凛冬未眠:BAAALgAECgYJDAAAAA==.',
['凯诶']='凯诶撒思:BAAALgAECgUJBgAAAA==.',
['刘玄']='刘玄德:BAAALgAFFAEJAQAAAA==.',
['刹那']='刹那:BAAALgAFFAIJAgAAAA==.刹那雪音:BAAALgAFFAIJAwAAAA==.',
['剎那']='剎那丶:BAAALgAFFAIJAwAAAA==.剎那灬:BAAALgAECgYJCQAAAA==.',
['勇敢']='勇敢小德:BAAALgADCgEJAQAAAA==.勇敢熊熊:BAAALgADCgEJAQAAAA==.',
['千云']='千云千月:BAAALgADCgEJAQAAAA==.',
['半夏']='半夏小银:BAAALgAECgEJAQAAAA==.',
['半岛']='半岛铁盒:BAAALgAECgIJAgAAAA==.',
['南风']='南风知我忆:BAAALgAECgUJBgAAAA==.',
['卡丹']='卡丹尼尔:BAAALgAECgEJAQAAAA==.',
['卡特']='卡特玲娜:BAAALgAFFAEJAQABLgAFFAMJCAAKACsLAA==.',
['叫啥']='叫啥来的:BAAALgAECgMJAwAAAA==.',
['叮叮']='叮叮当当小妈:BAAALgAECgcJBwAAAA==.',
['吃鱼']='吃鱼的猫猫:BAAALgAECgEJAgAAAA==.',
['咸鱼']='咸鱼大王:BAAALgAECgIJAgAAAA==.',
['唔噗']='唔噗噗:BAAALgADCgMJAgAAAA==.',
['啦丶']='啦丶啦:BAAALgAECgYJAwAAAA==.',
['喝真']='喝真酒打假拳:BAABLgAFFH8FAAIJAAMJmgFUGQCgAAAJAAMJmgFUGQCgAAAAAA==.',
['嘿嘿']='嘿嘿丶咻咻:BAAALgAECgYJBgAAAA==.',
['囯产']='囯产零零久:BAAALgAFFAEJAgAAAA==.',
['国产']='国产零零久:BAAALgAECgUJBwABLgAFFAEJAgACAAAAAA==.',
['图刃']='图刃:BAAALgAECgUJAQAAAA==.',
['图劣']='图劣:BAAALgAECgUJBQAAAA==.',
['图法']='图法:BAAALgAECgYJDQAAAA==.',
['图灵']='图灵:BAAALgAECgUJBgAAAA==.',
['國产']='國产零零久:BAAALgAECgcJEwABLgAFFAEJAgACAAAAAA==.',
['圣光']='圣光回响:BAAALgAECgYJCwAAAA==.圣光在那:BAAALgADCgYJBgAAAA==.',
['圣血']='圣血天使:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱的怒吼:BAAALgAFFAEJAgAAAA==.地狱维纳斯:BAAALgAECgYJCAAAAA==.',
['夜罗']='夜罗刹:BAAALgAECgMJAwAAAA==.',
['大一']='大一:BAAALgAECgYJBgAAAA==.',
['大大']='大大地发丝:BAAALgAECgYJCwAAAA==.',
['天呐']='天呐我真高:BAAALgAECgYJEAAAAA==.',
['天空']='天空的刺青:BAAALgAECgQJBgAAAA==.',
['夹断']='夹断十号钢筋:BAAALgAECgMJAwAAAA==.',
['奶不']='奶不死你:BAAALgAECgEJAQAAAA==.',
['如丿']='如丿初:BAAALgAECgUJCQAAAA==.',
['如果']='如果哀:BAAALgADCgIJAgAAAA==.',
['姐夫']='姐夫是叁哥:BAAALgAECgEJAQAAAA==.',
['姑苏']='姑苏河畔:BAAALgAECgEJAQAAAA==.',
['子线']='子线:BAABLgAFFH8FAAILAAUJlxSgAwC1AQALAAUJlxSgAwC1AQAAAA==.',
['宅男']='宅男心不宅:BAAALgAFFAEJAQAAAA==.',
['宋徽']='宋徽宗:BAAALgADCgMJAwAAAA==.',
['宝蓝']='宝蓝半夏:BAAALgAECgYJBgAAAA==.',
['害羞']='害羞的番茄:BAAALgAECgYJDAAAAA==.',
['寻山']='寻山小妖:BAAALgADCgIJAgAAAA==.',
['小毛']='小毛乌头:BAAALgAECgEJAQAAAA==.',
['小红']='小红胖:BAAALgAECgQJBAAAAA==.',
['小肥']='小肥妹:BAAALgADCgEJAQAAAA==.',
['小荷']='小荷才露尖角:BAAALgADCgkJAwAAAA==.',
['尐絮']='尐絮兒:BAAALgAFFAEJAQAAAA==.',
['巴克']='巴克大队长:BAAALgAECgMJAwAAAA==.',
['希尔']='希尔瓦钢丝儿:BAAALgADCgMJAwAAAA==.',
['帕拉']='帕拉梅猪:BAAALgAECgYJCwAAAA==.',
['库巴']='库巴:BAAALgAFFAIJBAAAAA==.',
['开心']='开心笨笨:BAAALgADCgUJBQAAAA==.开心莓莓奶昔:BAAALgAECgEJAgAAAA==.',
['彩云']='彩云之北:BAAALgAECgEJAQAAAA==.',
['往前']='往前看:BAAALgAECgQJBAAAAA==.',
['德国']='德国德:BAAALgAFFAEJAQAAAA==.',
['心惢']='心惢:BAAALgAECgYJBgAAAA==.',
['忧郁']='忧郁的颜色:BAAALgAECgUJBQAAAA==.',
['怜媚']='怜媚:BAAALgADCgEJAQAAAA==.',
['恋上']='恋上寒若雨:BAAALgADCgEJAQABLgAFFAYJEgAMAG8iAA==.',
['恐惧']='恐惧达灵毛:BAAALgAECgUJBQAAAA==.',
['恶行']='恶行易施:BAAALgAECgYJCQAAAA==.',
['恶霊']='恶霊之手绝色:BAAALgAFFAEJAQAAAA==.',
['悲怜']='悲怜:BAAALgAFFAEJAQAAAA==.',
['拉风']='拉风:BAAALgAECgIJAwAAAA==.',
['招魂']='招魂幡离忧:BAABLgAFFH8IAAMNAAQJoQ9+BAA/AQANAAQJoQ9+BAA/AQAOAAIJsAkAAAAAAAAAAA==.',
['挽歌']='挽歌之风:BAAALgAECgYJBwAAAA==.',
['搓搓']='搓搓寒冰箭:BAAALgAECgkJBwAAAA==.',
['放过']='放过我吧:BAABLgAFFH8IAAIIAAQJxQ4oCQBXAQAIAAQJxQ4oCQBXAQAAAA==.',
['斷點']='斷點:BAAALgAFFAIJAwAAAA==.',
['方便']='方便面:BAAALgAECgEJAQAAAA==.',
['无聊']='无聊的小矮子:BAAALgADCgEJAQAAAA==.',
['明月']='明月爱赏喵:BAAALgAECgYJBwAAAA==.',
['晶风']='晶风:BAAALgAECgkJCQAAAA==.',
['暗夜']='暗夜之明月:BAAALgAECgYJEAAAAA==.',
['暗香']='暗香丨德:BAAALgAECgYJBgAAAA==.暗香丨戰:BAAALgAECgMJAwAAAA==.',
['曲利']='曲利出清:BAAALgAECgUJBQAAAA==.',
['月下']='月下孤舞:BAAALgAECgEJAQAAAA==.',
['月光']='月光丶:BAAALgAECgUJCgAAAA==.',
['李大']='李大鬼丶:BAAALgAECgEJAQAAAA==.',
['李晓']='李晓龙:BAAALgAECgEJAQAAAA==.',
['来自']='来自星星的狗:BAAALgAFFAIJAgAAAA==.',
['柒暮']='柒暮:BAAALgAECgUJBAAAAA==.',
['桀出']='桀出青年:BAAALgADCgEJAQAAAA==.',
['桃乃']='桃乃木香奈:BAAALgADCgYJBgAAAA==.',
['榴莲']='榴莲一号:BAAALgADCgEJAQAAAA==.',
['樂姐']='樂姐:BAAALgADCgMJAwAAAA==.',
['欧麦']='欧麦尬:BAAALgAECgYJDQAAAA==.',
['死亡']='死亡騎士:BAAALgAECgEJAQABLgAECgIJAwACAAAAAA==.',
['死肥']='死肥仔:BAAALgADCgEJAQAAAA==.',
['段月']='段月之光:BAAALgAECgQJCAAAAA==.',
['江流']='江流石不转:BAAALgAFFAIJAgAAAA==.',
['江湖']='江湖夜雨孤灯:BAAALgAECgEJAQAAAA==.',
['汽泡']='汽泡咖啡:BAAALgADCgIJAgAAAA==.',
['沐筱']='沐筱筱:BAAALgAECgMJAwABLgAECgUJBwACAAAAAA==.',
['沙罗']='沙罗娇娇:BAAALgADCgcJBwAAAA==.',
['流年']='流年丶丶:BAAALgAECgQJCQAAAA==.',
['涩青']='涩青苹果:BAAALgAFFAIJBAAAAA==.',
['渚光']='渚光希:BAAALgAECgEJAQAAAA==.',
['温柔']='温柔一笑:BAAALgAECgYJCgAAAA==.',
['灬刹']='灬刹那灬:BAAALgAECgYJCgAAAA==.',
['灬童']='灬童宝宝灬:BAAALgAECgYJCwAAAA==.',
['灿烂']='灿烂男孩:BAAALgAECgQJBwAAAA==.',
['焰云']='焰云长霄:BAAALgADCgIJAQAAAA==.',
['熊小']='熊小能:BAAALgAECgMJAwAAAA==.',
['燃烧']='燃烧卡路里:BAAALgAECgUJBQAAAA==.',
['爆发']='爆发者深度:BAAALgAECgIJAgAAAA==.',
['牛牛']='牛牛会武功:BAAALgAECgYJBgAAAA==.',
['牛眼']='牛眼流牛油:BAAALgAECgYJAQAAAA==.',
['独孤']='独孤凰火:BAAALgAECgYJCAAAAA==.',
['玄丶']='玄丶德:BAAALgAECgEJAQAAAA==.',
['玩火']='玩火烧到脸:BAAALgAECgEJAQAAAA==.',
['玩的']='玩的就是姿态:BAAALgAECgYJCQAAAA==.',
['瓜叽']='瓜叽:BAAALgADCgUJBQAAAA==.',
['白羊']='白羊座小小雨:BAAALgADCgEJAQAAAA==.白羊座小雨:BAAALgAECgMJAwAAAA==.',
['盖爾']='盖爾加朵:BAAALgAECgMJAwAAAA==.',
['盲客']='盲客:BAAALgAECgIJAwAAAA==.',
['睡也']='睡也无聊:BAAALgAECgQJBAAAAA==.',
['破晓']='破晓灬残影:BAAALgAECgEJAgAAAA==.',
['硒街']='硒街少年:BAAALgAECgIJAwAAAA==.',
['祖龙']='祖龙丶政:BAABLgAECn8gAAQJAAgJNAw0NQB5AQAJAAgJxgo0NQB5AQAPAAcJuwnEMgBYAQAQAAYJQxBYNwARAQAAAA==.',
['祝踏']='祝踏岚丶神明:BAAALgAECgQJBwAAAA==.',
['稳定']='稳定:BAAALgADCgYJBgAAAA==.',
['突突']='突突兔:BAAALgAFFAIJAwAAAA==.',
['索菲']='索菲雅:BAAALgAECgYJCgAAAA==.',
['繁花']='繁花梦落:BAAALgAECgIJAwAAAA==.',
['绝代']='绝代:BAAALgAECgEJAQAAAA==.',
['罗纱']='罗纱莉亚:BAAALgAECgYJBgAAAA==.',
['翻滚']='翻滚吧萌子:BAAALgAFFAEJAQAAAA==.翻滚屁屁:BAAALgAECgEJAQAAAA==.',
['老大']='老大哥:BAAALgADCgcJBwAAAA==.',
['老混']='老混子:BAAALgAECgEJAQAAAA==.',
['老滚']='老滚哥:BAAALgAECgYJBgAAAA==.',
['背叛']='背叛者丶神明:BAAALgAECgYJBwAAAA==.',
['背着']='背着盾牌找矛:BAAALgAECgEJAQAAAA==.',
['胖胖']='胖胖的糯米鸡:BAAALgAECgYJCQAAAA==.',
['胡小']='胡小狐:BAAALgAECgQJBAAAAA==.',
['花雨']='花雨川:BAAALgAECgYJBwAAAA==.',
['若是']='若是風輕:BAAALgAECgkJDAABLgAFFAQJCAAEABsdAA==.',
['英雄']='英雄城二师兄:BAAALgAECgYJDgAAAA==.英雄城厨子:BAAALgAECgYJDAAAAA==.英雄城地狱吼:BAAALgAECgQJBgAAAA==.',
['荷尔']='荷尔蒙:BAAALgAFFAIJAgAAAA==.',
['莉露']='莉露:BAAALgAECgEJAQAAAA==.',
['菊花']='菊花守护者:BAAALgAECgIJAgAAAA==.菊花护卫者:BAAALgAECgYJBgAAAA==.',
['萨鲁']='萨鲁法尔:BAAALgAECgEJAgAAAA==.',
['蓝雨']='蓝雨啊:BAAALgAECgEJAQAAAA==.',
['街边']='街边蹲一牛狼:BAAALgAECgEJAQAAAA==.',
['被狗']='被狗带:BAAALgAECgkJCQAAAA==.',
['让我']='让我来试试:BAAALgAECgEJAQAAAA==.',
['试玩']='试玩账号:BAAALgADCgMJAwAAAA==.',
['诺贝']='诺贝尔井岛犟:BAAALgADCgEJAQAAAA==.',
['贝特']='贝特瑞阿哥:BAABLgAECn8UAAIRAAcJThhyJAAzAgARAAcJThhyJAAzAgAAAA==.',
['贰拾']='贰拾肆伏:BAAALgAECgEJAQAAAA==.',
['超神']='超神怡寳:BAAALgADCgIJAgAAAA==.',
['跳跃']='跳跃之咒:BAAALgAECgkJBgAAAA==.',
['轻装']='轻装前行:BAAALgADCgkJCwAAAA==.',
['迪斯']='迪斯奈特:BAAALgAECgMJAwAAAA==.',
['逆时']='逆时针理想:BAAALgADCgEJAQAAAA==.',
['钢霸']='钢霸天:BAAALgAECgYJCAAAAA==.',
['镜子']='镜子里的你:BAAALgAECgYJCgAAAA==.',
['间桐']='间桐樱灬:BAAALgAFFAUJBAAAAA==.',
['阮阮']='阮阮:BAAALgAECgMJAwAAAA==.',
['阿喀']='阿喀硫斯:BAAALgAECgYJCgAAAA==.',
['阿尔']='阿尔方斯丶:BAAALgAECgYJDQAAAA==.',
['阿西']='阿西边:BAAALgAECgEJAgAAAA==.',
['阿里']='阿里克斯:BAAALgAECgUJBQAAAA==.',
['附魔']='附魔来了:BAAALgAECgQJBAAAAA==.',
['陰丶']='陰丶天:BAAALgAFFAEJAQAAAA==.',
['雪域']='雪域冰封:BAAALgAECgcJDgAAAA==.',
['雷战']='雷战:BAAALgAECgEJAQAAAA==.',
['雷法']='雷法:BAAALgAECgUJBQAAAA==.',
['雷美']='雷美眉:BAAALgAECgYJBgAAAA==.',
['雷龍']='雷龍:BAAALgADCgEJAgAAAA==.',
['露易']='露易丝薇登:BAAALgAECgMJAwAAAA==.',
['非常']='非常忧郁射神:BAAALgAECgYJBgAAAA==.',
['靥丶']='靥丶:BAAALgAECgEJAQAAAA==.',
['颗粒']='颗粒剂:BAAALgADCgEJAQAAAA==.',
['风暴']='风暴啤酒桶:BAAALgAECgYJBQAAAA==.',
['风渺']='风渺渺:BAAALgAECgYJBgAAAA==.',
['饿了']='饿了么猎手:BAAALgAECgQJBAAAAA==.',
['魔之']='魔之共犯:BAAALgADCgEJAQAAAA==.',
['魔法']='魔法小香菇:BAAALgADCgUJCgAAAA==.',
['魷魚']='魷魚筒:BAAALgAECgcJCAAAAA==.',
['鱼满']='鱼满:BAAALgAECgYJCAABLgAECgcJGQASAAIhAA==.',
['鲨鱼']='鲨鱼辣椒:BAAALgAFFAEJAQAAAA==.',
['黑暗']='黑暗涅槃:BAAALgAECgcJCAAAAA==.',
['黑锋']='黑锋领主:BAABLgAECn8VAAIHAAcJAA66igBrAQAHAAcJAA66igBrAQAAAA==.',
['龘丶']='龘丶貓:BAACLgAFFH8KAAITAAMJrCTDEABIAQATAAMJrCTDEABIAQAuAAQKfxgAAxMABwkVIdkhAIYCABMABwk1INkhAIYCABQABAnEHYY/AP4AAAEuAAUUBgkTABMAKCAA.',
['龙魂']='龙魂雨风:BAAALgAECgEJAgAAAA==.',
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
