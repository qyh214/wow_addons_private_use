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

local lookup = {'Shaman-Elemental','Shaman-Restoration','DeathKnight-Blood','Mage-Frost','Mage-Fire','DeathKnight-Unholy','DeathKnight-Frost','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Rogue-Subtlety','Druid-Balance','Druid-Restoration','Monk-Brewmaster','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Warrior-Fury','Unknown-Unknown','Warrior-Protection','DemonHunter-Devourer','DemonHunter-Vengeance','Paladin-Protection',}
local provider = {region='CN',realm='奥斯里安',name='CN',type='weekly',zone=46,date='2026-04-25',data={Au='Austonmartin:BAAALgAECgYJEgAAAA==.',
Cl='Claudia:BAAALgADCgQJBAAAAA==.',
Da='Daedal:BAACLgAFFH8JAAIBAAMJsRhaDgAGAQABAAMJsRhaDgAGAQAuAAQKfyQAAwEACAn0HBcXAF8CAAEACAn0HBcXAF8CAAIAAwkEEoR8AKEAAAAA.',
If='Ifan:BAABLgAFFH8FAAIDAAUJqw0bBgA2AQADAAUJqw0bBgA2AQAAAA==.Ifcxsql:BAAALgADCgUJBQAAAA==.',
Im='Importent:BAAALgADCgIJAgAAAA==.',
La='Lacrimosa:BAABLgAECn8UAAMEAAcJuA0nlQCqAQAEAAcJuA0nlQCqAQAFAAIJPAXeDQBKAAAAAA==.',
Sk='Skrillx:BAAALgAECggJCAAAAA==.',
So='Someone:BAACLgAFFH8LAAICAAMJBiNFCQA7AQACAAMJBiNFCQA7AQAuAAQKfyMAAgIACAktIWMQAJQCAAIACAktIWMQAJQCAAAA.',
Sw='Swiper:BAAALgAECgYJBgAAAA==.',
Ze='Zeroblood:BAACLgAFFH8JAAIGAAMJjhx1JAADAQAGAAMJjhx1JAADAQAuAAQKfyMAAwYACAkcHVA0AGUCAAYACAkcHVA0AGUCAAcAAQkAAIgVAD0AAAAA.',
['一号']='一号技术师:BAABLgAFFH8FAAMIAAUJDQ3+EwBKAQAIAAQJZgr+EwBKAQAJAAEJARVOFABWAAAAAA==.',
['一百']='一百级鲤鱼王:BAAALgAECgUJBQAAAA==.',
['一身']='一身英雄胆:BAABLgAFFH8GAAIKAAMJGhM5JQChAAAKAAMJGhM5JQChAAAAAA==.',
['万万']='万万没想到:BAAALgAECgEJAwAAAA==.',
['东郊']='东郊到家姬师:BAAALgADCgEJAQAAAA==.东郊老妈子:BAAALgADCgcJCwAAAA==.',
['丶只']='丶只对你说:BAAALgADCgYJCAAAAA==.',
['丶珊']='丶珊珊来迟:BAAALgAECgEJAgAAAA==.',
['丽塔']='丽塔洛丝薇瑟:BAAALgAECgcJEQAAAA==.',
['也太']='也太厉害了吧:BAAALgAECgYJBwAAAA==.',
['何似']='何似风雨:BAAALgAECgIJAwAAAA==.',
['保安']='保安队长:BAAALgAECgEJAQAAAA==.',
['元素']='元素行者:BAAALgADCgUJBQAAAA==.',
['克尔']='克尔忒加繆:BAAALgADCgIJAgAAAA==.',
['冰火']='冰火犇羴鱻:BAAALgAECgQJBAAAAA==.',
['凛冬']='凛冬将至:BAABLgAFFH8FAAIEAAQJfBnRFgBuAQAEAAQJfBnRFgBuAQAAAA==.',
['半个']='半个月亮:BAABLgAECn8UAAIKAAYJyBc2cwCVAQAKAAYJyBc2cwCVAQAAAA==.',
['单车']='单车暴风:BAAALgAECgYJDAAAAA==.',
['博麗']='博麗靈夢丶:BAAALgAECgkJDwAAAA==.',
['含汨']='含汨加入:BAAALgAECgYJDAAAAA==.',
['含泪']='含泪加入:BAABLgAFFH8aAAILAAcJNx0XAADWAgALAAcJNx0XAADWAgAAAA==.',
['吾王']='吾王:BAAALgAECgYJDAAAAA==.吾王丶:BAAALgAECgIJAwAAAA==.',
['周凯']='周凯希:BAAALgADCgQJBQAAAA==.',
['咩脂']='咩脂球:BAAALgAECgYJCQAAAA==.',
['回首']='回首亦少年:BAAALgAECgEJAQAAAA==.',
['囧声']='囧声波:BAAALgAECgYJBgAAAA==.',
['地震']='地震不烫脚:BAAALgAECgEJAQAAAA==.',
['墨白']='墨白:BAAALgAECgQJBQAAAA==.',
['多弗']='多弗朗明哥:BAAALgAFFAIJAgAAAA==.',
['夜枫']='夜枫吸:BAAALgAECgYJBwAAAA==.',
['夜独']='夜独酌不识卿:BAAALgADCgcJCAAAAA==.',
['夸父']='夸父逐曰出橙:BAAALgAECgYJDgAAAA==.',
['妙涟']='妙涟寺鸦郎:BAABLgAECn8mAAMBAAgJdB/uDADPAgABAAgJdB/uDADPAgACAAcJXxVfKwDfAQAAAA==.',
['威猛']='威猛大菜瓜:BAAALgADCgcJDgABLgAECgYJHAAEAFQiAA==.威猛大西瓜:BAAALgAECgEJAQAAAA==.',
['安西']='安西军何在:BAAALgAECgYJBgAAAA==.',
['宝井']='宝井宁:BAABLgAFFH8HAAIIAAQJeRPbEQBWAQAIAAQJeRPbEQBWAQAAAA==.',
['射点']='射点什么:BAAALgADCgUJBQAAAA==.',
['巴索']='巴索罗缪大熊:BAAALgAECgYJDAAAAA==.',
['布德']='布德奇冥:BAAALgAECgEJAwAAAA==.',
['帝王']='帝王图拉飏:BAAALgAECgIJAgAAAA==.',
['广富']='广富林死神:BAAALgAECgYJBgAAAA==.广富林萨神:BAAALgAECgEJAgAAAA==.',
['愤怒']='愤怒的钢板:BAAALgAECgEJBAAAAA==.',
['执着']='执着的铁锤:BAABLgAFFH8FAAIKAAIJmhIHEAClAAAKAAIJmhIHEAClAAAAAA==.',
['拉美']='拉美西斯:BAAALgAECgQJBAAAAA==.',
['挣大']='挣大钱摸小札:BAAALgAECgMJAwAAAA==.',
['换坦']='换坦嘲讽:BAAALgADCgUJBQAAAA==.',
['掌上']='掌上老虎:BAAALgAECgkJDQAAAA==.',
['摸摸']='摸摸唱大师:BAACLgAFFH8FAAMMAAMJeQGrFwB8AAAMAAIJTAGrFwB8AAANAAIJggKJIABxAAAuAAQKfxwAAw0ACAkRBO91APUAAA0ACAkRBO91APUAAAwACAmaCJMTAMUAAAAA.',
['摸骨']='摸骨老师傅:BAABLgAECn8YAAIOAAYJZhayNAB8AQAOAAYJZhayNAB8AQAAAA==.',
['撒斯']='撒斯费罗:BAAALgAFFAEJAQAAAA==.',
['旅店']='旅店老板娘:BAAALgAFFAIJAgABLgAFFAYJEwAKAMggAA==.',
['早乙']='早乙女道:BAABLgAFFH8MAAIIAAQJEBbvEABbAQAIAAQJEBbvEABbAQAAAA==.',
['星光']='星光点点:BAAALgAFFAEJAQAAAA==.',
['春哥']='春哥夸我帅:BAAALgADCgMJAwAAAA==.',
['暗魂']='暗魂哀歌:BAACLgAFFH8JAAICAAMJjBYDDgD8AAACAAMJjBYDDgD8AAAuAAQKfyMAAgIACAmsHZ4EACQCAAIACAmsHZ4EACQCAAAA.',
['暴风']='暴风单车:BAAALgADCgIJAgAAAA==.暴风雪:BAAALgAECgYJCAAAAA==.',
['机子']='机子酱:BAAALgAECgYJCAAAAA==.',
['杯酒']='杯酒释人生:BAAALgAECgIJAgAAAA==.',
['果然']='果然不是:BAAALgADCgYJBgAAAA==.',
['桃子']='桃子酱:BAAALgAFFAMJAwAAAA==.',
['桥本']='桥本不菜:BAAALgAECgEJAQAAAA==.桥本很菜:BAAALgAECgYJBwAAAA==.',
['死磕']='死磕降临:BAACLgAFFH8TAAIGAAUJEyR8AgDrAQAGAAUJEyR8AgDrAQAuAAQKfx0AAgYACQlfJcwEAIYDAAYACQlfJcwEAIYDAAAA.',
['死神']='死神眷恋:BAAALgAECgcJDQAAAA==.',
['母牛']='母牛太妖娆:BAACLgAFFH8HAAIKAAMJmxSmFQD9AAAKAAMJmxSmFQD9AAAuAAQKfxcAAgoABwk6I4QfAK8CAAoABwk6I4QfAK8CAAAA.',
['没脑']='没脑袋:BAACLgAFFH8JAAMPAAMJfSHrCwAqAQAPAAMJfSHrCwAqAQAQAAEJPyREHgBtAAAuAAQKfyMABA8ACAmTH78IAK0CAA8ACAmTH78IAK0CABAABAk2HYEOAAUBABEAAglUAYEKACAAAAAA.',
['海王']='海王哥:BAAALgAECgYJCQAAAA==.',
['潜入']='潜入搜查倌:BAAALgAECgcJEwAAAA==.',
['火锅']='火锅:BAAALgAECgMJAgAAAA==.',
['照烧']='照烧小丸子:BAAALgAECgYJCwAAAA==.',
['熊猫']='熊猫陨石拿铁:BAABLgAFFH8GAAIGAAQJ4BoJDgBqAQAGAAQJ4BoJDgBqAQABLgAFFAUJBQASAP4TAA==.',
['爆击']='爆击灭烟:BAAALgAECgEJAQAAAA==.',
['獠丶']='獠丶牙:BAAALgAECgYJBgAAAA==.',
['王嘉']='王嘉熙:BAAALgAFFAMJAwAAAA==.王嘉熙小号二:BAACLgAFFH8QAAIPAAUJQxjgAwDDAQAPAAUJQxjgAwDDAQAuAAQKfxQAAg8ACAkXH10HAMgCAA8ACAkXH10HAMgCAAAA.',
['玫瑰']='玫瑰酱:BAACLgAFFH8HAAITAAMJBQeKCgC8AAATAAMJBQeKCgC8AAAuAAQKfxYAAxMACAkNCe8OAAABABMACAkNCe8OAAABABQABAntASVbAEkAAAAA.',
['白塔']='白塔:BAAALgAECgYJBgAAAA==.',
['百合']='百合酱:BAACLgAFFH8IAAIVAAMJZhfHEQC8AAAVAAMJZhfHEQC8AAAuAAQKfyMAAxUACAmzHEYhAD4CABUACAl2HEYhAD4CABYABgkKFfI8AGgBAAAA.',
['破晓']='破晓:BAAALgADCgEJAQAAAA==.',
['神乐']='神乐:BAAALgADCgUJCQAAAA==.',
['神户']='神户牛排:BAAALgAFFAEJAQAAAA==.',
['秀一']='秀一刀:BAAALgAECgUJBwAAAA==.',
['细嗅']='细嗅蔷薇:BAAALgAECgEJAgAAAA==.',
['绫零']='绫零:BAABLgAFFH8KAAIXAAMJ7Cb1BwBdAQAXAAMJ7Cb1BwBdAQAAAA==.',
['羽蝶']='羽蝶:BAAALgAECgcJBwABLgAFFAMJCgAXAOwmAA==.',
['肥了']='肥了个熊:BAAALgAECgMJAwAAAA==.',
['自恋']='自恋长发飘:BAABLgAFFH8HAAIYAAIJSh/uFADDAAAYAAIJSh/uFADDAAAAAA==.',
['自然']='自然灵域:BAAALgADCgMJAwAAAA==.',
['至臻']='至臻牧司:BAAALgAECgcJBgABLgAFFAgJAQAZAAAAAA==.',
['芝士']='芝士莓莓茶:BAAALgAFFAIJBAAAAA==.',
['英年']='英年早逝:BAAALgAECgYJCgAAAA==.',
['菜小']='菜小四:BAAALgAECgYJCwAAAA==.',
['萌思']='萌思:BAAALgAECgEJAQAAAA==.',
['血落']='血落:BAAALgAFFAIJAgAAAA==.',
['言出']='言出法随:BAAALgADCgIJAgAAAA==.',
['誓约']='誓约胜利之剑:BAAALgAECgQJAgAAAA==.',
['贱死']='贱死不救:BAAALgAFFAIJAgABLgAFFAMJBwAKAJsUAA==.',
['贵宾']='贵宾楼上请:BAAALgADCgEJAQAAAA==.',
['超时']='超时空辉夜姬:BAAALgAFFAQJBAAAAA==.',
['超级']='超级杯水果茶:BAAALgAECgcJBgAAAA==.',
['超越']='超越纣王:BAAALgAECgYJCAAAAA==.',
['迈克']='迈克尔三藏:BAAALgADCgMJAwAAAA==.',
['邪能']='邪能伏特加:BAACLgAFFH8JAAISAAMJLhpRBQAHAQASAAMJLhpRBQAHAQAuAAQKfyMAAhIACAluHf8MAJICABIACAluHf8MAJICAAAA.',
['酱爆']='酱爆肉:BAAALgAECgYJBgAAAA==.',
['酷棋']='酷棋:BAAALgADCgEJAQAAAA==.',
['铜毛']='铜毛头:BAAALgAECgcJBwABLgAFFAMJCgAXAOwmAA==.',
['银月']='银月城之心:BAAALgADCgUJBQAAAA==.',
['闪光']='闪光光:BAAALgAFFAIJAgAAAA==.',
['阿曼']='阿曼苏尔的妈:BAABLgAECn8VAAIaAAYJIgk1KQD2AAAaAAYJIgk1KQD2AAAAAA==.',
['雪月']='雪月明:BAAALgAECgcJBwAAAA==.',
['飘渺']='飘渺逸:BAAALgAECgEJAQAAAA==.',
['驯兽']='驯兽家:BAABLgAFFH8FAAIVAAUJGRrDAACRAQAVAAUJGRrDAACRAQAAAA==.',
['驼鹿']='驼鹿角:BAAALgAECgUJBQAAAA==.',
['鲨鱼']='鲨鱼辣椒丶:BAAALgAFFAMJAwAAAA==.',
['黑曜']='黑曜丶:BAACLgAFFH8JAAIbAAMJTiLeFAAsAQAbAAMJTiLeFAAsAQAuAAQKfyMABBsACAngIboSAOoCABsACAncIboSAOoCABIABAlgGepDAOcAABwAAQkoAVsyABoAAAAA.',
['黑豹']='黑豹:BAAALgAECgQJBAAAAA==.',
['龍丶']='龍丶:BAACLgAFFH8IAAIKAAQJxRn8BwBzAQAKAAQJxRn8BwBzAQAuAAQKfxgAAwoACAnDIqgXANsCAAoACAnDIqgXANsCAB0AAQnCAr1LABwAAAAA.',
['龙洺']='龙洺:BAAALgAFFAEJAQABLgAFFAUJBQAbAN8aAA==.',
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
