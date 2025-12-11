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
 local lookup = {'Monk-Brewmaster','Evoker-Augmentation','Hunter-BeastMastery','Shaman-Restoration','Hunter-Marksmanship','Paladin-Retribution','Warrior-Fury','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','Mage-Arcane','DeathKnight-Frost','Druid-Guardian','DeathKnight-Unholy',}; local provider = {region='CN',realm='埃基尔松',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ko='Kotori:BAAALAAFFAIIBAAAAA==.',['一起']='一起冲丶:BAAALAAECgQIBAAAAA==.',['佐倉']='佐倉綾音:BAABLAAFFH8GAAIBAAYIkBefDQBtAQABAAYIkBefDQBtAQAAAA==.',['冷静']='冷静地二求:BAAALAAFFAQIBAABLAAFFAgIBgACAMYbAA==.',['动不']='动不动手:BAAALAAECgIIAgAAAA==.',['十二']='十二月:BAAALAADCgMIAwAAAA==.',['发条']='发条工程师:BAABLAAFFH8YAAIDAAcIcRtUEwD1AQADAAcIcRtUEwD1AQAAAA==.',['取名']='取名字好难:BAABLAAFFH8MAAIEAAII4Q7hWwBkAAAEAAII4Q7hWwBkAAAAAA==.',['大四']='大四喜:BAABLAAFFH8GAAIDAAQIYQ2AYAC/AAADAAQIYQ2AYAC/AAAAAA==.',['女德']='女德:BAAALAADCgUIBQAAAA==.',['奶片']='奶片儿:BAAALAAECgYIBgAAAA==.',['宁静']='宁静致远:BAAALAAECgMIBAAAAA==.',['小酒']='小酒壶:BAAALAADCgMIAwAAAA==.',['小飞']='小飞机:BAABLAAFFH8zAAIFAAcIph3hAQA6AgAFAAcIph3hAQA6AgAAAA==.',['德玛']='德玛西亚:BAAALAADCgIIAgAAAA==.',['我见']='我见过帝师:BAAALAAFFAEIAQAAAA==.',['支付']='支付宝儿:BAAALAAECgcIBwAAAA==.',['无情']='无情铁手:BAABLAAECn8WAAIGAAcIARnnRACNAQAGAAcIARnnRACNAQAAAA==.',['更深']='更深的蓝:BAAALAAECgUIBwAAAA==.',['歼击']='歼击丶基:BAABLAAFFH8GAAIHAAIIKRaJUABEAAAHAAIIKRaJUABEAAAAAA==.',['毛豆']='毛豆豆:BAAALAAECgYIBgAAAA==.',['汤包']='汤包最能剥:BAAALAAECgMIBAAAAA==.',['没有']='没有恶魔:BAABLAAFFH8FAAMIAAIIJA5GGACTAAAIAAII2w1GGACTAAAJAAIIJQgrTgCEAAAAAA==.没有战复:BAABLAAFFH8IAAIKAAIIqRjcJgCOAAAKAAIIqRjcJgCOAAAAAA==.',['流川']='流川乐:BAABLAAFFH8eAAILAAYIjiWzCwAsAgALAAYIjiWzCwAsAgABLAAFFAgIFwAMABIeAA==.',['流水']='流水:BAAALAADCgMIAwAAAA==.',['清风']='清风:BAAALAAECgQIBAAAAA==.',['煞嗒']='煞嗒姆:BAABLAAFFH8GAAIHAAYIahQHHQCCAQAHAAYIahQHHQCCAQAAAA==.',['牛小']='牛小萌:BAAALAADCgYIBgAAAA==.',['狗一']='狗一样的老板:BAAALAAFFAIIBAAAAA==.',['狗哥']='狗哥牛批:BAAALAAFFAIIBAAAAA==.',['瓜子']='瓜子二手车:BAAALAAFFAIIAgAAAA==.',['生鱼']='生鱼片片:BAAALAAECgUIBQAAAA==.',['秋夜']='秋夜江晚吟:BAABLAAFFH8JAAIGAAIITQpAawBBAAAGAAIITQpAawBBAAAAAA==.',['美丽']='美丽的太阳:BAAALAAECgMIAwAAAA==.',['群星']='群星守护:BAAALAADCgYIBgAAAA==.',['苍云']='苍云:BAAALAADCgUIBgAAAA==.',['荒野']='荒野猪崽:BAABLAAFFH8KAAMKAAYIOhJxIQAUAQAKAAUIUw9xIQAUAQANAAEIQhmyCwBVAAAAAA==.',['运满']='运满乾坤:BAAALAADCggICAAAAA==.',['速度']='速度与馕:BAAALAAECgYIBgAAAA==.',['阿里']='阿里皮皮:BAABLAAECn8fAAIMAAYI/CDKZAAsAgAMAAYI/CDKZAAsAgAAAA==.',['陈十']='陈十一:BAABLAAFFH8XAAMMAAYIEh5EJACkAQAMAAYIpx1EJACkAQAOAAIIWh3SCQC9AAAAAA==.',['雲和']='雲和山的彼端:BAAALAAECggICAAAAA==.',['鬣魔']='鬣魔:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end