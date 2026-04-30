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

local lookup = {'Unknown-Unknown','Priest-Discipline','Hunter-BeastMastery','Mage-Frost','Druid-Guardian','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Paladin-Holy',}
local provider = {region='CN',realm='火喉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ap='Apt:BAAALgADCgIJAgAAAA==.',
Di='Diczz:BAAALgAECgIJAgAAAA==.',
Fl='Flowersea:BAAALgADCgUJBQAAAA==.',
Ga='Gawaine:BAAALgADCgEJAQAAAA==.',
Ka='Katze:BAAALgAECgIJBQAAAA==.',
Ki='Kisslucky:BAAALgADCgEJAQAAAA==.',
Pe='Pearl:BAAALgAECgMJAwAAAA==.',
Sn='Snakeman:BAAALgAECgIJAgABLgAECgUJBQABAAAAAA==.',
So='Soner:BAAALgAECgEJAgAAAA==.',
Uy='Uyu:BAAALgADCgEJAQAAAA==.',
['不知']='不知道彧:BAAALgAECgcJDwAAAA==.',
['乌兰']='乌兰牧骑:BAABLgAECn8VAAICAAgJpgtEBQC6AQACAAgJpgtEBQC6AQAAAA==.',
['书生']='书生意气:BAAALgAECgEJAQAAAA==.',
['亚特']='亚特兰丶诛灭:BAAALgAECgQJBAAAAA==.',
['余烬']='余烬:BAABLgAFFH8GAAIDAAMJ7Rm0BQAhAQADAAMJ7Rm0BQAhAQAAAA==.',
['光华']='光华浮夸:BAAALgAECgYJDQAAAA==.',
['光寒']='光寒十六州:BAAALgAECgcJBwAAAA==.',
['冰龙']='冰龙侠:BAAALgAECgYJBgAAAA==.',
['冽冬']='冽冬将至:BAAALgAECgcJDwAAAA==.',
['初音']='初音未来:BAAALgAECgEJAQAAAA==.',
['删除']='删除回忆:BAAALgADCgUJBQAAAA==.',
['别欺']='别欺负小昙芯:BAAALgAECgMJAwAAAA==.',
['勿忘']='勿忘心安:BAABLgAFFH8GAAIEAAMJzxRsEQAHAQAEAAMJzxRsEQAHAQABLgAFFAUJCQABAAAAAA==.',
['卡卡']='卡卡旋秋周:BAAALgAECgYJBwAAAA==.',
['卡里']='卡里古拉:BAAALgAECgEJAQAAAA==.',
['双魚']='双魚理:BAABLgAECn8aAAIEAAkJGhn7BABoAgAEAAkJGhn7BABoAgABLgAFFAYJCwAEAMUbAA==.',
['嗷呜']='嗷呜:BAABLgAFFH8FAAIFAAMJvgEuBQBpAAAFAAMJvgEuBQBpAAAAAA==.',
['嘎嘎']='嘎嘎有米:BAAALgAECgQJBQAAAA==.',
['壹劍']='壹劍破蒼天:BAAALgADCgEJAQAAAA==.',
['大猫']='大猫猫:BAAALgAECgEJAQAAAA==.',
['大白']='大白牛:BAAALgADCgIJAgAAAA==.',
['天津']='天津饭:BAAALgAFFAEJAQAAAA==.',
['姐姐']='姐姐下班我接:BAAALgAECgYJCQAAAA==.姐姐为您服雾:BAAALgAECgUJCAAAAA==.',
['嫩牧']='嫩牧牧:BAAALgAECgQJBQAAAA==.',
['孤独']='孤独的快乐:BAAALgADCgcJBwAAAA==.',
['完美']='完美召唤:BAAALgADCgMJAwAAAA==.完美舞步:BAAALgAECgYJCgAAAA==.',
['寻鹏']='寻鹏:BAAALgAECgUJBQAAAA==.',
['小妮']='小妮妮:BAAALgAECgkJEAAAAA==.',
['小糯']='小糯糯:BAAALgAECgYJBgABLgAECgkJEAABAAAAAA==.',
['小胖']='小胖橘:BAAALgADCgEJAQAAAA==.',
['小舞']='小舞飛天:BAAALgADCgYJBgAAAA==.',
['小进']='小进宝:BAAALgAECgIJAwAAAA==.',
['小锅']='小锅巴:BAAALgAECgkJDwABLgAECgkJEAABAAAAAA==.',
['小馥']='小馥贵:BAAALgAFFAIJBAAAAA==.',
['展墨']='展墨眉:BAAALgAECgEJAQAAAA==.',
['帅比']='帅比无敌发丝:BAACLgAFFH8IAAIEAAMJXA20LQAAAQAEAAMJXA20LQAAAQAuAAQKfxcAAgQABwlSG89SAD8CAAQABwlSG89SAD8CAAAA.',
['幽灵']='幽灵图腾:BAAALgAECgkJCQAAAA==.',
['当厨']='当厨子的司机:BAAALgADCgUJBQAAAA==.',
['忄乙']='忄乙:BAAALgADCgUJBQAAAA==.',
['恶魔']='恶魔呆萌:BAAALgAECgEJAQAAAA==.',
['悯天']='悯天乄承影:BAAALgADCgkJCgAAAA==.',
['慯信']='慯信:BAAALgAECgMJAwAAAA==.',
['成年']='成年拖鞋:BAAALgAFFAEJAQAAAA==.',
['我很']='我很抱歉:BAAALgAECgIJAgAAAA==.',
['我藏']='我藏好了:BAACLgAFFH8EAAIGAAMJSQ55JQDsAAAGAAMJSQ55JQDsAAAuAAQKfxcAAwcABwmsGaguAAEBAAYABgmoFy19AGEBAAcABAnxE6guAAEBAAAA.',
['戴了']='戴了不算给:BAAALgAECgIJAwAAAA==.',
['捂着']='捂着命:BAAALgAECgMJAwAAAA==.',
['昙芯']='昙芯:BAAALgAECgEJAQAAAA==.',
['星星']='星星骑士:BAAALgAFFAIJBAAAAA==.',
['最佳']='最佳丶损友:BAAALgAECgYJCgAAAA==.',
['月影']='月影魂殇:BAAALgAECgcJBgABLgAFFAYJEwAIAMggAA==.',
['本可']='本可儿不同意:BAAALgADCgEJAQAAAA==.',
['李兰']='李兰迪:BAABLgAFFH8GAAIDAAMJvB6jBQAiAQADAAMJvB6jBQAiAQAAAA==.',
['梦儛']='梦儛曲丶娮籽:BAAALgAECgEJAQAAAA==.梦儛曲丶小水:BAAALgAECgIJAgAAAA==.',
['梦舞']='梦舞曲丶入渊:BAAALgADCgIJAgAAAA==.',
['灵能']='灵能觉醒:BAAALgAECgQJBgAAAA==.',
['烹饪']='烹饪技术哪家:BAAALgAECgUJEAAAAA==.',
['燎原']='燎原火:BAAALgAECgEJAQAAAA==.',
['猪八']='猪八戒大官人:BAAALgAECgYJCQABLgAECgkJEAABAAAAAA==.',
['王翠']='王翠花:BAAALgAECgQJAwAAAA==.',
['碳酸']='碳酸氢娜:BAAALgADCgEJAQAAAA==.',
['糖醋']='糖醋小小德:BAAALgADCgEJAQAAAA==.',
['纯情']='纯情丶大表哥:BAAALgAFFAIJAgAAAA==.',
['终结']='终结者:BAAALgAFFAEJAQAAAA==.',
['翘班']='翘班小王子:BAAALgAECgIJBAAAAA==.',
['胖吖']='胖吖:BAAALgAECgkJCQAAAA==.',
['良夜']='良夜陌世人:BAAALgAECgEJAQAAAA==.',
['芙莉']='芙莉莲:BAAALgAECgMJAwAAAA==.',
['芝士']='芝士雪豸刁:BAACLgAFFH8JAAIJAAMJhxuIDAAVAQAJAAMJhxuIDAAVAQAuAAQKfxQAAgkABgnuG/81AKQBAAkABgnuG/81AKQBAAAA.',
['苍天']='苍天哥:BAAALgAECgcJCwAAAA==.',
['蔽风']='蔽风之影:BAAALgAECgUJBwAAAA==.',
['蛙仔']='蛙仔:BAAALgAECggJDwAAAA==.',
['行走']='行走的圣光:BAAALgAECgEJAQAAAA==.',
['记忆']='记忆似手中水:BAAALgAECgEJAQAAAA==.',
['诗嫣']='诗嫣:BAAALgAECgkJBgAAAA==.',
['迷糊']='迷糊骑:BAAALgAECgYJCQAAAA==.迷糊鬼:BAAALgAECgIJAgAAAA==.迷糊龙:BAAALgADCgEJAQAAAA==.',
['追寻']='追寻你的轨迹:BAAALgAECgEJAgAAAA==.',
['醉愛']='醉愛红尘:BAAALgAECgUJCQAAAA==.',
['醉爱']='醉爱红尘:BAABLgAFFH8FAAIDAAIJNhbfFACxAAADAAIJNhbfFACxAAAAAA==.',
['银河']='银河流魂:BAAALgADCgcJFgAAAA==.',
['长毛']='长毛圣骑:BAAALgADCgcJBwAAAA==.',
['阳光']='阳光下的温柔:BAAALgADCgEJAQAAAA==.',
['阿朗']='阿朗的抉择:BAAALgAECgEJAQAAAA==.',
['隔壁']='隔壁王师傅:BAAALgADCgEJAQAAAA==.',
['隨風']='隨風潛入夜:BAAALgADCgIJAgAAAA==.',
['鬼狱']='鬼狱囚锁:BAAALgAECgIJAgAAAA==.',
['黑铁']='黑铁战神:BAAALgAECgEJAQAAAA==.',
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
