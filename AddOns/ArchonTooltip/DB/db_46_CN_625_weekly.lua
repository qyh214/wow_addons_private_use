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

local lookup = {'Warlock-Demonology','Shaman-Elemental','Unknown-Unknown','DeathKnight-Unholy','Hunter-Survival','Hunter-BeastMastery','Mage-Frost',}
local provider = {region='CN',realm='塞拉赞恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Do='Doll:BAAALgAECgEJAQAAAA==.',
El='Elian:BAAALgAECgYJBgAAAA==.',
Ga='Gastonxudu:BAACLgAFFH8LAAIBAAMJww1xKADVAAABAAMJww1xKADVAAAuAAQKfxkAAgEACAmNEORYAL0BAAEACAmNEORYAL0BAAAA.',
Go='Goozi:BAAALgAECgYJCgAAAA==.Gozi:BAACLgAFFH8HAAICAAMJjxObDwD3AAACAAMJjxObDwD3AAAuAAQKfxsAAgIACAmdH8cLAN0CAAIACAmdH8cLAN0CAAAA.',
Hy='Hysteria:BAAALgADCgkJDwAAAA==.Hysteriab:BAAALgAECgYJCgAAAA==.',
Ma='Mamba:BAAALgAECgcJCAAAAA==.',
Na='Napie:BAAALgAECgcJCQAAAA==.',
Oo='Oops:BAAALgAECgYJBgAAAA==.',
['一级']='一级天灾:BAAALgAECgYJCAAAAA==.',
['不会']='不会取名好烦:BAAALgAECgYJCwAAAA==.',
['东方']='东方未央:BAAALgADCgUJBwAAAA==.',
['乱世']='乱世螺蛳粉:BAAALgADCgYJBgAAAA==.',
['冬虫']='冬虫夏草:BAAALgAECgkJDgAAAA==.',
['凛冬']='凛冬将至:BAAALgAECgYJBgAAAA==.',
['刚猎']='刚猎:BAAALgAECgEJAQAAAA==.',
['功夫']='功夫熊猫灬:BAAALgADCgIJAgAAAA==.',
['加里']='加里维克斯:BAAALgAECgEJAQAAAA==.',
['卡莉']='卡莉丝丨暮光:BAAALgAECgYJBgABLgAFFAIJAQADAAAAAA==.',
['双鱼']='双鱼座:BAAALgAECgYJCQAAAA==.',
['呜喵']='呜喵王:BAAALgAECgEJAgAAAA==.',
['咻二']='咻二二:BAAALgAFFAIJAgABLgAFFAYJDQAEAE8YAA==.咻二五:BAABLgAFFH8NAAIEAAYJTxhWBAC6AQAEAAYJTxhWBAC6AQAAAA==.咻二四:BAABLgAFFH8GAAIEAAQJdxKLEABfAQAEAAQJdxKLEABfAQABLgAFFAYJDQAEAE8YAA==.',
['四不']='四不四傻:BAAALgAECgEJAQAAAA==.',
['圈小']='圈小鸟圈:BAAALgAECgEJAgAAAA==.',
['塞拉']='塞拉赞恩牛:BAAALgAECgEJAQAAAA==.',
['夙月']='夙月:BAAALgADCgMJAwAAAA==.',
['夜孤']='夜孤行:BAAALgAECgIJAgAAAA==.',
['小璟']='小璟:BAAALgAECgUJBQAAAA==.',
['小雪']='小雪飘零:BAAALgAECgcJCAAAAA==.',
['小鸟']='小鸟:BAAALgAECgMJBgAAAA==.',
['庇护']='庇护审判:BAAALgAECgQJBAAAAA==.',
['德罗']='德罗西:BAAALgAECgcJCQAAAA==.',
['性感']='性感大脚丫:BAAALgAECgYJCAAAAA==.',
['我叫']='我叫刘华强:BAAALgADCgEJAQAAAA==.',
['拾壹']='拾壹:BAAALgAECgYJCgAAAA==.',
['揽胜']='揽胜:BAAALgAECgEJAQAAAA==.',
['无双']='无双上将:BAAALgAECgcJDwAAAA==.',
['无情']='无情:BAAALgAECgcJCgAAAA==.',
['晴天']='晴天悠悠:BAAALgAECgIJAgAAAA==.',
['梦再']='梦再续殷缘:BAAALgAECgUJBwAAAA==.',
['毛毛']='毛毛月:BAAALgAECgIJAgAAAA==.',
['淡妆']='淡妆卿墨:BAAALgAFFAIJAwAAAA==.',
['游侠']='游侠一崔斯特:BAAALgADCgUJBQAAAA==.',
['狗蛋']='狗蛋丶:BAACLgAFFH8KAAICAAMJRiAHDQAeAQACAAMJRiAHDQAeAQAuAAQKfx4AAgIABwmTITwRAJsCAAIABwmTITwRAJsCAAAA.',
['玛萨']='玛萨起飞:BAAALgADCgEJAQAAAA==.',
['睡觉']='睡觉达人:BAAALgAECgYJCAAAAA==.',
['破万']='破万卷:BAAALgADCgEJAQAAAA==.',
['破嗯']='破嗯哈博:BAAALgADCgUJBQAAAA==.',
['碎花']='碎花雨:BAAALgAFFAIJAgABLgAFFAYJEgACADgjAA==.',
['红烧']='红烧肉丶:BAAALgAECgYJBgAAAA==.',
['艾达']='艾达梅斯默:BAAALgAFFAIJAQAAAA==.',
['芙蓉']='芙蓉王源:BAAALgAECgkJCQAAAA==.',
['花田']='花田错:BAAALgAECgUJBQAAAA==.',
['荒天']='荒天帝:BAAALgAFFAIJAwAAAA==.',
['萌萌']='萌萌旳拖拖:BAAALgAECgcJCQAAAA==.',
['蒼瑶']='蒼瑶:BAAALgAECgEJAQAAAA==.',
['蛋蛋']='蛋蛋:BAAALgAECgIJAwAAAA==.',
['諾伊']='諾伊伊:BAAALgAECgEJAQAAAA==.',
['诺雪']='诺雪:BAAALgAECgcJDQAAAA==.',
['贵州']='贵州小女孩:BAAALgAECgYJDAAAAA==.',
['这个']='这个层数奔放:BAAALgAECgcJEwAAAA==.',
['那羅']='那羅無双華:BAABLgAECn8aAAMFAAgJ1BrZAgDiAQAFAAgJuA7ZAgDiAQAGAAcJ7h1qaAAvAQAAAA==.',
['里克']='里克休比:BAAALgAECgcJEAABLgAFFAUJBwAHAMcZAA==.',
['阿伦']='阿伦不吃寄:BAAALgAECgYJBgAAAA==.阿伦不吃龙:BAAALgAFFAIJAgAAAA==.',
['鞭子']='鞭子硬:BAAALgADCgUJBgAAAA==.',
['骑个']='骑个隆咚呛:BAAALgAECgEJAQAAAA==.',
['骑德']='骑德龙的德:BAAALgAECgcJDQAAAA==.骑德龙的龙:BAAALgAECgUJBQABLgAECgcJDQADAAAAAA==.',
['龙骑']='龙骑士骑龙:BAAALgAFFAIJAgAAAA==.',
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
