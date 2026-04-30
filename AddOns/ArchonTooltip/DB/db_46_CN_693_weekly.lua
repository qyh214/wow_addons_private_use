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

local lookup = {'Druid-Restoration','Evoker-Preservation','Mage-Frost','DeathKnight-Unholy','Evoker-Augmentation','Evoker-Devastation','Shaman-Restoration','Rogue-Subtlety','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Unknown-Unknown','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver','Paladin-Protection','Warrior-Protection','Paladin-Holy','Druid-Guardian','Warrior-Arms','Monk-Brewmaster','DemonHunter-Devourer','Hunter-Marksmanship','Shaman-Elemental','DeathKnight-Blood','Druid-Balance','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','DemonHunter-Havoc','Priest-Holy','Warrior-Fury','DemonHunter-Vengeance',}
local provider = {region='CN',realm='提瑞斯法',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Acolost:BAAALgAECgYJCgAAAA==.',
Ai='Aioy:BAAALgAECgYJCwAAAA==.',
Al='Aleba:BAAALgAFFAUJAgAAAA==.Aleda:BAAALgAFFAUJAwAAAA==.Alega:BAABLgAFFH8LAAIBAAUJQBXHBACRAQABAAUJQBXHBACRAQAAAA==.Aleha:BAABLgAFFH8JAAIBAAUJnRhYAwCxAQABAAUJnRhYAwCxAQAAAA==.Aleia:BAABLgAFFH8JAAIBAAUJYhTrAQChAQABAAUJYhTrAQChAQAAAA==.Aleja:BAAALgAFFAUJAwAAAA==.Alela:BAABLgAFFH8HAAIBAAQJcQ6fDAAbAQABAAQJcQ6fDAAbAQAAAA==.Aleza:BAAALgAFFAUJAgAAAA==.',
Ar='Arachnia:BAAALgAFFAIJBAAAAA==.',
Au='Aurorra:BAAALgADCgEJAQAAAA==.',
Bk='Bkmonk:BAAALgAECgYJBQABLgAFFAYJDgACAK4ZAA==.',
Bu='Bubbjsg:BAAALgAECgYJCQAAAA==.Bullimoes:BAAALgAECgYJBgAAAA==.',
Ca='Cavill:BAABLgAECn8XAAIDAAkJ6yNVCgBxAwADAAkJ6yNVCgBxAwAAAA==.',
Cb='Cblind:BAAALgAFFAQJBAAAAA==.',
De='Deedee:BAAALgAECgYJDwAAAA==.Deeparisen:BAABLgAECn8dAAIEAAgJjCBBFQD8AgAEAAgJjCBBFQD8AgAAAA==.',
Dm='Dmorth:BAAALgAECgIJAgAAAA==.',
Ef='Effortless:BAAALgAECgQJBgAAAA==.',
El='Elise:BAAALgADCgQJBAAAAA==.',
Fi='Fifthelement:BAAALgAFFAQJBAAAAA==.',
Fo='Fourseasons:BAAALgAECgEJAQAAAA==.',
Gi='Giyu:BAAALgAECgYJBgAAAA==.',
Gu='Gugugu:BAAALgAECgcJEwABLgAFFAYJDgACAK4ZAA==.',
Ha='Haaland:BAAALgAFFAIJAwAAAA==.',
Il='Ilililililil:BAAALgAECgEJAQAAAA==.',
Is='Isabellas:BAAALgAECgQJBAAAAA==.',
It='Itachia:BAAALgAECgYJBgAAAA==.',
Jo='Joe:BAACLgAFFH8HAAIFAAMJMQSYFADPAAAFAAMJMQSYFADPAAAuAAQKfx0AAwUACAm+D+0eAMwBAAUACAm+D+0eAMwBAAYAAwl+CnwxAIoAAAAA.',
Js='Jshtoday:BAAALgAECgcJBwAAAA==.',
Ka='Kadles:BAAALgAECgQJBgAAAA==.',
Le='Leeq:BAABLgAECn8ZAAIHAAgJORToOgCWAQAHAAgJORToOgCWAQAAAA==.',
Lk='Lkoqlfipbukh:BAABLgAECn8UAAIIAAkJwRi7FQBiAgAIAAkJwRi7FQBiAgABLgAFFAQJDgAIAPsdAA==.',
Lu='Lunasolar:BAAALgAECgMJAwAAAA==.',
My='Mynameises:BAAALgAECgMJBAAAAA==.',
Na='Nallra:BAACLgAFFH8IAAMJAAMJsxqeAgBmAAAKAAMJTxryHQAMAQAJAAEJcx+eAgBmAAAuAAQKfxwAAwoABgn9JcYoAG4CAAoABgn9JcYoAG4CAAsAAgnqH1tBAK8AAAAA.',
Ni='Nickloues:BAAALgAECgYJBwAAAA==.',
Pi='Pika:BAAALgAECgUJBQAAAA==.',
Pl='Plsql:BAAALgAECgcJBgABLgAECgkJCwAMAAAAAA==.',
Po='Polekachu:BAAALgAFFAIJAwAAAA==.',
Ru='Ruintus:BAAALgAECgEJAQAAAA==.',
Sa='Saintrow:BAABLgAFFH8IAAINAAQJfR/sBgCBAQANAAQJfR/sBgCBAQAAAA==.Salong:BAAALgAECgIJAQAAAA==.',
Se='Senorita:BAAALgAECgcJBwAAAA==.Seveni:BAAALgAECgEJAQAAAA==.',
Si='Similight:BAAALgAFFAEJAQAAAA==.',
So='Sorserer:BAAALgADCgcJDQAAAA==.',
St='Stimulant:BAACLgAFFH8HAAIEAAMJihFROwCmAAAEAAMJihFROwCmAAAuAAQKfyQAAgQACAkNI3ICAJMCAAQACAkNI3ICAJMCAAAA.Stonehenge:BAAALgAECgUJBQAAAA==.',
Ta='Tassel:BAAALgAFFAIJAgAAAA==.',
Te='Temmy:BAAALgAECgIJAgAAAA==.Tenga:BAAALgAECgYJEQAAAA==.',
Th='Thrud:BAAALgADCgEJAQAAAA==.',
To='Tomcat:BAAALgAECgkJCwAAAA==.Toolwoman:BAAALgAFFAEJAQAAAA==.',
Tr='Traveler:BAAALgADCgkJCwAAAA==.',
Un='Unsolar:BAAALgAFFAEJAQAAAA==.',
Wo='Wowgpo:BAAALgAFFAQJBAAAAA==.',
Xi='Xiaobyangz:BAACLgAFFH8FAAIOAAIJFB3uCwCjAAAOAAIJFB3uCwCjAAAuAAQKfxcAAw4ABgldIx8UAE0CAA4ABgldIx8UAE0CAA8AAQmeBS5wACUAAAAA.',
Ye='Yezhan:BAAALgAFFAIJBAAAAA==.',
Yg='Yggdrasil:BAAALgAFFAEJAQAAAA==.',
['一一']='一一得一:BAAALgAECgIJAwAAAA==.',
['一七']='一七得七:BAAALgAECgkJCgAAAA==.',
['一三']='一三得三:BAABLgAECn8WAAMNAAkJHRYDJACYAgANAAkJHRYDJACYAgAQAAEJnAsvRgAoAAAAAA==.',
['一九']='一九三:BAAALgAECgYJDwAAAA==.',
['一二']='一二得二:BAAALgAECgIJAgAAAA==.',
['一六']='一六得六:BAAALgAECgkJEgAAAA==.',
['一口']='一口老奶:BAAALgADCgUJBQAAAA==.',
['一布']='一布洛克斯一:BAABLgAECn8ZAAIRAAgJ2RMcFgCsAQARAAgJ2RMcFgCsAQAAAA==.',
['一炀']='一炀:BAAALgAECgYJBgABLgAFFAUJCAALAO0UAA==.',
['一莉']='一莉亚德琳一:BAAALgAECgIJAwAAAA==.',
['一顿']='一顿喂不饱:BAAALgADCgIJAgAAAA==.',
['七荒']='七荒:BAAALgAFFAQJBAAAAA==.',
['万花']='万花通灵:BAAALgADCgUJBQAAAA==.',
['上帝']='上帝爸爸:BAAALgAECgUJAgAAAA==.',
['丨我']='丨我心永恒丨:BAAALgAECgMJAwAAAA==.',
['丨貓']='丨貓咪男爵丨:BAAALgADCgIJAgAAAA==.',
['丨风']='丨风暴之星丨:BAAALgAFFAIJAgAAAA==.',
['丶丨']='丶丨失忆:BAABLgAFFH8FAAISAAMJYBVzDgDuAAASAAMJYBVzDgDuAAAAAA==.',
['丶划']='丶划水大师:BAAALgAECgYJCQAAAA==.',
['丶嘿']='丶嘿:BAAALgAECgUJBQAAAA==.',
['丶奈']='丶奈德丽:BAABLgAFFH8FAAITAAMJVwwjBgBNAAATAAMJVwwjBgBNAAAAAA==.',
['丶小']='丶小晨夜:BAAALgAECgEJAgAAAA==.丶小鲸鱼:BAAALgAECgMJBQAAAA==.',
['丶布']='丶布冯:BAACLgAFFH8HAAMUAAMJJw8rBwCiAAAUAAMJvAwrBwCiAAARAAEJTw/SDwBGAAAuAAQKfx8AAxQACAlLHjMDANwCABQACAk9HjMDANwCABEAAQl3HZBAAE8AAAAA.',
['丶老']='丶老弓:BAAALgAECgcJDQAAAA==.',
['乐乐']='乐乐横扫饥饿:BAAALgAECgYJCAAAAA==.',
['乱世']='乱世不留情:BAAALgAFFAIJAgAAAA==.',
['云澈']='云澈:BAAALgAECgQJBAAAAA==.',
['云生']='云生:BAAALgADCgUJBQAAAA==.',
['亲爱']='亲爱的坝坝:BAAALgAECgMJAwAAAA==.',
['亵渎']='亵渎:BAACLgAFFH8GAAIEAAMJXR13HwAeAQAEAAMJXR13HwAeAQAuAAQKfyMAAgQACAmCI4IMADYDAAQACAmCI4IMADYDAAAA.',
['人中']='人中赤兔丶:BAAALgADCgUJBQAAAA==.',
['人间']='人间惆怅客:BAAALgAECgUJBAAAAA==.',
['仁丶']='仁丶:BAAALgAECgQJCAAAAA==.',
['付付']='付付二哥:BAAALgADCgEJAQAAAA==.',
['伊戈']='伊戈战:BAAALgAECgIJAgAAAA==.',
['伍粮']='伍粮液:BAAALgADCgEJAQAAAA==.',
['会飞']='会飞的玛茜:BAAALgAECgEJAQAAAA==.',
['传说']='传说中的衰:BAAALgADCgIJAgAAAA==.',
['佩罗']='佩罗娜:BAAALgAECgEJAQAAAA==.',
['俺村']='俺村俺最坏:BAABLgAECn8YAAMRAAkJmRlxBgDJAgARAAkJmRlxBgDJAgAUAAYJWw2jGwAUAQABLgAFFAUJCQARALUOAA==.',
['借下']='借下角磨机罢:BAAALgAECgEJAQAAAA==.',
['偷偷']='偷偷的爱上你:BAAALgAFFAEJAgAAAA==.',
['傲丶']='傲丶雪:BAAALgAFFAIJAgAAAA==.',
['傲灬']='傲灬雪:BAAALgAECgYJBgAAAA==.',
['元亓']='元亓亓元:BAAALgADCgIJAgAAAA==.',
['光光']='光光酱丶:BAAALgAECgYJCwAAAA==.',
['克瑞']='克瑞斯之影:BAAALgAECgEJAQAAAA==.',
['八级']='八级大狂风:BAAALgAECgYJDQAAAA==.',
['八部']='八部摩呼罗迦:BAAALgAECgYJDAAAAA==.',
['其实']='其实我很黑:BAAALgADCgUJBQAAAA==.',
['再会']='再会芳华:BAACLgAFFH8QAAIDAAUJxx0JCgDOAQADAAUJxx0JCgDOAQAuAAQKfx4AAgMACAlwIvYXABsDAAMACAlwIvYXABsDAAAA.',
['冰火']='冰火洗礼:BAACLgAFFH8GAAIDAAIJ/QmQHACkAAADAAIJ/QmQHACkAAAuAAQKfxoAAgMACAmEFwFLAFYCAAMACAmEFwFLAFYCAAAA.',
['凌绮']='凌绮丶蔱:BAAALgAECgEJAwAAAA==.',
['减伤']='减伤全开:BAABLgAECn8bAAIVAAgJ0AqlOwBZAQAVAAgJ0AqlOwBZAQAAAA==.',
['凝眸']='凝眸丶:BAAALgAECgYJBgAAAA==.',
['凡出']='凡出手必定有:BAAALgAECgYJBgAAAA==.',
['刚好']='刚好及格:BAAALgAECgYJDAAAAA==.',
['初一']='初一:BAAALgAECgIJAgAAAA==.',
['利奥']='利奥雷乌斯:BAAALgAECgUJDAABLgAECgYJEAAMAAAAAA==.',
['刷血']='刷血糕手:BAAALgAECgcJCQAAAA==.',
['十斤']='十斤哥:BAAALgAECgEJAQAAAA==.',
['十王']='十王星南:BAABLgAECn8VAAIWAAgJUxZ+PgD6AQAWAAgJUxZ+PgD6AQAAAA==.',
['半支']='半支罒烟:BAAALgAFFAEJAQAAAA==.',
['单依']='单依纯:BAAALgAECgEJAQAAAA==.',
['卖萌']='卖萌猎爹丶:BAAALgAECgIJBAAAAA==.',
['南悦']='南悦张翠山:BAAALgAFFAEJAgAAAA==.',
['卡西']='卡西奥佩娅:BAAALgAECgEJAQAAAA==.',
['卷卷']='卷卷:BAAALgAECgYJCQAAAA==.',
['双人']='双人徐:BAAALgAFFAIJAwAAAA==.',
['古尔']='古尔蛋灬:BAAALgAFFAEJAgAAAA==.',
['叫兽']='叫兽爱纯情:BAAALgAFFAMJAwABLgAFFAYJBQAXACQLAA==.',
['史巴']='史巴克斯塔:BAAALgAECgEJAQAAAA==.',
['叶叶']='叶叶烬歌:BAAALgAECgUJBQAAAA==.',
['叶子']='叶子酷酷哒:BAAALgAFFAIJAwAAAA==.',
['吃馒']='吃馒头心:BAAALgAECgEJAQAAAA==.',
['吕泡']='吕泡皮登戴丶:BAAALgAECgYJCwAAAA==.',
['吻中']='吻中带铍:BAABLgAECn8aAAMCAAgJzRrqCwB2AgACAAgJzRrqCwB2AgAGAAMJaBRHOgBIAAAAAA==.',
['吼你']='吼你妹:BAAALgAECgYJCQAAAA==.',
['吾心']='吾心永恆:BAABLgAECn8fAAMYAAgJLhCmCQBiAQAYAAgJLhCmCQBiAQAHAAEJngFJpAArAAAAAA==.',
['咁米']='咁米你中意咯:BAAALgAECgEJAgAAAA==.',
['咪萨']='咪萨咪萨:BAAALgAFFAQJBAAAAA==.',
['咸芝']='咸芝士:BAAALgAECgYJDQAAAA==.',
['哇啦']='哇啦哇啦咙:BAAALgAECgEJAQAAAA==.',
['哈籁']='哈籁恩达尔德:BAAALgAECgEJAQAAAA==.',
['哎呀']='哎呀下雨了:BAAALgAECgYJCAAAAA==.',
['唫角']='唫角大王:BAABLgAECn8aAAIEAAkJcxYPBABWAgAEAAkJcxYPBABWAgAAAA==.',
['啊灬']='啊灬哒灬:BAAALgAECgYJCwAAAA==.',
['啊牛']='啊牛奶奶:BAAALgADCgEJAQAAAA==.',
['喷射']='喷射戦神:BAAALgAFFAEJAQAAAA==.',
['嗨你']='嗨你真受:BAAALgAFFAIJAwAAAA==.',
['嘚儿']='嘚儿灬驾丶:BAABLgAECn8kAAINAAkJ4hsyBABgAgANAAkJ4hsyBABgAgAAAA==.',
['嘦勥']='嘦勥嫑囧:BAAALgAECgYJDwAAAA==.',
['嘻咪']='嘻咪噜:BAABLgAECn8XAAIYAAcJ8g0MEQD+AAAYAAcJ8g0MEQD+AAAAAA==.',
['嚇准']='嚇准斯托斯:BAAALgAECggJDwAAAA==.',
['嚣张']='嚣张青菜:BAAALgADCgEJAQAAAA==.',
['四棍']='四棍萨满:BAABLgAECn8cAAIHAAgJ8hdqHQAwAgAHAAgJ8hdqHQAwAgAAAA==.',
['回笼']='回笼不觉:BAABLgAECn8ZAAMNAAgJBBQdWQDXAQANAAcJ/hMdWQDXAQAQAAYJSg3BHgATAQAAAA==.',
['团子']='团子大法师:BAAALgAECgkJDgABLgAFFAQJCwADACsVAA==.',
['土士']='土士土士土土:BAACLgAFFH8GAAIEAAMJVRvNQgCdAAAEAAMJVRvNQgCdAAAuAAQKfx8AAwQACAlKILMFACsCAAQACAlKILMFACsCABkAAQmjBbtKACEAAAAA.',
['圣光']='圣光孖辫妹:BAABLgAECn8WAAMNAAcJSRO8eQCGAQANAAcJSRO8eQCGAQASAAMJuwnVewCKAAAAAA==.圣光漫步:BAAALgAECgQJBQAAAA==.圣光牛牛:BAAALgAECgIJAgABLgAFFAUJCQAaALAdAA==.圣光贰拉罐:BAAALgAECgYJBQAAAA==.',
['地精']='地精:BAAALgAECgYJBwAAAA==.',
['坏猫']='坏猫:BAAALgADCgcJBwAAAA==.',
['堕落']='堕落的茄子:BAAALgAECgQJBQAAAA==.',
['壓迫']='壓迫众生:BAAALgAECgkJDwAAAA==.',
['士郎']='士郎:BAAALgAECgYJDQAAAA==.',
['壮壮']='壮壮灬:BAAALgAECgQJBgAAAA==.',
['壹戳']='壹戳插盲你:BAAALgAECgEJAQAAAA==.',
['复苏']='复苏的飞飞酱:BAAALgAECgIJAgAAAA==.',
['夏沫']='夏沫之殇丶:BAAALgADCgcJBwAAAA==.',
['夜空']='夜空:BAAALgAECgUJBQAAAA==.',
['夜访']='夜访吸血鬼:BAABLgAFFH8JAAIDAAMJHRQlLwD5AAADAAMJHRQlLwD5AAAAAA==.',
['夢如']='夢如丶淺沫:BAAALgAECgcJBwAAAQ==.',
['大木']='大木木:BAAALgAECgQJCAAAAA==.',
['大泳']='大泳鸿:BAAALgADCgMJAwAAAA==.',
['大熊']='大熊咕咕:BAAALgAECgYJCQAAAA==.',
['大猫']='大猫儿丶:BAAALgAECgMJBAAAAA==.',
['大祥']='大祥老师:BAAALgAECgYJDAAAAA==.',
['大雁']='大雁叫:BAAALgAFFAIJBAAAAA==.',
['天堂']='天堂圣箭:BAAALgAECgEJAQAAAA==.天堂里的圣光:BAAALgAECgMJBAAAAA==.',
['天灰']='天灰灰:BAAALgAECgMJAwAAAA==.',
['太阳']='太阳双子祭司:BAAALgAFFAQJBAABLgAFFAUJBQAbANEPAA==.',
['太陽']='太陽当空照丶:BAAALgAECgMJAwAAAA==.',
['奢望']='奢望哪抹浅笑:BAAALgADCgUJBQAAAA==.',
['奥妮']='奥妮克希娅:BAAALgAECgYJCQABLgAFFAYJFgAcAKkVAA==.',
['奶到']='奶到你死为止:BAAALgADCgMJAwAAAA==.',
['好玩']='好玩的飞飞酱:BAAALgAFFAIJAwAAAA==.',
['姆诺']='姆诺兹多:BAAALgADCgkJCQAAAA==.',
['安得']='安得丶妈咪:BAABLgAECn8WAAIDAAgJYBpLCwD6AQADAAgJYBpLCwD6AQAAAA==.',
['完美']='完美威力大:BAAALgADCgEJAQABLgAECgQJCAAMAAAAAA==.',
['完颜']='完颜不破:BAAALgADCgcJCAAAAA==.',
['宝宝']='宝宝熊:BAAALgAECgEJAQAAAA==.宝宝牙买蝶:BAAALgADCgEJAQAAAA==.',
['宫丶']='宫丶东风:BAAALgADCgEJAQAAAA==.',
['寂静']='寂静猎手:BAAALgAECgYJDgAAAA==.',
['寒冰']='寒冰圣光:BAAALgAECgIJAwAAAA==.寒冰玫瑰:BAAALgAECgEJAQAAAA==.',
['寒白']='寒白:BAAALgAECgUJBAAAAA==.',
['小丘']='小丘西:BAAALgAECgYJEwAAAA==.',
['小叶']='小叶叶龙:BAAALgAECgIJAgAAAA==.',
['小宅']='小宅虎:BAAALgAECgQJBQAAAA==.',
['小春']='小春子:BAAALgAECgYJCAAAAA==.',
['小样']='小样别跑:BAAALgAECgcJEAAAAA==.',
['小灬']='小灬宝:BAAALgAECgQJBAAAAA==.',
['小聋']='小聋瞎:BAAALgAECgEJAQAAAA==.',
['小肥']='小肥酱:BAAALgAECgkJCgAAAA==.',
['小芙']='小芙妮:BAABLgAFFH8IAAIdAAQJAxbvCQASAQAdAAQJAxbvCQASAQAAAA==.',
['小茉']='小茉莉茶:BAAALgAECgEJAQAAAA==.',
['小豆']='小豆吖:BAAALgAECggJDAAAAA==.',
['小鱼']='小鱼咖啡:BAAALgADCgcJBwAAAA==.',
['尤迪']='尤迪安:BAAALgAECgkJEgAAAA==.',
['就是']='就是猛:BAAALgAECgcJDgAAAA==.',
['尸土']='尸土:BAAALgAECgkJDQAAAA==.',
['尼可']='尼可:BAAALgAECgcJDwABLgAFFAYJFgAcAKkVAA==.',
['山有']='山有扶苏:BAAALgAECgEJAQAAAA==.',
['岢岢']='岢岢龍:BAAALgAECgcJEAAAAA==.',
['巉瀺']='巉瀺丶:BAAALgAECgIJAgAAAA==.',
['希尔']='希尔瓦娜燍:BAAALgAECgEJAQAAAA==.',
['帕秋']='帕秋莉酱:BAABLgAFFH8FAAMKAAUJgBGeEgBSAQAKAAQJWBSeEgBSAQALAAEJ+Qi+FgBRAAAAAA==.',
['幕夕']='幕夕:BAAALgAECgYJCQAAAA==.',
['干煸']='干煸史莱姆:BAAALgAECgEJAQAAAA==.',
['年轻']='年轻的女祭司:BAAALgAFFAQJAgAAAA==.',
['幻境']='幻境:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影小猎:BAAALgAECgEJAgAAAA==.幻影小骑:BAAALgAECgMJBgAAAA==.',
['开门']='开门查心能:BAAALgAECgQJBAAAAA==.',
['引露']='引露:BAAALgAECgEJAQAAAA==.',
['弥诺']='弥诺陶洛斯:BAAALgAECgkJEAAAAA==.',
['強顔']='強顔歡笑:BAABLgAECn8aAAIDAAYJhRmeggDMAQADAAYJhRmeggDMAQAAAA==.',
['当代']='当代艺术分析:BAAALgAECggJCAAAAA==.',
['心梦']='心梦:BAAALgAECgYJBwAAAA==.',
['忑忑']='忑忑忐忑:BAAALgADCgIJAgAAAA==.',
['忘川']='忘川之畔:BAAALgAECgEJAQAAAA==.',
['怀疑']='怀疑你在演:BAAALgAECgYJBwAAAA==.',
['怪妳']='怪妳過分热情:BAABLgAECn8UAAINAAcJVh50NQBNAgANAAcJVh50NQBNAgAAAA==.',
['总是']='总是学不会:BAACLgAFFH8JAAIEAAMJNxcJKQD1AAAEAAMJNxcJKQD1AAAuAAQKfxUAAwQABwnjGz1BADQCAAQABwnjGz1BADQCABkAAQnjDQAAAAAAAAAA.',
['恐虐']='恐虐神选靓坤:BAAALgAECgQJDQAAAA==.',
['恶魔']='恶魔小百变:BAAALgAECgQJBAAAAA==.恶魔霸天女猎:BAAALgAECgYJCwAAAA==.',
['恺尔']='恺尔萨斯:BAAALgAECgEJAwAAAA==.',
['恺撒']='恺撒:BAAALgAECgYJCQAAAA==.',
['悪麼']='悪麼猎手:BAAALgAECgIJAgAAAA==.',
['愛之']='愛之義:BAACLgAFFH8WAAIcAAYJqRWMAQAPAgAcAAYJqRWMAQAPAgAuAAQKfyYAAhwACQljJO8BAJsDABwACQljJO8BAJsDAAAA.',
['感同']='感同身受:BAAALgAECgkJCQAAAA==.',
['愿丶']='愿丶:BAAALgAFFAIJAgAAAA==.',
['慎丶']='慎丶:BAAALgAECggJCAAAAA==.',
['我当']='我当时就懵了:BAAALgAFFAIJAwAAAA==.',
['战鹰']='战鹰吃什么:BAACLgAFFH8OAAIYAAQJNRvtCABPAQAYAAQJNRvtCABPAQAuAAQKfxkAAxgACQnqHwoLAOcCABgACQnqHwoLAOcCAAcAAQnFAYGmACkAAAAA.',
['截天']='截天灭地神限:BAAALgADCgcJBwAAAA==.',
['戰丶']='戰丶術:BAAALgADCgEJAQAAAA==.',
['打了']='打了个嗝:BAAALgAECgEJAQAAAA==.',
['执剑']='执剑九五二七:BAAALgADCgEJAQAAAA==.执剑大领主:BAAALgADCgMJAwAAAA==.执剑玄衣:BAAALgADCgMJAwAAAA==.执剑甲:BAAALgAECgIJAgAAAA==.执剑锁:BAAALgAECgQJBAAAAA==.执剑龙虎豹:BAAALgADCgEJAQAAAA==.',
['扯丶']='扯丶花花:BAABLgAFFH8FAAIKAAIJgBEfMwCsAAAKAAIJgBEfMwCsAAAAAA==.',
['拒绝']='拒绝过娜扎:BAABLgAFFH8GAAISAAQJuhjgBwBTAQASAAQJuhjgBwBTAQAAAA==.',
['拳击']='拳击教授:BAAALgAECgcJBwAAAA==.',
['掟上']='掟上今曰子:BAACLgAFFH8HAAIWAAMJUhN2JgCmAAAWAAMJUhN2JgCmAAAuAAQKfyUAAxYACAmIIFcXAMoCABYACAmIIFcXAMoCAB4AAQnaFClsADkAAAAA.',
['探花']='探花陈庆之:BAAALgADCgIJAgAAAA==.',
['提防']='提防小手:BAACLgAFFH8NAAIIAAQJLwzPCQBUAQAIAAQJLwzPCQBUAQAuAAQKfxkAAggABwm9HHwZADgCAAgABwm9HHwZADgCAAAA.',
['摩天']='摩天大牛:BAAALgAECgEJAQAAAA==.',
['散漫']='散漫:BAAALgADCgIJAgAAAA==.',
['敲开']='敲开天堂之门:BAAALgAECgEJAQAAAA==.',
['文静']='文静的秒殺:BAAALgAECgYJDAABLgAFFAUJBAAMAAAAAA==.',
['斋藤']='斋藤飞鸟:BAAALgAECgYJCQAAAA==.',
['新手']='新手法师:BAABLgAFFH8IAAIDAAMJYxNwKQAOAQADAAMJYxNwKQAOAQAAAA==.',
['方大']='方大厨:BAAALgAECgYJDwAAAA==.',
['旋风']='旋风喵喵踢:BAAALgAFFAEJAQAAAA==.',
['无敌']='无敌小贱妹:BAABLgAECn8UAAIfAAgJDxwVDACRAgAfAAgJDxwVDACRAgAAAA==.无敌小饭团:BAAALgAECgYJBgAAAA==.无敌炉石回城:BAAALgAECgcJDQAAAA==.',
['无畏']='无畏的圣光:BAABLgAECn8UAAISAAgJIh2rDgChAgASAAgJIh2rDgChAgAAAA==.无畏的圣谕:BAAALgAECgcJCQABLgAFFAUJCQAaALAdAA==.无畏的牧:BAABLgAECn8cAAMfAAkJQRL4FQAtAgAfAAkJQRL4FQAtAgAcAAEJLAjrYwAxAAABLgAFFAUJCQAaALAdAA==.无畏的输出:BAAALgAECgkJDAABLgAFFAUJCQAaALAdAA==.',
['日番']='日番谷东狮郞:BAABLgAECn8XAAIDAAcJ+xORiwC7AQADAAcJ+xORiwC7AQAAAA==.',
['星光']='星光龙骑:BAAALgAFFAEJAQAAAA==.',
['星星']='星星躲进云里:BAAALgADCgEJAQAAAA==.',
['春日']='春日影:BAABLgAFFH8GAAIWAAMJpAc/IADTAAAWAAMJpAc/IADTAAAAAA==.',
['是米']='是米娅呀:BAABLgAFFH8JAAMXAAUJAyAOBgDBAQAXAAUJvRwOBgDBAQAdAAQJQRgAAAAAAAAAAA==.',
['是紫']='是紫色有救了:BAAALgAECgIJAgAAAA==.',
['暂无']='暂无此牙:BAAALgAECgMJAwAAAA==.',
['暗堂']='暗堂天赐:BAABLgAFFH8GAAIDAAMJWB7BJAAiAQADAAMJWB7BJAAiAQAAAA==.',
['暗影']='暗影弑魔者:BAAALgAECgUJCgAAAA==.',
['暗言']='暗言术:BAAALgAFFAIJAgAAAA==.',
['暴力']='暴力橙:BAAALgAECgQJBwAAAA==.',
['暴走']='暴走面条:BAAALgAECgUJDwAAAA==.',
['月姬']='月姬:BAAALgAECgMJAwAAAA==.',
['朔风']='朔风飞扬:BAAALgADCgUJBgAAAA==.',
['朝阳']='朝阳群众:BAAALgAECgYJDAAAAA==.',
['木严']='木严:BAAALgAECgYJCQAAAA==.',
['木言']='木言:BAAALgAECgEJAQAAAA==.',
['末节']='末节极地:BAAALgAECgkJCQAAAA==.',
['机灵']='机灵贰拉罐:BAAALgAECgEJAQAAAA==.',
['杨小']='杨小雨:BAAALgADCgYJBgAAAA==.',
['松嫩']='松嫩牛排师傅:BAAALgAECgQJBQAAAA==.',
['林北']='林北:BAAALgAECgcJBwAAAA==.',
['果赖']='果赖:BAABLgAECn8dAAIBAAgJLhdWOADGAQABAAgJLhdWOADGAQAAAA==.',
['柒天']='柒天丶:BAAALgAECgMJAwAAAA==.',
['格礼']='格礼菲斯:BAAALgADCgYJBgABLgAECgMJAwAMAAAAAA==.',
['橙战']='橙战:BAAALgAECgIJBAAAAA==.',
['武曲']='武曲星:BAAALgAECgEJAgAAAA==.',
['武汉']='武汉靓坤:BAAALgAECgQJBAAAAA==.',
['死亡']='死亡骷戮:BAAALgAECgEJAQAAAA==.',
['死司']='死司凭血:BAAALgAECgMJAwAAAA==.',
['死神']='死神跳舞:BAAALgAECgYJDAAAAA==.',
['毁灭']='毁灭才是信仰:BAAALgAFFAEJAQAAAA==.',
['气气']='气气:BAAALgAECgEJAQAAAA==.',
['水晶']='水晶大岩蛇:BAAALgAECgcJDQAAAA==.',
['江天']='江天锁钥楼:BAAALgAECgMJAwAAAA==.',
['池瑶']='池瑶:BAAALgAECgYJDQAAAA==.',
['沉睡']='沉睡的妞妞:BAABLgAECn8cAAMNAAkJVxaTLQBtAgANAAkJ7RWTLQBtAgAQAAEJyArLRQApAAAAAA==.沉睡肆无忌惮:BAAALgAECgEJAQAAAA==.',
['沐玄']='沐玄音:BAAALgAECgEJAgAAAA==.',
['没有']='没有无敌:BAAALgAECgEJAgAAAA==.',
['没钱']='没钱的小飞象:BAAALgAECgcJCgAAAA==.',
['油爆']='油爆瞎:BAAALgAECgQJBQAAAA==.',
['法伊']='法伊卡尔雅:BAABLgAECn8WAAINAAgJ/xQERAAYAgANAAgJ/xQERAAYAgAAAA==.',
['法修']='法修散打师傅:BAAALgAECgMJAwAAAA==.',
['法号']='法号三藏:BAABLgAECn8UAAIOAAkJaRm9CwC/AgAOAAkJaRm9CwC/AgAAAA==.',
['泠緬']='泠緬獵掱:BAAALgAECgMJBQAAAA==.',
['波克']='波克比:BAAALgAECgMJAwAAAA==.',
['浪恋']='浪恋云:BAAALgAECgIJAgAAAA==.',
['海贼']='海贼王一乔巴:BAAALgADCgMJAwAAAA==.',
['消逝']='消逝年華:BAAALgAECggJCAAAAA==.',
['深邃']='深邃梦点:BAAALgAECgQJBAAAAA==.',
['溜达']='溜达的幻龗:BAAALgADCgYJBgAAAA==.',
['漆又']='漆又又丶:BAAALgADCgUJBQAAAA==.',
['潘多']='潘多拉:BAAALgADCgIJAgAAAA==.',
['潮州']='潮州果子狸:BAAALgAECgYJBwAAAA==.',
['瀟湘']='瀟湘夜雨:BAAALgADCgEJAQAAAA==.',
['火灬']='火灬柴棍:BAABLgAECn8VAAIDAAcJYBZwHgBeAQADAAcJYBZwHgBeAQAAAA==.',
['灬喵']='灬喵喵萌灬:BAABLgAECn8VAAICAAYJXhV6HwCDAQACAAYJXhV6HwCDAQAAAA==.',
['灬战']='灬战复我灬:BAAALgAECgEJAQAAAA==.',
['灬鐡']='灬鐡炙灬:BAABLgAECn8VAAMHAAYJvBBKSABhAQAHAAYJvBBKSABhAQAYAAIJDALBegBYAAAAAA==.',
['灵射']='灵射:BAAALgAECgQJBQAAAA==.',
['灿若']='灿若年华:BAAALgAECgIJAgAAAA==.',
['炭烤']='炭烤秋刀鱼:BAAALgAECgEJAQAAAA==.',
['点点']='点点流水:BAAALgAECgUJCAAAAA==.',
['烈海']='烈海王:BAAALgAECgMJAwAAAA==.',
['烈风']='烈风之卡琳:BAAALgADCgUJBQAAAA==.烈风的骑士姬:BAABLgAFFH8FAAINAAMJgyCIEwAKAQANAAMJgyCIEwAKAQAAAA==.',
['無念']='無念丶:BAAALgAECggJDQABLgAFFAUJBwADAMcZAA==.',
['無欲']='無欲丶:BAAALgAECgYJCAAAAA==.',
['無霜']='無霜丶:BAAALgAECgcJBwABLgAFFAgJGgADAHwmAA==.',
['熙瓜']='熙瓜寨寨主:BAAALgAECgMJAwAAAA==.',
['爀尔']='爀尔墨斯:BAABLgAECn8aAAMUAAkJlxt4AACcAgAgAAkJ0hmeDQDpAgAUAAkJoxd4AACcAgABLgAFFAYJFQAgAFEmAA==.',
['爱吃']='爱吃各种饺子:BAAALgADCgcJDQAAAA==.爱吃白菜饺:BAABLgAFFH8IAAIEAAQJhQ4QGgA9AQAEAAQJhQ4QGgA9AQAAAA==.',
['牛一']='牛一佰:BAAALgAECgYJDQABLgAFFAUJCQAaALAdAA==.',
['牛三']='牛三:BAAALgAECgIJAgAAAA==.牛三生:BAAALgAECgcJEQABLgAFFAUJCQAaALAdAA==.',
['牛壹']='牛壹贰:BAAALgAECgkJCwABLgAFFAUJCQAaALAdAA==.',
['牛小']='牛小妹:BAAALgAECgIJAgAAAA==.',
['牛德']='牛德亿币:BAAALgAFFAIJAgAAAA==.',
['牛牛']='牛牛你好酷:BAAALgAECgQJBAAAAA==.牛牛德:BAAALgADCgUJBQAAAA==.',
['狂暴']='狂暴妞妞:BAAALgAECgIJAgAAAA==.',
['狂野']='狂野与杀戮:BAAALgADCgQJBAAAAA==.',
['独爱']='独爱灬微风:BAAALgADCgUJBQAAAA==.',
['猎魂']='猎魂矢:BAAALgAFFAEJAgAAAA==.',
['玉藻']='玉藻前丶:BAAALgAECgYJCwAAAA==.',
['琥珀']='琥珀的回忆:BAAALgADCgEJAQAAAA==.',
['生椰']='生椰拿铁去冰:BAAALgADCgIJAgAAAA==.',
['生煎']='生煎馒头:BAAALgAECgcJAQAAAA==.',
['电死']='电死那个小酷:BAAALgAECgMJBAAAAA==.',
['疯男']='疯男唤魔龙:BAAALgAECgYJCwAAAA==.疯男圣光骑:BAAALgAECgcJCAAAAA==.疯男熊猫僧:BAAALgAECgIJAgAAAA==.疯男百变德:BAAALgAECgYJEQAAAA==.疯男黑锋骑:BAAALgAECgYJBgAAAA==.',
['痴痴']='痴痴吃:BAAALgAECgYJBwAAAA==.',
['瘦多']='瘦多多:BAAALgAECgMJAwAAAA==.',
['白里']='白里透橙:BAAALgAECgYJBQAAAA==.',
['白龙']='白龙:BAAALgAFFAIJAgAAAA==.',
['眼泪']='眼泪水汪汪:BAAALgAECgEJAQAAAA==.',
['睦头']='睦头人:BAABLgAFFH8IAAIFAAMJ1AbkEwDcAAAFAAMJ1AbkEwDcAAAAAA==.',
['石原']='石原里美:BAAALgADCgQJBAAAAA==.',
['石真']='石真香:BAACLgAFFH8FAAIEAAIJGBMkPwChAAAEAAIJGBMkPwChAAAuAAQKfxYAAgQACQkIF5UrAIoCAAQACQkIF5UrAIoCAAAA.',
['神圣']='神圣疯暴:BAAALgAECgMJAwAAAA==.神圣风暴:BAABLgAFFH8FAAMSAAIJ3yLPEQDAAAASAAIJ3yLPEQDAAAANAAEJxQlRNABOAAAAAA==.',
['禁锢']='禁锢的洛基:BAABLgAECn8eAAMKAAcJoBiSFgBbAQAKAAYJoBiSFgBbAQALAAEJAAAVYQBMAAAAAA==.',
['禽龙']='禽龙寺小熊猫:BAAALgAECgQJBAAAAA==.',
['窝佬']='窝佬功:BAABLgAECn8aAAIDAAgJ9BG2bwD1AQADAAgJ9BG2bwD1AQAAAA==.',
['第十']='第十二夜:BAAALgADCgEJAQAAAA==.',
['糊里']='糊里糊涂:BAAALgAECgYJBgAAAA==.',
['糖菓']='糖菓子:BAAALgAECgIJAgAAAA==.',
['紫魇']='紫魇:BAACLgAFFH8HAAIhAAMJdRkfAgDCAAAhAAMJdRkfAgDCAAAuAAQKfx8AAiEACAn3GR4HABkCACEACAn3GR4HABkCAAAA.',
['红扣']='红扣:BAABLgAFFH8FAAIEAAIJAB6+OQCoAAAEAAIJAB6+OQCoAAAAAA==.',
['红狮']='红狮:BAAALgAFFAIJAgAAAA==.',
['红神']='红神:BAAALgAECgEJAQAAAA==.',
['纯正']='纯正莽夫:BAABLgAECn8VAAIgAAgJpBbvJAAwAgAgAAgJpBbvJAAwAgABLgAFFAYJDgACAK4ZAA==.',
['给他']='给他打个眠:BAAALgAFFAEJAQAAAA==.',
['给你']='给你打个眠:BAAALgADCgYJBgAAAA==.',
['绝命']='绝命丶:BAAALgADCgIJAgAAAA==.',
['维纳']='维纳斯的拥抱:BAAALgADCgkJAgAAAA==.',
['绿茶']='绿茶牛灬牛:BAAALgAECgcJDQABLgAFFAUJCQAaALAdAA==.绿茶牛牛:BAAALgAECgcJAgABLgAFFAUJCQAaALAdAA==.',
['美素']='美素佳儿:BAAALgADCgEJAQABLgAECgYJEAAMAAAAAA==.',
['羲毙']='羲毙凄:BAAALgAECgQJCgAAAA==.',
['老摩']='老摩托:BAAALgAECgQJBAAAAA==.',
['聽說']='聽說這樣很難:BAAALgAECgQJBAAAAA==.',
['肥兜']='肥兜兜:BAAALgADCgEJAQAAAA==.',
['胖胖']='胖胖丸子球:BAAALgAECggJAQAAAA==.',
['能量']='能量灌猪:BAAALgAFFAIJBAAAAA==.',
['腥风']='腥风踏白骨:BAAALgADCgQJBAAAAA==.',
['膜王']='膜王纳渣克:BAACLgAFFH8LAAIEAAQJWx5ZCgB/AQAEAAQJWx5ZCgB/AQAuAAQKfyEAAgQACAm4JDsNADADAAQACAm4JDsNADADAAAA.',
['舒肤']='舒肤佳:BAABLgAECn8YAAIDAAgJ4xWUCwD2AQADAAgJ4xWUCwD2AQAAAA==.',
['花开']='花开并蒂:BAAALgAECgEJAQAAAA==.',
['花木']='花木瞳:BAAALgAECgQJBAAAAA==.',
['若斐']='若斐:BAAALgAFFAIJBAAAAA==.',
['莱万']='莱万汀:BAAALgAECgEJAgAAAA==.',
['落叶']='落叶听枫:BAAALgAECgYJBgAAAA==.',
['董巧']='董巧巧:BAAALgAECgIJAgAAAA==.',
['蒂塔']='蒂塔纽姆:BAAALgAECgYJCAAAAA==.',
['虚空']='虚空的飞飞酱:BAACLgAFFH8HAAMKAAMJWw21NACpAAAKAAIJKRG1NACpAAALAAEJwQUAAAAAAAAuAAQKfx0AAwsACAlfHv4KABACAAoACAnyG3YjAIYCAAsABwn+G/4KABACAAAA.',
['蛇喰']='蛇喰梦子:BAAALgADCgcJBwAAAA==.',
['蛋吖']='蛋吖儿:BAAALgAECgEJAQAAAA==.',
['蜂王']='蜂王将:BAAALgAFFAIJAgAAAA==.',
['蝉鸣']='蝉鸣之夏:BAAALgADCgEJAgAAAA==.',
['血色']='血色中的残阳:BAAALgAECggJDAAAAA==.',
['被封']='被封印的双刀:BAAALgADCgIJAgABLgAFFAYJDQAWAAAcAA==.',
['要你']='要你命:BAAALgAECgIJAgAAAA==.',
['议会']='议会之影:BAAALgAECgEJAQAAAA==.',
['试玩']='试玩职业:BAAALgAECgYJCwAAAA==.',
['诡异']='诡异的大鹌鹑:BAAALgAECgkJCwAAAA==.诡异的萨他死:BAAALgAECgkJAwAAAA==.',
['诺二']='诺二:BAAALgAECgMJBAAAAA==.',
['豆吖']='豆吖儿:BAAALgAECgQJBAAAAA==.',
['账账']='账账:BAAALgADCgUJBQAAAA==.',
['起个']='起个大早:BAAALgAECgMJAwAAAA==.',
['超级']='超级丶小智:BAAALgADCgMJAwAAAA==.',
['路小']='路小希:BAAALgAECgYJDAAAAA==.',
['踏空']='踏空:BAAALgADCgQJBAAAAA==.',
['身高']='身高一米五丶:BAAALgAECgEJAQAAAA==.',
['软软']='软软爱阿伦:BAAALgADCgEJAgAAAA==.',
['迅影']='迅影贼侠:BAAALgAECgUJCAAAAA==.',
['过期']='过期关系丶:BAAALgAECgQJBAAAAA==.',
['运动']='运动:BAAALgAECggJDgAAAA==.',
['还记']='还记得:BAAALgAECgYJEAAAAA==.',
['迷踪']='迷踪熊铁枪:BAAALgAECggJEwAAAA==.',
['追风']='追风星辰:BAAALgAECgEJAQAAAA==.',
['逆风']='逆风凋零:BAAALgADCgEJAQAAAA==.逆风的翼:BAAALgADCgIJAgAAAA==.',
['那个']='那个叫什么:BAABLgAECn8UAAISAAYJFxdgNQCnAQASAAYJFxdgNQCnAQAAAA==.那个迪凯:BAAALgAECgQJBQAAAA==.',
['那妞']='那妞丨在徘徊:BAAALgADCgkJCQAAAA==.',
['那非']='那非:BAAALgAECgEJAwAAAA==.',
['邪帝']='邪帝雅撕:BAAALgAFFAIJAgAAAA==.',
['邪恶']='邪恶贰拉罐:BAAALgAFFAIJAgAAAA==.',
['邪祟']='邪祟生:BAAALgAFFAEJAQAAAA==.',
['都督']='都督:BAAALgAECgIJAgAAAA==.',
['酞均']='酞均是发事:BAAALgAECgYJBwAAAA==.',
['野性']='野性之灵:BAAALgAECgYJDwAAAA==.',
['银河']='银河美少年:BAAALgAECgkJCQAAAA==.',
['银角']='银角汏王:BAABLgAECn8VAAIEAAkJZxZCKACZAgAEAAkJZxZCKACZAgAAAA==.',
['银雪']='银雪:BAAALgAECgIJAgAAAA==.',
['长腿']='长腿哥哥:BAAALgADCgIJAgAAAA==.',
['闫艳']='闫艳:BAAALgAECgEJAQAAAA==.',
['闹闹']='闹闹丶:BAAALgAFFAIJAgAAAA==.',
['阿佛']='阿佛萝狄忒:BAABLgAECn8VAAIeAAkJ8hvgBgD4AgAeAAkJ8hvgBgD4AgAAAA==.',
['阿克']='阿克蒙德:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔忒沵斯:BAAALgAECgYJBgAAAA==.阿尔西弥丝:BAABLgAECn8VAAMKAAkJIha+CgDIAQAKAAgJbBO+CgDIAQALAAQJoBmFIwA8AQAAAA==.阿尔西弥偲:BAAALgAECgkJEAAAAA==.阿尔西弥斯:BAAALgAECgkJEAAAAA==.',
['阿拉']='阿拉托尔:BAAALgAECgQJBQAAAA==.',
['阿曼']='阿曼妮西斯:BAAALgAFFAIJAgAAAA==.',
['阿瑞']='阿瑞斯丶:BAACLgAFFH8VAAMEAAYJsBizCgB9AQAEAAUJsBizCgB9AQAZAAEJAADdGgAxAAAuAAQKfykAAgQACQmxIvkEAIQDAAQACQmxIvkEAIQDAAAA.阿瑞斯丶丶:BAABLgAECn8WAAIIAAgJbw8xHwABAgAIAAgJbw8xHwABAgAAAA==.',
['陈巨']='陈巨基:BAAALgAECgYJCgAAAA==.',
['随心']='随心所遇:BAAALgAECgQJBQAAAA==.',
['雨宫']='雨宫莲:BAAALgADCgIJAgAAAA==.',
['雨宮']='雨宮琉璃:BAAALgAECgYJEAAAAA==.',
['霸气']='霸气的蒜:BAAALgAECgQJBAAAAA==.',
['霸霸']='霸霸丷:BAAALgAFFAIJBAAAAA==.霸霸乛:BAAALgAECgkJDAAAAA==.霸霸朴道中:BAABLgAECn8fAAIDAAgJZxVHVQA4AgADAAgJZxVHVQA4AgAAAA==.',
['青阳']='青阳子:BAABLgAFFH8HAAIWAAMJLA6VHADvAAAWAAMJLA6VHADvAAAAAA==.',
['静涛']='静涛君:BAAALgADCgEJAQAAAA==.',
['音無']='音無响子:BAABLgAFFH8IAAIDAAMJhBu0JgAYAQADAAMJhBu0JgAYAQABLgAFFAYJCwADAMUbAA==.',
['领域']='领域丨暗调:BAAALgADCgcJBwAAAA==.',
['風巻']='風巻残雲:BAAALgAECgIJAgAAAA==.',
['风灵']='风灵亚当:BAAALgAECgQJBAAAAA==.',
['风行']='风行者灬圣光:BAAALgAECgQJBgAAAA==.风行者灬暗影:BAAALgAFFAIJAgAAAA==.',
['风袭']='风袭:BAAALgAFFAEJAQAAAA==.',
['风骚']='风骚无限:BAACLgAFFH8GAAINAAMJqg0bFwD0AAANAAMJqg0bFwD0AAAuAAQKfygAAg0ACAktI2gWAOMCAA0ACAktI2gWAOMCAAAA.',
['马骝']='马骝子会上树:BAAALgAECgYJBgAAAA==.',
['骁勇']='骁勇善德:BAAALgAECgYJCgAAAA==.',
['骰子']='骰子:BAAALgAECgQJBAAAAA==.',
['高压']='高压充电宝:BAABLgAECn8VAAMCAAYJ/w1yJwA4AQACAAYJ/w1yJwA4AQAFAAQJvAvLSQCuAAAAAA==.',
['鬼煞']='鬼煞:BAAALgAECgcJCwAAAA==.',
['鬼舞']='鬼舞娃娃:BAAALgAFFAIJAgAAAA==.',
['鬼魅']='鬼魅银雪:BAAALgAECgEJAQAAAA==.',
['魂淡']='魂淡蘑菇:BAAALgAECgIJAgAAAA==.',
['魔二']='魔二代:BAAALgAECgYJBwAAAA==.',
['魔头']='魔头琉:BAAALgAECgQJCAAAAA==.',
['魔灵']='魔灵亚当:BAABLgAFFH8FAAIDAAUJYgWFEwB9AQADAAUJYgWFEwB9AQAAAA==.',
['魔煞']='魔煞:BAAALgADCgEJAQAAAA==.',
['魔理']='魔理沙酱:BAAALgADCgEJAQAAAA==.',
['魔能']='魔能术:BAAALgADCgUJBQAAAA==.',
['鲨鱼']='鲨鱼辣椒:BAAALgAECgcJCgAAAA==.',
['鳯玉']='鳯玉瑶:BAAALgAECgEJAQAAAA==.',
['鳴寂']='鳴寂:BAACLgAFFH8HAAMNAAMJgw0SKQCUAAANAAIJhAgSKQCUAAASAAMJeQUlGQB2AAAuAAQKfyYAAw0ACAlXFZxFABMCAA0ACAlXFZxFABMCABIACAlRCRwLAI4BAAAA.',
['鳴越']='鳴越:BAAALgAECgEJAQAAAA==.',
['鸠摩']='鸠摩智:BAAALgADCgEJAQAAAA==.',
['麻烦']='麻烦加个血:BAAALgADCggJCAAAAA==.',
['黄东']='黄东来:BAAALgAECgYJCwAAAA==.',
['黑曼']='黑曼波丨朵特:BAAALgAECgcJCAABLgAFFAIJAwAMAAAAAA==.',
['黑焱']='黑焱:BAAALgADCgYJCwAAAA==.',
['黑皮']='黑皮小痞狼:BAAALgAECgIJAwAAAA==.',
['黑色']='黑色大杀器:BAAALgADCgEJAQAAAA==.黑色诱丝:BAAALgAECgQJBAAAAA==.',
['龙之']='龙之修罗:BAAALgAECgYJBgAAAA==.',
['龙虎']='龙虎少年队:BAABLgAECn8YAAIEAAgJfxbuDAC4AQAEAAgJfxbuDAC4AQAAAA==.',
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
