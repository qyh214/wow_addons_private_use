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
 local lookup = {'Mage-Frost','Hunter-BeastMastery','Monk-Windwalker','DeathKnight-Frost','Paladin-Retribution','Mage-Arcane','Shaman-Elemental','Druid-Restoration','Druid-Balance','DemonHunter-Havoc',}; local provider = {region='CN',realm='祖达克',name='CN',type='weekly',zone=44,date='2025-12-10',data={Al='Alba:BAAALAAECgEIAQAAAA==.',Ma='Mageroysong:BAABLAAFFH8RAAIBAAYItxm6BACHAQABAAYItxm6BACHAQAAAA==.Maynear:BAABLAAFFH8UAAICAAYIgCULEgACAgACAAYIgCULEgACAgABLAAFFAcIIgADAGEjAA==.',Oy='Oyyxdk:BAACLAAFFH8IAAIEAAYIJhd7MAB/AQAEAAYIJhd7MAB/AQAsAAQKfyIAAgQABwjQJWkcAP4CAAQABwjQJWkcAP4CAAAA.',St='Stamina:BAACLAAFFH8iAAIDAAcIYSMUAgA1AgADAAcIYSMUAgA1AgAsAAQKfzMAAgMACAj5JekBAHEDAAMACAj5JekBAHEDAAAA.',Xi='Xiaor:BAAALAAECgUIBAAAAA==.',['不嘻']='不嘻嘻:BAAALAAECgUIBQAAAA==.',['光使']='光使神猎:BAABLAAFFH8HAAICAAIIZhzmlABEAAACAAIIZhzmlABEAAAAAA==.',['圣殿']='圣殿骑士:BAAALAADCgMIAwAAAA==.',['大山']='大山:BAAALAAECgQIBAAAAA==.',['好运']='好运的龙龙丶:BAAALAADCgYIBgAAAA==.',['小橘']='小橘子的死骑:BAAALAAECgYIDgAAAA==.',['抹油']='抹油贼客:BAAALAAECgYIBgAAAA==.',['旧城']='旧城人不覆:BAAALAAFFAIIBAAAAA==.',['暴灬']='暴灬:BAAALAAECgYIBgAAAA==.',['气功']='气功师:BAAALAAECggICAAAAA==.',['浮华']='浮华乱流年:BAABLAAFFH8HAAIFAAIIAA9UVgCMAAAFAAIIAA9UVgCMAAAAAA==.',['热爱']='热爱:BAAALAAECggICAAAAA==.',['獸獸']='獸獸無敵:BAABLAAFFH8LAAIEAAMIhRdeXACbAAAEAAMIhRdeXACbAAAAAA==.',['玛莎']='玛莎灬拉蒂:BAAALAAECgEIAgAAAA==.',['甜甜']='甜甜的龙眼:BAABLAAFFH8IAAIGAAMIJxDnSACCAAAGAAMIJxDnSACCAAAAAA==.',['电疗']='电疗:BAAALAAECgYICQAAAA==.',['画一']='画一画她:BAAALAAECgIIAgAAAA==.',['白太']='白太阳:BAAALAAECgIIAgAAAA==.',['百利']='百利甜酒:BAAALAADCgUIBQAAAA==.',['皓斧']='皓斧力士:BAAALAADCggICAAAAA==.',['糕松']='糕松灯:BAACLAAFFH8NAAIEAAUI+xP4IwAMAQAEAAUI+xP4IwAMAQAsAAQKfyAAAgQACAhwJe8RACoDAAQACAhwJe8RACoDAAEsAAUUBQgOAAcANhUA.',['罐罐']='罐罐西施:BAAALAAECggIAwAAAA==.',['胸毛']='胸毛在燃烧:BAAALAAECgYIBgAAAA==.',['芙芙']='芙芙丶咕哒:BAABLAAECn8UAAMIAAcI8wmmVADJAAAIAAcI8wmmVADJAAAJAAMIeAdsZQAuAAAAAA==.',['荧光']='荧光:BAAALAAECggICAAAAA==.',['西红']='西红柿蛋汤:BAAALAADCgYIBgAAAA==.',['貂蝉']='貂蝉在跨上:BAAALAADCgcIBwAAAA==.',['轲戾']='轲戾怒风:BAAALAADCggICAAAAA==.',['邪恶']='邪恶灬力量:BAAALAAECgQIBAAAAA==.',['酸溜']='酸溜溜的麻瓜:BAAALAADCgUIBQAAAA==.',['野法']='野法德心:BAABLAAFFH8LAAIIAAII4hgCOACOAAAIAAII4hgCOACOAAAAAA==.',['阿尔']='阿尔托莉吖:BAACLAAFFH8OAAIHAAUINhXNDACzAQAHAAUINhXNDACzAQAsAAQKfxcAAgcABwjvIzgaAMwCAAcABwjvIzgaAMwCAAAA.',['雨枫']='雨枫:BAAALAAECggICAAAAA==.',['零浩']='零浩彻:BAAALAAECgQIBAAAAA==.',['雷总']='雷总让我改名:BAAALAAECggICAAAAA==.',['靓仔']='靓仔:BAAALAADCgEIAQAAAA==.',['鱼丸']='鱼丸泡面:BAAALAAECgQIBQAAAA==.',['鱼丹']='鱼丹丹:BAACLAAFFH8LAAIKAAQI4he9GwD+AAAKAAQI4he9GwD+AAAsAAQKfxoAAgoACAhEIxgSACUDAAoACAhEIxgSACUDAAEsAAUUBwgiAAMAYSMA.',['黄焖']='黄焖山鸡:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end