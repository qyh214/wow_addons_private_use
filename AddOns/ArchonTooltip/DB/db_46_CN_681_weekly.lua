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

local lookup = {'Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','Paladin-Retribution','Warrior-Protection','Unknown-Unknown','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Mage-Frost','Druid-Restoration','Shaman-Elemental','Warrior-Fury','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Frost','DeathKnight-Blood','Monk-Mistweaver','Warrior-Arms','DemonHunter-Vengeance','DemonHunter-Devourer','Hunter-Survival','Druid-Balance',}
local provider = {region='CN',realm='恶魔之魂',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aegwyn:BAABLgAFFH8JAAIBAAQJPBn1BQBoAQABAAQJPBn1BQBoAQAAAA==.',
Ai='Aioria:BAAALgAECgcJBwAAAA==.',
An='Anelace:BAACLgAFFH8XAAMCAAYJJSWKAQD0AQACAAUJSSWKAQD0AQADAAEJmCTGBABwAAAuAAQKfxUAAwIABwmZJPAUAGsCAAIABwmZJPAUAGsCAAMAAQlbA3MiACEAAAAA.',
Ap='Apostle:BAAALgAECgEJAQAAAA==.',
Co='Cortezice:BAAALgAECgkJCAAAAA==.',
De='Demonhunter:BAAALgAFFAIJAgAAAA==.',
Ee='Eels:BAAALgAECgYJEQAAAA==.',
Fl='Flmdk:BAAALgAECggJEQAAAA==.',
Fu='Fulee:BAAALgAECgkJAgAAAA==.',
Gh='Ghostcola:BAAALgADCgYJBgAAAA==.',
Ji='Jimmyz:BAAALgAECgQJBAAAAA==.',
Mm='Mmua:BAAALgAECgEJAQAAAA==.',
Ne='Necrom:BAAALgAECgYJBgAAAA==.Neoly:BAABLgAECn8eAAIEAAcJ4yJvKACDAgAEAAcJ4yJvKACDAgAAAA==.Nevermore:BAAALgADCgcJCQAAAA==.',
Ra='Razorx:BAAALgAFFAEJAQAAAA==.',
Re='Recklessly:BAAALgAECgYJBgAAAA==.',
Sh='Shadowing:BAAALgADCgYJBgAAAA==.',
St='Stray:BAAALgAFFAMJAwAAAA==.',
Xi='Xiaoolu:BAAALgAECgEJAQAAAA==.',
Yu='Yumica:BAAALgAECgIJAgAAAA==.',
Zi='Zibbaii:BAAALgAECgYJCQAAAA==.Zielle:BAEALgAECgcJBgAAAA==.',
Zs='Zsphtyrchhpy:BAAALgAECgQJBAAAAA==.',
['一切']='一切丶随缘:BAAALgAFFAEJAQAAAA==.',
['一叶']='一叶倾心:BAAALgAECgYJDwABLgAECgYJFQAFABgcAA==.',
['一吻']='一吻:BAAALgAECgEJAQAAAA==.',
['一坐']='一坐车就要吐:BAAALgAECgEJAQABLgAECgYJDQAGAAAAAA==.',
['一夕']='一夕丶:BAAALgAECgYJCQAAAA==.',
['一笑']='一笑倾城:BAAALgAECgYJDAAAAA==.',
['不语']='不语:BAABLgAECn8cAAQHAAkJNBljAABUAgAHAAgJRRxjAABUAgAIAAYJ/g4HrAABAQAJAAIJ2QzOHACMAAAAAA==.',
['专属']='专属小马哥:BAAALgAECgUJBgAAAA==.',
['世纪']='世纪神牛:BAAALgAECgUJBQAAAA==.',
['业火']='业火焚心:BAAALgAECgkJDwAAAA==.',
['东君']='东君:BAAALgAFFAEJAQAAAA==.',
['丝妄']='丝妄骑士爸爸:BAAALgAECgQJBQAAAA==.',
['两袖']='两袖清风:BAAALgADCgUJBQAAAA==.',
['丨奶']='丨奶糖儿丨:BAAALgAECgQJAwAAAA==.',
['丨苍']='丨苍丶云丨:BAAALgAFFAIJAgAAAA==.',
['丶一']='丶一介武夫:BAAALgADCgMJAwAAAA==.',
['丶今']='丶今何在丶:BAAALgAFFAEJAgAAAA==.',
['丶小']='丶小涛:BAABLgAFFH8JAAIKAAMJaRwrEQAJAQAKAAMJaRwrEQAJAQAAAA==.',
['丶马']='丶马冬什么:BAAALgAECgEJAgAAAA==.',
['丹尼']='丹尼尔克雷格:BAAALgAECgEJAQAAAA==.',
['丿彼']='丿彼岸丶花开:BAAALgAECgQJBwAAAA==.',
['乄尛']='乄尛西:BAAALgAFFAEJAQAAAA==.',
['义老']='义老板:BAAALgAECgcJAQAAAA==.',
['九五']='九五贰漆:BAAALgAECgEJAQAAAA==.',
['五个']='五个半柠檬丨:BAAALgAECgQJBQAAAA==.',
['五更']='五更琉璃丷:BAACLgAFFH8FAAIIAAIJ2hf/LgC1AAAIAAIJ2hf/LgC1AAAuAAQKfx4AAwcABwlQIFobAHIBAAgABglQIAhOAN4BAAcABgmvE1obAHIBAAAA.',
['人心']='人心薄凉丶伤:BAAALgAECgkJBgAAAA==.',
['伟大']='伟大的杯具:BAAALgADCgEJAQAAAA==.',
['传说']='传说的山山:BAABLgAFFH8HAAIKAAMJaBUHEwD9AAAKAAMJaBUHEwD9AAABLgAFFAUJEAAKAAwaAA==.',
['伪神']='伪神之书:BAABLgAFFH8FAAILAAMJxR9FFADFAAALAAMJxR9FFADFAAAAAA==.',
['你丶']='你丶看不见我:BAAALgAECgYJCwAAAA==.',
['你喷']='你喷喷我吧:BAAALgAECggJCQAAAA==.',
['你好']='你好再見丶:BAAALgAFFAQJAgAAAA==.',
['你抱']='你抱抱我吧:BAAALgAECgkJAQABLgAFFAQJAQAGAAAAAA==.',
['你拉']='你拉拉我吧:BAAALgAECgkJEAAAAA==.',
['你无']='你无视我吧:BAAALgAECggJCAAAAA==.',
['你有']='你有毛病啊丶:BAAALgAECgYJDQAAAA==.',
['你虐']='你虐待我吧:BAABLgAFFH8IAAIFAAQJcAZRBwDtAAAFAAQJcAZRBwDtAAABLgAFFAUJDAAMANMiAA==.',
['你锤']='你锤锤我吧:BAAALgAECgkJCQABLgAFFAcJBQAKANIGAA==.',
['你风']='你风筝我吧:BAAALgAECgkJCgABLgAFFAQJDAAMAH4TAA==.',
['你饶']='你饶过我吧:BAAALgAECgkJEgAAAA==.',
['保重']='保重猛牛:BAABLgAECn8VAAINAAcJ9Rq4JAAxAgANAAcJ9Rq4JAAxAgAAAA==.',
['俺屯']='俺屯俺是村长:BAAALgAFFAIJBAAAAA==.俺屯俺最冷:BAAALgAFFAIJBAAAAA==.俺屯俺最暖:BAAALgAECgEJAQAAAA==.俺屯俺最焱:BAAALgAECgMJBAAAAA==.俺屯俺最疯:BAACLgAFFH8FAAIEAAMJbB4rMQBTAAAEAAMJbB4rMQBTAAAuAAQKfxYAAgQABwn2ISkeALYCAAQABwn2ISkeALYCAAAA.俺屯辣柿椒:BAAALgAECgUJCAAAAA==.',
['傲天']='傲天一笑:BAAALgADCgEJAQAAAA==.',
['傷丶']='傷丶龍五:BAACLgAFFH8FAAMBAAIJGg2zDwCnAAABAAIJGg2zDwCnAAAOAAIJ4Rn0FwBSAAAuAAQKfxQAAwEABwm2GowWADMCAAEABwm2GowWADMCAA8ABAlfHuBBADEBAAAA.傷丶龍玖:BAAALgAFFAEJAQAAAA==.',
['光与']='光与暗各一半:BAAALgAFFAIJBAAAAA==.',
['兔棋']='兔棋棋:BAAALgAECgEJAQAAAA==.',
['八号']='八号楼小颢:BAAALgAECgYJDAAAAA==.',
['八重']='八重樱嘤嘤:BAAALgAECgMJAwAAAA==.',
['公子']='公子世无双:BAAALgAECgUJBAAAAA==.',
['兴风']='兴风狂啸:BAAALgAECgQJBgAAAA==.',
['兹茨']='兹茨:BAAALgAECgEJAQAAAA==.',
['内牛']='内牛满面:BAAALgAECgIJAgAAAA==.',
['再来']='再来一桶:BAAALgADCgMJAgAAAA==.',
['冰与']='冰与火之哥:BAAALgAECgEJAQAAAA==.',
['冰火']='冰火爽翻天:BAAALgAECgcJCAAAAA==.',
['冷月']='冷月羽殇:BAAALgADCgEJAQAAAA==.',
['冷淬']='冷淬:BAAALgAECgEJAQAAAA==.',
['凯尔']='凯尔:BAAALgAECgEJAQAAAA==.',
['凶得']='凶得丶批爆:BAAALgAECgYJAwAAAA==.',
['出门']='出门不带錢:BAAALgAECgEJAgAAAA==.',
['分劣']='分劣:BAAALgAECgYJBgAAAA==.',
['剁剁']='剁剁就爆头:BAAALgAECgMJBAAAAA==.',
['剁椒']='剁椒枸杞:BAAALgAECgEJAQAAAA==.',
['剑心']='剑心犹在丶:BAAALgAECgcJCwAAAA==.',
['十三']='十三九号丶:BAAALgAFFAMJAgAAAA==.十三十二号丶:BAAALgAFFAQJBAAAAA==.',
['十八']='十八个京牌:BAAALgAFFAQJBAAAAA==.十八岁的小玮:BAAALgAFFAEJAQAAAA==.十八酒坊:BAAALgAECgEJAQAAAA==.',
['十杠']='十杠九开:BAAALgADCgQJBAAAAA==.',
['午夜']='午夜悲伤:BAAALgAECgYJCQAAAA==.',
['半个']='半个世界下雨:BAABLgAFFH8IAAIQAAQJeQZMEQDnAAAQAAQJeQZMEQDnAAAAAA==.',
['单班']='单班叔叔:BAAALgADCgcJBwAAAA==.',
['单纯']='单纯愚乐:BAAALgAECgEJAQAAAA==.',
['单薄']='单薄半夏:BAAALgAECgEJAQAAAA==.',
['南宁']='南宁彭于晏:BAAALgAFFAIJAgAAAA==.',
['単纯']='単纯娱乐:BAAALgAECgUJAQAAAA==.',
['卡卡']='卡卡零零一:BAAALgADCgUJBQAAAA==.',
['卡库']='卡库:BAAALgADCgQJBAAAAA==.',
['厌蠢']='厌蠢又厌作:BAAALgAECgYJBgAAAA==.',
['古纳']='古纳纳:BAAALgAECgEJAQAAAA==.',
['吃人']='吃人吐骨头:BAAALgAFFAIJBAAAAA==.',
['吉伊']='吉伊卡哇:BAAALgADCgEJAQAAAA==.',
['呜呼']='呜呼上将:BAAALgAECgQJBgAAAA==.',
['周星']='周星祖:BAAALgAECgQJBAAAAA==.',
['咖啡']='咖啡海:BAAALgAFFAEJAwAAAA==.',
['哈基']='哈基牛:BAAALgAECgYJDAAAAA==.',
['哈挤']='哈挤牛:BAAALgAECgYJDAAAAA==.',
['哈达']='哈达街一棍哥:BAAALgAECgUJBQAAAA==.',
['哦豁']='哦豁:BAAALgAECgEJAQAAAA==.',
['哪个']='哪个狐狸:BAAALgADCgEJAQAAAA==.',
['喬裝']='喬裝進城:BAAALgADCgEJAQAAAA==.',
['嗨丶']='嗨丶黎紫:BAAALgADCgcJBwAAAA==.',
['嘎嘎']='嘎嘎法:BAACLgAFFH8XAAIKAAYJrR8uAgBwAgAKAAYJrR8uAgBwAgAuAAQKfxYAAgoABwm0JBFDAG8CAAoABwm0JBFDAG8CAAAA.嘎嘎萨:BAAALgAFFAIJBAABLgAFFAYJFwAKAK0fAA==.',
['嘎牙']='嘎牙子:BAAALgAECgYJCwAAAA==.',
['嘘低']='嘘低调:BAAALgAECgQJCAAAAA==.',
['噬一']='噬一把灭散:BAAALgAECgYJBgAAAA==.',
['四夕']='四夕丶:BAABLgAECn8XAAMRAAcJmBs1XwBKAQARAAYJKh41XwBKAQASAAUJNxe5TAAeAQAAAA==.',
['因帅']='因帅被判千年:BAAALgADCgYJBwAAAA==.',
['圆桌']='圆桌贰拾肆:BAAALgAFFAQJBAAAAA==.圆桌贰拾贰:BAAALgAFFAEJAQAAAA==.圆桌龙:BAAALgAFFAQJBAAAAA==.圆桌龙希儿:BAABLgAFFH8FAAITAAUJ/RR3AQCvAQATAAUJ/RR3AQCvAQAAAA==.',
['圣光']='圣光大宗师:BAAALgAECgUJBgAAAA==.圣光妖姬:BAAALgAECgEJAQAAAA==.',
['圣火']='圣火流年:BAABLgAECn8XAAIEAAcJryVLEQAGAwAEAAcJryVLEQAGAwABLgAFFAEJAQAGAAAAAA==.',
['在下']='在下拳很硬:BAAALgADCgMJAwAAAA==.',
['地狱']='地狱追猎者:BAAALgAECgEJAgAAAA==.',
['坦格']='坦格利安丶:BAAALgAECgUJCAAAAA==.',
['夏娜']='夏娜:BAACLgAFFH8FAAIUAAIJaA6cHQCFAAAUAAIJaA6cHQCFAAAuAAQKfyYAAxQABwljGIMfAAYCABQABwljGIMfAAYCABUAAQndEaiDAC0AAAAA.',
['夏季']='夏季八闪:BAACLgAFFH8GAAIKAAUJNBXDDQCtAQAKAAUJNBXDDQCtAQAuAAQKfxQAAgoABwl6JUgcAAUDAAoABwl6JUgcAAUDAAEuAAUUBgkEAAYAAAAA.',
['夏木']='夏木与磊:BAAALgAECgUJDAAAAA==.',
['夜半']='夜半无语时:BAAALgAECgIJAgAAAA==.',
['大恶']='大恶魔:BAAALgAECgEJAQAAAA==.',
['大手']='大手子:BAAALgAECgIJAQAAAA==.',
['大潘']='大潘:BAABLgAECn8WAAIBAAgJ6yLJCgDWAgABAAgJ6yLJCgDWAgAAAA==.',
['大火']='大火球糊你脸:BAAALgADCgUJBQAAAA==.',
['大粪']='大粪龙卷风:BAABLgAFFH8FAAIEAAUJ/g4HBgCPAQAEAAUJ/g4HBgCPAQAAAA==.',
['大红']='大红手:BAAALgAECgEJAwAAAA==.',
['大臭']='大臭猪:BAAALgAFFAMJAwAAAA==.',
['大苍']='大苍蝇:BAAALgADCgYJBgAAAA==.',
['大霸']='大霸:BAAALgAFFAIJAwAAAA==.',
['天使']='天使的泪:BAAALgAECgcJBwAAAA==.',
['头纹']='头纹子弟:BAAALgADCgYJCQAAAA==.',
['奈良']='奈良丶:BAAALgADCgEJAQAAAA==.',
['奔放']='奔放的小牛哥:BAAALgAECgEJAgAAAA==.',
['奥西']='奥西莉米雅:BAAALgAECgcJBwAAAA==.',
['好喜']='好喜欢下雪:BAACLgAFFH8QAAQWAAUJvCQJAAC/AQAWAAQJvCQJAAC/AQAQAAQJOSIaBwCYAQAXAAEJAAAAAAAAAAAuAAQKfy4AAxAACAk6JvUGAGoDABAACAkhJvUGAGoDABYABglgI1wBALgBAAAA.',
['妍一']='妍一小美:BAAALgAFFAIJAwAAAA==.',
['威尔']='威尔一史密斯:BAAALgAECgMJAwAAAA==.',
['媛来']='媛来爱你:BAAALgAECgEJAQAAAA==.',
['子夜']='子夜妖瞳:BAAALgAECgYJBAAAAA==.',
['子巴']='子巴嘎:BAABLgAFFH8GAAMQAAIJtRp9NgCuAAAQAAIJeRR9NgCuAAAXAAIJchoAAAAAAAABLgAFFAYJFwAKAK0fAA==.',
['子曰']='子曰太阳你:BAAALgAECgEJAQAAAA==.',
['孤影']='孤影夢随風:BAAALgAECgUJBgAAAA==.',
['安小']='安小暗:BAAALgAECgcJBgAAAA==.安小许:BAAALgAECgIJAgAAAA==.',
['完全']='完全没有感觉:BAAALgAECgYJCwAAAA==.',
['寒冬']='寒冬之灵:BAAALgAECgEJAQAAAA==.',
['寰瑾']='寰瑾:BAAALgAECgYJBgAAAA==.',
['射神']='射神之怒:BAAALgADCgMJAwAAAA==.',
['小卡']='小卡皮巴拉:BAAALgAECgYJCwAAAA==.',
['小咪']='小咪蜂:BAAALgADCgcJBwAAAA==.',
['小墨']='小墨墨:BAAALgAECgYJCgAAAA==.',
['小强']='小强不是很强:BAAALgAECgIJAgAAAA==.',
['小德']='小德变成熊:BAAALgAECgYJCAAAAA==.',
['小心']='小心我秒了你:BAAALgADCgcJBwAAAA==.',
['小猪']='小猪武僧:BAABLgAECn8UAAMYAAcJOxTCKQBpAQAYAAYJFBbCKQBpAQAVAAcJyxMFiwAiAAAAAA==.小猪诺诺德:BAAALgADCgkJCQAAAA==.',
['小魚']='小魚慕斯:BAAALgAECgEJAQAAAA==.',
['就是']='就是要扫兴:BAAALgADCgYJBgAAAA==.',
['居北']='居北子:BAAALgAECgYJBgAAAA==.',
['山里']='山里有姑娘:BAAALgAFFAEJAQAAAA==.',
['巭孬']='巭孬灬:BAAALgAECgIJBAAAAA==.',
['帅的']='帅的掉毛:BAAALgAECgQJBAAAAA==.',
['幺喂']='幺喂:BAAALgAECgcJEwAAAA==.',
['幽儿']='幽儿希卡:BAABLgAFFH8GAAITAAIJQhvVEAC2AAATAAIJQhvVEAC2AAAAAA==.',
['康健']='康健之基:BAAALgAECgUJBQAAAA==.',
['张老']='张老大:BAACLgAFFH8FAAILAAIJBhvXFwCiAAALAAIJBhvXFwCiAAAuAAQKfyIAAgsABwmTI5oOAMUCAAsABwmTI5oOAMUCAAAA.',
['张飞']='张飞:BAAALgAECgIJAwAAAA==.',
['影月']='影月幽刃:BAAALgADCgQJBAAAAA==.',
['徊捯']='徊捯過紶:BAAALgAECgEJAQAAAA==.',
['微灬']='微灬笑:BAAALgAECgUJCAAAAA==.',
['德圣']='德圣:BAAALgAECgMJBAAAAA==.',
['德德']='德德彭友:BAAALgADCgEJAQAAAA==.',
['心情']='心情看天气:BAAALgAECgYJBQAAAA==.',
['心火']='心火燎心:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁的鱿鱼:BAAALgAFFAQJBAAAAA==.',
['思丶']='思丶柒灬:BAAALgADCgMJAwAAAA==.',
['恶魔']='恶魔爸爸:BAAALgAECgYJDAAAAA==.',
['悠悠']='悠悠紫烬:BAAALgADCgEJAQAAAA==.',
['悠遠']='悠遠的蒼穹:BAAALgAECgEJAQAAAA==.',
['惊鸿']='惊鸿四起:BAAALgAECgMJAwAAAA==.',
['想吃']='想吃马卡龙:BAAALgAECgYJCwAAAA==.',
['愚者']='愚者:BAAALgAECgUJCQAAAA==.',
['慈母']='慈母手中贱:BAAALgAECgEJAgAAAA==.',
['慕容']='慕容箭神:BAAALgADCgYJBgAAAA==.',
['慕漪']='慕漪:BAABLgAECn8WAAIBAAgJQBMiGwAFAgABAAgJQBMiGwAFAgAAAA==.',
['慯丶']='慯丶龍九:BAAALgADCgUJBQAAAA==.',
['憨憨']='憨憨熊德春天:BAAALgADCgkJDAAAAA==.',
['我会']='我会冰箱:BAAALgAECgEJAgAAAA==.',
['我好']='我好乖的:BAAALgAECgkJBwAAAA==.',
['我干']='我干的:BAAALgAECgcJCAAAAA==.',
['我很']='我很害羞滴:BAABLgAECn8WAAIRAAgJQRjGHwBHAgARAAgJQRjGHwBHAgAAAA==.',
['我會']='我會消失:BAACLgAFFH8FAAICAAIJ/w7QEwCwAAACAAIJ/w7QEwCwAAAuAAQKfx8AAgIABwmtHGgXAE8CAAIABwmtHGgXAE8CAAAA.',
['打不']='打不打嘛:BAAALgAFFAIJBAAAAA==.',
['打扰']='打扰:BAABLgAFFH8HAAIUAAMJlQLPCgCnAAAUAAMJlQLPCgCnAAAAAA==.',
['托伽']='托伽拉:BAABLgAFFH8HAAMZAAMJyhhqAwATAQAZAAMJyBdqAwATAQANAAMJDBgiEAAHAQABLgAFFAUJEAAWALwkAA==.',
['扫把']='扫把佬阿豪:BAAALgAFFAEJAQAAAA==.',
['把把']='把把胡幺九:BAAALgAFFAEJAQAAAA==.',
['抓住']='抓住了阿巴瑟:BAAALgADCgEJAQAAAA==.',
['抹茶']='抹茶麻薯咕:BAAALgAECgQJBAAAAA==.',
['拉西']='拉西:BAAALgAECgcJBwAAAA==.',
['拽拽']='拽拽德:BAAALgAECgcJBwAAAA==.拽拽的石头:BAAALgAECgIJAgAAAA==.',
['挽梦']='挽梦忆笙歌:BAAALgADCggJBgAAAA==.',
['掌中']='掌中有乾坤:BAAALgAECgEJAgAAAA==.',
['掌风']='掌风:BAAALgAECgQJBAAAAA==.',
['握爪']='握爪好吗:BAAALgADCgcJBwAAAA==.',
['摇滚']='摇滚巴赫:BAAALgAECgYJEQAAAA==.',
['撒科']='撒科打诨:BAAALgADCgEJAgAAAA==.',
['放着']='放着我来:BAAALgAECgEJAQAAAA==.',
['斩龙']='斩龙:BAAALgAECgEJAQAAAA==.',
['无尽']='无尽致死:BAAALgAECgUJBQAAAA==.',
['无糖']='无糖可乐丶:BAAALgAFFAEJAQAAAA==.',
['旧梦']='旧梦如炽灬:BAACLgAFFH8FAAIaAAIJ1AxoAwCAAAAaAAIJ1AxoAwCAAAAuAAQKfyYAAxoABwnlGtoHAAQCABoABwnlGtoHAAQCABsAAQnqD5XeADMAAAAA.旧梦如鸩灬:BAAALgAFFAEJAQAAAA==.',
['星屑']='星屑的辉煌:BAAALgADCgEJAQAAAA==.',
['晚倾']='晚倾:BAAALgAECgYJCgAAAA==.',
['晚祈']='晚祈:BAAALgAECgcJDAAAAA==.',
['暗影']='暗影之锋:BAAALgAECgIJAgAAAA==.',
['曦影']='曦影:BAAALgAECgcJAQAAAA==.',
['曦玥']='曦玥灬雪:BAAALgAECgYJCAAAAA==.',
['曼巴']='曼巴奥特:BAAALgADCgcJBwABLgAECgkJEQAGAAAAAA==.',
['最帅']='最帅蛋总:BAAALgADCgcJBwAAAA==.',
['月下']='月下神灵:BAABLgAFFH8GAAIKAAIJxhvyNgC8AAAKAAIJxhvyNgC8AAAAAA==.',
['朔月']='朔月揽星河:BAAALgADCgcJBwABLgAECgYJCwAGAAAAAA==.',
['朕诛']='朕诛你九族:BAAALgAECgcJDAAAAA==.',
['未知']='未知恐惧:BAABLgAFFH8GAAMQAAUJkgLhIQAQAQAQAAUJkgLhIQAQAQAXAAEJAAAFFABSAAAAAA==.',
['来吃']='来吃妹妹毒奶:BAACLgAFFH8MAAIOAAQJwRlxBwBmAQAOAAQJwRlxBwBmAQAuAAQKfycAAw4ACQl1IlcBAIIDAA4ACQl1IlcBAIIDAA8AAwkjDzpmAJQAAAAA.',
['杨帅']='杨帅明:BAAALgAECgIJAwAAAA==.',
['杨翠']='杨翠花丶:BAAALgAECgIJAgAAAA==.',
['林宥']='林宥嘉丶:BAAALgAECgUJBQAAAA==.',
['果冻']='果冻爽:BAAALgAECgEJAQAAAA==.',
['格温']='格温:BAABLgAECn8iAAQRAAgJLSQtLAADAgASAAcJORz0IQATAgARAAYJ6R0tLAADAgAcAAUJFhptFwBUAQABLgAFFAEJAQAGAAAAAA==.',
['梅子']='梅子飘飘:BAAALgAECgIJAwAAAA==.',
['梆梆']='梆梆不梆梆:BAAALgAFFAEJAQAAAA==.',
['森多']='森多的小跟班:BAAALgADCgEJAQAAAA==.',
['楚河']='楚河:BAABLgAECn8fAAMNAAcJpRMOOADHAQANAAcJjhEOOADHAQAFAAEJeBCfRgAzAAAAAA==.',
['榜一']='榜一大哥:BAAALgAECgIJAwAAAA==.',
['樱落']='樱落:BAAALgAECgEJAQAAAA==.',
['橘子']='橘子仙人:BAAALgAECgQJBAAAAA==.',
['橘柚']='橘柚灬曦汐牧:BAAALgAECgIJAgAAAA==.',
['欧哈']='欧哈基里曼波:BAAALgAECgQJBAAAAA==.',
['止水']='止水丶:BAAALgAECgEJAQAAAA==.',
['殇丶']='殇丶封:BAAALgAECgUJCAAAAA==.殇丶龙少:BAAALgAECgcJBwAAAA==.',
['永恒']='永恒丶传奇:BAAALgAECgkJCQAAAA==.',
['氾凢']='氾凢犭:BAAALgAECgIJAgAAAA==.',
['求财']='求财之道:BAAALgAECgEJAQAAAA==.',
['汇源']='汇源果汁:BAAALgAECgEJAQAAAA==.',
['江南']='江南:BAAALgAECgUJCwAAAA==.',
['汽車']='汽車維修員:BAAALgAECgYJCAAAAA==.',
['沐勒']='沐勒:BAAALgAECgQJBAAAAA==.',
['波罗']='波罗吹雪:BAAALgAFFAEJAgAAAA==.',
['洒血']='洒血满天:BAAALgAECgEJAQAAAA==.',
['洛逸']='洛逸央:BAAALgAECgMJBAAAAA==.',
['洪荒']='洪荒之力圣光:BAAALgAECgEJAQAAAA==.',
['流光']='流光魂挽:BAACLgAFFH8OAAMIAAQJqiHzCQApAQAIAAMJFyDzCQApAQAHAAIJzyIVCQDIAAAuAAQKfyYAAggACAnAI7wFAGEDAAgACAnAI7wFAGEDAAAA.',
['流姩']='流姩:BAAALgAECgYJBwAAAA==.',
['流年']='流年旧梦:BAAALgAECgcJEwABLgAFFAYJEwAEAMggAA==.流年易逝:BAAALgAECgEJAQAAAA==.',
['流风']='流风残雪:BAAALgADCgEJAQAAAA==.',
['浅吻']='浅吻芹双唇:BAAALgAECgcJBwAAAA==.',
['浅浅']='浅浅:BAAALgAECgcJDwAAAA==.',
['海利']='海利安星歌:BAAALgAECgEJAQAAAA==.',
['海尼']='海尼曼:BAAALgADCgYJBwAAAA==.',
['清早']='清早被帅醒:BAACLgAFFH8NAAIEAAQJdRUIBQBEAQAEAAQJdRUIBQBEAQAuAAQKfxgAAgQACQlHGjYkAJcCAAQACQlHGjYkAJcCAAAA.',
['清风']='清风洗轻我狂:BAAALgAECgYJDQAAAA==.',
['游神']='游神的牧司:BAAALgADCgEJAQAAAA==.',
['湛灡']='湛灡:BAAALgAECgYJDAAAAA==.',
['湫丶']='湫丶:BAAALgAECgkJDgAAAA==.',
['灬杨']='灬杨幂灬:BAAALgAECgYJCAAAAA==.',
['灬赵']='灬赵丽颖灬:BAAALgAECgMJAwAAAA==.',
['灬郭']='灬郭富城灬:BAAALgAECgYJBwAAAA==.',
['烏鴉']='烏鴉归來:BAAALgAFFAIJBAAAAA==.',
['無敌']='無敌炉石:BAAALgAECgQJBAAAAA==.',
['焦山']='焦山大佬:BAAALgAFFAIJAwAAAA==.',
['熊猫']='熊猫伯茨:BAAALgAECgUJBQAAAA==.熊猫甜甜:BAAALgAECgYJCgAAAA==.',
['燃灭']='燃灭之手:BAAALgAECgQJBAAAAA==.',
['燃起']='燃起来了:BAAALgAECgEJAgAAAA==.',
['爆击']='爆击:BAAALgAECgEJAQAAAA==.',
['爱仕']='爱仕达后:BAAALgADCgMJAwAAAA==.',
['牛氓']='牛氓白菜:BAAALgAFFAEJAQAAAA==.',
['牛犇']='牛犇牛:BAAALgAECgQJBAAAAA==.',
['牛的']='牛的传人:BAAALgAECgcJDwAAAA==.',
['狂战']='狂战刚背:BAAALgAECgQJBAAAAA==.',
['狂暴']='狂暴战灬:BAAALgADCgUJBQAAAA==.',
['独孤']='独孤我才来:BAAALgAECgcJCwAAAA==.',
['猛牛']='猛牛传人:BAAALgAECgYJBwAAAA==.',
['猫丶']='猫丶大丶侠:BAAALgAECgYJDQAAAA==.',
['猫了']='猫了个喵:BAAALgAECgYJAgAAAA==.',
['猫儿']='猫儿猫儿:BAAALgAECgMJAwAAAA==.',
['猫星']='猫星一等公民:BAAALgAECgUJCAAAAA==.',
['猫眼']='猫眼学长:BAAALgAECgEJAgAAAA==.',
['玉早']='玉早前:BAAALgAECgQJBQAAAA==.',
['玉林']='玉林彭于晏:BAAALgAECgYJEAAAAA==.',
['王百']='王百生:BAAALgAECgEJAQAAAA==.',
['玛蒂']='玛蒂尔达:BAAALgAECgYJCwABLgAFFAEJAQAGAAAAAA==.',
['瑟曦']='瑟曦:BAAALgAFFAEJAQABLgAFFAIJAgAGAAAAAA==.',
['画里']='画里桃花:BAAALgAECgIJAgAAAA==.',
['痴呆']='痴呆康复大师:BAAALgAECgcJCAAAAA==.',
['白銀']='白銀騎士:BAABLgAFFH8FAAIEAAUJqQXTCQBeAQAEAAUJqQXTCQBeAQABLgAFFAcJBQAKANIGAA==.',
['百步']='百步穿杨:BAAALgAECgEJAQAAAA==.',
['皮卡']='皮卡乒乓:BAAALgAECgQJBAAAAA==.',
['皮皮']='皮皮睿:BAAALgAECgQJBAAAAA==.',
['盐酸']='盐酸哌替啶:BAAALgAECgMJAwAAAA==.',
['知闲']='知闲妹妹:BAAALgAECgUJCQAAAA==.',
['神丶']='神丶踪:BAAALgAECgYJEQAAAA==.',
['神经']='神经小伙:BAAALgAECgMJAwAAAA==.',
['秋风']='秋风之疾:BAAALgAECggJEwAAAA==.',
['窑街']='窑街痞子:BAAALgAECgEJAQAAAA==.',
['站住']='站住别跑丶射:BAAALgADCgQJBAAAAA==.',
['笑傲']='笑傲浆糊:BAAALgAECgUJCQAAAA==.',
['第四']='第四使徒丶:BAAALgAECgYJDwAAAA==.',
['简洁']='简洁小酒:BAAALgAECgYJCQAAAA==.',
['米兰']='米兰的小铁锤:BAABLgAECn8WAAILAAgJ1RKQDACLAQALAAgJ1RKQDACLAQAAAA==.',
['米德']='米德拉什:BAAALgAECgYJDQAAAA==.',
['米诺']='米诺绯:BAAALgAECgQJBAAAAA==.',
['精神']='精神小伙儿:BAAALgAFFAEJAQAAAA==.',
['索菲']='索菲娅奥塔斯:BAAALgADCgUJBQAAAA==.',
['紫雨']='紫雨牛牛:BAABLgAFFH8JAAIdAAQJIh2TCABZAQAdAAQJIh2TCABZAQAAAA==.',
['縁寿']='縁寿:BAABLgAECn8WAAMIAAcJ9BOyUwDMAQAIAAcJ9BOyUwDMAQAHAAMJywkBRQChAAAAAA==.',
['红莲']='红莲之轨迹:BAABLgAFFH8HAAMJAAMJbSEVAQBjAAAIAAIJqCP2EwDEAAAJAAEJ9hwVAQBjAAAAAA==.',
['纯洁']='纯洁小可爱:BAAALgAECgQJAwAAAA==.',
['纯白']='纯白之刃:BAABLgAFFH8JAAIEAAQJ9RUdCwBTAQAEAAQJ9RUdCwBTAQAAAA==.',
['绝对']='绝对圣光:BAAALgAECgUJDgAAAA==.',
['绯月']='绯月十六:BAAALgAECgEJAQAAAA==.',
['羊天']='羊天帝:BAAALgAFFAMJBAAAAA==.',
['老七']='老七发糖啦:BAAALgAECgQJBAAAAA==.',
['老乱']='老乱吃生火:BAABLgAECn8VAAIQAAcJmhwUNQBiAgAQAAcJmhwUNQBiAgAAAA==.',
['老年']='老年阿冰:BAAALgAECgMJAwAAAA==.',
['聖小']='聖小鹏:BAAALgAECgEJAgAAAA==.',
['肥嘉']='肥嘉嘉:BAAALgAECgYJCgAAAA==.',
['肾光']='肾光之力:BAAALgAECgYJDAAAAA==.',
['胖胖']='胖胖大厨:BAAALgAECgYJEAAAAA==.',
['胡桃']='胡桃:BAAALgAECgYJDwAAAA==.',
['脑壳']='脑壳不对:BAAALgADCgcJCAAAAA==.',
['脑袋']='脑袋尖尖的:BAAALgAECgEJAQAAAA==.',
['致终']='致终将的忘却:BAAALgAECgcJAQAAAA==.',
['良品']='良品兔子:BAAALgAECgEJAQAAAA==.',
['艾利']='艾利桑徳:BAAALgADCgYJBgAAAA==.',
['艿骑']='艿骑:BAAALgADCgcJBwAAAA==.',
['花式']='花式乱砍冠军:BAAALgAECgYJCgAAAA==.',
['芽衣']='芽衣:BAAALgAECgUJBQAAAA==.',
['苏察']='苏察哈尔擦:BAAALgAECgEJAQAAAA==.',
['草帽']='草帽君屮:BAAALgAFFAQJAQAAAA==.',
['莉法']='莉法:BAAALgAECgEJAQAAAA==.',
['莱赞']='莱赞:BAABLgAFFH8JAAIdAAIJaRNnCACnAAAdAAIJaRNnCACnAAAAAA==.',
['萌妹']='萌妹杀手:BAAALgAECgEJAQAAAA==.',
['萌萌']='萌萌的筱琪:BAAALgADCgEJAQAAAA==.',
['葉的']='葉的一瓣:BAAALgADCgEJAQAAAA==.',
['蒙妮']='蒙妮坦:BAAALgADCgUJBgAAAA==.',
['薄荷']='薄荷起飞:BAAALgAECgEJAQAAAA==.',
['虚空']='虚空灬幽荫:BAAALgAECgQJBAAAAA==.',
['虾仁']='虾仁猪心堡:BAAALgAECgcJEwAAAA==.',
['血夜']='血夜番茄:BAAALgAECggJAQAAAA==.',
['血鸦']='血鸦:BAAALgAECgYJCQAAAA==.',
['袁丨']='袁丨少:BAAALgAECgcJDgAAAA==.',
['西门']='西门灬鬼仆:BAAALgAECgEJAQAAAA==.',
['观棋']='观棋:BAABLgAECn8dAAQIAAkJmw/KVgDDAQAIAAgJ5wzKVgDDAQAHAAUJ+AwGJwApAQAJAAIJ/wssHQCIAAAAAA==.',
['解雨']='解雨晨:BAAALgAECgYJBgAAAA==.',
['誓死']='誓死保护刘波:BAAALgAECgEJAQAAAA==.',
['诡秘']='诡秘侍者:BAAALgAECgEJAQAAAA==.',
['谁醉']='谁醉饮花香:BAAALgAECgkJCQAAAA==.',
['超导']='超导磁小轨:BAAALgAECgYJDAAAAA==.',
['路边']='路边牛:BAAALgAECgYJBgAAAA==.',
['身如']='身如不系之舟:BAAALgAFFAEJAQAAAA==.',
['躲躲']='躲躲:BAAALgAECgkJBgAAAA==.',
['轻风']='轻风留影:BAEALgAECgYJBgAAAA==.',
['达尔']='达尔卡:BAAALgAECgEJAQAAAA==.',
['迎战']='迎战丨未来:BAAALgAECgQJBwAAAA==.',
['近战']='近战丶停手:BAAALgAECgQJBAAAAA==.',
['远古']='远古丨骑士:BAAALgADCgcJBwAAAA==.',
['逝沿']='逝沿:BAAALgAFFAEJAQAAAA==.',
['遮灬']='遮灬天:BAAALgADCgEJAQAAAA==.',
['邀月']='邀月洛曦:BAAALgAECgcJCQAAAA==.邀月洛雪:BAAALgAECgcJCQAAAA==.',
['酷德']='酷德乐:BAAALgAECgQJBAAAAA==.',
['酷酷']='酷酷小黑牛:BAABLgAECn8jAAMNAAcJOyAlFwCTAgANAAcJOyAlFwCTAgAFAAIJlBxxPwBVAAAAAA==.',
['酿酒']='酿酒师:BAAALgADCgIJAgAAAA==.',
['醉筱']='醉筱筱:BAAALgAECgMJDQAAAA==.',
['釋呿']='釋呿的傳説:BAAALgAECgYJBgAAAA==.',
['重案']='重案组之虎:BAAALgAECgcJDgAAAA==.',
['铁血']='铁血蛮牛:BAAALgAECgYJDgAAAA==.铁血黑蛮牛:BAAALgAECgQJBQAAAA==.',
['银时']='银时红豆饭:BAAALgAECgQJBgAAAA==.',
['闵小']='闵小白:BAAALgAECgIJAgAAAA==.',
['阿利']='阿利丶斯塔:BAAALgAECgQJBwAAAA==.',
['阿卡']='阿卡姆丶术癫:BAAALgADCgUJBQAAAA==.',
['阿库']='阿库娅:BAAALgAECgEJAQAAAA==.',
['阿撒']='阿撒托斯丶僧:BAABLgAFFH8HAAIUAAQJ/BqMFQDJAAAUAAQJ/BqMFQDJAAAAAA==.阿撒托斯丶萨:BAAALgAFFAMJAwAAAA==.阿撒托斯丶術:BAABLgAFFH8GAAIIAAQJdA+AGQAlAQAIAAQJdA+AGQAlAQAAAA==.',
['阿棕']='阿棕:BAACLgAFFH8FAAILAAIJHR9uFQC4AAALAAIJHR9uFQC4AAAuAAQKfx8AAgsABwk3Ih8XAH0CAAsABwk3Ih8XAH0CAAAA.',
['阿泽']='阿泽玛:BAAALgADCgIJAgAAAA==.',
['阿紫']='阿紫:BAAALgAFFAIJAgABLgAFFAIJBQAUAGgOAA==.',
['阿肆']='阿肆蒙蒂斯:BAAALgAECgIJAgAAAA==.',
['随小']='随小宇:BAAALgAECggJCwAAAA==.',
['隔岸']='隔岸观火:BAAALgAECgYJEAAAAA==.',
['雨聲']='雨聲残响:BAAALgAECgEJAQAAAA==.',
['雪丶']='雪丶璃:BAAALgAECgEJAgAAAA==.',
['雷霆']='雷霆守护:BAAALgADCgUJBQAAAA==.',
['露奈']='露奈雅拉:BAAALgADCgYJBAAAAA==.',
['霹雳']='霹雳娇娃:BAAALgAECgQJBgAAAA==.',
['青椒']='青椒炒蛋:BAAALgAECgMJAwAAAA==.',
['韭菜']='韭菜龍丨柒号:BAAALgADCgYJBgAAAA==.',
['顶着']='顶着龟壳爬:BAAALgAECgQJBAAAAA==.',
['额额']='额额哈哈:BAACLgAFFH8JAAMNAAUJNSKpCABkAQANAAQJNSKpCABkAQAZAAEJAADpDABMAAAuAAQKfyIAAw0ACQkVIAMGAEcDAA0ACQm1HgMGAEcDABkAAgnNH94nALAAAAAA.',
['风引']='风引鹤:BAAALgAECgUJBQAAAA==.',
['风翱']='风翱:BAAALgAECgIJAgAAAA==.',
['风雪']='风雪夜归猫:BAAALgAECgYJCQAAAA==.',
['风雷']='风雷之翼:BAAALgAECgUJCAAAAA==.',
['飘雪']='飘雪趁寒霜:BAAALgAECgkJCAAAAA==.',
['飞莞']='飞莞:BAABLgAECn8UAAIbAAgJCBS8TgC6AQAbAAgJCBS8TgC6AQAAAA==.',
['馄饨']='馄饨不加盐:BAAALgAECgMJBAAAAA==.',
['魔能']='魔能小裤裤:BAAALgADCgMJAwAAAA==.',
['鲜血']='鲜血弥漫:BAAALgAFFAIJAgAAAA==.',
['鲸鱼']='鲸鱼呆呆:BAAALgAECgQJBQAAAA==.',
['鸥西']='鸥西里斯:BAAALgAECgYJBgAAAA==.',
['鹤泣']='鹤泣九重渊:BAAALgADCgcJBwAAAA==.',
['麻夜']='麻夜王丶:BAAALgAECgEJAwAAAA==.',
['黑参']='黑参参:BAAALgAECgIJAQAAAA==.',
['黑手']='黑手飓风:BAAALgAECgIJAwAAAA==.',
['默默']='默默丫头:BAAALgAECgMJAwAAAA==.',
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
