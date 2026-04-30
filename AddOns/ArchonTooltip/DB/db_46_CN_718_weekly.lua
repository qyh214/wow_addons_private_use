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

local lookup = {'Shaman-Elemental','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Druid-Restoration','DeathKnight-Unholy','Unknown-Unknown','Mage-Frost','Paladin-Holy','Paladin-Retribution','Paladin-Protection','DeathKnight-Blood','DemonHunter-Devourer','DemonHunter-Havoc','Druid-Guardian','Monk-Brewmaster','Hunter-Marksmanship','Warlock-Demonology','Priest-Holy','Druid-Balance','Druid-Feral','Warlock-Destruction','Warlock-Affliction','Rogue-Subtlety','Rogue-Outlaw','Hunter-BeastMastery','Hunter-Survival','Shaman-Restoration','Monk-Windwalker','Monk-Mistweaver','Warrior-Protection','Priest-Shadow','Priest-Discipline','Mage-Fire','Mage-Arcane',}
local provider = {region='CN',realm='梦境之树',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Addiction:BAAALgAECgEJAgAAAA==.',
Ae='Aegwyn:BAAALgAECgUJCAAAAA==.',
Ag='Agito:BAABLgAFFH8NAAIBAAQJrhleAgBXAQABAAQJrhleAgBXAQAAAA==.',
Al='Alannix:BAAALgAECgYJCwAAAA==.',
An='Andy:BAACLgAFFH8MAAICAAQJQiDQBgCDAQACAAQJQiDQBgCDAQAuAAQKfyUAAwIACAmbIF8GAN0CAAIACAmbIF8GAN0CAAMAAQmSER4JAEMAAAAA.Ankhdrunk:BAAALgADCgEJAQAAAA==.',
As='Asser:BAAALgAECgEJAQAAAA==.',
Ba='Badada:BAAALgAECgYJEwAAAA==.',
Bi='Binglian:BAACLgAFFH8HAAMEAAQJBR02DQAtAQAEAAMJGyE2DQAtAQACAAEJph4/FQBgAAAuAAQKfyoABAQACAkVJYMAAOsCAAQABwkVJYMAAOsCAAMABQmpHV8VAJcBAAIABQmbGj4fAIYBAAAA.',
Bo='Bobdylan:BAAALgAECgYJCwAAAA==.Bovinee:BAACLgAFFH8LAAIFAAMJJh7+DQAIAQAFAAMJJh7+DQAIAQAuAAQKfx4AAgUABwnuINwVAIgCAAUABwnuINwVAIgCAAAA.',
Br='Breezewing:BAAALgAECgEJAQAAAA==.Brotherchunn:BAAALgAECgYJBgAAAA==.',
Ca='Castormonk:BAAALgAECgkJBgAAAA==.',
Co='Cobra:BAAALgAECgQJBAAAAA==.',
Cu='Cust:BAAALgADCgEJAQAAAA==.',
De='Deadk:BAABLgAECn8ZAAIGAAYJKxhsFABvAQAGAAYJKxhsFABvAQAAAA==.Demonwhisper:BAAALgAECgYJCwAAAA==.',
Dh='Dhtwyz:BAAALgAECgEJAQAAAA==.',
Ed='Edgclearlove:BAAALgADCgYJBgAAAA==.',
El='Ellenwuu:BAAALgAECggJCgAAAA==.Elzayork:BAAALgAECgQJBwABLgAECgUJBQAHAAAAAA==.',
Fu='Furina:BAAALgAECgYJEgAAAA==.',
Ga='Gaisk:BAAALgAECgYJBgAAAA==.Gaiss:BAAALgAFFAIJAgAAAA==.',
Ge='Gewen:BAAALgAECgYJEwAAAA==.',
Gu='Gulaba:BAAALgAECgQJBAAAAA==.',
Ha='Harell:BAAALgADCgUJBQAAAA==.',
Hh='Hherobrine:BAAALgAECgEJAQAAAA==.',
Il='Iloveyy:BAAALgADCgMJAwAAAA==.',
Iv='Iv:BAAALgAECgYJCAAAAA==.',
Ja='Jason:BAAALgAECgEJAQAAAA==.',
Ju='Julia:BAAALgAECgIJAgAAAA==.',
Kk='Kkd:BAAALgAECgYJDwAAAA==.',
Li='Lichrage:BAAALgADCgEJAQAAAA==.Lightking:BAAALgAECgcJCAAAAA==.Liliumm:BAAALgADCggJCAAAAA==.Litigation:BAAALgAECgIJAgAAAA==.',
Lu='Luning:BAAALgADCgcJBwAAAA==.',
Ma='Madly:BAABLgAECn8VAAIIAAYJYSAiXwAdAgAIAAYJYSAiXwAdAgAAAA==.Marlboros:BAAALgAECgEJAQAAAA==.',
Mi='Missoutyou:BAACLgAFFH8KAAIIAAQJDxNhGQBlAQAIAAQJDxNhGQBlAQAuAAQKfxgAAggACQmoHiQMAGMDAAgACQmoHiQMAGMDAAAA.',
Mo='Mortis:BAACLgAFFH8LAAIJAAQJ0xHKCgAwAQAJAAQJ0xHKCgAwAQAuAAQKfygAAwkACAl0Gl8fAB4CAAkACAl0Gl8fAB4CAAoABwmlFENbANEBAAAA.',
Na='Namo:BAAALgAECgMJAwAAAA==.Naomi:BAAALgADCgMJAwAAAA==.',
Ni='Nikka:BAAALgAECgMJAwABLgAFFAYJFQALAGUlAA==.',
Ok='Okda:BAAALgAECgIJAgAAAA==.',
Oo='Ookami:BAACLgAFFH8UAAIMAAUJXCbGAAAxAgAMAAUJXCbGAAAxAgAuAAQKfyYAAgwACAlSJegBAGEDAAwACAlSJegBAGEDAAAA.',
Pe='Peashooter:BAAALgAFFAEJAQAAAA==.',
Pl='Playeruddopr:BAAALgAECgEJAgAAAA==.',
Po='Potom:BAAALgADCgkJCQABLgAECgYJCAAHAAAAAA==.',
Py='Pyzless:BAAALgAECgIJAgAAAA==.',
Re='Remote:BAABLgAFFH8WAAINAAYJcR/EAADhAQANAAYJcR/EAADhAQAAAA==.Remotet:BAABLgAECn8UAAMOAAgJsySPAwBIAwAOAAgJsySPAwBIAwANAAYJMRBMiwAMAQAAAA==.Revvyhn:BAAALgAFFAIJAgAAAA==.',
Ro='Royo:BAAALgADCgQJBAAAAA==.',
Rr='Rrllyyjj:BAAALgAECgIJAgAAAA==.',
Sh='Shionne:BAAALgAECgkJDAAAAA==.',
St='Starlish:BAAALgAECgIJAgAAAA==.Stella:BAAALgAFFAQJBAAAAA==.',
Su='Superbiadrud:BAABLgAECn8VAAMFAAcJUg87WgBDAQAFAAcJUg87WgBDAQAPAAQJFgfQJQBuAAABLgAFFAQJCgAQAO0SAA==.',
Th='Thebscyf:BAAALgADCgQJBAAAAA==.Thesweetfish:BAAALgADCgEJAQAAAA==.',
Tr='Truefan:BAACLgAFFH8LAAIRAAUJlSFZBADzAQARAAUJlSFZBADzAQAuAAQKfxYAAhEACAm/I/kIAA8DABEACAm/I/kIAA8DAAAA.',
Va='Vaseline:BAAALgAECgEJAQAAAA==.',
Ve='Velvet:BAAALgAECgEJAQAAAA==.',
Vi='Violin:BAAALgAECgcJCAAAAA==.Virtuosa:BAAALgAECgUJBQAAAA==.',
Vs='Vscode:BAAALgAFFAEJAQABLgAFFAQJCwAQAJEKAA==.',
Vw='Vwkwv:BAAALgAECgYJDwAAAA==.',
Ws='Wswyz:BAAALgAECgMJBQAAAA==.',
Yi='Yifaerchen:BAAALgADCgIJAgAAAA==.',
Yo='Youngscrappy:BAABLgAFFH8RAAIQAAUJRRAqBQAoAQAQAAUJRRAqBQAoAQAAAA==.',
Yy='Yyjjxin:BAAALgADCgUJBQAAAA==.',
Ze='Zeztz:BAAALgAFFAIJAwAAAA==.',
Zm='Zmagetwo:BAABLgAFFH8JAAIIAAcJnhU+AAAzAgAIAAcJnhU+AAAzAgAAAA==.',
Zy='Zyb:BAAALgADCgEJAQAAAA==.',
['一只']='一只哞哞牛丶:BAAALgAECgQJBAAAAA==.一只小锤锤丶:BAAALgAECgYJCQAAAA==.一只抹油的猪:BAAALgAECgkJEgAAAA==.',
['一头']='一头喵咕熊:BAAALgAECgIJAgAAAA==.',
['一帮']='一帮妇女:BAAALgADCgUJBQAAAA==.',
['一抹']='一抹浅笑伤丶:BAAALgAECgMJAwAAAA==.',
['一拳']='一拳:BAAALgAFFAMJBAAAAA==.',
['一朵']='一朵花菜:BAAALgAECgkJAQAAAA==.',
['一棵']='一棵梧桐树:BAAALgADCgEJAQAAAA==.一棵葡萄树:BAAALgADCgEJAQAAAA==.',
['一碰']='一碰就嗯:BAAALgAECgkJCQAAAA==.',
['一箭']='一箭穿云:BAAALgAECgYJBgAAAA==.',
['一西']='一西门吹雪一:BAAALgAECgIJAgAAAA==.',
['一辣']='一辣辣一:BAAALgAFFAIJBAAAAA==.',
['七亿']='七亿少女梦丶:BAAALgAECgYJCQAAAA==.',
['七点']='七点就打野:BAAALgADCgIJAgAAAA==.',
['万有']='万有引力:BAAALgAFFAEJAQABLgAFFAQJBAAHAAAAAA==.',
['三个']='三个月:BAABLgAFFH8JAAISAAQJWBXCEQBWAQASAAQJWBXCEQBWAQAAAA==.',
['三目']='三目:BAAALgAECgEJAQAAAA==.',
['三空']='三空:BAAALgAECgMJAgAAAA==.',
['三顾']='三顾冒菜丶:BAABLgAFFH8GAAITAAMJyBvKBAC3AAATAAMJyBvKBAC3AAAAAA==.',
['上杉']='上杉丨绘梨衣:BAAALgAFFAQJBAAAAA==.',
['下弦']='下弦月:BAAALgADCgEJAQAAAA==.',
['不了']='不了的思念:BAAALgAECgEJAQAAAA==.',
['不二']='不二:BAAALgAECgkJDgAAAA==.不二大成:BAAALgAFFAIJAwAAAA==.',
['不交']='不交减伤放生:BAAALgAECgYJCgAAAA==.',
['不羁']='不羁的橙子:BAAALgAECgMJAwAAAA==.',
['不行']='不行除非加钱:BAAALgAECgEJAQAAAA==.',
['专业']='专业冲锋释放:BAAALgAECgUJCQAAAA==.',
['世界']='世界的尽头:BAAALgAECgcJEgAAAA==.世界第一骑士:BAAALgAECgMJAwAAAA==.',
['丛雨']='丛雨:BAAALgAECgYJCwAAAA==.',
['中二']='中二的圣骑:BAAALgAFFAIJAgABLgAFFAQJCQAKAHYlAA==.',
['中儿']='中儿:BAAALgAECgQJBAAAAA==.',
['丶戰']='丶戰前女神:BAAALgAFFAEJAQAAAA==.',
['丶茶']='丶茶凉了丶:BAAALgAECgQJBAAAAA==.',
['丶长']='丶长丶安丿:BAAALgADCgYJBgAAAA==.',
['丷白']='丷白浅:BAAALgAECgIJAgAAAA==.',
['丿莫']='丿莫问:BAAALgAFFAIJAgAAAA==.',
['乄冰']='乄冰子乄:BAAALgAECgEJAQAAAA==.',
['乄灵']='乄灵之舞乄:BAAALgAECgEJAQAAAA==.',
['乄空']='乄空大的劫乄:BAAALgADCgEJAQAAAA==.',
['么么']='么么兒:BAAALgAECgQJBAAAAA==.',
['乐天']='乐天果粒橙:BAAALgAECgEJAQAAAA==.',
['乘客']='乘客:BAAALgADCgEJAQAAAA==.',
['九清']='九清揽月:BAAALgAECgMJAwAAAA==.',
['九点']='九点不准睡:BAABLgAECn8VAAMUAAgJvRweEwB8AgAUAAgJvRweEwB8AgAFAAUJRB4oRwCFAQABLgAFFAYJDgAUAP8PAA==.',
['了此']='了此生:BAAALgAECgkJCwAAAA==.',
['二月']='二月六:BAAALgAFFAEJAQAAAA==.二月德:BAABLgAECn8UAAMFAAcJeha8OADDAQAFAAcJeha8OADDAQAVAAUJaxVdFQBgAQAAAA==.二月战:BAAALgAECgcJDQAAAA==.二月牧:BAAALgAECgYJDwAAAA==.二月猎:BAAALgAECgEJAQAAAA==.二月萨:BAAALgAECgQJBQAAAA==.',
['二脚']='二脚踢:BAAALgAFFAIJAgAAAA==.',
['五线']='五线乐谱:BAAALgAFFAIJAgAAAA==.',
['井之']='井之上泷奈:BAAALgADCgkJCQAAAA==.',
['亚顿']='亚顿之矛丶:BAAALgAECgEJAQAAAA==.',
['人海']='人海中的孤影:BAAALgAECgkJDgAAAA==.',
['人神']='人神共焚:BAAALgAECgIJAwAAAA==.',
['人间']='人间小妖精:BAAALgAECgMJAwAAAA==.人间无事人:BAAALgAECgIJAgAAAA==.',
['仓鼠']='仓鼠飞仑:BAABLgAFFH8JAAICAAQJpg2lCgBAAQACAAQJpg2lCgBAAQAAAA==.',
['仙仙']='仙仙青柑青提:BAAALgAECgUJBgAAAA==.',
['代号']='代号审判:BAAALgAECgIJBQAAAA==.',
['以安']='以安:BAAALgAECgMJAwAAAA==.',
['以德']='以德变人:BAAALgADCgEJAQAAAA==.',
['仲小']='仲小坏:BAAALgADCgYJBgAAAA==.',
['伊云']='伊云言:BAAALgAECgYJEAAAAA==.',
['伊利']='伊利兰:BAAALgAECgUJBQAAAA==.',
['伊墨']='伊墨惜兮:BAABLgAECn8bAAQWAAcJYRpGJAA4AQASAAYJmhfyXwCpAQAWAAQJthpGJAA4AQAXAAEJAABaJQBcAAAAAA==.',
['伊格']='伊格诺斯:BAAALgAFFAMJAwAAAA==.',
['伊立']='伊立丹怒风:BAAALgAECgIJAwAAAA==.',
['伊莉']='伊莉雅蕾:BAAALgAECgQJBgAAAA==.',
['伊里']='伊里野的天空:BAAALgAECgMJAwAAAA==.',
['众生']='众生灬:BAAALgADCgQJBwAAAA==.',
['优酸']='优酸乳灬:BAAALgAECgcJEwAAAA==.',
['佘琦']='佘琦:BAAALgADCgEJAQAAAA==.',
['你从']='你从未离去:BAAALgAECgEJAQAAAA==.',
['你是']='你是不懂哦:BAAALgADCgEJAQAAAA==.',
['你的']='你的神来了:BAAALgAECgQJBAAAAA==.',
['你要']='你要尝一口吗:BAACLgAFFH8QAAMYAAQJ2iNuBACqAQAYAAQJaCJuBACqAQAZAAQJNB1BAQC4AAAuAAQKfyoAAxgACAnPJDMEAFYDABgACAmBJDMEAFYDABkACAlIIvsAALgBAAAA.',
['侍书']='侍书:BAAALgAECgIJAwAAAA==.',
['依云']='依云燕:BAAALgAECgYJCAAAAA==.',
['信仰']='信仰绯月:BAAALgAECgYJDgAAAA==.',
['假死']='假死一下:BAAALgADCgEJAQAAAA==.',
['做梦']='做梦都想瘦:BAAALgAECgEJAQAAAA==.',
['偷羊']='偷羊贼:BAAALgAECgYJDwAAAA==.',
['光影']='光影圣光:BAAALgAECgEJAQAAAA==.',
['光明']='光明牛奶:BAAALgAECgYJCQAAAA==.',
['入魂']='入魂:BAAALgAECgEJAQAAAA==.',
['六影']='六影:BAAALgADCgYJBgAAAA==.',
['六月']='六月的耨耨:BAAALgAECgUJBgAAAA==.',
['兮语']='兮语兮语:BAAALgAFFAEJAQAAAA==.',
['兰希']='兰希多姆:BAABLgAFFH8MAAICAAQJvSKIBQCdAQACAAQJvSKIBQCdAQAAAA==.',
['冂丄']='冂丄冂:BAAALgADCgEJAQAAAA==.',
['冂冂']='冂冂:BAAALgAECgIJAwAAAA==.',
['农民']='农民山泉:BAAALgAECgkJEAAAAA==.',
['冬丶']='冬丶冰:BAAALgAECgMJAQAAAA==.',
['冰夫']='冰夫人:BAAALgAECgkJBgAAAA==.',
['冰河']='冰河灬:BAAALgAECgUJBQABLgAFFAUJAQAHAAAAAA==.',
['冰糖']='冰糖起司:BAAALgAECgEJAQAAAA==.',
['冰红']='冰红柠檬茶:BAAALgAECgEJAQAAAA==.',
['冰青']='冰青椰:BAAALgADCgQJBAAAAA==.',
['准备']='准备卖老:BAAALgAECgcJCQAAAA==.',
['准男']='准男:BAABLgAFFH8GAAIGAAMJrBicJQD/AAAGAAMJrBicJQD/AAAAAA==.',
['凉雨']='凉雨丶知秋:BAAALgAECgYJDAAAAA==.',
['凌霄']='凌霄殿黄袍身:BAAALgADCgYJBgAAAA==.',
['凤南']='凤南行:BAAALgADCgcJBwAAAA==.',
['凰儛']='凰儛玖兲:BAAALgAECgUJBQAAAA==.',
['击剑']='击剑小药娘:BAAALgAECgkJCQAAAA==.',
['刃下']='刃下心:BAAALgAECgYJDwAAAA==.',
['初號']='初號機:BAAALgAECgkJBwAAAA==.',
['利瓦']='利瓦拉:BAAALgAECgYJCwAAAA==.',
['别打']='别打我我很菜:BAAALgAECgYJDQAAAA==.别打扰我射击:BAAALgADCgUJBQAAAA==.',
['刹那']='刹那清欢:BAACLgAFFH8RAAMaAAUJ0RSwBABXAQAaAAQJ0RSwBABXAQARAAEJAADTKgBGAAAuAAQKfxcAAhoACAm3HrcXAHsCABoACAm3HrcXAHsCAAAA.',
['前世']='前世蝶缘:BAAALgAECgYJBwAAAA==.',
['力强']='力强如智:BAAALgAECgYJBwAAAA==.',
['勾世']='勾世:BAAALgADCgMJAwAAAA==.',
['包有']='包有米:BAAALgADCgUJBQAAAA==.包有财:BAAALgADCgUJBQAAAA==.',
['匆荷']='匆荷:BAAALgAECgQJBgAAAA==.',
['十二']='十二号化肥:BAAALgAFFAEJAQAAAA==.',
['十年']='十年灬:BAAALgAECgQJBAAAAA==.',
['千十']='千十来个妹子:BAAALgADCgMJAwAAAA==.',
['卓越']='卓越的途途:BAAALgAECgQJCQAAAA==.',
['单面']='单面体:BAAALgAECgEJAQAAAA==.',
['南南']='南南达也:BAAALgAECgYJAgAAAA==.',
['南宫']='南宫犇犇:BAAALgAECggJCAAAAA==.',
['南岸']='南岸靑栀:BAABLgAFFH8GAAIGAAIJGiGRNQCxAAAGAAIJGiGRNQCxAAAAAA==.',
['南熙']='南熙:BAABLgAECn8YAAIbAAcJhB7VBwBxAgAbAAcJhB7VBwBxAgAAAA==.',
['南燕']='南燕:BAAALgAFFAEJAQAAAA==.',
['南风']='南风灬知我意:BAAALgAFFAIJAwAAAA==.',
['博尔']='博尔赫斯:BAACLgAFFH8FAAMRAAMJzg7SFQDsAAARAAMJzg7SFQDsAAAaAAEJDwLdKgBMAAAuAAQKfxUAAhEABglaGeQvALMBABEABglaGeQvALMBAAAA.',
['卡寇']='卡寇莎:BAAALgAECgYJBgAAAA==.',
['古尔']='古尔丁:BAAALgAECgEJAQAAAA==.',
['只管']='只管拉不管送:BAAALgADCgIJAgAAAA==.',
['史丹']='史丹利:BAAALgADCgIJAgAAAA==.',
['叶十']='叶十七:BAAALgAECgIJAgAAAA==.',
['叶樱']='叶樱院彩芽:BAAALgAECgYJBgAAAA==.',
['司鸿']='司鸿介:BAAALgAFFAIJAwAAAA==.',
['吃茄']='吃茄子的狼丶:BAAALgAECggJDwAAAA==.',
['吃草']='吃草的荷兰猪:BAAALgADCgEJAQAAAA==.',
['听南']='听南:BAAALgADCgUJBQAAAA==.',
['听风']='听风又听雨:BAAALgAECgQJBAAAAA==.',
['吴歈']='吴歈越吟:BAAALgAECgYJBgAAAA==.',
['吴老']='吴老黑哥:BAAALgADCgYJBgAAAA==.',
['吹拉']='吹拉弹唱:BAAALgADCgYJBgAAAA==.',
['周三']='周三哥:BAABLgAECn8YAAISAAcJNxD1YACmAQASAAcJNxD1YACmAQAAAA==.',
['和乐']='和乐:BAAALgAECgQJBAAAAA==.',
['咏丶']='咏丶唱:BAAALgADCgYJBgAAAA==.',
['咕咕']='咕咕小精灵:BAAALgAFFAIJAgAAAA==.',
['咕喵']='咕喵王代言人:BAAALgAECgYJBwAAAA==.',
['咸鱼']='咸鱼技师:BAAALgAECgYJEgAAAA==.',
['咻射']='咻射:BAAALgAECgYJBgAAAA==.',
['哆嗦']='哆嗦啰嗦:BAAALgAFFAIJBAAAAA==.哆嗦小萌猎:BAABLgAFFH8LAAMaAAQJeBogBABEAQAaAAQJeBogBABEAQARAAIJqQYDIgCEAAAAAA==.',
['哈兜']='哈兜哏:BAAALgAECgMJAwAAAA==.',
['哈基']='哈基咕:BAAALgAECgIJBQAAAA==.哈基咪:BAAALgADCgUJBgAAAA==.',
['哈迪']='哈迪伊斯玛迩:BAAALgAFFAEJAQAAAA==.',
['哎悠']='哎悠:BAAALgADCgUJBQAAAA==.',
['哥伦']='哥伦比娅:BAAALgAECgYJDAAAAA==.',
['哥鱼']='哥鱼比娅:BAAALgAECgEJAQAAAA==.',
['唯爱']='唯爱冰冰:BAAALgAECgEJAQAAAA==.',
['唷唷']='唷唷:BAAALgADCgEJAQAAAA==.',
['啊克']='啊克萌德:BAAALgAECgkJCQAAAA==.',
['啊坤']='啊坤:BAACLgAFFH8HAAIIAAMJtQTcMQDhAAAIAAMJtQTcMQDhAAAuAAQKfyMAAggABwmfGLBnAAcCAAgABwmfGLBnAAcCAAAA.',
['啊淦']='啊淦:BAAALgAFFAEJAQAAAA==.',
['啊龍']='啊龍:BAAALgADCgEJAQAAAA==.',
['啦啦']='啦啦荣肥:BAAALgAECgkJCwAAAA==.',
['啾啾']='啾啾星:BAAALgAECgcJDgAAAA==.',
['喜荫']='喜荫:BAAALgAECgYJDAAAAA==.',
['喵儿']='喵儿兄弟:BAAALgAECgkJCgAAAA==.',
['喵喵']='喵喵污:BAABLgAFFH8GAAIGAAIJ1hY7PQCkAAAGAAIJ1hY7PQCkAAAAAA==.',
['嗜睡']='嗜睡老虎狗:BAAALgAECgkJCAAAAA==.',
['噬魂']='噬魂挽歌:BAACLgAFFH8GAAIGAAMJUgOrLwDVAAAGAAMJUgOrLwDVAAAuAAQKfyMAAgYACAmJH+kEAEACAAYACAmJH+kEAEACAAAA.',
['四月']='四月物语:BAAALgADCgEJAQAAAA==.',
['团队']='团队吉祥物:BAAALgAECgEJAgAAAA==.',
['圆了']='圆了咕咚:BAAALgADCgYJBgAAAA==.',
['圣光']='圣光之至:BAAALgADCgUJBQAAAA==.圣光大熊喵:BAAALgAECgYJCAAAAA==.圣光守护者:BAAALgAECgIJAwAAAA==.圣光救救我:BAAALgAECgUJBQAAAA==.圣光永恒:BAAALgADCgcJBwAAAA==.圣光道标:BAAALgAECgQJBAAAAA==.',
['圣火']='圣火喵喵教主:BAAALgAECgMJAwAAAA==.圣火骑士:BAAALgAECgEJAQAAAA==.',
['圣焰']='圣焰:BAABLgAECn8UAAIKAAcJyg3aiwBjAQAKAAcJyg3aiwBjAQAAAA==.',
['在回']='在回家:BAAALgAECgMJAwAAAA==.',
['坚果']='坚果:BAAALgADCgQJBAAAAA==.',
['埃莱']='埃莱达尔:BAAALgADCgYJBgAAAA==.',
['塔苦']='塔苦菜:BAAALgAECgMJBAAAAA==.',
['墨蝉']='墨蝉:BAAALgAECgIJAgAAAA==.',
['夏汐']='夏汐霖:BAAALgAECgYJBgAAAA==.',
['外套']='外套:BAAALgAECgMJBAAAAA==.',
['多可']='多可悲:BAAALgAFFAIJAwAAAA==.',
['多面']='多面体:BAAALgADCgYJBgABLgAECgEJAQAHAAAAAA==.',
['夜刃']='夜刃:BAAALgADCgIJAgAAAA==.',
['夜梦']='夜梦:BAAALgAECgMJBAAAAA==.',
['夜闌']='夜闌靜:BAAALgAECgIJAQAAAA==.',
['夜鹰']='夜鹰:BAAALgAECgEJAgAAAA==.',
['大只']='大只佬:BAAALgAECgEJAQAAAA==.',
['大哞']='大哞:BAAALgAECgQJBAAAAA==.',
['大地']='大地之坏:BAACLgAFFH8HAAIcAAMJURUSCADUAAAcAAMJURUSCADUAAAuAAQKfycAAxwABwltHikYAFUCABwABwltHikYAFUCAAEABQmODopXAOcAAAAA.',
['大拉']='大拉扯家:BAAALgAECgYJEgAAAA==.',
['大灭']='大灭:BAAALgAECgQJCAAAAA==.',
['大烟']='大烟鬼:BAAALgAECgEJAQAAAA==.',
['大祥']='大祥老师:BAAALgADCgcJBwAAAA==.',
['大粗']='大粗:BAAALgAECgMJAwAAAA==.',
['天才']='天才吃瓜雪梨:BAABLgAFFH8FAAIBAAIJAhgFCQCuAAABAAIJAhgFCQCuAAAAAA==.',
['天津']='天津小艾:BAAALgAECgYJBgAAAA==.',
['天竹']='天竹辰:BAAALgAECgYJDQAAAA==.',
['太极']='太极禅:BAAALgAECgYJDwAAAA==.',
['太阳']='太阳黑子:BAAALgAFFAEJAQABLgAFFAQJDAAEAN4hAA==.',
['奇奇']='奇奇怪怪:BAAALgADCgEJAQAAAA==.',
['奇怪']='奇怪的防骑:BAAALgADCgYJBgAAAA==.',
['奇迹']='奇迹行者:BAAALgAECgEJAQAAAA==.',
['奈里']='奈里夫丶神谕:BAAALgAECgEJAQAAAA==.',
['奥格']='奥格小甜甜:BAAALgAECgYJBgAAAA==.',
['奥法']='奥法的暗牧:BAAALgAECgYJCgAAAA==.',
['女伯']='女伯爵艾蕾:BAAALgADCgYJBgAAAA==.',
['好大']='好大的凶器:BAAALgAECgIJAgAAAA==.',
['好想']='好想喝可乐:BAAALgAECgEJAQAAAA==.',
['妮球']='妮球:BAAALgAECgcJCAAAAA==.',
['妮菲']='妮菲凯渊:BAAALgAECgEJAQAAAA==.',
['姚宝']='姚宝宝:BAAALgAECgEJAQAAAA==.',
['娜诺']='娜诺:BAAALgAECgMJAwAAAA==.',
['嫙岄']='嫙岄甜酒果:BAAALgADCgYJCgAAAA==.',
['嬅尔']='嬅尔:BAAALgAECgIJAgAAAA==.',
['子弹']='子弹上膛丶:BAAALgAFFAYJBAAAAA==.',
['子越']='子越子越:BAAALgAECgYJBgAAAA==.',
['孙六']='孙六空:BAAALgAECgYJCwAAAA==.',
['孙悟']='孙悟杰:BAAALgAECgEJAQAAAA==.',
['孟加']='孟加拉豹猫:BAAALgAECgUJBQAAAA==.',
['孤独']='孤独时代的梦:BAAALgAECgkJDwAAAA==.孤独星巴克:BAABLgAFFH8GAAIOAAIJVBpwBwC5AAAOAAIJVBpwBwC5AAAAAA==.',
['安丝']='安丝尔:BAAALgAECgMJBQAAAA==.',
['安尔']='安尔乐:BAAALgAECgYJBgAAAA==.',
['安澜']='安澜:BAACLgAFFH8PAAMdAAUJyiCsAgCFAQAdAAUJKAysAgCFAQAQAAQJyiB8BQB9AQAuAAQKfxsABB0ACAmeIBASAGYCAB0ACAlbHhASAGYCABAACAlOGkAYAEICAB4ABAl0F982ABQBAAAA.',
['安静']='安静回忆:BAAALgAECgEJAQAAAA==.',
['官人']='官人丨哈酒:BAABLgAFFH8FAAIeAAMJZRx+CwDuAAAeAAMJZRx+CwDuAAAAAA==.',
['宜宁']='宜宁:BAAALgAECgUJBgABLgAFFAEJAgAHAAAAAA==.',
['害羞']='害羞七:BAAALgAECgYJCwAAAA==.',
['家养']='家养大怪兽:BAAALgADCgIJAgAAAA==.',
['家庭']='家庭帝位的我:BAAALgAFFAIJAgAAAA==.',
['寂寞']='寂寞萌痕:BAABLgAECn8XAAIcAAcJfhV9NACyAQAcAAcJfhV9NACyAQAAAA==.',
['寂烬']='寂烬:BAAALgAECgMJAwAAAA==.',
['寒凌']='寒凌夜月:BAAALgAECgQJBAAAAA==.',
['对乙']='对乙酰氨基酚:BAAALgADCgYJCAAAAA==.',
['小也']='小也静子:BAAALgAECgcJEwAAAA==.',
['小兔']='小兔警官:BAAALgAECgIJAgAAAA==.',
['小小']='小小糯米团:BAAALgAECgUJBQAAAA==.小小鱼啊:BAAALgADCgUJBQAAAA==.',
['小新']='小新星闪耀:BAAALgADCgcJBwAAAA==.',
['小星']='小星瞳来喽:BAAALgADCgEJAQAAAA==.',
['小桃']='小桃子:BAAALgAECgYJCwAAAA==.',
['小毛']='小毛秀才丶:BAAALgAECgIJAgAAAA==.',
['小胖']='小胖墩墩:BAAALgADCgUJBQAAAA==.',
['小赵']='小赵不吃蘑菇:BAAALgAECgQJBAAAAA==.',
['小钻']='小钻风:BAABLgAECn8dAAIfAAYJ6BNbHQBbAQAfAAYJ6BNbHQBbAQAAAA==.',
['小隔']='小隔离墩:BAAALgADCgYJBgAAAA==.',
['小雨']='小雨丝丝:BAAALgAECgUJCQAAAA==.小雨绵绵:BAAALgAECgQJBAAAAA==.',
['小馬']='小馬珍珠:BAAALgAECgEJAQAAAA==.',
['小龙']='小龙人丶:BAAALgAECgcJBwAAAA==.',
['少侠']='少侠丨且慢:BAAALgAECgUJBQAAAA==.',
['尽死']='尽死生之力:BAAALgAFFAQJBAAAAA==.',
['屡德']='屡德:BAACLgAFFH8NAAMFAAQJEyExAgCRAQAFAAQJEyExAgCRAQAUAAIJNxWVFACfAAAuAAQKfxgAAwUACQmtI5wBAIsDAAUACQmtI5wBAIsDABQABgnuF1krAKcBAAAA.',
['山有']='山有扶蘇:BAAALgAECgcJAQAAAA==.',
['山望']='山望:BAAALgAECggJCQAAAA==.',
['岭城']='岭城术汉:BAAALgADCgUJBQAAAA==.',
['左书']='左书:BAAALgAECgUJCQAAAA==.',
['左牵']='左牵黄右擎苍:BAAALgADCgQJBAAAAA==.',
['帝国']='帝国余晖:BAAALgAECgIJAgAAAA==.',
['干饭']='干饭的小灰灰:BAACLgAFFH8FAAIaAAMJGglmGQChAAAaAAMJGglmGQChAAAuAAQKfycAAxoACAm2GvEEACsCABoACAm2GvEEACsCABEAAQk/AQSbABUAAAAA.',
['幽寒']='幽寒小牧:BAAALgAECgUJBQAAAA==.',
['广钢']='广钢忍者龟:BAAALgADCgMJAwAAAA==.',
['庄方']='庄方宜:BAAALgAECgIJAgABLgAFFAQJBwAEAAUdAA==.',
['开智']='开智灵猪:BAAALgAECgQJBAAAAA==.',
['弑魂']='弑魂黑骑:BAAALgAECgYJDQAAAA==.',
['张喜']='张喜喜:BAAALgADCgUJBQAAAA==.',
['弹跳']='弹跳的元蟾:BAAALgAECgYJBgAAAA==.',
['当狗']='当狗也是学问:BAAALgAECgcJEAAAAA==.',
['往后']='往后余生:BAAALgAECggJCAAAAA==.',
['很丑']='很丑很温柔:BAAALgADCgUJAgAAAA==.',
['很好']='很好吃:BAAALgADCgQJAwAAAA==.',
['徐又']='徐又廷:BAAALgAFFAQJAgAAAA==.',
['徐诺']='徐诺诺:BAAALgAECgYJCwAAAA==.',
['御手']='御手洗裤衩:BAAALgAECgIJAQAAAA==.',
['微风']='微风不倦:BAAALgAECgcJAQAAAA==.',
['德得']='德得玛:BAAALgAECgUJBQABLgAECgcJCAAHAAAAAA==.',
['心理']='心理:BAACLgAFFH8HAAIIAAQJ4QxXHQBWAQAIAAQJ4QxXHQBWAQAuAAQKfykAAggACAlAJLQDAIkCAAgACAlAJLQDAIkCAAAA.',
['心生']='心生法生:BAABLgAFFH8JAAIIAAUJkBvACQDQAQAIAAUJkBvACQDQAQAAAA==.',
['忆挽']='忆挽清河梦:BAAALgAECgkJCQAAAA==.',
['快回']='快回家:BAAALgAECgcJDQAAAA==.',
['怒气']='怒气爆发:BAAALgADCggJEAAAAA==.',
['恩冲']='恩冲:BAAALgADCgEJAQAAAA==.',
['恩静']='恩静:BAAALgAECgYJDAAAAA==.',
['悠德']='悠德:BAAALgADCgEJAQAAAA==.',
['悠悠']='悠悠有雨:BAABLgAFFH8GAAMgAAQJ5QiiCAA6AQAgAAQJ5QiiCAA6AQATAAIJzQhEDwCEAAABLgAFFAUJBAAHAAAAAA==.',
['悠沁']='悠沁:BAAALgAECgUJCgAAAA==.',
['悲伤']='悲伤大鼻嘎:BAAALgAECgYJCwAAAA==.',
['悲酥']='悲酥清疯:BAAALgADCgEJAQABLgAFFAYJCgAcAHYKAA==.',
['惹得']='惹得就是妳:BAAALgAECgYJDgAAAA==.',
['愤怒']='愤怒的大锤:BAAALgAECgYJCgAAAA==.',
['愿圣']='愿圣光照死你:BAAALgAECgEJAQAAAA==.',
['慕銫']='慕銫:BAAALgAECgQJBwAAAA==.',
['我不']='我不会唱情歌:BAAALgAECgUJBQAAAA==.',
['我们']='我们都是演员:BAAALgAECgYJEAAAAA==.',
['我就']='我就是老周:BAAALgAECgMJAwAAAA==.',
['我是']='我是你的眼睛:BAAALgAECgYJCwAAAA==.我是武森:BAABLgAFFH8KAAIQAAQJEha9CQA8AQAQAAQJEha9CQA8AQAAAA==.',
['我有']='我有抑郁症:BAABLgAFFH8FAAMGAAMJMBktMgDAAAAGAAIJmyAtMgDAAAAMAAIJFgr3DwBxAAAAAA==.',
['我的']='我的未来式:BAAALgAECgIJAgAAAA==.',
['战栗']='战栗的猛兽:BAAALgAECgYJCgAAAA==.',
['战神']='战神乌鸦:BAAALgAECgcJEgABLgAECgcJFgAGAMkbAA==.',
['户县']='户县软面:BAAALgAECgIJAgAAAA==.',
['手叁']='手叁:BAAALgADCgUJBQAAAA==.',
['扛不']='扛不住辣:BAAALgAFFAMJAwAAAA==.',
['执笔']='执笔丶话她:BAABLgAFFH8JAAMRAAQJyAyrFwDYAAARAAMJRwurFwDYAAAaAAIJhA1lGACmAAAAAA==.',
['扳手']='扳手老王:BAACLgAFFH8RAAIQAAUJIyWTAADBAQAQAAUJIyWTAADBAQAuAAQKfyMAAhAACAkMJOUGABgDABAACAkMJOUGABgDAAAA.',
['拉稀']='拉稀菜菜子:BAAALgAECgMJAwABLgAECgYJCAAHAAAAAA==.',
['拿着']='拿着板转:BAAALgAECgQJBAAAAA==.',
['挑灯']='挑灯问梦:BAAALgAECgYJCgAAAA==.',
['挽星']='挽星眠丶:BAAALgAECgEJAQAAAA==.',
['排骨']='排骨人:BAAALgAECgEJAQAAAA==.',
['摆烂']='摆烂大王:BAAALgAECgYJDAAAAA==.',
['摩缑']='摩缑:BAAALgAECgYJDwAAAA==.',
['摩西']='摩西摩西:BAAALgADCgMJAwAAAA==.',
['摸鱼']='摸鱼小熊喵:BAAALgAECgEJAQAAAA==.',
['方宝']='方宝盾:BAAALgAECggJCAAAAA==.',
['无常']='无常索命:BAAALgADCgUJBwAAAA==.',
['无情']='无情月:BAAALgADCgEJAQAAAA==.',
['无敌']='无敌华哥:BAAALgAECgYJCgAAAA==.',
['无毁']='无毁之刃:BAAALgAECgcJBwAAAA==.无毁之矢:BAAALgAECgkJEAAAAA==.无毁之辉:BAAALgAECgcJBwAAAA==.',
['无赖']='无赖佬:BAAALgADCgEJAQAAAA==.',
['无邪']='无邪:BAAALgAFFAEJAQAAAA==.',
['既明']='既明:BAAALgADCgMJAwAAAA==.',
['旧约']='旧约:BAAALgADCgUJBQAAAA==.',
['时光']='时光之之:BAAALgAECgUJBQAAAA==.',
['旺旺']='旺旺屁:BAACLgAFFH8OAAIKAAQJBybRAACpAQAKAAQJBybRAACpAQAuAAQKfxcAAwoABglSI1g9AC8CAAoABglSI1g9AC8CAAkAAQlmAO+kAA4AAAAA.',
['明丿']='明丿非:BAAALgAECgMJBQAAAA==.',
['易丶']='易丶碎:BAAALgAECgYJCgAAAA==.',
['易碎']='易碎丶:BAAALgAECgYJBgAAAA==.',
['星海']='星海冰乡:BAAALgAECgYJCgAAAA==.',
['星灵']='星灵血蕴:BAAALgAECgMJBQAAAA==.',
['春宵']='春宵:BAAALgAECggJDQAAAA==.',
['春末']='春末雨谷:BAAALgAFFAEJAQABLgAFFAUJEwAFAN0YAA==.',
['昨夜']='昨夜风:BAAALgAECgYJBgAAAA==.',
['是不']='是不是耳朵龙:BAAALgAECgcJBwAAAA==.',
['晨曦']='晨曦残颜:BAAALgAECgEJAQAAAA==.',
['暗影']='暗影卫队:BAAALgAECgUJBgAAAA==.',
['暮色']='暮色回响:BAAALgAECggJCAAAAA==.',
['暴力']='暴力小五熊:BAAALgAECgEJAgAAAA==.',
['暴富']='暴富灬鬼才:BAAALgAECgkJEAAAAA==.',
['暴怒']='暴怒小哼哼:BAAALgAECgYJCAAAAA==.',
['曙光']='曙光女神:BAACLgAFFH8HAAIKAAQJ0hASDABLAQAKAAQJ0hASDABLAQAuAAQKfygAAgoACAkNIxsNACUDAAoACAkNIxsNACUDAAAA.',
['月下']='月下听枫:BAAALgAECgkJEgAAAA==.月下弥音:BAAALgADCgEJAQAAAA==.',
['月光']='月光灼瞎了眼:BAAALgADCgEJAQAAAA==.',
['月冷']='月冷千山:BAAALgAECgQJBAAAAA==.',
['月夜']='月夜丶漂漂:BAAALgAECgUJBgAAAA==.',
['月映']='月映殘雪:BAAALgADCgEJAQABLgAFFAcJDQAfAM4ZAA==.',
['有栖']='有栖丶花绯:BAAALgAECgYJEgAAAA==.',
['朗基']='朗基奴斯:BAAALgAECgEJAQAAAA==.',
['望春']='望春风:BAACLgAFFH8HAAMeAAQJrhjwBgBTAQAeAAQJrhjwBgBTAQAQAAEJ0ApuJwA7AAAuAAQKfx0ABB4ACAnhG5gMAIsCAB4ACAnhG5gMAIsCABAABwkWHMkkANwBAB0AAgkCG9BaAKQAAAAA.',
['朝天']='朝天锅:BAAALgAFFAQJBAAAAA==.',
['李子']='李子维:BAAALgAECgYJDAABLgAFFAcJBgAEADUaAA==.',
['杠开']='杠开:BAACLgAFFH8IAAINAAMJ0xnoGgD6AAANAAMJ0xnoGgD6AAAuAAQKfxQAAg0ABwlOGnxCAOoBAA0ABwlOGnxCAOoBAAAA.',
['杨如']='杨如画:BAAALgAECgEJAwAAAA==.',
['松之']='松之乔:BAAALgAECgIJBAAAAA==.',
['松松']='松松丶:BAAALgAECgUJBQAAAA==.',
['板子']='板子丶:BAAALgADCgUJBQAAAA==.',
['极焰']='极焰:BAAALgAFFAIJAwAAAA==.',
['极美']='极美:BAAALgAFFAIJAgAAAA==.',
['构造']='构造小德:BAAALgADCgUJBQAAAA==.构造阿牧牧:BAAALgADCgUJBQAAAA==.',
['枕边']='枕边童话:BAAALgAECgYJBgAAAA==.',
['林深']='林深时见鹿:BAAALgADCgUJBQAAAA==.',
['枝江']='枝江聪明二宝:BAAALgAECgcJCQAAAA==.',
['枫吹']='枫吹一夏:BAAALgAECgEJAQAAAA==.',
['枫陵']='枫陵渡:BAAALgADCgcJBAAAAA==.',
['柠檬']='柠檬今天酸辣:BAABLgAFFH8LAAIEAAQJXyRgBQCrAQAEAAQJXyRgBQCrAQAAAA==.柠檬鲨:BAAALgAECgMJAwAAAA==.',
['核谐']='核谐圣佑:BAAALgAECgEJAQAAAA==.核谐打击:BAAALgAECgcJDAAAAA==.',
['桥本']='桥本奈奈未:BAAALgAFFAIJAwAAAA==.',
['梦回']='梦回宇轩:BAAALgAECgYJCwAAAA==.',
['梦娜']='梦娜丽沙:BAAALgADCgcJBwAAAA==.梦娜丽紗:BAAALgAECgEJAQAAAA==.',
['梦若']='梦若丶风:BAAALgAFFAEJAQAAAA==.',
['槟榔']='槟榔:BAAALgADCgEJAQAAAA==.',
['橘子']='橘子味橘子:BAAALgAECgIJAgAAAA==.',
['欣染']='欣染:BAAALgAECgcJDgAAAA==.',
['欧拉']='欧拉欧拉丶:BAAALgAECgIJAgAAAA==.',
['欧阳']='欧阳一克:BAAALgAECgYJCQAAAA==.',
['步丶']='步丶惊云:BAAALgAECgYJBgABLgAFFAQJBgAQAFUbAA==.',
['步步']='步步轻单:BAAALgAECgIJAgAAAA==.',
['死掉']='死掉的木头:BAAALgAECgYJAgAAAA==.',
['死灵']='死灵战:BAAALgAECgMJAwAAAA==.',
['死翘']='死翘翘:BAAALgAFFAEJAQAAAA==.',
['残星']='残星丶:BAAALgAFFAEJAgAAAA==.',
['殘月']='殘月狼:BAAALgAECgkJAwAAAA==.',
['比巴']='比巴卜:BAAALgAECgIJBAAAAA==.',
['比莫']='比莫大人:BAAALgAECgYJDAAAAA==.',
['毛企']='毛企鹅:BAAALgAECgkJEAAAAA==.',
['毛毛']='毛毛种子:BAAALgAECgUJCQAAAA==.',
['毛琉']='毛琉:BAAALgADCgcJDQAAAA==.',
['氨溴']='氨溴索盐酸盐:BAAALgADCgYJCAAAAA==.',
['水萨']='水萨:BAAALgAECgMJAwAAAA==.',
['永丶']='永丶久:BAAALgADCgIJAgAAAA==.',
['永恒']='永恒灬:BAAALgAECgIJBgAAAA==.',
['沁星']='沁星丶:BAAALgADCgEJAQAAAA==.',
['沅仔']='沅仔仔:BAAALgAECgUJBQAAAA==.',
['没刺']='没刺小酥鱼:BAAALgAFFAIJBAAAAA==.',
['沫理']='沫理酱:BAABLgAFFH8FAAIFAAIJFBjRFgCqAAAFAAIJFBjRFgCqAAAAAA==.',
['河丶']='河丶上:BAAALgAECgQJBAAAAA==.',
['河马']='河马:BAAALgAECgUJBQAAAA==.',
['法无']='法无定法:BAAALgAECgYJCwAAAA==.',
['泠泠']='泠泠:BAAALgAECgIJAgAAAA==.',
['泰瑞']='泰瑞米尔:BAAALgAECgkJCQAAAA==.',
['泼墨']='泼墨台风天:BAAALgAECgMJAwAAAA==.',
['洋芋']='洋芋粑:BAABLgAECn8cAAMcAAgJlhcjBQAUAgAcAAgJlhcjBQAUAgABAAYJdAr1SwAYAQAAAA==.',
['浅妆']='浅妆薄黛:BAAALgAECgIJAQAAAA==.',
['浩瀚']='浩瀚丶星辰:BAAALgAECgEJAQAAAA==.',
['海璐']='海璐璐:BAAALgADCgEJAQAAAA==.',
['海的']='海的那边有璐:BAAALgADCgMJAwAAAA==.',
['海飞']='海飞:BAAALgAECgQJBQAAAA==.',
['淘淘']='淘淘坏:BAAALgAECgEJAQAAAA==.',
['深沉']='深沉的乌萨奇:BAAALgADCgYJBgAAAA==.',
['深海']='深海没狮子:BAAALgAECgYJCQAAAA==.',
['清也']='清也:BAAALgAECgUJBQAAAA==.',
['清风']='清风紫月:BAAALgAECgQJAgAAAA==.',
['游侠']='游侠与独角兽:BAABLgAECn8UAAIGAAkJ4BeYMAB1AgAGAAkJ4BeYMAB1AgAAAA==.',
['溦沫']='溦沫:BAAALgAECgQJBAAAAA==.',
['溪云']='溪云:BAAALgAECgUJBQAAAA==.',
['滚滚']='滚滚最可爱:BAAALgAECggJCAAAAA==.滚滚红尘:BAAALgAECgYJBwAAAA==.',
['漓江']='漓江:BAAALgADCgEJAQAAAA==.',
['漫游']='漫游者:BAAALgAECgEJAQAAAA==.',
['潸潸']='潸潸:BAABLgAECn8UAAIQAAcJYR9UGABCAgAQAAcJYR9UGABCAgAAAA==.',
['火样']='火样女:BAAALgAECgYJBgAAAA==.',
['灬云']='灬云殇灬:BAAALgAECgcJBwAAAA==.',
['灬神']='灬神棍骑:BAAALgAECgEJAQAAAA==.',
['灬锦']='灬锦瑟:BAAALgADCgMJAwAAAA==.',
['灬露']='灬露米娜丝灬:BAAALgAECgcJBwAAAA==.',
['灭绝']='灭绝武僧:BAAALgAECgIJAgAAAA==.',
['灰夫']='灰夫人格雷:BAAALgAECgcJBwAAAA==.',
['灰尘']='灰尘:BAAALgAECgIJAgAAAA==.',
['灵之']='灵之舞:BAAALgAECgQJBwAAAA==.',
['灵羿']='灵羿:BAAALgADCgEJAQAAAA==.',
['炎之']='炎之十月:BAACLgAFFH8HAAISAAMJWRNdIQD+AAASAAMJWRNdIQD+AAAuAAQKfx4AAhIABwlNHABAAA4CABIABwlNHABAAA4CAAAA.',
['炙热']='炙热:BAAALgAECgYJEAAAAA==.',
['炽焰']='炽焰唤魔师:BAABLgAFFH8HAAMEAAQJiAj7FADGAAAEAAQJiAj7FADGAAACAAEJYgCZGAA9AAAAAA==.',
['热望']='热望婆婆:BAAALgADCgcJBwAAAA==.',
['热爱']='热爱学习:BAAALgAFFAEJAgAAAA==.',
['焰火']='焰火青年:BAAALgAECgEJAQAAAA==.',
['熊保']='熊保国:BAABLgAFFH8LAAIQAAQJkQrwDgAMAQAQAAQJkQrwDgAMAQAAAA==.',
['爱力']='爱力丝:BAABLgAECn8WAAIGAAcJyRsWPABHAgAGAAcJyRsWPABHAgAAAA==.',
['爱念']='爱念:BAAALgADCgEJAQABLgAECgYJDQAHAAAAAA==.',
['爱蜜']='爱蜜莉雅碳碳:BAAALgAECgUJBwAAAA==.',
['牧濑']='牧濑红莉栖:BAAALgAECgEJAQAAAA==.',
['牧牧']='牧牧拉牧拉:BAAALgAECgYJDgAAAA==.',
['狂暴']='狂暴的牛:BAAALgADCgUJBQAAAA==.',
['狂炫']='狂炫富婆画饼:BAAALgAFFAQJBAAAAA==.',
['狂龙']='狂龙小熊喵:BAAALgAECgUJBQAAAA==.',
['狄克']='狄克推多鷉:BAAALgAFFAEJAgAAAA==.',
['狐小']='狐小九:BAACLgAFFH8GAAIhAAQJcBqqBgB1AQAhAAQJcBqqBgB1AQAuAAQKfxgAAiEACAkwIpMAAAYDACEACAkwIpMAAAYDAAAA.',
['狐尾']='狐尾瓜:BAAALgAFFAEJAQAAAA==.',
['狐狸']='狐狸狸丶:BAAALgAECgYJDwAAAA==.狐狸麦麦:BAAALgAECgEJAQAAAA==.',
['狗二']='狗二丹丶彦祖:BAAALgAECgkJEQAAAA==.',
['狩月']='狩月:BAAALgADCgUJBQAAAA==.',
['猎人']='猎人丶:BAAALgAECgYJDgAAAA==.',
['猛灬']='猛灬男:BAAALgADCgEJAQAAAA==.',
['猛鬼']='猛鬼出笼:BAAALgAECgQJBQAAAA==.',
['猪一']='猪一把:BAAALgAECgEJAgAAAA==.',
['猫仙']='猫仙魔君:BAAALgAECgMJAwAAAA==.',
['猫猫']='猫猫的陈零:BAAALgAECgIJAgAAAA==.',
['玉瑾']='玉瑾瞳魂:BAAALgADCgIJAgABLgAECgEJAQAHAAAAAA==.',
['王健']='王健康:BAAALgAECgEJAQAAAA==.',
['玛修']='玛修:BAAALgAECgYJCwAAAA==.',
['珊蒂']='珊蒂斯羽月:BAAALgAFFAQJBAAAAA==.',
['班德']='班德拉:BAAALgAECggJDAAAAA==.',
['琳琅']='琳琅豆丁:BAAALgADCgcJAQAAAA==.',
['璐斯']='璐斯希尔:BAAALgAFFAQJBAAAAA==.',
['瓦王']='瓦王亲传弟子:BAAALgAECgYJBgABLgAECgcJFQACAHsSAA==.',
['瓶砸']='瓶砸瓶砸:BAABLgAECn8VAAMCAAcJexIjGwCwAQACAAcJexIjGwCwAQAEAAMJfgcaVAB1AAAAAA==.',
['男闺']='男闺蜜丶丶:BAAALgAECgIJAgAAAA==.',
['番茄']='番茄炒一个蛋:BAAALgAECgQJCgAAAA==.',
['疯不']='疯不动:BAAALgAECgYJBgAAAA==.',
['疯狂']='疯狂圣贤:BAAALgAECgEJAwAAAA==.',
['瘸腿']='瘸腿的人:BAAALgAECgYJCgAAAA==.',
['發氏']='發氏秀德:BAAALgAECgkJEAAAAA==.',
['白汁']='白汁:BAAALgAECgMJAwAAAA==.',
['白色']='白色风车丶:BAAALgAFFAIJAgAAAA==.',
['白马']='白马御东风丶:BAABLgAFFH8GAAIGAAIJlh+HMQDEAAAGAAIJlh+HMQDEAAAAAA==.',
['百川']='百川升:BAAALgAECgYJCgAAAA==.',
['益德']='益德:BAAALgADCgcJBwAAAA==.',
['相川']='相川步:BAAALgADCgIJAgAAAA==.',
['看我']='看我变个熊:BAAALgAECgYJDAAAAA==.',
['睇唔']='睇唔到咯:BAAALgAFFAEJAQAAAA==.',
['知趣']='知趣浅薄:BAAALgAECgMJAwAAAA==.',
['短发']='短发恩静:BAAALgAECgEJAgAAAA==.',
['破丶']='破丶浪:BAAALgAECgEJAQAAAA==.',
['砸小']='砸小兔:BAAALgAECgEJAQAAAA==.',
['社会']='社会啊:BAAALgAECgEJAQAAAA==.',
['神棍']='神棍大娘:BAAALgAECgcJDwAAAA==.',
['神民']='神民天下:BAAALgADCgYJBgAAAA==.',
['神经']='神经不正常:BAAALgAECgIJAgAAAA==.',
['神聖']='神聖骑士:BAAALgADCgEJAQAAAA==.',
['神风']='神风动:BAAALgADCgQJBAAAAA==.',
['秋水']='秋水云烟:BAAALgAECgQJBAAAAA==.',
['秦丨']='秦丨汉:BAAALgAECgEJAQAAAA==.',
['穿条']='穿条大蒜裤:BAAALgAECgIJAwAAAA==.穿条黑蒜裤:BAAALgAECgEJAwAAAA==.',
['竹笙']='竹笙芷郁:BAAALgAECgIJAgAAAA==.',
['米利']='米利暗:BAABLgAECn8aAAIKAAkJeSN6AgC0AwAKAAkJeSN6AgC0AwAAAA==.',
['米尔']='米尔豪斯冰法:BAAALgAECgQJBQAAAA==.',
['粉哥']='粉哥:BAAALgAECgYJCwAAAA==.',
['粪海']='粪海狅蛆:BAAALgAFFAIJAgAAAA==.',
['精灵']='精灵之光:BAAALgADCggJCAAAAA==.',
['糖心']='糖心薯片:BAAALgAECgEJAgAAAA==.',
['紫嫣']='紫嫣缥缈:BAAALgAFFAEJAgAAAA==.',
['紫宝']='紫宝宝:BAAALgAECgYJCgAAAA==.',
['紫色']='紫色的大拉锁:BAABLgAECn8XAAIIAAcJWRtEHABqAQAIAAcJWRtEHABqAQAAAA==.',
['红莓']='红莓十字军:BAAALgAECgQJBAAAAA==.',
['纯情']='纯情房东:BAAALgAECgYJBQAAAA==.',
['纸昕']='纸昕:BAACLgAFFH8RAAMGAAUJ7xlqEQBbAQAGAAQJKhlqEQBbAQAMAAUJCBD1BQA6AQAuAAQKfxkAAwYACAl/H+QyAGsCAAYACAl/H+QyAGsCAAwABgmcDlskAB4BAAAA.',
['组一']='组一辈子乐队:BAAALgAECgYJEQAAAA==.',
['结城']='结城昨日奈:BAACLgAFFH8IAAIJAAIJth8wEQDIAAAJAAIJth8wEQDIAAAuAAQKfx0ABAkACAmhGO4gABQCAAkACAmhGO4gABQCAAsABQnWGE4VAHsBAAoAAQnWHT0jAVcAAAEuAAUUAwkHABwA0xcA.',
['缇菈']='缇菈娜:BAAALgAFFAEJAgAAAA==.',
['罗兰']='罗兰紫衣:BAAALgADCgMJAwAAAA==.',
['罗琳']='罗琳汐薾:BAAALgAECgkJBwAAAA==.',
['群童']='群童欺我无力:BAAALgAFFAIJBAAAAA==.',
['翻书']='翻书人:BAAALgAFFAIJAwAAAA==.',
['翻滚']='翻滚的土豆子:BAAALgAFFAMJAwAAAA==.',
['翻转']='翻转:BAAALgADCgUJBQAAAA==.',
['老坛']='老坛风暴烈酒:BAAALgAECgEJAQAAAA==.',
['耐烧']='耐烧王梅琳娜:BAAALgAECgEJAQAAAA==.',
['聆晚']='聆晚音:BAAALgADCgcJBwAAAA==.',
['聲聲']='聲聲呀:BAAALgAECggJCQAAAA==.',
['肯德']='肯德坤爷爷:BAAALgAECgMJAwAAAA==.',
['背叛']='背叛的圣光:BAAALgAECgEJAQAAAA==.',
['胖头']='胖头鲨:BAAALgAECgMJAwAAAA==.',
['胡小']='胡小夹:BAAALgAECgYJEQAAAA==.胡小来:BAACLgAFFH8MAAIGAAQJ3CQGBQCxAQAGAAQJ3CQGBQCxAQAuAAQKfxcAAgYABgmiJZM5AFACAAYABgmiJZM5AFACAAAA.',
['胡萝']='胡萝卜丝:BAAALgAECgIJAgAAAA==.胡萝卜布丁:BAAALgAECgYJDgAAAA==.',
['脆脆']='脆脆鲨好好吃:BAAALgAECgUJBQAAAA==.',
['脑袋']='脑袋不发芽:BAAALgAECgEJAQAAAA==.',
['腰颜']='腰颜货重:BAAALgAFFAIJAgAAAA==.',
['臭蛋']='臭蛋鱿鱼:BAAALgADCgUJBQAAAA==.',
['臻德']='臻德很厉害:BAAALgAFFAEJAQAAAA==.',
['舒肤']='舒肤佳:BAAALgAECgIJAgAAAA==.',
['良时']='良时如飞鸟:BAAALgAFFAQJBAAAAA==.',
['艾比']='艾比利薯片:BAAALgAECgUJBwAAAA==.艾比娜丝:BAAALgADCgEJAQAAAA==.',
['艾琳']='艾琳埃德蒙:BAAALgAECgQJBgAAAA==.',
['艾瑞']='艾瑞丽娅:BAAALgAECgUJCQAAAA==.',
['艾里']='艾里奥斯大陆:BAAALgAFFAEJAgAAAA==.',
['艾黎']='艾黎溪鹿:BAAALgADCgYJBgAAAA==.',
['芙宁']='芙宁娜德枫丹:BAACLgAFFH8HAAIFAAIJdx/FFAC/AAAFAAIJdx/FFAC/AAAuAAQKfyMAAgUACAm9Ik8GACcDAAUACAm9Ik8GACcDAAAA.',
['花鳥']='花鳥風月:BAAALgADCgEJAgAAAA==.',
['茄汁']='茄汁大虾:BAAALgAECgMJAwAAAA==.',
['茉莉']='茉莉清:BAAALgAECgcJBwAAAA==.茉莉蜜:BAAALgAECgYJDAAAAA==.',
['草丛']='草丛啃饭团:BAAALgADCgcJBwAAAA==.',
['草料']='草料都指挥使:BAAALgADCgEJAQAAAA==.',
['荔小']='荔小知:BAAALgAECgYJCwABLgAECgcJFgAGAMkbAA==.',
['莓苷']='莓苷:BAAALgAFFAEJAQAAAA==.',
['菈缇']='菈缇娜:BAABLgAECn8UAAIOAAcJHBMIIQC1AQAOAAcJHBMIIQC1AQAAAA==.',
['菈雯']='菈雯妲:BAAALgADCgYJBgAAAA==.',
['菠萝']='菠萝可乐达:BAACLgAFFH8OAAIIAAQJ3xOhCQBTAQAIAAQJ3xOhCQBTAQAuAAQKfxcAAwgABgkJIDF0AOoBAAgABgkJIDF0AOoBACIAAwmrDEgKAKEAAAAA.',
['菲律']='菲律宾炸鱼队:BAAALgAFFAEJAQAAAA==.',
['萌新']='萌新玩部落:BAAALgAECgQJBAAAAA==.',
['萌达']='萌达乃:BAAALgAECgEJAQAAAA==.',
['萨古']='萨古拉斯余晖:BAACLgAFFH8FAAIIAAMJVBTQKQANAQAIAAMJVBTQKQANAQAuAAQKfx8AAggACAmcICooANICAAgACAmcICooANICAAAA.',
['萨馒']='萨馒:BAAALgAECgUJBQAAAA==.',
['落月']='落月:BAAALgAECgMJBwAAAA==.',
['葉师']='葉师傅:BAAALgAFFAIJAgAAAA==.',
['蒂利']='蒂利亚:BAAALgAECgQJBAAAAA==.',
['蒜鸟']='蒜鸟蒜鸟:BAAALgADCgQJBAAAAA==.',
['蓝梓']='蓝梓铭丶:BAACLgAFFH8KAAIQAAQJ7RIUDAAkAQAQAAQJ7RIUDAAkAQAuAAQKfyIAAxAACAnjGKATAHQCABAACAnjGKATAHQCAB0AAgl9BFxvAFQAAAAA.',
['蓝洛']='蓝洛:BAAALgADCgEJAQAAAA==.',
['蔡徐']='蔡徐咕:BAACLgAFFH8MAAIFAAQJ7SQrAwC2AQAFAAQJ7SQrAwC2AQAuAAQKfxoAAgUABwlRJCcLAOgCAAUABwlRJCcLAOgCAAAA.',
['蔷薇']='蔷薇朵朵开:BAAALgAECgkJBgAAAA==.',
['薇薇']='薇薇酱一号:BAABLgAFFH8HAAIKAAMJQwzPCgDwAAAKAAMJQwzPCgDwAAAAAA==.',
['薯球']='薯球:BAAALgAECgMJAwAAAA==.',
['藏不']='藏不住的深情:BAAALgAECgEJAQAAAA==.',
['虎贲']='虎贲凤仪:BAAALgADCgEJAQAAAA==.',
['虐心']='虐心丶:BAABLgAFFH8FAAINAAQJ8BSzDgBZAQANAAQJ8BSzDgBZAQAAAA==.',
['蚂蚁']='蚂蚁过家家:BAAALgAECgYJBgAAAA==.',
['蛟爷']='蛟爷爱吃鱼:BAAALgAECgEJAgAAAA==.',
['蛮力']='蛮力之警铃:BAAALgAECgEJAQAAAA==.',
['蟪蛄']='蟪蛄不知春秋:BAAALgADCgYJBgAAAA==.',
['血乄']='血乄小贱:BAAALgAECgMJBAAAAA==.',
['血月']='血月狼嚎:BAABLgAECn8pAAIjAAgJVBxHAABLAgAjAAgJVBxHAABLAgABLgAECgkJAwAHAAAAAA==.',
['表情']='表情包阿里嘎:BAAALgAECgYJBgAAAA==.',
['裂魂']='裂魂圣天:BAAALgADCgkJEAABLgAECgcJBwAHAAAAAA==.',
['观天']='观天:BAAALgAECgYJBgABLgAECgcJBgAHAAAAAA==.',
['觅法']='觅法丶:BAAALgAECgYJCgAAAA==.',
['諦麯']='諦麯:BAAALgAFFAEJAgAAAA==.',
['认真']='认真脸:BAAALgAECgYJBgAAAA==.',
['论奶']='论奶娘关系:BAAALgAFFAIJBAAAAA==.',
['诡笑']='诡笑黑夜:BAAALgADCgUJBQAAAA==.',
['诺撒']='诺撒尔:BAAALgAECgYJBgAAAA==.',
['贝贝']='贝贝之星:BAAALgAECgUJCwAAAA==.',
['赤炎']='赤炎之语:BAABLgAECn8ZAAMgAAgJ0BMDKQCSAQAgAAYJ4hQDKQCSAQATAAYJYglDRwAcAQAAAA==.',
['赤赤']='赤赤是大腕:BAAALgAECgcJDQAAAA==.',
['超级']='超级旺旺:BAACLgAFFH8OAAIEAAQJ7ReWBABJAQAEAAQJ7ReWBABJAQAuAAQKfxcAAgQABgm+FwwlAJQBAAQABgm+FwwlAJQBAAAA.',
['跨越']='跨越隐隐蓝海:BAAALgAFFAEJAQAAAA==.',
['踏月']='踏月而来:BAAALgAECgEJAQAAAA==.',
['踏风']='踏风凌云:BAAALgAECgEJAQAAAA==.',
['蹄狐']='蹄狐灌顶:BAAALgADCgIJAQAAAA==.',
['转一']='转一圈:BAAALgAECgEJAQAAAA==.',
['转么']='转么么:BAAALgAECgYJBwAAAA==.',
['辰泽']='辰泽:BAACLgAFFH8JAAMEAAMJ1RI8EQD3AAAEAAMJ1RI8EQD3AAACAAIJaRcAAAAAAAAuAAQKfygAAwIACAlrIYEEAAoDAAIACAlrIYEEAAoDAAQABwk8IIMCAB4CAAAA.',
['辰灬']='辰灬小柒:BAAALgAECgYJBgAAAA==.',
['远如']='远如晚星:BAAALgAFFAEJAgAAAA==.',
['远山']='远山青黛色:BAAALgAECgcJDQABLgAFFAUJDwAdAMogAA==.',
['远程']='远程远离:BAAALgAECgcJBwAAAA==.',
['迪菲']='迪菲亚吡吡:BAAALgADCgcJDgABLgAECgcJCAAHAAAAAA==.迪菲亚悟道者:BAAALgAECgUJBQABLgAECgcJCAAHAAAAAA==.迪菲亚驯龙者:BAAALgAECgcJCAAAAA==.',
['迷路']='迷路的宝塔兽:BAAALgADCgEJAQAAAA==.',
['追光']='追光者:BAAALgAECgIJAgAAAA==.',
['逍遥']='逍遥忘忧:BAAALgAECgEJAQAAAA==.逍遥无忧:BAAALgAFFAQJBAAAAA==.',
['透心']='透心凉:BAAALgAECgYJCwAAAA==.',
['逐雾']='逐雾:BAABLgAFFH8FAAMFAAMJ/BIdGQCZAAAFAAIJIxMdGQCZAAAVAAEJ7gFRBgBPAAABLgAFFAYJEgAFAOsZAA==.',
['逐露']='逐露:BAACLgAFFH8SAAIFAAYJ6xnAAQD0AQAFAAYJ6xnAAQD0AQAuAAQKfx0AAwUACQnkIV4GACYDAAUACQnkIV4GACYDABUAAQknIh4LAGYAAAAA.',
['道阴']='道阴寺:BAAALgAECgEJAQAAAA==.',
['遗忘']='遗忘如冰山:BAAALgAECgYJDwAAAA==.',
['那一']='那一晚的床单:BAAALgADCgYJBgAAAA==.',
['那个']='那个戦士:BAAALgAECgYJBgAAAA==.',
['那你']='那你佷胖胖喔:BAAALgAECgkJEgABLgAFFAcJEgAhAEEVAA==.那你很胖胖噢:BAAALgAECgQJCAAAAA==.',
['邪恶']='邪恶大毛王:BAAALgAECgEJAQAAAA==.邪恶小龙人:BAACLgAFFH8OAAMTAAQJFgR8AwDvAAAhAAQJDgNtDAAOAQATAAQJsQN8AwDvAAAuAAQKfxcAAxMABgmGCXtKAA4BABMABgnCB3tKAA4BACEABAnjB4FAAKwAAAAA.',
['酒馆']='酒馆老板惟基:BAAALgAECgQJBAAAAA==.',
['酸涩']='酸涩的橘子:BAAALgADCgYJAQAAAA==.',
['野蛮']='野蛮冲锋:BAAALgAECgYJCQAAAA==.',
['铁卫']='铁卫:BAAALgAECgQJBAAAAA==.',
['银沙']='银沙王:BAAALgAECgcJDwAAAA==.',
['長期']='長期術士:BAAALgAECgUJBQAAAA==.',
['门徒']='门徒:BAAALgAECgEJAQAAAA==.',
['闪光']='闪光的猪:BAAALgAECgkJDQAAAA==.',
['闷墩']='闷墩墩:BAAALgAECgYJCAAAAA==.',
['阴阳']='阴阳道:BAAALgAECgYJBgAAAA==.',
['阿凡']='阿凡猎:BAAALgAECgYJDAAAAA==.',
['阿咩']='阿咩狸:BAAALgAECgcJCAAAAA==.',
['阿尔']='阿尔卡:BAAALgAECgMJAwAAAA==.',
['阿巴']='阿巴克:BAAALgAECgUJBQAAAA==.',
['阿柒']='阿柒丶:BAAALgADCgcJDgABLgAECgYJCAAHAAAAAA==.',
['陈丶']='陈丶凤暴烈酒:BAAALgAECgEJAQAAAA==.',
['陈大']='陈大头儿:BAAALgAECgMJAwABLgAECgUJBQAHAAAAAA==.',
['陈氏']='陈氏太极:BAAALgAECgkJEAAAAA==.',
['随风']='随风飞扬:BAAALgAFFAIJAgAAAA==.',
['雇佣']='雇佣兵小法:BAAALgAECgYJBAAAAA==.雇佣兵老大:BAAALgAECgMJAwAAAA==.',
['雨慕']='雨慕冰:BAAALgADCgIJAgAAAA==.',
['雨落']='雨落花笙:BAAALgAFFAIJAwAAAA==.',
['雲夢']='雲夢:BAAALgADCgEJAQAAAA==.',
['零星']='零星一点:BAAALgAECgUJCQAAAA==.',
['零落']='零落花飘香:BAAALgAECgEJAQAAAA==.',
['零食']='零食大盗:BAAALgAFFAEJAQAAAA==.',
['霍格']='霍格来我身边:BAAALgAECgcJEQAAAA==.',
['霍肯']='霍肯伯格:BAAALgAECgYJCwAAAA==.',
['霞宝']='霞宝:BAAALgADCgEJAQAAAA==.',
['露露']='露露的小肥咕:BAAALgAECgcJBwAAAA==.露露的魔术师:BAAALgAECgYJBgAAAA==.',
['青丘']='青丘山白狐狸:BAAALgAFFAEJAQAAAA==.',
['青之']='青之幻想:BAAALgAFFAEJAQAAAA==.',
['青山']='青山有思:BAAALgAECgcJBgAAAA==.',
['青淤']='青淤:BAAALgAECgUJBgAAAA==.',
['青澈']='青澈:BAAALgAFFAIJAgAAAA==.',
['青神']='青神之梦:BAAALgAECgEJAgABLgAFFAEJAQAHAAAAAA==.',
['静艳']='静艳:BAAALgAECgEJAQAAAA==.',
['顺畅']='顺畅呼吸:BAACLgAFFH8GAAIIAAQJoA3ZHQBTAQAIAAQJoA3ZHQBTAQAuAAQKfyAAAggACAkRH0UHADYCAAgACAkRH0UHADYCAAAA.',
['顺直']='顺直:BAAALgAECgUJBgAAAA==.',
['颓废']='颓废者的春天:BAAALgADCgEJAgAAAA==.',
['额滴']='额滴圣剑:BAAALgAECgcJDQABLgAECgkJDgAHAAAAAA==.',
['颠脚']='颠脚僧:BAAALgAECgYJCQAAAA==.',
['风凝']='风凝:BAAALgAECgYJBwAAAA==.',
['风尘']='风尘女:BAAALgAECgQJBQAAAA==.',
['风度']='风度翩翩的哥:BAAALgADCgEJAQAAAA==.',
['风样']='风样男:BAAALgAECgcJCwAAAA==.',
['风正']='风正帆悬:BAAALgADCgEJAwAAAA==.',
['风灵']='风灵霜雨:BAAALgAECgYJCgAAAA==.',
['飘飘']='飘飘然:BAAALgAECgQJBQAAAA==.',
['飞出']='飞出宇宙的熊:BAAALgADCgUJBQAAAA==.',
['饿了']='饿了嘛:BAAALgAECgEJAQAAAA==.',
['马丁']='马丁拉斯特:BAAALgAECgIJAgAAAA==.',
['骑术']='骑术精湛:BAAALgADCgYJBgAAAA==.',
['髓战']='髓战斗英雄:BAAALgAECgYJCAAAAA==.',
['高性']='高性能小狐狸:BAAALgAECgQJBAAAAA==.',
['魔法']='魔法小咪:BAAALgAECgQJBAAAAA==.',
['魔界']='魔界极度恶魔:BAAALgAECgQJBgAAAA==.',
['鱼火']='鱼火火:BAAALgAECgEJAQAAAA==.',
['鱼龙']='鱼龙之逢风雨:BAAALgAECgIJAgAAAA==.',
['鳯橆']='鳯橆丷緂:BAABLgAECn8aAAQaAAYJhxazPgC0AQAaAAYJhxazPgC0AQAbAAQJNAviJACiAAARAAEJWwGlmgAXAAAAAA==.',
['鹤顶']='鹤顶红三路奶:BAAALgAECgYJCAAAAA==.',
['麦琳']='麦琳恩丶袭月:BAAALgAECgEJAQAAAA==.',
['黎明']='黎明灬破晓:BAAALgAECgEJAQAAAA==.',
['黑丶']='黑丶章:BAAALgADCgIJAgAAAA==.',
['黑吗']='黑吗喽:BAAALgAECgYJDgAAAA==.',
['黑夜']='黑夜:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗女王:BAAALgADCgMJAwAAAA==.',
['黑白']='黑白道:BAAALgADCgYJBgAAAA==.',
['黑矮']='黑矮子:BAAALgAECgUJDwAAAA==.',
['黑色']='黑色山羊:BAAALgAFFAIJAwAAAA==.黑色的白:BAAALgAECgUJBQAAAA==.',
['黑铁']='黑铁大帝:BAABLgAFFH8IAAIMAAMJXBQxCgDgAAAMAAMJXBQxCgDgAAAAAA==.',
['黑风']='黑风萨:BAAALgADCgYJBgAAAA==.',
['龙城']='龙城乄九天:BAABLgAFFH8KAAIIAAQJrRMACQBYAQAIAAQJrRMACQBYAQABLgAFFAUJBgAIABoKAA==.',
['龙髓']='龙髓:BAAALgADCgYJBgAAAA==.',
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
