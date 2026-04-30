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

local lookup = {'Warlock-Demonology','Warlock-Destruction','DemonHunter-Havoc','Shaman-Elemental','Hunter-BeastMastery',}
local provider = {region='CN',realm='萨洛拉丝',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ch='Chenzz:BAAALgAFFAMJAwAAAA==.',
Dm='Dmyl:BAAALgAECgYJDwAAAA==.',
Ho='Hotop:BAAALgAECgMJAwAAAA==.',
Je='Jeroo:BAAALgAECgYJBgAAAA==.',
Re='Rexom:BAAALgAECgMJBQAAAA==.',
Sr='Srdhrr:BAAALgADCgEJAQAAAA==.',
Ty='Tydrande:BAAALgAECgIJAgAAAA==.',
Yi='Yinga:BAAALgAECggJCAAAAA==.Yingc:BAAALgAECgkJCwAAAA==.Yings:BAAALgAECgcJBwAAAA==.',
Yu='Yukicool:BAAALgAECgQJBAAAAA==.',
['一梦']='一梦红尘:BAAALgADCgIJAgAAAA==.',
['丑哥']='丑哥说我蛮丑:BAAALgAECgQJBAAAAA==.',
['世界']='世界小怪兽:BAAALgAECgUJBQAAAA==.',
['丨打']='丨打獵的灬:BAAALgAECgQJBwAAAA==.',
['丶一']='丶一曲离骚:BAAALgAECgUJCQAAAA==.',
['丶雨']='丶雨雾晴晨:BAAALgAECgYJBwAAAA==.',
['你三']='你三叔的表哥:BAABLgAFFH8IAAMBAAMJ5ReZHgAJAQABAAMJ5ReZHgAJAQACAAEJNAcHCABNAAAAAA==.',
['你刘']='你刘姥姥:BAAALgADCgEJAQAAAA==.',
['偶来']='偶来丶酱油:BAAALgADCgYJBgAAAA==.',
['冲锋']='冲锋丶断尾:BAAALgAECggJCAAAAA==.',
['剩光']='剩光啊忽悠我:BAAALgAFFAEJAQAAAA==.',
['劉氓']='劉氓头子丶:BAAALgAECgYJCAAAAA==.',
['召命']='召命:BAAALgADCgcJBwAAAA==.',
['咆哮']='咆哮的天空:BAAALgADCgEJAQAAAA==.',
['喂你']='喂你绿粑:BAAALgAECgEJAgAAAA==.',
['喵的']='喵的咪的咪:BAAALgADCgQJBAAAAA==.',
['圣光']='圣光来也:BAAALgAECgMJAwAAAA==.',
['在等']='在等月亮吗:BAAALgAECgEJAQAAAA==.',
['天意']='天意如此:BAAALgAECgIJAwAAAA==.',
['她只']='她只是朋友:BAAALgAECgIJAgAAAA==.',
['宮胁']='宮胁咲良:BAAALgAECgEJAQAAAA==.',
['小三']='小三有木有:BAAALgAECgYJDQAAAA==.',
['巴纳']='巴纳泽尔:BAAALgAECgYJBwAAAA==.',
['帅气']='帅气泡芙:BAAALgAECgIJAwAAAA==.帅气趣多多:BAAALgADCgMJAwAAAA==.帅气饼干:BAAALgAECgQJBQAAAA==.',
['幽昙']='幽昙冷烟:BAAALgAECgYJDgAAAA==.',
['影殇']='影殇:BAAALgAECgkJEwAAAA==.',
['我不']='我不认识你:BAAALgAECgIJAgAAAA==.',
['断尾']='断尾求生:BAAALgAECgIJAgAAAA==.',
['施工']='施工方头:BAAALgAECgEJBAAAAA==.',
['有梦']='有梦想的男刀:BAABLgAFFH8FAAIDAAIJwBDGBACcAAADAAIJwBDGBACcAAAAAA==.',
['朔风']='朔风煞:BAAALgAECgcJCAAAAA==.',
['李玄']='李玄胤:BAAALgAECgEJAgAAAA==.',
['樱噬']='樱噬妖空:BAAALgADCgEJAQAAAA==.',
['樱花']='樱花咲良:BAAALgAECgEJAQAAAA==.',
['欧罗']='欧罗路拉:BAAALgADCgEJAQAAAA==.',
['气死']='气死我了:BAAALgAFFAEJAQAAAA==.',
['汉考']='汉考克:BAAALgAECgYJBgAAAA==.',
['沅有']='沅有芷兮:BAAALgAECgIJAgAAAA==.',
['灬玛']='灬玛尔扎哈灬:BAAALgAECgEJAQAAAA==.',
['燃雨']='燃雨:BAAALgAECgIJAgAAAA==.',
['爆炸']='爆炸小裤衩:BAAALgAECgEJAQAAAA==.',
['牛多']='牛多多:BAAALgADCgMJAwAAAA==.',
['狐哩']='狐哩狐:BAAALgAECgUJCwAAAA==.',
['猛牛']='猛牛酸酸乳:BAAALgADCgIJAgAAAA==.',
['白太']='白太郎:BAAALgAECgIJAgAAAA==.',
['白衣']='白衣勝雪丶:BAAALgAFFAEJAQAAAA==.',
['福山']='福山雅治丶:BAAALgADCgEJAQAAAA==.',
['科长']='科长六号:BAAALgAFFAQJAwAAAA==.科长四号:BAABLgAFFH8HAAIEAAcJZiAHAACRAgAEAAcJZiAHAACRAgAAAA==.',
['符氏']='符氏木头人:BAAALgAECgUJEAAAAA==.',
['等会']='等会儿:BAACLgAFFH8FAAIFAAIJGhrYEgC3AAAFAAIJGhrYEgC3AAAuAAQKfxgAAgUACAmIHGMSAKUCAAUACAmIHGMSAKUCAAAA.',
['米开']='米开朗煎圆:BAAALgADCgIJAgAAAA==.',
['花生']='花生牛腩:BAAALgAECgUJBgAAAA==.',
['花羽']='花羽珞:BAAALgAECgcJDgAAAA==.',
['诶儿']='诶儿:BAAALgAECgEJAQAAAA==.',
['走起']='走起撒:BAAALgAFFAIJAgAAAA==.',
['超导']='超导体:BAAALgAFFAQJAgAAAA==.',
['逗战']='逗战胜佛:BAABLgAFFH8FAAIFAAMJ1RAWCgAIAQAFAAMJ1RAWCgAIAQAAAA==.',
['铁柱']='铁柱八号:BAAALgADCgEJAQAAAA==.铁柱哥:BAAALgAECgIJAgAAAA==.',
['霸道']='霸道无双:BAAALgAECgMJBgAAAA==.',
['饭丨']='饭丨饭:BAAALgAECgMJAwAAAA==.',
['骑马']='骑马多多:BAAALgAECgEJAQAAAA==.',
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
