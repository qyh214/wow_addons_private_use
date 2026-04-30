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

local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Priest-Shadow','Druid-Restoration','Hunter-BeastMastery','Paladin-Retribution','Priest-Discipline','Priest-Holy','Hunter-Marksmanship','Mage-Frost','Monk-Brewmaster','Hunter-Survival','DemonHunter-Devourer','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Shaman-Restoration','Evoker-Preservation','Druid-Balance','Shaman-Elemental',}
local provider = {region='CN',realm='自由之风',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abysstoller:BAAALgAECgIJAgAAAA==.',
Al='Allanpoe:BAAALgADCgMJAwAAAA==.',
Am='Amaryllisa:BAABLgAFFH8FAAMBAAUJAyJvBwCVAQABAAQJAyJvBwCVAQACAAEJAAC+EABrAAAAAA==.',
Bl='Blackmanba:BAAALgAFFAQJBAAAAA==.Blackshadow:BAAALgADCgEJAQAAAA==.Blameuncle:BAAALgAECgUJBQAAAA==.',
Br='Brokenkite:BAAALgAECgEJAQABLgAECgIJAgADAAAAAA==.',
Ca='Cababa:BAAALgADCgYJBgABLgAFFAQJDgAEAMgZAA==.',
Da='Dayanjing:BAAALgADCgUJBQAAAA==.',
Dy='Dysprist:BAAALgADCgYJBwABLgAFFAQJDAAFAFokAA==.',
Em='Emno:BAAALgAECgYJCQAAAA==.',
Es='Essementhol:BAAALgAECgQJBwAAAA==.',
Ev='Evilknight:BAAALgADCgUJBQAAAA==.',
Fa='Fallenarcher:BAABLgAECn8UAAIGAAcJhxfzNgDTAQAGAAcJhxfzNgDTAQAAAA==.',
Ga='Galatea:BAAALgAECgYJCgAAAA==.',
Hi='Highlord:BAAALgAECgQJAwAAAA==.',
Li='Link:BAAALgAECgEJAQAAAA==.Lirak:BAAALgAECgIJAwABLgAFFAIJAgADAAAAAA==.',
Lo='Loop:BAAALgAECgQJBwAAAA==.',
Lu='Lucifinilau:BAAALgAECgEJAQAAAA==.',
Me='Mess:BAAALgAECgYJCgAAAA==.',
Mi='Minecraft:BAAALgAFFAIJAgAAAA==.',
['Mó']='Móriv:BAAALgAECgQJBQABLgAFFAIJAgADAAAAAA==.',
Oi='Oihannelys:BAAALgAFFAIJAgAAAA==.',
Op='Oppugno:BAAALgAECgIJAgAAAA==.',
Pa='Panini:BAAALgAECgQJBAABLgAFFAQJDQABAMohAA==.',
Se='Seschenat:BAAALgAECgUJBwABLgAFFAIJAgADAAAAAA==.',
St='Strank:BAAALgAECgcJBAAAAA==.',
To='Toot:BAAALgAECgYJBgAAAA==.',
Tu='Turnss:BAAALgAECgYJBgAAAA==.',
Yo='Yomi:BAAALgADCgIJAgAAAA==.',
['一刀']='一刀水:BAAALgADCgUJBQAAAA==.',
['七八']='七八酒:BAAALgADCgUJBQAAAA==.',
['万兽']='万兽无疆丶:BAAALgAECgQJBAAAAA==.',
['专杀']='专杀泪:BAAALgADCggJCAAAAA==.',
['且听']='且听風吟:BAAALgAECgUJBwAAAA==.',
['且聽']='且聽風吟:BAAALgAECgkJDQABLgAFFAUJCQAHAJAWAA==.',
['东海']='东海边的夏夏:BAAALgAECgEJAQAAAA==.东海边的小君:BAAALgAECgQJCwAAAA==.',
['丶淡']='丶淡然先生:BAAALgADCgIJAgAAAA==.',
['丶溜']='丶溜溜:BAACLgAFFH8OAAMEAAQJyBnQBQBsAQAEAAQJyBnQBQBsAQAIAAQJkw29BQA7AQAuAAQKfxsABAQABwlFJecJAOUCAAQABwlFJecJAOUCAAkAAgl6BqFzAFkAAAgAAQnBGGcbAEsAAAAA.',
['义肢']='义肢独秀:BAAALgAECgYJBgAAAA==.',
['乌瑞']='乌瑞亚:BAAALgAECgIJAgABLgAFFAQJDgAKAKgSAA==.',
['九妄']='九妄:BAAALgADCgYJBgAAAA==.',
['予新']='予新:BAAALgAECgYJBQAAAA==.',
['五杀']='五杀键盘手:BAAALgADCgEJAQAAAA==.',
['什么']='什么东西:BAAALgAECgYJBgAAAA==.',
['伤害']='伤害不高:BAAALgAECgMJBAAAAA==.',
['余烬']='余烬:BAAALgAFFAQJBAAAAA==.',
['依德']='依德服人:BAAALgAECgEJAgAAAA==.',
['信仰']='信仰飛跃:BAABLgAECn8eAAIIAAkJqBM5BAAKAgAIAAkJqBM5BAAKAgAAAA==.',
['偶像']='偶像大偿茎:BAAALgAECgEJAQAAAA==.',
['六月']='六月花开:BAAALgAECgIJAwAAAA==.',
['内永']='内永枝利:BAAALgAFFAEJAQAAAA==.',
['冥灯']='冥灯龙:BAAALgAECgkJCQAAAA==.',
['凉清']='凉清甘白:BAAALgADCgIJAgAAAA==.',
['加尔']='加尔弗雷德:BAAALgAECgMJBQAAAA==.',
['加百']='加百列:BAAALgAECgEJAQAAAA==.',
['十万']='十万伏特:BAAALgAECgcJDgAAAA==.',
['半夏']='半夏曲:BAAALgAECgcJAQABLgAFFAUJEQAEAIwhAA==.',
['受命']='受命于天:BAACLgAFFH8GAAIIAAMJyQ1zDgDmAAAIAAMJyQ1zDgDmAAAuAAQKfxkAAggABwmTHRkOAFgCAAgABwmTHRkOAFgCAAAA.',
['吉澤']='吉澤詺鸔:BAAALgAECgEJAgAAAA==.',
['呜喵']='呜喵王丷:BAAALgADCgEJAQAAAA==.',
['呼啸']='呼啸山庄:BAABLgAECn8VAAILAAcJnBkxlQCpAQALAAcJnBkxlQCpAQAAAA==.',
['哈喽']='哈喽天启:BAAALgADCgQJCgAAAA==.',
['哎哟']='哎哟哎哟喂:BAAALgAECgEJAQAAAA==.',
['商羽']='商羽:BAAALgAECgEJAgAAAA==.',
['善恶']='善恶有报:BAAALgAECgcJAQABLgAFFAYJBAADAAAAAA==.',
['嘤嘤']='嘤嘤阿花丶:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光力量:BAAALgADCgUJBQAAAA==.圣光小奶骑:BAAALgAECgEJAQAAAA==.圣光弗丁:BAAALgAFFAEJAQAAAA==.圣光酱油嚓:BAAALgAECgEJAQAAAA==.',
['圣殿']='圣殿骑士:BAAALgADCgEJAQAAAA==.',
['墨香']='墨香哭乱冢:BAAALgAECgEJAQAAAA==.',
['夏熠']='夏熠森丶:BAAALgAECgIJAgAAAA==.',
['夜无']='夜无痕:BAAALgADCgEJAQAAAA==.',
['夜枫']='夜枫丶:BAAALgAECgQJBAAAAA==.',
['大哥']='大哥推背么:BAAALgAECgEJAQAAAA==.',
['大头']='大头东:BAABLgAECn8ZAAIBAAkJ1iA2BQCBAwABAAkJ1iA2BQCBAwABLgAECgkJHwABAHwjAA==.大头东东:BAABLgAECn8WAAIBAAkJdyG+BACHAwABAAkJdyG+BACHAwABLgAECgkJHwABAHwjAA==.大头东已:BAAALgAECgcJBwABLgAECgkJHwABAHwjAA==.',
['大饼']='大饼派:BAABLgAFFH8FAAIMAAMJxxZvEQDxAAAMAAMJxxZvEQDxAAAAAA==.',
['天启']='天启贺南:BAAALgADCgUJCAAAAA==.',
['天起']='天起:BAAALgADCgEJAQAAAA==.',
['天道']='天道萌叔叔:BAAALgAECgYJDwAAAA==.',
['夸夸']='夸夸绵绵:BAABLgAFFH8KAAIEAAQJWx14BQB1AQAEAAQJWx14BQB1AQAAAA==.',
['奶油']='奶油小丸子:BAAALgAECgcJCgAAAA==.奶油肉丸:BAAALgADCgEJAQAAAA==.',
['她的']='她的睫毛味:BAAALgADCgUJBQAAAA==.',
['好名']='好名让猫取了:BAAALgADCgEJAQAAAA==.',
['如臻']='如臻至极:BAAALgAECgQJBQAAAA==.',
['寒冰']='寒冰之羽:BAAALgADCgEJAQAAAA==.',
['寒霜']='寒霜之耀:BAAALgADCgEJAQAAAA==.',
['小头']='小头东:BAAALgAECggJCwABLgAECgkJHwABAHwjAA==.小头东东:BAABLgAECn8fAAIBAAkJfCNbBACPAwABAAkJfCNbBACPAwAAAA==.',
['小心']='小心你兜兜:BAAALgAECgMJAwAAAA==.',
['小魚']='小魚:BAAALgAECgQJBAAAAA==.',
['小鸡']='小鸡腻:BAAALgAECgYJDwAAAA==.',
['巴哈']='巴哈姆特:BAAALgAFFAIJAwAAAA==.',
['巴林']='巴林:BAAALgAECgYJEgABLgAFFAIJAgADAAAAAA==.',
['巴诺']='巴诺克:BAAALgAECgQJBAAAAA==.',
['希尔']='希尔瓦纳缌:BAAALgAFFAMJBAAAAA==.',
['带头']='带头大哥:BAAALgAECgIJAwAAAA==.',
['幻灵']='幻灵猫儿:BAAALgADCgUJBQAAAA==.',
['异灵']='异灵:BAAALgAECgEJAQAAAA==.',
['强无']='强无敌:BAAALgADCgEJAQAAAA==.',
['影团']='影团团:BAAALgAECgYJCAAAAA==.',
['微风']='微风细语:BAAALgAFFAEJAQAAAA==.',
['德尼']='德尼姆:BAAALgADCgUJBQAAAA==.',
['心的']='心的冬眠:BAABLgAFFH8FAAILAAUJxwAQHwC5AAALAAUJxwAQHwC5AAAAAA==.',
['心随']='心随明月:BAAALgAECgEJAgAAAA==.',
['必爷']='必爷:BAAALgAFFAEJAQAAAA==.',
['忌霞']='忌霞伤:BAABLgAFFH8NAAQGAAQJSgxlDgDcAAANAAMJ+gdPBAD0AAAGAAMJaQplDgDcAAAKAAIJbQbbIQCGAAAAAA==.',
['思思']='思思韵韵:BAAALgAECgYJBgAAAA==.',
['怨虎']='怨虎龙:BAAALgAECgcJBQAAAA==.',
['懒懒']='懒懒小虫:BAAALgAECgcJAQAAAA==.',
['懦夫']='懦夫救星:BAAALgAFFAEJAQAAAA==.',
['我不']='我不是王宝:BAAALgAECgUJCQAAAA==.',
['我代']='我代表联盟:BAAALgAECgcJEgAAAA==.',
['所念']='所念皆星河:BAAALgAECgYJBgAAAA==.',
['抄了']='抄了暴血:BAAALgAECgMJAwAAAA==.',
['拉克']='拉克丝:BAAALgADCgEJAQAAAA==.',
['摸鱼']='摸鱼鱼:BAAALgADCgUJBQAAAA==.',
['文文']='文文卫:BAAALgAECgYJBwAAAA==.',
['方南']='方南的丽美:BAACLgAFFH8KAAIOAAMJmxAOEQDuAAAOAAMJmxAOEQDuAAAuAAQKfxgAAg4ACAlYF+RBAOwBAA4ACAlYF+RBAOwBAAAA.',
['旋转']='旋转我闭着眼:BAAALgAECgQJBAAAAA==.',
['无敌']='无敌最俊朗:BAAALgAECgYJAwABLgAFFAUJAQADAAAAAA==.',
['无极']='无极仙道:BAACLgAFFH8JAAICAAMJaBYkBgDfAAACAAMJaBYkBgDfAAAuAAQKfxoAAgIACAmYGAIUAM8BAAIACAmYGAIUAM8BAAAA.无极论仙道:BAAALgAECgQJBAAAAA==.',
['星光']='星光鱼文波:BAAALgAECgEJAQAAAA==.',
['星月']='星月落:BAAALgAECgYJBgAAAA==.',
['是个']='是个法師:BAAALgAECgYJBwAAAA==.',
['晓好']='晓好比:BAAALgADCgEJAQAAAA==.',
['曼音']='曼音天籁:BAAALgAECgQJBQABLgAFFAQJBAADAAAAAA==.',
['月下']='月下狼入:BAAALgAECgEJAQAAAA==.',
['月影']='月影织渊:BAAALgAECgUJBwAAAA==.',
['未来']='未来那么远:BAAALgADCgcJDAAAAA==.',
['术宝']='术宝宝丶:BAACLgAFFH8IAAIPAAQJ0wtYFgA8AQAPAAQJ0wtYFgA8AQAuAAQKfyMABA8ACAn3Hu4aALMCAA8ACAn3Hu4aALMCABAAAgm8DGlZAGMAABEAAQkAAN44AA4AAAAA.',
['来支']='来支烟:BAAALgAECgIJAgAAAA==.',
['杨小']='杨小河:BAAALgAECgMJBQAAAA==.',
['极光']='极光之舞:BAAALgAECgEJAQAAAA==.',
['柯墓']='柯墓:BAAALgADCgIJAgAAAA==.',
['格尔']='格尔宾梅卡娜:BAAALgAECgMJAwAAAA==.',
['梦境']='梦境护卫:BAAALgAECgEJAQAAAA==.',
['樱桃']='樱桃小肥子:BAAALgADCgcJBwAAAA==.樱桃肥肥子:BAAALgADCgcJBwAAAA==.',
['此子']='此子斷不可留:BAAALgADCgEJAQAAAA==.',
['步步']='步步生莲:BAABLgAFFH8GAAIHAAQJ/Q8pBgBLAQAHAAQJ/Q8pBgBLAQAAAA==.',
['武装']='武装兔兔:BAAALgADCgEJAQAAAA==.',
['死神']='死神永生:BAAALgAECgMJAwAAAA==.死神的学徒:BAAALgADCgkJCQAAAA==.',
['段誉']='段誉:BAAALgAECgcJCgAAAA==.',
['比比']='比比拉布:BAAALgAECgEJAgAAAA==.',
['水随']='水随云:BAAALgAECgEJAQAAAA==.',
['江听']='江听潮:BAAALgAECgcJBgAAAA==.',
['法克']='法克儿:BAAALgAECgYJBgAAAA==.',
['法力']='法力渣渣:BAAALgADCgYJAQAAAA==.',
['波波']='波波沙:BAAALgAECgYJBwAAAA==.',
['洛云']='洛云:BAAALgAFFAUJBAAAAA==.',
['浪子']='浪子无家:BAAALgADCgEJAQAAAA==.',
['深兰']='深兰姐姐:BAAALgAECgMJBwAAAA==.',
['温酒']='温酒:BAAALgAECgUJDAAAAA==.',
['湖五']='湖五十弦:BAAALgAECgkJCwABLgAFFAIJAgADAAAAAA==.',
['源源']='源源灬亲亲:BAAALgAECgYJCwAAAA==.',
['满地']='满地鸡跑:BAAALgADCgYJBgAAAA==.',
['灵幻']='灵幻猫儿:BAAALgADCgEJAQAAAA==.',
['灾厄']='灾厄女王:BAAALgAECgEJAQAAAA==.',
['炀橙']='炀橙:BAAALgAECgUJDAAAAA==.',
['炽荧']='炽荧:BAAALgAECgYJDgAAAA==.',
['烜赫']='烜赫大梁城:BAAALgADCgEJAgAAAA==.',
['熊三']='熊三儿:BAAALgADCgEJAQAAAA==.',
['熊猫']='熊猫辣妹:BAAALgAECgYJBgAAAA==.',
['爱上']='爱上天使:BAAALgAECgIJAgAAAA==.',
['牛奶']='牛奶哥哥:BAAALgADCgEJAQAAAA==.',
['狂风']='狂风绝息斬:BAABLgAFFH8FAAMBAAUJ5gl8GwA2AQABAAQJ5gl8GwA2AQACAAEJAACzFgA/AAAAAA==.',
['独狼']='独狼猎手:BAAALgADCgUJCAAAAA==.',
['独钓']='独钓韩江:BAAALgAECgYJEwAAAA==.',
['狸狸']='狸狸我呀:BAAALgAECgQJBAAAAA==.',
['猛爪']='猛爪:BAAALgADCgMJBAAAAA==.',
['猪猪']='猪猪小侠:BAAALgADCgEJAQAAAA==.',
['獦狚']='獦狚:BAAALgADCgEJAQAAAA==.',
['王牛']='王牛:BAAALgAECgYJAwABLgAECgkJHwABAHwjAA==.',
['王走']='王走:BAAALgAECggJCAABLgAECgkJHwABAHwjAA==.',
['琉风']='琉风:BAABLgAECn8iAAISAAcJgxxcBABKAgASAAcJgxxcBABKAgAAAA==.',
['电动']='电动香蕉:BAAALgAECgQJBQAAAA==.',
['电眼']='电眼姐姐:BAAALgAECgMJAwAAAA==.',
['界临']='界临:BAAALgAFFAQJBAAAAA==.',
['疯狂']='疯狂的豆沙包:BAAALgAECgQJCgAAAA==.',
['白玉']='白玉京:BAAALgAECgQJBAAAAA==.',
['眠空']='眠空:BAABLgAECn8VAAIBAAcJ6xR7WgDiAQABAAcJ6xR7WgDiAQAAAA==.',
['瞧峰']='瞧峰:BAAALgADCgEJAQAAAA==.',
['矮个']='矮个子骑士:BAAALgADCgcJCgAAAA==.',
['矮灬']='矮灬大灬紧:BAAALgAECgMJBQAAAA==.',
['神奇']='神奇小正正:BAAALgADCgMJAgAAAA==.',
['神灬']='神灬罚:BAAALgAECgQJCwAAAA==.神灬阿术:BAAALgAECgYJCAAAAA==.神灬阿飙:BAAALgAECgMJAQAAAA==.',
['秉烛']='秉烛夜游:BAAALgAECgYJBwAAAA==.',
['秋幕']='秋幕:BAAALgADCgUJBQAAAA==.',
['立华']='立华奏:BAAALgADCgUJBQABLgAFFAQJDAATAGkcAA==.',
['篆愁']='篆愁君:BAAALgAECgUJAQAAAA==.',
['红透']='红透一片天:BAAALgAECgQJBAAAAA==.',
['纯爱']='纯爱女神:BAAALgAECgEJAQAAAA==.',
['纳兰']='纳兰风:BAACLgAFFH8IAAISAAMJFA3PEADiAAASAAMJFA3PEADiAAAuAAQKfx0AAhIABwkxIEoeACoCABIABwkxIEoeACoCAAAA.',
['纳努']='纳努伊尔:BAAALgAFFAQJBAAAAA==.',
['绝境']='绝境之光:BAAALgAECgMJBgAAAA==.',
['罗克']='罗克塔:BAAALgAECgYJBwAAAA==.',
['羊脂']='羊脂球:BAAALgAECgQJAwAAAA==.',
['老王']='老王猎手:BAAALgAECgYJBgAAAA==.',
['肉松']='肉松小贝:BAAALgAECgkJDQAAAA==.',
['脆灬']='脆灬壳:BAAALgAECgEJAQAAAA==.',
['航空']='航空报国:BAAALgAECggJCAAAAA==.',
['艾灵']='艾灵灬羽花:BAAALgADCgcJBwAAAA==.',
['艾瑞']='艾瑞达双子:BAAALgAFFAIJAgAAAA==.',
['艾里']='艾里凯曼:BAAALgAECgYJDwAAAA==.',
['芙宁']='芙宁娜:BAAALgAECgIJAgAAAA==.',
['花雨']='花雨嘌呤:BAAALgADCgYJCAAAAA==.',
['苦痛']='苦痛寺僧:BAAALgAECgQJBAAAAA==.',
['草莓']='草莓大馒头:BAAALgADCgYJBgAAAA==.',
['荧荧']='荧荧:BAAALgADCgMJAwAAAA==.',
['荷妞']='荷妞:BAAALgAECgQJBAAAAA==.',
['荷妹']='荷妹七号:BAAALgAECgYJCwAAAA==.荷妹二号:BAAALgAECgMJAwABLgAECgYJCwADAAAAAA==.荷妹五号:BAAALgAECgUJBQABLgAECgYJCwADAAAAAA==.',
['莎莎']='莎莎妹:BAAALgADCgEJAQAAAA==.',
['莫高']='莫高雷的风:BAAALgADCgMJAwAAAA==.',
['萌新']='萌新小奥法:BAABLgAFFH8MAAILAAQJORluBwBxAQALAAQJORluBwBxAQAAAA==.',
['薄情']='薄情于痴:BAAALgADCgYJBgAAAA==.',
['虚空']='虚空大波浪:BAAALgAECgEJAQAAAA==.虚空的行者:BAAALgAECgMJAwAAAA==.',
['蛋白']='蛋白质的忧伤:BAAALgAECgkJCQAAAA==.',
['西西']='西西妹:BAAALgAECgQJBAAAAA==.西西米露:BAABLgAFFH8FAAIFAAIJWAsYEQCGAAAFAAIJWAsYEQCGAAAAAA==.',
['言午']='言午枫:BAAALgAECgQJCAAAAA==.',
['豌豆']='豌豆芽:BAABLgAECn8VAAMFAAgJNSCKDgDFAgAFAAcJwCKKDgDFAgAUAAcJ9SB6AgBHAgAAAA==.',
['赫敏']='赫敏:BAAALgADCgUJBQAAAA==.',
['赳赳']='赳赳老魔:BAAALgAECgcJBwAAAA==.',
['路易']='路易威登:BAAALgADCggJDAAAAA==.',
['轩哥']='轩哥武僧一:BAABLgAECn8VAAIMAAkJPBwbDQDAAgAMAAkJPBwbDQDAAgABLgAFFAYJDwAMAEwWAA==.',
['辣鸡']='辣鸡小正正:BAAALgAECgEJAQAAAA==.',
['迪鲁']='迪鲁芬:BAAALgAFFAIJAgAAAA==.',
['迷迷']='迷迷芙芙:BAACLgAFFH8SAAMVAAUJqyDHBACVAQAVAAQJqyDHBACVAQASAAIJ2gTMHwBUAAAuAAQKfy4AAxUACAlcJSAEAFwDABUACAlcJSAEAFwDABIAAwkSHIFyAMUAAAAA.',
['追忆']='追忆旧梦丶:BAAALgADCgEJAQAAAA==.',
['逆风']='逆风的流云:BAAALgAFFAEJAQAAAA==.',
['闖禍']='闖禍的阿淼:BAAALgAECgYJCQAAAA==.',
['阡墨']='阡墨:BAAALgADCgcJBwAAAA==.',
['阿卡']='阿卡多:BAAALgAECgYJCwAAAA==.',
['陆沉']='陆沉的小兔子:BAAALgADCgQJBAAAAA==.',
['陈大']='陈大米:BAAALgADCgEJAQAAAA==.',
['陈沦']='陈沦:BAAALgAECgkJBwAAAA==.',
['雙雙']='雙雙:BAAALgAECgEJAQAAAA==.',
['雪莉']='雪莉:BAAALgAECgMJBQAAAA==.',
['零度']='零度萌萌哒:BAABLgAECn8YAAILAAYJOR41XAAlAgALAAYJOR41XAAlAgAAAA==.',
['霜馨']='霜馨:BAACLgAFFH8LAAIPAAQJRBrSBwBUAQAPAAQJRBrSBwBUAQAuAAQKfxcABA8ACAmjF2d3AG4BAA8ABQlIGmd3AG4BABAABAlbEhg8AMQAABEAAQlUFnEuAEEAAAAA.',
['露娜']='露娜月之歌:BAAALgADCgYJBwAAAA==.',
['非常']='非常熟食:BAAALgADCgUJBQAAAA==.',
['音風']='音風夜:BAAALgADCgEJAQAAAA==.',
['风中']='风中的线条:BAAALgADCgMJAwAAAA==.',
['风之']='风之行者:BAAALgAECgMJAwAAAA==.',
['风影']='风影之牛:BAAALgAECgYJBwAAAA==.',
['风行']='风行殇云:BAAALgAECgQJCAAAAA==.',
['风雪']='风雪来过:BAAALgAECgYJCAAAAA==.',
['饭团']='饭团哥:BAAALgAECgEJAQAAAA==.',
['骑你']='骑你头上:BAAALgAFFAIJAwAAAA==.',
['魂烬']='魂烬:BAAALgAECgcJDgAAAA==.',
['魑魅']='魑魅罔两:BAAALgADCgEJAQAAAA==.魑魅迷惘:BAAALgAFFAIJAgAAAA==.',
['魔兽']='魔兽入野:BAAALgAECgQJCAAAAA==.',
['魔魔']='魔魔的小眉毛:BAAALgAECgQJCgAAAA==.',
['鲍老']='鲍老师:BAAALgAECgMJAwAAAA==.',
['鹅肝']='鹅肝和牛堡:BAABLgAECn8YAAILAAgJpxMfEgDTAQALAAgJpxMfEgDTAQAAAA==.',
['麟锋']='麟锋:BAAALgAECgIJAgAAAA==.',
['麻三']='麻三豆:BAAALgAECgQJCAAAAA==.',
['黄飞']='黄飞鸿:BAAALgADCgMJAwAAAA==.',
['黑虎']='黑虎赵公明:BAAALgAECgEJAQAAAA==.',
['黑角']='黑角丶高岭:BAAALgAECgMJAwAAAA==.',
['黑铁']='黑铁饭饭:BAABLgAECn8aAAMGAAkJtyDfBQAwAwAGAAkJtyDfBQAwAwAKAAEJwBfbEwBHAAABLgAECgkJHwABAHwjAA==.',
['黑龙']='黑龙:BAAALgAECgMJAwAAAA==.',
['鼻毛']='鼻毛飞舞:BAACLgAFFH8FAAIFAAIJkgbGHgCAAAAFAAIJkgbGHgCAAAAuAAQKfxgAAwUACAmSGCMLANABAAUACAmSGCMLANABABQABAlSDilWAMwAAAAA.',
['龙族']='龙族丫小雪:BAAALgADCgcJBwAAAA==.',
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
