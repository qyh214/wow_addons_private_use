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

local lookup = {'Priest-Shadow','Priest-Holy','Evoker-Augmentation','Paladin-Retribution','Priest-Discipline','Paladin-Protection','DemonHunter-Havoc','Warrior-Fury','Warrior-Protection','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Mage-Frost','Monk-Windwalker','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','Warlock-Demonology','Evoker-Preservation','Evoker-Devastation','DeathKnight-Blood','Druid-Restoration','Monk-Brewmaster','Warrior-Arms','DemonHunter-Devourer',}
local provider = {region='CN',realm='外域',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Blast:BAAALgAECgYJDgAAAA==.',
De='Devilmaycry:BAAALgAECgMJAwAAAA==.',
Dr='Dreamo:BAAALgADCgIJAgAAAA==.',
Et='Etmemory:BAAALgAECgYJBgAAAA==.',
Gh='Ghostdog:BAABLgAECn8XAAMBAAYJVhjkKQCLAQABAAYJVhjkKQCLAQACAAYJgwjFSQARAQAAAA==.',
Ha='Halfkoala:BAAALgAECgYJCwABLgAFFAMJCQADAKolAA==.',
Ka='Kathen:BAAALgAECgYJEAAAAA==.',
La='Last:BAAALgADCgUJBQAAAA==.',
Ld='Ld:BAAALgAECgEJAQAAAA==.',
Le='Leclerc:BAAALgAECgcJAwAAAA==.',
Li='Liadrin:BAABLgAFFH8HAAIEAAQJXBaXCgBYAQAEAAQJXBaXCgBYAQAAAA==.',
Ll='Llzy:BAAALgAECgkJCQAAAA==.',
Ls='Lsabella:BAABLgAECn8UAAMFAAcJLw0CIwB8AQAFAAcJLw0CIwB8AQACAAYJqgLfVADjAAAAAA==.',
Ly='Lycks:BAAALgAFFAEJAQAAAA==.Lyjxs:BAAALgAFFAEJAQAAAA==.Lyxls:BAAALgAECgcJDAAAAA==.Lyyes:BAABLgAECn8WAAIGAAcJQA0ZGgA/AQAGAAcJQA0ZGgA/AQAAAA==.',
Ma='Maybee:BAAALgAECgMJAwAAAA==.',
Mi='Missnvg:BAAALgAFFAEJAgAAAA==.',
Ne='Neoo:BAAALgAFFAIJAwAAAA==.',
Ry='Ryasundruid:BAAALgAFFAIJAgAAAA==.',
Sa='Sarrite:BAAALgADCgUJBQAAAA==.',
Sh='Sheldoms:BAAALgAECgcJDwAAAA==.',
Th='Thursday:BAAALgADCgQJBAAAAA==.',
Ve='Venchi:BAAALgAECgcJBwAAAA==.',
Wi='Windwhisper:BAAALgADCgUJBQAAAA==.',
Ye='Yellowbaby:BAAALgAECgYJCAAAAA==.',
['一世']='一世安然:BAAALgADCgUJBQAAAA==.',
['一只']='一只胖熊猫丶:BAAALgADCgcJBAAAAA==.',
['一笑']='一笑而過:BAAALgAECgEJAQAAAA==.',
['七森']='七森莉莉丶:BAAALgADCgYJBgAAAA==.',
['万物']='万物皆可射:BAAALgAECgMJAgAAAA==.万物皆可浪:BAAALgAECgEJAwAAAA==.',
['三里']='三里烟村:BAAALgAECgYJDAAAAA==.',
['不要']='不要追我:BAAALgAFFAIJAwAAAA==.',
['专门']='专门献祭草哥:BAABLgAECn8VAAIHAAYJ7hypBACKAQAHAAYJ7hypBACKAQAAAA==.专门闪现草哥:BAAALgAECgUJBgAAAA==.',
['丨冲']='丨冲锋切唧唧:BAAALgAFFAIJAwAAAA==.',
['丨史']='丨史泰龙丶:BAABLgAECn8WAAIIAAYJOxS8DABVAQAIAAYJOxS8DABVAQABLgAFFAcJDQAJAM4ZAA==.',
['丨周']='丨周二少丶:BAAALgAECgYJCwABLgAECgYJDgAKAAAAAA==.',
['丨阿']='丨阿尔薩斯丨:BAAALgAECgIJAgAAAA==.',
['丶恍']='丶恍惚:BAAALgADCgMJAwAAAA==.',
['丿丷']='丿丷乀乄巜屮:BAAALgAECgUJBQAAAA==.',
['乱舞']='乱舞小咕咕:BAAALgAECgcJDQAAAA==.乱舞小嘟嘟:BAAALgADCgYJBgAAAA==.',
['于星']='于星夜:BAAALgAECgcJCwAAAA==.',
['亚玛']='亚玛逊:BAAALgAECgIJAQAAAA==.',
['人形']='人形大灰狗:BAAALgADCgEJAQAAAA==.',
['人生']='人生贵淡泊:BAAALgAECgEJAQAAAA==.',
['亿万']='亿万少女的梦:BAAALgAECgYJDAAAAA==.',
['以我']='以我之血:BAAALgAECgYJDAAAAA==.',
['伊利']='伊利氮:BAAALgAECgMJAwAAAA==.',
['优磐']='优磐地妖枝:BAAALgAECgIJAgAAAA==.',
['会赢']='会赢地:BAAALgAECgMJAwAAAA==.',
['依然']='依然烤香肠:BAABLgAFFH8LAAMLAAQJrBpSDQAGAQALAAMJuR5SDQAGAQAMAAEJkwt2HwBFAAAAAA==.',
['侵蚀']='侵蚀污染:BAAALgAECgcJBwAAAA==.',
['信仰']='信仰之力:BAAALgADCgIJAgAAAA==.',
['偶迈']='偶迈噶得:BAAALgAECgUJBQAAAA==.',
['傲血']='傲血天风:BAAALgAECgYJCgAAAA==.',
['光铸']='光铸亲王霜火:BAAALgAECgIJAgABLgAFFAIJAgAKAAAAAA==.',
['六连']='六连杀:BAAALgAECgEJAQAAAA==.',
['凤夙']='凤夙丶:BAAALgADCgUJBQAAAA==.',
['凯恩']='凯恩之裔:BAAALgAECgMJAwAAAA==.',
['刘大']='刘大宝:BAAALgAFFAEJAQAAAA==.',
['刘珂']='刘珂:BAAALgAECgMJAwAAAA==.',
['刹那']='刹那繁华:BAAALgAECgMJAwAAAA==.',
['北极']='北极小兔:BAAALgADCgQJBAAAAA==.',
['十里']='十里飘雪:BAAALgAECgIJAgAAAA==.',
['千幻']='千幻流光:BAABLgAECn8iAAINAAgJLBkLRQBoAgANAAgJLBkLRQBoAgAAAA==.',
['千鹤']='千鹤观空:BAAALgAECgcJCgAAAA==.',
['午后']='午后紅茶:BAAALgAECgEJAQAAAA==.',
['半只']='半只熊猫:BAABLgAFFH8LAAIOAAMJfyGLAgAaAQAOAAMJfyGLAgAaAQAAAA==.',
['半吨']='半吨土豆:BAAALgAECgMJBAAAAA==.',
['卌爱']='卌爱莎卌:BAAALgAECgIJAgAAAA==.',
['卖炊']='卖炊饼的:BAAALgADCgUJCAAAAA==.',
['卖萌']='卖萌怪丶嘤嘤:BAAALgAECgYJBgAAAA==.',
['南南']='南南:BAAALgAECgQJBAAAAA==.',
['发财']='发财暴富:BAAALgADCgYJCwAAAA==.',
['呜喵']='呜喵王丶:BAAALgADCggJCQAAAA==.',
['咸湿']='咸湿:BAAALgAECgYJBgAAAA==.',
['哈工']='哈工:BAAALgAECgYJCgAAAA==.',
['喷射']='喷射火龙:BAAALgAFFAEJAQAAAA==.',
['圆子']='圆子与团子:BAAALgAECgYJCQAAAA==.',
['圣帝']='圣帝弑神:BAAALgAECgEJAQAAAA==.',
['坏気']='坏気十哫:BAAALgAECgcJBwAAAA==.',
['坠入']='坠入凡尘:BAABLgAECn8VAAILAAcJxQuORwBjAQALAAcJxQuORwBjAQAAAA==.',
['塔尖']='塔尖上的男人:BAAALgADCgEJAQAAAA==.',
['塔斯']='塔斯叮苟圣光:BAAALgAECgMJBAAAAA==.',
['夏日']='夏日微凉:BAAALgAECgEJAgAAAA==.',
['夏雪']='夏雪瑶:BAAALgAECgEJAQAAAA==.',
['夜游']='夜游:BAACLgAFFH8FAAIPAAQJWxtBAgBrAQAPAAQJWxtBAgBrAQAuAAQKfxUAAw8ABwlVHwIoABgCAA8ABgkaIQIoABgCABAABAlzEhFXAOsAAAAA.',
['夜溪']='夜溪儿:BAACLgAFFH8HAAIRAAIJOhzpEgCvAAARAAIJOhzpEgCvAAAuAAQKfxcAAxEACQmFGcUTAHQCABEACQmFGcUTAHQCAAQABgknDPygAD0BAAAA.夜溪兒:BAAALgAFFAIJBAAAAA==.',
['大地']='大地妈:BAAALgAECgYJBgAAAA==.',
['大德']='大德鲁伊阿歪:BAAALgAECgEJAQAAAA==.',
['大潘']='大潘潘:BAAALgAECgIJAgAAAA==.',
['大表']='大表哥丶:BAAALgAECgUJBQAAAA==.',
['天堂']='天堂信仰丶朮:BAAALgAECgEJAQABLgAFFAQJBQAJAK4CAA==.',
['好大']='好大:BAAALgAECgEJAQAAAA==.',
['姑酌']='姑酌:BAAALgADCgUJBQAAAA==.',
['威廉']='威廉姆斯:BAAALgAECgEJAQAAAA==.',
['娴熟']='娴熟的艾瑞娜:BAAALgAECgYJEQAAAA==.',
['媚惑']='媚惑者:BAAALgAECgcJCwAAAA==.',
['宇文']='宇文術学:BAABLgAFFH8GAAISAAQJ6AoqJgDoAAASAAQJ6AoqJgDoAAAAAA==.',
['守之']='守之血骑:BAABLgAECn8XAAIEAAcJ1yQABABlAgAEAAcJ1yQABABlAgAAAA==.',
['宝宝']='宝宝咬她咬啊:BAAALgADCgEJAQAAAA==.',
['家有']='家有只熊:BAAALgAECgYJBgAAAA==.',
['小乄']='小乄宝贝:BAAALgAECgEJAQAAAA==.',
['小奶']='小奶德:BAAALgADCgYJBgAAAA==.',
['小學']='小學我念過:BAAALgADCgYJBwAAAA==.',
['小林']='小林未郁:BAABLgAFFH8GAAISAAQJPgztHgAIAQASAAQJPgztHgAIAQAAAA==.',
['小熙']='小熙:BAAALgAECgcJCwAAAA==.',
['小芈']='小芈:BAAALgAECgYJBgAAAA==.',
['小镇']='小镇做题家:BAAALgAECgYJBgAAAA==.',
['小黄']='小黄油拿铁:BAAALgADCgYJBgAAAA==.',
['少年']='少年郎丶:BAAALgAFFAEJAQAAAA==.',
['就不']='就不奶就哔哔:BAAALgAECgYJBgAAAA==.',
['尼奥']='尼奥奥龙:BAABLgAECn8YAAMTAAcJcxiLFAD+AQATAAcJcxiLFAD+AQADAAUJ5QJyYgAyAAAAAA==.尼奥龙:BAABLgAECn8UAAMTAAkJCxPlFwDWAQATAAcJsRTlFwDWAQAUAAcJHxB2FQCWAQABLgAFFAUJCwATAFsVAA==.尼奥龙龙:BAABLgAECn8bAAMTAAcJySPCBwDBAgATAAcJySPCBwDBAgADAAQJXgxxQQDeAAAAAA==.',
['尼尼']='尼尼奥奥龙:BAAALgAECgcJBwAAAA==.尼尼奥奥龙龙:BAAALgADCgkJDwAAAA==.尼尼奥龙:BAABLgAECn8VAAMTAAcJvRpsEAA0AgATAAcJvRpsEAA0AgAUAAEJ/BTgPwAxAAAAAA==.',
['巫小']='巫小可:BAAALgAECgQJBAAAAA==.',
['巫毒']='巫毒嘎嘎:BAAALgAECgYJCQAAAA==.',
['布莱']='布莱恩恰鸡:BAAALgAECgcJBgAAAA==.',
['席琳']='席琳虛空牧:BAAALgAECgYJBgAAAA==.',
['幻痛']='幻痛:BAAALgAECgEJAQAAAA==.',
['幽兰']='幽兰血姬:BAAALgAFFAEJAQAAAA==.',
['弹珠']='弹珠:BAAALgAECgUJBQAAAA==.',
['微光']='微光:BAACLgAFFH8JAAIEAAQJbhqfCgBXAQAEAAQJbhqfCgBXAQAuAAQKfxoAAgQABwlKJaIYANUCAAQABwlKJaIYANUCAAAA.',
['德古']='德古拉阴影:BAAALgADCgUJAQAAAA==.',
['心情']='心情在变:BAAALgAECgYJBgAAAA==.',
['想不']='想不开:BAAALgAECgQJBAAAAA==.',
['想要']='想要一顿胖揍:BAAALgADCgYJBgAAAA==.',
['愤怒']='愤怒之心:BAAALgAECgYJDgAAAA==.',
['我是']='我是活老鬼:BAAALgAECgEJAQAAAA==.我是闪电:BAAALgAECgEJAQAAAA==.',
['战地']='战地厨师:BAAALgAECgYJBwAAAA==.',
['手里']='手里纂的手:BAAALgAECgEJAwAAAA==.',
['打肥']='打肥鸡:BAAALgAECgYJCwAAAA==.',
['抠脚']='抠脚小郎君:BAABLgAECn8bAAINAAcJBBy1YAAZAgANAAcJBBy1YAAZAgAAAA==.',
['拉文']='拉文克劳冠冕:BAAALgAECgMJBgAAAA==.',
['摇了']='摇了摇头灬:BAAALgAFFAIJAwAAAA==.',
['放了']='放了那大婶:BAAALgAECgYJCgAAAA==.',
['放开']='放开那个蛋蛋:BAAALgAECgQJBwAAAA==.',
['无名']='无名的人:BAAALgADCgEJAQAAAA==.',
['无垢']='无垢的塞恩娜:BAAALgAECgcJDgAAAA==.',
['无敌']='无敌旋风腿:BAAALgAFFAIJAwAAAA==.',
['明月']='明月心:BAAALgAFFAEJAwAAAA==.',
['星丶']='星丶:BAAALgAECgUJBgAAAA==.',
['星光']='星光下的玫瑰:BAAALgAECgIJAgAAAA==.',
['星痕']='星痕破晓:BAAALgAECgEJAgAAAA==.',
['星辰']='星辰魂:BAAALgAECgQJBAAAAA==.',
['春风']='春风不解意:BAAALgAECgYJCgAAAA==.',
['暴食']='暴食强袭:BAAALgADCgUJBQAAAA==.',
['月夜']='月夜幻世:BAAALgAECgkJDwAAAA==.',
['月落']='月落云生:BAAALgAECgMJAwAAAA==.',
['有一']='有一个德:BAAALgAECgQJCAAAAA==.',
['杀气']='杀气入指間:BAAALgAECgYJBwAAAA==.',
['林晨']='林晨:BAAALgAECgcJCAAAAA==.',
['枫人']='枫人愿:BAAALgAFFAIJAgAAAA==.',
['枫舞']='枫舞尛蓝:BAAALgAECgEJAQAAAA==.',
['柏崎']='柏崎星奈:BAAALgAECgYJCQAAAA==.',
['桃大']='桃大爷:BAAALgAECgQJBAAAAA==.',
['桜椛']='桜椛:BAAALgAECgYJBgAAAA==.',
['梅蒽']='梅蒽梅:BAAALgAECgYJBgAAAA==.',
['棉花']='棉花糖小熊:BAAALgAECgcJBwAAAA==.',
['欢茄']='欢茄炒鸡蛋:BAAALgAECgcJBwAAAA==.',
['歪特']='歪特多拉贡:BAAALgAECgEJAQAAAA==.',
['歲月']='歲月雨中奏:BAABLgAFFH8GAAIVAAMJOAXqDACiAAAVAAMJOAXqDACiAAAAAA==.',
['死亡']='死亡边境:BAAALgAECgQJCAAAAA==.',
['水星']='水星冲浪手:BAAALgAECgkJAgAAAA==.',
['法痞']='法痞:BAAALgAECgQJCAAAAA==.',
['泡泡']='泡泡哒冰:BAAALgADCgIJAgAAAA==.泡泡哒溪:BAAALgAECgQJAQAAAA==.',
['波波']='波波虎:BAAALgAECgYJDAAAAA==.',
['泰奶']='泰奶奶骑白虎:BAAALgAFFAIJBAABLgAFFAQJBwAEAFwWAA==.',
['洗心']='洗心革面流风:BAAALgAECgYJBgAAAA==.',
['洛丽']='洛丽塔审查官:BAAALgAECgQJBAAAAA==.',
['流氓']='流氓帅哥:BAAALgADCgEJAQAAAA==.',
['浅巷']='浅巷墨漓:BAAALgADCgIJAgAAAA==.',
['海滩']='海滩:BAAALgAECgEJAQAAAA==.',
['液魔']='液魔影瑝:BAAALgAFFAIJBAAAAA==.',
['涴涴']='涴涴清风:BAABLgAFFH8FAAIRAAMJuhFvBgDrAAARAAMJuhFvBgDrAAAAAA==.',
['淡定']='淡定的灬土豆:BAAALgAECggJEwAAAA==.',
['清风']='清风狂虐:BAAALgAECgUJBwAAAA==.',
['渣男']='渣男二号灬:BAABLgAFFH8GAAIWAAMJBgPiFQCzAAAWAAMJBgPiFQCzAAAAAA==.',
['滚球']='滚球球:BAAALgAECgYJAwAAAA==.',
['潇洒']='潇洒的小猪猪:BAAALgAECgcJBwAAAA==.',
['火锅']='火锅吃特辣:BAAALgAECgYJCgAAAA==.火锅味:BAAALgAECgUJBwAAAA==.',
['灬殘']='灬殘韌灬:BAAALgAECgYJCwAAAA==.',
['灲魂']='灲魂:BAAALgAECgEJAgAAAA==.',
['烟雨']='烟雨夜:BAAALgAECgQJBQAAAA==.',
['烦了']='烦了烦了:BAAALgADCgEJAQAAAA==.',
['烬劫']='烬劫丶瞳淵:BAAALgAECgYJCAABLgAFFAQJCwAOAEgaAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgABAAcWAA==.',
['熊熊']='熊熊本熊:BAAALgAECgMJAwAAAA==.',
['爱落']='爱落风尘:BAAALgADCgEJAQAAAA==.',
['牛一']='牛一哥被注册:BAAALgAECgEJAQAAAA==.',
['牛之']='牛之刚健:BAAALgAECgQJBAAAAA==.',
['牛牛']='牛牛本牛:BAAALgAECgEJAQAAAA==.',
['牧玖']='牧玖:BAAALgAECgQJBwAAAA==.',
['牧畜']='牧畜业手艺人:BAAALgAFFAIJBAAAAA==.',
['狂野']='狂野的男人:BAAALgAECggJCAAAAA==.',
['狐狸']='狐狸蓓蓓:BAAALgAECgkJCQAAAA==.',
['猥者']='猥者至尊:BAAALgAECgcJBwAAAA==.',
['猪脚']='猪脚捞面:BAAALgAECgUJBQAAAA==.',
['猫不']='猫不是我家滴:BAAALgAECgUJBQAAAA==.',
['猫就']='猫就是我家滴:BAABLgAFFH8IAAIXAAQJSQuLDgAPAQAXAAQJSQuLDgAPAQAAAA==.',
['玻璃']='玻璃訫:BAAALgAECgcJCAAAAA==.',
['珀尔']='珀尔托:BAABLgAECn8VAAICAAgJWQmIMgB2AQACAAgJWQmIMgB2AQAAAA==.',
['珠八']='珠八戒:BAABLgAFFH8FAAIFAAUJ0BDnBACcAQAFAAUJ0BDnBACcAQAAAA==.',
['甩尾']='甩尾巴:BAABLgAECn8UAAITAAcJsxHcHACeAQATAAcJsxHcHACeAQAAAA==.',
['电气']='电气精灵:BAAALgAECgcJCQAAAA==.',
['疯狂']='疯狂的牛牛:BAAALgAECgEJAQAAAA==.疯狂的飞机丶:BAAALgAECgEJAQAAAA==.',
['白牧']='白牧云:BAAALgAECgYJBgAAAA==.',
['瞳溪']='瞳溪:BAAALgAECgEJAQAAAA==.',
['破釜']='破釜沉舟:BAABLgAFFH8KAAMIAAYJrhTUCwBFAQAIAAQJDA7UCwBFAQAYAAYJ5BAAAAAAAAAAAA==.',
['神戳']='神戳戳:BAAALgAECgcJBwAAAA==.',
['神聖']='神聖之舞:BAAALgAECgUJBQAAAA==.',
['神龙']='神龙大侠阿满:BAAALgAECgIJAgAAAA==.',
['空空']='空空:BAAALgAECgMJAwAAAA==.',
['笨犇']='笨犇犇:BAAALgAECgUJBQAAAA==.',
['等风']='等风起:BAAALgAECgMJAwAAAA==.',
['筱玖']='筱玖:BAAALgAECgEJAQAAAA==.',
['简单']='简单的疯子:BAAALgAECgEJAQAAAA==.',
['简然']='简然:BAAALgAECgUJBQAAAA==.',
['米唐']='米唐门:BAAALgADCgUJBQAAAA==.',
['粉团']='粉团子:BAAALgAECgcJCgAAAA==.',
['精神']='精神匮乏的人:BAAALgAECggJCQAAAA==.',
['紫彤']='紫彤:BAAALgAFFAEJAQAAAA==.',
['紫珠']='紫珠珠:BAAALgAECgIJAgAAAA==.',
['红旗']='红旗渠:BAAALgADCgYJBgAAAA==.',
['纵横']='纵横乄小德:BAAALgAECgQJBAAAAA==.纵横兀武僧:BAAALgAECgQJBwAAAA==.',
['练家']='练家子:BAAALgAECgcJEQAAAA==.',
['绝世']='绝世牛妖:BAAALgAECgYJBwAAAA==.',
['继国']='继国缘壹:BAAALgAECgYJCwAAAA==.',
['肾亏']='肾亏修女:BAAALgADCgYJBgAAAA==.',
['肾骑']='肾骑士:BAAALgAECgUJBQAAAA==.',
['胡豆']='胡豆夺牙签:BAAALgAECgEJAQAAAA==.',
['腊月']='腊月初柒:BAAALgAECgQJBAAAAA==.',
['芝麻']='芝麻狐丶:BAAALgAECgEJAQAAAA==.',
['萌物']='萌物:BAAALgAECgIJAgAAAA==.',
['萨满']='萨满宙斯:BAAALgAECgEJAQAAAA==.',
['蓝火']='蓝火哈士奇:BAAALgADCgQJBAAAAA==.',
['蔷薇']='蔷薇绅士:BAAALgAECgUJBAAAAA==.',
['虚假']='虚假的圣洁:BAAALgADCgkJCQAAAA==.',
['血云']='血云游:BAAALgAECgMJAwAAAA==.',
['被卡']='被卡在黑洞中:BAAALgAECgIJAwAAAA==.',
['訩兆']='訩兆丶:BAAALgAECgEJAQAAAA==.',
['让我']='让我电一下:BAAALgAECgIJAgAAAA==.',
['诶哎']='诶哎骑士:BAAALgADCgEJAQAAAA==.',
['贫道']='贫道劫个色:BAAALgAECgUJCgAAAA==.',
['贼哈']='贼哈哈嗝嗝:BAAALgAECgYJDAAAAA==.',
['践踏']='践踏战争:BAAALgAECgYJCwAAAA==.',
['辛夷']='辛夷吖:BAAALgAECgEJAQAAAA==.辛夷大王:BAACLgAFFH8HAAISAAMJ5Q7kIgD4AAASAAMJ5Q7kIgD4AAAuAAQKfyoAAhIACAl3GeYsAFoCABIACAl3GeYsAFoCAAAA.',
['辰宝']='辰宝宝灬:BAAALgAECgQJBAAAAA==.',
['迷你']='迷你烤鸡翅:BAAALgAFFAEJAQAAAA==.',
['迷茫']='迷茫中的现实:BAAALgAECgYJCQAAAA==.',
['邪恶']='邪恶的渣爷:BAAALgAECgEJAQAAAA==.',
['邪能']='邪能汉堡:BAACLgAFFH8XAAIZAAYJhR2eAQBYAgAZAAYJhR2eAQBYAgAuAAQKfx8AAxkACQl1IKsjAHwCABkACQmEHasjAHwCAAcABgmHH/4kAJYBAAAA.',
['酒酒']='酒酒:BAAALgAECgYJBwAAAA==.',
['醉月']='醉月丶觞:BAABLgAFFH8HAAINAAMJYB/VOAC4AAANAAMJYB/VOAC4AAAAAA==.',
['醉舞']='醉舞滇西:BAAALgAECgEJAgAAAA==.',
['里尔']='里尔:BAAALgADCgYJBgAAAA==.',
['铁人']='铁人老五:BAAALgAECgEJAQAAAA==.',
['铺路']='铺路的:BAAALgAFFAEJAQAAAA==.',
['阝灬']='阝灬丶逍尧:BAAALgAECgQJBgAAAA==.',
['阿纳']='阿纳克洛斯:BAAALgAECgcJEQAAAA==.',
['陈平']='陈平安:BAAALgAFFAIJAgAAAA==.',
['隐秘']='隐秘通途:BAAALgAFFAEJAQAAAA==.',
['雨辰']='雨辰再临:BAAALgAECgcJDQAAAA==.',
['雪崩']='雪崩:BAAALgADCgYJBgAAAA==.',
['雷霆']='雷霆强袭:BAAALgAECgQJBAAAAA==.',
['霜火']='霜火圣光:BAAALgAFFAEJAQABLgAFFAIJAgAKAAAAAA==.',
['霸气']='霸气的年糕:BAAALgAECgcJBwAAAA==.',
['面條']='面條:BAAALgADCgUJBQAAAA==.',
['鞭鞭']='鞭鞭:BAAALgAECgYJDQAAAA==.',
['频烦']='频烦之鹿:BAAALgADCgMJAwAAAA==.',
['风之']='风之夜语:BAAALgADCgEJAgAAAA==.',
['风情']='风情微解:BAAALgAECgUJCAAAAA==.',
['风潇']='风潇潇兮:BAAALgAFFAEJAQAAAA==.',
['风言']='风言风语:BAAALgAECgEJAQAAAA==.',
['风迹']='风迹月影彡:BAAALgAECgYJBgAAAA==.',
['鱼心']='鱼心丸子:BAAALgAFFAIJAgAAAA==.',
['鸿孺']='鸿孺:BAAALgADCgYJBgAAAA==.',
['麻油']='麻油恶丶:BAAALgAECgYJDAAAAA==.',
['黎明']='黎明的光晕:BAABLgAECn8WAAMQAAcJrRIIMwCfAQAQAAcJrRIIMwCfAQAPAAEJEwnFRQA7AAAAAA==.',
['齐德']='齐德龙东锵:BAAALgADCgUJBQAAAA==.',
['龍少']='龍少爷:BAAALgAFFAEJAgAAAA==.',
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
