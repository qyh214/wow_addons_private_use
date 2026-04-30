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

local lookup = {'Rogue-Assassination','Warrior-Fury','Warrior-Protection','Warrior-Arms','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Paladin-Holy','Paladin-Retribution','Shaman-Elemental','Shaman-Restoration','Hunter-BeastMastery','Rogue-Subtlety','Rogue-Outlaw','Evoker-Devastation','Priest-Shadow','Priest-Holy','Druid-Restoration','Priest-Discipline','DeathKnight-Unholy','Warlock-Affliction','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Paladin-Protection','Druid-Feral','Mage-Frost','Hunter-Survival',}
local provider = {region='CN',realm='影牙要塞',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abram:BAAALgADCgYJBgAAAA==.',
Ar='Archonn:BAAALgADCgIJAgAAAA==.Archons:BAAALgADCgUJBQAAAA==.',
Ba='Badrobin:BAAALgAECgMJBAAAAA==.',
Bl='Blackjack:BAAALgAECgMJAwAAAA==.Bladess:BAAALgAECgEJAQAAAA==.',
Ca='Candy:BAAALgAECgYJCAAAAA==.',
Co='Cosmas:BAAALgAECgYJDwAAAA==.',
Da='Damian:BAAALgADCgIJAQAAAA==.',
Do='Dosm:BAAALgAECgkJEgAAAA==.',
Dr='Driomograine:BAAALgADCgQJBAAAAA==.',
Er='Erthesmanath:BAAALgAECgEJAQAAAA==.',
Ev='Evankai:BAABLgAECn8VAAIBAAYJsBwTCADYAQABAAYJsBwTCADYAQAAAA==.Evansia:BAAALgAECgQJBAAAAA==.',
Fs='Fszz:BAAALgAECgIJAgAAAA==.',
Ga='Game:BAAALgAECgcJDAAAAA==.',
He='Hellsream:BAABLgAECn8UAAQCAAgJ8Rc4OADGAQACAAcJlBE4OADGAQADAAIJ3iMuLwDKAAAEAAEJPRFzOgBGAAAAAA==.',
Ic='Icemt:BAAALgAECgcJCAAAAA==.',
Ka='Kaylly:BAAALgADCgcJBwABLgAECgQJBAAFAAAAAA==.',
Ku='Kumo:BAAALgAFFAQJAwAAAA==.',
La='Lanceloot:BAAALgAFFAEJAQAAAA==.',
Ln='Lnteme:BAAALgAECgYJBgAAAA==.',
Lo='Lorewalkerz:BAAALgAECgYJCwABLgAECggJFAACAPEXAA==.',
Lu='Lucky:BAAALgAECgQJBQAAAA==.Luckysm:BAAALgADCgYJBgAAAA==.',
Ly='Lys:BAAALgAECgUJBwAAAA==.',
Ma='Macrohard:BAAALgAECgEJAQAAAA==.Madison:BAABLgAFFH8FAAMGAAMJGRHeOACiAAAGAAIJuRbeOACiAAAHAAEJ2AXrGABMAAAAAA==.',
Mm='Mmdd:BAAALgAECgYJBAAAAA==.',
Na='Naxxramas:BAAALgAECgMJCQAAAA==.',
No='Nohesitate:BAAALgADCgEJAQAAAA==.',
Or='Orange:BAAALgAECgcJEAAAAA==.',
Ov='Oversoul:BAAALgAECgEJAQAAAA==.',
Pa='Pamdarkness:BAAALgADCgcJBwAAAA==.',
Pe='Pein:BAAALgAECgYJBwAAAA==.',
Pi='Pinkblack:BAAALgAECgUJBQAAAA==.',
Pl='Playmx:BAAALgAECgMJAgAAAA==.',
Ra='Rammus:BAAALgAECggJCAAAAA==.Ranranb:BAAALgAECgYJCQAAAA==.',
Re='Redempt:BAABLgAFFH8FAAIIAAUJjButAgCiAQAIAAUJjButAgCiAQAAAA==.',
Ro='Roronoa:BAAALgAFFAEJAgAAAA==.',
Sa='Sasiki:BAAALgAFFAIJAgAAAA==.Saulh:BAAALgAECgkJDwAAAA==.',
Sc='Scarletholy:BAAALgADCgQJBAAAAA==.',
St='Stealthy:BAAALgAECgEJAQAAAA==.',
Ta='Tany:BAAALgAECgEJAQAAAA==.',
Th='Thetinyevil:BAAALgAECgUJBQABLgAECggJFAACAPEXAA==.',
To='Tonym:BAAALgAECgEJAQAAAA==.',
Ve='Vestige:BAAALgAECgMJAwAAAA==.',
Wi='Winterqaq:BAAALgAFFAQJBAAAAA==.',
Yu='Yunp:BAAALgAECgkJBQAAAA==.',
['一北']='一北风吹:BAABLgAECn8XAAMJAAYJhx9FKADrAQAJAAYJhx9FKADrAQAKAAYJLBijdgCNAQAAAA==.',
['一只']='一只小慢慢:BAAALgAECgYJCwAAAA==.一只逗比僧:BAAALgAECgIJAgAAAA==.',
['一品']='一品新茶:BAAALgAFFAQJAgAAAA==.',
['一秒']='一秒的安慰:BAAALgAECgcJDgAAAA==.',
['一笑']='一笑丶一尘缘:BAAALgAECgYJCAAAAA==.',
['七叶']='七叶重楼:BAAALgADCgUJBQAAAA==.',
['万华']='万华未央:BAAALgAECgUJCgAAAA==.',
['下个']='下个棋:BAAALgAECgIJAgAAAA==.',
['不知']='不知冬几许:BAAALgAFFAQJBAAAAA==.',
['且听']='且听风吟:BAAALgAECgEJAQAAAA==.',
['世界']='世界洛丹伦:BAAALgAECgQJBQAAAA==.',
['丨曼']='丨曼殊沙华丨:BAAALgAECgYJBgAAAA==.',
['丶元']='丶元亨利贞:BAAALgAECgEJAgAAAA==.',
['丶蕾']='丶蕾丝控:BAAALgAECgYJDgAAAA==.',
['久遠']='久遠寺有珠:BAAALgAECgIJAwAAAA==.',
['乌鸦']='乌鸦坐飞机:BAAALgAECgIJAgABLgAFFAMJAwAFAAAAAA==.乌鸦年少:BAAALgADCgQJBAAAAA==.',
['二丶']='二丶酱:BAAALgAECgEJAgAAAA==.',
['二酱']='二酱:BAAALgAECgUJCQAAAA==.',
['亭中']='亭中朴雪:BAAALgAECggJDgAAAA==.',
['他们']='他们心跳加快:BAAALgAFFAIJAwAAAA==.',
['以剑']='以剑为名:BAAALgAECgEJAQAAAA==.',
['以太']='以太贤者:BAAALgAFFAIJAwAAAA==.',
['伊丽']='伊丽丝:BAAALgAFFAQJBAAAAA==.',
['伊莎']='伊莎薇儿:BAAALgAECgMJBAAAAA==.',
['伊隆']='伊隆马斯克:BAAALgAECgEJAQAAAA==.',
['优点']='优点小可爱:BAAALgAECgQJCAAAAA==.',
['会武']='会武功的常威:BAAALgAECgEJAQAAAA==.',
['传说']='传说时间:BAAALgADCgQJBAAAAA==.',
['低调']='低调的召唤者:BAAALgAECgcJEwAAAA==.',
['佑曦']='佑曦:BAAALgAECgYJBgAAAA==.',
['佑罗']='佑罗:BAAALgADCgEJAQAAAA==.',
['何意']='何意味:BAACLgAFFH8NAAMLAAUJLAqeBQCBAQALAAUJLAqeBQCBAQAMAAQJuhb8BwBIAQAuAAQKfxUAAgwABwmwFpk0ALEBAAwABwmwFpk0ALEBAAAA.',
['你怕']='你怕我么:BAAALgAECgYJDAAAAA==.',
['依妹']='依妹儿:BAAALgAECgUJDQAAAA==.',
['依清']='依清:BAAALgAFFAIJAgAAAA==.',
['修女']='修女索妮娅:BAAALgAECgUJBwABLgAFFAYJCgAMAHYKAA==.',
['倾城']='倾城倾帼:BAAALgAECgYJBgAAAA==.',
['偷鸡']='偷鸡摸狗:BAAALgAECgYJCwAAAA==.',
['傲箭']='傲箭狂枪:BAAALgADCgYJBgAAAA==.',
['先打']='先打德:BAAALgAECgMJBAAAAA==.',
['光头']='光头:BAAALgADCgcJCAAAAA==.',
['六合']='六合飞蓬:BAAALgADCgEJAgAAAA==.',
['养由']='养由羿:BAAALgAECgQJBAAAAA==.',
['冈咲']='冈咲美保:BAAALgAECgcJBQAAAA==.',
['冰川']='冰川纱夜:BAAALgAECgcJBQAAAA==.',
['冷夜']='冷夜风满楼:BAAALgAECgUJBQAAAA==.',
['冷血']='冷血大圣:BAAALgAECgYJCQAAAA==.',
['出笙']='出笙之南:BAAALgADCgcJBwAAAA==.',
['别举']='别举报我:BAAALgAECgMJAwAAAA==.',
['十二']='十二级台风:BAAALgADCgYJBgAAAA==.',
['十年']='十年前的约定:BAAALgAECgIJAgAAAA==.',
['半夜']='半夜去偷蛇:BAAALgADCgcJBwAAAA==.',
['卡拉']='卡拉赞扫地僧:BAAALgAECgYJCQAAAA==.',
['双叶']='双叶杏:BAAALgAECgYJDAAAAA==.',
['双核']='双核心橙:BAAALgAECgEJAQAAAA==.',
['吕涅']='吕涅:BAAALgAECgUJCQAAAA==.',
['吹比']='吹比大师丶:BAAALgAECgYJCwABLgAFFAIJAgAFAAAAAA==.',
['咒心']='咒心:BAAALgAECgYJEwAAAA==.',
['咕咕']='咕咕嘎嘎:BAABLgAFFH8JAAILAAUJGgkxBgB3AQALAAUJGgkxBgB3AQAAAA==.',
['哇哇']='哇哇大叫:BAAALgAECgYJBgABLgAFFAUJCQANAMwQAA==.',
['哼哼']='哼哼熊:BAAALgAECgIJAgAAAA==.',
['唯美']='唯美记忆:BAAALgADCgEJAQAAAA==.',
['嗷丶']='嗷丶呜:BAAALgAECgcJDQAAAA==.',
['图那']='图那样:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光啊老兄:BAAALgAECgEJAQAAAA==.',
['地獄']='地獄咆哮:BAAALgADCgcJBgAAAA==.',
['垌房']='垌房不敗:BAAALgAECgQJBAAAAA==.',
['塞雷']='塞雷西亚:BAAALgAECgEJAgAAAA==.',
['夏灬']='夏灬梦僧:BAAALgAECgYJCgAAAA==.夏灬梦墨:BAAALgADCgIJAgAAAA==.夏灬梦懿:BAAALgAFFAIJAwAAAA==.夏灬梦落:BAAALgAECgQJAwAAAA==.夏灬梦葉:BAAALgAECgYJBwAAAA==.夏灬梦述:BAABLgAFFH8HAAIGAAMJDxARJADzAAAGAAMJDxARJADzAAAAAA==.夏灬梦陨:BAAALgAECgEJAQAAAA==.',
['夜刀']='夜刀神:BAAALgAECgYJBgAAAA==.',
['夜的']='夜的第七章丶:BAAALgADCgIJAgAAAA==.',
['大叔']='大叔随心:BAAALgAECgYJCQAAAA==.',
['大建']='大建路过:BAAALgAECgMJAwAAAA==.',
['天权']='天权:BAABLgAFFH8HAAILAAUJhwlBBwBlAQALAAUJhwlBBwBlAQAAAA==.',
['头上']='头上有崎角:BAAALgAFFAIJBAAAAA==.',
['奥臣']='奥臣黯魂:BAAALgAECgEJAQAAAA==.',
['孤岳']='孤岳:BAAALgAFFAEJAgAAAA==.',
['家园']='家园绝影:BAAALgAECgEJAwAAAA==.',
['密勒']='密勒頓:BAAALgAECgUJBQAAAA==.',
['射不']='射不出的温柔:BAAALgAECgUJAQAAAA==.',
['小九']='小九号:BAAALgAECgEJAQAAAA==.',
['小凯']='小凯特:BAAALgAECgEJAQAAAA==.',
['小匕']='小匕宅子:BAAALgAECgYJCwAAAA==.',
['小医']='小医仙:BAAALgADCgEJAQAAAA==.',
['小奶']='小奶酪君儿:BAAALgAECgQJBAAAAA==.',
['小影']='小影爸爸:BAAALgAECgQJCAAAAA==.',
['小早']='小早川凛子:BAAALgAECgMJAwAAAA==.',
['小步']='小步舞曲:BAACLgAFFH8PAAILAAQJNxVFAwA/AQALAAQJNxVFAwA/AQAuAAQKfxkAAgsACAnhHQYYAFYCAAsACAnhHQYYAFYCAAAA.',
['小毛']='小毛坨:BAAALgAECggJDwAAAA==.',
['小浣']='小浣熊干脆面:BAAALgAECgYJCAAAAA==.',
['小清']='小清水亚美:BAAALgADCgUJBQAAAA==.',
['小破']='小破弓:BAACLgAFFH8GAAINAAMJNBa7GgCaAAANAAMJNBa7GgCaAAAuAAQKfxUAAg0ACQlmFhMiADkCAA0ACQlmFhMiADkCAAAA.',
['小豆']='小豆芽:BAAALgAECgYJBgAAAA==.',
['小镇']='小镇的流逝:BAABLgAECn8ZAAQOAAYJaRN6LQCVAQAOAAYJRhN6LQCVAQABAAQJwwqkFACxAAAPAAEJAABCDwAsAAAAAA==.',
['尽是']='尽是风流:BAAALgAECgYJDwAAAA==.',
['山顶']='山顶的黑狗兄:BAAALgAECgQJAwAAAA==.',
['布布']='布布女王殿下:BAAALgAFFAEJAQAAAA==.',
['布莱']='布莱克凯特:BAAALgAECgEJAQAAAA==.',
['布里']='布里兹丶:BAAALgAFFAQJBAAAAA==.',
['干达']='干达各:BAAALgADCgcJBwAAAA==.',
['幽丷']='幽丷紫瞳:BAAALgADCgEJAQAAAA==.',
['幽兰']='幽兰胜雪:BAAALgAECgYJBwAAAA==.',
['幽冥']='幽冥幻:BAAALgAECgYJEgAAAA==.',
['库啵']='库啵果好吃哦:BAAALgAECgYJDAAAAA==.',
['开阳']='开阳:BAACLgAFFH8IAAMMAAQJ+g1oCgAvAQAMAAQJ+g1oCgAvAQALAAQJIQncDAAgAQAuAAQKfxUAAgwABwlbHpAeACgCAAwABwlbHpAeACgCAAAA.',
['强力']='强力骑士壹:BAABLgAFFH8FAAIJAAUJdQhFBgB0AQAJAAUJdQhFBgB0AQABLgAFFAYJBgAQAAkSAA==.',
['德之']='德之道:BAAALgADCgUJCgAAAA==.',
['德制']='德制翼:BAABLgAECn8YAAMRAAYJchXSKwB+AQARAAYJchXSKwB+AQASAAMJkRlibQBzAAAAAA==.',
['德神']='德神薛仁贵:BAABLgAFFH8IAAITAAQJwxZ2BABCAQATAAQJwxZ2BABCAQAAAA==.',
['心御']='心御丨圣裁:BAAALgADCgIJAgAAAA==.',
['态变']='态变小个一:BAAALgAECgEJAQABLgAECgEJAQAFAAAAAA==.态变老个一:BAAALgAECgEJAQAAAA==.',
['思念']='思念亦是泪:BAAALgAECgQJBAAAAA==.',
['思淰']='思淰弈是泪:BAAALgAECgEJAQAAAA==.思淰洂是泪:BAAALgAECgUJBQAAAA==.',
['性感']='性感舞男:BAAALgAECgEJAQAAAA==.',
['恐怖']='恐怖:BAAALgAECgQJCAAAAA==.',
['情非']='情非丶:BAAALgAFFAMJAwAAAA==.',
['憋叨']='憋叨叨:BAAALgAECgcJCAAAAA==.',
['我不']='我不想玩奶:BAAALgAECgEJAQAAAA==.我不是伊利:BAAALgADCgEJAgAAAA==.',
['我热']='我热很热:BAAALgADCgUJBQAAAA==.',
['我的']='我的刀盾:BAABLgAFFH8NAAMLAAUJqRPdBACSAQALAAUJqRPdBACSAQAMAAQJ6BPyBwBIAQAAAA==.',
['我说']='我说疼没说停:BAAALgAFFAIJAwAAAA==.',
['我还']='我还是很牛:BAAALgADCgEJAQAAAA==.',
['扛住']='扛住奶住猛砍:BAAALgADCgIJAgAAAA==.',
['执政']='执政少女:BAABLgAFFH8FAAIUAAUJBBUyBACtAQAUAAUJBBUyBACtAQAAAA==.',
['抹不']='抹不掉的伤:BAAALgAECgIJAgAAAA==.',
['抽烟']='抽烟加喝酒:BAAALgADCgUJBQAAAA==.',
['挽弓']='挽弓射沙雕:BAAALgAECgIJAgAAAA==.',
['捌拾']='捌拾捌:BAAALgADCgEJAQAAAA==.',
['换个']='换个姿势:BAAALgAECgcJBwAAAA==.',
['提默']='提默斯奥丁:BAAALgAFFAEJAQAAAA==.',
['撷芳']='撷芳绘岚霞:BAABLgAFFH8NAAMLAAUJTRVHBAChAQALAAUJTRVHBAChAQAMAAQJdhJvCQA6AQAAAA==.',
['撼地']='撼地神牛:BAAALgAECgIJAwAAAA==.',
['文曲']='文曲星下界:BAAALgAFFAQJBAAAAA==.',
['日落']='日落归山海:BAAALgAECgEJAgAAAA==.',
['时无']='时无忧:BAAALgAECgYJBQAAAA==.',
['明月']='明月笑春风:BAAALgAECgYJBwAAAA==.',
['昔曰']='昔曰鸣响:BAAALgAECgUJCQAAAA==.',
['星期']='星期八的大神:BAAALgAFFAEJAQAAAA==.',
['星汉']='星汉落玉盘:BAAALgAECggJCAAAAA==.',
['星祭']='星祭:BAAALgAECgEJAwAAAA==.',
['時小']='時小雨丶:BAAALgAECgQJCgABLgAECggJFAACAPEXAA==.',
['普通']='普通的小刚:BAAALgAECgUJCAAAAA==.',
['暗夜']='暗夜守望:BAAALgAECgYJCAAAAA==.',
['暗月']='暗月星星:BAAALgAECgYJBgAAAA==.',
['暴击']='暴击红颜:BAAALgAECgYJBgAAAA==.',
['暴風']='暴風雨的呼喚:BAAALgAECgYJBgAAAA==.',
['曹梦']='曹梦德:BAAALgAECgEJAQAAAA==.',
['月面']='月面兎灬兵器:BAAALgAECgcJDQAAAA==.',
['木下']='木下秀吉:BAAALgAECgQJBgAAAA==.',
['朱雀']='朱雀七宿一井:BAAALgAECgUJBgAAAA==.朱雀七宿一星:BAAALgADCgEJAQAAAA==.朱雀七宿一翼:BAAALgAFFAIJBAAAAA==.',
['朴实']='朴实无华:BAAALgAECgQJCgAAAA==.',
['李尺']='李尺泾:BAABLgAFFH8JAAMVAAUJkBLcFQBMAQAVAAQJkBLcFQBMAQAIAAEJAAAhFwA+AAAAAA==.',
['李清']='李清虹:BAAALgAFFAMJAwAAAA==.',
['李渊']='李渊蛟:BAABLgAFFH8HAAMVAAUJhRexFABQAQAVAAQJhRexFABQAQAIAAEJAAAgFgBBAAAAAA==.',
['李玄']='李玄岭:BAAALgAFFAMJAwAAAA==.李玄锋:BAABLgAFFH8FAAMVAAUJbRYhEQBdAQAVAAQJbRYhEQBdAQAIAAEJAADQFwA8AAAAAA==.',
['李通']='李通崖:BAABLgAFFH8JAAMVAAUJKxJaFwBHAQAVAAQJKxJaFwBHAQAIAAEJAADxGQA1AAAAAA==.',
['果冻']='果冻猫喵:BAAALgAECgcJBwAAAA==.',
['枫舞']='枫舞丨湮灭:BAAALgADCgYJBgAAAA==.',
['枭龙']='枭龙银:BAAALgAECgQJBAAAAA==.',
['柒柒']='柒柒啾啾:BAAALgAFFAEJAQAAAA==.',
['柠檬']='柠檬不萌丶:BAAALgAECgcJBgAAAA==.',
['柴可']='柴可夫斯基:BAAALgAECgQJBQAAAA==.',
['桂馥']='桂馥兰香:BAACLgAFFH8MAAMGAAQJoB+YCwB/AQAGAAQJoB+YCwB/AQAHAAEJBhbsAwBfAAAuAAQKfxUABAYACAnwHvdOANsBAAYABwkCHvdOANsBAAcAAwleEBVFAKEAABYAAQkAAO8oAE4AAAAA.',
['梅琳']='梅琳娜的锋刃:BAABLgAFFH8JAAMIAAIJ1RQOBwCAAAAIAAIJ1RQOBwCAAAAVAAEJShEOVQBOAAAAAA==.',
['梵高']='梵高:BAAALgAFFAEJAQAAAA==.',
['棒棒']='棒棒德:BAAALgAECgEJAwAAAA==.',
['森亚']='森亚露露卡:BAAALgAFFAQJBAAAAA==.',
['榜一']='榜一大哥:BAAALgADCgcJCwAAAA==.',
['欣赏']='欣赏我的丑:BAAALgADCgYJBgAAAA==.欣赏我的坏:BAAALgAFFAMJAwAAAA==.欣赏我的蠢:BAAALgAECgQJBgAAAA==.',
['此生']='此生忘不掉:BAAALgAECgEJAQAAAA==.',
['死靈']='死靈若龍:BAAALgAECgYJEAAAAA==.',
['比比']='比比拉布:BAABLgAFFH8IAAMMAAQJ5RSgCABBAQAMAAQJ5RSgCABBAQALAAQJxQiODAAlAQAAAA==.',
['气得']='气得发疯:BAAALgADCgEJAQAAAA==.',
['水之']='水之加罗温:BAAALgADCgcJCAAAAA==.',
['水杯']='水杯泡枸杞:BAABLgAFFH8FAAIMAAUJIBtKAgDEAQAMAAUJIBtKAgDEAQAAAA==.',
['水色']='水色铃兰:BAAALgADCgYJBgAAAA==.',
['浅唱']='浅唱依月:BAAALgAECgMJAwAAAA==.',
['浪漫']='浪漫卜多餘:BAAALgADCgIJAgAAAA==.',
['海角']='海角丶天涯:BAAALgADCgIJAgAAAA==.',
['涉水']='涉水谭梅:BAAALgAECgEJAQAAAA==.',
['清规']='清规戒律:BAAALgAECgEJAQAAAA==.',
['清风']='清风晓岚:BAAALgADCgUJBQAAAA==.清风茉白丶:BAAALgAFFAEJAQAAAA==.',
['滋滋']='滋滋怪:BAAALgAECgQJBAAAAA==.',
['滑稽']='滑稽的波波:BAAALgAFFAEJAgAAAA==.',
['灬辣']='灬辣辣灬:BAAALgAFFAQJBAAAAA==.',
['灵弦']='灵弦:BAAALgAECgYJBwAAAA==.',
['烙禋']='烙禋:BAAALgADCgcJBwAAAA==.',
['烟花']='烟花等等哥丶:BAABLgAECn8UAAQXAAcJkBPWIQCmAQAXAAcJkBPWIQCmAQAYAAQJRQSLXQCaAAAZAAEJlxQTIwA9AAAAAA==.',
['熊丿']='熊丿猫:BAAALgADCgkJEgAAAA==.',
['熊掌']='熊掌奶酪:BAAALgAECgcJEgAAAA==.',
['熊本']='熊本熊大:BAAALgADCgYJBgABLgAECgYJBgAFAAAAAA==.',
['燃烧']='燃烧的丶胸毛:BAAALgADCgEJAQAAAA==.',
['爱吃']='爱吃辣椒的猫:BAAALgADCgEJAQAAAA==.',
['爱悉']='爱悉尼的小学:BAAALgADCgIJAgAAAA==.',
['爱罗']='爱罗:BAAALgAFFAIJAgAAAA==.',
['爸爸']='爸爸:BAAALgAECgcJCwAAAA==.',
['狂血']='狂血之战:BAAALgAECgUJBgAAAA==.',
['独自']='独自守夜:BAAALgAFFAQJBAAAAA==.',
['狸沫']='狸沫:BAAALgAECgcJBwAAAA==.',
['狼魂']='狼魂之影:BAABLgAECn8VAAMaAAYJyR/wCwAKAgAaAAYJyR/wCwAKAgAKAAUJuxjqrgAlAQAAAA==.',
['猿神']='猿神牛彼:BAAALgAFFAQJBAAAAA==.',
['玲珑']='玲珑魅:BAABLgAFFH8IAAIMAAMJDx7FCgArAQAMAAMJDx7FCgArAQABLgAFFAcJBwARACQaAA==.',
['璀璨']='璀璨丶晨曦:BAAALgADCgIJAgABLgAECgYJGAARAHIVAA==.',
['瓜一']='瓜一:BAAALgAECgUJBgAAAA==.',
['瓜三']='瓜三瓜:BAAALgAECgQJDAAAAA==.',
['瓜啊']='瓜啊瓜:BAAALgAECgYJCwAAAA==.',
['瓦伦']='瓦伦蒂诺公爵:BAAALgAECgIJAwAAAA==.',
['瓦里']='瓦里安丶瑞恩:BAAALgAECgEJAQAAAA==.',
['甩手']='甩手掌柜:BAABLgAECn8hAAIbAAcJ/Bc6DQDkAQAbAAcJ/Bc6DQDkAQABLgAFFAcJHAAcAKwbAA==.',
['电动']='电动疯子:BAAALgAECgQJBAAAAA==.',
['疯子']='疯子不疯:BAAALgAECgQJBAAAAA==.',
['疯狂']='疯狂大保健:BAAALgAFFAQJBAAAAA==.',
['白血']='白血公主:BAABLgAECn8XAAIcAAkJuSARAQALAwAcAAkJuSARAQALAwAAAA==.',
['真不']='真不系大叔:BAAALgADCgMJBgAAAA==.',
['神圣']='神圣的职业:BAAALgAECgEJAgAAAA==.',
['离殇']='离殇灵异:BAAALgADCgIJAgAAAA==.',
['秘制']='秘制烤鸡翅:BAAALgAECgEJAQAAAA==.',
['等待']='等待未名:BAAALgAFFAIJBAAAAA==.',
['箭血']='箭血封喉:BAAALgAECgEJAgAAAA==.',
['米饭']='米饭黄焖基:BAACLgAFFH8MAAIOAAUJmBroAgDPAQAOAAUJmBroAgDPAQAuAAQKfyYAAg4ACAmhI8kGACQDAA4ACAmhI8kGACQDAAAA.',
['粉野']='粉野猪:BAAALgAFFAUJAgAAAA==.',
['精神']='精神科主任:BAAALgAECgQJBAAAAA==.',
['紫川']='紫川码农:BAAALgADCgcJBwAAAA==.',
['繁星']='繁星丶春水:BAAALgAECgYJBgAAAA==.',
['纾糖']='纾糖:BAAALgAECgcJCAAAAA==.',
['维多']='维多俩的豆腐:BAAALgAFFAIJBAAAAA==.',
['维娜']='维娜:BAAALgAECgEJAQAAAA==.',
['美少']='美少女月火菟:BAAALgAECgQJBAAAAA==.',
['美食']='美食的俘虏:BAAALgAECgEJAQAAAA==.',
['耀世']='耀世战神:BAAALgAECgUJBQAAAA==.',
['老鸡']='老鸡奇遇记:BAAALgADCgIJAgAAAA==.',
['联盟']='联盟第一奶爸:BAAALgAECgIJAQAAAA==.',
['胧隐']='胧隐:BAAALgADCgUJBQAAAA==.',
['艾姆']='艾姆威痞:BAAALgAECgEJAQAAAA==.',
['艾尒']='艾尒熙德:BAAALgADCgMJAwAAAA==.',
['艾斯']='艾斯汀:BAAALgAECgYJBgAAAA==.',
['艾琳']='艾琳语风:BAAALgAECgEJAQAAAA==.',
['苦痛']='苦痛冈布奥:BAAALgAFFAIJAgAAAA==.',
['菲比']='菲比啾比:BAABLgAFFH8IAAILAAQJFwjnDAAfAQALAAQJFwjnDAAfAQAAAA==.',
['萌兽']='萌兽侠:BAAALgAECgYJCQAAAA==.',
['萌小']='萌小萌:BAAALgADCgIJAgAAAA==.',
['萌萌']='萌萌布布酱:BAAALgAECgYJCgAAAA==.',
['萝莉']='萝莉的时间:BAABLgAFFH8FAAICAAMJLBEmBwDlAAACAAMJLBEmBwDlAAAAAA==.',
['落红']='落红尘:BAAALgAECgIJAgAAAA==.',
['蓉火']='蓉火之心:BAAALgAECgIJAgAAAA==.',
['血花']='血花飞溅:BAAALgAECgUJBQAAAA==.血花飞灄:BAABLgAFFH8FAAIaAAIJaQmtBQBnAAAaAAIJaQmtBQBnAAAAAA==.',
['詞嘲']='詞嘲灵异:BAAALgADCgEJAQAAAA==.',
['请叫']='请叫我锤哥吧:BAABLgAECn8gAAIaAAcJIhDTFgBnAQAaAAcJIhDTFgBnAQAAAA==.',
['诺风']='诺风:BAAALgAFFAQJAQAAAA==.',
['豆腐']='豆腐丨表弟:BAAALgAECgYJBgAAAA==.豆腐丶表弟:BAAALgAECgYJBgABLgAECgYJBgAFAAAAAA==.豆腐姐姐:BAAALgAFFAIJBAAAAA==.',
['贝贝']='贝贝熊:BAAALgAECgEJAQAAAA==.',
['蹦蹦']='蹦蹦跳跳:BAAALgAFFAIJAwAAAA==.',
['轩辕']='轩辕红木棉:BAAALgAECgUJBQAAAA==.',
['迅影']='迅影贼:BAAALgAECgEJAQAAAA==.',
['过江']='过江武神:BAAALgAFFAEJAQAAAA==.',
['酆都']='酆都北阴大帝:BAAALgADCgEJAQAAAA==.',
['酒酿']='酒酿的熊猫:BAACLgAFFH8LAAIZAAQJiyCmBACMAQAZAAQJiyCmBACMAQAuAAQKfxwAAhkACAnsJJcIAP0CABkACAnsJJcIAP0CAAAA.酒酿的猎:BAAALgAECgUJBQAAAA==.酒酿的龙:BAAALgADCgUJBQAAAA==.',
['醉红']='醉红颜:BAAALgAECgYJCQAAAA==.',
['野兽']='野兽追猎者:BAABLgAECn8UAAIdAAYJghkEEgCiAQAdAAYJghkEEgCiAQAAAA==.',
['量尺']='量尺天涯:BAAALgAECgcJBwABLgAFFAUJCQADALUOAA==.',
['鈴鈴']='鈴鈴:BAAALgAECgYJBgAAAA==.',
['铃兰']='铃兰:BAAALgADCgEJAQAAAA==.',
['银月']='银月城热巴:BAAALgAECgUJBQAAAA==.',
['锡兰']='锡兰:BAAALgAECgMJAwAAAA==.',
['长谷']='长谷川育美:BAAALgADCgYJBgAAAA==.',
['闪现']='闪现不撞墙:BAAALgAECgUJBQAAAA==.',
['阝方']='阝方馬奇:BAAALgAECgIJAwAAAA==.',
['阳光']='阳光丽影:BAAALgAFFAIJAgAAAA==.',
['阿奎']='阿奎利亚斯:BAAALgADCgIJAgAAAA==.',
['阿尔']='阿尔忒蜜斯:BAAALgAECgEJAQAAAA==.',
['阿梨']='阿梨丶:BAAALgAFFAQJBAAAAA==.',
['雪雪']='雪雪:BAAALgADCgYJBgAAAA==.',
['非暗']='非暗夜:BAAALgAECgkJBwAAAA==.',
['韭菜']='韭菜小迷糊:BAAALgAECgcJCAAAAA==.',
['风一']='风一样的老头:BAAALgAECgEJAgAAAA==.',
['风吹']='风吹起了从前:BAAALgAECgYJCQAAAA==.',
['风神']='风神雪:BAAALgAECgEJAQAAAA==.',
['风自']='风自东来:BAAALgAECgYJCQAAAA==.',
['风雪']='风雪月花:BAAALgAECgYJBgAAAA==.',
['风骚']='风骚的小蝴蝶:BAABLgAFFH8GAAIcAAMJPRpuKgALAQAcAAMJPRpuKgALAQAAAA==.',
['飘柔']='飘柔:BAAALgAFFAIJAgAAAA==.',
['高义']='高义:BAAALgAECgYJCwAAAA==.',
['魔猎']='魔猎:BAAALgAECgEJAQAAAA==.',
['魔道']='魔道祖师:BAAALgAECgQJBAAAAA==.',
['鱼尔']='鱼尔萨斯:BAAALgAECgkJBgAAAA==.',
['麒麟']='麒麟肥肥:BAAALgAECgQJBAAAAA==.',
['黄泉']='黄泉木:BAAALgAECgQJBAAAAA==.',
['黑小']='黑小子:BAAALgADCgYJBgAAAA==.',
['黑疯']='黑疯鬼:BAAALgAECgEJAQAAAA==.',
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
