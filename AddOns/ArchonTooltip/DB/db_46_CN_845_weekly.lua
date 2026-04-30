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

local lookup = {'Priest-Holy','Priest-Discipline','Shaman-Elemental','DeathKnight-Unholy','Shaman-Restoration','Warlock-Demonology','Evoker-Preservation','Paladin-Retribution','DeathKnight-Blood','Rogue-Subtlety','Mage-Frost','Hunter-Marksmanship','Evoker-Augmentation','Unknown-Unknown',}
local provider = {region='CN',realm='迦玛兰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aily:BAAALgAECgEJAQAAAA==.',
Av='Avis:BAAALgAFFAEJAQAAAA==.',
Ee='Eemls:BAAALgAECgEJAQAAAA==.',
El='Elis:BAAALgAECgYJBgAAAA==.Elsa:BAACLgAFFH8NAAMBAAQJphh2BgAVAQABAAMJhiB2BgAVAQACAAQJWgmjCADlAAAuAAQKfysAAwEACAmMHlAMAI4CAAEACAlQHVAMAI4CAAIACAkcFkMIAIsBAAAA.',
Gr='Gracy:BAAALgADCggJCQAAAA==.',
He='Hemsworth:BAAALgAFFAIJAQAAAA==.',
Ic='Icebreaker:BAAALgAECgQJAwAAAA==.',
Me='Mestony:BAAALgADCgEJAQAAAA==.',
No='Nogamenolife:BAAALgADCgYJCwAAAA==.',
Su='Sunnimabio:BAAALgAECgIJAgAAAA==.',
Wa='Wayaway:BAAALgAECgIJAgAAAA==.',
['一四']='一四七澫:BAAALgAECgEJAQAAAA==.',
['万俟']='万俟泠:BAAALgAECgkJCQAAAA==.',
['三六']='三六九澫:BAAALgAECgQJBwAAAA==.',
['下一']='下一日要我:BAAALgAECgUJCgAAAA==.',
['丑姑']='丑姑娘:BAAALgAECgYJCwAAAA==.',
['丨电']='丨电闪丶雷鸣:BAABLgAECn8eAAIDAAcJpBUmDwA2AQADAAcJpBUmDwA2AQAAAA==.',
['乐猫']='乐猫儿:BAAALgADCgcJBwAAAA==.',
['乾坤']='乾坤无极:BAAALgAECgcJAQABLgAFFAUJBQAEADsiAA==.',
['人间']='人间术:BAAALgAECgQJBQAAAA==.',
['今夜']='今夜不会醉:BAABLgAFFH8KAAIFAAQJTgSuDAAPAQAFAAQJTgSuDAAPAQAAAA==.',
['伊泽']='伊泽瑞尔:BAAALgAECgEJAQAAAA==.',
['传说']='传说的调调:BAAALgAFFAIJBAAAAA==.',
['冬水']='冬水仙:BAAALgADCgEJAQAAAA==.',
['出锅']='出锅的肉丸子:BAABLgAECn8VAAIGAAYJxQltlQAuAQAGAAYJxQltlQAuAQAAAA==.',
['别想']='别想摸我一号:BAABLgAFFH8IAAIHAAQJbxjsCABaAQAHAAQJbxjsCABaAQABLgAFFAYJCgAFAHYKAA==.别想摸我七号:BAABLgAFFH8JAAIHAAUJpiHUAAD9AQAHAAUJpiHUAAD9AQABLgAFFAYJCgAFAHYKAA==.别想摸我三号:BAABLgAFFH8IAAIHAAQJuxzCBwBvAQAHAAQJuxzCBwBvAQABLgAFFAYJCgAFAHYKAA==.别想摸我九号:BAABLgAFFH8FAAIHAAUJbSHEAAAHAgAHAAUJbSHEAAAHAgABLgAFFAYJCgAFAHYKAA==.别想摸我二号:BAABLgAFFH8IAAIHAAQJMx1eBwB3AQAHAAQJMx1eBwB3AQABLgAFFAYJCgAFAHYKAA==.别想摸我五号:BAABLgAFFH8JAAIHAAUJBiIGCQBYAQAHAAUJBiIGCQBYAQABLgAFFAYJCgAFAHYKAA==.别想摸我八号:BAABLgAFFH8JAAIHAAUJ6h1+AQDGAQAHAAUJ6h1+AQDGAQABLgAFFAYJCgAFAHYKAA==.别想摸我六号:BAABLgAFFH8IAAIHAAQJih4FAwCAAQAHAAQJih4FAwCAAQABLgAFFAYJCgAFAHYKAA==.别想摸我四号:BAAALgAFFAQJBAABLgAFFAYJCgAFAHYKAA==.',
['劍無']='劍無義:BAAALgAECgEJAQAAAA==.',
['卡卡']='卡卡:BAABLgAFFH8JAAIGAAMJjxOsIAABAQAGAAMJjxOsIAABAQAAAA==.',
['发科']='发科密:BAAALgAECgcJDAAAAA==.',
['古尔']='古尔丹严父:BAAALgADCgEJAQAAAA==.',
['叨刀']='叨刀:BAABLgAFFH8JAAIIAAQJkw/2BQBOAQAIAAQJkw/2BQBOAQAAAA==.',
['叮噹']='叮噹貓:BAAALgAECgEJAQAAAA==.',
['呜喵']='呜喵王:BAAALgAFFAIJBAAAAA==.',
['哈库']='哈库纳玛塔塔:BAAALgADCgEJAQAAAA==.',
['嘟嘟']='嘟嘟秒黑市:BAABLgAFFH8FAAMEAAUJSgGcJwD5AAAEAAQJSgGcJwD5AAAJAAEJAAAiFgBBAAABLgAFFAcJDQAEAGUkAA==.',
['城城']='城城丷:BAAALgAECgYJDAAAAA==.',
['基尼']='基尼洛友:BAAALgAECgQJBAAAAA==.',
['墨言']='墨言:BAAALgAECgYJBwAAAA==.',
['夜的']='夜的狙擊手:BAAALgAECgYJCQAAAA==.',
['大榴']='大榴莲想滋人:BAAALgAECgYJBgABLgAFFAMJBgAKACoVAA==.大榴莲想背刺:BAABLgAFFH8GAAIKAAMJKhWADQASAQAKAAMJKhWADQASAQAAAA==.',
['天蓝']='天蓝卡卡:BAABLgAFFH8GAAILAAMJKw/MLAADAQALAAMJKw/MLAADAQAAAA==.',
['妄徊']='妄徊:BAACLgAFFH8TAAIEAAUJbCWFAQAXAgAEAAUJbCWFAQAXAgAuAAQKfyMAAgQACAmHI7ELAD4DAAQACAmHI7ELAD4DAAAA.',
['小罗']='小罗曼司:BAAALgAECgQJAQAAAA==.',
['心态']='心态好手艺高:BAAALgAFFAEJAQAAAA==.',
['必须']='必须得释放:BAAALgAFFAEJAQAAAA==.',
['恶灵']='恶灵之缚:BAAALgAECgEJAQAAAA==.',
['想喝']='想喝奶出门买:BAAALgAECgEJAQAAAA==.',
['战火']='战火大德:BAAALgADCgYJBwAAAA==.',
['扳手']='扳手:BAAALgADCgIJAgAAAA==.',
['拉克']='拉克絲丶:BAAALgAFFAQJBAAAAA==.',
['拉米']='拉米雅:BAAALgADCgEJAQAAAA==.',
['晴舞']='晴舞青猫:BAAALgAECgUJBgAAAA==.',
['来个']='来个盾呗:BAAALgAFFAEJAQAAAA==.',
['枫风']='枫风:BAAALgAECgEJAQAAAA==.',
['标哥']='标哥:BAAALgAECgYJDAAAAA==.标哥的表哥:BAAALgAECgUJBQAAAA==.',
['树忄']='树忄爿:BAAALgAFFAIJBAAAAA==.',
['死了']='死了没埋:BAAALgAFFAEJAQAAAA==.',
['毅格']='毅格:BAACLgAFFH8TAAIMAAUJJyCABgC2AQAMAAUJJyCABgC2AQAuAAQKfxwAAgwACAkXHZIRAKoCAAwACAkXHZIRAKoCAAAA.',
['水门']='水门大侠:BAAALgAECgUJBQAAAA==.',
['游学']='游学者董卓:BAAALgAECgEJAQAAAA==.',
['潜龙']='潜龙勿用:BAAALgADCgEJAgAAAA==.',
['灬光']='灬光之子灬:BAAALgAECgMJBgAAAA==.',
['焰心']='焰心:BAAALgADCgMJAwAAAA==.',
['爱的']='爱的罗曼斯:BAAALgAECgEJAQAAAA==.',
['牛牛']='牛牛柒:BAAALgADCgMJAwAAAA==.',
['牧喵']='牧喵者:BAAALgAECgkJCQAAAA==.',
['特里']='特里休:BAAALgAECgMJAwAAAA==.',
['玛里']='玛里苟斯:BAACLgAFFH8IAAMNAAMJEwsQEwDmAAANAAMJEwsQEwDmAAAHAAIJBQpqEwCQAAAuAAQKfx4AAwcACQn9FrQXANgBAAcACAlyFbQXANgBAA0ABQkaFnI4ABQBAAAA.',
['神你']='神你妹:BAAALgAECgEJAQAAAA==.',
['秋晓']='秋晓:BAAALgADCgIJAgABLgADCgYJCwAOAAAAAA==.',
['秋晚']='秋晚枫:BAABLgAFFH8KAAIIAAQJBiZlAwC+AQAIAAQJBiZlAwC+AQAAAA==.',
['粉色']='粉色卡卡:BAABLgAFFH8FAAIIAAIJZRAjJACkAAAIAAIJZRAjJACkAAAAAA==.',
['红龟']='红龟粉色头:BAAALgAECgYJBAAAAA==.',
['美超']='美超風:BAAALgAECgEJAgAAAA==.',
['肆雨']='肆雨:BAAALgAECgYJBwAAAA==.',
['胸藏']='胸藏三聚氰:BAAALgAECgUJBwAAAA==.',
['臭臭']='臭臭的丶:BAAALgAECgYJCAAAAA==.',
['舞媆']='舞媆晓德:BAAALgADCgYJAwAAAA==.',
['若叶']='若叶睦:BAAALgAECgkJBwAAAA==.',
['若无']='若无其事:BAAALgAECgQJBAAAAA==.',
['菠萝']='菠萝大神:BAAALgAFFAIJAwAAAA==.',
['蕾丝']='蕾丝小裤裤:BAAALgADCgEJAQAAAA==.',
['薇尔']='薇尔莉特:BAAALgAECgkJBwAAAA==.',
['虚荣']='虚荣灬:BAAALgADCgUJBQAAAA==.',
['行恶']='行恶:BAAALgADCgYJBgAAAA==.',
['这咕']='这咕咕保熟吗:BAAALgADCgUJBQAAAA==.',
['逝水']='逝水情丶:BAAALgADCgEJAQAAAA==.',
['都都']='都都衄:BAAALgAECgEJAQAAAA==.',
['释星']='释星魂:BAAALgADCgQJBAAAAA==.',
['阿宝']='阿宝同学:BAAALgAECgYJDgAAAA==.',
['阿萨']='阿萨斯砍:BAACLgAFFH8IAAIEAAMJVRiTEAAGAQAEAAMJVRiTEAAGAQAuAAQKfxgAAwQACAmuHeIwAHQCAAQACAmuHeIwAHQCAAkABglYCZwqAOkAAAAA.',
['陈韬']='陈韬毅格:BAAALgADCgYJBgAAAA==.',
['韩版']='韩版太子:BAAALgAECgcJEQAAAA==.韩版太子丶:BAAALgAECgcJCAAAAA==.韩版灬太子:BAAALgAECgcJCQAAAA==.',
['鹿野']='鹿野:BAAALgAECgIJAgAAAA==.',
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
