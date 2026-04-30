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

local lookup = {'Warrior-Arms','Warrior-Fury','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Hunter-Marksmanship','Paladin-Holy','Paladin-Retribution','Unknown-Unknown','DemonHunter-Devourer','DeathKnight-Unholy','Druid-Balance','Druid-Restoration','Monk-Brewmaster','Shaman-Restoration','Shaman-Elemental','Mage-Frost','Evoker-Augmentation','Hunter-Survival','Rogue-Subtlety','Rogue-Assassination','Evoker-Preservation','Monk-Mistweaver','Monk-Windwalker','Warrior-Protection','Warlock-Affliction','Priest-Holy','Evoker-Devastation','Priest-Shadow','DemonHunter-Havoc','DeathKnight-Blood','DemonHunter-Vengeance',}
local provider = {region='CN',realm='红云台地',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aemeath:BAAALgAECgEJAQAAAA==.',
Al='Alss:BAAALgAECgYJCgAAAA==.',
Am='Amend:BAAALgADCgUJBQAAAA==.Amens:BAAALgAECgYJDQAAAA==.',
An='Andyou:BAAALgAECgMJAwAAAA==.',
Ar='Archdomon:BAAALgAECgEJAQAAAA==.Areyoumad:BAAALgAECgMJBAAAAA==.Armageddon:BAAALgAECgYJEgAAAA==.',
Bl='Blackrend:BAAALgADCgEJAQAAAA==.',
Ca='Caitlyn:BAAALgAECgYJCQAAAA==.Calioena:BAAALgAECgEJAQAAAA==.',
Da='Darklove:BAAALgAECggJEQAAAA==.',
De='Deadknights:BAAALgAECgEJAQAAAA==.',
Di='Dilios:BAABLgAECn8gAAMBAAkJQh99AAC3AgACAAkJBR0UBwA3AwABAAkJXBp9AAC3AgAAAA==.',
Do='Donk:BAAALgAECgcJEAAAAA==.',
Dr='Drugapple:BAAALgAECgYJEgAAAA==.',
Dt='Dtt:BAAALgAECgEJAQAAAA==.',
En='Entarotasada:BAAALgAECgkJCQAAAA==.',
Ev='Evangel:BAAALgAECgMJBQAAAA==.',
Fo='Forthehor:BAAALgAECgcJAQAAAA==.',
Fu='Fugitive:BAAALgAECgUJBQAAAA==.',
Ga='Gawaine:BAAALgAECgkJEAAAAA==.',
Gi='Gira:BAAALgADCgQJCAAAAA==.',
Gr='Groudon:BAAALgAECgEJAgAAAA==.',
Ha='Hastin:BAAALgAECgIJAgAAAA==.Hawker:BAABLgAECn8aAAIDAAgJGhZcJwAcAgADAAgJGhZcJwAcAgAAAA==.',
He='Heric:BAAALgAECgEJAQABLgAFFAYJFQAEAEcjAA==.',
Hg='Hginferior:BAAALgAECgUJCAAAAA==.',
Hu='Hunterspark:BAAALgAECgQJBQAAAA==.',
If='Iforsaken:BAAALgAECgQJBQAAAA==.',
Ji='Jinm:BAAALgAECgYJAgAAAA==.',
Js='Jsy:BAAALgADCgYJBgAAAA==.',
Kk='Kkid:BAACLgAFFH8VAAMEAAYJRyNKAAAGAgAEAAYJRyNKAAAGAgAFAAIJFRqICgC1AAAuAAQKfxgAAwQACAnkIu4GAFEDAAQACAnkIu4GAFEDAAUABAlsGHUtAAcBAAAA.',
Kl='Klind:BAAALgAECgEJAQAAAA==.',
Kr='Krito:BAAALgADCggJCAAAAA==.',
Ky='Kyogre:BAAALgAECgIJAQAAAA==.',
Li='Liquefy:BAAALgADCgEJAQAAAA==.Liverpool:BAAALgAECgcJDQAAAA==.',
Lm='Lmmdh:BAAALgAECgEJAQAAAA==.',
Lo='Lonelysoul:BAAALgAECgEJAQAAAA==.',
Lu='Lumier:BAAALgAFFAIJAgAAAA==.Lumoss:BAAALgAECgEJAQAAAA==.Lunzai:BAAALgAECgYJCgAAAA==.',
Ly='Lypj:BAAALgAECgQJBAAAAA==.',
Me='Mehone:BAAALgAECgYJCgAAAA==.',
Mi='Mieya:BAABLgAECn8VAAMGAAgJOB3ZFACJAgAGAAgJOB3ZFACJAgADAAEJgx4ftQBZAAAAAA==.Misting:BAAALgAECgYJEQAAAA==.Mizuki:BAAALgAECgMJBAAAAA==.',
Na='Naivemo:BAABLgAFFH8FAAMHAAMJDAX7EADMAAAHAAMJDAX7EADMAAAIAAIJfwQYKgCMAAAAAA==.',
Ne='Neptune:BAAALgAECgEJAQABLgAECgYJDQAJAAAAAA==.',
Ni='Niudeblood:BAAALgADCgEJAQAAAA==.Niudehunter:BAAALgADCgEJAQAAAA==.',
No='Nolans:BAAALgAECgYJBgAAAA==.Norvi:BAAALgAECgEJAQAAAA==.',
Ob='Oblivionis:BAAALgAECgYJBgAAAA==.',
Ol='Oldmonster:BAAALgADCgEJAQAAAA==.',
Or='Orangelee:BAABLgAFFH8HAAIKAAMJmxb4GAAHAQAKAAMJmxb4GAAHAQAAAA==.Orgjuice:BAAALgAECgEJAgAAAA==.',
Pa='Paradisekis:BAACLgAFFH8HAAILAAMJDRfFIwAHAQALAAMJDRfFIwAHAQAuAAQKfx0AAgsACAmTHQYpAJYCAAsACAmTHQYpAJYCAAAA.',
Ph='Phoenixred:BAAALgADCgUJBQAAAA==.',
Pl='Playerqfjwvu:BAAALgAECgYJBgAAAA==.',
Ra='Rancid:BAAALgAECgEJAQAAAA==.Raquel:BAAALgAFFAEJAQAAAA==.',
Re='Redspark:BAACLgAFFH8NAAMMAAQJXw8HCwA7AQAMAAQJXw8HCwA7AQANAAEJlhiRIgBSAAAuAAQKfywAAwwACAk8I9YGACoDAAwACAk8I9YGACoDAA0AAQnKG7G6AFAAAAAA.Remil:BAAALgADCgMJAwAAAA==.',
Ro='Roderick:BAAALgAECgYJDQAAAA==.Rolex:BAAALgAECgIJAgAAAA==.',
Se='Seeuming:BAAALgAECgYJEgABLgAFFAQJBQAGAJUNAA==.Seigakus:BAAALgADCgIJAgAAAA==.',
Sk='Skade:BAAALgAECgYJBwAAAA==.',
St='Stellagosa:BAAALgAECgIJAgAAAA==.',
Th='Thalira:BAAALgAECgUJBQAAAA==.',
Tr='Tribe:BAAALgAECgIJBAAAAA==.',
Tz='Tzr:BAAALgAECgcJAwAAAA==.',
Wi='Wick:BAAALgAFFAIJBAAAAA==.Wildsummon:BAAALgAECgYJCAAAAA==.',
Ya='Yatoro:BAABLgAFFH8IAAILAAMJlApXFwDeAAALAAMJlApXFwDeAAAAAA==.',
Yu='Yup:BAAALgAECgYJBgAAAA==.',
Zg='Zgle:BAAALgAECgEJAQAAAA==.',
Zz='Zzj:BAAALgAECgYJBgAAAA==.',
['一七']='一七:BAAALgAFFAIJAgABLgAFFAQJBQAGAJUNAA==.',
['一不']='一不良人一:BAAALgAECgEJAQAAAA==.',
['一个']='一个三:BAABLgAFFH8FAAIOAAIJyxDOHACKAAAOAAIJyxDOHACKAAAAAA==.',
['一丿']='一丿袖青蛇:BAAALgAECgcJCgAAAA==.',
['一冰']='一冰魄一:BAABLgAFFH8FAAIPAAIJPyKsEgDNAAAPAAIJPyKsEgDNAAAAAA==.',
['一把']='一把骨:BAAALgADCgYJBgAAAA==.',
['一诺']='一诺倾清:BAABLgAFFH8KAAILAAQJlhi3CABIAQALAAQJlhi3CABIAQAAAA==.',
['丁日']='丁日辰:BAEALgAFFAIJAgAAAA==.',
['丁香']='丁香与茉莉:BAAALgAECgYJBgAAAA==.',
['七七']='七七:BAABLgAECn8WAAILAAYJ/R/sHABMAQALAAYJ/R/sHABMAQAAAA==.',
['七酱']='七酱:BAAALgAECgUJBQAAAA==.',
['万发']='万发自然:BAAALgAECgkJEQAAAA==.',
['不焦']='不焦之人:BAABLgAFFH8JAAIQAAUJsxL3BAAxAQAQAAUJsxL3BAAxAQAAAA==.',
['不给']='不给鱼就闹:BAAALgAECggJCAAAAA==.',
['不述']='不述离愁:BAAALgAFFAEJAQAAAA==.',
['与时']='与时舒卷丶:BAAALgAFFAIJBAAAAA==.',
['丑皇']='丑皇丶:BAAALgAECgIJAgAAAA==.',
['世界']='世界飒:BAAALgAECgEJAgAAAA==.',
['丶唇']='丶唇色:BAAALgAECgUJCQAAAA==.',
['丶子']='丶子墨:BAACLgAFFH8HAAIRAAMJlRiPEgAdAQARAAMJlRiPEgAdAQAuAAQKfxgAAhEABgleIxwOAPoBABEABgleIxwOAPoBAAAA.',
['丶心']='丶心碎乌托邦:BAAALgAECgIJBQAAAA==.',
['丶空']='丶空城:BAAALgAECgcJDQABLgAFFAUJBAAJAAAAAA==.',
['丶纠']='丶纠结君:BAAALgAECgQJBAAAAA==.',
['丶记']='丶记念:BAAALgAECgMJBQAAAA==.',
['丷念']='丷念老师:BAAALgAFFAQJBAAAAA==.',
['为了']='为了洛丹伦:BAAALgAECgYJDAAAAA==.',
['丽丶']='丽丶风暴烈酒:BAAALgAECgIJAgAAAA==.',
['乃万']='乃万:BAAALgAECgEJAQAAAA==.',
['乄殇']='乄殇逝之刃:BAABLgAFFH8FAAILAAIJkRzlHwCiAAALAAIJkRzlHwCiAAAAAA==.',
['乌丝']='乌丝丹:BAAALgAECgcJAgAAAA==.',
['九念']='九念离殇:BAAALgAECgcJBQAAAA==.',
['九日']='九日三寿:BAAALgADCgEJAQAAAA==.',
['亂了']='亂了感覚:BAAALgAECgkJAQAAAA==.',
['予你']='予你挚终丶:BAAALgAECgYJCwAAAA==.',
['二七']='二七二七:BAAALgAECgYJBgAAAA==.',
['二牛']='二牛他老嗲:BAAALgADCgMJAwAAAA==.',
['五半']='五半樱花:BAAALgAECgcJCQAAAA==.',
['五帝']='五帝龙:BAAALgAFFAYJBAABLgAFFAYJBQASAIAVAA==.',
['井川']='井川里予:BAAALgAECgMJBAAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgcJBwABLgAFFAcJBQANAMsVAA==.',
['今天']='今天一般般:BAACLgAFFH8IAAIRAAIJrB1GNQDBAAARAAIJrB1GNQDBAAAuAAQKfxYAAhEABgkhHzuTAK0BABEABgkhHzuTAK0BAAAA.',
['伊利']='伊利雷怒风:BAAALgADCgEJAQAAAA==.',
['伟丶']='伟丶伟:BAAALgAECgIJAgAAAA==.',
['伦仔']='伦仔:BAAALgAECgcJBwAAAA==.',
['低语']='低语丨小龙人:BAAALgAECgMJAwAAAA==.低语行者:BAAALgAFFAIJBAAAAA==.',
['佐丹']='佐丹伮:BAAALgAECgEJAQAAAA==.',
['你大']='你大墩子啊:BAAALgAECgkJCQAAAA==.',
['你总']='你总算:BAAALgAFFAIJBAAAAA==.',
['你终']='你终于:BAAALgAFFAIJBAAAAA==.',
['你被']='你被强化了丶:BAAALgAECgEJAQAAAA==.',
['你闻']='你闻起来真棒:BAAALgAFFAQJBAAAAA==.',
['佩恩']='佩恩酱:BAAALgAFFAIJAwAAAA==.',
['俊宇']='俊宇尚清丶云:BAAALgADCgEJAQAAAA==.',
['倒了']='倒了阵形:BAAALgAECgcJBwAAAA==.',
['倚楼']='倚楼赏明月:BAABLgAFFH8GAAMTAAUJlxfMAQArAQATAAMJ6B7MAQArAQAGAAIJpwFNIQCMAAAAAA==.',
['倾辉']='倾辉乄十六月:BAAALgAECgkJEQAAAA==.',
['偶尔']='偶尔玩玩德:BAAALgAECgYJCgAAAA==.',
['偷月']='偷月光:BAABLgAFFH8GAAIQAAMJeRr5DQAMAQAQAAMJeRr5DQAMAQAAAA==.',
['傻猪']='傻猪来噶:BAAALgAECgIJAgAAAA==.',
['僧球']='僧球丶:BAAALgAECgQJCAAAAA==.',
['元素']='元素呱冻:BAAALgAECgcJDAAAAA==.',
['兄弟']='兄弟来砍我:BAAALgAECgYJBgAAAA==.',
['先死']='先死的是给给:BAAALgADCgUJBQAAAA==.',
['先锋']='先锋官:BAAALgAECgYJBgAAAA==.',
['光辉']='光辉小杰:BAAALgADCgkJDAAAAA==.',
['兜兜']='兜兜转转:BAAALgAECgMJAwAAAA==.',
['八一']='八一零:BAABLgAECn8UAAIIAAgJ5g84WgDUAQAIAAgJ5g84WgDUAQAAAA==.',
['兰色']='兰色鸢尾:BAAALgAECgIJAgAAAA==.',
['关你']='关你嘛事:BAAALgAECgcJBgAAAA==.',
['兽兽']='兽兽之盾:BAAALgAECgUJBwAAAA==.兽兽的小可爱:BAAALgAECgYJCAAAAA==.兽兽的小龙人:BAAALgAECgUJBQAAAA==.',
['冉婷']='冉婷婷是仙女:BAAALgAECgQJBQAAAA==.',
['再也']='再也不见:BAAALgAECgQJBAAAAA==.',
['再逼']='再逼逼就锤你:BAAALgAECgEJAQAAAA==.',
['军团']='军团壳儿:BAAALgAFFAEJAQAAAA==.',
['冬夏']='冬夏:BAAALgADCgkJDwAAAA==.',
['冯大']='冯大媛:BAAALgAECgEJAQAAAA==.',
['冰与']='冰与果汁哥:BAAALgAECgQJBAAAAA==.',
['冰可']='冰可乐:BAAALgADCgMJAwAAAA==.',
['冰月']='冰月黯然:BAABLgAECn8bAAMPAAgJCxwOEgCGAgAPAAgJCxwOEgCGAgAQAAUJPBbSTgALAQAAAA==.',
['冰镐']='冰镐雷人:BAAALgADCgMJAwAAAA==.',
['冰风']='冰风:BAAALgADCgcJCAAAAA==.',
['凝结']='凝结的氺滴:BAAALgAECgMJAwAAAA==.',
['凯恩']='凯恩血飞蹄:BAAALgAECgYJAgAAAA==.',
['出墙']='出墙的菊花:BAAALgAECgYJBgAAAA==.',
['出家']='出家人:BAAALgADCgUJBQAAAA==.',
['刀马']='刀马丶:BAABLgAFFH8FAAMUAAMJqRxyEADIAAAUAAIJwCFyEADIAAAVAAEJehKxBQBhAAAAAA==.',
['分离']='分离教义:BAAALgAECgEJAQAAAA==.',
['划过']='划过星空的星:BAAALgAECgYJCQAAAA==.划过星空的血:BAAALgAECgYJCAAAAA==.',
['刘大']='刘大锤:BAAALgAECgYJEAAAAA==.',
['初弦']='初弦值早秋:BAAALgAFFAIJAgAAAA==.',
['别动']='别动那个菜菜:BAABLgAECn8XAAIPAAcJjgzCQwByAQAPAAcJjgzCQwByAQAAAA==.',
['剑指']='剑指悠扬:BAABLgAECn8WAAMNAAYJ1RN9FgA9AQANAAYJ1RN9FgA9AQAMAAIJVw6EKAA4AAAAAA==.',
['加拉']='加拉哈德:BAACLgAFFH8GAAILAAIJuhKZIwCYAAALAAIJuhKZIwCYAAAuAAQKfxsAAgsABwlhHUVFACUCAAsABwlhHUVFACUCAAAA.',
['勒蛋']='勒蛋小小裤:BAAALgADCgcJDQAAAA==.',
['勾魂']='勾魂大宝贝:BAAALgAFFAIJBAAAAA==.',
['勿急']='勿急:BAAALgAECgcJCQAAAA==.',
['医生']='医生姐姐来咯:BAAALgAECgIJAwAAAA==.',
['十卄']='十卄卅卌:BAAALgADCgEJAQAAAA==.',
['千夏']='千夏凉风:BAAALgADCgMJAwABLgAFFAIJBQADAOQdAA==.',
['千里']='千里飘香:BAAALgAECgEJAQAAAA==.',
['半岛']='半岛铁锤:BAAALgAECgYJCAABLgAECgYJDAAJAAAAAA==.',
['华佗']='华佗阿龙:BAAALgADCgMJAwAAAA==.',
['南柯']='南柯七梦:BAAALgAECgcJDAAAAA==.',
['卡罗']='卡罗娜二世:BAAALgAECgIJAgAAAA==.',
['卡莎']='卡莎:BAAALgAECgYJBgAAAA==.',
['卧听']='卧听风雨声:BAAALgADCgUJBQAAAA==.',
['厄似']='厄似个老北京:BAAALgAECgMJAwAAAA==.',
['去也']='去也冲冲:BAAALgADCgEJAQAAAA==.',
['双逆']='双逆足球员:BAAALgAECgIJAgAAAA==.',
['叮噹']='叮噹貓:BAAALgAECgUJBQAAAA==.',
['可乐']='可乐人生:BAAALgAECgUJCAAAAA==.',
['吃个']='吃个佛跳强:BAAALgAFFAEJAgAAAA==.',
['吃洋']='吃洋葱的小牛:BAAALgAECgYJDAAAAA==.',
['含蓄']='含蓄的射手:BAAALgAECgYJBgAAAA==.',
['吻你']='吻你我错了:BAAALgADCgEJAQAAAA==.',
['呂师']='呂师傅:BAAALgAECgYJCgAAAA==.',
['呆呆']='呆呆鸟:BAACLgAFFH8QAAIWAAQJKiLZAgCGAQAWAAQJKiLZAgCGAQAuAAQKfxoAAhYACAk5IZ4FAO8CABYACAk5IZ4FAO8CAAAA.',
['呜啦']='呜啦哇咔咔丶:BAAALgADCgEJAQAAAA==.',
['呱冻']='呱冻:BAABLgAFFH8FAAIIAAIJAw34JgCcAAAIAAIJAw34JgCcAAAAAA==.',
['咁佑']='咁佑未必:BAAALgAFFAQJBAAAAA==.',
['咔咔']='咔咔萌萌哒丶:BAABLgAECn8UAAMXAAcJYRJ8KQBrAQAXAAYJOBR8KQBrAQAYAAMJzQEtegA2AAAAAA==.',
['咔皮']='咔皮巴啦:BAAALgAECgEJAgAAAA==.',
['咕德']='咕德猫柠:BAAALgAECgcJDAAAAA==.',
['咚达']='咚达隆咚嗆:BAABLgAECn8gAAMCAAcJGA+3DgBdAQACAAcJxg63DgBdAQABAAUJRweFIwDRAAAAAA==.',
['咪啪']='咪啪:BAAALgAECgEJAQAAAA==.',
['哀木']='哀木踢已死:BAAALgAECgQJBAABLgAFFAcJDQAZAM4ZAA==.',
['哇牧']='哇牧:BAAALgAECgQJBAAAAA==.',
['哈基']='哈基米德:BAAALgAECgYJDAAAAA==.',
['問戦']='問戦:BAAALgAFFAQJAgAAAA==.',
['喜爱']='喜爱豆腐乳:BAAALgADCgQJBAAAAA==.',
['喧哗']='喧哗:BAAALgAECgkJBAAAAA==.',
['喵喵']='喵喵兽:BAABLgAFFH8IAAIRAAMJJR+9EQAkAQARAAMJJR+9EQAkAQAAAA==.',
['嗜血']='嗜血钢筋棍:BAABLgAFFH8CAAIEAAIJ4RcFKwBdAAAEAAIJ4RcFKwBdAAAAAA==.',
['嗨班']='嗨班子:BAAALgAECggJDwAAAA==.',
['嘿嘿']='嘿嘿小黑兔:BAAALgADCgUJBQAAAA==.',
['因幡']='因幡帝丶:BAABLgAFFH8IAAMGAAMJ0gcyIQCMAAAGAAIJRAYyIQCMAAADAAEJ7wq5IwBZAAAAAA==.',
['因瓦']='因瓦尔:BAAALgAECgMJAwAAAA==.',
['土土']='土土精:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光啊:BAAALgADCgcJBwAAAA==.圣光照我前行:BAAALgAECgIJAgAAAA==.',
['圣欣']='圣欣依苒:BAAALgAFFAEJAgAAAA==.',
['垂耳']='垂耳兔之熊:BAAALgAECgYJDAAAAA==.',
['墨染']='墨染幽:BAAALgADCgcJBwAAAA==.',
['墨琉']='墨琉璃一毐:BAAALgAFFAQJAwAAAA==.',
['墨雨']='墨雨烟云:BAAALgAECgQJBAAAAA==.',
['复活']='复活的亡者:BAAALgAECgYJBgAAAA==.',
['夏末']='夏末灬生花:BAAALgAECgYJAQABLgAECgkJAQAJAAAAAA==.',
['夏琉']='夏琉:BAAALgAECgUJBQAAAA==.',
['夏蝉']='夏蝉:BAAALgAECgEJAQAAAA==.',
['大栗']='大栗栗丨:BAAALgAECgYJBgAAAA==.',
['大爷']='大爷您喝好:BAAALgAECgEJAQAAAA==.',
['大猪']='大猪蹄一个鑫:BAABLgAFFH8GAAILAAMJkA1jKwDtAAALAAMJkA1jKwDtAAAAAA==.',
['大聪']='大聪师滚滚丶:BAAALgADCgYJBgAAAA==.',
['大蓝']='大蓝龙:BAAALgAFFAQJBAAAAA==.',
['大蝉']='大蝉时雨:BAAALgADCgUJBQAAAA==.',
['大风']='大风七彩:BAACLgAFFH8KAAISAAMJ4xYGCgD/AAASAAMJ4xYGCgD/AAAuAAQKfyAAAxIACQmVGy8HAAgDABIACQmVGy8HAAgDABYAAQnZDZdIADIAAAAA.',
['天刚']='天刚刚破晓:BAAALgAECgEJAQAAAA==.',
['天动']='天动万象:BAAALgAFFAEJAQAAAA==.',
['天国']='天国的湖光:BAAALgAECgUJCAAAAA==.',
['天慧']='天慧龙:BAAALgAFFAQJAQABLgAFFAYJBQASAIAVAA==.',
['天菩']='天菩萨喂:BAAALgAFFAEJAQAAAA==.',
['天边']='天边树若荠:BAAALgAECgYJBwAAAA==.',
['天道']='天道总司:BAAALgAECgcJDgAAAA==.',
['太阳']='太阳蝴蝶小花:BAAALgAECgEJAQAAAA==.',
['头很']='头很硬很铁:BAAALgAECgQJAwAAAA==.',
['夹心']='夹心酱本酱丶:BAABLgAFFH8FAAIIAAIJthJKIQCqAAAIAAIJthJKIQCqAAAAAA==.',
['奈斯']='奈斯丶:BAAALgAECgQJBAAAAA==.',
['奕昕']='奕昕德:BAAALgADCgUJBQAAAA==.',
['奥尼']='奥尼嘟噜噜:BAABLgAFFH8FAAIXAAIJQwNiEwB7AAAXAAIJQwNiEwB7AAAAAA==.',
['奥斯']='奥斯卡电费:BAAALgAECgEJAQAAAA==.',
['奶棒']='奶棒丶:BAAALgAECgYJBgAAAA==.',
['奶爹']='奶爹顶得住:BAAALgADCgYJBgAAAA==.',
['奶骑']='奶骑骑:BAAALgAECgMJAgAAAA==.',
['好市']='好市民田伯光:BAAALgAECgEJAQAAAA==.',
['好长']='好长的毛:BAABLgAECn8VAAIDAAgJkhp5GQBvAgADAAgJkhp5GQBvAgAAAA==.',
['妖怪']='妖怪爹爹:BAAALgAECgYJBwAAAA==.',
['妖雨']='妖雨舞舞:BAAALgAECgEJAQAAAA==.',
['妥妥']='妥妥的小跟班:BAAALgAECgEJAQAAAA==.',
['威霸']='威霸:BAAALgAECgEJAwAAAA==.',
['娜夜']='娜夜的销魂:BAABLgAECn8UAAMEAAYJARaXJAAvAQAEAAYJARaXJAAvAQAaAAIJKwuQJgBXAAAAAA==.',
['娜爷']='娜爷的潇魂:BAAALgADCgIJAgAAAA==.',
['嫣红']='嫣红一笑:BAAALgAECgQJBwABLgAFFAIJAgAJAAAAAA==.',
['子路']='子路的路人:BAAALgAECgcJBwAAAA==.',
['孟德']='孟德:BAAALgAECgMJBAAAAA==.',
['孤风']='孤风:BAAALgAECgEJAQAAAA==.',
['孤鸾']='孤鸾:BAAALgAECgEJAwAAAA==.',
['安里']='安里的直剑:BAAALgAECgkJBwAAAA==.',
['宋丶']='宋丶修:BAAALgAECgMJAwAAAA==.',
['宝钟']='宝钟玛琳:BAAALgAECggJDgAAAA==.',
['富贵']='富贵:BAAALgAECgYJCgAAAA==.',
['对吾']='对吾嗨住:BAAALgAFFAQJBAAAAA==.',
['封绯']='封绯玄华:BAAALgAECgMJAwAAAA==.',
['射鸡']='射鸡猎:BAAALgAFFAQJBAABLgAFFAUJBQARAGkYAA==.',
['尊尼']='尊尼又获加:BAAALgAECgUJCgAAAA==.',
['小乌']='小乌龟啊:BAAALgADCgcJBwAAAA==.',
['小依']='小依露:BAAALgAECgMJAwAAAA==.',
['小夜']='小夜时雨:BAAALgAECgEJAQAAAA==.',
['小学']='小学僧丶:BAAALgAFFAIJAwABLgAFFAIJBAAJAAAAAA==.',
['小小']='小小的丸子:BAAALgADCgEJAQAAAA==.',
['小希']='小希巴:BAAALgAECgcJBwAAAA==.',
['小明']='小明骑大黑马:BAAALgAECgkJAgAAAA==.',
['小杨']='小杨乱跑:BAAALgAECgYJBgAAAA==.小杨跑不动啦:BAAALgAECgcJBgABLgAFFAUJBQARAGkYAA==.',
['小林']='小林托尔:BAAALgADCgEJAQABLgAECgcJDAAJAAAAAA==.',
['小猎']='小猎豹一个鑫:BAAALgAFFAMJAwAAAA==.',
['小皓']='小皓轩:BAAALgAECgYJCgABLgAFFAIJAgAJAAAAAA==.',
['小皮']='小皮:BAAALgADCgEJAQAAAA==.',
['小红']='小红帽的理想:BAAALgAECgIJBAAAAA==.小红牛二:BAACLgAFFH8IAAIIAAMJVRIuDAADAQAIAAMJVRIuDAADAQAuAAQKfxwAAggACQk4GAsxAF8CAAgACQk4GAsxAF8CAAAA.',
['小萌']='小萌萌呀:BAAALgAFFAIJAwAAAA==.',
['尐丷']='尐丷念:BAAALgAECgIJAgAAAA==.',
['少林']='少林胖次大师:BAAALgAECgYJBgAAAA==.',
['就是']='就是不喝血:BAAALgAECgcJDAAAAA==.',
['尼古']='尼古丁真:BAAALgAECgIJAgAAAA==.',
['展达']='展达:BAAALgADCgMJAwAAAA==.',
['山有']='山有扶苏:BAAALgAECgcJCAAAAA==.',
['山猪']='山猪吃细糠:BAAALgAECgYJEQAAAA==.',
['崎玉']='崎玉怒风:BAAALgADCgEJAQAAAA==.',
['左手']='左手捶你:BAAALgAFFAEJAQAAAA==.',
['左拳']='左拳右勾:BAAALgAECgEJAQAAAA==.',
['师法']='师法雪风:BAAALgAECgIJAgAAAA==.',
['希格']='希格露恩:BAAALgADCgIJAgAAAA==.',
['帕修']='帕修斯一骑士:BAAALgAECgIJBQAAAA==.',
['帝波']='帝波:BAAALgAFFAIJBAABLgAFFAYJAwAJAAAAAA==.',
['席默']='席默牛:BAAALgADCgQJBAAAAA==.',
['常陆']='常陆茉子:BAAALgAECgkJBQAAAA==.',
['幻羽']='幻羽丶:BAAALgAECgUJBQAAAA==.',
['康斯']='康斯坦丁丶:BAABLgAFFH8KAAIKAAMJ9BQdEQDuAAAKAAMJ9BQdEQDuAAAAAA==.',
['弓尘']='弓尘流山:BAAALgAFFAIJAgAAAA==.',
['弗乌']='弗乌尔:BAAALgAFFAEJAQAAAA==.',
['弗兹']='弗兹丶断角:BAAALgAECgYJCAAAAA==.',
['张三']='张三的李四:BAABLgAFFH8BAAIEAAEJqAGfUwA4AAAEAAEJqAGfUwA4AAAAAA==.',
['张歆']='张歆艺:BAAALgAECgUJBQAAAA==.',
['张粑']='张粑拉斯:BAAALgAECgMJBQAAAA==.',
['彩苹']='彩苹救我:BAAALgAECgYJBgABLgAFFAIJBAAJAAAAAA==.',
['彼静']='彼静阅兮:BAAALgAFFAIJAgAAAA==.',
['徳意']='徳意奥:BAAALgAFFAMJAwAAAA==.',
['德一']='德一奥:BAAALgAECgMJAwAAAA==.',
['心痕']='心痕之殇:BAABLgAECn8hAAIIAAkJ7R5RCgA+AwAIAAkJ7R5RCgA+AwAAAA==.',
['怀旧']='怀旧丨:BAAALgAECgEJAQAAAA==.怀旧狠悲伤:BAAALgAECgYJCgAAAA==.',
['怪东']='怪东西:BAAALgADCgUJBQAAAA==.',
['恰似']='恰似一抹柔情:BAAALgAFFAIJBAAAAA==.',
['恶魔']='恶魔信仰:BAAALgAECgEJAQAAAA==.',
['悔恨']='悔恨边缘:BAAALgAECgYJBgAAAA==.',
['想吃']='想吃酸菜:BAAALgAECgcJCQAAAA==.',
['懒得']='懒得偷懒得:BAACLgAFFH8RAAIPAAUJJiTjAAANAgAPAAUJJiTjAAANAgAuAAQKfyEAAw8ACAnoJNsCAFEDAA8ACAnoJNsCAFEDABAAAQmOBQqOACoAAAAA.',
['戈瑞']='戈瑞斯华尓德:BAAALgAECgQJCQAAAA==.',
['我不']='我不是堂客:BAAALgAECgMJAwAAAA==.我不是蜜汁鸡:BAAALgAECgMJAwAAAA==.',
['我叫']='我叫森哥:BAAALgAECgcJDgAAAA==.',
['我心']='我心飞翔:BAAALgAECgEJAQAAAA==.',
['我是']='我是傻灵:BAAALgAECgYJCwAAAA==.我是豆子:BAACLgAFFH8FAAIHAAMJGSHlCgAvAQAHAAMJGSHlCgAvAQAuAAQKfxoAAwcACAkXJqECAE8DAAcACAkXJqECAE8DAAgAAwnvHNTNAO4AAAEuAAUUBQkQABsADiEA.',
['我牛']='我牛大了:BAAALgAECgEJAQAAAA==.',
['我的']='我的蓝色天空:BAACLgAFFH8NAAIRAAQJ3BGyGgBgAQARAAQJ3BGyGgBgAQAuAAQKfxkAAhEABwmPHBZaACsCABEABwmPHBZaACsCAAAA.',
['我闻']='我闻起来很棒:BAAALgAECgYJBgAAAA==.',
['戰灬']='戰灬傷:BAAALgAECgcJBwAAAA==.',
['扄駴']='扄駴焢秅卝:BAAALgADCgYJBgAAAA==.',
['打锤']='打锤子哦:BAAALgAECgIJAgAAAA==.',
['拂晓']='拂晓者莉娅:BAAALgAFFAEJAQAAAA==.',
['拉夫']='拉夫劳伦:BAAALgAECgEJAwAAAA==.',
['拉席']='拉席奥:BAABLgAFFH8FAAMSAAQJ8hzaCABgAQASAAQJ8hzaCABgAQAcAAEJNRxZCQBWAAABLgAFFAYJBQASAIAVAA==.',
['拔丝']='拔丝朝天椒:BAAALgADCgcJBwAAAA==.',
['指间']='指间沙:BAAALgAECgIJAgAAAA==.指间温柔:BAAALgADCgQJBAAAAA==.',
['掉线']='掉线大庸医:BAABLgAFFH8JAAIXAAQJ9x+2BQB4AQAXAAQJ9x+2BQB4AQAAAA==.',
['提丰']='提丰:BAABLgAFFH8FAAMDAAIJ5B2HEADEAAADAAIJix2HEADEAAAGAAIJzhSkHACjAAAAAA==.',
['摧毁']='摧毁联盟:BAAALgAECgEJAgAAAA==.',
['撒丫']='撒丫子就闪:BAAALgAECgQJAQABLgAECgkJAQAJAAAAAA==.撒丫子瞎跑:BAAALgAECgkJAQAAAA==.',
['撒蛮']='撒蛮:BAAALgAECgIJAgAAAA==.',
['撕点']='撕点纸给我:BAABLgAFFH8HAAMCAAMJeg4yCAD8AAACAAMJeg4yCAD8AAABAAEJZAwKDABSAAAAAA==.',
['救世']='救世星龙:BAABLgAFFH8FAAISAAQJgBWHDwAJAQASAAQJgBWHDwAJAQAAAA==.',
['敖武']='敖武:BAAALgADCgEJAQAAAA==.',
['断念']='断念骑士:BAAALgAECgcJCwAAAA==.',
['无事']='无事过一日:BAAALgAFFAIJAgAAAA==.',
['无厌']='无厌:BAAALgAECgUJBwABLgAFFAIJAgAJAAAAAA==.',
['无声']='无声铃鹿:BAAALgADCgMJAwAAAA==.',
['无敌']='无敌软绵绵丶:BAAALgAFFAIJAgAAAA==.',
['无界']='无界空宇:BAAALgAECgEJAQAAAA==.',
['日落']='日落:BAAALgAFFAEJAQAAAA==.',
['时光']='时光浅浅:BAAALgAECgMJBQAAAA==.',
['时雨']='时雨:BAAALgADCgEJAQAAAA==.',
['旺仔']='旺仔水饺:BAAALgAFFAEJAQAAAA==.',
['明天']='明天早上带完:BAAALgAECgYJBwAAAA==.',
['星尘']='星尘龙:BAAALgAFFAQJBAABLgAFFAYJBQASAIAVAA==.',
['星河']='星河入梦:BAAALgADCgEJAQAAAA==.',
['星落']='星落周慧敏:BAAALgADCgMJBQAAAA==.星落宗师:BAAALgAECgEJAgAAAA==.',
['是我']='是我惹不起:BAAALgAFFAIJBAAAAA==.',
['晓晓']='晓晓丸子:BAAALgAECgYJBgAAAA==.',
['晓耗']='晓耗子:BAACLgAFFH8HAAMDAAMJwRqSEADDAAADAAMJwRqSEADDAAAGAAIJXwdvIACSAAAuAAQKfxgAAwYACAmwHRYoAOYBAAYABgmgHRYoAOYBAAMAAwnyGVh1AAcBAAAA.',
['暗夜']='暗夜泉:BAAALgAECgYJBgAAAA==.暗夜风暴:BAAALgADCgMJAwAAAA==.',
['暴怒']='暴怒族长:BAAALgADCgUJBQAAAA==.',
['暴雪']='暴雪的爸爸:BAAALgADCggJCAAAAA==.',
['暴风']='暴风女神:BAAALgADCgIJAgAAAA==.',
['曲非']='曲非烟:BAAALgAECgIJAgAAAA==.',
['曼妮']='曼妮妮丶:BAAALgADCgUJBQAAAA==.',
['曾经']='曾经的恶魔:BAAALgAFFAIJAgAAAA==.曾经的隐:BAAALgAECgUJBgAAAA==.',
['最后']='最后一箭:BAAALgADCgMJAwAAAA==.最后的开始:BAAALgAECgEJAQAAAA==.',
['最干']='最干净的脚:BAAALgAECgEJAQAAAA==.',
['月照']='月照影参差:BAAALgAECgEJAwAAAA==.',
['有美']='有美清扬:BAAALgAFFAQJBAAAAA==.',
['木风']='木风飞:BAABLgAFFH8FAAIIAAMJjBBBFgD5AAAIAAMJjBBBFgD5AAABLgAFFAcJBgAIANsXAA==.',
['未注']='未注册:BAAALgAECgEJAQAAAA==.',
['朴灵']='朴灵儿:BAAALgAECgQJCQAAAA==.',
['朵黎']='朵黎:BAAALgAECgIJAgABLgAFFAIJAgAJAAAAAA==.',
['李富']='李富清:BAAALgADCgMJAwAAAA==.',
['李意']='李意花:BAACLgAFFH8FAAIGAAQJlQ2hDwA1AQAGAAQJlQ2hDwA1AQAuAAQKfxsAAgYABwmkICkVAIYCAAYABwmkICkVAIYCAAAA.',
['李淳']='李淳风:BAAALgAECgIJBAAAAA==.',
['村口']='村口小贩:BAAALgAECgcJEwAAAA==.村口淘尼:BAAALgAECgcJDQAAAA==.村口理发师:BAAALgAECggJEAAAAA==.',
['来也']='来也匆匆:BAAALgAECgYJBgAAAA==.',
['枕清']='枕清风丶:BAAALgAECgEJAQAAAA==.',
['枫叶']='枫叶锁秋城:BAAALgAECgYJCAAAAA==.枫叶飘梅:BAAALgAECgEJAQAAAA==.',
['枯法']='枯法者果酱:BAAALgAECgcJDQAAAA==.',
['根本']='根本吃不饱:BAAALgAECgYJDAAAAA==.',
['桃桃']='桃桃姐:BAAALgAECgkJCQAAAA==.',
['桥隧']='桥隧建模员:BAAALgADCgEJAQAAAA==.',
['梅林']='梅林娜丶:BAAALgAECgcJCgAAAA==.',
['梦听']='梦听雪:BAAALgADCgYJCgAAAA==.',
['梦魇']='梦魇小布:BAAALgAECgYJBwAAAA==.',
['棍哥']='棍哥:BAAALgAFFAEJAgAAAA==.',
['椎名']='椎名真白丶:BAAALgAECgYJBgAAAA==.',
['椎间']='椎间盘突出:BAAALgAECgYJCgAAAA==.',
['椰青']='椰青美式:BAABLgAFFH8IAAIUAAQJBAK/CwAnAQAUAAQJBAK/CwAnAQAAAA==.',
['楓力']='楓力葵司美疏:BAAALgADCgIJAgAAAA==.',
['榴莲']='榴莲忘返:BAAALgAECgIJAgAAAA==.',
['樱岛']='樱岛麻衣:BAABLgAECn8UAAIHAAYJIhgsPACJAQAHAAYJIhgsPACJAQAAAA==.',
['欣然']='欣然的旋律:BAAALgAECgEJAQAAAA==.',
['欧的']='欧的天空龙:BAAALgAFFAYJBAABLgAFFAYJBQASAIAVAA==.',
['欧阳']='欧阳震华:BAAALgAECgYJBgAAAA==.',
['正式']='正式打工人:BAAALgAECgQJBAAAAA==.',
['此生']='此生丶逍遥:BAABLgAECn8XAAMFAAgJiQYHJAA5AQAFAAcJ8gYHJAA5AQAEAAMJpgRO8QB2AAAAAA==.',
['此间']='此间的奶熊:BAAALgADCgIJAgAAAA==.',
['武帝']='武帝:BAAALgADCgUJBQAAAA==.',
['死亡']='死亡一指:BAAALgAECgkJBQAAAA==.',
['毋忘']='毋忘我:BAACLgAFFH8HAAIZAAMJbQwHCQDBAAAZAAMJbQwHCQDBAAAuAAQKfxwAAhkACAlNGGUOACMCABkACAlNGGUOACMCAAAA.',
['毒藥']='毒藥:BAAALgAECgYJCwAAAA==.',
['比格']='比格迪克曼:BAAALgAECgQJBAAAAA==.',
['汉尼']='汉尼伯尔博士:BAAALgAECgMJBQABLgAECgEJAQAJAAAAAA==.',
['江户']='江户川柯紫:BAAALgADCgcJBwAAAA==.江户川柯蓝:BAABLgAECn8XAAIPAAkJhRY0GgBGAgAPAAkJhRY0GgBGAgAAAA==.',
['汪汪']='汪汪兽:BAAALgAECgUJBQAAAA==.',
['没事']='没事吃虾米:BAAALgADCgcJBwAAAA==.',
['沦仔']='沦仔:BAAALgAECgEJAQAAAA==.',
['油包']='油包腰子:BAAALgADCgcJCAAAAA==.',
['治疗']='治疗训练假人:BAAALgAECgMJAwAAAA==.治疗训练真人:BAABLgAFFH8FAAIBAAUJBgooAgBZAQABAAUJBgooAgBZAQAAAA==.',
['法盲']='法盲:BAAALgAECgEJAQAAAA==.',
['泡露']='泡露达:BAAALgAECgMJAwAAAA==.',
['注意']='注意嗜血:BAAALgAECgEJAQAAAA==.',
['泷宵']='泷宵:BAAALgADCgUJBQAAAA==.',
['泽风']='泽风大过:BAAALgAFFAIJBAABLgAFFAQJBQAGAJUNAA==.',
['洛瑟']='洛瑟斯灬怒风:BAAALgAECgEJAgAAAA==.',
['洪流']='洪流:BAAALgAECgEJAQAAAA==.',
['浪漫']='浪漫龙五:BAACLgAFFH8FAAIRAAMJLAIgMgDcAAARAAMJLAIgMgDcAAAuAAQKfxsAAhEACQmlEAZKAFkCABEACQmlEAZKAFkCAAAA.',
['海星']='海星贝贝:BAAALgAECgIJAgAAAA==.',
['海梦']='海梦灬:BAAALgAECggJAgABLgAFFAQJAwAJAAAAAA==.',
['涂山']='涂山飒蛮:BAAALgAECgUJBgAAAA==.',
['淡然']='淡然审判:BAAALgADCgQJBAABLgAFFAEJAQAJAAAAAA==.',
['清丨']='清丨扬:BAAALgAFFAMJAwAAAA==.',
['清纯']='清纯男高中生:BAAALgAECgEJAQAAAA==.',
['清风']='清风浪冰:BAAALgAECgQJBQAAAA==.',
['渡尘']='渡尘:BAAALgADCgYJBgABLgAECggJIgARAHMhAA==.',
['游离']='游离三界:BAABLgAECn8lAAMEAAgJDR2CKQBqAgAEAAcJDR2CKQBqAgAFAAEJAAC5XQBVAAAAAA==.',
['游荡']='游荡魔法:BAAALgAECgQJBAAAAA==.',
['潶不']='潶不溜秋:BAAALgAECgIJAQAAAA==.',
['濡羽']='濡羽:BAAALgAECgMJAwAAAA==.',
['灬咆']='灬咆哮德:BAAALgAECgQJBwABLgAFFAMJCgASAOMWAA==.',
['灬訥']='灬訥嗰誰灬:BAAALgAECgcJAwAAAA==.',
['灭世']='灭世魔神:BAABLgAFFH8HAAIKAAQJhAUJFwAYAQAKAAQJhAUJFwAYAQAAAA==.',
['烂账']='烂账:BAAALgAECggJBgAAAA==.',
['烈日']='烈日阳阳:BAABLgAFFH8GAAIIAAIJpSJpEADJAAAIAAIJpSJpEADJAAAAAA==.',
['烟锁']='烟锁池塘柳:BAAALgAECgEJAQAAAA==.',
['烬悟']='烬悟:BAAALgAECgUJBQAAAA==.',
['焚尽']='焚尽:BAAALgADCgEJAQAAAA==.',
['焚霜']='焚霜:BAAALgAECgUJBwAAAA==.',
['無声']='無声:BAAALgAECgIJAgAAAA==.',
['無量']='無量福:BAAALgADCgEJAQAAAA==.',
['照彻']='照彻忘川:BAAALgAECgIJAwAAAA==.',
['熊球']='熊球丶:BAAALgAECgkJCQAAAA==.',
['燃烧']='燃烧的腿毛丶:BAAALgAFFAIJBAAAAA==.',
['燚焱']='燚焱炎火:BAAALgAECgEJAQAAAA==.',
['爱理']='爱理贴身护垫:BAAALgAECgkJCQAAAA==.',
['爱莉']='爱莉:BAAALgAECgYJBgAAAA==.',
['爱鱼']='爱鱼的拍拍熊:BAAALgAECgcJAwAAAA==.',
['爻小']='爻小烨:BAAALgAECgYJCQAAAA==.',
['牛一']='牛一:BAAALgAECgEJAQAAAA==.',
['牛旺']='牛旺达:BAAALgAECgUJBAAAAA==.',
['牛花']='牛花草:BAAALgAECgYJCAAAAA==.',
['牛酋']='牛酋长:BAAALgAECgEJAQAAAA==.',
['牧寺']='牧寺:BAAALgADCgYJBgAAAA==.',
['牧薯']='牧薯粉:BAABLgAECn8ZAAMbAAcJ3x3qEQBSAgAbAAcJ3x3qEQBSAgAdAAMJOQ4lGQC0AAAAAA==.',
['犇三']='犇三:BAAALgAECgIJAgAAAA==.',
['犹大']='犹大的杀戮:BAAALgAFFAIJAgAAAA==.',
['狂暴']='狂暴丨黑手谠:BAAALgADCgYJBgAAAA==.狂暴奶牛:BAAALgAFFAEJAQAAAA==.狂暴小墨:BAAALgAECgYJBgAAAA==.狂暴老爹:BAAALgADCgYJCQAAAA==.',
['狐可']='狐可:BAAALgAECgIJAgAAAA==.',
['狠角']='狠角色哦:BAAALgAECgEJAQAAAA==.',
['猎晓']='猎晓:BAAALgAECgEJAQAAAA==.',
['猎魔']='猎魔魔:BAAALgAECgYJBgAAAA==.',
['猫丶']='猫丶夏先生:BAAALgAECgEJAwAAAA==.',
['猫扑']='猫扑风铃:BAABLgAECn8WAAMKAAYJaR7VQADxAQAKAAYJaR7VQADxAQAeAAYJkQJESwDDAAAAAA==.',
['玄玥']='玄玥:BAAALgAECgQJBgAAAA==.',
['王以']='王以太:BAAALgAECgEJAQAAAA==.',
['王小']='王小皓:BAAALgAECgUJBQABLgAFFAIJAgAJAAAAAA==.',
['玛法']='玛法奥斯:BAAALgADCgQJBAAAAA==.',
['玛莲']='玛莲妮亚:BAAALgAECgIJAgAAAA==.',
['玩意']='玩意来了:BAAALgAECgcJEgAAAA==.',
['玩玩']='玩玩灬:BAAALgADCgIJAgAAAA==.',
['琳琳']='琳琳小飞侠:BAAALgADCgcJBwAAAA==.',
['琼楼']='琼楼玉宇:BAABLgAFFH8FAAIZAAUJ7gkFBABEAQAZAAUJ7gkFBABEAQAAAA==.',
['瓦米']='瓦米:BAAALgAECgQJBAAAAA==.',
['电焊']='电焊总会发光:BAAALgAECgkJEAAAAA==.',
['留技']='留技能抢人头:BAAALgAECgMJCQAAAA==.留技能混助攻:BAAALgAECgUJBQAAAA==.',
['略颦']='略颦轻笑:BAAALgAECgYJBgAAAA==.',
['疯狂']='疯狂德荒帝:BAAALgAECgYJDgAAAA==.',
['痴情']='痴情男人:BAAALgAECgcJDAAAAA==.',
['白白']='白白:BAAALgAECgYJDgAAAA==.',
['百事']='百事咖啡:BAAALgAFFAMJAwAAAA==.',
['皮皮']='皮皮丸子:BAAALgADCgQJBAAAAA==.',
['矮小']='矮小的狐狐:BAAALgADCgEJAQAAAA==.',
['砚川']='砚川:BAAALgAECgIJAgAAAA==.',
['破晓']='破晓之路:BAAALgAECgIJBAAAAA==.',
['破碎']='破碎的诺言:BAAALgAFFAEJAgABLgAFFAIJAgAJAAAAAA==.',
['硬币']='硬币决定输赢:BAAALgADCgEJAQAAAA==.',
['祖灵']='祖灵:BAAALgAECgEJAQAAAA==.',
['神奇']='神奇的九寨:BAAALgAECgEJAQAAAA==.',
['神舟']='神舟电脑:BAAALgADCgUJBQAAAA==.',
['神谕']='神谕丶逍遥:BAAALgADCgEJAQAAAA==.',
['离光']='离光:BAAALgAFFAIJBAAAAA==.',
['秀公']='秀公主:BAAALgAECgcJDgAAAA==.',
['秋诺']='秋诺冬渐离:BAAALgADCgYJBgAAAA==.',
['积积']='积积大大德:BAEBLgAFFH8GAAILAAIJ3CGxMgC+AAALAAIJ3CGxMgC+AAABLgAFFAIJAgAJAAAAAA==.',
['笨笨']='笨笨不是笨笨:BAABLgAFFH8HAAIOAAIJIgkdIAB2AAAOAAIJIgkdIAB2AAAAAA==.',
['箐谛']='箐谛:BAAALgAECgIJAgAAAA==.',
['米法']='米法法:BAAALgAECgEJAwAAAA==.',
['米线']='米线锅锅:BAAALgAECgYJCAAAAA==.',
['糖豆']='糖豆包:BAAALgAECgIJAgABLgAFFAIJAgAJAAAAAA==.',
['糖门']='糖门丶好了滚:BAAALgAECgYJDAAAAA==.',
['糥夫']='糥夫:BAAALgAECgUJCQAAAA==.',
['純愛']='純愛戰士:BAAALgAECgEJAQAAAA==.',
['索克']='索克法:BAAALgAECgIJAgAAAA==.',
['索兰']='索兰宝宝:BAAALgADCgMJAwAAAA==.',
['紫浩']='紫浩:BAAALgADCgYJBgAAAA==.',
['纠结']='纠结法:BAAALgADCgEJAQAAAA==.',
['红绫']='红绫:BAAALgAFFAIJAwAAAA==.',
['红绿']='红绿鲤鱼:BAAALgAFFAQJBAABLgAFFAYJCgABAH4fAA==.',
['纳斯']='纳斯达克四万:BAAALgAECgQJBQAAAA==.',
['终结']='终结丶裤衩:BAAALgADCgEJAQAAAA==.',
['肥皂']='肥皂狂魔灵魂:BAAALgAFFAEJAgAAAA==.',
['肯尼']='肯尼两口:BAAALgAECgQJBAAAAA==.',
['胡乱']='胡乱吹吧:BAAALgAECgEJAgAAAA==.',
['胸胸']='胸胸惹人爱:BAAALgAECgYJBgAAAA==.',
['脚步']='脚步矜矜:BAAALgADCggJEgAAAA==.',
['自然']='自然的抉择:BAAALgAECgEJAQAAAA==.',
['艾伦']='艾伦妮塔:BAABLgAFFH8LAAIRAAQJqBOpDQBLAQARAAQJqBOpDQBLAQAAAA==.',
['芒果']='芒果加冰:BAAALgAFFAIJBAAAAA==.',
['芙宁']='芙宁娜:BAABLgAFFH8GAAIRAAMJ0g15LQABAQARAAMJ0g15LQABAQAAAA==.',
['花季']='花季灬蔚蓝:BAAALgAECgQJBAAAAA==.',
['花染']='花染眉间雪丶:BAAALgAECgIJAgAAAA==.',
['花浸']='花浸心头月丶:BAAALgAECgEJAQAAAA==.',
['花火']='花火:BAAALgAECgUJBwAAAA==.',
['苒丶']='苒丶一生:BAAALgAECgYJBgAAAA==.',
['范海']='范海辛:BAAALgAECgEJAQAAAA==.',
['茉莉']='茉莉丶清茶:BAAALgAECgYJDAAAAA==.',
['茶壶']='茶壶:BAAALgAECgYJBgAAAA==.',
['萌娜']='萌娜李花:BAAALgAECgIJAgAAAA==.',
['萤火']='萤火兔:BAAALgADCgcJBwAAAA==.',
['萨球']='萨球丶:BAAALgAECgcJBwAAAA==.',
['萨贝']='萨贝拧:BAAALgAECgEJAgAAAA==.',
['落浅']='落浅术:BAABLgAFFH8GAAIEAAQJlglPGQAmAQAEAAQJlglPGQAmAQAAAA==.落浅枫:BAACLgAFFH8HAAIRAAIJZRFGPACzAAARAAIJZRFGPACzAAAuAAQKfxsAAhEABwm/Hf9LAFMCABEABwm/Hf9LAFMCAAAA.',
['葡萄']='葡萄汤圆:BAAALgAECgUJBQAAAA==.',
['葱葱']='葱葱辣年:BAAALgAECgEJAQAAAA==.',
['蕉小']='蕉小蛙:BAECLgAFFH8GAAIHAAMJCiYnCABPAQAHAAMJCiYnCABPAQAuAAQKfxsAAgcABwnFJfIKAMgCAAcABwnFJfIKAMgCAAAA.',
['虞书']='虞书欣:BAAALgAECgUJBQAAAA==.',
['蛍丶']='蛍丶:BAABLgAFFH8JAAMIAAYJ6hp3DgA2AQAIAAMJByB3DgA2AQAHAAQJcAWHDwDhAAAAAA==.',
['血橙']='血橙维生素:BAAALgAECggJEwAAAA==.',
['血步']='血步:BAACLgAFFH8IAAICAAQJ8ATADQArAQACAAQJ8ATADQArAQAuAAQKfx4AAgIACQn3HfkGADkDAAIACQn3HfkGADkDAAAA.',
['血牛']='血牛:BAAALgAECgUJCgAAAA==.',
['装唐']='装唐阴他一手:BAABLgAFFH8GAAIfAAMJFRKSBgDPAAAfAAMJFRKSBgDPAAAAAA==.',
['西瓜']='西瓜汰郞:BAAALgAECgEJAQAAAA==.',
['赛拉']='赛拉利昂:BAAALgAECgEJAwAAAA==.',
['赦心']='赦心丶冰释:BAAALgAECgYJCgAAAA==.',
['赫斯']='赫斯缇雅:BAAALgAECgYJBwAAAA==.',
['赫箩']='赫箩:BAAALgADCgMJBAAAAA==.',
['赶紧']='赶紧开嗜血:BAAALgADCgUJBQAAAA==.',
['超爱']='超爱吃可丽饼:BAABLgAECn8cAAIeAAcJ8BVUBwBcAQAeAAcJ8BVUBwBcAQAAAA==.',
['超級']='超級小呱籽:BAAALgADCgYJBgAAAA==.',
['跳着']='跳着打你膝盖:BAAALgAECgEJAQAAAA==.',
['踏破']='踏破风雷:BAAALgAECgMJAwAAAA==.',
['踏风']='踏风僧:BAAALgAECgEJAQAAAA==.',
['蹦擦']='蹦擦擦女王:BAAALgAECgMJAwAAAA==.',
['蹬足']='蹬足特:BAAALgAECgUJBwAAAA==.',
['轨道']='轨道加农炮:BAAALgAECgQJBAAAAA==.',
['转世']='转世神医:BAAALgAECgQJBwAAAA==.',
['辅子']='辅子策:BAAALgAECgIJBQABLgAECgEJAQAJAAAAAA==.',
['辉球']='辉球丶:BAAALgAECgYJBgAAAA==.',
['远野']='远野汉娜:BAAALgAFFAMJAwAAAA==.',
['迷恋']='迷恋的魔瘾:BAAALgAECgMJAwAAAA==.',
['追击']='追击闪电侠:BAAALgAECgQJBgAAAA==.',
['追灬']='追灬击:BAAALgADCgQJBAAAAA==.',
['追魂']='追魂使者:BAAALgAECgIJAgABLgAFFAcJBQAQANEWAA==.',
['逐寒']='逐寒:BAAALgAFFAIJAwABLgAFFAIJBgAIAKUiAA==.',
['道劍']='道劍丶非道:BAAALgAECgUJCAAAAA==.',
['道德']='道德糕点:BAAALgAECgMJAwAAAA==.',
['遗失']='遗失丨未来:BAAALgAECgcJEgAAAA==.',
['那个']='那个增辉:BAAALgAECgUJDQAAAA==.',
['那厮']='那厮达克牛逼:BAAALgAECgQJDAAAAA==.',
['邦摁']='邦摁:BAAALgADCgMJAwAAAA==.',
['邪影']='邪影夫人:BAAALgAECgIJAgAAAA==.',
['邮电']='邮电部诗人:BAABLgAECn8WAAINAAcJrRfqLgDxAQANAAcJrRfqLgDxAQAAAA==.',
['部落']='部落代表:BAAALgAECgcJDAAAAA==.',
['野兽']='野兽乌迪尔:BAAALgAECgEJAQAAAA==.',
['鈴鼓']='鈴鼓法絲:BAAALgAECgYJAQAAAA==.',
['鑄劍']='鑄劍:BAAALgAECgEJAwAAAA==.',
['钢得']='钢得过:BAAALgAFFAIJAgAAAA==.',
['银僧']='银僧:BAAALgAECgYJBgAAAA==.',
['银月']='银月之镰:BAAALgADCgcJBwAAAA==.',
['银河']='银河眼光子龙:BAAALgAFFAUJAQABLgAFFAYJBQASAIAVAA==.',
['银灬']='银灬翎:BAAALgADCgMJAwAAAA==.',
['锅边']='锅边糊:BAAALgAECgcJEAAAAA==.',
['锦玲']='锦玲:BAAALgADCgIJAgAAAA==.',
['間單']='間單:BAAALgAECgIJBAAAAA==.',
['闪现']='闪现踩香蕉:BAABLgAECn8WAAIRAAgJGRkkSgBZAgARAAgJGRkkSgBZAgAAAA==.',
['阝槑']='阝槑槑灬:BAAALgAECgEJAQAAAA==.',
['阳光']='阳光落叶:BAAALgAECgMJBAAAAA==.',
['阿凌']='阿凌灬术:BAAALgAFFAEJAQAAAA==.',
['阿周']='阿周收手吧:BAAALgAECgQJBAAAAA==.',
['阿尔']='阿尔伊莉斯:BAACLgAFFH8JAAIKAAMJEBTIGgD6AAAKAAMJEBTIGgD6AAAuAAQKfyEAAyAABwlKG1sMAJQBAAoABgmXHuo9APwBACAABwmjElsMAJQBAAAA.阿尔哞莉斯:BAAALgAECgQJCAABLgAFFAMJCQAKABAUAA==.阿尔琉莉斯:BAAALgAECgcJEQABLgAFFAMJCQAKABAUAA==.阿尔茉莉斯:BAAALgAFFAIJBAABLgAFFAMJCQAKABAUAA==.',
['阿莫']='阿莫西林矮子:BAAALgAECgEJAgAAAA==.',
['阿蒙']='阿蒙哥:BAAALgAECgQJBgAAAA==.',
['阿隆']='阿隆戴特:BAAALgAFFAIJAgABLgAFFAIJBQADAOQdAA==.',
['阿雷']='阿雷奇诺:BAAALgAECgMJAwAAAA==.',
['陈庆']='陈庆之:BAAALgADCgEJAQAAAA==.',
['陈陈']='陈陈噜:BAAALgADCgEJAQAAAA==.',
['陌悠']='陌悠歌:BAAALgAECgcJEgAAAA==.',
['陌路']='陌路黯魂:BAAALgAECgYJDgAAAA==.',
['降臣']='降臣:BAAALgADCgcJBwAAAA==.',
['随风']='随风兜兜侠:BAAALgAECgYJDAAAAA==.',
['难赋']='难赋深情:BAABLgAFFH8GAAIOAAIJ3BqCGQCfAAAOAAIJ3BqCGQCfAAAAAA==.',
['雨痴']='雨痴风丶:BAAALgAECgQJBAABLgAECggJIgARAHMhAA==.',
['雨落']='雨落灬听丶风:BAAALgADCgUJBQAAAA==.',
['霜烬']='霜烬影:BAAALgADCgEJAQAAAA==.',
['霸王']='霸王察基:BAAALgADCgUJBQAAAA==.',
['青涩']='青涩灵魂:BAABLgAECn8XAAMYAAgJORHPLQB0AQAYAAcJGg3PLQB0AQAOAAMJexA6ZACxAAAAAA==.',
['青阳']='青阳斟茶兵:BAAALgAECgEJAQAAAA==.',
['非洲']='非洲吴彦祖:BAAALgAECgYJDwAAAA==.',
['非走']='非走不可:BAAALgADCgEJAQAAAA==.',
['顺风']='顺风奔跑:BAAALgADCgEJAQAAAA==.',
['风中']='风中的温柔:BAAALgADCgUJBQAAAA==.',
['风染']='风染:BAAALgAFFAIJAgAAAA==.',
['风轻']='风轻雨丶:BAABLgAECn8iAAIRAAgJcyHcHQD+AgARAAgJcyHcHQD+AgAAAA==.',
['风领']='风领主:BAAALgAECgMJBgAAAA==.',
['飞行']='飞行鸟:BAAALgAFFAIJAgAAAA==.',
['香蕉']='香蕉与菊花:BAAALgAFFAQJBAAAAA==.香蕉她喜欢吗:BAAALgAECgYJCQAAAA==.',
['马里']='马里奥佛丁:BAAALgAECgIJAwAAAA==.',
['骑冰']='骑冰冰丶:BAAALgADCgIJAgAAAA==.',
['骑斑']='骑斑马的小粉:BAAALgADCgcJBwAAAA==.骑斑马的小绿:BAAALgAECgMJAwAAAA==.',
['骨耳']='骨耳蛋:BAAALgAECgIJAgABLgAECgEJAQAJAAAAAA==.',
['高压']='高压郭:BAAALgAECgcJBwAAAA==.',
['高血']='高血压不倒:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法少女雪梨:BAAALgAECgIJAgAAAA==.魔法球球:BAAALgAECgYJCAAAAA==.',
['鲨鱼']='鲨鱼辣酱:BAAALgAECgYJBgAAAA==.',
['鳳凰']='鳳凰沁雪:BAAALgADCgEJAQAAAA==.',
['鸿逸']='鸿逸:BAAALgADCgYJBgAAAA==.',
['麝香']='麝香猫果:BAAALgAECgMJAwAAAA==.',
['黎明']='黎明之剑:BAAALgADCgEJAQAAAA==.',
['黑色']='黑色切歌者:BAAALgAECgQJBAAAAA==.',
['黯夜']='黯夜灬月丶风:BAAALgAECgEJAQAAAA==.',
['龙之']='龙之飞鱼:BAAALgAECgMJBwAAAA==.',
['龙城']='龙城西荡:BAAALgAECgEJAgAAAA==.',
['龙曦']='龙曦尔:BAAALgAECgQJBQAAAA==.',
['龙霸']='龙霸天:BAAALgAECgcJBwAAAA==.',
['龙鹰']='龙鹰骑士:BAAALgAFFAEJAQAAAA==.',
['龟仙']='龟仙人:BAAALgAECgEJAQAAAA==.',
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
