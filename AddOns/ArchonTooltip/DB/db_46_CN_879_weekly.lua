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

local lookup = {'Warrior-Protection','Monk-Brewmaster','Unknown-Unknown','Evoker-Devastation','Evoker-Augmentation','Druid-Balance','DemonHunter-Devourer','DemonHunter-Havoc','Druid-Restoration','Monk-Windwalker','DeathKnight-Unholy','Shaman-Restoration','Paladin-Retribution','Shaman-Elemental','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','DeathKnight-Frost','Warrior-Fury','Priest-Holy','Priest-Discipline','DeathKnight-Blood','Evoker-Preservation','Priest-Shadow','Paladin-Holy','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','Hunter-Survival',}
local provider = {region='CN',realm='霍格',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aifa:BAAALgAECgEJAgAAAA==.',
Ak='Akane:BAAALgAECgYJBgAAAA==.',
Ba='Bananab:BAAALgAFFAQJBAAAAA==.Bananaer:BAAALgAFFAQJBAAAAA==.Bananan:BAABLgAFFH8GAAIBAAQJnxTXBAArAQABAAQJnxTXBAArAQABLgAFFAQJBgACAFUbAA==.',
Br='Bryan:BAAALgAFFAIJAwAAAA==.',
Ca='Cassiel:BAAALgAECgEJAQAAAA==.',
Ci='Ciao:BAAALgAECgQJBAAAAA==.',
De='Deathnote:BAAALgAFFAIJBAAAAA==.Deeplog:BAAALgADCgQJBAAAAA==.',
Em='Emilye:BAAALgAECgYJDwAAAA==.Emnm:BAAALgAFFAMJBAABLgAFFAQJBAADAAAAAA==.',
He='Helle:BAAALgAECgYJEQAAAA==.',
Hu='Husky:BAAALgAECgcJBwAAAA==.',
Ja='Jackseven:BAAALgAECgEJAQAAAA==.Jagermister:BAAALgAECgYJDQAAAA==.',
Ki='Kiba:BAABLgAECn8hAAMEAAgJQBskBwB6AgAEAAgJ5hgkBwB6AgAFAAgJ1BIxBgC7AQAAAA==.',
Lu='Luckydk:BAAALgAECgQJBwAAAA==.',
Ma='Maisakatoku:BAAALgAECgYJBgAAAA==.',
Me='Medusa:BAAALgAECgYJDwAAAA==.',
Mt='Mtl:BAAALgAECgQJCAAAAA==.',
Na='Naiqi:BAAALgAECgMJBQAAAA==.',
Oi='Oi:BAAALgADCgUJBQAAAA==.',
Ra='Rare:BAAALgAFFAQJBAAAAA==.',
Re='Remmy:BAAALgAECgIJAgAAAA==.',
Sh='Shownor:BAAALgAECgEJAQAAAA==.',
Sm='Smallrain:BAABLgAFFH8LAAIGAAUJpQTuCwAqAQAGAAUJpQTuCwAqAQAAAA==.',
Xi='Xiaoqi:BAAALgAECgYJBwAAAA==.',
Xm='Xm:BAAALgAECgcJDAAAAA==.',
Yv='Yveital:BAABLgAECn8dAAMHAAYJmh7eEACiAQAHAAYJ1x3eEACiAQAIAAUJDBuCMQBHAQAAAA==.',
Zi='Zise:BAAALgADCgYJBgAAAA==.',
['一只']='一只小萨满:BAAALgAECgIJAgAAAA==.',
['一抹']='一抹丶回忆:BAAALgAECgMJAwAAAA==.',
['一粒']='一粒弹怒牛:BAAALgAECgIJAwAAAA==.',
['丁丁']='丁丁又真真:BAAALgADCgEJAQAAAA==.',
['七海']='七海蒂娜:BAAALgAECgMJAwAAAA==.',
['丈育']='丈育:BAAALgAECgQJBAAAAA==.',
['三岁']='三岁学杀鸡:BAAALgAFFAEJAQAAAA==.三岁就很靓:BAAALgAFFAIJAgAAAA==.',
['三木']='三木曰一先生:BAAALgAFFAIJAwABLgAFFAUJBAADAAAAAA==.',
['三聚']='三聚氰胺:BAAALgADCgEJAQAAAA==.',
['上杉']='上杉谦信:BAABLgAFFH8FAAIJAAMJ6BdeDwDyAAAJAAMJ6BdeDwDyAAAAAA==.',
['下次']='下次一定:BAAALgAECgUJBQAAAA==.',
['不蜥']='不蜥蜥:BAAALgAECgYJBwABLgAFFAIJBgAKAKIVAA==.',
['不要']='不要再打了啦:BAAALgADCgIJAgAAAA==.',
['东海']='东海帝王:BAAALgADCgEJAQAAAA==.',
['东莱']='东莱太史慈:BAAALgAECgEJAQAAAA==.',
['两百']='两百很多了:BAAALgAECgEJAQAAAA==.',
['丨小']='丨小心售人控:BAAALgAECgYJCQAAAA==.',
['丰胸']='丰胸圣手:BAAALgAECgYJCAAAAA==.',
['丶子']='丶子之星众丨:BAAALgAECgYJCQAAAA==.',
['丶小']='丶小可愛:BAAALgAECgEJAQAAAA==.',
['丶更']='丶更好看:BAAALgAECgEJAQAAAA==.',
['丶瑶']='丶瑶瑶丶:BAAALgADCgUJBQAAAA==.',
['乄荧']='乄荧惑:BAAALgAECgkJBgAAAA==.',
['乔佛']='乔佛里大人:BAAALgAECgYJBgAAAA==.',
['二零']='二零一七年:BAAALgAECgMJBAAAAA==.',
['五袋']='五袋长老:BAAALgAECgIJAgAAAA==.',
['伊莎']='伊莎玛拉:BAAALgAECgIJAgAAAA==.',
['伏黑']='伏黑甚尓:BAAALgAECgMJAwAAAA==.',
['伤心']='伤心猪大肠:BAABLgAFFH8GAAMJAAQJ3wdMEwDOAAAJAAMJ9gdMEwDOAAAGAAEJYAO3GgBMAAAAAA==.',
['似氺']='似氺流年:BAAALgAECgMJAwAAAA==.',
['你被']='你被牛打过:BAABLgAFFH8GAAMJAAUJwgs+BABkAQAJAAUJwgs+BABkAQAGAAEJ9wOaHABDAAAAAA==.',
['倾斜']='倾斜:BAAALgAECgQJBAAAAA==.',
['光辉']='光辉女郎:BAAALgAECgIJAgAAAA==.',
['全看']='全看脸:BAAALgAECgEJAwAAAA==.',
['八月']='八月丶下:BAAALgAECgEJAQAAAA==.',
['公子']='公子丨世无双:BAAALgAECgcJCAAAAA==.',
['六十']='六十六:BAAALgADCgYJCAAAAA==.',
['兵主']='兵主:BAACLgAFFH8HAAILAAIJ9RGBPQCjAAALAAIJ9RGBPQCjAAAuAAQKfxgAAgsABgkIJNZGAB8CAAsABgkIJNZGAB8CAAAA.',
['冬青']='冬青子:BAAALgAECgMJAwAAAA==.',
['冰川']='冰川怒:BAAALgAECgEJAQAAAA==.',
['冷水']='冷水鱼:BAAALgAECgMJAwAAAA==.',
['利比']='利比亚张飞:BAAALgADCgEJAQAAAA==.',
['别问']='别问:BAAALgAECgcJCAAAAA==.',
['南桪']='南桪:BAAALgAECgYJCQAAAA==.',
['卡呆']='卡呆:BAAALgAFFAMJAwAAAA==.',
['厉害']='厉害不厉害:BAAALgAECgkJBgAAAA==.',
['双面']='双面龟:BAAALgAECgYJCQAAAA==.',
['变大']='变大变好看:BAAALgAECgIJAwAAAA==.',
['叛逆']='叛逆的鲁智深:BAAALgAFFAIJAgAAAA==.',
['口合']='口合口合:BAAALgADCgUJBQAAAA==.',
['口嗨']='口嗨可不行:BAAALgAECgEJAQAAAA==.',
['周二']='周二的荒冬:BAAALgAECgYJBgAAAA==.',
['咕噜']='咕噜丨敏:BAAALgAECggJAgAAAA==.',
['咩咩']='咩咩子:BAABLgAFFH8HAAIMAAIJORgQFwCgAAAMAAIJORgQFwCgAAAAAA==.',
['喂奶']='喂奶:BAAALgAECgMJAwAAAA==.',
['喵一']='喵一:BAAALgAFFAQJBAAAAA==.',
['喵九']='喵九:BAABLgAFFH8JAAICAAUJwRP/BABCAQACAAUJwRP/BABCAQAAAA==.',
['喵八']='喵八:BAABLgAECn8fAAMCAAkJzxFiHwAHAgACAAkJzxFiHwAHAgAKAAYJeAskQAAYAQAAAA==.',
['喵十']='喵十:BAABLgAFFH8NAAICAAUJXxoRBwBiAQACAAUJXxoRBwBiAQAAAA==.喵十一:BAABLgAFFH8JAAICAAUJzhPOBQB3AQACAAUJzhPOBQB3AQAAAA==.喵十七:BAAALgAFFAQJBAAAAA==.喵十三:BAABLgAFFH8NAAICAAUJVxVSBgBuAQACAAUJVxVSBgBuAQAAAA==.喵十二:BAAALgAFFAQJBAAAAA==.喵十五:BAABLgAFFH8JAAICAAUJfxQ6BgAuAQACAAUJfxQ6BgAuAQAAAA==.喵十八:BAABLgAFFH8MAAICAAQJKxv8AgBqAQACAAQJKxv8AgBqAQAAAA==.喵十六:BAABLgAFFH8IAAICAAQJlxP+CgAvAQACAAQJlxP+CgAvAQAAAA==.喵十四:BAABLgAFFH8MAAICAAQJoxlKBABNAQACAAQJoxlKBABNAQAAAA==.',
['四囍']='四囍蒸鹅煲:BAAALgAECgYJCAAAAA==.',
['圣光']='圣光宇:BAAALgAECgMJBAAAAA==.圣光忽悠着我:BAAALgAECgEJAgAAAA==.',
['圣灵']='圣灵吹拂:BAAALgAECgMJAwAAAA==.',
['坎焏']='坎焏:BAAALgAECgYJBgAAAA==.',
['坐牢']='坐牢:BAAALgAFFAEJAQAAAA==.',
['塔塔']='塔塔:BAAALgADCgUJBQAAAA==.',
['墨児']='墨児:BAAALgAECgYJBgAAAA==.',
['夏洛']='夏洛特凯尔:BAAALgAFFAQJBAABLgAFFAcJCwANAEEbAA==.',
['夜露']='夜露死苦:BAAALgADCgEJAQAAAA==.',
['大典']='大典太光世:BAAALgAFFAEJAQAAAA==.',
['大意']='大意失亲马:BAAALgADCgUJBQAAAA==.',
['大花']='大花花:BAAALgAECgYJCgAAAA==.',
['大锤']='大锤王:BAAALgAECgkJDwAAAA==.',
['天真']='天真的云:BAABLgAFFH8JAAILAAYJSRyzGQA+AQALAAYJSRyzGQA+AQAAAA==.',
['奥术']='奥术啤酒花:BAAALgAECgEJAQAAAA==.',
['女老']='女老爷儿:BAAALgAECgEJAQAAAA==.',
['奶不']='奶不动就跑:BAABLgAFFH8FAAIMAAQJ3QalCwAeAQAMAAQJ3QalCwAeAQAAAA==.',
['奶德']='奶德儿:BAAALgAECgYJBgAAAA==.',
['娜塔']='娜塔莎:BAAALgAFFAIJAgAAAA==.',
['嫣然']='嫣然:BAAALgAECgQJBQAAAA==.',
['孑弦']='孑弦:BAAALgAFFAQJBAAAAA==.',
['孫勇']='孫勇敢:BAAALgAECgYJBgAAAA==.',
['宁心']='宁心:BAAALgAFFAQJBAAAAA==.',
['宝宝']='宝宝是本体:BAAALgAECgYJBwAAAA==.',
['审判']='审判:BAAALgAECgMJAwAAAA==.',
['寒暄']='寒暄兮语:BAAALgAECgYJCAAAAA==.寒暄汹焽僧:BAAALgAECgcJCwAAAA==.寒暄焽訩貓:BAAALgAECgcJEwAAAA==.寒暄莫焽狐:BAAALgAECgUJBQAAAA==.',
['小哥']='小哥有故事:BAAALgAECgUJBwAAAA==.',
['小希']='小希大魔王:BAAALgAECgEJAQAAAA==.',
['小忮']='小忮:BAAALgAECgQJBQAAAA==.',
['小桥']='小桥流水:BAAALgADCgYJBAAAAA==.',
['小泽']='小泽早安:BAABLgAECn8ZAAIOAAYJuyVaEgCQAgAOAAYJuyVaEgCQAgAAAA==.',
['小狸']='小狸花:BAAALgAECgMJBgAAAA==.',
['小狼']='小狼十一号:BAAALgAECgEJAQAAAA==.小狼叁号:BAAALgAECgEJAwAAAA==.',
['小管']='小管同学萨:BAAALgAECgEJAQAAAA==.',
['小紅']='小紅帽:BAAALgAECgUJBQAAAA==.',
['小菜']='小菜丶咕:BAAALgAECgYJEwAAAA==.',
['小虎']='小虎骑士:BAAALgAECgUJBQAAAA==.',
['小马']='小马拉的大车:BAAALgAECgYJBgAAAA==.',
['尼尔']='尼尔机械纪元:BAAALgAECgcJCgAAAA==.',
['巨山']='巨山霸霸:BAAALgADCgIJAgABLgAECgcJFwAPAPAfAA==.',
['帝皇']='帝皇:BAAALgAECgIJAwAAAA==.',
['幽沁']='幽沁静心:BAAALgAECgYJEwAAAA==.',
['幽灵']='幽灵灬壁垒:BAAALgAFFAQJBAAAAA==.',
['广州']='广州大盗:BAAALgAECgUJBgAAAA==.',
['弑君']='弑君丶:BAAALgAECgYJBwAAAA==.',
['弹簧']='弹簧钢:BAABLgAECn80AAMQAAkJ4hthBwAaAwAQAAkJ4hthBwAaAwARAAgJdxJIKgDWAQABLgAFFAUJBgASADQdAA==.',
['徐锦']='徐锦江丶:BAAALgAECgEJAQAAAA==.',
['御林']='御林铁卫:BAAALgAECgYJBwAAAA==.',
['德拉']='德拉科马尔福:BAAALgAECgIJAgAAAA==.',
['心向']='心向明月:BAABLgAECn8UAAIHAAYJViWcBwAeAgAHAAYJViWcBwAeAgABLgAECgYJGQAOALslAA==.',
['忍冬']='忍冬和月见草:BAACLgAFFH8JAAMQAAMJLSArDwDQAAARAAMJAR9yEQAhAQAQAAIJDCArDwDQAAAuAAQKfxgAAxAACAloHpUSAKICABAABwklHpUSAKICABEABgkJILsrAMwBAAAA.',
['恶魔']='恶魔丶佑翼:BAAALgAECgQJBAAAAA==.恶魔丶巴巴塔:BAAALgADCgEJAQAAAA==.',
['愤怒']='愤怒的小熊:BAAALgADCgIJAgAAAA==.',
['慒丶']='慒丶懆:BAABLgAECn8WAAMTAAcJdx7HAgB+AgATAAcJdx7HAgB+AgALAAMJbBil7AClAAAAAA==.',
['成都']='成都的塔子山:BAAALgAECgUJBQAAAA==.',
['我不']='我不做小强:BAABLgAECn8UAAISAAcJjgVS1QBEAQASAAcJjgVS1QBEAQAAAA==.',
['我是']='我是神:BAAALgAECgYJBwABLgAECgcJFwAPAPAfAA==.',
['我笑']='我笑清风:BAABLgAECn8bAAILAAcJcxykNQBgAgALAAcJcxykNQBgAgAAAA==.',
['打窝']='打窝:BAACLgAFFH8LAAMUAAUJXCJeBQCcAQAUAAQJXCJeBQCcAQAPAAEJAAADCAB4AAAuAAQKfxUAAhQACQnCGagVAKACABQACQnCGagVAKACAAAA.',
['拉莱']='拉莱耶海鲜馆:BAAALgAECgEJAQAAAA==.',
['拿我']='拿我耙子来:BAAALgAECgYJBgAAAA==.',
['搁浅']='搁浅丶:BAACLgAFFH8RAAISAAUJIyXyBQADAgASAAUJIyXyBQADAgAuAAQKfx8AAhIACAm7I9QXABwDABIACAm7I9QXABwDAAAA.',
['搞不']='搞不太清楚:BAAALgADCgEJAQAAAA==.',
['文鸯']='文鸯:BAAALgAECgYJBgAAAA==.',
['旋转']='旋转人:BAACLgAFFH8RAAICAAQJXyCUAgB0AQACAAQJXyCUAgB0AQAuAAQKfxgAAgIACAk6IGALANcCAAIACAk6IGALANcCAAAA.',
['无敌']='无敌法帅大王:BAABLgAECn8UAAISAAYJdSK+UQBCAgASAAYJdSK+UQBCAgAAAA==.',
['旧人']='旧人:BAAALgAECgYJCgAAAA==.',
['早饭']='早饭想吃啥:BAABLgAECn8WAAMQAAcJBRxyKwAGAgAQAAcJBRxyKwAGAgARAAIJwAOnfgBLAAAAAA==.',
['旬旬']='旬旬洵:BAAALgAECgYJEwAAAA==.',
['时间']='时间笑染一瞬:BAAALgAECgYJEwAAAA==.',
['明月']='明月:BAAALgADCgMJAwAAAA==.',
['星见']='星见雅:BAAALgADCgEJAQAAAA==.',
['春夏']='春夏秋冬:BAAALgAECgMJAwAAAA==.',
['晚晚']='晚晚:BAACLgAFFH8HAAMVAAQJQBavAgA1AQAVAAQJmRKvAgA1AQAWAAIJEhEzEwCcAAAuAAQKfxUAAhUABgnHIgQUAD8CABUABgnHIgQUAD8CAAAA.',
['晚里']='晚里:BAAALgAFFAQJBAABLgAFFAkJAQADAAAAAA==.',
['暴风']='暴风电鳗:BAAALgAECgYJCAAAAA==.',
['暴食']='暴食:BAAALgAECgYJBgAAAA==.',
['曦光']='曦光咏叹:BAAALgAECgEJAQABLgAECgcJBwADAAAAAA==.',
['曲误']='曲误周郎:BAAALgAECgMJAwAAAA==.',
['朝歌']='朝歌:BAAALgAECgEJAQAAAA==.',
['朝霞']='朝霞:BAAALgADCgYJBgAAAA==.',
['权志']='权志龙:BAAALgAFFAIJAgAAAA==.',
['杨钰']='杨钰:BAAALgADCgEJAQAAAA==.',
['极光']='极光瑰夏:BAAALgAECgYJBgAAAA==.',
['林深']='林深时见鹿:BAAALgAECgQJBQAAAA==.',
['枫岁']='枫岁月:BAAALgADCgcJBwAAAA==.',
['梅超']='梅超风丶:BAAALgADCgYJBgAAAA==.',
['梓落']='梓落湫山:BAAALgAECgUJBgAAAA==.',
['梦叨']='梦叨叨:BAAALgAFFAIJAwAAAA==.',
['梦幻']='梦幻:BAAALgAECgcJBgAAAA==.',
['梦游']='梦游猫:BAAALgAFFAEJAQAAAA==.',
['橙柚']='橙柚柚:BAAALgAECgcJBwAAAA==.',
['欢迎']='欢迎业主回家:BAACLgAFFH8QAAMLAAQJDh5sDQBtAQALAAQJDh5sDQBtAQATAAIJMRrJAgC9AAAuAAQKfx8ABAsACAmgIlgRABQDAAsACAlHIlgRABQDABMABgmCJB8EACkCABcAAQm+CAtNABwAAAAA.',
['欧阳']='欧阳嗯:BAAALgAECgEJAQAAAA==.欧阳小蕾蕾:BAAALgAFFAEJAQAAAA==.',
['此面']='此面向敌:BAAALgAFFAUJBAAAAA==.',
['毁灭']='毁灭术:BAAALgAECgUJBwAAAA==.',
['毘沙']='毘沙门天:BAABLgAECn8VAAILAAgJOhoHSQAYAgALAAgJOhoHSQAYAgAAAA==.',
['水煮']='水煮牛鞭丶:BAAALgAECgEJAgAAAA==.',
['江南']='江南十六:BAAALgADCgQJBAAAAA==.',
['污而']='污而不雅:BAAALgAECgEJAQAAAA==.',
['汪尔']='汪尔萨斯:BAACLgAFFH8IAAMXAAMJ3QLjCACCAAALAAMJlgJ7MADMAAAXAAMJ/ADjCACCAAAuAAQKfyEAAwsACAllGJJHAB0CAAsACAllGJJHAB0CABcABwmCCk8iAC8BAAAA.',
['没味']='没味:BAAALgADCgYJBgAAAA==.',
['沸点']='沸点:BAAALgADCgcJBwAAAA==.',
['法尸']='法尸:BAAALgAECgUJCAAAAA==.',
['泠霜']='泠霜映雪:BAAALgAECgEJAgAAAA==.',
['泷泽']='泷泽萝莉丶:BAAALgAECgYJCAAAAA==.',
['泽兰']='泽兰:BAAALgAFFAIJAgAAAA==.',
['流莺']='流莺毒:BAAALgAFFAQJBAAAAA==.',
['浪迹']='浪迹在地球:BAAALgADCgEJAQAAAA==.',
['海绵']='海绵丶宝宝:BAAALgAECgEJAQAAAA==.',
['清扬']='清扬婉兮:BAACLgAFFH8JAAISAAQJaR+mBQB/AQASAAQJaR+mBQB/AQAuAAQKfx0AAhIACAnlIPUFAHICABIACAnlIPUFAHICAAAA.',
['清蒸']='清蒸鱼:BAAALgAECgEJAQAAAA==.',
['清风']='清风箭神:BAAALgAECgIJAwABLgAECgcJGwALAHMcAA==.',
['渊眼']='渊眼白龙:BAAALgAECgYJEAAAAA==.',
['渐隐']='渐隐的幽魂:BAAALgAECgQJBAAAAA==.',
['滚滚']='滚滚转圈圈:BAAALgAECgQJCQAAAA==.',
['满月']='满月开:BAAALgAECgYJDgAAAA==.',
['漠影']='漠影丶:BAABLgAFFH8OAAILAAQJOh6OBABrAQALAAQJOh6OBABrAQAAAA==.',
['漫漫']='漫漫射:BAAALgAECgQJBAAAAA==.',
['点根']='点根烟打个怪:BAAALgAECgYJBQAAAA==.',
['煙酒']='煙酒茶糖:BAAALgAECgEJAQAAAA==.',
['熊德']='熊德:BAAALgAFFAEJAQAAAA==.',
['燼靈']='燼靈:BAAALgAECgYJCwAAAA==.',
['牛九']='牛九九:BAAALgAECggJCgAAAA==.',
['牛爷']='牛爷爷来咯:BAAALgAECgYJCQABLgAECgcJFwAPAPAfAA==.',
['特辣']='特辣的辣椒:BAAALgADCgUJBQAAAA==.',
['狂炫']='狂炫富婆画饼:BAEALgAFFAQJBAABLgAFFAQJBgASALASAA==.',
['猎鹰']='猎鹰十九号:BAAALgAECgYJBgAAAA==.',
['王多']='王多浴:BAAALgAFFAIJAwABLgAFFAQJDgAGAL8PAA==.',
['珈小']='珈小珈:BAABLgAECn8XAAMYAAkJvBGgDwBAAgAYAAkJvBGgDwBAAgAEAAYJVhUQFQCaAQAAAA==.',
['珈蓝']='珈蓝疯癫癫:BAAALgAECgcJDQAAAA==.',
['球球']='球球大帝:BAAALgAECgMJAwAAAA==.',
['瑶仔']='瑶仔仔:BAAALgADCgEJAQAAAA==.',
['璨若']='璨若星河:BAAALgADCgEJAQAAAA==.',
['瓦里']='瓦里安帕拉丁:BAAALgAECgIJAgAAAA==.',
['甄霓']='甄霓瑪黛静:BAAALgAECgYJBgAAAA==.',
['疯一']='疯一样地男人:BAAALgAFFAIJAgAAAA==.',
['癞疙']='癞疙宝:BAABLgAFFH8GAAICAAMJqCMwCQBCAQACAAMJqCMwCQBCAQAAAA==.',
['白淩']='白淩轩:BAAALgAECgYJCQAAAA==.',
['白芷']='白芷动芳馨丶:BAABLgAFFH8MAAMJAAQJOhpkBwAcAQAJAAQJOhpkBwAcAQAGAAMJYQ9+FQCZAAAAAA==.',
['皮皮']='皮皮雨:BAAALgAFFAMJAwAAAA==.',
['盐酸']='盐酸哌替啶:BAAALgAECgcJCAAAAA==.',
['盘丝']='盘丝大仙:BAABLgAFFH8HAAMZAAMJfwaICgCOAAAZAAIJygaICgCOAAAWAAIJqQWNFQCIAAAAAA==.',
['盛宴']='盛宴:BAAALgAFFAQJBAAAAA==.',
['看我']='看我射岌岌:BAABLgAFFH8FAAIRAAQJiA0CEAAxAQARAAQJiA0CEAAxAQAAAA==.',
['眼睛']='眼睛有点迷:BAAALgAECgcJDgAAAA==.',
['睡觉']='睡觉小队长:BAAALgADCgEJAQAAAA==.',
['神巨']='神巨山:BAABLgAECn8XAAMPAAcJ8B9SDQDJAQAUAAYJyyC5JgAlAgAPAAYJJhpSDQDJAQAAAA==.',
['神的']='神的左手:BAAALgADCgMJBAAAAA==.',
['神经']='神经小哥:BAABLgAECn8fAAQNAAgJYR8VDgDfAQANAAgJYR8VDgDfAQAaAAIJIAQoiwBRAAAbAAEJAgL/SgAdAAAAAA==.',
['离心']='离心丶鬼颜:BAACLgAFFH8MAAIcAAYJkhWbDgBoAQAcAAYJkhWbDgBoAQAuAAQKfxQAAxwACAmcGflUAMkBABwABgndGvlUAMkBAB0AAwnkEtVCAKkAAAAA.',
['离法']='离法:BAABLgAFFH8GAAIcAAQJKxXTEQBWAQAcAAQJKxXTEQBWAQAAAA==.',
['稳重']='稳重猫咪:BAAALgAFFAEJAQAAAA==.',
['红色']='红色天空:BAAALgAECgQJBAAAAA==.红色皇后:BAAALgAECgYJBwAAAA==.',
['纳尔']='纳尔札尔:BAAALgADCgIJAgAAAA==.',
['练气']='练气小凑:BAAALgAECgUJCAAAAA==.',
['绝望']='绝望祷言:BAAALgAECgEJAQAAAA==.',
['绿灬']='绿灬晶晶:BAAALgAFFAIJAwAAAA==.',
['缘起']='缘起缘散:BAAALgAFFAQJBAAAAA==.',
['网瘾']='网瘾少女:BAAALgAECgYJCQAAAA==.网瘾少年:BAAALgAECgYJCgAAAA==.',
['羽登']='羽登仙:BAAALgAFFAEJAQAAAA==.',
['老天']='老天真:BAAALgAECgUJBQAAAA==.',
['老登']='老登丶:BAAALgADCgEJAQABLgAECgUJBQADAAAAAA==.',
['老蔡']='老蔡:BAAALgAECgEJAQAAAA==.',
['胖子']='胖子你好:BAAALgAECgYJBgAAAA==.',
['脑袋']='脑袋有点晕:BAAALgAFFAEJAgAAAA==.',
['自攻']='自攻牛:BAAALgADCgcJBwAAAA==.',
['艾玛']='艾玛格兰杰:BAAALgAECggJEAABLgAFFAIJAgADAAAAAA==.',
['花半']='花半仙:BAAALgAECgcJCAAAAA==.',
['花开']='花开若相依:BAABLgAFFH8FAAIWAAUJMRKKBACkAQAWAAUJMRKKBACkAQAAAA==.',
['花式']='花式啊:BAAALgAECgUJBQAAAA==.',
['花桥']='花桥丶:BAABLgAECn8YAAMPAAcJ7R3iAQAEAgAPAAcJeBziAQAEAgAUAAYJrh+wLQD8AQAAAA==.',
['苏苏']='苏苏喂酥酥:BAAALgAECgkJDwAAAA==.',
['荀令']='荀令君丶:BAAALgADCgcJBwAAAA==.荀令君丷:BAABLgAECn8WAAIVAAYJVSXNDgByAgAVAAYJVSXNDgByAgAAAA==.',
['荀文']='荀文若丶:BAAALgAECgUJCAAAAA==.',
['荒野']='荒野的呼唤:BAAALgADCgEJAQAAAA==.',
['荣归']='荣归:BAAALgADCgUJBQAAAA==.',
['莉可']='莉可:BAAALgADCgQJBAAAAA==.',
['菜比']='菜比圣骑:BAAALgAECgQJBAAAAA==.',
['萨特']='萨特先祖:BAAALgAECgQJBAAAAA==.',
['葛城']='葛城王牌:BAAALgAECgYJBgAAAA==.',
['蓝岚']='蓝岚丶坠:BAABLgAFFH8IAAIOAAIJLh/rEgC/AAAOAAIJLh/rEgC/AAAAAA==.',
['虞丶']='虞丶:BAABLgAFFH8GAAIVAAIJQhIVDQCVAAAVAAIJQhIVDQCVAAAAAA==.',
['血剑']='血剑刀锋:BAAALgADCgUJBQAAAA==.',
['许妍']='许妍:BAAALgAECgEJAQAAAA==.',
['诙止']='诙止:BAAALgADCgEJAQAAAA==.',
['语风']='语风:BAAALgAECgIJAgAAAA==.',
['请先']='请先杀我队友:BAAALgAECgYJBwAAAA==.',
['谬影']='谬影:BAAALgAECgEJAQAAAA==.',
['贝先']='贝先生:BAAALgAFFAIJBAAAAA==.',
['贝贝']='贝贝喷水水:BAAALgAFFAEJAgABLgAFFAMJAwADAAAAAA==.贝贝滚得得:BAAALgAFFAMJAwAAAA==.',
['贰贰']='贰贰叁肆:BAAALgAFFAIJAwAAAA==.',
['赵露']='赵露思:BAAALgAECgIJAgAAAA==.',
['起雾']='起雾:BAABLgAFFH8IAAIdAAQJLRIbBABRAQAdAAQJLRIbBABRAQABLgAFFAQJDAALAJkZAA==.',
['起风']='起风:BAABLgAFFH8MAAILAAQJmRkmDQBvAQALAAQJmRkmDQBvAQAAAA==.',
['超人']='超人冷:BAAALgAECgQJBAAAAA==.',
['辉月']='辉月:BAABLgAFFH8FAAINAAUJsRjpAwC0AQANAAUJsRjpAwC0AQAAAA==.',
['追风']='追风孤影:BAAALgAECgUJCAAAAA==.追风赶月:BAAALgAECgYJCQAAAA==.追风踏月:BAAALgAECgUJAQAAAA==.追风逐梦:BAAALgAECgQJBAAAAA==.',
['退伍']='退伍老兵:BAABLgAECn8bAAMGAAgJSxyWGwAlAgAGAAgJSxyWGwAlAgAJAAYJqhBCYgArAQAAAA==.',
['速效']='速效救心糖:BAAALgAECgcJBwAAAA==.',
['遇见']='遇见对的人:BAAALgAECgMJAwAAAA==.',
['那风']='那风灬慢点:BAAALgAECgEJAgAAAA==.',
['邪皇']='邪皇丶:BAAALgAECgYJCgAAAA==.',
['采湍']='采湍濑之玄芝:BAAALgADCgIJAgAAAA==.',
['释永']='释永行:BAAALgAECgUJCgAAAA==.',
['野人']='野人谷的狼:BAAALgAECgUJBQAAAA==.',
['钢背']='钢背灬传说刂:BAAALgAECgEJAQAAAA==.',
['银兰']='银兰水月:BAAALgAECgkJAwAAAA==.',
['银狼']='银狼:BAAALgADCgQJBAAAAA==.',
['闪电']='闪电连五鞭:BAAALgAFFAIJAgAAAA==.',
['闪解']='闪解人衣:BAAALgADCgQJBAAAAA==.',
['阐释']='阐释者:BAAALgAECgYJBgAAAA==.',
['阿西']='阿西灬法克刂:BAAALgAECgEJAwAAAA==.',
['阿雷']='阿雷:BAAALgAECgEJAQAAAA==.',
['陳千']='陳千語:BAABLgAECn8XAAIHAAcJBB6mIQCHAgAHAAcJBB6mIQCHAgAAAA==.',
['雨过']='雨过天阴:BAAALgAECgEJAQAAAA==.',
['雷丸']='雷丸:BAAALgAECgcJEgAAAA==.',
['雷布']='雷布朗多星人:BAAALgAECgYJCwABLgAECgcJFwAPAPAfAA==.',
['霍尔']='霍尔萌尾巴:BAAALgAECgEJAQAAAA==.',
['露露']='露露缇雅:BAAALgAECgYJBgAAAA==.',
['霸主']='霸主:BAAALgAECgYJEQAAAA==.',
['青柑']='青柑丨普洱:BAAALgAECgYJBgABLgAFFAYJFQAXAE4QAA==.',
['青雀']='青雀:BAAALgAECgcJBwABLgAFFAcJBgAFADUaAA==.',
['颜面']='颜面爆浆丶:BAAALgAECgEJAgAAAA==.',
['风月']='风月无边:BAAALgAECgMJAwAAAA==.',
['风绾']='风绾暮晴雪:BAABLgAFFH8IAAIYAAQJYRmDCABiAQAYAAQJYRmDCABiAQAAAA==.',
['飞翼']='飞翼鱼:BAAALgADCgEJAQAAAA==.',
['骑蜗']='骑蜗牛追火箭:BAAALgAECggJEAAAAA==.',
['鬣魔']='鬣魔人:BAAALgAECgMJBQAAAA==.',
['魔鬼']='魔鬼刀鱼:BAAALgAECgYJCgAAAA==.',
['鸿影']='鸿影踏霜迟:BAAALgADCgUJBQAAAA==.',
['黄河']='黄河丨入海流:BAAALgAECgQJBAAAAA==.',
['默爵']='默爵鞠:BAAALgADCgUJBQAAAA==.',
['鼓楼']='鼓楼一杯奶:BAAALgADCgYJCgABLgAECgcJHAAeAPggAA==.',
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
