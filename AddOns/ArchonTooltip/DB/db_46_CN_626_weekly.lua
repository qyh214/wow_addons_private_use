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

local lookup = {'Priest-Holy','Paladin-Retribution','Monk-Brewmaster','Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Arms','Warrior-Fury',}
local provider = {region='CN',realm='塞泰克',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ah='Ahunter:BAAALgAECgMJBgAAAA==.',
Sv='Sven:BAAALgAECgQJBAAAAA==.',
Ye='Yebo:BAAALgAECgYJEAAAAA==.',
['万能']='万能小酱油:BAAALgAECgYJCgAAAA==.',
['不萌']='不萌不术:BAAALgAECgIJAgAAAA==.',
['伊力']='伊力丹驽风:BAAALgADCgEJAQAAAA==.',
['克里']='克里斯哲别:BAAALgAECgEJAQAAAA==.',
['卡比']='卡比亚修斯:BAAALgADCgYJBwAAAA==.',
['卤花']='卤花花拌瓜瓜:BAAALgAECgMJAwAAAA==.',
['卤蛋']='卤蛋蛋光头头:BAAALgAECgcJBwAAAA==.卤蛋蛋死球球:BAAALgAECgYJDQAAAA==.',
['双采']='双采德:BAAALgADCgYJBgAAAA==.',
['吆吆']='吆吆钉钉阔:BAAALgAECgYJDQAAAA==.',
['喵小']='喵小雪:BAAALgAECgYJBgABLgAECgcJFgABABAgAA==.',
['嗜血']='嗜血玫瑰:BAAALgADCgMJBQAAAA==.',
['圣夜']='圣夜:BAAALgAECgEJAQAAAA==.',
['夏日']='夏日青提拿铁:BAAALgAECgUJBwAAAA==.',
['夏末']='夏末海盐拿铁:BAAALgAECgYJBgAAAA==.',
['夜德']='夜德明:BAAALgAECgQJBAAAAA==.',
['大明']='大明永乐:BAABLgAFFH8FAAICAAMJzggTGQDgAAACAAMJzggTGQDgAAAAAA==.',
['大玉']='大玉兒:BAABLgAFFH8FAAIBAAMJJARICgDCAAABAAMJJARICgDCAAAAAA==.',
['天下']='天下凡:BAAALgADCgEJAQAAAA==.',
['好家']='好家伙:BAAALgAECgYJDgAAAA==.',
['安多']='安多米尔:BAAALgAECgEJAQAAAA==.',
['寒秋']='寒秋:BAAALgAECgQJBAAAAA==.',
['小斑']='小斑点:BAAALgAECgIJAgAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8OAAIDAAUJdBqxAwCjAQADAAUJdBqxAwCjAQAAAA==.',
['帕尔']='帕尔默:BAAALgAFFAEJAQAAAA==.',
['幻云']='幻云迷踪:BAAALgAECgIJAgAAAA==.',
['度她']='度她余生:BAAALgAECgUJBgAAAA==.',
['德財']='德財兼唄:BAAALgAECgEJAQAAAA==.',
['我没']='我没喊你名字:BAAALgAECgEJAgAAAA==.',
['战魂']='战魂之天下:BAAALgADCgYJCgAAAA==.',
['托尼']='托尼丶克罗斯:BAAALgAECgUJDAAAAA==.',
['指甲']='指甲破武术:BAACLgAFFH8FAAIEAAIJJwapHQCeAAAEAAIJJwapHQCeAAAuAAQKfx8AAgQACAlCEkpoAAYCAAQACAlCEkpoAAYCAAAA.',
['新盗']='新盗帅留香:BAAALgAECgEJAQAAAA==.',
['春风']='春风和熙:BAAALgADCgEJAQAAAA==.',
['暗黑']='暗黑汤圆:BAAALgAECgEJAQAAAA==.',
['朗基']='朗基努斯:BAAALgAECgQJBgAAAA==.',
['木之']='木之鑫:BAAALgAECgEJAQAAAA==.',
['橘汁']='橘汁:BAAALgADCgEJAQAAAA==.',
['橙丿']='橙丿酱:BAAALgAFFAEJAgAAAA==.',
['毛团']='毛团曾经:BAAALgAECgYJDQAAAA==.',
['永远']='永远爱果果:BAAALgAECgYJCAAAAA==.',
['涵宝']='涵宝儿:BAAALgAECgUJBQAAAA==.',
['火焰']='火焰飞丝:BAAALgAECgEJAgAAAA==.',
['焸貓']='焸貓:BAAALgAECgYJEgAAAA==.',
['爱吃']='爱吃面条:BAAALgADCgEJAQAAAA==.爱吃馒头:BAAALgADCgYJBgAAAA==.',
['现金']='现金银行:BAAALgAECgQJBAAAAA==.',
['瑜瑾']='瑜瑾:BAAALgADCgEJAQAAAA==.',
['痞子']='痞子:BAAALgADCgUJAQAAAA==.',
['白狼']='白狼杰洛特:BAAALgADCgMJAQAAAA==.',
['秀旗']='秀旗不努力:BAAALgAECgEJAgAAAA==.',
['细嗅']='细嗅蔷薇:BAAALgAECgEJAQAAAA==.',
['舞袖']='舞袖夕茗:BAAALgAECgIJAwAAAA==.',
['花果']='花果山在逃猴:BAAALgAFFAEJAQAAAA==.',
['萌死']='萌死了死萌:BAAALgAECgQJBAAAAA==.',
['蒙塔']='蒙塔鸡钢蛋:BAAALgAECgYJCAAAAA==.',
['蓝小']='蓝小小:BAAALgAECgYJBwAAAA==.',
['蓝猫']='蓝猫猫:BAAALgAECgQJCgAAAA==.',
['贴贴']='贴贴:BAAALgAECggJCwAAAA==.',
['远子']='远子:BAAALgAECgIJAgAAAA==.',
['迷彩']='迷彩小当家:BAAALgAECgEJAQAAAA==.',
['逝去']='逝去随风:BAAALgAECgYJAgAAAA==.',
['遗弃']='遗弃紫玫瑰:BAAALgAECgkJEAAAAA==.',
['阿宝']='阿宝:BAAALgAECgIJAgAAAA==.',
['陆雪']='陆雪琪:BAAALgAECgYJDAAAAA==.',
['陈老']='陈老师丨法:BAAALgAECgYJBgAAAA==.',
['隔壁']='隔壁射鸡的:BAACLgAFFH8GAAIFAAMJQRNBCwAIAQAFAAMJQRNBCwAIAQAuAAQKfxoAAwUACAlQG6MMANsCAAUACAlQG6MMANsCAAYABgndEHlBAFEBAAAA.',
['面包']='面包人:BAAALgAECgEJAgAAAA==.',
['风起']='风起黄昏:BAACLgAFFH8KAAMHAAQJZxx4AQB+AQAHAAQJZxx4AQB+AQAIAAIJWRshFgCzAAAuAAQKfxcAAwgACAldIXYbAHECAAgABwlzIXYbAHECAAcAAwnnHy0bABgBAAAA.',
['馨梦']='馨梦:BAAALgAECgYJBgAAAA==.',
['龙井']='龙井虾仁:BAAALgAECgYJCAAAAA==.',
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
