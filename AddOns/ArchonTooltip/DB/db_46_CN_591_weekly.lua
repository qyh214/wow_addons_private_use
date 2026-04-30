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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','DemonHunter-Devourer','Shaman-Restoration','Shaman-Elemental','Mage-Frost','Warlock-Demonology','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Fury','Warrior-Arms','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Monk-Brewmaster','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Warrior-Protection','Shaman-Enhancement','Druid-Restoration','Druid-Balance','Paladin-Holy','DeathKnight-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Paladin-Protection','Rogue-Subtlety','Mage-Arcane','Monk-Windwalker',}
local provider = {region='CN',realm='加基森',name='CN',type='weekly',zone=46,date='2026-04-25',data={Af='Afterglow:BAACLgAFFH8YAAIBAAYJvCOlAQBQAgABAAYJvCOlAQBQAgAuAAQKfyMABAEACQldIaIFACwDAAEACQldIaIFACwDAAIABgmkDjYmAPEAAAMAAQnTFahGAD0AAAAA.',
Al='Alcaponelol:BAAALgAECgMJAwAAAA==.',
An='Anpu:BAAALgAECgIJAwAAAA==.',
Ar='Araths:BAAALgAECgYJBgAAAA==.',
Ba='Barbatos:BAAALgAECgcJBwAAAA==.',
Bi='Biubiubiu:BAAALgAECgMJAwAAAA==.Biubiubu:BAAALgAECgEJAQAAAA==.',
Bl='Blazer:BAAALgAECgEJAgAAAA==.Blbs:BAAALgAECgQJBgAAAA==.',
Bo='Boker:BAAALgADCgEJAQAAAA==.',
Bu='Burizado:BAAALgAECgEJAQAAAA==.Burningangel:BAAALgAECgYJCQAAAA==.',
Ca='Calcifer:BAAALgAECgEJAQAAAA==.Canubemydog:BAAALgAFFAIJAQAAAA==.Capybara:BAAALgAECgYJBAAAAA==.',
Cl='Cliff:BAAALgAECgIJAgAAAA==.',
De='Deadk:BAAALgADCgcJBwABLgAFFAQJDQAEABAdAA==.',
Do='Dogtor:BAAALgAECgYJCgAAAA==.',
Dy='Dymaid:BAAALgADCgMJAwAAAA==.Dyss:BAAALgADCgYJBgAAAA==.',
Ee='Eelolz:BAAALgAECgYJBgABLgAFFAQJCgABAJEMAA==.',
Eg='Egoistz:BAAALgAFFAEJAQAAAA==.',
Eo='Eonot:BAAALgAECgQJBAAAAA==.',
Fa='Fakerz:BAAALgAECgQJBAAAAA==.',
Fl='Flerken:BAAALgAECgkJCQAAAA==.',
Ga='Gazz:BAAALgAECgYJBgAAAA==.',
Ha='Haoz:BAAALgAECgYJDQAAAA==.Hassel:BAAALgAFFAIJAgAAAA==.',
Hy='Hyacinth:BAABLgAECn8VAAMFAAYJfRFMVAA1AQAFAAYJfRFMVAA1AQAGAAQJ+Bp3RwAqAQAAAA==.',
Ic='Icenc:BAAALgAFFAEJAQABLgAFFAYJCwAHAMUbAA==.Iceyw:BAAALgAECgYJCAAAAA==.',
Iv='Ivinia:BAAALgAECgEJAQAAAA==.',
Jo='Johnconner:BAAALgAECgYJBgAAAA==.',
Ki='Kiyomi:BAAALgAECgYJBgAAAA==.',
Kz='Kzzla:BAAALgAECgMJAwAAAA==.',
La='Lastdevil:BAABLgAECn8eAAIIAAcJXxt0CQDaAQAIAAcJXxt0CQDaAQAAAA==.',
Li='Lisacety:BAAALgAECgIJAwAAAA==.',
Ll='Lldestiny:BAAALgAECgMJAwAAAA==.',
Lo='Longmayher:BAAALgAECgYJCQAAAA==.',
Ma='Madelemontea:BAAALgAECggJCAAAAA==.Makelemonad:BAAALgABCgEJAQABLgAFFAUJBAAJAAAAAA==.Manuela:BAAALgAECgQJBAAAAA==.',
Mo='Monkjoker:BAAALgADCgEJAQAAAA==.',
Ni='Nivak:BAAALgAECgIJAwAAAA==.',
Oj='Ojo:BAAALgAECgIJBAAAAA==.',
Or='Orangey:BAAALgADCgUJBQAAAA==.Orton:BAAALgAECgEJAQAAAA==.',
Ou='Outlier:BAAALgAECgQJBAAAAA==.Outlierone:BAAALgAFFAIJAwAAAA==.',
['Oó']='Oó:BAAALgAECgYJBgAAAA==.',
Pe='Perilla:BAAALgAECgEJAQAAAA==.',
Po='Poised:BAAALgAECgcJEQAAAA==.',
Ra='Rabbitfury:BAAALgAECgYJBwAAAA==.Raft:BAAALgADCgMJAwAAAA==.Ranyipackage:BAAALgAECgQJAQAAAA==.',
Ry='Ryzen:BAAALgAECggJEQABLgAFFAUJBAAJAAAAAA==.',
Sa='Saccfrs:BAAALgAECgcJBgAAAA==.Sans:BAAALgADCgQJBAAAAA==.',
Se='Seal:BAAALgAECgEJAQAAAA==.',
Sh='Shooting:BAAALgADCgMJAwABLgAECgIJAgAJAAAAAA==.Shoujike:BAAALgAECgYJBgAAAA==.Shoujitiemo:BAAALgAECgQJBAAAAA==.',
Si='Simouns:BAAALgAFFAIJAgAAAA==.',
Sy='Syy:BAAALgAECgEJAQAAAA==.',
Th='Thundery:BAAALgAECgEJAQAAAA==.',
To='Tomkerr:BAAALgAECgYJCwAAAA==.Tompark:BAAALgAECgMJAwAAAA==.',
Tu='Turalyn:BAAALgAFFAEJAQABLgAFFAIJAgAJAAAAAA==.',
Ve='Veronica:BAAALgAECgEJAQAAAA==.',
Vi='Vidic:BAABLgAFFH8FAAMFAAIJfxK4FwCdAAAFAAIJfxK4FwCdAAAGAAIJIxMKHABRAAAAAA==.',
Wa='Warlockjoker:BAAALgAFFAIJBAAAAA==.',
Wl='Wlin:BAAALgAECgMJAwAAAA==.',
Wz='Wzq:BAAALgADCgYJBgAAAA==.Wzy:BAAALgAECgcJBwAAAA==.',
Xl='Xlin:BAAALgAECgYJCQAAAA==.',
Xx='Xxc:BAAALgAECgQJBwAAAA==.',
Ya='Yagw:BAACLgAFFH8JAAMKAAQJ1AqrHgAjAQAKAAQJ1AqrHgAjAQALAAEJlQNLGwAuAAAuAAQKfx0AAwoACAmPDiJiAM0BAAoACAlGDiJiAM0BAAsAAwl2DGAPAHsAAAAA.',
Ym='Ymage:BAAALgAFFAQJAwAAAA==.',
Yo='Yoshinocon:BAABLgAFFH8IAAIMAAMJwhLdFgCuAAAMAAMJwhLdFgCuAAAAAA==.Yoyoma:BAAALgADCgEJAQAAAA==.',
Za='Zacks:BAAALgADCgUJBQAAAA==.',
['Öa']='Öangelababy:BAAALgAECgYJAQAAAA==.',
['一万']='一万次悲伤:BAAALgADCgIJAgAAAA==.',
['一世']='一世琉璃梦:BAAALgAECgQJBQAAAA==.',
['一个']='一个丶武僧:BAAALgAECgYJCQAAAA==.',
['一啪']='一啪即合:BAAALgAECgIJAgAAAA==.',
['一季']='一季三稻:BAAALgADCgcJBwAAAA==.',
['一尘']='一尘不染:BAAALgADCgEJAQAAAA==.',
['一曲']='一曲忐忑:BAAALgAFFAIJBAAAAA==.',
['一月']='一月一:BAAALgAECgUJBwAAAA==.',
['一栗']='一栗莎子:BAAALgAECgUJBQAAAA==.',
['一盒']='一盒黄鹤楼:BAAALgAECgEJAQAAAA==.',
['一碰']='一碰就碎:BAAALgAECgYJBwAAAA==.',
['一身']='一身原谅套:BAAALgAFFAEJAQAAAA==.',
['一辆']='一辆小猫:BAAALgADCgIJAgAAAA==.',
['一键']='一键万血:BAAALgAECgYJBgAAAA==.',
['一鸡']='一鸡抵三鸡:BAABLgAECn8ZAAMMAAgJcBY+KAAcAgAMAAgJSxU+KAAcAgANAAEJ5QvhQgAzAAAAAA==.',
['七七']='七七亓:BAACLgAFFH8FAAIOAAMJISX9CABNAQAOAAMJISX9CABNAQAuAAQKfxoAAw4ABwmPJLIGANsCAA4ABwmPJLIGANsCAA8AAQk5DaNkAC8AAAAA.',
['三级']='三级稻:BAAALgAFFAIJAQAAAA==.',
['上流']='上流战队打野:BAAALgAECgcJBwAAAA==.',
['下蛋']='下蛋公鸡:BAAALgAECgMJAwAAAA==.',
['下雨']='下雨要打伞:BAAALgAECgQJBAAAAA==.',
['不可']='不可追:BAAALgAECgIJAgAAAA==.',
['不屈']='不屈的大狗:BAAALgAECgUJBwAAAA==.',
['不想']='不想玩啦:BAAALgAECgYJCQAAAA==.',
['不爱']='不爱吃红苕:BAAALgAECgIJAgAAAA==.',
['不脏']='不脏丨不牧:BAAALgAECgYJCgAAAA==.',
['不要']='不要紧的:BAAALgAECgUJBgAAAA==.',
['专砍']='专砍追尘:BAAALgAFFAEJAQAAAA==.',
['东方']='东方子书:BAAALgAECgYJCQAAAA==.',
['丨丶']='丨丶繁华落幕:BAABLgAECn8WAAMFAAYJbB8TIAAfAgAFAAYJbB8TIAAfAgAGAAUJGhHyUgD6AAAAAA==.丨丶飞凡灬:BAAALgADCgEJAQAAAA==.',
['丨北']='丨北苍:BAAALgAECgEJAQAAAA==.',
['丨巫']='丨巫法无天丨:BAAALgAECgIJAwAAAA==.',
['丨忘']='丨忘川丨:BAAALgAECgcJBwABLgAFFAUJCQAQAHomAA==.',
['丨懒']='丨懒癌患者:BAAALgAECgcJBwAAAA==.',
['丨消']='丨消散的記憶:BAAALgADCgEJAQAAAA==.',
['丨皮']='丨皮皮鲁:BAAALgAECgIJAgAAAA==.',
['丨离']='丨离岛牧人:BAAALgAFFAIJAgAAAA==.',
['丨第']='丨第一戦:BAAALgAFFAIJAwAAAA==.',
['丨聖']='丨聖光丨:BAAALgAECggJEgAAAA==.',
['中东']='中东车神:BAAALgAECgUJBgAAAA==.',
['中杯']='中杯抹茶拿铁:BAAALgAECgEJAQAAAA==.',
['临街']='临街流水:BAAALgAECgMJAwAAAA==.',
['丶从']='丶从容一生:BAAALgAECgQJCwAAAA==.',
['丶关']='丶关键先生:BAABLgAFFH8IAAIKAAQJLBA2EAD2AAAKAAQJLBA2EAD2AAAAAA==.',
['丶可']='丶可乐丶:BAAALgAECgEJAQAAAA==.',
['丶吉']='丶吉泽亮:BAAALgAECgUJCgAAAA==.',
['丶吧']='丶吧哒嘣:BAAALgADCgUJBQAAAA==.',
['丶培']='丶培培很乖:BAABLgAECn8UAAIRAAcJDx45OQA+AgARAAcJDx45OQA+AgAAAA==.',
['丶夕']='丶夕阳醉:BAAALgAFFAIJAgAAAA==.',
['丶大']='丶大德德:BAAALgAECgEJAQABLgAECgYJBwAJAAAAAA==.',
['丶小']='丶小海疼灬:BAAALgAECgUJBwAAAA==.丶小红手琉璃:BAAALgAFFAEJAQAAAA==.',
['丶无']='丶无名氏丶:BAAALgADCgQJBAAAAA==.',
['丶晓']='丶晓默:BAAALgAECgUJBQAAAA==.',
['丶晚']='丶晚晚卿卿:BAABLgAFFH8OAAQSAAUJDh+AAgCLAQASAAQJDh+AAgCLAQATAAEJAABYAwBfAAAIAAEJchvHQgBeAAAAAA==.丶晚晚卿卿丶:BAABLgAFFH8NAAQSAAUJaR3mAgB4AQASAAQJaR3mAgB4AQAIAAEJaBk0QwBcAAATAAEJAACkBQBWAAAAAA==.',
['丶橙']='丶橙子:BAAALgAECgYJDgAAAA==.',
['丶秀']='丶秀:BAAALgAECgEJAQAAAA==.',
['丶繁']='丶繁丨星灬:BAAALgAECgIJAwAAAA==.',
['丶薛']='丶薛迪凯丶:BAAALgAECgEJAQAAAA==.',
['丶訫']='丶訫葑:BAAALgAECgEJAQAAAA==.',
['丶里']='丶里维:BAABLgAFFH8FAAIUAAMJmgjVCADYAAAUAAMJmgjVCADYAAAAAA==.',
['丶霸']='丶霸氣:BAAALgAFFAIJAwAAAA==.丶霸王:BAAALgAECgEJAgAAAA==.',
['丶静']='丶静三:BAAALgAFFAEJAQAAAA==.',
['丶龍']='丶龍太仙丶:BAAALgAFFAEJAQAAAA==.',
['丷橙']='丷橙子:BAAALgADCgQJBAAAAA==.',
['丿小']='丿小萨灬:BAAALgADCgYJBgAAAA==.',
['丿枫']='丿枫訫:BAAALgAFFAIJBAAAAA==.',
['丿煤']='丿煤球宝宝丶:BAAALgAFFAEJAQAAAA==.',
['丿骚']='丿骚年丶来站:BAAALgAECgYJBgAAAA==.',
['乌萨']='乌萨奇:BAAALgAECgcJDAAAAA==.',
['乔渣']='乔渣男十五号:BAABLgAFFH8LAAMVAAYJIg9uCwBiAQAVAAYJIQhuCwBiAQAWAAUJJg4AAAAAAAAAAA==.乔渣男十四号:BAAALgAFFAQJBAAAAA==.',
['九月']='九月灬初:BAAALgAFFAEJAQAAAA==.',
['九江']='九江小白龙:BAAALgAECgcJBwAAAA==.',
['九潜']='九潜一深:BAAALgADCgUJBQAAAA==.',
['二四']='二四柒:BAAALgAECgEJAQAAAA==.',
['二比']='二比的卷心菜:BAAALgAECgUJBgAAAA==.',
['云丶']='云丶破月:BAAALgAFFAQJBAAAAA==.',
['五花']='五花丨肉丨:BAAALgAECgUJBQAAAA==.',
['亚瑟']='亚瑟丶默根:BAAALgAECgEJAQAAAA==.',
['亡爷']='亡爷丶超:BAAALgAECgYJBgAAAA==.',
['亡语']='亡语丶噤声:BAAALgAECgYJBgAAAA==.',
['亡龙']='亡龙:BAAALgADCgYJDAAAAA==.',
['亰香']='亰香:BAAALgAECgUJBQAAAA==.',
['今天']='今天吃肘子:BAAALgAECgYJDAAAAA==.',
['从小']='从小就瞎:BAAALgAECgcJBwAAAA==.',
['他复']='他复活的祖宗:BAAALgAECgMJAwAAAA==.',
['以太']='以太局局枪:BAAALgADCgIJAgAAAA==.',
['仰望']='仰望虚空:BAAALgADCgEJAQAAAA==.',
['伊利']='伊利蛋之怒:BAAALgAECgYJCwAAAA==.',
['伍柒']='伍柒:BAABLgAFFH8GAAIWAAMJrBs1DAABAQAWAAMJrBs1DAABAQAAAA==.',
['休息']='休息术:BAAALgAECgYJBgABLgAFFAQJBAAJAAAAAA==.',
['会摸']='会摸眼回旋踢:BAAALgAECgMJAwAAAA==.',
['传奇']='传奇机长:BAAALgAFFAIJAgAAAA==.',
['传说']='传说中的骑士:BAAALgAECgEJAQAAAA==.',
['伽希']='伽希莫多:BAAALgAECgMJAwAAAA==.',
['佑柚']='佑柚:BAAALgAECgkJCAAAAA==.',
['何须']='何须问姓名:BAAALgADCgYJBgAAAA==.',
['余情']='余情绻缱:BAAALgAECgMJBAAAAA==.',
['余额']='余额宝:BAAALgADCgIJAgAAAA==.',
['作死']='作死梦中:BAAALgAECgcJDgAAAA==.',
['你也']='你也想起舞嘛:BAAALgAECgcJBwAAAA==.',
['你们']='你们先上:BAAALgAECgYJAgAAAA==.',
['你很']='你很帅丶霸气:BAAALgAECgYJBgAAAA==.',
['你被']='你被瞄准了:BAABLgAFFH8FAAIWAAUJOg3GAwBNAQAWAAUJOg3GAwBNAQAAAA==.',
['你要']='你要打针吗:BAAALgAECgYJCgAAAA==.',
['侑德']='侑德必侑尸:BAAALgAECgIJAgAAAA==.',
['侯天']='侯天来:BAAALgAECgMJAwAAAA==.',
['保健']='保健单人行:BAAALgADCgQJBAAAAA==.',
['修努']='修努努:BAAALgAECgYJBwAAAA==.',
['修罗']='修罗傀儡妖:BAAALgADCgUJBQAAAA==.',
['俺不']='俺不中嘞:BAEALgAFFAQJBAABLgAFFAQJBgAHALASAA==.',
['俺是']='俺是老实人:BAAALgAECgYJDAAAAA==.',
['做了']='做了谁的梦:BAAALgADCgYJBgAAAA==.',
['傻慢']='傻慢傻慢:BAAALgAFFAIJAgAAAA==.',
['先天']='先天挨打圣体:BAAALgAECgEJAgAAAA==.',
['克劳']='克劳德丶:BAAALgAECgEJAQAAAA==.',
['全刚']='全刚不坏体:BAAALgADCgcJDQAAAA==.',
['公爵']='公爵丶叁:BAAALgAECgEJAQAAAA==.',
['兰君']='兰君主:BAAALgADCgEJAQAAAA==.',
['关于']='关于小熊丶:BAAALgAECgUJCAAAAA==.',
['写个']='写个名字真烦:BAAALgADCgUJBQAAAA==.',
['冥缚']='冥缚:BAAALgAFFAIJAgAAAA==.',
['冬冬']='冬冬梅:BAAALgAFFAEJAgAAAA==.',
['冰川']='冰川火花:BAAALgAECgMJBAAAAA==.',
['冰火']='冰火法圣:BAAALgADCgEJAQAAAA==.',
['冰蓝']='冰蓝血雨:BAAALgAECgcJCgAAAA==.',
['冰霜']='冰霜退休员:BAAALgAECgYJDQAAAA==.',
['冲锋']='冲锋冲到死:BAAALgAECgkJCQAAAA==.冲锋卡折腿:BAAALgADCgUJBQAAAA==.冲锋的牛角声:BAAALgAFFAMJBAAAAA==.',
['冷寒']='冷寒月颖:BAAALgADCgUJBQAAAA==.',
['冷风']='冷风浪子:BAAALgAFFAIJAgAAAA==.',
['准备']='准备开怪:BAAALgAECgEJAQAAAA==.',
['凌乱']='凌乱的小鬼:BAAALgADCgYJBgAAAA==.',
['凌月']='凌月与十六夜:BAAALgAECgUJBwAAAA==.',
['凌风']='凌风阁:BAAALgAECgIJAgAAAA==.',
['出银']='出银命:BAACLgAFFH8PAAIHAAUJ5RxlCADeAQAHAAUJ5RxlCADeAQAuAAQKfyEAAgcACAmzIl0aAA4DAAcACAmzIl0aAA4DAAAA.',
['刀啸']='刀啸云:BAAALgAECgMJBQAAAA==.',
['别怕']='别怕变老:BAAALgAECgUJBQAAAA==.',
['别皱']='别皱眉别想他:BAAALgAECgkJCAAAAA==.',
['别贪']='别贪:BAAALgAECgEJAQAAAA==.',
['剑心']='剑心犹在:BAAALgAECgEJAQAAAA==.',
['剑鞘']='剑鞘:BAAALgAECgMJBAAAAA==.',
['剩光']='剩光泡沫儿:BAAALgAECgYJBwABLgAFFAkJBgAXALgTAA==.',
['劏大']='劏大梁:BAACLgAFFH8GAAMYAAQJOA/ZBACrAAAYAAIJXRnZBACrAAANAAQJJQkAAAAAAAAuAAQKfxYAAxgABgmGG5gUAMMBABgABgmGG5gUAMMBAA0ABAlBCuAnALAAAAAA.',
['包您']='包您滿意:BAAALgADCgYJBgAAAA==.',
['北冥']='北冥無雨:BAAALgAECgEJAgAAAA==.',
['北苍']='北苍氵:BAAALgAECgEJAgAAAA==.',
['匠心']='匠心巨制:BAAALgAECgMJAwAAAA==.',
['医學']='医學奇迹:BAAALgAECgYJDwAAAA==.',
['十一']='十一月的小德:BAAALgAFFAIJAgAAAA==.',
['十亿']='十亿少女地梦:BAAALgAFFAIJBAAAAA==.',
['十年']='十年磨一剑:BAAALgAECgYJBgAAAA==.十年磨一劍丶:BAABLgAFFH8FAAIRAAMJnRzcBwARAQARAAMJnRzcBwARAQAAAA==.',
['千屿']='千屿千寻:BAAALgAECgYJDwAAAA==.',
['千载']='千载逢无俪:BAAALgADCgIJAgAAAA==.',
['卓尔']='卓尔游侠:BAAALgAFFAEJAgAAAA==.',
['单吊']='单吊二饼:BAABLgAFFH8GAAIGAAQJawFyCADBAAAGAAQJawFyCADBAAABLgAFFAYJBgAXADsWAA==.',
['南泉']='南泉叨叨婆:BAAALgAECgQJBAAAAA==.',
['博天']='博天下大奕:BAAALgADCgEJAQAAAA==.',
['博尔']='博尔特:BAAALgAECgkJCQAAAA==.',
['卡密']='卡密尔丶怒风:BAAALgADCgIJAgAAAA==.',
['卡布']='卡布达:BAAALgAECgQJBQAAAA==.',
['卡拉']='卡拉豆豆:BAACLgAFFH8JAAQNAAQJ5g+NAgBCAQANAAQJgQqNAgBCAQAYAAIJuBa9CgCdAAAMAAEJJQI5JgBEAAAuAAQKfyEABA0ACAm/HGkGAGYCAA0ACAkCG2kGAGYCABgABgnkGVcUAMYBAAwABQmpFDpsAAUBAAAA.',
['卡提']='卡提西亚:BAAALgAECgIJAgAAAA==.',
['卡芙']='卡芙咔:BAAALgAECgIJAgAAAA==.',
['厄魔']='厄魔的旦旦:BAAALgAECgEJAQAAAA==.厄魔的蛋蛋:BAAALgAECgUJBQAAAA==.',
['叁拾']='叁拾六帝:BAAALgAECgcJAQAAAA==.',
['又何']='又何必纠结丶:BAAALgAECgYJBgAAAA==.',
['双持']='双持大宝剑:BAAALgAECgcJBwAAAA==.',
['发丶']='发丶发丶发:BAABLgAECn8UAAIKAAYJjBpkZwC/AQAKAAYJjBpkZwC/AQAAAA==.',
['可儿']='可儿:BAAALgAECgEJAQAAAA==.',
['可爱']='可爱的猎人:BAAALgADCgUJBQAAAA==.',
['名主']='名主万岁:BAAALgADCgUJBQAAAA==.',
['吕竖']='吕竖式:BAAALgADCgcJDAAAAA==.',
['吖卟']='吖卟尐一小之:BAAALgADCgcJBwAAAA==.',
['吗赛']='吗赛克:BAAALgAECgUJDAABLgAECgYJCwAJAAAAAA==.',
['君喃']='君喃一世长安:BAAALgAFFAQJBAAAAA==.',
['呆啲']='呆啲:BAACLgAFFH8IAAMGAAUJWQnTDQAPAQAGAAUJWQnTDQAPAQAFAAEJNwNZEwA4AAAuAAQKfxoABAYABwlsIb8TAIECAAYABwlsIb8TAIECAAUAAgn2ATWWAEUAABkAAQkeEP8rADUAAAAA.',
['呆河']='呆河马:BAAALgADCgUJCQAAAA==.',
['命运']='命运之麻衣:BAABLgAFFH8OAAIIAAQJHxSCEABdAQAIAAQJHxSCEABdAQAAAA==.',
['咔下']='咔下流:BAAALgAECgYJCwAAAA==.',
['咖咖']='咖咖就是发:BAAALgAECgYJDgAAAA==.',
['咖喱']='咖喱炒蟹:BAAALgADCgIJAwAAAA==.',
['咚次']='咚次嗒次丶咚:BAAALgAECgUJBgAAAA==.',
['咦丨']='咦丨:BAACLgAFFH8JAAIHAAQJthwoFAB6AQAHAAQJthwoFAB6AQAuAAQKfxwAAgcABgnyJMUMAOYBAAcABgnyJMUMAOYBAAAA.',
['咯咯']='咯咯:BAAALgAECgEJAQAAAA==.',
['哆塔']='哆塔之神:BAAALgAFFAQJBAAAAA==.',
['哪个']='哪个谁:BAAALgADCgEJAQAAAA==.',
['哭泣']='哭泣的刀子:BAAALgAECgUJCQAAAA==.',
['唐吉']='唐吉坷德:BAAALgADCgMJAwAAAA==.',
['啊优']='啊优科瑞泽:BAAALgAECgYJCQAAAA==.',
['啵啵']='啵啵鸡:BAAALgAECgYJBgAAAA==.',
['喵喵']='喵喵特工队:BAAALgAECgEJAQAAAA==.',
['喵嘞']='喵嘞个寿司:BAACLgAFFH8HAAIKAAMJGB1YDQAKAQAKAAMJGB1YDQAKAQAuAAQKfxwAAgoACAkzH5UgAL8CAAoACAkzH5UgAL8CAAAA.',
['喵汪']='喵汪呢呢:BAACLgAFFH8GAAMQAAMJRR7cAgARAQAQAAMJRR7cAgARAQAPAAEJCg+eFABRAAAuAAQKfxUAAxAACAmfFvobAP0BABAACAmfFvobAP0BAA8AAQkIEVddAD8AAAAA.',
['喵真']='喵真真:BAABLgAFFH8GAAIQAAIJtCNhBADIAAAQAAIJtCNhBADIAAAAAA==.',
['嘣了']='嘣了真君:BAAALgAECgUJBwAAAA==.',
['噗咚']='噗咚噗咚:BAAALgAECgIJAgAAAA==.',
['回春']='回春丹:BAAALgAECgEJAQAAAA==.回春叔:BAAALgAECgQJBAAAAA==.',
['国服']='国服第一法爷:BAAALgAECgYJBwAAAA==.',
['图图']='图图是肥婆呀:BAAALgADCgEJAgAAAA==.',
['土豆']='土豆兄弟:BAAALgAECgEJAQABLgAFFAEJAgAJAAAAAA==.',
['圣光']='圣光无畏惧:BAAALgAFFAMJAwAAAA==.圣光血蹄:BAAALgAECgUJBQAAAA==.',
['圣骑']='圣骑士:BAAALgADCgQJBAAAAA==.',
['地狱']='地狱魔术师:BAAALgAECgQJBgAAAA==.',
['坂本']='坂本缇凌:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落灬醉鸟:BAAALgAECggJCAAAAA==.',
['增辉']='增辉哥哥带我:BAAALgAECgcJBwAAAA==.',
['墨染']='墨染丶清风:BAAALgAECgcJEwAAAA==.',
['壹光']='壹光年之灭:BAAALgAECgEJAQAAAA==.',
['壹啾']='壹啾啾气丷:BAAALgADCgUJBQAAAA==.壹啾啾气灬:BAAALgAECgEJAQAAAA==.',
['夏梦']='夏梦玫珑:BAAALgADCgcJBwAAAA==.',
['多情']='多情小武:BAAALgAECgQJBQAAAA==.',
['夜風']='夜風之歌:BAAALgAECgEJAQABLgAECgYJCAAJAAAAAA==.',
['大丶']='大丶天丶二丶:BAAALgAECgYJCAAAAA==.',
['大光']='大光头头哥:BAAALgAECgkJDAAAAA==.',
['大刀']='大刀向前方:BAAALgAECgQJBgAAAA==.',
['大威']='大威德龙宝宝:BAAALgADCgkJDwAAAA==.',
['大欧']='大欧很欧:BAAALgAECgEJAQAAAA==.',
['大海']='大海绵不见了:BAAALgAECgYJDwAAAA==.',
['大灬']='大灬领主:BAAALgAECgYJEAAAAA==.',
['大米']='大米的小米:BAAALgAECgYJDwAAAA==.',
['大群']='大群术爷:BAAALgAECgYJBwAAAA==.',
['天下']='天下流云:BAAALgAECgYJCwAAAA==.',
['天丨']='天丨:BAAALgAECgcJDwAAAA==.',
['天丶']='天丶问:BAAALgAECgEJAgAAAA==.',
['天空']='天空猎:BAAALgADCgQJBAAAAA==.',
['天运']='天运明光真君:BAAALgAECgYJBgAAAA==.',
['天音']='天音:BAAALgAECgIJAgAAAA==.',
['太寿']='太寿鸠毛:BAAALgAECgYJDAAAAA==.',
['太虚']='太虚无形:BAAALgADCgUJBQAAAA==.',
['奔跑']='奔跑的特仑苏:BAAALgAECgcJEAAAAA==.',
['奥德']='奥德飙啊:BAABLgAFFH8IAAIHAAQJKRBHCQBWAQAHAAQJKRBHCQBWAQAAAA==.',
['奥术']='奥术的吟唱:BAAALgAECgcJAQAAAA==.',
['奥莉']='奥莉尔丶:BAAALgAFFAEJAQAAAA==.',
['奶不']='奶不动呀:BAAALgADCgEJAQAAAA==.奶不是很多:BAAALgAECgEJAQAAAA==.',
['奶你']='奶你姐呀:BAAALgAECgEJAQAAAA==.',
['奶思']='奶思兔咪特悠:BAAALgAECgcJCwAAAA==.',
['她喜']='她喜欢:BAAALgAFFAIJAwAAAA==.',
['好的']='好的:BAAALgAECgIJAgAAAA==.',
['如此']='如此灬陌生:BAAALgAECgYJBwAAAA==.',
['妍小']='妍小贝:BAAALgADCgUJBQAAAA==.',
['妖妖']='妖妖拓哉:BAAALgAECgYJBgAAAA==.',
['妖精']='妖精的归宿:BAAALgAECgEJAQAAAA==.',
['妖颜']='妖颜惑众:BAAALgADCgcJBwAAAA==.',
['姬夏']='姬夏:BAABLgAECn8WAAMIAAgJOiF+HACqAgAIAAgJOiF+HACqAgATAAIJ9yI5GgClAAAAAA==.',
['婲開']='婲開丶終須落:BAAALgAECgcJBwAAAA==.',
['嫩咕']='嫩咕:BAAALgADCgcJBwAAAA==.',
['孤独']='孤独郁:BAAALgAECgUJCgAAAA==.',
['学会']='学会喂鸡爱鸡:BAABLgAFFH8HAAIaAAMJnBAzCADgAAAaAAMJnBAzCADgAAABLgAFFAYJEQAXANshAA==.',
['宁姚']='宁姚:BAAALgADCgIJAgAAAA==.',
['宇宙']='宇宙鸡老师:BAAALgAECgUJBQAAAA==.',
['安安']='安安呀:BAAALgAFFAIJAwAAAA==.',
['安度']='安度因之子:BAAALgAECgQJBgAAAA==.',
['安格']='安格鲁之光:BAAALgAECgkJAgAAAA==.安格鲁之刃:BAAALgAECgkJCQABLgAFFAQJDgAKAOcjAA==.安格鲁之岚:BAAALgAECgIJAgAAAA==.安格鲁之心:BAAALgAECgkJAgABLgAFFAUJEQAPAIwhAA==.安格鲁之殇:BAAALgAECgcJBwAAAA==.安格鲁之禅:BAAALgAECgIJAgAAAA==.安格鲁之触:BAAALgAECgkJAgABLgAFFAUJCQAQANcWAA==.安格鲁之霜:BAAALgAECgkJBAAAAA==.安格鲁之魂:BAAALgAECgkJCgAAAA==.安格鲁之鹰:BAAALgAECgEJAQABLgAFFAYJBwAVABANAA==.',
['安萨']='安萨卡:BAAALgADCgEJAQAAAA==.',
['宝贝']='宝贝儿别跑:BAAALgADCgUJBQAAAA==.',
['宫园']='宫园薰丶:BAAALgAECgEJAQAAAA==.',
['宫廷']='宫廷玉液酒:BAAALgAECgUJBgAAAA==.',
['容我']='容我来摸个橙:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞孢:BAAALgAECgQJBgAAAA==.寂寞寳:BAABLgAECn8VAAIOAAYJsBt+FgDuAQAOAAYJsBt+FgDuAQAAAA==.寂寞小雨:BAAALgAFFAEJAQAAAA==.',
['密丝']='密丝特:BAAALgAFFAQJBAABLgAECgkJFwAYAMAcAA==.',
['射爆']='射爆你的头:BAAALgADCgUJBQAAAA==.',
['小千']='小千早爱音:BAAALgAECgIJAgAAAA==.',
['小号']='小号全家桶:BAAALgAECgEJAQAAAA==.',
['小太']='小太公:BAAALgAECgUJBQAAAA==.',
['小小']='小小顾云:BAAALgAECggJEQAAAA==.',
['小巴']='小巴饼干:BAAALgAECgIJAgAAAA==.',
['小心']='小心头前:BAAALgAECgUJBQABLgAFFAUJCQASANghAA==.小心着火:BAAALgAFFAEJAQAAAA==.',
['小怡']='小怡宝:BAAALgAECgcJBgAAAA==.',
['小斗']='小斗士:BAABLgAECn8VAAIKAAcJgR8YNwBaAgAKAAcJgR8YNwBaAgAAAA==.',
['小术']='小术盗魂:BAAALgAECgQJBAAAAA==.',
['小桃']='小桃枝丶:BAABLgAFFH8FAAIaAAMJNgOqCwCZAAAaAAMJNgOqCwCZAAAAAA==.',
['小滚']='小滚珠:BAABLgAECn8aAAIFAAgJFRL5KQDmAQAFAAgJFRL5KQDmAQAAAA==.',
['小熊']='小熊哥哥:BAABLgAFFH8MAAMQAAQJhh0OCADnAAAQAAQJhh0OCADnAAAOAAEJYgV1GwBBAAAAAA==.',
['小狗']='小狗不蘸酱:BAAALgAECgkJCQAAAA==.小狗蘸酱:BAAALgAECgYJBgAAAA==.',
['小糊']='小糊糊:BAAALgAECgYJCQAAAA==.',
['小红']='小红手丶梦梦:BAABLgAFFH8HAAIRAAIJ+hD0DwCmAAARAAIJ+hD0DwCmAAAAAA==.',
['小芭']='小芭蕉丶丶:BAAALgADCgEJAQAAAA==.',
['小芷']='小芷妍吖:BAACLgAFFH8HAAIaAAMJShkYCADjAAAaAAMJShkYCADjAAAuAAQKfxUAAxsABwlNFzEoAL0BABsABwlNFzEoAL0BABoABgmvEzJdADoBAAAA.',
['小酒']='小酒馆飞盾丶:BAAALgADCgMJAwAAAA==.',
['小钢']='小钢炮:BAAALgAECgYJCAAAAA==.',
['小靑']='小靑不开心:BAAALgAFFAIJAwAAAA==.',
['小青']='小青不开心:BAAALgAECgcJCAAAAA==.',
['小鱼']='小鱼同学丶:BAAALgAECgEJAQAAAA==.',
['小黑']='小黑熊冰红茶:BAAALgADCgMJAwAAAA==.',
['小龙']='小龙人的光:BAAALgADCgcJBwAAAA==.',
['尐兔']='尐兔子残残:BAAALgADCgUJBQAAAA==.',
['尚善']='尚善偌水:BAACLgAFFH8HAAIQAAMJMw/ACADcAAAQAAMJMw/ACADcAAAuAAQKfxsABBAABwn/FnYnALMBABAABwkfFnYnALMBAA8ABQnpG78rAH4BAA4ABQlBEbcvACIBAAAA.',
['就是']='就是梅偷税:BAACLgAFFH8IAAIcAAMJIyWbAwBKAQAcAAMJIyWbAwBKAQAuAAQKfxUAAhwACAnxHmIUAG8CABwACAnxHmIUAG8CAAAA.',
['就点']='就点你麻筋:BAAALgAECgYJDAAAAA==.',
['尼戈']='尼戈哈玛彼:BAAALgADCgEJAQAAAA==.',
['居里']='居里:BAAALgAECgEJAQAAAA==.',
['屠魔']='屠魔使艾丽斯:BAAALgADCgEJAQAAAA==.',
['山由']='山由:BAAALgAECgMJAwAAAA==.',
['岛屿']='岛屿与心情:BAAALgAECgQJBwAAAA==.',
['岩仓']='岩仓玲音:BAABLgAFFH8GAAIOAAMJySHhBAAsAQAOAAMJySHhBAAsAQAAAA==.',
['巅峰']='巅峰的荣耀:BAAALgAFFAEJAQAAAA==.',
['工人']='工人领袖:BAAALgADCgEJAQAAAA==.',
['巧克']='巧克力好好吃:BAACLgAFFH8GAAIQAAIJahTGDACYAAAQAAIJahTGDACYAAAuAAQKfxUAAxAABwlCHgEUAD8CABAABwlSHAEUAD8CAA4ABQlkFksnAFsBAAAA.',
['巴小']='巴小肥:BAAALgAECgcJBwAAAA==.',
['巴拉']='巴拉纳:BAAALgAECgYJBgAAAA==.',
['巴比']='巴比母捏牛:BAAALgAECgYJBwAAAA==.',
['帅哥']='帅哥当自强:BAABLgAFFH8LAAIKAAMJHyR9GQA/AQAKAAMJHyR9GQA/AQAAAA==.',
['希尔']='希尔丶瓦拉斯:BAAALgAECgEJAgAAAA==.',
['希开']='希开头的奶骑:BAAALgAECgYJCAABLgAFFAIJBAAJAAAAAA==.希开头的骑士:BAAALgAFFAIJBAAAAA==.',
['帝国']='帝国斟茶兵:BAAALgAFFAEJAQAAAA==.',
['帥到']='帥到不行:BAAALgAECgcJDQAAAA==.',
['带你']='带你转圈圈:BAAALgAECgYJCQAAAA==.',
['幚幚']='幚幚两拳:BAABLgAFFH8KAAIUAAMJoyEhDAAkAQAUAAMJoyEhDAAkAQAAAA==.',
['干煸']='干煸肥肠:BAAALgAFFAUJBAAAAA==.',
['平川']='平川:BAAALgAECgYJBwAAAA==.',
['年年']='年年有汐:BAAALgAECgYJDgAAAA==.',
['年迈']='年迈的肥柯基:BAABLgAFFH8GAAMKAAIJyB2zQgCdAAAKAAIJfw6zQgCdAAAdAAEJVyEAAAAAAAAAAA==.',
['幻山']='幻山的烟花:BAAALgAECgQJBAAAAA==.',
['幼儿']='幼儿园杠把子:BAACLgAFFH8FAAIIAAIJNA8eOACjAAAIAAIJNA8eOACjAAAuAAQKfxgABAgACAkPHVQkAIICAAgACAkPHVQkAIICABMAAQkAACYrAEkAABIAAQkAAOV+ABoAAAAA.',
['幽冥']='幽冥夜月:BAAALgAECgEJAQAAAA==.',
['幽娜']='幽娜婷:BAAALgAECgQJBAAAAA==.',
['幽暗']='幽暗圣君:BAAALgADCgEJAQAAAA==.',
['库里']='库里小妖怪:BAABLgAECn8VAAQeAAcJ2gKAIACAAAAeAAUJugOAIACAAAAfAAYJegAtewAnAAAEAAUJAQD7+AADAAABLgAFFAMJBgAgAF0FAA==.',
['建筑']='建筑设计大师:BAAALgAECgIJAgAAAA==.',
['开始']='开始跑操:BAAALgAFFAEJAQABLgAFFAEJAgAJAAAAAA==.',
['开水']='开水煮白菜:BAAALgAFFAEJAQAAAA==.',
['开芯']='开芯:BAABLgAFFH8FAAIRAAMJchVEFAAGAQARAAMJchVEFAAGAQAAAA==.',
['弁空']='弁空:BAAALgADCgUJBQAAAA==.',
['异世']='异世界旅行:BAAALgAECgEJAQAAAA==.',
['弑魂']='弑魂乄焚月:BAABLgAFFH8LAAIXAAQJUQsABQASAQAXAAQJUQsABQASAQAAAA==.弑魂乄紫月:BAAALgAFFAMJBAAAAA==.弑魂乄芈月:BAAALgAECgYJAQAAAA==.',
['弓冢']='弓冢五月:BAABLgAFFH8FAAIcAAIJzh8zEgC6AAAcAAIJzh8zEgC6AAAAAA==.',
['弓虽']='弓虽力术出:BAAALgADCgUJBQAAAA==.',
['弔迩']='弔迩朤氹:BAAALgAECgcJDwAAAA==.',
['弗尔']='弗尔摩斯:BAAALgAECgMJAwAAAA==.',
['张九']='张九生:BAAALgAECgYJBwAAAA==.',
['归溟']='归溟幽灵鲨:BAAALgAFFAMJAwAAAA==.',
['当愛']='当愛已成往亊:BAABLgAECn8WAAMMAAYJzh17NADYAQAMAAYJuhl7NADYAQANAAIJFRjwKwCUAAAAAA==.',
['当时']='当时很帅:BAAALgAECgEJAQAAAA==.',
['当爱']='当爱在进行时:BAAALgAECgYJBwAAAA==.',
['彩虹']='彩虹大神:BAAALgADCgYJBgAAAA==.',
['影之']='影之肉肉:BAAALgAECgQJBQAAAA==.',
['影舞']='影舞之旋律:BAAALgADCgEJAQAAAA==.',
['彼岸']='彼岸花开灬:BAAALgAECgIJAwAAAA==.',
['彾梦']='彾梦:BAAALgAECgIJAgAAAA==.',
['很水']='很水的老阿姨:BAAALgAFFAEJAQAAAA==.',
['律已']='律已秋:BAAALgAFFAMJAwAAAA==.',
['徐寒']='徐寒零:BAAALgAECgMJAwAAAA==.',
['從小']='從小就很嗨:BAAALgAECgMJBAAAAA==.從小就很萌:BAAALgAECgEJAQAAAA==.',
['徵羽']='徵羽白:BAAALgAECgUJBgAAAA==.',
['德嘞']='德嘞个德:BAAALgAECgMJAwAAAA==.',
['德德']='德德徳徳德:BAAALgAECgEJAQAAAA==.',
['心随']='心随术:BAAALgAECgYJBgAAAA==.',
['忧由']='忧由有又:BAAALgAECgIJAwAAAA==.',
['忿怒']='忿怒的小鸡:BAAALgAECgUJCAAAAA==.',
['怀素']='怀素:BAAALgAECgYJBwAAAA==.',
['怒的']='怒的咆哮:BAAALgADCgcJBwAAAA==.',
['思念']='思念随风过:BAAALgADCgYJBgAAAA==.',
['恐怖']='恐怖老虎鸡:BAAALgAECgcJCQAAAA==.',
['恰同']='恰同学少年:BAABLgAECn8dAAIHAAYJXyGwUgBAAgAHAAYJXyGwUgBAAgAAAA==.',
['恶劣']='恶劣人:BAAALgADCgYJBgAAAA==.',
['恶魔']='恶魔的地狱火:BAACLgAFFH8JAAMSAAQJlRzzCgCyAAAIAAIJfyONKADUAAASAAIJqxXzCgCyAAAuAAQKfxoAAxIABgm3JeoPANEBAAgABQmKJXQ9ABcCABIABgngIeoPANEBAAAA.恶魔骑士:BAAALgAECgQJBAAAAA==.',
['恶龙']='恶龙:BAAALgAECgYJCgAAAA==.',
['悠米']='悠米有米:BAAALgADCgYJBgAAAA==.',
['悲剧']='悲剧的盗号了:BAAALgAECgUJCAAAAA==.',
['惊鸿']='惊鸿过隙:BAAALgAECgEJAgAAAA==.',
['惠风']='惠风和畅:BAAALgAECgQJBgAAAA==.',
['想喝']='想喝冰阔乐:BAAALgAECgEJAgAAAA==.',
['愛夢']='愛夢丶:BAAALgAECgYJBgAAAA==.',
['愛希']='愛希爾:BAAALgAECgQJBAAAAA==.',
['感受']='感受雷电吧:BAAALgAECgIJAgAAAA==.',
['愤怒']='愤怒丶咕噜:BAABLgAFFH8FAAIcAAIJDhh+FACdAAAcAAIJDhh+FACdAAAAAA==.',
['慕容']='慕容云海:BAABLgAFFH8GAAIYAAMJYBCMCADOAAAYAAMJYBCMCADOAAAAAA==.',
['慕禾']='慕禾灬:BAAALgAECgMJAwAAAA==.',
['成龙']='成龙大哥:BAAALgAECgYJBwAAAA==.',
['我们']='我们的船长:BAAALgAECgQJBAAAAA==.',
['我嘂']='我嘂哀木涕:BAAALgAECgEJAQAAAA==.',
['我妻']='我妻由乃:BAAALgAECgcJCAAAAA==.',
['我将']='我将点燃星海:BAAALgAECgkJDAAAAA==.',
['我就']='我就是这么吊:BAAALgAECgEJAQAAAA==.',
['我愛']='我愛吃汉堡:BAAALgAECgUJCQAAAA==.',
['我是']='我是啊蛮:BAAALgAECgMJBAAAAA==.',
['我有']='我有抑郁症:BAAALgAECgIJAgAAAA==.我有点儿困了:BAAALgAECgQJBAAAAA==.',
['我滴']='我滴乖汝汝:BAAALgAECgEJAQAAAA==.',
['我爱']='我爱小崽:BAABLgAFFH8IAAIFAAMJ+RIVBwDjAAAFAAMJ+RIVBwDjAAAAAA==.',
['我的']='我的眼会射:BAAALgAECgEJAQAAAA==.',
['我错']='我错哪啦:BAAALgAECgEJAgAAAA==.',
['战羊']='战羊羊:BAAALgAECgkJDwABLgAFFAUJEQAPAIwhAA==.',
['战舞']='战舞骑士:BAAALgADCgcJBwAAAA==.',
['扔你']='扔你蛋蛋:BAACLgAFFH8HAAIHAAMJxB4LDQApAQAHAAMJxB4LDQApAQAuAAQKfxYAAgcACAmeH0MnANUCAAcACAmeH0MnANUCAAEuAAEKAQkBAAkAAAAA.',
['托尼']='托尼:BAAALgAECgEJAQAAAA==.',
['托普']='托普利亚黑牛:BAEALgAECgYJBgAAAA==.',
['扛刀']='扛刀赴会:BAAALgAFFAIJAwAAAA==.',
['执掌']='执掌邪恶:BAAALgAECgEJAQABLgAECgUJCQAJAAAAAA==.',
['扶墙']='扶墙对抗:BAAALgADCgcJDAAAAA==.',
['把酒']='把酒眼:BAAALgAECgYJCAAAAA==.',
['抹茶']='抹茶巧克力:BAAALgAECgUJCQAAAA==.',
['拉之']='拉之哥:BAAALgAECgMJAwAAAA==.',
['拖进']='拖进苞米地:BAAALgAECgIJAgAAAA==.',
['拳打']='拳打安度因:BAAALgAECgEJAQAAAA==.',
['拳脚']='拳脚无眼:BAAALgAECgMJAgAAAA==.',
['拽进']='拽进小树林:BAAALgAECgIJAwAAAA==.',
['持续']='持续:BAAALgAECgUJCQAAAA==.',
['捌叁']='捌叁捌肆:BAAALgADCgMJAQAAAA==.',
['掩护']='掩护你躺尸:BAAALgAECgYJBgAAAA==.',
['提托']='提托迪奥斯:BAAALgAECgMJAwAAAA==.',
['搓一']='搓一个大火球:BAAALgAECgMJBQAAAA==.',
['攻强']='攻强:BAAALgAFFAIJAgAAAA==.',
['故事']='故事中:BAABLgAFFH8GAAIRAAQJmSFkBQCZAQARAAQJmSFkBQCZAQAAAA==.',
['断水']='断水琉大师兄:BAAALgAECgMJAwAAAA==.',
['旋律']='旋律牛战天:BAACLgAFFH8OAAIYAAQJVg38BQALAQAYAAQJVg38BQALAQAuAAQKfyMAAhgACAlYGmQKAG0CABgACAlYGmQKAG0CAAAA.旋律麦蒂文:BAAALgADCgUJBQAAAA==.',
['无锡']='无锡毒蛤蟆:BAAALgAECgkJCgABLgAFFAcJBwASAE0eAA==.',
['无韵']='无韵之歌:BAAALgAECgEJAQAAAA==.',
['旧时']='旧时梦:BAABLgAFFH8IAAIHAAMJJByUJQAdAQAHAAMJJByUJQAdAQAAAA==.',
['早川']='早川秋:BAAALgAFFAIJAgAAAA==.',
['时光']='时光之舞:BAACLgAFFH8FAAIhAAIJih+nFgBkAAAhAAIJih+nFgBkAAAuAAQKfxYAAiEABwl7JMMRAJECACEABwl7JMMRAJECAAAA.时光奕人心:BAAALgAECgIJAwAAAA==.',
['时天']='时天使:BAAALgAECgEJAQAAAA==.',
['时崎']='时崎狂三:BAAALgAECgEJAQAAAA==.',
['明月']='明月狂刀:BAAALgAECgQJBwAAAA==.明月青锋:BAAALgAECgMJCAAAAA==.',
['星辰']='星辰月夜:BAACLgAFFH8PAAMIAAUJKBCFCQCTAQAIAAUJKBCFCQCTAQASAAEJJQE+GwA9AAAuAAQKfxoAAwgACAkEFfVkAJwBAAgABgnrF/VkAJwBABIAAgmdA41PAH8AAAAA.星辰盼蓝儿归:BAAALgADCgMJAwAAAA==.',
['春风']='春风怜花意:BAAALgAECgIJAwAAAA==.',
['昨夜']='昨夜小楼:BAAALgAECgYJCgAAAA==.',
['昭明']='昭明破晦夜:BAAALgAECgcJCAAAAA==.',
['晓晓']='晓晓楠:BAAALgAECgcJBwAAAA==.',
['晟光']='晟光阿昆达:BAAALgAECgQJAgAAAA==.',
['晨宝']='晨宝:BAABLgAECn8WAAIYAAgJFhVmDwATAgAYAAgJFhVmDwATAgAAAA==.',
['晴天']='晴天丶叶梦:BAAALgAECgIJAgAAAA==.晴天丶瑟琳娜:BAAALgADCgEJAQAAAA==.晴天丶芊芊珊:BAAALgAECgEJAQAAAA==.',
['暗十']='暗十:BAAALgADCgEJAQAAAA==.',
['暗零']='暗零:BAAALgAECgYJCQAAAA==.',
['曉曉']='曉曉孩:BAAALgAECgYJBwAAAA==.',
['曾经']='曾经的酱油:BAAALgAECgEJAgAAAA==.',
['最后']='最后的神棍:BAABLgAECn8XAAMIAAcJmBk+TQDhAQAIAAcJHhk+TQDhAQASAAIJBxT/UAB7AAAAAA==.',
['最爱']='最爱波斯猫:BAAALgAECgYJEQAAAA==.',
['月上']='月上烟花:BAAALgAECgIJAgAAAA==.',
['月光']='月光下的惩戒:BAABLgAECn8UAAIRAAcJQBmLWwDQAQARAAcJQBmLWwDQAQAAAA==.',
['月照']='月照别离:BAAALgAFFAEJAQAAAA==.',
['有去']='有去无回:BAAALgADCgMJAwAAAA==.',
['木子']='木子熙丶:BAAALgAECggJDwAAAA==.',
['木易']='木易成舟:BAAALgAECgEJAQAAAA==.',
['末日']='末日天降:BAAALgADCgYJBgAAAA==.',
['本地']='本地围观群众:BAEALgAECgEJAQABLgAECgYJBgAJAAAAAA==.',
['朱紅']='朱紅之涙:BAAALgAECgYJEQAAAA==.',
['朴克']='朴克:BAAALgAECgcJAgAAAA==.',
['朵朵']='朵朵惹人爱:BAAALgAFFAEJAQAAAA==.',
['杀戮']='杀戮魔瞳:BAAALgAECgYJBgAAAA==.',
['李丷']='李丷奶奶:BAAALgAECgcJCAAAAA==.',
['李富']='李富贵:BAAALgAECgYJBwAAAA==.',
['来伊']='来伊口:BAAALgAECgUJBQAAAA==.',
['杭州']='杭州彭于晏:BAAALgAECgQJBAABLgAFFAIJBAAJAAAAAA==.',
['杰克']='杰克:BAACLgAFFH8KAAIaAAQJRxxVBwBeAQAaAAQJRxxVBwBeAQAuAAQKfxYAAhoABwnBJXsOAMYCABoABwnBJXsOAMYCAAAA.',
['杰里']='杰里克丶御风:BAAALgAECgQJBAAAAA==.',
['板鸭']='板鸭不吃鸭:BAAALgAECgMJAwAAAA==.',
['极限']='极限冰法:BAABLgAFFH8HAAIHAAMJyxmHFwC7AAAHAAMJyxmHFwC7AAAAAA==.极限水法:BAAALgAECgMJAwAAAA==.',
['林花']='林花谢春红:BAABLgAFFH8NAAIVAAUJYSKaBADpAQAVAAUJYSKaBADpAQAAAA==.',
['果然']='果然牛:BAAALgAECgIJAQAAAA==.',
['枫椛']='枫椛:BAABLgAFFH8HAAIRAAQJMBCRCgBYAQARAAQJMBCRCgBYAQAAAA==.',
['柒柒']='柒柒同学:BAAALgAECgcJEAAAAA==.',
['柔情']='柔情胖虎:BAAALgAECgYJEQAAAA==.',
['柠檬']='柠檬:BAAALgAECgIJBAAAAA==.',
['柯基']='柯基无解:BAABLgAECn8aAAIKAAcJXiNWBwALAgAKAAcJXiNWBwALAgAAAA==.',
['树屿']='树屿:BAAALgAECgQJAwAAAA==.',
['栗中']='栗中暴栗:BAAALgAECgQJAgAAAA==.',
['栗姜']='栗姜:BAABLgAECn8YAAIGAAYJQxsOLQCyAQAGAAYJQxsOLQCyAQAAAA==.',
['核动']='核动力战列舰:BAAALgAECgQJBgAAAA==.',
['根基']='根基图騰:BAAALgAFFAQJBAAAAA==.',
['格瓦']='格瓦拉:BAAALgAECgEJAQAAAA==.',
['格罗']='格罗姆哈格:BAAALgAECgYJCgAAAA==.',
['桃之']='桃之夭夭丨:BAAALgAECgMJAwAAAA==.',
['桃屋']='桃屋猫猫:BAAALgADCggJBwAAAA==.',
['桐间']='桐间纱路丶:BAAALgADCgEJAQAAAA==.',
['梦可']='梦可保:BAAALgADCgYJBgAAAA==.',
['梦萦']='梦萦灬寒烟丶:BAABLgAFFH8IAAIKAAQJbhZ3CwAXAQAKAAQJbhZ3CwAXAQAAAA==.',
['梦醒']='梦醒八分:BAABLgAECn8WAAMHAAkJ4x1oEQA/AwAHAAkJ4x1oEQA/AwAiAAIJLxNTFgBoAAAAAA==.梦醒时见你:BAAALgAECgYJBgAAAA==.',
['楚云']='楚云飞丶:BAABLgAFFH8HAAIDAAQJ8xmOBAAZAQADAAQJ8xmOBAAZAQAAAA==.',
['楚留']='楚留香:BAAALgAFFAEJAQABLgAFFAIJAgAJAAAAAA==.',
['楠哥']='楠哥大法:BAAALgADCgEJAQAAAA==.',
['橙多']='橙多多:BAAALgADCgUJBQAAAA==.',
['橙色']='橙色大树苗:BAACLgAFFH8FAAIaAAIJfyTsEgDSAAAaAAIJfyTsEgDSAAAuAAQKfxoAAhoABwkYJQoNANQCABoABwkYJQoNANQCAAEuAAUUAwkFAA4AISUA.',
['欧皇']='欧皇天花板:BAAALgAECgUJBQAAAA==.',
['欧阳']='欧阳菲儿:BAAALgAECgUJBQAAAA==.',
['欧鳇']='欧鳇:BAAALgADCgEJAQAAAA==.',
['歆嵐']='歆嵐:BAAALgAECgYJCAAAAA==.',
['武皇']='武皇雷帝尔:BAAALgAECgQJBAAAAA==.',
['歪嘴']='歪嘴战神:BAAALgAECgcJDQAAAA==.',
['死亡']='死亡之翼:BAAALgAECgYJBgAAAA==.',
['死灵']='死灵狂想家:BAAALgADCgcJBwAAAA==.',
['死神']='死神塔那托斯:BAAALgAECgYJBwAAAA==.死神小秘书:BAAALgAECgUJCQAAAA==.',
['殇之']='殇之灭世:BAAALgAECgcJDwAAAA==.',
['殇牧']='殇牧:BAAALgAECgcJCAAAAA==.',
['残雪']='残雪灬:BAAALgAECgEJAgAAAA==.',
['殷崇']='殷崇杰:BAAALgAECgIJAgAAAA==.',
['殺丶']='殺丶神:BAAALgAECgMJAwAAAA==.',
['毅帆']='毅帆小毛毛:BAAALgAFFAIJAwAAAA==.',
['毛晓']='毛晓毛:BAAALgAECgEJAgAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8IAAIOAAQJWyQ1BACtAQAOAAQJWyQ1BACtAQABLgAFFAUJKgAOAP8kAA==.',
['水动']='水动力皮划艇:BAAALgAECgcJCQAAAA==.',
['水哇']='水哇哇:BAAALgAFFAIJAwAAAA==.',
['水沝']='水沝淼友:BAAALgAFFAIJBAAAAA==.',
['氷蜜']='氷蜜桃:BAAALgAECgQJBQAAAA==.',
['求虐']='求虐求出名:BAAALgAECgYJBgAAAA==.',
['汉堡']='汉堡黑加仑款:BAAALgAECgkJBgAAAA==.',
['汤松']='汤松林:BAAALgADCggJCwABLgAFFAEJAgAJAAAAAA==.',
['沉於']='沉於浅夢不醉:BAAALgAFFAIJAwAAAA==.',
['沉默']='沉默之矮法:BAABLgAFFH8IAAIHAAQJhSBbDwCcAQAHAAQJhSBbDwCcAQAAAA==.',
['沐兰']='沐兰雪:BAAALgAECgUJBQAAAA==.',
['沐春']='沐春情缘:BAAALgAECgEJAQAAAA==.',
['沐頭']='沐頭秂:BAAALgAECgQJBgAAAA==.',
['沧琅']='沧琅泪:BAAALgAFFAEJAQAAAA==.',
['沫沫']='沫沫:BAAALgAECgEJAQAAAA==.',
['沭大']='沭大:BAABLgAECn8XAAMIAAkJ/iENBAB7AwAIAAkJ/iENBAB7AwASAAYJkhRAIwA+AQAAAA==.',
['油炸']='油炸丸子:BAAALgAECgMJBAAAAA==.油炸豆腐丶:BAAALgADCgQJBAAAAA==.',
['油焖']='油焖龙虾:BAAALgAECgYJDwAAAA==.',
['沼鹿']='沼鹿:BAAALgAECgQJBAAAAA==.',
['法羊']='法羊羊:BAABLgAECn8YAAIHAAkJ3BxrHAAEAwAHAAkJ3BxrHAAEAwAAAA==.',
['泡泡']='泡泡丨:BAAALgAECgYJBQAAAA==.',
['波波']='波波哈皮:BAAALgAECgcJBwAAAA==.',
['洋芋']='洋芋粑:BAAALgAECgcJBwAAAA==.',
['洛拉']='洛拉斯提利尔:BAAALgADCgQJBAAAAA==.',
['洛雪']='洛雪染东凌:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪风魂:BAAALgAECgYJCAAAAA==.',
['流萤']='流萤:BAABLgAFFH8NAAIfAAQJxBflBAAVAQAfAAQJxBflBAAVAQAAAA==.',
['浅唱']='浅唱丶素颜:BAAALgADCgMJAwAAAA==.',
['浅梦']='浅梦悠悠:BAAALgAECgUJBQAAAA==.',
['浪浪']='浪浪山小钻风:BAAALgAECgcJBwAAAA==.',
['消失']='消失的你:BAAALgAECgYJEgAAAA==.',
['消散']='消散的回忆:BAAALgAECgYJCQAAAA==.',
['液渔']='液渔丸家:BAAALgAECgYJEQAAAA==.',
['涵酱']='涵酱的凝视:BAAALgAFFAIJAwAAAA==.涵酱的守护:BAAALgAECgIJAgAAAA==.',
['深情']='深情告白:BAABLgAECn8UAAIHAAgJ0ROcWAAvAgAHAAgJ0ROcWAAvAgAAAA==.',
['清歌']='清歌问盏:BAAALgAECgEJAQAAAA==.',
['清辉']='清辉丶夜凝:BAAALgAECgEJAQAAAA==.',
['清醒']='清醒梦境之忆:BAAALgAECgEJAQAAAA==.',
['清风']='清风拂山岗:BAAALgAECgIJAgAAAA==.清风竹影丶:BAAALgAECgQJBAAAAA==.',
['温暖']='温暖的光明:BAAALgAECgMJBAAAAA==.',
['温柔']='温柔的闪避:BAAALgADCgEJAQAAAA==.温柔野:BAAALgAECgYJEQAAAA==.',
['温蕾']='温蕾萨丶霜刃:BAAALgADCgQJBAAAAA==.',
['湛海']='湛海:BAAALgAFFAEJAQAAAA==.',
['滑翔']='滑翔機:BAAALgAECgYJBgAAAA==.',
['滚滚']='滚滚吃尛孩儿:BAAALgAECgEJAQAAAA==.',
['滴溜']='滴溜溜:BAAALgAECgEJAQAAAA==.',
['漂流']='漂流:BAAALgAECgEJAQAAAA==.',
['演得']='演得你崩溃:BAAALgAECgkJDwAAAA==.',
['潇瑟']='潇瑟:BAAALgADCgUJBQAAAA==.',
['澡堂']='澡堂鼓手:BAAALgAFFAEJAwAAAA==.',
['激光']='激光制导:BAAALgADCgYJBgAAAA==.',
['灀芷']='灀芷哀傷:BAAALgAECgEJAQAAAA==.',
['火星']='火星种萝卜:BAAALgAFFAEJAQAAAA==.',
['火柴']='火柴棍将军:BAAALgADCgUJBQAAAA==.',
['灬净']='灬净莲妖火灬:BAAALgAECgEJAQAAAA==.',
['灬司']='灬司音灬:BAAALgADCgMJAwAAAA==.',
['灬小']='灬小屁孩灬:BAAALgAECgYJBwAAAA==.',
['灬猎']='灬猎手灬:BAAALgAECgUJBQAAAA==.',
['灬魂']='灬魂之挽歌:BAABLgAFFH8JAAILAAUJbBihAwB/AQALAAUJbBihAwB/AQAAAA==.',
['灭烬']='灭烬:BAAALgADCgEJAQAAAA==.',
['灰雪']='灰雪灰雪:BAAALgAECgUJBQAAAA==.',
['灵訫']='灵訫:BAAALgAECgcJCgAAAA==.',
['灵魂']='灵魂外卖员:BAAALgAECgMJAwAAAA==.',
['炼天']='炼天:BAAALgAECgEJAQAAAA==.',
['炽焰']='炽焰土豆:BAAALgAECgYJBgAAAA==.',
['烈焰']='烈焰风暴:BAAALgAFFAIJAgAAAA==.',
['烹饪']='烹饪大师:BAAALgAECgIJAgAAAA==.',
['無尽']='無尽爆破:BAAALgAECgkJCwAAAA==.',
['無所']='無所窎鰃:BAAALgAECgcJBwAAAA==.',
['無痕']='無痕丶四月:BAAALgAECgEJBAAAAA==.',
['無雙']='無雙乄蛋蛋:BAAALgADCgUJBQAAAA==.',
['煮酒']='煮酒丶:BAAALgADCgMJAwAAAA==.',
['熊晓']='熊晓不吃饭:BAAALgAECgUJCAAAAA==.',
['熊猫']='熊猫小瞎:BAAALgAFFAMJAwAAAA==.',
['熢火']='熢火裢荿:BAAALgAECgEJAQAAAA==.',
['燃烧']='燃烧的白咖啡:BAABLgAFFH8HAAIEAAQJ3BkCDQD1AAAEAAQJ3BkCDQD1AAAAAA==.',
['爆猎']='爆猎:BAAALgADCgEJAQAAAA==.',
['爬墙']='爬墙觅红杏:BAAALgAECgYJBwAAAA==.',
['爱人']='爱人错过:BAAALgAFFAIJAgAAAA==.',
['爱前']='爱前女友无罪:BAAALgAECgEJAgAAAA==.',
['爱抽']='爱抽瑞克五:BAAALgAECgIJAgAAAA==.爱抽黄鹤楼:BAAALgADCgUJBQABLgAECgIJAgAJAAAAAA==.',
['爱放']='爱放长假:BAAALgAECgIJAwAAAA==.',
['爱无']='爱无反顾:BAAALgAECgYJBgAAAA==.',
['爱莉']='爱莉希雅:BAAALgAECgQJBAAAAA==.',
['爱雪']='爱雪儿:BAAALgAECgYJCgAAAA==.',
['牛丨']='牛丨丨妞:BAAALgAECgQJBAAAAA==.',
['牛也']='牛也有梦想:BAABLgAECn8dAAIRAAcJbB2JEgCOAQARAAcJbB2JEgCOAQAAAA==.',
['牛二']='牛二骑:BAAALgAECgUJCAAAAA==.',
['牛牛']='牛牛爱小崽:BAAALgAECgEJAQAAAA==.',
['狂之']='狂之岚寳寳:BAAALgAECgYJCQAAAA==.',
['狂战']='狂战莱莱:BAABLgAECn8XAAIMAAcJYyPZDQDmAgAMAAcJYyPZDQDmAgAAAA==.',
['狇狇']='狇狇:BAAALgAECgQJBAAAAA==.',
['狩獵']='狩獵妳啲訫:BAAALgAECgkJDQAAAA==.',
['狮子']='狮子座肾骑士:BAAALgAECgMJAwAAAA==.',
['猎之']='猎之祭:BAAALgAECgIJAQAAAA==.',
['猛击']='猛击小白花:BAAALgAECgUJEAAAAA==.',
['猫咪']='猫咪好好吃:BAABLgAFFH8GAAIWAAIJbSGEEgC4AAAWAAIJbSGEEgC4AAAAAA==.猫咪稀饭:BAABLgAECn8XAAQQAAgJJRizFgAmAgAQAAcJpBqzFgAmAgAPAAYJvw2sDwD7AAAOAAEJJQOEXAApAAAAAA==.',
['獸猛']='獸猛戰:BAAALgAECgYJCgAAAA==.',
['玛秋']='玛秋:BAAALgAECgcJAwABLgAFFAYJBgAVAGIaAA==.',
['琉璃']='琉璃浅夏:BAABLgAFFH8FAAIPAAMJXiH/CAAxAQAPAAMJXiH/CAAxAQAAAA==.',
['璐璐']='璐璐艾露莎:BAAALgAECgYJBwAAAA==.',
['瓦里']='瓦里安丶血丁:BAAALgAECgEJAQAAAA==.',
['甘小']='甘小小:BAAALgAECgQJBAAAAA==.',
['甲乌']='甲乌王:BAAALgAFFAEJAQAAAA==.',
['电羊']='电羊羊:BAAALgAECgkJCwABLgAFFAcJCQACALslAA==.',
['电萨']='电萨在线刮痧:BAAALgAECgYJCQAAAA==.',
['疯狂']='疯狂的毛毛:BAAALgADCgUJBQAAAA==.',
['疾乄']='疾乄风:BAAALgAFFAEJAQAAAA==.',
['疾风']='疾风云手:BAAALgADCgkJCQAAAA==.疾风魔狼:BAAALgAFFAIJAgAAAA==.',
['癫佬']='癫佬丶:BAAALgAECgcJCAAAAA==.',
['白夜']='白夜梦幻:BAAALgAECgYJCwAAAA==.',
['白头']='白头发:BAABLgAFFH8FAAMKAAIJERc+PwChAAAKAAIJWBI+PwChAAAdAAIJxQxzAgBYAAAAAA==.',
['白月']='白月梵星:BAAALgAECgMJAwAAAA==.',
['白色']='白色琴弦:BAAALgAECgYJDAAAAA==.',
['百八']='百八的衣服架:BAAALgAECgQJCAAAAA==.',
['百步']='百步穿歪:BAAALgAECgEJAgAAAA==.',
['皇上']='皇上皇:BAAALgAECgUJCgAAAA==.',
['皮丨']='皮丨灬卡丘丶:BAAALgAECgQJBAAAAA==.',
['盖鯮']='盖鯮盖:BAAALgAECgYJBgAAAA==.',
['盘尼']='盘尼西林:BAAALgAECgEJAQAAAA==.',
['看看']='看看哪里:BAAALgAECgcJCAAAAA==.',
['真的']='真的怕你了:BAABLgAFFH8DAAIIAAIJFB+bFwCsAAAIAAIJFB+bFwCsAAAAAA==.',
['真诚']='真诚的龟宝宝:BAAALgAECgEJAgAAAA==.',
['眼镜']='眼镜哥哥:BAAALgAECgYJCwAAAA==.',
['睿智']='睿智的窝头:BAABLgAECn8VAAIWAAcJUSFKEAC4AgAWAAcJUSFKEAC4AgAAAA==.',
['瞌睡']='瞌睡醒了:BAAALgAECgIJAgAAAA==.',
['砂狼']='砂狼白子:BAAALgAECgEJAQAAAA==.',
['砂糖']='砂糖橘:BAAALgAECgcJBwAAAA==.',
['砍脑']='砍脑壳呢丶:BAAALgAECgkJCQAAAA==.',
['破晓']='破晓煦光:BAAALgAECgcJBwAAAA==.',
['砸瓦']='砸瓦鲁多:BAAALgADCgEJAQAAAA==.',
['确实']='确实是呆:BAAALgAECgQJBAAAAA==.',
['磨刀']='磨刀寸头:BAAALgADCgQJAwAAAA==.磨刀砍柴:BAAALgADCgUJBQAAAA==.',
['神也']='神也会输:BAAALgAECgEJAQAAAA==.',
['神圣']='神圣圣光骑:BAAALgAECgcJCQAAAA==.',
['神射']='神射手刀疤:BAAALgAECgYJCAAAAA==.',
['秃秃']='秃秃寺涌馨:BAAALgAECgIJAwAAAA==.',
['秋刀']='秋刀鱼:BAAALgAECgYJBwABLgAFFAIJBAAJAAAAAA==.',
['秋叶']='秋叶为谁而落:BAABLgAECn8UAAIKAAcJqhZkXQDaAQAKAAcJqhZkXQDaAQAAAA==.',
['科学']='科学怪熊:BAAALgAECgUJCwAAAA==.',
['科斯']='科斯塔库塔:BAAALgAFFAIJBAAAAA==.',
['空想']='空想具现化:BAAALgAECgYJBgAAAA==.',
['空格']='空格歼灭者:BAAALgAECgYJCAAAAA==.',
['童貞']='童貞卒業:BAAALgAECgEJAQAAAA==.',
['第四']='第四次历险:BAAALgAFFAIJAgAAAA==.',
['简娜']='简娜:BAACLgAFFH8HAAIHAAQJPRhdGABoAQAHAAQJPRhdGABoAQAuAAQKfyYAAgcACAmBIrcbAAgDAAcACAmBIrcbAAgDAAAA.',
['箛啴']='箛啴的仔仔:BAAALgADCgIJAgAAAA==.',
['箭尾']='箭尾:BAAALgAECgIJBAAAAA==.',
['米兰']='米兰巴斯滕:BAAALgAECgUJEAAAAA==.米兰马尔蒂尼:BAABLgAFFH8HAAIWAAMJGxaaCgANAQAWAAMJGxaaCgANAQAAAA==.',
['米奈']='米奈希尔之怒:BAAALgAECgUJBQAAAA==.',
['米莉']='米莉森的锋刃:BAACLgAFFH8FAAIjAAUJ3gyhAgCHAQAjAAUJ3gyhAgCHAQAuAAQKfxsAAhcABwkUHHAYAPsBABcABwkUHHAYAPsBAAAA.',
['粉羊']='粉羊羊:BAAALgAECgcJBwAAAA==.',
['粪海']='粪海卝狂蛆:BAAALgADCgMJAwAAAA==.',
['糊涂']='糊涂大羽:BAAALgADCgIJAgAAAA==.糊涂大雨:BAAALgADCgQJBAAAAA==.',
['糖大']='糖大梁:BAAALgAECgMJAwAAAA==.',
['糖霜']='糖霜苹果:BAAALgAECgUJBQAAAA==.',
['糟辣']='糟辣子:BAAALgAECgUJCQAAAA==.',
['紫刹']='紫刹:BAAALgADCgYJBgAAAA==.',
['紫苏']='紫苏炖黄鲤:BAAALgAECgUJBQAAAA==.',
['紫魅']='紫魅瞳灵:BAAALgADCgYJBgAAAA==.',
['繁华']='繁华尽染:BAAALgAECgYJCQAAAA==.',
['红眼']='红眼小白龙:BAABLgAECn8VAAIYAAgJdhr7CgBhAgAYAAgJdhr7CgBhAgAAAA==.',
['红色']='红色寒冰箭:BAAALgADCgEJAQAAAA==.',
['红门']='红门红门红门:BAAALgAECgIJAgAAAA==.',
['红颜']='红颜丶殁:BAAALgAECgYJBwAAAA==.',
['纪念']='纪念小明:BAAALgAECgcJBwAAAA==.',
['纯情']='纯情小小晓:BAAALgAECgQJBAAAAA==.',
['纯色']='纯色丶:BAAALgAECgUJBQAAAA==.',
['纳兰']='纳兰若熙:BAAALgADCgYJCAAAAA==.',
['纽伦']='纽伦堡大海绵:BAAALgAECgIJAgAAAA==.',
['给我']='给我擦皮鞋:BAAALgAFFAMJAwABLgAFFAQJBwADAPMZAA==.给我甜虾面:BAAALgADCgEJAQAAAA==.',
['绝倫']='绝倫義父:BAAALgADCgYJBgAAAA==.',
['绝命']='绝命导爆:BAABLgAFFH8LAAIGAAQJliQ1BACjAQAGAAQJliQ1BACjAQAAAA==.',
['绯然']='绯然灬暖凉:BAAALgAECgEJAgAAAA==.',
['绿之']='绿之挽歌:BAAALgAECgEJAgAAAA==.',
['绿皮']='绿皮小倩:BAABLgAFFH8PAAIGAAUJVRRiBQCHAQAGAAUJVRRiBQCHAQAAAA==.',
['绿色']='绿色丨残骸:BAAALgAECgYJDQAAAA==.绿色小鬼:BAAALgAECgUJBwAAAA==.',
['缭乱']='缭乱的烟火:BAAALgAECgIJAgAAAA==.',
['罗仕']='罗仕煾:BAAALgAECgQJBAAAAA==.',
['美妞']='美妞儿:BAAALgAFFAEJAQABLgAFFAEJAgAJAAAAAA==.',
['美滋']='美滋滋灬:BAAALgAECggJDgAAAA==.',
['義妹']='義妹小悪魔:BAAALgAECgQJCAAAAA==.',
['翠焰']='翠焰切:BAAALgAECgEJAQAAAA==.',
['老王']='老王说走就走:BAAALgAECgEJAgAAAA==.',
['联盟']='联盟保卫战:BAAALgAECgUJBgAAAA==.',
['聖歌']='聖歌:BAAALgADCgIJAgAAAA==.',
['聖騎']='聖騎士丶:BAAALgAECgEJAQAAAA==.',
['聚光']='聚光灯往这打:BAAALgADCgYJBQAAAA==.',
['聪明']='聪明得小美女:BAAALgAECgYJEwAAAA==.',
['肆億']='肆億少女的夢:BAAALgADCgIJAgAAAA==.',
['肉票']='肉票:BAAALgADCgUJBQAAAA==.',
['胎神']='胎神:BAAALgAECgQJBgAAAA==.',
['胖皮']='胖皮胖:BAAALgAECgQJBwAAAA==.',
['胜道']='胜道七千雪:BAACLgAFFH8HAAIHAAIJcx2aMwDMAAAHAAIJcx2aMwDMAAAuAAQKfxgAAgcABgmIINtjABECAAcABgmIINtjABECAAAA.',
['脱缰']='脱缰的丶野馬:BAAALgAECgIJAgAAAA==.',
['自己']='自己爬起来:BAABLgAFFH8FAAIOAAQJNQUrDQD6AAAOAAQJNQUrDQD6AAAAAA==.',
['自游']='自游:BAAALgADCgIJAgAAAA==.',
['舍脂']='舍脂多:BAAALgAECgEJAQAAAA==.',
['舞男']='舞男:BAAALgAECgYJCAAAAA==.',
['艾薇']='艾薇莉亚:BAABLgAFFH8HAAIWAAQJQxGsBABXAQAWAAQJQxGsBABXAQAAAA==.',
['芝士']='芝士红薯:BAABLgAFFH8FAAMWAAMJhRqfEQC9AAAWAAMJhRqfEQC9AAAVAAEJAw+pJQBSAAAAAA==.',
['芣冷']='芣冷:BAAALgADCgUJBQAAAA==.',
['芭吶']='芭吶吶:BAAALgAFFAEJAQAAAA==.',
['花一']='花一枝:BAAALgAECgQJBgAAAA==.',
['花岗']='花岗岩丶:BAAALgAECgkJEAAAAA==.',
['花木']='花木九里虎丶:BAAALgAECgIJAgAAAA==.',
['花满']='花满楼氵:BAAALgADCgMJAwAAAA==.',
['花田']='花田蜜桃乌龙:BAAALgAECgIJAgAAAA==.',
['花荩']='花荩千霜黙:BAAALgAFFAQJBAAAAA==.',
['花辞']='花辞:BAAALgAECgUJCgAAAA==.',
['苏小']='苏小德:BAAALgAECgQJBQAAAA==.',
['若宫']='若宫诗畅:BAAALgAECgQJBQAAAA==.',
['若风']='若风倾雨:BAAALgAECgYJBgAAAA==.',
['荒川']='荒川:BAAALgAECgUJBwAAAA==.',
['荣耀']='荣耀之战:BAAALgADCgEJAQAAAA==.',
['莉维']='莉维亚桑:BAAALgAECgQJBAAAAA==.',
['莎弥']='莎弥拉:BAAALgAECgUJBQAAAA==.',
['莫小']='莫小四丶死骑:BAAALgAECggJCQAAAA==.',
['莫格']='莫格莱尼哥:BAAALgAECgEJAQAAAA==.',
['莫离']='莫离:BAAALgAECgYJCwAAAA==.',
['莱安']='莱安娜丶霜刃:BAAALgADCgkJCQAAAA==.',
['莽汉']='莽汉王:BAABLgAECn8aAAMEAAYJbxrCWgCRAQAEAAYJ/BfCWgCRAQAfAAUJtxX1OAAfAQAAAA==.',
['萌萌']='萌萌灬惩戒:BAABLgAFFH8GAAIRAAIJfBQQEAClAAARAAIJfBQQEAClAAAAAA==.萌萌的兔筱喵:BAABLgAFFH8GAAIaAAQJBiUMAwC5AQAaAAQJBiUMAwC5AQAAAA==.萌萌的胖子丶:BAABLgAFFH8HAAIUAAMJHRMBEwDhAAAUAAMJHRMBEwDhAAAAAA==.',
['萝卜']='萝卜战:BAAALgAECgYJBgAAAA==.',
['萝莉']='萝莉小猛德:BAAALgAECgMJBAAAAA==.',
['萧萧']='萧萧历历:BAABLgAFFH8FAAIWAAMJfBuODwDLAAAWAAMJfBuODwDLAAAAAA==.',
['萨勒']='萨勒个满:BAAALgAECgYJCAAAAA==.',
['落日']='落日云清:BAAALgADCgYJBgAAAA==.',
['蒂域']='蒂域咆哮:BAAALgADCgEJAQAAAA==.',
['蓝染']='蓝染的染:BAAALgAECgMJBQAAAA==.',
['虚空']='虚空莱莱:BAAALgAECgYJBgAAAA==.',
['虞果']='虞果:BAAALgAECgkJCAAAAA==.',
['蚂蚁']='蚂蚁的奶爸:BAAALgAECgYJCQAAAA==.蚂蚁的耳坠:BAAALgAECgEJAQAAAA==.',
['蛋蛋']='蛋蛋大哥:BAAALgAECgYJDwAAAA==.',
['蜂蜜']='蜂蜜柚子貓:BAAALgADCgYJBgABLgAFFAQJBwAbAPUSAA==.',
['蜘蛛']='蜘蛛侠我来做:BAAALgAFFAMJBAAAAA==.',
['蜜小']='蜜小桃:BAAALgAECgIJAwAAAA==.',
['蜜蜂']='蜜蜂蜇了真痛:BAAALgAECgEJAQAAAA==.',
['蜡笔']='蜡笔不小新:BAAALgADCgYJAwAAAA==.',
['蠕动']='蠕动的荣誉:BAAALgAECgEJAQAAAA==.',
['血戟']='血戟圣骑:BAAALgAFFAQJBAAAAA==.',
['血殤']='血殤:BAAALgAECgMJBAAAAA==.',
['血的']='血的海洋:BAAALgAECgcJDgAAAA==.',
['行者']='行者丶冰锋:BAABLgAFFH8LAAIKAAQJchF4BgBYAQAKAAQJchF4BgBYAQAAAA==.',
['西城']='西城小可爱:BAAALgAECgEJAQAAAA==.',
['西爷']='西爷:BAAALgAECgUJBQAAAA==.',
['觉北']='觉北风二号机:BAAALgAECgYJDwAAAA==.',
['诗七']='诗七言:BAAALgAECgcJAQAAAA==.',
['诡笑']='诡笑:BAAALgAECgYJDwAAAA==.',
['该昵']='该昵称已过审:BAAALgAFFAEJAQAAAA==.该昵称未过审:BAAALgAECgQJBwABLgAFFAEJAQAJAAAAAA==.',
['诺卿']='诺卿璇:BAAALgAECgYJCwAAAA==.',
['诺小']='诺小僧:BAAALgADCgIJAgAAAA==.',
['读条']='读条慢但特猛:BAACLgAFFH8IAAIHAAMJrCD3IgAuAQAHAAMJrCD3IgAuAQAuAAQKfx0AAgcABgngI/lHAF8CAAcABgngI/lHAF8CAAAA.',
['谜之']='谜之杀马特:BAAALgAECgEJAQAAAA==.',
['谢跑']='谢跑跑啊:BAAALgAECgEJAQAAAA==.',
['豇豆']='豇豆米米:BAAALgAFFAEJAQAAAA==.',
['贝里']='贝里玛列斯:BAAALgADCgYJBgAAAA==.',
['贩冰']='贩冰冰:BAAALgAECgYJDwAAAA==.',
['赛巴']='赛巴多拉贡:BAAALgAFFAEJAQAAAA==.',
['赤月']='赤月奇迹:BAAALgAECgcJBwAAAA==.',
['赤红']='赤红魅影:BAAALgAFFAIJAwAAAA==.',
['赤色']='赤色丶彗星:BAAALgAECgQJBAAAAA==.',
['赦天']='赦天琴箕:BAAALgADCgEJAQAAAA==.',
['走着']='走着走着脱臼:BAAALgAECgUJBQAAAA==.',
['超出']='超出配送范围:BAAALgAFFAQJBAAAAA==.',
['超大']='超大杯:BAAALgAECgcJCwAAAA==.',
['超威']='超威枭炮:BAAALgAFFAEJAQABLgAECggJGgAYAEQdAA==.',
['超瘦']='超瘦侠:BAAALgADCgUJBQABLgAFFAEJAQAJAAAAAA==.',
['超自']='超自然睡觉:BAAALgAECggJCAAAAA==.',
['跳得']='跳得最高:BAAALgAECgEJAQAAAA==.',
['踏雪']='踏雪无踪:BAAALgAECgYJEAAAAA==.',
['蹦了']='蹦了真君:BAABLgAECn8WAAIbAAYJuxTRMACCAQAbAAYJuxTRMACCAQAAAA==.',
['转就']='转就完了丶:BAAALgAFFAIJAgAAAA==.',
['还你']='还你女儿身丶:BAAALgADCgEJAQAAAA==.',
['还是']='还是做不到吗:BAAALgAECgYJCAAAAA==.',
['远行']='远行的祝福:BAAALgAECgcJBwAAAA==.',
['迷恋']='迷恋圣光:BAAALgAECgEJAQAAAA==.',
['迷雾']='迷雾重重:BAAALgADCgUJBQAAAA==.',
['追想']='追想者:BAAALgAECgYJBgAAAA==.',
['逆流']='逆流刃:BAAALgAECgYJCgAAAA==.',
['逐光']='逐光:BAAALgAECgYJBgAAAA==.',
['逗逗']='逗逗猪:BAAALgAECgkJCQAAAA==.',
['遁入']='遁入虚空:BAACLgAFFH8NAAIEAAQJEB1UDABxAQAEAAQJEB1UDABxAQAuAAQKfxUAAwQABwl4IMIlAHACAAQABwl4IMIlAHACAB8AAQm/GQlnAEgAAAAA.',
['遗忘']='遗忘无间:BAAALgAECgMJAwAAAA==.',
['遗憾']='遗憾:BAAALgAFFAIJAgAAAA==.',
['邓紫']='邓紫骑:BAAALgAECgMJBwAAAA==.',
['那些']='那些花儿丶:BAAALgAECgQJAwAAAA==.',
['那滋']='那滋盖尔:BAAALgAECgYJBwABLgAFFAYJEAAFANsjAA==.',
['邪恶']='邪恶猎手:BAAALgAECgEJAgAAAA==.',
['邪斩']='邪斩:BAAALgAECgYJCAAAAA==.',
['鄙人']='鄙人不善奔跑:BAAALgAFFAQJAwAAAA==.',
['酒丶']='酒丶狂:BAAALgAECgMJAwAAAA==.',
['酒都']='酒都丶驸马爷:BAAALgAECgEJAQAAAA==.',
['酸核']='酸核检测员:BAAALgADCgYJBgAAAA==.',
['酿酒']='酿酒师傅鸡丝:BAAALgAECgYJBgAAAA==.',
['醉后']='醉后的葱油饼:BAAALgAECgEJAgAAAA==.',
['醉里']='醉里望雪:BAAALgAECgYJCgAAAA==.',
['重铬']='重铬酸钾:BAAALgAFFAIJAgAAAA==.',
['钟声']='钟声为谁而鸣:BAAALgADCgYJBgAAAA==.',
['钦瀚']='钦瀚爱静静:BAAALgADCgYJBgAAAA==.',
['铃鹿']='铃鹿御前:BAABLgAFFH8JAAIIAAQJMxINEwBQAQAIAAQJMxINEwBQAQAAAA==.',
['锅盖']='锅盖镇河妖:BAAALgAFFAIJAgAAAA==.',
['错别']='错别字:BAAALgAECgUJCAAAAA==.',
['长琴']='长琴无焰:BAABLgAFFH8GAAIEAAMJRhC4HQDnAAAEAAMJRhC4HQDnAAAAAA==.',
['闪电']='闪电瓜牛:BAAALgAECgQJCQAAAA==.',
['闪耀']='闪耀地狱:BAAALgAECgIJAQAAAA==.',
['阳光']='阳光一百:BAAALgAECgIJAwAAAA==.',
['阿严']='阿严丶:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔萨絲:BAAALgADCgEJAQAAAA==.',
['阿恶']='阿恶:BAAALgAECgYJCAAAAA==.',
['阿憯']='阿憯:BAAALgAECgcJDwAAAA==.',
['阿比']='阿比盖尔亲:BAACLgAFFH8XAAILAAYJmhdfAgCwAQALAAYJmhdfAgCwAQAuAAQKfyQAAgsACQk8HrEEAP0CAAsACQk8HrEEAP0CAAAA.',
['阿狩']='阿狩:BAAALgAECgYJBgAAAA==.',
['阿玛']='阿玛忒拉斯:BAAALgAECgEJAQAAAA==.',
['阿瑶']='阿瑶瑶:BAAALgAECgcJAQAAAA==.',
['阿瘸']='阿瘸蜥蜴:BAAALgAECgYJCwAAAA==.',
['阿离']='阿离丷:BAAALgAECgQJBAAAAA==.',
['阿莽']='阿莽:BAAALgAECgEJAQAAAA==.',
['陨落']='陨落辰星:BAAALgAECgkJCQAAAA==.',
['陶爷']='陶爷爷:BAAALgAECgUJCwAAAA==.',
['随便']='随便丨逛逛:BAAALgAECgQJBgAAAA==.',
['隐遁']='隐遁才玩联盟:BAAALgAECgEJAgAAAA==.',
['雅儿']='雅儿呗德:BAAALgAFFAQJBAAAAA==.',
['雇佣']='雇佣军丨列兵:BAABLgAECn8dAAMKAAYJVBxBZADHAQAKAAYJVBxBZADHAQALAAMJ+QkYTAAeAAAAAA==.',
['雨言']='雨言:BAAALgAECgQJDQAAAA==.',
['雪色']='雪色无敌:BAAALgAECgMJBgAAAA==.',
['雲淡']='雲淡丶風輕:BAAALgAECgcJDQAAAA==.',
['零下']='零下四度:BAAALgAECgYJCgAAAA==.',
['零个']='零个耳环:BAAALgAECgEJAQAAAA==.',
['零度']='零度战姬:BAAALgAECgEJAQAAAA==.',
['霍元']='霍元甲:BAAALgAFFAEJAgAAAA==.',
['霜之']='霜之飘渺:BAABLgAFFH8GAAIHAAIJHA8QPgCwAAAHAAIJHA8QPgCwAAAAAA==.',
['霹雳']='霹雳豆豆:BAAALgAECgQJCAAAAA==.',
['靈美']='靈美:BAAALgAECgYJEgAAAA==.',
['青云']='青云志:BAAALgADCgQJBAAAAA==.',
['青山']='青山墨落画卷:BAAALgAECgEJAQABLgAFFAIJAwAJAAAAAA==.',
['青眼']='青眼钢甲龙:BAAALgADCgYJBgAAAA==.',
['青色']='青色归来:BAAALgAECgYJDQAAAA==.青色织雾:BAAALgAECgYJCwAAAA==.',
['非洲']='非洲扣脚大汉:BAAALgAECgcJBwAAAA==.',
['靡靡']='靡靡狡童:BAAALgADCgYJBgAAAA==.',
['韦恩']='韦恩:BAABLgAFFH8FAAMWAAMJ/A9cFwCpAAAWAAIJIg1cFwCpAAAVAAIJoBEaHQChAAAAAA==.',
['须跋']='须跋陀罗:BAAALgAECgkJCQAAAA==.',
['風絮']='風絮:BAAALgAECgcJCQAAAA==.',
['風華']='風華絕代:BAABLgAFFH8IAAIPAAMJnCHICAA3AQAPAAMJnCHICAA3AQAAAA==.',
['风之']='风之河马:BAAALgAECgkJDwAAAA==.',
['风後']='风後:BAAALgAFFAEJAgAAAA==.',
['风暴']='风暴追逐者:BAAALgAECgEJAQAAAA==.',
['风火']='风火山林:BAAALgAFFAEJAQAAAA==.',
['风灵']='风灵月影:BAAALgAECgIJAgABLgAFFAYJFgAIAA8mAA==.',
['风骚']='风骚静香:BAAALgAECgEJAQAAAA==.',
['飒飒']='飒飒之风:BAAALgAECgEJAQAAAA==.',
['飘逸']='飘逸如法:BAAALgADCgYJBgAAAA==.',
['飛龍']='飛龍:BAAALgAFFAEJAQAAAA==.',
['飞天']='飞天小鹏鹏:BAAALgADCgEJAQAAAA==.飞天茅抬:BAAALgAECgkJCQAAAA==.',
['飞来']='飞来飞去丶:BAAALgAFFAIJAwAAAA==.',
['飞鸣']='飞鸣镝:BAAALgAECgMJAwAAAA==.',
['首席']='首席划水大师:BAAALgAECgEJAQAAAA==.',
['驚鴻']='驚鴻照影:BAAALgADCgYJBgAAAA==.',
['马二']='马二娃:BAACLgAFFH8GAAIQAAMJpyP1CgC0AAAQAAMJpyP1CgC0AAAuAAQKfxUAAhAABgkoI+4QAFwCABAABgkoI+4QAFwCAAAA.',
['马冬']='马冬什么丶:BAAALgAFFAQJBAAAAA==.',
['马路']='马路子:BAAALgAECgYJCgAAAA==.',
['马踏']='马踏富士山脚:BAABLgAFFH8KAAIRAAMJNhMaGADtAAARAAMJNhMaGADtAAAAAA==.',
['鬼术']='鬼术:BAAALgAECgEJAgAAAA==.',
['魔术']='魔术:BAABLgAFFH8HAAIIAAMJiRwEDAATAQAIAAMJiRwEDAATAQAAAA==.',
['魔王']='魔王夜莺:BAAALgAECgEJAQAAAA==.',
['魔龙']='魔龙之心:BAAALgAECgEJAQAAAA==.',
['鱼柱']='鱼柱纯:BAAALgAECgcJEAAAAA==.',
['鸢一']='鸢一折纸:BAAALgAECgEJAQAAAA==.',
['麛鐷']='麛鐷灬鐃孱:BAAALgAECgcJCgAAAA==.',
['麦麦']='麦麦撒:BAAALgAECgYJBgAAAA==.',
['黄炸']='黄炸坨子:BAAALgAFFAIJBAAAAA==.',
['黄瞳']='黄瞳先生:BAAALgADCgEJAQAAAA==.',
['黑漆']='黑漆漆的夜:BAAALgAECgYJBwAAAA==.',
['黑牛']='黑牛上线干架:BAAALgADCgEJAQAAAA==.',
['黑猫']='黑猫的土灭霸:BAAALgAECgEJAQAAAA==.黑猫的黑骑士:BAAALgAECgcJDQAAAA==.黑猫迪诶曲:BAAALgADCgEJAQAAAA==.黑猫黑猫:BAAALgAECgUJBQAAAA==.',
['黑蝉']='黑蝉:BAAALgAECgIJAgAAAA==.',
['黑豆']='黑豆儿:BAAALgADCgEJAQAAAA==.',
['黑雪']='黑雪丶妖梦:BAAALgADCgIJAgAAAA==.',
['龍一']='龍一:BAACLgAFFH8SAAMGAAUJjx03BwBmAQAGAAQJjx03BwBmAQAFAAEJSgCnEwAtAAAuAAQKfxcAAgYACQkgI8YFADgDAAYACQkgI8YFADgDAAAA.',
['龍哮']='龍哮天:BAAALgAECgEJAQAAAA==.',
['龙大']='龙大奇:BAAALgAFFAEJAgAAAA==.',
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
