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
 local lookup = {'Paladin-Protection','Paladin-Retribution','Priest-Holy','Priest-Discipline','Warrior-Arms','Mage-Frost','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','DemonHunter-Havoc','Monk-Windwalker','Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Paladin-Holy','Shaman-Restoration',}; local provider = {region='CN',realm='瓦丝琪',name='CN',type='weekly',zone=42,date='2025-08-08',data={Em='Emo:BAAAKgAECgYIBgAAAA==.',Fo='Foever:BAAAKgAECgMIAwAAAA==.Forevernight:BAAAKgAECgQIBAAAAA==.',La='Lash:BAAAKgAECgYIBgAAAA==.',Vi='Violent:BAAAKgAECgUIBQAAAA==.',['不朽']='不朽之王:BAAAKgAECgQIBAAAAA==.',['丨眼']='丨眼眸丨:BAABKgAFFH8NAAMBAAYI9BQACwBJAQABAAYI9BQACwBJAQACAAEIHQjKXgAwAAAAAA==.',['乳玉']='乳玉皇妃:BAAAKgADCgEIAQAAAA==.',['体育']='体育生:BAAAKgAECgEIAQAAAA==.',['你狐']='你狐吗:BAABKgAECn8gAAMDAAgIlCFSDABzAgADAAgIFyFSDABzAgAEAAgIlhroFAD3AQAAAA==.',['养什']='养什么死什么:BAAAKgADCgUIBQAAAA==.',['冰霜']='冰霜:BAAAKgAECgUIBgAAAA==.',['冷傲']='冷傲孤狂:BAABKgAFFH8IAAIFAAgIawj3BQDCAQAFAAgIawj3BQDCAQAAAA==.',['劈头']='劈头士帅牛:BAAAKgAFFAIIAwAAAA==.',['卡斯']='卡斯特:BAAAKgAECgcIBwAAAA==.',['叫我']='叫我各种纠结:BAAAKgADCgMIAwAAAA==.',['嗯我']='嗯我知道了:BAAAKgADCggICAAAAA==.',['嚼子']='嚼子:BAAAKgADCgIIBAAAAA==.',['因盗']='因盗被抓:BAAAKgADCgEIAQAAAA==.',['圣光']='圣光忽悠悠:BAAAKgAFFAIIAgAAAA==.圣光涌动:BAAAKgADCgEIAQAAAA==.',['壹眯']='壹眯灬陽銧:BAAAKgAECgMIAwAAAA==.',['复仇']='复仇女神:BAAAKgAECgEIAQAAAA==.',['奥拉']='奥拉:BAAAKgADCggICAAAAA==.',['妖妖']='妖妖:BAABKgAFFH8IAAIGAAMI7wdzEgBpAAAGAAMI7wdzEgBpAAAAAA==.',['妞妞']='妞妞的一天:BAABKgAFFH8FAAIGAAMIwQ3pFwC2AAAGAAMIwQ3pFwC2AAAAAA==.',['小痴']='小痴躲猫猫:BAABKgAFFH8HAAMHAAYIHR1FDgB5AQAHAAYI1xlFDgB5AQAIAAEIAiTRQQBaAAAAAA==.',['怪叁']='怪叁叔:BAAAKgAECgUIDAAAAA==.',['怪贰']='怪贰嫂:BAAAKgAFFAEIAQAAAA==.怪贰爺:BAAAKgADCggIDAAAAA==.',['怪骑']='怪骑骑:BAAAKgAECgIIAgAAAA==.',['怪龍']='怪龍龍:BAAAKgADCgMIAwAAAA==.',['怪龖']='怪龖龖:BAAAKgADCgcIDQAAAA==.',['愤怒']='愤怒的豆豆:BAAAKgAECgUIDwAAAA==.',['放开']='放开那根竹子:BAAAKgADCgcIBwAAAA==.',['放弃']='放弃治疗速死:BAAAKgAECggICAAAAA==.',['斧刃']='斧刃:BAAAKgAECgIIAgAAAA==.',['无人']='无人在念:BAAAKgAECgYICwAAAA==.',['无双']='无双:BAAAKgAECgIIAgAAAA==.',['无心']='无心的航海:BAAAKgAFFAIIAgABKgAFFAgIGAAJAKUbAA==.',['无粒']='无粒丹:BAABKgAECn8iAAIKAAgIHSOtBwDRAgAKAAgIHSOtBwDRAgAAAA==.',['氵昆']='氵昆血儿灬:BAAAKgAECgYIBgAAAA==.',['潇潇']='潇潇:BAAAKgAFFAMIAwAAAA==.',['牧殇']='牧殇小痴:BAABKgAFFH8GAAICAAYIXhmCHgB3AQACAAYIXhmCHgB3AQAAAA==.',['猫猫']='猫猫咪呀:BAABKgAECn8YAAILAAgIWhuCBQBXAgALAAgIWhuCBQBXAgAAAA==.',['王者']='王者的叹息:BAAAKgAECgIIAgAAAA==.',['玛卡']='玛卡巴卡卜:BAAAKgAFFAEIAQAAAA==.',['珍丶']='珍丶珠:BAAAKgAECggICAAAAA==.',['瑞思']='瑞思拜丶:BAAAKgADCgYIBgAAAA==.',['田甜']='田甜:BAAAKgAECgYICQAAAA==.',['白银']='白银之爹:BAAAKgAECgUICQAAAA==.',['皎玥']='皎玥玥:BAAAKgAECgMIAwAAAA==.',['碱水']='碱水丨魔芋爽:BAABKgAECn8aAAMMAAgIjBgAGADAAQAMAAgIThYAGADAAQANAAYI0BfhUwAZAQAAAA==.',['祐天']='祐天寺若麦:BAABKgAFFH8FAAIOAAUIwBqnEQA3AQAOAAUIwBqnEQA3AQAAAA==.',['美少']='美少女丶壮士:BAAAKgAECgUICAAAAA==.',['美式']='美式:BAAAKgAFFAEIAQAAAA==.',['老子']='老子是输出:BAAAKgAECgcICwAAAA==.',['老李']='老李七号:BAACKgAFFH8UAAIDAAQIHxleHQDWAAADAAQIHxleHQDWAAAqAAQKfxQAAwMABwg2F9oqAH8BAAMABwg2F9oqAH8BAAQAAgjlCppzAEgAAAAA.老李五号:BAABKgAFFH8LAAIPAAQIfgQuFQCOAAAPAAQIfgQuFQCOAAAAAA==.老李六号:BAACKgAFFH8oAAIQAAQIFh0iEgDpAAAQAAQIFh0iEgDpAAAqAAQKfxoAAhAACAg2HoYVAEcCABAACAg2HoYVAEcCAAAA.',['草莓']='草莓:BAABKgAECn8gAAICAAgIch8aKgBXAgACAAgIch8aKgBXAgAAAA==.',['菊花']='菊花棒棒糖:BAABKgAFFH8HAAIKAAYI2xbiOwCOAAAKAAYI2xbiOwCOAAAAAA==.',['蓋爾']='蓋爾加朵花花:BAAAKgAECggICAAAAA==.',['蛋刀']='蛋刀在哪里:BAAAKgAECgYIBgAAAA==.',['见南']='见南山:BAABKgAFFH8GAAIJAAYILQpyDAA+AQAJAAYILQpyDAA+AQAAAA==.',['超妹']='超妹儿:BAAAKgAECgIIAgAAAA==.',['距离']='距离感没:BAAAKgADCgQIBAAAAA==.',['轻夜']='轻夜:BAAAKgAECgYICAAAAA==.',['送葬']='送葬的霍霍:BAAAKgAECgMIBAAAAA==.',['阿吉']='阿吉娜:BAAAKgADCgIIAgAAAA==.',['随风']='随风而行:BAAAKgAECgIIAQAAAA==.',['雪纳']='雪纳瑞:BAAAKgAECgYICAAAAA==.',['飙车']='飙车男:BAAAKgAECgUIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end