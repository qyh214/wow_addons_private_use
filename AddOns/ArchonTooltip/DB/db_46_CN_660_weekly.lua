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

local lookup = {'Warrior-Protection','Hunter-Marksmanship','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Unknown-Unknown','DeathKnight-Unholy','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Blood','Warrior-Arms','Druid-Restoration','Monk-Brewmaster','Monk-Mistweaver','Hunter-BeastMastery','DemonHunter-Devourer','DemonHunter-Havoc','Mage-Frost','Mage-Arcane','Evoker-Devastation','Warlock-Demonology','Warlock-Destruction','Evoker-Augmentation','Evoker-Preservation','Warrior-Fury','Druid-Guardian','Mage-Fire','Shaman-Enhancement','Monk-Windwalker','Warlock-Affliction',}
local provider = {region='CN',realm='山丘之王',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aiman:BAAALgAECgUJBQAAAA==.Aimr:BAAALgADCgEJAQAAAA==.',
Al='Alexanderw:BAAALgAECgYJBgAAAA==.',
At='Atheña:BAAALgAFFAIJAgAAAA==.',
Au='Auaodk:BAAALgAECgIJAgAAAA==.',
Az='Azazell:BAAALgAFFAEJAQAAAA==.',
Be='Belka:BAAALgAFFAQJBAAAAA==.',
Bi='Bigpp:BAAALgAECgUJBQAAAA==.',
Bj='Bjgre:BAAALgAECgYJCAAAAA==.Bjgree:BAAALgAECgYJBgAAAA==.',
Bu='Bulbulhhl:BAAALgAECgcJCwAAAA==.',
Ch='Chaeyoung:BAAALgAECgcJDAABLgAFFAcJDQABAM4ZAA==.Chisa:BAABLgAFFH8FAAICAAIJ2QkdIACUAAACAAIJ2QkdIACUAAABLgAFFAMJCAADAEMjAA==.',
Co='Coolling:BAAALgAECgQJBgAAAA==.',
De='Demondh:BAAALgAFFAQJAgAAAA==.',
Du='Duwu:BAAALgAECgIJAgAAAA==.',
Ea='East:BAAALgAFFAIJBAAAAA==.',
Ev='Everloveu:BAAALgAFFAIJAwAAAA==.',
Fa='Faner:BAAALgAECgcJDwAAAA==.',
Fi='Finale:BAAALgAFFAYJBAAAAA==.',
Fr='Frostheart:BAABLgAECn8eAAQEAAgJDAgvRwBbAQAEAAgJDAgvRwBbAQADAAYJ7A01NgDAAAAFAAMJQwcbOQBbAAAAAA==.',
Ga='Gailbulle:BAAALgAECgYJBwAAAA==.',
Gr='Grumbar:BAAALgAECgEJAQAAAA==.',
Ha='Hakunamatatà:BAAALgAFFAEJAgABLgAFFAQJBAAGAAAAAA==.Hathor:BAAALgAECgcJDQAAAA==.',
Id='Idontbite:BAAALgAECgQJAwAAAA==.',
Ja='Janescript:BAAALgAECgUJBQAAAA==.',
Ka='Kaffka:BAABLgAECn8hAAIHAAgJjyStCwA+AwAHAAgJjyStCwA+AwAAAA==.',
Ke='Kelemvor:BAAALgAECgEJAQAAAA==.',
Ko='Kotoki:BAAALgAECgEJAQAAAA==.',
Ld='Ldun:BAAALgAECgQJBAAAAA==.',
Le='Lemolo:BAABLgAFFH8GAAIIAAIJcA+zFACeAAAIAAIJcA+zFACeAAAAAA==.',
Lu='Luu:BAAALgAECgUJBQAAAA==.',
Ma='Mayhem:BAAALgADCgIJAgAAAA==.',
Mi='Midnightyi:BAAALgAECgYJCgAAAA==.',
Mu='Muzi:BAAALgAECgYJDAAAAA==.',
Na='Nanpaism:BAABLgAFFH8FAAIJAAIJHxfiFgChAAAJAAIJHxfiFgChAAAAAA==.Nanpaiws:BAAALgAECgUJBQAAAA==.Nasdaq:BAAALgAECgEJAQAAAA==.Natonuclear:BAABLgAECn8UAAMKAAkJIRSLNgB5AQAKAAYJ+hKLNgB5AQAJAAkJmRBGdgC3AAAAAA==.',
Ne='Nevermore:BAAALgAECgEJAgAAAA==.',
No='Nombre:BAAALgAFFAIJAgAAAA==.',
Od='Odles:BAACLgAFFH8OAAILAAQJjSWKAwDCAQALAAQJjSWKAwDCAQAuAAQKfyMAAwsACAnPJDcFAEADAAsACAnPJDcFAEADAAwAAgktGuQXAHUAAAAA.',
Pa='Partypoison:BAAALgAFFAEJAQAAAA==.',
Pl='Playergpfgxj:BAAALgAECgEJAgAAAA==.',
Po='Popa:BAAALgAECgcJEgAAAA==.',
Pr='Prayery:BAAALgADCgUJBQABLgAFFAIJBgAIAHAPAA==.Promentheus:BAAALgADCgIJAgAAAA==.',
Ra='Rayx:BAACLgAFFH8UAAINAAUJLhbsBABWAQANAAUJLhbsBABWAQAuAAQKfx8AAg0ACAk0H8cJAIACAA0ACAk0H8cJAIACAAAA.',
Re='Relier:BAAALgAECgYJDgAAAA==.Requiem:BAAALgADCgUJBQAAAA==.',
Ri='Rising:BAAALgAECgcJBwAAAA==.',
Ro='Romefrater:BAAALgAECgkJDQAAAA==.',
Sa='Sakuya:BAAALgAECgYJCQAAAA==.',
Sc='Scarletdoll:BAABLgAECn8fAAMOAAgJSCHfAwC9AgAOAAcJZyLfAwC9AgABAAMJIxkfMgC0AAAAAA==.',
Sh='Shallow:BAAALgADCgEJAQAAAA==.',
Sk='Skyeblue:BAAALgAECgEJAQAAAA==.',
Ud='Udyr:BAAALgADCgEJAQAAAA==.',
Us='Ustinian:BAAALgAECgEJAQAAAA==.',
Ve='Veros:BAACLgAFFH8NAAIPAAQJwSEvBgB1AQAPAAQJwSEvBgB1AQAuAAQKfxQAAg8ABgk5JZgZAGwCAA8ABgk5JZgZAGwCAAAA.',
Wi='Willowwillo:BAAALgAECgMJAwAAAA==.Wisp:BAABLgAECn8WAAIPAAYJdxB7XwAzAQAPAAYJdxB7XwAzAQAAAA==.',
Xi='Xiaoluobo:BAABLgAFFH8FAAIDAAIJjRn7HAC5AAADAAIJjRn7HAC5AAAAAA==.',
Yi='Yiransnowk:BAACLgAFFH8NAAIDAAQJHx2JBgCGAQADAAQJHx2JBgCGAQAuAAQKfyYAAgMACAkHJM8JAEIDAAMACAkHJM8JAEIDAAAA.Yiransnowks:BAAALgAECgUJBgAAAA==.',
Yo='Yo:BAAALgAFFAIJBAAAAA==.',
Zo='Zoreyueshen:BAAALgAECgcJCgAAAA==.',
['一个']='一个小榴莲:BAAALgAECgYJBgAAAA==.',
['一二']='一二三二一:BAAALgAECgIJAwAAAA==.',
['一勺']='一勺毒奶:BAAALgADCgIJAgAAAA==.',
['一十']='一十一:BAAALgAECgEJAQAAAA==.',
['一只']='一只会飞的熊:BAAALgAECgkJCQAAAA==.',
['一尘']='一尘:BAAALgAECgYJCwAAAA==.',
['一手']='一手微风:BAAALgAECgEJAQAAAA==.',
['一硬']='一硬两三天:BAAALgAECgYJDgAAAA==.',
['一蝶']='一蝶舞三乐一:BAAALgAECgMJAwAAAA==.',
['万塔']='万塔:BAAALgAECgMJBAAAAA==.',
['三分']='三分男吊丝:BAACLgAFFH8NAAIQAAQJkhZqCwArAQAQAAQJkhZqCwArAQAuAAQKfxQAAxAABwkzGicKAE0BABAABwkzGicKAE0BABEABQn2BaZNAJ8AAAAA.',
['三角']='三角小辫子:BAAALgAECgIJAgAAAA==.',
['上泉']='上泉信纲:BAAALgAECgEJAQAAAA==.',
['下限']='下限酱丶:BAAALgAECgYJBgAAAA==.',
['不祥']='不祥之兆:BAAALgAECgYJCQAAAA==.',
['世界']='世界都欺棱了:BAAALgAECgEJAgAAAA==.世界都欺綾了:BAAALgAECgEJAQAAAA==.',
['东风']='东风恶:BAAALgAECgQJBAAAAA==.',
['丨倒']='丨倒头就睡:BAAALgAECgEJAQAAAA==.',
['丨老']='丨老和丨:BAAALgADCgIJAgAAAA==.',
['丰川']='丰川祥子:BAAALgAECgEJAgAAAA==.',
['丶一']='丶一缕阳光:BAAALgAECgUJBQAAAA==.',
['丶三']='丶三叶:BAAALgAECgIJAgAAAA==.',
['丶下']='丶下一月:BAAALgAECgYJBwAAAA==.',
['丶墓']='丶墓中无人:BAAALgAECgEJAQAAAA==.',
['丶白']='丶白的刺眼:BAAALgAECgIJAgAAAA==.',
['丶荼']='丶荼蘼:BAAALgAECgEJAQAAAA==.',
['丶阿']='丶阿呱丶:BAAALgADCgQJBQAAAA==.',
['丶雨']='丶雨季:BAAALgAECgIJAwAAAA==.',
['丷溜']='丷溜溜丷:BAAALgAECgEJAQAAAA==.',
['丿落']='丿落花随风:BAAALgAECgIJAgAAAA==.',
['乌瑟']='乌瑟尔丶锋:BAAALgAECgYJBwAAAA==.',
['乔露']='乔露诺乔巴娜:BAAALgADCgEJAQAAAA==.',
['乖乖']='乖乖快滚:BAAALgAFFAIJAwAAAA==.乖乖的猪猪:BAAALgAFFAEJAgAAAA==.',
['九条']='九条裟罗:BAABLgAFFH8FAAISAAMJew4YDAABAQASAAMJew4YDAABAQAAAA==.',
['二花']='二花不嗦:BAAALgAFFAEJAQAAAA==.',
['二队']='二队牧師:BAAALgAECgYJAQAAAA==.',
['云和']='云和山的彼端:BAAALgAFFAIJAgAAAA==.',
['亚朵']='亚朵艾克斯:BAAALgAECgEJAwAAAA==.',
['人生']='人生如水:BAAALgAECgMJAwAAAA==.',
['以前']='以前以後:BAAALgADCgEJAQAAAA==.',
['仲尼']='仲尼不死:BAAALgAECgcJBwAAAA==.',
['伊利']='伊利逗逗:BAAALgAECgkJCQAAAA==.伊利達蕾:BAACLgAFFH8GAAITAAMJYQO1IADNAAATAAMJYQO1IADNAAAuAAQKfx8AAxMACAl1F2REAOIBABMACAl2FmREAOIBABQABgmtFzI0ADkBAAAA.',
['伊睿']='伊睿莎:BAAALgAECgUJBQAAAA==.',
['佐仓']='佐仓瞳月:BAAALgAECgYJBgAAAA==.',
['余悸']='余悸:BAAALgAECgYJBgAAAA==.',
['作死']='作死作活:BAAALgAECgUJBgAAAA==.',
['你的']='你的狗宝贝:BAAALgAECgIJAgAAAA==.',
['依依']='依依乖囡囡:BAAALgAFFAQJBAAAAA==.',
['依然']='依然忘不了你:BAAALgADCgQJBQAAAA==.',
['修宝']='修宝:BAAALgAECgMJAwAAAA==.',
['借东']='借东风:BAAALgAECgYJEQAAAA==.',
['健康']='健康活泼:BAAALgAECgEJAQAAAA==.',
['傀儡']='傀儡丶娃娃:BAAALgADCgYJBgAAAA==.',
['光明']='光明奶牛:BAABLgAFFH8FAAIDAAQJWAb2EwAIAQADAAQJWAb2EwAIAQAAAA==.',
['免兔']='免兔免兔兔免:BAACLgAFFH8QAAIJAAUJORx4AwCfAQAJAAUJORx4AwCfAQAuAAQKfxgAAgkACAnVHtALAMMCAAkACAnVHtALAMMCAAAA.免兔兔免免兔:BAAALgAECgEJAQABLgAFFAUJEAAJADkcAA==.免兔兔免兔免:BAAALgAECgEJAQABLgAFFAUJEAAJADkcAA==.',
['兔免']='兔免兔免兔免:BAAALgAFFAEJAQABLgAFFAUJEAAJADkcAA==.',
['兔兔']='兔兔免兔免免:BAAALgAECgEJAQABLgAFFAUJEAAJADkcAA==.',
['兜兜']='兜兜里有花:BAAALgAECgcJEwAAAA==.',
['兜米']='兜米:BAAALgAECggJEQAAAA==.',
['兜里']='兜里丿有糖:BAAALgAFFAIJAgAAAA==.',
['六尘']='六尘:BAAALgAFFAEJAQAAAA==.',
['冰封']='冰封爱恋:BAAALgAECgkJEgAAAA==.',
['冰火']='冰火奥利奥:BAAALgAECgEJAgAAAA==.',
['冲锋']='冲锋拦截:BAAALgAECgEJAQAAAA==.',
['冷兵']='冷兵器大神:BAAALgADCgEJAQAAAA==.',
['冷月']='冷月无声:BAAALgAECgIJAwAAAA==.',
['冷灬']='冷灬凌雪:BAAALgADCgEJAQAAAA==.',
['凝墨']='凝墨:BAAALgAECgIJAwAAAA==.',
['凨伊']='凨伊:BAAALgAECgYJBgAAAA==.',
['凯兰']='凯兰崔尔:BAAALgAECgEJAQAAAA==.',
['别嘬']='别嘬我会奶:BAAALgAECgUJCwAAAA==.',
['别奶']='别奶我自己嘬:BAAALgAECgEJAQAAAA==.',
['刺猬']='刺猬小小:BAAALgAFFAEJAQAAAA==.',
['剑气']='剑气昂然:BAAALgAECgkJAQAAAA==.',
['劃船']='劃船不用桨:BAABLgAFFH8GAAIHAAMJAhEAKgDyAAAHAAMJAhEAKgDyAAAAAA==.',
['勇敢']='勇敢的羿儿:BAAALgAECgcJCgAAAA==.',
['包工']='包工包料嘛:BAAALgAECgEJAQAAAA==.',
['包贰']='包贰奶:BAAALgAECgYJBwAAAA==.',
['十二']='十二星座唫牛:BAAALgAECgEJAQAAAA==.',
['南宫']='南宫贝贝:BAAALgAECgEJAQAAAA==.',
['卜卜']='卜卜的卜卜:BAAALgADCgQJBAAAAA==.',
['占星']='占星师孙连城:BAAALgAECgEJAQAAAA==.',
['卡了']='卡了米:BAAALgAECgYJCQAAAA==.',
['卡卡']='卡卡夫:BAABLgAECn8YAAIBAAYJiBxpEQDxAQABAAYJiBxpEQDxAQAAAA==.',
['卡哇']='卡哇咿:BAAALgADCgUJBQAAAA==.',
['卡夫']='卡夫:BAAALgAECgcJDwAAAA==.卡夫夫:BAAALgAFFAMJAwAAAA==.',
['卡特']='卡特布鲁斯:BAAALgAFFAEJAgAAAA==.',
['原初']='原初巴哈姆特:BAAALgAFFAIJAQAAAA==.',
['厥灵']='厥灵霄:BAAALgAECgQJBAAAAA==.',
['叁小']='叁小姐:BAAALgAECgMJBAAAAA==.',
['又恐']='又恐琼楼玉宇:BAAALgAECgUJBQAAAA==.',
['双魚']='双魚理:BAAALgAFFAQJBAABLgAFFAYJCwAVAMUbAA==.',
['反派']='反派:BAABLgAECn8VAAMWAAYJziRVAwBAAgAWAAYJziRVAwBAAgAVAAYJrR5qYgAVAgAAAA==.',
['发财']='发财平安:BAAALgADCgUJGAAAAA==.',
['变身']='变身给你看:BAAALgADCgMJAwAAAA==.',
['口可']='口可口可没:BAAALgAECgEJAQAAAA==.',
['古稀']='古稀:BAAALgAECgQJBAAAAA==.',
['古老']='古老师:BAAALgAECgQJBAAAAA==.',
['叭叭']='叭叭的八八:BAAALgAECgIJAgAAAA==.',
['叶萘']='叶萘法:BAAALgAECgYJCQAAAA==.',
['叽里']='叽里呱啦:BAAALgADCgMJAwAAAA==.',
['吉良']='吉良吉星:BAAALgAFFAMJBAAAAA==.',
['含家']='含家橙:BAAALgAECgEJAQAAAA==.',
['听风']='听风落雨:BAAALgAECgYJBgAAAA==.听风讲她故事:BAAALgAECgQJBwAAAA==.',
['吹星']='吹星:BAAALgAECgIJAgAAAA==.',
['和泉']='和泉纱雾:BAAALgAECgMJAwAAAA==.',
['咖哩']='咖哩牛腩:BAAALgAECgYJCgAAAA==.',
['哇哦']='哇哦丶谢谢你:BAAALgADCgYJBgAAAA==.',
['哈士']='哈士骑:BAACLgAFFH8MAAIDAAQJ6RFcDABJAQADAAQJ6RFcDABJAQAuAAQKfx4AAwMACAk7HpUoAIMCAAMACAk7HpUoAIMCAAQAAgkEBN2LAE4AAAAA.',
['哈耶']='哈耶克的大手:BAAALgADCgcJDwABLgAECgcJCgAGAAAAAA==.',
['哈雷']='哈雷丶:BAABLgAFFH8JAAIJAAQJphj8CgAoAQAJAAQJphj8CgAoAQABLgAFFAYJFgAKAMUZAA==.',
['哥萨']='哥萨克狼咩:BAAALgAECgYJBgAAAA==.',
['哲学']='哲学家:BAAALgAECgcJCQAAAA==.',
['唐悠']='唐悠悠:BAACLgAFFH8PAAIFAAQJfCE8AACHAQAFAAQJfCE8AACHAQAuAAQKfyAAAgUACAmfIngCAA4DAAUACAmfIngCAA4DAAAA.',
['啾如']='啾如雪:BAACLgAFFH8OAAMPAAUJJxhxCQA+AQAPAAUJJxhxCQA+AQAIAAEJSQZUHABFAAAuAAQKfxQAAw8ACAlCGvkfAEICAA8ACAlCGvkfAEICAAgAAQmDA5mBAC8AAAAA.',
['喜多']='喜多川海夢:BAAALgAECgMJBAAAAA==.',
['喝奶']='喝奶多长得快:BAAALgAECgYJBgAAAA==.',
['喵豆']='喵豆子:BAAALgADCgEJAQAAAA==.',
['噬魂']='噬魂天:BAAALgAECgUJDQAAAA==.',
['回忆']='回忆倒计时:BAAALgADCgEJAQAAAA==.',
['国宝']='国宝丶:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光保佑着你:BAAALgADCgMJBgAAAA==.圣光的玛小丽:BAAALgADCgIJAgAAAA==.',
['圣琪']='圣琪琦:BAAALgAECgIJAwAAAA==.',
['地狱']='地狱无门:BAAALgAECgEJAQAAAA==.',
['坊屋']='坊屋春道:BAAALgADCgIJAgAAAA==.',
['坑队']='坑队友:BAAALgAECgIJAgAAAA==.',
['埃玟']='埃玟:BAAALgAECgEJAQAAAA==.',
['墙角']='墙角影子:BAAALgAECgYJBgAAAA==.',
['壮壮']='壮壮丶:BAAALgAECgUJBgABLgAFFAYJBgAXAAkSAA==.',
['壹号']='壹号女嘉宾:BAAALgADCgEJAQAAAA==.',
['夏了']='夏了个天:BAAALgAECgkJEgAAAA==.',
['夏威']='夏威夷晓花裙:BAAALgAECgEJAQAAAA==.',
['夏拉']='夏拉希魔灾:BAAALgAECgUJBQAAAA==.',
['夏至']='夏至易至:BAAALgAECgMJAwABLgAFFAMJBQADAKYhAA==.',
['夕颜']='夕颜若雪:BAAALgAECgEJAQAAAA==.',
['多情']='多情红玫瑰:BAAALgAECgcJEgAAAA==.',
['夜曦']='夜曦:BAAALgAECgEJAQAAAA==.',
['大个']='大个子丶:BAAALgAECgQJBAAAAA==.',
['大叔']='大叔私奔吧:BAAALgAECgMJAwAAAA==.',
['大地']='大地飞歌:BAABLgAECn8WAAIIAAcJUxrOHAAaAgAIAAcJUxrOHAAaAgAAAA==.',
['大法']='大法师奥的表:BAAALgADCgUJBQAAAA==.',
['大海']='大海马:BAAALgAECgIJAwAAAA==.',
['大西']='大西几:BAAALgAECgcJCAAAAA==.',
['天之']='天之琪琪:BAAALgADCgYJBgAAAA==.',
['天地']='天地通明:BAAALgAECgEJAQAAAA==.',
['天堂']='天堂无路:BAAALgAECgEJAQAAAA==.',
['天壤']='天壤之劫火:BAAALgAECgYJCgAAAA==.',
['天枢']='天枢:BAAALgADCgEJAQAAAA==.',
['天气']='天气转凉:BAAALgAECgEJAQAAAA==.',
['天翎']='天翎:BAAALgAECgQJBQAAAA==.',
['头晕']='头晕是正常的:BAAALgAECgQJBAAAAA==.',
['奥利']='奥利波斯猎:BAAALgAECgIJAwAAAA==.奥利薇耶:BAAALgAECgcJBAAAAA==.',
['女人']='女人是老虎:BAAALgAECgkJCQAAAA==.',
['奶豆']='奶豆:BAAALgADCgEJAQAAAA==.',
['好热']='好热:BAAALgAECgQJBAAAAA==.',
['妖精']='妖精艾露莎:BAAALgAECgMJAwAAAA==.',
['姬塔']='姬塔:BAAALgAECgkJCQAAAA==.',
['宇夜']='宇夜:BAAALgAFFAMJBAAAAA==.',
['宇宙']='宇宙奥秘:BAAALgADCgYJBgAAAA==.',
['宇宸']='宇宸果果:BAAALgAFFAIJAgAAAA==.',
['守护']='守护火:BAAALgAECgEJAwAAAA==.',
['安因']='安因因:BAAALgAECgYJBgAAAA==.',
['安德']='安德莉娜:BAAALgADCgYJBgAAAA==.',
['完颜']='完颜洪烈:BAAALgAECgYJAgAAAA==.',
['宝丽']='宝丽来:BAAALgAECgIJAgAAAA==.',
['宝黛']='宝黛色迷恋:BAAALgAECgEJAgAAAA==.',
['宫园']='宫园薰:BAAALgAECgcJCQAAAA==.',
['寒风']='寒风将至:BAAALgAECgEJAgAAAA==.',
['小丨']='小丨小:BAAALgAECgYJBgAAAA==.',
['小亮']='小亮丶影刃:BAAALgADCgUJAQAAAA==.',
['小佑']='小佑丶佑:BAAALgADCgIJAgAAAA==.小佑佑丶:BAAALgAECgYJEgAAAA==.',
['小灬']='小灬佑佑:BAAALgADCgEJAQAAAA==.',
['小菲']='小菲菲:BAAALgAFFAEJAQAAAA==.',
['小蛋']='小蛋糕丿:BAAALgAECgMJAwAAAA==.',
['小襁']='小襁褓:BAAALgAECgYJBwAAAA==.',
['小辈']='小辈放下机缘:BAACLgAFFH8IAAIYAAQJsBinEQBXAQAYAAQJsBinEQBXAQAuAAQKfxkAAxgACQkOIFENAA8DABgACQkOIFENAA8DABkAAwkyBiZIAJYAAAAA.',
['小黄']='小黄花:BAAALgAECgQJCAAAAA==.',
['就差']='就差一丢丢儿:BAABLgAFFH8FAAIHAAQJoAcxHQAtAQAHAAQJoAcxHQAtAQAAAA==.',
['山有']='山有沐兮:BAAALgAECgEJAQAAAA==.',
['岁岁']='岁岁奇诺:BAAALgAECgcJDgAAAA==.',
['工大']='工大油瓶:BAAALgAECgcJCQAAAA==.',
['左手']='左手:BAAALgAECgEJAQAAAA==.',
['巧笑']='巧笑嫣然:BAAALgAECgkJEgAAAA==.',
['帝国']='帝国之拳:BAAALgAECgEJAgAAAA==.',
['年轻']='年轻就学坏:BAAALgAECgEJAQAAAA==.',
['幸福']='幸福的阿萨:BAAALgAECgQJBAAAAA==.',
['弦卷']='弦卷心:BAAALgAECgQJBAAAAA==.',
['弯弓']='弯弓射小雕:BAAALgAFFAEJAgAAAA==.',
['影灯']='影灯:BAAALgAECgIJAgAAAA==.',
['御灵']='御灵神:BAAALgAECgYJBgAAAA==.',
['微风']='微风之羽:BAAALgAECgUJBwAAAA==.',
['德自']='德自然:BAAALgADCgEJAQAAAA==.',
['心若']='心若希:BAAALgAFFAIJAwAAAA==.',
['忧郁']='忧郁的蓝:BAAALgAECgYJCQAAAA==.',
['快乐']='快乐小战司:BAAALgAECgQJBgAAAA==.快乐小武僧:BAACLgAFFH8JAAIQAAMJQhIfEwDgAAAQAAMJQhIfEwDgAAAuAAQKfxwAAhAACAkVGcAVAFwCABAACAkVGcAVAFwCAAAA.',
['恋上']='恋上冰儿:BAAALgAECgEJAQAAAA==.',
['恐怖']='恐怖木木枭:BAABLgAFFH8FAAMCAAMJihzNGADFAAACAAIJ+x/NGADFAAASAAEJqRWFIQBdAAAAAA==.',
['恶魔']='恶魔的低语:BAAALgAFFAEJAQAAAA==.',
['我不']='我不卖火柴:BAAALgAECgYJCgAAAA==.',
['我叫']='我叫叨叨:BAAALgAECgQJBAAAAA==.我叫红小猪:BAAALgAECgQJBQAAAA==.',
['我是']='我是小坏蛋:BAAALgAECgcJBwAAAA==.',
['我爱']='我爱红小猪:BAAALgAECgcJBwAAAA==.',
['我这']='我这下很疼:BAAALgAECgEJAQAAAA==.',
['扶疏']='扶疏:BAAALgAECgkJDQAAAA==.',
['披萨']='披萨:BAAALgAFFAUJAwAAAA==.',
['拉个']='拉个糖嘛:BAAALgAECgQJCgAAAA==.',
['拉面']='拉面技师:BAAALgAECgEJAQAAAA==.',
['挺好']='挺好的故事:BAAALgAFFAQJBAAAAA==.',
['捏你']='捏你小脸蛋丶:BAAALgAECgcJBwAAAA==.',
['捞月']='捞月亮的人丶:BAAALgAECgEJAQAAAA==.',
['搞得']='搞得不丑:BAAALgAECgkJBgAAAA==.',
['摘星']='摘星:BAAALgAECgIJAwAAAA==.',
['摩耶']='摩耶火箭炮:BAAALgAECgQJBAAAAA==.',
['斤团']='斤团小王子:BAAALgAECgcJEwAAAA==.',
['斯诺']='斯诺白:BAAALgAECgEJAQAAAA==.',
['旁友']='旁友票子要伐:BAAALgAECggJDAAAAA==.旁友蛋刀要伐:BAAALgAECgYJAQAAAA==.',
['旖乄']='旖乄旎:BAAALgAFFAMJAwAAAA==.',
['无双']='无双讯影:BAAALgAECgEJAQAAAA==.',
['无情']='无情猪儿虫:BAAALgAFFAQJBAAAAA==.',
['无语']='无语倾心:BAAALgAFFAMJBAAAAA==.',
['无限']='无限月读:BAAALgAECgMJBAAAAA==.',
['既白']='既白:BAAALgADCgcJBwAAAA==.',
['星辰']='星辰天空:BAABLgAECn8XAAQaAAcJ2RUBIQC3AQAaAAcJwhIBIQC3AQAbAAYJdxU6HgCPAQAXAAYJzBQ/HgA8AQAAAA==.',
['星野']='星野梦美:BAAALgAECgQJBwAAAA==.',
['普拉']='普拉顿桑克斯:BAAALgAECgYJCQAAAA==.',
['暗影']='暗影之刃:BAAALgAECgUJBQAAAA==.',
['暮色']='暮色心情:BAAALgAECgcJDQAAAA==.',
['暴怒']='暴怒年糕:BAAALgAECgYJDgAAAA==.',
['最爱']='最爱灬芳芳:BAAALgAECgYJBwAAAA==.',
['月生']='月生宏十:BAAALgADCgEJAQAAAA==.',
['月若']='月若亦晨曦:BAAALgAFFAIJAwAAAA==.',
['有梦']='有梦想的熊:BAAALgAECgYJBgAAAA==.',
['木剑']='木剑温酒:BAAALgAECgEJAgABLgAECgYJBgAGAAAAAA==.',
['未央']='未央未至:BAAALgAECgEJAgAAAA==.',
['未成']='未成年包面:BAAALgAECgYJCgAAAA==.',
['朱轶']='朱轶晗:BAAALgAECgcJCgAAAA==.',
['来自']='来自内蒙古:BAABLgAFFH8GAAIcAAMJUx1XDgAgAQAcAAMJUx1XDgAgAQAAAA==.来自至高岭:BAAALgAFFAIJAgABLgAFFAMJBgAcAFMdAA==.',
['杨二']='杨二秦:BAAALgADCgEJAQAAAA==.',
['林黛']='林黛玉:BAAALgAECgQJBQAAAA==.',
['果酱']='果酱:BAAALgAFFAIJAwAAAA==.',
['枪掉']='枪掉:BAAALgADCgYJBgAAAA==.',
['枪法']='枪法也是法:BAAALgAECgQJBAAAAA==.',
['枫丨']='枫丨枫大宝贝:BAAALgAECgkJBgAAAA==.',
['某人']='某人:BAAALgAECgUJCgAAAA==.',
['柠檬']='柠檬汽泡水:BAAALgADCgYJBgAAAA==.',
['柳絮']='柳絮因风起:BAAALgAFFAIJBAAAAA==.',
['格拉']='格拉德丽尔:BAAALgADCgEJAQAAAA==.',
['桂花']='桂花糕也不错:BAABLgAECn8gAAIQAAgJ5hZYHAAgAgAQAAgJ5hZYHAAgAgAAAA==.',
['梓喵']='梓喵:BAAALgAECgIJAgAAAA==.',
['梦见']='梦见电子羊:BAAALgAECgUJBgAAAA==.',
['梦醒']='梦醒:BAAALgAECgcJBwAAAA==.',
['楼兰']='楼兰幽梦:BAAALgAECgEJAwAAAA==.',
['樱月']='樱月枫:BAAALgAECgEJAgAAAA==.',
['橘栀']='橘栀语:BAAALgADCgEJAQAAAA==.',
['橘瑪']='橘瑪麗:BAAALgAFFAIJBAAAAA==.',
['橙心']='橙心橙意:BAABLgAFFH8LAAIJAAYJABtdAgDCAQAJAAYJABtdAgDCAQAAAA==.',
['橙香']='橙香一季:BAAALgAFFAQJBAAAAA==.橙香三季:BAABLgAFFH8FAAIJAAQJKRvfBACCAQAJAAQJKRvfBACCAQAAAA==.橙香二季:BAABLgAFFH8FAAIJAAUJchb7AgCtAQAJAAUJchb7AgCtAQAAAA==.',
['橴嫣']='橴嫣然:BAAALgAECgYJBwAAAA==.',
['櫻島']='櫻島麻衣:BAAALgAECggJBwAAAA==.',
['欧皇']='欧皇一号:BAAALgAECgQJBgAAAA==.',
['正在']='正在摸鱼丶:BAAALgADCgEJAQAAAA==.正在读条:BAAALgADCgMJAwAAAA==.',
['此刻']='此刻寂灭之时:BAAALgAECgMJAwAAAA==.',
['武道']='武道秒:BAAALgADCgYJBgAAAA==.',
['死骑']='死骑卉卉:BAABLgAECn8XAAIHAAYJahy1XwDUAQAHAAYJahy1XwDUAQAAAA==.',
['气哭']='气哭小九梨:BAAALgAECgEJAQAAAA==.',
['水嫩']='水嫩小黄瓜丶:BAAALgAECgQJBQAAAA==.',
['水晶']='水晶玫瑰:BAAALgAECgUJDAAAAA==.',
['水清']='水清墨韵:BAAALgAECgQJBAAAAA==.',
['永恒']='永恒国度:BAAALgAECgQJBAAAAA==.',
['汉诺']='汉诺崇高力量:BAAALgAECgcJDAAAAA==.',
['汪汪']='汪汪睡冰冰:BAAALgAECgUJBQAAAA==.',
['沐雲']='沐雲:BAACLgAFFH8KAAIKAAQJ+hsmBwBoAQAKAAQJ+hsmBwBoAQAuAAQKfxYAAgoABwl7IbISAI0CAAoABwl7IbISAI0CAAAA.',
['没有']='没有如果:BAAALgAFFAIJAgAAAA==.',
['沧海']='沧海一沐:BAAALgAECgUJBgAAAA==.',
['泡芙']='泡芙:BAAALgAECgUJBQAAAA==.',
['泰来']='泰来尔:BAAALgAECgYJCQAAAA==.',
['洛神']='洛神賦:BAABLgAFFH8IAAMSAAQJ5SBMAQCUAQASAAQJ3CBMAQCUAQACAAQJhhAAAAAAAAAAAA==.',
['流年']='流年丶筑心:BAABLgAFFH8IAAITAAMJtyGxEQBCAQATAAMJtyGxEQBCAQAAAA==.',
['流浪']='流浪的白雲:BAAALgAFFAEJAQAAAA==.',
['浅苍']='浅苍花喃:BAAALgAECgUJBQAAAA==.',
['浓情']='浓情茶:BAAALgAECgYJCQAAAA==.',
['浮生']='浮生任白头:BAAALgAECgMJAwAAAA==.',
['海德']='海德薇麗:BAAALgAECgMJBAABLgAECgEJAQAGAAAAAA==.',
['海飏']='海飏:BAACLgAFFH8HAAMIAAIJbgZPCQCWAAAIAAIJbgZPCQCWAAAPAAIJugjTHQCFAAAuAAQKfyAABA8ACAkXHLodAFACAA8ABwm0HLodAFACAAgABgkgD6Q5AFABAB0AAgkqBv4tAD4AAAAA.',
['涨停']='涨停板:BAAALgAFFAIJBAAAAA==.',
['清风']='清风许愿:BAAALgAECgcJBwAAAA==.',
['渴望']='渴望长大:BAAALgAECgIJAgAAAA==.',
['漂亮']='漂亮的猫猫:BAAALgADCgEJAQAAAA==.',
['火点']='火点墩墩:BAAALgAECgYJBgAAAA==.',
['灬旖']='灬旖旎灬:BAAALgAECgEJAQAAAA==.',
['灬火']='灬火烧火燎灬:BAAALgAECgIJAgABLgAECgUJBgAGAAAAAA==.',
['灬花']='灬花花灬:BAAALgAECgUJCAAAAA==.',
['灬蓝']='灬蓝灬天灬:BAACLgAFFH8JAAIDAAMJ2hXrEwAIAQADAAMJ2hXrEwAIAQAuAAQKfyQAAgMACQnSG+oLAC8DAAMACQnSG+oLAC8DAAAA.',
['灵紫']='灵紫凝:BAAALgAECgYJCgAAAA==.',
['烈焰']='烈焰阿锐:BAABLgAECn8WAAIeAAgJeBj9AQBVAgAeAAgJeBj9AQBVAgAAAA==.',
['烟灰']='烟灰悲雀:BAAALgAECgIJAgAAAA==.',
['焦糖']='焦糖布丁:BAAALgAECgUJBQAAAA==.',
['燃烧']='燃烧的星河:BAAALgAECgEJAQAAAA==.',
['爱上']='爱上我怕不怕:BAAALgAECgYJDAAAAA==.',
['爱如']='爱如指间沙:BAAALgAECgQJBAAAAA==.',
['爱瑟']='爱瑟瑞尔:BAAALgAECgIJAgABLgAECgUJCQAGAAAAAA==.',
['爱神']='爱神降临:BAAALgAECgYJCQAAAA==.',
['爷爱']='爷爱吃肉:BAAALgADCgIJAgAAAA==.',
['牛肉']='牛肉饼:BAAALgAFFAUJAQAAAA==.',
['特基']='特基拉日出:BAAALgAECgcJDAAAAA==.',
['狂想']='狂想闪影:BAACLgAFFH8IAAITAAMJ6hyJFgAdAQATAAMJ6hyJFgAdAQAuAAQKfxQAAhMABglYJNwoAF8CABMABglYJNwoAF8CAAAA.',
['狂暴']='狂暴化身:BAAALgAECgMJAwAAAA==.狂暴的高个子:BAAALgAECgQJBAAAAA==.',
['狐一']='狐一刀:BAAALgAFFAEJAQAAAA==.',
['狗腿']='狗腿柴的主人:BAACLgAFFH8FAAMPAAMJwSIvFQC7AAAPAAIJ8iAvFQC7AAAIAAIJNBWBEwCnAAAuAAQKfyEABA8ACAkfJCACAKkCAA8ABwn5JSACAKkCAAgABgkJIkEbACkCAB0AAgloDLApAFQAAAAA.',
['狼咩']='狼咩:BAAALgAECgcJBwAAAA==.',
['猫口']='猫口喵乐:BAAALgAECgIJBQAAAA==.',
['瓦利']='瓦利耶娃:BAAALgAECgQJBwAAAA==.',
['画绝']='画绝:BAAALgAECgEJAQAAAA==.',
['留恋']='留恋小时候:BAAALgAECgMJAwAAAA==.',
['番茄']='番茄卫士:BAAALgAECgcJDQAAAA==.',
['疯子']='疯子:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂蛋丁:BAAALgAFFAIJAgAAAA==.',
['發條']='發條雪饼:BAAALgAECgQJBQAAAA==.',
['白马']='白马醉春风:BAACLgAFFH8IAAISAAMJARrKBwAnAQASAAMJARrKBwAnAQAuAAQKfxQAAhIABwm7ICcbAGQCABIABwm7ICcbAGQCAAAA.',
['百永']='百永莎里奈:BAAALgAECgQJCgAAAA==.',
['真蓝']='真蓝色:BAABLgAECn8gAAMfAAgJdx7oAQDuAQAKAAgJJRwIFAB/AgAfAAcJtBroAQDuAQAAAA==.',
['瞳丿']='瞳丿哀霜:BAABLgAFFH8HAAIgAAMJ0hWMBwD+AAAgAAMJ0hWMBwD+AAABLgAFFAUJCwAHAAEaAA==.',
['矮僧']='矮僧先森:BAAALgAFFAIJAwAAAA==.',
['石头']='石头伯伯:BAAALgAECgYJCQAAAA==.',
['碎碎']='碎碎念:BAAALgADCgMJAwAAAA==.',
['祝福']='祝福:BAAALgAFFAIJAgAAAA==.',
['神偷']='神偷:BAAALgAECgQJCAAAAA==.',
['神圣']='神圣的玛小丽:BAAALgAECgEJAQAAAA==.',
['神殇']='神殇冷月:BAAALgAECgUJCwAAAA==.',
['秃头']='秃头披风:BAAALgAECgEJAQAAAA==.',
['秋旻']='秋旻:BAAALgAECgEJAQAAAA==.',
['科技']='科技与狠活:BAAALgAECgYJBgAAAA==.',
['空谷']='空谷幽幽人:BAAALgAFFAEJAQAAAA==.',
['笑一']='笑一块:BAAALgADCgEJAQABLgAFFAYJEAATAJkaAA==.',
['笑丨']='笑丨笑爱吃菜:BAAALgAECgcJBwAAAA==.',
['笑靥']='笑靥少年狂:BAAALgADCgIJAgAAAA==.',
['筱红']='筱红龙:BAABLgAECn8ZAAMaAAgJ4BHUBgCHAQAaAAgJ4BHUBgCHAQAbAAQJ1hUhKwAZAQAAAA==.',
['管君']='管君的帕拉丁:BAAALgAECgIJAwAAAA==.',
['米小']='米小灵:BAAALgAECgkJBAAAAA==.',
['米饭']='米饭杀手:BAAALgADCgUJBQAAAA==.',
['粉色']='粉色大锤术:BAAALgAECgYJCAAAAA==.',
['糾结']='糾结依然:BAAALgADCgUJBQAAAA==.',
['素入']='素入:BAAALgAECgIJAgAAAA==.',
['紫灵']='紫灵韵:BAAALgAECgUJCQAAAA==.',
['紫荆']='紫荆泽蓝:BAAALgAECgEJAQAAAA==.',
['終丶']='終丶:BAAALgAECgQJBQAAAA==.',
['終末']='終末丶序章:BAAALgAECgMJAwAAAA==.',
['繁星']='繁星儿:BAAALgAECgMJAwAAAA==.',
['红糖']='红糖排骨:BAAALgAECgQJBAAAAA==.',
['红袖']='红袖:BAAALgAECgYJDgAAAA==.红袖夜添香:BAAALgAECgYJCQABLgAECgkJDQAGAAAAAA==.',
['纸防']='纸防骑丶:BAABLgAFFH8FAAIDAAMJpiFqHwCwAAADAAMJpiFqHwCwAAAAAA==.',
['纹身']='纹身大领主:BAAALgAECgEJAgAAAA==.',
['练为']='练为战:BAAALgAECgEJAgAAAA==.',
['给你']='给你肾来一击:BAAALgAECgEJAQAAAA==.',
['给我']='给我刀:BAAALgADCgUJBQAAAA==.给我刃:BAAALgAECgIJAwAAAA==.',
['绿豆']='绿豆汤灬:BAAALgAFFAIJAwAAAA==.',
['缥缈']='缥缈小妖:BAAALgAECgQJBQAAAA==.',
['罒十']='罒十罒:BAAALgAECgIJAgAAAA==.',
['罗小']='罗小黑:BAAALgAECgUJBQAAAA==.',
['罪叶']='罪叶林拳王:BAAALgAECgcJBwAAAA==.',
['羅將']='羅將神灬水姬:BAAALgAECgkJBgABLgAECgEJAQAGAAAAAA==.羅將神聖姬:BAAALgAECgEJAQAAAA==.',
['羽翼']='羽翼丶:BAAALgAECgUJCAAAAA==.',
['老哥']='老哥:BAAALgAECgEJAQAAAA==.',
['考拉']='考拉丶:BAABLgAFFH8IAAIPAAMJxxg1GwCQAAAPAAMJxxg1GwCQAAAAAA==.',
['肆条']='肆条:BAAALgAECgMJAwAAAA==.',
['肆雨']='肆雨:BAAALgAECgQJBQAAAA==.',
['腱鞘']='腱鞘炎贼:BAAALgAECgYJCwAAAA==.',
['臥笑']='臥笑醉伊人:BAAALgAFFAQJBAAAAA==.',
['舍甫']='舍甫琴科丶:BAAALgAECgQJBAAAAA==.',
['芙柔']='芙柔桑克斯:BAAALgAFFAIJAgABLgAFFAUJDgAPACcYAA==.',
['芙莉']='芙莉蓮:BAAALgAECgYJDAAAAA==.',
['花冈']='花冈雫:BAAALgAECgMJAwAAAA==.',
['花前']='花前月下:BAAALgAECgIJBAAAAA==.',
['花开']='花开夏茉:BAAALgAFFAEJAQAAAA==.',
['花龙']='花龙点精:BAAALgADCgEJAQAAAA==.',
['苇名']='苇名一心:BAAALgAECgEJAQAAAA==.',
['苏丶']='苏丶海伦:BAAALgAECgQJBwAAAA==.',
['苟冬']='苟冬溪:BAAALgAECgEJAgAAAA==.',
['苦练']='苦练杀敌本领:BAAALgAECgYJBwAAAA==.',
['草莓']='草莓奈奈:BAAALgAECgEJAQAAAA==.',
['莫念']='莫念无言:BAAALgAFFAEJAQAAAA==.',
['莳萝']='莳萝葉蓂:BAACLgAFFH8MAAIPAAQJYRRrCQA+AQAPAAQJYRRrCQA+AQAuAAQKfyMAAg8ACQl1HGoNANECAA8ACQl1HGoNANECAAAA.',
['菈妮']='菈妮:BAAALgAFFAIJAwABLgAFFAUJDgAPACcYAA==.菈妮的布莱泽:BAACLgAFFH8PAAMHAAUJ/h15AgCJAQAHAAQJ/h15AgCJAQANAAEJAAAAAAAAAAAuAAQKfxYAAgcACAksITslAKgCAAcACAksITslAKgCAAAA.',
['萝莉']='萝莉开膛手:BAAALgAECgEJAQAAAA==.',
['萨儿']='萨儿:BAAALgAECgYJBgAAAA==.',
['葛林']='葛林姆尼尔:BAAALgADCggJCAAAAA==.',
['蒼老']='蒼老湿:BAAALgAFFAEJAQABLgAFFAIJBAAGAAAAAA==.',
['蕾咪']='蕾咪莉亜:BAAALgADCgcJBwAAAA==.',
['蕾西']='蕾西恩:BAABLgAECn8iAAIDAAgJ7h3SCAD9AQADAAgJ7h3SCAD9AQAAAA==.',
['虎王']='虎王猎:BAAALgAECgYJBgAAAA==.',
['虎皮']='虎皮貓:BAAALgAECgQJBwAAAA==.',
['虚空']='虚空大姐姐:BAABLgAECn8dAAMYAAgJCRlfEgB9AQAYAAUJfBpfEgB9AQAZAAUJcBRwIABPAQAAAA==.',
['蜗牛']='蜗牛骑士:BAAALgADCgQJBAAAAA==.',
['蝉鸣']='蝉鸣晴空:BAAALgAECgQJBAAAAA==.',
['行成']='行成于思:BAAALgAECgQJBQAAAA==.',
['袜底']='袜底酥:BAAALgAECgEJAQAAAA==.',
['裂手']='裂手:BAAALgADCgEJAQAAAA==.',
['裘力']='裘力斯凯撒:BAAALgAFFAEJAQAAAA==.',
['许爱']='许爱刘群华:BAAALgAECgYJDQAAAA==.',
['诶哟']='诶哟:BAAALgAECgMJAgAAAA==.',
['请输']='请输入文本:BAAALgAECgEJAQABLgAECggJIQAHAI8kAA==.',
['诺克']='诺克塔:BAAALgAECgkJCQABLgAECgkJFwABAMAcAA==.',
['诺弥']='诺弥安:BAAALgAECgYJBwAAAA==.',
['贪婪']='贪婪先锋:BAAALgAECgUJCAAAAA==.',
['贫困']='贫困形象大使:BAAALgAFFAIJAwAAAA==.',
['贰拾']='贰拾玖:BAAALgAECgcJCgAAAA==.',
['赤丨']='赤丨风:BAAALgAECgEJAQAAAA==.',
['赫萝']='赫萝克:BAAALgAECgQJBAAAAA==.',
['起点']='起点点:BAAALgAECgUJCAAAAA==.',
['超级']='超级猪儿虫:BAABLgAFFH8NAAMYAAQJJSKICgCIAQAYAAQJJSKICgCIAQAhAAEJ3B5pAwBfAAAAAA==.',
['路人']='路人骑:BAAALgAECgQJBQAAAA==.',
['踏碎']='踏碎星河:BAAALgADCgEJAQAAAA==.',
['轩辕']='轩辕麒麒:BAAALgADCgEJAQAAAA==.',
['转圈']='转圈小彩旗:BAAALgADCgIJAgAAAA==.',
['轰轰']='轰轰火花:BAAALgAFFAEJAQAAAA==.',
['辛巴']='辛巴小蹄子:BAAALgAECgcJDQAAAA==.',
['达盖']='达盖尔:BAAALgADCgYJBgAAAA==.',
['还回']='还回家吃饭吗:BAAALgAECgQJCAAAAA==.还回来吃饭吗:BAAALgADCgYJBgAAAA==.',
['这个']='这个层数奔放:BAAALgAECgYJEwAAAA==.',
['迷茫']='迷茫羽翼:BAAALgAECgEJAQAAAA==.',
['遗失']='遗失的青春:BAAALgAECgYJBwAAAA==.',
['那颜']='那颜:BAAALgAECgkJCwAAAA==.',
['邦侬']='邦侬博特勒:BAAALgAECgIJAwAAAA==.',
['邪恶']='邪恶大叔盖奇:BAAALgADCgUJBQAAAA==.',
['邪能']='邪能拿铁:BAAALgAECgEJAQAAAA==.',
['郑飞']='郑飞机:BAAALgAECgkJEAAAAA==.',
['采白']='采白:BAAALgADCgYJBgABLgAFFAQJBQAdAGsRAA==.',
['野区']='野区毒瘤敌法:BAAALgAFFAIJAwABLgAFFAMJBQADAKYhAA==.',
['错哥']='错哥我又登了:BAAALgAECgQJBAAAAA==.',
['闪一']='闪一号:BAABLgAFFH8NAAIJAAUJLBsyAgDIAQAJAAUJLBsyAgDIAQAAAA==.',
['闪三']='闪三号:BAABLgAFFH8FAAIJAAMJuSJnCgAvAQAJAAMJuCJnCgAvAQAAAA==.',
['闪五']='闪五号:BAABLgAFFH8JAAIJAAUJHhr8AAC6AQAJAAUJHhr8AAC6AQAAAA==.',
['闪四']='闪四号:BAABLgAFFH8OAAIJAAUJFx/SAQDaAQAJAAUJFx/SAQDaAQAAAA==.',
['闻雨']='闻雨听风起:BAAALgAECgQJBQAAAA==.',
['阑珊']='阑珊夜色:BAAALgAECgYJBwAAAA==.',
['阿亚']='阿亚拉:BAAALgAECgQJBQAAAA==.',
['阿卡']='阿卡尔:BAAALgAECgYJBQAAAA==.',
['阿杜']='阿杜不胖:BAABLgAECn8XAAIHAAgJ5SDzGQDhAgAHAAgJ5SDzGQDhAgAAAA==.',
['阿琉']='阿琉克斯:BAAALgAECgEJAQAAAA==.',
['阿鲁']='阿鲁高太爷爷:BAAALgAECgUJCAAAAA==.',
['陈老']='陈老师:BAAALgAECgEJAgAAAA==.',
['隋棠']='隋棠:BAAALgAECgEJAQAAAA==.',
['雪域']='雪域咸奶茶:BAAALgAECgYJBgAAAA==.',
['雷电']='雷电影:BAAALgAECgYJBgAAAA==.',
['霞之']='霞之丘詩羽:BAAALgAECgYJCgAAAA==.',
['露露']='露露:BAAALgAECgIJAgAAAA==.',
['青翎']='青翎丶:BAAALgAECgcJCAAAAA==.',
['青龙']='青龙山刀匠:BAEALgAECgcJDAABLgAFFAQJCgAQAKYXAA==.',
['风暴']='风暴之泠:BAAALgAECgcJDgAAAA==.风暴烈酒丶锋:BAAALgAECgQJBQAAAA==.',
['风起']='风起兮:BAAALgAECgQJDAAAAA==.',
['风采']='风采富贵:BAAALgAECgEJAQAAAA==.',
['马上']='马上吃猪肉:BAAALgAFFAQJBAAAAA==.马上吃鱼肉:BAAALgAFFAUJAwAAAA==.马上吃鸡肉:BAABLgAFFH8HAAIJAAUJSRp4AgC+AQAJAAUJSRp4AgC+AQAAAA==.马上吃鸭肉:BAAALgAFFAIJAQAAAA==.',
['马萨']='马萨鸡:BAAALgADCgEJAQAAAA==.',
['骸山']='骸山生蝇:BAAALgAECgUJBwAAAA==.',
['高垣']='高垣枫:BAAALgAECgYJCQAAAA==.',
['魔女']='魔女若叶睦:BAABLgAECn8YAAMPAAgJyhPMPwCjAQAPAAcJLRXMPwCjAQAIAAEJ2wF3iwAjAAAAAA==.',
['鯊魚']='鯊魚辣椒:BAAALgAFFAEJAgAAAA==.',
['鹘翎']='鹘翎:BAAALgAECgYJEAABLgAFFAEJAQAGAAAAAA==.',
['麟珈']='麟珈:BAAALgAECgMJAwABLgAECgYJCwAGAAAAAA==.',
['麻辣']='麻辣小面:BAAALgADCgUJBQAAAA==.',
['黄子']='黄子弘凡:BAAALgAECgQJBgAAAA==.',
['黄瓜']='黄瓜超强力灬:BAABLgAECn8VAAMYAAgJvhHYTADiAQAYAAgJvhHYTADiAQAZAAEJOQCIgQAFAAAAAA==.',
['黑柯']='黑柯基:BAAALgAECgQJBgAAAA==.',
['黑殇']='黑殇:BAAALgAECgYJDQAAAA==.',
['黑涩']='黑涩翅膀:BAAALgAECgcJEwAAAA==.',
['黑色']='黑色四叶草:BAAALgADCgYJBgABLgAECgUJBgAGAAAAAA==.',
['黑骑']='黑骑仕:BAAALgAECgEJAgAAAA==.',
['黑魔']='黑魔术师:BAABLgAFFH8TAAIZAAUJZRwhAQDrAQAZAAUJZRwhAQDrAQAAAA==.',
['黑黑']='黑黑的七夜:BAAALgAECgYJBgAAAA==.',
['黑龙']='黑龙如意:BAAALgADCgYJCwAAAA==.',
['龍伶']='龍伶丶:BAAALgAECgEJAQAAAA==.',
['龍回']='龍回:BAAALgAFFAEJAQAAAA==.',
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
