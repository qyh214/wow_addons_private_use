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

local lookup = {'Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Warrior-Fury','Warrior-Arms','Warrior-Protection','Priest-Holy','Evoker-Preservation','Warlock-Destruction','Warlock-Demonology','Evoker-Augmentation','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Priest-Shadow','Evoker-Devastation','Monk-Mistweaver','Paladin-Protection','Druid-Balance','Druid-Restoration','Monk-Brewmaster','Monk-Windwalker','Shaman-Restoration','Shaman-Elemental','Warlock-Affliction','DemonHunter-Havoc','DemonHunter-Devourer','DemonHunter-Vengeance','DeathKnight-Blood','Shaman-Enhancement','Priest-Discipline','Rogue-Subtlety','Rogue-Assassination','Druid-Guardian',}
local provider = {region='CN',realm='诺兹多姆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aemeath:BAAALgAECgMJBAAAAA==.',
Al='Alexstraszs:BAAALgADCgcJBwABLgAECgQJBQABAAAAAA==.',
An='Annahill:BAAALgAECgMJAgAAAA==.',
Ap='Appig:BAAALgAECgQJBAAAAA==.',
Av='Ave:BAABLgAFFH8JAAICAAQJSBoiEQBdAQACAAQJSBoiEQBdAQAAAA==.',
Bl='Blimbo:BAAALgAECgEJAgAAAA==.Bloodyknigt:BAACLgAFFH8VAAIDAAYJIx1FAQAjAgADAAYJIx1FAQAjAgAuAAQKfyEAAgMACQnAJF4DAJ0DAAMACQnAJF4DAJ0DAAAA.',
By='Byakuren:BAAALgAECgYJEgABLgAFFAUJEAAEAFwdAA==.',
Ca='Caizan:BAAALgAECgIJBAAAAA==.Calia:BAACLgAFFH8RAAMFAAUJfiEEBgCPAQAFAAUJfiEEBgCPAQAGAAMJahZ8BADmAAAuAAQKfyMAAwUACAn6IokNAOoCAAUABwmjJYkNAOoCAAYAAgnuGqkuAIAAAAEuAAUUBwkNAAcAzhkA.Cammy:BAAALgAECgIJAQAAAA==.',
Co='Coldkiller:BAAALgADCgkJCQAAAA==.',
Cu='Cutepsyduck:BAAALgAECgUJBQAAAA==.',
Da='Darkfortres:BAAALgAECgIJAgAAAA==.',
Do='Do:BAAALgADCgMJAwAAAA==.',
En='Enozomuprise:BAAALgAECgYJCAAAAA==.',
Es='Esarus:BAACLgAFFH8IAAIDAAQJhxKFCwBQAQADAAQJhxKFCwBQAQAuAAQKfykAAgMABwn3I5EFAF0CAAMABwn3I5EFAF0CAAAA.',
Ey='Eyns:BAAALgAECgUJBQAAAA==.',
Fe='Featherwing:BAAALgAECgYJEgAAAA==.Featheryarns:BAACLgAFFH8QAAIIAAUJux3XAADiAQAIAAUJux3XAADiAQAuAAQKfysAAggACAnLI9sCADQDAAgACAnLI9sCADQDAAAA.',
Fk='Fklax:BAAALgAECgYJBgAAAA==.',
Fr='Fryrue:BAAALgAECgYJBwAAAA==.',
Ga='Gameboyb:BAAALgADCgIJAgAAAA==.',
Gg='Ggbeng:BAAALgAECgEJAQAAAA==.',
Go='Goldenbest:BAAALgAFFAEJAQAAAA==.',
Gr='Grailss:BAAALgAECgcJDgAAAA==.',
Ha='Halanir:BAAALgAFFAIJAgAAAA==.',
Hy='Hyacinths:BAAALgAECgMJAwABLgAECggJHQAJAIgfAA==.',
Ja='Janebabe:BAAALgADCgUJBQABLgAECgIJAgABAAAAAA==.',
Jo='Joe:BAAALgAFFAIJBAAAAA==.Jonah:BAAALgAECgEJAQAAAA==.Jordnær:BAABLgAFFH8IAAMKAAYJrxzrBAAxAQAKAAMJviHrBAAxAQALAAMJFxXYGAAqAQAAAA==.',
Ka='Kaopu:BAAALgAECgIJAgAAAA==.',
La='Lansmith:BAAALgAFFAEJAQAAAA==.',
Le='Leiha:BAACLgAFFH8QAAIEAAUJXB3HDAC2AQAEAAUJXB3HDAC2AQAuAAQKfysAAgQACAmkI68FAHcCAAQACAmkI68FAHcCAAAA.',
Li='Liftshertail:BAABLgAFFH8HAAIMAAMJjhCOEQD0AAAMAAMJjhCOEQD0AAAAAA==.',
Lu='Luclfer:BAAALgADCgEJAQAAAA==.Lux:BAAALgAFFAIJAgAAAA==.',
Ma='Magicalcelo:BAAALgAFFAEJAQAAAA==.',
Mi='Mimos:BAABLgAECn8dAAIJAAgJiB97CACzAgAJAAgJiB97CACzAgAAAA==.Miserae:BAAALgAFFAEJAQAAAA==.Mixyx:BAAALgAECgUJBQAAAA==.',
My='Myf:BAAALgADCgYJBgAAAA==.',
Ne='Nehalem:BAAALgAECgEJAQAAAA==.Nesingwary:BAAALgAECgYJBgAAAA==.Nevermore:BAAALgAECgkJDgAAAA==.Nevermores:BAAALgAFFAEJAQAAAA==.',
No='Nozdormua:BAAALgAECgQJBQAAAA==.',
Ol='Olivelu:BAAALgAECgkJCgAAAA==.',
Pa='Paparazzi:BAAALgAECgcJBQAAAA==.',
Sa='Sabertyan:BAAALgAECgYJBgABLgAFFAYJDgAGANUkAA==.Sabomorton:BAAALgAFFAEJAQABLgAFFAIJBAABAAAAAA==.',
Sb='Sbyoung:BAACLgAFFH8HAAIDAAMJFyMODwAwAQADAAMJFyMODwAwAQAuAAQKfyAAAgMABwmbIpYcAL8CAAMABwmbIpYcAL8CAAAA.',
Sc='Schols:BAAALgAECgYJDgAAAA==.Scotus:BAAALgAFFAIJBAAAAA==.',
Se='Servine:BAACLgAFFH8MAAQNAAQJ+CGDEADEAAAOAAMJSSAMEgAZAQANAAIJxSGDEADEAAAPAAEJ3R6VBwBnAAAuAAQKfyYABA4ACAmtHnoSAKACAA4ABwmJInoSAKACAA8ABQmxGlkHAG0BAA0AAwmtIYdsACIBAAAA.Sevenz:BAAALgAECgcJAwAAAA==.',
Si='Sippitsu:BAAALgAECgUJBQAAAA==.',
Sl='Slex:BAAALgAECgYJCwAAAA==.Slowstep:BAAALgADCgMJAwAAAA==.',
So='Sonyx:BAAALgAECgYJBgAAAA==.Sonyxx:BAABLgAFFH8GAAICAAQJhhWxFgBJAQACAAQJhhWxFgBJAQAAAA==.',
Sw='Swaranaa:BAABLgAFFH8LAAIQAAQJiB4KBQCBAQAQAAQJiB4KBQCBAQAAAA==.',
Ta='Tapirus:BAAALgAECgQJBAAAAA==.Taregosa:BAAALgAECgcJAgAAAA==.',
Th='Thh:BAACLgAFFH8RAAILAAUJ3CBXAwDvAQALAAUJ3CBXAwDvAQAuAAQKfx8AAgsABwl8JI4YAMECAAsABwl8JI4YAMECAAAA.',
To='Tosld:BAAALgAECgYJBgAAAA==.Toylc:BAAALgAECgEJAQAAAA==.',
Tu='Tutankamen:BAAALgAFFAIJBAAAAA==.',
Tw='Twistdlck:BAAALgAECgYJBQAAAA==.',
Ty='Tyrand:BAAALgAECgUJBQAAAA==.',
Ve='Vescovo:BAACLgAFFH8XAAQJAAYJ/CJ3AgCVAQAJAAUJfCN3AgCVAQAMAAMJghdrEAD+AAARAAQJkxteAQDRAAAuAAQKfygABAkACQmoIpgEAAgDAAkACAnbIpgEAAgDABEACQlDI1sAAI4CAAwABAkpJQIjAKYBAAAA.Vesstya:BAAALgAECgYJBgAAAA==.',
Vi='Viden:BAABLgAFFH8FAAISAAIJNRssDgC7AAASAAIJNRssDgC7AAABLgAFFAYJFwAJAPwiAA==.Violish:BAAALgAFFAQJBAAAAA==.',
Vo='Vonheimdall:BAAALgAFFAQJBAAAAA==.',
Xy='Xyaa:BAAALgAECgIJAgAAAA==.',
Ym='Ymik:BAAALgADCgEJAQAAAA==.',
Yo='Yoisaki:BAAALgAECgcJBwAAAA==.',
Ys='Ysstxdy:BAAALgAECgYJDAAAAA==.',
Yu='Yuukiasuna:BAAALgADCgEJAQAAAA==.',
Za='Zapdos:BAAALgAECgUJBQAAAA==.',
['一晓']='一晓风残月一:BAAALgAECgYJDwAAAA==.',
['一枚']='一枚小土豆:BAAALgAECgMJAwAAAA==.',
['一桶']='一桶江湖:BAAALgADCgEJAQAAAA==.',
['一种']='一种相思:BAACLgAFFH8NAAMDAAUJOxvhCQBeAQADAAQJOxvhCQBeAQATAAQJ5gs4AgDtAAAuAAQKfyUAAwMACAlEJHEKAD0DAAMACAlEJHEKAD0DABMABwkgGoUDALMBAAAA.',
['一秒']='一秒三刀:BAAALgAECgQJBAAAAA==.',
['一笑']='一笑很倾城:BAAALgAECgcJCAAAAA==.',
['一筐']='一筐小土豆:BAAALgAFFAQJAgAAAA==.',
['一箱']='一箱小土豆:BAAALgADCgcJBwAAAA==.',
['一起']='一起恰饭吧:BAACLgAFFH8OAAMLAAUJqBRWCQBIAQALAAUJqBRWCQBIAQAKAAIJOAWODgCWAAAuAAQKfx8AAwoACQmtIBkMAAECAAsABwlTIG8uAFMCAAoABgkFHhkMAAECAAAA.',
['一颗']='一颗小土豆:BAAALgAECgYJCQAAAA==.',
['一鸭']='一鸭一鸭油:BAAALgAECgYJBwAAAA==.',
['七嘴']='七嘴八舌:BAAALgAECgUJBQAAAA==.',
['七武']='七武海张大姐:BAAALgAECgEJAQAAAA==.',
['七老']='七老八十:BAAALgAECggJCAAAAA==.',
['七荤']='七荤八素:BAAALgAECggJCAAAAA==.',
['七长']='七长八短:BAAALgADCgMJAwAAAA==.',
['七零']='七零八碎:BAAALgAECgcJDQAAAA==.',
['三七']='三七丿二十一:BAABLgAFFH8GAAIEAAIJpRe4OwC0AAAEAAIJpRe4OwC0AAAAAA==.',
['三刀']='三刀流一闪:BAAALgADCgEJAQAAAA==.',
['三匹']='三匹狼:BAAALgADCgYJBgAAAA==.',
['三千']='三千彴彴:BAAALgAFFAEJAQAAAA==.三千灼灼:BAABLgAFFH8HAAICAAMJuyCgHgAkAQACAAMJuyCgHgAkAQABLgAFFAcJDQACAGUkAA==.',
['三姐']='三姐姐:BAAALgADCgUJBQAAAA==.',
['三水']='三水叔叔爱你:BAACLgAFFH8FAAILAAMJuQdvJgCBAAALAAMJuQdvJgCBAAAuAAQKfxYAAwsACAnaGLkuAFICAAsACAnaGLkuAFICAAoAAQkAAON+ABoAAAAA.',
['三牟']='三牟四清:BAAALgAECgIJAgAAAA==.',
['三非']='三非宝宝:BAAALgAECgYJAQAAAA==.',
['三食']='三食的烦恼:BAAALgAECgQJBAAAAA==.',
['不吃']='不吃牛肉:BAAALgADCgcJCwAAAA==.',
['不拒']='不拒绝不负责:BAAALgAFFAIJBAAAAA==.',
['不服']='不服才练一个:BAAALgAECgQJBQAAAA==.',
['不言']='不言:BAAALgADCgEJAQAAAA==.',
['业火']='业火红莲:BAAALgADCgEJAgAAAA==.',
['东蜀']='东蜀黍:BAAALgAECgYJCwAAAA==.',
['东门']='东门口第一帅:BAAALgAFFAEJAQAAAA==.东门口第五帅:BAAALgAECgUJBQAAAA==.',
['丨优']='丨优迪安丨:BAAALgADCgEJAQAAAA==.',
['丨可']='丨可爱的我丨:BAAALgAECgcJCAAAAA==.',
['丨或']='丨或跃在渊丨:BAAALgAECgIJAgAAAA==.',
['丨栗']='丨栗山未来:BAAALgAECgYJBgAAAA==.',
['丨泰']='丨泰拦德丨:BAAALgAECgYJBgAAAA==.',
['丨风']='丨风灵月影丨:BAAALgAECgYJEAABLgAECgYJEgABAAAAAA==.',
['丶丶']='丶丶空空:BAAALgAECgcJCQAAAA==.',
['丶以']='丶以德服人丶:BAAALgAECgIJAgAAAA==.',
['丶小']='丶小鸟游六花:BAAALgADCgcJBwAAAA==.',
['丶斯']='丶斯塔丶:BAAALgAECgQJCAAAAA==.',
['丶灬']='丶灬:BAAALgAECgMJAwAAAA==.',
['丶猎']='丶猎星空丿:BAAALgAFFAEJAgAAAA==.',
['丶青']='丶青青子衿:BAAALgAECgQJBAAAAA==.',
['为了']='为了武僧:BAAALgAECgEJAQAAAA==.',
['为面']='为面包而战:BAAALgAECgMJBAAAAA==.',
['之乎']='之乎醉也:BAAALgADCgQJBAAAAA==.',
['乖乖']='乖乖帕吉:BAAALgAFFAIJAgAAAA==.',
['九幽']='九幽丄淡定:BAAALgADCgEJAQAAAA==.',
['乱魔']='乱魔:BAAALgAECgMJBAAAAA==.',
['二刺']='二刺猿:BAAALgAFFAQJBAAAAA==.',
['二岚']='二岚:BAAALgAECgYJCwAAAA==.',
['二阶']='二阶堂希罗:BAABLgAFFH8GAAIGAAMJBAlqBADsAAAGAAMJBAlqBADsAAAAAA==.',
['云深']='云深不归处:BAAALgADCgEJAQAAAA==.',
['云飞']='云飞燕:BAAALgAECgUJBQAAAA==.',
['亞榭']='亞榭落:BAABLgAFFH8LAAICAAQJ8x9TCgB/AQACAAQJ8x9TCgB/AQAAAA==.',
['亡者']='亡者之力:BAAALgAECgQJCAAAAA==.',
['人生']='人生逃避號:BAAALgAFFAIJAgAAAA==.',
['人间']='人间叛卖黄昏:BAAALgAECgIJAwAAAA==.人间水蜜桃:BAAALgAFFAEJAQAAAA==.',
['仙尊']='仙尊:BAAALgADCgcJBwAAAA==.',
['任法']='任法兽角虎:BAAALgAECgQJAgAAAA==.',
['伊格']='伊格鲁迪:BAAALgAECgQJCQAAAA==.',
['伊莎']='伊莎利斯:BAAALgAECgMJAwAAAA==.',
['优秀']='优秀员工:BAAALgADCgYJBgAAAA==.',
['伞伞']='伞伞妹:BAAALgAFFAIJAgAAAA==.',
['伤心']='伤心小树莓:BAAALgADCgEJAQAAAA==.',
['似此']='似此如之奈何:BAAALgAECgEJAQAAAA==.',
['似锦']='似锦:BAAALgAECgMJAwAAAA==.',
['佐鼬']='佐鼬为难:BAAALgAECgQJBgAAAA==.',
['佛啵']='佛啵乐:BAAALgAECgcJBwAAAA==.',
['佛波']='佛波乐:BAAALgAECggJEAAAAA==.',
['佛耶']='佛耶戈:BAAALgAECgQJCAAAAA==.',
['佟老']='佟老板:BAABLgAFFH8FAAINAAMJ1xG8CgADAQANAAMJ1xG8CgADAQAAAA==.佟老板丶圣:BAAALgAECgUJBQAAAA==.',
['你也']='你也晚安好梦:BAAALgAECgUJBQAAAA==.',
['你宠']='你宠爱的人:BAAALgAECgYJBwAAAA==.',
['你这']='你这是死劲:BAAALgADCgIJAgAAAA==.',
['你霉']='你霉柿吧:BAAALgAECgMJAwAAAA==.',
['保安']='保安室大队长:BAAALgADCgEJAQAAAA==.',
['保护']='保护大橘:BAAALgAECgQJBQAAAA==.',
['俞玲']='俞玲:BAAALgAFFAIJAwAAAA==.',
['信仰']='信仰沦陷:BAAALgAFFAIJAgAAAA==.',
['信信']='信信哥:BAAALgAECgEJAQAAAA==.',
['俺老']='俺老牛又来了:BAABLgAFFH8GAAMUAAMJ6QcaEADgAAAUAAMJ6QcaEADgAAAVAAEJYiCdIQBeAAAAAA==.',
['健山']='健山雏:BAABLgAFFH8FAAIUAAIJAhpYEgCxAAAUAAIJAhpYEgCxAAAAAA==.',
['光明']='光明丶:BAAALgAECgQJCAABLgAECgYJCQABAAAAAA==.',
['光景']='光景:BAAALgAECgUJBgAAAA==.',
['光铸']='光铸丿审判:BAAALgAECgUJBgAAAA==.',
['八奈']='八奈见杏菜:BAAALgAECgEJAQAAAA==.',
['六块']='六块腹肌:BAAALgAFFAIJAgAAAA==.',
['六百']='六百:BAAALgAFFAQJAgAAAA==.',
['兰加']='兰加洛斯:BAAALgADCgMJAwAAAA==.',
['兴兴']='兴兴归来:BAAALgADCgQJBAAAAA==.',
['其实']='其实也无所谓:BAAALgAECgIJBAAAAA==.',
['再别']='再别康桥:BAAALgAECgYJCAAAAA==.',
['冖灬']='冖灬冖:BAACLgAFFH8HAAIWAAMJ9ARIGACsAAAWAAMJ9ARIGACsAAAuAAQKfx0AAxcACAmIFkMiAMQBABcABglNHkMiAMQBABYACAkJD1EqALgBAAAA.',
['冬栀']='冬栀:BAAALgAECgYJBgAAAA==.',
['冬茯']='冬茯苓:BAAALgAECgYJBgAAAA==.',
['冬马']='冬马和纱:BAABLgAFFH8LAAMNAAQJKBW0CAAUAQAOAAQJ+QrPEQAcAQANAAMJuBi0CAAUAQAAAA==.',
['冯河']='冯河:BAAALgAECgUJBQAAAA==.',
['冰冷']='冰冷霜焰:BAAALgADCgcJBwABLgAFFAUJEAAEAAwaAA==.',
['冰封']='冰封死骑:BAAALgAECgcJDwAAAA==.',
['冲之']='冲之:BAAALgADCgEJAQAAAA==.',
['凉秋']='凉秋槿言:BAAALgAECgQJBAAAAA==.',
['凋零']='凋零者:BAAALgAECgEJAQAAAA==.',
['凌紫']='凌紫冥:BAAALgAECgEJAQAAAA==.',
['凌风']='凌风织梦绘璃:BAAALgADCgEJAQAAAA==.',
['凤栖']='凤栖梧桐丨橘:BAAALgAFFAEJAQAAAA==.凤栖梧桐丨蓝:BAABLgAFFH8QAAMYAAQJag1SBgAjAQAYAAQJag1SBgAjAQAZAAQJMwGrEgDGAAAAAA==.',
['别搞']='别搞了:BAAALgAECgMJAwAAAA==.',
['别看']='别看小有宝宝:BAAALgAECgYJCwAAAA==.',
['刺猬']='刺猬小卡尔:BAAALgADCgEJAQAAAA==.',
['剑刃']='剑刃乱舞:BAAALgAECgEJAQAAAA==.',
['剑指']='剑指偏锋:BAAALgADCgUJBQAAAA==.',
['劒御']='劒御九天:BAAALgADCgUJBQAAAA==.',
['加速']='加速同调:BAABLgAECn8WAAISAAYJ9himJACQAQASAAYJ9himJACQAQAAAA==.',
['勿使']='勿使惹尘埃:BAAALgADCgQJBAAAAA==.',
['包凡']='包凡达:BAABLgAECn8VAAQKAAkJRhvnBQB0AgAKAAcJgyDnBQB0AgAaAAYJAR7dCAC6AQALAAIJkAsr6gCGAAAAAA==.',
['包莱']='包莱恩:BAAALgAECgYJBgAAAA==.',
['化了']='化了的鱼丸:BAAALgAECgMJAwAAAA==.',
['北狐']='北狐:BAACLgAFFH8IAAMbAAMJiRLkBQD4AAAbAAMJzxDkBQD4AAAcAAMJ8AvzHQDmAAAuAAQKfywAAxsABwnFJPgIANMCABsABwnFJPgIANMCABwABwk4HusqAFQCAAAA.',
['北觅']='北觅无郁:BAAALgAFFAIJAgAAAA==.北觅无鱼:BAAALgAFFAMJAwAAAA==.',
['十三']='十三世祖:BAAALgAECgYJCgAAAA==.',
['千戀']='千戀乄萬花:BAAALgADCgcJCAAAAA==.',
['千纱']='千纱:BAAALgAECgMJAwAAAA==.',
['华丽']='华丽的叮叮猫:BAACLgAFFH8HAAIdAAQJrw82AQAWAQAdAAQJrw82AQAWAQAuAAQKfzYAAh0ACAmCHuoAADECAB0ACAmCHuoAADECAAAA.',
['华太']='华太极:BAAALgAECgYJDAAAAA==.',
['卓越']='卓越的淘淘:BAAALgAFFAIJAgAAAA==.',
['南方']='南方加班獭獭:BAAALgAECgEJAgAAAA==.',
['卡代']='卡代膻:BAAALgAECgcJBwAAAA==.',
['卡卡']='卡卡冬:BAAALgAECgUJBwAAAA==.',
['卡哇']='卡哇伊宝宝:BAAALgAFFAEJAwAAAA==.',
['卡牛']='卡牛牛:BAABLgAECn8XAAMYAAcJPRRGNgCqAQAYAAcJPRRGNgCqAQAZAAUJlg0qWADkAAAAAA==.',
['卡西']='卡西法煎蛋丶:BAAALgAFFAQJBAAAAA==.卡西法煎蛋灬:BAAALgADCgEJAQAAAA==.',
['卡酥']='卡酥咪:BAAALgAECgEJAQAAAA==.卡酥米:BAAALgAECgYJDAAAAA==.',
['卡雷']='卡雷:BAACLgAFFH8RAAQJAAYJnxJsAgD6AQAJAAYJnxJsAgD6AQARAAEJOSS/BwBuAAAMAAEJaB+rHgBfAAAuAAQKfyEABBEACQlHIhgDAPMCABEACAkmIhgDAPMCAAwACAn0HacKAMsCAAkABQk/IIocAKIBAAAA.',
['卧曹']='卧曹狼:BAAALgADCgUJBwAAAA==.',
['危险']='危险的包:BAAALgAECgEJAQAAAA==.危险的果:BAAALgAECgEJAQAAAA==.危险的鸣:BAAALgAECgEJAQAAAA==.',
['原来']='原来的男人婆:BAAALgAECgYJBgAAAA==.',
['去你']='去你猫猫德:BAAALgADCgEJAQAAAA==.',
['双林']='双林丶水中月:BAAALgAECgcJCgAAAA==.',
['双马']='双马尾卓小妹:BAAALgAECgYJBgABLgAFFAUJEQACAJYfAA==.',
['反补']='反补世界树:BAABLgAFFH8FAAMUAAQJjwHkDgDyAAAUAAQJjwHkDgDyAAAVAAEJxg3HFwBMAAAAAA==.',
['取名']='取名字干嘛啊:BAABLgAFFH8FAAIOAAIJFg1xHwCYAAAOAAIJFg1xHwCYAAAAAA==.',
['古城']='古城萧声灬:BAAALgAECgQJBwAAAA==.',
['古堡']='古堡一游灵:BAAALgAECgYJBgAAAA==.古堡幽灵:BAAALgAECgYJBwAAAA==.',
['古朗']='古朗月明:BAAALgAECggJEAAAAA==.',
['只会']='只会拉毛线:BAAALgAECgQJBgAAAA==.',
['召唤']='召唤师丶卡尔:BAAALgAECgEJAwAAAA==.',
['叮咚']='叮咚鸡曼波:BAACLgAFFH8GAAIcAAMJJhvVIADLAAAcAAMJJhvVIADLAAAuAAQKfxQAAhwABwkRIgobALECABwABwkRIgobALECAAAA.',
['可爱']='可爱的小吉尔:BAAALgAECgQJBAAAAA==.可爱的镓镓:BAAALgADCgEJAQAAAA==.',
['可蕾']='可蕾尔:BAAALgAECgYJBgAAAA==.',
['史上']='史上最牛丶牛:BAAALgADCgQJBAAAAA==.',
['叶新']='叶新:BAAALgAECgIJAwAAAA==.',
['叶落']='叶落抚雾浔:BAAALgAECgEJAQAAAA==.叶落风念兮:BAAALgAECgYJCwAAAA==.',
['叽叽']='叽叽姬骑士:BAAALgAECgYJBgAAAA==.',
['吃遍']='吃遍小餐馆:BAAALgAECgYJCwAAAA==.',
['吉塞']='吉塞尔达:BAAALgAECggJCAAAAA==.',
['吉娜']='吉娜拉:BAAALgADCgQJBAAAAA==.',
['后青']='后青春期的湿:BAAALgADCgUJBQAAAA==.',
['向充']='向充:BAAALgADCgYJBgAAAA==.',
['吕凤']='吕凤:BAAALgAECgYJCwAAAA==.',
['吗喽']='吗喽龙:BAAALgADCgEJAQAAAA==.',
['吴高']='吴高冷:BAAALgAFFAEJAQAAAA==.',
['吸吸']='吸吸血吃吃肉:BAABLgAECn8XAAMLAAgJtRE7GgBnAQALAAgJpQ47GgBnAQAKAAEJ+STsVwBnAAAAAA==.',
['吼叔']='吼叔叔:BAACLgAFFH8RAAMCAAUJlh87BgBcAQACAAQJlh87BgBcAQAeAAEJAAA8EwBZAAAuAAQKfxcAAgIACAn8G/oxAHACAAIACAn8G/oxAHACAAAA.',
['咋回']='咋回事儿:BAAALgAECgYJBgAAAA==.',
['和平']='和平使者:BAAALgAECgYJBwAAAA==.',
['咔咔']='咔咔小丨凯:BAACLgAFFH8GAAICAAMJQg+xKQDzAAACAAMJQg+xKQDzAAAuAAQKfyEAAgIABwkGG7dBADICAAIABwkGG7dBADICAAAA.咔咔小丨坤:BAAALgAFFAEJAQABLgAFFAYJEAACAMUmAA==.',
['咕噜']='咕噜噜噢:BAAALgAECgUJDQAAAA==.',
['咖啡']='咖啡果糖:BAAALgAECgEJAQAAAA==.咖啡真苦:BAAALgAECgYJCQAAAA==.',
['哈尼']='哈尼:BAAALgAECgQJBAAAAA==.',
['哈蕾']='哈蕾尼尔:BAAALgADCgYJBgAAAA==.',
['哥谭']='哥谭顶流:BAAALgAECgMJAwAAAA==.',
['唐诗']='唐诗:BAAALgAFFAQJBAAAAA==.',
['唐门']='唐门之幸:BAAALgAECgEJAQAAAA==.',
['喆太']='喆太极:BAAALgAECgUJBgAAAA==.',
['喜欢']='喜欢触手:BAAALgAECgYJCQAAAA==.',
['嗜血']='嗜血怒击:BAAALgAECgkJCQAAAA==.',
['嗯啼']='嗯啼啊:BAAALgAFFAUJBAAAAA==.',
['嘟捞']='嘟捞捞:BAACLgAFFH8MAAICAAQJviP8AQCaAQACAAQJviP8AQCaAQAuAAQKfx4AAgIABwnnIMApAJICAAIABwnnIMApAJICAAAA.',
['嘬嘬']='嘬嘬你的:BAAALgAECgYJBgAAAA==.',
['嘴哥']='嘴哥很火:BAAALgAFFAEJAQAAAA==.嘴哥蛋蛋:BAABLgAECn8UAAMcAAYJdRZLYACAAQAcAAYJdRZLYACAAQAbAAIJPAPDZQBNAAABLgAFFAEJAQABAAAAAA==.',
['嘻嘻']='嘻嘻小萨:BAAALgAFFAIJBAAAAA==.',
['嘿嘿']='嘿嘿黑黑:BAAALgAECgMJAwAAAA==.',
['嚣张']='嚣张威廉:BAAALgADCgEJAQAAAA==.',
['四箫']='四箫奈何:BAAALgAECgQJBAAAAA==.',
['囧囧']='囧囧如绿令:BAAALgAECgEJAgAAAA==.',
['国师']='国师鸠摩智:BAABLgAFFH8GAAIWAAMJ2hu9DgANAQAWAAMJ2hu9DgANAQABLgAFFAQJEAAEAL4gAA==.',
['圣光']='圣光不忽悠:BAAALgAECgEJAQAAAA==.圣光庇佑着你:BAAALgAECgcJCAAAAA==.圣光指引你:BAAALgAECgcJBwAAAA==.圣光是否:BAAALgADCgEJAQAAAA==.',
['圣言']='圣言术丶罚:BAAALgAFFAQJAgAAAA==.圣言术丶赎:BAAALgAFFAQJBAAAAA==.',
['坍缩']='坍缩之星救我:BAAALgAFFAEJAQAAAA==.',
['坎多']='坎多:BAACLgAFFH8IAAIZAAQJ3hQsCQBMAQAZAAQJ3hQsCQBMAQAuAAQKfyQAAxkACAnFI0QBAKcCABkACAnFI0QBAKcCAB8AAQkAAN0rADYAAAAA.',
['坷垃']='坷垃的信仰:BAABLgAFFH8FAAIYAAUJ7gFVCABDAQAYAAUJ7gFVCABDAQAAAA==.',
['埋在']='埋在心里:BAAALgAECgIJAgAAAA==.',
['堂吉']='堂吉诃德:BAAALgAECgEJAQAAAA==.',
['塵歸']='塵歸塵:BAABLgAECn8dAAIEAAgJAh1VPgB+AgAEAAgJAh1VPgB+AgAAAA==.',
['墨小']='墨小竹:BAAALgAFFAEJAgAAAA==.',
['壮烈']='壮烈丶成仁:BAAALgADCgMJAwAAAA==.',
['夏亚']='夏亚:BAAALgAECgUJBQAAAA==.',
['多喝']='多喝水:BAACLgAFFH8GAAIYAAQJpxDyCQA0AQAYAAQJpxDyCQA0AQAuAAQKfxoAAxgACAlPGi0DAHUCABgACAlPGi0DAHUCABkABQnlGMdCAD0BAAAA.',
['夜雨']='夜雨王子:BAAALgAECgUJBQAAAA==.',
['大十']='大十字军领主:BAAALgAECgkJCQAAAA==.',
['大尾']='大尾巴狐狸:BAAALgADCgUJBQAAAA==.',
['大树']='大树一号:BAABLgAFFH8KAAIVAAQJph41BABlAQAVAAQJph41BABlAQABLgAFFAYJBwAVAIYaAA==.大树树:BAABLgAFFH8NAAIVAAUJ5CGVAQDHAQAVAAUJ5CGVAQDHAQABLgAFFAYJBwAVAIYaAA==.大树根:BAABLgAFFH8HAAIVAAUJjhx/BgBuAQAVAAUJjhx/BgBuAQAAAA==.',
['大洋']='大洋码:BAABLgAECn8aAAMbAAcJQSB5DACaAgAbAAcJQSB5DACaAgAcAAIJ6xJmywBfAAAAAA==.',
['大葱']='大葱无形:BAAALgAECgEJAQAAAA==.',
['大西']='大西王涨献忠:BAAALgAFFAIJBAAAAA==.',
['天外']='天外飞仙:BAAALgAECgkJAQAAAA==.',
['天山']='天山摇摆客:BAAALgAECgcJDAAAAA==.',
['天彩']='天彩彩:BAAALgAECgMJBgAAAA==.',
['天殇']='天殇:BAAALgAECgcJDAAAAA==.',
['天灬']='天灬祭:BAACLgAFFH8PAAMLAAUJKiGIAwDpAQALAAUJKiGIAwDpAQAKAAEJaxIgFABWAAAuAAQKfykAAwsACAnAJJECAKACAAsABwnAJJECAKACAAoAAgk9E0VBALAAAAAA.',
['天灾']='天灾风云:BAAALgADCgMJAwAAAA==.',
['天狼']='天狼星:BAAALgAECgEJAQAAAA==.',
['天王']='天王老子来了:BAAALgADCgMJAwAAAA==.',
['天真']='天真的小吉尔:BAAALgAFFAIJAgAAAA==.',
['天蓝']='天蓝蓝天:BAACLgAFFH8GAAMaAAIJPgvwAgBiAAALAAIJLgasPACYAAAaAAEJGhHwAgBiAAAuAAQKfx4AAwsABwm/EvRjAJ8BAAsABwm/EvRjAJ8BAAoAAgnyD4hTAHMAAAAA.',
['天马']='天马行空萨满:BAAALgAECgYJBwAAAA==.',
['太极']='太极者:BAAALgAECgYJCwAAAA==.',
['夹心']='夹心石榴:BAAALgADCgEJAQAAAA==.夹心西红柿:BAAALgAECgMJAwAAAA==.夹心黄瓜:BAAALgAECgQJBAAAAA==.',
['奈亞']='奈亞拉托提普:BAAALgAECgYJCwAAAA==.',
['奥克']='奥克拉斯:BAAALgAECgYJCwAAAA==.',
['奶味']='奶味蓝:BAAALgAECgYJBgAAAA==.',
['奶士']='奶士奇:BAAALgADCgEJAQAAAA==.',
['奶騎']='奶騎:BAABLgAECn8UAAIZAAcJehlvJwDXAQAZAAcJehlvJwDXAQAAAA==.',
['她是']='她是小矮子:BAAALgAECgkJCQAAAA==.',
['好女']='好女孩灰泽满:BAAALgAECgcJDgAAAA==.',
['妮兔']='妮兔兔:BAAALgAECgYJBwAAAA==.',
['姑德']='姑德猫宁:BAAALgAECgkJBQABLgAFFAUJBAABAAAAAA==.',
['姬崎']='姬崎莉波:BAAALgAECggJCAAAAA==.',
['姹紫']='姹紫嫣红:BAAALgADCgQJBAAAAA==.',
['娱樂']='娱樂王:BAAALgAECgEJAQAAAA==.',
['孤叶']='孤叶凌牛:BAAALgAECgUJCQAAAA==.',
['安洁']='安洁卡特莉娜:BAAALgAECgcJCwAAAA==.',
['宋晓']='宋晓峰:BAAALgAECgYJEAAAAA==.',
['宝琳']='宝琳妹妹:BAAALgAECgYJCwAAAA==.',
['宝贝']='宝贝我喜爱:BAAALgAECgcJCgAAAA==.',
['实力']='实力坑队友:BAABLgAECn8dAAIDAAgJ1x6PHQC5AgADAAgJ1x6PHQC5AgAAAA==.',
['宮羽']='宮羽:BAAALgAECgYJBgAAAA==.',
['寄葉']='寄葉:BAAALgAECgcJCgAAAA==.',
['寒冬']='寒冬一鸡:BAAALgAECgYJBgAAAA==.',
['寒眩']='寒眩:BAAALgAECgQJBQAAAA==.',
['射手']='射手座丶:BAAALgAECgcJBwAAAA==.',
['射杀']='射杀恋人之日:BAAALgAFFAMJBAABLgAFFAMJBQAMAEsPAA==.',
['将臣']='将臣丶:BAAALgAECgYJCgAAAA==.',
['小册']='小册佬:BAAALgAECgEJAQAAAA==.',
['小奶']='小奶瓜很疼:BAAALgAECgIJBQAAAA==.',
['小小']='小小千秋:BAAALgADCgIJAgAAAA==.',
['小峥']='小峥嵘:BAAALgAECggJDAAAAA==.',
['小新']='小新的大象:BAAALgADCgQJBAAAAA==.',
['小旨']='小旨桐:BAAALgAECgIJAgAAAA==.',
['小昭']='小昭:BAAALgAECgEJAQAAAA==.',
['小树']='小树子:BAABLgAFFH8IAAIVAAQJxx+FAgCaAQAVAAQJxx+FAgCaAQABLgAFFAYJBwAVAIYaAA==.小树树:BAABLgAFFH8KAAIVAAQJXiT1AQCzAQAVAAQJXiT1AQCzAQAAAA==.',
['小武']='小武僧:BAABLgAECn8WAAQWAAcJDxxeGQA5AgAWAAcJDxxeGQA5AgASAAIJqwqTXgBVAAAXAAEJxwl8gQAvAAAAAA==.',
['小泽']='小泽爱莉:BAAALgAFFAIJAgAAAA==.小泽的猫爪:BAAALgAECgcJBwAAAA==.',
['小猫']='小猫产生羁绊:BAAALgAECgYJCQAAAA==.',
['小皓']='小皓宇:BAAALgAECgUJCAAAAA==.',
['小睿']='小睿香香:BAAALgAECgcJEQAAAA==.',
['小矮']='小矮砸:BAAALgAECgcJCAAAAA==.',
['小绻']='小绻萌:BAAALgAECgMJAwAAAA==.',
['小领']='小领主:BAAALgAECgkJDQAAAA==.',
['小龙']='小龙包:BAAALgAECgYJCwAAAA==.',
['就怕']='就怕灬来一下:BAAALgAECgcJBgAAAA==.',
['山龙']='山龙隐秀:BAAALgADCgIJAgAAAA==.',
['崩溃']='崩溃:BAABLgAECn8WAAMLAAgJER/4CQD3AQALAAgJER/4CQD3AQAKAAIJ2Bt+RwCYAAAAAA==.',
['巧克']='巧克力味的痰:BAAALgADCgYJDAAAAA==.',
['巨离']='巨离:BAABLgAFFH8IAAILAAQJhxLWCgA8AQALAAQJhxLWCgA8AQAAAA==.',
['巨蛋']='巨蛋牛牛:BAAALgADCgUJBQAAAA==.巨蛋龙龙:BAAALgAECgEJAQAAAA==.',
['巴尔']='巴尔特罗恩:BAAALgAECgQJBAAAAA==.',
['巴巴']='巴巴车司机:BAAALgAECgEJAQAAAA==.',
['布兰']='布兰多艾德:BAAALgAECgYJCAAAAA==.',
['布拉']='布拉格广场:BAAALgAECgYJCQAAAA==.',
['帅哥']='帅哥熊猫人:BAAALgAECgQJCgAAAA==.',
['师从']='师从陈华顺:BAAALgAECgYJBwAAAA==.',
['希凝']='希凝:BAAALgAECgYJCQAAAA==.',
['帕拉']='帕拉迪昂:BAAALgAECgEJAQAAAA==.',
['帝花']='帝花之綉丶:BAAALgAECgYJBwABLgAFFAIJBQAdAHIOAA==.',
['幸运']='幸运灵:BAAALgAECgIJAgABLgAFFAYJEQAJAJ8SAA==.',
['幻化']='幻化做风:BAAALgAFFAIJAwAAAA==.',
['廣場']='廣場靈魂舞王:BAAALgAECgEJAQAAAA==.',
['建筑']='建筑师芙瑞尔:BAECLgAFFH8IAAMDAAMJygbwGQDUAAADAAMJ1gPwGQDUAAATAAIJ3AX9BQBhAAAuAAQKfyYAAwMACAkCEvtcAMwBAAMACAmLEPtcAMwBABMABAnZDy4rALMAAAAA.',
['弯弯']='弯弯月儿:BAAALgADCgYJBgAAAA==.',
['張之']='張之后:BAAALgAECgIJAgABLgAFFAMJCAALAGkgAA==.',
['强化']='强化波比:BAABLgAECn8fAAIJAAgJQxagFQDxAQAJAAgJQxagFQDxAQAAAA==.',
['彡飘']='彡飘落记忆彡:BAAALgAECgIJAgAAAA==.',
['彩虹']='彩虹人丶:BAACLgAFFH8LAAICAAMJxxJIFADzAAACAAMJxxJIFADzAAAuAAQKfxcAAgIACAnkGjUyAG4CAAIACAnkGjUyAG4CAAAA.',
['御风']='御风灬之魂:BAAALgAFFAQJBAAAAA==.',
['微酸']='微酸的加应子:BAAALgAECgYJEAAAAA==.',
['德马']='德马吸丫:BAAALgAECgQJBAAAAA==.',
['心中']='心中的湮灭:BAAALgAFFAEJAQAAAA==.',
['心心']='心心视春草:BAAALgAECgMJAwAAAA==.',
['心未']='心未冷丶风雪:BAAALgAFFAEJAQAAAA==.',
['怒火']='怒火刀男:BAAALgADCgEJAQAAAA==.',
['性感']='性感小怪兽:BAAALgAECgcJBQAAAA==.',
['恋予']='恋予深蓝:BAAALgAECgMJAwABLgAFFAYJEQAJAJ8SAA==.',
['悉尼']='悉尼盒子:BAAALgAFFAEJAQAAAA==.',
['悦儿']='悦儿:BAAALgAECgYJBwAAAA==.',
['意想']='意想:BAAALgAFFAEJAQAAAA==.',
['感恩']='感恩带德:BAAALgAECgUJBwAAAA==.',
['慕红']='慕红袖添香:BAAALgADCgQJBAAAAA==.',
['憨憨']='憨憨德:BAAALgADCgcJBgAAAA==.',
['我不']='我不会冰打:BAAALgADCgQJBAAAAA==.我不是女的:BAAALgAECgYJCAAAAA==.',
['我是']='我是你老舅:BAAALgAECgEJAQAAAA==.',
['我要']='我要揍十个:BAABLgAECn8YAAMNAAgJIRdcLwD0AQANAAgJIRdcLwD0AQAOAAMJyQMPdABtAAAAAA==.',
['戢武']='戢武王玉辞心:BAAALgADCgEJAQAAAA==.',
['戰至']='戰至終章:BAAALgADCgEJAQAAAA==.',
['打工']='打工包:BAAALgAECgkJEAAAAA==.',
['打拳']='打拳的烤鸭:BAAALgADCgEJAQAAAA==.',
['打滚']='打滚:BAAALgAFFAEJAQAAAA==.',
['扣个']='扣个问号:BAAALgAECgEJAQAAAA==.',
['拉特']='拉特诺甘尼斯:BAAALgADCgEJAQAAAA==.',
['拖拉']='拖拉机哥哥:BAAALgAECgYJBgAAAA==.',
['推了']='推了个平头:BAACLgAFFH8FAAISAAMJQwycDADaAAASAAMJQwycDADaAAAuAAQKfxgAAhIABwlvFrUbANsBABIABwlvFrUbANsBAAAA.',
['摧花']='摧花:BAAALgAECgQJBAAAAA==.',
['摩羯']='摩羯:BAAALgAECgYJCAAAAA==.',
['摸了']='摸了摸了:BAAALgADCgEJAQAAAA==.',
['放学']='放学有种别跑:BAABLgAECn8XAAIDAAcJJCEzKwB3AgADAAcJJCEzKwB3AgAAAA==.',
['放牛']='放牛娃大黑牛:BAAALgAECgEJAQAAAA==.',
['故事']='故事细腻灬:BAAALgAECgcJAgAAAA==.',
['救赎']='救赎灬之魔:BAAALgAECgkJDwAAAA==.',
['散失']='散失初号机:BAABLgAECn8ZAAIXAAYJBBsRIgDFAQAXAAYJBBsRIgDFAQAAAA==.散失四号机:BAAALgAECgEJAgAAAA==.',
['敬爱']='敬爱与明天:BAAALgAECgQJBgAAAA==.',
['斩首']='斩首红龙:BAAALgAECgkJAQAAAA==.',
['断水']='断水無痕:BAAALgAFFAMJBAAAAA==.',
['斯迦']='斯迦蒂之眼:BAAALgAFFAMJAwAAAA==.',
['无情']='无情熊掌:BAAALgAECgQJBAAAAA==.',
['无所']='无所谓犋:BAAALgAECgMJBQAAAA==.',
['无敌']='无敌也很寂寞:BAAALgADCgYJBgAAAA==.无敌小钢蛋:BAABLgAFFH8MAAIVAAQJiBdcCQA/AQAVAAQJiBdcCQA/AQAAAA==.',
['无茗']='无茗:BAAALgAECgYJBwAAAA==.',
['日倪']='日倪哥退钱:BAAALgADCgEJAQAAAA==.',
['日历']='日历仙人:BAAALgAECgEJAgAAAA==.',
['明月']='明月照天桥:BAABLgAECn8UAAIDAAcJNhU0WgDUAQADAAcJNhU0WgDUAQAAAA==.',
['星流']='星流霆击:BAAALgADCgEJAQAAAA==.',
['星野']='星野:BAAALgAFFAEJAQAAAA==.',
['晓玥']='晓玥琦姬:BAAALgAECgIJAQAAAA==.',
['晨星']='晨星海伦娜:BAAALgAECgIJBAAAAA==.',
['晴天']='晴天流云:BAAALgAECgUJBQAAAA==.',
['暗之']='暗之鹰:BAAALgAECgMJAwAAAA==.',
['暗喵']='暗喵:BAAALgAFFAQJBAAAAA==.',
['暮云']='暮云合璧:BAAALgAECgcJBwAAAA==.',
['暮烟']='暮烟寒雨:BAAALgAFFAEJAQAAAA==.',
['暮色']='暮色云端:BAAALgAECgMJAwAAAA==.',
['暴徒']='暴徒玄戈:BAACLgAFFH8FAAIcAAQJWANOFQDEAAAcAAQJWANOFQDEAAAuAAQKfyMAAxwACAk9FasWAG8BABwACAk9FasWAG8BABsABgm4CjI3ACkBAAAA.',
['暴虎']='暴虎:BAAALgADCgkJCQAAAA==.',
['最后']='最后一页:BAAALgAECgQJBAAAAA==.',
['月夜']='月夜枕星河:BAACLgAFFH8RAAMNAAYJFhb8AgBtAQANAAQJFBr8AgBtAQAOAAIJIAamGwCoAAAuAAQKfxUAAw0ABwmrI6YhADsCAA0ABwlAI6YhADsCAA4ABAldGzBYAOUAAAAA.月夜狐影:BAAALgAECgEJAQAAAA==.',
['月魔']='月魔断:BAABLgAFFH8GAAICAAQJAxEAGQBBAQACAAQJAxEAGQBBAQAAAA==.',
['有人']='有人在演:BAAALgAECgIJAgAAAA==.',
['有点']='有点无情:BAAALgADCgYJBwAAAA==.',
['有種']='有種放學別跑:BAAALgAECgEJAgAAAA==.',
['有锈']='有锈员工:BAABLgAECn8XAAMWAAcJeSNQCwDXAgAWAAcJeSNQCwDXAgASAAcJlBrFFgANAgAAAA==.',
['朔月']='朔月流火:BAAALgAECgYJDAAAAA==.',
['朗格']='朗格丽娅:BAAALgAECgMJAwAAAA==.',
['木又']='木又寸五:BAAALgAFFAIJAgABLgAFFAYJBwAVAIYaAA==.',
['木槿']='木槿花花:BAACLgAFFH8WAAIHAAYJEBvHAAAkAgAHAAYJEBvHAAAkAgAuAAQKfxgAAgcACAneEloWAKoBAAcACAneEloWAKoBAAAA.',
['杀戮']='杀戮晚宴:BAAALgAECgUJBgAAAA==.',
['李行']='李行舟:BAAALgAECgEJAQAAAA==.',
['杨千']='杨千秋:BAAALgAECgIJAgAAAA==.',
['杰瑞']='杰瑞粑粑:BAAALgAFFAIJAgAAAA==.杰瑞萨满:BAAALgAECgUJCAAAAA==.',
['東雪']='東雪莲:BAAALgAECgEJAQAAAA==.',
['松间']='松间听雪落:BAAALgAECgEJAQAAAA==.',
['林允']='林允儿:BAAALgAFFAEJAwAAAA==.',
['林殊']='林殊哥哥萨满:BAAALgAECgYJCgAAAA==.',
['果贝']='果贝七:BAAALgAECgYJCwAAAA==.',
['枣元']='枣元素:BAAALgAECgYJBgAAAA==.',
['枫之']='枫之露露:BAAALgADCgMJAwAAAA==.',
['枫糖']='枫糖小面包:BAABLgAFFH8KAAIUAAQJ0hwcAwBcAQAUAAQJ0hwcAwBcAQAAAA==.',
['枫诺']='枫诺丶怒风:BAAALgADCgUJBQAAAA==.',
['枯鞠']='枯鞠:BAAALgAECgIJAgAAAA==.',
['柒月']='柒月下丶:BAAALgAFFAIJBAAAAA==.',
['柯基']='柯基糖门狗:BAAALgAECgcJDAAAAA==.',
['柳条']='柳条儿:BAACLgAFFH8NAAMLAAUJXyHHAgD+AQALAAUJXyHHAgD+AQAKAAEJJhybEQBcAAAuAAQKfy8AAwsACAn/JCoFAGgDAAsACAn/JCoFAGgDAAoAAwkOIcsqABYBAAAA.',
['柴糕']='柴糕一顿:BAAALgAFFAIJAgAAAA==.',
['树子']='树子:BAABLgAFFH8HAAIVAAUJQRmjAwCqAQAVAAUJQRmjAwCqAQABLgAFFAYJBwAVAIYaAA==.',
['树根']='树根:BAABLgAFFH8MAAIVAAQJ+yG+AgCRAQAVAAQJ+yG+AgCRAQABLgAFFAYJBwAVAIYaAA==.',
['树皮']='树皮:BAABLgAFFH8NAAIVAAUJFh1lAQDSAQAVAAUJFh1lAQDSAQABLgAFFAYJBwAVAIYaAA==.',
['核动']='核动力柯基:BAABLgAFFH8LAAICAAQJ1xPHFwBGAQACAAQJ1xPHFwBGAQAAAA==.',
['格琳']='格琳:BAAALgAECgEJAQAAAA==.',
['格鲁']='格鲁姆丶寒霜:BAAALgAECgEJAQAAAA==.',
['桂魄']='桂魄流光:BAAALgAECgcJDQAAAA==.',
['梦想']='梦想时见你:BAAALgAECgMJBAAAAA==.',
['梦梦']='梦梦首席备胎:BAAALgAFFAkJAwAAAA==.',
['梦舞']='梦舞之时:BAAALgAECgYJEgAAAA==.',
['横断']='横断十万大山:BAAALgAECgQJAwAAAA==.',
['橘侍']='橘侍:BAAALgADCgcJBwAAAA==.',
['橘子']='橘子的圣光:BAAALgADCgYJBgAAAA==.',
['橙色']='橙色噬元兽:BAACLgAFFH8GAAIUAAMJnSOsCwAwAQAUAAMJnSOsCwAwAQAuAAQKfyQAAxQACQnfInYJAP0CABQABwnQJXYJAP0CABUAAgkRDp6rAG8AAAAA.',
['欧阳']='欧阳旺财:BAAALgAFFAIJAwAAAA==.',
['正在']='正在冲锋:BAAALgAECgEJAQAAAA==.',
['歳月']='歳月无波澜:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡暗鹰:BAAALgAECgYJCgAAAA==.',
['殇丶']='殇丶结弦:BAAALgAFFAIJAwAAAA==.',
['每天']='每天揉眯眯:BAAALgAECgMJAwAAAA==.',
['比嘎']='比嘎豆豆:BAAALgAECgkJEAAAAA==.',
['水凼']='水凼凼:BAAALgADCgQJBAAAAA==.',
['水墨']='水墨云烟:BAAALgAECgcJBQAAAA==.',
['水太']='水太凉:BAAALgAFFAIJAgAAAA==.',
['水穷']='水穷云起:BAAALgAECgYJCgAAAA==.',
['水蓝']='水蓝色诅咒:BAAALgAECgMJAwAAAA==.',
['永煌']='永煌:BAAALgAFFAEJAQAAAA==.',
['永远']='永远的菡菡:BAAALgAECgYJEAAAAA==.',
['汐見']='汐見蛍:BAAALgADCgIJAgAAAA==.',
['沐涵']='沐涵:BAABLgAFFH8LAAIEAAQJThe7DQBKAQAEAAQJThe7DQBKAQAAAA==.',
['沫丶']='沫丶言:BAAALgAECgQJBQAAAA==.',
['沫炎']='沫炎:BAAALgAECgIJAgAAAA==.',
['法力']='法力涌动:BAAALgAECgQJBAAAAA==.',
['泡泡']='泡泡糖带我飞:BAAALgADCgEJAQAAAA==.',
['波波']='波波豪杰:BAAALgADCgkJCgAAAA==.波波骑士:BAAALgAECgYJBgAAAA==.波波魔子:BAAALgADCggJDQAAAA==.',
['泰拉']='泰拉多尔:BAAALgAECgYJEQAAAA==.',
['洛十']='洛十三:BAACLgAFFH8GAAIEAAMJoghCMADzAAAEAAMJoghCMADzAAAuAAQKfxgAAgQABgmBGsF8ANgBAAQABgmBGsF8ANgBAAAA.',
['洛城']='洛城春风满:BAABLgAFFH8FAAICAAIJ7R4/NQCzAAACAAIJ7R4/NQCzAAAAAA==.',
['活死']='活死人丶:BAAALgAECgMJAwAAAA==.',
['流云']='流云若天:BAAALgAECgcJBgAAAA==.',
['流浪']='流浪熊猫:BAAALgAFFAEJAgAAAA==.',
['浮士']='浮士德陆军:BAAALgAECgYJBgAAAA==.',
['海大']='海大贵:BAAALgAFFAIJBAAAAA==.',
['海德']='海德林:BAACLgAFFH8IAAMcAAQJahk6DQBnAQAcAAQJlRc6DQBnAQAbAAEJZhMCDQBSAAAuAAQKfycAAxwACAnjI0EEAHACABwACAnhIkEEAHACABsABQl3H5EeAMoBAAAA.',
['深霜']='深霜:BAAALgAECgEJAQAAAA==.',
['混乱']='混乱善良包:BAAALgAECgYJBgAAAA==.',
['混沌']='混沌领主凯拉:BAAALgAECgUJBQAAAA==.',
['清越']='清越:BAAALgAECgQJBgAAAA==.',
['清雪']='清雪:BAAALgAECgYJBgAAAA==.',
['渎神']='渎神:BAABLgAECn8ZAAQKAAkJ3yMsAACxAwAKAAkJ1iMsAACxAwALAAUJRxiSagCNAQAaAAEJlQ97MQA7AAAAAA==.',
['渡风']='渡风:BAAALgAECgMJAwAAAA==.',
['游侠']='游侠:BAAALgAECgYJCQAAAA==.',
['游城']='游城十代:BAABLgAFFH8FAAIMAAMJSw+iGACgAAAMAAMJSw+iGACgAAAAAA==.',
['湖南']='湖南孙一峰:BAAALgAFFAEJAQAAAA==.',
['满月']='满月很痛苦:BAAALgAFFAIJAgABLgAFFAUJBAABAAAAAA==.满月德德:BAAALgAECgcJAQAAAA==.',
['潇潇']='潇潇木雨:BAAALgADCgEJAQAAAA==.',
['火锅']='火锅微辣不来:BAAALgADCgMJAwAAAA==.',
['灬二']='灬二月灬:BAAALgAFFAEJAQAAAA==.',
['灬浮']='灬浮生未歇:BAAALgAECgYJBgAAAA==.',
['灬神']='灬神無月灬:BAAALgAECgcJBQAAAA==.',
['灬莫']='灬莫莫:BAAALgAFFAIJAgAAAA==.',
['灬麦']='灬麦子:BAAALgAFFAIJBAAAAA==.',
['烈火']='烈火丶:BAAALgAECgYJCQAAAA==.',
['烨叶']='烨叶无眠:BAAALgAECgEJAQAAAA==.',
['烬瞳']='烬瞳:BAAALgAECgcJDAABLgAFFAMJCAALAGkgAA==.',
['無一']='無一:BAAALgADCgIJAgAAAA==.',
['燊祈']='燊祈:BAAALgAECgkJAQAAAA==.',
['爱吃']='爱吃菜焖饭:BAACLgAFFH8HAAILAAMJByU6FQBDAQALAAMJByU6FQBDAQAuAAQKfyEAAgsACAnGJFYBAOgCAAsACAnGJFYBAOgCAAAA.',
['爱来']='爱来了吧:BAAALgAFFAIJBAAAAA==.',
['爱莉']='爱莉西亚:BAAALgAECgEJAQAAAA==.',
['爱说']='爱说藏话:BAAALgAFFAIJAgABLgAFFAYJFAAEAF0jAA==.',
['父爱']='父爱配方:BAAALgADCgUJBQAAAA==.',
['牛油']='牛油包:BAAALgAECgkJDwAAAA==.',
['牛逼']='牛逼哟:BAAALgADCgQJBAAAAA==.',
['牧歌']='牧歌之泪:BAAALgAECgEJAQAAAA==.',
['特德']='特德摩尔:BAAALgAFFAEJAQAAAA==.',
['狐坂']='狐坂若藻:BAAALgAECgcJDgABLgAFFAMJCAAbAIkSAA==.',
['狗蛋']='狗蛋之脚:BAAALgAECgQJBAAAAA==.',
['狱火']='狱火小凤凰:BAACLgAFFH8HAAIDAAMJ3RdTEgATAQADAAMJ3RdTEgATAQAuAAQKfx8AAgMABwn/IN8jAJkCAAMABwn/IN8jAJkCAAAA.',
['狸离']='狸离猫:BAACLgAFFH8OAAMLAAYJ/Bv/AwDgAQALAAUJ1h//AwDgAQAKAAQJrwssBABQAQAuAAQKfxsAAwsACQmKG8QVANMCAAsACQk6GsQVANMCAAoAAwlqG/AvAPsAAAAA.',
['猫猫']='猫猫么咪:BAAALgAECgYJBgAAAA==.',
['玉皇']='玉皇大帝:BAAALgAECggJBgABLgAFFAYJDgAGANUkAA==.',
['玉米']='玉米尛面团:BAAALgAECgYJCgAAAA==.',
['王老']='王老七:BAAALgAECgQJBAAAAA==.',
['玛丽']='玛丽莲萌德:BAABLgAECn8bAAIVAAgJnx/sEwCXAgAVAAgJnx/sEwCXAgAAAA==.',
['玛卡']='玛卡不刷牙:BAABLgAFFH8JAAMNAAMJahWMCQANAQANAAMJ+hOMCQANAQAOAAMJ8Q9JFQDxAAAAAA==.',
['玛露']='玛露塔:BAAALgAECgYJBgAAAA==.',
['班基']='班基拉斯:BAABLgAECn8jAAMbAAgJUR1qAgATAgAbAAgJUR1qAgATAgAcAAEJYAjn7QAkAAAAAA==.',
['琪琪']='琪琪吃不堡:BAAALgAECgUJBQAAAA==.',
['瑞祥']='瑞祥知心:BAAALgAECgIJAgAAAA==.',
['生前']='生前打过虎:BAAALgAECgEJBAAAAA==.',
['生生']='生生流转:BAAALgAECgEJAgAAAA==.',
['甩甩']='甩甩蛇:BAAALgADCgYJBgAAAA==.',
['电工']='电工小王:BAAALgADCgMJAwAAAA==.',
['畂偶']='畂偶:BAAALgAECgUJBQAAAA==.',
['疏桐']='疏桐鸿影:BAAALgAECgQJBAAAAA==.',
['疾攻']='疾攻:BAAALgADCgYJBgAAAA==.',
['痛苦']='痛苦丶女王:BAAALgADCgQJBAAAAA==.',
['瘦钚']='瘦钚辣姬:BAAALgAECgUJCQAAAA==.',
['白夜']='白夜星空:BAAALgAECgQJBAAAAA==.',
['白日']='白日飞升:BAAALgAECgEJAQAAAA==.',
['百分']='百分百纯新手:BAAALgADCgUJBQABLgAECgYJCAABAAAAAA==.',
['百花']='百花虫子:BAAALgAECgMJAwAAAA==.',
['百里']='百里花香:BAAALgAECgEJAQAAAA==.',
['皇家']='皇家魔宫玫瑰:BAAALgAECgQJBgAAAA==.',
['盖桠']='盖桠:BAAALgAECgEJAQAAAA==.',
['盗梦']='盗梦空间:BAAALgAFFAIJAgAAAA==.',
['盛世']='盛世丶:BAAALgAFFAEJAQAAAA==.',
['盲嘿']='盲嘿:BAAALgAECgUJBwAAAA==.',
['相濡']='相濡以茉:BAAALgAECgIJAgAAAA==.',
['看咩']='看咩看:BAAALgAECgMJBAAAAA==.',
['真言']='真言术丶盾:BAABLgAFFH8FAAIgAAQJiwssCADxAAAgAAQJiwssCADxAAAAAA==.真言术丶耀:BAABLgAFFH8GAAIgAAQJHwqoBgAhAQAgAAQJHwqoBgAhAQAAAA==.',
['眯眯']='眯眯米米:BAAALgAECgYJEgAAAA==.',
['知名']='知名种猪佩骑:BAAALgAFFAEJAQAAAA==.',
['矮陀']='矮陀螺:BAAALgAECgYJBgAAAA==.',
['硬梆']='硬梆梆蜀黍:BAAALgAFFAMJAwAAAA==.',
['神奇']='神奇的我呦:BAAALgAFFAMJBAAAAA==.',
['神武']='神武骑士:BAAALgAECgYJBgAAAA==.',
['神玛']='神玛东曦:BAABLgAECn8aAAIDAAcJZA7geQCGAQADAAcJZA7geQCGAQAAAA==.',
['神蛇']='神蛇大侠:BAAALgADCgIJAgAAAA==.',
['神赐']='神赐之吻:BAACLgAFFH8HAAILAAMJpQnXJADvAAALAAMJpQnXJADvAAAuAAQKfykAAwsACAkEH9AFAD0CAAsABwkXINAFAD0CAAoABgkdG6IOAN8BAAAA.',
['神风']='神风丶淡定:BAAALgAECgQJBAAAAA==.',
['离二']='离二三:BAABLgAFFH8FAAILAAMJIhbBJgDjAAALAAMJIhbBJgDjAAAAAA==.离二十:BAABLgAFFH8GAAILAAUJyRlIEAANAQALAAUJyRlIEAANAQAAAA==.',
['离克']='离克狐:BAABLgAFFH8IAAILAAQJ5hfTBgBcAQALAAQJ5hfTBgBcAQAAAA==.',
['离多']='离多夏:BAABLgAFFH8IAAILAAQJcRyHBwBXAQALAAQJcRyHBwBXAQAAAA==.',
['离格']='离格玛:BAABLgAFFH8IAAILAAQJaRf8BgBbAQALAAQJaRf8BgBbAQAAAA==.',
['秀源']='秀源:BAAALgADCgQJBAAAAA==.',
['秋山']='秋山澪丨:BAABLgAFFH8MAAIcAAQJgxHPGgD6AAAcAAQJgxHPGgD6AAAAAA==.',
['秋意']='秋意浓:BAAALgAECgEJAQAAAA==.',
['科斯']='科斯维奇:BAACLgAFFH8MAAIcAAQJKRuEDABvAQAcAAQJKRuEDABvAQAuAAQKfxoAAhwABgmEJAkkAHoCABwABgmEJAkkAHoCAAEuAAUUBgkRAAkAnxIA.',
['稳健']='稳健棍:BAAALgAFFAEJAgAAAA==.',
['稳重']='稳重的男士:BAACLgAFFH8LAAICAAMJuyTpDQAbAQACAAMJuyTpDQAbAQAuAAQKfx4AAgIACAnFJHYLAD8DAAIACAnFJHYLAD8DAAEuAAUUBgkEAAEAAAAA.',
['空呀']='空呀么气:BAABLgAFFH8IAAIWAAMJbB9CDgASAQAWAAMJbB9CDgASAQAAAA==.',
['空气']='空气儿:BAAALgAECgMJAwAAAA==.',
['空飘']='空飘落的记忆:BAAALgADCgEJAQAAAA==.',
['竜头']='竜头蛇尾:BAAALgAECgYJBgAAAA==.',
['笃丨']='笃丨果:BAACLgAFFH8LAAMgAAQJnBkyBwBqAQAgAAQJnBkyBwBqAQAIAAEJxAYtFwA5AAAuAAQKfxkABAgABwnYGRkiANMBAAgABwmEGBkiANMBACAABglGF7wfAJYBABAABAmdDC9CAOgAAAAA.',
['笑兰']='笑兰香:BAAALgAECgEJAgAAAA==.',
['符坚']='符坚:BAAALgAECgIJAgAAAA==.',
['笨熊']='笨熊不爬树:BAAALgAECgYJBgAAAA==.',
['第一']='第一赘婿:BAAALgAECgEJAQAAAA==.',
['筱僧']='筱僧:BAAALgAFFAIJBAAAAA==.',
['筱小']='筱小:BAAALgAECgEJAQAAAA==.',
['筱德']='筱德:BAAALgAECgkJCQAAAA==.',
['筱手']='筱手红红:BAAALgAFFAEJAwAAAA==.',
['筱爻']='筱爻:BAAALgAECgcJDAABLgAFFAIJBAABAAAAAA==.',
['米奇']='米奇卤味:BAABLgAECn8WAAIDAAkJDRqHEwD3AgADAAkJDRqHEwD3AgAAAA==.',
['米斯']='米斯特達艾斯:BAAALgAECgUJBQAAAA==.',
['米莉']='米莉姆:BAAALgAECgYJCwAAAA==.',
['精灵']='精灵闲云:BAAALgAECgEJAQAAAA==.精灵黄旭东:BAABLgAECn8WAAMWAAgJww0+SwAWAQAWAAYJPQw+SwAWAQASAAYJGQIRUgCMAAAAAA==.',
['精精']='精精乐道:BAAALgAECgcJBgAAAA==.',
['索萨']='索萨菲:BAAALgAECgIJAwAAAA==.',
['紫色']='紫色惩戒骑:BAAALgADCgcJBwAAAA==.',
['細細']='細細的馬甲:BAAALgAECgUJBgAAAA==.',
['红烧']='红烧咕翅:BAAALgAECgYJBgAAAA==.',
['红色']='红色猛兽:BAAALgAFFAIJBAABLgAFFAMJBwAhALgXAA==.',
['红酥']='红酥手黄藤酒:BAAALgAECgIJAgAAAA==.',
['红魔']='红魔丨赤月:BAABLgAECn8ZAAMiAAcJux5vAQDeAQAhAAcJWBujGgAsAgAiAAYJCh9vAQDeAQAAAA==.',
['终一']='终一世渡一人:BAAALgADCgMJAwAAAA==.',
['维恩']='维恩丶夜影:BAAALgAECgkJAQAAAA==.',
['绿光']='绿光少年丶:BAAALgAECgUJBQAAAA==.',
['绿毛']='绿毛水怪:BAAALgADCgYJCwAAAA==.',
['绿色']='绿色扭扭蛇:BAAALgAECgkJCQAAAA==.',
['罗洛']='罗洛牧:BAAALgAECgEJAQAAAA==.',
['美川']='美川苦茶:BAAALgAECgQJAwAAAA==.',
['羞涩']='羞涩的小矮子:BAACLgAFFH8GAAITAAIJqBkgBACZAAATAAIJqBkgBACZAAAuAAQKfx4AAhMABwk+IlYFAKMCABMABwk+IlYFAKMCAAEuAAUUBwkZABYA/hYA.',
['翎丶']='翎丶風:BAAALgAECgQJBAAAAA==.',
['翠花']='翠花小同学:BAAALgADCgUJBQAAAA==.翠花绵云冷萃:BAABLgAECn8fAAIEAAgJ1hiFEADhAQAEAAgJ1hiFEADhAQAAAA==.',
['老子']='老子不吔:BAAALgADCgEJAQAAAA==.',
['老枪']='老枪丶砰:BAABLgAECn8YAAINAAcJuh2ZHgBOAgANAAcJuh2ZHgBOAgAAAA==.',
['老铁']='老铁的黑铁:BAAALgAECgUJBQAAAA==.',
['老麋']='老麋鹿:BAABLgAECn8XAAIEAAYJmhWpLgA2AQAEAAYJmhWpLgA2AQAAAA==.',
['而我']='而我会拒绝你:BAAALgAECgYJEgAAAA==.',
['聯盟']='聯盟第壹死騎:BAAALgAECgcJBwAAAA==.',
['聼説']='聼説龍人好玩:BAAALgAECgcJBwAAAA==.',
['胖嘟']='胖嘟嘟的三食:BAAALgAECgQJBAAAAA==.',
['胖小']='胖小雨:BAAALgAECgIJAgAAAA==.',
['胖胖']='胖胖帕吉:BAABLgAFFH8IAAIYAAQJSQd5CAD2AAAYAAQJSQd5CAD2AAAAAA==.',
['腰马']='腰马合一:BAAALgAECgYJEgAAAA==.',
['自然']='自然静月曲:BAAALgAECgIJAgAAAA==.',
['致盲']='致盲圣光:BAAALgADCgMJAwAAAA==.',
['舜华']='舜华浅歌:BAACLgAFFH8IAAMQAAMJEBztCQAXAQAQAAMJEBztCQAXAQAgAAEJ8Q3VGABNAAAuAAQKfyQAAxAACAnDIRgJAPMCABAACAnDIRgJAPMCACAAAwkyCZ5FAI0AAAAA.',
['舟诗']='舟诗叶:BAAALgADCgUJBQAAAA==.',
['色格']='色格伯出击:BAAALgADCgcJDAAAAA==.',
['艾瑞']='艾瑞达恶魔:BAAALgAECgMJBQAAAA==.',
['芍斛']='芍斛:BAAALgADCgYJBgAAAA==.',
['苍蓝']='苍蓝秘法者:BAAALgAECgUJBgAAAA==.',
['苍野']='苍野水白:BAAALgAECgUJCAAAAA==.',
['苏格']='苏格拉底:BAACLgAFFH8FAAIMAAUJPQhuDgAaAQAMAAUJPQhuDgAaAQAuAAQKfysAAgwACAkzHZ4EAOsBAAwACAkzHZ4EAOsBAAAA.',
['苏梦']='苏梦:BAAALgAECgQJCAAAAA==.',
['范様']='范様貳點零:BAABLgAECn8dAAIDAAgJuhdxPQAvAgADAAgJuhdxPQAvAgAAAA==.',
['茉莉']='茉莉星空:BAAALgAFFAEJAQAAAA==.',
['荠菜']='荠菜团子:BAAALgAFFAEJAwAAAA==.',
['荡糕']='荡糕君:BAABLgAFFH8FAAIYAAQJFAewCwAdAQAYAAQJFAewCwAdAQAAAA==.',
['荪悦']='荪悦:BAAALgAFFAIJAgAAAA==.',
['荭邪']='荭邪:BAAALgAECgIJAgAAAA==.',
['莀晓']='莀晓晓:BAAALgAECgYJCQAAAA==.',
['莉拉']='莉拉晴雪:BAAALgADCgkJCQAAAA==.',
['莎弗']='莎弗莱:BAABLgAECn8oAAIjAAgJGxrgAgCwAQAjAAgJGxrgAgCwAQAAAA==.',
['莫离']='莫离:BAABLgAFFH8PAAIOAAQJdxCZAgA7AQAOAAQJdxCZAgA7AQAAAA==.',
['莱因']='莱因哈特丶:BAAALgAECgIJAwAAAA==.',
['莱柆']='莱柆:BAAALgAFFAEJAQAAAA==.',
['莱椰']='莱椰丝丶:BAAALgAECgIJAgAAAA==.',
['莱耶']='莱耶丶暗炉:BAAALgAECgcJCgAAAA==.',
['莲瞳']='莲瞳茉染丶:BAAALgAECgEJAQABLgAFFAcJBQAEANIGAA==.',
['莺飞']='莺飞蝶舞:BAAALgADCgMJAwAAAA==.',
['菁依']='菁依愺:BAAALgAECgYJCgAAAA==.',
['菇菇']='菇菇嘎嘎:BAAALgADCgYJBgAAAA==.',
['菠萝']='菠萝包是只猫:BAAALgADCgQJBAAAAA==.',
['菲尔']='菲尔奥娜:BAAALgADCgQJBAAAAA==.',
['萌歌']='萌歌玛丽:BAAALgAECgYJDAAAAA==.',
['萌萌']='萌萌的犄角丶:BAAALgAFFAIJBAAAAA==.',
['萝莉']='萝莉的失主:BAABLgAECn8jAAMLAAgJeCBJBQBLAgALAAgJeCBJBQBLAgAKAAIJTAeEWwBcAAAAAA==.',
['萧太']='萧太后:BAAALgAECgEJAQAAAA==.',
['萨娇']='萨娇蒂晓满:BAAALgAECgQJBAAAAA==.',
['萨尔']='萨尔酱:BAAALgADCgYJCwAAAA==.',
['萨灬']='萨灬:BAAALgAECgcJBwAAAA==.',
['落落']='落落小魔王:BAAALgAECggJEAAAAA==.',
['蒙紫']='蒙紫夏:BAAALgAECgYJBQAAAA==.',
['蓝色']='蓝色的天:BAAALgAECgcJBwAAAA==.',
['薇莉']='薇莉娅:BAAALgADCgEJAQAAAA==.',
['薇薇']='薇薇丶雨晨:BAAALgAECgYJCgAAAA==.',
['虫子']='虫子:BAACLgAFFH8IAAIEAAMJbyAGEQAqAQAEAAMJbyAGEQAqAQAuAAQKfxYAAgQACAlXGhYJADkCAAQACAlXGhYJADkCAAAA.',
['蜗伦']='蜗伦蒸鸭:BAAALgADCgEJAQAAAA==.',
['蝶依']='蝶依醉梦:BAAALgAFFAMJAwAAAA==.',
['衣架']='衣架子:BAAALgAECgcJBwAAAA==.',
['袜子']='袜子热潮:BAAALgAECgcJDwAAAA==.',
['西丨']='西丨瓜:BAAALgAECgIJAgAAAA==.',
['西么']='西么西:BAAALgAECgQJBAAAAA==.',
['西关']='西关畏野:BAAALgAECgYJBgAAAA==.',
['西域']='西域老狼:BAAALgADCgUJBQAAAA==.',
['西瓜']='西瓜啵啵:BAAALgADCgYJCwAAAA==.',
['西红']='西红柿炒番茄:BAAALgADCgcJBwAAAA==.',
['言途']='言途:BAABLgAECn8ZAAIWAAcJKwzwOwBYAQAWAAcJKwzwOwBYAQAAAA==.',
['謦謦']='謦謦馨馨:BAAALgAECgcJDQAAAA==.',
['诗歌']='诗歌:BAAALgAFFAEJAwAAAA==.',
['诡六']='诡六:BAAALgAECgcJBwAAAA==.',
['说些']='说些藏话:BAAALgAECgYJBgAAAA==.',
['谁会']='谁会怀念:BAAALgAECggJCAAAAA==.',
['谢思']='谢思珖:BAAALgADCgIJAgAAAA==.谢思雪:BAAALgAECgYJCAAAAA==.',
['豆芽']='豆芽:BAABLgAECn8aAAMGAAgJIxwABQCTAgAGAAgJIxwABQCTAgAHAAEJmgZeSQArAAAAAA==.',
['豊川']='豊川祥子:BAAALgAFFAUJBAAAAA==.',
['貅琳']='貅琳丶:BAAALgAECgYJCAAAAA==.',
['贫僧']='贫僧略懂拳脚:BAAALgAECgYJCwAAAA==.',
['赫瑞']='赫瑞德玛:BAAALgADCgcJBwAAAA==.',
['赵子']='赵子龙一号:BAAALgAECgcJDAAAAA==.',
['赵莉']='赵莉颖:BAAALgAECgQJBQAAAA==.',
['起司']='起司超人:BAACLgAFFH8KAAICAAQJ1B5LCQCGAQACAAQJ1B5LCQCGAQAuAAQKfxsAAgIABwmrJZ0XAO4CAAIABwmrJZ0XAO4CAAAA.',
['跟着']='跟着太阳走:BAAALgAECgYJCgAAAA==.',
['路徳']='路徳维希:BAAALgAECgQJBwAAAA==.',
['踩踩']='踩踩猫:BAABLgAFFH8IAAIYAAMJ1xrrBwACAQAYAAMJ1xrrBwACAQAAAA==.',
['轌見']='轌見:BAAALgAECgYJBgAAAA==.',
['轩然']='轩然恶灭:BAAALgAECgMJAwABLgAECgYJCAABAAAAAA==.轩然灭世:BAAALgAECgQJEQABLgAECgYJCAABAAAAAA==.',
['辉煌']='辉煌如我:BAACLgAFFH8LAAIcAAQJkhuOBABtAQAcAAQJkhuOBABtAQAuAAQKfyIABBwACQl+HYIUANwCABwACAmAH4IUANwCABsABQngEuM2ACsBAB0AAQnjES0rADQAAAAA.',
['辛达']='辛达苟萨:BAAALgAECgQJBQAAAA==.',
['辞九']='辞九门回忆:BAAALgAECgUJBQAAAA==.',
['达莉']='达莉娅:BAAALgAECgQJBAAAAA==.',
['近战']='近战杨永信:BAAALgAECgYJDAAAAA==.',
['这把']='这把稳限:BAACLgAFFH8GAAMLAAMJ5xI3NgCnAAALAAMJ5xI3NgCnAAAaAAEJ4hM5BQBYAAAuAAQKfxoABAsACQl4GXYaALYCAAsACQl4GXYaALYCAAoABwmgCXodAGMBABoABgkBB6cQACMBAAAA.',
['迪匹']='迪匹埃斯:BAACLgAFFH8JAAINAAQJSRQSBQBSAQANAAQJSRQSBQBSAQAuAAQKfygAAw0ACAnUJE8GACkDAA0ACAnUJE8GACkDAA4AAgk+FUhuAIYAAAAA.',
['迪铠']='迪铠:BAAALgAECgIJAgAAAA==.',
['迪非']='迪非亚黑骑士:BAAALgAECgYJCgAAAA==.',
['迷你']='迷你猫娘头子:BAAALgADCgEJAQAAAA==.',
['迷失']='迷失的诺言:BAAALgADCgYJDAAAAA==.',
['追忆']='追忆丶焱寳:BAAALgAECgYJDQAAAA==.',
['逃起']='逃起来飞快:BAAALgAECgYJBgAAAA==.',
['逆水']='逆水流刹:BAAALgADCgYJDAAAAA==.',
['道剑']='道剑剑非刀:BAAALgADCgUJBQAAAA==.',
['遛遛']='遛遛依依:BAAALgAECgcJDAAAAA==.',
['那你']='那你去找物管:BAAALgAECgMJAwAAAA==.',
['邦邦']='邦邦蜀黍:BAABLgAFFH8GAAINAAMJaSC6BgA2AQANAAMJaSC6BgA2AQAAAA==.',
['邪能']='邪能榴芒:BAAALgAECgQJBAAAAA==.',
['邻家']='邻家王叔叔:BAAALgAECgYJCAAAAA==.',
['酸茄']='酸茄子酱:BAAALgAECggJEQAAAA==.',
['酸辣']='酸辣鸡蛋面:BAAALgADCgcJBwAAAA==.',
['酸黄']='酸黄瓜酱:BAAALgAECgcJDwAAAA==.',
['醉月']='醉月流星:BAAALgAECgYJCwAAAA==.',
['醉風']='醉風塵:BAAALgAECgYJBgAAAA==.',
['里子']='里子抄:BAAALgADCgUJBQAAAA==.',
['里索']='里索额图斯:BAAALgAECgEJAQAAAA==.',
['重黎']='重黎:BAAALgAECgYJCwAAAA==.',
['野兽']='野兽包丶子:BAAALgAFFAIJAgAAAA==.',
['钢铁']='钢铁般的意痔:BAACLgAFFH8JAAIJAAQJ0yZOAwDVAQAJAAQJ0yZOAwDVAQAuAAQKfxwAAwkACAmzJjIBAH8DAAkACAmzJjIBAH8DAAwAAQkAACBYAF8AAAAA.',
['铁铠']='铁铠冥魂:BAAALgAECgYJCgAAAA==.',
['铁锤']='铁锤村大领主:BAABLgAFFH8JAAICAAQJ9RLKGABCAQACAAQJ9RLKGABCAQAAAA==.',
['银闪']='银闪之风:BAAALgAECgYJBgAAAA==.',
['锅包']='锅包肉:BAAALgAECgMJBAAAAA==.',
['锡音']='锡音:BAAALgAFFAEJAgAAAA==.',
['锦儿']='锦儿不乖:BAAALgAECgYJCwAAAA==.',
['长尾']='长尾景虎:BAAALgAFFAMJBAAAAA==.',
['长手']='长手爬爬怪:BAAALgAECgIJAgABLgAFFAIJBAABAAAAAA==.',
['长胡']='长胡子老头:BAAALgAECgIJAQAAAA==.',
['闪光']='闪光喷火龙:BAAALgAECgcJBwAAAA==.',
['闷德']='闷德德:BAAALgAECgIJAgAAAA==.',
['闹闹']='闹闹:BAAALgAECgMJAwAAAA==.',
['阳光']='阳光小智:BAABLgAFFH8HAAMhAAMJuBd6EQC9AAAhAAIJjB16EQC9AAAiAAEJEQxUBgBbAAAAAA==.',
['阿丽']='阿丽塔:BAAALgAECgEJAQAAAA==.',
['阿二']='阿二萨斯:BAAALgAECgMJAwAAAA==.',
['阿尔']='阿尔艾斯:BAAALgADCgYJBgAAAA==.',
['阿康']='阿康婚礼:BAAALgAECgEJAQAAAA==.',
['阿弥']='阿弥忒尔斯:BAAALgAECgQJBAAAAA==.',
['阿肱']='阿肱:BAAALgAECgMJAwAAAA==.',
['阿达']='阿达丶:BAAALgAECgcJCwAAAA==.',
['阿雷']='阿雷娅丶月纹:BAAALgAECgEJAQAAAA==.',
['陈老']='陈老姑:BAABLgAECn8WAAICAAkJXR9nDQAvAwACAAkJXR9nDQAvAwAAAA==.',
['隔壁']='隔壁王蜀黍:BAAALgAECgYJDwAAAA==.',
['雅璃']='雅璃耶妲:BAAALgAECgYJBgAAAA==.',
['雪映']='雪映辰:BAAALgAECgIJAwAAAA==.',
['雪风']='雪风之匙:BAAALgAECgMJAwAAAA==.',
['雷文']='雷文笈:BAAALgAECgcJCQAAAA==.',
['雷莉']='雷莉莉:BAABLgAFFH8JAAIYAAQJqR7LBACDAQAYAAQJqR7LBACDAQAAAA==.',
['雷诺']='雷诺的游骑兵:BAAALgAECgMJBAAAAA==.',
['雷霆']='雷霆元素:BAAALgAECgYJBwAAAA==.雷霆狂龙:BAAALgAECgYJCgAAAA==.雷霆狂龙千亿:BAAALgAECgcJBAAAAA==.',
['雾屿']='雾屿虹霖:BAAALgADCgIJAgAAAA==.',
['霜兰']='霜兰:BAAALgADCgEJAQAAAA==.',
['露娜']='露娜小公主:BAAALgAECgMJAwAAAA==.',
['霸道']='霸道真气:BAAALgAFFAEJAQAAAA==.',
['青梅']='青梅煮酒:BAAALgAECgYJBgAAAA==.',
['青焰']='青焰:BAAALgAECgIJAgAAAA==.',
['青花']='青花德:BAAALgAECgUJCAAAAA==.',
['青衫']='青衫如歌:BAAALgADCgEJAQAAAA==.',
['面包']='面包:BAAALgAECgYJDAAAAA==.面包狗:BAAALgAECgQJBQAAAA==.',
['韩大']='韩大仁:BAAALgAECgEJAQAAAA==.',
['韬美']='韬美丽:BAAALgAFFAIJBAAAAA==.',
['顶级']='顶级倒霉熊:BAAALgADCgcJBwAAAA==.',
['風丶']='風丶火:BAAALgAECgUJDgAAAA==.',
['风上']='风上云尖:BAAALgADCggJCAAAAA==.',
['风之']='风之时光:BAAALgADCgUJBQAAAA==.风之酒:BAAALgAECgQJBQAAAA==.',
['风刃']='风刃乱舞:BAAALgAECgQJBwAAAA==.',
['风吹']='风吹梨子坡:BAAALgADCgEJAQAAAA==.',
['风斩']='风斩冰华灬:BAABLgAFFH8UAAIEAAYJXSMHAgB3AgAEAAYJXSMHAgB3AgAAAA==.',
['风痕']='风痕使者:BAAALgAECgEJAQAAAA==.',
['飞翔']='飞翔的风筝:BAAALgAECgQJBQAAAA==.',
['飞花']='飞花与芽:BAAALgAECgYJCAAAAA==.',
['飞行']='飞行雪绒:BAABLgAFFH8IAAIcAAUJZyEJBAD0AQAcAAUJZyEJBAD0AQAAAA==.',
['香芋']='香芋:BAABLgAECn8dAAIeAAgJJg/JGQCFAQAeAAgJJg/JGQCFAQAAAA==.',
['馨妮']='馨妮瑟拉:BAABLgAECn8VAAIJAAcJvhLuGwCoAQAJAAcJvhLuGwCoAQABLgAFFAYJDgAMANgWAA==.',
['马加']='马加骑:BAABLgAFFH8MAAIDAAQJkiLvAgB3AQADAAQJkiLvAgB3AQAAAA==.',
['骨殇']='骨殇:BAAALgAECgYJCgAAAA==.',
['高伤']='高伤害:BAAALgAFFAEJAQAAAA==.',
['鬼切']='鬼切呱:BAAALgAECgYJBgAAAA==.',
['魑魅']='魑魅魍魉魃魈:BAAALgAECgIJAgAAAA==.',
['魔女']='魔女辛德拉:BAAALgADCgYJBgAAAA==.',
['魔心']='魔心:BAAALgAECgUJCwAAAA==.',
['魔法']='魔法少女小橘:BAAALgAECgYJCAAAAA==.魔法淡水:BAABLgAECn8UAAIEAAcJnBeFfQDWAQAEAAcJnBeFfQDWAQABLgAFFAUJAQABAAAAAA==.',
['鲁北']='鲁北北丶:BAAALgAECgYJCAAAAA==.',
['鲁卡']='鲁卡提耶:BAAALgAECgYJBgAAAA==.',
['鲁西']='鲁西西丶:BAACLgAFFH8JAAIEAAMJFiJjFAAQAQAEAAMJFiJjFAAQAQAuAAQKfyIAAgQACAk9H20nANUCAAQACAk9H20nANUCAAAA.',
['鸩主']='鸩主:BAAALgAECgEJAQABLgAFFAQJDgATAGUTAA==.',
['鸩佑']='鸩佑:BAACLgAFFH8OAAITAAQJZRO8AAA0AQATAAQJZRO8AAA0AQAuAAQKfxsAAhMACQlVHQMCACQDABMACQlVHQMCACQDAAAA.',
['鸩翅']='鸩翅:BAAALgADCgcJBwABLgAFFAQJDgATAGUTAA==.',
['鸭绒']='鸭绒被芯:BAAALgAECgUJBQAAAA==.',
['鹤冲']='鹤冲天:BAAALgAECgMJBgAAAA==.',
['麻友']='麻友友:BAAALgAECgQJBQAAAA==.',
['麻花']='麻花辫:BAAALgAECgMJAwAAAA==.',
['麻薯']='麻薯宝宝:BAAALgAECgYJBgAAAA==.',
['黄油']='黄油饼干:BAABLgAECn8fAAICAAgJwxt7MAB2AgACAAgJwxt7MAB2AgAAAA==.',
['黎羽']='黎羽幻笙:BAAALgAFFAIJAgABLgAFFAQJDgATAGUTAA==.',
['黑心']='黑心包:BAAALgAECgcJEgAAAA==.',
['黑锋']='黑锋女神:BAABLgAECn8WAAICAAkJwR44DwAjAwACAAkJwR44DwAjAwAAAA==.',
['默亦']='默亦蓝:BAAALgAECgkJAQABLgAFFAQJDAADAJIiAA==.',
['黯灬']='黯灬雨晴:BAAALgAFFAEJAQAAAA==.',
['齊天']='齊天大聖:BAAALgAECgIJAgAAAA==.',
['龍鳯']='龍鳯呈祥灬:BAAALgAFFAQJBAAAAA==.',
['龙焱']='龙焱丶:BAAALgADCgIJAgAAAA==.',
['龙鳯']='龙鳯呈祥:BAAALgAECgQJBAABLgAFFAQJBAABAAAAAA==.',
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
