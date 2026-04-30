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

local lookup = {'Unknown-Unknown','DemonHunter-Havoc','DeathKnight-Unholy','DemonHunter-Vengeance','Monk-Mistweaver','Shaman-Elemental','Mage-Frost','Warlock-Demonology','Paladin-Retribution','Druid-Feral','Shaman-Restoration','Shaman-Enhancement','Druid-Restoration','Druid-Balance','Rogue-Subtlety','DemonHunter-Devourer','Druid-Guardian','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Protection','Warlock-Destruction','Paladin-Holy','Warrior-Protection','Hunter-Survival','Evoker-Augmentation','Evoker-Devastation','DemonHunter-DPS','DeathKnight-Blood','Warlock-Ranged','Priest-Holy','Monk-Brewmaster','Priest-Discipline','DeathKnight-Frost','Warrior-Fury','Priest-Shadow','Warrior-Arms','Monk-Windwalker','Mage-Fire','Evoker-Preservation',}
local provider = {region='CN',realm='玛里苟斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Aczom:BAAALgAFFAQJBAAAAA==.',
Ae='Aenrq:BAAALgADCgMJAwAAAA==.',
Ai='Aina:BAAALgAFFAIJAgABLgAFFAIJAwABAAAAAA==.',
Al='Alexrd:BAAALgADCgUJBQAAAA==.',
Am='Amireux:BAAALgAFFAIJBAAAAA==.',
An='Angrywind:BAAALgAECgcJDAAAAA==.',
Bi='Bibi:BAAALgAECgcJBwAAAA==.',
Ca='Calatath:BAAALgAECgQJBAABLgAFFAEJAgABAAAAAA==.Cate:BAAALgAFFAEJAgAAAA==.',
Ci='Ciri:BAAALgADCgEJAQAAAA==.',
Cr='Crecre:BAAALgAECgEJAQAAAA==.',
Da='Dara:BAABLgAECn8YAAICAAcJahpyFAAtAgACAAcJahpyFAAtAgAAAA==.',
De='Deathog:BAABLgAFFH8FAAIDAAMJfBsWJAAFAQADAAMJfBsWJAAFAQAAAA==.Deathtom:BAAALgAFFAIJAwABLgAFFAUJBQAEAFMlAA==.',
Di='Dispenser:BAAALgAECgkJCQABLgAFFAYJEgAFAB4aAA==.',
Do='Doro:BAAALgAFFAQJBAAAAA==.',
Ds='Dseight:BAABLgAFFH8IAAIGAAQJuhUhCQBMAQAGAAQJuhUhCQBMAQAAAA==.Dsfive:BAAALgAECgYJBgAAAA==.Dsfour:BAAALgAFFAMJBAAAAA==.Dsmseven:BAABLgAFFH8LAAIGAAQJfRt8BwBiAQAGAAQJfRt8BwBiAQAAAA==.Dsnine:BAAALgAECgcJBgAAAA==.Dsone:BAAALgAFFAIJAgAAAA==.Dssix:BAABLgAECn8YAAIGAAcJHBZlIQADAgAGAAcJHBZlIQADAgAAAA==.Dsthree:BAAALgAFFAQJBAAAAA==.Dstwo:BAAALgAFFAIJAgAAAA==.',
Ef='Efforts:BAAALgAECgUJBgAAAA==.',
El='Elunery:BAAALgAECgMJAwAAAA==.',
Fa='Fansk:BAAALgAECgYJBgAAAA==.',
Fl='Flechazo:BAAALgAECgYJCAAAAA==.',
Fr='Free:BAAALgADCgMJAwAAAA==.',
Ga='Garlvinland:BAAALgAFFAUJBAAAAA==.Gato:BAAALgAFFAQJBAAAAA==.',
He='Heartslayer:BAACLgAFFH8FAAIDAAMJsw5KKgDxAAADAAMJsw5KKgDxAAAuAAQKfxYAAgMACAnnFFVSAPoBAAMACAnnFFVSAPoBAAAA.',
Hj='Hjl:BAAALgAECgMJBQAAAA==.',
Io='Ioo:BAAALgAECgYJBgAAAA==.',
Ja='Jacethorns:BAAALgAECgUJBwAAAA==.Jacklove:BAAALgAECgcJEwAAAA==.Janedoe:BAAALgAFFAQJBAAAAA==.',
Ko='Kokobila:BAAALgAECgYJCAAAAA==.Kokolo:BAAALgAECgUJCQAAAA==.',
Li='Linnanxd:BAAALgAFFAIJBAAAAA==.Linnanxqlr:BAAALgADCgUJBQAAAA==.Littlebaer:BAAALgAECgYJBgAAAA==.',
Ma='Maki:BAAALgADCgEJAQAAAA==.Manro:BAAALgAFFAMJAwAAAA==.',
Mi='Mins:BAAALgADCgUJBQAAAA==.',
Mo='Mollyradwolf:BAAALgAECgcJBwAAAA==.Moonrift:BAAALgADCgMJAwAAAA==.',
Mz='Mz:BAAALgAECgEJAQAAAA==.',
Ne='Nevermor:BAAALgAECgQJBQAAAA==.',
Nu='Nugget:BAAALgADCgUJBQAAAA==.Nuo:BAABLgAFFH8FAAIDAAIJaBj/QwCbAAADAAIJaBj/QwCbAAAAAA==.',
Ny='Nyxx:BAAALgAECgQJBAAAAA==.',
Pa='Paradisesa:BAAALgADCgQJBAAAAA==.',
Ph='Philein:BAAALgAECgEJAQAAAA==.',
Pi='Picasso:BAABLgAFFH8GAAIHAAMJGyEgIgA2AQAHAAMJGyEgIgA2AQAAAA==.',
Rz='Rzcll:BAAALgAECgYJBgAAAA==.',
Sa='Saberl:BAAALgAECgcJCwAAAA==.Sallyy:BAAALgADCgMJAwAAAA==.',
Sh='Shakuhachi:BAAALgADCgIJAgABLgAECggJEgABAAAAAA==.',
Si='Sinceh:BAAALgAECgYJCgAAAA==.',
So='Souleternal:BAAALgAECgYJCQAAAA==.',
Su='Supercici:BAAALgAECgYJBgAAAA==.Survivor:BAABLgAFFH8HAAIDAAUJxSUPAQA2AgADAAUJxSUPAQA2AgAAAA==.',
Ta='Takedown:BAABLgAFFH8HAAIDAAUJqiO/AQALAgADAAUJqiO/AQALAgAAAA==.',
Th='Thesun:BAAALgAECgEJAQAAAA==.Thunderkeg:BAAALgAECgYJBgAAAA==.',
Ti='Timor:BAAALgAECgEJAQAAAA==.Titan:BAAALgAECgEJAQAAAA==.',
To='Tomori:BAAALgAECgEJAQAAAA==.',
Ur='Urmineyy:BAAALgAECggJBgAAAA==.',
Va='Vail:BAABLgAFFH8NAAIHAAQJsB/OEACPAQAHAAQJsB/OEACPAQAAAA==.Vanitywarlo:BAAALgAFFAIJAgAAAA==.',
['一个']='一个圣骑:BAAALgAECgEJAQAAAA==.',
['一双']='一双灭:BAAALgAECgYJDAAAAA==.',
['一只']='一只球球丶:BAAALgAFFAIJAgAAAA==.',
['一平']='一平:BAAALgAECgEJAQAAAA==.',
['一米']='一米八九:BAAALgAECgYJBgAAAA==.',
['一门']='一门:BAAALgAFFAEJAQAAAA==.',
['一霎']='一霎溟濛:BAAALgADCgcJBAAAAA==.',
['丁丶']='丁丶尼格:BAAALgAECgMJBAAAAA==.',
['七个']='七个小德:BAAALgAECgQJBAAAAA==.',
['七十']='七十八次:BAACLgAFFH8GAAIIAAQJpQmdGQAkAQAIAAQJpQmdGQAkAQAuAAQKfxQAAggABgnJIf1CAAMCAAgABgnJIf1CAAMCAAAA.',
['万圣']='万圣之夜:BAABLgAFFH8FAAIJAAMJ5xErFQAAAQAJAAMJ5xErFQAAAQAAAA==.',
['万花']='万花通灵:BAABLgAFFH8MAAIKAAQJoCIfAACqAQAKAAQJoCIfAACqAQAAAA==.',
['万萬']='万萬沒想到:BAABLgAECn8XAAQGAAgJQxYvIwD2AQAGAAgJQxYvIwD2AQALAAUJbRwlSgBZAQAMAAIJowxpJwBlAAAAAA==.',
['三重']='三重吴彦祖:BAAALgAECgEJBAAAAA==.三重无厌祖:BAAALgADCgEJAQAAAA==.',
['不会']='不会拉怪:BAAALgAECgEJAQAAAA==.',
['不喝']='不喝酒:BAABLgAFFH8LAAIFAAQJ2BmbBwBEAQAFAAQJ2BmbBwBEAQAAAA==.',
['不要']='不要狼人:BAABLgAFFH8JAAINAAMJrB0CDQAWAQANAAMJrB0CDQAWAQAAAA==.',
['专业']='专业掏月工:BAAALgADCgYJBgAAAA==.',
['且趁']='且趁余花:BAABLgAECn8WAAMNAAkJVBqsDwC7AgANAAkJVBqsDwC7AgAOAAcJqRwNIQD0AQAAAA==.',
['世一']='世一克:BAABLgAECn8VAAIDAAgJxyCOMgBtAgADAAgJxyCOMgBtAgAAAA==.',
['东大']='东大熬鹰:BAAALgAECgcJCAAAAA==.',
['丢你']='丢你一蕾姆:BAAALgAECgcJBwAAAA==.',
['丧钟']='丧钟鸣寂寞:BAAALgAECgQJBAAAAA==.',
['丨吴']='丨吴彦祖丨:BAABLgAECn8aAAIPAAgJzBW1GgAsAgAPAAgJzBW1GgAsAgAAAA==.',
['丨天']='丨天兆丨:BAACLgAFFH8GAAIQAAMJKwhhEQC+AAAQAAMJKwhhEQC+AAAuAAQKfyEAAxAACAkREblFAN0BABAACAkREblFAN0BAAQABAkYCdMdAJsAAAAA.',
['丨寳']='丨寳灬貝兒丶:BAAALgADCgQJBAAAAA==.',
['丨小']='丨小欣丨:BAAALgAECgYJBgAAAA==.',
['丨迪']='丨迪妮莎丨:BAABLgAFFH8FAAIIAAIJPBYZFgC0AAAIAAIJPBYZFgC0AAAAAA==.',
['丶多']='丶多喝热水:BAAALgAECgQJCAAAAA==.',
['丶奔']='丶奔放的小鸟:BAAALgAECgEJAQAAAA==.丶奔放的德德:BAAALgAECgMJAwAAAA==.丶奔放的术士:BAAALgAECgUJBQAAAA==.丶奔放的猎手:BAAALgAECgEJAQAAAA==.丶奔放的贝贝:BAAALgADCgMJAwAAAA==.',
['丶逆']='丶逆我者变羊:BAAALgAFFAMJBAAAAA==.',
['丶饼']='丶饼干:BAAALgADCgIJAgAAAA==.',
['为了']='为了连萌:BAAALgADCgcJBwAAAA==.',
['乃嘴']='乃嘴:BAAALgAECgEJAQAAAA==.',
['久仰']='久仰久仰:BAAALgAECgYJBgAAAA==.',
['九八']='九八:BAAALgAECgEJAQAAAA==.',
['九号']='九号半:BAAALgADCgcJBwAAAA==.',
['乱了']='乱了印象:BAAALgADCgEJAQAAAA==.',
['乱柒']='乱柒捌糟:BAABLgAECn8YAAMRAAgJ0hWtCwDTAQARAAgJ0hWtCwDTAQANAAYJXBswVgBQAQAAAA==.',
['了无']='了无痕丶:BAAALgADCgMJAwAAAA==.',
['云之']='云之岚:BAACLgAFFH8GAAMSAAMJNSEvGADQAAASAAIJjiIvGADQAAATAAEJgx5bHwBiAAAuAAQKfxUAAxIABwmlIt0cAD0CABIABwmhHN0cAD0CABMABglNImmGANUAAAEuAAUUBAkGAAcAyx4A.',
['云毓']='云毓:BAAALgAFFAQJBAAAAA==.',
['五眼']='五眼丁真:BAAALgAECgEJAgABLgAFFAQJBQADACARAA==.',
['交射']='交射丶逻辑:BAAALgAECgkJDwAAAA==.',
['人型']='人型魅魔:BAAALgAECggJAgAAAA==.',
['人彘']='人彘:BAAALgADCgQJBAAAAA==.',
['人走']='人走凉茶凉:BAABLgAFFH8FAAILAAMJPh9BDQAHAQALAAMJPh9BDQAHAQAAAA==.人走茶未凉:BAAALgAFFAIJAgAAAA==.',
['今田']='今田美樱:BAACLgAFFH8OAAIHAAUJrBKUCABcAQAHAAUJrBKUCABcAQAuAAQKfx0AAgcABwlAG0FNAE8CAAcABwlAG0FNAE8CAAAA.',
['以光']='以光的名义:BAAALgAECgEJAQAAAA==.',
['伊什']='伊什塔迩:BAAALgAECgYJBgAAAA==.',
['伊厉']='伊厉丹:BAAALgAECgQJBAAAAA==.',
['优昙']='优昙华院:BAAALgAECgcJBwAAAA==.',
['伴夏']='伴夏:BAAALgAECgYJBgAAAA==.',
['似风']='似风逝去:BAAALgAECgQJBQAAAA==.',
['低头']='低头丶浅笑:BAAALgADCgUJBQAAAA==.',
['体力']='体力劳动者:BAAALgAECgEJAQABLgAFFAMJAwABAAAAAA==.',
['依然']='依然在一起:BAAALgAECgYJBgAAAA==.',
['傻傻']='傻傻的帅:BAAALgAECgEJAQAAAA==.',
['光羊']='光羊羊:BAAALgADCgEJAQAAAA==.',
['克伦']='克伦菲尔:BAACLgAFFH8HAAIJAAMJRBcaIACuAAAJAAMJRBcaIACuAAAuAAQKfx4AAwkACAlTJNEQAAkDAAkACAkHJNEQAAkDABQAAQmQJLo2AGgAAAAA.',
['兒童']='兒童乖乖:BAAALgAECgYJCwAAAA==.',
['全身']='全身战火带槽:BAAALgAECgYJEQAAAA==.',
['兮怜']='兮怜:BAAALgAFFAMJAwAAAA==.',
['兰斯']='兰斯洛特丶:BAAALgAECgcJBwAAAA==.',
['兽医']='兽医神:BAAALgAECgYJDwAAAA==.',
['冰天']='冰天雪地丶:BAAALgADCgcJBwAAAA==.',
['冰颜']='冰颜:BAAALgAECgEJAQAAAA==.',
['冷風']='冷風过境:BAAALgAFFAEJAQAAAA==.',
['出云']='出云天花:BAACLgAFFH8JAAIHAAQJThjJFwBrAQAHAAQJThjJFwBrAQAuAAQKfxwAAgcABwmfJfcmANcCAAcABwmfJfcmANcCAAAA.',
['利维']='利维坦夫斯基:BAAALgADCgcJBwAAAA==.',
['剑月']='剑月:BAAALgAECgEJAQAAAA==.',
['劍絲']='劍絲丶無情:BAAALgAECgcJDQAAAA==.',
['力量']='力量的代价:BAABLgAECn8UAAMVAAYJqCDnFwCLAQAIAAUJqCC6TwDZAQAVAAYJahPnFwCLAQAAAA==.',
['加血']='加血加爆你:BAAALgAECgMJAwAAAA==.',
['劣人']='劣人七号:BAABLgAECn8aAAIWAAgJnCF6CQDZAgAWAAgJnCF6CQDZAgAAAA==.',
['北郊']='北郊灬拾玖:BAAALgAECgEJAQAAAA==.',
['十萬']='十萬伏特:BAAALgAECgUJBgAAAA==.',
['千里']='千里:BAAALgAECgQJBAAAAA==.',
['午夜']='午夜凶龙:BAAALgADCgEJAQAAAA==.午夜疯兔:BAAALgADCgEJAgAAAA==.午夜疯熊:BAAALgADCgEJAQAAAA==.',
['南区']='南区黄月光:BAAALgAECgEJAQAAAA==.',
['南征']='南征:BAABLgAECn8eAAIXAAcJDhQ2FQC5AQAXAAcJDhQ2FQC5AQAAAA==.',
['博罗']='博罗米尔之怒:BAAALgAECgQJAwAAAA==.',
['口酱']='口酱:BAAALgAECgMJAwAAAA==.',
['只吃']='只吃牛肉:BAAALgAECgEJAQAAAA==.',
['叫啥']='叫啥呢:BAAALgAECgYJDAAAAA==.',
['叫我']='叫我狼外公:BAACLgAFFH8LAAINAAQJYQ6+BQAfAQANAAQJYQ6+BQAfAQAuAAQKfx4AAg0ACAkmF5clACICAA0ACAkmF5clACICAAAA.',
['可乐']='可乐糖丶:BAAALgADCgEJAQAAAA==.',
['可爱']='可爱小流氓:BAAALgAECgEJAQAAAA==.',
['吃茶']='吃茶:BAAALgAECgcJCgAAAA==.',
['吉安']='吉安娜黑蛋子:BAAALgAECgEJAgAAAA==.',
['吗咪']='吗咪吗咪哄:BAAALgADCgEJAQAAAA==.',
['吗喽']='吗喽大王:BAAALgAFFAEJAgABLgAFFAMJBQALABoWAA==.',
['吹大']='吹大气球:BAAALgAECgUJCQAAAA==.',
['周游']='周游云梦泽:BAAALgAECgEJAQAAAA==.',
['呼嘟']='呼嘟猪:BAAALgADCgMJBAAAAA==.',
['哆啦']='哆啦没有梦:BAABLgAFFH8RAAIJAAQJ5CURAQCbAQAJAAQJ5CURAQCbAQAAAA==.',
['哈宝']='哈宝:BAAALgADCgYJBgAAAA==.',
['哈库']='哈库呐瑪塔塔:BAAALgAECgYJCgAAAA==.',
['哈雷']='哈雷:BAAALgADCgIJAgAAAA==.',
['商略']='商略黄昏雨:BAAALgAFFAEJAQABLgAFFAUJCgAPAKcbAA==.',
['啊哇']='啊哇咪:BAAALgAFFAEJAQABLgAFFAcJBwAWADwVAA==.',
['啊哚']='啊哚哏:BAAALgAECgEJAQAAAA==.',
['喂丶']='喂丶小乌龟:BAAALgAFFAEJAQAAAA==.喂丶小苍蝇:BAAALgAECgkJBQAAAA==.',
['單刷']='單刷幼稚园:BAAALgAECgIJAgAAAA==.',
['喳喳']='喳喳:BAABLgAECn8ZAAIHAAcJvhUNGgB4AQAHAAcJvhUNGgB4AQAAAA==.',
['喵德']='喵德化身:BAAALgAECgQJBQAAAA==.',
['嗳耗']='嗳耗:BAAALgADCgEJAQAAAA==.',
['嗷嗷']='嗷嗷熬嗷嗷:BAAALgADCggJCAAAAA==.',
['嘚瑟']='嘚瑟的一逼:BAAALgAECgYJBgAAAA==.',
['嘛呢']='嘛呢头头:BAABLgAECn8UAAMYAAcJYhlsDgDgAQAYAAcJzhZsDgDgAQATAAIJ0xmILQCiAAAAAA==.',
['嘿丶']='嘿丶孙贼:BAAALgAECgEJAQAAAA==.',
['噗露']='噗露噗露八号:BAABLgAFFH8IAAMZAAQJThBNDgAcAQAZAAQJzwpNDgAcAQAaAAEJUxcAAAAAAAAAAA==.',
['回眸']='回眸圣光:BAAALgADCgYJBgAAAA==.',
['囧安']='囧安:BAAALgAECgYJCAAAAA==.',
['国服']='国服最后希望:BAAALgAECgcJBwAAAA==.国服第一甜:BAAALgAECgMJBgAAAA==.',
['圆蹲']='圆蹲蹲:BAAALgADCgUJBQAAAA==.',
['土豆']='土豆咖喱:BAAALgAECgQJAQAAAA==.',
['圣光']='圣光凹凸曼:BAAALgAECgQJBAAAAA==.圣光复燃:BAAALgAECgEJAQAAAA==.圣光追寻者:BAAALgADCgUJBQAAAA==.',
['圣型']='圣型尤物:BAAALgAFFAMJAwAAAA==.',
['在下']='在下坂本君:BAABLgAFFH8FAAIbAAUJbwgAAAAAAAAQAAUJbwgAAAAAAAAAAA==.',
['地平']='地平线:BAAALgAECgYJBgAAAA==.',
['坤灵']='坤灵:BAAALgAFFAEJAgAAAA==.',
['墓穴']='墓穴之小鬼:BAAALgAFFAIJAwAAAA==.',
['墨晓']='墨晓书:BAAALgAECgEJAQAAAA==.',
['壹健']='壹健钟琴:BAAALgAFFAMJAwAAAA==.',
['夏雪']='夏雪宜:BAAALgAECgYJCQAAAA==.',
['夜店']='夜店天真熊姐:BAABLgAFFH8FAAINAAMJ0wfKEwDKAAANAAMJ0wfKEwDKAAAAAA==.',
['大到']='大到没人要:BAAALgAECgQJBAAAAA==.',
['大壮']='大壮:BAAALgAECgUJBwAAAA==.',
['大意']='大意了没有闪:BAAALgAECgYJBgAAAA==.',
['大村']='大村长:BAABLgAFFH8HAAIcAAQJoxBkBwAaAQAcAAQJoxBkBwAaAQAAAA==.',
['大棒']='大棒肉叔叔:BAAALgAECgcJCAAAAA==.',
['大棕']='大棕狮丶:BAABLgAFFH8HAAIFAAMJ0A89EACaAAAFAAMJ0A89EACaAAAAAA==.',
['大脚']='大脚熊:BAAALgAFFAEJAQAAAA==.',
['大荒']='大荒干饭人:BAAALgADCgEJAQAAAA==.',
['天城']='天城燐音:BAAALgAECgEJAQAAAA==.',
['天生']='天生有个萨满:BAABLgAFFH8LAAILAAQJzBXSAwA5AQALAAQJzBXSAwA5AQABLgAFFAUJBQAdAKQVAA==.',
['契约']='契约噩魔:BAAALgAECgkJCgAAAA==.',
['奔波']='奔波儿霸:BAAALgAECgEJAQAAAA==.',
['奶无']='奶无可奶:BAAALgAECgcJBwAAAA==.',
['奶龙']='奶龙在天:BAAALgADCgcJBwAAAA==.',
['奺妖']='奺妖妖:BAAALgADCgYJBgAAAA==.',
['妖鲸']='妖鲸的尾巴:BAAALgAECgcJAQAAAA==.',
['妞丶']='妞丶难过了:BAAALgAFFAEJAQAAAA==.',
['娅妮']='娅妮丨索菲雅:BAAALgAECgEJAQAAAA==.',
['娴熟']='娴熟德:BAAALgAECgcJBwAAAA==.',
['孤单']='孤单猎手:BAAALgAECgIJAgAAAA==.',
['安塞']='安塞斯塔:BAAALgADCgIJAgAAAA==.',
['安度']='安度因的男宠:BAABLgAECn8YAAIeAAcJ5xVyJADEAQAeAAcJ5xVyJADEAQAAAA==.',
['宾利']='宾利:BAAALgAECgIJAgAAAA==.',
['寂寞']='寂寞右手:BAAALgADCgQJBAAAAA==.',
['富贵']='富贵儿:BAABLgAECn8lAAMGAAgJKR7SCwDcAgAGAAgJKR7SCwDcAgAMAAEJwwS0LgArAAAAAA==.',
['尊尼']='尊尼获加:BAAALgAECgIJAwAAAA==.',
['尊者']='尊者丶鬼:BAAALgAFFAIJAwAAAA==.',
['小君']='小君:BAAALgAFFAEJAQAAAA==.',
['小哲']='小哲老师:BAAALgAECgQJBwAAAA==.',
['小嫩']='小嫩薩:BAAALgAFFAEJAQAAAA==.',
['小宝']='小宝贝:BAAALgAECgYJCgAAAA==.',
['小小']='小小圣:BAABLgAFFH8FAAIJAAMJaQuZFwDxAAAJAAMJaQuZFwDxAAAAAA==.小小骑士:BAAALgADCgQJBAAAAA==.小小龙:BAAALgADCgIJAgAAAA==.',
['小球']='小球球丶:BAAALgAECgQJBQABLgAFFAIJAgABAAAAAA==.',
['小甜']='小甜猪:BAAALgADCgQJBAAAAA==.',
['小白']='小白狼:BAAALgADCgUJCAAAAA==.',
['小谢']='小谢同学丶:BAAALgAFFAIJAgAAAA==.',
['小马']='小马快跑:BAAALgAECgQJBQAAAA==.',
['小黑']='小黑二:BAAALgAFFAEJAQABLgAFFAMJAwABAAAAAA==.',
['尐白']='尐白一只:BAAALgAFFAIJAwAAAA==.',
['尒魚']='尒魚:BAABLgAFFH8FAAITAAMJ4w6ODQDwAAATAAMJ4w6ODQDwAAAAAA==.',
['尤里']='尤里西斯:BAAALgAECgYJDAAAAA==.',
['尼赛']='尼赛亚:BAAALgAFFAEJAgAAAA==.',
['崎岖']='崎岖珊:BAAALgAECgYJBwAAAA==.',
['左手']='左手之殇:BAAALgADCgUJBQAAAA==.左手的肖邦:BAAALgAECgYJCAAAAA==.',
['巧克']='巧克力星锦:BAAALgAECgEJAQAAAA==.巧克力花花牛:BAAALgAECgMJBAAAAA==.',
['巴基']='巴基的鸡:BAAALgAECgYJCAAAAA==.',
['巴迪']='巴迪斯图塔:BAAALgAECgEJAQAAAA==.',
['布吉']='布吉岛:BAAALgAECgYJCwAAAA==.',
['布莱']='布莱恩丶铜包:BAAALgAECgQJBQAAAA==.',
['布鲁']='布鲁斯韦恩:BAAALgADCgUJBQAAAA==.',
['帅哥']='帅哥:BAABLgAFFH8GAAITAAMJPSMkCAAiAQATAAMJPSMkCAAiAQAAAA==.',
['希优']='希优顿的信念:BAAALgAECgMJAwAAAA==.',
['希尔']='希尔佤那斯:BAABLgAFFH8FAAIQAAMJpBCvGwD1AAAQAAMJpBCvGwD1AAAAAA==.',
['帕帕']='帕帕:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影沁血:BAAALgAECgcJBwABLgAFFAUJCQAeANcWAA==.',
['幽冥']='幽冥雨师:BAABLgAECn8YAAIHAAYJnRrejAC5AQAHAAYJnRrejAC5AQAAAA==.',
['康桥']='康桥之风:BAAALgAECgYJCwAAAA==.康桥双子星:BAABLgAECn8XAAITAAcJtB02HABdAgATAAcJtB02HABdAgAAAA==.康桥萨满:BAABLgAECn8YAAILAAcJQxNFOAChAQALAAcJQxNFOAChAQAAAA==.康桥骑士:BAAALgAECgMJAwAAAA==.康桥魔女:BAAALgAECgYJDwAAAA==.',
['开天']='开天老祖:BAAALgAECgkJCQAAAA==.',
['开心']='开心的马骝:BAAALgAECgEJAgAAAA==.',
['弎哥']='弎哥:BAAALgAECgEJAgAAAA==.',
['弑夜']='弑夜:BAAALgAECgEJAQAAAA==.',
['弑魂']='弑魂丶超哥:BAAALgAECgkJBwAAAA==.',
['弓虽']='弓虽哥:BAAALgAECgYJBgAAAA==.',
['张国']='张国大猩猩:BAAALgAECgkJCAABLgAFFAUJCQAVANghAA==.',
['弥赛']='弥赛亚丶月:BAAALgAECgIJAgABLgAFFAEJAgABAAAAAA==.',
['弯角']='弯角:BAAALgAECgEJAQAAAA==.',
['强大']='强大的白:BAAALgAECgIJAgAAAA==.',
['归零']='归零:BAAALgAECgEJAQAAAA==.',
['影踪']='影踪丶雷掌:BAAALgAECgcJDQAAAA==.',
['徐汐']='徐汐的汐:BAAALgAECgYJBgAAAA==.',
['微笑']='微笑很美:BAACLgAFFH8HAAIJAAMJkBhVEQAbAQAJAAMJkBhVEQAbAQAuAAQKfxoAAgkABwl8H4AyAFgCAAkABwl8H4AyAFgCAAAA.',
['德嘚']='德嘚得:BAAALgAFFAMJAwAAAA==.',
['心动']='心动男孩:BAAALgAECgEJAwAAAA==.',
['心葬']='心葬:BAAALgADCgcJBwAAAA==.',
['忍鸟']='忍鸟爆熊:BAAALgADCgUJBQAAAA==.',
['忘詞']='忘詞:BAAALgAECgYJCwAAAA==.',
['快乐']='快乐的小二畀:BAAALgAECgEJAQAAAA==.',
['性魔']='性魔:BAAALgAECgcJBwAAAA==.',
['总是']='总是变来变去:BAAALgAECgYJCgAAAA==.',
['恐虐']='恐虐神选:BAAALgAECgUJAgAAAA==.',
['恣意']='恣意妄为:BAAALgAECgMJAwAAAA==.',
['悖论']='悖论:BAAALgAECgUJBQAAAA==.',
['悟通']='悟通魔神:BAAALgAECgEJAQAAAA==.',
['悠悠']='悠悠筱爱:BAAALgAECgIJAwAAAA==.',
['愁月']='愁月仙子:BAABLgAECn8eAAIfAAcJ2Rd4CgBHAQAfAAcJ2Rd4CgBHAQAAAA==.',
['慊罹']='慊罹:BAAALgADCgEJAQABLgAFFAMJBQAIADsYAA==.',
['慢热']='慢热:BAAALgAECgIJAgAAAA==.',
['憶剣']='憶剣情殇:BAAALgADCgEJAQAAAA==.',
['懂夜']='懂夜夜:BAABLgAFFH8GAAMOAAQJUwAuEwCqAAAOAAQJUwAuEwCqAAANAAIJOQo3HQCIAAAAAA==.',
['懂斯']='懂斯斯:BAAALgAECgEJAQAAAA==.',
['戏琺']='戏琺師:BAAALgADCgMJAwAAAA==.',
['我不']='我不丶:BAAALgAECgQJBAAAAA==.',
['我又']='我又来了:BAAALgAECgYJEAAAAA==.',
['我来']='我来奶国足:BAABLgAFFH8GAAMeAAIJhBA+EwBLAAAeAAIJhBA+EwBLAAAgAAEJRAPGGwA/AAAAAA==.',
['战鸽']='战鸽氏足:BAAALgAFFAIJAwAAAA==.',
['打个']='打个锤子:BAAALgADCgEJAQAAAA==.',
['打洪']='打洪水:BAAALgADCgEJAQAAAA==.',
['把鑫']='把鑫涛给你:BAAALgAECgYJCAAAAA==.',
['抓兔']='抓兔子的狮子:BAAALgAFFAEJAgAAAA==.',
['折断']='折断的竹光:BAAALgAECgYJBgAAAA==.',
['拉克']='拉克里玛:BAABLgAFFH8NAAMDAAUJXyYbAQAyAgADAAUJXyYbAQAyAgAhAAEJbh5BAgBeAAAAAA==.',
['拓海']='拓海丶:BAAALgAECgMJAwAAAA==.',
['拾月']='拾月:BAAALgAECgQJBAAAAA==.',
['挖掉']='挖掉眼睛卖萌:BAAALgAECgYJDQAAAA==.',
['插地']='插地小神通:BAAALgADCgUJBQAAAA==.',
['摺紙']='摺紙黃昏:BAAALgAFFAUJBAAAAA==.',
['攒眉']='攒眉向月:BAAALgAECgUJBQAAAA==.',
['放光']='放光的:BAAALgAECgMJAwAAAA==.',
['敗天']='敗天:BAAALgAECgEJAQAAAA==.',
['斩啥']='斩啥:BAABLgAFFH8FAAIiAAMJHBYHGQClAAAiAAMJHBYHGQClAAAAAA==.',
['旅法']='旅法者:BAAALgAECgEJAQAAAA==.',
['无为']='无为小人儒:BAAALgAECgUJBQAAAA==.',
['无尽']='无尽幻光:BAAALgAFFAEJAgAAAA==.',
['早干']='早干嘛去了:BAAALgAECgcJBwAAAA==.',
['时簪']='时簪姆:BAAALgAECgUJBgAAAA==.',
['时间']='时间快进暂停:BAAALgAECgYJCwAAAA==.时间飞逝:BAAALgAECgYJCwAAAA==.',
['星噬']='星噬:BAAALgAECgQJBwAAAA==.',
['星塵']='星塵回憶:BAABLgAECn8XAAIjAAYJHiOvBADRAQAjAAYJHiOvBADRAQAAAA==.',
['星岚']='星岚:BAAALgAECgEJAQAAAA==.',
['星界']='星界转移:BAAALgAECgMJAwABLgAECgcJBwABAAAAAA==.',
['春酌']='春酌:BAAALgAECgYJBgAAAA==.',
['晚美']='晚美:BAAALgAECgYJCAAAAA==.',
['晚风']='晚风:BAAALgAECgYJCgAAAA==.',
['晨云']='晨云:BAAALgAECgYJDAAAAA==.',
['景离']='景离悠哉:BAAALgAECgEJAQAAAA==.',
['暮星']='暮星之瞳:BAAALgAECgQJBAAAAA==.',
['暴怒']='暴怒的野兽:BAABLgAFFH8FAAINAAIJBh6zFQC1AAANAAIJBh6zFQC1AAAAAA==.',
['暴走']='暴走的小巴基:BAAALgAECgYJBgAAAA==.',
['曾经']='曾经也是超哥:BAAALgAECgYJEAAAAA==.',
['月下']='月下刹那:BAAALgAFFAIJBAAAAA==.',
['月丶']='月丶蚀:BAAALgAECgYJCwAAAA==.',
['月光']='月光妹:BAAALgAECgcJBwAAAA==.',
['月巴']='月巴仔:BAAALgAFFAIJAwAAAA==.',
['月舞']='月舞嫣然:BAABLgAECn8bAAMWAAgJ5BhHHAAzAgAWAAgJ5BhHHAAzAgAJAAIJGgIdKQFOAAAAAA==.',
['月迷']='月迷津渡:BAAALgAECgYJBgAAAA==.',
['木子']='木子太白:BAAALgAECgEJAQAAAA==.',
['木枼']='木枼精灵:BAAALgAECgEJAQAAAA==.',
['未竟']='未竟之诗丶:BAAALgAECgQJBQAAAA==.',
['未见']='未见花开:BAAALgAECgYJBgAAAA==.',
['术神']='术神:BAAALgAECgYJEAAAAA==.',
['朵朵']='朵朵芸儿:BAABLgAECn8cAAMCAAgJ1Rd4EwA5AgACAAgJ1Rd4EwA5AgAQAAYJdwgAsACrAAAAAA==.',
['杀手']='杀手不问出处:BAAALgAECgEJAQAAAA==.',
['杉田']='杉田智和:BAAALgAECgIJAgAAAA==.',
['李撇']='李撇希:BAAALgAECgUJBwAAAA==.',
['来年']='来年花开时:BAAALgAECgEJAQAAAA==.',
['来跟']='来跟大苏:BAAALgAECgYJDQAAAA==.',
['松松']='松松:BAACLgAFFH8IAAIHAAIJHwegHgCWAAAHAAIJHwegHgCWAAAuAAQKfxQAAgcABwkaG8lcACQCAAcABwkaG8lcACQCAAAA.',
['果厨']='果厨保护协会:BAAALgAFFAQJBAAAAA==.',
['枫华']='枫华绝代:BAAALgAECgUJBQAAAA==.',
['枫红']='枫红向晚:BAABLgAECn8fAAIiAAgJ0R5QEADPAgAiAAgJ0R5QEADPAgAAAA==.',
['柚子']='柚子汁:BAAALgAFFAIJAgAAAA==.',
['柠檬']='柠檬尐贱:BAAALgAECgYJBgAAAA==.柠檬百香果:BAAALgAFFAEJAwAAAA==.',
['核丨']='核丨酸检测:BAAALgADCgUJBQAAAA==.核丨酸采样:BAAALgADCgEJAQAAAA==.',
['梆梆']='梆梆就两拳:BAAALgADCgYJCQAAAA==.',
['椒盐']='椒盐提拉米苏:BAAALgAECgEJAQAAAA==.',
['椿殇']='椿殇:BAAALgAECgIJAgAAAA==.',
['楯楯']='楯楯:BAAALgAECgEJAQAAAA==.',
['楼兰']='楼兰两伍洞肆:BAAALgAECggJDQAAAA==.',
['樱花']='樱花羽:BAABLgAECn8ZAAMSAAgJfRcNIgASAgASAAgJAxUNIgASAgATAAIJyhjluQBPAAABLgAECgkJBgABAAAAAA==.',
['欧莱']='欧莱雅:BAAALgAECgYJCQAAAA==.',
['正经']='正经牛:BAAALgAECgYJBgAAAA==.',
['毛毛']='毛毛虫:BAABLgAFFH8FAAMkAAMJzAlEBAD0AAAkAAMJzAlEBAD0AAAXAAIJdwJLBgBvAAAAAA==.',
['水果']='水果圈真乱:BAAALgAECgUJBgAAAA==.',
['沐芸']='沐芸:BAAALgAECgcJBwAAAA==.',
['沙漠']='沙漠的天空:BAAALgADCgIJAgAAAA==.',
['沸洋']='沸洋洋:BAAALgAECgYJDQAAAA==.',
['法批']='法批疯:BAAALgAFFAIJAwAAAA==.',
['泥娃']='泥娃娃:BAAALgAECgIJBAAAAA==.',
['洪都']='洪都拉斯:BAAALgAECgYJAgAAAA==.',
['活化']='活化烈焰:BAAALgAECgIJAQABLgAECgcJBwABAAAAAA==.',
['流年']='流年一似水:BAAALgADCgYJBgAAAA==.',
['流氓']='流氓咕丶:BAAALgAECgYJCgAAAA==.流氓鸽丶:BAABLgAECn8cAAIfAAgJFw0pMwCEAQAfAAgJFw0pMwCEAQAAAA==.',
['浅蓝']='浅蓝:BAAALgAECgUJBQAAAA==.',
['浮生']='浮生萧条:BAAALgAECgEJAQAAAA==.',
['涛行']='涛行天下:BAAALgAECgIJAgAAAA==.',
['涤烦']='涤烦子:BAAALgAFFAMJAwAAAA==.',
['淡泊']='淡泊丶野:BAAALgAFFAMJAwAAAA==.',
['深海']='深海长空:BAAALgADCgUJBQAAAA==.',
['深邃']='深邃夜空:BAABLgAFFH8GAAIJAAMJWhxICAAMAQAJAAMJWhxICAAMAQAAAA==.',
['混乱']='混乱之祭灬:BAABLgAFFH8HAAIIAAIJriU3JwDgAAAIAAIJriU3JwDgAAAAAA==.',
['淺白']='淺白战战果酱:BAAALgAECgEJAgAAAA==.',
['清古']='清古寺:BAABLgAECn8eAAMgAAYJWxq6GQDLAQAgAAYJWxq6GQDLAQAeAAYJuwkLSAAZAQAAAA==.',
['清城']='清城雪影:BAAALgAECgcJDgAAAA==.',
['清水']='清水幽萍:BAAALgAECgYJBgAAAA==.',
['清雪']='清雪飘落:BAAALgAECgIJAgAAAA==.',
['清风']='清风澈羽:BAAALgAFFAEJAgAAAA==.',
['游戏']='游戏世界:BAAALgAECgYJBgAAAA==.',
['滇东']='滇东老表:BAAALgAECgIJBAAAAA==.',
['滚来']='滚来滚去:BAAALgAECgUJBQAAAA==.',
['漏你']='漏你吧胡子:BAAALgAECgUJCAAAAA==.',
['潘帕']='潘帕斯射鲸:BAAALgADCgEJAQAAAA==.',
['潘德']='潘德拉塔萨:BAAALgAFFAIJAgAAAA==.',
['潘达']='潘达奶糖:BAAALgAFFAIJAwAAAA==.',
['澹静']='澹静是一:BAAALgADCgYJBgAAAA==.',
['灬妞']='灬妞妞灬:BAAALgADCgEJAQAAAA==.',
['灬流']='灬流砂灬:BAAALgADCgEJAQAAAA==.',
['灰燼']='灰燼丶無情:BAABLgAECn8YAAIJAAcJKBSRZgCzAQAJAAcJKBSRZgCzAQAAAA==.',
['烧肉']='烧肉:BAABLgAFFH8KAAMSAAMJmSPyAwDTAAASAAIJtyTyAwDTAAATAAEJXCGyEQBpAAAAAA==.烧肉肉:BAAALgAECgQJBwAAAA==.',
['烧麦']='烧麦灬:BAAALgAECgQJBgAAAA==.',
['热德']='热德热布德:BAAALgAECgcJBgAAAA==.',
['熊猫']='熊猫白木耳:BAAALgAFFAEJAQAAAA==.',
['熬熬']='熬熬嗷嗷:BAAALgADCgIJAgAAAA==.',
['熵能']='熵能小绵羊:BAAALgAECgYJEgAAAA==.',
['爱上']='爱上朱哒哒:BAAALgAECgYJAgAAAA==.',
['爱心']='爱心攻击:BAAALgAECgYJBgAAAA==.',
['爱意']='爱意随枫起:BAABLgAFFH8EAAMTAAIJpR34CwC5AAASAAIJKBp5GQC6AAATAAIJ+Bj4CwC5AAAAAA==.',
['牛皮']='牛皮术:BAACLgAFFH8JAAIIAAMJOBgbDgADAQAIAAMJOBgbDgADAQAuAAQKfxYAAggACAlsIO8YAL8CAAgACAlsIO8YAL8CAAAA.',
['牛虻']='牛虻飞:BAAALgAFFAEJAQAAAA==.',
['牧丶']='牧丶牧:BAABLgAECn8VAAIOAAcJPSLbDADLAgAOAAcJPSLbDADLAgAAAA==.',
['牧牧']='牧牧:BAABLgAECn8UAAMFAAkJgh1wBwDiAgAFAAkJgh1wBwDiAgAfAAEJAAAAAAAAAAAAAA==.牧牧丶:BAAALgAECgcJBQAAAA==.牧牧的复仇者:BAAALgAECgkJDQAAAA==.牧牧的守护者:BAAALgAECggJBAAAAA==.牧牧的幻魔师:BAABLgAECn8WAAIHAAkJWR2KEwAzAwAHAAkJWR2KEwAzAwABLgAFFAcJHAAHAKwbAA==.牧牧的援护者:BAAALgAECgcJCAAAAA==.牧牧的放逐者:BAAALgAECgQJAwAAAA==.牧牧的毁灭者:BAABLgAECn8XAAIDAAkJ3SHfBgBrAwADAAkJ3SHfBgBrAwABLgAFFAYJEAADAC0hAA==.牧牧的泡泡龙:BAAALgAECgcJCAABLgAFFAUJEgALAFohAA==.',
['犹达']='犹达丶奥凯:BAAALgAFFAIJAwAAAA==.',
['狐狸']='狐狸桐:BAAALgAECgUJBQAAAA==.',
['独奏']='独奏夜:BAABLgAECn8cAAQjAAgJlBz0FgAuAgAjAAgJlBz0FgAuAgAgAAcJLhqTFQD6AQAeAAIJYgsvcgBeAAAAAA==.',
['狸花']='狸花花:BAAALgAECgQJAwAAAA==.',
['狼头']='狼头男:BAAALgAECgEJAQAAAA==.',
['猪肉']='猪肉炖粉条:BAAALgAECgIJAQAAAA==.',
['猫主']='猫主任:BAAALgAECgkJAQAAAA==.',
['猫哥']='猫哥的世界:BAAALgAECgUJAgAAAA==.猫哥的眼睛:BAAALgAECgMJAwAAAA==.',
['献祭']='献祭光环:BAAALgAECgcJBwAAAA==.',
['獨行']='獨行臭熊:BAAALgAECgYJBgAAAA==.',
['王宝']='王宝强力胶:BAACLgAFFH8GAAIcAAIJkg/9DgB5AAAcAAIJkg/9DgB5AAAuAAQKfyIAAxwABglEH68SAOIBABwABglEH68SAOIBAAMAAQnyA+IzASQAAAAA.',
['玖玖']='玖玖:BAAALgAECgIJAgAAAA==.',
['玛薇']='玛薇怒风:BAAALgAECgYJCgAAAA==.',
['玫瑰']='玫瑰的余香:BAAALgADCgYJBgAAAA==.玫瑰静静开:BAAALgAECgEJAQAAAA==.',
['玫菲']='玫菲尔:BAAALgAECgUJBQAAAA==.',
['由南']='由南至北丨:BAAALgAECgEJAgAAAA==.',
['男颜']='男颜汁饮:BAAALgADCgYJBgAAAA==.',
['疯狂']='疯狂的龙:BAAALgADCgMJAwAAAA==.疯狂石头:BAAALgAECgYJCAAAAA==.',
['痊愈']='痊愈:BAAALgAFFAIJAgAAAA==.',
['痕烬']='痕烬:BAABLgAFFH8HAAIJAAMJ+xjUEwAIAQAJAAMJ+xjUEwAIAQAAAA==.',
['瘋小']='瘋小哈:BAAALgAECgQJCQAAAA==.',
['百香']='百香果欧蕾:BAAALgAFFAEJAQAAAA==.',
['皎洁']='皎洁明月:BAAALgAECgEJAQAAAA==.',
['皓月']='皓月影影:BAACLgAFFH8GAAMjAAQJhAvNEgBfAAAjAAQJhAvNEgBfAAAeAAEJshQvFABDAAAuAAQKfxgAAyMABwnHEscgANIBACMABwnHEscgANIBAB4ABgmRDH1EACcBAAEuAAUUBQkNACAAqiMA.',
['真影']='真影:BAAALgAECgMJBAAAAA==.',
['真浩']='真浩:BAAALgAFFAEJAQAAAA==.',
['真香']='真香警告:BAAALgAFFAUJAwAAAA==.',
['睡喏']='睡喏喏的喵酱:BAABLgAECn8bAAIDAAgJqhjXNQBfAgADAAgJqhjXNQBfAgAAAA==.',
['知天']='知天在水:BAAALgAFFAMJBAAAAA==.',
['短腿']='短腿萝莉:BAAALgAECgEJAQAAAA==.',
['神樂']='神樂:BAAALgAECgQJBgAAAA==.',
['神隐']='神隐大熊猫:BAAALgAECgEJAQAAAA==.',
['秋洛']='秋洛颜溪:BAAALgAECgkJCQAAAA==.',
['秋颜']='秋颜:BAAALgAECgQJAQAAAA==.',
['空唱']='空唱挽歌:BAAALgAECgkJCQAAAA==.',
['空灵']='空灵泉:BAAALgADCgEJAQAAAA==.',
['筋肉']='筋肉小奶咕:BAABLgAECn8eAAQKAAcJuxtJAgC+AQAKAAcJuxtJAgC+AQANAAYJmxCYXAA8AQAOAAEJ0hPTgQAuAAAAAA==.',
['简单']='简单猪猪:BAAALgAECgQJBwAAAA==.',
['米兰']='米兰一九八三:BAAALgAFFAEJAQAAAA==.',
['粉粉']='粉粉的棉花糖:BAAALgAECgYJBwAAAA==.',
['粥粥']='粥粥:BAAALgAECgYJBgAAAA==.',
['糖葫']='糖葫芦头:BAABLgAECn8XAAQFAAkJDhxfCQC9AgAFAAgJih1fCQC9AgAlAAcJdBWUJgCjAQAfAAEJuxscgABJAAABLgAFFAQJAQABAAAAAA==.',
['糨糊']='糨糊術士:BAAALgADCgIJAwAAAA==.',
['紫缘']='紫缘宝宝:BAABLgAECn8UAAMTAAYJFBT4ZAA4AQAYAAYJkAyBGABGAQATAAYJChL4ZAA4AQAAAA==.',
['紫芊']='紫芊:BAAALgAECgUJDgAAAA==.',
['紫荆']='紫荆花之怒:BAAALgAFFAEJAQAAAA==.',
['红尘']='红尘輪回:BAAALgAECgYJBgAAAA==.',
['红河']='红河传说:BAABLgAFFH8HAAIJAAIJoxkNIwCmAAAJAAIJoxkNIwCmAAAAAA==.',
['红烧']='红烧大米饼:BAAALgAECgEJAwAAAA==.',
['纵月']='纵月:BAAALgAECggJCQAAAA==.',
['纸壳']='纸壳猫:BAAALgADCgcJBwAAAA==.',
['纾妍']='纾妍宝宝:BAABLgAFFH8FAAIDAAMJehQwQACgAAADAAMJehQwQACgAAAAAA==.',
['结城']='结城乀星娅:BAABLgAECn8NAAIHAAYJUyE/GACEAQAHAAYJUyE/GACEAQAAAA==.',
['罗纳']='罗纳德:BAABLgAECn8YAAIXAAYJvh0BFADMAQAXAAYJvh0BFADMAQAAAA==.',
['耙耙']='耙耙柑:BAAALgAECgIJBQAAAA==.',
['聪明']='聪明眼袋:BAAALgAFFAEJAQABLgAFFAMJBwAJAJAYAA==.',
['肉山']='肉山大魔王:BAAALgAECgYJCAAAAA==.',
['肥仔']='肥仔:BAAALgAECgQJBgAAAA==.肥仔猫:BAAALgAFFAIJAgAAAA==.',
['肥美']='肥美香饭饭:BAAALgAECgcJEQAAAA==.',
['背叛']='背叛者罗恩:BAAALgAECgYJBgAAAA==.',
['胖纸']='胖纸:BAABLgAECn8WAAIHAAgJXR/uQgBvAgAHAAgJXR/uQgBvAgAAAA==.',
['胡桃']='胡桃有危险了:BAAALgAECgYJBQAAAA==.胡桃龙:BAAALgAECgIJAgAAAA==.',
['脱摸']='脱摸哒基:BAAALgADCgYJBgAAAA==.',
['臧卫']='臧卫瑞丰:BAAALgADCgYJBgAAAA==.',
['自我']='自我素:BAABLgAFFH8IAAIDAAQJ/CYFAwDYAQADAAQJ/CYFAwDYAQAAAA==.',
['自爆']='自爆彩虹:BAAALgAECgUJBQAAAA==.',
['艾尔']='艾尔玛娜:BAACLgAFFH8FAAQSAAMJihLHGwCnAAASAAIJtRXHGwCnAAATAAEJNQz7IgBaAAAYAAIJWAgAAAAAAAAuAAQKfxgAAxIACAmgF4QeAC8CABIACAmhFoQeAC8CABgABAmrEhggAN8AAAAA.',
['艾虂']='艾虂蒽灬晨歌:BAAALgAFFAIJAgAAAA==.',
['芈法']='芈法:BAAALgAECgQJBAAAAA==.',
['芋泥']='芋泥波波:BAAALgAECgUJBQABLgAFFAMJBwAFANAPAA==.',
['花影']='花影:BAAALgAECgUJCwAAAA==.',
['花自']='花自飘零:BAAALgAECgkJCQAAAA==.',
['花蝎']='花蝎:BAAALgADCgUJBQAAAA==.',
['若能']='若能触及群星:BAABLgAFFH8WAAMDAAYJ2SbsAABGAgADAAYJ2SbsAABGAgAhAAEJ2iYVAwB3AAAAAA==.',
['若雲']='若雲:BAAALgADCgYJBgAAAA==.',
['英普']='英普睿思:BAAALgAFFAEJAQAAAA==.',
['草莓']='草莓泡芙丶:BAABLgAFFH8IAAIDAAIJ7hfpOwClAAADAAIJ7hfpOwClAAAAAA==.',
['莫无']='莫无命:BAAALgAECgYJCAAAAA==.莫无言:BAAALgAECgQJBAAAAA==.',
['莹尘']='莹尘:BAABLgAFFH8GAAIFAAIJjgm0CQB1AAAFAAIJjgm0CQB1AAAAAA==.莹尘的骑士:BAAALgAECgIJBAAAAA==.',
['菊起']='菊起:BAAALgAECgEJAQAAAA==.',
['菜嬢']='菜嬢嬢:BAAALgAECgMJBAAAAA==.',
['菜孃']='菜孃孃:BAAALgAECgUJBQAAAA==.',
['萌丶']='萌丶小兮:BAAALgAECgQJBAAAAA==.',
['萌熙']='萌熙熙:BAAALgAECgEJAQAAAA==.',
['萧如']='萧如瑟:BAAALgAECgYJBwAAAA==.',
['萨莱']='萨莱茵丨亡语:BAAALgAECgEJAQAAAA==.',
['萱恩']='萱恩娜:BAAALgAECgIJAgAAAA==.',
['落水']='落水丶無情:BAAALgAECgEJAgABLgAFFAUJBwAHAMcZAA==.',
['葬心']='葬心:BAABLgAECn8eAAIeAAcJah7cAgAxAgAeAAcJah7cAgAxAgAAAA==.',
['蓝芯']='蓝芯之沫:BAAALgAECgQJBAAAAA==.',
['薄葬']='薄葬株洲牧:BAAALgAECgYJCwAAAA==.',
['虎斑']='虎斑小妞:BAAALgAECgYJBgAAAA==.',
['虚空']='虚空精灵猎:BAAALgADCgEJAQAAAA==.',
['蛋蛋']='蛋蛋森林二:BAAALgAECgQJBAAAAA==.',
['蟲且']='蟲且:BAAALgAECgEJAQAAAA==.',
['血之']='血之战:BAAALgAFFAEJAgAAAA==.',
['衔枝']='衔枝者赞诗:BAABLgAFFH8NAAIDAAUJfyUoAQAuAgADAAUJfyUoAQAuAgAAAA==.',
['裴钱']='裴钱:BAAALgAECgcJBAAAAA==.',
['西多']='西多利亚:BAAALgAECgUJCQAAAA==.',
['許個']='許個心願:BAAALgAECgYJBwAAAA==.',
['许个']='许个訫愿:BAAALgAECgcJEgAAAA==.',
['说矮']='说矮就急眼:BAAALgADCgEJAQAAAA==.',
['谁的']='谁的心忘了收:BAAALgAFFAMJAwAAAA==.',
['豆蛋']='豆蛋宝:BAAALgADCgEJAQAAAA==.',
['贝壳']='贝壳:BAAALgAFFAEJAgAAAA==.',
['贰月']='贰月拾玖:BAABLgAECn8cAAMmAAgJ4iCmAgAWAgAHAAgJpx9WOgCNAgAmAAYJ/R6mAgAWAgAAAA==.',
['赤红']='赤红英短喵:BAABLgAECn8VAAIDAAkJfSGTBQB8AwADAAkJfSGTBQB8AwAAAA==.',
['走濄']='走濄杺誶:BAAALgAECgUJBQAAAA==.',
['超级']='超级赛娅喵:BAAALgAFFAIJAgAAAA==.',
['越来']='越来越强:BAAALgADCgcJBwAAAA==.',
['跳来']='跳来跳去:BAAALgAECgEJAgAAAA==.',
['跳起']='跳起旋风斩:BAAALgAECgMJAwAAAA==.',
['轻轻']='轻轻河边树:BAAALgAECgQJBQAAAA==.',
['辽北']='辽北彪子:BAAALgADCgUJBQAAAA==.',
['还魂']='还魂酒:BAAALgAECgcJCgAAAA==.',
['进击']='进击的榴莲:BAAALgAECgEJAQAAAA==.',
['远野']='远野月明:BAAALgAECgcJBwAAAA==.',
['迪卡']='迪卡侬那:BAAALgAECgQJAwAAAA==.',
['迷乱']='迷乱清风:BAAALgAECgIJAgAAAA==.',
['逝川']='逝川流光:BAACLgAFFH8RAAQaAAYJ+BtMAAD6AQAaAAUJQSBMAAD6AQAnAAMJthesDAAbAQAZAAEJlA8YIQBOAAAuAAQKfyEABBkACAkTJeoKAMcCABkABwl9IuoKAMcCABoABwmfHVQIAF8CACcABwkDGVgUAAACAAAA.',
['遥遥']='遥遥地夜空:BAAALgADCgYJBgAAAA==.',
['邱淑']='邱淑贞十八岁:BAAALgAECgYJBgAAAA==.',
['酒伈']='酒伈巧克力:BAAALgAFFAIJBAAAAA==.',
['醉梦']='醉梦千年:BAAALgAECgcJBwAAAA==.',
['醉里']='醉里梦星河:BAABLgAFFH8HAAInAAUJcQQhCABoAQAnAAUJcQQhCABoAQAAAA==.',
['金翅']='金翅威鹏:BAABLgAECn8VAAIIAAgJ+hdEPQAXAgAIAAgJ+hdEPQAXAgAAAA==.',
['钢铁']='钢铁兽:BAAALgAECgEJAQAAAA==.',
['钣磚']='钣磚:BAAALgAECgIJAgAAAA==.',
['铁棍']='铁棍肉山药:BAAALgAECgYJBQABLgAFFAQJBQATAIMMAA==.',
['铃木']='铃木乃:BAAALgAECgYJCwAAAA==.',
['银行']='银行总裁:BAAALgAECgYJCQAAAA==.',
['长衫']='长衫照紫龙:BAAALgADCgYJCwAAAA==.',
['闷油']='闷油瓶子:BAAALgAECgEJAQAAAA==.',
['阮梅']='阮梅:BAAALgADCgUJBQAAAA==.',
['阳关']='阳关噶啊:BAAALgADCgYJAgAAAA==.',
['阿基']='阿基米德丶:BAAALgADCgQJBAAAAA==.',
['阿尔']='阿尔纹的绝望:BAAALgAECgEJAQAAAA==.',
['阿瑞']='阿瑞阿尼:BAAALgAECgQJAQAAAA==.',
['阿西']='阿西吧吧:BAAALgAFFAEJAQAAAA==.',
['除魔']='除魔者罗恩:BAAALgAECgEJAQAAAA==.',
['随风']='随风幻想:BAAALgAECgMJAQAAAA==.',
['雪中']='雪中的玫瑰:BAAALgADCgQJBQAAAA==.',
['雪酪']='雪酪芝士抹茶:BAAALgADCgUJBQAAAA==.',
['雷奥']='雷奥玛里塔萨:BAABLgAFFH8FAAIZAAMJyAQIFQDEAAAZAAMJyAQIFQDEAAAAAA==.',
['雷葛']='雷葛:BAAALgAFFAMJAwAAAA==.',
['霜寒']='霜寒十四:BAAALgAFFAEJAQAAAA==.',
['韩老']='韩老魔韩立:BAAALgAECgIJAgAAAA==.',
['風吹']='風吹菊花開:BAABLgAFFH8JAAMDAAMJnyRSFwBHAQADAAMJnyRSFwBHAQAhAAIJzRFpAgC1AAAAAA==.',
['风之']='风之兴:BAAALgAECgYJBgAAAA==.风之诚:BAAALgAECgcJBwAAAA==.',
['风云']='风云霜雪雨:BAAALgAECgYJBwAAAA==.',
['风亦']='风亦雨:BAAALgAECgcJBgAAAA==.',
['风吉']='风吉:BAABLgAFFH8FAAIfAAMJcx3dDgAMAQAfAAMJcx3dDgAMAQAAAA==.',
['风吹']='风吹淡淡冷:BAAALgAECgMJAwAAAA==.',
['风月']='风月小雪:BAACLgAFFH8FAAIeAAIJ4wpODgCLAAAeAAIJ4wpODgCLAAAuAAQKfxYAAh4ABgmGFtkyAHQBAB4ABgmGFtkyAHQBAAAA.',
['风雪']='风雪的缩影:BAAALgADCgIJAgAAAA==.',
['飞鸿']='飞鸿雪泥:BAAALgAECgQJAwABLgAFFAMJAwABAAAAAA==.',
['香辣']='香辣烤翅:BAAALgAFFAIJAgAAAA==.',
['马尔']='马尔加尼斯:BAAALgAECgMJAwAAAA==.',
['骨感']='骨感是种美:BAAALgAFFAEJAQAAAA==.',
['高低']='高低高低:BAAALgAECgEJAQAAAA==.',
['高等']='高等术学:BAAALgAECgYJCgAAAA==.',
['魔古']='魔古尔之邪刃:BAAALgAECgQJBAAAAA==.',
['鲜团']='鲜团子丷淸夢:BAACLgAFFH8JAAILAAQJqBXhBQAFAQALAAQJpxXhBQAFAQAuAAQKfx4AAgsACQmiGgIOAKoCAAsACQmiGgIOAKoCAAAA.',
['鸠摩']='鸠摩罗什:BAAALgADCgQJBAAAAA==.',
['鸢尾']='鸢尾浮世绘:BAAALgADCgkJCQAAAA==.',
['鸽子']='鸽子杀手:BAAALgAFFAIJAwAAAA==.',
['麻溜']='麻溜澈:BAAALgAFFAQJAQAAAA==.',
['黎风']='黎风丶维诺:BAAALgAFFAEJAgAAAA==.',
['黑尾']='黑尾:BAAALgAECgUJBwAAAA==.',
['黑山']='黑山老猫:BAAALgADCgYJBgAAAA==.',
['黑虎']='黑虎阿福:BAAALgAFFAIJAgAAAA==.',
['黑韵']='黑韵之心:BAAALgAECgYJBwAAAA==.',
['默默']='默默地玫瑰:BAAALgADCgEJAQAAAA==.',
['黯舞']='黯舞:BAAALgAECgkJDgAAAA==.',
['龍伯']='龍伯:BAABLgAECn8cAAMZAAgJ9BOOIAC8AQAZAAgJHRKOIAC8AQAaAAYJJhKAHABMAQAAAA==.',
['龍游']='龍游小辣椒:BAAALgADCgcJBwAAAA==.',
['龙傲']='龙傲斩天:BAAALgAECgQJBAAAAA==.',
['龙都']='龙都香茗:BAAALgAECggJEgAAAA==.',
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
