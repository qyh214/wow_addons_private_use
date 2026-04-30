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

local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Shaman-Elemental','Mage-Frost','Paladin-Retribution','Paladin-Holy','Unknown-Unknown','Warlock-Ranged','Warlock-Demonology','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','Monk-Brewmaster',}
local provider = {region='CN',realm='安戈洛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Au='Auditore:BAAALgADCgQJBAAAAA==.',
Be='Berserktusk:BAAALgADCgUJBQAAAA==.',
Bl='Blader:BAAALgAECgQJBgAAAA==.',
Cl='Claire:BAAALgADCgYJBgAAAA==.',
De='Deepdarkboys:BAACLgAFFH8FAAIBAAIJNQ05GQCjAAABAAIJNQ05GQCjAAAuAAQKfxoAAwEABwlvHOpKABICAAEABwlvHOpKABICAAIABQkBC6EPAHUAAAAA.',
Dr='Drablo:BAAALgAECgkJCAABLgAFFAQJDQADAJAdAA==.',
Mo='Moonstalker:BAAALgADCgYJEAAAAA==.',
Ne='Newword:BAAALgAECgMJBQABLgAECgcJFQAEAG4iAA==.',
Si='Sinnerdk:BAACLgAFFH8HAAIBAAMJnyGyHQAqAQABAAMJnyGyHQAqAQAuAAQKfxoAAgEABwm+IZAuAH4CAAEABwm+IZAuAH4CAAAA.',
St='Stormcaller:BAAALgADCgYJAgAAAA==.',
Ta='Talisker:BAAALgADCgYJBgAAAA==.',
Va='Valorheart:BAAALgADCgUJBQAAAA==.',
['一条']='一条大香肠猎:BAAALgADCgYJBgAAAA==.',
['万种']='万种风情:BAABLgAECn8YAAIFAAcJhgwmgQB4AQAFAAcJhgwmgQB4AQAAAA==.',
['下雨']='下雨天:BAAALgAFFAEJAQAAAA==.',
['专打']='专打小东东:BAAALgAECgYJDgAAAA==.',
['丨阿']='丨阿布灬:BAAALgAECgQJBAAAAA==.',
['丶苍']='丶苍山负雪:BAAALgAECgUJCAAAAA==.',
['丷星']='丷星沅丷:BAAALgADCgEJAQAAAA==.',
['丸子']='丸子老公:BAAALgAECgMJAwAAAA==.',
['乌夜']='乌夜啼:BAAALgAFFAIJAgABLgAFFAMJBwAFAPYiAA==.',
['五条']='五条刻:BAABLgAFFH8IAAIBAAMJSQ71PgCiAAABAAMJSQ71PgCiAAAAAA==.',
['以心']='以心相克:BAAALgAFFAEJAQAAAA==.',
['传说']='传说中的自由:BAAALgADCgUJBQAAAA==.',
['傲雪']='傲雪玉龙:BAAALgADCgUJBQAAAA==.',
['公子']='公子染尘:BAAALgAECgEJAQAAAA==.',
['动物']='动物园牛总:BAAALgAFFAEJAQAAAA==.',
['吉尔']='吉尔伽美什神:BAAALgADCgQJBQAAAA==.',
['吾系']='吾系菜菜子:BAACLgAFFH8FAAIBAAIJlxQlOACrAAABAAIJlxQlOACrAAAuAAQKfxoAAgEACQnPIHMPACEDAAEACQnPIHMPACEDAAAA.',
['哭泣']='哭泣的维纳斯:BAACLgAFFH8FAAIGAAMJ5wXNDABSAAAGAAMJ5wXNDABSAAAuAAQKfxYAAgYABwl7DftCAGwBAAYABwl7DftCAGwBAAAA.',
['埃克']='埃克佐迪亚:BAAALgADCgYJBgAAAA==.',
['基拉']='基拉的怒火:BAAALgAECgUJCQAAAA==.',
['基里']='基里连科:BAAALgADCgIJAgAAAA==.',
['墨翼']='墨翼丶幽澜:BAAALgAFFAMJAwABLgAFFAQJAgAHAAAAAA==.',
['奶个']='奶个锤子:BAAALgAECgEJAQAAAA==.',
['奶蓟']='奶蓟草:BAAALgAECgYJCwAAAA==.',
['安度']='安度克拉伯爵:BAAALgADCgcJBwAAAA==.',
['定风']='定风波:BAAALgAECgYJCgAAAA==.',
['宴清']='宴清都:BAABLgAFFH8HAAIFAAMJ9iJEDwAuAQAFAAMJ9iJEDwAuAQAAAA==.',
['小宇']='小宇:BAAALgAECgMJAwAAAA==.',
['小小']='小小鱼碗里来:BAABLgAFFH8FAAIIAAUJpBUAAAAAAAAJAAUJpBUAAAAAAAAAAA==.',
['小母']='小母牛不下崽:BAAALgAECggJCAAAAA==.',
['小糊']='小糊涂仙丶:BAAALgAECgQJBQAAAA==.',
['尾巴']='尾巴控:BAAALgAFFAEJAQAAAA==.',
['山木']='山木有枝:BAAALgAECgQJAwAAAA==.',
['师姐']='师姐救我:BAAALgAECgcJBwAAAA==.',
['御坂']='御坂美琴丶:BAAALgAECgcJDAAAAA==.',
['心橙']='心橙自由:BAAALgAECgcJDQAAAA==.',
['恩赐']='恩赐解脱:BAAALgAECgcJCAAAAA==.',
['我有']='我有神经冰:BAACLgAFFH8LAAIEAAQJlAx5HgBQAQAEAAQJlAx5HgBQAQAuAAQKfx0AAgQACAnTG4c6AIwCAAQACAnTG4c6AIwCAAAA.',
['拔毛']='拔毛炖鸡骑:BAAALgADCgMJAwAAAA==.',
['拿得']='拿得起放得下:BAAALgAECgcJCQAAAA==.',
['断水']='断水流:BAAALgADCgYJBgAAAA==.',
['暴走']='暴走小学生:BAAALgAFFAIJAgABLgAFFAMJBwABAJ8hAA==.暴走练习生:BAAALgAECgUJCQABLgAFFAMJBwABAJ8hAA==.',
['术业']='术业有专攻:BAAALgADCgEJAQAAAA==.',
['枕香']='枕香肩尝朱唇:BAAALgAFFAQJBAAAAA==.',
['柔蛋']='柔蛋葱鸡:BAAALgAFFAEJAQAAAA==.',
['桖銫']='桖銫坆瓌韓:BAAALgADCgQJBQAAAA==.',
['樱桃']='樱桃小奶狗:BAAALgAECgQJBAAAAA==.',
['步虚']='步虚声:BAAALgAECgQJCwAAAA==.',
['浣溪']='浣溪沙:BAAALgAECgcJBwABLgAFFAMJBwAFAPYiAA==.',
['清歌']='清歌:BAAALgAECgMJAwAAAA==.',
['滚滚']='滚滚:BAACLgAFFH8GAAIKAAIJYBmtFQCqAAAKAAIJYBmtFQCqAAAuAAQKfx0AAgoABwlMGrElAP0BAAoABwlMGrElAP0BAAAA.',
['王得']='王得財:BAAALgADCgUJBQAAAA==.',
['瑪惹']='瑪惹乏課:BAAALgADCgYJBgAAAA==.',
['甜甜']='甜甜的糖:BAAALgAECgMJAwAAAA==.',
['碎樰']='碎樰镜:BAAALgAECgUJCAAAAA==.',
['碎雪']='碎雪镜:BAAALgADCgUJBgAAAA==.',
['神棍']='神棍:BAAALgAFFAEJAQAAAA==.',
['神秘']='神秘巨星:BAAALgADCgcJCAAAAA==.',
['神马']='神马都是浮云:BAAALgAECgUJBQAAAA==.',
['笑红']='笑红尘:BAAALgAECgUJBQAAAA==.',
['绮葛']='绮葛龙丶苳蔷:BAAALgADCgYJBgAAAA==.',
['羊美']='羊美娜斯:BAACLgAFFH8IAAMLAAMJURgtBwD+AAALAAMJmxMtBwD+AAAJAAIJUx1zKwDCAAAuAAQKfxcABAsABwkCHzQLAA0CAAsABgmPIDQLAA0CAAkABAnmG8DWAKwAAAwAAQmeAsM3ACAAAAAA.',
['胸毛']='胸毛君:BAABLgAECn8WAAMNAAcJjRh5IQCpAQANAAcJjRh5IQCpAQAOAAQJ+Aa/bgCHAAAAAA==.',
['艾希']='艾希礼:BAAALgAECgUJDQAAAA==.',
['蛮横']='蛮横冲:BAAALgAECgYJCwAAAA==.',
['血珊']='血珊瑚:BAABLgAECn8VAAIEAAcJbiInLwC2AgAEAAcJbiInLwC2AgAAAA==.',
['贼法']='贼法四代:BAAALgAECgUJBQAAAA==.',
['轩辕']='轩辕嗜血:BAAALgAFFAEJAQAAAA==.',
['还是']='还是不够黑:BAAALgADCgkJCwAAAA==.',
['那又']='那又咋了:BAAALgAECgYJBgAAAA==.',
['重启']='重启之增辉龙:BAAALgAFFAIJAgABLgAFFAMJCAABAEkOAA==.',
['阿尔']='阿尔托莉雅丶:BAAALgAECgYJDgAAAA==.',
['陈大']='陈大锤:BAAALgAECgYJCQAAAA==.',
['高野']='高野兰子:BAAALgAECgYJCgAAAA==.',
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
