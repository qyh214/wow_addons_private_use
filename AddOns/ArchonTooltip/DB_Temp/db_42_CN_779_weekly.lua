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
 local lookup = {'Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','DeathKnight-Unholy','Mage-Fire','Mage-Frost','Mage-Arcane','DemonHunter-Havoc','Paladin-Protection','Unknown-Unknown','Shaman-Enhancement','Hunter-Marksmanship','Hunter-BeastMastery',}; local provider = {region='CN',realm='穆戈尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Fa='Farseer:BAAAKgAECgQICAAAAA==.',Oa='Oac:BAAAKgADCgIIAgAAAA==.',Se='Seasonofknow:BAAAKgAFFAIIAgAAAA==.Seasonoflife:BAABKgAECn8VAAMBAAgIZgjkgADEAAABAAYIeAjkgADEAAACAAUI4QhIVgDAAAAAAA==.',['一介']='一介俗人:BAAAKgAECgYIBgAAAA==.',['你可']='你可拉倒吧:BAAAKgAFFAgIBAAAAA==.',['冰霜']='冰霜夜舞:BAAAKgADCgQIBAAAAA==.',['凯尔']='凯尔萨:BAAAKgADCgIIAgAAAA==.',['别嘌']='别嘌醇:BAAAKgADCggICAAAAA==.',['勾陈']='勾陈驭靈:BAAAKgAECgIIAgAAAA==.',['古月']='古月:BAAAKgAFFAYIBAAAAA==.',['吃过']='吃过亏:BAABKgAFFH8GAAICAAYI2BXHBwBbAQACAAYI2BXHBwBbAQAAAA==.',['呢了']='呢了要吃肉:BAAAKgAECgQIBAAAAA==.',['嗜血']='嗜血医鬼:BAAAKgAECgEIAQAAAA==.',['多哥']='多哥爱吃醋:BAABKgAFFH8IAAIDAAgIZQP9JgBMAQADAAgIZQP9JgBMAQAAAA==.',['夜之']='夜之醉美人:BAABKgAECn8WAAIDAAgI7BABigCDAQADAAgI7BABigCDAQAAAA==.',['安徒']='安徒生:BAAAKgAECgQIBQABKgAFFAMICwAEABoZAA==.',['寳寳']='寳寳堃贝尔:BAACKgAFFH8OAAMFAAYI+R9DCgCUAQAFAAYI0RxDCgCUAQAGAAMI7BX2EADbAAAqAAQKfx0AAwYACAhRH0AxAK4BAAYACAhRH0AxAK4BAAcAAQgJHI9AAFQAAAAA.',['小小']='小小灵:BAAAKgADCggICAAAAA==.',['岁年']='岁年:BAAAKgAECgUIBwAAAA==.',['崔巉']='崔巉:BAAAKgAECgYIBgAAAA==.',['弦上']='弦上舞:BAAAKgAECgYICQAAAA==.',['惡魔']='惡魔獵手:BAABKgAFFH8IAAIIAAgIkxJRCAAHAgAIAAgIkxJRCAAHAgAAAA==.',['施晓']='施晓林:BAAAKgADCgYIBgAAAA==.',['旷野']='旷野之息:BAABKgAFFH8LAAMJAAYInBN0CAArAQAJAAYIHRJ0CAArAQADAAQIhhBPGgATAQAAAA==.',['春风']='春风不语:BAABKgAECn8ZAAIGAAgIQyANEwBmAgAGAAgIQyANEwBmAgABKgAFFAQIBAAKAAAAAA==.',['最爱']='最爱阴朝:BAAAKgADCgQIBAAAAA==.',['死鬼']='死鬼:BAAAKgADCgIIAgAAAA==.',['活整']='活整稀碎:BAABKgAFFH8GAAIDAAYIdhXJDQAdAQADAAYIdhXJDQAdAQAAAA==.',['浪里']='浪里个浪:BAAAKgAFFAgIBAAAAA==.',['温蕾']='温蕾萨:BAABKgAFFH8FAAMLAAUIiQWEFQCmAAALAAQIdQaEFQCmAAABAAEIsAEJKgAtAAAAAA==.',['爱吃']='爱吃蛋堡:BAAAKgADCggICAAAAA==.',['爱的']='爱的冬景圣光:BAAAKgAFFAMIAwAAAA==.',['狐仙']='狐仙小娘子:BAAAKgADCggICwAAAA==.',['猎亾']='猎亾:BAABKgAFFH8cAAMMAAgImCO0AgCDAgANAAgIdh9GAgCwAgAMAAgIeCK0AgCDAgAAAA==.',['生生']='生生:BAABKgAECn8XAAIGAAgI6xr6HADJAQAGAAgI6xr6HADJAQAAAA==.',['白发']='白发魔女:BAAAKgAECggICAAAAA==.',['等待']='等待煎熬:BAAAKgADCgIIAgAAAA==.',['红色']='红色气球:BAAAKgAECgQIBwAAAA==.',['聖騏']='聖騏仕:BAABKgAFFH8WAAIDAAgIfBWWCQApAgADAAgIfBWWCQApAgAAAA==.',['萨滿']='萨滿:BAAAKgAECgEIAQAAAA==.',['郝帅']='郝帅:BAAAKgADCggIAgAAAA==.',['银河']='银河球棒侠:BAAAKgAECggIEQAAAA==.',['龘哒']='龘哒鞑:BAAAKgAFFAYIBAABKgAFFAgIDwALAC4bAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end