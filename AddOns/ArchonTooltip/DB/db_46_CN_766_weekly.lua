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

local lookup = {'Paladin-Retribution','Warrior-Protection','Druid-Balance','Mage-Frost','Unknown-Unknown','Paladin-Holy','DeathKnight-Unholy','Priest-Holy','Priest-Discipline','Priest-Shadow',}
local provider = {region='CN',realm='瓦拉斯塔兹',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ch='Chinamobile:BAACLgAFFH8IAAIBAAMJsR1/CQAbAQABAAMJsR1/CQAbAQAuAAQKfxQAAgEABwmXIhEdALwCAAEABwmXIhEdALwCAAAA.',
Co='Comremors:BAAALgAECgcJDQAAAA==.',
Ed='Edan:BAAALgAECgIJAgAAAA==.',
Ga='Gawain:BAAALgAECgIJAgAAAA==.',
Ic='Iceredtea:BAAALgAECgQJBQAAAA==.',
La='Laknight:BAAALgAECgkJCQAAAA==.',
Sl='Slytherin:BAAALgADCgYJBgAAAA==.',
['万恶']='万恶人为一:BAAALgADCgQJBAAAAA==.',
['万碧']='万碧瑶:BAAALgADCgEJAQAAAA==.',
['万纯']='万纯:BAAALgAECgEJAQAAAA==.',
['东关']='东关咚咚霸:BAAALgAECgEJAgAAAA==.',
['东隅']='东隅:BAAALgADCgcJBwAAAA==.',
['丨上']='丨上善若水:BAAALgAECgQJBAAAAA==.',
['丶蓝']='丶蓝骑:BAAALgADCgEJAQAAAA==.',
['丷重']='丷重返巅峰丷:BAAALgAECgEJAQABLgAFFAUJCgACAHUSAA==.',
['乐子']='乐子恶霸:BAAALgADCgEJAQAAAA==.',
['二手']='二手丶月季:BAAALgAECgEJAQAAAA==.二手幕丝:BAAALgADCgcJBgAAAA==.',
['亵渎']='亵渎:BAAALgAECgEJAQAAAA==.',
['人帅']='人帅被人欺:BAAALgAECgMJAwAAAA==.',
['伊珞']='伊珞恩:BAACLgAFFH8HAAIDAAMJXRwvDQAMAQADAAMJXRwvDQAMAQAuAAQKfxoAAgMACAlFIngJAP0CAAMACAlFIngJAP0CAAAA.',
['保安']='保安恶霸:BAAALgAECgEJAQAAAA==.',
['傲气']='傲气嗜战:BAAALgAECgMJAwAAAA==.傲气寒冰:BAAALgADCgEJAQAAAA==.',
['光輝']='光輝成就:BAAALgADCgQJBAAAAA==.',
['兔巴']='兔巴妹:BAAALgADCgEJAQAAAA==.',
['八宝']='八宝花:BAAALgAECgIJAwAAAA==.',
['养了']='养了只羊:BAAALgAECgUJBQAAAA==.',
['出货']='出货恶霸:BAAALgAECgMJAwAAAA==.',
['勿入']='勿入天堂:BAABLgAFFH8IAAIEAAIJ2SG5HQDCAAAEAAIJ2SG5HQDCAAAAAA==.',
['十六']='十六兄:BAAALgAECgEJAgAAAA==.',
['南家']='南家丨夏奈:BAACLgAFFH8MAAIEAAQJbxnPFgBuAQAEAAQJbxnPFgBuAQAuAAQKfx0AAgQACAk5JGUUAC4DAAQACAk5JGUUAC4DAAAA.',
['君醉']='君醉笑葒颜:BAAALgADCgUJBQAAAA==.',
['哇丶']='哇丶哈哈:BAAALgADCgMJAwAAAA==.',
['唐鸢']='唐鸢别闹了:BAAALgAFFAMJBAAAAA==.',
['嗜血']='嗜血的圣光:BAAALgADCgIJAgAAAA==.',
['嘿小']='嘿小猩猩:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光同行:BAAALgADCgMJAwAAAA==.',
['圣尔']='圣尔乌班:BAAALgAECgEJAQAAAA==.',
['大帝']='大帝丶:BAAALgAECgEJAgAAAA==.',
['太老']='太老爷:BAAALgAFFAQJBAAAAA==.',
['奈何']='奈何桥灬渡:BAAALgAECgEJAQAAAA==.',
['小嘿']='小嘿:BAAALgAECgYJBgAAAA==.',
['小地']='小地瓜蛋:BAAALgADCgMJAwAAAA==.',
['小小']='小小瑞鸡:BAAALgAECgEJAQAAAA==.',
['小旋']='小旋风:BAAALgAECgEJAQAAAA==.',
['小瑞']='小瑞鸡:BAAALgAECgEJAQAAAA==.',
['小男']='小男孩:BAAALgAECgEJAQAAAA==.',
['尐灬']='尐灬洒满:BAAALgAECgQJCAABLgAFFAQJBAAFAAAAAA==.尐灬牧丝:BAAALgADCgUJBQAAAA==.尐灬骑师:BAAALgADCgYJBgAAAA==.',
['岁月']='岁月的童话丿:BAAALgADCgEJAQAAAA==.',
['幂夜']='幂夜:BAAALgADCgYJBgAAAA==.',
['愤怒']='愤怒的大虾:BAAALgADCgQJBAAAAA==.',
['打我']='打我拿本记你:BAAALgAECgYJAwAAAA==.',
['旋律']='旋律灬花溪:BAAALgAECgEJAQAAAA==.',
['无影']='无影山:BAAALgADCgUJBQAAAA==.',
['星願']='星願丿天堂:BAAALgAECgYJBgAAAA==.',
['暗暗']='暗暗牧:BAAALgAECgYJDgAAAA==.',
['暴怒']='暴怒丨天使:BAAALgADCgYJBgAAAA==.',
['曾经']='曾经的春风:BAAALgAECgEJAQAAAA==.',
['月中']='月中丹桂:BAAALgAECgIJAwAAAA==.',
['来福']='来福:BAAALgAECgYJBgAAAA==.',
['欢愉']='欢愉恶霸:BAAALgAECgQJBAAAAA==.',
['死神']='死神丨梦魇:BAAALgAECgMJBAAAAA==.',
['永恒']='永恒暮光:BAAALgADCgIJAgAAAA==.',
['泰兰']='泰兰徳:BAAALgAECgMJAwAAAA==.',
['洞庭']='洞庭皮皮虾:BAAALgAECgEJAQABLgAFFAYJFQAGABkcAA==.',
['浪子']='浪子无脚鸟:BAAALgAFFAMJAwAAAA==.',
['渴饮']='渴饮风霜:BAAALgADCgQJBAAAAA==.',
['满满']='满满回忆:BAABLgAECn8ZAAIHAAgJGxf+UAD/AQAHAAgJGxf+UAD/AQAAAA==.',
['牛牪']='牛牪犇:BAAALgAFFAIJAgAAAA==.',
['牛逼']='牛逼德:BAAALgAECgIJAwAAAA==.',
['狂澜']='狂澜:BAAALgAECgEJAQAAAA==.',
['狼雪']='狼雪:BAAALgAECgUJCAAAAA==.',
['珐岚']='珐岚:BAAALgAECgMJBAAAAA==.',
['碧雪']='碧雪琪:BAABLgAFFH8GAAIEAAQJCxjlFwBqAQAEAAQJCxjlFwBqAQAAAA==.',
['穆斯']='穆斯二号:BAABLgAECn8bAAIBAAkJbxp5EgD/AgABAAkJbxp5EgD/AgAAAA==.',
['等下']='等下个季节:BAAALgAECgMJAwAAAA==.',
['血夜']='血夜圣光:BAAALgADCgMJAwAAAA==.',
['诡异']='诡异的丹:BAAALgADCgEJAQAAAA==.诡异的傲:BAACLgAFFH8GAAIBAAMJphTzCwAFAQABAAMJphTzCwAFAQAuAAQKfxUAAgEABglWF+OFAG4BAAEABglWF+OFAG4BAAAA.诡异的猎:BAAALgAFFAEJAQAAAA==.',
['说了']='说了再见:BAAALgAECgYJCwAAAA==.',
['辞暮']='辞暮尔尔丶:BAAALgAECgQJBAAAAA==.',
['逍遥']='逍遥:BAAALgAECgEJAQAAAA==.',
['那天']='那天下雨了:BAABLgAFFH8IAAQIAAMJtxyiBgCpAAAJAAIJVR5kEQCwAAAIAAIJ3BqiBgCpAAAKAAEJXSDeEgBeAAAAAA==.',
['郑映']='郑映宇:BAAALgADCgYJBgAAAA==.',
['长卿']='长卿:BAAALgADCgIJAgAAAA==.',
['霸气']='霸气双刀:BAAALgAECgUJBQAAAA==.',
['飞天']='飞天:BAAALgADCgYJBgAAAA==.',
['驱风']='驱风者:BAAALgAECgQJBAAAAA==.',
['鬼脸']='鬼脸落堕:BAAALgADCgEJAQAAAA==.',
['鬼蜮']='鬼蜮先驱:BAAALgAECgYJBgAAAA==.鬼蜮神箭手:BAAALgADCgMJAwAAAA==.',
['魇梦']='魇梦:BAAALgAECgIJAgAAAA==.',
['魔羯']='魔羯:BAAALgAECgEJAQABLgAECgMJBAAFAAAAAA==.',
['麦兜']='麦兜的巫僧:BAAALgAECgcJCwAAAA==.麦兜的朮爹:BAAALgAECgYJCgAAAA==.',
['龘翼']='龘翼:BAAALgADCgMJAwAAAA==.',
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
