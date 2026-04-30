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

local lookup = {'Paladin-Retribution','Unknown-Unknown','Warrior-Fury','Rogue-Subtlety','Priest-Shadow','Monk-Brewmaster','Priest-Holy','Priest-Discipline','Druid-Balance','DemonHunter-Havoc','DeathKnight-Unholy','Hunter-Marksmanship','DeathKnight-Blood','Druid-Restoration','Druid-Guardian','Shaman-Elemental','Evoker-Ranged','Evoker-Augmentation','Evoker-Devastation','Warrior-Protection','Hunter-Survival','DemonHunter-Vengeance','Mage-Frost','Warlock-Demonology','Hunter-BeastMastery','Paladin-Holy','DeathKnight-Frost',}
local provider = {region='CN',realm='洛丹伦',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aespa:BAAALgAECgYJBwAAAA==.',
Ak='Akiyamamio:BAABLgAECn8UAAIBAAcJQxOrZAC4AQABAAcJQxOrZAC4AQAAAA==.',
Am='Amebest:BAAALgAECgYJCwAAAA==.',
Ar='Araki:BAAALgAECgIJAgABLgAECgcJDQACAAAAAA==.Armos:BAAALgADCgEJAQAAAA==.',
Au='Aurora:BAAALgAECgUJBQAAAA==.',
Bl='Blaze:BAABLgAFFH8FAAIDAAUJgBheHwBXAAADAAUJgBheHwBXAAAAAA==.Bloodborne:BAAALgAECgYJAQAAAA==.Bloodorange:BAAALgAECgkJBQAAAA==.',
Ca='Cataclysm:BAAALgAECgEJAQAAAA==.',
Da='Darkalliance:BAAALgADCgEJAQAAAA==.Darksamurai:BAAALgAECgYJCQAAAA==.',
Do='Dovelove:BAAALgAECgEJAQAAAA==.',
En='Enjoyblue:BAAALgADCgEJAQAAAA==.',
Fl='Flea:BAABLgAECn8YAAIEAAcJJxriAwDVAQAEAAcJJxriAwDVAQAAAA==.',
Fr='Fraser:BAAALgAECgYJCwAAAA==.',
Fu='Fu:BAAALgAECgQJBwAAAA==.',
Hd='Hdzibba:BAAALgAFFAEJAQAAAA==.',
Il='Ilaktg:BAAALgAECgYJDAAAAA==.',
Ju='Junjiito:BAAALgAECgcJDQAAAA==.',
Ke='Kexo:BAAALgAECgEJAQAAAA==.',
Ki='Killura:BAAALgAFFAIJAgABLgAFFAUJDQAFAPQHAA==.',
Lo='Loktar:BAAALgAFFAQJBAAAAA==.Loveleftdk:BAAALgAECgMJAwAAAA==.',
Lu='Lumiki:BAAALgAECgcJCgAAAA==.Lunala:BAAALgAECgUJBQAAAA==.',
Ma='Mantra:BAAALgADCgEJAQABLgAECgIJAgACAAAAAA==.',
My='Myeyes:BAAALgAECgQJBQAAAA==.',
Ni='Nightmaree:BAAALgADCgkJCQAAAA==.Niu:BAAALgADCgUJBQAAAA==.',
Om='Ombrapugno:BAAALgAECgUJBgAAAA==.',
Or='Orfevre:BAAALgAECgkJCQAAAA==.',
Pa='Pandarenmonk:BAABLgAFFH8IAAIGAAMJrhWAFADTAAAGAAMJrhWAFADTAAAAAA==.',
Pi='Pinky:BAAALgAECgkJCQAAAA==.',
Ra='Rambodemon:BAAALgADCgEJAQAAAA==.',
Re='Remy:BAAALgADCgEJAQAAAA==.',
Ru='Rudeus:BAAALgAECgYJDAAAAA==.',
Sa='Sagepuppy:BAAALgAECgIJAgAAAA==.',
So='Soulcube:BAAALgAECgYJDgAAAA==.',
Ta='Tallhart:BAAALgAECgEJAQAAAA==.',
Te='Terminat:BAAALgAFFAIJAgAAAA==.',
Ti='Tirpitz:BAAALgADCgEJAQAAAA==.',
Va='Valkyrja:BAAALgAFFAEJAQAAAA==.',
Ve='Veronica:BAAALgAECgkJBgAAAA==.Veryoutman:BAAALgAECgEJAQAAAA==.',
Zh='Zhegelongr:BAAALgADCgkJCQAAAA==.',
['一九']='一九:BAABLgAECn8UAAIHAAcJSg8CCACEAQAHAAcJSg8CCACEAQAAAA==.',
['一头']='一头老牛丶:BAAALgAECgcJCwAAAA==.',
['一帘']='一帘幽夢:BAAALgAECgMJAwAAAA==.',
['一杆']='一杆枪叫射:BAAALgAECggJCAAAAA==.',
['一炮']='一炮到天亮:BAAALgAECgEJAQAAAA==.',
['一盘']='一盘大菜:BAAALgADCgEJAgAAAA==.',
['一粒']='一粒小蛋蛋:BAAALgAECgEJAQAAAA==.',
['七七']='七七陪:BAABLgAFFH8FAAIIAAUJ+xQbBACvAQAIAAUJ+xQbBACvAQAAAA==.',
['三城']='三城灬水:BAAALgADCgEJAQAAAA==.',
['三川']='三川:BAAALgADCgEJAQAAAA==.',
['上瘾']='上瘾丶:BAABLgAFFH8FAAIGAAIJYhDLHACKAAAGAAIJYhDLHACKAAAAAA==.',
['不学']='不学无束:BAAALgAECgQJBQAAAA==.',
['不给']='不给透就分手:BAAALgAECgYJCAAAAA==.',
['丘比']='丘比特之神萨:BAAALgAECgYJBgAAAA==.',
['丨暖']='丨暖阳丨:BAAALgADCgUJBQAAAA==.',
['丨破']='丨破晓丶:BAAALgAECgcJEwAAAA==.',
['丨连']='丨连理双树丨:BAABLgAFFH8HAAIJAAUJaBHGAgBRAQAJAAUJaBHGAgBRAQAAAA==.',
['丶伊']='丶伊瑞尔灬:BAAALgAECgEJAQAAAA==.',
['丶温']='丶温柏:BAAALgAECgMJBgAAAA==.',
['丶灰']='丶灰烬之怒:BAAALgAFFAIJAgAAAA==.',
['丶礻']='丶礻申:BAAALgAECgcJEQABLgAFFAQJCAAKAHMJAA==.',
['丶群']='丶群星陨落:BAAALgAECgEJAQAAAA==.',
['丶芒']='丶芒果:BAAALgAECgQJBAAAAA==.',
['丶莲']='丶莲雾:BAAALgAECgMJBAAAAA==.',
['丷赤']='丷赤日煌煌丷:BAAALgADCgUJBQAAAA==.',
['丿丶']='丿丶小丶猎:BAAALgAECgYJBwAAAA==.',
['么有']='么有鱼丸:BAAALgADCgMJAwAAAA==.',
['乌啦']='乌啦啦乌:BAAALgAECgYJBgAAAA==.',
['乌桃']='乌桃厚乳:BAAALgAECgYJBgAAAA==.',
['九不']='九不卑十不亢:BAAALgAFFAIJAgAAAA==.',
['乱世']='乱世书:BAAALgAECgEJAQABLgAECgEJAgACAAAAAA==.',
['五虎']='五虎断魂枪:BAAALgAECgEJAQAAAA==.',
['亡汝']='亡汝者:BAAALgAFFAEJAQAAAA==.',
['人恨']='人恨我有钱:BAAALgAECgYJBgAAAA==.',
['亿粒']='亿粒蛋:BAAALgAECgUJBQABLgAFFAMJCgALACchAA==.',
['今何']='今何在丶:BAAALgAECgYJBgAAAA==.',
['仙女']='仙女味的牛:BAAALgAECgEJAQAAAA==.',
['仙宫']='仙宫第一增强:BAAALgAFFAEJAQAAAA==.',
['伏魔']='伏魔御厨子丶:BAAALgAECgIJAgAAAA==.',
['你艾']='你艾希我乃妈:BAAALgAECgMJAwAAAA==.',
['侑侑']='侑侑莉:BAAALgAECgQJBAAAAA==.',
['倾城']='倾城之修:BAAALgADCgYJBgAAAA==.',
['偶尔']='偶尔玩一玩丶:BAAALgAECgkJCgAAAA==.',
['偸睲']='偸睲的寶赑熋:BAAALgAECgQJBAAAAA==.',
['元亨']='元亨利贞:BAAALgADCgMJBwAAAA==.',
['元素']='元素之翼:BAAALgADCgEJAQAAAA==.',
['兄弟']='兄弟丶讲道理:BAAALgAECgIJAwAAAA==.',
['兜兜']='兜兜的想念:BAAALgAECgIJAwAAAA==.',
['八个']='八个联盟又:BAAALgADCgYJBgAAAA==.',
['八云']='八云紫:BAAALgADCgEJAQABLgAFFAIJAgACAAAAAA==.',
['六不']='六不声七不响:BAAALgAFFAEJAQAAAA==.',
['册那']='册那队长:BAAALgADCgYJBgAAAA==.',
['再来']='再来一桶:BAAALgADCgUJBQAAAA==.再来亿桶:BAAALgAECgIJAgAAAA==.',
['冥魄']='冥魄之冰霜:BAAALgAFFAIJAwAAAA==.',
['冰八']='冰八凉:BAAALgAECgkJDwABLgAFFAYJEQAMANITAA==.',
['冰阔']='冰阔樂:BAAALgAECgcJCwAAAA==.',
['冷物']='冷物语:BAAALgAECgEJAQAAAA==.',
['凶兽']='凶兽咆哮:BAAALgADCgYJBgAAAA==.',
['出逃']='出逃帝姬:BAAALgAECgkJEAAAAA==.出逃王女:BAAALgAECgkJDwAAAA==.',
['别想']='别想抓我:BAAALgAECgEJAQAAAA==.',
['别打']='别打我了:BAAALgADCggJCAAAAA==.',
['加尔']='加尔摩:BAAALgADCgEJAQAAAA==.',
['劫财']='劫财不劫涩:BAAALgADCgEJAQAAAA==.',
['勢來']='勢來运转:BAAALgAECgMJAwAAAA==.',
['化骸']='化骸为洁:BAAALgAECgYJBgAAAA==.',
['北极']='北极贝贝:BAAALgAECgEJAQAAAA==.',
['十二']='十二钗:BAAALgADCgQJBAAAAA==.',
['十黎']='十黎九夏:BAAALgAECgYJBwAAAA==.',
['千隐']='千隐千寻:BAAALgAECgYJCAABLgAFFAMJBAACAAAAAA==.',
['午夜']='午夜日出:BAAALgAECgcJCAAAAA==.',
['半盏']='半盏轻风:BAAALgAFFAIJAgAAAA==.',
['南熊']='南熊北猫:BAAALgADCgYJAQAAAA==.',
['卡梅']='卡梅莉亚:BAAALgAECgIJAwAAAA==.',
['去半']='去半生:BAAALgADCgEJAQABLgAECgEJAgACAAAAAA==.',
['叔叔']='叔叔大坏蛋丶:BAAALgAECgQJBQAAAA==.',
['古天']='古天昊:BAAALgAECgYJCgAAAA==.',
['可爱']='可爱超膘:BAAALgAFFAIJBAAAAA==.',
['叶流']='叶流云:BAAALgADCgIJAgAAAA==.',
['吴丶']='吴丶风暴烈酒:BAAALgADCgUJBQAAAA==.',
['咒丶']='咒丶:BAAALgADCgYJBgAAAA==.',
['咔咔']='咔咔上来就砍:BAAALgADCgIJAgAAAA==.',
['咕咕']='咕咕狗:BAAALgADCgQJBAAAAA==.',
['哈基']='哈基波:BAAALgADCgIJAgAAAA==.',
['哈根']='哈根米苏:BAAALgAECgYJBgAAAA==.',
['嗝屁']='嗝屁了:BAABLgAECn8YAAMLAAgJnRZjGABQAQALAAcJ1RhjGABQAQANAAEJSgn/SAAmAAAAAA==.',
['嘿一']='嘿一啊嘿:BAAALgAECgcJBwAAAA==.',
['嘿牛']='嘿牛小氵德:BAAALgADCgYJBgAAAA==.',
['四知']='四知文:BAAALgAECgcJDAAAAA==.',
['圣光']='圣光之柱:BAAALgAECgMJBQAAAA==.圣光的信仰:BAAALgADCgYJBgAAAA==.',
['圣域']='圣域龙魂:BAAALgAECgEJAQAAAA==.',
['圣疗']='圣疗加不满:BAAALgAECgUJBAAAAA==.',
['地主']='地主家的宠物:BAAALgAECgQJCAAAAA==.地主家的小偷:BAAALgAECgUJBQAAAA==.',
['地煞']='地煞灬地酷星:BAAALgAECgIJAgAAAA==.',
['塔骑']='塔骑米:BAAALgAECgQJBgAAAA==.',
['壁上']='壁上观:BAAALgAECgEJAgAAAA==.',
['夜魔']='夜魔内瑟斯:BAAALgAECgYJCwAAAA==.',
['大剑']='大剑在手:BAAALgAECgUJDgABLgAECgYJBgACAAAAAA==.',
['大声']='大声一点好吗:BAABLgAFFH8JAAILAAMJCyP8HQAoAQALAAMJCyP8HQAoAQAAAA==.',
['大奉']='大奉打更人:BAAALgAECgEJAQAAAA==.',
['大琛']='大琛琛:BAAALgAECgIJAwAAAA==.',
['大软']='大软:BAAALgAECgQJBAAAAA==.',
['大院']='大院长:BAAALgAECgUJBQAAAA==.',
['大雄']='大雄金刚:BAAALgAFFAYJAwAAAA==.',
['大馍']='大馍王:BAAALgADCgIJAgAAAA==.',
['天冬']='天冬:BAABLgAECn8XAAMOAAcJnh1hHgBMAgAOAAcJnh1hHgBMAgAPAAQJUAD+MgApAAABLgAFFAEJAQACAAAAAA==.天冬糖糖:BAAALgAFFAMJBAAAAA==.',
['天崩']='天崩灬岚山碎:BAAALgAECgUJBQAAAA==.',
['天真']='天真丶小猎:BAAALgAFFAQJBAAAAA==.天真丶小骑:BAAALgAECgMJBAABLgAFFAQJBAACAAAAAA==.',
['天退']='天退星雷横:BAAALgAFFAIJAgAAAA==.',
['天降']='天降伟帝:BAAALgAECgEJAQAAAA==.天降伟男:BAAALgAECgEJAwABLgAFFAcJGQAQAJEdAA==.',
['太阳']='太阳裂片:BAAALgADCgEJAQAAAA==.',
['奇怪']='奇怪的土豆饼:BAAALgAECgEJAgAAAA==.',
['奶狗']='奶狗憨柴:BAAALgAECgIJAgAAAA==.',
['她抠']='她抠我肚脐眼:BAAALgAECgYJCgAAAA==.',
['好久']='好久:BAAALgAECgEJAQAAAA==.',
['好运']='好运:BAAALgADCgEJAQAAAA==.',
['妄想']='妄想天使:BAAALgAECgEJAgAAAA==.',
['妮妮']='妮妮在线拉面:BAAALgAECgUJBQAAAA==.',
['妳艾']='妳艾希我奶妈:BAAALgAECgIJAgABLgAECgUJCwACAAAAAA==.',
['娜丶']='娜丶一抹微笑:BAAALgAECgMJBAAAAA==.',
['安格']='安格斯厚牛:BAABLgAECn8WAAIPAAcJgxreCQD+AQAPAAcJgxreCQD+AQAAAA==.',
['射日']='射日神使:BAAALgADCgYJBgAAAA==.',
['小元']='小元素:BAAALgADCgEJAQAAAA==.',
['小垃']='小垃圾:BAAALgADCgEJAQAAAA==.',
['小小']='小小保安:BAAALgAECgQJCQAAAA==.小小只丶:BAAALgAECgcJDAAAAA==.小小罗:BAAALgAECgMJBQAAAA==.',
['小机']='小机粑粑:BAAALgAECgYJDAAAAA==.',
['小汉']='小汉子丶:BAAALgAECgYJBgAAAA==.',
['小牧']='小牧夜光:BAAALgAECgYJCwAAAA==.',
['小猪']='小猪八戒:BAAALgAFFAEJAQAAAA==.',
['小羊']='小羊娜娜子:BAABLgAECn8fAAILAAgJ1CKLEAAZAwALAAgJ1CKLEAAZAwAAAA==.',
['小象']='小象努努:BAAALgAECgkJCQAAAA==.',
['小贼']='小贼:BAAALgAFFAEJAwAAAA==.',
['小鹿']='小鹿溜溜:BAAALgAECgEJAQAAAA==.',
['小龙']='小龙女丶:BAAALgAECgUJCwAAAA==.',
['尘丨']='尘丨湿昧:BAAALgAECgQJBwAAAA==.',
['就不']='就不奶鹏鹏:BAAALgAECgEJAQAAAA==.',
['就是']='就是不吊你:BAAALgAECgYJDQAAAA==.',
['岂曰']='岂曰无衣:BAAALgAECgYJBgAAAA==.',
['巧克']='巧克力奶片:BAAALgADCgEJAQAAAA==.',
['布偶']='布偶桃:BAAALgAECgYJCwAAAA==.',
['帅了']='帅了搞擦边:BAAALgAFFAIJAgAAAA==.',
['希尔']='希尔娃纳丝:BAAALgAECgIJBAAAAA==.',
['帝猎']='帝猎天崩:BAAALgAECgkJCQAAAA==.',
['幻丨']='幻丨缥缈:BAAALgAECgcJDwAAAA==.',
['庅應']='庅應明:BAAALgAECgEJAQAAAA==.',
['开怪']='开怪了:BAAALgAECgYJDAAAAA==.',
['弱鸡']='弱鸡战:BAAALgAECgQJBwAAAA==.',
['当时']='当时是寻常:BAAALgAECgIJAgAAAA==.',
['徐州']='徐州牧:BAAALgAECgEJAQAAAA==.',
['得鲁']='得鲁伊:BAAALgAECgQJBQAAAA==.',
['德善']='德善骐顺:BAAALgAECgIJAwAAAA==.',
['忧郁']='忧郁山东人:BAAALgADCgUJBQAAAA==.',
['急急']='急急如律令:BAAALgAECgkJDQAAAA==.',
['悲秋']='悲秋:BAAALgADCgEJAQAAAA==.',
['意随']='意随风起:BAAALgAECgUJBQAAAA==.',
['愛迪']='愛迪生:BAAALgAFFAMJAwAAAA==.',
['慕忱']='慕忱:BAAALgAECgMJAwAAAA==.',
['我也']='我也是龙啊:BAAALgAECgEJAQAAAA==.',
['我会']='我会灭光:BAAALgAECgYJCQAAAA==.',
['我叫']='我叫信仰战:BAAALgAECgEJAQAAAA==.',
['我就']='我就是亡法:BAAALgAECgcJBwAAAA==.',
['我恨']='我恨有钱人:BAAALgAECgEJAQAAAA==.',
['戒丶']='戒丶梦:BAAALgAECgEJAQAAAA==.',
['扛滴']='扛滴龙:BAABLgAFFH8FAAMRAAUJMwQAAAAAAAASAAQJMwQAAAAAAAATAAEJAAAAAAAAAAABLgAFFAcJEAASAHgaAA==.',
['抗渗']='抗渗混凝土:BAAALgAECgIJAgAAAA==.',
['折夜']='折夜冰凉:BAAALgAFFAIJAgAAAA==.折夜夕阳:BAAALgAECgYJAwAAAA==.',
['拆尼']='拆尼斯丶功夫:BAAALgAECgYJBgAAAA==.',
['拯救']='拯救丝足少萝:BAAALgAECgUJAgAAAA==.',
['持箭']='持箭闯天涯:BAAALgAECgcJEQAAAA==.',
['搞忘']='搞忘记了:BAAALgAFFAIJBAAAAA==.',
['摩莉']='摩莉安丶晶眼:BAAALgAECgQJBAAAAA==.',
['故棠']='故棠照雪来:BAAALgAECgUJBQAAAA==.',
['断剑']='断剑重铸:BAAALgAECgkJCQAAAA==.',
['无情']='无情好残忍:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌红猫爪:BAAALgAECgMJAwAAAA==.',
['早安']='早安晨的奶龙:BAAALgAFFAEJAQAAAA==.',
['春藤']='春藤之角:BAAALgAFFAEJAQAAAA==.',
['普利']='普利斯特:BAABLgAECn8dAAIBAAcJtB37LQBrAgABAAcJtB37LQBrAgAAAA==.',
['景和']='景和猫猫:BAAALgAECgMJAwAAAA==.',
['暗影']='暗影流咣:BAAALgADCgIJAgAAAA==.',
['暴走']='暴走丨初号机:BAABLgAFFH8IAAIUAAQJAwjFBwDhAAAUAAQJAwjFBwDhAAAAAA==.暴走丨初號機:BAAALgAFFAQJBAAAAA==.暴走丶初号机:BAAALgAFFAQJBAAAAA==.暴走丶初號機:BAABLgAFFH8JAAIUAAUJagqjCQC1AAAUAAUJagqjCQC1AAAAAA==.暴走初号机:BAAALgAFFAQJBAAAAA==.暴走初號機:BAAALgAFFAQJBAAAAA==.暴走灬初號機:BAAALgAFFAQJBAAAAA==.',
['暴风']='暴风的崛起:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经的淡然:BAAALgADCgEJAQAAAA==.',
['最后']='最后的单纯:BAAALgAECgcJDgAAAA==.',
['月影']='月影幽兰:BAAALgAFFAUJAgAAAA==.',
['月殁']='月殁:BAAALgAECgIJBAAAAA==.',
['有一']='有一点点调皮:BAAALgAECgYJBgAAAA==.',
['有德']='有德有詩:BAABLgAECn8cAAMJAAkJFRv0GQA2AgAJAAcJxxr0GQA2AgAOAAkJJhLPKAAQAgAAAA==.有德有诗:BAAALgAECgcJBwAAAA==.',
['有遮']='有遮:BAABLgAECn8YAAIVAAcJPBg2CgA2AgAVAAcJPBg2CgA2AgAAAA==.',
['期待']='期待那未来:BAAALgAECgYJDgAAAA==.',
['木大']='木大爷:BAAALgAECgMJBwAAAA==.',
['末日']='末日之星魂:BAAALgAECgQJBAAAAA==.',
['朱颜']='朱颜辞镜:BAAALgAECgcJBQABLgAFFAQJBAACAAAAAA==.',
['李果']='李果果的爸爸:BAAALgAECgUJBgAAAA==.',
['来呀']='来呀小宝贝:BAAALgAFFAIJAgAAAA==.',
['极限']='极限大漂亮:BAAALgADCgUJBQAAAA==.极限疯狂:BAAALgAECgYJBwAAAA==.极限雷哥:BAAALgAECgYJBQAAAA==.极限鬼妹:BAAALgAECgEJAQAAAA==.极限鬼斩:BAAALgAECgcJCAAAAA==.',
['果松']='果松村扛把子:BAAALgADCgYJBgAAAA==.',
['核心']='核心橙:BAAALgAECgUJCAAAAA==.',
['梦之']='梦之醉呀:BAAALgAECgcJEwAAAA==.',
['梦战']='梦战苍穹:BAAALgAFFAIJAgABLgAFFAUJBQAWAFMlAA==.',
['榴蓮']='榴蓮牛奶泡芙:BAAALgAECgYJCwAAAA==.',
['樱花']='樱花一宝儿:BAAALgAECgcJBwAAAA==.',
['橙多']='橙多多的垑溹:BAAALgAECgkJBgAAAA==.',
['欧气']='欧气的猫爪子:BAAALgAECgQJBQAAAA==.',
['欧皇']='欧皇:BAAALgAECgYJBgAAAA==.',
['正阳']='正阳:BAAALgADCgEJAgAAAA==.',
['死亡']='死亡主宰者:BAAALgAECgYJBgABLgAFFAIJAwACAAAAAA==.',
['残存']='残存丶剩光灬:BAABLgAFFH8FAAIBAAUJRghJCQBkAQABAAUJRghJCQBkAQAAAA==.',
['残月']='残月天:BAABLgAFFH8FAAIXAAMJeg5qLAAFAQAXAAMJeg5qLAAFAQAAAA==.',
['毛毛']='毛毛牛:BAAALgADCgEJAQAAAA==.',
['氵去']='氵去丶礻申:BAABLgAECn8UAAIXAAcJ4xC6lwClAQAXAAcJ4xC6lwClAQABLgAFFAQJCAAKAHMJAA==.',
['沐思']='沐思:BAAALgAECgUJBQAAAA==.',
['沐足']='沐足你还爱吗:BAAALgADCgkJCQAAAA==.',
['没事']='没事就睡觉么:BAAALgAECgUJBQAAAA==.',
['法灬']='法灬思:BAAALgADCgEJAQAAAA==.',
['法老']='法老之鹰:BAAALgAECgMJAwAAAA==.',
['泰兰']='泰兰徳:BAAALgAECgIJAgAAAA==.',
['洛克']='洛克塔欧格:BAAALgAECgQJDgAAAA==.',
['流氓']='流氓本性:BAAALgAECgcJBgAAAA==.',
['涂山']='涂山紅紅:BAAALgAFFAEJAgAAAA==.',
['清秋']='清秋叶念春风:BAAALgAECgMJAwAAAA==.',
['滺滺']='滺滺潴:BAAALgAECgUJBgAAAA==.',
['灬佩']='灬佩佩灬:BAAALgAECgQJAQAAAA==.',
['灬依']='灬依蓓:BAAALgADCgIJAgAAAA==.',
['灵灵']='灵灵牧:BAAALgAECgEJAQAAAA==.',
['烂漫']='烂漫山花:BAAALgAECgYJBgAAAA==.',
['烈焰']='烈焰母牛:BAAALgAECgYJBgAAAA==.',
['焉知']='焉知狸狸:BAAALgADCgYJBgAAAA==.',
['熊老']='熊老师:BAAALgAECgkJCwAAAA==.',
['爱不']='爱不是罪:BAAALgAECgcJCgAAAA==.',
['爱漠']='爱漠世疯年:BAAALgAECgcJDgAAAA==.',
['爱芮']='爱芮:BAACLgAFFH8KAAMSAAMJyiBRDQAsAQASAAMJCB1RDQAsAQATAAIJcB5nBQC8AAAuAAQKfxcAAxMABgl6JmwGAI4CABMABgl6JmwGAI4CABIABAm3Is8lAI4BAAAA.',
['牛劲']='牛劲:BAABLgAFFH8EAAIYAAMJQxZIDwD6AAAYAAMJQxZIDwD6AAAAAA==.',
['牛德']='牛德华丶斯基:BAAALgAECgUJBQAAAA==.',
['牛肉']='牛肉熟了:BAAALgAECgYJAwAAAA==.',
['狮子']='狮子挽歌:BAAALgADCgEJAQAAAA==.',
['猫姐']='猫姐:BAAALgAECgMJBAAAAA==.',
['王级']='王级战神:BAAALgAECgIJAQAAAA==.王级猎少:BAABLgAFFH8HAAIZAAMJRg8lDAABAQAZAAMJRg8lDAABAQAAAA==.王级龍少:BAAALgAFFAEJAQAAAA==.',
['玛丽']='玛丽鸡丝:BAAALgAECgYJBgAAAA==.',
['玩你']='玩你妹啊:BAAALgAECgYJEAAAAA==.',
['玩笑']='玩笑灬而已:BAAALgAECgkJCQAAAA==.',
['玲珑']='玲珑小厮:BAAALgAECgEJAQAAAA==.',
['琼斯']='琼斯雪诺:BAAALgADCgUJBQAAAA==.',
['瑜伽']='瑜伽裤老斑鸠:BAAALgAECgUJBQAAAA==.',
['画僧']='画僧逗奶:BAAALgAECgEJAQAAAA==.',
['痕墨']='痕墨殇:BAAALgADCgUJBQAAAA==.',
['癞蛤']='癞蛤蟆沾甜水:BAAALgAECgYJDwAAAA==.',
['百万']='百万炼狱扳机:BAAALgAECgcJBwAAAA==.',
['百兽']='百兽凌天:BAAALgADCgQJBQAAAA==.',
['真德']='真德清心:BAAALgAFFAEJAQAAAA==.',
['真的']='真的太难了:BAAALgAECgEJAQAAAA==.',
['硬硬']='硬硬:BAAALgAFFAIJAgAAAA==.',
['神一']='神一样的冰法:BAAALgAECgkJAwABLgAFFAMJCAAaAM0MAA==.',
['神潘']='神潘凤:BAAALgAECgEJAQAAAA==.',
['福瑞']='福瑞迪剋:BAACLgAFFH8GAAILAAMJzg9PKQD0AAALAAMJzg9PKQD0AAAuAAQKfx0AAgsACAl7HjUhALwCAAsACAl7HjUhALwCAAAA.',
['福袋']='福袋:BAAALgAECgIJAgAAAA==.',
['笑谈']='笑谈风华:BAAALgADCgEJAgAAAA==.',
['米青']='米青彩:BAAALgAECgEJAQAAAA==.',
['粉色']='粉色体育生:BAAALgAECgQJCAAAAA==.',
['糾結']='糾結式想念:BAAALgAFFAEJAwAAAA==.',
['紫罗']='紫罗兰颖:BAAALgADCgUJCgAAAA==.',
['红枣']='红枣桂圆:BAAALgADCgEJAQAAAA==.',
['红豆']='红豆派:BAAALgADCgEJAgAAAA==.',
['纯白']='纯白切茜娅:BAAALgAECgcJDQAAAA==.',
['绝对']='绝对精神小伙:BAAALgADCgYJBgAAAA==.',
['绿树']='绿树葉丶:BAABLgAFFH8TAAMMAAcJNSDPAwAFAgAMAAcJNSDPAwAFAgAZAAQJRg/6BQBDAQAAAA==.',
['老衲']='老衲牛叉不:BAAALgAECgYJBwAAAA==.',
['老青']='老青丘炸鸡腿:BAAALgAECgEJAQAAAA==.',
['者别']='者别:BAAALgAECgIJAwAAAA==.',
['联盟']='联盟两行泪:BAAALgAECgcJCwAAAA==.',
['肉没']='肉没熟:BAAALgAECgYJBwAAAA==.',
['能小']='能小棕:BAAALgADCggJCQAAAA==.',
['自由']='自由时间:BAAALgAECgIJAwAAAA==.',
['至尊']='至尊绝杀:BAAALgAECgEJAQAAAA==.',
['舒然']='舒然小开心:BAABLgAECn8YAAIHAAcJNxmIBADtAQAHAAcJNxmIBADtAQAAAA==.',
['艾尔']='艾尔登之王:BAAALgAECgMJAwAAAA==.',
['艾萨']='艾萨克:BAAALgAECgYJDAAAAA==.',
['芝嵐']='芝嵐:BAAALgAECgMJAwAAAA==.',
['芯茹']='芯茹祉水:BAAALgADCgYJBgAAAA==.',
['花季']='花季大叔们:BAAALgADCgUJBQAAAA==.',
['花袜']='花袜子:BAAALgAECgUJBQAAAA==.',
['莞一']='莞一笑:BAAALgAECgEJAQAAAA==.',
['莱茵']='莱茵河畔:BAAALgAECgYJBQAAAA==.',
['菲莉']='菲莉希娅:BAAALgAECgMJAwAAAA==.',
['萝卜']='萝卜丶:BAAALgAECgQJBAAAAA==.',
['葉冷']='葉冷:BAAALgAFFAEJAQAAAA==.',
['葵茉']='葵茉莉:BAAALgADCgcJBwAAAA==.',
['蒸蚌']='蒸蚌蒸蚌:BAAALgAECgYJBgAAAA==.',
['蓝子']='蓝子虚:BAAALgAECgYJBgABLgAFFAQJBAACAAAAAA==.',
['蔚蓝']='蔚蓝的天空:BAAALgADCgEJAQAAAA==.',
['薄荷']='薄荷奶昔:BAAALgAECgkJAgAAAA==.',
['虎哥']='虎哥哥:BAAALgAFFAEJAgAAAA==.',
['虫出']='虫出魔兽:BAAALgADCgcJBwAAAA==.',
['蛮小']='蛮小脚:BAAALgADCgIJAgAAAA==.',
['被祝']='被祝福的猫:BAAALgAECgcJCAAAAA==.',
['西格']='西格蒙德:BAAALgAECgMJAwAAAA==.',
['要奶']='要奶喊我:BAAALgAECgIJAgAAAA==.',
['要饭']='要饭不带碗:BAAALgAECgYJCQAAAA==.',
['誓约']='誓约胜利之剑:BAAALgAECgEJAQAAAA==.',
['让窝']='让窝先来:BAAALgAECgEJAQAAAA==.',
['许辰']='许辰丶浮花子:BAAALgAECgQJBAAAAA==.',
['诛仙']='诛仙男孩小夏:BAABLgAFFH8UAAMLAAYJCyV+AAB7AgALAAYJCyV+AAB7AgAbAAIJWCMAAAAAAAAAAA==.',
['请叫']='请叫我苏哥哥:BAAALgAECgEJAQAAAA==.',
['贾志']='贾志国:BAAALgAECgMJAwAAAA==.',
['赵守']='赵守城:BAAALgAECgQJBAAAAA==.',
['起开']='起开:BAAALgAECgEJAQAAAA==.',
['起手']='起手双蛋刀:BAAALgADCgYJBgAAAA==.',
['趁醉']='趁醉独饮:BAAALgAECgQJBgAAAA==.',
['超威']='超威蓝猫:BAAALgADCgEJAQAAAA==.',
['软软']='软软吖:BAAALgADCgIJAgAAAA==.',
['辰熙']='辰熙微光:BAAALgAFFAIJAgAAAA==.',
['迅捷']='迅捷毛爪爪:BAAALgAECgQJCgAAAA==.迅捷而弱小:BAAALgAFFAIJAwAAAA==.',
['过期']='过期猫罐头:BAAALgAECgEJAQAAAA==.',
['这个']='这个陪:BAABLgAFFH8GAAIIAAYJ3hTAAAALAgAIAAYJ3hTAAAALAgAAAA==.',
['迷失']='迷失的野牛:BAAALgAFFAIJBAAAAA==.',
['逝灬']='逝灬弑:BAAALgADCgEJAQAAAA==.',
['邈思']='邈思孙:BAAALgAECgYJCwAAAA==.',
['邓小']='邓小良:BAAALgAECgIJAgAAAA==.',
['那个']='那个和尚:BAAALgAECgcJBwAAAA==.',
['那就']='那就算了:BAAALgAECgYJBgAAAA==.',
['那年']='那年似水如年:BAAALgAFFAIJAgAAAA==.',
['酒舞']='酒舞二妻:BAAALgAECgEJAQAAAA==.',
['醉丨']='醉丨八荒:BAAALgAECgcJBwAAAA==.',
['野性']='野性不知火:BAAALgAECgYJDQAAAA==.',
['金玉']='金玉麒麟:BAAALgAECgYJBQAAAA==.',
['银月']='银月城荣耀:BAAALgAECggJDwAAAA==.',
['闻香']='闻香识女人:BAAALgAECgYJBgAAAA==.',
['阿刁']='阿刁妹儿:BAAALgAECgQJBAAAAA==.',
['阿星']='阿星星:BAAALgAECgQJBQAAAA==.',
['阿波']='阿波尼亚:BAAALgAECgQJBAAAAA==.',
['阿莎']='阿莎曼:BAAALgAECgIJAgAAAA==.',
['阿萨']='阿萨小基友:BAABLgAFFH8FAAILAAMJ8A+bKQDzAAALAAMJ8A+bKQDzAAAAAA==.',
['随风']='随风而过:BAAALgAECgIJAwAAAA==.',
['雨中']='雨中小椰子灬:BAAALgADCgEJAQAAAA==.',
['雪狱']='雪狱:BAABLgAECn8UAAIXAAgJlh2cMgCoAgAXAAgJlh2cMgCoAgAAAA==.',
['雪鹽']='雪鹽焦糖貓:BAACLgAFFH8HAAIJAAQJ9RK4CABXAQAJAAQJ9RK4CABXAQAuAAQKfyYAAwkACAmkIL8IAAkDAAkACAmkIL8IAAkDAA4ABQmyHcUeAMAAAAAA.',
['雾警']='雾警警脾气臭:BAAALgAFFAEJAQAAAA==.',
['青岛']='青岛土掉渣:BAABLgAFFH8FAAIUAAMJKhkjBQCeAAAUAAMJKhkjBQCeAAAAAA==.',
['静镜']='静镜:BAAALgAECgIJAgAAAA==.',
['音无']='音无华奏:BAAALgADCgUJBQAAAA==.',
['風暴']='風暴清酒:BAAALgADCgEJAgAAAA==.風暴米酒:BAAALgAECgYJCwABLgAFFAQJBAACAAAAAA==.',
['風非']='風非翼:BAAALgAECgIJAwAAAA==.',
['风住']='风住了风:BAAALgAECgIJAgAAAA==.',
['骑士']='骑士诺贝蒂:BAAALgAFFAEJAQAAAA==.',
['鬼眼']='鬼眼狂刀:BAAALgADCgIJAgAAAA==.',
['魑魅']='魑魅魍魉魉:BAAALgAECgYJCgAAAA==.',
['鸡汤']='鸡汤来咯:BAAALgAECgYJDAABLgAFFAEJAQACAAAAAA==.',
['鸣上']='鸣上悠丶:BAAALgAECgkJEgAAAA==.',
['鹤井']='鹤井闲人:BAAALgAFFAIJAgAAAA==.',
['麦的']='麦的垛朱尼尔:BAAALgAECgcJDAAAAA==.',
['黄山']='黄山牌香烟:BAAALgAECgUJBQAAAA==.',
['黑色']='黑色小裤头:BAAALgAECgEJAQAAAA==.',
['龙倩']='龙倩児:BAAALgAECgIJAQAAAA==.',
['龙系']='龙系儿:BAAALgAECgIJBAAAAA==.',
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
