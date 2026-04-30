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

local lookup = {'DeathKnight-Unholy','Monk-Windwalker','Priest-Discipline','DemonHunter-Devourer','DemonHunter-Havoc','Unknown-Unknown','Hunter-Marksmanship','Hunter-Survival','Warrior-Protection','Priest-Holy','Warrior-Fury','Warrior-Arms','Mage-Frost','Paladin-Holy','Paladin-Retribution','Warlock-Demonology','Druid-Restoration','Evoker-Preservation','Priest-Shadow','Shaman-Restoration','Rogue-Assassination','Rogue-Subtlety','Warlock-Destruction','Shaman-Elemental','Hunter-BeastMastery','Monk-Mistweaver','Monk-Brewmaster','Warlock-Affliction','DeathKnight-Blood',}
local provider = {region='CN',realm='斩魔者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ah='Ahfreshmeat:BAAALgAECggJEAAAAA==.',
Al='Almaty:BAAALgADCgIJAgAAAA==.Alphonse:BAAALgAECgQJBAAAAA==.',
Ca='Camellia:BAAALgAECgYJDgAAAA==.',
Co='Constantine:BAAALgAECggJDgAAAA==.Converter:BAAALgAECgcJBgABLgAFFAYJCgABAM8MAA==.',
Do='Doubleliu:BAAALgAECggJDQAAAA==.',
Ev='Evelyn:BAAALgAECgEJAQAAAA==.Evemomaek:BAAALgAECgYJDAAAAA==.',
Fo='Foco:BAAALgAECgQJBgAAAA==.',
Gs='Gsh:BAAALgADCgQJBAAAAA==.',
Ha='Haris:BAAALgAECgcJCQAAAA==.',
Ic='Icememory:BAAALgAECgEJAQAAAA==.',
Ke='Keroro:BAAALgAECgcJBwAAAA==.',
Ki='Kiro:BAAALgAECgMJAwAAAA==.',
Ko='Komit:BAAALgADCgIJAgAAAA==.',
Ku='Kuro:BAAALgAECgYJBwAAAA==.',
La='Lalatina:BAAALgAECgEJAgAAAA==.',
Ls='Lsland:BAAALgAECgYJBgAAAA==.',
Mi='Mikeyang:BAAALgAECgQJBQAAAA==.',
Na='Natsuki:BAAALgADCgcJBwAAAA==.',
Ne='Nestone:BAAALgAECgQJBAAAAA==.',
Ni='Nicola:BAEALgAECgYJBgAAAA==.Nika:BAABLgAFFH8HAAIBAAIJnyBiPwChAAABAAIJnyBiPwChAAAAAA==.Nines:BAAALgAECgcJEAAAAA==.',
On='Onlyloveless:BAAALgAECgEJAQAAAA==.',
Pa='Pandaman:BAAALgAECgEJAQAAAA==.',
Pl='Playerwpxbob:BAAALgAECgMJAwAAAA==.',
Ry='Ryosuke:BAABLgAFFH8GAAICAAQJ6gPPBwD5AAACAAQJ6gPPBwD5AAAAAA==.',
Se='Seeyou:BAAALgAECgUJBQAAAA==.',
Si='Simpuff:BAABLgAFFH8FAAIDAAMJhQ9GDgDoAAADAAMJhQ9GDgDoAAAAAA==.',
Vo='Voodooshades:BAEALgAECgcJDgAAAA==.',
Xe='Xeon:BAABLgAECn8UAAMEAAgJORA0SQDPAQAEAAcJ7RI0SQDPAQAFAAcJAAAAAAAAAAABLgAFFAUJAgAGAAAAAA==.',
['一心']='一心向善:BAAALgAFFAEJAQAAAA==.',
['一粒']='一粒丹:BAAALgADCgIJAgAAAA==.',
['三百']='三百马格南:BAAALgAECgEJAwAAAA==.',
['不是']='不是随意:BAABLgAFFH8HAAMHAAMJHB+IEgASAQAHAAMJHB+IEgASAQAIAAIJTRV8BAC9AAAAAA==.',
['丘比']='丘比特之哀伤:BAAALgAECgEJAQAAAA==.丘比特的圈套:BAAALgAECgYJCAAAAA==.',
['丨古']='丨古月三少丨:BAAALgAECgYJAwABLgAFFAcJDQAJAM4ZAA==.',
['中野']='中野一花丶:BAAALgADCgEJAQAAAA==.',
['丰胸']='丰胸肾手:BAAALgAECgUJCQAAAA==.',
['丶一']='丶一诺:BAAALgAECgcJDQAAAA==.',
['为了']='为了女孩子:BAAALgAECgEJAQAAAA==.',
['丿枫']='丿枫丶芙爱:BAAALgAECgUJBwAAAA==.',
['丿血']='丿血色丶蔷薇:BAAALgAECgMJAwAAAA==.',
['乌丑']='乌丑:BAAALgADCgQJBgAAAA==.',
['九字']='九字兼定:BAAALgAECgYJEgAAAA==.',
['二两']='二两汾酒:BAAALgAFFAEJAQAAAA==.二两竹叶青:BAAALgAECgkJCQAAAA==.',
['云霄']='云霄:BAAALgAECgYJCAAAAA==.',
['亞蔑']='亞蔑蝶:BAABLgAFFH8KAAIKAAQJchHUAgATAQAKAAQJchHUAgATAQAAAA==.',
['人民']='人民群众:BAABLgAECn8ZAAQLAAYJhA1bYgAoAQALAAUJ+w5bYgAoAQAJAAMJBQQxPQBjAAAMAAEJaA09RQAuAAAAAA==.',
['伊尔']='伊尔迷:BAABLgAFFH8NAAINAAUJlRqNIgAyAQANAAUJlRqNIgAyAQAAAA==.',
['伯乐']='伯乐:BAAALgAECgIJBQAAAA==.',
['低调']='低调的连她:BAAALgAFFAIJAgAAAA==.',
['你妹']='你妹夫:BAAALgAECgYJDgAAAA==.',
['偌水']='偌水琉璃:BAAALgADCgEJAQAAAA==.',
['傅菁']='傅菁:BAAALgADCgIJAgAAAA==.',
['傺魂']='傺魂:BAAALgAECgYJCwAAAA==.',
['元寳']='元寳:BAAALgAECgcJBwAAAA==.',
['先赞']='先赞后揍:BAAALgAECgMJAwAAAA==.',
['克里']='克里斯丁:BAACLgAFFH8FAAIOAAMJhgFvEgC3AAAOAAMJhgFvEgC3AAAuAAQKfxoAAg4ACAmYDDE1AKgBAA4ACAmYDDE1AKgBAAAA.',
['其实']='其实我很靓:BAAALgAECgIJBAAAAA==.',
['农夫']='农夫三拳丨痛:BAAALgAFFAMJBAAAAA==.农夫散拳:BAAALgAECgYJBgAAAA==.',
['冬刺']='冬刺骨春繁华:BAABLgAFFH8HAAIPAAQJ6B6tBgCEAQAPAAQJ6B6tBgCEAQABLgAFFAYJEwAPAMggAA==.',
['冰火']='冰火绝恋:BAAALgAECgYJEQAAAA==.',
['冰镇']='冰镇萝莉子:BAAALgAECgMJBgAAAA==.',
['冷血']='冷血凝刃:BAAALgAECgEJAQAAAA==.',
['凪诚']='凪诚士郎:BAAALgAECgYJBgAAAA==.',
['凯伦']='凯伦:BAAALgADCgMJBAAAAA==.',
['凶喵']='凶喵:BAAALgAECgYJBgAAAA==.',
['刀景']='刀景:BAAALgADCgEJAQAAAA==.',
['剑來']='剑來:BAAALgAECgYJBgAAAA==.',
['剑倾']='剑倾雪:BAAALgAFFAEJAQAAAA==.',
['剑来']='剑来丶张山峰:BAAALgAECgMJBAAAAA==.剑来丶黄三甲:BAAALgAECgUJCgAAAA==.',
['千千']='千千结:BAAALgAECgYJDQAAAA==.',
['千愿']='千愿溯辉:BAABLgAFFH8JAAIQAAUJ0RanBQBeAQAQAAUJ0RanBQBeAQAAAA==.',
['卫宫']='卫宫切嗣:BAAALgAECgEJAQAAAA==.',
['卫无']='卫无风:BAAALgAECgQJBAAAAA==.',
['印第']='印第安纳白菜:BAAALgAECgYJDAAAAA==.',
['去冰']='去冰谢谢:BAAALgADCgMJAwAAAA==.',
['古二']='古二:BAAALgAFFAEJAQAAAA==.',
['古尔']='古尔蛋龙:BAAALgAECgYJCQAAAA==.',
['叶惠']='叶惠美:BAAALgAECgEJAgAAAA==.',
['吒查']='吒查查:BAABLgAECn8VAAINAAcJ3xKUiQC/AQANAAcJ3xKUiQC/AQAAAA==.',
['呀买']='呀买呆:BAAALgAECgEJAQAAAA==.',
['呱丶']='呱丶呱:BAAALgAFFAIJBAAAAA==.',
['和谐']='和谐福娃:BAAALgAECgQJBgAAAA==.',
['哈基']='哈基米曼波:BAAALgAFFAMJAwAAAA==.',
['哦麦']='哦麦泪滴嘎嘎:BAAALgAECgEJAQAAAA==.',
['哲与']='哲与诗:BAAALgAECgYJEAAAAA==.',
['唐門']='唐門:BAAALgAECgQJCAAAAA==.',
['啮人']='啮人:BAAALgADCgYJCgAAAA==.',
['喜爱']='喜爱大保健:BAAALgAECgkJCQAAAA==.',
['喵猫']='喵猫躲:BAAALgAECgYJBwAAAA==.',
['圣光']='圣光味牛肉干:BAAALgAECgIJAgAAAA==.圣光小绿豆:BAACLgAFFH8GAAIOAAIJaRCCFQCVAAAOAAIJaRCCFQCVAAAuAAQKfxkAAg4ABgkQHWInAO8BAA4ABgkQHWInAO8BAAAA.',
['圣哈']='圣哈哈:BAACLgAFFH8GAAIPAAMJJg8uKQCTAAAPAAMJJg8uKQCTAAAuAAQKfyIAAw8ACAmRFWpdAMsBAA8ABwnZF2pdAMsBAA4ACAm+C0Y7AIwBAAAA.',
['墨香']='墨香染流年:BAAALgAFFAQJBAAAAA==.',
['夕揽']='夕揽乂昔愁:BAAALgAECgQJBAAAAA==.',
['多巴']='多巴胺:BAAALgAECgYJDAAAAA==.',
['大湾']='大湾仔:BAAALgAECgYJBgAAAA==.',
['大花']='大花花:BAAALgAECgEJAgAAAA==.',
['大饼']='大饼:BAAALgAFFAIJAgAAAA==.',
['大驚']='大驚小怪:BAAALgAECgEJAgAAAA==.',
['天然']='天然气女友:BAAALgAECgUJBQAAAA==.',
['天罡']='天罡北狐:BAAALgAECgEJAQAAAA==.天罡暗狐:BAABLgAFFH8FAAIQAAUJJwBaQQBsAAAQAAUJJwBaQQBsAAAAAA==.',
['奈何']='奈何黄粱一梦:BAAALgAECgQJBAAAAA==.',
['奈奈']='奈奈有个熊:BAAALgADCgIJAgAAAA==.',
['奈萨']='奈萨里奥:BAAALgAFFAEJAQAAAA==.',
['女孩']='女孩子喜欢我:BAAALgAFFAEJAQAAAA==.',
['好心']='好心女孩子:BAAALgAECgUJBwAAAA==.',
['如果']='如果你不在:BAABLgAFFH8GAAIOAAMJOBgnBwDTAAAOAAMJOBgnBwDTAAAAAA==.',
['婵羽']='婵羽:BAAALgAECgIJAgAAAA==.',
['孤烟']='孤烟:BAAALgAECggJDwAAAA==.',
['宝屁']='宝屁龙:BAAALgADCgcJBwAAAA==.',
['宫乐']='宫乐:BAAALgAFFAIJAgAAAA==.',
['小妖']='小妖妖娆娆:BAABLgAECn8cAAIRAAgJSRNFOQDBAQARAAgJSRNFOQDBAQAAAA==.',
['小小']='小小法强:BAACLgAFFH8OAAINAAUJ3Q/6DQCqAQANAAUJ3Q/6DQCqAQAuAAQKfy8AAg0ACQklIPIQAEIDAA0ACQklIPIQAEIDAAAA.',
['小当']='小当僧:BAAALgAECgYJBgAAAA==.',
['小蓝']='小蓝龙:BAABLgAFFH8JAAISAAQJpxbmAwA9AQASAAQJpxbmAwA9AQAAAA==.',
['小钢']='小钢炮架起来:BAAALgADCgEJAQAAAA==.',
['少女']='少女作妖记:BAAALgAECgQJBAAAAA==.',
['就爱']='就爱席胸:BAAALgADCgYJCgAAAA==.',
['尼姑']='尼姑丁:BAAALgAFFAEJAgAAAA==.',
['岳下']='岳下噬魔:BAAALgAECgcJDQAAAA==.',
['岳绮']='岳绮罗:BAAALgADCgEJAQAAAA==.',
['巧儿']='巧儿:BAAALgAECgEJAQAAAA==.',
['布灬']='布灬娃娃:BAAALgAECggJCAAAAA==.',
['希雅']='希雅:BAAALgAFFAQJBAAAAA==.',
['帝凯']='帝凯:BAABLgAFFH8GAAIBAAIJDAsJRQCZAAABAAIJDAsJRQCZAAAAAA==.',
['幻夜']='幻夜微光:BAABLgAFFH8FAAIQAAQJ0BFfNQCoAAAQAAQJ0BFfNQCoAAAAAA==.',
['幻梦']='幻梦丶唯殇:BAABLgAFFH8LAAIQAAUJaRJVEwBOAQAQAAUJaRJVEwBOAQAAAA==.',
['幽冥']='幽冥暗殇:BAAALgAECgIJAwAAAA==.',
['幽暗']='幽暗圣灵:BAACLgAFFH8SAAIKAAUJHhz5AADUAQAKAAUJHhz5AADUAQAuAAQKfxwABAoACAnjHt4IAL4CAAoACAnjHt4IAL4CAAMABAkJCNM+ALcAABMAAgkqAdFhADQAAAAA.',
['幽莲']='幽莲:BAABLgAFFH8IAAIQAAQJJxtTDgBqAQAQAAQJJxtTDgBqAQAAAA==.',
['庄生']='庄生迷蝶:BAAALgAECgEJAQAAAA==.',
['应采']='应采儿:BAAALgAECgcJDAAAAA==.',
['张小']='张小斐:BAAALgAECgIJAgAAAA==.',
['弥诺']='弥诺陶若斯:BAAALgAECgcJAwAAAA==.',
['强尼']='强尼:BAAALgAECgYJDAAAAA==.',
['徐子']='徐子凡:BAAALgADCgUJBQAAAA==.',
['心善']='心善女孩子:BAAALgAECgUJBQAAAA==.',
['忆中']='忆中人:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁的泪:BAAALgAECgQJCAAAAA==.',
['惟余']='惟余:BAAALgADCgEJAQAAAA==.',
['慕容']='慕容小童:BAAALgAFFAQJBAABLgAFFAUJCQAUAHoNAA==.慕容紫萱:BAAALgAFFAQJBAAAAA==.',
['我不']='我不是神德:BAAALgAECgcJCQAAAA==.',
['我喜']='我喜欢女孩子:BAAALgAECgIJAwAAAA==.',
['我好']='我好想你:BAAALgAECgEJAQAAAA==.',
['抖腿']='抖腿的贵妇:BAAALgAECgYJBgAAAA==.',
['折月']='折月丨煮酒:BAAALgAECgEJAQAAAA==.',
['指尖']='指尖流年:BAABLgAFFH8KAAIQAAQJoRJTBgBWAQAQAAQJoRJTBgBWAQAAAA==.',
['挽歌']='挽歌之殇:BAAALgAFFAEJAQAAAA==.',
['搞七']='搞七撵三:BAABLgAECn8nAAIBAAgJnyCNEwAGAwABAAgJnyCNEwAGAwAAAA==.',
['撒旦']='撒旦的微笑:BAAALgAFFAIJAwAAAA==.',
['放开']='放开那只小喵:BAAALgADCgIJAgAAAA==.',
['斩尽']='斩尽红尘:BAAALgAECgcJBwAAAA==.',
['斩意']='斩意乄:BAAALgAECgEJAQAAAA==.',
['断桥']='断桥残雪:BAAALgAECgcJCQAAAA==.',
['斯文']='斯文败类丨:BAAALgAECgEJAQAAAA==.',
['新星']='新星的鑫心:BAAALgADCgkJCQAAAA==.',
['时尚']='时尚小子:BAACLgAFFH8HAAMVAAMJFhzzAQA2AQAVAAMJFhzzAQA2AQAWAAEJAwu0GQBWAAAuAAQKfxkAAxYACAnvG8cPAKkCABYACAmEG8cPAKkCABUABgn5GmwGABACAAAA.',
['星炫']='星炫:BAACLgAFFH8JAAMQAAQJixQpEgBUAQAQAAQJixQpEgBUAQAXAAEJ0wOnGQBJAAAuAAQKfxQAAxcABwk9HOkQAMYBABAABwksHEdBAAkCABcABwk+GOkQAMYBAAAA.',
['星痕']='星痕予墨:BAAALgAECgQJBAAAAA==.',
['昨日']='昨日艾露温:BAAALgAECgYJCAAAAA==.',
['晨曦']='晨曦的回忆:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经在飞:BAAALgAECgcJDQAAAA==.',
['最无']='最无情的月相:BAAALgAECgEJAwAAAA==.',
['月之']='月之小德:BAAALgADCgQJBAAAAA==.',
['月夜']='月夜舞:BAAALgAECgIJAgAAAA==.',
['月灯']='月灯:BAACLgAFFH8HAAIQAAUJVhVsBQBgAQAQAAUJVhVsBQBgAQAuAAQKfxUAAxAACQnuE/IuAFECABAACQnuE/IuAFECABcAAQkAACx2AC4AAAAA.',
['有点']='有点尴尬:BAAALgAECgQJBAAAAA==.',
['朕略']='朕略萌:BAAALgADCgEJAQAAAA==.',
['木兮']='木兮:BAAALgAFFAEJAQAAAA==.',
['李不']='李不高兴:BAAALgAECgEJAQAAAA==.',
['李盼']='李盼盼:BAAALgAECgQJBgAAAA==.',
['杨永']='杨永信:BAAALgAFFAIJAwAAAA==.',
['林红']='林红别匆匆:BAAALgADCgUJBAAAAA==.',
['林野']='林野:BAAALgAECgMJAwAAAA==.',
['柒非']='柒非非:BAAALgAECgEJAQAAAA==.',
['桂花']='桂花酒:BAAALgAECgMJAwAAAA==.',
['桐寶']='桐寶:BAAALgADCgYJBgAAAA==.',
['梅塔']='梅塔斯:BAAALgAECgMJAwAAAA==.',
['梦漓']='梦漓城:BAAALgAECgEJAQAAAA==.',
['梦颜']='梦颜:BAAALgAFFAMJAwAAAA==.',
['棉花']='棉花糖嘟嘟:BAAALgAECgMJAwAAAA==.',
['正义']='正义之丘比特:BAAALgAECgYJCAABLgAFFAYJDgAMANUkAA==.',
['死了']='死了还会活:BAAALgAECgEJAgAAAA==.',
['水不']='水不水看怪:BAAALgAECgIJAgAAAA==.',
['水月']='水月之舞:BAAALgAFFAUJAgAAAA==.',
['水汐']='水汐:BAAALgAECgYJCAAAAA==.',
['汐之']='汐之卡米:BAAALgAFFAEJAQAAAA==.',
['江户']='江户川乱步:BAAALgAECgMJAQAAAA==.',
['江湖']='江湖术士:BAABLgAECn8UAAMQAAcJnRchGgBEAQAQAAcJQhchGgBEAQAXAAIJ1xWLSACVAAAAAA==.',
['汽车']='汽车:BAAALgAECgIJAgAAAA==.',
['法外']='法外不留情:BAAALgAECgYJCAAAAA==.',
['法小']='法小啡:BAAALgADCgEJAwAAAA==.',
['法维']='法维安:BAAALgAECgYJCgAAAA==.',
['泽村']='泽村英梨梨:BAAALgAFFAEJAQAAAA==.',
['洛水']='洛水天依:BAAALgAECgYJBgAAAA==.',
['济世']='济世狂魔:BAAALgAECgEJAQAAAA==.',
['浪子']='浪子阿三:BAAALgADCgIJAgAAAA==.',
['浪飞']='浪飞冲天:BAAALgAECgEJAQAAAA==.',
['海德']='海德悠二:BAAALgAECgMJAwAAAA==.',
['溪城']='溪城小咕:BAAALgADCgEJAQAAAA==.',
['漫夜']='漫夜灯语:BAABLgAFFH8PAAIQAAUJCxosBQBjAQAQAAUJCxosBQBjAQAAAA==.',
['灬笙']='灬笙语灬:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂洄游:BAABLgAFFH8GAAIQAAQJohLaEgBRAQAQAAQJohLaEgBRAQAAAA==.',
['炊烟']='炊烟醉清风:BAAALgADCgEJAQAAAA==.',
['然然']='然然:BAABLgAFFH8FAAIYAAQJ7g5xAwA7AQAYAAQJ7g5xAwA7AQABLgAFFAQJBgATAAcWAA==.',
['煜兔']='煜兔儿:BAAALgADCgQJBAAAAA==.',
['煭熖']='煭熖:BAAALgAECgEJAQAAAA==.',
['燎原']='燎原:BAAALgAECgIJAgAAAA==.',
['燎野']='燎野:BAAALgAECgQJBAAAAA==.',
['燕囡']='燕囡:BAAALgAECgIJAgAAAA==.',
['爆炸']='爆炸天团:BAAALgAECggJCAAAAA==.',
['爱吃']='爱吃小雪的魂:BAACLgAFFH8IAAMTAAMJnhVrDQDEAAATAAIJPiBrDQDEAAADAAMJEwIOEQC3AAAuAAQKfykAAxMACAnNHFAOAJ4CABMACAnNHFAOAJ4CAAMACAmQGNIBAGkCAAAA.爱吃水果:BAABLgAFFH8FAAMZAAMJ8BCTCwAGAQAZAAMJ8BCTCwAGAQAHAAEJYAAULgAzAAAAAA==.',
['爱心']='爱心女孩子:BAAALgAECgQJBAAAAA==.',
['牛不']='牛不白吖:BAAALgADCgQJBAAAAA==.',
['牛盾']='牛盾:BAAALgADCgIJAgAAAA==.',
['牦牛']='牦牛奔驰:BAABLgAFFH8FAAIaAAIJ7g8CEwCAAAAaAAIJ7g8CEwCAAAAAAA==.',
['犭畏']='犭畏锁小萨:BAAALgAFFAIJAwABLgAFFAIJAgAGAAAAAA==.',
['狂怒']='狂怒审判:BAAALgAECgEJAQAAAA==.',
['狐假']='狐假虎威:BAAALgAFFAQJBAAAAA==.',
['王千']='王千翼:BAACLgAFFH8GAAIbAAMJ7wlSCQDMAAAbAAMJ7wlSCQDMAAAuAAQKfxcAAhsACAmOEI4pALwBABsACAmOEI4pALwBAAAA.',
['琥珀']='琥珀月色:BAAALgAECgUJBwAAAA==.',
['璞鈺']='璞鈺:BAAALgAECgcJCwAAAA==.',
['男人']='男人玩哲学:BAAALgADCgEJAQAAAA==.',
['留下']='留下伱过夜:BAAALgAECgMJBQAAAA==.',
['番茄']='番茄泥鳅:BAAALgAECgMJBQAAAA==.',
['番荔']='番荔枝:BAAALgAECgkJCwABLgAFFAQJBwASAGwSAA==.',
['痛毁']='痛毁恶魔:BAABLgAECn8VAAQcAAcJww3qDABnAQAcAAYJYgzqDABnAQAQAAcJ+wt7fgBeAQAXAAYJywjILAALAQAAAA==.',
['白发']='白发绿皮:BAAALgADCgEJAQAAAA==.',
['白流']='白流苏:BAAALgAFFAIJAwABLgAFFAcJFgAbAGsTAA==.',
['百事']='百事可乐加冰:BAAALgAECgMJAwAAAA==.',
['皮卡']='皮卡啾鸭:BAAALgAECgMJAwAAAA==.',
['眀日']='眀日香:BAAALgAECgYJDwAAAA==.',
['真冬']='真冬酱:BAAALgAECgQJBgABLgAFFAQJBAAGAAAAAA==.',
['砸妮']='砸妮家玻璃:BAAALgAECgYJBgAAAA==.',
['神之']='神之圣骑:BAAALgAECgEJAQAAAA==.',
['秋水']='秋水:BAAALgAECgEJAQAAAA==.',
['积碳']='积碳糕:BAAALgADCgEJAQAAAA==.',
['突然']='突然灬烦恼:BAAALgAECgYJBgAAAA==.',
['窜天']='窜天雷:BAAALgAECgMJAwABLgAFFAIJAgAGAAAAAA==.',
['繁之']='繁之语:BAAALgAECgYJCAAAAA==.',
['纠结']='纠结丶星辰:BAAALgADCgUJBQAAAA==.',
['纳木']='纳木措:BAAALgAECgQJBAAAAA==.',
['绝霸']='绝霸:BAAALgAECgUJBQAAAA==.',
['绿皮']='绿皮小怪兽:BAAALgADCgQJBAAAAA==.',
['缘缘']='缘缘长相念:BAABLgAFFH8IAAIQAAQJKxrpDwBhAQAQAAQJKxrpDwBhAQAAAA==.',
['罗天']='罗天大醮:BAAALgAECgQJCgAAAA==.',
['羽衣']='羽衣甘蓝:BAAALgAECgUJDgAAAA==.',
['老子']='老子酒中仙:BAAALgADCgMJBAAAAA==.',
['老钟']='老钟采花:BAAALgAECgEJAQAAAA==.老钟采蜜:BAAALgAFFAIJBAAAAA==.',
['肯定']='肯定是很好:BAAALgADCgUJBQAAAA==.',
['胖肚']='胖肚皮:BAAALgAFFAEJAQAAAA==.',
['腥风']='腥风血雨靠:BAAALgAECgYJBgAAAA==.',
['艾斯']='艾斯迪凯:BAAALgAECgEJAQAAAA==.',
['艾萨']='艾萨克尼特罗:BAABLgAFFH8GAAMMAAMJMw2vBgCpAAALAAMJbQW+EwDhAAAMAAIJkhGvBgCpAAAAAA==.',
['芙兰']='芙兰莎:BAAALgAECgIJAgAAAA==.',
['花怨']='花怨秋:BAAALgAECgcJDgAAAA==.',
['花颜']='花颜醉:BAAALgAECgQJBQAAAA==.',
['苏樱']='苏樱:BAAALgAECgEJAQAAAA==.',
['荒漠']='荒漠虚空:BAAALgAFFAIJAgAAAA==.荒漠龙息:BAAALgAECgYJCAAAAA==.',
['莫安']='莫安娜:BAAALgAECgYJCgAAAA==.',
['莫黎']='莫黎:BAAALgAECgcJBwAAAA==.',
['菇妖']='菇妖王:BAAALgAECgEJAQAAAA==.',
['菜小']='菜小蜓:BAAALgAECgYJBgAAAA==.',
['萨克']='萨克拉:BAAALgADCgQJBAAAAA==.',
['萨蛮']='萨蛮丶:BAAALgAECgUJCQAAAA==.',
['葡萄']='葡萄吃苹果:BAAALgAFFAEJAQAAAA==.',
['螭吻']='螭吻:BAAALgAECgQJBAAAAA==.',
['被遺']='被遺棄的笨笨:BAAALgADCgYJBgAAAA==.',
['裸身']='裸身男主播五:BAAALgAECgYJBgAAAA==.',
['诃德']='诃德佛拉明戈:BAAALgAECgEJAQAAAA==.',
['诺娴']='诺娴:BAAALgAECgcJBwAAAA==.',
['诺心']='诺心:BAAALgAECgYJAwABLgAFFAIJAgAGAAAAAA==.',
['诺情']='诺情:BAAALgAECgUJBQAAAA==.',
['诺玥']='诺玥:BAAALgAECgYJBgAAAA==.',
['诺言']='诺言:BAAALgAECgcJBgAAAA==.',
['谛听']='谛听:BAAALgAECggJCwAAAA==.',
['豆豆']='豆豆的骑士:BAAALgAFFAEJAQAAAA==.',
['趙思']='趙思琪:BAAALgAECgYJBgAAAA==.',
['跳起']='跳起来踢你蛋:BAABLgAFFH8FAAIbAAMJPgm5FQDHAAAbAAMJPgm5FQDHAAAAAA==.',
['跳跳']='跳跳蛙:BAAALgAECgQJBAAAAA==.',
['过山']='过山风:BAAALgADCgYJBgAAAA==.',
['这都']='这都奶不住你:BAAALgAECgEJAQAAAA==.',
['道友']='道友留步:BAAALgAECgEJAQAAAA==.',
['道夫']='道夫:BAAALgAFFAMJAwAAAA==.',
['遗忘']='遗忘神泣:BAAALgAECgkJDwAAAA==.',
['那夜']='那夜太寂寞:BAACLgAFFH8MAAIPAAQJNxsEAgB8AQAPAAQJNxsEAgB8AQAuAAQKfyIAAg8ACAntI2gLADMDAA8ACAntI2gLADMDAAAA.那夜太纪墨:BAABLgAFFH8HAAIQAAMJow+iIgD5AAAQAAMJow+iIgD5AAAAAA==.',
['酷呆']='酷呆法夜:BAAALgADCgEJAQAAAA==.',
['開襠']='開襠少帥:BAAALgAFFAIJAwAAAA==.',
['间影']='间影呛咚呛:BAACLgAFFH8HAAIKAAMJER4PBgAeAQAKAAMJER4PBgAeAQAuAAQKfxUAAgoABwlYGA8cAPwBAAoABwlYGA8cAPwBAAAA.',
['闻人']='闻人语:BAAALgAECgIJAgAAAA==.',
['队长']='队长五百斤:BAAALgAECgEJAwAAAA==.',
['阿克']='阿克琉斯:BAAALgAECgQJBQAAAA==.',
['阿努']='阿努比斯杰:BAAALgAECgcJCQAAAA==.',
['阿尔']='阿尔萨四:BAAALgAECgYJDwAAAA==.',
['阿耀']='阿耀:BAACLgAFFH8OAAIdAAUJyBvjAQDLAQAdAAUJyBvjAQDLAQAuAAQKfxoAAh0ACQkpHwkEABEDAB0ACQkpHwkEABEDAAAA.',
['雪贝']='雪贝儿:BAAALgAECgEJAQAAAA==.',
['雪走']='雪走:BAAALgADCgEJAQAAAA==.',
['零千']='零千魂:BAAALgAECgUJBQAAAA==.',
['雷二']='雷二:BAAALgAECgcJEgAAAA==.',
['雷萨']='雷萨特:BAAALgAFFAIJAgAAAA==.',
['霜晓']='霜晓寒姿:BAACLgAFFH8FAAMLAAMJRgq3EgDvAAALAAMJRgq3EgDvAAAJAAEJQArsDwBFAAAuAAQKfxwABAsACAl6GX0uAPcBAAsABwlZGn0uAPcBAAkABwmAE9kXAJgBAAwAAQk4DAAAAAAAAAAA.',
['顶呱']='顶呱瓜:BAAALgADCgYJBgAAAA==.',
['风尘']='风尘细雨:BAABLgAFFH8GAAIOAAIJmBlzFACdAAAOAAIJmBlzFACdAAAAAA==.',
['风潇']='风潇声动:BAABLgAECn8UAAIPAAgJCR/TIgCeAgAPAAgJCR/TIgCeAgAAAA==.',
['风玲']='风玲珑:BAAALgAECgYJCgAAAA==.',
['风缘']='风缘:BAAALgAECgcJBQAAAA==.',
['风飒']='风飒飒:BAAALgAECgYJCwAAAA==.',
['飘逸']='飘逸丶人生:BAAALgAECgcJBwAAAA==.',
['飞天']='飞天僵尸:BAAALgADCgYJCgAAAA==.',
['香酥']='香酥小红手:BAAALgADCgUJBQAAAA==.',
['騒气']='騒气蓬勃:BAAALgADCgEJAQAAAA==.',
['马努']='马努鲁鲁:BAAALgADCgMJAwAAAA==.',
['马褂']='马褂不要了:BAAALgAECgIJAgAAAA==.',
['鬼呀']='鬼呀:BAAALgAECgIJAgAAAA==.',
['鸢一']='鸢一折纸丶:BAAALgAECgQJBAAAAA==.',
['麝香']='麝香弥漫:BAAALgAECgIJAgAAAA==.',
['黄豆']='黄豆豆:BAABLgAFFH8FAAIOAAIJewbhFwCGAAAOAAIJewbhFwCGAAAAAA==.',
['黑天']='黑天鹅:BAABLgAFFH8HAAIQAAMJQw03NgCnAAAQAAMJQw03NgCnAAAAAA==.',
['黑牛']='黑牛还是牛:BAAALgAECgYJCgAAAA==.',
['黑虎']='黑虎虾:BAABLgAFFH8FAAIaAAIJtRdWDwClAAAaAAIJtRdWDwClAAAAAA==.',
['龙傲']='龙傲天:BAABLgAECn8VAAMbAAgJYh2vHgAMAgAbAAcJFSGvHgAMAgAaAAgJkA6BBgCmAQAAAA==.',
['龙隐']='龙隐云墨间:BAAALgAFFAQJBAAAAA==.',
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
