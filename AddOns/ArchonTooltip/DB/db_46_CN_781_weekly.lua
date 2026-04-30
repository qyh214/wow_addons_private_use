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

local lookup = {'DemonHunter-Havoc','Paladin-Holy','Paladin-Retribution','DemonHunter-Devourer','Priest-Shadow','DeathKnight-Unholy','Evoker-Augmentation','Evoker-Preservation','Warlock-Demonology','Mage-Frost','Warlock-Destruction','Priest-Discipline','Monk-Mistweaver','Monk-Brewmaster','Unknown-Unknown','Rogue-Subtlety','Warrior-Fury','Shaman-Restoration','Druid-Restoration','DeathKnight-Blood','Warlock-Affliction','Paladin-Protection','Warrior-Arms','Priest-Holy','Hunter-BeastMastery','Druid-Balance','Monk-Windwalker','Evoker-Devastation','DemonHunter-Vengeance','Hunter-Marksmanship','Mage-Arcane','Mage-Fire','Shaman-Elemental','Warrior-Protection','Shaman-Enhancement','Druid-Feral','Hunter-Survival',}
local provider = {region='CN',realm='米奈希尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aafu:BAAALgADCgYJBgAAAA==.',
Af='Afufua:BAAALgAFFAIJAgAAAA==.',
Ai='Ainy:BAAALgADCgEJAQAAAA==.',
Am='Amyl:BAAALgAFFAEJAgAAAA==.',
An='Ananas:BAABLgAFFH8JAAIBAAMJtCCEBAApAQABAAMJtCCEBAApAQAAAA==.',
Be='Bellingham:BAAALgAECgcJBwAAAA==.',
Bu='Bunny:BAACLgAFFH8FAAMCAAIJlB8pEgC7AAACAAIJlB8pEgC7AAADAAEJzQUXOABIAAAuAAQKfyMAAwIABwkwIiMRAIoCAAIABwkwIiMRAIoCAAMAAwknE+PvALEAAAAA.',
Ca='Cartethyia:BAAALgAECgYJBgAAAA==.',
Ch='Chaoticmuchh:BAABLgAFFH8JAAIEAAMJnR2LFgAdAQAEAAMJnR2LFgAdAQAAAA==.Cheney:BAACLgAFFH8QAAIFAAQJGiGWBACQAQAFAAQJGiGWBACQAQAuAAQKfyAAAgUACAnsJFkEAFEDAAUACAnsJFkEAFEDAAAA.',
Co='Coisini:BAAALgAECgkJCQAAAA==.',
Cr='Crystallize:BAAALgAFFAEJAQAAAA==.',
Dk='Dk:BAABLgAFFH8GAAIGAAMJDCESHgAoAQAGAAMJDCESHgAoAQAAAA==.',
Do='Doragon:BAACLgAFFH8MAAMHAAQJpA8LDAA8AQAHAAQJpA8LDAA8AQAIAAEJcwc3DQBCAAAuAAQKfyAAAwcACAlrH4UBAJACAAcACAlrH4UBAJACAAgABwm5C3QgAHkBAAAA.Doubleama:BAAALgAECgUJCQAAAA==.',
Dr='Driedmango:BAAALgAECgYJDQAAAA==.',
Du='Durandal:BAAALgAECgkJCgAAAA==.',
El='Eldridge:BAAALgAFFAIJAQAAAA==.',
En='Encici:BAECLgAFFH8QAAIEAAUJ4RixCACcAQAEAAUJ4RixCACcAQAuAAQKfx4AAgQACQnOIDMOAA0DAAQACQnOIDMOAA0DAAAA.',
Eo='Eow:BAABLgAFFH8HAAIJAAQJUAxAFQBDAQAJAAQJUAxAFQBDAQAAAA==.',
Er='Eren:BAAALgAECgYJBwAAAA==.',
Fi='Fiercat:BAAALgAECgUJAwAAAA==.Firedog:BAAALgADCgEJAQAAAA==.',
He='Hennessy:BAAALgAECgEJAQAAAA==.',
In='Initial:BAAALgADCgEJAQAAAA==.',
Ip='Ipxwarlock:BAABLgAFFH8FAAIJAAQJ6Qy1CgA9AQAJAAQJ6Qy1CgA9AQAAAA==.',
Is='Isaac:BAAALgAECgYJBwAAAA==.',
Ja='Jagcrowe:BAAALgAECgkJAwAAAA==.',
Ka='Kaltsit:BAAALgADCgIJAgAAAA==.Kaneria:BAAALgAECgEJAQAAAA==.Kawhileonard:BAAALgAECgQJBAAAAA==.Kayle:BAABLgAFFH8FAAIDAAIJRhnGHQC2AAADAAIJRhnGHQC2AAABLgAFFAQJDAAKAFIYAA==.',
La='Laoa:BAAALgAFFAIJAgAAAA==.',
Li='Lindh:BAAALgAECgUJBQAAAA==.Linevoker:BAAALgAECgQJBAAAAA==.Linshaman:BAAALgAFFAIJAgAAAA==.Linwarlock:BAACLgAFFH8LAAIJAAUJBCRvBAB2AQAJAAUJBCRvBAB2AQAuAAQKfxQAAwkACAnpJG0gAJYCAAkACAnpJG0gAJYCAAsAAwlPDOc/ALUAAAAA.',
Lj='Ljcxxy:BAACLgAFFH8GAAIFAAMJFxP6BQD6AAAFAAMJFxP6BQD6AAAuAAQKfxUAAgUABwk6H5QRAHECAAUABwk6H5QRAHECAAAA.',
Lo='Louise:BAAALgAECgEJAgAAAA==.',
Ma='Marchsecond:BAAALgAFFAIJAgAAAA==.',
Me='Melina:BAAALgAECgYJDAAAAA==.',
Mi='Misaki:BAAALgAFFAIJAwABLgAFFAYJCgAMABIPAA==.Misakii:BAACLgAFFH8JAAINAAUJ0huiAgDlAQANAAUJ0huiAgDlAQAuAAQKfxYAAg0ACQmTJPUAAKgDAA0ACQmTJPUAAKgDAAEuAAUUBgkKAAwAEg8A.Misamisa:BAAALgADCgMJAwAAAA==.',
Na='Nanakagura:BAAALgAFFAEJAQABLgAFFAUJFAAOAFslAA==.',
No='Novokiss:BAAALgAECgkJDwABLgAFFAUJAgAPAAAAAA==.Novoyoona:BAAALgAECgkJCgABLgAFFAQJAQAPAAAAAA==.',
Ny='Nyankosensei:BAABLgAFFH8FAAIQAAIJpBfOEQC7AAAQAAIJpBfOEQC7AAAAAA==.',
Ph='Photographer:BAAALgAECgYJEAAAAA==.Phrolova:BAABLgAFFH8FAAIFAAMJ7CE0CQAsAQAFAAMJ7CE0CQAsAQAAAA==.',
Ro='Ronronner:BAACLgAFFH8LAAIRAAQJmQ7NAwBNAQARAAQJmQ7NAwBNAQAuAAQKfyUAAhEACAlsHrkTALECABEACAlsHrkTALECAAAA.Roueight:BAAALgAECgQJBAAAAA==.Rouone:BAABLgAFFH8IAAIFAAQJBSG8BACLAQAFAAQJBSG8BACLAQAAAA==.Rousix:BAAALgAFFAMJAwAAAA==.Routwo:BAAALgAFFAIJAgAAAA==.Royce:BAAALgAECgIJAgAAAA==.',
Ru='Russo:BAACLgAFFH8RAAIRAAQJeyVWAACwAQARAAQJeyVWAACwAQAuAAQKfxwAAhEACAnqI6wPANUCABEACAnqI6wPANUCAAAA.',
Sh='Shoei:BAAALgADCgMJAwAAAA==.',
Sl='Slq:BAAALgADCgEJAQAAAA==.',
St='Stark:BAAALgAECgQJBwAAAA==.',
Su='Summer:BAAALgAECgcJBgAAAA==.',
Th='Thor:BAAALgAECgMJAQABLgAFFAQJBAAPAAAAAA==.Threesocks:BAAALgAFFAEJAQABLgAFFAIJBAAPAAAAAA==.Thunder:BAAALgADCgEJAQAAAA==.',
Wi='Winterfell:BAACLgAFFH8LAAIGAAQJhyFGCgB/AQAGAAQJhyFGCgB/AQAuAAQKfx0AAgYACAmpI04PACIDAAYACAmpI04PACIDAAAA.',
Xd='Xdh:BAABLgAFFH8FAAIEAAIJdBETKAChAAAEAAIJdBETKAChAAABLgAFFAYJCgAMABIPAA==.Xdr:BAABLgAFFH8JAAMHAAUJDg2yCwDrAAAHAAMJpQuyCwDrAAAIAAMJvR5DCADBAAABLgAFFAYJCgAMABIPAA==.',
Xm='Xms:BAAALgAFFAEJAQABLgAFFAYJCgAMABIPAA==.',
Xs='Xsm:BAABLgAECn8UAAISAAkJuSPPAAChAwASAAkJuSPPAAChAwABLgAFFAYJCgAMABIPAA==.',
Xx='Xxd:BAABLgAFFH8MAAITAAUJ9BxnAQDSAQATAAUJ9BxnAQDSAQABLgAFFAYJCgAMABIPAA==.',
Yi='Yimi:BAAALgAECgUJBgAAAA==.Yimimi:BAAALgAECgYJCwAAAA==.',
Yo='Yone:BAAALgAECgcJBgABLgAFFAQJBAAPAAAAAA==.',
Yz='Yzzkl:BAAALgAECgYJCQAAAA==.',
['一七']='一七扳你:BAACLgAFFH8OAAIKAAYJhhhEAwBFAgAKAAYJhhhEAwBFAgAuAAQKfxUAAgoACQmeGjkrAMYCAAoACQmeGjkrAMYCAAAA.一七扳晕你:BAACLgAFFH8IAAIKAAQJrxy3EgCCAQAKAAQJrxy3EgCCAQAuAAQKfxcAAgoACQmJIUUIAIYDAAoACQmJIUUIAIYDAAAA.',
['一劍']='一劍你就想笑:BAAALgAECgkJEQAAAA==.',
['一狙']='一狙两德:BAAALgADCgUJCgABLgAECgkJCgAPAAAAAA==.',
['一笑']='一笑兮夜:BAAALgAECgcJBwAAAA==.',
['一颗']='一颗小逗逗:BAAALgAECgQJBAAAAA==.',
['七夜']='七夜灬:BAAALgAECgcJBwAAAA==.',
['七枼']='七枼灬:BAAALgAECggJBwAAAA==.',
['七葉']='七葉灬:BAAALgAECgMJAwAAAA==.',
['万岁']='万岁成纯:BAAALgAFFAIJAgAAAA==.',
['万物']='万物皆虚:BAAALgADCgYJBgAAAA==.',
['万象']='万象澄澈:BAAALgAECgkJDwAAAA==.',
['上月']='上月朱:BAAALgAECgYJDwAAAA==.',
['下午']='下午茶與貓:BAAALgADCgYJBgAAAA==.',
['下次']='下次一定:BAAALgAECggJCwAAAA==.下次我请丶:BAAALgAECggJBwAAAA==.',
['不動']='不動明王:BAAALgAECgYJCQAAAA==.',
['不咕']='不咕:BAAALgAECgEJAQAAAA==.',
['不忙']='不忙哆不慌哆:BAAALgAECgcJDQAAAA==.',
['不讲']='不讲武德:BAABLgAECn8UAAIOAAkJrh4KAQC3AgAOAAkJrh4KAQC3AgAAAA==.',
['不鸭']='不鸭:BAACLgAFFH8VAAIKAAUJqCKEBgD3AQAKAAUJqCKEBgD3AQAuAAQKfxwAAgoACQkFJogNAFkDAAoACQkFJogNAFkDAAAA.',
['世界']='世界称我為王:BAABLgAFFH8FAAIJAAIJYBSaHQCxAAAJAAIJYBSaHQCxAAAAAA==.',
['业火']='业火映东水:BAAALgADCgcJBAAAAA==.',
['东那']='东那个咚:BAABLgAFFH8GAAIGAAIJxBnWNQCxAAAGAAIJxBnWNQCxAAAAAA==.',
['丧黑']='丧黑福造:BAAALgAECgEJAQAAAA==.',
['丨卡']='丨卡提希娅丨:BAAALgAECgcJBwAAAA==.',
['丨赞']='丨赞美太阳:BAAALgAFFAEJAgAAAA==.',
['丫丫']='丫丫:BAAALgADCgUJBQAAAA==.',
['丶小']='丶小牧:BAACLgAFFH8KAAIMAAYJEg/8AgDaAQAMAAYJEg/8AgDaAQAuAAQKfxYAAwUACQlnFzATAFwCAAUACAl7FTATAFwCAAwABgmmG+MYANQBAAAA.',
['丶眸']='丶眸眸:BAAALgAECgYJDQAAAA==.',
['丷烈']='丷烈风劲啸丷:BAAALgAECgYJCQAAAA==.',
['乌卡']='乌卡卡丶:BAAALgADCgEJAQAAAA==.',
['九神']='九神:BAAALgAFFAEJAQAAAA==.',
['二十']='二十倍界王拳:BAAALgADCgUJBQAAAA==.',
['于饵']='于饵:BAAALgAECgEJAQAAAA==.',
['云晴']='云晴魂:BAAALgAECgYJCAAAAA==.',
['云曦']='云曦:BAAALgAECgcJBwAAAA==.',
['云涌']='云涌风飞:BAAALgAECgYJBgAAAA==.',
['云过']='云过云果:BAAALgADCgEJAQAAAA==.',
['五岳']='五岳倒为轻:BAACLgAFFH8JAAMJAAQJlxJNHwAGAQAJAAMJRxhNHwAGAQALAAEJiQEBGwBAAAAuAAQKfxwAAwkACAlXGx42ADMCAAkABwlXGx42ADMCAAsAAglLDpFNAIUAAAAA.',
['五月']='五月落夏:BAAALgAECgMJBAAAAA==.',
['五条']='五条奶龙:BAAALgAECgYJDAAAAA==.',
['交洋']='交洋:BAAALgAECgYJCAAAAA==.',
['亮晶']='亮晶晶:BAAALgAECgMJAwAAAA==.',
['人生']='人生若初见:BAAALgAFFAEJAQAAAA==.',
['人间']='人间值得:BAAALgAECgcJEgAAAA==.',
['以延']='以延为定:BAABLgAFFH8PAAIGAAQJwSIuAgCVAQAGAAQJwSIuAgCVAQAAAA==.',
['伊藤']='伊藤诚丶:BAAALgAECgYJCgAAAA==.',
['优雅']='优雅颓废丶:BAAALgADCgQJBAAAAA==.',
['会变']='会变熊的哥:BAAALgAECgIJAwAAAA==.',
['伤心']='伤心鱼头:BAAALgAFFAEJAQAAAA==.',
['何事']='何事六:BAABLgAECn8XAAMGAAkJYyLSBQBFAgAGAAkJYyLSBQBFAgAUAAcJYxHRHABkAQABLgAFFAQJBgAGAL0YAA==.',
['佬炉']='佬炉筋烨蔫绸:BAABLgAFFH8HAAIEAAQJdhMsEQBFAQAEAAQJdhMsEQBFAQAAAA==.',
['偏偏']='偏偏喜欢你:BAAALgAECgEJAQAAAA==.',
['健胃']='健胃消食片:BAAALgAFFAQJAgAAAA==.',
['傻耕']='傻耕耕:BAABLgAFFH8NAAIKAAUJvw7aDQCsAQAKAAUJvw7aDQCsAQAAAA==.',
['八尺']='八尺鸦:BAAALgADCgUJBQAAAA==.',
['八蛟']='八蛟龙:BAAALgADCgMJBAAAAA==.',
['六里']='六里桥:BAAALgAFFAEJAQAAAA==.',
['冬至']='冬至:BAAALgADCgMJAwAAAA==.',
['冰葉']='冰葉芷若:BAAALgAECgYJCwAAAA==.',
['冻住']='冻住敌方治疗:BAAALgAECgYJAgAAAA==.',
['几星']='几星霜:BAABLgAFFH8GAAMJAAUJBBuiBAB0AQAJAAQJBBuiBAB0AQAVAAEJAADyAgAAAAAAAA==.',
['刀锋']='刀锋灬意志:BAAALgAECgEJAQAAAA==.',
['刃丶']='刃丶舞:BAAALgAECgYJAgAAAA==.',
['刘亦']='刘亦菲十八岁:BAAALgAECgEJAQAAAA==.',
['剑心']='剑心:BAAALgAFFAIJAwAAAA==.',
['勇敢']='勇敢牛哥:BAAALgAECgUJBQAAAA==.',
['北落']='北落星星:BAACLgAFFH8GAAICAAMJFRs2BwAFAQACAAMJFRs2BwAFAQAuAAQKfxoABAMACAkTHqs1AEwCAAMABwnFHqs1AEwCAAIAAgnLE+F7AIkAABYAAQl4AR1PABQAAAAA.北落辰星:BAAALgAECgYJBgABLgAFFAMJBgACABUbAA==.',
['十点']='十点准时睡觉:BAAALgADCgQJBAAAAA==.',
['千石']='千石抚子:BAABLgAFFH8GAAIKAAQJ6g2fHwBJAQAKAAQJ6g2fHwBJAQAAAA==.',
['千羽']='千羽:BAAALgAECgEJAQAAAA==.',
['千里']='千里之外:BAAALgADCgcJBwAAAA==.',
['华为']='华为:BAACLgAFFH8PAAMRAAQJ0hn5BwBtAQARAAQJ0hn5BwBtAQAXAAEJCBIXBwBcAAAuAAQKfygAAxcACAnAHgwDALoBABEABwlvHqgYAIYCABcABwloHAwDALoBAAAA.',
['卡布']='卡布佳:BAAALgAECgQJBAAAAA==.',
['反摊']='反摊局一把手:BAAALgAFFAIJAgAAAA==.',
['发如']='发如雪:BAAALgAECgQJBAAAAA==.',
['变形']='变形琻刚:BAAALgAECgIJAgAAAA==.',
['变身']='变身飞入大圈:BAAALgAECgEJAwAAAA==.',
['口曷']='口曷三酉:BAAALgADCgMJAwAAAA==.口曷氵酉:BAAALgADCgEJAQAAAA==.',
['只吃']='只吃肉不喝酒:BAAALgAECgYJBgABLgAFFAQJBAAPAAAAAA==.',
['史莱']='史莱拇:BAAALgAECgEJAgAAAA==.',
['叶一']='叶一一:BAAALgAECgYJCAAAAA==.',
['叶小']='叶小法:BAAALgAECgYJBgAAAA==.',
['司幼']='司幼幽:BAAALgAECgkJCwAAAA==.',
['吉瓜']='吉瓜子:BAAALgADCgUJEAAAAA==.',
['呲呲']='呲呲:BAAALgAECgcJBwAAAA==.',
['咖喱']='咖喱牛肉粥:BAAALgAFFAIJAQAAAA==.',
['哈利']='哈利波波:BAAALgAECgMJAwAAAA==.',
['哈鲁']='哈鲁:BAAALgAECgcJDQAAAA==.',
['哎丫']='哎丫丫:BAAALgAECgcJCwAAAA==.',
['哎呦']='哎呦不错:BAAALgAECgQJBwAAAA==.',
['哦应']='哦应:BAAALgAFFAEJAQAAAA==.',
['哪里']='哪里有红豆泥:BAAALgAFFAEJAQAAAA==.',
['唉呀']='唉呀呀:BAAALgAECgcJBwAAAA==.',
['嘟嘟']='嘟嘟可大魔王:BAAALgAECgUJBQABLgAECgcJBwAPAAAAAA==.',
['嘟小']='嘟小猎:BAAALgAECgcJBwAAAA==.',
['团长']='团长的小姨子:BAAALgAECgYJAwAAAA==.',
['圆卟']='圆卟隆咚:BAAALgAECgMJBAAAAA==.',
['土耳']='土耳其海峡:BAAALgAECgUJBQAAAA==.',
['圣迟']='圣迟迟:BAAALgAECgYJCwAAAA==.',
['地狱']='地狱颤抖:BAAALgAECgMJAwAAAA==.',
['塔烙']='塔烙沙紗:BAAALgADCgcJBwAAAA==.',
['塞拉']='塞拉赞恩雯希:BAAALgAFFAIJAgAAAA==.',
['复仇']='复仇洋洋:BAABLgAECn8YAAMFAAYJsiCaBQDTAQAFAAYJsiCaBQDTAQAYAAEJPAqpfQA1AAAAAA==.',
['夜幕']='夜幕下的圣光:BAAALgAECgEJAQAAAA==.',
['夜游']='夜游的鱼:BAAALgAECgIJAgABLgAFFAUJEAACAG0XAA==.',
['夢回']='夢回二零零九:BAAALgADCgMJAwABLgAFFAUJEAACAG0XAA==.',
['大侦']='大侦探皮卡丘:BAAALgAECgMJAwAAAA==.',
['大哀']='大哀姆:BAAALgAECgYJAgAAAA==.',
['大地']='大地之灵:BAAALgAECgQJCwAAAA==.',
['大灬']='大灬树:BAABLgAFFH8FAAIDAAIJBBD9JACiAAADAAIJBBD9JACiAAAAAA==.',
['大胖']='大胖丶:BAAALgADCgEJAQAAAA==.',
['大雾']='大雾:BAAALgAECgEJAQAAAA==.',
['天使']='天使病号:BAAALgAFFAMJAwABLgAFFAQJDAAZAAgYAA==.',
['天才']='天才帅千万:BAACLgAFFH8LAAIOAAQJVhkoCQBCAQAOAAQJVhkoCQBCAQAuAAQKfx4AAg4ACAnsH10MAMkCAA4ACAnsH10MAMkCAAAA.',
['天真']='天真的云:BAAALgAFFAQJBAABLgAFFAYJCAAHAAkTAA==.',
['天青']='天青色等烟雨:BAABLgAFFH8KAAIGAAUJKhZgDgBoAQAGAAUJKhZgDgBoAQAAAA==.',
['奈茶']='奈茶的雪:BAAALgADCgQJBAAAAA==.',
['奔跑']='奔跑的乌龟:BAAALgAECgQJBwAAAA==.',
['奥利']='奥利波斯德:BAABLgAECn8ZAAIaAAcJfxrQGgAtAgAaAAcJfxrQGgAtAgAAAA==.',
['奥米']='奥米茄:BAAALgAFFAIJAwAAAA==.',
['奥蕾']='奥蕾莉亜雯希:BAAALgAECggJBgAAAA==.',
['她说']='她说:BAAALgAECgcJCAABLgAFFAQJBAAPAAAAAA==.',
['妖姬']='妖姬妹妹:BAAALgAECgEJAQAAAA==.',
['妞灬']='妞灬萬亽敬仰:BAAALgAECgQJBAAAAA==.',
['子时']='子时雪:BAAALgAFFAEJAgAAAA==.',
['孑弦']='孑弦:BAAALgAFFAIJAgAAAA==.',
['寂寞']='寂寞小野蛮:BAAALgAECgEJAgAAAA==.',
['射的']='射的艺术:BAAALgAECgYJDgAAAA==.',
['小丶']='小丶单车:BAACLgAFFH8OAAIUAAYJcxAXBgA3AQAUAAYJcxAXBgA3AQAuAAQKfx8AAxQACQmWGswNADECABQACQnYE8wNADECAAYABAlhG4ezABsBAAAA.',
['小小']='小小妖:BAAALgAECgMJAwAAAA==.',
['小崔']='小崔:BAAALgADCgQJAQAAAA==.',
['小浮']='小浮力:BAAALgAECgEJAQAAAA==.',
['小灵']='小灵仙儿:BAABLgAECn8UAAIDAAcJxxgcTQD7AQADAAcJxxgcTQD7AQAAAA==.',
['小瑞']='小瑞瑞:BAAALgAFFAEJAgAAAA==.',
['小白']='小白兔:BAABLgAECn8bAAIWAAcJCiarAACXAgAWAAcJCiarAACXAgAAAA==.',
['小群']='小群群:BAAALgAFFAEJAQAAAA==.',
['小落']='小落:BAABLgAECn8bAAIbAAgJXSbcAQCLAwAbAAgJXSbcAQCLAwAAAA==.',
['小鑫']='小鑫鑫无敌:BAAALgAECgQJBAAAAA==.',
['小飞']='小飞俠:BAAALgAECgMJBQAAAA==.',
['小鬼']='小鬼画符:BAAALgAECgEJAQAAAA==.',
['小龙']='小龙银儿:BAABLgAFFH8FAAIHAAMJoQ5fEgDsAAAHAAMJoQ5fEgDsAAABLgAFFAQJBwAEAHYTAA==.',
['尐样']='尐样児丶:BAAALgAECgYJCAAAAA==.',
['就很']='就很缺德:BAAALgAECgMJBAAAAA==.',
['就爱']='就爱吃甜的:BAABLgAECn8YAAMcAAYJKB0yEADZAQAcAAYJWBsyEADZAQAHAAYJFxoUIwClAQAAAA==.',
['尾巴']='尾巴翘翘:BAAALgAECgEJAQAAAA==.',
['岚之']='岚之山:BAAALgAECgkJEwAAAA==.',
['巫喵']='巫喵王:BAACLgAFFH8GAAIGAAIJ3hiyNwCsAAAGAAIJ3hiyNwCsAAAuAAQKfxQAAgYACAn0Gy0tAIQCAAYACAn0Gy0tAIQCAAAA.',
['巴耶']='巴耶力:BAAALgAFFAEJAQABLgAFFAQJBwAdACoRAA==.',
['布吉']='布吉岛:BAABLgAECn8aAAIDAAkJyyC4AQDTAgADAAkJyyC4AQDTAgABLgAFFAQJBAAPAAAAAA==.',
['布鲁']='布鲁伊:BAAALgAECgEJAQAAAA==.',
['帅鸡']='帅鸡:BAAALgAECgcJBwAAAA==.',
['希筱']='希筱:BAAALgAECgcJBwAAAA==.',
['希绪']='希绪弗斯:BAAALgAECgQJBAAAAA==.',
['帕拉']='帕拉丁真:BAAALgAECgMJAwAAAA==.',
['平昌']='平昌喵:BAAALgAECgQJBgAAAA==.平昌猫:BAAALgAECgcJAgABLgAFFAUJDQAZAOsUAA==.',
['幽丶']='幽丶冥:BAAALgAECgkJBwAAAA==.',
['幽兰']='幽兰黛尒:BAAALgAECgcJBwAAAA==.',
['应欢']='应欢欢:BAAALgAECgcJBwAAAA==.',
['引川']='引川:BAAALgAECgYJDgAAAA==.',
['弟诶']='弟诶斥:BAABLgAFFH8GAAIEAAQJIxzxCwB1AQAEAAQJIxzxCwB1AQAAAA==.',
['强效']='强效至圣斩:BAAALgAECgYJBgABLgAECggJEAAPAAAAAA==.',
['强无']='强无敌猎爹:BAABLgAECn8kAAMZAAkJqiUgAAD0AwAZAAkJqiUgAAD0AwAeAAEJ9BEHhAA5AAAAAA==.',
['往生']='往生:BAAALgADCgUJBQAAAA==.',
['恋你']='恋你着迷:BAACLgAFFH8HAAIKAAMJMArZJACmAAAKAAMJMArZJACmAAAuAAQKfycAAgoACAmcHoMNAP8BAAoACAmcHoMNAP8BAAAA.',
['恶业']='恶业:BAACLgAFFH8LAAIOAAQJgRe6CgAxAQAOAAQJgRe6CgAxAQAuAAQKfx4AAg4ACAlmHi8DAC0CAA4ACAlmHi8DAC0CAAAA.',
['悄悄']='悄悄滴:BAACLgAFFH8PAAIKAAUJTxHiDQCsAQAKAAUJTxHiDQCsAQAuAAQKfyMABAoACQk6IZMLAGcDAAoACQk6IZMLAGcDAB8AAgkaDnEUAH8AACAAAgmJB1gMAGgAAAAA.',
['悠米']='悠米队长:BAAALgAECgMJAwAAAA==.',
['慕婉']='慕婉儿:BAAALgAFFAIJBAABLgAECgcJFQALACMWAA==.',
['慕安']='慕安若:BAAALgAECgYJBgAAAA==.',
['慕芊']='慕芊芊:BAAALgAECgcJBwAAAA==.',
['慕芷']='慕芷晴:BAAALgAECgkJDwABLgAFFAcJCgAKAO4cAA==.',
['慕苏']='慕苏禾:BAAALgAECgcJBgAAAA==.',
['慕言']='慕言汐:BAAALgAECgcJBwAAAA==.',
['懒大']='懒大王:BAAALgAFFAQJBAAAAA==.',
['懒懒']='懒懒的小背心:BAAALgAECggJCAAAAA==.',
['懼夢']='懼夢丶:BAAALgAFFAMJAwAAAA==.',
['我叫']='我叫不高兴:BAAALgAFFAIJAgAAAA==.',
['我姓']='我姓杨丶:BAAALgAECgEJAQAAAA==.',
['我是']='我是葡萄:BAAALgAECgcJCwAAAA==.',
['我真']='我真的是红手:BAAALgAECgUJBQABLgAFFAEJAQAPAAAAAA==.',
['我老']='我老婆超可爱:BAAALgADCgYJBgABLgAECgMJBgAPAAAAAA==.',
['我要']='我要烟牌:BAAALgAECgEJAwAAAA==.',
['所有']='所有人:BAAALgAECgUJBgAAAA==.',
['扣一']='扣一复活牢大:BAAALgAECgUJBQAAAA==.',
['执丶']='执丶手:BAAALgAFFAEJAQAAAA==.',
['执剑']='执剑人:BAAALgAECgkJAQAAAA==.',
['技术']='技术差心态棒:BAAALgAECgIJAgAAAA==.',
['抄底']='抄底:BAABLgAFFH8OAAIEAAQJ4BGAEQBDAQAEAAQJ4BGAEQBDAQAAAA==.',
['招财']='招财进宝:BAABLgAFFH8KAAMaAAUJ/A0ZBgCFAQAaAAUJ/A0ZBgCFAQATAAEJmgvQJgBBAAAAAA==.',
['拾步']='拾步殺壹人:BAAALgAECgQJBwAAAA==.',
['拿梨']='拿梨跑:BAAALgAFFAIJAwAAAA==.',
['摇摇']='摇摇薯条:BAAALgADCgYJBgAAAA==.',
['斯嘉']='斯嘉丽艾什:BAABLgAFFH8FAAIMAAUJhxxOAwDMAQAMAAUJhxxOAwDMAQAAAA==.',
['无忧']='无忧无怖:BAACLgAFFH8QAAICAAUJbRcpBACfAQACAAUJbRcpBACfAQAuAAQKfyIAAwIACAkYG9AaAD4CAAIACAkYG9AaAD4CAAMABQmQGCOHAGwBAAAA.',
['既定']='既定之天命:BAAALgAECgcJCQAAAA==.',
['时光']='时光会倒流:BAABLgAFFH8FAAICAAUJsRJcBACaAQACAAUJsRJcBACaAQAAAA==.时光浅歌:BAABLgAFFH8GAAITAAMJtx3CDAAZAQATAAMJtx3CDAAZAQAAAA==.',
['星辰']='星辰墜落:BAAALgAECgcJDAAAAA==.',
['是小']='是小新呀:BAAALgAECgEJAgAAAA==.',
['暗影']='暗影之杰克:BAAALgAFFAEJAQAAAA==.',
['暮色']='暮色回响丶:BAAALgAFFAIJAgAAAA==.',
['暴打']='暴打小苏菲:BAAALgAECggJDQAAAA==.',
['曼芭']='曼芭:BAAALgAECgYJDQAAAA==.',
['最爱']='最爱大西瓜:BAAALgAECgEJAQAAAA==.',
['月亮']='月亮我踹弯的:BAAALgAECgQJBgAAAA==.',
['月使']='月使徒:BAAALgAECgEJAgAAAA==.',
['月火']='月火机关枪:BAAALgAECgcJCAABLgAECgkJCgAPAAAAAA==.',
['月见']='月见丶:BAAALgAECgcJCAAAAA==.',
['有点']='有点困:BAAALgAECgYJEQAAAA==.',
['有马']='有马加奈:BAAALgADCgYJBgAAAA==.',
['朝朝']='朝朝辞暮暮:BAAALgAECgcJBwAAAA==.',
['本草']='本草纲目:BAAALgAECgMJAwAAAA==.',
['朴昌']='朴昌范:BAAALgAECggJBwABLgAECgkJEgAPAAAAAA==.',
['杀死']='杀死知更鸟:BAAALgAECgkJDwAAAA==.',
['李家']='李家旺:BAAALgAECgEJAQAAAA==.',
['李慕']='李慕婉:BAAALgAFFAEJAQAAAA==.',
['村儿']='村儿:BAAALgAFFAEJAQAAAA==.',
['果丶']='果丶酱:BAAALgADCgYJBgAAAA==.',
['柒夜']='柒夜流觴:BAACLgAFFH8LAAIGAAQJbxE/CwA2AQAGAAQJbxE/CwA2AQAuAAQKfxwAAgYACAmVHnQgAMACAAYACAmVHnQgAMACAAAA.',
['染血']='染血的小黄瓜:BAAALgADCgYJBgAAAA==.',
['柔柔']='柔柔爹拨皮:BAAALgAFFAEJAQAAAA==.',
['格锐']='格锐特:BAABLgAFFH8IAAISAAQJDRIOCQA9AQASAAQJDRIOCQA9AQAAAA==.',
['梁朝']='梁朝伟:BAAALgAFFAEJAQAAAA==.',
['梦可']='梦可儿:BAAALgAECgcJBwAAAA==.',
['梦回']='梦回还:BAAALgAECggJCgAAAA==.',
['梦翼']='梦翼流苏:BAAALgAFFAEJAQAAAA==.',
['棒冰']='棒冰:BAACLgAFFH8HAAIdAAQJKhEfAQAdAQAdAAQJKhEfAQAdAQAuAAQKfx8AAh0ACAlYImsBABIDAB0ACAlYImsBABIDAAAA.',
['橙色']='橙色:BAAALgAECgkJCQAAAA==.',
['欧神']='欧神:BAAALgAFFAMJAQAAAA==.欧神会变身:BAAALgAFFAQJBAAAAA==.',
['欧米']='欧米茄:BAABLgAFFH8GAAIhAAIJfxc1FACsAAAhAAIJfxc1FACsAAAAAA==.',
['死亡']='死亡擱淺:BAAALgAECgkJDQAAAA==.',
['死騎']='死騎丶:BAAALgAFFAIJAgAAAA==.',
['毁灭']='毁灭博士:BAAALgAFFAIJAgAAAA==.',
['永川']='永川菲尔米诺:BAAALgAECgcJBwAAAA==.',
['江离']='江离:BAABLgAFFH8FAAIGAAQJ3gu5HgAjAQAGAAQJ3Qu5HgAjAQAAAA==.',
['没棱']='没棱角石头子:BAAALgAECgIJAwAAAA==.',
['没爱']='没爱硬做:BAAALgADCgMJAwAAAA==.',
['法力']='法力馋扎:BAAALgAFFAIJAgABLgAFFAQJBwAEAHYTAA==.',
['泡芙']='泡芙米米:BAAALgAECgEJAQAAAA==.',
['泰伦']='泰伦血窟:BAAALgAFFAQJBAAAAA==.',
['泰坦']='泰坦杀手:BAACLgAFFH8LAAIiAAQJRw/pBQAMAQAiAAQJRw/pBQAMAQAuAAQKfxQAAiIABwm9F5cTANIBACIABwm9F5cTANIBAAAA.',
['泽川']='泽川小兔:BAAALgADCgcJBwABLgAFFAgJAQAPAAAAAA==.',
['洪福']='洪福齐天:BAAALgAECgEJAgAAAA==.',
['流光']='流光飞萤:BAAALgAFFAMJBAAAAA==.',
['流龙']='流龙马:BAAALgAECgMJBgAAAA==.',
['浅墨']='浅墨筱猎:BAAALgAECgQJBAAAAA==.',
['浅蓝']='浅蓝吖:BAABLgAFFH8IAAIaAAQJuAnHCwAtAQAaAAQJuAnHCwAtAQAAAA==.浅蓝呀:BAABLgAFFH8IAAIhAAQJZQ5mCwAzAQAhAAQJZQ5mCwAzAQAAAA==.',
['浇花']='浇花:BAAALgADCgEJAgAAAA==.',
['浮世']='浮世草:BAAALgAFFAEJAQAAAA==.',
['涤罪']='涤罪之焰:BAAALgADCgEJAQAAAA==.',
['淡淡']='淡淡甜味:BAAALgADCgIJAgAAAA==.',
['淰汐']='淰汐:BAAALgAFFAIJBAAAAA==.',
['清宵']='清宵:BAAALgAECgkJEgAAAA==.',
['清漪']='清漪:BAAALgAFFAEJAQAAAA==.',
['溪午']='溪午不闻钟:BAABLgAFFH8GAAICAAQJ9w4gCgA3AQACAAQJ9w4gCgA3AQAAAA==.',
['滚门']='滚门糖:BAAALgAECgkJCgAAAA==.',
['漫漫']='漫漫丶依然:BAAALgAECgYJBgAAAA==.',
['灬九']='灬九仙灬:BAABLgAECn8VAAIZAAcJUB7YCAD6AQAZAAcJUB7YCAD6AQAAAA==.',
['灼灼']='灼灼其华:BAAALgAFFAEJAQAAAA==.',
['灿若']='灿若星辰:BAAALgAECgEJAQAAAA==.',
['点名']='点名死在人群:BAAALgAECgUJBwAAAA==.',
['点点']='点点和朵朵:BAAALgAFFAIJBAAAAA==.',
['烈风']='烈风:BAAALgAECgcJCwAAAA==.',
['烛离']='烛离:BAAALgAECgYJBwAAAA==.',
['煤多']='煤多多:BAAALgAECgYJCwAAAA==.',
['熊依']='熊依依:BAAALgAECgYJCwAAAA==.',
['熔炉']='熔炉百相:BAAALgAECgEJAQAAAA==.',
['爱静']='爱静如梦:BAAALgAECgcJBwAAAA==.',
['狂野']='狂野妹妹:BAAALgAFFAEJAQAAAA==.',
['猥鎖']='猥鎖兽爷:BAAALgAFFAEJAQAAAA==.猥鎖獣爷:BAAALgAFFAEJAQAAAA==.',
['猪肉']='猪肉王子:BAAALgAECgcJCQAAAA==.',
['猫丶']='猫丶妮卡:BAAALgAECgkJBwABLgAFFAQJBAAPAAAAAA==.',
['猫之']='猫之愛恋:BAAALgAECggJCwABLgAFFAQJBAAPAAAAAA==.',
['猫猫']='猫猫德:BAABLgAECn8YAAIaAAYJuhPSNgBfAQAaAAYJuhPSNgBfAQAAAA==.',
['王祖']='王祖贤丶:BAAALgADCgIJAgAAAA==.',
['玛嗒']='玛嗒塔:BAAALgAECgYJDgAAAA==.',
['班德']='班德尔小猫:BAAALgADCgEJAQAAAA==.班德尔的猫:BAAALgAECgEJAQAAAA==.',
['甄姬']='甄姬扒水:BAAALgADCgUJBQAAAA==.',
['甘織']='甘織玲奈子:BAAALgAECgYJDQAAAA==.',
['甘霖']='甘霖:BAABLgAFFH8KAAMhAAQJ0gJfEgDNAAAhAAQJ0gJfEgDNAAAjAAEJ9gCIBwA+AAAAAA==.',
['甜丝']='甜丝儿丝儿:BAAALgAECgkJEAAAAA==.',
['生命']='生命脆弱如丝:BAAALgAECgkJCQAAAA==.',
['疯癫']='疯癫的小毛驴:BAAALgAFFAQJBAAAAA==.',
['疲惫']='疲惫虚弱沧桑:BAAALgAECgQJBgAAAA==.',
['痛仰']='痛仰:BAAALgAECgQJBgAAAA==.',
['白湘']='白湘:BAAALgAECgIJAgAAAA==.',
['的的']='的的:BAAALgAECgEJAQAAAA==.',
['皮干']='皮干:BAAALgAECgIJAgAAAA==.',
['皮皮']='皮皮乐:BAAALgAECgIJAgABLgAFFAUJEAACAG0XAA==.',
['盖世']='盖世豪侠:BAAALgAECgEJAgAAAA==.',
['眼神']='眼神忧郁深沉:BAAALgAECgkJCAAAAA==.',
['眼里']='眼里没有光:BAAALgAECgkJCwAAAA==.',
['瞬发']='瞬发炉石法案:BAABLgAFFH8HAAISAAIJLx4rFAC6AAASAAIJLx4rFAC6AAAAAA==.',
['碳丶']='碳丶多多:BAAALgAECgEJAQAAAA==.',
['福利']='福利豆:BAAALgAECgcJCAABLgAFFAQJBAAPAAAAAA==.',
['福禄']='福禄寿:BAABLgAFFH8JAAMaAAUJjQgMBwByAQAaAAUJjQgMBwByAQATAAMJAgvPEgDTAAAAAA==.',
['禛畿']='禛畿灞莺:BAAALgAECgEJAQAAAA==.',
['秦意']='秦意绝:BAAALgAECgEJAQAAAA==.',
['空山']='空山闻鹿鸣:BAABLgAFFH8IAAMaAAQJoRiHCQBOAQAaAAQJoRiHCQBOAQATAAQJnAQ+DgADAQAAAA==.',
['空虚']='空虚寂寞冷:BAAALgADCgQJBAAAAA==.',
['章鱼']='章鱼术:BAAALgAECgEJAQAAAA==.',
['竹子']='竹子与石榴:BAAALgAECgYJCwAAAA==.',
['等我']='等我洗个澡:BAAALgAECgYJCwAAAA==.',
['等风']='等风:BAAALgAECgMJBAAAAA==.',
['简素']='简素言丶:BAAALgAECgcJCAAAAA==.',
['米利']='米利希尔:BAAALgADCgEJAQAAAA==.',
['糖丸']='糖丸子:BAAALgAFFAEJAQAAAA==.',
['糖糖']='糖糖三角:BAABLgAFFH8GAAMkAAQJCCHZAACiAQAkAAQJCCHZAACiAQAaAAEJ5xreGABXAAAAAA==.',
['素度']='素度咩:BAAALgAECgMJAwAAAA==.',
['紫苏']='紫苏:BAAALgAECgMJAwAAAA==.',
['红烧']='红烧牛肉人:BAAALgAECgUJBwAAAA==.红烧的小排骨:BAAALgADCgEJAQAAAA==.',
['约修']='约修亚:BAAALgADCgIJAgAAAA==.',
['织诗']='织诗成锦:BAAALgAFFAQJBAAAAA==.',
['终阳']='终阳的败犬:BAACLgAFFH8PAAMCAAQJuxbPCABGAQACAAQJuxbPCABGAQADAAEJtQBwOwA8AAAuAAQKfxUAAwIABwl+FEEzALEBAAIABwl+FEEzALEBAAMABAmEHbK2ABcBAAAA.',
['绿光']='绿光:BAAALgAECgUJBQAAAA==.',
['羊一']='羊一手开门走:BAABLgAFFH8QAAMKAAQJhhMhHABaAQAKAAQJdxIhHABaAQAfAAEJ/gfGAQBPAAAAAA==.',
['羽川']='羽川翼:BAAALgAFFAQJBAAAAA==.',
['老僧']='老僧:BAAALgAECgUJBQAAAA==.',
['老婆']='老婆只让玩法:BAAALgAECgYJBgAAAA==.',
['老羊']='老羊龙:BAAALgAECgMJAwAAAA==.',
['耶梦']='耶梦加得:BAAALgAECgMJAwAAAA==.',
['联盟']='联盟骑士:BAAALgADCgEJAQAAAA==.',
['聖光']='聖光闪现:BAAALgAECgIJAgAAAA==.',
['肉丶']='肉丶肉:BAABLgAFFH8HAAIKAAQJ7hkbEwAZAQAKAAQJ7hkbEwAZAQAAAA==.',
['肉沫']='肉沫蛋黄派:BAAALgAECgEJAgAAAA==.',
['胖神']='胖神带带我:BAAALgADCgYJBgAAAA==.',
['舒克']='舒克乄:BAAALgAFFAIJAwAAAA==.',
['艾瑞']='艾瑞达花花:BAAALgADCgEJAQAAAA==.',
['艾莲']='艾莲西雅:BAAALgAECgEJAQAAAA==.',
['芙宁']='芙宁娜:BAAALgAECgYJDAAAAA==.',
['花澤']='花澤香菜:BAAALgADCgUJBQAAAA==.',
['苏喂']='苏喂苏喂:BAAALgAECgQJBQAAAA==.',
['茉莉']='茉莉雨:BAAALgAECgYJCwAAAA==.',
['茶一']='茶一只:BAAALgAECgEJAgAAAA==.',
['药匣']='药匣子:BAAALgAECgEJAQAAAA==.',
['莫卡']='莫卡瑞尔娜:BAAALgAECgIJAgAAAA==.',
['莫莫']='莫莫子:BAAALgAECgUJBQAAAA==.',
['莲华']='莲华错:BAAALgAECgMJAwAAAA==.',
['萌你']='萌你一脸血:BAAALgAECgkJCQAAAA==.',
['萧薰']='萧薰儿:BAAALgAECgcJAwAAAA==.',
['落红']='落红逐青裙:BAACLgAFFH8LAAIKAAQJVCV9DQCwAQAKAAQJVCV9DQCwAQAuAAQKfyAAAwoACAl9JGQQAEUDAAoACAl9JGQQAEUDACAAAgk+GuQJAKwAAAAA.',
['董白']='董白:BAAALgAECgYJAwAAAA==.',
['蒲公']='蒲公英的旅行:BAAALgAECgcJBwAAAA==.',
['蕞后']='蕞后的德鲁:BAAALgADCgMJAwAAAA==.',
['蛋蛋']='蛋蛋去哪里:BAAALgAECgkJCAAAAA==.',
['蝴蝶']='蝴蝶忍:BAAALgAECgEJAgAAAA==.',
['蟲姬']='蟲姬:BAAALgAECgUJBQAAAA==.',
['被遗']='被遗忘的凝凝:BAAALgAECgcJDQAAAA==.',
['裁雨']='裁雨留虹:BAABLgAECn8WAAIHAAkJiRQ6EQBlAgAHAAkJiRQ6EQBlAgAAAA==.',
['裸丶']='裸丶刁:BAAALgAFFAMJBAAAAA==.',
['豹变']='豹变之蔚:BAABLgAECn8dAAIOAAkJOyLxAADAAgAOAAkJOyLxAADAAgAAAA==.',
['贝利']='贝利乌鸦嘴:BAAALgAECgIJBAAAAA==.',
['贰号']='贰号拉面师傅:BAAALgAECgEJAQAAAA==.',
['赛博']='赛博坦大锤:BAAALgAECggJCgAAAA==.',
['超度']='超度我丶:BAAALgAFFAIJBAAAAA==.',
['路小']='路小雨丶:BAAALgAECgkJEAAAAA==.',
['蹄子']='蹄子:BAAALgAECgIJAwAAAA==.',
['躺尸']='躺尸老板:BAABLgAECn8aAAIOAAkJ1iGKAADwAgAOAAkJ1iGKAADwAgAAAA==.',
['辶逆']='辶逆:BAAALgAECgEJAQAAAA==.',
['迷之']='迷之谷:BAAALgAECgUJBQAAAA==.',
['送你']='送你一朵花:BAAALgAECgEJAQAAAA==.',
['逆流']='逆流六分仪:BAAALgAECgMJAwAAAA==.',
['逆袭']='逆袭丶凝:BAACLgAFFH8FAAMZAAMJLg4IFQCeAAAZAAIJeAYIFQCeAAAeAAIJBRJDHwCZAAAuAAQKfyMAAx4ACAl2IE0SAKICAB4ABwnlIU0SAKICABkAAgmiGzA4AKUAAAAA.',
['逆風']='逆風飛翔:BAAALgAECgEJAQAAAA==.',
['逆风']='逆风飞翔:BAAALgAECgEJAQAAAA==.',
['酒仙']='酒仙儿:BAAALgAECgQJBAAAAA==.',
['酸菜']='酸菜豆角粥:BAAALgAECgEJAQAAAA==.',
['醉了']='醉了丶流年:BAACLgAFFH8HAAMZAAMJVRdJEgC5AAAZAAIJshVJEgC5AAAeAAIJ7g4bHwCZAAAuAAQKfyIABB4ACAl0HUYVAIQCAB4ACAl0HUYVAIQCACUABwkhFVEEAMoBABkAAQnsD4TRADQAAAAA.',
['里海']='里海:BAAALgAFFAMJAwAAAA==.',
['重叠']='重叠的掩饰:BAABLgAFFH8FAAIZAAIJuxyaDwC7AAAZAAIJuxyaDwC7AAAAAA==.',
['野生']='野生雷头咣:BAAALgAECgcJCAAAAA==.野生雷龙:BAAALgAECgcJCQAAAA==.',
['野鸟']='野鸟:BAAALgAECgEJAgAAAA==.',
['钢琴']='钢琴里的猫:BAAALgAFFAUJBAAAAA==.',
['钱塘']='钱塘:BAAALgADCgQJBwAAAA==.',
['锚之']='锚之愛恋:BAAALgAECgYJBgABLgAFFAQJBAAPAAAAAA==.',
['闪开']='闪开让我先跑:BAAALgAFFAIJAgAAAA==.',
['阿尓']='阿尓萨斯:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔冯斯:BAAALgAFFAIJAgAAAA==.阿尔托莉亚灬:BAAALgAECgEJAgAAAA==.',
['阿瓦']='阿瓦达肯大瓜:BAAALgAECgQJBQAAAA==.',
['隐凡']='隐凡之路:BAAALgAECgkJEAAAAA==.',
['集火']='集火那个德:BAAALgAECgQJBgAAAA==.',
['雨线']='雨线难画:BAAALgAFFAMJAwAAAA==.',
['零陵']='零陵上将:BAAALgADCgYJBgAAAA==.',
['雷法']='雷法尔:BAAALgADCgQJAgAAAA==.',
['雷灬']='雷灬特:BAAALgAFFAMJAwAAAA==.',
['雷霆']='雷霆一断角:BAAALgADCgEJAQAAAA==.',
['霜降']='霜降露隐:BAAALgAECgMJAwAAAA==.',
['霸气']='霸气依依:BAAALgAECgEJAQAAAA==.霸气恒恒:BAABLgAECn8YAAIGAAYJmCXgMAB0AgAGAAYJmCXgMAB0AgAAAA==.',
['青衣']='青衣神相:BAAALgAECgIJAgAAAA==.',
['青龙']='青龙场的龙:BAACLgAFFH8RAAIIAAQJJAZ/DAAfAQAIAAQJJAZ/DAAfAQAuAAQKfyQAAwgACAk2Cl4IAB4BAAgACAk2Cl4IAB4BABwABQkrE/4hABoBAAAA.',
['願枕']='願枕星河如夢:BAAALgAECgEJAQABLgAFFAUJEAACAG0XAA==.',
['風来']='風来:BAAALgADCgYJBgAAAA==.',
['风之']='风之幽谷:BAAALgADCgIJAgAAAA==.',
['风起']='风起无兆:BAABLgAFFH8GAAIbAAQJUAtEBgAYAQAbAAQJUAtEBgAYAQAAAA==.',
['风雨']='风雨无视:BAAALgAECgUJBQAAAA==.风雨泪:BAAALgAECgEJAQAAAA==.',
['飞雪']='飞雪映晨曦:BAAALgAECgYJBgAAAA==.',
['饿狼']='饿狼食月:BAAALgAECgkJCQABLgAFFAYJFQAJAFMSAA==.',
['香菜']='香菜:BAABLgAFFH8FAAIKAAMJeAaoMADwAAAKAAMJeAaoMADwAAAAAA==.香菜引爆地球:BAAALgADCgIJAgAAAA==.',
['高皓']='高皓光:BAAALgAECgIJAwABLgAFFAEJAQAPAAAAAA==.',
['魑魅']='魑魅魍魉:BAAALgAECgQJBAAAAA==.',
['魔法']='魔法披风:BAAALgAECgEJAQAAAA==.',
['鸡丝']='鸡丝凉面:BAAALgAECgcJBwAAAA==.',
['麦门']='麦门永存:BAAALgAECgYJCQAAAA==.',
['黏黏']='黏黏豆包:BAAALgAECgcJEQAAAA==.',
['龍傲']='龍傲娇:BAAALgAECgQJBAAAAA==.',
['龙希']='龙希尔薇:BAABLgAFFH8JAAIIAAUJnw7UBQCYAQAIAAUJnw7UBQCYAQAAAA==.',
['龙瞎']='龙瞎:BAAALgAECgEJAQAAAA==.',
['龙肝']='龙肝凤胆粥:BAAALgADCgEJAQAAAA==.',
['龙蜥']='龙蜥尔:BAAALgAECgUJCQAAAA==.',
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
