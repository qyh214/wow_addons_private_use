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

local lookup = {'Hunter-BeastMastery','Shaman-Elemental','Shaman-Restoration','Unknown-Unknown','Mage-Frost','Hunter-Marksmanship','Mage-Fire','Paladin-Holy','DemonHunter-Devourer','Priest-Holy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','DeathKnight-Unholy','Monk-Windwalker','Monk-Brewmaster','DemonHunter-Havoc','Warrior-Fury','Rogue-Subtlety','Warrior-Arms','Priest-Shadow','Hunter-Survival','Evoker-Augmentation','Druid-Balance','Paladin-Protection','Paladin-Retribution','Evoker-Devastation','Evoker-Preservation','Druid-Restoration','Priest-Discipline','Warrior-Protection','DeathKnight-Blood','Rogue-Assassination',}
local provider = {region='CN',realm='幽暗沼泽',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abaddonn:BAAALgAFFAIJAwAAAA==.',
Ak='Akmd:BAAALgAECgYJCQAAAA==.',
Al='Alioe:BAAALgADCgEJAQAAAA==.',
Am='Amaterasu:BAAALgAECgEJAQAAAA==.',
An='Antimage:BAAALgAECgUJBQAAAA==.',
Ar='Arcee:BAABLgAFFH8HAAIBAAMJbxu8BwAnAQABAAMJbxu8BwAnAQAAAA==.Arlecchino:BAAALgAECgEJAQAAAA==.Arthasprince:BAAALgADCgIJAgAAAA==.',
As='Astraea:BAAALgAECgYJBgAAAA==.',
At='Atomcat:BAAALgAECgEJAQAAAA==.',
Au='Autumn:BAACLgAFFH8MAAICAAQJPRIgCgBBAQACAAQJPRIgCgBBAQAuAAQKfygAAwIACQlmIzkCAJEDAAIACQlmIzkCAJEDAAMAAgl3CPclAFsAAAAA.',
Ay='Ayingg:BAAALgAECgYJDAAAAA==.',
Ba='Babyboy:BAAALgAECgIJAwAAAA==.',
Bl='Blackmythic:BAAALgAFFAIJAgAAAA==.',
Cg='Cgssd:BAAALgAECgEJAQAAAA==.',
Ci='Ciel:BAAALgAECgcJBwABLgAFFAcJBAAEAAAAAA==.',
Cn='Cnzlb:BAAALgAECgEJAQAAAA==.',
Cr='Cristino:BAAALgAECgQJCgAAAA==.Crystalapple:BAAALgAECgYJCQAAAA==.',
Cy='Cyutian:BAAALgAECgkJDAABLgAFFAUJEAAFAJURAA==.',
Da='Dakerdog:BAAALgADCgYJBgAAAA==.Darkhunteric:BAAALgAECgYJBwAAAA==.',
De='Deletes:BAAALgADCgIJAgAAAA==.Deyn:BAAALgAECgkJBgABLgAFFAcJBgAGAG4FAA==.',
Dr='Drama:BAAALgAECgkJEAAAAA==.',
Eu='Eulogy:BAACLgAFFH8LAAIFAAQJlQ8BHQBXAQAFAAQJlQ8BHQBXAQAuAAQKfyEAAgUACAlBHwMtAL4CAAUACAlBHwMtAL4CAAAA.',
Fe='Fergie:BAAALgAECgYJBgAAAA==.',
Fi='Fifi:BAAALgADCgEJAQAAAA==.',
Fr='Frenzy:BAAALgAECgcJBwAAAA==.',
Ga='Galygeygey:BAAALgAECgEJAQAAAA==.',
He='Heavensward:BAAALgADCgEJAQAAAA==.',
In='Innovation:BAACLgAFFH8GAAMHAAMJNw4fAQBiAAAFAAMJmgq0HgCUAAAHAAEJRB0fAQBiAAAuAAQKfxwAAwcABwkFGBgFAHYBAAUABwmGFuVtAPkBAAcABglKGhgFAHYBAAAA.Intochaos:BAAALgAECgQJBgAAAA==.',
It='Itomcat:BAAALgAFFAMJBAAAAA==.',
Jo='Jobsin:BAAALgAFFAQJBAAAAA==.',
Jt='Jtyhxtf:BAAALgAECgkJCQAAAA==.',
Ju='Jui:BAAALgAECgMJAwAAAA==.',
Le='Lemon:BAABLgAFFH8IAAIIAAMJXx7qDAAOAQAIAAMJXx7qDAAOAQAAAA==.',
Li='Linkingsone:BAAALgAECgEJAQAAAA==.',
Lo='Loneye:BAAALgAECgEJAQAAAA==.',
Lu='Luna:BAAALgAECgEJAQAAAA==.',
Ma='Magisk:BAAALgAFFAIJAwAAAA==.',
Na='Nameless:BAAALgAECgEJAgAAAA==.',
Ne='Neekey:BAAALgAECgYJCQAAAA==.',
Ni='Nianiaz:BAAALgAECgYJBwAAAA==.',
Og='Oglo:BAAALgAECgUJBgAAAA==.',
Ol='Olivia:BAAALgAECgYJCQAAAA==.',
On='Onlylovesky:BAABLgAFFH8GAAIBAAIJHBtoFQCvAAABAAIJHBtoFQCvAAAAAA==.',
Pl='Playeriqrpxv:BAAALgAECgYJBgAAAA==.',
Pr='Prayicedown:BAAALgAECgQJCAAAAA==.',
Qu='Quay:BAAALgAECgQJBgAAAA==.',
Re='Rebecca:BAAALgAECgQJBQAAAA==.',
Ri='Rivenhong:BAAALgAECgYJBwAAAA==.',
Se='Secretletter:BAAALgAECgQJBQAAAA==.',
Si='Simin:BAAALgAFFAIJAgAAAA==.Simplyy:BAAALgAECgEJAQAAAA==.',
St='Starhunter:BAABLgAFFH8FAAIGAAMJjwPLGQC2AAAGAAMJjwPLGQC2AAAAAA==.Stocklng:BAAALgAECgcJCwAAAA==.',
To='Tonysword:BAAALgAECgYJCQAAAA==.',
Tr='Try:BAAALgADCgYJBwAAAA==.',
Tw='Twenty:BAAALgADCgUJBQAAAA==.',
Un='Underthemoon:BAAALgAECgEJAQAAAA==.',
Ur='Urlippsl:BAAALgAECgIJBgAAAA==.',
Wh='Whitebinder:BAAALgAECgcJAQABLgAFFAYJDQAJAAAcAA==.',
Ye='Yellowoman:BAAALgADCgMJAwAAAA==.',
Yo='Youngahce:BAAALgADCgQJBAAAAA==.',
Yu='Yuxuan:BAAALgADCgEJAQAAAA==.',
Zi='Zizian:BAAALgAECgkJCAAAAA==.',
Zo='Zoeivy:BAABLgAFFH8HAAIKAAMJLh6dBgAQAQAKAAMJLh6dBgAQAQAAAA==.Zoloftz:BAAALgADCgYJBgAAAA==.',
Zs='Zsyhqs:BAAALgAECgYJBgAAAA==.',
Zz='Zzizizziz:BAAALgAECgUJBQAAAA==.',
['一刀']='一刀入魂:BAAALgAECgYJBgAAAA==.',
['一烨']='一烨知秋:BAAALgAECgYJBAAAAA==.',
['一瓶']='一瓶老酒:BAAALgAECgEJAgAAAA==.',
['一种']='一种习惯:BAAALgAECgUJCAAAAA==.',
['一箭']='一箭卿心:BAAALgAECgEJAgAAAA==.',
['一米']='一米半半:BAAALgAECgcJEQAAAA==.',
['一習']='一習慣一:BAAALgAECgkJBgAAAA==.',
['一脸']='一脸盆糊死你:BAAALgAECgYJBgAAAA==.',
['一身']='一身怨念:BAAALgADCgEJAQABLgAFFAQJBAAEAAAAAA==.',
['一颗']='一颗咪豆:BAAALgAECgQJCAAAAA==.',
['七品']='七品:BAAALgAECgMJBAAAAA==.',
['万物']='万物皆有灵:BAAALgAECgEJAQAAAA==.',
['丈母']='丈母娘之怒:BAAALgAECgQJBAAAAA==.',
['三鹿']='三鹿:BAAALgADCgYJCgAAAA==.',
['上杉']='上杉繪梨衣:BAAALgAECgUJAwAAAA==.',
['丌丌']='丌丌:BAAALgAECgEJAQAAAA==.',
['不可']='不可以摸尾巴:BAAALgAECgEJAQAAAA==.',
['不喜']='不喜欢吃蒜苗:BAAALgAECgYJCwAAAA==.',
['不回']='不回头随你打:BAAALgAECgQJBQAAAA==.',
['不如']='不如:BAAALgAECgYJBgAAAA==.',
['不小']='不小心坑下:BAAALgADCgcJBQAAAA==.',
['不羁']='不羁:BAAALgAFFAEJAQAAAA==.',
['不语']='不语:BAABLgAECn8kAAQLAAkJBBHoCgDHAQALAAgJBBHoCgDHAQAMAAQJww1vNADlAAANAAEJAACYCgAAAAAAAA==.',
['不饱']='不饱有刷子:BAAALgAECgQJBgAAAA==.',
['不髙']='不髙興:BAAALgAFFAEJAQAAAA==.',
['与寂']='与寂寞侑染:BAAALgAECgEJAQABLgAFFAIJAgAEAAAAAA==.',
['专属']='专属蓓寳寳:BAAALgAECgQJCAAAAA==.',
['专采']='专采花姑娘:BAAALgAECgYJDQAAAA==.',
['东方']='东方夜未明:BAAALgAECgEJAQAAAA==.',
['东门']='东门小管家:BAABLgAFFH8HAAIOAAMJfhbpBQDoAAAOAAMJfhbpBQDoAAAAAA==.东门总管家:BAAALgAFFAIJAgAAAA==.',
['两袖']='两袖清风:BAAALgAECgEJAQAAAA==.',
['丨五']='丨五更琉璃丨:BAAALgADCgYJCQAAAA==.',
['丨希']='丨希尓瓦娜斯:BAAALgAECgMJBAAAAA==.',
['丨德']='丨德不常湿丨:BAAALgAECgUJBQAAAA==.',
['丨灬']='丨灬昶葉丶:BAAALgAECgEJAgAAAA==.',
['个高']='个高乃水足:BAAALgAECgcJCgAAAA==.',
['丫头']='丫头和丫掌:BAACLgAFFH8HAAMDAAMJhxOnCwCOAAADAAIJEAunCwCOAAACAAEJBwp1HgBIAAAuAAQKfx4AAwMABwkvHUsgAB0CAAMABwkvHUsgAB0CAAIABwlGGz0sALcBAAAA.',
['丶旅']='丶旅店老板:BAAALgAECgEJAQAAAA==.',
['丶晨']='丶晨晨丶:BAAALgAECgMJBQAAAA==.',
['丶胭']='丶胭脂粉:BAAALgAECgcJBwAAAA==.',
['丶蓝']='丶蓝胖墩儿:BAAALgAFFAEJAQAAAA==.',
['丶超']='丶超哥:BAAALgAECgMJAgAAAA==.',
['丿尒']='丿尒猛:BAAALgAECgYJCAAAAA==.',
['乂乂']='乂乂软泥怪:BAAALgAECgYJBwAAAA==.',
['久远']='久远寺有珠灬:BAAALgAECgEJAQAAAA==.',
['乛乛']='乛乛软泥怪:BAAALgAECgIJAgAAAA==.',
['九五']='九五至尊:BAAALgADCgYJBgAAAA==.',
['九喜']='九喜:BAABLgAECn8WAAIPAAcJyhvBUAD/AQAPAAcJyhvBUAD/AQAAAA==.',
['九月']='九月星:BAAALgAECgYJCwAAAA==.',
['九歌']='九歌丶潮女妖:BAAALgAECgEJAQAAAA==.',
['乱妹']='乱妹骑:BAAALgAECgcJAQAAAA==.',
['了不']='了不德:BAAALgADCgQJBAAAAA==.',
['二法']='二法大人:BAAALgAFFAEJAQAAAA==.二法大腿武僧:BAABLgAFFH8FAAIQAAMJrRxoBgAVAQAQAAMJrRxoBgAVAQABLgAFFAMJBwAIALccAA==.二法的圣光:BAABLgAFFH8HAAIIAAMJtxwADgD3AAAIAAMJtxwADgD3AAAAAA==.',
['云暮']='云暮幻影:BAAALgADCgUJBQAAAA==.',
['云深']='云深望舒灬:BAAALgAECgEJAQAAAA==.',
['云霄']='云霄凌云:BAAALgAECgUJBQAAAA==.',
['云飞']='云飞扬兮:BAACLgAFFH8FAAIFAAMJ1QFkMgDZAAAFAAMJ1QFkMgDZAAAuAAQKfxcAAgUACAnbEqJuAPcBAAUACAnbEqJuAPcBAAAA.',
['五月']='五月辉哥:BAAALgAECgQJBAAAAA==.',
['京城']='京城小玩玩皮:BAAALgAECgYJDAAAAA==.',
['亲爱']='亲爱的交公粮:BAAALgAECgEJAQAAAA==.',
['人生']='人生几何:BAAALgAECgIJAgAAAA==.',
['人间']='人间散客丶:BAAALgAECgQJBQAAAA==.',
['以格']='以格约姆:BAAALgAFFAIJAwAAAA==.',
['仼子']='仼子归来:BAAALgAECgYJBgAAAA==.',
['伊奇']='伊奇:BAAALgAECgMJAwAAAA==.',
['伊賀']='伊賀幻:BAABLgAFFH8GAAIPAAMJKwqmSQCPAAAPAAMJKwqmSQCPAAAAAA==.',
['伍佰']='伍佰万整:BAAALgAECgEJAQAAAA==.',
['伟大']='伟大无需多言:BAAALgADCgEJAQAAAA==.',
['似水']='似水霸箭:BAAALgADCgMJAwAAAA==.',
['伽门']='伽门丨犇羴鱻:BAAALgAECgMJAwAAAA==.',
['何以']='何以解忧:BAAALgAFFAIJAgAAAA==.',
['你们']='你们的二哥:BAAALgAFFAIJAwAAAA==.',
['你倒']='你倒是出货啊:BAAALgAECgYJEwAAAA==.',
['你咋']='你咋这么嘚儿:BAAALgAECggJCAAAAA==.',
['你的']='你的一条蛇:BAACLgAFFH8IAAIRAAMJlx9OBQAmAQARAAMJlx9OBQAmAQAuAAQKfxoAAxEABwkNHEUGAKEBABEABwkNHEUGAKEBABAAAglKBvluAFUAAAAA.你的远方亲戚:BAAALgAECgEJAQAAAA==.',
['你瞅']='你瞅啥:BAABLgAECn8aAAIJAAcJphO6UQCwAQAJAAcJphO6UQCwAQAAAA==.',
['俏公']='俏公子:BAAALgAECgEJAQAAAA==.',
['信仰']='信仰元素:BAAALgAECgMJBQAAAA==.',
['借北']='借北風:BAABLgAECn8YAAIPAAkJkhtrFAABAwAPAAkJkhtrFAABAwAAAA==.',
['借東']='借東風:BAABLgAECn8XAAIPAAkJUxutIwCwAgAPAAkJUxutIwCwAgAAAA==.',
['倪小']='倪小叔:BAAALgAECgEJAQAAAA==.倪小姨:BAAALgAECgMJBAAAAA==.',
['假面']='假面女王:BAACLgAFFH8MAAIJAAUJHhPxCACZAQAJAAUJHhPxCACZAQAuAAQKfysAAwkACQklIrQHAE8DAAkACQklIrQHAE8DABIAAwlHC2NTAJsAAAAA.',
['催斯']='催斯特:BAAALgAFFAIJAgAAAA==.',
['傲娇']='傲娇小怪兽:BAABLgAFFH8HAAIDAAIJux3gFACzAAADAAIJux3gFACzAAAAAA==.',
['傻老']='傻老陈:BAAALgAECgYJCgAAAA==.',
['傻蛮']='傻蛮:BAAALgADCgEJAQAAAA==.',
['儿子']='儿子:BAAALgAECgEJAgAAAA==.',
['元气']='元气丸子:BAAALgAECgYJCQAAAA==.',
['光稜']='光稜:BAAALgAECgkJAwAAAA==.',
['光辉']='光辉萨:BAAALgAFFAIJAgAAAA==.',
['光铸']='光铸大领主:BAAALgAFFAEJAQAAAA==.',
['兜兜']='兜兜里有箭:BAAALgAECgMJAwAAAA==.',
['八品']='八品:BAAALgAECgEJAQAAAA==.',
['兰斯']='兰斯洛特:BAAALgAFFAQJBAAAAA==.',
['兼商']='兼商筱德:BAAALgAECgQJBAAAAA==.',
['内个']='内个:BAAALgAECgYJBgAAAA==.',
['再贱']='再贱就再见丶:BAAALgAECgUJBgAAAA==.',
['军团']='军团再再临:BAAALgAECgEJAQAAAA==.',
['冰丶']='冰丶榆:BAAALgAECgUJCAAAAA==.',
['冰无']='冰无名:BAAALgAECgUJEgAAAA==.',
['冰糖']='冰糖:BAAALgAECgcJBwAAAA==.',
['冰雪']='冰雪飞舞:BAAALgADCgUJBQAAAA==.',
['冷冰']='冷冰冰:BAAALgAECgEJAQAAAA==.',
['冷夜']='冷夜寒秋雨:BAAALgAECgEJAQAAAA==.',
['冷珺']='冷珺:BAAALgAFFAEJAgAAAA==.',
['冷艳']='冷艳小咪:BAAALgAFFAEJAQAAAA==.冷艳小妈:BAAALgAFFAMJBAAAAA==.',
['凤姐']='凤姐她竟然:BAAALgAECgEJAQAAAA==.',
['出水']='出水和琴:BAAALgADCgUJBQABLgAECggJEwAEAAAAAA==.',
['刑事']='刑事之虎阿达:BAAALgAECgkJEgAAAA==.',
['刘大']='刘大胆:BAAALgADCgEJAQAAAA==.',
['初生']='初生:BAAALgAECgEJAQAAAA==.',
['别烦']='别烦喵在蓄力:BAAALgAFFAIJAgAAAA==.',
['别玩']='别玩烂梗了:BAAALgADCgEJAQAAAA==.',
['到处']='到处打狗:BAABLgAFFH8IAAITAAMJQSRcAwA/AQATAAMJQSRcAwA/AQAAAA==.',
['动人']='动人心弦:BAAALgAECgUJBQAAAA==.',
['勇敢']='勇敢的萝卜:BAAALgAECgEJAgAAAA==.',
['勾心']='勾心豆角:BAABLgAECn8ZAAIFAAkJeiL+BwCJAwAFAAkJeiL+BwCJAwAAAA==.',
['勿丶']='勿丶靠近丶:BAAALgADCgYJBgAAAA==.',
['化桥']='化桥等回眸:BAAALgAECgYJBwAAAA==.',
['北冥']='北冥華:BAAALgAECggJEgAAAA==.',
['北府']='北府一鹤冥:BAAALgAECgMJAwAAAA==.',
['十亿']='十亿妇女的梦:BAAALgADCgEJAQAAAA==.',
['千恋']='千恋万花:BAAALgAFFAIJBAAAAA==.',
['千早']='千早爱音:BAAALgAECgcJAQAAAA==.',
['千秋']='千秋丶落月:BAAALgAECgQJBAAAAA==.',
['半玖']='半玖湾:BAABLgAECn8UAAIUAAcJ8CAzGABGAgAUAAcJ8CAzGABGAgAAAA==.',
['单眼']='单眼盲僧:BAAALgAECgEJAQAAAA==.',
['卖石']='卖石头的:BAAALgADCgIJAgAAAA==.',
['卡比']='卡比龙:BAAALgAECgEJAQAAAA==.',
['卫宫']='卫宫崎礼:BAAALgADCgcJBwABLgAFFAIJAgAEAAAAAA==.',
['印第']='印第安老山炮:BAAALgAECgYJDwAAAA==.',
['原叶']='原叶嚒嚒:BAAALgAECgEJAgAAAA==.',
['原谅']='原谅你了白鸽:BAAALgAFFAIJAgAAAA==.',
['叁只']='叁只黑:BAAALgAECgEJAQAAAA==.',
['又又']='又又:BAACLgAFFH8OAAITAAUJxw4hBgCNAQATAAUJxw4hBgCNAQAuAAQKfywAAxMACQknHuEHACwDABMACQknHuEHACwDABUAAgmFD+cvAHcAAAAA.',
['又双']='又双叒双又:BAAALgAECgYJBgAAAA==.',
['双马']='双马尾惠星:BAAALgAFFAEJAQAAAA==.',
['发财']='发财毛:BAACLgAFFH8GAAIKAAMJ4xheCwCtAAAKAAMJ4xheCwCtAAAuAAQKfyAAAgoACAkzILUGAOICAAoACAkzILUGAOICAAAA.',
['变熊']='变熊咬小鸡:BAAALgADCgUJBQAAAA==.',
['叨叨']='叨叨的德:BAAALgAECgIJAgAAAA==.叨叨的法丝:BAAALgAECgIJAgAAAA==.',
['只管']='只管叫我奶:BAAALgAECgIJAgAAAA==.',
['可爱']='可爱的括约肌:BAAALgAECgMJAwAAAA==.',
['叶落']='叶落之冬:BAAALgAECgYJBwAAAA==.',
['吃不']='吃不得辣张某:BAAALgADCgQJBAAAAA==.',
['吃肉']='吃肉的唐僧:BAAALgADCgIJAgAAAA==.',
['听求']='听求佛的牧師:BAABLgAECn8XAAMKAAcJzhV9JgC5AQAKAAcJzhV9JgC5AQAWAAYJRAnTNwAwAQABLgAECggJFAALAKMVAA==.',
['周美']='周美灵:BAACLgAFFH8HAAIBAAQJlwyCDQDxAAABAAQJlwyCDQDxAAAuAAQKfyYABAEACQkPIBwQALoCAAEACQm+HxwQALoCABcABwmnHXoDAMYBAAYABAkIDUJkAK8AAAAA.',
['呵呵']='呵呵言:BAAALgAECgYJBwAAAA==.',
['呼噜']='呼噜噜打饭团:BAAALgAECgMJBQAAAA==.呼噜小妞:BAAALgADCgUJCgAAAA==.',
['命运']='命运交响曲:BAAALgAECgYJBwAAAA==.',
['咕咕']='咕咕亲自然:BAAALgAECgUJBgAAAA==.',
['咪扑']='咪扑:BAAALgAECgEJAQAAAA==.',
['咸豆']='咸豆浆:BAAALgAECgMJAwAAAA==.',
['咿呀']='咿呀哈:BAACLgAFFH8GAAIJAAQJ/geiEADLAAAJAAQJ/geiEADLAAAuAAQKfyIAAwkACAnRHAIlAHQCAAkACAmPGwIlAHQCABIABgkAGNcuAFcBAAAA.',
['哈喽']='哈喽哈喽哦:BAAALgAECgYJAgAAAA==.',
['哈来']='哈来尼尔勇士:BAAALgADCgQJBAAAAA==.',
['哎呦']='哎呦哈:BAAALgAECgEJAQABLgAFFAgJIAAYAAAlAA==.',
['唐馨']='唐馨丶:BAAALgAECgIJAgAAAA==.',
['唤无']='唤无名:BAAALgAECgMJAwAAAA==.',
['啊嘟']='啊嘟嘟啊哒嘟:BAACLgAFFH8PAAIRAAQJSxNeDQAaAQARAAQJSxNeDQAaAQAuAAQKfxgAAhEACAnKHEUXAEwCABEACAnKHEUXAEwCAAAA.',
['啸影']='啸影:BAAALgAECgYJCwAAAA==.',
['喵了']='喵了个咪的:BAAALgAECgYJDAAAAA==.',
['喵星']='喵星人会爬树:BAABLgAFFH8FAAIBAAIJoxUkFgCtAAABAAIJoxUkFgCtAAAAAA==.',
['嘉禾']='嘉禾:BAAALgAECgEJAQAAAA==.',
['嘎嘎']='嘎嘎暴力:BAAALgAECgEJAQAAAA==.',
['嘟嘟']='嘟嘟嚕灬:BAAALgAECgIJAgAAAA==.',
['嘿丶']='嘿丶小护士:BAAALgADCgIJAgAAAA==.',
['嘿嘿']='嘿嘿的悟空:BAAALgADCgcJBwAAAA==.',
['噢嘪']='噢嘪丶大芊:BAAALgAECgEJAQAAAA==.',
['四颗']='四颗小虎牙:BAAALgADCgUJBQAAAA==.',
['团长']='团长不是引的:BAAALgAECgEJAwAAAA==.',
['囧果']='囧果果:BAACLgAFFH8MAAIPAAUJBxIxCACPAQAPAAUJBxIxCACPAQAuAAQKfx8AAg8ACAmyIsMRABEDAA8ACAmyIsMRABEDAAAA.',
['圞圝']='圞圝丶:BAAALgAECgEJAQAAAA==.',
['土特']='土特产:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光小兔:BAAALgAECgcJBwAAAA==.圣光小少女:BAAALgADCgEJAQAAAA==.圣光死亡骑士:BAAALgAECgEJAgAAAA==.圣光脏死你:BAAALgAECgQJBAAAAA==.圣光高人:BAAALgAECgEJAQAAAA==.',
['在水']='在水之舟:BAAALgAECgEJAQAAAA==.',
['坏西']='坏西琪:BAAALgAFFAIJBAAAAA==.',
['城楠']='城楠丶:BAAALgAECgEJAgAAAA==.',
['夏沫']='夏沫儿:BAAALgAFFAEJAgAAAA==.',
['夏無']='夏無神:BAAALgAECgMJAwAAAA==.',
['夕丶']='夕丶洛:BAAALgAECgYJCgAAAA==.',
['多喝']='多喝热氺:BAAALgAECgkJCAAAAA==.',
['夜切']='夜切:BAAALgAECgIJAgAAAA==.',
['夜墓']='夜墓亡法:BAAALgAECgkJDQAAAA==.',
['夜色']='夜色名咏士:BAAALgAECgEJAQAAAA==.夜色微蓝:BAAALgAECgMJAwAAAA==.',
['夜魇']='夜魇:BAAALgAECgIJAgAAAA==.',
['夜魔']='夜魔侠:BAAALgAECgEJAQAAAA==.',
['大传']='大传送门:BAACLgAFFH8QAAMLAAUJ6CYsAQA+AgALAAUJ6CYsAQA+AgAMAAEJWiMtEABnAAAuAAQKfycABAsACQmwJuYCAJQDAAsACAmwJuYCAJQDAAwAAwmpJb0gAE4BAA0AAQkAACsmAFkAAAAA.',
['大啵']='大啵啵来嗨了:BAAALgAFFAEJAQAAAA==.',
['大圣']='大圣光忽悠:BAAALgAECgYJBgAAAA==.',
['大奥']='大奥奥:BAAALgAECgEJAgAAAA==.',
['大术']='大术娃:BAAALgADCgQJBAAAAA==.',
['大皖']='大皖牛肉面:BAAALgAECgkJCQAAAA==.',
['大耳']='大耳朵波波:BAAALgAECgQJBAAAAA==.',
['大胃']='大胃二十五王:BAAALgAECgYJCQAAAA==.',
['大莽']='大莽娃二号:BAAALgAECgMJAwAAAA==.',
['大角']='大角角牛牛:BAAALgAECgYJBgAAAA==.',
['大长']='大长腿呀:BAAALgAFFAEJAQAAAA==.',
['大闪']='大闪电链:BAAALgAECggJDAAAAA==.',
['大闹']='大闹闹:BAAALgAECgEJAQAAAA==.',
['天剑']='天剑星阮小二:BAABLgAFFH8IAAISAAQJPAc2BAA3AQASAAQJPAc2BAA3AQAAAA==.',
['天命']='天命难违:BAAALgAFFAEJAQAAAA==.',
['天天']='天天吃素:BAABLgAECn8cAAIZAAcJzB4fFgBeAgAZAAcJzB4fFgBeAgAAAA==.',
['天恒']='天恒羽:BAAALgADCgYJBgAAAA==.',
['天浩']='天浩龙风:BAAALgAECgMJBAAAAA==.',
['天照']='天照:BAAALgAECgIJAgAAAA==.',
['天秀']='天秀蔷薇:BAAALgAECgkJDAAAAA==.',
['天黑']='天黑将夜:BAACLgAFFH8LAAMaAAQJoxENAgD4AAAaAAQJNw4NAgD4AAAbAAEJIhZHLQBaAAAuAAQKfyEAAxoABwnjHs8GAHcCABoABwnAHs8GAHcCABsABAnlH7EjABoBAAAA.',
['太过']='太过懵懂:BAAALgAECgEJAgAAAA==.',
['奔跑']='奔跑的五花喽:BAAALgAECgEJAgAAAA==.',
['奠丄']='奠丄百億冥幣:BAAALgAECgQJBQAAAA==.',
['奥丽']='奥丽薇丶:BAABLgAFFH8IAAIGAAQJaxH7DgA7AQAGAAQJaxH7DgA7AQAAAA==.',
['奥蕯']='奥蕯鲁:BAAALgAECgEJAQAAAA==.',
['好喝']='好喝到咩扑茶:BAAALgAECgMJAwAAAA==.',
['好汉']='好汉饶命:BAAALgADCgMJAwAAAA==.',
['妖魅']='妖魅迷惑:BAAALgADCgYJBgAAAA==.',
['威风']='威风糖糖丶:BAAALgAECgMJAwAAAA==.',
['娃娃']='娃娃的鞋子:BAAALgAECgMJAwAAAA==.',
['婣尐']='婣尐德征:BAAALgAECgUJBwAAAA==.',
['孤星']='孤星雨:BAAALgAFFAIJAwAAAA==.',
['守护']='守护者魔鬼龍:BAAALgAECgQJBgAAAA==.',
['安否']='安否:BAAALgADCgcJBwAAAA==.',
['安和']='安和昴:BAAALgAECgIJAgAAAA==.',
['安娜']='安娜宝宝:BAAALgAECgMJAwAAAA==.',
['安德']='安德蘿妮:BAAALgAECgkJBgAAAA==.',
['宜兴']='宜兴熊猫凝:BAAALgAECgIJAgAAAA==.',
['小叔']='小叔叔:BAAALgADCgQJBAAAAA==.',
['小台']='小台监护人:BAAALgAECgEJAQABLgAECggJFAALAKMVAA==.',
['小小']='小小冰:BAAALgAECgMJAwAAAA==.小小鞋子:BAAALgAECgMJAwAAAA==.',
['小徳']='小徳:BAAALgAECgEJAQAAAA==.',
['小智']='小智:BAAALgAECggJEwAAAA==.',
['小树']='小树喵:BAAALgAECgUJCgAAAA==.',
['小棉']='小棉花丶:BAAALgAECgYJBwAAAA==.',
['小猫']='小猫兮兮:BAAALgADCgEJAQAAAA==.',
['小福']='小福妮:BAAALgAECgYJBgAAAA==.',
['小萨']='小萨飞天真君:BAAALgAECgEJAQAAAA==.',
['小西']='小西琪:BAACLgAFFH8LAAIUAAQJEAouCgBPAQAUAAQJEAouCgBPAQAuAAQKfxYAAhQACAmNFwcWAF4CABQACAmNFwcWAF4CAAAA.',
['小钕']='小钕嬣:BAAALgAECgEJAQAAAA==.',
['小风']='小风监护人:BAAALgAECgcJCgAAAA==.',
['小鱼']='小鱼吐泡泡:BAAALgAECgYJDQAAAA==.',
['小鵬']='小鵬有:BAAALgADCgEJAQAAAA==.',
['小鸽']='小鸽:BAAALgAFFAEJAQAAAA==.',
['尧舜']='尧舜千钟:BAABLgAFFH8GAAIRAAUJmgVpCQBAAQARAAUJmgVpCQBAAQAAAA==.',
['尹娜']='尹娜的真言:BAAALgAECggJEwAAAA==.',
['屯里']='屯里一枝花:BAAALgAECgEJAQABLgAFFAIJAwAEAAAAAA==.',
['峥澄']='峥澄灬:BAAALgAECgMJAgAAAA==.',
['工藤']='工藤灬新一:BAACLgAFFH8EAAIBAAMJuQvSDAD7AAABAAMJuQvSDAD7AAAuAAQKfyIABAEACAkMG0cHAPUBAAEACAlbGUcHAPUBABcABwniFfYQALMBAAYAAgnqFN5xAHYAAAAA.',
['左半']='左半边惡魔:BAAALgAFFAEJAQAAAA==.',
['巴巴']='巴巴耶嘉:BAABLgAFFH8FAAIPAAMJ9Bk8VQBOAAAPAAMJ9Bk8VQBOAAAAAA==.',
['巴比']='巴比伦尼亚:BAAALgAECgQJBAAAAA==.',
['布拉']='布拉修:BAAALgADCgYJBgAAAA==.',
['布洛']='布洛克斯:BAABLgAECn8VAAMTAAcJ3gqKTQBwAQATAAcJ3gqKTQBwAQAVAAUJWgg0IADrAAAAAA==.',
['布魯']='布魯斯韋恩:BAAALgAECgMJAwAAAA==.',
['希尔']='希尔瓦娜凘:BAAALgAECgQJBQAAAA==.',
['帝王']='帝王绿:BAAALgAECgkJAQAAAA==.',
['幻影']='幻影术魔:BAAALgAECgcJEAABLgAFFAQJCAAcANACAA==.幻影龙神:BAACLgAFFH8IAAMcAAQJ0AIhBQDOAAAcAAMJxgIhBQDOAAAYAAMJhgLTDgCDAAAuAAQKfyAAAxwACAm1G1MGAJACABwACAnGGlMGAJACABgACAm6E+0FAJ8BAAAA.',
['广收']='广收座下童子:BAAALgAECgEJAQAAAA==.',
['库洛']='库洛米吖:BAAALgAECgUJBQAAAA==.',
['开心']='开心树朋友:BAAALgAFFAEJAQAAAA==.',
['当家']='当家落寞:BAAALgAFFAIJAgAAAA==.',
['彼岸']='彼岸:BAAALgAECgUJBQAAAA==.',
['往事']='往事如疯:BAABLgAFFH8HAAIDAAMJGRH0DwDoAAADAAMJGRH0DwDoAAAAAA==.',
['御箭']='御箭丨寒晶:BAAALgAFFAEJAQAAAA==.',
['微微']='微微丶冰:BAAALgADCgEJAQAAAA==.',
['微疯']='微疯的聋:BAABLgAECn8UAAQYAAcJbQsCLgBSAQAYAAcJbQsCLgBSAQAdAAQJ+ghRNgC5AAAcAAQJXgXVLgChAAAAAA==.',
['微笑']='微笑丶冰:BAAALgADCgEJAQAAAA==.微笑有毒:BAAALgADCgUJBQAAAA==.',
['德过']='德过且过:BAACLgAFFH8OAAMeAAUJhA4dBgB3AQAeAAUJhA4dBgB3AQAZAAIJXwYAAAAAAAAuAAQKfy8AAx4ACQlWHMIPALoCAB4ACQlWHMIPALoCABkABgnIH7odABICAAAA.',
['心有']='心有虞姬:BAABLgAFFH8GAAIbAAMJtRLGFAADAQAbAAMJtRLGFAADAQAAAA==.',
['忘掉']='忘掉种过的花:BAAALgADCgEJAQAAAA==.',
['快樂']='快樂的雯雯醬:BAACLgAFFH8MAAIdAAQJjyOhAQCmAQAdAAQJjyOhAQCmAQAuAAQKfxkAAh0ACAmyIJgFAO8CAB0ACAmyIJgFAO8CAAAA.',
['怒风']='怒风归来:BAAALgAECgMJAwAAAA==.',
['怖拉']='怖拉修修:BAAALgAECgMJAwAAAA==.',
['悔过']='悔过诗丶:BAAALgAECgYJEgAAAA==.',
['悻悻']='悻悻软泥家族:BAAALgAFFAIJAgAAAA==.',
['情绪']='情绪零碎:BAACLgAFFH8KAAIFAAMJfyMFDgAeAQAFAAMJfyMFDgAeAQAuAAQKfycAAgUACAn3JBUUADADAAUACAn3JBUUADADAAAA.',
['惩戒']='惩戒大魔王:BAAALgAECgYJBwAAAA==.',
['愤怒']='愤怒的三胖:BAAALgAECgUJCAABLgAECgcJDQAEAAAAAA==.',
['愿与']='愿与愁:BAABLgAFFH8GAAIfAAQJ2hugBwBiAQAfAAQJ2hugBwBiAQAAAA==.',
['慕兮']='慕兮:BAAALgAECgYJCQAAAA==.',
['成佶']='成佶思汗:BAAALgAECgYJDAAAAA==.',
['我总']='我总有一样得:BAABLgAFFH8JAAIFAAMJxwyRMQDnAAAFAAMJxwyRMQDnAAAAAA==.',
['我是']='我是新手啊丶:BAAALgAECgYJCwAAAA==.我是牛逼德灬:BAAALgAFFAIJAwAAAA==.',
['我本']='我本叛逆:BAAALgADCgEJAQAAAA==.',
['我爱']='我爱吃火锅丶:BAAALgAECggJDwABLgAFFAgJIAAYAAAlAA==.',
['我硬']='我硬的一批:BAAALgAECgUJBQAAAA==.',
['我身']='我身无形:BAAALgAECgEJAgAAAA==.',
['我还']='我还未离去:BAAALgAFFAIJBAAAAA==.',
['戒灬']='戒灬指:BAAALgAECgYJDAAAAA==.',
['扑扑']='扑扑:BAAALgAFFAEJAQAAAA==.',
['打不']='打不过就丶病:BAAALgAFFAIJAgAAAA==.打不过就丶退:BAAALgAFFAIJAgABLgAFFAIJAgAEAAAAAA==.',
['打呼']='打呼噜:BAAALgADCgUJBQAAAA==.',
['打酱']='打酱油的:BAAALgAECgcJCAAAAA==.打酱油的胖胖:BAAALgAECgcJCgAAAA==.',
['扭葫']='扭葫芦宝宝:BAACLgAFFH8GAAILAAMJwweIJgDlAAALAAMJwweIJgDlAAAuAAQKfx4AAwsACAkxG9Y5ACQCAAsABwkxG9Y5ACQCAAwAAwkuDDxBALAAAAAA.',
['抓不']='抓不到宝宝:BAAALgAECgIJAgAAAA==.',
['折风']='折风渡夜:BAAALgAFFAIJAwABLgAFFAQJBQALAD4fAA==.',
['拉糖']='拉糖的阿昆达:BAAALgAFFAIJBAAAAA==.',
['拳一']='拳一:BAAALgAECgQJBAAAAA==.',
['拳打']='拳打高富帅:BAAALgAECgEJAQAAAA==.',
['拿吕']='拿吕布擦一下:BAAALgAECgQJBwAAAA==.',
['拿坡']='拿坡里黄:BAAALgAECgQJBAAAAA==.',
['捌氪']='捌氪彩色电视:BAAALgADCgYJBgAAAA==.',
['捷拉']='捷拉奥拉:BAAALgAECgEJAgAAAA==.',
['探囊']='探囊取物丶:BAAALgAECgIJAgAAAA==.',
['攘攘']='攘攘熙熙:BAAALgAFFAEJAQAAAA==.',
['救人']='救人丶要紧:BAABLgAECn8XAAIPAAcJgBWQXgDXAQAPAAcJgBWQXgDXAQAAAA==.',
['新子']='新子憧:BAAALgAECgEJAQAAAA==.',
['无聊']='无聊的猪哥:BAAALgAFFAQJBAABLgAFFAUJBQAPADYhAA==.',
['日落']='日落大道:BAAALgAFFAIJAwAAAA==.',
['时间']='时间在燃烧:BAAALgAECgEJAgAAAA==.',
['旺仔']='旺仔牛逼糖:BAAALgAECgkJDAAAAA==.',
['明明']='明明爱阿鲁巴:BAAALgAECgEJAgAAAA==.',
['明月']='明月别枝惊鹊:BAAALgAECgUJBwAAAA==.明月应无恙:BAAALgAECgEJAgAAAA==.',
['易十']='易十三:BAAALgAECgcJEAAAAA==.',
['昕晨']='昕晨的小迷弟:BAAALgAECgEJAQAAAA==.',
['星冥']='星冥:BAAALgAECgQJBgAAAA==.',
['星术']='星术丶:BAAALgADCgYJBgAAAA==.',
['星野']='星野龙之介:BAAALgAECgUJCQAAAA==.',
['是念']='是念鲸呀:BAAALgAECgMJAgAAAA==.',
['晓丶']='晓丶骑:BAAALgAECgYJCwAAAA==.',
['晓慕']='晓慕丶晨曦:BAAALgAECgYJDQAAAA==.',
['晓风']='晓风灿月:BAAALgAFFAEJAQAAAA==.',
['晚泠']='晚泠西:BAAALgAECgIJAwAAAA==.',
['晴晴']='晴晴:BAAALgAECgkJCQAAAA==.',
['暖小']='暖小喵:BAAALgAECgQJBAAAAA==.',
['暗夜']='暗夜小恶魔:BAAALgAECgcJBwAAAA==.暗夜苍穹:BAAALgAECgUJBQAAAA==.',
['暗影']='暗影杀机:BAAALgAFFAQJBAAAAA==.暗影逐风:BAAALgAECgIJAgAAAA==.',
['暴力']='暴力嗷嗷:BAAALgAECgQJBgAAAA==.暴力治疗:BAAALgAECgYJCAAAAA==.',
['最初']='最初的风:BAAALgADCgcJBwAAAA==.',
['最多']='最多喝二两:BAAALgADCgYJBgAAAA==.',
['月之']='月之黑羽:BAAALgAFFAIJAgAAAA==.',
['月光']='月光下的温柔:BAAALgAECgIJAgAAAA==.月光之暖:BAAALgADCgYJBAAAAA==.',
['月浅']='月浅汐:BAAALgAECgYJBwAAAA==.',
['月稀']='月稀:BAABLgAECn8UAAMKAAYJvQ03QAA4AQAKAAYJvQ03QAA4AQAfAAQJwgX1PwCvAAABLgAFFAMJBQAGANENAA==.',
['月糊']='月糊:BAABLgAFFH8FAAICAAMJNAv4CgCSAAACAAMJNAv4CgCSAAAAAA==.',
['有梦']='有梦想的妹子:BAAALgAECgEJAQAAAA==.',
['有琴']='有琴浅浅:BAAALgAECgYJBgAAAA==.',
['朝雲']='朝雲暮雨:BAAALgAECgMJAwAAAA==.朝雲行雨:BAAALgAECgQJBAAAAA==.',
['术西']='术西琪:BAAALgAECgEJAQAAAA==.',
['朴腻']='朴腻墨:BAABLgAFFH8JAAIFAAQJzghbLQABAQAFAAQJzghbLQABAQAAAA==.',
['李琪']='李琪薇:BAAALgAECgYJBwAAAA==.',
['李道']='李道长:BAAALgAECgYJBwAAAA==.',
['杏仁']='杏仁牛奶:BAAALgADCgUJCQAAAA==.',
['杰森']='杰森斯坦昇:BAAALgAECgIJAgAAAA==.',
['松阪']='松阪梅:BAAALgAECgUJBgAAAA==.',
['板上']='板上钉钉丶:BAAALgAECgQJBgAAAA==.',
['林下']='林下风致:BAAALgAECgYJDwABLgAFFAMJCgAFAH8jAA==.',
['果果']='果果粑粑:BAAALgAECgEJAgAAAA==.',
['柒个']='柒个术湿:BAAALgAECgEJAgAAAA==.',
['柠檬']='柠檬味的夏天:BAACLgAFFH8IAAIfAAMJIgo7DwDbAAAfAAMJIgo7DwDbAAAuAAQKfxkAAx8ACAktFLAaAMIBAB8ABwmQE7AaAMIBAAoABgnQECc6AFIBAAAA.',
['柳梦']='柳梦丽:BAAALgAECgUJCQAAAA==.',
['格斗']='格斗家氧氧:BAAALgAECgcJBgAAAA==.',
['梁山']='梁山泊:BAAALgAECgUJBgAAAA==.',
['梅西']='梅西天生要墙:BAAALgADCgUJBQAAAA==.',
['梧凰']='梧凰:BAAALgADCgcJBwAAAA==.',
['棒棒']='棒棒神爽歪歪:BAAALgAFFAEJAQAAAA==.',
['椰子']='椰子鸡:BAACLgAFFH8IAAIBAAMJ+BXLFgCrAAABAAMJ+BXLFgCrAAAuAAQKfycAAwEACAnaIO0BAJcCAAEACAnaIO0BAJcCAAYAAwlPFz1gAL8AAAAA.',
['楠楠']='楠楠真的困:BAAALgAFFAMJAwAAAA==.',
['橘子']='橘子小柠檬:BAACLgAFFH8PAAIKAAQJZyMgBABIAQAKAAQJZyMgBABIAQAuAAQKfz8AAwoACQmbJNsAAIoDAAoACQmbJNsAAIoDAB8AAgl5G0JDAJsAAAAA.',
['橘橘']='橘橘小檬檬:BAAALgAFFAEJAQABLgAFFAQJDwAKAGcjAA==.',
['正式']='正式服的莽娃:BAAALgAECgYJDgAAAA==.',
['武拳']='武拳灬无风:BAAALgAECgEJAgAAAA==.',
['歪圣']='歪圣骑:BAAALgADCgEJAQAAAA==.',
['死战']='死战乄本风流:BAAALgAECgQJBwAAAA==.',
['死骑']='死骑女王:BAAALgAFFAEJAQAAAA==.',
['毛豆']='毛豆拔唐僧:BAAALgAECgIJAwAAAA==.',
['水果']='水果的聖光:BAAALgADCgMJAwAAAA==.',
['永夜']='永夜之语:BAABLgAFFH8HAAMLAAcJ9RQHAQDAAQALAAYJWBMHAQDAAQAMAAEJBh3aAgBpAAAAAA==.',
['永远']='永远的利物浦:BAAALgAECgUJBQAAAA==.',
['江婉']='江婉盈:BAAALgAECgEJAQAAAA==.',
['汪凝']='汪凝:BAAALgAECgcJEAAAAA==.',
['沙壁']='沙壁暴雪:BAAALgAECgYJDwAAAA==.',
['没事']='没事走俩步:BAABLgAECn8TAAMLAAkJOCALEAD5AgALAAkJOCALEAD5AgAMAAEJAABZgQAIAAAAAA==.',
['没瞎']='没瞎的盲僧:BAAALgADCgEJAQAAAA==.',
['法修']='法修仙哒:BAAALgAFFAIJAwAAAA==.',
['法学']='法学大恶魔:BAAALgAFFAIJAgABLgAFFAMJBwAIALccAA==.',
['洋芋']='洋芋丝丝:BAAALgAECgYJCAAAAA==.',
['洒满']='洒满满:BAAALgAFFAEJAQAAAA==.',
['洛丹']='洛丹伦之魂:BAAALgAECgUJBQAAAA==.',
['洛拉']='洛拉希尔:BAAALgADCgYJBgAAAA==.',
['派克']='派克诺坦:BAAALgAFFAIJAwAAAA==.',
['流氓']='流氓丶子:BAAALgAECgcJCgAAAA==.',
['流颜']='流颜七号:BAAALgAECgYJBgAAAA==.流颜九号:BAABLgAFFH8IAAILAAQJ5CBsEgBTAQALAAQJ5CBsEgBTAQAAAA==.',
['海月']='海月映残夜:BAAALgAFFAEJAgAAAA==.',
['混乱']='混乱美少女:BAAALgADCgYJBgAAAA==.',
['清云']='清云歌丶:BAAALgAECgEJAQAAAA==.',
['清寒']='清寒照萧瑟:BAACLgAFFH8GAAIFAAIJ+hqiGAC1AAAFAAIJ+hqiGAC1AAAuAAQKfycAAgUACAkpI6kGAEICAAUACAkpI6kGAEICAAAA.',
['湛蓝']='湛蓝灬残影:BAAALgADCgYJBgAAAA==.湛蓝灬毒狼:BAAALgADCgEJAQAAAA==.',
['漠漠']='漠漠猫:BAABLgAFFH8HAAIJAAMJqAsZHwDeAAAJAAMJqAsZHwDeAAAAAA==.',
['澄子']='澄子:BAAALgAECgIJAgAAAA==.',
['澄灬']='澄灬子:BAAALgAECgEJAQAAAA==.',
['澳特']='澳特曼使者:BAAALgAECgYJCgAAAA==.',
['灬天']='灬天赋帝:BAAALgAECgcJBwAAAA==.',
['灬威']='灬威震天:BAAALgADCgQJBAAAAA==.',
['灭绝']='灭绝师太:BAAALgAECgEJAwAAAA==.',
['灵魂']='灵魂高歌:BAABLgAECn8aAAIFAAYJiiMrRwBiAgAFAAYJiiMrRwBiAgAAAA==.',
['炎爆']='炎爆炸飞机:BAAALgADCgMJAwAAAA==.',
['炒面']='炒面骚年:BAAALgAECgYJBgAAAA==.',
['炫酷']='炫酷的不行:BAAALgAECgYJAgAAAA==.',
['炼狱']='炼狱敕令:BAACLgAFFH8PAAICAAUJ5xNOBwBlAQACAAUJ5xNOBwBlAQAuAAQKfyIAAwIACQkFIkADAHEDAAIACQkFIkADAHEDAAMAAQk4CVqaADkAAAAA.',
['烮丶']='烮丶崆:BAAALgAECgYJCAAAAA==.烮丶火:BAACLgAFFH8IAAIgAAMJaxBDCADVAAAgAAMJaxBDCADVAAAuAAQKfyoAAiAACAk4GUwMAEcCACAACAk4GUwMAEcCAAAA.',
['烮风']='烮风:BAAALgAFFAEJAQAAAA==.',
['煙雨']='煙雨丶傾城:BAAALgAECgEJAwABLgAECgcJCgAEAAAAAA==.',
['爱佬']='爱佬虎油:BAAALgAFFAQJBAAAAA==.',
['爱尔']='爱尔伯屌丝:BAAALgADCgIJAgAAAA==.爱尔伯蕾丝:BAACLgAFFH8QAAMKAAUJRySZAAD9AQAKAAUJRySZAAD9AQAfAAIJnw4BFACWAAAuAAQKfy8AAwoACQlJJlkAAMMDAAoACQlJJlkAAMMDAB8ACAl1HucHAMICAAAA.',
['牛毙']='牛毙暴叻:BAAALgADCgIJAgAAAA==.',
['牛牛']='牛牛:BAABLgAECn8VAAMZAAYJXQsnSQAHAQAZAAYJXQsnSQAHAQAeAAUJ6wHZpAB/AAAAAA==.',
['牛闪']='牛闪闪:BAAALgAECgEJAQAAAA==.',
['物是']='物是人尽非:BAAALgAECgEJAQAAAA==.',
['狂野']='狂野曦:BAABLgAFFH8GAAIRAAMJWBYsHwB9AAARAAMJWBYsHwB9AAAAAA==.',
['狐狸']='狐狸会放电:BAAALgAECgQJBQAAAA==.',
['狐迪']='狐迪凯:BAAALgAECgMJAwAAAA==.',
['狐颜']='狐颜烈:BAAALgAECgcJEQAAAA==.',
['猫毛']='猫毛拌饭:BAAALgAFFAMJBAAAAA==.',
['猫猫']='猫猫偷腥:BAAALgADCgUJBQAAAA==.',
['猫能']='猫能四:BAAALgAECgQJBAABLgAECgcJCgAEAAAAAA==.',
['玄天']='玄天皓月:BAAALgAECgEJAQAAAA==.',
['玉高']='玉高惊魂:BAAALgAFFAMJBAAAAA==.',
['王牌']='王牌律师乐天:BAACLgAFFH8JAAIFAAUJtwwYIgA2AQAFAAUJtwwYIgA2AQAuAAQKfyYAAgUACQkPINADAIQCAAUACQkPINADAIQCAAAA.',
['珍塔']='珍塔玛莎:BAAALgAECgYJBgAAAA==.',
['理解']='理解不了:BAAALgAECgcJDQAAAA==.',
['瑞搓']='瑞搓比利:BAAALgAFFAIJAwAAAA==.',
['璀璨']='璀璨的烟火:BAACLgAFFH8KAAIaAAQJ1xHEAgDRAAAaAAQJ1xHEAgDRAAAuAAQKfx8AAhoACQnZFkYHAGwCABoACQnZFkYHAGwCAAAA.',
['留香']='留香:BAAALgADCgYJBgAAAA==.',
['疍疍']='疍疍的忧伤:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂的小湛士:BAAALgAECgYJAQAAAA==.疯狂野性:BAAALgAFFAMJAwAAAA==.',
['疯花']='疯花血夜:BAAALgADCgEJAQAAAA==.疯花血夜丶:BAABLgAECn8bAAIbAAYJ2hv4VQDgAQAbAAYJ2hv4VQDgAQAAAA==.',
['瘋狂']='瘋狂的骨頭:BAAALgAFFAQJBAAAAA==.',
['白白']='白白嘿:BAAALgAECgUJBgAAAA==.',
['皆你']='皆你:BAAALgAECgYJCwAAAA==.',
['皮皮']='皮皮骑士:BAAALgAECgMJAwAAAA==.',
['真皮']='真皮獸人:BAAALgADCgUJBQAAAA==.',
['矛盾']='矛盾螺旋:BAAALgAECgkJEwAAAA==.',
['知北']='知北游灬柠真:BAAALgADCgcJBwAAAA==.',
['破天']='破天碎梦:BAAALgAECgEJAQAAAA==.',
['碎翼']='碎翼天使:BAAALgAECggJDwAAAA==.',
['祈灬']='祈灬福:BAAALgAECgQJBQABLgAECgYJGgAFAIojAA==.',
['祎儿']='祎儿:BAAALgAECgQJBQAAAA==.',
['神奇']='神奇不在:BAAALgAECgEJAQAAAA==.',
['神葬']='神葬星辰:BAAALgAECgEJAQAAAA==.',
['祸津']='祸津神:BAAALgAECgcJBgAAAA==.',
['秋梦']='秋梦寒:BAAALgAECgQJBAAAAA==.',
['秦淮']='秦淮情深深:BAAALgADCgIJAgAAAA==.',
['究极']='究极青眼白龙:BAAALgAFFAQJBAAAAA==.',
['空北']='空北:BAAALgAECgYJBgAAAA==.',
['空心']='空心花少丶:BAABLgAFFH8FAAILAAQJPh+dHQBsAAALAAQJPh+dHQBsAAAAAA==.',
['空气']='空气太敏感:BAAALgAECgIJAgAAAA==.',
['笑容']='笑容不是为她:BAAALgAECgEJAQAAAA==.',
['笨小']='笨小猪:BAACLgAFFH8WAAIFAAYJSRs9BAAtAgAFAAYJSRs9BAAtAgAuAAQKfyMAAgUACAlvJrYIAIEDAAUACAlvJrYIAIEDAAAA.',
['等一']='等一刻儿:BAAALgAECgQJBAAAAA==.',
['箩卜']='箩卜滴箩卜:BAAALgAECgQJCgAAAA==.',
['粉嘟']='粉嘟嘟:BAAALgAECgEJAQABLgAECgYJGgAFAIojAA==.',
['粉色']='粉色小蹄子:BAAALgAECgEJAQAAAA==.',
['粑粑']='粑粑是谁:BAAALgAECgMJAwAAAA==.',
['糖宝']='糖宝:BAAALgAECgYJCwAAAA==.',
['糜霓']='糜霓:BAABLgAFFH8GAAILAAIJCAV1PgCSAAALAAIJCAV1PgCSAAAAAA==.',
['糜麑']='糜麑:BAAALgAFFAIJAgAAAA==.',
['索逸']='索逸:BAAALgADCgYJBgAAAA==.',
['紫丨']='紫丨星辰:BAAALgAECgEJAQAAAA==.',
['红旗']='红旗牌壹号:BAAALgAECgYJBgAAAA==.',
['红美']='红美铃:BAAALgAFFAEJAQABLgAFFAQJBAAEAAAAAA==.',
['纯洁']='纯洁的老兵:BAACLgAFFH8FAAIPAAIJkQWKSACSAAAPAAIJkQWKSACSAAAuAAQKfxoAAg8ACAkTE0sOAKgBAA8ACAkTE0sOAKgBAAAA.',
['纷争']='纷争:BAAALgAECgkJCQAAAA==.',
['细雨']='细雨:BAACLgAFFH8QAAIOAAUJcSTSAQASAgAOAAUJcSTSAQASAgAuAAQKfy8AAg4ACQniJOMAAK0DAA4ACQniJOMAAK0DAAAA.',
['织雾']='织雾猪:BAAALgADCgcJBwAAAA==.',
['绝叅']='绝叅:BAAALgADCgEJAQAAAA==.',
['绿绿']='绿绿箭箭:BAACLgAFFH8LAAIIAAUJOhL3BACPAQAIAAUJOhL3BACPAQAuAAQKfx4AAggACAl7FBglAPwBAAgACAl7FBglAPwBAAAA.',
['网爖']='网爖灬圣灵:BAAALgADCgcJBwABLgAECgYJGgAFAIojAA==.',
['罪爷']='罪爷:BAAALgAECgUJBQAAAA==.',
['美杜']='美杜莎之瞳:BAAALgADCgEJAQAAAA==.',
['翔子']='翔子来了:BAAALgAECgUJCAAAAA==.',
['老兵']='老兵不死灬:BAAALgADCgUJBQAAAA==.',
['老夫']='老夫就是白:BAAALgADCgcJBwAAAA==.',
['老子']='老子有点颠:BAAALgADCgYJBgABLgAECgYJDAAEAAAAAA==.',
['老暴']='老暴力:BAAALgAECgYJCwAAAA==.',
['老色']='老色劈来咯:BAAALgAECgEJAgAAAA==.',
['耶巴']='耶巴碟:BAAALgAECgEJAQAAAA==.',
['耶格']='耶格牧:BAAALgAECgEJAQAAAA==.耶格骑:BAACLgAFFH8QAAMIAAUJlRxlBwBdAQAIAAQJOBplBwBdAQAbAAUJyR63DgA0AQAuAAQKfx4AAxsACQnAI64JAEMDABsACAnyJK4JAEMDAAgACQlfIF4DAD0DAAAA.',
['肆意']='肆意妄为:BAAALgAECgEJAQAAAA==.',
['肥子']='肥子:BAAALgADCgUJBQAAAA==.',
['胖卵']='胖卵郑猪奇:BAAALgAECgQJBAAAAA==.',
['能狗']='能狗哈一口:BAAALgAECgQJAgAAAA==.',
['脏三']='脏三疯:BAAALgAECgEJAQAAAA==.',
['脏脏']='脏脏黑巧:BAACLgAFFH8OAAMPAAUJFBwBFABSAQAPAAQJFBwBFABSAQAhAAEJAAD8GwApAAAuAAQKfy4AAg8ACQmmJXMBAM0DAA8ACQmmJXMBAM0DAAAA.',
['脱兔']='脱兔:BAAALgAECgkJAQAAAA==.',
['脸刷']='脸刷刷白:BAAALgADCgIJAgAAAA==.',
['自由']='自由镇镇长:BAAALgAECgQJBAAAAA==.',
['臭弟']='臭弟弟二法:BAABLgAFFH8FAAIPAAIJFB84MQDGAAAPAAIJFB84MQDGAAAAAA==.',
['致以']='致以无瑕之人:BAACLgAFFH8QAAIZAAUJ3yXUAQD9AQAZAAUJ3yXUAQD9AQAuAAQKfy8AAhkACQmaJZwAAOUDABkACQmaJZwAAOUDAAAA.',
['致命']='致命华尔兹:BAAALgAECgEJAQAAAA==.',
['艾瑞']='艾瑞莉雅:BAAALgAECgYJCgAAAA==.',
['芝士']='芝士奶盖:BAABLgAFFH8IAAIFAAMJwQosLgD+AAAFAAMJwQosLgD+AAABLgAFFAQJBAAEAAAAAA==.',
['芭拉']='芭拉啪啪帕:BAAALgAECgEJAQAAAA==.',
['花开']='花开成雪:BAAALgAFFAQJBAAAAA==.花开见我:BAAALgAFFAIJAgAAAA==.',
['芳华']='芳华:BAAALgAECgMJAwAAAA==.',
['苗儿']='苗儿巴:BAABLgAFFH8HAAICAAMJ2hInBgD5AAACAAMJ2hInBgD5AAAAAA==.',
['茫然']='茫然骑士:BAAALgADCgIJAgAAAA==.',
['茱瑛']='茱瑛苔:BAAALgAECgEJAgAAAA==.',
['荒野']='荒野大朴客:BAAALgAFFAQJAwAAAA==.',
['荔枝']='荔枝:BAAALgAECgYJBgAAAA==.',
['药大']='药大爷突然:BAAALgAECgEJAQAAAA==.',
['药娘']='药娘刘二萌:BAAALgAECgYJBgAAAA==.',
['莫得']='莫得仇恨:BAAALgAFFAIJAwAAAA==.',
['莫拉']='莫拉格巴尔:BAAALgAECgYJDgAAAA==.',
['菠萝']='菠萝:BAAALgADCgUJBQAAAA==.菠萝牛角包:BAAALgAECgUJDgAAAA==.',
['萌了']='萌了吧唧:BAACLgAFFH8GAAIKAAIJ6g4xDgCMAAAKAAIJ6g4xDgCMAAAuAAQKfycAAgoACAlYGFkWACkCAAoACAlYGFkWACkCAAAA.',
['萌萌']='萌萌哒血骑士:BAAALgAECgMJAwAAAA==.萌萌小橘子:BAABLgAFFH8GAAIOAAQJfRZVBgBjAQAOAAQJfRZVBgBjAQABLgAFFAQJDwAKAGcjAA==.萌萌的痞子叔:BAAALgAECgUJBQAAAA==.',
['萝卜']='萝卜的排骨:BAAALgAECgQJBQAAAA==.',
['萨萨']='萨萨很低调:BAAALgAFFAMJBAAAAA==.',
['落雪']='落雪丶无桁:BAAALgAECgMJBQAAAA==.',
['蒜蓉']='蒜蓉龙虾:BAACLgAFFH8JAAIDAAMJ1iUOBwBUAQADAAMJ1iUOBwBUAQAuAAQKfyAAAgMACAlUJLYDADsDAAMACAlUJLYDADsDAAAA.',
['蓝翼']='蓝翼天:BAAALgAECgcJEAAAAA==.',
['蓝色']='蓝色眼眸丶:BAAALgAFFAEJAQABLgAFFAQJDAABAAgYAA==.',
['蘭丁']='蘭丁格児:BAACLgAFFH8FAAIPAAMJ3RnRIQAQAQAPAAMJ3RnRIQAQAQAuAAQKfyAAAg8ACAkfIwIOACsDAA8ACAkfIwIOACsDAAAA.',
['虞书']='虞书欣:BAAALgAECgcJDAAAAA==.',
['蛋糕']='蛋糕酱:BAAALgAECgEJBAAAAA==.',
['蛋蛋']='蛋蛋侠风怒:BAAALgAECgEJAQAAAA==.',
['蜜汁']='蜜汁叉烧饭:BAAALgAECgEJAgAAAA==.',
['血腥']='血腥丶浪漫:BAAALgAECgEJAgAAAA==.',
['血誓']='血誓灬筱泞:BAAALgAECgUJBQAAAA==.血誓逍遥:BAAALgADCgEJAQAAAA==.',
['被血']='被血染红的刄:BAABLgAFFH8GAAIPAAMJphISKAD4AAAPAAMJphISKAD4AAAAAA==.',
['西柚']='西柚:BAAALgAECgMJAwAAAA==.',
['西瓜']='西瓜大侠:BAAALgAECgEJAQAAAA==.西瓜小侠:BAAALgAECgEJAQAAAA==.',
['西西']='西西琪:BAABLgAFFH8FAAICAAMJbg1BEADvAAACAAMJbg1BEADvAAAAAA==.',
['见面']='见面就挠你:BAAALgAECgEJAQAAAA==.',
['解解']='解解:BAAALgAECgYJEQAAAA==.',
['護身']='護身戒指:BAAALgAECgYJDgAAAA==.',
['讨厌']='讨厌夏天:BAACLgAFFH8PAAMGAAUJpxG6EAAoAQAGAAQJnQ26EAAoAQABAAQJYRJdEgBiAAAuAAQKfy8AAwEACQmHIeEBAJoCAAEACQlxIOEBAJoCAAYABwm6IR8TAJkCAAAA.',
['让我']='让我叠一下钢:BAAALgAECgUJBQAAAA==.',
['许昊']='许昊龙:BAAALgAECgYJBgAAAA==.',
['证吾']='证吾神通:BAAALgAECgMJBAAAAA==.',
['诗酒']='诗酒露华浓:BAAALgAECgEJAQAAAA==.',
['请勿']='请勿喂食:BAACLgAFFH8IAAIeAAMJTQuXEgDUAAAeAAMJTQuXEgDUAAAuAAQKfxYAAh4ACAk0GUgeAE0CAB4ACAk0GUgeAE0CAAAA.',
['诺克']='诺克萨斯之影:BAAALgAECgEJAQAAAA==.',
['谁是']='谁是躺赢狗:BAACLgAFFH8QAAMiAAUJeiNTAAAIAgAiAAUJwiJTAAAIAgAUAAQJ/h6mBQCGAQAuAAQKfyQAAyIACAlUIuEAAEsDACIACAnTIeEAAEsDABQABwlrIasNAMICAAAA.',
['谜一']='谜一样:BAAALgADCggJCAAAAA==.',
['谢绝']='谢绝拍打喂食:BAAALgAECgMJAwABLgAECgYJDgAEAAAAAA==.',
['豆奶']='豆奶味豆花:BAAALgADCgEJAQAAAA==.',
['豹宝']='豹宝宝:BAAALgAECgMJAwAAAA==.',
['败给']='败给伱的温柔:BAAALgAECgQJBAAAAA==.',
['贵仁']='贵仁肾宝片:BAAALgAFFAEJAQAAAA==.',
['赤城']='赤城濑菜:BAAALgADCgYJBgAAAA==.',
['赤色']='赤色软泥怪:BAABLgAFFH8FAAIPAAIJ+geCRwCVAAAPAAIJ+geCRwCVAAAAAA==.',
['路人']='路人你妹:BAAALgAECgIJAwAAAA==.',
['辛多']='辛多雷之魇:BAAALgAECgUJCQAAAA==.',
['辣椒']='辣椒炒皮蛋:BAAALgADCgEJAQAAAA==.',
['返回']='返回角色:BAABLgAECn8UAAQLAAgJoxUlOQAnAgALAAgJoxUlOQAnAgANAAEJyAtKMgA5AAAMAAEJAAABcQA1AAAAAA==.',
['这太']='这太秀了龟龟:BAAALgAECgUJCAAAAA==.',
['迷儿']='迷儿丶:BAAALgAECgYJCQAAAA==.',
['迷茫']='迷茫的萌货丶:BAAALgAECgUJCQAAAA==.',
['逐星']='逐星者:BAAALgAECgMJBQAAAA==.',
['逐梦']='逐梦天涯:BAAALgAECgkJEAAAAA==.',
['逗成']='逗成一匹马:BAAALgAECggJDQAAAA==.',
['這樣']='這樣微笑:BAAALgAECgEJAQAAAA==.',
['速度']='速度与我击剑:BAAALgAECgQJCgAAAA==.',
['逹鲁']='逹鲁:BAAALgADCgEJAQAAAA==.',
['那年']='那年那天那雪:BAAALgAECgEJAQAAAA==.',
['邪悪']='邪悪银渐层:BAAALgAECgEJAQAAAA==.',
['邪牛']='邪牛:BAAALgAECgQJBgAAAA==.',
['酒糟']='酒糟鼻:BAAALgAECgYJBgAAAA==.',
['醉丶']='醉丶爱:BAAALgAFFAIJBAAAAA==.醉丶酒池:BAAALgAECgQJBQAAAA==.',
['醉后']='醉后一骑:BAAALgAECgQJBgAAAA==.',
['醉酒']='醉酒念红尘:BAAALgAECgYJBgAAAA==.',
['野人']='野人新之助:BAAALgAECgkJCQAAAA==.',
['量小']='量小非君子:BAAALgAECgMJAwAAAA==.',
['釺琻']='釺琻:BAAALgAECggJDwAAAA==.',
['鎷鎷']='鎷鎷:BAACLgAFFH8HAAIFAAIJPxEkPQCyAAAFAAIJPxEkPQCyAAAuAAQKfxgAAgUABwnpF017ANsBAAUABwnpF017ANsBAAAA.',
['钎琻']='钎琻报德:BAAALgAECgcJDQAAAA==.',
['钮钴']='钮钴禄和珅:BAAALgAECgYJBgAAAA==.',
['钱塘']='钱塘情歌王:BAAALgAECgcJBwAAAA==.',
['锋尐']='锋尐疯:BAAALgAECgEJAQAAAA==.',
['锐锐']='锐锐:BAACLgAFFH8GAAIPAAIJVxbAFAC1AAAPAAIJVxbAFAC1AAAuAAQKfycAAg8ACAkeIMcFACkCAA8ACAkeIMcFACkCAAAA.',
['错咖']='错咖葫芦娃:BAACLgAFFH8FAAMBAAMJJAsODwClAAABAAMJJAsODwClAAAGAAEJWAYpKwBFAAAuAAQKfx8AAwYABwmgIZIaAFICAAYABwkqHpIaAFICAAEABAkMHzMdABYBAAAA.',
['锦心']='锦心锦煜:BAAALgAECgIJAgAAAA==.',
['锦绣']='锦绣初年:BAAALgAECgMJAwAAAA==.锦绣初战:BAAALgAECgEJAQAAAA==.',
['长岛']='长岛冰碴:BAACLgAFFH8GAAIFAAMJJBpsJgAZAQAFAAMJJBpsJgAZAQAuAAQKfyAAAgUABwkxHw4RALoBAAUABwkxHw4RALoBAAAA.',
['长缨']='长缨在手:BAACLgAFFH8HAAIPAAQJzgx2GQA/AQAPAAQJzgx2GQA/AQAuAAQKfxgAAg8ACQmpHzUPACMDAA8ACQmpHzUPACMDAAEuAAUUBAkHAAEAlwwA.',
['闪光']='闪光裂空座:BAAALgAECgEJAQAAAA==.',
['闲雨']='闲雨:BAAALgAECgcJBwAAAA==.',
['阿乄']='阿乄狸:BAAALgADCgEJAQAAAA==.',
['阿僧']='阿僧波:BAABLgAFFH8HAAIQAAMJLRIICAD2AAAQAAMJLRIICAD2AAAAAA==.',
['阿克']='阿克雅:BAAALgAFFAEJAQAAAA==.',
['阿兹']='阿兹陌丹:BAAALgAECgEJAQAAAA==.',
['阿塔']='阿塔达萨:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔托利雅灬:BAAALgAECgEJAgAAAA==.',
['阿瓦']='阿瓦达啃大瓜:BAAALgAECgUJCAAAAA==.',
['陌路']='陌路狂沙:BAAALgAECgEJAQAAAA==.',
['除您']='除您家伙事儿:BAAALgAECgcJEAAAAA==.',
['随风']='随风而行灬:BAAALgAECgYJCwAAAA==.',
['隐寂']='隐寂:BAAALgAFFAMJBAAAAA==.',
['难以']='难以理解:BAAALgAECgcJBwABLgAECgcJDQAEAAAAAA==.',
['雀明']='雀明华:BAAALgAECggJEwAAAA==.',
['雅雅']='雅雅:BAABLgAFFH8GAAIFAAMJih53JQAeAQAFAAMJih53JQAeAQAAAA==.',
['雨中']='雨中的爱丽丝:BAAALgAECgUJBgAAAA==.',
['雪哀']='雪哀:BAAALgAECgYJCwAAAA==.',
['雪莉']='雪莉蜜瓜桶:BAAALgADCgEJAQAAAA==.',
['零乐']='零乐:BAAALgAECgIJAwAAAA==.',
['雷霆']='雷霆洗礼:BAAALgADCgEJAQAAAA==.',
['霉利']='霉利普贝当:BAAALgAECgQJBAAAAA==.',
['露水']='露水旁乘凉乄:BAAALgADCgIJAgAAAA==.',
['霸气']='霸气凹凸曼:BAAALgAECgUJBQAAAA==.',
['霸波']='霸波儿大奔:BAAALgAECgIJAgAAAA==.',
['青山']='青山入梦:BAAALgAECgIJBAAAAA==.',
['青柌']='青柌:BAAALgAFFAQJBAAAAA==.',
['韓兯']='韓兯餀阚歛:BAAALgAECgMJAwAAAA==.',
['風起']='風起丶:BAAALgAECgEJAQAAAA==.',
['风林']='风林火山辉:BAAALgAECgYJBwAAAA==.',
['风的']='风的季节:BAAALgAFFAIJAwABLgAFFAIJAwAEAAAAAA==.',
['风过']='风过飘影:BAAALgAECgMJAwAAAA==.',
['飞雪']='飞雪无霜:BAAALgAECgEJAQAAAA==.',
['饺子']='饺子格里芬:BAAALgAECgMJAwAAAA==.',
['马上']='马上开杀:BAAALgAECgEJAQAAAA==.',
['马德']='马德制杖:BAABLgAFFH8HAAMGAAMJxxX4HACiAAAGAAIJcBL4HACiAAABAAMJxxUCIwBaAAAAAA==.',
['骑龙']='骑龙弄凤:BAAALgAFFAIJAgABLgAFFAQJBQALAD4fAA==.',
['魂之']='魂之殇:BAAALgAECgEJAwAAAA==.',
['魔法']='魔法少女绫:BAAALgADCgEJAQAAAA==.',
['鸡脚']='鸡脚丶芝士:BAAALgAFFAEJAQAAAA==.',
['鸡腿']='鸡腿哥之怒:BAAALgADCgYJBgAAAA==.',
['鹰魔']='鹰魔:BAAALgADCgEJAQAAAA==.',
['麦当']='麦当劳超好味:BAAALgAECggJCAAAAA==.',
['麦肯']='麦肯奈特:BAAALgAECgYJCwAAAA==.',
['麦言']='麦言中:BAAALgAECgYJDAAAAA==.',
['黄昏']='黄昏之后:BAAALgAECgEJAQAAAA==.',
['黄牛']='黄牛奶爸:BAAALgAECgMJBAAAAA==.',
['黎黯']='黎黯倵:BAAALgAECgcJBwAAAA==.',
['黑了']='黑了点:BAAALgAECgYJBgAAAA==.',
['黑心']='黑心大萝卜:BAAALgAECgYJBgAAAA==.',
['黑暗']='黑暗艺术家:BAAALgADCgMJAwAAAA==.',
['黑棠']='黑棠朵朵:BAAALgADCgMJAwAAAA==.',
['黑色']='黑色影子:BAAALgADCgEJAQAAAA==.',
['龙小']='龙小布:BAAALgAECgQJBAAAAA==.',
['龙布']='龙布:BAABLgAECn8TAAIGAAcJpx27GgBQAgAGAAcJpx27GgBQAgAAAA==.',
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
