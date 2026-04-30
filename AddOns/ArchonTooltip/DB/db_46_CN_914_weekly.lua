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

local lookup = {'DeathKnight-Blood','Warlock-Demonology','Evoker-Augmentation','Priest-Discipline','DeathKnight-Frost','DeathKnight-Unholy','Rogue-Assassination','Monk-Brewmaster','Mage-Frost','Unknown-Unknown','Druid-Balance','Shaman-Restoration','Paladin-Retribution','Warrior-Fury','Warrior-Arms','DemonHunter-Havoc','Mage-Arcane','DemonHunter-Devourer','Druid-Guardian','Monk-Mistweaver','Druid-Restoration','Priest-Shadow','Priest-Holy','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation','Warlock-Destruction','DemonHunter-Vengeance',}
local provider = {region='CN',realm='安东尼达斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Arrebol:BAAALgADCgUJBAAAAA==.',
Ba='Baobaod:BAAALgAECgYJBgAAAA==.',
De='Dekey:BAAALgAECgYJDAAAAA==.Demage:BAAALgADCgcJCgAAAA==.',
Di='Dime:BAABLgAFFH8FAAIBAAIJtgKQEwBWAAABAAIJtgKQEwBWAAAAAA==.',
Do='Dollarsa:BAAALgAECgYJBwAAAA==.',
Dr='Dreamfyre:BAAALgAECgMJAwAAAA==.',
Fe='Felithoth:BAAALgAFFAEJAQABLgAECggJIQACALEgAA==.',
Fo='Foxx:BAAALgADCgMJAwAAAA==.',
Io='Io:BAABLgAFFH8FAAIDAAIJoxRxGgCYAAADAAIJoxRxGgCYAAAAAA==.',
Jv='Jv:BAAALgADCgEJAQAAAA==.',
Ka='Kayanomi:BAACLgAFFH8MAAIEAAQJ3iNZAgCzAQAEAAQJ3iNZAgCzAQAuAAQKfxoAAgQABwltI5MHAMkCAAQABwltI5MHAMkCAAAA.',
Ku='Kumo:BAABLgAECn8bAAMFAAkJCyETAAAdAwAFAAkJCyETAAAdAwAGAAkJYxO4PABEAgAAAA==.',
La='Laxixi:BAAALgAFFAIJAwAAAA==.',
Li='Liqi:BAAALgAFFAEJAgAAAA==.',
Ll='Lldruid:BAAALgAECgEJAQAAAA==.',
Ne='Neol:BAAALgAECgYJEAAAAA==.',
No='Noct:BAAALgAECgEJAQAAAA==.',
Or='Ori:BAAALgAECgYJCwABLgAFFAIJBQADAKMUAA==.',
Po='Pollyanna:BAABLgAFFH8FAAIGAAUJcgoXCwA3AQAGAAUJcgoXCwA3AQAAAA==.',
Re='Remixdk:BAAALgAECgEJAQAAAA==.',
Ri='Riong:BAABLgAFFH8JAAIHAAQJwRZaAACGAQAHAAQJwRZaAACGAQAAAA==.',
Sa='Sanin:BAABLgAFFH8NAAIIAAQJnBTdBABEAQAIAAQJnBTdBABEAQAAAA==.',
So='Soaih:BAAALgADCgUJBQAAAA==.Sonny:BAAALgAECgUJCgAAAA==.',
To='Tobecc:BAAALgAECgEJAwAAAA==.',
Tu='Tueur:BAAALgAECgIJAgAAAA==.',
Wl='Wldr:BAAALgADCgQJBAAAAA==.',
Yf='Yfhu:BAACLgAFFH8HAAIJAAMJ6CI1IQA9AQAJAAMJ6CI1IQA9AQAuAAQKfxoAAgkABwnyJDI9AIMCAAkABwnyJDI9AIMCAAAA.',
Zh='Zhilian:BAAALgAECgQJBAAAAA==.',
['一个']='一个字:BAAALgAECgUJBQABLgAECgYJBwAKAAAAAA==.',
['一头']='一头钢毛:BAAALgAFFAIJAgAAAA==.',
['一笑']='一笑:BAAALgAECgcJDQAAAA==.',
['一般']='一般通过战:BAAALgAECgYJCQAAAA==.',
['三千']='三千琉璃月:BAAALgAECgcJDAAAAA==.',
['下雨']='下雨踩水玩:BAAALgAECgMJAwAAAA==.',
['丘山']='丘山:BAAALgADCgYJDQAAAA==.',
['丨无']='丨无敌炉石丨:BAAALgAECgYJBgAAAA==.',
['丫丫']='丫丫鱼:BAAALgADCgMJBAAAAA==.',
['中薯']='中薯:BAABLgAECn8XAAMGAAcJ4x1bNwBZAgAGAAcJsRtbNwBZAgABAAMJ4w4kNACfAAABLgAFFAQJCAAGABcaAA==.',
['临鹿']='临鹿:BAAALgADCgEJAQAAAA==.',
['丶丶']='丶丶七:BAAALgAFFAQJBAAAAA==.',
['丶圣']='丶圣愈:BAAALgAECgIJAgAAAA==.',
['丶小']='丶小冰块:BAABLgAECn8cAAIGAAcJ8R0uQAA4AgAGAAcJ8R0uQAA4AgAAAA==.丶小烈:BAAALgAECgUJBQAAAA==.',
['丷夜']='丷夜火琉萤丷:BAAALgAECgYJCwAAAA==.',
['丿唐']='丿唐宋元明清:BAAALgAECgQJBQAAAA==.',
['于晦']='于晦暗中期许:BAAALgAECggJDQAAAA==.',
['云淡']='云淡月明:BAAALgAFFAIJAwAAAA==.',
['云边']='云边落叶:BAAALgADCgYJBgABLgAFFAIJAgAKAAAAAA==.',
['五分']='五分糖:BAAALgAECgEJAQAAAA==.',
['五百']='五百城茉央:BAAALgAFFAMJAwAAAA==.',
['亚历']='亚历山德罗斯:BAAALgAECgcJDAAAAA==.',
['伊利']='伊利达雷之怒:BAAALgAECgYJBgAAAA==.',
['伍百']='伍百城茉央:BAABLgAFFH8FAAILAAUJChHqBgB0AQALAAUJChHqBgB0AQAAAA==.',
['优秀']='优秀士兵:BAAALgAFFAIJAwAAAA==.',
['佑一']='佑一:BAAALgADCgEJAQAAAA==.',
['你好']='你好西瓜先森:BAAALgAECgcJBwAAAA==.',
['你是']='你是我的阳光:BAAALgADCgIJAgAAAA==.你是老变态:BAAALgAECgMJAwAAAA==.',
['假奶']='假奶量:BAACLgAFFH8IAAIMAAQJYQzdBwAEAQAMAAQJYQzdBwAEAQAuAAQKfxcAAgwABgl0DzZTADkBAAwABgl0DzZTADkBAAAA.',
['假装']='假装没事:BAAALgADCgEJAQAAAA==.',
['元旦']='元旦:BAAALgAFFAIJAgAAAA==.',
['光明']='光明使者丶烈:BAAALgAECgEJAQAAAA==.光明内敛:BAAALgAECgMJAwAAAA==.',
['冰法']='冰法帝冰箱:BAAALgADCgIJAgAAAA==.',
['冰魄']='冰魄卡尔德:BAAALgADCgEJAQAAAA==.',
['刺灭']='刺灭:BAAALgAECgUJBQAAAA==.',
['劣丶']='劣丶人:BAAALgAECgMJAwAAAA==.',
['南瓜']='南瓜大魔王:BAAALgADCgcJBwAAAA==.',
['变不']='变不够的文森:BAAALgADCgcJBwAAAA==.',
['叶樱']='叶樱莲:BAAALgADCgIJAgAAAA==.',
['吴启']='吴启占:BAACLgAFFH8IAAINAAMJ9yE/DwAvAQANAAMJ9yE/DwAvAQAuAAQKfxsAAg0ABwnkJYsQAAsDAA0ABwnkJYsQAAsDAAAA.',
['和光']='和光丨同尘:BAAALgADCgEJAQAAAA==.',
['咕神']='咕神降临:BAAALgAECgUJBQABLgAFFAQJCgACADgjAA==.',
['哈基']='哈基爆:BAACLgAFFH8LAAIOAAQJDyUTBACzAQAOAAQJDyUTBACzAQAuAAQKfxkAAw4ABwluJiUKAA4DAA4ABwlNJiUKAA4DAA8AAQlsJacxAG0AAAAA.',
['喂那']='喂那个骑士:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血七天:BAAALgAECgIJAgAAAA==.',
['嘟嘟']='嘟嘟武僧:BAAALgAECgkJDAAAAA==.',
['图拉']='图拉菲:BAAALgAECgYJBgAAAA==.',
['土豆']='土豆地蕾斌:BAACLgAFFH8OAAQGAAQJaRrEEQBaAQAGAAQJaRrEEQBaAQABAAIJ5gynCACIAAAFAAEJkAA7BgA9AAAuAAQKfxYAAwYACAn1HSE/ADsCAAYABwndHyE/ADsCAAEABgkhGGkIADABAAAA.',
['圣锋']='圣锋:BAAALgAECgYJEQAAAA==.',
['处处']='处处吻:BAABLgAFFH8FAAIIAAIJPgndHgB+AAAIAAIJPgndHgB+AAAAAA==.',
['夕恙']='夕恙:BAAALgADCgUJBQAAAA==.',
['多喝']='多喝冰水吧:BAAALgAECgIJAgAAAA==.',
['大丝']='大丝瓜:BAAALgADCgQJBAAAAA==.',
['大恐']='大恐龙:BAAALgAECggJDwABLgAFFAQJCAAGABcaAA==.',
['大明']='大明举重冠军:BAAALgAECgQJBAAAAA==.',
['大薯']='大薯:BAAALgAECgkJCAABLgAFFAQJCAAGABcaAA==.',
['奥利']='奥利雅:BAAALgAECgUJDAAAAA==.',
['如灯']='如灯灭时:BAACLgAFFH8NAAIQAAQJgiOYAACBAQAQAAQJgiOYAACBAQAuAAQKfxkAAhAABwkzJdMGAPkCABAABwkzJdMGAPkCAAAA.',
['宅男']='宅男宣:BAAALgAECgQJBwABLgAFFAMJBQADAGIfAA==.',
['尊尼']='尊尼获加丶:BAAALgAECgEJAwAAAA==.',
['對酒']='對酒當歌:BAAALgAECgYJBgAAAA==.',
['小剑']='小剑人:BAAALgAFFAIJBAAAAA==.',
['小小']='小小斌下士:BAAALgAFFAEJAgAAAA==.',
['小法']='小法:BAABLgAFFH8GAAIJAAIJNAj9JwCYAAAJAAIJNAj9JwCYAAAAAA==.',
['小浣']='小浣熊丶:BAAALgAECgYJCQAAAA==.',
['小熊']='小熊干饼:BAAALgADCgMJAwAAAA==.',
['小虾']='小虾吞饭:BAAALgAECgUJBQAAAA==.',
['小鸡']='小鸡毛自己玩:BAAALgAECgQJBAAAAA==.',
['岁月']='岁月安然:BAAALgAECgYJCAAAAA==.',
['巨魔']='巨魔还是精灵:BAAALgAECgcJEAAAAA==.',
['已断']='已断开连接:BAACLgAFFH8LAAIJAAQJkgZDEQAnAQAJAAQJkgZDEQAnAQAuAAQKfx4AAxEABwl2GqMKADEBAAkABgmhGZWKAL0BABEABQl1FqMKADEBAAAA.',
['希幻']='希幻:BAAALgAECgMJAwAAAA==.',
['帝国']='帝国拉面摄政:BAAALgAECgIJAgABLgAECgcJHQASANMUAA==.',
['帝狱']='帝狱咆哮:BAAALgAECgYJCAAAAA==.',
['幽夜']='幽夜小猎:BAAALgAECgQJBAAAAA==.幽夜小骑:BAAALgAECgIJAwAAAA==.',
['弑灬']='弑灬梦:BAAALgADCgIJAgAAAA==.',
['张洛']='张洛南:BAABLgAFFH8FAAICAAUJGgZqDgAbAQACAAUJGgZqDgAbAQAAAA==.',
['张顺']='张顺飞要分钱:BAAALgAECgEJAQAAAA==.',
['张飞']='张飞:BAAALgAFFAEJAwAAAA==.',
['彪悍']='彪悍的小德:BAABLgAFFH8GAAITAAMJbQMfBQBrAAATAAMJbQMfBQBrAAAAAA==.',
['影之']='影之咆哮:BAAALgAECgcJBwAAAA==.',
['待我']='待我胸毛即腰:BAAALgADCgYJBgAAAA==.待我胸毛及腰:BAABLgAFFH8GAAIMAAIJ2iNLEgDSAAAMAAIJ2iNLEgDSAAAAAA==.待我胸髦及腰:BAAALgAFFAIJAwAAAA==.',
['御魂']='御魂午马:BAAALgADCgcJCQAAAA==.',
['心灵']='心灵圣牧:BAAALgAFFAEJAQAAAA==.',
['恨海']='恨海情天:BAAALgADCgcJBwAAAA==.',
['恬淡']='恬淡晴天:BAACLgAFFH8MAAIUAAQJnA3LCAAtAQAUAAQJnA3LCAAtAQAuAAQKfxQAAhQABwlFFTwhAKsBABQABwlFFTwhAKsBAAAA.',
['慕公']='慕公爵:BAAALgAFFAEJAQAAAA==.',
['我可']='我可以变鸟:BAAALgAECgIJAgAAAA==.',
['我的']='我的脚好臭:BAAALgAECgYJBgAAAA==.',
['我累']='我累个逗:BAAALgADCgYJCQAAAA==.',
['战锋']='战锋芒:BAAALgAECgYJCAAAAA==.',
['手术']='手术中:BAAALgADCggJCAAAAA==.',
['折耳']='折耳小狮叽:BAACLgAFFH8GAAIOAAMJaxUdDwATAQAOAAMJaxUdDwATAQAuAAQKfyAAAg4ABwn8I3kEAA8CAA4ABwn8I3kEAA8CAAAA.',
['抽红']='抽红塔:BAAALgAECgIJAwAAAA==.',
['拏云']='拏云握雾:BAAALgAECgEJAQAAAA==.',
['指导']='指导抬手就毛:BAAALgADCgEJAQAAAA==.',
['排水']='排水盾:BAAALgAECgYJDgAAAA==.',
['提小']='提小米:BAABLgAFFH8IAAIVAAMJaw9GEgDXAAAVAAMJaw9GEgDXAAAAAA==.',
['提米']='提米:BAAALgADCgUJBQAAAA==.',
['擎天']='擎天白钰柱:BAAALgAECgYJBgABLgAECgcJHQASANMUAA==.',
['敌意']='敌意偶偶:BAAALgAECgEJAQAAAA==.',
['数量']='数量更改:BAAALgAECgYJBgAAAA==.',
['斯莱']='斯莱顿:BAAALgAECgEJAQAAAA==.',
['无财']='无财便是德:BAAALgAECgYJCAAAAA==.',
['时代']='时代变了钴丹:BAAALgAECgEJAQABLgAFFAQJCQAUADcQAA==.',
['明眸']='明眸善导:BAAALgADCgIJAgAAAA==.',
['明石']='明石:BAACLgAFFH8NAAMWAAQJbA62CAA4AQAWAAQJbA62CAA4AQAEAAMJEg0hCADyAAAuAAQKfyQABBYACAkzHfkLAMMCABYACAkzHfkLAMMCAAQABwkOIdENAF0CABcAAQl4BCGCAC8AAAAA.',
['星芒']='星芒月幻:BAAALgAFFAEJAQAAAA==.',
['暗矛']='暗矛战:BAAALgAECgcJBwAAAA==.',
['暴怒']='暴怒蜗牛:BAAALgAECgMJAwAAAA==.',
['暴血']='暴血:BAAALgADCggJCAAAAA==.',
['月亮']='月亮来了:BAAALgADCgMJAwAAAA==.',
['月夜']='月夜乂舞者:BAAALgAECgQJBAAAAA==.',
['朝花']='朝花惜时:BAAALgADCgEJAgAAAA==.',
['木木']='木木沐:BAAALgADCgcJBwAAAA==.',
['来杯']='来杯夏威夷:BAAALgADCgIJAgAAAA==.来杯白兰地:BAAALgAECgQJBQAAAA==.',
['枫糖']='枫糖总帅:BAAALgAECgYJBgAAAA==.',
['柒索']='柒索:BAAALgAECgQJBAAAAA==.',
['梅塔']='梅塔特隆:BAAALgAECgEJAQAAAA==.',
['梨花']='梨花千树:BAAALgAFFAMJAwAAAA==.',
['橘雪']='橘雪莉:BAAALgAFFAIJAgAAAA==.',
['橙訫']='橙訫橙懿:BAABLgAECn8ZAAMWAAgJZRspFQBDAgAWAAcJEh0pFQBDAgAXAAMJugt2ZACcAAABLgAFFAEJAQAKAAAAAA==.',
['欧力']='欧力爹:BAAALgAECgQJBQAAAA==.',
['欧墨']='欧墨尼德斯:BAAALgAECgYJCgAAAA==.',
['武僧']='武僧武松:BAAALgAFFAIJBAAAAA==.',
['歪比']='歪比丨丶巴卜:BAAALgADCgEJAQAAAA==.',
['死亡']='死亡之握:BAAALgAFFAIJAwAAAA==.',
['残丶']='残丶梦:BAAALgAFFAIJAgAAAA==.',
['洪红']='洪红尘辰:BAAALgAECgQJBAAAAA==.',
['流星']='流星奶糖:BAAALgAFFAEJAQAAAA==.',
['浪丿']='浪丿人:BAAALgAECgMJAwAAAA==.',
['海苔']='海苔饭团:BAAALgADCgYJBgAAAA==.',
['淘气']='淘气的橙子:BAABLgAECn8UAAIXAAYJ6BcPLwCGAQAXAAYJ6BcPLwCGAQAAAA==.',
['淮海']='淮海雲龍:BAAALgAECgUJCQAAAA==.',
['淳安']='淳安啊:BAAALgAECgQJBAAAAA==.',
['混乱']='混乱打计:BAAALgADCgUJBQAAAA==.',
['清风']='清风夜下:BAABLgAFFH8GAAIQAAMJzAlPBgDsAAAQAAMJzAlPBgDsAAAAAA==.',
['潘达']='潘达华斯基:BAACLgAFFH8JAAIUAAQJNxDbCAAsAQAUAAQJNxDbCAAsAQAuAAQKfxoAAhQACAn9H+8IAMYCABQACAn9H+8IAMYCAAAA.',
['灬亞']='灬亞夫灬:BAABLgAECn8VAAIGAAcJqRn7TgAFAgAGAAcJqRn7TgAFAgAAAA==.',
['灬骨']='灬骨灵冷火:BAAALgAECgkJCQAAAA==.',
['灼耀']='灼耀:BAAALgAECgYJCAAAAA==.',
['焚身']='焚身:BAAALgAECgYJBgAAAA==.',
['然莫']='然莫:BAAALgAECgEJAQAAAA==.',
['狐护']='狐护符:BAAALgAECgYJBgAAAA==.',
['狼心']='狼心狗肺:BAAALgAECgYJCgAAAA==.',
['猫氏']='猫氏财团叫兽:BAAALgAFFAIJAgAAAA==.',
['瓜瓜']='瓜瓜:BAABLgAFFH8HAAINAAMJeBO2EwCuAAANAAMJeBO2EwCuAAAAAA==.',
['生于']='生于若水彼岸:BAAALgAECgMJAwAAAA==.',
['田文']='田文镜我:BAAALgAFFAIJAgAAAA==.',
['白雪']='白雪红颜:BAAALgAFFAIJBAAAAA==.',
['直接']='直接删号:BAAALgAECgIJAgAAAA==.',
['直男']='直男宣:BAACLgAFFH8FAAIDAAMJYh9dDgAbAQADAAMJYh9dDgAbAQAuAAQKfxcAAxgACAkgIuUDANcCABgABwndI+UDANcCAAMABQmlHGwjAKIBAAAA.',
['相沢']='相沢綾香:BAAALgAECgYJDAAAAA==.',
['真心']='真心犹在:BAABLgAFFH8IAAMZAAMJigvACwD5AAAZAAMJHAvACwD5AAAaAAIJiAQjIQCNAAAAAA==.',
['真是']='真是太烧了:BAAALgADCgcJBwAAAA==.',
['知世']='知世郎:BAAALgAECgUJBgAAAA==.',
['知了']='知了:BAAALgAECgYJBwAAAA==.',
['石头']='石头哥哥丶:BAAALgAECgUJBgAAAA==.',
['碧风']='碧风浩扬:BAABLgAECn8eAAQYAAgJeBGFHQBCAQAYAAYJLAyFHQBCAQAbAAYJwxANKgAiAQADAAUJFRHzGAC0AAAAAA==.',
['站不']='站不稳的文森:BAAALgAECgQJBgAAAA==.',
['笨蛋']='笨蛋的天空:BAAALgAECgEJAgAAAA==.',
['糕高']='糕高手:BAAALgAECgUJBQABLgAFFAQJCwASAFAUAA==.',
['糟佬']='糟佬头:BAAALgAECgYJEQAAAA==.',
['红小']='红小辰:BAAALgAECgQJBAAAAA==.',
['纸魔']='纸魔:BAAALgAFFAIJAwAAAA==.',
['组个']='组个嗜血:BAAALgAECgMJBgAAAA==.',
['给自']='给自己的信:BAAALgAFFAIJAgABLgAFFAYJEAAGAC0hAA==.',
['绾妤']='绾妤:BAAALgADCgcJBwAAAA==.',
['罗罗']='罗罗汤马西:BAAALgAECgIJAgABLgAFFAIJAwAKAAAAAA==.',
['美团']='美团外卖小哥:BAAALgADCgEJAQAAAA==.',
['翠微']='翠微:BAAALgAECgQJBAAAAA==.',
['耀星']='耀星:BAAALgAECgEJAQAAAA==.',
['艾尔']='艾尔丶誓阳:BAAALgAECgYJCAAAAA==.',
['花有']='花有重开之时:BAABLgAFFH8FAAMCAAUJyxe3DwARAQACAAQJgBu3DwARAQAcAAEJqwxmBABjAAAAAA==.',
['苍蝇']='苍蝇大王指导:BAAALgAECgUJBQAAAA==.',
['苦瓜']='苦瓜:BAACLgAFFH8MAAIJAAQJWBlCGABpAQAJAAQJWBlCGABpAQAuAAQKfxsAAgkABwlbI/YsAL4CAAkABwlbI/YsAL4CAAAA.',
['英勇']='英勇汉堡王:BAABLgAFFH8FAAMaAAMJEw1JFwDeAAAaAAMJYQpJFwDeAAAZAAEJdhpOIQBeAAAAAA==.',
['萧炎']='萧炎:BAACLgAFFH8IAAIGAAQJWCH9AgCEAQAGAAQJWCH9AgCEAQAuAAQKfyEAAgYACQnMJaAAAOcDAAYACQnMJaAAAOcDAAEuAAUUBAkIAAYAFxoA.',
['萧萧']='萧萧暮雨咕咕:BAAALgAECgIJAwAAAA==.',
['葡萄']='葡萄:BAAALgAFFAIJAwAAAA==.',
['虚无']='虚无的壁垒:BAAALgAECgYJCAAAAA==.',
['血色']='血色修道院:BAAALgAECgUJCAAAAA==.',
['裹脚']='裹脚布会飞吗:BAAALgAECgQJBAAAAA==.',
['豆丨']='豆丨油:BAACLgAFFH8RAAILAAUJdBvYAwCxAQALAAUJdBvYAwCxAQAuAAQKfyUAAgsACAlKJRgEAGUDAAsACAlKJRgEAGUDAAAA.',
['豆豆']='豆豆睡觉觉:BAAALgADCgIJAgAAAA==.',
['败笑']='败笑秋风:BAAALgAFFAEJAQAAAA==.',
['超级']='超级爆爆龙:BAAALgAECgYJBgABLgAECgYJBwAKAAAAAA==.',
['超绝']='超绝体育生:BAABLgAFFH8IAAIGAAQJqRf8EQBZAQAGAAQJqRf8EQBZAQAAAA==.',
['趣踏']='趣踏玛德:BAAALgAECgYJDgAAAA==.',
['这是']='这是一个戰士:BAAALgAECgEJAQAAAA==.',
['远航']='远航星:BAABLgAFFH8NAAIDAAQJ7hWKCwBBAQADAAQJ7hWKCwBBAQAAAA==.',
['邪刃']='邪刃战姬:BAABLgAFFH8GAAIdAAIJAwGSBABVAAAdAAIJAwGSBABVAAAAAA==.',
['邪怒']='邪怒:BAAALgAECgQJBAAAAA==.',
['酷酷']='酷酷的牛头人:BAAALgAECgMJBAAAAA==.',
['铃仙']='铃仙:BAAALgADCgYJBgAAAA==.',
['阿丝']='阿丝塔莉:BAAALgAECgEJAQAAAA==.',
['阿克']='阿克喵德:BAAALgAECgUJBQAAAA==.',
['阿姆']='阿姆斯特壮:BAAALgADCgYJBgAAAA==.',
['阿尔']='阿尔撒斯:BAAALgAECgYJCQAAAA==.',
['阿斯']='阿斯普洛斯:BAAALgAECgUJBwAAAA==.',
['雁啼']='雁啼:BAABLgAFFH8FAAIZAAQJZRIgBABYAQAZAAQJZRIgBABYAQAAAA==.',
['雪之']='雪之下的情愫:BAAALgAFFAIJAwAAAA==.',
['雪灬']='雪灬詠恆:BAAALgAECgcJCgAAAA==.',
['雪路']='雪路浪游:BAABLgAFFH8FAAIUAAUJvxYUBACpAQAUAAUJvxYUBACpAQAAAA==.',
['顽昧']='顽昧:BAABLgAFFH8GAAIWAAIJpAhrEACiAAAWAAIJpAhrEACiAAAAAA==.',
['风流']='风流周少喔:BAAALgAECgYJDgAAAA==.',
['风游']='风游:BAACLgAFFH8KAAMaAAQJ+xZxFgDnAAAaAAMJ2RFxFgDnAAAZAAEJYiYuHAB1AAAuAAQKfxYAAxoABwlDIqIkAP8BABoABwllHqIkAP8BABkABAmFJik9ALoBAAAA.',
['风语']='风语德兰泰:BAAALgADCgUJBQABLgAECgcJGQAJAP8WAA==.',
['飞翔']='飞翔滴小恶魔:BAAALgADCgMJAwAAAA==.',
['饕餮']='饕餮战神:BAAALgAFFAIJAwAAAA==.',
['馒头']='馒头:BAABLgAFFH8JAAICAAUJMwBiNACqAAACAAUJMwBiNACqAAAAAA==.',
['首领']='首领:BAAALgAECgQJBQAAAA==.',
['马鲁']='马鲁卡凯多:BAAALgADCgYJBgAAAA==.',
['骏小']='骏小哥:BAAALgAFFAIJAgAAAA==.骏小爷:BAACLgAFFH8HAAICAAMJeRjxHQAMAQACAAMJeRjxHQAMAQAuAAQKfxcAAwIABgkAIQI4ACwCAAIABgkAIQI4ACwCABwAAQniAAaAABMAAAAA.',
['高小']='高小柒:BAABLgAFFH8FAAINAAQJUxV9BABhAQANAAQJUxV9BABhAQAAAA==.',
['高糕']='高糕手:BAACLgAFFH8LAAISAAQJUBR+EgA9AQASAAQJUBR+EgA9AQAuAAQKfzQAAxIACAl8JNMJADgDABIACAl8JNMJADgDABAAAgmhDQRiAFoAAAAA.',
['魔域']='魔域龙华:BAAALgAECgMJBAAAAA==.',
['魔帅']='魔帅瑝影:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法少女小爆:BAAALgAFFAMJAwAAAA==.',
['魔魂']='魔魂申猴:BAAALgADCgEJAQAAAA==.',
['鱼忆']='鱼忆海七秒:BAAALgAECgUJBQAAAA==.',
['鹰头']='鹰头猫:BAABLgAECn8dAAISAAcJ0xQ9XQCJAQASAAcJ0xQ9XQCJAQAAAA==.',
['鹿港']='鹿港:BAAALgAECgcJDAAAAA==.',
['麻麻']='麻麻的:BAAALgADCgQJBAAAAA==.',
['龙之']='龙之帝:BAAALgAECgQJBwAAAA==.',
['龙脊']='龙脊居士:BAAALgAECgYJDQAAAA==.',
['龙随']='龙随中原:BAAALgAECgMJAwAAAA==.',
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
