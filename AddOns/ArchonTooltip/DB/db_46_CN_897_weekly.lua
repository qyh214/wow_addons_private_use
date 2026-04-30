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

local lookup = {'Shaman-Elemental','Shaman-Restoration','Warlock-Demonology','Priest-Shadow','Priest-Discipline','Mage-Frost','DeathKnight-Blood','Evoker-Augmentation','Evoker-Devastation','Druid-Restoration','Rogue-Subtlety','Paladin-Retribution','Unknown-Unknown','Monk-Brewmaster','Monk-Windwalker','Evoker-Preservation','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Warrior-Fury','DeathKnight-Unholy','Warrior-Arms','Mage-Arcane','DeathKnight-Frost','DemonHunter-Havoc','Warrior-Protection',}
local provider = {region='CN',realm='黑暗虚空',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abukuma:BAAALgAECgYJEgAAAA==.',
Ag='Agoni:BAAALgAECgUJBQAAAA==.',
Ch='Charmer:BAAALgAECgEJAQAAAA==.',
Cr='Crazypriest:BAACLgAFFH8HAAMBAAMJVg/NCwCjAAABAAIJxRDNCwCjAAACAAIJ2BaUFwCdAAAuAAQKfx0AAwIACAmEHxMMAMACAAIACAmEHxMMAMACAAEAAwkJDeBzAHIAAAAA.',
Dr='Dranosh:BAAALgAECgMJAwAAAA==.',
Gu='Guldanpapa:BAABLgAECn8WAAIDAAkJWSKtAQC3AwADAAkJWSKtAQC3AwAAAA==.',
Hd='Hdgzlgmwzy:BAAALgAFFAIJBAAAAA==.',
Ic='Icebox:BAAALgAECgUJCAAAAA==.',
In='Insonmia:BAAALgAECgIJAwAAAA==.',
Is='Isyalvie:BAACLgAFFH8FAAIEAAMJ8A3mBgDoAAAEAAMJ8A3mBgDoAAAuAAQKfxwAAwQACAlUEAMjAL8BAAQACAlUEAMjAL8BAAUABwkeEIwfAJcBAAAA.',
Ji='Jirogue:BAAALgADCgIJAgAAAA==.',
Ju='Junes:BAAALgAECgMJAwAAAA==.',
Le='Legendgodx:BAAALgADCgMJAwAAAA==.',
Ma='Maylife:BAAALgAECgYJEAAAAA==.',
Mi='Mieken:BAAALgAECggJDQAAAA==.',
Ra='Rainbowsugar:BAAALgAFFAEJAQAAAA==.',
Sp='Spz:BAACLgAFFH8EAAIGAAMJSBHVIACyAAAGAAMJSBHVIACyAAAuAAQKfxUAAgYABwlyHXhpAAMCAAYABwlyHXhpAAMCAAAA.',
St='Struggles:BAAALgAECgEJAQAAAA==.',
['Sà']='Sànêtíng:BAAALgADCgUJBQAAAA==.',
Us='Usk:BAABLgAFFH8LAAIDAAQJIRfnBwBUAQADAAQJIRfnBwBUAQAAAA==.',
Wh='Wheelchair:BAAALgAECgIJAwAAAA==.',
Yu='Yubibabo:BAAALgAECgEJAQAAAA==.',
Yz='Yzolaphilo:BAACLgAFFH8HAAIHAAMJmwh0BwCvAAAHAAMJmwh0BwCvAAAuAAQKfx8AAgcACAmbFKgTANQBAAcACAmbFKgTANQBAAAA.',
Za='Zalot:BAAALgAECgYJCAAAAA==.',
Zu='Zundamon:BAACLgAFFH8PAAMIAAQJDBbGCwA/AQAIAAQJ4xHGCwA/AQAJAAEJlx0vCABfAAAuAAQKfykAAwkACAkeH0sMABYCAAgABwkdG0cXABoCAAkABglZHksMABYCAAAA.',
['一刀']='一刀死:BAAALgAECgUJBwAAAA==.',
['一氧']='一氧化二氢:BAABLgAECn8aAAIKAAgJnhgCJwAaAgAKAAgJnhgCJwAaAgAAAA==.',
['一禄']='一禄德:BAABLgAFFH8IAAIKAAQJVBgVCABRAQAKAAQJVBgVCABRAQAAAA==.',
['七月']='七月七日狼:BAAALgAFFAIJAgAAAA==.',
['万州']='万州烤鱼:BAAALgAECgUJBQAAAA==.',
['三昧']='三昧神风:BAAALgAECgcJDQAAAA==.',
['不准']='不准撒粉灬:BAABLgAFFH8FAAILAAMJvRN5DgAIAQALAAMJvRN5DgAIAQAAAA==.',
['不离']='不离不弃灬:BAAALgAECgEJAQAAAA==.',
['不许']='不许敲自己:BAABLgAFFH8FAAIMAAMJCCJpDgA3AQAMAAMJCCJpDgA3AQABLgAFFAQJBAANAAAAAA==.',
['东北']='东北小花猪:BAAALgADCgIJAgAAAA==.',
['两仪']='两仪阑尾:BAAALgADCgUJBQAAAA==.',
['两面']='两面包夹芝士:BAAALgAFFAMJAwAAAA==.',
['丨折']='丨折磨灬:BAAALgAECggJDQAAAA==.',
['丨阿']='丨阿撒托斯丨:BAAALgAECgUJBQAAAA==.',
['丶武']='丶武松:BAAALgAECgEJAQAAAA==.',
['丶茄']='丶茄子丶:BAAALgAECgEJAgAAAA==.',
['为你']='为你哭红眼:BAAALgADCgEJAQAAAA==.',
['丿丶']='丿丶绿茶伈甜:BAAALgADCgIJAgAAAA==.',
['乌鸦']='乌鸦做飞机:BAAALgAECgIJAgAAAA==.',
['九天']='九天呆:BAAALgAECgEJAQAAAA==.',
['二二']='二二叁肆:BAAALgAECgYJCQAAAA==.',
['二郎']='二郎显圣真君:BAAALgAECgYJDAAAAA==.',
['于都']='于都宫紫苑:BAAALgADCgMJAwAAAA==.',
['云卷']='云卷云舒:BAABLgAFFH8JAAIGAAQJESSkDwCaAQAGAAQJESSkDwCaAQAAAA==.',
['云淡']='云淡风清:BAAALgADCgcJBQAAAA==.',
['亦亦']='亦亦得失:BAAALgAFFAMJBAAAAA==.',
['伍柒']='伍柒:BAAALgAECgcJBgAAAA==.',
['低吟']='低吟的诅咒:BAAALgAECgUJEQAAAA==.',
['你干']='你干嘛:BAAALgAECgMJAwAAAA==.',
['傻蔓']='傻蔓:BAAALgAECgQJBAAAAA==.',
['元始']='元始天尊:BAAALgADCgMJAwAAAA==.',
['光头']='光头强不强:BAAALgAECgEJAgAAAA==.',
['全抖']='全抖焕:BAAALgAECgYJBgAAAA==.',
['八颗']='八颗苹果:BAACLgAFFH8FAAICAAIJGRBBGQCWAAACAAIJGRBBGQCWAAAuAAQKfxkAAwIACAk3FsEhABQCAAIACAk3FsEhABQCAAEABgnWCgFQAAcBAAAA.',
['冰火']='冰火赞歌:BAAALgAECgYJCAAAAA==.',
['冰风']='冰风玉壁:BAAALgADCgMJAwAAAA==.冰风玉肌:BAAALgADCgQJBAAAAA==.',
['冷雨']='冷雨:BAABLgAECn8XAAMOAAgJOQ+TMgCHAQAOAAcJ6A6TMgCHAQAPAAcJAQrQMwBTAQAAAA==.',
['凌晨']='凌晨四点的蓝:BAAALgADCgcJBwAAAA==.',
['凌漠']='凌漠孤梦:BAACLgAFFH8QAAIQAAQJCicmAwDbAQAQAAQJCicmAwDbAQAuAAQKfzYAAhAACQkIJwIAACAEABAACQkIJwIAACAEAAEuAAQKBAkIAA0AAAAA.',
['凛冽']='凛冽寒风:BAAALgAECgEJAQAAAA==.',
['凶悍']='凶悍的姜老歪:BAAALgAECgMJBQAAAA==.',
['刀儿']='刀儿我来抗:BAAALgADCgUJAwAAAA==.',
['刃从']='刃从风浪起:BAAALgAECgYJCwAAAA==.',
['别对']='别对我放肆:BAAALgAECgUJCQAAAA==.别对莪放肆:BAAALgAECgQJBAAAAA==.',
['别急']='别急:BAAALgAECgIJAgAAAA==.',
['勒是']='勒是雾都丶:BAAALgAECgQJBgAAAA==.',
['十八']='十八个罗汉:BAABLgAFFH8FAAIOAAMJ/h5yDQAZAQAOAAMJ/h5yDQAZAQAAAA==.',
['千鸟']='千鸟流:BAACLgAFFH8MAAIBAAQJOxZmAwBOAQABAAQJOxZmAwBOAQAuAAQKfx0AAgEACQmSGCggAA4CAAEACQmSGCggAA4CAAAA.',
['午安']='午安小爱:BAAALgAECgYJBQABLgAFFAMJBwARAG0XAA==.',
['午時']='午時已到:BAACLgAFFH8HAAIOAAMJmgvzCwDTAAAOAAMJmgvzCwDTAAAuAAQKfxYAAw4ABwmwD3k9AFABAA4ABwmwD3k9AFABAA8AAQmAERZ6ADYAAAAA.',
['半盏']='半盏竹影凉:BAAALgAECgIJAwAAAA==.',
['南无']='南无加特林佛:BAAALgAECgEJAQAAAA==.',
['南溟']='南溟:BAAALgAECgUJBwABLgAFFAQJCQARAHMRAA==.',
['卡布']='卡布奇诺伯爵:BAAALgAFFAEJAQAAAA==.',
['卡雷']='卡雷什:BAAALgAECgMJAwAAAA==.',
['又过']='又过了一天:BAAALgAECgMJAwAAAA==.',
['发飙']='发飙的蜗牛丶:BAAALgAECgEJAQAAAA==.',
['古丹']='古丹丶:BAAALgAECgYJEQAAAA==.',
['古城']='古城:BAAALgADCgUJBQAAAA==.',
['古客']='古客子:BAAALgAECgYJBgAAAA==.',
['右方']='右方之火丶:BAAALgAECgYJBwAAAA==.',
['吃猫']='吃猫鱼:BAAALgAECgUJCQAAAA==.',
['哈薩']='哈薩度:BAAALgAECgEJAQAAAA==.',
['哈酒']='哈酒箱箱:BAAALgADCgEJAQAAAA==.',
['唤梦']='唤梦:BAAALgAECgQJCAAAAA==.',
['唯烟']='唯烟懂我心:BAAALgAECgkJDwAAAA==.',
['啊呜']='啊呜罗拉:BAACLgAFFH8JAAIMAAMJNSSDBwA3AQAMAAMJNSSDBwA3AQAuAAQKfx4AAgwACAntJM8HAFcDAAwACAntJM8HAFcDAAAA.',
['嗜灬']='嗜灬魔灵:BAAALgADCgcJBwAAAA==.',
['嘻嘻']='嘻嘻粒:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光会庇佑你:BAAALgAECgEJAQAAAA==.圣光灬制裁:BAAALgAECgQJBgAAAA==.',
['坂田']='坂田银时:BAAALgADCgEJAQAAAA==.',
['堕落']='堕落:BAAALgAECgQJBwAAAA==.',
['墨丨']='墨丨水:BAAALgADCgEJAQAAAA==.',
['夏奇']='夏奇拉丶:BAAALgADCgMJAwAAAA==.',
['夜游']='夜游僧:BAAALgAECgkJBgAAAA==.',
['夜风']='夜风之龙:BAAALgADCgEJAQAAAA==.',
['大牛']='大牛法棍:BAAALgADCgcJBQAAAA==.',
['奈何']='奈何桥上观景:BAAALgAECgMJAwAAAA==.',
['奧格']='奧格瑞瑪步兵:BAAALgAECgYJDQAAAA==.',
['奶乃']='奶乃牛牛:BAAALgAFFAIJAgAAAA==.',
['如果']='如果:BAAALgAECgEJAQAAAA==.',
['嬌爽']='嬌爽:BAABLgAFFH8IAAMSAAMJ+xqIBwAqAQASAAMJ+xqIBwAqAQATAAEJYgc2KwBFAAAAAA==.',
['孟战']='孟战冲冲:BAAALgADCgEJAQAAAA==.',
['宇宙']='宇宙无敌龙神:BAAALgAFFAEJAQAAAA==.',
['寂靜']='寂靜的霜火:BAAALgAECgMJAwAAAA==.',
['小小']='小小妮酱:BAAALgAECgEJAQAAAA==.',
['小白']='小白一个:BAAALgAECgUJDQAAAA==.',
['小的']='小的魔法:BAAALgAFFAIJBAAAAA==.',
['小蓝']='小蓝帽:BAAALgAECgYJCAAAAA==.',
['小邪']='小邪神酱:BAAALgAECgEJAgAAAA==.',
['尐仙']='尐仙女吖:BAABLgAECn8VAAIUAAcJphNEKQCoAQAUAAcJphNEKQCoAQAAAA==.',
['少女']='少女苦涩心事:BAAALgAECgEJAQAAAA==.',
['尼古']='尼古拉斯猫:BAAALgAECgcJDAAAAA==.',
['尼可']='尼可狐尼可:BAAALgAECgYJCgAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8NAAIOAAUJFghGCQAAAQAOAAUJFghGCQAAAQAAAA==.',
['山水']='山水有重逢:BAAALgAECgYJDwAAAA==.',
['川渝']='川渝特暴龙:BAAALgAECgEJAQAAAA==.',
['差不']='差不多调调:BAAALgADCgYJBgAAAA==.',
['师爷']='师爷包有为:BAAALgAECgYJBgAAAA==.',
['带三']='带三个表:BAABLgAFFH8LAAMBAAQJgBQsBQAtAQABAAQJgBQsBQAtAQACAAIJGBiUFgCjAAAAAA==.',
['幂幂']='幂幂楠:BAAALgAECgMJAwAAAA==.',
['年迈']='年迈的德德:BAABLgAECn8VAAIRAAgJgxQAVwCdAQARAAgJgxQAVwCdAQAAAA==.',
['影逝']='影逝沙漏:BAAALgAECgEJAQAAAA==.',
['徐盼']='徐盼盼:BAAALgAECgIJAgAAAA==.',
['德道']='德道高僧:BAAALgADCgUJBQAAAA==.',
['心中']='心中有猛虎:BAABLgAFFH8GAAIVAAMJExjcDwAKAQAVAAMJExjcDwAKAQAAAA==.',
['忧忧']='忧忧:BAAALgADCgEJAQAAAA==.',
['愤怒']='愤怒哋西瓜:BAAALgAFFAEJAQAAAA==.愤怒滴芒果:BAABLgAFFH8HAAIOAAMJAQUgFwC4AAAOAAMJAQUgFwC4AAAAAA==.愤怒的尛德:BAAALgAECgEJAgAAAA==.愤怒的西瓜:BAABLgAFFH8OAAMWAAQJzwjNHQApAQAWAAQJbwjNHQApAQAHAAQJ5gHnBgDCAAAAAA==.',
['愿圣']='愿圣光忽悠你:BAAALgAECgEJAQAAAA==.',
['我爱']='我爱长发飘飘:BAAALgAECgQJBAAAAA==.',
['战丶']='战丶小糊涂:BAAALgADCgEJAQAAAA==.',
['抛弃']='抛弃温柔:BAAALgAFFAEJAQAAAA==.',
['抹茶']='抹茶拿铁:BAAALgAFFAIJAwAAAA==.',
['捣蛋']='捣蛋西西:BAAALgAFFAIJAgAAAA==.',
['攞琳']='攞琳莎娜:BAAALgAECgMJAwAAAA==.',
['救救']='救救我:BAAALgADCgEJAQAAAA==.',
['斯维']='斯维因:BAAALgAFFAIJAgAAAA==.',
['新之']='新之助:BAACLgAFFH8GAAIWAAIJPxDEIwCXAAAWAAIJPxDEIwCXAAAuAAQKfxgAAhYACAlIFy5QAAECABYACAlIFy5QAAECAAAA.',
['无冕']='无冕之王:BAAALgADCgIJAgAAAA==.',
['无心']='无心无我:BAAALgAECgYJBgAAAA==.',
['无罪']='无罪之魂:BAAALgAFFAIJAgAAAA==.',
['旧丶']='旧丶景:BAAALgAECgYJDgAAAA==.',
['易边']='易边桥:BAAALgAECgMJBAAAAA==.',
['星光']='星光璀璨:BAAALgAECgQJBAAAAA==.',
['春风']='春风吹拂:BAAALgAECgUJBgAAAA==.',
['晚风']='晚风孤夜:BAAALgADCgEJAQAAAA==.',
['暗光']='暗光:BAAALgAECgcJBwAAAA==.',
['暗黑']='暗黑佟大为:BAABLgAFFH8GAAIXAAQJygbGAgAzAQAXAAQJygbGAgAzAQAAAA==.',
['曼陀']='曼陀罗:BAAALgAECgEJAQAAAA==.',
['朝映']='朝映夕颜:BAACLgAFFH8JAAIMAAMJvhPJFQD8AAAMAAMJvhPJFQD8AAAuAAQKfxgAAgwACAmBHsIeALMCAAwACAmBHsIeALMCAAAA.',
['木子']='木子:BAAALgAECgUJBAAAAA==.',
['木拉']='木拉猫:BAACLgAFFH8FAAIGAAIJ0hSzOQC3AAAGAAIJ0hSzOQC3AAAuAAQKfxcAAwYABwkdHUhUADsCAAYABwkjHEhUADsCABgAAQliIQsYAFgAAAAA.木拉猫五号:BAAALgAECgYJBgAAAA==.木拉猫四号:BAAALgAECgYJBwABLgAFFAIJBQAGANIUAA==.',
['未吱']='未吱:BAAALgAECgEJAgAAAA==.',
['村花']='村花:BAAALgAECgIJAgAAAA==.',
['来凤']='来凤鱼:BAAALgAECgcJBwAAAA==.',
['来啦']='来啦老弟:BAAALgAFFAIJAwABLgAFFAQJDQAWAEkbAA==.',
['枫丶']='枫丶叶:BAAALgAFFAMJAwAAAA==.',
['枫纹']='枫纹:BAAALgADCgQJBAAAAA==.',
['柒玥']='柒玥寒堸:BAAALgAECgEJAQAAAA==.',
['柠檬']='柠檬爱吃柚子:BAABLgAFFH8RAAIRAAYJmyADAQDYAQARAAYJmyADAQDYAQAAAA==.',
['桑娜']='桑娜丶逐星:BAAALgAECgYJBwAAAA==.',
['梅芙']='梅芙:BAAALgAECgYJBgAAAA==.',
['橙双']='橙双橙对:BAAALgAECgkJCQAAAA==.',
['欧尼']='欧尼酱丶:BAAALgAECgYJCwAAAA==.',
['武人']='武人仙风:BAAALgAECgkJCAAAAA==.',
['武汉']='武汉热干面:BAAALgAECgkJBwAAAA==.',
['殇心']='殇心之傷:BAAALgAECgMJAwAAAA==.',
['江湖']='江湖多面首:BAAALgADCgUJBwAAAA==.',
['沐芷']='沐芷:BAAALgADCgUJBQAAAA==.',
['泰罗']='泰罗奥特曼:BAAALgAECgcJBgAAAA==.',
['洪帮']='洪帮山鸡:BAAALgAECgYJCgAAAA==.',
['流落']='流落在外:BAAALgAECgQJBAAAAA==.',
['海风']='海风微微甜:BAAALgAECgEJAgAAAA==.',
['淮扬']='淮扬菜:BAAALgAFFAEJAQAAAA==.',
['混血']='混血法:BAAALgADCgIJAgAAAA==.',
['清风']='清风抚雨:BAAALgAECgYJBgAAAA==.清风道人:BAAALgAECgEJAQAAAA==.',
['澄澈']='澄澈之水:BAAALgADCgcJBwAAAA==.',
['火法']='火法帝:BAAALgAFFAIJAgAAAA==.',
['灬冬']='灬冬至灬:BAAALgAFFAEJAQAAAA==.',
['灬圣']='灬圣魂灬:BAAALgAECgYJCQAAAA==.',
['無伈']='無伈戀愛:BAAALgAECgIJAwABLgAECgYJBgANAAAAAA==.',
['熊霸']='熊霸天下:BAABLgAFFH8FAAIOAAIJpQd4HwB7AAAOAAIJpQd4HwB7AAAAAA==.',
['爱不']='爱不爱绿冻:BAAALgAECgEJAQAAAA==.',
['爱做']='爱做梦的小兔:BAAALgADCgMJAwAAAA==.',
['牛的']='牛的花:BAAALgAECgUJBQAAAA==.',
['狂暴']='狂暴蜗牛:BAAALgAFFAEJAgAAAA==.',
['狗蛋']='狗蛋兒:BAAALgAFFAQJBAAAAA==.',
['猫咪']='猫咪弓爵:BAAALgAECgIJAgAAAA==.',
['獸人']='獸人吼吼:BAAALgAFFAIJBAAAAA==.',
['瓜瓜']='瓜瓜的瓜:BAAALgAECgIJAgAAAA==.',
['甜柚']='甜柚柚小莓冰:BAAALgAECgYJBwAAAA==.',
['画冰']='画冰:BAAALgAECgQJBAAAAA==.',
['疯舞']='疯舞酒天:BAAALgADCgQJBAAAAA==.',
['疾风']='疾风骤雨:BAAALgAECgYJCQAAAA==.',
['痛打']='痛打落水狗:BAAALgAECgYJEQAAAA==.',
['白喵']='白喵:BAAALgAECgEJAwAAAA==.',
['盈盈']='盈盈一水间:BAACLgAFFH8HAAIKAAMJ/R0RCAAPAQAKAAMJ/R0RCAAPAQAuAAQKfx8AAgoACAniInMHABUDAAoACAniInMHABUDAAAA.',
['眼角']='眼角的错觉:BAAALgAECgEJAwAAAA==.',
['砂糖']='砂糖橘:BAAALgAECgMJAwAAAA==.',
['示申']='示申讠舌:BAAALgADCgEJAQAAAA==.',
['秃头']='秃头丶披风侠:BAAALgAECgUJBQAAAA==.',
['科學']='科學超電磁炮:BAACLgAFFH8GAAIEAAIJJwq4CQCdAAAEAAIJJwq4CQCdAAAuAAQKfxUAAwQABwmSGykWADcCAAQABwmSGykWADcCABQABgljHswdAPABAAAA.',
['策士']='策士丶斯维因:BAAALgAECgEJAQAAAA==.',
['粑粑']='粑粑大王:BAAALgAECgEJAQAAAA==.',
['精神']='精神力旋冲:BAAALgAECgMJAwAAAA==.',
['糖醋']='糖醋鱼之焱:BAAALgAECgQJBAAAAA==.',
['红富']='红富士苹果:BAAALgAECgUJBQAAAA==.',
['纹胸']='纹胸:BAAALgAECgEJAgAAAA==.',
['继续']='继续颓废:BAAALgAECgcJBwAAAA==.',
['羊蹄']='羊蹄翘起来:BAAALgAECgYJCQAAAA==.',
['美味']='美味母龙:BAAALgAECgYJCAAAAA==.美味虚空:BAAALgADCgUJBQABLgAECgYJCAANAAAAAA==.',
['老子']='老子整把来复:BAAALgADCgIJAgAAAA==.',
['聋的']='聋的传人:BAAALgAECgYJCgAAAA==.',
['肆拾']='肆拾叁:BAAALgAECgIJAgAAAA==.',
['肖兮']='肖兮兮:BAABLgAFFH8HAAMSAAQJ1wWEDADuAAATAAQJkQNUFAD8AAASAAMJOweEDADuAAAAAA==.',
['胖胖']='胖胖拳:BAAALgAFFAIJAwAAAA==.',
['艾拉']='艾拉酱:BAAALgAECgUJCAABLgAFFAIJBgAEACcKAA==.',
['花葬']='花葬丶:BAAALgAECgEJAQAAAA==.',
['苏夕']='苏夕鹤:BAAALgADCgUJBQAAAA==.',
['蓝柠']='蓝柠:BAAALgADCgUJBQAAAA==.',
['蓝色']='蓝色忧伤:BAAALgADCgEJAQAAAA==.',
['藤条']='藤条焖猪腿:BAABLgAECn8UAAMWAAcJpyCaMAB1AgAWAAcJpyCaMAB1AgAZAAIJaBDoBwB9AAAAAA==.',
['虛無']='虛無中的舞者:BAACLgAFFH8IAAIEAAMJ4hQ1BgD2AAAEAAMJ4hQ1BgD2AAAuAAQKfx8AAwQACAnKGesRAGwCAAQACAnKGesRAGwCABQAAgnYBCNzAFsAAAAA.',
['蛋丶']='蛋丶蛋:BAAALgAECgMJAwAAAA==.',
['蝶舞']='蝶舞菱紗:BAAALgAECgMJAwABLgAFFAQJDQAUAMgHAA==.',
['血月']='血月缝魂:BAAALgAECgMJAwAAAA==.',
['裂蹄']='裂蹄残角丨:BAAALgAECgEJAQAAAA==.',
['西瓜']='西瓜瓜:BAAALgAFFAIJAwAAAA==.',
['覆水']='覆水:BAAALgAECgcJDQAAAA==.',
['说句']='说句不好吃的:BAAALgAFFAEJAQAAAA==.',
['谁知']='谁知道是谁:BAAALgAECgEJAQAAAA==.',
['賊神']='賊神:BAABLgAECn8tAAILAAgJqhr3AwDxAQALAAgJqhr3AwDxAQAAAA==.',
['贫道']='贫道稽首:BAAALgAECgMJAwAAAA==.',
['辛德']='辛德萌拉:BAAALgAECgMJAwAAAA==.',
['逍遥']='逍遥小苹果:BAAALgAECgEJAgAAAA==.',
['道法']='道法自燃:BAACLgAFFH8FAAIGAAMJZBv8FQAIAQAGAAMJZBv8FQAIAQAuAAQKfx0AAgYACAlXHIQvALQCAAYACAlXHIQvALQCAAAA.',
['铁血']='铁血灬游龍:BAAALgAECgYJCgAAAA==.',
['锅盔']='锅盔像锅盖:BAAALgAECgEJAQAAAA==.',
['镜雨']='镜雨:BAACLgAFFH8HAAIWAAMJwwEGGwC2AAAWAAMJwwEGGwC2AAAuAAQKfx8AAhYACAlLEthbAN4BABYACAlLEthbAN4BAAEuAAUUBQkFABYAMgoA.',
['长泽']='长泽雅美:BAAALgAFFAIJBAAAAA==.',
['闪现']='闪现撞了墙:BAAALgADCgMJAwAAAA==.',
['陳大']='陳大师:BAAALgAECgYJCgAAAA==.',
['隋右']='隋右边:BAAALgADCgIJAgAAAA==.',
['雪怜']='雪怜儿:BAAALgAECgIJBAAAAA==.',
['雪落']='雪落人间:BAAALgAECgQJEAAAAA==.',
['雾都']='雾都夜话:BAAALgAECgEJAQAAAA==.雾都情迷丶:BAAALgAECgIJAwAAAA==.雾都旧梦丶:BAAALgAECgEJAQAAAA==.',
['非酋']='非酋韦小宝:BAAALgAECgYJEQAAAA==.',
['风扑']='风扑扑:BAACLgAFFH8HAAMRAAMJbReQEQDrAAARAAMJ8RKQEQDrAAAaAAEJxhDQDABTAAAuAAQKfx4AAxEACAmqFXA4ABMCABEACAmqFXA4ABMCABoABQn+Dbs9AAYBAAAA.',
['风暴']='风暴烈茶:BAAALgAECgEJAgAAAA==.',
['风魇']='风魇:BAAALgADCgUJBQAAAA==.',
['香草']='香草:BAAALgAECgUJBQAAAA==.',
['马老']='马老板之怒:BAABLgAFFH8GAAIVAAQJ3w5dBABBAQAVAAQJ3w5dBABBAQABLgAFFAUJCgAbAHUSAA==.',
['骄傲']='骄傲的小火车:BAAALgADCgcJBwAAAA==.',
['高老']='高老板之丶:BAABLgAECn8XAAITAAkJfx8rBwAnAwATAAkJfx8rBwAnAwABLgAFFAUJEgAIAAYgAA==.高老板之癫:BAAALgAECgcJDgABLgAFFAYJFgALAJYgAA==.',
['魂殇']='魂殇丶:BAAALgAECgkJCQAAAA==.',
['魅影']='魅影随风:BAAALgAFFAEJAQAAAA==.',
['魍魉']='魍魉丑丑:BAAALgAECgYJCgAAAA==.',
['魔光']='魔光碎碎念:BAAALgAECgEJAQAAAA==.',
['魔力']='魔力猫咪:BAAALgAECgMJBAABLgAFFAIJAwANAAAAAA==.',
['鱼子']='鱼子酱丶:BAAALgAECgIJAgAAAA==.',
['鲤鯉']='鲤鯉媛上草:BAAALgAECgcJBAABLgAFFAYJDAASAJ8SAA==.',
['鲤鲤']='鲤鲤媛上草:BAAALgAECgkJCQAAAA==.',
['黑化']='黑化回会飞花:BAAALgADCgUJBQAAAA==.',
['黧黑']='黧黑牧言:BAAALgAECgEJAgAAAA==.',
['龍城']='龍城武丶僧:BAAALgAFFAQJBAAAAA==.',
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
