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

local lookup = {'Shaman-Elemental','DeathKnight-Unholy','Paladin-Retribution','Priest-Shadow','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','Warrior-Protection','Mage-Frost','Shaman-Restoration','Druid-Restoration','Hunter-BeastMastery','DemonHunter-Devourer','Warlock-Demonology','Evoker-Preservation','Monk-Mistweaver','Warrior-Arms','Warrior-Fury','Warlock-Destruction','Paladin-Holy',}
local provider = {region='CN',realm='激流之傲',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Araneth:BAAALgAECgYJBgAAAA==.Arborin:BAAALgAECgMJAwAAAA==.',
Ca='Caesarr:BAAALgAECgYJBgAAAA==.',
Co='Coo:BAAALgAECgEJAgAAAA==.',
Fu='Fuita:BAAALgAECgEJAgAAAA==.Fuze:BAAALgADCgYJBgAAAA==.',
He='Hesha:BAAALgADCgYJBgAAAA==.',
Ic='Iceyu:BAAALgAECgYJBgAAAA==.',
Ko='Komorebi:BAAALgAECgEJAQAAAA==.',
Lu='Lukc:BAABLgAFFH8HAAIBAAMJKSOICgA8AQABAAMJKSOICgA8AQAAAA==.',
Ly='Lypj:BAAALgADCgYJBgAAAA==.',
Ma='Magician:BAAALgADCgUJBQAAAA==.Maste:BAABLgAFFH8FAAICAAMJQRH5LwDSAAACAAMJQRH5LwDSAAAAAA==.',
Re='Rehenter:BAAALgAECgYJDAAAAA==.',
Sk='Skymimi:BAAALgAECgUJBQAAAA==.',
Sn='Snowmonster:BAAALgAECgIJAQAAAA==.',
St='Starboy:BAAALgAECgMJAwAAAA==.',
Su='Sunshine:BAAALgAECgQJBAAAAA==.',
Te='Tendernessh:BAAALgAECgYJBgAAAA==.',
Va='Valentine:BAAALgAECgYJBgAAAA==.',
Ve='Vengeancebri:BAAALgAECgQJBAAAAA==.',
Xc='Xcao:BAAALgAECgcJBAAAAA==.',
Yz='Yzhnqs:BAABLgAFFH8FAAIDAAUJYwk2BQA/AQADAAUJYwk2BQA/AQAAAA==.',
Za='Zard:BAAALgADCgMJAwAAAA==.',
['一叶']='一叶知秋:BAAALgAECgcJBwAAAA==.',
['一念']='一念神魔:BAAALgAECgYJBgAAAA==.',
['一贱']='一贱成名:BAAALgAECgEJAQAAAA==.',
['七条']='七条天空:BAAALgAECgkJAQAAAA==.',
['上帝']='上帝的救赎:BAAALgAFFAEJAQAAAA==.',
['不会']='不会动:BAAALgADCgYJBgAAAA==.',
['丑得']='丑得要死:BAABLgAECn8VAAICAAgJnxsJNQBiAgACAAgJnxsJNQBiAgAAAA==.',
['丛林']='丛林小奶瓶:BAAALgAECgcJBwAAAA==.',
['中年']='中年油腻大叔:BAAALgAECgYJBwAAAA==.',
['丶阿']='丶阿丽塔:BAAALgAECgEJAQAAAA==.',
['乌蝇']='乌蝇哥:BAAALgAECgEJAgAAAA==.',
['云南']='云南老表:BAAALgAECgIJAgAAAA==.',
['伐竹']='伐竹取道:BAAALgAECggJEQAAAA==.',
['低位']='低位单打:BAAALgAECgYJCAAAAA==.',
['便便']='便便三号机:BAAALgAECgQJBQAAAA==.便便超人丶:BAAALgAECgYJBwAAAA==.',
['修罗']='修罗尊:BAAALgAECgEJAQAAAA==.',
['倔强']='倔强的阿昆达:BAAALgAECgUJBgAAAA==.',
['倾桑']='倾桑逝琴:BAAALgAECgcJEgAAAA==.',
['傻馒']='傻馒:BAAALgAECgIJAgAAAA==.',
['光影']='光影不離:BAABLgAECn8WAAQEAAkJgRwjBwAYAwAEAAkJgRwjBwAYAwAFAAcJFR8QDQBoAgAGAAYJpw+hQAA3AQABLgAFFAUJBQAHAP4TAA==.',
['兜里']='兜里没糖:BAAALgAECgcJCwAAAA==.',
['八丶']='八丶月的叶:BAAALgAECgQJBAAAAA==.',
['六扇']='六扇门牛牛:BAAALgAECgYJBgAAAA==.',
['关云']='关云:BAAALgADCgEJAQAAAA==.',
['其实']='其实很想你:BAAALgAECgMJAwAAAA==.',
['农药']='农药喂了不落:BAAALgAECgkJDwAAAA==.',
['冰轩']='冰轩爻魔幻:BAAALgAFFAIJAgABLgAECgkJIQAIACMgAA==.',
['冷飲']='冷飲:BAACLgAFFH8FAAIJAAIJjwR0SACeAAAJAAIJjwR0SACeAAAuAAQKfxoAAgkABgmPFmOhAJQBAAkABgmPFmOhAJQBAAAA.',
['出家']='出家失败:BAAALgAECgUJBQAAAA==.',
['初心']='初心:BAAALgAECgIJAgAAAA==.初心者:BAAALgAECgMJAwAAAA==.',
['初见']='初见:BAAALgAECgEJAQAAAA==.',
['劣灬']='劣灬丶人:BAAALgAECgEJAQAAAA==.',
['十一']='十一月的小德:BAAALgAECgEJAQAAAA==.十一月的萧邦:BAAALgAECgIJAgAAAA==.',
['十八']='十八寸太奶奶:BAAALgAECgYJBgAAAA==.',
['十胆']='十胆小鬼十:BAABLgAECn8ZAAMKAAkJXSKxAgBVAwAKAAkJXSKxAgBVAwABAAEJCA8+kQAmAAAAAA==.',
['千反']='千反田琉璃:BAAALgAECgYJBgAAAA==.',
['千幻']='千幻魅影:BAAALgAECgQJBAAAAA==.',
['南派']='南派大叔:BAAALgAECgMJBAAAAA==.',
['叫我']='叫我陈晓莫:BAAALgAECgYJEwAAAA==.',
['可可']='可可丷:BAABLgAFFH8HAAILAAMJMx8hDAAgAQALAAMJMx8hDAAgAQAAAA==.',
['司务']='司务长:BAAALgAECgYJBgAAAA==.',
['吃完']='吃完饭找你玩:BAAALgADCgQJBAAAAA==.',
['吃瓜']='吃瓜的胖猫:BAABLgAECn8UAAIMAAcJuBMPEQB2AQAMAAcJuBMPEQB2AQAAAA==.',
['后仰']='后仰跳投:BAAALgAECgUJBQAAAA==.',
['吥要']='吥要吥要:BAAALgAECgUJBQAAAA==.',
['和花']='和花:BAAALgAECgcJEgAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgAFFAEJAwAAAA==.',
['哇哒']='哇哒:BAAALgAECgIJAwAAAA==.',
['土耳']='土耳其冰淇淋:BAAALgAECgcJBgAAAA==.',
['圣光']='圣光:BAAALgADCgcJCgAAAA==.圣光护佑果冻:BAAALgADCgEJAQAAAA==.圣光照哞哞:BAAALgAECgcJDQAAAA==.圣光甜甜圈:BAAALgAECgcJBwAAAA==.',
['圣耀']='圣耀星辉:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱狂猪佩奇:BAAALgADCgIJAgAAAA==.',
['地精']='地精铭文珠宝:BAAALgADCgIJAgAAAA==.',
['墙角']='墙角的小萌瓜:BAAALgAECgEJAQAAAA==.',
['墨化']='墨化枯叶:BAAALgAECgcJBwAAAA==.',
['壹支']='壹支毒秀:BAAALgADCgYJBgAAAA==.',
['夏凉']='夏凉橙:BAAALgAECgcJEAAAAA==.',
['多乐']='多乐是只猫:BAAALgAFFAIJAgAAAA==.',
['大理']='大理老表:BAAALgADCgIJAgAAAA==.',
['大锤']='大锤来了:BAAALgAECgUJBwAAAA==.',
['天灾']='天灾加里奥:BAAALgAECgcJCAAAAA==.',
['天舞']='天舞寶輪:BAAALgADCgcJDAAAAA==.',
['奶少']='奶少:BAAALgAECggJBwAAAA==.',
['小丶']='小丶姐姐:BAAALgAECgkJCQAAAA==.',
['小周']='小周不急:BAAALgAECgUJBQAAAA==.小周爱玩神牧:BAABLgAFFH8FAAIFAAMJhwVbBwDJAAAFAAMJhwVbBwDJAAAAAA==.',
['小恶']='小恶魔丶:BAAALgAECgYJCwAAAA==.',
['小楼']='小楼又南风丶:BAAALgADCgEJAQAAAA==.',
['小烦']='小烦烦:BAAALgAECgEJAgAAAA==.',
['小煤']='小煤球快跑:BAAALgAECgkJCAABLgAFFAQJCAANANgIAA==.',
['小熊']='小熊软糖:BAAALgAECgEJAQAAAA==.',
['小舟']='小舟潮:BAABLgAFFH8FAAIOAAQJhhSbEQBXAQAOAAQJhhSbEQBXAQAAAA==.',
['小芙']='小芙遥:BAABLgAFFH8FAAIFAAIJ5hEuEwCcAAAFAAIJ5hEuEwCcAAABLgAFFAUJBQAPAIkdAA==.',
['小鬼']='小鬼很忙:BAAALgAECgkJEgAAAA==.',
['尐圣']='尐圣:BAAALgAECgMJAwAAAA==.',
['尛笨']='尛笨孩:BAAALgAECgYJBgAAAA==.',
['屠戮']='屠戮者小周:BAAALgAECgQJBAAAAA==.',
['崽丶']='崽丶僧:BAAALgADCgIJAgAAAA==.崽丶骑:BAAALgAECgcJDAAAAA==.',
['崽灬']='崽灬萨:BAAALgAECgQJBQAAAA==.',
['巫小']='巫小乖:BAAALgADCgYJCwAAAA==.',
['幸运']='幸运饼:BAAALgAFFAIJAwAAAA==.',
['弗洛']='弗洛洛:BAAALgAECgYJDAAAAA==.',
['弯弓']='弯弓似月牙:BAAALgAECgQJBQAAAA==.',
['微笑']='微笑丶蒂妮莎:BAAALgAECgcJBwAAAA==.',
['德不']='德不配喂:BAAALgAECgMJBAABLgAECgYJFAAGAM0SAA==.',
['怀中']='怀中抱妹杀丶:BAAALgAECgUJDwABLgAECgYJFAAGAM0SAA==.',
['悠悠']='悠悠邪神:BAAALgAECgYJBgAAAA==.悠悠酋长:BAAALgAECgYJBgAAAA==.',
['情之']='情之亦心往:BAAALgAECggJCgAAAA==.',
['惧锋']='惧锋:BAAALgADCgEJAQAAAA==.',
['愤怒']='愤怒的小鸟:BAAALgAECgYJDQAAAA==.',
['慕紜']='慕紜丶:BAAALgAECgQJAgAAAA==.',
['慢摇']='慢摇:BAAALgAECgQJBQAAAA==.',
['懒懒']='懒懒熊猫丶:BAAALgAECgEJAgAAAA==.',
['我不']='我不是嗗頭:BAAALgADCgEJAQAAAA==.',
['我将']='我将拄拐冲锋:BAAALgADCgYJBgAAAA==.',
['所得']='所得皆所愿:BAAALgAFFAMJAwAAAA==.',
['手冲']='手冲熊豪:BAAALgADCgMJBAAAAA==.',
['批威']='批威批:BAAALgAECgYJBgAAAA==.',
['把酒']='把酒戏红尘:BAAALgADCgIJAgAAAA==.',
['掳管']='掳管熊吼:BAAALgAECgEJAQAAAA==.',
['斗魂']='斗魂:BAAALgAECgUJCAAAAA==.',
['断翅']='断翅天使:BAABLgAECn8VAAIJAAYJhBOFsgB5AQAJAAYJhBOFsgB5AQAAAA==.',
['斯特']='斯特兰奇空间:BAAALgAECgcJBwAAAA==.',
['新爱']='新爱派德:BAAALgAECgEJAgAAAA==.',
['日光']='日光美少女:BAAALgADCgUJBQAAAA==.',
['早餐']='早餐店劫匪:BAAALgAECgEJAQAAAA==.',
['星爷']='星爷爷:BAAALgAFFAEJAQAAAA==.',
['是我']='是我惹不起:BAACLgAFFH8OAAIQAAQJqQrGBQDvAAAQAAQJqQrGBQDvAAAuAAQKfxQAAhAABwkbHLoYAPkBABAABwkbHLoYAPkBAAAA.',
['暗月']='暗月星魂:BAAALgADCggJCAAAAA==.暗月血影:BAAALgAECgQJBAAAAA==.',
['暗香']='暗香残留:BAAALgAECgQJAQAAAA==.',
['暗黑']='暗黑丹丹:BAAALgADCgIJAgAAAA==.',
['月下']='月下夜想:BAAALgAECgYJDQAAAA==.',
['月光']='月光倾城:BAAALgAFFAEJAQAAAA==.',
['月寒']='月寒日暖丶:BAABLgAECn8UAAQGAAYJzRIjOABbAQAGAAYJShAjOABbAQAFAAUJNQ7DMgAMAQAEAAMJAwqmTwCSAAAAAA==.',
['月牙']='月牙:BAAALgAECgEJAQAAAA==.',
['未来']='未来可期:BAAALgADCgIJAgAAAA==.',
['机智']='机智的大菜刀:BAAALgAECgkJCQAAAA==.',
['杀戮']='杀戮弹指间:BAAALgAECgIJAgAAAA==.',
['杀破']='杀破熊哥:BAAALgADCgEJAQAAAA==.',
['李二']='李二狗他老汉:BAAALgAECgQJBQAAAA==.',
['李狗']='李狗蛋超级凶:BAACLgAFFH8IAAICAAQJlh0vCACPAQACAAQJlh0vCACPAQAuAAQKfxkAAgIACAlkIEIbANoCAAIACAlkIEIbANoCAAAA.',
['李白']='李白:BAAALgAFFAEJAQAAAA==.',
['杨仔']='杨仔灬小德:BAAALgAECgEJAQAAAA==.',
['杨哒']='杨哒哒:BAAALgAECgYJBwAAAA==.',
['杨小']='杨小婲:BAAALgAFFAIJAgAAAA==.',
['板烧']='板烧鸡腿堡:BAAALgAECgEJAQAAAA==.',
['柠檬']='柠檬紫紫:BAAALgAECgcJBwAAAA==.',
['梅代']='梅代刀:BAAALgAECgEJAgAAAA==.',
['死亡']='死亡如风:BAAALgAECgEJAQAAAA==.',
['毁灭']='毁灭吧麻了:BAAALgAECgYJCwAAAA==.',
['母草']='母草:BAAALgAECgcJBwAAAA==.',
['永恒']='永恒之钕:BAAALgAECgYJBgAAAA==.永恒之锿:BAAALgAECgYJDAAAAA==.',
['江南']='江南第一深情:BAAALgAECgEJAQAAAA==.',
['沃德']='沃德:BAAALgAECgEJAQAAAA==.',
['沉槿']='沉槿:BAAALgADCgYJBgAAAA==.',
['流萨']='流萨:BAAALgADCgQJBAAAAA==.',
['海鸟']='海鸟和鱼:BAAALgAECgEJAQABLgAECggJFwAEAMgfAA==.',
['淘气']='淘气仙星:BAABLgAECn8XAAIEAAgJyB+YBwANAwAEAAgJyB+YBwANAwAAAA==.',
['淡蓝']='淡蓝色的爱:BAAALgAECgMJAwAAAA==.',
['清歌']='清歌扶酒:BAAALgAECgEJAwAAAA==.',
['渴望']='渴望抗怪:BAAALgAFFAIJBAAAAA==.',
['熊刹']='熊刹刹:BAAALgADCgMJAwAAAA==.',
['熊猫']='熊猫曦曦:BAAALgAECgYJCgAAAA==.',
['熊里']='熊里安乌瑞恩:BAABLgAECn8aAAMRAAgJwSB6AgD8AgARAAgJwSB6AgD8AgASAAQJ7B0yZAAhAQAAAA==.',
['熵之']='熵之逆旅:BAAALgAECgMJBAAAAA==.',
['爱吃']='爱吃鱼:BAAALgAECgcJBwAAAA==.',
['版本']='版本之子:BAAALgAECgYJDQAAAA==.',
['牙齿']='牙齿也迷人:BAAALgAECgEJAQAAAA==.',
['牛怪']='牛怪:BAAALgAFFAIJBAAAAA==.',
['牛牛']='牛牛不卖萌:BAAALgAECgIJAgAAAA==.',
['特洛']='特洛伊德:BAAALgAECgYJCAAAAA==.',
['特瑞']='特瑞克:BAAALgAFFAIJAgAAAA==.',
['狼爸']='狼爸爸:BAAALgAECgkJDwAAAA==.',
['猩红']='猩红王子:BAABLgAFFH8FAAIPAAUJiR1EAwDWAQAPAAUJiR1EAwDWAQAAAA==.',
['獠刹']='獠刹:BAAALgAFFAIJBAAAAA==.',
['玳瑁']='玳瑁丨猫爪草:BAABLgAECn8dAAMGAAgJlBV9GgAIAgAGAAgJqhJ9GgAIAgAFAAgJAQzpHgCdAQAAAA==.',
['瑶光']='瑶光:BAAALgAECgIJAgAAAA==.',
['生前']='生前是圣骑:BAAALgAFFAIJBAAAAA==.',
['留頭']='留頭人法師:BAAALgAFFAIJAgAAAA==.',
['疾风']='疾风亦有归途:BAAALgAECgQJBQAAAA==.',
['看星']='看星星的牛:BAAALgADCgQJBAAAAA==.',
['真武']='真武降魔:BAAALgAECgYJBwAAAA==.',
['砚寒']='砚寒清:BAAALgAECgEJAQAAAA==.',
['祝贺']='祝贺:BAAALgADCgMJAwAAAA==.',
['神奇']='神奇的李狗蛋:BAAALgADCgEJAQAAAA==.',
['祥子']='祥子:BAAALgAECgMJAwAAAA==.',
['空山']='空山未雨:BAAALgAECgkJCQAAAA==.',
['空空']='空空熊:BAAALgAECgIJAgAAAA==.',
['空见']='空见大师:BAABLgAECn8UAAIQAAgJxguBDQALAQAQAAgJxguBDQALAQAAAA==.',
['窝腰']='窝腰烟牌:BAACLgAFFH8MAAMOAAQJkCHnFQA/AQAOAAMJZyLnFQA/AQATAAEJCR/NEABfAAAuAAQKfx4AAw4ACAl+JF0XAMgCAA4ABwl+JF0XAMgCABMAAQkAAH9iAEkAAAAA.',
['第叄']='第叄稳限:BAAALgAECgYJBgAAAA==.',
['筒仔']='筒仔米糕:BAAALgAECgYJDQAAAA==.',
['粗又']='粗又硬丶戰弔:BAAALgAECgMJAwAAAA==.',
['红手']='红手:BAABLgAFFH8FAAIUAAMJNCLEEQDAAAAUAAMJNCLEEQDAAAAAAA==.',
['红烧']='红烧牛魔丸:BAAALgAECgUJCgAAAA==.',
['纯情']='纯情嫪毐:BAAALgAECgYJCgAAAA==.',
['练霓']='练霓裳:BAAALgAECgQJBgAAAA==.',
['维多']='维多利亚:BAAALgAECgcJBwAAAA==.',
['羊宫']='羊宫妃那:BAAALgAECgEJAQAAAA==.',
['老痰']='老痰喷射专员:BAAALgAFFAIJAgAAAA==.',
['聖光']='聖光曉刹:BAAALgAECgQJBAAAAA==.',
['胸奴']='胸奴李狗蛋:BAAALgAFFAIJAgAAAA==.',
['艾尔']='艾尔德里奇:BAAALgAECgEJAQAAAA==.',
['艾梅']='艾梅达尔:BAAALgAFFAIJAgAAAA==.',
['艾雅']='艾雅白掌:BAAALgADCgIJAgAAAA==.',
['芷菀']='芷菀:BAAALgAECgUJBgAAAA==.',
['苍岚']='苍岚星:BAAALgAECgIJAgAAAA==.',
['苍澜']='苍澜星:BAAALgAECgcJBwAAAA==.',
['莉亞']='莉亞德林:BAAALgAECgIJAgAAAA==.',
['莉莉']='莉莉娅娜:BAAALgAECgEJAgAAAA==.',
['菘蓝']='菘蓝丨猫爪草:BAAALgADCgUJBQAAAA==.',
['萧语']='萧语:BAAALgADCgUJCQAAAA==.',
['萨里']='萨里奥诺维奇:BAAALgAECgYJDgAAAA==.',
['葵花']='葵花点泬掱:BAAALgADCgUJBQAAAA==.',
['薛定']='薛定谔的雾:BAAALgADCgEJAQABLgAECgYJFAAGAM0SAA==.',
['蛋疼']='蛋疼大师:BAAALgAECgkJDAAAAA==.',
['蝴蝶']='蝴蝶吻花香:BAABLgAECn8bAAMFAAgJTBA6HQCqAQAFAAgJ8As6HQCqAQAGAAYJ6RMJNQBqAQAAAA==.',
['裂肠']='裂肠熊一:BAAALgAECgMJBQAAAA==.',
['谭鱼']='谭鱼头:BAAALgADCgUJBQAAAA==.',
['超超']='超超级:BAAALgAECgEJAQAAAA==.',
['软云']='软云:BAAALgAFFAIJAgAAAA==.',
['这是']='这是自寻死路:BAAALgADCgcJDAAAAA==.',
['远古']='远古的尧:BAAALgAECgQJBAAAAA==.',
['邪恶']='邪恶灬力量:BAABLgAECn8UAAINAAgJSxmWKgBWAgANAAgJSxmWKgBWAgAAAA==.',
['都是']='都是我的翅膀:BAAALgAECgEJAQABLgAECgYJFAAGAM0SAA==.',
['酣畅']='酣畅淋漓:BAAALgAECgYJBwAAAA==.',
['重庆']='重庆肥牛王:BAAALgADCgIJAgAAAA==.重庆野蛮牛:BAAALgADCgIJAgAAAA==.',
['重甲']='重甲持斧:BAAALgAECgcJCAAAAA==.',
['鈅魅']='鈅魅灬儛姬:BAAALgAECgUJBQAAAA==.',
['针尖']='针尖对麦芒:BAAALgAECgcJDQAAAA==.',
['锅里']='锅里的奥特馒:BAAALgAFFAIJAwAAAA==.',
['问剑']='问剑:BAAALgAECgYJBAAAAA==.',
['阳叶']='阳叶:BAAALgADCgIJAgAAAA==.',
['阿克']='阿克猛德:BAAALgADCgYJBgAAAA==.',
['阿姆']='阿姆斯特朗炮:BAAALgAECgUJBQAAAA==.',
['阿滚']='阿滚:BAAALgAECgcJBQABLgAFFAUJBQAPAIkdAA==.',
['阿蕾']='阿蕾克斯塔萨:BAAALgAECgEJAQAAAA==.',
['霸道']='霸道折耳根:BAACLgAFFH8FAAINAAIJSQcYLQCSAAANAAIJSQcYLQCSAAAuAAQKfxYAAwcACAlyF0sUAC8CAAcACAlyF0sUAC8CAA0ABgkBCnaEAB8BAAAA.',
['青春']='青春你太痘:BAAALgAECgcJEgAAAA==.',
['题里']='题里奥佛丁:BAAALgAECgcJBwAAAA==.',
['马尔']='马尔萨斯:BAAALgAECgYJEgAAAA==.',
['骑老']='骑老奶过马路:BAAALgAFFAIJBAAAAA==.',
['高松']='高松灯:BAAALgAECgQJBAAAAA==.',
['鬼小']='鬼小棋:BAAALgADCgUJBQAAAA==.鬼小灯笼:BAAALgADCgQJBAAAAA==.',
['鬼尐']='鬼尐圣:BAAALgADCgYJBgAAAA==.',
['鱼油']='鱼油进口商:BAAALgAECgcJEAAAAA==.',
['黄花']='黄花风铃木:BAAALgADCgcJBwAAAA==.',
['龙伽']='龙伽尔:BAABLgAFFH8HAAICAAQJ0RqpEABeAQACAAQJ0RqpEABeAQAAAA==.',
['龙枷']='龙枷尔:BAAALgAFFAIJAgAAAA==.',
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
