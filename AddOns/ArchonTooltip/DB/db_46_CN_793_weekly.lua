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

local lookup = {'Mage-Frost','DeathKnight-Unholy','Warrior-Arms','Unknown-Unknown','Warrior-Protection','Warrior-Fury','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Devourer','Paladin-Retribution','Warlock-Destruction','Paladin-Protection','Warlock-Demonology','Monk-Windwalker','Hunter-Survival','Evoker-Preservation','Paladin-Holy','Rogue-Subtlety','DeathKnight-Blood','Warlock-Affliction','Monk-Mistweaver','Priest-Discipline','Druid-Restoration','Monk-Brewmaster','Shaman-Restoration','Shaman-Elemental',}
local provider = {region='CN',realm='耐奥祖',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Always:BAAALgAECgQJBAAAAA==.',
An='Anyway:BAAALgAECgIJAgAAAA==.',
Bl='Bloodborne:BAABLgAFFH8FAAIBAAIJZBOROwC0AAABAAIJZBOROwC0AAAAAA==.',
Br='Brightspirit:BAAALgAECgYJBwAAAA==.',
Cj='Cjdh:BAAALgAECgUJBgAAAA==.',
Cl='Clara:BAAALgAECgUJBgAAAA==.',
Cu='Cuticle:BAAALgAECgcJAQAAAA==.',
Da='Daseinn:BAAALgAECgEJAQAAAA==.',
Di='Dierwo:BAAALgAECgQJBAAAAA==.',
Do='Donottouchme:BAAALgAECgcJDQAAAA==.',
Fi='Finalnao:BAAALgAECgUJBQAAAA==.',
Gr='Grandpa:BAAALgADCgIJAgAAAA==.',
Ha='Haohaa:BAABLgAECn8VAAICAAcJnBomSQAYAgACAAcJnBomSQAYAgAAAA==.Haola:BAAALgAECgYJBwABLgAECgcJFQACAJwaAA==.',
Hd='Hdeyz:BAABLgAECn8WAAICAAgJtx0ZHQDRAgACAAgJtx0ZHQDRAgAAAA==.',
Ka='Kala:BAAALgADCgcJBwAAAA==.',
Lo='Lottery:BAAALgAFFAQJBAAAAA==.',
Mi='Minotaurs:BAAALgAECgYJBgABLgAFFAUJBwADADEdAA==.Miracle:BAAALgADCgUJBQABLgAECgYJBgAEAAAAAA==.',
Mo='Monikasm:BAAALgAFFAMJBAAAAA==.',
Ny='Nya:BAAALgAECgYJBgAAAA==.',
On='Onemoretimes:BAAALgAECgMJAwAAAA==.',
Ro='Rolex:BAAALgAECgQJBAAAAA==.',
Sa='Sapagaagonie:BAACLgAFFH8OAAIFAAQJYwn3AwD9AAAFAAQJYwn3AwD9AAAuAAQKfy0AAwUACQnaGJkMAEECAAUACQk9F5kMAEECAAYAAQndFYGZAFoAAAAA.',
Sc='Scarlett:BAAALgAECgYJBgABLgAFFAQJAQAEAAAAAA==.',
Sy='Sylvan:BAABLgAFFH8FAAIHAAIJaw6BBACiAAAHAAIJaw6BBACiAAAAAA==.',
Ya='Yasashi:BAAALgAECgEJAgAAAA==.',
Zi='Ziyuzile:BAACLgAFFH8GAAIIAAMJwBQsCwAIAQAIAAMJwBQsCwAIAQAuAAQKfxoAAwgACAl4Ib8JAPsCAAgACAl4Ib8JAPsCAAkAAQkAAImcAAYAAAAA.',
['一满']='一满满一:BAAALgAECgQJCAAAAA==.',
['下午']='下午凉茶:BAAALgAECgMJAwAAAA==.',
['丢了']='丢了个橙:BAAALgADCgQJBAABLgAFFAIJAwAEAAAAAA==.',
['丨乏']='丨乏乄味丶:BAAALgADCgEJAQAAAA==.',
['丨朮']='丨朮丶:BAAALgADCgMJAwABLgAECgkJDAAEAAAAAA==.',
['丶暮']='丶暮色倾城:BAAALgADCgMJAwAAAA==.',
['为难']='为难队友:BAABLgAFFH8FAAIBAAUJpRlYCADfAQABAAUJpRlYCADfAQAAAA==.',
['丿灬']='丿灬十年饮冰:BAABLgAECn8WAAIKAAgJ6CBnDwAEAwAKAAgJ6CBnDwAEAwAAAA==.丿灬浊酒壹壶:BAAALgAECgEJAQAAAA==.',
['丿米']='丿米凯撒丨:BAAALgAFFAEJAQAAAA==.',
['了無']='了無所愛:BAAALgAECgEJAQABLgAECgQJBAAEAAAAAA==.',
['云朵']='云朵:BAAALgAECgcJBAABLgAFFAcJBAAEAAAAAA==.',
['亡命']='亡命冲塔送:BAABLgAFFH8GAAIHAAMJ1R7OBAAaAQAHAAMJ1R7OBAAaAQAAAA==.',
['令狐']='令狐沖:BAAALgAECgkJCQAAAA==.',
['伊莎']='伊莎贝莉:BAAALgAECgUJBQAAAA==.',
['伟大']='伟大的试验:BAAALgADCgUJBwAAAA==.',
['佐倉']='佐倉綾音:BAAALgAECgQJBAAAAA==.',
['何伯']='何伯:BAAALgADCgYJBgAAAA==.',
['何糖']='何糖糖:BAAALgADCgYJCAAAAA==.',
['你看']='你看我硬不:BAAALgAECgEJAQAAAA==.',
['佩露']='佩露薇莉:BAABLgAFFH8IAAIBAAQJqgjWDgBAAQABAAQJqgjWDgBAAQAAAA==.',
['俯卧']='俯卧撑:BAAALgAECgYJBgAAAA==.',
['偷猫']='偷猫的咕咕:BAAALgAECgUJBQAAAA==.',
['傷心']='傷心小栈:BAABLgAECn8VAAILAAYJjRyoWADZAQALAAYJjRyoWADZAQAAAA==.',
['克里']='克里斯蒂娜:BAAALgADCgYJBgAAAA==.',
['兔兔']='兔兔跳啊跳啊:BAAALgAECgUJBgABLgAFFAEJAQAEAAAAAA==.',
['兜兜']='兜兜木有糖:BAAALgAECgcJBwAAAA==.',
['八头']='八头锅:BAAALgADCgMJAwAAAA==.',
['冥花']='冥花有註:BAAALgADCgMJAwAAAA==.',
['冰峰']='冰峰之巅:BAAALgAECgQJBwAAAA==.',
['冰莲']='冰莲火舞:BAAALgAECgIJAgAAAA==.',
['冷清']='冷清秋灬:BAAALgAFFAIJAgABLgAFFAgJCQAMAC0aAA==.',
['冷露']='冷露无声:BAAALgAECgkJCQAAAA==.',
['冷風']='冷風嚎:BAAALgADCgEJAQAAAA==.',
['准提']='准提道人:BAACLgAFFH8IAAILAAMJMR/mDwAoAQALAAMJMR/mDwAoAQAuAAQKfyIAAwsACAn+IpINACEDAAsACAn+IpINACEDAA0ABAnEGXIlAN0AAAAA.',
['凤栖']='凤栖朝阳:BAAALgAFFAQJAQABLgAFFAcJCwALAEEbAA==.',
['切克']='切克闹:BAAALgAECgYJCgAAAA==.',
['删灬']='删灬除:BAAALgAFFAIJAwAAAA==.',
['删除']='删除灬灬:BAAALgADCgEJAQAAAA==.',
['刹古']='刹古拉:BAAALgAFFAIJAgAAAA==.',
['动态']='动态血糖仪:BAAALgAFFAIJAgAAAA==.',
['勇剑']='勇剑斩天罡:BAAALgADCgQJBAAAAA==.',
['勇敢']='勇敢的甜甜:BAAALgAECgcJBwABLgAFFAQJBAAEAAAAAA==.',
['化肥']='化肥会挥发:BAAALgAFFAIJAgAAAA==.',
['医翻']='医翻都流口水:BAAALgAECgEJAQABLgAFFAIJAwAEAAAAAA==.',
['十五']='十五夜望月:BAAALgAECgkJEAAAAA==.',
['又见']='又见鲜血:BAAALgADCgEJAQAAAA==.',
['叉烧']='叉烧星星:BAAALgAECgEJAQABLgAFFAUJBAAEAAAAAA==.',
['只喝']='只喝红乌苏:BAAALgAECgUJBQAAAA==.',
['后羿']='后羿:BAAALgAECgEJAQAAAA==.',
['咕咕']='咕咕馒头:BAAALgAECgYJDAAAAA==.',
['咖啡']='咖啡喵:BAAALgADCgUJBQAAAA==.',
['哎呦']='哎呦丶格雷:BAAALgADCgEJAQAAAA==.哎呦好小:BAAALgAECgIJAgABLgAECgQJBAAEAAAAAA==.',
['哒哒']='哒哒撒:BAAALgADCgUJBQAAAA==.',
['啊尔']='啊尔托莉雅:BAAALgAECgcJCgAAAA==.',
['喵星']='喵星渔:BAABLgAECn8WAAIBAAcJvhlCYwATAgABAAcJvhlCYwATAgAAAA==.',
['四系']='四系图腾:BAAALgAFFAIJAgAAAA==.',
['圣光']='圣光女骑士:BAAALgAECgUJBwAAAA==.',
['圣血']='圣血魔骑:BAAALgAECgEJAQAAAA==.',
['基米']='基米洛乔伊斯:BAAALgAECgcJBwAAAA==.基米洛十一战:BAAALgAECgcJBAAAAA==.基米洛忒弥斯:BAAALgAECgcJBQAAAA==.',
['塞拉']='塞拉赞恩:BAAALgAECgEJAQABLgAFFAYJFAAOAPIgAA==.',
['壞饅']='壞饅頭:BAAALgAECgEJAgAAAA==.',
['壹仟']='壹仟:BAAALgADCgEJAQAAAA==.',
['夏季']='夏季八碗:BAAALgAECgUJCwAAAA==.',
['大付']='大付丨德:BAAALgAECgQJBAAAAA==.大付丨猎:BAAALgAECgcJDgAAAA==.大付丨萨满:BAAALgAECgYJBgAAAA==.',
['大树']='大树花生:BAAALgAECgEJAQAAAA==.',
['大贼']='大贼贼:BAAALgAECgQJBAAAAA==.',
['天地']='天地血魔:BAAALgAECgEJAQAAAA==.',
['天真']='天真萌萌姐:BAAALgAECgYJEAAAAA==.',
['太纸']='太纸:BAAALgADCgEJAQAAAA==.',
['太阳']='太阳之子:BAAALgADCgUJAgAAAA==.',
['奈非']='奈非天:BAAALgAECgUJCAAAAA==.',
['妮可']='妮可拉基芭岛:BAAALgAECgkJBwAAAA==.',
['孙猴']='孙猴子:BAAALgAECgQJCAAAAA==.',
['实影']='实影:BAAALgAECgYJCgAAAA==.',
['寒树']='寒树栖鸦:BAAALgAECgkJDwAAAA==.',
['寒風']='寒風飄零:BAAALgAECgUJBwAAAA==.',
['寓仔']='寓仔:BAAALgAECgkJCQAAAA==.',
['小小']='小小丶三号机:BAABLgAFFH8NAAIIAAUJFBc6BABdAQAIAAUJFBc6BABdAQABLgAFFAgJBgAJAG8UAA==.小小丶二号机:BAABLgAFFH8PAAMIAAUJCRdIBQBPAQAIAAUJqhBIBQBPAQAJAAMJBxJ8FQDwAAABLgAFFAgJBgAJAG8UAA==.小小丶初号机:BAABLgAFFH8NAAMIAAUJwBnsBABUAQAIAAUJQRPsBABUAQAJAAIJpxfyGQC1AAABLgAFFAgJBgAJAG8UAA==.小小丶劣人:BAABLgAFFH8FAAMIAAQJ+hDbBABVAQAIAAQJ+hDbBABVAQAJAAEJ/glAJwBOAAAAAA==.小小的星星:BAAALgAECgUJBQAAAA==.',
['小布']='小布:BAAALgAECgYJBgABLgAECgYJBgAEAAAAAA==.',
['小栈']='小栈:BAAALgAECgMJAwAAAA==.',
['小火']='小火龙:BAAALgAECgQJAQAAAA==.',
['小落']='小落大叶:BAABLgAFFH8JAAILAAMJ2CRjBwA4AQALAAMJ2CRjBwA4AQAAAA==.',
['峨嵋']='峨嵋刺:BAABLgAECn8XAAIPAAcJRgcvDwAKAQAPAAcJRgcvDwAKAQAAAA==.',
['左转']='左转丶暗恋:BAAALgAECgYJDAAAAA==.',
['巨硬']='巨硬:BAAALgAECgcJEgAAAA==.',
['布兰']='布兰卡:BAAALgADCgEJAQAAAA==.',
['年轻']='年轻有为:BAABLgAECn8VAAICAAcJiBd4XADdAQACAAcJiBd4XADdAQAAAA==.',
['幻胖']='幻胖:BAAALgAECgQJBAAAAA==.',
['幽梦']='幽梦伊馨:BAAALgADCgEJAQAAAA==.',
['幽蓝']='幽蓝紫月:BAACLgAFFH8GAAIIAAMJshphCQAWAQAIAAMJshphCQAWAQAuAAQKfxkAAwgACAlSHbQaAGcCAAgACAlSHbQaAGcCABAABQm9D0cNAO4AAAAA.',
['弑血']='弑血寒刃:BAAALgAECgUJCgAAAA==.',
['强如']='强如冰清:BAAALgAECgEJAgAAAA==.',
['徐丶']='徐丶字宋:BAAALgAECgEJAwAAAA==.',
['德之']='德之我性:BAAALgAECgEJAgAAAA==.',
['德德']='德德戚戚:BAAALgAECgYJEAAAAA==.',
['恶龙']='恶龙咆哮丶丶:BAABLgAFFH8IAAIRAAQJ3wowCwA3AQARAAQJ3wowCwA3AQAAAA==.',
['想像']='想像:BAAALgAFFAEJAwAAAA==.',
['慕雨']='慕雨丶夜:BAACLgAFFH8IAAMLAAMJcCZqBgBIAQALAAMJcCZqBgBIAQASAAEJMwkXHwA9AAAuAAQKfxcAAxIACAm6CWtLAEoBABIABwm9B2tLAEoBAAsAAgkpJRrZANkAAAAA.',
['我上']='我上来就一拳:BAAALgAECgEJAQAAAA==.',
['我只']='我只会飞:BAABLgAFFH8FAAIKAAIJOwLtLwCDAAAKAAIJOwLtLwCDAAAAAA==.',
['我在']='我在后面掩护:BAAALgAFFAEJAQAAAA==.',
['我是']='我是奶龙:BAAALgAECgYJBgAAAA==.',
['我要']='我要验牌:BAABLgAFFH8FAAILAAQJ5BL3BQBNAQALAAQJ5BL3BQBNAQAAAA==.',
['战无']='战无霜:BAACLgAFFH8KAAIFAAMJ1ghFCQC8AAAFAAMJ1ghFCQC8AAAuAAQKfyEAAwUACAleEqUWAKYBAAUACAmkEaUWAKYBAAYAAQmcE1agAEEAAAAA.',
['手留']='手留余香:BAAALgAFFAIJAgAAAA==.',
['扑湿']='扑湿玛丽:BAABLgAFFH8HAAIOAAMJ+xbMHgAIAQAOAAMJ+xbMHgAIAQAAAA==.',
['挖图']='挖图熊猫:BAAALgAECgEJAgAAAA==.',
['揾笨']='揾笨七:BAAALgAECgEJAQAAAA==.',
['斩殺']='斩殺:BAAALgADCgEJAQAAAA==.',
['无兄']='无兄弟不嗜血:BAAALgAFFAIJAgAAAA==.',
['无尽']='无尽的星空:BAAALgAECgMJAwAAAA==.',
['无敌']='无敌琪琪:BAAALgADCgUJBQAAAA==.',
['星枢']='星枢呈瑞:BAABLgAECn8WAAITAAYJSRtcIwDeAQATAAYJSRtcIwDeAQAAAA==.',
['星辰']='星辰坠入深海:BAACLgAFFH8IAAIUAAMJth4PCAALAQAUAAMJth4PCAALAQAuAAQKfyEAAhQACAl4IAQGANsCABQACAl4IAQGANsCAAAA.',
['星铖']='星铖:BAAALgAECgkJCQAAAA==.',
['暮鼓']='暮鼓宸冢:BAABLgAECn8VAAICAAkJsyAiCABeAwACAAkJsyAiCABeAwAAAA==.',
['月光']='月光莫里亚:BAAALgAECgYJCQAAAA==.',
['月夜']='月夜星彩:BAAALgAECgEJAQAAAA==.',
['月無']='月無露:BAAALgAECgYJBgAAAA==.',
['术业']='术业专攻:BAABLgAECn8iAAQOAAgJ+RgwLgBUAgAOAAgJ+RgwLgBUAgAMAAQJogIGTwCBAAAVAAEJwgK8NgAqAAAAAA==.',
['朱莉']='朱莉安娜丶:BAAALgAECgEJAQAAAA==.',
['李小']='李小龙:BAAALgAECgkJCQAAAA==.',
['杠爆']='杠爆十三幺:BAAALgAECgQJCgAAAA==.',
['极阴']='极阴岛韩天尊:BAAALgAECgMJAwAAAA==.',
['柚柚']='柚柚:BAAALgADCgUJBQAAAA==.',
['核喵']='核喵汪:BAAALgAECgYJCQAAAA==.',
['核桃']='核桃喵喵:BAAALgAECgYJEAAAAA==.',
['根特']='根特大:BAAALgAECgIJAgAAAA==.',
['樱空']='樱空桃:BAAALgAECgYJCgAAAA==.',
['檸尛']='檸尛檬灬:BAAALgAFFAEJAgAAAA==.',
['武浅']='武浅静:BAAALgAECgYJBwAAAA==.',
['歧路']='歧路唱离歌:BAAALgADCgEJAgAAAA==.',
['死亡']='死亡之源:BAAALgAECgkJEAAAAA==.死亡背叛:BAAALgAECgUJBQAAAA==.',
['殷家']='殷家道:BAAALgADCgEJAQAAAA==.',
['水坑']='水坑之王:BAAALgAECgYJDQAAAA==.',
['水有']='水有意:BAAALgAECgUJCQAAAA==.',
['法力']='法力残渣:BAAALgAECgMJAwAAAA==.',
['泡老']='泡老板:BAAALgAECgYJBgABLgAFFAkJBgAWALgTAA==.',
['浪漫']='浪漫小鱼儿:BAAALgAECgYJCwAAAA==.',
['浮华']='浮华掠影:BAAALgAECgEJAgAAAA==.',
['浮士']='浮士唐红艳煞:BAAALgAECgEJAQAAAA==.',
['液态']='液态史莱姆:BAAALgAECgQJBAAAAA==.',
['深夜']='深夜召唤人:BAAALgAECgYJBgAAAA==.深夜小白牛:BAABLgAECn8YAAILAAkJRh8PAQD7AgALAAkJRh8PAQD7AgAAAA==.深夜小黑牛:BAAALgAECgkJDwAAAA==.深夜料理人:BAAALgAECgUJBQABLgAECgYJBgAEAAAAAA==.深夜熊喵人:BAAALgAECgYJBgABLgAECgYJBgAEAAAAAA==.深夜蝙蝠人:BAAALgAFFAQJAQAAAA==.深夜赶尸人:BAAALgAECgUJBQABLgAECgYJBgAEAAAAAA==.深夜青哔哔:BAAALgADCgYJBgAAAA==.',
['湾仔']='湾仔之火车神:BAAALgAECgcJCwAAAA==.',
['满目']='满目星河:BAAALgAECgUJBQAAAA==.',
['漫漫']='漫漫牛:BAAALgAECgUJBwAAAA==.',
['灬尐']='灬尐泗哥灬:BAAALgAECgcJBwAAAA==.',
['灬神']='灬神辉星辰灬:BAAALgADCgMJAwAAAA==.',
['炙热']='炙热的冰:BAAALgAECgYJBgAAAA==.',
['烟花']='烟花易冷丶:BAAALgAECgYJBgAAAA==.',
['烨世']='烨世兵权:BAAALgAECgEJAQAAAA==.',
['焱焱']='焱焱:BAAALgAECgUJCAAAAA==.',
['熊猫']='熊猫人武僧:BAAALgAECgcJCwAAAA==.',
['燕麦']='燕麦坚果:BAAALgAECgYJCQAAAA==.',
['牛腩']='牛腩粉:BAAALgAECgMJBAAAAA==.',
['牜牜']='牜牜丨丨:BAAALgAECgEJAQAAAA==.',
['狂燊']='狂燊:BAAALgAECggJDAABLgAECgYJBgAEAAAAAA==.',
['白桃']='白桃兔兔奶冻:BAAALgAECgYJBgABLgAFFAIJCAAHALAZAA==.',
['皓燃']='皓燃:BAAALgAFFAUJAwAAAA==.',
['盖伦']='盖伦:BAAALgAFFAMJAwAAAA==.',
['相依']='相依为命:BAAALgAECgQJBwAAAA==.',
['社川']='社川梨:BAAALgAECgkJEAAAAA==.',
['神圣']='神圣的奇酷比:BAAALgAECgcJBwABLgAFFAMJCAAXAPwYAA==.',
['神罚']='神罚之怒:BAAALgADCgIJAgAAAA==.',
['神靈']='神靈乄德铖:BAABLgAECn8UAAIYAAcJCBmsNwDJAQAYAAcJCBmsNwDJAQAAAA==.',
['福娃']='福娃武影:BAAALgADCgQJBAAAAA==.',
['稳鸠']='稳鸠你笨七:BAAALgAECgUJBgAAAA==.',
['空歡']='空歡喜丶:BAAALgAFFAMJBAAAAA==.',
['童子']='童子鸡盖饭:BAAALgADCgUJBQAAAA==.',
['筱曉']='筱曉:BAAALgAECgQJBQAAAA==.',
['箭拔']='箭拔弩张:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色职业:BAAALgAECgUJBAAAAA==.',
['红菱']='红菱舞姬:BAABLgAFFH8IAAIHAAIJsBnMBwCzAAAHAAIJsBnMBwCzAAAAAA==.',
['绿女']='绿女驴与绿驴:BAAALgADCgUJBQAAAA==.',
['罗克']='罗克西阿斯:BAAALgAFFAIJBAABLgAFFAcJBAAEAAAAAA==.',
['罗大']='罗大米:BAAALgAFFAIJBAAAAA==.',
['羽川']='羽川翼:BAACLgAFFH8MAAIBAAQJ4RaZGgBgAQABAAQJ4RaZGgBgAQAuAAQKfxYAAgEABwnLHG9xAPEBAAEABwnLHG9xAPEBAAAA.',
['老驴']='老驴的小宋:BAAALgAECgUJBQAAAA==.',
['肾启']='肾启示:BAAALgAECgcJCgAAAA==.',
['能不']='能不能用点力:BAABLgAECn8XAAIKAAkJTSLSAwCNAwAKAAkJTSLSAwCNAwAAAA==.',
['自卫']='自卫少女:BAAALgADCgEJAQAAAA==.',
['舞丶']='舞丶:BAAALgAECgUJBQAAAA==.',
['舞无']='舞无馒头:BAAALgAECgYJCAAAAA==.',
['花非']='花非花粉凤凰:BAAALgAECgYJBgAAAA==.',
['苍白']='苍白:BAAALgAECgYJBgAAAA==.',
['苟且']='苟且的小宋:BAAALgADCgEJAQAAAA==.',
['莫德']='莫德凯撒:BAAALgADCgMJAwAAAA==.',
['菩提']='菩提下的小牛:BAAALgAECgEJAQAAAA==.',
['萨塔']='萨塔妮娅晨星:BAAALgAECgUJBQAAAA==.',
['萨满']='萨满丶小小:BAAALgAECgEJAQAAAA==.',
['葬夜']='葬夜星:BAAALgADCgQJBAAAAA==.',
['葬爱']='葬爱傾城:BAAALgAECgEJAQAAAA==.',
['蔚蓝']='蔚蓝丶乱羽:BAAALgAECgkJEAAAAA==.蔚蓝丶光之翼:BAAALgAECgkJEAAAAA==.',
['蕾雅']='蕾雅希拉:BAAALgAECgYJDAAAAA==.',
['螺丝']='螺丝椒:BAAALgADCgIJAgAAAA==.',
['血东']='血东东:BAAALgAECgQJBAAAAA==.',
['血祭']='血祭血影:BAAALgADCgEJAQAAAA==.',
['诡手']='诡手丶:BAAALgAECgEJAQAAAA==.',
['豆豆']='豆豆打豆豆:BAAALgADCgYJBgAAAA==.',
['貌美']='貌美如花:BAAALgADCgQJBwAAAA==.貌美如贺:BAAALgAECgYJBwAAAA==.',
['财神']='财神爷的宝宝:BAAALgADCgMJAwAAAA==.',
['赤华']='赤华:BAAALgAECgYJCQAAAA==.',
['跳啊']='跳啊跳兔兔:BAAALgAFFAEJAQAAAA==.',
['转身']='转身就不离开:BAAALgADCgYJBgAAAA==.转身没离开:BAAALgADCgMJAwAAAA==.',
['轻舞']='轻舞叹惜:BAAALgAECgcJBwAAAA==.',
['辉夜']='辉夜的沉沦:BAAALgADCgIJAgAAAA==.',
['辣椒']='辣椒炒肉:BAAALgAECgkJAwABLgAFFAUJBAAEAAAAAA==.',
['道航']='道航天尊:BAAALgADCgYJBgAAAA==.',
['邪能']='邪能恶魔:BAAALgAECgEJAQAAAA==.',
['鄙夫']='鄙夫问于我:BAAALgAECgcJDgAAAA==.',
['酒中']='酒中酒霸:BAABLgAFFH8LAAIZAAQJdAuZDgAPAQAZAAQJdAuZDgAPAQAAAA==.',
['酸辣']='酸辣粉:BAAALgAECgQJBgAAAA==.',
['醴甘']='醴甘指凉:BAAALgADCgEJAQAAAA==.醴甘指涼:BAAALgADCgEJAQAAAA==.',
['野火']='野火流云:BAAALgAFFAIJAwAAAA==.',
['鏡花']='鏡花水月:BAAALgAECgEJAQAAAA==.',
['银河']='银河修理员:BAABLgAECn8bAAIBAAcJjhJ3hQDHAQABAAcJjhJ3hQDHAQAAAA==.',
['镜流']='镜流:BAACLgAFFH8IAAMJAAMJmyFBEAAuAQAJAAMJjyFBEAAuAQAIAAIJmh5bDgDIAAAuAAQKfyMAAwkACAm3I9cOAMgCAAkABwlHI9cOAMgCAAgABQnWJBkOALUBAAAA.',
['阿古']='阿古路:BAAALgAFFAEJAQAAAA==.',
['阿拼']='阿拼:BAAALgADCgMJAwAAAA==.',
['雅雅']='雅雅宝贝:BAAALgAECgIJAgAAAA==.',
['雨花']='雨花:BAAALgAECgIJBAAAAA==.',
['韓喧']='韓喧茗:BAACLgAFFH8HAAIaAAMJshVmDQAFAQAaAAMJshVmDQAFAQAuAAQKfxsAAxoACAmKGvwRAIYCABoACAmKGvwRAIYCABsAAwmXEEYjAHUAAAAA.',
['韩尛']='韩尛薇:BAAALgAECgUJBwAAAA==.',
['风色']='风色幻想:BAAALgAECgIJAgAAAA==.',
['飞天']='飞天旺财:BAAALgAECgcJAQAAAA==.',
['高启']='高启强:BAAALgAECgEJAQABLgAFFAQJAQAEAAAAAA==.',
['鬼火']='鬼火妖姬:BAAALgAFFAIJBAAAAA==.',
['鱼塘']='鱼塘鱼哆哆:BAAALgAECgQJBAAAAA==.鱼塘鱼多多:BAAALgAFFAEJAQAAAA==.',
['鲁智']='鲁智深丶:BAAALgAFFAIJAgAAAA==.',
['鲁西']='鲁西飞:BAAALgAECgYJCQAAAA==.',
['鳞介']='鳞介:BAAALgADCgEJAQAAAA==.',
['麦麦']='麦麦脆汁鸡:BAAALgAECgkJDgABLgAECgYJBgAEAAAAAA==.',
['黑大']='黑大米:BAAALgAFFAIJAgABLgAFFAIJBAAEAAAAAA==.',
['黑牛']='黑牛肉丸子:BAAALgAECgYJEAAAAA==.',
['黑龙']='黑龙妹妹:BAAALgAECgEJAgAAAA==.',
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
