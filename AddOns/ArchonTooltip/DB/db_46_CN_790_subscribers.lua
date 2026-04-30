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

local lookup = {'Mage-Frost','Monk-Mistweaver','DeathKnight-Blood','Mage-Fire','Shaman-Restoration','Shaman-Elemental','Monk-Brewmaster','Unknown-Unknown','Rogue-Subtlety','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','DeathKnight-Frost','Evoker-Preservation','Evoker-Augmentation','Paladin-Retribution','Rogue-Assassination',}
local provider = {region='CN',realm='罗宁',name='CN',type='subscribers',zone=46,date='2026-04-25',data={Ae='Aegwynne:BAEALgAFFAEJAQABLgAFFAQJBgABALASAA==.',
Bu='Bushnell:BAEALgAFFAQJBAABLgAFFAQJBgABALASAA==.',
Cl='Clorislol:BAEBLgAECn8VAAIBAAkJ+CLPAABJAwloDAAAAgBeAGkMAAACAFcAawwAAAMAWwBqDAAAAwBjAGwMAAADAFcAbQwAAAMAYwDqDAAAAwBfAG4MAAABAGAAbwwAAAEAPwABAAkJ+CLPAABJAwloDAAAAgBeAGkMAAACAFcAawwAAAMAWwBqDAAAAwBjAGwMAAADAFcAbQwAAAMAYwDqDAAAAwBfAG4MAAABAGAAbwwAAAEAPwABLgAFFAQJBwABAOMlAA==.',
Co='Colaad:BAEALgADCgcJBwABLgAFFAQJBgABALASAA==.Colaas:BAEALgAFFAEJAQABLgAFFAQJBgABALASAA==.Colae:BAEALgAFFAIJAgABLgAFFAQJBgABALASAA==.Colag:BAEALgAECgcJBwABLgAFFAQJBgABALASAA==.Colai:BAEALgAECggJCAABLgAFFAQJBgABALASAA==.Colamage:BAECLgAFFH8GAAIBAAQJsBKMCgBeAQRoDAAAAwA1AGkMAAABACUAawwAAAEAFQDqDAAAAQBPAAEABAmwEowKAF4BBGgMAAADADUAaQwAAAEAJQBrDAAAAQAVAOoMAAABAE8ALgAECn93AAIBAAkJqCEWKQDOAgABAAkJqCEWKQDOAgAAAA==.Colaq:BAEALgAECgkJCQABLgAFFAQJBgABALASAA==.Colasa:BAEALgAFFAIJAgABLgAFFAQJBgABALASAA==.Colat:BAEBLgAFFH8FAAIBAAMJXg1/GQD2AANoDAAAAgAfAGsMAAABABIA6gwAAAIANQABAAMJXg1/GQD2AANoDAAAAgAfAGsMAAABABIA6gwAAAIANQABLgAFFAQJBgABALASAA==.Colau:BAEALgAECgkJCQABLgAFFAQJBgABALASAA==.Colaw:BAEALgAECgkJEAABLgAFFAQJBgABALASAA==.Colay:BAEALgAFFAIJAgABLgAFFAQJBgABALASAA==.',
De='Destiniess:BAEALgAFFAEJAQABLgAFFAQJBgABALASAA==.',
Et='Eternalmage:BAEALgAECgcJCgABLgAFFAQJBgABALASAA==.',
Fa='Fattyseal:BAEALgAFFAEJAQABLgAFFAYJCwACAFcbAA==.',
Fl='Flamage:BAEALgAECggJCQABLgAFFAQJBgABALASAA==.',
Fr='Fredpal:BAEALgADCgcJBwABLgAFFAUJEgADAFggAA==.',
Gr='Grimnar:BAEALgAFFAQJBAAAAA==.',
Ne='Nesteamage:BAECLgAFFH8RAAIBAAUJ3iSxBAAiAgVoDAAABQBjAGkMAAAFAGEAawwAAAMAYwBqDAAAAQBNAOoMAAADAFEAAQAFCd4ksQQAIgIFaAwAAAUAYwBpDAAABQBhAGsMAAADAGMAagwAAAEATQDqDAAAAwBRAC4ABAp/KAADAQAICaYlFQsAawMAAQAICaYlFQsAawMABAABCf0MYw8AOgAAAAA=.',
Re='Reallpcy:BAECLgAFFH8GAAIBAAIJliSWMgDVAAJoDAAAAwBgAOoMAAADAFoAAQACCZYkljIA1QACaAwAAAMAYADqDAAAAwBaAC4ABAp/FQACAQAHCYkfIyoAygIAAQAHCYkfIyoAygIAAS4ABRQHCRQAAQCSJAA=.',
Sn='Snowmage:BAEALgAECgMJAwABLgAFFAQJBgABALASAA==.',
Tt='Ttmage:BAEALgAECgcJBwABLgAFFAQJBgABALASAA==.',
Tu='Turbomage:BAEALgAFFAIJAgABLgAFFAQJBgABALASAA==.',
['下水']='下水道萨满:BAECLgAFFH8TAAIFAAUJ+hxBAwClAQVoDAAABQBUAGkMAAAFAFYAawwAAAMAOABqDAAAAQA8AOoMAAAFAFIABQAFCfocQQMApQEFaAwAAAUAVABpDAAABQBWAGsMAAADADgAagwAAAEAPADqDAAABQBSAC4ABAp/LwADBQAICTQkNwQAMQMABQAICTQkNwQAMQMABgACCVohJW8AhgAAAAA=.',
['丶咲']='丶咲僧丿:BAEALgAECgkJCQAAAA==.',
['九千']='九千七丶术:BAEALgAECgUJDwABLgAECgcJJAAHAM8lAA==.',
['云烟']='云烟成雨丨:BAECLgAFFH8VAAIBAAYJSyNQAgBrAgZoDAAABQBgAGkMAAAEAGMAawwAAAQATABqDAAAAwBNAGwMAAACAGAA6gwAAAMAUwABAAYJSyNQAgBrAgZoDAAABQBgAGkMAAAEAGMAawwAAAQATABqDAAAAwBNAGwMAAACAGAA6gwAAAMAUwAuAAQKfysAAgEACQlTJskAAPcDAAEACQlTJskAAPcDAAAA.',
['哥布']='哥布宁:BAECLgAFFH8SAAIHAAUJsCLnAQDmAQVoDAAABQBdAGkMAAAEAFMAawwAAAMAVQBqDAAAAgBPAOoMAAAEAFwABwAFCbAi5wEA5gEFaAwAAAUAXQBpDAAABABTAGsMAAADAFUAagwAAAIATwDqDAAABABcAC4ABAp/IgACBwAJCUwjgAEAlwMABwAJCUwjgAEAlwMAAAA=.',
['嘿冷']='嘿冷静丶:BAEALgAECgcJDQABLgAFFAQJBgABALASAA==.',
['夕年']='夕年半夏:BAEALgAFFAIJBAABLgAFFAQJBAAIAAAAAA==.',
['夜寻']='夜寻安:BAEBLgAFFH8IAAIJAAQJOhgEBwBwAQRoDAAAAgBFAGkMAAACACcAawwAAAIAPQDqDAAAAgBNAAkABAk6GAQHAHABBGgMAAACAEUAaQwAAAIAJwBrDAAAAgA9AOoMAAACAE0AAAA=.',
['姜糖']='姜糖小饼干:BAECLgAFFH8SAAIGAAUJ/yECAgDuAQVoDAAABABbAGkMAAADAFQAawwAAAMATABqDAAAAwBgAOoMAAAFAF8ABgAFCf8hAgIA7gEFaAwAAAQAWwBpDAAAAwBUAGsMAAADAEwAagwAAAMAYADqDAAABQBfAC4ABAp/HQACBgAJCaslTQEAtwMABgAJCaslTQEAtwMAAAA=.',
['安妮']='安妮宝贝:BAEALgAECgMJAwABLgAFFAIJAwAIAAAAAA==.',
['安蜜']='安蜜莉雅:BAECLgAFFH8SAAIKAAYJGCLuAABgAgZoDAAAAgBeAGkMAAAEAE0AawwAAAQATQBqDAAAAgBdAGwMAAABAFQA6gwAAAUAYQAKAAYJFyLuAABgAgZoDAAAAgBeAGkMAAAEAE0AawwAAAQATQBqDAAAAgBdAGwMAAABAFQA6gwAAAUAYQAuAAQKfyEAAwoACQklIa4HAMcCAAoACAkcHq4HAMcCAAsABwksGRUgAOEBAAAA.',
['对的']='对的对的:BAEALgAFFAIJBAABLgAFFAUJEgADAFggAA==.',
['封存']='封存的小菊花:BAECLgAFFH8SAAICAAYJ7hcLAgACAgZoDAAAAwBaAGkMAAAFADUAawwAAAIATQBqDAAAAwA8AGwMAAABAAwA6gwAAAQASQACAAYJ7hcLAgACAgZoDAAAAwBaAGkMAAAFADUAawwAAAIATQBqDAAAAwA8AGwMAAABAAwA6gwAAAQASQAuAAQKfxcAAgIACAkYIokFAAsDAAIACAkYIokFAAsDAAAA.',
['小王']='小王睡不醒:BAEALgAECgkJDgABLgAFFAQJBgABALASAA==.',
['小草']='小草狗:BAEALgAECgQJBAABLgAFFAUJEgAHALAiAA==.',
['影薇']='影薇:BAEBLgAECn8aAAMKAAkJERs3EgAjAgloDAAABAA5AGkMAAAEAEYAawwAAAMATwBqDAAABQBgAGwMAAADAFAAbQwAAAEANgDqDAAABABaAG4MAAABACoAbwwAAAEAMQAKAAYJBB83EgAjAgZoDAAABAA5AGkMAAADAEYAawwAAAMATwBqDAAABABgAGwMAAACAFAA6gwAAAQAWgALAAYJlxTLCQCIAQZpDAAAAQA+AGoMAAABAD8AbAwAAAEAKwBtDAAAAQA2AG4MAAABACoAbwwAAAEAMQABLgAECgcJHwAKAJUiAA==.',
['心雨']='心雨丶:BAEALgAFFAEJAQAAAA==.',
['心靈']='心靈之镜:BAEALgADCgEJAQABLgADCgMJAwAIAAAAAA==.',
['悖谬']='悖谬:BAEALgAECgkJBgABLgAFFAQJBgABALASAA==.',
['情诗']='情诗:BAEALgAECgkJCQABLgAFFAQJBgABALASAA==.',
['无星']='无星:BAECLgAFFH8SAAIDAAUJWCABAwCVAQVoDAAABQBaAGkMAAAEAFoAawwAAAMAPABqDAAAAQAwAOoMAAAFAFoAAwAFCVggAQMAlQEFaAwAAAUAWgBpDAAABABaAGsMAAADADwAagwAAAEAMADqDAAABQBaAC4ABAp/JwACAwAICYsi/gMAEgMAAwAICYsi/gMAEgMAAAA=.',
['无解']='无解肥丶:BAEBLgAFFH8HAAIMAAYJwxgHAgD8AQZoDAAAAQBVAGkMAAABAEcAawwAAAIAPgBqDAAAAQALAGwMAAABADQA6gwAAAEALQAMAAYJwxgHAgD8AQZoDAAAAQBVAGkMAAABAEcAawwAAAIAPgBqDAAAAQALAGwMAAABADQA6gwAAAEALQAAAA==.',
['暮色']='暮色半夏:BAEBLgAFFH8HAAMMAAMJ/xqrDwANAQNoDAAAAwBSAGkMAAABADwA6gwAAAMAQAAMAAMJ/xqrDwANAQNoDAAAAwBSAGkMAAABADwA6gwAAAIAQAANAAEJfATeAgBOAAHqDAAAAQALAAEuAAUUBAkEAAgAAAAA.',
['毒蔷']='毒蔷薇:BAEBLgAECn8fAAMKAAcJlSJHCAC6AgdoDAAABQBXAGkMAAAEAF0AawwAAAQAXgBqDAAABQBgAGwMAAAEAF4AbQwAAAMAPADqDAAABgBdAAoABwmVIkcIALoCB2gMAAAEAFcAaQwAAAMAXQBrDAAAAwBeAGoMAAAEAGAAbAwAAAMAXgBtDAAAAgA8AOoMAAAFAF0ACwAHCZsWgigArAEHaAwAAAEAAQBpDAAAAQAyAGsMAAABAD8AagwAAAEAWgBsDAAAAQBZAG0MAAABADUA6gwAAAEANwAAAA==.',
['游泳']='游泳体育生:BAEALgAECgEJBAABLgAFFAYJEgACAO4XAA==.',
['漆黒']='漆黒之牙:BAEALgADCgMJAwAAAA==.',
['灰烬']='灰烬大人:BAEALgADCgEJAQABLgADCgMJAwAIAAAAAA==.',
['烛翎']='烛翎:BAEBLgAFFH8NAAMOAAQJZRYpCQBXAQRoDAAABABIAGkMAAADABQAawwAAAIASQDqDAAABAA/AA4ABAllFikJAFcBBGgMAAACAEgAaQwAAAIAFABrDAAAAgBJAOoMAAACAD8ADwADCWAiXwwAOQEDaAwAAAIAVwBpDAAAAQBVAOoMAAACAFoAAAA=.',
['狂诗']='狂诗:BAEALgAFFAQJBAABLgAFFAQJBgABALASAA==.',
['猫耋']='猫耋:BAECLgAFFH8NAAIQAAUJdx+KAgDZAQVoDAAAAwBeAGkMAAADAFwAawwAAAMANgBqDAAAAQAbAOoMAAADAFEAEAAFCXcfigIA2QEFaAwAAAMAXgBpDAAAAwBcAGsMAAADADYAagwAAAEAGwDqDAAAAwBRAC4ABAp/GAACEAAJCRkl3QAA4QMAEAAJCRkl3QAA4QMAAAA=.',
['琉璃']='琉璃半夏:BAEALgAFFAQJBAAAAA==.',
['白毛']='白毛龙妈:BAEALgAECgEJAQABLgAFFAUJEwAFAPocAA==.',
['白色']='白色工具人:BAEALgAFFAMJAwAAAA==.',
['纸牛']='纸牛软软:BAEALgAFFAIJAwABLgAFFAUJEgAGAP8hAA==.',
['绯影']='绯影舞:BAEALgAECgYJBQAAAA==.',
['舞汐']='舞汐羽:BAEALgAFFAIJAwAAAA==.',
['苦尽']='苦尽甘來:BAEBLgAFFH8UAAMJAAYJRB1/AgDZAQZoDAAABABWAGkMAAAEAFQAawwAAAQAPQBqDAAAAwBiAGwMAAABAEcA6gwAAAQARgAJAAUJkR1/AgDZAQVoDAAABABWAGkMAAADAFQAawwAAAQAPQBqDAAAAQA9AOoMAAAEAEYAEQADCVEWGQIAJgEDaQwAAAEAKgBqDAAAAgBiAGwMAAABAEcAAAA=.',
['蕾茉']='蕾茉妮雅:BAECLgAFFH8VAAIHAAUJORXSBgBlAQVoDAAABQA5AGkMAAAEADIAawwAAAQANgBqDAAAAwAVAOoMAAAFADcABwAFCTkV0gYAZQEFaAwAAAUAOQBpDAAABAAyAGsMAAAEADYAagwAAAMAFQDqDAAABQA3AC4ABAp/JQADBwAJCVYdDwoA6AIABwAJCVYdDwoA6AIAAgAECRIHkRoAkwAAAAA=.',
['酒牧']='酒牧云:BAEALgAFFAQJBAAAAA==.',
['醋酱']='醋酱配卷饼:BAEALgAECggJEwAAAA==.',
['风灬']='风灬焰:BAEBLgAFFH8NAAMMAAQJiSZrAwDOAQRoDAAABABfAGkMAAADAGMAawwAAAIAYwDqDAAABABjAAwABAmJJmsDAM4BBGgMAAADAF8AaQwAAAIAYwBrDAAAAgBjAOoMAAADAGMADQADCVMk+AAASwEDaAwAAAEAXwBpDAAAAQBXAOoMAAABAF8AAAA=.',
['龍龙']='龍龙希尔:BAEALgAECgcJBgABLgAFFAcJDwAPAPsYAA==.',
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
