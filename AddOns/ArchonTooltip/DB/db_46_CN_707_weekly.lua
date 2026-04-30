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

local lookup = {'DeathKnight-Unholy','Unknown-Unknown','Mage-Frost','Paladin-Retribution','Evoker-Preservation','Druid-Restoration','Hunter-Marksmanship','Hunter-Survival','Evoker-Augmentation','Priest-Holy','Paladin-Holy','DemonHunter-Devourer','Priest-Shadow','Warlock-Demonology','Hunter-BeastMastery','Priest-Discipline','Druid-Balance','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','Warlock-Affliction','Paladin-Any','Paladin-Protection','Monk-Windwalker','Monk-Brewmaster','Rogue-Subtlety','Evoker-Devastation','Rogue-Assassination','Mage-Arcane','DeathKnight-Frost','Warlock-Destruction','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Mistweaver','Warrior-Arms','Warrior-Protection','Rogue-Outlaw','Druid-Guardian','DeathKnight-Blood',}
local provider = {region='CN',realm='月光林地',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Acgdk:BAAALgAECgkJEQABLgAECgkJJQABAOQkAA==.',
Al='Alanhunter:BAAALgAECgYJCQABLgAFFAIJAgACAAAAAA==.Alanmagic:BAAALgAECgcJCgABLgAFFAIJAgACAAAAAA==.Alanpriest:BAAALgAFFAIJAgAAAA==.Alanwarlock:BAAALgAECgYJCQABLgAFFAIJAgACAAAAAA==.',
An='Ansend:BAAALgAECgUJBQAAAA==.',
Ar='Aroohàn:BAAALgADCgMJAwAAAA==.',
As='Asakiw:BAAALgADCgEJAQAAAA==.Asgar:BAAALgAECgEJAgAAAA==.Ashae:BAAALgAECgEJAgAAAA==.Ashura:BAAALgAECgYJCQAAAA==.',
Br='Broccoli:BAAALgAECgYJCwAAAA==.',
Ca='Casted:BAAALgAECgMJAwAAAA==.Casting:BAABLgAECn8WAAIDAAYJgSEVWAAxAgADAAYJgSEVWAAxAgAAAA==.',
Ch='Chensha:BAAALgADCgYJBgAAAA==.',
Co='Cocohunter:BAAALgAECgYJDAAAAA==.Cocopala:BAAALgADCgcJDgAAAA==.',
Da='Darkangel:BAAALgADCgEJAQAAAA==.Darksaber:BAAALgAFFAIJAgAAAA==.',
Dl='Dll:BAAALgADCgEJAQAAAA==.',
Do='Dogday:BAAALgAECgEJAQAAAA==.',
Dr='Drangonbaby:BAAALgAECggJCAAAAA==.',
Du='Duriantree:BAAALgAECgYJBgAAAA==.',
Ee='Eeric:BAAALgAECgUJDwAAAA==.',
El='Elde:BAAALgAECgUJBQAAAA==.',
Fa='Fatefake:BAAALgAECgkJEAAAAA==.',
Fl='Flysnail:BAAALgAECgMJAwAAAA==.',
Ga='Galvatron:BAAALgAECgYJDwAAAA==.',
Gj='Gjingz:BAAALgAFFAEJAQAAAA==.',
Gt='Gts:BAAALgAECgEJAgAAAA==.',
Ha='Hakureiyoumu:BAAALgAECgcJCAAAAA==.',
Hi='Hiroshi:BAAALgAECgEJAgAAAA==.',
Ic='Icestone:BAAALgAECgYJBgAAAA==.Icy:BAAALgADCgEJAQAAAA==.',
In='Infraction:BAAALgAECgQJBAAAAA==.',
Ji='Jingz:BAAALgAECgcJDQAAAA==.',
Ka='Kaelen:BAAALgAECgEJAQAAAA==.Karlz:BAABLgAFFH8FAAIDAAIJwhcyOgC2AAADAAIJwhcyOgC2AAABLgAFFAUJAQACAAAAAA==.Kateline:BAAALgAECgYJBgAAAA==.',
Ke='Kelsus:BAAALgAECgYJBgAAAA==.',
Ki='Kiri:BAAALgAECgYJBgAAAA==.',
Kj='Kjingz:BAAALgAECgcJBgAAAA==.',
Ko='Kodomo:BAAALgADCgYJBgAAAA==.Koeus:BAACLgAFFH8GAAIEAAMJFSBvEAAiAQAEAAMJFSBvEAAiAQAuAAQKfx0AAgQACAmHI+0PAA8DAAQACAmHI+0PAA8DAAAA.Konstantin:BAAALgAFFAMJAwAAAA==.Konstantine:BAAALgAECgUJBQAAAA==.',
La='Labrynth:BAAALgAECgkJBgAAAA==.Lamomo:BAAALgAFFAQJBAAAAA==.',
Le='Leonardolol:BAAALgAECgQJBQAAAA==.Leonshaman:BAAALgAECgkJAgAAAA==.',
Lu='Lumière:BAAALgADCgYJCwAAAA==.',
Me='Meeball:BAAALgAECgMJAwAAAA==.',
Mi='Midnight:BAABLgAECn8XAAIBAAgJthXJUAD/AQABAAgJthXJUAD/AQAAAA==.',
Mo='Moira:BAAALgAECgYJDgAAAA==.',
Nh='Nhelv:BAAALgADCgcJCAAAAA==.',
No='Nobodylove:BAAALgAECgYJCwAAAA==.',
Or='Ori:BAAALgADCgYJBgABLgAFFAQJDAAFAGkcAA==.Original:BAAALgADCgEJAQAAAA==.',
Pa='Papaya:BAAALgADCgYJBgABLgAECgYJBgACAAAAAA==.',
Pd='Pdade:BAAALgAECgIJAgABLgAECgYJEQACAAAAAA==.',
Ph='Phaethon:BAAALgAECgQJBAAAAA==.Pharaoh:BAABLgAFFH8IAAIGAAQJmhUbCABQAQAGAAQJmhUbCABQAQAAAA==.',
Pp='Pphil:BAAALgAFFAIJAwAAAA==.',
Py='Pyrista:BAAALgAECgMJBAAAAA==.',
Ra='Rainfoam:BAABLgAECn8ZAAIEAAcJiyFNKQCAAgAEAAcJiyFNKQCAAgAAAA==.',
Re='Reze:BAAALgAECgYJDQAAAA==.',
Rh='Rhadamanthos:BAAALgAECggJCAAAAA==.',
Ri='Rivendale:BAABLgAFFH8FAAIBAAIJzCKsEwC9AAABAAIJzCKsEwC9AAAAAA==.',
Se='Seane:BAAALgAECgEJAQAAAA==.Selene:BAAALgAECgYJCwAAAA==.',
Sh='Shana:BAAALgAECgEJAQAAAA==.',
Sm='Smaug:BAAALgAECgcJCAAAAA==.',
So='Solaria:BAAALgAECgEJAQAAAA==.Southqian:BAAALgAECgYJCwAAAA==.',
Sp='Spårda:BAABLgAECn8eAAMHAAYJMRr/LQC+AQAHAAYJYRn/LQC+AQAIAAYJSRKOHQAAAQAAAA==.',
Su='Suu:BAAALgAECgMJAwAAAA==.',
Ta='Tajraturunen:BAAALgAECgIJAgAAAA==.',
Te='Teotw:BAAALgAECgEJAQAAAA==.',
Ti='Tizii:BAAALgAECgkJCgAAAA==.',
Um='Umeko:BAAALgAECgEJAQAAAA==.',
Un='Uncledh:BAAALgAECgkJCQAAAA==.',
Ve='Venruki:BAAALgADCgcJBwABLgAFFAMJBgAJALchAA==.',
Vi='Victoriawang:BAAALgAECgYJCgAAAA==.',
Wi='Wilder:BAAALgADCgcJCAAAAA==.Wini:BAAALgAECgkJCQAAAA==.',
Xj='Xjingz:BAAALgAECgcJDQAAAA==.',
Ye='Yeti:BAAALgAECgEJAgAAAA==.',
Za='Zaken:BAAALgAECgEJAQAAAA==.Zanemíchaël:BAAALgAECgcJDwAAAA==.',
Zo='Zoken:BAAALgAECgEJAgAAAA==.',
['一个']='一个桃子:BAAALgAECgYJBgAAAA==.',
['一只']='一只修狗:BAAALgADCgUJBQAAAA==.一只可爱咕:BAAALgAECgYJBgABLgAFFAMJBQAKAO0dAA==.一只幸运喵:BAAALgAECgQJBAAAAA==.',
['一喜']='一喜羊羊一:BAAALgAFFAEJAQAAAA==.',
['一念']='一念放下:BAAALgAECgEJAQAAAA==.',
['一慣']='一慣性背叛一:BAAALgAECgQJBAAAAA==.',
['一手']='一手烟火:BAAALgADCgIJAgAAAA==.',
['一盏']='一盏孤灯:BAAALgAECggJEAAAAA==.',
['一马']='一马平川:BAAALgAECgYJCAAAAA==.',
['万世']='万世古柯:BAAALgAECgEJAwAAAA==.',
['三味']='三味书屋:BAAALgAECgYJDAAAAA==.',
['三国']='三国志:BAAALgAECgUJBQAAAA==.',
['三拾']='三拾五:BAACLgAFFH8IAAILAAMJhxK3BgDiAAALAAMJhxK3BgDiAAAuAAQKfyMAAwsACAlIIA0KANICAAsACAlIIA0KANICAAQAAQmiDSYzAT4AAAAA.',
['三马']='三马尾正道:BAAALgAECgQJBAAAAA==.',
['不乖']='不乖的乖乖:BAAALgAECgEJAgAAAA==.',
['不出']='不出货:BAAALgAECgYJDwAAAA==.',
['不咸']='不咸的咸鱼:BAAALgAECgEJAQAAAA==.',
['与众']='与众不同:BAAALgADCgEJAQAAAA==.',
['两眼']='两眼一抹黑:BAAALgAECgUJCAABLgAFFAUJBQAMAN8aAA==.',
['丨南']='丨南鸢离梦丨:BAAALgAFFAEJAQAAAA==.',
['丨孔']='丨孔雀丨:BAAALgAECgYJBwAAAA==.',
['丨岩']='丨岩谷尚文丨:BAAALgAECgUJBQABLgAFFAEJAQACAAAAAA==.',
['丨胭']='丨胭脂雪丨:BAAALgAECgkJCgAAAA==.',
['丨风']='丨风筝丨:BAAALgAECgEJAQAAAA==.',
['个人']='个人哎好:BAAALgAECgEJAQAAAA==.',
['临沧']='临沧坚果:BAAALgAECgYJBgABLgAECgYJBgACAAAAAA==.',
['丶六']='丶六六:BAAALgAECgkJCQABLgAECgkJJQABAOQkAA==.',
['丶小']='丶小敏:BAAALgAFFAQJBAAAAA==.',
['丶猫']='丶猫南北:BAAALgAECgUJCQAAAA==.',
['为此']='为此春酒:BAABLgAECn8aAAINAAcJJBpnGAAfAgANAAcJJBpnGAAfAgAAAA==.',
['久处']='久处亦怦然:BAAALgAECgkJEQABLgAECgkJJQABAOQkAA==.',
['九亭']='九亭:BAAALgAECgQJBAABLgAECggJHgAOAHAdAA==.',
['九月']='九月的小术:BAAALgADCgEJAQAAAA==.',
['予你']='予你:BAAALgAECgEJAQAAAA==.',
['二八']='二八二五六:BAAALgAECgUJBQAAAA==.',
['二重']='二重奏:BAAALgAECgcJBwAAAA==.',
['云之']='云之乐:BAAALgAECgMJBAAAAA==.云之珊珊:BAAALgADCgEJAQAAAA==.',
['云涧']='云涧唤雷:BAAALgAECgQJBgAAAA==.',
['云螭']='云螭:BAAALgAECgcJEgAAAA==.',
['亚历']='亚历山大王:BAAALgAECgYJBgAAAA==.',
['亚路']='亚路嘉:BAAALgADCgcJDQAAAA==.',
['亡之']='亡之转生者:BAAALgAECgkJAQAAAA==.',
['亡月']='亡月之光:BAABLgAECn8ZAAIBAAgJSRq2RQAjAgABAAgJSRq2RQAjAgAAAA==.',
['人在']='人在囧途:BAAALgAECgQJBwAAAA==.',
['人美']='人美路子野:BAAALgAECgkJBwABLgAFFAcJBgAJADUaAA==.',
['仁无']='仁无幻:BAAALgADCgcJBwAAAA==.',
['以徳']='以徳胡人:BAAALgAECgYJCAAAAA==.',
['以敖']='以敖以游:BAAALgAFFAMJAwAAAA==.',
['仲夏']='仲夏黄昏:BAAALgAECgEJAQAAAA==.',
['任正']='任正骑:BAACLgAFFH8OAAILAAQJuhdZAwBRAQALAAQJuhdZAwBRAQAuAAQKfx8AAwsACAkmGSwWAGACAAsACAkmGSwWAGACAAQABgmsDPioADABAAAA.',
['伊利']='伊利牛奶喝:BAAALgADCgYJBgAAAA==.',
['伊鲁']='伊鲁卡特:BAAALgAECgEJAQAAAA==.',
['众生']='众生皆苦:BAAALgADCgEJAQAAAA==.',
['会飞']='会飞的锤子:BAAALgAECgQJBAAAAA==.',
['传世']='传世问天:BAAALgAECgQJBgAAAA==.',
['传奇']='传奇舞灯使:BAABLgAECn8cAAINAAgJmxcgHgDoAQANAAgJmxcgHgDoAQAAAA==.',
['低调']='低调的坏人:BAAALgADCgEJAwAAAA==.',
['何丶']='何丶妨:BAAALgAECgYJBgAAAA==.',
['你人']='你人还怪好嘞:BAABLgAFFH8PAAMPAAUJXRIeBQBRAQAPAAQJiBAeBQBRAQAHAAQJ8AtFDwA4AQAAAA==.',
['你再']='你再叫我报警:BAAALgAECgQJBgAAAA==.',
['你尔']='你尔多龙吗:BAAALgAECgcJDAAAAA==.',
['你是']='你是什么垃圾:BAAALgAECgcJBgAAAA==.你是最棒的咕:BAABLgAFFH8HAAILAAMJ9hSJDgDtAAALAAMJ9hSJDgDtAAAAAA==.',
['你眼']='你眼角有泪:BAAALgAECgYJBwAAAA==.',
['佳宝']='佳宝奶:BAAALgAECgYJEAAAAA==.',
['依栏']='依栏听雨:BAAALgAECgEJAQAAAA==.',
['倒影']='倒影:BAACLgAFFH8HAAMNAAMJjBg8BwCsAAANAAMJjBg8BwCsAAAQAAEJEAu6GABNAAAuAAQKfyUABA0ACAnsI9gEAEYDAA0ACAnsI9gEAEYDABAABAmrHRgtADQBAAoAAQkCEAqCAC8AAAAA.',
['借月']='借月:BAABLgAFFH8JAAMGAAUJ6wrgGQCVAAAGAAIJFRbgGQCVAAARAAUJ8AEAAAAAAAAAAA==.',
['倪丶']='倪丶风暴烈酒:BAAALgAECgQJBQAAAA==.',
['傲慢']='傲慢:BAAALgAECgEJAQAAAA==.',
['元丶']='元丶初:BAAALgAECgQJBAAAAA==.',
['元素']='元素心恢复命:BAAALgAECgQJCAAAAA==.',
['光光']='光光绿丶:BAACLgAFFH8IAAINAAQJ/BsjBgBmAQANAAQJ/BsjBgBmAQAuAAQKfx0AAg0ABgnXIg8UAFECAA0ABgnXIg8UAFECAAAA.',
['光头']='光头外卖小哥:BAAALgAECgkJDgAAAA==.',
['光明']='光明指引你:BAAALgADCgIJAgAAAA==.',
['光芒']='光芒:BAAALgAECgYJCgAAAA==.',
['光辉']='光辉的晓:BAAALgAECgcJDQAAAA==.',
['克洛']='克洛塔之陨:BAAALgADCgcJBQABLgAECgIJBAACAAAAAA==.',
['全都']='全都是幻觉:BAAALgAECgMJAwAAAA==.',
['八爪']='八爪小鱼:BAABLgAFFH8MAAISAAQJHA+xDAA7AQASAAQJHA+xDAA7AQAAAA==.',
['六六']='六六小蒂凯:BAAALgAECgkJEAABLgAECgkJJQABAOQkAA==.六六灬:BAAALgAECgkJCgABLgAECgkJJQABAOQkAA==.六六牛肉人:BAABLgAECn8RAAIBAAkJZhrrIQC5AgABAAkJZhrrIQC5AgABLgAECgkJJQABAOQkAA==.六六知冬:BAAALgAECgkJEQABLgAECgkJJQABAOQkAA==.六六知夏:BAABLgAECn8lAAIBAAkJ5CQ0AQDTAwABAAkJ5CQ0AQDTAwAAAA==.六六知春:BAABLgAECn8UAAIBAAkJ/CGaBgBuAwABAAkJ/CGaBgBuAwABLgAECgkJJQABAOQkAA==.六六知秋:BAABLgAECn8aAAIBAAkJNh6dDAA1AwABAAkJNh6dDAA1AwABLgAECgkJJQABAOQkAA==.六六蒂凯:BAAALgAECgkJCQABLgAECgkJJQABAOQkAA==.六六迪凯:BAAALgAECgkJDAABLgAECgkJJQABAOQkAA==.',
['兰斯']='兰斯桑克斯:BAACLgAFFH8aAAIFAAcJGCM7AACsAgAFAAcJGCM7AACsAgAuAAQKfyAAAwUACQmnIVICAFADAAUACQmnIVICAFADAAkABgk/GAAAAAAAAAAA.',
['内伊']='内伊做特:BAAALgAECgQJBwAAAA==.',
['冬日']='冬日麽麽茶:BAAALgADCgIJAgAAAA==.',
['冰晶']='冰晶小兵:BAAALgAECgUJBQAAAA==.',
['冰玙']='冰玙火:BAAALgADCgIJAgAAAA==.',
['冷心']='冷心邪念:BAABLgAECn8WAAMJAAgJkhY0FQAzAgAJAAgJkhY0FQAzAgAFAAYJhA9lIwBeAQAAAA==.',
['凌峰']='凌峰拂云:BAAALgAFFAQJBAAAAA==.',
['凛威']='凛威之鹰:BAAALgAECgMJBgAAAA==.',
['凶影']='凶影丶传说:BAAALgAECgcJBwAAAA==.',
['凹凸']='凹凸法:BAAALgADCgEJAQAAAA==.',
['刀刀']='刀刀烈火丶:BAAALgAFFAEJAQAAAA==.',
['刃灬']='刃灬歌:BAAALgAECgYJBgAAAA==.',
['划船']='划船不用桨丶:BAAALgAECgcJCQAAAA==.',
['刘寄']='刘寄奴:BAAALgADCgUJBQAAAA==.',
['初尘']='初尘旖旎:BAAALgAECgYJBgAAAA==.',
['初见']='初见乍惊欢:BAAALgAECgkJEAABLgAECgkJJQABAOQkAA==.',
['别忘']='别忘达不溜叉:BAACLgAFFH8GAAIFAAMJKh21BAASAQAFAAMJKh21BAASAQAuAAQKfx8AAgUACAlYGhIOAFUCAAUACAlYGhIOAFUCAAAA.',
['别感']='别感冒:BAAALgAFFAEJAgAAAA==.',
['到贤']='到贤圈圈:BAAALgAECgYJBgAAAA==.',
['加油']='加油小欣欣:BAAALgAECgIJAgAAAA==.',
['动感']='动感锅盖:BAAALgADCgEJAQAAAA==.',
['北斗']='北斗星灬亮七:BAAALgADCgEJAQAAAA==.',
['北海']='北海叶子:BAAALgAECgEJAQAAAA==.',
['北辰']='北辰之月:BAAALgADCgQJBAAAAA==.',
['千与']='千与千寻的梦:BAAALgAECgcJBwAAAA==.',
['千城']='千城丶晓旭:BAAALgADCgUJBQAAAA==.',
['半仙']='半仙:BAAALgAECgkJCQAAAA==.半仙半佛祖:BAAALgAECgcJBwAAAA==.',
['半神']='半神:BAAALgADCgYJBgAAAA==.',
['半糖']='半糖芒芒椰:BAAALgAECgEJAwAAAA==.',
['华容']='华容无声:BAAALgAECgEJAQAAAA==.',
['南巷']='南巷宫羽:BAAALgAECgIJAgAAAA==.',
['南有']='南有嘉鱼:BAAALgAECgEJAgAAAA==.',
['卡卡']='卡卡战:BAAALgAFFAIJAgAAAA==.卡卡瓦的极光:BAABLgAFFH8FAAIKAAMJ7R23CgC5AAAKAAMJ7R23CgC5AAAAAA==.',
['卡斯']='卡斯諾尔:BAAALgAECgUJCAAAAA==.',
['卡莉']='卡莉佳依琳:BAAALgAFFAEJAQAAAA==.',
['卧虎']='卧虎藏熊:BAAALgAECgYJCAABLgAFFAcJBQATANEWAA==.',
['叁拾']='叁拾捌:BAAALgAFFAEJAQAAAA==.',
['又棉']='又棉秋雨:BAAALgAECgEJAgAAAA==.',
['双刃']='双刃老王:BAAALgAECgEJAQAAAA==.',
['双叶']='双叶丶:BAAALgAFFAIJAgAAAA==.',
['发扬']='发扬光大:BAAALgADCgUJBQAAAA==.',
['变态']='变态:BAAALgAECgEJAQAAAA==.',
['古哎']='古哎底儿:BAAALgAECgMJAwAAAA==.',
['古月']='古月罗卜:BAAALgAECgYJCAAAAA==.',
['古见']='古见黑猫:BAAALgADCgEJAQAAAA==.',
['句芒']='句芒之童:BAAALgAECgQJBAAAAA==.',
['叨叨']='叨叨:BAAALgADCgQJBAABLgAFFAYJFAAUANUFAA==.',
['可天']='可天:BAAALgAECgkJAgAAAA==.',
['可爱']='可爱丽丽:BAAALgAECgYJCAAAAA==.',
['叶莜']='叶莜莜:BAAALgAECgQJBAAAAA==.',
['叶齐']='叶齐:BAAALgAECgEJAQAAAA==.',
['吃糖']='吃糖糖:BAABLgAECn8UAAIOAAcJbyI1OAArAgAOAAcJbyI1OAArAgAAAA==.',
['吉姆']='吉姆雷诺:BAAALgAFFAEJAQAAAA==.',
['听说']='听说很那个:BAAALgAECgYJCQAAAA==.',
['吴奇']='吴奇:BAAALgAECgIJBAAAAA==.',
['告死']='告死天使:BAAALgAECgEJAQAAAA==.',
['周末']='周末晴:BAAALgAECgEJAQAAAA==.',
['咆哮']='咆哮的小福:BAACLgAFFH8HAAIUAAMJDgteCADOAAAUAAMJDgteCADOAAAuAAQKfxsAAhQACAkPHioTAHwCABQACAkPHioTAHwCAAAA.咆哮的鲨魚:BAAALgAECgQJBwAAAA==.',
['咋瓦']='咋瓦鲁多:BAAALgADCgEJAQAAAA==.',
['咕噜']='咕噜咕噜:BAAALgAECgMJAwAAAA==.',
['咖啡']='咖啡君:BAAALgAECgYJCwAAAA==.咖啡圣骑:BAAALgAECgYJDAAAAA==.',
['咦嘻']='咦嘻:BAAALgADCgEJAQAAAA==.',
['哇大']='哇大力好好吸:BAAALgAECgUJBQAAAA==.',
['哎呦']='哎呦你干嘛:BAABLgAFFH8GAAIJAAQJ/hMUCwBFAQAJAAQJ/hMUCwBFAQAAAA==.',
['唯一']='唯一米兰:BAACLgAFFH8WAAIUAAYJTh1vAAA7AgAUAAYJTh1vAAA7AgAuAAQKfxYAAxQACAmsJMUEACYDABQACAmsJMUEACYDABMAAQn/EuMlADsAAAAA.',
['啊可']='啊可萌的:BAAALgAECgkJBQAAAA==.',
['嗳瑭']='嗳瑭:BAAALgAECgEJAQAAAA==.',
['嘚啵']='嘚啵嘚:BAAALgAFFAEJAQABLgAFFAUJEAABAPsmAA==.',
['嘚嘚']='嘚嘚儿:BAAALgAECgEJAwAAAA==.',
['噬渊']='噬渊:BAAALgAFFAEJAQAAAA==.',
['四季']='四季刻歌:BAAALgAECgcJBwAAAA==.',
['囡囯']='囡囯:BAAALgADCgIJAgAAAA==.',
['团团']='团团回家:BAAALgADCgEJAQAAAA==.',
['国牧']='国牧:BAAALgAECgUJBwAAAA==.',
['土豆']='土豆侠升龙爸:BAAALgAECgQJBQAAAA==.',
['圣光']='圣光托莉娅:BAAALgAECgcJCAAAAA==.圣光看着你:BAABLgAECn8XAAMLAAcJLho3IwAGAgALAAcJLho3IwAGAgAEAAEJnAMmSwEvAAAAAA==.',
['地狱']='地狱火都软:BAABLgAFFH8CAAMVAAIJ7wI8AwBgAAAVAAEJAAA8AwBgAAAOAAEJ7wKtUgBAAAAAAA==.',
['埃塔']='埃塔塻斯:BAAALgAECgcJBwAAAA==.',
['城戶']='城戶紗織:BAAALgAECgYJCgAAAA==.',
['塞尔']='塞尔赫不答应:BAAALgAECgcJCgAAAA==.',
['境井']='境井仁:BAAALgAECgYJBgAAAA==.',
['墨染']='墨染梅霜:BAAALgAECgEJAQAAAA==.',
['壹整']='壹整根:BAAALgAECgEJAQAAAA==.',
['壹点']='壹点点:BAAALgAECgQJBAAAAA==.',
['复仇']='复仇者:BAAALgAECgUJBQAAAA==.',
['夏晓']='夏晓妍:BAABLgAECn8cAAMKAAgJ4RrWDQB9AgAKAAgJ4RrWDQB9AgAQAAIJ9QupVQA2AAAAAA==.',
['多多']='多多超越飞多:BAAALgAECggJCQAAAA==.',
['夜歌']='夜歌灰爪:BAAALgAECgcJCAAAAA==.',
['夜语']='夜语灵风:BAAALgADCgUJBQAAAA==.',
['大力']='大力水手黑凯:BAACLgAFFH8OAAMEAAYJWB5oAwC+AQAEAAUJsB1oAwC+AQALAAEJ6xrzGQBiAAAuAAQKfxgAAgQACQnHJSYDAKMDAAQACQnHJSYDAKMDAAAA.',
['大古']='大古熬成汤:BAAALgAFFAMJAwABLgAFFAcJBgAWANsXAA==.',
['大可']='大可机可大:BAAALgAECgIJAwAAAA==.大可狼可大:BAAALgADCgcJBwAAAA==.',
['大块']='大块砖头:BAAALgADCgEJAQAAAA==.',
['大殺']='大殺丨四方:BAAALgAECgQJBAAAAA==.',
['大熊']='大熊硬棒棒:BAAALgAECgcJBgAAAA==.',
['大老']='大老粗:BAAALgAECgIJBAAAAA==.',
['大青']='大青山:BAAALgADCgMJAwABLgAFFAUJCQARAAgTAA==.',
['大魔']='大魔神:BAAALgAECgYJAgAAAA==.',
['天呐']='天呐我真高:BAAALgADCgEJAQAAAA==.',
['天命']='天命人:BAAALgADCgUJBQAAAA==.',
['天天']='天天复盘:BAAALgADCgMJAwAAAA==.天天站岗:BAAALgADCgMJAwAAAA==.',
['天才']='天才术学家:BAAALgAECgQJBAAAAA==.',
['天湛']='天湛蓝:BAAALgAECgQJBQAAAA==.',
['天音']='天音彼方:BAAALgAECgQJBgAAAA==.',
['天香']='天香洛神:BAAALgADCgQJBAAAAA==.',
['失去']='失去灵魂的爱:BAAALgAECgcJBAAAAA==.',
['夸幻']='夸幻之父:BAAALgAECgYJCQAAAA==.',
['奥菲']='奥菲娅:BAAALgAECgEJAQAAAA==.',
['奥萝']='奥萝拉:BAACLgAFFH8HAAIDAAIJ6hm1GAC0AAADAAIJ6hm1GAC0AAAuAAQKfxoAAgMACAljHgoKAAoCAAMACAljHgoKAAoCAAAA.',
['奶徳']='奶徳:BAAALgAFFAIJAwAAAA==.',
['奶黄']='奶黄猪猪包:BAAALgAECgYJCgAAAA==.',
['她会']='她会魔法吧:BAAALgAECgkJEgABLgAECgkJJQABAOQkAA==.',
['好几']='好几十个武僧:BAAALgAECgYJBQAAAA==.',
['好赌']='好赌的爸爸:BAAALgAFFAIJAwAAAA==.',
['如果']='如果只是如果:BAAALgAFFAQJBAAAAA==.',
['如烟']='如烟的回忆:BAAALgAECgEJAgAAAA==.',
['妮妮']='妮妮是妮妮:BAABLgAECn8hAAIPAAgJwhu0FACRAgAPAAgJwhu0FACRAgAAAA==.',
['娃娃']='娃娃小猫奴:BAAALgAFFAEJAQAAAA==.娃娃小骑士:BAAALgAECgUJCQAAAA==.',
['嬉风']='嬉风逐月:BAAALgAECgcJDQAAAA==.',
['孤独']='孤独的坦克:BAAALgAECgQJBAAAAA==.孤独的小雨:BAAALgAECgEJAgAAAA==.',
['学而']='学而不思则罔:BAAALgAECgYJEwAAAA==.',
['守序']='守序陆:BAAALgAECgkJCQAAAA==.',
['守护']='守护天使:BAAALgADCgcJBwABLgAFFAMJBgAFAPwXAA==.',
['安吉']='安吉拉婴儿:BAAALgAFFAEJAQAAAA==.',
['安德']='安德尔斯:BAACLgAFFH8IAAIXAAMJrB5+AQAhAQAXAAMJrB5+AQAhAQAuAAQKfx0AAhcACAkAHIoIAFACABcACAkAHIoIAFACAAAA.',
['安迷']='安迷修:BAAALgAECgUJBQAAAA==.安迷苟斯:BAABLgAECn8eAAIDAAcJeSXpJgDXAgADAAcJeSXpJgDXAgAAAA==.',
['宋义']='宋义进:BAAALgAECgUJBgAAAA==.',
['客服']='客服小祥:BAACLgAFFH8IAAIMAAMJvRC6HADuAAAMAAMJvRC6HADuAAAuAAQKfyMAAgwABwkZImwdAKECAAwABwkZImwdAKECAAAA.',
['宫村']='宫村伊澄:BAAALgADCgEJAQAAAA==.',
['寂若']='寂若寒蝉:BAAALgAECgEJAgAAAA==.',
['寒鸦']='寒鸦却却:BAAALgAECgEJAQAAAA==.',
['寿司']='寿司不会说谎:BAAALgAFFAIJAwABLgAFFAMJBAACAAAAAA==.',
['射箭']='射箭欧德毕:BAAALgAECgcJDQAAAA==.',
['小仙']='小仙米下凡:BAAALgAECgMJBgAAAA==.',
['小娃']='小娃娃牌保镖:BAAALgAECgEJAQAAAA==.',
['小手']='小手贼红:BAAALgADCgUJBQAAAA==.',
['小松']='小松鼠小绵羊:BAACLgAFFH8KAAMLAAMJFQ01EADWAAALAAMJFQ01EADWAAAEAAIJNBkAAAAAAAAuAAQKfxcAAwsACAnIERozALEBAAsABwm8ExozALEBAAQAAgnvEl0GAYoAAAAA.',
['小浪']='小浪提子:BAAALgAECgEJAQAAAA==.',
['小牛']='小牛外卖员:BAAALgADCgUJBQAAAA==.',
['小猪']='小猪熊:BAAALgAECgcJCwAAAA==.',
['小白']='小白芨:BAAALgAFFAIJAgAAAA==.',
['小米']='小米有犄角:BAAALgAECgEJAQAAAA==.',
['小红']='小红手晨曦丶:BAAALgAECgcJDAABLgAFFAgJAgACAAAAAA==.',
['小羊']='小羊酮中毒:BAAALgADCgcJBwAAAA==.',
['小药']='小药儿:BAAALgAECgEJAQAAAA==.',
['小豬']='小豬熊:BAAALgAECgUJBwAAAA==.',
['小马']='小马会巫术:BAAALgAECgYJCwAAAA==.',
['尘尽']='尘尽光生:BAAALgAECgUJBQAAAA==.',
['就当']='就当我没说:BAAALgAFFAMJBAAAAA==.',
['尼古']='尼古拉斯蔡明:BAABLgAFFH8IAAIYAAQJ3Q7bAQA7AQAYAAQJ3Q7bAQA7AQAAAA==.',
['屍王']='屍王:BAAALgADCgUJBQAAAA==.',
['岂有']='岂有此理:BAAALgADCgUJBQAAAA==.',
['左大']='左大壮:BAAALgADCgUJBQAAAA==.',
['巨石']='巨石牧远:BAAALgAECgYJBgAAAA==.',
['巫瞳']='巫瞳:BAABLgAECn8UAAIDAAkJySNGCACGAwADAAkJySNGCACGAwAAAA==.',
['布莱']='布莱斯伊尔:BAAALgADCgcJBgAAAA==.',
['希望']='希望曙光:BAAALgADCgYJBgAAAA==.',
['干部']='干部爱考核:BAAALgADCgEJAQAAAA==.',
['康师']='康师傅绿茶:BAAALgAECgEJAQAAAA==.',
['开心']='开心就好:BAAALgAECgYJDAAAAA==.开心游戏:BAAALgAECgYJBgAAAA==.',
['式微']='式微微:BAAALgAECgcJDQAAAA==.',
['弗南']='弗南的:BAAALgADCgYJBgAAAA==.',
['张国']='张国立:BAACLgAFFH8IAAISAAMJQAgcBwDnAAASAAMJQAgcBwDnAAAuAAQKfx4AAhIACAnxFK8jADgCABIACAnxFK8jADgCAAEuAAUUAwkIABkA5RgA.',
['张长']='张长生:BAAALgAECgUJBQABLgAFFAMJCAAZAOUYAA==.',
['徐长']='徐长卿:BAAALgADCgcJCAAAAA==.',
['御风']='御风僧:BAAALgAFFAEJAQAAAA==.',
['微笑']='微笑迪妮莎:BAAALgAECgQJBQAAAA==.',
['德寸']='德寸进尺:BAAALgADCgYJBgABLgAECggJIgANAPAWAA==.',
['德莱']='德莱萨神:BAAALgAECgEJAQAAAA==.',
['德萝']='德萝莉丝:BAAALgAECggJCAAAAA==.',
['心猿']='心猿贝贝:BAAALgAECgcJDwAAAA==.',
['怒三']='怒三娘:BAABLgAECn8VAAILAAcJKgvMVwAcAQALAAcJKgvMVwAcAQAAAA==.',
['怨念']='怨念深渊:BAAALgAFFAQJBAABLgAFFAMJBgAFAPwXAA==.',
['恩佐']='恩佐斯之光:BAAALgAECgYJDgAAAA==.恩佐斯之怒:BAAALgAECgcJAwAAAA==.恩佐斯代言人:BAAALgAECgIJAgAAAA==.',
['恶魔']='恶魔圣光:BAAALgAECgEJAQAAAA==.恶魔黎明:BAAALgAECgEJAQAAAA==.',
['悲惨']='悲惨人士:BAAALgAECgYJBgAAAA==.',
['情定']='情定爱情海:BAAALgAECgYJBgAAAA==.',
['愛相']='愛相誼:BAAALgAECgkJCQAAAA==.',
['憨憨']='憨憨杰尼龟:BAAALgAECgUJBQAAAA==.',
['我去']='我去打麻将了:BAABLgAFFH8GAAIEAAYJggaeBQCWAQAEAAYJggaeBQCWAQAAAA==.',
['我心']='我心飛翔:BAAALgAECgcJBwAAAA==.',
['我是']='我是一个术士:BAAALgADCgQJBAAAAA==.',
['我暴']='我暴脾气:BAAALgAECgYJCQAAAA==.',
['我的']='我的刀盾:BAABLgAECn8jAAMPAAgJ/h9aHQBWAgAPAAcJ/R9aHQBWAgAHAAcJjRfxJwDnAQAAAA==.',
['战棍']='战棍:BAAALgAFFAIJAQAAAA==.',
['战神']='战神神龙:BAAALgAECgMJBgAAAA==.',
['戰歌']='戰歌之帥帥:BAAALgAECgIJAQAAAA==.戰歌之鹰:BAAALgAECggJDgAAAA==.',
['手搂']='手搂子:BAAALgAECgMJAwAAAA==.',
['打破']='打破枷锁丶:BAAALgADCgIJAgAAAA==.',
['托托']='托托熊:BAABLgAECn8eAAMTAAgJ4xIBLQCyAQATAAcJRxQBLQCyAQAUAAIJfAdajQBgAAAAAA==.',
['扶大']='扶大力萌萌吸:BAAALgAFFAQJBAAAAA==.',
['抹茶']='抹茶奶冻:BAAALgAECgYJCwABLgAFFAQJCAAHAJUeAA==.抹茶灬小饼干:BAACLgAFFH8MAAIFAAUJwSEIAgANAgAFAAUJwSEIAgANAgAuAAQKfx4AAgUACAnBHgoHAM8CAAUACAnBHgoHAM8CAAAA.',
['拉什']='拉什德:BAAALgADCgYJBgAAAA==.',
['拉夫']='拉夫乐兰:BAAALgAECgcJEgAAAA==.',
['拉娜']='拉娜的动物园:BAAALgAECgcJDQAAAA==.',
['拉格']='拉格朗日:BAABLgAFFH8EAAIOAAIJjBgQMQCwAAAOAAIJjBgQMQCwAAAAAA==.',
['拨楞']='拨楞你行不:BAAALgAECgQJBQAAAA==.',
['挚爱']='挚爱:BAAALgAECgYJBgAAAA==.',
['挠挠']='挠挠就痒痒:BAAALgADCgEJAQAAAA==.',
['挽狂']='挽狂澜:BAAALgAECgIJAgAAAA==.',
['摸扣']='摸扣:BAAALgAECgEJAQAAAA==.',
['摸鱼']='摸鱼两月的他:BAAALgAECgYJBwAAAA==.',
['撕脱']='撕脱怂勋爵:BAAALgAECgcJDwAAAA==.',
['文森']='文森特织法者:BAACLgAFFH8MAAIDAAQJOxaABwBkAQADAAQJOxaABwBkAQAuAAQKfyAAAgMACAniIQUnANYCAAMACAniIQUnANYCAAAA.',
['斛律']='斛律光:BAAALgAECgkJCQAAAA==.',
['断魂']='断魂歌:BAAALgADCgcJBwAAAA==.',
['新生']='新生的宿命:BAAALgAFFAEJAQAAAA==.',
['无名']='无名小虾米:BAAALgAFFAMJBAAAAA==.',
['无情']='无情的小刀郎:BAAALgADCgEJAQAAAA==.',
['无敌']='无敌小番茄:BAAALgAECgUJDQAAAA==.无敌矮子猎:BAACLgAFFH8OAAMPAAQJfB+NEgC4AAAPAAQJbh+NEgC4AAAHAAIJWxe3GwCnAAAuAAQKfyAAAwcACAmkH8kTAJMCAAcACAm8G8kTAJMCAA8AAwkpHhJ9APAAAAAA.',
['无用']='无用之用:BAABLgAFFH8KAAIXAAQJmwOVAwCsAAAXAAQJmwOVAwCsAAAAAA==.',
['无限']='无限极:BAAALgAECgMJAwAAAA==.',
['明夜']='明夜:BAAALgAECgYJBQAAAA==.',
['易燃']='易燃易爆炸:BAABLgAECn8UAAIDAAcJlCbiFwAbAwADAAcJlCbiFwAbAwAAAA==.',
['星野']='星野月影:BAAALgAECgUJBQAAAA==.',
['春哥']='春哥好大:BAAALgAECgUJBQAAAA==.春哥竟然:BAAALgAECgIJAgAAAA==.',
['春水']='春水煎茶:BAAALgAECgQJCQABLgAFFAYJFgAJAKchAA==.',
['春满']='春满园:BAAALgAECgEJAQAAAA==.',
['是染']='是染不是柒:BAAALgAECgMJAwAAAA==.',
['晋康']='晋康:BAAALgADCgUJBQAAAA==.',
['晚来']='晚来静待月:BAAALgAECgEJAQAAAA==.',
['晚饭']='晚饭吃苹果:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜琳:BAAALgAFFAEJAQAAAA==.暗夜紫罗兰:BAAALgADCgUJBQAAAA==.',
['暗天']='暗天波动眼:BAAALgADCgQJBAAAAA==.',
['暗影']='暗影圣光:BAABLgAFFH8FAAMKAAIJFBGuDQCQAAAKAAIJFBGuDQCQAAANAAEJ9QAAAAAAAAAAAA==.',
['暗黑']='暗黑破坏神:BAAALgAECgYJDAAAAA==.',
['暮远']='暮远:BAAALgAECgEJBAAAAA==.',
['最后']='最后的土小豆:BAABLgAECn8YAAIaAAgJRx6MCwDdAgAaAAgJRx6MCwDdAgAAAA==.最后的微笑:BAAALgAECgQJBQAAAA==.',
['最囂']='最囂張的兔子:BAAALgADCgEJAQAAAA==.',
['月光']='月光时刻:BAAALgAECgIJAgAAAA==.',
['月夜']='月夜归来:BAAALgAECgEJAQAAAA==.',
['月弦']='月弦:BAAALgAECgQJBAAAAA==.',
['月影']='月影栖苔:BAAALgAECgYJCQAAAA==.',
['月舞']='月舞星光:BAAALgAECgEJAQAAAA==.',
['未擊']='未擊中:BAAALgAECgIJAwAAAA==.',
['本质']='本质騎士丶:BAAALgAECgYJCQAAAA==.',
['李奥']='李奥瑞克:BAAALgADCgYJBgAAAA==.',
['李小']='李小狼丷:BAAALgAECgEJAQABLgAFFAEJAQACAAAAAA==.',
['李火']='李火旺:BAAALgAECgEJAQAAAA==.',
['极彩']='极彩華想烈:BAACLgAFFH8IAAIFAAMJWBNZBQD4AAAFAAMJWBNZBQD4AAAuAAQKfx0ABAUACAkqHGMKAI8CAAUACAkqHGMKAI8CABsABAltEMopANAAAAkAAQnlH3kbAF8AAAAA.',
['极恶']='极恶俯冲:BAACLgAFFH8GAAIFAAMJ/BdcEQCqAAAFAAMJ/BdcEQCqAAAuAAQKfxkAAwUACQmnGvMIAKgCAAUACAmnHPMIAKgCAAkAAQmhA7JgADgAAAAA.',
['林西']='林西冰:BAAALgAFFAEJAQAAAA==.',
['果果']='果果向前冲:BAAALgAECgEJAQAAAA==.',
['果铺']='果铺面包:BAAALgAECgEJAQABLgAECgMJAwACAAAAAA==.',
['枫糖']='枫糖唱片:BAAALgAECgEJAQAAAA==.',
['柒月']='柒月拾柒:BAAALgAECgEJAQAAAA==.',
['柚点']='柚点开心:BAAALgAECgcJBwAAAA==.',
['柴可']='柴可夫斯基:BAAALgAECgYJBgABLgAFFAMJCAAZAOUYAA==.',
['栀遇']='栀遇:BAAALgAECgkJEAABLgAECgkJJQABAOQkAA==.',
['桥洞']='桥洞里盖小被:BAAALgAFFAMJAwAAAA==.',
['梁山']='梁山大王:BAACLgAFFH8FAAMaAAMJpxrFDwDpAAAaAAIJsibFDwDpAAAcAAEJkgILBwBUAAAuAAQKfx8AAxoACAn3JOsDAFsDABoACAn3JOsDAFsDABwAAgkxD20XAH0AAAAA.',
['梦回']='梦回百变:BAAALgAECgYJBgAAAA==.',
['梦胧']='梦胧:BAAALgAECgEJAQABLgAECgUJCgACAAAAAA==.',
['梦魇']='梦魇哀霜:BAAALgAECgQJBwAAAA==.',
['梵净']='梵净:BAAALgAECgEJAgAAAA==.',
['梵天']='梵天:BAAALgAECgQJBAAAAA==.',
['梵魔']='梵魔:BAAALgAECgQJAwAAAA==.',
['椰团']='椰团团:BAAALgAFFAIJAgABLgAFFAQJCAAHAJUeAA==.',
['槟榔']='槟榔骑士:BAAALgAECgEJAQAAAA==.',
['槿年']='槿年:BAAALgAFFAIJAQAAAA==.',
['樂与']='樂与怒:BAAALgAECgYJBgAAAA==.',
['樱桃']='樱桃可乐:BAAALgAECgIJAwAAAA==.樱桃玛德琳:BAAALgAECggJCAAAAA==.樱桃绵绵冰:BAAALgAECggJCwAAAA==.',
['樱羽']='樱羽艾玛:BAACLgAFFH8FAAIDAAMJwxK4QACtAAADAAMJwxK4QACtAAAuAAQKfygAAwMACAmaJT0DAJgCAAMACAmEIz0DAJgCAB0AAwmTJbcJAEoBAAAA.',
['橙戒']='橙戒骑:BAAALgAECgEJAQAAAA==.',
['橙骑']='橙骑士:BAAALgAECgcJDQAAAA==.',
['欧阳']='欧阳自微:BAAALgAECgYJCQAAAA==.',
['止于']='止于至善:BAAALgAECgUJCAAAAA==.',
['武雄']='武雄之狮:BAACLgAFFH8IAAIEAAMJMBcyCAANAQAEAAMJMBcyCAANAQAuAAQKfyEAAgQACAkeJHgKAD0DAAQACAkeJHgKAD0DAAAA.',
['歪德']='歪德富:BAAALgAECgUJCgAAAA==.',
['歪歪']='歪歪:BAAALgADCgUJBQAAAA==.',
['死亡']='死亡大囧骑:BAAALgAECgQJBAAAAA==.',
['死别']='死别:BAAALgAECgEJAQAAAA==.',
['死神']='死神力量:BAAALgAECgEJAQAAAA==.',
['殊途']='殊途:BAACLgAFFH8QAAMPAAUJLCNJAQCUAQAPAAQJLCNJAQCUAQAIAAIJjwX8BwBLAAAuAAQKfyUAAw8ACAn/JFAGACkDAA8ACAn/JFAGACkDAAcACAmlErUiAA0CAAAA.',
['残忍']='残忍的胖克斯:BAACLgAFFH8HAAIBAAIJVSKBMADLAAABAAIJVSKBMADLAAAuAAQKfxwAAwEABwmlIo4lAKcCAAEABwmlIo4lAKcCAB4AAQmNGCsIAEoAAAAA.',
['残花']='残花飘飘:BAAALgADCgIJAgAAAA==.',
['毁灭']='毁灭之镜:BAABLgAECn8eAAMOAAgJcB1ePgAUAgAOAAcJcB1ePgAUAgAfAAEJAAChXgBTAAAAAA==.',
['氤氲']='氤氲囡囡:BAAALgAECgEJAQAAAA==.',
['水杯']='水杯子:BAAALgAFFAIJAgAAAA==.',
['永夜']='永夜悲歌:BAAALgAFFAIJAgAAAA==.',
['汉武']='汉武立国:BAAALgAECgIJAgAAAA==.',
['江之']='江之岛耀孓:BAABLgAECn8WAAMbAAgJLBl5FAChAQAbAAUJaxx5FAChAQAJAAYJUhaVJACYAQAAAA==.',
['污博']='污博士丶:BAABLgAECn8ZAAIBAAcJRR7EOQBQAgABAAcJRR7EOQBQAgAAAA==.',
['沁月']='沁月凝霜:BAAALgAECgMJAwAAAA==.',
['沐初']='沐初阳:BAAALgAECgEJAQAAAA==.',
['沐歌']='沐歌:BAAALgAECgQJBAAAAA==.',
['沐雨']='沐雨青峦:BAAALgAECgkJDwAAAA==.',
['没关']='没关系:BAAALgAECgUJBQAAAA==.',
['没有']='没有你的世界:BAAALgAECgUJBQAAAA==.',
['沫牧']='沫牧:BAAALgAECgEJAQAAAA==.',
['法外']='法外枉徒张三:BAAALgAECgEJAQAAAA==.',
['波雅']='波雅尐汉库克:BAAALgAECgYJDAAAAA==.',
['洛希']='洛希极限:BAAALgAECgUJDQAAAA==.',
['洢澐']='洢澐渺渺:BAABLgAECn8WAAMOAAgJtAzCiABIAQAOAAcJtAzCiABIAQAfAAEJAAA3cAA2AAAAAA==.',
['流刃']='流刃若火:BAAALgAFFAEJAQAAAA==.',
['浩太']='浩太郎:BAAALgAECgEJAQAAAA==.',
['海山']='海山大王:BAAALgADCgYJBgAAAA==.',
['海明']='海明威:BAAALgAECgQJBQAAAA==.',
['海洋']='海洋石油:BAAALgAECgMJAwAAAA==.',
['涨停']='涨停了:BAAALgADCgYJBgAAAA==.',
['深呼']='深呼吸飞行:BAAALgAECgQJBwAAAA==.',
['深情']='深情的钱满天:BAABLgAECn8eAAQPAAgJsxU7JAAsAgAPAAgJsxU7JAAsAgAHAAYJxwizTAAeAQAIAAcJwwgAAAAAAAAAAA==.',
['渔家']='渔家清蒸:BAAALgAECgYJCgAAAA==.',
['渡鸦']='渡鸦之影:BAAALgAECgUJCAAAAA==.',
['游云']='游云小蝎:BAAALgAECgQJCAAAAA==.',
['游戏']='游戏圣人:BAAALgAFFAIJAgAAAA==.',
['湊阿']='湊阿库娅:BAAALgADCgQJBAAAAA==.',
['湮没']='湮没冰霜:BAAALgAECgcJEAAAAA==.',
['潋阙']='潋阙:BAAALgAECgUJBQAAAA==.',
['潜龙']='潜龙于渊丶:BAAALgADCgEJAQAAAA==.',
['火烧']='火烧哥:BAAALgADCgcJDAAAAA==.',
['灬小']='灬小坚果:BAAALgAECggJCAAAAA==.',
['灰色']='灰色的青春:BAAALgAECgMJAwAAAA==.',
['灵魂']='灵魂行者:BAAALgAECgYJBgAAAA==.',
['炸酱']='炸酱面面:BAAALgAECgEJAQAAAA==.',
['烟萌']='烟萌萌:BAAALgAFFAEJAQAAAA==.',
['烬鸢']='烬鸢:BAAALgAECgMJBQAAAA==.',
['热带']='热带鱼甜酱:BAAALgAECgYJCQAAAA==.',
['焰柳']='焰柳树丛:BAAALgAECgYJCAABLgAFFAIJAgACAAAAAA==.',
['煎饼']='煎饼和葱:BAAALgADCgIJAgAAAA==.',
['熊丶']='熊丶印:BAABLgAFFH8GAAITAAMJgRp/DgAFAQATAAMJgRp/DgAFAQAAAA==.',
['熊德']='熊德斯泰特:BAAALgAECgEJAQAAAA==.',
['燁安']='燁安觀:BAAALgAECgEJAQAAAA==.',
['爱坤']='爱坤丶长眠:BAAALgAECgQJCQABLgAECggJGwADAEsgAA==.爱坤二号:BAAALgAECgQJBAABLgAECggJGwADAEsgAA==.爱坤长眠:BAABLgAECn8bAAIDAAgJSyDAJwDTAgADAAgJSyDAJwDTAgAAAA==.爱坤长眠丶:BAAALgAECgcJCgABLgAECggJGwADAEsgAA==.',
['爱玩']='爱玩的懒猫:BAABLgAECn8eAAQgAAgJNxIrLgBbAQAgAAYJ3xIrLgBbAQAMAAgJ1Q5ZdQBFAQAhAAQJtwW5HwCIAAAAAA==.',
['爱笑']='爱笑的胖苏:BAAALgAECgcJBwAAAA==.',
['牛奶']='牛奶小鱼:BAAALgAECgIJBAAAAA==.',
['牧远']='牧远巨石:BAAALgAECgcJAQABLgAFFAQJBAACAAAAAA==.',
['狂暴']='狂暴的奢华:BAAALgADCgEJAQAAAA==.',
['狄尔']='狄尔曼迪斯:BAAALgAECgkJDwAAAA==.',
['狗毛']='狗毛山药:BAAALgADCgcJDAAAAA==.',
['独孤']='独孤小战:BAAALgADCgEJAQAAAA==.',
['猎手']='猎手小多:BAAALgAECgcJBgAAAA==.',
['猎魔']='猎魔者苏:BAAALgAECgEJAQAAAA==.',
['猫大']='猫大爷:BAAALgAECgMJAwAAAA==.',
['猫小']='猫小豆:BAAALgAECgEJAQAAAA==.',
['猫巷']='猫巷拾青柠:BAAALgAFFAEJAQAAAA==.',
['猫與']='猫與熊掌兼德:BAAALgAECgYJCwAAAA==.',
['獨枭']='獨枭:BAAALgAECgEJAgAAAA==.',
['玄丶']='玄丶苑:BAABLgAFFH8FAAIUAAIJ3hBUGACaAAAUAAIJ3hBUGACaAAAAAA==.',
['玄天']='玄天邪帝:BAAALgAECgYJDgAAAA==.',
['玉石']='玉石:BAAALgAECgcJEQAAAA==.',
['王子']='王子丶哈皮:BAAALgADCgUJBQAAAA==.',
['玩法']='玩法撕裂:BAAALgAECgMJAwAAAA==.',
['珍小']='珍小宝:BAAALgAFFAEJAgAAAA==.',
['琉璃']='琉璃焰:BAAALgAECgkJCQAAAA==.琉璃的小伙伴:BAAALgAECgYJCQAAAA==.',
['琻牛']='琻牛座当师长:BAAALgAFFAEJAQABLgAFFAQJBwAiAKkRAA==.',
['瑱圭']='瑱圭:BAAALgAFFAEJAQAAAA==.',
['璀璨']='璀璨魔女:BAAALgAECgQJBAAAAA==.',
['甜崽']='甜崽:BAAALgAFFAQJBAAAAA==.',
['电池']='电池兔:BAAALgAECgEJAQAAAA==.',
['电车']='电车痴汗:BAAALgADCgEJAgAAAA==.',
['畅仔']='畅仔:BAAALgAFFAMJAwAAAA==.',
['留星']='留星闪了闪:BAAALgAECgcJBQAAAA==.',
['疗灵']='疗灵师:BAAALgAECgcJAgAAAA==.',
['疯狂']='疯狂奶爸:BAAALgAECgkJAQAAAA==.',
['痛苦']='痛苦达不溜叉:BAAALgADCgMJAwAAAA==.',
['痴断']='痴断肠:BAACLgAFFH8FAAIjAAIJ4iLeAgDDAAAjAAIJ4iLeAgDDAAAuAAQKfx8AAiMABwm0HZYFAH8CACMABwm0HZYFAH8CAAAA.',
['白日']='白日焰火:BAAALgADCgEJAQAAAA==.',
['白桃']='白桃气泡水:BAAALgAECgQJBAAAAA==.',
['白羊']='白羊座当鍕長:BAABLgAFFH8HAAIiAAQJqRHbDwCeAAAiAAQJqRHbDwCeAAAAAA==.',
['白酒']='白酒加冰:BAAALgADCgUJBQAAAA==.',
['白鹿']='白鹿:BAAALgADCgEJAQAAAA==.',
['百变']='百变小只因:BAAALgAECgEJAgAAAA==.',
['皈依']='皈依僧:BAAALgADCgIJAgAAAA==.',
['盖兹']='盖兹:BAAALgAFFAIJAgAAAA==.',
['真灬']='真灬怡靌:BAAALgAECgYJDAAAAA==.',
['真的']='真的沒關係吖:BAABLgAECn8eAAMOAAgJaxjRQAALAgAOAAcJaxjRQAALAgAfAAEJAAAOYwBIAAAAAA==.',
['眼睛']='眼睛被打姑鹧:BAAALgAECgQJBAAAAA==.',
['睡不']='睡不着别烦:BAAALgAFFAEJAQAAAA==.睡不醒的柚子:BAABLgAECn8WAAIEAAgJ8RL0TwDyAQAEAAgJ8RL0TwDyAQAAAA==.',
['瞳夕']='瞳夕:BAAALgADCgcJBwAAAA==.',
['矢志']='矢志不渝:BAAALgAECgQJAwAAAA==.',
['知者']='知者不言:BAAALgAECgYJBgAAAA==.',
['石之']='石之牧远:BAAALgAECgYJBgAAAA==.',
['石头']='石头蛋:BAAALgAECgcJBwAAAA==.',
['破伤']='破伤风:BAAALgAFFAEJAgAAAA==.',
['破喉']='破喉龙:BAAALgADCgEJAQAAAA==.',
['碎星']='碎星之语:BAAALgAECgEJAgAAAA==.',
['磷叶']='磷叶石:BAAALgAECgQJBAAAAA==.',
['神人']='神人:BAAALgAFFAUJAwAAAA==.',
['神佑']='神佑索索:BAAALgAECgcJDgAAAA==.神佑耶:BAAALgAECgEJAQAAAA==.',
['神力']='神力恩泽:BAAALgAFFAEJAQABLgAFFAMJBgAFAPwXAA==.',
['神圣']='神圣乐章:BAAALgAECgQJBQAAAA==.',
['神明']='神明坠落:BAAALgAECgEJAQAAAA==.',
['神笔']='神笔丶:BAACLgAFFH8GAAITAAIJryb7EADnAAATAAIJryb7EADnAAAuAAQKfxwAAhMACAmAJKUEAFADABMACAmAJKUEAFADAAAA.',
['神龙']='神龙灰灰:BAAALgAFFAQJBAAAAA==.',
['私人']='私人定制:BAAALgADCgYJBgAAAA==.',
['空城']='空城空旧忆:BAAALgAECgUJCAAAAA==.',
['章鱼']='章鱼宝宝:BAAALgAECgUJBQAAAA==.',
['童妻']='童妻:BAACLgAFFH8IAAIDAAMJrB7yEAAKAQADAAMJrB7yEAAKAQAuAAQKfyMAAwMACAk3IYAdAAADAAMACAk3IYAdAAADAB0AAglnCuMZAEkAAAAA.',
['笑问']='笑问青天:BAAALgAECgcJCAAAAA==.',
['米拉']='米拉丷坏包儿:BAAALgAECgYJBgAAAA==.',
['米酒']='米酒:BAAALgAECgEJAgAAAA==.',
['精分']='精分少女:BAAALgADCgEJAQAAAA==.',
['糖果']='糖果果:BAAALgADCgQJBAAAAA==.',
['糖菓']='糖菓噯:BAAALgAECgMJBgAAAA==.',
['糯叽']='糯叽叽:BAAALgAECgIJAwAAAA==.',
['紫梦']='紫梦凉痕:BAAALgAECgMJAwAAAA==.',
['紫灬']='紫灬櫻:BAAALgAECgYJBwAAAA==.',
['紫色']='紫色小多:BAAALgAECgQJBAAAAA==.',
['紫雨']='紫雨心衣丶:BAAALgAFFAIJAwAAAA==.',
['纠结']='纠结小术:BAAALgAECgkJEAAAAA==.',
['红油']='红油咕咕鸡:BAAALgAECgEJAQAAAA==.',
['纵横']='纵横百核:BAAALgAFFAIJBAABLgAFFAYJDgAJAEIXAA==.',
['绥山']='绥山桃:BAABLgAFFH8IAAIRAAQJbhblCABVAQARAAQJbhblCABVAQAAAA==.',
['绫枫']='绫枫:BAAALgADCgEJAQABLgAFFAYJCwADAIUbAA==.',
['绮罗']='绮罗翼:BAAALgAECgUJBwAAAA==.',
['缘来']='缘来是妮:BAAALgAECgYJDQAAAA==.',
['罗大']='罗大人:BAAALgAECgYJDQAAAA==.',
['罗德']='罗德凯奥斯:BAAALgADCgYJBwAAAA==.',
['羽川']='羽川翼:BAAALgAECgcJBwAAAA==.',
['翠花']='翠花来找淑芬:BAAALgAECggJCwAAAA==.',
['翻滚']='翻滚的柴犬:BAACLgAFFH8IAAIZAAMJ5RirBwDyAAAZAAMJ5RirBwDyAAAuAAQKfx0AAhkACAnIGdoYAD0CABkACAnIGdoYAD0CAAAA.',
['老实']='老实人恩佐斯:BAAALgAECgMJBQAAAA==.',
['老木']='老木先生:BAAALgAECgUJBQAAAA==.',
['老游']='老游戏:BAAALgAECgYJBwAAAA==.',
['肉球']='肉球战:BAAALgAFFAQJAgAAAA==.',
['肯尼']='肯尼迪:BAAALgAECgYJBwAAAA==.',
['胆子']='胆子大德:BAAALgAECgMJAwAAAA==.',
['胖僧']='胖僧哦:BAAALgAECgMJAwAAAA==.',
['胖嘟']='胖嘟嘟的嘟嘟:BAAALgAECgUJBQAAAA==.',
['能不']='能不能奶我:BAAALgAECgEJAQAAAA==.',
['自摸']='自摸妖姬:BAAALgAFFAIJAgABLgAFFAUJBAACAAAAAA==.',
['舟山']='舟山梭子蟹:BAAALgAECgcJBwAAAA==.',
['艾尔']='艾尔特琳德:BAAALgADCgMJAwAAAA==.',
['艾文']='艾文凯尔:BAABLgAECn8dAAIBAAcJwh39DQCrAQABAAcJwh39DQCrAQAAAA==.',
['艾米']='艾米丫:BAABLgAFFH8HAAIkAAMJ/gHICwCNAAAkAAMJ/gHICwCNAAAAAA==.',
['芒果']='芒果百事:BAACLgAFFH8LAAIKAAQJiBrXAwBQAQAKAAQJiBrXAwBQAQAuAAQKfyUAAgoABwkrH6sPAGkCAAoABwkrH6sPAGkCAAAA.',
['芒芒']='芒芒千层:BAAALgAFFAIJAgABLgAFFAQJCAAHAJUeAA==.',
['芙蓉']='芙蓉王源:BAAALgAECgMJAwAAAA==.',
['芝士']='芝士酸奶修狗:BAAALgAECgYJCgAAAA==.',
['花天']='花天狂骨:BAAALgAFFAEJAQAAAA==.',
['花開']='花開富贵:BAAALgAECgYJCgAAAA==.',
['苍白']='苍白心语:BAAALgAECgQJBwAAAA==.',
['茗糖']='茗糖:BAAALgADCgUJBQAAAA==.',
['草莓']='草莓喵酱:BAACLgAFFH8KAAIGAAQJqyJ3BACXAQAGAAQJqyJ3BACXAQAuAAQKfxUAAgYACAl+JCwGACoDAAYACAl+JCwGACoDAAEuAAUUBQkUAAoAJyUA.草莓布丁:BAABLgAECn8UAAIHAAcJEhqiIQAWAgAHAAcJEhqiIQAWAgABLgAFFAQJCAAHAJUeAA==.',
['荔枝']='荔枝掉了:BAABLgAECn8eAAIEAAgJcR38IQCiAgAEAAgJcR38IQCiAgAAAA==.',
['莉娅']='莉娅徳琳:BAAALgAECgIJAgAAAA==.',
['莉雅']='莉雅:BAAALgADCgEJAQAAAA==.',
['菠菜']='菠菜西兰花:BAAALgAECgUJCAABLgAFFAQJDgAOAKgfAA==.',
['菲妮']='菲妮斯娅:BAABLgAECn8UAAIKAAkJRReEDACLAgAKAAkJRReEDACLAgAAAA==.',
['萌灬']='萌灬主:BAAALgAECgIJAgAAAA==.',
['萨拉']='萨拉塔斯的脚:BAAALgAFFAQJBAAAAA==.',
['萨瓦']='萨瓦图恩:BAAALgAECgIJBAAAAA==.',
['落花']='落花流觞:BAAALgADCgEJAQAAAA==.',
['葡萄']='葡萄果冻:BAAALgAFFAIJAgABLgAFFAQJCAAHAJUeAA==.',
['蒙丶']='蒙丶奇奇:BAAALgAFFAEJAgAAAA==.',
['蓝月']='蓝月光:BAAALgADCgQJBAAAAA==.',
['蓝泽']='蓝泽薄荷:BAAALgAECgYJBgAAAA==.',
['蕞清']='蕞清风:BAAALgAECgUJCwAAAA==.',
['薄荷']='薄荷生巧:BAABLgAFFH8IAAMHAAQJlR4GDQBNAQAHAAQJlR4GDQBNAQAPAAEJpRMAAAAAAAAAAA==.薄荷骨丷:BAAALgAECgcJBwAAAA==.',
['薇塔']='薇塔克洛提德:BAAALgAECgYJBgAAAA==.',
['薇蕊']='薇蕊:BAAALgAFFAEJAQAAAA==.',
['薇薇']='薇薇小宝贝:BAAALgAECgYJCAAAAA==.',
['虎皮']='虎皮脆香米:BAABLgAECn8eAAQaAAgJ3yI5CgDuAgAaAAgJ3yI5CgDuAgAlAAEJVxVjDQBBAAAcAAEJmxOmHQA/AAAAAA==.',
['虚空']='虚空羊羊:BAAALgAECgYJBgAAAA==.虚空邪能:BAAALgAECgQJBAAAAA==.',
['蜡烛']='蜡烛台:BAAALgAECgEJAQAAAA==.',
['蝴蝶']='蝴蝶薇安:BAAALgAECgQJBAAAAA==.',
['血冰']='血冰:BAAALgADCgEJAQAAAA==.',
['血斑']='血斑泥沼:BAAALgAECgYJBwABLgAFFAIJAgACAAAAAA==.',
['血瞳']='血瞳渡灵:BAAALgAECgYJDQAAAA==.',
['西索']='西索莫罗:BAACLgAFFH8IAAMQAAQJSQQeDAAVAQAQAAQJSQQeDAAVAQAKAAIJmAG4EABsAAAuAAQKfx0AAxAACAl7FSkQADwCABAACAkSFSkQADwCAAoABgmBFZkwAH8BAAAA.',
['覆手']='覆手为云:BAAALgAECgYJEAAAAA==.',
['言若']='言若言诺:BAAALgAECgQJBQAAAA==.',
['让盛']='让盛夏去贪玩:BAAALgAECgMJAwAAAA==.',
['记忆']='记忆的小德:BAAALgADCgcJBwAAAA==.',
['诡术']='诡术妖僧:BAAALgAFFAMJBAAAAA==.',
['诺夜']='诺夜花秋雪:BAABLgAFFH8FAAMOAAUJTASSGgAeAQAOAAQJTASSGgAeAQAVAAEJAACQBwBAAAAAAA==.',
['豆丁']='豆丁甜甜:BAAALgAECgEJAQAAAA==.',
['豆乳']='豆乳玉麒麟:BAACLgAFFH8IAAIRAAMJVSN8AwBAAQARAAMJVSN8AwBAAQAuAAQKfxwAAhEACAlJJvQDAGkDABEACAlJJvQDAGkDAAAA.',
['豌豆']='豌豆芽:BAAALgAECgUJBQABLgAECgkJDwACAAAAAA==.',
['豪雨']='豪雨奶神:BAAALgAECgcJCwAAAA==.',
['贪狼']='贪狼:BAAALgAECgQJBQAAAA==.',
['贲勇']='贲勇之虓:BAAALgAECgIJAgAAAA==.',
['贵样']='贵样尊者:BAAALgAECgYJCAAAAA==.',
['贼儒']='贼儒:BAAALgAECgIJAgAAAA==.',
['赛纳']='赛纳土斯:BAAALgAECgcJDQAAAA==.',
['赵子']='赵子龙:BAAALgAFFAEJAQABLgAFFAYJBQAiALQGAA==.',
['赶快']='赶快给我上:BAAALgADCgkJCQABLgAECgcJCwACAAAAAA==.',
['超牛']='超牛:BAAALgAECgEJAQAAAA==.',
['超震']='超震声波:BAAALgADCgEJAQABLgAFFAMJBgAFAPwXAA==.',
['跑得']='跑得最快了:BAAALgADCgEJAQAAAA==.',
['身板']='身板硬有容错:BAABLgAECn8ZAAIgAAgJ6BcQDwBzAgAgAAgJ6BcQDwBzAgAAAA==.',
['辛月']='辛月:BAAALgADCgQJBAAAAA==.',
['过水']='过水沙丁渔:BAAALgAECgMJBAAAAA==.过水沙丁鱼:BAAALgAECgYJBwAAAA==.',
['还有']='还有王法吗:BAAALgAECgcJEQAAAA==.',
['迪斯']='迪斯:BAAALgAECgEJAQAAAA==.',
['迷幻']='迷幻森林:BAAALgADCgcJCwAAAA==.',
['逝去']='逝去的正义:BAAALgAECgQJBQAAAA==.',
['逞生']='逞生:BAAALgAECgEJAQAAAA==.',
['逹纳']='逹纳斯:BAABLgAECn8YAAISAAcJSRcFKQAYAgASAAcJSRcFKQAYAgAAAA==.',
['遇见']='遇见鹿:BAACLgAFFH8MAAIGAAQJ6iJ8BACXAQAGAAQJ6iJ8BACXAQAuAAQKfxYAAgYABgn5I6scAFcCAAYABgn5I6scAFcCAAAA.',
['那年']='那年杏花微雨:BAAALgAFFAEJAQAAAA==.',
['邦胖']='邦胖迪:BAAALgAECgEJAwAAAA==.',
['邪恶']='邪恶屠戮者:BAAALgAECgEJAQAAAA==.',
['邪魅']='邪魅悪靈:BAAALgAFFAIJAgAAAA==.',
['醉九']='醉九:BAAALgAECgEJAQAAAA==.醉九的坦克:BAAALgADCgEJAQAAAA==.',
['醉眼']='醉眼问花:BAAALgAECgcJDgAAAA==.',
['野外']='野外音丶德:BAABLgAECn8WAAMmAAYJ/hAxFwACAQAmAAYJ3Q8xFwACAQARAAUJlAogVQDQAAAAAA==.野外音丶猎:BAAALgAECgUJCAAAAA==.',
['錵开']='錵开半夏:BAACLgAFFH8FAAIZAAIJww3ODACIAAAZAAIJww3ODACIAAAuAAQKfx4AAhkABwloEnsuAJ4BABkABwloEnsuAJ4BAAAA.',
['钱立']='钱立仙:BAAALgAECgcJEwAAAA==.',
['铁钴']='铁钴镍铜锌:BAAALgAECgEJAwAAAA==.',
['铄铄']='铄铄:BAABLgAFFH8OAAITAAUJJSKhAQABAgATAAUJJSKhAQABAgAAAA==.',
['铭记']='铭记依韵:BAAALgAECgYJBwAAAA==.',
['银色']='银色玄雷:BAAALgAECgEJAQAAAA==.银色的月光:BAAALgADCgUJBQAAAA==.',
['长眠']='长眠爱坤:BAAALgAECgUJDQABLgAECggJGwADAEsgAA==.',
['阿拉']='阿拉圣骑:BAAALgAECgEJAQAAAA==.阿拉法式:BAAALgAECgEJAQAAAA==.',
['阿波']='阿波次得:BAAALgADCgYJBgAAAA==.',
['阿瑟']='阿瑟柯南道尔:BAABLgAFFH8GAAIOAAIJdSPaKQDLAAAOAAIJdSPaKQDLAAAAAA==.',
['阿瓦']='阿瓦隆之怒:BAAALgAECgYJDwAAAA==.',
['陈宝']='陈宝宝:BAABLgAECn8bAAIDAAcJ5CNcNAChAgADAAcJ5CNcNAChAgAAAA==.',
['陳亦']='陳亦迅:BAAALgADCgEJAQAAAA==.',
['随风']='随风起舞:BAAALgADCgEJAQAAAA==.',
['雨漫']='雨漫年华:BAAALgADCgMJAwAAAA==.',
['雨过']='雨过天晴:BAAALgAECgYJBgAAAA==.',
['雪团']='雪团团:BAAALgAFFAIJAgABLgAFFAQJCAAHAJUeAA==.',
['雪糕']='雪糕糕:BAAALgAECgYJCwABLgAFFAQJCAAHAJUeAA==.',
['雷霆']='雷霆法王:BAAALgAECgEJAQAAAA==.',
['雾隠']='雾隠酌莲华:BAAALgAECgYJAgAAAA==.',
['雾雨']='雾雨霜霏:BAAALgAECgUJBQAAAA==.',
['青云']='青云之蔽月:BAAALgAECgcJDwAAAA==.',
['青峰']='青峰总攻:BAACLgAFFH8IAAIKAAMJYiJzAgAlAQAKAAMJYiJzAgAlAQAuAAQKfyMAAgoACAnrJbsBAF0DAAoACAnrJbsBAF0DAAAA.',
['青溟']='青溟览月:BAAALgAFFAIJAgAAAA==.',
['青黛']='青黛丶:BAAALgAECgYJCQAAAA==.',
['静静']='静静不生气:BAAALgADCgYJBgAAAA==.',
['领主']='领主瑟里耶克:BAAALgAECgcJBwAAAA==.',
['颜真']='颜真:BAAALgAECgEJAQAAAA==.',
['風中']='風中骑缘:BAAALgAECgUJBQAAAA==.',
['風姿']='風姿飒爽:BAAALgAECgYJDwAAAA==.',
['風鸟']='風鸟院丶花月:BAAALgAECgYJCQAAAA==.',
['风之']='风之追忆:BAAALgAECgIJAgAAAA==.',
['风云']='风云:BAAALgADCgMJAwAAAA==.',
['风勇']='风勇士:BAAALgAFFAEJAQAAAA==.',
['风吹']='风吹花花开:BAAALgAECgQJBQAAAA==.',
['风姿']='风姿一众星:BAAALgAECgkJEwAAAA==.',
['风梦']='风梦如影:BAAALgAECgkJEQAAAA==.',
['风飍']='风飍:BAAALgAECgcJDQAAAA==.',
['飘零']='飘零若雪:BAAALgAECgkJBwAAAA==.',
['飘飘']='飘飘叶子:BAAALgAECgIJAwAAAA==.',
['飞凫']='飞凫:BAAALgAECgEJAgAAAA==.',
['飞坏']='飞坏机:BAAALgADCgUJBQAAAA==.',
['飞奔']='飞奔的五花肉:BAAALgAECgQJBwAAAA==.',
['飞龙']='飞龙在天:BAAALgADCgUJBQAAAA==.',
['魔法']='魔法狐咪:BAAALgADCgYJBgAAAA==.',
['魚虎']='魚虎:BAACLgAFFH8IAAIDAAMJtRwFEQAKAQADAAMJtRwFEQAKAQAuAAQKfyEAAgMACAlbH7EvALMCAAMACAlbH7EvALMCAAAA.',
['鲁珀']='鲁珀特之泪:BAAALgAECgcJDQAAAA==.',
['鲨鱼']='鲨鱼曼曼:BAAALgAECgcJCgAAAA==.',
['鹅头']='鹅头:BAAALgAECgYJEwAAAA==.',
['鹤舞']='鹤舞白紗:BAAALgAECgEJAQAAAA==.',
['鹿丶']='鹿丶:BAAALgAECgYJDQABLgAFFAYJGQAMAOAmAA==.',
['麥克']='麥克雷:BAAALgAECgEJAQAAAA==.',
['麥田']='麥田玉米頭兒:BAAALgAECgEJAQAAAA==.',
['麦向']='麦向:BAACLgAFFH8NAAIBAAQJgSEbDAB0AQABAAQJgSEbDAB0AQAuAAQKfxsAAgEACAn9Hh4eAMwCAAEACAn9Hh4eAMwCAAAA.',
['黄泉']='黄泉赎夜姬:BAAALgAECgEJAQAAAA==.',
['黎明']='黎明圣贤:BAAALgAECgQJCAAAAA==.',
['黎罗']='黎罗:BAAALgAFFAEJAQAAAA==.',
['黑暗']='黑暗丿猎魔:BAAALgAECgcJDAAAAA==.',
['黑松']='黑松白鹿:BAACLgAFFH8NAAMBAAUJVxVMEABgAQABAAQJVxVMEABgAQAnAAEJAADxFwA8AAAuAAQKfycAAgEACQkoHgUaAOACAAEACQkoHgUaAOACAAAA.',
['黑沼']='黑沼爽子:BAAALgAECgQJBAAAAA==.',
['黑皮']='黑皮肌肉菀菀:BAACLgAFFH8HAAIOAAMJLxTDDQAFAQAOAAMJLxTDDQAFAQAuAAQKfx0AAw4ACAl2ItISAOUCAA4ACAl2ItISAOUCAB8AAglaGflKAI0AAAAA.',
['默示']='默示录丶:BAACLgAFFH8GAAIBAAMJPRL2JwD4AAABAAMJPRL2JwD4AAAuAAQKfxsAAgEACAntGAg8AEcCAAEACAntGAg8AEcCAAAA.',
['黛眉']='黛眉:BAAALgADCgIJAgAAAA==.',
['龙怒']='龙怒通念师:BAAALgAFFAIJAgAAAA==.',
['龙战']='龙战与野:BAAALgAECgEJAQAAAA==.',
['龙蛇']='龙蛇之变:BAAALgAECgcJDQAAAA==.',
['龙龟']='龙龟:BAAALgADCgIJAgAAAA==.',
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
