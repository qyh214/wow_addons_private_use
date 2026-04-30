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

local lookup = {'Shaman-Elemental','DemonHunter-Havoc','Evoker-Preservation','Rogue-Subtlety','Rogue-Assassination','Priest-Holy','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Restoration','Druid-Balance','DemonHunter-Devourer','Shaman-Restoration','Warrior-Fury','DeathKnight-Blood','DeathKnight-Unholy','Mage-Frost','Evoker-Augmentation','Paladin-Holy','Paladin-Protection','Paladin-Retribution','Warrior-Protection','Evoker-Devastation','Warlock-Demonology','DeathKnight-Frost',}
local provider = {region='CN',realm='勇士岛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexluo:BAAALgAECgYJBgAAAA==.',
As='Ashbringer:BAAALgAFFAEJAQAAAA==.',
Cr='Crit:BAAALgAECgMJBAAAAA==.Crushso:BAAALgAECgEJAQAAAA==.',
Dr='Dra:BAAALgAECggJCAAAAA==.',
Fr='Frostmoon:BAAALgAECgEJAgAAAA==.',
Go='Gourdin:BAAALgAECgcJCwAAAA==.',
Kh='Khuntoria:BAACLgAFFH8NAAIBAAUJzCEAAgDuAQABAAUJzCEAAgDuAQAuAAQKfycAAgEACQnPIlgCAI0DAAEACQnPIlgCAI0DAAAA.',
Ku='Kunppapa:BAABLgAECn8VAAICAAgJsBoGDQCSAgACAAgJsBoGDQCSAgAAAA==.',
Li='Ligoat:BAAALgAECgIJAwAAAA==.Liquidtobo:BAABLgAFFH8FAAIDAAIJVBicEQClAAADAAIJVBicEQClAAAAAA==.',
Ml='Mlsslovee:BAAALgADCgEJAQAAAA==.',
Mo='Morghulis:BAAALgAECgQJBgABLgAFFAMJCQADAOcgAA==.',
Rl='Rlyeh:BAABLgAECn8XAAMEAAcJvh72FABrAgAEAAcJGR72FABrAgAFAAYJUx/eCwBpAQAAAA==.',
Sa='Saphira:BAABLgAFFH8IAAIGAAMJbSS6BAA7AQAGAAMJbSS6BAA7AQAAAA==.',
Si='Siky:BAAALgAECgQJBAAAAA==.',
Su='Superorange:BAAALgAECgYJBwAAAA==.',
Ve='Veoul:BAAALgAECgIJAgAAAA==.',
Wh='Whitemane:BAAALgAECggJEQAAAA==.',
['一翩']='一翩若惊鸿一:BAAALgAECgMJAQAAAA==.',
['一首']='一首陌离歌:BAAALgAFFAEJAQAAAA==.',
['万贱']='万贱归冢丶:BAAALgAECgYJBgAAAA==.',
['三条']='三条腿:BAAALgAFFAEJAQAAAA==.',
['下次']='下次我请:BAAALgAECgYJDgAAAA==.',
['不擅']='不擅杀伐:BAAALgAECgEJAQABLgAFFAIJAwAHAAAAAA==.',
['不死']='不死神术:BAAALgAFFAEJAgAAAA==.',
['不知']='不知冬:BAAALgAECgYJCQAAAA==.',
['丨一']='丨一哥丨:BAAALgADCgIJAgAAAA==.',
['丨丶']='丨丶灬逼格妈:BAAALgADCgEJAQAAAA==.',
['丨灰']='丨灰丶烬丨:BAAALgAECgcJBwAAAA==.',
['丶牜']='丶牜叉的愺根:BAAALgADCgEJAgAAAA==.',
['丶獵']='丶獵:BAAALgAFFAIJAgAAAA==.',
['丹丹']='丹丹丶:BAAALgAFFAIJAQAAAA==.',
['为了']='为了联盟灬:BAACLgAFFH8LAAMIAAQJ+BkXCgAQAQAJAAQJLg3LEAAoAQAIAAQJmBkXCgAQAQAuAAQKfxUAAwgACAkLHzECAIwCAAgACAkLHzECAIwCAAkABQlOA/hnAJ4AAAAA.',
['为人']='为人民服务:BAAALgAECgMJBQAAAA==.',
['丿斩']='丿斩:BAAALgAECgEJAQAAAA==.',
['乐邦']='乐邦詹士:BAABLgAFFH8KAAMKAAQJdhWICABJAQAKAAQJdhWICABJAQALAAIJsgC9DABLAAAAAA==.',
['二三']='二三四五六:BAAALgAECgQJBwAAAA==.',
['云枫']='云枫乔:BAAALgAECgQJBQAAAA==.',
['亿之']='亿之水月:BAAALgAECgYJBwAAAA==.',
['伊俐']='伊俐丹怒風:BAAALgAECgUJBgAAAA==.',
['伍分']='伍分熟:BAAALgAECgYJBgABLgAFFAYJBwAMAGYTAA==.',
['你才']='你才是奶龙:BAAALgADCgEJAQAAAA==.',
['傲天']='傲天大兵:BAAALgAECgQJCAAAAA==.',
['元素']='元素喵喵:BAABLgAECn8VAAMNAAgJkCImCwDLAgANAAgJkCImCwDLAgABAAYJkQ3HRAA1AQAAAA==.',
['元龙']='元龙:BAAALgADCgUJBQAAAA==.',
['克莉']='克莉斯蒂亚诺:BAAALgADCgEJAQAAAA==.',
['八橙']='八橙在手:BAAALgADCgcJBwAAAA==.',
['六五']='六五三灵一:BAAALgAECgEJAQAAAA==.',
['六侠']='六侠来:BAAALgAECgEJAgAAAA==.',
['兹拜']='兹拜因巴哈:BAAALgAECgMJAwAAAA==.',
['再入']='再入深渊:BAAALgAECgEJAgAAAA==.',
['冰甜']='冰甜小粽子:BAAALgADCgkJCQAAAA==.',
['冰糖']='冰糖小粽子:BAAALgAECgcJCwAAAA==.',
['冲浪']='冲浪的鲨鱼:BAACLgAFFH8HAAIOAAIJQQpMGgCgAAAOAAIJQQpMGgCgAAAuAAQKfxcAAg4ABwkQFg8LAG8BAA4ABwkQFg8LAG8BAAAA.',
['冲锋']='冲锋乆乆:BAAALgAECgMJBQAAAA==.',
['决不']='决不平凡:BAAALgADCgMJAwAAAA==.',
['冷月']='冷月曦:BAABLgAECn8ZAAIPAAYJnx1yBACLAQAPAAYJnx1yBACLAQABLgAFFAIJBQADAFQYAA==.',
['凌乱']='凌乱的人生:BAAALgAECgYJDAAAAA==.',
['凛冬']='凛冬之球:BAAALgAFFAEJAgAAAA==.',
['别搞']='别搞了呀:BAAALgADCgEJAQAAAA==.',
['刷刷']='刷刷喵:BAAALgAECgQJBAABLgAECggJEQAHAAAAAA==.',
['勇士']='勇士王子:BAAALgAECgMJBQAAAA==.',
['十火']='十火十:BAAALgADCgEJAQAAAA==.',
['卉卉']='卉卉巍巍:BAAALgAECgMJAwAAAA==.',
['卖萌']='卖萌骑骑:BAABLgAFFH8HAAIQAAMJ/hiiDQAIAQAQAAMJ/hiiDQAIAQAAAA==.',
['博丽']='博丽灵梦:BAAALgAECgEJAQAAAA==.',
['卡德']='卡德减:BAAALgAECgQJBAAAAA==.',
['卡神']='卡神:BAABLgAFFH8GAAIRAAIJtBgMOAC6AAARAAIJtBgMOAC6AAAAAA==.',
['又红']='又红又硬:BAAALgADCgUJBQAAAA==.',
['变个']='变个熊看看:BAAALgADCgUJBQAAAA==.',
['古风']='古风淦:BAAALgADCgIJAgAAAA==.',
['只抽']='只抽华子:BAAALgAFFAEJAQAAAA==.',
['史蒂']='史蒂芬霍津:BAAALgAECggJCAAAAA==.',
['吃蜜']='吃蜜桃的男人:BAAALgAECgEJAwAAAA==.',
['同窗']='同窗:BAAALgADCgEJAQAAAA==.',
['呆西']='呆西七号:BAABLgAFFH8IAAISAAUJ/x3/BgCGAQASAAUJ/x3/BgCGAQAAAA==.呆西五号:BAABLgAFFH8HAAISAAQJ/ByxBwB2AQASAAQJ/ByxBwB2AQAAAA==.呆西八号:BAABLgAFFH8JAAISAAQJDxpYCQBZAQASAAQJDxpYCQBZAQAAAA==.呆西六号:BAABLgAFFH8GAAISAAUJghuiBAC/AQASAAUJghuiBAC/AQAAAA==.',
['咪类']='咪类个喵:BAAALgAECgEJAQAAAA==.',
['哈哩']='哈哩咕噜几:BAAALgAECgEJAQAAAA==.',
['唐萌']='唐萌萌:BAAALgAECgIJAgABLgAFFAEJAQAHAAAAAA==.',
['唛晨']='唛晨:BAAALgADCgIJAgAAAA==.',
['嘻样']='嘻样样:BAAALgAECgYJCgAAAA==.',
['国际']='国际名媛:BAAALgAECgYJBgAAAA==.',
['圆滚']='圆滚滚:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光大粽子:BAABLgAECn8VAAMTAAgJkhHhKQDiAQATAAgJkhHhKQDiAQAUAAIJawXyPgBCAAAAAA==.',
['圣淡']='圣淡净魔仇:BAAALgADCgUJBQAAAA==.',
['埃尔']='埃尔文薛定谔:BAACLgAFFH8PAAIUAAUJ/Bl8AACdAQAUAAUJ/Bl8AACdAQAuAAQKfxYAAhQACQnWHJIDAN8CABQACQnWHJIDAN8CAAAA.',
['墨染']='墨染丶未央:BAAALgAECgUJBQAAAA==.',
['士法']='士法:BAAALgAFFAIJAwAAAA==.',
['壹生']='壹生所愛:BAAALgADCgUJBQAAAA==.',
['夏慕']='夏慕萘萘:BAAALgAECgUJCgAAAA==.',
['夜月']='夜月追风:BAACLgAFFH8NAAIRAAUJlBPtDgCgAQARAAUJlBPtDgCgAQAuAAQKfykAAhEACQl5FaxBAHMCABEACQl5FaxBAHMCAAAA.',
['夜羽']='夜羽:BAAALgAECgIJAQAAAA==.夜羽丶:BAAALgAECgQJBQAAAA==.',
['夢飛']='夢飛瑒:BAAALgAFFAMJBAAAAA==.',
['大丽']='大丽花的咆哮:BAAALgAECgQJCQAAAA==.',
['大兵']='大兵:BAABLgAECn8ZAAIVAAYJeh2xbQCiAQAVAAYJeh2xbQCiAQAAAA==.',
['大圣']='大圣僧:BAAALgAECgUJEgAAAA==.',
['大德']='大德鲁伊亮仔:BAAALgADCgIJAgAAAA==.',
['大领']='大领主亮仔:BAAALgAFFAIJBAAAAA==.',
['大风']='大风吹:BAAALgAECgYJCgAAAA==.',
['天之']='天之城:BAAALgADCgUJBQAAAA==.',
['天地']='天地同寿:BAAALgAECgYJCQAAAA==.',
['天澜']='天澜冰歌:BAAALgAECgUJBgAAAA==.',
['奋进']='奋进的小强:BAAALgAECgUJBQAAAA==.',
['女主']='女主播:BAAALgAECgEJAgAAAA==.',
['好久']='好久不见好久:BAAALgAECgYJBgAAAA==.',
['威哥']='威哥:BAAALgADCgYJBgAAAA==.',
['孤城']='孤城不危:BAAALgAECgYJDAAAAA==.',
['宋雨']='宋雨琦:BAAALgAECgYJBwABLgAFFAIJBQADAFQYAA==.',
['完乂']='完乂美:BAAALgAECgEJAgAAAA==.',
['完美']='完美音调:BAAALgAFFAEJAQAAAA==.完美音韵:BAAALgADCgEJAQAAAA==.',
['宝宝']='宝宝雙:BAAALgADCgUJBQAAAA==.',
['寂静']='寂静冷冬:BAAALgAECgUJBgAAAA==.',
['富婆']='富婆来拉怪:BAAALgAECgYJBgAAAA==.',
['小宝']='小宝贝儿:BAAALgAECgUJBQAAAA==.',
['小炒']='小炒肉:BAAALgAECgYJCQAAAA==.',
['小苏']='小苏儿:BAAALgAECgcJCgAAAA==.',
['小菊']='小菊花:BAAALgAECgEJAQAAAA==.',
['小闷']='小闷骚:BAAALgAECgEJAgAAAA==.',
['小飞']='小飞:BAAALgAECgEJAQAAAA==.',
['小鱼']='小鱼蛋:BAAALgAECgUJBQAAAA==.小鱼鱼:BAAALgAECgYJBgAAAA==.',
['少女']='少女丶撒手:BAAALgAFFAEJAgAAAA==.',
['岛川']='岛川冈阪:BAABLgAFFH8NAAINAAQJXAXgBgDoAAANAAQJXAXgBgDoAAAAAA==.',
['左尔']='左尔:BAAALgADCgIJAgAAAA==.',
['市子']='市子安娜:BAAALgAECgMJBAAAAA==.',
['幼稚']='幼稚园哈尼:BAAALgAECgQJBAAAAA==.',
['强尼']='强尼:BAAALgAECgYJBgAAAA==.',
['影心']='影心:BAABLgAFFH8JAAMDAAMJ5yCACwAyAQADAAMJ5yCACwAyAQASAAMJAByFHgBjAAAAAA==.',
['徐熙']='徐熙媛转世:BAAALgADCgUJBQAAAA==.',
['得非']='得非所求:BAAALgAECgYJCAAAAA==.',
['微雨']='微雨若絮:BAAALgAECgQJBgAAAA==.微雨雰霏:BAAALgAECgQJBQAAAA==.',
['微风']='微风沐情书:BAAALgAFFAEJAQAAAA==.',
['忘离']='忘离霹雳重触:BAAALgADCgEJAQAAAA==.',
['怕我']='怕我落地:BAAALgADCgQJBAAAAA==.',
['思寒']='思寒梅:BAAALgADCgIJAQAAAA==.',
['恋上']='恋上狗的狼:BAAALgAECgIJAgAAAA==.恋上酒的猫:BAAALgAFFAIJAgAAAA==.',
['恶魔']='恶魔乄市銀丸:BAAALgAECgYJCQAAAA==.',
['悟空']='悟空嘿嘿:BAAALgAECgYJCAAAAA==.',
['情迷']='情迷大自然:BAAALgAECgYJDAAAAA==.',
['慕青']='慕青:BAAALgAECgYJBgAAAA==.',
['戰岚']='戰岚破海:BAAALgAFFAMJAgABLgAFFAcJDQAWAM4ZAA==.',
['打不']='打不过溜溜球:BAAALgAECgEJAQAAAA==.',
['打斐']='打斐济:BAAALgAECgQJBAAAAA==.',
['打爆']='打爆你的狗头:BAAALgAECgEJAQAAAA==.',
['抚蔚']='抚蔚光明:BAAALgADCgEJAgAAAA==.',
['拨弦']='拨弦弄月:BAAALgAECgYJBgAAAA==.',
['掌心']='掌心丶:BAAALgAECgYJBgAAAA==.',
['提里']='提里奥福鼎:BAAALgAECgYJBwAAAA==.',
['插花']='插花弄玉:BAAALgAECgQJBgAAAA==.',
['摁着']='摁着来:BAAALgAECgMJAwAAAA==.',
['放假']='放假:BAAALgADCgYJBgAAAA==.',
['敖乙']='敖乙:BAACLgAFFH8MAAIDAAQJgAwDCwA6AQADAAQJgAwDCwA6AQAuAAQKfyYAAgMACQmDHJIDACYDAAMACQmDHJIDACYDAAAA.',
['无情']='无情修罗:BAAALgADCgMJAwAAAA==.',
['无法']='无法选中:BAAALgAECgkJCQAAAA==.',
['时光']='时光漫步:BAAALgAECgEJAQAAAA==.',
['时间']='时间煮客:BAAALgAFFAEJAQAAAA==.',
['明明']='明明不是米粒:BAAALgAECgIJAgAAAA==.',
['星也']='星也丶:BAAALgAECgcJBwAAAA==.',
['星飞']='星飞鸟:BAAALgAECgMJAgAAAA==.',
['晓月']='晓月清歆:BAAALgAECgQJBgAAAA==.',
['暗夜']='暗夜小萱萱:BAAALgAECgEJAQAAAA==.',
['暗黑']='暗黑佟大为:BAACLgAFFH8MAAISAAQJixkyCQBbAQASAAQJixkyCQBbAQAuAAQKfyUABBIACAklIbkHAP0CABIACAklIbkHAP0CAAMAAQlbFk9EAEwAABcAAQkAAPQKAAAAAAAA.',
['暴力']='暴力幺妹:BAAALgAECgEJAgAAAA==.暴力鸟:BAAALgADCgEJAQAAAA==.',
['月之']='月之缨络:BAAALgADCgEJAQAAAA==.',
['月神']='月神之刃:BAAALgAECgQJBAAAAA==.',
['月蚀']='月蚀之舞:BAACLgAFFH8GAAMWAAMJigYZDQB6AAAOAAMJzgBmHQB7AAAWAAIJrwkZDQB6AAAuAAQKfxcAAxYABwmvFE8iACsBAA4ABwkADHdWAFIBABYABAnGHE8iACsBAAAA.',
['木森']='木森林:BAAALgADCgEJAQABLgAECgUJEgAHAAAAAA==.',
['木瓜']='木瓜惹的祸:BAABLgAECn8VAAIQAAgJdhQuVAD1AQAQAAgJdhQuVAD1AQAAAA==.',
['杜甫']='杜甫丶:BAAALgAFFAIJAgAAAA==.',
['枫叶']='枫叶飘落:BAAALgAECgYJBgAAAA==.',
['枫珏']='枫珏丶:BAAALgAECgcJDQAAAA==.',
['枫的']='枫的风格:BAAALgAECgYJCAAAAA==.',
['柏拉']='柏拉图的奶爸:BAAALgAECgEJAQAAAA==.',
['梦境']='梦境之忆:BAAALgADCgEJAQAAAA==.',
['梦落']='梦落丶:BAAALgAECgYJDAAAAA==.',
['森语']='森语鹿鸣:BAAALgAECgYJCQAAAA==.',
['楠疯']='楠疯鼓皂:BAAALgAECgYJBgAAAA==.',
['橙猫']='橙猫猫:BAAALgAECgYJBgAAAA==.',
['步步']='步步生花:BAAALgAECgYJEAAAAA==.',
['段小']='段小贱:BAAALgAECgMJAwAAAA==.',
['水无']='水无月丶辉夜:BAAALgADCgYJAQAAAA==.',
['江南']='江南晓月:BAAALgAFFAEJAQAAAA==.',
['汤圆']='汤圆麻麻:BAAALgAECgEJAgAAAA==.',
['沃纳']='沃纳海森堡:BAAALgAFFAEJAQAAAA==.',
['沉睡']='沉睡喵喵:BAAALgADCgkJCwAAAA==.',
['泡沫']='泡沫冰茶:BAAALgAECgQJBAAAAA==.',
['泪血']='泪血狂徒:BAAALgAFFAEJAQAAAA==.',
['浮光']='浮光丶:BAAALgAECgEJAQAAAA==.',
['海盗']='海盗湾:BAAALgAECgYJEQAAAA==.',
['海鲜']='海鲜之光:BAAALgAECgQJBAAAAA==.',
['淡然']='淡然天空:BAAALgAECgMJAwAAAA==.',
['清风']='清风醉笑:BAAALgAECgEJAQAAAA==.',
['火羽']='火羽白熠:BAAALgAECgMJAwAAAA==.',
['灬孙']='灬孙慧文灬:BAAALgADCgUJAQAAAA==.',
['灬小']='灬小太子奶:BAAALgADCgEJAQAAAA==.',
['灵魂']='灵魂边缘:BAAALgAECgMJAwAAAA==.',
['烈焰']='烈焰狂吻:BAAALgAECgMJAwAAAA==.',
['热情']='热情的大叔:BAAALgAECgEJAQAAAA==.',
['無丶']='無丶名:BAAALgAECgQJBQAAAA==.',
['熊猫']='熊猫小王子:BAAALgAECgEJAQAAAA==.',
['燚焱']='燚焱焱燚:BAAALgAECgYJBwAAAA==.',
['狂战']='狂战之魂:BAAALgADCgYJBgAAAA==.',
['狂暴']='狂暴狂暴战神:BAAALgAECgMJAwAAAA==.',
['狼与']='狼与香辛料:BAABLgAECn8WAAIKAAcJSxbwCwCWAQAKAAcJSxbwCwCWAQAAAA==.',
['猎物']='猎物不够:BAAALgAFFAEJAQAAAA==.',
['猫猫']='猫猫爱吃鱼:BAAALgADCgQJBAAAAA==.',
['玛卡']='玛卡里亚:BAAALgADCgkJCwAAAA==.',
['琳琳']='琳琳寶貝:BAAALgAECgMJAQAAAA==.',
['生煎']='生煎若干鸡蛋:BAAALgADCgkJCQAAAA==.',
['疾风']='疾风破袭:BAABLgAECn8ZAAIRAAYJeQnA2wA6AQARAAYJeQnA2wA6AQAAAA==.',
['白玉']='白玉蘭:BAAALgADCgEJAQAAAA==.',
['白菜']='白菜不再:BAAALgAFFAIJAgAAAA==.白菜子:BAABLgAFFH8JAAIMAAMJrxxeFgAeAQAMAAMJrxxeFgAeAQAAAA==.',
['皎兮']='皎兮:BAAALgAECgUJBQAAAA==.',
['真理']='真理香:BAAALgADCgEJAQAAAA==.',
['矮穷']='矮穷挫:BAAALgAECgMJAwAAAA==.',
['砹氰']='砹氰:BAAALgAECgYJCwAAAA==.',
['磷叶']='磷叶石:BAAALgADCgYJBgAAAA==.',
['神木']='神木与瞳:BAAALgAECgQJAwAAAA==.',
['神罗']='神罗郁帝:BAAALgAECgcJBwAAAA==.',
['立定']='立定跳远两米:BAAALgAECgMJAwAAAA==.',
['紫色']='紫色头发:BAAALgADCgEJAgAAAA==.',
['紫荆']='紫荆依然:BAAALgAECggJEgAAAA==.',
['绅不']='绅不由己:BAABLgAFFH8IAAIPAAQJYx78AwByAQAPAAQJYx78AwByAQAAAA==.',
['翁雪']='翁雪:BAAALgAECgcJBwABLgAFFAQJAQAHAAAAAA==.',
['翩若']='翩若鸿:BAAALgAFFAEJAQAAAA==.',
['胖可']='胖可丁:BAAALgADCgEJAQAAAA==.',
['舞魅']='舞魅夕:BAAALgAECgkJCQAAAA==.',
['艾利']='艾利亚罗:BAAALgADCgQJBAAAAA==.',
['芦名']='芦名丶未帆:BAAALgAECgQJBAAAAA==.',
['花仙']='花仙娘:BAAALgAECgcJBwAAAA==.',
['花椒']='花椒锅巴:BAABLgAFFH8GAAIYAAMJFg8TGQCkAAAYAAMJFg8TGQCkAAAAAA==.',
['苍穹']='苍穹夜鸦:BAAALgAECgYJEwAAAA==.',
['苏牧']='苏牧牧:BAAALgAECgYJCwAAAA==.',
['苏酥']='苏酥头号粉丝:BAAALgAFFAIJBAAAAA==.',
['荒野']='荒野断脊客:BAAALgAECgYJDgAAAA==.',
['莉雅']='莉雅的小蛋蛋:BAAALgAECgEJAQAAAA==.',
['莫格']='莫格萊尼:BAAALgADCgMJAwAAAA==.',
['莫西']='莫西欧赖:BAAALgAECgEJAgAAAA==.',
['菲星']='菲星:BAACLgAFFH8TAAIRAAUJ+yMzBwDtAQARAAUJ+yMzBwDtAQAuAAQKfygAAhEACQkuJXUEALkDABEACQkuJXUEALkDAAAA.',
['藏玛']='藏玛然特:BAAALgAECgcJCQAAAA==.',
['裤子']='裤子都脱了:BAAALgAECgEJAQAAAA==.',
['言谈']='言谈生趣:BAAALgAECgEJAgAAAA==.',
['諵蛮']='諵蛮乁笙箫亥:BAAALgAECgQJBQAAAA==.諵蛮乁笙箫子:BAAALgAECgcJCAAAAA==.',
['订书']='订书针:BAAALgAECgIJAgAAAA==.',
['诗酒']='诗酒趁年华丶:BAAALgAECgYJDQAAAA==.',
['语丶']='语丶墨:BAAALgAECgMJAwAAAA==.',
['请你']='请你喝阿帕茶:BAAALgAECgEJAQAAAA==.',
['谁为']='谁为天使忧愁:BAABLgAFFH8LAAMQAAMJ5SQWFwBIAQAQAAMJ5SQWFwBIAQAZAAIJzSEAAAAAAAAAAA==.',
['谁懂']='谁懂明月心:BAAALgAECgUJBQAAAA==.',
['豆沙']='豆沙饼:BAAALgAECgYJCgABLgAFFAUJEwARAPsjAA==.',
['贝亚']='贝亚特丽斯丶:BAAALgAECgEJAQAAAA==.',
['赛博']='赛博先祖:BAAALgADCgUJBQAAAA==.',
['路希']='路希菲尔:BAAALgAECgEJAQAAAA==.',
['辣白']='辣白菜:BAAALgAECgQJBAAAAA==.',
['还不']='还不削弱嘛:BAABLgAFFH8GAAIIAAMJ4RqrBQAiAQAIAAMJ4RqrBQAiAQAAAA==.',
['迷茫']='迷茫的蔓頭:BAAALgAECgEJAQAAAA==.',
['逐风']='逐风烨月:BAAALgAECgQJBAAAAA==.',
['那年']='那年的春夏:BAAALgAFFAEJAgAAAA==.',
['部落']='部落的敌人:BAAALgAECgUJBgAAAA==.',
['酌酒']='酌酒丶敬余年:BAAALgAECgEJAQAAAA==.',
['酷酷']='酷酷玛噜:BAAALgAECgEJAQAAAA==.',
['醉枫']='醉枫点墨:BAAALgAECgcJEQAAAA==.',
['醉梦']='醉梦浮生:BAAALgAECgQJBAAAAA==.',
['重走']='重走青春路:BAAALgAECgYJDgAAAA==.',
['重雷']='重雷:BAAALgADCgMJAwAAAA==.',
['銘訫']='銘訫頦餶:BAAALgADCgYJBgAAAA==.',
['锦山']='锦山:BAAALgAECgUJCAAAAA==.',
['长期']='长期术世:BAAALgAECgYJCgAAAA==.',
['闹伊']='闹伊做特:BAAALgAECgUJBgAAAA==.',
['阝灬']='阝灬熊熊彡:BAAALgAECgQJBAAAAA==.',
['防战']='防战天笑:BAAALgADCgMJAwAAAA==.',
['阿尔']='阿尔塞斯是我:BAAALgAECgEJAQAAAA==.阿尔达:BAAALgADCgYJBgAAAA==.',
['阿拉']='阿拉斯加湾:BAAALgAFFAQJAQAAAA==.',
['阿瓦']='阿瓦可:BAAALgAECgYJBgAAAA==.',
['阿鸡']='阿鸡:BAAALgAFFAEJAQAAAA==.',
['陈四']='陈四鸟:BAAALgADCgUJBQAAAA==.',
['雪華']='雪華绮晶:BAAALgADCgEJAQAAAA==.',
['零点']='零点乁枫如歌:BAAALgAECgYJBgAAAA==.',
['霁寒']='霁寒子:BAAALgAECgQJBwAAAA==.',
['青山']='青山几重:BAAALgAECgYJDgAAAA==.',
['靠近']='靠近靠近:BAAALgAFFAEJAQAAAA==.',
['风之']='风之猎影:BAAALgAECgIJAgAAAA==.',
['骨质']='骨质增僧:BAAALgAECgMJAwAAAA==.',
['魅匪']='魅匪蛇戊:BAAALgAECgUJBQAAAA==.',
['魔幻']='魔幻冥帝:BAAALgAECgQJBAAAAA==.魔幻天鋆:BAAALgAECgYJAwAAAA==.',
['魚雷']='魚雷雷:BAAALgAECgUJBQABLgAFFAQJDAADAIAMAA==.',
['鯊魚']='鯊魚香椒:BAAALgAECgEJAQAAAA==.',
['鳥叔']='鳥叔:BAAALgAECgEJAQAAAA==.',
['鸢尾']='鸢尾巨龙:BAAALgAECgYJDQAAAA==.',
['黄仁']='黄仁勋:BAAALgAECgUJCAAAAA==.',
['黑白']='黑白颜色:BAAALgADCgEJAQAAAA==.',
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
