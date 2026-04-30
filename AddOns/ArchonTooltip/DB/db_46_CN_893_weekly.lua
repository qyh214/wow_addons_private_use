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

local lookup = {'Mage-Frost','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Warrior-Fury','Druid-Balance','Shaman-Restoration','Mage-Fire','DemonHunter-Havoc','Evoker-Preservation','Unknown-Unknown','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Evoker-Augmentation','Priest-Discipline','Priest-Shadow','Hunter-Marksmanship','Hunter-Survival','Rogue-Subtlety','Warrior-Protection','DemonHunter-Vengeance','Druid-Restoration','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Monk-Any',}
local provider = {region='CN',realm='黄金之路',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alf:BAAALgAECgYJCwAAAA==.',
Be='Bedivere:BAABLgAECn8UAAIBAAYJcCOjRwBgAgABAAYJcCOjRwBgAgAAAA==.',
Bt='Btwang:BAACLgAFFH8FAAICAAMJExxYEgASAQACAAMJExxYEgASAQAuAAQKfxoABAIABwmmIFUlAJICAAIABwmmIFUlAJICAAMAAQn0CYYYACoAAAQAAQlzBLihACUAAAAA.',
Bu='Buddyloveiv:BAAALgADCgYJBgAAAA==.Buddylovevii:BAAALgADCggJCAAAAA==.',
Co='Coconice:BAAALgAECgcJBwAAAA==.',
Dr='Dragonsky:BAAALgAECgkJDwABLgAFFAYJCQAFACIJAA==.',
Eb='Ebenholz:BAABLgAECn8ZAAIGAAcJvhe5HQASAgAGAAcJvhe5HQASAgAAAA==.',
Ec='Eclecticism:BAAALgAECgMJAwAAAA==.',
Ga='Galadrel:BAAALgAECgEJAQAAAA==.',
Ha='Haar:BAABLgAFFH8FAAIHAAMJLxecCgDVAAAHAAMJLxecCgDVAAAAAA==.',
Ku='Kuicause:BAACLgAFFH8FAAMIAAUJQwCCAACiAAAIAAQJQwCCAACiAAABAAEJAACnOgAAAAAuAAQKfxkAAwgACQl0Fs4BAG4CAAEACQmQFdoyAKcCAAgACQlSEs4BAG4CAAAA.',
Le='Leahdizon:BAAALgADCgUJBQAAAA==.Leahdizonii:BAAALgAECgMJBAAAAA==.Leahdizoniix:BAAALgADCgUJBQAAAA==.Leahdizoniv:BAAALgADCgYJBgAAAA==.',
Li='Lightnight:BAAALgAECgYJCAAAAA==.',
Na='Najasna:BAAALgADCgEJAQAAAA==.',
Ny='Nyjstiutk:BAAALgAECgQJBAAAAA==.',
Ol='Oldorange:BAAALgAECgYJBAAAAA==.',
['Ré']='Rémÿ:BAAALgAECgEJAQAAAA==.',
Sc='Schwarzejes:BAAALgAECgcJBwAAAA==.',
Tb='Tb:BAAALgAECgcJCwAAAA==.',
Ti='Timi:BAAALgADCgEJAQAAAA==.',
Tr='Trdkf:BAAALgAECgkJDAAAAA==.Trdkq:BAAALgAECggJCAAAAA==.',
Wa='Walkingdead:BAAALgAECgYJBgAAAA==.',
['一粒']='一粒丹:BAAALgADCgcJBwAAAA==.',
['七分']='七分孤寂丶:BAAALgADCgQJBAAAAA==.',
['七喜']='七喜:BAAALgAECgYJCQAAAA==.',
['七进']='七进七出:BAABLgAFFH8HAAIEAAMJvQouEADXAAAEAAMJvQouEADXAAAAAA==.',
['丶凪']='丶凪光:BAAALgADCgUJBQAAAA==.',
['为月']='为月沉沦:BAAALgAECgYJBwAAAA==.',
['二宝']='二宝子:BAAALgADCgMJAwAAAA==.',
['仇白']='仇白:BAAALgAFFAQJBAAAAA==.',
['今晚']='今晚七麻麻:BAABLgAECn8UAAIJAAYJ9yUqDQCQAgAJAAYJ9yUqDQCQAgAAAA==.',
['伊蕾']='伊蕾娜:BAABLgAECn8TAAIBAAcJWSFpMQCtAgABAAcJWSFpMQCtAgAAAA==.',
['佑祥']='佑祥:BAAALgAFFAEJAQAAAA==.',
['佛耶']='佛耶戈:BAAALgAFFAMJAwAAAA==.',
['你好']='你好呀丶起灵:BAAALgAECgcJCQAAAA==.',
['你的']='你的小洣洣:BAAALgAECgYJBgAAAA==.',
['信仰']='信仰之殇:BAABLgAECn8hAAICAAkJYx4PDAAuAwACAAkJYx4PDAAuAwABLgAFFAYJCQAKAEYkAA==.',
['倚陵']='倚陵:BAAALgAECgkJEAAAAA==.',
['傅妍']='傅妍潔:BAAALgAECgYJCwAAAA==.',
['光之']='光之子:BAABLgAECn8UAAICAAYJdBVzcQCZAQACAAYJdBVzcQCZAQAAAA==.',
['八级']='八级大狂蜂:BAACLgAFFH8PAAIGAAQJMg3MBAA8AQAGAAQJMg3MBAA8AQAuAAQKf0sAAgYACAlCHjUOALkCAAYACAlCHjUOALkCAAAA.',
['八门']='八门遁甲开:BAAALgAFFAEJAQAAAA==.',
['冯宝']='冯宝宝:BAAALgAECgEJAQAAAA==.',
['冰雪']='冰雪之银水晶:BAAALgAECgYJBgAAAA==.',
['几缕']='几缕青葭:BAAALgAECgIJAgAAAA==.',
['凯程']='凯程先生:BAAALgAECgcJCQAAAA==.',
['刘亿']='刘亿妃:BAAALgADCgYJBwAAAA==.',
['刘小']='刘小白:BAAALgADCgEJAQAAAA==.',
['别打']='别打我丶笨蛋:BAAALgAECgIJBAAAAA==.',
['北慕']='北慕南辞:BAAALgAECgcJBwABLgAFFAEJAgALAAAAAA==.',
['十四']='十四行诗:BAAALgAECgYJCwAAAA==.',
['华蕾']='华蕾裘尔:BAAALgAECgkJDQAAAA==.',
['卧龙']='卧龙大花熊:BAAALgAECgMJAwAAAA==.',
['变身']='变身的德:BAAALgAECgEJAQAAAA==.',
['只会']='只会暴雨:BAAALgAFFAUJAQAAAA==.',
['召唤']='召唤师你来啦:BAAALgADCgQJBAAAAA==.',
['后羿']='后羿射月:BAABLgAECn8UAAIMAAYJriGhJAAqAgAMAAYJriGhJAAqAgAAAA==.',
['哈基']='哈基猎:BAAALgAECgMJAwAAAA==.',
['哈迪']='哈迪斯:BAAALgAECgUJCAABLgAECgcJFwAFABscAA==.',
['哲学']='哲学的淡季:BAAALgAECgMJAwAAAA==.',
['喵之']='喵之哀伤:BAAALgADCgEJAQAAAA==.',
['嘎噶']='嘎噶咖:BAAALgADCgUJAgAAAA==.',
['圣光']='圣光黎明:BAAALgAECgYJBgAAAA==.',
['地宝']='地宝:BAAALgAECgYJCQAAAA==.',
['墨狄']='墨狄斯丶菲比:BAAALgAECgQJBQAAAA==.',
['夏美']='夏美哩哩:BAABLgAECn8YAAQNAAcJbBFppAAPAQANAAUJjhFppAAPAQAOAAMJ5AsnRwCaAAAPAAEJAABeNAAzAAAAAA==.',
['多泽']='多泽:BAAALgAECgEJAgAAAA==.',
['多蒙']='多蒙卡欣:BAAALgAECgYJDQAAAA==.',
['夜露']='夜露死苦:BAAALgADCgIJAgAAAA==.',
['大旋']='大旋风:BAAALgADCgMJAwAAAA==.',
['天下']='天下:BAABLgAECn8tAAICAAkJxR7GCgA6AwACAAkJxR7GCgA6AwABLgAFFAUJBgAHAOgQAA==.',
['天真']='天真的云:BAABLgAFFH8FAAIQAAQJGBOcFABQAQAQAAQJGBOcFABQAQABLgAFFAYJCAARAAkTAA==.',
['天道']='天道:BAAALgAECgYJBgABLgAFFAUJBgAHAOgQAA==.',
['太难']='太难得:BAABLgAECn8UAAMSAAYJ0Q4iKQBOAQASAAYJ0Q4iKQBOAQATAAYJIwePPAAOAQAAAA==.',
['奥利']='奥利波斯猎:BAABLgAFFH8GAAQUAAIJVB+hHQCfAAAUAAIJjw6hHQCfAAAMAAEJtyNWFwBsAAAVAAEJ8Rq6BwBkAAAAAA==.',
['妄想']='妄想狂:BAAALgAECgUJCgABLgAFFAQJDAAWACwdAA==.',
['姜栩']='姜栩栩丶:BAAALgAECgIJAgAAAA==.',
['娇嫣']='娇嫣的紫水晶:BAAALgAECgIJAgABLgAFFAcJBQARAGAAAA==.',
['娇雪']='娇雪林:BAAALgADCgIJAwAAAA==.',
['孤影']='孤影醉:BAAALgADCgMJAwAAAA==.',
['守护']='守护梦境:BAAALgADCgYJBgAAAA==.',
['安么']='安么么:BAAALgAECgkJBwAAAA==.',
['安克']='安克雷奇:BAAALgAECgEJAQAAAA==.',
['小小']='小小的太阳:BAAALgADCgUJBQAAAA==.',
['小法']='小法泪儿灬:BAAALgAECgMJBAAAAA==.',
['小番']='小番茄屮:BAAALgADCgEJAQAAAA==.',
['小米']='小米虫子:BAAALgAFFAEJAQAAAA==.',
['岚岚']='岚岚:BAAALgADCgUJBQAAAA==.',
['布洛']='布洛芬疼:BAAALgAECgIJAgAAAA==.',
['张若']='张若衡:BAAALgAECgcJEwAAAA==.',
['很单']='很单纯很懵懂:BAABLgAFFH8LAAMNAAUJIw7YIwD1AAANAAUJxwzYIwD1AAAOAAEJYgrmFgBRAAAAAA==.',
['很忙']='很忙的法师:BAAALgAECgUJBQAAAA==.',
['德川']='德川加康:BAAALgAECgMJBAAAAA==.',
['忘川']='忘川秋裤:BAAALgAECgIJAgAAAA==.',
['慕青']='慕青鸾:BAAALgAFFAIJAgAAAA==.',
['我可']='我可能要掉线:BAAALgAECgIJAgAAAA==.',
['托山']='托山岳刀劈地:BAAALgADCgIJAgAAAA==.',
['扯毛']='扯毛线:BAAALgAECgkJCwAAAA==.',
['挑灯']='挑灯看剑:BAAALgADCgEJAQAAAA==.挑灯问梦:BAABLgAFFH8IAAMUAAQJQhWZDgA+AQAUAAQJyRKZDgA+AQAMAAIJYg33FgCqAAAAAA==.',
['捶你']='捶你胸口:BAAALgAECgEJAwAAAA==.',
['撒娇']='撒娇小满:BAABLgAECn8cAAIHAAcJRBzpGQBIAgAHAAcJRBzpGQBIAgAAAA==.',
['无敌']='无敌热熔人:BAABLgAFFH8GAAIBAAMJtRKbGAD7AAABAAMJtRKbGAD7AAAAAA==.',
['无有']='无有乡:BAAALgADCgMJAwABLgAFFAQJDAAWACwdAA==.',
['明日']='明日香:BAABLgAECn8dAAIQAAkJiBfKMwBnAgAQAAkJiBfKMwBnAgAAAA==.',
['星之']='星之卡比:BAAALgAECgMJAgAAAA==.',
['星明']='星明:BAAALgAECgMJBwAAAA==.',
['星月']='星月飘摇:BAAALgADCgEJAQAAAA==.',
['星河']='星河辞梦:BAAALgADCgcJBwAAAA==.',
['晋善']='晋善晋美:BAAALgAECgkJCQAAAA==.',
['晕呼']='晕呼呼:BAAALgAFFAEJAQAAAA==.',
['普罗']='普罗米修斯:BAABLgAECn8XAAMFAAcJGxxeLAADAgAFAAYJuB9eLAADAgAXAAYJcgsCJQAWAQAAAA==.',
['晶晶']='晶晶丶:BAAALgADCgYJBgAAAA==.',
['月夜']='月夜清霜:BAAALgAECgEJAQAAAA==.',
['月隐']='月隐空夜的狗:BAAALgAFFAIJAwAAAA==.',
['末法']='末法时代:BAAALgADCgcJBwAAAA==.',
['极速']='极速真空龙吸:BAAALgAECgcJEAAAAA==.',
['枫飞']='枫飞梦舞:BAABLgAECn8VAAIBAAYJWR6HawD+AQABAAYJWR6HawD+AQAAAA==.',
['栖野']='栖野:BAAALgAFFAEJAQABLgAFFAYJDQABAJESAA==.',
['栩墨']='栩墨:BAAALgAECgEJAQAAAA==.',
['格子']='格子的错觉:BAAALgADCgIJAgAAAA==.',
['梅伊']='梅伊比斯:BAAALgAECgIJAgAAAA==.',
['梅比']='梅比斯:BAAALgADCgEJAQAAAA==.',
['森蚺']='森蚺:BAAALgAECggJDAAAAA==.',
['樱桃']='樱桃姐姐:BAAALgAECgIJAwAAAA==.',
['欧气']='欧气喵喵:BAABLgAECn8RAAMOAAYJyheHCQCwAAANAAQJHhQ+OADSAAAOAAMJeh2HCQCwAAAAAA==.欧气满满富:BAAALgAECgkJCQAAAA==.',
['比姚']='比姚明高一些:BAAALgADCgIJAgAAAA==.',
['氤氲']='氤氲混沌:BAABLgAECn8UAAIYAAYJ1BdwDgBsAQAYAAYJ1BdwDgBsAQAAAA==.',
['汉丁']='汉丁顿伯爵:BAAALgAFFAEJBAAAAA==.',
['汉堡']='汉堡包:BAAALgAECgMJAwAAAA==.',
['池伏']='池伏妖:BAABLgAFFH8GAAIZAAMJNAjzDQCsAAAZAAMJNAjzDQCsAAAAAA==.',
['河发']='河发源于:BAAALgAECgYJBwAAAA==.',
['海墟']='海墟:BAAALgAECgYJBgAAAA==.',
['海洛']='海洛塔帝:BAAALgAECgYJDgAAAA==.',
['深渊']='深渊之玛瑙玉:BAAALgADCgEJAQAAAA==.',
['清源']='清源丫:BAAALgAFFAEJAgAAAA==.',
['灯火']='灯火不灭:BAABLgAFFH8KAAMMAAUJpxS2AwBbAQAMAAUJpxS2AwBbAQAUAAEJVQQ4KQBJAAAAAA==.',
['烈空']='烈空坐:BAAALgAECgUJBQAAAA==.',
['烨永']='烨永:BAAALgAECgIJAgAAAA==.',
['热心']='热心邻居:BAAALgADCgIJAgAAAA==.',
['無銘']='無銘小卒:BAAALgADCgEJAQAAAA==.無銘肥兴:BAAALgADCgcJBwAAAA==.',
['焰尾']='焰尾:BAABLgAFFH8MAAIUAAUJPBS8AgAxAQAUAAUJPBS8AgAxAQAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgATAAcWAA==.',
['熊熊']='熊熊高富帅:BAAALgADCgEJAQAAAA==.',
['熔炉']='熔炉行者:BAAALgADCgEJAQAAAA==.',
['牧仕']='牧仕:BAAALgAFFAEJAwAAAA==.',
['狂风']='狂风烟雨:BAAALgAECgEJAQAAAA==.',
['狐乱']='狐乱喝:BAABLgAFFH8FAAMaAAQJ6gPoBgAKAQAaAAQJ6gPoBgAKAQAbAAEJwQNCGQA4AAAAAA==.',
['獄門']='獄門:BAAALgAFFAEJAgAAAA==.',
['玄牛']='玄牛武僧:BAAALgADCgEJAQAAAA==.',
['王否']='王否留行:BAABLgAECn8WAAIMAAcJwh4mGgBrAgAMAAcJwh4mGgBrAgAAAA==.',
['王铁']='王铁锤:BAAALgAECgMJBQAAAA==.',
['理性']='理性论马:BAAALgAFFAcJAQABLgAFFAkJBgAbALgTAA==.',
['申小']='申小贝:BAAALgADCgEJAQAAAA==.',
['白夜']='白夜行:BAABLgAFFH8MAAIWAAQJLB2CAgBwAQAWAAQJLB2CAgBwAQAAAA==.',
['白就']='白就穿:BAAALgADCgEJAQAAAA==.',
['白茶']='白茶:BAAALgAECgYJBgAAAA==.',
['白駒']='白駒過隙:BAAALgAFFAEJAQAAAA==.',
['百鬼']='百鬼夜伈:BAAALgAECgUJBQAAAA==.',
['盛夏']='盛夏灬星空:BAAALgADCgEJAQAAAA==.',
['睡的']='睡的自然醒:BAAALgAECgMJAwAAAA==.',
['矮仙']='矮仙浪:BAAALgAECgcJCAABLgAFFAQJDgAQAOcjAA==.',
['破风']='破风斩月:BAAALgADCgMJAwAAAA==.',
['神一']='神一般的男人:BAAALgADCgUJBQAAAA==.',
['私人']='私人时间:BAABLgAECn8WAAIQAAcJJBkKTwAFAgAQAAcJJBkKTwAFAgAAAA==.',
['空蝉']='空蝉霜霜:BAAALgAECgMJAwAAAA==.',
['竡竡']='竡竡:BAAALgAECgYJBwAAAA==.',
['綾波']='綾波麗:BAAALgADCgYJBgAAAA==.',
['红色']='红色熊猫:BAAALgAECgYJCAAAAA==.',
['绫晄']='绫晄:BAAALgAECgIJAQAAAA==.',
['绮罗']='绮罗悦芬芳:BAAALgAECgUJCAAAAA==.',
['维密']='维密天使:BAAALgAFFAEJAQAAAA==.',
['胖大']='胖大仁:BAABLgAECn8ZAAIcAAcJEBT9KQC5AQAcAAcJEBT9KQC5AQAAAA==.',
['胸肌']='胸肌碎大石:BAAALgAECgEJAQAAAA==.',
['自在']='自在的风:BAAALgADCgYJBgAAAA==.',
['自然']='自然睡到醒:BAAALgAFFAIJBAAAAA==.',
['芋泥']='芋泥味大熊熊:BAAALgAECgIJAQABLgAFFAEJAgALAAAAAA==.',
['芒菓']='芒菓布丁:BAAALgAECgEJAQAAAA==.',
['苇草']='苇草:BAABLgAFFH8IAAIUAAQJ9RBsDwA3AQAUAAQJ9RBsDwA3AQAAAA==.',
['苍天']='苍天之青玉:BAAALgAFFAIJAgABLgAFFAYJFQAGAHIhAA==.',
['苏尔']='苏尔特洛奇:BAAALgAECgcJEAAAAA==.',
['莱贝']='莱贝克勒:BAAALgADCgIJAgAAAA==.',
['菊道']='菊道人:BAAALgAFFAEJAQAAAA==.',
['菟菟']='菟菟格蕾丝:BAAALgAECgcJDgAAAA==.',
['萧何']='萧何为情仇:BAAALgAECgYJCgAAAA==.',
['萨拉']='萨拉塔斯:BAAALgAECgQJBAAAAA==.',
['薇恩']='薇恩:BAAALgADCgUJBQAAAA==.',
['薇萌']='薇萌丝:BAAALgADCgEJAQAAAA==.',
['蛋总']='蛋总:BAAALgAECgEJAgAAAA==.',
['蟬時']='蟬時雨:BAAALgAFFAIJAwAAAA==.',
['行雲']='行雲流水:BAAALgAECgIJAgAAAA==.',
['誓约']='誓约:BAAALgAECgYJCgAAAA==.',
['赞时']='赞时空缺:BAAALgAECgEJAgAAAA==.',
['赫娅']='赫娅:BAAALgAECgEJAgAAAA==.',
['蹄子']='蹄子有蹄:BAAALgAECgUJBQAAAA==.',
['辞樱']='辞樱挽风:BAAALgAECgEJAQABLgAFFAEJAgALAAAAAA==.',
['逢坂']='逢坂大河:BAAALgAECgUJBQAAAA==.',
['遐蝶']='遐蝶:BAAALgADCgQJAQAAAA==.',
['钢达']='钢达姆机器人:BAAALgAECgMJAwAAAA==.',
['银之']='银之流星:BAACLgAFFH8HAAIBAAIJJhy8IACyAAABAAIJJhy8IACyAAAuAAQKfxoAAgEABwn+HMAZAJoBAAEABwn+HMAZAJoBAAAA.',
['银翼']='银翼圣龙:BAAALgAECgEJAgAAAA==.',
['開沅']='開沅術:BAAALgADCgEJAQAAAA==.',
['阡陌']='阡陌花开:BAAALgAECgkJCQAAAA==.',
['阿呦']='阿呦痛阿:BAAALgAECgYJEgAAAA==.',
['陈乔']='陈乔恩:BAAALgAECgYJBgAAAA==.',
['雷欧']='雷欧娜:BAAALgAECgYJCAAAAA==.',
['青丶']='青丶:BAABLgAFFH8KAAMUAAUJ6BPpCQB6AQAUAAUJWw3pCQB6AQAMAAQJYhIAAAAAAAAAAA==.',
['青木']='青木爭羽:BAABLgAECn8UAAQCAAcJsRg/cACcAQACAAYJKBY/cACcAQAEAAcJBwdYTgA/AQADAAEJRBLNQQA2AAAAAA==.',
['面条']='面条:BAAALgAECgcJDAAAAA==.',
['骨香']='骨香一号:BAACLgAFFH8JAAIcAAUJ4g/CBgAmAQAcAAUJ4g/CBgAmAQAuAAQKfxsAAhwACQlKGX4PAKICABwACQlKGX4PAKICAAAA.骨香七号:BAABLgAFFH8IAAIcAAQJxQsGBwAjAQAcAAQJxQsGBwAjAQAAAA==.骨香三号:BAABLgAFFH8IAAIcAAQJAAwWBwAiAQAcAAQJAAwWBwAiAQAAAA==.骨香二号:BAABLgAFFH8IAAIcAAQJVQ5gBgAsAQAcAAQJVQ5gBgAsAQAAAA==.骨香五号:BAACLgAFFH8IAAIcAAQJTQzvBgAkAQAcAAQJTQzvBgAkAQAuAAQKfxgAAhwACQlIFyEQAJsCABwACQlIFyEQAJsCAAAA.骨香八号:BAABLgAFFH8JAAIcAAUJtQoxCQABAQAcAAUJtQoxCQABAQAAAA==.骨香六号:BAABLgAFFH8FAAIdAAUJMAcAAAAAAAAcAAUJMAcAAAAAAAAAAA==.骨香四号:BAABLgAFFH8JAAIcAAUJOQ0KBwAjAQAcAAUJOQ0KBwAjAQAAAA==.',
['魑魅']='魑魅之灵:BAAALgAECgQJBAAAAA==.魑魅之球:BAAALgAFFAEJAgAAAA==.魑魅魍魉:BAAALgAECgIJBQAAAA==.',
['鲲上']='鲲上水晶:BAAALgADCgEJAQAAAA==.',
['麻醉']='麻醉师:BAAALgADCgEJAQAAAA==.',
['龙乡']='龙乡之星:BAAALgAECgEJAQAAAA==.',
['龙小']='龙小辰:BAABLgAECn8UAAIZAAYJuRXZSAB/AQAZAAYJuRXZSAB/AQAAAA==.',
['龙王']='龙王破山剑:BAAALgAECgEJAQAAAA==.',
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
