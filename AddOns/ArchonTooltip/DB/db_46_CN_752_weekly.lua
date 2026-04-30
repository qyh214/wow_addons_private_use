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

local lookup = {'DemonHunter-Devourer','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Monk-Brewmaster','Shaman-Restoration','Shaman-Elemental','Evoker-Preservation','Priest-Holy','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Frost','Priest-Shadow','Druid-Balance','Mage-Frost','Paladin-Holy','Warrior-Arms','Warrior-Fury','Paladin-Protection','Paladin-Retribution','Warrior-Protection','Warlock-Demonology','Druid-Feral','Priest-Discipline','Evoker-Augmentation','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Priest-Healing','Unknown-Unknown','DemonHunter-Vengeance','Monk-Mistweaver','DeathKnight-Blood','Hunter-Survival','Druid-Restoration','Warlock-Affliction','Evoker-Devastation',}
local provider = {region='CN',realm='燃烧平原',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aallin:BAAALgAECgIJAgAAAA==.',
Az='Azzinoth:BAABLgAECn8UAAMBAAYJeA75dwA/AQABAAYJeA75dwA/AQACAAMJ+AuOVQCRAAAAAA==.',
Ca='Caliburian:BAAALgADCgcJCwAAAA==.',
Cu='Cuchulainn:BAAALgAECgcJBwAAAA==.',
Da='Darkkeeper:BAAALgAECgEJAwAAAA==.',
Di='Dimensius:BAACLgAFFH8FAAMDAAMJGwsoEwCzAAADAAIJSAwoEwCzAAAEAAEJwAjtBgBVAAAuAAQKfyIAAwMACAmyI1INAMYCAAMABwnVI1INAMYCAAQAAQniIs0YAGgAAAAA.',
Dr='Drakeacht:BAABLgAFFH8JAAIFAAYJ8gt1DwAHAQAFAAYJ8gt1DwAHAQAAAA==.Drakefuenf:BAAALgAFFAQJBAAAAA==.Drakehund:BAAALgAFFAQJBAAAAA==.Drakemmonk:BAAALgAFFAUJBAAAAA==.Drakemonk:BAABLgAFFH8IAAIFAAQJNRIgCwAuAQAFAAQJNRIgCwAuAQAAAA==.',
Eu='Eugenpoder:BAACLgAFFH8IAAMGAAMJiR3eDAANAQAGAAMJiR3eDAANAQAHAAEJBxriGwBSAAAuAAQKfxcAAwYACAloIsgIAOoCAAYACAloIsgIAOoCAAcAAglzH7djALQAAAAA.',
Fo='Forgreen:BAACLgAFFH8MAAIIAAUJ5xw5AwDXAQAIAAUJ5xw5AwDXAQAuAAQKfxQAAggABglIJVsLAIACAAgABglIJVsLAIACAAAA.',
Go='Golaniyule:BAAALgAECgUJBwAAAA==.',
Gu='Gundam:BAAALgAECgUJBQAAAA==.Guru:BAAALgAECgEJAQAAAA==.',
Ha='Hazelwarlock:BAAALgAECgYJCwAAAA==.',
He='Heydream:BAAALgAECggJBgABLgAFFAYJFwAJANsRAA==.',
Hi='Hippo:BAAALgADCgUJAgAAAA==.',
Ic='Icedstone:BAAALgAECgEJAQAAAA==.Icyzhang:BAAALgAECgMJAwAAAA==.',
Ja='Jackpotbobo:BAABLgAECn8cAAIKAAgJLCEdCgDWAgAKAAgJLCEdCgDWAgAAAA==.',
Ko='Kobeout:BAAALgAECgEJAQAAAA==.',
Kw='Kw:BAAALgAECgEJAgAAAA==.',
Ly='Lybfisherman:BAACLgAFFH8GAAIGAAMJfRkQFgCmAAAGAAMJfRkQFgCmAAAuAAQKfxsAAgYABgksJoEPAJwCAAYABgksJoEPAJwCAAAA.',
Ma='Maverick:BAABLgAECn8dAAMLAAgJXhyuLwB5AgALAAgJXhyuLwB5AgAMAAEJOwmQGAAtAAAAAA==.',
Mo='Mona:BAACLgAFFH8TAAIJAAUJaB/xAADXAQAJAAUJaB/xAADXAQAuAAQKfxsAAgkACAn1Fv4YABQCAAkACAn1Fv4YABQCAAAA.',
Mu='Muamuamua:BAAALgAECgIJAgAAAA==.Muista:BAAALgADCgcJBwAAAA==.',
No='Norna:BAABLgAECn8hAAIBAAkJRB5yCwAmAwABAAkJRB5yCwAmAwAAAA==.',
On='Onix:BAACLgAFFH8FAAINAAMJYRW1CgAJAQANAAMJYRW1CgAJAQAuAAQKfyAAAw0ACAkMIqkGACADAA0ACAkMIqkGACADAAkAAgmqGmVmAJMAAAAA.',
Or='Ormsby:BAAALgAECgQJAgAAAA==.',
Pe='Pepsiamber:BAAALgAECgkJDgABLgAFFAYJDgAOAP8PAA==.',
Pi='Piinapple:BAAALgAECgcJBwAAAA==.',
Py='Pyreus:BAAALgAECgMJAwABLgAECgYJFAABAHgOAA==.',
Ra='Rashford:BAAALgAECgcJBwAAAA==.',
Re='Reira:BAAALgAECgcJDgAAAA==.',
Sh='Shadowwithme:BAAALgADCgEJAQAAAA==.',
Si='Silverlol:BAAALgAECgcJBwAAAA==.',
Su='Sunpayus:BAAALgAECgEJAgAAAA==.',
Td='Tdryad:BAAALgAECgYJCwAAAA==.',
Un='Underground:BAABLgAECn8YAAIPAAkJriF+BgCdAwAPAAkJriF+BgCdAwAAAA==.',
Vu='Vurtney:BAAALgAECgEJAQAAAA==.',
We='Weatherspoon:BAAALgADCgEJAQAAAA==.',
Wi='Will:BAAALgAECgMJAwAAAA==.',
Xd='Xdeath:BAAALgADCgMJAwAAAA==.',
Zi='Zimomobear:BAAALgAECgQJAwAAAA==.',
['一个']='一个光头突然:BAAALgAECgEJAgAAAA==.',
['一只']='一只卷毛:BAAALgADCgUJBQAAAA==.',
['一头']='一头二臂:BAAALgAECgEJAgAAAA==.',
['一空']='一空心一:BAAALgAECgUJBQAAAA==.',
['一箭']='一箭一箭钟情:BAAALgADCgMJAwAAAA==.',
['一脸']='一脸落寞:BAAALgAECgQJBwAAAA==.',
['七月']='七月上:BAAALgAECgYJDAAAAA==.',
['丄締']='丄締寵兒:BAAALgAECgQJBAAAAA==.',
['三千']='三千阳春:BAACLgAFFH8QAAIKAAUJjyLWAQCtAQAKAAUJjyLWAQCtAQAuAAQKfygAAgoACAmmJH8DAFkDAAoACAmmJH8DAFkDAAAA.',
['三林']='三林阿祖:BAAALgADCgEJAQAAAA==.',
['三鹿']='三鹿小奶牛:BAAALgADCgUJAgAAAA==.',
['上号']='上号就掉线:BAAALgAECgQJBAAAAA==.',
['上海']='上海张学友:BAAALgADCgEJAQAAAA==.',
['不会']='不会起门:BAAALgAFFAIJBAAAAA==.',
['不变']='不变的风骚:BAAALgAFFAEJAQAAAA==.',
['不得']='不得不潇洒:BAAALgAECgYJDgAAAA==.',
['丘卡']='丘卡皮:BAAALgAECgQJBgAAAA==.',
['丨你']='丨你瞅啥丨:BAAALgAECgEJAwAAAA==.',
['丨全']='丨全能王丨:BAAALgAECgYJBgAAAA==.',
['丨夜']='丨夜修罗丨:BAAALgAECgUJBwAAAA==.',
['丨飘']='丨飘雪丨:BAABLgAFFH8OAAIQAAQJtSSiAwCsAQAQAAQJtSSiAwCsAQAAAA==.',
['丨餹']='丨餹門術屍丨:BAAALgAECgcJBwAAAA==.',
['中单']='中单亚索:BAAALgAFFAIJAwAAAA==.',
['丶冷']='丶冷冷殿下:BAAALgAECgcJBwAAAA==.',
['丶天']='丶天瑜:BAAALgAECgcJCwAAAA==.',
['丶珊']='丶珊珊丶:BAAALgAECgcJBwAAAA==.',
['丶阿']='丶阿莫西林:BAAALgAECgUJCwAAAA==.',
['丶饕']='丶饕餮:BAAALgADCgEJAQAAAA==.',
['丶黯']='丶黯语丶:BAAALgAECgMJBAAAAA==.',
['丿格']='丿格瑞拉:BAAALgAECgEJAgAAAA==.',
['乄輕']='乄輕風:BAAALgAECgYJCAAAAA==.',
['乌鸦']='乌鸦坐飞叽:BAAALgAECgQJBQAAAA==.',
['也曾']='也曾孤单:BAAALgADCgEJAQAAAA==.',
['书逝']='书逝:BAAALgADCgEJAQAAAA==.',
['乱码']='乱码不可用:BAAALgAECgQJCQAAAA==.',
['云翳']='云翳障空:BAAALgAECgcJBwAAAA==.',
['五光']='五光十色:BAAALgAFFAEJAQAAAA==.',
['今汐']='今汐长离:BAAALgAECgEJAQAAAA==.',
['从不']='从不吃洋葱:BAAALgAECgMJAwAAAA==.',
['从零']='从零起步:BAAALgAFFAIJAgAAAA==.',
['仙草']='仙草猫猫:BAAALgADCgcJEwAAAA==.',
['伊利']='伊利単丶怒风:BAAALgAECgYJCwAAAA==.',
['伯牙']='伯牙绝弦丶懿:BAAALgADCgcJDAAAAA==.',
['伴青']='伴青灯:BAAALgAECgMJAwAAAA==.',
['低语']='低语咆哮:BAAALgAECgQJBQAAAA==.',
['低调']='低调的月影:BAAALgAECgEJAQAAAA==.',
['佩古']='佩古奇:BAAALgADCgUJBQAAAA==.',
['佳斯']='佳斯米:BAAALgAECgIJBAAAAA==.',
['侵略']='侵略之殇:BAAALgAECgYJBwAAAA==.',
['倚星']='倚星折月:BAAALgAECgUJBQAAAA==.',
['假嘟']='假嘟嘟:BAAALgAECgEJAgAAAA==.',
['健硕']='健硕的麺包:BAAALgAFFAIJAgAAAA==.',
['傲苍']='傲苍穹:BAAALgAECgEJAQAAAA==.',
['傲血']='傲血魔圣:BAAALgAECgEJAQAAAA==.',
['元素']='元素精华:BAAALgAECgYJCgAAAA==.',
['先打']='先打我队友丶:BAAALgAECgQJBAAAAA==.',
['光头']='光头一团团:BAAALgAECgYJBgAAAA==.',
['克拉']='克拉夫特:BAAALgAECgkJBAAAAA==.',
['八刀']='八刀:BAAALgAECgMJAwAAAA==.',
['六月']='六月丶羁绊:BAABLgAECn8iAAIJAAgJ6RNnIADfAQAJAAgJ6RNnIADfAQAAAA==.',
['关欣']='关欣:BAAALgADCgYJBgAAAA==.',
['养花']='养花:BAAALgAECgEJAQAAAA==.',
['冇灬']='冇灬三炮:BAAALgAECgUJBgAAAA==.',
['冥丶']='冥丶:BAAALgAECgYJDwAAAA==.',
['冫中']='冫中钅峯:BAABLgAECn8WAAMRAAcJ8SF0DADZAQARAAUJ5iB0DADZAQASAAUJxiLQNQDRAQAAAA==.',
['冬季']='冬季大三哥:BAAALgAECgYJCgAAAA==.',
['冰冰']='冰冰的小萌新:BAAALgAFFAMJAwAAAA==.',
['冰圣']='冰圣:BAAALgAECgYJCAAAAA==.',
['冷眼']='冷眼玛吉:BAAALgAFFAIJAgAAAA==.',
['冻空']='冻空粉雪:BAAALgADCgQJBAAAAA==.',
['凶猛']='凶猛的小老虎:BAAALgAECgcJAQAAAA==.',
['凹潤']='凹潤菊:BAAALgAECgYJCwAAAA==.',
['刈之']='刈之秋:BAABLgAFFH8PAAIHAAQJqhz3BwBbAQAHAAQJqhz3BwBbAQAAAA==.',
['刚交']='刚交滴朋友:BAACLgAFFH8FAAITAAIJUQ5jBQBvAAATAAIJUQ5jBQBvAAAuAAQKfx8AAxMACQnVDXUWAGwBABMABwkrEHUWAGwBABQAAwmOBHYPAXcAAAEuAAUUAwkHABMAXQUA.',
['努力']='努力与汗水:BAACLgAFFH8FAAMSAAMJih00GQCkAAASAAIJgww0GQCkAAARAAMJJhwAAAAAAAAuAAQKfxsABBEACAlZGqoBAPABABEACAnTGKoBAPABABIABQnjFjFTAF0BABUAAQmjEMxEADkAAAAA.',
['勿一']='勿一鸣:BAAALgAFFAEJAQAAAA==.',
['北落']='北落师门的爱:BAACLgAFFH8TAAIQAAYJFB+cAABCAgAQAAYJFB+cAABCAgAuAAQKfyQAAxAACQnJHgAOAKgCABAACAkmHwAOAKgCABQAAQmzFPYuAUQAAAAA.',
['十一']='十一乄:BAAALgAECgQJBAAAAA==.十一只术:BAABLgAFFH8LAAIWAAUJNhf9BABlAQAWAAUJNhf9BABlAQAAAA==.',
['十三']='十三乄:BAAALgAECgUJBQAAAA==.十三只术:BAABLgAFFH8HAAIWAAQJwRXJEABbAQAWAAQJwRXJEABbAQAAAA==.',
['十二']='十二只术:BAABLgAFFH8FAAIWAAUJBxVuBQBgAQAWAAUJBxVuBQBgAQAAAA==.',
['十四']='十四只术:BAAALgAECgcJBwAAAA==.',
['十指']='十指穿弹:BAAALgAECgYJCAAAAA==.',
['千门']='千门自由鸟:BAAALgAECgMJAwAAAA==.',
['半岛']='半岛的太阳:BAAALgADCgEJAgAAAA==.',
['半月']='半月弦:BAAALgAECgQJBAAAAA==.',
['半梦']='半梦半醒:BAAALgAFFAMJAwAAAA==.',
['单无']='单无雙:BAAALgAECgcJEwAAAA==.',
['南迦']='南迦忆沧海:BAAALgADCgMJAwAAAA==.',
['占戈']='占戈礻申:BAAALgADCgYJBgAAAA==.',
['卡路']='卡路里燃烧者:BAAALgAFFAQJBAAAAA==.',
['厚乳']='厚乳拿铁丶轩:BAAALgAECgYJBgAAAA==.',
['双叶']='双叶理央:BAACLgAFFH8MAAIXAAUJ0hidAADDAQAXAAUJ0hidAADDAQAuAAQKfyIAAxcACQlJIiIBAG0DABcACQk1IiIBAG0DAA4AAgmwFaZjAJIAAAAA.',
['叛逆']='叛逆点点:BAABLgAECn8cAAIPAAgJ4BzkNQCcAgAPAAgJ4BzkNQCcAgAAAA==.',
['古夫']='古夫的小姨子:BAAALgAECgMJAwAAAA==.',
['叨乐']='叨乐儿:BAAALgAECgQJBAAAAA==.',
['可颂']='可颂:BAAALgAECgQJBgAAAA==.',
['史蒂']='史蒂芬丶强尼:BAAALgAECgcJBwAAAA==.',
['叶底']='叶底藏花:BAAALgAFFAIJBAAAAA==.',
['吉米']='吉米丶:BAAALgAECgYJEAAAAA==.',
['吉良']='吉良吉银:BAAALgADCgMJAwAAAA==.',
['同仁']='同仁堂:BAAALgAECgMJAwAAAA==.',
['名字']='名字牛的很:BAAALgAECgQJBAAAAA==.名字矮的很:BAAALgAECgEJAwAAAA==.',
['吧唧']='吧唧大狂风:BAAALgAECgQJBAAAAA==.',
['呆呆']='呆呆的眼色:BAAALgADCgUJBQAAAA==.',
['呆萌']='呆萌丶熊寶寶:BAAALgAECgYJDwAAAA==.呆萌丶牪寶寶:BAAALgAECgYJDwAAAA==.',
['呱里']='呱里呱气呱唧:BAAALgAECgQJBwAAAA==.',
['咖喱']='咖喱牛腩饭:BAAALgADCgYJCQAAAA==.咖喱糊弄学:BAAALgAECgEJAQAAAA==.',
['咘叮']='咘叮灬熊寶寶:BAAALgAECgEJAQAAAA==.',
['咸鱼']='咸鱼很闲:BAAALgAECgkJAQAAAA==.',
['哔哔']='哔哔拉布:BAAALgAECgUJBgAAAA==.',
['啊哈']='啊哈嘿额:BAAALgAECgEJAQAAAA==.',
['啵啵']='啵啵侠:BAACLgAFFH8KAAQNAAQJMBXRCgAHAQANAAQJMBXRCgAHAQAYAAMJsAhCDwDaAAAJAAEJSgsoFgA9AAAuAAQKfyEAAw0ABwmIHVkUAE0CAA0ABwmIHVkUAE0CABgABwnfHEAFALoBAAAA.',
['喜帖']='喜帖大师:BAAALgADCgYJBgAAAA==.',
['喜羊']='喜羊羊歪歪:BAAALgAECgYJDAAAAA==.',
['嗜血']='嗜血的麺包:BAAALgAECgIJAgAAAA==.',
['嘎几']='嘎几窝庞臭:BAAALgAFFAEJAQAAAA==.',
['四辰']='四辰丶:BAAALgAECgEJAQAAAA==.',
['图拉']='图拉牛:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光大表哥:BAAALgAECgIJAgAAAA==.圣光救我:BAECLgAFFH8LAAMQAAQJhxdqDAAWAQAQAAQJhxdqDAAWAQAUAAIJtAkmNQBNAAAuAAQKfyUAAxAACAmkHw4ZAEoCABAACAmkHw4ZAEoCABQACAnbFHZNAPoBAAAA.圣光老相好:BAAALgADCgEJAQAAAA==.圣光露比:BAAALgAECgMJAwAAAA==.',
['在爆']='在爆发别逼逼:BAABLgAFFH8GAAIQAAIJ+iJgEQDGAAAQAAIJ+iJgEQDGAAAAAA==.',
['地之']='地之逐日者:BAAALgAECgUJCgAAAA==.',
['坠星']='坠星净浊影丶:BAAALgADCgEJAQAAAA==.',
['塔沃']='塔沃:BAAALgAECgYJCAAAAA==.',
['墨匠']='墨匠:BAAALgAECgYJBgAAAA==.',
['壹刃']='壹刃:BAAALgAECgEJAQAAAA==.',
['夏夜']='夏夜漪:BAACLgAFFH8FAAIGAAMJ0iSoBwBLAQAGAAMJ0iSoBwBLAQAuAAQKfxwAAwYACAm6IGoHAP0CAAYACAm6IGoHAP0CAAcABAk+B+BqAJcAAAAA.夏夜雨:BAAALgAECgQJBAAAAA==.',
['夏季']='夏季哀木涕:BAAALgAECgYJBwAAAA==.夏季胖熊猫:BAAALgAECgcJCQAAAA==.',
['夏末']='夏末沫之秋:BAAALgADCgEJAQAAAA==.',
['夜丶']='夜丶雨:BAAALgADCgEJAQAAAA==.',
['夜之']='夜之之:BAAALgAECgkJAQABLgAFFAUJEAAWAOAaAA==.',
['夜半']='夜半淋淋雨:BAAALgAECgEJAQAAAA==.',
['夜牧']='夜牧歌:BAAALgAFFAQJAwAAAA==.',
['大力']='大力菠菜:BAAALgAECgMJBAAAAA==.',
['大将']='大将军管家:BAAALgAECgUJBQAAAA==.',
['大德']='大德王子:BAAALgADCgYJBgAAAA==.',
['大树']='大树菠萝丶:BAAALgAFFAEJAQAAAA==.',
['大福']='大福星:BAABLgAFFH8JAAMZAAQJChQKCwBGAQAZAAQJChQKCwBGAQAIAAIJRQf/BwCJAAAAAA==.',
['大脸']='大脸控:BAAALgAFFAIJBAAAAA==.',
['大花']='大花来喽:BAAALgAECgEJAQAAAA==.',
['大苹']='大苹果呀:BAAALgAECgEJAQAAAA==.',
['天蚕']='天蚕土豆泥:BAAALgADCgUJBQAAAA==.',
['天问']='天问:BAAALgADCgYJBgAAAA==.',
['天雨']='天雨曼殊莎:BAAALgAECgMJAwAAAA==.',
['奶不']='奶不动人:BAAALgAFFAEJAQAAAA==.',
['奶你']='奶你没道理:BAAALgAECgEJAgAAAA==.',
['奶凶']='奶凶奶凶:BAAALgAECgQJAwAAAA==.',
['奶昔']='奶昔公主:BAABLgAFFH8FAAMaAAIJAw2+JQBRAAAaAAEJaQ6+JQBRAAAbAAEJnQsfKQBPAAAAAA==.',
['奶油']='奶油蛋卷:BAAALgAFFAEJAQAAAA==.',
['奶牛']='奶牛走前面:BAAALgAFFAEJAQAAAA==.',
['好哥']='好哥哥:BAAALgAECgQJBAAAAA==.',
['好运']='好运哥:BAAALgAECgYJBwAAAA==.',
['妖气']='妖气妖气山:BAAALgAECgQJBAAAAA==.',
['季秋']='季秋桐:BAAALgAECgUJDgAAAA==.',
['宁静']='宁静的小浣熊:BAAALgAECgkJBgAAAA==.',
['安乐']='安乐冈花火:BAAALgAFFAEJAgAAAA==.',
['安度']='安度因李四:BAAALgAECgYJEAAAAA==.',
['容朕']='容朕三撕:BAAALgAFFAUJAQAAAA==.',
['富贵']='富贵的小宝贝:BAAALgAECgIJAQAAAA==.',
['寒灯']='寒灯:BAAALgAFFAIJAgABLgAFFAUJEAAKAI8iAA==.',
['寒狱']='寒狱灬封天:BAAALgAECgQJBgAAAA==.',
['寒露']='寒露大三哥:BAAALgAECgQJBQAAAA==.',
['寒風']='寒風飄散:BAAALgAECgQJAwAAAA==.',
['小学']='小学生杀手:BAAALgAECgMJAwAAAA==.',
['小小']='小小熙:BAAALgAECgEJAQAAAA==.',
['小强']='小强小强:BAAALgAECgMJBAAAAA==.',
['小松']='小松:BAABLgAFFH8GAAMSAAUJag2hJQBHAAASAAEJ9gKhJQBHAAAVAAUJag0AAAAAAAAAAA==.',
['小楼']='小楼烟雨:BAAALgAECgEJAgAAAA==.',
['小洋']='小洋哥:BAABLgAECn8XAAMcAAYJtSJCFgCYAQAcAAQJnyNCFgCYAQAWAAQJsRz0lQAsAQAAAA==.小洋马:BAAALgADCgYJBgAAAA==.',
['小熊']='小熊的啤酒肚:BAAALgAFFAUJBAABLgAFFAUJBQAdAH4PAA==.',
['小虎']='小虎爷:BAAALgAECgEJAQAAAA==.小虎爺:BAAALgAECgYJBgAAAA==.',
['小锦']='小锦虎:BAAALgAECgcJAgAAAA==.',
['就会']='就会咕咕叫:BAAALgAECgcJEgAAAA==.',
['就差']='就差一丢丢儿:BAABLgAFFH8IAAMMAAQJuhC7AABRAQAMAAQJOg27AABRAQALAAMJdA4LKwDuAAAAAA==.',
['就是']='就是纠结:BAAALgAECgMJBAAAAA==.',
['就问']='就问你麻布麻:BAABLgAECn8XAAIGAAkJ+ReRFABxAgAGAAkJ+ReRFABxAgAAAA==.',
['尼察']='尼察德泰滕:BAAALgAECgEJAQAAAA==.',
['屁桃']='屁桃没有腿:BAAALgAECgUJCQAAAA==.',
['山川']='山川风月:BAAALgAECgkJCwAAAA==.',
['布莱']='布莱克曼巴:BAAALgAECgEJAQAAAA==.布莱克科里昂:BAAALgAFFAEJAQAAAA==.',
['布靁']='布靁斯塔:BAAALgAFFAEJAQAAAA==.',
['布鲁']='布鲁大人好帅:BAAALgAECgUJBQAAAA==.',
['希美']='希美媚的情人:BAAALgAFFAIJBAAAAA==.',
['幸存']='幸存者丶如你:BAAALgAECgYJDAAAAA==.',
['幸运']='幸运青:BAAALgAECgEJAQAAAA==.',
['幼儿']='幼儿园布布雷:BAAALgAECgYJBgAAAA==.',
['幽瞳']='幽瞳丶:BAAALgAECgkJCQAAAA==.',
['张有']='张有财:BAAALgADCgMJAwABLgAFFAQJBAAeAAAAAA==.',
['弥雾']='弥雾理纱丶:BAAALgAECgQJBAAAAA==.',
['强哥']='强哥的奶霸:BAAALgAFFAIJAgAAAA==.',
['强大']='强大的物种:BAAALgAFFAIJAgAAAA==.',
['强袭']='强袭自由:BAAALgAECgYJCQAAAA==.',
['德智']='德智體美:BAAALgAFFAUJAwABLgAFFAUJBQAdAH4PAA==.',
['忘忧']='忘忧候:BAAALgAECgYJBgAAAA==.',
['怎么']='怎么办吖:BAAALgAFFAYJAwAAAA==.',
['怒放']='怒放的烟花:BAAALgAECgUJCQAAAA==.',
['怪强']='怪强你先上:BAAALgAECgEJAQAAAA==.',
['恋风']='恋风恋歌:BAAALgAECggJEwAAAA==.',
['恐龙']='恐龙扛狼:BAAALgAFFAQJBAAAAA==.',
['恒河']='恒河之沙:BAAALgAECgYJDAAAAA==.',
['恩賜']='恩賜:BAACLgAFFH8IAAIQAAQJFCGDDQACAQAQAAQJFCGDDQACAQAuAAQKfxUAAhAABgkOIoUeACMCABAABgkOIoUeACMCAAAA.',
['恶魔']='恶魔人生:BAAALgAECgUJCAAAAA==.恶魔如何:BAAALgAECgYJBgAAAA==.',
['恺大']='恺大师:BAAALgADCgYJBgAAAA==.',
['悲哀']='悲哀天使:BAAALgADCgEJAQAAAA==.',
['惊雪']='惊雪:BAAALgAECgEJAQAAAA==.',
['惑昕']='惑昕之欣:BAABLgAFFH8IAAMYAAMJHg2ADgDlAAAYAAMJHg2ADgDlAAAJAAEJPglwFgA8AAAAAA==.',
['愤怒']='愤怒的高压锅:BAAALgAECgUJBQAAAA==.',
['慕容']='慕容烟雨:BAAALgAECgUJBAAAAA==.',
['憋着']='憋着呼吸:BAAALgAECgcJDAAAAA==.',
['懵新']='懵新:BAAALgAECgIJAgAAAA==.',
['我怕']='我怕透心凉:BAAALgAECgEJAgAAAA==.',
['我是']='我是百变法王:BAAALgAECgMJAwAAAA==.',
['我来']='我来打输出啦:BAAALgAFFAIJAgAAAA==.',
['我的']='我的尾巴呢:BAAALgADCgUJBQAAAA==.',
['我里']='我里奥斯:BAAALgAECgQJBQAAAA==.',
['战五']='战五:BAAALgAFFAIJAwAAAA==.',
['战日']='战日天:BAAALgAECgMJAwAAAA==.',
['战鸽']='战鸽氏族:BAAALgAECgYJBwAAAA==.',
['手写']='手写的从前:BAAALgAFFAEJAQAAAA==.',
['扶瑶']='扶瑶:BAAALgADCgEJAQAAAA==.',
['拂衣']='拂衣:BAAALgAECgIJAgAAAA==.',
['拉丨']='拉丨法:BAAALgAECgMJBQAAAA==.',
['拉塔']='拉塔恩丶:BAAALgADCgYJBgAAAA==.',
['挠挠']='挠挠痒痒:BAAALgAECgYJBgAAAA==.',
['搞不']='搞不懂:BAAALgADCgMJAwAAAA==.',
['摸摸']='摸摸小獠牙:BAABLgAECn8aAAMGAAgJnR/GCQDcAgAGAAgJnR/GCQDcAgAHAAQJaAqpaQCcAAAAAA==.',
['攻强']='攻强卷轴丶:BAAALgADCgEJAQAAAA==.',
['斯巴']='斯巴达国钟:BAAALgAECgYJCQAAAA==.',
['旋律']='旋律德:BAAALgAFFAEJAQAAAA==.',
['旋转']='旋转丶木马:BAABLgAECn8iAAQfAAgJdxt4AwCbAgAfAAgJdxt4AwCbAgABAAEJhwgY3gA0AAACAAEJAACVdwAtAAAAAA==.',
['无人']='无人能敌男:BAABLgAFFH8JAAIPAAMJPh8rKgAMAQAPAAMJPh8rKgAMAQAAAA==.',
['无心']='无心恋花:BAAALgAECgYJBwAAAA==.',
['无情']='无情浪子:BAACLgAFFH8FAAIBAAMJIgo9HgDkAAABAAMJIgo9HgDkAAAuAAQKfyIAAgEACAlbGCEvAD8CAAEACAlbGCEvAD8CAAAA.',
['无所']='无所不能:BAAALgAFFAIJBAAAAA==.',
['无敌']='无敌嘉炉石:BAAALgADCgYJBgAAAA==.',
['无级']='无级别限制:BAABLgAFFH8OAAIPAAQJuyZKAQDTAQAPAAQJuyZKAQDTAQAAAA==.',
['早餐']='早餐豆腐脑:BAAALgAECgMJAwAAAA==.',
['明月']='明月半倚深秋:BAAALgAFFAEJAQAAAA==.',
['星空']='星空在你眼中:BAAALgAECgEJAQAAAA==.',
['星辰']='星辰海:BAACLgAFFH8GAAIbAAMJEhjrBwAlAQAbAAMJEhjrBwAlAQAuAAQKfyIAAxsACAlDIoEGACUDABsACAlDIoEGACUDABoABgkRFTtDAEkBAAAA.',
['是夏']='是夏夜呀:BAAALgADCgcJBwAAAA==.',
['是大']='是大男孩呀:BAAALgADCgMJAwAAAA==.',
['晓来']='晓来慕花生:BAAALgADCgYJBQAAAA==.',
['晚风']='晚风依然:BAAALgAFFAIJBAABLgAFFAUJFAAFAFslAA==.',
['晴天']='晴天六翼:BAAALgAFFAQJBAABLgAFFAQJBAAeAAAAAA==.',
['暗夜']='暗夜星空:BAAALgADCgcJBwAAAA==.暗夜灯芯:BAAALgAECgUJBwAAAA==.',
['暗无']='暗无天曰:BAAALgAFFAQJBAAAAA==.',
['暗舞']='暗舞芊芊:BAAALgAECgEJAQAAAA==.',
['暮晨']='暮晨雪:BAAALgAECgYJBQAAAA==.',
['月挽']='月挽星:BAAALgAECgEJAQAAAA==.',
['月无']='月无暇:BAAALgAECgYJBgAAAA==.',
['有怪']='有怪物大哥上:BAAALgADCgEJAQAAAA==.',
['有点']='有点小小帅:BAAALgADCgEJAQAAAA==.',
['李嘉']='李嘉树的防战:BAAALgAFFAMJAwAAAA==.',
['来碗']='来碗刀削面:BAAALgAECgYJBwAAAA==.',
['来财']='来财来:BAAALgADCgIJAQAAAA==.',
['林间']='林间低语:BAAALgADCgcJBwAAAA==.',
['枫月']='枫月白:BAAALgAFFAMJAwAAAA==.',
['柏拉']='柏拉图式想念:BAAALgAECgUJCAAAAA==.',
['某牟']='某牟牟:BAAALgAECgYJBgAAAA==.',
['柯尼']='柯尼塞格天使:BAAALgADCgUJBgAAAA==.',
['格林']='格林艾塞:BAAALgAECgUJBQAAAA==.',
['格里']='格里恩钢琴家:BAAALgAECgEJAgAAAA==.',
['桂花']='桂花乌龙:BAAALgADCgMJAwAAAA==.',
['桃亭']='桃亭:BAAALgAECgQJAwAAAA==.',
['梆梆']='梆梆就三爪:BAAALgADCgMJAwAAAA==.梆梆就两脚:BAAALgAECgYJBgAAAA==.',
['椎名']='椎名立希:BAAALgAECgYJCwAAAA==.',
['樱丶']='樱丶桃:BAAALgADCgEJAQAAAA==.',
['橘子']='橘子味的喵丶:BAAALgAECgIJBAAAAA==.',
['欧成']='欧成简繁:BAAALgAECgcJBwAAAA==.',
['欧阳']='欧阳绿蛋:BAAALgAECgEJAQAAAA==.欧阳绿豆:BAAALgAECgIJAwAAAA==.',
['歌鳥']='歌鳥丶風月:BAAALgAECgYJBgAAAA==.',
['正在']='正在路上:BAAALgAECgMJAwAAAA==.',
['死吼']='死吼:BAAALgAECgcJCQAAAA==.',
['死骑']='死骑也怕鬼:BAAALgAFFAQJBAAAAA==.',
['殇之']='殇之蛋:BAAALgAECgEJAQAAAA==.',
['残暴']='残暴的可达鸭:BAAALgAECgcJCQAAAA==.',
['毁灭']='毁灭之翼丶:BAAALgADCgUJBQAAAA==.',
['每日']='每日大赛:BAAALgAECgkJEAABLgAFFAcJBwAWANgSAA==.',
['比比']='比比拉布:BAAALgAECgYJBQAAAA==.',
['毛茸']='毛茸茸的箭:BAAALgAECgcJEQAAAA==.',
['汤圆']='汤圆葱:BAAALgAECgYJBgAAAA==.',
['汪大']='汪大虎:BAAALgAECgEJAgAAAA==.',
['汪肉']='汪肉卷:BAAALgAFFAEJAQAAAA==.',
['没有']='没有后视镜:BAAALgAECgcJBwAAAA==.没有嗜血:BAAALgADCgkJDgAAAA==.没有盾牌:BAAALgAECgcJCQAAAA==.没有集合石:BAAALgAECgUJBQAAAA==.',
['浪子']='浪子肯特:BAAALgAECgYJDAAAAA==.',
['浮光']='浮光丶破晓:BAAALgAECggJCgAAAA==.',
['浮沫']='浮沫乔:BAAALgADCgYJBgAAAA==.',
['海山']='海山了:BAAALgAECgIJAgAAAA==.',
['海盐']='海盐牛牛:BAACLgAFFH8HAAIPAAMJSB5FJQAeAQAPAAMJSB5FJQAeAQAuAAQKfygAAg8ABwmFJfADAIECAA8ABwmFJfADAIECAAAA.',
['海紫']='海紫薇宁:BAAALgAECgMJAwAAAA==.',
['涂山']='涂山苏苏:BAAALgADCgcJBwAAAA==.',
['消逝']='消逝灬:BAACLgAFFH8FAAIPAAMJsiOWIABDAQAPAAMJsiOWIABDAQAuAAQKfyIAAg8ACAnlJlMGAJ8DAA8ACAnlJlMGAJ8DAAAA.',
['混元']='混元马保国:BAAALgAFFAMJBAAAAA==.',
['淸王']='淸王武光:BAAALgAECgEJAwAAAA==.',
['清晨']='清晨的星星:BAAALgAECgQJBAAAAA==.',
['清柠']='清柠:BAAALgADCgUJBQAAAA==.',
['清算']='清算:BAAALgAECgQJBgAAAA==.',
['源数']='源数圣域:BAABLgAFFH8OAAITAAQJ0BEcAQDzAAATAAQJ0BEcAQDzAAAAAA==.',
['溪水']='溪水潺潺:BAAALgADCgEJAQAAAA==.',
['濡润']='濡润小镰刀:BAAALgAECgMJAwAAAA==.',
['火焰']='火焰鼠红了:BAAALgADCgcJBwAAAA==.',
['灬保']='灬保安队长:BAAALgADCgEJAQAAAA==.',
['灬噢']='灬噢买尬灬:BAAALgAECgcJBwAAAA==.',
['灯芯']='灯芯姐姐:BAAALgAECgYJBgAAAA==.',
['炙纹']='炙纹:BAAALgAECgQJBgAAAA==.',
['烈焰']='烈焰凤凰:BAAALgAECgYJCgAAAA==.',
['热心']='热心市民中钱:BAAALgADCgUJBQAAAA==.热心市民老洋:BAAALgAECgEJAQAAAA==.',
['热敷']='热敷小蛤蜊:BAAALgAECgMJAwAAAA==.',
['焦糖']='焦糖琛琛:BAAALgAECgYJBwAAAA==.',
['焱的']='焱的忧伤:BAAALgAECgcJDwAAAA==.',
['煎俩']='煎俩荷包蛋:BAAALgADCgkJCQAAAA==.',
['煤气']='煤气小罐罐:BAAALgAECgUJBQAAAA==.',
['熊丶']='熊丶铭:BAABLgAECn8aAAMFAAgJ0hypHAAdAgAFAAcJTBupHAAdAgAgAAcJmQf9NwAOAQAAAA==.',
['熊胡']='熊胡子好大:BAAALgAECgYJBgAAAA==.',
['燃烧']='燃烧军团后厨:BAAALgADCgMJAwAAAA==.',
['爆裂']='爆裂丿小德:BAAALgAECgEJAQAAAA==.',
['爱姐']='爱姐姐太好了:BAAALgAECgcJDQAAAA==.',
['爲誰']='爲誰動惢:BAAALgAECgQJBAAAAA==.',
['牛不']='牛不牛看我:BAAALgAECgcJBwAAAA==.',
['牛亡']='牛亡情未了:BAABLgAFFH8JAAILAAQJ5Rm1BgBVAQALAAQJ5Rm1BgBVAQAAAA==.',
['牛叁']='牛叁叁:BAAALgAECgEJAQABLgAFFAMJBwAPAEgeAA==.',
['牛排']='牛排五分熟:BAAALgADCgEJAQAAAA==.',
['牛牛']='牛牛滴僚机獣:BAAALgAECgcJDgAAAA==.牛牛飞上天丶:BAAALgAFFAUJAQAAAA==.',
['牛肉']='牛肉卷:BAAALgAFFAEJAQAAAA==.',
['牧知']='牧知牧觉:BAABLgAFFH8GAAIYAAYJTiD/AABWAgAYAAYJTiD/AABWAgAAAA==.',
['犇犇']='犇犇獁:BAAALgAECgEJAwAAAA==.',
['独孤']='独孤悠玥:BAABLgAECn8WAAIUAAcJCRxiOwA2AgAUAAcJCRxiOwA2AgAAAA==.独孤钥:BAAALgADCgMJAwAAAA==.',
['狼乄']='狼乄:BAAALgAECgEJAQAAAA==.',
['狼犬']='狼犬:BAAALgAECgcJBwAAAA==.',
['猛丁']='猛丁哥:BAAALgAECgMJBgAAAA==.',
['猪头']='猪头真颠:BAABLgAFFH8HAAIFAAIJOgGIIgBbAAAFAAIJOgGIIgBbAAAAAA==.猪头真黒:BAABLgAFFH8GAAIhAAIJ4gGaCgAtAAAhAAIJ4gGaCgAtAAAAAA==.',
['王将']='王将军之武库:BAAALgADCgEJAQAAAA==.',
['王瑀']='王瑀:BAAALgAFFAIJAgABLgAFFAQJCAAQAF0gAA==.',
['玛珐']='玛珐里奥痛风:BAAALgAFFAEJAQAAAA==.',
['玲珑']='玲珑丶舞:BAAALgAECgYJCgAAAA==.',
['瓦格']='瓦格洛什:BAABLgAFFH8KAAISAAUJshS9AQBtAQASAAUJshS9AQBtAQAAAA==.',
['甘蔗']='甘蔗敲后脑:BAAALgAFFAQJBAAAAA==.',
['甯月']='甯月:BAAALgAFFAIJAgABLgAFFAUJEAAWAOAaAA==.',
['田附']='田附近:BAAALgADCgEJAQAAAA==.',
['电磁']='电磁版阿斯克:BAAALgAECgYJBgAAAA==.',
['番茄']='番茄炒蛋拳:BAABLgAFFH8FAAIhAAIJnhoGDAC4AAAhAAIJnhoGDAC4AAABLgAFFAUJFAAFAFslAA==.',
['疯穿']='疯穿箱子丶:BAABLgAFFH8MAAMaAAQJSxBDDwA4AQAaAAQJSxBDDwA4AQAiAAQJTwIAAAAAAAAAAA==.',
['白发']='白发美少女:BAAALgAFFAUJAgAAAA==.',
['白天']='白天丶夜的黑:BAAALgAFFAQJBAAAAA==.',
['白衣']='白衣破千軍:BAAALgAFFAIJAgAAAA==.',
['白骑']='白骑士:BAAALgAECgMJAwAAAA==.',
['百香']='百香灬果:BAAALgAFFAEJAQAAAA==.',
['皇雷']='皇雷:BAAALgAECgYJCAAAAA==.',
['盖里']='盖里盖气的:BAAALgAECgEJAQAAAA==.',
['直视']='直视我的双眼:BAAALgAECgEJAgAAAA==.',
['直蹭']='直蹭炕沿儿:BAAALgAFFAIJAwAAAA==.',
['相见']='相见争如不见:BAAALgAECgMJBAAAAA==.',
['真中']='真中合歡:BAACLgAFFH8FAAIhAAMJKg2UCwDAAAAhAAMJKg2UCwDAAAAuAAQKfxcAAiEACAnnGOQLAFQCACEACAnnGOQLAFQCAAAA.',
['眯眯']='眯眯慧:BAAALgAECgQJBAAAAA==.',
['眼眸']='眼眸印温柔:BAAALgAFFAEJAQAAAA==.',
['破碎']='破碎小手办:BAAALgAECgYJCgAAAA==.',
['福气']='福气满堂:BAAALgAFFAUJBAAAAA==.',
['禧乐']='禧乐:BAAALgAECgYJBgAAAA==.',
['秋帆']='秋帆:BAAALgAECgYJDgAAAA==.',
['秋游']='秋游阉基:BAAALgAFFAUJAwABLgAFFAUJBQAdAH4PAA==.',
['科学']='科学电磁炮:BAABLgAFFH8FAAIhAAUJ7hExBQBQAQAhAAUJ7hExBQBQAQAAAA==.',
['空条']='空条徐伦丶:BAAALgAECgcJDgAAAA==.',
['第四']='第四章的烬:BAAALgAECgcJAgAAAA==.',
['筑梦']='筑梦纳格兰:BAAALgAECgMJAwAAAA==.',
['筱熙']='筱熙丶:BAABLgAFFH8FAAIWAAMJrRmYFAC+AAAWAAMJrRmYFAC+AAABLgAFFAMJBQAPALIjAA==.',
['篠原']='篠原:BAACLgAFFH8GAAISAAMJCxc4EAAGAQASAAMJCxc4EAAGAQAuAAQKfx4AAhIACAlcJesEAFoDABIACAlcJesEAFoDAAAA.',
['粉蒸']='粉蒸肉:BAAALgAFFAIJAwAAAA==.',
['系花']='系花:BAAALgAECgcJCgAAAA==.',
['緟逢']='緟逢的世界:BAAALgAECgEJAQAAAA==.',
['红衣']='红衣丶:BAAALgADCgkJCgAAAA==.',
['纤月']='纤月:BAABLgAECn8ZAAIjAAcJKx1iJAAoAgAjAAcJKx1iJAAoAgAAAA==.',
['终极']='终极法怪:BAAALgAECgQJBAAAAA==.',
['绝命']='绝命怒嚎:BAAALgAECgEJAQABLgAFFAMJBQAhACoNAA==.',
['绝版']='绝版阿斯克:BAAALgAECgYJBgABLgAFFAcJCgAPAO4cAA==.',
['统一']='统一牛奶多:BAABLgAECn8fAAMJAAcJVhDXNABrAQAJAAcJVhDXNABrAQANAAUJABTlMgBPAQAAAA==.',
['绯色']='绯色凋零:BAAALgAECgQJBgAAAA==.',
['缄默']='缄默的泪:BAAALgAECgYJBwAAAA==.',
['罗科']='罗科索夫斯基:BAACLgAFFH8DAAIWAAIJLx8QKgDJAAAWAAIJLx8QKgDJAAAuAAQKfw0AAxYABwkJJuogAJQCABYABgkJJuogAJQCABwAAQkAAFJYAGUAAAAA.',
['罪惡']='罪惡的麺包:BAAALgAECgEJAQAAAA==.',
['羊娃']='羊娃子:BAAALgAECgUJBgABLgAFFAcJHAAPAKwbAA==.',
['美滋']='美滋滋的萨满:BAAALgADCgYJBgABLgAFFAIJBAAeAAAAAA==.',
['群星']='群星塌落:BAAALgADCgcJBwAAAA==.',
['羽之']='羽之羿:BAAALgAECgYJCwAAAA==.',
['羽落']='羽落:BAAALgADCgUJBQAAAA==.',
['老巴']='老巴子:BAAALgAECgcJEQAAAA==.',
['老昊']='老昊:BAAALgAECgUJBQAAAA==.',
['老油']='老油条拉车:BAABLgAECn8VAAMaAAcJGBRXOQB8AQAaAAYJcBZXOQB8AQAbAAIJvgkCrABsAAAAAA==.',
['老舅']='老舅冒汗了:BAAALgAECgUJCAAAAA==.',
['耶路']='耶路撒冷:BAAALgADCgEJAQAAAA==.',
['聂风']='聂风:BAAALgAFFAIJAgABLgAFFAMJBwALAC4eAA==.',
['聖堂']='聖堂:BAAALgAFFAMJBAAAAA==.',
['肆月']='肆月灬:BAAALgAECgIJAwAAAA==.',
['肆漾']='肆漾:BAAALgAFFAMJAwAAAA==.肆漾的旖旎:BAABLgAECn8ZAAIWAAgJBRkWNAA8AgAWAAgJBRkWNAA8AgAAAA==.',
['胖凯']='胖凯:BAAALgAFFAUJAwABLgAFFAUJBQAdAH4PAA==.',
['胖胖']='胖胖凯凯:BAAALgADCgUJBQABLgAFFAUJBQAdAH4PAA==.胖胖山:BAAALgAECgcJDgAAAA==.',
['自由']='自由自在點:BAAALgAECgYJBgAAAA==.',
['至战']='至战之力:BAAALgAECgEJAQAAAA==.',
['舞所']='舞所不能:BAABLgAFFH8GAAIZAAQJXAnrDwADAQAZAAQJXAnrDwADAQAAAA==.',
['艾丽']='艾丽西雅:BAAALgAECgkJCQAAAA==.',
['芬达']='芬达味可乐:BAAALgAECgQJBAAAAA==.',
['花卷']='花卷豆浆:BAAALgAECgEJAQAAAA==.',
['花酒']='花酒行者:BAACLgAFFH8FAAMKAAMJGRAZCwCrAAAKAAIJkhUZCwCrAAAFAAEJKAWWJgA+AAAuAAQKfxcAAgoACAl4IT4HAAkDAAoACAl4IT4HAAkDAAAA.',
['苍月']='苍月潮:BAAALgAECgIJAgAAAA==.',
['苦灬']='苦灬咖啡:BAAALgAFFAIJAgAAAA==.',
['苹果']='苹果光:BAAALgAFFAEJAQAAAA==.',
['茶叶']='茶叶蛋假面:BAABLgAECn8WAAQWAAcJ8w8ziQBHAQAWAAYJXRIziQBHAQAcAAIJDwnbWQBhAAAkAAEJAAB5NgArAAAAAA==.',
['莉迪']='莉迪亚丶罗兰:BAAALgADCgYJBgAAAA==.',
['莫邪']='莫邪丶:BAAALgAECgQJBgAAAA==.',
['菈妮']='菈妮的暗月:BAAALgAECgcJEQAAAA==.',
['菊攻']='菊攻尽趣:BAAALgAECgEJAQAAAA==.',
['菲来']='菲来棏暧:BAABLgAECn8eAAIPAAcJwwxNLgARAQAPAAcJwwxNLgARAQAAAA==.',
['萊科']='萊科寧:BAAALgAFFAEJAQAAAA==.',
['萌萌']='萌萌德呀:BAAALgADCgYJBgAAAA==.',
['蒙战']='蒙战:BAACLgAFFH8FAAIOAAMJIwSgEADUAAAOAAMJIwSgEADUAAAuAAQKfxkAAg4ACAktHRgQAKECAA4ACAktHRgQAKECAAAA.',
['蓝瑾']='蓝瑾:BAAALgAECgYJBgAAAA==.',
['薄荷']='薄荷微光:BAAALgAECgEJAQAAAA==.薄荷柠檬:BAAALgAECgIJAgAAAA==.薄荷灯芯:BAAALgAECgUJBQAAAA==.',
['虚空']='虚空冲击:BAAALgAECgUJBgAAAA==.虚空法王:BAAALgADCgIJAgAAAA==.',
['蜃气']='蜃气楼:BAAALgADCgYJBwAAAA==.',
['蜗牛']='蜗牛骑士:BAAALgADCgcJDAAAAA==.',
['血祭']='血祭扉月:BAAALgAFFAIJAgAAAA==.',
['血色']='血色暴风:BAAALgAECgcJDAAAAA==.',
['街头']='街头音乐家:BAAALgAECgUJBQAAAA==.',
['褪色']='褪色者丶:BAAALgAECgQJBAAAAA==.',
['西瓜']='西瓜榴莲:BAAALgAECgMJAwAAAA==.',
['诺诺']='诺诺大王:BAAALgAECgEJAQAAAA==.诺诺好美:BAAALgAECgYJBwAAAA==.',
['贝鲁']='贝鲁娜:BAAALgAECgIJAgAAAA==.',
['财源']='财源广进:BAAALgADCgEJAQAAAA==.',
['财猫']='财猫双全:BAABLgAFFH8FAAIdAAUJfg8AAAAAAAANAAUJfg8AAAAAAAAAAA==.',
['赛飞']='赛飞儿:BAAALgAECgEJAQAAAA==.',
['超级']='超级火锅:BAACLgAFFH8HAAIBAAMJWg0THQDrAAABAAMJWg0THQDrAAAuAAQKfygAAwEACAkCGksLAL8BAAEACAkCGksLAL8BAAIAAgkDCylgAGEAAAAA.',
['身披']='身披冰河:BAABLgAFFH8GAAILAAIJESFVNgCvAAALAAIJESFVNgCvAAABLgAFFAYJBgABAGofAA==.',
['躺好']='躺好就不动:BAAALgAECgYJCQAAAA==.',
['躺尸']='躺尸老板:BAAALgAECgQJBAAAAA==.',
['轩辕']='轩辕凌雪:BAACLgAFFH8FAAILAAMJnwZALgDhAAALAAMJnwZALgDhAAAuAAQKfyIAAgsACAkOHc8dAM4CAAsACAkOHc8dAM4CAAAA.',
['追丶']='追丶牛牛:BAAALgAFFAQJAwAAAA==.',
['追命']='追命天子:BAAALgAECggJEgAAAA==.',
['追寻']='追寻你的名字:BAAALgAECgEJAQAAAA==.',
['追风']='追风神使:BAACLgAFFH8QAAIOAAYJuxKBAgDbAQAOAAYJuxKBAgDbAQAuAAQKfyQAAg4ACQk2IgIEAGcDAA4ACQk2IgIEAGcDAAAA.',
['透心']='透心凉:BAAALgAECgIJAgAAAA==.',
['道友']='道友怎么称呼:BAAALgADCgcJBwAAAA==.',
['那个']='那个木尸:BAAALgAECgYJCwAAAA==.那个老板:BAAALgAECgQJBQAAAA==.',
['那女']='那女马则莉莉:BAAALgAFFAIJAwAAAA==.',
['邪能']='邪能蛋糕:BAAALgAECgIJAwAAAA==.',
['邪魔']='邪魔降临:BAAALgAECgIJAwAAAA==.',
['酱油']='酱油月:BAAALgAECgEJAQAAAA==.',
['酸菜']='酸菜汆白肉:BAAALgAECgEJAQAAAA==.',
['重逢']='重逢的地狱:BAAALgADCgEJAQAAAA==.',
['野人']='野人村长:BAAALgAFFAIJBAAAAA==.',
['野性']='野性丨之心:BAAALgAECgEJAQAAAA==.',
['野生']='野生月亮:BAAALgAECgYJBwAAAA==.',
['銀色']='銀色手鏈:BAAALgAFFAIJAgAAAA==.',
['鑫飞']='鑫飞扬:BAAALgAECgkJCQAAAA==.',
['销魂']='销魂双下巴:BAAALgAECgMJBAAAAA==.',
['锣斯']='锣斯柴尓德:BAAALgADCgEJAQAAAA==.',
['锤乄']='锤乄:BAAALgAECgYJBgAAAA==.',
['長陳']='長陳猎姬:BAAALgAECgEJAQAAAA==.',
['长命']='长命:BAAALgAECgUJBgAAAA==.',
['长岛']='长岛冰茶丶懿:BAACLgAFFH8FAAIKAAMJPRBpCADwAAAKAAMJPRBpCADwAAAuAAQKfx4AAwoACQnbF4wUAEkCAAoACQn9E4wUAEkCAAUABwnGGfYgAPoBAAAA.',
['闪耀']='闪耀冰晶:BAAALgADCgYJBgAAAA==.闪耀的贝尔:BAABLgAECn8iAAQIAAgJrxxRCwCAAgAIAAgJrxxRCwCAAgAZAAcJfRdDBQCxAQAlAAMJrwteMACTAAAAAA==.',
['闪闪']='闪闪灬发光:BAAALgAECgcJDQAAAA==.',
['阿丶']='阿丶铭:BAAALgAFFAIJBAAAAA==.',
['阿基']='阿基眯德:BAAALgAECgEJAQAAAA==.',
['阿斯']='阿斯菲尔:BAAALgAFFAIJAgAAAA==.',
['阿波']='阿波次的恶魔:BAAALgAFFAMJBAAAAA==.阿波茨的恶魔:BAABLgAECn8aAAMjAAgJLx9aDQDRAgAjAAgJLx9aDQDRAgAOAAUJtR85OQBSAQAAAA==.',
['阿胖']='阿胖达:BAAALgAFFAIJAgAAAA==.',
['阿芙']='阿芙佳朵:BAAALgAFFAIJAgAAAA==.',
['阿韧']='阿韧:BAAALgAECgIJAgAAAA==.',
['阿鲁']='阿鲁迪吧:BAAALgAECgYJBwAAAA==.',
['陈小']='陈小沐:BAAALgADCgEJAQAAAA==.',
['隨訫']='隨訫鎍慾:BAAALgAECgEJAQAAAA==.',
['雨中']='雨中果:BAAALgAFFAIJAwAAAA==.',
['霓裳']='霓裳辕:BAAALgAECgMJAwAAAA==.',
['霜刀']='霜刀:BAAALgAECgQJBQAAAA==.',
['霜天']='霜天筱角:BAAALgAECgQJBAAAAA==.',
['露西']='露西塔:BAAALgAECgUJBQAAAA==.',
['霸王']='霸王要我:BAACLgAFFH8FAAIGAAMJsRMwDgD5AAAGAAMJsRMwDgD5AAAuAAQKfx8AAgYACAkCHuIOAKICAAYACAkCHuIOAKICAAAA.',
['霸霸']='霸霸查你学历:BAAALgAECgUJCAAAAA==.霸霸查妳学历:BAAALgAECgUJBwAAAA==.',
['霹雳']='霹雳:BAAALgAFFAEJAQAAAA==.',
['非木']='非木:BAAALgAFFAEJAQAAAA==.',
['颠疯']='颠疯时代:BAAALgAECgIJAgAAAA==.',
['風暴']='風暴丶卡麗熙:BAAALgAECgQJBAAAAA==.',
['風豬']='風豬蜀黍:BAAALgAECgcJCAAAAA==.',
['风暴']='风暴茅台:BAAALgAECgEJAQAAAA==.',
['风言']='风言影兮:BAAALgAECgYJCQAAAA==.',
['飘飘']='飘飘的妖精:BAAALgAFFAEJAQAAAA==.',
['飞德']='飞德:BAAALgAECgIJBAAAAA==.',
['飞机']='飞机头村长:BAAALgAECgYJBgAAAA==.',
['飞流']='飞流直下丶:BAAALgAECgQJBAAAAA==.',
['饥火']='饥火中烧:BAAALgAECgYJDwAAAA==.',
['饮水']='饮水机:BAAALgAFFAIJBAAAAA==.',
['首席']='首席电疗师:BAAALgAECgUJBQAAAA==.',
['香甜']='香甜可口:BAAALgAFFAIJAgAAAA==.',
['香草']='香草拿铁丶懿:BAAALgAFFAQJBAAAAA==.香草里兰德:BAACLgAFFH8NAAIIAAQJ0SK0AQChAQAIAAQJ0SK0AQChAQAuAAQKfxgABAgACAnaIecGANECAAgACAnaIecGANECACUABQmHGwkYAHkBABkAAQmgGypdAEUAAAAA.',
['馬走']='馬走日:BAAALgAFFAEJAQAAAA==.',
['骑驴']='骑驴找花花:BAAALgADCgEJAQAAAA==.',
['高乐']='高乐高大哥:BAAALgAFFAIJBAAAAA==.',
['魅影']='魅影寒风:BAAALgAECgEJAQAAAA==.魅影猎手:BAAALgADCgEJAQAAAA==.',
['魔女']='魔女幼熙:BAAALgAECgMJAwAAAA==.',
['魔法']='魔法击击:BAAALgAECgEJAgAAAA==.',
['魔羽']='魔羽桃源:BAAALgAECgMJAwAAAA==.',
['魔飘']='魔飘叶:BAACLgAFFH8RAAQiAAUJRhwoAQBoAQAiAAQJYREoAQBoAQAaAAQJzRiNDABTAQAbAAIJZxVEFQCvAAAuAAQKfyoAAxoACAkUI/UHABwDABoACAmpIvUHABwDACIABgnQHr4CAOkBAAAA.',
['魔鬼']='魔鬼加纳乔:BAAALgAECgQJBAAAAA==.',
['鲍隆']='鲍隆:BAAALgAECgQJBAAAAA==.',
['鲤鱼']='鲤鱼鲤鱼鲤:BAAALgADCgIJAgAAAA==.',
['鲨鱼']='鲨鱼巨人:BAAALgAECgYJBgAAAA==.',
['麦兜']='麦兜沐沐:BAABLgAFFH8NAAIYAAUJtSEXAwDUAQAYAAUJtSEXAwDUAQAAAA==.麦兜萌萌:BAAALgAFFAQJBAAAAA==.',
['黄哥']='黄哥:BAABLgAECn8YAAILAAcJfRz9PwA4AgALAAcJfRz9PwA4AgAAAA==.',
['黄鳝']='黄鳝女琪琪:BAAALgAECgYJCgAAAA==.',
['黑漆']='黑漆漆的徳:BAAALgAECgUJBwAAAA==.黑漆漆的战:BAAALgAFFAIJAgAAAA==.黑漆漆的鸟:BAAALgAFFAIJAgAAAA==.',
['黑牛']='黑牛豆奶啊:BAAALgAECgYJBwAAAA==.',
['黑骑']='黑骑士豆奶啊:BAAALgAECgEJAQAAAA==.',
['黑麒']='黑麒麟:BAAALgAFFAEJAgAAAA==.',
['黒猪']='黒猪:BAAALgAECgMJAwAAAA==.',
['龙宅']='龙宅宅:BAAALgAECgEJAQAAAA==.',
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
