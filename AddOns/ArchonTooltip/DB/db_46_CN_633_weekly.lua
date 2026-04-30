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

local lookup = {'Monk-Brewmaster','Unknown-Unknown','Rogue-Subtlety','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Paladin-Holy','Hunter-Marksmanship','Warlock-Demonology','Warlock-Affliction','Rogue-Assassination','Rogue-Outlaw','Priest-Holy','Warlock-Destruction','Shaman-Elemental','Druid-Guardian','Hunter-BeastMastery','Warrior-Protection','Warrior-Fury','Shaman-Restoration','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Druid-Balance','Druid-Restoration','Warrior-Arms','Monk-Windwalker','DemonHunter-Devourer','DemonHunter-Havoc','Priest-Discipline','Druid-Feral','DeathKnight-Blood','Paladin-Protection','Monk-Mistweaver','Priest-Shadow','Mage-Arcane','DemonHunter-Vengeance',}
local provider = {region='CN',realm='天空之墙',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alteracspiri:BAAALgADCgQJBAAAAA==.',
Aq='Aqua:BAAALgAFFAEJAQAAAA==.',
As='Asipilim:BAAALgAECgQJBAAAAA==.Asmartin:BAAALgAECgQJDAAAAA==.Asukaa:BAAALgAECgEJAQAAAA==.',
Ba='Baaks:BAAALgAFFAIJAwAAAA==.',
Bi='Biabiabia:BAABLgAFFH8HAAIBAAMJEA5GCQDNAAABAAMJEA5GCQDNAAABLgAFFAcJBAACAAAAAA==.',
Bo='Bomomomom:BAAALgAECgUJBQAAAA==.Bowow:BAAALgAECgcJAQAAAA==.Bowwoww:BAAALgAECgQJBAAAAA==.',
Br='Braboy:BAAALgAECgEJAQAAAA==.Brutal:BAABLgAFFH8HAAIDAAMJ1w1CDwD8AAADAAMJ1w1CDwD8AAABLgAFFAUJDQAEAC8WAA==.',
Cc='Cclook:BAAALgAECgEJAQAAAA==.',
Cl='Claymoers:BAAALgAFFAIJBAAAAA==.',
Co='Coisini:BAAALgAFFAUJAgAAAA==.',
Cr='Crazypang:BAACLgAFFH8IAAIFAAMJjhLMFQD8AAAFAAMJjhLMFQD8AAAuAAQKfx8AAgUABwkbHTI3AEYCAAUABwkbHTI3AEYCAAAA.Crazystory:BAAALgAECgYJBwAAAA==.',
Da='Dalek:BAAALgAECgEJAQAAAA==.Dawntime:BAAALgAECgEJAQAAAA==.',
Dc='Dcz:BAAALgAECgEJAQAAAA==.',
De='Demonphantom:BAAALgAECgMJAwAAAA==.Derder:BAAALgADCgEJAQAAAA==.',
Df='Dfljsdf:BAAALgAFFAIJAgAAAA==.',
Dr='Drakepigg:BAAALgAECgEJAQAAAA==.Drakflame:BAAALgAECgkJAgAAAA==.',
Ds='Dsyhsy:BAAALgAECgYJBwAAAA==.',
Du='Durotann:BAAALgAECgYJEAAAAA==.',
Ev='Evildeed:BAAALgAECgUJCwAAAA==.',
Ex='Exome:BAAALgAECgEJAgAAAA==.',
Fa='Fabiano:BAAALgAECgYJDwAAAA==.',
Gu='Guernika:BAAALgAECgYJCgAAAA==.',
Ha='Haisi:BAAALgAECgcJBwAAAA==.Handou:BAAALgADCgYJBgAAAA==.',
Hi='Hiioojjkk:BAAALgAECgQJAwAAAA==.',
Ho='Hopeless:BAAALgAECgUJBQAAAA==.',
Hu='Humbertzyl:BAABLgAFFH8FAAIGAAIJwh5kNADGAAAGAAIJwh5kNADGAAAAAA==.',
Ic='Iceheart:BAABLgAFFH8FAAIEAAIJpxdzQgCdAAAEAAIJpxdzQgCdAAAAAA==.',
Ik='Ikk:BAAALgAECgIJAgAAAA==.',
Il='Illenium:BAAALgAECgcJBwAAAA==.',
Ji='Jimssxol:BAAALgAFFAEJAQAAAA==.',
Li='Linvp:BAACLgAFFH8PAAIDAAQJ9CKjAQB6AQADAAQJ9CKjAQB6AQAuAAQKfxYAAgMACAkzIp4HABYDAAMACAkzIp4HABYDAAAA.Lionheart:BAAALgAECgEJAQAAAA==.',
Lo='Lockhart:BAAALgAECgQJBAAAAA==.Love:BAAALgADCgYJBgAAAA==.',
Lu='Luciferming:BAAALgAFFAEJAQAAAA==.Lumen:BAABLgAFFH8IAAIHAAMJQiP4AwA+AQAHAAMJQiP4AwA+AQAAAA==.Lunakoo:BAAALgAFFAQJBAABLgAFFAUJBAACAAAAAA==.',
Lv='Lvpaul:BAAALgAFFAQJBAAAAA==.',
Ma='Mayamo:BAAALgAFFAEJAQAAAA==.',
Mi='Milkshaman:BAAALgAECgUJBQAAAA==.Misuuta:BAACLgAFFH8HAAIGAAMJkA1kLgD9AAAGAAMJkA1kLgD9AAAuAAQKfxgAAgYABwlHHUNOAEwCAAYABwlHHUNOAEwCAAAA.Mithrandirr:BAAALgAECgQJBAAAAA==.Miu:BAAALgAECgEJAQAAAA==.',
Mo='Mortis:BAAALgAECgYJCwAAAA==.Mozar:BAAALgAFFAIJAwAAAA==.',
Ne='Neinei:BAAALgAECgQJBAAAAA==.',
No='Novia:BAAALgADCgQJBAAAAA==.',
Oi='Oizys:BAAALgAECgYJCwAAAA==.',
Ol='Olivera:BAAALgAFFAMJAwAAAA==.',
Op='Opa:BAABLgAECn8ZAAIIAAgJ0hQAIwALAgAIAAgJ0hQAIwALAgAAAA==.',
Ot='Otk:BAAALgAECgEJAQAAAA==.',
Ov='Ova:BAAALgAECgcJCwAAAA==.',
Pl='Playervyeray:BAAALgAECgEJAQAAAA==.',
Po='Pokey:BAAALgAECgkJDwAAAA==.Poseidn:BAAALgAECgIJAgAAAA==.',
Ra='Rastsw:BAAALgAECgUJBQAAAA==.Rave:BAAALgAECgcJBwAAAA==.',
Re='Redcross:BAAALgADCgYJBgAAAA==.Revage:BAAALgAECgcJBgAAAA==.',
Ri='Riven:BAAALgAECgYJBwAAAA==.',
Sa='Sammael:BAACLgAFFH8FAAIJAAIJFg91GgCdAAAJAAIJFg91GgCdAAAuAAQKfxUAAwkABwnxGW47AB8CAAkABwnxGW47AB8CAAoAAQnRC/8xADoAAAAA.',
Sh='Shlxm:BAAALgAECgUJBQAAAA==.',
Si='Sillen:BAAALgAECgEJAQAAAA==.Silvteamo:BAAALgAECgEJAQAAAA==.',
So='Sode:BAAALgAECgMJAwAAAA==.',
St='Stephan:BAACLgAFFH8NAAIDAAQJHR+/BAChAQADAAQJHR+/BAChAQAuAAQKfx0ABAMABwk7I/YQAJoCAAMABwk7I/YQAJoCAAsAAQkaG5IdAD8AAAwAAQkYBAAAAAAAAAAA.Stephans:BAAALgAECgEJAQABLgAFFAQJDQADAB0fAA==.',
Su='Sucette:BAAALgAECgYJBgAAAA==.Sumail:BAAALgAECgYJBwAAAA==.Sumuz:BAABLgAECn8eAAINAAcJfB1IEgBOAgANAAcJfB1IEgBOAgAAAA==.Sunyunalol:BAAALgAECgkJCQAAAA==.Sunz:BAAALgAECgQJCAAAAA==.',
Th='Theseu:BAABLgAECn8XAAIEAAgJZRgyPwA7AgAEAAgJZRgyPwA7AgAAAA==.',
Ti='Tinder:BAABLgAECn8mAAQJAAgJMyNwFwDIAgAJAAgJaSFwFwDIAgAKAAUJzyMZBwDlAQAOAAEJAAAXZABGAAAAAA==.',
Va='Valeo:BAAALgAECgQJBAAAAA==.',
Ve='Vermilion:BAAALgAECgYJBwABLgAFFAMJCAAHAEIjAA==.',
Vi='Vivicam:BAAALgADCgcJBwAAAA==.',
Wa='Wa:BAACLgAFFH8MAAIPAAUJzRewBACWAQAPAAUJzRewBACWAQAuAAQKfxkAAg8ACAkMIRQLAOYCAA8ACAkMIRQLAOYCAAAA.Warlockdd:BAAALgAECgcJDwAAAA==.Warlockz:BAAALgAECgUJBQAAAA==.Wawawa:BAABLgAFFH8HAAIEAAMJjCE9NQCzAAAEAAMJjCE9NQCzAAAAAA==.',
Wh='Wheelchair:BAAALgAECgMJAwAAAA==.Whitley:BAAALgAECgYJEQAAAA==.',
Wi='Withsara:BAAALgAECgEJAQAAAA==.',
Xw='Xwinder:BAAALgAECgcJCQAAAA==.',
Ye='Yeat:BAAALgAECgMJAwAAAA==.',
Yt='Ytongxue:BAAALgADCgQJBAAAAA==.',
Zh='Zhangg:BAAALgAECgEJAgAAAA==.',
['Åâ']='Åâãäå:BAAALgAECgcJBgAAAA==.',
['一剑']='一剑入青冥:BAAALgAECgMJBAAAAA==.',
['一只']='一只耳:BAAALgAECgYJDQAAAA==.',
['一吻']='一吻别一:BAAALgAECgYJCgAAAA==.',
['一射']='一射一日:BAAALgADCgUJBQAAAA==.',
['一牛']='一牛平川:BAABLgAFFH8GAAIQAAIJaganBQBcAAAQAAIJaganBQBcAAAAAA==.',
['一米']='一米四:BAABLgAFFH8KAAIIAAYJwhHkBADiAQAIAAYJwhHkBADiAQAAAA==.一米高:BAAALgAECgYJEwAAAA==.',
['一缕']='一缕骄阳:BAAALgADCgEJAQAAAA==.',
['一群']='一群武器战:BAAALgAECgEJAgAAAA==.',
['七分']='七分糖拿铁:BAAALgAFFAEJAQAAAA==.',
['万灵']='万灵的冬天:BAAALgADCgYJCQAAAA==.',
['万爱']='万爱渴:BAAALgADCgIJAgAAAA==.',
['三手']='三手黑斯:BAAALgAECgcJDwAAAA==.',
['三星']='三星斗者丶:BAAALgAFFAQJBAAAAA==.',
['三玖']='三玖的饲养员:BAAALgAECgUJBQAAAA==.',
['上天']='上天啊狗:BAABLgAFFH8PAAIGAAQJSBiDFgBvAQAGAAQJSBiDFgBvAQAAAA==.',
['上官']='上官幽梦:BAAALgAECgEJAQAAAA==.',
['上帝']='上帝的牧羊人:BAAALgAECgIJAgAAAA==.',
['下饭']='下饭师傅:BAAALgAFFAEJAQAAAA==.',
['不带']='不带帽:BAAALgADCgcJCwAAAA==.',
['不服']='不服练一个啊:BAAALgAECgYJCQAAAA==.',
['不来']='不来氪布尔:BAABLgAFFH8FAAIQAAIJpwg7BQBoAAAQAAIJpwg7BQBoAAAAAA==.',
['不死']='不死战灰:BAAALgADCgEJAQAAAA==.不死骑士灬:BAAALgADCggJCAAAAA==.',
['不爱']='不爱挠痒的牛:BAAALgAFFAIJAgAAAA==.',
['不能']='不能喝就回家:BAAALgAFFAEJAQAAAA==.',
['专业']='专业抢野:BAAALgAFFAIJAwAAAA==.',
['世界']='世界旅者:BAAALgAFFAIJAwAAAA==.',
['东北']='东北一米九丶:BAAALgAFFAEJAgAAAA==.',
['东方']='东方有奶丶:BAABLgAFFH8RAAIGAAcJyyELAACFAgAGAAcJyyELAACFAgAAAA==.',
['东门']='东门龙王:BAABLgAFFH8HAAIRAAMJmyATEADHAAARAAMJmyATEADHAAAAAA==.',
['东风']='东风橘:BAAALgAECgYJCAAAAA==.',
['丨丶']='丨丶艾斯卡诺:BAAALgAECgQJBQAAAA==.丨丶苓苝丶丨:BAAALgAECgEJAQAAAA==.',
['丨可']='丨可不可以:BAAALgAECgEJAgAAAA==.',
['丨懟']='丨懟妳偏愛丨:BAAALgAECgIJAwAAAA==.',
['丨詩']='丨詩情畫意丨:BAABLgAFFH8KAAMSAAQJQBNhBgACAQASAAQJQBNhBgACAQATAAEJaANwJQBIAAAAAA==.',
['丨铁']='丨铁蛋丨:BAAALgAFFAMJAwAAAA==.',
['临秋']='临秋:BAAALgAECgcJCwAAAA==.',
['丶人']='丶人之律者:BAAALgAECgMJAwAAAA==.',
['丶信']='丶信步听雨:BAAALgAECgYJCgAAAA==.',
['丶夜']='丶夜侵入安:BAAALgADCgUJBQAAAA==.',
['丶干']='丶干脆面丶:BAABLgAFFH8GAAIUAAMJpRrKFAC0AAAUAAMJpRrKFAC0AAAAAA==.',
['丶式']='丶式微:BAAALgAECgYJBwAAAA==.',
['丶扫']='丶扫地焚香:BAAALgAECgkJDwAAAA==.',
['丶春']='丶春秋:BAAALgAECgIJAgAAAA==.',
['丶晓']='丶晓晴天:BAAALgAECgIJAgAAAA==.',
['丶爱']='丶爱晴天:BAAALgAECgYJBwAAAA==.',
['丶钟']='丶钟无艳:BAAALgAECgUJBQAAAA==.',
['丶铭']='丶铭:BAAALgAECgcJCAAAAA==.',
['丶顺']='丶顺笛丶:BAAALgADCgIJAgAAAA==.',
['丶饮']='丶饮月君:BAACLgAFFH8FAAMVAAIJlAcVGwCVAAAVAAIJlAcVGwCVAAAWAAEJkQdPGAA/AAAuAAQKfxcABBUABwnvFg4qAG4BABUABgl1EQ4qAG4BABcABAmYFrMmAOwAABYABAm5CXg4AKcAAAAA.',
['丷柒']='丷柒:BAAALgAECgUJBQAAAA==.',
['丹妮']='丹妮莉丝女王:BAAALgAECgYJCQAAAA==.',
['丽鸽']='丽鸽游酒:BAABLgAFFH8GAAIIAAQJQxbSDABQAQAIAAQJQxbSDABQAQAAAA==.',
['丿一']='丿一叶知秋:BAAALgAECgYJCAAAAA==.丿一叶芷秋:BAAALgADCgcJCAAAAA==.',
['丿嘿']='丿嘿吧砸嘿:BAAALgADCgkJDAAAAA==.',
['丿紫']='丿紫泪丶:BAAALgAECgYJEgAAAA==.',
['乃我']='乃我一哈:BAAALgAECgMJAwAAAA==.',
['久久']='久久不射:BAAALgADCgEJAwAAAA==.',
['九幺']='九幺幺:BAAALgAECgIJAQAAAA==.',
['九月']='九月之上:BAACLgAFFH8IAAIGAAIJmR/jNADDAAAGAAIJmR/jNADDAAAuAAQKfxUAAgYABwkCIa9UADoCAAYABwkCIa9UADoCAAAA.',
['九束']='九束圣光:BAAALgAECgYJBwAAAA==.九束炙焰:BAAALgAECgYJBgAAAA==.',
['九零']='九零后小琪:BAAALgAFFAEJAQAAAA==.九零盛夏:BAAALgAFFAIJBAAAAA==.',
['乞丐']='乞丐包:BAACLgAFFH8FAAIUAAIJMhKhFgCiAAAUAAIJMhKhFgCiAAAuAAQKfxQAAxQACAn7D0w2AKoBABQACAn7D0w2AKoBAA8ABQlEBwNXAOkAAAAA.',
['乳娘']='乳娘:BAAALgAECgUJBgAAAA==.',
['五十']='五十个骑士:BAAALgAECgQJBAAAAA==.',
['五点']='五点钟:BAACLgAFFH8HAAIGAAQJkRVKGgBhAQAGAAQJkRVKGgBhAQAuAAQKfxcAAgYABgk1HIyGAMQBAAYABgk1HIyGAMQBAAAA.',
['亚麻']='亚麻绷带:BAAALgAECgMJAwAAAA==.',
['京痴']='京痴梦灬彡:BAAALgADCgUJBQAAAA==.京痴梦灬玖:BAAALgADCgYJBgAAAA==.京痴梦罒:BAAALgADCgEJAQAAAA==.',
['人心']='人心薄凉丶伤:BAABLgAECn8YAAMYAAYJEQ8nOQBSAQAYAAYJEQ8nOQBSAQAZAAYJ+RG0aAAZAQAAAA==.',
['人末']='人末予毒:BAAALgAECgYJBAABLgAFFAcJDwAGANUjAA==.',
['人生']='人生如戏灬:BAAALgADCgEJAgAAAA==.',
['人莫']='人莫予毒:BAACLgAFFH8IAAIJAAMJbB/uFwAxAQAJAAMJbB/uFwAxAQAuAAQKfxUAAw4ACAl1HuQHAEcCAAkABwmoHvIpAGgCAA4ABgn3H+QHAEcCAAEuAAUUBgkEAAIAAAAA.',
['人间']='人间正道沧桑:BAAALgAECgIJAgAAAA==.',
['人魚']='人魚朵朵:BAAALgADCgEJAQAAAA==.',
['今晚']='今晚九点睡:BAAALgADCgYJBgAAAA==.',
['仓颉']='仓颉:BAAALgAECgYJBwAAAA==.',
['以徳']='以徳扶人:BAAALgAECgcJBwAAAA==.',
['以此']='以此为念:BAABLgAFFH8HAAIFAAIJ9RbqHQC1AAAFAAIJ9RbqHQC1AAAAAA==.',
['仰望']='仰望星空的猫:BAAALgADCgMJAwAAAA==.',
['伊塔']='伊塔:BAABLgAECn8aAAIEAAcJgCAGLQCEAgAEAAcJgCAGLQCEAgAAAA==.',
['会长']='会长认证官:BAAALgADCgMJAwAAAA==.',
['伤心']='伤心小勺子:BAAALgAECgUJBQAAAA==.',
['低调']='低调的班长:BAAALgAECgEJAQAAAA==.',
['你别']='你别捏我鼻子:BAAALgAECgEJAQAAAA==.',
['你是']='你是章鱼吗:BAAALgAECgkJDAAAAA==.',
['你背']='你背后的圣光:BAAALgAECgUJBgAAAA==.',
['你轻']='你轻点她怕疼:BAAALgAFFAMJBAAAAA==.',
['佰思']='佰思不得其姐:BAAALgAFFAEJAQAAAA==.',
['來杯']='來杯柠檬可樂:BAAALgAECgcJDgAAAA==.',
['依然']='依然小七:BAAALgAFFAIJAgAAAA==.',
['信仰']='信仰圣光:BAAALgAECgYJDwAAAA==.',
['倩丶']='倩丶兮:BAAALgAECgcJCAAAAA==.',
['停下']='停下喝咖啡:BAAALgAECgYJBwAAAA==.',
['傻灬']='傻灬慢:BAAALgAECgYJAwAAAA==.',
['儱傲']='儱傲娇:BAAALgAECgEJAQAAAA==.',
['兆他']='兆他爸:BAAALgADCgcJBwAAAA==.',
['光盘']='光盘空间:BAACLgAFFH8FAAIJAAMJ9AZFJgDnAAAJAAMJ9AZFJgDnAAAuAAQKfxoABAkABwnFIG5HAPQBAAkABglyH25HAPQBAA4AAwmWE1pAALMAAAoAAQkAAP4oAE0AAAAA.',
['光矮']='光矮:BAAALgAECgcJBwAAAA==.',
['克亚']='克亚路加:BAAALgAFFAIJBAAAAA==.',
['克利']='克利欧佩特拉:BAAALgAECgMJBAAAAA==.',
['克里']='克里思丶:BAAALgAECgMJAwAAAA==.克里斯廷娜碧:BAAALgADCgEJAQAAAA==.',
['全都']='全都不会玩:BAABLgAFFH8FAAIJAAUJ8hglBQDMAQAJAAUJ8hglBQDMAQAAAA==.',
['八冀']='八冀大狂疯:BAAALgAECgYJBgAAAA==.',
['六边']='六边形武僧:BAAALgAFFAEJAQAAAA==.',
['兮丶']='兮丶风:BAAALgADCgMJAwAAAA==.',
['养猪']='养猪高手:BAABLgAECn8XAAIBAAgJSR79EwBwAgABAAgJSR79EwBwAgAAAA==.',
['冉啊']='冉啊让:BAAALgAECgUJBwAAAA==.',
['再闯']='再闯红烛镇:BAAALgAECgcJDAAAAA==.',
['冬日']='冬日暖洋:BAAALgAFFAEJAQAAAA==.',
['冰箭']='冰箭乱射:BAAALgAECgcJBwAAAA==.',
['冰鎮']='冰鎮檸檬:BAAALgAECgYJBwABLgAFFAUJDAAIADsQAA==.',
['冲峰']='冲峰丿骑:BAAALgAECgcJEgAAAA==.',
['冲锋']='冲锋吧宠物:BAAALgAECgYJBgAAAA==.',
['凉宫']='凉宫的消失:BAAALgADCgcJBwAAAA==.',
['凉水']='凉水好烫:BAAALgAECgcJBwAAAA==.',
['凯尔']='凯尔:BAAALgAECgIJBAAAAA==.',
['出墙']='出墙的龙人:BAAALgAECggJCAAAAA==.',
['刀锋']='刀锋女皇萧:BAABLgAFFH8IAAIRAAMJCREfDQD3AAARAAMJCREfDQD3AAAAAA==.',
['刚果']='刚果黑叔叔:BAAALgADCgEJAQAAAA==.',
['别死']='别死:BAAALgAECgMJAwAAAA==.',
['剣走']='剣走偏锋:BAAALgAECgYJBgAAAA==.',
['化身']='化身卫龙:BAAALgAECgUJCQAAAA==.',
['北冕']='北冕:BAAALgADCgMJAwAAAA==.',
['北海']='北海吴彦祖:BAAALgAFFAIJAgAAAA==.',
['十二']='十二笙花:BAAALgAECgUJBwAAAA==.',
['十八']='十八清纯女大:BAAALgAECgcJBgAAAA==.',
['千魂']='千魂兔兔丶:BAAALgAECgUJBQAAAA==.',
['千鹤']='千鹤五号:BAAALgAECgUJBQAAAA==.千鹤六号:BAABLgAFFH8JAAIGAAMJXBmOJgAYAQAGAAMJXBmOJgAYAQAAAA==.',
['华丽']='华丽冒险:BAAALgAECgQJBgAAAA==.',
['华山']='华山叶小冷:BAACLgAFFH8HAAIBAAMJ5gjDFQDHAAABAAMJ5gjDFQDHAAAuAAQKfyEAAgEACAnIE00lANgBAAEACAnIE00lANgBAAAA.',
['南鹿']='南鹿与森:BAAALgAECgUJBAAAAA==.',
['卡德']='卡德山的绝望:BAAALgAECgEJAQAAAA==.',
['卡桑']='卡桑德菈:BAAALgAECgEJAQAAAA==.',
['原叶']='原叶锡兰:BAAALgAECgMJBAAAAA==.',
['去玩']='去玩儿人:BAAALgAECgEJAQAAAA==.',
['叁废']='叁废街溜子:BAAALgAECgcJCAAAAA==.',
['又凶']='又凶又红:BAAALgAECgIJAgAAAA==.',
['又被']='又被打飞啦:BAACLgAFFH8VAAMTAAYJJxozAwDDAQATAAUJiRwzAwDDAQAaAAEJoRDjCQBbAAAuAAQKfxkAAhMACAkmIK4UAKgCABMACAkmIK4UAKgCAAAA.',
['双魚']='双魚理:BAAALgAFFAUJBAABLgAFFAYJCwAGAMUbAA==.',
['双鱼']='双鱼理灬:BAAALgAECgEJAQAAAA==.',
['叛逆']='叛逆:BAAALgADCgEJAQAAAA==.',
['口可']='口可口乐:BAABLgAFFH8FAAIbAAUJrBh7AQC/AQAbAAUJrBh7AQC/AQABLgAFFAYJCwAGAL0cAA==.',
['古单']='古单:BAAALgAFFAIJAgAAAA==.',
['古天']='古天有点乐:BAAALgAECgYJCAAAAA==.',
['可乐']='可乐加盐灬:BAAALgAECgQJBAAAAA==.可乐加醋灬:BAAALgAECgIJAgAAAA==.',
['可伊']='可伊:BAAALgAECgEJAwAAAA==.',
['可可']='可可菠萝:BAAALgAECgIJAgAAAA==.',
['可爱']='可爱的花花:BAAALgAECgMJAwAAAA==.',
['史蒂']='史蒂芬铁柱:BAAALgAECgEJAgAAAA==.',
['叶不']='叶不问:BAAALgAECgMJAwAAAA==.',
['叶遮']='叶遮天:BAABLgAECn8dAAMcAAgJnhJDXwCDAQAcAAgJWw9DXwCDAQAdAAUJhRTsOQAaAQAAAA==.',
['吃西']='吃西瓜死骑:BAAALgAECgYJCwAAAA==.',
['吉川']='吉川爱美:BAABLgAFFH8FAAIWAAIJsSS7DwDTAAAWAAIJsSS7DwDTAAAAAA==.',
['吸血']='吸血:BAAALgAECgUJBQAAAA==.',
['吾为']='吾为天帝:BAAALgAFFAMJBAAAAA==.',
['吾彦']='吾彦吾辰:BAAALgAECgEJAQAAAA==.',
['呀勒']='呀勒呀勒:BAAALgAECgQJCAAAAA==.',
['呆呆']='呆呆鹅丶:BAAALgADCgcJBwAAAA==.',
['周美']='周美离:BAAALgAFFAIJAwAAAA==.',
['呼吸']='呼吸:BAAALgADCgIJAgAAAA==.',
['呼呼']='呼呼的榴莲:BAAALgAFFAIJAgAAAA==.',
['呼噜']='呼噜瓦:BAABLgAFFH8HAAIFAAMJ1BTuFAACAQAFAAMJ1BTuFAACAQAAAA==.',
['咚咚']='咚咚隆咚锵:BAAALgAECgMJBgABLgAECgYJBwACAAAAAA==.',
['哈哈']='哈哈懒尼尔:BAAALgAECgMJBgAAAA==.',
['哈尔']='哈尔辛:BAAALgADCgIJAgAAAA==.',
['哋精']='哋精:BAAALgAECgQJBAAAAA==.',
['唐飘']='唐飘飘:BAAALgAECgYJCwAAAA==.',
['唧儿']='唧儿梆嗯:BAAALgAFFAQJAwAAAA==.',
['唯一']='唯一的霸气:BAAALgADCgMJAwAAAA==.',
['唯有']='唯有业缠身:BAAALgADCgIJAgAAAA==.',
['善良']='善良的大熊熊:BAAALgAFFAUJAwAAAA==.',
['喝白']='喝白酒交朋友:BAAALgAECgEJAQAAAA==.',
['喵喵']='喵喵帕斯丶:BAAALgAECgcJCwAAAA==.',
['喵姨']='喵姨:BAAALgADCgIJAgAAAA==.',
['嘴贫']='嘴贫一只猪:BAAALgAECgYJBwAAAA==.',
['嘿喂']='嘿喂狗丶:BAABLgAECn8aAAISAAgJAB8kCACjAgASAAgJAB8kCACjAgAAAA==.',
['嘿黑']='嘿黑嗨:BAAALgAECgIJAgAAAA==.',
['噩梦']='噩梦的小德:BAAALgADCgQJBAAAAA==.噩梦的消逝:BAAALgAECgUJCgAAAA==.噩梦的祭日:BAAALgADCgEJAQAAAA==.噩梦的邪术:BAAALgAECgMJBAAAAA==.',
['噬灭']='噬灭丶:BAABLgAFFH8FAAIcAAMJbQmyHgDiAAAcAAMJbQmyHgDiAAAAAA==.',
['囚团']='囚团:BAAALgAECgYJBgAAAA==.',
['四月']='四月丶:BAAALgAECgkJEQAAAA==.',
['回不']='回不去的曾经:BAAALgAECgQJBwAAAA==.',
['囧字']='囧字眉:BAAALgAECgkJDgAAAA==.',
['圣光']='圣光小怪兽:BAAALgAECgEJAQAAAA==.圣光蹄下死:BAAALgAECgEJAQAAAA==.圣光闪瞎着你:BAAALgAECgYJEgAAAA==.圣光魅魔:BAAALgAECgEJAgAAAA==.',
['在线']='在线就是痒了:BAAALgAFFAIJBAAAAA==.',
['地上']='地上一趴:BAAALgAECgUJBgABLgAECgYJBwACAAAAAA==.',
['地零']='地零零:BAABLgAECn8UAAMPAAcJ9BRUOgBlAQAPAAYJ6xZUOgBlAQAUAAQJjwj0cgDDAAAAAA==.',
['墨亦']='墨亦:BAAALgADCgUJBQAAAA==.',
['墨雨']='墨雨轩:BAAALgAFFAMJAwAAAA==.',
['墨霏']='墨霏特:BAAALgADCgUJBQAAAA==.',
['壹贰']='壹贰叁等等:BAAALgAECgcJDAAAAA==.',
['夏拉']='夏拉的星星:BAAALgAECgYJBgAAAA==.',
['夏萄']='夏萄柠柠茶:BAAALgAECgcJBwAAAA==.',
['夏都']='夏都尔:BAAALgAECgEJAQAAAA==.',
['夕阳']='夕阳丶醉了:BAAALgADCgEJAQAAAA==.',
['夙愿']='夙愿丨:BAAALgAECgEJAQAAAA==.',
['多动']='多动昕宸:BAAALgAECgEJAQAAAA==.',
['多啦']='多啦牛仔:BAACLgAFFH8IAAIPAAMJGBPtBQD8AAAPAAMJGBPtBQD8AAAuAAQKfxwAAw8ABwkjIWkRAJkCAA8ABwkjIWkRAJkCABQAAQndIAAAAAAAAAAA.',
['夜有']='夜有星澜:BAAALgAFFAIJAwAAAA==.',
['夜术']='夜术:BAAALgAECgMJAwAAAA==.',
['夜狩']='夜狩无痕:BAAALgAECgUJCAAAAA==.',
['大乘']='大乘:BAAALgAECgcJBwAAAA==.大乘一:BAAALgAECgYJBgAAAA==.大乘七:BAAALgAECgYJBgAAAA==.大乘三:BAAALgAECgYJDAAAAA==.大乘二:BAAALgAECgYJBgAAAA==.大乘五:BAAALgAECgYJBgAAAA==.大乘八:BAAALgAECgYJBgAAAA==.大乘六:BAAALgAECgYJBQAAAA==.大乘四:BAAALgAECgYJEgAAAA==.',
['大地']='大地的复苏:BAAALgAECgQJBwAAAA==.',
['大屁']='大屁屁提莫:BAAALgAECgEJAQAAAA==.',
['大条']='大条:BAAALgAECgEJAQAAAA==.',
['大概']='大概率不会鸽:BAAALgADCgcJBwAAAA==.',
['大猫']='大猫手:BAAALgAECgQJBQAAAA==.',
['大米']='大米毁灭者:BAACLgAFFH8IAAMeAAMJwxhBCAChAAAeAAIJoRRBCAChAAANAAEJCCFjBwBkAAAuAAQKfxYAAx4ABwkCILETABACAB4ABgmaHrETABACAA0AAwkwHY9KAA4BAAAA.',
['大莽']='大莽夫:BAAALgAECgYJEgAAAA==.',
['大跳']='大跳坠机:BAAALgAECgcJCAAAAA==.',
['大辣']='大辣条:BAAALgAECgQJBAAAAA==.',
['天牛']='天牛下凡:BAABLgAFFH8IAAIfAAMJJxOpAgAMAQAfAAMJJxOpAgAMAQAAAA==.',
['天猫']='天猫精灵:BAAALgADCgEJAQAAAA==.',
['太阳']='太阳之火:BAAALgAECgMJAwAAAA==.',
['失眠']='失眠飞行:BAAALgAECgUJDAAAAA==.',
['夹断']='夹断负心汉:BAAALgAECgQJBAAAAA==.',
['奈何']='奈何苍生苦楚:BAABLgAFFH8HAAIFAAMJ8BQeIACuAAAFAAMJ8BQeIACuAAAAAA==.',
['奎秃']='奎秃斯:BAAALgADCgYJBgAAAA==.',
['奥丁']='奥丁:BAAALgAECgEJAQAAAA==.',
['奥斯']='奥斯丁丶:BAAALgAECgUJBQAAAA==.',
['女友']='女友的饿梦:BAAALgAECgEJAQAAAA==.',
['奴葵']='奴葵令雨:BAAALgAECgYJBgAAAA==.',
['奶菲']='奶菲天:BAAALgAECgUJBgAAAA==.',
['奶谁']='奶谁谁躺尸:BAAALgADCgYJBgAAAA==.',
['好吃']='好吃嘛我尝尝:BAABLgAFFH8JAAIGAAUJ+xZ9CABdAQAGAAUJ+xZ9CABdAQAAAA==.',
['好好']='好好玩乖:BAAALgAECgcJBwAAAA==.',
['好运']='好运來:BAAALgAECgkJBwAAAA==.',
['如玥']='如玥弦太郎:BAAALgAECgcJCwAAAA==.',
['妍妍']='妍妍小妮妮:BAAALgAECgQJBAABLgAFFAcJBAACAAAAAA==.',
['妖哥']='妖哥直摇头:BAAALgAECgEJAQAAAA==.',
['妮妮']='妮妮小妍妍:BAAALgADCgMJAwAAAA==.',
['姜红']='姜红芍:BAAALgAECgIJAgAAAA==.',
['姬如']='姬如雪:BAAALgAECgcJCwAAAA==.',
['威尓']='威尓丶史密斯:BAAALgAECgEJAQAAAA==.',
['娃娃']='娃娃菜哈:BAAALgADCgEJAQAAAA==.',
['娜亚']='娜亚斯帝娜:BAAALgAFFAIJBAAAAA==.',
['娜娜']='娜娜:BAAALgADCgEJAQAAAA==.',
['婕婕']='婕婕子:BAAALgAECgUJBQAAAA==.',
['婕酱']='婕酱:BAAALgAECgYJBgAAAA==.',
['婷儿']='婷儿宝宝:BAAALgAECgEJAQAAAA==.',
['孤独']='孤独丶恋:BAAALgADCgEJAQAAAA==.',
['宁静']='宁静一夏:BAAALgAECgcJCQAAAA==.',
['安玉']='安玉琪:BAAALgAECgYJBwAAAA==.',
['安琪']='安琪:BAAALgAECgUJBQAAAA==.安琪玉:BAAALgAECgIJAgAAAA==.',
['安道']='安道明:BAAALgAECgYJBgAAAA==.',
['完美']='完美狩猎者:BAAALgAECgMJBQAAAA==.',
['宝宝']='宝宝不弃:BAAALgAECgUJCgAAAA==.',
['宝藏']='宝藏男孩坤坤:BAACLgAFFH8VAAMEAAYJch5EAgDyAQAEAAUJch5EAgDyAQAgAAEJAACLGwAtAAAuAAQKfxcAAgQACAlCI+wTAAMDAAQACAlCI+wTAAMDAAAA.',
['宠物']='宠物带宠物:BAAALgAECgEJAQAAAA==.',
['寂静']='寂静低语:BAAALgAFFAMJAwAAAA==.',
['寒蝉']='寒蝉泣鸣:BAAALgAECgEJAQAAAA==.',
['封号']='封号斗罗:BAAALgADCgYJBgAAAA==.',
['小丶']='小丶单车:BAACLgAFFH8LAAIBAAUJtxLLBgBmAQABAAUJtxLLBgBmAQAuAAQKfxoAAwEACAm8GEcWAFcCAAEACAk1GEcWAFcCABsABQliD9dDAAcBAAAA.小丶坏蛋:BAAALgAECgMJAwAAAA==.小丶娘子:BAAALgAFFAQJBAABLgAFFAYJBwAcAGYTAA==.',
['小乌']='小乌鸦隼:BAAALgAFFAIJBAAAAA==.',
['小二']='小二哥:BAAALgAFFAIJAgAAAA==.',
['小冰']='小冰弓:BAAALgAECgQJBAAAAA==.',
['小叶']='小叶子睡不着:BAAALgADCgQJBAAAAA==.',
['小咖']='小咖喱黄不辣:BAAALgAECgkJEAAAAA==.',
['小婕']='小婕:BAAALgAECgIJAgAAAA==.',
['小小']='小小罗曼:BAAALgAECgUJBQAAAA==.小小阿童木丶:BAAALgADCgcJBwAAAA==.',
['小彭']='小彭:BAAALgAECgYJCwABLgAFFAQJDQADAB0fAA==.',
['小朱']='小朱哦耶:BAAALgAECgYJCAAAAA==.',
['小林']='小林康娜:BAAALgAECgkJCQAAAA==.',
['小椰']='小椰风挡不住:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊猫三:BAAALgADCgcJBwAAAA==.',
['小甜']='小甜心丶:BAAALgAECgEJAQAAAA==.',
['小神']='小神龙:BAAALgAECgMJAwAAAA==.',
['小米']='小米字不大:BAAALgAECgEJBAAAAA==.',
['小辉']='小辉辉:BAABLgAECn8fAAIcAAcJeiBbIQCJAgAcAAcJeiBbIQCJAgAAAA==.',
['小邪']='小邪:BAAALgADCgcJBwAAAA==.',
['尔存']='尔存万物春:BAAALgAECgEJAQAAAA==.',
['尘封']='尘封的记忆:BAAALgAECgEJAQAAAA==.',
['尛祖']='尛祖宗:BAAALgAECgMJAwAAAA==.',
['尼克']='尼克拉撕:BAAALgAECgcJDgAAAA==.',
['屠龍']='屠龍:BAAALgAECgYJBwAAAA==.',
['山楂']='山楂树下:BAAALgAECgIJAgAAAA==.',
['工作']='工作称职务:BAAALgAECgUJBQAAAA==.',
['左右']='左右为难:BAAALgAECgYJCgAAAA==.',
['巨恶']='巨恶:BAABLgAECn8YAAMUAAgJXiOHBAArAwAUAAgJXiOHBAArAwAPAAMJogQtdQBtAAABLgAFFAQJEQAGABIgAA==.',
['巫小']='巫小诺:BAAALgAFFAIJAgAAAA==.',
['布穿']='布穿奶酷:BAABLgAFFH8FAAIBAAMJdyI0DQAbAQABAAMJdyI0DQAbAQAAAA==.',
['帅了']='帅了二十年:BAAALgAECgcJBwAAAA==.',
['希尔']='希尔凡:BAAALgAFFAIJBAAAAA==.希尔妲:BAAALgADCgEJAQAAAA==.希尔邷呐斯:BAAALgAECgYJEAAAAA==.',
['帕拉']='帕拉丁灬程:BAAALgAFFAEJAQAAAA==.',
['干邑']='干邑:BAAALgADCgMJAwAAAA==.',
['平平']='平平安安小鱼:BAAALgAECgQJBAAAAA==.',
['幸运']='幸运小谢:BAAALgAECgEJAQAAAA==.',
['幽雾']='幽雾:BAAALgADCgcJBwABLgAFFAMJCAAHAEIjAA==.',
['广末']='广末凉子丶:BAAALgAECgYJBgAAAA==.',
['应春']='应春风:BAAALgAECgcJBwAAAA==.',
['庶民']='庶民之罪:BAABLgAFFH8NAAIUAAQJoRdoAwBHAQAUAAQJoRdoAwBHAQAAAA==.',
['廿小']='廿小戚:BAABLgAECn8ZAAIeAAcJ2BuMEQArAgAeAAcJ2BuMEQArAgAAAA==.',
['开心']='开心果可爱豆:BAAALgAECgEJAQAAAA==.',
['弓冢']='弓冢五月:BAAALgAECgYJBQAAAA==.',
['张三']='张三丰:BAAALgAFFAIJAwAAAA==.',
['张跛']='张跛子:BAAALgAECgYJEAAAAA==.',
['弥生']='弥生丶美月:BAAALgADCgEJAQAAAA==.',
['彤童']='彤童小君主:BAAALgAECgMJAwAAAA==.',
['彩虹']='彩虹软糖丶:BAAALgAECgcJBwABLgAFFAUJBAACAAAAAA==.',
['影之']='影之刃:BAAALgAFFAEJAgAAAA==.',
['彼时']='彼时旧梦:BAAALgAECgEJAQAAAA==.',
['得鹿']='得鹿梦鱼:BAAALgAECgMJAwAAAA==.',
['德不']='德不配喂:BAAALgADCgcJBwABLgAFFAQJBwAGAJEVAA==.',
['德叔']='德叔灬:BAAALgAECgQJBAAAAA==.',
['德小']='德小晓:BAAALgAECgcJAQAAAA==.',
['德里']='德里德气:BAAALgAECgUJBAAAAA==.',
['心柔']='心柔:BAAALgAECgMJBAAAAA==.',
['快乐']='快乐小喇叭:BAAALgAECgYJBgAAAA==.',
['忽魂']='忽魂悸以魄动:BAAALgAECgIJAgAAAA==.',
['思琳']='思琳贝尔:BAAALgADCgYJBgAAAA==.',
['怡追']='怡追命:BAAALgAECgcJBgAAAA==.',
['恐怖']='恐怖利刃:BAAALgAECgkJAgAAAA==.',
['恶梦']='恶梦的开始:BAAALgAECgMJAwAAAA==.',
['恶臭']='恶臭仙子:BAAALgAECgEJAQAAAA==.',
['恶霸']='恶霸雪酱:BAAALgAFFAMJBAAAAA==.',
['悔爷']='悔爷:BAAALgAECgQJBAAAAA==.',
['悲伤']='悲伤大蕃薯:BAACLgAFFH8TAAIBAAUJFxcaBgByAQABAAUJFxcaBgByAQAuAAQKfxoAAgEACAmLH40OAK0CAAEACAmLH40OAK0CAAAA.',
['情殇']='情殇堕:BAAALgAECgYJBwAAAA==.',
['惊雨']='惊雨丶:BAAALgADCgQJBAAAAA==.',
['惊鸢']='惊鸢丶:BAAALgAECgMJAwAAAA==.',
['懒相']='懒相迎:BAAALgADCgYJBgAAAA==.',
['戏如']='戏如人生灬:BAAALgAECgYJDAAAAA==.',
['我偏']='我偏要勉强:BAAALgAECgcJDQABLgAFFAQJCAAYALEIAA==.',
['我刁']='我刁不见了:BAAALgADCgUJBQAAAA==.',
['我带']='我带了个小鬼:BAAALgADCgEJAQAAAA==.',
['我很']='我很皮:BAAALgAFFAMJBAAAAA==.我很硬先奶她:BAAALgADCgYJDAAAAA==.',
['我推']='我推福瑞:BAAALgAECgEJAQAAAA==.',
['我有']='我有大翅膀:BAAALgADCgEJAQAAAA==.',
['我特']='我特么社保:BAAALgAECgYJBwAAAA==.',
['我的']='我的小宝贝儿:BAAALgADCgYJBgAAAA==.我的小肝肝儿:BAAALgAECgYJBgAAAA==.',
['我要']='我要抓宝宝咯:BAAALgAECgYJCAAAAA==.',
['战诗']='战诗:BAAALgADCgEJAQAAAA==.',
['戰士']='戰士大叔:BAAALgAECgQJBAAAAA==.',
['扑哧']='扑哧扑哧:BAAALgAECgYJBwAAAA==.',
['托猪']='托猪举高高:BAAALgAECgYJDwAAAA==.',
['托钠']='托钠鲁斯之爪:BAAALgAECgEJAQAAAA==.',
['抠脚']='抠脚丶天使:BAAALgAFFAMJBAAAAA==.',
['抢琳']='抢琳琳雪糕:BAAALgAECgEJAgAAAA==.',
['抹茶']='抹茶橘:BAAALgAECgYJBgAAAA==.',
['抽烟']='抽烟吐烟圈:BAAALgAECgEJAQAAAA==.',
['指尖']='指尖划过的泪:BAAALgADCgEJAQAAAA==.',
['挚爱']='挚爱尼哥:BAABLgAFFH8FAAIUAAMJ3gj3CwCKAAAUAAMJ3gj3CwCKAAAAAA==.',
['挥剑']='挥剑斩情丝丶:BAAALgADCgYJBgAAAA==.',
['控儞']='控儞挤挖:BAAALgAECgMJBAAAAA==.',
['提尔']='提尔:BAABLgAFFH8WAAIPAAYJKCHRAABWAgAPAAYJKCHRAABWAgAAAA==.',
['提里']='提里奥豆丁:BAAALgADCgYJBgAAAA==.',
['揽月']='揽月入梦:BAAALgAFFAEJAQAAAA==.',
['搁浅']='搁浅的鱼:BAAALgAECgIJAgAAAA==.',
['撸士']='撸士无双:BAABLgAECn8VAAISAAcJ3RamEgDfAQASAAcJ3RamEgDfAQAAAA==.',
['救赎']='救赎灵魂的猫:BAAALgAECgUJBQAAAA==.',
['敖凌']='敖凌:BAAALgAECgEJAQAAAA==.',
['散装']='散装奶粉:BAAALgAECgQJBAAAAA==.',
['文泰']='文泰来:BAACLgAFFH8OAAIBAAQJRxfYCABGAQABAAQJRxfYCABGAQAuAAQKfxgAAgEACAllHG0SAIACAAEACAllHG0SAIACAAAA.',
['斩虹']='斩虹之瞳:BAAALgAECgIJAgAAAA==.',
['斯三']='斯三雷:BAABLgAECn8WAAMIAAgJxhWXMwCbAQAIAAcJNBiXMwCbAQARAAQJCgbGfgDrAAAAAA==.',
['斯大']='斯大雷:BAACLgAFFH8LAAMRAAQJBxnVEADCAAAIAAMJpw2vFgDkAAARAAMJFyHVEADCAAAuAAQKfx0AAxEACAnRJOwIAAUDABEABwmeJewIAAUDAAgABwnzGXotAMEBAAAA.',
['新月']='新月乄唯美:BAAALgAECgMJBQAAAA==.',
['施主']='施主你别跑灬:BAAALgAECgUJBgAAAA==.',
['无合']='无合有之:BAAALgAECgYJDwAAAA==.',
['无敌']='无敌奶僧:BAAALgAECgMJAwAAAA==.无敌奶嘴:BAAALgAECgYJCwAAAA==.无敌奶瓶:BAAALgAECgEJAQAAAA==.无敌奶糖:BAAALgADCgUJBQAAAA==.无敌小屁狗:BAABLgAECn8UAAINAAcJPRGRLACUAQANAAcJPRGRLACUAQAAAA==.无敌炉石溜:BAAALgAECgEJAgAAAA==.',
['无畏']='无畏天启:BAAALgAECgEJAQAAAA==.',
['无锡']='无锡小笼包:BAAALgAFFAEJAQAAAA==.',
['明月']='明月问春风:BAAALgAECgEJAQAAAA==.',
['星丶']='星丶月夜:BAABLgAFFH8GAAIhAAMJ+hV2BACLAAAhAAMJ+hV2BACLAAAAAA==.',
['星夜']='星夜晚风:BAAALgAECgQJBAAAAA==.',
['星宫']='星宫一花:BAAALgAECgkJCQAAAA==.',
['星月']='星月同行:BAABLgAFFH8IAAIJAAUJSxSHBwCsAQAJAAUJSxSHBwCsAQAAAA==.',
['星痕']='星痕划暮:BAAALgAECgUJBgAAAA==.',
['春日']='春日影:BAABLgAFFH8GAAIIAAYJbh/EAQBhAgAIAAYJbh/EAQBhAgAAAA==.',
['春见']='春见花开:BAAALgAECgEJAQAAAA==.',
['昨夜']='昨夜灬小楼:BAAALgAECgYJCgAAAA==.',
['是个']='是个秘法师:BAABLgAECn8UAAIGAAYJexGiqACIAQAGAAYJexGiqACIAQAAAA==.',
['是富']='是富贵吖:BAAALgADCgcJBwAAAA==.',
['是小']='是小肥柴呀丶:BAABLgAECn8aAAMaAAcJOyN2AwDQAgAaAAcJEyN2AwDQAgATAAUJiCSzLQD8AQAAAA==.',
['是我']='是我莽撞了呀:BAAALgAECgYJDAAAAA==.',
['是等']='是等等啊:BAAALgAECgYJCgAAAA==.是等等阿:BAAALgAECgcJBwAAAA==.',
['晚凉']='晚凉:BAAALgAECgQJBAAAAA==.',
['晴雨']='晴雨飞扬:BAAALgAFFAEJAQAAAA==.',
['暖小']='暖小暖:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜歌者:BAAALgAECgcJEAAAAA==.',
['暗骑']='暗骑:BAAALgAECgMJAwAAAA==.',
['暮光']='暮光风暴:BAAALgADCgcJBwAAAA==.',
['暮雪']='暮雪千山丶:BAAALgAFFAIJAgAAAA==.',
['暴风']='暴风丶骤雨:BAAALgAECgcJDAAAAA==.',
['曦月']='曦月:BAAALgAECgIJAwAAAA==.',
['曼彻']='曼彻斯特丶联:BAAALgAFFAMJBAAAAA==.',
['最后']='最后的晚餐:BAABLgAFFH8FAAMPAAMJFx60DQASAQAPAAMJFx60DQASAQAUAAEJlANjIgBJAAAAAA==.',
['最爱']='最爱娇娇:BAAALgAECgkJCQAAAA==.',
['會笑']='會笑的猫:BAAALgAECgYJBgAAAA==.',
['月影']='月影天涯一号:BAAALgADCgcJBwAAAA==.',
['月魔']='月魔之殇:BAAALgADCgUJBQAAAA==.',
['有毒']='有毒小熊:BAAALgAFFAMJAwAAAA==.',
['木風']='木風枼:BAACLgAFFH8JAAIJAAUJxxr2AwBzAQAJAAUJxxr2AwBzAQAuAAQKfxcAAgkACQlgI7EBALYDAAkACQlgI7EBALYDAAAA.',
['木马']='木马岚:BAAALgAECgEJAgAAAA==.',
['未央']='未央丷:BAACLgAFFH8IAAIRAAMJshcUCgARAQARAAMJshcUCgARAQAuAAQKfxwAAhEABwnmIS0TAJ4CABEABwnmIS0TAJ4CAAAA.',
['末日']='末日降零:BAAALgADCgUJBQAAAA==.',
['术战']='术战术決:BAAALgAECgUJBQAAAA==.',
['李婼']='李婼惜:BAAALgAECgYJBgAAAA==.',
['李拜']='李拜天:BAAALgAECgYJCQAAAA==.',
['李捷']='李捷:BAAALgAFFAIJAgAAAA==.',
['村口']='村口蹲:BAAALgAECgQJBgAAAA==.',
['来跟']='来跟冰棍丶:BAAALgAECgQJBAAAAA==.',
['来路']='来路归途:BAAALgAECgUJCQAAAA==.',
['来追']='来追我小可爱:BAAALgAFFAQJBAAAAA==.',
['极夜']='极夜:BAAALgAFFAEJAQAAAA==.',
['林忆']='林忆宁:BAACLgAFFH8IAAIeAAQJhxN0CQBHAQAeAAQJhxN0CQBHAQAuAAQKfxwAAx4ACQl2HAoIAL4CAB4ACQkXGwoIAL4CAA0ABwnzE6orAJkBAAAA.',
['果断']='果断就会败北:BAAALgAECgYJBgABLgAECgkJFgABACggAA==.',
['果来']='果来:BAAALgADCgEJAQAAAA==.',
['枫叶']='枫叶残:BAAALgAECgUJBQAAAA==.枫叶的悲伤:BAABLgAFFH8FAAIHAAUJpQ4dBACfAQAHAAUJpQ4dBACfAQABLgAFFAYJBgAXAAkSAA==.',
['枫天']='枫天燎煞:BAAALgAECgEJAQAAAA==.',
['柒柒']='柒柒不知道:BAAALgAECgQJBwABLgAECgcJCgACAAAAAA==.',
['柠檬']='柠檬撞可乐:BAAALgAECgcJEwAAAA==.柠檬花扣:BAAALgAECgIJAgAAAA==.',
['柳生']='柳生飘絮:BAAALgAECgUJBQABLgAFFAQJDgABAEcXAA==.',
['栗不']='栗不了:BAAALgAFFAIJAgAAAA==.',
['核聚']='核聚变打击:BAABLgAFFH8IAAIUAAQJ3xWYCwAfAQAUAAQJ3xWYCwAfAQAAAA==.',
['梦之']='梦之仙子:BAAALgADCgUJBQAAAA==.',
['梦游']='梦游梦回:BAABLgAFFH8JAAIiAAQJ9REfBwDGAAAiAAQJ9REfBwDGAAAAAA==.',
['楼兰']='楼兰夜雨:BAAALgAECgMJBQAAAA==.',
['橙色']='橙色大土豆:BAAALgAECgYJBgAAAA==.',
['橡树']='橡树之心:BAAALgAECgMJAgAAAA==.',
['欣丶']='欣丶:BAAALgAECgkJCwAAAA==.',
['武僧']='武僧丶无烦恼:BAAALgAECgQJCwAAAA==.',
['殉月']='殉月:BAAALgAECgUJBQAAAA==.',
['比卡']='比卡比卡啾丶:BAAALgAECgUJBQAAAA==.',
['永远']='永远的安静:BAAALgAECgYJBgAAAA==.',
['氺蓝']='氺蓝色:BAACLgAFFH8KAAIFAAQJ0hyxDgA0AQAFAAQJ0hyxDgA0AQAuAAQKfyAAAwUACAmvIBESAAEDAAUACAmvIBESAAEDAAcAAwlYCbx5AJEAAAAA.',
['氿叭']='氿叭柒:BAAALgAECgEJAQABLgAECgEJAgACAAAAAA==.',
['汪得']='汪得福:BAAALgAECgUJBQAAAA==.',
['沃尔']='沃尔伊芙:BAABLgAFFH8GAAIUAAIJ0Ak/DACGAAAUAAIJ0Ak/DACGAAAAAA==.',
['沐无']='沐无痕:BAAALgAECgYJCQAAAA==.',
['沐灵']='沐灵:BAAALgADCgUJBQAAAA==.',
['沧桑']='沧桑未改志:BAAALgAECgMJAwAAAA==.',
['法丨']='法丨海:BAAALgAECgcJBwAAAA==.',
['泡沫']='泡沫花火:BAAALgAECgYJCwAAAA==.',
['泡泡']='泡泡茶壷:BAAALgAECgMJAwAAAA==.',
['波莱']='波莱罗:BAAALgAECgQJBwAAAA==.',
['泪三']='泪三行:BAAALgAECgYJCQAAAA==.',
['泰山']='泰山叶小冷:BAAALgADCgYJBgAAAA==.',
['洛神']='洛神图:BAAALgAECgcJAQAAAA==.',
['浅沐']='浅沐汐雨:BAAALgAECgEJAQAAAA==.',
['浅色']='浅色夏未:BAAALgAECgEJAQAAAA==.',
['浣熊']='浣熊家小耳朵:BAACLgAFFH8KAAIGAAQJwRlCFgBwAQAGAAQJwRlCFgBwAQAuAAQKfyIAAgYACAlxIf4bAAYDAAYACAlxIf4bAAYDAAAA.',
['浪谢']='浪谢守护者:BAAALgAECgcJDwAAAA==.',
['浮光']='浮光兮若流年:BAAALgAECgYJBgAAAA==.',
['海拉']='海拉鲁流氓:BAAALgAECgQJCQAAAA==.',
['消失']='消失的玛雅:BAAALgAECgcJBwAAAA==.',
['涩朗']='涩朗:BAAALgADCgMJAwAAAA==.',
['深海']='深海初音酱:BAAALgAECgMJAwAAAA==.',
['清新']='清新小法:BAAALgAECgUJCQAAAA==.',
['清玄']='清玄:BAAALgAECgYJCQAAAA==.',
['清都']='清都山水郎:BAAALgAECgYJBQAAAA==.',
['清风']='清风呼呼:BAAALgAECgYJDQAAAA==.清风武僧:BAAALgADCgIJAgAAAA==.',
['温文']='温文尔雅:BAAALgAECgYJBgAAAA==.',
['温柔']='温柔男孩坤坤:BAAALgADCgUJBQAAAA==.',
['溪溪']='溪溪:BAABLgAFFH8HAAIZAAMJtRZCFgCwAAAZAAMJtRZCFgCwAAAAAA==.',
['滋喽']='滋喽儿:BAAALgADCgEJAQAAAA==.',
['滕滕']='滕滕菜哈:BAABLgAECn8kAAQeAAcJ0BPUCQA3AQANAAcJBA+9MgB0AQAeAAYJpxLUCQA3AQAjAAIJ1wQyHQBKAAAAAA==.',
['滚滚']='滚滚:BAAALgAECgUJBQAAAA==.',
['滴滴']='滴滴嗒嗒:BAAALgAECgYJBgAAAA==.',
['潇洒']='潇洒佑能打:BAAALgAECgQJBQAAAA==.',
['潕聊']='潕聊乄帥聖騏:BAAALgADCgEJAQAAAA==.',
['火焰']='火焰之子:BAAALgAECgUJBQAAAA==.',
['灬七']='灬七尺美髯公:BAAALgAFFAEJAQAAAA==.',
['灬丶']='灬丶冫氵灬:BAAALgADCgEJAQAAAA==.',
['灬傲']='灬傲娇灬:BAACLgAFFH8RAAMGAAQJEiDiAwCHAQAGAAQJBSDiAwCHAQAkAAEJZiMYAQBsAAAuAAQKfyAAAgYACAmwJE4UAC4DAAYACAmwJE4UAC4DAAAA.',
['灬冰']='灬冰美式灬:BAAALgADCgMJAwAAAA==.',
['灬小']='灬小寳灬:BAAALgAECgcJBQABLgAECggJDwACAAAAAA==.',
['灬有']='灬有求必应灬:BAAALgADCgUJCAAAAA==.',
['灬玛']='灬玛西灬:BAAALgADCgUJBQAAAA==.',
['灬逆']='灬逆鳞丶:BAAALgAECgUJBQAAAA==.',
['灭绝']='灭绝师太:BAAALgAECgcJCAAAAA==.',
['灵翼']='灵翼之魂:BAAALgAECgcJEwAAAA==.',
['灵茗']='灵茗诺诺:BAAALgAECgYJBwAAAA==.',
['灵魂']='灵魂测量:BAAALgADCgYJDAAAAA==.',
['灸舞']='灸舞丶:BAAALgAFFAMJAwAAAA==.',
['灾狗']='灾狗蛋丶:BAAALgAECgYJBgABLgAECgcJCQACAAAAAA==.',
['炎丨']='炎丨射:BAAALgAECgcJAgAAAA==.',
['烂柠']='烂柠檬:BAAALgAECgEJAQAAAA==.',
['烈烈']='烈烈风中:BAAALgAFFAIJAgAAAA==.',
['烈焰']='烈焰云影:BAAALgAECgQJCgAAAA==.',
['烘焙']='烘焙界新秀:BAAALgAECgEJAQAAAA==.',
['烟熏']='烟熏小疯妹:BAAALgAECgYJBgAAAA==.',
['烟雨']='烟雨清寒:BAAALgAECgkJBwAAAA==.',
['焖鬻']='焖鬻:BAAALgAECgYJCwAAAA==.',
['無輌']='無輌壽仏:BAAALgAECgkJAgAAAA==.',
['煋丨']='煋丨菏:BAAALgAECgIJBAAAAA==.',
['熊德']='熊德不是熊:BAAALgAFFAEJAQAAAA==.',
['熊懋']='熊懋:BAAALgAFFAIJAgAAAA==.',
['熊猫']='熊猫世界:BAAALgAECgIJAwAAAA==.',
['爆炒']='爆炒萝卜丝:BAAALgAECgUJBQAAAA==.',
['爱上']='爱上牛妞:BAAALgAECgYJDAAAAA==.',
['爱你']='爱你的蜀黍:BAAALgADCgMJAwAAAA==.',
['爱吹']='爱吹泡泡:BAAALgADCgMJAwAAAA==.',
['爱射']='爱射:BAAALgAECgMJAwAAAA==.',
['爱德']='爱德蒙唐泰斯:BAAALgAECgUJBgAAAA==.',
['爱琴']='爱琴海小牛牛:BAAALgAFFAEJAQAAAA==.',
['爱莉']='爱莉希雅丶丶:BAAALgAECgkJCgAAAA==.',
['爽哄']='爽哄哄:BAAALgAECgMJAwAAAA==.',
['牛氣']='牛氣沖天:BAAALgAECgYJBwAAAA==.',
['牛牛']='牛牛不怕困难:BAABLgAFFH8GAAIPAAIJ2hHxFQChAAAPAAIJ2hHxFQChAAAAAA==.',
['牛肉']='牛肉细粉:BAAALgAFFAEJAQAAAA==.',
['牛黄']='牛黄说灬哼哼:BAAALgAECgEJAQAAAA==.',
['特能']='特能德尔:BAAALgADCgEJAQAAAA==.特能拉:BAABLgAECn8UAAIEAAcJiB/QPABEAgAEAAcJiB/QPABEAgAAAA==.',
['狂炫']='狂炫富婆画饼:BAAALgAFFAQJBAAAAA==.',
['狐步']='狐步舞者:BAAALgAECgUJBQAAAA==.',
['狗小']='狗小美同学:BAAALgADCgcJBwAAAA==.',
['狡猾']='狡猾:BAAALgAECgcJBwAAAA==.',
['独奏']='独奏丿战:BAAALgAFFAMJAwAAAA==.',
['独山']='独山玉:BAAALgAECgYJCgAAAA==.',
['猎人']='猎人丶无烦恼:BAAALgAECgEJAQAAAA==.',
['猎户']='猎户座:BAAALgAECgEJAQAAAA==.',
['猎魔']='猎魔人:BAAALgAECgUJBQAAAA==.',
['猛侽']='猛侽大皮皮丶:BAAALgAECgEJAQAAAA==.',
['猩红']='猩红女巫:BAAALgAECgYJCgAAAA==.',
['獣忍']='獣忍:BAAALgAECgMJAwAAAA==.',
['玄狙']='玄狙的冬天:BAAALgAECgYJBgAAAA==.',
['玉如']='玉如意丷:BAAALgAFFAMJAwABLgAFFAUJBAACAAAAAA==.',
['王老']='王老爷子:BAAALgAECgEJAQAAAA==.',
['玛丽']='玛丽莲孟获:BAAALgAECgQJBgAAAA==.',
['玩个']='玩个蛋蛋:BAAALgADCgEJAQAAAA==.',
['琦玉']='琦玉有脾气:BAAALgAECgYJBgAAAA==.',
['琴獣']='琴獣大骑士:BAAALgAFFAIJAwAAAA==.',
['瑶光']='瑶光丶陨星辰:BAAALgAECgkJBwAAAA==.',
['生吃']='生吃小姑娘:BAABLgAECn9EAAMRAAkJJiDvCwDiAgARAAcJdSPvCwDiAgAIAAgJIA7JNACVAQAAAA==.',
['男友']='男友的噩梦:BAAALgAFFAIJAQAAAA==.',
['留住']='留住了风:BAAALgAECgUJBQAAAA==.',
['疼疼']='疼疼腾总:BAAALgAECgkJCQAAAA==.',
['痞爷']='痞爷有脾气:BAAALgADCgMJAwAAAA==.',
['痴女']='痴女:BAAALgADCgcJBwAAAA==.',
['發財']='發財小红人:BAAALgAECgQJBgAAAA==.',
['白云']='白云丶:BAAALgAECgUJBQAAAA==.',
['白切']='白切鸡:BAAALgADCgEJAQAAAA==.',
['白术']='白术:BAACLgAFFH8MAAIEAAQJ0BMAGABFAQAEAAQJ0BMAGABFAQAuAAQKfyIAAgQACAlLILYbANcCAAQACAlLILYbANcCAAAA.',
['白白']='白白的大腿:BAAALgAECgMJAwAAAA==.',
['白菜']='白菜黑黑的:BAAALgAECgYJBgAAAA==.',
['白雷']='白雷丶:BAAALgAFFAMJBAABLgAFFAUJBQAEADIKAA==.',
['皇家']='皇家礼炮丶:BAAALgAECgYJCwAAAA==.',
['皎狐']='皎狐丶夜影:BAAALgAECgEJAgAAAA==.',
['皮宝']='皮宝:BAAALgADCgEJAQAAAA==.',
['皮皮']='皮皮哥丨:BAAALgAECgcJCgAAAA==.皮皮哥的妞:BAAALgAECgEJAQAAAA==.皮皮哥的德德:BAAALgAECgIJAgAAAA==.',
['盘丝']='盘丝大仙:BAAALgAECgEJAQAAAA==.',
['相关']='相关法律:BAAALgAECgUJBQAAAA==.',
['看我']='看我任意门:BAAALgAFFAEJAQAAAA==.',
['真理']='真理:BAAALgAECgMJAwAAAA==.',
['真的']='真的烦:BAAALgADCgEJAQAAAA==.',
['眾生']='眾生無冥:BAAALgAFFAEJAQAAAA==.眾生無相:BAAALgADCgcJBwAAAA==.',
['瞎子']='瞎子看世界:BAAALgADCgQJBQAAAA==.',
['碎月']='碎月与射日:BAAALgAECgYJBwAAAA==.',
['磁盘']='磁盘空间:BAAALgAECgIJAgABLgAFFAMJBQAJAPQGAA==.',
['神圣']='神圣骑丶:BAAALgAECgcJCgAAAA==.',
['神奇']='神奇牧:BAAALgADCgUJBQAAAA==.',
['神无']='神无:BAAALgAFFAMJAwAAAA==.',
['神灵']='神灵复生:BAAALgAECgYJBgAAAA==.',
['神蛊']='神蛊温皇:BAAALgAFFAIJBAAAAA==.',
['神里']='神里绫华:BAAALgADCgUJBQAAAA==.',
['神龙']='神龙教:BAAALgADCgcJBwAAAA==.',
['离歌']='离歌丶笑:BAABLgAFFH8FAAIFAAMJUhQHCQAEAQAFAAMJUhQHCQAEAQAAAA==.',
['秋天']='秋天的菠菜:BAAALgAFFAQJBAAAAA==.',
['秋雨']='秋雨如梦:BAAALgAECgYJBgAAAA==.',
['秦时']='秦时明月丶:BAAALgAECgQJBwAAAA==.',
['移日']='移日卜夜:BAAALgAECgQJAwABLgAFFAYJAwACAAAAAA==.',
['稻琪']='稻琪:BAAALgAECgEJAQAAAA==.',
['穻智']='穻智波鼬:BAAALgAECgEJAgAAAA==.',
['立功']='立功小子:BAABLgAFFH8JAAIIAAQJsRYqDQBMAQAIAAQJsRYqDQBMAQAAAA==.',
['竹剑']='竹剑皇:BAAALgAFFAIJBAAAAA==.竹剑豪:BAAALgAFFAIJAgAAAA==.',
['符文']='符文之语:BAAALgAECgMJAwAAAA==.',
['第三']='第三颗星籽:BAAALgADCgQJBAAAAA==.',
['笵笵']='笵笵:BAAALgAECgYJBgAAAA==.',
['等我']='等我搞哈幻化:BAACLgAFFH8EAAIJAAMJcRT6DAALAQAJAAMJcRT6DAALAQAuAAQKfxYABAkABwnyIR1lAJwBAAkABgnyIR1lAJwBAA4AAwmtECk4ANQAAAoAAgl5Fd4aAJ8AAAAA.',
['筝筝']='筝筝纸鸢:BAAALgAECgYJCQAAAA==.',
['筱丨']='筱丨术:BAAALgAFFAIJAgAAAA==.',
['筱小']='筱小姑娘:BAABLgAFFH8IAAIGAAMJQRNrEwD5AAAGAAMJQRNrEwD5AAAAAA==.',
['箭射']='箭射硬汉:BAAALgAFFAIJAgAAAA==.',
['糊图']='糊图图:BAABLgAECn8VAAIFAAcJ1B6yOgA4AgAFAAcJ1B6yOgA4AgAAAA==.',
['糖果']='糖果豆:BAAALgAECgEJAgAAAA==.',
['紅世']='紅世:BAAALgAECgYJEgAAAA==.',
['素笺']='素笺淡墨丶:BAAALgAECgEJAgAAAA==.',
['索索']='索索的战斗机:BAAALgAECgYJCgAAAA==.',
['紫色']='紫色小花:BAAALgAECgQJBAAAAA==.',
['紫霞']='紫霞爱至尊宝:BAAALgADCgUJBgAAAA==.',
['红唇']='红唇依旧:BAAALgAECgYJCAAAAA==.',
['红尘']='红尘乁羁绊:BAAALgAECgEJAQAAAA==.',
['红浪']='红浪漫歌舞厅:BAAALgAFFAEJAgAAAA==.',
['纨扇']='纨扇:BAAALgAECgMJAwAAAA==.',
['纯黑']='纯黑色葬礼:BAAALgAECgUJCQAAAA==.',
['纳兰']='纳兰梦境:BAAALgAECgEJAQAAAA==.',
['纳尔']='纳尔逊:BAAALgAECgYJCgAAAA==.',
['纳蕾']='纳蕾德:BAAALgADCgIJAgAAAA==.',
['绫玻']='绫玻丽:BAAALgAECgYJBgAAAA==.',
['绯翊']='绯翊:BAABLgAECn8cAAIRAAgJzyFhCwDoAgARAAgJzyFhCwDoAgAAAA==.',
['维斯']='维斯塔潘:BAAALgAECgQJCAAAAA==.',
['绿脸']='绿脸三体人:BAAALgAECgEJAQAAAA==.',
['绿野']='绿野小仙:BAAALgADCgEJAQAAAA==.',
['网逝']='网逝如风:BAAALgADCgYJBgAAAA==.',
['罙丶']='罙丶爱:BAABLgAFFH8HAAIEAAIJ1SEKEwDFAAAEAAIJ1SEKEwDFAAAAAA==.',
['群众']='群众丶:BAAALgAFFAIJBAAAAA==.',
['翘嘴']='翘嘴翘嘴:BAAALgAECgcJBwAAAA==.',
['翠羽']='翠羽登萍:BAAALgAFFAIJBAAAAA==.',
['翡翠']='翡翠龙牙:BAAALgAECgMJAwAAAA==.',
['翻滚']='翻滚肚腩:BAAALgAFFAIJAgAAAA==.',
['耀文']='耀文宝贝:BAAALgADCgYJAgAAAA==.',
['老书']='老书:BAAALgADCgEJAQAAAA==.',
['老师']='老师我肾很好:BAABLgAECn8iAAMcAAcJHB7MDQCgAQAcAAYJgiDMDQCgAQAlAAIJHBIBJQBbAAAAAA==.',
['老是']='老是被欺负:BAAALgADCgYJBgAAAA==.',
['老登']='老登也疯狂:BAAALgAECgQJBQAAAA==.老登肆否幺好:BAAALgAFFAEJAgAAAA==.',
['老虎']='老虎跳大:BAAALgAECgcJBwAAAA==.',
['聖丶']='聖丶骑:BAAALgAECgIJAgAAAA==.',
['聖骑']='聖骑:BAAALgAECggJCQAAAA==.',
['肉蛋']='肉蛋葱击:BAAALgAECgYJBgAAAA==.',
['育红']='育红班班:BAAALgAECgYJDAAAAA==.',
['胖娃']='胖娃也能飞:BAAALgAECgMJAwAAAA==.',
['胖浣']='胖浣熊:BAABLgAFFH8MAAIUAAQJYA0nEADnAAAUAAQJYA0nEADnAAAAAA==.',
['胡椒']='胡椒麻烧饼:BAAALgAECgcJCQAAAA==.',
['胶己']='胶己德奶龙:BAAALgAECgQJAwAAAA==.胶己德子:BAAALgAFFAMJAwAAAA==.',
['胸毛']='胸毛仁:BAAALgADCgUJBwAAAA==.',
['能喝']='能喝的留下:BAAALgAECgIJAgABLgAFFAEJAQACAAAAAA==.',
['腐蚀']='腐蚀之心:BAAALgAECgUJCAAAAA==.',
['腰围']='腰围三次半:BAAALgADCgQJBAAAAA==.',
['臣妾']='臣妾办不到啊:BAABLgAECn8aAAMJAAcJPCQALwBRAgAJAAYJIiEALwBRAgAOAAIJ/R/TPwC1AAAAAA==.',
['舍而']='舍而未予:BAAALgAECgEJAQAAAA==.',
['舒坡']='舒坡皮蛋:BAAALgAECgUJBwAAAA==.',
['舞處']='舞處不再:BAAALgAECgUJBgAAAA==.',
['艾丽']='艾丽娜:BAAALgAFFAMJBAAAAA==.',
['艾缌']='艾缌米达:BAABLgAFFH8JAAMYAAQJJQooFQCbAAAYAAQJJQooFQCbAAAZAAEJdSDoIQBZAAAAAA==.',
['芬芬']='芬芬的老公:BAAALgADCgEJAQAAAA==.',
['花狐']='花狐:BAAALgAECgYJBwAAAA==.',
['花钱']='花钱的三嫂:BAACLgAFFH8HAAIJAAQJXg2OFwA0AQAJAAQJXg2OFwA0AQAuAAQKfxcAAgkACQlOFCUnAHUCAAkACQlOFCUnAHUCAAAA.',
['花開']='花開富貴丶:BAAALgAFFAMJAwAAAA==.',
['芽芽']='芽芽大王:BAAALgAECgEJAQAAAA==.',
['苏拉']='苏拉米斯:BAABLgAECn8WAAIGAAcJKyRXCgAFAgAGAAcJKyRXCgAFAgAAAA==.',
['苏醒']='苏醒的堕落:BAAALgAECgcJCgAAAA==.',
['草帽']='草帽小路:BAAALgAECgcJBwAAAA==.',
['莉亚']='莉亚:BAAALgAECgMJBAAAAA==.',
['莉兹']='莉兹:BAAALgAFFAEJAgAAAA==.',
['莉莉']='莉莉丝丨:BAAALgAECgMJAwAAAA==.',
['菲比']='菲比啾比:BAACLgAFFH8PAAMJAAUJrB0jBgC+AQAJAAUJrB0jBgC+AQAOAAEJxRhOEwBYAAAuAAQKfxgAAwkABwmEJG4DAF4CAAkABwmEJG4DAF4CAA4ABAknHL4oACABAAAA.',
['萌晓']='萌晓喵:BAABLgAECn8VAAIGAAYJ6RL+qQCGAQAGAAYJ6RL+qQCGAQAAAA==.',
['萌槑']='萌槑呆淡茶:BAACLgAFFH8FAAIEAAQJhAWOHgAkAQAEAAQJhAWOHgAkAQAuAAQKfxcAAgQACQnMFeEvAHgCAAQACQnMFeEvAHgCAAAA.',
['萌萌']='萌萌的小牛:BAAALgAECgMJAwAAAA==.',
['萝莉']='萝莉丶:BAACLgAFFH8FAAIjAAIJwhVpDgCyAAAjAAIJwhVpDgCyAAAuAAQKfxUAAiMABwmaH90SAGACACMABwmaH90SAGACAAAA.',
['萧瑟']='萧瑟:BAAALgAECgEJAQAAAA==.',
['萨搏']='萨搏:BAAALgADCgUJBQAAAA==.',
['萨达']='萨达哈噜:BAACLgAFFH8KAAIJAAMJ9yS+EwBMAQAJAAMJ9yS+EwBMAQAuAAQKfx8AAwkABwk3JuQdAKMCAAkABwk3JuQdAKMCAA4AAQkAAJJXAGgAAAAA.',
['萨鲁']='萨鲁法尔小王:BAAALgAECgEJAQAAAA==.',
['落霞']='落霞与孤鹭:BAAALgAECgMJAwAAAA==.',
['蒂亚']='蒂亚莉丝:BAAALgAECgYJEgAAAA==.',
['蒋武']='蒋武德:BAAALgAECgcJBwAAAA==.',
['蒙古']='蒙古海军:BAAALgAECgIJAgAAAA==.',
['蒙牛']='蒙牛之牛:BAAALgADCgEJAQAAAA==.',
['蓝咖']='蓝咖啡:BAACLgAFFH8HAAIWAAMJawKKEAC+AAAWAAMJawKKEAC+AAAuAAQKfxoAAxYACQkGCbIZAMABABYACQkGCbIZAMABABcABQnjAb4yAIAAAAAA.',
['蓝灬']='蓝灬调:BAAALgAECgYJAQAAAA==.',
['蔡师']='蔡师傅丶:BAAALgADCgcJBwAAAA==.',
['蕾茵']='蕾茵丶穆:BAAALgAFFAIJBQAAAQ==.',
['虾钳']='虾钳高举:BAAALgAECgQJCAAAAA==.',
['蛇蝎']='蛇蝎美牛:BAAALgAECgcJCwAAAA==.',
['蛋哥']='蛋哥爱你哟:BAAALgAECgEJAQAAAA==.',
['蛮牛']='蛮牛冲锋:BAAALgAECgEJAQAAAA==.',
['蜀黍']='蜀黍术:BAAALgAECgEJAQAAAA==.',
['血月']='血月影羽:BAAALgAFFAIJAgAAAA==.',
['血舞']='血舞晨曦:BAACLgAFFH8JAAISAAQJuwW0BwDjAAASAAQJuwW0BwDjAAAuAAQKfx8AAhIACQkPEr8OAB0CABIACQkPEr8OAB0CAAAA.',
['血蹄']='血蹄飞蹬:BAAALgAECgEJAQAAAA==.',
['衲子']='衲子布可咏:BAAALgADCgYJBgAAAA==.',
['被诅']='被诅咒的幸福:BAAALgAECgEJAQAAAA==.',
['裹灬']='裹灬郡主:BAAALgAECgMJAwAAAA==.',
['西伯']='西伯利亚的王:BAAALgAECgYJBwABLgAFFAQJEQAGABIgAA==.',
['西琼']='西琼:BAAALgAECgkJAwAAAA==.',
['西红']='西红柿炒瞎子:BAAALgAFFAIJAgAAAA==.',
['誓约']='誓约之刃:BAAALgAECgIJAgAAAA==.',
['諾丶']='諾丶颜:BAAALgAFFAIJBAAAAA==.',
['让我']='让我锤一下嘛:BAAALgAECgYJBgAAAA==.',
['话事']='话事人丶:BAABLgAECn8UAAIGAAYJrCJdVwAzAgAGAAYJrCJdVwAzAgAAAA==.',
['诺米']='诺米:BAABLgAFFH8FAAIiAAMJlBf/CgD4AAAiAAMJlBf/CgD4AAAAAA==.',
['豆浆']='豆浆油条:BAAALgAFFAIJAgAAAA==.',
['豆豉']='豆豉蒸柳丁:BAABLgAFFH8FAAIHAAMJDBEIDgD2AAAHAAMJDBEIDgD2AAAAAA==.',
['豌豆']='豌豆桂:BAACLgAFFH8HAAIUAAMJsRKUDwDrAAAUAAMJsRKUDwDrAAAuAAQKfxQAAhQABgn6IYAeACgCABQABgn6IYAeACgCAAAA.豌豆颠哈:BAAALgAECgUJBQAAAA==.',
['豚豚']='豚豚大神龙:BAAALgAFFAIJAgAAAA==.',
['貔貅']='貔貅丶:BAAALgAECgcJDwAAAA==.',
['贝贝']='贝贝妮尼:BAAALgAECgIJAgAAAA==.',
['贪玩']='贪玩宝宝:BAAALgAECgUJBgAAAA==.',
['赛博']='赛博回锅肉:BAAALgAFFAIJAgABLgAFFAQJDgABAEcXAA==.',
['赛纳']='赛纳牛斯:BAAALgAFFAIJAgAAAA==.',
['赛貂']='赛貂婵:BAAALgADCgEJAQAAAA==.',
['起剑']='起剑问明月:BAAALgAECgcJEAAAAA==.',
['超大']='超大力超级:BAAALgAECgEJAgAAAA==.',
['超级']='超级蜗牛:BAAALgAECgEJAQAAAA==.',
['超能']='超能花花:BAAALgAECgEJAQAAAA==.',
['越扯']='越扯越淡:BAAALgADCgIJAgAAAA==.',
['跑得']='跑得快最重要:BAAALgAFFAEJAgAAAA==.',
['跨马']='跨马提枪:BAAALgAECgYJDAAAAA==.',
['踏血']='踏血临风:BAAALgAECgYJCQAAAA==.踏血苍龙:BAAALgAECgIJAgAAAA==.',
['蹦蹦']='蹦蹦哒:BAAALgADCgIJAgAAAA==.',
['軁举']='軁举刄:BAAALgADCgEJAQAAAA==.',
['转身']='转身过后:BAAALgADCgEJAgAAAA==.',
['转运']='转运顺起来:BAAALgAFFAEJAQAAAA==.',
['输出']='输出标杆:BAAALgADCgcJBwAAAA==.',
['辣是']='辣是针滴妞劈:BAAALgAECgEJAQAAAA==.',
['这次']='这次一定不鸽:BAAALgAECgUJBQAAAA==.',
['进击']='进击的酒桶:BAAALgAECgQJBAAAAA==.',
['远方']='远方与诗:BAAALgADCgQJBAAAAA==.',
['远程']='远程打击:BAAALgAECgMJAwAAAA==.',
['迷糊']='迷糊小勺子:BAACLgAFFH8GAAIXAAMJwAgFAQDvAAAXAAMJwAgFAQDvAAAuAAQKfxgAAhcABwlbG0gLACYCABcABwlbG0gLACYCAAAA.',
['逃离']='逃离魔法武僧:BAAALgAECggJCQAAAA==.',
['逆十']='逆十字的复仇:BAABLgAFFH8IAAIhAAMJXx2bAwCrAAAhAAMJXx2bAwCrAAAAAA==.',
['逆风']='逆风之翼:BAABLgAFFH8FAAIUAAMJawwAGwCOAAAUAAMJawwAGwCOAAAAAA==.',
['逍遥']='逍遥坏坏生:BAAALgAECgYJCAAAAA==.',
['道友']='道友不死贫道:BAAALgADCgEJAQAAAA==.',
['邪恶']='邪恶波比:BAAALgAFFAMJBAABLgAFFAgJBAACAAAAAA==.',
['邹妮']='邹妮玛大王:BAAALgADCgQJBAAAAA==.',
['部落']='部落姜子牙:BAAALgAECgYJDwAAAA==.',
['酒后']='酒后眼迷离:BAAALgADCgEJAQAAAA==.',
['酒吞']='酒吞童子:BAAALgAECgMJAwAAAA==.',
['酸爽']='酸爽牛肉丝:BAAALgAFFAIJBAAAAA==.',
['酸菜']='酸菜牛:BAAALgAFFAIJBAABLgAECgYJCQACAAAAAA==.',
['醉太']='醉太平:BAAALgAFFAIJBAAAAA==.',
['醉心']='醉心葬梨花:BAAALgAECgYJCwAAAA==.醉心葬黎花:BAAALgADCgkJCQAAAA==.',
['重案']='重案组之猛禽:BAAALgAFFAEJAgAAAA==.重案组之蝰蛇:BAAALgAFFAIJAgAAAA==.重案组偷心猫:BAAALgAECgEJAQABLgAFFAEJAgACAAAAAA==.重案组叮咚鸡:BAAALgAECgUJBwAAAA==.',
['重生']='重生之我是:BAABLgAECn8VAAMgAAcJ4CUEBwDBAgAgAAcJLiMEBwDBAgAEAAYJPybjKgCNAgAAAA==.',
['野狼']='野狼与梦:BAAALgAECgEJAwAAAA==.',
['野蔷']='野蔷薇:BAAALgADCgEJAQAAAA==.',
['鐘無']='鐘無艷:BAAALgAECgUJCgAAAA==.',
['钦点']='钦点的武举人:BAACLgAFFH8JAAIEAAQJmhN8FQBNAQAEAAQJmhN8FQBNAQAuAAQKfxcAAgQACAlgG586AEwCAAQACAlgG586AEwCAAAA.',
['铁甲']='铁甲依然在:BAAALgAECgYJBwAAAA==.铁甲小宝:BAAALgADCgYJBgAAAA==.',
['银色']='银色战车:BAAALgAECgMJAwAAAA==.',
['長離']='長離:BAAALgADCgMJAwAAAA==.',
['闭着']='闭着眼睛叫:BAAALgADCgYJAgAAAA==.',
['阅桥']='阅桥段:BAABLgAFFH8GAAIFAAIJMx0fHAC/AAAFAAIJMx0fHAC/AAAAAA==.',
['阿凡']='阿凡达呀:BAAALgAECgEJAQAAAA==.',
['阿勒']='阿勒纳德:BAAALgAECgYJBwAAAA==.',
['阿尔']='阿尔托:BAAALgAECgYJBwAAAA==.阿尔托莉唖:BAAALgAECgEJAgAAAA==.',
['阿罪']='阿罪丶:BAAALgAECgUJBgAAAA==.',
['阿萨']='阿萨斯之泪:BAABLgAECn8aAAIJAAgJqgoLbACJAQAJAAgJqgoLbACJAQAAAA==.',
['阿蒂']='阿蒂卡达:BAAALgADCgIJAgAAAA==.',
['阿霖']='阿霖丶:BAAALgAECgYJBgAAAA==.',
['阿魯']='阿魯卡多:BAABLgAFFH8IAAIFAAQJHSEuBQCdAQAFAAQJHSEuBQCdAQAAAA==.',
['陀地']='陀地驱魔人:BAAALgAECgYJCQAAAA==.',
['陀妈']='陀妈头:BAAALgAECgYJCQAAAA==.',
['陈富']='陈富贵:BAABLgAECn8VAAIPAAgJQBRkLQCwAQAPAAgJQBRkLQCwAQAAAA==.',
['陪一']='陪一根:BAAALgAECgUJBgAAAA==.',
['陰天']='陰天與小詩君:BAAALgAECgYJBAAAAA==.',
['陳陳']='陳陳猪:BAAALgAECgYJCgAAAA==.',
['难为']='难为水不是云:BAAALgAECgEJAgAAAA==.',
['难免']='难免挨打:BAAALgAECgIJAgAAAA==.',
['雅棋']='雅棋:BAACLgAFFH8MAAIZAAQJ3AMuDwD0AAAZAAQJ3AMuDwD0AAAuAAQKfyMAAhkACAlfFpczANoBABkACAlfFpczANoBAAAA.',
['離開']='離開以後:BAAALgAECgUJBwAAAA==.',
['雨落']='雨落纱幔:BAAALgAFFAIJBAAAAA==.雨落飞剑:BAAALgAFFAIJBAAAAA==.',
['雪渐']='雪渐:BAAALgAECgUJBQAAAA==.',
['零九']='零九幺幺:BAAALgAFFAIJAwAAAA==.',
['雷神']='雷神丶索尔:BAAALgAECgMJAwAAAA==.',
['雷霆']='雷霆怒风丹:BAAALgADCggJCAAAAA==.',
['雷顿']='雷顿:BAAALgAFFAIJBAAAAA==.',
['雾眠']='雾眠:BAAALgAECgUJAQAAAA==.',
['霄飞']='霄飞练:BAAALgAECgEJAgAAAA==.',
['霜爱']='霜爱舞:BAAALgAFFAIJAQAAAA==.',
['青丘']='青丘丶白浅:BAAALgAECgcJEQAAAA==.',
['青丶']='青丶争:BAAALgAECgIJAgAAAA==.',
['青澈']='青澈:BAAALgAECgEJAQABLgAFFAIJAgACAAAAAA==.',
['面包']='面包供应商:BAAALgADCgMJAwAAAA==.',
['颠覆']='颠覆法则的猫:BAAALgAECgYJBgAAAA==.',
['风中']='风中呢喃:BAAALgAECgUJBQAAAA==.',
['风暴']='风暴丶图图:BAAALgADCgEJAQAAAA==.风暴的冬天:BAAALgAECgUJBQAAAA==.风暴英雄:BAAALgAECgQJBAAAAA==.',
['风浅']='风浅:BAAALgADCgYJBgAAAA==.',
['飓魔']='飓魔蘸酱:BAAALgAECgcJBwAAAA==.',
['飞天']='飞天小银狼灬:BAAALgAFFAEJAQAAAA==.',
['飞花']='飞花:BAABLgAFFH8HAAIiAAMJHAzYDQDCAAAiAAMJHAzYDQDCAAAAAA==.',
['饼干']='饼干波比:BAAALgAECggJCAAAAA==.',
['首尔']='首尔之春:BAAALgAECgQJBAAAAA==.',
['首席']='首席鉴黄师:BAAALgAFFAEJAQAAAA==.',
['香辣']='香辣小龙虾:BAAALgAECgEJAQAAAA==.',
['驴丶']='驴丶打滚:BAAALgAECgYJBgAAAA==.',
['骑天']='骑天大聖:BAAALgADCgUJBQAAAA==.',
['鬼新']='鬼新娘:BAAALgAECgEJAQAAAA==.',
['魂之']='魂之哀殇:BAAALgAFFAEJAQAAAA==.',
['魂小']='魂小沫:BAAALgAECgEJAQAAAA==.',
['魔人']='魔人琦琦:BAAALgADCgYJBgAAAA==.',
['魔导']='魔导师莉娜:BAAALgAECgEJAgAAAA==.',
['魔心']='魔心:BAAALgAECgcJDQAAAA==.',
['魔神']='魔神争霸骑士:BAAALgAECgUJDQAAAA==.',
['魚哔']='魚哔哔:BAABLgAFFH8IAAIfAAMJUBXqAgD7AAAfAAMJUBXqAgD7AAAAAA==.',
['鱼头']='鱼头:BAAALgAECgkJCQAAAA==.',
['鱼辣']='鱼辣:BAAALgAFFAMJBAAAAA==.',
['鱼饼']='鱼饼丶:BAAALgAECgYJDAAAAA==.',
['鲸魚']='鲸魚:BAACLgAFFH8JAAIEAAMJAgQKEgDZAAAEAAMJAgQKEgDZAAAuAAQKfxUAAgQACAn6F7Q6AEwCAAQACAn6F7Q6AEwCAAAA.',
['麻哩']='麻哩麻哩轰:BAAALgAECgcJCAAAAA==.',
['麻辣']='麻辣小兔丁丶:BAAALgAECgUJCgAAAA==.',
['黄昏']='黄昏界:BAAALgAECgMJAwAAAA==.黄昏的曼陀铃:BAAALgAFFAIJAwAAAA==.',
['黄桃']='黄桃芒果椰果:BAAALgAFFAEJAQAAAA==.',
['黄油']='黄油啤酒灬:BAACLgAFFH8VAAIWAAYJgCRyAACPAgAWAAYJgCRyAACPAgAuAAQKfxYAAxYABwmOIJcLAHwCABYABwmOIJcLAHwCABcAAQkWBwVDACkAAAAA.',
['黑人']='黑人辨灬:BAAALgAECgEJAQAAAA==.',
['黑白']='黑白电视机:BAAALgAECgYJBwAAAA==.',
['黑糖']='黑糖花妹:BAAALgADCgIJAgAAAA==.',
['黑羽']='黑羽川:BAAALgAFFAEJAgAAAA==.',
['黯羽']='黯羽清灵:BAAALgAECgQJBgAAAA==.',
['黯翼']='黯翼飞宵:BAAALgAECgcJEAAAAA==.',
['龙战']='龙战天下:BAAALgAFFAIJBAAAAA==.',
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
