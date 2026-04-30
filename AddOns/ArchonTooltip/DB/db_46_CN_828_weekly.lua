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

local lookup = {'Shaman-Elemental','Mage-Frost','DemonHunter-Devourer','Warlock-Demonology','Druid-Restoration','Evoker-Augmentation','Paladin-Retribution','Priest-Shadow','Monk-Brewmaster','Unknown-Unknown','DeathKnight-Unholy','Shaman-Restoration','Paladin-Holy','Druid-Balance','Druid-Guardian','DemonHunter-Havoc','Evoker-Preservation','DemonHunter-Vengeance','Warrior-Protection','Hunter-Marksmanship','Monk-Mistweaver','Hunter-BeastMastery','Warlock-Destruction','Monk-Windwalker','DeathKnight-Frost','Rogue-Subtlety','Rogue-Outlaw','Priest-Discipline','Priest-Holy','Evoker-Devastation','Warlock-Affliction',}
local provider = {region='CN',realm='试炼之环',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Albert:BAAALgAECgcJDQAAAA==.Alsun:BAAALgAFFAIJAgAAAA==.',
Ar='Artemls:BAAALgAECgYJBgAAAA==.Arwen:BAAALgAECggJBwABLgAFFAUJDAABANMiAA==.Aryastark:BAAALgADCgQJBAAAAA==.',
As='Asika:BAAALgAECgQJCwAAAA==.',
At='Atf:BAAALgAECgYJCwAAAA==.',
Be='Beancox:BAAALgAECgUJBQAAAA==.Beanczh:BAAALgAFFAQJAwAAAA==.',
Br='Brian:BAAALgAECgQJBAAAAA==.',
Ch='Cheers:BAAALgAECgEJAQAAAA==.',
Co='Collapse:BAABLgAFFH8JAAICAAMJ3RNlFgAGAQACAAMJ3RNlFgAGAQABLgAFFAcJBgACANUOAA==.Conqueror:BAAALgAECgcJBwAAAA==.',
Cr='Creamqvq:BAABLgAFFH8IAAIDAAUJryFRBQDUAQADAAUJryFRBQDUAQAAAA==.',
De='Demonmaster:BAABLgAFFH8HAAIEAAMJzCRrCQBIAQAEAAMJzCRrCQBIAQAAAA==.Derritter:BAAALgAECgEJAQAAAA==.',
Dr='Draenam:BAAALgAECgEJAQAAAA==.',
Ee='Eedzxd:BAAALgAECgEJAgAAAA==.',
Ex='Exice:BAABLgAFFH8FAAIFAAIJGBl0DgClAAAFAAIJGBl0DgClAAAAAA==.',
Fi='Firstloves:BAAALgAFFAMJAQAAAA==.',
Gg='Ggpanda:BAAALgAECgEJAQABLgAFFAQJEAAGAKAkAA==.',
Gl='Glt:BAAALgADCgcJDAAAAA==.',
Ha='Hade:BAAALgAECgIJAgAAAA==.',
Hh='Hheisenberg:BAAALgAECgQJBAAAAA==.',
In='Indigo:BAAALgADCgYJBgAAAA==.',
Ju='Juri:BAAALgAECgEJAQAAAA==.',
Ki='Kimijimamio:BAABLgAFFH8HAAIHAAMJkBTzFAABAQAHAAMJkBTzFAABAQAAAA==.',
Lu='Luckely:BAAALgAFFAIJBAAAAA==.',
Me='Meeka:BAABLgAFFH8HAAIIAAMJ9x3DBQD+AAAIAAMJ9x3DBQD+AAAAAA==.',
Mi='Mikà:BAAALgAECgcJCgAAAA==.',
Mo='Mozz:BAAALgAECgQJBwAAAA==.',
Na='Nayanion:BAAALgAECgYJBgAAAA==.',
Ne='Neoracle:BAAALgAECgEJAQAAAA==.',
Ot='Otz:BAAALgAECgIJAgABLgAFFAQJEAAJAKwiAA==.',
Qi='Qiuqiudh:BAABLgAFFH8LAAIDAAQJBB7JDwBPAQADAAQJBB7JDwBPAQAAAA==.',
Ra='Raccoon:BAAALgAECgYJBwAAAA==.',
Ro='Robing:BAAALgAECgQJBQAAAA==.',
Sa='Sakuras:BAAALgAECgEJAQAAAA==.Sakuraxdd:BAAALgAECgYJDAABLgAFFAIJBAAKAAAAAA==.',
Su='Sudevil:BAAALgAFFAEJAQABLgAFFAQJCwADAAQeAA==.',
Th='Thelonerange:BAAALgAECgEJAQAAAA==.Thomus:BAAALgAECgMJAwAAAA==.',
To='Tommyshelby:BAACLgAFFH8HAAILAAMJ0Ba+FADwAAALAAMJ0Ba+FADwAAAuAAQKfxYAAgsACAlgHWI0AGUCAAsACAlgHWI0AGUCAAEuAAUUAwkHAAcAkBQA.',
Ug='Ugrace:BAAALgAECgYJCQAAAA==.',
Va='Valonia:BAAALgAECgUJBQAAAA==.',
Wi='Will:BAAALgAECgEJAQAAAA==.',
Yu='Yulim:BAAALgAECgEJAQAAAA==.',
Ze='Zephyra:BAABLgAECn8UAAIFAAkJZiNGAACVAwAFAAkJZiNGAACVAwAAAA==.',
Zi='Zion:BAAALgAECgIJAgAAAA==.',
['一抹']='一抹浅蓝:BAAALgAECgYJDQAAAA==.',
['一束']='一束丶光:BAACLgAFFH8GAAIHAAMJ1QtQDgDxAAAHAAMJ1QtQDgDxAAAuAAQKfxUAAgcABwlfHnJBACECAAcABwlfHnJBACECAAAA.',
['一神']='一神之哀伤一:BAAALgAECgUJCgAAAA==.',
['一脚']='一脚破伤风:BAAALgAECgIJAgAAAA==.',
['一路']='一路丶向南:BAAALgAECgYJCQAAAA==.',
['一霸']='一霸霸一:BAAALgAECgEJAQAAAA==.',
['三藏']='三藏狄燊:BAAALgAECgIJAgAAAA==.',
['上弦']='上弦月之歌:BAAALgAECgIJAwAAAA==.',
['不再']='不再低调:BAAALgADCgEJAQAAAA==.',
['不出']='不出橙怪我咯:BAAALgAECgEJAQAAAA==.',
['不可']='不可捕捉:BAAALgAECgEJAQAAAA==.',
['专打']='专打老弱病残:BAAALgAECgEJAQAAAA==.',
['丨刃']='丨刃峰丨:BAAALgAECgEJAQAAAA==.',
['丨法']='丨法灬正丨:BAAALgAECgYJDwAAAA==.',
['丨爱']='丨爱布拉娜丨:BAAALgAECgYJCAAAAA==.',
['中坑']='中坑法:BAAALgAECgUJBQAAAA==.',
['丶再']='丶再睡一夏:BAAALgAECgIJAgAAAA==.',
['丶忠']='丶忠诚:BAAALgAECgYJEgAAAA==.',
['丶朵']='丶朵特:BAAALgAECgUJBwABLgAFFAIJAwAKAAAAAA==.',
['丶枫']='丶枫落灬:BAAALgAECgEJAQAAAA==.',
['丶牛']='丶牛:BAAALgAECgMJAwAAAA==.丶牛丶:BAAALgAFFAEJAQAAAA==.',
['丷古']='丷古尓丹丷:BAAALgAECgQJBwAAAA==.',
['丷追']='丷追疯子丷:BAAALgADCgQJBAAAAA==.',
['丿晨']='丿晨児丶:BAAALgAFFAEJAQAAAA==.',
['丿犀']='丿犀利爺丿:BAACLgAFFH8JAAMMAAIJaiL8EgDJAAAMAAIJaiL8EgDJAAABAAIJtw4EFgChAAAuAAQKfx0AAwwACAnDIDYJAOMCAAwACAnDIDYJAOMCAAEACAmfGBkdACgCAAAA.',
['九五']='九五清风:BAAALgAECgMJAwAAAA==.',
['乾兑']='乾兑离震:BAAALgAECgMJAwAAAA==.',
['二毛']='二毛骑士:BAAALgAECgYJCgAAAA==.',
['二零']='二零二六零一:BAAALgADCgcJDAAAAA==.',
['云来']='云来到:BAAALgADCgEJAQAAAA==.',
['五芒']='五芒星:BAAALgADCgcJBwAAAA==.',
['些许']='些许的等待:BAAALgAFFAMJAwAAAA==.',
['享图']='享图:BAAALgADCgQJAgAAAA==.',
['什么']='什么名字好:BAAALgAECgMJAwAAAA==.什么骑:BAAALgADCgEJAQAAAA==.',
['今夜']='今夜你最美丶:BAAALgAECgIJAgAAAA==.今夜你真美:BAAALgAECgYJDQAAAA==.',
['以自']='以自然为名:BAAALgAECgUJBwAAAA==.以自然之名:BAAALgAECgUJBQAAAA==.',
['休闲']='休闲小牛犊:BAAALgAECgQJBgAAAA==.',
['体型']='体型崩坏:BAAALgAECgYJCAAAAA==.',
['你五']='你五大爷:BAAALgAECgQJBAAAAA==.',
['倚法']='倚法治国:BAAALgADCgEJAQAAAA==.',
['倾邪']='倾邪:BAAALgAECgEJAQAAAA==.',
['假象']='假象:BAAALgAECgYJEQAAAA==.',
['元神']='元神启动:BAAALgAECgkJEgAAAA==.',
['兄蛹']='兄蛹砰派:BAAALgAECgMJAwAAAA==.',
['光之']='光之礼赞:BAAALgAFFAEJAQAAAA==.',
['光明']='光明顶:BAAALgAECgkJCQAAAA==.',
['克里']='克里德丶:BAABLgAECn8YAAINAAYJdySEBABAAgANAAYJdySEBABAAgAAAA==.',
['兜兜']='兜兜里有糖丶:BAAALgAECgEJAQAAAA==.',
['冈部']='冈部伦太郎:BAAALgAFFAEJAQAAAA==.',
['军合']='军合力不齐:BAABLgAFFH8HAAMOAAcJ/B2TAABvAgAOAAYJMyCTAABvAgAPAAEJ6hKjBQBcAAAAAA==.',
['农妇']='农妇山泉:BAAALgAECgYJCQAAAA==.',
['冬至']='冬至丶:BAAALgAECgEJAQAAAA==.',
['冬雪']='冬雪:BAAALgAECgIJAwAAAA==.',
['冰火']='冰火炫舞:BAABLgAECn8VAAICAAgJ5BHyHgB9AQACAAgJ5BHyHgB9AQAAAA==.',
['冰菟']='冰菟菟兔兔:BAAALgAECgEJAQAAAA==.',
['冷与']='冷与毒灬天照:BAAALgAECgkJCQAAAA==.',
['冷酷']='冷酷的郑同学:BAAALgAECgYJDwAAAA==.',
['凌空']='凌空:BAAALgAECgYJBgAAAA==.',
['凑你']='凑你咋地:BAAALgAECgIJAgAAAA==.',
['凝聚']='凝聚诺诺丶:BAAALgAECgYJBgAAAA==.',
['几度']='几度夕阳红:BAAALgAFFAEJAQAAAA==.',
['凯尔']='凯尔萨施:BAABLgAECn8VAAICAAgJ6hawFwCoAQACAAgJ6hawFwCoAQAAAA==.',
['刀剑']='刀剑剑非刀:BAAALgAECgEJAQAAAA==.',
['刘海']='刘海柱子:BAAALgAECgEJAQAAAA==.',
['初代']='初代吴彦祖:BAAALgAECgQJBAAAAA==.',
['利刃']='利刃华尔兹:BAAALgAECgcJDQAAAA==.',
['别惹']='别惹我行吗:BAAALgAFFAEJAQAAAA==.',
['劍倾']='劍倾城:BAAALgAECgMJBAAAAA==.',
['北冥']='北冥的鱼:BAAALgAFFAIJAgAAAA==.',
['北落']='北落:BAABLgAECn8eAAIQAAkJvyPZAADEAwAQAAkJvyPZAADEAwAAAA==.北落星辰:BAAALgAFFAQJBAAAAA==.',
['千早']='千早爱音:BAAALgADCgUJBQAAAA==.',
['千里']='千里之行:BAAALgAECgYJBgAAAA==.',
['千魂']='千魂:BAAALgAECgkJCQAAAA==.',
['半城']='半城安:BAAALgAECgEJAQAAAA==.',
['华美']='华美至善:BAAALgADCgUJBwAAAA==.',
['南岳']='南岳幽凰:BAAALgAECgQJAwAAAA==.',
['厉害']='厉害的阿昆达:BAAALgAECgEJAQAAAA==.',
['厉鬼']='厉鬼邪神:BAAALgAECggJDQAAAA==.',
['叁与']='叁与三山:BAAALgADCgMJBQAAAA==.',
['叁辻']='叁辻:BAAALgAECgEJAQAAAA==.',
['反撃']='反撃流:BAABLgAFFH8IAAILAAQJqBEhFgBLAQALAAQJqBEhFgBLAQAAAA==.',
['口一']='口一下丶:BAAALgAECgcJBwAAAA==.',
['古丶']='古丶尔丹:BAAALgAECgIJAwAAAA==.',
['古月']='古月娜:BAAALgAECgQJBAAAAA==.',
['只会']='只会神圣风暴:BAAALgAECgYJBgAAAA==.',
['可爱']='可爱大妞妞:BAAALgAECgUJBQAAAA==.可爱小可可:BAAALgAECgMJBAAAAA==.',
['吉米']='吉米哥:BAAALgAECgYJCAAAAA==.',
['后手']='后手拳扫堂腿:BAAALgADCgEJAQAAAA==.',
['君不']='君不见:BAAALgAECgcJEAAAAA==.',
['吟诗']='吟诗灬作乐:BAABLgAFFH8KAAICAAUJDRdtCgDLAQACAAUJDRdtCgDLAQAAAA==.',
['含光']='含光:BAAALgAECgEJAQAAAA==.',
['听说']='听说狠:BAAALgAECgEJAQAAAA==.',
['吸血']='吸血獠牙啊伊:BAAALgADCgEJAQAAAA==.',
['周三']='周三练背:BAAALgAFFAYJBAAAAA==.',
['周五']='周五瑜伽:BAAALgAFFAcJAQAAAA==.',
['周四']='周四练腿:BAABLgAFFH8JAAMOAAcJThaJAADHAQAOAAYJTBWJAADHAQAPAAEJVRtzBQBhAAAAAA==.',
['周諾']='周諾米:BAAALgAECgEJAQAAAA==.',
['呼风']='呼风唤宇:BAAALgAECgIJBAAAAA==.',
['哥们']='哥们的哥们:BAAALgAECgEJAQAAAA==.',
['哥斯']='哥斯拉巨兔:BAAALgADCgcJDQAAAA==.',
['哼哼']='哼哼哈圣騎士:BAAALgADCgEJAQAAAA==.',
['唯箭']='唯箭而已:BAAALgAFFAEJAQAAAA==.',
['啼鸟']='啼鸟一声春晚:BAACLgAFFH8FAAIRAAMJcxyTDAAdAQARAAMJcxyTDAAdAQAuAAQKfxwAAhEABwl4IPEJAJYCABEABwl4IPEJAJYCAAAA.',
['啾啾']='啾啾丷:BAABLgAFFH8FAAMRAAIJPyBmEADDAAARAAIJPyBmEADDAAAGAAEJkgCsJQA3AAABLgAFFAUJEwANAF0TAA==.',
['嗔滅']='嗔滅谶:BAAALgAECgMJBAAAAA==.',
['嗜血']='嗜血帝王:BAAALgADCgUJBQAAAA==.',
['嗥鬼']='嗥鬼:BAAALgAECgUJBQAAAA==.',
['嗯内']='嗯内孤:BAAALgAFFAEJAQAAAA==.',
['回归']='回归基本功:BAAALgAFFAEJAQAAAA==.',
['囨囨']='囨囨:BAAALgADCgQJBAAAAA==.',
['囹圄']='囹圄:BAAALgAECgMJBgAAAA==.',
['图腾']='图腾的叹息:BAAALgAECgEJAQAAAA==.',
['土星']='土星二号:BAAALgAECgcJBwAAAA==.',
['圣之']='圣之盾:BAAALgADCgEJAQAAAA==.',
['圣亞']='圣亞爱乐:BAAALgAECgcJDQAAAA==.',
['圣光']='圣光牛肉条儿:BAAALgAECgQJBAAAAA==.圣光裁决:BAAALgADCgcJBwAAAA==.',
['圣耀']='圣耀救赎:BAAALgAECgYJCQAAAA==.',
['地话']='地话:BAAALgADCgMJAwAAAA==.',
['壮烈']='壮烈三号:BAAALgAFFAQJBAAAAA==.壮烈二号:BAAALgAFFAEJAQAAAA==.壮烈五号:BAAALgAECgYJBgAAAA==.',
['夏树']='夏树繁花:BAAALgAECgMJAwAAAA==.',
['夕时']='夕时雨:BAAALgAECgQJBQAAAA==.',
['夕阳']='夕阳与余晖:BAAALgAECgEJAgAAAA==.',
['夜小']='夜小曦:BAAALgAECgEJAQAAAA==.',
['夜神']='夜神丨朵特:BAAALgAECgEJAQABLgAFFAIJAwAKAAAAAA==.',
['夠級']='夠級:BAAALgAECgMJAwAAAA==.',
['大冶']='大冶丹丹妹:BAAALgAECgQJBQAAAA==.',
['大红']='大红手老贼:BAAALgADCgEJAQAAAA==.',
['大郎']='大郎来喝药:BAAALgAECgkJCgAAAA==.',
['天下']='天下无双:BAAALgADCgYJBgAAAA==.',
['天使']='天使不爱美丽:BAAALgAFFAEJAQABLgAFFAcJBAAKAAAAAA==.',
['天凰']='天凰:BAAALgAFFAIJBAAAAA==.',
['天国']='天国复生:BAABLgAFFH8FAAILAAIJhRnlMgC9AAALAAIJhRnlMgC9AAAAAA==.天国灬重生:BAAALgAECgQJAwAAAA==.',
['天气']='天气好:BAAALgAECgEJAQAAAA==.',
['天涯']='天涯瞎:BAAALgAECgYJDAAAAA==.天涯龙:BAAALgAECgYJBgAAAA==.',
['天琦']='天琦琦大魔王:BAAALgAECgYJDQAAAA==.',
['天谴']='天谴断魂:BAAALgADCggJAgAAAA==.',
['天野']='天野阳菜:BAAALgAFFAQJAwAAAA==.',
['天闲']='天闲一铁僧:BAAALgADCgMJAwAAAA==.天闲之人:BAAALgAECgEJAQAAAA==.',
['天降']='天降萌萌兽:BAAALgAECgEJAQAAAA==.',
['天魔']='天魔无敌:BAAALgAECgYJCwAAAA==.',
['失火']='失火:BAAALgAECgQJCQAAAA==.',
['头顶']='头顶尖尖:BAABLgAECn8XAAMSAAcJ4SAOBACFAgASAAcJ4SAOBACFAgAQAAMJKQxMVQCSAAABLgAFFAQJDQAJACMeAA==.',
['奥之']='奥之法则:BAAALgAECgMJAwAAAA==.',
['奥斯']='奥斯卡桀:BAAALgAECgUJBQAAAA==.',
['奥蕾']='奥蕾利亚:BAAALgAECgEJAgAAAA==.',
['奶湯']='奶湯灬纯黑色:BAAALgAECgYJBgAAAA==.',
['奶蓟']='奶蓟段斐垣:BAAALgAECgEJAQAAAA==.',
['妖妖']='妖妖魅:BAABLgAECn8VAAILAAkJihVhLgB/AgALAAkJihVhLgB/AgAAAA==.',
['妖月']='妖月:BAAALgAECgEJAQAAAA==.',
['妙法']='妙法华莲:BAAALgADCgEJAQAAAA==.',
['妮奶']='妮奶奶灬熊猫:BAAALgAECgcJEgAAAA==.',
['孔月']='孔月:BAAALgAFFAMJAwAAAA==.',
['孟庭']='孟庭苇:BAAALgAECgYJBgAAAA==.',
['安德']='安德鲁森:BAABLgAECn8YAAITAAcJrAqKCgD/AAATAAcJrAqKCgD/AAAAAA==.',
['安格']='安格斯肥牛:BAAALgAECgEJAgAAAA==.',
['射不']='射不远:BAABLgAFFH8FAAIUAAUJGCBHBAD1AQAUAAUJGCBHBAD1AQAAAA==.',
['将縑']='将縑来比素:BAAALgAECgUJCQABLgAFFAMJBQARAHMcAA==.',
['小五']='小五花:BAAALgAECgEJAwAAAA==.',
['小吱']='小吱吱丷:BAACLgAFFH8TAAINAAUJXRPJAwCpAQANAAUJXRPJAwCpAQAuAAQKfxcAAw0ACQkoIC8FABkDAA0ACQkoIC8FABkDAAcAAQkeE1BFATIAAAAA.',
['小屁']='小屁:BAAALgAECgEJAQAAAA==.',
['小满']='小满:BAABLgAFFH8LAAILAAQJ/w4/GwA3AQALAAQJ/w4/GwA3AQAAAA==.',
['小灬']='小灬乔:BAAALgAECgIJAgAAAA==.',
['小烤']='小烤又又:BAAALgAECgQJBAAAAA==.',
['小趴']='小趴菜丶:BAAALgAECgYJBgAAAA==.',
['小鱼']='小鱼小虾:BAABLgAFFH8GAAICAAQJlQauJQAdAQACAAQJlQauJQAdAQAAAA==.',
['尛犇']='尛犇犇:BAAALgADCgUJBQAAAA==.',
['尛貊']='尛貊:BAAALgAECgYJBwAAAA==.',
['尝尝']='尝尝酒酒:BAAALgAECgYJBgAAAA==.',
['就是']='就是刘懂:BAAALgAECgUJCgAAAA==.',
['尼克']='尼克王尔德:BAAALgADCggJCAAAAA==.',
['尼古']='尼古丁三雨:BAAALgADCgUJBQAAAA==.',
['山水']='山水小德:BAAALgAECgYJBgAAAA==.山水梦画:BAAALgAECggJCgAAAA==.',
['崇尚']='崇尚野性:BAAALgAECgcJDgAAAA==.',
['崔斯']='崔斯特丶云想:BAAALgAECgYJBgAAAA==.',
['左弄']='左弄右弄:BAABLgAFFH8FAAICAAIJ3xN7JACnAAACAAIJ3xN7JACnAAAAAA==.',
['已关']='已关基:BAAALgAECgEJAQAAAA==.',
['布莱']='布莱恩铜:BAAALgADCgEJAQAAAA==.',
['希望']='希望的守护者:BAAALgAECgYJCwAAAA==.',
['干柴']='干柴猎火:BAAALgAECgMJAwAAAA==.',
['廈韎']='廈韎丶:BAAALgAECgMJAgAAAA==.',
['弑神']='弑神灭世:BAAALgADCgEJAQAAAA==.',
['弓箭']='弓箭手出列:BAAALgAECgQJBQAAAA==.',
['强手']='强手裂颅:BAAALgADCgYJBgAAAA==.',
['彼端']='彼端水月:BAAALgAECgcJBwAAAA==.',
['念之']='念之断人肠:BAAALgAFFAQJBAAAAA==.',
['怪怪']='怪怪點:BAAALgAFFAEJAgAAAA==.',
['总浪']='总浪总得瑟:BAAALgADCgEJAQAAAA==.',
['恒伊']='恒伊丶夜:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔丶之吻:BAAALgADCgEJAQAAAA==.恶魔小猎手:BAAALgAECgMJAwAAAA==.',
['戏丨']='戏丨子:BAAALgAECgYJDgAAAA==.',
['我太']='我太帅咯:BAAALgAECgEJAgAAAA==.',
['我是']='我是碧蓝高手:BAAALgADCgEJAQAAAA==.我是鸣潮高手:BAAALgAECgUJBQAAAA==.',
['戦无']='戦无雙:BAAALgAECgIJAgAAAA==.',
['托宾']='托宾贝尔:BAAALgAECgYJDAAAAA==.',
['执剑']='执剑者丨罗辑:BAAALgAECgYJBgAAAA==.',
['执笔']='执笔流年:BAAALgAECgUJCAAAAA==.',
['抹茶']='抹茶巧克力:BAAALgADCgEJAQAAAA==.',
['拉面']='拉面盒盒:BAAALgAFFAEJAQAAAA==.',
['指尖']='指尖有年华:BAAALgAECgUJBQAAAA==.',
['控雷']='控雷师:BAABLgAECn8VAAIBAAcJsxlrEgAUAQABAAcJsxlrEgAUAQAAAA==.',
['提里']='提里奥丶补丁:BAAALgAECgYJCQAAAA==.',
['揖哥']='揖哥:BAAALgAECgIJAgAAAA==.',
['救赎']='救赎丶法:BAAALgAECgUJCAABLgAFFAUJDgAVACsaAA==.',
['敖呜']='敖呜呜:BAABLgAFFH8MAAMWAAQJkxn4AwBZAQAWAAQJSxD4AwBZAQAUAAQJuBZ/DQBJAQAAAA==.',
['斯塔']='斯塔尔丶玻琳:BAAALgAECgQJBAAAAA==.',
['新晓']='新晓涛涛:BAAALgAECgEJAgAAAA==.',
['无敌']='无敌朵特:BAAALgAECgUJBQABLgAFFAIJAwAKAAAAAA==.',
['无毛']='无毛强:BAAALgADCgYJBgAAAA==.',
['时倾']='时倾:BAAALgAECgMJAwAAAA==.',
['时雨']='时雨城心:BAAALgAECgcJCQAAAA==.',
['明烛']='明烛天南:BAAALgAECgQJBAAAAA==.',
['星如']='星如雨:BAAALgAECgcJCAAAAA==.',
['星空']='星空叹息:BAAALgAECgYJBgAAAA==.',
['星辰']='星辰之赐:BAAALgAECgYJBgAAAA==.',
['晨星']='晨星:BAAALgAECgEJAQAAAA==.',
['景卿']='景卿癶:BAAALgAFFAEJAwAAAA==.',
['暗影']='暗影的疯狂:BAAALgAECgIJBAAAAA==.',
['曹阿']='曹阿瞒:BAAALgAECgYJDQAAAA==.',
['月下']='月下暗香残留:BAAALgAECgcJCQAAAA==.',
['月之']='月之羽:BAAALgAECgEJAQAAAA==.',
['有一']='有一个哈密瓜:BAABLgAFFH8GAAIRAAMJaBoUDAAnAQARAAMJaBoUDAAnAQAAAA==.有一屉小笼包:BAABLgAFFH8GAAIVAAQJCBJOBQAnAQAVAAQJCBJOBQAnAQAAAA==.有一筐红番茄:BAABLgAFFH8IAAIFAAQJag8xCwArAQAFAAQJag8xCwArAQAAAA==.',
['有德']='有德才有尸:BAAALgAFFAIJAwAAAA==.',
['有点']='有点坏坏:BAAALgAECgIJAgAAAA==.',
['朝朝']='朝朝暮暮:BAAALgAECgIJBAAAAA==.',
['木丨']='木丨偶:BAAALgAFFAIJAwAAAA==.',
['木丷']='木丷偶:BAAALgAECgEJAQAAAA==.',
['木油']='木油爪爪:BAAALgAECgYJCQAAAA==.',
['术有']='术有乾坤:BAAALgAECgYJBwAAAA==.',
['朵特']='朵特:BAAALgAFFAIJAwAAAA==.',
['机关']='机关枪图凸突:BAABLgAFFH8FAAIMAAMJtRAzEADnAAAMAAMJtRAzEADnAAAAAA==.',
['杀马']='杀马特萌萌:BAAALgAFFAIJBAAAAA==.',
['李木']='李木碗:BAAALgAECgIJAgAAAA==.',
['杨千']='杨千万:BAAALgADCgQJBAAAAA==.',
['杨永']='杨永信的电棒:BAAALgAFFAQJBAAAAA==.',
['杰斯']='杰斯贝莲:BAABLgAECn8UAAMDAAkJOhGnRgDZAQADAAcJLxSnRgDZAQAQAAUJjgkdPAAPAQAAAA==.',
['杰瑞']='杰瑞丶:BAAALgADCgIJAgABLgAFFAQJDgACAIUbAA==.',
['東志']='東志燚:BAAALgAECgYJBgAAAA==.',
['林殊']='林殊:BAAALgAFFAMJBAAAAA==.',
['果冻']='果冻儿灬耄:BAAALgAECgIJAgAAAA==.',
['枫落']='枫落:BAAALgAECgUJBQAAAA==.',
['枳花']='枳花丶驿影:BAAALgAECgUJBQABLgAFFAUJDwAXAFgVAA==.',
['栎羽']='栎羽万:BAAALgADCgcJCgABLgAECgMJAgAKAAAAAA==.',
['梦丷']='梦丷魇:BAAALgADCgUJBQAAAA==.',
['梦游']='梦游僧:BAABLgAFFH8FAAIJAAIJNx5XFwC2AAAJAAIJNx5XFwC2AAAAAA==.梦游术:BAAALgAECgYJDAABLgAFFAIJBQAJADceAA==.',
['梦魂']='梦魂:BAAALgADCgUJBQAAAA==.',
['棒棒']='棒棒冰:BAABLgAFFH8GAAIJAAIJZBj3DgCdAAAJAAIJZBj3DgCdAAAAAA==.',
['椒麻']='椒麻麦乐鸡:BAAALgADCgUJBQAAAA==.',
['橘雪']='橘雪莉:BAAALgAFFAQJBAAAAA==.',
['櫻花']='櫻花色的夢:BAAALgAECgYJBwAAAA==.',
['正北']='正北偏南:BAAALgAECgMJAwAAAA==.',
['正当']='正当防卫:BAAALgAECgcJBwAAAA==.',
['此人']='此人為險:BAAALgADCgIJAgAAAA==.',
['此生']='此生孤独:BAAALgAECgYJCgAAAA==.',
['武月']='武月丨星辰:BAABLgAFFH8FAAIYAAMJmA+PBAD2AAAYAAMJmA+PBAD2AAABLgAFFAUJBQAVACMXAA==.',
['死亡']='死亡笔記灬:BAAALgADCgYJBgAAAA==.',
['殇之']='殇之:BAAALgAFFAIJAwABLgAFFAMJCAALAOElAA==.殇之丶:BAABLgAFFH8IAAILAAMJ4SUAFQBPAQALAAMJ4SUAFQBPAQAAAA==.',
['毁灭']='毁灭吧:BAAALgAECgMJBAAAAA==.',
['毛毛']='毛毛:BAAALgAECgEJAQAAAA==.',
['水星']='水星三号:BAAALgAFFAEJAQAAAA==.水星二号:BAAALgAFFAQJBAAAAA==.水星八号:BAAALgAFFAQJBAAAAA==.水星四号:BAAALgAECgcJCgAAAA==.水星魔女:BAABLgAFFH8IAAIMAAUJKxBPBACNAQAMAAUJKxBPBACNAQAAAA==.',
['汉娜']='汉娜韦尔:BAAALgADCgYJCgAAAA==.',
['沈童']='沈童五号:BAAALgAFFAEJAQAAAA==.',
['沈青']='沈青山:BAAALgAECgYJCwAAAA==.',
['沉霜']='沉霜:BAABLgAECn8VAAICAAcJ4x74PQCAAgACAAcJ4x74PQCAAgAAAA==.',
['沉默']='沉默是黑夜:BAAALgADCgEJAQAAAA==.',
['沐玥']='沐玥多人:BAAALgAECgEJAgAAAA==.',
['沐辰']='沐辰:BAABLgAFFH8HAAICAAQJjwQTIgA2AQACAAQJjwQTIgA2AQAAAA==.',
['沐陽']='沐陽:BAAALgAECgcJCQAAAA==.',
['没事']='没事丶我硬抗:BAAALgADCgUJBQAAAA==.',
['法克']='法克艾瑞巴迪:BAAALgADCgEJAQAAAA==.',
['法莽']='法莽:BAAALgAECgYJBwAAAA==.',
['泡泡']='泡泡珑:BAAALgAECgUJBQAAAA==.泡泡瞎:BAAALgAECgYJBgAAAA==.泡泡骑:BAAALgAFFAEJAgAAAA==.',
['泰奶']='泰奶奶水果:BAAALgAECgEJAQAAAA==.',
['泷羽']='泷羽:BAAALgAECgYJBgAAAA==.',
['洛希']='洛希极限:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪剑客:BAAALgAECgYJBwAAAA==.',
['浅丨']='浅丨伤:BAAALgAECgMJAwAAAA==.',
['浅丷']='浅丷伤:BAAALgAECgYJDgAAAA==.',
['浦和']='浦和花子:BAAALgADCgEJAQAAAA==.',
['浦江']='浦江睿睿哥:BAAALgAECgMJBwAAAA==.',
['浪灬']='浪灬:BAAALgAECgQJBgAAAA==.',
['浪里']='浪里小笼包:BAAALgADCgQJAwAAAA==.',
['浮華']='浮華丶夯:BAAALgAECgMJAwAAAA==.浮華丶書:BAAALgADCgQJBAAAAA==.',
['淘灬']='淘灬气:BAAALgAECgkJCQABLgAFFAEJAQAKAAAAAA==.',
['深白']='深白色丶:BAAALgAECgEJAQAAAA==.',
['深蓝']='深蓝色:BAAALgAECgYJCAAAAA==.',
['渺渺']='渺渺兮予怀丶:BAAALgADCgMJAwAAAA==.',
['湛灬']='湛灬蓝:BAAALgAECgEJAQAAAA==.',
['滄海']='滄海:BAAALgAECgUJCAABLgAFFAQJCwACAM4eAA==.',
['满天']='满天星:BAAALgAECgIJAgABLgAECgcJGgARAPIPAA==.',
['潜龙']='潜龙腾渊:BAAALgAECgYJCwAAAA==.',
['灬乌']='灬乌拉灬:BAAALgAFFAQJBAAAAA==.',
['灬冲']='灬冲鸭灬:BAAALgAECgUJBQAAAA==.',
['灬呜']='灬呜呜灬:BAABLgAFFH8HAAMZAAQJgBQWAQBDAQAZAAQJzQoWAQBDAQALAAIJth/SMQDCAAAAAA==.',
['灬啵']='灬啵啵鸭灬:BAAALgAFFAIJAgABLgAFFAUJEwANAF0TAA==.',
['灬枫']='灬枫落灬:BAAALgAFFAEJAgAAAA==.',
['灬枭']='灬枭灬:BAABLgAFFH8FAAIaAAQJ6g+xCABhAQAaAAQJ6g+xCABhAQAAAA==.',
['灬深']='灬深海灬:BAAALgAECggJBAAAAA==.',
['灬温']='灬温柔灬:BAACLgAFFH8GAAMFAAMJKxVpCwDRAAAFAAMJKxVpCwDRAAAOAAEJShBEGgBOAAAuAAQKfxUAAwUABwnSHM4jACwCAAUABgmTIM4jACwCAA4ABwlLHQofAAcCAAAA.',
['灬辣']='灬辣辣灬:BAABLgAFFH8LAAIDAAUJXSSHAwAAAgADAAUJXSSHAwAAAgAAAA==.',
['灬阿']='灬阿德灬:BAAALgADCgQJBAAAAA==.',
['灰烬']='灰烬的澳:BAAALgADCgMJAwAAAA==.',
['灵之']='灵之守卫:BAAALgAECgEJAgAAAA==.',
['灵动']='灵动小风:BAAALgAECgEJAQAAAA==.',
['灼热']='灼热轰炸:BAAALgAECgMJAwAAAA==.',
['炫舞']='炫舞非影:BAABLgAECn8UAAINAAgJtAx3EABiAQANAAgJtAx3EABiAQAAAA==.',
['無悪']='無悪卜唑灬訫:BAAALgAECgIJBAAAAA==.',
['熊熊']='熊熊奶团子:BAACLgAFFH8NAAMJAAQJIx5/BQB8AQAJAAQJIx5/BQB8AQAVAAEJ6AQgFgBJAAAuAAQKfyIAAgkABwnwJQoIAAUDAAkABwnwJQoIAAUDAAAA.',
['熊猫']='熊猫不丑:BAABLgAFFH8IAAMYAAMJqAzMCADpAAAYAAMJqAzMCADpAAAJAAEJ5QEsKAA4AAAAAA==.',
['爆乱']='爆乱:BAAALgAFFAIJAwAAAA==.',
['爱星']='爱星爵爷:BAABLgAFFH8GAAIBAAMJuhSODwD4AAABAAMJuhSODwD4AAAAAA==.',
['片刻']='片刻永恆:BAAALgAECgYJCAAAAA==.',
['牛德']='牛德华:BAAALgAECgcJDQAAAA==.',
['牛牛']='牛牛扭扭忸忸:BAAALgADCgEJAQAAAA==.',
['牛霸']='牛霸霸:BAABLgAECn8WAAIFAAcJMB9/GwBgAgAFAAcJMB9/GwBgAgAAAA==.',
['牜亽']='牜亽篮板球:BAAALgAFFAIJBAAAAA==.',
['牧濑']='牧濑红莉栖:BAAALgAECgEJAQAAAA==.',
['物法']='物法皆修:BAAALgAECgkJCQAAAA==.',
['犀利']='犀利爺:BAABLgAFFH8FAAIHAAMJ0RFOFQD/AAAHAAMJ0RFOFQD/AAAAAA==.',
['犀鸟']='犀鸟:BAACLgAFFH8FAAIHAAIJVha5IwClAAAHAAIJVha5IwClAAAuAAQKfxYAAwcABwmoH4gsAHECAAcABwmoH4gsAHECAA0AAgl3CtaIAFgAAAAA.',
['狂暴']='狂暴小清新:BAAALgAECgUJCQAAAA==.狂暴巍少:BAAALgAFFAIJBAAAAA==.',
['狼王']='狼王丶:BAAALgAECgQJBQAAAA==.',
['猫不']='猫不易:BAAALgAECgEJAwAAAA==.',
['玄烛']='玄烛:BAAALgADCgEJAQAAAA==.',
['玉猎']='玉猎一:BAAALgAECgUJCAAAAA==.玉猎三:BAAALgAECgYJBgAAAA==.玉猎二:BAAALgAECgYJBgAAAA==.',
['王丽']='王丽坤丶:BAAALgAECgIJAgAAAA==.',
['王技']='王技师:BAAALgAECgMJAwAAAA==.',
['王斯']='王斯拉夫:BAAALgAECgkJAgAAAA==.',
['玛卡']='玛卡个巴子:BAAALgAECgQJBwAAAA==.',
['玛琪']='玛琪玛万圣节:BAABLgAFFH8FAAICAAMJcw7oGAD6AAACAAMJcw7oGAD6AAAAAA==.',
['球球']='球球丶:BAAALgAECgYJBgAAAA==.',
['瓦王']='瓦王:BAAALgAECgQJBQAAAA==.',
['生民']='生民百遗一:BAAALgAFFAYJBAAAAA==.',
['电子']='电子龙:BAAALgADCgUJBQAAAA==.',
['电男']='电男:BAACLgAFFH8FAAMMAAIJ4gWSGwCLAAAMAAIJ4gWSGwCLAAABAAIJqwKMDgB/AAAuAAQKfxcAAwwABwl5DaJEAG8BAAwABwl5DaJEAG8BAAEABQlkF+g8AFgBAAAA.',
['电眼']='电眼萌狐:BAAALgAECggJCAAAAA==.',
['白头']='白头山天降者:BAAALgADCgUJBQAAAA==.',
['白狐']='白狐儿脸:BAAALgADCgEJAQAAAA==.',
['白骨']='白骨露于野:BAAALgAFFAcJBAAAAA==.',
['白鸟']='白鸟咲:BAAALgAECgcJCAAAAA==.',
['百奇']='百奇:BAAALgAECggJCwAAAA==.',
['百炼']='百炼嘉维尔:BAAALgADCgEJAQAAAA==.',
['百里']='百里登峰:BAAALgADCggJCAAAAA==.',
['的话']='的话:BAAALgAECgYJBgAAAA==.',
['皆尽']='皆尽:BAAALgAECgYJBgAAAA==.',
['皮尔']='皮尔卡松:BAAALgADCgEJAQAAAA==.',
['盛夏']='盛夏丶光年:BAAALgAECgYJCAAAAA==.',
['看不']='看不见旳星星:BAAALgAFFAEJAgAAAA==.',
['看到']='看到了哈:BAAALgAECgEJAgAAAA==.',
['真的']='真的是泥鸭:BAAALgAECgYJBwAAAA==.',
['石之']='石之自由:BAAALgAECgEJAQAAAA==.',
['碎痕']='碎痕:BAABLgAFFH8FAAITAAUJvAotBAA/AQATAAUJvAotBAA/AQAAAA==.',
['祖师']='祖师爷吴彦祖:BAAALgAECgQJBAAAAA==.',
['秋叶']='秋叶离:BAAALgAECgEJAQAAAA==.',
['秋裤']='秋裤:BAAALgAECgIJAgABLgAFFAYJCwACAMUbAA==.',
['种族']='种族骑士:BAAALgADCgcJBwAAAA==.',
['科瑞']='科瑞姆邱瑞秋:BAAALgADCgcJBwAAAA==.',
['空灵']='空灵尘:BAAALgAECgQJBAAAAA==.',
['空空']='空空德:BAAALgAECgYJCQAAAA==.',
['索亚']='索亚:BAAALgADCgEJAQAAAA==.',
['紫呈']='紫呈:BAAALgAFFAEJAQAAAA==.',
['紫色']='紫色罗兰:BAAALgAECgEJAQAAAA==.',
['线劣']='线劣自己扛:BAAALgAECgYJDwAAAA==.',
['绅士']='绅士的肥皂:BAAALgAFFAEJAQAAAA==.',
['给我']='给我一双翅膀:BAAALgADCgEJAQABLgAFFAQJBAAKAAAAAA==.',
['绯红']='绯红女巫:BAAALgAECgkJDwAAAA==.',
['绿火']='绿火的加特林:BAAALgAECgEJAQAAAA==.',
['美酒']='美酒:BAAALgAECgYJCAAAAA==.',
['美髯']='美髯公:BAAALgAECgYJEAAAAA==.',
['羽墨']='羽墨:BAAALgAECgMJAgAAAA==.',
['翡翠']='翡翠梦灬魇:BAAALgAECgYJDAAAAA==.',
['翻滾']='翻滾丷牜宝宝:BAAALgAECgIJAwAAAA==.',
['聖光']='聖光丶之翼:BAAALgAECgEJAQAAAA==.',
['聽雨']='聽雨遇蜓:BAAALgAECgcJCQAAAA==.',
['能上']='能上能下:BAAALgADCgcJBwAAAA==.',
['能拽']='能拽会罩丶乐:BAAALgAECgYJBgAAAA==.',
['腐化']='腐化之种:BAAALgAECgMJAwAAAA==.',
['自由']='自由人:BAAALgAECgEJAQAAAA==.',
['臭臭']='臭臭狐:BAAALgAFFAEJAgAAAA==.',
['芊芊']='芊芊草:BAAALgAECgMJCQAAAA==.',
['花子']='花子弎:BAAALgAECgkJCQAAAA==.',
['花花']='花花啊花花:BAAALgADCgUJBQAAAA==.',
['花開']='花開柒月:BAAALgADCgYJCwAAAA==.',
['苦丁']='苦丁:BAABLgAECn8YAAIbAAcJeh3QAgBBAgAbAAcJeh3QAgBBAgAAAA==.',
['范布']='范布鲁克:BAAALgAECgYJCwAAAA==.',
['茶与']='茶与清酒:BAABLgAFFH8IAAIFAAQJTBXeCABFAQAFAAQJTBXeCABFAQAAAA==.',
['荼白']='荼白:BAAALgAFFAIJAgAAAA==.',
['莫尔']='莫尔诺:BAAALgADCgUJBQAAAA==.',
['莫拉']='莫拉丝:BAABLgAFFH8IAAIEAAMJ9QfqJQDpAAAEAAMJ9QfqJQDpAAAAAA==.',
['萌大']='萌大眼儿:BAAALgADCgMJAwAAAA==.',
['萌萌']='萌萌老师:BAABLgAFFH8GAAMYAAMJrAnXDQCUAAAYAAIJMQ3XDQCUAAAJAAEJoAJiGABEAAAAAA==.',
['萨瑟']='萨瑟菲:BAAALgAECgYJCQAAAA==.',
['萨那']='萨那芳華:BAAALgAECgkJCQAAAA==.',
['落雪']='落雪哥:BAACLgAFFH8GAAIcAAMJ4hKuDgDjAAAcAAMJ4hKuDgDjAAAuAAQKfxYABBwABgmaHQMbAL8BABwABgmaHQMbAL8BAB0ABglICR1JABQBAAgAAQlsF4ZbAEcAAAAA.',
['落魄']='落魄七尺汉:BAAALgAFFAMJAwAAAA==.',
['蒸蚌']='蒸蚌丷:BAAALgADCgYJBgAAAA==.',
['藏众']='藏众生:BAAALgAECgYJBgAAAA==.',
['虚空']='虚空的守护者:BAABLgAECn8ZAAIIAAgJmR3fDAC1AgAIAAgJmR3fDAC1AgAAAA==.',
['蛋形']='蛋形好事:BAAALgAECgIJAgAAAA==.',
['血之']='血之帝王:BAAALgADCgEJAQAAAA==.',
['血小']='血小板:BAAALgAECgkJDwAAAA==.',
['血山']='血山黑狐:BAAALgAECgYJBgAAAA==.',
['血影']='血影舞者:BAAALgAECgcJBwAAAA==.',
['血流']='血流之箭:BAAALgAECgYJEgAAAA==.',
['西班']='西班牙丶小黑:BAAALgADCgEJAQAAAA==.西班牙丶梅西:BAAALgAECgUJCQAAAA==.',
['西瓜']='西瓜碎碎冰:BAABLgAECn8bAAIHAAcJVhlNXwDGAQAHAAcJVRlNXwDGAQAAAA==.',
['西门']='西门止水:BAAALgAECgUJCAAAAA==.',
['要下']='要下雨了:BAAALgADCgQJBAAAAA==.',
['觊觎']='觊觎:BAAALgADCgYJBgAAAA==.',
['誰傢']='誰傢那尐誰:BAAALgAFFAEJAQABLgAFFAIJBQAHACoWAA==.',
['诶嘿']='诶嘿:BAAALgADCgYJBgAAAA==.',
['谁组']='谁组的小德:BAAALgAECgEJAQAAAA==.',
['豆奶']='豆奶:BAAALgAECgEJAQAAAA==.',
['豆汁']='豆汁焦圈:BAAALgADCgIJAgAAAA==.',
['豐川']='豐川祥子:BAAALgAECgEJAQABLgAFFAcJBQATALwKAA==.',
['赤鸦']='赤鸦裂空破:BAAALgAECgEJBAAAAA==.',
['走路']='走路摇不摇:BAAALgAECgEJAQAAAA==.',
['躁血']='躁血骑士:BAAALgAECgQJBAAAAA==.',
['轉身']='轉身丿黃粱驚:BAACLgAFFH8FAAMGAAMJkAH9DQC2AAAGAAMJkAH9DQC2AAARAAIJqBCWEgCYAAAuAAQKfxYABBEACAmmFT4QADcCABEACAmmFT4QADcCAAYAAQmtBwEpADMAAB4AAQkAAKANAAAAAAAA.轉身丿黯明月:BAAALgAECgYJDgABLgAFFAMJBQAGAJABAA==.',
['辣鸡']='辣鸡略人:BAAALgAECgEJBAAAAA==.',
['过江']='过江:BAAALgAECgEJAQAAAA==.',
['迈克']='迈克尔奶德:BAAALgAECgIJAgAAAA==.',
['这河']='这河狸吗:BAAALgAECgMJAwAAAA==.',
['这缺']='这缺德吗:BAAALgAFFAEJAQAAAA==.',
['逆风']='逆风整一身:BAAALgAECgYJCAAAAA==.',
['逍遥']='逍遥小狐仙:BAAALgAECgIJAwAAAA==.',
['道丽']='道丽小呲话:BAAALgAECgEJAQAAAA==.',
['道莉']='道莉大呲花:BAAALgAECgEJAQAAAA==.道莉大茈花:BAAALgAECgEJAwAAAA==.',
['道道']='道道六号:BAAALgAECgkJBwAAAA==.',
['酒吥']='酒吥醉人:BAAALgAECgIJAwAAAA==.',
['醉酒']='醉酒的武僧:BAAALgAECgQJBAAAAA==.',
['重逢']='重逢:BAAALgAECgMJBAAAAA==.',
['金属']='金属控:BAAALgAECgMJAwAAAA==.',
['銎鍂']='銎鍂归来:BAAALgAECgYJCAAAAA==.',
['鍋子']='鍋子里:BAAALgAECgQJBAAAAA==.',
['银色']='银色战车:BAAALgAECgcJBwAAAA==.',
['长路']='长路慢慢:BAAALgAECgYJDwAAAA==.',
['關关']='關关风月:BAAALgAFFAEJAQAAAA==.',
['闪电']='闪电狐:BAAALgAECgEJAQAAAA==.',
['阡陌']='阡陌笑:BAAALgAECgQJBQABLgAFFAUJDwARAKMcAA==.',
['阿斯']='阿斯代伦:BAAALgAECgYJBwAAAA==.',
['阿蒂']='阿蒂拉:BAAALgAECgEJAQAAAA==.',
['阿鼠']='阿鼠:BAAALgAECgUJBQAAAA==.',
['陆小']='陆小七:BAAALgAECgYJBgAAAA==.',
['隐藏']='隐藏姿势:BAAALgAFFAEJAQAAAA==.',
['雄鹰']='雄鹰的王叔:BAAALgAECgEJAwAAAA==.',
['雨下']='雨下一个月:BAAALgAECgYJBgAAAA==.',
['雪落']='雪落凝霜:BAAALgAECgkJDgAAAA==.',
['雪饼']='雪饼泡芙:BAAALgAECgcJCwAAAA==.',
['雷电']='雷电芽衣:BAAALgAFFAIJBAAAAA==.',
['雷鸣']='雷鸣忘川丶:BAAALgAECgEJAgAAAA==.',
['霜炎']='霜炎之夕:BAAALgADCgcJCAAAAA==.',
['霹雳']='霹雳惊弦:BAAALgADCgYJAQAAAA==.',
['青云']='青云桥伦巴王:BAAALgAECgYJCwABLgAFFAcJFQALABEcAA==.',
['青色']='青色回忆:BAAALgAECggJAQAAAA==.',
['靓龙']='靓龙:BAAALgAECgEJAQAAAA==.',
['颜瑟']='颜瑟:BAAALgADCgEJAQAAAA==.',
['颠鸾']='颠鸾倒凤:BAACLgAFFH8IAAIEAAYJXxulCgCHAQAEAAYJXxulCgCHAQAuAAQKfxQAAx8ABwlPHFAFABcCAB8ABwkVGlAFABcCAAQABwnjFSNmAJkBAAAA.',
['風風']='風風月:BAAALgAFFAEJAQABLgAFFAEJAQAKAAAAAA==.',
['风之']='风之自由:BAAALgAECgEJAgAAAA==.',
['风吹']='风吹半夏:BAAALgAECgQJBAAAAA==.',
['风还']='风还在吹:BAAALgADCgUJBQAAAA==.',
['风靡']='风靡万千少男:BAAALgAFFAQJBAABLgAFFAcJEQALAEEYAA==.',
['飞天']='飞天大砍刀:BAAALgADCgMJAwAAAA==.',
['飞失']='飞失连心:BAABLgAFFH8GAAIUAAQJQRyZCwBgAQAUAAQJQRyZCwBgAQAAAA==.',
['骑丶']='骑丶小鹿:BAAALgAECgYJCwAAAA==.',
['鬼萌']='鬼萌关:BAAALgAECgUJCQAAAA==.',
['魔女']='魔女迷灵:BAAALgAECgYJCwAAAA==.',
['魔神']='魔神:BAAALgAECgcJDwAAAA==.',
['鯨泪']='鯨泪:BAAALgAECgYJDAABLgAECgcJDgAKAAAAAA==.',
['鲨鱼']='鲨鱼僧:BAAALgAFFAEJAgAAAA==.鲨鱼德:BAAALgAECgYJBgABLgAFFAEJAgAKAAAAAA==.鲨鱼术:BAAALgAECgMJAwABLgAFFAEJAgAKAAAAAA==.',
['黏树']='黏树猴:BAAALgAECgQJBgAAAA==.',
['黑汤']='黑汤圆:BAAALgAECgYJCAAAAA==.',
['黑焱']='黑焱凋零:BAAALgADCgQJBAAAAA==.',
['黑腿']='黑腿欧巴:BAAALgAFFAIJBAAAAA==.',
['龙鳞']='龙鳞胸甲五铜:BAACLgAFFH8IAAIEAAMJDg3pIgD4AAAEAAMJDg3pIgD4AAAuAAQKfxUABAQACAnpHetLAOUBAAQABwkMGutLAOUBABcAAglVH6I/ALYAAB8AAQkAAAYfAHgAAAEuAAUUBQkSABEAyCEA.',
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
