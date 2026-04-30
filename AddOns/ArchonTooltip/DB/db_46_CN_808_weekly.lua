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

local lookup = {'Warrior-Arms','Unknown-Unknown','DeathKnight-Unholy','Warrior-Protection','Druid-Balance','Mage-Frost','Druid-Restoration','Priest-Holy','Priest-Discipline','Shaman-Restoration',}
local provider = {region='CN',realm='范达尔鹿盔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adnachiel:BAAALgAECgEJAQAAAA==.',
Al='Alhena:BAAALgAECgkJCQAAAA==.',
Ar='Arui:BAAALgAECgcJEQAAAA==.',
Ca='Cashgo:BAAALgAECgYJBwAAAA==.',
Cc='Ccas:BAAALgADCgEJAQAAAA==.',
Co='Congbaobao:BAAALgAECgYJBgAAAA==.',
Cs='Csafhuo:BAAALgAECgYJDAAAAA==.',
Ge='Gem:BAAALgAECgYJBwABLgAECggJHAABAA4gAA==.',
Ma='Maomaosea:BAAALgAECgUJCQAAAA==.',
Or='Orangess:BAAALgADCgIJAgAAAA==.',
Ra='Rafale:BAAALgAECgEJAQAAAA==.',
['一宏']='一宏儿一:BAAALgAFFAEJAgAAAA==.',
['一碗']='一碗蛋炒饭:BAAALgAECgMJAwAAAA==.',
['丁神']='丁神:BAAALgADCgUJBQAAAA==.',
['不想']='不想当溜溜梅:BAAALgAECgEJAQAAAA==.',
['丢丢']='丢丢今天没丢:BAAALgAECgkJAgAAAA==.',
['丨吃']='丨吃了就睡丨:BAAALgAECgcJBwABLgAFFAUJAwACAAAAAA==.',
['丨流']='丨流氓丶貔貅:BAAALgAECgYJDwAAAA==.',
['丶神']='丶神秀開天:BAABLgAFFH8HAAIDAAIJjyO7MADKAAADAAIJjyO7MADKAAAAAA==.',
['从小']='从小不学好:BAAALgADCgEJAQAAAA==.',
['代号']='代号四十七:BAAALgADCgUJBQAAAA==.',
['伊芙']='伊芙:BAAALgAECgkJBgAAAA==.',
['再来']='再来一个钟:BAAALgAECgIJAgAAAA==.',
['凌风']='凌风:BAAALgAECgEJAQAAAA==.',
['凛风']='凛风:BAAALgADCgMJAwAAAA==.',
['几博']='几博:BAAALgAECgUJBQAAAA==.',
['十一']='十一:BAAALgAECgEJAgAAAA==.',
['午夜']='午夜莲:BAAALgADCgYJBwAAAA==.',
['占戈']='占戈馬奇:BAAALgAECgEJAQAAAA==.',
['卡帕']='卡帕托斯:BAAALgAECgcJEAAAAA==.',
['吃宝']='吃宝石长大:BAAALgAFFAEJBAAAAA==.',
['善良']='善良的良:BAAALgADCgUJBQAAAA==.',
['回头']='回头一刀:BAAALgAECgcJDQAAAA==.',
['圆滚']='圆滚滚的程程:BAAALgAECgYJBwAAAA==.',
['城市']='城市一劣人:BAAALgAECgkJCQAAAA==.',
['天堂']='天堂之焰:BAAALgAFFAQJBAAAAA==.',
['天生']='天生油污:BAAALgAECgQJCAAAAA==.',
['姐夫']='姐夫的小姨子:BAAALgADCgEJAQAAAA==.',
['寂静']='寂静的黎明:BAAALgAECgEJAQAAAA==.',
['小心']='小心大人:BAAALgAECgUJBgAAAA==.',
['小笠']='小笠原茉由:BAAALgAFFAEJAQAAAA==.',
['小飞']='小飞棍来咯:BAAALgAECgMJAwAAAA==.',
['尛萌']='尛萌兒:BAAALgAECgQJBAAAAA==.',
['屁屁']='屁屁然:BAAALgADCgEJAQABLgAFFAUJCgAEAHUSAA==.',
['带刀']='带刀蝴蝶:BAAALgAECgcJBwAAAA==.',
['张翠']='张翠翠:BAAALgAECgUJCAAAAA==.',
['徐凡']='徐凡:BAAALgAECgYJBwAAAA==.',
['微风']='微风:BAAALgAECgQJDgAAAA==.',
['心智']='心智雕皇:BAABLgAFFH8FAAIFAAUJMxqEAgBqAQAFAAUJMxqEAgBqAQAAAA==.',
['志诚']='志诚爱玩牛:BAAALgAECgUJBQAAAA==.',
['忘忧']='忘忧谷药仙:BAAALgAECgEJAQAAAA==.',
['惹我']='惹我就砍你:BAABLgAFFH8FAAIDAAUJRRJ1BwCVAQADAAUJRRJ1BwCVAQAAAA==.',
['执笔']='执笔丶绘流年:BAAALgAECgMJAwAAAA==.',
['拉图']='拉图修斯:BAAALgAECgMJBAAAAA==.',
['拥抱']='拥抱暗影:BAAALgADCgMJAwAAAA==.',
['指原']='指原莉乃:BAAALgADCgYJBgAAAA==.',
['提纳']='提纳里:BAAALgAECgYJBgAAAA==.',
['断层']='断层术:BAAALgAECgIJAwAAAA==.',
['无限']='无限回忆:BAAALgADCgYJBgAAAA==.',
['时光']='时光能否倒流:BAAALgAECgYJCwAAAA==.',
['晨曦']='晨曦:BAAALgADCgEJAQAAAA==.',
['暁妞']='暁妞賊帥丶:BAAALgAECgYJBgAAAA==.',
['月夜']='月夜舞霓裳:BAAALgAECgcJBwAAAA==.',
['极冰']='极冰焱焱:BAACLgAFFH8HAAIGAAMJpRNSKQAPAQAGAAMJpRNSKQAPAQAuAAQKfxwAAgYABwknHRlJAFwCAAYABwknHRlJAFwCAAAA.',
['林夕']='林夕:BAAALgAFFAEJAQAAAA==.',
['歌剧']='歌剧魅影:BAAALgADCgYJBgAAAA==.',
['正经']='正经不错:BAAALgAECgEJAQAAAA==.',
['毕业']='毕业就失业:BAAALgAECgMJAwAAAA==.',
['泰坦']='泰坦的使者:BAABLgAFFH8KAAIHAAUJZRU5BACcAQAHAAUJZRU5BACcAQABLgAFFAcJDwAHAJIXAA==.',
['洅不']='洅不斬:BAAALgAECgUJBQAAAA==.',
['浅羽']='浅羽悠真:BAAALgADCgEJAQAAAA==.',
['温蕾']='温蕾萨:BAAALgADCgMJAwAAAA==.',
['潜龙']='潜龙勿用:BAAALgAECgcJDQAAAA==.',
['灭世']='灭世者之影:BAAALgAECgIJAwAAAA==.',
['灵魂']='灵魂都随心:BAAALgAECgYJBgAAAA==.',
['点燃']='点燃心海:BAAALgAECgYJAgAAAA==.',
['猎艳']='猎艳人生:BAAALgADCgEJAQAAAA==.',
['玄冰']='玄冰烈火:BAAALgADCgMJAwAAAA==.',
['电电']='电电萨:BAAALgAECgYJBgAAAA==.',
['白乌']='白乌鸦:BAAALgADCgIJAgAAAA==.',
['白色']='白色的魅力:BAAALgAECgEJAQAAAA==.白色追猎:BAAALgAECgEJAgAAAA==.',
['简大']='简大师:BAAALgADCgMJAwAAAA==.',
['繁花']='繁花灬挽歌:BAAALgAECgUJBQAAAA==.',
['绽放']='绽放的噬灵:BAAALgAECgcJEQAAAA==.绽放的圣光:BAAALgAECgkJCQAAAA==.',
['罗伯']='罗伯斯庇尔:BAAALgAECgcJEQAAAA==.',
['老猎']='老猎手:BAAALgAECgMJAwAAAA==.',
['耳朵']='耳朵有点长:BAAALgAECgYJCQAAAA==.',
['脆脆']='脆脆翠:BAACLgAFFH8KAAMIAAMJ2CXKAgAxAQAIAAMJ2CXKAgAxAQAJAAMJYyCICwAkAQAuAAQKfyMAAwgABwl0JaQFAPYCAAgABwl0JaQFAPYCAAkAAwktGx05AN4AAAAA.',
['苍白']='苍白的梦境:BAACLgAFFH8GAAIKAAIJAxtoFQCuAAAKAAIJAxtoFQCuAAAuAAQKfx0AAgoABwksIP8DAFUCAAoABwksIP8DAFUCAAAA.',
['苦工']='苦工:BAAALgAECgMJBgAAAA==.',
['莱恩']='莱恩:BAAALgAECgYJCgAAAA==.',
['萌萌']='萌萌的艾佳:BAAALgADCgIJAgAAAA==.',
['萧晴']='萧晴儿:BAAALgAECgQJBAAAAA==.',
['萧萧']='萧萧祭司:BAAALgADCgQJBAAAAA==.',
['萬兽']='萬兽:BAAALgADCgYJBgAAAA==.',
['赠送']='赠送的芙蓉王:BAAALgAECgYJBgAAAA==.',
['路人']='路人丶殇:BAAALgAECgEJAQAAAA==.',
['速度']='速度灭呀:BAAALgAECgcJBwAAAA==.',
['阿亦']='阿亦子:BAAALgAFFAIJAgAAAA==.',
['难得']='难得明白:BAAALgAECgUJCQAAAA==.',
['风华']='风华丶骑士:BAAALgAECgcJBwAAAA==.',
['风轻']='风轻花落:BAAALgAECgQJBAAAAA==.',
['香橙']='香橙小术:BAAALgAECgQJBAAAAA==.香橙小法:BAAALgAECgEJAQAAAA==.',
['麦格']='麦格莱尼铜须:BAAALgADCgMJAwAAAA==.',
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
