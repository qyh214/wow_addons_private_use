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

local lookup = {'Shaman-Restoration','Druid-Restoration','Priest-Discipline','Monk-Brewmaster','Mage-Frost','Monk-Windwalker','DemonHunter-Devourer','Warrior-Fury','Evoker-Augmentation','Paladin-Retribution','Paladin-Holy','Warlock-Demonology','Druid-Balance','Mage-Fire','Warrior-Protection','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Shaman-Elemental','DemonHunter-Havoc','Warlock-Destruction','Rogue-Subtlety','Mage-Arcane','Warrior-Arms','Druid-Feral','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Mistweaver','DeathKnight-Frost','Warlock-Ranged','Evoker-Devastation','Druid-Guardian','Paladin-Protection','Hunter-Survival',}
local provider = {region='CN',realm='灰谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adryad:BAAALgAECgMJAwAAAA==.',
Ag='Aged:BAACLgAFFH8SAAIBAAUJZCMTAQABAgABAAUJZCMTAQABAgAuAAQKfycAAgEACAn8JWACAF4DAAEACAn8JWACAF4DAAAA.',
Aj='Ajex:BAAALgAECgYJBwAAAA==.',
Ar='Archon:BAAALgAECgEJAwAAAA==.',
Av='Avery:BAABLgAFFH8HAAICAAMJaw0aEgDZAAACAAMJaw0aEgDZAAAAAA==.',
Br='Breathe:BAAALgAECgcJEAAAAA==.',
Cl='Cleric:BAABLgAECn8ZAAIDAAcJziKTBwDIAgADAAcJziKTBwDIAgAAAA==.',
Co='Cococo:BAAALgAECgMJAwAAAA==.Colo:BAAALgAECgUJBwAAAA==.Cool:BAAALgAECgYJCQAAAA==.',
Cr='Cryforme:BAABLgAFFH8HAAICAAIJDRTYGACaAAACAAIJDRTYGACaAAAAAA==.',
Da='Darktemplar:BAAALgAECgcJAwAAAA==.Davidwu:BAAALgADCgMJAwAAAA==.',
De='Deedo:BAAALgAECgEJAQAAAA==.Delores:BAAALgAECgMJAwAAAA==.',
Di='Dione:BAAALgAECgMJAwAAAA==.',
Dw='Dwan:BAABLgAFFH8GAAIEAAMJag8zFADWAAAEAAMJag8zFADWAAAAAA==.',
En='Enjoy:BAAALgAECgcJCQAAAA==.',
Fi='Fishh:BAAALgAECgIJAgAAAA==.',
Ha='Hadesye:BAAALgAECgQJBAAAAA==.',
Hm='Hmm:BAAALgAECgcJCwAAAA==.',
Ho='Holight:BAAALgADCgUJBQAAAA==.',
In='Inkeyes:BAAALgAECgYJBgAAAA==.',
Jo='Jotl:BAAALgAECgQJBAAAAA==.',
Jt='Jtrdruid:BAAALgAECgEJAQAAAA==.Jtrinsofov:BAABLgAFFH8HAAIFAAMJzBAeKwAJAQAFAAMJzBAeKwAJAQAAAA==.',
Ko='Kororo:BAAALgAECgkJCQAAAA==.',
Ks='Kssddkk:BAAALgAECgUJBQAAAA==.Kssnns:BAAALgAECgEJAQAAAA==.Ksszs:BAAALgAECgUJBQAAAA==.',
La='Lahmbad:BAAALgAECgMJBgAAAA==.',
Li='Lierenn:BAAALgADCgYJBgAAAA==.',
Ll='Llnikita:BAAALgAECgYJCwAAAA==.',
Lu='Luckli:BAAALgAECgQJBQAAAA==.Lucklil:BAAALgAECgYJBgAAAA==.Luckllil:BAACLgAFFH8GAAIGAAMJFw2eCADsAAAGAAMJFw2eCADsAAAuAAQKfxYAAwYACAk9FccXACYCAAYABwlDGMcXACYCAAQABQlXBttkAK4AAAAA.',
Lz='Lzj:BAAALgAECgMJAwAAAA==.',
Ma='Martinlin:BAACLgAFFH8GAAIFAAIJzCHIFgDDAAAFAAIJzCHIFgDDAAAuAAQKfxsAAgUABwm2ItElANsCAAUABwm2ItElANsCAAAA.',
Me='Megumi:BAAALgAECgYJCwAAAA==.',
Mu='Mun:BAAALgAECgYJBgAAAA==.',
Ol='Oldfish:BAACLgAFFH8WAAIHAAYJxyBGAgAyAgAHAAYJxyBGAgAyAgAuAAQKfykAAgcACQk0IfIHAEsDAAcACQk0IfIHAEsDAAAA.',
Oz='Oz:BAAALgAECgEJAQAAAA==.',
Pa='Paladins:BAAALgADCgMJAwAAAA==.',
Pl='Plainjane:BAAALgAECgQJAgAAAA==.',
Pu='Pureice:BAAALgAFFAIJBAAAAA==.',
Ra='Randa:BAAALgADCgQJBAAAAA==.',
Ri='Rinbow:BAABLgAFFH8LAAIIAAQJihdDCwBLAQAIAAQJihdDCwBLAQAAAA==.',
Sa='Saber:BAAALgAECgEJAgAAAA==.Saberlily:BAAALgAECgYJBgAAAA==.Sadism:BAAALgADCgEJAQAAAA==.Sannomiya:BAAALgAECgEJAQAAAA==.',
Se='Sebastian:BAAALgAECgEJAgAAAA==.',
Sh='Shinonome:BAABLgAFFH8KAAIJAAUJQhIpBABQAQAJAAUJQhIpBABQAQAAAA==.',
Si='Sincerely:BAABLgAECn8VAAIIAAcJkxoBLgD6AQAIAAcJkxoBLgD6AQAAAA==.',
St='Starr:BAAALgAECgIJAgAAAA==.',
Sy='Sylvia:BAABLgAECn8WAAICAAYJLiVZGAB0AgACAAYJLiVZGAB0AgABLgAFFAQJCgADAH4dAA==.',
Ta='Talos:BAAALgAECgIJAgAAAA==.',
Ti='Tiffanyco:BAAALgAECgQJBQAAAA==.Tiskry:BAABLgAFFH8FAAICAAIJZxWWGQCXAAACAAIJZxWWGQCXAAAAAA==.',
Wa='Warriors:BAAALgAECgEJAQAAAA==.Wastetime:BAAALgADCgEJAQAAAA==.',
Wo='Wohaha:BAABLgAECn8UAAMKAAcJ4x74WADYAQAKAAcJ4x74WADYAQALAAYJjBXVOACXAQAAAA==.',
Xi='Xictory:BAAALgAECgQJBAAAAA==.',
Xk='Xkknbplus:BAAALgADCgEJAgAAAA==.',
Yi='Yii:BAAALgADCgQJBAAAAA==.',
['一個']='一個人的風:BAAALgAECgYJDwAAAA==.',
['一千']='一千年的刺青:BAAALgAECgYJDQAAAA==.一千年的宿怨:BAAALgAECgYJCAAAAA==.一千年的愤怒:BAAALgADCggJBgAAAA==.',
['一帕']='一帕拉丁一:BAAALgAECgUJBQAAAA==.',
['一抹']='一抹余辉:BAAALgAECgIJAgAAAA==.',
['一朝']='一朝生死两难:BAABLgAFFH8LAAIBAAQJxRqlBwBLAQABAAQJxRqlBwBLAQAAAA==.',
['一根']='一根软白沙:BAAALgAECgYJBgAAAA==.',
['一武']='一武大娘一:BAAALgADCgMJAwAAAA==.',
['一留']='一留不住一:BAAALgAFFAQJBAAAAA==.',
['一谷']='一谷雨:BAAALgAECgEJAQAAAA==.',
['七十']='七十刹那:BAAALgADCgEJAQAAAA==.',
['七曜']='七曜使者:BAAALgAECgcJAwAAAA==.',
['万妖']='万妖之灵:BAAALgAECgMJAwAAAA==.',
['三九']='三九胃泰:BAAALgAECgQJBAAAAA==.',
['三鹿']='三鹿大仙:BAAALgAECgEJAQAAAA==.',
['上官']='上官雪娇:BAAALgAECgcJCAAAAA==.',
['不可']='不可食用:BAAALgAECgYJCgAAAA==.',
['不吃']='不吃丶香菜:BAAALgADCgYJBgAAAA==.',
['不要']='不要哭:BAAALgAECgcJEQAAAA==.',
['且随']='且随疾风前行:BAAALgAECgUJBQAAAA==.',
['东北']='东北偏东:BAAALgAECgYJBgAAAA==.',
['两眼']='两眼一抹黑:BAAALgAECgEJAwAAAA==.',
['丨浮']='丨浮生狱丨:BAAALgAECgEJAQAAAA==.',
['中专']='中专说唱尼格:BAABLgAFFH8NAAIMAAQJwQ6gCAA7AQAMAAQJwQ6gCAA7AQAAAA==.',
['丶千']='丶千阙灬:BAAALgAFFAIJAgAAAA==.',
['丶墨']='丶墨月之城:BAAALgAECgQJBAAAAA==.',
['丶夜']='丶夜如慯:BAAALgAECgEJAgAAAA==.',
['丶奶']='丶奶大力:BAACLgAFFH8GAAINAAMJVRBsDgD4AAANAAMJVRBsDgD4AAAuAAQKfxkAAg0ACAlLHXcQAJ0CAA0ACAlLHXcQAJ0CAAAA.',
['丶染']='丶染月灬凄:BAABLgAECn8hAAMOAAgJOhtzAADtAQAOAAcJCh1zAADtAQAFAAIJIhCIaQE4AAAAAA==.',
['丶陌']='丶陌上傾寒:BAABLgAFFH8JAAIFAAQJGCPSDQCsAQAFAAQJGCPSDQCsAQAAAA==.',
['久旧']='久旧橘:BAABLgAECn8aAAIMAAgJzR2XFgDNAgAMAAgJzR2XFgDNAgABLgAFFAUJEAAJAIgkAA==.',
['二哈']='二哈要发飙了:BAABLgAECn8UAAICAAYJSxmTOwC2AQACAAYJSxmTOwC2AQAAAA==.',
['二噶']='二噶子:BAAALgAECgEJAQAAAA==.',
['云梦']='云梦琪:BAAALgAECgEJAQAAAA==.',
['云鹤']='云鹤:BAAALgAECgYJDAAAAA==.',
['五十']='五十元大洋:BAABLgAFFH8IAAIPAAQJtAXTBwDhAAAPAAQJtAXTBwDhAAAAAA==.',
['五线']='五线缘:BAAALgAECgEJAQAAAA==.',
['亚米']='亚米娜:BAABLgAECn8YAAILAAcJTBVzLQDOAQALAAcJTBVzLQDOAQAAAA==.',
['亮兵']='亮兵器吧:BAAALgAECgIJAwAAAA==.',
['人族']='人族小流氓:BAAALgADCgUJBQAAAA==.',
['人民']='人民:BAAALgADCgQJBQAAAA==.',
['人生']='人生很无奈:BAAALgADCgEJAQAAAA==.',
['什么']='什么弓:BAAALgAECgEJAQAAAA==.',
['今井']='今井莉莎:BAAALgAFFAIJBAABLgAFFAUJCgAJAEISAA==.',
['今夜']='今夜有喜:BAABLgAECn8aAAIFAAcJqxMpeADhAQAFAAcJqxMpeADhAQAAAA==.',
['仗剑']='仗剑倚青天:BAAALgADCgEJAQAAAA==.',
['以德']='以德斧仁:BAAALgADCgEJAQAAAA==.',
['企鹅']='企鹅王国:BAAALgAFFAIJAgAAAA==.',
['会喊']='会喊六的闲鱼:BAABLgAFFH8OAAMQAAYJyBrpAwDCAQAQAAUJyBrpAwDCAQARAAEJAACQHAAXAAAAAA==.',
['会起']='会起名字丶:BAAALgAFFAIJAwAAAA==.',
['伟戈']='伟戈:BAAALgAECgIJAgAAAA==.',
['传播']='传播瘟疫:BAAALgAECgYJBgAAAA==.',
['传说']='传说丶依旧:BAAALgADCgYJBgAAAA==.',
['伤心']='伤心残月:BAAALgAECgYJCgAAAA==.',
['你被']='你被牛打过:BAAALgAFFAQJAQAAAA==.',
['修罗']='修罗斩:BAAALgAFFAQJBAAAAA==.',
['倔强']='倔强胡豆:BAAALgAECgEJAQAAAA==.',
['倾仪']='倾仪乱德:BAAALgAECgEJAgAAAA==.',
['倾天']='倾天圣威:BAAALgAECgQJBQAAAA==.',
['傲娇']='傲娇的少年郎:BAAALgAFFAEJAQAAAA==.',
['光影']='光影牧渣:BAAALgADCgYJBgAAAA==.',
['克里']='克里奧佩特拉:BAAALgAECgcJBwABLgAFFAcJBgAJADUaAA==.',
['八重']='八重神子:BAAALgAECgEJAQABLgAFFAYJBAASAAAAAA==.',
['兰斯']='兰斯洛光:BAAALgAECggJDwAAAA==.',
['关晓']='关晓彤:BAAALgAECgYJBwAAAA==.',
['兵五']='兵五进一:BAAALgADCgIJAgAAAA==.',
['冒牌']='冒牌大英雄:BAAALgADCgEJAQAAAA==.',
['农妇']='农妇三拳:BAAALgAFFAIJAgAAAA==.',
['冬之']='冬之风鈴:BAAALgADCgMJAwAAAA==.',
['冰傷']='冰傷:BAABLgAFFH8JAAIKAAMJLh+CBgAkAQAKAAMJLh+CBgAkAQAAAA==.',
['冰封']='冰封尘伤:BAACLgAFFH8JAAITAAQJTBgvBgD4AAATAAQJTBgvBgD4AAAuAAQKfxwAAhMACAkpHZ4RAJcCABMACAkpHZ4RAJcCAAAA.',
['冰橙']='冰橙美式:BAAALgAECgQJBAAAAA==.',
['冰糖']='冰糖乄雪梨:BAAALgAFFAEJAQAAAA==.',
['冰血']='冰血狂舞:BAABLgAFFH8IAAIFAAQJ4BVbGQBlAQAFAAQJ4BVbGQBlAQAAAA==.',
['冷不']='冷不冷:BAAALgAECgQJBQAAAA==.',
['冷开']='冷开水:BAABLgAFFH8JAAILAAQJhQ9dCwApAQALAAQJhQ9dCwApAQAAAA==.',
['凯萨']='凯萨蒂娜:BAABLgAFFH8FAAIMAAIJ8AefOgCeAAAMAAIJ8AefOgCeAAAAAA==.',
['创造']='创造极限:BAAALgADCgYJBgAAAA==.',
['刮痧']='刮痧:BAAALgAECgMJBgAAAA==.刮痧张大爷:BAAALgADCgcJBwABLgAFFAQJCwAEAFMIAA==.',
['力哥']='力哥哥:BAAALgAECgEJAQAAAA==.',
['功守']='功守道:BAAALgAECgUJBQAAAA==.',
['加林']='加林仙人:BAAALgAFFAEJAQAAAA==.',
['勥字']='勥字分开念:BAAALgAFFAUJAgAAAA==.',
['包龙']='包龙星:BAAALgAECgQJBQAAAA==.',
['北落']='北落紫衫:BAAALgADCgIJAgAAAA==.',
['北霸']='北霸天:BAAALgAECgMJAwAAAA==.',
['十六']='十六夜清心:BAAALgAECgQJBAAAAA==.',
['十年']='十年残梦:BAAALgADCgEJAQAAAA==.',
['千秋']='千秋明月:BAAALgADCgQJBAAAAA==.',
['千羽']='千羽之尘:BAAALgAECgEJAQAAAA==.',
['半城']='半城尘埃落:BAABLgAFFH8BAAIMAAEJYSAcQgBjAAAMAAEJYSAcQgBjAAAAAA==.',
['卑微']='卑微小许:BAAALgADCgEJAwAAAA==.',
['卖拐']='卖拐张大爷:BAABLgAFFH8JAAIRAAMJuQ17CwDCAAARAAMJuQ17CwDCAAABLgAFFAQJCwAEAFMIAA==.',
['卖萌']='卖萌不卖艺:BAAALgAECgYJBgAAAA==.',
['南宫']='南宫乐兮:BAAALgADCgQJBAAAAA==.',
['南柯']='南柯求醉:BAAALgAECgQJBAAAAA==.',
['卡雷']='卡雷莉斯任歌:BAAALgAFFAEJAQAAAA==.',
['又是']='又是夏至:BAAALgAFFAIJAwAAAA==.',
['叔叔']='叔叔丶用力阿:BAAALgAECgcJBQAAAA==.',
['古迩']='古迩丹:BAABLgAFFH8FAAIMAAMJIgRbPQCWAAAMAAMJIgRbPQCWAAAAAA==.',
['叫我']='叫我阿龙吖:BAAALgAFFAIJAgAAAA==.',
['可爱']='可爱到膨胀:BAAALgAFFAIJBAAAAA==.',
['可风']='可风:BAAALgAECgYJCQAAAA==.',
['右手']='右手的傲慢:BAAALgAECgcJDgAAAA==.',
['叶炎']='叶炎:BAAALgAECgMJBwAAAA==.',
['叶采']='叶采章:BAAALgAECgYJDwAAAA==.',
['吃排']='吃排骨的肉肉:BAAALgAECgUJAgAAAA==.',
['听风']='听风雨:BAAALgAECgEJAwAAAA==.',
['吴小']='吴小悦:BAAALgAFFAIJBAAAAA==.',
['吴猛']='吴猛达:BAAALgAFFAIJAgAAAA==.',
['吹哥']='吹哥的力量:BAAALgAECgcJBwAAAA==.',
['呼呼']='呼呼滴:BAAALgAECgYJBgAAAA==.',
['咕咕']='咕咕嘎嘎丶:BAABLgAECn8WAAIHAAcJ/hrkNgAbAgAHAAcJ/hrkNgAbAgAAAA==.',
['咖啡']='咖啡丶牛奶:BAAALgAECgEJAQAAAA==.',
['咯咯']='咯咯哒:BAABLgAFFH8GAAICAAQJ2RnoEQDaAAACAAQJ2RnoEQDaAAAAAA==.',
['咸菜']='咸菜小包:BAAALgADCgEJAQAAAA==.',
['哇哦']='哇哦哦悟:BAAALgAECgIJAgAAAA==.',
['哈哈']='哈哈蜜瓜:BAAALgADCgYJCgAAAA==.',
['哪個']='哪個哪個:BAAALgAECgYJDQAAAA==.',
['啊龙']='啊龙吖丶:BAAALgAECgEJAgAAAA==.',
['喵喵']='喵喵龙:BAAALgADCgEJAQAAAA==.',
['四十']='四十是四十:BAABLgAFFH8GAAMUAAMJBxGyBQD9AAAUAAMJ5hCyBQD9AAAHAAEJrw4AAAAAAAAAAA==.',
['四级']='四级:BAACLgAFFH8IAAIBAAQJFxiOBgBdAQABAAQJFxiOBgBdAQAuAAQKfx8AAgEABwkaJVMKANUCAAEABwkaJVMKANUCAAAA.',
['回到']='回到过去:BAAALgADCgIJAgAAAA==.',
['回忆']='回忆的尘埃:BAABLgAFFH8FAAIBAAMJpAMbFQCwAAABAAMJpAMbFQCwAAAAAA==.',
['困囿']='困囿时分秒:BAAALgAFFAIJAgAAAA==.',
['土元']='土元素:BAAALgAECgMJBAAAAA==.',
['圣光']='圣光咯咯哒:BAAALgAECgEJAQAAAA==.圣光德国人:BAAALgAECgQJBAAAAA==.',
['在云']='在云的这一端:BAACLgAFFH8OAAIBAAQJmBo4BgBjAQABAAQJmBo4BgBjAQAuAAQKfxQAAgEACAnbHxQSAIYCAAEACAnbHxQSAIYCAAAA.',
['坠星']='坠星杖:BAACLgAFFH8HAAIMAAIJlRG7MwCrAAAMAAIJlRG7MwCrAAAuAAQKfyAAAwwACAn0G/4xAEQCAAwABwn0G/4xAEQCABUABAkhFckmACoBAAAA.',
['城风']='城风旧酒:BAAALgADCgYJBgAAAA==.',
['埼玉']='埼玉老师:BAAALgAECgEJAgAAAA==.',
['堕落']='堕落的强总:BAAALgAECgkJCQAAAA==.',
['墨浓']='墨浓:BAAALgADCgEJAQAAAA==.',
['壹橙']='壹橙不染:BAAALgAFFAQJBAAAAA==.',
['夏亦']='夏亦可:BAAALgAECgUJBQAAAA==.',
['夏悠']='夏悠悠:BAAALgAECgIJAgAAAA==.',
['夏至']='夏至夏至:BAAALgAECgYJDgAAAA==.',
['夏莉']='夏莉乄菲蕾特:BAAALgAECgYJCwAAAA==.',
['夕哈']='夕哈:BAAALgAECgEJAgAAAA==.',
['夕牛']='夕牛:BAAALgAECgEJAQAAAA==.',
['夕若']='夕若丶:BAAALgAECgYJCwAAAA==.',
['夕里']='夕里:BAAALgAECgMJBgAAAA==.',
['夜之']='夜之牧師:BAAALgADCgcJBwAAAA==.',
['夜如']='夜如觞:BAAALgADCgEJAQAAAA==.',
['夜行']='夜行丨者:BAAALgAECgEJAQAAAA==.',
['夜长']='夜长梦少:BAAALgAFFAEJAgABLgAFFAQJAwASAAAAAA==.',
['夜魉']='夜魉:BAAALgADCgUJBQAAAA==.',
['大哥']='大哥自己人:BAAALgAECgkJCQAAAA==.',
['大地']='大地牧歌:BAAALgAECgUJBQAAAA==.',
['大波']='大波浪:BAAALgAECgYJBgAAAA==.',
['大火']='大火收汁:BAAALgAFFAEJAQAAAA==.',
['大王']='大王的跟班:BAAALgAECgUJCQAAAA==.大王的酒保:BAAALgAFFAIJAwAAAA==.',
['大虫']='大虫哥:BAAALgAECgMJAwAAAA==.',
['天地']='天地之风:BAAALgADCgEJAQAAAA==.',
['天堑']='天堑弦弓:BAAALgADCgMJBAAAAA==.',
['天才']='天才麦麦坤:BAABLgAFFH8GAAINAAIJTg7tFACdAAANAAIJTg7tFACdAAAAAA==.',
['天放']='天放三世:BAAALgAECgcJDAAAAA==.',
['天河']='天河雪琼:BAAALgADCgEJAQAAAA==.',
['太阳']='太阳下的蛋:BAAALgAECgEJAQAAAA==.',
['奇伦']='奇伦:BAAALgADCgEJAQAAAA==.',
['奔雷']='奔雷熊:BAAALgAECgEJAgAAAA==.',
['奥伊']='奥伊拉姆:BAAALgAECgYJBwAAAA==.',
['奥德']='奥德彪打月交:BAAALgAFFAEJAgAAAA==.',
['女巫']='女巫洛可可:BAAALgAECgYJDQAAAA==.',
['奶妹']='奶妹:BAABLgAFFH8HAAIBAAMJWCCCCwAgAQABAAMJWCCCCwAgAQABLgAFFAQJBAASAAAAAA==.',
['好鬼']='好鬼马:BAABLgAECn8aAAIKAAcJqhlLVADlAQAKAAcJqhlLVADlAQAAAA==.',
['妮莎']='妮莎妮莎:BAAALgAECgUJCAAAAA==.',
['姿态']='姿态艾希奶妈:BAAALgAFFAEJAwAAAA==.',
['嫂嫂']='嫂嫂丶好滑阿:BAAALgAFFAQJBAAAAA==.',
['嫂子']='嫂子:BAAALgAECgUJDAAAAA==.',
['嫑忈']='嫑忈嘦姕:BAAALgAECgYJCAAAAA==.',
['孟子']='孟子义:BAAALgAECgYJCAAAAA==.',
['孤城']='孤城百刃:BAAALgAECgUJDAAAAA==.',
['孤夜']='孤夜:BAAALgAECgEJAQAAAA==.',
['孤独']='孤独之杰:BAAALgAECgYJDAAAAA==.',
['宁凝']='宁凝丶:BAAALgAECgMJBAAAAA==.',
['守门']='守门张大爷:BAABLgAFFH8HAAIEAAMJ1Qu7FQDHAAAEAAMJ1Qu7FQDHAAABLgAFFAQJCwAEAFMIAA==.',
['安焙']='安焙晴明:BAAALgAFFAEJAgAAAA==.',
['宋雨']='宋雨琦:BAAALgAECgUJBQAAAA==.',
['定海']='定海神针:BAAALgADCgIJAgAAAA==.',
['宽油']='宽油滑锅:BAABLgAFFH8FAAIKAAMJuRfzFQD8AAAKAAMJuRfzFQD8AAAAAA==.',
['寂寞']='寂寞古典流:BAAALgADCgEJAQAAAA==.寂寞小熊猫:BAAALgAECgQJBwAAAA==.',
['寒川']='寒川冰吻:BAAALgAECgkJCQAAAA==.',
['对不']='对不起我赢了:BAAALgAECgcJDgAAAA==.',
['小伞']='小伞多多良:BAAALgAFFAIJAgAAAA==.',
['小啵']='小啵波:BAAALgAECgEJBAAAAA==.',
['小姨']='小姨丶快撸阿:BAAALgAFFAQJBAAAAA==.',
['小寒']='小寒:BAAALgAECgQJBAAAAA==.',
['小小']='小小丶子木:BAAALgAFFAQJAQAAAA==.小小邪恶:BAACLgAFFH8NAAIQAAQJGx9nDQBuAQAQAAQJGx9nDQBuAQAuAAQKfxgAAhAABwm/Hr85AFACABAABwm/Hr85AFACAAAA.',
['小拉']='小拉格:BAAALgAECgUJAQABLgAFFAUJBAASAAAAAA==.',
['小无']='小无名:BAAALgAECgEJAQAAAA==.',
['小机']='小机灵鬼:BAACLgAFFH8JAAIIAAMJOhltDwAPAQAIAAMJOhltDwAPAQAuAAQKfxcAAggACQlcGmgNAOsCAAgACQlcGmgNAOsCAAAA.',
['小珉']='小珉:BAAALgADCgUJBQABLgADCgYJBQASAAAAAA==.',
['小飞']='小飞盾来咯:BAAALgAECgYJCQAAAA==.',
['尼可']='尼可波拉斯:BAAALgAECgUJBQAAAA==.',
['尿片']='尿片子:BAAALgAECgEJAwAAAA==.',
['屁神']='屁神的皮卡丘:BAAALgAECgQJCAAAAA==.',
['岭雪']='岭雪:BAAALgADCgIJAgAAAA==.',
['嶶笑']='嶶笑哋廸妮莏:BAAALgAECgcJDQAAAA==.',
['布丽']='布丽奇特:BAAALgAECgcJEAAAAA==.',
['布莱']='布莱克尔:BAAALgAECgUJCQAAAA==.布莱恩:BAAALgADCgUJBQAAAA==.',
['布衣']='布衣史努比:BAAALgAECgQJBAAAAA==.',
['希伯']='希伯来斯:BAACLgAFFH8NAAMUAAQJsRBdBgDpAAAUAAMJpQtdBgDpAAAHAAMJqQwZEQDDAAAuAAQKfxwAAwcACAnXGZY+APoBAAcACAk+FZY+APoBABQABglLHeojAJ0BAAAA.',
['希卡']='希卡希卡希:BAAALgAECgUJBQABLgAFFAQJDQAFAJweAA==.',
['希尔']='希尔瓦娜思思:BAAALgAECgEJAQAAAA==.',
['带带']='带带大宗师:BAAALgAECgMJAwAAAA==.',
['带着']='带着志玲开车:BAAALgAFFAEJAQAAAA==.',
['幸福']='幸福的方向:BAAALgADCgMJAwAAAA==.',
['幽夜']='幽夜吟风:BAABLgAECn8XAAIWAAcJNhsqGQA8AgAWAAcJNhsqGQA8AgAAAA==.',
['幽藍']='幽藍隨風:BAAALgAECgYJDAAAAA==.',
['康斯']='康斯蛋丁:BAAALgAECgUJBQAAAA==.',
['弑情']='弑情橘猫:BAAALgAFFAIJAgAAAA==.',
['张大']='张大爷起门:BAAALgADCgcJBwABLgAFFAQJCwAEAFMIAA==.',
['弹弓']='弹弓弹啊弹:BAAALgAECgUJCAABLgAFFAIJBgAQAD4dAA==.',
['弹跳']='弹跳的肉丸子:BAAALgAECgEJAQAAAA==.',
['影舞']='影舞:BAAALgAECgQJDAAAAA==.',
['影踪']='影踪小师妹:BAABLgAFFH8GAAIEAAMJqBCQFADSAAAEAAMJqBCQFADSAAAAAA==.',
['御风']='御风之舞:BAAALgAECgYJDQAAAA==.',
['德与']='德与香辛料:BAAALgAECgUJAQAAAA==.',
['德保']='德保罗:BAAALgAECgcJDgAAAA==.',
['德林']='德林德林德:BAACLgAFFH8NAAIFAAQJnB7dDgAYAQAFAAQJnB7dDgAYAQAuAAQKfygAAwUACAmLHkw7AIkCAAUABwl3HUw7AIkCABcABAkLHzcLACUBAAAA.',
['德罒']='德罒:BAAALgAECgQJCwAAAA==.',
['念慈']='念慈在此:BAAALgADCgEJAQAAAA==.',
['思念']='思念溢出纸巾:BAAALgAECgEJAwAAAA==.',
['性感']='性感肱二头肌:BAABLgAFFH8MAAMIAAYJjyBgAACjAQAIAAQJriNgAACjAQAYAAIJEhTtBABhAAAAAA==.',
['性格']='性格如此:BAAALgADCgUJBQABLgADCgYJBQASAAAAAA==.',
['恋之']='恋之疯:BAAALgADCgIJAgAAAA==.',
['恐龙']='恐龙抗浪:BAACLgAFFH8JAAINAAMJvAVlBwDEAAANAAMJvAVlBwDEAAAuAAQKfx8AAw0ACAk0GwMbACsCAA0ACAk0GwMbACsCABkABAkLGYMaACIBAAAA.',
['恭喜']='恭喜发财:BAABLgAFFH8LAAIKAAQJEAvXEAAfAQAKAAQJEAvXEAAfAQABLgAFFAUJCQAQAGomAA==.',
['恰似']='恰似少年:BAAALgAECgcJDwAAAA==.',
['悠悠']='悠悠如风:BAAALgAECgYJCAAAAA==.',
['想起']='想起飞咯:BAAALgAFFAMJAwAAAA==.想起飞嘛:BAAALgAECgMJAwAAAA==.',
['愛田']='愛田由:BAAALgAFFAEJAQABLgAFFAIJBgAFAMwhAA==.',
['愤怒']='愤怒哒小鸟:BAABLgAFFH8MAAINAAQJvBA6CwA4AQANAAQJvBA6CwA4AQAAAA==.',
['慈航']='慈航静斋:BAAALgAECgUJDgAAAA==.',
['慕容']='慕容晴雪:BAAALgAECgEJAQAAAA==.',
['慕慕']='慕慕:BAAALgADCgUJCQAAAA==.',
['我也']='我也想低调啊:BAAALgAECgMJAwAAAA==.',
['我就']='我就是艾因:BAAALgAECgUJBwAAAA==.',
['我有']='我有一米八四:BAAALgADCgEJAQAAAA==.',
['我来']='我来变个熊:BAAALgAECgEJAQAAAA==.',
['我欲']='我欲乘风而去:BAAALgAECgQJBAABLgAFFAYJEwACAJEaAA==.',
['我爱']='我爱打萌新:BAAALgAECgEJAQAAAA==.',
['战个']='战个痛啊:BAAALgAFFAIJBAAAAA==.',
['戴晓']='戴晓菲:BAAALgAECgYJCQAAAA==.',
['把淚']='把淚寄給海:BAAALgAFFAEJAQABLgAFFAQJCQATADkmAA==.',
['拂衣']='拂衣踏雪:BAAALgAECgEJAQAAAA==.',
['拉丽']='拉丽亚:BAAALgAFFAEJAQAAAA==.',
['拒绝']='拒绝优雅:BAAALgAECgYJBAAAAA==.',
['捞壳']='捞壳的包丶:BAAALgAFFAMJAwAAAA==.',
['撑花']='撑花:BAAALgAECgYJCgAAAA==.',
['撒旦']='撒旦的回忆:BAAALgADCgIJAgAAAA==.',
['撒满']='撒满鸡丝:BAAALgADCgQJBAAAAA==.',
['放狗']='放狗咬你哈:BAAALgAECgEJAQAAAA==.',
['敌法']='敌法師:BAAALgAFFAEJAQAAAA==.',
['救赎']='救赎:BAAALgAECgcJAQAAAA==.救赎之盾:BAAALgAECgEJAQAAAA==.',
['新人']='新人物:BAAALgAFFAEJAgAAAA==.',
['斷桥']='斷桥殘雪:BAAALgAECgEJAQAAAA==.',
['旅路']='旅路夢中:BAAALgADCgEJAQAAAA==.',
['无梦']='无梦的夜:BAAALgADCgMJAwAAAA==.',
['昊然']='昊然哥哥:BAAALgADCgUJBQAAAA==.',
['星夜']='星夜的离觞:BAABLgAECn8XAAMLAAcJ4wgqSwBLAQALAAcJ4wgqSwBLAQAKAAcJ6glInABGAQAAAA==.星夜的羽觞:BAAALgAECgIJAgAAAA==.',
['星痕']='星痕丨依然:BAAALgAECgYJCgABLgAFFAMJCAANAKQcAA==.星痕丨吟风:BAABLgAFFH8IAAMNAAMJpBz+DAAQAQANAAMJpBz+DAAQAQACAAEJwyG3IQBdAAAAAA==.',
['星繁']='星繁丶:BAAALgAECgYJDQAAAA==.',
['星里']='星里有鬼:BAAALgAECgQJCgAAAA==.',
['春哥']='春哥护体:BAABLgAECn8hAAIKAAgJfB4nIQCmAgAKAAgJfB4nIQCmAgAAAA==.',
['昨夜']='昨夜清风:BAAALgAECgcJBwAAAA==.',
['晓娅']='晓娅:BAAALgAFFAEJAQAAAA==.',
['晚晚']='晚晚公主:BAAALgADCgMJAwAAAA==.',
['晚风']='晚风追日:BAAALgAECgMJAwAAAA==.',
['晨轻']='晨轻:BAAALgAECgYJCAAAAA==.',
['暖暖']='暖暖的小铃铛:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜男丶劣人:BAAALgAECgEJAgAAAA==.',
['暗灬']='暗灬邪:BAAALgAECgEJAQAAAA==.',
['暴走']='暴走笨笨:BAAALgAECgIJAgAAAA==.',
['曹静']='曹静:BAAALgAFFAEJAQAAAA==.',
['最初']='最初最终:BAAALgAFFAEJAQAAAA==.',
['最爱']='最爱乐乐:BAABLgAECn8WAAMFAAcJ5BjMbAD8AQAFAAcJ5BjMbAD8AQAOAAEJiAKvEQAnAAAAAA==.最爱吃虾饺丶:BAACLgAFFH8LAAIFAAQJqRp5BwBkAQAFAAQJqRp5BwBkAQAuAAQKfxYAAwUABwm5HohDAG0CAAUABwm5HohDAG0CAA4AAwmfCdgKAJEAAAAA.',
['月在']='月在人依旧:BAAALgAFFAIJAgAAAA==.',
['月影']='月影三人:BAAALgADCgQJBAAAAA==.月影假面:BAAALgAECgEJAQAAAA==.月影小麻:BAAALgAECgEJAQAAAA==.月影暄:BAAALgAECgEJAQAAAA==.',
['月溪']='月溪:BAAALgAECgMJAwAAAA==.',
['月读']='月读:BAAALgAECgQJBgAAAA==.',
['有点']='有点深邃:BAAALgAECgIJAgAAAA==.',
['有翅']='有翅膀的蝎子:BAAALgAECgYJEQABLgAFFAQJDwAaAO0YAA==.',
['本西']='本西蒙斯:BAAALgADCgYJBgAAAA==.',
['朱若']='朱若丶:BAAALgADCgYJBQAAAA==.',
['机器']='机器猫:BAAALgAECgQJBwAAAA==.',
['杉木']='杉木零落:BAAALgAECgQJBAAAAA==.',
['李善']='李善德:BAAALgAECgEJAQAAAA==.',
['李诺']='李诺萱:BAAALgADCgUJBQAAAA==.',
['杜冷']='杜冷钉:BAAALgADCgIJAgAAAA==.',
['杨梅']='杨梅山路的秋:BAABLgAFFH8FAAIRAAUJ9hW4AwB7AQARAAUJ9hW4AwB7AQAAAA==.',
['林檎']='林檎酱:BAAALgAECgUJBQAAAA==.',
['枭菲']='枭菲猪:BAAALgAECgUJBgAAAA==.',
['柠檬']='柠檬真的不酸:BAAALgAFFAMJBAAAAA==.柠檬红茶:BAABLgAFFH8MAAIbAAQJAyHeCACMAQAbAAQJAyHeCACMAQAAAA==.',
['桺莺']='桺莺莺:BAAALgAECgQJBQAAAA==.',
['梦毁']='梦毁午夜:BAAALgAECgMJBAAAAA==.',
['梭林']='梭林奇力:BAAALgAECgQJBgAAAA==.',
['梵小']='梵小烦:BAACLgAFFH8GAAICAAMJpRfCEQDbAAACAAMJpRfCEQDbAAAuAAQKfxoAAgIABwnHHHQgAD8CAAIABwnHHHQgAD8CAAAA.',
['椛丨']='椛丨椛:BAAALgAECgUJBQAAAA==.',
['樱桃']='樱桃小饼子:BAAALgAECgYJCQAAAA==.',
['橘久']='橘久久:BAAALgAECgEJAQABLgAFFAUJEAAJAIgkAA==.',
['橘子']='橘子味的喵:BAAALgADCgYJBgAAAA==.',
['橙木']='橙木:BAAALgAECgIJAgAAAA==.',
['欧皇']='欧皇不谈:BAAALgAFFAIJAgABLgAFFAcJDQAPAM4ZAA==.',
['殴吃']='殴吃矛:BAAALgAECgEJAQAAAA==.',
['每天']='每天吃饱饭:BAAALgAECgcJBwABLgAFFAQJBAASAAAAAA==.',
['毛绒']='毛绒绒暖呼呼:BAAALgADCgcJBwAAAA==.',
['毛豆']='毛豆:BAABLgAFFH8FAAIcAAIJqRU8DwCnAAAcAAIJqRU8DwCnAAAAAA==.毛豆炒肉:BAAALgAFFAIJAwAAAA==.',
['毳毳']='毳毳:BAAALgAECgMJAwAAAA==.',
['氤氲']='氤氲迷乱:BAAALgAECgYJBgAAAA==.',
['永恒']='永恒依旧:BAAALgAECgcJDwAAAA==.',
['沐沐']='沐沐博博:BAAALgAECgUJBQAAAA==.沐沐暮暮:BAABLgAFFH8GAAMQAAIJQghORQCZAAAQAAIJQghORQCZAAAdAAEJWgAAAAAAAAAAAA==.',
['沐雨']='沐雨橙枫:BAAALgAECgYJBgAAAA==.',
['沙包']='沙包张大爷:BAABLgAFFH8GAAIPAAQJggE3DgBjAAAPAAQJggE3DgBjAAABLgAFFAQJCwAEAFMIAA==.',
['沙拉']='沙拉沙拉:BAAALgAECgYJCwAAAA==.',
['沙漠']='沙漠丶骆驼:BAAALgAECgIJBQAAAA==.',
['法客']='法客游:BAAALgADCgEJAQAAAA==.',
['波丷']='波丷波:BAABLgAFFH8IAAQYAAQJdRXiAQATAQAYAAQJdRXiAQATAQAIAAIJOREFGACpAAAPAAEJ4QvEEAA9AAAAAA==.',
['泰兰']='泰兰戏德:BAAALgAECgYJBgAAAA==.',
['泰凱']='泰凱斯芬利:BAAALgAECgIJAQAAAA==.',
['泰罗']='泰罗奥特曼:BAAALgADCgMJAwAAAA==.',
['泰莉']='泰莉瑟尔:BAAALgAECgcJCgAAAA==.泰莉维娅:BAAALgAECgkJEQAAAA==.',
['洗发']='洗发鹿:BAAALgAECgUJCwAAAA==.',
['洛拉']='洛拉莉丝:BAAALgAECgYJCgAAAA==.',
['洛玖']='洛玖璃:BAAALgADCgEJAgAAAA==.洛玖謧:BAAALgADCgEJAQAAAA==.',
['洛蒂']='洛蒂娅:BAAALgAECgQJBAAAAA==.',
['流丶']='流丶枫:BAAALgAECgcJBwAAAA==.',
['流刄']='流刄若火:BAAALgAECgYJBwAAAA==.',
['流年']='流年秋水:BAABLgAECn8aAAIFAAkJZh4CAgDJAgAFAAkJZh4CAgDJAgABLgAFFAQJBAASAAAAAA==.',
['浅睡']='浅睡:BAAALgAECgEJAQAAAA==.',
['浓浓']='浓浓人生:BAEALgAECgcJBwAAAA==.',
['浪你']='浪你个狼:BAAALgAECgUJAQAAAA==.',
['海伦']='海伦之心:BAAALgAECgUJCQAAAA==.',
['深海']='深海小鱼:BAAALgAECgEJAwAAAA==.',
['满满']='满满丶:BAAALgAECgQJBAAAAA==.',
['漫天']='漫天飞沙:BAAALgAECgEJAgAAAA==.',
['漫漫']='漫漫:BAAALgAECgEJAQAAAA==.',
['澄楠']='澄楠:BAAALgAECgkJCgABLgAFFAUJBQAeAKQVAA==.',
['灬博']='灬博希芙妮:BAAALgAECgYJBwAAAA==.',
['灬墨']='灬墨提斯:BAAALgAECgcJEQAAAA==.',
['灬宝']='灬宝宝灬:BAAALgADCgYJBgAAAA==.',
['炎雨']='炎雨一薩:BAAALgAECgEJAQAAAA==.',
['炽天']='炽天使莉莉斯:BAAALgADCggJCAAAAA==.',
['炽热']='炽热之火:BAAALgAECgUJBQAAAA==.',
['炽魂']='炽魂余烬:BAAALgAFFAEJAQAAAA==.',
['烤焦']='烤焦你:BAAALgAECgUJBQAAAA==.',
['热卤']='热卤毛豆:BAAALgAFFAIJBAAAAA==.',
['熊大']='熊大胆:BAAALgAFFAMJBAAAAA==.',
['熊宝']='熊宝宝:BAAALgADCgEJAQAAAA==.',
['熊雄']='熊雄的圣光:BAAALgAECgcJEAAAAA==.',
['燃烧']='燃烧独恋云:BAAALgAECgQJBQAAAA==.燃烧的小芋头:BAAALgAECgYJBgAAAA==.',
['爷苏']='爷苏格拉底:BAAALgAFFAIJAwAAAA==.',
['牛牟']='牛牟:BAAALgADCgUJBAAAAA==.',
['牧濑']='牧濑红莉曦:BAAALgAECgMJAwAAAA==.',
['犀利']='犀利莫里多:BAAALgAFFAQJBAAAAA==.',
['狐言']='狐言狸语:BAAALgAECgQJBAAAAA==.',
['狗儿']='狗儿蛋:BAAALgADCgEJAQAAAA==.',
['独射']='独射寒江雪:BAAALgAECgEJAQAAAA==.',
['独恋']='独恋云:BAAALgADCgEJAQAAAA==.',
['狮子']='狮子艾力:BAAALgAECgIJAgAAAA==.',
['猎犬']='猎犬长牙:BAAALgAECgYJDAAAAA==.',
['猫之']='猫之报恩:BAAALgAFFAIJAwAAAA==.',
['猫咪']='猫咪骑熊猫:BAAALgAECgYJBwAAAA==.',
['王安']='王安宇:BAAALgAECgMJAwAAAA==.',
['王诺']='王诺诺:BAAALgAECgQJBAAAAA==.',
['琉璃']='琉璃影:BAAALgAECgcJBwAAAA==.',
['琦乐']='琦乐无穷:BAAALgAECgcJDAAAAA==.',
['甘果']='甘果:BAAALgAECgUJBwAAAA==.',
['甛甛']='甛甛六:BAAALgAECgQJBAAAAA==.',
['画了']='画了个圈:BAAALgAECggJDwAAAA==.',
['略懂']='略懂一些拳脚:BAAALgAECgcJBAAAAA==.',
['番茄']='番茄炸蛋:BAAALgAECggJBwAAAA==.',
['疯狂']='疯狂的礼拜四:BAAALgAECgcJAwAAAA==.',
['病毒']='病毒附体:BAAALgAECggJDQABLgAFFAcJAgASAAAAAA==.',
['痕迹']='痕迹:BAAALgAECgEJAgAAAA==.',
['白髮']='白髮三千丈:BAAALgAFFAIJAgAAAA==.',
['百世']='百世浮生:BAAALgAECgQJBAAAAA==.',
['百宝']='百宝袋:BAACLgAFFH8GAAMMAAMJMxLUOQCfAAAMAAIJ7wrUOQCfAAAVAAMJThCVGABNAAAuAAQKfxQAAxUABgmUHlcfAFcBAAwABgn8E96AAFkBABUABQn/G1cfAFcBAAAA.',
['皮卡']='皮卡巴拉:BAABLgAECn8XAAMJAAcJTxs8IAC/AQAJAAYJnho8IAC/AQAfAAUJIR1LFgCNAQAAAA==.',
['盘尼']='盘尼西林:BAAALgAECgEJAgAAAA==.',
['看门']='看门张大爷:BAABLgAFFH8LAAIEAAQJUwjpBgADAQAEAAQJUwjpBgADAQAAAA==.',
['眞希']='眞希:BAAALgAECgkJAQAAAA==.',
['真希']='真希:BAAALgAECgkJCQAAAA==.',
['真旺']='真旺财:BAAALgAECgYJBgAAAA==.',
['破晓']='破晓弥撒:BAAALgAECgIJAgAAAA==.',
['硝酸']='硝酸羊腿:BAAALgAFFAIJBAAAAA==.',
['硫酸']='硫酸脑花:BAABLgAFFH8OAAIEAAQJ3hFqDAAiAQAEAAQJ3hFqDAAiAQAAAA==.硫酸鸡爪:BAACLgAFFH8JAAIPAAQJFB3DAgB4AQAPAAQJFB3DAgB4AQAuAAQKfyAAAg8ACAlJIAUHALwCAA8ACAlJIAUHALwCAAAA.',
['福格']='福格瑞姆:BAABLgAFFH8GAAMbAAQJHhkXFQDzAAAbAAQJ4hIXFQDzAAAaAAEJLR9QIABgAAAAAA==.',
['秘舞']='秘舞:BAAALgAECgUJCAAAAA==.',
['穆穆']='穆穆:BAABLgAECn8VAAQYAAgJRg4YGgAiAQAIAAUJaBEfYQAsAQAYAAUJRQwYGgAiAQAPAAEJAAAAAAAAAAAAAA==.穆穆博博:BAAALgAECgMJAwAAAA==.',
['空间']='空间之门:BAAALgAECgYJCQAAAA==.',
['穿拖']='穿拖鞋走天下:BAAALgAECgQJBgAAAA==.',
['站长']='站长推荐:BAAALgAECgUJCQAAAA==.',
['笨萝']='笨萝卜:BAAALgAECgYJCgAAAA==.',
['简单']='简单点点:BAAALgAFFAEJAQAAAA==.',
['精灵']='精灵婉儿:BAAALgADCgEJAQAAAA==.',
['糖一']='糖一果:BAAALgAECgQJBQAAAA==.',
['素衣']='素衣青丝:BAABLgAECn8UAAICAAcJIxIFSQB+AQACAAcJIxIFSQB+AQAAAA==.',
['紫坨']='紫坨坨:BAAALgAECgQJBAAAAA==.',
['红发']='红发张大爷:BAABLgAFFH8IAAIRAAMJdwdnDACuAAARAAMJdwdnDACuAAABLgAFFAQJCwAEAFMIAA==.',
['红莲']='红莲业火:BAAALgAECgMJAwAAAA==.红莲续断:BAACLgAFFH8QAAIFAAUJqRqFCgDKAQAFAAUJqRqFCgDKAQAuAAQKfx0AAgUACQm4JfECAM8DAAUACQm4JfECAM8DAAAA.',
['红颜']='红颜如霜:BAAALgAECgcJCAAAAA==.',
['红魔']='红魔:BAAALgADCggJCAAAAA==.',
['纳兹']='纳兹德雷格:BAAALgAECgIJAgAAAA==.',
['纳各']='纳各慕诗:BAAALgAECgQJAwAAAA==.',
['缪莉']='缪莉:BAAALgAECgUJBwAAAA==.',
['罗永']='罗永浩:BAAALgAECgEJAQAAAA==.',
['老板']='老板来俩斤萌:BAABLgAFFH8LAAIEAAQJgxtdAwBMAQAEAAQJgxtdAwBMAQAAAA==.',
['老铁']='老铁丶扎心了:BAAALgAECgEJAwAAAA==.',
['耐斯']='耐斯:BAAALgAECgYJBgAAAA==.',
['聂老']='聂老大:BAAALgAECgEJAQAAAA==.',
['职业']='职业钕杀手:BAAALgADCgMJAgAAAA==.',
['肆枫']='肆枫院夜一:BAAALgAECgYJBgAAAA==.',
['胆怯']='胆怯丷糊糊:BAAALgAECgUJCgAAAA==.',
['胖胖']='胖胖虎快跑:BAAALgADCgUJBQAAAA==.',
['胖虎']='胖虎张大爷:BAAALgAECgYJBgABLgAFFAQJCwAEAFMIAA==.',
['胥胥']='胥胥叨叨:BAAALgADCgEJAQAAAA==.',
['脆脆']='脆脆丶猎:BAAALgAECgMJBgAAAA==.',
['腐化']='腐化之心:BAAALgAECgIJAgAAAA==.',
['自由']='自由的天巫:BAAALgAECgEJAQAAAA==.',
['自贡']='自贡超人:BAAALgAECgUJBQAAAA==.',
['至高']='至高之拳:BAAALgAECgUJBgAAAA==.',
['舌尖']='舌尖上的苏牙:BAAALgAECgEJBAAAAA==.',
['舒舒']='舒舒服服:BAAALgAECgQJBAAAAA==.',
['艾无']='艾无戒:BAAALgADCgIJAgAAAA==.',
['艾美']='艾美达:BAAALgADCgkJCQAAAA==.',
['艾露']='艾露尼丶钉刺:BAAALgAECgcJBgAAAA==.',
['芒果']='芒果西米露:BAABLgAFFH8NAAIEAAQJ3Bj1BwBTAQAEAAQJ3Bj1BwBTAQAAAA==.',
['花天']='花天狂骨:BAAALgAECgYJDAAAAA==.',
['花影']='花影移:BAAALgAECgYJCwAAAA==.',
['苏格']='苏格兰式调情:BAAALgAECgQJAgAAAA==.',
['苏牧']='苏牧橙:BAAALgAFFAIJAgAAAA==.',
['若叶']='若叶睦:BAAALgAECgIJAQAAAA==.',
['若霜']='若霜:BAABLgAECn8ZAAQXAAcJbhzxAgBUAgAXAAcJGxzxAgBUAgAFAAYJSRhgmwCfAQAOAAQJBRcwBwAVAQAAAA==.',
['茜茜']='茜茜涅槃丶:BAAALgADCgYJBgAAAA==.',
['茶派']='茶派:BAAALgAECgYJBwAAAA==.',
['荔枝']='荔枝与胖多肉:BAABLgAFFH8IAAIKAAQJYBMwDABKAQAKAAQJYBMwDABKAQAAAA==.荔枝与芒果冰:BAABLgAFFH8KAAIFAAQJegvRHgBOAQAFAAQJegvRHgBOAQAAAA==.',
['莉娅']='莉娅:BAAALgAECgcJBwAAAA==.',
['莱昂']='莱昂庄森:BAAALgAECgkJDwAAAA==.',
['菱纱']='菱纱纱:BAAALgADCgEJAQAAAA==.',
['萧峰']='萧峰:BAAALgAFFAIJBAAAAA==.',
['葉子']='葉子红了:BAAALgADCgEJAQAAAA==.',
['葫芦']='葫芦酒大人:BAAALgAFFAEJAgAAAA==.',
['蓝天']='蓝天玉暖:BAAALgAECgEJAQAAAA==.',
['蓝牙']='蓝牙重新连接:BAABLgAECn8bAAIQAAcJvB7URAAmAgAQAAcJvB7URAAmAgAAAA==.',
['蔚蔚']='蔚蔚的夏天:BAAALgAECgQJBAAAAA==.',
['蔸里']='蔸里有币:BAACLgAFFH8MAAIFAAQJXyDXEACPAQAFAAQJXyDXEACPAQAuAAQKfxYAAgUACQkvH/sRADsDAAUACQkvH/sRADsDAAAA.',
['虎灬']='虎灬爺:BAAALgAECgMJAwAAAA==.虎灬虎:BAAALgAECgkJCQAAAA==.',
['虚空']='虚空之灵:BAAALgAFFAIJAwAAAA==.',
['蛋蛋']='蛋蛋丶忧伤:BAAALgAECgEJAQAAAA==.',
['蝎子']='蝎子玩弹弓:BAACLgAFFH8PAAMaAAQJ7RgjAwBaAQAaAAQJow8jAwBaAQAbAAQJxxgfDQBMAQAuAAQKfysAAxsACQnGIK8EAFQDABsACQnGIK8EAFQDABoAAwmpEt8wAIgAAAAA.',
['血之']='血之神启:BAAALgADCgUJBQAAAA==.',
['血兽']='血兽霸霸:BAAALgAFFAEJAQAAAA==.',
['血影']='血影追月:BAAALgAECgYJBQAAAA==.',
['血腥']='血腥浪漫:BAAALgADCgMJAwAAAA==.',
['裁衣']='裁衣匠:BAAALgAECgcJBwABLgAFFAUJCgAJAEISAA==.',
['西楚']='西楚灬霸王:BAAALgAECgkJDAAAAA==.',
['要奶']='要奶一口吗:BAAALgAECgYJCwAAAA==.',
['言笑']='言笑:BAAALgAECgEJAQAAAA==.',
['诶呦']='诶呦我佛了:BAAALgAECgEJAQAAAA==.',
['豌豆']='豌豆米米:BAACLgAFFH8JAAMIAAUJgCOsBACrAQAIAAQJgCOsBACrAQAYAAEJAAARCAB0AAAuAAQKfxgAAggACQnJHhUMAPgCAAgACQnJHhUMAPgCAAAA.',
['豬潴']='豬潴:BAAALgAECgcJEgAAAA==.',
['财神']='财神乄爷:BAAALgAECgMJAwAAAA==.',
['败神']='败神:BAAALgAECgYJBgAAAA==.',
['贺新']='贺新郎:BAAALgAECgYJDgAAAA==.',
['贼低']='贼低調:BAAALgAECgYJBgAAAA==.',
['赫斯']='赫斯佩拉克丝:BAAALgAECgcJDwAAAA==.',
['赵潄']='赵潄芬:BAAALgAECgkJCQAAAA==.',
['超人']='超人丨卜會飛:BAAALgAECgcJCQAAAA==.',
['超导']='超导体:BAAALgAECgkJCQAAAA==.',
['超级']='超级可恨:BAAALgAECgUJBQAAAA==.',
['跟着']='跟着老子冲:BAAALgAECgYJEAAAAA==.',
['路人']='路人甲乙丙丁:BAAALgADCgQJBAAAAA==.',
['路小']='路小雨丶:BAAALgAECgkJBwABLgAFFAUJBQAQADsiAA==.',
['路边']='路边蹲一丫头:BAAALgAECgYJBgAAAA==.',
['路过']='路过晴天:BAAALgAECgcJEAAAAA==.',
['路遥']='路遥知马:BAAALgAECgYJCgAAAA==.',
['踢死']='踢死你丫的:BAAALgAECgEJAQAAAA==.',
['轻描']='轻描淡写訫碎:BAABLgAFFH8FAAIgAAIJcQd2BQBhAAAgAAIJcQd2BQBhAAAAAA==.',
['辛弃']='辛弃疾:BAAALgADCgkJDAAAAA==.',
['辛徳']='辛徳瑞拉:BAAALgAFFAMJBAAAAA==.',
['这装']='这装备我毛了:BAABLgAFFH8GAAIKAAQJ8BknAgB5AQAKAAQJ8BknAgB5AQAAAA==.',
['这里']='这里不可以:BAAALgADCgMJAwAAAA==.',
['远武']='远武僧:BAAALgAFFAQJBAAAAA==.',
['迷之']='迷之泰钽:BAAALgAECgQJCAAAAA==.',
['逍遥']='逍遥天镜:BAAALgAECgQJBAAAAA==.',
['遥见']='遥见青丝断:BAAALgAECgcJBwAAAA==.',
['邪灵']='邪灵印:BAABLgAFFH8IAAMMAAUJKxotCgCMAQAMAAQJthotCgCMAQAVAAIJlBLhCwCsAAAAAA==.',
['鄙人']='鄙人不善奔跑:BAABLgAFFH8JAAIQAAQJwAthGwA2AQAQAAQJwAthGwA2AQAAAA==.',
['重瞳']='重瞳者:BAAALgADCgcJCAAAAA==.',
['野人']='野人也有爱:BAACLgAFFH8HAAIaAAMJhgv9DAD5AAAaAAMJhgv9DAD5AAAuAAQKfxoAAhoACAkXHrsSAKECABoACAkXHrsSAKECAAAA.',
['钟苗']='钟苗苗:BAAALgAFFAIJAwAAAA==.',
['钢板']='钢板张大爷:BAABLgAFFH8JAAIPAAMJvQOtCgCfAAAPAAMJvQOtCgCfAAABLgAFFAQJCwAEAFMIAA==.',
['钥石']='钥石枯竭者:BAAALgAECgIJAgAAAA==.',
['铠哥']='铠哥:BAAALgADCgEJAQAAAA==.',
['银月']='银月贤者:BAAALgAECgEJAQAAAA==.',
['镖人']='镖人:BAAALgAECgEJAQAAAA==.',
['闷墩']='闷墩丶:BAAALgADCgUJBQAAAA==.',
['阡陌']='阡陌:BAAALgAECgEJAQAAAA==.',
['防守']='防守一波:BAAALgAFFAEJAQAAAA==.',
['阿睿']='阿睿抚摸阿春:BAABLgAFFH8IAAIKAAQJFiOFBACpAQAKAAQJFiOFBACpAQAAAA==.',
['陈卿']='陈卿璃:BAAALgAECgEJAQAAAA==.',
['陈诗']='陈诗若伊:BAAALgAFFAIJAwABLgAFFAIJBgAQAD4dAA==.',
['陈霜']='陈霜红叶:BAABLgAFFH8GAAIQAAIJPh1YOQCpAAAQAAIJPh1YOQCpAAAAAA==.',
['陌凌']='陌凌橒:BAAALgAECgEJAQAAAA==.',
['陌北']='陌北:BAAALgAECgUJBQAAAA==.',
['陌小']='陌小鬼:BAAALgAECgIJAwAAAA==.',
['随风']='随风飘霖:BAACLgAFFH8LAAIKAAQJ7R8sBgCMAQAKAAQJ7R8sBgCMAQAuAAQKfxoAAwoACAm3Hu4kAJMCAAoACAm3Hu4kAJMCACEAAgnLCho8AE4AAAEuAAUUBgkXAAoA3R8A.',
['隔壁']='隔壁老唐丶:BAAALgAECgUJBQAAAA==.',
['雪中']='雪中茶栈:BAAALgAECgQJBgAAAA==.',
['雪欺']='雪欺霜:BAAALgAECgYJBwAAAA==.',
['雷班']='雷班纳:BAAALgAECgEJAQAAAA==.',
['雷番']='雷番茄:BAAALgADCgEJAQAAAA==.',
['雾切']='雾切之回光:BAAALgADCgEJAgAAAA==.',
['霸王']='霸王别搞姬:BAAALgAECgIJAgAAAA==.',
['霸霸']='霸霸:BAAALgAECgYJCwAAAA==.',
['靈界']='靈界冰释:BAAALgADCggJCAAAAA==.',
['青山']='青山:BAAALgAECgYJCQAAAA==.',
['青杉']='青杉:BAABLgAFFH8GAAIMAAQJehuMKQDNAAAMAAQJehuMKQDNAAAAAA==.',
['青蜂']='青蜂侠的二舅:BAAALgAFFAEJAQAAAA==.',
['頂頂']='頂頂:BAABLgAECn8XAAIbAAcJyxepIAAeAgAbAAcJyxepIAAeAgAAAA==.',
['风之']='风之恋云:BAAALgAECgMJAwAAAA==.风之玫:BAAALgAECgUJCAAAAA==.',
['风元']='风元素:BAAALgAECgMJBAAAAA==.',
['风华']='风华玉碎:BAAALgAECgcJDwAAAA==.',
['风见']='风见一幽香:BAAALgAFFAIJAwAAAA==.',
['风诉']='风诉:BAABLgAFFH8FAAIbAAUJfw6OCQCAAQAbAAUJfw6OCQCAAQAAAA==.',
['飞了']='飞了几个机:BAAALgADCgcJBwAAAA==.',
['马头']='马头不市区:BAABLgAFFH8FAAMaAAIJohzECwC7AAAaAAIJohzECwC7AAAiAAIJjgvSBACnAAAAAA==.',
['马报']='马报国:BAAALgAECgMJAwAAAA==.',
['马赛']='马赛克的幽默:BAAALgAFFAMJBAAAAA==.马赛克的汤勺:BAAALgAECgUJCQAAAA==.',
['骨骨']='骨骨:BAAALgADCgcJCgAAAA==.',
['高冷']='高冷御姐:BAAALgADCgUJBQAAAA==.',
['高松']='高松灯:BAAALgADCgUJBQAAAA==.',
['魂之']='魂之牧者:BAAALgAECgYJEAAAAA==.',
['鱼人']='鱼人骑士:BAAALgAECgkJCgAAAA==.',
['鲨鱼']='鲨鱼灬辣椒:BAAALgADCgEJAQAAAA==.',
['麦兜']='麦兜的世界:BAACLgAFFH8MAAINAAQJNyPIBACfAQANAAQJNyPIBACfAQAuAAQKfxQAAwIACQnOILEIAAQDAAIABwmcJbEIAAQDAA0ABglfItoaAC0CAAAA.',
['黄昏']='黄昏乐章:BAAALgAECgcJDwAAAA==.',
['黄豆']='黄豆炖猪蹄:BAAALgAECgEJAQAAAA==.',
['黄黚']='黄黚黚:BAAALgAECgIJAQAAAA==.',
['黑夜']='黑夜中那抹绿:BAAALgAECgQJBAAAAA==.',
['黑猫']='黑猫大侠:BAAALgAECgEJAwAAAA==.',
['黑白']='黑白花妖:BAAALgAECgEJAQAAAA==.',
['黑红']='黑红张大爷:BAAALgAFFAMJBAABLgAFFAQJCwAEAFMIAA==.',
['黑风']='黑风要塞:BAAALgAECgYJEgAAAA==.',
['黯之']='黯之哀伤:BAAALgADCgQJBAAAAA==.',
['黯然']='黯然之泪:BAAALgAECgYJCwAAAA==.',
['齐夏']='齐夏:BAAALgAECgcJAgAAAA==.',
['龍崗']='龍崗大青山:BAAALgAECgcJAgABLgAFFAQJBAASAAAAAA==.',
['龙虾']='龙虾不是肉:BAAALgAECgYJBgAAAA==.',
['龙龙']='龙龙人:BAACLgAFFH8QAAMJAAUJiCT3AgAFAgAJAAUJiCT3AgAFAgAfAAEJAAApCgBSAAAuAAQKfywAAwkACQntIp0BAKoDAAkACQl+Ip0BAKoDAB8ABwlnJbAEALwCAAAA.',
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
