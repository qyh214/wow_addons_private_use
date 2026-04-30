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

local lookup = {'Paladin-Holy','Paladin-Retribution','Rogue-Subtlety','Rogue-Assassination','Evoker-Augmentation','Warrior-Protection','Warlock-Demonology','DeathKnight-Unholy','DeathKnight-Blood','Mage-Frost','Paladin-Protection','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','DemonHunter-Havoc','Hunter-Marksmanship','Priest-Holy','Druid-Restoration','Unknown-Unknown','DemonHunter-Vengeance','Druid-Guardian','Druid-Balance','Evoker-Preservation','Shaman-Restoration','Warlock-Destruction','Warrior-Fury','DemonHunter-Devourer',}
local provider = {region='CN',realm='阿格拉玛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adnachiel:BAAALgAECgYJDgAAAA==.',
Al='Alberta:BAABLgAECn8VAAMBAAcJwQrhQwBoAQABAAcJwQrhQwBoAQACAAUJphbHrgAmAQAAAA==.',
An='Anilao:BAAALgADCgEJAQAAAA==.',
Av='Avocado:BAACLgAFFH8OAAMDAAQJJyQ0AQCNAQADAAQJJyQ0AQCNAQAEAAEJ4RhRBQBkAAAuAAQKfxYAAwMABwmMHz4QAKICAAMABwmMHz4QAKICAAQAAQm7HagaAFMAAAAA.Avocadosm:BAAALgAECgYJBgABLgAFFAQJDgADACckAA==.',
Br='Brantmolly:BAAALgAECgYJCgAAAA==.',
Da='Darcklifire:BAAALgAECgcJCAAAAA==.',
Do='Dokilia:BAAALgAECgUJCAAAAA==.',
En='Eno:BAAALgADCgQJBQAAAA==.',
Ha='Haerin:BAAALgAECgcJCAABLgAFFAYJDgAFAHUaAA==.',
Hi='Hingir:BAAALgAFFAIJAwABLgAFFAQJDQAGAKwUAA==.',
Ja='Jame:BAAALgAFFAIJAQABLgAFFAQJCAAHABsdAA==.',
Ka='Kavenawa:BAAALgAFFAEJAQAAAA==.',
Ne='Neuro:BAABLgAECn8VAAMIAAkJ4x98HQDPAgAIAAcJhiV8HQDPAgAJAAgJMxQ+GQCMAQAAAA==.',
Ni='Niko:BAABLgAECn8XAAIKAAkJthxzGgANAwAKAAkJthxzGgANAwAAAA==.',
Ph='Phoebee:BAAALgADCgIJAgAAAA==.',
Re='Reroll:BAAALgAECgkJDwAAAA==.',
Sa='Saber:BAAALgAECgEJAgAAAA==.',
St='Starwar:BAAALgADCgQJAgAAAA==.',
Ta='Taqindieqs:BAAALgAECgYJCwAAAA==.',
Wa='Wazjj:BAAALgADCgMJAwAAAA==.',
Xh='Xhuger:BAAALgAECgYJEgAAAA==.',
Ya='Yanxin:BAACLgAFFH8FAAICAAMJDRHSDAD+AAACAAMJDRHSDAD+AAAuAAQKfxoAAwIABgneGbFhAMABAAIABgmqGLFhAMABAAsABglrE9IHACcBAAEuAAUUAwkGAAcA9Q0A.',
Ye='Yennefer:BAABLgAFFH8GAAIKAAMJJRG8FwAAAQAKAAMJJRG8FwAAAQAAAA==.',
Yu='Yuna:BAAALgAECgYJEwABLgAFFAMJBQAMACkiAA==.',
['一箭']='一箭走天下:BAAALgAECgEJAQAAAA==.',
['一脸']='一脸清纯:BAAALgAFFAEJAQAAAA==.',
['一队']='一队那个洒满:BAAALgAECgUJBQAAAA==.',
['一魔']='一魔:BAAALgAECgYJDgAAAA==.',
['丁叮']='丁叮:BAAALgADCgUJBQAAAA==.',
['七森']='七森莉莉:BAABLgAFFH8EAAIHAAMJ8wv7FADyAAAHAAMJ8wv7FADyAAAAAA==.',
['上帝']='上帝的左手:BAAALgAECgEJAQAAAA==.上帝荣光:BAAALgAECgIJAgAAAA==.',
['不是']='不是我开的怪:BAAALgADCgEJAQAAAA==.',
['丰胸']='丰胸胶囊:BAAALgADCgYJBgAAAA==.',
['丶辛']='丶辛德拉:BAAALgADCgYJBgAAAA==.',
['乂紫']='乂紫伊乂:BAAALgAFFAEJAQAAAA==.',
['乔露']='乔露易丝巴:BAAALgAECgYJBwAAAA==.',
['乱花']='乱花:BAABLgAFFH8GAAINAAMJPAxpCwDdAAANAAMJPAxpCwDdAAAAAA==.',
['二把']='二把伞:BAAALgAECgYJBwAAAA==.',
['云不']='云不归:BAAALgAECgYJBQAAAA==.',
['五号']='五号位:BAABLgAFFH8IAAIFAAQJRh0dAwB1AQAFAAQJRh0dAwB1AQAAAA==.',
['五条']='五条悟:BAAALgAECgkJEAAAAA==.',
['人帅']='人帅刀快:BAAALgAECgYJCwAAAA==.',
['从此']='从此不空车:BAABLgAFFH8IAAMOAAQJiSVgAQDGAQAOAAQJiSVgAQDGAQANAAQJkhbXAwBUAQAAAA==.',
['仙灵']='仙灵:BAACLgAFFH8MAAIOAAQJfx+CAgCNAQAOAAQJfx+CAgCNAQAuAAQKfxgAAg4ACAkyIbIOAJICAA4ACAkyIbIOAJICAAAA.',
['伽蓝']='伽蓝听雨盼:BAAALgAECggJDQAAAA==.',
['何必']='何必当真:BAAALgADCgkJDgAAAA==.',
['做死']='做死:BAAALgAECgcJDAAAAA==.',
['偶然']='偶然非偶尔:BAAALgAECgMJAwAAAA==.',
['元宵']='元宵:BAAALgAECgUJBQAAAA==.',
['光芒']='光芒小丑丑:BAAALgAECgEJAQAAAA==.',
['再诞']='再诞之翼:BAAALgAECgUJDwAAAA==.',
['刑裁']='刑裁者:BAAALgAECggJEQAAAA==.',
['十字']='十字军凌叶:BAAALgAECgIJAgAAAA==.',
['半只']='半只菜鸡:BAAALgAECgcJBwAAAA==.',
['卡德']='卡德减:BAABLgAFFH8IAAIKAAQJ2B7AEACQAQAKAAQJ2B7AEACQAQABLgAFFAcJCgAKAO4cAA==.',
['双龙']='双龙湖杰哥:BAAALgAECgEJAQAAAA==.',
['古尼']='古尼雅:BAAALgAFFAIJBAAAAA==.',
['吃柠']='吃柠檬大酋长:BAAALgAECgkJCQAAAA==.',
['吳下']='吳下阿蒙:BAABLgAFFH8IAAICAAMJyR7qCAAhAQACAAMJyR7qCAAhAQAAAA==.',
['吾辈']='吾辈大宗师:BAAALgAECgEJAQAAAA==.',
['咕嘟']='咕嘟拜哇:BAAALgAFFAEJAQAAAA==.',
['咖啡']='咖啡调调:BAAALgAECgYJBgAAAA==.',
['哀沐']='哀沐剃:BAAALgAECgEJAQAAAA==.',
['喵星']='喵星达人:BAABLgAFFH8GAAIPAAMJwg8HAwDvAAAPAAMJwg8HAwDvAAAAAA==.',
['嘀嘀']='嘀嘀咕咕:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光麦乐鸡:BAACLgAFFH8UAAICAAYJrhoGAQCrAQACAAYJrhoGAQCrAQAuAAQKfxoAAgIACQlqIM0XANoCAAIACQlqIM0XANoCAAAA.',
['地狱']='地狱铁蹄:BAAALgADCgUJBQAAAA==.',
['基斯']='基斯丹尼:BAAALgAECgEJAQAAAA==.',
['奶牛']='奶牛宝可梦:BAAALgAECgcJEQAAAA==.',
['姚神']='姚神小窝:BAAALgAECgYJCwAAAA==.',
['婵鸣']='婵鸣在呼唤:BAAALgAECgYJBgAAAA==.',
['孤雨']='孤雨:BAAALgADCgEJAQAAAA==.',
['宁姚']='宁姚:BAAALgAECgYJEgAAAA==.',
['安娜']='安娜卡列琳娜:BAAALgADCgEJAQAAAA==.',
['安藤']='安藤樱:BAAALgAECgEJAQAAAA==.',
['完整']='完整的鸡蛋壳:BAAALgAECgMJAwAAAA==.',
['小叮']='小叮当:BAAALgAECgcJDQAAAA==.',
['小小']='小小狂战:BAAALgADCgkJCwAAAA==.',
['小飞']='小飞姬樣:BAAALgAFFAQJBAAAAA==.',
['小鸟']='小鸟游一花:BAAALgAFFAEJAQAAAA==.小鸟游十花:BAAALgADCgEJAQAAAA==.',
['山药']='山药丸子:BAAALgADCgMJBQAAAA==.',
['巫婆']='巫婆:BAAALgAECgcJEwAAAA==.',
['希尔']='希尔瓦娜球:BAABLgAFFH8FAAIQAAMJOht5EgAUAQAQAAMJOht5EgAUAQAAAA==.',
['弟娃']='弟娃爱你哟:BAAALgAECgYJCAAAAA==.',
['张大']='张大翼:BAAALgAECgcJBwAAAA==.',
['往事']='往事:BAAALgAECgQJCwAAAA==.',
['恐惧']='恐惧脚步:BAAALgAECgYJCAAAAA==.',
['慕容']='慕容宝儿:BAAALgADCgUJBQAAAA==.',
['我是']='我是大狐:BAAALgAFFAEJAQAAAA==.我是彦祖大王:BAAALgAECgYJBgAAAA==.',
['打野']='打野啊:BAAALgADCgQJBAAAAA==.',
['扛不']='扛不住打扰了:BAAALgAFFAEJAQAAAA==.',
['承天']='承天之佑:BAAALgAFFAQJBAABLgAFFAUJEQARAPIiAA==.',
['捕鱼']='捕鱼达人:BAAALgAECgIJAgAAAA==.',
['摩尔']='摩尔迦娜:BAAALgAECgYJBgAAAA==.',
['摸不']='摸不到的颜色:BAAALgAECgYJCAAAAA==.',
['放脸']='放脸烨:BAAALgADCgEJAQAAAA==.',
['无聊']='无聊的德:BAAALgAFFAEJAQAAAA==.',
['星飒']='星飒:BAAALgAECgQJBwAAAA==.',
['晴天']='晴天霏霏:BAAALgADCgYJBgAAAA==.',
['晴晴']='晴晴女王:BAAALgAECgEJAQAAAA==.',
['暗月']='暗月之蚀:BAAALgAFFAIJAwAAAA==.',
['暗言']='暗言术:BAAALgAECgEJAQAAAA==.',
['最后']='最后的咏叹调:BAAALgAECgkJDgABLgAFFAUJBQASAJkcAA==.最后的归:BAAALgAECgIJAgAAAA==.',
['月夜']='月夜听风雨:BAAALgAECgYJDAAAAA==.',
['有点']='有点痒挠一挠:BAAALgAECgMJAwAAAA==.',
['果果']='果果的小巫婆:BAAALgAECgUJBQAAAA==.果果的小神僧:BAAALgAECgIJAgAAAA==.果果的小虚空:BAAALgAECgcJCQAAAA==.',
['枫花']='枫花恋兮:BAAALgAECgEJAQAAAA==.',
['某球']='某球:BAAALgAECgYJBgAAAA==.',
['格林']='格林:BAAALgAECgUJBQAAAA==.',
['桃姐']='桃姐的狗:BAAALgAECgcJBgABLgAFFAcJBQASAMsVAA==.',
['樱岛']='樱岛麻衣:BAAALgAECgYJBgAAAA==.',
['欢喜']='欢喜城:BAAALgAECgEJAQAAAA==.',
['正义']='正义的地球人:BAABLgAFFH8HAAICAAMJriDuBwAxAQACAAMJriDuBwAxAQABLgAFFAcJDQAGAM4ZAA==.',
['水元']='水元素:BAAALgAFFAMJAwAAAA==.',
['汐汐']='汐汐宝宝:BAAALgAECgIJAgAAAA==.',
['河口']='河口丢丢:BAAALgAECgMJAwAAAA==.',
['治疗']='治疗还是输出:BAAALgAECgcJBwAAAA==.',
['泰僧']='泰僧:BAAALgAECgEJAQABLgAECgYJCgATAAAAAA==.',
['洒家']='洒家鸟你一脸:BAAALgAECgcJEAAAAA==.',
['淪陥']='淪陥:BAAALgAECgEJAQAAAA==.',
['源神']='源神:BAAALgAECgcJDQAAAA==.',
['灵极']='灵极冰:BAAALgAECgcJCwAAAA==.',
['灵猫']='灵猫:BAAALgAECgIJAgAAAA==.',
['爪妹']='爪妹醬:BAAALgAFFAEJAQAAAA==.',
['牙辣']='牙辣伊辣郎辣:BAAALgADCgEJAQAAAA==.',
['物丸']='物丸呜喵王:BAACLgAFFH8HAAIJAAMJdQdSEABuAAAJAAMJdQdSEABuAAAuAAQKfxcAAgkABgkJEEwjACcBAAkABgkJEEwjACcBAAEuAAUUBAkNAAYArBQA.物丸大队长:BAACLgAFFH8LAAILAAQJlRfAAQANAQALAAQJlRfAAQANAQAuAAQKfxcAAgsABgmlIXMJADoCAAsABgmlIXMJADoCAAEuAAUUBAkNAAYArBQA.物丸小混范:BAACLgAFFH8HAAIUAAMJTwtbAQDCAAAUAAMJTwtbAQDCAAAuAAQKfxgAAhQABgkGEm0SACsBABQABgkGEm0SACsBAAEuAAUUBAkNAAYArBQA.物丸小混飯:BAACLgAFFH8LAAMVAAQJtgyHAQAMAQAVAAQJtgyHAQAMAQAWAAEJAwHGHQA5AAAuAAQKfxUAAhUABglKFRESAFIBABUABglKFRESAFIBAAEuAAUUBAkNAAYArBQA.物丸小混饭:BAACLgAFFH8NAAIGAAQJrBSwAgAtAQAGAAQJrBSwAgAtAQAuAAQKfx8AAgYABwlMFtcSANwBAAYABwlMFtcSANwBAAAA.物丸小炒饼:BAAALgADCgYJBgAAAA==.物丸桃桃酱:BAAALgADCgcJBwAAAA==.物丸熊了个猫:BAABLgAFFH8KAAINAAQJNAkvEAD/AAANAAQJNAkvEAD/AAABLgAFFAQJDQAGAKwUAA==.',
['狂猎']='狂猎:BAAALgAECgMJAwAAAA==.',
['狂野']='狂野的大蜂子:BAAALgAECgQJCgAAAA==.',
['狄雀']='狄雀:BAAALgAFFAIJBAAAAA==.',
['猎刃']='猎刃都:BAAALgADCgMJAwAAAA==.',
['王子']='王子无敌:BAAALgAECgQJBAAAAA==.',
['玩的']='玩的你团团转:BAAALgAECgEJAQAAAA==.',
['生杀']='生杀予夺:BAAALgAECggJCAAAAA==.',
['疯狂']='疯狂星期四:BAAALgAECgIJAwAAAA==.',
['白鹿']='白鹿鹿:BAAALgADCgkJDwAAAA==.',
['皓月']='皓月宁雨:BAAALgAECgQJCQABLgAFFAQJDAAOAH8fAA==.',
['盾肉']='盾肉牛:BAAALgAECgUJCAAAAA==.',
['看世']='看世界繁华:BAAALgAECgYJCwAAAA==.',
['破晓']='破晓晨曦:BAAALgAECgkJCQABLgAFFAYJFwACAN0fAA==.',
['神之']='神之舞子:BAAALgAECgcJBgAAAA==.',
['神人']='神人梅西:BAAALgAECgQJBAAAAA==.',
['神圣']='神圣的番茄:BAAALgAECgcJDQAAAA==.',
['秀念']='秀念:BAAALgAECgEJAgAAAA==.',
['秋名']='秋名山德斯基:BAAALgAFFAIJAgAAAA==.',
['科学']='科学戒德局:BAAALgADCgcJDQAAAA==.',
['科迪']='科迪亚:BAAALgADCgEJAQAAAA==.',
['程灵']='程灵素:BAABLgAFFH8GAAMXAAMJWxIWBwDuAAAXAAMJWxIWBwDuAAAFAAIJLAJ3HQCDAAAAAA==.',
['等我']='等我绕个后:BAAALgAFFAEJAQAAAA==.',
['红手']='红手阿风:BAAALgAECgUJCQAAAA==.',
['红运']='红运正当头:BAAALgAECgYJEAAAAA==.红运贼当头:BAAALgAECgQJDwABLgAECgYJEAATAAAAAA==.',
['纯情']='纯情火鸡:BAAALgAFFAEJAQAAAA==.',
['线粒']='线粒体基质:BAAALgAECgMJAwAAAA==.',
['终极']='终极节拍:BAAALgAECgkJCQABLgAFFAYJAgATAAAAAA==.',
['绊倒']='绊倒铁盒:BAAALgAECgYJCwAAAA==.',
['罚酒']='罚酒峰:BAAALgAECgEJAQAAAA==.',
['老将']='老将盖乌斯:BAAALgAECgcJDAABLgAFFAYJEAAYANsjAA==.',
['老练']='老练的凤凰:BAABLgAFFH8GAAIHAAMJ9Q3AIgD5AAAHAAMJ9Q3AIgD5AAAAAA==.',
['老陈']='老陈:BAAALgAECgYJBgAAAA==.',
['耶路']='耶路撒冷:BAABLgAFFH8GAAIYAAMJuBhmCAD3AAAYAAMJuBhmCAD3AAAAAA==.',
['胭脂']='胭脂虫:BAABLgAFFH8FAAIIAAMJyBEUFAD0AAAIAAMJyBEUFAD0AAAAAA==.',
['腥红']='腥红圆舞曲:BAAALgAECgYJBgABLgAFFAUJCQAZANghAA==.',
['航丶']='航丶风暴烈酒:BAABLgAFFH8FAAIMAAMJKSKSCAAxAQAMAAMJKSKSCAAxAQAAAA==.',
['芙柔']='芙柔桑克斯:BAAALgAECgcJCgAAAA==.',
['苏非']='苏非玛索:BAAALgAECgQJBgAAAA==.',
['茉莉']='茉莉奶绿:BAAALgAECgIJAwAAAA==.',
['菠萝']='菠萝切啊切:BAAALgAFFAIJBAAAAA==.',
['萝卜']='萝卜切啊切:BAABLgAECn8UAAIaAAcJwBsgIgBDAgAaAAcJwBsgIgBDAgAAAA==.',
['葉子']='葉子辰丶:BAACLgAFFH8IAAIIAAMJvCQDHgAoAQAIAAMJvCQDHgAoAQAuAAQKfxgAAggABwk6IhgqAJECAAgABwk6IhgqAJECAAEuAAUUBAkIAAoA0RsA.',
['蓝血']='蓝血牛牛:BAAALgAECgQJCAAAAA==.',
['虎之']='虎之咆哮:BAAALgAECgMJBQAAAA==.虎之骑士:BAAALgAECgIJAgAAAA==.',
['蛋糕']='蛋糕切啊切:BAAALgAFFAIJBAABLgAFFAUJBQAbAN8aAA==.',
['血鬼']='血鬼狂人:BAACLgAFFH8XAAICAAYJkyZMAACrAgACAAYJkyZMAACrAgAuAAQKfyMAAgIACQm8JjYAAP8DAAIACQm8JjYAAP8DAAAA.',
['西格']='西格玛男银丶:BAAALgAFFAEJAQAAAA==.',
['请你']='请你吃粉:BAAALgAECgMJAwAAAA==.',
['诺伊']='诺伊:BAAALgAECgEJAgAAAA==.诺伊伊:BAAALgAECgEJAQAAAA==.',
['迈克']='迈克拉伦:BAAALgAFFAEJAQAAAA==.',
['逝去']='逝去的往昔:BAAALgAECgUJCgAAAA==.',
['造纸']='造纸农夫三拳:BAAALgAECgYJBgAAAA==.',
['邪能']='邪能苏苏:BAAALgADCgEJAQAAAA==.',
['醉花']='醉花荫:BAAALgAECgQJBAAAAA==.',
['释永']='释永信:BAAALgAECgIJAwAAAA==.',
['门捷']='门捷猎夫:BAAALgADCgEJAQAAAA==.',
['雪娜']='雪娜蕊斯:BAACLgAFFH8RAAIRAAUJ8iK4AQCkAQARAAUJ8iK4AQCkAQAuAAQKfx4AAhEACAlYIvUFAPACABEACAlYIvUFAPACAAAA.',
['霜灬']='霜灬炎音:BAAALgAECgYJCAAAAA==.',
['韩小']='韩小七:BAAALgAECgQJCgAAAA==.',
['顾异']='顾异的:BAAALgAECgYJCwAAAA==.',
['風随']='風随:BAABLgAFFH8GAAIKAAMJQQtpGgDvAAAKAAMJQQtpGgDvAAAAAA==.',
['风中']='风中無我:BAAALgAECgEJAQAAAA==.',
['饺子']='饺子音:BAAALgAFFAEJAQAAAA==.',
['香菇']='香菇仔:BAAALgAECgQJBQAAAA==.',
['香香']='香香熊:BAAALgAECgcJBwAAAA==.',
['骷髅']='骷髅鬼:BAAALgAECgYJCwAAAA==.',
['鬼拳']='鬼拳:BAAALgAECgMJAwAAAA==.',
['魅影']='魅影灬晴晴:BAAALgAECgEJAQAAAA==.',
['黯影']='黯影谜踪:BAAALgAECgYJBgABLgAFFAUJEQARAPIiAA==.',
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
