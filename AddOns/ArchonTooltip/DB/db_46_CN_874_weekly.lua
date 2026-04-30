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

local lookup = {'DemonHunter-Devourer','Warrior-Fury','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver','Druid-Balance','Mage-Frost','Hunter-BeastMastery','Monk-Brewmaster','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Blood','Priest-Holy','Priest-Shadow','Priest-Discipline','Unknown-Unknown','Rogue-Outlaw','Evoker-Preservation','Druid-Guardian','Warrior-Protection','Warrior-Arms','Evoker-Augmentation','Druid-Restoration','DemonHunter-Havoc','Rogue-Subtlety','Shaman-Elemental','Shaman-Restoration','Rogue-Assassination','Paladin-Protection','Hunter-Marksmanship','Shaman-Enhancement','Hunter-Survival','Warlock-Affliction','DemonHunter-Vengeance',}
local provider = {region='CN',realm='雷克萨',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akmu:BAABLgAECn8YAAIBAAgJMhPJFAB/AQABAAgJMhPJFAB/AQAAAA==.',
Al='Alucarde:BAAALgAFFAIJBAAAAA==.',
An='Angelo:BAAALgAECgIJAgAAAA==.',
Ba='Badgril:BAAALgADCgIJAgAAAA==.',
Be='Bearball:BAAALgADCgcJBwAAAA==.',
Bt='Btm:BAABLgAFFH8IAAICAAQJ6RuQAQB7AQACAAQJ6RuQAQB7AQAAAA==.',
Bu='Bufface:BAACLgAFFH8OAAMDAAYJ7hv8AQAaAgADAAYJ7hv8AQAaAgAEAAEJLwPuGQBIAAAuAAQKfxsAAwQACAnCIJwFAHsCAAQABwndH5wFAHsCAAMABwkAHLxBAAgCAAAA.Buffret:BAACLgAFFH8TAAIFAAUJoCTyAQD0AQAFAAUJoCTyAQD0AQAuAAQKfycAAgUACQnHJYoEAIQDAAUACQnHJYoEAIQDAAAA.',
Ca='Capricornus:BAAALgAECgYJBgAAAA==.Catandpig:BAACLgAFFH8FAAMGAAUJpBU2BAD+AAAGAAMJfhU2BAD+AAAHAAIJZBLvFABWAAAuAAQKfxUAAwcABgnPIIQUACUCAAcABgnPIIQUACUCAAYABAkHI8UnAJsBAAAA.',
Cc='Ccb:BAAALgADCgYJBgAAAA==.',
Ch='Chaostorm:BAAALgAECgQJCAABLgAFFAYJFAAIALAdAA==.',
Co='Cosmos:BAAALgAECgcJBwAAAA==.',
Cr='Crseven:BAAALgAECgMJAwAAAA==.',
De='Dempsey:BAACLgAFFH8HAAIJAAMJ3AlAGgDxAAAJAAMJ3AlAGgDxAAAuAAQKfxQAAgkACAmDHK4wALACAAkACAmDHK4wALACAAAA.Despite:BAAALgAECgQJCQAAAA==.',
Dz='Dzotl:BAAALgAECgMJAwAAAA==.',
Ep='Epimetreus:BAAALgAECgEJAQAAAA==.',
Ev='Evea:BAAALgADCgEJAQAAAA==.Evoless:BAAALgAECgUJBwAAAA==.',
Fa='Fabiola:BAAALgAFFAEJAQAAAA==.',
Gd='Gd:BAAALgAECgEJAQAAAA==.',
Go='Goye:BAAALgADCgQJBAAAAA==.',
Gy='Gyrozeppeli:BAABLgAFFH8MAAMDAAYJaiN0AAB1AgADAAYJZiN0AAB1AgAEAAEJBR4OEQBeAAAAAA==.',
Gz='Gz:BAAALgAECgQJBAAAAA==.',
He='Hex:BAAALgAECgUJBQABLgAFFAMJBwAKAF0lAA==.',
Hu='Huggingface:BAABLgAFFH8IAAMLAAUJ1wyaFADSAAALAAUJ1wyaFADSAAAHAAIJHyI4CgCaAAAAAA==.',
Hy='Hypnos:BAAALgAFFAIJAwAAAA==.',
In='Inory:BAACLgAFFH8PAAIDAAYJBRWqAgADAgADAAYJBRWqAgADAgAuAAQKfy4AAwMACQnSIycBAPICAAMACQnSIycBAPICAAQABglSHZ8MAPkBAAAA.',
Ju='Jussey:BAAALgAECgQJBAAAAA==.',
Kc='Kcheetaah:BAACLgAFFH8TAAIMAAUJQSOBAQD6AQAMAAUJQSOBAQD6AQAuAAQKfzEAAwUACQm/HNYOABcDAAUACQm/HNYOABcDAAwACQkXJEAGAAcDAAAA.',
Ki='Kitchen:BAAALgADCgEJAQAAAA==.',
Ko='Koldira:BAACLgAFFH8QAAMNAAUJqCV9BgCeAQANAAQJqCV9BgCeAQAOAAEJAADMFgA/AAAuAAQKfx8AAg0ACAk8JSYKAEoDAA0ACAk8JSYKAEoDAAAA.',
La='Labseries:BAAALgADCgIJAgAAAA==.Lazyfish:BAAALgAECgMJAgAAAA==.',
Li='Lipper:BAACLgAFFH8QAAMPAAUJDBN/AQBuAQAPAAUJDBN/AQBuAQAQAAQJtgtSCABCAQAuAAQKfx8ABBAACAmSHsAQAHsCABAABwllIsAQAHsCAA8ABQniHRAyAHgBABEAAQkZDARUADkAAAAA.',
Ma='Malrine:BAAALgAECgUJBwABLgAFFAEJAQASAAAAAA==.Max:BAAALgAECgcJBwAAAA==.',
Mi='Minday:BAAALgAECgQJAgAAAA==.',
Mn='Mnoer:BAAALgAECgYJBgAAAA==.',
Mo='Modeus:BAAALgAECgEJAQABLgAFFAMJBwAKAF0lAA==.',
Na='Napolen:BAAALgADCgYJBgAAAA==.',
No='Nothingshu:BAAALgAECgIJAwAAAA==.Nothingwy:BAAALgADCgEJAQABLgAECgIJAwASAAAAAA==.',
Om='Omomo:BAAALgAECgIJAwAAAA==.',
Pi='Pinyin:BAABLgAECn8cAAMPAAgJ5BnLGgAGAgAPAAgJyBXLGgAGAgARAAcJlhVVFQD9AQAAAA==.',
Pl='Playerlkdsys:BAAALgAECgYJBgAAAA==.Playerykghli:BAAALgADCgIJAgAAAA==.',
Po='Polynesia:BAAALgAECgcJEQABLgAFFAUJBQARADwhAA==.',
Re='Reton:BAAALgADCgYJBgAAAA==.',
Sa='Sarala:BAAALgAECgEJAQAAAA==.',
Sc='Scav:BAACLgAFFH8OAAIJAAUJ1CQ0EQCMAQAJAAUJ1CQ0EQCMAQAuAAQKfyUAAgkACQk/JqkEALYDAAkACQk/JqkEALYDAAAA.',
Sh='Shengguang:BAAALgAFFAEJAQAAAA==.Shllee:BAAALgADCgkJEAAAAA==.',
Sm='Smolder:BAAALgAECgYJBgAAAA==.',
Su='Superlw:BAAALgAECgEJAgAAAA==.',
Ti='Tinysuperman:BAAALgAECgIJAgAAAA==.',
Un='Uncrowns:BAACLgAFFH8KAAITAAQJxhCaAABbAQATAAQJxhCaAABbAQAuAAQKfx8AAhMACAndGd0BAJ4CABMACAndGd0BAJ4CAAAA.Undyne:BAACLgAFFH8KAAIUAAYJnxMRAgALAgAUAAYJnxMRAgALAgAuAAQKfxUAAhQACAn9FYESABgCABQACAn9FYESABgCAAAA.',
Xt='Xtruedamage:BAAALgAECgYJBgAAAA==.',
Zb='Zbybr:BAAALgAFFAQJBAAAAA==.Zbybrdruid:BAABLgAFFH8GAAIVAAYJexShAADVAQAVAAYJexShAADVAQAAAA==.Zbybrwarrior:BAABLgAFFH8SAAIWAAcJJB6SAABMAgAWAAcJJB6SAABMAgAAAA==.',
Zd='Zdrada:BAAALgAECgUJBQABLgAFFAMJBwAKAF0lAA==.',
['一块']='一块豆腐:BAAALgAECgEJAQAAAA==.',
['一梦']='一梦繁星:BAAALgAECgQJBgAAAA==.',
['一锤']='一锤儿丢死:BAAALgADCgcJCAAAAA==.一锤子砸死:BAAALgAECgQJCQAAAA==.',
['一闪']='一闪:BAAALgAECgcJEgAAAA==.',
['三十']='三十七度:BAAALgAECgEJAQAAAA==.三十七度六:BAAALgADCgEJAQAAAA==.',
['不可']='不可言:BAAALgAECgQJBAAAAA==.',
['不听']='不听话小孩:BAAALgAECgYJDgAAAA==.',
['不是']='不是酒鬼:BAACLgAFFH8SAAMXAAUJISJ9AAD0AQAXAAUJISJ9AAD0AQACAAIJGRDYGAClAAAuAAQKfxUAAxcACAnNI38CAPsCABcACAm1IH8CAPsCAAIABgkNI5coABoCAAAA.',
['不穷']='不穷锋:BAACLgAFFH8SAAMXAAYJnhNoAAAEAgAXAAYJnhNoAAAEAgACAAMJ7gWgEwDjAAAuAAQKfxkAAwIACAn/HGMnACECAAIABgkVIGMnACECABcABQnCF20IABMBAAAA.',
['丛林']='丛林:BAAALgAECgYJCgAAAA==.',
['东风']='东风柒号:BAAALgAECgQJBQAAAA==.',
['丧叉']='丧叉:BAAALgAECgQJBAABLgAFFAQJCgALAGMRAA==.',
['丨胖']='丨胖虎丨:BAAALgAECgEJAQAAAA==.',
['丨黑']='丨黑丶黑黑刺:BAAALgAECgQJBQAAAA==.',
['串爆']='串爆:BAAALgAFFAIJBAAAAA==.',
['丶善']='丶善逸:BAABLgAECn8VAAIJAAcJkiSiLgC3AgAJAAcJkiSiLgC3AgAAAA==.',
['为爱']='为爱而战斗:BAAALgAECgQJBAAAAA==.为爱而自醉:BAAALgAECgMJAwAAAA==.为爱而詭異:BAAALgAECgMJAwAAAA==.',
['丿弑']='丿弑念灬潇潇:BAAALgAECgEJAQAAAA==.',
['丿灬']='丿灬冷冷:BAAALgAFFAIJAgAAAA==.',
['乀丶']='乀丶辣辣:BAACLgAFFH8LAAIJAAYJ5xZfBQAQAgAJAAYJ5xZfBQAQAgAuAAQKfxsAAgkACAmgHTMxAK0CAAkACAmgHTMxAK0CAAAA.',
['乌龙']='乌龙拿铁:BAAALgAFFAUJAgAAAA==.',
['乐可']='乐可事百:BAAALgAECgMJAwAAAA==.',
['九成']='九成八:BAAALgAECgEJAQAAAA==.',
['了不']='了不起的香香:BAAALgAECgcJEAAAAA==.',
['二觭']='二觭丶露西:BAAALgADCgIJAwAAAA==.',
['云深']='云深成雨:BAAALgAFFAIJAgAAAA==.',
['五五']='五五二十五:BAAALgAECgEJAQAAAA==.',
['井岛']='井岛叫唤:BAAALgAECgQJBAAAAA==.',
['人生']='人生海海:BAAALgAECgEJAgAAAA==.',
['人鱼']='人鱼骑士:BAAALgADCgEJAQAAAA==.',
['今晚']='今晚执返剂:BAAALgAECgMJAwAAAA==.',
['伊莉']='伊莉娜尔:BAAALgAECgkJCQAAAA==.',
['伍六']='伍六柒:BAAALgADCgYJBwAAAA==.',
['何华']='何华少:BAAALgADCgYJBgAAAA==.',
['佩大']='佩大师:BAAALgAECgEJBAAAAA==.',
['修羅']='修羅丶月刃:BAAALgAECgYJCQAAAA==.',
['偶逆']='偶逆酱:BAAALgAECgYJDwABLgAECgcJFQAYAOQPAA==.',
['傲雪']='傲雪:BAAALgAECgUJBQAAAA==.',
['光铸']='光铸小骑士:BAAALgADCgUJBQAAAA==.',
['克罗']='克罗多斯:BAAALgAFFAEJAQAAAA==.',
['克莉']='克莉雅:BAAALgAECgMJBgAAAA==.',
['入侵']='入侵脑细胞:BAAALgAECgcJEgABLgAECgcJCwASAAAAAA==.',
['八分']='八分咲咲:BAABLgAFFH8SAAIIAAUJFiCNAgDZAQAIAAUJFiCNAgDZAQAAAA==.',
['八奈']='八奈见杏菜:BAAALgAFFAEJAQAAAA==.',
['兮乐']='兮乐:BAAALgAFFAEJAQAAAA==.',
['养魚']='养魚:BAAALgAECgYJBgAAAA==.',
['再生']='再生:BAACLgAFFH8JAAIZAAQJOBQ6CQBAAQAZAAQJOBQ6CQBAAQAuAAQKfxQAAhkACAmqFzArAAQCABkACAmqFzArAAQCAAAA.',
['军之']='军之守卫者:BAAALgAECgEJAQAAAA==.',
['农妹']='农妹:BAAALgADCgYJBwAAAA==.',
['农小']='农小妹:BAAALgAECgYJCQAAAA==.',
['农村']='农村小妹:BAAALgAECgQJBwAAAA==.',
['冥噬']='冥噬:BAAALgAECgcJBwAAAA==.',
['冬瓜']='冬瓜头:BAAALgADCgYJBgAAAA==.',
['冬语']='冬语:BAAALgAFFAEJAQAAAA==.',
['冰冻']='冰冻奶茶:BAAALgAECgEJAQAAAA==.',
['冰封']='冰封晨忆:BAAALgAFFAQJBAAAAA==.',
['冰羽']='冰羽冷血:BAAALgAECgEJBAAAAA==.冰羽怒风:BAAALgADCgQJBAAAAA==.',
['冰镇']='冰镇西瓜:BAAALgADCgcJBwAAAA==.',
['决撒']='决撒客人:BAAALgADCgEJAQAAAA==.',
['凌夜']='凌夜夜:BAAALgADCgIJAgAAAA==.',
['凌朝']='凌朝朝:BAABLgAECn8eAAIGAAcJniAZDwCMAgAGAAcJniAZDwCMAgAAAA==.',
['出门']='出门右拐:BAAALgAECgQJBAAAAA==.',
['刀刀']='刀刀爽:BAAALgAECgYJDAAAAA==.',
['刃语']='刃语者辛娜:BAACLgAFFH8NAAIaAAQJ8BfpAABpAQAaAAQJ8BfpAABpAQAuAAQKfycAAhoACQmyIP0BAHoDABoACQmyIP0BAHoDAAAA.',
['别跟']='别跟我抢辣条:BAAALgAECgYJCAAAAA==.',
['包包']='包包焱:BAAALgADCgYJBgAAAA==.',
['北瓜']='北瓜:BAAALgAECgQJBgAAAA==.',
['卡兰']='卡兰诺思:BAAALgAECgQJBAAAAA==.',
['卡地']='卡地亞:BAAALgAECgQJBgAAAA==.',
['卧室']='卧室大厨:BAABLgAFFH8FAAIBAAUJxAlyDABwAQABAAUJxAlyDABwAQAAAA==.卧室纯爷们:BAAALgAECgQJBAAAAA==.',
['原神']='原神高手:BAAALgADCgMJAwAAAA==.',
['叁姐']='叁姐儿:BAAALgAECgEJAQAAAA==.',
['又把']='又把您逮捕了:BAAALgAECgcJBwAAAA==.',
['双魚']='双魚理:BAABLgAFFH8LAAIJAAYJWSFYAwCeAQAJAAYJWSFYAwCeAQAAAA==.',
['双鱼']='双鱼狗都不谈:BAAALgAECgQJBAAAAA==.',
['口丶']='口丶神射:BAAALgAECgEJAQAAAA==.',
['只会']='只会无脑按一:BAEBLgAECn8UAAIJAAYJExqdjAC5AQAJAAYJExqdjAC5AQAAAA==.',
['只想']='只想一波到底:BAAALgAECgMJBQAAAA==.',
['可芮']='可芮奇诺:BAAALgAECgEJAQAAAA==.',
['右手']='右手的溫柔:BAAALgAECgYJCAAAAA==.',
['叶师']='叶师傅:BAAALgAECgYJCAAAAA==.',
['吃饭']='吃饭小弟:BAAALgAECgMJBgABLgAFFAUJDgAJANQkAA==.',
['吃鸡']='吃鸡小萝莉:BAAALgAFFAIJBAAAAA==.',
['吧啦']='吧啦啦大魔仙:BAAALgAECgcJBwAAAA==.',
['呕吼']='呕吼:BAACLgAFFH8KAAMRAAQJoxzhAwB1AQARAAQJoxzhAwB1AQAPAAEJUAyaEgBQAAAuAAQKfxQAAw8ACAnnHTcWACsCAA8ABwmEHTcWACsCABEABwkzFZcZAMwBAAAA.',
['周可']='周可乐:BAAALgAECgUJCAAAAA==.',
['周王']='周王者:BAACLgAFFH8RAAMNAAUJcSGHDwBjAQANAAQJcSGHDwBjAQAOAAEJAADnFwA8AAAuAAQKfx4AAg0ACQlbJdcIAFYDAA0ACQlbJdcIAFYDAAAA.',
['咕哒']='咕哒老祖:BAECLgAFFH8OAAIIAAYJFSKRAABwAgAIAAYJFSKRAABwAgAuAAQKfyAAAggACQnDJcEAAN0DAAgACQnDJcEAAN0DAAAA.',
['品如']='品如的衣柜:BAAALgAECgMJAwAAAA==.',
['哈密']='哈密瓜是猪:BAABLgAECn8aAAIJAAkJzhyGBgBoAgAJAAkJzhyGBgBoAgAAAA==.',
['喜欢']='喜欢炸鸡西瓜:BAAALgAECgIJAgAAAA==.',
['喵丶']='喵丶之哀伤:BAAALgAECgUJBQAAAA==.',
['喵小']='喵小丢丢:BAAALgAECgcJBwAAAA==.',
['噗丶']='噗丶噗:BAAALgAECgIJAwAAAA==.',
['噢吼']='噢吼:BAAALgADCgQJBAAAAA==.',
['嚣丨']='嚣丨星光:BAABLgAECn8dAAIbAAgJkhDkBADRAQAbAAgJkhDkBADRAQAAAA==.',
['嚣张']='嚣张小狼:BAAALgAECgIJAgAAAA==.',
['四保']='四保一阿巴瑟:BAAALgAECgYJCAAAAA==.',
['四季']='四季夏:BAAALgAECgQJAQAAAA==.',
['土耳']='土耳其狠人:BAAALgAFFAIJAgABLgAFFAUJDgAJANQkAA==.',
['圣乄']='圣乄提子:BAAALgAECgYJEgAAAA==.',
['圣光']='圣光之丶耀:BAAALgAECgEJAQAAAA==.圣光忽悠牛:BAAALgAECgUJDwAAAA==.圣光逝者:BAAALgADCgYJBgABLgAFFAQJCgAYAKwYAA==.',
['圣殿']='圣殿骑士裁决:BAAALgAECgQJBAAAAA==.',
['圣洁']='圣洁列斯:BAAALgADCgUJBQAAAA==.',
['堕落']='堕落之背叛者:BAAALgAECgUJBQAAAA==.',
['塞巴']='塞巴斯甜:BAACLgAFFH8IAAIcAAMJVhipDgACAQAcAAMJVhipDgACAQAuAAQKfx8AAhwACAnlIScSAJICABwACAnlIScSAJICAAAA.',
['夏日']='夏日颜颜丶:BAAALgAECgUJBgAAAA==.',
['夏桑']='夏桑:BAAALgADCgcJBwAAAA==.',
['夏雪']='夏雪丶:BAAALgADCgcJBwAAAA==.夏雪仪:BAABLgAECn8UAAIGAAcJhBThCABsAQAGAAcJhBThCABsAQAAAA==.',
['夜丶']='夜丶魔:BAACLgAFFH8OAAINAAYJxBxbAQAhAgANAAYJxBxbAQAhAgAuAAQKfxYAAg0ACQn/JRkEAJMDAA0ACQn/JRkEAJMDAAAA.',
['夜归']='夜归修罗:BAABLgAFFH8GAAIRAAIJwghmFQCKAAARAAIJwghmFQCKAAAAAA==.',
['夜鬼']='夜鬼修罗:BAABLgAFFH8HAAIRAAMJsgXqFQCEAAARAAMJsgXqFQCEAAAAAA==.',
['夜魅']='夜魅:BAACLgAFFH8FAAMNAAIJkyJ5MQDFAAANAAIJkyJ5MQDFAAAOAAEJSwcMGgA0AAAuAAQKfxQAAg0ACAnxIYArAIsCAA0ACAnxIYArAIsCAAAA.',
['大威']='大威天龍:BAAALgAECgcJBwAAAA==.',
['大尾']='大尾巴狼:BAABLgAECn8VAAMYAAcJ5A9ICgBjAQAYAAcJ5A9ICgBjAQAUAAcJQQMwLQAJAQAAAA==.',
['大恶']='大恶龙:BAAALgADCgEJAQAAAA==.',
['大枫']='大枫树梅普露:BAAALgAECgQJBgAAAA==.',
['大米']='大米那么可爱:BAAALgADCgUJBQAAAA==.',
['大绿']='大绿龙:BAAALgAECgYJBgAAAA==.',
['大自']='大自然到苏州:BAAALgAECgIJAgAAAA==.大自然的天启:BAAALgAECgQJBAAAAA==.',
['大黑']='大黑龙龙:BAACLgAFFH8PAAMUAAUJWAPxCABZAQAUAAUJWAPxCABZAQAYAAMJAgiRFADQAAAuAAQKfxUAAhQACQk0CdcZAL4BABQACQk0CdcZAL4BAAAA.',
['天之']='天之圣道:BAAALgAECgEJAQAAAA==.天之翼:BAAALgAECgcJDAAAAA==.',
['天使']='天使灵溪:BAAALgAECgYJBgAAAA==.',
['太帅']='太帅也有罪:BAABLgAECn8dAAIdAAgJNhpQFwBbAgAdAAgJNhpQFwBbAgAAAA==.',
['奈斯']='奈斯兔咪啾:BAAALgAFFAEJAQAAAA==.',
['奋斗']='奋斗新时代:BAAALgAECgYJBwAAAA==.',
['女主']='女主:BAAALgAECgYJEAAAAA==.',
['奶爸']='奶爸嗜血:BAAALgAECgIJAgAAAA==.',
['如花']='如花真的是你:BAAALgAECgMJAwAAAA==.',
['妮妮']='妮妮爱虐你:BAAALgAECgQJBQAAAA==.',
['姬小']='姬小血:BAAALgAECgQJBgAAAA==.',
['威廉']='威廉波罗蜜多:BAAALgAFFAEJAQAAAA==.',
['婉兒']='婉兒:BAAALgAECgcJCgAAAA==.',
['婼漓']='婼漓:BAAALgAECgUJBQAAAA==.',
['嫣雨']='嫣雨:BAAALgAECgcJCwAAAA==.',
['孤无']='孤无敌卿随意:BAAALgAECgUJBwABLgAECgcJEAASAAAAAA==.',
['孤独']='孤独幽灵:BAAALgAECgYJBgAAAA==.',
['守护']='守护的雪夜殇:BAAALgAECgYJBgAAAA==.守护者之左手:BAABLgAECn8UAAIKAAcJghG3VgBkAQAKAAcJghG3VgBkAQAAAA==.',
['安娜']='安娜朮:BAAALgAECgIJAgAAAA==.安娜淑:BAAALgADCgIJAgAAAA==.安娜苏:BAAALgAECgEJAQAAAA==.安娜菽:BAAALgAECgEJAQAAAA==.',
['家有']='家有贤妻:BAAALgAECgEJAgAAAA==.',
['密林']='密林塔瑞尔:BAAALgAECgUJBgAAAA==.',
['寒冬']='寒冬烈焰:BAAALgAECgYJBgAAAA==.',
['对女']='对女人过敏:BAAALgAECgcJDAAAAA==.对女人过敏吖:BAABLgAECn8XAAMIAAYJ9ho1MQB/AQAIAAYJ9ho1MQB/AQAZAAYJJA/UagATAQAAAA==.',
['寻不']='寻不到的星空:BAAALgAECgYJBgAAAA==.',
['小兵']='小兵一只:BAABLgAECn8YAAMCAAcJHQq5TABzAQACAAcJHQq5TABzAQAWAAEJKAGCUAAbAAAAAA==.',
['小化']='小化化:BAAALgAECgcJBwAAAA==.',
['小吖']='小吖小年糕:BAAALgAECgcJAQAAAA==.',
['小唐']='小唐睡不饱:BAAALgAECgMJAwAAAA==.',
['小尾']='小尾巴丶:BAAALgAECgIJAgAAAA==.',
['小时']='小时候可囧啦:BAABLgAECn8YAAIFAAgJARP5VQDgAQAFAAgJARP5VQDgAQAAAA==.',
['小明']='小明睡不醒:BAAALgAFFAIJAgAAAA==.',
['小桃']='小桃子:BAAALgAECgEJAQAAAA==.',
['小牧']='小牧:BAAALgADCgYJBgAAAA==.',
['小甜']='小甜糖灬:BAAALgADCgUJBQAAAA==.',
['小福']='小福:BAAALgADCgUJBQAAAA==.',
['小芭']='小芭内:BAAALgADCgUJBQAAAA==.',
['小酒']='小酒窝长腋毛:BAAALgAECgMJBAAAAA==.',
['小阿']='小阿雨丶:BAAALgAECgQJBAAAAA==.',
['小黄']='小黄皮:BAAALgAECgYJBgAAAA==.',
['小黑']='小黑悄悄的:BAAALgAECgQJBAAAAA==.',
['尘稀']='尘稀载耀:BAAALgAECgUJBQAAAA==.',
['山楂']='山楂果丹皮:BAACLgAFFH8FAAMLAAMJWBv+BwAUAQALAAMJWBv+BwAUAQAGAAEJ1wbrEgBIAAAuAAQKfxkAAwsACAl5HjoNAL4CAAsACAl5HjoNAL4CAAYABwnpE2IuAHEBAAAA.',
['山澗']='山澗淸流:BAAALgAECgYJBgAAAA==.',
['岑丶']='岑丶风暴烈酒:BAAALgAECgUJBQAAAA==.',
['島村']='島村抱月:BAABLgAFFH8NAAIFAAQJMhy7AgB7AQAFAAQJMhy7AgB7AQAAAA==.',
['工号']='工号玖玖捌:BAAALgAFFAEJAQAAAA==.',
['巧克']='巧克力维他奶:BAAALgAECgYJBwAAAA==.',
['布鲁']='布鲁伊:BAAALgADCgEJAQAAAA==.',
['布鸽']='布鸽:BAAALgAECgUJBQAAAA==.',
['帅小']='帅小呆:BAAALgAECgYJCAAAAA==.',
['幸运']='幸运兔爪:BAAALgAECgYJCQAAAA==.',
['廈絡']='廈絡特嘚網:BAAALgAECgYJBgAAAA==.',
['开门']='开门找别人:BAAALgADCgEJAQAAAA==.',
['弑夜']='弑夜的死:BAAALgAFFAIJAgAAAA==.',
['弑神']='弑神者灬丨:BAAALgAFFAIJAgAAAA==.',
['弾指']='弾指红颜老:BAAALgAECgcJEgAAAA==.',
['影夜']='影夜殇魂:BAACLgAFFH8LAAIOAAMJ1gF2DgCDAAAOAAMJ1gF2DgCDAAAuAAQKfxYAAg4ACQkiC4cVALsBAA4ACQkiC4cVALsBAAAA.',
['影月']='影月宿魂:BAABLgAFFH8LAAIVAAMJhwRcBACJAAAVAAMJhwRcBACJAAAAAA==.',
['影殇']='影殇一号:BAAALgAECgcJBwAAAA==.',
['影訫']='影訫:BAABLgAECn8fAAQbAAgJsBUrGQA7AgAbAAgJrRUrGQA7AgAeAAQJVQ8cEAAOAQATAAEJSgRaDwArAAAAAA==.',
['徐筱']='徐筱珂:BAAALgAECgEJAgAAAA==.',
['微笑']='微笑之手:BAAALgAECgYJBgAAAA==.',
['心动']='心动讯号:BAAALgAECgkJEAAAAA==.',
['忆小']='忆小梦:BAAALgAFFAIJBAAAAA==.',
['忆梦']='忆梦:BAACLgAFFH8KAAIfAAQJiBYkAQA9AQAfAAQJiBYkAQA9AQAuAAQKfx8AAx8ACQmUHB8BAF4CAB8ACQmUHB8BAF4CAAwABQkMCYFnAN0AAAEuAAUUBgkPAB8ATx0A.',
['快乐']='快乐小男孩:BAACLgAFFH8SAAIRAAYJWR8cAQBKAgARAAYJWR8cAQBKAgAuAAQKfx0AAxEACQkeJAwBAJQDABEACQkeJAwBAJQDAA8AAQmTD6KBADAAAAAA.',
['思绪']='思绪飘零:BAAALgAECgUJCQAAAA==.',
['怪兽']='怪兽哪里跑:BAAALgADCgYJBgAAAA==.',
['怪叔']='怪叔叔:BAAALgAECgIJAgAAAA==.',
['恶魔']='恶魔代言人:BAAALgAECgMJAwAAAA==.恶魔球:BAAALgAECgYJCgAAAA==.',
['恺总']='恺总爱吃果:BAAALgAECgcJDQAAAA==.',
['悠悠']='悠悠的哓猪:BAAALgADCgcJBwAAAA==.悠悠的筱猪:BAAALgADCgEJAQAAAA==.悠悠的筱筱猪:BAAALgAECgYJBgAAAA==.',
['想吃']='想吃可爱多:BAAALgAECgEJAQAAAA==.',
['惹丶']='惹丶尘埃:BAAALgAECgEJAQAAAA==.',
['愚人']='愚人奏乐:BAAALgAECgQJBwAAAA==.',
['愤怒']='愤怒鼻涕:BAABLgAFFH8LAAIJAAQJrxGBDQBMAQAJAAQJrxGBDQBMAQAAAA==.',
['慢性']='慢性子:BAAALgAECgEJAgAAAA==.',
['懒惰']='懒惰人:BAACLgAFFH8LAAIdAAQJwSJNAwCkAQAdAAQJwSJNAwCkAQAuAAQKfxwAAh0ACAmaJAIDAE0DAB0ACAmaJAIDAE0DAAAA.',
['我偷']='我偷电瓶养你:BAAALgAFFAQJBAAAAA==.',
['我叫']='我叫季伯大:BAAALgADCgYJBgAAAA==.我叫季佰长:BAABLgAECn8WAAMaAAYJaA1lPQAIAQABAAYJMwxPfwAsAQAaAAYJ7AhlPQAIAQAAAA==.',
['我欲']='我欲封天:BAAALgAECgYJBgAAAA==.',
['我爱']='我爱吃蛋挞:BAAALgAECgQJCwAAAA==.我爱吃鸡腿:BAAALgAFFAIJAwAAAA==.我爱慧慧爱我:BAAALgAECgYJBwAAAA==.我爱猪脚饭:BAAALgAECggJCwABLgAFFAIJAwASAAAAAA==.',
['我看']='我看看咋玩:BAAALgADCgYJBgAAAA==.',
['我知']='我知道你是谁:BAAALgAECgYJBgAAAA==.',
['我腰']='我腰烟牌:BAAALgAECgkJCQAAAA==.',
['我要']='我要是偏不呢:BAAALgADCgUJBQAAAA==.我要焯你阿:BAAALgAFFAEJAQAAAA==.我要驗牌:BAAALgADCgYJBgAAAA==.我要验牌:BAAALgAFFAEJAQAAAA==.',
['手持']='手持超新星:BAEBLgAFFH8GAAIQAAMJ1iS4AgBNAQAQAAMJ1iS4AgBNAQABLgAFFAYJDgAIABUiAA==.',
['扯你']='扯你一角:BAAALgADCgEJAQAAAA==.',
['抖抖']='抖抖莎:BAAALgADCgMJAwAAAA==.',
['拓拓']='拓拓:BAAALgAECgcJDQAAAA==.',
['排水']='排水弯过沟:BAAALgAFFAEJAgAAAA==.',
['擎天']='擎天小骑:BAAALgAECgkJDwABLgAFFAkJBgAHALgTAA==.',
['散步']='散步者吴竞:BAAALgAECgMJAwAAAA==.',
['无所']='无所做为:BAAALgAFFAIJAwAAAA==.',
['无能']='无能的相公:BAAALgAECgUJCQAAAA==.',
['旺仔']='旺仔摇滚栋:BAACLgAFFH8LAAMgAAMJ8RfGFAD3AAAgAAMJxhPGFAD3AAAKAAMJGRUWFQCwAAAuAAQKfxwAAiAABwmOILYBAPsBACAABwmOILYBAPsBAAAA.',
['星空']='星空辰影:BAAALgADCgEJAQAAAA==.',
['昨天']='昨天没下雨:BAAALgAECgYJBgAAAA==.',
['晚安']='晚安飞机:BAAALgADCgEJAgAAAA==.',
['晨光']='晨光之怒:BAAALgAECgEJAQAAAA==.',
['晨曦']='晨曦载耀:BAACLgAFFH8RAAMZAAYJKBsvAQAZAgAZAAYJKBsvAQAZAgAIAAEJCgUwHABFAAAuAAQKfyYAAhkACQmxJCgBAKEDABkACQmxJCgBAKEDAAAA.',
['普皖']='普皖:BAAALgADCgUJBQAAAA==.',
['晴空']='晴空想念:BAAALgAECgYJDAAAAA==.',
['暗礁']='暗礁:BAAALgAECgQJBAAAAA==.',
['暮光']='暮光炮:BAAALgAECgEJAQAAAA==.',
['暴風']='暴風灰燼使者:BAAALgAECgYJCAAAAA==.',
['暴食']='暴食:BAAALgAECgYJDwAAAA==.',
['曹达']='曹达华:BAAALgAECgQJBAAAAA==.',
['最强']='最强萨满:BAABLgAECn8UAAIdAAcJExSNMwC2AQAdAAcJExSNMwC2AQAAAA==.',
['最棒']='最棒的你:BAAALgAECgIJAgAAAA==.',
['月之']='月之本樱:BAAALgAECgMJAwAAAA==.',
['月岛']='月岛织姫:BAAALgAECgQJBwAAAA==.',
['月是']='月是天上月:BAAALgADCgcJBwAAAA==.',
['月现']='月现狼嚎:BAAALgAECgEJAQAAAA==.',
['月瞳']='月瞳:BAAALgAECgEJAgAAAA==.',
['月黄']='月黄昏:BAAALgAECgIJBAAAAA==.',
['有一']='有一堆人:BAABLgAECn8VAAQcAAcJIAqNPwBMAQAcAAcJuAmNPwBMAQAhAAQJpwjUIADFAAAdAAMJpwcLhwB4AAAAAA==.',
['有所']='有所思:BAAALgAECgYJCAAAAA==.',
['望舒']='望舒逸剑:BAAALgAECgYJBwAAAA==.',
['朵力']='朵力朵特:BAAALgAECgEJAQAAAA==.',
['李三']='李三哥:BAAALgAECgIJAgAAAA==.',
['枼少']='枼少丶:BAAALgADCgEJAQAAAA==.',
['柰文']='柰文莫尔:BAAALgAECgcJCgAAAA==.',
['桀骜']='桀骜斯达瑞:BAACLgAFFH8SAAMCAAYJMSPUAAAMAgACAAUJDyTUAAAMAgAXAAEJtx+dCABlAAAuAAQKfxUAAgIACQl4Ja8BALIDAAIACQl4Ja8BALIDAAAA.',
['桑小']='桑小伊:BAAALgAECgUJCQAAAA==.',
['梦境']='梦境之念:BAAALgAECgYJEwAAAA==.梦境追逐者:BAAALgAECgEJAQAAAA==.',
['梦蝶']='梦蝶:BAAALgAECgEJAQAAAA==.',
['樊崎']='樊崎灵:BAAALgAECgQJBAAAAA==.',
['樱桃']='樱桃寿司:BAACLgAFFH8RAAIFAAYJCheqAQAHAgAFAAYJCheqAQAHAgAuAAQKfyEAAgUACQmLIokMACkDAAUACQmLIokMACkDAAAA.',
['樱流']='樱流:BAAALgAECgkJEAAAAA==.',
['檸檬']='檸檬:BAAALgADCgcJBwAAAA==.',
['欧柒']='欧柒:BAAALgAECgcJBwAAAA==.',
['欧阳']='欧阳筱筱:BAAALgAECgYJDAAAAA==.',
['正常']='正常人类:BAAALgAECgUJCAAAAA==.',
['死骑']='死骑死骑哟:BAACLgAFFH8OAAMNAAUJqxGcGwA1AQANAAQJqxGcGwA1AQAOAAEJAABlGQA3AAAuAAQKfy4AAg0ACQmfIfEHAGADAA0ACQmfIfEHAGADAAAA.',
['残酷']='残酷猎神:BAABLgAFFH8LAAMKAAQJ4RHbCgALAQAKAAMJSRTbCgALAQAiAAIJJAmiBgCoAAAAAA==.',
['残阳']='残阳如风:BAAALgADCgEJAQAAAA==.',
['毛线']='毛线:BAAALgAECgYJBwAAAA==.',
['水煮']='水煮魚:BAAALgADCgEJAQAAAA==.',
['水王']='水王小德:BAAALgAECgUJCAAAAA==.',
['永不']='永不跳车:BAAALgAFFAEJAQAAAA==.',
['汐丶']='汐丶咲:BAACLgAFFH8IAAIOAAUJaATsCAD6AAAOAAUJaATsCAD6AAAuAAQKfxUAAg4ACAnfCGwnAAMBAA4ACAnfCGwnAAMBAAEuAAUUBwkfACAAIiMA.',
['江上']='江上听风:BAAALgAECgUJBQAAAA==.',
['江烟']='江烟万缕:BAAALgAECgEJAQAAAA==.',
['汼奶']='汼奶咘甸:BAAALgAECgEJAQAAAA==.',
['沃特']='沃特看爱死一:BAAALgAECgYJDgAAAA==.',
['沾染']='沾染墨色:BAAALgADCgYJBgAAAA==.',
['沾繁']='沾繁霜而至曙:BAACLgAFFH8VAAQDAAYJ5BOVAgAGAgADAAYJXROVAgAGAgAEAAEJOBUNFQBUAAAjAAEJhAbtBgBOAAAuAAQKfxkAAwMACAlVIZ0bAK8CAAMACAk5IJ0bAK8CAAQAAgl6HtMPAFkAAAAA.',
['泡泡']='泡泡吹泡泡:BAAALgAECgYJBgAAAA==.',
['泰岚']='泰岚德:BAAALgADCgIJAgAAAA==.',
['洛神']='洛神:BAAALgAECgQJBAAAAA==.',
['洛阳']='洛阳水神:BAAALgAECgEJAQAAAA==.',
['洪世']='洪世贤:BAAALgAFFAEJAQAAAA==.',
['活体']='活体炸彈:BAAALgAECgUJBQAAAA==.',
['浮華']='浮華:BAAALgAECgIJAwAAAA==.',
['海南']='海南烈发家居:BAABLgAECn8YAAIdAAgJjhfLHQAtAgAdAAgJjhfLHQAtAgAAAA==.',
['海绵']='海绵祖宗:BAAALgAECgYJBgAAAA==.',
['淡淡']='淡淡的伊人:BAAALgAECgUJBQAAAA==.淡淡风飘渺:BAAALgADCgUJBQAAAA==.',
['淦亖']='淦亖一片:BAAALgAECgEJAQAAAA==.',
['深圳']='深圳货代老李:BAAALgAECgcJEwAAAA==.',
['混混']='混混:BAAALgAECgEJAgAAAA==.',
['添乐']='添乐蚂蚱:BAAALgAECgYJCgAAAA==.',
['渡鸦']='渡鸦:BAAALgAECgIJAwAAAA==.',
['温酒']='温酒斩古蛋:BAAALgAFFAEJAQABLgAECggJGAAdAI4XAA==.',
['渺渺']='渺渺兮予怀:BAAALgAECggJCwAAAA==.',
['溏心']='溏心:BAAALgADCgcJDgAAAA==.',
['溏悠']='溏悠悠:BAAALgAECgYJBgAAAA==.',
['潇洒']='潇洒哥来了:BAAALgAECgUJBgAAAA==.潇洒哥走了:BAAALgAECgMJBAAAAA==.',
['澜祎']='澜祎的小鬼:BAAALgADCgYJBwABLgAECgcJDQASAAAAAA==.',
['火塞']='火塞煤:BAAALgAECgEJAQAAAA==.',
['灬汤']='灬汤圆灬:BAABLgAECn8cAAIKAAkJ0hJNIgA4AgAKAAkJ0hJNIgA4AgAAAA==.',
['灬臭']='灬臭屁喽灬:BAAALgADCgQJBAAAAA==.',
['灰烬']='灰烬者:BAABLgAECn8VAAIFAAcJihYMTQD7AQAFAAcJihYMTQD7AQAAAA==.',
['灰袍']='灰袍萨鲁曼:BAAALgAECgYJCgAAAA==.',
['灵幻']='灵幻风影:BAACLgAFFH8NAAMQAAQJzhEMBwBVAQAQAAQJzhEMBwBVAQAPAAIJ3AQODgCNAAAuAAQKfzAAAxAACQmKIFoAACQDABAACQmKIFoAACQDAA8ABAkGCsFXANYAAAAA.',
['热心']='热心网友小霖:BAAALgAECgQJBgAAAA==.',
['熊萨']='熊萨:BAABLgAFFH8WAAIZAAYJBx6OAAAjAgAZAAYJBx6OAAAjAgAAAA==.',
['熊貓']='熊貓人:BAABLgAFFH8KAAILAAQJYxHyBwAVAQALAAQJYxHyBwAVAQAAAA==.熊貓酒仙:BAAALgAECgQJBAAAAA==.',
['熙儿']='熙儿:BAAALgAECgYJDAAAAA==.',
['熙兒']='熙兒:BAAALgAECgMJBAAAAA==.',
['熙妤']='熙妤:BAAALgAECgcJCAAAAA==.',
['爆爆']='爆爆:BAAALgADCgMJAwAAAA==.',
['爱德']='爱德莉娅:BAAALgADCgUJBQAAAA==.',
['爱滴']='爱滴魔力:BAAALgAECgMJAwAAAA==.',
['爵乄']='爵乄爷:BAAALgAECgYJDAAAAA==.爵乄爺:BAAALgAECgQJBQAAAA==.',
['牛奶']='牛奶:BAAALgAECgEJAgAAAA==.',
['猎部']='猎部高手:BAAALgAECgYJCAAAAA==.',
['猪儿']='猪儿要飞天:BAAALgADCgEJAQAAAA==.',
['猫爪']='猫爪必须在上:BAAALgAECgcJDQAAAA==.',
['玉兔']='玉兔搗药:BAAALgAECgQJCQAAAA==.',
['王哥']='王哥你好丶:BAAALgAFFAQJAgAAAA==.',
['玥颖']='玥颖:BAAALgAFFAEJAQAAAA==.',
['琪琪']='琪琪爱闹:BAAALgAECgYJCQAAAA==.',
['璐璐']='璐璐卟:BAAALgAECgUJBQAAAA==.',
['甜米']='甜米月亮粥:BAAALgAECgUJBQAAAA==.',
['男神']='男神的号:BAAALgAFFAMJAwAAAA==.',
['疯狂']='疯狂屠夫:BAAALgAFFAEJAQAAAA==.疯狂屠戮者:BAAALgAECgYJCwAAAA==.',
['疯魔']='疯魔皇胤:BAAALgADCgIJAgAAAA==.',
['白斩']='白斩:BAAALgAECgcJBwAAAA==.',
['白色']='白色裤衩子:BAAALgAECgEJAQAAAA==.',
['皇家']='皇家扫堂腿:BAAALgAFFAMJAwAAAA==.',
['皓匀']='皓匀京墨:BAAALgAECgMJAwAAAA==.皓匀长卿:BAAALgAECgYJBgAAAA==.',
['盐板']='盐板秋刀鱼:BAAALgAECgEJAgAAAA==.',
['目邓']='目邓口呆:BAAALgAECgMJAwAAAA==.',
['真男']='真男人:BAAALgAECgMJAwAAAA==.',
['眼瞎']='眼瞎瞎:BAABLgAECn8VAAMkAAgJzAMGFwDsAAAkAAgJXwMGFwDsAAAaAAMJlgILXQBsAAAAAA==.',
['瞎眼']='瞎眼眼:BAAALgAECgQJBQABLgAFFAgJGQAbAN0eAA==.',
['神之']='神之净土:BAAALgAFFAIJAgAAAA==.',
['神圣']='神圣魔王:BAAALgADCgIJAgAAAA==.',
['神奇']='神奇高爆弹:BAAALgAFFAEJAQAAAA==.',
['神樂']='神樂千鶴:BAAALgADCgUJBQAAAA==.',
['神赫']='神赫利乌斯:BAAALgAECgYJCAAAAA==.',
['秀儿']='秀儿:BAAALgADCgEJAQAAAA==.',
['秋水']='秋水伊琳:BAABLgAECn8XAAMHAAgJRQs9MQA1AQAHAAcJOws9MQA1AQAGAAEJZwI2iwAiAAAAAA==.',
['秋蝉']='秋蝉微鸣:BAABLgAECn8WAAIkAAYJYhBcEgAsAQAkAAYJYhBcEgAsAQAAAA==.',
['秋雨']='秋雨:BAAALgAECgYJBwAAAA==.',
['空城']='空城丶守望:BAAALgAECgYJBgAAAA==.',
['窵禠']='窵禠:BAAALgAECgEJAgAAAA==.',
['立花']='立花里子丶:BAAALgAFFAIJBAAAAA==.',
['筑云']='筑云:BAAALgAECgQJBAAAAA==.',
['筱竹']='筱竹雨荷:BAAALgAECgcJBgAAAA==.',
['箭舞']='箭舞飛揚:BAAALgAECgYJDAAAAA==.',
['糖不']='糖不甩:BAAALgAECgIJAQAAAA==.',
['糖篼']='糖篼:BAAALgAECgEJAQAAAA==.',
['絶歌']='絶歌:BAAALgAECgEJAQAAAA==.',
['红模']='红模仿:BAAALgAECgQJBAAAAA==.',
['红鲤']='红鲤鱼绿鲤鱼:BAAALgAECgQJBgAAAA==.',
['细雨']='细雨牧:BAAALgAECgEJAQAAAA==.',
['织影']='织影者井三子:BAAALgAFFAIJBAABLgAFFAYJFAAIALAdAA==.',
['续一']='续一分钟:BAAALgAECgYJCAAAAA==.',
['绯红']='绯红丶耀月:BAAALgAECgUJAwAAAA==.',
['绿毛']='绿毛虫:BAACLgAFFH8IAAICAAMJPx8MBgAZAQACAAMJPx8MBgAZAQAuAAQKfyEAAwIACAlDHloMAPUCAAIACAlDHloMAPUCABcAAQmTCaJDADEAAAAA.',
['羊过']='羊过小龙女:BAAALgAFFAQJBAAAAA==.',
['老司']='老司机带个我:BAAALgADCgEJAQAAAA==.',
['聖光']='聖光萌主:BAAALgAECgYJBgAAAA==.',
['聪头']='聪头再来:BAAALgAECgQJBAAAAA==.',
['肚子']='肚子真的疼:BAAALgADCgQJBAAAAA==.',
['肥尼']='肥尼科斯:BAABLgAFFH8IAAIKAAQJsQfmCgALAQAKAAQJsQfmCgALAQAAAA==.',
['肥雕']='肥雕:BAAALgADCgEJAQAAAA==.',
['肯德']='肯德基爷爷:BAAALgAECggJCQAAAA==.',
['胖灬']='胖灬虎:BAAALgAECgIJAwAAAA==.',
['脆面']='脆面:BAAALgAECgUJBQAAAA==.',
['腥哩']='腥哩膀气:BAAALgAECgcJCwAAAA==.',
['腻黛']='腻黛蒂:BAAALgADCgQJBAAAAA==.',
['致命']='致命打叽:BAAALgAECgUJCwAAAA==.',
['艾特']='艾特利:BAAALgAECgIJAwAAAA==.',
['芒果']='芒果西米:BAAALgAECgEJAQAAAA==.',
['芝芝']='芝芝莓问题:BAAALgAECgQJBAAAAA==.',
['花木']='花木槿:BAAALgADCgUJBQAAAA==.',
['花海']='花海小红手:BAAALgAECgYJCgAAAA==.',
['花絮']='花絮纷飞:BAAALgADCgIJAgAAAA==.',
['苍冥']='苍冥君临乱世:BAAALgADCgQJBAAAAA==.',
['荒川']='荒川之王:BAAALgAFFAEJAQABLgAFFAQJCgALAGMRAA==.',
['莉娜']='莉娜因巴斯:BAAALgAECgQJBwAAAA==.',
['莎莉']='莎莉逐日者:BAAALgAFFAEJAQAAAA==.',
['莫奈']='莫奈何:BAABLgAECn8eAAMXAAkJfQ8SCQAeAgAXAAkJIA0SCQAeAgACAAYJFQxEZwAWAQAAAA==.',
['莱希']='莱希拉姆:BAABLgAFFH8FAAIYAAMJOQTfDQC4AAAYAAMJOQTfDQC4AAAAAA==.',
['菲尼']='菲尼克斯丨法:BAAALgAECgYJAQAAAA==.菲尼克斯丨聖:BAABLgAFFH8FAAIFAAMJ3xNYJACjAAAFAAMJ3xNYJACjAAABLgAFFAcJBQAJANIGAA==.',
['萌三']='萌三奶奶:BAABLgAFFH8VAAIZAAYJVQpTAgCjAQAZAAYJVQpTAgCjAQAAAA==.',
['萌囡']='萌囡囡丶:BAAALgAECgYJCwAAAA==.',
['萌萌']='萌萌的果果:BAAALgAECgYJEwAAAA==.',
['萨倾']='萨倾国:BAAALgAECgQJBQAAAA==.',
['萨谢']='萨谢斯:BAAALgADCgQJBAAAAA==.',
['落叶']='落叶春雨:BAAALgADCgEJAQAAAA==.',
['葫芦']='葫芦焱:BAAALgADCgYJBgAAAA==.',
['蓝希']='蓝希尔:BAAALgAECgcJCQAAAA==.',
['蕶灬']='蕶灬儿:BAAALgAFFAEJAgAAAA==.',
['蕾塞']='蕾塞:BAAALgAECgUJBQAAAA==.',
['薛棣']='薛棣凯:BAAALgAECgYJBwABLgAFFAUJDAANAPwjAA==.',
['虎哇']='虎哇虎哇噜:BAACLgAFFH8RAAMeAAUJQBXRAAC4AQAeAAUJrxDRAAC4AQAbAAUJcxE7BACwAQAuAAQKfxoAAxsACQm5IT4GAC0DABsACQm5IT4GAC0DAB4ACAlJGZwCAMQCAAAA.',
['蛮子']='蛮子:BAAALgAECgEJAQAAAA==.',
['血腥']='血腥追猎者:BAABLgAFFH8OAAMKAAUJCRLYDAD7AAAgAAQJSQtlDwA3AQAKAAQJ8BHYDAD7AAAAAA==.',
['血龙']='血龙吟:BAAALgAECgIJBAAAAA==.',
['袁术']='袁术煞:BAABLgAFFH8FAAIcAAUJsQBrCgC/AAAcAAUJsQBrCgC/AAAAAA==.',
['西门']='西门飘柔:BAAALgAECgEJAQAAAA==.',
['见习']='见习小法:BAAALgAECgcJEwAAAA==.',
['訷話']='訷話乄爵爷:BAAALgAECgYJBgAAAA==.訷話乄爵爺:BAAALgAECgYJCwAAAA==.訷話乄雪莉:BAAALgAECgUJCAAAAA==.',
['请假']='请假来上网:BAAALgAECgMJAwAAAA==.',
['请叫']='请叫我嘟总丶:BAAALgAECgYJCQAAAA==.',
['诸葛']='诸葛劣人:BAAALgAECgIJAwAAAA==.',
['貓小']='貓小小:BAABLgAFFH8GAAIZAAMJsxJ0CgDeAAAZAAMJsxJ0CgDeAAAAAA==.',
['赦夜']='赦夜之魂:BAAALgAECgUJBwAAAA==.',
['超时']='超时空辉夜姬:BAAALgAECgUJDgAAAA==.',
['踏风']='踏风揽云:BAACLgAFFH8QAAILAAUJ6h7xAgC4AQALAAUJ6h7xAgC4AQAuAAQKfxoAAwsACQlwI5kCAHADAAsACQlwI5kCAHADAAYAAQlTDoh3ADsAAAAA.',
['躁虐']='躁虐:BAACLgAFFH8IAAIBAAMJVAzYEgDhAAABAAMJVAzYEgDhAAAuAAQKfx4AAgEACAlFHH8aALUCAAEACAlFHH8aALUCAAAA.',
['轩辕']='轩辕心:BAAALgAFFAIJAgAAAA==.',
['软惊']='软惊天:BAAALgAECgEJAQAAAA==.',
['轰牛']='轰牛:BAAALgADCgIJAgAAAA==.',
['辉夜']='辉夜的暗影:BAAALgADCgEJAQAAAA==.',
['边疆']='边疆荒野:BAAALgAECgMJAwAAAA==.',
['还在']='还在嘴硬:BAACLgAFFH8GAAIOAAUJlxZABABrAQAOAAUJlxZABABrAQAuAAQKfxcAAg4ACAncGmINADgCAA4ACAncGmINADgCAAAA.',
['迪亚']='迪亚小菠萝:BAAALgAECgYJBgAAAA==.',
['迷彩']='迷彩一:BAAALgADCgUJBQAAAA==.',
['逍遥']='逍遥灵:BAAALgAECgEJAQAAAA==.逍遥自在:BAAALgAECgcJDAAAAA==.',
['那个']='那个黑魔:BAAALgAFFAIJBAAAAA==.',
['那克']='那克萌德:BAAALgAECgYJBgAAAA==.',
['那夜']='那夜花謝:BAAALgAECgQJBAAAAA==.',
['那时']='那时非人:BAAALgAECgEJAQAAAA==.',
['重于']='重于泰山:BAAALgADCgYJBgAAAA==.',
['野哥']='野哥:BAAALgAECgEJAQAAAA==.',
['野性']='野性的拥抱:BAAALgAECgUJBwAAAA==.',
['野蛮']='野蛮狂热者:BAAALgADCgEJAQAAAA==.',
['金麟']='金麟:BAAALgAECgYJAwAAAA==.',
['铁柱']='铁柱:BAAALgAECgEJAQAAAA==.',
['铜枪']='铜枪铁笔:BAAALgAECgYJBgABLgAFFAUJDAAgADsQAA==.',
['银河']='银河黑暗大帝:BAABLgAFFH8LAAIBAAYJCBXNAgCQAQABAAYJCBXNAgCQAQAAAA==.',
['销魂']='销魂阿水:BAAALgAFFAEJAQAAAA==.',
['阿佛']='阿佛洛谛忒:BAAALgAECgQJBAAAAA==.',
['阿德']='阿德:BAAALgADCgEJAQAAAA==.',
['阿漓']='阿漓:BAAALgAECgEJAQAAAA==.',
['阿珂']='阿珂懵德:BAAALgAECgIJAgAAAA==.',
['阿萌']='阿萌萌酱:BAAALgAECgYJAQAAAA==.',
['陆晚']='陆晚晚:BAAALgAECgYJCAAAAA==.',
['陈文']='陈文锦丿:BAACLgAFFH8NAAIPAAYJwxdPAAAlAgAPAAYJwxdPAAAlAgAuAAQKfxcAAg8ACAmYIroEAAYDAA8ACAmYIroEAAYDAAAA.',
['雅戈']='雅戈布丶:BAACLgAFFH8FAAIcAAUJ7wzrBgBsAQAcAAUJ7wzrBgBsAQAuAAQKfyQAAhwACQlIHz4GAC8DABwACQlIHz4GAC8DAAAA.',
['雨寒']='雨寒:BAAALgAECgUJBQAAAA==.',
['雨神']='雨神:BAAALgAECgQJBwAAAA==.',
['雨落']='雨落天堂:BAAALgADCgYJBgAAAA==.',
['雪乄']='雪乄莉:BAAALgAECgUJBwAAAA==.',
['零度']='零度线:BAAALgAFFAIJAwAAAA==.',
['雷寒']='雷寒暄:BAAALgADCggJCAAAAA==.',
['雾一']='雾一:BAAALgAFFAEJAQAAAA==.',
['雾峪']='雾峪伞:BAAALgAFFAQJBAABLgAFFAQJCQAZADgUAA==.',
['霜语']='霜语梦寐:BAAALgAECgIJAgAAAA==.',
['霜雪']='霜雪成坛:BAAALgAECgYJDAAAAA==.',
['靈儿']='靈儿:BAAALgADCggJCAAAAA==.',
['青锋']='青锋侠:BAAALgAECgEJAQAAAA==.',
['青鸾']='青鸾:BAAALgAECgYJEAAAAA==.',
['面包']='面包师晓晨:BAAALgAECgMJAwAAAA==.',
['顾墨']='顾墨问:BAAALgAECgQJBQAAAA==.',
['風吹']='風吹大乃摇:BAAALgAECgEJAQAAAA==.',
['風流']='風流雲散:BAAALgAECgMJBAAAAA==.',
['风中']='风中承诺:BAAALgADCgMJAwAAAA==.',
['风之']='风之軌跡:BAAALgAECgcJBwAAAA==.',
['风潇']='风潇潇雨飘飘:BAAALgAECgUJBQAAAA==.',
['飞机']='飞机仔:BAAALgADCgEJAQAAAA==.',
['飞翼']='飞翼零:BAAALgAECgYJBwAAAA==.',
['飞行']='飞行雪绒:BAAALgAFFAIJAgAAAA==.',
['飞鱼']='飞鱼:BAAALgAECgYJEgAAAA==.',
['香奈']='香奈兒:BAAALgAECgQJBQAAAA==.',
['马尔']='马尔科丶:BAAALgAECgIJAwAAAA==.',
['马甲']='马甲的追求:BAAALgAECgIJAgAAAA==.',
['骑马']='骑马与砍杀:BAAALgAECgYJCwAAAA==.',
['骚气']='骚气小母龙:BAAALgADCgMJAwAAAA==.',
['鬼城']='鬼城阴都:BAAALgAECgEJAQAAAA==.',
['鬼谜']='鬼谜曰眼:BAAALgAECgcJCAAAAA==.',
['鬼魅']='鬼魅灬幽幽:BAAALgAECgkJAQAAAA==.鬼魅灬战魂:BAAALgAECgEJAQAAAA==.鬼魅灬浅唱:BAAALgAECgcJBwAAAA==.鬼魅灬淼淼:BAAALgAECgEJAQAAAA==.鬼魅灬潇潇:BAAALgAECgYJCAAAAA==.鬼魅灬猎忍:BAAALgADCgIJAgAAAA==.鬼魅灬猎杀:BAAALgAECgIJAgAAAA==.鬼魅灬落落:BAAALgAECgQJBAAAAA==.',
['魔法']='魔法大冬瓜:BAACLgAFFH8FAAIJAAUJvhEWDAC8AQAJAAUJvhEWDAC8AQAuAAQKfx0AAgkABwmxIZ4tALsCAAkABwmxIZ4tALsCAAAA.',
['魔皇']='魔皇:BAAALgADCgEJAQAAAA==.',
['鸡蛋']='鸡蛋鸭蛋荷包:BAAALgAECggJCAABLgAFFAIJAgASAAAAAA==.',
['鸳箩']='鸳箩:BAAALgADCgEJAQAAAA==.',
['鹏抟']='鹏抟九万:BAAALgAECgYJBgAAAA==.',
['鹏鹏']='鹏鹏:BAAALgAECgcJCgAAAA==.',
['鹰击']='鹰击长空:BAAALgAECgYJCQAAAA==.',
['麦田']='麦田里的熊:BAAALgAECgEJAQAAAA==.',
['黑夜']='黑夜兽医:BAAALgAECgUJBQAAAA==.',
['黑白']='黑白灰:BAAALgAECgUJBwAAAA==.',
['默言']='默言:BAAALgAECgQJBAAAAA==.',
['黛琳']='黛琳:BAAALgAECgEJAQAAAA==.',
['龙龙']='龙龙大冬瓜:BAAALgAFFAQJBAABLgAFFAUJBQAJAL4RAA==.',
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
