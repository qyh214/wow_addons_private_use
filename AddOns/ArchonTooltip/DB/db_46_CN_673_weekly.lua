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

local lookup = {'DeathKnight-Blood','DeathKnight-Unholy','DemonHunter-Devourer','Paladin-Holy','Paladin-Retribution','Druid-Restoration','Evoker-Augmentation','Unknown-Unknown','Priest-Shadow',}
local provider = {region='CN',realm='库尔提拉斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avbox:BAAALgAECgQJBgAAAA==.',
De='Deminer:BAAALgAECgYJBgAAAA==.',
Do='Dot:BAAALgADCgEJAQAAAA==.',
Du='Duang:BAAALgAECgEJAwAAAA==.',
El='Elainé:BAAALgAECgQJBAAAAA==.',
Ha='Harrisonharr:BAAALgAECgcJDAAAAA==.',
Ku='Kukunat:BAACLgAFFH8SAAIBAAUJuxccBABvAQABAAUJuxccBABvAQAuAAQKfxcAAwEACAmxIIoFAOcCAAEACAmxIIoFAOcCAAIAAQnUACk7ARwAAAAA.',
Mo='Molly:BAAALgAECggJEAAAAA==.',
Re='Regrets:BAAALgAECgIJAgAAAA==.',
Sm='Smilee:BAACLgAFFH8IAAIDAAQJDxcNBwA9AQADAAQJDxcNBwA9AQAuAAQKfxYAAgMACAmqHisZAL0CAAMACAmqHisZAL0CAAAA.',
Tv='Tvic:BAAALgADCgIJAgAAAA==.',
Vi='Viviby:BAAALgADCgUJBQAAAA==.',
Vu='Vurtne:BAAALgADCgUJBQAAAA==.',
['不加']='不加外求:BAAALgAFFAEJAQABLgAFFAIJBQAEAJQhAA==.',
['临渊']='临渊:BAAALgAECgQJBAAAAA==.',
['丶柒']='丶柒染:BAAALgAECgEJAQAAAA==.',
['为了']='为了布洛芬:BAAALgAECgcJBwAAAA==.',
['乳家']='乳家小仙:BAAALgADCgMJAwAAAA==.',
['云玫']='云玫:BAAALgAFFAEJAQAAAA==.',
['亚联']='亚联邦帝国:BAAALgAECgYJBgAAAA==.',
['享受']='享受阳光:BAAALgAECgIJAgAAAA==.',
['今天']='今天蹲腿:BAAALgAECgEJAQAAAA==.',
['伊兰']='伊兰圣玲:BAAALgAECgQJBAAAAA==.',
['伊利']='伊利达雷领主:BAAALgADCgEJAQAAAA==.',
['俺来']='俺来打酱油:BAAALgADCgEJAQAAAA==.',
['倾城']='倾城:BAAALgAECgQJBQAAAA==.',
['傲娇']='傲娇的汪汪儿:BAAALgAECgcJCgAAAA==.',
['光博']='光博士:BAAALgADCgMJAwAAAA==.',
['冰灬']='冰灬水:BAAALgAECgEJAQAAAA==.',
['凉月']='凉月风夕:BAAALgAECgYJBgAAAA==.',
['北冥']='北冥鑫鑫:BAAALgAECgUJBQAAAA==.',
['半山']='半山溪如雨:BAAALgAFFAEJAgAAAA==.',
['发呆']='发呆的尛德:BAAALgAECgUJBQAAAA==.发呆的肖隆仁:BAAALgAECgYJBgAAAA==.',
['吱之']='吱之吱:BAABLgAFFH8JAAIFAAQJjw1iDQBAAQAFAAQJjw1iDQBAAQAAAA==.',
['嗯我']='嗯我很好:BAAALgADCgEJAQAAAA==.',
['土豆']='土豆豆土:BAAALgADCgEJAQAAAA==.',
['圣光']='圣光的宁静:BAAALgADCgMJAwAAAA==.',
['圣子']='圣子道无尽:BAAALgAECgEJAwAAAA==.',
['圣武']='圣武:BAAALgADCgMJAwAAAA==.',
['圣灵']='圣灵沨:BAAALgAECgYJBwAAAA==.',
['圣骑']='圣骑无焰:BAABLgAFFH8GAAIFAAUJigcCCgBdAQAFAAUJigcCCgBdAQAAAA==.',
['天启']='天启丶:BAAALgAECgkJEgAAAA==.',
['奈斯']='奈斯型队友:BAABLgAECn8ZAAIGAAcJ3SGeFgCBAgAGAAcJ3SGeFgCBAgAAAA==.',
['奥菲']='奥菲迩:BAAALgADCgcJCAAAAA==.',
['如一']='如一宝宝:BAABLgAFFH8IAAIHAAQJdhBCCwBDAQAHAAQJdhBCCwBDAQAAAA==.',
['如芸']='如芸:BAAALgAECgkJDgAAAA==.',
['威海']='威海雷哥:BAAALgAECgEJAQAAAA==.',
['媽媽']='媽媽:BAAALgAFFAQJBAAAAA==.',
['寒露']='寒露丶:BAAALgAECgcJBwABLgAFFAQJBAAIAAAAAA==.',
['小德']='小德传说:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊快快跑:BAAALgAECgQJBAAAAA==.',
['小红']='小红手法師:BAAALgAECgEJAQAAAA==.',
['就爱']='就爱麻辣烫:BAAALgAECgEJAQAAAA==.',
['嶵兒']='嶵兒:BAAALgADCgYJBgAAAA==.',
['幻璃']='幻璃:BAAALgADCgIJAgAAAA==.',
['弑神']='弑神的耳环:BAAALgAECgEJAQAAAA==.',
['彩色']='彩色雪花:BAAALgAECgYJBgAAAA==.',
['德才']='德才兼备:BAAALgAECgEJAQAAAA==.',
['心外']='心外无事:BAACLgAFFH8FAAIEAAIJlCF7EQDEAAAEAAIJlCF7EQDEAAAuAAQKfxcAAwQABwkkJI0JANkCAAQABwkkJI0JANkCAAUAAQnMBWhRASsAAAAA.',
['忙着']='忙着当牛做马:BAAALgAECgUJBQAAAA==.',
['我是']='我是你的茶:BAAALgAFFAIJBAAAAA==.',
['我爱']='我爱饼饼:BAAALgADCgcJCAAAAA==.',
['斩鬼']='斩鬼:BAAALgAECgEJAQAAAA==.',
['星烬']='星烬:BAAALgADCgUJBgAAAA==.',
['是小']='是小染尘呀:BAAALgAECgEJAQABLgAFFAQJBAAIAAAAAA==.是小染尘哈:BAAALgADCgYJBgABLgAFFAQJBAAIAAAAAA==.',
['暗里']='暗里着迷:BAAALgAECgEJAQAAAA==.',
['最初']='最初的希望:BAAALgAFFAQJBAAAAA==.',
['月光']='月光下的独舞:BAAALgAECgIJAgAAAA==.',
['未知']='未知目标:BAAALgAECgUJDAAAAA==.',
['林清']='林清雅:BAAALgADCgEJAQAAAA==.',
['正摇']='正摇反摇拳:BAAALgAECgcJBwAAAA==.',
['涟漪']='涟漪:BAAALgADCgkJDAAAAA==.',
['清新']='清新的汪汪儿:BAAALgAFFAIJAgABLgAFFAQJBwAJANkMAA==.',
['溪水']='溪水:BAAALgAECgcJCgABLgAFFAQJEwAGADEgAA==.',
['灬小']='灬小趴菜:BAAALgAECgYJBgAAAA==.',
['灬汤']='灬汤圆:BAAALgAECgYJBgAAAA==.',
['灬血']='灬血色灬:BAAALgAECgQJBAAAAA==.',
['炽爱']='炽爱飞雪:BAAALgADCgYJBgAAAA==.',
['烈阳']='烈阳:BAAALgADCgUJBQAAAA==.',
['烟錵']='烟錵我愛雅:BAAALgADCgEJAQAAAA==.',
['熊熊']='熊熊冬:BAAALgADCgcJBwAAAA==.',
['狂战']='狂战:BAAALgADCgQJBQAAAA==.',
['狐喵']='狐喵喵:BAAALgAECgEJAQAAAA==.',
['狐嘚']='狐嘚嘚:BAAALgAECgEJAQAAAA==.',
['猎杀']='猎杀武神:BAAALgAECgYJDAAAAA==.',
['王旖']='王旖:BAAALgADCgUJBQAAAA==.',
['玖玖']='玖玖:BAAALgADCgUJBQAAAA==.',
['百合']='百合小天天:BAAALgAFFAEJAQAAAA==.',
['皮卡']='皮卡丶丘:BAAALgAECgEJAQAAAA==.',
['碟恋']='碟恋红尘:BAAALgAFFAEJAQAAAA==.',
['神圣']='神圣小混混:BAAALgAFFAEJAQAAAA==.',
['神奇']='神奇的东:BAAALgADCgYJBgAAAA==.',
['精神']='精神小海哥:BAAALgADCgIJAgAAAA==.',
['自由']='自由灬如风:BAAALgAECgUJBQAAAA==.',
['艾德']='艾德:BAAALgADCgMJAwAAAA==.',
['艾恩']='艾恩璐:BAAALgAECgUJBQAAAA==.',
['芬陀']='芬陀利:BAAALgADCgMJAwAAAA==.',
['草履']='草履虫超人:BAAALgAECgYJBgAAAA==.',
['菊花']='菊花神:BAAALgAECgEJAQAAAA==.',
['落花']='落花葬青草:BAAALgAECgYJBwAAAA==.',
['蒲公']='蒲公英的旅行:BAAALgAECgkJEAAAAA==.',
['蔷薇']='蔷薇公爵:BAAALgAECgQJBAAAAA==.',
['薔薇']='薔薇公爵:BAAALgAECgQJBAAAAA==.',
['袅熊']='袅熊:BAAALgAECgYJBgAAAA==.',
['被守']='被守卫的猫:BAAALgAECgYJEQAAAA==.',
['许爽']='许爽:BAAALgAECgYJBgAAAA==.',
['超级']='超级棒棒糖:BAAALgADCgYJBgABLgAFFAQJCAADAA8XAA==.',
['长生']='长生:BAAALgADCgMJAwAAAA==.',
['闪开']='闪开:BAAALgADCgMJAwAAAA==.',
['闭家']='闭家锁:BAAALgAECgYJBwAAAA==.',
['阿瑟']='阿瑟丶:BAAALgAECgYJAQABLgAFFAQJBAAIAAAAAA==.',
['霜天']='霜天:BAAALgAECgEJAQAAAA==.',
['霜羽']='霜羽风舞:BAAALgADCgMJAwAAAA==.',
['霜袶']='霜袶丶:BAABLgAFFH8JAAICAAQJNBs7DwBlAQACAAQJNBs7DwBlAQAAAA==.',
['飘摇']='飘摇悦兮:BAAALgAECgIJAwABLgAFFAQJBAAIAAAAAA==.',
['飞天']='飞天德:BAAALgAECgQJBAAAAA==.',
['鹅哥']='鹅哥:BAAALgAECgEJAQAAAA==.',
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
