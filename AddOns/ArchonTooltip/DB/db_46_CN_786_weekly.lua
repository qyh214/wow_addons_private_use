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

local lookup = {'DeathKnight-Unholy','Warlock-Demonology','Priest-Discipline','Priest-Shadow','Shaman-Restoration','Mage-Frost','Hunter-Survival','Druid-Restoration','Unknown-Unknown','Monk-Windwalker','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','DeathKnight-Frost','DeathKnight-Blood','Monk-Mistweaver','Rogue-Subtlety','Warrior-Fury','Shaman-Elemental','Paladin-Retribution','DemonHunter-Devourer','Warrior-Arms','Paladin-Holy','Monk-Brewmaster','Warrior-Protection','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Druid-Guardian','DemonHunter-Havoc',}
local provider = {region='CN',realm='红龙女王',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agares:BAAALgADCgUJBQAAAA==.',
An='Andk:BAABLgAECn8UAAIBAAYJVR45bACyAQABAAYJVR45bACyAQAAAA==.Anny:BAABLgAFFH8FAAICAAIJoyNOGQDMAAACAAIJoyNOGQDMAAAAAA==.',
Ao='Aoi:BAAALgAECgYJAQAAAA==.',
As='Askalon:BAABLgAFFH8IAAIBAAQJRxYBEQBdAQABAAQJRxYBEQBdAQAAAA==.',
Au='Aureolee:BAAALgAFFAMJAwAAAA==.Aureolef:BAAALgAFFAQJBAAAAA==.Aureoleh:BAABLgAFFH8FAAMDAAQJnhvjAwB1AQADAAQJnhvjAwB1AQAEAAEJpiOAEgBsAAAAAA==.',
Cr='Cristen:BAAALgADCggJCwAAAA==.',
De='Deathmetal:BAABLgAFFH8HAAIFAAMJOx1RBwAOAQAFAAMJOx1RBwAOAQAAAA==.',
Do='Dogmonk:BAAALgAECgUJBQAAAA==.Dogpaladin:BAAALgAECgEJAQAAAA==.',
Dr='Druidred:BAAALgAECgEJAQAAAA==.',
Du='Dusti:BAABLgAFFH8JAAIGAAQJoQnXDwA3AQAGAAQJoQnXDwA3AQAAAA==.Dusts:BAAALgAECgQJBAAAAA==.',
Ea='Earlyrider:BAAALgAECgcJCAAAAA==.',
Er='Erebus:BAAALgAECgEJAQAAAA==.',
Fi='Fiodk:BAAALgAECgUJBwAAAA==.',
Go='Gospel:BAAALgADCgQJBAAAAA==.',
Gr='Greywings:BAAALgAECgQJBQAAAA==.',
Hy='Hyperian:BAAALgAFFAEJAQAAAA==.',
In='Invictus:BAAALgAECgIJAQAAAA==.',
Ka='Kathigura:BAAALgAFFAMJBAAAAA==.',
La='Lakye:BAAALgAFFAEJAQAAAA==.',
Le='Levi:BAAALgADCgEJAQAAAA==.',
Li='Liddada:BAAALgAECgUJBQABLgAFFAMJBwACAAUlAA==.Lilymars:BAAALgAECgIJAgAAAA==.Lippe:BAAALgADCgEJAQAAAA==.',
Ll='Llonggnoll:BAABLgAFFH8MAAIBAAQJ0BTFCQBCAQABAAQJ0BTFCQBCAQAAAA==.',
Ma='Madeline:BAABLgAFFH8HAAIHAAMJNBtSAwAXAQAHAAMJNBtSAwAXAQAAAA==.',
Nu='Nun:BAAALgAECgEJAQAAAA==.',
Pe='Pense:BAAALgAECgQJBAAAAA==.',
Sa='Sarkura:BAAALgAECgYJCgAAAA==.',
Se='Seekmy:BAAALgAECgQJBAAAAA==.',
Su='Succumb:BAAALgAFFAIJAgAAAA==.Suneast:BAAALgAECgYJBgAAAA==.Suseven:BAAALgAECgYJBwAAAA==.',
Sw='Swing:BAABLgAFFH8HAAIIAAMJwxPTEQDbAAAIAAMJwxPTEQDbAAAAAA==.',
Tr='Triping:BAAALgAECgkJDgAAAA==.',
Vi='Violetmars:BAAALgADCgEJAQAAAA==.',
Wa='Wakuwaku:BAAALgAECgYJBgABLgAFFAEJAQAJAAAAAA==.',
We='Weare:BAAALgAECgQJBAAAAA==.',
Wz='Wz:BAAALgAFFAMJBAAAAA==.',
Xy='Xyzfs:BAAALgAECgQJBgAAAA==.Xyzlong:BAAALgAFFAEJAQAAAA==.',
Ya='Yayacc:BAAALgADCgYJBgAAAA==.',
Ye='Yeps:BAABLgAECn8UAAIKAAgJQBh/AwAGAgAKAAgJQBh/AwAGAgAAAA==.',
['一不']='一不行:BAAALgAECgEJAQAAAA==.',
['一切']='一切为了和平:BAAALgAECgMJAwAAAA==.',
['一剑']='一剑雪中来:BAAALgAECgYJBgAAAA==.',
['一咦']='一咦已亿:BAAALgAECgQJBAAAAA==.',
['一嘻']='一嘻嘻哈哈一:BAAALgADCgQJBAAAAA==.',
['一念']='一念佛或魔:BAAALgADCgQJBAAAAA==.',
['一棵']='一棵树苗:BAAALgADCgcJDQAAAA==.',
['一百']='一百个扁二:BAAALgAECgIJAgAAAA==.一百个毛豆:BAAALgAECgIJAgAAAA==.一百个肉筋:BAAALgAECgEJAQAAAA==.',
['七丶']='七丶六丶五:BAAALgADCggJDgAAAA==.',
['七和']='七和弦:BAABLgAFFH8OAAIEAAQJtBd+BAAgAQAEAAQJtBd+BAAgAQAAAA==.',
['七月']='七月节:BAAALgAECgYJBwAAAA==.',
['七生']='七生:BAAALgAECgEJAQAAAA==.',
['三重']='三重牛德华:BAAALgAECgQJBgAAAA==.',
['上白']='上白泽慧音:BAAALgAECgUJBQAAAA==.',
['不吃']='不吃花生丶:BAAALgAECgYJDAAAAA==.',
['不服']='不服我练一个:BAAALgADCgUJBQAAAA==.',
['不知']='不知东方既白:BAAALgAECgUJBQAAAA==.',
['专业']='专业开马桶:BAAALgAECgEJAQAAAA==.',
['东海']='东海泥鳅:BAAALgAECggJDgAAAA==.',
['丨前']='丨前世今生丶:BAAALgAECgQJBAAAAA==.',
['丨龙']='丨龙凤呈祥丨:BAAALgAECgUJBQAAAA==.',
['中个']='中个彩票吧:BAAALgAECgcJDAABLgAFFAYJAgAJAAAAAA==.',
['丶小']='丶小瓶子丶:BAAALgAECgYJBgABLgAFFAUJBQADANEPAA==.',
['丶老']='丶老白:BAAALgAECgUJBQAAAA==.',
['丶陛']='丶陛下饶命:BAAALgAECgEJAQAAAA==.',
['丹羽']='丹羽灯莉:BAAALgAECgIJAgAAAA==.',
['为所']='为所欲为:BAAALgAECgMJBAAAAA==.',
['为爱']='为爱鼓掌:BAAALgAECgIJAgAAAA==.',
['之妤']='之妤:BAAALgAECgMJAwABLgAFFAYJEwALAGMRAA==.',
['乌里']='乌里麻里:BAAALgAECgYJCQAAAA==.',
['九溪']='九溪弥烟:BAAALgAECgYJCQAAAA==.',
['乱来']='乱来灬:BAABLgAFFH8GAAMCAAMJfBCBIQD+AAACAAMJfBCBIQD+AAALAAEJKAeAGABNAAAAAA==.',
['亍贝']='亍贝克:BAAALgADCgUJBQAAAA==.',
['五丶']='五丶六丶七:BAAALgAECgcJBwAAAA==.',
['五日']='五日市芽依:BAAALgAECgUJBQAAAA==.',
['五花']='五花马:BAACLgAFFH8HAAIMAAMJLgb1DQDoAAAMAAMJLgb1DQDoAAAuAAQKfxoAAwwACAlGFW8QAJ8BAAwACAlGFW8QAJ8BAAcAAwnmB24mAI0AAAAA.',
['井芹']='井芹仁菜:BAACLgAFFH8RAAQHAAUJkxr0AAB8AQAHAAQJkxr0AAB8AQANAAEJAABhJABWAAAMAAEJHQlDKABRAAAuAAQKfyEAAwcACAmNGPMLABACAAcABwk+F/MLABACAA0ABgmpDpZEAEIBAAAA.',
['亲密']='亲密接触:BAAALgAECgEJAgAAAA==.',
['人生']='人生短急个球:BAAALgAECgQJBAAAAA==.',
['亿点']='亿点点:BAAALgAFFAEJAQAAAA==.',
['今晚']='今晚要尽兴:BAAALgAECgEJAQAAAA==.',
['伊兰']='伊兰妮月歌:BAACLgAFFH8OAAIOAAQJQiE0AgBzAQAOAAQJQiE0AgBzAQAuAAQKfxcAAg4ACAnEIkIKAPECAA4ACAnEIkIKAPECAAAA.',
['伍百']='伍百:BAAALgAECgIJAgAAAA==.',
['伤心']='伤心词:BAABLgAFFH8GAAIDAAUJtRDdAgCdAQADAAUJtRDdAgCdAQAAAA==.',
['佐仓']='佐仓双叶:BAAALgAECgUJBgAAAA==.',
['余暇']='余暇:BAAALgAECgQJCAAAAA==.',
['你一']='你一生的故事:BAAALgAECgQJCgAAAA==.',
['你也']='你也是个人了:BAAALgAECgEJAQAAAA==.',
['侍尘']='侍尘:BAAALgAFFAEJAQAAAA==.',
['侏侏']='侏侏侠:BAAALgAECgEJAQAAAA==.',
['依神']='依神紫苑:BAAALgAECgEJAQAAAA==.',
['保持']='保持干燥:BAAALgAECgMJAwAAAA==.',
['傲天']='傲天:BAAALgAFFAEJAQAAAA==.',
['光头']='光头佬:BAAALgAECgQJBwAAAA==.',
['克拉']='克拉丽蒙德:BAAALgAECgQJCAAAAA==.',
['八手']='八手踢:BAAALgAFFAIJAwAAAA==.',
['六翼']='六翼残骸:BAABLgAFFH8FAAMPAAUJhheRAABrAQAPAAQJhheRAABrAQAQAAEJAAC5DwAAAAABLgAFFAUJBwABABkZAA==.',
['军团']='军团首席保镖:BAAALgAECgcJBwAAAA==.',
['冥界']='冥界镇魂曲:BAAALgAECgIJAgAAAA==.',
['冰岚']='冰岚:BAAALgAECgQJCAAAAA==.',
['冰见']='冰见晶:BAABLgAECn8gAAIRAAgJUCGaBQAIAwARAAgJUCGaBQAIAwAAAA==.',
['冰语']='冰语梦蝶:BAAALgAECgkJEgAAAA==.冰语梦霜:BAAALgAECgcJBwABLgAFFAUJEAASAC8lAA==.',
['冲动']='冲动的小牛牛:BAAALgAECgUJBgAAAA==.',
['冷凝']='冷凝冰:BAAALgAECgcJBwAAAA==.',
['冷酷']='冷酷女杀手乂:BAAALgAECgEJAQAAAA==.',
['凡星']='凡星:BAAALgAECgEJAQAAAA==.',
['刘强']='刘强壮:BAAALgAECgQJBAAAAA==.',
['别噶']='别噶:BAAALgAFFAQJAgAAAA==.',
['勇敢']='勇敢的心:BAAALgAECgYJBgAAAA==.',
['包吃']='包吃包住:BAAALgAECgQJBAAAAA==.',
['北原']='北原雪菜:BAACLgAFFH8QAAITAAUJfw2nBgCDAQATAAUJfw2nBgCDAQAuAAQKfyEAAhMACAmQGroZAH4CABMACAmQGroZAH4CAAAA.',
['十二']='十二重梦境:BAAALgAFFAUJAwABLgAFFAUJBwABABkZAA==.',
['十五']='十五月蚀:BAAALgAFFAUJAwABLgAFFAUJBwABABkZAA==.',
['十四']='十四岁的夏天:BAAALgAFFAUJBAABLgAFFAUJBwABABkZAA==.十四行绝诗:BAABLgAFFH8FAAMBAAUJ1xI7PgCiAAABAAQJ1xI7PgCiAAAQAAEJAAAAAAAAAAABLgAFFAUJBwABABkZAA==.',
['千寻']='千寻靓影:BAAALgADCgEJAQAAAA==.',
['千里']='千里续:BAAALgAECgEJAQAAAA==.',
['午夜']='午夜撸键盘:BAACLgAFFH8GAAMNAAMJgQ5EHgCdAAAHAAIJBgjwBgCgAAANAAIJeQ5EHgCdAAAuAAQKfykABA0ACAn3HuUVAH4CAA0ACAmpHeUVAH4CAAwAAgnWHdyOAL4AAAcAAgnyFssQAKYAAAAA.',
['半夏']='半夏薇凉:BAAALgAECgEJAQAAAA==.',
['卢米']='卢米安:BAAALgAECgIJAgAAAA==.',
['原味']='原味发酵乳:BAAALgAECgIJAgAAAA==.',
['原村']='原村和:BAAALgAFFAIJAgAAAA==.',
['双生']='双生悖论:BAABLgAFFH8GAAQPAAUJ2A8SAQBEAQAPAAQJtwoSAQBEAQABAAEJqxulTgBWAAAQAAEJAADVDwAAAAABLgAFFAUJBwABABkZAA==.',
['发一']='发一次呆:BAAALgAFFAEJAQAAAA==.',
['另一']='另一萨:BAAALgADCgEJAQAAAA==.',
['可樂']='可樂:BAAALgAECgIJAwAAAA==.',
['吃我']='吃我一耳屎:BAAALgAFFAIJAgAAAA==.',
['吉姆']='吉姆丶雷诺:BAAALgAECgIJAgAAAA==.',
['吉马']='吉马忠:BAAALgAECgQJBQAAAA==.',
['吊尔']='吊尔郎:BAAALgAECgMJAwAAAA==.',
['否否']='否否:BAAALgAECgEJAQAAAA==.',
['命运']='命运丨灵魂丶:BAAALgAECgEJAQAAAA==.',
['和平']='和平行者:BAAALgADCgYJCgAAAA==.',
['咕咕']='咕咕会振翅:BAABLgAFFH8GAAIOAAQJFBKfCABYAQAOAAQJFBKfCABYAQAAAA==.',
['咕灬']='咕灬咕:BAABLgAECn8VAAIOAAYJbxBtQwAiAQAOAAYJbxBtQwAiAQAAAA==.',
['咿然']='咿然巜:BAAALgAECgQJBgAAAA==.',
['哆尔']='哆尔哆:BAAALgADCgIJAgAAAA==.',
['哈好']='哈好好:BAAALgADCgYJCQAAAA==.',
['哈骑']='哈骑米:BAAALgAECgIJAgAAAA==.',
['哥洗']='哥洗脚哇:BAAALgAECgEJAQAAAA==.',
['哲思']='哲思的加菲猫:BAAALgAFFAUJAwABLgAFFAUJBwABABkZAA==.',
['喵哆']='喵哆狸狸:BAAALgAECgIJAgAAAA==.',
['嗜血']='嗜血丨小粉:BAAALgAFFAEJAQAAAA==.嗜血伤残:BAAALgAECgUJBQAAAA==.',
['噪音']='噪音音:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光丶钟:BAAALgAECgMJAwAAAA==.圣光护佑尼:BAAALgADCgEJAQAAAA==.',
['圣索']='圣索菲亚:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱丨战歌:BAAALgAFFAMJBAAAAA==.地狱丶猫:BAABLgAFFH8IAAINAAQJ4B3kCgBpAQANAAQJ4B3kCgBpAQAAAA==.',
['坎怕']='坎怕斯:BAAALgAECgEJAgAAAA==.',
['垮酷']='垮酷尔:BAAALgADCgYJBgAAAA==.',
['壹点']='壹点虚数:BAABLgAFFH8GAAIBAAQJDxx3DQBtAQABAAQJDxx3DQBtAQABLgAFFAUJBwABABkZAA==.',
['壹瓶']='壹瓶可乐:BAAALgAECgkJCQAAAA==.',
['夏槿']='夏槿拂风:BAAALgAFFAIJBAAAAA==.',
['夜清']='夜清枫:BAAALgAECgEJAgAAAA==.',
['夜雨']='夜雨微风:BAAALgADCgcJDAAAAA==.',
['大肥']='大肥鸡起飞:BAAALgADCgIJAgAAAA==.',
['天宫']='天宫心:BAABLgAFFH8IAAIUAAUJyB+9AQB+AQAUAAUJyB+9AQB+AQAAAA==.',
['天意']='天意之秋:BAAALgAFFAIJAgAAAA==.',
['天魔']='天魔劫火:BAAALgAECgIJAgABLgAFFAIJBAAJAAAAAA==.',
['天黑']='天黑有灯:BAAALgAECgYJCQAAAA==.',
['头上']='头上长包:BAAALgAECgMJAwAAAA==.',
['奇奇']='奇奇妹怒吼:BAAALgAECgEJAQAAAA==.',
['奕暖']='奕暖:BAAALgADCgYJBgAAAA==.',
['女流']='女流氓阿沁:BAAALgAECgEJAQAAAA==.',
['奶爸']='奶爸打电脑:BAAALgAECgIJAgAAAA==.',
['奶瓶']='奶瓶洗一下:BAAALgAECgYJCQAAAA==.',
['奶黄']='奶黄好久不见:BAAALgAECgYJBwAAAA==.',
['好汉']='好汉来了:BAAALgAECgYJCQAAAA==.',
['宁缺']='宁缺:BAACLgAFFH8MAAMCAAUJURBgDAB5AQACAAUJURBgDAB5AQALAAEJVgbSGABMAAAuAAQKfxoAAwsACAnuG+QZAH0BAAIABgkhGVtVAMgBAAsABQnrF+QZAH0BAAAA.',
['宇宙']='宇宙术大王:BAACLgAFFH8LAAMLAAQJfiS9AAAkAQALAAQJTCS9AAAkAQACAAEJVybpJgB0AAAuAAQKfxkAAwsABgmzJo4EAJcCAAsABgmQJo4EAJcCAAIAAQnUJlL0AHAAAAAA.',
['安室']='安室白:BAAALgADCgEJAQAAAA==.',
['安洛']='安洛希雅:BAABLgAFFH8HAAIVAAMJWSbcCgBVAQAVAAMJWSbcCgBVAQAAAA==.',
['宋东']='宋东野:BAAALgAECgEJAQAAAA==.',
['寒风']='寒风兮兮:BAAALgAFFAQJAQAAAA==.',
['寛雲']='寛雲窄雨:BAAALgAECgEJAgAAAA==.',
['寻觅']='寻觅觅:BAAALgAFFAQJBAABLgAFFAUJBQAWAN8aAA==.',
['小丑']='小丑在哪:BAAALgADCgMJAwAAAA==.',
['小哑']='小哑巴:BAAALgAECgEJAQAAAA==.',
['小小']='小小白羊座:BAAALgAFFAMJAwAAAA==.小小瞇糊:BAAALgAECgIJAgAAAA==.',
['小柠']='小柠檬丶:BAAALgAFFAIJAgAAAA==.',
['小洛']='小洛丽塔:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊哞:BAAALgAECgEJAwAAAA==.',
['小玉']='小玉玉:BAAALgAECgUJBQAAAA==.',
['小白']='小白兔丢核弹:BAAALgAECgIJBAAAAA==.',
['小矮']='小矮砸长高高:BAAALgAECgMJAwAAAA==.',
['小蕃']='小蕃茄:BAAALgAECgEJAgAAAA==.',
['小蜜']='小蜜橘丶:BAAALgAECgQJBAAAAA==.',
['小邪']='小邪邪:BAAALgAECgEJAQAAAA==.',
['小雀']='小雀斑:BAAALgAECgMJAwABLgAECgYJFgAXALQQAA==.',
['小鹿']='小鹿:BAACLgAFFH8QAAIGAAUJiR4nCADgAQAGAAUJiR4nCADgAQAuAAQKfy8AAgYACQk4JGkDAMkDAAYACQk4JGkDAMkDAAAA.',
['尼古']='尼古拉斯圣骑:BAAALgADCgEJAQAAAA==.',
['山田']='山田仁菜:BAAALgAECgQJBAAAAA==.',
['左思']='左思右想:BAAALgADCgMJAwAAAA==.',
['巫行']='巫行雲:BAAALgAECgYJBgAAAA==.',
['布兰']='布兰多:BAAALgAFFAEJAQAAAA==.',
['帕维']='帕维尔无敌:BAAALgAECgkJCQAAAA==.',
['帝国']='帝国的撒库拉:BAABLgAECn8YAAMYAAcJwhgLJgD3AQAYAAcJwhgLJgD3AQAVAAUJdxKTLAAaAQAAAA==.',
['平原']='平原美弦:BAAALgAECgUJBQAAAA==.',
['年糕']='年糕爸爸:BAABLgAFFH8LAAIFAAQJERj4BAA6AQAFAAQJERj4BAA6AQAAAA==.',
['幽幽']='幽幽子:BAAALgAFFAMJBAAAAA==.',
['开始']='开始你的秀:BAABLgAFFH8GAAIVAAQJLRQYCwBTAQAVAAQJLRQYCwBTAQAAAA==.',
['开心']='开心芯:BAAALgAECgMJBAAAAA==.',
['御嶽']='御嶽海:BAACLgAFFH8RAAIZAAUJ7iC6AgC+AQAZAAUJ7iC6AgC+AQAuAAQKfxcAAhkACAkrIoUKAOECABkACAkrIoUKAOECAAAA.',
['御手']='御手洗杯麵:BAAALgADCgUJBQAAAA==.',
['御龙']='御龙天尊:BAAALgAECgQJBAAAAA==.',
['德德']='德德没想好:BAAALgAECgQJAwAAAA==.',
['德财']='德财皆无:BAAALgADCgYJBgAAAA==.',
['急袭']='急袭猛禽:BAAALgADCgIJAgAAAA==.',
['悍丨']='悍丨丨馬:BAAALgADCgEJAQAAAA==.悍丨丨马:BAAALgADCgMJAwAAAA==.',
['悔无']='悔无崖:BAAALgAECgUJCgAAAA==.',
['悦星']='悦星战神:BAAALgADCgMJAwAAAA==.',
['慕斯']='慕斯:BAAALgAECgIJAgAAAA==.',
['慕烟']='慕烟奕暖:BAAALgAECgQJBAAAAA==.',
['慷慨']='慷慨的加菲猫:BAAALgAFFAUJAgABLgAFFAUJBwABABkZAA==.',
['成都']='成都:BAAALgAECgYJDgAAAA==.',
['我哈']='我哈哈:BAAALgAECgQJBgAAAA==.',
['我的']='我的角大嘛:BAAALgAECgMJAgAAAA==.',
['战神']='战神无双:BAAALgAFFAIJBAAAAA==.',
['戰神']='戰神丶:BAABLgAECn8VAAQaAAYJdxi7HABiAQAaAAUJGhi7HABiAQATAAUJAhQUYAAwAQAXAAIJYhuHKQClAAAAAA==.',
['扉页']='扉页早已翻烂:BAAALgAECgIJAgAAAA==.',
['手心']='手心中的蔷薇:BAAALgAECgQJBAAAAA==.',
['找到']='找到那片海:BAAALgAECgEJAQAAAA==.',
['折戟']='折戟丿:BAAALgADCgUJBQAAAA==.',
['拉芙']='拉芙希妮:BAAALgAFFAEJAgAAAA==.',
['拯救']='拯救大兵雷轰:BAAALgADCgEJAQAAAA==.',
['提尔']='提尔比茨:BAAALgAECggJEwAAAA==.',
['救世']='救世星龙:BAACLgAFFH8HAAMbAAMJ/RB8BAD6AAAbAAMJsg98BAD6AAAcAAIJHA0yGgCZAAAuAAQKfx8ABBsACAl3HlwFAKkCABsACAmWHFwFAKkCAB0ABwmxEQ8cAKYBABwAAgmrGjhLAKYAAAAA.',
['斩鵺']='斩鵺:BAAALgADCgEJAQAAAA==.',
['新堂']='新堂愛:BAACLgAFFH8RAAMIAAUJjxUuBQCJAQAIAAUJjxUuBQCJAQAOAAEJugBUHABFAAAuAAQKfxsAAw4ACAncDxopALYBAA4ACAncDxopALYBAAgAAgk0FFOlAH4AAAAA.',
['方丈']='方丈丨伏虎:BAABLgAFFH8JAAIZAAMJ7gRRFwC2AAAZAAMJ7gRRFwC2AAAAAA==.',
['无尽']='无尽的德:BAAALgAECgQJBAAAAA==.',
['无心']='无心丶:BAAALgAECgcJBwAAAA==.',
['星图']='星图:BAAALgAECgYJCwAAAA==.',
['春曰']='春曰野穹:BAAALgAFFAEJAQAAAA==.',
['暗之']='暗之忧伤:BAAALgAECgEJAQAAAA==.',
['曼波']='曼波:BAABLgAFFH8HAAIEAAQJtRRABgBjAQAEAAQJtRRABgBjAQAAAA==.',
['最爱']='最爱炒刀削:BAAALgADCgMJAwAAAA==.',
['望雪']='望雪丶:BAAALgAECgcJBwAAAA==.',
['朝武']='朝武芳乃:BAACLgAFFH8RAAIQAAUJ5RKOBQBGAQAQAAUJ5RKOBQBGAQAuAAQKfxcAAhAACAmfGycPABkCABAACAmfGycPABkCAAAA.',
['末丶']='末丶洛:BAAALgAECgkJEAABLgAFFAUJDgAVAE4mAA==.',
['本质']='本质骑士:BAAALgAECggJDQAAAA==.',
['杜若']='杜若:BAAALgAECgMJAwAAAA==.',
['杨永']='杨永信:BAAALgAFFAIJAgAAAA==.',
['松浦']='松浦果南:BAAALgAFFAEJAQAAAA==.',
['林北']='林北贞渡岚:BAAALgAECgYJEQAAAA==.',
['染血']='染血的小黄瓜:BAAALgAECgYJBwAAAA==.',
['柚叶']='柚叶久远:BAAALgADCgUJBQAAAA==.',
['栀夏']='栀夏丶:BAAALgAFFAQJBAAAAA==.',
['桃乐']='桃乐丝:BAABLgAFFH8FAAISAAIJKBawEgC1AAASAAIJKBawEgC1AAAAAA==.',
['桃花']='桃花影落神剑:BAAALgAECgQJAgAAAA==.',
['桥倒']='桥倒麻袋:BAAALgAECgYJBwAAAA==.',
['梅丽']='梅丽亚斯:BAAALgADCgEJAQABLgAFFAcJBAAJAAAAAA==.',
['梅人']='梅人杏:BAAALgAFFAQJBAAAAA==.',
['梦璃']='梦璃夜天星:BAACLgAFFH8XAAIOAAYJOCQ+AAD5AQAOAAYJOCQ+AAD5AQAuAAQKfykAAg4ACQnlJWcAAO8DAA4ACQnlJWcAAO8DAAAA.',
['梦里']='梦里知花落:BAAALgAECgkJDQAAAA==.',
['梨谱']='梨谱橙子:BAAALgAFFAQJBAAAAA==.',
['森海']='森海轮回:BAAALgAFFAEJAQAAAA==.',
['楽尒']='楽尒:BAAALgADCgcJCgAAAA==.',
['榴莲']='榴莲留恋牛奶:BAAALgAECgEJAQAAAA==.',
['橘子']='橘子的香水:BAAALgAECgIJAgAAAA==.',
['歌音']='歌音:BAAALgAECgIJAgAAAA==.',
['止杀']='止杀:BAAALgAFFAEJAQAAAA==.',
['正统']='正统高岭:BAAALgAECgUJBQAAAA==.',
['武林']='武林高手:BAAALgAFFAEJAQAAAA==.',
['死亡']='死亡之叹息:BAAALgADCgEJAQAAAA==.',
['死前']='死前巨餓:BAAALgAECgQJCAAAAA==.',
['死尸']='死尸级小白:BAAALgAECgEJAQAAAA==.',
['死屍']='死屍级小白:BAAALgAECgEJAQAAAA==.',
['毁灭']='毁灭闪电:BAAALgAECgMJAwAAAA==.',
['比达']='比达格拉斯:BAAALgAECgEJAgAAAA==.',
['水妙']='水妙妙:BAAALgAECgQJBAAAAA==.',
['水晶']='水晶般透明:BAAALgAFFAEJAQAAAA==.',
['水渺']='水渺渺:BAAALgAFFAIJAgAAAA==.',
['水茜']='水茜茜:BAABLgAFFH8HAAICAAMJngyBFAD1AAACAAMJngyBFAD1AAAAAA==.',
['永信']='永信烧烤:BAAALgAECgYJCwAAAA==.',
['永玄']='永玄大帝:BAAALgAECgIJAgAAAA==.',
['江口']='江口结瞳:BAAALgAECgQJBAAAAA==.',
['江涵']='江涵:BAAALgAFFAIJAwAAAA==.',
['江边']='江边一碗水:BAAALgAECgUJBQAAAA==.',
['沁沁']='沁沁小无敌:BAAALgAECgUJBQAAAA==.沁沁快睡觉:BAAALgAECgMJAwAAAA==.',
['沫紫']='沫紫:BAAALgAECgcJBwAAAA==.',
['治外']='治外狂徒:BAAALgAFFAMJAwAAAA==.',
['法力']='法力值不足:BAAALgAECgQJBQAAAA==.',
['洋葱']='洋葱一棵树:BAAALgAECgEJAQAAAA==.',
['流涟']='流涟飞絮:BAAALgAECgEJAQAAAA==.',
['浅葱']='浅葱:BAACLgAFFH8RAAMCAAUJ2yM3BQBtAQACAAUJLSI3BQBtAQALAAEJMiQ1EABmAAAuAAQKfxsAAwIACAnDItAeAJ4CAAIABwmfItAeAJ4CAAsAAwllHmc0AOUAAAEuAAUUBwkKAAYA7hwA.',
['浓情']='浓情随翌:BAAALgADCgEJAQAAAA==.',
['海苹']='海苹果:BAAALgAFFAIJAgAAAA==.',
['消失']='消失闷棍:BAAALgAECgEJAQAAAA==.',
['清泷']='清泷桂香:BAACLgAFFH8RAAICAAUJIBcpBwCxAQACAAUJIBcpBwCxAQAuAAQKfxYAAwIACAkpHkEvAFACAAIABwkpHkEvAFACAAsAAQkAAOZeAFIAAAAA.',
['清酒']='清酒微凉:BAAALgAECgYJBgAAAA==.',
['清野']='清野:BAAALgADCgUJBQAAAA==.',
['漓泉']='漓泉在手:BAAALgAECgUJCgAAAA==.',
['潶色']='潶色記憶:BAAALgAECgIJAgAAAA==.',
['火炎']='火炎焱燚:BAAALgADCgIJAgAAAA==.',
['火狐']='火狐小地:BAAALgAECgcJEwAAAA==.',
['灬武']='灬武神:BAABLgAFFH8KAAIZAAQJ9Qc+EQD0AAAZAAQJ9Qc+EQD0AAAAAA==.',
['灬犇']='灬犇仔:BAABLgAFFH8GAAQIAAIJoA/LGwCNAAAIAAIJoA/LGwCNAAAOAAEJIAhVGwBJAAAeAAIJ1QBzBABCAAAAAA==.',
['炎東']='炎東丶:BAAALgAECgEJAQAAAA==.',
['烧报']='烧报纸哄鬼:BAAALgAECgcJAgAAAA==.',
['热疯']='热疯了:BAAALgAECgkJBwABLgAFFAQJBwAFAIcHAA==.',
['煩嘞']='煩嘞:BAAALgAECgEJAQAAAA==.',
['爆改']='爆改哈基米:BAAALgAFFAMJBAAAAA==.',
['特猫']='特猫务:BAAALgAECgYJDgAAAA==.',
['特蕾']='特蕾西娅:BAABLgAFFH8PAAIBAAUJTSGPAgDoAQABAAUJTSGPAgDoAQAAAA==.',
['犇犇']='犇犇牛牛:BAAALgAECgIJAgAAAA==.',
['狐狸']='狐狸萨:BAAALgAECgYJCwAAAA==.',
['猪头']='猪头山大魔王:BAAALgAECgUJCAAAAA==.',
['王呵']='王呵呵:BAAALgADCgIJAgAAAA==.',
['玖姑']='玖姑娘:BAAALgAFFAIJBAAAAA==.',
['生前']='生前十分强:BAAALgAFFAEJAQAAAA==.',
['生物']='生物竞赛:BAAALgADCgUJBQAAAA==.',
['生生']='生生死死:BAAALgAECgMJBQAAAA==.',
['甲基']='甲基橙:BAAALgADCgYJBwAAAA==.',
['疯狂']='疯狂钻石:BAAALgAECgQJBQAAAA==.',
['痱子']='痱子哭哭:BAAALgADCgEJAQAAAA==.',
['白色']='白色恋人:BAAALgAECgcJBwAAAA==.',
['白贞']='白贞:BAAALgAFFAIJBAAAAA==.',
['百变']='百变马丁:BAAALgAECgYJCQAAAA==.',
['监正']='监正:BAAALgAECgEJAQAAAA==.',
['目睹']='目睹温柔丶:BAAALgAECgkJEAAAAA==.',
['盾娘']='盾娘也很萌:BAACLgAFFH8GAAMBAAMJYR9aGgC8AAABAAMJYR9aGgC8AAAPAAIJCBVyBABaAAAuAAQKfyMABAEABwndJGcuAH8CAAEABgnuJGcuAH8CAA8ABQmQG4ICAHEBABAAAQkMJPcUAGAAAAAA.',
['真幽']='真幽兔无双:BAAALgAECggJEwAAAA==.',
['眠思']='眠思梦想:BAAALgAECgcJEgAAAA==.',
['睿丶']='睿丶寶:BAAALgAECgEJAQAAAA==.',
['瞎已']='瞎已丨不是虾:BAAALgAECgYJBgAAAA==.',
['破冰']='破冰逐夜:BAAALgAECgUJBQAAAA==.',
['破镜']='破镜菲尔:BAACLgAFFH8JAAMWAAQJKha5EQBBAQAWAAQJixG5EQBBAQAfAAIJox64AwC3AAAuAAQKfxYAAxYACAkJHlAhAIkCABYACAnXG1AhAIkCAB8ABglWI5oUACsCAAAA.',
['硬尾']='硬尾:BAAALgAECgEJAwAAAA==.',
['神说']='神说还有光:BAABLgAFFH8HAAMMAAMJ0RrSEQC8AAAMAAIJTBrSEQC8AAANAAIJdRwTGgCzAAAAAA==.',
['神贞']='神贞:BAAALgAECgQJBAAAAA==.',
['秋叶']='秋叶:BAAALgADCgUJBQAAAA==.',
['空丨']='空丨白:BAAALgAFFAIJAgAAAA==.',
['空气']='空气炸锅:BAAALgAECgkJCQAAAA==.',
['第四']='第四扇窗:BAABLgAFFH8FAAMPAAUJbxaxAABiAQAPAAQJbxaxAABiAQAQAAEJAADSDwAAAAABLgAFFAUJBwABABkZAA==.',
['简繁']='简繁:BAAALgAECgYJCAAAAA==.',
['箭羽']='箭羽苍穹:BAAALgAECgkJBgAAAA==.',
['米奥']='米奥莉奈:BAABLgAFFH8HAAIOAAQJKh+2BQAkAQAOAAQJKh+2BQAkAQABLgAFFAQJCQAWACoWAA==.',
['糖女']='糖女王:BAAALgADCgcJBwAAAA==.',
['索菲']='索菲熊熊:BAAALgAECgUJBwAAAA==.',
['红烧']='红烧土豆:BAAALgAECgQJBgAAAA==.',
['纯情']='纯情丿小母牛:BAAALgADCgEJAQAAAA==.',
['纯洁']='纯洁的小爱:BAAALgADCgEJAQAAAA==.',
['结实']='结实的板板:BAAALgAECgUJBQAAAA==.',
['绝活']='绝活海:BAAALgAFFAEJAQAAAA==.',
['继国']='继国缘一:BAAALgAECgkJBwABLgAFFAUJCwAWAF0kAA==.',
['绫地']='绫地宁宁:BAAALgAFFAIJAgAAAA==.',
['绿侠']='绿侠的骚气:BAAALgAECgMJAwAAAA==.',
['绿鼻']='绿鼻涕:BAAALgAECgQJBAAAAA==.',
['罪与']='罪与罚与赎:BAABLgAECn8dAAITAAgJ2CKjCwD9AgATAAgJ2CKjCwD9AgABLgAFFAUJDwABAE0hAA==.',
['美刀']='美刀见雪:BAAALgAECgkJCQABLgAECgkJDgAJAAAAAA==.',
['肥腩']='肥腩仔:BAAALgAECgIJAgAAAA==.',
['胡来']='胡来灬:BAAALgAECgEJAQAAAA==.',
['花开']='花开纪年丶:BAAALgAECgMJAwAAAA==.',
['花花']='花花丶:BAAALgAFFAEJAQAAAA==.',
['苏念']='苏念乐:BAABLgAECn8YAAIGAAcJPx75HwB4AQAGAAcJPx75HwB4AQAAAA==.',
['苟尔']='苟尔丹:BAAALgAECgEJAgAAAA==.',
['若说']='若说花事了:BAAALgAECgkJCQAAAA==.',
['范星']='范星:BAAALgAECgMJBQAAAA==.',
['茉莉']='茉莉龙井:BAAALgAECgkJCQAAAA==.',
['茵素']='茵素:BAAALgAECgUJBQABLgAFFAYJDQALAOgiAA==.',
['荒野']='荒野:BAAALgAECgYJBgAAAA==.',
['莱因']='莱因哈特:BAAALgADCgUJBQAAAA==.',
['菊花']='菊花真荡漾:BAAALgAECgYJBwAAAA==.',
['菲伦']='菲伦:BAACLgAFFH8GAAMcAAQJkRbvCAAOAQAcAAMJDBXvCAAOAQAbAAMJJBalBQC3AAAuAAQKfyEAAxsACAlqHKIFAKICABsACAlqHKIFAKICABwABAmoDt1IALQAAAEuAAUUBQkPAAEATSEA.',
['葡萄']='葡萄啵啵冰:BAAALgAECgEJAQAAAA==.',
['薹汈']='薹汈:BAAALgADCgIJAgAAAA==.',
['蛇踏']='蛇踏嵐丶:BAAALgAECgUJBQAAAA==.',
['蛮腰']='蛮腰:BAAALgAECgEJAQAAAA==.',
['血月']='血月影彧:BAAALgAFFAQJBAAAAA==.',
['血爪']='血爪佩佩:BAAALgAECgYJAgAAAA==.',
['街溜']='街溜子:BAAALgAECgYJEQAAAA==.',
['衣锦']='衣锦夜行丶:BAAALgAECgYJBgAAAA==.',
['表看']='表看我眼睛:BAACLgAFFH8HAAIWAAIJqxPiJwCiAAAWAAIJqxPiJwCiAAAuAAQKfxwAAhYABwkBIPQrAE8CABYABwkBIPQrAE8CAAAA.',
['西尾']='西尾夕香:BAABLgAFFH8OAAINAAUJ0SIbAQCKAQANAAUJ0SIbAQCKAQAAAA==.',
['西瓜']='西瓜变成菠萝:BAAALgAECgQJBwAAAA==.',
['训练']='训练师毛毛:BAAALgAFFAIJAwABLgAFFAQJCwALAH4kAA==.',
['请你']='请你检阅:BAAALgAECgUJCgAAAA==.',
['诸葛']='诸葛亮:BAAALgADCgEJAQAAAA==.',
['貝微']='貝微微:BAAALgAECgQJBAAAAA==.',
['贪吃']='贪吃的加菲猫:BAABLgAFFH8GAAMBAAQJTR+zGADOAAABAAMJTR+zGADOAAAQAAEJAAAAAAAAAAABLgAFFAUJBwABABkZAA==.',
['贪睡']='贪睡的加肥猫:BAAALgAFFAUJAQABLgAFFAUJBwABABkZAA==.',
['赖哒']='赖哒:BAAALgADCgIJAQAAAA==.',
['赛兰']='赛兰迪丝:BAAALgAECgQJBAAAAA==.',
['达文']='达文西裂蹄:BAAALgAECgQJBwAAAA==.',
['达维']='达维安:BAAALgAECgMJAQAAAA==.',
['还在']='还在毛:BAAALgAECgMJAwAAAA==.',
['进击']='进击的辣子鸡:BAACLgAFFH8IAAIZAAQJaBnBCABIAQAZAAQJaBnBCABIAQAuAAQKfxUAAhkABwkUHeslANUBABkABwkUHeslANUBAAEuAAUUBQkJABkAjhgA.',
['迸裂']='迸裂:BAAALgAECgMJBAAAAA==.',
['逍遥']='逍遥无忧:BAAALgAECgEJAQAAAA==.',
['逛街']='逛街闲的:BAAALgAECgEJAQAAAA==.',
['遇术']='遇术临疯丶:BAAALgAECgIJAgAAAA==.',
['那个']='那个史骑:BAAALgAECgMJAwAAAA==.',
['鄂人']='鄂人王:BAAALgADCgUJBQAAAA==.',
['酒寄']='酒寄彩叶:BAACLgAFFH8QAAQBAAUJWBuhDABxAQABAAQJLhuhDABxAQAPAAQJzQR1AQAmAQAQAAEJAAC+FwA8AAAuAAQKfxsAAwEACAmZIcgdAM4CAAEACAmZIcgdAM4CABAAAgnJGek1AJIAAAAA.',
['酥脆']='酥脆托尔尾肉:BAAALgAECgQJBAAAAA==.',
['醉生']='醉生丶:BAAALgAECgMJBgAAAA==.',
['重火']='重火力曼波:BAAALgAFFAEJAQAAAA==.',
['重铸']='重铸邪能:BAAALgAFFAIJAgABLgAFFAMJBQACAEEQAA==.',
['鐡甲']='鐡甲依旧在:BAABLgAECn8VAAMTAAYJ8hAbUgBhAQATAAYJ8hAbUgBhAQAaAAEJfQbhSQAqAAAAAA==.',
['钦钦']='钦钦威震天:BAAALgAFFAMJAwAAAA==.',
['铁甲']='铁甲依旧在:BAAALgAECgcJCQAAAA==.',
['长崎']='长崎素时:BAAALgAECgQJAwAAAA==.',
['问题']='问题不大:BAAALgAECgEJAQAAAA==.',
['队友']='队友伍佰斤:BAAALgAFFAEJAQAAAA==.',
['阿卡']='阿卡林:BAAALgADCgEJAQAAAA==.',
['阿斯']='阿斯卡伦:BAAALgAECgEJAQABLgAFFAQJCAABAEcWAA==.',
['阿梅']='阿梅达希尔:BAAALgADCgcJBwAAAA==.',
['阿莫']='阿莫西林:BAAALgAECgIJAgAAAA==.',
['阿落']='阿落奈非:BAAALgADCgUJBQAAAA==.',
['阿蘭']='阿蘭貝爾:BAAALgAECgEJAgABLgAFFAUJDAACAK0mAA==.',
['阿雪']='阿雪:BAAALgAFFAQJBAAAAA==.',
['陌上']='陌上桑:BAAALgAECgYJDAAAAA==.',
['雨之']='雨之子:BAAALgAECgYJDgAAAA==.',
['雪夜']='雪夜悠悠:BAACLgAFFH8GAAIcAAIJmgKdHQCBAAAcAAIJmgKdHQCBAAAuAAQKfxwAAx0ABwm9HqMMAGsCAB0ABwm9HqMMAGsCABwABwlWDykpAHQBAAAA.',
['雪花']='雪花牛:BAAALgAECgMJAwAAAA==.',
['零之']='零之回响:BAABLgAFFH8HAAIBAAQJGRmHDABxAQABAAQJGRmHDABxAQAAAA==.',
['雷伽']='雷伽:BAAALgAECgQJBwAAAA==.',
['霸気']='霸気歪撸:BAAALgADCgYJBgABLgAECgYJAQAJAAAAAA==.',
['青春']='青春的活力:BAAALgADCgQJBAAAAA==.',
['青果']='青果喵喵:BAAALgAECgUJBwAAAA==.',
['青阳']='青阳:BAAALgAECgEJAQAAAA==.',
['青鸟']='青鸟:BAAALgADCgIJAgAAAA==.',
['韩丶']='韩丶小雅:BAAALgAECgMJAwAAAA==.',
['风鸣']='风鸣翼:BAACLgAFFH8FAAIBAAMJ3gXrLgDcAAABAAMJ3QXrLgDcAAAuAAQKfx0AAgEACAmRFPRUAPMBAAEACAmRFPRUAPMBAAAA.',
['马踏']='马踏王庭:BAAALgADCgMJBAAAAA==.',
['骨龍']='骨龍天:BAAALgAECgEJAQAAAA==.',
['高桥']='高桥凉介丶:BAABLgAFFH8GAAIZAAIJcRfqGgCTAAAZAAIJcRfqGgCTAAAAAA==.',
['魂魄']='魂魄妖梦:BAACLgAFFH8RAAMdAAUJ7hBVBgCNAQAdAAUJ7hBVBgCNAQAcAAEJIAzLIgBIAAAuAAQKfxsAAx0ACAmAGKsTAAkCAB0ABwnEGasTAAkCABwAAQkLATxpACMAAAAA.',
['魔牙']='魔牙:BAAALgADCgUJBQAAAA==.',
['魔箭']='魔箭士艾希尔:BAAALgADCgEJAQAAAA==.',
['鲁鲁']='鲁鲁嘉:BAAALgADCgUJBQAAAA==.',
['鶴竜']='鶴竜:BAAALgAFFAIJAgAAAA==.',
['鸳鸯']='鸳鸯羽:BAAALgAECgEJAgAAAA==.',
['鹭沢']='鹭沢文香:BAABLgAFFH8IAAIZAAQJxBoJCABRAQAZAAQJxBoJCABRAQAAAA==.',
['鹭泽']='鹭泽文香:BAABLgAECn8bAAMVAAgJWRjdMQBbAgAVAAgJWRjdMQBbAgAYAAEJWQMQnwAqAAAAAA==.',
['鹿悦']='鹿悦芳华:BAAALgAECgIJAgABLgAFFAMJBAAJAAAAAA==.',
['鹿枕']='鹿枕月眠:BAAALgAFFAMJBAAAAA==.',
['鹿沉']='鹿沉星河:BAABLgAFFH8HAAIZAAIJbAqmEQB/AAAZAAIJbAqmEQB/AAABLgAFFAMJBAAJAAAAAA==.',
['鹿眠']='鹿眠花下:BAAALgADCgYJBgABLgAFFAMJBAAJAAAAAA==.',
['鹿祈']='鹿祈星野:BAAALgAECgcJEwAAAA==.',
['鹿衔']='鹿衔:BAABLgAFFH8KAAICAAMJBhX1FADyAAACAAMJBhX1FADyAAAAAA==.',
['鹿饮']='鹿饮山泽:BAAALgAECgQJBgAAAA==.',
['麒麟']='麒麟儿:BAAALgADCgUJBQAAAA==.',
['麓娜']='麓娜:BAAALgAECgMJBQAAAA==.',
['黑暗']='黑暗奶牛:BAAALgAECgIJAgAAAA==.',
['黑腕']='黑腕泽法:BAAALgAECgcJBAAAAA==.',
['黑锋']='黑锋呆牛:BAAALgAECgcJBwAAAA==.',
['龍傲']='龍傲天:BAAALgAECgYJBwAAAA==.',
['龙胆']='龙胆尊:BAABLgAFFH8MAAIWAAUJcBn9BgC0AQAWAAUJcBn9BgC0AQAAAA==.',
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
