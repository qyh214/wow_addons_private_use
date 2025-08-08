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
 local lookup = {'DemonHunter-Havoc','DeathKnight-Unholy','Rogue-Assassination','Unknown-Unknown','Priest-Holy','Shaman-Restoration','Shaman-Enhancement','DemonHunter-Vengeance','Hunter-Marksmanship','Monk-Windwalker','Warlock-Destruction','Paladin-Retribution','Hunter-BeastMastery',}; local provider = {region='CN',realm='埃基尔松',name='CN',type='weekly',zone=42,date='2025-08-08',data={Gt='Gto:BAACKgAFFH8IAAIBAAQIEAtzHADTAAABAAQIEAtzHADTAAAqAAQKfxgAAgEACAgvIFYVAIYCAAEACAgvIFYVAIYCAAEqAAUUCAgMAAIA9REA.',Ko='Kotori:BAAAKgAFFAQIBAAAAA==.',Sa='Salt:BAABKgAFFH8XAAIDAAYILCClAQDAAQADAAYILCClAQDAAQABKgAFFAgIAwAEAAAAAA==.',['一起']='一起冲丶:BAAAKgAECgIIAgAAAA==.',['上膛']='上膛的紫蛋:BAAAKgAECgIIAgAAAA==.',['低保']='低保真叽叭黑:BAAAKgAFFAQIBAAAAA==.',['俄罗']='俄罗斯大狗熊:BAABKgAFFH8GAAIFAAYIxhYBCQBOAQAFAAYIxhYBCQBOAQAAAA==.',['功夫']='功夫茶:BAAAKgAECgYIBgAAAA==.',['取名']='取名字好难:BAABKgAECn8VAAIGAAgI7h/RGAAzAgAGAAgI7h/RGAAzAgAAAA==.',['吉尔']='吉尔加蛋:BAABKgAFFH8SAAMGAAYIKCBMDACFAQAGAAYIKCBMDACFAQAHAAYIERiEBwBrAQAAAA==.',['咆哮']='咆哮地狱:BAAAKgAECgMIBgAAAA==.',['天外']='天外飞仙:BAABKgAFFH8GAAIIAAYINBV1BwApAQAIAAYINBV1BwApAQAAAA==.',['小飞']='小飞机:BAACKgAFFH8WAAIJAAcI2BqACQDAAQAJAAcI2BqACQDAAQAqAAQKfx0AAgkACAigII0PAFoCAAkACAigII0PAFoCAAAA.',['小鱼']='小鱼:BAAAKgAECgQIBAAAAA==.',['快乐']='快乐向前冲:BAABKgAFFH8GAAIKAAYIZAv0CQBFAQAKAAYIZAv0CQBFAQAAAA==.',['我可']='我可爱吗:BAAAKgAECgYICAAAAA==.',['我见']='我见过帝师:BAABKgAFFH8IAAILAAgI3wjDDAC/AQALAAgI3wjDDAC/AQAAAA==.',['无情']='无情铁手:BAAAKgAFFAEIAQAAAA==.',['晴天']='晴天无敌牛牛:BAAAKgADCgMIAwAAAA==.',['月归']='月归尘:BAAAKgADCgEIAQAAAA==.',['欢宝']='欢宝:BAAAKgADCgQIAQAAAA==.',['武道']='武道尊者:BAAAKgADCgUIBQAAAA==.',['歼击']='歼击丶基:BAAAKgAECgQIBQAAAA==.',['江湖']='江湖豪哥兽猎:BAAAKgAFFAMIAwAAAA==.',['泰十']='泰十七:BAAAKgADCgEIAQAAAA==.',['狗哥']='狗哥牛批:BAAAKgAECgEIAQAAAA==.',['秋夜']='秋夜江晚吟:BAAAKgADCgEIAQAAAA==.',['空白']='空白的记忆:BAAAKgADCgEIAgAAAA==.',['给你']='给你扒个蒜:BAAAKgAFFAIIAgAAAA==.',['美丽']='美丽的太阳:BAAAKgAECgMIBwAAAA==.',['走向']='走向光明:BAAAKgAFFAgIBAAAAA==.',['转转']='转转二手上门:BAAAKgAECggICAAAAA==.',['运满']='运满乾坤:BAAAKgAECgYIBgAAAA==.',['远程']='远程停手:BAAAKgAECgYIBgAAAA==.',['速度']='速度与馕:BAAAKgAFFAIIAgAAAA==.',['镁铝']='镁铝:BAAAKgAECggICQAAAA==.',['长胡']='长胡子的大叔:BAABKgAFFH8GAAIMAAYIxAwPJgBRAQAMAAYIxAwPJgBRAQAAAA==.',['陈十']='陈十一:BAABKgAFFH8IAAICAAgIzAicCACzAQACAAgIzAicCACzAQAAAA==.',['雲和']='雲和山的彼端:BAABKgAFFH8HAAINAAYI8Q37FwA6AQANAAYI8Q37FwA6AQAAAA==.',['霜降']='霜降:BAAAKgADCggICAAAAA==.',['骑士']='骑士快跑:BAAAKgAFFAIIAgAAAA==.',['黛西']='黛西的姐姐:BAAAKgAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end