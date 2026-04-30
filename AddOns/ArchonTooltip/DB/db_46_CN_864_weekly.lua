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

local lookup = {'Shaman-Elemental','DeathKnight-Unholy','Unknown-Unknown','DemonHunter-Devourer','Warrior-Protection','Warrior-Fury','Rogue-Subtlety','Mage-Frost','Priest-Discipline','Priest-Holy','Priest-Shadow','Paladin-Retribution',}
local provider = {region='CN',realm='阿扎达斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alf:BAAALgAECgEJAQAAAA==.',
Ar='Arlsa:BAABLgAFFH8JAAIBAAQJQRauBAA2AQABAAQJQRauBAA2AQAAAA==.',
Dr='Drankrobber:BAAALgAECgYJEQAAAA==.',
Em='Embalm:BAABLgAFFH8HAAICAAMJ/Q5VFADzAAACAAMJ/Q5VFADzAAAAAA==.',
Ev='Evilreaper:BAAALgAECgUJBQAAAA==.',
Ki='Kimuratakuya:BAAALgADCgYJBgAAAA==.',
Sa='San:BAAALgAECgEJAQAAAA==.',
St='Starfifteen:BAAALgAECgEJAQAAAA==.',
Zo='Zommari:BAAALgADCgUJBQABLgAECgUJBwADAAAAAA==.',
['一只']='一只白白:BAAALgAECgkJEAAAAA==.',
['三色']='三色娃娃长官:BAAALgAECgYJDgAAAA==.',
['上仙']='上仙:BAAALgAFFAEJAQAAAA==.',
['二两']='二两肉:BAAALgAECgIJAgAAAA==.',
['任我']='任我狠:BAAALgAECgEJAQAAAA==.',
['伊邪']='伊邪那岐丶:BAABLgAFFH8FAAIEAAMJtxWqGAAKAQAEAAMJtxWqGAAKAQABLgAFFAQJBwACAN0WAA==.',
['优乐']='优乐镁:BAAALgAECgYJDQAAAA==.',
['你是']='你是真的苟:BAAALgAECgkJDwAAAA==.',
['兔子']='兔子爷:BAAALgAECgEJAQAAAA==.',
['出就']='出就一直刷:BAAALgADCgEJAQAAAA==.',
['刘德']='刘德华:BAAALgAECgcJDQAAAA==.',
['午夜']='午夜猫猫:BAAALgAECgYJCQAAAA==.',
['呆小']='呆小法:BAAALgADCgYJBgAAAA==.',
['周星']='周星驰:BAAALgAECgYJDgAAAA==.',
['咕我']='咕我在:BAAALgADCgEJAQABLgAECgEJAQADAAAAAA==.',
['啊排']='啊排归来:BAAALgADCgkJEAAAAA==.',
['墩里']='墩里格墩:BAAALgAECgcJBwAAAA==.',
['夏川']='夏川丨真凉:BAAALgAFFAIJBAAAAA==.',
['大苏']='大苏打:BAAALgADCgcJCQAAAA==.',
['天之']='天之萌:BAAALgAFFAMJAwAAAA==.天之鬼魅:BAAALgAECgEJAQAAAA==.',
['奥格']='奥格水电工:BAABLgAFFH8HAAIBAAQJPQuTDQATAQABAAQJPQuTDQATAQAAAA==.',
['奶丨']='奶丨茶:BAAALgAECgEJAQAAAA==.',
['好友']='好友丶趣:BAAALgADCgYJCwAAAA==.',
['妹思']='妹思他棒威:BAAALgAECgUJBQAAAA==.',
['姜明']='姜明子:BAAALgAECgcJEAAAAA==.',
['姝释']='姝释:BAAALgADCgQJBAAAAA==.',
['娇姐']='娇姐请抽烟:BAACLgAFFH8OAAMFAAQJ+gclCQC/AAAFAAQJpwElCQC/AAAGAAIJuw79GAClAAAuAAQKfxgAAwYACAnyEUkzAN4BAAYABwldE0kzAN4BAAUABwlxBG4nAAMBAAAA.',
['宁静']='宁静双击:BAAALgAECgQJBAAAAA==.',
['小害']='小害虫:BAAALgADCgEJAQABLgAECgEJAQADAAAAAA==.',
['尐胖']='尐胖墩:BAAALgAECgQJBAAAAA==.',
['差点']='差点我就信了:BAAALgADCgEJAQAAAA==.',
['常世']='常世万法仙君:BAAALgAECgQJBAAAAA==.',
['幽幽']='幽幽狐:BAAALgAECgEJAQAAAA==.',
['幽游']='幽游猎影:BAAALgADCgQJBAAAAA==.',
['张斗']='张斗斗:BAAALgAFFAEJAQAAAA==.',
['影子']='影子:BAABLgAECn8cAAIHAAcJ6yK/EACcAgAHAAcJ6yK/EACcAgABLgAFFAQJCAAHAJoaAA==.',
['影羽']='影羽:BAAALgAECgMJBQAAAA==.',
['德乄']='德乄爷:BAAALgAECgEJAgAAAA==.',
['想吃']='想吃自己打:BAAALgAECgkJCQAAAA==.',
['成龙']='成龙:BAAALgADCgIJAgAAAA==.',
['我不']='我不打铲的:BAABLgAFFH8FAAIEAAQJ6xDCEQBBAQAEAAQJ6xDCEQBBAQAAAA==.',
['我菊']='我菊花一紧:BAAALgADCgEJAQAAAA==.',
['戒律']='戒律木:BAAALgAECggJCQAAAA==.',
['战牛']='战牛在野:BAAALgAECgEJAQAAAA==.',
['指挥']='指挥:BAAALgAFFAQJBAAAAA==.',
['故我']='故我思:BAAALgADCgYJBgABLgAECgEJAQADAAAAAA==.',
['日忽']='日忽月令:BAAALgAECgMJAwAAAA==.',
['春哥']='春哥快救我:BAAALgAECgMJAQAAAA==.',
['晓他']='晓他:BAAALgAECgIJAgAAAA==.',
['晚上']='晚上睡不着:BAAALgAECgEJAQAAAA==.',
['晨曦']='晨曦秋景:BAAALgAECgEJAQAAAA==.',
['暮色']='暮色玫瑰:BAAALgAECgQJBAAAAA==.',
['有关']='有关部门灬:BAAALgAECgMJAwAAAA==.',
['枼耐']='枼耐法:BAAALgAECgYJCAAAAA==.',
['梁朝']='梁朝伟:BAAALgADCgUJBQAAAA==.',
['楚甘']='楚甘唯阳村道:BAAALgADCgUJBQAAAA==.',
['残月']='残月天明:BAABLgAFFH8JAAIIAAMJ+RBmKwAIAQAIAAMJ+RBmKwAIAQAAAA==.',
['沐小']='沐小绫:BAAALgAECgkJEQAAAA==.',
['流水']='流水飞烟:BAAALgAECgQJBAAAAA==.',
['清水']='清水先生:BAAALgADCgMJAwAAAA==.',
['灵精']='灵精血骑:BAAALgAECgEJAQAAAA==.',
['灾痕']='灾痕滟:BAAALgAECgMJAwAAAA==.',
['炒饼']='炒饼:BAAALgAFFAEJAQAAAA==.',
['热你']='热你温:BAAALgAECgEJAQAAAA==.',
['热烈']='热烈丶的马:BAAALgADCgMJBAAAAA==.',
['狂云']='狂云一叶:BAAALgAECgYJBwAAAA==.',
['猴黑']='猴黑黑:BAACLgAFFH8VAAMJAAUJXyIwAwDQAQAJAAUJXyIwAwDQAQAKAAEJEBVUFABDAAAuAAQKfyIABAoACQkkJPEJAK4CAAoACQmvIPEJAK4CAAkACAkOIOsIAK0CAAsAAQmYCHRjADEAAAAA.',
['白月']='白月光:BAAALgAFFAMJAwAAAA==.',
['百里']='百里东君:BAAALgAECgMJBAAAAA==.',
['盗取']='盗取圣光:BAABLgAECn8ZAAIMAAkJOB2TEQAEAwAMAAkJOB2TEQAEAwAAAA==.',
['祎祎']='祎祎不舍:BAAALgAECgEJAgAAAA==.',
['科羅']='科羅蒂娜:BAAALgAFFAQJBAAAAA==.',
['空条']='空条徐伦:BAAALgAECgIJAgAAAA==.',
['箫声']='箫声絶:BAAALgADCgEJAQABLgAECgcJCAADAAAAAA==.',
['縌迗']='縌迗之影:BAAALgADCgYJBgABLgAFFAQJBwABAD0LAA==.縌迗之雲:BAAALgADCgQJBQABLgAFFAQJBwABAD0LAA==.',
['纯蓝']='纯蓝色:BAAALgAFFAIJBAAAAA==.',
['肉酱']='肉酱君:BAAALgAECgEJAQAAAA==.',
['花开']='花开猫猫:BAAALgAECgIJAgAAAA==.',
['花花']='花花世界:BAAALgAECgEJAgAAAA==.花花很忧郁:BAAALgADCgMJAwAAAA==.',
['蒸汽']='蒸汽成龙:BAAALgAECgIJAgAAAA==.',
['蓑笠']='蓑笠翁:BAAALgAECgEJAQAAAA==.',
['藏起']='藏起来的秋天:BAAALgAECgUJCAAAAA==.',
['蛋猪']='蛋猪超人:BAAALgAECgEJAQAAAA==.',
['訫术']='訫术:BAAALgAECgYJCwAAAA==.',
['豆角']='豆角先生:BAAALgAECgEJAQAAAA==.',
['迪亚']='迪亚波罗丶:BAABLgAFFH8HAAICAAQJ3RZGEQBcAQACAAQJ3RZGEQBcAQAAAA==.',
['迷失']='迷失的爱丽丝:BAAALgAECgcJDQAAAA==.',
['追风']='追风:BAAALgAECgYJCAAAAA==.',
['逆天']='逆天羲和:BAAALgAFFAIJBAABLgAFFAQJBwABAD0LAA==.',
['遇术']='遇术临风:BAAALgADCgEJAQAAAA==.',
['部族']='部族龙魂:BAAALgADCgQJBAAAAA==.',
['野牛']='野牛两个半:BAAALgAECgEJAgAAAA==.',
['银光']='银光骤雨:BAAALgADCgEJAQABLgAECgEJAQADAAAAAA==.',
['阿格']='阿格拉玛:BAAALgAECgcJBwAAAA==.',
['霸气']='霸气坑爹兔:BAAALgADCgEJAQAAAA==.',
['静源']='静源星:BAAALgADCgQJBAAAAA==.',
['风里']='风里有詩句:BAAALgAECgcJCAAAAA==.',
['风间']='风间絮:BAAALgAECgIJAgAAAA==.',
['黯星']='黯星:BAACLgAFFH8IAAICAAMJwSJYGwA3AQACAAMJwSJYGwA3AQAuAAQKfyMAAgIACAnFHYoMANcBAAIACAnFHYoMANcBAAAA.',
['龙星']='龙星:BAAALgAECgMJAwAAAA==.',
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
