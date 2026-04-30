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

local lookup = {'Druid-Restoration','Monk-Brewmaster','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Mage-Frost','Paladin-Protection','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Warrior-Arms','Druid-Feral','Priest-Shadow','Priest-Holy','Priest-Discipline','DemonHunter-Devourer','Unknown-Unknown','DemonHunter-Havoc',}
local provider = {region='CN',realm='埃苏雷格',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Blueeyess:BAAALgAECgYJEQAAAA==.',
La='Lancelot:BAAALgAECgEJAgAAAA==.',
Li='Ling:BAABLgAFFH8IAAIBAAMJbR0eDQAUAQABAAMJbR0eDQAUAQAAAA==.',
Ps='Psionick:BAAALgAECgcJDgAAAA==.',
Te='Tearra:BAAALgADCgEJAQAAAA==.',
['一个']='一个小坏蛋:BAAALgAECgYJCwAAAA==.',
['一凌']='一凌一:BAAALgADCgUJBQAAAA==.',
['一木']='一木一浮生:BAAALgADCgIJAgAAAA==.',
['七月']='七月的秋刀鱼:BAABLgAFFH8HAAICAAQJqRBiEwDdAAACAAQJqRBiEwDdAAAAAA==.',
['乱夜']='乱夜月:BAABLgAECn8aAAQDAAgJUBphHABcAgADAAgJUBphHABcAgAEAAUJ6AX/XQDJAAAFAAEJVgwFMAAzAAAAAA==.',
['二人']='二人游:BAAALgAECgEJAwAAAA==.',
['仰中']='仰中:BAABLgAECn8UAAICAAkJUx5ZBwAPAwACAAkJUx5ZBwAPAwAAAA==.',
['会飞']='会飞的蜗牛:BAAALgAECgMJAwAAAA==.',
['佛祖']='佛祖:BAAALgAFFAEJAQAAAA==.',
['依文']='依文洁琳:BAAALgAECgYJDgAAAA==.',
['俺矮']='俺矮别欺负俺:BAAALgAECgUJCQAAAA==.',
['光明']='光明裂痕:BAAALgAECgYJEwAAAA==.光明隐者:BAAALgADCgEJAQAAAA==.',
['光速']='光速电魂:BAAALgADCgUJBQAAAA==.',
['六不']='六不溜:BAAALgAECgMJAwAAAA==.',
['典韦']='典韦灬:BAAALgAFFAEJAQAAAA==.',
['军团']='军团制裁者:BAAALgAECgEJAQAAAA==.',
['凯文']='凯文灬艾维娜:BAAALgADCgYJCgAAAA==.',
['加拉']='加拉哈德丶:BAAALgAECgEJAQAAAA==.',
['北政']='北政所:BAAALgAECgMJAwAAAA==.',
['匹德']='匹德菲特:BAAALgAECgYJEwAAAA==.',
['卡德']='卡德珈:BAABLgAFFH8LAAIGAAMJiRsMLgD+AAAGAAMJiRsMLgD+AAAAAA==.',
['史帝']='史帝芬席格:BAAALgAECgMJBgAAAA==.',
['哞哞']='哞哞牛奶:BAAALgAECgEJAQAAAA==.',
['回忆']='回忆雪静:BAAALgAFFAEJAgAAAA==.',
['圣光']='圣光在佑:BAAALgAFFAIJAwAAAA==.',
['墨陌']='墨陌默默:BAACLgAFFH8NAAIGAAQJkB61EgCCAQAGAAQJkB61EgCCAQAuAAQKfx4AAgYACQmDIPsaAAsDAAYACQmDIPsaAAsDAAAA.',
['夏天']='夏天的风:BAAALgAECgYJEwAAAA==.',
['多龙']='多龙巴鲁托:BAAALgAECgMJAwAAAA==.',
['夜的']='夜的凄凉:BAAALgAECgUJBQAAAA==.',
['大木']='大木:BAAALgADCgEJAQAAAA==.',
['大酱']='大酱风度:BAAALgAECgcJDgAAAA==.',
['天驱']='天驱一光喀:BAAALgAECgYJEwAAAA==.',
['太阳']='太阳丶:BAAALgAECgkJBwAAAA==.',
['安宁']='安宁的稻草:BAAALgAECgEJAQAAAA==.',
['小妖']='小妖蜜三锤:BAAALgAECgEJAgAAAA==.',
['小时']='小时候很丑:BAAALgAECgkJCQAAAA==.',
['布兰']='布兰琪:BAAALgAECgUJCAAAAA==.',
['庶哥']='庶哥会跳杀:BAAALgADCgEJAQAAAA==.',
['张小']='张小贱:BAAALgAECgcJCAAAAA==.',
['强效']='强效魔法:BAAALgAFFAUJAwAAAA==.',
['彩虹']='彩虹幻熊:BAABLgAECn8cAAMHAAgJJBcLFwBkAQAIAAcJtRGuggB0AQAHAAUJZRoLFwBkAQAAAA==.',
['心儿']='心儿:BAAALgAECgYJBwAAAA==.',
['忧伤']='忧伤的雷维尔:BAAALgADCgIJAgAAAA==.',
['怀特']='怀特迈恩:BAAALgAECgYJEwAAAA==.',
['愈慢']='愈慢愈美丽:BAAALgAECgYJBwAAAA==.',
['我正']='我正在冲钅:BAAALgADCgcJCAAAAA==.我正在圣疒:BAAALgAECgYJBwAAAA==.我正在治疗钅:BAAALgAECgYJBgAAAA==.',
['我跑']='我跑滴滴呢:BAABLgAECn8bAAMJAAkJSBoeRAD/AQAJAAcJWhkeRAD/AQAKAAMJtBnjNQDfAAAAAA==.',
['无言']='无言的泪珠:BAAALgAECgcJBQAAAA==.',
['既要']='既要又要还要:BAAALgADCgMJAwAAAA==.',
['旧城']='旧城之王:BAABLgAFFH8FAAILAAMJ0RjTBgCoAAALAAMJ0RjTBgCoAAABLgAFFAYJFgAMAJMjAA==.',
['旺旺']='旺旺掀被:BAAALgAECgcJCwAAAA==.',
['明月']='明月玄兰:BAAALgAFFAEJAQAAAA==.',
['暗夜']='暗夜法:BAAALgAECgEJAQAAAA==.暗夜骑:BAAALgAECgQJBAAAAA==.',
['暗影']='暗影螃蟹:BAAALgAECgEJAQAAAA==.',
['暴力']='暴力的葡萄:BAAALgAECggJDgAAAA==.',
['月之']='月之舞光:BAACLgAFFH8GAAMNAAQJNAKACgALAQANAAQJNAKACgALAQAOAAEJTRLOFABBAAAuAAQKfxgABA8ACQmADCMcALUBAA8ACQmQCyMcALUBAA4ABgmAB0VNAAMBAA0ABgkLCiVAAPUAAAAA.',
['染指']='染指浮生梦:BAAALgAECgMJAwAAAA==.',
['柯布']='柯布:BAAALgADCgUJBQAAAA==.',
['格兰']='格兰瑞尔:BAAALgAECgQJBAAAAA==.',
['梦境']='梦境行者:BAAALgADCgUJBQAAAA==.',
['正义']='正义骑士:BAAALgADCgMJAwAAAA==.',
['洛漓']='洛漓丶雨道:BAAALgAECgYJEwAAAA==.',
['浮生']='浮生欢愉少:BAAALgAECgEJAgAAAA==.',
['海释']='海释靈:BAAALgAECgYJCQAAAA==.',
['玛洛']='玛洛恩:BAAALgADCgIJAgAAAA==.',
['珍珠']='珍珠:BAACLgAFFH8OAAIQAAUJYhYjCQCXAQAQAAUJYhYjCQCXAQAuAAQKfyQAAhAACQmuH9AJADgDABAACQmuH9AJADgDAAAA.',
['生猛']='生猛:BAAALgADCgMJAQAAAA==.',
['破风']='破风丶:BAAALgAECgkJDAAAAA==.',
['空青']='空青:BAAALgADCgIJAgAAAA==.',
['穿云']='穿云丶:BAAALgAECgcJBgABLgAECgcJEwARAAAAAA==.',
['紫月']='紫月雪:BAAALgADCgQJBAAAAA==.',
['罐头']='罐头盒:BAAALgAECgYJEAAAAA==.',
['而今']='而今是老头:BAAALgADCgEJAQAAAA==.',
['艺萌']='艺萌:BAAALgAECgEJAgAAAA==.',
['蓝玉']='蓝玉:BAAALgAECgcJDQABLgAFFAUJDgAQAGIWAA==.',
['血色']='血色救赎:BAAALgAECgcJBwAAAA==.',
['裂石']='裂石丶:BAAALgAECgcJEwAAAA==.',
['言寺']='言寺冈:BAAALgAECgUJBQAAAA==.',
['豆沙']='豆沙包包:BAAALgADCgUJBQAAAA==.',
['路西']='路西安卡尔兹:BAAALgAECgMJAwAAAA==.',
['踏雪']='踏雪丶:BAAALgAECgcJDQABLgAECgcJEwARAAAAAA==.',
['逐梦']='逐梦:BAAALgADCgUJBQAAAA==.',
['邀玥']='邀玥:BAAALgADCgQJBAAAAA==.',
['郁闷']='郁闷的训兽师:BAAALgAECgEJAQAAAA==.',
['重生']='重生之我是猪:BAAALgAFFAIJAgAAAA==.',
['鑫鱻']='鑫鱻:BAAALgAECgEJAQAAAA==.',
['键盘']='键盘斗士:BAACLgAFFH8RAAIGAAUJex96CQDUAQAGAAUJex96CQDUAQAuAAQKfx0AAgYACAlwI2kgAPICAAYACAlwI2kgAPICAAAA.',
['闪远']='闪远一小点:BAAALgADCgEJAQAAAA==.',
['陌路']='陌路两相忘:BAAALgAECgIJAgAAAA==.',
['雷昂']='雷昂米修莉:BAAALgAECgEJAQAAAA==.',
['风中']='风中的火焰:BAAALgAECgYJEwAAAA==.',
['风智']='风智骋稀:BAAALgADCgEJAQAAAA==.',
['风铃']='风铃花:BAAALgAECgYJCwAAAA==.',
['风骚']='风骚:BAAALgAFFAUJAwAAAA==.',
['鬼少']='鬼少:BAAALgAECgUJBgAAAA==.',
['魂魄']='魂魄之殇:BAACLgAFFH8QAAIQAAUJTx08BABjAQAQAAUJTx08BABjAQAuAAQKfykAAxAACAmmIvANABADABAACAmmIvANABADABIAAwnFD6dVAJEAAAAA.',
['麻花']='麻花咕咕:BAAALgAFFAEJAQAAAA==.',
['黃昏']='黃昏的邂逅:BAAALgAECgYJBgAAAA==.',
['黑色']='黑色的沉默:BAAALgADCgEJAQAAAA==.',
['默默']='默默的狩猎:BAAALgAFFAIJAgAAAA==.',
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
