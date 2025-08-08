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
 local lookup = {'Rogue-Outlaw','Rogue-Assassination','Monk-Windwalker','Mage-Fire','Mage-Arcane','Mage-Frost','Monk-Mistweaver','Monk-Brewmaster','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Paladin-Retribution','Shaman-Restoration','Shaman-Elemental',}; local provider = {region='CN',realm='祖达克',name='CN',type='weekly',zone=42,date='2025-08-04',data={Hu='Hunger:BAACKgAFFH8JAAIBAAQIyyHsAgATAQABAAQIyyHsAgATAQAqAAQKfxcAAwEACAipIt8FABECAAEACAipIt8FABECAAIAAQgyEVtGAEYAAAEqAAUUCAgpAAMA6SMA.',La='Lanse:BAAAKgAFFAQIBAAAAA==.',Ma='Mageroysong:BAACKgAFFH8YAAMEAAgIaRytAQAVAgAFAAgIKRYpBQBRAgAEAAYIYyGtAQAVAgAqAAQKfxcAAgYACAj9HA0gAAwCAAYACAj9HA0gAAwCAAAA.Maynear:BAAAKgAFFAMIAwABKgAFFAgIKQADAOkjAA==.',St='Stamina:BAACKgAFFH8pAAIDAAgI6SNzBAAEAgADAAgI6SNzBAAEAgAqAAQKfzsABAMACAi5JQIDAPQCAAMACAi5JQIDAPQCAAcAAghSEASNADgAAAgAAQj0AQAAAAAAAAAA.',Wa='Warlockroy:BAABKgAFFH8MAAQJAAgI2SCmAgBuAQAJAAUItCCmAgBuAQAKAAQIKx7kFABcAQALAAEIpx9PDgBdAAAAAA==.',['丨紫']='丨紫气东来丨:BAABKgAFFH8IAAIMAAgInhPrCgAXAgAMAAgInhPrCgAXAgAAAA==.',['吾有']='吾有上将潘凤:BAAAKgADCggICAAAAA==.',['咕咕']='咕咕股:BAAAKgAFFAcIAgABKgAFFAgIFAANAOgiAA==.',['喝冰']='喝冰峰的骑士:BAAAKgADCggICAAAAA==.',['国王']='国王大道:BAABKgAFFH8MAAMCAAMIMx/FDgC+AAACAAMIzh7FDgC+AAABAAEIixkBBgBTAAAAAA==.',['大东']='大东人:BAAAKgAFFAIIAgAAAA==.',['天生']='天生我菜:BAAAKgADCggICAAAAA==.',['好运']='好运的龙龙丶:BAAAKgADCgEIAQAAAA==.',['射线']='射线恶魔:BAAAKgAFFAIIAgAAAA==.',['小绿']='小绿:BAAAKgADCgMIAwAAAA==.',['就咬']='就咬一小口:BAAAKgADCggICAAAAA==.',['怀旧']='怀旧风岸:BAAAKgADCgcICQAAAA==.',['我是']='我是奶你信嘛:BAAAKgAECgIIAgAAAA==.',['抹油']='抹油贼客:BAAAKgAECgUICQAAAA==.',['拉泽']='拉泽尔:BAAAKgAECggIDAAAAA==.',['暴灬']='暴灬:BAAAKgAECgcIEgAAAA==.',['死神']='死神出世:BAAAKgAECgUICAAAAA==.',['没人']='没人比我帅:BAAAKgAECgIIAgAAAA==.',['流萤']='流萤:BAAAKgAFFAQIBAAAAA==.',['浮华']='浮华乱流年:BAAAKgAECggIBwAAAA==.',['热爱']='热爱:BAAAKgAECgMIBAAAAA==.',['甜甜']='甜甜的龙眼:BAAAKgAECgcIDQAAAA==.',['画一']='画一画她:BAAAKgADCgYIBgAAAA==.',['荧光']='荧光:BAAAKgAFFAgIBAAAAA==.',['萤火']='萤火中的微光:BAAAKgADCggICAAAAA==.',['薇尔']='薇尔莉特:BAABKgAECn8jAAIOAAgIOyLYDQCAAgAOAAgIOyLYDQCAAgAAAA==.',['话多']='话多皮蛋多:BAABKgAECn8eAAQDAAgIcxP7KwCIAQADAAcIXhb7KwCIAQAHAAYIWhBtZQCqAAAIAAEI9AEAAAAAAAAAAA==.',['达泊']='达泊西叮丶:BAAAKgAECgEIAQAAAA==.',['邪恶']='邪恶灬力量:BAABKgAECn8WAAIJAAgISgcaPgD7AAAJAAgISgcaPgD7AAAAAA==.',['阿凯']='阿凯尼:BAAAKgAECgQIBAAAAA==.',['阿隆']='阿隆索斯丶:BAAAKgADCggICAAAAA==.',['雨季']='雨季丨:BAAAKgAECggICAAAAA==.',['风止']='风止意难评:BAAAKgAFFAQIBAAAAA==.',['黄瓜']='黄瓜味龙宝:BAAAKgADCggIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end