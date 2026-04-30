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

local lookup = {'Warrior-Protection','Monk-Brewmaster','DeathKnight-Unholy','Unknown-Unknown','Priest-Shadow','Mage-Frost','Shaman-Elemental','Shaman-Restoration','DemonHunter-Devourer','Warlock-Demonology','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Warlock-Destruction','Evoker-Preservation','Paladin-Retribution','Paladin-Holy','Evoker-Augmentation','Druid-Balance','Rogue-Outlaw','DeathKnight-Blood','Druid-Guardian','Druid-Restoration','Druid-Feral','Warrior-Fury',}
local provider = {region='CN',realm='风行者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adioscowboy:BAABLgAFFH8IAAIBAAUJPRRoAgA4AQABAAUJPRRoAgA4AQABLgAFFAUJCQACAEEeAA==.',
Al='Alleriaa:BAAALgAECgYJBgABLgAFFAMJCgADAB4XAA==.Allin:BAAALgAFFAQJBAABLgAFFAYJAwAEAAAAAA==.',
Am='Ammy:BAAALgAECgEJAQAAAA==.Amy:BAAALgAECgcJDwAAAA==.',
Ba='Baby:BAAALgAECgkJBwAAAA==.',
Ca='Cammy:BAAALgADCgYJBgAAAA==.Caramella:BAAALgAECgcJBwAAAA==.Catmini:BAAALgAECgEJAQAAAA==.',
Cb='Cbob:BAAALgAFFAEJAQAAAA==.',
Ch='Chinesekf:BAAALgAECgEJAQAAAA==.',
Cy='Cytheria:BAAALgAFFAEJAQAAAA==.',
Da='Dark:BAAALgAFFAEJAQAAAA==.',
Dd='Ddlymin:BAAALgAECgcJBgAAAA==.',
Do='Domnmic:BAAALgAECgIJAwAAAA==.',
El='Eleuther:BAAALgAECgcJBwAAAA==.',
En='Ensiferum:BAAALgADCgIJAgAAAA==.',
Es='Escanor:BAAALgAECgUJCgAAAA==.',
Fe='Ferrary:BAAALgADCgYJBgAAAA==.',
Ga='Gawain:BAAALgAECgEJAQAAAA==.',
Go='Goku:BAAALgAECgMJAwAAAA==.Goodfaith:BAAALgADCgcJBwAAAA==.',
Gu='Gutso:BAAALgAECgkJBAAAAA==.',
Im='Imgirgir:BAAALgAECgcJCAAAAA==.',
Jo='Joshwupang:BAABLgAFFH8MAAIFAAQJzCFXAQB7AQAFAAQJzCFXAQB7AQAAAA==.',
Ka='Kafka:BAAALgAECgYJBAAAAA==.',
Ki='Kitzwupang:BAAALgAFFAIJBAAAAA==.',
Ko='Korospo:BAAALgAECgIJAgAAAA==.',
Kr='Kreay:BAAALgAECgIJAQAAAA==.',
La='Lastxuan:BAAALgAFFAIJAwAAAA==.Lays:BAAALgADCgYJBgAAAA==.',
Ma='Maboroshi:BAAALgAECgcJDgAAAA==.Magna:BAAALgADCgUJBQAAAA==.Manta:BAAALgAECgUJBQAAAA==.Mass:BAAALgADCggJCAAAAA==.',
Me='Messmer:BAABLgAECn8gAAIDAAgJqRFVGwBXAQADAAgJqRFVGwBXAQAAAA==.',
Mo='Mofli:BAAALgADCgYJCQAAAA==.',
No='Noamd:BAAALgADCgIJAQAAAA==.',
Pa='Palette:BAAALgAECgcJEQAAAA==.',
Pe='Peekaboo:BAAALgADCgUJBQAAAA==.',
Pl='Plzfthx:BAECLgAFFH8JAAIGAAMJsCD4EwATAQAGAAMJsCD4EwATAQAuAAQKfxwAAgYABwluIaI1AJ0CAAYABwluIaI1AJ0CAAAA.',
Po='Popcornbaby:BAAALgAECgUJBQAAAA==.',
Qp='Qp:BAAALgAECgUJCQAAAA==.',
Re='Rebornlyqaq:BAAALgAFFAIJAwAAAA==.Residualsoul:BAABLgAFFH8NAAIHAAUJjhyiBQCBAQAHAAUJjhyiBQCBAQAAAA==.Resoul:BAACLgAFFH8IAAIHAAQJOxp/AgBjAQAHAAQJOxp/AgBjAQAuAAQKfxQAAwcACAmWGRgfABcCAAcACAmWGRgfABcCAAgABglyFfpMAE8BAAAA.Reunravel:BAABLgAFFH8HAAIHAAQJuxfhEgDAAAAHAAQJuxfhEgDAAAAAAA==.',
Ri='Rimeland:BAAALgAECgYJEAAAAA==.',
Sa='Sakiko:BAAALgAECgIJAgAAAA==.',
Se='Seet:BAAALgAFFAEJAQABLgAFFAIJBQAJAG8HAA==.',
Sf='Sflash:BAAALgAECgQJBQAAAA==.',
St='Strommage:BAABLgAFFH8MAAIGAAMJKxacKQAOAQAGAAMJKxacKQAOAQAAAA==.',
Su='Sucyy:BAAALgADCgIJAwAAAA==.',
Sy='Sylleria:BAAALgAECgkJDwABLgAFFAYJFwAKAOIkAA==.',
Ta='Tacy:BAAALgAECgMJAwAAAA==.',
Ti='Tigerw:BAAALgAFFAEJAQABLgAFFAIJAwAEAAAAAA==.',
Us='Usettn:BAAALgAECgIJBAAAAA==.Usezttv:BAAALgADCgEJAQAAAA==.',
Ve='Veerene:BAAALgAECgkJEgAAAA==.',
Wu='Wuxin:BAAALgAECggJDAAAAA==.',
Xl='Xlight:BAACLgAFFH8HAAIGAAQJHwsWIQA+AQAGAAQJHwsWIQA+AQAuAAQKfxUAAgYACAm+HEMzAKYCAAYACAm+HEMzAKYCAAAA.',
Zz='Zzb:BAAALgAECgQJBgAAAA==.',
['一剑']='一剑灬无痕:BAAALgAECgYJAQAAAA==.一剑灬無痕:BAAALgAFFAEJAQAAAA==.一剑灬邪魅:BAAALgAFFAEJAQAAAA==.一剑灬锋芒:BAAALgAECgcJDAAAAA==.一剑灬风雪:BAAALgAECgUJBQAAAA==.一剑灬风霜:BAAALgAECgYJCQAAAA==.一剑灬魅舞:BAAALgAECgYJEQAAAA==.',
['一哚']='一哚小黄錵:BAAALgAFFAIJAgAAAA==.',
['一般']='一般给力:BAAALgAECgQJBAAAAA==.',
['一话']='一话三麻灬瑟:BAABLgAFFH8FAAMLAAUJzx0UAwAjAQALAAQJpR4UAwAjAQAMAAEJTRtSGABjAAAAAA==.',
['一顿']='一顿毒奶:BAAALgAECgYJEAAAAA==.',
['丛魂']='丛魂:BAAALgAECgYJBgAAAA==.',
['丨冲']='丨冲锋丨:BAAALgAECgEJAQAAAA==.',
['丨瘸']='丨瘸子:BAAALgAFFAQJBAAAAA==.',
['丷小']='丷小妮子巛:BAAALgAECgcJCwAAAA==.',
['为了']='为了一百一十:BAAALgAECgcJBwAAAA==.',
['举起']='举起手唻:BAAALgAECgEJAgAAAA==.',
['丿幻']='丿幻世:BAABLgAFFH8FAAMJAAIJbwfCLACTAAAJAAIJbwfCLACTAAANAAEJIAH+DwBAAAAAAA==.',
['乄笑']='乄笑寳寶灬:BAAALgAFFAEJAQAAAA==.',
['九九']='九九堂:BAAALgAECgkJCQABLgAECgkJFwABAMAcAA==.',
['也就']='也就只会转了:BAAALgAFFAIJAgAAAA==.',
['亵渎']='亵渎之力:BAABLgAFFH8IAAIDAAQJ0RSbEQBbAQADAAQJ0RSbEQBbAQAAAA==.',
['伊格']='伊格尼斯:BAAALgAECgUJBgAAAA==.',
['传奇']='传奇饼干:BAAALgAECgcJCAAAAA==.',
['作死']='作死无底线:BAAALgAFFAIJAwAAAA==.',
['你们']='你们看我伤害:BAABLgAFFH8IAAMMAAQJGCHIDgDWAAALAAMJURg5EwAJAQAMAAIJoCPIDgDWAAAAAA==.',
['你卡']='你卡上了吗:BAABLgAFFH8IAAMLAAQJwh4SEQAlAQALAAMJVh8SEQAlAQAMAAEJBR3cHwBhAAAAAA==.',
['你懂']='你懂歌姬芭:BAAALgAECgQJBAAAAA==.',
['你是']='你是临时工吗:BAABLgAFFH8IAAMLAAQJKR6tEAAqAQALAAMJwB6tEAAqAQAMAAEJZBzNHwBhAAAAAA==.',
['停云']='停云:BAAALgAECgUJBQAAAA==.',
['傲雪']='傲雪残月:BAAALgAECgEJAgAAAA==.',
['元素']='元素之誓:BAAALgAECgEJAQAAAA==.',
['兔学']='兔学渣:BAAALgAECgQJBQAAAA==.',
['兮梓']='兮梓丶:BAAALgAECgIJAgAAAA==.',
['冥凰']='冥凰:BAABLgAECn8aAAMOAAcJxBwkBwBYAgAOAAcJxBwkBwBYAgAKAAEJRRbKWwBKAAAAAA==.',
['冰与']='冰与火之泪:BAAALgADCgIJAgAAAA==.',
['冰火']='冰火精灵:BAAALgAECgEJAQAAAA==.',
['冰霜']='冰霜序曲:BAAALgAECgkJCQABLgAFFAIJBwAGAOANAA==.',
['凛冬']='凛冬将至:BAAALgAECgEJAQAAAA==.',
['凯尔']='凯尔撒思:BAAALgADCgEJAQAAAA==.',
['出鞘']='出鞘狂刃:BAACLgAFFH8GAAIBAAMJiwvsCADEAAABAAMJiwvsCADEAAAuAAQKfxwAAgEACAn3GfIMADwCAAEACAn3GfIMADwCAAAA.',
['北斗']='北斗神拳:BAAALgAECgEJAgAAAA==.',
['千宵']='千宵待尽:BAABLgAFFH8IAAIPAAMJ8SE7CwA2AQAPAAMJ8SE7CwA2AQAAAA==.',
['千早']='千早爱音:BAABLgAFFH8PAAIQAAQJYBqwBABeAQAQAAQJYBqwBABeAQAAAA==.',
['千秋']='千秋亦永恒:BAAALgAECgYJCgAAAA==.',
['华年']='华年:BAACLgAFFH8RAAIFAAUJ8SJdAQAcAgAFAAUJ8SJdAQAcAgAuAAQKfyQAAgUACQmlJOoAANADAAUACQmlJOoAANADAAAA.',
['压力']='压力大我先拿:BAABLgAFFH8HAAMLAAUJLRaYAwALAQALAAQJgBaYAwALAQAMAAIJqBZiEwC1AAAAAA==.',
['双魚']='双魚理:BAABLgAFFH8GAAIGAAQJ7x10NQDBAAAGAAQJ7x10NQDBAAABLgAFFAYJCwAGAMUbAA==.',
['发飙']='发飙的小牛:BAAALgAECgQJBAAAAA==.',
['可爱']='可爱:BAAALgAFFAEJAgAAAA==.',
['同林']='同林风:BAAALgAECgQJBAAAAA==.',
['后悔']='后悔毒药:BAAALgAECgQJBQAAAA==.',
['吹梦']='吹梦无踪:BAAALgAECgcJDgAAAA==.',
['呜呜']='呜呜你回来了:BAAALgAFFAEJAQAAAA==.',
['周灬']='周灬踏岚:BAAALgADCgUJBQAAAA==.',
['哈酒']='哈酒:BAAALgADCgcJDAABLgAFFAIJBAAEAAAAAA==.',
['哞哞']='哞哞小小母牛:BAAALgAECgIJAwAAAA==.',
['哦迪']='哦迪凯:BAABLgAFFH8HAAIDAAQJiBzhBABoAQADAAQJiBzhBABoAQABLgAFFAUJDQACAL4aAA==.',
['哪个']='哪个防骑:BAAALgAECgUJBwAAAA==.',
['啊哒']='啊哒哒鸭:BAAALgAECgEJAQAAAA==.',
['啤酒']='啤酒:BAAALgAFFAEJAQAAAA==.',
['喜欢']='喜欢在后面:BAAALgADCgEJAQAAAA==.',
['喵了']='喵了个咪呀:BAAALgAECgYJBgAAAA==.',
['喵喵']='喵喵不是猫猫:BAAALgAFFAIJAwAAAA==.',
['嘿歌']='嘿歌:BAAALgAFFAEJAQAAAA==.',
['噩梦']='噩梦:BAAALgAFFAEJAQAAAA==.',
['图南']='图南:BAABLgAFFH8KAAIBAAUJIQ9+AwBXAQABAAUJIQ9+AwBXAQAAAA==.',
['土豆']='土豆吃牛肉:BAAALgAECgEJAQAAAA==.土豆土豆:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光仲裁:BAABLgAFFH8IAAIRAAQJTAq4CgAxAQARAAQJTAq4CgAxAQAAAA==.圣光猫咪:BAAALgADCgYJBgAAAA==.圣光逐晨者:BAABLgAFFH8IAAIRAAQJBw5xBABOAQARAAQJBw5xBABOAQAAAA==.圣光闪瞎狗眼:BAAALgAFFAQJBAAAAA==.',
['墨方']='墨方:BAAALgAECgQJCQAAAA==.',
['墨蕾']='墨蕾莉娅:BAAALgAECgYJCgAAAA==.',
['夏诗']='夏诗:BAAALgAECgUJBQAAAA==.',
['夕照']='夕照深秋雨:BAAALgADCgcJBwAAAA==.',
['夜羽']='夜羽:BAABLgAFFH8SAAILAAYJDhq/AwAIAgALAAYJDhq/AwAIAgAAAA==.',
['夜聆']='夜聆凤:BAAALgAECgIJAgAAAA==.夜聆风:BAAALgADCgEJAQAAAA==.',
['大姨']='大姨妈归来:BAAALgAFFAIJAgAAAA==.',
['大怀']='大怀言者:BAAALgAFFAEJAQAAAA==.',
['大花']='大花卷儿:BAAALgAECgMJAwAAAA==.',
['大阔']='大阔:BAAALgAECgkJCQAAAA==.',
['大魔']='大魔棒:BAAALgAECgYJBwAAAA==.',
['天之']='天之伤:BAAALgADCgEJAQAAAA==.',
['天使']='天使出演:BAAALgAECgEJAQAAAA==.天使安琪儿:BAAALgAECgYJBgAAAA==.天使安琪兒:BAAALgAECgcJAwAAAA==.天使宝宝:BAAALgAECgIJAwAAAA==.',
['天涯']='天涯风云:BAAALgAECgEJAgAAAA==.',
['天空']='天空熊猫:BAAALgAECgEJAgAAAA==.',
['太初']='太初星辉:BAAALgAECgkJBgABLgAFFAQJCAASAE4QAA==.',
['失憶']='失憶蝴蝶:BAAALgAECgQJBAAAAA==.',
['夹心']='夹心跳跳糖:BAAALgAECgEJAQAAAA==.',
['夺命']='夺命汾:BAAALgAECgUJBQAAAA==.',
['奎尔']='奎尔的娜塔莎:BAAALgAECgcJBwAAAA==.',
['奥类']='奥类莉亚:BAAALgAECgEJAQAAAA==.',
['奥雷']='奥雷莉亚斯:BAAALgAECgQJBgAAAA==.',
['奶酪']='奶酪不甜:BAAALgAECgYJCwAAAA==.',
['如意']='如意小阿发:BAAALgAECgQJBQAAAA==.',
['妮珂']='妮珂基德曼:BAABLgAECn8YAAMMAAkJLiG/AwBVAwAMAAkJLiG/AwBVAwALAAIJygEEgwA7AAAAAA==.',
['娇花']='娇花她们:BAAALgAECgYJEQAAAA==.',
['孤丨']='孤丨影:BAAALgAFFAMJAwAAAA==.',
['孤独']='孤独跟随者:BAAALgADCgQJBAAAAA==.',
['宅屠']='宅屠:BAAALgAECgQJBAAAAA==.',
['宇神']='宇神:BAABLgAFFH8HAAIGAAQJwAtUIQA8AQAGAAQJwAtUIQA8AQAAAA==.',
['安吉']='安吉拉:BAAALgAFFAIJAgAAAA==.',
['安娜']='安娜米露:BAAALgAECgIJAgAAAA==.',
['小乐']='小乐乐可爱:BAAALgAECgEJAQAAAA==.',
['小小']='小小先生:BAAALgADCgEJAQAAAA==.小小光:BAAALgAECgMJAwAAAA==.',
['小忍']='小忍:BAAALgADCgYJBgAAAA==.',
['小晚']='小晚好:BAAALgAECgEJAQAAAA==.',
['小满']='小满兜:BAAALgAECgEJAQAAAA==.',
['小魂']='小魂儿财团:BAAALgAECgEJAgAAAA==.',
['少爷']='少爷福福:BAAALgADCgIJAgAAAA==.',
['尤里']='尤里安:BAAALgADCgUJBQABLgAFFAMJDAAGACsWAA==.',
['尨影']='尨影:BAAALgAECgUJBQAAAA==.',
['就是']='就是这个术:BAABLgAFFH8FAAIKAAMJahw9GQAnAQAKAAMJahw9GQAnAQABLgAFFAMJDAAGACsWAA==.',
['山林']='山林风火:BAAALgAECgkJAgAAAA==.',
['山魂']='山魂:BAAALgADCgYJBgAAAA==.',
['巴巴']='巴巴波伊:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔芙蕾雅:BAAALgADCgEJAQAAAA==.',
['希沃']='希沃斯:BAAALgAECgUJBwAAAA==.',
['希瓦']='希瓦娜斯:BAAALgAECgIJAgAAAA==.',
['希达']='希达:BAAALgADCgUJBQAAAA==.',
['带宠']='带宠狂徒:BAAALgADCgMJAwAAAA==.',
['幸运']='幸运的吉米丶:BAAALgAECgEJAgAAAA==.',
['幼丶']='幼丶女控:BAAALgAECgEJAQAAAA==.',
['建材']='建材批发小王:BAAALgAECgYJBgAAAA==.',
['弑乄']='弑乄無双:BAAALgAECgQJBQAAAA==.',
['彩虹']='彩虹捕手:BAAALgAECgQJBAABLgAFFAQJDgAKAMYgAA==.',
['彼岸']='彼岸曼珠沙华:BAAALgAECgIJAgAAAA==.',
['快樂']='快樂風男:BAAALgAECgYJBgAAAA==.',
['怒之']='怒之鬼眼:BAAALgAECgQJBAAAAA==.',
['性感']='性感小野狗:BAAALgADCgYJBgAAAA==.性感的大哥:BAAALgADCgUJBwAAAA==.',
['恶魔']='恶魔在哭泣:BAAALgAECgYJBgABLgAECgcJHgALAPYVAA==.恶魔的猫猫:BAAALgAECgEJAgAAAA==.恶魔蜀黍:BAABLgAFFH8HAAIJAAMJ8xZSHADwAAAJAAMJ8xZSHADwAAAAAA==.',
['想吃']='想吃一包薯片:BAAALgAECgYJAwAAAA==.',
['想静']='想静静:BAABLgAECn8WAAIGAAYJ7h+0bQD5AQAGAAYJ7h+0bQD5AQAAAA==.',
['感觉']='感觉你号笨:BAAALgAECgQJCAAAAA==.',
['愿天']='愿天堂没有德:BAAALgAECgkJCQAAAA==.',
['我可']='我可没脑子:BAAALgAFFAEJAQAAAA==.',
['我是']='我是自然守护:BAAALgAECgYJDgAAAA==.',
['我真']='我真不手残啊:BAAALgAECgQJBwAAAA==.',
['战复']='战复月不浪:BAAALgAECgUJBQAAAA==.',
['打奶']='打奶真恶心:BAAALgADCggJAwAAAA==.',
['打小']='打小就能蛋:BAAALgAECgEJAgAAAA==.',
['扯丶']='扯丶:BAAALgAECgcJEwAAAA==.',
['抖擞']='抖擞:BAAALgADCgMJAwAAAA==.',
['招商']='招商银行:BAAALgAECgcJDAAAAA==.',
['指尖']='指尖烟:BAAALgAECgUJCAAAAA==.',
['按摩']='按摩没去过嗷:BAAALgAFFAQJBAAAAA==.',
['摩根']='摩根:BAAALgAECgEJAQAAAA==.',
['摸凹']='摸凹喵:BAAALgAECgIJAgAAAA==.',
['易压']='易压易压悠:BAAALgAECgQJBAAAAA==.',
['星曜']='星曜:BAACLgAFFH8JAAIRAAUJZgwVAgCfAQARAAUJZgwVAgCfAQAuAAQKfxoAAxEACQmJGFQPAJoCABEACQmJGFQPAJoCABAAAQnuApdZASUAAAAA.',
['星辰']='星辰大海:BAAALgAECgUJDgAAAA==.',
['是墓']='是墓尸:BAAALgAECgUJBQABLgAFFAQJBwAGAB8LAA==.',
['智慧']='智慧琦琦:BAAALgAFFAEJAQAAAA==.',
['暗色']='暗色星辰:BAAALgAECgIJBAAAAA==.',
['暴怒']='暴怒的邪僧:BAAALgAECgEJAgAAAA==.',
['最速']='最速皮卡丘:BAABLgAFFH8FAAIGAAMJ+xBYMQDoAAAGAAMJ+xBYMQDoAAAAAA==.',
['月牙']='月牙兒:BAAALgAECgkJDwABLgAFFAQJCAATALEIAA==.',
['月色']='月色:BAAALgAECgYJCAABLgAFFAgJHgAUAOEdAA==.',
['月虹']='月虹:BAABLgAFFH8IAAMNAAQJrgkRBAA9AQANAAQJrgkRBAA9AQAJAAQJJQUAAAAAAAAAAA==.',
['望圣']='望圣光忽悠你:BAAALgAFFAEJAgAAAA==.',
['朦胧']='朦胧的耳语:BAAALgAFFAEJAQAAAA==.',
['木语']='木语:BAAALgAECgcJBwAAAA==.',
['术师']='术师蜀黍:BAAALgADCgcJBwAAAA==.',
['李不']='李不伯丨:BAAALgAFFAMJAwAAAA==.',
['村雨']='村雨丶:BAAALgAECgYJCAABLgAFFAIJBQAJAG8HAA==.',
['杨屁']='杨屁屁:BAAALgAECgUJCgAAAA==.',
['杨超']='杨超越:BAAALgAECgMJAwAAAA==.',
['杯装']='杯装可乐:BAAALgAECgcJBwAAAA==.',
['林魂']='林魂:BAAALgAECgkJDwAAAA==.',
['枫芯']='枫芯:BAAALgAECgUJBgAAAA==.',
['柚子']='柚子不圆:BAAALgAECgQJBAAAAA==.',
['栢炼']='栢炼秋:BAAALgADCgYJBgAAAA==.',
['桃知']='桃知知:BAAALgAECgIJBAAAAA==.',
['桔梗']='桔梗仙冬月:BAAALgAECgkJCQAAAA==.',
['梦兮']='梦兮忆流年:BAAALgAECgYJBgAAAA==.',
['梦比']='梦比的医生:BAAALgADCgMJAwAAAA==.',
['梨花']='梨花雨凉:BAAALgAFFAEJAQAAAA==.',
['横竖']='横竖横:BAAALgAECgYJBgABLgAFFAUJBQAVAKgLAA==.',
['樱岛']='樱岛麻衣:BAAALgAECgMJAwAAAA==.',
['正气']='正气:BAABLgAFFH8FAAIMAAQJVhCVBQBKAQAMAAQJVhCVBQBKAQAAAA==.正气水:BAAALgAECgQJBAAAAA==.',
['死亡']='死亡狂想曲:BAAALgADCgMJAwAAAA==.',
['死骑']='死骑大姨妈:BAAALgADCgEJAQAAAA==.',
['水卜']='水卜樱:BAAALgADCgEJAQAAAA==.',
['水陸']='水陸草木:BAACLgAFFH8FAAMTAAQJhxC0CwAwAQATAAQJhxC0CwAwAQAWAAEJEgmtBgA/AAAuAAQKfycABBMACQmKH2gKAO8CABMACAktH2gKAO8CABcACQmUHGMOAMYCABgAAwnZD4QmAJwAAAAA.',
['永恒']='永恒黎明:BAAALgAFFAEJAQAAAA==.',
['求真']='求真的小萝卜:BAABLgAFFH8KAAIBAAQJPwUFCADcAAABAAQJPwUFCADcAAAAAA==.',
['沁嬢']='沁嬢亻黯讽:BAAALgADCgUJBQAAAA==.',
['没奶']='没奶:BAAALgAECgYJBgAAAA==.',
['法老']='法老耍猫:BAAALgAFFAIJAwAAAA==.',
['泥巴']='泥巴龙:BAAALgAECgQJBQAAAA==.',
['津島']='津島善子:BAAALgAFFAIJAwAAAA==.',
['流星']='流星的火光:BAAALgAECgYJBgAAAA==.',
['浪天']='浪天涯存本心:BAAALgAECgMJAwAAAA==.',
['浪客']='浪客猎心:BAAALgAECgUJCgAAAA==.',
['海德']='海德公园:BAAALgAFFAEJAQAAAA==.',
['海月']='海月雾:BAAALgAFFAIJAgAAAA==.',
['淡定']='淡定从容:BAAALgAFFAEJAQAAAA==.',
['渔樵']='渔樵问答:BAAALgAECgEJAQAAAA==.',
['温柔']='温柔:BAAALgADCgcJCAAAAA==.',
['溯世']='溯世命:BAAALgAECgYJBgAAAA==.',
['滑跪']='滑跪三道杠:BAAALgAECgUJBwAAAA==.',
['滚筒']='滚筒洗衣机丶:BAAALgAECgcJBwAAAA==.',
['潇潇']='潇潇雨:BAAALgAECgIJAgAAAA==.',
['潶歌']='潶歌:BAAALgAECgYJBgAAAA==.',
['潶潶']='潶潶:BAAALgAECgcJEAAAAA==.',
['火浣']='火浣:BAAALgAECgIJAgAAAA==.',
['灬莫']='灬莫闻:BAAALgAECgMJBgAAAA==.',
['灵动']='灵动死亡:BAAALgAECgYJBgABLgAFFAUJBQARACwHAA==.',
['炎影']='炎影:BAAALgAECgMJBQAAAA==.',
['煅焚']='煅焚:BAAALgAECgUJBQAAAA==.',
['熊猫']='熊猫是熊:BAABLgAFFH8FAAICAAIJdg+QHgCAAAACAAIJdg+QHgCAAAAAAA==.熊猫胖乎乎丶:BAAALgAECgQJBQAAAA==.',
['爱小']='爱小米睡不醒:BAAALgAECgcJDQAAAA==.',
['爸爸']='爸爸:BAAALgAECgEJAQAAAA==.',
['牛牛']='牛牛不怕苦:BAAALgAECgYJCAAAAA==.',
['牛犇']='牛犇牛犇:BAAALgADCgUJBQAAAA==.',
['物尽']='物尽天择:BAAALgAFFAEJAQAAAA==.',
['特喜']='特喜范:BAAALgAECgkJCQAAAA==.',
['狂战']='狂战斧:BAAALgAECgQJBAAAAA==.',
['狂暴']='狂暴橙匚:BAAALgADCgMJAwAAAA==.',
['狐狐']='狐狐宝宝:BAACLgAFFH8JAAICAAUJQR6BAwCoAQACAAUJQR6BAwCoAQAuAAQKfx0AAgIABwkMJoAMAMgCAAIABwkMJoAMAMgCAAAA.',
['独孤']='独孤翔:BAAALgAECgEJAQAAAA==.',
['猛踹']='猛踹老登瘸腿:BAABLgAFFH8FAAMLAAUJ0hgiCwBmAQALAAQJWBoiCwBmAQAMAAEJQRQMIQBeAAAAAA==.',
['猫头']='猫头蛇尾:BAAALgADCgIJAgAAAA==.',
['猫宫']='猫宫鼬娜:BAAALgADCgEJAQAAAA==.',
['玄霄']='玄霄:BAAALgAECgQJBAAAAA==.',
['王白']='王白毛:BAABLgAFFH8GAAIKAAMJwgdHJgDnAAAKAAMJwgdHJgDnAAAAAA==.',
['珍珠']='珍珠奶盖:BAABLgAFFH8GAAIGAAMJPgdZMADyAAAGAAMJPgdZMADyAAAAAA==.',
['琦琦']='琦琦大师:BAAALgAECgQJBgABLgAFFAEJAQAEAAAAAA==.琦琦小朋友:BAAALgAECgQJBAABLgAFFAEJAQAEAAAAAA==.琦琦拳法:BAAALgADCgUJBQAAAA==.琦琦教主:BAAALgADCgMJAwAAAA==.琦琦暗焰:BAAALgAECgEJAQABLgAFFAEJAQAEAAAAAA==.琦琦热血:BAAALgADCgMJAwAAAA==.',
['琴岛']='琴岛龙之子:BAAALgAFFAIJAgAAAA==.',
['甲流']='甲流后勤灬邙:BAAALgADCgEJAQAAAA==.',
['画斗']='画斗:BAAALgADCgcJBwABLgAFFAYJDgATAP8PAA==.',
['痞老']='痞老板:BAAALgAECgYJBwAAAA==.',
['癫狂']='癫狂:BAAALgADCgEJAQAAAA==.',
['白白']='白白空:BAAALgAFFAIJAgAAAA==.',
['白練']='白練秋:BAAALgADCgEJAQAAAA==.',
['白雪']='白雪凝冰:BAAALgAECgQJBAAAAA==.',
['百变']='百变灬:BAABLgAECn8fAAIXAAkJFx9tCAAIAwAXAAkJFx9tCAAIAwAAAA==.',
['皮皮']='皮皮龙虾:BAAALgAECgIJAwAAAA==.',
['皮蛋']='皮蛋:BAAALgAECgUJBQAAAA==.',
['盛夏']='盛夏:BAAALgAECgEJAQAAAA==.',
['真的']='真的很大:BAAALgAECgEJAQAAAA==.',
['眩耀']='眩耀夜行:BAABLgAFFH8FAAIBAAMJow57CADPAAABAAMJow57CADPAAAAAA==.',
['睡眠']='睡眠真的不足:BAAALgAECgYJDAAAAA==.',
['知彼']='知彼知己:BAAALgAECgMJAwAAAA==.',
['碳烤']='碳烤萌德:BAAALgAECgEJAQAAAA==.',
['祝踏']='祝踏喵:BAAALgADCgMJAwAAAA==.',
['福灵']='福灵术:BAAALgAFFAIJBAAAAA==.',
['稳牛']='稳牛:BAAALgAECggJCAABLgAFFAIJAwAEAAAAAA==.',
['空丶']='空丶白:BAAALgAECgUJBgAAAA==.',
['突然']='突然变了:BAAALgAECgkJDwAAAA==.突然圣光:BAAALgAECggJCgAAAA==.突然射出:BAAALgAECgcJBwAAAA==.突然无聊致死:BAAALgAFFAIJAwAAAA==.突然肥了:BAAALgAECgcJDQAAAA==.',
['等人']='等人上线很烦:BAAALgAECgUJBQAAAA==.',
['箭雨']='箭雨伽罗:BAAALgAECgUJBQAAAA==.',
['米拉']='米拉杰:BAAALgAECgEJAQAAAA==.',
['粉红']='粉红色体育生:BAAALgAECgYJDQAAAA==.',
['紫苏']='紫苏炒花甲:BAAALgAECgkJEAAAAA==.',
['约翰']='约翰雪豹:BAAALgAECgMJAwABLgAFFAcJDQABAM4ZAA==.',
['纳克']='纳克印痕:BAABLgAECn8UAAIIAAcJyAiXUwA3AQAIAAcJyAiXUwA3AQAAAA==.',
['细雨']='细雨亲香腮:BAAALgADCgMJAwAAAA==.',
['给你']='给你个大塞梨:BAAALgAECgYJBgAAAA==.',
['绝对']='绝对开水:BAAALgAECgYJBgAAAA==.',
['绝影']='绝影:BAAALgAFFAQJBAAAAA==.',
['维涅']='维涅斯:BAAALgAECgQJBAAAAA==.',
['绿色']='绿色土虫:BAAALgAECgMJAwAAAA==.',
['缺小']='缺小德:BAAALgAFFAQJBAAAAA==.',
['美味']='美味牛欢喜:BAAALgAECgEJAQAAAA==.',
['美少']='美少女水冰月:BAAALgAECgMJBQAAAA==.',
['美服']='美服喷子:BAAALgAECgEJAQAAAA==.',
['肌肉']='肌肉丶达人:BAAALgAECgcJEgAAAA==.',
['致命']='致命的芬达:BAAALgAECgQJBQAAAA==.',
['舒茉']='舒茉:BAAALgAECgYJDAAAAA==.',
['艾斯']='艾斯卡弥尔:BAAALgAFFAQJBAAAAA==.',
['芙蓉']='芙蓉王源:BAAALgAECgYJCgAAAA==.',
['花域']='花域:BAABLgAECn8UAAMTAAkJdh92AgBJAgATAAgJux52AgBJAgAXAAIJhCRyIgDYAAAAAA==.',
['英仙']='英仙座丶:BAABLgAECn8dAAIIAAkJ7BG6JQD9AQAIAAkJ7BG6JQD9AQAAAA==.',
['范特']='范特喜:BAAALgAFFAQJBAAAAA==.',
['莉莉']='莉莉娅:BAAALgAECgEJAQAAAA==.',
['莫问']='莫问火烛:BAABLgAFFH8FAAIQAAMJbw2FFwDyAAAQAAMJbw2FFwDyAAAAAA==.',
['菊里']='菊里橘气:BAAALgAFFAIJAwAAAA==.',
['落木']='落木:BAAALgAECgYJBgAAAA==.',
['虎丷']='虎丷:BAABLgAFFH8LAAIGAAQJxx96EgCDAQAGAAQJxx96EgCDAQAAAA==.',
['虚空']='虚空灬熊猫:BAAALgAECgUJBgAAAA==.',
['蛋破']='蛋破:BAAALgAFFAIJAgAAAA==.',
['蟋蟀']='蟋蟀的哥哥:BAAALgAFFAEJAQAAAA==.',
['血之']='血之雾:BAAALgAECgUJCAAAAA==.',
['裤衩']='裤衩撕裂者:BAAALgADCgEJAQAAAA==.',
['西格']='西格玛男神:BAAALgADCgEJAQAAAA==.',
['观星']='观星者灬团子:BAAALgAECgUJCQAAAA==.',
['詹尼']='詹尼丶:BAABLgAFFH8GAAMMAAMJMxBcDAAAAQAMAAMJMxBcDAAAAQALAAEJ+wZAKABLAAAAAA==.',
['记的']='记的丿那年秋:BAAALgAECgUJBQAAAA==.',
['讴歌']='讴歌烂漫:BAABLgAFFH8QAAICAAUJQBZ8BQB9AQACAAUJQBZ8BQB9AQAAAA==.',
['谙忽']='谙忽:BAAALgAECgEJAQAAAA==.',
['貝貝']='貝貝丶:BAAALgAECgQJBQAAAA==.',
['贩卖']='贩卖圣光核弹:BAAALgAECgMJAwAAAA==.',
['贱贱']='贱贱的薄荷:BAAALgAFFAIJAgABLgAFFAIJAgAEAAAAAA==.',
['赫卡']='赫卡蒂:BAAALgADCgQJBAAAAA==.',
['超屁']='超屁:BAACLgAFFH8HAAIZAAMJ/BxIBwAHAQAZAAMJ/BxIBwAHAQAuAAQKfyQAAxkACQnuIeQFAEkDABkACQnuIeQFAEkDAAEAAQmgD0lGADQAAAAA.',
['转么']='转么么:BAAALgAECgkJEgABLgAFFAUJBQAXAJkcAA==.',
['软席']='软席吉吉:BAAALgADCgEJAQAAAA==.',
['还是']='还是别吃了吧:BAAALgAECgcJCAAAAA==.',
['这是']='这是大宝贝:BAAALgAECgYJBgAAAA==.这是巫师:BAAALgAECgcJCwAAAA==.',
['进击']='进击的小伙伴:BAAALgAECgEJAQAAAA==.',
['逗逼']='逗逼德:BAAALgAECggJAgABLgAFFAcJBAAEAAAAAA==.',
['通灵']='通灵战歌:BAAALgAECgMJBAAAAA==.',
['酥酥']='酥酥:BAABLgAECn8UAAIXAAYJGwoTJwC6AAAXAAYJGwoTJwC6AAAAAA==.',
['重楼']='重楼:BAAALgAECgQJBAAAAA==.',
['钙奶']='钙奶饼干:BAAALgAECgEJAQAAAA==.',
['钰寳']='钰寳兒:BAAALgAECgIJAwAAAA==.',
['锂电']='锂电法王:BAAALgAECgYJDQAAAA==.',
['锦旗']='锦旗猎猎:BAAALgAFFAEJAQAAAA==.',
['闵小']='闵小东:BAAALgAECgYJBgAAAA==.',
['防战']='防战:BAAALgAFFAEJAQABLgAFFAIJBQACAHYPAA==.',
['阿丽']='阿丽塔:BAAALgAECgYJBgAAAA==.',
['阿卡']='阿卡林:BAABLgAECn8UAAIDAAgJGxWFQwArAgADAAgJGxWFQwArAgAAAA==.',
['随風']='随風牛牛:BAAALgAECgIJAgAAAA==.',
['隔夜']='隔夜辣子鸡:BAAALgAECgUJBQAAAA==.隔夜饭:BAAALgADCgMJAwAAAA==.',
['隔山']='隔山看海是雾:BAAALgAECgQJBQAAAA==.',
['雪痕']='雪痕伊:BAAALgAECgEJAgAAAA==.',
['雪镸']='雪镸锋:BAAALgAECgYJDQAAAA==.',
['霜纹']='霜纹灬扳手:BAAALgAECgYJCgAAAA==.',
['青柠']='青柠可可:BAAALgAECgUJDAAAAA==.',
['静空']='静空大师:BAAALgAECgQJBQAAAA==.',
['顷刻']='顷刻炼化:BAAALgAFFAEJAQABLgAFFAIJAwAEAAAAAA==.',
['风永']='风永远的使徒:BAAALgAECgMJAwAAAA==.',
['风生']='风生木:BAAALgAECgcJCwAAAA==.',
['风轻']='风轻花自落:BAAALgADCgcJCwAAAA==.',
['馒头']='馒头墩儿:BAACLgAFFH8JAAIJAAMJXxVJEgDlAAAJAAMJXxVJEgDlAAAuAAQKfxsAAw0ABwkEJXkNAIsCAA0ABwkEJXkNAIsCAAkABwkdG7lDAOUBAAAA.馒头渣儿:BAAALgAECgYJBgAAAA==.',
['香兒']='香兒飘飘:BAAALgAECgEJAQAAAA==.',
['骑士']='骑士蜀黍:BAAALgADCgYJBgAAAA==.',
['骑小']='骑小猪看星星:BAAALgAECgEJAQAAAA==.',
['骷髅']='骷髅:BAAALgAECgEJAgAAAA==.',
['高文']='高文:BAAALgAECgYJDAAAAA==.',
['鬼丨']='鬼丨弑:BAABLgAECn8YAAIKAAYJuBlgcAB/AQAKAAYJuBlgcAB/AQAAAA==.',
['魔理']='魔理沙:BAAALgADCgEJAQAAAA==.',
['鹿小']='鹿小咪:BAAALgAFFAEJAQAAAA==.',
['麻木']='麻木无敌:BAAALgAECgcJCQAAAA==.',
['黎明']='黎明之圣光:BAAALgAFFAQJBAAAAA==.',
['黑松']='黑松白露:BAAALgAECgYJBgAAAA==.',
['黒崎']='黒崎一牛:BAAALgAECgcJCQAAAA==.',
['默默']='默默摸摸:BAAALgADCgcJBwAAAA==.',
['龍灬']='龍灬傲天:BAAALgADCgEJAQAAAA==.',
['龙之']='龙之骄子:BAAALgAECgYJCAAAAA==.',
['龙啸']='龙啸武僧:BAAALgAECgkJCQAAAA==.',
['龙战']='龙战之殇:BAABLgAFFH8FAAIRAAUJLAc6AwB3AQARAAUJLAc6AwB3AQAAAA==.',
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
