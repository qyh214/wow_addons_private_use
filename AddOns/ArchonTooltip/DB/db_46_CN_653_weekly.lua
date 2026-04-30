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

local lookup = {'Hunter-BeastMastery','Unknown-Unknown','Paladin-Retribution','Rogue-Subtlety','Warlock-Demonology','DemonHunter-Devourer',}
local provider = {region='CN',realm='安格博达',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bi='Biubiubiuu:BAABLgAFFH8GAAIBAAMJzhcEDQCyAAABAAMJzhcEDQCyAAAAAA==.',
El='Elementer:BAAALgAECgEJAQAAAA==.Elf:BAAALgAECgQJBAAAAA==.Ellend:BAAALgAECgcJEAAAAA==.',
Fr='Frostrange:BAAALgADCgIJAgAAAA==.',
Se='Seraph:BAAALgAECgQJCQAAAA==.',
['一撮']='一撮毛:BAAALgAECgEJAQAAAA==.',
['不灭']='不灭幽灵:BAAALgAECgMJAwABLgAECgMJAwACAAAAAA==.',
['东皇']='东皇丶新一:BAAALgADCgkJDgAAAA==.',
['丨灵']='丨灵愈者丨:BAAALgAECgkJCQAAAA==.',
['丶三']='丶三嵗:BAAALgADCgEJAQAAAA==.',
['丶仨']='丶仨嵗:BAAALgAECgYJCQAAAA==.',
['人生']='人生若只初见:BAAALgAECggJEwAAAA==.',
['亿粒']='亿粒蛋:BAAALgAECgEJAQAAAA==.',
['仅次']='仅次于狼:BAAALgAECgcJEAAAAA==.',
['信灬']='信灬仰:BAAALgAECgEJAQAAAA==.',
['光之']='光之印记:BAAALgAECgEJAQAAAA==.',
['光明']='光明:BAAALgADCgcJBwAAAA==.',
['光辉']='光辉之翼:BAAALgADCgIJAgAAAA==.',
['凌芯']='凌芯雪:BAAALgAECggJCAAAAA==.',
['喵了']='喵了个喵:BAAALgAECgEJAQAAAA==.',
['噜噜']='噜噜:BAAALgAECgcJBwAAAA==.',
['因帅']='因帅判七年:BAAALgAECgYJCQAAAA==.',
['埃琳']='埃琳娜:BAAALgADCgQJBAAAAA==.',
['大剑']='大剑:BAAALgADCgYJBgAAAA==.',
['奶奶']='奶奶儿丷:BAAALgAECgEJAQAAAA==.',
['守望']='守望寂寞:BAAALgAECgEJAgAAAA==.',
['安舞']='安舞格枫:BAAALgAECgEJAQAAAA==.',
['巴斯']='巴斯光年:BAAALgADCgIJAgAAAA==.',
['常威']='常威与来福:BAAALgAECgUJBQAAAA==.',
['怡红']='怡红院花主任:BAAALgAFFAIJAwAAAA==.',
['恩赐']='恩赐解灬脱:BAAALgAECgIJAgAAAA==.',
['我的']='我的易兰:BAAALgADCgYJBgAAAA==.',
['我超']='我超凶的:BAAALgADCgMJAwAAAA==.',
['折耳']='折耳猫:BAAALgAECgQJBAAAAA==.',
['故里']='故里:BAAALgADCgMJAwAAAA==.',
['无敌']='无敌表哥:BAAALgAECgQJBwAAAA==.',
['李欢']='李欢喜:BAAALgAECgQJBAAAAA==.',
['杠杠']='杠杠地:BAAALgAECgEJAQAAAA==.',
['杠牛']='杠牛奶:BAAALgAECgYJBgAAAA==.',
['杰森']='杰森牛坦森:BAAALgAECgEJAgAAAA==.',
['枕月']='枕月而眠:BAAALgAECgYJDQAAAA==.',
['林薇']='林薇薇:BAAALgAECgYJEAAAAA==.',
['柔情']='柔情猫娘:BAAALgADCgYJBgAAAA==.',
['框框']='框框:BAAALgAECgYJBgAAAA==.',
['梅川']='梅川酷滋:BAABLgAECn8WAAIDAAgJ5hopOQA+AgADAAgJ5hopOQA+AgAAAA==.',
['泡灬']='泡灬僧叁拾肆:BAAALgAFFAQJAQAAAA==.泡灬僧贰拾伍:BAAALgAFFAQJAgABLgAFFAUJAQACAAAAAA==.泡灬僧贰拾叁:BAAALgAFFAQJAgABLgAFFAUJAQACAAAAAA==.泡灬僧贰拾壹:BAAALgAFFAUJAQAAAA==.泡灬僧贰拾肆:BAAALgAFFAQJAgABLgAFFAUJAQACAAAAAA==.',
['活的']='活的很好:BAAALgAFFAIJAgAAAA==.',
['牛鼻']='牛鼻子老道:BAAALgADCgUJBQABLgAECgMJAwACAAAAAA==.',
['琴声']='琴声细雨:BAAALgADCgYJBgAAAA==.',
['瘸子']='瘸子的好腿:BAAALgAECgEJAgAAAA==.',
['腹肌']='腹肌磨马甲线:BAAALgADCgEJAQAAAA==.',
['蕾娜']='蕾娜娅:BAABLgAECn8YAAIEAAYJRhyrIgDjAQAEAAYJRhyrIgDjAQAAAA==.',
['薇笑']='薇笑星宸:BAAALgAECgYJBgAAAA==.',
['谜谜']='谜谜米:BAABLgAFFH8FAAIFAAIJgw5MOQChAAAFAAIJgw5MOQChAAAAAA==.',
['迷帝']='迷帝古茶:BAAALgAECgcJDQAAAA==.',
['鈊茽']='鈊茽絠術:BAAALgAECgYJDwAAAA==.',
['雪无']='雪无言:BAAALgADCgIJAgAAAA==.',
['雷军']='雷军:BAAALgAECgYJDQAAAA==.',
['霞月']='霞月紫灵:BAAALgAECgQJBwAAAA==.',
['魅影']='魅影一紫青:BAAALgAECgEJAQAAAA==.魅影梦魇:BAAALgAECgEJAQAAAA==.',
['魔弓']='魔弓手:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法披风:BAABLgAFFH8HAAIGAAMJmRmeGAALAQAGAAMJmRmeGAALAQAAAA==.',
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
