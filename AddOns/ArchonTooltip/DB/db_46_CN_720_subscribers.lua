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

local lookup = {'Warlock-Demonology','Warrior-Protection','Priest-Shadow','Evoker-Preservation','Priest-Discipline','Evoker-Augmentation','Priest-Holy','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Shaman-Enhancement','Shaman-Elemental','Monk-Brewmaster','Rogue-Subtlety','DemonHunter-Devourer','Evoker-Devastation','Evoker-Ranged','Mage-Frost','Paladin-Holy','Warrior-Fury',}
local provider = {region='CN',realm='死亡之翼',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Di='Dirkll:BAEBLgAFFH8FAAIBAAUJdBoNBADfAQVoDAAAAQBDAGkMAAABAEYAawwAAAEAIwBqDAAAAQBXAOoMAAABAGEAAQAFCXQaDQQA3wEFaAwAAAEAQwBpDAAAAQBGAGsMAAABACMAagwAAAEAVwDqDAAAAQBhAAAA.',
Fi='Fiskerdh:BAEALgAECgUJBQABLgAFFAUJEAACAF0IAA==.Fiskerdru:BAEALgAECgYJBgABLgAFFAUJEAACAF0IAA==.Fiskerpal:BAEALgAECgYJBgABLgAFFAUJEAACAF0IAA==.',
Gu='Guldand:BAEALgAECgkJEAABLgAFFAQJBQABAJcIAA==.',
Ls='Lsydk:BAEALgAECgYJBgAAAA==.',
Mi='Miroslav:BAECLgAFFH8QAAICAAUJXQhFBAA8AQVoDAAABQA5AGkMAAAEABcAawwAAAMABgBsDAAAAQAHAOoMAAADAAwAAgAFCV0IRQQAPAEFaAwAAAUAOQBpDAAABAAXAGsMAAADAAYAbAwAAAEABwDqDAAAAwAMAC4ABAp/FgACAgAICeYXkxEA7gEAAgAICeYXkxEA7gEAAAA=.',
Oo='Oogodtaao:BAEALgAFFAIJBAABLgAFFAYJFQADAGYiAA==.',
Se='Sevoker:BAEBLgAFFH8HAAIEAAMJfSHHCwAtAQNoDAAAAwBVAGkMAAACAE8A6gwAAAIAXAAEAAMJfSHHCwAtAQNoDAAAAwBVAGkMAAACAE8A6gwAAAIAXAABLgAFFAMJBwAFAGclAA==.',
Tg='Tgoddemon:BAEALgAFFAIJAwABLgAFFAYJFQADAGYiAA==.Tgodevoker:BAEBLgAFFH8GAAIGAAQJDQ48EAAAAQRrDAAAAQAgAGoMAAACADkAbAwAAAIAGgDqDAAAAQAwAAYABAkNDjwQAAABBGsMAAABACAAagwAAAIAOQBsDAAAAgAaAOoMAAABADAAAS4ABRQGCRUAAwBmIgA=.Tgodpriest:BAECLgAFFH8VAAMDAAYJZiKhAABwAgZoDAAABQBhAGkMAAAEAGEAawwAAAQAYwBqDAAAAgArAGwMAAABAC4A6gwAAAUAYgADAAYJZiKhAABwAgZoDAAABABhAGkMAAAEAGEAawwAAAQAYwBqDAAAAgArAGwMAAABAC4A6gwAAAQAYgAFAAIJHA59FACSAAJoDAAAAQAaAOoMAAABAC0ALgAECn8jAAMDAAgJiSbBBQAzAwADAAgJiSbBBQAzAwAFAAEJTBcoUQBIAAAAAA==.',
Wa='Wanderpst:BAECLgAFFH8HAAMFAAMJZyXrCABOAQNoDAAAAwBgAGkMAAABAF8A6gwAAAMAXwAFAAMJZyXrCABOAQNoDAAAAgBgAGkMAAABAF8A6gwAAAMAXwAHAAEJOyJJEQBfAAFoDAAAAQBXAC4ABAp/IgAEBQAICbsl9gMAJAMABQAICUUl9gMAJAMABwAGCWAmNwwAjwIAAwADCTgdaEEA7QAAAAA=.',
Ze='Zetalive:BAEBLgAFFH8FAAMIAAUJuwUSHwAgAQVoDAAAAQAXAGkMAAABABgAawwAAAEACQBqDAAAAQAuAOoMAAABAAAACAAECbsFEh8AIAEEaAwAAAEAFwBpDAAAAQAYAGsMAAABAAkA6gwAAAEAAAAJAAEJAABHFgBBAAFqDAAAAQAuAAEuAAUUBAkEAAoAAAAA.Zetall:BAEALgAFFAQJBAAAAA==.',
['世界']='世界萨归来:BAECLgAFFH8GAAILAAMJlSM8AgBGAQNoDAAAAwBjAGkMAAABAFsA6gwAAAIAUgALAAMJlSM8AgBGAQNoDAAAAwBjAGkMAAABAFsA6gwAAAIAUgAuAAQKfygAAwsACAnXIf4BADsDAAsACAnXIf4BADsDAAwACAnGG4kcAC0CAAAA.',
['九千']='九千七丶僧:BAEBLgAECn8kAAINAAcJzyU9CAACAwdoDAAABgBjAGkMAAAGAGEAawwAAAYAYQBqDAAABQBjAGwMAAAGAGIAbQwAAAEAWwDqDAAABgBeAA0ABwnPJT0IAAIDB2gMAAAGAGMAaQwAAAYAYQBrDAAABgBhAGoMAAAFAGMAbAwAAAYAYgBtDAAAAQBbAOoMAAAGAF4AAAA=.九千七丶法:BAEALgADCgMJAwABLgAECgcJJAANAM8lAA==.九千七丶萨:BAEALgAECgIJAgABLgAECgcJJAANAM8lAA==.九千七丶贼:BAEALgAECgEJAQABLgAECgcJJAANAM8lAA==.九千七丶骑:BAEALgAECgcJEQABLgAECgcJJAANAM8lAA==.九千七丶龙:BAEALgAECgUJBQABLgAECgcJJAANAM8lAA==.',
['人生']='人生边缘:BAEALgAECgcJBgABLgAFFAYJFAAOAEQdAA==.',
['你脚']='你脚下有居居:BAEALgAECgkJBAAAAA==.',
['修止']='修止符丶:BAEBLgAFFH8KAAIMAAQJDxNaCgA+AQRoDAAAAwBRAGkMAAACABsAawwAAAIAJADqDAAAAwAxAAwABAkPE1oKAD4BBGgMAAADAFEAaQwAAAIAGwBrDAAAAgAkAOoMAAADADEAAAA=.',
['借泥']='借泥炉烧碗饭:BAEBLgAFFH8GAAIIAAQJ/APKIAAWAQRoDAAAAgAZAGkMAAABAAEAawwAAAEACQDqDAAAAgAEAAgABAn8A8ogABYBBGgMAAACABkAaQwAAAEAAQBrDAAAAQAJAOoMAAACAAQAAS4ABRQGCQ8ADwAfCQA=.',
['倾白']='倾白:BAECLgAFFH8UAAMGAAUJ4hMaBQCyAQVoDAAABQBXAGkMAAAEAEAAawwAAAQAGgBqDAAAAwA9AOoMAAAEABoABgAFCY4TGgUAsgEFaAwAAAMAVwBpDAAAAwA8AGsMAAADABoAagwAAAMAPQDqDAAAAwAaABAABAnAEPgCAEsBBGgMAAACAEoAaQwAAAEAQABrDAAAAQAJAOoMAAABABcALgAECn8fAAMQAAgJMiP1CwAcAgAQAAYJpSH1CwAcAgAGAAUJ4iFcGgD3AQAAAA==.',
['再叩']='再叩风月关:BAECLgAFFH8PAAIPAAYJHwkLBgDEAQZoDAAAAwAsAGkMAAADABAAawwAAAEAEQBqDAAABAAMAGwMAAABAAUA6gwAAAMAIAAPAAYJHwkLBgDEAQZoDAAAAwAsAGkMAAADABAAawwAAAEAEQBqDAAABAAMAGwMAAABAAUA6gwAAAMAIAAuAAQKfxkAAg8ACAkBGuIqAFUCAA8ACAkBGuIqAFUCAAAA.',
['吹吹']='吹吹丶吹:BAEALgAECgEJAgAAAA==.',
['土豆']='土豆拌番茄:BAEALgAECgQJCgAAAA==.土豆炖烩菜:BAEALgAECgIJAwABLgAECgQJCgAKAAAAAA==.土豆烧芹菜:BAEALgAECgEJAgABLgAECgQJCgAKAAAAAA==.',
['尒尾']='尒尾巴:BAEALgAECgkJBgAAAA==.',
['念夏']='念夏之耀:BAEBLgAFFH8IAAIDAAMJDxTlCgAGAQNoDAAAAgAqAGkMAAADADEA6gwAAAMAPgADAAMJDxTlCgAGAQNoDAAAAgAqAGkMAAADADEA6gwAAAMAPgAAAA==.念夏熙盈:BAEALgAECgQJCgABLgAFFAMJCAADAA8UAA==.',
['悲伤']='悲伤苦瓜:BAEALgAECgYJCQAAAA==.',
['放空']='放空倥:BAEALgAECgYJBgAAAA==.',
['查理']='查理斯:BAEBLgAFFH8NAAMIAAUJzB+cCwB3AQVoDAAAAwBBAGkMAAADAFgAawwAAAEARwBqDAAAAgBBAOoMAAAEAGMACAAECcwfnAsAdwEEaAwAAAMAQQBpDAAAAwBYAGsMAAABAEcA6gwAAAQAYwAJAAEJAAAoFgBBAAFqDAAAAgBBAAEuAAUUBgkKAAgAoAgA.',
['梦海']='梦海洋一:BAEBLgAFFH8PAAIGAAcJ+xgeAQB6AgdoDAAAAwBIAGkMAAADAF0AawwAAAMAUQBqDAAAAgAwAGwMAAABABEAbQwAAAEAPADqDAAAAgA7AAYABwn7GB4BAHoCB2gMAAADAEgAaQwAAAMAXQBrDAAAAwBRAGoMAAACADAAbAwAAAEAEQBtDAAAAQA8AOoMAAACADsAAAA=.梦海洋七:BAEBLgAFFH8FAAIGAAUJhxVtBQCqAQVoDAAAAQBDAGkMAAABADwAawwAAAEARABqDAAAAQAyAOoMAAABABgABgAFCYcVbQUAqgEFaAwAAAEAQwBpDAAAAQA8AGsMAAABAEQAagwAAAEAMgDqDAAAAQAYAAEuAAUUBwkPAAYA+xgA.梦海洋三:BAEBLgAFFH8GAAIRAAYJOhMAAAAAAAZoDAAAAQBKAGkMAAABAC4AawwAAAEASgBqDAAAAQA0AGwMAAABABkA6gwAAAEAGQAGAAYJOhMAAAAAAAZoDAAAAQBKAGkMAAABAC4AawwAAAEASgBqDAAAAQA0AGwMAAABABkA6gwAAAEAGQABLgAFFAcJDwAGAPsYAA==.梦海洋二:BAEBLgAFFH8IAAIGAAUJMBN9BQCpAQVoDAAAAgBYAGkMAAACADsAawwAAAEAFwBqDAAAAQAXAOoMAAACABkABgAFCTATfQUAqQEFaAwAAAIAWABpDAAAAgA7AGsMAAABABcAagwAAAEAFwDqDAAAAgAZAAEuAAUUBwkPAAYA+xgA.梦海洋五:BAEBLgAFFH8KAAIGAAUJHxMKBgCdAQVoDAAAAgBIAGkMAAACADEAawwAAAIAMABqDAAAAgAUAOoMAAACABgABgAFCR8TCgYAnQEFaAwAAAIASABpDAAAAgAxAGsMAAACADAAagwAAAIAFADqDAAAAgAYAAEuAAUUBwkPAAYA+xgA.梦海洋八:BAEBLgAFFH8PAAIGAAYJkBnsBQCgAQZoDAAAAwBbAGkMAAADADsAawwAAAMAVABqDAAAAgA9AGwMAAABACQA6gwAAAMANwAGAAYJkBnsBQCgAQZoDAAAAwBbAGkMAAADADsAawwAAAMAVABqDAAAAgA9AGwMAAABACQA6gwAAAMANwABLgAFFAcJDwAGAPsYAA==.梦海洋六:BAEALgAECgcJBwABLgAFFAcJDwAGAPsYAA==.梦海洋十:BAEBLgAFFH8FAAIGAAQJhArGFADMAARoDAAAAgA3AGkMAAABAAcAawwAAAEAEwDqDAAAAQAZAAYABAmECsYUAMwABGgMAAACADcAaQwAAAEABwBrDAAAAQATAOoMAAABABkAAS4ABRQHCQ8ABgD7GAA=.梦海洋四:BAEBLgAFFH8MAAIGAAcJ/Rr4AwDWAQdoDAAAAgBbAGkMAAACAEcAawwAAAIAWwBqDAAAAgBPAGwMAAACACwAbQwAAAEARADqDAAAAQAuAAYABwn9GvgDANYBB2gMAAACAFsAaQwAAAIARwBrDAAAAgBbAGoMAAACAE8AbAwAAAIALABtDAAAAQBEAOoMAAABAC4AAS4ABRQHCQ8ABgD7GAA=.',
['温丰']='温丰瑞:BAEBLgAECn8ZAAIJAAYJ5BcWGwB2AQZoDAAABABMAGkMAAAEAD8AawwAAAQAQABqDAAABAA7AGwMAAAEACsA6gwAAAUAOQAJAAYJ5BcWGwB2AQZoDAAABABMAGkMAAAEAD8AawwAAAQAQABqDAAABAA7AGwMAAAEACsA6gwAAAUAOQABLgAFFAUJEAACAF0IAA==.',
['火爆']='火爆虎鞭:BAEALgAECgYJCwAAAA==.',
['狂炫']='狂炫富婆画饼:BAEALgAECgkJCgABLgAFFAQJBgASALASAA==.',
['白鸽']='白鸽游酒:BAECLgAFFH8OAAQFAAQJPBtzBwBlAQRoDAAABABRAGkMAAAEAFAAawwAAAMAKgDqDAAAAwBKAAUABAk8G3MHAGUBBGgMAAADAFEAaQwAAAQAUABrDAAAAQAqAOoMAAADAEoABwABCdENVRIAUgABawwAAAIAIwADAAEJjwIAAAAAAAFoDAAAAQAGAC4ABAp/IAAEBQAICewlUgEAggMABQAICewlUgEAggMAAwACCb8btEwAowAABwABCZgePXkARAAAAAA=.',
['破碎']='破碎黎明:BAEALgAECgYJBgABLgAFFAIJAwAKAAAAAA==.',
['笙歌']='笙歌丶丶:BAEALgAECgEJAQABLgAECgYJFAATAKEYAA==.',
['红烧']='红烧脚鱼:BAEALgAECgMJBAABLgAECgYJCwAKAAAAAA==.',
['虎牙']='虎牙查理斯:BAEBLgAFFH8KAAIIAAYJoAgUIgAPAQZoDAAAAgAKAGkMAAACAB0AawwAAAIAJwBqDAAAAQATAGwMAAABABcA6gwAAAIACAAIAAYJoAgUIgAPAQZoDAAAAgAKAGkMAAACAB0AawwAAAIAJwBqDAAAAQATAGwMAAABABcA6gwAAAIACAAAAA==.',
['赎罪']='赎罪丶疯月亮:BAEBLgAECn8UAAMCAAgJDg2FGwBvAQhoDAAAAwAxAGkMAAACABsAawwAAAMAJABqDAAAAwAqAGwMAAADADgAbQwAAAEAEwDqDAAABAAdAG4MAAABAA4AAgAICZ8MhRsAbwEIaAwAAAIAKQBpDAAAAQAbAGsMAAACACQAagwAAAIAKgBsDAAAAwA4AG0MAAABABMA6gwAAAMAHQBuDAAAAQAOABQABQmVCdBsAAMBBWgMAAABADEAaQwAAAEABQBrDAAAAQAfAGoMAAABACEA6gwAAAEADAABLgAFFAUJBAAKAAAAAA==.',
['那方']='那方面很行:BAEBLgAFFH8GAAISAAMJKhg6JwAWAQNoDAAAAgAzAGkMAAABAD4A6gwAAAMARwASAAMJKhg6JwAWAQNoDAAAAgAzAGkMAAABAD4A6gwAAAMARwAAAA==.',
['雨姐']='雨姐的大香脚:BAEALgAFFAIJAgABLgAFFAUJEAACAF0IAA==.',
['黑闪']='黑闪丨:BAEALgAFFAUJBAAAAA==.',
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
