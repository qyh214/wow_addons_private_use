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

local lookup = {'Druid-Restoration','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Mage-Frost','DemonHunter-Devourer','Druid-Balance','Warrior-Arms','DemonHunter-Havoc','Rogue-Subtlety','Warlock-Demonology','Priest-Discipline','Warrior-Fury','Shaman-Restoration','DeathKnight-Blood','DemonHunter-Vengeance','Shaman-Elemental','DeathKnight-Unholy','Priest-Holy','Druid-Guardian','Monk-Brewmaster','Mage-Arcane','Mage-Ranged',}
local provider = {region='CN',realm='守护之剑',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alliancpower:BAAALgADCgEJAgAAAA==.',
An='Animagus:BAACLgAFFH8VAAIBAAYJfCVGAACTAgABAAYJfCVGAACTAgAuAAQKfxgAAgEACQl8JYYAAMgDAAEACQl8JYYAAMgDAAAA.',
Ar='Art:BAAALgAECgEJAQAAAA==.',
Az='Azul:BAAALgAECgYJCgAAAA==.',
Bg='Bgvirgo:BAAALgAECgUJCAAAAA==.',
Bo='Boykises:BAAALgADCgEJAQAAAA==.',
Di='Disappeared:BAAALgADCgIJAgAAAA==.',
El='Ellis:BAAALgADCgYJBgAAAA==.',
Fa='Facefear:BAAALgAECgEJAQAAAA==.',
Fe='Ferry:BAAALgAECgEJAQAAAA==.',
Fi='Figo:BAAALgAECgcJEQABLgAFFAQJBAACAAAAAA==.',
Fo='Foraiur:BAABLgAECn8WAAMDAAkJZSBfBABJAwADAAkJaB9fBABJAwAEAAcJbyGyIwAGAgAAAA==.',
Ha='Hack:BAAALgAECgQJBAAAAA==.Hanser:BAAALgADCgYJBgAAAA==.',
Hi='Hinz:BAABLgAECn8bAAIFAAgJICTTCgA5AwAFAAgJICTTCgA5AwAAAA==.',
Ic='Icecream:BAAALgAECgUJBwAAAA==.',
Jd='Jdll:BAAALgAECgYJDQAAAA==.',
Ka='Karlbaby:BAAALgAECgkJBwAAAA==.',
Ke='Kemical:BAAALgAFFAIJAgAAAA==.',
Lo='Lo:BAAALgAECgUJCQAAAA==.',
Ma='Maire:BAAALgADCgIJAgAAAA==.',
Mu='Mubati:BAAALgAECgYJDAAAAA==.Mulu:BAAALgAECgIJAwAAAA==.Musee:BAAALgAECgEJAQAAAA==.',
Nc='Nc:BAAALgAECgEJAQAAAA==.',
Ne='Netflix:BAAALgADCgEJAQAAAA==.',
No='Noelle:BAAALgAECgYJDgAAAA==.',
Og='Ogloc:BAAALgAECgUJBQAAAA==.',
Pi='Pinkpapa:BAAALgAECgYJAgAAAA==.',
Re='Remiria:BAAALgAECgUJBwAAAA==.',
Rv='Rvmnk:BAAALgADCgYJBgAAAA==.',
So='Solarius:BAAALgAECgEJAQAAAA==.',
Sy='Sylvans:BAAALgADCgYJBgAAAA==.',
Te='Terminusest:BAAALgAECgIJBAAAAA==.',
Ty='Typemoon:BAABLgAFFH8FAAIGAAIJUxmsNwC7AAAGAAIJUxmsNwC7AAABLgAFFAIJBwAHAGASAA==.',
Va='Vampire:BAAALgAECgEJAQAAAA==.',
Xi='Xinliu:BAAALgAECgEJAQAAAA==.',
Xx='Xxspec:BAAALgAECgYJBgAAAA==.',
['一同']='一同天下:BAAALgAFFAEJAQAAAA==.',
['一德']='一德芙人:BAAALgADCgEJAQAAAA==.',
['一心']='一心不乱:BAAALgAECgIJBQAAAA==.',
['一插']='一插一哆嗦:BAAALgAECgMJAwAAAA==.',
['下班']='下班的哈娜:BAAALgAECgEJAgAAAA==.',
['东方']='东方树叶:BAAALgAECgQJBAAAAA==.',
['丶月']='丶月落:BAAALgAECgEJAgAAAA==.',
['丶花']='丶花生米:BAAALgADCgYJBgAAAA==.',
['丿白']='丿白鹿秋:BAAALgAECgEJAgAAAA==.',
['乔拉']='乔拉可尔:BAAALgADCgcJBwAAAA==.',
['乔汉']='乔汉娜:BAAALgAECgEJAgAAAA==.',
['五十']='五十嵐裕也:BAABLgAECn8iAAMBAAgJ1yB5CwDlAgABAAgJ1yB5CwDlAgAIAAIJawjjdABPAAAAAA==.',
['五岁']='五岁:BAAALgAECgQJBAAAAA==.',
['伊克']='伊克西之翼:BAAALgAECgEJAQAAAA==.',
['伊莉']='伊莉达蕾:BAAALgAECgEJAQAAAA==.',
['传说']='传说中的蛋蛋:BAAALgAECgMJAgAAAA==.',
['伽蓝']='伽蓝:BAAALgAECgEJAQAAAA==.',
['你是']='你是个球啊:BAAALgAECgYJDAAAAA==.',
['你的']='你的益达:BAAALgAECgYJAwAAAA==.',
['佩可']='佩可莉姆:BAAALgAFFAMJAwAAAA==.',
['偷偷']='偷偷的奶一口:BAAALgAECgYJBgAAAA==.',
['偷袭']='偷袭老年人:BAACLgAFFH8NAAIGAAUJfRIwDQCyAQAGAAUJfRIwDQCyAQAuAAQKfyAAAgYACAm9I40WACIDAAYACAm9I40WACIDAAAA.',
['儿童']='儿童归来:BAAALgADCgEJAQAAAA==.',
['兜兜']='兜兜有寂寞:BAAALgAECgkJAQAAAA==.',
['八十']='八十八十:BAAALgAFFAEJAQAAAA==.',
['八月']='八月即飞雪:BAAALgAECgEJAQAAAA==.',
['兲嘫']='兲嘫丶汁:BAAALgAECgUJBQAAAA==.',
['冰墩']='冰墩墩:BAABLgAFFH8GAAIJAAMJUxtUAwAWAQAJAAMJUxtUAwAWAQAAAA==.',
['冷岚']='冷岚曦:BAABLgAFFH8HAAIEAAUJoBTqCwBcAQAEAAUJoBTqCwBcAQAAAA==.',
['冷月']='冷月葬花魂丶:BAAALgAECgYJBgABLgAECgYJBwACAAAAAA==.冷月霜飞雪丶:BAAALgAECggJDgAAAA==.',
['凉茶']='凉茶:BAAALgAECgEJAQABLgAFFAYJCQAJAEMfAA==.',
['凌丶']='凌丶雪:BAAALgAECgIJAgAAAA==.',
['凹凸']='凹凸曼吞吞:BAAALgAECgIJAgAAAA==.',
['刘诗']='刘诗湿:BAAALgAFFAEJAgABLgAFFAIJBwAHAGASAA==.',
['初音']='初音岛的樱花:BAAALgAECgkJCQAAAA==.',
['别院']='别院莺歌:BAACLgAFFH8NAAIHAAQJUg8NCQAlAQAHAAQJUg8NCQAlAQAuAAQKfyIAAwcABwlTICckAHkCAAcABwlTICckAHkCAAoAAgn0CPFhAFsAAAAA.',
['加多']='加多寳:BAAALgADCgMJAwAAAA==.',
['劲哥']='劲哥哥:BAAALgAFFAEJAgAAAA==.',
['十岁']='十岁:BAAALgAECgEJAQAAAA==.',
['升云']='升云出鼎湖:BAAALgAECgMJAwAAAA==.',
['半支']='半支烟:BAAALgAECgUJBQAAAA==.',
['半点']='半点不由人:BAAALgADCgEJAQAAAA==.',
['卖萌']='卖萌的大西瓜:BAAALgADCgEJAQAAAA==.',
['南笙']='南笙浅梦墨汐:BAAALgAECgYJBwAAAA==.',
['卢卡']='卢卡不是奶龙:BAAALgAECgcJEQAAAA==.',
['原来']='原来是你:BAAALgAECgIJAgAAAA==.',
['又睡']='又睡十八分钟:BAABLgAFFH8FAAILAAQJBwfHCgBCAQALAAQJBwfHCgBCAQAAAA==.',
['只学']='只学被动天赋:BAAALgAECgQJBAAAAA==.',
['可爱']='可爱的球球:BAAALgAFFAEJAQAAAA==.',
['司空']='司空圣:BAAALgADCgYJBgAAAA==.',
['吃瓜']='吃瓜姨姨:BAAALgAECgYJBgAAAA==.',
['吉吉']='吉吉小傻猪:BAAALgAECgMJAwAAAA==.吉吉小懒猪:BAAALgADCgEJAQAAAA==.吉吉小笨猪:BAAALgADCgEJAQAAAA==.',
['君丶']='君丶天下:BAAALgAECgQJBAAAAA==.',
['听山']='听山观海:BAAALgAECgEJAgAAAA==.',
['吾知']='吾知汝深浅:BAAALgAECgQJBAAAAA==.',
['命運']='命運脉動:BAAALgADCgEJAQAAAA==.',
['咕德']='咕德外带捅:BAAALgADCgEJAQAAAA==.',
['哈尼']='哈尼卷卷:BAAALgAECgEJAQAAAA==.',
['哦好']='哦好的:BAAALgAECgcJBwAAAA==.',
['喵喵']='喵喵妙喵喵:BAAALgAECgEJAQAAAA==.',
['嗆口']='嗆口乄小辣椒:BAABLgAFFH8GAAIMAAIJeRu+FAC9AAAMAAIJeRu+FAC9AAAAAA==.',
['嘎木']='嘎木第一痴情:BAAALgADCgYJBgAAAA==.',
['嚼到']='嚼到你昏迷:BAAALgAECgIJAgAAAA==.',
['国服']='国服第一美:BAAALgAECgMJAwAAAA==.',
['圣一']='圣一若梦:BAAALgAECgEJAgAAAA==.',
['圣神']='圣神斯文:BAAALgADCgEJAQAAAA==.',
['坚硬']='坚硬侠:BAAALgADCgUJBQAAAA==.',
['埃斯']='埃斯卡破魂:BAAALgAECgYJDAAAAA==.',
['塞博']='塞博坦:BAAALgADCgEJAQAAAA==.',
['夏天']='夏天的华尔兹:BAAALgAECgQJBgAAAA==.',
['夏沫']='夏沫晨曦:BAAALgAECgMJAwAAAA==.',
['夙咊']='夙咊:BAAALgAECgYJEAAAAA==.',
['夙姀']='夙姀:BAAALgADCgYJBwABLgAECgYJEAACAAAAAA==.',
['夜丶']='夜丶小箫:BAAALgAECgcJCgAAAA==.',
['夜深']='夜深人靜:BAAALgAECgQJBAABLgAECgcJEwACAAAAAA==.',
['大薛']='大薛迪克:BAAALgAECgMJAwAAAA==.',
['天之']='天之神铭:BAAALgAECgMJAwAAAA==.',
['奇得']='奇得隆:BAAALgAECgEJAgAAAA==.',
['女乃']='女乃乄米唐:BAAALgAFFAIJAwAAAA==.',
['奶包']='奶包:BAACLgAFFH8FAAINAAIJ3xBHEwCbAAANAAIJ3xBHEwCbAAAuAAQKfyEAAg0ACAn/IpADADEDAA0ACAn/IpADADEDAAAA.',
['如约']='如约灬而至:BAAALgAECgQJBAAAAA==.',
['妙啊']='妙啊妙啊:BAAALgAECgMJAwAAAA==.',
['娜塔']='娜塔莉波特曼:BAAALgAECgYJDwAAAA==.',
['孔雀']='孔雀东南飞:BAAALgADCgYJEgAAAA==.',
['孤独']='孤独飘:BAAALgAECgYJBwAAAA==.',
['宇智']='宇智波冰霜:BAAALgAECgEJAQAAAA==.',
['宇髄']='宇髄天元丶:BAACLgAFFH8QAAIHAAYJJw8mBQDZAQAHAAYJJw8mBQDZAQAuAAQKfyIAAgcACAnbIfIQAPcCAAcACAnbIfIQAPcCAAAA.',
['安德']='安德烈空气:BAAALgADCgYJBgAAAA==.',
['宝强']='宝强别哭:BAAALgAECgEJAQAAAA==.',
['宽带']='宽带山滚地龙:BAAALgADCgEJAQAAAA==.',
['射击']='射击猎:BAAALgAECgEJAQAAAA==.',
['小作']='小作坊下料猛:BAAALgAECgIJAgAAAA==.',
['小小']='小小魚:BAAALgAECgQJBgAAAA==.',
['小师']='小师妹真靓:BAAALgAECgUJDgAAAA==.',
['小旋']='小旋风:BAAALgAECgMJAwAAAA==.',
['小李']='小李子:BAAALgAECgcJBwABLgAFFAUJAQACAAAAAA==.',
['小牛']='小牛来了:BAAALgADCgQJBAAAAA==.',
['小猎']='小猎灬死神:BAAALgADCgMJAwAAAA==.',
['小猫']='小猫晃悠悠:BAAALgAECgQJCAABLgAECgYJBwACAAAAAA==.',
['小米']='小米朵:BAAALgAECgYJBwAAAA==.',
['小萨']='小萨去哪儿:BAAALgAECgkJDQAAAA==.',
['小马']='小马的抹茶:BAAALgAFFAIJAgAAAA==.',
['小魔']='小魔无敌:BAAALgAECgUJCAAAAA==.',
['尤加']='尤加利叶:BAAALgAFFAIJAgAAAA==.',
['屠猪']='屠猪刀:BAABLgAFFH8FAAIOAAIJ9A/uJABKAAAOAAIJ9A/uJABKAAAAAA==.',
['屮莓']='屮莓百分百:BAAALgADCgEJAQAAAA==.',
['岸芷']='岸芷汀兰:BAAALgAECgIJAgABLgAFFAQJDAAPALAVAA==.',
['崑崙']='崑崙:BAAALgAECgYJCwAAAA==.',
['左马']='左马:BAAALgADCgYJBgAAAA==.',
['巨胖']='巨胖大肥龙:BAAALgADCgYJCwAAAA==.',
['帮助']='帮助伱帮助我:BAAALgAFFAIJAwAAAA==.',
['广结']='广结善缘:BAAALgADCgEJAQAAAA==.',
['康娜']='康娜卡姆依:BAAALgAECgMJAwAAAA==.',
['开冲']='开冲:BAAALgAECgQJBAAAAA==.',
['开开']='开开窍:BAAALgAFFAIJAgAAAA==.',
['开心']='开心男孩:BAAALgAECgIJAgAAAA==.',
['异度']='异度守望橙:BAAALgAECgYJBwAAAA==.',
['弓箭']='弓箭手:BAAALgADCgYJBgAAAA==.',
['弟荙']='弟荙洞洞荙荙:BAAALgAECgkJBwAAAA==.',
['张灬']='张灬海旺:BAAALgAECggJDgAAAA==.',
['当局']='当局者迷:BAABLgAFFH8HAAIQAAIJERWEBgCRAAAQAAIJERWEBgCRAAAAAA==.',
['征战']='征战之年:BAAALgAECgEJAQAAAA==.',
['征收']='征收熊:BAAALgAECgYJBgAAAA==.',
['德芙']='德芙德:BAAALgAECgEJAwAAAA==.',
['心上']='心上:BAAALgAECgkJDgABLgAFFAUJEAAGAFIlAA==.',
['心動']='心動:BAAALgAECgMJBAAAAA==.',
['心跳']='心跳在左边:BAAALgADCgEJAQAAAA==.',
['情傷']='情傷:BAABLgAECn8UAAIPAAkJ8BZzHgApAgAPAAkJ8BZzHgApAgAAAA==.',
['情系']='情系吾人:BAAALgADCgEJAQAAAA==.',
['想办']='想办法的霄:BAAALgAECgEJAQAAAA==.',
['慕格']='慕格莱尼:BAAALgAECgEJAgAAAA==.',
['慢慢']='慢慢:BAAALgAFFAEJAQAAAA==.',
['慧远']='慧远:BAAALgADCgEJAQAAAA==.',
['戆胖']='戆胖:BAAALgADCgYJBgAAAA==.',
['我是']='我是花哥:BAAALgAFFAMJAwAAAA==.',
['战神']='战神斯文:BAAALgAECgEJAQAAAA==.',
['戦丶']='戦丶珐:BAAALgAECgYJBgAAAA==.戦丶魍:BAAALgAECgYJBgAAAA==.',
['手心']='手心的蔷薇:BAAALgADCgEJAQAAAA==.',
['执笔']='执笔画黛眉:BAAALgAECgkJDAABLgAFFAQJDAAPALAVAA==.',
['把你']='把你们都鲨了:BAAALgAECgEJAQAAAA==.',
['拉斐']='拉斐尔娜:BAAALgAECgUJDAAAAA==.',
['拉糖']='拉糖起门告辞:BAAALgAECggJBAABLgAFFAcJBwAMANgSAA==.',
['按在']='按在地板摩擦:BAACLgAFFH8HAAMHAAIJYBIVFACgAAAHAAIJYBIVFACgAAAKAAEJxgRDDwBHAAAuAAQKfxQABAcABgnxIPosAEoCAAcABgnxIPosAEoCAAoABAlmGjg/AP8AABEAAQmpCY0sAC4AAAAA.',
['换号']='换号拿橙武:BAAALgADCgMJAwAAAA==.',
['摸摸']='摸摸向上游:BAAALgAECgEJAQAAAA==.',
['撕天']='撕天:BAAALgAECgEJAgAAAA==.',
['放学']='放学你别跑:BAABLgAFFH8QAAIMAAUJJhcJBwCyAQAMAAUJJhcJBwCyAQAAAA==.',
['文法']='文法拉辛:BAAALgAECgQJCAAAAA==.',
['断浪']='断浪刀:BAABLgAFFH8FAAIMAAMJRwiFJQDsAAAMAAMJRwiFJQDsAAAAAA==.',
['斯提']='斯提亚拉:BAAALgADCgcJDgABLgAECgIJBQACAAAAAA==.',
['旃蒙']='旃蒙:BAAALgAECgQJBAAAAA==.',
['旅人']='旅人超哥:BAABLgAECn8YAAISAAgJsxyiGABPAgASAAgJsxyiGABPAgAAAA==.',
['无尽']='无尽暗牧:BAAALgAECgkJCQAAAA==.',
['无敌']='无敌中登:BAAALgAFFAMJBAAAAA==.无敌果然寂寞:BAAALgAECgUJBgAAAA==.',
['无理']='无理小德:BAAALgAECgMJAwAAAA==.',
['晨星']='晨星风舞:BAAALgADCgYJBgAAAA==.',
['晴空']='晴空初斐:BAAALgADCgYJBgAAAA==.',
['暗非']='暗非:BAAALgAECgMJAwAAAA==.',
['暗鸦']='暗鸦守卫:BAAALgADCgYJBgAAAA==.',
['暴虐']='暴虐灬瑟琳娜:BAAALgAECgcJBwAAAA==.暴虐的灬山君:BAAALgAECgYJBgABLgAECgcJBwACAAAAAA==.',
['暴躁']='暴躁的塔塔:BAAALgADCgcJDQAAAA==.',
['月之']='月之天狼:BAAALgAFFAMJAwAAAA==.',
['月夜']='月夜传说:BAABLgAECn8kAAIBAAgJFBX/LAD6AQABAAgJFBX/LAD6AQAAAA==.',
['月盲']='月盲:BAAALgADCgYJBgAAAA==.',
['月隐']='月隐藏锋匿迹:BAAALgAECgcJCAAAAA==.',
['朝圣']='朝圣的小蜗牛:BAAALgADCgEJAQAAAA==.',
['末季']='末季邂逅:BAAALgAECgcJBwAAAA==.',
['本泽']='本泽彪:BAAALgAECgkJCQAAAA==.本泽马户:BAAALgAECgYJBgAAAA==.',
['杜特']='杜特尔特:BAAALgADCgMJAwAAAA==.',
['来易']='来易去难:BAABLgAECn8WAAITAAkJwhCKQAA2AgATAAkJwhCKQAA2AgAAAA==.',
['极巨']='极巨化暴鲤龙:BAAALgAFFAEJAgABLgAFFAIJBwAQABEVAA==.',
['柯朵']='柯朵莉诺塔:BAAALgAECgkJAgAAAA==.',
['柳贯']='柳贯一:BAAALgAECgQJAwAAAA==.',
['桀骜']='桀骜的大妈:BAAALgAFFAIJBAAAAA==.',
['楚天']='楚天阔:BAAALgAECgMJAwAAAA==.',
['楠哥']='楠哥:BAAALgADCgUJCAAAAA==.楠哥呀:BAAALgAECgMJAwAAAA==.',
['樱桃']='樱桃子:BAAALgADCgYJCAAAAA==.',
['樹下']='樹下聽雨:BAAALgAECgIJAgAAAA==.',
['欢乐']='欢乐和内容:BAAALgAECgUJBQAAAA==.',
['此情']='此情可待:BAAALgAFFAIJAwAAAA==.',
['武神']='武神斯文:BAAALgADCgMJAgAAAA==.',
['死刑']='死刑宣判:BAAALgAECgYJBgAAAA==.',
['死际']='死际:BAAALgAECgUJCAAAAA==.',
['沙琪']='沙琪玛:BAAALgAECgUJBQAAAA==.',
['没事']='没事数数钱:BAAALgAECgkJCQAAAA==.',
['法神']='法神斯文:BAAALgAECgMJAwAAAA==.',
['泡辉']='泡辉:BAAALgAECgYJCAAAAA==.',
['波摩']='波摩:BAAALgAECgkJDwAAAA==.',
['波雅']='波雅灬漢庫克:BAAALgAECgYJDwAAAA==.',
['泰兰']='泰兰徳之翼:BAAALgAECgcJCAAAAA==.',
['洛丽']='洛丽塔:BAAALgAFFAEJAQAAAA==.',
['流影']='流影丨青霜:BAACLgAFFH8OAAINAAQJDx+1BQCKAQANAAQJDx+1BQCKAQAuAAQKfxkAAw0ACAkaHYEMAHACAA0ACAmHGoEMAHACABQAAQnmJPluAGsAAAAA.',
['流氓']='流氓要逆袭:BAAALgAECgQJBAAAAA==.',
['浊森']='浊森:BAAALgADCgYJDAAAAA==.',
['海思']='海思大牛:BAAALgAECgcJEwAAAA==.',
['海糖']='海糖:BAAALgAECgYJBgABLgAFFAUJBgAGABoKAA==.',
['涛灬']='涛灬涛:BAAALgADCgEJAQAAAA==.',
['淅淅']='淅淅索索:BAAALgAFFAIJAgAAAA==.',
['清浅']='清浅:BAAALgAECgUJBQAAAA==.',
['清辉']='清辉:BAAALgAECgUJBQAAAA==.',
['溶解']='溶解孤独:BAAALgAECgkJEQAAAA==.',
['潜入']='潜入搜查官:BAAALgAECgQJBAAAAA==.',
['灬枫']='灬枫灬:BAAALgAECgEJAgAAAA==.',
['灬糖']='灬糖馨灬:BAAALgAECgYJBgAAAA==.',
['灵媚']='灵媚静轩:BAAALgAECgQJAwAAAA==.',
['炼狱']='炼狱之盐酥鸡:BAAALgADCgcJBwABLgAECggJGAAGAHwiAA==.',
['烈云']='烈云:BAAALgADCgUJBQAAAA==.',
['烟花']='烟花迷离:BAAALgAECgcJEwAAAA==.',
['煽风']='煽风点火灬:BAAALgAFFAIJAgAAAA==.',
['爆之']='爆之血:BAAALgAECgYJDgAAAA==.',
['爬开']='爬开老子宁静:BAAALgAECgUJBQAAAA==.爬开老子英勇:BAAALgAECgEJAQAAAA==.爬开老子起门:BAAALgAECgEJAQAAAA==.',
['爱上']='爱上雪的冰冷:BAAALgAECgQJBAAAAA==.',
['爱通']='爱通通:BAAALgAECgYJCgAAAA==.',
['狂飙']='狂飙灬三毛:BAABLgAFFH8FAAILAAMJSxwTDAAhAQALAAMJSxwTDAAhAQABLgAFFAYJGQAQAAYmAA==.',
['狩猎']='狩猎猫咪:BAAALgAECgUJCgAAAA==.',
['猎神']='猎神斯文:BAAALgAECgQJBAAAAA==.',
['猪母']='猪母狼马蜂:BAAALgAECgIJAgAAAA==.',
['猪猪']='猪猪丶昊仔:BAAALgAECgYJBgAAAA==.',
['猫耳']='猫耳多多:BAAALgAECgcJEwAAAA==.猫耳月月:BAABLgAECn8WAAMTAAcJxRuPWQDlAQATAAcJxRuPWQDlAQAQAAYJihTRJgAIAQABLgAFFAYJGQAQAAYmAA==.',
['猫雷']='猫雷:BAAALgAECgMJAwAAAA==.',
['玖悦']='玖悦:BAABLgAECn8YAAIGAAgJfCKWBgBEAgAGAAgJfCKWBgBEAgAAAA==.',
['玛珐']='玛珐里奥怒风:BAAALgAECgcJEAAAAA==.',
['玫瑰']='玫瑰炖蛋:BAAALgADCgYJBgAAAA==.',
['现代']='现代城市猎:BAAALgAECgMJAwAAAA==.',
['电喵']='电喵丶皮卡丘:BAAALgAECgQJBAABLgAECgYJBwACAAAAAA==.',
['白牡']='白牡丹:BAAALgADCgUJBQAAAA==.',
['白胡']='白胡子爱德华:BAAALgAECgEJAQAAAA==.',
['皓若']='皓若流火:BAAALgAECgIJAgAAAA==.',
['盖世']='盖世丹妮莉丝:BAAALgAECgQJBQAAAA==.',
['盾比']='盾比命厚:BAAALgADCgIJAQAAAA==.',
['硬而']='硬而不软:BAABLgAECn8YAAIDAAcJ6Ro4CQDVAQADAAcJ6Ro4CQDVAQAAAA==.',
['碳沓']='碳沓:BAAALgAECgYJCgAAAA==.',
['神圣']='神圣风暴玩的:BAAALgAECgEJAQAAAA==.',
['神尊']='神尊大不净:BAAALgAECgYJBwAAAA==.',
['神猎']='神猎阿丰:BAAALgAECgQJBAAAAA==.',
['秋茉']='秋茉雨:BAAALgAECgMJAQABLgAFFAUJDQADAOsUAA==.',
['秦喵']='秦喵喵德里奇:BAAALgAECgIJAgAAAA==.',
['稀神']='稀神探女:BAAALgAECgUJCQAAAA==.',
['空袭']='空袭巴格达:BAAALgAFFAEJAgAAAA==.',
['米菈']='米菈娜:BAAALgAECgEJAQAAAA==.',
['精灵']='精灵小树:BAAALgAECgYJBgAAAA==.',
['糖糖']='糖糖馨:BAAALgAECggJDQAAAA==.',
['糖馨']='糖馨馨:BAAALgAECgYJBgAAAA==.',
['紫泷']='紫泷:BAAALgAECgYJDAAAAA==.',
['紫竉']='紫竉:BAABLgAFFH8NAAIFAAQJ4B7bBwB0AQAFAAQJ4B7bBwB0AQAAAA==.',
['紫雲']='紫雲:BAAALgAFFAEJAQAAAA==.',
['紫龙']='紫龙神骑士:BAAALgADCgIJAQAAAA==.',
['红祭']='红祭司:BAAALgAECgMJAwAAAA==.',
['红魔']='红魔马球王:BAAALgAECgQJBAAAAA==.红魔魔力鸟:BAAALgAECgQJBAAAAA==.',
['纳格']='纳格兰的晨星:BAAALgADCgEJAQAAAA==.',
['纵火']='纵火犯:BAAALgAECgYJBQAAAA==.',
['纸鸢']='纸鸢尾:BAAALgAECgUJCQAAAA==.',
['练功']='练功发自内心:BAABLgAFFH8FAAIVAAIJtAhkBQBjAAAVAAIJtAhkBQBjAAABLgAFFAIJBwAQABEVAA==.',
['给大']='给大郎灌药:BAAALgAECgEJAQAAAA==.',
['绝黛']='绝黛:BAAALgAECgMJAwAAAA==.',
['缓解']='缓解旅客:BAABLgAECn8WAAIGAAYJFBDDxABdAQAGAAYJFBDDxABdAQAAAA==.',
['缘生']='缘生意转:BAABLgAECn8UAAMSAAkJCx2ZAADNAgASAAkJCx2ZAADNAgAPAAcJJBRHLwDLAQABLgAFFAcJGQASAJEdAA==.',
['罐子']='罐子:BAAALgAFFAIJBAAAAA==.',
['罚罪']='罚罪:BAAALgADCgMJAwAAAA==.',
['羊的']='羊的了一时:BAAALgAFFAEJAgAAAA==.',
['老司']='老司机套路深:BAAALgAECgYJCAAAAA==.',
['老王']='老王头:BAAALgAECgIJAwAAAA==.',
['胖胖']='胖胖不怕胖:BAAALgAECgYJBgAAAA==.',
['臣想']='臣想半隐:BAAALgAECgQJBAAAAA==.',
['花开']='花开只为君:BAAALgAFFAEJAQAAAA==.',
['花生']='花生米德:BAAALgAECgYJBwAAAA==.',
['花脸']='花脸猫丶:BAAALgAECgEJAQAAAA==.',
['花花']='花花卡:BAAALgAECgQJBAAAAA==.',
['若拉']='若拉司晨:BAAALgAECgUJBQAAAA==.',
['英雄']='英雄之魂:BAAALgAFFAIJAgAAAA==.',
['茄茄']='茄茄是晴天:BAAALgAECgYJBgAAAA==.',
['草莓']='草莓胖次:BAAALgAECgYJCgAAAA==.',
['莫小']='莫小样是猪:BAABLgAFFH8HAAIPAAMJKhRaCwCSAAAPAAMJKhRaCwCSAAAAAA==.',
['菲菲']='菲菲灰灰:BAABLgAECn8XAAITAAYJUBMiiQBvAQATAAYJUBMiiQBvAQAAAA==.',
['萌萌']='萌萌哒灬老爬:BAAALgADCgUJBQAAAA==.',
['萝卜']='萝卜青菜:BAAALgAECgQJBAAAAA==.',
['蒋稻']='蒋稻礼:BAAALgAECgEJAQAAAA==.',
['蓝雨']='蓝雨:BAAALgADCgEJAQAAAA==.',
['蕾米']='蕾米羅亚:BAAALgAFFAIJBAABLgAFFAUJEAALAC8lAA==.',
['蚂蚁']='蚂蚁大强:BAAALgAECgEJAQAAAA==.',
['蝇火']='蝇火:BAABLgAECn8WAAIOAAkJHiJiAgCXAwAOAAkJHiJiAgCXAwAAAA==.',
['血之']='血之印记:BAAALgAECgEJAgAAAA==.',
['见证']='见证者:BAAALgAECgQJBAAAAA==.',
['言娴']='言娴雅:BAAALgAECgEJAgAAAA==.',
['训犬']='训犬师:BAAALgAECgYJCgAAAA==.',
['豆芽']='豆芽妹妹:BAAALgAECgUJBQAAAA==.',
['超火']='超火流星:BAABLgAECn8UAAIWAAgJcRbiJADbAQAWAAgJcRbiJADbAQABLgAFFAcJGAAQALojAA==.',
['路芽']='路芽:BAAALgADCgcJDQAAAA==.',
['路雅']='路雅:BAABLgAECn8WAAIRAAcJwRKsDwBWAQARAAcJwRKsDwBWAQAAAA==.',
['軳灰']='軳灰:BAAALgAECgYJCAAAAA==.',
['转奶']='转奶巨龙:BAAALgAECgQJBwAAAA==.',
['远游']='远游客:BAAALgADCgEJAQAAAA==.',
['逆转']='逆转的死神:BAAALgADCgEJAQAAAA==.',
['逐梦']='逐梦:BAAALgAECgEJAQAAAA==.',
['速啪']='速啪抛瓦:BAAALgAECgYJEwAAAA==.',
['遇箭']='遇箭:BAAALgAECgEJAQAAAA==.',
['道心']='道心不稳:BAAALgAECgYJBgAAAA==.',
['遗忘']='遗忘教主:BAAALgAECgcJBwAAAA==.',
['醉卧']='醉卧桃花源:BAAALgAECgIJAgAAAA==.',
['重光']='重光:BAAALgAFFAEJAQAAAA==.',
['钵兰']='钵兰街楠姐:BAAALgADCgQJBAAAAA==.',
['铃儿']='铃儿小丸子:BAAALgAECgQJBAAAAA==.',
['长明']='长明当月:BAAALgAECggJCAAAAA==.',
['阿古']='阿古斯逃亡者:BAAALgAFFAEJAQAAAA==.',
['阿尔']='阿尔萨丝:BAAALgAECgQJBgAAAA==.',
['阿布']='阿布喏喏:BAAALgAECgQJCQAAAA==.阿布是只哞:BAAALgAFFAQJAQAAAA==.',
['阿斯']='阿斯蒙迪斯:BAAALgAECgYJCwAAAA==.',
['阿法']='阿法:BAABLgAECn8cAAIXAAgJtCIkAQDfAgAXAAgJtCIkAQDfAgAAAA==.',
['阿渣']='阿渣奶奶:BAAALgAECgMJAwAAAA==.',
['阿释']='阿释密达:BAAALgAECgYJCQAAAA==.',
['陌路']='陌路繁花丶喵:BAAALgADCgMJAwAAAA==.',
['随风']='随风老贵:BAAALgAECgcJCwAAAA==.',
['雪碧']='雪碧丶青柠味:BAAALgADCgUJBQAAAA==.雪碧灬怪人:BAAALgAECgYJDAABLgAECgcJBwACAAAAAA==.',
['靓影']='靓影闪现:BAAALgADCgYJBwAAAA==.',
['非狼']='非狼勿说:BAAALgAECgEJAgAAAA==.',
['面面']='面面:BAAALgAECggJCAAAAA==.',
['项链']='项链精灵:BAABLgAFFH8FAAIYAAUJhAEAAAAAAAAGAAUJhAEAAAAAAAAAAA==.',
['風導']='風導星歌:BAAALgAECgQJAwAAAA==.',
['风动']='风动:BAAALgAECgcJEwAAAA==.',
['饲灵']='饲灵丸:BAAALgAECgcJBwAAAA==.',
['骑士']='骑士猫:BAAALgAFFAEJAgAAAA==.',
['骑德']='骑德龙咚墙:BAAALgAECgYJCwAAAA==.',
['高大']='高大形象:BAAALgAECgIJAgAAAA==.',
['魅影']='魅影佳人:BAAALgAECgEJAQAAAA==.',
['魅惑']='魅惑眾生:BAAALgADCgYJBgAAAA==.',
['鱼有']='鱼有荣焉:BAAALgAFFAEJAQAAAA==.',
['黎明']='黎明光年之外:BAAALgAECgQJBQAAAA==.',
['黑色']='黑色皮球:BAAALgADCgEJAQAAAA==.',
['龘大']='龘大龘:BAAALgADCgcJDQAAAA==.',
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
