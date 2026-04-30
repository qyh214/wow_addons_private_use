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

local lookup = {'DemonHunter-Devourer','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Priest-Shadow','DemonHunter-Havoc','Unknown-Unknown','Mage-Frost','Mage-Arcane','Shaman-Restoration','Monk-Brewmaster','Warrior-Protection','Evoker-Preservation','Priest-Holy','Priest-Discipline','Warlock-Demonology','Warlock-Destruction','Evoker-Augmentation','Druid-Restoration','Druid-Balance','Warrior-Fury','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DemonHunter-Vengeance','Shaman-Elemental','Druid-Guardian','DeathKnight-Unholy','Monk-Mistweaver','Warrior-Arms','Monk-Windwalker','Warlock-Affliction','Mage-Fire','DeathKnight-Blood','DeathKnight-Frost',}
local provider = {region='CN',realm='黑龙军团',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adema:BAAALgAECgMJAwAAAA==.',
Ai='Airstyle:BAAALgADCgEJAQAAAA==.Aivi:BAAALgAECgUJBgAAAA==.',
Am='Amdradeon:BAAALgAECgIJAgAAAA==.',
An='Anglesoso:BAABLgAFFH8KAAIBAAQJLhwACABCAQABAAQJLhwACABCAQAAAA==.Anglesoxo:BAAALgAFFAIJAgABLgAFFAQJCgABAC4cAA==.Anglesuvu:BAAALgAFFAMJAwABLgAFFAQJCgABAC4cAA==.',
Ax='Axia:BAABLgAECn8VAAQCAAcJchbYIABSAQACAAYJ9hbYIABSAQADAAQJDhbSXwD9AAAEAAEJXQ8RRAAuAAABLgAFFAUJBQAFAM8HAA==.',
Bi='Biubiubiuy:BAAALgAECgYJEwAAAA==.',
Br='Bruce:BAABLgAFFH8GAAIBAAMJfAkGFADVAAABAAMJfAkGFADVAAAAAA==.Brunomars:BAAALgAFFAIJAwAAAA==.',
Ch='Cherudim:BAAALgAECgEJAQAAAA==.',
Cl='Clytie:BAAALgAECgEJAQAAAA==.',
Co='Conblue:BAAALgAFFAEJAgAAAA==.',
Da='Daylight:BAAALgAECgEJAQAAAA==.',
De='Deathknight:BAAALgADCgEJAgAAAA==.Destroydevil:BAAALgAECgIJAgAAAA==.',
Ev='Everline:BAAALgAECgUJBQAAAA==.',
Ex='Eximmortal:BAABLgAFFH8HAAIGAAQJwyTfAAC7AQAGAAQJwyTfAAC7AQAAAA==.',
Fo='Fosaken:BAAALgAECgYJCAAAAA==.Fourlair:BAAALgAECgUJBQAAAA==.Foxgirl:BAAALgAECgYJBgAAAA==.',
Ge='Georgeknight:BAAALgAFFAIJAgABLgAFFAIJAgAHAAAAAA==.Georgemonk:BAAALgAECgMJAwABLgAFFAIJAgAHAAAAAA==.Georgeyoung:BAABLgAECn8UAAMIAAYJFCHxWQArAgAIAAYJFCHxWQArAgAJAAEJ9QocHwAyAAABLgAFFAIJAgAHAAAAAA==.',
Ha='Hairball:BAAALgAECgcJCgAAAA==.Handinhand:BAAALgAECgcJDgAAAA==.',
Ho='Hollow:BAAALgAFFAEJAQABLgAFFAUJDQAKAMwRAA==.Hotcolo:BAAALgAECgYJBgAAAA==.',
Ic='Icepalace:BAACLgAFFH8XAAIIAAYJkRuFAQDXAQAIAAYJkRuFAQDXAQAuAAQKfyUAAggACQk3JH4FAKsDAAgACQk3JH4FAKsDAAAA.',
Il='Illidanyu:BAAALgAECgcJDgAAAA==.',
Im='Imba:BAAALgAECgQJBwAAAA==.',
Io='Ioveating:BAABLgAFFH8GAAILAAMJJgJNGQChAAALAAMJJgJNGQChAAAAAA==.',
Ji='Jiajin:BAABLgAFFH8GAAIEAAIJTguOBQBrAAAEAAIJTguOBQBrAAAAAA==.',
Jo='Jokermeow:BAACLgAFFH8VAAIMAAUJnxbJAgB2AQAMAAUJnxbJAgB2AQAuAAQKfygAAgwACAlTH+sGAL4CAAwACAlTH+sGAL4CAAAA.',
Jy='Jyss:BAAALgAECgEJAQAAAA==.',
Ko='Kohl:BAAALgADCgkJCQAAAA==.',
Le='Letmein:BAAALgADCgUJBQAAAA==.Leviac:BAACLgAFFH8KAAINAAUJ8AX9BAA+AQANAAUJ8AX9BAA+AQAuAAQKfxYAAg0ACAlHGW0VAPQBAA0ACAlHGW0VAPQBAAAA.Leviackerman:BAACLgAFFH8KAAMOAAUJsxfoAQCdAQAOAAUJsxfoAQCdAQAPAAEJDxgBGABRAAAuAAQKfysAAw4ACAlcJHICAEQDAA4ACAlcJHICAEQDAA8ABgkMGZgZAMwBAAAA.',
Li='Licht:BAAALgAECgUJBgABLgAFFAUJBQAFAM8HAA==.Lions:BAAALgADCgQJCAAAAA==.',
Ll='Llac:BAAALgAECgYJBgAAAA==.Llhyll:BAAALgAECgYJBgAAAA==.',
Lo='Loststars:BAAALgAECgEJAQAAAA==.Loveating:BAACLgAFFH8GAAMQAAQJ1gMPJwByAAAQAAQJ1gMPJwByAAARAAEJggBaGwA5AAAuAAQKfyQAAxAACAnIEbY/AA8CABAACAnsELY/AA8CABEABAk/DfZCAKkAAAAA.',
Lu='Lucifersword:BAAALgAFFAEJAgAAAA==.Lunala:BAAALgADCgUJBQAAAA==.',
Mi='Mionelol:BAACLgAFFH8PAAICAAQJzBqMBABgAQACAAQJzBqMBABgAQAuAAQKfyQAAgIACQmTHgoIAFQDAAIACQmTHgoIAFQDAAAA.',
Mm='Mmurge:BAAALgAECgYJEAABLgAFFAYJFwASAKMjAA==.',
Mu='Muelsyse:BAACLgAFFH8FAAITAAMJ5xK7EADjAAATAAMJ5xK7EADjAAAuAAQKfxwAAxMACQlAG2ILAOYCABMACQlAG2ILAOYCABQABAlXCjhfAKQAAAAA.Murge:BAACLgAFFH8XAAMSAAYJoyOSAQBYAgASAAYJoyOSAQBYAgANAAIJ4xkzEADHAAAuAAQKfxwAAxIACQl/IJUJAN0CABIACAlRI5UJAN0CAA0ACAm2H08HAMkCAAAA.Muzitoudruid:BAAALgAFFAEJAQAAAA==.',
My='Mylittlepony:BAAALgAECgYJEgAAAA==.',
Ne='Necry:BAAALgAECgQJBAAAAA==.',
No='Normie:BAAALgAECgEJAQAAAA==.',
Ol='Oldcap:BAAALgAFFAMJBAAAAA==.',
Ph='Photios:BAAALgAECgEJAQAAAA==.',
Pi='Pigraisercht:BAAALgADCgQJBAAAAA==.Pineappleman:BAAALgAECgUJCgAAAA==.Pinman:BAAALgADCgIJAgAAAA==.',
Pl='Pluto:BAAALgAFFAEJAQABLgAFFAMJBQASAEwPAA==.',
Pn='Pnk:BAAALgAECgYJCAAAAA==.',
Pr='Predestine:BAABLgAECn8iAAICAAgJOx+8GwDDAgACAAgJOx+8GwDDAgAAAA==.',
Qq='Qqlc:BAAALgAECgIJAQAAAA==.',
Qx='Qx:BAAALgAECggJCwAAAA==.',
Ra='Rainbowzs:BAABLgAECn8dAAIVAAcJkRs8IQBJAgAVAAcJkRs8IQBJAgAAAA==.',
Re='Reimmortal:BAABLgAECn8ZAAMGAAcJiSPFDgB3AgAGAAYJyiXFDgB3AgABAAcJVB7sMwAqAgAAAA==.',
Sa='Sacerdarrow:BAAALgAECgIJAgAAAA==.Sanjiuo:BAACLgAFFH8JAAIWAAMJuBjnCQASAQAWAAMJuBjnCQASAQAuAAQKfxUAAhYACAnbGLgYAHQCABYACAnbGLgYAHQCAAAA.',
Se='Senorita:BAAALgAFFAEJAgAAAA==.',
Sh='Shurrikx:BAAALgAFFAIJAgABLgAFFAYJFwAIAJEbAA==.',
Si='Silendragoon:BAAALgAECgEJAQAAAA==.',
Sl='Slair:BAAALgAECgMJAwAAAA==.',
So='Sonwalker:BAAALgADCgQJBAAAAA==.',
Sp='Spectre:BAAALgAFFAQJAQAAAA==.',
St='Stardust:BAAALgAECgcJBwAAAA==.',
Su='Superhunter:BAACLgAFFH8UAAMXAAUJxB5hBgC5AQAXAAUJ9xxhBgC5AQAYAAQJph+rAgAqAQAuAAQKfx8AAxcACAlNJNgLAOkCABcACAkaI9gLAOkCABgABQmBI6EQALkBAAAA.',
Sy='Symphony:BAAALgADCgQJBAAAAA==.',
Th='Thepip:BAAALgADCgEJAQAAAA==.Thex:BAABLgAFFH8GAAMWAAMJlCT3BABMAQAWAAMJlCT3BABMAQAXAAIJnRHoHACiAAAAAA==.',
Xc='Xcf:BAABLgAFFH8FAAILAAIJAAZbIAB0AAALAAIJAAZbIAB0AAAAAA==.',
Yo='Yolo:BAAALgAECgYJDwAAAA==.',
Ze='Zeff:BAAALgADCgcJBwAAAA==.',
['一只']='一只小肥鱼:BAAALgADCgUJBQAAAA==.一只小飞鱼:BAACLgAFFH8LAAIZAAQJjg7FAAAQAQAZAAQJjg7FAAAQAQAuAAQKfyIAAhkACAn4GdcEAGYCABkACAn4GdcEAGYCAAAA.一只眠羊:BAAALgADCgEJAQAAAA==.',
['一大']='一大波跟风术:BAAALgADCgMJAwAAAA==.',
['一头']='一头驴:BAAALgAECgcJBwAAAA==.',
['一字']='一字淦:BAAALgAFFAQJBAAAAA==.',
['一拳']='一拳超人:BAAALgAECgYJCAAAAA==.',
['一支']='一支巛云箭:BAAALgAECgQJBAAAAA==.',
['一睡']='一睡饱清欢:BAABLgAECn8UAAIIAAkJ3R/qCAB/AwAIAAkJ3R/qCAB/AwAAAA==.',
['一笑']='一笑清城:BAAALgAECgMJAwAAAA==.',
['一紙']='一紙巟年:BAAALgAECgQJBAAAAA==.',
['一萌']='一萌头:BAAALgAECgYJCAAAAA==.',
['一记']='一记闷棍:BAAALgAECgEJAQAAAA==.',
['七条']='七条天空:BAAALgAECgEJAgAAAA==.',
['七秒']='七秒记忆的鱼:BAABLgAECn8YAAIaAAcJRBeRKQDIAQAaAAcJRBeRKQDIAQAAAA==.',
['三角']='三角初华:BAAALgAECgIJAgAAAA==.',
['上去']='上去就一刀:BAAALgAFFAIJAgAAAA==.',
['上帝']='上帝之手:BAAALgAECgEJAQAAAA==.',
['不信']='不信圣光的牛:BAABLgAECn8eAAMbAAgJVB0RAgDuAQAUAAYJHByfHgAKAgAbAAgJ5RoRAgDuAQAAAA==.',
['不听']='不听:BAAALgAECgYJCAAAAA==.',
['不疯']='不疯魔不成活:BAAALgADCgEJAQAAAA==.',
['不要']='不要就是不要:BAAALgADCgEJAQAAAA==.',
['专干']='专干隔壁老王:BAAALgAECgYJBgAAAA==.',
['丨子']='丨子非鱼丨:BAAALgAECgcJBwAAAA==.',
['丨栗']='丨栗山未来:BAAALgADCgEJAQAAAA==.',
['丨白']='丨白羊丶火象:BAAALgAECgQJBwAAAA==.',
['个球']='个球:BAAALgADCgUJBQAAAA==.',
['丶三']='丶三生:BAAALgAECgMJBQAAAA==.',
['丶丶']='丶丶夕阳丶丶:BAABLgAFFH8FAAIcAAMJlRb6JQD+AAAcAAMJlRb6JQD+AAAAAA==.丶丶射射丶丶:BAABLgAECn8UAAMWAAgJPReIHQA8AQAWAAgJXhaIHQA8AQAXAAUJJQ9ZUAAMAQABLgAFFAMJBQAcAJUWAA==.丶丶术术丶丶:BAAALgAECgkJEQABLgAFFAMJBQAcAJUWAA==.',
['丶棒']='丶棒棒糖灬:BAAALgAECggJCAAAAA==.',
['丶王']='丶王嘟嘟:BAAALgAECgEJAQAAAA==.',
['丶羽']='丶羽:BAAALgADCgMJAwAAAA==.',
['丷嘚']='丷嘚吧嘚丷:BAACLgAFFH8LAAMUAAQJAge0BgAJAQAUAAQJAge0BgAJAQATAAMJ5BrKDgD7AAAuAAQKfyMAAxMACAlfIJUPALwCABMACAlfIJUPALwCABQABgnTGtclAM8BAAAA.',
['乄死']='乄死神狂:BAAALgAFFAIJAgAAAA==.',
['乱哼']='乱哼哼:BAAALgAECgUJDQAAAA==.',
['乾元']='乾元:BAAALgAECgYJEQABLgAFFAcJBwAdAA8VAA==.',
['云韵']='云韵:BAABLgAFFH8FAAIeAAMJPx8yAgAgAQAeAAMJPx8yAgAgAQAAAA==.',
['任月']='任月临影:BAAALgAECgYJBgAAAA==.',
['伊利']='伊利丹怒风:BAAALgAECgEJAQAAAA==.伊利八个圈:BAAALgAECgEJAQAAAA==.',
['但丁']='但丁丶神曲:BAABLgAECn8WAAIcAAcJDBdyDwC2AQAcAAcJDBdyDwC2AQAAAA==.',
['佛我']='佛我不过并蒂:BAAALgAECgYJCQABLgAFFAUJBQAFAM8HAA==.',
['你丑']='你丑你先讲:BAAALgAFFAIJAgAAAA==.',
['你在']='你在诗的结尾:BAAALgAECgIJBQAAAA==.',
['你怎']='你怎么汜了:BAAALgAECgUJBQAAAA==.',
['你是']='你是下三路:BAAALgADCgUJBQAAAA==.',
['你萌']='你萌死啦:BAACLgAFFH8JAAMPAAQJ8BArCwAqAQAPAAQJ+gorCwAqAQAOAAIJehqoCwCoAAAuAAQKfysABA4ACQllHFwEABkCAA4ABwnwIFwEABkCAA8ABQmJDmYuACsBAAUAAQn4DiVfADoAAAAA.',
['佩恩']='佩恩灰:BAAALgAECgUJBQAAAA==.',
['侑魜']='侑魜:BAAALgAECgQJBgAAAA==.',
['偷瓜']='偷瓜被抓的猹:BAAALgAECgEJAQAAAA==.',
['傲慢']='傲慢:BAAALgAECgQJBAAAAA==.',
['傻愣']='傻愣愣:BAAALgAECgQJBQAAAA==.',
['元素']='元素艺术:BAAALgAECgMJAwAAAA==.',
['光之']='光之所在:BAABLgAECn8hAAIaAAgJjCAmDADZAgAaAAgJjCAmDADZAgAAAA==.',
['兜里']='兜里有阿昆达:BAABLgAFFH8FAAIcAAUJwA0tCwB6AQAcAAUJwA0tCwB6AQAAAA==.',
['兽忘']='兽忘猎:BAAALgAECgIJAgAAAA==.',
['冰与']='冰与火:BAAALgAECgIJAgAAAA==.',
['冰寒']='冰寒之血:BAAALgAECgUJBQABLgAFFAQJDgAcAN0cAA==.',
['冰封']='冰封战将:BAAALgADCgEJAQAAAA==.',
['冰泪']='冰泪风暴:BAAALgAECgIJAQAAAA==.',
['冰澜']='冰澜王子:BAAALgAECgQJBAAAAA==.',
['冲锋']='冲锋的导酱:BAAALgAECgYJDAAAAA==.',
['凉凉']='凉凉:BAAALgAECgQJBAAAAA==.',
['利群']='利群之馬:BAAALgAECgIJAwAAAA==.',
['刻晴']='刻晴高手:BAAALgAFFAMJBAAAAA==.',
['加菲']='加菲的黑狐骑:BAAALgAECgkJEAABLgAFFAgJAQAHAAAAAA==.',
['协能']='协能德:BAAALgADCgEJAQAAAA==.',
['卖身']='卖身买酒喝:BAAALgADCgMJAwAAAA==.',
['南流']='南流景:BAABLgAFFH8GAAIcAAIJ7Q6XQACgAAAcAAIJ7Q6XQACgAAAAAA==.',
['南琴']='南琴梨丶:BAAALgAECgMJAwAAAA==.',
['卡皮']='卡皮芭拉:BAAALgAFFAEJAQAAAA==.',
['卢克']='卢克麦艾斯:BAAALgADCgUJCAAAAA==.',
['卷丶']='卷丶柏:BAAALgAECgUJBQAAAA==.',
['卷卷']='卷卷酥饼:BAAALgAECgUJCAAAAA==.',
['叁叁']='叁叁肆肆:BAAALgAECgYJCQAAAA==.',
['叉老']='叉老师:BAABLgAFFH8KAAIQAAUJtx0UBADeAQAQAAUJtx0UBADeAQAAAA==.',
['双笙']='双笙:BAABLgAECn8fAAQeAAYJPhVVFwBAAQAVAAUJ4xAtWwBBAQAeAAUJARNVFwBAAQAMAAMJlAxwOQB/AAAAAA==.',
['口司']='口司口令口:BAAALgAECgEJAgAAAA==.',
['古尔']='古尔没有丹:BAABLgAFFH8FAAIQAAUJTyEOAwD2AQAQAAUJTyEOAwD2AQAAAA==.',
['可她']='可她总在梦里:BAAALgAECgEJAQAAAA==.',
['吉薇']='吉薇艾儿:BAACLgAFFH8IAAIcAAQJBg9OGQBAAQAcAAQJBg9OGQBAAQAuAAQKfyUAAhwACQm+G/UYAOYCABwACQm+G/UYAOYCAAAA.',
['吖丶']='吖丶熊猫:BAAALgAECgYJDwAAAA==.',
['君士']='君士坦丁真:BAAALgAECgMJAwABLgAFFAQJDQAfAJ0jAA==.',
['吴萨']='吴萨七:BAAALgAFFAEJAQAAAA==.',
['呆骑']='呆骑士:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜咕噜咕噜:BAAALgAFFAQJBAAAAA==.',
['咖喱']='咖喱牛排:BAAALgAECgYJBgAAAA==.',
['哈基']='哈基咪曼波:BAAALgAECgIJAgAAAA==.哈基米噜曼波:BAABLgAFFH8FAAMQAAMJehNSHgCuAAAQAAIJPhRSHgCuAAAgAAEJ8hG/AQBZAAAAAA==.哈基米尔:BAABLgAECn8RAAMWAAgJWR+5CAAHAwAWAAgJWR+5CAAHAwAXAAMJrBRcYQC7AAAAAA==.',
['哑巴']='哑巴:BAAALgAECgEJAQAAAA==.',
['唯梦']='唯梦闲人:BAAALgAECgYJCgABLgAFFAEJAQAHAAAAAA==.',
['唱反']='唱反調:BAAALgAECgkJCQAAAA==.唱反调丶丶:BAAALgAECgMJAwAAAA==.',
['嚒嚒']='嚒嚒牛阿昆达:BAAALgAECgEJAwAAAA==.',
['团团']='团团笨笨:BAAALgAECgQJBQAAAA==.',
['在下']='在下呵呵哒:BAAALgADCgcJBwAAAA==.',
['在逃']='在逃歼尸犯:BAAALgAECgcJDwAAAA==.',
['夏夜']='夏夜晚枫:BAAALgADCgYJBgAAAA==.夏夜晚风:BAAALgAECgEJAQAAAA==.',
['夏霜']='夏霜恸:BAAALgAECgYJCAAAAA==.',
['夜月']='夜月傲天:BAAALgAECgYJBgAAAA==.',
['大展']='大展宏图:BAAALgADCgUJBQAAAA==.',
['大洪']='大洪拳:BAAALgADCgQJBAAAAA==.',
['大灬']='大灬黑灬牛:BAAALgAECgUJBQAAAA==.',
['大神']='大神牛:BAAALgADCgYJCQAAAA==.',
['大魔']='大魔头炸酱面:BAAALgAECgQJBgAAAA==.',
['大黑']='大黑哞:BAAALgADCgYJBgAAAA==.',
['天涯']='天涯共此时:BAAALgAECgcJDQAAAA==.',
['夭夭']='夭夭灵:BAAALgADCgMJAwAAAA==.',
['失忆']='失忆的鱼:BAAALgAECgYJBgAAAA==.',
['奇妙']='奇妙魔幻黑黑:BAAALgAECgkJCQAAAA==.',
['奉饶']='奉饶天下先:BAAALgAECgYJBgAAAA==.',
['奥丁']='奥丁之眼:BAAALgAECgYJBgAAAA==.',
['奶德']='奶德可可:BAAALgADCgUJBQAAAA==.',
['好吧']='好吧我错了:BAAALgADCgEJAQAAAA==.',
['妙匕']='妙匕开花:BAAALgAECgEJAwAAAA==.',
['威尔']='威尔卡斯:BAAALgAECgYJBgAAAA==.',
['娘子']='娘子:BAAALgAECgMJAwAAAA==.',
['娜美']='娜美美:BAAALgAFFAEJAQABLgAFFAUJDAAcAPwjAA==.',
['守护']='守护甜鑫:BAAALgAFFAQJBAAAAA==.守护者麦迪武:BAABLgAECn8UAAMIAAYJ6RBBuABwAQAIAAYJ6RBBuABwAQAhAAIJUwoAAAAAAAABLgAFFAUJBQAFAM8HAA==.',
['安之']='安之若素:BAAALgAECgYJBgAAAA==.',
['安西']='安西教练:BAAALgAECgUJDQAAAA==.',
['完全']='完全胜利:BAACLgAFFH8MAAQOAAQJdw52BQAtAQAOAAQJdw52BQAtAQAPAAIJZwilFACQAAAFAAEJ1AIxFwBDAAAuAAQKfxgABA4ACAmwGikTAEYCAA4ACAkRGikTAEYCAA8ABAmbEBk3AO0AAAUABAkbDuhEANUAAAAA.',
['宝可']='宝可梦玩家丶:BAAALgADCgEJAQAAAA==.',
['寂夜']='寂夜封魂:BAAALgAECgIJAgAAAA==.',
['寂寞']='寂寞会冻:BAAALgAECgEJAQAAAA==.',
['寒風']='寒風輕吟:BAAALgAECgEJAQAAAA==.',
['小天']='小天狼星:BAABLgAFFH8IAAIGAAQJ3hwXAQBfAQAGAAQJ3hwXAQBfAQAAAA==.',
['小弦']='小弦:BAAALgAECgIJAgAAAA==.',
['小氿']='小氿月:BAABLgAECn8eAAIcAAgJjh1NKgCQAgAcAAgJjh1NKgCQAgAAAA==.',
['小煜']='小煜不吃苦瓜:BAAALgAFFAEJAQAAAA==.',
['小籽']='小籽:BAAALgAECgIJAgAAAA==.',
['小豆']='小豆包:BAAALgAECgIJAgAAAA==.',
['小阿']='小阿龙:BAAALgADCgUJDwAAAA==.',
['少年']='少年阿猫:BAABLgAECn8eAAIiAAgJeBU1BQCQAQAiAAgJeBU1BQCQAQAAAA==.',
['少说']='少说多吃:BAAALgAECgEJAQAAAA==.',
['尤廸']='尤廸安丿怒风:BAAALgAECgMJAwAAAA==.',
['尼禄']='尼禄丶:BAAALgADCgIJAgAAAA==.',
['屮灬']='屮灬谁来助我:BAAALgAECgYJCgAAAA==.',
['山河']='山河图:BAAALgADCgMJAwAAAA==.',
['山濛']='山濛雨奇:BAABLgAFFH8JAAIUAAUJBw+sBgB4AQAUAAUJBw+sBgB4AQABLgAFFAYJCgAUAHUWAA==.',
['岩石']='岩石的背:BAAALgADCgUJBQAAAA==.',
['帅蛋']='帅蛋的忧伤:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔薇娜斯:BAAALgAECgEJAQAAAA==.',
['干汜']='干汜黄旭东:BAAALgAECgYJDwAAAA==.',
['幸存']='幸存者泽瑞拉:BAAALgADCgUJBQAAAA==.',
['幽幽']='幽幽龙:BAAALgAECgYJCQAAAA==.',
['幽然']='幽然自德:BAAALgAECgMJAwAAAA==.',
['库呲']='库呲咔嚓:BAAALgADCgEJAQAAAA==.',
['张靓']='张靓颖:BAABLgAFFH8HAAIFAAQJhA+YDADjAAAFAAQJhA+YDADjAAAAAA==.',
['张鸽']='张鸽佳:BAAALgADCgYJBQAAAA==.',
['弦琴']='弦琴音符:BAACLgAFFH8QAAIOAAQJOQ/IBQAlAQAOAAQJOQ/IBQAlAQAuAAQKfyYAAg4ACQlbIjMBAHUDAA4ACQlbIjMBAHUDAAAA.',
['彩虹']='彩虹喵:BAAALgAECgYJBgAAAA==.',
['微笑']='微笑的厄里斯:BAAALgAECgcJEAAAAA==.',
['快乐']='快乐的千岛酱:BAAALgAECgMJAwAAAA==.',
['快到']='快到碗里来丶:BAAALgAECgUJCAAAAA==.',
['快跑']='快跑吧小菇凉:BAAALgAECgYJCQAAAA==.',
['怀英']='怀英:BAABLgAECn8ZAAIIAAcJRREHPQACAQAIAAcJRREHPQACAQAAAA==.',
['怎么']='怎么教都不听:BAAALgADCgEJAgAAAA==.',
['惊恐']='惊恐的鸦熊:BAAALgAFFAIJAgABLgAFFAMJCgAUAKEbAA==.',
['愈地']='愈地者之力:BAAALgAECgYJCAAAAA==.',
['愣头']='愣头青:BAAALgAECgQJDAABLgAFFAUJDAAQAK0mAA==.',
['懵圈']='懵圈的吉米:BAAALgAECgYJBgAAAA==.',
['我一']='我一个无敌:BAAALgADCgEJAQAAAA==.我一个闪现:BAAALgAECgMJBgAAAA==.',
['我不']='我不会闪现丶:BAAALgADCgIJAgAAAA==.我不是哀木涕:BAAALgADCgkJDgAAAA==.我不是赵云:BAABLgAECn8VAAICAAcJISAKJQCTAgACAAcJISAKJQCTAgAAAA==.',
['我叫']='我叫倪帅哥:BAAALgAFFAIJAgAAAA==.',
['我很']='我很甜:BAACLgAFFH8JAAIQAAQJtgM/GwAaAQAQAAQJtgM/GwAaAQAuAAQKfyIAAhAACAntFCNDAAMCABAACAntFCNDAAMCAAAA.',
['我根']='我根本就不困:BAAALgAECgUJDAAAAA==.',
['战丶']='战丶五渣:BAAALgAFFAIJAgAAAA==.',
['护士']='护士衫下:BAAALgAECgUJBQAAAA==.',
['抹了']='抹了猪的油:BAAALgAECgkJCQAAAA==.',
['拾月']='拾月风雨:BAAALgAECgEJAgAAAA==.',
['拿包']='拿包三五双冰:BAAALgAECgcJBgAAAA==.',
['拿指']='拿指头戳你:BAAALgAECgEJAwAAAA==.',
['按时']='按时毕业:BAAALgAECgEJAQABLgAFFAEJAQAHAAAAAA==.',
['挊哥']='挊哥:BAAALgAECgEJAQABLgAFFAUJBQABAN8aAA==.',
['揽月']='揽月:BAAALgADCgUJCQAAAA==.',
['摩卡']='摩卡不加糖:BAAALgAECgcJAQAAAA==.',
['撒旦']='撒旦之灵:BAAALgAECgYJCQAAAA==.撒旦重生:BAAALgAECgUJBQAAAA==.',
['断奶']='断奶我要死了:BAAALgAECgIJAgAAAA==.',
['断翼']='断翼天翎:BAABLgAECn8YAAMTAAYJ0BdTOwC3AQATAAYJ0BdTOwC3AQAUAAYJHxYIMgB6AQAAAA==.',
['断魂']='断魂丶殇:BAAALgAECgEJAgAAAA==.',
['斯利']='斯利普汰克:BAAALgAECgUJDgABLgAFFAUJBQAFAM8HAA==.斯利普沃克:BAABLgAFFH8FAAIFAAUJzwddBAAjAQAFAAUJzwddBAAjAQAAAA==.',
['斯尔']='斯尔瓦娜希:BAABLgAFFH8FAAMXAAIJixSGGwCoAAAXAAIJixSGGwCoAAAWAAEJxhc9GgBbAAAAAA==.',
['方丈']='方丈心眼很小:BAAALgADCgMJAwAAAA==.',
['无事']='无事:BAAALgAECgUJBQAAAA==.',
['无尽']='无尽的悔恨:BAABLgAECn8UAAMjAAcJKxd2BQDkAQAjAAcJ0BV2BQDkAQAcAAYJDhGXHQBJAQAAAA==.',
['无端']='无端的执着:BAAALgAECgEJAQAAAA==.',
['昔丶']='昔丶涟:BAABLgAECn8YAAMFAAkJIRcvDgCgAgAFAAkJIRcvDgCgAgAOAAcJChgqIADgAQAAAA==.',
['昕悦']='昕悦妹妹:BAAALgAECgEJAQAAAA==.',
['星河']='星河点点:BAAALgAECgQJBAAAAA==.',
['星痕']='星痕:BAAALgAECgYJCAAAAA==.',
['春卷']='春卷与栗子饭:BAAALgAECgIJAQABLgAFFAYJBAAHAAAAAA==.',
['春来']='春来鸟不惊:BAAALgAECgIJBAAAAA==.',
['是椎']='是椎名真昼呀:BAAALgAECgYJDAAAAA==.',
['暗夜']='暗夜波比:BAABLgAFFH8HAAIIAAMJmxJ4GQD2AAAIAAMJmxJ4GQD2AAAAAA==.',
['暗色']='暗色天鹅绒:BAAALgAFFAQJBAAAAA==.',
['暮之']='暮之晨:BAAALgAECgYJCwAAAA==.',
['暴躁']='暴躁的亚瑟:BAAALgAECgQJBQAAAA==.',
['曉蘿']='曉蘿莉:BAABLgAECn8nAAIDAAgJVxi9HgAiAgADAAgJVxi9HgAiAgAAAA==.',
['最遥']='最遥远的距离:BAACLgAFFH8LAAIcAAQJpBwfCQBGAQAcAAQJpBwfCQBGAQAuAAQKfxwAAhwACAnBImAZAOQCABwACAnBImAZAOQCAAAA.',
['月圆']='月圆云清:BAAALgAECgUJBgAAAA==.',
['月忱']='月忱:BAAALgAECgYJCgABLgAFFAMJCAAPAEUgAA==.',
['月辰']='月辰:BAABLgAFFH8IAAIPAAMJRSBtBgAnAQAPAAMJRSBtBgAnAQAAAA==.',
['朕慑']='朕慑你无罪:BAAALgAECgEJAQAAAA==.',
['木皿']='木皿陽平:BAABLgAFFH8FAAIKAAIJ3hg6FgClAAAKAAIJ3hg6FgClAAAAAA==.',
['朵拉']='朵拉贡:BAAALgAFFAEJAQAAAA==.',
['李一']='李一离:BAAALgADCgMJAwAAAA==.',
['李橙']='李橙橙丶:BAAALgAECgMJAwAAAA==.',
['杏子']='杏子夹心饼干:BAAALgAECgYJBgAAAA==.',
['来杯']='来杯飘雪:BAAALgAECgYJCgAAAA==.',
['来自']='来自太阳的光:BAABLgAFFH8IAAICAAMJzSBtDgA3AQACAAMJzSBtDgA3AQAAAA==.来自小星星:BAAALgAECgEJAQAAAA==.来自月亮的鱼:BAAALgAECgEJAgAAAA==.',
['東東']='東東卌卌:BAAALgADCgEJAQAAAA==.',
['東洋']='東洋雪蓮:BAAALgAECgUJAwAAAA==.',
['柚柚']='柚柚子:BAECLgAFFH8KAAIIAAQJ+A06EAAzAQAIAAQJ+A06EAAzAQAuAAQKfyAAAggACAmfIYEpAM0CAAgACAmfIYEpAM0CAAAA.',
['柠檬']='柠檬丶茶:BAAALgADCgEJAQAAAA==.',
['桔梗']='桔梗苑西瓜:BAABLgAECn8WAAMPAAcJFh5DEwAWAgAPAAYJ3x9DEwAWAgAFAAcJUxqCJgCjAQAAAA==.',
['梅梅']='梅梅美美:BAABLgAECn8jAAMWAAgJ0CFhBwATAgAWAAcJqSJhBwATAgAXAAIJ6xWXbwCAAAAAAA==.',
['梦原']='梦原知予:BAAALgAECgYJBgAAAA==.',
['梨落']='梨落不爱索雅:BAAALgADCgMJAwAAAA==.',
['棕色']='棕色海绵:BAAALgAFFAEJAQAAAA==.',
['椰林']='椰林飘香:BAAALgAECgQJBgAAAA==.',
['楠城']='楠城卡布达:BAAALgAECgEJAQAAAA==.',
['歌者']='歌者与喵:BAAALgADCgMJBgAAAA==.',
['止凛']='止凛:BAAALgAECggJDgAAAA==.',
['武魂']='武魂天:BAAALgAECgIJAgAAAA==.',
['歪脖']='歪脖子:BAAALgADCgYJBwAAAA==.',
['死骑']='死骑来灵打:BAABLgAFFH8LAAIcAAQJxBClCQBDAQAcAAQJxBClCQBDAQAAAA==.',
['母牛']='母牛旭峰:BAAALgAECgIJAgAAAA==.',
['比格']='比格沃咕:BAAALgAECgEJAQAAAA==.',
['毛绒']='毛绒微醺爬爬:BAABLgAFFH8JAAMLAAUJfyGIAQCXAQALAAQJfyGIAQCXAQAfAAEJAAByFAA+AAAAAA==.',
['毛都']='毛都没有:BAABLgAECn8bAAMCAAcJ+B2GSwAAAgACAAYJZh2GSwAAAgAEAAEJ0yBDOABgAAAAAA==.',
['水口']='水口茉莉绘:BAAALgAECgUJBQAAAA==.',
['水果']='水果就图一乐:BAAALgAECgUJCQAAAA==.',
['汝妻']='汝妻吾自养之:BAAALgAECgkJBwAAAA==.',
['江南']='江南周杰伦:BAAALgAECgEJAQAAAA==.',
['江厦']='江厦厦:BAAALgAECgUJDAAAAA==.',
['江理']='江理工小助手:BAAALgAECgUJBgAAAA==.',
['沈不']='沈不浪:BAAALgADCgUJBQAAAA==.沈不浪大侠呀:BAAALgADCgcJBwAAAA==.',
['没殼']='没殼的螃蟹:BAABLgAFFH8OAAIUAAUJixiDBACjAQAUAAUJixiDBACjAQABLgAFFAYJCgAUAHUWAA==.',
['沧海']='沧海龙吟:BAACLgAFFH8IAAICAAQJJxZiCgBZAQACAAQJJxZiCgBZAQAuAAQKfysAAgIACQkNICMFAHoDAAIACQkNICMFAHoDAAAA.',
['法不']='法不容情:BAAALgAECggJCAAAAA==.',
['法丝']='法丝:BAAALgAECgUJBQAAAA==.',
['泡饭']='泡饭:BAAALgAECgYJBgAAAA==.',
['注意']='注意你的态度:BAAALgAECgUJBwAAAA==.',
['泰瑞']='泰瑞昂丶白狮:BAAALgADCgEJAQAAAA==.',
['洛克']='洛克塔丶:BAABLgAECn8ZAAICAAcJaRJdZgCzAQACAAcJaRJdZgCzAQAAAA==.洛克萨斯之手:BAAALgAECgQJBAAAAA==.',
['洞蛮']='洞蛮糕兽:BAAALgAECgYJDAAAAA==.',
['活性']='活性益笙菌:BAAALgAECgYJBgAAAA==.',
['流星']='流星风云:BAABLgAFFH8GAAIIAAMJrRlpKAASAQAIAAMJrRlpKAASAQAAAA==.',
['浅酌']='浅酌一梦:BAAALgAECgQJBQAAAA==.',
['浅陌']='浅陌:BAAALgAECgMJAwAAAA==.',
['浓浓']='浓浓的特仑苏:BAACLgAFFH8KAAMUAAQJzw+YCgBBAQAUAAQJzw+YCgBBAQATAAMJsQxLEgDXAAAuAAQKfysAAxQACQlgIcsDAG0DABQACQlgIcsDAG0DABMABgntHixAAKEBAAAA.',
['浩浩']='浩浩君:BAAALgAECgUJDgAAAA==.',
['浮生']='浮生梦日:BAAALgADCgEJAQAAAA==.',
['海洋']='海洋葱:BAABLgAECn8eAAIaAAgJiSKJAwAkAgAaAAgJiSKJAwAkAgAAAA==.',
['深潭']='深潭微澜:BAAALgAECgYJBgAAAA==.',
['清风']='清风徐徐:BAAALgADCgEJAQAAAA==.',
['温柔']='温柔的死磕:BAAALgAECgIJAgAAAA==.',
['满月']='满月丨:BAAALgAECgMJBQAAAA==.',
['潘哒']='潘哒林熊猫:BAABLgAECn8ZAAIWAAgJ4Rh4HgBPAgAWAAgJ4Rh4HgBPAgAAAA==.',
['潘管']='潘管严:BAAALgAECgcJEAAAAA==.',
['灭世']='灭世丶亡爷:BAAALgAFFAIJAgAAAA==.',
['灵兮']='灵兮如云:BAAALgAECgYJBgAAAA==.',
['灵活']='灵活且优雅:BAAALgADCgkJCQAAAA==.',
['灵犀']='灵犀指花满楼:BAAALgADCgEJAQAAAA==.',
['烈日']='烈日行者巨剑:BAAALgADCgMJAwAAAA==.',
['烤土']='烤土豆:BAAALgAECgYJBgAAAA==.',
['热心']='热心网友:BAAALgAECgIJAgABLgAFFAQJBAAHAAAAAA==.',
['無火']='無火的餘灰:BAAALgAECgYJDwAAAA==.',
['無無']='無無聊聊:BAAALgAECgYJCAAAAA==.',
['無路']='無路矢:BAAALgADCgIJAgABLgAFFAIJBAAHAAAAAA==.',
['焦糖']='焦糖奶黄包:BAABLgAECn8VAAIcAAgJXRxDMwBqAgAcAAgJXRxDMwBqAgAAAA==.',
['焰烬']='焰烬:BAAALgADCgUJBQAAAA==.',
['焰诗']='焰诗:BAACLgAFFH8NAAIfAAQJnSOvAQC0AQAfAAQJnSOvAQC0AQAuAAQKfzAAAh8ACQmHJKkAANcDAB8ACQmHJKkAANcDAAAA.焰诗难波碎:BAAALgAFFAIJAgABLgAFFAQJDQAfAJ0jAA==.',
['熊猫']='熊猫人的滋味:BAAALgAECgQJBQAAAA==.',
['熏染']='熏染的坚强:BAAALgAECgcJBwAAAA==.',
['熔岩']='熔岩:BAAALgAECgYJDQAAAA==.',
['爪巴']='爪巴:BAAALgADCgEJAQAAAA==.',
['爬爬']='爬爬会彗星:BAAALgAECgYJBgAAAA==.',
['爱吃']='爱吃番茄炒蛋:BAAALgAECgcJEgAAAA==.爱吃红烧肉:BAAALgADCgMJAwAAAA==.',
['爱耍']='爱耍风头的狼:BAAALgAFFAIJAwAAAA==.',
['爷是']='爷是鹅:BAABLgAECn8VAAMiAAYJJBlmFQC8AQAiAAYJJBlmFQC8AQAjAAEJLQTZGQAmAAAAAA==.',
['版纳']='版纳贵族铁鑫:BAAALgAECggJEAAAAA==.',
['牧字']='牧字头咕咕:BAAALgADCgUJBQAAAA==.',
['牧已']='牧已成舟:BAAALgAECgkJEAAAAA==.',
['物登']='物登明堂:BAACLgAFFH8WAAIKAAYJ+RvqAAAKAgAKAAYJ+RvqAAAKAgAuAAQKfxYAAwoACAljHk0NALICAAoACAljHk0NALICABoAAQk8BACUACIAAAAA.',
['特蕾']='特蕾西娅:BAAALgAECgQJBAAAAA==.',
['狂零']='狂零:BAAALgAECgYJBgAAAA==.',
['狐人']='狐人法力高高:BAAALgAECgYJEQABLgAFFAQJCAAGAN4cAA==.狐人肘击王:BAACLgAFFH8JAAMQAAQJ+BJoCABQAQAQAAQJ+BJoCABQAQARAAEJQAyFFgBSAAAuAAQKfxsAAhAACAnwHwoXAMoCABAACAnwHwoXAMoCAAAA.',
['狗蛋']='狗蛋呀:BAAALgAECgcJDgAAAA==.',
['狡猾']='狡猾的喵星人:BAACLgAFFH8GAAIBAAMJxw8tHADxAAABAAMJxw8tHADxAAAuAAQKfyQAAgEACQl/FrwMANABAAEACQl/FrwMANABAAAA.',
['独行']='独行者:BAABLgAECn8WAAIIAAgJ9RyJCgAjAgAIAAgJ9RyJCgAjAgAAAA==.',
['狱长']='狱长:BAAALgADCgEJAQAAAA==.',
['猫哩']='猫哩个喵:BAACLgAFFH8KAAIKAAQJGhTdCAA/AQAKAAQJGhTdCAA/AQAuAAQKfysAAgoACQnsHlgBANACAAoACQnsHlgBANACAAAA.',
['猫宫']='猫宫又奈:BAAALgAECgQJAwAAAA==.',
['玉树']='玉树樱:BAABLgAFFH8IAAIjAAQJ0BxDAACDAQAjAAQJ0BxDAACDAQAAAA==.',
['玉面']='玉面小肥猪:BAAALgAECgEJAQAAAA==.',
['玛尔']='玛尔伽尼斯:BAAALgAECgIJAgAAAA==.',
['琉璃']='琉璃丶欧皇:BAABLgAECn8VAAMCAAgJIyEyGwDGAgACAAcJJCUyGwDGAgADAAYJDw4cYwDwAAAAAA==.琉璃之人:BAAALgAECgcJCQAAAA==.',
['甜甜']='甜甜禹鱼:BAAALgAECgkJCQAAAA==.',
['生命']='生命火花:BAAALgAECgUJCgAAAA==.',
['生死']='生死玄境:BAAALgAFFAEJAgAAAA==.',
['畞蛳']='畞蛳凵:BAABLgAECn8UAAMPAAgJNQ8zHgCjAQAPAAgJBQwzHgCjAQAOAAcJBA65MwBwAQAAAA==.',
['白月']='白月禾:BAAALgAECgUJCgAAAA==.',
['白露']='白露吟:BAACLgAFFH8FAAIOAAMJbBOXCQDNAAAOAAMJbBOXCQDNAAAuAAQKfxgAAg4ABwkgFwchANoBAA4ABwkgFwchANoBAAAA.',
['皆烬']='皆烬:BAAALgAECgEJAQAAAA==.',
['目中']='目中无人:BAAALgADCgEJAQAAAA==.',
['目无']='目无王法:BAAALgADCgkJCQAAAA==.',
['盾击']='盾击炖鸡切奶:BAABLgAECn8WAAQCAAgJ+BYIbQCjAQACAAcJZBMIbQCjAQAEAAYJaxGsIAACAQADAAQJShT2IACbAAAAAA==.',
['看我']='看我的名字:BAAALgAECgcJEQAAAA==.',
['看毛']='看毛线啊打呀:BAAALgADCgIJAgAAAA==.',
['矢忆']='矢忆丶宝:BAAALgAECgUJDwAAAA==.',
['石头']='石头帅帅:BAAALgAECgEJAQAAAA==.',
['硬玩']='硬玩酒桶:BAAALgAECgYJCAAAAA==.',
['碧海']='碧海星春菜:BAAALgAECgMJAwAAAA==.',
['碳水']='碳水有毒:BAAALgAECgYJDwAAAA==.',
['神厨']='神厨小福瑞:BAACLgAFFH8KAAILAAQJ5yDLBQB3AQALAAQJ5yDLBQB3AQAuAAQKfx0AAgsACAmIJQIGACcDAAsACAmIJQIGACcDAAAA.',
['神圣']='神圣裁决:BAABLgAFFH8HAAICAAIJbyMyGgDRAAACAAIJbyMyGgDRAAAAAA==.',
['神楽']='神楽梓岚:BAAALgAFFAIJBAAAAA==.',
['祥和']='祥和大宗师:BAAALgADCgEJAQAAAA==.',
['秀福']='秀福:BAAALgAECgcJCQAAAA==.',
['稀缺']='稀缺地龙:BAAALgAECgUJCQAAAA==.',
['站直']='站直了别动:BAAALgAECgcJCgAAAA==.',
['笙淅']='笙淅雨落:BAAALgAECgYJEQAAAA==.',
['米特']='米特:BAAALgAFFAcJAQAAAA==.',
['粒粒']='粒粒之:BAAALgAECgEJAgAAAA==.',
['糖醋']='糖醋大萌德:BAAALgAECgcJBwAAAA==.',
['糖门']='糖门灬滚:BAAALgAECgMJAwAAAA==.',
['糚哉']='糚哉大酒神:BAAALgAFFAEJAQAAAA==.',
['紫猎']='紫猎的滋味:BAAALgAECgUJBQAAAA==.',
['紫音']='紫音燈:BAAALgADCgYJBgAAAA==.',
['繁星']='繁星鸭丶:BAAALgAECgYJBQAAAA==.',
['纷纭']='纷纭天下:BAAALgAECgMJBwAAAA==.',
['组织']='组织在召唤我:BAAALgAECgIJAgAAAA==.',
['绔绔']='绔绔:BAAALgAECgQJBQAAAA==.',
['绫波']='绫波丽:BAAALgAECgQJBAAAAA==.',
['维克']='维克多弗兰:BAAALgAECgMJAwAAAA==.',
['羊羊']='羊羊堕落:BAAALgAFFAQJBAAAAA==.',
['美梦']='美梦醒:BAABLgAECn8YAAMXAAkJPB5eBwAkAwAXAAkJgBxeBwAkAwAWAAIJWhh6lwCnAAAAAA==.',
['美露']='美露莘:BAAALgAFFAEJAQAAAA==.',
['群星']='群星之冠:BAAALgAECgYJBgAAAA==.',
['翻皮']='翻皮水:BAAALgADCgYJCwAAAA==.',
['老年']='老年居士:BAACLgAFFH8HAAMOAAMJoRL6CwCjAAAOAAIJdhr6CwCjAAAPAAIJJAR9FQCJAAAuAAQKfxgAAw4ACAm+GWQYABkCAA4ABwkXG2QYABkCAA8AAQlTEAlTAD0AAAAA.',
['老熊']='老熊吉:BAACLgAFFH8JAAMXAAQJSQmdGADJAAAXAAMJWAmdGADJAAAWAAEJGwnEJQBVAAAuAAQKfysABBcACQnWGXsaAFICABcACAmAGHsaAFICABgABQniCwwMAAYBABYABQklFZ4rAOkAAAEuAAUUBgkFABcAJAsA.',
['老阿']='老阿嘤:BAACLgAFFH8KAAILAAQJWyJOBACVAQALAAQJWyJOBACVAQAuAAQKfysAAwsACQmhIVMCAHcDAAsACQmhIVMCAHcDAB0AAQlrD55pAC4AAAAA.',
['老陈']='老陈与十月:BAAALgADCgMJAwAAAA==.',
['肥伦']='肥伦:BAAALgAECgIJAgAAAA==.',
['脆升']='脆升升薯条:BAABLgAECn8pAAIBAAgJZyNZBABsAgABAAgJZyNZBABsAgABLgAECgkJHgAIAG4fAA==.',
['膽小']='膽小:BAABLgAECn8bAAMgAAgJ5ByzCQCnAQAgAAcJ8hizCQCnAQAQAAYJdRpEIQA/AQAAAA==.',
['自演']='自演螺旋方程:BAAALgAECgYJEgAAAA==.',
['艾玟']='艾玟:BAAALgAECgYJCgAAAA==.',
['艾米']='艾米利雅:BAAALgADCgEJAQAAAA==.',
['艾莎']='艾莎:BAAALgAECgkJCQAAAA==.',
['芒椰']='芒椰西米露:BAAALgAECgQJBAAAAA==.',
['芝士']='芝士蛋挞:BAAALgAECgEJAQAAAA==.',
['苍蓝']='苍蓝猛萨:BAAALgAECgEJAQAAAA==.',
['茶喵']='茶喵不吃糖:BAACLgAFFH8VAAMQAAUJbh9kBQBrAQAQAAUJaxxkBQBrAQARAAQJmxXrAwBXAQAuAAQKfyYABBEACAmmJYIGAGYCABEABwn3I4IGAGYCABAABgkKJvs2ADACACAAAQnOJqQfAHQAAAAA.',
['荒芜']='荒芜拉普兰德:BAAALgADCgIJAgABLgAECgYJEgAHAAAAAA==.',
['莞儿']='莞儿睡不醒:BAACLgAFFH8KAAISAAQJQxdGCgBOAQASAAQJQxdGCgBOAQAuAAQKfx8AAhIACQkvIA8BAMUCABIACQkvIA8BAMUCAAAA.',
['莫待']='莫待无花折:BAAALgAECgMJBAAAAA==.',
['菠萝']='菠萝包丶哥哥:BAAALgAFFAUJAgAAAA==.',
['萌新']='萌新不会玩:BAAALgAECgYJBgAAAA==.',
['萌萌']='萌萌哒小可:BAAALgADCgQJBAAAAA==.',
['萝卜']='萝卜侠丨:BAAALgAECgYJBgAAAA==.',
['萨拉']='萨拉塔斯之刃:BAAALgADCgcJCwAAAA==.',
['葬爱']='葬爱丶咩咩:BAAALgAECgcJBwAAAA==.',
['蓝色']='蓝色妖姬:BAAALgAECgQJBgAAAA==.蓝色学者:BAAALgAFFAEJAQAAAA==.蓝色海绵:BAAALgAECgIJAgAAAA==.',
['蘑菇']='蘑菇菌:BAABLgAFFH8FAAMQAAMJTA+1KABkAAAQAAMJKQ+1KABkAAARAAEJvgOvGQBJAAAAAA==.',
['虛空']='虛空引擎:BAAALgAECgIJAgAAAA==.',
['蛋糕']='蛋糕吨吨桶:BAAALgAFFAQJAQAAAA==.',
['蛋臭']='蛋臭臭:BAAALgAECgYJBgAAAA==.',
['蜡笔']='蜡笔小毛新:BAAALgAECgUJBQAAAA==.',
['蟹迪']='蟹迪凯:BAAALgAECgUJBwAAAA==.',
['血羽']='血羽惊弦:BAABLgAECn8eAAIXAAcJVwiWBgAoAQAXAAcJVwiWBgAoAQAAAA==.',
['血色']='血色冰吻:BAAALgAECggJCwAAAA==.',
['血鸟']='血鸟:BAAALgAECgYJBwAAAA==.',
['行走']='行走的可丽饼:BAAALgAECgYJDgAAAA==.',
['西洋']='西洋雪莲:BAAALgADCgQJBAAAAA==.',
['西门']='西门朱玉丶:BAAALgAFFAEJAQAAAA==.',
['要乐']='要乐奈:BAAALgAECgcJBwAAAA==.',
['觉得']='觉得休闲:BAEALgADCgEJAQAAAA==.',
['贝尔']='贝尔库鲁斯:BAAALgAECgYJDAAAAA==.',
['赋丶']='赋丶比兴:BAAALgAECgEJAQAAAA==.',
['超熊']='超熊力能猫:BAAALgADCgUJBQAAAA==.',
['超级']='超级哈气形态:BAAALgADCgcJBwAAAA==.',
['跑滴']='跑滴就是快:BAAALgAECgEJAQAAAA==.',
['车輪']='车輪灬滚滚:BAAALgADCgUJBQAAAA==.',
['软绵']='软绵绵的喵:BAAALgAECgEJAQAAAA==.',
['达斯']='达斯维德:BAAALgAECgYJDAAAAA==.',
['过路']='过路的小鬼:BAAALgAECgIJAwAAAA==.',
['还是']='还是小朋友:BAABLgAECn8VAAICAAYJEx3uQwAYAgACAAYJEx3uQwAYAgAAAA==.还是疯子:BAAALgAECgYJCAAAAA==.',
['这只']='这只是个苍蝇:BAAALgAECgcJCwAAAA==.',
['逝水']='逝水如斯丶:BAAALgAECgcJBwAAAA==.',
['逝烟']='逝烟:BAAALgAFFAUJBAAAAA==.',
['道奇']='道奇战斧:BAAALgAECgIJAwAAAA==.',
['遗憾']='遗憾之泪:BAAALgAECgEJAQAAAA==.',
['那盛']='那盛夏丶:BAAALgAFFAIJAgAAAA==.',
['邪能']='邪能领主:BAACLgAFFH8JAAIQAAMJhBF0IQD+AAAQAAMJhBF0IQD+AAAuAAQKfxYAAhAABwmmIDowAEwCABAABwmmIDowAEwCAAAA.',
['酒仙']='酒仙小岑:BAAALgAECgYJCQAAAA==.',
['醉言']='醉言万斗烟霞:BAAALgADCgIJAgAAAA==.',
['醉酒']='醉酒佳酿:BAAALgAECgEJAQAAAA==.',
['野格']='野格加冰:BAAALgAECgMJAwAAAA==.',
['野生']='野生小米妮:BAAALgADCgUJBQAAAA==.',
['鏴絔']='鏴絔此彼身轉:BAAALgADCgEJAQAAAA==.',
['钢筋']='钢筋铁骨:BAAALgADCgcJBwAAAA==.',
['钢铁']='钢铁侠:BAAALgADCgIJAgAAAA==.',
['铁牛']='铁牛牛肉面:BAAALgADCgEJAQAAAA==.',
['铁腿']='铁腿水上漂:BAAALgAECgMJAwAAAA==.',
['长诗']='长诗佐酒:BAAALgADCgQJBAAAAA==.',
['阿么']='阿么:BAAALgAECgYJCwAAAA==.',
['阿依']='阿依莫德:BAAALgAECgIJAgAAAA==.',
['阿塔']='阿塔尼斯:BAACLgAFFH8IAAIDAAUJowp4BgBwAQADAAUJowp4BgBwAQAuAAQKfxgAAgMACAk9HcgSAHwCAAMACAk9HcgSAHwCAAAA.',
['阿布']='阿布糗:BAAALgAECgEJAQAAAA==.',
['阿月']='阿月浑子:BAAALgAECgEJAQAAAA==.',
['阿珺']='阿珺:BAAALgADCgkJCQAAAA==.',
['阿锴']='阿锴好为人师:BAAALgAECgEJAQAAAA==.',
['陈千']='陈千语:BAAALgAECgQJCAAAAA==.',
['陌上']='陌上寂静雪:BAABLgAECn8dAAMOAAgJ1AxzLACVAQAOAAgJ1AxzLACVAQAPAAQJiQCHVAA4AAAAAA==.',
['雨落']='雨落凡尘:BAAALgAECgIJAgAAAA==.',
['雪歌']='雪歌:BAAALgAECgYJCgAAAA==.',
['雪糕']='雪糕历险记:BAABLgAFFH8HAAIaAAIJ8AeFDQCSAAAaAAIJ8AeFDQCSAAAAAA==.雪糕求生记:BAAALgADCgkJCQAAAA==.',
['零耗']='零耗:BAAALgAECgIJAgAAAA==.',
['零肆']='零肆贰壹:BAAALgAECgQJCgAAAA==.',
['需要']='需要光吗少年:BAAALgAECgEJAQAAAA==.',
['霜恸']='霜恸血蹄:BAABLgAECn8UAAMVAAYJ1xJGTAB1AQAVAAYJ1xJGTAB1AQAeAAIJPAetEwBeAAAAAA==.',
['霜灬']='霜灬降:BAAALgAECgIJAgAAAA==.',
['青岚']='青岚皓月:BAAALgADCgkJCgAAAA==.',
['青火']='青火:BAAALgAECgEJAQAAAA==.',
['静水']='静水流深丶:BAAALgADCgEJAQAAAA==.',
['颤抖']='颤抖三头身:BAAALgAECgQJBAAAAA==.',
['风在']='风在起时:BAABLgAECn8WAAIPAAcJyxULHgCkAQAPAAcJyxULHgCkAQAAAA==.',
['风城']='风城玫瑰:BAACLgAFFH8HAAICAAQJ6RhuCQBiAQACAAQJ6RhuCQBiAQAuAAQKfxkAAgIACAmZG2svAGUCAAIACAmZG2svAGUCAAAA.',
['风暴']='风暴烈酒血沸:BAAALgADCgMJAwAAAA==.',
['飘絮']='飘絮:BAABLgAFFH8GAAIIAAIJCwYJJwCdAAAIAAIJCwYJJwCdAAAAAA==.',
['飞天']='飞天大喷菇:BAAALgAECgYJBwAAAA==.飞天小喷菇:BAACLgAFFH8UAAIBAAUJBCXPAgAaAgABAAUJBCXPAgAaAgAuAAQKfx8AAgEACAnaJeIFAGcDAAEACAnaJeIFAGcDAAAA.',
['飞奔']='飞奔的武僧:BAAALgAECgMJAwAAAA==.',
['飞飛']='飞飛飝丶:BAAALgAECgYJDQAAAA==.',
['马维']='马维:BAAALgADCgEJAQAAAA==.',
['骡马']='骡马跪族:BAAALgAECgcJAQAAAA==.',
['高斯']='高斯奥特曼:BAAALgAFFAIJAwAAAA==.',
['高速']='高速上的石头:BAAALgAECgQJBAAAAA==.',
['魏无']='魏无羡:BAAALgAECgcJDgAAAA==.',
['鲸鲵']='鲸鲵:BAAALgAECgcJDAAAAA==.',
['鶯鴛']='鶯鴛:BAAALgAECgcJDQAAAA==.',
['鹿忘']='鹿忘忧:BAAALgAFFAIJAgAAAA==.',
['麓战']='麓战:BAAALgAECgUJCAAAAA==.',
['黑夜']='黑夜学派:BAAALgAECgEJAQAAAA==.',
['黑川']='黑川莤:BAAALgAECgcJBAAAAA==.',
['黑帝']='黑帝斯:BAABLgAECn8aAAIcAAgJ3Bi+QAA1AgAcAAgJ3Bi+QAA1AgAAAA==.',
['黑心']='黑心喵:BAABLgAECn8ZAAILAAgJlxjcEwBxAgALAAgJlxjcEwBxAgABLgAFFAUJFQAMAJ8WAA==.',
['黑旗']='黑旗:BAAALgAECgEJAQAAAA==.',
['黑色']='黑色的小幽默:BAAALgAFFAQJBAAAAA==.',
['鼠鼠']='鼠鼠:BAAALgAECgkJDwAAAA==.',
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
