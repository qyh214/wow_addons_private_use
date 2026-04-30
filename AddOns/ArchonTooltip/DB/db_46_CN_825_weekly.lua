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

local lookup = {'DeathKnight-Unholy','Mage-Frost','Rogue-Subtlety','DeathKnight-Blood','Paladin-Protection','Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Evoker-Augmentation','Evoker-Preservation','Druid-Restoration','DeathKnight-Frost','Priest-Shadow','Warlock-Demonology','Warrior-Protection','Unknown-Unknown','Warrior-Fury','Priest-Holy','Monk-Brewmaster','Monk-Mistweaver','Monk-Windwalker','Shaman-Restoration','Shaman-Elemental','Evoker-Devastation','Paladin-Holy','Hunter-Survival','Priest-Discipline','Shaman-Enhancement','Warlock-Destruction','Druid-Guardian',}
local provider = {region='CN',realm='血羽',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aelex:BAAALgAECgIJAgAAAA==.',
Ar='Ardenrena:BAAALgAECgcJDgAAAA==.',
Bb='Bbudk:BAABLgAFFH8GAAIBAAQJChy2DwBiAQABAAQJChy2DwBiAQAAAA==.Bbuqs:BAAALgAECgMJAwAAAA==.',
Bs='Bshadow:BAABLgAECn8XAAICAAcJwhSycwDrAQACAAcJwhSycwDrAQAAAA==.',
Bu='Buobunetwo:BAAALgAECgMJAwAAAA==.',
Di='Diso:BAAALgAECgcJBgAAAA==.',
Gr='Grubby:BAAALgAECgMJAwAAAA==.',
Jo='Joshua:BAAALgAECgMJAwAAAA==.',
Ka='Katsumi:BAAALgAFFAEJAQABLgAFFAQJCAADAFoZAA==.',
La='Laodager:BAAALgAFFAQJBAAAAA==.',
Lz='Lzblood:BAACLgAFFH8JAAIEAAIJnAMcEwBaAAAEAAIJnAMcEwBaAAAuAAQKfxUAAgQABwmLFEUcAGoBAAQABwmLFEUcAGoBAAAA.Lzpink:BAACLgAFFH8FAAIFAAIJLwzfBQBkAAAFAAIJLwzfBQBkAAAuAAQKfxQAAwUACAnOCokbADEBAAUACAnOCokbADEBAAYAAQlfAHRhARYAAAAA.',
Ma='Martin:BAAALgAECgIJAwAAAA==.',
Me='Metalstorm:BAAALgAECgEJAQAAAA==.',
Mi='Mizuki:BAACLgAFFH8HAAMHAAQJSRPJAgBhAQAHAAQJSRPJAgBhAQAIAAEJxQVDJwBIAAAuAAQKfxUAAgcABwnJI7kJAMYCAAcABwnJI7kJAMYCAAAA.',
Mo='Mourning:BAABLgAFFH8GAAMJAAMJPQ5KDAAAAQAJAAMJPQ5KDAAAAQAKAAEJJQFiLABBAAABLgAFFAQJCAADAFoZAA==.',
Oe='Oeoe:BAAALgADCgEJAQAAAA==.',
Pi='Piag:BAAALgAFFAEJAQAAAA==.',
Ro='Rootone:BAAALgAECgYJCgAAAA==.',
Ry='Rye:BAAALgAECgIJAgAAAA==.',
Th='Theforsaken:BAAALgAECgQJBAABLgAFFAMJBwAIAFsiAA==.Therainman:BAAALgAECgIJAgAAAA==.',
Ti='Tieria:BAAALgAECgEJAQAAAA==.',
Wi='Without:BAAALgAECgkJCQAAAA==.',
Xo='Xom:BAABLgAECn8VAAIDAAcJdRwDBADvAQADAAcJdRwDBADvAQAAAA==.',
['一口']='一口龙痰:BAAALgAFFAEJAQAAAA==.',
['一只']='一只青团:BAABLgAECn8WAAMJAAcJoiC7BABNAgAJAAcJoCC7BABNAgAKAAcJZR06HABDAgABLgAFFAUJCgALANMRAA==.',
['一片']='一片小叶子:BAAALgADCgQJBAAAAA==.',
['一顿']='一顿仨馒头:BAACLgAFFH8GAAMMAAMJDAtpEACeAAAMAAIJwQ1pEACeAAANAAIJEBIrEgCdAAAuAAQKfx4AAw0ABwnvIbMHAMICAA0ABwnvIbMHAMICAAwAAQkyIZIhAGEAAAAA.',
['七八']='七八零零:BAABLgAECn8UAAIGAAcJ+hOzGQB9AQAGAAcJ+hOzGQB9AQAAAA==.',
['三去']='三去米青米申:BAAALgAECgEJAQAAAA==.',
['三笠']='三笠丶阿克曼:BAAALgAFFAIJBAABLgAFFAQJCAADAFoZAA==.',
['不羨']='不羨:BAAALgAECgEJAQAAAA==.',
['与浪']='与浪漫单挑:BAAALgAECgQJBAAAAA==.',
['严直']='严直高:BAAALgADCgEJAQAAAA==.',
['丨吟']='丨吟灬天丨:BAAALgAECgUJBQAAAA==.',
['丨猎']='丨猎猎丨:BAAALgAECgEJAQAAAA==.',
['丶甲']='丶甲甲:BAAALgAFFAIJAgAAAA==.',
['为我']='为我花生:BAAALgADCgIJAgAAAA==.',
['丿丶']='丿丶喵喵:BAAALgAECgQJBwAAAA==.',
['九重']='九重小主:BAAALgAECgYJCwAAAA==.',
['也许']='也许可以:BAAALgAECgMJAwAAAA==.',
['二氧']='二氧化硅:BAAALgAECgIJAgAAAA==.',
['二貘']='二貘:BAAALgADCgEJAQAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgcJBgABLgAFFAcJBQAOAMsVAA==.',
['伊利']='伊利丶冰工厂:BAAALgAFFAEJAQAAAA==.',
['伊格']='伊格尼斯:BAAALgAECgkJCQAAAA==.',
['众生']='众生同调奥秘:BAACLgAFFH8QAAQBAAUJmyKxEABeAQABAAQJ+COxEABeAQAEAAMJtR1SBAATAQAPAAEJhRx2BABaAAAuAAQKfxgAAwEACAmlJZ4qAI8CAAEABwmtJZ4qAI8CAA8AAQl4JSASAG8AAAAA.',
['会躺']='会躺尸的萌新:BAAALgAECgIJAgAAAA==.',
['低调']='低调是一种罪:BAAALgAECgUJBQAAAA==.',
['佐岸']='佐岸丨痴情:BAAALgAECgYJEgAAAA==.',
['余烬']='余烬之火:BAAALgADCgEJAQAAAA==.',
['佬子']='佬子是光棍:BAAALgAECgEJAQAAAA==.',
['信我']='信我不超生:BAAALgAECgQJBwAAAA==.',
['元宝']='元宝:BAACLgAFFH8FAAIQAAQJkAZzDADoAAAQAAQJkAZzDADoAAAuAAQKfxUAAhAABwnSD/8nAJkBABAABwnSD/8nAJkBAAAA.',
['兎大']='兎大乖:BAABLgAECn8cAAIGAAcJNxwFFgCXAQAGAAcJNxwFFgCXAQAAAA==.',
['兎小']='兎小乖:BAAALgAECgcJCwAAAA==.',
['八神']='八神嘉儿丶:BAAALgAFFAEJAQAAAA==.',
['六氟']='六氟化硫:BAAALgAECgEJAQAAAA==.',
['冰凝']='冰凝物语:BAAALgAECgcJCwAAAA==.',
['凊杉']='凊杉:BAAALgAECgEJAQAAAA==.',
['凝冰']='凝冰漱玉:BAAALgAECgYJBgAAAA==.',
['凝霜']='凝霜雨:BAAALgAECgYJBgAAAA==.',
['刘春']='刘春的碟:BAAALgAECgQJBAAAAA==.',
['剩界']='剩界王骑:BAAALgADCgYJBgAAAA==.',
['卅栏']='卅栏:BAAALgAECgYJBgAAAA==.',
['午夜']='午夜心碎小熊:BAAALgAECgEJAgAAAA==.',
['发财']='发财树:BAAALgAECgYJBwAAAA==.',
['口笛']='口笛:BAAALgAECggJDQABLgAFFAUJDAARAFYlAA==.',
['古尔']='古尔疍:BAAALgAECgIJAwAAAA==.',
['可爱']='可爱的牛妞:BAAALgADCgUJBQAAAA==.',
['史诗']='史诗级罓白鲸:BAAALgADCgcJBwAAAA==.',
['吼吼']='吼吼:BAAALgADCgYJBgAAAA==.',
['呂布']='呂布:BAAALgAECgQJAwAAAA==.',
['呉朙']='呉朙丨二十一:BAAALgAFFAQJBAAAAA==.',
['呦呦']='呦呦鹿鸣:BAAALgAECgcJCwAAAA==.',
['周末']='周末想钓翘嘴:BAABLgAFFH8FAAISAAMJoAQmCgCqAAASAAMJoAQmCgCqAAAAAA==.',
['哈斯']='哈斯加特:BAAALgAECgUJBAAAAA==.',
['哎呦']='哎呦卧槽:BAAALgAECgYJBgAAAA==.',
['哟哟']='哟哟燚燚:BAAALgAECgcJBgABLgAFFAIJAgATAAAAAA==.',
['啊丶']='啊丶吴先森:BAAALgAECgcJBwAAAA==.',
['喵君']='喵君二号:BAAALgAECgYJDAAAAA==.',
['喵小']='喵小奈:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光强强:BAAALgAECgYJBwAAAA==.圣光扛把子:BAAALgAECgYJBwAAAA==.',
['圣翊']='圣翊:BAAALgAFFAIJAwAAAA==.',
['地表']='地表最强龙虾:BAAALgAECgYJCwAAAA==.',
['埃辛']='埃辛诺斯:BAAALgAECgEJAQAAAA==.',
['堕灬']='堕灬欲:BAAALgAECgYJBwAAAA==.',
['声优']='声优都是怪物:BAAALgAECgYJDwAAAA==.',
['壹粒']='壹粒蛋:BAAALgAECgYJCgAAAA==.',
['大高']='大高个:BAAALgAECgUJBQAAAA==.',
['天丨']='天丨命:BAAALgAECgQJBQAAAA==.',
['天天']='天天变的心烦:BAAALgAECgEJAQAAAA==.天天啃大骨头:BAAALgAECgYJCAAAAA==.',
['天灾']='天灾契约:BAAALgAECgQJBAAAAA==.',
['天王']='天王寺璃奈:BAACLgAFFH8UAAIBAAUJRBrjBACzAQABAAUJRBrjBACzAQAuAAQKfyIAAgEACAmQIjYYAOoCAAEACAmQIjYYAOoCAAAA.',
['天骑']='天骑士:BAAALgAECgcJCAAAAA==.',
['失去']='失去风的筝:BAAALgADCgEJAQAAAA==.',
['奈何']='奈何不能死:BAAALgAFFAEJAQAAAA==.',
['奈斯']='奈斯啊:BAAALgAECggJCAAAAA==.',
['奶制']='奶制造:BAAALgAECgIJAgAAAA==.',
['如虹']='如虹:BAAALgADCgUJBQAAAA==.',
['妖厷']='妖厷墨羽:BAAALgAECgEJAQAAAA==.',
['妖小']='妖小伊:BAAALgADCgEJAQAAAA==.',
['妙脆']='妙脆角:BAAALgAECgEJAwAAAA==.',
['子了']='子了子了:BAAALgAECgcJDAABLgAFFAUJEAACAFIlAA==.',
['孤独']='孤独的猎手:BAAALgADCgkJCAAAAA==.',
['安安']='安安小脑斧:BAAALgADCgYJBgABLgAECggJFwABALYfAA==.',
['安東']='安東尼:BAABLgAFFH8GAAIOAAUJ3w/PAwBvAQAOAAUJ3w/PAwBvAQAAAA==.',
['宋条']='宋条妍:BAAALgAFFAEJAQAAAA==.',
['小依']='小依一:BAAALgAECgEJAgAAAA==.',
['小凌']='小凌丶:BAAALgADCgYJBgAAAA==.',
['小叔']='小叔叔:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊小羊:BAAALgAECgcJBwAAAA==.',
['小猫']='小猫崽:BAAALgAECgcJBwAAAA==.',
['小绿']='小绿人:BAAALgADCgcJBwAAAA==.',
['尤菲']='尤菲如月:BAAALgADCgcJBwAAAA==.',
['就你']='就你叫胖虎:BAAALgAFFAEJAgAAAA==.',
['就玩']='就玩萨满:BAAALgAECgIJAgAAAA==.',
['尸体']='尸体收割机:BAAALgAECgEJAgAAAA==.',
['尹丶']='尹丶末:BAAALgAECgEJAQAAAA==.',
['山海']='山海:BAAALgADCgEJAgAAAA==.',
['巴尔']='巴尔:BAAALgAECgcJCwAAAA==.',
['帅的']='帅的不明显:BAAALgAFFAMJAwAAAA==.',
['师太']='师太我还要:BAAALgAECgYJCAAAAA==.',
['希尔']='希尔瓦叶斯:BAAALgAFFAIJAgAAAA==.',
['希格']='希格露恩:BAAALgAECgYJCwAAAA==.',
['带走']='带走你的灵魂:BAAALgAECgUJBQAAAA==.',
['幸福']='幸福不遥远:BAAALgADCgEJAQAAAA==.',
['幽瞳']='幽瞳蚀月:BAAALgAFFAIJBAAAAA==.',
['序曲']='序曲丶:BAAALgAECgYJBwAAAA==.',
['弔戼']='弔戼:BAABLgAFFH8IAAIUAAQJjhQsAwBbAQAUAAQJjhQsAwBbAQAAAA==.',
['弗洛']='弗洛伊丶德彪:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁花仙子:BAAALgAECgYJCgAAAA==.',
['念念']='念念的猎神:BAAALgAECgcJBwAAAA==.念念的骑士:BAAALgAECgcJBwAAAA==.',
['性感']='性感的小眼睛:BAAALgAECgQJBAAAAA==.',
['恋魂']='恋魂:BAAALgAECgUJBQAAAA==.',
['恍若']='恍若隔世丶:BAABLgAFFH8IAAIVAAQJnA2zBQAoAQAVAAQJnA2zBQAoAQAAAA==.',
['悲剧']='悲剧人物:BAAALgAECgEJAQAAAA==.',
['情义']='情义灬增辉:BAAALgAECgcJDAAAAA==.情义灬猎爹:BAAALgAECgcJDgAAAA==.',
['我懷']='我懷念的:BAACLgAFFH8TAAIWAAYJsgRtBgBsAQAWAAYJsgRtBgBsAQAuAAQKfxUAAhYACAmDB28+AEwBABYACAmDB28+AEwBAAAA.',
['我爸']='我爸刚弄死他:BAAALgAECgEJAgAAAA==.',
['我真']='我真的在奶了:BAAALgAECgEJAQAAAA==.我真的太难了:BAACLgAFFH8PAAMIAAQJyhK9CQAyAQAIAAQJbxG9CQAyAQAHAAMJSAs6BgDvAAAuAAQKfx8AAwcACAkDFYIfAMIBAAgACAlrEmxGANoBAAcACAmTEIIfAMIBAAAA.',
['我这']='我这德行:BAAALgAECgYJDAAAAA==.',
['战吊']='战吊爱冲锋:BAAALgAECgMJBAAAAA==.',
['打瞌']='打瞌睡的鱼:BAAALgAECgcJBwAAAA==.',
['托尔']='托尔丶:BAAALgADCgEJAQAAAA==.',
['抹茶']='抹茶大福:BAABLgAFFH8UAAMXAAcJChbqAABcAgAXAAcJChbqAABcAgAYAAMJ8gXbCACCAAAAAA==.',
['摩根']='摩根勒菲:BAAALgAECgcJBwAAAA==.',
['摸头']='摸头点赞拒战:BAAALgADCgIJAgAAAA==.',
['放开']='放开这湿太:BAAALgAECgEJAQAAAA==.',
['放肆']='放肆的溫柔:BAAALgAECgEJAQAAAA==.',
['斬灬']='斬灬相思:BAAALgAECgYJBQAAAA==.',
['断一']='断一下别瘤了:BAABLgAECn8ZAAMZAAYJ4Q8iTwBHAQAZAAYJ4Q8iTwBHAQAaAAYJTxBIRgAvAQAAAA==.',
['时婧']='时婧丶梦沧妍:BAAALgAECgkJCQAAAA==.',
['春哥']='春哥的叉腰肌:BAAALgADCgYJBgAAAA==.',
['晓分']='晓分阴阳:BAAALgADCgIJAgAAAA==.',
['暖暖']='暖暖混子:BAABLgAECn8WAAIWAAYJQBDQPwBFAQAWAAYJQBDQPwBFAQAAAA==.',
['最后']='最后的教堂:BAAALgAECgQJBAAAAA==.',
['有点']='有点脾气:BAABLgAFFH8gAAMMAAgJFhttAAD4AgAMAAgJFhttAAD4AgAbAAMJRQbHBADrAAAAAA==.',
['期年']='期年:BAAALgADCgQJCQAAAA==.',
['木小']='木小沫:BAAALgAECgcJDAAAAA==.',
['术神']='术神:BAAALgAECgIJAwAAAA==.',
['朱小']='朱小荣:BAAALgAECgEJAQAAAA==.',
['朴上']='朴上瘾:BAAALgAECgMJBAAAAA==.',
['朴国']='朴国尝:BAAALgAECgUJDwAAAA==.',
['机智']='机智的小满满:BAAALgAECgcJBwABLgAFFAUJFQAbAIEkAA==.',
['权倾']='权倾一世:BAAALgAECgIJAgAAAA==.',
['李小']='李小伟:BAAALgAECgIJAgAAAA==.',
['李清']='李清之:BAAALgAECgIJAgAAAA==.',
['杜皮']='杜皮和帝皮:BAAALgAECgcJDgAAAA==.',
['来口']='来口芥末么:BAAALgAECgcJDAAAAA==.',
['松下']='松下裤带子:BAAALgAECgcJDQAAAA==.',
['林雪']='林雪:BAABLgAFFH8HAAIIAAUJbxU1EABMAQAIAAUJbxU1EABMAQAAAA==.',
['柠檬']='柠檬冰茶:BAAALgAECgEJAQABLgAFFAUJCQAIALYEAA==.柠檬骑:BAAALgAECgcJBwAAAA==.',
['样银']='样银笑幻:BAAALgAECgYJAgAAAA==.',
['核桃']='核桃酥:BAABLgAECn8VAAIcAAcJWBXYDgB3AQAcAAcJWBXYDgB3AQAAAA==.',
['桃花']='桃花诺:BAAALgAFFAEJAQAAAA==.',
['桥豆']='桥豆麻袋桑:BAAALgADCgEJAQAAAA==.',
['梦醒']='梦醒时分:BAAALgAECgYJDQAAAA==.',
['梦魇']='梦魇破晓:BAACLgAFFH8WAAMYAAcJ4xoXAACjAgAYAAcJwBgXAACjAgAWAAMJUhMfEwDgAAAuAAQKfxgAAhgACAk4JOYEADkDABgACAk4JOYEADkDAAAA.',
['止殇']='止殇之光:BAAALgAECgMJAwAAAA==.',
['正义']='正义摸鱼使者:BAAALgAECgEJAQAAAA==.',
['武魄']='武魄战魂:BAAALgAECgQJDAAAAA==.',
['毛毛']='毛毛熊:BAAALgAFFAQJBAAAAA==.',
['永恒']='永恒飞鸟:BAAALgAECgYJBgAAAA==.',
['汉东']='汉东省高育良:BAABLgAFFH8HAAMOAAMJbxgpCwDUAAAOAAMJbxgpCwDUAAALAAIJvwQ9FwCHAAAAAA==.',
['汤汤']='汤汤:BAAALgAECgcJCwAAAA==.',
['汤湯']='汤湯:BAAALgAECgYJDAAAAA==.',
['沐雪']='沐雪微寒:BAACLgAFFH8VAAIIAAYJahrLAwD5AQAIAAYJahrLAwD5AQAuAAQKfxwAAwgACAkqG/01AB8CAAgACAkOG/01AB8CAAcAAQm+EhYaAEAAAAAA.',
['沙白']='沙白田:BAAALgAECgMJBQAAAA==.',
['没头']='没头脑呀:BAACLgAFFH8NAAMGAAYJ3hlvAADdAQAGAAYJmxhvAADdAQAFAAEJ5B4uBgBcAAAuAAQKfxkAAgYACAkcIEsUAPECAAYACAkcIEsUAPECAAAA.',
['没没']='没没木头:BAACLgAFFH8VAAIOAAYJsR5pAQAKAgAOAAYJsR5pAQAKAgAuAAQKfx0AAg4ACQlsIpMGACIDAA4ACQlsIpMGACIDAAAA.',
['治愈']='治愈系芒果丶:BAACLgAFFH8gAAQKAAgJVx9OAAAWAwAKAAgJoR5OAAAWAwAJAAQJPh32BwAcAQAdAAEJux/HBwBjAAAuAAQKfxkAAwoACAmqI5EMAOECAAoACAleI5EMAOECAAkAAgm+IpWKAMkAAAAA.',
['泼熊']='泼熊:BAAALgAECgUJBQAAAA==.',
['流沙']='流沙:BAABLgAFFH8FAAIIAAMJDRgMGQAHAQAIAAMJDRgMGQAHAQAAAA==.',
['海棠']='海棠未雨:BAAALgAECgcJAgAAAA==.',
['海边']='海边微风起:BAAALgAECgMJAwAAAA==.',
['深仁']='深仁厚泽:BAACLgAFFH8OAAMcAAUJCBOZBQCCAQAcAAUJCBOZBQCCAQAGAAMJqQ+WFgD4AAAuAAQKfxcAAhwACAnFIiMMALoCABwACAnFIiMMALoCAAAA.',
['清虚']='清虚术一:BAAALgAECgcJAgAAAA==.',
['清风']='清风依旧:BAAALgAECgUJBgAAAA==.清风拂过:BAAALgAECgIJAQAAAA==.',
['滚地']='滚地瓜:BAAALgAECgQJBAAAAA==.',
['漂亮']='漂亮的回旋踢:BAAALgAECgYJCgAAAA==.',
['潶貓']='潶貓:BAAALgAECgIJAgAAAA==.',
['激渴']='激渴:BAAALgAECgYJBgABLgAFFAMJBwANAMASAA==.激渴小龙人:BAACLgAFFH8HAAMNAAMJwBIxEgCdAAANAAIJQxIxEgCdAAAMAAIJ7AMeEgCLAAAuAAQKfxgAAw0ABwmRF1UiAGcBAA0ABgnJF1UiAGcBAAwAAwm0EytHAL4AAAAA.激渴黑骑士:BAAALgAECgYJBgABLgAFFAMJBwANAMASAA==.',
['灬惩']='灬惩戒骑灬:BAABLgAECn8VAAIGAAcJwCSoBgBHAgAGAAcJwCSoBgBHAgAAAA==.',
['灬风']='灬风灬:BAAALgAFFAIJBAAAAA==.',
['灵梦']='灵梦丶:BAAALgAECgcJDgAAAA==.',
['灵玉']='灵玉一念之插:BAAALgAECgcJCAAAAA==.',
['灼热']='灼热之熵:BAAALgAECgIJAwAAAA==.',
['烈火']='烈火燎缘:BAAALgAECgUJBgAAAA==.',
['烏鸦']='烏鸦:BAAALgAECgIJAgAAAA==.',
['煕媛']='煕媛:BAAALgAECgkJCQAAAA==.',
['牛一']='牛一刀:BAAALgAECgYJCQAAAA==.',
['牛多']='牛多重:BAACLgAFFH8bAAMKAAgJJhxoAAD9AgAKAAgJmhtoAAD9AgAJAAEJKBj3IQBcAAAuAAQKfxkAAgoACAl7JRcIABsDAAoACAl7JRcIABsDAAAA.',
['牛德']='牛德华:BAAALgAECgMJAwAAAA==.',
['特麽']='特麽劈我瓜:BAAALgAFFAIJBAAAAA==.',
['犬啸']='犬啸天:BAABLgAECn8aAAMBAAgJGBAVNADcAAABAAcJlREVNADcAAAEAAEJLQe6SQAkAAAAAA==.',
['狐人']='狐人总冠军:BAABLgAECn8XAAIZAAkJ7hIOJQABAgAZAAkJ7hIOJQABAgAAAA==.',
['独行']='独行浪人:BAAALgAECgMJAwAAAA==.',
['猫猫']='猫猫人:BAAALgADCgMJAwAAAA==.',
['玄翊']='玄翊:BAAALgAECgYJDgABLgAFFAIJAwATAAAAAA==.',
['王不']='王不留行:BAABLgAECn8XAAIBAAgJth9LLwB7AgABAAgJth9LLwB7AgAAAA==.',
['王栽']='王栽楞:BAAALgAECgQJBAAAAA==.',
['由加']='由加莉丶:BAAALgAFFAIJAgAAAA==.',
['画甲']='画甲:BAACLgAFFH8QAAIaAAUJtBpUBAChAQAaAAUJtBpUBAChAQAuAAQKfyEAAhoACAkiJZoEAFEDABoACAkiJZoEAFEDAAAA.',
['痞帅']='痞帅:BAAALgAECgkJBgAAAA==.',
['癞疙']='癞疙宝:BAAALgADCgcJBwAAAA==.',
['白玉']='白玉汤:BAAALgAECgEJAgAAAA==.',
['白瑟']='白瑟大胖:BAAALgAECgMJAgAAAA==.',
['皮兔']='皮兔叽:BAAALgADCgcJBwAAAA==.',
['皮叽']='皮叽兔:BAACLgAFFH8fAAIeAAgJdRVPAADQAgAeAAgJdRVPAADQAgAuAAQKfxgAAh4ACAlUIjMFAP8CAB4ACAlUIjMFAP8CAAAA.皮叽叽:BAACLgAFFH8IAAIZAAQJNRZRBgBhAQAZAAQJNRZRBgBhAQAuAAQKfxQAAhkACAnvGdodAC0CABkACAnvGdodAC0CAAEuAAUUCAkfAB4AdRUA.',
['皮喵']='皮喵喵:BAAALgAECgQJBQAAAA==.',
['皮皮']='皮皮酷:BAAALgAFFAQJAgABLgAFFAQJBAATAAAAAA==.皮皮露:BAAALgAFFAQJBAAAAA==.',
['眠眠']='眠眠糖:BAAALgAECgEJAQAAAA==.',
['眼镜']='眼镜琤琤亮:BAAALgAECgYJDgAAAA==.',
['睿德']='睿德门儿:BAAALgAECgcJDQAAAA==.',
['矿石']='矿石终结者:BAAALgAECgcJCwAAAA==.',
['破晓']='破晓之矢:BAABLgAFFH8GAAMJAAMJghd9CgAOAQAJAAMJghd9CgAOAQAKAAEJAQ5UKABLAAAAAA==.',
['祢豆']='祢豆子丶:BAACLgAFFH8OAAIGAAUJABi9AwC3AQAGAAUJABi9AwC3AQAuAAQKfxwAAgYACAk9JEMMACwDAAYACAk9JEMMACwDAAAA.',
['禹言']='禹言:BAAALgADCgEJAQAAAA==.',
['秋雨']='秋雨化酒:BAACLgAFFH8HAAIWAAMJmQvPCwDVAAAWAAMJmQvPCwDVAAAuAAQKfxUAAhYABgndGJkyAIcBABYABgndGJkyAIcBAAAA.',
['秦叔']='秦叔叔:BAAALgAECgYJCgAAAA==.',
['秦哥']='秦哥哥:BAAALgAECgIJAwAAAA==.',
['秦媽']='秦媽媽:BAAALgAECgYJCgAAAA==.',
['穿花']='穿花衣的狐狸:BAAALgAFFAIJBAAAAA==.',
['笨咪']='笨咪:BAAALgAECgEJAwAAAA==.',
['等我']='等我开火跑:BAAALgAFFAIJAgAAAA==.',
['筱月']='筱月儿:BAAALgAECgEJAQAAAA==.',
['箭来']='箭来:BAAALgADCgUJBQAAAA==.',
['米山']='米山:BAAALgAECgYJBgAAAA==.',
['米斯']='米斯思:BAABLgAECn8VAAIfAAgJyBVGCwAXAgAfAAgJyBVGCwAXAgABLgAFFAQJBQAQAJAGAA==.',
['粉条']='粉条子:BAAALgAECgEJAQAAAA==.',
['索尔']='索尔德林:BAACLgAFFH8JAAIcAAQJ/xAKCgA4AQAcAAQJ/xAKCgA4AQAuAAQKfx4AAxwACAlsHxAKANICABwACAlsHxAKANICAAYAAQn0BwJFATIAAAAA.',
['索沦']='索沦斯:BAAALgAECgEJAgAAAA==.',
['紫烨']='紫烨:BAAALgADCgYJBgAAAA==.',
['红尘']='红尘续梦:BAAALgADCgEJAQAAAA==.',
['绷不']='绷不住嘞:BAACLgAFFH8MAAMRAAQJtCKSCACfAQARAAQJtCKSCACfAQAgAAEJLRy1EQBcAAAuAAQKfxcAAxEACAmLH7MoAG4CABEABwmLH7MoAG4CACAAAQkAAI1gAE0AAAAA.',
['罪恶']='罪恶水果刀:BAAALgAECgYJCQAAAA==.',
['翻滚']='翻滚吧兔宝宝:BAAALgAFFAIJAgAAAA==.',
['老孩']='老孩子:BAAALgADCgYJBgAAAA==.',
['老山']='老山:BAAALgAECgMJAwAAAA==.',
['耳龙']='耳龙:BAAALgAECgYJDAAAAA==.',
['肉圆']='肉圆:BAAALgAECgUJBAAAAA==.',
['舞状']='舞状元:BAAALgAECgYJDAAAAA==.',
['艾德']='艾德里安娜:BAAALgAECgcJBwAAAA==.',
['芒果']='芒果呐丶:BAAALgAECgYJDAAAAA==.芒果术:BAACLgAFFH8LAAMgAAYJMx81AACMAQAgAAUJlBw1AACMAQARAAUJbBj1DwBgAQAuAAQKfxcAAhEACAkAIYUZALwCABEACAkAIYUZALwCAAAA.芒果猎:BAAALgAFFAEJAQAAAA==.',
['花拳']='花拳绣腿:BAAALgAECggJDwAAAA==.',
['花西']='花西:BAAALgAECgIJAgAAAA==.',
['荠麦']='荠麦弥望:BAABLgAFFH8FAAIhAAMJTBieAgDnAAAhAAMJTBieAgDnAAAAAA==.',
['荳包']='荳包:BAAALgAECgYJEgAAAA==.',
['莫要']='莫要和我扯:BAAALgAECgEJAQAAAA==.',
['莼青']='莼青色灬:BAAALgADCgUJBQAAAA==.',
['萌萌']='萌萌妲:BAAALgADCgMJAwAAAA==.萌萌小术:BAAALgAECgYJCAAAAA==.',
['萨西']='萨西摩尔堇花:BAAALgAECgUJBQAAAA==.',
['虔坤']='虔坤:BAAALgAECgIJAgAAAA==.',
['行丨']='行丨风暴烈酒:BAAALgAECgEJAQAAAA==.',
['西红']='西红柿炖牛腩:BAABLgAFFH8FAAIRAAMJcgtVJQDtAAARAAMJcgtVJQDtAAAAAA==.',
['西蜀']='西蜀扛霸子:BAAALgAECgUJBgAAAA==.',
['豆包']='豆包:BAAALgAFFAIJAgAAAA==.',
['豪豬']='豪豬吉列姆:BAABLgAFFH8MAAMRAAUJViUdBwCxAQARAAQJ3CQdBwCxAQAgAAIJbCSJCADYAAAAAA==.',
['贝簏']='贝簏丹尼:BAAALgAECgYJBgAAAA==.',
['赖皮']='赖皮蛇:BAAALgAECgIJAgAAAA==.',
['赤炎']='赤炎马:BAACLgAFFH8IAAIDAAQJWhl/BgB4AQADAAQJWhl/BgB4AQAuAAQKfxkAAgMACAlQJHsIAAkDAAMACAlQJHsIAAkDAAAA.',
['赤焰']='赤焰马:BAAALgAFFAIJBAABLgAFFAQJCAADAFoZAA==.',
['赤色']='赤色天下:BAAALgAECgYJCQAAAA==.',
['轩辕']='轩辕神君:BAAALgAECgcJCwAAAA==.',
['转一']='转一下别毛了:BAAALgAECgEJAQAAAA==.',
['辛达']='辛达苟萨灬灬:BAAALgAFFAIJAgAAAA==.',
['辽北']='辽北著名狠人:BAAALgAECgQJBQAAAA==.',
['达斯']='达斯摩尔:BAAALgAECgkJBgAAAA==.',
['迪凯']='迪凯:BAAALgAECgYJCwAAAA==.',
['造型']='造型大咖:BAAALgAECgYJBgAAAA==.',
['遗忘']='遗忘血腥:BAAALgAECgUJCAAAAA==.',
['遺忘']='遺忘血腥:BAAALgAECgQJBAAAAA==.',
['酒蒙']='酒蒙叶子:BAAALgAFFAMJBAAAAA==.',
['野性']='野性花仙子:BAAALgAECgcJDwAAAA==.',
['钢琴']='钢琴里的猫:BAAALgAFFAcJBAAAAA==.',
['铁血']='铁血传奇:BAAALgAECgEJAQAAAA==.',
['银色']='银色天空:BAAALgADCgMJAwAAAA==.',
['长歌']='长歌暖浮生:BAAALgAECgEJAQAAAA==.',
['闲潭']='闲潭梦落花:BAAALgAECgUJBQAAAA==.',
['闷头']='闷头别瞎挤:BAAALgAECgYJCgAAAA==.',
['阿术']='阿术丶:BAACLgAFFH8HAAMgAAQJAxPDCwCtAAARAAMJNQ/4IwD0AAAgAAIJdxHDCwCtAAAuAAQKfxcAAxEACAm3GwJNAOEBABEABwl4FQJNAOEBACAABAmXFsIlADABAAAA.',
['阿法']='阿法:BAABLgAECn8WAAICAAcJlAM96wAhAQACAAcJlAM96wAhAQAAAA==.',
['阿迪']='阿迪牛仔:BAAALgADCgYJBgAAAA==.',
['雨落']='雨落云飞丶:BAABLgAECn8YAAIDAAkJhh/KAgB5AwADAAkJhh/KAgB5AwAAAA==.',
['雪代']='雪代灬巴:BAAALgAECgUJCAAAAA==.',
['雪悦']='雪悦:BAAALgAECggJDwAAAA==.',
['雪花']='雪花沉睡:BAAALgAECgEJAQAAAA==.',
['霁无']='霁无瑕:BAACLgAFFH8GAAIIAAMJICGtFQAkAQAIAAMJICGtFQAkAQAuAAQKfxgAAggABwkgH/omAGkCAAgABwkgH/omAGkCAAAA.',
['霜与']='霜与混乱:BAAALgAECgUJCQAAAA==.',
['风怒']='风怒狂牛:BAAALgAECgUJBQAAAA==.',
['风暴']='风暴无尽:BAAALgAECgYJEgAAAA==.',
['风飒']='风飒飒木萧萧:BAABLgAECn8UAAIUAAgJTRTrIwA3AgAUAAgJTRTrIwA3AgAAAA==.',
['饱了']='饱了横:BAABLgAFFH8FAAIBAAIJgxdTNAC3AAABAAIJgxdTNAC3AAAAAA==.',
['香蕉']='香蕉你个芭拉:BAAALgADCgQJBAAAAA==.香蕉哥哥:BAAALgAECgkJCQAAAA==.',
['马可']='马可波罗:BAABLgAFFH8HAAIGAAMJYxr2EgAOAQAGAAMJYxr2EgAOAQABLgAFFAUJDgAJAKMgAA==.',
['髭男']='髭男:BAABLgAFFH8TAAMRAAUJ8yVzAQAvAgARAAUJ8yVzAQAvAgAgAAEJNxZsEwBYAAABLgAFFAUJDAARAFYlAA==.',
['鸿翊']='鸿翊:BAAALgAECgcJBwAAAA==.',
['鹰眼']='鹰眼瞄的准:BAAALgAECgcJCQAAAA==.',
['鹿鸣']='鹿鸣丶星河:BAAALgAECgQJBAAAAA==.',
['鼎隆']='鼎隆鑫肥牛:BAAALgAECgcJBwAAAA==.',
['龙猎']='龙猎:BAAALgAECgUJBgAAAA==.',
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
