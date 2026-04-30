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

local lookup = {'Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Mage-Frost','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','Warrior-Fury','Priest-Discipline','Hunter-BeastMastery','Druid-Restoration','Paladin-Holy','DeathKnight-Frost','DeathKnight-Blood','Rogue-Outlaw','Warlock-Affliction','Paladin-Retribution','Shaman-Elemental','Hunter-Marksmanship','Monk-Brewmaster','Monk-Mistweaver','Priest-Holy','Priest-Shadow',}
local provider = {region='CN',realm='凤凰之神',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Ma='Maéva:BAEALgAFFAUJAQAAAA==.',
Na='Natty:BAEBLgAFFH8FAAMBAAQJiAxSFgBSAARoDAAAAQAOAGkMAAABADcAawwAAAEAGgDqDAAAAgAgAAEAAQmiDFIWAFIAAeoMAAABACAAAgAECVELAAAAAAAEaAwAAAEADgBpDAAAAQA3AGsMAAABABoA6gwAAAEAEwABLgAFFAUJBAADAAAAAA==.',
Ne='Nesteawlk:BAEALgAECgMJAwABLgAFFAUJEQAEAN4kAA==.',
Ob='Obdr:BAECLgAFFH8VAAIFAAYJtSVAAAAfAgZoDAAABABeAGkMAAAFAF0AawwAAAMAYQBqDAAAAQBKAGwMAAADAGMA6gwAAAUAYQAFAAYJtSVAAAAfAgZoDAAABABeAGkMAAAFAF0AawwAAAMAYQBqDAAAAQBKAGwMAAADAGMA6gwAAAUAYQAuAAQKfxQAAwYACAlMHw0PAOoBAAYABgltIA0PAOoBAAUABQn4HskeAM0BAAAA.',
['一个']='一个奇藕:BAEBLgAECn8bAAMHAAcJcx/3DABmAgdoDAAABwBRAGkMAAAFAFcAawwAAAQAVABqDAAAAgBKAGwMAAAEAEoA6gwAAAQAWABuDAAAAQBIAAcABwlzH/cMAGYCB2gMAAAHAFEAaQwAAAUAVwBrDAAABABUAGoMAAACAEoAbAwAAAMASgDqDAAABABYAG4MAAABAEgABQABCf0DAAAAAAABbAwAAAEACgAAAA==.',
['上条']='上条灬当麻:BAEALgAECgEJAQABLgAECgYJBgADAAAAAA==.',
['两杆']='两杆大冰枪:BAECLgAFFH8GAAIEAAMJgRNZEgABAQNoDAAAAwBLAGkMAAABAC0A6gwAAAIAHAAEAAMJgRNZEgABAQNoDAAAAwBLAGkMAAABAC0A6gwAAAIAHAAuAAQKfxwAAgQACAkpHBY+AH8CAAQACAkpHBY+AH8CAAAA.',
['丨幼']='丨幼麟丨:BAEALgAECgUJBQABLgAECgcJFAAIAHcSAA==.',
['丶不']='丶不努力:BAEBLgAECn8XAAIHAAcJigbJLAANAQdoDAAABQAPAGkMAAAEAAcAawwAAAMAFgBqDAAABAASAGwMAAACAAAA6gwAAAQAJwBuDAAAAQANAAcABwmKBsksAA0BB2gMAAAFAA8AaQwAAAQABwBrDAAAAwAWAGoMAAAEABIAbAwAAAIAAADqDAAABAAnAG4MAAABAA0AAS4ABRQFCRQACQCoJgA=.',
['丶伊']='丶伊裴尔塔尔:BAEALgAECgcJCgABLgAECgcJDgADAAAAAA==.',
['丶小']='丶小爪丶:BAEALgAECggJCgABLgAFFAcJDwAFAPsYAA==.',
['丷寒']='丷寒丷:BAEALgAECgcJDgAAAA==.',
['丿萌']='丿萌嘟嘟:BAEALgAECgYJBgABLgAFFAQJEAAKACMmAA==.',
['义怜']='义怜圣灵斩:BAEALgAFFAIJAwABLgAFFAQJBwALAJ8OAA==.',
['云青']='云青青兮欲雨:BAEBLgAFFH8IAAMCAAYJShc9OACjAAZoDAAAAgAsAGkMAAABAD8AawwAAAEASQBqDAAAAQAnAGwMAAABACsA6gwAAAIASAACAAQJBRU9OACjAARoDAAAAgAsAGoMAAABACcAbAwAAAEAKwDqDAAAAgBIAAEAAgmxGgAAAAAAAmkMAAABAD8AawwAAAEASQABLgAFFAQJBgAEALASAA==.',
['伊势']='伊势灬七绪:BAEALgAECgEJAQABLgAECgYJBgADAAAAAA==.',
['佳小']='佳小德:BAECLgAFFH8TAAIMAAUJ6CaeAABPAgVoDAAABQBjAGkMAAAFAGMAawwAAAMAYwBqDAAAAgBiAOoMAAAEAGMADAAFCegmngAATwIFaAwAAAUAYwBpDAAABQBjAGsMAAADAGMAagwAAAIAYgDqDAAABABjAC4ABAp/JgACDAAICdomOgEAnQMADAAICdomOgEAnQMAAAA=.佳小骑:BAEBLgAFFH8LAAINAAQJASS5AwCqAQRoDAAABABcAGkMAAACAFYAawwAAAIAYgDqDAAAAwBbAA0ABAkBJLkDAKoBBGgMAAAEAFwAaQwAAAIAVgBrDAAAAgBiAOoMAAADAFsAAS4ABRQFCRMADADoJgA=.',
['傲世']='傲世狂龙:BAEALgAECgYJCQAAAA==.',
['全息']='全息玫瑰裂片:BAEALgAECgEJAQAAAA==.',
['冷布']='冷布叮:BAEALgAECgIJAgABLgAECgYJBgADAAAAAA==.',
['别碰']='别碰我龙角:BAEALgAECgkJCQABLgAFFAIJBAADAAAAAA==.',
['北山']='北山先生:BAECLgAFFH8QAAIEAAUJyxpTDAC6AQVoDAAAAwBVAGkMAAACAEgAawwAAAQAIgBqDAAAAwBDAOoMAAAEAFIABAAFCcsaUwwAugEFaAwAAAMAVQBpDAAAAgBIAGsMAAAEACIAagwAAAMAQwDqDAAABABSAC4ABAp/KgACBAAICTQhQBgAGQMABAAICTQhQBgAGQMAAS4ABRQGCRUABABLIwA=.',
['古月']='古月方源丨:BAEBLgAFFH8KAAMIAAQJ0iUeGQBBAQRoDAAAAwBfAGkMAAADAGEAawwAAAEAYwDqDAAAAwBfAAgAAwm+JB4ZAEEBA2gMAAACAF8AaQwAAAIAYQDqDAAAAgBZAA4ABAm+IQAAAAAABGgMAAABAFgAaQwAAAEAPgBrDAAAAQBjAOoMAAABAF8AAAA=.',
['喷火']='喷火龙王:BAEALgAECgYJBgAAAA==.',
['固有']='固有时制御:BAEALgAECgcJBgABLgAFFAQJBwAEAOMlAA==.',
['天内']='天内灬理子:BAEALgADCgIJAgABLgAECgYJBgADAAAAAA==.',
['天道']='天道树花超甜:BAEALgAFFAIJAgABLgAFFAEJAQADAAAAAA==.',
['寒冰']='寒冰刺客:BAEALgAECgkJDwABLgAFFAQJBgAEALASAA==.',
['小小']='小小毒瘤:BAECLgAFFH8OAAMIAAUJIiBvDQBtAQVoDAAAAgBIAGkMAAADAEgAawwAAAQAWQBqDAAAAQBLAOoMAAAEAF4ACAAECSIgbw0AbQEEaAwAAAIASABpDAAAAwBIAGsMAAAEAFkA6gwAAAQAXgAPAAEJAAA/EwBZAAFqDAAAAQBLAC4ABAp/HAACCAAHCd4gJSoAkAIACAAHCd4gJSoAkAIAAAA=.',
['张碧']='张碧晨:BAEBLgAFFH8LAAIEAAcJLho2AQCvAgdoDAAAAgBPAGkMAAACADwAawwAAAIAXQBqDAAAAQBHAGwMAAABAC8AbQwAAAEAJwDqDAAAAgBQAAQABwkuGjYBAK8CB2gMAAACAE8AaQwAAAIAPABrDAAAAgBdAGoMAAABAEcAbAwAAAEALwBtDAAAAQAnAOoMAAACAFAAAAA=.',
['悠云']='悠云叶月丶:BAEALgAFFAQJBAAAAA==.',
['拟态']='拟态软泥涡虫:BAEALgAECgYJBwAAAA==.',
['捣管']='捣管仙人:BAEALgAECgYJBgABLgAFFAQJBgAEALASAA==.',
['斩空']='斩空天翔剑:BAEBLgAECn8bAAIIAAgJcx5dKACZAghoDAAABABZAGkMAAAEAGEAawwAAAQAYQBqDAAAAwBaAGwMAAAEAFwAbQwAAAEAAwDqDAAABQBeAG4MAAACAEYACAAICXMeXSgAmQIIaAwAAAQAWQBpDAAABABhAGsMAAAEAGEAagwAAAMAWgBsDAAABABcAG0MAAABAAMA6gwAAAUAXgBuDAAAAgBGAAEuAAUUBAkHAAsAnw4A.',
['断铠']='断铠灬绳衣:BAEALgAECgYJBgAAAA==.',
['无限']='无限贴贴号:BAEALgAFFAQJBAABLgAFFAQJBgAEALASAA==.',
['早川']='早川绘里莎:BAEALgAECggJCAAAAA==.',
['月神']='月神吧唧:BAEALgAECgYJBgABLgAFFAUJEAAQAJYmAA==.',
['梦绕']='梦绕之灵魂:BAECLgAFFH8FAAMCAAQJlwhoEADwAARoDAAAAQAlAGkMAAABAAkAawwAAAEADwDqDAAAAgAZAAIAAwk3CmgQAPAAA2gMAAABACUAawwAAAEADwDqDAAAAgAZAAEAAQm3A7wGAEYAAWkMAAABAAkALgAECn8YAAQBAAgJ4hwYJAA5AQABAAQJUBsYJAA5AQACAAQJDx7fNACsAAARAAEJAACyKgBKAAAAAA==.',
['母牛']='母牛迎风劈叉:BAEALgADCgUJBQAAAA==.',
['海洋']='海洋一:BAEBLgAFFH8LAAIFAAYJdxqUAgAYAgZoDAAAAgBHAGkMAAACAE4AawwAAAIAOABqDAAAAgAWAGwMAAABADwA6gwAAAIARwAFAAYJdxqUAgAYAgZoDAAAAgBHAGkMAAACAE4AawwAAAIAOABqDAAAAgAWAGwMAAABADwA6gwAAAIARwABLgAFFAcJDwAFAPsYAA==.海洋三:BAEBLgAFFH8JAAIFAAUJrBSaBQCmAQVoDAAAAgBKAGkMAAACADsAawwAAAIAPABqDAAAAQApAOoMAAACABAABQAFCawUmgUApgEFaAwAAAIASgBpDAAAAgA7AGsMAAACADwAagwAAAEAKQDqDAAAAgAQAAEuAAUUBwkPAAUA+xgA.海洋二:BAEBLgAFFH8GAAIFAAYJdR2JAQBZAgZoDAAAAQBeAGkMAAABAFkAawwAAAEAWwBqDAAAAQA8AGwMAAABADAA6gwAAAEANAAFAAYJdR2JAQBZAgZoDAAAAQBeAGkMAAABAFkAawwAAAEAWwBqDAAAAQA8AGwMAAABADAA6gwAAAEANAABLgAFFAcJDwAFAPsYAA==.海洋五:BAEBLgAFFH8UAAIFAAYJtRk9AgApAgZoDAAABABeAGkMAAAEAFEAawwAAAQAVwBqDAAAAwBSAGwMAAABAA0A6gwAAAQAMwAFAAYJtRk9AgApAgZoDAAABABeAGkMAAAEAFEAawwAAAQAVwBqDAAAAwBSAGwMAAABAA0A6gwAAAQAMwABLgAFFAcJDwAFAPsYAA==.海洋八:BAEBLgAFFH8KAAIFAAUJTxYcBQCyAQVoDAAAAgBaAGkMAAACADkAawwAAAIAMwBqDAAAAgAuAOoMAAACAB0ABQAFCU8WHAUAsgEFaAwAAAIAWgBpDAAAAgA5AGsMAAACADMAagwAAAIALgDqDAAAAgAdAAEuAAUUBwkPAAUA+xgA.海洋六:BAEBLgAFFH8MAAIFAAUJ2BVTBQCtAQVoDAAAAwBWAGkMAAADACoAawwAAAMALABqDAAAAQARAOoMAAACADIABQAFCdgVUwUArQEFaAwAAAMAVgBpDAAAAwAqAGsMAAADACwAagwAAAEAEQDqDAAAAgAyAAEuAAUUBwkPAAUA+xgA.海洋十:BAEBLgAFFH8KAAIFAAUJexjqBAC4AQVoDAAAAgBfAGkMAAACAEYAawwAAAIAQQBqDAAAAgAdAOoMAAACABMABQAFCXsY6gQAuAEFaAwAAAIAXwBpDAAAAgBGAGsMAAACAEEAagwAAAIAHQDqDAAAAgATAAEuAAUUBwkPAAUA+xgA.海洋四:BAEALgAFFAQJBAABLgAFFAcJDwAFAPsYAA==.',
['湖畔']='湖畔骑:BAEBLgAFFH8TAAISAAUJTSXBAQABAgVoDAAABABfAGkMAAAFAGIAawwAAAQAXwBqDAAAAgBJAOoMAAAEAF0AEgAFCU0lwQEAAQIFaAwAAAQAXwBpDAAABQBiAGsMAAAEAF8AagwAAAIASQDqDAAABABdAAAA.',
['激励']='激励皮卡丘:BAEBLgAECn8UAAMCAAcJGCVqIACWAgdoDAAAAgBhAGkMAAADAF4AawwAAAMAYwBqDAAAAwBZAGwMAAADAFkAbQwAAAIAWgDqDAAABABhAAIABwm1I2ogAJYCB2gMAAACAGEAaQwAAAIAXgBrDAAAAwBjAGoMAAABAFkAbAwAAAEARABtDAAAAgBaAOoMAAAEAGEAAQADCTgiCigAIwEDaQwAAAEAVQBqDAAAAgBVAGwMAAACAFkAAAA=.',
['王心']='王心凌的铁粉:BAEALgAFFAEJAQAAAA==.王心凌超甜:BAEALgAFFAIJAgABLgAFFAEJAQADAAAAAA==.',
['皇白']='皇白璐:BAEBLgAFFH8FAAITAAUJMwrHBgBuAQVoDAAAAQAkAGkMAAABAB4AawwAAAEACgBqDAAAAQAHAOoMAAABABsAEwAFCTMKxwYAbgEFaAwAAAEAJABpDAAAAQAeAGsMAAABAAoAagwAAAEABwDqDAAAAQAbAAAA.',
['真神']='真神炼狱刹:BAEBLgAFFH8HAAMLAAQJnw5GCQAXAQRoDAAAAwBVAGkMAAABAAQAawwAAAEAAADqDAAAAgA7AAsABAn9DUYJABcBBGgMAAACAFUAaQwAAAEABABrDAAAAQAAAOoMAAABADUAFAACCQoVohwAowACaAwAAAEAMADqDAAAAQA7AAAA.',
['笙歌']='笙歌丶:BAEBLgAECn8UAAMNAAYJoRg/NQCoAQZoDAAABABGAGkMAAAEADYAawwAAAQALgBqDAAAAgA9AGwMAAADADMA6gwAAAMAXQANAAYJoRg/NQCoAQZoDAAAAgBGAGkMAAACADYAawwAAAIALgBqDAAAAgA9AGwMAAACADMA6gwAAAIAXQASAAUJdBSStQAZAQVoDAAAAgBCAGkMAAACADYAawwAAAIAJgBsDAAAAQA9AOoMAAABACcAAAA=.',
['素质']='素质洼地:BAEALgAFFAQJBAABLgAFFAQJBgAEALASAA==.',
['网恋']='网恋奶僧:BAEALgAECgIJAgAAAA==.',
['罗勒']='罗勒捞面条:BAEBLgAFFH8KAAMBAAYJqhsWDACqAAZoDAAAAgBTAGkMAAACAD0AawwAAAIARgBqDAAAAQAyAGwMAAABAC8A6gwAAAIAWwACAAQJ8xwlMQCwAARoDAAAAgBTAGoMAAABADIAbAwAAAEALwDqDAAAAgBbAAEAAgm9GRYMAKoAAmkMAAACAD0AawwAAAIARgABLgAFFAQJBgAEALASAA==.',
['芒果']='芒果茶:BAEALgAECgEJAQABLgAECgIJAgADAAAAAA==.',
['苏格']='苏格呢:BAEBLgAFFH8QAAIQAAUJliYPAAAkAgVoDAAABABjAGkMAAAEAGMAawwAAAIAYQBqDAAAAgBCAOoMAAAEAGMAEAAFCZYmDwAAJAIFaAwAAAQAYwBpDAAABABjAGsMAAACAGEAagwAAAIAQgDqDAAABABjAAAA.苏格大爷:BAEALgADCgcJBwABLgAFFAUJEAAQAJYmAA==.',
['荔飞']='荔飞羽:BAECLgAFFH8GAAINAAIJQyZyDwDhAAJoDAAAAgBfAOoMAAAEAGQADQACCUMmcg8A4QACaAwAAAIAXwDqDAAABABkAC4ABAp/FwACDQAGCTAmzREAhAIADQAGCTAmzREAhAIAAAA=.',
['菰羽']='菰羽翎風:BAEALgAECgMJAwABLgAFFAUJEwAEABkYAA==.菰羽翎风:BAECLgAFFH8TAAIEAAUJGRgFCgDOAQVoDAAABABNAGkMAAAEAEgAawwAAAQAJgBqDAAAAwBIAOoMAAAEADkABAAFCRkYBQoAzgEFaAwAAAQATQBpDAAABABIAGsMAAAEACYAagwAAAMASADqDAAABAA5AC4ABAp/HwACBAAJCbckMhYAJAMABAAJCbckMhYAJAMAAAA=.',
['萨萨']='萨萨丶熊:BAEALgAECgEJAQABLgAFFAUJDgAIACIgAA==.',
['蒼月']='蒼月璃晴:BAEALgAECgcJAQABLgAFFAUJBAADAAAAAA==.',
['银岭']='银岭灬弧雀:BAEALgADCgMJAwABLgAECgYJBgADAAAAAA==.',
['长天']='长天共秋水:BAEBLgAFFH8GAAICAAMJ+CWlEQBXAQNoDAAAAwBhAGkMAAACAGMA6gwAAAEAXgACAAMJ+CWlEQBXAQNoDAAAAwBhAGkMAAACAGMA6gwAAAEAXgAAAA==.',
['闲梦']='闲梦江南:BAEBLgAFFH8GAAINAAIJryb8DgDmAAJoDAAAAgBiAOoMAAAEAGMADQACCa8m/A4A5gACaAwAAAIAYgDqDAAABABjAAEuAAUUBAkQAAoAIyYA.',
['阿茶']='阿茶龙七:BAEBLgAFFH8FAAIHAAUJZhmXAwDMAQVoDAAAAQAkAGkMAAABAEcAawwAAAEAIgBqDAAAAQBbAOoMAAABAFoABwAFCWYZlwMAzAEFaAwAAAEAJABpDAAAAQBHAGsMAAABACIAagwAAAEAWwDqDAAAAQBaAAEuAAUUBAkGAAQAsBIA.阿茶龙九:BAEALgAFFAUJBAABLgAFFAQJBgAEALASAA==.阿茶龙六:BAEALgAFFAUJBAABLgAFFAQJBgAEALASAA==.阿茶龙四:BAEALgAFFAUJBAABLgAFFAQJBgAEALASAA==.',
['青龙']='青龙山打手:BAECLgAFFH8KAAIVAAQJphfWBwBUAQRoDAAAAwBRAGkMAAADABoAawwAAAEAKgDqDAAAAwBbABUABAmmF9YHAFQBBGgMAAADAFEAaQwAAAMAGgBrDAAAAQAqAOoMAAADAFsALgAECn8ZAAMVAAcJDxI0MwCEAQAVAAYJrBU0MwCEAQAWAAEJAwBOeQABAAAAAA==.',
['静静']='静静的看着侬:BAECLgAFFH8IAAIXAAMJzxfEBwDuAANoDAAABABAAGkMAAABAC4A6gwAAAMARwAXAAMJzxfEBwDuAANoDAAABABAAGkMAAABAC4A6gwAAAMARwAuAAQKfyIABBcACAkMIh8IAMkCABcACAmNIR8IAMkCAAoABgmxGaMbALkBABgAAQnLJItVAGsAAAAA.',
['风吹']='风吹枫叶:BAEALgAECgYJDAAAAA==.',
['马勒']='马勒比海盗:BAECLgAFFH8KAAMCAAYJzBi9AADVAQZoDAAAAgBCAGkMAAACAEkAawwAAAIANABqDAAAAQAQAGwMAAABABkA6gwAAAIAYgACAAYJzBi9AADVAQZoDAAAAgBCAGkMAAABAEkAawwAAAIANABqDAAAAQAQAGwMAAABABkA6gwAAAIAYgABAAEJ7hmAEgBaAAFpDAAAAQBCAC4ABAp/FwADAgAJCe8d0QcARQMAAgAJCe8d0QcARQMAAQABCQAAZF8AUAAAAS4ABRQECQYABACwEgA=.',
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
