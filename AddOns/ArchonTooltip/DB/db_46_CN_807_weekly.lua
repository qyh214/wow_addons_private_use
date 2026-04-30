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

local lookup = {'Paladin-Holy','Paladin-Retribution','Shaman-Elemental','DemonHunter-Devourer',}
local provider = {region='CN',realm='范克里夫',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Animus:BAAALgAECgEJAQAAAA==.',
Aq='Aq:BAAALgADCgYJBwAAAA==.',
Cr='Crscfs:BAAALgAFFAUJAwAAAA==.',
Dm='Dmango:BAAALgAFFAMJAwAAAA==.',
Mo='Moonaurora:BAAALgAFFAEJAgAAAA==.',
Ov='Overdrive:BAAALgAECgQJCgAAAA==.',
Sa='Sasioverlord:BAAALgAECgQJBAAAAA==.',
Sh='Shasha:BAAALgAFFAEJAQAAAA==.',
So='Soulharveste:BAAALgAECgQJBAAAAA==.',
Su='Superjump:BAAALgAECgUJBgAAAA==.',
Ti='Timi:BAAALgAFFAEJAQAAAA==.',
Tw='Twinmirror:BAAALgAECgQJBwAAAA==.',
['万类']='万类霜天:BAAALgAECgMJAwAAAA==.',
['下鸭']='下鸭矢一郎:BAAALgAFFAIJAgAAAA==.',
['不知']='不知意:BAAALgAFFAMJBAAAAA==.',
['个子']='个子高射的远:BAAALgAECgEJAQAAAA==.',
['丶术']='丶术丶:BAAALgADCgMJAwAAAA==.',
['九挂']='九挂:BAABLgAFFH8OAAIBAAYJexmeAAACAgABAAYJexmeAAACAgAAAA==.',
['你还']='你还不如跳担:BAAALgAECgQJBAAAAA==.',
['兵长']='兵长一米五:BAAALgAECgEJAQAAAA==.',
['再见']='再见时光:BAAALgADCgUJBQAAAA==.',
['凉红']='凉红摇:BAACLgAFFH8OAAIBAAUJnBxsAwCyAQABAAUJnBxsAwCyAQAuAAQKfxwAAgEACQmUG7wMALQCAAEACQmUG7wMALQCAAAA.凉红瑶:BAABLgAFFH8LAAIBAAUJbRMcBQCMAQABAAUJbRMcBQCMAQAAAA==.凉红药:BAABLgAFFH8TAAIBAAYJVhxxAAATAgABAAYJVhxxAAATAgAAAA==.',
['十一']='十一挂:BAAALgAFFAUJAwABLgAFFAYJDgABAHsZAA==.',
['十二']='十二挂:BAABLgAFFH8FAAIBAAUJXyI4AQAOAgABAAUJXyI4AQAOAgABLgAFFAYJDgABAHsZAA==.',
['十挂']='十挂:BAABLgAFFH8JAAIBAAUJaR3WAQDqAQABAAUJaR3WAQDqAQABLgAFFAYJDgABAHsZAA==.',
['听海']='听海风擦身过:BAAALgAECgYJBgAAAA==.',
['回归']='回归小恶魔:BAAALgAECgQJBAAAAA==.',
['大妈']='大妈与广场舞:BAAALgAECgQJBQAAAA==.',
['大皮']='大皮雁子:BAAALgAECgUJBQAAAA==.',
['天斩']='天斩:BAAALgAFFAQJBAAAAA==.',
['奎尔']='奎尔丹尼:BAAALgADCgEJAQAAAA==.',
['奶嘴']='奶嘴:BAAALgAECgYJDAAAAA==.',
['娇妹']='娇妹:BAAALgAECgEJAgAAAA==.',
['婷宝']='婷宝:BAAALgAECgEJAQAAAA==.',
['子榆']='子榆居:BAAALgAECgIJAwAAAA==.',
['季的']='季的终章:BAAALgAECgcJDQAAAA==.',
['小皮']='小皮艳子:BAABLgAECn8UAAICAAcJdxr+UADuAQACAAcJdxr+UADuAQAAAA==.',
['年少']='年少不识英招:BAAALgAECgcJBgAAAA==.',
['悦色']='悦色正朦胧:BAAALgAECgEJAQAAAA==.',
['情绪']='情绪:BAAALgAECgYJDAAAAA==.',
['手捧']='手捧玫瑰:BAABLgAECn8XAAIDAAcJRh3WFgBiAgADAAcJRh3WFgBiAgAAAA==.',
['拌面']='拌面:BAAALgAECgEJAgAAAA==.',
['是冬']='是冬:BAAALgAECgEJAwAAAA==.',
['月亮']='月亮之井:BAAALgAECgYJCwAAAA==.',
['月舞']='月舞丨清枫:BAAALgAECgEJAQAAAA==.',
['月色']='月色最朦胧:BAAALgAECgEJAQAAAA==.',
['机佬']='机佬黄:BAAALgAECgcJEwAAAA==.',
['柠樱']='柠樱丶:BAAALgAECgUJBgAAAA==.',
['梁红']='梁红摇:BAACLgAFFH8HAAIBAAQJEh78BQB6AQABAAQJEh78BQB6AQAuAAQKfxcAAgEACQkDGEgVAGcCAAEACQkDGEgVAGcCAAAA.梁红瑶:BAABLgAFFH8PAAIBAAYJ5hp9AAAPAgABAAYJ5hp9AAAPAgAAAA==.梁红药:BAACLgAFFH8OAAIBAAYJLRz3AAAbAgABAAYJLRz3AAAbAgAuAAQKfx4AAgEACQnVHvgGAPwCAAEACQnVHvgGAPwCAAAA.',
['梅素']='梅素雪银:BAAALgAECgEJAQAAAA==.',
['水冰']='水冰月张:BAAALgAECgUJCQAAAA==.',
['水嫩']='水嫩娇妻:BAABLgAFFH8JAAIEAAMJzxD/EQDoAAAEAAMJzxD/EQDoAAAAAA==.',
['浮光']='浮光旧年:BAAALgAECgcJBwAAAA==.',
['游鱼']='游鱼丿:BAAALgAECgEJBAAAAA==.',
['滅魂']='滅魂潇:BAAALgAECgcJDQAAAA==.',
['满穗']='满穗:BAAALgAECgMJAwAAAA==.',
['灬橙']='灬橙子灬:BAAALgAECgMJAwAAAA==.',
['烤两']='烤两串胸口:BAAALgAECgYJBgAAAA==.',
['燕人']='燕人张飞:BAAALgAFFAMJBAAAAA==.',
['狂燥']='狂燥苏大强:BAAALgAFFAIJAgAAAA==.',
['白鸽']='白鸽:BAABLgAECn8ZAAIDAAcJNR1AIAAOAgADAAcJNR1AIAAOAgAAAA==.',
['老人']='老人与海:BAAALgAFFAIJAgAAAA==.',
['肚皮']='肚皮很白:BAAALgADCgEJAQAAAA==.',
['至高']='至高岭肝肝:BAAALgAFFAEJAQAAAA==.',
['花落']='花落添愁:BAABLgAFFH8KAAIBAAQJLxVSCADpAAABAAQJLxVSCADpAAAAAA==.',
['莉莉']='莉莉斯:BAAALgADCgEJAQAAAA==.',
['莎拉']='莎拉凯瑞甘:BAAALgAFFAIJAgAAAA==.',
['藏起']='藏起来的猫:BAAALgAECgkJCQAAAA==.',
['虚空']='虚空寻觅者:BAAALgADCgEJAQAAAA==.虚空猎:BAAALgAECgEJAQAAAA==.',
['诀别']='诀别:BAAALgAECgcJCAAAAA==.',
['这小']='这小曲线:BAAALgAFFAIJAwAAAA==.',
['通号']='通号盘兴高铁:BAAALgAECgIJAQAAAA==.',
['邪焰']='邪焰:BAAALgAECgIJAgAAAA==.',
['部落']='部落一打铁的:BAAALgAECgYJBgAAAA==.',
['醉财']='醉财仙:BAAALgAECgEJAQAAAA==.',
['醉青']='醉青楼:BAAALgADCgEJAQAAAA==.',
['闪雷']='闪雷:BAAALgAECgkJCQAAAA==.',
['阿迷']='阿迷:BAAALgAECgYJEAAAAA==.',
['雪之']='雪之下雪乃:BAAALgAECgUJCAAAAA==.',
['香猪']='香猪贰:BAAALgAECgcJDwAAAA==.',
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
