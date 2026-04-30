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

local lookup = {'Unknown-Unknown','Evoker-Augmentation','Mage-Frost','Rogue-Subtlety','Rogue-Assassination','Monk-Brewmaster','DemonHunter-Devourer','Priest-Holy','Evoker-Devastation','Druid-Restoration','Evoker-Preservation','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction',}
local provider = {region='CN',realm='迪托马斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akg:BAAALgAECggJEQAAAA==.',
Bo='Bomer:BAAALgAECgEJAgAAAA==.',
Co='Coolhot:BAAALgAECgYJBgAAAA==.',
Hh='Hhnexus:BAAALgAECgYJCgAAAA==.',
Ka='Kamilr:BAAALgAECgEJAQAAAA==.',
La='Lamperouge:BAAALgAECgcJBwAAAA==.',
Ne='Newniu:BAAALgADCgUJBwAAAA==.',
No='Novo:BAAALgAECgMJAwAAAA==.',
Ok='Ok:BAAALgAFFAIJBAAAAA==.',
Tr='Trinitylily:BAAALgAECgYJDQAAAA==.',
Wd='Wdkly:BAAALgAFFAcJBAAAAA==.',
['一样']='一样枫隐:BAAALgADCgcJCwAAAA==.',
['三上']='三上河北彩花:BAAALgAFFAEJAQAAAA==.三上秋雅:BAAALgADCgIJAgAAAA==.',
['三流']='三流小学生:BAAALgAECgEJAgABLgAECgIJAgABAAAAAA==.',
['九十']='九十九点九:BAAALgAECgIJAgAAAA==.',
['云游']='云游天涯:BAAALgAECgYJBgAAAA==.',
['五里']='五里:BAAALgAECgEJAQAAAA==.',
['佣兽']='佣兽:BAAALgAECgQJBAABLgAFFAMJCQACAIwVAA==.',
['储君']='储君:BAAALgAECgUJBQAAAA==.',
['光泽']='光泽:BAAALgADCgcJBwAAAA==.',
['创世']='创世元神:BAAALgAECgUJBgAAAA==.',
['卢卡']='卢卡:BAAALgAECgEJAQAAAA==.',
['君莫']='君莫笑:BAAALgADCgIJAgAAAA==.',
['命运']='命运女神:BAAALgADCgYJBgAAAA==.',
['哎呦']='哎呦哇啦:BAAALgAECgMJAwAAAA==.',
['唯一']='唯一性人:BAAALgAECgEJAQAAAA==.',
['嘟巿']='嘟巿蓅氓:BAAALgAECgYJCQAAAA==.',
['大聪']='大聪明:BAAALgAFFAEJAQAAAA==.',
['大腿']='大腿轻轻抚:BAACLgAFFH8FAAIDAAQJACWbCwDAAQADAAQJACWbCwDAAQAuAAQKfxkAAgMACAn7G/BGAGMCAAMACAn7G/BGAGMCAAAA.',
['奥拉']='奥拉斯塔萨:BAAALgADCgUJBQAAAA==.',
['妞妞']='妞妞侠:BAAALgAECgMJAwAAAA==.',
['宝贝']='宝贝儿:BAAALgADCgEJAQAAAA==.',
['小贼']='小贼一枚:BAACLgAFFH8IAAIEAAQJ5hOCCABiAQAEAAQJ5hOCCABiAQAuAAQKfxwAAwQABgmIInsVAGQCAAQABgmIInsVAGQCAAUAAwl7GdQRAOgAAAAA.',
['帮帮']='帮帮小朋友:BAAALgAECgQJBAAAAA==.',
['幽默']='幽默之保安:BAAALgAECgUJBQAAAA==.',
['忍者']='忍者鱼:BAACLgAFFH8GAAIDAAIJbhrDNQC/AAADAAIJbhrDNQC/AAAuAAQKfxwAAgMABwnzHZNMAFECAAMABwnzHZNMAFECAAAA.',
['悬崖']='悬崖上的草:BAAALgADCgEJAQAAAA==.',
['懒懒']='懒懒的缺缺:BAAALgAECgUJCAAAAA==.',
['抢你']='抢你裤衩:BAAALgAECgcJCgAAAA==.',
['拳头']='拳头弟弟:BAACLgAFFH8UAAIDAAcJpCF3AAD/AgADAAcJpCF3AAD/AgAuAAQKfxcAAgMACQkaJX4RAD8DAAMACQkaJX4RAD8DAAAA.',
['斑斓']='斑斓灵灵:BAABLgAFFH8FAAIGAAIJ2xdNGgCYAAAGAAIJ2xdNGgCYAAAAAA==.',
['普琳']='普琳赛丝:BAAALgAECgUJBwAAAA==.',
['暴打']='暴打小朋友:BAAALgAECgUJBQAAAA==.',
['木人']='木人:BAAALgAECgIJAgAAAA==.',
['朴丸']='朴丸丸:BAABLgAECn8UAAIHAAcJ+yGGMQA0AgAHAAcJ+yGGMQA0AgAAAA==.',
['桀骜']='桀骜天天:BAAALgADCgEJAQAAAA==.',
['梦游']='梦游的鱼:BAAALgAECgEJAQAAAA==.',
['榴莲']='榴莲刺猬:BAABLgAFFH8GAAIIAAMJZhT7BADcAAAIAAMJZhT7BADcAAAAAA==.',
['沃什']='沃什大拉基:BAEBLgAFFH8LAAMJAAUJOByXAgBbAQAJAAQJURWXAgBbAQACAAMJzhS+DwAGAQAAAA==.',
['深渊']='深渊者:BAAALgAECgQJBQAAAA==.',
['湮灭']='湮灭:BAAALgAECgYJBgAAAA==.',
['火星']='火星单身汉:BAAALgADCgMJAwAAAA==.火星骑士:BAAALgADCgEJAQAAAA==.',
['牛重']='牛重殴:BAAALgAECgkJCgAAAA==.',
['犹香']='犹香:BAAALgAECgEJAQAAAA==.',
['王木']='王木白雨木木:BAAALgADCgEJAQAAAA==.',
['理子']='理子:BAACLgAFFH8GAAIKAAQJBgk5DQASAQAKAAQJBgk5DQASAQAuAAQKfxYAAgoABgmlHAM2ANABAAoABgmlHAM2ANABAAAA.',
['石大']='石大侠:BAAALgAECgcJCwAAAA==.石大骑:BAAALgADCgEJAQAAAA==.',
['神启']='神启丷灭烬:BAAALgAFFAUJAQAAAA==.',
['秋叶']='秋叶落木:BAAALgADCgYJBgAAAA==.',
['粉魇']='粉魇:BAAALgADCgUJBQAAAA==.',
['粒粒']='粒粒子:BAAALgAFFAIJAgAAAA==.',
['繁華']='繁華褪盡:BAAALgAFFAEJAQAAAA==.',
['纳什']='纳什:BAAALgADCgYJBgAAAA==.',
['纳姆']='纳姆温:BAAALgAECgUJCwAAAA==.',
['细狗']='细狗行不行:BAAALgAECggJEQAAAA==.',
['绝世']='绝世神棍:BAAALgAECgQJCgAAAA==.',
['维萨']='维萨吉:BAACLgAFFH8JAAICAAMJjBXOCgD3AAACAAMJjBXOCgD3AAAuAAQKfxoABAIABwmZISETAE4CAAIABgmZISETAE4CAAkAAQkAAKQ2AGEAAAsAAQm2BzdKAC0AAAAA.',
['肥龙']='肥龙在天:BAACLgAFFH8KAAILAAQJOBn/CABYAQALAAQJOBn/CABYAQAuAAQKfyIAAgsABwmRJc8FAOsCAAsABwmRJc8FAOsCAAAA.',
['色弱']='色弱:BAAALgAECgQJBAAAAA==.',
['芭蕾']='芭蕾杀姬:BAAALgADCgQJBAAAAA==.',
['苹果']='苹果树:BAAALgAECgYJBgAAAA==.',
['荒野']='荒野孤行者:BAAALgAECgcJBwAAAA==.',
['萨琉']='萨琉弥斯:BAAALgAECgEJAgAAAA==.',
['萨琦']='萨琦瑪:BAAALgAECgQJBAAAAA==.',
['萨百']='萨百万:BAAALgADCgUJBQAAAA==.',
['血之']='血之泪:BAAALgAECgQJBAAAAA==.',
['訷彩']='訷彩飛扬:BAAALgAECgIJAgAAAA==.',
['越来']='越来越猛:BAAALgAECgEJAQAAAA==.',
['路大']='路大主教:BAAALgAECgUJBQAAAA==.',
['转世']='转世幻影:BAAALgADCgYJBwAAAA==.',
['辛巴']='辛巴叫幺七四:BAABLgAFFH8RAAIHAAUJbB+OBgC6AQAHAAUJbB+OBgC6AQAAAA==.',
['辞慕']='辞慕丶:BAAALgAECgUJBgAAAA==.',
['边渡']='边渡有次子:BAAALgAECgEJAgAAAA==.',
['速度']='速度咩:BAAALgAECgMJAwAAAA==.',
['邪恶']='邪恶冷静:BAABLgAFFH8FAAIMAAIJCgYmBgBdAAAMAAIJCgYmBgBdAAABLgAFFAQJBAABAAAAAA==.',
['醉人']='醉人的酒:BAAALgAECgYJCwAAAA==.',
['霍尔']='霍尔蒙克斯:BAABLgAECn8fAAQNAAcJjxVwhwBKAQANAAYJExBwhwBKAQAOAAIJKRarSwCKAAAPAAEJAAApLABGAAAAAA==.',
['霜雪']='霜雪明:BAAALgAECgMJBAAAAA==.',
['风轻']='风轻轻的吹:BAAALgAECgIJAgAAAA==.',
['风鸟']='风鸟院花月:BAAALgAECgcJDgAAAA==.',
['魔屠']='魔屠嚜嚜:BAAALgAFFAIJBAAAAA==.',
['鲜血']='鲜血长河:BAAALgAECgcJDwAAAA==.',
['鸡尔']='鸡尔加蛋:BAAALgAECgQJBgAAAA==.',
['默默']='默默我最乖:BAAALgAECgEJAQAAAA==.',
['龙卷']='龙卷:BAAALgAECgkJDAAAAA==.',
['龙葵']='龙葵:BAAALgADCgcJBwAAAA==.',
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
