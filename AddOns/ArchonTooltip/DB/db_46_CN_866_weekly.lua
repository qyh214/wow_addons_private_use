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

local lookup = {'Druid-Restoration','Warrior-Fury','Warrior-Arms','Warrior-Protection','Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Rogue-Subtlety','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Demonology','DeathKnight-Blood','Monk-Brewmaster','Rogue-Outlaw','Paladin-Holy','Rogue-Assassination','Priest-Discipline','DemonHunter-Havoc','DemonHunter-Devourer','Priest-Holy','Druid-Balance','Druid-Feral','Druid-Guardian',}
local provider = {region='CN',realm='阿拉索',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Archaa:BAAALgAECgYJAgAAAA==.',
Ca='Cardinal:BAAALgADCgEJAQAAAA==.Cardinalnn:BAAALgAECgEJAQAAAA==.',
Ch='Change:BAAALgAECgQJBAAAAA==.Chastain:BAAALgAECgYJBgAAAA==.Chopxx:BAAALgAECgcJEQAAAA==.',
Cl='Clingnar:BAAALgAECgYJCQAAAA==.',
Co='Commnr:BAAALgAECgIJAgAAAA==.',
Cr='Crystal:BAAALgAECgUJCAAAAA==.',
Fl='Flyinbed:BAAALgAECgEJAQAAAA==.',
Gh='Ghorn:BAAALgAECgQJBAAAAA==.',
Ic='Iceberg:BAAALgAECgMJBQAAAA==.',
Ig='Ignn:BAABLgAFFH8HAAIBAAMJ3RnZDAAYAQABAAMJ3RnZDAAYAQAAAA==.',
Ij='Ije:BAAALgAECgQJBgAAAA==.',
Im='Imbakiller:BAAALgAECgcJCAAAAA==.',
Ko='Konoko:BAABLgAECn8UAAQCAAcJkBN9QACiAQACAAYJjRR9QACiAQADAAIJHAnTMABxAAAEAAEJng5ERgA0AAAAAA==.',
Ku='Kurtgodel:BAAALgADCgMJBAAAAA==.',
La='Lallana:BAAALgAFFAIJBAAAAA==.',
Le='Lemonade:BAAALgAECgYJAgAAAA==.',
Lo='Loveandhate:BAAALgAECgYJEQAAAA==.',
Lu='Luckylin:BAAALgAECgMJAwAAAA==.Lunacy:BAAALgAFFAQJBAAAAA==.Lunara:BAAALgAECgQJBAABLgAFFAQJAwAFAAAAAA==.',
Mi='Misskidney:BAAALgADCgcJBwAAAA==.',
Pa='Panda:BAAALgAECgQJBAAAAA==.',
Ph='Phelah:BAAALgAECgEJAgAAAA==.',
Ra='Ragnaba:BAAALgAECgUJDAAAAA==.',
Re='Reid:BAAALgAFFAMJAwAAAA==.',
Se='Sevenr:BAAALgAFFAEJAQAAAA==.',
Sk='Skade:BAAALgAECgcJBwABLgAFFAUJCgAGAGkdAA==.',
Su='Sushihurray:BAAALgAECgEJAQAAAA==.',
Th='Thesun:BAAALgAFFAEJAQAAAA==.',
Ti='Tiberian:BAAALgADCgMJAwAAAA==.',
Ts='Tsubasa:BAAALgADCgEJAQAAAA==.',
Tu='Tuscan:BAAALgAFFAQJBAAAAA==.',
Zh='Zhorn:BAAALgAFFAEJAQAAAA==.',
['一只']='一只大鲸鱼:BAAALgAECgEJAQAAAA==.一只小凶猫:BAAALgADCgEJAQAAAA==.',
['一圣']='一圣王一:BAABLgAFFH8HAAIHAAMJ/xQADQD9AAAHAAMJ/xQADQD9AAAAAA==.',
['一念']='一念地狱:BAAALgAECgQJBQAAAA==.',
['一邪']='一邪神一:BAAALgAECgQJAwAAAA==.',
['七月']='七月追风:BAAALgAECgEJAQAAAA==.',
['三宅']='三宅一生:BAABLgAFFH8HAAIHAAQJ9Q7ZDABFAQAHAAQJ9Q7ZDABFAQAAAA==.',
['三尖']='三尖两刃刀:BAAALgAECgEJAQAAAA==.',
['专打']='专打各种纯纯:BAAALgAECgQJBwAAAA==.',
['东邪']='东邪:BAAALgAECgYJDAAAAA==.',
['两岸']='两岸终将统一:BAAALgAECgYJBwAAAA==.',
['丨暗']='丨暗雪蓝痕丨:BAAALgAECgUJCAABLgAFFAYJCwAIAL0cAA==.',
['丶影']='丶影子丶:BAAALgAFFAIJAgABLgAFFAQJBAAFAAAAAA==.',
['丶漫']='丶漫漫慢慢丶:BAAALgAFFAEJAwAAAA==.',
['丶西']='丶西瓜粥:BAAALgAECgYJCgABLgAFFAYJFgAJAE8hAA==.',
['丷噜']='丷噜班:BAAALgAECgUJBgAAAA==.丷噜球球:BAAALgAFFAIJAwAAAA==.',
['丷昽']='丷昽丷:BAACLgAFFH8JAAMKAAUJkxUTFQD0AAAKAAMJWhMTFQD0AAALAAMJKxPmGgCZAAAuAAQKfyYAAwoACAkCIeASAJwCAAoACAkGIOASAJwCAAsABgndIN9AAKwBAAAA.',
['为芸']='为芸变神:BAAALgAECgYJBgAAAA==.',
['主攻']='主攻下三路:BAAALgAFFAIJAgAAAA==.',
['丿女']='丿女王大人:BAAALgAFFAQJBAAAAA==.',
['丿没']='丿没睡醒:BAAALgAECgYJCAAAAA==.',
['乀影']='乀影子乀:BAAALgAFFAQJBAAAAA==.',
['乐观']='乐观的摸摸头:BAAALgADCgEJAQAAAA==.',
['二十']='二十一个影子:BAAALgAECgcJEwABLgAFFAQJBAAFAAAAAA==.二十三个影子:BAAALgAECgYJDAABLgAFFAQJBAAFAAAAAA==.二十二个影子:BAAALgAECgYJDAABLgAFFAQJBAAFAAAAAA==.二十四个影子:BAAALgAECgYJBwABLgAFFAQJBAAFAAAAAA==.二十娭毑:BAAALgAECgYJDAAAAA==.',
['亣名']='亣名鼎鼎:BAAALgAECgUJCgAAAA==.',
['伍哒']='伍哒哒:BAAALgAECggJDAAAAA==.',
['优雅']='优雅的小圈圈:BAAALgAFFAMJAwAAAA==.',
['伴我']='伴我乄同行:BAAALgAECgEJAQAAAA==.',
['低调']='低调的大熊:BAAALgAECgEJAQAAAA==.',
['佐伯']='佐伯米莉亚:BAAALgAFFAQJBAAAAA==.',
['佐助']='佐助:BAAALgAECgEJAgAAAA==.',
['依丶']='依丶然:BAAALgAFFAIJAwAAAA==.',
['侦测']='侦测到在途的:BAAALgAFFAIJBAAAAA==.',
['傲气']='傲气十足:BAAALgAECgkJCQAAAA==.',
['克妮']='克妮雅影之歌:BAAALgAECgUJBQAAAA==.',
['兔先']='兔先森:BAAALgAECgEJAQAAAA==.',
['六道']='六道众生:BAAALgAECgEJAQAAAA==.',
['兰斯']='兰斯特:BAAALgAECgYJBgAAAA==.',
['兽皇']='兽皇:BAABLgAFFH8GAAILAAQJABB0BABbAQALAAQJABB0BABbAQAAAA==.',
['冫影']='冫影子冫:BAAALgAFFAQJBAAAAA==.',
['冬天']='冬天吃西瓜:BAAALgAECgMJBgAAAA==.',
['冰美']='冰美式:BAAALgAFFAIJAgAAAA==.',
['冷冷']='冷冷酱:BAABLgAFFH8NAAILAAQJ7RoiAQCKAQALAAQJ7RoiAQCKAQAAAA==.',
['冷酷']='冷酷暗猎:BAAALgAECgcJDwAAAA==.',
['凌风']='凌风追猎者:BAAALgAECgQJBAAAAA==.',
['凶狠']='凶狠汤汤:BAAALgAECgIJAgAAAA==.',
['初夏']='初夏的风:BAAALgAECgEJAwAAAA==.',
['刻俄']='刻俄柏:BAAALgAECgUJBQAAAA==.',
['剑语']='剑语墨尘:BAABLgAECn8WAAILAAkJ2hfVGgBmAgALAAkJ2hfVGgBmAgAAAA==.',
['十一']='十一个影子:BAABLgAFFH8IAAIJAAQJjw+0CQBVAQAJAAQJjw+0CQBVAQAAAA==.',
['十三']='十三个影子:BAAALgAECgYJDAABLgAFFAQJBAAFAAAAAA==.',
['十个']='十个影子:BAABLgAFFH8IAAIJAAQJYQoCBABSAQAJAAQJYQoCBABSAQAAAA==.',
['十二']='十二个影子:BAAALgAFFAQJBAAAAA==.',
['十分']='十分滴无情:BAAALgAECgYJCwAAAA==.',
['十四']='十四个影子:BAAALgAECgYJDAAAAA==.',
['南慕']='南慕容:BAAALgAECgkJBgAAAA==.',
['占戈']='占戈神:BAAALgADCgYJBgAAAA==.',
['卡拉']='卡拉永远欧克:BAAALgAECgQJBwAAAA==.',
['卡萨']='卡萨布蓝卡:BAAALgADCgUJBQAAAA==.',
['叁哒']='叁哒哒:BAACLgAFFH8GAAIGAAQJehEFFwBIAQAGAAQJehEFFwBIAQAuAAQKfxYAAgYACQmUGugWAPICAAYACQmUGugWAPICAAAA.',
['只会']='只会欧:BAAALgAFFAEJAQAAAA==.',
['名濑']='名濑美月:BAABLgAFFH8JAAIMAAMJcyR8CQBHAQAMAAMJcyR8CQBHAQAAAA==.',
['名無']='名無声:BAABLgAFFH8IAAINAAQJygiGCQDuAAANAAQJygiGCQDuAAAAAA==.',
['吴明']='吴明龙:BAAALgADCgcJCwAAAA==.',
['呆萌']='呆萌杭特:BAAALgAECgYJBgAAAA==.',
['周嗨']='周嗨:BAAALgAECgYJDQAAAA==.',
['咲恋']='咲恋救济院:BAAALgAECgMJAwAAAA==.',
['哈利']='哈利波特:BAAALgADCgYJBgAAAA==.',
['响马']='响马无双:BAAALgAECgYJDAAAAA==.',
['啊拉']='啊拉索:BAAALgADCgYJBgAAAA==.',
['回忆']='回忆依然:BAAALgAECgQJBgAAAA==.',
['因瑟']='因瑟瑞児:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光丶审判者:BAAALgAECgEJAQAAAA==.圣光之影:BAAALgAECgMJAwAAAA==.',
['圣殿']='圣殿大主教:BAAALgAECgQJBAAAAA==.',
['圣灵']='圣灵卵卵:BAAALgAECgUJBQAAAA==.',
['地狱']='地狱灬恶魔:BAAALgAECgUJCAAAAA==.',
['墨角']='墨角:BAAALgADCgYJBgAAAA==.',
['壹哒']='壹哒哒:BAAALgAFFAQJBAAAAA==.',
['夏港']='夏港港:BAAALgADCgEJAQAAAA==.',
['多多']='多多橙:BAABLgAECn8YAAIIAAYJQSDyZAAOAgAIAAYJQSDyZAAOAgAAAA==.',
['夜曰']='夜曰:BAAALgAFFAQJBAABLgAFFAUJEAAMAOAaAA==.',
['夜阑']='夜阑风雪舞:BAAALgAECgYJCQAAAA==.',
['大尾']='大尾巴雀仔:BAAALgAECgYJBgAAAA==.',
['天使']='天使也魔鬼:BAAALgADCgYJBgAAAA==.',
['天殇']='天殇残梦:BAAALgADCgMJAwAAAA==.',
['天牢']='天牢月:BAAALgAECgEJAQAAAA==.',
['太男']='太男:BAAALgAECgMJAwAAAA==.',
['失落']='失落之末日:BAAALgADCggJCAAAAA==.失落之湮灭:BAAALgADCgQJBQAAAA==.失落之黄昏:BAAALgAECgEJAQAAAA==.',
['头上']='头上没犄角:BAAALgAECgYJCAAAAA==.',
['夹夹']='夹夹两个头旁:BAAALgAECgkJCQAAAA==.',
['奉献']='奉献卡壳:BAAALgAECgEJAQAAAA==.',
['奥蕾']='奥蕾莉:BAAALgAFFAEJAQAAAA==.',
['奶吖']='奶吖奶:BAAALgADCgIJAgAAAA==.',
['奶茶']='奶茶优乐美:BAAALgAECgUJBQAAAA==.',
['奶萨']='奶萨新之助:BAAALgAECgEJAgAAAA==.',
['好名']='好名都狗起了:BAAALgADCgQJBgAAAA==.',
['孙梦']='孙梦熙:BAABLgAFFH8KAAIOAAMJXh9QDQAaAQAOAAMJXh9QDQAaAQAAAA==.',
['孤舟']='孤舟中指:BAAALgAECgUJBQAAAA==.',
['宠爱']='宠爱有嘉:BAAALgAECgEJAQAAAA==.',
['寒蝉']='寒蝉:BAAALgAECgYJCgAAAA==.',
['小島']='小島秋時:BAAALgAECgEJAQAAAA==.',
['尛罆']='尛罆栤:BAAALgAFFAEJAQAAAA==.',
['就叫']='就叫杨哥:BAAALgADCgcJBwAAAA==.',
['市一']='市一中李逍遥:BAAALgAECgIJAgAAAA==.',
['布达']='布达梅林:BAAALgADCgIJAgAAAA==.',
['帅刀']='帅刀客:BAAALgAECgEJAQAAAA==.',
['帝俊']='帝俊:BAAALgADCgYJBwAAAA==.',
['幸运']='幸运小粥:BAAALgADCgEJAQAAAA==.',
['幻影']='幻影小丸子:BAAALgAECgcJCAAAAA==.幻影流光:BAACLgAFFH8MAAIIAAQJlyCgBACLAQAIAAQJlyCgBACLAQAuAAQKfygAAggACAlbI18GAGoCAAgACAlbI18GAGoCAAEuAAUUBgkDAAUAAAAA.',
['强卡']='强卡:BAAALgADCgMJAwAAAA==.',
['影缝']='影缝者:BAAALgAECgkJEAAAAA==.',
['得吃']='得吃:BAAALgAECgIJAgAAAA==.',
['忒斯']='忒斯特賊賊:BAABLgAFFH8KAAIPAAUJwR8dAADuAQAPAAUJwR8dAADuAQAAAA==.',
['怞怍']='怞怍尒萠伖:BAAALgADCgMJAwAAAA==.',
['恢恢']='恢恢:BAAALgAECgYJDwAAAA==.',
['惟楚']='惟楚潇湘:BAAALgADCgMJBAAAAA==.',
['惹人']='惹人烦:BAAALgADCgYJBgAAAA==.',
['愁眠']='愁眠江:BAABLgAECn8TAAIHAAcJPh+AOQA9AgAHAAcJPh+AOQA9AgAAAA==.',
['愤怒']='愤怒之锤子:BAAALgAECgIJAgAAAA==.',
['懒懒']='懒懒的冰狼:BAAALgAECgIJAgAAAA==.',
['我惹']='我惹你的吗:BAAALgAFFAEJAQAAAA==.',
['我是']='我是灵牙:BAAALgAECgEJAQAAAA==.',
['戴安']='戴安娜琼斯:BAAALgAECgEJAwAAAA==.',
['打麻']='打麻将赚点卡:BAAALgAECgQJBgAAAA==.',
['折耳']='折耳猫:BAAALgAECggJCAAAAA==.',
['拳少']='拳少:BAAALgAECgMJAwAAAA==.',
['掌心']='掌心的凌乱:BAAALgAECgUJBgAAAA==.',
['旋涡']='旋涡刘英:BAAALgAECgEJAgAAAA==.',
['无危']='无危不至:BAAALgAECgEJAQAAAA==.',
['无情']='无情小骑士:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌既俊朗:BAAALgAECgEJAQAAAA==.',
['无灬']='无灬魔:BAAALgAFFAIJBAAAAA==.',
['无纹']='无纹萌萌:BAAALgAECgEJAgAAAA==.',
['无脑']='无脑:BAAALgAECgMJAwAAAA==.',
['时光']='时光乄荏苒:BAAALgAECgYJBwAAAA==.',
['昏黄']='昏黄柳影斜:BAAALgADCgUJBQABLgAECgcJEQAFAAAAAA==.',
['星爵']='星爵:BAAALgAECgcJEwAAAA==.',
['星空']='星空下一棵树:BAAALgAECgcJCQAAAA==.',
['春生']='春生:BAAALgAECgEJAQAAAA==.',
['暗箭']='暗箭飘零:BAAALgAECgYJBgAAAA==.',
['暗血']='暗血兰痕:BAAALgAECgYJBgAAAA==.',
['暗鸦']='暗鸦:BAAALgADCgkJCgAAAA==.',
['最佳']='最佳床友:BAAALgADCgcJBwAAAA==.',
['朱诺']='朱诺:BAAALgAFFAEJAQAAAA==.',
['杀手']='杀手二号:BAAALgAECgUJCAAAAA==.',
['桔子']='桔子飘香:BAAALgAECgQJCAAAAA==.',
['梵高']='梵高先生丶:BAAALgAECgEJAQAAAA==.',
['楪祈']='楪祈公主:BAAALgAECgUJBQAAAA==.',
['樱桃']='樱桃小丸犊子:BAAALgAECgcJBgAAAA==.',
['欧媓']='欧媓:BAAALgAECgcJEAAAAA==.',
['武林']='武林至尊:BAAALgADCgEJAQAAAA==.',
['死牧']='死牧板:BAAALgADCgMJBgAAAA==.',
['死骑']='死骑乄信仰:BAAALgAECgYJBwAAAA==.',
['死魂']='死魂小超市:BAAALgADCgEJAQAAAA==.死魂灵:BAAALgAECgYJCAAAAA==.',
['氵影']='氵影子氵:BAAALgAFFAQJBAAAAA==.',
['沒心']='沒心沒肺:BAAALgAECgQJBQAAAA==.',
['洛奇']='洛奇巴尔博:BAAALgAECgkJCQAAAA==.',
['洱语']='洱语:BAAALgAECgEJAQAAAA==.',
['浪漫']='浪漫无用:BAAALgAECgYJCQAAAA==.浪漫至死不渝:BAAALgAECgEJAgAAAA==.',
['浮世']='浮世乄之绘:BAAALgAECgIJAgAAAA==.',
['淖尔']='淖尔:BAAALgAECgEJAQAAAA==.',
['混凝']='混凝土:BAABLgAECn8WAAIQAAkJSSB3BQAUAwAQAAkJSSB3BQAUAwABLgAFFAYJCwAQAPEZAA==.',
['清风']='清风不羁:BAAALgADCgEJAQAAAA==.',
['港岛']='港岛妹夫:BAABLgAECn8VAAIIAAcJCRI8gwDLAQAIAAcJCRI8gwDLAQAAAA==.',
['溜溜']='溜溜蛋:BAABLgAECn8UAAIHAAkJtBVfJgCMAgAHAAkJtBVfJgCMAgAAAA==.',
['潇湘']='潇湘风笛:BAAALgAECgMJAwAAAA==.',
['潜伏']='潜伏的伤:BAAALgADCgUJBQAAAA==.',
['潶天']='潶天灬小僧:BAAALgAFFAIJAgAAAA==.',
['灬没']='灬没睡醒:BAAALgAECgEJAgAAAA==.',
['灰色']='灰色的雾:BAAALgAECgcJDwAAAA==.',
['無休']='無休鋒刃:BAAALgAECgQJBgABLgAFFAQJDQALAO0aAA==.',
['焮燃']='焮燃:BAABLgAECn8hAAIGAAcJMhzfFACFAQAGAAcJMhzfFACFAQAAAA==.',
['煎猪']='煎猪排超人:BAAALgAECgcJBgAAAA==.',
['熊仔']='熊仔粑粑:BAAALgADCgUJBQAAAA==.',
['熊少']='熊少:BAAALgAECgcJCwAAAA==.',
['爬山']='爬山醋男:BAAALgAECgUJBQAAAA==.',
['爱笑']='爱笑的眼睛:BAAALgAECgQJAQAAAA==.',
['牛玄']='牛玄德:BAAALgADCgcJBwAAAA==.',
['牛肉']='牛肉丸零号:BAABLgAFFH8NAAMJAAUJyBmOAgDYAQAJAAUJyBmOAgDYAQARAAEJ4xOKBQBiAAAAAA==.',
['狂抽']='狂抽男模嫩臀:BAAALgAECgYJBgAAAA==.',
['猛咩']='猛咩:BAAALgAECgIJBAAAAA==.',
['猛蛇']='猛蛇下山:BAAALgAFFAEJAQAAAA==.',
['猫一']='猫一:BAACLgAFFH8IAAILAAQJUBELBQBTAQALAAQJUBELBQBTAQAuAAQKfx0AAgsACQnCG/ALAOICAAsACQnCG/ALAOICAAAA.',
['猫二']='猫二:BAABLgAECn8dAAILAAkJUBWVFgCEAgALAAkJUBWVFgCEAgAAAA==.',
['猫五']='猫五:BAAALgAECggJAwAAAA==.',
['猫叁']='猫叁:BAAALgAECgMJAwAAAA==.',
['猫四']='猫四:BAABLgAECn8UAAILAAkJkRsaCQADAwALAAkJkRsaCQADAwAAAA==.',
['猫小']='猫小白:BAABLgAECn8lAAILAAgJBiMABQA9AwALAAgJBiMABQA9AwAAAA==.',
['猫猫']='猫猫女:BAAALgAECgEJAQAAAA==.',
['玉皇']='玉皇:BAABLgAECn8fAAILAAkJehmqEgCiAgALAAkJehmqEgCiAgAAAA==.玉皇一号:BAAALgAECgkJDgAAAA==.玉皇三号:BAAALgAECgcJCgAAAA==.玉皇五号:BAABLgAECn8UAAILAAkJYBcqHABdAgALAAkJYBcqHABdAgAAAA==.玉皇四号:BAAALgAECgcJDQAAAA==.',
['王者']='王者再临:BAAALgAECgEJAQAAAA==.',
['玛莉']='玛莉亚:BAAALgAECgcJBwAAAA==.',
['玫瑰']='玫瑰气泡水:BAAALgADCgEJAQAAAA==.',
['玲瓏']='玲瓏:BAAALgAECgEJAQAAAA==.',
['白银']='白银幼儿园长:BAAALgADCgEJAQAAAA==.',
['的身']='的身份的:BAAALgAECgcJEwAAAA==.',
['皮卡']='皮卡丘酱:BAAALgAECgMJAwAAAA==.',
['睡到']='睡到自然醒:BAAALgAECgEJAQAAAA==.',
['神圣']='神圣的礼拜天:BAAALgAFFAIJAQAAAA==.',
['神宠']='神宠箭灵:BAAALgADCgUJBQAAAA==.',
['神拳']='神拳无敌:BAAALgAECgEJAQAAAA==.',
['神话']='神话之幻影:BAAALgAECgYJBgAAAA==.',
['福氣']='福氣满满:BAAALgAFFAIJBAAAAA==.',
['秋池']='秋池渊:BAAALgAECgUJBQAAAA==.',
['秋色']='秋色怡人:BAAALgAECgQJBgAAAA==.',
['稳了']='稳了:BAAALgAECgUJBgAAAA==.',
['空崎']='空崎日奈:BAAALgAECgEJAQAAAA==.',
['米拉']='米拉娜:BAAALgAECgEJAQAAAA==.',
['粉色']='粉色心情:BAAALgAECgQJBAAAAA==.',
['糖门']='糖门爬:BAAALgAECgUJBQAAAA==.',
['紫龙']='紫龙:BAAALgAECgYJBwAAAA==.',
['绯村']='绯村剑心:BAAALgAECgYJCwAAAA==.',
['维什']='维什戴尔:BAAALgAECgYJBgAAAA==.',
['羅賓']='羅賓漢:BAAALgAECgcJDQAAAA==.',
['羲和']='羲和:BAACLgAFFH8QAAIQAAUJ+hZ/BQCEAQAQAAUJ+hZ/BQCEAQAuAAQKfx0AAxAACAmpHqkaAD8CABAACAmpHqkaAD8CAAcAAQlzE0EwAUIAAAAA.',
['老弟']='老弟棒:BAAALgAECgEJAQAAAA==.',
['肆哒']='肆哒哒:BAAALgAFFAQJBAAAAA==.',
['胥高']='胥高:BAAALgAECgQJBAAAAA==.',
['自摸']='自摸二五八:BAAALgAFFAEJAQAAAA==.',
['自由']='自由的灵魂:BAAALgADCgMJAwAAAA==.',
['艾利']='艾利亚纳:BAABLgAECn8UAAILAAcJfB7JHgBNAgALAAcJfB7JHgBNAgAAAA==.',
['艾美']='艾美拉达斯:BAAALgAECgUJBQAAAA==.',
['花丶']='花丶逝無:BAAALgAECgUJBgAAAA==.',
['花空']='花空烟水流:BAAALgAECgUJCQAAAA==.',
['苍穹']='苍穹蔚蓝:BAAALgAECgcJBwABLgAFFAcJEgASAEEVAA==.',
['萤石']='萤石:BAAALgADCgYJBgAAAA==.',
['蒙师']='蒙师切:BAAALgAECgEJAQAAAA==.',
['蕾尔']='蕾尔提斯:BAAALgAECgEJAgAAAA==.',
['薛定']='薛定谔丨喵丨:BAAALgAFFAEJAQABLgAFFAUJDQAKANsVAA==.',
['藤虎']='藤虎:BAAALgAECgEJAQAAAA==.',
['蘭哥']='蘭哥丶:BAAALgAFFAIJAwAAAA==.',
['蜗牛']='蜗牛漫步:BAAALgAECgEJAQAAAA==.',
['血色']='血色芭蕾:BAAALgADCgYJBAAAAA==.',
['西北']='西北狼:BAAALgADCgMJAwAAAA==.',
['调野']='调野太祥:BAABLgAECn8UAAIHAAgJpRaePwAnAgAHAAgJpRaePwAnAgAAAA==.',
['豌杂']='豌杂:BAACLgAFFH8MAAIGAAQJZxy3BQBgAQAGAAQJZxy3BQBgAQAuAAQKfyAAAgYACQlRHU8bANoCAAYACQlRHU8bANoCAAAA.',
['贰哒']='贰哒哒:BAAALgAFFAIJAgAAAA==.',
['赵佳']='赵佳蕊:BAAALgAECgYJBgAAAA==.',
['踏天']='踏天猎穹斩:BAAALgAECgYJCwAAAA==.',
['輪回']='輪回镜:BAABLgAFFH8FAAIQAAUJ2wdRBgBzAQAQAAUJ2wdRBgBzAQAAAA==.',
['輪符']='輪符雨:BAAALgAECgYJDwAAAA==.',
['边渡']='边渡友次子:BAAALgADCgMJAwAAAA==.',
['远野']='远野汉娜:BAAALgAECgYJBgAAAA==.',
['迪奥']='迪奥:BAAALgAECgkJDwAAAA==.',
['迷茫']='迷茫小刀:BAAALgADCgEJAQAAAA==.迷茫小猎:BAAALgAECgUJAgAAAA==.',
['迷路']='迷路的风筝:BAACLgAFFH8HAAIGAAIJ5RvnHgCkAAAGAAIJ5RvnHgCkAAAuAAQKfx0AAgYACQlJHLwTAAQDAAYACQlJHLwTAAQDAAAA.',
['逆蝶']='逆蝶:BAABLgAFFH8GAAMTAAIJ4h47BwDBAAATAAIJXB47BwDBAAAUAAEJMRt1IABaAAAAAA==.',
['邦德']='邦德落地:BAAALgAECgkJCgAAAA==.',
['醉雨']='醉雨听月:BAABLgAFFH8GAAIVAAMJwA8KCADoAAAVAAMJwA8KCADoAAAAAA==.',
['铁甲']='铁甲铱然在:BAAALgAECgQJBAAAAA==.',
['镜天']='镜天遥:BAAALgAECgQJCAAAAA==.',
['门前']='门前糖果店:BAAALgAECgcJEQAAAA==.',
['阿克']='阿克苏啦:BAAALgAECgMJBQAAAA==.',
['阿华']='阿华:BAAALgAECgMJBAAAAA==.',
['阿尔']='阿尔达莉雅:BAAALgAECgEJAQAAAA==.',
['阿斯']='阿斯兰精灵:BAAALgAECgcJEQAAAA==.',
['阿玛']='阿玛妮:BAAALgAECgYJBgAAAA==.',
['陆哒']='陆哒哒:BAABLgAECn8VAAIGAAkJ4RmiHQDOAgAGAAkJ4RmiHQDOAgAAAA==.',
['陆奥']='陆奥八云:BAAALgAECgIJBAAAAA==.',
['陈小']='陈小圣:BAAALgADCgEJAQAAAA==.',
['雨晴']='雨晴亦相隨:BAAALgAECgUJBQAAAA==.',
['雲過']='雲過無痕:BAAALgAECgUJBgAAAA==.',
['霜刃']='霜刃舞者:BAAALgADCgMJAwAAAA==.',
['霜雪']='霜雪皮卡丘:BAAALgAECgUJBwAAAA==.',
['霸少']='霸少:BAAALgAECgMJBQAAAA==.',
['青猫']='青猫咖喱:BAAALgAECgYJEQAAAA==.',
['风云']='风云娱乐:BAAALgADCgMJAwAAAA==.',
['风定']='风定花犹落:BAAALgADCgMJAwAAAA==.',
['风诉']='风诉:BAAALgAECgcJBwAAAA==.',
['飞来']='飞来飞去天天:BAAALgAECgIJAgAAAA==.',
['马子']='马子吗:BAAALgADCgMJAwAAAA==.',
['马维']='马维影之歌:BAAALgAFFAEJAQAAAA==.',
['马老']='马老熊:BAACLgAFFH8KAAMWAAQJMg94DgD4AAAWAAMJTBJ4DgD4AAABAAQJhBrFDwDtAAAuAAQKfxYAAxYABwk/HooaADACABYABgkPIooaADACAAEABwnkF4IzANsBAAAA.',
['高考']='高考零分:BAAALgAECgIJAwABLgAECgcJEQAFAAAAAA==.',
['魅雪']='魅雪邪姬:BAAALgAECgEJAQAAAA==.',
['鲸让']='鲸让我照望海:BAAALgADCgEJAQAAAA==.',
['鸿品']='鸿品德一:BAABLgAECn8WAAUXAAcJuAvjGQAqAQAXAAYJTAvjGQAqAQAYAAUJ2QldIACbAAAWAAQJHAVCZACQAAABAAEJfAEM7AAWAAAAAA==.',
['麦恬']='麦恬:BAAALgAECgcJCQAAAA==.',
['黄药']='黄药師:BAAALgADCgUJBQAAAA==.',
['黎邪']='黎邪的旅程:BAAALgAECgYJBgAAAA==.',
['黑的']='黑的发光:BAAALgAFFAQJBAAAAA==.',
['齐天']='齐天鸿运:BAABLgAFFH8NAAISAAUJvg+lBAChAQASAAUJvg+lBAChAQAAAA==.',
['龍仔']='龍仔:BAAALgAECgYJCAAAAA==.',
['龍少']='龍少:BAAALgADCgEJAgAAAA==.',
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
