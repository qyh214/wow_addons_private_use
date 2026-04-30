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

local lookup = {'Warlock-Demonology','Warlock-Destruction','DeathKnight-Unholy','DemonHunter-Havoc','Mage-Frost','DemonHunter-Devourer','Druid-Balance','Druid-Restoration','Evoker-Augmentation','DeathKnight-Blood','Hunter-BeastMastery','Priest-Discipline','Priest-Holy','Shaman-Enhancement','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Rogue-Subtlety','Shaman-Restoration','Paladin-Retribution','Warrior-Protection','Hunter-Marksmanship','Hunter-Survival','Monk-Brewmaster','Evoker-Preservation','Evoker-Devastation','Druid-Guardian','Shaman-Elemental','Monk-Mistweaver','Priest-Shadow',}
local provider = {region='CN',realm='荆棘谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adgt:BAAALgAECgMJAwAAAA==.',
Ai='Ailons:BAAALgADCgYJBgAAAA==.',
Al='Alana:BAAALgADCgUJBQAAAA==.',
Ar='Archangel:BAAALgAECgYJEgAAAA==.',
At='Attach:BAABLgAFFH8IAAMBAAQJdR0sCQBKAQABAAQJ3RksCQBKAQACAAEJrRmyEgBZAAABLgAFFAcJBwACAE0eAA==.',
Bl='Blackpudding:BAAALgAECgEJAQAAAA==.',
Ca='Candybin:BAABLgAFFH8IAAIDAAIJqRmrNAC1AAADAAIJqRmrNAC1AAAAAA==.Caniva:BAABLgAECn8XAAIEAAgJSCMYBAA5AwAEAAgJSCMYBAA5AwAAAA==.Carrsy:BAAALgAFFAQJAwAAAA==.',
Ch='Chinchilla:BAAALgAECgIJAgAAAA==.',
Cr='Crazylitchi:BAAALgADCgEJAQAAAA==.',
De='Deathloadj:BAACLgAFFH8PAAIDAAQJnR02BgBcAQADAAQJnR02BgBcAQAuAAQKfxUAAgMACQkgIR8eAMwCAAMACQkgIR8eAMwCAAAA.Dezal:BAAALgAECgYJCQABLgAECggJFAAFAOARAA==.',
Dk='Dkmoney:BAAALgADCgcJBwAAAA==.',
Fr='Freyjavayne:BAAALgAECgIJAwAAAA==.',
Je='Jelmont:BAAALgAFFAEJAQAAAA==.',
Ju='Juanz:BAACLgAFFH8LAAIGAAMJmBcoGgD/AAAGAAMJmBcoGgD/AAAuAAQKfyMAAwYACAnUIacPAAIDAAYACAnUIacPAAIDAAQAAglfGm5SAKAAAAAA.',
Kk='Kkomilol:BAAALgAECgcJBwAAAA==.Kkomrlol:BAAALgAECgEJAQAAAA==.',
Le='Level:BAAALgAECgYJBgAAAA==.',
Li='Linckqs:BAAALgAECgMJAwAAAA==.Litchixlol:BAAALgAECgIJBAAAAA==.',
Lu='Ludwigvan:BAAALgAECgkJDgAAAA==.',
No='Nosttum:BAAALgAECgEJAQAAAA==.',
Ri='Righteous:BAAALgAECgYJBgAAAA==.',
Ry='Ryze:BAAALgAECgYJBgAAAA==.',
Sl='Sleeperuid:BAABLgAECn8VAAMHAAcJ0xHRKgCqAQAHAAcJ0xHRKgCqAQAIAAMJ/RDMjQC3AAAAAA==.',
Su='Sunmoonstar:BAAALgAFFAEJAQAAAA==.',
Te='Teacherhao:BAAALgADCgIJAgAAAA==.',
Ti='Timelessly:BAAALgAECgEJAQAAAA==.',
Tr='Transformer:BAAALgAECgMJBAAAAA==.',
Tz='Tzarr:BAAALgAECgIJAgAAAA==.',
We='Weareone:BAAALgAECgYJBgAAAA==.',
Wo='Woangel:BAAALgAECgUJBQAAAA==.',
Yo='Yoinnblood:BAAALgAECgQJBAAAAA==.',
Zi='Ziwi:BAABLgAFFH8HAAIJAAMJGwOhDQC+AAAJAAMJGwOhDQC+AAAAAA==.',
['一枕']='一枕星河:BAAALgADCgYJBgAAAA==.',
['一眼']='一眼之念:BAAALgAECgEJAgAAAA==.',
['一米']='一米阳光:BAAALgADCgEJAQAAAA==.',
['一脉']='一脉相传:BAAALgAECgEJAgAAAA==.',
['一零']='一零二四:BAAALgAECgcJBwAAAA==.',
['七喜']='七喜牛:BAAALgAECgMJAwAAAA==.',
['万花']='万花筒丶:BAAALgAECgIJAwAAAA==.',
['三花']='三花聚顶:BAAALgADCgYJBgAAAA==.',
['上官']='上官静儿:BAABLgAECn8WAAIDAAcJ5yAmNwBaAgADAAcJ5yAmNwBaAgAAAA==.',
['不知']='不知名小陈:BAABLgAFFH8GAAIDAAIJBBWZIgCbAAADAAIJBBWZIgCbAAAAAA==.',
['不要']='不要睡醒:BAACLgAFFH8IAAIFAAMJ5AmcLgD8AAAFAAMJ5AmcLgD8AAAuAAQKfyAAAgUABwlkGUMaAJgBAAUABwlkGUMaAJgBAAEuAAUUBQkLAAoA7g8A.',
['东京']='东京那年不热:BAAALgAECgYJCQAAAA==.',
['东北']='东北仙女:BAAALgADCgUJBQAAAA==.',
['丨原']='丨原丶罪灬:BAAALgAECgEJAQAAAA==.',
['丨郝']='丨郝老师丨:BAABLgAECn8aAAILAAkJkx59BABHAwALAAkJkx59BABHAwABLgAFFAQJDwADAJ0dAA==.',
['丶勇']='丶勇敢的心:BAAALgAECgEJAgAAAA==.',
['丶御']='丶御弟哥哥:BAABLgAFFH8JAAIGAAQJRw5hCgAsAQAGAAQJRw5hCgAsAQAAAA==.',
['丶鸡']='丶鸡蛋:BAAALgAECgcJBwAAAA==.',
['举杯']='举杯望月:BAAALgADCgYJAQAAAA==.',
['乎乎']='乎乎跳:BAAALgAECgkJCgABLgAFFAQJCgALAJgZAA==.',
['乔丶']='乔丶谨记在心:BAABLgAFFH8GAAIMAAUJnxHMAgCfAQAMAAUJnxHMAgCfAQABLgAFFAcJDwANAOsmAA==.',
['乖璐']='乖璐璐:BAAALgAECgEJAwAAAA==.',
['乳白']='乳白的液体:BAAALgAECgMJAwAAAA==.',
['二姐']='二姐:BAACLgAFFH8HAAIDAAQJPQr5GgA4AQADAAQJPQr5GgA4AQAuAAQKfxQAAgMACQneGQEzAGsCAAMACQneGQEzAGsCAAAA.',
['二甩']='二甩肝:BAABLgAECn8UAAIOAAcJ4R0TCQBJAgAOAAcJ4R0TCQBJAgAAAA==.',
['产房']='产房护士长:BAABLgAECn8VAAMPAAYJLw0aDgCuAAAQAAYJEAWPawAIAQAPAAQJ2w4aDgCuAAAAAA==.',
['今早']='今早愿:BAAALgADCgIJAgAAAA==.',
['今晚']='今晚打再弱:BAAALgADCgYJBgABLgAECgMJAwARAAAAAA==.今晚打咾虎:BAAALgAECgMJAwAAAA==.',
['伊莉']='伊莉丹妮:BAAALgAECgEJAgAAAA==.',
['伟少']='伟少:BAAALgAECgEJAQAAAA==.',
['传说']='传说中的拉拉:BAAALgAFFAIJAgAAAA==.',
['传骑']='传骑:BAAALgADCgEJAQAAAA==.',
['伤心']='伤心却在笑:BAAALgADCgEJAQAAAA==.',
['伴随']='伴随:BAAALgADCgcJBwAAAA==.',
['何事']='何事秋风:BAAALgAECgEJAQAAAA==.',
['傲娇']='傲娇:BAAALgAECgUJBQAAAA==.',
['八翼']='八翼:BAAALgADCgMJAwAAAA==.',
['冇丶']='冇丶有:BAAALgAECgYJBgAAAA==.',
['冰凝']='冰凝如雪:BAAALgAFFAIJBAAAAA==.',
['冰火']='冰火魔煞:BAAALgAECgIJAgAAAA==.',
['冰落']='冰落霜破:BAAALgAECgYJBgAAAA==.',
['冷如']='冷如冰寒如雪:BAAALgAECgEJAgABLgAECgYJCQARAAAAAA==.',
['刃海']='刃海:BAAALgAECgMJAwAAAA==.',
['刘子']='刘子夏:BAAALgAECgIJAgAAAA==.',
['刘铁']='刘铁柱:BAAALgAECgEJAQAAAA==.',
['初音']='初音神奶:BAAALgAECgEJAQAAAA==.',
['刺针']='刺针:BAABLgAECn8YAAISAAgJ/R7sDADKAgASAAgJ/R7sDADKAgAAAA==.',
['剑舞']='剑舞霜凝:BAAALgAECgYJEwAAAA==.',
['劍舞']='劍舞霜凝:BAAALgAECgIJAgAAAA==.',
['功夫']='功夫熊宝:BAAALgAECgIJAwAAAA==.',
['动感']='动感大菊花:BAAALgAFFAEJAQAAAA==.',
['北政']='北政所:BAAALgAECgkJAQAAAA==.',
['匚紫']='匚紫灬檀香丨:BAAALgAECgEJAQAAAA==.',
['医生']='医生救我:BAAALgAECgcJEgAAAA==.',
['十七']='十七张牌秒我:BAAALgAECgYJBgAAAA==.',
['十追']='十追风十:BAAALgAECgUJBQAAAA==.',
['半场']='半场开香槟:BAAALgAECgIJAQAAAA==.',
['半城']='半城风雪:BAAALgAECgEJAQAAAA==.',
['半簌']='半簌微風:BAAALgADCgcJBwAAAA==.',
['南宫']='南宫帝凌:BAAALgAECgcJEAAAAA==.',
['南春']='南春香丶:BAAALgAECgMJAgAAAA==.',
['南烛']='南烛:BAAALgADCgUJBQAAAA==.',
['卡卡']='卡卡大帝:BAAALgAECgEJAQAAAA==.',
['叁队']='叁队萨满:BAAALgAECgEJAQAAAA==.',
['双子']='双子的蓝内内:BAABLgAECn8VAAITAAcJJhYyLQDVAQATAAcJJhYyLQDVAQAAAA==.',
['双鱼']='双鱼座丶其其:BAAALgAECgEJAQAAAA==.',
['发光']='发光丶二极管:BAAALgAFFAIJAgAAAA==.发光二极管:BAABLgAFFH8GAAITAAIJIR0EFAC8AAATAAIJIR0EFAC8AAAAAA==.',
['叠甲']='叠甲:BAAALgAECgYJCQABLgAFFAQJCwALALkOAA==.',
['可口']='可口可乐雪碧:BAAALgAECgQJBgAAAA==.',
['可莉']='可莉不知道哟:BAAALgAECgMJAwAAAA==.',
['司马']='司马宣王:BAABLgAECn8WAAIDAAYJixm8bgCsAQADAAYJixm8bgCsAQAAAA==.',
['吃不']='吃不饱的考拉:BAAALgADCgQJAgAAAA==.',
['吃完']='吃完就饿:BAAALgAECgQJBAAAAA==.',
['名剑']='名剑寰宇:BAAALgADCgYJBgAAAA==.',
['呆胶']='呆胶布:BAABLgAFFH8MAAIDAAQJHiaaBwBRAQADAAQJHiaaBwBRAQAAAA==.',
['呼吸']='呼吸武器:BAAALgAECgQJCAAAAA==.',
['和空']='和空气撒个娇:BAAALgAECgEJAQABLgAFFAQJDwADAJ0dAA==.',
['咕咚']='咕咚来了:BAAALgADCgEJAQAAAA==.',
['咕登']='咕登:BAAALgAECgYJCgAAAA==.',
['咱累']='咱累:BAAALgAFFAQJAgAAAA==.',
['咴軚']='咴軚狼:BAAALgAECgQJBAAAAA==.',
['啷个']='啷个嫩个勒个:BAAALgAECgIJAgAAAA==.',
['啷里']='啷里格啷丨:BAAALgAECgkJCAAAAA==.',
['啸苍']='啸苍月:BAAALgAECgQJBAAAAA==.',
['嗜血']='嗜血骑士:BAAALgAECgEJAgAAAA==.',
['嘆息']='嘆息之墙:BAAALgAFFAQJBAAAAA==.',
['嘿嘿']='嘿嘿大魔王:BAAALgAECgUJCAAAAA==.',
['四代']='四代火影:BAABLgAECn8ZAAIUAAkJthM9DQDoAQAUAAkJthM9DQDoAQAAAA==.',
['四叔']='四叔保平安:BAAALgADCgYJBgAAAA==.',
['四手']='四手难敌双拳:BAAALgADCgEJAQAAAA==.',
['回锅']='回锅肉蛋炒饭:BAAALgAECgEJAQAAAA==.',
['国服']='国服第一劣人:BAAALgAECgcJCAAAAA==.国服第一术:BAAALgAECgYJBwAAAA==.国服第一迪凯:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光与黑暗:BAAALgADCgIJAgAAAA==.圣光哑火了:BAAALgAECgQJBQAAAA==.',
['圣地']='圣地蓝雪:BAAALgAECgYJBgAAAA==.',
['堕落']='堕落中的男神:BAAALgAECgQJBAAAAA==.堕落的聖光丶:BAAALgADCgYJBgAAAA==.',
['壹队']='壹队法师:BAAALgAECgcJBwAAAA==.',
['夕阳']='夕阳下的喵:BAAALgADCgEJAQAAAA==.',
['夜幕']='夜幕下的审判:BAAALgAECgcJBgAAAA==.',
['夜空']='夜空丶月影:BAAALgAECgEJAQAAAA==.',
['大唿']='大唿悠:BAAALgAECgYJBwAAAA==.',
['大意']='大意食晶粥:BAAALgAECgYJBgAAAA==.',
['大高']='大高个儿:BAAALgAECgUJBQAAAA==.',
['天上']='天上无双:BAAALgAECgYJBgAAAA==.天上麒麟:BAAALgADCgcJDQAAAA==.',
['天命']='天命挽歌:BAAALgAECgEJAgAAAA==.',
['天威']='天威星:BAAALgAECgYJDAAAAA==.',
['天罡']='天罡星丿:BAAALgAECgQJCwAAAA==.',
['天蝎']='天蝎座丶蛮:BAAALgADCgkJCQAAAA==.',
['天裁']='天裁丿:BAAALgAECgUJBgAAAA==.',
['夸老']='夸老板:BAAALgAECgUJBgABLgAFFAMJCAABAD8cAA==.',
['奔跑']='奔跑的德:BAAALgAECgMJAwAAAA==.',
['奥格']='奥格茶馆:BAAALgAFFAQJBAABLgAECgkJFwAVAMAcAA==.',
['奶啤']='奶啤:BAAALgAECgUJBQAAAA==.',
['如梦']='如梦幻泡影:BAAALgADCgYJBgAAAA==.',
['娃娃']='娃娃教训我:BAAALgAECgUJBQAAAA==.',
['娜娜']='娜娜丽丶:BAAALgAECgEJAQAAAA==.',
['婠婠']='婠婠:BAABLgAECn8YAAILAAcJuxRHGQBWAQALAAcJuxRHGQBWAQAAAA==.',
['孀霏']='孀霏蝶:BAAALgAECgcJCAAAAA==.',
['孙小']='孙小小圣:BAAALgAECgQJBwAAAA==.孙小怡:BAABLgAECn8VAAIIAAcJaRY1NgDPAQAIAAcJaRY1NgDPAQAAAA==.',
['孤星']='孤星月儿:BAAALgAECgMJAwAAAA==.',
['宁姚']='宁姚丶:BAAALgAFFAQJBAAAAA==.',
['安灬']='安灬牙膏:BAAALgAFFAEJAgAAAA==.',
['安眠']='安眠羊:BAACLgAFFH8PAAIIAAQJohqIBwBaAQAIAAQJohqIBwBaAQAuAAQKfxYAAggACQkXGlkUAJMCAAgACQkXGlkUAJMCAAAA.',
['宝贝']='宝贝别闹闹:BAACLgAFFH8FAAIBAAQJygNBIQD/AAABAAQJygNBIQD/AAAuAAQKfxQAAwEABwkmFk1gAKgBAAEABgkmFk1gAKgBAAIAAQkAAGxwADYAAAAA.',
['将军']='将军饮马:BAAALgAECgMJAwAAAA==.',
['小公']='小公鸡:BAAALgADCgUJBQAAAA==.',
['小兵']='小兵不感冒:BAAALgADCgEJAQAAAA==.',
['小小']='小小任性:BAAALgADCgEJAQAAAA==.小小的悲伤:BAAALgAECgUJBgAAAA==.',
['小法']='小法老歌歌:BAAALgADCgYJBgAAAA==.',
['小秘']='小秘:BAAALgAECgcJEAAAAA==.',
['小领']='小领主丨:BAAALgAECgMJAwAAAA==.',
['小鹿']='小鹿撒欢:BAAALgADCgIJAgAAAA==.',
['尘之']='尘之沙:BAABLgAECn8cAAIFAAYJhhiSlQCpAQAFAAYJhhiSlQCpAQAAAA==.',
['岚大']='岚大裳:BAAALgAECgQJBAAAAA==.',
['巴尔']='巴尔扎克:BAAALgAECgUJBQAAAA==.',
['希哒']='希哒:BAAALgAECgEJAgAAAA==.',
['希里']='希里:BAAALgADCgEJAQAAAA==.',
['幺零']='幺零零捌六:BAAALgAECgYJCwAAAA==.',
['幻舞']='幻舞宝宝:BAAALgADCgcJBwAAAA==.',
['幽閉']='幽閉遮蘭:BAAALgADCgYJBgAAAA==.',
['弗糯']='弗糯糯:BAAALgAECgMJAwAAAA==.',
['强力']='强力输出的祸:BAAALgADCgEJAQAAAA==.',
['彪僧']='彪僧:BAAALgADCgEJAQAAAA==.',
['後天']='後天:BAAALgAECgcJAwAAAA==.後天丿:BAAALgAECgYJBgAAAA==.',
['後尘']='後尘:BAAALgAECgYJCwAAAA==.',
['後盾']='後盾:BAAALgAFFAIJAgAAAA==.',
['德古']='德古拉公爵:BAAALgADCgIJAgAAAA==.',
['心念']='心念起动之间:BAAALgAECgIJAgAAAA==.',
['心有']='心有千千欲:BAAALgAECgMJAwAAAA==.',
['思恋']='思恋太猖狂:BAAALgAECgMJAwAAAA==.',
['恶毒']='恶毒奶爸:BAAALgAECgQJBwAAAA==.',
['恶魔']='恶魔军团首领:BAAALgADCgEJAQAAAA==.',
['惊鸿']='惊鸿踏影:BAAALgAECgQJBgAAAA==.',
['愛摯']='愛摯:BAAALgADCgQJBAAAAA==.',
['愤怒']='愤怒的牛排:BAAALgAECgMJAwAAAA==.',
['我不']='我不会奶:BAAALgADCgUJBAAAAA==.',
['我哒']='我哒嗒达:BAAALgAECgQJBQAAAA==.',
['我烫']='我烫死你:BAABLgAECn8UAAIFAAYJCB/ogQDNAQAFAAYJCB/ogQDNAQAAAA==.',
['战丶']='战丶风云:BAAALgADCgYJBgAAAA==.',
['战殇']='战殇小曦:BAACLgAFFH8LAAILAAQJuQ5xBQBNAQALAAQJuQ5xBQBNAQAuAAQKfx4ABAsACQl2H10EAEkDAAsACQl2H10EAEkDABYABAmECHBeAMcAABcAAwmJDOEiALoAAAAA.',
['承天']='承天之德:BAAALgAFFAMJBAAAAA==.',
['把我']='把我腿分开:BAAALgAECgUJBQAAAA==.',
['指引']='指引:BAABLgAFFH8NAAMLAAQJBxIdBQBJAQALAAQJ/Q8dBQBJAQAWAAIJgxQwHQChAAAAAA==.',
['捋你']='捋你命:BAAALgAECggJCQAAAA==.',
['搖曳']='搖曳滴靈魂:BAAALgAECgYJEgAAAA==.',
['摘星']='摘星:BAAALgAFFAIJAgAAAA==.',
['文腥']='文腥第十:BAAALgAECgEJAQAAAA==.',
['新鲜']='新鲜鱼子酱:BAAALgAECgYJCQAAAA==.',
['无情']='无情之德:BAAALgAECgEJAQAAAA==.',
['无聊']='无聊的妖妖丶:BAAALgAECgQJBgAAAA==.',
['时尚']='时尚古典:BAAALgAECgMJAwAAAA==.时尚金典:BAAALgAECgEJAQAAAA==.',
['时节']='时节不居:BAABLgAECn8fAAQQAAgJvB4lDQDtAgAQAAgJvB4lDQDtAgAPAAEJRByFNgBWAAAVAAEJWgO9SwAlAAAAAA==.',
['时间']='时间回忆:BAAALgAFFAQJBAAAAA==.',
['旺晓']='旺晓财嘿嘿:BAABLgAFFH8GAAIYAAIJgANeIQBrAAAYAAIJgANeIQBrAAAAAA==.',
['春丽']='春丽风暴列酒:BAAALgADCgIJAgAAAA==.',
['暗影']='暗影大姐:BAAALgAECgEJAQAAAA==.',
['最佳']='最佳攝影師:BAAALgAECgIJAgAAAA==.',
['最初']='最初:BAACLgAFFH8IAAIDAAQJgRYkBwBUAQADAAQJgRYkBwBUAQAuAAQKfxoAAgMACQnGHMocANICAAMACQnGHMocANICAAEuAAUUBAkPAAMAnR0A.最初啊:BAABLgAFFH8HAAIDAAQJZhCaGABCAQADAAQJZhCaGABCAQAAAA==.',
['月与']='月与海丶:BAAALgADCgkJCQAAAA==.',
['木槿']='木槿花:BAAALgAFFAQJBAAAAA==.',
['未满']='未满十八岁:BAAALgAECgkJDgABLgAFFAQJDwADAJ0dAA==.',
['末日']='末日乌伤:BAAALgAECgEJAQABLgAFFAYJBAARAAAAAA==.',
['杀羊']='杀羊安眠系列:BAAALgAECggJDgAAAA==.',
['李一']='李一禾:BAAALgAECgUJCQAAAA==.',
['李嘉']='李嘉格:BAAALgADCgEJAQAAAA==.',
['杨提']='杨提子:BAAALgADCgMJAwAAAA==.',
['极度']='极度狡猾分子:BAAALgAECgYJBwAAAA==.',
['林恩']='林恩恩:BAAALgAECgEJAQAAAA==.',
['枪枪']='枪枪小猫:BAAALgAECgYJBgAAAA==.枪枪小鱼:BAAALgAECgEJAQAAAA==.',
['柳茹']='柳茹妍:BAAALgADCgEJAQAAAA==.',
['格老']='格老子好凶:BAAALgADCgQJAwAAAA==.',
['桀洛']='桀洛特:BAAALgADCgUJBQAAAA==.',
['梦之']='梦之灬嫵:BAAALgAECgEJAQAAAA==.',
['梦莱']='梦莱:BAAALgADCgUJBQAAAA==.',
['森叶']='森叶林:BAAALgAECgUJCwAAAA==.',
['死掉']='死掉的骑士:BAAALgAECggJBgAAAA==.',
['残剑']='残剑快马:BAAALgAECgEJAgAAAA==.',
['残灵']='残灵暗弓:BAAALgAECgYJDAAAAA==.',
['残缺']='残缺的执着:BAAALgAECgUJBgAAAA==.',
['段祺']='段祺瑞:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛萨:BAAALgAECgUJCAAAAA==.',
['水煮']='水煮牛肉丶:BAABLgAFFH8FAAIDAAIJKgvlRACaAAADAAIJKgvlRACaAAAAAA==.水煮白菜:BAAALgAECgUJCAAAAA==.',
['水蒙']='水蒙蒙:BAAALgAECgcJCwAAAA==.',
['江流']='江流子:BAACLgAFFH8FAAMZAAIJVxNxEgCaAAAZAAIJVxNxEgCaAAAJAAEJdwqgFgBOAAAuAAQKfxcABBoABwkdFhoQANoBABoABwnmFRoQANoBABkABgmeELsgAHcBAAkABgn6ES4xAD0BAAAA.',
['泡芙']='泡芙熙熙:BAAALgAFFAEJAQAAAA==.',
['注意']='注意冲击波:BAAALgAECgYJBgAAAA==.',
['洛楚']='洛楚三千:BAAALgADCgEJAQAAAA==.',
['洛霞']='洛霞:BAAALgAFFAMJBAAAAA==.',
['洪兴']='洪兴丶乌鸦:BAAALgAECgIJAgAAAA==.洪兴丶泰子:BAAALgAECgEJAQAAAA==.洪兴丶骆驼:BAAALgAECgIJAgAAAA==.',
['浅梦']='浅梦丶星河:BAAALgAECgYJAgAAAA==.',
['浑天']='浑天象:BAAALgAFFAQJBAABLgAFFAYJEgAJAKAgAA==.',
['浪蹄']='浪蹄小九:BAABLgAECn8XAAIUAAYJoSN+LABxAgAUAAYJoSN+LABxAgAAAA==.',
['海南']='海南希某某:BAAALgAECgQJBAAAAA==.',
['海派']='海派甜心:BAAALgAECgQJAwAAAA==.',
['海雾']='海雾残阳:BAAALgAECgEJAQAAAA==.',
['涛尛']='涛尛絔:BAAALgAECgEJAgAAAA==.',
['涵涵']='涵涵屁屁:BAAALgAECgIJAgAAAA==.',
['淀淀']='淀淀:BAAALgADCgYJBgAAAA==.',
['淡梦']='淡梦芸海:BAAALgADCgEJAQAAAA==.',
['清澈']='清澈的风:BAAALgAECgcJBgAAAA==.',
['清风']='清风兑酒:BAAALgAECgEJAgAAAA==.',
['漂泊']='漂泊的木头:BAAALgAECgkJEAAAAA==.',
['潘爷']='潘爷:BAAALgAECgIJAgAAAA==.',
['火云']='火云:BAAALgAECgIJAwAAAA==.',
['灬歡']='灬歡歡:BAAALgAECgMJBAAAAA==.',
['灰之']='灰之伊雷娜:BAAALgAECgYJBgAAAA==.',
['炽热']='炽热烙印:BAAALgAECgEJAwAAAA==.',
['烂账']='烂账:BAAALgAECgMJAwAAAA==.',
['烈火']='烈火胸心:BAAALgADCgIJAgAAAA==.',
['烟雨']='烟雨清尘:BAABLgAECn8WAAIEAAcJgxveEgBBAgAEAAcJgxveEgBBAgAAAA==.',
['烧烤']='烧烤布丁:BAAALgAECgUJBQAAAA==.',
['焦糖']='焦糖瓜子:BAAALgAFFAIJBAAAAA==.',
['然丶']='然丶:BAABLgAFFH8FAAIUAAMJACMyEAAlAQAUAAMJACMyEAAlAQAAAA==.',
['然丿']='然丿:BAAALgAECgYJBgAAAA==.',
['煙雨']='煙雨墨色:BAABLgAECn8UAAIKAAYJEA37JAAXAQAKAAYJEA37JAAXAQAAAA==.',
['熵增']='熵增:BAAALgAECgYJAwAAAA==.',
['燕云']='燕云十六声:BAABLgAECn8WAAIFAAgJlRUuXgAgAgAFAAgJlRUuXgAgAgAAAA==.',
['燕宝']='燕宝:BAABLgAECn8UAAIDAAkJ3xyLPgA9AgADAAkJ3xyLPgA9AgAAAA==.',
['独醉']='独醉天涯:BAAALgAFFAEJAQAAAA==.',
['猎手']='猎手孤狼:BAAALgADCgcJCgAAAA==.',
['猥盟']='猥盟先生:BAAALgADCgEJAQAAAA==.',
['猪肉']='猪肉小丸子丶:BAABLgAECn8VAAIGAAcJLRwRKwBUAgAGAAcJLRwRKwBUAgAAAA==.',
['猫猫']='猫猫灬冬眠中:BAAALgAECgYJBgAAAA==.',
['玛嘉']='玛嘉烈临光:BAAALgAECgYJCQAAAA==.',
['玛塔']='玛塔塔:BAAALgADCgEJAQAAAA==.',
['珍欢']='珍欢喜:BAAALgAECgEJAQAAAA==.',
['瘦瘦']='瘦瘦的胖纸:BAAALgAECgQJBQAAAA==.',
['白灬']='白灬浅:BAAALgADCgcJDAAAAA==.',
['白色']='白色奶牛:BAAALgADCgIJAgABLgAECgEJAQARAAAAAA==.',
['白骑']='白骑祸灵梦:BAABLgAECn8cAAIUAAgJnyI9DAAsAwAUAAgJnyI9DAAsAwAAAA==.',
['盈星']='盈星辰:BAAALgAECgUJBQAAAA==.',
['碎影']='碎影:BAACLgAFFH8PAAIbAAQJvgyOAgDsAAAbAAQJvgyOAgDsAAAuAAQKfyEAAhsACQnLGtADAMcCABsACQnLGtADAMcCAAAA.',
['神箭']='神箭手鹰眼:BAAALgAECgMJAwAAAA==.',
['秋叙']='秋叙:BAAALgAECgMJAwAAAA==.',
['秋风']='秋风潇潇:BAAALgAECgMJAwAAAA==.',
['秒你']='秒你不为奇:BAAALgAECgUJDgAAAA==.',
['糖寶']='糖寶兒:BAAALgAECgMJAwAAAA==.',
['糖醋']='糖醋灬叮叮猫:BAAALgAECgMJAwAAAA==.',
['紧到']='紧到扯:BAAALgADCgYJBgAAAA==.',
['纯阳']='纯阳上人:BAAALgAECgYJBQAAAA==.',
['美丽']='美丽的妖妖:BAAALgAECgcJCAAAAA==.',
['美女']='美女姐姐:BAABLgAECn8WAAMMAAYJFBP1KABPAQAMAAYJ+A71KABPAQANAAMJmws2aACMAAAAAA==.',
['美德']='美德:BAAALgADCgYJBgAAAA==.',
['老兵']='老兵曼巴烧烤:BAABLgAFFH8NAAIZAAUJ1yPVAQAWAgAZAAUJ1yPVAQAWAgAAAA==.',
['聂三']='聂三娘:BAAALgAECgQJBQAAAA==.',
['肉盾']='肉盾小呆:BAAALgADCgcJBwAAAA==.',
['肚肚']='肚肚里有酒:BAAALgAECgMJAwAAAA==.',
['胖坨']='胖坨儿:BAAALgAECgEJAQAAAA==.',
['自由']='自由灬女神:BAAALgAECgUJBwAAAA==.',
['艳艳']='艳艳宝宝:BAABLgAFFH8IAAIDAAMJSyB7IgANAQADAAMJSyB7IgANAQAAAA==.',
['艾尔']='艾尔多的守卫:BAAALgADCgYJBgABLgAFFAQJCwALALkOAA==.',
['艾林']='艾林:BAAALgAECgYJAQAAAA==.',
['芙兰']='芙兰瑟尔:BAAALgAECgQJAQAAAA==.',
['芝麻']='芝麻丶:BAABLgAFFH8FAAMWAAIJMBgqGwCrAAAXAAIJFQtZBgCuAAAWAAIJMBgqGwCrAAAAAA==.',
['花心']='花心居念情:BAAALgAECgcJCQAAAA==.花心居情如梦:BAAALgAECgIJAgAAAA==.',
['苏情']='苏情:BAAALgAECgYJBgAAAA==.',
['苏麻']='苏麻:BAABLgAECn8UAAQTAAYJqwqxGwD2AAATAAYJqwqxGwD2AAAOAAEJ0QG6LwAlAAAcAAEJYAD3lwAVAAAAAA==.',
['莎夏']='莎夏:BAAALgAECgEJAgAAAA==.',
['莫宁']='莫宁:BAACLgAFFH8MAAIFAAQJmxoiFgBxAQAFAAQJmxoiFgBxAQAuAAQKfxkAAgUACAlfJCwUAC8DAAUACAlfJCwUAC8DAAAA.',
['莫尚']='莫尚鑫:BAABLgAECn8UAAIIAAYJZRqjEQBzAQAIAAYJZRqjEQBzAQAAAA==.',
['莱菔']='莱菔子:BAAALgAECgYJCQAAAA==.',
['萊爾']='萊爾斯昂:BAAALgAECgQJBAAAAA==.',
['萌萌']='萌萌小烧饼:BAAALgAECgcJCQAAAA==.',
['萝卜']='萝卜史塔克:BAAALgAECgQJBAAAAA==.',
['落日']='落日:BAAALgAECgQJAwAAAA==.',
['葉關']='葉關山:BAAALgAECgkJCQAAAA==.',
['蓝枫']='蓝枫叶:BAAALgAECgEJAgAAAA==.',
['薇薇']='薇薇悍妻:BAAALgAECgcJDwAAAA==.',
['蜜糖']='蜜糖兔子:BAAALgAECgEJAQAAAA==.',
['蠢卫']='蠢卫星:BAAALgAFFAIJAgAAAA==.',
['觉灵']='觉灵:BAAALgAECgYJCwAAAA==.',
['言丶']='言丶:BAAALgAECgcJDQAAAA==.',
['语过']='语过添情丶:BAAALgAFFAIJAwAAAA==.',
['谢谢']='谢谢你的帮助:BAAALgAECgEJAQAAAA==.',
['贫僧']='贫僧法号瞎子:BAAALgAECgYJCwAAAA==.',
['赛瓜']='赛瓜小法:BAAALgAECgYJEgAAAA==.',
['起司']='起司短短:BAAALgADCgEJAQAAAA==.',
['超大']='超大硅胶:BAABLgAECn8VAAIUAAcJuR6CLQBtAgAUAAcJuR6CLQBtAgAAAA==.',
['踢哎']='踢哎克硬:BAAALgAECgMJBAAAAA==.',
['软饭']='软饭硬吃:BAAALgAECgYJBgAAAA==.',
['轰隆']='轰隆轰隆:BAAALgAECgYJBwAAAA==.',
['还你']='还你漂亮拳:BAAALgAECgEJAQAAAA==.',
['远在']='远在天边:BAAALgAECgQJBgAAAA==.',
['违法']='违法昵称:BAAALgAECgIJAgABLgAFFAQJDwADAJ0dAA==.',
['迷之']='迷之自信:BAAALgAECgcJCAAAAA==.',
['迷茫']='迷茫芃渝燕:BAAALgAECgEJAQAAAA==.',
['追尾']='追尾巴的猫:BAAALgADCgEJAQAAAA==.',
['追着']='追着你打:BAAALgAECgYJCwAAAA==.',
['邪血']='邪血染冰锋:BAABLgAECn8UAAIDAAcJsQWINwDOAAADAAcJsQWINwDOAAAAAA==.',
['银色']='银色黑夜之梦:BAAALgAECgUJCQAAAA==.',
['锐萌']='锐萌萌:BAABLgAFFH8MAAIDAAQJ8hNmCABKAQADAAQJ8hNmCABKAQABLgAFFAQJDwADAJ0dAA==.',
['锡耶']='锡耶纳:BAAALgAFFAIJBAAAAA==.',
['门清']='门清另糊葱:BAAALgAECgIJAgAAAA==.',
['闪电']='闪电微辣:BAAALgAECgUJBgAAAA==.',
['闺公']='闺公:BAABLgAECn8aAAIWAAcJgR+WGQBaAgAWAAcJgR+WGQBaAgAAAA==.',
['闻人']='闻人牧月:BAAALgAFFAIJAgAAAA==.',
['阳光']='阳光大白马:BAAALgAECgUJBgAAAA==.',
['阿丽']='阿丽狄娜:BAAALgAECgkJCQAAAA==.',
['阿尔']='阿尔塞斯丶:BAABLgAFFH8LAAIDAAQJoRSVFgBKAQADAAQJoRSVFgBKAQABLgAFFAQJDwADAJ0dAA==.',
['阿尤']='阿尤里尔斯:BAAALgADCgUJBQAAAA==.',
['阿帕']='阿帕吉:BAABLgAECn8WAAIFAAcJKgq8wgBgAQAFAAcJKgq8wgBgAQAAAA==.',
['阿鱼']='阿鱼儿:BAAALgAECgQJBQAAAA==.',
['陈平']='陈平安丶:BAAALgAFFAMJAwAAAA==.陈平安啊:BAAALgAECgcJCgAAAA==.陈平安安:BAAALgAFFAIJAgAAAA==.',
['陌谨']='陌谨年:BAAALgAECgEJAQAAAA==.',
['陰影']='陰影中演舞:BAAALgADCgEJAQAAAA==.',
['雅哥']='雅哥:BAAALgAECgEJAQAAAA==.',
['雷欢']='雷欢:BAAALgAECgcJBwAAAA==.',
['青丝']='青丝悠悠:BAAALgAECgEJAQAAAA==.',
['非仙']='非仙:BAAALgAECgYJBwAAAA==.',
['非法']='非法插入:BAAALgAECgUJCwAAAA==.非法集资:BAAALgAECgQJBQAAAA==.',
['颠覆']='颠覆儱行澐:BAAALgAECgEJAQAAAA==.',
['風公']='風公爵:BAAALgAECgEJAQAAAA==.',
['风一']='风一样的咆嚣:BAAALgAECgcJDAAAAA==.',
['风中']='风中散发灬:BAAALgAECgcJEgAAAA==.',
['风公']='风公爵:BAAALgAECgEJAQAAAA==.',
['风花']='风花十月红:BAAALgADCgUJBQAAAA==.',
['风见']='风见幽紫:BAAALgADCgcJBwAAAA==.',
['飒鳗']='飒鳗:BAAALgAECgYJCQAAAA==.',
['飘扬']='飘扬的秀发:BAAALgAFFAEJAgAAAA==.',
['香酥']='香酥黑豆:BAABLgAFFH8FAAIdAAUJxQnhAwBbAQAdAAUJxQnhAwBbAQAAAA==.',
['骑高']='骑高高:BAAALgAECgMJAwAAAA==.',
['高启']='高启牧加强版:BAAALgAECgYJCQAAAA==.',
['鬼佳']='鬼佳静:BAACLgAFFH8FAAIMAAMJohrXBwD5AAAMAAMJohrXBwD5AAAuAAQKfxoAAwwABwl6IEgLAIMCAAwABwl6IEgLAIMCAB4ABAlkFaI7ABYBAAAA.',
['鬼冢']='鬼冢静:BAABLgAECn8WAAILAAcJ5gjbVgBkAQALAAcJ5gjbVgBkAQAAAA==.',
['魔之']='魔之煞:BAAALgAECgEJAQAAAA==.',
['魔兽']='魔兽老兵:BAAALgADCgMJAwAAAA==.',
['鸡腿']='鸡腿小笼包:BAAALgAECgkJAQAAAA==.',
['麻油']='麻油仙贝:BAAALgAECgQJBwAAAA==.',
['麻薯']='麻薯你坐下吃:BAAALgAFFAIJAgAAAA==.',
['黄子']='黄子韬:BAAALgAECgEJAQAAAA==.',
['黄渤']='黄渤:BAAALgAECgEJAQAAAA==.',
['黑夜']='黑夜独舞:BAAALgAECgMJAwAAAA==.',
['黑天']='黑天赤炎:BAAALgAECgcJCwAAAA==.',
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
