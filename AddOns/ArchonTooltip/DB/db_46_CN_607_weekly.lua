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

local lookup = {'Mage-Frost','DeathKnight-Unholy','DeathKnight-Blood','Hunter-BeastMastery','Warlock-Demonology','DemonHunter-Devourer','Unknown-Unknown','Warrior-Fury','Warrior-Protection',}
local provider = {region='CN',realm='哈兰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ch='Chriscc:BAAALgAFFAEJAQAAAA==.',
Do='Dogauyu:BAAALgADCgEJAQAAAA==.',
El='Element:BAAALgAECgMJBgAAAA==.',
Fi='Fingercroxx:BAAALgAECgIJAgAAAA==.',
We='Weiyan:BAAALgAECgUJCwAAAA==.',
['Ãå']='Ãåfs:BAAALgAECgkJBgABLgAFFAUJBgABABoKAA==.',
['一内']='一内内可愛:BAAALgAECgMJAwAAAA==.',
['一颗']='一颗惩戒的心:BAAALgAECgYJBwAAAA==.',
['丨简']='丨简单丨:BAAALgAECgQJBAAAAA==.',
['丶冲']='丶冲锋就崴脚:BAAALgAECgYJBgAAAA==.',
['丶茶']='丶茶叶灬:BAAALgADCgEJAQAAAA==.',
['也许']='也许是爱:BAAALgAECgcJBwAAAA==.',
['伊什']='伊什塔尔:BAAALgADCgYJBgAAAA==.',
['兜兜']='兜兜里有剑:BAAALgADCgMJAwAAAA==.兜兜里有槍:BAAALgAECgMJBQAAAA==.',
['其实']='其实很可爱:BAAALgAFFAEJAQAAAA==.',
['农业']='农业射:BAAALgAECgQJBQAAAA==.',
['冲锋']='冲锋撞闪现:BAAALgADCgEJAQAAAA==.',
['刚哥']='刚哥:BAAALgADCgEJAQAAAA==.',
['加藤']='加藤的鹰:BAAALgAECgkJBgAAAA==.',
['十字']='十字军流浪:BAAALgAECgIJAgAAAA==.',
['千颂']='千颂伊:BAAALgADCgMJAwAAAA==.',
['压缩']='压缩饼干:BAAALgADCgEJAQAAAA==.',
['口合']='口合克克:BAAALgAFFAUJBAAAAA==.',
['叭叭']='叭叭芭衲:BAAALgADCgEJAQAAAA==.',
['吸血']='吸血鬼丨小可:BAAALgAECgUJBQAAAA==.',
['咪哩']='咪哩嗶哩哞:BAAALgAECgkJCQAAAA==.',
['哈克']='哈克兄:BAABLgAFFH8FAAMCAAUJvRraDQBrAQACAAQJvRraDQBrAQADAAEJAAAjFwA+AAAAAA==.哈克克:BAAALgAFFAcJAwAAAA==.',
['哈兑']='哈兑克:BAABLgAFFH8GAAICAAQJlRoIFABSAQACAAQJlRoIFABSAQAAAA==.',
['哈兢']='哈兢:BAAALgAFFAYJAgAAAA==.',
['哞哞']='哞哞:BAAALgAECgQJBAAAAA==.',
['嘿歌']='嘿歌:BAAALgAECgYJDwAAAA==.',
['复方']='复方联苯:BAAALgADCgEJAQAAAA==.',
['夜微']='夜微凉:BAAALgAECgEJAgAAAA==.',
['大朗']='大朗狂风:BAAALgAECgYJCAAAAA==.',
['大米']='大米弓米弓:BAAALgAECgEJAQAAAA==.',
['天天']='天天魔你:BAAALgAECgQJBAAAAA==.',
['天道']='天道:BAAALgADCgQJBgAAAA==.',
['妗伶']='妗伶:BAAALgAECgUJBQAAAA==.',
['完美']='完美:BAAALgADCgMJAwAAAA==.',
['客官']='客官来呀:BAABLgAECn8XAAIEAAkJDxAnBwD4AQAEAAkJDxAnBwD4AQAAAA==.',
['封剑']='封剑藏刀:BAAALgAECgQJAgAAAA==.',
['封影']='封影:BAAALgADCgMJAwAAAA==.',
['小小']='小小牛奶:BAAALgADCgMJAwAAAA==.',
['小澤']='小澤瑪麗婭:BAAALgAFFAQJBAAAAA==.',
['巫舞']='巫舞:BAAALgAECgQJBAAAAA==.',
['希尔']='希尔瓦娜嘶:BAAALgAECgYJCwAAAA==.',
['怀特']='怀特迈恩:BAAALgADCgIJAgAAAA==.',
['我不']='我不紧张:BAAALgAECgQJBAAAAA==.',
['我还']='我还没吃饱:BAAALgAECgEJAQAAAA==.',
['指尖']='指尖上施法:BAAALgAECgMJAwAAAA==.',
['放学']='放学等我:BAAALgAECgEJAQAAAA==.',
['星回']='星回丶:BAAALgAECggJDwAAAA==.',
['暗夜']='暗夜丨星痕:BAAALgAECgMJAwAAAA==.',
['洛萨']='洛萨林:BAAALgAECgcJBwAAAA==.',
['涂山']='涂山瞳:BAAALgAECgUJBgAAAA==.',
['潶歌']='潶歌:BAAALgAECgYJDAAAAA==.',
['熊爷']='熊爷不做奶:BAAALgAECgQJAgAAAA==.',
['爆岁']='爆岁岁:BAABLgAFFH8HAAIFAAMJyQ6rGACmAAAFAAMJyQ6rGACmAAAAAA==.',
['牧中']='牧中舞人:BAAALgADCgIJAgAAAA==.',
['王者']='王者的使命:BAAALgAECgcJDgAAAA==.',
['玛德']='玛德增强萨:BAAALgAECgIJAgAAAA==.',
['玲娜']='玲娜貝兒:BAABLgAECn8bAAIFAAkJpxMpKQBsAgAFAAkJpxMpKQBsAgAAAA==.',
['电波']='电波元气少女:BAAALgAECgYJCAAAAA==.',
['矝枔']='矝枔:BAAALgAECgMJCAAAAA==.',
['箭驰']='箭驰弓满:BAAALgADCgIJAwAAAA==.',
['米朵']='米朵:BAAALgAECgYJEQAAAA==.',
['红唇']='红唇暴徒:BAAALgAECgQJBAAAAA==.',
['胖胖']='胖胖的小肚:BAAALgAFFAQJBAAAAA==.',
['色如']='色如刮骨钢刀:BAAALgAFFAIJAwAAAA==.',
['艾芙']='艾芙悠希珂:BAAALgAECgYJBgAAAA==.',
['莉莉']='莉莉安妮:BAAALgAECgYJBgAAAA==.',
['软绵']='软绵绵:BAABLgAFFH8LAAIGAAQJnQ8AEwA6AQAGAAQJnQ8AEwA6AQABLgAFFAUJAwAHAAAAAA==.',
['辛多']='辛多雷侦察兵:BAAALgAECgUJCAAAAA==.',
['辛灬']='辛灬巴:BAAALgAECgYJBgAAAA==.',
['还取']='还取不上名字:BAACLgAFFH8LAAMIAAMJ+xVHBQAMAQAIAAMJ+xVHBQAMAQAJAAEJ3AgbEQA7AAAuAAQKfx4AAggABwn9H4oXAJACAAgABwn9H4oXAJACAAAA.',
['酸梅']='酸梅汤:BAAALgADCgYJBgAAAA==.',
['阿弥']='阿弥陀佛:BAAALgAECgEJAQAAAA==.',
['零零']='零零柒:BAAALgAECgIJAwAAAA==.零零發:BAAALgADCgcJBwAAAA==.',
['青瓷']='青瓷白画殇:BAAALgAECgEJAQAAAA==.',
['风中']='风中的木鱼:BAAALgAECgYJCwAAAA==.',
['黑科']='黑科技:BAAALgAECgUJBgAAAA==.',
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
