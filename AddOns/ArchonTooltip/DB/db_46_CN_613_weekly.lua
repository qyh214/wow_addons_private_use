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

local lookup = {'DeathKnight-Unholy','Rogue-Subtlety','Hunter-BeastMastery','Priest-Discipline','Priest-Holy','Unknown-Unknown','Mage-Frost','Druid-Restoration','Druid-Balance','Paladin-Retribution','Paladin-Holy','Hunter-Marksmanship','Monk-Mistweaver','Evoker-Preservation',}
local provider = {region='CN',realm='圣火神殿',name='CN',type='weekly',zone=46,date='2026-04-25',data={Co='Conquest:BAACLgAFFH8NAAIBAAQJnhl+EABfAQABAAQJnhl+EABfAQAuAAQKfxgAAgEABwlbHVlKABQCAAEABwlbHVlKABQCAAAA.',
Cr='Cresing:BAAALgAECggJEgAAAA==.',
De='Deathgun:BAAALgAECgIJAgAAAA==.',
Di='Diginypbucdz:BAABLgAECn8aAAICAAkJsheEEQCUAgACAAkJsheEEQCUAgAAAA==.',
Ga='Gail:BAAALgAFFAIJBAAAAA==.',
Gh='Ghyhuijn:BAAALgADCgUJHgAAAA==.',
Ha='Harish:BAAALgAECgQJBgAAAA==.',
Ja='Jax:BAAALgAECgMJAwAAAA==.',
Le='Lengen:BAAALgAECgQJCgAAAA==.',
Li='Lierena:BAABLgAECn8cAAIDAAcJfxIINgDWAQADAAcJfxIINgDWAQAAAA==.',
Ru='Rurb:BAAALgAECgEJAQAAAA==.',
Si='Sinister:BAAALgAECgYJBgAAAA==.',
Ta='Taa:BAAALgAECgEJAQAAAA==.',
Tm='Tmekii:BAAALgAECgcJDgAAAA==.Tmxkii:BAAALgADCgUJBQAAAA==.',
Wq='Wqq:BAAALgAFFAQJAwAAAA==.',
['一幻']='一幻狼一:BAAALgADCgQJBAAAAA==.',
['不讲']='不讲理大王:BAAALgAECgEJAQAAAA==.',
['东大']='东大肥肠医院:BAAALgAECgEJAQAAAA==.',
['临时']='临时数据:BAAALgAECgkJDgAAAA==.',
['丶小']='丶小狐狸:BAAALgADCgYJBwAAAA==.',
['丷法']='丷法法:BAAALgAECgYJEgAAAA==.',
['二大']='二大爷:BAAALgAECgQJBAAAAA==.',
['仁科']='仁科百华:BAAALgAECgEJAQAAAA==.',
['代工']='代工的狄爱奇:BAAALgAECgEJAQAAAA==.',
['伊丽']='伊丽莎奥尔森:BAAALgADCgUJBQAAAA==.',
['伍号']='伍号风球:BAAALgADCgUJBQAAAA==.',
['休杰']='休杰克曼:BAAALgADCgMJAwAAAA==.',
['低调']='低调法爺:BAAALgAECgIJBAAAAA==.',
['佟楛']='佟楛漱:BAAALgAECgMJAgAAAA==.',
['你杀']='你杀了我吧:BAAALgADCgEJAQAAAA==.',
['你谈']='你谈恋爱吗:BAAALgAECgQJBAAAAA==.',
['偷腥']='偷腥的鱼丶:BAAALgAECgMJBgAAAA==.',
['光头']='光头大魔王:BAAALgAECgYJEgAAAA==.',
['兜兜']='兜兜有寂寞:BAAALgAECgEJAQAAAA==.',
['册那']='册那潜兵:BAAALgAECgQJBAAAAA==.',
['冰雪']='冰雪之蒂:BAAALgAECgUJBgAAAA==.',
['冷冷']='冷冷小黑:BAAALgADCgEJAQAAAA==.',
['凛时']='凛时曲:BAAALgAECgQJBAAAAA==.',
['十九']='十九灬:BAAALgADCgEJAQAAAA==.',
['南小']='南小鸟:BAAALgAFFAIJAwAAAA==.',
['卡妙']='卡妙:BAAALgAECgYJBgAAAA==.',
['原神']='原神高手:BAAALgAECgQJAwAAAA==.',
['叔叔']='叔叔我还要:BAAALgAECgQJBAAAAA==.',
['叨叨']='叨叨:BAABLgAFFH8FAAMEAAMJGRH7DQDsAAAEAAMJ2xD7DQDsAAAFAAEJqRAOFQBBAAAAAA==.',
['史臻']='史臻香:BAAALgAECgIJAgAAAA==.',
['啾啾']='啾啾:BAAALgAECgIJAgAAAA==.',
['土老']='土老帽:BAAALgAECgcJCQAAAA==.',
['在这']='在这狂混:BAAALgAECgEJAwAAAA==.',
['夜一']='夜一:BAAALgAECgMJAwAAAA==.',
['大桥']='大桥未久:BAAALgAECgEJAgAAAA==.',
['大梦']='大梦一场:BAAALgAECgEJAQAAAA==.',
['天棒']='天棒坤哥:BAAALgADCgEJAQAAAA==.',
['天照']='天照:BAACLgAFFH8FAAIFAAMJ+hB2BQCfAAAFAAMJ+hB2BQCfAAAuAAQKfxYAAwUABwmRFIApAKYBAAUABwnSE4ApAKYBAAQABAnFDYU6ANQAAAAA.',
['天青']='天青色瞪眼鱼:BAAALgAFFAEJAQAAAA==.',
['对白']='对白:BAAALgADCgUJEgAAAA==.',
['小小']='小小影月:BAAALgAFFAEJAQAAAA==.',
['小錘']='小錘錘拳你胸:BAAALgADCgMJAwAAAA==.',
['帝陨']='帝陨:BAAALgAFFAMJBAAAAA==.',
['徐一']='徐一枫:BAAALgADCgMJFQAAAA==.',
['打我']='打我正七头:BAAALgAECgQJBAAAAA==.',
['提尔']='提尔鋒:BAAALgAECgYJBwAAAA==.',
['星辰']='星辰之陨:BAAALgAECgcJDgAAAA==.',
['极道']='极道乐师:BAAALgAFFAMJBAAAAA==.',
['枭妖']='枭妖:BAAALgAECgYJCQAAAA==.',
['格里']='格里高利:BAAALgADCgUJBQAAAA==.',
['桐言']='桐言:BAAALgAECgMJBAAAAA==.',
['梆梆']='梆梆不梆梆:BAAALgAFFAEJAQAAAA==.',
['流云']='流云飞霞:BAAALgADCgMJAwAAAA==.',
['游王']='游王子:BAAALgAECgIJAwAAAA==.',
['灰袍']='灰袍干豆腐:BAAALgAECgUJBQAAAA==.',
['熊猫']='熊猫人谜雾:BAAALgAECgEJAgABLgAFFAIJBAAGAAAAAA==.',
['牛奶']='牛奶吐司:BAAALgAECgYJEQAAAA==.',
['狐哩']='狐哩唬菟:BAAALgAFFAEJAQAAAA==.',
['猛干']='猛干小熊软糖:BAAALgAECgUJCQAAAA==.',
['甄棋']='甄棋行:BAABLgAFFH8HAAIHAAMJ6gd1GwCpAAAHAAMJ6gd1GwCpAAAAAA==.',
['疾如']='疾如风:BAAALgAECgEJAQAAAA==.',
['白歌']='白歌笑:BAAALgAFFAEJAQAAAA==.',
['盖亚']='盖亚龙卷风:BAAALgAECgEJAgAAAA==.',
['破笑']='破笑灭:BAAALgAECgIJAQAAAA==.',
['秋意']='秋意谣:BAAALgAECgEJAQAAAA==.',
['空心']='空心:BAAALgAECgEJAQAAAA==.',
['竹马']='竹马旧青梅落:BAAALgAECgYJBgAAAA==.',
['笑江']='笑江湖:BAAALgAECgYJBwAAAA==.',
['糖粒']='糖粒粒:BAAALgAECgQJBAAAAA==.',
['紫堂']='紫堂堂:BAAALgAECgYJDAAAAA==.',
['统治']='统治魔神:BAABLgAECn8UAAMIAAYJgxDlVwBLAQAIAAYJgxDlVwBLAQAJAAIJ4w/3GAB4AAAAAA==.',
['绯云']='绯云:BAAALgAECgQJBwAAAA==.',
['缺曰']='缺曰:BAAALgAECgEJAQAAAA==.',
['罪之']='罪之歌:BAACLgAFFH8LAAIKAAMJfwsLGADtAAAKAAMJfwsLGADtAAAuAAQKfysAAwoACAmkHSQlAJMCAAoACAmkHSQlAJMCAAsABwm/BdpSAC8BAAAA.',
['羽轻']='羽轻音:BAACLgAFFH8GAAIDAAMJvxq+FwCoAAADAAMJvxq+FwCoAAAuAAQKfxcAAgMABwlnHfsgAD8CAAMABwlnHfsgAD8CAAAA.',
['联盟']='联盟炒股佬:BAAALgAECgEJAgAAAA==.',
['胖胖']='胖胖龙:BAABLgAECn8VAAIKAAkJQRNzLgBpAgAKAAkJQRNzLgBpAgAAAA==.',
['芯潮']='芯潮澎湃:BAAALgAECgMJAwAAAA==.',
['荒野']='荒野寻踪者:BAAALgADCgQJBAAAAA==.',
['莫白']='莫白丨僧:BAAALgAECgEJAQAAAA==.',
['虾仁']='虾仁猪心:BAAALgADCgMJAwAAAA==.',
['蛋皮']='蛋皮皮:BAAALgAECgEJAgAAAA==.',
['西蜀']='西蜀一点红:BAAALgAECgYJAQAAAA==.西蜀红尘飘:BAAALgAECgEJAQAAAA==.',
['贝德']='贝德维爾:BAAALgADCgMJAwAAAA==.',
['贫僧']='贫僧不厚道:BAAALgAFFAIJAgAAAA==.',
['超级']='超级动物园:BAABLgAECn8eAAMDAAgJ7hkyCwC3AQADAAgJ7hkyCwC3AQAMAAEJuQA4mgAZAAAAAA==.',
['足下']='足下生风:BAACLgAFFH8ZAAINAAYJgiZrAACmAgANAAYJgiZrAACmAgAuAAQKfyEAAg0ACQn4JHUBAI8DAA0ACQn4JHUBAI8DAAAA.',
['跟我']='跟我走吧:BAAALgAECgYJBgAAAA==.',
['路明']='路明非陈雯雯:BAAALgAECgcJCgAAAA==.',
['轻尘']='轻尘:BAAALgAFFAEJAgAAAA==.',
['还是']='还是你缺德:BAAALgADCgMJAwAAAA==.',
['逝殇']='逝殇易云:BAAALgADCgcJDAAAAA==.',
['達拉']='達拉然的光輝:BAAALgAECgYJCgAAAA==.',
['部落']='部落最辣姬:BAAALgAECgQJBgAAAA==.',
['醉花']='醉花间:BAAALgADCgEJAQAAAA==.',
['鑫鑫']='鑫鑫金:BAAALgAFFAEJAQAAAA==.',
['长角']='长角的抱抱:BAAALgADCgEJAQAAAA==.',
['阿牛']='阿牛的术:BAAALgADCggJCAAAAA==.',
['雨风']='雨风翼:BAAALgAECgEJAwABLgAFFAEJAQAGAAAAAA==.',
['雷炎']='雷炎之星:BAAALgADCgUJBQAAAA==.',
['霜奶']='霜奶仙:BAAALgADCgEJAQAAAA==.',
['霹雳']='霹雳娇猛:BAABLgAECn8UAAIOAAYJLx47BACHAQAOAAYJLx47BACHAQAAAA==.',
['風若']='風若汐:BAAALgAECgMJBAAAAA==.',
['风蚀']='风蚀之弦:BAAALgAECgEJAQAAAA==.',
['香蕉']='香蕉鱼丶:BAAALgAECgQJBAAAAA==.',
['驚訝']='驚訝吃驚:BAAALgAECgQJBAAAAA==.',
['马踏']='马踏飞燕:BAAALgADCgMJBAAAAA==.',
['魂萦']='魂萦:BAABLgAECn8WAAMEAAcJ9A6HLQAxAQAEAAYJOAyHLQAxAQAFAAYJSw1GQwArAQAAAA==.',
['魔焱']='魔焱滔天:BAAALgAECgQJAQAAAA==.',
['魔神']='魔神的化身:BAAALgAECgEJAgAAAA==.',
['黑色']='黑色幽默:BAAALgAECgkJAwAAAA==.',
['鼠鼠']='鼠鼠滚:BAAALgAECgEJAwAAAA==.鼠鼠滚滚:BAAALgAECgUJBgAAAA==.',
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
