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

local lookup = {'Priest-Holy','Mage-Frost','Paladin-Retribution','Rogue-Subtlety','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Paladin-Holy',}
local provider = {region='CN',realm='库德兰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Be='Beforetime:BAAALgAFFAEJAQAAAA==.',
Mi='Miquella:BAACLgAFFH8HAAIBAAMJSCYPCADnAAABAAMJSCYPCADnAAAuAAQKfyUAAgEACQkRInwBAGgDAAEACQkRInwBAGgDAAAA.',
Ry='Rykard:BAAALgAECggJCAABLgAFFAMJBwABAEgmAA==.',
Vo='Vor:BAABLgAFFH8IAAICAAQJAxuoFAB3AQACAAQJAxuoFAB3AQAAAA==.',
['三少']='三少:BAAALgADCgEJAQAAAA==.',
['中神']='中神父:BAAALgAECgMJAwAAAA==.',
['乔芭']='乔芭:BAAALgAECgIJAgAAAA==.',
['京红']='京红:BAAALgAFFAQJBAAAAA==.',
['会笑']='会笑的狼:BAAALgAECgkJCQAAAA==.',
['克里']='克里斯汀碧:BAAALgAECgUJBQAAAA==.',
['古灵']='古灵精怪:BAAALgAECgEJAgAAAA==.',
['叮铛']='叮铛叮铛:BAAALgAFFAIJAwAAAA==.',
['可爱']='可爱豆丨:BAAALgAECgcJBAAAAA==.',
['吖乌']='吖乌:BAAALgAECgQJBQAAAA==.',
['吹风']='吹风流:BAAALgADCgYJBgAAAA==.',
['咕咕']='咕咕胖咕咕胖:BAAALgAECgcJDwAAAA==.',
['哈娜']='哈娜:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光永恒:BAABLgAFFH8GAAIDAAQJSB3nBwB0AQADAAQJSB3nBwB0AQAAAA==.',
['夜长']='夜长梦会多:BAAALgAECgYJEQAAAA==.',
['大脚']='大脚丨浩克:BAAALgAECgYJDwAAAA==.',
['大花']='大花:BAAALgAECgIJAgAAAA==.',
['大酱']='大酱军:BAAALgAECgQJBgAAAA==.',
['天从']='天从云:BAAALgAECgcJCQAAAA==.',
['天天']='天天萧萧:BAAALgAECgQJBAAAAA==.',
['奶油']='奶油松饼:BAAALgAECgEJAQAAAA==.',
['妖神']='妖神:BAAALgAECgQJBAAAAA==.',
['小猪']='小猪:BAAALgAECgYJCAAAAA==.',
['慕风']='慕风眠:BAAALgADCgYJBgAAAA==.',
['憔悴']='憔悴的大伯:BAABLgAFFH8GAAIDAAMJFRHcFQD8AAADAAMJFRHcFQD8AAAAAA==.',
['懒之']='懒之鱼鱼:BAAALgAECgIJBAABLgAFFAYJCgAEAM8bAA==.',
['把我']='把我搁八队:BAAALgAECgEJAQAAAA==.',
['拉科']='拉科西斯:BAAALgAECggJCAAAAA==.',
['择一']='择一城终老丶:BAAALgAECgQJBAAAAA==.',
['拯救']='拯救之手:BAAALgAECgQJBAAAAA==.',
['无敌']='无敌葫芦娃:BAAALgADCgEJAQAAAA==.',
['昏睡']='昏睡紅茶丶:BAAALgAECgEJAQAAAA==.',
['有丶']='有丶毒:BAAALgAECgMJAwAAAA==.',
['未照']='未照耀的荣光:BAAALgAFFAEJAQAAAA==.',
['极乐']='极乐老人:BAAALgAFFAEJAgAAAA==.',
['樹总']='樹总:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡如风:BAAALgAECgUJBQAAAA==.',
['泡腾']='泡腾片:BAAALgAECgEJAgAAAA==.',
['流年']='流年堇色丶:BAAALgADCgEJAQAAAA==.',
['浪漫']='浪漫雾雨:BAAALgAECgIJAgAAAA==.',
['海鲜']='海鲜大咖:BAAALgAECgQJBAAAAA==.',
['熙年']='熙年丶:BAABLgAFFH8JAAMFAAQJcBgzAwAdAQAFAAMJiBczAwAdAQAGAAIJbR5vFQC8AAAAAA==.',
['爱夏']='爱夏路摩尔:BAAALgAECgkJEgABLgAFFAQJBAAHAAAAAA==.',
['牙好']='牙好:BAAALgAECgYJDAAAAA==.',
['玖拾']='玖拾:BAAALgAFFAIJBAAAAA==.',
['瓦王']='瓦王是我杀的:BAAALgAECgYJBgAAAA==.',
['皎洁']='皎洁:BAAALgAECgEJAQAAAA==.',
['皮卡']='皮卡皮卡:BAAALgAECgkJCwAAAA==.',
['神圣']='神圣一锤:BAAALgAECgUJBQAAAA==.',
['科罗']='科罗索:BAAALgAECgkJEgAAAA==.',
['绑上']='绑上帝:BAABLgAECn8VAAIDAAYJdBAalgBRAQADAAYJdBAalgBRAQAAAA==.',
['美洛']='美洛耶塔:BAAALgAECgcJBwAAAA==.',
['肥仔']='肥仔好叻:BAAALgAECgYJBwAAAA==.',
['膘人']='膘人:BAAALgAECgMJAwAAAA==.',
['良人']='良人与猫:BAAALgAECgYJCwAAAA==.',
['苏格']='苏格兰高鸟蛋:BAACLgAFFH8JAAIIAAMJcSQgCwAsAQAIAAMJcSQgCwAsAQAuAAQKfyAAAwgACAkUIwAIAO4CAAgACAkUIwAIAO4CAAMAAglAGMv9AJkAAAAA.',
['莉雅']='莉雅拉:BAAALgAECgUJBgAAAA==.',
['虎烈']='虎烈:BAAALgAECgUJBgAAAA==.',
['蛋炒']='蛋炒饭加俩蛋:BAAALgAECgIJAgAAAA==.',
['西山']='西山秋鱼:BAAALgAECgYJBwAAAA==.',
['西格']='西格格男拧:BAAALgAECgEJAQAAAA==.',
['言舞']='言舞許:BAAALgADCgIJAgAAAA==.',
['赛博']='赛博胖客:BAAALgAECgYJBgAAAA==.',
['超级']='超级女孩:BAAALgAFFAEJAQAAAA==.',
['酒舞']='酒舞二妻:BAAALgADCgEJAQAAAA==.',
['钉铛']='钉铛钉铛:BAAALgAECgEJAQAAAA==.',
['阳光']='阳光下的罪恶:BAAALgADCgQJBQAAAA==.',
['阿斌']='阿斌:BAABLgAECn8VAAIDAAcJchnkWADYAQADAAcJchnkWADYAQAAAA==.',
['霜语']='霜语人:BAAALgAECgEJAQAAAA==.',
['霸下']='霸下:BAAALgAECgUJBQAAAA==.',
['静水']='静水散人:BAAALgADCgEJAgAAAA==.',
['高松']='高松灯:BAAALgADCgYJBgAAAA==.',
['鱼崽']='鱼崽子:BAAALgAECgQJBQAAAA==.',
['黑魔']='黑魔女依丝特:BAAALgAECgkJEwABLgAFFAQJBAAHAAAAAA==.',
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
