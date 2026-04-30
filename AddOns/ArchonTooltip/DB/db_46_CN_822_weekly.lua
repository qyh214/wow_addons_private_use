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

local lookup = {'Mage-Frost','Warrior-Fury','Druid-Feral','Rogue-Subtlety','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Priest-Holy','DemonHunter-Devourer','DemonHunter-Havoc','Shaman-Restoration','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Shaman-Elemental','Druid-Balance','Druid-Guardian','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Protection','DeathKnight-Unholy','Warrior-Arms','Paladin-Holy','Evoker-Augmentation','Paladin-Retribution','DeathKnight-Blood','Evoker-Preservation','Warlock-Demonology','DeathKnight-Frost','Warlock-Destruction','Warlock-Affliction','DemonHunter-Vengeance','Hunter-Survival','Druid-Restoration','Paladin-Protection',}
local provider = {region='CN',realm='血吼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abuseu:BAAALgAECgEJAQAAAA==.',
Al='Alonsus:BAAALgADCgIJAwABLgAECgYJFQABAF0gAA==.',
An='Anotherdáy:BAABLgAFFH8HAAICAAMJig03EwDpAAACAAMJig03EwDpAAAAAA==.',
Ap='Apate:BAAALgAECgEJAQAAAA==.',
Ar='Artemiar:BAAALgAECgEJAQAAAA==.',
Av='Avelily:BAAALgAFFAMJAwAAAA==.',
Ay='Ayuu:BAAALgAECgYJBwAAAA==.',
Ba='Batzz:BAAALgAECgYJBgAAAA==.',
Ce='Centre:BAAALgAECgcJBwAAAA==.',
Ch='Champaign:BAAALgAECgQJBAAAAA==.Chantal:BAAALgAECgIJAgAAAA==.Chua:BAAALgAECgcJDAAAAA==.',
Cl='Clearlove:BAAALgAECgkJAwAAAA==.',
Cr='Cruelsheep:BAAALgAECgcJBwAAAA==.',
De='De:BAACLgAFFH8GAAIDAAMJ1w53AgCvAAADAAMJ1w53AgCvAAAuAAQKfx8AAgMABwmcH1YHAHcCAAMABwmcH1YHAHcCAAAA.',
Dk='Dkbu:BAAALgAECgUJDAAAAA==.Dkyyds:BAAALgAECgIJAgAAAA==.',
El='Eliesmonk:BAAALgAECgYJDAABLgAECgcJHgAEAK4iAA==.',
Ex='Exyth:BAAALgAECgYJDwABLgAFFAEJAQAFAAAAAA==.',
Fa='Fallensadan:BAAALgAECgQJBAAAAA==.',
Fu='Fuflower:BAAALgAFFAEJAgAAAA==.',
Ga='Gandal:BAAALgAECgEJAQAAAA==.',
Ha='Hackerdie:BAAALgADCgMJAwAAAA==.Hayata:BAAALgADCgIJAgAAAA==.',
He='Heartbreaker:BAAALgAECgEJAgAAAA==.',
Hy='Hyacinemage:BAAALgAFFAEJAQAAAA==.',
In='Infinites:BAAALgAECgYJDwAAAA==.',
Ja='Jaylee:BAAALgAFFAEJAQAAAA==.',
Js='Jshaitian:BAAALgADCgEJAQAAAA==.',
Kh='Khunter:BAAALgAECgkJDwAAAA==.',
Lw='Lwjqw:BAAALgAECgYJBgAAAA==.',
Me='Merling:BAAALgAECgUJBQAAAA==.',
Mi='Milabo:BAAALgAECgUJBQAAAA==.Missy:BAAALgADCgEJAQAAAA==.',
Ne='Nemoy:BAAALgAFFAIJBAABLgAFFAIJBAAFAAAAAA==.Netureenvoy:BAAALgAECgEJAQAAAA==.',
Pe='Peanut:BAAALgAECgQJBAAAAA==.',
Qw='Qwlwj:BAAALgAECgcJCwAAAA==.',
Re='Redamancy:BAAALgAECgEJAQABLgAECgYJCwAFAAAAAA==.',
Sa='Samss:BAABLgAECn8dAAQGAAcJ2BXDIACNAQAGAAcJ7hDDIACNAQAHAAcJnQ7CLwBkAQAIAAUJ7xYvPQBFAQAAAA==.Sanmage:BAAALgAECgQJBAAAAA==.',
Sc='Scathacha:BAAALgAFFAEJAQAAAA==.',
Se='Severusx:BAACLgAFFH8FAAIJAAMJYAWIIADPAAAJAAMJYAWIIADPAAAuAAQKfxgAAwkABwmTFeNJAMwBAAkABwmTFeNJAMwBAAoABAkcEERJAM0AAAAA.',
Sh='Sherlok:BAAALgAECgcJAgAAAA==.',
So='Soulmatee:BAAALgAECgEJAgAAAA==.',
Th='Thesa:BAABLgAFFH8IAAILAAMJjhUZEADnAAALAAMJjhUZEADnAAAAAA==.Theuglyboy:BAAALgAFFAIJAgAAAA==.',
Tw='Twhy:BAAALgAECgEJAgABLgAECgMJAwAFAAAAAA==.Twhyws:BAAALgAECgMJAwAAAA==.',
Vz='Vzt:BAAALgADCgEJAQAAAA==.',
Wu='Wulieasy:BAAALgAFFAEJAQAAAA==.Wuliholy:BAAALgAECgEJAgAAAA==.',
Yo='Youba:BAAALgAECgEJAgAAAA==.Youja:BAAALgAECgEJAQAAAA==.Yourseven:BAAALgAECgcJBwAAAA==.Youzzidk:BAAALgAFFAEJAQAAAA==.',
Ze='Zethree:BAACLgAFFH8JAAMMAAQJqBPvCAAqAQAMAAQJqBPvCAAqAQANAAEJXghtJQBDAAAuAAQKfx4AAwwACAmZHu4DACsCAAwACAmZHu4DACsCAA4ABgmbDPI8ACcBAAAA.',
['一切']='一切随缘:BAAALgAECgYJBwAAAA==.',
['一小']='一小骑士:BAAALgAECgMJAwAAAA==.',
['一羽']='一羽霓裳乁:BAAALgAFFAQJBAAAAA==.',
['一骑']='一骑当仟:BAAALgAECgYJBgAAAA==.',
['七月']='七月吟术:BAAALgAFFAEJAQAAAA==.七月唐虞:BAACLgAFFH8KAAIPAAQJQBTzCQBDAQAPAAQJQBTzCQBDAQAuAAQKfx8AAw8ACQlRH7sLAN4CAA8ACAlZILsLAN4CAAsAAgmuFpOCAIkAAAEuAAUUBgkOABAA/w8A.',
['三儿']='三儿爸:BAAALgAECgcJAQAAAA==.',
['三十']='三十咕去埔里:BAAALgAFFAQJAgAAAA==.',
['三只']='三只咕滑滑梯:BAAALgAFFAUJAwAAAA==.',
['上古']='上古:BAABLgAECn8bAAMMAAgJshgYFAAqAgAMAAgJshgYFAAqAgAOAAIJwgT5LQAqAAAAAA==.',
['下课']='下课闹闹:BAAALgADCgcJBwAAAA==.',
['不知']='不知冬:BAAALgAECgEJAQAAAA==.不知秋:BAAALgAECgEJAgAAAA==.',
['专业']='专业吐痰:BAAALgAECgUJAgAAAA==.',
['东港']='东港上人:BAAALgAECgQJCQAAAA==.',
['丠狼']='丠狼天辰:BAAALgAECgEJAQAAAA==.',
['丨倾']='丨倾国倾橙丨:BAAALgAECgYJBwAAAA==.',
['丨刃']='丨刃舞:BAAALgAECgYJBgAAAA==.',
['丨华']='丨华茂春松丨:BAABLgAFFH8JAAILAAUJfgleBQB3AQALAAUJfgleBQB3AQAAAA==.',
['丨叮']='丨叮叮丨:BAAALgAECgYJBgAAAA==.',
['丨撒']='丨撒旦之手丨:BAAALgAECgEJAQAAAA==.',
['丨米']='丨米奈希尔:BAAALgAECgYJCwAAAA==.',
['丨荣']='丨荣曜秋菊丨:BAAALgAFFAQJBAAAAA==.',
['丨风']='丨风起:BAAALgADCgMJAwAAAA==.',
['丫头']='丫头不太乖:BAAALgADCgIJAgAAAA==.丫头乖乖:BAAALgAECgYJBwAAAA==.丫头吥萌:BAAALgADCgIJAgAAAA==.',
['丶儒']='丶儒雅随和:BAAALgAECgcJDgAAAA==.',
['丶口']='丶口吅品丶:BAAALgAECgYJBgAAAA==.',
['丶圣']='丶圣傲天:BAAALgAECgEJAgAAAA==.',
['丶时']='丶时迁:BAABLgAFFH8PAAIBAAQJMCKbBQCAAQABAAQJMCKbBQCAAQAAAA==.',
['丶术']='丶术傲天:BAAALgAECgEJAQAAAA==.',
['丶樱']='丶樱井智树:BAAALgAECgYJCwAAAA==.',
['丶死']='丶死神的尊严:BAAALgAECgYJCAAAAA==.',
['丶殘']='丶殘轌:BAAALgAFFAEJAgAAAA==.',
['丶洒']='丶洒家:BAAALgAECgEJAQAAAA==.',
['丶灰']='丶灰色:BAAALgAECgYJEAAAAA==.',
['丶点']='丶点如人心:BAAALgAECgcJCAAAAA==.',
['丶熊']='丶熊躯一震:BAAALgAECgEJAQAAAA==.',
['丶老']='丶老牛丶:BAAALgAECgIJAgAAAA==.',
['丶蝴']='丶蝴蝶:BAAALgAFFAQJBAAAAA==.',
['丶道']='丶道法自燃:BAAALgAECgEJAgAAAA==.',
['丶骨']='丶骨傲天:BAAALgAECgEJAQAAAA==.',
['丶麦']='丶麦旋旋风:BAAALgAECgMJAwAAAA==.',
['为自']='为自己带盐:BAAALgADCgYJBgAAAA==.',
['乌兰']='乌兰巴托的夜:BAAALgAECgIJAwAAAA==.',
['九个']='九个菜包:BAAALgAECgIJAgAAAA==.',
['九六']='九六叁:BAAALgAECgcJBwAAAA==.',
['九诫']='九诫:BAAALgAECgEJAQAAAA==.',
['乱舞']='乱舞春秋:BAAALgADCgEJAQAAAA==.',
['亂丗']='亂丗乂胧:BAAALgAECgIJAgAAAA==.亂丗乂荭諵亰:BAAALgADCgEJAQAAAA==.',
['二七']='二七咕去板桥:BAAALgAFFAUJBAAAAA==.',
['二五']='二五咕去府城:BAABLgAFFH8GAAIQAAQJmhnCBwBkAQAQAAQJmhnCBwBkAQAAAA==.',
['二六']='二六咕去虎尾:BAABLgAFFH8OAAMQAAYJhhi7AgDRAQAQAAUJRh67AgDRAQARAAEJiAFZBgBHAAAAAA==.',
['云天']='云天巧:BAAALgAECgEJAQAAAA==.',
['五花']='五花牛牛:BAAALgAECgQJBQAAAA==.',
['亲丶']='亲丶按摩不:BAAALgAECgEJAQAAAA==.',
['人狠']='人狠话不多:BAAALgADCgUJCAAAAA==.',
['人间']='人间正道:BAAALgADCgYJBgAAAA==.',
['亻尔']='亻尔爷爷:BAAALgAECgkJBwAAAA==.',
['从小']='从小爱撒娇:BAAALgADCgIJAgAAAA==.',
['代达']='代达罗斯丶:BAACLgAFFH8RAAMSAAYJehgvAgBzAQATAAUJPBIGBgDCAQASAAUJ7RYvAgBzAQAuAAQKfxUAAxMACQneHH0NANcCABMACQmuHH0NANcCABIAAgkUIf2WAKgAAAAA.',
['以德']='以德服德:BAAALgADCgEJAQAAAA==.',
['伊伊']='伊伊:BAAALgADCgUJEAAAAA==.',
['伊利']='伊利没有丹:BAAALgADCgUJBQAAAA==.伊利达雷之眼:BAAALgAECgQJBgAAAA==.',
['伐不']='伐不知道:BAAALgAECgYJCQAAAA==.',
['众神']='众神之诗:BAAALgAECgYJDQAAAA==.',
['伱的']='伱的丨益达:BAAALgAECgUJCgAAAA==.',
['低保']='低保丶:BAAALgAECgMJAwAAAA==.',
['何必']='何必愁眉苦脸:BAABLgAFFH8HAAIUAAUJ7Q8LAwBrAQAUAAUJ7Q8LAwBrAQAAAA==.',
['何肥']='何肥肥:BAAALgADCgQJBAAAAA==.',
['你就']='你就不会:BAABLgAFFH8FAAIBAAIJEx8xNQDCAAABAAIJEx8xNQDCAAAAAA==.',
['你干']='你干嘛:BAAALgAECgcJDAAAAA==.',
['你懂']='你懂数值吗:BAAALgADCgYJBgAAAA==.',
['你打']='你打何处来:BAAALgAECgEJAQAAAA==.',
['你说']='你说人走茶凉:BAAALgAECgYJCAAAAA==.你说物是人非:BAAALgADCgQJBAAAAA==.',
['你过']='你过关:BAACLgAFFH8KAAIVAAQJWxHZGABCAQAVAAQJWxHZGABCAQAuAAQKfxsAAhUACAkEHY4nAJwCABUACAkEHY4nAJwCAAAA.',
['佩奇']='佩奇葩葩:BAAALgAECgYJCQAAAA==.',
['依利']='依利丹:BAAALgADCgMJAwAAAA==.',
['倾听']='倾听丶:BAAALgADCgIJAgAAAA==.倾听的晨雨:BAAALgAECgQJCAAAAA==.',
['假酒']='假酒小熊喵:BAAALgADCgcJBwABLgAFFAEJAgAFAAAAAA==.',
['傻馒']='傻馒的主人:BAACLgAFFH8MAAISAAQJixgTBABeAQASAAQJixgTBABeAQAuAAQKfyUAAhIACAkcJWEEAEkDABIACAkcJWEEAEkDAAAA.',
['元始']='元始天尊丶:BAAALgAECgEJAQAAAA==.',
['光明']='光明赞颂者:BAAALgAECgMJAwAAAA==.光明黄晓明:BAACLgAFFH8MAAIUAAQJWBhqBAA3AQAUAAQJWBhqBAA3AQAuAAQKfyoAAhQACAlLIN4EAPcCABQACAlLIN4EAPcCAAAA.',
['光铸']='光铸暗影:BAAALgAFFAEJAQAAAA==.',
['全城']='全城死爱:BAAALgAECgcJEAAAAA==.',
['养孩']='养孩子:BAAALgAECgIJAgAAAA==.',
['冥魂']='冥魂丶大帝:BAAALgADCgYJBgAAAA==.',
['冯唐']='冯唐易老:BAAALgAECgEJAQAAAA==.',
['冰火']='冰火奥的夜:BAAALgAECgEJAQAAAA==.',
['冰璃']='冰璃夜歌:BAAALgAECgIJAgAAAA==.',
['冰阔']='冰阔乐:BAAALgAECgEJAgAAAA==.',
['冲锋']='冲锋陷阵:BAABLgAFFH8HAAMWAAMJJQmnBADaAAAWAAMJ0AanBADaAAAUAAEJGQlyEABAAAAAAA==.冲锋风车释放:BAAALgAECgcJDQAAAA==.',
['冷丶']='冷丶丶:BAAALgAECgYJEwAAAA==.',
['冷双']='冷双眸:BAAALgAECgIJAgAAAA==.',
['冻阔']='冻阔乐:BAAALgADCgIJAgAAAA==.',
['准备']='准备跌得粉碎:BAABLgAFFH8FAAIDAAUJ3gT7AAAzAQADAAUJ3gT7AAAzAQAAAA==.',
['凉城']='凉城旧夢:BAAALgAECgEJAwAAAA==.',
['凛冬']='凛冬之吻:BAAALgAECgQJCwAAAA==.',
['凝煞']='凝煞:BAAALgAECgcJEgAAAA==.',
['凭栏']='凭栏千里:BAAALgAFFAIJAgAAAA==.凭栏夜雨:BAAALgAECgUJDgAAAA==.',
['刀落']='刀落枫叶飘:BAAALgAECgQJBQAAAA==.',
['北极']='北极熊的弟弟:BAAALgAECgYJBwAAAA==.',
['北风']='北风的月:BAAALgAECgUJBwAAAA==.',
['千珏']='千珏:BAAALgADCgIJAgAAAA==.',
['千里']='千里飞沙:BAAALgAECgQJCgAAAA==.',
['升竜']='升竜拳丶:BAAALgAFFAIJAgAAAA==.',
['华亭']='华亭鹤唳:BAAALgAECgIJAwAAAA==.',
['卡亚']='卡亚可乐:BAAALgAECgMJAwAAAA==.',
['卩認']='卩認心灬安靜:BAAALgAECgQJBQAAAA==.',
['原来']='原来是骑士啊:BAAALgAECgEJAgAAAA==.',
['又大']='又大又白:BAACLgAFFH8JAAIJAAQJOAScGQADAQAJAAQJOAScGQADAQAuAAQKfyMAAgkACAm/F3UpAFwCAAkACAm/F3UpAFwCAAAA.',
['只是']='只是拿锤子的:BAABLgAFFH8SAAIXAAUJZRbGAwCpAQAXAAUJZRbGAwCpAQAAAA==.',
['叫我']='叫我居总:BAABLgAFFH8GAAMSAAMJDA4YCwAAAQASAAMJDA4YCwAAAQATAAMJXgSiGADJAAAAAA==.叫我靓仔:BAAALgAFFAQJBAABLgAFFAcJBAAFAAAAAA==.',
['可以']='可以吸的果冻:BAABLgAECn8XAAIJAAcJeBZoRwDWAQAJAAcJeBZoRwDWAQABLgAECggJFQASAPIbAA==.',
['可爱']='可爱小豆沙:BAABLgAFFH8FAAISAAIJSCAAFACzAAASAAIJSCAAFACzAAAAAA==.可爱秋秋:BAAALgAECgYJBwABLgAFFAYJBAAFAAAAAA==.',
['吃我']='吃我一击吧:BAAALgADCgEJAQAAAA==.',
['吃番']='吃番茄的土豆:BAAALgAECgYJBgAAAA==.',
['吃货']='吃货殿下:BAAALgAECgEJAQAAAA==.',
['同载']='同载酒:BAAALgAFFAMJBAAAAA==.',
['吴山']='吴山烤鸡:BAAALgAECgcJDwAAAA==.',
['呔筱']='呔筱張:BAAALgAECgEJAQAAAA==.',
['呼啸']='呼啸而过:BAAALgADCgIJAgAAAA==.',
['咪咕']='咪咕小玉藻:BAAALgAECgMJAgAAAA==.',
['哆唻']='哆唻咪:BAAALgAECgQJBgAAAA==.',
['唐老']='唐老师圣:BAAALgAECgMJAwABLgAFFAEJAQAFAAAAAA==.唐老师灵:BAAALgAECgYJBgABLgAFFAEJAQAFAAAAAA==.唐老师魂:BAAALgAFFAEJAQAAAA==.',
['唔西']='唔西丶迪西:BAAALgAFFAEJAgABLgAFFAYJGAAYACkgAA==.',
['唤潮']='唤潮:BAACLgAFFH8MAAIGAAQJBxBeCgA5AQAGAAQJBxBeCgA5AQAuAAQKfxsAAwYACAlgFgkUAAwCAAYACAmcFQkUAAwCAAgABwlZDbw1AGYBAAAA.',
['喜提']='喜提我狗命:BAABLgAECn8VAAISAAgJ8hv8EgCfAgASAAgJ8hv8EgCfAgAAAA==.',
['嗳星']='嗳星星的小孩:BAAALgAFFAEJAwAAAA==.',
['嘟嘟']='嘟嘟魯:BAAALgAFFAEJAQAAAA==.',
['嘿吣']='嘿吣喵:BAABLgAFFH8GAAIZAAQJJxUICgBcAQAZAAQJJxUICgBcAQAAAA==.',
['四十']='四十米大砍刀:BAABLgAFFH8MAAMVAAYJWBmoAwDHAQAVAAUJWBmoAwDHAQAaAAEJAABVFQBFAAAAAA==.',
['圣型']='圣型尤物:BAACLgAFFH8MAAIZAAQJ5iAqBgCNAQAZAAQJ5iAqBgCNAQAuAAQKfyIAAhkACAmmIkQSAAADABkACAmmIkQSAAADAAAA.',
['地王']='地王:BAAALgAECgYJBgAAAA==.',
['城邦']='城邦总管:BAAALgAECgEJAQAAAA==.',
['基情']='基情丶萧磊:BAAALgAFFAIJBAAAAA==.',
['墓中']='墓中哥:BAAALgAECgYJEAAAAA==.',
['墨香']='墨香余音:BAAALgAECgQJBAAAAA==.',
['壮汉']='壮汉小天使:BAAALgAECgEJAgAAAA==.',
['复生']='复生出错了:BAAALgAECgcJDgAAAA==.',
['夏丨']='夏丨灰烬之手:BAAALgADCgUJBQAAAA==.',
['外的']='外的:BAAALgAECgQJCQAAAA==.',
['多多']='多多涞:BAAALgAECgYJCQAAAA==.',
['多拉']='多拉贡抛瓦:BAACLgAFFH8SAAIYAAUJoxCNBgCRAQAYAAUJoxCNBgCRAQAuAAQKfyQAAxgACQmGG6QIAO4CABgACQmGG6QIAO4CABsABwkqDeUgAHYBAAAA.',
['夜寂']='夜寂的旋律:BAAALgAFFAIJAwAAAA==.',
['夜幕']='夜幕玫瑰:BAAALgADCgYJBgAAAA==.',
['夜思']='夜思明:BAABLgAFFH8FAAIVAAMJyhwoDgAYAQAVAAMJyhwoDgAYAQAAAA==.',
['夜色']='夜色幕倾城:BAAALgAFFAIJAgAAAA==.',
['大丨']='大丨乔:BAAALgAFFAEJAQAAAA==.',
['大树']='大树丶:BAAALgAECgYJDgAAAA==.',
['大熊']='大熊包:BAAALgAECgYJBgAAAA==.',
['大獅']='大獅子丶:BAAALgAECgMJAwAAAA==.',
['大织']='大织梦师小满:BAAALgAECgUJCQAAAA==.',
['大角']='大角丶牛:BAAALgAECgYJDAAAAA==.',
['大锤']='大锤的叁号:BAAALgAECgYJCAAAAA==.',
['天吶']='天吶你真高:BAACLgAFFH8JAAIGAAQJ0CCTBQCNAQAGAAQJ0CCTBQCNAQAuAAQKfxkABAYACAltHXYIALYCAAYACAk/HXYIALYCAAgAAwnOIMpRAPAAAAcAAwnPB5gcAIoAAAAA.',
['天外']='天外圣骑:BAAALgADCgMJAwAAAA==.',
['天涯']='天涯夜狂:BAAALgAECgkJCQAAAA==.',
['天生']='天生会飞:BAAALgAECgcJDAAAAA==.',
['天真']='天真丶无邪:BAAALgAECgQJBgAAAA==.',
['太俊']='太俊没办法:BAAALgAECgMJAwAAAA==.',
['太贪']='太贪玩:BAAALgAECgQJBAABLgAFFAUJBQAWADoQAA==.',
['奎尔']='奎尔萨啦:BAAALgAECgUJCgAAAA==.',
['奥尔']='奥尔德雷蒙:BAAALgAECgUJCwAAAA==.奥尔瑟亚:BAAALgAECgQJCQABLgAECgUJCwAFAAAAAA==.',
['奥术']='奥术鸿牛:BAAALgAECgIJAgAAAA==.',
['奶龙']='奶龙奶浓:BAAALgAECgEJAQABLgAFFAQJCQAGANAgAA==.',
['好运']='好运加亿:BAABLgAFFH8FAAIcAAQJgAqNFgA7AQAcAAQJgAqNFgA7AQAAAA==.',
['姜海']='姜海潾:BAAALgAFFAEJAQAAAA==.',
['姬夜']='姬夜:BAAALgAECgIJAwAAAA==.',
['娇躯']='娇躯难承魅颜:BAAALgAECgEJAgAAAA==.',
['嬴楚']='嬴楚:BAAALgAFFAEJAgAAAA==.',
['季都']='季都丶罗侯:BAAALgAECgIJBAAAAA==.',
['守宝']='守宝团姬特:BAAALgAFFAQJBAAAAA==.',
['宝子']='宝子:BAAALgAFFAEJAQAAAA==.',
['宝宝']='宝宝好缺爱:BAAALgAECgYJBgAAAA==.宝宝爱吃药:BAAALgAFFAIJBAAAAA==.',
['宝石']='宝石:BAAALgAECgYJCwABLgAFFAEJAQAFAAAAAA==.',
['寒夜']='寒夜空车:BAAALgAECgQJBwAAAA==.',
['寒月']='寒月中的北风:BAAALgAECgYJBgAAAA==.',
['寒江']='寒江独影:BAAALgADCggJCQAAAA==.',
['小丑']='小丑女:BAACLgAFFH8KAAIBAAQJwwS/IQA5AQABAAQJwwS/IQA5AQAuAAQKfx8AAgEACAkHGZ1EAGoCAAEACAkHGZ1EAGoCAAAA.',
['小丨']='小丨乔:BAAALgAECgUJBQAAAA==.',
['小丶']='小丶蜥蜴:BAAALgADCgUJBQAAAA==.',
['小可']='小可烦:BAAALgAECgcJEAAAAA==.',
['小士']='小士牛刀:BAAALgAECgcJDQAAAA==.',
['小妖']='小妖妖:BAAALgAECgYJCwAAAA==.',
['小小']='小小僧丶:BAAALgAECgUJCgAAAA==.小小猪猪强:BAAALgAECgIJAgAAAA==.',
['小时']='小时候很厉害:BAAALgAFFAEJAQAAAA==.',
['小破']='小破的歌:BAAALgAECgEJAQAAAA==.',
['小米']='小米棒子:BAAALgADCgEJAQAAAA==.',
['小糖']='小糖串儿:BAAALgAECgEJAQAAAA==.',
['小罗']='小罗嗦:BAAALgAECggJCgAAAA==.',
['小芯']='小芯点:BAAALgAECgMJBAAAAA==.',
['小苦']='小苦瓜:BAACLgAFFH8MAAMVAAQJWR7fCwB1AQAVAAQJWR7fCwB1AQAdAAIJwBXoAgC4AAAuAAQKfyQAAxUACAmhIwQLAEMDABUACAmhIwQLAEMDAB0AAgmpI4cIAGoAAAAA.',
['小萌']='小萌醤:BAABLgAECn8UAAIJAAcJYxizRwDVAQAJAAcJYxizRwDVAQAAAA==.',
['尐丨']='尐丨熊喵喵:BAAALgADCgEJAQAAAA==.',
['尐寳']='尐寳哥:BAAALgAECgQJBgAAAA==.',
['尐爺']='尐爺灬吥呔壊:BAAALgADCgcJBwAAAA==.',
['居然']='居然小蓝蓝:BAAALgAFFAEJAgAAAA==.',
['山居']='山居秋暝:BAAALgAECgcJDQAAAA==.',
['岚少']='岚少:BAAALgAECgYJCwAAAA==.',
['岭南']='岭南王富贵:BAAALgADCgMJAwAAAA==.',
['崐莱']='崐莱山辉夜:BAAALgAECgEJAQAAAA==.',
['左手']='左手一支烟:BAAALgADCgcJBwAAAA==.',
['师傅']='师傅在线刮痧:BAAALgAFFAMJAwAAAA==.',
['希因']='希因娜:BAAALgADCgEJAQAAAA==.',
['希诺']='希诺:BAAALgAFFAEJAQAAAA==.',
['帕拉']='帕拉丁圣骑:BAAALgADCgYJBgAAAA==.',
['带个']='带个恶魔逛街:BAACLgAFFH8NAAMcAAQJNhkqEABfAQAcAAQJNhkqEABfAQAeAAEJmg2qFQBTAAAuAAQKfx4AAxwACAlPHPQjAIQCABwACAlPHPQjAIQCAB4AAglZE5dIAJUAAAAA.',
['平头']='平头哥丶:BAAALgAECgYJBgAAAA==.',
['廖化']='廖化:BAAALgAECgMJBAAAAA==.',
['建军']='建军:BAAALgAECgYJBwAAAA==.',
['开摆']='开摆开摆:BAAALgAECgYJBgABLgAECggJFQASAPIbAA==.',
['弃夢']='弃夢:BAAALgAFFAIJBAAAAA==.',
['弎生']='弎生:BAAALgADCgkJCQAAAA==.',
['张大']='张大帅:BAAALgAECgEJAQAAAA==.',
['张迷']='张迷人呀丶:BAAALgAECgcJEgAAAA==.',
['彩虹']='彩虹糖:BAAALgADCgcJBwAAAA==.',
['彩钢']='彩钢瓦:BAAALgAFFAEJAQAAAA==.',
['德美']='德美丽:BAAALgAECgcJEAABLgAECggJFQASAPIbAA==.',
['心中']='心中镜:BAAALgAECgYJBgAAAA==.',
['心想']='心想世橙:BAAALgADCgEJAQAAAA==.',
['心灵']='心灵震撼:BAAALgAECgkJCgAAAA==.',
['快乐']='快乐就对了鸭:BAAALgAECgUJCwAAAA==.',
['思这']='思这想娜:BAAALgAECgQJCQAAAA==.',
['恶毒']='恶毒避风塘:BAACLgAFFH8KAAIcAAQJ9hCbFgA6AQAcAAQJ9hCbFgA6AQAuAAQKfyUABBwACAmgIGEXAMgCABwACAmgIGEXAMgCAB8AAgmiGR8ZALIAAB4AAwmXEVVBALAAAAAA.',
['恶魔']='恶魔之拥:BAABLgAECn8VAAQJAAYJ/hO9VwCaAQAJAAYJ/hO9VwCaAQAKAAEJfAPXegAoAAAgAAEJPgVuLwAjAAAAAA==.',
['情愿']='情愿做一尾鱼:BAAALgAFFAEJAQAAAA==.',
['惨绝']='惨绝戏之导化:BAABLgAFFH8IAAIbAAQJ4A85CgBFAQAbAAQJ4A85CgBFAQAAAA==.',
['惹你']='惹你的温:BAAALgAECgcJBwAAAA==.',
['愛宕']='愛宕洋榎:BAAALgAECgIJAQAAAA==.',
['懒精']='懒精灵:BAAALgAECgIJAgAAAA==.',
['戀離']='戀離飛翼:BAABLgAFFH8JAAIOAAUJegRcBAD7AAAOAAUJegRcBAD7AAAAAA==.',
['我的']='我的小熊在哪:BAAALgAECgUJBQAAAA==.',
['战神']='战神进化论:BAAALgAECgkJEwAAAA==.',
['扑棱']='扑棱鹅子:BAAALgAECgQJBQAAAA==.',
['把他']='把他們叉出去:BAAALgAECgUJBQAAAA==.',
['抹了']='抹了油的猪:BAAALgAFFAIJBAAAAA==.',
['抽烟']='抽烟女武神:BAAALgAFFAEJAgAAAA==.',
['拜见']='拜见猫大人:BAAALgAECggJCAAAAA==.',
['拳拳']='拳拳带风:BAAALgAECgcJEQAAAA==.',
['持忆']='持忆画红尘:BAAALgAFFAEJAQABLgAFFAIJAgAFAAAAAA==.',
['按摩']='按摩小妹倩倩:BAACLgAFFH8TAAQSAAYJohK4AACzAQASAAUJMha4AACzAQAhAAUJ8AryAQBPAQATAAEJZASBCgBVAAAuAAQKfygABBIACAnZJdkGACEDABIACAnZJdkGACEDABMABglyG7gqANMBACEABAleGCYMAAUBAAAA.按摩小妹婉婉:BAACLgAFFH8LAAIZAAMJaiUrBwA8AQAZAAMJaiUrBwA8AQAuAAQKfxkAAhkACAmRJIcIAE8DABkACAmRJIcIAE8DAAEuAAUUBgkTABIAohIA.按摩小妹婷婷:BAABLgAFFH8GAAIEAAMJUg7XBwD+AAAEAAMJUg7XBwD+AAABLgAFFAYJEwASAKISAA==.按摩小妹星星:BAAALgAECgMJAwABLgAFFAYJEwASAKISAA==.按摩小妹桂桂:BAAALgAECgYJEgAAAA==.按摩小妹芳芳:BAAALgAECgYJBwABLgAFFAYJEwASAKISAA==.按摩小妹露露:BAACLgAFFH8IAAIVAAMJFSAyHAAyAQAVAAMJFSAyHAAyAQAuAAQKfxcAAhUABwm2Ho0oAJgCABUABwm2Ho0oAJgCAAEuAAUUBgkTABIAohIA.',
['捣成']='捣成泥:BAAALgAECgQJBgAAAA==.',
['掏出']='掏出来给你看:BAAALgAFFAEJAQAAAA==.',
['推倒']='推倒小妹妹:BAAALgAECgYJBgAAAA==.',
['揉花']='揉花撕玉:BAAALgAECgMJAwAAAA==.',
['提奥']='提奥曼迪司:BAAALgAECgIJBAAAAA==.',
['摇耳']='摇耳朵小白兔:BAAALgAECgcJBwAAAA==.',
['摧残']='摧残直剑:BAAALgAECgYJCAAAAA==.',
['撒拉']='撒拉黑:BAAALgAECgQJAwAAAA==.',
['撒满']='撒满人间爱:BAAALgAECgUJBQAAAA==.',
['教练']='教练正在热身:BAABLgAFFH8HAAIcAAIJ+QmpIQCjAAAcAAIJ+QmpIQCjAAAAAA==.',
['旖旎']='旖旎從風:BAAALgAECgYJDQAAAA==.',
['无敌']='无敌小贝壳:BAAALgAECgEJAQAAAA==.',
['时代']='时代在召唤:BAACLgAFFH8FAAMXAAMJqhHkDgDoAAAXAAMJqhHkDgDoAAAZAAIJdhNfJACjAAAuAAQKfxsAAxkABwkRJOUUAO0CABkABwkRJOUUAO0CABcABgngFAI/AHwBAAEuAAQKCAkVABIA8hsA.',
['昔日']='昔日灬冥:BAABLgAFFH8HAAIBAAIJsRjSOQC3AAABAAIJsRjSOQC3AAAAAA==.',
['星晨']='星晨万象:BAABLgAFFH8FAAIXAAIJ5g0IDACTAAAXAAIJ5g0IDACTAAAAAA==.',
['星野']='星野白夜:BAAALgAECgUJBQAAAA==.',
['晕云']='晕云允韵丶:BAAALgAECgEJAQAAAA==.',
['普通']='普通大哥:BAAALgAECgQJBAAAAA==.',
['晴暖']='晴暖海洋:BAAALgAECgUJBgAAAA==.',
['暗丶']='暗丶修罗:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜柒:BAAALgAECgcJBwAAAA==.',
['暗影']='暗影中的光芒:BAAALgAECgUJBgAAAA==.',
['暗灬']='暗灬血血:BAAALgAECgcJDgAAAA==.',
['暮色']='暮色兮凉城:BAAALgADCgEJAQAAAA==.',
['暴走']='暴走怪咖:BAABLgAFFH8FAAIcAAUJnhAFCQBLAQAcAAUJnhAFCQBLAQAAAA==.',
['暴风']='暴风怒雨:BAAALgAECgYJCwAAAA==.暴风雪:BAAALgAECgYJEAAAAA==.',
['曙光']='曙光女神丶:BAAALgAECgQJBAAAAA==.',
['最后']='最后的青春:BAAALgAECgcJEAAAAA==.',
['月下']='月下泥泞:BAAALgADCgEJAQAAAA==.月下疯狂杀戮:BAAALgAECgYJBgAAAA==.月下蓑衣客:BAAALgAECgUJCAAAAA==.',
['月之']='月之暗面:BAAALgAECgUJBQABLgAECgYJBQAFAAAAAA==.',
['月伴']='月伴小海浪:BAAALgAECgIJAgAAAA==.',
['有健']='有健康有光明:BAAALgAFFAEJAQAAAA==.',
['有沢']='有沢実紗:BAAALgAECgMJBAAAAA==.',
['有髁']='有髁虎牙:BAAALgAECgMJBQAAAA==.',
['木易']='木易淑婉:BAAALgAFFAEJAQAAAA==.',
['朴祉']='朴祉禹:BAAALgADCgEJAQAAAA==.',
['李宇']='李宇春的哥哥:BAAALgAECgIJAgAAAA==.',
['李沅']='李沅禧:BAAALgAFFAIJAwAAAA==.',
['杖一']='杖一玄文:BAAALgAFFAEJAgAAAA==.',
['极度']='极度山伯爵:BAAALgAECgEJAQAAAA==.',
['枕霞']='枕霞旧友:BAAALgAECgEJAwAAAA==.',
['果粒']='果粒橙加香蕉:BAAALgAECgEJAQAAAA==.',
['柒涩']='柒涩夜月葉:BAAALgAECgQJBAAAAA==.',
['柠檬']='柠檬酸:BAAALgAECgYJDwAAAA==.',
['树爷']='树爷:BAAALgAECgEJAQAAAA==.',
['格格']='格格女巫:BAAALgAECgEJAwAAAA==.',
['桃夭']='桃夭丶坤灵:BAAALgAECgEJAQAAAA==.',
['桐敷']='桐敷沙子:BAACLgAFFH8PAAIBAAUJ4hTYDAC1AQABAAUJ4hTYDAC1AQAuAAQKfyMAAgEACAngI9wQAEMDAAEACAngI9wQAEMDAAAA.',
['桥本']='桥本丶环奈:BAAALgAECgEJAQAAAA==.',
['梦中']='梦中雾里看花:BAACLgAFFH8GAAIBAAMJARbnHQDBAAABAAMJARbnHQDBAAAuAAQKfyMAAgEACAnlIEYHAFkCAAEACAnlIEYHAFkCAAAA.',
['椰果']='椰果蛋挞:BAAALgAECgcJEQAAAA==.',
['楊老']='楊老板:BAAALgAECgUJBQAAAA==.',
['槐破']='槐破梦:BAAALgAECgUJBQAAAA==.',
['欢乐']='欢乐歌颂:BAAALgADCgYJBgAAAA==.',
['欧狗']='欧狗吃我一矛:BAAALgAECgUJBQAAAA==.',
['欧皇']='欧皇:BAAALgADCgMJAwAAAA==.',
['残风']='残风冷煞:BAAALgAECgQJDAAAAA==.',
['比比']='比比拉不:BAAALgAECggJCQAAAA==.',
['气定']='气定寒冰箭:BAAALgAECgIJAgAAAA==.',
['水丝']='水丝草:BAAALgAECgMJAwAAAA==.',
['水劣']='水劣人:BAAALgAECgEJAQAAAA==.',
['水区']='水区吴彦祖:BAAALgAECgEJAQABLgAFFAQJAQAFAAAAAA==.',
['水管']='水管工:BAAALgAECgcJCgAAAA==.',
['江東']='江東小覇朢:BAAALgAECgEJAQAAAA==.',
['沃蒴']='沃蒴灬婷婷:BAAALgAECgIJAgAAAA==.',
['沐师']='沐师:BAAALgAECgMJAwAAAA==.',
['沐浠']='沐浠:BAAALgAECgcJBwAAAA==.',
['沙坪']='沙坪坝二豁子:BAAALgAECggJCAAAAA==.',
['沟子']='沟子好烫:BAAALgAECgQJBgAAAA==.',
['河原']='河原木桃香丶:BAAALgAECgEJAQAAAA==.',
['油站']='油站第一车模:BAAALgAECgQJBAAAAA==.',
['法丶']='法丶帕森图拉:BAAALgADCgkJBwAAAA==.',
['波波']='波波要浪:BAAALgAECgQJBwAAAA==.',
['波浪']='波浪浪:BAAALgAECgQJBAAAAA==.',
['洽哩']='洽哩:BAAALgADCgYJBgAAAA==.',
['浊酒']='浊酒慰风尘:BAAALgAECgEJAQAAAA==.',
['浮生']='浮生若梦:BAAALgADCgcJBwAAAA==.',
['海浪']='海浪噢:BAACLgAFFH8KAAILAAMJoiMkBQA2AQALAAMJoiMkBQA2AQAuAAQKfyQAAgsACAn4Ir8GAAcDAAsACAn4Ir8GAAcDAAAA.',
['清洛']='清洛:BAAALgAECgQJBAABLgAFFAUJEgABAKYZAA==.',
['清风']='清风客:BAAALgAECgQJBgAAAA==.清风幽梦:BAAALgADCgEJAQAAAA==.清风明月:BAAALgAECgkJCAABLgAFFAQJBAAFAAAAAA==.清风沐雨:BAAALgADCgMJAwAAAA==.',
['溜圆']='溜圆的阿昆达:BAAALgAECgcJAgABLgAFFAUJCQANAH0fAA==.',
['漂亮']='漂亮的回旋踢:BAAALgADCgYJBgAAAA==.',
['漆夜']='漆夜雪:BAAALgAFFAEJAQAAAA==.',
['漆黑']='漆黑之刃:BAAALgAECgYJBwAAAA==.',
['澄星']='澄星:BAACLgAFFH8MAAIBAAQJqR3lFAB2AQABAAQJqR3lFAB2AQAuAAQKfycAAgEACAlSJEUQAEYDAAEACAlSJEUQAEYDAAAA.',
['火冰']='火冰奥:BAAALgADCgUJBQAAAA==.',
['火山']='火山大饭桶:BAAALgAECgQJBAAAAA==.火山猛狮:BAAALgAECgcJBwAAAA==.',
['火炎']='火炎焱燚丨:BAAALgADCgEJAQAAAA==.',
['灬吖']='灬吖吖灬:BAAALgAECgYJAgAAAA==.',
['灬尐']='灬尐爺灬:BAAALgADCgEJAQAAAA==.',
['灬芙']='灬芙莉莲灬:BAAALgADCgEJAQAAAA==.',
['灭龙']='灭龙魔导士:BAAALgAECgcJCgAAAA==.',
['灵魂']='灵魂低吟:BAACLgAFFH8FAAIVAAIJHhDGPgCiAAAVAAIJHhDGPgCiAAAuAAQKfx0ABBUACAkJF79jAMgBABUABglPGb9jAMgBABoABgn2C8EsANgAAB0AAQnjD44VAD0AAAEuAAUUAwkFABIAuhIA.灵魂爆裂:BAABLgAECn8XAAIBAAYJqxn6iwC6AQABAAYJqxn6iwC6AQABLgAFFAMJBQASALoSAA==.灵魂狂獵:BAACLgAFFH8FAAISAAMJuhLPCgACAQASAAMJuhLPCgACAQAuAAQKfxQABBIABglyGUtTAG8BABIABAncHktTAG8BACEABQkWFKkZADUBABMAAgmTCXJ4AF4AAAAA.灵魂神棍:BAAALgAFFAMJBAABLgAFFAMJBQASALoSAA==.',
['灸暮']='灸暮:BAAALgAECgYJBwAAAA==.',
['点星']='点星火:BAAALgADCgYJBgAAAA==.',
['烈焰']='烈焰飞羽:BAAALgAFFAEJAQAAAA==.',
['烧烬']='烧烬:BAAALgAECgYJBgAAAA==.',
['热丶']='热丶丶:BAAALgAECgQJBAAAAA==.',
['無節']='無節剿聖光:BAAALgAECgkJCQAAAA==.',
['照相']='照相鸡漫走:BAAALgAECgYJDgAAAA==.',
['熊爺']='熊爺沒有貓:BAAALgADCgUJBQAAAA==.',
['燃烧']='燃烧魅惑:BAAALgAFFAEJAgAAAA==.',
['爆鸟']='爆鸟大师:BAAALgAECgcJAwAAAA==.爆鸟转圈圈:BAAALgAECgIJAgAAAA==.',
['爱丘']='爱丘雷尔丶:BAAALgAECgEJAQABLgAFFAUJBQAiAJkcAA==.',
['爱丽']='爱丽儿:BAAALgAECgUJBQAAAA==.',
['爱是']='爱是一道光:BAAALgAECgUJCgAAAA==.',
['牛丶']='牛丶悟空:BAABLgAECn8XAAIZAAgJMhjmLwBjAgAZAAgJMhjmLwBjAgAAAA==.',
['牛家']='牛家的哥哥:BAAALgAECgEJAQAAAA==.',
['牛尾']='牛尾七分熟:BAAALgAECgYJDAAAAA==.',
['牛川']='牛川风丶:BAAALgAECgIJAgAAAA==.',
['牛德']='牛德一丶:BAAALgAECgMJAwAAAA==.',
['狂气']='狂气之瞳:BAAALgADCgEJAQAAAA==.',
['狂爆']='狂爆小骑兵:BAAALgADCgEJAQAAAA==.',
['狂酱']='狂酱爱之列车:BAACLgAFFH8MAAIBAAQJ3RlGGgBhAQABAAQJ3RlGGgBhAQAuAAQKfxgAAgEACAmDHl0oANECAAEACAmDHl0oANECAAAA.',
['狂霸']='狂霸拽布丁:BAACLgAFFH8FAAIBAAIJrxmaNwC7AAABAAIJrxmaNwC7AAAuAAQKfxcAAgEABwmtIfgxAKsCAAEABwmtIfgxAKsCAAAA.',
['狄安']='狄安娜:BAAALgAECgYJCQAAAA==.',
['狒狒']='狒狒聖王:BAAALgAFFAIJBAAAAA==.',
['独孤']='独孤伽罗:BAAALgAECgEJAQAAAA==.',
['狮子']='狮子与海:BAAALgAFFAIJAwAAAA==.狮子的海:BAAALgAFFAEJAQABLgAFFAIJAwAFAAAAAA==.',
['猎残']='猎残月:BAAALgAECgYJEAAAAA==.',
['猫冬']='猫冬丶:BAAALgAECgEJAgAAAA==.',
['獨特']='獨特思考的貓:BAAALgADCgYJBgAAAA==.',
['王猪']='王猪弟:BAAALgAECgQJBQAAAA==.',
['王萌']='王萌萌:BAAALgAECgEJAQAAAA==.',
['玖儿']='玖儿永不言败:BAAALgAECgEJAgAAAA==.',
['玖戒']='玖戒:BAAALgAECgYJBgAAAA==.玖戒一聖:BAAALgAECgMJAwAAAA==.',
['环球']='环球同此凉热:BAABLgAFFH8FAAIWAAUJAgCoCQABAAAWAAUJAgCoCQABAAABLgAFFAcJCwANAM0PAA==.',
['琥珀']='琥珀烟云:BAAALgAECgEJAQAAAA==.',
['甘尼']='甘尼克斯:BAAALgAECgkJEAAAAA==.',
['生活']='生活如清水:BAAALgAECgEJAQAAAA==.',
['生瓜']='生瓜蛋子:BAAALgADCgcJBwAAAA==.',
['画个']='画个女朋友:BAAALgAECgUJBQAAAA==.',
['痞子']='痞子暴:BAAALgAFFAEJAQAAAA==.',
['登里']='登里个登:BAAALgAECgEJAQAAAA==.',
['皮皮']='皮皮啾啾:BAAALgAECgQJBAAAAA==.',
['盛唐']='盛唐赞风:BAAALgAECgYJCQAAAA==.',
['相当']='相当刚健:BAAALgAECgEJAQAAAA==.',
['看不']='看不见终点:BAAALgAECgcJCAAAAA==.',
['看心']='看心情奶你:BAAALgAECgcJDwAAAA==.',
['看看']='看看怎么个事:BAAALgAECgYJCQAAAA==.',
['看轻']='看轻所以看轻:BAAALgAECgEJAQAAAA==.',
['睿特']='睿特派:BAAALgADCgMJAwAAAA==.',
['石胡']='石胡煲粥:BAAALgAECgkJEQAAAA==.',
['砂糖']='砂糖橘:BAAALgAFFAEJAgAAAA==.',
['碎裂']='碎裂残阳:BAAALgADCgEJAQAAAA==.',
['神圣']='神圣风暴战士:BAAALgAECgIJAgAAAA==.',
['空鞗']='空鞗徐伦:BAAALgAECgEJAQAAAA==.',
['竹影']='竹影星辰:BAAALgAECgYJDQAAAA==.',
['笑靥']='笑靥繁花:BAAALgAECgYJBgAAAA==.',
['粉红']='粉红体育生丶:BAAALgAFFAIJBAAAAA==.',
['紫爱']='紫爱紫红:BAAALgAECgMJAwAAAA==.',
['红发']='红发魔女:BAAALgAECgEJAQAAAA==.',
['红孩']='红孩儿丶道标:BAABLgAFFH8JAAMOAAUJYxTVAwBbAQAOAAQJYxTVAwBbAQANAAUJ4AsDBwAjAQAAAA==.',
['红豆']='红豆团子:BAACLgAFFH8MAAMSAAQJ+B3mAQCEAQASAAQJ+B3mAQCEAQAhAAEJswcPCQBXAAAuAAQKfygABBIACAmcI6MEAEQDABIACAmcI6MEAEQDACEABQmgE68KACQBABMABAmdFX9bANUAAAAA.',
['纯情']='纯情小蛋蛋:BAAALgAECgEJAQAAAA==.',
['纯白']='纯白之黑:BAAALgAECgkJCAABLgAFFAcJBQABANIGAA==.纯白舞精灵:BAAALgAECgMJAwAAAA==.',
['纯粹']='纯粹无聊:BAAALgAECgYJBQAAAA==.',
['给你']='给你点牛奶:BAAALgAECgEJAQAAAA==.给你看个宝贝:BAAALgAECgEJAQAAAA==.',
['绝对']='绝对伏特加酒:BAAALgADCgYJBgAAAA==.',
['绿叶']='绿叶鲜粽:BAAALgAFFAEJAQAAAA==.',
['缺爱']='缺爱的宝宝:BAACLgAFFH8LAAMSAAQJKBvlBwAdAQATAAQJjQ/GDwAzAQASAAMJRh3lBwAdAQAuAAQKfygAAxMACAmFIjsQALkCABMACAkMIDsQALkCABIABwmYH78qAAoCAAAA.',
['罓灬']='罓灬罓:BAAALgAECgMJAwAAAA==.',
['罗格']='罗格多恩:BAABLgAFFH8HAAIZAAQJaQ9eDQBAAQAZAAQJaQ9eDQBAAQAAAA==.',
['羊角']='羊角尖:BAAALgAECgEJAgAAAA==.',
['美女']='美女术:BAAALgADCgIJAgAAAA==.',
['美杜']='美杜灬莎:BAAALgAECgMJBQAAAA==.',
['美老']='美老伴儿:BAAALgAFFAMJAwAAAA==.',
['翠神']='翠神丶艾翁:BAAALgAFFAEJAgAAAA==.',
['翻滚']='翻滚吧胖球:BAAALgAECgcJAgAAAA==.',
['老虎']='老虎的第八部:BAAALgADCgIJAgAAAA==.老虎终结者:BAAALgAECgYJBwAAAA==.',
['肉蛋']='肉蛋葱鸡堡堡:BAAALgADCgEJAQAAAA==.',
['胖达']='胖达胖胖哒:BAAALgAECgMJAwAAAA==.',
['胜哥']='胜哥哥:BAAALgAECgYJDQAAAA==.',
['至暗']='至暗之牧:BAAALgAECgcJDwAAAA==.',
['良宵']='良宵丶美九:BAAALgADCgYJBgAAAA==.',
['艾丽']='艾丽瑞亚:BAABLgAECn8UAAMJAAcJ/RYYZgBvAQAJAAcJ/RYYZgBvAQAKAAIJAwm9XgBmAAABLgAFFAQJDAAHAPETAA==.',
['艾泽']='艾泽拉丝冥君:BAAALgAECgEJAQAAAA==.艾泽拉丝唤魔:BAAALgAECgQJBQAAAA==.艾泽拉丝烈阳:BAAALgAFFAEJAQAAAA==.',
['艾瑞']='艾瑞梸娅:BAAALgAECgUJBwAAAA==.',
['艾维']='艾维琳娜:BAAALgAECgYJCQABLgAFFAQJDAAHAPETAA==.',
['艾莉']='艾莉瑞雅:BAABLgAFFH8FAAMXAAIJKxqXCwCYAAAXAAIJKxqXCwCYAAAZAAEJ6AI7OQBGAAABLgAFFAQJDAAHAPETAA==.',
['芒果']='芒果蛋挞:BAAALgADCgEJAQAAAA==.',
['芜鲤']='芜鲤煜煜:BAAALgAECgYJBgAAAA==.',
['芝士']='芝士獐子:BAAALgAECgEJAgABLgAFFAQJCQAGANAgAA==.',
['芯仲']='芯仲侑术:BAAALgADCgIJAgAAAA==.',
['花开']='花开碟满枝:BAAALgAECgIJAwAAAA==.',
['花灬']='花灬火:BAAALgAECgEJAQAAAA==.',
['花生']='花生奶酪:BAAALgAECgUJBwAAAA==.',
['花飞']='花飞隐雪:BAAALgAFFAIJBAAAAA==.',
['苏高']='苏高飞丶:BAAALgADCgYJBgAAAA==.',
['苦寻']='苦寻杭州富婆:BAAALgAECgQJBAAAAA==.',
['苹果']='苹果砸晕牛顿:BAABLgAECn8XAAMGAAgJYhxLAgBrAgAGAAgJYhxLAgBrAgAIAAQJtQloXgC4AAAAAA==.',
['草祭']='草祭:BAAALgADCgEJAQAAAA==.',
['荣耀']='荣耀战团苦工:BAAALgAECgYJCAAAAA==.',
['莉娅']='莉娅德淋:BAAALgADCgUJBQAAAA==.',
['莉莉']='莉莉酱:BAABLgAFFH8GAAISAAQJ9gsqBQBJAQASAAQJ9gsqBQBJAQAAAA==.',
['莫沫']='莫沫陌:BAAALgAECgMJBAAAAA==.',
['莫非']='莫非公主:BAAALgAECgQJBgAAAA==.',
['莱东']='莱东:BAAALgAECgkJEAAAAA==.',
['菈妮']='菈妮:BAAALgAECgEJAQAAAA==.',
['菲狄']='菲狄亚斯:BAAALgAECgYJDAAAAA==.',
['萌萌']='萌萌的熊孩子:BAAALgAFFAIJAgAAAA==.',
['萌鹌']='萌鹌鹑灬:BAAALgAECgYJCgAAAA==.',
['萨美']='萨美丽:BAABLgAECn8cAAMLAAgJdyD9CADmAgALAAgJdyD9CADmAgAPAAEJpxKxjQAqAAABLgAECggJFQASAPIbAA==.',
['落花']='落花杞:BAAALgAFFAEJAQAAAA==.',
['葉丶']='葉丶風:BAAALgAECgQJCQAAAA==.',
['蒹霞']='蒹霞苍苍:BAAALgAFFAIJAwAAAA==.',
['蓝爬']='蓝爬博:BAAALgAECgQJBQAAAA==.',
['蓝色']='蓝色圣光:BAABLgAECn8aAAIjAAgJeh9+AwDiAgAjAAgJeh9+AwDiAgAAAA==.',
['蓝鳍']='蓝鳍鮪真好吃:BAAALgAECggJDAAAAA==.',
['薛定']='薛定谔的猫貓:BAAALgADCgcJBwAAAA==.',
['虚幻']='虚幻地旋律:BAAALgADCgMJBAAAAA==.',
['虚空']='虚空统御者:BAAALgAECgIJAwAAAA==.',
['虫二']='虫二丶:BAAALgAFFAEJAQAAAA==.',
['蜜糖']='蜜糖兔兔:BAAALgAECgYJCAABLgAFFAIJAgAFAAAAAA==.',
['蝶化']='蝶化庄生:BAABLgAFFH8HAAIBAAcJKRdDAABCAgABAAcJKRdDAABCAgAAAA==.',
['血宝']='血宝贝:BAAALgAECgUJBQAAAA==.',
['血小']='血小贱:BAAALgAECgUJBQAAAA==.',
['血穴']='血穴:BAAALgAECgEJAQAAAA==.',
['街头']='街头吃熊貓:BAAALgAECgYJBgAAAA==.',
['表哥']='表哥:BAAALgAECgQJBAAAAA==.',
['裆里']='裆里的大黑龍:BAAALgAECgYJDgAAAA==.',
['裴秀']='裴秀智:BAAALgAFFAEJAQABLgAFFAEJAQAFAAAAAA==.',
['许仙']='许仙骑白蛇:BAAALgAECgMJAwAAAA==.',
['许反']='许反帝双刀客:BAAALgAECgYJCwAAAA==.',
['该死']='该死的圣光:BAAALgADCgEJAQAAAA==.',
['说不']='说不德:BAAALgAECgQJBAAAAA==.',
['贫道']='贫道太上司机:BAAALgAECgYJBgAAAA==.',
['贵族']='贵族小牛牛:BAAALgAECgEJAQAAAA==.',
['贼浪']='贼浪:BAAALgADCgkJCQAAAA==.',
['赛博']='赛博双马尾:BAAALgAECgYJBgAAAA==.',
['赛娜']='赛娜留斯:BAAALgAECgEJAQABLgAECgYJFQABAF0gAA==.',
['赫炎']='赫炎萝:BAAALgAECgQJBAAAAA==.',
['超能']='超能喵:BAAALgAECgEJAQAAAA==.',
['超雄']='超雄小饼:BAAALgAECgUJBgAAAA==.',
['踏风']='踏风者:BAAALgAECgcJBwABLgAFFAUJBQANAFgQAA==.',
['辛叡']='辛叡恩:BAAALgAECgIJAgAAAA==.',
['辛睿']='辛睿恩:BAABLgAFFH8GAAIcAAIJ9BbYHAC0AAAcAAIJ9BbYHAC0AAAAAA==.',
['辛达']='辛达苟萨:BAAALgAECgkJCAAAAA==.',
['辞镜']='辞镜:BAAALgAFFAEJAQAAAA==.',
['辣椒']='辣椒丶猎手:BAAALgAFFAIJBAAAAA==.辣椒王座:BAAALgADCgUJCgAAAA==.辣椒超肉:BAAALgAFFAIJAgAAAA==.',
['还喝']='还喝丿酸奶:BAAALgAECgcJEAAAAA==.',
['这不']='这不是老大:BAAALgAECgUJCAAAAA==.',
['迪门']='迪门修斯丶:BAABLgAFFH8HAAIJAAQJ7gnZGQABAQAJAAQJ7gnZGQABAQAAAA==.',
['逆天']='逆天的哥特瓦:BAAALgAECgMJAwAAAA==.',
['逐暗']='逐暗者:BAAALgAECgkJCgAAAA==.',
['逝水']='逝水星辰:BAABLgAECn8XAAIBAAYJrSAhbgD4AQABAAYJrSAhbgD4AQABLgAFFAIJAgAFAAAAAA==.',
['遂缘']='遂缘:BAAALgAFFAEJAgAAAA==.',
['那年']='那年夏天:BAAALgAECgYJBwAAAA==.',
['野王']='野王哈德森:BAABLgAFFH8FAAIVAAMJSwvCGADNAAAVAAMJSwvCGADNAAAAAA==.',
['錵澤']='錵澤萫婇:BAAALgAECgYJDwAAAA==.',
['鑫宝']='鑫宝宝:BAACLgAFFH8MAAMaAAQJ3xG/CQDoAAAaAAQJlwi/CQDoAAAVAAIJ8BgRGwC2AAAuAAQKfyQAAxUACAlYHfE/ADgCABUACAmFG/E/ADgCABoACAlVEWQVAL0BAAAA.',
['钢琴']='钢琴家:BAAALgAECgYJBgAAAA==.',
['钢铁']='钢铁圣斗士:BAAALgAECgcJEQAAAA==.',
['钱烈']='钱烈宪发言:BAAALgADCgEJAQAAAA==.',
['银白']='银白耀日:BAAALgAECgEJAQAAAA==.',
['长河']='长河落日:BAAALgAECgQJCwAAAA==.',
['门前']='门前大树:BAAALgAFFAUJAwAAAA==.',
['闪电']='闪电伍连鞭:BAAALgAFFAEJAQAAAA==.闪电连五鞭:BAAALgAECgEJAQAAAA==.',
['阳光']='阳光朦胧:BAAALgADCgcJBwAAAA==.',
['阿亨']='阿亨:BAAALgAECgcJCQAAAA==.',
['阿尔']='阿尔托莉亚:BAAALgADCgYJAQABLgAFFAQJCQAGANAgAA==.阿尔托莉娅:BAAALgAECgEJAQAAAA==.阿尔法苟:BAAALgAECgYJCAAAAA==.',
['阿帕']='阿帕提阿帕提:BAAALgADCgQJBAAAAA==.',
['阿祖']='阿祖:BAAALgAECgkJCAAAAA==.',
['陈琛']='陈琛琛:BAAALgAECgYJBwAAAA==.',
['陈老']='陈老二:BAAALgADCgIJAgAAAA==.',
['陈菖']='陈菖蒲:BAAALgAECgYJBgAAAA==.',
['陳平']='陳平安:BAAALgAECgEJAQAAAA==.',
['随心']='随心所欲:BAAALgADCgUJBQAAAA==.',
['隔壁']='隔壁的猿人:BAAALgAECgYJBgAAAA==.',
['雨丶']='雨丶:BAAALgAECgYJBgAAAA==.雨丶丶:BAAALgAECgYJBgAAAA==.',
['雨魄']='雨魄星散:BAAALgAECgIJAgAAAA==.',
['雪花']='雪花:BAACLgAFFH8JAAIUAAMJkgL7CgCYAAAUAAMJkgL7CgCYAAAuAAQKfxYAAhQABwnGC6UgADsBABQABwnGC6UgADsBAAAA.',
['雪馨']='雪馨:BAAALgADCgYJBgAAAA==.',
['雷欧']='雷欧奈:BAAALgAECgEJAQAAAA==.',
['雷纳']='雷纳斯:BAAALgAFFAIJBAAAAA==.',
['電電']='電電:BAAALgADCgEJAQAAAA==.',
['霜丨']='霜丨降丶:BAAALgAECgEJAQAAAA==.',
['霹雳']='霹雳蛋蛋:BAAALgAECggJEwAAAA==.',
['靈魂']='靈魂碎片:BAABLgAFFH8IAAIcAAQJ0CBqCgCKAQAcAAQJ0CBqCgCKAQAAAA==.',
['青丝']='青丝如墨丶:BAAALgAECgEJAQAAAA==.',
['青时']='青时雨:BAAALgAECgUJBQAAAA==.',
['青椒']='青椒蔬菜:BAAALgAECgYJCQAAAA==.',
['青笙']='青笙挽歌:BAAALgAECgEJAQAAAA==.',
['静极']='静极丶思动:BAAALgAECgkJEgABLgAFFAUJBQANAEkBAA==.',
['面包']='面包树游侠:BAAALgAECgkJCQAAAA==.',
['顶瓜']='顶瓜瓜:BAAALgAFFAEJAQAAAA==.',
['风一']='风一样的泪:BAAALgAECgcJCAAAAA==.',
['风会']='风会来:BAAALgAFFAQJBAAAAA==.',
['风干']='风干的大爷:BAAALgAECgcJDgABLgAFFAYJDgAWANUkAA==.风干的橘滑:BAAALgAECgYJBgAAAA==.',
['飘絮']='飘絮灬小骑:BAAALgAECgQJBgAAAA==.',
['飞起']='飞起一欧拉:BAAALgAECgIJAwAAAA==.',
['食指']='食指:BAAALgAECgIJAwAAAA==.',
['饺子']='饺子好吃:BAAALgAECgYJDAAAAA==.',
['香坊']='香坊大茈花:BAAALgADCgIJAgAAAA==.',
['骆小']='骆小一:BAAALgAECggJCQAAAA==.',
['骚年']='骚年灬:BAAALgAECgYJBgAAAA==.',
['骨头']='骨头很脆:BAAALgAECgYJBgAAAA==.',
['高小']='高小杰灬:BAAALgAECgEJAQAAAA==.',
['鬼舞']='鬼舞辻无掺:BAAALgAECgEJAQAAAA==.',
['魔之']='魔之戮:BAAALgAECgEJAQAAAA==.',
['鮟度']='鮟度因:BAABLgAFFH8FAAMVAAIJJyV9LgDfAAAVAAIJJyV9LgDfAAAdAAEJHAweBQBSAAAAAA==.',
['鱿鱼']='鱿鱼:BAAALgAFFAIJAgAAAA==.',
['鸡汤']='鸡汤喝不下:BAAALgAECggJBgAAAA==.',
['鸡的']='鸡的嘴下巴:BAAALgADCgUJCgAAAA==.',
['麦克']='麦克阿西丶:BAAALgAECgYJBgABLgAFFAUJBAAFAAAAAA==.',
['黑心']='黑心的榴莲:BAAALgADCgcJBwAAAA==.黑心的樱桃:BAAALgAFFAQJBAAAAA==.',
['龙马']='龙马精神:BAAALgAECgYJBgAAAA==.',
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
