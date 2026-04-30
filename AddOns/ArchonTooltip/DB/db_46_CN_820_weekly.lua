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

local lookup = {'DemonHunter-Devourer','Mage-Frost','Warrior-Protection','Druid-Restoration','DeathKnight-Unholy','Hunter-Survival','Priest-Holy','Priest-Shadow','Priest-Discipline','Monk-Windwalker','Druid-Guardian','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Unknown-Unknown','Evoker-Preservation','Paladin-Holy','Druid-Balance','Warrior-Arms','Monk-Mistweaver','Rogue-Subtlety','Rogue-Assassination','Warrior-Fury','Paladin-Retribution',}
local provider = {region='CN',realm='藏宝海湾',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adano:BAAALgADCgYJBgAAAA==.',
Al='Alexanderw:BAAALgAECgMJAwAAAA==.',
Bl='Bloodyfox:BAAALgAFFAEJAQAAAA==.',
Ca='Capylulu:BAABLgAECn8dAAIBAAgJPiKTAgCnAgABAAgJPiKTAgCnAgAAAA==.',
Cr='Crin:BAAALgADCgEJAQAAAA==.',
De='Devourer:BAAALgAECggJCgAAAA==.',
Gi='Giania:BAAALgAECgYJBgAAAA==.',
Go='Goat:BAAALgAECgIJAgAAAA==.',
He='Helloboy:BAAALgAECgYJAQAAAA==.',
Hu='Huntingwind:BAAALgAECgMJBAAAAA==.',
Ic='Icy:BAAALgADCgEJAQAAAA==.',
Is='Isi:BAAALgAECgEJAQAAAA==.',
La='Lambrother:BAAALgADCgMJAwAAAA==.',
Ma='Magicfan:BAAALgAECgcJBwAAAA==.Makise:BAACLgAFFH8HAAICAAQJEx0pEgCFAQACAAQJEx0pEgCFAQAuAAQKfxQAAgIACAmgIfQVACUDAAIACAmgIfQVACUDAAAA.Marika:BAABLgAECn8VAAIDAAcJyxGIFQC0AQADAAcJyxGIFQC0AQAAAA==.Martyr:BAABLgAFFH8GAAIEAAQJrgvMCwAkAQAEAAQJrgvMCwAkAQAAAA==.',
Mc='Mcqueenw:BAAALgAECgQJCAAAAA==.',
Ov='Ov:BAAALgAECgQJBQAAAA==.',
Pa='Paris:BAAALgAECgcJCAAAAA==.',
Ra='Ravenheart:BAAALgADCgIJAgAAAA==.',
Sa='Saulh:BAAALgAECgcJDgAAAA==.',
Sc='Scarletty:BAAALgAECgcJCQAAAA==.',
Sn='Snower:BAABLgAFFH8GAAIFAAIJkRlUOgCoAAAFAAIJkRlUOgCoAAAAAA==.',
St='Stephanie:BAAALgAECgYJDgAAAA==.',
['一条']='一条恶龙:BAAALgAFFAEJAQAAAA==.',
['一狩']='一狩猎一:BAABLgAECn8VAAIGAAcJpB+0BgCRAgAGAAcJpB+0BgCRAgAAAA==.',
['三桥']='三桥李杂王:BAAALgAECgEJAgAAAA==.',
['三色']='三色灰:BAAALgAECgYJCQAAAA==.',
['不跟']='不跟笨蛋丸:BAACLgAFFH8HAAMHAAMJPRVIBAD1AAAHAAMJPRVIBAD1AAAIAAEJXgKJFQBNAAAuAAQKfygAAwcABwmmFWcoAK0BAAcABwmmFWcoAK0BAAgABgl4Ds41AD0BAAAA.',
['乄天']='乄天狼:BAAALgAECgkJAQABLgAFFAcJDQADAM4ZAA==.',
['九妞']='九妞一氍:BAAALgAECggJCwAAAA==.',
['云朵']='云朵团团:BAACLgAFFH8VAAMHAAYJ7CEvAABNAgAHAAYJ7CEvAABNAgAJAAQJpQoJCwAtAQAuAAQKfx8AAwcACQkpIOYDABgDAAcACQkpIOYDABgDAAkAAwmeCvRBAKMAAAAA.',
['仁佑']='仁佑:BAAALgAECgcJEgAAAA==.',
['你的']='你的法泽尔:BAAALgAECgYJBgAAAA==.',
['你相']='你相信光嗎:BAABLgAECn8kAAIKAAgJRBzeAgAiAgAKAAgJRBzeAgAiAgAAAA==.',
['侬伊']='侬伊拉佐徳:BAAALgAECgEJAQAAAA==.',
['保卫']='保卫室郭大爷:BAAALgAECgQJAwAAAA==.',
['信仰']='信仰灬元素:BAAALgAECgYJBgAAAA==.',
['修修']='修修小小:BAAALgAECgEJAQAAAA==.',
['元素']='元素萨:BAAALgAECgIJAgAAAA==.',
['克洛']='克洛诺斯:BAAALgAECgIJBAAAAA==.',
['写忆']='写忆:BAAALgAECgEJAQAAAA==.',
['冰寒']='冰寒巧技:BAAALgAECgcJDQAAAA==.',
['劉備']='劉備:BAAALgAFFAQJBAAAAA==.',
['劳资']='劳资蜀道山:BAAALgAECgEJAQAAAA==.',
['千帆']='千帆过尽:BAAALgAECgEJAQAAAA==.',
['午后']='午后悠凌:BAAALgAECgkJCQAAAA==.',
['卡冈']='卡冈图雅:BAAALgAECgIJAgAAAA==.',
['卡厄']='卡厄斯:BAAALgAECgEJAgAAAA==.',
['卡咩']='卡咩咩:BAABLgAECn8VAAMEAAYJXBfsPwCiAQAEAAYJXBfsPwCiAQALAAEJwQGnOgARAAAAAA==.',
['印第']='印第安老斑鸠:BAAALgAECgEJAQAAAA==.',
['厄瑞']='厄瑞玻斯:BAAALgAECgEJAQAAAA==.',
['叁幺']='叁幺柒:BAAALgADCgMJAwAAAA==.',
['另壶']='另壶葱:BAAALgADCgYJBgAAAA==.',
['史诗']='史诗乳娘:BAAALgAECgYJBgAAAA==.',
['名字']='名字最长的牛:BAABLgAECn8XAAIDAAYJXwlaKQD1AAADAAYJXwlaKQD1AAAAAA==.',
['周浦']='周浦内马尔:BAABLgAECn8XAAMMAAcJ7hsyHwBKAgAMAAcJ7hsyHwBKAgANAAUJfRG0TAAeAQAAAA==.',
['咕德']='咕德猫咛:BAAALgAFFAIJAwAAAA==.',
['啊呜']='啊呜:BAAALgAECgEJAQAAAA==.',
['喵叔']='喵叔:BAAALgADCgMJAwAAAA==.',
['因幡']='因幡月夜:BAAALgAECgQJBQAAAA==.',
['坠泪']='坠泪心痛:BAAALgADCgEJAQAAAA==.',
['堕落']='堕落灰烬使者:BAAALgAECgEJAQAAAA==.',
['墨燊']='墨燊:BAAALgAFFAIJBAAAAA==.',
['大桶']='大桶烘焙坚果:BAAALgAECgEJAQAAAA==.',
['大狐']='大狐狸崽:BAAALgAECgMJAwAAAA==.',
['天国']='天国恩赐:BAAALgAECgcJCAAAAA==.',
['奥妙']='奥妙无穷:BAABLgAECn8WAAICAAgJUh/UIwDjAgACAAgJUh/UIwDjAgAAAA==.',
['奶量']='奶量超低:BAAALgADCgUJBQAAAA==.',
['娴熟']='娴熟虎:BAABLgAECn8iAAMOAAgJxB8FAgBwAgAOAAgJxB8FAgBwAgAPAAUJ7BZ3SABgAQAAAA==.',
['季丶']='季丶:BAAALgAECgUJCQAAAA==.',
['守护']='守护者乌瑟尔:BAAALgAECgYJEAAAAA==.',
['宝宝']='宝宝别跑呀:BAAALgADCgYJBgAAAA==.',
['小力']='小力飞道:BAABLgAECn8RAAQQAAYJIhDhlgAqAQAQAAUJIhDhlgAqAQARAAEJAABSawA8AAASAAEJJQYZNQAxAAAAAA==.',
['小呀']='小呀小么牛:BAAALgAECgQJBAAAAA==.',
['小唐']='小唐似了:BAAALgAFFAEJAQABLgAFFAQJDgADAGgaAA==.小唐挺糖:BAACLgAFFH8OAAIDAAQJaBpfAwBdAQADAAQJaBpfAwBdAQAuAAQKfxwAAgMACAnzHqMFAN4CAAMACAnzHqMFAN4CAAAA.',
['小小']='小小修修:BAABLgAECn8oAAIHAAgJtBDPIwDIAQAHAAgJtBDPIwDIAQAAAA==.小小的恶魔:BAAALgAECgEJAQAAAA==.小小的法斯:BAAALgAECgEJAQAAAA==.小小的酒仙:BAAALgAECgQJBAABLgAECgcJFQAGAKQfAA==.小小的骑士:BAAALgAECgMJAwAAAA==.',
['小王']='小王牛:BAAALgAECgEJAQAAAA==.',
['小红']='小红手:BAAALgADCgcJBwAAAA==.',
['小麦']='小麦基:BAAALgAECgIJAgAAAA==.',
['尼克']='尼克斯:BAAALgAECgcJBwAAAA==.',
['尾巴']='尾巴隐身了:BAAALgAECgEJAQAAAA==.',
['工程']='工程法:BAAALgADCgEJAQAAAA==.',
['左手']='左手的左边:BAAALgAECgQJBAAAAA==.',
['巧克']='巧克狸:BAAALgAECgQJBAAAAA==.',
['巫山']='巫山沧海:BAAALgADCgQJBAAAAA==.',
['帅熊']='帅熊爱骑士:BAAALgAECgMJAgAAAA==.',
['幻海']='幻海梦蝶:BAAALgAECgQJBQAAAA==.',
['幽兰']='幽兰黛尔:BAAALgAECgMJAgAAAA==.',
['幽幽']='幽幽小叮当:BAAALgAECgcJBwABLgAFFAQJBAATAAAAAA==.',
['影遁']='影遁看风景:BAAALgAECgEJAQAAAA==.',
['後會']='後會丶無期:BAAALgAECgEJAQAAAA==.',
['息丶']='息丶:BAAALgAECgUJBgABLgAECgUJCQATAAAAAA==.',
['慕容']='慕容风蓝:BAAALgADCgMJAwAAAA==.慕容馨児:BAABLgAECn8nAAICAAgJMiKDBQB6AgACAAgJMiKDBQB6AgAAAA==.',
['慢慢']='慢慢蓄大力喷:BAABLgAFFH8MAAIUAAQJFSHYAgCGAQAUAAQJFSHYAgCGAQAAAA==.',
['手机']='手机没电了:BAAALgADCgEJAQAAAA==.',
['指尖']='指尖:BAAALgAECgcJCwAAAA==.',
['教主']='教主的洗漱间:BAAALgAECgYJDQAAAA==.',
['斗牛']='斗牛犬斯派克:BAAALgADCgUJBQAAAA==.',
['斯洛']='斯洛诺玛:BAAALgAECgEJAgAAAA==.',
['无声']='无声仿有声丶:BAAALgAECgYJEAAAAA==.',
['无拘']='无拘之青:BAAALgAECgEJAQABLgAECgUJCQATAAAAAA==.',
['无理']='无理走遍天下:BAABLgAECn8lAAIFAAgJ9xvBJQClAgAFAAgJ9xvBJQClAgAAAA==.',
['星空']='星空下的妖孽:BAAALgAECgQJBAAAAA==.星空下的月影:BAAALgAECgYJEgAAAA==.',
['星野']='星野爱:BAAALgAFFAEJAQAAAA==.',
['昭昭']='昭昭:BAABLgAFFH8XAAIVAAYJHCUbAACBAgAVAAYJHCUbAACBAgAAAA==.',
['暗之']='暗之狂奔:BAABLgAFFH8HAAIWAAQJ2g3DBAA9AQAWAAQJ2g3DBAA9AQAAAA==.',
['曼波']='曼波:BAAALgAECgcJBwABLgAECggJGQAKAJQXAA==.',
['最后']='最后的时光:BAAALgAECgEJAQAAAA==.',
['杀戮']='杀戮战神:BAAALgAECgEJAgAAAA==.',
['橘雪']='橘雪莉:BAACLgAFFH8NAAMQAAQJviUyEwBPAQAQAAMJWiUyEwBPAQARAAEJ6SZTDwB2AAAuAAQKfyEABBAACAkqJoMhAJECABAABgm9JoMhAJECABEAAwlrJL4jADsBABIAAQkAACEhAG0AAAAA.',
['欧贝']='欧贝利斯:BAABLgAECn8iAAMDAAgJ1xwsAgAmAgADAAgJ1xwsAgAmAgAXAAEJORsPOABPAAAAAA==.',
['死亡']='死亡使者:BAAALgAECgIJAgABLgAFFAUJCQAFAGomAA==.死亡弹药:BAAALgAECgMJAgAAAA==.',
['死噬']='死噬:BAABLgAECn8mAAIFAAgJxSObAgCkAgAFAAgJxSObAgCkAgABLgAFFAMJCAAQALsYAA==.',
['比女']='比女王更美:BAAALgAECgUJCAAAAA==.',
['毗湿']='毗湿奴:BAAALgAECgEJAQAAAA==.',
['水月']='水月大师:BAABLgAFFH8GAAIYAAQJaAQhBwDqAAAYAAQJaAQhBwDqAAAAAA==.',
['永恒']='永恒抹杀:BAAALgAECgIJAgABLgAFFAYJFwAHANsRAA==.',
['沙扬']='沙扬娜拉:BAABLgAECn8nAAMZAAgJ7CSMAADpAgAZAAgJ7CSMAADpAgAaAAEJHh86GgBXAAAAAA==.',
['洛丽']='洛丽嗒:BAAALgADCgYJBgAAAA==.',
['浩骑']='浩骑南防:BAAALgAFFAIJAgAAAA==.',
['浪总']='浪总:BAAALgAECgkJAQAAAA==.',
['浪飜']='浪飜云:BAAALgAFFAMJAwAAAA==.浪飜雲:BAAALgAFFAQJBAAAAA==.',
['海贼']='海贼王挖坑:BAAALgAECgYJCgAAAA==.',
['火暴']='火暴米青虫:BAAALgAECgYJDQAAAA==.',
['火焰']='火焰吞噬一切:BAAALgADCgMJAwAAAA==.',
['炎魔']='炎魔之王:BAAALgAECgIJAgAAAA==.',
['牛啦']='牛啦梦:BAAALgAECgUJBQAAAA==.牛啦猎:BAABLgAECn8oAAMGAAgJ+xtvBgCZAgAGAAgJ+xtvBgCZAgAMAAEJVgriVQA/AAAAAA==.',
['牛必']='牛必大荆龙:BAABLgAECn8gAAIUAAgJmhpXAgAaAgAUAAgJmhpXAgAaAgAAAA==.',
['牛有']='牛有刀:BAABLgAECn8YAAIbAAgJYhgPBQAAAgAbAAgJYhgPBQAAAgAAAA==.',
['狂戰']='狂戰:BAAALgAECgEJAQAAAA==.',
['狐假']='狐假虎哥威:BAAALgAECgEJAQAAAA==.',
['狸沫']='狸沫:BAAALgAECgkJCgAAAA==.',
['獸王']='獸王獵人:BAABLgAECn8nAAIMAAgJXyUTAwBjAwAMAAgJXyUTAwBjAwAAAA==.',
['玄嵩']='玄嵩岳:BAAALgADCgMJAwAAAA==.',
['珍梅']='珍梅薯汁:BAAALgADCgEJAQAAAA==.',
['瑶瑶']='瑶瑶:BAAALgAECgEJAgAAAA==.',
['白石']='白石麻衣:BAAALgAECgcJAgAAAA==.',
['碎片']='碎片:BAAALgAFFAIJBAAAAA==.',
['祖师']='祖师婆:BAABLgAFFH8IAAIQAAMJuxh8HQAOAQAQAAMJuxh8HQAOAQAAAA==.',
['穗積']='穗積丶:BAAALgAFFAQJBAAAAA==.',
['空谷']='空谷足音:BAAALgAECgEJAQAAAA==.',
['米且']='米且人:BAAALgAECgQJBAAAAA==.',
['粉丝']='粉丝鸡:BAAALgAECgYJDAAAAA==.',
['粉鸟']='粉鸟满天飞:BAAALgAECgYJBwAAAA==.',
['繁花']='繁花落尽:BAAALgAECgcJDgAAAA==.',
['给你']='给你两坨子:BAAALgAFFAEJAQAAAA==.',
['绝命']='绝命毒师:BAABLgAECn8VAAMSAAYJbQ6BDgBJAQASAAYJPwuBDgBJAQAQAAMJ+RJt7ACBAAAAAA==.',
['绯红']='绯红奥尔森:BAAALgAECgYJDgAAAA==.',
['绷带']='绷带批发商:BAAALgAECgYJCwAAAA==.',
['羊吕']='羊吕志:BAAALgAFFAEJAQAAAA==.',
['羸弱']='羸弱的妖腰:BAAALgADCgIJAgAAAA==.',
['老陳']='老陳:BAACLgAFFH8SAAQQAAUJ3xxUDwBkAQAQAAQJ3xxUDwBkAQARAAEJ0wWmGABNAAASAAEJAAA2BwBLAAAuAAQKfxYABBAACAkJH25AAAwCABAABwm9Hm5AAAwCABIAAwmlHxEVAOAAABEAAgmrIDo/ALgAAAEuAAUUBgkJABAAwhkA.',
['聚光']='聚光灯往这打:BAABLgAFFH8YAAMOAAYJISYNAQA4AgAOAAUJDSYNAQA4AgAPAAIJeRl9EwDDAAAAAA==.',
['至明']='至明之光:BAAALgAECgMJBgAAAA==.',
['荒村']='荒村大蘑菇:BAAALgAECgYJBwAAAA==.荒村大野龙:BAAALgAECgYJEAAAAA==.',
['莉亚']='莉亚德琳:BAABLgAECn8nAAIcAAgJdiE/AwCYAgAcAAgJdiE/AwCYAgAAAA==.',
['莱昂']='莱昂哈特:BAAALgAECgEJAgAAAA==.',
['董卓']='董卓:BAAALgAECgEJAQAAAA==.',
['蒲公']='蒲公英的旅行:BAABLgAECn8VAAIDAAgJ0gwtFQC6AQADAAgJ0gwtFQC6AQAAAA==.',
['蓝黑']='蓝黑色的忧伤:BAAALgAFFAEJAQAAAA==.',
['薄荷']='薄荷叶:BAAALgAECgMJBgAAAA==.',
['虾仁']='虾仁不假演:BAAALgAECgIJAgAAAA==.',
['蛋蛋']='蛋蛋哥哥:BAAALgAECgYJCgAAAA==.',
['術爷']='術爷:BAAALgAFFAIJAgABLgAFFAYJCQAQAMIZAA==.',
['西瓜']='西瓜的皮:BAAALgADCgcJBwAAAA==.',
['诡秘']='诡秘:BAAALgAECgkJCQABLgAFFAUJAQATAAAAAA==.',
['诸界']='诸界亵渎:BAAALgAECgcJBwAAAA==.',
['貂蝉']='貂蝉还在骑马:BAAALgADCgIJAgAAAA==.',
['赛博']='赛博坦之牙:BAABLgAECn8WAAQLAAcJ5BUdDQC1AQALAAYJ7RkdDQC1AQAWAAYJeRD6QgAkAQAEAAUJxg5ZcQACAQAAAA==.',
['赫菲']='赫菲斯乇斯:BAAALgAECgIJBAAAAA==.',
['踏雪']='踏雪風無痕:BAAALgAECgYJCgAAAA==.',
['还在']='还在想他吗:BAAALgADCgEJAQAAAA==.',
['追风']='追风小满:BAAALgAECgYJCwAAAA==.',
['逐暗']='逐暗者:BAAALgAECgEJAgAAAA==.',
['逗你']='逗你玩大表哥:BAAALgAECgEJAQAAAA==.',
['邪恶']='邪恶师傅:BAAALgAECgUJBQAAAA==.',
['铁巴']='铁巴斯塔:BAAALgAECgYJCQAAAA==.',
['阿猪']='阿猪斩舰刀:BAAALgAECgkJBQAAAA==.',
['雲那']='雲那個雲:BAABLgAECn8oAAMEAAgJ5yJmBwAWAwAEAAgJ5yJmBwAWAwAWAAYJYRCNEQAEAQAAAA==.',
['雷霆']='雷霆嘎巴:BAAALgAECgcJBwAAAA==.',
['霹雳']='霹雳背背:BAAALgADCgEJAQAAAA==.',
['青螭']='青螭:BAAALgAFFAIJAwAAAA==.',
['青霖']='青霖谣:BAAALgAECgMJAwAAAA==.',
['风走']='风走过的天空:BAAALgAECgYJBgAAAA==.',
['飞猫']='飞猫精:BAAALgAECgIJAgAAAA==.',
['香菇']='香菇盾击:BAAALgAECgMJBgAAAA==.',
['香香']='香香软软白:BAAALgAECgUJBQAAAA==.',
['马鸡']='马鸡:BAAALgAECgYJBgAAAA==.',
['鬼鬼']='鬼鬼火火:BAABLgAECn8iAAMQAAgJZBOXEQCkAQAQAAgJZBOXEQCkAQARAAEJAACIGwAAAAAAAA==.',
['魔鬼']='魔鬼筋肉人:BAAALgADCgUJBQAAAA==.',
['鸟德']='鸟德伊:BAAALgAFFAIJAgAAAA==.',
['麦当']='麦当劳:BAAALgAFFAEJAQAAAA==.',
['黑启']='黑启英二:BAAALgADCgYJBgAAAA==.',
['黯丨']='黯丨岚:BAAALgAFFAIJAgAAAA==.',
['龙云']='龙云:BAABLgAECn8bAAIQAAgJowvFFQCFAQAQAAgJowvFFQCFAQAAAA==.',
['龙魂']='龙魂之最:BAAALgAECgYJCQAAAA==.',
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
