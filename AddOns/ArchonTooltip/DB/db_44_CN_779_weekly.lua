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
 local lookup = {'Mage-Frost','Mage-Arcane','Shaman-Restoration','DeathKnight-Frost','Hunter-BeastMastery','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Paladin-Retribution','Hunter-Marksmanship','Paladin-Protection',}; local provider = {region='CN',realm='穆戈尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Gu='Gui:BAABLAAECn8cAAMBAAYICR2TJAD9AQABAAYI6ByTJAD9AQACAAEIcQoUAQE5AAAAAA==.',Oa='Oac:BAABLAAFFH8HAAIDAAII2RsuNgCUAAADAAII2RsuNgCUAAABLAAFFAMIBQAEAAULAA==.',Ob='Obiuobiuo:BAAALAAECggICgAAAA==.',Wi='Winkirayi:BAAALAAECggICAAAAA==.',Zz='Zze:BAAALAAECgMIAwAAAA==.',['一缕']='一缕阳光:BAAALAAECgEIAQAAAA==.',['互相']='互相看不上:BAAALAAECgYIBgAAAA==.',['人死']='人死鸟朝上:BAAALAAECgYICgAAAA==.',['你可']='你可拉倒吧:BAAALAAFFAIIAgABLAAFFAUICwAFADcXAA==.',['你觉']='你觉得呢:BAABLAAFFH8GAAIGAAIIAhPoSwBNAAAGAAIIAhPoSwBNAAAAAA==.',['先死']='先死为敬:BAAALAAECgYIBgAAAA==.',['八万']='八万个馒头:BAAALAAECgUICQAAAA==.',['冰霜']='冰霜夜舞:BAAALAAECgYIBwAAAA==.',['古月']='古月:BAABLAAFFH8SAAMHAAYI0BEjGwB1AQAHAAYI0BEjGwB1AQAIAAUIvBItFAAyAQAAAA==.',['吃过']='吃过亏:BAAALAAFFAIIAgAAAA==.吃过饭:BAABLAAFFH8KAAIFAAIIUxYCWgCPAAAFAAIIUxYCWgCPAAAAAA==.',['呢了']='呢了要吃肉:BAAALAAECgIIAgAAAA==.',['圣光']='圣光再现:BAAALAAECgcICAAAAA==.',['坠落']='坠落的泪:BAAALAAECgYIBgAAAA==.',['夜里']='夜里抚假面:BAAALAAECgYICAAAAA==.',['嬷嬷']='嬷嬷:BAAALAAFFAEIAQAAAA==.',['安徒']='安徒生:BAABLAAFFH8HAAIFAAcIOxyzCwAuAgAFAAcIOxyzCwAuAgAAAA==.',['寳寳']='寳寳堃贝尔:BAAALAAFFAIIAgAAAA==.',['小流']='小流氓东东:BAAALAAECgYIBgAAAA==.',['岁年']='岁年:BAAALAAECgYICgAAAA==.',['幽炎']='幽炎冰:BAAALAAECgYIDAAAAA==.',['彡彡']='彡彡:BAAALAADCgIIAgAAAA==.',['惡魔']='惡魔獵手:BAABLAAFFH8LAAIGAAYInAu+JgBaAQAGAAYInAu+JgBaAQAAAA==.',['惬意']='惬意:BAAALAADCgEIAQAAAA==.',['折酒']='折酒苦柳:BAAALAADCgYIBAAAAA==.',['拖月']='拖月山大祖:BAAALAAECgMIAwAAAA==.',['春风']='春风不语:BAABLAAFFH8HAAMCAAIIBBlmTACUAAACAAIIYBhmTACUAAABAAEIMRBKIABCAAABLAAFFAUICwAFADcXAA==.',['极寒']='极寒之触:BAACLAAFFH8HAAIJAAIIHA6iSwCWAAAJAAIIHA6iSwCWAAAsAAQKfxYAAgkABgjKHt54APgBAAkABgjKHt54APgBAAAA.',['柿子']='柿子柿子:BAAALAAECgYIBgAAAA==.',['殘丨']='殘丨梦:BAAALAAFFAIIBAAAAA==.',['活整']='活整稀碎:BAAALAAECgEIAQAAAA==.',['浪里']='浪里个浪:BAAALAAECgYICAAAAA==.',['牛酋']='牛酋人头长:BAABLAAFFH8MAAIFAAII+Qr/dQB4AAAFAAII+Qr/dQB4AAAAAA==.',['猎亾']='猎亾:BAACLAAFFH8FAAIKAAUIkBXsCQALAQAKAAUIkBXsCQALAQAsAAQKfxcAAgUACAgFGb56AOgBAAUACAgFGb56AOgBAAAA.',['猫汁']='猫汁:BAAALAAECgUIBQAAAA==.',['王大']='王大牛:BAABLAAFFH8HAAILAAMIBQxDDgClAAALAAMIBQxDDgClAAAAAA==.',['玥玥']='玥玥:BAAALAAFFAIIAgAAAA==.',['珍宝']='珍宝一号:BAABLAAFFH8YAAICAAgIWSMqBACtAgACAAgIWSMqBACtAgAAAA==.珍宝三号:BAABLAAFFH8QAAICAAgIaSL1BgB3AgACAAgIaSL1BgB3AgAAAA==.珍宝二号:BAABLAAFFH8PAAICAAgIlSNJAwDBAgACAAgIlSNJAwDBAgAAAA==.珍宝五号:BAABLAAFFH8KAAICAAcIYB2/LABbAQACAAcIYB2/LABbAQAAAA==.珍宝四号:BAABLAAFFH8KAAICAAgIBh5ABwBxAgACAAgIBh5ABwBxAgAAAA==.',['生生']='生生:BAAALAAECgMIAwAAAA==.',['番茄']='番茄酱:BAAALAAECgYICwAAAA==.',['神乐']='神乐圆舞:BAAALAAECgQIBAAAAA==.',['红色']='红色气球:BAAALAAFFAIIAgAAAA==.',['维怡']='维怡:BAABLAAFFH8GAAIDAAII6xDqSwBvAAADAAII6xDqSwBvAAAAAA==.',['艾莉']='艾莉尔丶猎星:BAAALAAECgYIBgAAAA==.',['若叶']='若叶睦:BAAALAAFFAIIAgAAAA==.',['萨滿']='萨滿:BAABLAAFFH8GAAIDAAYIBRNdIgBLAQADAAYIBRNdIgBLAQAAAA==.',['郝帅']='郝帅:BAAALAADCgcIBwAAAA==.',['闪现']='闪现踩到翔:BAAALAAECgYICQAAAA==.',['雅丽']='雅丽:BAAALAADCgUIBQAAAA==.',['麻辣']='麻辣小龙侠:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end