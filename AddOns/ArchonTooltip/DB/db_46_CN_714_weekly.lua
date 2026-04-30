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

local lookup = {'Evoker-Preservation','Evoker-Augmentation','Warlock-Demonology','Warrior-Protection','Unknown-Unknown','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Druid-Feral','Mage-Frost','DeathKnight-Unholy','Warlock-Destruction','Rogue-Subtlety','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Shaman-Restoration','Warrior-Fury','Warrior-Arms','Priest-Holy','Druid-Balance','Rogue-Assassination','Druid-Restoration','DemonHunter-Devourer','Druid-Guardian','Rogue-Outlaw','Monk-Brewmaster','Evoker-Devastation','DemonHunter-Havoc','DeathKnight-Blood',}
local provider = {region='CN',realm='格雷迈恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Angrylemon:BAAALgAECgMJBQAAAA==.Ansur:BAACLgAFFH8HAAIBAAMJlyL3CgA7AQABAAMJlyL3CgA7AQAuAAQKfxwAAwEACAnBIQsHAM8CAAEABwkuJQsHAM8CAAIABwksGGkaAPcBAAAA.',
Ap='Apology:BAAALgAECgMJAwAAAA==.',
Ar='Arhat:BAAALgAECgYJBgAAAA==.Arsh:BAAALgAFFAIJAgAAAA==.',
Bi='Biabiabia:BAAALgAECgYJBgAAAA==.',
Cl='Cloudy:BAAALgAECgUJBgAAAA==.',
Da='Dalea:BAAALgAECgcJBwAAAA==.Darknts:BAAALgAECgYJBgAAAA==.',
De='Desperatedx:BAABLgAFFH8HAAIDAAMJVyKPEgDWAAADAAMJVyKPEgDWAAAAAA==.',
Di='Dishike:BAAALgAECgcJCAAAAA==.',
Do='Doro:BAAALgAECgcJEQABLgAFFAYJDwABAF4VAA==.Doroo:BAAALgAECgkJEAAAAA==.',
En='Enengy:BAAALgAECgEJAQAAAA==.',
Fa='Fade:BAAALgAECgYJDAAAAA==.',
Fq='Fq:BAAALgAECgYJBgAAAA==.',
Ga='Galaxy:BAAALgAECgYJBgAAAA==.Gao:BAAALgAECgYJDAABLgAFFAcJDQAEAM4ZAA==.',
Gl='Glitter:BAAALgAECgEJAgAAAA==.',
Hi='Hisashi:BAAALgAFFAQJBAAAAA==.',
Ho='Hotsauce:BAAALgAECgcJDQAAAA==.',
Ir='Irreen:BAAALgAECgcJCAAAAA==.',
Ja='Jasper:BAAALgAFFAIJBAABLgAFFAMJBAAFAAAAAA==.',
Je='Jeffqs:BAACLgAFFH8GAAIGAAMJgg4BCgD7AAAGAAMJgg4BCgD7AAAuAAQKfyAABAYACAntGP4+ACkCAAYABwmWG/4+ACkCAAcABwl9Fu8pAOIBAAgAAQn5CD1EAC4AAAAA.',
Jo='Joly:BAAALgADCgYJAQAAAA==.',
Ju='Justice:BAABLgAFFH8GAAIGAAIJWwpaJwCbAAAGAAIJWwpaJwCbAAAAAA==.',
La='Lappe:BAAALgAECgcJBwABLgAFFAQJEAAJAOsiAA==.',
Lu='Luluemo:BAABLgAFFH8FAAIKAAQJah+6EACQAQAKAAQJah+6EACQAQAAAA==.',
Me='Melbisty:BAAALgAFFAEJAQAAAA==.Melodydan:BAAALgAECgMJAwAAAA==.',
Mi='Minnt:BAAALgAFFAMJBAAAAA==.',
Mu='Mulogle:BAAALgADCgUJCQAAAA==.',
Ng='Ngusupw:BAAALgAECgIJAgAAAA==.',
Nz='Nz:BAAALgAECgEJAgAAAA==.',
Oc='Octavius:BAAALgAFFAEJAQAAAA==.',
Pi='Pinkman:BAAALgAFFAEJAQABLgAFFAMJBAAFAAAAAA==.',
Pl='Playerneiazi:BAAALgAFFAIJBAAAAA==.',
Po='Porridge:BAAALgAFFAIJAgAAAA==.',
Pr='Protoss:BAACLgAFFH8JAAIKAAMJHiGlDQAiAQAKAAMJHiGlDQAiAQAuAAQKfxoAAgoACAlMJWoOAFMDAAoACAlMJWoOAFMDAAAA.Protossh:BAAALgAFFAIJAwAAAA==.Protossr:BAAALgAECgUJBQABLgAFFAMJCQAKAB4hAA==.',
Ro='Roling:BAAALgAECgIJAwAAAA==.',
Sa='Sakuraa:BAAALgADCgEJAQAAAA==.Sanangelina:BAAALgAECgUJBQAAAA==.Sausagepp:BAABLgAFFH8JAAILAAQJMBg3OwCmAAALAAQJMBg3OwCmAAAAAA==.',
Sh='Shiyou:BAAALgADCgUJBQAAAA==.Shiyoux:BAAALgAECgEJAQAAAA==.',
Si='Silveraven:BAABLgAECn8VAAMMAAYJwxXRJQAvAQAMAAUJxxHRJQAvAQADAAUJ9xGeuwDhAAAAAA==.',
Sk='Skranie:BAAALgADCgYJBgABLgAFFAYJFgANAJYgAA==.',
Su='Sunburst:BAABLgAFFH8GAAIKAAIJhwwTHACmAAAKAAIJhwwTHACmAAAAAA==.',
Th='Thalorin:BAAALgAECgEJAQAAAA==.Tharllnos:BAACLgAFFH8JAAIKAAMJbSDyIgAvAQAKAAMJbSDyIgAvAQAuAAQKfyIAAgoACAkKJAIXACADAAoACAkKJAIXACADAAAA.Thunderwrath:BAAALgAECgYJDAAAAA==.',
Un='Undaunted:BAABLgAFFH8IAAMOAAMJ0wREGADPAAAOAAMJMgNEGADPAAAPAAEJ/Ad5FgBTAAAAAA==.Unicornbaby:BAAALgAECgcJEgAAAA==.',
Uo='Uok:BAAALgAECgQJBAAAAA==.',
Vi='Virgoz:BAAALgAECgIJAgAAAA==.',
Wa='Wangren:BAAALgAECgMJAwAAAA==.',
Wl='Wlbl:BAAALgADCgYJBgAAAA==.',
Xi='Xinkeaii:BAAALgAFFAQJBAAAAA==.',
Yu='Yuzidws:BAAALgAECgkJCQABLgAFFAUJAQAFAAAAAA==.',
Zz='Zz:BAAALgAFFAIJAwAAAA==.',
['Áî']='Áî:BAAALgAECgYJCQAAAA==.',
['一天']='一天丶一射:BAAALgAECgMJAwAAAA==.',
['一杯']='一杯冰美式:BAACLgAFFH8GAAIQAAMJIgxxDADeAAAQAAMJIgxxDADeAAAuAAQKfxwAAhAABwnIGWgYAPwBABAABwnIGWgYAPwBAAAA.',
['七年']='七年级小学生:BAAALgADCgEJAQAAAA==.',
['万里']='万里冰封:BAAALgAECgYJBwAAAA==.',
['三不']='三不沾:BAAALgAECgUJBgAAAA==.',
['上官']='上官煞:BAAALgAECgUJCAAAAA==.',
['下次']='下次一定呀:BAAALgAFFAIJAgAAAA==.',
['不丶']='不丶讲道理:BAAALgADCgUJBQAAAA==.',
['不知']='不知云过:BAAALgAFFAIJAwAAAA==.',
['不负']='不负榴莲:BAAALgAECgYJBgAAAA==.',
['不雨']='不雨亦潇潇:BAAALgAECgYJCwAAAA==.',
['不饮']='不饮醉花阴:BAAALgAFFAIJAgAAAA==.',
['丑到']='丑到拖网速:BAAALgAECgcJBwAAAA==.',
['专治']='专治不孕:BAAALgADCgEJAQAAAA==.',
['东北']='东北傻狍子:BAAALgADCgMJAwAAAA==.',
['东咕']='东咕:BAAALgAECgEJAQAAAA==.',
['丨凌']='丨凌霄丨:BAAALgAECgMJAwAAAA==.',
['丨十']='丨十丨:BAAALgAECgIJAwAAAA==.',
['丨颜']='丨颜抱丶:BAAALgADCgYJBgAAAA==.',
['丨饕']='丨饕灬餮丨:BAACLgAFFH8IAAIRAAMJbxsXBgD9AAARAAMJbxsXBgD9AAAuAAQKfyAAAhEACAl6GPgkAAECABEACAl6GPgkAAECAAAA.',
['中森']='中森明菜:BAAALgAECgEJAwAAAA==.',
['丶云']='丶云端咆哮:BAAALgAFFAIJAwABLgAFFAMJBAAFAAAAAA==.',
['丶光']='丶光年之外:BAAALgAFFAIJAwAAAA==.',
['丶南']='丶南河:BAAALgAECgYJDQAAAA==.',
['丶堕']='丶堕落:BAABLgAFFH8JAAIKAAMJ5w47LQACAQAKAAMJ5w47LQACAQAAAA==.',
['丶夏']='丶夏天:BAAALgAFFAMJBAAAAA==.',
['丶夜']='丶夜雨清眸:BAAALgAFFAIJAgAAAA==.',
['丶小']='丶小秋月丶:BAAALgAECgUJCQAAAA==.',
['丶托']='丶托儿索丶:BAAALgADCgEJAgAAAA==.',
['丶施']='丶施瓦辛格:BAACLgAFFH8OAAMSAAQJJR7pDQAoAQASAAMJEh7pDQAoAQATAAIJnxhOAwC1AAAuAAQKfxgAAxIABwlEH2ohAEgCABIABgkuJGohAEgCABMAAgkRCM8vAHcAAAAA.',
['丶洛']='丶洛神:BAAALgAECgYJCQAAAA==.',
['丶灰']='丶灰色丶:BAAALgAECgYJBgAAAA==.',
['丶非']='丶非洲大酋长:BAAALgAECgEJAQAAAA==.',
['为了']='为了部落:BAABLgAFFH8FAAILAAMJ5h/CHwAcAQALAAMJ5h/CHwAcAQAAAA==.',
['丿假']='丿假面:BAAALgADCgcJCgAAAA==.',
['乄无']='乄无人生还:BAAALgAFFAEJAQAAAA==.',
['九蓮']='九蓮宝灯:BAABLgAECn8VAAIKAAYJniJ+owCRAQAKAAYJniJ+owCRAQAAAA==.',
['二筒']='二筒:BAAALgAECgcJCgAAAA==.',
['云海']='云海惜瑶:BAAALgAECgMJBgAAAA==.',
['五十']='五十亦到:BAAALgAFFAEJAQABLgAFFAQJBAAFAAAAAA==.',
['亲包']='亲包邮哦:BAAALgAECgEJAQAAAA==.',
['今天']='今天有点热:BAAALgAECgQJBAAAAA==.',
['从小']='从小砍传奇:BAAALgAECgEJAQAAAA==.',
['伊格']='伊格利特:BAAALgAECgEJAQAAAA==.',
['伊泽']='伊泽瑞尔丶:BAAALgAECgYJBwAAAA==.',
['会飞']='会飞的牛牛:BAAALgAECgEJAgAAAA==.',
['伤害']='伤害及格线:BAAALgAFFAEJAQAAAA==.',
['你的']='你的术爷:BAAALgAECgYJBwAAAA==.',
['信仰']='信仰那挚爱:BAAALgADCgEJAQAAAA==.',
['儍僈']='儍僈:BAACLgAFFH8IAAIRAAMJSxeqDgDzAAARAAMJSxeqDgDzAAAuAAQKfyAAAhEACAk9GsAYAFACABEACAk9GsAYAFACAAAA.',
['元素']='元素微粒:BAAALgAECgYJDAAAAA==.',
['再狂']='再狂一次:BAAALgAECgEJAQAAAA==.',
['冫澡']='冫澡堂歌神丶:BAAALgAECgEJAQAAAA==.',
['冯宝']='冯宝宝:BAAALgAFFAEJAQAAAA==.',
['冰柠']='冰柠悠悠:BAABLgAECn8UAAIUAAgJVxkWEABlAgAUAAgJVxkWEABlAgAAAA==.',
['冰淇']='冰淇淋柠檬茶:BAAALgAFFAIJBAAAAA==.',
['冰镇']='冰镇小青提:BAAALgAECgMJAwAAAA==.',
['冰龟']='冰龟罗克:BAACLgAFFH8JAAMOAAMJ4iQWDQBNAQAOAAMJ4iQWDQBNAQAPAAIJGR83CgDTAAAuAAQKfyAAAw4ACAmMJPYNANECAA4ABwmMJPYNANECAA8AAQkAAGKrAG4AAAAA.',
['凯莉']='凯莉佩利:BAAALgADCgEJAQAAAA==.',
['力口']='力口尔鲁什:BAAALgAFFAEJAQAAAA==.',
['加尔']='加尔鲁丶:BAAALgAECgYJCwAAAA==.',
['加摩']='加摩尔:BAAALgAECgEJAgAAAA==.',
['劣人']='劣人丶:BAAALgAECgMJAwAAAA==.',
['十一']='十一打酱:BAAALgAFFAEJAQAAAA==.',
['十六']='十六年:BAAALgAECgYJCQAAAA==.',
['千愁']='千愁:BAAALgADCgEJAQAAAA==.',
['千杀']='千杀:BAAALgAECgUJCQAAAA==.',
['单唐']='单唐丶:BAAALgAECgcJEgAAAA==.',
['卡嘉']='卡嘉莉丶:BAABLgAECn8UAAIKAAYJVBZrrgB/AQAKAAYJVBZrrgB/AQAAAA==.',
['卡尔']='卡尔萨斯:BAAALgADCgUJBQABLgAECgcJBwAFAAAAAA==.',
['卡泽']='卡泽玛西亚成:BAAALgAFFAIJBAAAAA==.',
['叛逃']='叛逃:BAAALgAECgEJAQAAAA==.',
['古丽']='古丽娜:BAAALgAECgEJAgAAAA==.',
['古月']='古月丶寂落:BAAALgAECgYJCwAAAA==.',
['叫我']='叫我小刘就好:BAABLgAFFH8FAAIEAAMJGAI1CwCUAAAEAAMJGAI1CwCUAAAAAA==.',
['可以']='可以喝茶:BAAALgAECgYJAQAAAA==.',
['可拉']='可拉思刻:BAABLgAECn8bAAIBAAcJxxqMEQAkAgABAAcJxxqMEQAkAgAAAA==.',
['可罗']='可罗:BAABLgAECn8WAAIVAAYJNCGNHwACAgAVAAYJNCGNHwACAgAAAA==.',
['司马']='司马:BAAALgAECgUJBgAAAA==.',
['各种']='各种湿:BAAALgADCgUJCAABLgAECgcJBwAFAAAAAA==.',
['后起']='后起之秀丶:BAAALgAFFAMJBAAAAA==.',
['向阳']='向阳丶而生:BAAALgAFFAIJAwAAAA==.',
['君莫']='君莫笑:BAAALgAECgYJBgAAAA==.',
['吾辈']='吾辈何以为戰:BAAALgAFFAMJBAAAAA==.',
['周芷']='周芷婼:BAAALgAECgUJBQAAAA==.',
['咕咕']='咕咕噶噶:BAAALgADCgYJBgAAAA==.咕咕鸡丶:BAAALgADCgEJAQAAAA==.',
['哈籁']='哈籁尼尔萨满:BAAALgAECgcJBwAAAA==.',
['哈膜']='哈膜哒哒:BAAALgADCgQJBAAAAA==.',
['哦丶']='哦丶糟了:BAAALgAECggJEgAAAA==.',
['啾啾']='啾啾欣:BAAALgADCgcJEAAAAA==.',
['喜欢']='喜欢洗澡:BAAALgAECgEJAQAAAA==.喜欢玩蛇:BAAALgADCgMJAwAAAA==.喜欢罗马大帝:BAAALgAFFAIJAgAAAA==.',
['喵了']='喵了咪:BAAALgAFFAMJAwAAAA==.',
['嘚了']='嘚了个德:BAAALgAECgMJAwAAAA==.',
['四爷']='四爷:BAACLgAFFH8JAAIWAAMJehbyAAAWAQAWAAMJehbyAAAWAQAuAAQKfyAAAhYACAnqHvABAPICABYACAnqHvABAPICAAAA.',
['四顾']='四顾:BAAALgAECgEJAQAAAA==.',
['回憶']='回憶的碎片:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光救救我:BAAALgAECgEJAgAAAA==.',
['地球']='地球是我搓的:BAAALgAECgMJAwAAAA==.',
['埃隆']='埃隆马斯克:BAAALgAECgcJDgAAAA==.',
['壹骑']='壹骑無橙:BAAALgAECgUJBQAAAA==.',
['多弗']='多弗琅明妹:BAAALgAECgQJBAAAAA==.',
['多点']='多点耐心:BAABLgAFFH8FAAILAAIJ0SWOEQDjAAALAAIJ0SWOEQDjAAAAAA==.',
['夜厶']='夜厶色:BAAALgAECgcJEQAAAA==.',
['夜蓝']='夜蓝非天:BAAALgAECgMJAwAAAA==.',
['夜露']='夜露西苦:BAAALgAECgEJAQAAAA==.',
['大汉']='大汉满身:BAAALgAFFAEJAQAAAA==.',
['天地']='天地国宝:BAAALgADCgUJBQAAAA==.',
['天晴']='天晴有时雨:BAAALgADCgYJBgABLgAECgYJCgAFAAAAAA==.',
['天椒']='天椒小皇堡:BAAALgAECgQJBAAAAA==.',
['天运']='天运丨:BAAALgAFFAEJAQAAAA==.',
['天逸']='天逸风云扬:BAAALgADCgUJBQAAAA==.',
['天青']='天青色瞪眼鱼:BAAALgADCgYJBgAAAA==.',
['套装']='套装梯二二:BAAALgADCgMJAwAAAA==.',
['奥尔']='奥尔良:BAAALgAECgEJAwAAAA==.',
['奥莉']='奥莉薇娅:BAAALgAECgcJBwAAAA==.',
['奥黛']='奥黛丽圐圙:BAAALgADCgEJAQAAAA==.',
['奶飞']='奶飞天:BAAALgAECgEJAQAAAA==.',
['好哥']='好哥哥哦:BAAALgAECgYJCQAAAA==.',
['妈德']='妈德别跑:BAAALgAECgEJAQAAAA==.',
['婉嫣']='婉嫣:BAAALgADCgkJAQAAAA==.',
['孤垩']='孤垩:BAAALgADCgQJBAAAAA==.',
['孤灬']='孤灬星痕:BAAALgAECgIJAgAAAA==.',
['宇宇']='宇宇爱:BAAALgAECgYJCgAAAA==.',
['安安']='安安快跑:BAAALgAECgYJBwAAAA==.',
['安琪']='安琪儿:BAAALgAECgUJBQAAAA==.',
['宫本']='宫本武藏:BAAALgADCgIJAgAAAA==.',
['寂寞']='寂寞牛宝宝:BAAALgAECgEJAQAAAA==.寂寞牛寶寶:BAAALgAECgEJAQAAAA==.',
['小丑']='小丑艾伦:BAAALgAECgEJAQAAAA==.',
['小凶']='小凶许:BAAALgAECgcJBAAAAA==.',
['小可']='小可憐:BAAALgAECgEJAQAAAA==.',
['小天']='小天使艾薇尓:BAAALgAECgEJAQAAAA==.',
['小妈']='小妈:BAAALgAECgYJBwAAAA==.',
['小妞']='小妞卜要啊:BAAALgADCgEJAQAAAA==.',
['小姝']='小姝姝:BAAALgAECgYJBgAAAA==.',
['小忽']='小忽悠:BAAALgAECgYJCQAAAA==.',
['小手']='小手冰冰凉:BAAALgAECgQJAwAAAA==.',
['小混']='小混子:BAAALgAECgcJCQAAAA==.',
['小猎']='小猎阿呆:BAAALgAECgYJBgAAAA==.',
['小糯']='小糯米鸡:BAAALgAECgIJAgAAAA==.',
['小蛙']='小蛙牛:BAAALgADCgIJAgAAAA==.',
['小豆']='小豆角儿:BAAALgAECgkJCQAAAA==.',
['小都']='小都督:BAABLgAFFH8GAAIXAAIJTQJ5IAByAAAXAAIJTQJ5IAByAAAAAA==.',
['小雪']='小雪:BAAALgAECgcJEQAAAA==.',
['小马']='小马佩德罗:BAAALgAECgQJBAAAAA==.',
['少吃']='少吃火锅:BAABLgAFFH8FAAITAAMJfB4aAwAhAQATAAMJfB4aAwAhAQAAAA==.',
['山中']='山中井野:BAAALgAECgUJBQAAAA==.',
['左手']='左手倒影:BAABLgAFFH8IAAIYAAMJwQ0qHQDrAAAYAAMJwQ0qHQDrAAAAAA==.',
['巴基']='巴基大狂风:BAAALgAECgQJBAAAAA==.',
['布兰']='布兰德丶:BAAALgAECgMJBAAAAA==.',
['帕斯']='帕斯大大:BAAALgAFFAIJAgAAAA==.',
['年事']='年事已膏:BAACLgAFFH8GAAMZAAMJThI9AgCaAAAZAAMJThI9AgCaAAAJAAEJmQLCBgBHAAAuAAQKfxcAAhkABwnMGQALAOMBABkABwnMGQALAOMBAAAA.',
['年年']='年年糕:BAAALgAFFAMJBAAAAA==.',
['年糕']='年糕戰士:BAAALgAECgYJCwAAAA==.年糕萨满:BAAALgAECggJEAAAAA==.',
['幸福']='幸福快车:BAAALgAECgIJAgAAAA==.',
['幸运']='幸运迪亚波罗:BAAALgAECgUJBQAAAA==.',
['幸運']='幸運修女:BAAALgAECgQJBAAAAA==.幸運傻蛮:BAAALgADCgcJBwAAAA==.幸運兽战:BAAALgAECgYJCgAAAA==.幸運影殺:BAAALgAECgYJCAAAAA==.幸運快車:BAAALgAFFAEJAQAAAA==.幸運海拳师:BAAALgADCgkJAQAAAA==.幸運猫小魅:BAAALgAECgYJBgAAAA==.幸運靓术:BAAALgAECgYJBgAAAA==.',
['幽冥']='幽冥麒麟:BAAALgAECgYJCgAAAA==.',
['广东']='广东灬豉油鸡:BAAALgAECgEJAQAAAA==.',
['张小']='张小天的裤衩:BAAALgAECgYJDgAAAA==.',
['张雕']='张雕:BAAALgAECgQJBAABLgAFFAMJBAAFAAAAAA==.',
['弹头']='弹头丶:BAAALgAFFAIJBAAAAA==.',
['心慈']='心慈丶手软:BAAALgAECgEJAQAAAA==.',
['忆往']='忆往昔:BAAALgAECgQJBAAAAA==.',
['快来']='快来喝了这杯:BAABLgAFFH8HAAIQAAMJtxZrDADeAAAQAAMJtxZrDADeAAAAAA==.',
['思念']='思念的情绪:BAAALgADCggJCAAAAA==.',
['怪就']='怪就怪天气:BAAALgAECgYJBQAAAA==.',
['恶饿']='恶饿呃:BAAALgAECgYJBAAAAA==.',
['恶魔']='恶魔丛森:BAAALgADCgEJAQAAAA==.恶魔卡卡:BAAALgAECgQJBAAAAA==.',
['悠殇']='悠殇丶:BAAALgADCgYJBgAAAA==.',
['想吃']='想吃火锅:BAABLgAECn8fAAIaAAgJxyMcAACyAgAaAAgJxyMcAACyAgAAAA==.',
['慕灬']='慕灬欢:BAAALgAECgQJBgAAAA==.',
['我以']='我以前是爆眼:BAAALgAECgYJDAAAAA==.',
['我兄']='我兄弟会转弯:BAABLgAFFH8GAAIbAAMJ0wnmCADWAAAbAAMJ0wnmCADWAAAAAA==.',
['我勒']='我勒个脆:BAAALgADCgEJAQAAAA==.',
['我狠']='我狠射:BAAALgAECgMJAwAAAA==.',
['我看']='我看从买彩票:BAAALgAECgYJBgAAAA==.',
['我要']='我要转起来了:BAAALgAECgMJAwAAAA==.',
['戴蝴']='戴蝴蝶结的猫:BAAALgAECgEJAQAAAA==.',
['扎死']='扎死墓巫:BAAALgAECgUJCwAAAA==.',
['打渔']='打渔村村花:BAAALgAECgYJBAAAAA==.',
['把花']='把花送给妈妈:BAAALgAECgYJBgAAAA==.',
['折戟']='折戟沉沙乄:BAAALgAFFAIJBAAAAA==.',
['折翼']='折翼的火法:BAABLgAFFH8GAAIDAAIJqwSePQCVAAADAAIJqwSePQCVAAABLgAFFAYJBAAFAAAAAA==.',
['放开']='放开那位阿姨:BAAALgAECgcJBwAAAA==.',
['整个']='整个烂活儿:BAAALgAECgQJBAAAAA==.',
['无聊']='无聊是种习惯:BAAALgAECgEJAQAAAA==.',
['无证']='无证骑士:BAAALgAECgEJAQAAAA==.',
['星海']='星海无垠:BAAALgAECgMJBAAAAA==.星海灿烂:BAAALgAECgcJDQAAAA==.',
['是清']='是清秋的雲丶:BAAALgAECgcJDQAAAA==.',
['晨林']='晨林逐日:BAAALgAECgYJCgAAAA==.',
['晴风']='晴风村的少年:BAAALgADCgUJBQAAAA==.',
['暖懿']='暖懿:BAAALgAECgUJCAAAAA==.',
['暗之']='暗之光凤:BAAALgAECggJCwAAAA==.',
['曰地']='曰地恨软:BAAALgADCgUJBQAAAA==.',
['月光']='月光照耀酱:BAAALgAECgUJCAAAAA==.',
['月神']='月神殿城主:BAABLgAECn8XAAMVAAgJzBddPABCAQAVAAUJoBRdPABCAQAXAAcJpgrLYgApAQAAAA==.',
['朝乾']='朝乾夕惕:BAAALgAECgkJCQAAAA==.',
['木村']='木村拓哉:BAAALgAFFAMJBAAAAA==.',
['朽云']='朽云:BAAALgADCgEJAQAAAA==.',
['朽月']='朽月:BAAALgAFFAIJBAAAAA==.',
['朽木']='朽木灬德爷:BAAALgAECgMJBQAAAA==.',
['来个']='来个鸡蛋:BAABLgAFFH8FAAIRAAIJMR9FFAC5AAARAAIJMR9FFAC5AAAAAA==.',
['来根']='来根儿冰工厂:BAAALgAECgUJBQAAAA==.',
['柒號']='柒號:BAACLgAFFH8JAAIEAAMJxhcRBwD0AAAEAAMJxhcRBwD0AAAuAAQKfyAAAgQACAmGHEUIAKACAAQACAmGHEUIAKACAAAA.',
['桃香']='桃香乌龙茶:BAAALgAFFAMJBAAAAA==.',
['梁梦']='梁梦贤二娃:BAAALgAECgYJDwAAAA==.',
['梨花']='梨花丶:BAAALgAECgEJAQAAAA==.梨花波文急走:BAAALgADCgYJBgAAAA==.',
['棒棒']='棒棒圣光:BAAALgAECgEJAQAAAA==.',
['森羅']='森羅萬象:BAAALgAECgUJCAAAAA==.',
['榨菜']='榨菜肉丝:BAAALgAFFAEJAQAAAA==.',
['樊书']='樊书衍:BAAALgAECgYJCAAAAA==.',
['樱朧']='樱朧:BAAALgADCgEJAQAAAA==.',
['樱雪']='樱雪恋舞:BAAALgADCgEJAQAAAA==.',
['橙出']='橙出不穷丶:BAAALgADCgYJBgAAAA==.',
['欧皇']='欧皇帕斯:BAAALgAECggJEAAAAA==.欧皇的表妹:BAAALgADCgEJAQAAAA==.',
['正的']='正的发邪:BAAALgAECgMJBQAAAA==.',
['正義']='正義的伙伴:BAAALgAECgYJBgAAAA==.',
['殺手']='殺手不太冷:BAACLgAFFH8IAAMSAAMJyBE3EgD0AAASAAMJyBE3EgD0AAAEAAEJZgctCAA7AAAuAAQKfxsAAxIACAlHHrAXAI4CABIABwm9H7AXAI4CAAQAAQmAFRFEAD0AAAAA.',
['水晶']='水晶包:BAAALgAFFAEJAQAAAA==.',
['求洎']='求洎己釋懷:BAABLgAECn8UAAILAAcJPxF9gACCAQALAAcJPxF9gACCAQAAAA==.',
['汉正']='汉正街氵水锅:BAAALgAECgEJAQAAAA==.',
['汐焱']='汐焱:BAABLgAFFH8GAAMIAAMJTxAKAwDDAAAIAAMJ5w0KAwDDAAAGAAEJRA5ZFwBVAAAAAA==.',
['汤米']='汤米仔:BAAALgAECgMJBAAAAA==.',
['没门']='没门:BAAALgAECgEJAQAAAA==.',
['河溪']='河溪坝砍王:BAAALgAECgYJBgAAAA==.',
['油哄']='油哄哄:BAAALgAECgEJAQAAAA==.',
['泛泛']='泛泛:BAAALgAECgQJBgAAAA==.',
['泶伯']='泶伯爵:BAAALgAECgYJCwAAAA==.',
['洛櫻']='洛櫻:BAABLgAECn8YAAMPAAcJiBgoNwDSAQAPAAcJVxIoNwDSAQAOAAcJQA1sRABDAQAAAA==.',
['洛神']='洛神:BAAALgAECggJCAAAAA==.',
['洛阿']='洛阿变奏曲:BAAALgAECgMJAwAAAA==.',
['浣浣']='浣浣:BAACLgAFFH8IAAIDAAMJXgkeJwDhAAADAAMJXgkeJwDhAAAuAAQKfx0AAwMACAnQGtUbAK4CAAMACAnQGtUbAK4CAAwAAQnDFBFqAD4AAAAA.',
['浦东']='浦东吴彦祖:BAAALgAECgkJEAAAAA==.',
['浪在']='浪在四方:BAAALgAECgcJCgAAAA==.',
['海失']='海失火:BAAALgAECgEJAQAAAA==.',
['海岛']='海岛火龙果:BAAALgADCgYJBgABLgAFFAQJDAAPAAgYAA==.',
['涯应']='涯应:BAAALgADCgYJBwAAAA==.',
['深水']='深水浅冰:BAAALgAECgYJCQAAAA==.',
['清枫']='清枫:BAAALgAECgYJBgAAAA==.',
['清风']='清风挽月:BAAALgAECgYJDwAAAA==.',
['渡边']='渡边月丶:BAAALgAFFAEJAgAAAA==.',
['游山']='游山恋:BAAALgAECgYJBgAAAA==.',
['滑铲']='滑铲达人:BAAALgAECgQJBQAAAA==.',
['满城']='满城烽火:BAAALgAECgIJBAAAAA==.',
['满身']='满身大汗:BAABLgAECn8dAAMcAAgJGxnjDgDsAQAcAAcJIhrjDgDsAQACAAcJwxU4HwDJAQAAAA==.',
['漂亮']='漂亮哥哥:BAAALgAECgYJCAAAAA==.',
['灬哀']='灬哀沐涕:BAAALgAFFAIJAgAAAA==.',
['灬灬']='灬灬德灬灬:BAAALgAECgYJBgAAAA==.',
['灬雪']='灬雪之影灬:BAAALgAFFAIJBAAAAA==.灬雪之殇灬:BAABLgAFFH8FAAIKAAMJXhqbFwC7AAAKAAMJXhqbFwC7AAAAAA==.',
['灬魚']='灬魚鱼魚灬:BAAALgAFFAEJAQAAAA==.',
['烈空']='烈空座丶:BAAALgAECgYJBgAAAA==.',
['熊尼']='熊尼嘛:BAAALgAECgYJBgAAAA==.',
['熊熊']='熊熊思琳:BAAALgAECgQJBAAAAA==.',
['熬疯']='熬疯:BAAALgADCgEJAQAAAA==.',
['爆破']='爆破鬼财:BAAALgAECggJBgAAAA==.',
['爱吃']='爱吃柚子杨桃:BAAALgAECgQJBAAAAA==.',
['爱嘤']='爱嘤斯坦:BAAALgAECgIJAQAAAA==.',
['爱用']='爱用舒肤佳:BAAALgAFFAMJBAAAAA==.',
['爷傲']='爷傲丶奈我何:BAAALgAECgQJBAAAAA==.',
['爻乙']='爻乙口:BAAALgAFFAEJAQAAAA==.',
['牧小']='牧小诗:BAAALgAECgEJAQAAAA==.',
['狂战']='狂战天下:BAAALgADCgUJBQAAAA==.',
['狄娅']='狄娅娜:BAAALgAFFAEJAQAAAA==.',
['狐若']='狐若初见:BAAALgADCgUJBQAAAA==.',
['狐言']='狐言乱语:BAAALgAECgUJCQAAAA==.',
['狗儿']='狗儿蛋:BAAALgAECgYJCAAAAA==.',
['狼牙']='狼牙乱舞:BAAALgADCgUJBQAAAA==.',
['猫德']='猫德好烦:BAAALgADCgEJAQAAAA==.',
['猫雪']='猫雪旺:BAAALgAECgYJDAAAAA==.',
['王大']='王大锤:BAAALgAECgQJBAAAAA==.',
['玖姑']='玖姑娘:BAAALgADCgEJAQAAAA==.',
['玖星']='玖星:BAAALgAECgEJAQAAAA==.',
['玛赫']='玛赫:BAAALgAECgEJAgAAAA==.',
['瑞斯']='瑞斯洛克:BAAALgAECgcJDwAAAA==.',
['番茄']='番茄洋柿子:BAAALgAFFAMJBAAAAA==.',
['畵魂']='畵魂:BAAALgAECgcJBwAAAA==.',
['疯牛']='疯牛病传播者:BAAALgAFFAIJAgAAAA==.',
['痛灭']='痛灭宝:BAAALgAECgEJAQAAAA==.',
['痛痛']='痛痛怪:BAAALgAECgMJAwAAAA==.',
['百式']='百式天邪:BAAALgAECgYJCgAAAA==.',
['皮特']='皮特丿:BAAALgAECgEJAgAAAA==.皮特大叔丿:BAAALgAECgYJCQAAAA==.',
['盲眼']='盲眼杂耍者:BAAALgAECgYJBgAAAA==.',
['眸影']='眸影:BAAALgADCgEJAQAAAA==.',
['睿智']='睿智的睿酱:BAAALgAECgYJBQAAAA==.',
['瞄不']='瞄不准:BAAALgAECgIJAgAAAA==.',
['瞄的']='瞄的准:BAAALgAECgcJBwAAAA==.',
['砚染']='砚染流云:BAAALgAFFAEJAQAAAA==.',
['破晓']='破晓挽歌:BAABLgAFFH8FAAILAAMJGx+oCQArAQALAAMJGx+oCQArAQAAAA==.',
['硬到']='硬到爆炸:BAAALgAECgIJAwAAAA==.',
['碾压']='碾压贝多芬:BAAALgAECgMJAwAAAA==.',
['祁夜']='祁夜:BAAALgADCgYJBgAAAA==.',
['祈秋']='祈秋:BAAALgAFFAIJAgABLgAFFAMJBwABAJciAA==.',
['神佑']='神佑追命:BAAALgAECgQJBAAAAA==.神佑风语者:BAAALgADCgEJAQAAAA==.',
['空穴']='空穴来風:BAAALgADCgEJAQAAAA==.',
['章台']='章台柳:BAAALgAECgYJCgAAAA==.',
['第四']='第四丶苜蓿:BAAALgAFFAEJAQAAAA==.',
['精神']='精神小伙:BAAALgAECgEJAwAAAA==.',
['糖门']='糖门躺:BAAALgAECgcJBwAAAA==.',
['索伦']='索伦大魔王:BAAALgAECgUJBQAAAA==.',
['紫云']='紫云小白:BAAALgAFFAMJBAAAAA==.',
['緃火']='緃火的树哥丶:BAAALgADCgUJBQAAAA==.',
['红名']='红名都是怪:BAAALgAECgcJDgAAAA==.',
['红烧']='红烧猪蹄花:BAAALgAECgcJDAAAAA==.',
['红色']='红色双马尾:BAAALgADCgEJAQAAAA==.红色燕子:BAAALgAECgkJEQAAAA==.',
['给点']='给点糖果吃:BAAALgAECgEJAQAAAA==.',
['绮丶']='绮丶念:BAABLgAFFH8FAAIQAAIJ8g39EACUAAAQAAIJ8g39EACUAAAAAA==.',
['缘之']='缘之随风:BAAALgADCgEJAQAAAA==.',
['缠流']='缠流子:BAAALgAECgIJAgAAAA==.',
['群体']='群体混乱箭:BAAALgAFFAIJAwAAAA==.',
['翼德']='翼德丶:BAAALgAFFAEJAQAAAA==.',
['老五']='老五来了:BAAALgADCgQJBAAAAA==.',
['老吴']='老吴的芙蓉王:BAAALgAFFAIJAwAAAA==.',
['老牛']='老牛痕深:BAAALgADCgMJAwAAAA==.',
['老鸽']='老鸽:BAABLgAFFH8FAAIGAAIJIxe3JQCgAAAGAAIJIxe3JQCgAAABLgAFFAYJCwAKAL0cAA==.',
['胸毛']='胸毛爱美丽:BAAALgADCgUJBQAAAA==.',
['膏利']='膏利贷:BAAALgAECgEJAQAAAA==.',
['自然']='自然艾尔:BAABLgAECn8UAAMXAAYJ0xqYOwC2AQAXAAYJ0xqYOwC2AQAVAAIJjAN0dABQAAAAAA==.',
['艾库']='艾库莱亚:BAABLgAFFH8JAAISAAMJgiKcAwA2AQASAAMJgiKcAwA2AQAAAA==.',
['芝士']='芝士咸奶油:BAAALgADCgEJAgAAAA==.',
['花孽']='花孽:BAAALgADCgYJBAAAAA==.',
['花菱']='花菱惜若:BAAALgAECgcJEgAAAA==.',
['花落']='花落亦不惜:BAAALgADCgQJBAAAAA==.花落依不惜:BAAALgADCgEJAQAAAA==.',
['苍苍']='苍苍横翠微:BAAALgAECgYJCwAAAA==.',
['若有']='若有所言:BAAALgADCgYJBwAAAA==.',
['茬子']='茬子:BAAALgAECgMJBAAAAA==.',
['荆棘']='荆棘剑盾:BAAALgAECgEJAQAAAA==.',
['莫得']='莫得法:BAAALgAECgkJCwAAAA==.',
['萌萌']='萌萌丶小德:BAAALgAECgcJBwABLgAFFAYJFQAVAHIhAA==.',
['落零']='落零星:BAABLgAFFH8FAAIKAAIJ4xnzNgC8AAAKAAIJ4xnzNgC8AAAAAA==.',
['蒋姑']='蒋姑娘:BAAALgAECgYJBgAAAA==.',
['蕾丝']='蕾丝灬花边:BAAALgAECgYJBwAAAA==.',
['蛇王']='蛇王:BAAALgAFFAEJAQAAAA==.',
['蛮牛']='蛮牛:BAAALgADCgMJAwAAAA==.',
['蛮王']='蛮王:BAAALgADCgYJBgAAAA==.',
['血泪']='血泪的丶青春:BAAALgAECgIJAgAAAA==.',
['血紫']='血紫涵:BAAALgAECgMJAwAAAA==.',
['被改']='被改名了:BAAALgAECgcJCAAAAA==.',
['解忧']='解忧丶雪小贱:BAAALgAECgcJBwAAAA==.',
['设计']='设计院德老牛:BAAALgAECgYJBgAAAA==.',
['诗与']='诗与胡说:BAAALgAECgMJAwAAAA==.',
['调和']='调和之天救龙:BAAALgAECgkJCQAAAA==.',
['豹子']='豹子头零充:BAACLgAFFH8HAAMYAAMJ9Ar+DwDWAAAYAAMJ9Ar+DwDWAAAdAAIJvAEeCwCCAAAuAAQKfx4AAx0ACAkPD8UfAL8BAB0ACAklDMUfAL8BABgACAnpC+ljAHUBAAAA.',
['路人']='路人甲的毒奶:BAAALgADCgIJAgABLgAECgMJAwAFAAAAAA==.',
['载少']='载少年:BAAALgAECgIJBgAAAA==.',
['辉耀']='辉耀骑士:BAAALgAECgcJEAAAAA==.',
['迷雾']='迷雾:BAAALgADCgYJBgAAAA==.',
['遇术']='遇术临风:BAAALgAECgEJAQAAAA==.',
['邂逅']='邂逅地丶青春:BAAALgAECgUJCAAAAA==.',
['邓布']='邓布利恶魔多:BAAALgAECgMJAwAAAA==.',
['邪子']='邪子:BAAALgAECgIJAgAAAA==.',
['郁闷']='郁闷了喝牛奶:BAAALgAECgYJAgAAAA==.',
['郝霸']='郝霸霸:BAAALgAECgQJBQAAAA==.',
['酒仙']='酒仙武圣:BAAALgAECgYJBgAAAA==.',
['酒笙']='酒笙清栀:BAAALgAECgcJBwAAAA==.',
['酥脆']='酥脆鸡翅:BAAALgAECgEJAQAAAA==.',
['酷玩']='酷玩马克:BAAALgAECgEJAQAAAA==.',
['酸菜']='酸菜锦鲤:BAAALgAECgIJAgAAAA==.',
['銱神']='銱神灬与云:BAAALgAECgEJAgAAAA==.',
['银城']='银城路包工头:BAAALgADCgQJBAAAAA==.',
['银月']='银月城的少女:BAAALgADCgUJBQAAAA==.',
['長安']='長安丶小战:BAAALgAECgYJEAAAAA==.長安小獵:BAAALgAECgcJBwAAAA==.',
['闪开']='闪开我来抗:BAAALgAECgcJAgAAAA==.',
['阿尔']='阿尔茨海寞:BAAALgAECgEJAQAAAA==.',
['阿曼']='阿曼苏尔水晶:BAAALgAECgQJCAAAAA==.',
['阿索']='阿索姆斯:BAAALgAECgUJCAAAAA==.',
['阿里']='阿里里:BAAALgAECgIJAgAAAA==.',
['阿雅']='阿雅:BAAALgAECgEJAQAAAA==.',
['陈晓']='陈晓:BAAALgAECgMJAwAAAA==.',
['陈洁']='陈洁琪:BAAALgAECgkJBgAAAA==.',
['随风']='随风铃丶:BAACLgAFFH8HAAIeAAMJpQu/CwC9AAAeAAMJpQu/CwC9AAAuAAQKfyAAAh4ACAn9FC8RAPgBAB4ACAn9FC8RAPgBAAAA.',
['隔壁']='隔壁的那只鸡:BAAALgAECgIJAQAAAA==.',
['雨落']='雨落随心:BAAALgAECgEJAQAAAA==.',
['雪夜']='雪夜无憾:BAAALgAECgcJDwAAAA==.',
['雪舞']='雪舞残阳:BAAALgAECgcJBwABLgAFFAQJCAAGALEFAA==.',
['零七']='零七一号:BAAALgAECgUJBQAAAA==.',
['雷军']='雷军的娃:BAAALgAECgYJBgAAAA==.',
['雾隐']='雾隐青衫:BAAALgAECgMJAwAAAA==.',
['霹雳']='霹雳大帅皮:BAAALgADCgMJAwAAAA==.',
['青枫']='青枫:BAAALgAECgEJAQAAAA==.',
['青柑']='青柑乌龙茶:BAAALgAECgYJDQAAAA==.',
['非洲']='非洲小白脸吖:BAAALgADCgIJAgAAAA==.',
['面条']='面条牛牛:BAAALgADCgEJAQAAAA==.',
['鞘藏']='鞘藏红尘三千:BAAALgADCgYJBgAAAA==.',
['韩晓']='韩晓:BAAALgADCgYJBgAAAA==.',
['風子']='風子丶:BAACLgAFFH8HAAILAAMJvhhFJwD6AAALAAMJvhhFJwD6AAAuAAQKfx4AAgsACAlDHecfAMICAAsACAlDHecfAMICAAAA.',
['风早']='风早灬翔太:BAAALgAECgEJAQAAAA==.',
['风雪']='风雪满证衣:BAAALgAECgQJBAAAAA==.',
['飘逸']='飘逸大西瓜:BAAALgAECgEJAQAAAA==.',
['鬼瞳']='鬼瞳:BAAALgAECgMJBAAAAA==.',
['魈颾']='魈颾騠孖:BAAALgAECgYJBgAAAA==.',
['魔法']='魔法关照豌豆:BAAALgAFFAEJAgAAAA==.',
['鲜血']='鲜血如红唇:BAAALgAFFAIJAQAAAA==.',
['鲨鱼']='鲨鱼辣椒丶:BAAALgAECgMJAwAAAA==.',
['鸢一']='鸢一折纸:BAAALgAFFAIJAgAAAA==.',
['鸢尾']='鸢尾气泡水:BAACLgAFFH8PAAIKAAQJ3g9PHgBRAQAKAAQJ3g9PHgBRAQAuAAQKfzUAAgoABwkWILY4AJICAAoABwkWILY4AJICAAAA.',
['麦当']='麦当劳叔叔啊:BAAALgAECgQJBAAAAA==.麦当劳大叔:BAAALgAECgUJBQAAAA==.',
['黑兔']='黑兔应援会长:BAABLgAFFH8GAAIGAAIJ1QUaEgCRAAAGAAIJ1QUaEgCRAAAAAA==.',
['黑喵']='黑喵应援会长:BAAALgAECgYJDAAAAA==.',
['黑夜']='黑夜死神灬飞:BAAALgAECgcJCQAAAA==.',
['黑色']='黑色新娘:BAAALgAECgEJAQAAAA==.',
['黑菩']='黑菩提:BAAALgAECgYJBAAAAA==.',
['龙套']='龙套的生涯:BAAALgAECgYJCgAAAA==.',
['龙欲']='龙欲惩:BAAALgAECgEJAQAAAA==.龙欲襳:BAAALgADCgQJBAAAAA==.龙欲风:BAAALgAECgEJAQAAAA==.',
['龙翔']='龙翔飞雪:BAAALgADCgUJBQAAAA==.',
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
