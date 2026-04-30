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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Mage-Frost','Mage-Arcane','Unknown-Unknown','Paladin-Holy','Evoker-Devastation','Evoker-Augmentation','DemonHunter-Havoc','Shaman-Elemental','Warrior-Fury','Warrior-Protection','Monk-Windwalker','Monk-Mistweaver','Hunter-BeastMastery','Paladin-Retribution','Warrior-Arms','Hunter-Survival','Shaman-Restoration','DeathKnight-Unholy','DemonHunter-Devourer','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Priest-Shadow','DeathKnight-Frost','DeathKnight-Blood','Evoker-Preservation','Priest-Holy','Priest-Discipline','Rogue-Subtlety','Monk-Brewmaster',}
local provider = {region='CN',realm='雷斧堡垒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aarush:BAAALgAECgkJCQAAAA==.',
Aj='Ajie:BAAALgADCgEJAQAAAA==.',
Am='Amamiyuki:BAAALgAFFAIJAgAAAA==.Ami:BAAALgAECgEJAQAAAA==.',
Ar='Ariade:BAAALgAECgYJCQAAAA==.',
Ay='Ayaka:BAAALgADCgMJAwAAAA==.',
Az='Azuresong:BAABLgAFFH8KAAMBAAMJ8iHZHAARAQABAAMJ6xnZHAARAQACAAEJQCEJBQBfAAAAAA==.',
Ba='Balerion:BAAALgAECgcJEwAAAA==.',
Bo='Bourgogne:BAAALgADCgYJBgAAAA==.',
Cr='Crabmagician:BAABLgAFFH8JAAMDAAQJqhY+GQBlAQADAAQJqhY+GQBlAQAEAAEJ0AuzAABTAAAAAA==.',
De='Dedded:BAAALgADCgUJBQABLgADCgYJBgAFAAAAAA==.Demonkiller:BAAALgAECgQJBQAAAA==.Desmayado:BAAALgAFFAEJAQAAAA==.Destruction:BAAALgADCgQJBAAAAA==.Devilz:BAAALgADCgMJAwAAAA==.',
Dr='Dreamcrab:BAAALgAECgIJAgABLgAFFAQJCQADAKoWAA==.',
El='Elmo:BAAALgADCgYJBgAAAA==.',
Em='Emeris:BAAALgAECgYJBgAAAA==.',
Fl='Flyknight:BAAALgADCgEJAQAAAA==.',
Fr='Freetown:BAAALgADCgYJBgAAAA==.',
Ge='Geforceo:BAAALgADCgUJBQAAAA==.Geforceoc:BAAALgAECgUJBwAAAA==.',
Ho='Homelander:BAAALgAECgUJBQAAAA==.',
Ht='Htized:BAAALgAFFAEJAgAAAA==.',
In='Inviligence:BAAALgAECgQJBAABLgAFFAUJCwAGAM4YAA==.',
Ja='Jackslowfk:BAAALgAECgUJCAAAAA==.',
Ka='Kamachi:BAAALgAECgcJCwAAAA==.Karry:BAAALgAECgMJAwAAAA==.',
Ke='Keeley:BAAALgAECggJDwAAAA==.',
Le='Lemondragon:BAACLgAFFH8VAAMHAAYJaB4uAACRAQAHAAUJeCIuAACRAQAIAAEJJw7GHgBcAAAuAAQKfxgAAwcACQldIJwAAIgDAAcACQldIJwAAIgDAAgAAQlSI1JXAGMAAAAA.Lenne:BAACLgAFFH8IAAIDAAMJJgzwGgDqAAADAAMJJgzwGgDqAAAuAAQKfxsAAgMACAmUE0VoAAYCAAMACAmUE0VoAAYCAAAA.Leskerguel:BAAALgAECgUJBQAAAA==.',
Li='Littlelulu:BAAALgAECgEJAQAAAA==.',
Lo='Loktarorga:BAAALgADCgYJBgAAAA==.',
Ly='Lycheebaby:BAAALgAECgIJAgAAAA==.',
Ma='Magicvd:BAAALgAECgIJAgAAAA==.Maonkey:BAAALgAECgYJBgAAAA==.',
Me='Meiadk:BAAALgAECgUJBQAAAA==.Meonk:BAAALgAECgMJAwAAAA==.',
Mi='Miiet:BAAALgAECgQJAQAAAA==.Milkshake:BAAALgAECgYJCAAAAA==.',
My='Myrhythm:BAAALgAECgIJAgAAAA==.',
Na='Napster:BAAALgAECgEJAQAAAA==.Nasus:BAAALgAECgYJDgAAAA==.',
No='Note:BAAALgADCgEJAQAAAA==.',
Pl='Playertchyxi:BAAALgADCgIJAgAAAA==.',
Pr='Preacher:BAAALgADCgUJBQAAAA==.',
Ra='Rafel:BAAALgADCgEJAQAAAA==.',
Rb='Rbdks:BAAALgADCgEJAQAAAA==.',
Ru='Ruffer:BAAALgAECgQJBAAAAA==.',
Sa='Sacredwind:BAAALgADCgMJAwAAAA==.',
Se='Seagate:BAAALgAECgUJBQAAAA==.Seraphina:BAAALgAECgcJDAAAAA==.',
Sh='Shamanleung:BAAALgAFFAIJAgAAAA==.Shinn:BAAALgADCgUJBQAAAA==.',
St='Stary:BAAALgADCgUJBQAAAA==.Steelhaze:BAAALgAECgEJAQAAAA==.',
Te='Teed:BAAALgAECgYJDQAAAA==.',
To='Tohsakarin:BAAALgAFFAEJAQAAAA==.',
Tr='Treeman:BAAALgADCgEJAQAAAA==.',
Ty='Tyson:BAAALgAECgkJCQAAAA==.',
Va='Valerian:BAAALgAECgcJDAAAAA==.',
Ve='Vefe:BAAALgADCgUJCAAAAA==.',
Vi='Viamagic:BAAALgAECgMJBgAAAA==.Viarr:BAAALgAECgcJCAAAAA==.',
Vr='Vrindavani:BAAALgADCgEJAQAAAA==.',
Wi='Windblade:BAAALgADCgMJAwAAAA==.',
Wo='Wonderlust:BAABLgAFFH8FAAIJAAUJlwO2AgD+AAAJAAUJlwO2AgD+AAAAAA==.',
Za='Zaychik:BAAALgADCgQJBAAAAA==.',
Ze='Zerozx:BAAALgADCgEJAQAAAA==.',
['一个']='一个小小法:BAAALgAECgUJBQAAAA==.',
['一夏']='一夏末秋至:BAAALgAECgIJAgAAAA==.',
['一朵']='一朵西兰花:BAAALgAECgYJBgAAAA==.',
['一疯']='一疯狂王子一:BAAALgAFFAMJBAABLgAFFAQJCAAKADITAA==.',
['一艾']='一艾丽娅一:BAAALgADCgEJAQAAAA==.',
['一金']='一金钢狼一:BAABLgAECn8ZAAMLAAgJbRq5FwCOAgALAAgJbRq5FwCOAgAMAAEJAg4eRwAxAAAAAA==.',
['一锤']='一锤子怼你:BAAALgAFFAMJAwAAAA==.',
['一陈']='一陈不变:BAAALgAECgYJEQAAAA==.',
['七月']='七月喵:BAAALgAECggJCAAAAA==.',
['七毛']='七毛暗黑骑:BAAALgAFFAEJAQAAAA==.',
['三千']='三千流火:BAAALgAECgEJAQAAAA==.',
['三叉']='三叉路口:BAAALgADCgMJAwAAAA==.',
['三岔']='三岔路口:BAAALgAFFAEJAQAAAA==.',
['三笠']='三笠阿克曼丨:BAAALgAECgYJCQAAAA==.',
['三花']='三花聚鼎:BAAALgAECgQJBAAAAA==.',
['三衫']='三衫:BAAALgAFFAQJAwAAAA==.',
['三达']='三达叔:BAAALgAECgQJBAAAAA==.',
['上帝']='上帝在人间:BAAALgAECgMJAwAAAA==.上帝的执法人:BAABLgAFFH8HAAIMAAMJyQOECgCiAAAMAAMJyQOECgCiAAAAAA==.',
['上马']='上马不喊话:BAAALgAECgEJAQAAAA==.',
['不二']='不二的树:BAACLgAFFH8HAAINAAIJ3BuxDACdAAANAAIJ3BuxDACdAAAuAAQKfxQAAg0ABwmgIMkPAIMCAA0ABwmgIMkPAIMCAAAA.',
['不关']='不关小友的事:BAAALgAECgUJBgAAAA==.',
['不分']='不分好歹:BAAALgAECgMJAwAAAA==.',
['不可']='不可咕量:BAAALgAECgYJCQAAAA==.',
['不忮']='不忮不求:BAAALgAECgQJBAAAAA==.',
['不敢']='不敢名之恋:BAAALgAECgEJAQAAAA==.',
['不是']='不是吧哥们:BAAALgAECgYJDQAAAA==.',
['不给']='不给村长战复:BAAALgAECgYJDwAAAA==.不给村长英勇:BAAALgAECgUJBQAAAA==.',
['不羁']='不羁的易术:BAAALgAFFAIJBAAAAA==.',
['不许']='不许再说了:BAAALgAECgUJBgAAAA==.',
['与影']='与影子合十:BAAALgAECgEJAQAAAA==.',
['丑八']='丑八怪咿呀哎:BAAALgAECgQJBAAAAA==.',
['专治']='专治牛皮藓:BAAALgAECgkJDQAAAA==.',
['东涯']='东涯之鹰:BAAALgAECgYJBgAAAA==.',
['丝瓜']='丝瓜:BAAALgAECgIJAgAAAA==.',
['两年']='两年时光:BAAALgADCgYJBgAAAA==.',
['两腿']='两腿一伸:BAAALgAECgYJBgAAAA==.',
['丨涂']='丨涂山红红丨:BAAALgAECgMJBQAAAA==.',
['丨简']='丨简丶简单单:BAAALgADCgEJAQAAAA==.',
['丨茶']='丨茶茶丨:BAABLgAECn8UAAIOAAkJfhcsDgB0AgAOAAkJfhcsDgB0AgAAAA==.',
['丶三']='丶三三丶:BAABLgAFFH8JAAIPAAUJHQv+AQCBAQAPAAUJHQv+AQCBAQAAAA==.',
['丶兔']='丶兔荳泥:BAAALgAFFAIJBAAAAA==.',
['丶李']='丶李先生:BAAALgAECgUJCwAAAA==.',
['丶熊']='丶熊猫花花:BAAALgAECgUJBQAAAA==.',
['丶狂']='丶狂徒诺诺:BAAALgAECgMJBAAAAA==.',
['丶王']='丶王杰希:BAAALgAECgcJDQAAAA==.',
['丶秋']='丶秋山澪:BAAALgAECgEJAQAAAA==.',
['丶艾']='丶艾莎灬公主:BAAALgADCgEJAQAAAA==.',
['丶茶']='丶茶茶丶:BAAALgAECgYJBgAAAA==.',
['丶莎']='丶莎娜凯瑞甘:BAABLgAECn8UAAIQAAgJOhrpNgBHAgAQAAgJOhrpNgBHAgAAAA==.',
['丶迪']='丶迪妮莎:BAAALgADCgIJAgAAAA==.',
['丶阿']='丶阿瑞斯:BAABLgAFFH8FAAIRAAUJNQ8eAQCWAQARAAUJNQ8eAQCWAQAAAA==.',
['丶鲜']='丶鲜血诺诺:BAAALgAECgUJBQAAAA==.',
['为华']='为华崛起读书:BAACLgAFFH8KAAMQAAQJ4hKDDABIAQAQAAQJ4hKDDABIAQAGAAEJRA0/EABUAAAuAAQKfxgAAhAACAkWIJIbAMQCABAACAkWIJIbAMQCAAAA.',
['为好']='为好吃的而战:BAAALgAECggJDQAAAA==.',
['丿溫']='丿溫渘:BAAALgAECgIJAgAAAA==.',
['丿雲']='丿雲灬射手座:BAAALgAECgQJBAAAAA==.',
['乌哩']='乌哩哩:BAAALgAECgEJAgAAAA==.',
['乌托']='乌托喵:BAAALgAECgYJCwAAAA==.乌托彐飘逸:BAAALgAECgcJEwAAAA==.乌托飒:BAAALgAECgQJBAAAAA==.',
['乘風']='乘風破浪:BAABLgAFFH8FAAIMAAMJZwiLBQDCAAAMAAMJZwiLBQDCAAAAAA==.',
['九毛']='九毛萨:BAAALgADCgEJAgAAAA==.',
['乱舞']='乱舞之叶:BAAALgAECgIJBQAAAA==.',
['二刺']='二刺螈刀酱:BAAALgAECgYJCgAAAA==.二刺螈虎哥:BAAALgAECgYJCAAAAA==.',
['云中']='云中泪:BAAALgAECgEJAgAAAA==.',
['云依']='云依若梦:BAAALgADCgEJAQAAAA==.',
['五帝']='五帝:BAAALgAECgEJAgAAAA==.',
['五更']='五更雨:BAAALgAECgIJAgAAAA==.',
['五月']='五月空:BAAALgAECgMJAwAAAA==.',
['亚当']='亚当之手:BAAALgAECgEJAQAAAA==.',
['人形']='人形印钞机:BAAALgAECgQJBgAAAA==.',
['人间']='人间第一流:BAAALgAECgIJAgAAAA==.',
['仁族']='仁族法咝:BAAALgAECgYJCwAAAA==.',
['今天']='今天停网:BAAALgAECgQJBAAAAA==.',
['今朝']='今朝:BAAALgAECgcJDAAAAA==.',
['今生']='今生为爱狂:BAAALgAFFAIJBAAAAA==.',
['仙女']='仙女不生气:BAAALgAECgQJBAAAAA==.',
['令令']='令令:BAAALgAECgMJAwAAAA==.',
['任小']='任小术:BAAALgAECgUJCwAAAA==.任小邪:BAAALgAECgYJDAAAAA==.',
['任秋']='任秋玲:BAAALgAECgcJBgAAAA==.',
['伊俪']='伊俪荙蕊:BAAALgADCgIJAgAAAA==.',
['伊喵']='伊喵伊丸:BAAALgAECggJCAAAAA==.',
['伊扣']='伊扣伊丸:BAAALgAECgYJBgAAAA==.',
['伊森']='伊森维奥斯:BAAALgAECgUJBwAAAA==.',
['伊瑞']='伊瑞尔:BAAALgAFFAEJAgAAAA==.',
['伊衍']='伊衍夕:BAAALgAECgQJBgAAAA==.',
['伊鹿']='伊鹿德:BAAALgADCgMJAwAAAA==.',
['众光']='众光之光:BAAALgAECgYJEAAAAA==.',
['众神']='众神之怒火:BAABLgAECn8YAAIPAAkJLQU8aQAsAQAPAAkJLQU8aQAsAQAAAA==.众神之涟漪:BAAALgAECgcJBwAAAA==.',
['会走']='会走路的芒果:BAAALgAECgEJAQAAAA==.',
['传奇']='传奇开门术:BAAALgAECgEJAQAAAA==.',
['传说']='传说中的裂人:BAACLgAFFH8HAAISAAIJoSDBAwC6AAASAAIJoSDBAwC6AAAuAAQKfyYAAhIABwnfJDMDAPoCABIABwnfJDMDAPoCAAAA.',
['伤凋']='伤凋零:BAAALgAECgYJCQAAAA==.',
['伺机']='伺机打晕大佬:BAAALgAECgQJBAAAAA==.',
['你啊']='你啊:BAAALgAECgEJAQAAAA==.',
['你好']='你好拉个糖:BAAALgAECgYJCgAAAA==.',
['你就']='你就是对的人:BAAALgAECgYJCgAAAA==.',
['你才']='你才是矿脑壳:BAAALgAECgYJCwAAAA==.',
['你是']='你是我养的猪:BAAALgAECgMJAwAAAA==.',
['你的']='你的小可爱:BAAALgAECgUJBQAAAA==.',
['你空']='你空手来啊:BAAALgAFFAIJAgAAAA==.',
['佬夏']='佬夏:BAAALgAECgUJBQAAAA==.',
['佳洁']='佳洁士:BAAALgADCgYJBwAAAA==.',
['侑子']='侑子丶:BAAALgAFFAIJAgAAAA==.',
['依然']='依然爱不在意:BAAALgAECgUJCgAAAA==.依然饭特稀:BAAALgAECgQJBQAAAA==.',
['俊俊']='俊俊先生:BAABLgAECn8ZAAIGAAcJQRtsBwD0AQAGAAcJQRtsBwD0AQAAAA==.',
['倚楼']='倚楼听風雨:BAAALgAECgUJBQAAAA==.倚楼悲秋风:BAAALgAECgYJBgAAAA==.倚楼沐春雨:BAAALgAECgYJAwAAAA==.倚楼猎西风:BAAALgAECgIJAgAAAA==.倚楼观冬雪:BAAALgAECgcJEwAAAA==.',
['倚樓']='倚樓听風雨:BAAALgAECgQJBAAAAA==.倚樓听风雨:BAAALgAECgEJAQAAAA==.',
['假发']='假发:BAAALgAECgIJAgAAAA==.',
['偷了']='偷了一辈子:BAAALgAECgcJBwAAAA==.',
['偽谁']='偽谁落幕:BAAALgAFFAIJAgAAAA==.',
['傃顏']='傃顏:BAAALgAECgcJCgAAAA==.',
['傲剑']='傲剑笑苍穹:BAAALgAECgYJBgAAAA==.',
['傲嬌']='傲嬌:BAAALgADCgEJAgAAAA==.',
['元素']='元素降临:BAAALgAECgUJCgAAAA==.',
['元美']='元美丽:BAAALgAECgYJBgABLgAFFAIJAgAFAAAAAA==.',
['元老']='元老头:BAAALgAECgcJCAAAAA==.元老邪:BAAALgAECgkJBwAAAA==.',
['先鸽']='先鸽为敬:BAAALgAECgIJAgAAAA==.',
['光明']='光明鼎:BAAALgAECgEJAQAAAA==.',
['全力']='全力牛:BAAALgAECgQJBgAAAA==.',
['八万']='八万是只猫:BAAALgAECgQJBgAAAA==.',
['八剋']='八剋真牛马丶:BAAALgAFFAMJAwAAAA==.',
['八点']='八点四七七:BAAALgADCgUJBQAAAA==.',
['兰妙']='兰妙:BAABLgAFFH8IAAITAAQJKBd+BwBOAQATAAQJKBd+BwBOAQABLgAFFAYJEAATANsjAA==.',
['兰萱']='兰萱:BAAALgAFFAQJBAABLgAFFAYJEAATANsjAA==.',
['共鸣']='共鸣心焦:BAAALgADCgcJBwAAAA==.',
['典狱']='典狱厂:BAAALgAECgcJBwAAAA==.',
['再见']='再见心雨:BAAALgAECgcJBwAAAA==.',
['冥香']='冥香彼岸:BAABLgAFFH8FAAIDAAUJFRXbCwC+AQADAAUJFRXbCwC+AQAAAA==.',
['冷月']='冷月小妞:BAAALgAECgEJAQAAAA==.冷月戒灵:BAAALgAECgYJCgAAAA==.冷月耀阳:BAAALgAECgQJBAAAAA==.',
['冷眼']='冷眼旁观:BAAALgADCgEJAQAAAA==.',
['冷艳']='冷艳继母:BAAALgADCgYJBgAAAA==.',
['冻柠']='冻柠茶哦:BAAALgAECgYJBwAAAA==.',
['凉宫']='凉宫春日灬:BAAALgAFFAQJAQAAAA==.',
['凉拌']='凉拌大咕咕:BAABLgAFFH8FAAISAAIJbRmlAwC7AAASAAIJbRmlAwC7AAAAAA==.',
['凌婉']='凌婉儿:BAAALgAECgYJBgAAAA==.',
['减八']='减八十斤改名:BAAALgAECgcJDAAAAA==.',
['凝丶']='凝丶残月:BAAALgAECgUJCQAAAA==.',
['凹凸']='凹凸曼:BAAALgADCgEJAQAAAA==.',
['刘大']='刘大美:BAAALgAECgkJCQAAAA==.',
['刺胃']='刺胃:BAAALgAECgkJBAAAAA==.刺胃三:BAAALgAECgcJBwAAAA==.',
['前尘']='前尘应念:BAAALgAECgYJBgAAAA==.',
['功夫']='功夫邹邹:BAAALgAFFAIJAgAAAA==.',
['加鲁']='加鲁鲁啊:BAAALgADCgYJBgAAAA==.',
['包神']='包神气:BAAALgADCgcJCwAAAA==.',
['北子']='北子鸽鸽:BAAALgAECgcJBwAAAA==.',
['匿名']='匿名热心网友:BAAALgADCgQJBAABLgAFFAUJEQABAJwXAA==.',
['十二']='十二路谭腿:BAAALgAFFAEJAgAAAA==.',
['十五']='十五年老团:BAAALgAECgcJBwAAAA==.',
['十年']='十年老团长:BAAALgAECgUJBQAAAA==.',
['千层']='千层面:BAAALgAECgQJAwAAAA==.',
['千磨']='千磨万击:BAAALgAECgEJAQAAAA==.',
['千羽']='千羽猫咪:BAAALgAECgYJBwAAAA==.',
['半死']='半死死刑:BAAALgAECgYJEAAAAA==.',
['卡皮']='卡皮巴娜:BAAALgAECgIJAgAAAA==.',
['卡西']='卡西欧佩娅:BAAALgAFFAEJAQAAAA==.',
['受戒']='受戒:BAAALgADCgIJAgAAAA==.',
['变乖']='变乖:BAAALgAECgIJBAAAAA==.',
['古児']='古児玬:BAAALgAECgMJAwAAAA==.',
['可乐']='可乐泡泡:BAAALgAECgIJAgAAAA==.',
['可口']='可口可了:BAAALgADCgEJAQAAAA==.',
['可心']='可心丶丶:BAABLgAECn8VAAIUAAYJOxrGcQCkAQAUAAYJOxrGcQCkAQAAAA==.',
['可怕']='可怕的矮子:BAAALgAECgYJCQAAAA==.',
['可爱']='可爱的燕子:BAAALgAECgkJEwAAAA==.可爱饼饼:BAAALgAECgIJAgAAAA==.',
['右手']='右手的嗨:BAAALgADCgIJAgABLgAFFAQJDQAVAMwSAA==.',
['叶佳']='叶佳鑫:BAAALgAECgcJBwAAAA==.',
['叶冬']='叶冬冬:BAAALgAECgcJEgAAAA==.',
['叶灬']='叶灬修:BAAALgAECgkJDwAAAA==.',
['司二']='司二飞:BAAALgAECgMJAwAAAA==.',
['合波']='合波:BAAALgAECgYJCwAAAA==.',
['后跳']='后跳假死:BAAALgAECgQJCgAAAA==.',
['向愽']='向愽:BAAALgAECgcJBAABLgAFFAUJCQAWAAIQAA==.',
['听说']='听说过爱情:BAAALgAECgcJBwAAAA==.',
['吸二']='吸二瓦纳斯:BAAALgADCgYJBgAAAA==.',
['吹落']='吹落点点星:BAAALgADCgEJAQAAAA==.',
['吹雪']='吹雪入寒窗:BAAALgAFFAEJAQAAAA==.',
['告别']='告别黑暗:BAAALgAECgQJCgAAAA==.',
['呦呦']='呦呦切克闹:BAAALgAECgcJCAAAAA==.',
['呵呵']='呵呵你全家:BAAALgAECgMJAwAAAA==.呵呵折纸:BAAALgAECgYJBgAAAA==.',
['命运']='命运停驻之夜:BAAALgAECgUJBQAAAA==.',
['咕进']='咕进宝:BAACLgAFFH8KAAIXAAQJdx5kBgB/AQAXAAQJdx5kBgB/AQAuAAQKfxcAAhcACAmwJD0NAMUCABcACAmwJD0NAMUCAAAA.',
['咸鱼']='咸鱼的翻身:BAAALgAECgUJBQAAAA==.',
['哄哄']='哄哄小天后:BAAALgAECgkJDwAAAA==.',
['哆啦']='哆啦皮:BAAALgAECgMJAwAAAA==.',
['哆蕊']='哆蕊咪:BAAALgAECgYJBgAAAA==.',
['哈利']='哈利毛毛:BAABLgAFFH8FAAIUAAIJoAzGRACaAAAUAAIJoAzGRACaAAAAAA==.',
['哈吉']='哈吉米一:BAAALgAECgcJEAAAAA==.哈吉米二:BAAALgAECgYJDAAAAA==.',
['哈庫']='哈庫吶瑪塔塔:BAAALgAECgQJBAABLgAECgQJBQAFAAAAAA==.',
['哈籁']='哈籁尼尔:BAAALgAECgYJBgAAAA==.',
['哒哒']='哒哒打:BAAALgADCgEJAQAAAA==.',
['哟够']='哟够莱:BAAALgADCggJBAAAAA==.',
['哥德']='哥德里克二世:BAAALgAECgQJBwAAAA==.',
['哭过']='哭过就好:BAAALgADCgQJBAAAAA==.',
['啊悄']='啊悄:BAAALgAECgMJAwAAAA==.',
['啊麦']='啊麦:BAAALgAECgQJBQAAAA==.',
['喵小']='喵小白:BAAALgADCgQJBQAAAA==.',
['嗜血']='嗜血无形:BAABLgAFFH8JAAIJAAQJzyGVAACCAQAJAAQJzyGVAACCAQAAAA==.',
['嘎嘎']='嘎嘎清风:BAAALgAECgIJAgAAAA==.',
['嘛咪']='嘛咪贰号:BAAALgAECgMJAwAAAA==.',
['噩梦']='噩梦的旋律:BAAALgAFFAQJBAAAAA==.',
['四号']='四号小菜鸡:BAAALgAECgcJCQAAAA==.',
['四方']='四方不见:BAAALgAECgQJBwAAAA==.',
['回忆']='回忆里待续:BAAALgAECgEJAQAAAA==.',
['园上']='园上矛依未:BAAALgAECgQJBAAAAA==.',
['圆滚']='圆滚滚的正义:BAACLgAFFH8MAAMNAAQJzwmoBgAQAQANAAQJzwmoBgAQAQAOAAEJzA6JFQBOAAAuAAQKfx4AAw4ACAnVGbATAC4CAA4ACAnVGbATAC4CAA0ABgnjFC4xAGEBAAAA.',
['土牛']='土牛:BAACLgAFFH8KAAMPAAMJECIXBwAwAQAPAAMJECIXBwAwAQAWAAIJGhZpGwCpAAAuAAQKfxoAAw8ACAmuI9MQALMCAA8ABwkLI9MQALMCABYABwnOHy8lAPwBAAAA.',
['土豆']='土豆炖头皮屑:BAAALgAECgcJCwAAAA==.',
['圣佑']='圣佑教主:BAAALgAECgYJCAAAAA==.',
['圣光']='圣光忽悠您:BAAALgAECgEJAQAAAA==.圣光永驻:BAAALgAECgEJAQAAAA==.',
['圣息']='圣息之魂:BAAALgAECgMJAwAAAA==.',
['圣教']='圣教军小妹:BAAALgADCgUJBQAAAA==.',
['在下']='在下龙龙九:BAAALgAECgQJBQAAAA==.',
['地狱']='地狱咒怨:BAAALgAECgQJAwAAAA==.地狱小甲虫:BAAALgAECgEJAwAAAA==.',
['坏人']='坏人要倒霉了:BAAALgAECgQJBwAAAA==.',
['坏的']='坏的掉渣渣:BAAALgAECgQJBAAAAA==.',
['坚定']='坚定的小石头:BAAALgADCgMJBAAAAA==.',
['坦诚']='坦诚的人:BAAALgAECgQJBgABLgAFFAYJEwAOAA4YAA==.',
['埃索']='埃索瑞亚:BAAALgAFFAEJAQAAAA==.',
['埃辛']='埃辛诺斯血牙:BAAALgAECgYJDQAAAA==.',
['堕落']='堕落木有爱情:BAAALgAECgMJAwAAAA==.',
['塔托']='塔托提斯:BAAALgAFFAQJBAAAAA==.',
['塔西']='塔西格:BAAALgAECgIJAwAAAA==.',
['墓室']='墓室二零二六:BAAALgAECgIJAgAAAA==.',
['墨义']='墨义:BAABLgAFFH8FAAMPAAMJVBWPCgANAQAPAAMJVBWPCgANAQAWAAEJuQFgKwBEAAAAAA==.',
['墨墨']='墨墨的墨:BAAALgAECgIJAgAAAA==.',
['墨晓']='墨晓:BAAALgAECgQJBQAAAA==.',
['士米']='士米:BAAALgAECgEJAQAAAA==.',
['壮熊']='壮熊:BAAALgADCgIJAgAAAA==.',
['壹佰']='壹佰個筱德:BAAALgAECgQJBAAAAA==.',
['壹剑']='壹剑飘雪:BAAALgADCgEJAQAAAA==.',
['壹原']='壹原丶侑子:BAAALgADCgIJAgAAAA==.',
['夏尔']='夏尔王大锤:BAAALgAECggJCwAAAA==.',
['夏末']='夏末:BAAALgAECgcJDQAAAA==.夏末一秋至:BAAALgAECgMJAwAAAA==.',
['夏猎']='夏猎:BAAALgAECgYJDAAAAA==.',
['夏目']='夏目灬:BAAALgAECgQJBgAAAA==.',
['夏祭']='夏祭八曲:BAAALgAECgcJBQAAAA==.',
['夕阳']='夕阳下的风影:BAAALgAECgUJBQAAAA==.',
['夜叶']='夜叶:BAAALgAECgYJBgABLgAFFAgJAQAFAAAAAA==.',
['夜太']='夜太美:BAAALgAECgUJBQAAAA==.',
['夜枼']='夜枼隨風:BAAALgAFFAEJAQAAAA==.',
['大健']='大健健:BAAALgAECgcJEgAAAA==.',
['大土']='大土皮:BAAALgAECgYJCQAAAA==.',
['大屁']='大屁屁妞:BAAALgAECgYJBgAAAA==.',
['大橘']='大橘子吖:BAAALgAECgEJAQAAAA==.',
['大炮']='大炮一号:BAAALgAECgUJBQAAAA==.大炮三号:BAAALgAECgQJBAAAAA==.大炮二号:BAAALgAECgYJBgAAAA==.大炮四号:BAAALgAECgYJBgAAAA==.',
['大祭']='大祭司鳄梨:BAAALgAFFAMJBAAAAA==.',
['大笑']='大笑江湖:BAAALgADCgEJAQAAAA==.',
['大约']='大约在春季:BAAALgAECgEJAQAAAA==.',
['大野']='大野渊:BAAALgAECgUJBQAAAA==.',
['大鲤']='大鲤鱼崔先生:BAAALgADCgUJBQAAAA==.',
['大龄']='大龄女看就娶:BAAALgAECgUJBQAAAA==.',
['天下']='天下帝尊:BAAALgAFFAEJAQAAAA==.',
['天使']='天使若彼邻:BAAALgAECgEJAQAAAA==.',
['天傲']='天傲孤云:BAABLgAFFH8GAAIDAAIJ7xNpIQCwAAADAAIJ7xNpIQCwAAAAAA==.',
['天地']='天地最人:BAABLgAFFH8FAAIDAAMJCAxTMADyAAADAAMJCAxTMADyAAAAAA==.',
['天涯']='天涯同此心:BAAALgADCgEJAQAAAA==.',
['天王']='天王盖的虎:BAAALgAECgIJAgAAAA==.',
['天秤']='天秤术术:BAABLgAFFH8EAAIBAAQJQxyODAB3AQABAAQJQxyODAB3AQAAAA==.',
['天翼']='天翼之羽:BAAALgAECgQJAQAAAA==.',
['天职']='天职小玉:BAAALgADCgUJBQAAAA==.',
['太寿']='太寿鸠毛:BAAALgAECgEJAQAAAA==.',
['契爷']='契爷:BAAALgADCgYJBgAAAA==.',
['奔星']='奔星:BAAALgAECggJCAAAAA==.',
['奔跑']='奔跑小土豆:BAAALgAECgEJAQAAAA==.奔跑小豌豆:BAAALgAECgUJBQAAAA==.',
['奥蕾']='奥蕾丽鸭:BAAALgAECgMJAwABLgAECgUJBQAFAAAAAA==.',
['女王']='女王灬范儿:BAAALgAECgEJAQAAAA==.',
['女神']='女神下凡:BAAALgADCgUJBQAAAA==.',
['好色']='好色冲冲:BAAALgAECgEJAQAAAA==.',
['如依']='如依似水:BAAALgADCgUJCAAAAA==.',
['妄想']='妄想当英雄:BAAALgAECgEJAQAAAA==.',
['妖妖']='妖妖灵丶:BAAALgAECgcJDAAAAA==.',
['妡妧']='妡妧姀:BAAALgAECgUJBQAAAA==.',
['妹抖']='妹抖龙康娜酱:BAACLgAFFH8NAAIQAAQJ3RS2BABeAQAQAAQJ3RS2BABeAQAuAAQKfyIAAhAACQmEH5sPABIDABAACQmEH5sPABIDAAAA.',
['委琐']='委琐的西西:BAAALgAECgcJBwAAAA==.',
['娜娜']='娜娜蜜:BAAALgAECgYJBgAAAA==.',
['娜歌']='娜歌湛事:BAAALgAFFAMJAwAAAA==.',
['婀娜']='婀娜:BAAALgADCgMJAwAAAA==.',
['媚儿']='媚儿玛仙:BAAALgAECgEJAQAAAA==.',
['子月']='子月十五:BAABLgAFFH8OAAIGAAQJVA5bCgA1AQAGAAQJVA5bCgA1AQAAAA==.',
['孟瑶']='孟瑶:BAAALgAFFAIJAgAAAA==.',
['季柳']='季柳波:BAAALgAECgYJBgAAAA==.',
['季風']='季風:BAAALgAECgMJAwAAAA==.',
['宇智']='宇智波鼬:BAAALgADCgEJAQAAAA==.',
['安东']='安东尼大龙:BAAALgADCgEJAQAAAA==.',
['安心']='安心明灯:BAACLgAFFH8IAAIYAAMJ+gOAFQC3AAAYAAMJ+gOAFQC3AAAuAAQKfxQAAhgACQnPDWU7ALcBABgACQnPDWU7ALcBAAAA.',
['安河']='安河桥:BAAALgAECgUJBwAAAA==.',
['安雅']='安雅娜:BAAALgADCgMJAwAAAA==.',
['完美']='完美骑士:BAAALgAECgIJAgAAAA==.',
['宝宝']='宝宝楽楽:BAAALgAECgYJCQAAAA==.',
['宥宥']='宥宥宝贝:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞为谁:BAAALgAFFAMJAwAAAA==.寂寞之牛:BAAALgAECgQJAwAAAA==.寂寞滴多多:BAAALgAECgYJCgAAAA==.寂寞滴巧巧:BAAALgAECggJDAAAAA==.寂寞滴犬妞:BAAALgAECgcJBwAAAA==.寂寞滴琪琪:BAAALgAECggJCgAAAA==.寂寞滴粗茶:BAAALgAECgkJDwAAAA==.寂寞集团:BAAALgAECgcJCAAAAA==.',
['寂寥']='寂寥之小心心:BAAALgAECgYJEwAAAA==.',
['密语']='密语暖人心:BAAALgADCgMJAwAAAA==.',
['寇沃']='寇沃:BAAALgAECgcJBwAAAA==.',
['富贵']='富贵铲粑粑官:BAAALgADCggJCAAAAA==.',
['富阳']='富阳人民:BAAALgAECgUJBQAAAA==.',
['寡仔']='寡仔:BAAALgAECgMJAwAAAA==.',
['寵辱']='寵辱不驚:BAAALgAECgYJBgAAAA==.',
['射就']='射就是正义:BAAALgAFFAQJBAAAAA==.',
['小丿']='小丿野性:BAAALgADCgMJAwAAAA==.',
['小仙']='小仙女不生气:BAABLgAFFH8NAAITAAQJYBjLBgBYAQATAAQJYBjLBgBYAQAAAA==.',
['小女']='小女賊乖:BAAALgADCgQJAQAAAA==.',
['小寳']='小寳未来:BAAALgAECgIJAgAAAA==.',
['小小']='小小玄奘:BAAALgAECgIJAgAAAA==.',
['小德']='小德鲁医:BAABLgAFFH8FAAMXAAMJ9hcuFACiAAAXAAMJ9hcuFACiAAAYAAIJ8gxGHACLAAAAAA==.',
['小月']='小月亮:BAAALgAECgQJBQAAAA==.',
['小熊']='小熊妞妞:BAAALgAECgYJBgAAAA==.',
['小白']='小白:BAAALgAFFAIJAwAAAA==.',
['小笑']='小笑嘻小:BAAALgADCgUJBQAAAA==.',
['小肥']='小肥罩:BAAALgAFFAQJBAAAAA==.',
['小花']='小花明日香:BAAALgAECgUJCQAAAA==.',
['小菊']='小菊微微开:BAAALgADCgEJAQAAAA==.',
['小邓']='小邓子乐乐:BAAALgAECgIJAQABLgAFFAcJCQAHALslAA==.',
['少女']='少女终结者:BAAALgAECgIJAgAAAA==.',
['少爷']='少爷心太乱:BAAALgAECgUJCAAAAA==.',
['尚雅']='尚雅:BAAALgADCgEJAQAAAA==.',
['尨牙']='尨牙崽:BAAALgAECgYJBgAAAA==.',
['就想']='就想碎觉:BAAALgAECgcJDQAAAA==.',
['就是']='就是这么瘦:BAAALgADCgEJAQAAAA==.',
['就要']='就要阿凡达丶:BAAALgAECgUJCwAAAA==.',
['尹系']='尹系悦:BAAALgAECgkJBwAAAA==.',
['层楼']='层楼:BAAALgAECgcJDgAAAA==.',
['山东']='山东机:BAAALgADCgEJAQAAAA==.',
['山川']='山川映海:BAACLgAFFH8LAAIGAAUJzhiRAgDKAQAGAAUJzhiRAgDKAQAuAAQKfxUAAgYACAk+JMsGAP8CAAYACAk+JMsGAP8CAAAA.',
['山藥']='山藥:BAAALgAECgYJBwAAAA==.',
['岁岁']='岁岁長欢丶:BAAALgAECgIJAgAAAA==.',
['岚烬']='岚烬:BAAALgAECgcJBwAAAA==.',
['川中']='川中小德:BAAALgAECgQJAwAAAA==.',
['巡山']='巡山小旋风:BAAALgADCgYJBgAAAA==.',
['左炔']='左炔诺孕酮:BAAALgAECgMJBgAAAA==.',
['帕特']='帕特里奇昂:BAAALgAECgcJDAAAAA==.',
['帕西']='帕西瓦尔:BAABLgAFFH8HAAIQAAMJPBcwFgD6AAAQAAMJPBcwFgD6AAAAAA==.',
['常山']='常山赵纸虫:BAAALgAECgcJEwAAAA==.',
['年度']='年度之歌:BAAALgAECgEJAQAAAA==.',
['幸运']='幸运之欧皇:BAAALgAECgYJBwAAAA==.',
['幻滅']='幻滅:BAAALgAECgEJAQAAAA==.',
['幽云']='幽云:BAAALgAECgQJBQAAAA==.',
['异丙']='异丙肾上腺素:BAAALgADCgEJAQAAAA==.',
['张教']='张教官:BAAALgAFFAQJBAAAAA==.',
['张日']='张日山:BAAALgAECgYJBgAAAA==.',
['弥海']='弥海砂:BAACLgAFFH8RAAIZAAUJTSMBAgDwAQAZAAUJTSMBAgDwAQAuAAQKfyEAAhkACAndJe4CAHYDABkACAndJe4CAHYDAAAA.',
['彦祖']='彦祖丶宝宝:BAAALgAECgcJCgAAAA==.彦祖丶心跳:BAAALgAECgEJAQAAAA==.',
['彬乀']='彬乀:BAAALgAFFAEJAQAAAA==.',
['影眸']='影眸:BAAALgAECgMJAwAAAA==.',
['影织']='影织空岚:BAAALgAECgUJBQAAAA==.',
['後悔']='後悔:BAAALgAECgkJCQAAAA==.',
['微笑']='微笑里的宠溺:BAAALgAECgYJBwAAAA==.',
['德到']='德到你的心:BAAALgAFFAQJBAAAAA==.',
['心丶']='心丶跳:BAAALgAFFAEJAgAAAA==.',
['心芮']='心芮丶丶:BAAALgAECgYJCQAAAA==.',
['忠诚']='忠诚的人:BAAALgAECgMJAwABLgAFFAYJEwAOAA4YAA==.',
['快乐']='快乐的欣欣:BAAALgAECgYJBgAAAA==.',
['快扶']='快扶我还能送:BAAALgAECgEJAQAAAA==.',
['快跑']='快跑啊小仙女:BAABLgAFFH8FAAIYAAMJ0R5dDQARAQAYAAMJ0R5dDQARAQAAAA==.',
['念念']='念念不忘:BAAALgAECgUJDQAAAA==.',
['怒风']='怒风的猎手:BAAALgAECgYJBgAAAA==.',
['怕毛']='怕毛毛虫鸭:BAAALgAECgIJAgAAAA==.',
['怪乄']='怪乄怪:BAAALgAECgYJDwAAAA==.',
['总有']='总有少年来:BAAALgAECgEJAQAAAA==.',
['恋色']='恋色星空:BAAALgAECgEJAQAAAA==.',
['恶梦']='恶梦惊醒:BAAALgADCgIJAgAAAA==.',
['恶魔']='恶魔波比:BAAALgAECgYJCQAAAA==.恶魔钙片:BAAALgAECgEJAQAAAA==.',
['悲伤']='悲伤的换膜师:BAAALgAECgQJBAAAAA==.悲伤的橙劫骑:BAABLgAFFH8MAAIQAAQJWyTeAAC0AQAQAAQJWyTeAAC0AQAAAA==.',
['惩戒']='惩戒暴血:BAAALgADCgcJCAAAAA==.',
['惩肃']='惩肃:BAAALgAECgYJCgAAAA==.',
['愉悦']='愉悦的谐迪凯:BAAALgAFFAEJAQAAAA==.',
['愚行']='愚行者贝琳:BAAALgAECgYJCQAAAA==.',
['愤怒']='愤怒的寒冰贱:BAAALgAECgMJBwABLgAECgQJBwAFAAAAAA==.',
['慈怀']='慈怀药王:BAAALgAECgMJAwAAAA==.',
['慈悲']='慈悲度魂落:BAAALgADCgEJAQAAAA==.',
['懒冲']='懒冲懒:BAAALgAECgcJEQAAAA==.',
['懒得']='懒得取名:BAAALgAECgMJAwAAAA==.',
['懒猪']='懒猪丶起床丷:BAAALgADCgMJAwAAAA==.',
['戈多']='戈多:BAAALgAFFAEJAQAAAA==.',
['我们']='我们仨炫炸鸡:BAAALgAECgMJAwAAAA==.',
['我心']='我心不错:BAAALgAFFAEJAQAAAA==.我心似光:BAAALgAECgIJAwAAAA==.',
['我才']='我才尴尬呢:BAAALgAFFAMJBAAAAA==.',
['我按']='我按错大蹦:BAAALgAECgYJEgABLgAECgQJBAAFAAAAAA==.',
['我的']='我的圣光阿:BAAALgADCgEJAQAAAA==.',
['我真']='我真是妹子:BAAALgAECgUJBQAAAA==.',
['我错']='我错老:BAAALgAECgYJEgAAAA==.',
['战丶']='战丶魂:BAAALgAECgQJBgAAAA==.',
['扒手']='扒手喵喵:BAAALgAECgMJAwAAAA==.',
['打不']='打不死的:BAAALgAECgQJBAAAAA==.',
['抬手']='抬手就毛:BAAALgAECgYJBgAAAA==.',
['拉弓']='拉弓不麝贱:BAAALgAFFAEJAQAAAA==.',
['招蜂']='招蜂丶引蝶:BAAALgAECgEJAQAAAA==.',
['拳头']='拳头弟弟:BAACLgAFFH8HAAIDAAUJ8hQ1DAC7AQADAAUJ8hQ1DAC7AQAuAAQKfxoAAgMACQkGIh8WACQDAAMACQkGIh8WACQDAAAA.',
['拿盾']='拿盾也扛不住:BAAALgAECgEJAgAAAA==.',
['持盾']='持盾:BAAALgAFFAEJAQAAAA==.',
['挽手']='挽手說梦話:BAAALgAECgcJBwAAAA==.',
['提啦']='提啦米酥:BAABLgAFFH8FAAIQAAUJOQSiCQBgAQAQAAUJOQSiCQBgAQAAAA==.',
['提姆']='提姆丶:BAAALgAECgIJAgAAAA==.',
['携宠']='携宠闯天涯:BAAALgAECgYJBgAAAA==.',
['撒拉']='撒拉:BAAALgAECgIJBAAAAA==.',
['放一']='放一点冰块:BAABLgAECn8UAAIQAAgJsBSrRgAPAgAQAAgJsBSrRgAPAgAAAA==.',
['敛星']='敛星至尊版:BAAALgAECgYJDAAAAA==.',
['数珠']='数珠丸恒次:BAAALgAECgYJAwAAAA==.',
['新钙']='新钙中钙:BAAALgADCgMJAwAAAA==.',
['无情']='无情的小昕:BAAALgAECgYJCgAAAA==.',
['无敌']='无敌二二:BAAALgAFFAEJAQAAAA==.无敌橙子大王:BAAALgAECgMJAwAAAA==.',
['无痕']='无痕月:BAAALgADCgMJBQAAAA==.',
['无糖']='无糖配方:BAAALgAECgQJBwAAAA==.',
['时间']='时间如流水:BAAALgAECgYJDQAAAA==.',
['明月']='明月清风:BAAALgAECgQJBQAAAA==.',
['星月']='星月长明:BAAALgAECgYJBgAAAA==.',
['星语']='星语夜客:BAACLgAFFH8FAAMaAAQJMwtQAgDrAAAaAAMJPghQAgDrAAAUAAIJMgo0SwCCAAAuAAQKfxoAAhQACAk+HpcpAJMCABQACAk+HpcpAJMCAAAA.',
['春秋']='春秋恍惚:BAAALgAFFAIJBAAAAA==.',
['春风']='春风拂槛丶:BAABLgAECn8WAAMUAAYJcSA+awC1AQAUAAYJcSA+awC1AQAbAAEJoQ2aRwAqAAAAAA==.',
['晨曦']='晨曦封尘:BAAALgAFFAEJAQAAAA==.',
['景恬']='景恬:BAAALgAECgYJEAAAAA==.',
['景暄']='景暄:BAAALgAECgYJCAAAAA==.',
['晴天']='晴天的向往:BAAALgAFFAIJAgAAAA==.',
['暗影']='暗影界的正义:BAAALgAECggJCAAAAA==.',
['暗黑']='暗黑之瞳:BAAALgAECgkJCQAAAA==.',
['暴富']='暴富:BAAALgADCgIJAgAAAA==.',
['暴武']='暴武逗钉:BAAALgADCgYJBgAAAA==.',
['暴躁']='暴躁逗钉:BAAALgADCgcJCAAAAA==.',
['暴風']='暴風烈酒丶沉:BAAALgAFFAEJAgAAAA==.',
['曾小']='曾小仙:BAAALgAECgEJAwAAAA==.曾小贤:BAAALgAECgIJAgAAAA==.',
['最强']='最强射手:BAAALgAECgIJAgAAAA==.',
['月下']='月下紫艳:BAAALgAECgYJBgAAAA==.',
['月凌']='月凌宇:BAAALgAECgMJAwAAAA==.',
['月影']='月影追风:BAAALgAECgYJBgAAAA==.',
['月牙']='月牙弯之泪:BAAALgAECgEJAQAAAA==.',
['月色']='月色妖言:BAAALgAECgQJBAAAAA==.',
['月落']='月落不蹄:BAAALgAECggJDgAAAA==.月落猴啼:BAAALgAECgQJBAAAAA==.月落羊啼:BAAALgAECgYJBgAAAA==.月落蛇缠:BAAALgAECgcJCAAAAA==.月落馬啼:BAAALgAECgEJAQAAAA==.月落鳳鳴:BAAALgAECgcJBwAAAA==.月落鼠啼:BAAALgAECgkJDwAAAA==.',
['有医']='有医保我先上:BAAALgAECgEJAwAAAA==.',
['木叶']='木叶之梦:BAAALgADCgEJAQAAAA==.',
['木子']='木子李:BAAALgAECgYJCQAAAA==.',
['未闻']='未闻死骑:BAAALgAFFAIJAgAAAA==.',
['末世']='末世陨星:BAAALgAFFAIJAgAAAA==.',
['术术']='术术木木术:BAAALgAECgQJBAAAAA==.',
['机智']='机智的小飞:BAAALgAECgcJDAABLgAFFAYJAwAFAAAAAA==.',
['机械']='机械师郭达:BAAALgAECgYJBgAAAA==.',
['杀吧']='杀吧克:BAAALgAFFAEJAQAAAA==.',
['李大']='李大王:BAAALgAECgYJBgAAAA==.',
['李白']='李白的酒:BAAALgADCgIJAgAAAA==.',
['李镓']='李镓锟:BAAALgADCgMJAwAAAA==.',
['束光']='束光似水:BAAALgAFFAIJBAAAAA==.',
['杠子']='杠子:BAAALgAECgQJBAAAAA==.',
['来一']='来一发丶:BAAALgAECgEJAQAAAA==.',
['来今']='来今往古:BAAALgAECgEJAQAAAA==.',
['枯藤']='枯藤老樹:BAAALgAECgYJBgAAAA==.',
['柔柔']='柔柔的小怪兽:BAAALgAECgYJCAAAAA==.',
['柯圣']='柯圣:BAAALgAECgYJEAAAAA==.',
['树熊']='树熊丨天照:BAAALgADCgIJAgAAAA==.',
['栩之']='栩之狼:BAAALgAECgIJAgAAAA==.',
['格斯']='格斯:BAAALgAECgkJCQAAAA==.',
['格里']='格里菲因:BAAALgAECgEJAQAAAA==.',
['桃百']='桃百百:BAAALgAFFAEJAQAAAA==.桃百萬:BAABLgAFFH8FAAIBAAMJjAyAJADxAAABAAMJjAyAJADxAAAAAA==.',
['桜月']='桜月:BAAALgAECgEJAQAAAA==.',
['梅芳']='梅芳依旧:BAAALgAECgYJCAAAAA==.',
['梓熙']='梓熙:BAAALgAECgkJCQAAAA==.',
['梦回']='梦回星月夜:BAAALgAECgUJBwAAAA==.',
['梦貘']='梦貘丨秦:BAABLgAECn8WAAIPAAcJVxBrPQC5AQAPAAcJVxBrPQC5AQAAAA==.',
['椿兮']='椿兮如淋:BAAALgAECgkJBwAAAA==.',
['橘子']='橘子味果汁:BAAALgADCgkJCgAAAA==.橘子汁儿:BAAALgAFFAIJBAAAAA==.',
['橙装']='橙装收割者:BAAALgAECgcJBwAAAA==.',
['檸檬']='檸檬不萌:BAABLgAECn8XAAIYAAcJmyKVEgChAgAYAAcJmyKVEgChAgAAAA==.',
['欣欣']='欣欣:BAAALgAECgYJDAAAAA==.',
['止战']='止战之殤丶:BAAALgAECgEJAgAAAA==.',
['正在']='正在加载:BAAALgAECgYJCgAAAA==.',
['比比']='比比拉布:BAAALgADCgMJAwAAAA==.',
['毫无']='毫无压力:BAAALgADCgcJBgAAAA==.',
['民法']='民法:BAAALgADCgIJAgAAAA==.',
['氪劳']='氪劳蒂钨斯:BAAALgAECgEJAgAAAA==.',
['水书']='水书诗:BAAALgAECgkJCQAAAA==.',
['水井']='水井坊升:BAAALgADCgEJAQAAAA==.水井坊德:BAAALgAECgQJBAAAAA==.水井坊烈:BAAALgAECgQJBQAAAA==.',
['水月']='水月轻风:BAAALgAECgYJBgAAAA==.',
['水滨']='水滨祓禊:BAAALgAECgQJBAAAAA==.',
['水筱']='水筱芥:BAAALgAECggJDAAAAA==.',
['水绮']='水绮施:BAABLgAECn8ZAAIQAAkJKyFRAQDqAgAQAAkJKyFRAQDqAgAAAA==.',
['汐耀']='汐耀龙辉:BAABLgAFFH8GAAIcAAMJ3RlTDQAJAQAcAAMJ3RlTDQAJAQAAAA==.',
['沂水']='沂水寒殇:BAAALgAECgYJBwAAAA==.',
['沈幼']='沈幼楚:BAAALgAECgQJBwAAAA==.',
['沉星']='沉星:BAAALgAECgEJAgAAAA==.',
['沉睡']='沉睡的小绵羊:BAAALgADCgYJBwAAAA==.',
['沐初']='沐初:BAAALgAECgQJBQAAAA==.',
['沙漠']='沙漠大怪犬:BAAALgAECgYJBwAAAA==.沙漠看夕阳:BAAALgADCgEJAQAAAA==.',
['没事']='没事转圈圈:BAABLgAECn8VAAIQAAgJJSIqKACEAgAQAAgJJSIqKACEAgAAAA==.',
['没得']='没得兄弟:BAAALgADCgUJBQAAAA==.',
['沭米']='沭米:BAAALgAECgEJAQAAAA==.',
['法王']='法王宝诰:BAABLgAFFH8KAAMKAAQJpAtNCgDEAAAKAAQJpAtNCgDEAAATAAIJZAfGGwCJAAAAAA==.',
['法神']='法神阿满:BAAALgAECgQJBAAAAA==.法神阿红:BAAALgAECgYJAwAAAA==.',
['泠雨']='泠雨:BAAALgADCgEJAQAAAA==.',
['泡饭']='泡饭:BAACLgAFFH8HAAIQAAMJECVMDABJAQAQAAMJECVMDABJAQAuAAQKfxQAAhAABwmpJQ8aAM0CABAABwmpJQ8aAM0CAAAA.',
['泪娃']='泪娃娃:BAAALgAECgEJAQAAAA==.',
['泪眼']='泪眼愁眉:BAAALgAECgYJBgAAAA==.',
['泪雨']='泪雨寻情:BAAALgAECgEJAgAAAA==.',
['泰兰']='泰兰的怒风:BAAALgAECgEJAQAAAA==.',
['泰菲']='泰菲力:BAAALgAECgYJAQAAAA==.',
['泰雅']='泰雅丨星光:BAAALgAECgMJBQAAAA==.',
['洛河']='洛河:BAAALgAECgEJAQAAAA==.',
['浮世']='浮世华:BAAALgADCgIJAgAAAA==.',
['浮云']='浮云逍遥:BAAALgAECgUJBwAAAA==.',
['浮生']='浮生似梦:BAAALgAECgEJAQAAAA==.',
['海之']='海之审判:BAAALgADCgYJBgAAAA==.',
['海格']='海格妮丝:BAAALgAECgcJBwAAAA==.',
['海蓝']='海蓝德:BAAALgAFFAIJAgAAAA==.',
['海谢']='海谢拉:BAAALgAECgQJBQAAAA==.',
['海银']='海银:BAAALgAECgYJBwAAAA==.',
['淡水']='淡水微斓:BAAALgAECgQJBgAAAA==.',
['深邃']='深邃:BAAALgAECgQJBAAAAA==.',
['清欢']='清欢灬:BAACLgAFFH8NAAIDAAQJqB2ABgB3AQADAAQJqB2ABgB3AQAuAAQKfycAAgMACAmvIy8RAEEDAAMACAmvIy8RAEEDAAAA.',
['清风']='清风:BAAALgAECgIJAgAAAA==.',
['温柔']='温柔一箭:BAAALgAECgYJCQAAAA==.',
['源氏']='源氏:BAAALgAECgQJBwAAAA==.',
['源素']='源素:BAAALgAECgEJAwAAAA==.',
['滚丶']='滚丶糖门:BAAALgAECgYJCwAAAA==.',
['满满']='满满全是爱:BAAALgADCgQJBAAAAA==.',
['满艺']='满艺先生:BAAALgAECgMJCQAAAA==.',
['漠邪']='漠邪:BAAALgAECgYJDwAAAA==.',
['漾漾']='漾漾:BAAALgAFFAMJAwAAAA==.',
['潘敏']='潘敏俺之嫁:BAAALgAECgYJCAAAAA==.',
['潶色']='潶色喵喵:BAAALgAECgYJCAAAAA==.潶色彼岸椛:BAABLgAECn8aAAIdAAcJ1yRtAQCvAgAdAAcJ1yRtAQCvAgAAAA==.',
['灬小']='灬小确幸灬:BAAALgAECgYJBgAAAA==.',
['灰灰']='灰灰僧:BAAALgADCgYJBgAAAA==.灰灰狂:BAABLgAFFH8HAAIUAAMJ/xppIgAOAQAUAAMJ/xppIgAOAQAAAA==.',
['灰色']='灰色拥抱:BAAALgAECgEJAQAAAA==.',
['灵打']='灵打按键一:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂小豆儿:BAAALgAFFAEJAQABLgAFFAMJBgAYAP0IAA==.',
['炸毛']='炸毛小太妹:BAAALgADCgYJBgAAAA==.',
['炼奶']='炼奶西多士:BAAALgAFFAEJAQAAAA==.',
['炽魂']='炽魂:BAABLgAECn8UAAMUAAgJjhlNRwAeAgAUAAgJjhlNRwAeAgAbAAEJygcySgAjAAAAAA==.',
['炽魇']='炽魇衍夕:BAAALgAECgIJAgAAAA==.',
['烈焰']='烈焰玄甲:BAAALgAECgEJAgAAAA==.烈焰男爵:BAAALgAECgEJAQAAAA==.',
['烈空']='烈空:BAAALgADCgEJAQAAAA==.',
['烈酒']='烈酒敬余年:BAAALgAECgYJEgAAAA==.烈酒敬红颜:BAACLgAFFH8JAAILAAMJWBOSBwAEAQALAAMJWBOSBwAEAQAuAAQKfykAAgsACAmeIBAQANICAAsACAmeIBAQANICAAAA.',
['烟屿']='烟屿佳人:BAAALgADCgYJBgAAAA==.',
['烟花']='烟花飞满天:BAAALgADCgcJBwAAAA==.',
['無血']='無血不歡:BAAALgAECgEJAwAAAA==.',
['無言']='無言之痛:BAAALgAECgUJBAAAAA==.',
['煋灀']='煋灀:BAAALgAECgcJBQAAAA==.',
['煜掌']='煜掌门:BAAALgAECgUJBQAAAA==.',
['煮只']='煮只鱼好吗丶:BAAALgAECgcJAQAAAA==.',
['熊喵']='熊喵吃西瓜:BAAALgAECgIJAgAAAA==.',
['熊熊']='熊熊猫猫:BAAALgAECgMJAwAAAA==.',
['爆炸']='爆炸妹:BAAALgAECgUJCwAAAA==.',
['爱丽']='爱丽丝魏德尔:BAAALgADCgMJAwAAAA==.',
['爱偷']='爱偷鱼的猫:BAAALgAECgYJBgAAAA==.',
['爱的']='爱的圈圈:BAAALgADCgEJAQAAAA==.',
['爱随']='爱随风:BAAALgADCgQJBAAAAA==.',
['牧奶']='牧奶姨:BAAALgAECgYJEgABLgAFFAYJBQAeAOMOAA==.',
['牧毒']='牧毒法:BAAALgAECgcJCAABLgAECggJFwADAIobAA==.牧毒雨:BAAALgAECgQJBAAAAA==.',
['牧羊']='牧羊帅人:BAAALgAECgMJAwAAAA==.',
['特仑']='特仑苏丶奶妈:BAABLgAFFH8FAAITAAIJqxqbFQCrAAATAAIJqxqbFQCrAAAAAA==.',
['特莉']='特莉休:BAAALgAECgIJAgAAAA==.',
['狂暴']='狂暴呕吐没蓝:BAAALgAECgcJBwAAAA==.狂暴小龙虾:BAAALgAFFAMJBAAAAA==.',
['狂热']='狂热审判:BAABLgAECn8ZAAIQAAcJ4CCtKACCAgAQAAcJ4CCtKACCAgAAAA==.',
['狂野']='狂野教主:BAAALgAECgUJBgAAAA==.狂野男孩:BAAALgAECgUJBQAAAA==.',
['狂风']='狂风之击:BAAALgAECgUJCAAAAA==.',
['狐视']='狐视眈眈:BAAALgAECgcJBwAAAA==.',
['猎杀']='猎杀红烧肉:BAAALgAECgEJAQAAAA==.',
['猎灬']='猎灬小豆儿:BAAALgAECgQJAQAAAA==.',
['猛的']='猛的一咪:BAAALgAECgcJBwAAAA==.',
['猜疑']='猜疑嫉妒:BAAALgAECgUJBQAAAA==.',
['猪大']='猪大爷:BAABLgAFFH8HAAIDAAMJ5xv8FAAOAQADAAMJ5xv8FAAOAQAAAA==.',
['猫猫']='猫猫爱咬人:BAAALgAECgEJAQAAAA==.',
['猴哥']='猴哥求支援:BAAALgAECgMJAwAAAA==.',
['玉浦']='玉浦团:BAAALgAECgEJAQAAAA==.',
['玉龙']='玉龙元伯:BAAALgADCgYJBgAAAA==.',
['王子']='王子鼎:BAAALgADCgUJBQAAAA==.',
['王忻']='王忻至:BAAALgAECgEJAgAAAA==.',
['王梦']='王梦迪:BAAALgAECgYJCQAAAA==.',
['琇儿']='琇儿:BAAALgAECgMJBAAAAA==.',
['琥珀']='琥珀:BAAALgAECgIJBQAAAA==.',
['琪琪']='琪琪:BAABLgAECn8gAAIDAAkJ9SApFAAvAwADAAkJ9SApFAAvAwAAAA==.',
['琳琅']='琳琅山老腊肉:BAAALgAECgUJBQAAAA==.',
['瑟魂']='瑟魂艾莉丝:BAAALgAECgMJAgAAAA==.',
['璀璨']='璀璨丨星光:BAAALgADCgIJAgAAAA==.',
['瓦学']='瓦学弟:BAAALgAECgMJAwAAAA==.',
['瓦里']='瓦里安乌瑞蒽:BAAALgAFFAEJAgAAAA==.',
['甜崽']='甜崽小术:BAAALgAFFAQJBAAAAA==.甜崽小橙:BAAALgAECgYJDQAAAA==.',
['生气']='生气气:BAAALgAECgMJAgAAAA==.',
['用脚']='用脚走路:BAAALgAECgYJEwAAAA==.',
['疯狂']='疯狂吃货:BAAALgAECgQJCAAAAA==.疯狂的吃货:BAAALgAECgEJAQAAAA==.',
['疯陌']='疯陌戮:BAAALgAECgUJBQAAAA==.',
['瘸子']='瘸子:BAAALgAECgEJAgAAAA==.',
['登临']='登临渊:BAAALgADCgEJAQAAAA==.',
['白小']='白小舟:BAAALgAECgMJAwAAAA==.',
['白月']='白月魁氵:BAAALgADCgUJCgAAAA==.',
['白霜']='白霜:BAAALgAECggJCAAAAA==.',
['白风']='白风:BAAALgAECgcJEQAAAA==.',
['百变']='百变舞者:BAAALgAECgYJBQAAAA==.',
['百鬼']='百鬼林夕:BAAALgAFFAIJBAAAAA==.',
['皂动']='皂动不安:BAAALgAECgEJAQAAAA==.',
['目丶']='目丶标:BAAALgAECgMJAgAAAA==.',
['真诚']='真诚的人:BAACLgAFFH8TAAIOAAYJDhieAQAgAgAOAAYJDhieAQAgAgAuAAQKfxkAAw4ACAkVHl4RAEkCAA4ACAkVHl4RAEkCAA0ABAmvCllTAMQAAAAA.真诚的龙:BAABLgAFFH8HAAIcAAMJ+BrzDAATAQAcAAMJ+BrzDAATAQABLgAFFAYJEwAOAA4YAA==.',
['真贰']='真贰雪暴:BAAALgADCgUJBQAAAA==.',
['睚眦']='睚眦之怨:BAAALgAFFAEJAQAAAA==.',
['睡不']='睡不着:BAAALgAECgcJDwAAAA==.',
['睲灀']='睲灀荏苒:BAAALgAECgcJDQAAAA==.',
['瞳久']='瞳久丶:BAAALgAECgYJBwAAAA==.',
['矗云']='矗云:BAAALgAECgQJCAAAAA==.',
['破碎']='破碎流年:BAAALgADCgEJAQAAAA==.',
['硬又']='硬又粗:BAAALgADCgUJBQAAAA==.',
['碎骨']='碎骨狂心:BAACLgAFFH8HAAIMAAMJbhoSBwD0AAAMAAMJbhoSBwD0AAAuAAQKfxcAAgwACAm9HoAGAMgCAAwACAm9HoAGAMgCAAAA.',
['碧海']='碧海潮声:BAAALgAECgEJAQAAAA==.',
['碧翠']='碧翠丝巴鲁:BAAALgAFFAIJAgAAAA==.',
['祖传']='祖传多情公子:BAAALgAECgEJAQAAAA==.',
['祝崉']='祝崉岚:BAAALgAFFAIJBAAAAA==.',
['神烦']='神烦狗吐狗血:BAAALgAECgUJCAAAAA==.',
['神选']='神选:BAAALgAECgcJDgAAAA==.',
['福果']='福果果丶:BAAALgAECgUJBQABLgAFFAcJCAAIAEYdAA==.',
['秋叶']='秋叶不知舞:BAAALgAECgIJAgAAAA==.秋叶伶:BAAALgAECgEJAQAAAA==.秋叶沉渊:BAAALgAFFAIJAwABLgAFFAUJCwAGAM4YAA==.',
['秋山']='秋山君:BAAALgAECgEJAgAAAA==.',
['秋末']='秋末:BAAALgADCgEJAQAAAA==.',
['秋秋']='秋秋叶:BAAALgAECgQJBAAAAA==.',
['积月']='积月累:BAAALgAECgQJBAAAAA==.',
['稻草']='稻草小猫:BAAALgAECggJDQAAAA==.',
['空手']='空手七号:BAAALgAECgMJAwAAAA==.空手三号:BAAALgAECgkJCQAAAA==.空手九号:BAAALgAECgYJBgAAAA==.空手二号:BAAALgAECgkJDwAAAA==.空手八号:BAAALgAECgYJBgAAAA==.空手六号:BAAALgAECgkJCQAAAA==.空手十号:BAAALgAECgcJBwAAAA==.空手四号:BAAALgAECgkJCAAAAA==.',
['窦窦']='窦窦:BAAALgAECgYJBwAAAA==.',
['竹节']='竹节:BAAALgAECgQJBQAAAA==.',
['竹风']='竹风抚荷塘:BAAALgAECgMJAwAAAA==.',
['竺可']='竺可之寳:BAAALgAECgcJEwAAAA==.',
['笑嘻']='笑嘻:BAAALgAECgMJAwAAAA==.',
['筱丶']='筱丶咕咕:BAAALgAECgcJBwAAAA==.',
['箭出']='箭出无归:BAAALgAECgYJDAAAAA==.',
['箭多']='箭多矢广:BAAALgADCgQJBAAAAA==.',
['米丨']='米丨掿丨米:BAAALgAECgQJBQAAAA==.米丨诺丨米:BAAALgAECgQJBQAAAA==.米丨逽丨米:BAABLgAECn8UAAIUAAcJhh9SLwB6AgAUAAcJhh9SLwB6AgAAAA==.',
['粗茶']='粗茶淡饭:BAAALgAECgYJBwAAAA==.',
['粼粼']='粼粼:BAAALgAFFAIJAgAAAA==.',
['精灵']='精灵杀手:BAAALgAECgEJAQAAAA==.精灵水仙:BAAALgADCgEJAQAAAA==.精灵玉兰:BAAALgAECgcJBwAAAA==.精灵玫瑰:BAAALgAECgMJAwAAAA==.精灵百合:BAAALgAECgQJBQAAAA==.',
['糕手']='糕手死骑:BAAALgAECgYJDAAAAA==.',
['糖果']='糖果小方:BAAALgAECgUJBgABLgAECgkJCQAFAAAAAA==.糖果霜火:BAAALgAECgcJBgABLgAFFAUJBwADAMcZAA==.',
['索玛']='索玛丽:BAAALgAECgQJBAAAAA==.',
['索菲']='索菲亚之光:BAAALgAECgcJDAAAAA==.',
['紫夜']='紫夜雨彤:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色微笑:BAAALgAECgcJBwAAAA==.',
['红宝']='红宝贝:BAAALgAECgEJAQAAAA==.',
['红柚']='红柚:BAAALgAECgEJAgAAAA==.',
['红炉']='红炉醉酒:BAAALgAECgUJBQAAAA==.',
['红红']='红红豆沙包:BAAALgAECgYJBgAAAA==.',
['红莲']='红莲焚天:BAAALgADCgYJBgAAAA==.',
['红萍']='红萍果:BAAALgAECgkJCAAAAA==.',
['约修']='约修亚布莱特:BAACLgAFFH8JAAIUAAMJ8xO6EgD6AAAUAAMJ8xO6EgD6AAAuAAQKfxgAAhQACAlEHkEWAPYCABQACAlEHkEWAPYCAAAA.',
['纯奶']='纯奶德:BAAALgAECgEJAQABLgAFFAEJAQAFAAAAAA==.',
['纵横']='纵横四海:BAAALgADCgcJBwAAAA==.',
['纸船']='纸船:BAAALgAECgQJBAAAAA==.',
['细品']='细品香茗:BAAALgADCgEJAQABLgAECgcJGQAQAOAgAA==.',
['绒团']='绒团儿:BAAALgAECgEJAQAAAA==.',
['给你']='给你一背刺:BAACLgAFFH8GAAIfAAQJdQewDwDuAAAfAAQJdQewDwDuAAAuAAQKfxkAAh8ACAmWDosFAL8BAB8ACAmWDosFAL8BAAAA.给你飞起一脚:BAAALgAECgEJAQAAAA==.',
['给我']='给我一个香吻:BAAALgAECgkJEQAAAA==.',
['绝地']='绝地刺杀:BAAALgAECgcJDwAAAA==.',
['绝舞']='绝舞丶倾城:BAAALgAECgEJAQAAAA==.',
['维萨']='维萨群:BAAALgADCgEJAQAAAA==.',
['绽冰']='绽冰:BAAALgAECgMJAwAAAA==.',
['缇纳']='缇纳:BAAALgAECgEJAQAAAA==.',
['网吧']='网吧抠脚大叔:BAAALgAECgcJBwAAAA==.',
['罗牛']='罗牛奶:BAAALgAECgYJBgAAAA==.',
['羌瘣']='羌瘣:BAAALgAECgYJBgAAAA==.',
['美得']='美得难过:BAAALgAECgYJDAAAAA==.',
['老丝']='老丝尘:BAAALgAECggJCQAAAA==.',
['老夏']='老夏壹号:BAAALgAECgYJBQAAAA==.',
['老拳']='老拳师哈:BAACLgAFFH8HAAINAAMJ8x1NBgAXAQANAAMJ8x1NBgAXAQAuAAQKfxoAAg0ACAk2I6cEAD4DAA0ACAk2I6cEAD4DAAAA.',
['耐揍']='耐揍王:BAAALgAECgQJBgAAAA==.',
['联盟']='联盟女性骑士:BAAALgAFFAEJAQAAAA==.联盟的小伙伴:BAAALgAECgMJAwAAAA==.',
['聖殿']='聖殿騎士:BAAALgAECgEJAgAAAA==.',
['肆意']='肆意灬锋芒:BAABLgAFFH8HAAIPAAQJmBOvCgAMAQAPAAQJmBOvCgAMAQAAAA==.',
['肉娃']='肉娃喵咪:BAAALgAECgEJAQAAAA==.',
['肉搏']='肉搏战:BAAALgAECgYJCwAAAA==.',
['肝王']='肝王洪仁肝:BAAALgAECgcJCAABLgAFFAUJBQAJAP4TAA==.',
['背离']='背离初心使命:BAABLgAFFH8GAAITAAMJeAuZEQDbAAATAAMJeAuZEQDbAAAAAA==.',
['胖大']='胖大不是胖次:BAAALgAFFAMJAwABLgAFFAUJEgATAKYVAA==.',
['胖德']='胖德:BAAALgAFFAEJAQAAAA==.',
['胖胖']='胖胖罗:BAAALgAECgUJDQAAAA==.',
['胖虎']='胖虎最二:BAAALgAECgcJBwAAAA==.',
['胭苒']='胭苒:BAAALgAFFAEJAQAAAA==.',
['能丶']='能丶猫:BAACLgAFFH8OAAIgAAQJuwh8DwAGAQAgAAQJuwh8DwAGAQAuAAQKfxcAAyAABgnVENFDADMBACAABgnVENFDADMBAA4AAgmAAlVlADwAAAAA.',
['脚皮']='脚皮的老公:BAAALgAECgIJAgAAAA==.',
['腹黑']='腹黑的兔纸:BAAALgAECgYJCAAAAA==.',
['舞沨']='舞沨:BAAALgAECgcJCAAAAA==.',
['舞眉']='舞眉新娘:BAAALgAFFAIJAgAAAA==.',
['艾尔']='艾尔德因:BAABLgAFFH8HAAIQAAIJMyJoHAC9AAAQAAIJMyJoHAC9AAAAAA==.',
['艾索']='艾索尔:BAABLgAECn8UAAIdAAYJoCS0DQB/AgAdAAYJoCS0DQB/AgAAAA==.',
['艾路']='艾路:BAAALgADCgYJBgAAAA==.',
['艾雷']='艾雷诺亚:BAAALgAECgEJAgAAAA==.',
['芈妖']='芈妖:BAAALgAECgEJAQAAAA==.',
['芙蕾']='芙蕾娜:BAAALgAECgYJCAAAAA==.',
['花心']='花心如此:BAAALgAECgYJDgAAAA==.',
['花风']='花风瑾:BAAALgAECgYJBgAAAA==.',
['苍响']='苍响:BAAALgAECgEJAQAAAA==.',
['苍天']='苍天大术:BAAALgADCgYJBgAAAA==.',
['苍术']='苍术:BAAALgADCgUJBQAAAA==.',
['苍蓝']='苍蓝流星:BAAALgAECgEJAQAAAA==.',
['苏苏']='苏苏我来了:BAAALgAECgYJCwAAAA==.',
['苏茜']='苏茜丶:BAAALgAECgYJCgAAAA==.',
['苏闹']='苏闹闹:BAAALgADCgUJBQAAAA==.',
['若伊']='若伊:BAAALgADCgUJBQAAAA==.',
['若本']='若本规夫:BAACLgAFFH8GAAIRAAIJ9w77BgClAAARAAIJ9w77BgClAAAuAAQKfx0AAxEACAl3GPgBAP0BABEACAl3GPgBAP0BAAsABAkzEoJtAAABAAAA.',
['若相']='若相依是帅锅:BAAALgAECgEJAQAAAA==.',
['苹果']='苹果丶如风:BAAALgAECgEJAQAAAA==.苹果丶招蜂:BAAALgAECgEJAQAAAA==.',
['范达']='范达尔丶撸魁:BAAALgAFFAEJAQAAAA==.',
['茅台']='茅台:BAAALgAECgQJBAAAAA==.',
['茜芮']='茜芮:BAAALgADCgEJAQAAAA==.',
['茫然']='茫然的吉姆利:BAAALgAECgIJAwAAAA==.茫然的怒风:BAAALgAECgEJAQAAAA==.茫然的歌德:BAAALgAECgYJCwAAAA==.',
['莉婭']='莉婭德琳:BAAALgAECggJAwAAAA==.',
['莉莉']='莉莉丝欸:BAACLgAFFH8PAAIVAAUJzB9LBQDUAQAVAAUJzB9LBQDUAQAuAAQKfxcAAhUABwlFJIAWAM8CABUABwlFJIAWAM8CAAAA.',
['莉莎']='莉莎怒风:BAAALgADCgMJAwAAAA==.',
['萌萌']='萌萌哒诺小诺:BAAALgAECgQJCwAAAA==.',
['萤灵']='萤灵:BAAALgAECgIJAgAAAA==.',
['萤邪']='萤邪火:BAAALgAECgEJAQAAAA==.',
['萨拉']='萨拉塔斯:BAAALgADCgIJAgAAAA==.',
['萨维']='萨维恩:BAAALgAECgIJAwAAAA==.',
['落落']='落落丶丶:BAAALgAECgUJBQAAAA==.',
['落雪']='落雪天使心:BAAALgAFFAEJAQAAAA==.',
['董奔']='董奔:BAAALgAECgUJBQAAAA==.',
['葬爱']='葬爱无期:BAAALgAECgYJDgAAAA==.',
['葬花']='葬花戏月:BAAALgAECgcJBwAAAA==.',
['蒸大']='蒸大鹅丶:BAABLgAFFH8LAAMCAAcJahLcAAAYAQACAAMJSBPcAAAYAQABAAQJjBG5DwARAQAAAA==.',
['蓝灬']='蓝灬冥:BAAALgAECgQJBgAAAA==.',
['蔓越']='蔓越莓陷阱:BAAALgAECgcJBwAAAA==.',
['蔷薇']='蔷薇的磊:BAAALgAECgYJBgAAAA==.',
['蕊湫']='蕊湫:BAAALgAECgUJCAAAAA==.',
['薄凉']='薄凉尽昏晓:BAAALgAECgEJAQAAAA==.',
['薄雾']='薄雾浓云:BAACLgAFFH8FAAIOAAMJPBG+CwDpAAAOAAMJPBG+CwDpAAAuAAQKfyAAAg4ACAl/HZ4DADcCAA4ACAl/HZ4DADcCAAAA.',
['薇薇']='薇薇桉的粉丝:BAAALgADCgEJAQAAAA==.',
['虔诚']='虔诚的人:BAAALgAFFAMJAwABLgAFFAYJEwAOAA4YAA==.',
['蚊丶']='蚊丶:BAAALgAECgUJBQAAAA==.',
['蛋蛋']='蛋蛋是我:BAAALgAECgQJBQAAAA==.',
['蜜梨']='蜜梨:BAAALgAECgEJAQAAAA==.',
['血刃']='血刃小热:BAAALgADCgkJDAAAAA==.',
['血夜']='血夜飘摇:BAAALgAECgkJCQABLgAFFAYJBwAeAC4aAA==.',
['血棘']='血棘:BAAALgAECgQJBAAAAA==.',
['血腥']='血腥圣骑:BAAALgAFFAQJBAAAAA==.',
['裝完']='裝完逼了就跑:BAAALgADCgIJAgAAAA==.',
['西尔']='西尔维亚:BAAALgAFFAEJAQAAAA==.',
['西昆']='西昆仑:BAABLgAFFH8GAAIDAAQJ9BlMGABpAQADAAQJ9BlMGABpAQAAAA==.西昆仑丶:BAAALgAECgMJAwAAAA==.西昆仑丶丶:BAABLgAFFH8OAAMIAAQJlhiTBABYAQAIAAQJlhiTBABYAQAcAAIJkA3nEgCVAAABLgAFFAkJAQAFAAAAAA==.',
['西瓜']='西瓜僧:BAAALgAFFAMJBAAAAA==.',
['覃牛']='覃牛牛啊:BAAALgADCgIJAgAAAA==.',
['觞角']='觞角:BAAALgAECgEJAgAAAA==.',
['让我']='让我先跑:BAAALgAFFAEJAQAAAA==.',
['许意']='许意:BAAALgADCgcJBwAAAA==.',
['请喊']='请喊我法爷:BAAALgAFFAEJAQAAAA==.',
['诸葛']='诸葛暗:BAAALgAECgMJAwAAAA==.',
['诺诺']='诺诺睡不着:BAAALgADCgEJAQAAAA==.',
['谁都']='谁都打不过丶:BAAALgAECgQJBQAAAA==.',
['賊頭']='賊頭賊脳:BAAALgAECgEJAQAAAA==.',
['贰雪']='贰雪暴:BAAALgAECgIJAgAAAA==.',
['贸易']='贸易伯爵马克:BAAALgADCgIJAgAAAA==.',
['赤焰']='赤焰冰心:BAAALgAECgEJAQAAAA==.',
['赤瞳']='赤瞳丨斩:BAAALgAECgYJBgAAAA==.',
['超电']='超电磁炮波比:BAAALgAFFAEJAQAAAA==.',
['超级']='超级地球牛:BAAALgAFFAEJAQAAAA==.',
['跨海']='跨海斩长鲸:BAABLgAFFH8JAAIgAAQJ9xI2EQD0AAAgAAQJ9xI2EQD0AAAAAA==.',
['跳起']='跳起一奶:BAAALgAECgEJAQAAAA==.',
['轩灬']='轩灬灬誓:BAAALgAECgEJAQAAAA==.',
['轩辕']='轩辕猎魂:BAAALgAECgEJAQAAAA==.轩辕痕丶:BAABLgAFFH8GAAIBAAQJggstGAAvAQABAAQJggstGAAvAQABLgAFFAYJDwABALsgAA==.',
['辷臉']='辷臉懵潷丶:BAAALgAECgIJAgAAAA==.',
['达成']='达成目标:BAAALgADCgYJCQAAAA==.',
['迈克']='迈克尔墨墨:BAACLgAFFH8IAAMUAAMJ/RZ3JQAAAQAUAAMJuxZ3JQAAAQAaAAEJdBe1BABXAAAuAAQKfxYAAxoABwkEIAMBAAYCABQABwlkGwxKABUCABoABgmbIgMBAAYCAAAA.迈克尔妞妞莫:BAABLgAFFH8FAAIUAAIJOBWDOgCnAAAUAAIJOBWDOgCnAAAAAA==.迈克尔小幺幺:BAAALgAFFAIJBAAAAA==.迈克尔小开心:BAABLgAFFH8HAAIXAAMJpAI1CgCwAAAXAAMJpAI1CgCwAAAAAA==.迈克尔开心:BAAALgAFFAIJAgAAAA==.迈克尔朵莉亚:BAAALgAECgYJBgAAAA==.迈克尔火锅儿:BAABLgAFFH8HAAMaAAMJlw8vAgD3AAAaAAMJbQsvAgD3AAAUAAIJTg/5PwCgAAAAAA==.迈克尔石达:BAAALgADCgYJBgAAAA==.迈克尔罗密欧:BAAALgAFFAIJAgAAAA==.迈克尔辣条儿:BAAALgAFFAIJAgAAAA==.迈克尔釹兵儿:BAABLgAFFH8HAAMUAAMJchGBKwDtAAAUAAMJWAyBKwDtAAAaAAIJuQ2OAwCkAAAAAA==.',
['这一']='这一战翻身:BAAALgAECgUJBQAAAA==.',
['这样']='这样玩:BAAALgADCgYJBgAAAA==.',
['迷人']='迷人的少年:BAAALgAFFAIJAgAAAA==.',
['迷彩']='迷彩小猪:BAAALgAECgkJCAAAAA==.',
['选择']='选择:BAAALgAFFAIJAgAAAA==.',
['速八']='速八拉一:BAAALgAECgYJCwAAAA==.速八拉三:BAAALgAECgYJCgAAAA==.',
['遇見']='遇見丿花開:BAAALgAECgQJBgAAAA==.',
['遗忘']='遗忘的复仇者:BAAALgADCgUJBQAAAA==.',
['還我']='還我漂飘拳:BAABLgAFFH8FAAIgAAIJnwq7HgB/AAAgAAIJnwq7HgB/AAAAAA==.',
['那一']='那一抹粉红:BAAALgADCgcJAQAAAA==.',
['邪恶']='邪恶电毛驴:BAAALgAECgEJAQAAAA==.',
['邪火']='邪火焚世:BAAALgAECgEJAQAAAA==.',
['邪焱']='邪焱封君:BAAALgAECgEJAQAAAA==.',
['酱紫']='酱紫走位:BAAALgAECgMJAwAAAA==.',
['酷妮']='酷妮:BAAALgAECgMJAwAAAA==.',
['醉澜']='醉澜衍夕:BAAALgAECgQJBQAAAA==.',
['里夫']='里夫克里门森:BAAALgAECgIJAgAAAA==.',
['重生']='重生之虎:BAACLgAFFH8JAAILAAMJNAt7CAD3AAALAAMJNAt7CAD3AAAuAAQKfxUAAgsABwloG9YjADcCAAsABwloG9YjADcCAAAA.',
['野泤']='野泤狂野:BAAALgAECgEJAQAAAA==.',
['金色']='金色甲壳虫:BAAALgAECgMJAwAAAA==.',
['鎌倉']='鎌倉:BAAALgAECgQJBgAAAA==.',
['钢棍']='钢棍泄师傅:BAAALgAECgQJCgAAAA==.',
['钢铁']='钢铁屠戮者:BAAALgAECgYJDAAAAA==.',
['银色']='银色的贝比雯:BAAALgAECgEJAgAAAA==.',
['锁甲']='锁甲丶小黄人:BAAALgAECgEJAQAAAA==.',
['键丨']='键丨来:BAABLgAECn8VAAIUAAYJyiObOABUAgAUAAYJyiObOABUAgAAAA==.',
['镜中']='镜中圣女贞德:BAAALgAECgEJAQAAAA==.',
['镜子']='镜子里的你:BAAALgAFFAEJAgAAAA==.',
['长云']='长云:BAAALgAECgkJDAAAAA==.',
['闷大']='闷大鹅丶:BAAALgAFFAQJAQAAAA==.',
['阴苞']='阴苞谷:BAAALgAECgEJAgAAAA==.',
['阿兰']='阿兰蒂尔:BAAALgAECgYJEgAAAA==.',
['阿吨']='阿吨:BAAALgAECgcJDAAAAA==.',
['阿妮']='阿妮亚氵:BAAALgAECgYJDAAAAA==.',
['阿季']='阿季米德:BAAALgAECgUJBQAAAA==.',
['阿拉']='阿拉蒙:BAAALgAECgYJDgAAAA==.',
['阿普']='阿普洛丽亚:BAAALgADCgEJAQAAAA==.',
['阿浪']='阿浪哟:BAABLgAFFH8GAAIUAAQJuQl2HgAlAQAUAAQJuQl2HgAlAQAAAA==.',
['阿滨']='阿滨滨牟:BAAALgADCgQJBAAAAA==.',
['阿牛']='阿牛仔:BAAALgAECgUJBQAAAA==.',
['阿特']='阿特洛玻丝:BAAALgADCgMJAwAAAA==.',
['陈牛']='陈牛牛:BAAALgAECgIJBgAAAA==.',
['陌上']='陌上人如玉丶:BAAALgAECgEJBAAAAA==.',
['陌世']='陌世离殇:BAAALgAECgcJBwAAAA==.',
['陪你']='陪你一生:BAAALgAECgEJAQAAAA==.',
['随便']='随便喝汤:BAAALgAECgEJAQAAAA==.',
['随心']='随心所欲:BAAALgAECgMJBAAAAA==.',
['隐天']='隐天德:BAAALgAECgUJDwAAAA==.',
['隔壁']='隔壁小妞:BAAALgAECgcJCAAAAA==.隔壁小娘们:BAAALgAECgcJDQAAAA==.',
['隨心']='隨心所慾:BAAALgAECgIJAwAAAA==.',
['雀魂']='雀魂峭岫:BAAALgAECgcJBQAAAA==.',
['雙孖']='雙孖灬誣語:BAAALgAECgEJAQAAAA==.',
['雨中']='雨中狼灭:BAAALgAECgYJCQAAAA==.',
['雨天']='雨天溺爱微笑:BAAALgAECgMJAwAAAA==.',
['雨落']='雨落星:BAAALgAFFAIJAgAAAA==.',
['雪花']='雪花的哭泣:BAAALgAECgYJDAAAAA==.',
['雪风']='雪风:BAAALgADCgYJBgAAAA==.',
['零七']='零七年:BAAALgAECgkJCgAAAA==.',
['零度']='零度丶丶:BAAALgAECgEJAQAAAA==.',
['雷焰']='雷焰:BAAALgAECgEJAQAAAA==.',
['雷鸣']='雷鸣君:BAAALgADCgcJDgAAAA==.',
['霜语']='霜语之黎:BAAALgAECgIJAgAAAA==.',
['露希']='露希尔:BAAALgADCgEJAgAAAA==.',
['霸气']='霸气仙魔:BAAALgAECgUJBQAAAA==.',
['青涩']='青涩动人:BAAALgAECgMJAwAAAA==.',
['青藤']='青藤小扇贝:BAAALgAECgYJBgABLgAFFAUJEAAXAFcjAA==.',
['非尝']='非尝可乐:BAAALgAFFAEJAQAAAA==.',
['非诚']='非诚勿恋:BAAALgADCgYJBgAAAA==.',
['韦赛']='韦赛里斯:BAAALgADCgIJAgAAAA==.',
['韩孝']='韩孝珠氵:BAAALgAECgcJDgAAAA==.',
['顾筱']='顾筱雯:BAAALgAFFAEJAQAAAA==.',
['颀懐']='颀懐懿:BAABLgAFFH8FAAIYAAIJbxSHDwCUAAAYAAIJbxSHDwCUAAAAAA==.',
['领主']='领主和老君:BAAALgAECgIJAgAAAA==.',
['颤抖']='颤抖吧地球人:BAAALgAECgEJAwAAAA==.',
['风一']='风一败:BAAALgAECgYJCgAAAA==.',
['风与']='风与亲:BAAALgAECgEJAQAAAA==.',
['风之']='风之优雅的猪:BAAALgAECgMJAwAAAA==.风之子丶:BAAALgAECgEJAQAAAA==.',
['风怒']='风怒伊力丹:BAACLgAFFH8HAAIPAAMJyBokCgAQAQAPAAMJyBokCgAQAQAuAAQKfxsABA8ABwnMH1EhAD0CAA8ABwmPHFEhAD0CABIABgllHXQRAKsBABYAAgkPDmwVADwAAAAA.',
['风末']='风末止:BAAALgAECgEJAQAAAA==.',
['风神']='风神之力:BAAALgADCgUJBQAAAA==.',
['风行']='风行天地:BAAALgAECgIJAgAAAA==.风行者希炎:BAAALgAECgMJAwABLgAFFAUJAgAFAAAAAA==.',
['风那']='风那个吹:BAAALgADCgEJAQAAAA==.',
['飙龙']='飙龙妙影:BAAALgAECgUJBQAAAA==.',
['飚一']='飚一把女司机:BAABLgAECn8XAAMbAAcJ3RQ0DADhAAAbAAYJjBI0DADhAAAUAAIJJRp8/QCAAAABLgAFFAQJCAAQAOIIAA==.',
['飞向']='飞向你妹的床:BAAALgAECgYJBgAAAA==.',
['飞天']='飞天小晶:BAAALgAECgMJAwAAAA==.',
['飞妲']='飞妲小晶:BAAALgAECgIJAgAAAA==.',
['飞翔']='飞翔耗儿鱼:BAAALgAECgUJBQAAAA==.',
['飞花']='飞花梦影:BAACLgAFFH8DAAIBAAMJ0gNGGADXAAABAAMJ0gNGGADXAAAuAAQKfxoAAgEACAl9FvcKAOoBAAEACAl9FvcKAOoBAAAA.',
['飞龙']='飞龙改二:BAAALgAFFAEJAgAAAA==.',
['餐桌']='餐桌上的桃子:BAAALgAECgcJEQAAAA==.',
['饿梦']='饿梦:BAAALgAECgUJBgAAAA==.',
['饿魔']='饿魔一指:BAAALgADCgYJBgAAAA==.',
['饿龙']='饿龙丨咆哮:BAAALgAECgcJCwABLgAFFAcJBQAKANEWAA==.',
['馒头']='馒头莎拉酱:BAAALgAECgcJBwAAAA==.',
['馨馨']='馨馨泪:BAAALgAECgYJEAAAAA==.',
['马孔']='马孔多在下雨:BAAALgAECgYJBwAAAA==.',
['骑呢']='骑呢:BAAALgADCgEJAQAAAA==.',
['骑白']='骑白马的骑师:BAAALgAECgEJAQAAAA==.',
['骨瘦']='骨瘦如柴:BAAALgADCgcJBwAAAA==.',
['高冷']='高冷的欧巴:BAAALgAFFAMJAwAAAA==.',
['高压']='高压线:BAAALgAECgYJBgAAAA==.',
['鬼刻']='鬼刻:BAAALgAECgYJDAAAAA==.',
['鬼推']='鬼推磨:BAAALgAECgEJAQAAAA==.',
['魂泣']='魂泣荡:BAAALgAECgIJAgAAAA==.',
['魅林']='魅林影:BAAALgAECgUJBAAAAA==.',
['鲸落']='鲸落落:BAAALgAECgMJAwAAAA==.',
['麒麟']='麒麟星:BAAALgAECgIJAgAAAA==.',
['麻辣']='麻辣虾球:BAACLgAFFH8FAAIDAAMJhgItHADZAAADAAMJhgItHADZAAAuAAQKfxoAAgMABwnGFeNzAOsBAAMABwnGFeNzAOsBAAAA.',
['黄沙']='黄沙:BAAALgAFFAEJAQAAAA==.',
['黑夜']='黑夜的呢喃:BAAALgAFFAEJAgAAAA==.',
['黑暗']='黑暗的嘴角:BAAALgAECgUJBQAAAA==.',
['黑白']='黑白天枰:BAAALgAECgIJAQAAAA==.黑白苹果:BAAALgAECgEJAQAAAA==.',
['黑眼']='黑眼逗豆:BAAALgADCgMJAwAAAA==.',
['黑铁']='黑铁之魂:BAAALgADCgYJBgAAAA==.',
['默默']='默默潜行:BAABLgAFFH8LAAMPAAQJuxfSBwAmAQAPAAQJyhXSBwAmAQASAAEJVQ4AAAAAAAAAAA==.',
['黯丶']='黯丶暮沉:BAAALgAECgYJEAAAAA==.',
['黯月']='黯月凝霜:BAABLgAFFH8JAAMUAAUJaib/AAA+AgAUAAUJaib/AAA+AgAaAAIJdA8vAwCvAAAAAA==.',
['龙凤']='龙凤改二:BAAALgADCgEJAQABLgAFFAEJAgAFAAAAAA==.',
['龙咆']='龙咆虎啸:BAAALgAFFAIJAgAAAA==.',
['龙妈']='龙妈丹妮丽丝:BAAALgAECgEJAQAAAA==.',
['龙有']='龙有点聋:BAAALgAECgIJAwABLgAECgQJBQAFAAAAAA==.',
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
