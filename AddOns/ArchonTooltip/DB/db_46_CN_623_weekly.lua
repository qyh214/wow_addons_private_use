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

local lookup = {'Mage-Frost','DemonHunter-Havoc','Monk-Mistweaver','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Unknown-Unknown','Monk-Brewmaster','Hunter-BeastMastery','Priest-Shadow',}
local provider = {region='CN',realm='塔纳利斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ax='Axb:BAAALgADCgQJBAAAAA==.',
Ma='Maxi:BAAALgAECgEJAQAAAA==.Maxiws:BAAALgAECgQJBgAAAA==.',
Mu='Muda:BAAALgAECgcJBwAAAA==.',
['与风']='与风同行:BAAALgAECgEJAQAAAA==.',
['丨死']='丨死亡寒灰丨:BAAALgADCgMJAwAAAA==.',
['九十']='九十九夜:BAAALgAECgIJAgAAAA==.',
['亚尔']='亚尔维斯:BAAALgAECgIJAgAAAA==.',
['亮丽']='亮丽同行:BAAALgAECgQJBAAAAA==.',
['仙人']='仙人抚我顶:BAAALgAECgYJCAAAAA==.',
['传说']='传说冰有泪:BAAALgAECgEJAQAAAA==.',
['佛系']='佛系大盗贼:BAAALgADCgUJBQAAAA==.佛系晓发丝:BAAALgADCgEJAQAAAA==.',
['你先']='你先斩:BAAALgAECgEJAgAAAA==.',
['倩丷']='倩丷:BAAALgAECgEJAQAAAA==.',
['偷你']='偷你光光:BAAALgAECgYJBgAAAA==.',
['傲剑']='傲剑凌殇:BAAALgADCgEJAQAAAA==.',
['傲魂']='傲魂魅影:BAABLgAFFH8IAAIBAAMJzQU9MQDqAAABAAMJzQU9MQDqAAAAAA==.',
['元宝']='元宝去看海:BAAALgAECgEJAQAAAA==.',
['元滚']='元滚滚的宝:BAAALgAECgQJBAAAAA==.',
['剩骑']='剩骑士啊:BAAALgAECgQJBwAAAA==.',
['吥二']='吥二:BAAALgAECgUJBwAAAA==.',
['命运']='命运之大德:BAAALgAECgUJBQAAAA==.',
['咖啡']='咖啡背后:BAAALgAFFAIJAgAAAA==.',
['哈丶']='哈丶卵卵:BAAALgAECgYJBgAAAA==.',
['嘻嘻']='嘻嘻嘿嘿吼吼:BAAALgAECgUJBQAAAA==.',
['回城']='回城补个妆:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光有点皮:BAAALgAECgMJBAAAAA==.',
['夹心']='夹心灬盖伦:BAABLgAFFH8GAAICAAMJ+B3lBgDMAAACAAMJ+B3lBgDMAAAAAA==.夹心甜点:BAACLgAFFH8GAAIBAAIJSiI/MwDPAAABAAIJSiI/MwDPAAAuAAQKfxgAAgEACAmFIZYYABcDAAEACAmFIZYYABcDAAAA.',
['完美']='完美斩杀:BAAALgAECgYJBwAAAA==.',
['小灬']='小灬鲁:BAAALgADCgUJBQAAAA==.',
['小眼']='小眼勾魂:BAAALgADCgcJBwAAAA==.',
['小骑']='小骑士就是我:BAAALgAECggJDAAAAA==.',
['小龙']='小龙:BAAALgAECgcJBwAAAA==.',
['巅峰']='巅峰小学生:BAAALgADCgEJAQAAAA==.',
['幽煌']='幽煌:BAAALgAECgkJCQAAAA==.',
['弯弯']='弯弯的太阳:BAAALgAECgcJDAAAAA==.',
['我了']='我了个去:BAAALgADCgMJBAAAAA==.',
['斯特']='斯特莱夫:BAAALgADCgcJBwAAAA==.',
['月翼']='月翼猫头鹰:BAAALgAFFAUJAwAAAA==.',
['望天']='望天大树:BAAALgAECgcJCAAAAA==.',
['枫雨']='枫雨萧萧:BAAALgADCgEJAQAAAA==.',
['桐谷']='桐谷和人:BAAALgAECgEJAQAAAA==.',
['梦寐']='梦寐龙:BAAALgAECgYJCgAAAA==.',
['梦辰']='梦辰相拥:BAAALgAFFAIJAgAAAA==.',
['梦魂']='梦魂:BAABLgAECn8cAAIDAAgJ+R9eBgD5AgADAAgJ+R9eBgD5AgAAAA==.',
['森沪']='森沪老卵:BAAALgAECgYJBgAAAA==.',
['橘子']='橘子气味水五:BAAALgAFFAEJAQAAAA==.橘子气味水四:BAAALgAECgIJAQAAAA==.',
['此名']='此名受到限制:BAABLgAECn8VAAMEAAcJexPxTwDYAQAEAAcJexPxTwDYAQAFAAEJDgkTMgA5AAAAAA==.',
['水是']='水是这样喝的:BAAALgAECgIJAwAAAA==.',
['波丶']='波丶:BAAALgAFFAEJAQAAAA==.',
['洄游']='洄游鱼丶:BAACLgAFFH8HAAIEAAMJRhtvGwAZAQAEAAMJRhtvGwAZAQAuAAQKfxYABAQACAkmI28LAB8DAAQACAmDIm8LAB8DAAYAAQkwJFtXAGgAAAUAAQkAALYjAGMAAAAA.',
['浩法']='浩法无伤:BAAALgAECgUJBQAAAA==.',
['潇湘']='潇湘水云:BAAALgADCgUJBQABLgAECgEJAgAHAAAAAA==.',
['潇潇']='潇潇:BAAALgAECgEJAQAAAA==.',
['火灬']='火灬火:BAAALgADCgYJCwAAAA==.',
['烬余']='烬余:BAAALgADCgIJAgAAAA==.',
['琻刚']='琻刚娃转转猴:BAABLgAFFH8OAAIIAAQJWAg1EAD/AAAIAAQJWAg1EAD/AAAAAA==.',
['痛并']='痛并快乐:BAACLgAFFH8EAAIJAAIJtwriGQCfAAAJAAIJtwriGQCfAAAuAAQKfxcAAgkABwkFHpUiADYCAAkABwkFHpUiADYCAAAA.',
['箭过']='箭过无痕:BAAALgAECgUJBwAAAA==.',
['绿罩']='绿罩子:BAAALgAECgYJEAAAAA==.',
['芙蘭']='芙蘭朵露:BAAALgADCgQJBAAAAA==.',
['英雄']='英雄哥:BAAALgADCgQJBAAAAA==.',
['菠萝']='菠萝菠萝宝:BAAALgAECgEJAQAAAA==.',
['萨魔']='萨魔:BAAALgAFFAIJAwAAAA==.',
['蕊丿']='蕊丿:BAAALgAECgMJBQAAAA==.',
['血域']='血域幽魂:BAAALgAFFAIJAwAAAA==.',
['角斗']='角斗士的灵魂:BAAALgADCgYJBgABLgAFFAUJEQAKAIwhAA==.',
['詠遠']='詠遠的記憶:BAAALgAECgYJBgAAAA==.',
['越喝']='越喝越有:BAAALgAECgMJBQAAAA==.',
['踢零']='踢零输出:BAAALgAECgUJBQAAAA==.',
['逆襲']='逆襲:BAAALgAECgEJAQAAAA==.',
['逍遥']='逍遥卡德甲:BAAALgAFFAQJBAAAAA==.逍遥无边:BAAALgADCgEJAQAAAA==.',
['锤子']='锤子:BAAALgAECgcJDAAAAA==.',
['长泽']='长泽雅美:BAAALgAECgcJBwAAAA==.',
['风之']='风之祖:BAAALgADCgIJAgAAAA==.',
['风枫']='风枫叶飘飘:BAAALgADCgcJBwAAAA==.',
['风玫']='风玫影:BAAALgAECgUJBQAAAA==.',
['风风']='风风叶飘飘:BAAALgADCgEJAQAAAA==.',
['飞天']='飞天鹌鹑:BAAALgAECgYJBgAAAA==.',
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
