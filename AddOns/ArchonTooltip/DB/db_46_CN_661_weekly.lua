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

local lookup = {'Warrior-Protection','Unknown-Unknown','Druid-Feral','Druid-Balance','Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Monk-Windwalker','Paladin-Retribution','Warlock-Demonology','Shaman-Elemental','DemonHunter-Devourer','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','DeathKnight-Unholy','DeathKnight-Blood','Priest-Discipline','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Warlock-Destruction','Monk-Brewmaster','Druid-Restoration','Hunter-Survival','Priest-Shadow','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Arms','Shaman-Restoration','Shaman-Enhancement','Paladin-Holy','Paladin-Protection','Warrior-Fury','Warlock-Affliction','Monk-Mistweaver','Druid-Guardian',}
local provider = {region='CN',realm='巨龙之吼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alason:BAAALgAECgkJDwAAAA==.Alchmist:BAAALgADCgcJDQAAAA==.Alchmists:BAAALgADCgEJAQAAAA==.Alt:BAAALgAECgYJCAAAAA==.',
An='Antony:BAAALgAECgYJBgAAAA==.',
Ar='Arcanelion:BAAALgAECgYJBgAAAA==.',
At='Ataraxia:BAABLgAFFH8IAAIBAAQJtRqqAwBRAQABAAQJtRqqAwBRAQABLgAFFAQJBAACAAAAAA==.',
Ba='Bast:BAACLgAFFH8OAAIDAAQJ5x2OAABjAQADAAQJ5x2OAABjAQAuAAQKfxUAAwMABwkBJZ0EAM8CAAMABwkBJZ0EAM8CAAQAAQkAAJKIACcAAAAA.',
Be='Begierde:BAAALgAECgYJCgAAAA==.Behati:BAAALgAECgEJAgAAAA==.',
Bl='Blinkfeather:BAAALgAECgcJBwAAAA==.Bllazer:BAAALgAECgYJEQAAAA==.',
Ca='Cakethread:BAAALgAFFAIJBAAAAA==.',
Ch='Cherryred:BAABLgAFFH8FAAIFAAIJHR+xBAC8AAAFAAIJHR+xBAC8AAAAAA==.',
Cm='Cmxdh:BAAALgAECgkJCQAAAA==.',
Co='Coupa:BAABLgAECn8YAAMGAAgJmhjsHAA9AgAGAAgJWxjsHAA9AgAHAAEJUg+YvQBIAAAAAA==.',
Da='Darkdraon:BAAALgAFFAEJAQAAAA==.',
Db='Dbsekbada:BAAALgAECgUJBwAAAA==.',
De='Deimos:BAAALgAECgYJCAAAAA==.Despairred:BAAALgAECgEJAQAAAA==.',
Dh='Dhfly:BAAALgAECgYJBwAAAA==.',
Di='Dicck:BAAALgAFFAIJAgAAAA==.',
Ed='Edifier:BAAALgAECgYJBwAAAA==.',
Em='Emxdh:BAAALgAFFAQJAwAAAA==.',
En='Endless:BAAALgAECgQJBAAAAA==.Endness:BAAALgAECgYJDAAAAA==.',
Et='Eternia:BAABLgAECn8bAAIBAAcJtBL+BgApAQABAAcJtBL+BgApAQAAAA==.',
Ex='Explain:BAAALgADCgQJBAAAAA==.',
Fu='Futurehunter:BAAALgAECgUJBgAAAA==.',
Ge='Gevil:BAAALgAECgMJBQAAAA==.',
Gg='Ggstudy:BAAALgAECgQJBAAAAA==.',
Gi='Gisu:BAAALgAECgcJEQAAAA==.',
Gr='Grod:BAAALgAECgQJBAAAAA==.',
Ha='Hance:BAAALgAFFAEJAwAAAA==.',
In='Incineration:BAACLgAFFH8WAAIIAAYJayRcAAAfAgAIAAYJayRcAAAfAgAuAAQKfxsAAggACAnAJNwRADwDAAgACAnAJNwRADwDAAAA.',
Ja='Jakiro:BAAALgAECgQJBAAAAA==.',
Jj='Jjlinn:BAAALgAECgcJCgAAAA==.',
Ju='Jund:BAAALgAFFAUJAQAAAA==.',
Ki='Kid:BAAALgAECgYJBgAAAA==.',
Ko='Koris:BAAALgAECgIJAgABLgAECgYJCgACAAAAAA==.',
La='Lafayette:BAABLgAECn8aAAIJAAgJ9RZ5GQAVAgAJAAgJ9RZ5GQAVAgAAAA==.Lajidkbiewan:BAAALgAECgYJCgAAAA==.Laopang:BAAALgAECgMJAwAAAA==.',
Le='Legende:BAAALgAFFAIJAgAAAA==.',
Li='Lifengzs:BAAALgAFFAQJBAAAAA==.',
Me='Mepheisto:BAAALgAECgQJBAAAAA==.',
Mi='Milani:BAAALgAECgYJDQAAAA==.Milks:BAAALgAECgQJBwAAAA==.',
Ml='Mliongtx:BAAALgAFFAIJAgAAAA==.',
My='Mywizard:BAAALgAECgEJAgAAAA==.',
Ne='Neymarjr:BAAALgAECgEJAQAAAA==.',
Ni='Nightingle:BAAALgADCgUJBQAAAA==.',
Nu='Num:BAAALgADCgUJBQAAAA==.',
Pa='Patagonia:BAAALgAECgcJBwAAAA==.',
Pi='Pikeercheng:BAAALgAECgcJDAAAAA==.Pinkss:BAAALgAECgQJBwAAAA==.',
Pl='Playersvhcqv:BAABLgAECn8WAAIKAAgJ/B8uGwDGAgAKAAgJ/B8uGwDGAgAAAA==.Playeryzxvlz:BAAALgAECgQJBwAAAA==.',
Pr='Prtsc:BAAALgAECgQJBwAAAA==.',
Qu='Quasimoodo:BAAALgADCgYJBgAAAA==.',
Re='Reddawn:BAAALgAECgMJAQABLgAFFAMJBwALAE0aAA==.',
Ri='Riceflour:BAAALgAFFAMJAwAAAA==.Ricenoodless:BAABLgAFFH8HAAIMAAMJbh2uDQASAQAMAAMJbh2uDQASAQAAAA==.Rikki:BAAALgAFFAQJBAAAAA==.',
Ro='Robberman:BAAALgAECgcJCAABLgAFFAUJBAACAAAAAA==.',
Se='Servant:BAAALgAFFAEJAQAAAA==.',
Sh='Sherrypearl:BAAALgAECgQJBAAAAA==.Shreey:BAABLgAECn8aAAIIAAcJnQ3/KAApAQAIAAcJnQ3/KAApAQAAAA==.',
St='Steamedbun:BAABLgAFFH8LAAINAAUJ+xxSBwCvAQANAAUJ+xxSBwCvAQAAAA==.',
Te='Terrorbalde:BAABLgAFFH8IAAILAAIJmRobMQCwAAALAAIJmRobMQCwAAAAAA==.',
Th='Thj:BAAALgAECgMJBQAAAA==.',
To='Tokyohot:BAAALgADCgUJBQAAAA==.',
Tw='Twistzz:BAAALgAECgQJCAAAAA==.',
Un='Unogel:BAAALgAECgQJBQAAAA==.',
Ya='Yansheni:BAAALgAECgYJDgAAAA==.',
Yh='Yhang:BAAALgADCgEJAQAAAA==.',
Yz='Yzd:BAABLgAECn8XAAIOAAcJTR0nGwAnAgAOAAcJTR0nGwAnAgAAAA==.',
Za='Zagreos:BAACLgAFFH8TAAQOAAUJoyBiAQD6AQAOAAUJoyBiAQD6AQAPAAEJ8BKmBQBhAAAQAAEJiAMyAgBNAAAuAAQKfxcAAw4ACAkyJAsFAEQDAA4ACAkyJAsFAEQDAA8AAQlZG3EaAFQAAAAA.Zagreus:BAAALgADCgMJAwAAAA==.',
Zp='Zpecial:BAAALgAECgQJBQAAAA==.',
['一匹']='一匹老野马:BAAALgAECgYJBwAAAA==.',
['一只']='一只菠萝包:BAAALgAECgYJBgAAAA==.',
['一城']='一城烟沙:BAAALgAECgIJAgAAAA==.',
['一梵']='一梵天一:BAAALgAFFAIJAgAAAA==.',
['一段']='一段插曲:BAACLgAFFH8RAAMRAAUJfxc9GABEAQARAAQJfxc9GABEAQASAAMJ0gYCDAC4AAAuAAQKfyQAAhEACAmTI5QQABkDABEACAmTI5QQABkDAAAA.',
['一矛']='一矛入体丶:BAAALgAFFAEJAgAAAA==.',
['七爿']='七爿旪子:BAAALgAECgEJAQAAAA==.',
['万松']='万松:BAAALgAECgEJAQAAAA==.',
['万物']='万物皆虚:BAAALgAECgYJBwAAAA==.',
['三分']='三分醉:BAAALgADCgYJBgAAAA==.',
['三块']='三块腹肌:BAAALgAECgIJAgAAAA==.',
['不大']='不大的柿子:BAAALgADCgEJAQAAAA==.',
['专业']='专业刮痧:BAAALgAECgYJBwAAAA==.',
['丘永']='丘永远忠鱼:BAAALgADCgYJBgAAAA==.',
['东那']='东那个东:BAABLgAFFH8IAAIEAAIJ2x2fBwC7AAAEAAIJ2x2fBwC7AAAAAA==.',
['丨刘']='丨刘亦菲丨:BAAALgAECgEJBAAAAA==.',
['丨宋']='丨宋雨琦丨:BAAALgAECgYJCQAAAA==.',
['丨微']='丨微笑:BAAALgADCgEJAQAAAA==.',
['丨慕']='丨慕山溪丨:BAAALgAECgQJBAAAAA==.',
['丨紫']='丨紫丶惊寂灬:BAAALgAECgEJAQAAAA==.',
['丨蝶']='丨蝶恋丨樱花:BAAALgADCgMJBAAAAA==.',
['中二']='中二病欢乐多:BAAALgAECgEJAQAAAA==.',
['丰川']='丰川祥子:BAAALgADCgIJAgAAAA==.',
['丶果']='丶果汁要咖冰:BAABLgAECn8dAAMHAAgJ4B4FEQCxAgAHAAcJNR8FEQCxAgAGAAYJ7yLfHwAjAgAAAA==.',
['丶枫']='丶枫丶:BAAALgAECgQJBAAAAA==.',
['丶源']='丶源:BAABLgAECn8WAAINAAcJhCDIIwB7AgANAAcJhCDIIwB7AgAAAA==.',
['丶虎']='丶虎斑牛牛:BAAALgAFFAQJAwAAAA==.',
['丶那']='丶那彩虹很美:BAAALgAECgQJBgAAAA==.',
['丶风']='丶风见幽香:BAAALgADCgcJBwAAAA==.',
['丷微']='丷微笑丷:BAAALgAECgYJBgAAAA==.',
['丷臧']='丷臧老师丷:BAAALgAECgYJCgAAAA==.',
['丷酒']='丷酒仙阿路丷:BAAALgAECgIJAgAAAA==.',
['举起']='举起手來:BAAALgAECgQJBAAAAA==.',
['丿烽']='丿烽火戏佳人:BAAALgAECgEJAQAAAA==.',
['乄微']='乄微笑:BAAALgAECgEJAQAAAA==.',
['九成']='九成宫:BAAALgAFFAIJBAAAAA==.',
['九拉']='九拉丁:BAAALgAECgYJCQAAAA==.',
['九溪']='九溪烟树:BAAALgAFFAIJBAAAAA==.',
['二一']='二一一二:BAAALgAECgcJBwAAAA==.',
['二乃']='二乃:BAABLgAECn8UAAMTAAcJmB90CwCAAgATAAcJmB90CwCAAgAFAAQJ9BqhTAAGAQAAAA==.',
['二马']='二马子:BAAALgAECgEJAQAAAA==.',
['云去']='云去山如画:BAAALgAECgIJAgAAAA==.',
['云酉']='云酉生:BAAALgADCgMJAwAAAA==.',
['五品']='五品带棍侍卫:BAAALgAECgUJBQAAAA==.',
['亦暮']='亦暮暮:BAAALgAECgYJCAAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgkJDQAAAA==.',
['人无']='人无再少年:BAAALgAECgMJAwAAAA==.',
['人波']='人波切:BAAALgAECgYJCgAAAA==.',
['人生']='人生若梦:BAAALgAECgUJAQAAAA==.',
['人间']='人间大炮:BAAALgAECgEJAgAAAA==.',
['今天']='今天星期天:BAAALgAECgMJAwAAAA==.',
['今晚']='今晚打麻将:BAAALgAECgEJAQAAAA==.',
['今村']='今村美惠丶:BAAALgAECgYJCAAAAA==.',
['仍可']='仍可可:BAACLgAFFH8RAAIUAAYJIh4JAgA1AgAUAAYJIh4JAgA1AgAuAAQKfx0AAxQACAn6JIwDAGMDABQACAn6JIwDAGMDABUABQlCFoocAEsBAAAA.',
['仙人']='仙人掌:BAAALgAECgYJCQAAAA==.',
['代理']='代理屍神:BAAALgAECgEJAQAAAA==.',
['伊丽']='伊丽娜:BAAALgADCgUJBQAAAA==.',
['伊俄']='伊俄:BAAALgADCgcJBwAAAA==.',
['伊利']='伊利达雷丶叶:BAAALgAECgMJAwAAAA==.',
['伊诺']='伊诺:BAAALgAECgYJCQABLgAECgYJCgACAAAAAA==.',
['会计']='会计刺客:BAAALgAECgMJAwAAAA==.',
['传说']='传说中的刺哥:BAAALgAFFAEJAQAAAA==.传说中的菜姐:BAAALgAECgMJAwAAAA==.',
['伯兰']='伯兰丶死神:BAAALgADCgUJBQAAAA==.',
['低保']='低保选套装:BAAALgADCgEJAQAAAA==.',
['佐佑']='佐佑:BAAALgAECgcJBwAAAA==.',
['何术']='何术:BAAALgADCgUJBQAAAA==.',
['你这']='你这个坏蛋:BAAALgAECgYJDQAAAA==.',
['佩露']='佩露夏:BAAALgAECgUJCQAAAA==.',
['佬坑']='佬坑:BAAALgAECgcJBwAAAA==.',
['使劲']='使劲扑棱:BAAALgADCgEJAgAAAA==.',
['依古']='依古比古丶:BAABLgAECn8UAAINAAcJ1h6GEgBtAQANAAcJ1h6GEgBtAQAAAA==.',
['信神']='信神棍得永生:BAAALgAECgcJBwABLgAFFAEJAQACAAAAAA==.',
['倦收']='倦收天:BAAALgAFFAEJAwAAAA==.',
['傲娇']='傲娇:BAAALgAECgcJDgAAAA==.傲娇的槑槑:BAABLgAECn8WAAILAAkJqhbpGgCzAgALAAkJqhbpGgCzAgAAAA==.',
['傲氣']='傲氣天秤座:BAAALgAECgYJCgAAAA==.',
['光一']='光一闪跪一排:BAAALgAECgIJAgAAAA==.',
['光头']='光头蛋蛋:BAAALgADCgIJAgAAAA==.',
['光爷']='光爷的小种子:BAAALgAECgYJBgAAAA==.',
['光芒']='光芒乱射:BAAALgAECgUJCgABLgAFFAQJCgAHAEocAA==.',
['兜兜']='兜兜里都是毒:BAAALgAECgMJAwAAAA==.兜兜里都是茶:BAAALgAECgEJAQAAAA==.',
['全集']='全集中呼吸:BAAALgADCgUJBQAAAA==.',
['八月']='八月八诗年华:BAAALgAECgIJAgAAAA==.',
['六月']='六月丶飞霜:BAAALgAECgEJAQAAAA==.',
['六朝']='六朝帝王都:BAAALgAECgYJCAABLgAECgcJCgACAAAAAA==.',
['再也']='再也没有:BAAALgAECgYJCAAAAA==.',
['农村']='农村拳师:BAAALgAECgEJAQAAAA==.',
['冧林']='冧林子:BAAALgAECgYJBwAAAA==.',
['冬夜']='冬夜渐暖丶:BAAALgAFFAEJAQAAAA==.',
['冰冰']='冰冰:BAAALgAECgIJAgAAAA==.',
['冰冻']='冰冻的兔子:BAAALgAECgUJBwAAAA==.',
['冰可']='冰可乐:BAAALgAECgEJAQAAAA==.',
['冰林']='冰林承夏:BAAALgADCgEJAQAAAA==.',
['冰糖']='冰糖煮黄莲:BAAALgAECgYJCwAAAA==.',
['冰镇']='冰镇炒饭:BAAALgAECgcJBwAAAA==.',
['冰雪']='冰雪之荒芜:BAAALgAECgYJBgAAAA==.冰雪神裔:BAABLgAFFH8GAAIFAAMJOQ4ICQDXAAAFAAMJOQ4ICQDXAAAAAA==.',
['冲击']='冲击波:BAAALgAECgMJAwAAAA==.',
['冷箬']='冷箬冰霜:BAAALgAECgMJBAAAAA==.',
['凉拌']='凉拌猪下水丶:BAAALgAECgEJAQAAAA==.',
['凋零']='凋零的夜:BAABLgAFFH8FAAIIAAMJlwX9SgCTAAAIAAMJlwX9SgCTAAAAAA==.凋零魔导师:BAAALgAECgUJBAAAAA==.',
['凌非']='凌非烟:BAAALgAECgMJAwAAAA==.',
['凹凸']='凹凸曼死肥仔:BAABLgAFFH8FAAIKAAQJ/BdKCQBjAQAKAAQJ/BdKCQBjAQAAAA==.',
['别放']='别放生我:BAAALgAECgcJBwAAAA==.',
['前不']='前不见古人:BAAALgADCgIJAgAAAA==.',
['剑聖']='剑聖苇名一心:BAAALgAECgUJCgAAAA==.',
['劍謫']='劍謫仙:BAAALgAECgEJAQAAAA==.',
['力霸']='力霸天:BAAALgAECgEJAQAAAA==.',
['加勒']='加勒比海豹:BAAALgAECgcJAQAAAA==.',
['劳资']='劳资是国宝:BAAALgAECgEJAQAAAA==.',
['北原']='北原的白熊:BAAALgADCgEJAQAAAA==.',
['十倍']='十倍苦心:BAAALgAECgkJEwABLgAFFAQJBAACAAAAAA==.',
['千手']='千手王老七:BAAALgAECgEJAgAAAA==.',
['升龙']='升龙霸:BAAALgAECgEJAQABLgAFFAQJDgADAOcdAA==.',
['半条']='半条命:BAAALgAECgIJAwAAAA==.',
['半江']='半江渔火:BAAALgADCgEJAQAAAA==.',
['卖火']='卖火柴小牡牛:BAAALgAECgYJBwAAAA==.',
['卡哇']='卡哇伊灬依晨:BAAALgAECgEJAQAAAA==.',
['卧龙']='卧龙丶:BAABLgAECn8TAAQUAAcJgg63MABBAQAUAAYJyQ23MABBAQAVAAYJhAqsJAAAAQAWAAMJmweIOwCOAAAAAA==.',
['又菜']='又菜又爱玩:BAAALgAECgEJAQAAAA==.',
['发个']='发个火:BAACLgAFFH8QAAIIAAUJ3RY/CwDDAQAIAAUJ3RY/CwDDAQAuAAQKfyIAAggACAnCIzMXAB8DAAgACAnCIzMXAB8DAAAA.',
['古丿']='古丿尔丹:BAACLgAFFH8LAAILAAQJKxuGAwB5AQALAAQJKxuGAwB5AQAuAAQKfxcAAwsACAnkH5AqAGUCAAsABgncIpAqAGUCABcAAgkSDutFAJ4AAAAA.',
['古堡']='古堡的猫:BAABLgAFFH8MAAIIAAQJCBstFgBxAQAIAAQJCBstFgBxAQAAAA==.',
['古德']='古德萨:BAAALgAECgMJAwAAAA==.',
['只爱']='只爱安静:BAAALgAECgEJAQAAAA==.',
['可咸']='可咸可甜:BAAALgAECgYJDQAAAA==.',
['可樂']='可樂吃薯片:BAAALgAECgUJBgAAAA==.',
['可爱']='可爱天花板:BAAALgAFFAIJAwABLgAFFAcJBwALADocAA==.可爱菠萝子:BAAALgAECgMJAwAAAA==.',
['可问']='可问春风:BAAALgAECgYJCgAAAA==.',
['吃劳']='吃劳资一矛彡:BAAALgADCgYJBgAAAA==.',
['吃肥']='吃肥皂吐泡泡:BAAALgAECgkJCQAAAA==.',
['吃黄']='吃黄瓜麽麽哒:BAAALgAFFAEJAQAAAA==.',
['名字']='名字太难:BAAALgAECgQJAwAAAA==.名字己隐藏:BAAALgAFFAEJAQAAAA==.',
['吾为']='吾为混沌:BAABLgAECn8WAAMYAAcJnw03DQAcAQAYAAcJnw03DQAcAQAJAAEJZwjKiAAmAAAAAA==.',
['吾擒']='吾擒天:BAAALgAECgQJBAAAAA==.',
['吾焚']='吾焚天:BAAALgAECgMJAwAAAA==.',
['呉朙']='呉朙丨九:BAAALgAFFAUJBAAAAA==.呉朙丨八:BAAALgAFFAQJAgAAAA==.',
['呜喇']='呜喇喇:BAAALgADCgEJAgAAAA==.',
['咕得']='咕得猫德:BAAALgAECgYJCAAAAA==.',
['咩咩']='咩咩棂狐:BAACLgAFFH8GAAMLAAQJJgkaJwDhAAALAAMJYggaJwDhAAAXAAEJcguIFgBSAAAuAAQKfxYAAxcABgnVF142AN0AAAsABQlwFK6IAEgBABcAAwl5GF42AN0AAAAA.',
['咸鱼']='咸鱼猫施法中:BAAALgAECgYJBwAAAA==.',
['哆啦']='哆啦眯:BAAALgADCgQJBAAAAA==.',
['哈吉']='哈吉迷:BAAALgADCgcJDgAAAA==.',
['哎哟']='哎哟我的天呐:BAAALgAECgkJAwABLgAFFAcJBQAIANIGAA==.哎哟我的神呀:BAAALgAECgYJBgAAAA==.',
['唔西']='唔西迪西丶:BAAALgAECgYJBgAAAA==.',
['單單']='單單嘚疍:BAAALgADCgYJCQAAAA==.',
['喵喵']='喵喵莫思喵:BAAALgADCgUJBQAAAA==.',
['噴血']='噴血:BAAALgADCgUJBQAAAA==.',
['四财']='四财神:BAAALgADCgQJBAAAAA==.',
['因催']='因催思停:BAABLgAFFH8GAAIZAAIJlxRNGgCTAAAZAAIJlxRNGgCTAAAAAA==.',
['圐靐']='圐靐圙:BAAALgAFFAEJAQAAAA==.',
['圣一']='圣一光:BAAALgAECgEJAgAAAA==.',
['圣光']='圣光丶妖娆:BAAALgAECgQJBQAAAA==.圣光在照耀你:BAAALgAECgEJAQAAAA==.圣光大忽悠:BAAALgADCgMJAwAAAA==.',
['圣当']='圣当当:BAAALgAECgcJBgAAAA==.',
['圣马']='圣马奇土:BAAALgAECgYJCwAAAA==.',
['在下']='在下毛毛雨:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱小斐:BAAALgAECgYJBgAAAA==.',
['坎德']='坎德拉丶血誓:BAAALgAECgYJDQAAAA==.',
['塞巴']='塞巴多拉贡:BAAALgADCgYJBgAAAA==.',
['壹九']='壹九八八:BAAALgAECgEJAwAAAA==.',
['夏夜']='夏夜微醉:BAAALgAFFAQJBAAAAA==.',
['夏天']='夏天:BAAALgAECgMJAwAAAA==.',
['夏幽']='夏幽:BAAALgAECgYJDgAAAA==.',
['夏络']='夏络特:BAAALgAECgYJCgABLgAFFAYJCwAIAL0cAA==.',
['多巴']='多巴洛克:BAACLgAFFH8MAAINAAQJkyUvBgDBAQANAAQJkyUvBgDBAQAuAAQKfx0AAg0ABwn9I6cWAM4CAA0ABwn9I6cWAM4CAAAA.',
['夜一']='夜一:BAAALgAECgcJBwAAAA==.',
['夜放']='夜放花千树:BAAALgAECgMJAwAAAA==.',
['夜猫']='夜猫子:BAAALgAECgMJBAAAAA==.',
['夜龙']='夜龙翼:BAAALgAECgYJCQAAAA==.',
['大兽']='大兽萨:BAAALgAECgUJCgAAAA==.',
['大名']='大名大明:BAAALgAECgcJCQAAAA==.',
['大地']='大地白干:BAAALgADCgMJAwAAAA==.',
['大学']='大学生:BAEALgAECgEJAQABLgAFFAIJBAACAAAAAA==.',
['大山']='大山雀:BAAALgAECgYJCgAAAA==.',
['大熊']='大熊奶糖:BAABLgAFFH8GAAIKAAMJ+hawCAAIAQAKAAMJ+hawCAAIAQAAAA==.',
['大犇']='大犇犇:BAAALgAECgcJAQAAAA==.',
['大脸']='大脸猫:BAAALgADCgcJBwAAAA==.',
['大魔']='大魔骑士:BAAALgAECgEJAQAAAA==.',
['天剑']='天剑灬:BAAALgAECgEJAQAAAA==.',
['天堂']='天堂製造:BAAALgAECgMJBgAAAA==.',
['天真']='天真的云:BAAALgAFFAQJBAABLgAFFAYJCAAUAAkTAA==.',
['天蓝']='天蓝色一黑白:BAAALgAECgMJAwAAAA==.',
['天马']='天马流星兔:BAAALgAECgkJCgABLgAFFAcJDwAFAOsmAA==.',
['天鱼']='天鱼骑士:BAAALgAFFAQJBAAAAA==.',
['太平']='太平间王妃:BAAALgAECgEJAQAAAA==.',
['奈闻']='奈闻莫尔:BAAALgAECgIJAgAAAA==.',
['女子']='女子無才:BAAALgADCgYJBgAAAA==.',
['奶油']='奶油尐生:BAAALgADCggJCAAAAA==.',
['她不']='她不用下面:BAAALgAECgcJDAAAAA==.',
['她说']='她说是晒黑的:BAAALgAECgEJAQAAAA==.',
['好脆']='好脆啊:BAAALgAECgcJCAAAAA==.',
['妖妖']='妖妖蕶:BAAALgAECgYJBgAAAA==.',
['姜哥']='姜哥:BAAALgAFFAEJAQAAAA==.',
['威冲']='威冲白晶刚:BAAALgAFFAIJBAAAAA==.威冲蓝晶刚:BAAALgAECgYJBwAAAA==.',
['娘们']='娘们灬看刀:BAAALgAECgcJBwAAAA==.',
['娜岚']='娜岚嘉雪:BAAALgADCgYJBgAAAA==.',
['孟获']='孟获:BAAALgAECgEJAgAAAA==.',
['宁静']='宁静之语:BAAALgADCgYJBgAAAA==.',
['安自']='安自在丨:BAAALgAECgQJBAAAAA==.',
['安静']='安静一点点:BAAALgAECgMJAwAAAA==.',
['完颜']='完颜:BAAALgAECgQJBAAAAA==.完颜洪烈:BAAALgAECgUJBgAAAA==.完颜洪煭:BAAALgAECgUJBQAAAA==.',
['寒颤']='寒颤:BAAALgAECgMJAwAAAA==.',
['导丨']='导丨演:BAABLgAECn8dAAMHAAcJVx4xJAAtAgAHAAYJOyIxJAAtAgAaAAYJCBMWCQAWAQAAAA==.',
['射出']='射出一条长江:BAAALgAECgYJBgAAAA==.',
['小刺']='小刺猬的承诺:BAAALgAFFAIJAgAAAA==.',
['小夜']='小夜曲丶:BAAALgAECgEJAQAAAA==.',
['小小']='小小星:BAABLgAFFH8IAAQTAAQJHhBiEgCiAAATAAMJfA5iEgCiAAAFAAEJywe+EgBPAAAbAAEJcgfBFQBMAAABLgAFFAUJDQATABAfAA==.',
['小林']='小林酱超可爱:BAAALgAECgQJBAAAAA==.',
['小步']='小步舞曲:BAAALgAECgkJAQAAAA==.',
['小猎']='小猎:BAAALgAECgcJCQAAAA==.小猎三号:BAAALgAECgYJBgAAAA==.',
['小猫']='小猫猫喵喵叫:BAAALgADCgUJBQAAAA==.',
['小甜']='小甜甜扑烂妮:BAAALgAFFAEJAQAAAA==.',
['小绵']='小绵羊呀:BAAALgAECgcJCwAAAA==.',
['小肥']='小肥:BAAALgAECgEJAgAAAA==.',
['小超']='小超群:BAABLgAFFH8GAAIZAAIJeBg9GACfAAAZAAIJeBg9GACfAAAAAA==.',
['小静']='小静猪哔哔:BAABLgAECn8WAAIIAAgJryEtFwAfAwAIAAgJryEtFwAfAwAAAA==.',
['小馬']='小馬哥:BAAALgADCgIJAgAAAA==.',
['小麦']='小麦:BAABLgAFFH8FAAIKAAUJjRSuBACmAQAKAAUJjRSuBACmAQAAAA==.',
['尤格']='尤格薩倫:BAAALgAFFAEJAQAAAA==.',
['就当']='就当她练技术:BAAALgAECgYJDQAAAA==.',
['屠尽']='屠尽日寇:BAAALgAFFAQJBAAAAA==.',
['山玄']='山玄:BAAALgADCgMJAwAAAA==.',
['山野']='山野小菊花:BAAALgAFFAIJAgAAAA==.',
['山门']='山门大开:BAAALgADCgMJAwAAAA==.',
['岚之']='岚之山:BAAALgAECgkJEwAAAA==.',
['崔佛']='崔佛:BAAALgADCgEJAQAAAA==.',
['崔希']='崔希絲:BAAALgAECgQJBAABLgAECgQJBAACAAAAAA==.',
['崩摧']='崩摧:BAAALgAFFAEJAQAAAA==.',
['巅輪']='巅輪乛髪王:BAAALgAECgYJBgAAAA==.',
['巧克']='巧克力棒棒糖:BAAALgAECgEJAgAAAA==.',
['布洛']='布洛芬妮:BAAALgAECgkJCQAAAA==.',
['布莱']='布莱恩铝须:BAAALgAECgIJAgAAAA==.',
['帅乞']='帅乞男团:BAAALgADCgYJBgAAAA==.',
['帕米']='帕米拉之靈:BAABLgAECn8ZAAIRAAgJMhuEQwArAgARAAgJMhuEQwArAgAAAA==.',
['平头']='平头哥小蜜獾:BAAALgAECgQJBwAAAA==.',
['幸福']='幸福只是传说:BAAALgAECgYJDQAAAA==.幸福只是傳说:BAAALgAECgEJAQAAAA==.',
['幸运']='幸运丶壹:BAAALgAECgIJAgAAAA==.幸运丶美:BAAALgAECgEJAQAAAA==.幸运星大徐:BAAALgAECgIJAgAAAA==.',
['幸運']='幸運:BAAALgAECgcJDwAAAA==.',
['幻丶']='幻丶浅唱:BAAALgAECgEJAgAAAA==.',
['幻影']='幻影玄德:BAAALgAECgUJCAAAAA==.',
['幻翼']='幻翼之羽:BAAALgADCgEJAQAAAA==.',
['幽冥']='幽冥法魔:BAAALgAECgYJBwAAAA==.',
['幽灵']='幽灵:BAAALgAECgQJBAAAAA==.',
['库库']='库库噜:BAAALgAECggJDgAAAA==.',
['廿肆']='廿肆橋明月夜:BAAALgAECgIJAgAAAA==.',
['开山']='开山闲的熊:BAAALgAECgYJEQAAAA==.',
['开水']='开水浇花:BAAALgAECgEJAQAAAA==.',
['异旅']='异旅少年:BAAALgAECgQJBAAAAA==.',
['引领']='引领皮皮:BAAALgADCgEJAQAAAA==.引领阳阳:BAAALgAECgEJAwAAAA==.',
['弗罗']='弗罗依德:BAAALgAECgYJEQAAAA==.',
['弦鸣']='弦鸣丶喵小花:BAAALgAECgEJAQAAAA==.',
['当我']='当我入梦:BAAALgAECgYJBgABLgAFFAMJBwALAE0aAA==.',
['彬彬']='彬彬有礼:BAAALgADCgYJBgAAAA==.',
['彭彭']='彭彭的澎湃:BAAALgAECgkJCQAAAA==.',
['微凉']='微凉的記忆:BAAALgAFFAEJAQAAAA==.',
['微醺']='微醺丶:BAAALgAECgQJBAAAAA==.',
['德古']='德古拉:BAAALgAECgEJAQAAAA==.',
['德雷']='德雷祝塔尔:BAAALgAECgYJCwAAAA==.',
['心之']='心之钢丶永恩:BAAALgAECgMJAwAAAA==.',
['心情']='心情愉悦:BAAALgAECgEJAQAAAA==.',
['心空']='心空箭自无痕:BAAALgAECgYJDQAAAA==.',
['志琼']='志琼下落不明:BAAALgAECgQJAwAAAA==.',
['快乐']='快乐双踩:BAAALgAECgQJBAAAAA==.',
['快活']='快活嘚地沟油:BAAALgAECgYJEgAAAA==.',
['恋上']='恋上你的殇:BAAALgAECgUJCQAAAA==.',
['恋殇']='恋殇霓的灀:BAAALgAECgYJDwAAAA==.',
['恩恩']='恩恩:BAAALgAECgYJCQAAAA==.',
['恰豆']='恰豆豆:BAAALgAECgEJAQAAAA==.',
['恶棍']='恶棍在敲门:BAAALgAECgEJAQAAAA==.',
['悠叶']='悠叶:BAABLgAFFH8HAAMGAAQJwQxxIACSAAAGAAMJ7wBxIACSAAAHAAQJwQwAAAAAAAAAAA==.',
['悠悠']='悠悠忆往昔:BAAALgAECgMJAwAAAA==.',
['悦乐']='悦乐疯越悦:BAAALgAECgIJAgAAAA==.',
['悲伤']='悲伤破忒头:BAACLgAFFH8LAAINAAMJShaqGgD7AAANAAMJShaqGgD7AAAuAAQKfxUAAw0ABgmKIGw6AAsCAA0ABgmKIGw6AAsCABwAAQlCCrYsAC4AAAAA.',
['惩戒']='惩戒骑灬:BAAALgAECgEJAQAAAA==.',
['慕容']='慕容清风:BAAALgAECgEJAQAAAA==.',
['憨憨']='憨憨咕丶:BAAALgAECgcJBwAAAA==.',
['我不']='我不是狗二蛋:BAAALgADCgYJBgAAAA==.',
['我很']='我很慌丶:BAAALgADCgEJAQAAAA==.',
['我有']='我有两颗糖:BAAALgAFFAIJAgAAAA==.我有雨天:BAAALgADCgcJBwAAAA==.',
['我来']='我来组成裆部:BAAALgAECgUJBgAAAA==.',
['我爱']='我爱拉教授:BAAALgAECgcJBwAAAA==.我爱鸡爷:BAAALgAECgkJBwABLgAFFAQJBAACAAAAAA==.我爱黎明:BAAALgAECggJCgAAAA==.',
['我的']='我的:BAAALgAECgEJAQAAAA==.我的楼兰:BAAALgAECgEJAgAAAA==.',
['我能']='我能吃十碗:BAABLgAECn8VAAIbAAcJDSRXDAC9AgAbAAcJDSRXDAC9AgAAAA==.',
['我超']='我超萌德丶:BAAALgAECgEJAQAAAA==.',
['我遗']='我遗忘了一切:BAAALgADCgQJBAAAAA==.',
['我酷']='我酷我酷我酷:BAAALgAFFAMJBAAAAA==.',
['战仕']='战仕桑塔纳:BAAALgADCgcJBwAAAA==.',
['战破']='战破天:BAAALgAECgQJBAAAAA==.',
['戴撚']='戴撚憨:BAAALgAECgYJBwAAAA==.',
['打脚']='打脚骨:BAAALgAECgQJBAAAAA==.',
['扣肉']='扣肉太懒了:BAAALgAECggJEAAAAA==.',
['抹了']='抹了油的橙酱:BAAALgAECgYJDwABLgAFFAYJEwALAMYbAA==.',
['拉哈']='拉哈布雷亚:BAAALgAECgMJAwAAAA==.',
['拉迪']='拉迪亚斯:BAAALgAECgYJCQAAAA==.',
['拒虎']='拒虎:BAAALgAECgIJAgAAAA==.',
['拒软']='拒软:BAAALgADCgEJAQAAAA==.',
['招财']='招财猫叁号:BAAALgADCgEJAQAAAA==.',
['指尖']='指尖璇沙:BAAALgAECgYJEgAAAA==.指尖落在弦间:BAAALgAECgMJAwAAAA==.',
['掌握']='掌握虚空的人:BAAALgAECgcJBwAAAA==.',
['排骨']='排骨年糕:BAAALgAECggJEgAAAA==.',
['提利']='提利奥弗丁:BAAALgAFFAIJAwAAAA==.',
['搅拌']='搅拌缤纷:BAAALgAECgQJBwAAAA==.',
['撒满']='撒满旺旺:BAABLgAECn8YAAMNAAgJ5RtDJgBtAgANAAgJ5RtDJgBtAgAdAAEJAAB8YQBcAAAAAA==.',
['攸迪']='攸迪安:BAAALgAECgYJCQAAAA==.',
['放羊']='放羊的李二狗:BAAALgAECgQJCAAAAA==.',
['敏菲']='敏菲利亚:BAAALgADCgcJBwAAAA==.',
['方有']='方有志:BAABLgAFFH8KAAIRAAQJzxVMFQBOAQARAAQJzxVMFQBOAQAAAA==.方有野:BAABLgAFFH8JAAIeAAQJawp2AgDmAAAeAAQJawp2AgDmAAAAAA==.',
['旅行']='旅行的意义:BAAALgAECgkJAQAAAA==.',
['无天']='无天丶:BAAALgAECgQJBQAAAA==.',
['无拘']='无拘无术:BAAALgAECgcJBwAAAA==.',
['无敌']='无敌小旋风:BAABLgAFFH8GAAIfAAUJWw6JAQCZAQAfAAUJWw6JAQCZAQABLgAFFAYJFgAMAMUZAA==.',
['无极']='无极之巅:BAAALgADCgEJAQAAAA==.',
['无法']='无法丶:BAAALgAECgYJCgAAAA==.',
['日日']='日日要煲靓汤:BAAALgAECgMJAwAAAA==.',
['旧神']='旧神:BAAALgAECgQJBQAAAA==.',
['时间']='时间迷失了:BAAALgADCgIJAgAAAA==.',
['昆丶']='昆丶云:BAAALgADCgEJAQAAAA==.',
['昆明']='昆明德州:BAAALgAFFAIJAQAAAA==.昆明德州找我:BAAALgAECgUJBQAAAA==.',
['星光']='星光与你同在:BAAALgAECgYJCAAAAA==.',
['星羽']='星羽:BAAALgAECgYJBwAAAA==.',
['星路']='星路遥曜:BAACLgAFFH8KAAIHAAQJHBs2AgBsAQAHAAQJHBs2AgBsAQAuAAQKfxgAAgcABwnbHd8YAHMCAAcABwnbHd8YAHMCAAAA.',
['晓仴']='晓仴:BAAALgAECgEJAQAAAA==.',
['晓月']='晓月笙:BAAALgAECgkJAgAAAA==.',
['晴兲']='晴兲小鱼:BAAALgADCgUJBQAAAA==.',
['晴烟']='晴烟雨:BAAALgAECgQJBgAAAA==.',
['暗影']='暗影一鬼泣:BAAALgAECgIJAgAAAA==.暗影使者:BAAALgAECgEJAQAAAA==.暗影烈焰长靴:BAAALgAECgYJBwAAAA==.',
['暴富']='暴富牛牛:BAAALgAECgQJBAAAAA==.',
['暴捶']='暴捶管理员:BAABLgAECn8bAAMgAAcJ+h9FCABdAgAgAAYJmCNFCABdAgAfAAIJdwrajgBcAAAAAA==.',
['暴走']='暴走的瓦罗娜:BAAALgADCgMJAwAAAA==.',
['曉學']='曉學僧:BAACLgAFFH8ZAAIYAAYJyRb5AACkAQAYAAYJyRb5AACkAQAuAAQKfxcAAhgACAn4HDIVAGICABgACAn4HDIVAGICAAAA.',
['曹猪']='曹猪:BAAALgADCgEJAgAAAA==.',
['最佳']='最佳男主角:BAABLgAECn8UAAIKAAgJqhZqPwAoAgAKAAgJqhZqPwAoAgAAAA==.',
['最爱']='最爱老板娘:BAAALgAECgQJBQAAAA==.',
['月亮']='月亮在笑:BAAALgAFFAEJAQAAAA==.月亮骑:BAAALgAECgIJAgAAAA==.',
['月华']='月华血舞:BAAALgAECgMJBQAAAA==.',
['月酱']='月酱:BAABLgAFFH8IAAMTAAQJfRDpBQAAAQATAAMJRhTpBQAAAQAbAAEJdwckFgBKAAAAAA==.',
['朝朝']='朝朝辞暮:BAAALgAECgYJBgAAAA==.',
['未闻']='未闻狼名:BAAALgADCgUJBQAAAA==.未闻猫名:BAAALgADCgYJBgAAAA==.',
['朱老']='朱老师:BAAALgAECgMJAwAAAA==.',
['杀手']='杀手二八:BAAALgADCgUJBQAAAA==.杀手零零发:BAAALgAECgIJAgAAAA==.',
['李同']='李同学:BAAALgAECgYJCgAAAA==.',
['李小']='李小德:BAAALgAECgcJDwAAAA==.',
['条七']='条七有刺:BAABLgAFFH8GAAIIAAQJagKPJQAdAQAIAAQJagKPJQAdAQAAAA==.',
['来杯']='来杯黒咔啡:BAAALgADCgEJAQAAAA==.',
['松弛']='松弛感:BAAALgAECggJDAAAAA==.',
['极恶']='极恶之咒:BAAALgADCgYJBgAAAA==.',
['林夕']='林夕:BAAALgAECgIJAgAAAA==.',
['果冻']='果冻狂魔丶:BAAALgAECgYJBgAAAA==.',
['枫吹']='枫吹雪:BAAALgADCgYJCAAAAA==.',
['某小']='某小懒:BAAALgAECgkJCgAAAA==.',
['柒月']='柒月繁华:BAABLgAFFH8FAAIIAAIJQQnoQwCoAAAIAAIJQQnoQwCoAAAAAA==.',
['柠檬']='柠檬冰淇淋茶:BAABLgAFFH8HAAIMAAMJwBcTDgAKAQAMAAMJwBcTDgAKAQAAAA==.',
['栀子']='栀子楚:BAAALgAECgEJAQAAAA==.栀子花:BAABLgAECn8VAAIEAAgJJBa6GgAuAgAEAAgJJBa6GgAuAgAAAA==.栀子花呀:BAAALgAECgUJBQAAAA==.',
['桔子']='桔子黄了:BAAALgAECgEJAQAAAA==.',
['梦断']='梦断:BAAALgAECgYJCwAAAA==.',
['梦遊']='梦遊:BAAALgAFFAUJBAAAAA==.',
['梨谱']='梨谱:BAAALgAECgEJAwAAAA==.',
['棂儿']='棂儿咩咩:BAAALgADCgYJBgABLgAFFAQJBgALACYJAA==.',
['棉花']='棉花与尼哥:BAAALgAECgEJAQAAAA==.',
['榨汁']='榨汁魔:BAABLgAECn8XAAILAAgJaBMeOQAnAgALAAgJaBMeOQAnAgAAAA==.',
['樱小']='樱小路露娜:BAACLgAFFH8MAAIIAAMJgCW1HgBPAQAIAAMJgCW1HgBPAQAuAAQKfxUAAggABwmIJcweAPoCAAgABwmIJcweAPoCAAAA.',
['橘丶']='橘丶子:BAAALgAECgYJBgAAAA==.',
['欧洲']='欧洲明:BAAALgAECgcJEQAAAA==.',
['歃血']='歃血弑神:BAAALgADCgIJAgAAAA==.',
['正能']='正能量选手:BAAALgAFFAIJBAAAAA==.',
['武士']='武士之刃:BAAALgAECgMJBAAAAA==.',
['武藏']='武藏根岸:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡大绵羊:BAAALgAECgkJDwAAAA==.死亡爱丽斯:BAAALgAECgYJCgAAAA==.',
['比比']='比比东:BAAALgAECgcJCQAAAA==.',
['水月']='水月璃花:BAAALgAECgIJAgAAAA==.',
['永夜']='永夜君王:BAAALgAECgUJBwAAAA==.',
['永烁']='永烁:BAAALgAECgYJEwAAAA==.',
['江剑']='江剑心:BAAALgAECgIJAgAAAA==.',
['沉小']='沉小叨:BAAALgAECgcJCAABLgAFFAYJAQACAAAAAA==.',
['沉甸']='沉甸甸丶:BAAALgAECgQJBAAAAA==.',
['沐晨']='沐晨而上:BAAALgAECgQJBAAAAA==.',
['沐橙']='沐橙僧:BAAALgADCgEJAQAAAA==.',
['沖宮']='沖宮那美:BAABLgAECn8eAAMFAAgJXiDKAgA1AgAFAAgJXiDKAgA1AgATAAQJGAlaPgC6AAAAAA==.',
['沙奎']='沙奎尔奥尼尔:BAAALgAECgMJBAAAAA==.',
['沙风']='沙风辽:BAAALgAECgUJBgAAAA==.',
['法修']='法修散打:BAAALgAFFAIJAgABLgAFFAUJBQAZAJwUAA==.',
['法拉']='法拉利技师:BAAALgAECgEJAQAAAA==.',
['法爷']='法爷拉个桌子:BAAALgAECgkJCQAAAA==.',
['泠秋']='泠秋:BAAALgAECgEJAQAAAA==.',
['泡妞']='泡妞三十六计:BAAALgAECgIJAQAAAA==.',
['波加']='波加查:BAAALgAECgYJCgABLgAECgcJCgACAAAAAA==.',
['泰罗']='泰罗丶:BAAALgAECgYJBgAAAA==.',
['泰裹']='泰裹黑珍珠:BAAALgAECgMJAQAAAA==.',
['泼泼']='泼泼与波波:BAAALgAFFAQJAgAAAA==.',
['洞洞']='洞洞涡湿湿:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪剑客斯温:BAAALgAECgIJAQAAAA==.',
['流逝']='流逝于指尖:BAAALgADCgUJBQAAAA==.',
['浮夸']='浮夸小白牛:BAAALgADCgQJBAAAAA==.',
['海尔']='海尔格兰:BAAALgAECgIJAgAAAA==.',
['海是']='海是天的镜子:BAABLgAFFH8FAAILAAUJNBa4BgC2AQALAAUJNBa4BgC2AQAAAA==.',
['海棠']='海棠枝上吟丶:BAAALgAECgQJBQAAAA==.',
['海胆']='海胆栗子酱:BAAALgAECgUJBgAAAA==.',
['涩色']='涩色:BAAALgAECgYJCAAAAA==.',
['淘气']='淘气小静子:BAABLgAECn8YAAMfAAgJwht1DwCdAgAfAAgJwht1DwCdAgAMAAEJUgRnlQAgAAAAAA==.',
['淡泊']='淡泊夕阳:BAAALgAECgMJAwAAAA==.',
['混沌']='混沌宁昊:BAAALgAECgMJAwAAAA==.混沌浩劫:BAAALgAECgUJBQAAAA==.',
['清梦']='清梦压星河丶:BAAALgAECgYJCAAAAA==.',
['清浅']='清浅丶:BAAALgAECgYJDAAAAA==.',
['清风']='清风丶烈酒:BAAALgAECgQJBAAAAA==.清风几许:BAAALgAECgkJCwAAAA==.',
['渐染']='渐染秋霜:BAABLgAFFH8NAAMGAAYJwwxACgB0AQAGAAUJlwlACgB0AQAHAAQJyw1yCwC/AAAAAA==.',
['滚猫']='滚猫猫:BAABLgAFFH8FAAIYAAIJfA26DACJAAAYAAIJfA26DACJAAAAAA==.',
['满满']='满满滴都素爱:BAAALgADCgYJBwAAAA==.',
['火力']='火力:BAAALgADCgkJCQAAAA==.',
['火鸡']='火鸡味大锅巴:BAAALgAECggJDAAAAA==.',
['灰雾']='灰雾之上:BAAALgAECgEJAQAAAA==.',
['炎发']='炎发灼眼夏娜:BAAALgAECgcJCAAAAA==.',
['炎魔']='炎魔冰魁:BAAALgAECgMJAwAAAA==.',
['点燃']='点燃:BAAALgADCgEJAQAAAA==.',
['炽焰']='炽焰咆哮虎:BAACLgAFFH8GAAIhAAMJyiQQDAAdAQAhAAMJyiQQDAAdAQAuAAQKfxwAAiEACAmBJvoAAIkDACEACAmBJvoAAIkDAAAA.',
['烂春']='烂春袋:BAABLgAFFH8FAAIRAAIJkRp3OgCnAAARAAIJkRp3OgCnAAAAAA==.',
['烧雨']='烧雨:BAAALgAECggJCQAAAA==.',
['焦墨']='焦墨的太奶:BAABLgAFFH8FAAITAAIJtwoDCQCQAAATAAIJtwoDCQCQAAAAAA==.',
['煜丨']='煜丨风暴烈酒:BAAALgAECgEJAQAAAA==.',
['熊猫']='熊猫莘莘:BAAALgAECgMJAwAAAA==.',
['熔火']='熔火姚明:BAACLgAFFH8RAAMMAAUJWxkJAwDAAQAMAAUJWxkJAwDAAQAfAAEJvAb/IgBHAAAuAAQKfxgAAwwACAl5HG8ZAEgCAAwACAl5HG8ZAEgCACAAAQl8G6goAFEAAAAA.',
['燃锦']='燃锦:BAAALgAECgYJBgAAAA==.',
['燎原']='燎原火:BAAALgAECgYJCQAAAA==.',
['爪琊']='爪琊不是牙:BAABLgAECn8aAAMiAAgJLBNOHAAqAQAKAAYJ+BEMgQB4AQAiAAYJ3g9OHAAqAQABLgAFFAEJAQACAAAAAA==.',
['爱丽']='爱丽丝汀娜:BAAALgAECgUJCAAAAA==.',
['爱元']='爱元宝:BAAALgADCgMJAwAAAA==.',
['爱新']='爱新觉罗胤禛:BAAALgAECgYJBwAAAA==.',
['牛别']='牛别伦:BAAALgAECgEJAgAAAA==.',
['牛大']='牛大哥:BAAALgAFFAEJAQAAAA==.',
['牛油']='牛油麻辣蛋饺:BAAALgAECgYJCgAAAA==.',
['牛牛']='牛牛可乐:BAAALgAECgQJBAAAAA==.',
['牛牪']='牛牪犇牪犇:BAAALgAECgMJAwAAAA==.',
['牧绅']='牧绅一:BAAALgAECgkJDQAAAA==.',
['牧羊']='牧羊人的小小:BAAALgAECgEJAQAAAA==.',
['特郎']='特郎普:BAAALgAECgEJAQAAAA==.',
['狄老']='狄老班:BAAALgAECgEJAQAAAA==.',
['狐头']='狐头狐脑:BAAALgAECgMJBAAAAA==.',
['狗旺']='狗旺旺丶:BAAALgAECgIJAgAAAA==.',
['猎祖']='猎祖猎宗:BAAALgAFFAEJAQABLgADCgcJBwACAAAAAA==.',
['猛锤']='猛锤:BAAALgAECgEJAQAAAA==.',
['猩一']='猩一:BAAALgAECgMJAwAAAA==.',
['猩猩']='猩猩:BAAALgAECgMJAwAAAA==.',
['猪哼']='猪哼哼丶:BAACLgAFFH8ZAAMjAAYJSAnfBQCSAQAjAAUJngrfBQCSAQAeAAEJ7QMYDABRAAAuAAQKfyMABCMACAmoH+MMAO8CACMACAmoH+MMAO8CAAEABgnbDAwoAP8AAB4AAQlnGu83AFAAAAAA.',
['猪猪']='猪猪的毛毛狗:BAACLgAFFH8PAAMLAAYJdRmqBQDEAQALAAYJdRmqBQDEAQAXAAMJUQ+pBwDzAAAuAAQKfxgABAsACAkuHk4zAD8CAAsACAnqGU4zAD8CABcABAmPIX0fAFYBACQAAQkAAHgsAEYAAAAA.',
['猫猫']='猫猫过载:BAABLgAFFH8cAAIMAAcJSh5PAADGAgAMAAcJSh5PAADGAgAAAA==.',
['玄鸟']='玄鸟:BAAALgAECgkJAgAAAA==.',
['玛济']='玛济斯:BAAALgAECgIJAwAAAA==.',
['玥銫']='玥銫:BAAALgAECgcJDgAAAA==.',
['琼玉']='琼玉绘晚星丶:BAAALgAECgYJEAABLgAFFAUJBQAcAFMlAA==.',
['瑞鹤']='瑞鹤:BAAALgADCgkJCwAAAA==.',
['瑬火']='瑬火飛霜:BAABLgAFFH8FAAIIAAMJEA0TPQCyAAAIAAMJEA0TPQCyAAAAAA==.',
['瓜子']='瓜子煲猩猩:BAAALgAECgMJAwAAAA==.',
['瓜神']='瓜神终将为王:BAAALgAECgYJBgAAAA==.',
['田一']='田一卝田七:BAAALgAECgYJEgAAAA==.',
['电光']='电光丶奥义:BAAALgADCgkJBgAAAA==.',
['电撒']='电撒撒:BAAALgADCgYJBgAAAA==.',
['电玩']='电玩战魂:BAAALgADCgEJAQAAAA==.',
['画夕']='画夕颜:BAAALgAECgEJAQAAAA==.',
['疯子']='疯子旳迷恋:BAAALgAECgQJBAAAAA==.',
['疯狂']='疯狂炸线:BAAALgADCgEJAQAAAA==.疯狂老湿:BAAALgAECgYJBgAAAA==.',
['痛苦']='痛苦草鱼:BAACLgAFFH8MAAMLAAQJ4iCOCQCSAQALAAQJ4iCOCQCSAQAXAAEJAQvuFgBRAAAuAAQKfxkABAsACAl3IW4nAHQCAAsABglhJG4nAHQCABcABQlRGAsmAC4BACQAAQkAAA4jAGYAAAAA.',
['痞小']='痞小四:BAAALgAECgQJBAAAAA==.',
['痞帅']='痞帅:BAAALgAECgYJBwAAAA==.',
['痴侖']='痴侖线:BAAALgAFFAEJAQAAAA==.',
['痴囵']='痴囵线:BAABLgAECn8bAAIRAAcJ+BSkaAC8AQARAAcJ+BSkaAC8AQAAAA==.',
['瘾丶']='瘾丶:BAAALgAECgYJCgAAAA==.',
['白井']='白井黑子:BAAALgAECgQJBQAAAA==.',
['白发']='白发小獠牙:BAABLgAFFH8JAAIbAAQJYSBLBACZAQAbAAQJYSBLBACZAQABLgAFFAUJCQAFANcWAA==.',
['白库']='白库噜:BAAALgAECgYJBgAAAA==.',
['百万']='百万基老同时:BAAALgAECgYJBgAAAA==.',
['盖茨']='盖茨比:BAAALgADCgUJBQAAAA==.',
['盛夏']='盛夏的月:BAAALgAFFAQJBAAAAA==.',
['真不']='真不会玩:BAACLgAFFH8XAAMMAAYJiSBHAQAbAgAMAAYJiSBHAQAbAgAfAAEJyASWIgBIAAAuAAQKfyUAAgwACAl/JbgEAE4DAAwACAl/JbgEAE4DAAAA.',
['睡觉']='睡觉波比大王:BAAALgAECgEJAQAAAA==.',
['石榴']='石榴红:BAAALgADCgQJBAABLgAECgcJGwAgAPofAA==.',
['破伤']='破伤风:BAAALgAECgIJAwAAAA==.',
['硬梆']='硬梆梆丶:BAACLgAFFH8XAAINAAYJLBddAgAtAgANAAYJLBddAgAtAgAuAAQKfx4AAw0ACAmOH60ZALoCAA0ACAmOH60ZALoCAB0AAQm4HyJkAFMAAAAA.',
['神叨']='神叨叨:BAAALgADCgIJAgABLgAFFAUJBQAKAPseAA==.',
['神吼']='神吼吼:BAAALgAECgQJAwAAAA==.',
['神奇']='神奇大菠萝:BAAALgAECgYJCAAAAA==.',
['神秘']='神秘嘉宾:BAAALgADCgcJBwAAAA==.',
['禄柒']='禄柒识转弯:BAAALgAECgcJBwAAAA==.',
['福咧']='福咧咧:BAAALgAECgYJBgAAAA==.',
['秋之']='秋之泪:BAAALgADCgUJBQAAAA==.',
['秩序']='秩序始源:BAABLgAFFH8KAAIBAAQJBxGWBQAUAQABAAQJBxGWBQAUAQABLgAFFAUJEQAYAOwYAA==.',
['稀有']='稀有型库噜:BAACLgAFFH8XAAIlAAYJIBiqAgDjAQAlAAYJIBiqAgDjAQAuAAQKfxcAAiUACAkyIYsIAM0CACUACAkyIYsIAM0CAAAA.',
['稍懂']='稍懂拳脚:BAAALgAFFAEJAQAAAA==.',
['空山']='空山基:BAAALgAECgYJCAAAAA==.',
['筐鸨']='筐鸨粘:BAAALgAECgQJBAABLgAECgcJFwAOAE0dAA==.',
['筱筱']='筱筱豆丁:BAAALgADCgEJAQAAAA==.',
['管你']='管你事的蛋蛋:BAAALgADCgcJBwAAAA==.',
['粉乂']='粉乂乂:BAAALgAECgYJCQAAAA==.',
['粉灬']='粉灬嘟嘟:BAAALgAECgYJEwAAAA==.',
['糕手']='糕手阿毛:BAAALgAFFAEJAwAAAA==.',
['索拉']='索拉棂果:BAAALgAECgIJAgABLgAFFAQJBgALACYJAA==.',
['紫月']='紫月丶星辰:BAAALgAECgEJAQAAAA==.',
['維他']='維他:BAAALgAECgYJDQAAAA==.',
['維牠']='維牠:BAAALgAFFAEJAQAAAA==.',
['緈福']='緈福只是传说:BAAALgAECgUJBQAAAA==.',
['红藕']='红藕香殘:BAAALgAECgYJCwAAAA==.',
['纯情']='纯情小芈芈:BAAALgAECgcJEgAAAA==.',
['纷纷']='纷纷飞花已是:BAAALgAECgEJAgAAAA==.',
['细雨']='细雨如烟:BAAALgAECgUJDAAAAA==.',
['终焉']='终焉暮气:BAABLgAFFH8IAAIUAAYJZBZWCgDVAAAUAAYJZBZWCgDVAAAAAA==.',
['给你']='给你一冲锋:BAAALgADCgIJAgAAAA==.给你两坨子:BAAALgAFFAMJBAAAAA==.给你吃芒果:BAAALgAECgYJAwAAAA==.',
['给糖']='给糖就不哭:BAAALgAECgIJAgAAAA==.',
['绯色']='绯色柳絮:BAAALgAFFAIJAgAAAA==.',
['缘宝']='缘宝:BAAALgAECgQJBAAAAA==.',
['羊了']='羊了个羊羊:BAAALgAECgQJBAAAAA==.',
['羲和']='羲和丶:BAAALgAECgUJBQAAAA==.',
['翠羽']='翠羽丹霞:BAAALgAECgUJBQAAAA==.',
['老李']='老李:BAAALgAECgEJAQAAAA==.',
['老死']='老死花酒间:BAAALgAECgQJBAAAAA==.',
['老痰']='老痰酸菜面:BAAALgADCgcJBwAAAA==.',
['聆歌']='聆歌:BAAALgAECgcJBwAAAA==.',
['聪明']='聪明的肉肉:BAAALgAECgkJEgAAAA==.',
['聪眀']='聪眀旳肉肉:BAABLgAECn8WAAIRAAkJEB9yEAAaAwARAAkJEB9yEAAaAwAAAA==.聪眀的肉肉:BAABLgAECn8VAAIIAAkJRCFhBwCRAwAIAAkJRCFhBwCRAwAAAA==.',
['肚腩']='肚腩一圈肉:BAAALgAECgYJDgABLgAECgkJBgACAAAAAA==.',
['肥猪']='肥猪流七神:BAAALgADCgEJAQAAAA==.肥猪流八神:BAAALgADCgIJAQAAAA==.',
['胖纸']='胖纸一定死:BAAALgAECgkJBAABLgAFFAYJDQAXAOgiAA==.',
['能恩']='能恩:BAAALgAECgYJBgABLgAECgkJBwACAAAAAA==.',
['自然']='自然萌:BAAALgAFFAMJAwAAAA==.',
['自爆']='自爆自行车:BAACLgAFFH8FAAMMAAIJQwozFwCbAAAMAAIJQwozFwCbAAAfAAEJGgIAJwA5AAAuAAQKfxcAAwwABgniGo8pAMgBAAwABgniGo8pAMgBAB8ABgnZFtBBAHoBAAAA.',
['至简']='至简之力:BAAALgAFFAIJAgABLgAFFAIJBAACAAAAAA==.',
['芥兰']='芥兰强:BAAALgAFFAIJAgAAAA==.',
['花恋']='花恋哥:BAAALgAECgEJAgAAAA==.',
['花泰']='花泰富:BAAALgAECgYJBgAAAA==.',
['花開']='花開富貴:BAAALgAECgEJAQAAAA==.',
['苍天']='苍天月下:BAAALgAECgQJBAAAAA==.',
['苍烟']='苍烟落照:BAAALgADCgEJAQAAAA==.',
['苍蓝']='苍蓝色的圣光:BAAALgADCgkJEAAAAA==.',
['苏灬']='苏灬木:BAAALgAFFAIJAwAAAA==.',
['苞米']='苞米地的苞米:BAAALgAECgcJDAAAAA==.',
['苡宁']='苡宁清怀:BAAALgAECgcJBwAAAA==.',
['若梦']='若梦流苏:BAAALgAFFAMJAwAAAA==.',
['若葉']='若葉睦:BAABLgAFFH8LAAIlAAMJtR0WCQAnAQAlAAMJtR0WCQAnAQABLgAFFAQJBAACAAAAAA==.',
['英却']='英却澌汀丶:BAAALgAECgcJEwAAAA==.',
['茈春']='茈春袋:BAAALgAECgIJAgAAAA==.',
['茉莉']='茉莉奶白:BAABLgAFFH8FAAMGAAIJ2yQgHAClAAAGAAIJGhcgHAClAAAHAAIJ2yQ5HQBsAAAAAA==.',
['荒丶']='荒丶:BAACLgAFFH8HAAILAAMJNB46GAAvAQALAAMJNB46GAAvAQAuAAQKfxsAAwsABwkyJZYUANoCAAsABwn2JJYUANoCABcAAgljI51KAI4AAAAA.',
['荔枝']='荔枝术:BAAALgAECgYJBgAAAA==.',
['莱瑞']='莱瑞蕾:BAAALgAECgQJBAAAAA==.',
['菜菜']='菜菜子呀:BAABLgAECn8aAAMMAAcJ3As0RQA0AQAMAAYJcw00RQA0AQAfAAUJxxJrGADfAAAAAA==.',
['菠萝']='菠萝油丶罗宾:BAAALgAECgYJBgAAAA==.',
['萌萌']='萌萌不讲理:BAAALgADCgEJAQAAAA==.',
['萤火']='萤火之歌:BAAALgAECgQJBgAAAA==.',
['萬象']='萬象星塵:BAAALgADCgcJBwAAAA==.',
['蓝希']='蓝希诺:BAAALgADCgEJAQAAAA==.',
['蔡嘘']='蔡嘘坤:BAABLgAECn8VAAQeAAcJMRboDADQAQAeAAcJ4xPoDADQAQAjAAYJtRG2UQBiAQABAAEJLhQ6RgA0AAAAAA==.',
['蔷薇']='蔷薇怡仞:BAACLgAFFH8LAAIYAAQJYxqDCABLAQAYAAQJYxqDCABLAQAuAAQKfx8AAxgACAluIs0HAAkDABgACAltIs0HAAkDAAkABAksDh1TAMUAAAAA.',
['薄嗬']='薄嗬葒嗏:BAACLgAFFH8FAAIIAAIJmBlQNwC7AAAIAAIJmBlQNwC7AAAuAAQKfxkAAggACAmbGt5MAFACAAgACAmbGt5MAFACAAEuAAUUBAkLAAgAKxUA.',
['薄荷']='薄荷拿铁:BAABLgAECn8dAAIfAAkJixX6HwAfAgAfAAkJixX6HwAfAgAAAA==.',
['薩菲']='薩菲罗斯:BAAALgAECgIJAgAAAA==.',
['薯条']='薯条喝可乐:BAAALgAECgYJBQAAAA==.',
['虚空']='虚空术丶莫:BAAALgAFFAEJAQAAAA==.',
['蛯沢']='蛯沢真冬:BAAALgAECgMJAwAAAA==.',
['蜥蜴']='蜥蜴:BAAALgAFFAEJAQAAAA==.',
['蠻爷']='蠻爷:BAAALgAECgIJAwAAAA==.',
['血葬']='血葬武陵:BAAALgAECgEJAgAAAA==.',
['血魔']='血魔释:BAAALgAECgQJBQAAAA==.',
['补个']='补个耐:BAAALgAECgYJDwAAAA==.',
['裁决']='裁决:BAAALgAFFAEJAgAAAA==.',
['裂膜']='裂膜恶手:BAAALgADCgYJDAAAAA==.',
['装糊']='装糊涂的高手:BAAALgAECgUJBQABLgAFFAUJBQAZAJkcAA==.',
['解忧']='解忧杂货铺:BAAALgAECgUJBQAAAA==.',
['让老']='让老鬼玷污你:BAAALgAECgMJAwAAAA==.',
['诗水']='诗水蛇山神:BAACLgAFFH8HAAILAAMJTRrdDQAFAQALAAMJTRrdDQAFAQAuAAQKfxUAAxcACAmvG6UkADYBAAsABQmRHf5uAIIBABcABAmpF6UkADYBAAAA.',
['说话']='说话请投币:BAAALgAECgkJCQAAAA==.',
['谪仙']='谪仙丶:BAACLgAFFH8FAAImAAMJ6gVfAgCNAAAmAAMJ6gVfAgCNAAAuAAQKfxoAAiYABgk8FIMSAEkBACYABgk8FIMSAEkBAAAA.',
['豆包']='豆包真棒:BAABLgAFFH8FAAIKAAUJ+x6JAgDaAQAKAAUJ+x6JAgDaAQAAAA==.',
['豆沙']='豆沙大包:BAAALgAECgYJBgAAAA==.',
['豪鬼']='豪鬼的熊猫:BAAALgAECgUJBQAAAA==.',
['贺强']='贺强:BAAALgAECgIJAgAAAA==.',
['贼吸']='贼吸吸:BAAALgAECgYJBgAAAA==.',
['赞达']='赞达拉:BAAALgADCgQJBAAAAA==.',
['赤雲']='赤雲:BAAALgAECgYJBgAAAA==.',
['赦玑']='赦玑:BAAALgAECgEJAQAAAA==.',
['起峰']='起峰了:BAAALgAECgUJBQAAAA==.',
['超可']='超可爱的女孩:BAAALgAFFAEJAQAAAA==.',
['超级']='超级丿牛肉人:BAAALgAECgEJAgAAAA==.',
['超音']='超音速:BAAALgAECgEJAQAAAA==.',
['跑路']='跑路仔:BAAALgAECgUJBwAAAA==.',
['跳舞']='跳舞的旋律:BAAALgAECgEJAQAAAA==.',
['跳起']='跳起一飞腿:BAABLgAECn8dAAQcAAgJ0At9GADaAAAdAAUJ4Q1WPwD/AAANAAYJPgf2kgD4AAAcAAUJHAd9GADaAAAAAA==.',
['跷课']='跷课的西瓜:BAAALgAECgIJAQAAAA==.',
['踏天']='踏天下:BAAALgADCgQJBAAAAA==.',
['踏白']='踏白摧锋:BAAALgAECgEJAQAAAA==.',
['踏雪']='踏雪行歌:BAAALgAECgYJBQAAAA==.',
['蹦蹦']='蹦蹦猪:BAAALgAECgEJAQAAAA==.',
['輪佪']='輪佪祺:BAAALgAFFAQJBAAAAA==.',
['车队']='车队灵魂:BAACLgAFFH8OAAIRAAQJ7SByDQBtAQARAAQJ7SByDQBtAQAuAAQKfx0AAhEACAkzJl4IAFwDABEACAkzJl4IAFwDAAAA.',
['轻弹']='轻弹一首别离:BAAALgAFFAIJAwAAAA==.',
['还我']='还我风暴英雄:BAAALgAECgYJDAABLgAECgcJGwAgAPofAA==.',
['这天']='这天不太黑:BAAALgAECgQJBAAAAA==.',
['进击']='进击的帕拉丁:BAAALgADCgEJAQAAAA==.',
['退休']='退休赣部:BAAALgAECgEJAQAAAA==.',
['逆天']='逆天使:BAAALgAFFAQJBAAAAA==.',
['逆流']='逆流河:BAAALgADCgEJAQAAAA==.',
['那云']='那云那雪:BAABLgAFFH8IAAIDAAQJkBU8AQB6AQADAAQJkBU8AQB6AQAAAA==.',
['那彩']='那彩虹丨很美:BAABLgAFFH8IAAIRAAIJfgwAGwCZAAARAAIJfgwAGwCZAAAAAA==.',
['邪地']='邪地灵:BAAALgAECgcJEAAAAA==.',
['邪秽']='邪秽在身:BAABLgAECn8VAAIRAAcJGxgsUQD+AQARAAcJGxgsUQD+AQAAAA==.',
['邪血']='邪血小白:BAAALgAECgYJDgAAAA==.',
['邪魔']='邪魔骑士:BAAALgADCgYJBgAAAA==.',
['郊眠']='郊眠寺:BAAALgAECgcJCAAAAA==.',
['部落']='部落的小可爱:BAAALgAFFAEJAQAAAA==.',
['酚麻']='酚麻美敏片:BAAALgAECgEJAQAAAA==.',
['酱汁']='酱汁:BAABLgAECn8VAAIOAAgJ7RwIEwCCAgAOAAgJ7RwIEwCCAgAAAA==.酱汁丶第二帅:BAAALgAECgEJAQAAAA==.',
['醉相']='醉相思:BAAALgAFFAIJAgAAAA==.',
['野猪']='野猪不吃细糠:BAAALgAFFAEJAQAAAA==.',
['钜安']='钜安拓箭神:BAABLgAECn8XAAIHAAcJjhiJNQDYAQAHAAcJjhiJNQDYAQAAAA==.',
['钟发']='钟发白:BAAALgAECgcJBwAAAA==.',
['银月']='银月城倒霉蛋:BAAALgAECgMJBAAAAA==.',
['销魂']='销魂圣光:BAAALgAECgcJBwAAAA==.',
['锝彩']='锝彩:BAABLgAECn8bAAIiAAcJqhGbGQBFAQAiAAcJqhGbGQBFAQAAAA==.',
['锣刹']='锣刹鬼王帅富:BAAALgAECgUJBQAAAA==.',
['长歌']='长歌暖浮生丶:BAAALgAECgYJBwAAAA==.',
['长江']='长江三峡大坝:BAAALgAECgcJBwAAAA==.',
['阿契']='阿契娜:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔托莉丫:BAAALgAECgIJBQAAAA==.',
['阿良']='阿良丶:BAAALgAECgEJAgAAAA==.',
['阿风']='阿风丶丶:BAAALgAECgYJDAAAAA==.',
['陈巨']='陈巨龙的撞击:BAAALgAECgYJCwAAAA==.',
['陌殇']='陌殇悲鸣:BAAALgAFFAEJAQAAAA==.',
['陌陌']='陌陌上殇:BAABLgAFFH8FAAIHAAMJ2BabCQAUAQAHAAMJ2BabCQAUAQAAAA==.',
['随风']='随风小飒:BAAALgAECgcJCgAAAA==.',
['雅婷']='雅婷的暖暖:BAAALgAECgEJAgAAAA==.',
['集合']='集合分摊:BAAALgAECgcJDQAAAA==.',
['雪琳']='雪琳雅子:BAAALgAECgkJAwAAAA==.',
['雲見']='雲見:BAAALgAECgEJAQAAAA==.',
['雲贵']='雲贵川传染源:BAAALgAECgYJCQAAAA==.',
['零度']='零度:BAAALgAECgEJAgAAAA==.',
['零月']='零月蚀:BAAALgADCgMJAwAAAA==.',
['霜兰']='霜兰丶:BAABLgAFFH8HAAMKAAMJeR8qGQDfAAAKAAIJESYqGQDfAAAiAAMJ3Q4AAAAAAAAAAA==.',
['霸丿']='霸丿霸:BAAALgAECgEJAQAAAA==.',
['霸王']='霸王色的霸气:BAABLgAECn8aAAIjAAcJqxtdKQAVAgAjAAcJqxtdKQAVAgAAAA==.',
['霹雳']='霹雳小面包:BAAALgAECgEJAgAAAA==.',
['青丝']='青丝染银霜:BAECLgAFFH8WAAIbAAYJFyKkAABuAgAbAAYJFyKkAABuAgAuAAQKfyEAAhsACQlQI68BAKkDABsACQlQI68BAKkDAAEuAAUUAgkEAAIAAAAA.',
['青山']='青山霁雨:BAAALgAFFAEJAQAAAA==.',
['颢如']='颢如辰星:BAABLgAFFH8HAAMhAAMJuxV6DwDhAAAhAAMJuxV6DwDhAAAKAAEJcAlNNQBNAAABLgAFFAYJFwAKAN0fAA==.',
['風吹']='風吹你的裙角:BAAALgAFFAEJAQAAAA==.',
['风一']='风一样的男子:BAAALgAFFAMJBAAAAA==.',
['风之']='风之诚:BAAALgAECgEJAQAAAA==.',
['风影']='风影猎手:BAAALgAECgUJBQAAAA==.',
['风暴']='风暴烈酒丶萌:BAAALgADCgUJBQAAAA==.',
['风林']='风林小猎:BAAALgAECgYJCgAAAA==.',
['风流']='风流不是丶浪:BAAALgAECgQJBAAAAA==.',
['风舞']='风舞雷动:BAAALgAECgYJBgAAAA==.',
['风行']='风行:BAAALgAECgEJAQAAAA==.风行九歌:BAAALgAECgcJBwAAAA==.',
['飞天']='飞天蛙:BAAALgADCgEJAQAAAA==.',
['饕餮']='饕餮骑士:BAAALgAECgUJBQAAAA==.',
['饭来']='饭来:BAAALgAECgEJAgAAAA==.',
['饮茶']='饮茶先:BAAALgADCgYJBgAAAA==.',
['馒头']='馒头公子:BAAALgADCgcJBwAAAA==.',
['香咕']='香咕:BAAALgAECgYJCQAAAA==.',
['香喷']='香喷喷丶:BAACLgAFFH8QAAIKAAYJQRsBAgDzAQAKAAYJQRsBAgDzAQAuAAQKfxgAAgoACAkVJM8VAOYCAAoACAkVJM8VAOYCAAAA.',
['香芋']='香芋波啵奶茶:BAAALgAECgMJBAAAAA==.',
['骑月']='骑月亮看星星:BAAALgAECgEJAQAAAA==.',
['骨头']='骨头法罚:BAAALgAECgYJDQAAAA==.',
['高叉']='高叉泳装魔王:BAAALgADCgIJAgAAAA==.',
['高松']='高松灯:BAAALgAECgUJBQAAAA==.',
['高端']='高端上档次:BAAALgADCgYJDAAAAA==.',
['魔愈']='魔愈者斐柳依:BAAALgADCgEJAQAAAA==.',
['魔法']='魔法猫咪:BAACLgAFFH8UAAIWAAUJyhrIAADqAQAWAAUJyhrIAADqAQAuAAQKfyAAAxYACAmkGuMMAGcCABYACAmkGuMMAGcCABQAAQmODxxjADAAAAAA.',
['鱼小']='鱼小妖:BAABLgAECn8aAAImAAcJhw/7EgBCAQAmAAcJhw/7EgBCAQAAAA==.',
['鱼缸']='鱼缸:BAAALgAECgMJAwAAAA==.',
['鲁米']='鲁米亚斯:BAACLgAFFH8GAAIWAAMJfRiBDgDuAAAWAAMJfRiBDgDuAAAuAAQKfx4AAhYACAlpGecQAC0CABYACAlpGecQAC0CAAAA.',
['鳳霜']='鳳霜綾:BAAALgAECgYJCwAAAA==.',
['鸡二']='鸡二加蛋:BAAALgAFFAIJAgABLgAFFAUJEQAMAFsZAA==.',
['鸿鹄']='鸿鹄之志:BAAALgAECgYJBgAAAA==.',
['麦旋']='麦旋风:BAACLgAFFH8KAAIUAAQJbxu7BwB2AQAUAAQJbxu7BwB2AQAuAAQKfxUAAxQACAlSH3YOAI4CABQACAm6HnYOAI4CABUABwl8G9sLAB0CAAAA.',
['黄昏']='黄昏晓:BAAALgAECgIJAwAAAA==.',
['黑暗']='黑暗伊丽莎:BAAALgADCgQJBAAAAA==.',
['黑皮']='黑皮吗喽:BAAALgAECgEJAgAAAA==.',
['黑禮']='黑禮菔:BAAALgAECgEJAQAAAA==.',
['黑锋']='黑锋星光:BAAALgAECgYJBgABLgAECgYJCAACAAAAAA==.',
['黯泪']='黯泪无忧:BAABLgAFFH8FAAIIAAIJHARDHgCZAAAIAAIJHARDHgCZAAAAAA==.',
['齐天']='齐天大圣悟空:BAAALgAECgQJBAAAAA==.',
['龍嘶']='龍嘶嘶:BAAALgADCgMJAwAAAA==.',
['龍级']='龍级:BAAALgAFFAIJAgABLgAFFAMJBQANAA0YAA==.',
['龙傲']='龙傲天丶丶:BAAALgAECgYJBgAAAA==.',
['龙听']='龙听雨:BAAALgAECgYJEgAAAA==.',
['龙呼']='龙呼呼丶:BAABLgAECn8dAAQUAAgJgRR2FgAkAgAUAAgJgRR2FgAkAgAWAAYJCQvoJwA0AQAVAAIJCgMQPQA6AAABLgAFFAYJGQAjAEgJAA==.',
['龙天']='龙天啸:BAAALgAECgEJAQAAAA==.',
['龙奥']='龙奥天:BAAALgADCgUJBQAAAA==.',
['龙希']='龙希尔薇:BAABLgAFFH8JAAIWAAUJChMZBQCmAQAWAAUJChMZBQCmAQAAAA==.龙希希丶:BAAALgAECgcJCAAAAA==.',
['龙舌']='龙舌兰朗姆:BAAALgAECgkJBQAAAA==.',
['龚云']='龚云海:BAAALgAFFAIJAwAAAA==.',
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
