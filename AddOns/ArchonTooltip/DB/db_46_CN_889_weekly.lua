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

local lookup = {'Druid-Guardian','Warrior-Protection','Warlock-Demonology','Rogue-Subtlety','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-BeastMastery','Monk-Brewmaster','Warrior-Fury','Hunter-Marksmanship','Shaman-Restoration','Mage-Frost','Unknown-Unknown','DeathKnight-Blood','Mage-Fire','Paladin-Retribution','DemonHunter-Vengeance','Warrior-Arms','Priest-Discipline','Priest-Shadow','Rogue-Outlaw','Priest-Holy','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation',}
local provider = {region='CN',realm='鹰巢山',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Aben:BAAALgAECgQJBQAAAA==.',
Bu='Burden:BAAALgAECgQJBQAAAA==.',
De='Dearstan:BAAALgAECgEJAgAAAA==.',
Ez='Ezpz:BAACLgAFFH8FAAIBAAIJSRGUBAB+AAABAAIJSRGUBAB+AAAuAAQKfxQAAgEACAnSGmAIACcCAAEACAnSGmAIACcCAAAA.',
Fu='Furry:BAAALgAFFAIJAgAAAA==.',
Ki='Kimozi:BAAALgAECgUJBwAAAA==.',
La='Lansseax:BAAALgAFFAIJAgAAAA==.',
Mi='Minami:BAAALgAECgEJAQAAAA==.',
Ms='Msuqq:BAAALgAECgcJBwAAAA==.',
Pe='Perl:BAAALgAECgUJBwAAAA==.',
Sa='Sawa:BAACLgAFFH8HAAICAAMJMSVrAgA4AQACAAMJMSVrAgA4AQAuAAQKfxoAAgIACAlgJcQBAGUDAAIACAlgJcQBAGUDAAAA.',
Th='Thedeath:BAAALgAECgUJBQAAAA==.',
Xm='Xmercuryz:BAABLgAFFH8FAAIDAAMJtQy6FwDdAAADAAMJtQy6FwDdAAAAAA==.',
Zs='Zsess:BAAALgAECgIJAgAAAA==.',
['一小']='一小龙人一:BAAALgADCgcJCAAAAA==.',
['一尐']='一尐柒一:BAAALgAECgMJAwAAAA==.',
['一往']='一往如昔:BAAALgADCgEJAQAAAA==.',
['一抹']='一抹茶烟:BAAALgAECgcJBwAAAA==.',
['一路']='一路电过去:BAAALgAECgUJBQAAAA==.',
['七情']='七情渡:BAAALgAFFAEJAQAAAA==.',
['上官']='上官滚滚:BAAALgAFFAEJAQABLgAFFAQJDQAEABodAA==.',
['不会']='不会玩的圣骑:BAAALgAECgcJDAAAAA==.',
['与卿']='与卿赴韶华:BAAALgAECgUJAwAAAA==.',
['与龙']='与龙共舞:BAAALgAECgUJBQAAAA==.',
['丝滑']='丝滑老汉:BAAALgAECgcJDgAAAA==.',
['丧彪']='丧彪丶:BAAALgAECgQJBAAAAA==.',
['丨尐']='丨尐柒丨:BAAALgAECgEJAQAAAA==.',
['丶廬']='丶廬嚧鑪轤:BAAALgAFFAIJBAAAAA==.',
['丶浮']='丶浮生若梦丨:BAACLgAFFH8IAAIFAAMJ3xv+IwAGAQAFAAMJ3xv+IwAGAQAuAAQKfyMAAgUACAkWJO8PAB0DAAUACAkWJO8PAB0DAAAA.',
['丶煎']='丶煎蛋:BAAALgAECgUJBQAAAA==.丶煎蛋丶:BAAALgAECgQJAwAAAA==.',
['丶獨']='丶獨角戱丶:BAAALgAECgYJEAAAAA==.',
['为爱']='为爱守玲丶:BAAALgAECgYJDAAAAA==.',
['乔治']='乔治不拿盾:BAAALgAECgUJBQAAAA==.',
['二湿']='二湿熊:BAAALgAECgEJAQAAAA==.',
['云中']='云中小望望:BAABLgAECn8iAAMGAAgJkhd4FgAXAgAGAAcJjxp4FgAXAgAHAAgJNQ5sWgCSAQAAAA==.',
['云栖']='云栖夜:BAAALgAECgMJBAAAAA==.',
['亲亲']='亲亲小可爱:BAABLgAFFH8FAAIIAAIJZAeUGgCcAAAIAAIJZAeUGgCcAAAAAA==.',
['伊芙']='伊芙雷妮:BAAALgAECgkJCQAAAA==.',
['会跳']='会跳舞的熊:BAAALgAECgUJBQAAAA==.',
['佐希']='佐希亚:BAABLgAFFH8GAAIJAAIJrQ/5HACJAAAJAAIJrQ/5HACJAAAAAA==.',
['傲世']='傲世狂龍:BAAALgAECgkJCQAAAA==.',
['光与']='光与影的浪漫:BAAALgAFFAEJAQAAAA==.',
['光翼']='光翼展开:BAAALgAECgMJAwAAAA==.',
['八福']='八福字:BAABLgAFFH8KAAMKAAQJihueBwByAQAKAAQJihueBwByAQACAAEJChsZDwBNAAAAAA==.',
['凤秀']='凤秀苍穹:BAAALgAECgQJBAAAAA==.',
['凤青']='凤青:BAAALgAECgIJAwAAAA==.',
['初恋']='初恋的挽歌:BAAALgADCgUJBQAAAA==.',
['前面']='前面:BAAALgADCgEJAQAAAA==.',
['加钱']='加钱:BAAALgADCgEJAQAAAA==.',
['北极']='北极:BAAALgAECgQJBAAAAA==.',
['十一']='十一境武夫:BAAALgAECgMJBQAAAA==.',
['十六']='十六之石:BAAALgAECgYJDgAAAA==.',
['南琴']='南琴梨:BAAALgADCgEJAQAAAA==.',
['可乐']='可乐丶:BAAALgADCgEJAQAAAA==.',
['司空']='司空乐儿:BAAALgAECgIJAgAAAA==.',
['吕归']='吕归尘阿苏勒:BAAALgAECgYJCwAAAA==.',
['呀唛']='呀唛德:BAAALgAFFAQJBAAAAA==.',
['呆呆']='呆呆丶小囡:BAABLgAFFH8IAAMIAAQJ8hHCAwBbAQAIAAQJ8hHCAwBbAQALAAQJbwRyEwAGAQAAAA==.呆呆丶小萨:BAABLgAFFH8GAAIMAAQJOwbKCwAcAQAMAAQJOwbKCwAcAQAAAA==.',
['唐狮']='唐狮子牡丹:BAAALgAECgcJBwAAAA==.',
['嘛哩']='嘛哩丶中毒:BAAALgAECgQJBAAAAA==.嘛哩丶哄哄:BAAALgADCgYJBgAAAA==.嘛哩丶嘛哩:BAAALgAECgcJBwAAAA==.',
['嘟爆']='嘟爆你个肾:BAAALgAFFAIJAgAAAA==.',
['团饭']='团饭团:BAAALgAECgYJBQAAAA==.',
['地板']='地板丶王:BAAALgAECgMJBAAAAA==.',
['壞临']='壞临水的愛:BAAALgAECgMJAwAAAA==.',
['夏夜']='夏夜的柔风:BAAALgAECgIJAgAAAA==.',
['夜晚']='夜晚的潜水艇:BAAALgAECgEJAQAAAA==.',
['夢里']='夢里丶浮生:BAAALgAECgYJDAAAAA==.',
['大宝']='大宝贝:BAAALgADCgYJBgAAAA==.大宝鑫:BAAALgADCgUJBgAAAA==.',
['大將']='大將軍:BAAALgAECgQJBAAAAA==.',
['大松']='大松狮:BAAALgAECgEJAQAAAA==.',
['大猫']='大猫哥:BAAALgAECgYJCAAAAA==.',
['大苹']='大苹果:BAAALgAECgEJAQAAAA==.',
['大酒']='大酒缸:BAAALgAECgcJCwAAAA==.',
['大雨']='大雨烫脚:BAAALgAECgkJBwAAAA==.',
['天猎']='天猎战虎:BAAALgAECgYJBgAAAA==.',
['套住']='套住唔好玩:BAAALgAECgYJCQAAAA==.',
['奶油']='奶油烩蜊饭:BAABLgAECn8ZAAINAAcJjyQ9CABHAgANAAcJjyQ9CABHAgAAAA==.',
['安度']='安度因:BAAALgAECgQJBQABLgAECgcJBgAOAAAAAA==.',
['宫园']='宫园丶薰:BAAALgAFFAIJBAAAAA==.',
['寒塘']='寒塘渡鹤影丶:BAAALgAECgIJAgAAAA==.',
['小困']='小困包:BAAALgAFFAIJAwAAAA==.',
['小小']='小小瓜子:BAAALgADCgMJAwAAAA==.',
['小黄']='小黄帝俊俊:BAAALgADCgYJBgAAAA==.',
['巴到']='巴到烫:BAAALgAFFAMJAwAAAA==.',
['帅死']='帅死:BAAALgAECgQJBQAAAA==.',
['幽默']='幽默的杰森:BAAALgAECgkJDwAAAA==.',
['庄聚']='庄聚贤丶:BAAALgAECgYJCAAAAA==.',
['往事']='往事已成烟:BAABLgAFFH8PAAIPAAQJ8QXvBQDmAAAPAAQJ8QXvBQDmAAAAAA==.',
['德莱']='德莱文辅助:BAAALgAFFAIJAgAAAA==.',
['忧郁']='忧郁的蜗牛牛:BAAALgAECgQJBwAAAA==.',
['怠惰']='怠惰丶:BAABLgAFFH8NAAMPAAQJyRxYAwAuAQAPAAQJuBNYAwAuAQAFAAMJ4iGjHgAjAQAAAA==.',
['恶了']='恶了魔猎手:BAACLgAFFH8KAAIHAAQJxQclDgAHAQAHAAQJxQclDgAHAQAuAAQKfyMAAgcACAlSIFoQAPsCAAcACAlSIFoQAPsCAAAA.',
['恶堕']='恶堕修女:BAAALgADCgMJAwAAAA==.',
['恶魔']='恶魔术:BAAALgAECgQJBAAAAA==.',
['悟丶']='悟丶空:BAAALgAECgYJEAAAAA==.',
['悠兰']='悠兰:BAAALgAECgYJBgAAAA==.',
['我来']='我来试试火丶:BAAALgADCgUJBwAAAA==.',
['战争']='战争机器:BAAALgAECgMJBwAAAA==.',
['战场']='战场原丶:BAAALgAECgYJDgAAAA==.',
['战矛']='战矛诡计剑圣:BAAALgAECgEJAQAAAA==.',
['拉姆']='拉姆司菲尔德:BAAALgAECgIJAwAAAA==.',
['无敌']='无敌汉堡包:BAAALgAECgkJCgAAAA==.',
['日不']='日不落:BAAALgAECgEJAgAAAA==.',
['旧得']='旧得很好看:BAAALgAFFAIJAgAAAA==.',
['明前']='明前奶绿:BAACLgAFFH8PAAINAAQJZBVODABUAQANAAQJZBVODABUAQAuAAQKfxYAAw0ACAmCIIwlANwCAA0ACAmCIIwlANwCABAAAQl4HeUNAEoAAAAA.',
['星光']='星光灭绝:BAAALgAECgkJDwABLgAFFAYJFAARAHAeAA==.',
['星宸']='星宸:BAAALgAECgQJBAAAAA==.',
['星空']='星空下的幻想:BAAALgAFFAEJAQAAAA==.',
['是团']='是团团呀:BAAALgAFFAEJAQAAAA==.',
['晚秋']='晚秋初肃丶:BAAALgAECgEJAQAAAA==.',
['暖丨']='暖丨阳:BAAALgADCgYJBgAAAA==.',
['暖暖']='暖暖:BAAALgAFFAEJAQAAAA==.',
['最美']='最美好的初衷:BAAALgAECgMJAwAAAA==.',
['杰杰']='杰杰阿童木:BAAALgADCggJCQAAAA==.',
['東少']='東少:BAAALgADCgIJAgAAAA==.',
['松花']='松花斧邢道荣:BAAALgAECgYJBgAAAA==.',
['极夜']='极夜辉光:BAAALgAECgEJAQAAAA==.',
['林兮']='林兮:BAAALgAECgEJAQAAAA==.',
['柒兮']='柒兮:BAAALgAECgIJAgAAAA==.',
['橙心']='橙心丶:BAABLgAFFH8IAAMSAAMJ6BUYAgDEAAASAAMJLw0YAgDEAAAHAAIJwxpxFwCrAAAAAA==.',
['欢乐']='欢乐树的喷友:BAABLgAFFH8PAAMTAAQJLBk8BQDCAAAKAAMJZBTGEAABAQATAAIJyxs8BQDCAAAAAA==.',
['歌方']='歌方月乃丶:BAABLgAFFH8QAAIFAAQJpSYrAQC4AQAFAAQJpSYrAQC4AQAAAA==.',
['正義']='正義執行:BAAALgAFFAEJAQAAAA==.',
['正面']='正面:BAAALgADCgYJBgAAAA==.',
['死亡']='死亡之眼:BAAALgAECgMJAwAAAA==.',
['毒菇']='毒菇猫猫:BAAALgAECgkJBAAAAA==.',
['沐沐']='沐沐丨丶:BAABLgAECn8gAAMUAAgJYxnsDQBbAgAUAAgJYxnsDQBbAgAVAAMJ6gqVUACLAAABLgAFFAUJBQAUANEPAA==.',
['沙漠']='沙漠里的彩虹:BAAALgAECgcJBwAAAA==.',
['泡伊']='泡伊珂:BAAALgAECgIJAwAAAA==.',
['泣雷']='泣雷:BAAALgAECgEJAQAAAA==.',
['流年']='流年之伤:BAAALgAECgUJCAAAAA==.',
['渝州']='渝州十二卫:BAAALgAFFAIJBAAAAA==.',
['漏夜']='漏夜过东莞:BAAALgAECgQJBQAAAA==.',
['潜行']='潜行的奈亚子:BAACLgAFFH8NAAIEAAQJGh0gAgB3AQAEAAQJGh0gAgB3AQAuAAQKfyQAAgQACQmBItMBAJ0DAAQACQmBItMBAJ0DAAAA.',
['火星']='火星爆炸头:BAAALgADCgcJCQAAAA==.',
['炭术']='炭术:BAABLgAECn8kAAIDAAgJHw9/GgBlAQADAAgJHw9/GgBlAQAAAA==.',
['点根']='点根黑利群:BAAALgADCgEJAQAAAA==.',
['点点']='点点繁星:BAAALgADCgYJBgAAAA==.',
['焦糖']='焦糖三分糖:BAAALgAECgQJBAAAAA==.',
['煎了']='煎了个蛋:BAAALgAECgIJAQAAAA==.',
['煎蛋']='煎蛋丶:BAAALgAECgYJBgAAAA==.',
['熊熊']='熊熊:BAAALgADCgUJBQAAAA==.',
['爱上']='爱上张无忌:BAABLgAFFH8GAAIRAAMJKBJHDQD7AAARAAMJKBJHDQD7AAAAAA==.',
['犹记']='犹记少时:BAAALgAECgQJBAAAAA==.',
['狂者']='狂者灬怒风:BAAALgADCgYJBgAAAA==.',
['狐说']='狐说霸道:BAAALgADCgEJAQAAAA==.',
['獨奏']='獨奏悲歌:BAAALgAECgQJBwAAAA==.',
['玛丽']='玛丽莲丶撸哪:BAAALgAECgYJDAAAAA==.',
['瓜拾']='瓜拾叁:BAACLgAFFH8IAAIHAAQJIh89CgCJAQAHAAQJIh89CgCJAQAuAAQKfxUAAgcACQkRHCMPAAYDAAcACQkRHCMPAAYDAAAA.瓜拾壹:BAACLgAFFH8LAAIHAAQJviGJDABvAQAHAAQJviGJDABvAQAuAAQKfxUAAgcACQlsHjYOAA0DAAcACQlsHjYOAA0DAAAA.瓜拾肆:BAABLgAFFH8NAAIHAAUJ9RtOBQDUAQAHAAUJ9RtOBQDUAQAAAA==.瓜拾贰:BAABLgAFFH8MAAIHAAQJrR5BCwB9AQAHAAQJrR5BCwB9AQAAAA==.',
['疯狂']='疯狂的小牛丶:BAACLgAFFH8IAAIHAAIJzRf/JACrAAAHAAIJzRf/JACrAAAuAAQKfyYAAgcACAkMHmcXAMoCAAcACAkMHmcXAMoCAAAA.',
['疾风']='疾风丨极意:BAAALgAECgMJAwABLgAECgcJCAAOAAAAAA==.',
['白银']='白银德莱文:BAAALgAFFAEJAQAAAA==.',
['看不']='看不见岸:BAACLgAFFH8PAAIEAAQJRh4fAQCPAQAEAAQJRh4fAQCPAQAuAAQKfxUAAgQACAlcIX0MANACAAQACAlcIX0MANACAAAA.',
['看你']='看你流口水:BAAALgADCgMJAwAAAA==.',
['睡梦']='睡梦罗汉拳:BAAALgADCgIJAgAAAA==.',
['神枪']='神枪手龟龟:BAAALgAECgUJBAAAAA==.',
['神秘']='神秘左手釖:BAAALgAECgYJCgAAAA==.',
['禅西']='禅西大道:BAAALgAFFAEJAQAAAA==.',
['秋豆']='秋豆麻袋:BAAALgADCgMJAwAAAA==.',
['索马']='索马里渔夫:BAAALgAECgEJAgAAAA==.',
['紫焰']='紫焰幽兰:BAAALgAECgYJCQAAAA==.',
['红肚']='红肚兜丶:BAABLgAFFH8IAAIWAAQJ7gmpAABJAQAWAAQJ7gmpAABJAQAAAA==.',
['红色']='红色的忧郁:BAAALgAECgYJDAAAAA==.',
['红豆']='红豆思豆:BAAALgADCgkJCQAAAA==.',
['练赤']='练赤城:BAAALgAECgMJAwAAAA==.',
['绝美']='绝美:BAAALgAECgIJBAAAAA==.',
['绿皮']='绿皮鬼:BAABLgAFFH8HAAIDAAQJmgkhGQAoAQADAAQJmgkhGQAoAQAAAA==.',
['肉弹']='肉弹丶:BAAALgAECgYJBgAAAA==.',
['肝不']='肝不动时刻:BAAALgAECgIJAgAAAA==.',
['肯德']='肯德基上校:BAAALgADCgYJBgAAAA==.',
['艾尔']='艾尔奎特:BAAALgAECgEJAgAAAA==.',
['花村']='花村清洁工:BAAALgADCgQJBAAAAA==.花村的杏痒:BAAALgAECgUJBQAAAA==.',
['苏堤']='苏堤晓月:BAAALgAECgcJBwAAAA==.',
['荷包']='荷包蛋丶:BAAALgAECgYJCQAAAA==.',
['萨尓']='萨尓丶:BAAALgAECgcJBwAAAA==.',
['萨满']='萨满福克斯:BAAALgADCgMJAwAAAA==.',
['蒜蓉']='蒜蓉饺子:BAAALgAECgYJBgABLgAFFAIJAwAOAAAAAA==.',
['虚空']='虚空打火机:BAAALgAECgYJBwAAAA==.',
['蛋丶']='蛋丶:BAAALgAECgEJAgAAAA==.',
['蛋挞']='蛋挞超人:BAAALgAECgEJAQAAAA==.',
['蛋蛋']='蛋蛋不太傲娇:BAAALgAECgUJBwAAAA==.',
['街边']='街边一炮手:BAAALgAECgIJAwAAAA==.',
['西瓜']='西瓜酱:BAABLgAFFH8HAAMCAAUJ1QlXBAA6AQACAAUJWghXBAA6AQAKAAIJpwb9DQCcAAAAAA==.',
['西雅']='西雅啚夜未眠:BAAALgAECgQJBAAAAA==.西雅図夜未眠:BAAALgAECgUJCgAAAA==.西雅图不眠夜:BAAALgAECgQJBgAAAA==.西雅图夜未眠:BAAALgAECgIJAwAAAA==.',
['誰阿']='誰阿:BAAALgAECgQJBAAAAA==.',
['辰辰']='辰辰:BAAALgAECgMJAwAAAA==.',
['逐月']='逐月清风:BAACLgAFFH8QAAMUAAUJEA7RBgByAQAUAAUJXAnRBgByAQAXAAQJbA+fAwASAQAuAAQKfx4AAxQACAlJGgsYAN0BABQABwkZFwsYAN0BABcACAk7FOMtAI0BAAAA.',
['遗忘']='遗忘小哥哥:BAAALgAECgMJAwAAAA==.遗忘的彪子:BAAALgAECgUJBwAAAA==.遗忘的情人:BAAALgAECgcJDwAAAA==.',
['邪魔']='邪魔:BAAALgAFFAIJAwAAAA==.',
['都是']='都是泪:BAAALgAECgYJBgABLgAFFAcJDQACAM4ZAA==.',
['阮玲']='阮玲玉的阮:BAAALgAECgMJAwAAAA==.',
['阳台']='阳台的小熊:BAAALgAFFAIJAgAAAA==.',
['阿斯']='阿斯特拉尔:BAABLgAFFH8OAAQYAAQJcxJpCgBNAQAYAAQJcxJpCgBNAQAZAAQJhQ3DBQAeAQAaAAEJEglfCgBRAAAAAA==.',
['陋夜']='陋夜过东莞:BAAALgADCgUJBQAAAA==.',
['雪代']='雪代表死亡:BAAALgAECgcJCAAAAA==.',
['雪糕']='雪糕刺客:BAAALgAECgcJDwAAAA==.',
['风一']='风一样飘:BAAALgAFFAIJBAAAAA==.',
['飞过']='飞过苍海:BAAALgAFFAIJAgAAAA==.',
['饭团']='饭团团酱:BAAALgAECgMJAwAAAA==.',
['马蓉']='马蓉:BAAALgAECgcJEgAAAA==.',
['鬼舞']='鬼舞帥少:BAAALgAECgUJBgAAAA==.',
['黑色']='黑色沉沦:BAABLgAECn8gAAMLAAcJixidBwAPAQALAAYJ4xqdBwAPAQAIAAEJ1AxZUwBDAAAAAA==.',
['龙啸']='龙啸苍穹:BAAALgADCgMJAwAAAA==.',
['龙文']='龙文章:BAAALgAECgUJBwAAAA==.',
['龙舌']='龙舌蓝:BAAALgAECgEJAQAAAA==.',
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
