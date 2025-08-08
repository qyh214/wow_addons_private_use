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
 local lookup = {'Warrior-Arms','Rogue-Assassination','Rogue-Subtlety','Paladin-Retribution','Paladin-Protection','Druid-Balance','Mage-Frost','Warrior-Fury','DemonHunter-Havoc','Hunter-BeastMastery','DemonHunter-Vengeance',}; local provider = {region='CN',realm='无底海渊',name='CN',type='weekly',zone=42,date='2025-08-08',data={Cx='Cxz:BAAAKgADCgMIBAAAAA==.',Du='Duoga:BAAAKgAECgYIBgAAAA==.',Lh='Lhycs:BAAAKgAECggICAAAAA==.',Mo='Mouda:BAAAKgAECgEIAQAAAA==.',Ne='Neway:BAAAKgAFFAQIBAABKgAFFAgICgABAMsaAA==.',Nu='Nuroda:BAACKgAFFH8HAAMCAAMIzwSiDwC1AAACAAMIRASiDwC1AAADAAEIbQMpEwA5AAAqAAQKfxgAAwMACAjND8IZAGIBAAMACAgVDsIZAGIBAAIAAwi6CZg9AGwAAAAA.',Sa='Satorisama:BAACKgAFFH8ZAAIEAAQIFCHsMQAhAQAEAAQIFCHsMQAhAQAqAAQKfzoAAwQACAgwJJsZAJ8CAAQACAgwJJsZAJ8CAAUABQjkGK8sAPQAAAAA.',['不会']='不会玩小德:BAABKgAFFH8GAAIGAAQI0gycHgC8AAAGAAQI0gycHgC8AAAAAA==.不会玩的选手:BAACKgAFFH8RAAIEAAYICBmZFwCgAQAEAAYICBmZFwCgAQAqAAQKfyYAAgQACAjGJGMQANYCAAQACAjGJGMQANYCAAAA.',['八风']='八风糖:BAAAKgAFFAEIAQAAAA==.',['凯恩']='凯恩凯恩:BAAAKgAECggICwAAAA==.',['发财']='发财的这周三:BAABKgAFFH8IAAIEAAgIiBVwCAAoAgAEAAgIiBVwCAAoAgAAAA==.',['咖喱']='咖喱焖面:BAABKgAECn8eAAIEAAgIIxkeawDDAQAEAAgIIxkeawDDAQAAAA==.',['墨渊']='墨渊:BAAAKgAECgEIAQAAAA==.',['奶少']='奶少:BAAAKgAECggIEAAAAA==.',['实实']='实实在在:BAAAKgAECgIIAgAAAA==.',['小娇']='小娇娇:BAAAKgAECgcIAQAAAA==.',['小煜']='小煜:BAABKgAECn8YAAIHAAgI2BS9IACsAQAHAAgI2BS9IACsAQAAAA==.',['小王']='小王大:BAAAKgAECgMIAwAAAA==.',['小黄']='小黄人:BAABKgAFFH8IAAIIAAgI9gCdFQC3AAAIAAgI9gCdFQC3AAAAAA==.',['心有']='心有霖希:BAAAKgAECgYIDgAAAA==.',['扬煤']='扬煤土汽:BAAAKgADCgYIBgAAAA==.',['数数']='数数然:BAAAKgADCggICAAAAA==.数数然四:BAABKgAFFH8IAAIEAAgI9Q6XCgD7AQAEAAgI9Q6XCgD7AQAAAA==.',['残月']='残月:BAABKgAFFH8GAAIJAAQIyBBsMAC8AAAJAAQIyBBsMAC8AAAAAA==.',['烟渚']='烟渚寒:BAABKgAFFH8GAAIEAAYIcwvOLgAtAQAEAAYIcwvOLgAtAQABKgAFFAgIHQAFAHkbAA==.',['狂人']='狂人之和:BAAAKgAFFAQIBAAAAA==.',['独孤']='独孤小生:BAABKgAECn8VAAIKAAgIDh5rIgBrAgAKAAgIDh5rIgBrAgAAAA==.',['瓦伦']='瓦伦蒂娜:BAAAKgAECggIDQAAAA==.',['瓦王']='瓦王乌瑞恩丶:BAAAKgAECggIDgAAAA==.',['秋晚']='秋晚:BAABKgAFFH8GAAIEAAYIHxsbGgCPAQAEAAYIHxsbGgCPAQAAAA==.',['红手']='红手月:BAAAKgAECggICQAAAA==.',['绯红']='绯红:BAAAKgAECgEIAQAAAA==.',['腰板']='腰板直了:BAAAKgAECggIDwAAAA==.',['色孽']='色孽的圣光:BAAAKgAECgEIAQAAAA==.',['被遗']='被遗忘的隐者:BAAAKgAECgUIBQAAAA==.',['说不']='说不德丶:BAAAKgAFFAgIBAAAAA==.',['豆子']='豆子:BAAAKgADCgUIBQAAAA==.',['豆角']='豆角焖面:BAAAKgAECgIIAgAAAA==.',['贱射']='贱射特:BAAAKgAFFAQIBAAAAA==.',['通灵']='通灵妞妞:BAAAKgAECgQIBAAAAA==.',['阡若']='阡若:BAABKgAFFH8IAAIHAAgIlQiSBACIAQAHAAgIlQiSBACIAQAAAA==.',['飞机']='飞机场奶妈:BAAAKgADCgcIBwAAAA==.',['香肠']='香肠:BAAAKgADCgEIAQAAAA==.',['魔法']='魔法少女品红:BAABKgAECn8YAAMLAAgIpBcTCADdAQALAAgIzRYTCADdAQAJAAgIexMrMQCZAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end