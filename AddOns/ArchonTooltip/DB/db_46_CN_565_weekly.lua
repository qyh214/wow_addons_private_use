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

local lookup = {'Mage-Frost','Warlock-Demonology','Unknown-Unknown','DeathKnight-Unholy','Shaman-Elemental','DeathKnight-Frost','DeathKnight-Blood','Paladin-Retribution','DemonHunter-Devourer','Paladin-Holy','Shaman-Restoration','DemonHunter-Havoc','Evoker-Preservation','Priest-Discipline','Evoker-Augmentation','Hunter-BeastMastery','Warlock-Destruction','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Priest-Shadow','Priest-Holy','Warrior-Arms','Warrior-Fury','Rogue-Subtlety','Warrior-Protection','Mage-Fire','Druid-Guardian','Paladin-Protection','Evoker-Devastation','Warlock-Affliction','Hunter-Survival','Monk-Brewmaster','DemonHunter-Vengeance','Warrior-Melee',}
local provider = {region='CN',realm='亚雷戈斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Actual:BAAALgAECgEJAgAAAA==.',
Ag='Agic:BAABLgAFFH8FAAIBAAMJ9B0AJAAnAQABAAMJ9B0AJAAnAQAAAA==.',
Al='Alfimi:BAAALgAFFAEJAgAAAA==.Alucardlz:BAAALgAECgYJCgAAAA==.',
An='Angelhood:BAAALgADCgEJAQAAAA==.',
Ao='Aoe:BAAALgAECgQJBAAAAA==.',
Ba='Baily:BAAALgAECgYJBgAAAA==.Banmark:BAAALgADCgEJAQAAAA==.',
Be='Bearkid:BAAALgAFFAIJAwAAAA==.',
Bo='Boee:BAABLgAFFH8FAAICAAIJ/QadGgCcAAACAAIJ/QadGgCcAAAAAA==.',
Bu='Bunraku:BAAALgAECgEJAwAAAA==.',
Ca='Caiotte:BAAALgAECgIJAgAAAA==.',
Cc='Cckingdk:BAAALgADCgMJAwAAAA==.Cckingg:BAAALgAFFAEJAQAAAA==.Cckingqs:BAAALgAECgEJAQAAAA==.',
Ce='Centerchen:BAAALgAFFAIJAgAAAA==.',
Ch='Charizard:BAAALgAECgYJBwAAAA==.',
Cl='Clerith:BAAALgADCgYJCQAAAA==.',
Da='Danity:BAAALgAECgIJAwAAAA==.',
De='Deliyars:BAAALgAECgEJAQABLgAECgEJAgADAAAAAA==.Deviltoangel:BAAALgAECgYJBgAAAA==.',
Di='Diri:BAAALgADCgYJBwAAAA==.',
Dr='Dreadreaper:BAABLgAFFH8HAAIEAAIJTh/AMwC6AAAEAAIJTh/AMwC6AAAAAA==.',
Dz='Dz:BAAALgAECgYJBgAAAA==.',
El='Elickfs:BAAALgAECgEJAgAAAA==.',
Eu='Eunoia:BAAALgAECgYJBgAAAA==.',
Fi='Fishgrey:BAAALgAFFAEJAQAAAA==.',
Fo='Foe:BAAALgAFFAEJAQAAAA==.',
Fu='Furina:BAAALgAECgIJAgAAAA==.',
Gr='Graved:BAAALgAFFAEJAQAAAA==.',
Ha='Hanhanred:BAABLgAFFH8IAAIBAAUJ0SHnBQADAgABAAUJ0SHnBQADAgAAAA==.',
He='Hellcat:BAAALgADCgUJCQAAAA==.',
Is='Isosio:BAAALgAECgMJAwAAAA==.',
Jo='Jonathanpp:BAABLgAECn8UAAIFAAYJsB37JwDTAQAFAAYJsB37JwDTAQAAAA==.Joyel:BAAALgAECgUJDAAAAA==.',
Ka='Kaiing:BAAALgAECgEJAQAAAA==.Kalpa:BAAALgAECgYJCQAAAA==.',
Ko='Kouun:BAAALgAFFAQJAgAAAA==.',
Lb='Lbyxiolusumh:BAAALgAFFAQJBAAAAA==.',
Le='Lemonduel:BAAALgAECgEJAQAAAA==.Lemonripa:BAAALgAECgIJAgAAAA==.',
Lg='Lgcy:BAABLgAECn8bAAQEAAgJFwzhEgB8AQAEAAgJYwfhEgB8AQAGAAcJegUrCgAtAQAHAAQJOBHGLQDRAAAAAA==.',
Li='Lijingzhou:BAABLgAFFH8NAAIIAAQJSRFsDABIAQAIAAQJSRFsDABIAQAAAA==.',
Lo='Lovereo:BAAALgAECgcJBgAAAA==.',
Ly='Lyliasara:BAAALgAECgIJAgAAAA==.',
['Lô']='Lôtus:BAACLgAFFH8SAAMHAAUJ+SGFAQDlAQAHAAUJaiCFAQDlAQAEAAQJiR+lCQCEAQAuAAQKfxoAAwQACQnuIpAEAIsDAAQACQmoIpAEAIsDAAcAAwnAF40rAOIAAAAA.',
Ma='Magon:BAAALgADCgIJAgAAAA==.Maps:BAABLgAECn8UAAIEAAYJryA3WADpAQAEAAYJryA3WADpAQAAAA==.Mattemmons:BAAALgAECgYJCgAAAA==.',
Md='Mdzzsql:BAAALgADCgUJBQAAAA==.',
Me='Meister:BAAALgADCgUJBQAAAA==.',
Mi='Mikeyholy:BAAALgADCgYJBgAAAA==.Mikeylove:BAAALgAECgYJCwAAAA==.Milet:BAAALgAFFAIJAgAAAA==.Miniaqs:BAAALgADCgcJBwAAAA==.Misty:BAAALgAFFAIJBAAAAA==.',
Mo='Mockingbird:BAAALgAECgMJAwAAAA==.',
Ms='Mswind:BAAALgADCgcJDgAAAA==.',
Mu='Mumudh:BAABLgAFFH8FAAIJAAMJBRNtDQDxAAAJAAMJBRNtDQDxAAAAAA==.Mumulrr:BAAALgAFFAIJAwAAAA==.',
Ni='Niuniuqs:BAAALgAECgEJAQAAAA==.',
Ob='Obwan:BAAALgADCgYJBgAAAA==.',
Oc='Ocasjldasd:BAAALgAECgEJAQAAAA==.',
Oi='Oiiend:BAAALgAFFAEJAQABLgAFFAIJBQACAM4gAA==.',
On='Onionyang:BAABLgAECn8YAAMIAAgJqgv5bACjAQAIAAgJqgv5bACjAQAKAAYJ3QsAWAAcAQAAAA==.Onlythedevil:BAAALgAECgkJCQAAAA==.Onmbby:BAACLgAFFH8HAAMFAAIJFREECgCeAAAFAAIJFREECgCeAAALAAEJ5RRKIgBJAAAuAAQKfxYAAwsABwlOGUY/AIQBAAsABgm+GUY/AIQBAAUABAmmFSxUAPQAAAEuAAUUBwkFAAEA0gYA.',
Oo='Oouoo:BAAALgADCgUJBQAAAA==.',
Os='Ostar:BAAALgAECgQJBAAAAA==.',
Ou='Oudasheng:BAAALgAFFAEJAQAAAA==.',
Ph='Phainon:BAAALgAECgcJDQAAAA==.',
Pi='Pien:BAAALgAECgMJAwAAAA==.',
Pr='Prophecy:BAAALgAECgYJEgAAAA==.',
Ra='Ravenlord:BAAALgAECgUJAQAAAA==.Ravenmonk:BAAALgADCgcJBwAAAA==.Ravenshaman:BAAALgADCgcJBwABLgADCgcJBwADAAAAAA==.',
Re='Rebornb:BAAALgAECgEJAQAAAA==.Remotmt:BAABLgAFFH8HAAIMAAQJrSMbAAC0AQAMAAQJrSMbAAC0AQAAAA==.Renascence:BAAALgADCgUJBQAAAA==.Resolution:BAAALgAECgYJBgAAAA==.',
Rh='Rhaegal:BAABLgAECn8UAAINAAcJ0QbSJwA1AQANAAcJ0QbSJwA1AQAAAA==.',
Ri='Riverfish:BAAALgAFFAEJAQAAAA==.',
Rm='Rmp:BAAALgAFFAMJAwABLgAFFAgJGgABAHwmAA==.',
Ro='Rosaceea:BAAALgAECgkJDAAAAA==.',
Se='Serlliya:BAAALgAECgEJAgAAAA==.Setemper:BAAALgAFFAUJBAAAAA==.',
Sg='Sgst:BAABLgAECn8aAAIBAAgJkQ6xIQBMAQABAAgJkQ6xIQBMAQAAAA==.',
Si='Silverki:BAAALgAECgEJAQAAAA==.',
Sn='Snafu:BAAALgADCgQJBAAAAA==.',
So='Soldo:BAABLgAFFH8GAAIOAAMJGxL+DQDsAAAOAAMJGxL+DQDsAAAAAA==.Soraka:BAAALgAECgQJBAAAAA==.',
St='Starevoker:BAAALgAECgcJDQAAAA==.Starfired:BAAALgAECgEJAQAAAA==.Starxing:BAAALgAFFAIJBAABLgAFFAQJBwAPAJcQAA==.Starxingxing:BAAALgAFFAQJBAABLgAFFAQJBwAPAJcQAA==.Staryears:BAAALgADCgcJBwAAAA==.',
Su='Summertea:BAABLgAFFH8KAAIEAAMJaRv4JgD7AAAEAAMJaRv4JgD7AAAAAA==.Sunomika:BAAALgADCgEJAQABLgAFFAYJDAAQAJ8SAA==.Surt:BAAALgAECgQJBAAAAA==.',
Sw='Swellfun:BAAALgAECgYJBwAAAA==.',
Th='Thebug:BAACLgAFFH8LAAMCAAQJew0LEADzAAACAAMJxg4LEADzAAARAAEJmAloFwBQAAAuAAQKfx0AAwIACQmsGEdVAMgBAAIACAkQF0dVAMgBABEAAwlNF5s4ANIAAAAA.',
Tm='Tmac:BAAALgAECgMJBAAAAA==.Tmess:BAAALgAECgcJDwAAAA==.',
Ud='Udgirl:BAAALgADCgIJAgAAAA==.',
Un='Universe:BAACLgAFFH8VAAMSAAYJRxvLAAA7AgASAAYJRxvLAAA7AgATAAEJMQ6FDABNAAAuAAQKfyMAAhIACAmDJN0FAC8DABIACAmDJN0FAC8DAAAA.',
Uu='Uuz:BAAALgADCgEJAQAAAA==.',
Vi='Victorchenwy:BAAALgADCgYJBAAAAA==.',
Wu='Wumuclaudius:BAAALgAECgEJAQAAAA==.',
Xi='Xianyup:BAAALgAECgMJAwAAAA==.Xiaoxiaowei:BAAALgADCgEJAQAAAA==.',
Ya='Yaaoo:BAAALgAECgYJBgAAAA==.',
Yi='Yinshengua:BAAALgAECgEJAQAAAA==.',
Yo='Youyii:BAAALgAECgYJDAAAAA==.',
Yu='Yukina:BAAALgAECgMJAwAAAA==.',
Yz='Yzh:BAAALgADCgQJBAAAAA==.',
['一切']='一切都是重来:BAABLgAECn8UAAMSAAgJ+hkhHQBUAgASAAgJ+hkhHQBUAgATAAQJNBvxFQCmAAAAAA==.',
['一剑']='一剑破逍遥:BAAALgAECgQJBAAAAA==.',
['一只']='一只蠢喵喵:BAAALgADCgcJBwAAAA==.',
['一川']='一川烟雨絮:BAAALgAECgEJAQAAAA==.',
['一直']='一直是学霸:BAAALgAECgYJDQAAAA==.',
['一起']='一起去看海:BAAALgAECgIJAgAAAA==.',
['一锤']='一锤八十:BAAALgADCgEJAQAAAA==.一锤子砸你:BAAALgAECgEJAgAAAA==.',
['三锟']='三锟:BAABLgAFFH8LAAITAAQJ5BsECgBIAQATAAQJ5BsECgBIAQAAAA==.',
['上官']='上官小白菜:BAAALgAECgEJAQAAAA==.',
['下午']='下午茶也不行:BAAALgADCgUJBQAAAA==.',
['不壹']='不壹:BAAALgAECgYJCAAAAA==.',
['不夜']='不夜侯:BAAALgAFFAIJAgAAAA==.',
['不学']='不学巫术:BAAALgAECgYJBgAAAA==.',
['不知']='不知火春丽:BAAALgAECgcJBwABLgAFFAcJBAADAAAAAA==.不知道的熙:BAAALgADCgEJAQAAAA==.',
['不要']='不要看我白:BAAALgAFFAIJAgAAAA==.',
['不语']='不语丶:BAAALgAECgEJAQAAAA==.',
['不霍']='不霍草莓刘奶:BAAALgAECgYJDwAAAA==.',
['丑的']='丑的不能看:BAAALgAFFAIJBAAAAA==.',
['东土']='东土来的老爷:BAAALgAECgQJBAAAAA==.',
['东方']='东方圣骑:BAAALgAFFAIJBAAAAA==.',
['严苛']='严苛光芒:BAAALgAECgMJAwAAAA==.',
['丨德']='丨德墨忒尔:BAAALgAECgEJAQAAAA==.',
['丨懒']='丨懒羊丨:BAAALgADCgMJAwAAAA==.',
['丨暗']='丨暗香丨:BAAALgAFFAQJBAAAAA==.',
['丨灬']='丨灬八月灬丨:BAABLgAECn8WAAMUAAcJOBsmKADlAQAUAAYJhR8mKADlAQAQAAMJ2BSieAD9AAAAAA==.丨灬契约灬丨:BAAALgADCgQJBAAAAA==.',
['丨风']='丨风神潇灑丨:BAAALgAECggJAQAAAA==.',
['丨鸹']='丨鸹貔啊丶:BAAALgADCgcJBwAAAA==.',
['丶幽']='丶幽幽影清风:BAAALgAECgEJAQAAAA==.',
['丶曾']='丶曾经的圣骑:BAABLgAECn8YAAIEAAcJmxSAGgBCAQAEAAcJmxSAGgBCAQAAAA==.',
['丶酒']='丶酒蒙子:BAAALgAECgMJBgABLgAECgcJGAAEAJsUAA==.',
['丶雨']='丶雨泽丶:BAAALgAECgIJAgAAAA==.',
['为了']='为了埃尔:BAAALgADCgEJAQAAAA==.为了脸萌:BAAALgADCgcJDgAAAA==.',
['丿憾']='丿憾地丶者彡:BAAALgADCgYJBgAAAA==.',
['丿朴']='丿朴筱筱:BAAALgAFFAMJAwAAAA==.',
['丿陆']='丿陆吾:BAAALgADCgkJCQAAAA==.',
['乌拉']='乌拉蟹的宠物:BAAALgAFFAMJAwAAAA==.',
['乔乔']='乔乔:BAAALgADCgYJBgAAAA==.',
['乔气']='乔气宝:BAAALgADCgEJAQAAAA==.',
['九天']='九天阳光明媚:BAAALgAECgcJEwAAAA==.',
['二锟']='二锟:BAABLgAECn8UAAITAAgJExZZIQDyAQATAAgJExZZIQDyAQAAAA==.',
['亏亏']='亏亏:BAAALgAECgcJDAAAAA==.',
['云吞']='云吞面:BAAALgAECgQJBAAAAA==.',
['云川']='云川鞠亚:BAACLgAFFH8HAAMVAAIJtRkmCwCrAAAVAAIJtRkmCwCrAAAWAAIJxxf1CgBSAAAuAAQKfxcAAxUABwl3Hi0aAA8CABUABgkUIi0aAA8CABYAAgnIGkZQAJMAAAAA.',
['云荒']='云荒猫空:BAAALgADCgYJBgAAAA==.',
['五九']='五九六:BAAALgADCgUJBQAAAA==.',
['五翼']='五翼天使:BAAALgADCgEJAQAAAA==.',
['亚尔']='亚尔:BAAALgAFFAIJBAAAAA==.',
['亚玲']='亚玲一米五:BAAALgAECgcJDQAAAA==.',
['人是']='人是逼出来的:BAACLgAFFH8IAAIXAAQJKA/LAgA9AQAXAAQJKA/LAgA9AQAuAAQKfyEAAxcACQncF6wMALgCABcACQncF6wMALgCABgABwmwFy0jAMwBAAAA.',
['亿方']='亿方:BAAALgAFFAIJBAAAAA==.',
['仇恨']='仇恨之伦:BAAALgAECgIJAwAAAA==.',
['今晚']='今晚吃咕丶:BAAALgAFFAMJAwAAAA==.',
['今汐']='今汐:BAAALgAECgEJAQAAAA==.',
['他们']='他们叫我老八:BAAALgADCgYJBwAAAA==.',
['仙之']='仙之德:BAAALgAECgUJCgAAAA==.',
['优雅']='优雅的微笑:BAAALgADCgIJAgAAAA==.',
['会潜']='会潜水小火箭:BAAALgADCgQJBAAAAA==.',
['会飞']='会飞天小潜艇:BAAALgADCgEJAQAAAA==.',
['伟大']='伟大的法雷尔:BAAALgAECgcJAwABLgAFFAUJBAADAAAAAA==.伟大的渺小丶:BAAALgAECgMJBAABLgAFFAMJBgABAJYUAA==.',
['伴瘦']='伴瘦秂:BAAALgAECgIJAgAAAA==.',
['何君']='何君归:BAAALgAECgQJBAAAAA==.',
['何须']='何须避它锋芒:BAAALgAECgUJDQAAAA==.',
['佛法']='佛法无边无尽:BAAALgAECgYJCwAAAA==.',
['你先']='你先别死:BAACLgAFFH8MAAIXAAQJGR/aBACHAQAXAAQJGR/aBACHAQAuAAQKfyYAAhcABwnqJJgJAOkCABcABwnqJJgJAOkCAAAA.',
['你别']='你别动我拉你:BAAALgAFFAIJAgAAAA==.',
['你很']='你很忧寞:BAAALgADCgIJAgAAAA==.',
['倾城']='倾城丿绝恋:BAAALgAECgUJCAAAAA==.',
['偶不']='偶不是洁洁:BAAALgADCgUJBQAAAA==.',
['偶尔']='偶尔的神:BAAALgAECgEJAQAAAA==.',
['偶素']='偶素大肥肉:BAABLgAFFH8GAAILAAIJVQwRGgCTAAALAAIJVQwRGgCTAAAAAA==.',
['偷偷']='偷偷想妳丶:BAAALgAECgQJBAAAAA==.',
['先救']='先救奥法叭:BAABLgAECn8XAAMQAAcJHBqTUQB0AQAQAAcJlBeTUQB0AQAUAAQJpwzPYAC9AAAAAA==.',
['光翼']='光翼展开:BAAALgAECgQJBQAAAA==.',
['克里']='克里斯狄娜:BAAALgAFFAQJBAAAAA==.',
['全能']='全能之神丶:BAAALgAECgQJBAAAAA==.',
['八倍']='八倍镜:BAAALgAECggJCwAAAA==.',
['兰博']='兰博基尼:BAAALgAECgUJBwAAAA==.',
['兰天']='兰天:BAAALgAECgQJBAAAAA==.',
['其实']='其实很简单丶:BAAALgAECgIJAgAAAA==.',
['养什']='养什么罒什么:BAAALgADCgMJAwAAAA==.',
['内塔']='内塔尼亚湖:BAAALgAFFAEJAQAAAA==.',
['册勃']='册勃册影:BAACLgAFFH8YAAMZAAYJzyM5AAAxAgAZAAYJsyA5AAAxAgAaAAUJbSN9AQDtAQAuAAQKfxsAAxoACAk6I4MMAPMCABoACAnXIoMMAPMCABkAAgl3IY4OAGoAAAAA.',
['冬天']='冬天的东风霖:BAAALgADCgkJCQAAAA==.',
['冰之']='冰之冠冕:BAAALgAECgIJAgAAAA==.',
['冰色']='冰色心:BAAALgADCgMJBAAAAA==.',
['冰酱']='冰酱十三姨:BAAALgAECgYJCAAAAA==.',
['冲毛']='冲毛呀:BAAALgAECgQJBAAAAA==.',
['冲汽']='冲汽娃娃:BAAALgAECgcJDQAAAA==.',
['冲锋']='冲锋就炸气:BAAALgAECgYJBAAAAA==.',
['冷月']='冷月晨曦:BAAALgAECgEJAQAAAA==.',
['冷缌']='冷缌瑶:BAAALgAFFAQJAwAAAA==.',
['凡蔯']='凡蔯:BAAALgAECgEJAQAAAA==.',
['凤凰']='凤凰于飞煌:BAAALgAECgEJAgAAAA==.',
['凹凹']='凹凹凸凸囧囧:BAAALgAECgEJAQAAAA==.',
['刀枪']='刀枪箭戟:BAAALgAECgMJAwAAAA==.',
['刚刚']='刚刚不起床:BAAALgAECgQJBAAAAA==.刚刚睡着:BAAALgAECgQJBAABLgAFFAUJCgAUAPEQAA==.刚刚起床:BAAALgAECgIJAgAAAA==.',
['别叫']='别叫我布丁:BAAALgADCgUJBQAAAA==.',
['别惹']='别惹我丶:BAAALgAECgMJAwAAAA==.',
['别欧']='别欧屉:BAAALgAECgcJBwAAAA==.',
['别闹']='别闹:BAAALgAECgkJAQAAAA==.',
['剑尖']='剑尖:BAAALgADCgEJAQAAAA==.',
['剑无']='剑无笙:BAABLgAECn8XAAIIAAYJwSNTNgBJAgAIAAYJwSNTNgBJAgABLgAECgcJDAADAAAAAA==.',
['剑气']='剑气长歌:BAAALgAECgEJAQAAAA==.',
['剩启']='剩启世:BAAALgADCgIJAgAAAA==.',
['加勒']='加勒比海咕:BAAALgAECgcJBgABLgAFFAQJBAADAAAAAA==.',
['加百']='加百列:BAACLgAFFH8KAAIbAAQJjhhoBwBtAQAbAAQJjhhoBwBtAQAuAAQKfyYAAhsACQmpICgCAJADABsACQmpICgCAJADAAAA.',
['化骨']='化骨咩咩掌:BAAALgAECgYJBgAAAA==.',
['北滨']='北滨秋晚丨:BAAALgAFFAIJBAAAAA==.',
['十七']='十七块:BAABLgAFFH8FAAIJAAUJiQRPEABMAQAJAAUJiQRPEABMAQAAAA==.',
['十日']='十日终焉丶:BAAALgAECgQJBQAAAA==.',
['十蚊']='十蚊鸡:BAAALgAECgEJBAAAAA==.',
['半夜']='半夜修仙:BAAALgAECgMJAwAAAA==.半夜版:BAAALgADCgYJCgAAAA==.',
['华华']='华华最可爱:BAAALgAFFAEJAQABLgAFFAIJAgADAAAAAA==.华华最有德:BAAALgAFFAEJAQAAAA==.华华最风骚:BAABLgAFFH8FAAIcAAIJKA1aDACFAAAcAAIJKA1aDACFAAABLgAFFAIJAgADAAAAAA==.',
['南佳']='南佳也:BAAALgAECgEJAQAAAA==.',
['南千']='南千秋丶:BAABLgAECn8cAAQZAAgJ3xrbDgCuAQAZAAUJZSLbDgCuAQAcAAgJAg60GQCCAQAaAAIJ8CGEiQCZAAABLgAECgkJDAADAAAAAA==.',
['南岸']='南岸夏栀:BAAALgADCgEJAQAAAA==.',
['南風']='南風知我义:BAAALgADCgUJCwAAAA==.南風知我亦:BAAALgAECgQJBAAAAA==.南風知我伊:BAAALgAECgYJCAAAAA==.',
['卡塞']='卡塞帝:BAAALgAECgEJAQAAAA==.',
['卡普']='卡普奇诺:BAAALgADCgUJBQAAAA==.',
['卡莱']='卡莱尔丶鸦影:BAAALgADCgUJBQAAAA==.',
['卫兵']='卫兵乌拉蟹:BAAALgADCgYJBgAAAA==.',
['厄神']='厄神:BAAALgAECgQJBAAAAA==.',
['历战']='历战老兵:BAAALgADCgcJBwAAAA==.',
['原野']='原野行者:BAAALgAFFAEJAgAAAA==.',
['双手']='双手成就梦想:BAAALgAECgEJAQAAAA==.',
['古丽']='古丽热巴:BAAALgADCgEJAQAAAA==.',
['古尔']='古尔丹之手:BAAALgAECgIJAgAAAA==.',
['古思']='古思特:BAAALgAECgUJBwAAAA==.',
['古风']='古风熊猫:BAAALgAECgcJCgAAAA==.',
['叫我']='叫我猛哥丶:BAAALgADCgQJBAAAAA==.叫我马富贵:BAAALgADCgEJAQAAAA==.',
['可怕']='可怕蜥蜴人:BAACLgAFFH8SAAINAAUJihojBAC9AQANAAUJihojBAC9AQAuAAQKfywAAg0ACQkQHVsEAA4DAA0ACQkQHVsEAA4DAAAA.',
['可晓']='可晓:BAAALgAECgMJAwAAAA==.',
['叶叶']='叶叶的圣骑:BAAALgADCgYJCAAAAA==.叶叶的潜行:BAAALgADCgUJBQAAAA==.',
['吃我']='吃我一记夜凯:BAAALgADCgYJBgAAAA==.',
['吉米']='吉米埃克斯:BAAALgAFFAIJAgAAAA==.吉米希克斯:BAAALgAECgQJBAAAAA==.',
['同归']='同归殊途之吟:BAACLgAFFH8HAAISAAMJaB0VGACgAAASAAMJaB0VGACgAAAuAAQKfxYAAhIABglHHtY3AMgBABIABglHHtY3AMgBAAEuAAUUAwkJABgALCIA.',
['同葬']='同葬无光之愿:BAABLgAFFH8JAAMYAAMJLCLoCQDIAAAYAAMJEBzoCQDIAAAOAAIJeSDPEAC8AAAAAA==.',
['呆西']='呆西九号:BAABLgAFFH8GAAIPAAUJXRkSBQC0AQAPAAUJXRkSBQC0AQAAAA==.呆西十号:BAABLgAFFH8FAAIPAAUJ4xmTBADBAQAPAAUJ4xmTBADBAQAAAA==.',
['咕咕']='咕咕猎手:BAABLgAFFH8IAAIMAAQJmyQlAACnAQAMAAQJmyQlAACnAQAAAA==.',
['咱各']='咱各叫各的:BAAALgADCgEJAQAAAA==.',
['哇哇']='哇哇汪汪:BAABLgAFFH8KAAMLAAQJiAosEADnAAALAAQJiAosEADnAAAFAAMJPgYHEgDWAAAAAA==.',
['哪来']='哪来的观星德:BAAALgADCgIJAgAAAA==.',
['唐次']='唐次楚:BAAALgAFFAIJAwAAAA==.',
['喋喋']='喋喋不休:BAAALgAECgQJBQAAAA==.',
['喔唷']='喔唷:BAAALgAECgQJBwAAAA==.',
['喔尤']='喔尤:BAAALgAECgQJBAAAAA==.',
['喜卜']='喜卜喜:BAAALgADCgkJEAAAAA==.',
['單骑']='單骑:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血小强:BAAALgAECgEJAQAAAA==.',
['噼里']='噼里啪啦哗哗:BAAALgADCgYJBgAAAA==.',
['嚼我']='嚼我女王大人:BAAALgAFFAIJAwAAAA==.',
['四仰']='四仰化三铁:BAAALgADCgEJAQAAAA==.',
['四十']='四十码输出:BAAALgAECgcJCgAAAA==.',
['四锟']='四锟:BAABLgAFFH8LAAITAAQJuxl/BwBpAQATAAQJuxl/BwBpAQAAAA==.',
['回忆']='回忆很长:BAAALgAECgUJBQAAAA==.回忆的爱:BAABLgAECn8UAAIQAAYJIRowPQC6AQAQAAYJIRowPQC6AQAAAA==.回忆长存:BAAALgAECgEJAQAAAA==.',
['因随']='因随意而随意:BAAALgAECgIJAQAAAA==.',
['囬菋']='囬菋:BAAALgAECgEJAgAAAA==.',
['国一']='国一司空震:BAAALgAFFAQJBAAAAA==.',
['图灵']='图灵的圣光:BAAALgAECgEJAQAAAA==.',
['土豆']='土豆豆:BAAALgADCgEJAQAAAA==.',
['圣之']='圣之哞哞锤:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光之刃:BAAALgAECgUJBgAAAA==.圣光终焉:BAAALgAFFAIJAgAAAA==.圣光锦鲤:BAAALgAECgQJBQAAAA==.',
['圣枪']='圣枪丶拔锚:BAAALgAECgEJAQAAAA==.',
['圣诞']='圣诞术:BAAALgAFFAIJAgAAAA==.',
['圣骑']='圣骑华华:BAAALgADCgEJAQABLgAFFAIJAgADAAAAAA==.',
['在下']='在下朱某:BAAALgAFFAUJBAAAAA==.',
['在家']='在家种芋头:BAAALgAECgQJBQAAAA==.',
['地狱']='地狱礼赞:BAAALgAECgIJBAAAAA==.',
['地獄']='地獄戰獸:BAAALgAECgMJAwAAAA==.地獄鬼王:BAAALgAECgEJAgAAAA==.',
['塞于']='塞于仁泰:BAAALgAECgYJBgAAAA==.',
['墓丶']='墓丶中无人:BAAALgAECgcJDAAAAA==.',
['墨茗']='墨茗奇喵:BAABLgAFFH8FAAIQAAIJlybVDQDpAAAQAAIJlybVDQDpAAAAAA==.',
['壶中']='壶中客:BAAALgAFFAIJBAAAAA==.',
['壹沙']='壹沙壹世界:BAAALgADCgEJAQABLgAECgcJBwADAAAAAA==.',
['夏夜']='夏夜丶晚风:BAAALgAFFAEJAQAAAA==.',
['夏空']='夏空冬星:BAABLgAFFH8JAAISAAMJNBheEADmAAASAAMJNBheEADmAAAAAA==.夏空英仙:BAAALgAFFAIJAgAAAA==.',
['夕夕']='夕夕啊:BAAALgAFFAQJBAAAAA==.',
['多兰']='多兰:BAAALgADCgcJBwAAAA==.',
['多带']='多带点小弟:BAAALgAECgMJAwAAAA==.',
['大佬']='大佬爷:BAAALgAECgYJBwAAAA==.',
['大信']='大信球:BAAALgAECgcJBwAAAA==.',
['大咕']='大咕咕牛排:BAAALgAECgIJAgAAAA==.',
['大圣']='大圣来野:BAAALgADCgIJAgAAAA==.',
['大家']='大家都说我牛:BAAALgAECgQJBgAAAA==.',
['大张']='大张丷大合:BAAALgAECgUJCAAAAA==.',
['大明']='大明严世蕃:BAAALgAFFAEJAQAAAA==.',
['大朵']='大朵儿丶:BAAALgAECgEJAQAAAA==.大朵朵丶:BAAALgAFFAIJAgAAAA==.',
['大泓']='大泓啪嗒砰:BAAALgAECgEJAQAAAA==.',
['大温']='大温柔:BAAALgAECgQJBAAAAA==.',
['大牛']='大牛笔较懒:BAAALgAFFAIJAgAAAA==.',
['大胖']='大胖猫仔:BAAALgAFFAIJAgAAAA==.',
['大譊']='大譊姐丶驾到:BAABLgAECn8YAAIIAAcJ4hRyEAChAQAIAAcJ4hRyEAChAQAAAA==.',
['大镁']='大镁铝:BAAALgAECgEJAQAAAA==.',
['大香']='大香蕉:BAAALgAECgEJAQAAAA==.',
['大鱼']='大鱼炖海棠丶:BAAALgAECgEJAgAAAA==.',
['天使']='天使涙痕:BAAALgAECgYJBgAAAA==.',
['天台']='天台售票员:BAAALgAECgEJAQAAAA==.',
['天启']='天启熊喵喵:BAAALgAECgkJBwAAAA==.',
['天天']='天天要连板:BAAALgAECgcJEgAAAA==.',
['天才']='天才小海赖:BAAALgAECgEJAQABLgAECgIJAgADAAAAAA==.',
['奇尔']='奇尔沙治:BAABLgAFFH8KAAIEAAMJQCbtGwA0AQAEAAMJQCbtGwA0AQAAAA==.',
['奇异']='奇异果博士:BAAALgADCgUJCgAAAA==.奇异果硕士:BAAALgAECgEJAQAAAA==.',
['奈纹']='奈纹萌尔:BAAALgAECgEJAgAAAA==.',
['奥克']='奥克托:BAAALgAECgcJBwAAAA==.',
['奥格']='奥格围观群众:BAABLgAECn8fAAMBAAcJKyCOMQCsAgABAAcJIiCOMQCsAgAdAAIJmyHdCwByAAAAAA==.',
['女为']='女为悦己者容:BAAALgAECgEJAQAAAA==.',
['奶茶']='奶茶杠杠:BAAALgADCgUJBQAAAA==.',
['好喝']='好喝到咩噗茶:BAAALgADCgEJAQAAAA==.',
['好孕']='好孕气独自:BAAALgAECgYJBgAAAA==.',
['好风']='好风骚的人:BAAALgAECgYJDwAAAA==.',
['妖妖']='妖妖零:BAAALgAECgMJAgAAAA==.',
['妖法']='妖法尸:BAAALgAECgcJEgAAAA==.',
['妙龄']='妙龄老辈子:BAAALgAECgEJAQAAAA==.',
['妮美']='妮美雅:BAAALgAECgYJBgABLgAFFAMJCQAYACwiAA==.',
['姬子']='姬子清:BAAALgAECgEJAQAAAA==.',
['威威']='威威士忌:BAAALgADCgMJAwAAAA==.',
['威震']='威震四海:BAAALgAECgYJBgAAAA==.',
['娜塔']='娜塔微娅:BAAALgAECgMJAwAAAA==.',
['子蜚']='子蜚语:BAAALgAECgEJAQAAAA==.',
['孔雀']='孔雀翎:BAAALgADCgEJAQAAAA==.',
['孤孑']='孤孑:BAAALgAECgQJBAAAAA==.',
['安全']='安全嘀桃子:BAAALgAECgcJDQAAAA==.',
['安然']='安然若初:BAAALgADCgEJAQAAAA==.',
['宋尚']='宋尚颖:BAAALgAFFAQJAgAAAA==.',
['宗门']='宗门少主丶:BAAALgAFFAEJAQAAAA==.',
['宝可']='宝可梦帶师:BAACLgAFFH8HAAMUAAMJiRJgHACkAAAUAAIJghRgHACkAAAQAAIJghEYJABYAAAuAAQKfxkAAxQACAlyHBkbAE0CABQACAkfGRkbAE0CABAABAkKIgAAAAAAAAAA.',
['宝贝']='宝贝小熊乄:BAAALgAECgcJBwAAAA==.',
['密斯']='密斯特棒:BAAALgAECgEJAQAAAA==.',
['寒霜']='寒霜之姿:BAAALgAFFAIJAgAAAA==.',
['寒风']='寒风一猎:BAAALgADCgYJBgAAAA==.',
['对牛']='对牛弹琴:BAAALgAFFAEJAgAAAA==.',
['射手']='射手阿闻:BAAALgAECgEJAQAAAA==.',
['小冰']='小冰冰传奇:BAAALgAECgYJCAAAAA==.',
['小呀']='小呀嚒小灰灰:BAAALgADCgIJAgAAAA==.',
['小天']='小天时箭:BAAALgAECgEJAgAAAA==.',
['小妹']='小妹妹乖乖:BAAALgADCgUJBQAAAA==.',
['小小']='小小乖最爱你:BAAALgAECgUJBwAAAA==.小小智大佬:BAAALgAFFAEJAQAAAA==.小小橘子:BAAALgADCgUJBQAAAA==.',
['小德']='小德没烦恼:BAAALgAECggJCgAAAA==.',
['小心']='小心灬绷带:BAAALgAECgUJBgAAAA==.',
['小恶']='小恶魔传奇:BAAALgADCgQJAwAAAA==.',
['小手']='小手奶不动:BAAALgAECgQJBAAAAA==.',
['小拉']='小拉达达:BAAALgAFFAUJAQAAAA==.',
['小拳']='小拳拳锤死你:BAAALgAFFAIJAwAAAA==.',
['小晓']='小晓小圣骑:BAAALgAECgcJBgAAAA==.',
['小术']='小术术传奇:BAAALgADCgEJAQAAAA==.',
['小火']='小火猴猴:BAABLgAFFH8FAAIUAAUJWCQmAwAdAgAUAAUJWCQmAwAdAgAAAA==.',
['小牧']='小牧丶:BAAALgAECgEJAQAAAA==.',
['小红']='小红手元气:BAAALgAECgYJDAAAAA==.',
['小翼']='小翼:BAABLgAECn8bAAMPAAgJSBXVFwAUAgAPAAgJSBXVFwAUAgANAAEJdiOoQABlAAABLgAFFAYJFQAEAEEkAA==.',
['小蚂']='小蚂蚁:BAAALgAECgUJBgAAAA==.',
['小雏']='小雏菊爱大棒:BAAALgAFFAEJAQAAAA==.',
['小雨']='小雨潇潇:BAAALgAECgQJBAAAAA==.',
['小鬼']='小鬼法:BAAALgAECgYJBgAAAA==.小鬼萨:BAAALgAECgUJBQAAAA==.',
['少林']='少林功夫好椰:BAAALgADCgIJBAAAAA==.',
['尘茶']='尘茶:BAAALgAECgcJBwAAAA==.',
['尛奶']='尛奶骑:BAAALgAECgYJBgAAAA==.',
['就爱']='就爱巧克力:BAAALgADCgEJAQAAAA==.',
['尽享']='尽享丝滑:BAAALgAFFAIJAwAAAA==.',
['山海']='山海观雾灬:BAAALgAECgQJBAAAAA==.',
['屹夏']='屹夏:BAAALgAECgYJBwAAAA==.',
['岁星']='岁星:BAAALgAECgYJBgAAAA==.',
['左三']='左三拳右三拳:BAAALgADCgIJAgAAAA==.',
['巧克']='巧克力圣代:BAAALgADCgUJBQAAAA==.',
['已闻']='已闻花香:BAAALgAECgEJAQAAAA==.',
['巴瓦']='巴瓦:BAAALgAECgYJBgAAAA==.',
['巴黎']='巴黎倍儿甜丶:BAAALgAECgYJBwAAAA==.',
['希尓']='希尓瓦娜澌:BAAALgAECgcJCwAAAA==.',
['希尔']='希尔瑞斯丽:BAAALgAECgMJAwAAAA==.希尔瓦比西:BAAALgAECgEJAQAAAA==.',
['帕西']='帕西法尔:BAAALgADCgYJBgAAAA==.',
['带回']='带回忆去流浪:BAAALgADCgUJBQAAAA==.带回忆去漂泊:BAAALgADCgEJAQAAAA==.带回忆去远行:BAAALgAECgMJAwAAAA==.',
['幸运']='幸运的星星:BAAALgAECgQJBAAAAA==.',
['幻幻']='幻幻小魔女:BAAALgAECgQJBQAAAA==.',
['幻影']='幻影逍遥:BAAALgAECgQJBQAAAA==.',
['幻想']='幻想女孩:BAAALgAECgcJCQAAAA==.',
['幻月']='幻月倾萱:BAAALgAECgMJAwABLgAFFAYJGAAPACkgAA==.',
['幻紫']='幻紫紫月:BAAALgAECgcJDQAAAA==.',
['幽兰']='幽兰灬拿铁:BAABLgAFFH8GAAMSAAIJSw0HHACMAAASAAIJSw0HHACMAAAeAAEJKQmTBwAuAAAAAA==.',
['幽魂']='幽魂残雨:BAAALgADCgcJBwAAAA==.',
['开门']='开门的:BAAALgAECgYJCAAAAA==.',
['张咕']='张咕咕嘎:BAAALgAECgEJAgAAAA==.',
['张小']='张小妮儿:BAAALgAECgcJDgAAAA==.',
['归林']='归林:BAAALgAECgEJAQAAAA==.',
['影懿']='影懿灰先生:BAABLgAFFH8HAAIPAAQJlxAzBQA+AQAPAAQJlxAzBQA+AQAAAA==.',
['影灭']='影灭:BAAALgADCgEJAQAAAA==.',
['彷徨']='彷徨妖精:BAAALgAECgYJBgAAAA==.',
['彼盛']='彼盛北溟:BAAALgADCgYJBgABLgAFFAUJEAAEAEgRAA==.',
['很有']='很有教养的熊:BAAALgAECgYJCQAAAA==.',
['徐正']='徐正义:BAAALgAECgMJAwAAAA==.',
['得德']='得德的地嘚:BAABLgAECn8UAAISAAcJ5CP9GQBpAgASAAcJ5CP9GQBpAgAAAA==.',
['德年']='德年年:BAAALgAFFAIJAgAAAA==.',
['德莱']='德莱倪:BAAALgADCgEJAQAAAA==.',
['忧郁']='忧郁的牛奶:BAAALgADCgcJBwAAAA==.',
['快乐']='快乐的小丰:BAABLgAECn8VAAMIAAYJpxuGXADNAQAIAAYJpxuGXADNAQAfAAYJtQ5TIQD9AAAAAA==.',
['快开']='快开门我先走:BAAALgAECgcJDAAAAA==.',
['怪坏']='怪坏怪:BAAALgAECgEJAQAAAA==.',
['恐怖']='恐怖丶利刃:BAAALgAFFAEJAQAAAA==.',
['恶魔']='恶魔的碎片:BAABLgAECn8WAAIJAAcJ/RcAUwCrAQAJAAcJ/RcAUwCrAQAAAA==.恶魔秋:BAAALgAECgMJAwAAAA==.恶魔術:BAAALgAECgkJEAAAAA==.',
['悠然']='悠然南山:BAAALgADCgcJDwAAAA==.',
['惟愿']='惟愿山河锦绣:BAAALgAFFAIJAgAAAA==.',
['惠小']='惠小美:BAAALgAECgUJAgAAAA==.',
['想怎']='想怎么就怎么:BAABLgAFFH8IAAIFAAMJ0SJ9CgA9AQAFAAMJ0SJ9CgA9AQAAAA==.',
['慕丶']='慕丶官人:BAAALgAECgQJBAAAAA==.',
['憔悴']='憔悴的海豹:BAAALgADCgQJBAAAAA==.',
['我一']='我一星之光:BAAALgADCgcJDQAAAA==.',
['我上']='我上天了:BAAALgAECgIJBAAAAA==.',
['我不']='我不是术师:BAACLgAFFH8KAAICAAQJIRN8CQAvAQACAAQJIRN8CQAvAQAuAAQKfxgAAwIABwkJI2IeAKECAAIABwkJI2IeAKECABEAAQkAAMVnAEEAAAAA.',
['我也']='我也疲倦了:BAAALgAECgYJCwAAAA==.',
['我奶']='我奶的很好:BAAALgAECgYJBwAAAA==.',
['我家']='我家的小柴:BAAALgAECgYJBgAAAA==.',
['我就']='我就是正义:BAAALgAFFAEJAgAAAA==.',
['我是']='我是传说:BAAALgAECgIJAgAAAA==.我是捡来的:BAAALgADCgIJAgAAAA==.我是阿昆达:BAAALgADCgIJAgAAAA==.',
['我真']='我真的爱过你:BAAALgAECgYJBgAAAA==.',
['我美']='我美么:BAAALgADCgEJAQAAAA==.',
['我身']='我身体好:BAAALgADCgQJBAAAAA==.',
['才不']='才不玩狂暴呢:BAAALgAFFAIJAwAAAA==.',
['托尼']='托尼沙帕:BAAALgAECgcJDwAAAA==.',
['扯丶']='扯丶奈亚:BAAALgAECgYJBwAAAA==.',
['护邪']='护邪:BAAALgAFFAIJAgAAAA==.',
['抹茶']='抹茶丶绵绵冰:BAACLgAFFH8FAAIEAAIJTwm7QwCbAAAEAAIJTwm7QwCbAAAuAAQKfxQAAwQABgk4HLxpALkBAAQABgk4HLxpALkBAAcAAQnwGdtAAEkAAAAA.',
['拉娜']='拉娜德雷:BAAALgAECgcJCQAAAA==.',
['拉希']='拉希尔:BAAALgAECgMJAwAAAA==.',
['持盾']='持盾的鹌鹑:BAAALgADCgUJBQABLgAFFAEJAQADAAAAAA==.',
['撒玛']='撒玛利亚:BAAALgAECgcJEgAAAA==.',
['撸撸']='撸撸不累卡:BAAALgAECgYJDwAAAA==.',
['擎天']='擎天柱之父:BAAALgAECgEJAQAAAA==.',
['故乡']='故乡的永夜:BAAALgADCgEJAQAAAA==.',
['文小']='文小喵:BAAALgAECgYJBgAAAA==.',
['文艺']='文艺复兴:BAAALgADCgQJBAAAAA==.',
['斩马']='斩马刀:BAAALgAFFAIJAgAAAA==.',
['斯坦']='斯坦福桥的蓝:BAAALgADCgIJAgAAAA==.',
['新时']='新时代牛马:BAAALgAECgYJBgAAAA==.',
['无为']='无为的图腾:BAAALgAFFAIJAgAAAA==.',
['无敌']='无敌暴龙兽:BAACLgAFFH8PAAIEAAQJWCUHAQC0AQAEAAQJWCUHAQC0AQAuAAQKfxsAAgQACQkEIH4LAD8DAAQACQkEIH4LAD8DAAAA.',
['无聊']='无聊看看妹儿:BAAALgADCgIJAgAAAA==.',
['无茗']='无茗:BAAALgAECgEJAgAAAA==.',
['日落']='日落以后:BAAALgAECgYJBwAAAA==.',
['旧梦']='旧梦银时:BAAALgAECgMJAwAAAA==.',
['时光']='时光戏人:BAAALgAECgcJEwAAAA==.',
['旺旺']='旺旺掀被:BAAALgAECgYJBgAAAA==.',
['昀先']='昀先生:BAAALgAECgkJCQAAAA==.',
['星尘']='星尘之忆:BAAALgAECgYJBwAAAA==.',
['星辰']='星辰的碎片:BAAALgAECgkJBQAAAA==.',
['星野']='星野:BAAALgAECgIJAgAAAA==.',
['春日']='春日蝶序:BAAALgAECgkJEAAAAA==.',
['是大']='是大泓啊:BAAALgAECgYJCwAAAA==.',
['是杨']='是杨羊羊吖:BAAALgAECgIJAgAAAA==.',
['晟小']='晟小柒:BAABLgAECn8YAAIIAAcJ6R3xOQA7AgAIAAcJ6R3xOQA7AgAAAA==.',
['晨曦']='晨曦小法:BAAALgAECgYJCQAAAA==.',
['景语']='景语:BAAALgADCgYJBgAAAA==.',
['暗夜']='暗夜术:BAAALgAECgQJBQAAAA==.',
['暮星']='暮星阿尔温:BAACLgAFFH8IAAIKAAMJ4R64CgAxAQAKAAMJ4R64CgAxAQAuAAQKfxYAAgoABgn7JPsSAHsCAAoABgn7JPsSAHsCAAAA.',
['暮雨']='暮雨亦成诗丶:BAABLgAECn8UAAIBAAcJDx3AagAAAgABAAcJDx3AagAAAgAAAA==.',
['暴雨']='暴雨连连:BAAALgAECgMJAwAAAA==.',
['曦夜']='曦夜玉:BAAALgAECgQJBAAAAA==.',
['曲世']='曲世爱:BAAALgAECgMJAwAAAA==.',
['最细']='最细的大腿:BAAALgADCgEJAQAAAA==.',
['月光']='月光的碎片:BAABLgAECn8WAAQXAAcJARMlLgBvAQAXAAYJMBMlLgBvAQAOAAcJ5w6JLAA4AQAYAAMJjgPUbAB2AAAAAA==.',
['月影']='月影霓裳:BAAALgADCgEJAgAAAA==.',
['月色']='月色真美丨:BAAALgAFFAQJAwAAAA==.',
['朗多']='朗多雷之傲:BAAALgADCgIJAgAAAA==.',
['术爷']='术爷术爷:BAAALgAECgYJCQAAAA==.',
['村口']='村口娇花:BAAALgAECgIJAgAAAA==.',
['来吧']='来吧宝贝嗷:BAAALgAECgYJDQAAAA==.',
['极品']='极品小牛:BAAALgAECgEJAQAAAA==.',
['极意']='极意:BAEALgAECgYJDgAAAA==.',
['林宥']='林宥嘉:BAAALgAECgEJAgAAAA==.',
['枪小']='枪小该:BAAALgAECgMJAwAAAA==.',
['枫焰']='枫焰小龙:BAAALgADCgMJAwAAAA==.',
['枭隼']='枭隼:BAAALgAECgYJBgAAAA==.',
['枯燥']='枯燥:BAAALgAECgkJCQAAAA==.',
['柑橘']='柑橘双皮奶:BAAALgAECgEJAQAAAA==.',
['柒曜']='柒曜:BAAALgAECgYJBgAAAA==.',
['柚见']='柚见倾心:BAAALgAECgYJBgAAAA==.',
['柳柳']='柳柳球:BAACLgAFFH8LAAIWAAUJjxe7AwCzAQAWAAUJjxe7AwCzAQAuAAQKfxgAAhYACAmvIHEHAOICABYACAmvIHEHAOICAAAA.',
['柴妮']='柴妮子:BAAALgAECgMJAwAAAA==.',
['格雷']='格雷泽:BAAALgAECggJCAAAAA==.',
['桑格']='桑格利亚:BAAALgAECgYJCwAAAA==.',
['梦靥']='梦靥:BAAALgADCgUJBQAAAA==.',
['椛颜']='椛颜俏妞:BAAALgAECgQJBQAAAA==.',
['椰穌']='椰穌:BAAALgAECgEJAQAAAA==.',
['楊枝']='楊枝甘露:BAAALgAFFAIJAwAAAA==.',
['楓火']='楓火葉飄零:BAAALgAFFAIJAgAAAA==.',
['楚骄']='楚骄:BAAALgAECgEJAQAAAA==.',
['楼兰']='楼兰织梦:BAAALgAECgEJAQAAAA==.',
['槐夏']='槐夏风蝉:BAAALgAECgEJAQAAAA==.',
['樱井']='樱井智树丶丶:BAABLgAFFH8FAAICAAIJ9iRlJwDeAAACAAIJ9iRlJwDeAAAAAA==.',
['樱月']='樱月冰星:BAAALgAECgEJAQAAAA==.',
['樱桃']='樱桃布丁:BAABLgAFFH8GAAIBAAMJJQ6nLAAEAQABAAMJJQ6nLAAEAQAAAA==.',
['樱花']='樱花面包:BAABLgAFFH8GAAMIAAMJ5RjULQBZAAAIAAMJ5RjULQBZAAAKAAEJ8AmbGwBQAAABLgAFFAMJCQANAHIjAA==.',
['欧巴']='欧巴撒浪嘿:BAAALgAECgYJBAAAAA==.',
['欧布']='欧布重光形态:BAAALgAECgQJBwAAAA==.',
['正义']='正义没有假期:BAAALgAECgMJAwAAAA==.',
['正经']='正经老胡:BAAALgAECgEJAQAAAA==.',
['正规']='正规按摩:BAABLgAFFH8GAAIJAAQJ5xgfGQAGAQAJAAQJ5xgfGQAGAQAAAA==.',
['死亡']='死亡猎手米莎:BAAALgAFFAIJBAAAAA==.',
['殇嗳']='殇嗳:BAAALgAECgEJAwAAAA==.',
['毁丶']='毁丶:BAAALgAECgIJAgAAAA==.',
['毒英']='毒英俊:BAAALgADCgUJAgAAAA==.',
['毛毛']='毛毛小龙:BAACLgAFFH8HAAMgAAMJlhjmBwBlAAAPAAIJMRLGGACfAAAgAAIJshvmBwBlAAAuAAQKfxQABCAACAnyGSoNAAcCACAABgmtHioNAAcCAA0ABQnOHasbAKsBAA8AAgkdDvlSAHwAAAAA.毛毛狗:BAAALgAECgcJDAABLgAFFAMJBwAgAJYYAA==.',
['永夜']='永夜乄萌莉:BAACLgAFFH8IAAIMAAIJ5RKpCACqAAAMAAIJ5RKpCACqAAAuAAQKfxcAAgwABwkCH8USAEICAAwABwkCH8USAEICAAAA.',
['江南']='江南烟花:BAAALgAECgMJBAAAAA==.',
['沁沁']='沁沁氤氲静谧:BAAALgADCgYJBgAAAA==.',
['沐秋']='沐秋晚清霜:BAAALgADCgEJAQAAAA==.',
['没扎']='没扎头:BAABLgAECn8YAAIIAAYJ8iTCMgBXAgAIAAYJ8iTCMgBXAgAAAA==.',
['河图']='河图省度:BAAALgAFFAIJAgAAAA==.',
['法使']='法使:BAAALgADCgMJAwAAAA==.',
['泙安']='泙安喜乐:BAAALgADCgEJAQAAAA==.',
['泡泡']='泡泡关羽:BAAALgAECgQJBAAAAA==.泡泡刘备:BAAALgAFFAIJAgAAAA==.泡泡孟德:BAAALgAECgEJAQAAAA==.泡泡武松:BAAALgAECgMJAwAAAA==.泡泡紫霞:BAAALgADCgcJBwAAAA==.泡泡貂蝉:BAAALgAFFAEJAQAAAA==.泡泡龙猫:BAAALgAFFAQJAwAAAA==.泡泡龙王:BAAALgAECgYJBgAAAA==.泡泡龙蕾:BAAALgAFFAQJBAAAAA==.',
['泡的']='泡的饭饭:BAAALgADCgQJBAAAAA==.',
['波克']='波克比喵喵:BAABLgAFFH8GAAIEAAIJJCIXNwCtAAAEAAIJJCIXNwCtAAAAAA==.',
['波屯']='波屯劳改:BAABLgAFFH8GAAISAAMJxgggFADGAAASAAMJxgggFADGAAAAAA==.',
['波西']='波西米亚水晶:BAAALgADCgEJAQAAAA==.',
['洛神']='洛神丶蓝:BAAALgAFFAQJBAAAAA==.',
['海哥']='海哥死骑:BAABLgAECn8aAAIEAAgJXB8bFwDxAgAEAAgJXB8bFwDxAgAAAA==.海哥骑士:BAAALgAECgcJCgAAAA==.',
['海宝']='海宝:BAAALgAECgMJAwAAAA==.',
['海涅']='海涅丶:BAAALgAECgQJBAAAAA==.',
['海苔']='海苔面包:BAACLgAFFH8JAAMNAAMJciOzCgA/AQANAAMJciOzCgA/AQAgAAEJsRM8CQBXAAAuAAQKfxcAAw0ABgn2HFsWAOgBAA0ABgn2HFsWAOgBACAAAwmTF20oANwAAAAA.',
['淡水']='淡水:BAAALgADCgMJAwAAAA==.',
['淮暮']='淮暮:BAABLgAECn8bAAMCAAgJphbxMgBAAgACAAgJphbxMgBAAgARAAMJXw17RACjAAAAAA==.',
['深更']='深更半夜偷玩:BAABLgAFFH8GAAIBAAMJCA4oEwD7AAABAAMJCA4oEwD7AAAAAA==.',
['混乱']='混乱之手:BAAALgAECgIJAgAAAA==.',
['清华']='清华拳圣薛某:BAACLgAFFH8JAAIcAAMJZwNxCgCkAAAcAAMJZwNxCgCkAAAuAAQKfxgAAhwABwmhFAUTANoBABwABwmhFAUTANoBAAAA.',
['清霄']='清霄:BAAALgAECgEJAQAAAA==.',
['清风']='清风:BAAALgAECgcJDAAAAA==.',
['渊下']='渊下桃源:BAAALgAECgYJBgAAAA==.',
['渡江']='渡江楫:BAAALgAFFAYJBAAAAA==.',
['渣渣']='渣渣骑:BAAALgADCgEJAQAAAA==.',
['游学']='游学者胡适:BAAALgAECgEJAQAAAA==.',
['游鱼']='游鱼与海:BAAALgAECgYJBQAAAA==.游鱼与鸟:BAAALgAECgcJBwAAAA==.',
['湖灬']='湖灬人:BAAALgAECgMJAwAAAA==.',
['滄海']='滄海笑:BAAALgAECgEJAQAAAA==.',
['潇潇']='潇潇慕雪:BAAALgAECgUJCAAAAA==.',
['澄閃']='澄閃:BAAALgAECgcJBAAAAA==.',
['澪樱']='澪樱:BAABLgAFFH8FAAIBAAUJ3Ar/DgCgAQABAAUJ3Ar/DgCgAQAAAA==.',
['火的']='火的不得了:BAAALgAECgUJCAAAAA==.',
['灬法']='灬法丝灬:BAAALgAECgEJAQAAAA==.',
['灬牛']='灬牛肉镐灬:BAAALgAECgUJBQAAAA==.',
['灭魂']='灭魂:BAAALgAECgEJAQAAAA==.',
['灵宝']='灵宝道君:BAAALgAECgIJAwAAAA==.',
['灵忽']='灵忽:BAAALgAECgcJCQAAAA==.',
['灵霄']='灵霄光羽真君:BAAALgAECgQJBAAAAA==.',
['灵魂']='灵魂行者黑角:BAAALgAECgcJDQABLgAFFAQJCAAFAHMbAA==.',
['炊事']='炊事班扛锅的:BAAALgAFFAEJAQAAAA==.',
['炸不']='炸不死你:BAAALgAECgEJAQAAAA==.',
['烛光']='烛光摇曳:BAABLgAFFH8IAAILAAIJTiIIEwDJAAALAAIJTiIIEwDJAAABLgAFFAMJBgAQAJMWAA==.',
['烽火']='烽火连城:BAAALgAECgYJBgAAAA==.',
['無畏']='無畏地獄之心:BAAALgAECgkJCQAAAA==.',
['焱瑾']='焱瑾:BAAALgAFFAEJAQAAAA==.',
['煜帝']='煜帝:BAAALgAECgQJBgAAAA==.',
['熔火']='熔火叔:BAAALgADCgEJAQAAAA==.',
['燃星']='燃星者上尉:BAAALgADCgEJAQAAAA==.',
['燕飞']='燕飞天南:BAAALgAECgQJBQAAAA==.',
['爱姬']='爱姬多娜:BAAALgAECgIJAwAAAA==.',
['牛奰']='牛奰轟轟:BAAALgADCgcJBwAAAA==.',
['牛的']='牛的不得了:BAAALgAECgMJAwAAAA==.',
['牛耶']='牛耶巴斯托:BAAALgAFFAIJBAAAAA==.',
['牛麻']='牛麻批德很:BAAALgAFFAIJAgAAAA==.',
['狐狸']='狐狸头毒奶:BAAALgAECgQJAwAAAA==.',
['狸花']='狸花猫德:BAAALgADCgYJBgAAAA==.',
['狼鱼']='狼鱼啃啃:BAAALgAFFAEJAQAAAA==.',
['猎刃']='猎刃万嘉:BAAALgAFFAIJAwABLgAFFAIJAwADAAAAAA==.',
['猎手']='猎手华华:BAAALgADCgIJAgABLgAFFAIJAgADAAAAAA==.',
['猎质']='猎质品:BAAALgAFFAIJBAAAAA==.',
['猫是']='猫是液体:BAAALgAECgEJAwAAAA==.',
['猫鱼']='猫鱼小卖部:BAAALgAFFAIJAwAAAA==.',
['玄狐']='玄狐济世:BAABLgAFFH8JAAIWAAMJNCD3CAAqAQAWAAMJNCD3CAAqAQAAAA==.',
['玛法']='玛法绿奥:BAAALgAECgYJDgAAAA==.',
['玟小']='玟小六:BAABLgAFFH8IAAMYAAMJjAavDwCAAAAOAAIJ0gXGFQCFAAAYAAIJ7wWvDwCAAAAAAA==.',
['珈百']='珈百璃:BAACLgAFFH8JAAMCAAMJAgwVOgCfAAACAAIJ+g4VOgCfAAARAAEJEwbCGABMAAAuAAQKfxQABBEABwmtHGASALkBABEABQnoIGASALkBACEAAwnXHTYWANEAAAIAAwmOEAnQALoAAAAA.',
['珊迪']='珊迪:BAAALgADCgcJBwAAAA==.',
['瑛嫣']='瑛嫣:BAAALgAECgQJBAAAAA==.',
['瑶瑶']='瑶瑶翊柔丶:BAAALgAFFAIJBAAAAA==.',
['甄楠']='甄楠:BAAALgAFFAIJAgAAAA==.',
['甜甜']='甜甜小香肠:BAABLgAECn8gAAIiAAcJ0CI8BQC6AgAiAAcJ0CI8BQC6AgAAAA==.',
['生辰']='生辰华夫饼:BAAALgAECgYJCAAAAA==.',
['电竞']='电竞不要视力:BAAALgAECgUJCAAAAA==.',
['画角']='画角闻龙:BAABLgAFFH8FAAIMAAIJdR5FBwC+AAAMAAIJdR5FBwC+AAAAAA==.',
['略略']='略略大魔王:BAAALgAECgkJCQAAAA==.',
['番茄']='番茄味的黄瓜:BAAALgAECgYJEAAAAA==.',
['疾风']='疾风暴雨:BAAALgADCgMJAwAAAA==.',
['白茶']='白茶丶清欢:BAAALgAECgYJCwAAAA==.',
['白银']='白银之咪:BAAALgAECgYJBgABLgAFFAQJDgAVAE4QAA==.',
['百木']='百木园园长:BAABLgAFFH8GAAIjAAIJ4hIrDACRAAAjAAIJ4hIrDACRAAAAAA==.',
['百步']='百步穿阳:BAAALgAECgQJBAAAAA==.',
['百里']='百里东君:BAAALgAECgcJCAABLgAFFAQJDAANAP4jAA==.',
['皮皮']='皮皮嘎嘎香:BAAALgAFFAIJAgAAAA==.',
['看我']='看我颜色行事:BAAALgAECgYJCAAAAA==.',
['眠月']='眠月坠星河:BAAALgAFFAMJBAAAAA==.',
['瞎瞎']='瞎瞎子:BAABLgAFFH8FAAIJAAMJxAwmHQDrAAAJAAMJxAwmHQDrAAAAAA==.',
['知足']='知足长乐:BAAALgAECgQJBwAAAA==.',
['砍树']='砍树的熊大:BAAALgADCgEJAQAAAA==.',
['砰砰']='砰砰来咯:BAAALgAECgIJAgAAAA==.',
['破晓']='破晓圣使:BAAALgAECgkJDwAAAA==.',
['碎星']='碎星沉月:BAABLgAFFH8HAAQiAAQJ0RhzAgAeAQAiAAMJ6BZzAgAeAQAUAAMJZhLFFQDtAAAQAAEJqxdPIABgAAAAAA==.',
['碰我']='碰我就炸气:BAACLgAFFH8HAAIFAAMJ+BpyDQAWAQAFAAMJ+BpyDQAWAQAuAAQKfxQAAgUABwkTHRkYAFUCAAUABwkTHRkYAFUCAAAA.',
['磁暴']='磁暴辣椒:BAAALgAECgYJBgABLgAFFAMJBwAEAFshAA==.',
['社会']='社会你黄哥:BAAALgAECgQJBwAAAA==.',
['祖卡']='祖卡尔:BAAALgADCgYJBgAAAA==.',
['神使']='神使僧:BAAALgAECgEJAQAAAA==.',
['神秘']='神秘人:BAABLgAECn8VAAIjAAcJihclHwAIAgAjAAcJihclHwAIAgAAAA==.神秘练习生丶:BAACLgAFFH8GAAIBAAMJlhT+KAAQAQABAAMJlhT+KAAQAQAuAAQKfxcAAgEABwlJHQlVADkCAAEABwlJHQlVADkCAAAA.',
['神赵']='神赵子龙:BAAALgAECgEJAQAAAA==.',
['秀到']='秀到起飞:BAAALgAFFAIJAwAAAA==.',
['秀的']='秀的脑壳疼:BAAALgADCgcJBwAAAA==.',
['秋水']='秋水宵灯:BAAALgAECgQJBAAAAA==.',
['秋池']='秋池海棠:BAAALgAFFAIJAgAAAA==.',
['穿裤']='穿裤衩:BAAALgAECgIJAQAAAA==.',
['窝才']='窝才是奶龙:BAAALgADCgEJAQABLgAECgcJBwADAAAAAA==.',
['童年']='童年的橡皮擦:BAAALgAFFAIJAgAAAA==.童年的水彩笔:BAAALgAFFAIJAgAAAA==.',
['笙歌']='笙歌尽散:BAAALgAECgQJBAAAAA==.',
['第九']='第九重奏:BAAALgAFFAIJAgAAAA==.',
['等我']='等我狗先上:BAAALgAECgUJBQAAAA==.',
['筱雾']='筱雾:BAABLgAECn8aAAISAAgJjRUJLgD1AQASAAgJjRUJLgD1AQAAAA==.',
['简久']='简久久:BAAALgADCgYJBgAAAA==.',
['粉红']='粉红的雪花丶:BAAALgAECgYJCQAAAA==.',
['精序']='精序兵戈:BAABLgAFFH8GAAIjAAIJchWyDACKAAAjAAIJchWyDACKAAAAAA==.',
['糖是']='糖是挺唐的:BAAALgAFFAEJAQAAAA==.',
['糖果']='糖果瓣瓣:BAAALgAECgIJAgAAAA==.糖果贝贝:BAABLgAECn8cAAIfAAgJ+A6FEQCvAQAfAAgJ+A6FEQCvAQAAAA==.',
['糖醋']='糖醋板拦根:BAAALgAECgIJAgAAAA==.',
['糖门']='糖门也是红手:BAAALgAECgkJCgAAAA==.',
['紫浅']='紫浅风清:BAAALgAECgEJAQAAAA==.',
['紫鼠']='紫鼠鼠饼:BAAALgADCgEJAQAAAA==.',
['红狼']='红狼:BAAALgAECgIJAgAAAA==.',
['红蓝']='红蓝绿小灯泡:BAAALgAECgYJDAAAAA==.',
['红衣']='红衣术:BAAALgAECggJDwAAAA==.',
['纳兰']='纳兰二品品:BAAALgADCgEJAQAAAA==.',
['绝代']='绝代冰皇:BAAALgAECgIJAgAAAA==.',
['绣虎']='绣虎丶:BAAALgAFFAEJAQAAAA==.',
['绯色']='绯色苍穹:BAAALgAECgYJCQABLgAFFAMJBgAQAJMWAA==.',
['绿茶']='绿茶红:BAAALgAECgUJCAAAAA==.',
['缅因']='缅因喵灬财哥:BAAALgAECgMJBQAAAA==.',
['缇坦']='缇坦妮雅:BAAALgAFFAIJAgABLgAFFAMJCQAYACwiAA==.',
['缥缈']='缥缈小德:BAAALgAECgIJAgAAAA==.',
['羊丶']='羊丶超越:BAAALgAFFAIJAgAAAA==.',
['羊超']='羊超越:BAAALgAFFAEJAQAAAA==.',
['羽烬']='羽烬:BAAALgAECgUJBwAAAA==.',
['翎光']='翎光丶奇迹:BAAALgAECgYJDQAAAA==.',
['联通']='联通联不通:BAAALgADCgMJAwAAAA==.',
['聖光']='聖光一擊:BAAALgAECgMJBQABLgAFFAUJBQAkAFMlAA==.聖光魅魔:BAAALgAFFAIJBAABLgAFFAQJCgACACETAA==.',
['聪明']='聪明穴居人:BAAALgADCgQJBAAAAA==.',
['肉村']='肉村拓哉:BAAALgAECgUJBQAAAA==.',
['肥猫']='肥猫:BAAALgAECgEJAQAAAA==.',
['肥肥']='肥肥只吃一个:BAAALgAECgkJAgAAAA==.',
['胡日']='胡日图了:BAAALgADCgUJBQAAAA==.',
['胡渣']='胡渣小骑士:BAAALgAECgYJBgAAAA==.',
['自然']='自然之谜:BAABLgAFFH8FAAIQAAIJPxy7EgC3AAAQAAIJPxy7EgC3AAAAAA==.自然给我人品:BAAALgAECgYJDQAAAA==.',
['至高']='至高岭:BAABLgAFFH8FAAIlAAUJ1RwAAAAAAAAZAAUJ1RwAAAAAAAAAAA==.',
['舞月']='舞月蓝火:BAAALgAECgkJBwAAAA==.',
['艾利']='艾利西亚:BAAALgAECggJDQAAAA==.',
['艾瑞']='艾瑞克王:BAAALgAECgEJAQAAAA==.',
['艾莉']='艾莉罗拉:BAAALgAECgUJCQAAAA==.',
['芝士']='芝士小猎手:BAAALgAECgYJBgAAAA==.芝士蛋总:BAAALgAECgIJAgABLgAECgcJBwADAAAAAA==.',
['芥末']='芥末萝莉:BAAALgADCgIJAgAAAA==.芥末豆儿:BAAALgADCgIJAgAAAA==.',
['芬芳']='芬芳杜鹃:BAACLgAFFH8GAAISAAIJLBG8GgCRAAASAAIJLBG8GgCRAAAuAAQKfx8AAhIACAkwIo0KAO4CABIACAkwIo0KAO4CAAAA.',
['花剌']='花剌子模:BAAALgAECgYJEgAAAA==.',
['花卷']='花卷丶:BAAALgAECgEJAQAAAA==.',
['花右']='花右菁:BAAALgAECgcJBwAAAA==.',
['花开']='花开富贵丶:BAAALgAECgEJAQAAAA==.',
['花心']='花心炸炸:BAAALgAECgUJCQAAAA==.花心菜大叔:BAABLgAECn8XAAILAAcJmx1TJgD6AQALAAcJmx1TJgD6AQAAAA==.',
['花月']='花月丶凝悠:BAAALgAECgIJAgAAAA==.',
['花未']='花未眠:BAAALgADCgUJBQAAAA==.',
['花村']='花村达克尼斯:BAAALgAECgUJBgAAAA==.',
['花栉']='花栉妱榐:BAAALgAECgYJCAAAAA==.',
['花铃']='花铃铛:BAAALgADCgUJBgAAAA==.',
['芳猪']='芳猪:BAAALgAECgUJBQAAAA==.',
['苏丶']='苏丶:BAAALgAECgEJAQAAAA==.',
['苞娜']='苞娜:BAAALgAECgIJAgAAAA==.',
['苦苦']='苦苦的咖啡:BAAALgAECgMJAwAAAA==.',
['苹果']='苹果小夜:BAAALgADCgMJAwAAAA==.',
['范无']='范无咎灬:BAAALgADCgIJAgAAAA==.',
['茫國']='茫國丶寶銃:BAACLgAFFH8FAAICAAMJyhXuHQAMAQACAAMJyhXuHQAMAQAuAAQKfxcAAwIABwknGl5oAJMBAAIABQlmG15oAJMBABEAAwl0E6Q8AMIAAAAA.',
['草野']='草野优衣:BAAALgAECgQJBAAAAA==.',
['荒天']='荒天猎:BAAALgAECgYJBgAAAA==.',
['荒寺']='荒寺梦红尘:BAAALgAECgcJDAAAAA==.',
['荼萘']='荼萘:BAEBLgAFFH8FAAIVAAQJGg74BAA+AQAVAAQJGg74BAA+AQABLgAFFAUJEAAEAPUlAA==.',
['莎嘉']='莎嘉斯丶星焰:BAAALgAECgEJAQAAAA==.',
['莫德']='莫德凯撒:BAAALgAECgEJAQAAAA==.',
['莫斯']='莫斯提马:BAAALgADCgQJBAAAAA==.',
['莫求']='莫求得名堂:BAAALgAECgEJAQAAAA==.',
['莫莫']='莫莫:BAAALgADCgYJDAAAAA==.',
['菠萝']='菠萝拌饭:BAAALgAECgYJDgAAAA==.',
['菲可']='菲可老爹:BAAALgAECgEJAgAAAA==.',
['萌萌']='萌萌死小孩:BAABLgAECn8XAAIQAAcJxw2nQgClAQAQAAcJxw2nQgClAQAAAA==.',
['落幕']='落幕灬殇春:BAAALgAECgEJAQAAAA==.',
['葬雪']='葬雪蔷薇:BAABLgAFFH8JAAIBAAMJTRpyJwAVAQABAAMJTRpyJwAVAQAAAA==.',
['蒜香']='蒜香牛蛙:BAAALgADCgEJAQAAAA==.',
['蓝星']='蓝星的剑仙:BAAALgAECgEJAQAAAA==.',
['蓝桥']='蓝桥易乞:BAAALgAECgYJBgAAAA==.',
['蓝色']='蓝色伯爵:BAAALgAECgUJCwAAAA==.',
['薄荷']='薄荷:BAAALgAECgEJAQAAAA==.',
['虽有']='虽有嘉瑶:BAAALgADCgYJBgAAAA==.',
['蜀黍']='蜀黍我啊:BAAALgAFFAIJAgAAAA==.',
['融媒']='融媒尖刀班:BAAALgADCgUJBQAAAA==.',
['血圣']='血圣骑:BAAALgAECgIJAgAAAA==.',
['血来']='血来你不炸了:BAAALgAFFAIJBAAAAA==.',
['行歌']='行歌:BAAALgAFFAQJBAAAAA==.',
['西门']='西门凝雪:BAABLgAECn8UAAQCAAgJ6hGmdwBtAQACAAYJGRKmdwBtAQAhAAEJAABTKQBNAAARAAEJzhDTagA9AAAAAA==.',
['要乐']='要乐奈:BAAALgAECgYJDAAAAA==.',
['观沧']='观沧海:BAAALgAECgQJBwAAAA==.',
['认准']='认准正版龙喷:BAAALgAFFAEJAQAAAA==.',
['记忆']='记忆中的失忆:BAAALgADCgQJBAAAAA==.',
['该小']='该小枪:BAAALgAECgkJCgAAAA==.',
['谜之']='谜之眼神丶:BAAALgAECgQJBAAAAA==.',
['豪饮']='豪饮抹茶刘奶:BAAALgAECgIJAwAAAA==.',
['賢者']='賢者樹叢:BAAALgAECgYJBgAAAA==.',
['财丨']='财丨多多灬:BAAALgADCgYJBgAAAA==.',
['贰譊']='贰譊姐丶驾到:BAAALgAECgYJBgAAAA==.',
['贵妃']='贵妃椅:BAAALgAECgUJBQAAAA==.',
['赈早']='赈早见琥珀主:BAAALgAECgUJBQAAAA==.',
['赫符']='赫符:BAAALgADCgUJBQAAAA==.',
['走丢']='走丢的小牛:BAAALgAECgYJCwAAAA==.',
['超威']='超威蓝猫:BAAALgAECgUJCQAAAA==.',
['超炫']='超炫耀:BAAALgAECgYJCAAAAA==.',
['超级']='超级丰川祥子:BAAALgADCgUJBQAAAA==.超级大蓝莓:BAAALgADCgIJAgAAAA==.超级工具牛:BAAALgAFFAIJAgAAAA==.超级暴暴回:BAAALgAECgEJAQAAAA==.',
['路边']='路边蹲一狼:BAAALgADCggJDAAAAA==.',
['轩辕']='轩辕龙行:BAAALgADCgEJAQAAAA==.',
['辉耀']='辉耀:BAEALgAECgYJEgABLgAECgYJDgADAAAAAA==.',
['辛骓']='辛骓:BAABLgAECn8VAAQOAAkJPg58FAAGAgAOAAkJPg58FAAGAgAXAAYJMQfZPAAMAQAYAAIJXAgDdQBVAAAAAA==.',
['辰花']='辰花离海:BAAALgADCgEJAQAAAA==.',
['边边']='边边小婕妤:BAAALgAECgEJAQAAAA==.边边小竹五:BAAALgAECgQJBQAAAA==.',
['达拉']='达拉然乳业:BAAALgADCgcJCAAAAA==.',
['还在']='还在害人:BAAALgAFFAQJBAAAAA==.',
['这一']='这一剑很帅:BAAALgAECgIJAgAAAA==.',
['远坂']='远坂凛的手镯:BAAALgAFFAIJAwAAAA==.',
['迦勒']='迦勒底圣骑:BAAALgAECgYJCAAAAA==.',
['迷失']='迷失的小小德:BAAALgAECgYJBgAAAA==.',
['迷迭']='迷迭香的味道:BAAALgAECgEJAQAAAA==.',
['迷雾']='迷雾之上:BAAALgADCgYJBgAAAA==.',
['逆天']='逆天一圣骑:BAAALgAECgMJBgAAAA==.',
['逍遥']='逍遥小猪:BAAALgAECgYJBgAAAA==.',
['逐日']='逐日者豪森:BAABLgAECn8UAAIdAAgJ0RorAQC4AgAdAAgJ0RorAQC4AgAAAA==.',
['遥远']='遥远彼方:BAAALgAECgEJAQAAAA==.',
['那个']='那个法斯:BAAALgAECgYJCwAAAA==.那个狂暴战:BAAALgAECgQJBAAAAA==.',
['邪能']='邪能咖啡机:BAACLgAFFH8OAAIVAAQJThCkBQArAQAVAAQJThCkBQArAQAuAAQKfx8AAhUACAk3HGEOAJcCABUACAk3HGEOAJcCAAAA.',
['郝危']='郝危险:BAAALgAECgEJAgAAAA==.',
['部落']='部落丽人:BAABLgAECn8VAAIQAAcJGBsPKAAYAgAQAAcJGBsPKAAYAgAAAA==.',
['酒临']='酒临风:BAAALgAECgEJAQAAAA==.',
['酒花']='酒花橙子:BAAALgAFFAIJAwAAAA==.',
['酱香']='酱香牛柳:BAAALgAECgcJEwABLgAFFAUJBAADAAAAAA==.',
['醉宿']='醉宿的黑眼圈:BAAALgAECgYJBwAAAA==.',
['重返']='重返小战:BAAALgAECgcJDQAAAA==.重返小牛:BAAALgAECgcJDgAAAA==.重返小猎:BAAALgAECgUJAgAAAA==.重返暗影:BAABLgAECn8ZAAQMAAcJ2xqmEABcAgAMAAcJ2xqmEABcAgAkAAUJ8wuDGADaAAAJAAQJnQQfOQB7AAAAAA==.重返神骑士:BAAALgAECgcJDgAAAA==.',
['野性']='野性小德:BAAALgADCgcJDgAAAA==.野性百年:BAAALgAECgMJBQAAAA==.',
['野良']='野良神:BAAALgAECgcJBwAAAA==.',
['鎏云']='鎏云焕:BAAALgAFFAIJAwAAAA==.',
['钢铁']='钢铁圣令图腾:BAAALgAECgEJAQAAAA==.',
['钻石']='钻石星宸拳:BAAALgAECgIJAgAAAA==.',
['银魔']='银魔射:BAAALgAECgEJAQABLgAFFAIJBQACAM4gAA==.银魔术:BAABLgAFFH8FAAICAAIJziDHKQDLAAACAAIJziDHKQDLAAAAAA==.',
['锟子']='锟子:BAABLgAFFH8MAAITAAQJcRqEBwBpAQATAAQJcRqEBwBpAQAAAA==.',
['镇岳']='镇岳:BAAALgAECgYJBgAAAA==.',
['開錵']='開錵:BAAALgADCgEJAQAAAA==.',
['闪现']='闪现肥肉:BAAALgAECgUJBQAAAA==.',
['闪耀']='闪耀的杏奈:BAAALgAECgEJAQAAAA==.',
['闷西']='闷西瓜:BAAALgAECgEJAQAAAA==.',
['阿九']='阿九的牛脾气:BAAALgAECgcJDQAAAA==.',
['阿卜']='阿卜杜库杜斯:BAAALgADCgUJBQAAAA==.',
['阿发']='阿发撒:BAAALgAECgUJBQAAAA==.',
['阿拉']='阿拉塔尔:BAAALgAECgYJDAAAAA==.',
['阿斯']='阿斯蒂芬威廉:BAAALgAECgQJBAAAAA==.',
['阿梵']='阿梵达:BAAALgAECgMJAwAAAA==.',
['阿爾']='阿爾馮斯:BAABLgAECn8XAAIfAAcJehDMFwBZAQAfAAcJehDMFwBZAQAAAA==.',
['阿福']='阿福灌注:BAAALgADCgEJAQAAAA==.',
['阿超']='阿超短小快:BAAALgADCgQJBAAAAA==.',
['陈千']='陈千语:BAAALgAECgEJAQAAAA==.',
['陈曉']='陈曉薇:BAAALgADCgMJAwAAAA==.',
['陈真']='陈真:BAAALgAECgEJAgAAAA==.',
['陌莫']='陌莫:BAAALgAFFAEJAQAAAA==.',
['随便']='随便五号:BAACLgAFFH8OAAMXAAQJfhBKCABCAQAXAAQJfhBKCABCAQAOAAMJ/Q9LGQBLAAAuAAQKfxcAAw4ABwkDHjYXAOYBAA4ABgmZHjYXAOYBABcABwncF3g4ACsBAAAA.随便赫赫:BAAALgAECgEJAQAAAA==.',
['随风']='随风飘泊:BAAALgAECgIJAgAAAA==.',
['隔壁']='隔壁家的小三:BAAALgAECgkJCAAAAA==.',
['集火']='集火那个汤包:BAAALgAECgEJAQAAAA==.',
['雨潇']='雨潇潇兮:BAAALgAECgcJBwAAAA==.',
['雨落']='雨落雪未弦:BAAALgAECgYJCAAAAA==.',
['雪菈']='雪菈:BAAALgAECgkJCQABLgAFFAUJDAANAAshAA==.',
['零三']='零三:BAAALgADCgMJBAAAAA==.',
['零零']='零零奥:BAAALgAECgQJBgAAAA==.',
['雾萌']='雾萌萌丶小鬼:BAAALgADCggJDgAAAA==.',
['雾辞']='雾辞:BAAALgAFFAIJAgAAAA==.',
['雾里']='雾里聆风曲:BAAALgADCgIJAgAAAA==.',
['霁夜']='霁夜幻影:BAABLgAECn8XAAIKAAcJbCUREQCKAgAKAAcJbCUREQCKAgAAAA==.',
['霜刃']='霜刃丶征服者:BAAALgAFFAEJAQAAAA==.',
['青刺']='青刺鱼我李凉:BAAALgADCgQJBAAAAA==.',
['青山']='青山雾雨:BAAALgAECgEJAQAAAA==.',
['青石']='青石巷:BAAALgAECgIJAgAAAA==.',
['青綰']='青綰:BAAALgAECgkJCQAAAA==.',
['青雅']='青雅白鹿:BAAALgAECgUJBQAAAA==.',
['青龙']='青龙雪:BAAALgAECgQJBAAAAA==.',
['面目']='面目全非脚:BAAALgAFFAIJAgAAAA==.',
['鞠婧']='鞠婧祎太甜咯:BAAALgAECgMJAwAAAA==.鞠婧祎好甜咯:BAAALgAECgYJDQAAAA==.',
['须弥']='须弥吟雪:BAAALgAFFAEJAQAAAA==.',
['風神']='風神潇洒:BAAALgAECgkJDQAAAA==.',
['风中']='风中雨露:BAAALgADCgYJBgAAAA==.',
['风流']='风流小鸟:BAAALgADCgYJBgAAAA==.',
['风语']='风语丶诉衷情:BAAALgADCgQJBAAAAA==.',
['飛燕']='飛燕:BAABLgAECn8bAAQCAAgJfyR5HACqAgACAAcJjCB5HACqAgARAAQJIRKkKwARAQAhAAEJAACcHwB0AAAAAA==.',
['饕餮']='饕餮海:BAAALgAECgEJAQAAAA==.',
['饺子']='饺子:BAAALgAFFAIJBAAAAA==.饺子配咖啡:BAAALgAECgYJBgAAAA==.',
['香辣']='香辣蟹黄堡:BAAALgADCgQJBAAAAA==.',
['驚鴻']='驚鴻:BAAALgAECgcJEQAAAA==.',
['马卡']='马卡巴卡:BAAALgAFFAIJAgAAAA==.',
['马进']='马进:BAAALgAECgkJBwAAAA==.',
['骑士']='骑士猎:BAAALgAECgUJBgAAAA==.',
['骑马']='骑马傀儡师:BAAALgAECgEJAQAAAA==.',
['骤亡']='骤亡者约西撒:BAAALgAECgUJBgAAAA==.',
['骰子']='骰子王:BAAALgAECgIJAQAAAA==.',
['高富']='高富美:BAAALgADCgIJAgAAAA==.',
['高文']='高文:BAAALgAECgEJAQAAAA==.',
['鬥姆']='鬥姆元君:BAAALgAECgMJAwAAAA==.',
['鬼彻']='鬼彻:BAAALgAECgcJDwAAAA==.',
['鬼猎']='鬼猎猎:BAAALgADCgQJBAAAAA==.',
['魅影']='魅影星辰:BAAALgAFFAIJAgAAAA==.',
['魔草']='魔草哈:BAAALgADCgcJDwAAAA==.',
['鱼人']='鱼人也想进步:BAABLgAFFH8FAAIbAAMJPwnnDgACAQAbAAMJPwnnDgACAQAAAA==.',
['鱼灰']='鱼灰:BAAALgAFFAIJAgABLgAFFAEJAQADAAAAAA==.',
['鸡蛋']='鸡蛋花丶:BAAALgAFFAMJAwAAAA==.',
['麦辣']='麦辣鸡腿堡:BAAALgAFFAEJAQABLgAFFAYJEAAFAE0iAA==.',
['麻辣']='麻辣香粿:BAAALgAECgkJCQAAAA==.',
['黍黍']='黍黍:BAAALgAECgkJCQAAAA==.',
['黎枫']='黎枫:BAAALgAECgQJBgAAAA==.',
['黑人']='黑人丨:BAACLgAFFH8OAAMEAAUJLR+uDABxAQAEAAQJLR+uDABxAQAHAAEJAAA2HAAmAAAuAAQKfyAAAgQACQkeIE4kAK0CAAQACQkeIE4kAK0CAAAA.',
['黑咖']='黑咖丶:BAAALgAECgkJEAAAAA==.',
['黑桃']='黑桃武僧:BAAALgAECgcJBwAAAA==.',
['黑白']='黑白丶与或:BAAALgAECgcJEgAAAA==.黑白年华:BAAALgAECgYJBwAAAA==.',
['黑蝙']='黑蝙蝠:BAAALgAECgEJAQAAAA==.',
['黯夜']='黯夜修罗:BAAALgAECgQJBAAAAA==.黯夜妖神:BAAALgAECgQJAgAAAA==.',
['黯河']='黯河魅影:BAAALgADCgQJBAAAAA==.',
['齐的']='齐的龙东强:BAAALgAECgcJBQAAAA==.',
['龙战']='龙战天:BAACLgAFFH8MAAINAAQJ/iNtBQCgAQANAAQJ/iNtBQCgAQAuAAQKfx4AAg0ACAlMJfEBAF0DAA0ACAlMJfEBAF0DAAAA.',
['龙神']='龙神:BAAALgAECgIJAgAAAA==.',
['龙饮']='龙饮景天:BAAALgAECgEJAQAAAA==.',
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
