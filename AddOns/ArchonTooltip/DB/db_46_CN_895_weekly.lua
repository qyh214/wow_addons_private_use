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

local lookup = {'Monk-Mistweaver','Unknown-Unknown','Monk-Windwalker','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Frost','Shaman-Restoration','Evoker-Preservation','DemonHunter-Devourer','DeathKnight-Blood','Monk-Brewmaster','Paladin-Retribution','Rogue-Subtlety','Druid-Guardian','Hunter-Survival','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Evoker-Augmentation','Warrior-Protection','Shaman-Elemental','Warrior-Fury','Warrior-Arms','DemonHunter-Havoc',}
local provider = {region='CN',realm='黑暗之矛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexl:BAAALgADCgUJBQAAAA==.',
Ba='Bastion:BAAALgAECgUJBQAAAA==.',
Cr='Crazybaby:BAAALgAECgYJDgAAAA==.Crazymoney:BAAALgAECgIJAgAAAA==.Cristiano:BAAALgAECgYJBgAAAA==.Crooy:BAAALgAECgEJAQAAAA==.',
Da='Darktifa:BAAALgAECgYJDAAAAA==.',
Kh='Khazix:BAAALgADCgEJAQAAAA==.',
Kr='Kroos:BAAALgAECgQJBgAAAA==.',
La='Laobie:BAAALgAFFAEJAQAAAA==.',
Ro='Ronin:BAABLgAECn8XAAIBAAYJWxv1BwCrAQABAAYJWxv1BwCrAQAAAA==.',
Sa='Sadism:BAAALgAECgEJAQAAAA==.Saeed:BAAALgADCgIJAgAAAA==.',
Sw='Sweetbun:BAAALgAECgEJAQAAAA==.',
Yd='Yd:BAAALgAECgMJAwAAAA==.',
Ye='Yeei:BAAALgAECgEJAQAAAA==.',
['一抹']='一抹夏凉:BAAALgADCgUJBQABLgAFFAQJBAACAAAAAA==.',
['三千']='三千个圣骑:BAAALgAECgEJAQAAAA==.',
['不落']='不落的荣燿:BAAALgAECgYJCAAAAA==.',
['东阳']='东阳:BAAALgAECgQJBAAAAA==.',
['丶一']='丶一个贼:BAAALgAECgYJBgAAAA==.',
['丶女']='丶女士不爽:BAAALgAECgUJBQAAAA==.',
['丶莉']='丶莉莉丝:BAAALgAECgUJBQAAAA==.',
['丶软']='丶软绵绵:BAAALgAECgQJBAAAAA==.',
['丿灬']='丿灬香草:BAAALgAECgMJBAAAAA==.',
['乄与']='乄与田祐希:BAAALgAFFAIJBAAAAA==.',
['乄时']='乄时肆初冬:BAAALgAFFAIJAgAAAA==.',
['乌尔']='乌尔奇奥拉丶:BAAALgAECgkJEAAAAA==.',
['二踢']='二踢脚:BAACLgAFFH8NAAMBAAQJmwKjCwDrAAABAAQJmwKjCwDrAAADAAQJsQGaBwCgAAAuAAQKfx8AAwEACAmHE8MeAMABAAEACAmHE8MeAMABAAMABQloCN1VALkAAAAA.',
['二锤']='二锤:BAAALgAFFAIJAwAAAA==.',
['五更']='五更丶琉璃:BAAALgAECgIJAgAAAA==.',
['人心']='人心薄凉丶伤:BAABLgAECn8YAAMEAAkJ+BkWDQDHAgAEAAgJChoWDQDHAgAFAAcJ9hchLAD/AQAAAA==.',
['仙尊']='仙尊洛尘:BAABLgAECn8VAAMGAAkJ0hhIGgBqAgAGAAgJphlIGgBqAgAHAAcJmxEFNwCIAQAAAA==.',
['伊卡']='伊卡璐斯:BAAALgADCgcJBwAAAA==.',
['伊斯']='伊斯塔战灵:BAACLgAFFH8MAAIIAAQJNRF1GwBdAQAIAAQJNRF1GwBdAQAuAAQKfyUAAggACAnEH6EoANACAAgACAnEH6EoANACAAEuAAUUBQkHAAgAxxkA.',
['伊莉']='伊莉安斯菲尔:BAABLgAECn8ZAAMHAAgJxBu0GwBHAgAHAAgJkRq0GwBHAgAGAAUJGR7WOwC/AQAAAA==.',
['你是']='你是我宠物:BAAALgAECgMJAwAAAA==.',
['依旧']='依旧如前:BAAALgAFFAEJAQAAAA==.',
['元素']='元素洪流:BAAALgAECggJCwAAAA==.',
['光之']='光之凯哥:BAACLgAFFH8RAAIJAAUJiQ2JAgCDAQAJAAUJiQ2JAgCDAQAuAAQKfysAAwkACAllGLUaAAYCAAkACAnGF7UaAAYCAAoABQkfDhczAAkBAAAA.',
['克里']='克里斯蒂亚诺:BAACLgAFFH8FAAMLAAIJWwVPSgCLAAALAAIJ5gNPSgCLAAAMAAEJPgRvBQBOAAAuAAQKfxUAAgsACAnBExhQAAECAAsACAnBExhQAAECAAAA.',
['兔子']='兔子姬:BAAALgADCgMJAwAAAA==.',
['全踏']='全踏马妈格汗:BAAALgAECgkJEAAAAA==.',
['八叉']='八叉胡:BAAALgAECgEJAQAAAA==.',
['冬月']='冬月:BAAALgAFFAIJAgABLgAFFAYJCgANAHYKAA==.',
['冰缘']='冰缘:BAAALgAECgMJAwAAAA==.',
['凌空']='凌空抽射:BAAALgAECgUJBQAAAA==.',
['凛冬']='凛冬疾风:BAAALgADCgIJAgAAAA==.',
['凝雪']='凝雪:BAAALgAECgMJAwAAAA==.',
['刑天']='刑天之泪:BAAALgAFFAIJAwABLgAFFAMJBgAOAC4WAA==.',
['初雪']='初雪:BAAALgAFFAEJAQAAAA==.',
['勒个']='勒个痛不痛:BAAALgAFFAQJAgAAAA==.',
['华里']='华里六六:BAAALgAECgYJBgAAAA==.华里六叔:BAAALgAECgYJCwAAAA==.华里六月:BAAALgAECgUJBQAAAA==.华里六魔:BAAALgAECgYJBAAAAA==.华里六鸢:BAAALgAECgEJAQAAAA==.华里十七:BAAALgAECgYJCQAAAA==.华里十二:BAAALgAECgYJCAAAAA==.华里大德:BAAALgADCgEJAQAAAA==.华里怒怒:BAAALgAECgQJBAAAAA==.',
['单线']='单线程:BAAALgAECgkJCQAAAA==.',
['卡多']='卡多雷正黄旗:BAABLgAFFH8JAAIPAAMJcxGAHQDpAAAPAAMJcxGAHQDpAAAAAA==.',
['卡波']='卡波基炮灰:BAAALgADCgQJBQAAAA==.',
['卷王']='卷王:BAAALgAFFAIJAgAAAA==.',
['变的']='变的心烦:BAAALgAECgIJAwAAAA==.',
['吟风']='吟风:BAAALgAECgYJBgAAAA==.',
['吴织']='吴织亚切:BAAALgAFFAEJAQAAAA==.',
['周杰']='周杰伦:BAAALgAFFAIJAgAAAA==.',
['周润']='周润发:BAAALgAECgEJAQAAAA==.',
['咖喱']='咖喱快回家:BAAALgADCgMJAwAAAA==.',
['喵喵']='喵喵柒:BAAALgAECgUJBQAAAA==.',
['喵小']='喵小锤:BAAALgAECgYJBgAAAA==.',
['喵法']='喵法无边:BAAALgAECgcJBQAAAA==.',
['嗷呜']='嗷呜就一口:BAAALgAECgEJAQAAAA==.',
['嘉然']='嘉然吃什么:BAAALgAECgEJAQAAAA==.',
['噩梦']='噩梦中的舞者:BAAALgADCgUJBQAAAA==.',
['噩耗']='噩耗乌鸦:BAAALgAECgYJBgAAAA==.',
['回忆']='回忆的海风:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光将熄丶:BAACLgAFFH8XAAMLAAYJIiCDAQAYAgALAAYJIiCDAQAYAgAQAAEJAAB6GQA3AAAuAAQKfxoAAgsACQnsJLQEAIgDAAsACQnsJLQEAIgDAAAA.圣光骑:BAAALgADCgIJAgAAAA==.',
['圣火']='圣火徽章:BAAALgAECgYJBgAAAA==.',
['在这']='在这狂混:BAAALgADCgEJAQAAAA==.',
['夏湾']='夏湾:BAAALgAECgcJEAAAAA==.',
['夕梦']='夕梦:BAAALgAECgEJAQAAAA==.',
['夜色']='夜色小小美:BAAALgAFFAIJAgAAAA==.',
['夜雨']='夜雨未央丶:BAAALgAFFAMJAwAAAA==.',
['夜风']='夜风琪士:BAAALgADCgUJBQAAAA==.',
['大肥']='大肥:BAABLgAECn8ZAAMDAAkJahoiCwDHAgADAAkJHBkiCwDHAgARAAkJYhMdGwArAgAAAA==.',
['天地']='天地有清风:BAAALgAECgcJCAAAAA==.',
['天天']='天天:BAAALgAECgQJCwAAAA==.',
['天迹']='天迹:BAAALgAECgcJEgAAAA==.',
['太极']='太极须弥熊:BAAALgAECgQJCAAAAA==.',
['失去']='失去的回忆:BAAALgADCgMJAwAAAA==.',
['奇奇']='奇奇妙妙:BAAALgAECgQJBgAAAA==.',
['妈个']='妈个汗售任:BAABLgAECn8UAAMGAAgJNxjuJgAeAgAGAAgJAhXuJgAeAgAHAAEJbhbzgABCAAAAAA==.',
['婷婷']='婷婷妹:BAAALgAECgkJEAAAAA==.',
['嫂子']='嫂子丶:BAAALgAECgYJBgAAAA==.',
['子墨']='子墨抒画:BAAALgAECgEJAQAAAA==.',
['宇宙']='宇宙恶霸罗峰:BAABLgAFFH8HAAMGAAQJgxIGBQBTAQAGAAQJHhAGBQBTAQAHAAEJYxa2JABVAAAAAA==.',
['安居']='安居乐业:BAAALgAFFAQJBAAAAA==.',
['安静']='安静的土豆:BAAALgADCgcJCAAAAA==.',
['寒夜']='寒夜:BAAALgAECgEJAQAAAA==.',
['封号']='封号斗锣:BAAALgAECgcJBwAAAA==.',
['射政']='射政王:BAAALgAECgEJAQAAAA==.',
['專業']='專業打臉:BAAALgAECgYJDAAAAA==.',
['小披']='小披风:BAAALgAECgYJEQAAAA==.',
['小猎']='小猎残月:BAACLgAFFH8MAAMGAAQJXhd7BQBMAQAGAAQJGBF7BQBMAQAHAAMJhBFcFgDoAAAuAAQKfyQAAwcACQmZIt0MAN4CAAcACAnrIN0MAN4CAAYABglhIzwXAH8CAAAA.',
['小西']='小西果果:BAAALgAECgEJAQAAAA==.',
['小野']='小野塚小町:BAAALgADCgQJBAAAAA==.',
['小雪']='小雪柒:BAAALgAECgEJAwAAAA==.',
['小麻']='小麻鼠:BAAALgAECgcJBwAAAA==.',
['尖妮']='尖妮儿盘蚊香:BAABLgAECn8WAAISAAcJ8ResUADvAQASAAcJ8ResUADvAQAAAA==.',
['尘緣']='尘緣淺:BAAALgAECgYJDAAAAA==.',
['尤娜']='尤娜娅:BAAALgAECgcJCwAAAA==.',
['局中']='局中人:BAAALgAECgQJBAAAAA==.',
['屋无']='屋无五物:BAABLgAECn8aAAITAAcJRxKuCgBOAQATAAcJRxKuCgBOAQAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8NAAIRAAUJuAvBBwBWAQARAAUJuAvBBwBWAQAAAA==.',
['山水']='山水:BAAALgAECgQJBwAAAA==.',
['山涧']='山涧的雨:BAABLgAECn8VAAIIAAgJrB0TKQDOAgAIAAgJrB0TKQDOAgAAAA==.',
['山走']='山走云停:BAAALgADCgUJBQAAAA==.',
['崽崽']='崽崽:BAAALgAECgYJBgAAAA==.',
['川烟']='川烟雨:BAAALgAECgYJCQABLgAECgcJEgACAAAAAA==.',
['巫山']='巫山不是云:BAAALgAECgEJAgAAAA==.',
['巴尔']='巴尔:BAAALgAECgcJDQAAAA==.巴尔之殇:BAAALgAECgQJBAAAAA==.巴尔之魂:BAAALgAECgIJAwAAAA==.',
['布狄']='布狄卡:BAAALgADCgcJBwAAAA==.',
['幻化']='幻化成风:BAAALgAECgkJCQAAAA==.',
['弗拉']='弗拉基宓尔:BAAALgAECgcJAQABLgAFFAcJCgAIAO4cAA==.',
['强風']='强風吹拂:BAAALgAECgEJAQAAAA==.',
['强风']='强风吹拂:BAAALgAECgIJAgAAAA==.',
['彭彭']='彭彭丶:BAACLgAFFH8NAAMEAAUJKxYhAwBcAQAEAAUJKxYhAwBcAQAUAAEJaAWvBwAsAAAuAAQKfycAAwQACAnnINoJAPcCAAQACAnnINoJAPcCABQABwn5GBsOAKABAAAA.',
['德丶']='德丶福斯:BAAALgAECgUJBQAAAA==.',
['德系']='德系混动咕:BAAALgAECgYJBwAAAA==.',
['忒休']='忒休斯:BAAALgADCgUJBQAAAA==.',
['怒风']='怒风咆哮:BAAALgAECgcJCgAAAA==.',
['思媛']='思媛妹妹:BAAALgADCgIJAgABLgAFFAQJCAAKALIUAA==.',
['性感']='性感小罩罩丶:BAABLgAFFH8HAAISAAMJyQ6wFwDwAAASAAMJyQ6wFwDwAAAAAA==.',
['怯情']='怯情:BAAALgAECgUJBQAAAA==.',
['意大']='意大利炮:BAAALgAECgIJAgAAAA==.',
['我不']='我不是貓姬:BAAALgAECgEJAQAAAA==.',
['我是']='我是传奇:BAAALgAECgMJAwAAAA==.我是牛氓:BAAALgAECgEJAgAAAA==.',
['我爱']='我爱专专:BAAALgAECgMJAwAAAA==.',
['我骑']='我骑我袖:BAAALgAECgQJBQAAAA==.',
['戰殇']='戰殇:BAAALgAECgkJBwAAAA==.',
['扶摇']='扶摇:BAAALgAECgYJCQAAAA==.',
['抠鼻']='抠鼻:BAACLgAFFH8QAAQHAAUJTCStCACPAQAHAAQJpCOtCACPAQAVAAMJ0B9zAgAzAQAGAAIJHSM3DwDQAAAuAAQKfycABAYACAmqJiEIAA4DAAYABwlVJiEIAA4DAAcABwk6JYcQALUCABUABQk7Jb4EALsBAAAA.',
['拎狐']='拎狐冲:BAAALgAECgUJCgAAAA==.',
['摩法']='摩法披风:BAAALgAECgYJCQAAAA==.',
['撒撕']='撒撕给:BAAALgAECgkJDgAAAA==.',
['改正']='改正归邪:BAAALgAFFAIJAgAAAA==.',
['文武']='文武贝:BAAALgAECgUJBwAAAA==.',
['无坚']='无坚不摧之力:BAAALgAECgMJBQAAAA==.',
['星小']='星小狐:BAAALgAFFAIJAgAAAA==.',
['星空']='星空海螺:BAABLgAFFH8FAAIHAAUJOR5GBQDXAQAHAAUJOR5GBQDXAQAAAA==.',
['是萝']='是萝莉呀:BAAALgAECgYJBgAAAA==.',
['晓暧']='晓暧丶卫队长:BAAALgAECgMJAwAAAA==.',
['晓法']='晓法残月:BAAALgAECgYJAQAAAA==.',
['暗夜']='暗夜劣:BAAALgAECgIJAgAAAA==.暗夜劣手:BAAALgAECgMJAwAAAA==.暗夜术:BAAALgAECgIJAgAAAA==.',
['暗影']='暗影大叔:BAABLgAFFH8VAAMWAAUJpR8XAADvAQAWAAUJXx0XAADvAQAXAAUJnxy1BgC3AQAAAA==.',
['暗芝']='暗芝居:BAACLgAFFH8QAAMYAAUJDxqMBABCAQAXAAQJ/hm8EABcAQAYAAQJehaMBABCAQAuAAQKfycABBgACAn/IhIDAMoCABgACAmVHxIDAMoCABYACAnyIMsCAIgCABcABgkkHtZJAOwBAAAA.',
['暴力']='暴力的招式:BAAALgAECgQJCAAAAA==.',
['最后']='最后的亲雨:BAABLgAFFH8IAAMGAAQJQhOEDQDxAAAGAAMJFwuEDQDxAAAHAAIJCRhTGwCpAAAAAA==.',
['月曦']='月曦言:BAAALgAFFAEJAQAAAA==.',
['月牛']='月牛老姐姐:BAAALgAECgYJBwAAAA==.',
['木心']='木心:BAAALgAECgYJBgAAAA==.',
['朴树']='朴树散花:BAACLgAFFH8RAAIPAAUJfCCwBADiAQAPAAUJfCCwBADiAQAuAAQKfyUAAg8ACAnNJUwGAGEDAA8ACAnNJUwGAGEDAAAA.',
['极度']='极度之凶凶:BAAALgAECgkJCQAAAA==.',
['枫樾']='枫樾岚:BAAALgAECgIJAgAAAA==.',
['枯雪']='枯雪:BAAALgAECgcJDQAAAA==.',
['柒柒']='柒柒喵:BAAALgAECgQJBAAAAA==.',
['柔弱']='柔弱的小拳拳:BAAALgAECgQJBwAAAA==.',
['柳丷']='柳丷:BAAALgAFFAQJBAAAAA==.',
['格斗']='格斗小熊:BAAALgAECgcJBwAAAA==.',
['格蕾']='格蕾丝:BAAALgAECgMJBAAAAA==.',
['桃谷']='桃谷绘里香:BAAALgAECgQJBAAAAA==.',
['棒棒']='棒棒糖呷:BAAALgAECgEJAQAAAA==.',
['楚乔']='楚乔:BAAALgAECgcJCgABLgAFFAQJCwAGACIZAA==.',
['欧皇']='欧皇蛋丷:BAACLgAFFH8RAAMOAAUJ6ApxBwB2AQAOAAUJ6ApxBwB2AQAZAAEJKQi+IgBIAAAuAAQKfycAAw4ACAm3E8AUAPwBAA4ACAm3E8AUAPwBABkAAgntFYAdAIYAAAAA.',
['欺诈']='欺诈大师:BAAALgAECgQJBAAAAA==.',
['此号']='此号有人:BAAALgAFFAEJAgAAAA==.',
['歪崽']='歪崽崽:BAAALgAECgYJBwAAAA==.',
['死神']='死神的斩月:BAABLgAECn8YAAIIAAkJFBOyRABqAgAIAAkJFBOyRABqAgAAAA==.',
['毛团']='毛团子:BAAALgAECgIJAgABLgAFFAcJDQAaAM4ZAA==.',
['气体']='气体源流:BAAALgAECgEJAgAAAA==.',
['没有']='没有姿淡了:BAAALgAECgYJBwAAAA==.',
['泥鳅']='泥鳅:BAAALgAECgYJBgAAAA==.',
['泪痕']='泪痕:BAAALgAECgYJDAAAAA==.',
['泰瑞']='泰瑞昂黎明:BAACLgAFFH8PAAQLAAUJbyGYCgB9AQALAAQJOCCYCgB9AQAMAAMJBxqcAQAXAQAQAAEJAACoEABsAAAuAAQKfyoAAgsACAmrJTYKAEoDAAsACAmrJTYKAEoDAAAA.',
['洛无']='洛无极:BAABLgAECn8fAAMGAAkJnBlDDwDBAgAGAAkJKhlDDwDBAgAHAAYJ7RM5PABsAQAAAA==.',
['浮生']='浮生若清风:BAAALgAECgcJBwAAAA==.',
['海公']='海公牛:BAAALgAFFAEJAQAAAA==.',
['淡漠']='淡漠丶丶燕:BAAALgADCgMJBAAAAA==.淡漠丶赐:BAAALgAECgEJAQAAAA==.',
['渔家']='渔家傲丶孤岭:BAAALgAFFAMJBAAAAA==.',
['游狼']='游狼捕手:BAAALgAECgMJAwAAAA==.',
['灭绝']='灭绝师太:BAAALgAECgEJAQAAAA==.',
['灰灰']='灰灰大魔王:BAACLgAFFH8QAAMGAAUJMxmgAAC5AQAGAAUJMxmgAAC5AQAHAAEJVwA6LgAvAAAuAAQKfygAAwYACAkCI3cbAGICAAYABwngIncbAGICAAcABgmJGkErANABAAAA.',
['烂丶']='烂丶人:BAAALgAECgcJBwAAAA==.',
['烟云']='烟云暮暮朝朝:BAAALgAECgcJCAAAAA==.烟云漫村庄:BAAALgAECgYJBwAAAA==.烟云随风:BAAALgAECgYJCgAAAA==.',
['熊猫']='熊猫熊:BAAALgAECgYJBgAAAA==.',
['爱芷']='爱芷灵儿:BAAALgAECgYJDwAAAA==.',
['牛发']='牛发发:BAABLgAECn8WAAIEAAkJBwGvdABQAAAEAAkJBwGvdABQAAAAAA==.',
['牧瀨']='牧瀨红莉棲:BAAALgAECgIJAgAAAA==.',
['狒学']='狒学弟:BAACLgAFFH8UAAILAAUJhSWxAQAOAgALAAUJhSWxAQAOAgAuAAQKfxoAAgsACAmPJboGAG0DAAsACAmPJboGAG0DAAAA.',
['狠彪']='狠彪悍:BAAALgAECgkJDAAAAA==.',
['猪头']='猪头二饼:BAAALgAECgQJCAAAAA==.',
['猫猫']='猫猫的小牙虫:BAAALgADCgIJAgAAAA==.',
['王临']='王临天下:BAAALgAECgEJAQABLgAFFAUJAwACAAAAAA==.',
['瑟兰']='瑟兰蒂斯:BAAALgAECgYJBgAAAA==.',
['田德']='田德莉娜:BAAALgADCgYJCwAAAA==.',
['电城']='电城小杨杨:BAAALgADCgMJAwAAAA==.电城鱼炸:BAAALgADCgYJBgAAAA==.',
['电子']='电子竞技无心:BAAALgADCgEJAQAAAA==.',
['痞子']='痞子军:BAAALgAECgYJDAAAAA==.',
['百鬼']='百鬼宴刹罗:BAAALgAECgIJBQAAAA==.',
['真棒']='真棒:BAAALgAECgYJDAAAAA==.',
['神界']='神界圣莹滴泪:BAAALgAECgEJAQAAAA==.',
['神说']='神说有光:BAAALgADCgUJBQAAAA==.',
['秋月']='秋月爱莉:BAAALgAFFAEJAQAAAA==.',
['第五']='第五轻婉:BAAALgAECgUJBQAAAA==.',
['简蒂']='简蒂丝:BAAALgADCgUJBQAAAA==.',
['箭扬']='箭扬天下:BAAALgAECgYJDwAAAA==.',
['糟辣']='糟辣子:BAAALgADCgMJAwAAAA==.',
['紫色']='紫色初雪:BAAALgAECgkJBgAAAA==.紫色柠檬:BAAALgAECgMJAwABLgAECgQJCAACAAAAAA==.',
['红炎']='红炎耀辉:BAAALgAFFAEJAQAAAA==.',
['纯岩']='纯岩岚少冰丶:BAABLgAFFH8FAAIbAAIJ1g5kFwCaAAAbAAIJ1g5kFwCaAAAAAA==.',
['纯绿']='纯绿妍少冰丶:BAABLgAECn8XAAMLAAYJ4CGtSwAQAgALAAYJ4CGtSwAQAgAMAAEJmRcxCgBIAAAAAA==.',
['缥缈']='缥缈回忆:BAAALgAECgEJAgAAAA==.',
['罗包']='罗包包:BAABLgAECn8XAAIIAAcJdxbCegDcAQAIAAcJdxbCegDcAQAAAA==.',
['肆虐']='肆虐的段二二:BAAALgAECgYJBgAAAA==.肆虐的迫击炮:BAAALgAECggJCwAAAA==.',
['艾栗']='艾栗婕:BAAALgAFFAIJBAAAAA==.',
['花狩']='花狩:BAABLgAFFH8JAAIHAAUJRB8QBQDdAQAHAAUJRB8QBQDdAQAAAA==.',
['花落']='花落:BAAALgAFFAQJBAAAAA==.',
['若灬']='若灬:BAAALgAECgEJAQAAAA==.',
['茅十']='茅十八:BAAALgAECgEJAQAAAA==.',
['茶碎']='茶碎西麦:BAAALgADCgQJBAAAAA==.',
['萌不']='萌不起来:BAAALgAFFAIJAgAAAA==.',
['萩葵']='萩葵:BAAALgAECgEJAQAAAA==.',
['葉子']='葉子灬:BAAALgAECgEJAQAAAA==.',
['葛先']='葛先生:BAAALgAECgEJAQAAAA==.',
['葡萄']='葡萄慕斯:BAAALgAECgQJBAAAAA==.',
['藤藤']='藤藤菜:BAAALgAECgEJAgAAAA==.',
['虚空']='虚空花生:BAACLgAFFH8GAAIJAAMJgw+7BQDFAAAJAAMJgw+7BQDFAAAuAAQKfyIAAgkABwkpDUk5AFYBAAkABwkpDUk5AFYBAAAA.',
['蜗牛']='蜗牛爬爬:BAAALgAECgcJAQAAAA==.',
['蜜桃']='蜜桃四季春:BAAALgAECgMJAwAAAA==.',
['见过']='见过猪跑:BAAALgAECgYJCwAAAA==.',
['记得']='记得吃饭:BAAALgADCgEJAQAAAA==.',
['记忆']='记忆的橡皮擦:BAAALgAECgYJCgAAAA==.',
['诗烟']='诗烟雨:BAAALgAECgQJBAABLgAECgcJEgACAAAAAA==.',
['豆浆']='豆浆烩面:BAAALgAECgYJBgABLgAFFAcJCQARAH0VAA==.',
['赢罗']='赢罗许七安:BAAALgAFFAQJBAAAAA==.',
['起手']='起手嗜血:BAAALgAECgMJAwAAAA==.',
['超爷']='超爷丶:BAACLgAFFH8RAAMaAAUJiB4pAQCDAQAaAAQJiB4pAQCDAQAcAAEJAAD/IwBMAAAuAAQKfysAAxoACAkyJUkCAEsDABoACAkyJUkCAEsDABwAAwlOIh1gADABAAAA.',
['辉夜']='辉夜球:BAAALgAECgEJAQAAAA==.',
['辛巴']='辛巴之王:BAAALgAECgYJDAABLgAECgcJEgACAAAAAA==.',
['辛辣']='辛辣天森:BAAALgAECgkJCQAAAA==.',
['适丷']='适丷:BAABLgAFFH8FAAINAAMJ4hYZDgD7AAANAAMJ4hYZDgD7AAAAAA==.',
['逆袭']='逆袭的夙命:BAAALgAECgMJBQAAAA==.',
['郭芙']='郭芙蓉行啊:BAABLgAFFH8IAAIGAAQJGxUJBABfAQAGAAQJGxUJBABfAQAAAA==.',
['酥脆']='酥脆薄薄饼:BAAALgAECgYJBgAAAA==.',
['醉花']='醉花阴丶灵息:BAAALgAECgQJBAABLgAFFAMJBAACAAAAAA==.',
['重庆']='重庆夏季:BAAALgAECgIJAgAAAA==.重庆夏德:BAAALgAECgcJBwAAAA==.',
['野蛮']='野蛮将军:BAABLgAECn8aAAIdAAcJWhD/BABrAQAdAAcJWhD/BABrAQAAAA==.',
['阳光']='阳光小帅锅:BAACLgAFFH8LAAIPAAQJQReLDwBRAQAPAAQJQReLDwBRAQAuAAQKfyEAAw8ABwnUIWojAH0CAA8ABwk3IGojAH0CAB4ABgnrH1QdANUBAAAA.',
['阳呀']='阳呀阳:BAAALgAECgUJBwAAAA==.',
['阿库']='阿库娅:BAAALgAECgYJDwAAAA==.',
['阿玛']='阿玛忒辣死:BAAALgAFFAQJBAAAAA==.',
['阿西']='阿西果果:BAACLgAFFH8UAAIIAAUJVh6vBgD1AQAIAAUJVh6vBgD1AQAuAAQKfyAAAggACAmXJboKAG4DAAgACAmXJboKAG4DAAAA.',
['降临']='降临哀木涕:BAAALgAFFAQJAwAAAA==.',
['雨后']='雨后初晴:BAABLgAECn8XAAMGAAkJsxueCQD8AgAGAAkJsxueCQD8AgAHAAcJvA1MPQBmAQAAAA==.',
['雨珊']='雨珊:BAAALgAECgcJBwAAAA==.',
['雨霖']='雨霖铃丶唤雷:BAAALgAECgYJDAABLgAFFAMJBAACAAAAAA==.',
['雾丷']='雾丷:BAAALgAECgkJCQAAAA==.',
['露露']='露露提亚:BAABLgAFFH8FAAIJAAIJIgp3DgCKAAAJAAIJIgp3DgCKAAAAAA==.',
['青栀']='青栀:BAAALgAECgMJAwAAAA==.',
['顺顺']='顺顺:BAAALgAECggJCgAAAA==.',
['风云']='风云无忌:BAAALgADCgUJBQAAAA==.',
['风起']='风起鹤归:BAAALgAFFAQJBAAAAA==.',
['风闯']='风闯天下:BAAALgADCgEJAQAAAA==.',
['馣然']='馣然回首:BAAALgAECgEJAQAAAA==.',
['骑咕']='骑咕咕:BAAALgAFFAIJAgAAAA==.',
['鬼鬼']='鬼鬼的胆小鬼:BAAALgAECgIJAgAAAA==.',
['魃丷']='魃丷:BAABLgAFFH8GAAINAAQJfxZWBQAyAQANAAQJfxZWBQAyAQAAAA==.',
['魅丶']='魅丶色:BAAALgAECgYJCAAAAA==.',
['魅色']='魅色丶:BAAALgAECgEJAQAAAA==.',
['魔神']='魔神赵曰天:BAAALgAECgUJBAABLgAFFAUJBAACAAAAAA==.',
['鱼可']='鱼可奈奈:BAAALgAFFAMJAwAAAA==.',
['鸭梨']='鸭梨:BAAALgAECgUJBwAAAA==.',
['麽法']='麽法披风:BAAALgAFFAEJAQAAAA==.',
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
