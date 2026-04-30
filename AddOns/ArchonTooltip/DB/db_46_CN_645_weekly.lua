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

local lookup = {'Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Hunter-BeastMastery','DeathKnight-Unholy','Druid-Restoration','Mage-Frost','Warrior-Fury','Monk-Brewmaster','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Devourer','Priest-Shadow','Priest-Discipline','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Blood','Mage-Fire','DemonHunter-Vengeance','Hunter-Marksmanship','Evoker-Devastation','Evoker-Augmentation','Shaman-Restoration','Paladin-Holy','Paladin-Protection','Druid-Balance','Paladin-Retribution','Shaman-Elemental','Warlock-Affliction','Druid-Guardian','Evoker-Preservation','Priest-Holy',}
local provider = {region='CN',realm='奥蕾莉亚',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Albemuth:BAACLgAFFH8SAAMBAAUJHiRoCQDBAAABAAMJESBoCQDBAAACAAMJ/iEAAAAAAAAuAAQKfxYAAwIACQmeI5QCAJ0DAAIACQmEI5QCAJ0DAAEABgmLIgkLAA8CAAAA.Alicia:BAAALgAECgEJAQABLgAECgYJCQADAAAAAA==.Alphal:BAAALgAECgEJAQAAAA==.',
Am='Amastacia:BAAALgAFFAEJAgAAAA==.',
An='Anwaltt:BAAALgAECgEJAQAAAA==.',
Ar='Arniwarrior:BAAALgAECgUJBwAAAA==.',
As='Ashara:BAAALgAECgYJCAAAAA==.',
Au='Audrey:BAAALgAECgIJAgAAAA==.',
Bb='Bbxc:BAAALgADCgMJAwAAAA==.',
Bi='Bisu:BAAALgAECgEJAQAAAA==.',
Bl='Blue:BAAALgAECgcJBAAAAA==.',
Ca='Caicaid:BAAALgAECgUJBQAAAA==.',
Ch='Chip:BAAALgAECgYJCwAAAA==.Christina:BAAALgAFFAIJAwAAAA==.',
Ck='Ckw:BAABLgAECn8aAAIEAAgJihoKGwBlAgAEAAgJihoKGwBlAgAAAA==.',
Cm='Cmgs:BAAALgAECgIJAgAAAA==.',
Cr='Cristian:BAAALgAECgEJAQAAAA==.',
De='Deatheriaa:BAABLgAFFH8KAAIFAAMJHhc0PwChAAAFAAMJHhc0PwChAAAAAA==.Demonsoulxd:BAABLgAFFH8JAAIGAAQJ9SJgBACZAQAGAAQJ9SJgBACZAQAAAA==.',
Di='Dinosaurhurt:BAAALgAECgYJBgAAAA==.',
Do='Doucha:BAAALgADCgIJAgAAAA==.',
El='Electlover:BAAALgAFFAIJAwAAAA==.',
Es='Eshliah:BAAALgAECgcJBQAAAA==.',
Fa='Fanfan:BAAALgAECgUJCgAAAA==.',
Fi='Firerage:BAAALgAECgUJCAAAAA==.Fission:BAAALgAECgMJAwAAAA==.',
Go='Goulls:BAAALgAECgUJBQAAAA==.',
Gr='Grancy:BAAALgAECgEJAQAAAA==.',
Gu='Guihui:BAABLgAFFH8MAAIHAAQJYCEjEQCMAQAHAAQJYCEjEQCMAQAAAA==.',
Hy='Hyperion:BAAALgAFFAIJBAAAAA==.',
Ic='Icecrystal:BAAALgAFFAIJAgAAAA==.Icehunt:BAAALgADCgYJBgAAAA==.Iceoracle:BAAALgADCgEJAQAAAA==.Icephy:BAAALgADCgcJBwAAAA==.',
Ir='Iris:BAAALgAECgIJAQAAAA==.',
Ka='Kaslana:BAAALgAFFAEJAQAAAA==.',
Kb='Kbz:BAABLgAFFH8HAAIIAAMJ2xxPDgAgAQAIAAMJ2xxPDgAgAQAAAA==.',
Ke='Keder:BAAALgADCgMJAwAAAA==.',
Ko='Kongfirst:BAAALgAFFAEJAQAAAA==.Kongfu:BAAALgAECgYJCgAAAA==.Kotete:BAAALgAECgMJAQABLgAFFAUJEAAHAFIlAA==.',
La='Lapoopu:BAAALgAECgYJBwAAAA==.',
Li='Lich:BAAALgAECgcJBAAAAA==.',
Lm='Lma:BAAALgAECgYJBwAAAA==.',
Lo='Lovenoriko:BAAALgADCgYJBgAAAA==.',
Lw='Lwdk:BAAALgAECgYJDAAAAA==.',
Ma='Maelle:BAAALgAFFAIJBAAAAA==.Marksmanship:BAAALgAFFAIJAgABLgAFFAMJBwAIANscAA==.',
Me='Mesue:BAAALgAFFAUJAQAAAA==.',
Mi='Miriam:BAAALgADCgQJBAABLgAECgYJCwADAAAAAA==.',
Mo='Monica:BAAALgADCgQJBAAAAA==.',
Mu='Mutsumi:BAAALgADCgIJAgAAAA==.',
Ne='Nemesyx:BAAALgAECgUJCAAAAA==.',
No='Noriko:BAAALgADCgYJBgAAAA==.',
Pe='Pepe:BAABLgAFFH8LAAIJAAMJxhuIBgANAQAJAAMJxhuIBgANAQAAAA==.',
Pi='Piaggio:BAAALgAFFAEJAgAAAA==.',
Ro='Rongqiang:BAAALgAECgUJBQAAAA==.Roseblade:BAAALgAECgYJCwAAAA==.',
Sa='Sasa:BAAALgAFFAIJAgAAAA==.',
Sd='Sdadczx:BAABLgAECn8XAAIFAAgJzxLBVQDwAQAFAAgJzxLBVQDwAQAAAA==.',
Se='Sergioramos:BAAALgAECgYJCQAAAA==.',
Sh='Sheryl:BAAALgAFFAEJAgABLgAFFAYJDgAKANUkAA==.',
Si='Sizumi:BAABLgAFFH8HAAMBAAQJEwUkDwCGAAACAAIJTAgCPACaAAABAAIJ2wEkDwCGAAAAAA==.',
Sk='Skyarrow:BAAALgAECgQJBAAAAA==.Skyriver:BAAALgAECgYJBgAAAA==.',
So='Somnus:BAAALgAECgEJAQAAAA==.',
Su='Superrabbit:BAABLgAECn8VAAIHAAgJsQq8JwAvAQAHAAgJsQq8JwAvAQAAAA==.Suzumiyake:BAAALgAFFAEJAQAAAA==.Suzumiyaz:BAABLgAFFH8KAAMLAAQJ4xVbBwC7AAAMAAQJ3AscHgDlAAALAAIJdSBbBwC7AAAAAA==.',
Tm='Tm:BAABLgAFFH8FAAIFAAMJhiFdMwC7AAAFAAMJhiFdMwC7AAAAAA==.Tmï:BAAALgAECgIJBAABLgAFFAMJBQAFAIYhAA==.',
Tu='Tudou:BAAALgAECgcJDQAAAA==.',
Ul='Ultralock:BAAALgADCgYJBgAAAA==.Ultrasound:BAAALgAECgYJBAAAAA==.',
Va='Valeeraa:BAAALgAECgYJCQABLgAFFAMJCgAFAB4XAA==.',
Ye='Yelena:BAAALgADCgEJAQAAAA==.',
Yu='Yuniki:BAAALgAFFAIJAwAAAA==.',
Za='Zadwarlock:BAAALgAFFAMJBAAAAA==.',
['一再']='一再失望:BAAALgADCgYJCwAAAA==.',
['一剑']='一剑飚血:BAAALgAECgEJAgAAAA==.',
['一力']='一力蛋:BAAALgAFFAIJAgAAAA==.',
['一曲']='一曲清歌:BAABLgAFFH8GAAIHAAIJoA/oPACyAAAHAAIJoA/oPACyAAAAAA==.',
['一月']='一月十四日:BAAALgAECgYJBgAAAA==.',
['一路']='一路向东:BAAALgAECgUJCwAAAA==.',
['丁真']='丁真:BAAALgAECgMJAwAAAA==.',
['七之']='七之一:BAAALgAFFAEJAQAAAA==.',
['七濑']='七濑悠月:BAABLgAFFH8GAAMNAAIJpw/oDwCmAAANAAIJpw/oDwCmAAAOAAIJYxXWEgCfAAAAAA==.',
['七舞']='七舞玲珑:BAAALgADCgYJBQAAAA==.',
['七草']='七草日花:BAACLgAFFH8OAAMBAAYJ4R4kAACfAQABAAUJdCAkAACfAQACAAMJeBpKLQC6AAAuAAQKfxMAAwEABwleHAgYAIoBAAIABwl9GyU8ABwCAAEABgn6FQgYAIoBAAAA.',
['三个']='三个酒仙:BAABLgAECn8cAAQPAAgJ1Rf9EwArAgAPAAgJ1Rf9EwArAgAQAAYJgwzPPAAoAQAJAAMJHRJIcQB9AAAAAA==.',
['不看']='不看月亮:BAAALgAECgkJBwAAAA==.',
['不知']='不知德行:BAAALgAECgEJAQAAAA==.',
['世壹']='世壹僧:BAAALgAFFAUJAwAAAA==.',
['东谐']='东谐孙一峰:BAAALgAFFAIJBAABLgAFFAYJBQARAAcWAA==.',
['丢猫']='丢猫:BAAALgAECgMJAQAAAA==.',
['丢耳']='丢耳朵的兔纸:BAAALgADCgYJCwAAAA==.',
['两仪']='两仪芙芙:BAAALgAECgIJBAAAAA==.',
['丶桜']='丶桜雨丶:BAAALgAFFAQJBAABLgAFFAcJCwAKAP0dAA==.',
['久远']='久远三分之一:BAAALgAECgEJAQAAAA==.久远四分之一:BAAALgAECgUJBQAAAA==.',
['乙女']='乙女解剖:BAABLgAFFH8MAAMHAAQJOCHDIgAwAQAHAAQJfiDDIgAwAQASAAIJBRgAAAAAAAAAAA==.',
['九岁']='九岁结婚:BAAALgADCgYJBgAAAA==.',
['九条']='九条尾巴:BAAALgADCgQJAwAAAA==.',
['乱九']='乱九九:BAABLgAECn8aAAMTAAYJGwo4FwDpAAATAAYJGwo4FwDpAAAMAAEJoAH+9AAaAAAAAA==.',
['交响']='交响曲:BAABLgAFFH8GAAMBAAQJmR+jCADTAAABAAIJ1SKjCADTAAACAAIJXRwwLAC+AAAAAA==.',
['仁德']='仁德仁心:BAAALgAFFAEJAQAAAA==.',
['代代']='代代有猎神:BAAALgAECgcJBwAAAA==.',
['以前']='以前泡泡鱼:BAAALgAECgQJAwAAAA==.',
['伊米']='伊米拉:BAAALgADCgEJAQAAAA==.',
['伊蒂']='伊蒂娜门泽尔:BAAALgAECgMJBAAAAA==.',
['余文']='余文乐:BAAALgADCgYJBgAAAA==.',
['你也']='你也想起舞嘛:BAAALgAECgkJEAAAAA==.',
['傲娇']='傲娇的萨满:BAAALgAECgIJAgAAAA==.',
['光之']='光之愿薇迪克:BAAALgAECgEJAQAAAA==.',
['光明']='光明风骑士:BAAALgAFFAIJAgAAAA==.',
['兜兜']='兜兜里有箭:BAAALgAECgUJBQAAAA==.兜兜里的糖糖:BAAALgAECgUJBgAAAA==.兜兜里的霓裳:BAAALgAECgIJAgAAAA==.',
['入牧']='入牧三分:BAAALgADCgcJBgAAAA==.',
['六根']='六根清净:BAAALgAECgMJAwAAAA==.',
['兰斯']='兰斯洛:BAAALgAECgkJEQABLgAFFAUJCwAFAH4WAA==.',
['养了']='养了只丶狗:BAAALgADCgEJAQAAAA==.',
['冰之']='冰之羽衣:BAAALgADCgUJBQAAAA==.',
['冰封']='冰封精灵:BAABLgAECn8UAAMEAAcJ9hsJJgAjAgAEAAcJ9hsJJgAjAgAUAAEJVgLvlgAhAAAAAA==.',
['冷酷']='冷酷计算使:BAAALgAECgYJCQAAAA==.',
['凝丿']='凝丿玥:BAAALgAFFAIJAwAAAA==.',
['凝月']='凝月冥冥:BAAALgADCgMJAwABLgAECgEJAQADAAAAAA==.',
['几何']='几何学大师:BAABLgAECn8cAAIUAAgJLh35EgCbAgAUAAgJLh35EgCbAgAAAA==.',
['制霸']='制霸小树林:BAAALgAECgEJAQAAAA==.',
['功夫']='功夫阿凡达:BAAALgAECgUJBQAAAA==.',
['加州']='加州万里:BAACLgAFFH8HAAMBAAUJ4xwqAwBsAQABAAQJbhcqAwBsAQACAAIJ9R38KwC/AAAuAAQKfxwAAwIACQkIIVUFAGYDAAIACQkIIVUFAGYDAAEABQkmFeolAC8BAAAA.',
['北方']='北方的凤凰:BAABLgAECn8VAAMVAAgJvxeoCwAgAgAVAAgJshCoCwAgAgAWAAUJgBSxMQA6AQAAAA==.',
['北知']='北知秋:BAAALgADCgEJAQAAAA==.',
['十年']='十年长跑冠军:BAABLgAFFH8HAAIXAAIJdhUUFwCgAAAXAAIJdhUUFwCgAAAAAA==.',
['千嶂']='千嶂:BAABLgAECn8UAAMYAAUJ7SNDBgDzAQAYAAUJ7SNDBgDzAQAZAAUJigLDMgCBAAAAAA==.',
['千早']='千早爱因:BAAALgAECgYJBwAAAA==.',
['协奏']='协奏曲:BAABLgAFFH8SAAMBAAYJsyDTBAA0AQABAAUJLCPTBAA0AQACAAMJ5RJGNQCoAAAAAA==.',
['南方']='南方的凤凰:BAABLgAFFH8JAAIaAAMJIx3SBAARAQAaAAMJIx3SBAARAQAAAA==.',
['南烛']='南烛:BAAALgAFFAIJAwAAAA==.',
['卡塔']='卡塔莉娜:BAAALgAECgYJDwAAAA==.',
['卡文']='卡文迪许三多:BAAALgAECgQJBQAAAA==.',
['卯之']='卯之花八千流:BAABLgAECn8UAAMFAAYJRB7/ZgDAAQAFAAYJRB7/ZgDAAQARAAQJ9hGHLwDDAAAAAA==.',
['危险']='危险的小鸟:BAAALgAFFAQJAgABLgAFFAQJBAADAAAAAA==.',
['厚切']='厚切吐司:BAABLgAECn8XAAIbAAYJviSmLwBkAgAbAAYJviSmLwBkAgAAAA==.',
['原居']='原居民:BAABLgAECn8WAAMCAAkJJRvzEADzAgACAAkJJRvzEADzAgABAAYJaxO8HgBaAQAAAA==.',
['原批']='原批:BAAALgAECgYJBgAAAA==.',
['变形']='变形吧少女:BAAALgAECgEJAQAAAA==.',
['古泠']='古泠泠:BAAALgAECgUJBwAAAA==.',
['可丶']='可丶莉:BAAALgAECgYJBgAAAA==.',
['叶语']='叶语梨:BAAALgAECgcJBwAAAA==.',
['吃丸']='吃丸子吐章鱼:BAAALgAECgUJBQAAAA==.',
['吃我']='吃我一口檀:BAAALgAFFAMJAwABLgAFFAMJBQAHABYSAA==.',
['吉多']='吉多多:BAAALgAECgEJAQAAAA==.',
['吴彦']='吴彦祖之术:BAAALgAECgYJBgAAAA==.',
['周同']='周同學:BAAALgAECgYJCQAAAA==.',
['周胜']='周胜的熊猫人:BAAALgAECgYJCQAAAA==.',
['和她']='和她再战一夜:BAAALgAECgYJCQAAAA==.和她的那夜:BAAALgAECgUJAgAAAA==.和她的那次:BAAALgAECgUJCAAAAA==.',
['咕咕']='咕咕飞:BAAALgAECgEJAQAAAA==.',
['哈基']='哈基米迪克:BAAALgAECgkJCQAAAA==.',
['唐玉']='唐玉晓宝:BAAALgAECgEJAQAAAA==.',
['唐门']='唐门丶术:BAAALgAECgMJAwAAAA==.',
['唯独']='唯独爱你:BAABLgAFFH8NAAMBAAUJMBpYDACpAAABAAMJgxZYDACpAAACAAMJIhiLRABaAAAAAA==.',
['喵叽']='喵叽喵叽:BAAALgADCgMJAwAAAA==.',
['喵呜']='喵呜:BAAALgAFFAEJAgABLgAECgcJFAAcAHoZAA==.',
['喵咪']='喵咪酒酒仙:BAAALgAECgEJAQAAAA==.',
['喵喵']='喵喵法:BAAALgAECgUJCAAAAA==.',
['嘉应']='嘉应高升:BAABLgAFFH8VAAMCAAcJ5x2sAwB3AQACAAUJXRysAwB3AQABAAQJHh20BAA5AQAAAA==.',
['嚣张']='嚣张的小德:BAAALgAECgUJBQAAAA==.',
['四神']='四神共选:BAACLgAFFH8JAAIJAAMJuBkHEQD2AAAJAAMJuBkHEQD2AAAuAAQKfyAAAgkACAlgHOsOAKgCAAkACAlgHOsOAKgCAAAA.',
['国宝']='国宝冲锋:BAAALgAECgcJEgAAAA==.',
['土地']='土地精的朋友:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光术丶:BAAALgAECgYJBgAAAA==.圣光照耀着你:BAAALgAECgEJAQAAAA==.圣光熊喵:BAAALgAFFAEJAQAAAA==.',
['地狱']='地狱灾变:BAAALgAECgQJBAAAAA==.地狱雷光:BAAALgAECgUJBAAAAA==.',
['坂本']='坂本龙一:BAABLgAECn8bAAIPAAYJAyVxDwBiAgAPAAYJAyVxDwBiAgAAAA==.',
['坚强']='坚强的小鸟:BAABLgAFFH8FAAIcAAQJ1QrpCwAtAQAcAAQJ1QrpCwAtAQAAAA==.',
['城崎']='城崎莉嘉:BAAALgADCgYJBgAAAA==.',
['塞北']='塞北的雪:BAAALgAFFAEJAQAAAA==.',
['墙角']='墙角:BAAALgADCgEJAQAAAA==.',
['墨漓']='墨漓:BAAALgADCgEJAQAAAA==.',
['墨雨']='墨雨丹清:BAACLgAFFH8JAAIYAAMJpBxpBgDrAAAYAAMJpBxpBgDrAAAuAAQKfxcAAhgACAl8H2ENAK4CABgACAl8H2ENAK4CAAAA.',
['夕阳']='夕阳西下:BAAALgAECgQJBQAAAA==.',
['多多']='多多的秋天:BAAALgAECgUJBwAAAA==.',
['夜半']='夜半:BAAALgAECgEJAQAAAA==.',
['夜珞']='夜珞然:BAAALgADCgMJAwAAAA==.',
['夜用']='夜用小可爱丶:BAAALgAECgEJAQAAAA==.',
['夢珂']='夢珂:BAABLgAFFH8NAAIJAAQJpRD2BAAsAQAJAAQJpRD2BAAsAQAAAA==.',
['大户']='大户爱:BAAALgAECgEJAgAAAA==.',
['大明']='大明神机营:BAAALgAECgcJCgAAAA==.',
['大领']='大领主:BAABLgAFFH8HAAIbAAQJkxaOCgBYAQAbAAQJkxaOCgBYAQAAAA==.',
['天空']='天空沫:BAAALgAFFAEJAQAAAA==.',
['太阳']='太阳黑子:BAAALgAECgEJAgAAAA==.',
['头顶']='头顶丶阿巴瑟:BAAALgADCgQJBAAAAA==.',
['奇梦']='奇梦生:BAAALgADCgYJCgAAAA==.',
['奥格']='奥格瑞瑪:BAABLgAFFH8JAAIPAAMJzw72EACUAAAPAAMJzw72EACUAAAAAA==.',
['奶妈']='奶妈救我:BAAALgAECgEJAQAAAA==.',
['妖糖']='妖糖:BAAALgAECggJEQAAAA==.',
['娜美']='娜美:BAAALgAECgQJBwABLgAFFAUJBwAHAMcZAA==.',
['孙村']='孙村小哥:BAAALgAECgMJBAAAAA==.',
['安希']='安希妍:BAAALgAECgcJCwABLgAFFAcJBwAYADwVAA==.',
['完美']='完美回忆:BAAALgAECgYJCQAAAA==.完美罪犯:BAAALgAECgcJCwAAAA==.',
['宝贝']='宝贝宝贝:BAAALgADCgYJCwAAAA==.',
['寒冰']='寒冰魔女:BAABLgAFFH8GAAIHAAMJTRm5DgAZAQAHAAMJTRm5DgAZAQAAAA==.',
['小丑']='小丑竟在身边:BAABLgAFFH8HAAIUAAUJrBBvEAAsAQAUAAUJrBBvEAAsAQAAAA==.',
['小兔']='小兔子十二号:BAAALgADCgcJBwAAAA==.',
['小地']='小地之魂:BAAALgAECgcJEAAAAA==.',
['小小']='小小囧战:BAAALgAECgMJAwAAAA==.小小田力:BAAALgAECgQJBQAAAA==.',
['小波']='小波:BAABLgAFFH8IAAIWAAMJ5iT+CwA9AQAWAAMJ5iT+CwA9AQAAAA==.',
['小米']='小米她姐:BAAALgAECgUJBgAAAA==.小米挺身而出:BAAALgAECgEJAgAAAA==.',
['小资']='小资历求放过:BAAALgADCgcJBwAAAA==.',
['小马']='小马宝莉:BAAALgAECgEJAgAAAA==.',
['岚嘶']='岚嘶洛特:BAACLgAFFH8GAAMCAAQJDBSxHwAFAQACAAMJ3BOxHwAFAQABAAEJbRToEwBXAAAuAAQKfxoABAIACAmOIuUWAMsCAAIACAmzHuUWAMsCAAEAAgn4HpVIAJUAAB0AAQkAACk3ACYAAAAA.',
['峰一']='峰一样的男人:BAABLgAECn8YAAIHAAYJViTIQAB2AgAHAAYJViTIQAB2AgAAAA==.',
['左手']='左手倒影:BAAALgAECgYJDgAAAA==.',
['常盘']='常盘台电击娘:BAAALgAECgYJCgAAAA==.',
['幻舞']='幻舞心心:BAAALgAECgMJAwAAAA==.',
['庆余']='庆余年:BAAALgADCgUJBQAAAA==.',
['弗勒']='弗勒德莉丝:BAAALgAECgUJBQAAAA==.',
['强效']='强效冰冻鸡翅:BAAALgADCgcJBwAAAA==.',
['彩虹']='彩虹之影:BAAALgAECgcJCQAAAA==.',
['影缝']='影缝余弦:BAAALgAFFAEJAgAAAA==.',
['影舞']='影舞清秋:BAAALgAFFAEJAQABLgAFFAcJBAADAAAAAA==.',
['往之']='往之不谏:BAAALgAECgYJBwAAAA==.',
['征服']='征服:BAAALgAECgMJAwAAAA==.',
['後来']='後来的我们:BAAALgAECgcJAQAAAA==.',
['德玛']='德玛西亚的牛:BAAALgAECgUJBQAAAA==.',
['心爱']='心爱的小抱枕:BAAALgAECgkJBgAAAA==.',
['快乐']='快乐修熊:BAABLgAECn8dAAMJAAkJiRS1HQAUAgAJAAYJ6x+1HQAUAgAQAAkJvAAAAAAAAAAAAA==.',
['怪大']='怪大叔:BAAALgAECgYJEQAAAA==.',
['恢复']='恢复德:BAABLgAECn8ZAAQaAAYJCR5BIgDrAQAaAAYJFx1BIgDrAQAGAAQJKx1qEABUAQAeAAQJXBUfGQDpAAAAAA==.',
['惆怅']='惆怅:BAAALgADCgQJBAAAAA==.',
['愚蠢']='愚蠢的小鸟:BAAALgAFFAMJAwAAAA==.',
['慕容']='慕容大熊猫:BAAALgAECgcJDwAAAA==.',
['慷慨']='慷慨的小鸟:BAAALgAFFAQJAwABLgAFFAQJBAADAAAAAA==.',
['戀愛']='戀愛裁判:BAABLgAFFH8IAAIaAAQJDA7SEwClAAAaAAQJDA7SEwClAAAAAA==.',
['我不']='我不要打针:BAAALgAECgEJAQAAAA==.',
['我是']='我是技术员:BAABLgAECn8WAAMEAAYJuCRkGQBwAgAEAAYJuCRkGQBwAgAUAAIJQxCyeQBbAAAAAA==.我是随便玩:BAAALgAECgEJAQAAAA==.',
['战争']='战争:BAAALgAECgcJDgAAAA==.',
['拇指']='拇指乱舞:BAAALgAECgYJDAAAAA==.拇指冲锋:BAAALgADCgMJAwAAAA==.',
['搁浅']='搁浅丶叁:BAAALgAFFAUJAwAAAA==.搁浅丶拾:BAABLgAFFH8FAAIcAAQJ0BgkBwBoAQAcAAQJ0BgkBwBoAQAAAA==.搁浅丶捌:BAAALgAFFAUJAgAAAA==.搁浅丶火:BAAALgAFFAUJAgAAAA==.',
['擱淺']='擱淺丶風:BAAALgAFFAIJAgAAAA==.',
['放空']='放空心情:BAAALgAECgQJBAAAAA==.',
['斧乃']='斧乃木余接:BAAALgAECgYJDQAAAA==.',
['无敌']='无敌多么寂寞:BAAALgADCgcJCAAAAA==.',
['早安']='早安丶:BAAALgAECgIJAgAAAA==.',
['早濑']='早濑优香:BAABLgAFFH8GAAMWAAQJ8wtYEwDjAAAWAAMJjw5YEwDjAAAVAAEJHQToCwBGAAABLgAFFAQJDAAHADghAA==.',
['时时']='时时精彩:BAABLgAFFH8PAAMBAAYJbyAdAgCmAQABAAUJbSAdAgCmAQACAAMJThuXKQDNAAAAAA==.',
['旺多']='旺多多:BAAALgAECgEJAgAAAA==.',
['明月']='明月千里:BAABLgAFFH8QAAMBAAYJJSFCBABMAQABAAMJuiVCBABMAQACAAMJFx7OGgAdAQAAAA==.',
['星光']='星光:BAAALgADCgYJBwAAAA==.星光阿妮雅:BAAALgAECgMJBgAAAA==.',
['星屑']='星屑维纳斯丶:BAAALgAFFAEJAQABLgAFFAUJCwAfAFsVAA==.',
['星弦']='星弦蝶语:BAAALgADCgcJCAAAAA==.',
['星星']='星星头丶:BAAALgADCgEJAQAAAA==.',
['星月']='星月忆辰:BAAALgAECgIJBQAAAA==.',
['星耦']='星耦狱锁:BAAALgAECgQJBQABLgAFFAMJCQAfAN4eAA==.',
['星辰']='星辰钟塔玛丽:BAABLgAECn8pAAIHAAgJFRoPPQCDAgAHAAgJFRoPPQCDAgAAAA==.',
['春日']='春日影:BAAALgAFFAYJAwAAAA==.',
['晓胖']='晓胖纸贰号:BAAALgAECgQJBAAAAA==.',
['晓贤']='晓贤:BAAALgAECgUJBQAAAA==.',
['暧昧']='暧昧的小鸟:BAAALgAFFAQJBAAAAA==.',
['曹老']='曹老板:BAAALgAECgEJAQAAAA==.',
['曼佗']='曼佗羅丨帕菈:BAAALgADCgEJAQAAAA==.',
['曽经']='曽经沧海:BAAALgAECgEJAQAAAA==.',
['月儿']='月儿招宝宝:BAAALgADCgEJAQAAAA==.',
['月朗']='月朗风清:BAAALgAECgYJDAAAAA==.',
['望枫']='望枫:BAAALgAECgEJBAAAAA==.',
['末晓']='末晓之殇:BAAALgAECgYJDQABLgAFFAMJCQAfAN4eAA==.',
['机械']='机械小助手:BAAALgADCgYJBgAAAA==.',
['李瓶']='李瓶儿:BAABLgAECn8ZAAQNAAYJoBy6HQDsAQANAAYJoBy6HQDsAQAOAAMJ1xe8DQDcAAAgAAEJ1Q41IAAsAAAAAA==.',
['杏目']='杏目:BAABLgAFFH8OAAMBAAYJ8hsZAQDtAQABAAUJYxoZAQDtAQACAAIJEhzKLQC4AAAAAA==.',
['村雨']='村雨:BAAALgAECgcJDQAAAA==.',
['杯莫']='杯莫停:BAAALgADCgUJBQAAAA==.',
['某中']='某中二少年:BAAALgAFFAEJAgAAAA==.',
['柯南']='柯南天神:BAABLgAECn8VAAIgAAkJPxrkCAC9AgAgAAkJPxrkCAC9AgAAAA==.柯南死神:BAABLgAECn8dAAIFAAgJoh90JwCdAgAFAAgJoh90JwCdAgAAAA==.',
['柳贯']='柳贯一:BAACLgAFFH8WAAIHAAYJdyYnAQCyAgAHAAYJdyYnAQCyAgAuAAQKfyEAAgcACQm4JjIBAO4DAAcACQm4JjIBAO4DAAAA.',
['树下']='树下吃桃子:BAAALgADCgIJAgABLgAFFAMJBAADAAAAAA==.树下吃葡萄:BAAALgAFFAMJBAAAAA==.',
['桃花']='桃花载酒:BAAALgAECgIJAwAAAA==.',
['梦火']='梦火:BAAALgADCgkJCQAAAA==.',
['樋口']='樋口円香:BAAALgAFFAIJAwAAAA==.',
['次元']='次元圣光:BAAALgAECgYJCgAAAA==.次元战神:BAAALgAECgEJAQAAAA==.',
['武柒']='武柒:BAAALgAFFAEJAQAAAA==.',
['死亡']='死亡棋士:BAAALgADCgEJAQABLgADCgQJBAADAAAAAA==.',
['殁戮']='殁戮:BAAALgAECgMJAwABLgAECgUJCAADAAAAAA==.',
['殇知']='殇知秋:BAAALgAECgYJDwAAAA==.',
['段小']='段小一:BAAALgADCgEJAQAAAA==.',
['水中']='水中的雅典娜:BAAALgADCgYJBgAAAA==.',
['水源']='水源战神:BAAALgAFFAEJAgAAAA==.',
['永远']='永远的棋棋:BAAALgADCgYJDQAAAA==.',
['油条']='油条丶:BAAALgAECgUJBgAAAA==.',
['法珞']='法珞希黛:BAABLgAECn8WAAIGAAcJYiKkEQCpAgAGAAcJYiKkEQCpAgAAAA==.',
['泡泡']='泡泡熊拾壹号:BAAALgADCgYJBgAAAA==.',
['洛小']='洛小七:BAAALgAECgQJBQAAAA==.',
['洛拉']='洛拉斯之杖:BAAALgADCgMJAwAAAA==.',
['活动']='活动人偶:BAACLgAFFH8ZAAIRAAYJkR+qAABAAgARAAYJkR+qAABAAgAuAAQKfycAAhEACQkVJI4BAHMDABEACQkVJI4BAHMDAAAA.',
['济癫']='济癫:BAAALgAFFAEJAQAAAA==.',
['浪漫']='浪漫勇士:BAABLgAFFH8TAAMBAAYJjx85AACBAQABAAUJVSQ5AACBAQACAAMJohbcLQC4AAAAAA==.',
['浪的']='浪的一哔:BAAALgAECgYJCQAAAA==.',
['淡描']='淡描余音散丶:BAAALgADCgEJAQAAAA==.',
['深蓝']='深蓝之海:BAAALgADCgYJBgAAAA==.',
['混血']='混血麻瓜:BAAALgAECgcJEQAAAA==.',
['清秋']='清秋:BAAALgAECgcJBwAAAA==.',
['清風']='清風嘆離愁:BAAALgAECgYJBgAAAA==.',
['溜达']='溜达剑气纵横:BAAALgAECgEJAQAAAA==.溜达神出鬼没:BAAALgADCgcJCwAAAA==.',
['溪风']='溪风乄:BAAALgADCgUJBQAAAA==.',
['漂浮']='漂浮的树叶:BAAALgAECgYJDQAAAA==.',
['火之']='火之呼吸:BAAALgAECgIJAgAAAA==.',
['火热']='火热的小鸟:BAAALgAFFAQJBAABLgAFFAQJBAADAAAAAA==.',
['灵灵']='灵灵的打:BAAALgAECgUJBQAAAA==.',
['灵魂']='灵魂闪电:BAAALgAECgYJBgAAAA==.',
['烟宇']='烟宇流光:BAAALgAECgMJAwAAAA==.',
['烟雨']='烟雨江湳:BAAALgADCgYJCwAAAA==.',
['焰影']='焰影苇草:BAAALgADCgEJAQAAAA==.',
['熊大']='熊大打熊二:BAAALgADCgIJAgAAAA==.',
['熊猫']='熊猫诈尸:BAAALgADCgYJBQAAAA==.',
['燃烧']='燃烧的小鸟:BAAALgAFFAQJBAAAAA==.',
['燎里']='燎里:BAAALgAECgYJEAAAAA==.',
['爪皇']='爪皇凌雨:BAACLgAFFH8FAAMBAAUJrSGWAgCIAQABAAQJLCCWAgCIAQACAAEJMSbaQABzAAAuAAQKfxUABAEACQnaGwsJADACAAEABgkzIAsJADACAAIABwnvGBxWAMUBAB0AAQmUDmwxADsAAAAA.',
['爱因']='爱因瑟尔纳特:BAAALgADCgYJBQAAAA==.',
['爱如']='爱如往昔:BAABLgAFFH8MAAMBAAQJYx7LBAA1AQABAAMJkCDLBAA1AQACAAEJ3BdZRQBYAAAAAA==.',
['爱弥']='爱弥斯:BAAALgADCgYJBgAAAA==.',
['爱生']='爱生活爱小郭:BAAALgAECgYJDQABLgAFFAYJEAARAPwkAA==.',
['牛哎']='牛哎:BAABLgAECn8YAAIIAAgJghVRJgAnAgAIAAgJghVRJgAnAgAAAA==.',
['牧园']='牧园子:BAAALgAECggJCgAAAA==.',
['特莉']='特莉丝:BAAALgAECgQJBAAAAA==.',
['猛宝']='猛宝新岛男:BAAALgADCgUJBQAAAA==.',
['猫九']='猫九二:BAAALgAFFAQJAwAAAA==.猫九五:BAAALgAFFAMJAwAAAA==.',
['猫德']='猫德:BAAALgAFFAQJAgAAAA==.',
['王无']='王无敌:BAACLgAFFH8HAAIFAAMJaRydHwAdAQAFAAMJaRydHwAdAQAuAAQKfxYAAgUABgnuIOpEACYCAAUABgnuIOpEACYCAAAA.',
['王皓']='王皓:BAAALgADCgEJAQAAAA==.',
['玛奇']='玛奇玛骑马:BAABLgAFFH8IAAIbAAQJyBlGCABwAQAbAAQJyBlGCABwAQAAAA==.',
['玛薇']='玛薇卡:BAACLgAFFH8FAAIWAAMJrRn5CgC/AAAWAAMJrRn5CgC/AAAuAAQKfywABBYACQkaHo4EAEYDABYACQkaHo4EAEYDABUABQmKD94hABwBAB8AAQkxCn5FAEUAAAAA.',
['球洛']='球洛不早起丶:BAAALgAECgYJBgAAAA==.',
['琥珀']='琥珀色晨光:BAAALgAECgMJAwAAAA==.',
['琴夕']='琴夕:BAAALgAECgQJBAAAAA==.',
['琴夜']='琴夜:BAAALgADCgIJBAAAAA==.',
['琴薇']='琴薇:BAAALgADCgEJAQAAAA==.',
['琴魅']='琴魅:BAAALgAECgMJAwAAAA==.',
['甘蓝']='甘蓝:BAAALgAFFAEJAgAAAA==.',
['生煎']='生煎一口闷:BAAALgAFFAMJAwAAAA==.',
['田曦']='田曦薇:BAAALgADCgUJBQAAAA==.',
['画沙']='画沙:BAAALgAECgcJBwAAAA==.',
['白米']='白米露:BAAALgADCgEJAQAAAA==.',
['白豆']='白豆腐:BAAALgAECgQJBgAAAA==.',
['盈彩']='盈彩缤纷:BAABLgAFFH8PAAMBAAYJgR1iCQDCAAABAAUJKyBiCQDCAAACAAQJcxkAAAAAAAAAAA==.',
['盖尔']='盖尔:BAAALgADCgUJBQAAAA==.',
['盗帅']='盗帅留香:BAAALgAFFAMJAwAAAA==.',
['真正']='真正煎火:BAABLgAFFH8JAAMBAAUJlCI5AgCfAQABAAQJ3iM5AgCfAQACAAEJtR6qQwBbAAAAAA==.',
['真的']='真的很关键:BAAALgAECgUJBQAAAA==.',
['眩晕']='眩晕的小鸟:BAAALgAFFAEJAQAAAA==.',
['神人']='神人:BAACLgAFFH8IAAICAAMJLw8rEADyAAACAAMJLw8rEADyAAAuAAQKfxoAAwIACAm9HQsmAHoCAAIACAm9HQsmAHoCAB0AAQkAAFokAGAAAAAA.',
['神北']='神北小毬:BAABLgAFFH8NAAMBAAUJZCK/AAAaAgABAAUJZCK/AAAaAgACAAIJjAqxOQCgAAAAAA==.',
['神圣']='神圣恳求:BAAALgAECgMJAwAAAA==.',
['神奇']='神奇的韭菜:BAAALgAECgUJCAAAAA==.',
['神样']='神样的方世玉:BAAALgAFFAIJAgAAAA==.',
['神秘']='神秘的小鸟:BAAALgAECgQJBAABLgAFFAQJBAADAAAAAA==.',
['秋月']='秋月明梓:BAABLgAECn8bAAIHAAgJyRh/WwAnAgAHAAgJyRh/WwAnAgAAAA==.',
['空蒙']='空蒙:BAABLgAECn8VAAMBAAcJHRPxGACEAQABAAYJLxTxGACEAQACAAEJvw1IDQFDAAABLgAFFAIJBAADAAAAAA==.',
['筱之']='筱之之箒:BAAALgAECgUJBQAAAA==.',
['米丽']='米丽娜薇风:BAAALgAECgMJBAAAAA==.',
['粉色']='粉色的星星:BAAALgADCgcJBwAAAA==.',
['精英']='精英大师:BAACLgAFFH8NAAMBAAUJLCNNAgCZAQABAAUJVyJNAgCZAQACAAIJWh2RKwDBAAAuAAQKfxYABAIACQmEF/oiAIkCAAIACQmEF/oiAIkCAAEAAgmuEOdUAG8AAB0AAQlaFqsuAEEAAAAA.',
['糊人']='糊人:BAAALgADCgUJBQAAAA==.',
['糖糖']='糖糖里的奶昔:BAAALgAECgYJCgAAAA==.',
['糹影']='糹影舞清秋糹:BAAALgAECgYJBgAAAA==.',
['緋田']='緋田美琴:BAABLgAFFH8IAAMCAAQJnSKzLAC8AAACAAIJ8B+zLAC8AAABAAQJXh4AAAAAAAAAAA==.',
['红糖']='红糖锅盔:BAAALgAECgEJAQAAAA==.',
['纵火']='纵火无罪:BAAALgAECgYJEQAAAA==.',
['织云']='织云:BAABLgAFFH8FAAIHAAMJowZoFADvAAAHAAMJowZoFADvAAAAAA==.',
['终曲']='终曲黎明:BAABLgAFFH8JAAIfAAMJ3h4yBQD+AAAfAAMJ3h4yBQD+AAAAAA==.',
['经典']='经典黑白配:BAAALgAECgUJDAAAAA==.',
['绝対']='绝対运命黙示:BAAALgAECgYJEAAAAA==.',
['维多']='维多利娅:BAAALgAECgQJBAAAAA==.',
['绿色']='绿色翻滚汤圆:BAAALgAECgYJBgAAAA==.',
['罒清']='罒清秋罒:BAAALgAECgEJAwAAAA==.',
['美丽']='美丽传承:BAACLgAFFH8KAAMBAAYJQByvBAA6AQABAAUJ6SCvBAA6AQACAAIJuQ+KRgBWAAAuAAQKfxwABAEACQlxHIkEAJcCAAEACAkzG4kEAJcCAAIACAkDG4s6ACICAB0AAQmADI0yADgAAAAA.',
['羽川']='羽川翼丶:BAAALgAECgIJAgAAAA==.',
['耿鬼']='耿鬼:BAABLgAFFH8FAAIFAAIJ6yMZMADQAAAFAAIJ6yMZMADQAAAAAA==.',
['胡副']='胡副团总:BAAALgAECgIJAgAAAA==.',
['能抡']='能抡但没必要:BAAALgAFFAEJAgAAAA==.',
['能拉']='能拉但没必要:BAAALgADCgMJAwAAAA==.',
['能拽']='能拽但没必要:BAAALgAECgQJBAAAAA==.',
['能插']='能插但没必要:BAAALgAECgYJCgAAAA==.',
['舞僧']='舞僧:BAAALgADCgEJAQABLgADCgQJBAADAAAAAA==.',
['艾尔']='艾尔薇特:BAAALgAECgMJAQAAAA==.',
['艾尼']='艾尼路:BAAALgAFFAEJAgAAAA==.',
['艾蕾']='艾蕾克希娅:BAAALgAECgYJDAAAAA==.',
['艾薇']='艾薇尔:BAAALgAECgIJAwAAAA==.',
['花心']='花心时乱超人:BAAALgAFFAIJAgAAAA==.',
['花芯']='花芯里的虫:BAAALgAECgUJBQAAAA==.',
['若离']='若离于爱者:BAAALgAECgcJEAAAAA==.',
['英国']='英国大理石:BAAALgAECgIJAgAAAA==.',
['荒天']='荒天尘:BAAALgAECgEJAQAAAA==.',
['莫召']='莫召奴:BAAALgAFFAUJAgAAAA==.',
['菊池']='菊池桃子:BAAALgAECgUJCQAAAA==.',
['菜青']='菜青虫乖乖:BAAALgAECgcJEwABLgAFFAYJFgAcAMUZAA==.',
['菠萝']='菠萝荔枝蜜:BAAALgAECggJDAAAAA==.',
['萌新']='萌新打魔兽:BAAALgAECgUJBQAAAA==.',
['萌萌']='萌萌哒鸡蛋饼:BAAALgADCgYJBgAAAA==.',
['蒲公']='蒲公英的旅行:BAAALgAECgcJCAAAAA==.',
['蕾塞']='蕾塞:BAAALgAECgYJBwAAAA==.',
['蕾欧']='蕾欧娜暗月:BAAALgADCgUJBQAAAA==.',
['蕾蒂']='蕾蒂亚:BAAALgADCgYJBgAAAA==.',
['薄荷']='薄荷色清風:BAAALgAECgEJAQAAAA==.',
['薇诺']='薇诺德克丽丝:BAAALgAECgIJAgAAAA==.',
['蛋疼']='蛋疼一哔:BAAALgAECgYJBwAAAA==.',
['蛋肿']='蛋肿:BAAALgAECgQJCAAAAA==.',
['蛮力']='蛮力猛击:BAAALgAECgIJAgAAAA==.',
['血獣']='血獣:BAAALgAECgEJAQAAAA==.',
['袭人']='袭人:BAAALgADCgIJAgAAAA==.',
['西园']='西园小小美鱼:BAABLgAFFH8OAAMBAAYJxSBxCADbAAABAAQJMyNxCADbAAACAAMJYBesSABTAAAAAA==.西园小美鱼:BAABLgAFFH8IAAMBAAQJjh8nBQAlAQABAAMJHSEnBQAlAQACAAEJ4hpORgBXAAAAAA==.',
['西沃']='西沃格:BAAALgAECgYJEwAAAA==.',
['西里']='西里哗啦:BAAALgAECgIJAgAAAA==.',
['诶我']='诶我冰脉呢:BAABLgAFFH8FAAIHAAMJFhIFKwAJAQAHAAMJFhIFKwAJAQAAAA==.',
['请叫']='请叫我船长:BAAALgADCgEJAQAAAA==.',
['贪财']='贪财地精:BAAALgADCgUJBQAAAA==.',
['赤红']='赤红风暴:BAAALgAECgYJCAAAAA==.',
['轻裾']='轻裾丶德:BAAALgAECgYJCQAAAA==.轻裾丶术:BAACLgAFFH8UAAQBAAYJagtOBABLAQABAAUJYwhOBABLAQACAAMJEw+rFgCxAAAdAAEJAACCAwBfAAAuAAQKfyMAAwIACQnFH1IaALcCAAIACAlkH1IaALcCAAEABgngGrkNAOoBAAAA.',
['达尔']='达尔红手:BAAALgAECgQJBAAAAA==.',
['达洛']='达洛菲:BAAALgAECgYJCwAAAA==.',
['这是']='这是好事儿啊:BAACLgAFFH8JAAIbAAMJsxpKBwAZAQAbAAMJsxpKBwAZAQAuAAQKfyAAAhsACAlVH8YVAOcCABsACAlVH8YVAOcCAAAA.',
['进来']='进来看会书:BAAALgAECgYJCAAAAA==.',
['迦楼']='迦楼罗王:BAAALgAECgIJAgAAAA==.',
['追梦']='追梦梨:BAAALgAECgEJAQAAAA==.',
['逗丁']='逗丁丁:BAAALgAECgcJDQAAAA==.',
['遨游']='遨游气泡:BAACLgAFFH8XAAMBAAcJiCFbAABqAgABAAYJdyBbAABqAgACAAMJexV8LgC2AAAuAAQKfxUAAwEACQlAH4wBAAwDAAEABwmdJYwBAAwDAAIABglME7OMAEABAAAA.',
['邓诗']='邓诗颖:BAAALgAECgcJBgAAAA==.',
['那由']='那由多:BAACLgAFFH8IAAIFAAMJECN4CgAhAQAFAAMJECN4CgAhAQAuAAQKfxQAAgUACAkJGmtYAOgBAAUACAkJGmtYAOgBAAAA.',
['都行']='都行:BAAALgADCgMJAwAAAA==.',
['鄧诗']='鄧诗颖:BAABLgAECn8ZAAIFAAYJehw8WgDjAQAFAAYJehw8WgDjAQAAAA==.',
['酷酷']='酷酷的果果熊:BAAALgAECgQJBAAAAA==.',
['醉焓']='醉焓汐:BAAALgAECgEJAQAAAA==.',
['野猫']='野猫不变熊:BAAALgAECgYJDAAAAA==.',
['銃梦']='銃梦:BAAALgAECgIJAgAAAA==.',
['钢牙']='钢牙:BAAALgADCggJCgAAAA==.',
['铁铁']='铁铁的鬃:BAAALgAECgkJCgABLgAFFAQJBQAWAK0ZAA==.',
['长夜']='长夜漫漫:BAAALgAECgIJAgAAAA==.长夜至此而终:BAAALgAECgQJBAAAAA==.',
['閃靈']='閃靈:BAAALgAECgUJCQAAAA==.',
['闪亮']='闪亮夏莉欧:BAABLgAFFH8OAAMZAAQJWBZ9AQAiAQAZAAQJWBZ9AQAiAQAbAAQJ9QRAOwA+AAABLgAFFAYJGQARAJEfAA==.',
['闪电']='闪电哈尼:BAABLgAFFH8JAAMXAAQJ4htEBQB5AQAXAAQJ4htEBQB5AQAcAAIJ5RCnFQCjAAAAAA==.',
['阴湿']='阴湿病娇男:BAAALgAECgYJAgAAAA==.',
['阿玥']='阿玥拉:BAAALgAECgEJAQAAAA==.',
['陈平']='陈平安:BAAALgAECggJCAAAAA==.',
['陈落']='陈落落:BAAALgAECgEJAQAAAA==.',
['难的']='难的一哔:BAAALgAFFAIJBAAAAA==.',
['雨夜']='雨夜的沨:BAAALgADCgQJBAAAAA==.',
['雪梨']='雪梨:BAAALgADCgEJAQAAAA==.',
['雷克']='雷克奶萨:BAAALgAECgYJBgAAAA==.',
['雾雨']='雾雨魔理沙:BAAALgAFFAQJBAABLgAFFAUJDgAaAKMmAA==.',
['露米']='露米娅:BAAALgAFFAEJAQAAAA==.',
['青丶']='青丶藤:BAAALgAECgQJBAAAAA==.',
['青春']='青春常驻:BAABLgAFFH8MAAMBAAQJqCTzBAAuAQABAAMJtx/zBAAuAQACAAIJPCTKJwDbAAAAAA==.',
['青涩']='青涩后妈:BAAALgAECgQJBAAAAA==.',
['青眼']='青眼白龙:BAACLgAFFH8JAAIXAAMJpRJTDwDtAAAXAAMJpRJTDwDtAAAuAAQKfyAAAhcACAnSISAIAPMCABcACAnSISAIAPMCAAAA.',
['青藤']='青藤丨:BAAALgADCgQJBAAAAA==.',
['韩小']='韩小狗:BAAALgAECgMJBAAAAA==.',
['顾轻']='顾轻萝:BAAALgAECgYJBgAAAA==.',
['风之']='风之轻吟:BAAALgADCgQJBwAAAA==.',
['风暴']='风暴怒天:BAABLgAECn8XAAIXAAgJoBxYEACVAgAXAAgJoBxYEACVAgAAAA==.风暴烈酒陈:BAAALgAECgEJAQABLgAECgcJFQAQAP8TAA==.',
['风王']='风王子:BAACLgAFFH8MAAMEAAMJPxCCDgCpAAAEAAIJiw2CDgCpAAAUAAIJUhZRHAClAAAuAAQKfxYAAxQABwlsF/81AI0BABQABgmxF/81AI0BAAQAAgnAF4U8AE0AAAAA.',
['飘舞']='飘舞的咏叹曲:BAAALgAECgUJBQAAAA==.',
['飞马']='飞马幻想:BAAALgAECgcJDAAAAA==.飞马的风车:BAAALgAECgcJDQAAAA==.',
['馅饼']='馅饼:BAAALgAECgEJAQAAAA==.',
['馬小']='馬小玲:BAABLgAECn8VAAICAAcJwBwRQQAKAgACAAcJwBwRQQAKAgAAAA==.',
['高尚']='高尚骏逸:BAABLgAFFH8LAAMBAAUJwiMrAgCjAQABAAQJ3CMrAgCjAQACAAIJNhdtLgC2AAAAAA==.',
['魁奈']='魁奈:BAAALgAECgYJCwABLgAECgYJEAADAAAAAA==.',
['魂灵']='魂灵茄子:BAAALgAECgYJDgAAAA==.',
['魅影']='魅影君独行:BAAALgAECgMJAwAAAA==.',
['魔力']='魔力彩彩:BAAALgAECgEJAQAAAA==.',
['鸿蒙']='鸿蒙丨迪妮莎:BAAALgADCgEJAQAAAA==.',
['鹤清']='鹤清翎:BAAALgAECgYJCQAAAA==.',
['鹿鸽']='鹿鸽:BAABLgAECn8cAAIGAAkJjBuODQDPAgAGAAkJjBuODQDPAgAAAA==.',
['鹿鹿']='鹿鹿鸽:BAAALgAECgkJAQAAAA==.',
['黄油']='黄油茄子:BAAALgAECgEJAQAAAA==.',
['黑化']='黑化小夫:BAACLgAFFH8SAAMMAAUJRxybBQBOAQAMAAQJRxybBQBOAQATAAEJAACqBABSAAAuAAQKfxsAAgwACAlYHJsqAFYCAAwACAlYHJsqAFYCAAAA.',
['黑暗']='黑暗突变:BAAALgAECgcJAgAAAA==.',
['黑色']='黑色熊猫:BAAALgAECgQJBAAAAA==.',
['默斯']='默斯肯:BAACLgAFFH8YAAIaAAYJsSY9AAC9AgAaAAYJsSY9AAC9AgAuAAQKfx4AAhoACAnjJuMCAIgDABoACAnjJuMCAIgDAAAA.',
['黯戦']='黯戦:BAAALgAECgEJAQAAAA==.',
['鼠鼠']='鼠鼠星宝:BAAALgAECgEJAQAAAA==.鼠鼠猫狗鸡丶:BAAALgAECgYJBgAAAA==.',
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
