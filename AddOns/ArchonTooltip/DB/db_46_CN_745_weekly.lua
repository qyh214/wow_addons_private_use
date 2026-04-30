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

local lookup = {'Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Paladin-Retribution','Paladin-Holy','Mage-Frost','Warlock-Affliction','Warlock-Demonology','Hunter-Marksmanship','Hunter-Survival','Priest-Holy','Unknown-Unknown','Priest-Discipline','Hunter-BeastMastery','Shaman-Restoration','Shaman-Enhancement','Warlock-Destruction','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Frost','Druid-Restoration','Druid-Balance','Priest-Shadow','Paladin-Protection','Monk-Mistweaver','Monk-Brewmaster','DemonHunter-Devourer','DemonHunter-Havoc','Warrior-Arms','Warrior-Fury','Monk-Windwalker','Warrior-Protection','Rogue-Subtlety',}
local provider = {region='CN',realm='烈焰峰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Ado:BAAALgAFFAIJBAAAAA==.',
Ag='Agou:BAAALgAECgIJAgAAAA==.Agrul:BAAALgAECgMJBQAAAA==.',
Ai='Aineóg:BAAALgAFFAIJBAAAAA==.',
An='Anixon:BAAALgAECgEJAwAAAA==.',
Au='Automage:BAAALgAECgUJBQAAAA==.',
Ba='Barton:BAAALgAECgEJAQAAAA==.',
Bi='Bigsnake:BAAALgAFFAIJAgAAAA==.Bigteeth:BAAALgAECgIJBQAAAA==.',
Bn='Bndywbs:BAAALgADCgEJAQAAAA==.',
Ca='Carolqin:BAAALgAECgkJCQAAAA==.',
Ce='Ceui:BAAALgAECgQJBgAAAA==.',
Cf='Cfoeverh:BAAALgAECgYJEgAAAA==.',
Cu='Currenter:BAAALgAECgEJAQAAAA==.',
De='Deathdance:BAAALgAECgYJCgAAAA==.',
Do='Doubao:BAABLgAECn8VAAQBAAkJcRsZFwDfAQABAAUJtyIZFwDfAQACAAYJhhqSHQDYAQADAAUJ+R2TFgCJAQAAAA==.',
Ei='Eightyone:BAAALgAECgIJAgAAAA==.',
Es='Esdese:BAAALgAFFAEJAQAAAA==.Esrvgsd:BAAALgAECgYJBgAAAA==.',
Ev='Evanlyn:BAAALgAFFAEJAQAAAA==.',
Ez='Ezrual:BAACLgAFFH8MAAIBAAQJjBlAAwBSAQABAAQJjBlAAwBSAQAuAAQKfxkAAwEACAkXGbUNAFsCAAEACAkXGbUNAFsCAAMABQkOGDQbAFcBAAAA.',
Fi='Finalrvp:BAAALgAECggJDAAAAA==.',
Fl='Flinkyarn:BAAALgAFFAIJAgAAAA==.',
Ga='Gamm:BAAALgAFFAMJAwAAAA==.',
Go='Golem:BAAALgAECgcJBwAAAA==.',
Gr='Greentea:BAAALgAECgYJCwAAAA==.',
Ha='Hanropp:BAACLgAFFH8LAAIEAAQJAxjNAwBbAQAEAAQJAxjNAwBbAQAuAAQKfxsAAwQACAmDI24cAL8CAAQACAmDI24cAL8CAAUABgl1E/JHAFgBAAAA.',
Ho='Holydracarys:BAACLgAFFH8RAAIGAAYJbxvdAwA2AgAGAAYJbxvdAwA2AgAuAAQKfykAAgYACQkbJs8CANIDAAYACQkbJs8CANIDAAAA.Hosseiny:BAABLgAFFH8FAAMHAAMJtiTkAQB1AAAIAAIJ3CM3KADXAAAHAAEJaybkAQB1AAAAAA==.',
Is='Ishtar:BAACLgAFFH8HAAMJAAMJthEaHwCZAAAJAAIJahQaHwCZAAAKAAIJqgYAAAAAAAAuAAQKfx8AAwkACAkLHysOAM8CAAkACAkLHysOAM8CAAoAAgkLEvkNAJcAAAAA.',
Ji='Jinhsi:BAAALgADCgYJBgAAAA==.',
Ke='Keyyle:BAAALgAECgcJCQAAAA==.',
Kl='Kldh:BAAALgAFFAEJAQAAAA==.',
Kt='Ktaeyeon:BAAALgAECgYJEwAAAA==.',
La='Lakers:BAAALgAECgMJAwAAAA==.Lastdannce:BAABLgAFFH8IAAIIAAMJHBCBJADxAAAIAAMJHBCBJADxAAABLgAFFAcJBwAIANgSAA==.',
Le='Leviathan:BAAALgAECgcJCAAAAA==.',
Li='Lina:BAAALgAFFAMJAwAAAA==.',
Lu='Lulup:BAABLgAFFH8FAAILAAIJPgXVBgB3AAALAAIJPgXVBgB3AAAAAA==.',
Ma='Madao:BAACLgAFFH8HAAIEAAMJER/IEAAfAQAEAAMJER/IEAAfAQAuAAQKfxQAAgQACQnxHREVAOsCAAQACQnxHREVAOsCAAAA.Marsdh:BAAALgAECgYJDAAAAA==.Marsdk:BAAALgAECgYJCAAAAA==.Marsmage:BAAALgADCgYJBgAAAA==.Marsws:BAAALgAECgIJAgAAAA==.',
Me='Mendel:BAAALgAECgQJBAAAAA==.Mernika:BAAALgADCgYJBgAAAA==.',
Mf='Mfourwl:BAAALgAECgEJAQAAAA==.',
Mi='Minwallewow:BAAALgADCgQJBAAAAA==.Mishra:BAAALgAECgkJEAABLgAFFAgJAQAMAAAAAA==.',
Mo='Monsterntp:BAABLgAFFH8FAAINAAUJXRNUBACqAQANAAUJXRNUBACqAQAAAA==.',
Ne='Neroxevo:BAAALgAECgEJAQAAAA==.',
Ni='Nidhögg:BAACLgAFFH8PAAICAAYJYSAPAgAzAgACAAYJYSAPAgAzAgAuAAQKfykAAgIACQkPJo8AAOADAAIACQkPJo8AAOADAAAA.',
Oc='Octoploid:BAACLgAFFH8LAAMOAAYJFxa9CAAcAQAOAAMJfB29CAAcAQAJAAMJAQv8FAD0AAAuAAQKfykAAwkACQkwI4QHACIDAAkACQneHYQHACIDAA4ABwl/IpBHAJMBAAAA.',
Od='Odysey:BAAALgAECgEJAgAAAA==.',
Ol='Oldgou:BAAALgAFFAEJAQAAAA==.',
Pa='Pandoda:BAAALgADCgYJDAAAAA==.',
Pl='Planeswalker:BAACLgAFFH8IAAIGAAMJiSBKNQDBAAAGAAMJiSBKNQDBAAAuAAQKfyEAAgYACAlTJbQNAFgDAAYACAlTJbQNAFgDAAAA.Playertsjrbz:BAAALgAECgMJBAAAAA==.',
Ro='Rockbu:BAAALgAECgIJAgAAAA==.',
Ru='Rubidium:BAACLgAFFH8NAAIEAAUJpxo6BQCdAQAEAAUJpxo6BQCdAQAuAAQKfykAAgQACQkdI7AGAGUDAAQACQkdI7AGAGUDAAAA.',
Ry='Ryvius:BAAALgAFFAEJAQAAAA==.',
Sa='Samoyedlulu:BAAALgADCgcJCQAAAA==.',
Se='Septembermay:BAABLgAECn8YAAMPAAcJWBUoNACzAQAPAAcJWBUoNACzAQAQAAYJXA8kFQBqAQAAAA==.',
Sh='Shadowbucn:BAACLgAFFH8HAAIIAAMJkRNNOACjAAAIAAMJkRNNOACjAAAuAAQKfxkAAwgABgnhIJ5LAOYBAAgABgnhIJ5LAOYBABEAAwlaEIlBAK8AAAAA.Shadowfiend:BAAALgADCgIJAgAAAA==.Shami:BAAALgADCgYJCQAAAA==.',
Si='Sincejune:BAAALgAECggJDAAAAA==.',
Sp='Splash:BAACLgAFFH8HAAMPAAUJjxd0AgC/AQAPAAUJjxd0AgC/AQASAAEJZBNWHQBMAAAuAAQKfxQAAxIACAn7HkQdACcCABIABglQIUQdACcCAA8AAgkoIrdzAMEAAAAA.',
St='Stephan:BAAALgAECgYJCwAAAA==.',
Th='Thpool:BAAALgAECgUJBQAAAA==.',
Tr='Trajan:BAAALgAECgYJCgAAAA==.Triploid:BAAALgADCgkJCQAAAA==.',
Ts='Tsuyoshi:BAAALgAECgYJBgAAAA==.',
Vi='Vickyz:BAAALgAECgYJBgAAAA==.Vigormortis:BAAALgAECgcJBQAAAA==.',
Yo='Yokoi:BAAALgAECgEJAQAAAA==.',
Zj='Zjes:BAACLgAFFH8FAAITAAMJPhwJLwDbAAATAAMJPhwJLwDbAAAuAAQKfxwAAxMACAkfJqEFAHsDABMACAkfJqEFAHsDABQABQlEIpYBAJwBAAAA.',
['一只']='一只小貓:BAAALgADCgEJAQAAAA==.',
['一样']='一样是明月:BAAALgAECgkJBwAAAA==.',
['一演']='一演难尽:BAAALgAFFAIJAgAAAA==.',
['一灵']='一灵魂之舞一:BAABLgAECn8bAAMVAAcJiiESFACVAgAVAAYJYSYSFACVAgAWAAcJDR7iKwCjAQAAAA==.',
['一直']='一直卡蓝条:BAABLgAFFH8IAAIGAAQJRRTmGgBfAQAGAAQJRRTmGgBfAQAAAA==.',
['一缕']='一缕残风过:BAAALgADCgYJBgAAAA==.',
['一锅']='一锅端:BAAALgAECgYJCAAAAA==.',
['一闪']='一闪:BAAALgAECgQJBAAAAA==.',
['七四']='七四一:BAAALgAECgIJBAAAAA==.',
['七念']='七念:BAAALgADCgEJAQAAAA==.',
['七海']='七海千秋:BAAALgAECgEJAQAAAA==.',
['七菱']='七菱:BAABLgAECn8kAAMXAAgJvBpQEQB0AgAXAAgJvBpQEQB0AgANAAYJQhaYBwB1AQAAAA==.',
['三饮']='三饮得道:BAABLgAFFH8GAAMFAAMJOx2TFACcAAAFAAIJchiTFACcAAAYAAEJOyDOBgBLAAAAAA==.',
['上过']='上过封肾榜:BAAALgAECgUJBQAAAA==.',
['下次']='下次注意点:BAAALgAECgUJCAAAAA==.',
['不如']='不如玩奶德:BAAALgADCgMJAwAAAA==.',
['不找']='不找自己:BAAALgADCgUJBgAAAA==.',
['不空']='不空:BAAALgADCgMJAwAAAA==.',
['不笑']='不笑露齿:BAAALgAECgYJCQAAAA==.',
['不诉']='不诉离殇:BAAALgAECgYJBwAAAA==.',
['丑的']='丑的无与伦比:BAABLgAFFH8IAAITAAMJeiAIKgDyAAATAAMJeiAIKgDyAAAAAA==.',
['专业']='专业移动炮灰:BAAALgAECgEJAQAAAA==.',
['专属']='专属宝贝:BAAALgAECgYJBgAAAA==.',
['世为']='世为:BAAALgAECgYJBgAAAA==.',
['东风']='东风芙洛拉:BAAALgAECgYJDQAAAA==.',
['丢小']='丢小咪:BAAALgAECgYJCwAAAA==.',
['丨阿']='丨阿克萌德丨:BAAALgAECgQJBAAAAA==.',
['中野']='中野一伐枪:BAAALgAECgQJBQAAAA==.',
['丷叁']='丷叁柒丷:BAAALgAECgEJAQAAAA==.',
['丷抻']='丷抻姐骑丷:BAAALgAECgYJEQAAAA==.',
['丷特']='丷特喵德丷:BAAALgAECgMJAwAAAA==.',
['乄幽']='乄幽:BAAALgAFFAIJAwAAAA==.',
['九浅']='九浅我是一深:BAAALgAECgQJBAAAAA==.',
['二师']='二师兄:BAAALgAECgYJCwAAAA==.',
['二手']='二手摩托车:BAAALgADCgEJAQAAAA==.',
['二硼']='二硼化镁:BAACLgAFFH8IAAIZAAMJXxzeCQAUAQAZAAMJXxzeCQAUAQAuAAQKfxYAAhkACQmmHDsGAPwCABkACQmmHDsGAPwCAAAA.',
['云岫']='云岫:BAAALgAECgMJAwAAAA==.',
['云木']='云木:BAAALgADCgIJAgAAAA==.',
['今天']='今天不长肉:BAAALgAECgEJAQAAAA==.',
['今日']='今日我是女王:BAAALgAECgIJAgABLgAFFAEJAQAMAAAAAA==.',
['以武']='以武服人:BAAALgAECgQJAgAAAA==.',
['伊娃']='伊娃的波尔卡:BAAALgADCgcJCwAAAA==.',
['伊弗']='伊弗蕾妮:BAAALgAFFAIJAgABLgAFFAUJDQATAC8WAA==.',
['伊斯']='伊斯卡拉:BAAALgAECgYJBgAAAA==.',
['伏龙']='伏龙翔天:BAACLgAFFH8GAAIZAAMJ9QdlBwC9AAAZAAMJ9QdlBwC9AAAuAAQKfxUAAhkABwkIDhwNABIBABkABwkIDhwNABIBAAAA.',
['众神']='众神之翼:BAAALgAFFAMJBAABLgAFFAUJCwATAIwTAA==.',
['众筹']='众筹看病:BAAALgADCgEJAQAAAA==.',
['传说']='传说之下:BAAALgADCgEJAQAAAA==.',
['伦无']='伦无次语:BAAALgAECgYJEgAAAA==.',
['伯努']='伯努利:BAAALgAECgYJBgAAAA==.',
['低調']='低調的華麗:BAAALgAECgkJCQAAAA==.',
['佛系']='佛系奶萨:BAAALgADCgIJAgAAAA==.',
['你最']='你最吊:BAABLgAFFH8JAAMOAAMJnBXtCgAKAQAOAAMJnBXtCgAKAQAJAAEJAgcfKABLAAAAAA==.',
['你来']='你来呀你来呀:BAAALgAECgMJAwAAAA==.',
['來嘛']='來嘛英雄:BAAALgAECgUJBgAAAA==.',
['依麦']='依麦:BAAALgAECgQJBAAAAA==.',
['修修']='修修:BAAALgADCgYJBgAAAA==.',
['健壮']='健壮而又纯洁:BAAALgAECgMJBQAAAA==.',
['偶尓']='偶尓:BAAALgAFFAEJAQAAAA==.',
['偷吃']='偷吃奶酪的熊:BAABLgAECn8WAAIGAAYJzBOXogCSAQAGAAYJzBOXogCSAQAAAA==.',
['備胎']='備胎:BAAALgAECgYJCAAAAA==.',
['傲娇']='傲娇的九尾狐:BAAALgAECgYJCAAAAA==.',
['光明']='光明金骑:BAAALgAECgYJCAAAAA==.',
['光的']='光的另一面:BAAALgAECgQJBwAAAA==.',
['克迪']='克迪制胜:BAAALgAFFAMJAwAAAA==.',
['八方']='八方来才:BAAALgAECgMJAwAAAA==.',
['六字']='六字真言:BAAALgADCgUJBQAAAA==.',
['六月']='六月七月:BAAALgAECgUJBQAAAA==.六月天微蓝:BAABLgAECn8ZAAIGAAcJ1R7INACgAgAGAAcJ1R7INACgAgAAAA==.',
['六溜']='六溜六真的六:BAABLgAFFH8IAAIaAAMJ9RknDwAKAQAaAAMJ9RknDwAKAQAAAA==.',
['兮颜']='兮颜千雪:BAAALgAECgIJAgAAAA==.',
['再见']='再见姬骑士:BAABLgAECn8dAAIEAAgJvCOEAwByAgAEAAgJvCOEAwByAgAAAA==.',
['冰凌']='冰凌:BAAALgAFFAIJAgAAAA==.',
['冰岚']='冰岚色:BAAALgAECgYJCwAAAA==.',
['冰柠']='冰柠茶:BAAALgAFFAIJBAAAAA==.',
['凌零']='凌零漆:BAAALgAECgMJAwAAAA==.',
['凡人']='凡人不再忧郁:BAAALgAECgEJAQAAAA==.',
['凡尘']='凡尘不尔:BAAALgAECgEJAQAAAA==.',
['凤饮']='凤饮香蜜:BAAALgAECgcJDAAAAA==.',
['凰影']='凰影五:BAAALgAFFAQJBAAAAA==.',
['刘伯']='刘伯瑶:BAAALgAECgQJBAAAAA==.',
['刘海']='刘海在强度在:BAAALgAECgYJBgAAAA==.',
['别叫']='别叫我小龙女:BAAALgADCgMJAwAAAA==.',
['别怕']='别怕我不在:BAAALgAFFAIJAgAAAA==.',
['刹那']='刹那清樱:BAAALgAFFAIJAgAAAA==.',
['削肾']='削肾客的九叔:BAAALgAFFAEJAQAAAA==.',
['剥皮']='剥皮熊猫人:BAAALgAECgEJAQAAAA==.',
['劣灬']='劣灬风:BAAALgADCgEJAQAAAA==.',
['勇敢']='勇敢的蚊子:BAAALgAECgYJEQAAAA==.',
['北滘']='北滘:BAAALgADCgIJAgAAAA==.',
['十葉']='十葉:BAABLgAFFH8GAAIEAAMJ1RsEFAAHAQAEAAMJ1RsEFAAHAQAAAA==.',
['千堆']='千堆雪:BAABLgAECn8cAAMbAAgJnAvNXQCHAQAbAAgJnAvNXQCHAQAcAAYJaQXUPwD8AAAAAA==.',
['卅漫']='卅漫:BAAALgADCgQJBAAAAA==.',
['半夏']='半夏茯苓:BAAALgAECgYJCgAAAA==.',
['华三']='华三少:BAAALgAECgYJBQAAAA==.',
['华尔']='华尔街丶:BAAALgADCgYJBgAAAA==.',
['南有']='南有佳蕴:BAAALgAECgMJAwAAAA==.',
['南铁']='南铁烂崽:BAAALgADCgYJBgAAAA==.',
['卡卡']='卡卡兰纳斯:BAAALgADCgcJBgAAAA==.',
['卫宫']='卫宫家的饭丶:BAAALgAECgYJBgAAAA==.',
['原神']='原神真好玩:BAABLgAFFH8HAAITAAQJxgysHQAqAQATAAQJxgysHQAqAQAAAA==.',
['去年']='去年烟花:BAAALgADCgYJBgAAAA==.',
['又劲']='又劲又冷静:BAACLgAFFH8LAAISAAQJEhRzBwDhAAASAAQJEhRzBwDhAAAuAAQKfyQAAhIACAmCJFwFAEEDABIACAmCJFwFAEEDAAEuAAUUBwkEAAwAAAAA.',
['口呆']='口呆哗:BAAALgAECgEJAQAAAA==.口呆瓜:BAAALgAECgIJAgAAAA==.',
['可畏']='可畏:BAAALgADCgYJBgABLgADCgYJCQAMAAAAAA==.',
['司马']='司马骠骑:BAAALgAFFAQJBAAAAA==.',
['吃不']='吃不了:BAAALgAECgUJCAAAAA==.吃不了丷:BAAALgAECgYJBgAAAA==.',
['吃饱']='吃饱了不闹:BAAALgAFFAQJBAAAAA==.',
['吉赛']='吉赛星儿:BAAALgAECgIJAwAAAA==.',
['君君']='君君突然:BAACLgAFFH8PAAMJAAYJjxjRCACNAQAJAAUJ0g/RCACNAQAOAAMJVh2GIQBdAAAuAAQKfygAAwkACQkzIDAPAMUCAAkACAnAIDAPAMUCAA4ABAmuGk+zAFwAAAAA.',
['吻暖']='吻暖冬季:BAAALgAFFAQJAQAAAA==.',
['吾小']='吾小皇:BAAALgAECgQJCAAAAA==.',
['吾辈']='吾辈楷模:BAAALgADCgUJBQAAAA==.',
['哈吉']='哈吉米:BAAALgAECgYJBgAAAA==.',
['响当']='响当当:BAACLgAFFH8VAAMaAAYJ5RWQBQB7AQAaAAUJWBeQBQB7AQAZAAEJPAMBFwBFAAAuAAQKfykAAhoACQmJHysJAPYCABoACQmJHysJAPYCAAAA.',
['哥布']='哥布林牧師:BAAALgAECgQJBAAAAA==.',
['啊尔']='啊尔弗雷德:BAAALgAECgcJCwAAAA==.',
['善良']='善良的羊:BAAALgAECgYJDQAAAA==.',
['喵喵']='喵喵緢:BAAALgAECgEJAQAAAA==.',
['喵头']='喵头咕:BAAALgAECgEJAQAAAA==.',
['嗨有']='嗨有灰机:BAABLgAFFH8OAAMIAAUJYxk3BQBjAQAIAAUJYxk3BQBjAQARAAIJzgLgDgCPAAAAAA==.',
['嗷丶']='嗷丶丶呜丶丶:BAAALgADCgIJAgAAAA==.',
['嗷呜']='嗷呜舞呜:BAAALgADCgUJBQAAAA==.',
['嗷嗷']='嗷嗷不酱:BAAALgAECgYJCQAAAA==.',
['嘿盐']='嘿盐鞭:BAABLgAECn8VAAIPAAYJ7ReADgBYAQAPAAYJ7ReADgBYAQAAAA==.',
['嘿那']='嘿那个猎爹:BAAALgAFFAEJAQABLgAFFAIJAwAIADYaAA==.',
['国产']='国产零零壹:BAAALgAECgIJAgAAAA==.国产零零漆:BAAALgAECgUJBQAAAA==.',
['国服']='国服脑贪:BAAALgAECgUJBQAAAA==.',
['圣域']='圣域:BAAALgADCgcJBwAAAA==.',
['圣契']='圣契:BAAALgAECgYJDAAAAA==.',
['地狱']='地狱教父:BAABLgAFFH8GAAIEAAIJShg2IQCrAAAEAAIJShg2IQCrAAAAAA==.',
['坤坤']='坤坤的意志:BAABLgAECn8VAAIWAAYJ4iMwFgBeAgAWAAYJ4iMwFgBeAgAAAA==.坤坤骑士:BAAALgADCgUJBQAAAA==.',
['埃洛']='埃洛赫丶灵珑:BAAALgADCgUJBQAAAA==.',
['基因']='基因原体:BAAALgAECgQJCAAAAA==.',
['堕落']='堕落之鈊:BAABLgAFFH8GAAIGAAIJ8yC8NADEAAAGAAIJ8yC8NADEAAAAAA==.堕落母神:BAAALgADCgIJAgAAAA==.',
['墨初']='墨初:BAAALgAECgcJBwAAAA==.',
['壁水']='壁水貐:BAABLgAFFH8DAAIIAAIJNhrAEwDGAAAIAAIJNhrAEwDGAAAAAA==.',
['士兵']='士兵七十六:BAAALgADCgcJBwAAAA==.',
['声玻']='声玻:BAAALgAECgQJBAAAAA==.',
['壹吻']='壹吻天荒:BAAALgAECgUJBQAAAA==.',
['夏知']='夏知夜:BAAALgAECgEJAgAAAA==.',
['夏羡']='夏羡妆:BAAALgAECgYJBgAAAA==.',
['夏薇']='夏薇:BAAALgADCgcJDAAAAA==.',
['多拉']='多拉贡荡死:BAABLgAFFH8FAAICAAIJ2gvYGgCWAAACAAIJ2gvYGgCWAAAAAA==.',
['夜之']='夜之刹:BAAALgAECgEJAQAAAA==.',
['夜刀']='夜刀神:BAAALgAECgUJBwAAAA==.',
['夜枼']='夜枼業:BAAALgAECggJDAAAAA==.',
['夜語']='夜語:BAAALgADCgcJCQAAAA==.',
['大展']='大展宏图:BAAALgAECgYJDgAAAA==.',
['大桶']='大桶酸梅汤:BAAALgAFFAQJBAAAAA==.',
['大熊']='大熊猫来喽:BAAALgAECgQJBgAAAA==.',
['大琪']='大琪琪:BAAALgAECgMJAwAAAA==.',
['大莉']='大莉莉丝:BAAALgAFFAEJAQAAAA==.',
['大风']='大风兄弟:BAABLgAECn8dAAMdAAgJnRxtBACoAgAdAAgJnRxtBACoAgAeAAYJ0xeSTgBsAQAAAA==.大风破坏龙:BAAALgAECgIJAgABLgAECggJHQAdAJ0cAA==.',
['天丶']='天丶殇丨:BAABLgAFFH8FAAIJAAUJgAs2AgAvAQAJAAUJgAs2AgAvAQAAAA==.',
['天之']='天之亲亲:BAAALgAECgYJBgAAAA==.',
['天使']='天使初浔:BAAALgAECgkJBwAAAA==.天使妹:BAAALgAECgYJCwAAAA==.',
['天空']='天空之雪天使:BAAALgADCgYJBgAAAA==.',
['天蓝']='天蓝色的天:BAACLgAFFH8PAAIGAAYJjhrzAwA0AgAGAAYJjhrzAwA0AgAuAAQKfykAAgYACQnGJfgGAJYDAAYACQnGJfgGAJYDAAAA.',
['天降']='天降阿光:BAAALgAECgQJBAAAAA==.',
['天黑']='天黑好私奔:BAAALgAECgEJAQAAAA==.',
['天龙']='天龙:BAAALgAECgMJBAAAAA==.',
['太懒']='太懒神骑士:BAAALgAECgUJBQAAAA==.',
['奈丶']='奈丶何:BAABLgAFFH8HAAIIAAMJrBd6DwD4AAAIAAMJrBd6DwD4AAAAAA==.',
['奥娜']='奥娜娜:BAAALgADCgIJAgAAAA==.',
['女王']='女王之刃:BAAALgAECgcJBwAAAA==.',
['奶油']='奶油妹:BAAALgADCgYJBgAAAA==.',
['她不']='她不一样:BAABLgAFFH8GAAMaAAQJggz7HQCDAAAaAAIJUw37HQCDAAAfAAMJQQoAAAAAAAAAAA==.',
['妖妸']='妖妸沝:BAAALgAECgMJAwAAAA==.',
['妖娆']='妖娆悍妻:BAAALgAECgcJCwAAAA==.',
['妩媚']='妩媚妹妹:BAAALgAECgYJCQAAAA==.妩媚姐姐:BAAALgAECgcJCgAAAA==.',
['妮可']='妮可冫罗宾:BAAALgAFFAIJBAAAAA==.',
['姒无']='姒无薇:BAAALgAECgYJCgAAAA==.',
['姓欧']='姓欧名皇:BAAALgAECgYJCAAAAA==.',
['姜糖']='姜糖特辣:BAAALgADCgUJBQAAAA==.',
['孜然']='孜然萌:BAAALgAFFAQJBAAAAA==.',
['孤雏']='孤雏:BAAALgAECgUJAgAAAA==.',
['宇哥']='宇哥老厉害了:BAACLgAFFH8IAAIKAAMJyxgqAgAXAQAKAAMJyxgqAgAXAQAuAAQKfxsAAgoACAkCHQUEAN4CAAoACAkCHQUEAN4CAAAA.',
['守護']='守護丶雷劫:BAAALgAECgQJCAAAAA==.',
['安丶']='安丶非他命:BAAALgAECgEJAQAAAA==.',
['安玛']='安玛奈特:BAAALgADCgUJBQAAAA==.',
['安静']='安静格调:BAAALgAECgQJCAAAAA==.',
['宝宝']='宝宝霜:BAAALgAECgQJCAAAAA==.',
['寂寞']='寂寞水:BAAALgADCgUJBQAAAA==.',
['寒噤']='寒噤:BAAALgAECgcJCQAAAA==.',
['寶貝']='寶貝:BAABLgAECn8WAAIPAAkJ8BqXDgCmAgAPAAkJ8BqXDgCmAgAAAA==.',
['寻你']='寻你仟百度:BAAALgAECgYJBgAAAA==.',
['射你']='射你一箭:BAAALgAECgUJCwAAAA==.',
['小傻']='小傻大呆:BAAALgAECgYJDQAAAA==.',
['小噩']='小噩魔:BAACLgAFFH8FAAITAAIJnBU3FwCrAAATAAIJnBU3FwCrAAAuAAQKfxYAAhMABgk7IjNAADcCABMABgk7IjNAADcCAAAA.',
['小小']='小小一粒糖:BAAALgAECgkJBgABLgAFFAMJBwATAHIVAA==.小小灵感菇:BAAALgAECgEJAQAAAA==.',
['小心']='小心树後有熊:BAAALgAECggJCAAAAA==.',
['小恐']='小恐龍丶:BAAALgADCgEJAQAAAA==.',
['小手']='小手真红:BAAALgADCgcJBwAAAA==.小手红彤彤:BAAALgAFFAcJBAAAAA==.',
['小授']='小授子:BAAALgAECgYJDAAAAA==.',
['小浣']='小浣兔干脆面:BAABLgAFFH8FAAIfAAUJFRM8AgCYAQAfAAUJFRM8AgCYAQAAAA==.',
['小浪']='小浪花:BAABLgAFFH8IAAIgAAIJTgutDACAAAAgAAIJTgutDACAAAAAAA==.',
['小清']='小清漪:BAAALgAECgQJBAAAAA==.',
['小碗']='小碗:BAAALgAECgQJAwAAAA==.',
['小糊']='小糊涂仙:BAAALgAECgQJBAAAAA==.',
['小紫']='小紫鸢丶:BAAALgAECgYJBAAAAA==.',
['小肥']='小肥仔:BAACLgAFFH8HAAITAAIJ4h7dFAC0AAATAAIJ4h7dFAC0AAAuAAQKfxcAAhMABwlUIJY1AGACABMABwlUIJY1AGACAAAA.',
['小芮']='小芮希:BAABLgAFFH8GAAIaAAMJGwW5FwCxAAAaAAMJGwW5FwCxAAAAAA==.',
['小西']='小西几:BAAALgADCgUJBAAAAA==.',
['小龙']='小龙人来喽:BAAALgAFFAQJBAAAAA==.',
['少丶']='少丶天:BAACLgAFFH8SAAIbAAYJ7BhdAwAFAgAbAAYJ7BhdAwAFAgAuAAQKfxkAAxsACAnbIXMtAEgCABsABwmqIHMtAEgCABwABQmuITsoAIEBAAAA.',
['少女']='少女追求者:BAAALgAECgQJBAAAAA==.',
['少年']='少年不戴花丶:BAAALgAECgYJDAAAAA==.',
['就打']='就打德:BAAALgAECgEJAQAAAA==.',
['尴尬']='尴尬丶小天:BAAALgAECgkJCQAAAA==.',
['川崎']='川崎:BAAALgAECgMJAwAAAA==.',
['巨能']='巨能射:BAAALgAFFAIJAgABLgAFFAYJDAAOAJ8SAA==.',
['已死']='已死无尘丶:BAAALgAECgEJAQAAAA==.',
['帅得']='帅得一塌糊涂:BAAALgADCgcJBwABLgAECgYJCgAMAAAAAA==.',
['希尔']='希尔文:BAAALgAECgMJAwAAAA==.希尔瓦纳丝:BAAALgAECgMJAwAAAA==.',
['带带']='带带博博马:BAAALgAECgMJAwAAAA==.',
['幕野']='幕野:BAAALgAECgEJAQAAAA==.',
['幻月']='幻月晓晓:BAAALgAECgYJDAAAAA==.幻月若璇:BAAALgAECgYJBgAAAA==.',
['幻象']='幻象:BAAALgAECgMJCAAAAA==.',
['幽光']='幽光影流年:BAAALgAECgkJCQAAAA==.',
['广电']='广电转播车:BAAALgADCgIJAQAAAA==.',
['度日']='度日如牛:BAAALgAECgUJBQABLgAECgkJCQAMAAAAAA==.',
['强射']='强射:BAAALgAECgcJBwAAAA==.',
['影之']='影之悔:BAAALgAFFAIJAwAAAA==.',
['彻底']='彻底疯狂:BAAALgAECgMJAwAAAA==.',
['德国']='德国火车头:BAAALgAECgYJEwAAAA==.',
['德莱']='德莱妮:BAAALgAECgYJCQAAAA==.',
['快乐']='快乐的冰:BAAALgADCgUJBQAAAA==.',
['念我']='念我独兮:BAAALgAFFAYJAQAAAA==.',
['怀中']='怀中抱妹撒:BAAALgAECgIJAgAAAA==.',
['怀恋']='怀恋:BAAALgADCgYJBgAAAA==.',
['思南']='思南路花姐:BAAALgADCgMJAwAAAA==.',
['思绪']='思绪涌上心头:BAAALgADCgUJBQAAAA==.',
['怪侠']='怪侠妹妹:BAAALgADCgEJAQAAAA==.',
['恐山']='恐山丶安娜:BAAALgAECgYJBwAAAA==.',
['恶魔']='恶魔曦:BAAALgAECgEJAQAAAA==.',
['悲观']='悲观厌世:BAAALgAECgEJAQAAAA==.',
['情伤']='情伤丷难愈:BAAALgAECgIJAgAAAA==.情伤难愈丶:BAAALgAECgYJCAAAAA==.',
['情迷']='情迷蕓蕓少女:BAAALgAECgcJBwAAAA==.',
['惊爆']='惊爆小乖:BAAALgAECgEJAQAAAA==.',
['意念']='意念残雪:BAAALgAECgUJBQAAAA==.',
['愛丿']='愛丿琴:BAAALgAFFAEJAQAAAA==.',
['慢半']='慢半袙:BAAALgAECgYJBgAAAA==.',
['懒惰']='懒惰的油条:BAAALgAECgQJAgAAAA==.',
['懒懒']='懒懒的小可爱:BAAALgAECgUJBQABLgAFFAUJAQAMAAAAAA==.',
['我不']='我不是妹纸:BAAALgADCgYJBgAAAA==.',
['我又']='我又不傻:BAACLgAFFH8HAAILAAMJlBo7DACeAAALAAMJlBo7DACeAAAuAAQKfxwAAgsACAmgFz8cAPsBAAsACAmgFz8cAPsBAAAA.',
['我想']='我想想吃西瓜:BAAALgAFFAIJAgAAAA==.',
['我是']='我是你的宿命:BAABLgAECn8gAAIEAAgJVx3YBgAhAgAEAAgJVx3YBgAhAgAAAA==.',
['战魂']='战魂怒风:BAAALgAECgIJAgAAAA==.战魂镇魂曲:BAAALgAECgMJBAAAAA==.',
['扶危']='扶危持倾:BAACLgAFFH8QAAIFAAYJISZCAACAAgAFAAYJISZCAACAAgAuAAQKfygAAgUACQkcI/0AAIgDAAUACQkcI/0AAIgDAAAA.',
['拉丝']='拉丝:BAAALgADCgYJBgAAAA==.',
['拿铁']='拿铁艾哈迈德:BAAALgAECggJCQABLgAFFAQJDgATAOcjAA==.',
['挥手']='挥手好寂寞:BAABLgAFFH8HAAILAAMJHiI9BQAxAQALAAMJHiI9BQAxAQAAAA==.',
['捕风']='捕风捉下:BAAALgAECgMJAwAAAA==.捕风捉虾:BAACLgAFFH8GAAIPAAMJ+hciFwCfAAAPAAMJ+hciFwCfAAAuAAQKfxsAAg8ACAnbGaARAIoCAA8ACAnbGaARAIoCAAAA.',
['攘夷']='攘夷志士:BAAALgAECgcJDQAAAA==.',
['放飞']='放飞的青春:BAABLgAECn8XAAIGAAYJfhn0hgDEAQAGAAYJfhn0hgDEAQAAAA==.',
['敏风']='敏风:BAAALgAECgYJEwAAAA==.',
['无关']='无关是非:BAAALgAECgEJAQAAAA==.',
['无心']='无心风月:BAABLgAECn8UAAQEAAYJbRs2bAClAQAEAAYJbRs2bAClAQAFAAIJ4glEhgBgAAAYAAEJmgQ3TgAXAAAAAA==.',
['无白']='无白:BAAALgAECgIJAgAAAA==.',
['无罅']='无罅飞光:BAAALgAECgEJAQAAAA==.',
['无良']='无良善人:BAABLgAFFH8OAAITAAUJHByiAgDmAQATAAUJHByiAgDmAQAAAA==.',
['时代']='时代变了丶:BAABLgAECn8dAAMIAAgJFxfCMABJAgAIAAgJFxfCMABJAgARAAMJ2Q9lPwC3AAAAAA==.',
['时光']='时光丨荏苒:BAAALgAECgIJAwAAAA==.',
['时空']='时空战:BAAALgAECgUJBQAAAA==.',
['昙花']='昙花祭:BAAALgAECgEJAQABLgAFFAUJBgAhAGURAA==.',
['星见']='星见雅:BAAALgADCgUJBQAAAA==.',
['星辰']='星辰与月:BAAALgAFFAMJAwAAAA==.',
['昨日']='昨日先生:BAAALgAFFAIJAgAAAA==.',
['是谁']='是谁的小龙呀:BAAALgAECgYJBgAAAA==.',
['显眼']='显眼包丨:BAAALgAFFAEJAQAAAA==.',
['晓晓']='晓晓妹:BAAALgAECgYJBwAAAA==.',
['晚殇']='晚殇:BAAALgADCgEJAQAAAA==.',
['景德']='景德镇代言人:BAAALgAECgQJBAAAAA==.',
['暗影']='暗影焚天:BAAALgAECgcJBwAAAA==.',
['曼波']='曼波曼波曼波:BAAALgAECgUJBQABLgAFFAUJEwACAEQdAA==.',
['最棕']='最棕幻想:BAAALgAECgMJAwAAAA==.',
['月来']='月来月棒:BAAALgADCgEJAQAAAA==.',
['有关']='有关是非:BAACLgAFFH8HAAMTAAMJyxpYNQCyAAATAAMJyxpYNQCyAAAUAAEJMwGqBABGAAAuAAQKfxsAAxMACAldHPAdAM0CABMACAldHPAdAM0CABQAAwnXGC8EAO0AAAAA.',
['有心']='有心无贼:BAAALgAECgUJBgAAAA==.',
['有龙']='有龙乃大:BAAALgAECgEJAQAAAA==.',
['木叶']='木叶大虾:BAAALgAECgcJDQAAAA==.',
['木瓜']='木瓜奶茶:BAAALgAECgMJAwAAAA==.',
['木石']='木石人心:BAABLgAFFH8IAAMdAAYJSQ0BAQCiAQAdAAUJLhABAQCiAQAgAAIJKgZvDACDAAAAAA==.',
['末代']='末代龙王雷加:BAEALgAECgEJAQABLgAFFAUJEAAIAO8mAA==.',
['朵朵']='朵朵丶颜颜:BAAALgADCgUJBQAAAA==.',
['村长']='村长小跟班:BAAALgAFFAMJBAAAAA==.',
['枉凝']='枉凝眉:BAACLgAFFH8RAAIeAAUJig2WBQCYAQAeAAUJig2WBQCYAQAuAAQKfyMAAh4ACQkNHcYPANQCAB4ACQkNHcYPANQCAAAA.',
['柚乃']='柚乃:BAAALgAECgYJCgAAAA==.',
['柚希']='柚希:BAAALgAECgEJAQAAAA==.',
['柳乔']='柳乔乔:BAAALgAECgEJAgAAAA==.',
['柳柳']='柳柳星:BAAALgAECgUJBgAAAA==.',
['格里']='格里姆格铁皮:BAAALgAECgMJAwAAAA==.',
['梅子']='梅子青时酒:BAAALgAFFAEJAgAAAA==.',
['梦灵']='梦灵:BAAALgAECgkJDwABLgAFFAUJBQATAHgbAA==.',
['棉花']='棉花糖滚动:BAAALgAFFAEJAQAAAA==.',
['楪祈']='楪祈:BAAALgAECgMJAwAAAA==.',
['模棱']='模棱两不可:BAAALgAECgEJAwAAAA==.',
['樱木']='樱木椛道:BAAALgAFFAIJAgAAAA==.樱木花道:BAAALgAFFAEJAQAAAA==.',
['橙骑']='橙骑:BAAALgAFFAIJAgAAAA==.',
['欢乐']='欢乐满满:BAAALgAECgEJAwAAAA==.',
['欧啦']='欧啦拉啦拉啦:BAAALgAECgYJCQAAAA==.',
['歌者']='歌者闻令来:BAACLgAFFH8GAAIGAAMJrBYrJwAWAQAGAAMJrBYrJwAWAQAuAAQKfxYAAgYACQntHVIPAE0DAAYACQntHVIPAE0DAAEuAAUUBQkRAB4Aig0A.',
['歪比']='歪比巴卟:BAAALgADCgIJAgAAAA==.',
['死捞']='死捞逼:BAAALgAECgEJAQAAAA==.',
['毁天']='毁天滅地:BAAALgADCgMJAwAAAA==.',
['毁灭']='毁灭象征:BAAALgAECgMJAwAAAA==.',
['母题']='母题子:BAAALgAECgUJBwAAAA==.',
['毒箭']='毒箭丘比特:BAAALgAECgMJAwAAAA==.',
['永恒']='永恒的菊花残:BAAALgAECgQJBQAAAA==.',
['沉船']='沉船:BAAALgAECgMJAwAAAA==.',
['沙耶']='沙耶之歌:BAAALgAECgEJAQAAAA==.',
['没蓝']='没蓝:BAAALgAFFAEJAQAAAA==.',
['沧海']='沧海老龙吟:BAAALgAECgkJCQAAAA==.',
['法施']='法施:BAAALgAECgIJAgAAAA==.',
['波丿']='波丿妞:BAABLgAFFH8GAAIGAAIJfw4FQgCrAAAGAAIJfw4FQgCrAAAAAA==.',
['波比']='波比小兔兔:BAAALgAECggJBgAAAA==.',
['波波']='波波龍:BAAALgAECgYJBwAAAA==.',
['波雅']='波雅冫汉库克:BAAALgAFFAEJAQAAAA==.',
['波风']='波风林娜:BAABLgAFFH8HAAMXAAMJ0QaVDADjAAAXAAMJ0QaVDADjAAANAAIJjRlhEQCxAAAAAA==.',
['洗心']='洗心革面:BAAALgAECgQJAwAAAA==.',
['洗脑']='洗脑侦探翡翠:BAECLgAFFH8QAAMIAAUJ7yYoAQA/AgAIAAUJ1yYoAQA/AgARAAMJ0CSjBAA9AQAuAAQKfygABAgACQnTJisAAP4DAAgACQnTJisAAP4DABEABAn3Jb4SALYBAAcAAQkAAGgiAGgAAAAA.',
['洛天']='洛天丨凌風:BAAALgAECgEJAQAAAA==.',
['洛阿']='洛阿:BAAALgAECgMJAwAAAA==.',
['海獭']='海獭转圈圈:BAABLgAECn8UAAIVAAYJASB1MADpAQAVAAYJASB1MADpAQABLgAECgcJBwAMAAAAAA==.',
['淡若']='淡若清风灬光:BAAALgAECgYJCgAAAA==.淡若清风灬邪:BAAALgADCgYJBgAAAA==.淡若清风灬鸠:BAAALgAECgMJAwAAAA==.',
['淡雅']='淡雅茉莉:BAAALgAECgYJCAAAAA==.',
['清白']='清白杀手:BAAALgAECgEJAQAAAA==.',
['清風']='清風笑烟雨丶:BAAALgAFFAQJBAAAAA==.',
['溏糖']='溏糖糖:BAAALgAECgcJBwAAAA==.',
['溪灬']='溪灬星:BAAALgADCgQJBQAAAA==.',
['滅卻']='滅卻風津道:BAAALgADCgUJBQAAAA==.',
['满清']='满清十大裤邢:BAAALgAECgQJBAAAAA==.',
['滿江']='滿江紅:BAABLgAFFH8HAAIZAAQJYA6jCAAwAQAZAAQJYA6jCAAwAQAAAA==.',
['漏电']='漏电的福特棒:BAAALgAECgMJAwAAAA==.',
['漪流']='漪流:BAAALgAECgYJBgAAAA==.',
['火锅']='火锅大帝:BAAALgAECgQJBQAAAA==.火锅战將:BAAALgAECgYJCQAAAA==.',
['灬怒']='灬怒风灬:BAAALgAECgUJCQAAAA==.',
['灬灬']='灬灬丨丨:BAAALgAFFAIJAgABLgAFFAcJBgAJAG4FAA==.',
['灰烬']='灰烬之锤:BAAALgAECgQJBAAAAA==.',
['灰雾']='灰雾:BAAALgAECgYJBgAAAA==.',
['灵魂']='灵魂护壳:BAAALgAECgYJCAAAAA==.灵魂石:BAACLgAFFH8HAAIVAAMJ2xTzFwChAAAVAAMJ2xTzFwChAAAuAAQKfxkAAhUACAkGHZ4YAHICABUACAkGHZ4YAHICAAAA.',
['炎爆']='炎爆术未命中:BAAALgAECgUJBQAAAA==.',
['炮弹']='炮弹掉一地:BAAALgADCgMJAwAAAA==.',
['烈火']='烈火灼心:BAAALgAECgEJAQAAAA==.',
['烈焰']='烈焰之战神:BAAALgAECgMJAwAAAA==.',
['热心']='热心网友老胡:BAAALgAECgEJAQAAAA==.',
['無毁']='無毁的湖光:BAAALgADCgEJAQAAAA==.',
['熔火']='熔火核心:BAABLgAFFH8FAAIGAAIJMw/pGgCsAAAGAAIJMw/pGgCsAAAAAA==.',
['燃烧']='燃烧殆烬:BAABLgAFFH8HAAIRAAIJSh53CQDAAAARAAIJSh53CQDAAAAAAA==.',
['爱丶']='爱丶狂暴:BAAALgAECgYJCwAAAA==.',
['爱冒']='爱冒险:BAAALgAECgEJAQAAAA==.',
['爱弥']='爱弥斯:BAAALgAECgIJAgAAAA==.',
['爱莉']='爱莉希蕥:BAAALgAECgcJCAAAAA==.',
['牛奶']='牛奶涨价了:BAAALgADCgUJBwAAAA==.',
['牛牛']='牛牛归来:BAAALgAECgYJDQAAAA==.',
['牛百']='牛百叶:BAAALgAECgQJBQAAAA==.',
['牛祭']='牛祭司丶:BAAALgAFFAIJAwAAAA==.',
['牛顿']='牛顿流体:BAAALgAECgEJAQAAAA==.',
['犀利']='犀利手残党:BAABLgAFFH8CAAIIAAIJiAy8OgCdAAAIAAIJiAy8OgCdAAAAAA==.',
['犇啵']='犇啵尒灞丶:BAAALgAECgYJCgAAAA==.',
['狂怒']='狂怒的图腾:BAAALgAECgEJAQAAAA==.',
['狂戮']='狂戮血蹄:BAAALgAECgYJBwAAAA==.',
['狂暴']='狂暴的熊猫人:BAAALgADCgQJBAAAAA==.',
['狂舞']='狂舞着:BAAALgAECgMJAwAAAA==.',
['狄珂']='狄珂:BAAALgAECgEJAQAAAA==.',
['狩月']='狩月:BAAALgAECgYJCwAAAA==.',
['猎刃']='猎刃艾莉丝:BAABLgAECn8aAAMOAAgJohyVDADbAgAOAAgJohyVDADbAgAJAAEJ5gLRlgAhAAAAAA==.',
['猎猫']='猎猫熊:BAAALgAECgYJDQAAAA==.',
['猎神']='猎神尼古拉斯:BAAALgAECgEJAQAAAA==.',
['猪头']='猪头怪:BAAALgAECgYJBgAAAA==.',
['猫丨']='猫丨南北:BAAALgADCgEJAQAAAA==.',
['獵祖']='獵祖獵宗:BAAALgAECgcJBwAAAA==.',
['玄不']='玄不改欧:BAACLgAFFH8GAAMEAAMJMiXMGQDWAAAEAAMJMiXMGQDWAAAFAAEJMBmWCwBbAAAuAAQKfxsABAQACAk3IowKADwDAAQACAk3IowKADwDAAUAAQlbC8wnADcAABgAAQnnF7ZCADIAAAAA.',
['玄喵']='玄喵:BAAALgAECgYJBgAAAA==.',
['玄天']='玄天劫:BAAALgADCgMJAwAAAA==.',
['玉人']='玉人何处:BAABLgAFFH8IAAMaAAQJKxPxCwAmAQAaAAQJKxPxCwAmAQAZAAQJowehCgABAQAAAA==.',
['王心']='王心凌:BAAALgAECgEJAQAAAA==.',
['王牌']='王牌射手:BAAALgAECgYJBgAAAA==.王牌帝客:BAAALgAECgMJBAAAAA==.',
['玛卡']='玛卡什丶狂刃:BAAALgAECgMJAwAAAA==.',
['玛格']='玛格汉先祖:BAAALgAECgYJDQAAAA==.',
['玛法']='玛法尼奥:BAAALgAECgcJDgAAAA==.',
['玲娜']='玲娜贝儿:BAAALgAFFAQJAQAAAA==.',
['琓哋']='琓哋僦湜滈謿:BAAALgADCgMJAwAAAA==.',
['琥珀']='琥珀王:BAAALgAECgUJBQAAAA==.',
['琴棋']='琴棋书画唱丶:BAAALgAECgQJBwAAAA==.',
['璃珺']='璃珺墨:BAAALgAECgQJBQAAAA==.',
['瓜头']='瓜头蛙:BAAALgAECgcJAgAAAA==.',
['甜心']='甜心海牛:BAAALgAECgcJCgAAAA==.',
['生徒']='生徒会追随者:BAAALgAFFAIJAwAAAA==.',
['电小']='电小盆友:BAACLgAFFH8OAAIQAAUJKSFlAAD1AQAQAAUJKSFlAAD1AQAuAAQKfygAAhAACQlhJIkAAKsDABAACQlhJIkAAKsDAAAA.',
['电的']='电的一塌糊涂:BAACLgAFFH8UAAIPAAYJtBOOAQDmAQAPAAYJtBOOAQDmAQAuAAQKfykAAw8ACQn2HRIQAJcCAA8ACQn2HRIQAJcCABIAAQn4BnmNACoAAAAA.',
['电磁']='电磁你兼容吗:BAAALgAECgYJBgAAAA==.',
['疯宝']='疯宝:BAAALgADCgYJDAAAAA==.',
['疯狂']='疯狂小螃蟹:BAAALgAECgEJAgAAAA==.疯狂花姐:BAAALgAECgQJBQAAAA==.疯狂薇薇:BAAALgAECgEJAQAAAA==.',
['疯蛙']='疯蛙:BAAALgAECgIJBAAAAA==.',
['瘋狂']='瘋狂的小雨:BAAALgAECgEJAQAAAA==.',
['瘸子']='瘸子猫:BAABLgAFFH8FAAITAAIJMRIPRQCZAAATAAIJMRIPRQCZAAAAAA==.',
['瘸橘']='瘸橘子猫:BAAALgAECgEJAQAAAA==.',
['白兔']='白兔王:BAAALgAECgEJAQAAAA==.',
['白凝']='白凝冰:BAAALgADCgEJAQAAAA==.',
['白发']='白发魔术:BAACLgAFFH8EAAIIAAIJeSYOJgDoAAAIAAIJeSYOJgDoAAAuAAQKfxgABAgACAnWIxsTAOMCAAgACAnWIxsTAOMCABEAAgkgIN09AL0AAAcAAQlCBNA2ACkAAAAA.',
['白须']='白须:BAAALgAFFAEJAQAAAA==.',
['百变']='百变小德德:BAAALgAECgQJBAAAAA==.百变的大庆:BAAALgADCgUJBQAAAA==.',
['皇凌']='皇凌枫:BAAALgAECgYJDwAAAA==.',
['皮皮']='皮皮卡丘:BAAALgAECgYJBgAAAA==.',
['盛骑']='盛骑士:BAAALgAECgEJAQAAAA==.',
['睿恩']='睿恩的信仰:BAAALgAECgMJAwAAAA==.',
['瞎基']='瞎基尔变变:BAAALgAECgkJBgAAAA==.瞎基尔溜达:BAAALgAECgkJCQAAAA==.',
['石墨']='石墨烯:BAACLgAFFH8RAAIBAAYJ5RfsAQASAgABAAYJ5RfsAQASAgAuAAQKfygAAgEACQmBJHEAALsDAAEACQmBJHEAALsDAAAA.',
['石头']='石头的冰霜:BAAALgAECgkJEQAAAA==.石头的精灵:BAAALgAECgEJAQAAAA==.石头的鹰眼:BAAALgAECgcJDwAAAA==.',
['破碎']='破碎的暁菊花:BAAALgADCgYJBgAAAA==.',
['碧落']='碧落赋:BAAALgAECgQJBAAAAA==.',
['碳烤']='碳烤龙尾:BAACLgAFFH8LAAICAAYJohpeAgAjAgACAAYJohpeAgAjAgAuAAQKfycAAwIACQlFJF0CAIwDAAIACQlFJF0CAIwDAAMAAQm7CCE/ADMAAAAA.',
['神之']='神之宣告:BAAALgAECgcJBwAAAA==.',
['神奇']='神奇艾莉丝:BAAALgADCgMJAwAAAA==.',
['禅宗']='禅宗迦叶:BAAALgAECgQJBgAAAA==.',
['离经']='离经无悔:BAACLgAFFH8RAAIZAAYJgiPKAABqAgAZAAYJgiPKAABqAgAuAAQKfxcAAhkACQliITcDAEsDABkACQliITcDAEsDAAAA.',
['秋雨']='秋雨伊人:BAAALgADCgEJAQAAAA==.秋雨依然:BAAALgADCgMJAwAAAA==.',
['等死']='等死吧没救了:BAAALgAECgMJAwAAAA==.',
['筱炎']='筱炎:BAACLgAFFH8HAAIGAAMJfQl8QwCoAAAGAAMJfQl8QwCoAAAuAAQKfx8AAgYACAmEFJZgABkCAAYACAmEFJZgABkCAAAA.',
['米兰']='米兰的小铁匠:BAAALgAFFAIJAgAAAA==.',
['米花']='米花糖:BAAALgADCgQJBAAAAA==.',
['粉红']='粉红大叔:BAAALgAECgEJAQAAAA==.',
['糖姜']='糖姜姜:BAAALgAECgYJEQAAAA==.',
['糖糖']='糖糖璐璐:BAAALgAECgYJBgAAAA==.',
['紫玉']='紫玉幽兰:BAAALgAECgEJAQAAAA==.',
['紫皮']='紫皮大蒜:BAAALgAECgMJAwAAAA==.',
['繁若']='繁若星橙:BAAALgAECgYJDAAAAA==.',
['纸寂']='纸寂寞:BAABLgAFFH8IAAIIAAYJyh/YAABVAgAIAAYJyh/YAABVAgAAAA==.',
['纸鸢']='纸鸢鸩羽:BAAALgAFFAQJBAAAAA==.',
['细心']='细心依:BAAALgAECgcJCQAAAA==.',
['络缨']='络缨:BAAALgAECgEJAQAAAA==.',
['绝剑']='绝剑优纪:BAAALgAECgEJAgAAAA==.',
['绝对']='绝对呆子:BAAALgAECgEJAQAAAA==.',
['绿子']='绿子滕:BAAALgADCgYJBgAAAA==.',
['羡余']='羡余:BAAALgAECgQJBAAAAA==.',
['翡翠']='翡翠白玉湯:BAACLgAFFH8MAAMEAAUJvAmMEAAhAQAEAAQJIAmMEAAhAQAFAAQJQwjZFwCGAAAuAAQKfykAAwQACQnYH5ARAAQDAAQACQnYH5ARAAQDAAUACAnIFBskAAICAAAA.',
['老登']='老登本登:BAACLgAFFH8IAAIfAAMJLQyRCQDRAAAfAAMJLQyRCQDRAAAuAAQKfycAAh8ACQnUIXsEAEMDAB8ACQnUIXsEAEMDAAAA.',
['老西']='老西门酒寶寶:BAAALgAECggJCAAAAA==.',
['肾葵']='肾葵蝻子:BAAALgAECgMJAwABLgAFFAMJBQATAD4cAA==.',
['胖嘟']='胖嘟嘟小甜锡:BAAALgAECgYJBgAAAA==.',
['胸满']='胸满肥油:BAAALgAECgcJCwAAAA==.',
['脑袋']='脑袋困掉了:BAAALgAECgYJBgAAAA==.',
['腹背']='腹背受迪:BAABLgAECn8UAAIeAAYJJiLOIQBGAgAeAAYJJiLOIQBGAgAAAA==.',
['腿短']='腿短的阿昆达:BAAALgAFFAIJAgABLgAFFAIJAwAIADYaAA==.',
['臊气']='臊气的牛牛:BAAALgAECgQJBAAAAA==.',
['艾德']='艾德拉斯:BAAALgAECgIJAgAAAA==.',
['艾泽']='艾泽拉斯:BAAALgAECgUJBQAAAA==.',
['艾瑞']='艾瑞波堤:BAAALgAECgkJBwAAAA==.',
['花婲']='花婲:BAAALgAECgQJBAAAAA==.',
['芸荼']='芸荼:BAAALgAECgcJCgAAAA==.',
['苍蜣']='苍蜣登阶:BAAALgAECgMJAwAAAA==.',
['苏州']='苏州骑王:BAABLgAFFH8JAAIEAAMJoxXEFAADAQAEAAMJoxXEFAADAQAAAA==.',
['英雄']='英雄职业:BAAALgAECgcJDgABLgAFFAEJAQAMAAAAAA==.',
['茂茂']='茂茂大哥:BAAALgAECgEJAQAAAA==.',
['茬哪']='茬哪丨見過妳:BAAALgAECgQJBAAAAA==.',
['草莓']='草莓叁号:BAAALgAECgYJBgAAAA==.草莓壹号:BAAALgAECgUJBQAAAA==.草莓拾号:BAAALgAECgQJBAAAAA==.草莓捌号:BAAALgADCgcJBwAAAA==.草莓柒号:BAAALgADCgYJBgAAAA==.草莓贰号:BAAALgAECgIJAgAAAA==.',
['药师']='药师寺纱绫:BAAALgAECgYJBwAAAA==.',
['荻花']='荻花阴羊师:BAAALgAECgIJAgAAAA==.',
['莉丽']='莉丽:BAAALgADCgYJBgAAAA==.',
['莉莎']='莉莎莉莎:BAAALgAECgYJDQAAAA==.',
['莎士']='莎士比哑:BAAALgAECggJCAAAAA==.',
['菇凉']='菇凉天然纯:BAAALgADCgYJBgAAAA==.菇凉天然美:BAAALgADCgYJBgAAAA==.',
['萌天']='萌天殇:BAABLgAFFH8JAAINAAUJjRnXCQBBAQANAAUJjRnXCQBBAQAAAA==.',
['萌萌']='萌萌的三謌丶:BAAALgAECgYJBgAAAA==.',
['萨鲁']='萨鲁法厼:BAAALgAECgkJDgAAAA==.',
['葒莲']='葒莲:BAAALgAECgYJCwAAAA==.',
['葵葵']='葵葵子丶:BAAALgAECgIJAgAAAA==.',
['蓝小']='蓝小萌:BAAALgAECgIJAgAAAA==.',
['蓝魔']='蓝魔之花:BAAALgAECgMJAwAAAA==.',
['蕾妲']='蕾妲:BAAALgAECgIJAwAAAA==.',
['虚空']='虚空宝珠总代:BAABLgAFFH8GAAIXAAMJsRyxDQC9AAAXAAMJsRyxDQC9AAAAAA==.',
['蛋疼']='蛋疼派:BAAALgAFFAEJAQAAAA==.',
['蝶舞']='蝶舞翠:BAABLgAECn8bAAIaAAgJYB7UCgDdAgAaAAgJYB7UCgDdAgAAAA==.',
['血月']='血月无边:BAAALgAECgYJDQAAAA==.',
['血柚']='血柚子:BAAALgAECgYJCAAAAA==.',
['血腥']='血腥粗又长:BAAALgAECgMJAwAAAA==.',
['血魔']='血魔追猎者:BAAALgADCgEJAgAAAA==.',
['行吧']='行吧来都来了:BAAALgAECgUJAgAAAA==.',
['表妹']='表妹:BAAALgAFFAMJBAAAAA==.',
['裂空']='裂空:BAAALgAECgEJAgAAAA==.',
['補中']='補中益氣丸:BAAALgAECgYJBwAAAA==.',
['討厭']='討厭騩:BAAALgAFFAIJBAABLgAFFAMJBgAaAMoMAA==.',
['誰在']='誰在你左边:BAAALgAECgEJAQAAAA==.',
['试试']='试试就逝世:BAAALgADCgMJAwAAAA==.',
['诗短']='诗短梦长:BAAALgAECgMJAwABLgAFFAMJBgABADwKAA==.',
['请叫']='请叫我哦鸡酱:BAAALgAECgUJCAAAAA==.',
['谢尔']='谢尔顿库珀:BAAALgAECgQJBAAAAA==.',
['賈坤']='賈坤:BAAALgAECgYJBgAAAA==.',
['賦風']='賦風擷穎:BAAALgAFFAQJBAABLgAFFAcJBwAGANEWAA==.',
['贝利']='贝利:BAAALgADCgEJAQAAAA==.',
['轻羽']='轻羽飞扬:BAACLgAFFH8HAAIaAAMJSAN5IQBqAAAaAAMJSAN5IQBqAAAuAAQKfx4AAhoACAnxEXAnAMoBABoACAnxEXAnAMoBAAAA.',
['还记']='还记得第一次:BAAALgAECgcJBwAAAA==.',
['这般']='这般热恋:BAAALgAECgkJAgAAAA==.',
['远见']='远见的鹰:BAAALgAECgUJDAAAAA==.',
['远野']='远野家主秋叶:BAACLgAFFH8QAAIVAAYJ6iNgAAB8AgAVAAYJ6iNgAAB8AgAuAAQKfygAAxUACQm+JXEEAEcDABUACAnMJXEEAEcDABYABgmTIesgAPYBAAAA.',
['迷之']='迷之东风:BAAALgAECgYJBgAAAA==.',
['迷失']='迷失的西斯:BAAALgAECgMJAwAAAA==.',
['逆风']='逆风之翼:BAAALgAECgEJAQAAAA==.',
['逍遥']='逍遥的达叔:BAAALgADCgUJBQAAAA==.',
['逻狗']='逻狗盛:BAAALgAECgIJAQAAAA==.',
['遇神']='遇神殺神:BAABLgAFFH8GAAIaAAMJygz7FADOAAAaAAMJygz7FADOAAAAAA==.',
['遗失']='遗失的世界:BAAALgAECgYJBgAAAA==.',
['遥遥']='遥遥以轻飏:BAACLgAFFH8GAAQBAAMJPApBCgBJAAABAAMJPApBCgBJAAACAAEJ3QKkIgBIAAADAAEJHAEcDABCAAAuAAQKfxUABAMACAlcF+MTAKcBAAMABgkrHeMTAKcBAAEAAwmpDd83AK0AAAIAAgnEGkweAEcAAAAA.',
['遺忘']='遺忘沉默:BAAALgAECgEJAgAAAA==.',
['那么']='那么敷衍:BAAALgAECgkJCwAAAA==.',
['邦桑']='邦桑迪的契约:BAAALgAECgYJCQAAAA==.',
['郑佳']='郑佳老公:BAAALgAECgcJBwAAAA==.',
['郭的']='郭的纲:BAAALgAECgYJBgAAAA==.',
['酷术']='酷术:BAAALgADCgIJAgAAAA==.',
['酷酷']='酷酷哒熊猫:BAAALgAECgEJAwAAAA==.',
['酸酸']='酸酸爱美丽:BAAALgAFFAEJAQAAAA==.',
['醉春']='醉春风:BAAALgADCgYJBgAAAA==.',
['野蛮']='野蛮神话:BAAALgAECgYJEwAAAA==.',
['钉钉']='钉钉历险记:BAAALgAECgYJCAAAAA==.',
['铁侽']='铁侽:BAAALgAECgIJAgAAAA==.',
['银色']='银色主旋律:BAAALgAECgUJAgAAAA==.',
['镹肆']='镹肆伍:BAAALgAECgUJBQAAAA==.',
['阿克']='阿克娅:BAAALgAECgYJBgAAAA==.',
['阿姨']='阿姨的小迷弟:BAABLgAFFH8HAAITAAMJchX6JwD4AAATAAMJchX6JwD4AAAAAA==.',
['阿尔']='阿尔佛雷德:BAABLgAECn8VAAMEAAYJ0Bo7WADaAQAEAAYJ0Bo7WADaAQAFAAYJpw8/SwBLAQAAAA==.',
['阿斯']='阿斯忒里俄斯:BAABLgAFFH8GAAIZAAMJYxY7BgDdAAAZAAMJYxY7BgDdAAAAAA==.',
['阿星']='阿星真莱斯:BAAALgAECgIJAgAAAA==.',
['阿格']='阿格莱雅:BAAALgAECgcJDQAAAA==.',
['阿波']='阿波尼娅:BAAALgAECgIJAgAAAA==.',
['阿茶']='阿茶:BAAALgAFFAEJAQAAAA==.',
['阿萬']='阿萬:BAAALgADCgcJCgAAAA==.',
['陈小']='陈小落:BAACLgAFFH8GAAMNAAMJGgbSDwDRAAANAAMJGgbSDwDRAAALAAEJKgIGGAA0AAAuAAQKfyEAAw0ABwnHFVgeAKEBAA0ABwmAFVgeAKEBAAsABgmiCqRGAB4BAAAA.',
['陳醫']='陳醫生:BAAALgAECgYJDAAAAA==.',
['陶陶']='陶陶的小白:BAAALgAECgYJBgABLgAFFAQJBAAMAAAAAA==.',
['隔壁']='隔壁佬楊:BAAALgADCgQJBAAAAA==.',
['雁门']='雁门关大叔:BAAALgAECgQJCAABLgAECgUJBAAMAAAAAA==.雁门关妞妞:BAAALgAECgUJBAAAAA==.雁门关猎手:BAAALgAECgEJAQABLgAECgUJBAAMAAAAAA==.雁门关老猎:BAAALgAECgMJAwABLgAECgUJBAAMAAAAAA==.雁门关老黑:BAAALgAECgMJBAAAAA==.',
['雨宫']='雨宫琴音:BAAALgADCgEJAQAAAA==.',
['雨後']='雨後凋零:BAABLgAECn8WAAQIAAYJ/B/IdwBtAQAIAAUJ/B/IdwBtAQARAAEJAACyZABFAAAHAAEJMhHqLQBDAAAAAA==.',
['雨落']='雨落晨曦:BAAALgAECgYJDgAAAA==.',
['雪碧']='雪碧烤肉:BAABLgAECn8aAAITAAgJDSL9GQDhAgATAAgJDSL9GQDhAgAAAA==.',
['零度']='零度冰可乐:BAABLgAECn8WAAIPAAgJWh2LEgCCAgAPAAgJWh2LEgCCAgAAAA==.',
['霍家']='霍家拳型霍格:BAAALgAECgYJBgAAAA==.',
['霜之']='霜之寒霜之箭:BAAALgAECgEJAQAAAA==.霜之死亡之刺:BAAALgADCggJCAAAAA==.',
['霜胄']='霜胄:BAAALgAECgUJBQAAAA==.',
['露安']='露安:BAAALgADCgUJBQAAAA==.',
['露茜']='露茜琊:BAAALgAECgQJBAAAAA==.',
['青丘']='青丘丨白浅:BAAALgAECggJEgAAAA==.',
['青春']='青春学园:BAAALgADCgQJBAAAAA==.',
['青桔']='青桔柠檬丷:BAAALgAECgEJAQAAAA==.',
['韶华']='韶华白首:BAAALgAECgUJCQAAAA==.',
['顶不']='顶不住一点:BAAALgADCgQJBAAAAA==.',
['顽披']='顽披:BAAALgAECggJCAAAAA==.',
['风之']='风之子煞:BAAALgAECgcJAQAAAA==.风之子隼:BAAALgAFFAEJAQAAAA==.风之子零:BAAALgAECgQJBQAAAA==.风之拉斐尔:BAAALgAECgEJAQAAAA==.',
['风冽']='风冽:BAAALgAECgYJBgAAAA==.',
['风吹']='风吹死神泪:BAAALgAECgYJBwAAAA==.',
['风岚']='风岚战暮:BAAALgAECgYJBgAAAA==.',
['风暴']='风暴之灵:BAAALgAECgcJBwAAAA==.',
['风风']='风风云:BAAALgAECgYJCQAAAA==.',
['飘颻']='飘颻丷:BAAALgAECgYJDgAAAA==.',
['饿奏']='饿奏么背住:BAAALgAECgIJAwAAAA==.',
['驚鴻']='驚鴻游龍:BAAALgAECgYJCgAAAA==.',
['魂之']='魂之纹章:BAAALgAECgUJCgAAAA==.',
['魂小']='魂小骑:BAAALgAECgUJBQAAAA==.',
['魅影']='魅影冰:BAACLgAFFH8FAAIGAAMJvASLMQDnAAAGAAMJvASLMQDnAAAuAAQKfyMAAgYABwlxFggkAEEBAAYABwlxFggkAEEBAAAA.',
['魔法']='魔法少女克罗:BAAALgAFFAQJBAAAAA==.魔法少女咸鱼:BAABLgAFFH8QAAINAAQJsSU3BACtAQANAAQJsSU3BACtAQABLgAFFAkJAQAMAAAAAA==.',
['魔火']='魔火之雷:BAAALgAECgcJEAAAAA==.',
['魔灬']='魔灬堕弋天:BAAALgAECgQJBAAAAA==.',
['鮮血']='鮮血玫瑰:BAAALgAECgUJBgAAAA==.',
['鸾回']='鸾回凤翥:BAAALgAECgkJEAABLgAFFAQJAwAMAAAAAA==.',
['鸿狐']='鸿狐:BAAALgAECgIJAwAAAA==.',
['麦吉']='麦吉:BAAALgAECgUJAgAAAA==.',
['黑妞']='黑妞冲击:BAAALgAECgIJAwAAAA==.',
['黑羽']='黑羽之兽饮月:BAABLgAFFH8HAAIbAAMJ8x68CwADAQAbAAMJ8x68CwADAQAAAA==.',
['黑鼻']='黑鼻子大花猫:BAAALgAECgYJCQAAAA==.',
['黯煌']='黯煌零:BAAALgAECgEJAgABLgAECgEJAgAMAAAAAA==.',
['齐静']='齐静春:BAAALgAECgYJBgAAAA==.',
['龙城']='龙城星垂野:BAAALgADCgUJBQAAAA==.龙城逍遥德:BAAALgAECgQJBQAAAA==.龙城铁骑还:BAAALgADCgQJBAAAAA==.',
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
