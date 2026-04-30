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

local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Frost','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Shaman-Elemental','Warlock-Demonology','DeathKnight-Unholy','Paladin-Retribution','Warlock-Destruction','Shaman-Restoration','Unknown-Unknown','Druid-Balance','Druid-Restoration','Rogue-Subtlety','Rogue-Assassination','Paladin-Holy','DemonHunter-Devourer','DemonHunter-Havoc',}
local provider = {region='CN',realm='风暴之鳞',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Arthascris:BAAALgAECgUJBgAAAA==.',
Dd='Dd:BAACLgAFFH8IAAIBAAMJZBn3BwAlAQABAAMJZBn3BwAlAQAuAAQKfx4AAgEACAmTIFQNANQCAAEACAmTIFQNANQCAAEuAAUUBgkFAAIAJAsA.Ddkk:BAAALgAECgYJCwAAAA==.',
En='Entering:BAAALgAECgIJAgAAAA==.Envystar:BAACLgAFFH8RAAQDAAUJJSMiAgCTAQAEAAQJ+SH0BACbAQADAAQJgh4iAgCTAQAFAAEJDg/qDQBNAAAuAAQKfyYABAMACAlAJSoFAP0CAAMACAmyICoFAP0CAAQABwmUJEcGAOUCAAUAAwkBHYJDAN8AAAAA.',
Gr='Grand:BAAALgAECgQJBgAAAA==.',
Ho='How:BAAALgADCgMJAwAAAA==.',
Ia='Iansomerhar:BAAALgADCgcJCwAAAA==.',
Ka='Kaito:BAAALgAECgQJBAAAAA==.Kamikaze:BAAALgAECgUJDgAAAA==.Karlos:BAAALgAECgIJAgAAAA==.',
Ne='Nestea:BAACLgAFFH8JAAIGAAQJER1vEwAXAQAGAAQJER1vEwAXAQAuAAQKfyEAAgYACAkSIzMUAC8DAAYACAkSIzMUAC8DAAAA.',
Qx='Qxx:BAAALgADCgIJAgAAAA==.',
Re='Reborn:BAAALgAECgYJCgAAAA==.',
Te='Teamantmonk:BAACLgAFFH8KAAQHAAQJRQ5ZDQDOAAAHAAMJ5AlZDQDOAAAIAAIJ7QW1EgBIAAAJAAEJ2hVAJQBEAAAuAAQKfxcABAcACAmUEkUcANYBAAcACAmUEkUcANYBAAgABwmLG1UiAMMBAAkAAQmqF+iHADYAAAAA.',
Tu='Tunny:BAAALgAECgcJDQAAAA==.',
Ty='Tydk:BAAALgAECgQJBgAAAA==.',
Wh='Whiteswan:BAABLgAFFH8FAAIDAAMJ9QhXCQDRAAADAAMJ9QhXCQDRAAAAAA==.',
Ws='Wsnd:BAAALgADCgQJBAAAAA==.',
['一卷']='一卷冰雪挽情:BAAALgADCgYJBgAAAA==.',
['丶俊']='丶俊:BAAALgAECgEJAgAAAA==.',
['丶随']='丶随意:BAAALgAECgUJBgAAAA==.',
['主宰']='主宰天地间:BAAALgADCgUJBQAAAA==.',
['丿訫']='丿訫:BAAALgAECgMJBQAAAA==.',
['乌寒']='乌寒华:BAAALgAECgUJBQAAAA==.',
['乱跑']='乱跑跑丨:BAACLgAFFH8MAAIKAAQJ6QuACwAyAQAKAAQJ6QuACwAyAQAuAAQKfxsAAgoACAljHEwSAJACAAoACAljHEwSAJACAAAA.',
['云卷']='云卷云舒丶:BAAALgAECgEJAQAAAA==.',
['五香']='五香小土豆:BAAALgAECgIJAgAAAA==.',
['亲亲']='亲亲我的蓓蓓:BAAALgAFFAEJAQABLgAFFAUJBQALAH8lAA==.',
['人总']='人总是在受罪:BAACLgAFFH8HAAIGAAQJhBJcHABaAQAGAAQJhBJcHABaAQAuAAQKfxkAAgYABglkExw9AAIBAAYABglkExw9AAIBAAEuAAUUBQkGAAYAGgoA.人总是在死亡:BAACLgAFFH8GAAIMAAMJNBSlIwAHAQAMAAMJNBSlIwAHAQAuAAQKfxoAAgwABwlpHZlBADMCAAwABwlpHZlBADMCAAAA.人总是在颓废:BAABLgAECn8dAAINAAcJBxvkRgAPAgANAAcJBxvkRgAPAgABLgAFFAMJBgAMADQUAA==.',
['仇伍']='仇伍仁化:BAAALgAECgUJBgAAAA==.',
['伊泽']='伊泽瑞尔丿:BAAALgAECgYJBQAAAA==.',
['你的']='你的名字很美:BAAALgAECggJBQAAAA==.',
['傻琪']='傻琪玛:BAAALgADCgkJCQAAAA==.',
['克尼']='克尼克尼:BAAALgAFFAMJBAAAAA==.',
['克拉']='克拉苏斯:BAAALgAECgYJBwAAAA==.',
['兰科']='兰科曼:BAAALgADCgUJBQAAAA==.',
['冰凌']='冰凌恋:BAAALgAECgYJBgAAAA==.',
['冰柠']='冰柠檬丶:BAAALgADCgUJBQAAAA==.',
['刺刺']='刺刺背:BAAALgAECgYJBgAAAA==.',
['加把']='加把劲骑士:BAAALgADCgEJAQAAAA==.',
['北落']='北落師門:BAAALgADCgEJAQAAAA==.',
['北辰']='北辰亡裔:BAAALgAECgYJCAAAAA==.',
['医保']='医保:BAAALgAECgIJAgAAAA==.',
['千早']='千早星井:BAAALgAECgIJAwAAAA==.',
['千玉']='千玉千寻:BAAALgAECgUJCAAAAA==.',
['千里']='千里江陵:BAAALgAECgcJDAAAAA==.千里销魂香:BAAALgAECgIJAgAAAA==.',
['博文']='博文:BAABLgAFFH8IAAIMAAQJEhjfBgBWAQAMAAQJEhjfBgBWAQAAAA==.',
['叄花']='叄花聚顶:BAAALgAECgMJBQAAAA==.',
['反正']='反正不是我:BAAALgAECgMJAwAAAA==.',
['古尔']='古尔丹乄:BAAALgAECgEJAQAAAA==.',
['只会']='只会读火球:BAAALgAECgQJBQAAAA==.',
['可乐']='可乐小飞侠:BAAALgAECgEJAQAAAA==.',
['向往']='向往天空丶哈:BAAALgAECgEJAQAAAA==.',
['呗呗']='呗呗丶:BAAALgAECgUJBwAAAA==.呗呗龙:BAAALgAECgUJCQAAAA==.',
['咦鸡']='咦鸡娜慧:BAAALgAECgYJBgAAAA==.',
['哀月']='哀月:BAAALgAECgcJEwABLgAFFAUJCAAOAO0UAA==.',
['品尝']='品尝我的咸:BAAALgAECgEJAQAAAA==.',
['喜多']='喜多川海梦:BAAALgAFFAIJBAAAAA==.',
['嘿丶']='嘿丶来一发:BAAALgAECgYJDAAAAA==.',
['回忆']='回忆的地方:BAAALgAECgEJAQAAAA==.',
['园兴']='园兴投资集团:BAAALgAECgQJBQAAAA==.',
['圣云']='圣云星光:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光阿西利亚:BAAALgAECgIJAgAAAA==.',
['坚果']='坚果丶:BAAALgAECgEJAQAAAA==.',
['夕殇']='夕殇:BAAALgAECgYJBgABLgAECgcJFgAGAL0WAA==.',
['夜的']='夜的不死神:BAAALgADCgEJAQAAAA==.',
['大地']='大地之原:BAAALgADCgIJAgAAAA==.',
['大月']='大月亮丶:BAAALgADCgcJBwAAAA==.',
['失落']='失落的大黄:BAAALgAECgMJAwAAAA==.',
['奶龙']='奶龙大王:BAAALgADCgEJAQAAAA==.',
['如甜']='如甜蜜是凶手:BAABLgAFFH8NAAIPAAUJPhRmAwChAQAPAAUJPhRmAwChAQAAAA==.',
['妖精']='妖精伊布:BAAALgAECgcJDQAAAA==.',
['家有']='家有小牛船长:BAAALgADCgQJBAAAAA==.',
['射不']='射不准勿怪:BAAALgAECgEJAQAAAA==.',
['小小']='小小的太陽:BAAALgAFFAIJAgAAAA==.',
['小术']='小术也疯狂:BAAALgAECgEJAQAAAA==.',
['小林']='小林酱:BAACLgAFFH8MAAIEAAQJ1hZLCQBIAQAEAAQJ1hZLCQBIAQAuAAQKfyUAAgQACAmcIJYGAN8CAAQACAmcIJYGAN8CAAAA.',
['小白']='小白灬:BAABLgAFFH8GAAIMAAIJTBZMPAClAAAMAAIJTBZMPAClAAAAAA==.',
['小胖']='小胖蛋:BAAALgAECgUJAgAAAA==.',
['小骑']='小骑土:BAAALgAECgMJAwABLgAFFAQJBAAQAAAAAA==.',
['小龙']='小龙喵:BAAALgAECgEJAQABLgAECgIJAgAQAAAAAA==.',
['巜牧']='巜牧头人:BAABLgAFFH8HAAIFAAIJayATCADCAAAFAAIJayATCADCAAAAAA==.',
['巨大']='巨大肥猫:BAAALgADCgIJAgAAAA==.',
['帝凇']='帝凇:BAAALgAECgYJCgAAAA==.',
['异色']='异色眼柠檬心:BAABLgAECn8UAAMLAAYJeSKeTQDgAQALAAUJeSKeTQDgAQAOAAIJ4QHUSwCKAAAAAA==.',
['张小']='张小棍:BAAALgADCgkJCQAAAA==.',
['德不']='德不掉就毁到:BAAALgAECgIJAgAAAA==.',
['忘川']='忘川蒹葭:BAACLgAFFH8MAAMBAAQJKyRKAACtAQABAAQJxSNKAACtAQACAAMJIxN/FQDwAAAuAAQKfxwAAwIACAkZIVQRAKwCAAIACAkJH1QRAKwCAAEAAgmaIyovANQAAAAA.',
['快乐']='快乐火舞流沙:BAAALgAECgYJEQAAAA==.',
['怀草']='怀草诗:BAABLgAECn8UAAIDAAgJkgOTQQAyAQADAAgJkgOTQQAyAQAAAA==.',
['恶魔']='恶魔赦令:BAAALgAECgEJAQAAAA==.',
['悄悄']='悄悄咪咪射你:BAAALgAECgQJBAAAAA==.',
['愤怒']='愤怒的小火鸡:BAACLgAFFH8FAAIGAAIJxhpLOgC2AAAGAAIJxhpLOgC2AAAuAAQKfxUAAgYABwlwHiE5AJECAAYABwlwHiE5AJECAAAA.',
['我本']='我本纯洁:BAAALgAFFAMJAwAAAA==.',
['我比']='我比坐骑高:BAAALgAECgcJAQAAAA==.',
['扑街']='扑街小超:BAAALgAECgEJAQAAAA==.',
['打上']='打上花火:BAAALgAECgYJCQAAAA==.',
['护国']='护国神喵:BAAALgADCgYJBgAAAA==.',
['拉克']='拉克萨斯:BAABLgAECn8VAAINAAgJ+xPbTgD2AQANAAgJ+xPbTgD2AQAAAA==.',
['挥挥']='挥挥手全是狗:BAAALgAFFAIJAgAAAA==.',
['擎天']='擎天柱:BAAALgAECgYJBgAAAA==.',
['无敌']='无敌小术术:BAAALgAECgYJDwAAAA==.',
['无证']='无证骑士:BAACLgAFFH8LAAIMAAMJgBgKEwD5AAAMAAMJgBgKEwD5AAAuAAQKfycAAgwACAngHqUWAPQCAAwACAngHqUWAPQCAAAA.',
['明天']='明天天晴:BAAALgAECgIJAgAAAA==.',
['明明']='明明不吃蘑菇:BAAALgAECgEJAQAAAA==.',
['晴天']='晴天娃娃:BAAALgAFFAIJBAAAAA==.晴天小猪灬:BAAALgADCgEJAQAAAA==.',
['暗淡']='暗淡的光:BAAALgAECgcJBwAAAA==.',
['暧光']='暧光昧影:BAAALgAECgIJAgAAAA==.',
['暧門']='暧門小德:BAAALgADCgEJAQAAAA==.',
['木馬']='木馬摇摇乐:BAAALgADCgEJAQAAAA==.',
['术爷']='术爷来了:BAAALgAECgUJCAAAAA==.',
['果果']='果果猎:BAAALgADCgEJAQAAAA==.',
['梆梆']='梆梆两拳:BAACLgAFFH8NAAIJAAQJIBmFCABLAQAJAAQJIBmFCABLAQAuAAQKfyMAAgkACAltIqMHAAsDAAkACAltIqMHAAsDAAAA.',
['梦梦']='梦梦的石头:BAAALgAFFAEJAQAAAA==.',
['梦舞']='梦舞飘零:BAAALgAECgYJCwAAAA==.',
['欣欣']='欣欣相惜:BAAALgAFFAQJAwAAAA==.',
['死骑']='死骑小妹妹:BAAALgAECgcJDQAAAA==.',
['洛依']='洛依依:BAAALgAFFAEJAgAAAA==.',
['洛阿']='洛阿神佑之血:BAAALgAECgYJCAAAAA==.',
['流氓']='流氓的术师:BAAALgAECgkJBgABLgAFFAUJEAALAOAaAA==.',
['流風']='流風回雪:BAAALgAECgcJAQAAAA==.',
['浅陌']='浅陌灬初心:BAAALgAECgEJAgAAAA==.',
['海豚']='海豚炒年糕:BAAALgAECgkJDwAAAA==.',
['海阔']='海阔丶天空:BAACLgAFFH8MAAMRAAQJZSVfAwBXAQARAAQJZSVfAwBXAQASAAIJIBnIGACbAAAuAAQKfyYAAxEACAmLJQcFAFADABEACAmLJQcFAFADABIACAnCJL0FADEDAAAA.',
['灬寵']='灬寵愛灬:BAAALgAECgEJAQAAAA==.',
['灬漠']='灬漠名灬:BAAALgAECgUJBQAAAA==.',
['烟雨']='烟雨泷:BAAALgAECgMJAwABLgAFFAQJDAAEANYWAA==.烟雨落流星:BAAALgAECgQJCQAAAA==.',
['焚天']='焚天帝:BAAALgAECgYJDgAAAA==.',
['熊灬']='熊灬胖胖:BAAALgAFFAEJAgAAAA==.',
['爱吃']='爱吃鱼儿的喵:BAAALgAECgEJAQAAAA==.',
['爱吹']='爱吹大波浪:BAAALgADCgYJBgAAAA==.',
['爱里']='爱里失忆:BAAALgADCgQJBAAAAA==.',
['独步']='独步圣舞:BAAALgADCgIJAgAAAA==.',
['玉涛']='玉涛猎马龙:BAAALgAECgkJEAABLgAFFAcJDgAKAA8kAA==.',
['玻璃']='玻璃大炮丶:BAACLgAFFH8LAAIGAAQJMRngFQByAQAGAAQJMRngFQByAQAuAAQKfxkAAgYACAm9H9ErAMMCAAYACAm9H9ErAMMCAAAA.',
['田二']='田二狗:BAAALgAECgEJAQAAAA==.',
['痛苦']='痛苦的月色:BAAALgAECgIJAwAAAA==.',
['白羽']='白羽璃洛:BAAALgAECgYJDwAAAA==.',
['白色']='白色猫咪:BAAALgAECgUJBQAAAA==.',
['白霜']='白霜落尽:BAABLgAECn8WAAIGAAkJgAbcowCQAQAGAAkJgAbcowCQAQAAAA==.',
['矮油']='矮油我的腰:BAAALgAECgYJBgAAAA==.',
['神之']='神之慰:BAAALgADCgcJBwAAAA==.',
['神力']='神力:BAAALgAECgkJEAAAAA==.',
['离别']='离别的篇章:BAAALgADCgUJCAAAAA==.',
['立丶']='立丶夏:BAAALgADCgMJAwAAAA==.',
['粉皮']='粉皮丶骑:BAAALgAECgYJDAAAAA==.',
['索瑞']='索瑞森连山:BAAALgADCgEJAQABLgAECgIJAgAQAAAAAA==.',
['紫金']='紫金之魂:BAAALgAFFAEJAQAAAA==.',
['细小']='细小软:BAACLgAFFH8NAAIEAAQJNBIQCgA+AQAEAAQJNBIQCgA+AQAuAAQKfyQAAwQACAmmGg8LAIcCAAQACAl0Gg8LAIcCAAMABgkyFsw2AGEBAAAA.',
['绿皮']='绿皮丶萨:BAAALgAECgYJCQAAAA==.',
['绿蚁']='绿蚁:BAAALgAECgkJCQAAAA==.',
['缺徳']='缺徳就要團滅:BAAALgAECgYJDAAAAA==.',
['翱翔']='翱翔:BAABLgAFFH8FAAIGAAMJpwOeHADRAAAGAAMJpwOeHADRAAAAAA==.',
['老宫']='老宫:BAACLgAFFH8MAAITAAQJ/hLKCQBUAQATAAQJ/hLKCQBUAQAuAAQKfxUAAxMACAnXHrQSAIYCABMABwl/H7QSAIYCABQAAQnkGm4bAEsAAAAA.',
['自找']='自找伞渡:BAAALgAECgQJCAAAAA==.',
['艾力']='艾力摩尔:BAAALgAECgkJBgAAAA==.',
['艾贝']='艾贝里妮:BAAALgAECgMJAwAAAA==.',
['芝芝']='芝芝檬檬:BAAALgAECgEJAgAAAA==.',
['苏墨']='苏墨聆:BAAALgAECgYJBgAAAA==.',
['莫扎']='莫扎特丶德:BAAALgAECgEJAQAAAA==.',
['莱莎']='莱莎琳:BAAALgAECgEJAgAAAA==.',
['菠萝']='菠萝蜜:BAAALgAECgYJEAAAAA==.',
['萨不']='萨不住了:BAAALgAECggJCQAAAA==.',
['落叶']='落叶泛黄:BAAALgAFFAIJAgAAAA==.',
['蒙恬']='蒙恬:BAAALgAECgEJAQAAAA==.',
['蒼瀾']='蒼瀾:BAABLgAECn8WAAIDAAgJXhf6FAA1AgADAAgJXhf6FAA1AgAAAA==.',
['蝎子']='蝎子赖赖:BAAALgADCgUJBQAAAA==.',
['血刃']='血刃天下:BAAALgAECgMJBAABLgAFFAQJAgAQAAAAAA==.',
['血源']='血源病注射器:BAAALgAECgEJAQAAAA==.',
['血色']='血色那抹残阳:BAAALgAECgQJBAAAAA==.',
['諾夕']='諾夕:BAABLgAECn8WAAIGAAcJvRZ8cQDwAQAGAAcJvRZ8cQDwAQAAAA==.',
['请叫']='请叫我三鹿:BAAALgADCgMJAwAAAA==.',
['贝黑']='贝黑摩斯:BAAALgAECgYJBgAAAA==.',
['辉月']='辉月灬:BAACLgAFFH8LAAMNAAQJ3hu2EgAPAQANAAMJoBy2EgAPAQAVAAMJTweLEADSAAAuAAQKfyMAAw0ACAlCI7MnAIYCAA0ABwngIrMnAIYCABUACAldF54bADcCAAAA.',
['输出']='输出没悌高:BAAALgAECgMJAwAAAA==.',
['逆天']='逆天而行:BAAALgADCgEJAQAAAA==.',
['逗你']='逗你頑:BAACLgAFFH8FAAIKAAIJdRfmEwCuAAAKAAIJdRfmEwCuAAAuAAQKfxYAAgoABwmsHXYdACUCAAoABwmsHXYdACUCAAAA.',
['逸云']='逸云鸟:BAAALgAECgEJAgAAAA==.',
['道法']='道法当自然:BAAALgADCgEJAQAAAA==.',
['遥遥']='遥遥无期:BAAALgAECgYJBgAAAA==.',
['醉酒']='醉酒丶惜花颜:BAAALgAECgYJBgAAAA==.',
['长沙']='长沙第一鸟德:BAAALgAECgkJCQAAAA==.',
['阴月']='阴月琴:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔托莉雅:BAAALgAECgYJBwAAAA==.',
['随便']='随便的我:BAAALgAECgkJCQAAAA==.',
['雅木']='雅木天堂:BAAALgAFFAQJBAABLgAFFAUJCQACAAIQAA==.',
['雨夜']='雨夜撩澜:BAAALgAECgEJAQAAAA==.',
['颓废']='颓废的败家子:BAAALgAFFAQJBAABLgAFFAYJBgAWAGofAA==.',
['风隐']='风隐丶:BAAALgAECgcJBwAAAA==.',
['风骚']='风骚的大牛:BAAALgAECgUJCAAAAA==.',
['飞尐']='飞尐爺:BAABLgAFFH8FAAIMAAMJgglKLgDgAAAMAAMJgglKLgDgAAAAAA==.',
['飞巛']='飞巛飞:BAAALgAFFAIJBAAAAA==.',
['饭后']='饭后来走走:BAAALgADCgEJAQAAAA==.',
['马鹿']='马鹿:BAAALgAECgEJAQAAAA==.',
['魂帝']='魂帝:BAAALgADCgYJBgAAAA==.',
['黑灬']='黑灬乌龙茶:BAAALgAECgYJCAAAAA==.',
['黑熊']='黑熊熊:BAAALgADCgMJAQAAAA==.',
['齋藤']='齋藤明日香:BAACLgAFFH8FAAMXAAMJQwZQCgCaAAAXAAIJIQdQCgCaAAAWAAIJbALLMAByAAAuAAQKfyUAAxYACAlyF1Y/APcBABYACAnrFVY/APcBABcABwl7F/MhAK0BAAAA.',
['龙骧']='龙骧残雪:BAAALgAECgEJAQAAAA==.',
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
