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

local lookup = {'Warlock-Destruction','Warlock-Demonology','Mage-Frost','Monk-Mistweaver','DeathKnight-Unholy','Mage-Fire','Mage-Arcane','Warlock-Affliction','Hunter-Marksmanship','Shaman-Restoration','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Unknown-Unknown','Druid-Restoration','Druid-Balance','Paladin-Protection','Paladin-Holy','Paladin-Retribution','DemonHunter-Devourer','Monk-Brewmaster','DemonHunter-Havoc','Priest-Holy','Priest-Discipline','Monk-Windwalker','Hunter-BeastMastery','Warrior-Protection','Rogue-Subtlety','Priest-Shadow','DeathKnight-Blood','Druid-Feral','Shaman-Elemental','Rogue-Assassination','Warrior-Fury','Shaman-Enhancement',}
local provider = {region='CN',realm='世界之树',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agare:BAAALgAECgcJBwAAAA==.Agoena:BAAALgAECgYJDAAAAA==.',
Al='Albemuth:BAABLgAFFH8HAAMBAAQJFCBUCQDDAAABAAIJfB9UCQDDAAACAAIJqyCXLgC2AAAAAA==.',
Am='Amanises:BAAALgAFFAQJBAAAAA==.',
An='Answerqs:BAAALgAECgcJAwAAAA==.',
Ao='Aozora:BAAALgAECgQJBAAAAA==.',
Au='Auror:BAAALgAECgYJDwAAAA==.',
Ba='Baby:BAAALgAECgkJEAAAAA==.',
Bl='Bloodpink:BAAALgADCgUJBQAAAA==.',
Co='Coconut:BAAALgAECgYJDQABLgAFFAMJBgADAOkgAA==.',
Cr='Crane:BAACLgAFFH8HAAIEAAQJJR0bBgBrAQAEAAQJJR0bBgBrAQAuAAQKfxQAAgQACAkVHBIOAHYCAAQACAkVHBIOAHYCAAAA.Crystallize:BAAALgADCgYJBgAAAA==.',
Cy='Cyrbuzz:BAACLgAFFH8TAAIDAAYJOSKGAgBiAgADAAYJOSKGAgBiAgAuAAQKfyQAAgMACQkgIuIUACsDAAMACQkgIuIUACsDAAAA.',
Da='Dabo:BAAALgADCgEJAQAAAA==.Dawnchorus:BAAALgAECggJBgAAAA==.',
Di='Digbick:BAAALgAECgEJAQAAAA==.',
Do='Doomsayer:BAABLgAFFH8IAAICAAQJFRQxEQBZAQACAAQJFRQxEQBZAQAAAA==.Douya:BAAALgAFFAEJAQAAAA==.Douyazs:BAAALgADCgEJAQAAAA==.',
Er='Eros:BAAALgAECgMJAwAAAA==.',
Es='Espresso:BAAALgAFFAEJAQAAAA==.',
Ex='Extinguished:BAAALgAECgIJAgAAAA==.',
Fe='Femto:BAAALgAECgYJBgABLgAECgcJFQAFAFchAA==.',
Fl='Flyq:BAACLgAFFH8HAAMDAAMJ2SFjIgAzAQADAAMJ2SFjIgAzAQAGAAEJOCAAAAAAAAAuAAQKfxgABAcACAkfIYEFANQBAAMACAlMFUZsAP0BAAcABQndI4EFANQBAAYABAlSIAAAAAAAAAAA.',
Fo='Folinic:BAACLgAFFH8GAAMIAAIJUSRQAADgAAAIAAIJUSRQAADgAAACAAEJTAkGSQBTAAAuAAQKfxUAAggABwlYJEMBAOkCAAgABwlYJEMBAOkCAAAA.',
Fu='Funnypotato:BAAALgAFFAIJBAAAAA==.',
Ga='Galgame:BAABLgAECn8aAAIFAAcJYCXJGgDcAgAFAAcJYCXJGgDcAgAAAA==.',
Gt='Gtsmce:BAAALgAFFAQJBAABLgAFFAcJBgAJAG4FAA==.',
Gu='Guessm:BAAALgAECgUJCgAAAA==.',
He='Hebe:BAAALgAECgEJAQAAAA==.',
Ho='Hotbug:BAAALgAECgEJAQAAAA==.',
Ii='Iilliiliil:BAAALgAECgkJDQAAAA==.',
Il='Illiililil:BAAALgAECgcJBwAAAA==.Illillilil:BAAALgAECgkJBgAAAA==.',
Im='Imfiredup:BAAALgAECgYJCAABLgAFFAQJDwADAPQlAA==.',
Is='Isolate:BAAALgAECggJCAABLgAFFAUJFAAKAJ0fAA==.',
Ja='Jaychou:BAABLgAECn8WAAIDAAkJJQw6cQDxAQADAAkJJQw6cQDxAQAAAA==.',
Ka='Kamaruastra:BAACLgAFFH8UAAILAAUJ0RnnBAC4AQALAAUJ0RnnBAC4AQAuAAQKfxUABAsACAm/FTQjAKQBAAsABgnyFjQjAKQBAAwABgmyAkoyAN0AAA0ABAlFCcYqAMcAAAAA.Karena:BAAALgAECgMJAwAAAA==.Karim:BAAALgAECgUJCgAAAA==.',
Ke='Keria:BAAALgAECgYJBgABLgAECgYJDgAOAAAAAA==.',
Ku='Kurva:BAAALgAECgEJAQAAAA==.',
La='Lalalala:BAAALgADCgcJBwAAAA==.Laodu:BAAALgAECgIJAgAAAA==.',
Li='Lilynnsq:BAAALgADCgkJCQAAAA==.',
Lo='Loftmoon:BAAALgAECgEJAQAAAA==.Lota:BAABLgAFFH8LAAIPAAQJbAeRDQAOAQAPAAQJbAeRDQAOAQABLgAFFAYJDwAQAKghAA==.',
Lw='Lwoyue:BAACLgAFFH8GAAMRAAQJ5xUSAgD3AAARAAMJ5BoSAgD3AAASAAIJFA1MFwCKAAAuAAQKfyEABBEACAlLHvwDAM4CABEACAlLHvwDAM4CABIACAklGDUZAEkCABMABQnJE93KAPMAAAAA.Lwoyuews:BAAALgAFFAEJAgAAAA==.',
Ly='Lyfws:BAAALgAFFAIJAgAAAA==.',
Ma='Magiczxd:BAAALgAECgMJAwAAAA==.Mango:BAAALgADCgUJBQAAAA==.Maxdh:BAAALgAECgYJDgAAAA==.',
Mi='Michealstar:BAAALgAECgEJAQAAAA==.Minsoyal:BAAALgAFFAIJAwAAAA==.Miyeon:BAAALgAFFAMJAwAAAA==.',
Ml='Mln:BAAALgAFFAUJBAAAAA==.',
Mo='Monirot:BAAALgADCgIJAgAAAA==.',
My='Myosotis:BAABLgAECn8YAAQCAAcJQB1/DwCWAQACAAUJrBt/DwCWAQABAAMJ3x+eLwD9AAAIAAEJAACuJABfAAAAAA==.',
Ni='Niyah:BAAALgAFFAIJAwAAAA==.',
No='Nothingonyou:BAAALgAFFAIJAwAAAA==.',
Oi='Oicpd:BAEBLgAFFH8GAAMDAAQJIBi6JAAiAQADAAMJ3h66JAAiAQAHAAIJtA3qAACdAAABLgAFFAgJGwAUAJYbAA==.',
Os='Osrisi:BAAALgAECgEJAQAAAA==.',
Ot='Othinus:BAABLgAFFH8HAAIKAAMJYh/SCwAcAQAKAAMJYh/SCwAcAQAAAA==.',
Pa='Paisley:BAAALgAECgcJBgAAAA==.',
Ph='Phos:BAAALgAECgMJBAAAAA==.',
Pl='Planetes:BAAALgAECgEJAQAAAA==.',
Ps='Psy:BAAALgAFFAMJAwAAAA==.',
Qi='Qingf:BAAALgAECgUJBQAAAA==.',
Ra='Raymond:BAAALgAECgUJCAAAAA==.',
Re='Revvez:BAAALgADCgIJAgAAAA==.',
Ro='Rocveadealan:BAAALgADCgUJBQAAAA==.',
So='Soyorin:BAEALgAECgcJCAABLgAFFAgJGwAUAJYbAA==.',
Sw='Sweetcolor:BAAALgAECgkJBQAAAA==.',
Ta='Takira:BAAALgAECgEJAQAAAA==.',
Tf='Tfsi:BAAALgAECgIJAgAAAA==.',
Ti='Timoris:BAEALgAECgYJDAABLgAFFAgJGwAUAJYbAA==.Tinker:BAAALgAECgEJAQAAAA==.',
Wa='Wais:BAABLgAFFH8FAAIEAAIJsyJNDQDPAAAEAAIJsyJNDQDPAAAAAA==.',
We='Weiritter:BAAALgAECgkJBwAAAA==.',
Xi='Xiaosa:BAAALgAECgQJBAAAAA==.',
Xz='Xzmage:BAAALgAECgYJAQAAAA==.',
Yu='Yur:BAAALgAECgkJDwAAAA==.Yuukyuukikan:BAABLgAECn8VAAIFAAcJVyFJKQCVAgAFAAcJVyFJKQCVAgAAAA==.',
Ze='Zerokiller:BAAALgAECgIJAwAAAA==.',
Zo='Zorro:BAAALgADCgMJAwAAAA==.Zouknelofa:BAABLgAFFH8HAAIFAAQJ4w/HIAAWAQAFAAQJ4w/HIAAWAQAAAA==.',
['一只']='一只小猫德:BAABLgAFFH8IAAIQAAQJqx54BgB9AQAQAAQJqx54BgB9AQAAAA==.',
['一品']='一品乌龙茶:BAAALgAECgkJCQAAAA==.一品铜锣烧:BAAALgAECgYJBgAAAA==.一品鲜橙汁:BAAALgADCgYJBgAAAA==.',
['一宝']='一宝:BAAALgAECgYJBQAAAA==.',
['一波']='一波:BAAALgAECgEJAQAAAA==.',
['一炮']='一炮害三贤:BAAALgAFFAIJAgAAAA==.',
['一语']='一语:BAAALgAFFAQJBAAAAA==.',
['一骑']='一骑红尘:BAAALgAECgYJBgAAAA==.',
['七代']='七代火影:BAABLgAECn8gAAIFAAkJDBPGWQDkAQAFAAkJDBPGWQDkAQAAAA==.',
['七剑']='七剑屠龙:BAAALgAECgEJAQAAAA==.',
['万敌']='万敌斩:BAAALgAECgkJEAAAAA==.',
['三吉']='三吉彩花:BAAALgAECgYJCQAAAA==.',
['三玖']='三玖天下第一:BAAALgADCgEJAQAAAA==.',
['三花']='三花儿:BAAALgADCgUJBQAAAA==.',
['上善']='上善月火:BAAALgAECgUJBQAAAA==.',
['不能']='不能非的剑上:BAAALgADCgEJAQAAAA==.',
['不见']='不见俏伶人:BAAALgAECgIJAgAAAA==.',
['不解']='不解风卿:BAAALgAECggJEwAAAA==.',
['且听']='且听虚空:BAAALgAECgYJBgAAAA==.',
['世界']='世界第一中单:BAAALgAECgYJCgAAAA==.',
['东尼']='东尼大木:BAABLgAFFH8HAAIVAAMJkR9BDQAbAQAVAAMJkR9BDQAbAQAAAA==.',
['丝佳']='丝佳丽:BAAALgAECggJCQABLgAFFAEJAQAOAAAAAA==.',
['丨蛋']='丨蛋总丨:BAAALgAECgYJBgAAAA==.',
['丶离']='丶离歌:BAAALgAFFAIJAwAAAA==.',
['丷泡']='丷泡泡灬糖丷:BAAALgAECgQJBwAAAA==.',
['丽萨']='丽萨:BAAALgAECgYJBgAAAA==.',
['举杯']='举杯邀明月:BAAALgAECgUJBgABLgAECggJDgAOAAAAAA==.',
['乆术']='乆术神:BAAALgAECgYJCAAAAA==.',
['乌萨']='乌萨奇奇:BAAALgADCgIJAwAAAA==.',
['乐山']='乐山:BAAALgADCgEJAQAAAA==.',
['乔巴']='乔巴:BAAALgAFFAIJBAAAAA==.',
['二手']='二手月季:BAAALgAECgYJBgAAAA==.',
['二爷']='二爷:BAAALgAECgcJBwABLgAFFAYJAwAOAAAAAA==.',
['二蝶']='二蝶:BAAALgAECgEJAQAAAA==.',
['云海']='云海漫游:BAAALgADCgIJAgAAAA==.',
['云溪']='云溪:BAAALgADCgIJAgAAAA==.',
['云空']='云空:BAAALgAFFAIJAgAAAA==.',
['云雨']='云雨飘零:BAAALgADCgQJBAAAAA==.',
['五目']='五目炒饭:BAAALgADCgUJBQAAAA==.',
['亚力']='亚力马斯内:BAAALgAECgIJAgAAAA==.',
['亚米']='亚米米亚:BAAALgAECgIJAgABLgAFFAQJEAAJAKkkAA==.',
['亲斤']='亲斤:BAAALgAECgIJAQAAAA==.',
['人人']='人人有功练:BAAALgAECgYJCwAAAA==.',
['人洞']='人洞顶山:BAAALgAECgMJAwAAAA==.',
['人神']='人神采飞扬:BAAALgADCgYJBgAAAA==.',
['伏尔']='伏尔加:BAABLgAECn8UAAIPAAgJoBVcBwDxAQAPAAgJoBVcBwDxAQAAAA==.',
['众星']='众星:BAABLgAECn8cAAIPAAkJtRS/JwAWAgAPAAkJtRS/JwAWAgABLgAFFAUJDwAEADIiAA==.',
['传说']='传说之狼盛:BAAALgAECgQJBQAAAA==.传说葡萄鼠:BAAALgAECgYJCgAAAA==.',
['似猫']='似猫非猫:BAAALgAECgQJBAAAAA==.',
['你哪']='你哪那么多事:BAAALgAECgUJBgABLgAFFAMJBAAOAAAAAA==.',
['你的']='你的曲奇饼:BAAALgAECgUJAQAAAA==.',
['你看']='你看不见:BAAALgAECgQJBAAAAA==.',
['佩奇']='佩奇烤猪:BAACLgAFFH8KAAMCAAQJyBOGDwD4AAACAAQJVxOGDwD4AAABAAEJ5wvzFgBRAAAuAAQKfxUAAwIABwlAJOAfAJkCAAIABwlAJOAfAJkCAAEAAQkAAHhtADoAAAAA.',
['依旧']='依旧缺德:BAAALgAECgEJAQAAAA==.',
['信德']='信德维拉:BAACLgAFFH8OAAIWAAQJ5x1IAACQAQAWAAQJ5x1IAACQAQAuAAQKfx0AAxYACQm+IF0HAO8CABYACQm+IF0HAO8CABQAAQmADQAAAAAAAAAA.',
['俨雅']='俨雅君闯位面:BAAALgAFFAEJAQAAAA==.',
['倒了']='倒了玩原神:BAAALgAECgMJBAAAAA==.',
['元宝']='元宝仔:BAAALgAECggJBgAAAA==.元宝孖:BAAALgAFFAIJAgAAAA==.',
['光头']='光头巨人:BAAALgAECgYJBwAAAA==.',
['兔老']='兔老公:BAAALgAECgIJAgAAAA==.',
['八代']='八代目火影:BAAALgADCgcJBwAAAA==.',
['六代']='六代目火影:BAAALgAECgYJDAAAAA==.',
['兰兮']='兰兮:BAACLgAFFH8FAAIPAAIJ+BEVDQCGAAAPAAIJ+BEVDQCGAAAuAAQKfxoAAg8ACAmHI3AFADYDAA8ACAmHI3AFADYDAAAA.',
['兵马']='兵马大元帅:BAAALgAFFAIJAgAAAA==.',
['其实']='其实我叫丁满:BAAALgAECgcJCQAAAA==.',
['兽肉']='兽肉卷儿儿:BAABLgAFFH8HAAIFAAUJxgu/HQApAQAFAAUJxgu/HQApAQAAAA==.',
['再丸']='再丸丸呢:BAAALgADCgQJBAAAAA==.',
['冫西']='冫西瓜:BAEALgAECgUJCAABLgAFFAMJBQACAA4mAA==.',
['冬冬']='冬冬儿:BAAALgAECgEJAQAAAA==.',
['冰之']='冰之哀伤:BAAALgAECgEJAQAAAA==.',
['冰块']='冰块有害健康:BAAALgADCgEJAQAAAA==.',
['冰老']='冰老三:BAAALgAECgQJBgAAAA==.',
['冰霜']='冰霜法师蓝君:BAAALgAECgYJDgAAAA==.',
['冷月']='冷月心:BAAALgAFFAIJAgAAAA==.',
['减脂']='减脂增肌私聊:BAAALgADCgEJAQAAAA==.',
['凛冬']='凛冬之韵:BAAALgAECgIJAwAAAA==.',
['凯茜']='凯茜娅:BAAALgAFFAIJAwAAAA==.',
['凰丶']='凰丶涅槃重生:BAAALgAECgEJAgAAAA==.',
['刑者']='刑者悟僧:BAAALgADCgcJBwAAAA==.',
['创伤']='创伤成就了我:BAAALgAECgEJAQAAAA==.',
['初橙']='初橙:BAAALgADCgEJAQAAAA==.',
['初辞']='初辞逗你开心:BAABLgAFFH8IAAIXAAMJrBqJBwD1AAAXAAMJrBqJBwD1AAAAAA==.',
['别摸']='别摸我內个:BAAALgAECgUJBgAAAA==.',
['别组']='别组那个龙人:BAAALgAECgQJBAAAAA==.',
['刷猫']='刷猫头鹰八:BAAALgADCgEJAQAAAA==.',
['北辰']='北辰正:BAAALgAECgUJBgAAAA==.',
['十二']='十二小仙:BAAALgAECgMJAwAAAA==.',
['十点']='十点法力:BAAALgAECgYJEQABLgAFFAIJAgAOAAAAAA==.',
['千之']='千之堂:BAAALgAECgMJAwAAAA==.',
['千年']='千年遗梦:BAAALgAECgMJAwAAAA==.',
['半纸']='半纸清寒:BAAALgAECgYJBgAAAA==.',
['卑弥']='卑弥呼:BAAALgAECgcJDgAAAA==.',
['卓辉']='卓辉星拼图:BAAALgAECgYJCgAAAA==.',
['南天']='南天西松:BAAALgAECgYJDgAAAA==.',
['南小']='南小满:BAAALgADCgcJBwAAAA==.',
['卡彭']='卡彭:BAABLgAECn8XAAIKAAYJwCWCFgBiAgAKAAYJwCWCFgBiAgAAAA==.',
['卡托']='卡托西卡琉斯:BAABLgAECn8WAAMRAAYJHSIkDQD1AQARAAUJwCIkDQD1AQASAAYJmB0gNQCoAQAAAA==.',
['卡提']='卡提西亚:BAAALgAECgcJBwAAAA==.',
['卡皮']='卡皮巴拉丶:BAAALgAECggJEQAAAA==.',
['印帝']='印帝安老斑鸠:BAAALgADCgIJAgAAAA==.',
['印第']='印第安山药:BAAALgAECgEJAwAAAA==.',
['原神']='原神牛逼:BAAALgAECgcJBwAAAA==.',
['双旗']='双旗镇刀客:BAAALgAECgYJAQAAAA==.',
['口当']='口当口当:BAABLgAECn8UAAIYAAgJghwXCgCXAgAYAAgJghwXCgCXAgAAAA==.',
['古井']='古井贡:BAAALgAECgEJAgAAAA==.',
['只因']='只因倪太美:BAAALgAECgUJBQAAAA==.',
['叭叭']='叭叭啦叭叭:BAAALgADCgUJBQAAAA==.',
['可乐']='可乐七:BAAALgAECgEJAQAAAA==.可乐不仂丶:BAAALgAECgcJBwAAAA==.可乐不可丶:BAAALgAECgcJEAAAAA==.可乐卟乐丶:BAAALgAECgkJCgAAAA==.可乐要加冰:BAAALgAECggJDgAAAA==.',
['可仂']='可仂不乐丶:BAAALgAECgcJAQAAAA==.',
['可勒']='可勒不乐丶:BAAALgAECgcJBwAAAA==.',
['可可']='可可制:BAAALgADCgcJBwAAAA==.',
['可是']='可是:BAAALgAFFAEJAQAAAA==.',
['可达']='可达鸭爱睡觉:BAAALgAECgYJCQABLgAFFAIJBAAOAAAAAA==.',
['叶圣']='叶圣:BAACLgAFFH8NAAIEAAYJtwyMBQB9AQAEAAYJtwyMBQB9AQAuAAQKfxwABAQACQlZEnoUACYCAAQACQlZEnoUACYCABkABgmWC5c8ACkBABUAAQnpFdmPACUAAAAA.',
['叶江']='叶江枫:BAAALgADCgcJBwAAAA==.',
['吉尔']='吉尔鐡鹰:BAAALgAECgEJAQAAAA==.',
['吻如']='吻如雪上霜:BAABLgAFFH8GAAICAAQJwRw2DAB6AQACAAQJwRw2DAB6AQABLgAFFAcJCgADAO4cAA==.',
['呆西']='呆西十七号:BAABLgAFFH8LAAILAAUJ4xf0BAC3AQALAAUJ4xf0BAC3AQAAAA==.呆西十五号:BAABLgAFFH8FAAILAAQJXB7ZBwBzAQALAAQJXB7ZBwBzAQAAAA==.呆西十八号:BAABLgAFFH8GAAILAAUJ3RbfCQBTAQALAAUJ3RbfCQBTAQAAAA==.呆西十六号:BAABLgAFFH8JAAILAAUJlhnzBAC3AQALAAUJlhnzBAC3AQAAAA==.',
['呵乐']='呵乐不乐丶:BAAALgAECgcJBgAAAA==.',
['咕哒']='咕哒子:BAAALgAECgEJAgAAAA==.',
['咸鱼']='咸鱼麦片:BAAALgAFFAQJAQAAAA==.',
['哇噢']='哇噢:BAAALgAECgUJBAAAAA==.',
['哪泥']='哪泥哞:BAAALgAECgQJCgAAAA==.',
['唵嘛']='唵嘛呢叭咪吽:BAABLgAECn8WAAIaAAcJUBKlNgDUAQAaAAcJUBKlNgDUAQAAAA==.',
['啊西']='啊西八法爷:BAAALgAECgYJCgAAAA==.',
['啵哔']='啵哔啵哔啵:BAAALgADCgYJBgAAAA==.',
['善情']='善情:BAABLgAFFH8FAAIVAAMJOhH+EgDhAAAVAAMJOhH+EgDhAAAAAA==.',
['善灵']='善灵:BAAALgADCgcJBwAAAA==.',
['喵谛']='喵谛斯:BAACLgAFFH8JAAIDAAMJfxo8DQAnAQADAAMJfxo8DQAnAQAuAAQKfxcAAgMACAl/G0c9AIICAAMACAl/G0c9AIICAAAA.',
['喷焱']='喷焱龙:BAAALgAECgQJBgAAAA==.',
['嗷嗷']='嗷嗷酷:BAABLgAECn8VAAIDAAYJMQNDAQH4AAADAAYJMQNDAQH4AAAAAA==.',
['嘉特']='嘉特洛恩克:BAAALgAECgYJCwAAAA==.',
['噌噌']='噌噌:BAAALgAECgUJBQAAAA==.',
['四代']='四代火影:BAAALgAECgcJEwAAAA==.四代目火影:BAAALgAECgcJEwAAAA==.',
['四只']='四只小猫德:BAABLgAFFH8GAAIQAAQJqB8ZBwBxAQAQAAQJqB8ZBwBxAQAAAA==.四只小鸟德:BAAALgAFFAUJAwAAAA==.',
['回头']='回头再说吧:BAACLgAFFH8FAAIZAAQJIgg3BgAaAQAZAAQJIgg3BgAaAQAuAAQKfxgAAxUACAn5IAUOALMCABUACAnMHQUOALMCABkABwkDIoENAKMCAAEuAAUUBQkTABsAmBgA.',
['国宝']='国宝黑骑士:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光女神:BAAALgAECgEJAgAAAA==.圣光审判众生:BAAALgAECgUJCgAAAA==.圣光毁灭你:BAAALgAECgUJBQAAAA==.',
['圣维']='圣维伦:BAAALgAECgcJEAAAAA==.',
['坑跌']='坑跌僧:BAABLgAECn8aAAQEAAcJBRiTIACwAQAEAAcJBRiTIACwAQAZAAQJnByaSgDoAAAVAAIJshUPbwCGAAAAAA==.坑跌术:BAAALgAFFAIJBAAAAA==.坑跌死骑:BAAALgAECgUJBQAAAA==.坑跌贼:BAAALgAFFAIJBAAAAA==.坑跌骑丶:BAAALgAECgEJAQAAAA==.',
['坚冰']='坚冰至:BAAALgADCgMJAwAAAA==.',
['墒以']='墒以光年:BAAALgAECgUJBQAAAA==.',
['墓风']='墓风之寒:BAAALgADCgIJAgAAAA==.',
['墨钥']='墨钥:BAAALgAFFAEJAQAAAA==.',
['夏一']='夏一可可:BAAALgAECgYJBgAAAA==.',
['多面']='多面手:BAAALgAECgUJBQAAAA==.',
['夜夜']='夜夜秉烛游:BAAALgADCgYJBgAAAA==.',
['夜若']='夜若水:BAAALgAECgMJAgAAAA==.',
['夜雨']='夜雨潇湘:BAAALgAECgYJBgAAAA==.',
['大一']='大一:BAAALgAECgEJAQAAAA==.',
['大懒']='大懒虫:BAABLgAFFH8JAAIYAAUJkREGBQCZAQAYAAUJkREGBQCZAQAAAA==.',
['大海']='大海乄:BAAALgAECgYJBgABLgAFFAYJFQAQAHIhAA==.',
['大眼']='大眼肥猫:BAAALgADCgMJAwAAAA==.',
['大蘑']='大蘑咕:BAAALgAECgUJBQAAAA==.',
['大钻']='大钻子:BAAALgAECgYJBgAAAA==.',
['天下']='天下无贼:BAABLgAECn8UAAIcAAcJ/xZ8JADVAQAcAAcJ/xZ8JADVAQAAAA==.',
['天天']='天天上课:BAAALgAECgYJDAAAAA==.',
['奈亚']='奈亚子:BAAALgAFFAQJAgAAAA==.',
['奈斯']='奈斯巴蒂:BAAALgAECgIJAgAAAA==.',
['奥德']='奥德诺:BAAALgAECgcJDwAAAA==.',
['奶倒']='奶倒坦坦死奶:BAAALgAECgMJAwAAAA==.',
['奶味']='奶味蓝:BAAALgAECgQJBAABLgAFFAMJAwAOAAAAAA==.',
['好吃']='好吃兔兔:BAAALgADCgYJBgAAAA==.',
['好好']='好好吃:BAAALgADCgIJAgAAAA==.',
['好想']='好想玩原神啊:BAABLgAFFH8IAAIPAAMJGiWcCABJAQAPAAMJGiWcCABJAQAAAA==.',
['好甜']='好甜:BAAALgAECgYJBQAAAA==.',
['好运']='好运波比:BAABLgAFFH8GAAICAAIJuRGVMwCrAAACAAIJuRGVMwCrAAAAAA==.',
['姜汁']='姜汁可乐:BAAALgADCgcJBwAAAA==.',
['威尔']='威尔逊:BAAALgADCgUJBQABLgAFFAUJCQAQANogAA==.',
['子山']='子山老衲:BAAALgAECgQJBAAAAA==.',
['孙悟']='孙悟饭桶:BAAALgAECgYJCwAAAA==.',
['它在']='它在挣扎:BAAALgAECggJCAAAAA==.它在痛苦:BAABLgAFFH8JAAICAAMJqh7bGwAWAQACAAMJqh7bGwAWAQAAAA==.',
['守望']='守望梦境:BAABLgAFFH8IAAIQAAMJ/RDYBQD6AAAQAAMJ/RDYBQD6AAAAAA==.',
['安缇']='安缇诺雅:BAAALgAFFAIJAwAAAA==.',
['富贵']='富贵爆爆丨:BAAALgAECgQJBQAAAA==.',
['小呆']='小呆牧:BAABLgAECn8aAAIdAAgJkBQSGQAZAgAdAAgJkBQSGQAZAgAAAA==.小呆骑:BAAALgAFFAMJAwAAAA==.',
['小咔']='小咔拉咪:BAAALgADCgEJAQAAAA==.',
['小小']='小小猫咪:BAAALgAECgEJAQAAAA==.',
['小怪']='小怪物:BAAALgAECgMJBQAAAA==.',
['小拾']='小拾伍:BAAALgAECgQJBAAAAA==.小拾柒:BAAALgAFFAEJAQAAAA==.小拾陆:BAABLgAFFH8FAAIZAAUJTgw1AgCYAQAZAAUJTgw1AgCYAQAAAA==.',
['小枪']='小枪打飞艇:BAAALgAECgYJBgAAAA==.',
['小波']='小波:BAAALgAECgYJCAABLgAFFAIJBQAJAHYhAA==.',
['小火']='小火鸡:BAAALgAECgEJAQAAAA==.',
['小狼']='小狼灬:BAAALgAECgkJCQABLgAFFAUJBQAPAJUjAA==.',
['小猪']='小猪鼻美美宝:BAAALgADCgEJAQAAAA==.',
['小瑶']='小瑶依丶:BAABLgAFFH8IAAIDAAQJwQ8sCQBXAQADAAQJwQ8sCQBXAQAAAA==.',
['小睡']='小睡十一分钟:BAAALgAFFAQJBAAAAA==.',
['小红']='小红手刺杀:BAAALgAECgcJEAAAAA==.',
['小缇']='小缇娜:BAAALgAECgUJBQAAAA==.',
['小美']='小美一号:BAAALgAECgIJAgAAAA==.',
['小银']='小银子:BAAALgAECgYJBgAAAA==.',
['小面']='小面包:BAAALgAECgIJAgAAAA==.',
['尤皮']='尤皮皮:BAAALgAFFAIJBAAAAA==.',
['山音']='山音鹿鸣:BAAALgAFFAIJAwABLgAFFAMJCQADAH8aAA==.',
['山顶']='山顶洞人:BAABLgAFFH8FAAITAAMJqBnyHAC6AAATAAMJqBnyHAC6AAAAAA==.',
['巴蒂']='巴蒂斯图塔:BAAALgAECgkJDwAAAA==.',
['布娜']='布娜娜丶:BAABLgAFFH8FAAIDAAUJlQsVCgBOAQADAAUJlQsVCgBOAQAAAA==.',
['布瑞']='布瑞吉:BAAALgADCggJCAABLgAFFAEJAQAOAAAAAA==.',
['希尔']='希尔芙乐艾:BAABLgAECn8gAAMMAAgJxyJgAwAsAwAMAAgJxyJgAwAsAwALAAMJ7wvaTQCYAAAAAA==.',
['希瓦']='希瓦丶丶:BAAALgAECgMJAwAAAA==.',
['希耶']='希耶尔丿:BAAALgADCgYJBgAAAA==.',
['常世']='常世万法仙君:BAABLgAFFH8IAAMBAAQJtRI1CwCwAAABAAIJERU1CwCwAAACAAIJWhCiNACpAAAAAA==.',
['平安']='平安喜樂:BAAALgAECgMJAwAAAA==.',
['并非']='并非骑士:BAAALgAECgYJDwAAAA==.',
['幻境']='幻境奈丝:BAAALgAECgYJCQAAAA==.',
['幽儿']='幽儿希卡:BAAALgAECgcJBwAAAA==.',
['幽魂']='幽魂魔尊:BAAALgAECgYJBgAAAA==.',
['开始']='开始与结束:BAAALgADCgEJAQAAAA==.开始准备丶:BAAALgAECgIJAgAAAA==.',
['开心']='开心蛋:BAAALgADCgYJBgABLgAECgcJEAAOAAAAAA==.',
['张航']='张航齐:BAAALgADCgUJBAAAAA==.',
['强力']='强力皆知强力:BAAALgAFFAIJAgAAAA==.',
['影如']='影如岚:BAACLgAFFH8FAAIVAAIJCRiyCgCqAAAVAAIJCRiyCgCqAAAuAAQKfyIAAhUACAlxIbkHAAoDABUACAlxIbkHAAoDAAAA.',
['彼岸']='彼岸花开:BAAALgAECgEJAQAAAA==.',
['待好']='待好别动:BAAALgAFFAIJAwAAAA==.',
['徐不']='徐不凡:BAAALgAECgEJAQAAAA==.',
['循环']='循环的初见:BAAALgAECgMJAwAAAA==.',
['微笑']='微笑丿迪妮莎:BAAALgAECgcJCgAAAA==.',
['德拉']='德拉玛:BAAALgAFFAIJAgAAAA==.',
['心中']='心中有术丶:BAAALgAFFAIJAgAAAA==.',
['心向']='心向光眀:BAAALgAECgUJBQAAAA==.',
['心素']='心素:BAAALgAECgUJCQAAAA==.',
['恶魔']='恶魔的驱使者:BAAALgADCgEJAQAAAA==.',
['悄悄']='悄悄的来:BAAALgADCgMJAwAAAA==.',
['悠云']='悠云幽月:BAAALgAECggJDgAAAA==.',
['悦容']='悦容:BAAALgAFFAIJBAABLgAFFAUJFQAZAN0jAA==.',
['情纯']='情纯女高中生:BAAALgAECgQJCAAAAA==.',
['惊寂']='惊寂:BAAALgAECgQJAQAAAA==.',
['愚人']='愚人码头:BAABLgAFFH8HAAIVAAMJjx1rBwD3AAAVAAMJjx1rBwD3AAAAAA==.',
['慕少']='慕少艾:BAAALgAECgYJBwAAAA==.',
['懂你']='懂你意思:BAAALgAECgcJBgAAAA==.',
['懒牛']='懒牛牛:BAAALgADCgUJBQAAAA==.',
['懒神']='懒神:BAAALgAECgQJBAAAAA==.',
['懵懂']='懵懂小龙人:BAABLgAECn8aAAMLAAcJCxnxGwDoAQALAAcJ1xbxGwDoAQANAAQJoRXxJQD0AAAAAA==.',
['成名']='成名在望:BAAALgAECgEJAQABLgAECgEJAgAOAAAAAA==.',
['我一']='我一个飞:BAAALgAECgcJBQAAAA==.我一箭你就笑:BAABLgAECn8UAAMaAAgJfBkAGgBsAgAaAAgJsRcAGgBsAgAJAAMJNRYLYgC4AAAAAA==.',
['我好']='我好机智:BAABLgAFFH8KAAIKAAQJ1hoIBQB/AQAKAAQJ1hoIBQB/AQAAAA==.',
['我是']='我是仙女:BAAALgAECgcJCwAAAA==.',
['我爱']='我爱游戏:BAAALgAECgQJBAAAAA==.',
['战时']='战时:BAAALgADCgIJAgAAAA==.',
['战鸽']='战鸽不是战歌:BAAALgAECgMJAwAAAA==.',
['所愿']='所愿丷:BAAALgAECgEJAQAAAA==.',
['所罗']='所罗门死骑:BAABLgAECn8UAAIeAAgJVxbgEAD8AQAeAAgJVxbgEAD8AQAAAA==.',
['手写']='手写德从前:BAAALgAECgYJBwAAAA==.',
['打奶']='打奶别打我:BAAALgAECggJEgAAAA==.',
['扛不']='扛不住:BAAALgAECgEJAQAAAA==.',
['扫堂']='扫堂腿:BAAALgAECgQJBgAAAA==.',
['扭曲']='扭曲虚空:BAAALgAECgMJBAAAAA==.',
['抚春']='抚春溪:BAAALgAFFAUJBAAAAA==.',
['抹茶']='抹茶大福:BAACLgAFFH8NAAILAAUJ3x72AwDWAQALAAUJ3x72AwDWAQAuAAQKfx4ABAsACAkbJb0EAEIDAAsACAkbJb0EAEIDAAwABQmtDDMsABIBAA0AAgkiCqk5AEwAAAAA.',
['拉普']='拉普拉斯:BAAALgAECgEJAwAAAA==.',
['拉比']='拉比丽斯:BAAALgADCgEJAQAAAA==.',
['拉瑞']='拉瑞诺姆:BAAALgAECgYJBgAAAA==.',
['挖哦']='挖哦:BAAALgAECgMJAwAAAA==.',
['挖掘']='挖掘机哪家强:BAAALgAECgcJBwAAAA==.',
['搁浅']='搁浅:BAAALgAECgQJBwAAAA==.',
['支配']='支配:BAAALgADCgYJBgAAAA==.',
['整点']='整点脆脆薯条:BAAALgADCgUJBQAAAA==.整点薯条薯条:BAAALgAECgUJBQAAAA==.',
['无尽']='无尽的点穴:BAAALgAECgcJBwAAAA==.',
['无道']='无道极法魔君:BAAALgAFFAQJBAAAAA==.',
['旷古']='旷古绝今:BAAALgAECgcJBwAAAA==.',
['星慕']='星慕:BAACLgAFFH8GAAIXAAIJqB+qCgC6AAAXAAIJqB+qCgC6AAAuAAQKfxgAAhcACAk3GM0bAP4BABcACAk3GM0bAP4BAAAA.',
['星灵']='星灵乄:BAAALgAECgcJBwAAAA==.',
['星铭']='星铭的铭:BAAALgAECgYJBgAAAA==.',
['春水']='春水煎茶:BAAALgAECgEJAQAAAA==.',
['是卜']='是卜瑞斯:BAABLgAFFH8GAAISAAQJMBr4BgBmAQASAAQJMBr4BgBmAQAAAA==.',
['是糯']='是糯糯呦:BAABLgAFFH8IAAMQAAMJmxs1BAAmAQAQAAMJmxs1BAAmAQAfAAIJTA4nBACwAAAAAA==.',
['昼眠']='昼眠听雨:BAAALgAFFAIJBAAAAA==.',
['普洱']='普洱:BAAALgAECgQJBAAAAA==.',
['晴天']='晴天:BAAALgADCgEJAQAAAA==.晴天大宝贝:BAACLgAFFH8WAAIXAAYJvhWIAAAHAgAXAAYJvhWIAAAHAgAuAAQKfxsAAxcACQn3FDIWACsCABcACQn3FDIWACsCAB0AAQkRAaxrABsAAAAA.',
['智人']='智人:BAABLgAFFH8GAAMKAAQJ6Q2cCgAtAQAKAAQJ6Q2cCgAtAQAgAAIJMBEQFgCgAAAAAA==.',
['暂列']='暂列仙班:BAAALgAFFAIJAgAAAA==.',
['暗夜']='暗夜屠戮:BAAALgAFFAIJAgAAAA==.',
['暗老']='暗老三:BAAALgAECgIJAgAAAA==.',
['暴躁']='暴躁黑猫:BAAALgAFFAIJBAAAAA==.',
['暴龙']='暴龙无敌战神:BAAALgADCgEJAQAAAA==.',
['曼侬']='曼侬:BAAALgADCgEJAQAAAA==.',
['月半']='月半:BAAALgADCgYJCAAAAA==.',
['月村']='月村手毬:BAABLgAFFH8NAAIPAAYJsBbvAQDmAQAPAAYJsBbvAQDmAQAAAA==.',
['月灵']='月灵儿:BAAALgAECgIJAgAAAA==.',
['月烬']='月烬:BAAALgAECgYJBwAAAA==.',
['有些']='有些人:BAAALgADCgYJBgAAAA==.',
['有冠']='有冠希没关系:BAAALgAECgUJCQAAAA==.',
['有马']='有马贵将:BAAALgAECgEJAgAAAA==.',
['朔望']='朔望月:BAABLgAFFH8HAAIgAAMJ+AoaEQDmAAAgAAMJ+AoaEQDmAAAAAA==.',
['木折']='木折:BAAALgADCgEJAQAAAA==.',
['木沐']='木沐沐:BAAALgADCgEJAQAAAA==.',
['未见']='未见之面:BAAALgAECgYJCwAAAA==.',
['本笃']='本笃:BAAALgAECgEJAQAAAA==.',
['术妈']='术妈:BAAALgAECgEJAgAAAA==.',
['术术']='术术束:BAAALgAECgYJBgAAAA==.',
['朵蜜']='朵蜜你啵啵:BAAALgAECgYJCAAAAA==.',
['李柳']='李柳:BAAALgAECgUJBgAAAA==.',
['杨术']='杨术术:BAAALgADCgUJBQAAAA==.',
['杰尼']='杰尼龟:BAAALgAECgkJBwAAAA==.',
['杰斯']='杰斯还没干:BAAALgAECgIJAgAAAA==.',
['林暗']='林暗草惊风:BAAALgAECgQJBAAAAA==.',
['林落']='林落雪:BAAALgADCgQJBwAAAA==.',
['枫邪']='枫邪神:BAAALgAFFAEJAQAAAA==.',
['染秋']='染秋山:BAABLgAFFH8FAAITAAQJ/gyZDQA+AQATAAQJ/gyZDQA+AQAAAA==.',
['柚缘']='柚缘:BAAALgAFFAMJAwAAAA==.柚缘的小德:BAABLgAECn8VAAIPAAcJrRt/IgA0AgAPAAcJrRt/IgA0AgABLgAFFAMJAwAOAAAAAA==.',
['柠檬']='柠檬精:BAAALgADCgEJAgAAAA==.',
['查斯']='查斯特贝宁顿:BAAALgAECgEJAQAAAA==.',
['树犹']='树犹如此:BAAALgAFFAEJAQAAAA==.',
['格桑']='格桑曲培:BAAALgADCgUJBwAAAA==.',
['格莱']='格莱斯艾丝:BAAALgAECgEJAwAAAA==.',
['桃妮']='桃妮妮:BAAALgAECgQJBwAAAA==.',
['桃气']='桃气抹茶奶芙:BAAALgADCgEJAgAAAA==.',
['桐子']='桐子:BAAALgAECgEJAgAAAA==.',
['梅山']='梅山月色:BAAALgADCgEJAQAAAA==.',
['梅菲']='梅菲斯特邪:BAAALgAECgQJBAAAAA==.',
['梦梦']='梦梦呜:BAAALgAFFAEJAQAAAA==.',
['梵尘']='梵尘心:BAAALgADCgcJBwAAAA==.',
['梵帝']='梵帝罡:BAAALgADCgYJCgAAAA==.',
['森屿']='森屿牧歌:BAABLgAFFH8IAAIEAAUJWhVhAwBUAQAEAAUJWhVhAwBUAQAAAA==.',
['森林']='森林原人:BAAALgAECgIJAgABLgAFFAMJBwAVAJEfAA==.',
['森海']='森海灬飞霞:BAAALgADCgYJBgAAAA==.',
['欣欣']='欣欣真可爱:BAAALgADCgEJAQAAAA==.',
['正义']='正义大叔:BAAALgADCgYJBgAAAA==.',
['歪瑞']='歪瑞奈丝:BAABLgAECn8UAAIFAAgJ/Rp3NQBhAgAFAAgJ/Rp3NQBhAgAAAA==.',
['死亡']='死亡深度:BAAALgAECgQJBgAAAA==.',
['死鱼']='死鱼安乐:BAAALgAECgEJAQABLgAFFAQJBAAOAAAAAA==.死鱼忧患:BAAALgAFFAEJAQAAAA==.死鱼方丈:BAAALgAECgMJAwAAAA==.死鱼魅魔:BAACLgAFFH8GAAMCAAMJ/Q4tKQDQAAACAAMJLA4tKQDQAAAIAAEJwgJbBwBIAAAuAAQKfxgAAwIACAnUIsITAN8CAAIACAnkIcITAN8CAAgAAgnlE8IdAIMAAAAA.',
['残心']='残心屠戮:BAABLgAFFH8FAAIJAAIJdiF0GADLAAAJAAIJdiF0GADLAAAAAA==.',
['毁灭']='毁灭六六丶:BAAALgAECgQJBgAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8HAAIYAAQJ5x1pCABVAQAYAAQJ5x1pCABVAQABLgAFFAUJKgAYAP8kAA==.',
['水丨']='水丨泊:BAABLgAECn8aAAIVAAkJuxSQHwAFAgAVAAkJuxSQHwAFAgAAAA==.',
['水劣']='水劣:BAAALgAECgEJAgAAAA==.',
['水母']='水母大人:BAAALgAECgUJBwABLgAECggJEgAOAAAAAA==.',
['汐汐']='汐汐不嘻嘻:BAAALgAECgYJCAAAAA==.',
['江步']='江步月:BAABLgAFFH8IAAIFAAMJuRagKQDzAAAFAAMJuRagKQDzAAAAAA==.',
['沐泽']='沐泽:BAAALgAECgEJAQAAAA==.',
['油焖']='油焖大胖虾:BAAALgAECgYJBgAAAA==.',
['法亖']='法亖:BAAALgAECgUJCwAAAA==.',
['波比']='波比:BAAALgAECgUJCQAAAA==.',
['洛芯']='洛芯玥:BAAALgADCgEJAQAAAA==.',
['洛酒']='洛酒:BAAALgAECgcJBwABLgAECgkJCgAOAAAAAA==.',
['洛骑']='洛骑:BAAALgAECgEJAQAAAA==.',
['洞八']='洞八三奶神:BAAALgAECgYJCgAAAA==.',
['浅巷']='浅巷旧时光:BAAALgAECgYJDAAAAA==.',
['浪漫']='浪漫至死不渝:BAAALgAECgIJAgAAAA==.',
['浮屠']='浮屠三秋叶:BAAALgAECgYJCgAAAA==.',
['海角']='海角社区吧主:BAAALgAECgQJBAAAAA==.',
['深紅']='深紅:BAAALgADCgEJAQAAAA==.',
['深蓝']='深蓝色海:BAAALgAECgEJAQAAAA==.',
['清风']='清风伴晚霞:BAAALgAECgMJAwAAAA==.',
['温柔']='温柔一棒:BAAALgAECgYJDgAAAA==.温柔鑫:BAAALgAECgEJAwAAAA==.',
['湛然']='湛然常寂:BAAALgADCgIJAgAAAA==.',
['潜不']='潜不入你的心:BAABLgAECn8UAAMcAAYJKiNtGABEAgAcAAYJKiNtGABEAgAhAAEJaBkAAAAAAAAAAA==.',
['火者']='火者:BAAALgAECgkJCQAAAA==.',
['灬小']='灬小光头灬:BAAALgAECgMJAwAAAA==.',
['灰土']='灰土虫:BAAALgAECgYJBwABLgAFFAQJBwABABQgAA==.',
['灰色']='灰色的灰灰:BAAALgAFFAIJAgAAAA==.',
['灿烂']='灿烂的树叶:BAAALgADCgYJBgAAAA==.',
['炸香']='炸香香咩恶霸:BAAALgAFFAQJBAAAAA==.',
['烤面']='烤面包包:BAAALgAFFAEJAQAAAA==.',
['热情']='热情之基:BAAALgAECgYJCAAAAA==.',
['無終']='無終:BAAALgAFFAEJAQABLgAECggJIQAbADIjAA==.',
['焦糖']='焦糖麦芽:BAACLgAFFH8OAAMJAAQJcxMCBADPAAAJAAMJZhECBADPAAAaAAEJmxmSIABfAAAuAAQKfx8AAwkACAlRHgEXAHMCAAkACAkJHQEXAHMCABoAAQkRJriqAG8AAAAA.',
['焰狐']='焰狐:BAAALgAECggJDAAAAA==.',
['焱喵']='焱喵:BAACLgAFFH8JAAIUAAMJoxMTDgDrAAAUAAMJoxMTDgDrAAAuAAQKfxgAAxQACAkPGhQxADYCABQACAkPGhQxADYCABYAAwk9E11MAL0AAAAA.',
['煙霧']='煙霧鏡:BAABLgAFFH8GAAMaAAMJPCKNBgA5AQAaAAMJPCKNBgA5AQAJAAEJ/hmsJQBSAAAAAA==.',
['熊猫']='熊猫警长:BAABLgAECn8VAAIEAAcJKhhUGgDpAQAEAAcJKhhUGgDpAQAAAA==.',
['爱在']='爱在桃花树下:BAAALgADCgYJBgAAAA==.',
['爱玩']='爱玩篮球的坤:BAAALgAFFAIJAwAAAA==.',
['牛狼']='牛狼:BAAALgADCgIJAgAAAA==.',
['牧之']='牧之:BAAALgAECgQJAwAAAA==.',
['狂怒']='狂怒熊熊:BAAALgAFFAIJAwAAAA==.',
['狂战']='狂战大板鲫:BAAALgADCgMJAwAAAA==.',
['狐丸']='狐丸丷:BAAALgAECgYJDQAAAA==.',
['狐森']='狐森:BAAALgAECgUJBQAAAA==.',
['独自']='独自殒落:BAAALgAECgEJAQAAAA==.',
['猎残']='猎残阳:BAAALgADCgYJBgAAAA==.',
['猛犸']='猛犸不上班:BAAALgAECgYJCwAAAA==.',
['猛龙']='猛龙过江:BAAALgAECgcJDQABLgAECgcJEAAOAAAAAA==.',
['猪佳']='猪佳佳:BAAALgAECgUJDQAAAA==.',
['猪宝']='猪宝:BAAALgADCgIJAgAAAA==.',
['猪排']='猪排小汉堡:BAAALgADCgEJAgAAAA==.',
['猫灯']='猫灯伏特加:BAAALgAECgYJCwAAAA==.',
['玄灵']='玄灵:BAAALgADCgMJAwAAAA==.',
['王小']='王小树:BAAALgAFFAQJBAAAAA==.',
['王思']='王思聪:BAAALgAECggJCAAAAA==.',
['王率']='王率率:BAAALgAECgMJAwAAAA==.',
['环就']='环就是原:BAAALgAECgEJAQAAAA==.',
['珂雪']='珂雪:BAABLgAFFH8NAAIMAAUJsyV/AQApAgAMAAUJsyV/AQApAgAAAA==.',
['珠贝']='珠贝贝:BAAALgAECgcJCwAAAA==.',
['琥珀']='琥珀封印:BAAALgAECgMJAwAAAA==.',
['璇风']='璇风:BAAALgAECgEJAQABLgAFFAQJCQAgALkQAA==.',
['瓜皮']='瓜皮:BAAALgAECgIJBAAAAA==.',
['瓦一']='瓦一:BAAALgAFFAIJAwAAAA==.',
['甜也']='甜也迷人:BAACLgAFFH8QAAIPAAYJARNJAwCyAQAPAAYJARNJAwCyAQAuAAQKfx8AAg8ACQkeE08nABkCAA8ACQkeE08nABkCAAAA.',
['生死']='生死山河主:BAABLgAFFH8IAAMBAAQJgxLXCwCsAAABAAIJ9xLXCwCsAAACAAIJDxKcMwCrAAAAAA==.',
['生鱼']='生鱼安乐:BAAALgAECgcJDAAAAA==.',
['田渊']='田渊正浩:BAAALgAECgYJBwABLgAFFAMJBwAVAJEfAA==.',
['画沙']='画沙:BAAALgADCgcJBwAAAA==.',
['疾急']='疾急激击姬:BAAALgAECgUJBQAAAA==.',
['疾风']='疾风怒涛:BAAALgAECgcJEgAAAA==.',
['痛仰']='痛仰丶幺幺:BAAALgAECgQJBAAAAA==.痛仰丶永远:BAAALgAECgcJBwAAAA==.',
['白尘']='白尘羽:BAAALgAECgcJEgAAAA==.',
['白桃']='白桃汽水:BAAALgAFFAQJAQAAAA==.',
['皮棠']='皮棠:BAAALgADCgcJBwAAAA==.',
['盈盈']='盈盈笑语:BAAALgADCgQJBAAAAA==.',
['盐焗']='盐焗:BAAALgAECgIJAgAAAA==.',
['监汤']='监汤者丁眞:BAAALgAECgcJCQAAAA==.',
['盘怒']='盘怒:BAAALgAECgYJBgAAAA==.',
['看看']='看看你的秘密:BAAALgAECgUJDAAAAA==.',
['破甲']='破甲光环:BAAALgAECgIJAgAAAA==.',
['砻希']='砻希尔:BAAALgADCgIJAwAAAA==.',
['神龙']='神龙尊者:BAAALgAECgEJAQAAAA==.',
['秋水']='秋水:BAAALgADCgIJAgAAAA==.秋水揽星辰:BAAALgAECgIJAgAAAA==.',
['科尔']='科尔努诺丝:BAAALgAECgQJBAABLgAFFAQJBwAdABgHAA==.',
['移动']='移动集合石:BAAALgAFFAIJBAAAAA==.',
['穆拉']='穆拉丁全需:BAAALgAECgYJCQAAAA==.',
['究极']='究极社畜:BAAALgAECgEJAQAAAA==.',
['空空']='空空酱:BAAALgAFFAMJAwAAAA==.',
['章鱼']='章鱼蹦蹦:BAAALgAECgYJBwAAAA==.',
['笨蛋']='笨蛋美人:BAAALgAECgYJBwAAAA==.',
['米亚']='米亚亚米:BAAALgAFFAIJAwABLgAFFAQJEAAJAKkkAA==.',
['米兰']='米兰轩:BAAALgAECgEJAQAAAA==.',
['米多']='米多:BAAALgAECgUJDQAAAA==.',
['米奇']='米奇妙妙屋:BAAALgAECgEJAQAAAA==.',
['米奈']='米奈塔:BAAALgAECgQJBgAAAA==.',
['米拉']='米拉妮:BAAALgAECgcJBwAAAA==.',
['米米']='米米亚亚:BAABLgAFFH8QAAIJAAQJqSS5CACOAQAJAAQJqSS5CACOAQAAAA==.米米亚米:BAAALgADCgIJAgAAAA==.',
['糯布']='糯布那嘎:BAAALgAECgEJAQAAAA==.',
['素质']='素质小子:BAAALgAECgcJBQAAAA==.',
['红莲']='红莲魔尊:BAAALgAECgYJDAAAAA==.',
['纪倩']='纪倩倩:BAAALgAECgEJAwAAAA==.',
['终归']='终归遗憾:BAABLgAFFH8FAAIFAAQJmxUkEABgAQAFAAQJmxUkEABgAQAAAA==.',
['给个']='给个机会:BAAALgAFFAMJBAAAAA==.',
['绝无']='绝无意义:BAAALgAECgUJBgABLgAFFAMJBAAOAAAAAA==.',
['统御']='统御燃烧军团:BAACLgAFFH8LAAMCAAUJZRd4HQAOAQACAAMJlRd4HQAOAQABAAIJNhdeCgC2AAAuAAQKfx8ABAIACAliImUlAH0CAAIABwkDImUlAH0CAAEABQmTH+MSALQBAAgAAQkAANssAEUAAAAA.',
['维也']='维也纳丨忧伤:BAAALgAECgYJBgAAAA==.',
['缇塔']='缇塔妮娅裂魔:BAAALgAECgUJBgAAAA==.',
['网恋']='网恋大领主:BAAALgAFFAEJAQAAAA==.',
['罗星']='罗星:BAAALgAECgQJBQAAAA==.',
['罪防']='罪防无敌:BAAALgAECgYJBgAAAA==.',
['美味']='美味牛筋肠:BAAALgAECgYJDQAAAA==.',
['美式']='美式居合丶:BAAALgAFFAIJAwAAAA==.',
['羞涩']='羞涩的妮玛:BAAALgAECgEJAQAAAA==.',
['群友']='群友张顺飞:BAAALgAECgQJBAAAAA==.',
['羽翼']='羽翼飞扬:BAAALgAFFAIJAwAAAA==.',
['老大']='老大戒烟了:BAAALgAECgQJBwAAAA==.',
['老泰']='老泰:BAABLgAECn8UAAIbAAgJOhIbEwDYAQAbAAgJOhIbEwDYAQAAAA==.',
['老魔']='老魔:BAAALgAECgMJAwAAAA==.',
['肥丨']='肥丨大:BAAALgAFFAIJBAABLgAFFAYJDwAdAMIgAA==.',
['肥头']='肥头羊:BAABLgAFFH8PAAIUAAYJaxRTAwAHAgAUAAYJaxRTAwAHAgAAAA==.',
['肥牛']='肥牛仔:BAAALgADCgEJAQAAAA==.',
['胡碌']='胡碌碌:BAAALgAECgUJCQAAAA==.',
['胤炙']='胤炙:BAAALgADCgMJAwAAAA==.',
['脚滑']='脚滑的狗鸽:BAAALgAECgMJBAAAAA==.',
['脱缰']='脱缰灬疯豿:BAACLgAFFH8NAAIiAAQJbxsMCABsAQAiAAQJbxsMCABsAQAuAAQKfxwAAiIACAkWIGcPANgCACIACAkWIGcPANgCAAAA.脱缰疯芶:BAABLgAFFH8JAAIaAAQJdhVHBABcAQAaAAQJdhVHBABcAQAAAA==.脱缰疯豿灬:BAAALgAECgIJAgAAAA==.',
['自然']='自然之光:BAAALgAECgYJCgAAAA==.',
['自走']='自走树人:BAAALgADCgcJBwAAAA==.',
['舍羽']='舍羽:BAAALgAECgYJEQABLgAECgcJDQAOAAAAAA==.',
['艾斯']='艾斯卡锘:BAABLgAFFH8FAAIMAAUJVwm/BgCEAQAMAAUJVwm/BgCEAQAAAA==.',
['艾查']='艾查恩:BAAALgAECgYJBgAAAA==.',
['花开']='花开即美好:BAAALgAECgQJBAAAAA==.',
['花惢']='花惢和尚:BAAALgAECgEJAQAAAA==.',
['花祈']='花祈:BAAALgADCgUJBQAAAA==.',
['苍牙']='苍牙烈:BAABLgAECn8dAAIFAAgJ+hOpRgAgAgAFAAgJ+hOpRgAgAgAAAA==.',
['苍狼']='苍狼笑:BAABLgAECn8UAAIWAAgJchY/FAAvAgAWAAgJchY/FAAvAgAAAA==.',
['茄茄']='茄茄是晴天:BAAALgADCgcJBwAAAA==.',
['茱茱']='茱茱:BAAALgAECgEJAQAAAA==.',
['荡漾']='荡漾丨水波:BAAALgADCgYJBgABLgAECgkJGgAVALsUAA==.',
['莉尔']='莉尔塔颂歌:BAACLgAFFH8FAAIcAAQJYwmPCgBHAQAcAAQJYwmPCgBHAQAuAAQKfxYAAhwACAluFCYbACcCABwACAluFCYbACcCAAAA.',
['莎昔']='莎昔昔:BAAALgAECgkJCQABLgAFFAYJEgAKAG8iAA==.',
['莱瑞']='莱瑞拉:BAAALgAFFAEJAQAAAA==.',
['莱穆']='莱穆妮之光:BAAALgADCgcJDQAAAA==.',
['菊花']='菊花撕裂者:BAAALgADCgMJAwAAAA==.',
['萌芽']='萌芽熊:BAAALgAECgEJAQAAAA==.',
['萨拉']='萨拉斯:BAAALgAECgQJBAAAAA==.',
['萨格']='萨格辣斯:BAAALgAECgEJAQAAAA==.',
['蓝猫']='蓝猫警长:BAAALgADCgEJAQAAAA==.',
['蓝羽']='蓝羽浅葱丶:BAAALgADCgMJAwAAAA==.',
['薯鼠']='薯鼠泥:BAACLgAFFH8LAAIaAAQJfSAEAQCfAQAaAAQJfSAEAQCfAQAuAAQKfyIAAhoACQnMJJEBAI0DABoACQnMJJEBAI0DAAAA.',
['虎虎']='虎虎:BAABLgAECn8ZAAMaAAgJOBerDAClAQAaAAgJOBerDAClAQAJAAYJmAx0SgAoAQAAAA==.',
['虚无']='虚无不萌:BAAALgAECgYJEAAAAA==.',
['虹林']='虹林檎:BAAALgAECgYJCwAAAA==.',
['蚕豆']='蚕豆:BAAALgAECgMJAwAAAA==.',
['蛇王']='蛇王:BAAALgAECgEJAQAAAA==.',
['蝶舞']='蝶舞丶:BAABLgAFFH8FAAIDAAUJtRKeCwDAAQADAAUJtRKeCwDAAQAAAA==.',
['表面']='表面欧皇:BAAALgAECgUJBQAAAA==.',
['袖手']='袖手天下:BAAALgAECgEJAQABLgAFFAcJEAALAHgaAA==.',
['被遗']='被遗忘者:BAAALgAECgYJCQAAAA==.',
['西瓜']='西瓜小小术:BAEBLgAFFH8FAAICAAMJDiZREwBOAQACAAMJDiZREwBOAQAAAA==.西瓜小小龙:BAEALgAECgYJBgABLgAFFAMJBQACAA4mAA==.',
['西野']='西野小轩:BAAALgADCgYJBgAAAA==.',
['要要']='要要乐奈奈:BAAALgADCgEJAgAAAA==.',
['让我']='让我想一下:BAACLgAFFH8TAAIbAAUJmBikAgB/AQAbAAUJmBikAgB/AQAuAAQKfxcAAhsACAnGIWgHALECABsACAnGIWgHALECAAAA.',
['试探']='试探晚安:BAACLgAFFH8GAAICAAMJtBfYHAARAQACAAMJtBfYHAARAQAuAAQKfxUAAwEACAkHIEgXAJABAAIABgnPHJBJAO0BAAEABAn9IkgXAJABAAEuAAUUBAkFAAUAmxUA.',
['调皮']='调皮的开心果:BAAALgAECgEJAQAAAA==.',
['谎言']='谎言如此动听:BAACLgAFFH8WAAIbAAYJAw7nAQCwAQAbAAYJAw7nAQCwAQAuAAQKfxkAAhsACAlvFf8SANoBABsACAlvFf8SANoBAAAA.',
['豆教']='豆教军:BAAALgAECgYJCgAAAA==.',
['豆馅']='豆馅炸糕:BAAALgADCgUJBQAAAA==.',
['贼心']='贼心丶不死:BAAALgADCgYJBgAAAA==.',
['赫卡']='赫卡特丶:BAACLgAFFH8ZAAMaAAcJKiMmAAC6AQAJAAcJWyKOAADhAgAaAAUJcyMmAAC6AQAuAAQKfyYAAwkACQmyJboBAKUDAAkACQkkJLoBAKUDABoAAwluJQAAAAAAAAAA.',
['赵四']='赵四哥:BAAALgAECgEJAQAAAA==.',
['超六']='超六:BAAALgAECgEJAQAAAA==.',
['超级']='超级暴龙战神:BAAALgAECgQJBQAAAA==.',
['跳高']='跳高高手:BAAALgAFFAEJAgAAAA==.',
['躺尸']='躺尸三摆手:BAAALgADCgcJBwAAAA==.',
['转不']='转不了火:BAAALgAFFAQJBAAAAA==.转不动火:BAAALgAFFAUJAQAAAA==.',
['轻浮']='轻浮:BAAALgAECgUJBQAAAA==.',
['轻舞']='轻舞飞魂:BAAALgAFFAIJAwAAAA==.',
['辛希']='辛希娅:BAAALgADCgUJBQABLgAFFAEJAQAOAAAAAA==.',
['辻灬']='辻灬弎:BAAALgAECgEJAQAAAA==.',
['还是']='还是:BAABLgAFFH8JAAILAAMJqiVICgBOAQALAAMJqiVICgBOAQAAAA==.',
['还能']='还能再砍砍:BAAALgAFFAEJAQAAAA==.',
['这是']='这是化劲儿:BAAALgAECgUJBQAAAA==.',
['这样']='这样那样哪样:BAAALgADCgYJBgAAAA==.',
['远坂']='远坂灬樱:BAAALgAECgEJAQAAAA==.',
['迪曦']='迪曦焰卡:BAAALgAECgMJAwAAAA==.',
['迪迪']='迪迪马库斯:BAAALgAECgMJAwAAAA==.',
['迷行']='迷行:BAABLgAFFH8HAAIFAAIJcCBdNwCsAAAFAAIJcCBdNwCsAAAAAA==.',
['逆风']='逆风如解意:BAAALgAECgQJBgAAAA==.',
['邓布']='邓布里多:BAAALgADCgEJAQAAAA==.',
['那谁']='那谁:BAAALgADCgYJDQAAAA==.',
['那路']='那路托:BAAALgAECgcJBQAAAA==.',
['邪老']='邪老三:BAACLgAFFH8FAAIUAAMJyRwBGAAQAQAUAAMJyRwBGAAQAQAuAAQKfx8AAhQACAnpHLU3ABYCABQACAnpHLU3ABYCAAAA.',
['邪能']='邪能大领主:BAAALgAECgcJDgAAAA==.',
['都是']='都是浮云:BAAALgAECgEJAQAAAA==.',
['酒肆']='酒肆三觉:BAAALgAECgcJDQAAAA==.',
['酒酿']='酒酿:BAAALgAECgIJAgAAAA==.',
['酒醉']='酒醉梦醒:BAABLgAECn8bAAMKAAkJVRvzDQCrAgAKAAkJVRvzDQCrAgAjAAQJNiD1FABsAQAAAA==.',
['醉萧']='醉萧瑟:BAACLgAFFH8GAAICAAMJbSTDFABGAQACAAMJbSTDFABGAQAuAAQKfycAAwIACAnnJTUOAAgDAAIABwmZJjUOAAgDAAEABAnyH6ooACABAAAA.',
['醉轻']='醉轻风:BAAALgADCgEJAQAAAA==.',
['里榭']='里榭娜:BAACLgAFFH8HAAMdAAQJGAezDADgAAAdAAMJVwmzDADgAAAYAAEJYACNHAA2AAAuAAQKfxsAAx0ACAnrFWQWADQCAB0ACAnrFWQWADQCABgAAQlfCntXADIAAAAA.',
['重生']='重生之大宗师:BAAALgAECgcJEwAAAA==.',
['野人']='野人:BAAALgAECgMJAwAAAA==.',
['野源']='野源:BAABLgAFFH8FAAIFAAIJaRVqRACaAAAFAAIJaRVqRACaAAAAAA==.',
['野狗']='野狗啊野狗:BAAALgADCgIJAgAAAA==.',
['銀色']='銀色闪光:BAAALgADCgEJAQAAAA==.',
['铁木']='铁木男:BAAALgAECgIJAgAAAA==.',
['铃珠']='铃珠猎人:BAAALgAECgEJAQAAAA==.',
['铭月']='铭月紫兰:BAAALgAECgYJDAAAAA==.',
['長河']='長河集团:BAAALgAECgcJCAAAAA==.',
['长城']='长城上的卫士:BAAALgADCgEJAgAAAA==.',
['长崎']='长崎爽世:BAAALgAFFAMJBAAAAA==.',
['闪了']='闪了腰的敌法:BAAALgAECgMJAwAAAA==.',
['防火']='防火墙龙:BAAALgAECgYJCgABLgAECgYJCgAOAAAAAA==.',
['阿书']='阿书:BAAALgAECgQJBAAAAA==.',
['阿塞']='阿塞妹:BAAALgAECgEJAQAAAA==.',
['阿巴']='阿巴顿:BAAALgAECgIJAgAAAA==.',
['阿拉']='阿拉那一卡:BAAALgAECgYJBgAAAA==.',
['阿雕']='阿雕:BAAALgAECgUJBQAAAA==.',
['陈丶']='陈丶怒风:BAAALgADCgYJCQAAAA==.',
['雨下']='雨下一整晚:BAAALgADCgYJBwAAAA==.',
['雨雨']='雨雨居柒:BAAALgAFFAUJAgABLgAFFAgJAgAOAAAAAA==.',
['雪碧']='雪碧不要冰:BAAALgAECgMJBAAAAA==.',
['霎时']='霎时花落:BAAALgAECgEJAQAAAA==.',
['霜冻']='霜冻之蓝:BAAALgAFFAEJAgAAAA==.',
['霸王']='霸王龙扎克:BAAALgAECgkJEAAAAA==.',
['面包']='面包虚无:BAAALgADCgMJAwAAAA==.',
['音弦']='音弦华奏:BAAALgAECgEJAgAAAA==.',
['风在']='风在云颠:BAABLgAECn8UAAIgAAcJMyJuEQCZAgAgAAcJMyJuEQCZAgAAAA==.',
['风暴']='风暴烈酒丿:BAAALgAECgUJBgAAAA==.',
['风鬟']='风鬟雾鬓:BAAALgAECgYJEAAAAA==.',
['飘零']='飘零若久:BAAALgAFFAMJAwAAAA==.',
['饿了']='饿了吗:BAAALgAFFAIJAgAAAA==.',
['香克']='香克斯带点莽:BAAALgAECgMJBAAAAA==.',
['马库']='马库拉格之耀:BAAALgAECgEJAQAAAA==.',
['骄横']='骄横三击:BAAALgAECgIJAwAAAA==.',
['魔法']='魔法宝贝:BAAALgAECgQJBQAAAA==.',
['鹿城']='鹿城第一深情:BAAALgAECgkJEAAAAA==.',
['鹿角']='鹿角天然卷:BAABLgAFFH8IAAISAAMJCiJ/CwAnAQASAAMJCiJ/CwAnAQAAAA==.鹿角湾:BAAALgAECgcJCgAAAA==.',
['麒谕']='麒谕历险记:BAAALgAECgMJAwAAAA==.',
['麻辣']='麻辣兔兔:BAAALgAECgYJDwAAAA==.',
['黄油']='黄油鸡蛋卷:BAACLgAFFH8IAAIDAAIJ0SRWFQDeAAADAAIJ0SRWFQDeAAAuAAQKfxQAAgMABwngHaJQAEUCAAMABwngHaJQAEUCAAAA.',
['黑小']='黑小姐:BAAALgADCgcJBwAAAA==.',
['龙之']='龙之守望:BAAALgAECgUJBQAAAA==.',
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
