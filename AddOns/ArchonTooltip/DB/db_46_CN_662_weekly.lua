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

local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Havoc','DemonHunter-Devourer','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Mage-Frost','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Shaman-Restoration','Druid-Restoration','Druid-Balance','Priest-Discipline','Warrior-Fury','Paladin-Holy','Unknown-Unknown','Monk-Brewmaster','Paladin-Protection','Monk-Mistweaver','DeathKnight-Frost','Druid-Guardian','Rogue-Subtlety','Warrior-Arms','Priest-Holy','Monk-Windwalker','Rogue-Assassination','Shaman-Elemental',}
local provider = {region='CN',realm='巫妖之王',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Addie:BAAALgADCgkJCQAAAA==.',
Ah='Ahaa:BAAALgADCgQJBAAAAA==.',
An='Anoper:BAAALgAECgEJAQAAAA==.',
Bi='Bigp:BAAALgAECgYJBgAAAA==.Biu:BAAALgAFFAIJAQAAAA==.',
Co='Cornerrose:BAAALgAECgcJEQAAAA==.',
Da='Darkbeliever:BAABLgAECn8YAAMBAAcJLRv3QwApAgABAAcJPxj3QwApAgACAAYJJxkAAAAAAAAAAA==.Dawntree:BAAALgAECgEJAQAAAA==.',
Dh='Dhqaq:BAACLgAFFH8IAAMDAAQJbg2nAwBKAQADAAQJbg2nAwBKAQAEAAQJhAUAAAAAAAAuAAQKfxMAAgMABwnHHvkQAFkCAAMABwnHHvkQAFkCAAAA.',
Di='Disabled:BAAALgAFFAIJBAAAAA==.',
Do='Dontlookatme:BAAALgAECgMJBgAAAA==.',
El='Elunemusu:BAAALgAECgEJAwAAAA==.',
Eu='Euphony:BAACLgAFFH8RAAQFAAUJyRWPAwBgAQAFAAUJWxKPAwBgAQAGAAMJ6RLENwCkAAAHAAEJPRXxBABZAAAuAAQKfyEAAwUACQnxIv4GAFoCAAYACQmKH4kYAMICAAUABgl5Iv4GAFoCAAAA.',
Ev='Evillive:BAAALgAECgYJBgAAAA==.',
Ha='Haopo:BAAALgADCgcJBwAAAA==.',
Ir='Ironyquot:BAAALgADCgQJBAAAAA==.',
Je='Jesko:BAABLgAECn8UAAMIAAYJ4SVJEgClAgAIAAYJ4SVJEgClAgAJAAQJIRQ3WgDbAAAAAA==.',
Ke='Kentling:BAAALgAECgQJBQAAAA==.',
La='Lagerback:BAAALgADCgEJAQAAAA==.',
Li='Lissandra:BAAALgAECgQJBgAAAA==.',
Lo='Lovejinna:BAAALgAFFAIJAwAAAA==.',
Lu='Lucian:BAAALgAECgMJAwAAAA==.',
Ma='Maranoy:BAAALgAECgUJAQAAAA==.Matsuyoi:BAAALgADCgYJBgAAAA==.',
Me='Megalovania:BAAALgADCgIJAgAAAA==.Metallic:BAAALgAECgQJBgAAAA==.',
Mi='Misshe:BAAALgAECgYJBgAAAA==.',
Mt='Mtwhitezz:BAAALgAECgQJBQAAAA==.',
['Mò']='Mòmò:BAAALgAECgEJAwAAAA==.',
Ol='Oldsix:BAAALgAECgYJCAAAAA==.',
Or='Orangesky:BAAALgAECgEJAQAAAA==.',
Ph='Phoneix:BAAALgAECgIJAQAAAA==.',
Pl='Playerlwgqrc:BAAALgAECgMJAQAAAA==.',
Pu='Pumachoco:BAAALgAECgIJAgAAAA==.',
Qi='Qiseven:BAAALgAECgEJAQAAAA==.',
Qu='Qu:BAAALgADCgUJBQAAAA==.',
Re='Rebirthcday:BAAALgAECgkJCgAAAA==.Resolution:BAAALgAECgcJCgAAAA==.Retrlbution:BAABLgAFFH8IAAIKAAIJ3xvEGwDBAAAKAAIJ3xvEGwDBAAAAAA==.',
Sa='Sanfrancisco:BAAALgAECgEJAQAAAA==.',
Sh='Shuiqio:BAAALgAECgEJAwAAAA==.',
Si='Sivir:BAAALgAECgEJAQAAAA==.',
Sm='Smile:BAABLgAFFH8FAAIDAAMJ4As6BgDtAAADAAMJ4As6BgDtAAAAAA==.',
So='Solaris:BAAALgAECgEJAQAAAA==.Solis:BAAALgAECgYJBQAAAA==.Sorrymaker:BAAALgAECgYJBgAAAA==.',
St='Stopkilling:BAAALgAECgEJAQAAAA==.',
Su='Summerhk:BAAALgADCgIJAgAAAA==.Superdfs:BAABLgAFFH8GAAILAAMJ9xIWLgD+AAALAAMJ9xIWLgD+AAAAAA==.Superdly:BAAALgADCgYJBQAAAA==.Superss:BAAALgAFFAEJAQAAAA==.',
Sy='Sylvius:BAAALgAECgYJBwAAAA==.',
Ta='Takina:BAACLgAFFH8HAAMMAAMJVQ6XDgDsAAAMAAMJVQ6XDgDsAAANAAIJ2whxGgCYAAAuAAQKfyEABA0ACAmvF3IQAHECAA0ACAmvF3IQAHECAAwAAgn0EGo9AIAAAA4AAQl3BBxBAC4AAAAA.Takino:BAACLgAFFH8QAAIPAAYJxhb9AAAFAgAPAAYJxhb9AAAFAgAuAAQKfxgAAg8ACAkOJOAEACQDAA8ACAkOJOAEACQDAAAA.',
Ti='Tilma:BAAALgADCgIJAgAAAA==.',
Ul='Ulquiorraboa:BAAALgAFFAIJAwAAAA==.',
Vi='Vinny:BAAALgAECgYJCAAAAA==.',
Wa='Wangcjq:BAAALgAECgYJCgAAAA==.Want:BAAALgAECgUJBAAAAA==.',
Wi='Wilt:BAABLgAFFH8JAAIBAAIJniVHMADOAAABAAIJniVHMADOAAAAAA==.Wind:BAAALgAFFAEJAQAAAA==.',
Wo='Wokae:BAAALgAECgkJCQAAAA==.',
Zo='Zone:BAAALgAECgYJCwAAAA==.',
['一刹']='一刹那的寄托:BAAALgAECgYJDwAAAA==.',
['一只']='一只:BAAALgAECgIJAgAAAA==.一只小鹌鹑:BAABLgAFFH8MAAMQAAQJ7yPCAwCnAQAQAAQJ7yPCAwCnAQARAAEJ+gOoHABDAAAAAA==.',
['一如']='一如初遇:BAAALgAECgQJCQAAAA==.',
['一张']='一张嘴横着走:BAAALgAECgEJBQAAAA==.',
['一种']='一种信仰:BAAALgADCgEJAQAAAA==.',
['一米']='一米六八:BAAALgADCgUJCAAAAA==.',
['一车']='一车淼淼:BAACLgAFFH8NAAILAAUJxQ4kEACVAQALAAUJxQ4kEACVAQAuAAQKfyUAAgsACQmZIPkUACsDAAsACQmZIPkUACsDAAAA.一车焱焱:BAAALgAFFAMJAwAAAA==.一车鑫鑫:BAAALgAECgEJAQAAAA==.',
['三七']='三七木:BAAALgAECggJEQAAAA==.',
['不加']='不加可乐的冰:BAAALgADCgUJBQAAAA==.',
['不吃']='不吃香菜丶:BAAALgAFFAMJAwAAAA==.',
['不喜']='不喜欢听慢歌:BAACLgAFFH8PAAIPAAUJ4xUEBQCAAQAPAAUJ4xUEBQCAAQAuAAQKfx8AAg8ACAkbFHUiABACAA8ACAkbFHUiABACAAAA.',
['不法']='不法分子:BAAALgAECgEJAQAAAA==.',
['不羈']='不羈客:BAAALgADCgYJBgAAAA==.',
['专治']='专治不孕不育:BAAALgAECgkJDAAAAA==.',
['世界']='世界末的情话:BAAALgADCgEJAQAAAA==.',
['东北']='东北鹤仙人:BAACLgAFFH8HAAIKAAMJxRHyEwAIAQAKAAMJxRHyEwAIAQAuAAQKfxwAAgoACAkPGRA8ADQCAAoACAkPGRA8ADQCAAAA.',
['丝柯']='丝柯克的狗:BAABLgAFFH8IAAILAAQJ4Bk1HgBRAQALAAQJ4Bk1HgBRAQAAAA==.',
['两件']='两件体恤衫:BAAALgAECgYJCAAAAA==.',
['丨可']='丨可口可乐丨:BAAALgADCgIJAgAAAA==.',
['丨陷']='丨陷阵之志丨:BAAALgADCgEJAQAAAA==.',
['丶四']='丶四季映姬:BAAALgAECgIJAgAAAA==.',
['丶小']='丶小熠星:BAAALgADCgEJAQAAAA==.',
['丶水']='丶水无灯里:BAABLgAFFH8KAAISAAYJrCM+BgB+AQASAAYJrCM+BgB+AQAAAA==.',
['丶灬']='丶灬宝儿乄:BAAALgADCgYJBgAAAA==.',
['丶炙']='丶炙丶:BAAALgAECgMJAwAAAA==.',
['丷身']='丷身本忧:BAAALgAECgMJAwAAAA==.',
['丷郝']='丷郝霸霸:BAAALgAECgUJCAAAAA==.',
['丿猎']='丿猎杀丶时刻:BAAALgAECgQJBAAAAA==.',
['乄灬']='乄灬麥兜丶:BAAALgAECgEJAQAAAA==.',
['乄玛']='乄玛斯:BAACLgAFFH8FAAITAAMJDgmOHACSAAATAAMJDgmOHACSAAAuAAQKfxcAAhMACAlZFIolACwCABMACAlZFIolACwCAAAA.',
['乌萨']='乌萨骑:BAAALgAECgcJCwAAAA==.',
['乌鲁']='乌鲁灬奇奥拉:BAAALgAECgcJDQAAAA==.',
['乐人']='乐人:BAABLgAFFH8HAAILAAMJZA1GLQACAQALAAMJZA1GLQACAQABLgAFFAgJGgALAHwmAA==.',
['乖屁']='乖屁屁:BAAALgADCggJCAAAAA==.',
['亀派']='亀派气功:BAAALgAECgEJAQAAAA==.',
['二二']='二二三四五:BAABLgAECn8WAAIKAAgJyB86GwDGAgAKAAgJyB86GwDGAgAAAA==.',
['二神']='二神他大伯:BAAALgAECgYJCQAAAA==.',
['二郎']='二郎氵真君:BAAALgAECgYJCQAAAA==.',
['亡凌']='亡凌:BAAALgAECgUJBQAAAA==.',
['亨大']='亨大拿:BAAALgAECgYJBwAAAA==.',
['今晚']='今晚打老虎:BAAALgAECgcJBwAAAA==.',
['今朝']='今朝酒:BAABLgAFFH8FAAIEAAIJzBWaJQCpAAAEAAIJzBWaJQCpAAAAAA==.',
['从小']='从小玩到大:BAACLgAFFH8FAAIKAAMJUxy7IQCpAAAKAAMJUxy7IQCpAAAuAAQKfxUAAwoACAk2H5ooAIMCAAoABwkaIZooAIMCABQAAQnsAbCWADMAAAAA.',
['他哥']='他哥临死前:BAAALgADCgMJAwAAAA==.',
['以身']='以身試法:BAAALgADCgQJBAAAAA==.',
['仲老']='仲老师:BAAALgAFFAEJAQABLgAFFAEJAQAVAAAAAA==.',
['会加']='会加血的苏菲:BAABLgAECn8XAAIPAAkJhhPAHQAuAgAPAAkJhhPAHQAuAgAAAA==.',
['会走']='会走的三百块:BAAALgADCgEJAQAAAA==.',
['伤疤']='伤疤:BAAALgAECgcJCQABLgAFFAUJBwANAIMKAA==.',
['何必']='何必勉为其难:BAAALgAECgEJAQAAAA==.',
['你我']='你我不怕:BAAALgAECgYJBgAAAA==.',
['俄塞']='俄塞里斯:BAAALgAECgcJBwABLgAFFAcJBwAFAE0eAA==.',
['倒地']='倒地本手:BAAALgAECgcJBwABLgAFFAUJAQAVAAAAAA==.',
['傲世']='傲世圣光者:BAAALgAFFAEJAQAAAA==.',
['傻曼']='傻曼的老公:BAAALgAECgYJBgAAAA==.',
['傻鹿']='傻鹿:BAAALgAFFAEJAQAAAA==.',
['元亨']='元亨利贞:BAAALgAECgYJCQAAAA==.',
['元素']='元素萨:BAAALgAECgQJBwAAAA==.',
['克洛']='克洛琳德的狗:BAABLgAFFH8FAAILAAQJswuNWABQAAALAAQJswuNWABQAAAAAA==.',
['兔小']='兔小甜:BAABLgAECn8VAAIKAAcJXB+iNwBEAgAKAAcJXB+iNwBEAgAAAA==.',
['兔耳']='兔耳茶:BAAALgAFFAIJAgAAAA==.',
['全村']='全村丶希望:BAAALgADCgYJBgAAAA==.',
['八级']='八级大狂风丶:BAAALgADCgEJAgAAAA==.',
['八舞']='八舞兮弦:BAAALgAECgEJAwAAAA==.',
['八重']='八重神子的狗:BAAALgAFFAQJBAAAAA==.',
['六道']='六道众生:BAAALgAECgcJEwAAAA==.',
['内心']='内心的独白:BAAALgAECgEJAQAAAA==.',
['冥域']='冥域浅蓝:BAAALgAECgcJBQABLgAFFAQJBAAVAAAAAA==.',
['冥王']='冥王凌风:BAABLgAFFH8PAAILAAUJTRBIDgCnAQALAAUJTRBIDgCnAQAAAA==.',
['冬天']='冬天:BAAALgAFFAEJAQAAAA==.',
['冬月']='冬月:BAAALgAFFAEJAQAAAA==.',
['冰镇']='冰镇西瓜汁:BAAALgAECgQJCQAAAA==.',
['冷暖']='冷暖自知:BAAALgAECgMJAwAAAA==.',
['冷血']='冷血丶圣骑:BAAALgAECgUJBQAAAA==.',
['凌云']='凌云禅武尊:BAAALgADCgQJBAAAAA==.',
['凌小']='凌小满:BAAALgAECgEJAQAAAA==.凌小魔丶:BAAALgADCgEJAQAAAA==.',
['凪光']='凪光:BAAALgAECgEJAQAAAA==.',
['刀小']='刀小刀:BAAALgADCgYJCwAAAA==.',
['刘玥']='刘玥丶:BAAALgAECgEJAQABLgAFFAYJBAAVAAAAAA==.',
['制动']='制动瑧棒:BAAALgAECgQJBgAAAA==.',
['刻晴']='刻晴的狗:BAABLgAFFH8IAAILAAQJ/RcmBgBvAQALAAQJ/RcmBgBvAQAAAA==.',
['加了']='加了个比海盗:BAAALgAECgcJDQAAAA==.',
['动感']='动感小王爺:BAABLgAFFH8FAAIIAAIJHBqKEADDAAAIAAIJHBqKEADDAAAAAA==.',
['動情']='動情:BAAALgADCgQJBAAAAA==.',
['十字']='十字准心:BAAALgAECgIJAgAAAA==.十字凖星:BAAALgADCgEJAQAAAA==.',
['十月']='十月生石:BAAALgAECgEJAQAAAA==.',
['千鏜']='千鏜瑛理华:BAAALgAECgEJAQAAAA==.',
['千风']='千风:BAAALgAECgQJCAABLgAECgcJIAAKAP8jAA==.',
['卞珏']='卞珏二二:BAAALgAECgUJBgAAAA==.',
['卡尓']='卡尓:BAAALgAECgcJEQAAAA==.',
['卡皮']='卡皮吧啦:BAAALgAECgcJAQAAAA==.',
['叁仟']='叁仟弱氺:BAAALgAECgMJAwAAAA==.',
['友哈']='友哈巴赫:BAAALgAFFAMJAwAAAA==.',
['古丹']='古丹之翼:BAAALgADCgEJAQAAAA==.',
['古彤']='古彤清月:BAAALgAECgYJBgAAAA==.',
['叫我']='叫我黑大爷:BAAALgAECgcJCwAAAA==.',
['叮咚']='叮咚叽:BAAALgAECgcJCAAAAA==.',
['史蒂']='史蒂芬矮子:BAAALgAECgMJAgAAAA==.',
['叶觅']='叶觅:BAAALgAECgcJBwAAAA==.',
['吃喵']='吃喵酱的花椒:BAAALgADCgEJAgAAAA==.',
['吃我']='吃我一击吧:BAAALgAECgQJBAAAAA==.',
['吃饭']='吃饭睡觉:BAAALgADCgcJBwAAAA==.',
['吉几']='吉几吉吉几:BAAALgADCgUJBQAAAA==.',
['吉田']='吉田春:BAAALgAECgEJAQAAAA==.',
['名侦']='名侦探夏洛克:BAAALgAECgIJAgAAAA==.',
['名曰']='名曰夷:BAAALgADCgEJAQAAAA==.',
['吸吸']='吸吸欧气:BAAALgAECgQJBgAAAA==.',
['吹吹']='吹吹风听听歌:BAAALgADCgEJAQAAAA==.',
['呆呆']='呆呆法:BAAALgAFFAEJAQAAAA==.',
['咆哮']='咆哮的溜溜球:BAAALgAECgEJAQAAAA==.',
['咔咔']='咔咔一顿射:BAAALgAECgEJAQAAAA==.',
['咕蠱']='咕蠱咕:BAAALgAECgcJDQAAAA==.',
['哆妮']='哆妮蒂咔:BAAALgADCgUJBQAAAA==.',
['哆拉']='哆拉弓:BAAALgAECgIJAgAAAA==.',
['哈嘿']='哈嘿:BAAALgAECgYJCgAAAA==.',
['哈斯']='哈斯沃德:BAAALgADCgMJAwAAAA==.',
['哊點']='哊點無奈:BAAALgAFFAIJAgAAAA==.哊點無聊:BAAALgADCgcJBwAAAA==.',
['啊姨']='啊姨洗铁路:BAAALgAECgYJBwAAAA==.',
['喃喃']='喃喃自言:BAAALgAFFAEJAQAAAA==.',
['嘟哩']='嘟哩个嘟:BAAALgAECgQJBQAAAA==.',
['四个']='四个管住:BAAALgAECgYJBgAAAA==.',
['四月']='四月荒芜:BAAALgAECgkJAgAAAA==.',
['团子']='团子:BAAALgAECgMJAwAAAA==.',
['国服']='国服恶魔:BAAALgAECgQJBgAAAA==.',
['国王']='国王小瓦:BAAALgAECgIJAgAAAA==.',
['圈兒']='圈兒:BAAALgADCgcJBwABLgAECgYJFgAWAFgaAA==.',
['圈圈']='圈圈之王:BAAALgAECgIJAwABLgAECgYJFgAWAFgaAA==.',
['土人']='土人新成员:BAABLgAFFH8HAAIGAAIJGAp4OACiAAAGAAIJGAp4OACiAAAAAA==.',
['圣丨']='圣丨骑:BAAALgADCgEJAQAAAA==.',
['圣丶']='圣丶丨瑰洱:BAAALgAECgYJBgAAAA==.',
['地主']='地主老財:BAABLgAFFH8IAAIGAAMJ9RV6HwAGAQAGAAMJ9RV6HwAGAQAAAA==.',
['地里']='地里热吧:BAAALgAECgEJAQAAAA==.',
['坚定']='坚定的眼神:BAAALgADCgEJAQAAAA==.',
['培丨']='培丨根:BAAALgAFFAEJAQAAAA==.',
['墮丶']='墮丶丨熙拉:BAAALgAECgYJCAAAAA==.',
['复仇']='复仇风行者:BAAALgAECgcJDwAAAA==.',
['外公']='外公灬:BAAALgAECgEJAQAAAA==.',
['外卖']='外卖坏了:BAAALgAECgYJBgAAAA==.外卖掉了:BAAALgAECgYJCgAAAA==.',
['外甥']='外甥女阿黄:BAAALgADCgEJAQAAAA==.',
['夜修']='夜修:BAAALgAECgcJBwAAAA==.',
['夜芷']='夜芷殇:BAAALgAECgYJCwAAAA==.',
['大朗']='大朗该吃糖:BAAALgAECgMJAwAAAA==.',
['大松']='大松狮:BAAALgAECgYJCQAAAA==.',
['大白']='大白骑士:BAAALgADCgIJAgAAAA==.',
['大胖']='大胖柑:BAAALgAECgIJAwAAAA==.大胖胖:BAAALgAECgEJAQAAAA==.',
['大锤']='大锤俩四十:BAAALgAECgEJAgABLgAECggJFgAKAMgfAA==.',
['天天']='天天要吃饭:BAAALgAECgUJBQAAAA==.',
['天朗']='天朗气清:BAAALgAECgYJCQAAAA==.',
['天未']='天未老情难绝:BAAALgAECgYJCgAAAA==.',
['天道']='天道丶小呆:BAAALgADCgUJBQAAAA==.',
['天马']='天马三号:BAAALgAECgQJBQAAAA==.',
['夲跑']='夲跑的蜗牛:BAAALgAECgEJAQAAAA==.',
['头五']='头五头六:BAAALgAFFAQJBAAAAA==.',
['奈森']='奈森:BAAALgAECgIJAgAAAA==.',
['奈法']='奈法利安之手:BAAALgAECgYJCwAAAA==.',
['奔雷']='奔雷手炆泰来:BAAALgAECgUJEgAAAA==.',
['女亚']='女亚:BAAALgAECgYJCwAAAA==.',
['奶凶']='奶凶小糯熊:BAAALgAECgcJDgAAAA==.',
['奶势']='奶势汹汹:BAAALgAECgMJAwAAAA==.',
['奶油']='奶油丶覇爸:BAAALgAECgEJAQAAAA==.',
['奶飞']='奶飞天的小德:BAAALgAECgMJAwAAAA==.',
['好想']='好想吃汤圆:BAAALgAECgQJAwAAAA==.',
['如梦']='如梦亦如幻丶:BAAALgAECgIJAQAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8JAAISAAUJyA7+CgAuAQASAAUJyA7+CgAuAQAAAA==.',
['媚色']='媚色丷:BAAALgAECgEJAgAAAA==.',
['嫌淡']='嫌淡超人:BAAALgAECgYJBgAAAA==.',
['孔雀']='孔雀:BAAALgAFFAEJAQAAAA==.',
['孤单']='孤单吸血鬼:BAAALgAFFAIJBAAAAA==.',
['孤独']='孤独型人格:BAAALgAECgYJCAAAAA==.',
['宁淦']='宁淦:BAAALgAECgEJAQAAAA==.',
['宁艺']='宁艺卓丷:BAAALgAECgEJAQAAAA==.',
['宇佐']='宇佐见茶:BAAALgAECgcJCgAAAA==.',
['宋平']='宋平凡:BAAALgAECgYJCgAAAA==.',
['宝宝']='宝宝她老公:BAAALgAECgEJAQAAAA==.宝宝她老大:BAAALgAECgIJAgAAAA==.宝宝巴士来咯:BAAALgAECgYJCAAAAA==.',
['寒兮']='寒兮浅忆:BAABLgAFFH8GAAILAAMJnAf6EwD0AAALAAMJnAf6EwD0AAAAAA==.',
['小五']='小五五:BAAALgADCgEJAQAAAA==.',
['小号']='小号不思春:BAAALgADCgUJCAAAAA==.',
['小心']='小心包包:BAAALgAFFAEJAQAAAA==.',
['小时']='小时候可粗了:BAAALgAECgUJCwAAAA==.',
['小木']='小木曾雪菜:BAABLgAFFH8GAAIQAAMJ7iLkEQDaAAAQAAMJ7iLkEQDaAAAAAA==.',
['小术']='小术同学:BAAALgAECgQJCAAAAA==.',
['小潘']='小潘锅:BAAALgAECgQJBQAAAA==.',
['小肉']='小肉爷:BAAALgAFFAMJBAAAAA==.',
['小萝']='小萝卜头丶:BAAALgAECgQJBAAAAA==.',
['小轩']='小轩纳塔:BAAALgAECgcJBwAAAA==.小轩鹰风:BAAALgAECgEJAQAAAA==.',
['小转']='小转角:BAAALgAECgYJCQAAAA==.',
['小青']='小青山:BAABLgAFFH8HAAIKAAMJXhiWEwAKAQAKAAMJXhiWEwAKAQAAAA==.',
['小鹿']='小鹿乱撞:BAAALgADCgcJBwAAAA==.',
['小龙']='小龙女:BAAALgAECgEJAQAAAA==.',
['尐小']='尐小小乄魚儿:BAAALgAECgYJBgAAAA==.尐小小灬魚儿:BAAALgAECgUJBQAAAA==.',
['峡谷']='峡谷大角色丶:BAAALgAECgYJBgAAAA==.',
['巨棒']='巨棒哥:BAAALgAFFAIJAwAAAA==.',
['巫丶']='巫丶牛王:BAAALgAECgIJAgAAAA==.',
['巫喵']='巫喵之王:BAAALgAECgYJDAAAAA==.',
['帕塞']='帕塞瓦尔:BAAALgAECgEJAQAAAA==.',
['帕拉']='帕拉摩尔:BAAALgADCgEJAQAAAA==.',
['带带']='带带:BAAALgAECgYJBgAAAA==.',
['带皮']='带皮小黄牛:BAAALgAECgYJEAAAAA==.',
['幻笙']='幻笙海月:BAAALgAECgEJAQAAAA==.',
['幽灵']='幽灵的霊:BAAALgAECgIJAgAAAA==.',
['弥合']='弥合:BAAALgADCgYJBgAAAA==.',
['强爆']='强爆战丶:BAAALgAECgYJBwAAAA==.',
['彩彩']='彩彩爱睡懒觉:BAAALgAFFAIJBAAAAA==.',
['彩笔']='彩笔螳螂头:BAAALgAECgQJBAAAAA==.',
['彩虹']='彩虹德玛:BAAALgADCgIJAgAAAA==.',
['彬灬']='彬灬祁:BAAALgAECgEJAQAAAA==.',
['影魔']='影魔酱:BAAALgAFFAIJAgAAAA==.',
['往昔']='往昔:BAABLgAECn8XAAMXAAgJkBb8EAC3AQAKAAgJsw/gWQDVAQAXAAcJFBb8EAC3AQAAAA==.',
['很凶']='很凶很残忍:BAAALgADCgEJAQAAAA==.',
['後青']='後青春期的诗:BAAALgAECgUJDAAAAA==.',
['徐老']='徐老师骑:BAAALgAFFAEJAQAAAA==.',
['御坂']='御坂空白:BAAALgAECgQJBAAAAA==.御坂美幸:BAAALgADCgQJBAAAAA==.',
['御扳']='御扳美琴:BAAALgAFFAMJBAABLgAFFAMJBwALAD0cAA==.',
['德古']='德古拉爵士:BAAALgAECgMJAwAAAA==.',
['德落']='德落克:BAAALgADCgcJBwAAAA==.',
['忘忘']='忘忘碎冰冰:BAAALgAECgEJAQAAAA==.',
['怒炎']='怒炎飞歌:BAAALgAECgEJAQAAAA==.',
['怒风']='怒风之游龙:BAAALgADCgIJAgAAAA==.',
['思漫']='思漫:BAAALgAECgcJDAAAAA==.',
['恐龙']='恐龙抗狼:BAAALgAECgEJAQAAAA==.',
['恭喜']='恭喜你:BAAALgAECgEJAQAAAA==.',
['您小']='您小子:BAABLgAFFH8FAAIKAAIJWBRvEACiAAAKAAIJWBRvEACiAAAAAA==.',
['悲伤']='悲伤时唱首歌:BAAALgAECgMJBQAAAA==.',
['懂嘚']='懂嘚灬:BAAALgAFFAIJAwAAAA==.',
['懒虫']='懒虫丶不瞌睡:BAAALgAECgQJBwAAAA==.',
['戏命']='戏命师丶:BAAALgAECgIJBAAAAA==.',
['成都']='成都吴彦祖:BAABLgAFFH8HAAIGAAMJIhtxGQAlAQAGAAMJIhtxGQAlAQAAAA==.',
['我不']='我不停的走:BAAALgAECgEJAQAAAA==.',
['我叫']='我叫磁力棒:BAACLgAFFH8HAAILAAMJPRwvJQAfAQALAAMJPRwvJQAfAQAuAAQKfx4AAgsACAmII5IWACIDAAsACAmII5IWACIDAAAA.',
['我吃']='我吃矿贼猛:BAAALgAECgIJBAAAAA==.',
['我本']='我本快乐:BAAALgAECgEJAgAAAA==.',
['我死']='我死神不太溜:BAAALgAFFAEJAQAAAA==.',
['我还']='我还会回来的:BAAALgAECgcJDwAAAA==.',
['我魂']='我魂:BAAALgAECgUJDQAAAA==.',
['战复']='战复你粑粑:BAAALgADCgEJAQAAAA==.',
['战歌']='战歌:BAAALgAECgQJCQAAAA==.',
['战神']='战神阿瑞斯:BAAALgAECgYJBgAAAA==.',
['戰丶']='戰丶關羽:BAAALgAFFAIJAgAAAA==.',
['房东']='房东的猫:BAAALgAECgYJBgAAAA==.',
['打架']='打架俗手:BAABLgAECn8UAAMYAAcJSxxUGAD9AQAYAAcJSxxUGAD9AQAWAAcJDB06JQDZAQABLgAFFAUJAQAVAAAAAA==.',
['扬尘']='扬尘逆世丶:BAAALgAECgQJBAAAAA==.',
['抛开']='抛开事实不谈:BAABLgAECn8lAAIWAAgJJBHNCgBCAQAWAAgJJBHNCgBCAQAAAA==.',
['抡死']='抡死你:BAAALgAECgMJAwABLgAECgYJCQAVAAAAAA==.',
['拉妮']='拉妮娜:BAABLgAECn8WAAIKAAkJwgaKsAAiAQAKAAkJwgaKsAAiAQAAAA==.',
['拼命']='拼命六郎:BAABLgAECn8UAAMBAAYJ6hGTnwBBAQABAAYJ6hGTnwBBAQAZAAEJ8gFqGgAhAAAAAA==.',
['挫波']='挫波波:BAABLgAFFH8IAAILAAMJFBN8EQAHAQALAAMJFBN8EQAHAQAAAA==.',
['教官']='教官的第四课:BAAALgADCgYJBwAAAA==.',
['文先']='文先生请带刀:BAAALgAECgYJCQAAAA==.',
['文文']='文文小帅哥:BAAALgAECgQJBAAAAA==.',
['新丶']='新丶:BAAALgADCgEJAQAAAA==.',
['旋風']='旋風衝鋒:BAAALgAECgYJCQAAAA==.',
['无低']='无低暗影君王:BAACLgAFFH8GAAIEAAQJngqmFAAtAQAEAAQJngqmFAAtAQAuAAQKfx0AAgQACAnwFqpCAOkBAAQACAnwFqpCAOkBAAEuAAUUBQkTAAEANCUA.',
['无敌']='无敌小小牛:BAAALgAECgEJAQAAAA==.无敌牛牛大王:BAACLgAFFH8TAAIBAAUJNCU7AgDzAQABAAUJNCU7AgDzAQAuAAQKfyAAAgEACAnOJcYHAGIDAAEACAnOJcYHAGIDAAAA.',
['无边']='无边堕落:BAAALgAECgYJDgAAAA==.',
['无颜']='无颜之月:BAAALgAECgQJBwAAAA==.',
['明翼']='明翼:BAAALgAECgQJBAABLgAECgcJIAAKAP8jAA==.',
['昔曰']='昔曰无法回头:BAAALgAECgkJEgAAAA==.',
['星智']='星智:BAABLgAECn8WAAILAAYJ1CGgUABFAgALAAYJ1CGgUABFAgABLgAECgcJIAAKAP8jAA==.',
['晒得']='晒得蓬松:BAAALgAECgYJBgAAAA==.',
['晓得']='晓得啦:BAAALgAECgUJBgAAAA==.',
['晚饭']='晚饭还没吃丶:BAAALgAECgQJBAAAAA==.',
['晨铸']='晨铸:BAABLgAECn8gAAIKAAcJ/yPYBABPAgAKAAcJ/yPYBABPAgAAAA==.',
['晨锋']='晨锋:BAAALgAECgQJEwABLgAECgcJIAAKAP8jAA==.',
['暴躁']='暴躁小熊猫:BAAALgAECgEJAQAAAA==.暴躁老弟:BAAALgAECgEJAQAAAA==.',
['月下']='月下的哈基米:BAAALgADCgUJBQAAAA==.月下霓裳泪:BAAALgAECgEJAQAAAA==.',
['月影']='月影丶术灵:BAAALgAECgIJAgAAAA==.月影丶缺德:BAAALgADCgEJAQAAAA==.月影丶驭猎:BAAALgAECgMJBAAAAA==.',
['月牙']='月牙泉水:BAAALgADCgEJAQAAAA==.',
['月祭']='月祭靈离:BAAALgAFFAIJAgAAAA==.',
['月翼']='月翼猫头鹰:BAABLgAFFH8HAAIaAAcJLhVYAAA1AgAaAAcJLhVYAAA1AgAAAA==.',
['月色']='月色丶:BAAALgADCgcJDQAAAA==.',
['机器']='机器熊:BAABLgAECn8cAAMYAAkJwxnFCgCmAgAYAAkJwxnFCgCmAgAWAAcJMxI0NgB0AQAAAA==.',
['杀生']='杀生院祈荒:BAAALgAECgIJAwAAAA==.',
['李香']='李香兰:BAAALgAECgEJAQAAAA==.',
['杜姿']='杜姿藤:BAAALgAFFAIJAwAAAA==.',
['条条']='条条丶:BAAALgAECgIJAgAAAA==.',
['来啊']='来啊丨快活啊:BAAALgAECgEJAQAAAA==.',
['来春']='来春打马:BAAALgAFFAMJAwAAAA==.',
['来瓶']='来瓶冰阔乐:BAAALgAECgYJDAAAAA==.',
['杰洛']='杰洛齐贝林:BAAALgAECgEJAQAAAA==.',
['果冻']='果冻小乖:BAAALgAECggJCgAAAA==.',
['果赖']='果赖:BAACLgAFFH8XAAIQAAYJsCJ/AABpAgAQAAYJsCJ/AABpAgAuAAQKfyEAAhAACAn3JSgDAGIDABAACAn3JSgDAGIDAAAA.',
['枪魔']='枪魔:BAAALgAECgQJBwAAAA==.',
['枫之']='枫之小水:BAAALgAECgMJAwAAAA==.',
['枫御']='枫御:BAAALgAECggJEQAAAA==.',
['枭毒']='枭毒狂魔:BAAALgAECgQJBAAAAA==.',
['枯藤']='枯藤老树鹌鹑:BAAALgADCgYJBgAAAA==.',
['某位']='某位劣人:BAAALgADCgIJAgAAAA==.',
['柠檬']='柠檬狗:BAAALgAECgIJAgAAAA==.柠檬色回忆:BAAALgADCgYJBgAAAA==.',
['柰利']='柰利特:BAAALgAECgMJAwAAAA==.',
['桌面']='桌面上的快播:BAABLgAECn8cAAIKAAgJGR1eLQBuAgAKAAgJGR1eLQBuAgAAAA==.',
['梦幻']='梦幻斗舞:BAAALgAECgQJBgAAAA==.',
['梦玄']='梦玄:BAACLgAFFH8IAAILAAMJahxyMwDNAAALAAMJahxyMwDNAAAuAAQKfygAAgsACAkzJZINAFkDAAsACAkzJZINAFkDAAAA.',
['楪丶']='楪丶:BAABLgAFFH8GAAIGAAQJshmvDgBoAQAGAAQJshmvDgBoAQAAAA==.',
['樂丨']='樂丨星河:BAAALgADCgEJAgAAAA==.',
['樱小']='樱小路露娜:BAAALgAECgcJEQABLgAFFAYJAwAVAAAAAA==.',
['樱零']='樱零丨雨悴:BAABLgAECn8hAAILAAgJlyIyFQApAwALAAgJlyIyFQApAwAAAA==.',
['橙丶']='橙丶风暴烈酒:BAAALgAECgEJAQAAAA==.',
['橙灬']='橙灬冠犀:BAAALgAECgcJCgAAAA==.',
['橙風']='橙風尽垩:BAAALgAECgcJCQAAAA==.',
['欠宝']='欠宝贝:BAABLgAECn8UAAMKAAgJyxuoSwAAAgAKAAYJMR2oSwAAAgAXAAcJ2BQlEQC1AQAAAA==.',
['欧皇']='欧皇丶猎神:BAAALgADCgcJCQAAAA==.',
['武器']='武器战:BAAALgAECgYJDgAAAA==.',
['歪理']='歪理怪:BAAALgAECgQJCQAAAA==.',
['死亡']='死亡恐惧:BAAALgAECgEJAwAAAA==.',
['残七']='残七念:BAAALgAECgQJBAAAAA==.',
['水云']='水云身:BAACLgAFFH8IAAIYAAMJgxnoCgD6AAAYAAMJgxnoCgD6AAAuAAQKfxQAAhgABwklIeMNAHgCABgABwklIeMNAHgCAAAA.',
['水无']='水无丶灯里:BAABLgAFFH8GAAISAAYJrCAsAQBCAgASAAYJrCAsAQBCAgABLgAFFAcJBwASAJAaAA==.',
['永恩']='永恩丶:BAAALgAECgYJCwAAAA==.',
['永歌']='永歌:BAAALgAECgQJCAABLgAECgcJIAAKAP8jAA==.',
['江山']='江山策:BAAALgAECgEJAQAAAA==.',
['没事']='没事来口痰:BAAALgAECgYJBgAAAA==.',
['河北']='河北采花:BAAALgAECgEJAwAAAA==.',
['泌尿']='泌尿科陈主任:BAAALgAECgUJCgAAAA==.',
['法神']='法神卡萨丁:BAAALgADCgEJAQAAAA==.',
['泰二']='泰二真人:BAAALgADCgEJAQAAAA==.',
['泰兰']='泰兰德的香蕉:BAAALgAECgcJAQAAAA==.',
['泰斯']='泰斯塔洛莎:BAAALgAFFAIJAwAAAA==.',
['洗脚']='洗脚水面包师:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪小法:BAAALgAECgIJAgAAAA==.',
['浊酒']='浊酒三两三:BAAALgAECgMJAwAAAA==.',
['浩迟']='浩迟苟:BAAALgADCgEJAQAAAA==.',
['浪尖']='浪尖潮男:BAAALgAECgcJDwAAAA==.',
['浪漫']='浪漫眼神:BAAALgAECgEJAQAAAA==.',
['海汀']='海汀汀:BAAALgAECgEJAQAAAA==.',
['海的']='海的女儿忒咸:BAAALgAECgEJAQAAAA==.',
['海鲜']='海鲜大杂烩:BAAALgAECgYJBwAAAA==.海鲜最勇猛:BAAALgAECgQJBAAAAA==.海鲜最风骚:BAAALgAECgMJAwAAAA==.',
['涅扎']='涅扎斯丶梦魇:BAAALgADCgEJAQABLgAFFAQJCAAGACohAA==.',
['清欢']='清欢:BAAALgAECgYJDgAAAA==.',
['清照']='清照:BAAALgAECgYJBgAAAA==.',
['清秀']='清秀小生:BAAALgAECgQJCAAAAA==.',
['清辉']='清辉夜凝丶:BAAALgAECgEJAQAAAA==.',
['渝大']='渝大姐:BAAALgAECgEJAQAAAA==.',
['渡月']='渡月声:BAAALgAECgYJCgAAAA==.',
['渡魂']='渡魂炎燚:BAAALgAFFAEJAQAAAA==.',
['温蕾']='温蕾飒:BAAALgAFFAIJAwAAAA==.',
['湖人']='湖人总冠菌:BAAALgAECgQJBAAAAA==.',
['满酱']='满酱:BAAALgAECgEJAQAAAA==.',
['滴答']='滴答滴:BAAALgAECgEJAQAAAA==.',
['漫天']='漫天风雪:BAAALgADCgYJBgAAAA==.',
['潜行']='潜行的胖次:BAABLgAECn8VAAIbAAgJQxWXFQBjAgAbAAgJQxWXFQBjAgAAAA==.',
['激流']='激流:BAAALgAECgQJEgABLgAECgcJIAAKAP8jAA==.',
['火刃']='火刃屠夫:BAAALgAFFAEJAQAAAA==.',
['灬伊']='灬伊澤瑞尔灬:BAAALgADCgEJAQAAAA==.',
['灬青']='灬青麟丶:BAAALgAFFAIJAgAAAA==.',
['灰机']='灰机会武功:BAAALgAFFAMJBAAAAA==.灰机爱冲锋:BAAALgAECgMJAwAAAA==.',
['灰烬']='灰烬之血:BAAALgADCgYJAQAAAA==.',
['炮灰']='炮灰之琅琊:BAAALgAECgEJAgAAAA==.',
['烟头']='烟头烫菊花:BAAALgAECgEJAQAAAA==.',
['烬魔']='烬魔:BAAALgAECgcJCwAAAA==.',
['無名']='無名萃取:BAAALgAECgIJAgAAAA==.',
['煌尚']='煌尚:BAAALgAFFAIJAwABLgAFFAYJFQALAMYeAA==.',
['煙埖']='煙埖灬弎曰:BAAALgAFFAQJAgAAAA==.',
['熔岩']='熔岩行者:BAAALgADCgMJBQAAAA==.',
['爱可']='爱可菲的狗:BAAALgAFFAIJAgAAAA==.',
['爱的']='爱的天灵灵:BAAALgAECgUJBQAAAA==.',
['爹丨']='爹丨死扛到底:BAAALgADCgEJAQAAAA==.',
['牛妞']='牛妞牛:BAAALgAECgEJAQAAAA==.',
['牛撒']='牛撒牛撒滴:BAAALgADCgMJAwAAAA==.',
['牛牛']='牛牛小红手:BAAALgAECgEJAQAAAA==.',
['特点']='特点埏:BAAALgAECgMJAwABLgAECgcJBwAVAAAAAA==.',
['狂暴']='狂暴的小矮子:BAAALgAECgcJCgAAAA==.',
['狠胖']='狠胖很丰满丶:BAAALgADCgEJAQAAAA==.',
['独狼']='独狼计划:BAAALgAECgQJBAAAAA==.',
['独臂']='独臂大师:BAABLgAFFH8FAAIKAAMJ1h5yHgCzAAAKAAMJ1h5yHgCzAAAAAA==.',
['猎杀']='猎杀者拉客:BAAALgADCgcJEQAAAA==.',
['猪小']='猪小屁:BAAALgAFFAEJAQAAAA==.',
['猪脚']='猪脚饭丶:BAAALgAECgEJAQAAAA==.',
['猫光']='猫光:BAAALgAECgcJDAAAAA==.',
['猫咪']='猫咪丶:BAAALgAECgQJBAAAAA==.',
['猫氵']='猫氵:BAAALgAECgYJDAAAAA==.',
['猫猫']='猫猫头丶:BAAALgAECgEJAQAAAA==.',
['獭獭']='獭獭:BAAALgAECgIJAgAAAA==.',
['王大']='王大胖:BAAALgADCgEJAQAAAA==.',
['王肥']='王肥肥桃:BAAALgAFFAIJAgAAAA==.',
['玖丝']='玖丝丝:BAABLgAECn8UAAMFAAgJXAotGQCCAQAFAAgJSQgtGQCCAQAGAAYJZQrckwAxAQAAAA==.',
['玖清']='玖清河:BAABLgAECn8VAAIRAAcJpx44IAD8AQARAAcJpx44IAD8AQAAAA==.',
['玫瑰']='玫瑰病人:BAAALgADCgMJAwAAAA==.',
['玲小']='玲小珑:BAAALgAECgIJAgAAAA==.',
['琼琼']='琼琼低语者:BAAALgAFFAIJAwAAAA==.',
['瓜兮']='瓜兮兮:BAAALgAECgQJBgAAAA==.瓜兮兮的宝器:BAAALgAECgcJEAAAAA==.',
['瓦斯']='瓦斯坏蛋:BAABLgAECn8UAAITAAcJ5hZMLgD4AQATAAcJ5hZMLgD4AQAAAA==.',
['用途']='用途看:BAAALgAECgcJBwAAAA==.',
['申鹤']='申鹤的狗:BAABLgAFFH8IAAILAAQJABUjCABfAQALAAQJABUjCABfAQAAAA==.',
['男人']='男人至死少年:BAAALgAECgUJCQAAAA==.',
['畅游']='畅游天下:BAAALgADCgcJBwAAAA==.',
['疯四']='疯四儿:BAABLgAECn8aAAMcAAgJJBDGCgD4AQAcAAgJJBDGCgD4AQATAAYJvw2BWgBDAQAAAA==.',
['疯子']='疯子三十二号:BAAALgAECgYJDAAAAA==.',
['疯狂']='疯狂阿贝贝:BAAALgAECgUJDAAAAA==.',
['白染']='白染:BAAALgAECgMJAwAAAA==.',
['白琉']='白琉璃:BAAALgADCgcJBwAAAA==.',
['白雪']='白雪乃爱:BAABLgAECn8bAAIYAAcJFh91EwAxAgAYAAcJFh91EwAxAgAAAA==.',
['百里']='百里灬屠苏:BAAALgAECgEJAgAAAA==.',
['皮咔']='皮咔丘丶:BAAALgADCgEJAQAAAA==.',
['相思']='相思赋予誰:BAAALgADCgMJAwAAAA==.',
['看淡']='看淡逍遥:BAAALgADCgYJBgAAAA==.',
['知交']='知交半零落:BAAALgAECgcJBwAAAA==.',
['石川']='石川弥荣:BAAALgAECgMJAwABLgAECgcJGwAYABYfAA==.',
['碎便']='碎便者:BAAALgAECgUJBQAAAA==.碎便萌新:BAAALgAECgYJDAAAAA==.',
['祁同']='祁同伟:BAAALgAECgYJCwAAAA==.',
['祎灬']='祎灬宝:BAAALgADCgMJBAAAAA==.',
['神亦']='神亦羡逍遥:BAABLgAFFH8MAAMUAAQJdAZ2BQAKAQAUAAQJdAZ2BQAKAQAKAAEJvgfANgBLAAAAAA==.',
['神威']='神威无双:BAAALgAECgYJCQAAAA==.',
['神射']='神射十一箭:BAAALgADCgEJAQAAAA==.',
['神里']='神里菱华的狗:BAABLgAFFH8JAAILAAUJOhncCgDHAQALAAUJOhncCgDHAQAAAA==.',
['离戈']='离戈丶:BAAALgAECgcJBwAAAA==.',
['秋高']='秋高看山势:BAAALgAECgcJAQAAAA==.',
['积积']='积积大大德:BAAALgAECgYJBwAAAA==.',
['穿天']='穿天猴:BAAALgAECgEJAQAAAA==.',
['立正']='立正:BAAALgAECgYJCgAAAA==.',
['竹丶']='竹丶梦魇:BAAALgAECgcJCwAAAA==.',
['第一']='第一美女:BAAALgAECgIJAgAAAA==.',
['箭雨']='箭雨的劣人:BAAALgAECgEJAQAAAA==.',
['米诺']='米诺斯凋零者:BAAALgADCgEJAQAAAA==.',
['粉蒸']='粉蒸排骨丶:BAABLgAFFH8HAAISAAcJkBqtAACHAgASAAcJkBqtAACHAgAAAA==.',
['糖兜']='糖兜兒:BAAALgAECgIJAgABLgAFFAYJFQALAMYeAA==.',
['紅塵']='紅塵雪:BAACLgAFFH8FAAIKAAIJHh0NJwCcAAAKAAIJHh0NJwCcAAAuAAQKfxsAAgoACAnlF/ZgAMIBAAoACAnlF/ZgAMIBAAAA.',
['索伦']='索伦:BAAALgAECgcJCQAAAA==.',
['紫色']='紫色大地:BAACLgAFFH8JAAIWAAMJbRkhEQD2AAAWAAMJbRkhEQD2AAAuAAQKfxkAAhYACAl4HIUPAKICABYACAl4HIUPAKICAAAA.',
['繁华']='繁华落雪:BAAALgAECgIJAgAAAA==.',
['纪念']='纪念:BAAALgADCgUJBQAAAA==.',
['纯白']='纯白骑士:BAAALgAECgcJCAAAAA==.',
['纯黑']='纯黑酱:BAAALgAFFAIJAgAAAA==.',
['纵横']='纵横:BAAALgAECgMJCQAAAA==.',
['给小']='给小潘洗个脚:BAAALgAECgQJBQAAAA==.',
['绫地']='绫地宁宁:BAAALgADCgEJAQABLgAECgcJGwAYABYfAA==.',
['维仑']='维仑:BAABLgAFFH8FAAIEAAIJYhjoJACrAAAEAAIJYhjoJACrAAAAAA==.',
['缸之']='缸之炼铜术士:BAABLgAECn8ZAAQFAAkJTB2QAwC2AgAFAAkJ3BWQAwC2AgAGAAkJnRhSHQCmAgAHAAcJoRfsBAAkAgAAAA==.',
['義丨']='義丨彦祖:BAAALgAECgMJAwAAAA==.',
['聋丶']='聋丶战:BAAALgAECgMJBQAAAA==.',
['联盟']='联盟第一领主:BAAALgAECgMJBAAAAA==.',
['聖丶']='聖丶丨弗蕾亚:BAAALgAECgYJBgAAAA==.',
['肆拾']='肆拾壹号:BAAALgAFFAIJAgAAAA==.肆拾陆号:BAAALgAFFAEJAgAAAA==.',
['肖俊']='肖俊一鸣:BAAALgAECgMJAwAAAA==.',
['胖揍']='胖揍一顿:BAABLgAFFH8FAAIWAAMJBgvwFQDFAAAWAAMJBgvwFQDFAAAAAA==.',
['胡桃']='胡桃贝贝:BAAALgAECgEJAQAAAA==.',
['胸口']='胸口一撮毛:BAAALgAECgYJCwAAAA==.',
['自由']='自由行走的花:BAAALgADCgUJBQAAAA==.',
['致命']='致命牛牛:BAABLgAECn8YAAIBAAgJIBedCgDVAQABAAgJIBedCgDVAQAAAA==.致命脉动:BAABLgAECn8ZAAIIAAgJ7B0PDwDDAgAIAAgJ7B0PDwDDAgAAAA==.',
['舔包']='舔包妙手:BAAALgAECgcJBwABLgAFFAUJAQAVAAAAAA==.',
['舞鹤']='舞鹤:BAAALgAFFAIJAwAAAA==.',
['芒果']='芒果哦:BAAALgAFFAEJAQAAAA==.',
['芙宁']='芙宁娜的狗:BAAALgAFFAQJBAAAAA==.',
['花开']='花开凉凉丶:BAAALgAECgUJBQAAAA==.',
['苍月']='苍月:BAAALgADCgEJAQAAAA==.',
['苏打']='苏打水:BAAALgAECgEJAQAAAA==.',
['苏沄']='苏沄:BAAALgAFFAEJAQAAAA==.',
['茜特']='茜特拉莉的狗:BAABLgAFFH8IAAILAAQJbB0oGABpAQALAAQJbB0oGABpAQAAAA==.',
['茶浦']='茶浦:BAAALgAFFAEJAQAAAA==.',
['茸爪']='茸爪:BAAALgAFFAEJAQAAAA==.',
['草莓']='草莓味胳肢窝:BAAALgAFFAQJBAAAAA==.',
['荒天']='荒天谛:BAAALgAECgEJAQAAAA==.',
['莫格']='莫格莱妮妮:BAAALgAECgMJAwAAAA==.',
['莽才']='莽才是真:BAAALgAECgcJBwAAAA==.',
['莽阳']='莽阳阳丶:BAAALgAECgQJBAAAAA==.',
['菇菇']='菇菇德:BAAALgAECgYJBgAAAA==.',
['萌萌']='萌萌丶子:BAAALgAECgQJBgAAAA==.萌萌大白兔:BAAALgADCgUJBQAAAA==.萌萌小兔:BAABLgAFFH8FAAMXAAIJmQvDBwA5AAAKAAEJDAm+NABOAAAXAAEJJg7DBwA5AAAAAA==.',
['萨斯']='萨斯恺:BAAALgAECgMJAwAAAA==.',
['萨萨']='萨萨牧:BAACLgAFFH8KAAISAAQJahbVCABQAQASAAQJahbVCABQAQAuAAQKfxsAAxIACAkmH4wHAMkCABIACAkmH4wHAMkCAB0ABAnhEGZYANMAAAAA.',
['落叶']='落叶止秋:BAAALgAECgcJDQAAAA==.',
['落小']='落小橙:BAABLgAFFH8GAAIKAAMJ6hwWCAAPAQAKAAMJ6hwWCAAPAQAAAA==.',
['落银']='落银流光:BAAALgAECgEJAQAAAA==.',
['蒂兰']='蒂兰圣雪:BAAALgADCgEJAQAAAA==.',
['蒙阳']='蒙阳阳丶:BAAALgAECgUJBwAAAA==.',
['蒸发']='蒸发:BAAALgAECgIJAgAAAA==.',
['蔓步']='蔓步人生:BAAALgAECggJCAABLgAFFAUJDgAJANEiAA==.',
['蔺丶']='蔺丶白:BAAALgAFFAEJAQAAAA==.',
['薄情']='薄情丶雪:BAAALgAFFAIJBAAAAA==.',
['薄荷']='薄荷和酒丶贰:BAAALgAECgYJBwAAAA==.',
['薇薇']='薇薇黯:BAAALgAECgEJAQAAAA==.',
['藍點']='藍點:BAAALgAFFAIJAwAAAA==.',
['蛋姆']='蛋姆:BAABLgAFFH8FAAILAAIJUQQPSwCSAAALAAIJUQQPSwCSAAAAAA==.',
['蛮蛮']='蛮蛮宝宝:BAAALgAFFAIJBAAAAA==.',
['蠢得']='蠢得真像你:BAAALgAECgYJDwAAAA==.',
['血刺']='血刺猬:BAAALgAECgYJCQAAAA==.',
['血色']='血色圣光:BAAALgAECgMJAwAAAA==.',
['血魂']='血魂:BAAALgAFFAUJAQAAAA==.',
['言初']='言初:BAAALgAECgEJBQAAAA==.',
['请老']='请老祖升兲:BAAALgAECgQJBAAAAA==.请老祖升天:BAABLgAECn8VAAMeAAcJgB+xEAB2AgAeAAcJjR6xEAB2AgAWAAMJtCBzSgAZAQAAAA==.',
['贰爷']='贰爷霸气:BAAALgAECgQJCwAAAA==.',
['贰牛']='贰牛:BAAALgAECgIJAgAAAA==.',
['赤焰']='赤焰雄狮:BAAALgAECgMJAwAAAA==.',
['踏碎']='踏碎琉璃月:BAAALgAECgYJBgAAAA==.',
['輸出']='輸出低还犟嘴:BAAALgAECggJEAAAAA==.',
['轰贰']='轰贰零:BAAALgAECgYJBwAAAA==.',
['轰龙']='轰龙龙:BAAALgAECgIJAgAAAA==.',
['达利']='达利特:BAAALgAECgMJAwAAAA==.',
['还有']='还有陪的话:BAAALgAECgcJEgAAAA==.',
['远辰']='远辰:BAAALgAECgEJAQAAAA==.',
['迫真']='迫真裏技:BAAALgAECgEJAQAAAA==.',
['追月']='追月:BAAALgAECggJDwAAAA==.',
['逆者']='逆者求心:BAAALgADCgYJBgAAAA==.',
['逢坂']='逢坂大河丶:BAABLgAFFH8FAAIQAAMJLxkoDwD1AAAQAAMJLxkoDwD1AAAAAA==.',
['遇朮']='遇朮臨瘋:BAAALgADCgEJAQAAAA==.',
['遠坂']='遠坂丶凛:BAAALgADCgcJBwABLgAECgEJBQAVAAAAAA==.',
['那不']='那不勒斯:BAAALgADCgMJAwAAAA==.',
['那阿']='那阿爷:BAAALgAECgQJBAAAAA==.',
['邪能']='邪能木偶:BAAALgAECgUJBQAAAA==.',
['郡肝']='郡肝:BAAALgAECgEJAgAAAA==.',
['部落']='部落丶大酋长:BAABLgAECn8VAAILAAgJZw1rjgC2AQALAAgJZw1rjgC2AQAAAA==.部落神射手:BAAALgAECgQJBwAAAA==.',
['酔蒅']='酔蒅紅塵:BAAALgADCgUJBQAAAA==.',
['醉今']='醉今朝:BAAALgAECgQJBAAAAA==.',
['采魔']='采魔菇的姑娘:BAAALgAECgYJAgAAAA==.',
['重新']='重新归来:BAAALgAECgEJAQAAAA==.',
['野德']='野德向曰葵:BAAALgAECgQJBQAAAA==.',
['镇嶽']='镇嶽:BAAALgAECgUJBQAAAA==.',
['长公']='长公主:BAAALgAECgEJAQAAAA==.',
['长街']='长街听风:BAABLgAFFH8LAAISAAYJKCEiAAB8AgASAAYJKCEiAAB8AgAAAA==.',
['闭月']='闭月羞花嫣:BAAALgAFFAMJBAAAAA==.',
['闭眼']='闭眼随便打:BAAALgAECgkJCQAAAA==.',
['闲思']='闲思君:BAAALgADCgIJAgAAAA==.',
['阳穿']='阳穿三叶:BAAALgADCgEJAQAAAA==.',
['阴郁']='阴郁的捣蛋猫:BAAALgAECgYJCAAAAA==.',
['阿毗']='阿毗地狱:BAAALgADCgYJAQAAAA==.',
['阿神']='阿神:BAACLgAFFH8KAAILAAQJfBRNCABeAQALAAQJfBRNCABeAQAuAAQKfxUAAgsACQloGLVNAE4CAAsACQloGLVNAE4CAAAA.',
['阿薾']='阿薾萨斯:BAAALgAECgUJBQAAAA==.',
['陈年']='陈年老酒:BAAALgAECgEJAQAAAA==.',
['陶渊']='陶渊铭:BAAALgAECgYJBgAAAA==.',
['隐形']='隐形哎孤独:BAAALgAECgMJAwAAAA==.',
['隕落']='隕落殤逝:BAACLgAFFH8KAAIdAAQJFBPJBwDuAAAdAAQJFRPJBwDuAAAuAAQKfxoAAh0ABwlDHvoPAGYCAB0ABwlDHvoPAGYCAAAA.',
['隨你']='隨你愛咋咋滴:BAABLgAFFH8HAAIBAAIJZh18NgCuAAABAAIJZh18NgCuAAAAAA==.',
['雨之']='雨之狂:BAAALgAECgEJAQAAAA==.',
['雨声']='雨声:BAAALgAECgEJAQAAAA==.',
['雨季']='雨季:BAACLgAFFH8JAAIRAAQJtht6BwBpAQARAAQJtht6BwBpAQAuAAQKfxcAAxEABwmlJPsPAKMCABEABwmlJPsPAKMCABoAAQkAANAvADYAAAAA.',
['雪糕']='雪糕:BAAALgADCgYJBgAAAA==.雪糕刺客:BAACLgAFFH8GAAMbAAMJkA92FACsAAAbAAIJORZ2FACsAAAfAAEJPwIVBwBTAAAuAAQKfxgAAxsACAkdEdcdAA8CABsACAkdEdcdAA8CAB8AAgkKBewZAFsAAAAA.',
['雪落']='雪落無霜:BAAALgAECgQJAQAAAA==.',
['雪飘']='雪飘千:BAAALgADCgUJBQAAAA==.',
['雲雀']='雲雀恭弥:BAAALgAECgYJCwAAAA==.',
['雷霆']='雷霆吖:BAAALgAFFAIJAgAAAA==.雷霆鸭:BAAALgAFFAIJAwAAAA==.',
['霆哥']='霆哥:BAAALgAECgcJCAAAAA==.',
['青山']='青山知可子:BAAALgAECgQJBAAAAA==.',
['非凡']='非凡信仰:BAAALgADCgIJAgABLgAFFAcJBQAgANEWAA==.',
['非洲']='非洲惊奇男孩:BAAALgAECgYJBwAAAA==.',
['顺我']='顺我昌逆我亡:BAABLgAFFH8IAAMBAAMJ7x4sJwD6AAABAAMJERIsJwD6AAAZAAMJ7x4AAAAAAAAAAA==.',
['颖宝']='颖宝小迷妹:BAAALgAECgIJAgAAAA==.',
['颜洛']='颜洛直:BAAALgADCgEJAQAAAA==.',
['風之']='風之斬:BAAALgADCgMJAwAAAA==.',
['风不']='风不止:BAAALgAECgQJBAAAAA==.',
['风之']='风之羽:BAAALgAECgYJBgAAAA==.',
['风暴']='风暴裁决:BAAALgAECgYJBwAAAA==.',
['风行']='风行者丨乾寅:BAAALgAECgYJDQAAAA==.风行者丨未歆:BAAALgAECgYJDAAAAA==.风行者丨魔:BAAALgAECgYJEQAAAA==.风行者蒂诺:BAAALgAECgYJDQAAAA==.风行者贝影:BAAALgAECgcJDwAAAA==.风行逐风者:BAAALgAECgcJEwAAAA==.',
['风语']='风语者勋:BAAALgAECgkJCQAAAA==.',
['风随']='风随心动:BAAALgAFFAEJAQAAAA==.',
['风骚']='风骚小蛮犇丶:BAABLgAFFH8MAAIgAAQJuCH3AACYAQAgAAQJuCH3AACYAQAAAA==.风骚老张:BAAALgAECgYJBgAAAA==.',
['飘渺']='飘渺丶:BAABLgAFFH8FAAILAAIJsgskQACuAAALAAIJsgskQACuAAAAAA==.',
['食傲']='食傲天:BAAALgADCgEJAQAAAA==.',
['饿狼']='饿狼下山:BAAALgAECgQJBAAAAA==.饿狼岀山:BAAALgAECgkJEQAAAA==.',
['骨里']='骨里拿渣:BAAALgAECgEJAQAAAA==.',
['鬼咒']='鬼咒:BAAALgADCgkJCQAAAA==.',
['魂绕']='魂绕俏佳人:BAABLgAECn8WAAIeAAcJeRdZGwACAgAeAAcJeRdZGwACAgAAAA==.',
['魔之']='魔之曉魚:BAAALgAECgYJDAAAAA==.魔之魚:BAAALgAECgYJEAAAAA==.',
['魔兽']='魔兽变:BAAALgADCgUJBgAAAA==.',
['魔王']='魔王之盾:BAAALgAECgYJAQAAAA==.',
['鱼子']='鱼子酱丶:BAAALgAECgUJBgAAAA==.',
['鲜血']='鲜血爱好者:BAAALgAECgUJBQAAAA==.',
['鳕丨']='鳕丨丨夜:BAAALgAECgYJCgAAAA==.鳕丨夜:BAAALgAECgIJAgAAAA==.鳕丨烨:BAAALgAECgUJBQAAAA==.',
['鸿双']='鸿双唔:BAAALgAECgEJAQAAAA==.',
['鹿北']='鹿北:BAAALgAECgIJAgAAAA==.',
['鹿南']='鹿南:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗中的荣光:BAAALgAECgIJAQAAAA==.',
['黑桐']='黑桐未娜:BAACLgAFFH8VAAILAAYJxh7nAgBUAgALAAYJxh7nAgBUAgAuAAQKfxsAAgsACAlDJfsMAF0DAAsACAlDJfsMAF0DAAAA.',
['黑霸']='黑霸:BAAALgADCgcJCQAAAA==.',
['龌龊']='龌龊小排:BAAALgAECgYJCwAAAA==.',
['龍貓']='龍貓萨蛮:BAAALgAECgQJBAABLgAFFAYJEwAEACggAA==.',
['龙乐']='龙乐天:BAAALgAECgUJBQAAAA==.',
['龙凤']='龙凤依繁华:BAAALgAECgEJAQAAAA==.',
['龙岗']='龙岗无敌手:BAAALgADCgEJAQAAAA==.',
['龙年']='龙年限定:BAAALgAECgUJBQAAAA==.',
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
