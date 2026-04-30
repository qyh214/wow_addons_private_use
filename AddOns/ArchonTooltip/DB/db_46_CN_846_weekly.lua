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

local lookup = {'Druid-Restoration','Warlock-Demonology','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Evoker-Augmentation','Evoker-Preservation','DeathKnight-Blood','Priest-Discipline','Druid-Guardian','DemonHunter-Devourer',}
local provider = {region='CN',realm='迦罗娜',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Al:BAACLgAFFH8GAAIBAAIJEx98DQC1AAABAAIJEx98DQC1AAAuAAQKfxsAAgEACAm2H00NANICAAEACAm2H00NANICAAAA.Altria:BAAALgAFFAIJBAAAAA==.Alvitr:BAAALgADCgUJCgAAAA==.',
Di='Dih:BAAALgADCgEJAQAAAA==.',
Fa='Fammer:BAAALgADCgcJDQAAAA==.',
Ha='Hammerko:BAAALgAECgUJBQAAAA==.',
Ku='Kumo:BAAALgAFFAcJBAAAAA==.',
Ma='Masfia:BAAALgAECgMJAwAAAA==.',
Qu='Quaswexexort:BAAALgAECgEJAQAAAA==.',
['丁丁']='丁丁猫:BAABLgAFFH8FAAICAAIJciafJgDkAAACAAIJciafJgDkAAAAAA==.',
['不虚']='不虚:BAAALgAECgUJBQAAAA==.',
['不讲']='不讲武德哟:BAAALgAFFAQJBAAAAA==.',
['丨猎']='丨猎丨:BAAALgAFFAIJAgAAAA==.',
['五十']='五十几个死骑:BAAALgAECgcJEgAAAA==.',
['伊泽']='伊泽瑞尔:BAAALgAECgEJAQAAAA==.',
['八号']='八号风球:BAAALgAECgYJCwAAAA==.',
['再見']='再見螢火蟲:BAAALgAECgEJAQAAAA==.',
['冠希']='冠希:BAAALgAECgUJBQAAAA==.',
['凯蒂']='凯蒂佩瑞:BAAALgAECgEJAQAAAA==.',
['加尔']='加尔鲁什酋长:BAAALgAECgEJAQAAAA==.',
['加百']='加百利埃洛:BAAALgADCgIJAgAAAA==.',
['四雨']='四雨:BAAALgAECgEJAQAAAA==.',
['困告']='困告:BAAALgAECgQJBAAAAA==.',
['圣雾']='圣雾:BAAALgADCgEJAQAAAA==.',
['堪坷']='堪坷菜菜仔:BAAALgAECgEJAQAAAA==.',
['夜丨']='夜丨如此寂寞:BAAALgAECgIJAgAAAA==.',
['夜丶']='夜丶很静:BAAALgAECgMJAwAAAA==.',
['夜灬']='夜灬很静:BAAALgADCgQJBAAAAA==.',
['大拙']='大拙手山一程:BAAALgAECgIJAgAAAA==.',
['夯夯']='夯夯的劣人:BAAALgAECgcJBwAAAA==.',
['孑琅']='孑琅:BAAALgAECgQJAgAAAA==.',
['寳儿']='寳儿姐:BAAALgAECgcJDAAAAA==.',
['小肥']='小肥羊:BAAALgADCgYJBgAAAA==.',
['怒秀']='怒秀演技:BAAALgAECgEJAQAAAA==.',
['悠嵐']='悠嵐芷晴:BAAALgAECgYJDgAAAA==.',
['手里']='手里剑:BAAALgAECgcJEAAAAA==.',
['撕令']='撕令:BAAALgAECgEJAQAAAA==.',
['放逐']='放逐灵魂:BAAALgAECgMJAwAAAA==.',
['明月']='明月寄我心:BAAALgADCgUJBwAAAA==.',
['星之']='星之子:BAAALgAECgkJCQAAAA==.',
['星星']='星星:BAAALgADCgEJAQAAAA==.',
['星月']='星月多多:BAAALgAECgkJCgAAAA==.',
['暗夜']='暗夜冰翎:BAAALgAECgMJAwAAAA==.',
['正趣']='正趣果上果:BAAALgAECgQJBgAAAA==.',
['死神']='死神無極:BAAALgAECgEJAQAAAA==.',
['沉默']='沉默空大:BAAALgAFFAIJAwAAAA==.',
['沙沙']='沙沙鱼:BAACLgAFFH8IAAIDAAQJ7hifAgB0AQADAAQJ7hifAgB0AQAuAAQKfxgABAMABwk+IFoRAK4CAAMABwk+IFoRAK4CAAQAAgmMENIoAGwAAAUAAQlsEDmGADYAAAAA.',
['海尾']='海尾巴:BAABLgAFFH8HAAMGAAIJIAVREgCGAAAGAAIJIAVREgCGAAAHAAIJpADsFABuAAAAAA==.',
['海棉']='海棉:BAAALgAECgYJDAAAAA==.',
['清白']='清白之年:BAACLgAFFH8HAAIIAAIJ4xLoCQBoAAAIAAIJ4xLoCQBoAAAuAAQKfxgAAggABwneFs4aAHkBAAgABwneFs4aAHkBAAAA.',
['熊猫']='熊猫:BAAALgADCgMJBAAAAA==.',
['猫小']='猫小柒:BAAALgAECgEJAgAAAA==.',
['玛斯']='玛斯菲雅:BAAALgAECgQJBgAAAA==.',
['琬儿']='琬儿:BAAALgAECgEJAQAAAA==.',
['电饭']='电饭宝:BAABLgAFFH8FAAIJAAIJdA3yEwCWAAAJAAIJdA3yEwCWAAAAAA==.',
['白茉']='白茉晴:BAAALgAECgYJCwAAAA==.',
['第一']='第一天增辉:BAAALgAECgQJBAAAAA==.',
['米格']='米格:BAAALgAECgYJBgAAAA==.',
['米砂']='米砂:BAAALgAECgUJCQAAAA==.',
['红温']='红温的牛儿:BAAALgAFFAMJBAAAAA==.',
['终点']='终点:BAAALgAFFAIJAwAAAA==.',
['给力']='给力的老湿:BAAALgAFFAIJBAAAAA==.',
['老妹']='老妹儿给劲嗷:BAAALgAECgUJBQAAAA==.',
['聂格']='聂格:BAAALgAECggJCQAAAA==.',
['艾格']='艾格雯:BAAALgAECgYJBwAAAA==.',
['艾蕾']='艾蕾利亚:BAAALgAECgEJAQAAAA==.',
['萨雷']='萨雷:BAAALgAECgMJAwAAAA==.',
['蕓霜']='蕓霜嫣雨:BAAALgADCgcJBwAAAA==.',
['许愿']='许愿者:BAAALgAFFAIJAgABLgAFFAQJBgAKACgLAA==.',
['赤伶']='赤伶:BAAALgAECgQJBQAAAA==.',
['连山']='连山:BAAALgAECgYJBgAAAA==.',
['那个']='那个男人:BAABLgAFFH8GAAILAAIJuRxWEAD0AAALAAIJuRxWEAD0AAAAAA==.',
['雪域']='雪域风铃:BAABLgAFFH8FAAIBAAIJCSLDCwDMAAABAAIJCSLDCwDMAAAAAA==.',
['饲养']='饲养员:BAABLgAFFH8FAAIDAAUJhxHqAwBZAQADAAUJhxHqAwBZAQAAAA==.',
['麦子']='麦子公举:BAAALgAECgEJAQAAAA==.麦子郡主:BAAALgAFFAEJAQAAAA==.',
['龙渊']='龙渊:BAAALgAECgUJBQAAAA==.',
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
