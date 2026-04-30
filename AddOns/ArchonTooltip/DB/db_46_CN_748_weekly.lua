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

local lookup = {'Paladin-Retribution','Druid-Balance','Unknown-Unknown','Paladin-Holy','Warrior-Fury','Warrior-Arms','Priest-Discipline','Mage-Frost','Evoker-Augmentation','Evoker-Preservation','DemonHunter-Havoc','DemonHunter-Devourer','DeathKnight-Unholy','Druid-Restoration','DeathKnight-Blood','Hunter-BeastMastery','Warrior-Protection','Warlock-Demonology','Mage-Arcane','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Hunter-Survival','Priest-Holy','Priest-Shadow','Shaman-Restoration','Paladin-Protection','Monk-Brewmaster','Rogue-Subtlety','Rogue-Outlaw','Rogue-Assassination','Evoker-Devastation','Warlock-Ranged','Shaman-Enhancement',}
local provider = {region='CN',realm='熔火之心',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adundun:BAAALgAFFAEJAQAAAA==.',
Ar='Arrowgreen:BAAALgAECgYJBgAAAA==.',
At='Atroxnak:BAAALgAECgQJAwABLgAECggJFAABAOIgAA==.Atroxnar:BAABLgAECn8UAAIBAAgJ4iBqEgD/AgABAAgJ4iBqEgD/AgAAAA==.',
Av='Avid:BAAALgADCgIJAQAAAA==.',
Ba='Babinainai:BAAALgADCgQJBAAAAA==.Babyblue:BAAALgAECgEJAgAAAA==.Badappleone:BAAALgAFFAQJBAAAAA==.Badappletwo:BAABLgAFFH8IAAICAAQJ9Q3xCgA8AQACAAQJ9Q3xCgA8AQAAAA==.Baobao:BAAALgAECgYJCwABLgAECgcJCQADAAAAAA==.Battlent:BAAALgAECgQJBAAAAA==.',
Be='Beretta:BAAALgAECgEJAgAAAA==.',
Bi='Bigworse:BAAALgAECgQJBQAAAA==.',
Ca='Capencise:BAAALgAECgkJBQAAAA==.Cavalia:BAABLgAFFH8JAAIEAAUJpQ6NBQCDAQAEAAUJpQ6NBQCDAQAAAA==.',
Ce='Celebrities:BAAALgAECgIJAgAAAA==.',
Co='Colepalmer:BAAALgAECgEJAQAAAA==.',
Do='Doubled:BAAALgAFFAEJAgAAAA==.',
Dp='Dpkf:BAAALgAECgIJAgAAAA==.',
Du='Duonai:BAAALgAECgEJAQAAAA==.',
Em='Emliya:BAAALgAECgEJAQAAAA==.Emmawong:BAAALgADCgIJAwABLgADCgcJDAADAAAAAA==.',
Eo='Eos:BAAALgAECgkJDwAAAA==.',
Ex='Excaliburs:BAAALgAFFAEJAQAAAA==.',
Ey='Eyjafjalla:BAAALgAFFAQJAwAAAA==.',
Fe='Feigeo:BAAALgADCgUJBQAAAA==.',
Fo='Forbiddenws:BAAALgAECgEJAQAAAA==.',
Fu='Fullne:BAAALgADCgUJBwAAAA==.',
Ga='Gabriel:BAAALgAECgYJBgAAAA==.',
Go='Gouerdanm:BAAALgAECgYJBgAAAA==.',
Ha='Hairan:BAAALgADCgUJBQAAAA==.',
He='Hellkeeper:BAAALgADCgEJAQAAAA==.',
Ho='Houbiirudu:BAAALgAECgkJCQAAAA==.Houdryad:BAAALgAECgkJEAAAAA==.Housensei:BAAALgAECgIJAgAAAA==.',
Is='Ishamil:BAAALgAECgYJEQAAAA==.',
La='Lamando:BAAALgAFFAIJAgAAAA==.',
Li='Lintq:BAAALgAECgcJBwAAAA==.',
['Lâ']='Lâ:BAAALgAECgMJAwAAAA==.',
Ma='Madam:BAAALgAECgYJBgAAAA==.',
Mi='Miraitowa:BAAALgAECgYJBgAAAA==.Mithrandir:BAAALgADCgQJBAAAAA==.',
Mo='Morn:BAAALgAECgQJBAAAAA==.',
Na='Na:BAAALgAECgEJAQAAAA==.',
Ni='Nicorobin:BAAALgAECgYJCQAAAA==.',
No='Nobed:BAAALgAECgMJAQAAAA==.',
Nu='Numer:BAAALgADCgIJAgAAAA==.Nuyoah:BAAALgAFFAIJBAAAAA==.',
Ol='Oline:BAAALgAFFAIJAgAAAA==.',
Or='Orcswarrior:BAABLgAECn8iAAMFAAcJCRrWKgAMAgAFAAcJCRrWKgAMAgAGAAEJGg19QQA2AAAAAA==.',
Pa='Paradize:BAAALgAECgQJCAAAAA==.',
Ra='Rationa:BAAALgAECgEJAQAAAA==.',
Re='Redemptive:BAAALgAECgkJCwAAAA==.',
Ro='Rookiez:BAAALgAECgQJBAAAAA==.',
Ry='Ryujin:BAAALgAFFAIJBAABLgAFFAMJBQAHADodAA==.',
Sa='Sabermasta:BAAALgAECgkJBgAAAA==.Sailw:BAAALgAECgIJAwAAAA==.Sandytan:BAAALgADCgEJAgAAAA==.',
Sc='Scoop:BAAALgAECgMJBQAAAA==.',
Sh='Shox:BAAALgAECgIJAgAAAA==.',
St='Starmine:BAAALgAECgIJAgAAAA==.',
Su='Sunnywon:BAAALgAECgYJBgAAAA==.Surainss:BAAALgADCgIJAgAAAA==.Surainz:BAAALgAFFAEJAQAAAA==.Suriank:BAAALgAECgUJBgAAAA==.',
Ta='Tatsuya:BAAALgAECgkJCwAAAA==.',
Te='Teddyowo:BAABLgAFFH8FAAIBAAUJ7wz6BQCQAQABAAUJ7wz6BQCQAQAAAA==.',
Th='Thrilldark:BAAALgAECgkJCwAAAA==.Thór:BAAALgAECgcJDgAAAA==.',
Vi='Vitatea:BAAALgAECgYJBgAAAA==.',
Wa='Waston:BAAALgAECgkJCQAAAA==.Wateryo:BAAALgAECgYJEgAAAA==.',
Wu='Wuxiubo:BAAALgAECgYJDAAAAA==.',
Ww='Wwnm:BAAALgADCgEJAQAAAA==.',
Yi='Yiru:BAAALgADCgUJBQAAAA==.Yizhidk:BAAALgAFFAIJAgAAAA==.Yizhifs:BAABLgAFFH8GAAIIAAIJlRx/NgC9AAAIAAIJlRx/NgC9AAABLgAFFAYJAwADAAAAAA==.',
Zi='Zireael:BAAALgAECgUJBwAAAA==.',
Zx='Zxx:BAAALgAECgQJBAAAAA==.',
['一个']='一个小牧厮:BAAALgAECgIJAgAAAA==.',
['一关']='一关雲長一:BAAALgAFFAIJAwAAAA==.',
['一剑']='一剑关天门:BAAALgAECgQJBQAAAA==.',
['一只']='一只奶牛:BAAALgADCgEJAQAAAA==.',
['一啸']='一啸破千军:BAAALgAECgcJBwAAAA==.',
['一够']='一够萨的满一:BAAALgAECgEJAQAAAA==.',
['一心']='一心向暗丶:BAAALgAECgEJAQAAAA==.',
['一戰']='一戰痴一:BAAALgAECgIJAgAAAA==.',
['一摸']='一摸就倒:BAAALgAECgcJBwAAAA==.',
['一木']='一木易丶子一:BAAALgADCgMJAwAAAA==.',
['一束']='一束天觉:BAAALgADCgEJAQAAAA==.',
['一水']='一水灬满满:BAAALgAECgEJAgAAAA==.一水灬紫货:BAAALgAFFAIJAgAAAA==.',
['一粒']='一粒氮:BAAALgADCgUJBQAAAA==.',
['一路']='一路喜羊羊:BAAALgADCgUJBQAAAA==.一路火球术:BAABLgAFFH8HAAIIAAMJyhJ5LQABAQAIAAMJyhJ5LQABAQABLgAECgMJAwADAAAAAA==.',
['一首']='一首歌的时间:BAAALgAECgcJDQAAAA==.',
['七万']='七万:BAAALgADCgcJBwAAAA==.',
['七宗']='七宗罪丶奶嗏:BAAALgAECgYJCwAAAA==.',
['万花']='万花筒丶:BAAALgAECgQJBAAAAA==.',
['三三']='三三:BAABLgAFFH8FAAICAAIJ/hioEQC6AAACAAIJ/hioEQC6AAABLgAFFAMJBQAHADodAA==.',
['三十']='三十只骑士:BAAALgAECgEJAQAAAA==.',
['三句']='三句半:BAACLgAFFH8HAAIBAAQJIxK6CwBOAQABAAQJIxK6CwBOAQAuAAQKfxQAAgEABwkXIwEjAJ0CAAEABwkXIwEjAJ0CAAAA.',
['三级']='三级头丨:BAAALgAFFAIJAwAAAA==.',
['上帝']='上帝王主任:BAAALgAECgkJEwABLgAFFAYJCwAIAL0cAA==.上帝王校长:BAAALgAECgkJAgAAAA==.',
['上弦']='上弦之月丶:BAAALgADCgQJBAAAAA==.',
['下济']='下济三徒苦:BAAALgADCgUJBQAAAA==.',
['不会']='不会喷火:BAAALgAECgYJCwAAAA==.',
['不吃']='不吃青椒:BAAALgAECgYJEQAAAA==.',
['不死']='不死信仰:BAAALgAECgYJDwAAAA==.',
['东北']='东北大佬粗:BAAALgAECgEJAQAAAA==.',
['东商']='东商变革:BAAALgAECgMJAwAAAA==.',
['东西']='东西南北:BAAALgADCgUJBQAAAA==.',
['两把']='两把杀猪刀:BAAALgAECgIJAQAAAA==.',
['两袋']='两袋辣条约吗:BAAALgADCgUJBQAAAA==.',
['丨丨']='丨丨菟丨丨:BAAALgAECgcJBwAAAA==.',
['丨梵']='丨梵天:BAAALgAECgUJBQAAAA==.',
['丨贝']='丨贝尓摩德:BAAALgADCgQJBAAAAA==.',
['丨软']='丨软妹控丨:BAAALgAECgcJBwAAAA==.',
['丨龙']='丨龙骑士:BAABLgAFFH8NAAMJAAUJRRnkBAC5AQAJAAUJRRnkBAC5AQAKAAQJBxXeCQBLAQAAAA==.',
['中原']='中原德:BAAALgADCgYJBgAAAA==.中原骑:BAAALgAECgYJCQAAAA==.',
['丶佛']='丶佛爷丶:BAAALgADCgEJAQAAAA==.',
['丶你']='丶你瞅啥丶:BAAALgAECgEJAQAAAA==.',
['丶哈']='丶哈基米丶:BAAALgAECgUJCAAAAA==.',
['丶壮']='丶壮壮:BAAALgAECgYJCgAAAA==.',
['丶小']='丶小妍丶:BAAALgADCgEJAQAAAA==.丶小筱丶:BAAALgAECgMJAwAAAA==.',
['丶弗']='丶弗瑞奥萨:BAAALgAECgcJAQAAAA==.',
['丶彼']='丶彼岸:BAAALgAECgEJAgAAAA==.',
['丶撩']='丶撩开你别看:BAAALgADCgQJBAAAAA==.丶撩开看看屁:BAAALgAECgEJAwAAAA==.丶撩起来看看:BAAALgAECgEJAQAAAA==.丶撩起来进去:BAAALgAECgQJBAAAAA==.',
['丶次']='丶次元碎片:BAAALgAECgQJBAAAAA==.',
['丶流']='丶流年易逝:BAAALgAECgEJAQAAAA==.丶流年韶华:BAAALgAECgEJAgAAAA==.',
['丶真']='丶真谛熊:BAAALgAECggJCwAAAA==.',
['丶繁']='丶繁星:BAAALgAECgYJBgAAAA==.',
['丶莉']='丶莉莉丝儿:BAAALgAECgIJAwAAAA==.',
['丶血']='丶血刃丶:BAAALgAECgQJBQAAAA==.',
['丶雨']='丶雨吁丶:BAAALgAECgYJDgAAAA==.',
['为了']='为了中非友谊:BAAALgADCgEJAQAAAA==.',
['丿刀']='丿刀锋剑影丶:BAAALgADCgYJBgAAAA==.',
['乄熊']='乄熊猫会功夫:BAAALgADCgYJBgAAAA==.',
['乄陌']='乄陌上人如玉:BAAALgAECgQJBwAAAA==.',
['乐正']='乐正晴:BAAALgAECgYJBwAAAA==.',
['乖乖']='乖乖龙地洞:BAAALgAECgEJAQAAAA==.',
['九垓']='九垓:BAAALgAECgEJAQAAAA==.',
['九紫']='九紫离火:BAAALgAECgEJAQAAAA==.',
['九艺']='九艺:BAAALgAECgYJDAAAAA==.',
['二二']='二二三三:BAAALgAFFAQJBAAAAA==.二二四一:BAAALgAFFAQJBAAAAA==.二二四二:BAAALgAFFAQJBAAAAA==.',
['二叶']='二叶惠麻:BAAALgADCgEJAQAAAA==.',
['云启']='云启:BAAALgADCgEJAQAAAA==.',
['云开']='云开:BAAALgAECgIJAgAAAA==.',
['云无']='云无依:BAABLgAECn8UAAMLAAYJHR1dGgDwAQALAAYJHR1dGgDwAQAMAAUJxwn8mQDmAAAAAA==.',
['五颜']='五颜六设:BAAALgAECgEJAQAAAA==.',
['亞歷']='亞歷山大:BAAALgADCgUJBQAAAA==.',
['亡者']='亡者丶君临:BAABLgAFFH8HAAINAAMJRCKRHQArAQANAAMJRCKRHQArAQAAAA==.',
['以吻']='以吻封缄:BAAALgAECgIJBAAAAA==.',
['伊丽']='伊丽丹丶怒風:BAAALgAECgcJDwAAAA==.',
['伊利']='伊利达尔:BAAALgADCgcJBgABLgAECgYJCQADAAAAAA==.',
['伊灬']='伊灬丹:BAAALgAECgQJBAAAAA==.',
['会冲']='会冲锋的低凯:BAAALgAFFAIJAwAAAA==.',
['会飞']='会飞的石头:BAAALgAECgEJAQAAAA==.',
['传说']='传说之王:BAAALgAECgQJCAAAAA==.',
['伤风']='伤风劲吹:BAACLgAFFH8QAAMOAAYJJgxaBgAQAQAOAAUJqQdaBgAQAQACAAMJmASyFwB7AAAuAAQKfycAAwIACQmuF5ElANABAAIABwnZGZElANABAA4ABgmEFVNKAHkBAAAA.',
['但为']='但为君故:BAAALgAECgIJAwAAAA==.',
['何以']='何以丶:BAAALgAFFAIJAgAAAA==.',
['你拉']='你拉哪里了:BAAALgAECgUJBQAAAA==.',
['你昨']='你昨晚很一般:BAAALgADCgEJAQAAAA==.',
['你背']='你背后的棒棒:BAAALgADCgYJBgAAAA==.',
['你认']='你认识几个字:BAAALgAFFAIJAgAAAA==.',
['你长']='你长得好提神:BAABLgAECn8UAAMBAAcJahoaOwA3AgABAAcJahoaOwA3AgAEAAYJsReoGgCgAAAAAA==.',
['佩佩']='佩佩女士:BAAALgAFFAIJAgAAAA==.',
['依法']='依法变羊:BAAALgAECgEJAQABLgAECgYJCQADAAAAAA==.',
['依諾']='依諾:BAAALgAFFAIJAgAAAA==.',
['信仰']='信仰犹存:BAAALgAECgMJAwAAAA==.',
['修罗']='修罗迷罗永恒:BAAALgAECgYJBwAAAA==.',
['倔强']='倔强于执着丶:BAAALgAECgEJAQAAAA==.',
['停止']='停止呼吸壹:BAAALgAFFAIJAgAAAA==.',
['傲慢']='傲慢之罪:BAAALgAECgcJCAAAAA==.',
['像风']='像风很洒脱:BAAALgAECgMJAwAAAA==.',
['光仔']='光仔崽:BAAALgAECgcJBwAAAA==.',
['光玲']='光玲珑:BAABLgAECn8VAAMEAAgJeRxLEQCIAgAEAAgJeRxLEQCIAgABAAcJXhhKdwCLAQAAAA==.',
['八云']='八云岚:BAABLgAFFH8FAAIPAAMJqwJcDQCYAAAPAAMJqwJcDQCYAAAAAA==.',
['八烨']='八烨:BAAALgADCgMJAwAAAA==.',
['六乄']='六乄六:BAAALgAECgEJAQAAAA==.',
['共饮']='共饮悲欢:BAAALgAECgMJBgAAAA==.',
['兴趣']='兴趣使然:BAABLgAECn8UAAMFAAcJDhuJKwAIAgAFAAcJPhiJKwAIAgAGAAEJTRsvOABPAAAAAA==.',
['冥界']='冥界牛主宰:BAAALgAECgEJAQAAAA==.',
['冯楠']='冯楠舒:BAAALgAECgcJDwAAAA==.',
['冰冻']='冰冻的眼泪:BAAALgAECgEJAQAAAA==.',
['冰奶']='冰奶茶:BAAALgAECgEJAQAAAA==.',
['冰若']='冰若蓝颜:BAAALgAECgEJAQAAAA==.',
['冰镇']='冰镇青柠:BAAALgAECgYJBgAAAA==.',
['冲鋒']='冲鋒释放:BAAALgAECgQJBQAAAA==.',
['冲钅']='冲钅夆:BAAALgAECgEJAQAAAA==.',
['凌峰']='凌峰飞雪:BAAALgAECgYJCwAAAA==.',
['减肥']='减肥成功:BAAALgAECgcJCgAAAA==.',
['凤凰']='凤凰之怒:BAAALgAECgMJAwAAAA==.',
['凤城']='凤城玫瑰:BAAALgADCgUJAgAAAA==.',
['刺头']='刺头不说话丶:BAABLgAFFH8FAAIQAAMJVw1FDQD1AAAQAAMJVw1FDQD1AAAAAA==.',
['剑在']='剑在人在丨:BAABLgAECn8WAAQFAAgJrBwtHwBXAgAFAAgJrBwtHwBXAgARAAMJJQuUNwCMAAAGAAEJsx2hNgBVAAAAAA==.',
['剑影']='剑影:BAAALgAFFAUJAQAAAA==.',
['加斯']='加斯特度易特:BAAALgADCgUJBQAAAA==.',
['加菲']='加菲狼:BAAALgAECgUJCgAAAA==.',
['动感']='动感超人:BAAALgADCgEJAQAAAA==.',
['助威']='助威先生:BAAALgAECgEJAQAAAA==.',
['劳达']='劳达歌:BAAALgAECgcJBwAAAA==.',
['勇敢']='勇敢波波:BAAALgAECgMJAwAAAA==.',
['勺子']='勺子:BAAALgADCgQJBAAAAA==.',
['勾引']='勾引我吧:BAAALgAECggJCgAAAA==.',
['北丶']='北丶凉灬:BAAALgADCgYJBgAAAA==.',
['北兜']='北兜兜:BAAALgAECgEJAQAAAA==.',
['北国']='北国风光:BAAALgAECgIJAgAAAA==.',
['十七']='十七停:BAAALgAECgIJAgAAAA==.',
['午夜']='午夜咆哮:BAAALgAECgcJCwAAAA==.',
['半移']='半移动式保姆:BAAALgAECgUJBQAAAA==.',
['华夏']='华夏第一剑:BAAALgADCgcJBwAAAA==.',
['华山']='华山派最硬的:BAAALgAECgEJAQAAAA==.',
['单手']='单手射击骑士:BAAALgAECgQJBQAAAA==.',
['单挑']='单挑王:BAAALgAECgYJCwAAAA==.',
['卖女']='卖女孩鍀火柴:BAABLgAFFH8FAAISAAUJuRvBBADSAQASAAUJuBvBBADSAQAAAA==.',
['南烛']='南烛:BAACLgAFFH8GAAIIAAMJNAjJLwD2AAAIAAMJNAjJLwD2AAAuAAQKfxcAAwgABwktEnSPALQBAAgABwnTEXSPALQBABMAAQklEXEaAEQAAAAA.',
['南风']='南风丶落:BAAALgAECggJCAAAAA==.',
['卟语']='卟语:BAAALgAECgEJAQAAAA==.',
['卡布']='卡布兰德:BAAALgAECgEJAQAAAA==.卡布奇諾:BAAALgADCgEJAQAAAA==.',
['危险']='危险女士:BAAALgAECgEJAQAAAA==.',
['原谅']='原谅帽贩卖机:BAAALgAECgcJDwAAAA==.',
['厷爵']='厷爵:BAAALgAECgQJBwAAAA==.',
['去也']='去也匆匆:BAAALgAECgEJAQAAAA==.',
['反应']='反应迟钝:BAAALgAECgMJAwAAAA==.',
['反骨']='反骨:BAABLgAFFH8FAAIMAAQJxQaNGQADAQAMAAQJxQaNGQADAQAAAA==.',
['变点']='变点什么呢:BAAALgAECgYJCgAAAA==.',
['只玩']='只玩奶骑:BAAALgADCgEJAQAAAA==.',
['只赚']='只赚不赔:BAAALgAECgQJBAAAAA==.',
['叫我']='叫我闪电侠:BAAALgAECgEJAQAAAA==.',
['可怕']='可怕的狩猎者:BAAALgAECgYJDAAAAA==.',
['可硬']='可硬了:BAAALgAECgEJAgAAAA==.',
['可能']='可能有点疼:BAAALgAFFAEJAQAAAA==.',
['史莱']='史莱姆:BAAALgAECgUJBQAAAA==.',
['司马']='司马硬汉:BAAALgAECgEJAQAAAA==.',
['吃葡']='吃葡萄的阿木:BAABLgAECn8aAAMQAAkJBxM1SACRAQAQAAUJlRk1SACRAQAUAAkJ3w9LPABsAQAAAA==.',
['吉鲁']='吉鲁艾:BAAALgADCgEJAQAAAA==.',
['名利']='名利不如闲:BAAALgAECgUJBQAAAA==.',
['后来']='后来遇见他:BAAALgAECgYJBgAAAA==.',
['后羿']='后羿丶:BAAALgAECgUJCQAAAA==.',
['吟笑']='吟笑徐行:BAAALgAECgUJDwAAAA==.',
['吾乃']='吾乃叶东岳:BAAALgAECgMJAwAAAA==.',
['呆萌']='呆萌呆萌滴:BAABLgAECn8ZAAIIAAcJIRsYVgA2AgAIAAcJIRsYVgA2AgAAAA==.',
['周九']='周九月:BAABLgAFFH8NAAMVAAQJcQXiAgAMAQAVAAQJcQXiAgAMAQAWAAMJjAokDQDSAAAAAA==.',
['味覚']='味覚糖:BAAALgAECgEJAQAAAA==.',
['呼哈']='呼哈丶:BAABLgAFFH8KAAIOAAQJjBMiCQBBAQAOAAQJjBMiCQBBAQAAAA==.',
['咕叽']='咕叽咕叽呼:BAAALgAECgcJBwAAAA==.',
['咕咕']='咕咕驯养大师:BAACLgAFFH8KAAIQAAMJtR26BwAnAQAQAAMJtR26BwAnAQAuAAQKfxUAAxQABgmHHV03AIYBABQABgk4GV03AIYBABAABAkFHrViAD8BAAAA.',
['咕德']='咕德猫寕:BAAALgADCgYJBgABLgAECgYJCQADAAAAAA==.',
['哆啦']='哆啦誒喵:BAAALgAECgUJBQAAAA==.',
['哆瑞']='哆瑞咪法:BAAALgADCgEJAQAAAA==.',
['哈坦']='哈坦丝蒂娅:BAAALgAECgkJCQAAAA==.',
['哈萨']='哈萨给:BAAALgAECgkJCQAAAA==.',
['唉哟']='唉哟:BAAALgAECgYJDgAAAA==.',
['唐僧']='唐僧爱吃肉丶:BAAALgAECgEJAQAAAA==.',
['唯有']='唯有一种感觉:BAAALgAECgYJBwAAAA==.',
['啊脑']='啊脑:BAAALgAECgMJAwAAAA==.',
['喵宁']='喵宁好好偶:BAABLgAFFH8JAAQUAAQJVhYFEQAlAQAUAAQJcwoFEQAlAQAQAAIJ5xgVJgBVAAAXAAIJog0AAAAAAAAAAA==.',
['嗜血']='嗜血者丨如封:BAAALgADCgEJAQAAAA==.',
['嗨丶']='嗨丶尖叫:BAAALgADCgEJAQAAAA==.嗨丶布莱恩:BAAALgAECgUJCgAAAA==.',
['嗯呐']='嗯呐:BAAALgAECgMJAwAAAA==.',
['四糸']='四糸沐风:BAAALgADCgEJAQAAAA==.',
['团长']='团长缺德吗:BAAALgAFFAMJAwAAAA==.',
['囸出']='囸出东方:BAAALgADCgcJBwAAAA==.',
['国宝']='国宝丶:BAAALgAECgMJAwAAAA==.',
['国色']='国色天香:BAAALgAECgQJBgAAAA==.',
['圣光']='圣光之处:BAAALgADCgYJBgAAAA==.圣光帕鲁:BAACLgAFFH8GAAMBAAQJ7x6dDgA1AQABAAMJFR+dDgA1AQAEAAIJHRO4EwClAAAuAAQKfxgAAwQACAm0GvYeACACAAQABwkgHfYeACACAAEABwmMFjZhAMEBAAAA.圣光的侍从:BAAALgAECgMJAwAAAA==.圣光背叛者:BAAALgAECggJBwAAAA==.圣光阿牛哥:BAAALgAECgMJAwAAAA==.',
['在下']='在下溜溜球:BAAALgAECgYJBwAAAA==.在下牛德柱:BAAALgADCgUJBAAAAA==.',
['地狱']='地狱中归来:BAAALgAECgEJAQAAAA==.',
['坂田']='坂田丶银时:BAAALgAFFAUJAwAAAA==.',
['城中']='城中凡兵:BAAALgAECgQJBAAAAA==.',
['堇紫']='堇紫淚滴:BAAALgAECgUJBQAAAA==.',
['墓后']='墓后煮宩:BAAALgAECgcJBwAAAA==.',
['墓碑']='墓碑之殇:BAAALgAECgQJBgAAAA==.',
['墨靈']='墨靈弑:BAAALgADCgMJAwAAAA==.',
['壹瓶']='壹瓶养乐多:BAAALgADCgEJAQAAAA==.',
['夏夏']='夏夏丶末:BAAALgAFFAMJAwAAAA==.',
['夜伴']='夜伴风鈴:BAAALgAECgIJAgAAAA==.',
['夜凝']='夜凝紫:BAAALgAECgQJBAAAAA==.',
['夜影']='夜影风吟:BAAALgAECgYJDAAAAA==.',
['夜血']='夜血少校:BAAALgAECgIJAgAAAA==.',
['大块']='大块的冰糕:BAAALgAECgYJCAAAAA==.',
['大寳']='大寳丶:BAAALgAECgEJAQAAAA==.',
['大胖']='大胖头鱼:BAAALgAECgQJBQAAAA==.',
['大自']='大自在:BAAALgAECgIJAgAAAA==.',
['大跳']='大跳躲链子:BAAALgAECgYJCAAAAA==.',
['大酋']='大酋长韩三四:BAAALgAFFAEJAgAAAA==.',
['天哪']='天哪你可真高:BAAALgAECgMJAwAAAA==.',
['天堂']='天堂的玫瑰:BAAALgAECgQJBQAAAA==.',
['天恢']='天恢恢会不会:BAAALgAECgcJDQAAAA==.',
['天极']='天极无赖:BAAALgAECgYJBgAAAA==.',
['天生']='天生就胖:BAAALgAECgIJAgAAAA==.',
['太阳']='太阳当空照:BAAALgAECgYJCgAAAA==.',
['头球']='头球:BAAALgADCgEJAQAAAA==.',
['夹心']='夹心饼干丶:BAAALgAECgYJDQAAAA==.',
['夺魂']='夺魂者:BAAALgAECgEJAQAAAA==.',
['奇幻']='奇幻森林:BAAALgADCgYJBgAAAA==.',
['奈蒂']='奈蒂莉沐诗:BAABLgAFFH8FAAIHAAMJFw2KDgDlAAAHAAMJFw2KDgDlAAAAAA==.',
['奥尔']='奥尔加伊兹卡:BAAALgAECgYJBwAAAA==.',
['奥楚']='奥楚蔑洛夫:BAAALgAECgYJCwAAAA==.',
['奥黛']='奥黛丽霍尔:BAAALgAECgEJAQAAAA==.',
['她会']='她会魔法吗:BAAALgAECgYJDQAAAA==.',
['好命']='好命先生:BAABLgAECn8aAAISAAcJwx9QOgAjAgASAAcJwx9QOgAjAgABLgAFFAMJBQAQAFcNAA==.',
['好炫']='好炫哦:BAAALgAECgUJCQAAAA==.',
['好讨']='好讨厌起名字:BAAALgADCgEJAQAAAA==.',
['如梦']='如梦似幻:BAAALgAECgYJBgAAAA==.',
['妄议']='妄议丰年:BAAALgAECgEJAQAAAA==.',
['妇科']='妇科圣手卤蛋:BAAALgAECgMJAwAAAA==.',
['妍色']='妍色:BAAALgAECgMJAwAAAA==.',
['姐夫']='姐夫的白月光:BAAALgAECgUJBQAAAA==.姐夫的黑凤梨:BAACLgAFFH8JAAINAAQJNxmsDgBnAQANAAQJNxmsDgBnAQAuAAQKfxgAAg0ACAl4HVEeAMsCAA0ACAl4HVEeAMsCAAAA.',
['婲落']='婲落丶涙紅顏:BAAALgAECgIJAwAAAA==.',
['嫂嫂']='嫂嫂别乱来:BAAALgAECgYJDAABLgAFFAIJAwADAAAAAA==.',
['嫂子']='嫂子猎手:BAAALgAECgQJBAAAAA==.',
['子夙']='子夙:BAABLgAFFH8FAAINAAMJSRFOTQBbAAANAAMJSRFOTQBbAAAAAA==.',
['子时']='子时四刻死鬼:BAAALgAECgUJBQAAAA==.',
['孤寂']='孤寂小酌:BAACLgAFFH8JAAMYAAMJJBPIDACYAAAYAAIJehfIDACYAAAHAAMJLgrtFACOAAAuAAQKfxoABAcACAn+GycPAEsCAAcABwmDHScPAEsCABgABQlrFvEUAJ8AABkAAQkNCaJlAC0AAAAA.',
['孤鸣']='孤鸣风啸:BAAALgADCgEJAQAAAA==.',
['宇智']='宇智波丶辰龙:BAAALgAECgQJBAAAAA==.宇智波丶锦绣:BAAALgAECgQJBAAAAA==.',
['守护']='守护依旧:BAAALgAECgQJAgAAAA==.',
['安安']='安安灭:BAAALgAFFAEJAQAAAA==.',
['宕机']='宕机菠萝头:BAAALgAFFAEJAQABLgAFFAQJCwAZAIsWAA==.',
['定海']='定海神针:BAAALgADCgUJBgAAAA==.',
['定風']='定風波:BAAALgADCgEJAQAAAA==.',
['宝贝']='宝贝菲菲:BAACLgAFFH8KAAIIAAQJbhNsDgAbAQAIAAQJbhNsDgAbAQAuAAQKfyAAAggACAl1G4knANQCAAgACAl1G4knANQCAAAA.',
['宫永']='宫永疾风:BAACLgAFFH8PAAIaAAQJHiBqBACLAQAaAAQJHiBqBACLAQAuAAQKfxcAAhoABwlvIDsUAHMCABoABwlvIDsUAHMCAAAA.',
['寇塔']='寇塔空:BAAALgAECgcJBgABLgAFFAUJBAADAAAAAA==.',
['寶爺']='寶爺:BAAALgAECgIJAgAAAA==.',
['寻渊']='寻渊:BAAALgAFFAEJAQABLgAFFAIJBgAWABkaAA==.',
['寻觅']='寻觅者郡:BAAALgADCgEJAQAAAA==.',
['小哥']='小哥哥:BAAALgAECgIJAgAAAA==.',
['小奶']='小奶龙:BAACLgAFFH8SAAIKAAYJDRN5AgD3AQAKAAYJDRN5AgD3AQAuAAQKfyIAAgoACQmDIpIBAG0DAAoACQmDIpIBAG0DAAAA.',
['小小']='小小巨人:BAAALgAECgIJBAAAAA==.小小雨:BAAALgAECgQJBAAAAA==.小小骚:BAAALgAECgYJDAAAAA==.',
['小岩']='小岩岩:BAAALgAECgQJBAAAAA==.',
['小怪']='小怪兽豪仔:BAAALgAECgEJAQAAAA==.',
['小机']='小机灵鬼儿:BAAALgADCgcJBwAAAA==.',
['小柒']='小柒酱丶:BAAALgAECgMJAwAAAA==.',
['小浅']='小浅笑:BAAALgAECgYJBgAAAA==.',
['小湿']='小湿弟:BAAALgAECgEJAQAAAA==.',
['小狮']='小狮子罓:BAAALgAECgkJCQAAAA==.',
['小王']='小王老师丶:BAAALgAFFAIJAwAAAA==.',
['小白']='小白鸽:BAAALgAECgEJAQAAAA==.',
['小糖']='小糖棒棒:BAAALgAECgEJAQAAAA==.',
['小翻']='小翻:BAAALgAECgEJAgAAAA==.',
['小西']='小西瓜:BAAALgAFFAEJAQAAAA==.',
['小贝']='小贝塔:BAAALgAECgIJAgAAAA==.',
['小雷']='小雷鸥丶:BAAALgAECgQJBQAAAA==.',
['小骚']='小骚啊:BAAALgAECgEJAQAAAA==.',
['小龙']='小龙哥:BAAALgAECgkJCQAAAA==.小龙宝:BAAALgAFFAIJAgAAAA==.小龙宝丿:BAAALgAECgUJAgAAAA==.',
['少女']='少女大喜:BAAALgAFFAIJAgAAAA==.',
['少年']='少年阿宾:BAAALgAECgQJBgAAAA==.',
['尛白']='尛白是真的白:BAAALgAFFAIJAwAAAA==.',
['就你']='就你柿多:BAAALgAFFAQJBAAAAA==.',
['屯儿']='屯儿里的五爺:BAAALgAECgcJBwAAAA==.屯儿里的肆爺:BAAALgAFFAIJBAAAAA==.',
['山前']='山前未相见:BAAALgAECgMJAwAAAA==.',
['巨人']='巨人之眼:BAAALgAECgQJBAAAAA==.',
['差一']='差一点成熟丶:BAAALgAECggJDwABLgAFFAMJBQAQAFcNAA==.',
['已经']='已经很厉害了:BAAALgADCgEJAgAAAA==.',
['巴尔']='巴尔的摩丶:BAAALgAECgEJAQABLgAFFAUJCgARAHUSAA==.',
['布莱']='布莱聘可:BAAALgADCgQJBAAAAA==.',
['布蘭']='布蘭缇什:BAAALgAECgEJAQAAAA==.',
['师兄']='师兄有礼了丶:BAAALgAECgYJEAAAAA==.',
['帕米']='帕米菈:BAAALgAFFAEJAQAAAA==.',
['帝皇']='帝皇暴龍獸:BAAALgAECgYJBgAAAA==.',
['帝陨']='帝陨:BAAALgAECgkJCQAAAA==.',
['帝龙']='帝龙胤:BAAALgAFFAEJAQAAAA==.',
['幸福']='幸福丶回忆:BAAALgAECgcJEAAAAA==.',
['幸运']='幸运星:BAAALgAECgYJBwAAAA==.',
['幻丶']='幻丶葉:BAAALgAECgcJDAAAAA==.',
['幽冥']='幽冥轩栤:BAACLgAFFH8NAAIZAAQJ1h4EBQCBAQAZAAQJ1h4EBQCBAQAuAAQKfxsAAhkACAlsIdQGAB0DABkACAlsIdQGAB0DAAAA.幽冥阎罗:BAAALgADCgMJAwAAAA==.',
['幽夜']='幽夜匿形为隐:BAAALgAECggJAgAAAA==.',
['库昌']='库昌天:BAAALgAECgQJBQAAAA==.',
['库莱']='库莱玛:BAAALgAECgYJCgAAAA==.库莱马:BAAALgAECgkJCgAAAA==.',
['开席']='开席吃肘子:BAAALgAECgQJBQAAAA==.',
['开机']='开机:BAAALgAECgYJBwAAAA==.',
['弗瑞']='弗瑞丶奥萨:BAAALgAECgUJBwAAAA==.弗瑞奥萨酒仙:BAAALgAECgUJBQAAAA==.',
['张凌']='张凌赫:BAACLgAFFH8JAAINAAQJNx6EBwCVAQANAAQJNx6EBwCVAQAuAAQKfxUAAg0ACAmAJbsIAFcDAA0ACAmAJbsIAFcDAAAA.',
['张小']='张小猪萌萌哒:BAAALgAFFAQJBAAAAA==.',
['张摆']='张摆白不摆啦:BAAALgAECgQJBwAAAA==.',
['当街']='当街搂抱抱:BAAALgADCgcJBwABLgAECgUJCQADAAAAAA==.',
['彩虹']='彩虹牛:BAAALgAECgQJCQAAAA==.',
['彻底']='彻底搞不懂:BAAALgADCgMJAwAAAA==.',
['御灵']='御灵子:BAAALgADCgQJBQAAAA==.',
['御风']='御风神行丶:BAAALgAECgYJBAAAAA==.',
['德古']='德古拉之闇:BAAALgADCgEJAQAAAA==.',
['德噜']='德噜伊:BAABLgAFFH8FAAIOAAIJHxgcGACgAAAOAAIJHxgcGACgAAAAAA==.',
['心中']='心中要有光:BAAALgADCgEJAQAAAA==.',
['心声']='心声有否偏差:BAAALgAECgkJCgAAAA==.',
['快乐']='快乐酷宝:BAAALgADCgUJBQAAAA==.',
['念前']='念前:BAAALgAECgcJBwAAAA==.',
['怀惗']='怀惗:BAAALgAECgIJAwAAAA==.',
['怪物']='怪物最讨厌了:BAAALgAECgkJDAAAAA==.',
['总裁']='总裁:BAAALgAECgYJDAAAAA==.',
['恩和']='恩和塔拉:BAAALgAECgQJBAAAAA==.',
['恶魔']='恶魔头子:BAAALgAECgQJBAAAAA==.恶魔的终结者:BAAALgAECgEJAQAAAA==.',
['悠嘻']='悠嘻丶猴:BAAALgAECgcJBwAAAA==.',
['悲恸']='悲恸:BAAALgAECgUJCAAAAA==.',
['情非']='情非得灬已:BAAALgAECgYJBQAAAA==.',
['惩戒']='惩戒骑当奶用:BAACLgAFFH8GAAIbAAMJdB3lAQABAQAbAAMJdB3lAQABAQAuAAQKfxYAAhsABwmVG4gNAO4BABsABwmVG4gNAO4BAAAA.',
['想念']='想念曾经:BAAALgAECgkJCQAAAA==.',
['懒小']='懒小狼丶:BAAALgAFFAIJAwAAAA==.',
['懒懒']='懒懒好好偶:BAAALgADCgIJAgAAAA==.',
['懒猫']='懒猫爱打盹儿:BAAALgAFFAIJAgAAAA==.',
['我兜']='我兜兜里有糖:BAAALgADCgEJAQAAAA==.',
['我吃']='我吃不下啦灬:BAAALgADCgYJBgAAAA==.',
['我喜']='我喜欢吃鱼:BAAALgAECgIJAgAAAA==.',
['我很']='我很强力很棒:BAAALgAECgYJCQAAAA==.',
['我想']='我想看胸毛:BAAALgAECgUJAQAAAA==.',
['我是']='我是从了:BAAALgAECgYJBgAAAA==.',
['我有']='我有糖和门:BAAALgADCgMJAwAAAA==.',
['我爱']='我爱小咖啡:BAAALgAECgEJAQAAAA==.',
['我特']='我特么成龙了:BAAALgAECgIJAgABLgAECgUJDgADAAAAAA==.',
['我能']='我能炫六碗饭:BAACLgAFFH8JAAIIAAMJlROHEgAAAQAIAAMJlROHEgAAAQAuAAQKfxcAAggABwl4GtpwAPIBAAgABwl4GtpwAPIBAAAA.',
['我还']='我还不能死:BAAALgAECgQJBwAAAA==.',
['战将']='战将:BAAALgAFFAEJAQABLgAFFAUJBwAGADEdAA==.',
['战斗']='战斗力五三万:BAAALgAECgUJBwAAAA==.',
['战歌']='战歌嘹亮:BAAALgAECgEJAQAAAA==.',
['战神']='战神瓦:BAAALgAECgMJAwAAAA==.',
['戴面']='戴面具的剑士:BAAALgAECgYJCQAAAA==.戴面纱的琴师:BAAALgAECgEJAQAAAA==.',
['手残']='手残:BAAALgAECgEJAQAAAA==.',
['打小']='打小灬就傲:BAAALgAECgYJDQAAAA==.',
['打我']='打我的脸:BAAALgAECgYJCQAAAA==.',
['扛出']='扛出一片天:BAAALgAFFAEJAgAAAA==.',
['执念']='执念丶:BAAALgAECgEJAQAAAA==.',
['抚菊']='抚菊:BAAALgAECgMJBAAAAA==.',
['报丧']='报丧女妖:BAAALgAECgcJCQAAAA==.报丧女妖丶:BAAALgAECgUJCAAAAA==.',
['报之']='报之以李:BAAALgADCgEJAQAAAA==.',
['抵天']='抵天之臂:BAAALgADCgEJAQAAAA==.',
['拉稀']='拉稀奥:BAAALgAECgYJBgAAAA==.',
['招财']='招财:BAAALgAECgkJCQAAAA==.',
['拾叁']='拾叁妖:BAAALgAECgIJAgAAAA==.拾叁瑛:BAAALgAECgMJAwAAAA==.拾叁花:BAAALgAECgIJAgAAAA==.拾叁霸王花:BAAALgAECgEJAQAAAA==.',
['振小']='振小健:BAAALgAECgYJDgAAAA==.',
['捂头']='捂头骑士:BAAALgAECgYJCQAAAA==.',
['捶你']='捶你后脑勺:BAAALgAECgEJAgAAAA==.',
['排骨']='排骨丝瓜汤:BAAALgAECgcJBwAAAA==.',
['接受']='接受我的祝福:BAAALgAFFAEJAQAAAA==.',
['控制']='控制情绪:BAAALgAECgEJAQAAAA==.',
['握烤']='握烤嫩羊:BAAALgAECgQJCAABLgAFFAMJBgAbAHQdAA==.',
['搓你']='搓你一下:BAAALgAECgMJBgAAAA==.',
['携酒']='携酒踏云行丶:BAACLgAFFH8LAAQFAAQJNwhwDQAwAQAFAAQJWgZwDQAwAQARAAIJ9giBDACDAAAGAAEJQQA9DgAmAAAuAAQKfxoAAwUACAkKGcEqAA0CAAUACAkeFcEqAA0CABEACAmSFdoVALABAAAA.',
['摄政']='摄政王懒羊羊:BAAALgADCgUJBQAAAA==.',
['摩卡']='摩卡阿丶:BAAALgAECgMJAwAAAA==.',
['摩梦']='摩梦:BAAALgADCgEJAQAAAA==.',
['摸鱼']='摸鱼灬:BAAALgAECgEJAgAAAA==.',
['撑着']='撑着油纸伞:BAAALgAFFAEJAgABLgAFFAQJDAAaAF4SAA==.',
['擎天']='擎天丶紅颜:BAABLgAECn8XAAIZAAcJiCLCCwDGAgAZAAcJiCLCCwDGAgAAAA==.',
['擎宇']='擎宇:BAAALgAECgMJAwAAAA==.',
['放部']='放部落咬狗:BAAALgAECgIJAgAAAA==.',
['故人']='故人容颜依旧:BAAALgAECgUJCgAAAA==.',
['斧声']='斧声:BAAALgAFFAMJAwAAAA==.',
['斯黛']='斯黛梅什特:BAAALgADCgEJAQAAAA==.',
['新小']='新小岩五丁目:BAAALgADCgYJBgAAAA==.',
['旋转']='旋转跳跃:BAAALgAECgcJBwAAAA==.',
['无懮']='无懮无虑:BAAALgAECgkJCgABLgAFFAYJAwADAAAAAA==.',
['无敌']='无敌肌肉霸王:BAABLgAFFH8HAAIMAAMJWQ5vFQCVAAAMAAMJWQ5vFQCVAAAAAA==.',
['无聊']='无聊飒:BAAALgAECgcJCwAAAA==.',
['无限']='无限空冥:BAAALgAECgYJBwAAAA==.',
['日初']='日初灬:BAAALgAECgYJBwAAAA==.',
['时长']='时长两年半:BAAALgAECgEJAQAAAA==.',
['旷世']='旷世神奶:BAAALgADCgIJAwAAAA==.',
['明天']='明天晴天:BAAALgAFFAIJBAAAAA==.',
['星星']='星星火:BAAALgAECgEJAQAAAA==.',
['星野']='星野樱:BAAALgAECgYJEgAAAA==.',
['星驱']='星驱者:BAABLgAECn8ZAAIIAAcJcxUYHwBaAQAIAAcJcxUYHwBaAQAAAA==.',
['晓丶']='晓丶冰:BAAALgADCgEJAQAAAA==.',
['晨殇']='晨殇:BAAALgADCgUJBQAAAA==.',
['晶钢']='晶钢铁骨:BAAALgAECgYJBwAAAA==.',
['暗影']='暗影随行丶:BAABLgAECn8ZAAIZAAYJixnLJACxAQAZAAYJixnLJACxAQAAAA==.',
['暮落']='暮落起清风:BAAALgADCgIJAgAAAA==.',
['暴力']='暴力壊寳寳:BAAALgAECgEJAQAAAA==.',
['暴躁']='暴躁奶僧:BAAALgAFFAIJAgAAAA==.暴躁的老少女:BAAALgAECgEJAQAAAA==.',
['暴食']='暴食老舅:BAAALgAECgIJAwAAAA==.',
['曙光']='曙光美女:BAAALgAECgQJBQAAAA==.',
['最爱']='最爱雪琪:BAABLgAECn8gAAIIAAgJMRidVgA1AgAIAAgJMRidVgA1AgABLgAFFAUJAQADAAAAAA==.',
['月使']='月使徒:BAAALgAECgEJAQAAAA==.',
['月落']='月落灬:BAAALgAECgYJBwAAAA==.',
['有德']='有德必有事:BAAALgAECggJCAAAAA==.有德才有得:BAAALgAECgIJAgAAAA==.',
['有点']='有点蒙圈:BAAALgAECgEJAQAAAA==.',
['未灭']='未灭:BAAALgADCgYJBgAAAA==.',
['本间']='本间芽衣子:BAAALgAECgMJAQAAAA==.',
['术大']='术大遭封:BAAALgADCgQJBgAAAA==.',
['朵拉']='朵拉之心:BAABLgAECn8WAAIYAAYJ3h3lJwCwAQAYAAYJ3h3lJwCwAQAAAA==.',
['李亚']='李亚军:BAABLgAFFH8IAAIEAAMJeSb3CQA5AQAEAAMJeSb3CQA5AQAAAA==.',
['村里']='村里一支花:BAAALgADCgYJBgAAAA==.',
['来福']='来福乐:BAAALgAECgYJEAAAAA==.',
['来跟']='来跟我喝一杯:BAAALgAECgYJEAAAAA==.',
['来都']='来都来了哞哞:BAAALgAECgUJCAAAAA==.',
['杨铁']='杨铁柱:BAAALgAECgEJAQAAAA==.',
['杰兰']='杰兰特的台风:BAAALgAECgYJBwAAAA==.',
['杰拉']='杰拉德丶巴特:BAAALgAECgUJBQAAAA==.',
['杲杲']='杲杲龙龙:BAAALgAECgMJAwAAAA==.',
['果妖']='果妖:BAAALgAECgIJAwAAAA==.',
['果小']='果小妖:BAAALgADCgEJAQAAAA==.',
['枫乄']='枫乄:BAAALgADCgEJAQAAAA==.',
['枭申']='枭申克:BAAALgAECgIJAgAAAA==.',
['柳珊']='柳珊桐:BAAALgAECgQJBgAAAA==.',
['栋丶']='栋丶:BAAALgAECgIJAgAAAA==.',
['样猫']='样猫咯个么:BAAALgADCgYJBgAAAA==.',
['核心']='核心橙获得者:BAAALgAECgUJBgAAAA==.',
['梅洛']='梅洛凋零者:BAAALgAECgUJCwAAAA==.',
['梓傩']='梓傩:BAAALgAECgQJBAAAAA==.',
['梦酒']='梦酒欲醉:BAAALgAECgQJBAAAAA==.',
['棒槌']='棒槌捶你:BAAALgAECgYJBwAAAA==.',
['楠汐']='楠汐:BAAALgAECgUJCAABLgAFFAIJAwADAAAAAA==.',
['横行']='横行一把刀:BAABLgAECn8UAAMMAAYJkQ9QHgAVAQAMAAYJkQ9QHgAVAQALAAMJCAbJWACCAAAAAA==.',
['橙昕']='橙昕橙噫:BAAALgAFFAEJAQAAAA==.',
['欧乂']='欧乂皇:BAAALgAECgEJAQAAAA==.',
['欧皇']='欧皇小芙蓉:BAAALgAFFAIJBAAAAA==.欧皇战泰槽德:BAAALgADCgMJAwAAAA==.',
['歌方']='歌方月乃:BAAALgAECgYJDAAAAA==.',
['歘鑠']='歘鑠灬鍅蒒:BAAALgADCgEJAQAAAA==.',
['正义']='正义的黑人:BAAALgAECggJDQAAAA==.',
['此人']='此人绝非扇贝:BAAALgAECgQJBwAAAA==.',
['武僧']='武僧为:BAABLgAFFH8FAAIcAAQJ4Q3eDQAWAQAcAAQJ4Q3eDQAWAQAAAA==.',
['死亡']='死亡的追踪:BAAALgADCgcJBwAAAA==.',
['死神']='死神的请柬:BAAALgADCgEJAQAAAA==.',
['死骑']='死骑丶:BAAALgADCgYJBgAAAA==.',
['残暴']='残暴的大柠檬:BAAALgAECgUJBQAAAA==.残暴的大芒果:BAAALgAECgcJCQAAAA==.',
['残血']='残血灬:BAAALgAECgMJAwAAAA==.',
['毛毛']='毛毛爱踤球:BAAALgAFFAUJAwAAAA==.',
['永恒']='永恒德:BAACLgAFFH8GAAICAAIJIRJ7CACmAAACAAIJIRJ7CACmAAAuAAQKfxkAAgIABgl9JBQYAEkCAAIABgl9JBQYAEkCAAAA.',
['汤老']='汤老师:BAAALgAECgUJBQAAAA==.',
['沈唏']='沈唏唏:BAABLgAFFH8GAAIWAAMJ6w2YDQDJAAAWAAMJ6w2YDQDJAAAAAA==.',
['沉鱼']='沉鱼丨:BAAALgAECgYJCgAAAA==.',
['油炸']='油炸馒头:BAAALgAFFAIJAwAAAA==.油炸鼻葛甲:BAAALgAECgEJAQAAAA==.',
['法神']='法神张三:BAAALgAECgUJBQAAAA==.法神重现江湖:BAAALgAECgEJAQAAAA==.',
['注点']='注点儿意:BAAALgAECgEJAQAAAA==.',
['泰勒']='泰勒:BAABLgAFFH8MAAIdAAUJ/wwUCgBQAQAdAAUJ/wwUCgBQAQAAAA==.',
['泰迪']='泰迪尔:BAAALgAECgcJAQAAAA==.',
['洋洋']='洋洋:BAAALgAFFAQJBAAAAA==.',
['洗剪']='洗剪吹:BAAALgAECgYJCgAAAA==.',
['洛娜']='洛娜丹恩:BAAALgAECgUJCgAAAA==.',
['活字']='活字印刷术:BAAALgAECgUJCAAAAA==.',
['派宝']='派宝妈咪:BAAALgAECgIJAgAAAA==.',
['流光']='流光月影:BAAALgAECgQJCAAAAA==.',
['浅笑']='浅笑伊然:BAAALgAECgYJBwAAAA==.浅笑屹然:BAAALgAFFAEJAQAAAA==.',
['浅酌']='浅酌不解忧愁:BAAALgAFFAUJBAAAAA==.',
['浮夸']='浮夸丶柚子:BAAALgAECgQJBgAAAA==.',
['海碧']='海碧凌凌伍:BAAALgAECgEJAQAAAA==.',
['海鸟']='海鸟和鱼相爱:BAAALgAECgcJEAAAAA==.',
['淳于']='淳于鸿畴丶:BAAALgAFFAIJAgAAAA==.',
['清水']='清水湾仔:BAAALgAECgEJAQAAAA==.',
['渊眼']='渊眼白龙:BAAALgAECgcJCwABLgAFFAQJDwAYAHghAA==.',
['温柔']='温柔丶好几刀:BAAALgAECgYJCwAAAA==.',
['滑蛋']='滑蛋雪菜粥:BAAALgAECgEJAQAAAA==.',
['满电']='满电皮卡丘:BAAALgAFFAEJAQAAAA==.',
['漂移']='漂移:BAAALgAECgQJBwAAAA==.',
['漆黑']='漆黑罒烈焰使:BAAALgAECgMJAwABLgAECgQJBgADAAAAAA==.',
['激萌']='激萌的汐羽:BAAALgAECgUJBQAAAA==.',
['濑由']='濑由衣:BAAALgAECgEJAQAAAA==.',
['火之']='火之开心:BAAALgAECgEJAQAAAA==.',
['火喵']='火喵喵:BAAALgADCggJEAAAAA==.',
['灬七']='灬七夜丨丶:BAAALgAECgUJBAAAAA==.',
['灬咒']='灬咒逐灬:BAAALgAECgYJCQAAAA==.',
['灬小']='灬小红袄灬:BAABLgAFFH8FAAIEAAUJIwqrBQCBAQAEAAUJIwqrBQCBAQAAAA==.',
['灬左']='灬左慈:BAAALgADCgIJAgAAAA==.',
['灬执']='灬执笔逝流觞:BAAALgAECgQJBAABLgAFFAUJEAAIAJURAA==.',
['灵壹']='灵壹:BAAALgAECgQJBwAAAA==.',
['灵鸢']='灵鸢:BAAALgAFFAMJBAAAAA==.',
['灾难']='灾难审判者:BAAALgAECgQJBQAAAA==.',
['炫炫']='炫炫的调调:BAAALgAECgMJBAAAAA==.',
['炼狱']='炼狱恶天使:BAAALgAECgYJBgAAAA==.炼狱战神:BAAALgADCgEJAQAAAA==.炼狱皓望者:BAAALgADCgEJAQAAAA==.',
['烟丶']='烟丶葉:BAAALgAECgYJDwAAAA==.',
['烬墟']='烬墟:BAAALgAECgQJBQABLgAECgcJDwADAAAAAA==.',
['無双']='無双:BAAALgAECgcJDwAAAA==.',
['煌飞']='煌飞鸿:BAAALgAECgIJAgAAAA==.',
['熊丨']='熊丨翎羽:BAAALgAECgUJBQABLgAFFAUJEQAUAOIjAA==.',
['熊猫']='熊猫也笑了:BAAALgAECgEJBQAAAA==.熊猫滚呀滚:BAAALgADCgYJBgAAAA==.',
['熊逗']='熊逗逗:BAAALgAECgEJAQAAAA==.',
['燈火']='燈火阑珊:BAAALgAECgEJAgAAAA==.',
['爱丶']='爱丶筱妮:BAAALgAECgUJBgAAAA==.',
['爱可']='爱可抵流言:BAAALgAECgYJCgAAAA==.',
['爱吃']='爱吃哥的萨:BAAALgADCgUJBQAAAA==.',
['爱是']='爱是彼岸的花:BAAALgADCgUJBQAAAA==.',
['爲所']='爲所欲爲:BAAALgAECgQJBAAAAA==.',
['牛奶']='牛奶多多:BAAALgADCgEJAQAAAA==.',
['牛牛']='牛牛小骑:BAAALgAFFAIJAgAAAA==.',
['牛突']='牛突猛进:BAAALgAFFAEJAQAAAA==.',
['牛飘']='牛飘飘:BAAALgAECgEJAQAAAA==.',
['牧牧']='牧牧三三:BAACLgAFFH8FAAIHAAMJOh0pDAAUAQAHAAMJOh0pDAAUAQAuAAQKfxkAAwcABgk2JIAMAHACAAcABgnUI4AMAHACABgABAkXF05MAAcBAAAA.',
['牧羊']='牧羊少年:BAAALgAECgcJBwAAAA==.',
['物理']='物理学剑仙:BAAALgAECgQJBQAAAA==.',
['犀牛']='犀牛勇士:BAAALgAECgEJAgAAAA==.',
['犯罪']='犯罪领域:BAAALgADCgcJCAAAAA==.',
['狂野']='狂野丶怒风:BAAALgAECgcJCwABLgADCgcJBwADAAAAAA==.狂野丶猎影:BAACLgAFFH8JAAIQAAMJsiX0BQBDAQAQAAMJsiX0BQBDAQAuAAQKfxYAAxAABwm9GnIjADECABAABwm9GnIjADECABQAAQnjD9WIADIAAAAA.',
['狂魔']='狂魔戰天下:BAAALgAECgMJAwAAAA==.',
['狐言']='狐言乱语丶:BAAALgAECgcJDwAAAA==.',
['狐说']='狐说灬:BAAALgAECgQJBAAAAA==.',
['狼嵜']='狼嵜光:BAAALgADCgEJAQAAAA==.',
['猎火']='猎火朝天:BAAALgADCgUJBQAAAA==.',
['猫祖']='猫祖:BAAALgAECgQJBAAAAA==.',
['猫野']='猫野贼猫:BAAALgADCgIJAgAAAA==.',
['玉关']='玉关西丶:BAAALgADCgEJAQAAAA==.',
['玉树']='玉树:BAACLgAFFH8HAAINAAMJfRTQLADoAAANAAMJfRTQLADoAAAuAAQKfxoAAg0ABwmWFz1YAOkBAA0ABwmWFz1YAOkBAAAA.',
['玉虚']='玉虚宫一姐:BAABLgAFFH8FAAIIAAQJoRTVHABYAQAIAAQJoRTVHABYAQAAAA==.',
['玥弦']='玥弦丶琳儿:BAAALgAECgUJBQAAAA==.',
['玩的']='玩的就是信仰:BAAALgAECgkJBQABLgAFFAUJBAADAAAAAA==.',
['玫瑰']='玫瑰赠予石榴:BAAALgAECgQJBAAAAA==.',
['现状']='现状毁灭:BAAALgAECgYJCAAAAA==.',
['玲怡']='玲怡:BAAALgAECgQJBQAAAA==.',
['珠泪']='珠泪哀歌:BAACLgAFFH8TAAQeAAUJcR8/AAByAQAfAAQJex0pAQCKAQAdAAQJxx0eBgB+AQAeAAQJ2xU/AAByAQAuAAQKfyQABB0ACQmVIqIKAOgCAB0ACAnWI6IKAOgCAB8ABwm/GxAEAHUCAB4ABAk+IR8CACwBAAAA.',
['理想']='理想三旬丶:BAAALgAECgYJCAAAAA==.',
['琉山']='琉山桐:BAAALgAECgQJBwAAAA==.',
['瑞豊']='瑞豊圣皇:BAAALgADCggJCAAAAA==.',
['瓜学']='瓜学派猎魔人:BAAALgAFFAIJAgAAAA==.',
['甄姬']='甄姬乱舞:BAAALgADCgYJBgAAAA==.',
['甘拜']='甘拜下风:BAAALgAECgcJBQAAAA==.',
['甜蜜']='甜蜜:BAAALgAECggJCAAAAA==.',
['生前']='生前很炫酷:BAAALgAECgQJBgAAAA==.',
['疯风']='疯风峰:BAAALgAECgYJAgABLgAECgkJDQADAAAAAA==.',
['瘸子']='瘸子:BAAALgAFFAMJAwAAAA==.',
['白上']='白上白亚:BAAALgAECgQJBAABLgAFFAQJDwAaAB4gAA==.',
['白发']='白发黎叔:BAAALgAECgMJAwAAAA==.',
['白天']='白天不叫:BAAALgADCgEJAgAAAA==.白天叫:BAAALgADCgEJAQAAAA==.',
['白奶']='白奶:BAAALgAFFAEJAQAAAA==.',
['白娅']='白娅:BAAALgAECgMJAQAAAA==.',
['白灬']='白灬羊:BAAALgAECgEJAgAAAA==.',
['白狐']='白狐兒脸:BAAALgAFFAEJAQAAAA==.',
['白羊']='白羊捏:BAAALgAECgMJAwAAAA==.',
['白老']='白老板:BAAALgAFFAIJBAAAAA==.',
['白袍']='白袍小将薛礼:BAAALgADCgYJCwAAAA==.',
['百射']='百射中梦想:BAABLgAECn8XAAMQAAcJcxdqCgDCAQAQAAcJcxdqCgDCAQAUAAUJhAh/WADkAAAAAA==.',
['皮豆']='皮豆翻动势力:BAAALgADCgQJBAAAAA==.',
['相逢']='相逢已陌路:BAAALgAECgMJAwAAAA==.',
['睿智']='睿智的六六:BAAALgAECgEJAgAAAA==.',
['瞬羽']='瞬羽无情:BAAALgADCgEJAQAAAA==.瞬羽树模:BAAALgADCgYJBgAAAA==.瞬羽楠叶:BAAALgADCgEJAQAAAA==.',
['矢泽']='矢泽兴兴:BAAALgAFFAEJAQAAAA==.',
['石榴']='石榴儿丶:BAACLgAFFH8IAAIIAAMJBxccKAATAQAIAAMJBxccKAATAQAuAAQKfxoAAggACAlBHLgvALMCAAgACAlBHLgvALMCAAAA.',
['破晓']='破晓裁决者:BAAALgAECgUJBQAAAA==.',
['磊灬']='磊灬哥:BAAALgAECgEJAQAAAA==.',
['磊爷']='磊爷:BAAALgADCggJCAAAAA==.',
['社徽']='社徽住一浩:BAAALgAECgQJBAAAAA==.',
['祖雅']='祖雅:BAAALgAECgEJAQAAAA==.',
['神州']='神州七星:BAAALgAECgIJAwAAAA==.',
['神戳']='神戳戳:BAAALgAECgIJAgAAAA==.',
['神秘']='神秘男丨:BAAALgAECgYJBAAAAA==.',
['神隐']='神隐于白昼:BAAALgAFFAQJAQAAAA==.',
['福乐']='福乐真牛:BAABLgAECn8ZAAMRAAgJTxd7GACQAQARAAcJPhZ7GACQAQAFAAUJPhpvUgBgAQAAAA==.',
['离优']='离优:BAABLgAFFH8HAAINAAQJMglDIQATAQANAAQJMglDIQATAQAAAA==.',
['程一']='程一鸣:BAAALgAFFAEJAQAAAA==.',
['稻秋']='稻秋:BAAALgAECgEJAQABLgAECgEJAQADAAAAAA==.',
['笑看']='笑看丨风云:BAAALgAECgYJEQAAAA==.',
['笨萌']='笨萌笨萌滴:BAAALgADCgEJAQAAAA==.',
['筱筱']='筱筱同学:BAAALgAECgEJAgAAAA==.',
['算鸟']='算鸟:BAAALgAECgQJBAAAAA==.',
['米亚']='米亚轻寒:BAAALgAECgcJBwAAAA==.',
['粉红']='粉红胖胖:BAAALgAECgUJBQAAAA==.',
['粉色']='粉色圣光:BAAALgAECgUJCgAAAA==.',
['粗熊']='粗熊:BAAALgAECgYJBgABLgAFFAUJBAADAAAAAA==.',
['糀蕾']='糀蕾:BAAALgAECgEJAQAAAA==.',
['糕手']='糕手丶:BAAALgAECgUJBwAAAA==.',
['糯米']='糯米桑:BAAALgAECgIJAgAAAA==.',
['紅手']='紅手:BAAALgAECgEJAQAAAA==.',
['素帘']='素帘丶霁月:BAAALgADCgEJAQAAAA==.',
['紫梦']='紫梦悠扬:BAAALgAECgQJBAAAAA==.',
['紫禁']='紫禁城牛爷:BAAALgAECgYJEQAAAA==.',
['紫陌']='紫陌:BAAALgADCgMJAwAAAA==.',
['累累']='累累的:BAAALgAECgQJBgAAAA==.',
['红柚']='红柚:BAAALgAECgYJBgAAAA==.',
['红烧']='红烧牛筋:BAAALgAECgYJCgAAAA==.',
['红莲']='红莲天舞:BAAALgAECgMJBgAAAA==.红莲魔尊:BAAALgAECgMJAwAAAA==.',
['红颜']='红颜为谁妆:BAAALgAECgIJAgAAAA==.',
['红骑']='红骑士:BAAALgAFFAIJAgAAAA==.',
['纯子']='纯子的我:BAAALgAECgYJDAAAAA==.',
['终极']='终极小奶爸:BAAALgAECgYJDAAAAA==.',
['给我']='给我一个吻:BAAALgAECgkJAgAAAA==.',
['给蓝']='给蓝胖俩面子:BAAALgAECgYJCgAAAA==.',
['统一']='统一世界:BAAALgAECgQJCwAAAA==.',
['绿玩']='绿玩小技师:BAAALgAECgYJBgAAAA==.',
['缇玲']='缇玲:BAABLgAFFH8FAAIBAAUJ8xOqBACmAQABAAUJ8xOqBACmAQAAAA==.',
['缥缈']='缥缈小帆板:BAAALgADCgUJBQAAAA==.',
['缺牙']='缺牙怪:BAAALgAECgIJAwAAAA==.',
['罖魂']='罖魂丨幽灵:BAAALgAECgMJAwAAAA==.罖魂丨银莲花:BAAALgAECgYJBgAAAA==.',
['羅夏']='羅夏丶:BAAALgAECgYJDgAAAA==.',
['羊小']='羊小骚:BAAALgAECgUJBwAAAA==.',
['美丽']='美丽的莉:BAAALgAECgIJAwAAAA==.',
['美美']='美美蕴:BAAALgADCgQJBAAAAA==.',
['翔鹤']='翔鹤:BAAALgADCgcJBwAAAA==.',
['老唐']='老唐:BAAALgAECgIJAwAAAA==.',
['老奶']='老奶牛:BAAALgAECgQJBAAAAA==.',
['老边']='老边战:BAAALgAECgIJAgAAAA==.老边术:BAAALgAECgIJAgAAAA==.',
['而已']='而已赫然:BAAALgAECgQJBAAAAA==.',
['耐法']='耐法莉安:BAAALgAECgUJBQAAAA==.',
['聖光']='聖光優優:BAAALgADCgYJBgAAAA==.',
['聚散']='聚散都是缘:BAAALgAECgYJBgAAAA==.',
['肆意']='肆意寒暄:BAAALgAECgYJBgAAAA==.',
['肚皮']='肚皮滚滚:BAAALgAECgcJBgAAAA==.',
['胖乎']='胖乎乎俩大眼:BAAALgAECgEJAQAAAA==.',
['自备']='自备双蛋刀:BAAALgAECgEJAQAAAA==.',
['至尊']='至尊虎小宝:BAAALgAECgMJAwAAAA==.',
['舞于']='舞于暗影:BAAALgAECgQJBgAAAA==.',
['艾奇']='艾奇多娜咖:BAABLgAFFH8MAAIMAAUJnQwdDQBoAQAMAAUJnQwdDQBoAQAAAA==.',
['芈虾']='芈虾米:BAAALgADCgUJBQAAAA==.',
['芝士']='芝士汉堡丶:BAACLgAFFH8TAAQJAAUJmRMVCQBdAQAJAAUJlA8VCQBdAQAKAAIJVQQ4EwCSAAAgAAEJLhYCCQBYAAAuAAQKfx8ABAkACAmlHZERAGECAAkACAkqGpERAGECACAABgk8Hr4RAMQBAAoABAkCDVcxAOUAAAAA.',
['花丶']='花丶旗:BAAALgAFFAIJAwAAAA==.',
['花开']='花开花瓣飞:BAAALgAECgMJAwAAAA==.',
['花漓']='花漓丶:BAAALgAECgUJBQABLgAFFAYJDgAGANUkAA==.',
['花祭']='花祭泪:BAAALgADCgEJAQAAAA==.',
['花開']='花開如常丶:BAAALgAECgcJBwAAAA==.',
['苍月']='苍月天明:BAAALgAECgEJAQAAAA==.',
['苍穹']='苍穹舞者:BAAALgADCgEJAQAAAA==.',
['若惜']='若惜丶默:BAAALgAECgEJAQAAAA==.',
['英语']='英语小组长:BAAALgADCgQJBQAAAA==.',
['英雄']='英雄侠:BAAALgAECgQJBAAAAA==.',
['苹果']='苹果德:BAABLgAFFH8FAAICAAMJ2gpXBgDvAAACAAMJ2gpXBgDvAAAAAA==.苹果德一:BAABLgAFFH8FAAICAAMJSA0sBgDzAAACAAMJSA0sBgDzAAAAAA==.苹果德七:BAAALgAFFAMJAwAAAA==.苹果德三:BAAALgAFFAQJBAAAAA==.苹果德二:BAABLgAFFH8FAAICAAQJPg3nDwDjAAACAAQJPg3nDwDjAAAAAA==.苹果德五:BAAALgAFFAQJBAAAAA==.苹果德八:BAAALgAFFAQJBAAAAA==.苹果德六:BAAALgAFFAIJAgAAAA==.',
['茉莉']='茉莉丶艾迪迪:BAAALgADCgUJBQAAAA==.',
['茶树']='茶树菇丶:BAAALgAECgMJAwAAAA==.',
['荆棘']='荆棘:BAAALgADCgEJAQAAAA==.',
['荒野']='荒野狩猎者:BAAALgAECgUJBQAAAA==.',
['荔枝']='荔枝打酱油:BAAALgAECgIJAwAAAA==.',
['荟根']='荟根:BAAALgAFFAEJAQAAAA==.',
['莫小']='莫小牧:BAAALgAFFAMJAwAAAA==.',
['莫晓']='莫晓龙人:BAAALgAECgYJCgABLgAFFAMJAwADAAAAAA==.',
['菊花']='菊花一朵朵:BAAALgAECgEJAQAAAA==.',
['菜拉']='菜拉:BAAALgAECgQJBAAAAA==.',
['菟芓']='菟芓:BAAALgAECgcJCAAAAA==.',
['萌萌']='萌萌丿德:BAAALgAECgUJDgAAAA==.萌萌哒瑞萌萌:BAAALgAECgEJAQAAAA==.萌萌子:BAAALgADCgMJAwAAAA==.萌萌滴香菜:BAACLgAFFH8PAAIIAAQJrSKGAwCMAQAIAAQJrSKGAwCMAQAuAAQKfxYAAggABgkbIuNmAAkCAAgABgkbIuNmAAkCAAAA.萌萌的飞起:BAAALgADCgUJBQAAAA==.',
['萨拉']='萨拉布布:BAAALgADCgUJCAAAAA==.',
['萨滿']='萨滿祭司:BAAALgAFFAIJBAAAAA==.',
['落坨']='落坨丶翔子:BAAALgAECgUJBAAAAA==.',
['落幕']='落幕的残殇丶:BAABLgAECn8YAAIBAAgJyBrSOwA1AgABAAgJyBrSOwA1AgAAAA==.',
['蒋某']='蒋某人:BAAALgAECgcJBwAAAA==.',
['蒙牛']='蒙牛伊利蛋:BAAALgADCgMJAwAAAA==.',
['蒾夨']='蒾夨蔠點:BAAALgAECgYJCAAAAA==.',
['蓝色']='蓝色大宝贝:BAAALgAFFAIJBAAAAA==.',
['蕯鲁']='蕯鲁法尓丷:BAAALgAECgcJDAAAAA==.',
['薇恩']='薇恩的锋芒:BAAALgAECgYJCQAAAA==.',
['蘸糖']='蘸糖垫塔:BAAALgAECgUJCgAAAA==.',
['蚩吻']='蚩吻:BAAALgADCgYJBgAAAA==.',
['蛋蛋']='蛋蛋骑士:BAAALgAECgMJBgAAAA==.',
['蛮吉']='蛮吉丶:BAAALgAECgUJBgAAAA==.',
['蜜桃']='蜜桃潇潇:BAAALgAECgEJAgAAAA==.',
['血树']='血树残株:BAAALgAECgYJEQAAAA==.',
['血漂']='血漂亮:BAAALgAECgUJBQAAAA==.',
['裁决']='裁决骑士:BAAALgAFFAEJAQAAAA==.',
['裴淳']='裴淳华:BAAALgAECgYJBwAAAA==.',
['裴铮']='裴铮:BAAALgAECgEJAQAAAA==.',
['西昌']='西昌邛海畔:BAAALgAECgUJBQAAAA==.',
['西柚']='西柚益力多:BAAALgAECgEJAQAAAA==.',
['西西']='西西可哩丶:BAAALgADCgIJAgAAAA==.',
['要不']='要不咱报警吧:BAAALgAECgIJAgABLgAFFAUJBgAIABoKAA==.',
['要闹']='要闹哪样啊:BAAALgAECgEJAgAAAA==.',
['试丶']='试丶玩帐号:BAAALgAECgEJAQAAAA==.',
['说甚']='说甚龙争虎斗:BAAALgAECggJEgAAAA==.',
['诺珂']='诺珂提斯:BAAALgAECgcJEwAAAA==.',
['豺狼']='豺狼的日子:BAAALgAECgQJCQAAAA==.',
['貔貅']='貔貅阳:BAAALgAECgIJAwAAAA==.',
['质体']='质体细胞:BAAALgAECgEJAQAAAA==.',
['质疑']='质疑理解成为:BAABLgAFFH8GAAIBAAMJ3BNsEwALAQABAAMJ3BNsEwALAQAAAA==.',
['贪念']='贪念之意:BAAALgAECgEJAQAAAA==.',
['费尔']='费尔尼科:BAAALgADCgEJAQAAAA==.',
['赵先']='赵先生丶:BAAALgAECgYJCAABLgAFFAYJBgAgAAkSAA==.',
['超级']='超级无敌小猫:BAAALgADCgUJBQAAAA==.',
['踏万']='踏万千星河:BAAALgAECgcJDQAAAA==.',
['边缘']='边缘蔷薇:BAAALgAECgQJBAAAAA==.',
['过期']='过期的白开水:BAAALgAECgUJCAABLgAFFAYJEwABAMggAA==.',
['这都']='这都是毛皮:BAAALgADCgUJBgAAAA==.',
['迷你']='迷你兜:BAAALgAECgUJCgAAAA==.',
['迷失']='迷失的暗猫:BAAALgADCgEJAQABLgAECgQJBgADAAAAAA==.',
['追龍']='追龍:BAAALgAECgIJAQAAAA==.',
['送你']='送你一只尾巴:BAAALgAECgYJBgAAAA==.',
['选购']='选购:BAAALgAECgQJBAAAAA==.',
['逍遥']='逍遥风行侠:BAAALgAECgMJBQAAAA==.',
['逐風']='逐風:BAABLgAECn8ZAAMXAAcJrxxnCwAbAgAXAAcJrxxnCwAbAgAUAAQJFgYpaQCZAAAAAA==.',
['逗牛']='逗牛:BAAALgAECgQJBgAAAA==.',
['逸景']='逸景丶丶:BAAALgADCgcJDAAAAA==.',
['邀月']='邀月众人醉:BAAALgAECgMJAwAAAA==.',
['邪修']='邪修道法:BAAALgADCgcJBwAAAA==.',
['邪冰']='邪冰:BAAALgAECgYJCgAAAA==.',
['邪德']='邪德:BAAALgADCgIJAgAAAA==.',
['邪恶']='邪恶小闻子:BAAALgAFFAIJAgAAAA==.邪恶魔龙:BAAALgAECgEJAQABLgAFFAEJAQADAAAAAA==.',
['邪能']='邪能轰炸机:BAAALgAECgIJAwAAAA==.',
['邱哥']='邱哥:BAAALgAECgEJAQAAAA==.',
['酒酒']='酒酒丸:BAAALgAECgEJAQAAAA==.',
['酒鬼']='酒鬼酒:BAAALgADCgUJBQAAAA==.',
['酱油']='酱油必须打:BAAALgAECgQJBAAAAA==.酱油茉莉:BAAALgAECgEJAQAAAA==.',
['醉咕']='醉咕丶:BAAALgAECgEJAQAAAA==.',
['醉眼']='醉眼看人生:BAAALgAECgEJAQAAAA==.',
['野原']='野原广志:BAAALgAECgUJDgAAAA==.',
['钢炮']='钢炮熊叔:BAAALgAECgMJAwAAAA==.',
['铁锤']='铁锤锤你头:BAAALgAECgMJAwAAAA==.',
['银之']='银之匙:BAABLgAECn8XAAMCAAgJKh0jDQDGAgACAAgJKh0jDQDGAgAOAAEJ5xiuwwBBAAAAAA==.',
['锦衣']='锦衣卫丿墓尸:BAAALgAECgEJAQAAAA==.锦衣卫丿晨曦:BAAALgAFFAEJAQAAAA==.锦衣卫丿胡二:BAAALgAECgYJCgAAAA==.锦衣卫丿雨泪:BAAALgAECgEJAQAAAA==.锦衣卫丿鬼魅:BAAALgAECgMJAwAAAA==.',
['闪灵']='闪灵贝贝:BAAALgAECgYJBAABLgAFFAUJBQAhAKQVAA==.',
['闪电']='闪电喵:BAACLgAFFH8GAAMaAAIJLR5bFAC4AAAaAAIJLR5bFAC4AAAiAAEJxwFsBwBDAAAuAAQKfyMAAhoACQmJHcMFABYDABoACQmJHcMFABYDAAAA.闪电蛇形跑法:BAAALgAECgQJBgABLgAECgUJDgADAAAAAA==.',
['阡陌']='阡陌丶柒汐:BAAALgAFFAEJAQAAAA==.',
['阿克']='阿克熊德:BAAALgAECgEJAQAAAA==.',
['阿兰']='阿兰娜:BAAALgADCgIJAgAAAA==.',
['阿凡']='阿凡萨:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔法瑞思:BAABLgAFFH8HAAIJAAQJrwzHDAAzAQAJAAQJrwzHDAAzAQAAAA==.',
['阿猹']='阿猹:BAABLgAECn8bAAIRAAgJZAeEIwAiAQARAAgJZAeEIwAiAQAAAA==.',
['陈默']='陈默寡言丶:BAAALgAECgYJCAAAAA==.',
['陌上']='陌上花已开:BAAALgAECgcJEAAAAA==.',
['随便']='随便玩玩得了:BAAALgAECgcJDQAAAA==.',
['随风']='随风灬而逝:BAAALgADCgUJBQAAAA==.',
['雅丹']='雅丹城的凤凰:BAAALgAECgMJAwAAAA==.',
['雨天']='雨天不下雨:BAAALgADCgMJAwAAAA==.',
['雪夜']='雪夜迭香:BAAALgADCgMJAwAAAA==.',
['雪舞']='雪舞水寒:BAAALgAECgYJDgAAAA==.',
['零帧']='零帧出手:BAAALgAFFAIJAgAAAA==.',
['雷军']='雷军儿:BAAALgAECgYJBgAAAA==.',
['雷欧']='雷欧娜:BAAALgAECgIJAwAAAA==.',
['雷雳']='雷雳如一:BAAALgAECgQJBgAAAA==.',
['雾雨']='雾雨爱丽莎:BAAALgAECgMJAwAAAA==.',
['霖霖']='霖霖的调调:BAAALgAECgMJAgAAAA==.',
['青草']='青草味的牛牛:BAAALgAECgEJAQAAAA==.',
['青锋']='青锋:BAAALgAECgIJAgAAAA==.',
['青青']='青青子衿恩:BAAALgADCgcJDQAAAA==.',
['靡幽']='靡幽:BAAALgAECgQJBgAAAA==.',
['颂仁']='颂仁头丶:BAAALgADCgcJBwAAAA==.',
['颜颜']='颜颜嘻嘻:BAAALgAFFAIJAwAAAA==.',
['风无']='风无为:BAAALgAECgkJAgAAAA==.',
['风暴']='风暴烈桶:BAAALgADCgUJBQAAAA==.',
['风清']='风清似云淡:BAAALgAECgQJBAAAAA==.',
['风游']='风游京:BAAALgAECgUJBQAAAA==.',
['风骤']='风骤:BAAALgAECgQJBgAAAA==.',
['飘渺']='飘渺孤鸿影:BAAALgAECgEJAgAAAA==.',
['飘绫']='飘绫落叶:BAAALgAECgcJCQAAAA==.',
['飘落']='飘落灬朦胧:BAAALgAECgEJAQAAAA==.飘落灬毕姥爷:BAAALgAECgEJAQAAAA==.',
['飞天']='飞天小超:BAAALgAECgEJAQAAAA==.飞天神姬:BAAALgAECgMJBgAAAA==.',
['飞起']='飞起的小象:BAAALgAECgYJCAAAAA==.',
['飞鸟']='飞鸟马时丶:BAACLgAFFH8HAAMXAAMJcxKeAgAGAQAXAAMJFBGeAgAGAQAQAAIJ2QX5GgCYAAAuAAQKfxYAAhcABgnoHuoMAPwBABcABgnoHuoMAPwBAAAA.',
['骄傲']='骄傲:BAAALgAECggJDAAAAA==.',
['鬼滅']='鬼滅之刃:BAAALgAECgEJAQAAAA==.',
['鬼骑']='鬼骑:BAAALgADCgEJAQAAAA==.',
['魅力']='魅力的精灵:BAAALgAFFAEJAgAAAA==.',
['魅影']='魅影殇魂:BAAALgAECgEJAQAAAA==.',
['魔法']='魔法小水滴:BAAALgAECgQJBQAAAA==.',
['魔王']='魔王丨啵啵:BAAALgADCgYJBgAAAA==.',
['魔礼']='魔礼青:BAAALgAFFAQJBAAAAA==.',
['魚魚']='魚魚:BAAALgADCgEJAQAAAA==.',
['鱼潇']='鱼潇潇:BAABLgAFFH8GAAIIAAMJzBYwEgACAQAIAAMJzBYwEgACAQAAAA==.',
['鸦鸦']='鸦鸦:BAAALgAECgEJAQAAAA==.',
['鸽子']='鸽子炖番茄:BAAALgADCgEJAQAAAA==.',
['麻辣']='麻辣翅尖:BAAALgAECgEJAQAAAA==.',
['黄昏']='黄昏十一号丶:BAAALgAECgcJDQAAAA==.黄昏十三号丶:BAAALgAECgcJDQAAAA==.',
['黎明']='黎明之光:BAAALgADCgcJCAAAAA==.',
['黑手']='黑手转职:BAACLgAFFH8OAAIcAAQJZBQ+AwBPAQAcAAQJZBQ+AwBPAQAuAAQKfxoAAhwABgl4GeEyAIUBABwABgl4GeEyAIUBAAAA.',
['黑暗']='黑暗大领主:BAAALgAECgEJAQAAAA==.黑暗骑士丶:BAABLgAFFH8MAAIaAAQJXhIcCgAzAQAaAAQJXhIcCgAzAQAAAA==.',
['黑猫']='黑猫丶:BAAALgAECgIJAgAAAA==.',
['黑锋']='黑锋饲养员:BAAALgAECgQJBwAAAA==.',
['齐湿']='齐湿父:BAAALgAECgQJBQAAAA==.',
['龍訡']='龍訡:BAAALgADCgIJAgAAAA==.',
['龙卵']='龙卵尔:BAAALgAECgYJDwAAAA==.',
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
