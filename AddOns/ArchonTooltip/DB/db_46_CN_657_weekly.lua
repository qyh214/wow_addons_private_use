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

local lookup = {'Mage-Frost','DemonHunter-Devourer','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Havoc','Mage-Arcane','Warlock-Affliction','Druid-Balance','Paladin-Retribution','Paladin-Holy','DemonHunter-Vengeance','Warrior-Protection','Rogue-Subtlety','Monk-Mistweaver','Priest-Holy','Hunter-Survival','Shaman-Restoration','Warrior-Fury','Warrior-Arms','DeathKnight-Frost','Shaman-Elemental','Paladin-Protection','Priest-Shadow','Druid-Restoration','Priest-Discipline','Warlock-Ranged','Monk-Windwalker','Monk-Brewmaster','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation',}
local provider = {region='CN',realm='寒冰皇冠',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adcarry:BAAALgAFFAIJAwAAAA==.',
Ae='Aegiss:BAAALgAECgQJBAAAAA==.',
Ai='Aite:BAABLgAECn8WAAIBAAcJ4BHhIABQAQABAAcJ4BHhIABQAQAAAA==.',
An='Anduril:BAABLgAFFH8HAAICAAQJ1BNbEgA+AQACAAQJ1BNbEgA+AQAAAA==.',
Ba='Barber:BAAALgAECgQJAwAAAA==.',
Bo='Bookboon:BAAALgAFFAQJBAAAAA==.Boonten:BAAALgAECgcJDQAAAA==.',
Ca='Carmier:BAAALgADCgcJBwAAAA==.',
Ch='Changr:BAAALgAECgcJCQAAAA==.',
Co='Corbusier:BAAALgAECgMJAwAAAA==.',
Dd='Ddloading:BAAALgAECgcJCAAAAA==.',
Dm='Dmln:BAAALgADCgEJAQABLgAFFAEJAQADAAAAAA==.Dmlq:BAAALgADCgUJBQABLgAFFAEJAQADAAAAAA==.Dmls:BAABLgAECn8+AAMEAAkJOSVxAQC9AwAEAAkJ4SRxAQC9AwAFAAIJKyY+OADUAAAAAA==.Dmlss:BAAALgAFFAEJAQAAAA==.',
Do='Doloresangla:BAAALgAECgEJAQAAAA==.Dot:BAABLgAECn8OAAMEAAYJfRaVegBnAQAEAAYJfRaVegBnAQAFAAEJAAAydwAtAAAAAA==.',
Dr='Dryme:BAAALgADCgkJCQAAAA==.',
Du='Duddu:BAAALgADCgEJAQAAAA==.',
El='Elisande:BAAALgAECgYJBgAAAA==.',
Ev='Evelyndiana:BAAALgAECgEJAQAAAA==.Evilblade:BAAALgAFFAEJAQAAAA==.',
Fi='Ficus:BAAALgAECgYJBwAAAA==.',
Ge='Gevjon:BAAALgAECgYJCQAAAA==.',
Gi='Ginx:BAAALgAECgcJAQAAAA==.',
Ha='Haley:BAAALgAFFAIJAgAAAA==.Hammock:BAAALgAECgEJAQAAAA==.',
He='Hercules:BAAALgAECgEJAQAAAA==.',
Ho='Hongyanl:BAAALgAECgEJAQAAAA==.Hongyans:BAAALgAECgcJDAAAAA==.',
Je='Jermar:BAAALgAECgYJCAAAAA==.',
Ke='Kenneth:BAAALgAFFAEJAQAAAA==.Keymogee:BAAALgAECgEJAQAAAA==.',
Ki='Kinjaz:BAAALgAFFAIJAgAAAA==.Kira:BAABLgAFFH8IAAMGAAMJ9BCNCQDrAAAHAAMJ9BBYFQDxAAAGAAMJRgeNCQDrAAAAAA==.',
Ko='Koko:BAAALgAECgIJAwAAAA==.',
La='Lana:BAAALgADCgcJBwAAAA==.',
Li='Lilei:BAAALgAECgEJAQAAAA==.',
Lu='Luanxrd:BAAALgAFFAIJAwABLgAFFAUJEwABABYTAA==.',
Ma='Malefic:BAAALgAFFAEJAQAAAA==.',
Mi='Mithrandir:BAACLgAFFH8KAAICAAQJMRNREgA+AQACAAQJMRNREgA+AQAuAAQKfxkAAgIABwlVIS0kAHkCAAIABwlVIS0kAHkCAAAA.',
Mo='Mozz:BAAALgAFFAQJBAAAAA==.',
Ni='Nightm:BAAALgAECgIJAgAAAA==.',
No='Noex:BAABLgAFFH8NAAIIAAQJMhWmCAA7AQAIAAQJMhWmCAA7AQAAAA==.',
On='Onlykarina:BAAALgAECgYJCwAAAA==.',
Pl='Playerrkromw:BAAALgAECgMJAQAAAA==.Playerrmccth:BAAALgAECgIJAwAAAA==.',
Pu='Pusspussb:BAAALgAECgEJAQAAAA==.',
Qs='Qsqs:BAAALgAECgYJAwAAAA==.',
Ri='Rie:BAAALgAECgUJCAAAAA==.',
Sa='Sarottii:BAAALgAECgYJCQAAAA==.Satellite:BAAALgAECgMJAwAAAA==.',
Sh='Shelley:BAAALgAECgEJAQAAAA==.Shirlene:BAAALgAECgMJAwAAAA==.Shirleyon:BAAALgADCgUJBQAAAA==.Shirleyop:BAAALgAECgEJAgAAAA==.',
So='Sone:BAABLgAFFH8QAAMEAAQJeSJKFQBDAQAEAAMJCyRKFQBDAQAFAAEJwh2jAwBhAAAAAA==.Souldie:BAAALgAECgMJAwAAAA==.',
Sp='Spcloudy:BAAALgAECgEJAQAAAA==.Sprinter:BAAALgAECgIJAgAAAA==.',
St='Staywithme:BAAALgAECgYJDAAAAA==.Stella:BAACLgAFFH8NAAIJAAQJ9RQsAwAdAQAJAAQJ9RQsAwAdAQAuAAQKfxkAAgkACAn2FYcUAMgBAAkACAn2FYcUAMgBAAAA.',
Su='Sulejmani:BAAALgAECgcJBwAAAA==.Sunnymu:BAAALgADCgcJAgAAAA==.',
Sy='Sytlovegsr:BAAALgAECgcJBwAAAA==.',
Th='Thankssir:BAACLgAFFH8HAAIHAAQJFAwSEQAkAQAHAAQJFAwSEQAkAQAuAAQKfxcAAgcACAn6IMwWAHYCAAcACAn6IMwWAHYCAAAA.',
To='Topshot:BAAALgADCgQJBAAAAA==.',
Tr='Truly:BAABLgAECn8WAAMCAAYJuR/0OQANAgACAAYJuR/0OQANAgAKAAEJLQT8dwAsAAABLgAFFAIJAgADAAAAAA==.',
Va='Valkyrie:BAAALgAECgYJEAAAAA==.',
Vu='Vurtne:BAABLgAECn8XAAMBAAYJ4httawD/AQABAAYJ4httawD/AQALAAEJPgYbIQAqAAAAAA==.',
Wa='Warrioràg:BAAALgAECgMJAwAAAA==.Wauveey:BAAALgAECgcJBwABLgAFFAYJBwAHABANAA==.',
Wi='Wingz:BAAALgADCgEJAQAAAA==.',
Xd='Xdice:BAAALgADCgYJBgAAAA==.',
Xi='Xiaolieren:BAAALgAECgEJAQAAAA==.',
Xj='Xjll:BAAALgAECgYJCQAAAA==.',
Xl='Xlr:BAAALgAECgMJBAAAAA==.',
Yo='Younoob:BAAALgAECgMJAwAAAA==.',
Yu='Yuzuha:BAABLgAFFH8KAAIBAAQJLiV4DAC5AQABAAQJLiV4DAC5AQAAAA==.',
Zo='Zoomklns:BAABLgAECn8UAAQEAAYJ6h2tXgCtAQAEAAUJ6h2tXgCtAQAMAAIJ9RFTHACQAAAFAAEJuBUNZwBCAAAAAA==.',
['一个']='一个熊孩子:BAAALgAFFAIJAQAAAA==.',
['一剑']='一剑十四州:BAAALgADCgIJAgAAAA==.',
['一只']='一只小牦牛:BAAALgADCgIJAgAAAA==.',
['一叶']='一叶知湫:BAAALgADCgEJAQAAAA==.',
['一墓']='一墓了橪:BAAALgAECgEJAQAAAA==.',
['一声']='一声平安:BAAALgAECgYJBwAAAA==.',
['一煌']='一煌一:BAAALgAFFAIJBAAAAA==.',
['一爪']='一爪子:BAAALgAECgMJAwAAAA==.',
['一百']='一百万一:BAAALgAECgEJAQAAAA==.',
['一米']='一米半半:BAAALgAECgMJAwAAAA==.',
['一颗']='一颗死咖喱棒:BAAALgAECgYJCwAAAA==.一颗火龙果:BAAALgAECgEJAQAAAA==.一颗牛油果:BAAALgADCgUJBQAAAA==.一颗猪:BAAALgAECgQJBAAAAA==.',
['丁大']='丁大力:BAAALgAECgQJBAABLgAFFAIJBAADAAAAAA==.',
['七丶']='七丶夜:BAAALgAECgYJBwABLgAFFAEJAgADAAAAAA==.',
['七海']='七海娜娜米:BAAALgAECgcJBwAAAA==.',
['万物']='万物一:BAAALgAECgMJAwAAAA==.',
['三十']='三十二两:BAAALgADCgUJBQAAAA==.',
['三秋']='三秋叶:BAAALgAECgIJAgAAAA==.',
['下雨']='下雨天:BAAALgADCgEJAQAAAA==.',
['不明']='不明小鸟:BAAALgAECgEJAQAAAA==.',
['不曾']='不曾迷茫:BAAALgAECgQJBAAAAA==.',
['不死']='不死红云:BAAALgAFFAIJBAAAAA==.不死邪光:BAAALgAECgYJEAAAAA==.不死霸霸:BAABLgAECn8WAAIBAAcJGQmq3QA3AQABAAcJGQmq3QA3AQAAAA==.',
['不破']='不破诛罚:BAAALgADCgcJCgAAAA==.',
['丨以']='丨以恨为名丶:BAABLgAECn8bAAIIAAkJwhHaSQAVAgAIAAkJwhHaSQAVAgAAAA==.',
['丨冭']='丨冭楽丨:BAAALgAECgMJAwABLgAFFAYJFgANACsbAA==.',
['丨十']='丨十三丨:BAAALgAECgYJCAAAAA==.',
['丨午']='丨午丶夜丨:BAAALgADCgEJAQAAAA==.',
['丨大']='丨大表哥丶:BAAALgAECgUJCAAAAA==.',
['丨寂']='丨寂月流音丶:BAAALgAECgQJBwAAAA==.',
['丨小']='丨小表妹丶:BAAALgADCgIJAgAAAA==.',
['丨有']='丨有關部門丶:BAAALgAECggJCAAAAA==.',
['丨李']='丨李云龙丨:BAAALgAFFAMJBAAAAA==.',
['丨瑾']='丨瑾瑜:BAAALgAECgkJBgAAAA==.',
['丨笑']='丨笑熙熙:BAAALgAECgUJBQAAAA==.',
['丨言']='丨言谕丨:BAAALgAECgQJBwAAAA==.',
['丶上']='丶上杉绘梨衣:BAAALgAFFAIJAwAAAA==.',
['丶丶']='丶丶啪啪熊:BAAALgADCgYJBgAAAA==.',
['丶嘭']='丶嘭嘭:BAAALgAECgYJBgAAAA==.',
['丶小']='丶小白白:BAAALgAECgYJDAAAAA==.',
['丶简']='丶简单粗暴:BAAALgAECgYJBwAAAA==.',
['丶霸']='丶霸伊斯亞脩:BAAALgAFFAIJAwAAAA==.',
['为祖']='为祖国献石油:BAAALgAFFAIJBAAAAA==.',
['丽丽']='丽丽丨鬼影:BAEALgAECgkJDwAAAA==.',
['举起']='举起手来:BAAALgADCgYJBgAAAA==.',
['丿飘']='丿飘雪丶白:BAAALgAECgEJAQAAAA==.',
['九旬']='九旬铑太:BAAALgAFFAMJBAAAAA==.',
['也就']='也就不行:BAAALgAECgEJAwAAAA==.',
['买个']='买个蛋碎了:BAAALgAECgYJCAAAAA==.',
['二西']='二西莫夫:BAAALgADCgEJAQAAAA==.',
['云顶']='云顶流光:BAAALgAECgMJAwAAAA==.',
['五指']='五指山牢改犯:BAAALgAFFAEJAQAAAA==.',
['五棍']='五棍萨满:BAAALgADCgQJBQAAAA==.',
['亚瑟']='亚瑟:BAAALgAECgcJCgAAAA==.',
['亲爱']='亲爱凡凡宝贝:BAABLgAECn8bAAIBAAkJoSBTBwCSAwABAAkJoSBTBwCSAwAAAA==.',
['人狠']='人狠话不多:BAAALgAFFAIJBAAAAA==.',
['他丨']='他丨姑的邪锁:BAAALgAECgcJBwAAAA==.',
['仙箭']='仙箭:BAAALgAECgYJBgAAAA==.',
['伊利']='伊利橙:BAAALgAECgYJBgAAAA==.伊利沙白泰勒:BAABLgAECn8bAAMOAAkJbQQi3ADUAAAOAAkJbQQi3ADUAAAPAAUJDgBbLAAMAAAAAA==.伊利达雷之怒:BAAALgADCgIJAgAAAA==.',
['伊塔']='伊塔洛卡:BAAALgAECgcJCQAAAA==.',
['伊歌']='伊歌瑞亚:BAABLgAECn8WAAMQAAcJghaYEgAoAQAKAAUJhg90MQBHAQAQAAYJGhKYEgAoAQAAAA==.伊歌瑞尔:BAAALgAECgcJEwAAAA==.伊歌芮儿:BAAALgAFFAEJAQAAAA==.',
['伊黑']='伊黑小芭内:BAAALgADCgEJAQAAAA==.',
['伴水']='伴水半山:BAAALgAECgQJBAAAAA==.',
['伽罗']='伽罗沙曳:BAAALgAECgQJBAABLgAFFAEJAQADAAAAAA==.',
['佐伯']='佐伯米莉亚:BAAALgADCgYJBgAAAA==.',
['佐鼬']='佐鼬为难:BAAALgAECgIJAgAAAA==.',
['你们']='你们的大爷:BAACLgAFFH8eAAMEAAgJliMHAAAnAwAEAAgJliMHAAAnAwAMAAEJWR2UBABaAAAuAAQKfyYAAwQACQmZJlUAAO4DAAQACQmZJlUAAO4DAAwAAgmsJmoVANsAAAAA.',
['你叫']='你叫萨满是吧:BAAALgAFFAIJAwABLgAFFAIJBAADAAAAAA==.',
['你的']='你的益达啦:BAAALgAECgEJAQAAAA==.',
['你给']='你给我果赖:BAACLgAFFH8JAAICAAQJvQycCAAqAQACAAQJvQycCAAqAQAuAAQKfyMAAgIACAkfG9wGAAkCAAIACAkfG9wGAAkCAAAA.',
['做一']='做一个女汉子:BAAALgAFFAEJAQAAAA==.',
['偷偷']='偷偷看看情况:BAAALgADCgYJBgAAAA==.',
['傲雪']='傲雪越冬:BAAALgAECgIJAwAAAA==.',
['傻阿']='傻阿弟逼:BAAALgAECgYJBAAAAA==.',
['元气']='元气小晨:BAAALgAECgQJAgAAAA==.',
['元素']='元素爆发:BAAALgADCgEJAQAAAA==.',
['元罪']='元罪丶风:BAAALgADCggJCAAAAA==.',
['克里']='克里斯蒂安丶:BAAALgAECgcJEAAAAA==.',
['免贵']='免贵姓渣名女:BAAALgAECgEJAQAAAA==.',
['兜里']='兜里有枪:BAAALgAECgUJBwAAAA==.',
['入眼']='入眼:BAAALgAECgQJBAAAAA==.',
['全民']='全民萌神:BAAALgAECgYJEgAAAA==.',
['八号']='八号作品:BAAALgAECgMJAwAAAA==.',
['八零']='八零後的回憶:BAAALgAECgUJBQAAAA==.',
['八霸']='八霸丶丿灬丨:BAAALgAECgEJAQAAAA==.',
['关谷']='关谷丷君:BAAALgAECgEJAQAAAA==.',
['养鱼']='养鱼大哥:BAAALgAFFAEJAQAAAA==.',
['冥王']='冥王秦珑麟:BAAALgAECgkJDwABLgAFFAUJBAADAAAAAA==.',
['冭楽']='冭楽丨:BAAALgAFFAIJAgAAAA==.冭楽丨丨:BAAALgAFFAEJAQABLgAFFAIJAgADAAAAAA==.',
['冯克']='冯克雷之爱:BAAALgAECgQJBQAAAA==.',
['冰丨']='冰丨封:BAAALgAECgMJAwAAAA==.',
['冰冰']='冰冰宾子呀:BAAALgAECgQJBAAAAA==.',
['冰镇']='冰镇阔落:BAAALgAECgYJCQAAAA==.',
['冲钅']='冲钅跑尸:BAAALgAFFAQJAgAAAA==.',
['冲锋']='冲锋然后推倒:BAACLgAFFH8OAAIRAAQJ9gVnAwDtAAARAAQJ9gVnAwDtAAAuAAQKfxwAAhEABgkfEr0iACgBABEABgkfEr0iACgBAAAA.冲锋陷乱:BAAALgAECgcJBgAAAA==.',
['净化']='净化者法克:BAAALgAECgIJAwAAAA==.',
['凉薄']='凉薄:BAAALgAECgEJAQAAAA==.',
['凌枫']='凌枫魔影笙:BAAALgAECgkJDgAAAA==.',
['刂贼']='刂贼屮仔忄:BAAALgAECgYJBgAAAA==.',
['刘二']='刘二喜:BAAALgAFFAIJBAAAAA==.',
['剑舞']='剑舞:BAAALgAECgQJBAAAAA==.',
['剩下']='剩下的盛夏:BAAALgAECgEJAQAAAA==.',
['力量']='力量与农药丶:BAABLgAFFH8KAAMPAAQJrBSYAwBLAQAPAAQJrBSYAwBLAQAOAAIJbQYuKACYAAAAAA==.',
['加特']='加特林:BAAALgADCgIJAgAAAA==.',
['加盾']='加盾男爵:BAAALgADCgEJAQABLgAFFAMJBQAOAGAYAA==.',
['勿语']='勿语灬:BAAALgADCgEJAQAAAA==.',
['南游']='南游慕北归:BAAALgAECgQJAwAAAA==.',
['卧槽']='卧槽无情:BAAALgAECgMJAwAAAA==.',
['又见']='又见蓝蓝:BAAALgAECgEJAQAAAA==.',
['叉烧']='叉烧吃不吃:BAAALgAECgYJBwAAAA==.',
['友達']='友達戀未滿:BAAALgADCgEJAQAAAA==.',
['古児']='古児丹:BAAALgADCgMJAQAAAA==.',
['叫兽']='叫兽让你羊伪:BAAALgAECgQJBwAAAA==.',
['叫我']='叫我微风哥哥:BAAALgAECgYJBgAAAA==.',
['可莉']='可莉:BAAALgAECgIJAgAAAA==.',
['史上']='史上最漒男人:BAAALgADCgIJAgAAAA==.',
['叽里']='叽里呱拉:BAAALgAECgYJCwAAAA==.',
['吊打']='吊打权限狗:BAAALgAECgYJBwAAAA==.',
['名可']='名可名非常名:BAAALgAECgEJAQAAAA==.',
['吥會']='吥會徦死:BAAALgAECgQJBAAAAA==.',
['吧唧']='吧唧大狂蜂:BAAALgAECgYJDQAAAA==.',
['听画']='听画:BAAALgAECgkJCQAAAA==.',
['听話']='听話:BAAALgAECgkJCAAAAA==.',
['吱吱']='吱吱橙:BAAALgAECgkJCQAAAA==.',
['吹风']='吹风机:BAAALgAECgUJBwAAAA==.',
['周米']='周米粒:BAAALgAFFAIJAgAAAA==.',
['和泉']='和泉妃爱:BAACLgAFFH8HAAISAAUJMhC0AwC/AQASAAUJMhC0AwC/AQAuAAQKfxsAAhIACQklItQHABMDABIACQklItQHABMDAAAA.',
['咕咕']='咕咕来个振翅:BAAALgAECgEJAQAAAA==.',
['咪丷']='咪丷咪:BAAALgADCgUJAwAAAA==.',
['咸鱼']='咸鱼翻面:BAAALgAECgYJCAAAAA==.',
['哈库']='哈库呐码塔塔:BAAALgAECgMJAwAAAA==.',
['哥斯']='哥斯老坤:BAAALgAECgEJAQAAAA==.',
['哦呦']='哦呦丶:BAAALgAECgYJDAAAAA==.',
['唉丶']='唉丶丫:BAAALgADCgcJBwAAAA==.',
['啾咪']='啾咪:BAAALgAECgYJCQAAAA==.',
['喵呜']='喵呜灬呜喵:BAAALgADCgEJAQAAAA==.',
['嗨喂']='嗨喂你还好吗:BAAALgAECgYJBgAAAA==.',
['嗨嗨']='嗨嗨:BAAALgAECgQJBAAAAA==.',
['噢乁']='噢乁伊利蛋:BAAALgAECgQJBAAAAA==.',
['噬灭']='噬灭:BAAALgAECgIJAwAAAA==.',
['困龙']='困龙丶梅丽丝:BAAALgAECgkJCAABLgAFFAEJAQADAAAAAA==.',
['土豆']='土豆鸡丁:BAAALgAFFAIJAgAAAA==.',
['圣喻']='圣喻:BAAALgAECgYJCgAAAA==.',
['圣度']='圣度菲斯:BAAALgAECgYJCwAAAA==.',
['圣麒']='圣麒麟:BAAALgADCgMJAwAAAA==.',
['在人']='在人间凑数:BAAALgAECgEJAQAAAA==.',
['坏蛋']='坏蛋潮人:BAAALgAECgEJAQAAAA==.',
['坐飞']='坐飞机的舒克:BAAALgADCgIJAgAAAA==.',
['基头']='基头四:BAAALgAECgEJAwAAAA==.',
['堕落']='堕落丶骑士:BAACLgAFFH8GAAIIAAIJHCLSOQCoAAAIAAIJHCLSOQCoAAAuAAQKfxUAAwgABglbF49wAKcBAAgABQloHI9wAKcBAAkAAQknA7VLAB4AAAAA.堕落圆桌骑士:BAAALgAECgYJCgAAAA==.堕落得圣光:BAAALgAECgYJBgAAAA==.',
['墓狩']='墓狩:BAAALgAFFAEJAgAAAA==.',
['墙下']='墙下等红杏:BAAALgAECgEJAQAAAA==.',
['墨英']='墨英晓:BAACLgAFFH8QAAIIAAQJshrcBgBUAQAIAAQJshrcBgBUAQAuAAQKfxYAAggACAk5GpglAKYCAAgACAk5GpglAKYCAAAA.',
['壊小']='壊小子小狼:BAAALgAECgQJBAAAAA==.',
['壕骑']='壕骑:BAAALgAFFAEJAQABLgAFFAIJBAADAAAAAA==.',
['夏米']='夏米尔:BAAALgAECgYJBgAAAA==.',
['夜凯']='夜凯:BAAALgAECgEJAQAAAA==.',
['夜祈']='夜祈福:BAAALgAECgUJCAAAAA==.',
['夜雨']='夜雨過晴川:BAABLgAFFH8JAAMKAAMJdQrxCgCMAAACAAMJdQo0KwCYAAAKAAIJjQLxCgCMAAAAAA==.',
['大只']='大只西:BAAALgAECgEJAQAAAA==.',
['大吉']='大吉大利:BAAALgAECgEJAQAAAA==.',
['大哥']='大哥的喵:BAAALgAECgYJCQAAAA==.',
['大狮']='大狮姐:BAAALgAECgUJBQAAAA==.',
['大织']='大织弱鱼:BAABLgAFFH8OAAITAAQJCx0XBgBsAQATAAQJCx0XBgBsAQAAAA==.',
['天启']='天启肺总:BAAALgAECgcJEQAAAA==.',
['天國']='天國的記憶:BAAALgAECgYJBgAAAA==.',
['天堂']='天堂国度:BAAALgAECgYJBgAAAA==.天堂子弹:BAAALgAECgQJBAAAAA==.',
['天堑']='天堑梦魇:BAAALgADCgEJAQAAAA==.',
['天生']='天生就会飞:BAAALgAECgEJAQAAAA==.',
['天荒']='天荒地老萨:BAAALgAECgYJDAAAAA==.',
['天还']='天还是一样蓝:BAAALgADCgEJAQAAAA==.',
['夫子']='夫子剑:BAAALgAECgQJBAAAAA==.',
['奈德']='奈德莉:BAAALgAFFAIJAwAAAA==.',
['奎爷']='奎爷琅琊玥:BAACLgAFFH8JAAMJAAUJdh1yAgCrAQAJAAUJdh1yAgCrAQAIAAQJqQXlHgAhAQAuAAQKfxYAAggACQllHr4MADQDAAgACQllHr4MADQDAAEuAAUUBgkXABQA2xEA.',
['奔波']='奔波儿霸霸:BAAALgAECgUJBQAAAA==.',
['奥力']='奥力給:BAAALgAECgUJBQAAAA==.',
['奥客']='奥客:BAAALgAECgcJDgAAAA==.',
['奥巧']='奥巧慕斯沙琪:BAAALgAECgEJAQAAAA==.',
['奥迪']='奥迪旗舰:BAAALgADCgMJAwAAAA==.',
['女子']='女子骉射队员:BAACLgAFFH8GAAQGAAIJhRKlGQCgAAAGAAIJhRKlGQCgAAAVAAEJuQWBBwBUAAAHAAEJuQymKABKAAAuAAQKfxYABAYACAnKG14vAPQBAAYABgkXHV4vAPQBAAcABgkhFQJFAEEBABUAAgnzCLoPAG0AAAAA.',
['奶油']='奶油慕斯:BAAALgAECgYJDQAAAA==.',
['她也']='她也终成过往:BAAALgAECgUJBQAAAA==.',
['好丽']='好丽来:BAAALgAECgQJAwAAAA==.',
['好好']='好好吃好饭:BAAALgAECgYJBwAAAA==.好好爱打架:BAAALgADCgIJAgAAAA==.',
['妙丶']='妙丶别走:BAAALgAECgYJBgAAAA==.',
['妮莉']='妮莉艾露丶:BAAALgAECgEJAQAAAA==.',
['姊姊']='姊姊:BAAALgADCgEJAQAAAA==.',
['姬无']='姬无骦:BAAALgADCgMJAwAAAA==.姬无鹴:BAAALgAECgMJAwAAAA==.',
['威武']='威武霸气:BAABLgAFFH8GAAIOAAIJNyCGGgDMAAAOAAIJNyCGGgDMAAAAAA==.',
['媚影']='媚影修羅:BAAALgAFFAIJAwAAAA==.媚影修萝:BAAALgAFFAMJBAAAAA==.',
['子墨']='子墨言:BAAALgAECgcJBwAAAA==.',
['孟子']='孟子曰:BAACLgAFFH8GAAIWAAMJyRruDgDxAAAWAAMJyRruDgDxAAAuAAQKfxUAAhYABwkpFSkvAMwBABYABwkpFSkvAMwBAAAA.',
['宁亚']='宁亚:BAAALgAECgQJBQAAAA==.',
['宇智']='宇智波小蛐蛐:BAAALgADCgEJAQAAAA==.',
['守时']='守时的鸡鸽:BAAALgAECgQJDAAAAA==.',
['守梦']='守梦者:BAAALgAECgIJAwAAAA==.',
['安东']='安东尼汗:BAAALgAECgUJBQAAAA==.',
['寂静']='寂静的懒觉:BAAALgAECgIJAwAAAA==.',
['寒江']='寒江细雨:BAAALgADCgIJAgAAAA==.',
['射到']='射到手疼:BAAALgAECgQJDgAAAA==.',
['小小']='小小的月亮:BAAALgAECgYJCAAAAA==.',
['小山']='小山犭者:BAAALgAECgEJAQAAAA==.',
['小年']='小年年:BAAALgAFFAIJBAAAAA==.',
['小德']='小德佩立:BAAALgAFFAIJAgAAAA==.',
['小敏']='小敏哓敏晓敏:BAAALgAECgEJBQAAAA==.',
['小明']='小明小明:BAAALgADCgQJBAAAAA==.',
['小渣']='小渣子:BAAALgAECgQJBAAAAA==.',
['小灬']='小灬狐狸:BAAALgAECgcJEwAAAA==.小灬跟班:BAAALgAECgcJCwAAAA==.',
['小爪']='小爪冰凉:BAABLgAECn8ZAAMXAAcJ8R3gGgB1AgAXAAcJ8R3gGgB1AgARAAEJnwaUSQAqAAABLgAECgcJGwAOAEUlAA==.',
['小玮']='小玮:BAAALgAECgEJAQAAAA==.',
['小甜']='小甜甜赵露思:BAAALgAECgYJBgAAAA==.小甜甜郭德纲:BAAALgAECgEJAQAAAA==.',
['小白']='小白是我宠物:BAAALgADCgIJAgAAAA==.小白白丿:BAAALgAECgEJAQAAAA==.',
['小花']='小花浪:BAAALgAECgYJBwAAAA==.',
['小钢']='小钢裤:BAAALgADCgUJBQAAAA==.',
['小骑']='小骑佩立:BAAALgAECgYJBwAAAA==.',
['尐歎']='尐歎傢:BAAALgADCgIJAwAAAA==.',
['尛呅']='尛呅孒:BAAALgAECgcJDAAAAA==.',
['尤迪']='尤迪犾:BAAALgAECgQJCQAAAA==.',
['尤里']='尤里乌斯丶:BAAALgAECgYJCgABLgAECgcJDwADAAAAAA==.',
['尼古']='尼古拉斯赵寺:BAAALgAECgYJDwAAAA==.',
['岁月']='岁月静好:BAAALgADCgcJBwABLgAFFAQJCAAIAMYYAA==.',
['崖边']='崖边钓鸟:BAAALgAFFAIJAgAAAA==.',
['崩摧']='崩摧:BAAALgAECggJBwABLgAFFAYJDQAYALEiAA==.',
['工藤']='工藤洗衣机:BAAALgAECgYJBgAAAA==.',
['左秘']='左秘奥右灵匣:BAAALgAFFAIJBAAAAA==.',
['左绝']='左绝刃右英灵:BAAALgADCgcJDQAAAA==.',
['左蝴']='左蝴蝶右天堂:BAAALgAECgEJAQABLgAFFAIJBAADAAAAAA==.',
['左血']='左血棘右虚灵:BAAALgAECgkJCQABLgAFFAIJBAADAAAAAA==.',
['巭掌']='巭掌济气仁:BAAALgAECgYJCwAAAA==.',
['巴格']='巴格里亚尔:BAABLgAECn8VAAMKAAgJjxmkIAC4AQAKAAUJeBukIAC4AQACAAgJdhMqUQCyAQAAAA==.',
['巴纳']='巴纳吉林克斯:BAAALgAECgcJBwAAAA==.',
['布戈']='布戈尼血誓:BAAALgAECgUJCAAAAA==.',
['布来']='布来克:BAACLgAFFH8RAAQIAAUJmyHtBwCRAQAIAAQJmyHtBwCRAQAZAAMJsB0YAQAoAQAJAAEJAABwGQA3AAAuAAQKfyIAAggACAn5JOkJAEwDAAgACAn5JOkJAEwDAAAA.',
['希儿']='希儿的祭礼:BAABLgAFFH8GAAIUAAIJ2iWQCADfAAAUAAIJ2iWQCADfAAAAAA==.',
['希尓']='希尓佤娜絲:BAAALgAECgIJAgAAAA==.',
['希望']='希望小猪:BAAALgAECgcJBgAAAA==.',
['帕奇']='帕奇利兹:BAABLgAFFH8JAAIaAAQJnQ/9CgA4AQAaAAQJnQ/9CgA4AQAAAA==.',
['帯头']='帯头大哥:BAAALgAECgIJAQAAAA==.',
['干涉']='干涉你:BAAALgAECgkJCQAAAA==.',
['干饭']='干饭爱吃面包:BAAALgAECgEJAgAAAA==.',
['年糕']='年糕:BAAALgAECgkJCQAAAA==.',
['广陵']='广陵王:BAAALgAECgIJAgAAAA==.',
['应允']='应允隆贵:BAAALgAECgYJCAAAAA==.',
['弃武']='弃武从文:BAAALgAECgIJAwAAAA==.',
['弟弟']='弟弟很大:BAAALgAECgcJCAAAAA==.',
['张一']='张一小一虾:BAAALgADCggJCAAAAA==.',
['张多']='张多多:BAAALgAECgEJAQAAAA==.',
['彩色']='彩色泡泡:BAAALgAECgEJAQAAAA==.',
['影色']='影色舞:BAAALgAFFAEJAQAAAA==.',
['彼得']='彼得兔:BAABLgAFFH8FAAIOAAQJPgjxDgAyAQAOAAQJPgjxDgAyAQAAAA==.',
['律律']='律律冰萦:BAABLgAECn8ZAAMbAAcJuhzXDQDoAQAbAAYJeR/XDQDoAQAOAAIJjQ2PFgFrAAAAAA==.',
['從此']='從此被困:BAAALgADCgcJBwAAAA==.',
['微笑']='微笑小艾:BAAALgAECgkJEAAAAA==.',
['德一']='德一:BAAALgAFFAIJBAAAAA==.',
['德卤']='德卤伊之助:BAAALgAECgEJAQAAAA==.',
['德哥']='德哥哥丶:BAAALgADCgYJBgAAAA==.',
['德里']='德里克罗斯:BAAALgADCgMJAwAAAA==.',
['心若']='心若熙:BAABLgAECn8VAAIOAAYJgSI9DADPAQAOAAYJgSI9DADPAQABLgAFFAcJBwAPADwVAA==.',
['忆丶']='忆丶尛孩:BAAALgADCgEJAQAAAA==.',
['忍野']='忍野忍:BAACLgAFFH8LAAISAAUJShhkAgDcAQASAAUJShhkAgDcAQAuAAQKfxYAAhIACQmYIYUHABgDABIACQmYIYUHABgDAAAA.',
['忘陌']='忘陌路:BAAALgAECgUJBgAAAA==.',
['快挠']='快挠死:BAAALgAECgEJAQAAAA==.',
['快楽']='快楽的萨满:BAAALgAFFAIJBAAAAA==.',
['快用']='快用力不要停:BAABLgAFFH8HAAIGAAUJJBN4BABaAQAGAAUJJBN4BABaAQAAAA==.',
['恰人']='恰人:BAAALgAECgYJBgABLgAFFAYJBwACAGYTAA==.',
['恶魔']='恶魔的仆人:BAAALgAECgQJBQAAAA==.',
['情话']='情话未曾说:BAAALgAECgYJCAAAAA==.',
['惟有']='惟有香如故:BAAALgADCgUJBQAAAA==.',
['憎恶']='憎恶:BAAALgAECgYJBgAAAA==.',
['憬夜']='憬夜:BAAALgAECgEJAgAAAA==.',
['我不']='我不信我最黑:BAABLgAECn8UAAIBAAcJRxNIkACyAQABAAcJRxNIkACyAQAAAA==.',
['我们']='我们的下雪天:BAAALgADCgEJAQAAAA==.',
['我是']='我是李大元:BAAALgAFFAMJAwAAAA==.',
['我的']='我的刀盾:BAAALgAECgQJBAAAAA==.',
['战刃']='战刃已丢失:BAAALgAECggJBwAAAA==.',
['打我']='打我我扛:BAAALgAECgcJDgAAAA==.',
['托比']='托比小熊猫:BAAALgAECgEJAQAAAA==.',
['扮嗨']='扮嗨晒嘢:BAABLgAECn8cAAIFAAgJDxstBACjAgAFAAgJDxstBACjAgAAAA==.',
['折了']='折了玉簪:BAAALgAECgEJAgAAAA==.',
['拯救']='拯救的以撒:BAAALgAECgcJCQAAAA==.',
['挑灯']='挑灯丨看剣:BAAALgAECgQJBgAAAA==.',
['掩护']='掩护丶:BAAALgAFFAIJAwAAAA==.',
['摸鱼']='摸鱼小术:BAAALgAECgMJAwAAAA==.',
['撒了']='撒了萨皮蒂蒂:BAAALgAECgcJBwAAAA==.',
['支援']='支援型小骑士:BAAALgAECgEJAQAAAA==.',
['故事']='故事的角色:BAABLgAFFH8FAAIIAAMJsCMSGgA9AQAIAAMJsCMSGgA9AQAAAA==.',
['敌法']='敌法師:BAAALgADCgEJAQAAAA==.',
['救赎']='救赎丶杀戮:BAAALgAECgEJAQAAAA==.',
['斯美']='斯美美:BAAALgAECgkJDwABLgAFFAUJCgABAH0IAA==.',
['新垣']='新垣灬绫濑:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌小虾条:BAAALgAFFAQJAgAAAA==.无敌小虾饺:BAAALgAECgYJBwAAAA==.无敌小飞:BAABLgAECn8UAAIHAAcJwhzOHQA1AgAHAAcJwhzOHQA1AgAAAA==.无敌最凶狠:BAAALgAFFAIJAQAAAA==.',
['无欲']='无欲拔刀神:BAAALgAECgEJAQAAAA==.',
['早睡']='早睡早起:BAAALgAECgcJBwAAAA==.',
['明靖']='明靖天涯:BAAALgAECgcJBgAAAA==.',
['昕星']='昕星相印:BAAALgADCgEJAQAAAA==.',
['星丶']='星丶浅堪低唱:BAAALgAECgEJAQAAAA==.',
['星之']='星之瞳赫特:BAAALgADCgEJAQAAAA==.',
['星夜']='星夜最爱:BAAALgAECgMJAwAAAA==.',
['星河']='星河雪兒:BAAALgAECgcJBwABLgAECggJGQAUAF0TAA==.',
['星辰']='星辰弥漫眼底:BAABLgAECn8UAAIEAAYJnAV/qQAGAQAEAAYJnAV/qQAGAQAAAA==.星辰德鲁:BAAALgADCgMJBgAAAA==.',
['春风']='春风丶:BAAALgAECgIJBAAAAA==.',
['晚晚']='晚晚无安:BAAALgAFFAIJAgAAAA==.',
['普渡']='普渡慈航:BAAALgAFFAEJAQAAAA==.',
['普通']='普通的潘达:BAAALgAECgQJBAAAAA==.',
['暗之']='暗之星龙:BAAALgAECgQJBwABLgAECggJCwADAAAAAA==.',
['暗闪']='暗闪:BAAALgAECgcJDwAAAA==.',
['暮色']='暮色:BAABLgAECn8XAAIBAAcJYBTMgQDOAQABAAcJYBTMgQDOAQAAAA==.暮色挽歌:BAABLgAECn8UAAIEAAYJWBCjfABiAQAEAAYJWBCjfABiAQAAAA==.',
['暴躁']='暴躁鸽鸽:BAAALgAFFAEJAQAAAA==.',
['暴雨']='暴雨中的寂静:BAAALgAECgEJAQAAAA==.',
['曦暁']='曦暁:BAAALgADCgMJAwAAAA==.',
['曲水']='曲水流连:BAAALgAECgEJAQAAAA==.',
['最后']='最后一两生煎:BAABLgAFFH8QAAIcAAQJ9hUDAwA3AQAcAAQJ9hUDAwA3AQAAAA==.',
['月上']='月上花花:BAAALgAECgUJBQAAAA==.',
['月夜']='月夜天霜:BAABLgAFFH8GAAIYAAIJcBZMBgCuAAAYAAIJcBZMBgCuAAAAAA==.月夜语风:BAAALgAECgYJCAAAAA==.',
['木大']='木大木大:BAAALgAECgYJDAABLgAFFAQJBwAHABQMAA==.',
['朩艿']='朩艿咿:BAAALgAECgEJAgAAAA==.',
['末日']='末日的开端:BAAALgADCgUJBQAAAA==.',
['术丝']='术丝:BAAALgAECgcJBwAAAA==.',
['朱砂']='朱砂痣:BAAALgAFFAEJAQAAAA==.',
['李小']='李小七吖:BAACLgAFFH8IAAMIAAUJ6B5FDABzAQAIAAQJ6B5FDABzAQAJAAEJAADuEQBjAAAuAAQKfxoAAwgACQmkI3oJAFADAAgACQm3IXoJAFADAAkAAQntIqY+AFUAAAAA.李小龙:BAAALgAECgEJAQAAAA==.',
['杏里']='杏里:BAABLgAECn8aAAIdAAgJLR7LGwBdAgAdAAgJLR7LGwBdAgABLgAFFAQJBwAeANMFAA==.',
['村上']='村上春术:BAAALgAECgYJDAAAAA==.',
['来呗']='来呗:BAABLgAFFH8QAAIaAAQJshbvAgBHAQAaAAQJshbvAgBHAQAAAA==.',
['杨瑾']='杨瑾榕:BAAALgAECgkJEAAAAA==.',
['杨筱']='杨筱芈:BAAALgAECgkJCQAAAA==.',
['板甲']='板甲牧:BAABLgAFFH8FAAIOAAMJYBi0EQAYAQAOAAMJYBi0EQAYAQAAAA==.',
['果莫']='果莫果莫糯丶:BAAALgAECgcJAQAAAA==.',
['枫雾']='枫雾凋零:BAAALgAECgYJCgAAAA==.',
['枯燥']='枯燥:BAAALgAECgkJCQAAAA==.',
['柠檬']='柠檬酱露易丝:BAAALgAECgEJAQAAAA==.',
['柯莱']='柯莱儿:BAAALgADCgEJAQAAAA==.',
['栤欞']='栤欞:BAABLgAECn8bAAIOAAcJFRcEFwBoAQAOAAcJFRcEFwBoAQAAAA==.',
['核心']='核心奶糖:BAAALgAECgIJAgABLgAFFAUJBQAfAKQVAA==.',
['梅川']='梅川芎钊:BAAALgAECgkJCQAAAA==.',
['椒图']='椒图:BAAALgAECgYJBwAAAA==.',
['楼上']='楼上说得对:BAAALgAECgYJAQAAAA==.',
['榴莲']='榴莲紫吖:BAAALgAECgcJDAAAAA==.',
['樂翻']='樂翻天:BAAALgAECggJAgAAAA==.',
['欢宝']='欢宝宝:BAACLgAFFH8SAAQHAAUJGBxnBgC4AQAHAAUJGBxnBgC4AQAVAAIJcAseBQCwAAAGAAIJtgaOFgBTAAAuAAQKfyIABAcACAk4JA4PAMYCAAcABwkMJA4PAMYCAAYAAQlEJb+qAG8AABUAAQkzFEISAEsAAAAA.',
['武行']='武行孙:BAAALgAFFAIJAgAAAA==.',
['死灰']='死灰灬萨:BAAALgAECgQJBAAAAA==.',
['死騎']='死騎狄托洛:BAAALgAFFAIJAgAAAA==.',
['毁灭']='毁灭痛苦恶魔:BAAALgADCgEJAQABLgAFFAQJAQADAAAAAA==.',
['毒魔']='毒魔:BAAALgADCgcJBwAAAA==.',
['毕士']='毕士鸠路:BAAALgAECgUJBQAAAA==.',
['水木']='水木丶清华:BAAALgAECgQJBAAAAA==.',
['油腻']='油腻屎壳郎:BAAALgAECgEJAQAAAA==.',
['法号']='法号烤红薯:BAAALgAECgEJAgAAAA==.',
['法神']='法神龙魂:BAAALgAFFAIJAwAAAA==.',
['波哥']='波哥哥好帅:BAAALgAECgMJBAAAAA==.',
['波娜']='波娜娜:BAAALgADCgUJBQAAAA==.',
['洋丶']='洋丶风暴烈酒:BAAALgAECgEJAQAAAA==.',
['洛神']='洛神賦:BAAALgAECgEJAQAAAA==.',
['洪兴']='洪兴丶韩滨:BAAALgAECgEJAQAAAA==.',
['流星']='流星咕:BAAALgAECgQJBQAAAA==.',
['流风']='流风轻云:BAAALgAECgYJCgAAAA==.',
['浅眠']='浅眠中的梦境:BAAALgADCgIJAgAAAA==.',
['浅紫']='浅紫夏:BAAALgAECgEJAQAAAA==.',
['海弗']='海弗拉斯:BAACLgAFFH8PAAMgAAQJ3BroAABrAQAgAAQJ3BroAABrAQAhAAMJsAMRGACuAAAuAAQKfxUAAyAABwlqHmwOAJYCACAABwlqHmwOAJYCACEAAgmRB8J8AFMAAAAA.',
['涔浠']='涔浠浠:BAAALgAECgYJBQAAAA==.',
['淡淡']='淡淡海飞丝:BAAALgAECgcJDgAAAA==.淡淡海飞絲:BAAALgAECgYJBgABLgAECgcJDgADAAAAAA==.',
['深沉']='深沉的吗喽:BAAALgAECgYJBgAAAA==.',
['混淆']='混淆诅咒:BAAALgAECgYJCAAAAA==.',
['清晖']='清晖:BAAALgADCgEJAQAAAA==.',
['温柔']='温柔可人丶:BAAALgADCgUJBQAAAA==.',
['湿咕']='湿咕咕:BAAALgADCgMJAwAAAA==.',
['滑啾']='滑啾啾上好佳:BAAALgAECgYJCAAAAA==.滑啾啾小馒头:BAEBLgAFFH8IAAIBAAMJth7ZIwAoAQABAAMJth7ZIwAoAQAAAA==.滑啾啾李僧:BAAALgAECggJBgAAAA==.滑啾啾萨墓:BAAALgAECgYJCAAAAA==.',
['滚滚']='滚滚阿:BAAALgAFFAEJAQAAAA==.',
['满飛']='满飛飛:BAAALgAECgcJBwAAAA==.',
['潇潇']='潇潇妹:BAAALgAECgMJAwAAAA==.',
['激迪']='激迪屁:BAAALgAECgkJCQAAAA==.',
['火佛']='火佛:BAAALgAFFAIJBAAAAA==.',
['灬欧']='灬欧偙:BAAALgAECgYJDAAAAA==.',
['灬浣']='灬浣花溪丶:BAACLgAFFH8OAAIPAAQJ0xhgAwBQAQAPAAQJ0xhgAwBQAQAuAAQKfxcAAg8ABwkwGTUpAOYBAA8ABwkwGTUpAOYBAAAA.',
['灰烬']='灰烬使者法琳:BAABLgAECn8bAAIOAAcJRSWFEgD/AgAOAAcJRSWFEgD/AgAAAA==.',
['灵活']='灵活的天天:BAAALgAECgEJAgAAAA==.',
['灸灸']='灸灸:BAAALgAECgEJAgAAAA==.',
['炎雲']='炎雲:BAAALgAECgQJBAAAAA==.',
['炫橘']='炫橘子:BAAALgAECgYJBwAAAA==.',
['炸天']='炸天哥:BAAALgAECggJBgABLgAFFAYJEwAOAMggAA==.',
['烈焰']='烈焰灬徐琳:BAAALgADCgEJAQAAAA==.',
['热胜']='热胜红日光:BAAALgAFFAEJAQAAAA==.',
['無心']='無心睡眠:BAAALgAECgUJBQAAAA==.',
['熊德']='熊德:BAAALgAECgQJBAAAAA==.',
['爱吃']='爱吃大粽子:BAAALgADCgMJAwAAAA==.爱吃现成香菜:BAAALgADCgQJBAAAAA==.',
['爱看']='爱看恐怖片:BAAALgAECgQJBgAAAA==.',
['爱野']='爱野美奈子丶:BAAALgAFFAIJAQAAAA==.',
['爱面']='爱面条的米椒:BAAALgAECgMJAwAAAA==.',
['爱黑']='爱黑暗:BAAALgAECgUJBQAAAA==.',
['牙齿']='牙齿短头发长:BAAALgAECgEJAQAAAA==.',
['牛大']='牛大宝:BAAALgADCgEJAQAAAA==.',
['牛奶']='牛奶冰淇淋:BAAALgAECgQJAQAAAA==.',
['牧牧']='牧牧垛儿丶:BAAALgAFFAIJAgAAAA==.',
['狂煞']='狂煞:BAABLgAECn8WAAICAAgJLwjycgBMAQACAAgJLwjycgBMAQAAAA==.',
['狼心']='狼心犬吠:BAAALgAECgEJAQABLgAFFAMJBwAWAEweAA==.',
['玄蹄']='玄蹄牛滚滚:BAAALgAECgEJAQAAAA==.',
['王大']='王大喵:BAAALgAECgIJAgAAAA==.',
['王老']='王老四:BAAALgAECgcJBgAAAA==.',
['玛格']='玛格拉:BAAALgAECgUJCgAAAA==.',
['玛维']='玛维影歌:BAAALgAECgUJBQAAAA==.',
['珊宝']='珊宝:BAAALgAECgEJAQABLgAFFAUJEgAHABgcAA==.',
['琳娜']='琳娜贝儿:BAABLgAFFH8JAAIEAAUJ8BzNBADSAQAEAAUJ8BzNBADSAQAAAA==.',
['田田']='田田千杯不倒:BAAALgAFFAIJAgAAAA==.田田呼叫血兽:BAACLgAFFH8HAAIIAAQJ0ge7HAAvAQAIAAQJ0ge7HAAvAQAuAAQKfxoAAwgACAmlHplJABYCAAgABwmLHplJABYCAAkAAQlBH889AFoAAAEuAAUUBgkPAAQAkRkA.',
['略懂']='略懂武学:BAAALgAFFAIJAwAAAA==.',
['疍村']='疍村一姐:BAAALgAECgEJAgAAAA==.',
['白色']='白色的橡皮:BAAALgAECgEJAQAAAA==.',
['白虎']='白虎:BAAALgAECgEJAQAAAA==.',
['百草']='百草丰茂:BAAALgAFFAEJAQAAAA==.',
['百鬼']='百鬼夜形:BAAALgAFFAIJBAAAAA==.',
['皇甫']='皇甫甫:BAAALgAECgEJAQAAAA==.',
['皇阿']='皇阿瑪:BAAALgAECgYJDAAAAA==.',
['益儿']='益儿:BAAALgADCgcJCgAAAA==.',
['益钰']='益钰:BAAALgADCgMJBgAAAA==.',
['盒酸']='盒酸检测丶:BAAALgAECgYJBwAAAA==.',
['目无']='目无全牛:BAAALgAECgUJBQAAAA==.',
['眼镜']='眼镜蛇灬:BAAALgAFFAQJBAAAAA==.',
['瞬吸']='瞬吸小枕头:BAAALgAECgQJBQAAAA==.',
['瞳丨']='瞳丨瑾:BAAALgAECgcJDwAAAA==.',
['短手']='短手:BAAALgAECgEJAQAAAA==.',
['破月']='破月鬼斩:BAAALgADCgEJAQAAAA==.',
['破魂']='破魂之怒:BAABLgAFFH8FAAMEAAMJlwqWOQCgAAAEAAIJ8QiWOQCgAAAFAAEJ5A2WFQBTAAAAAA==.',
['祝桥']='祝桥大佬管:BAABLgAFFH8IAAQeAAMJoRV/DQDzAAAeAAMJoRV/DQDzAAAUAAIJAgflDwB+AAAcAAEJdwAEDQAzAAAAAA==.',
['神剑']='神剑御雷真决:BAAALgAECgYJBgAAAA==.',
['神罗']='神罗天征:BAAALgAECgYJCQAAAA==.',
['神诺']='神诺:BAAALgAECgQJBAAAAA==.',
['神霄']='神霄:BAAALgAECgYJDAAAAA==.',
['祭血']='祭血:BAAALgAECgEJAQAAAA==.',
['禪域']='禪域狄托洛:BAACLgAFFH8NAAIhAAQJ7w1ZDgARAQAhAAQJ7w1ZDgARAQAuAAQKfxsAAiEACAnoFT4iAPABACEACAnoFT4iAPABAAAA.',
['穿貂']='穿貂人:BAAALgAECgYJCwAAAA==.',
['站在']='站在布隆后面:BAAALgAFFAEJAQAAAA==.',
['章鱼']='章鱼蟹蟹:BAAALgAECgMJBAAAAA==.',
['端木']='端木戎:BAAALgAECgEJAQAAAA==.',
['竹马']='竹马竹马:BAAALgAECgkJBgAAAA==.',
['笑忘']='笑忘书:BAAALgADCgYJBgAAAA==.',
['笨猪']='笨猪笨猪:BAABLgAFFH8GAAIiAAMJZQWrDwDVAAAiAAMJZQWrDwDVAAAAAA==.',
['第一']='第一波散:BAAALgAECgQJBwAAAA==.',
['箫进']='箫进疼:BAAALgAECgQJBAAAAA==.',
['精德']='精德:BAAALgADCgYJBgAAAA==.',
['紫月']='紫月玄依:BAAALgAECgQJBAAAAA==.紫月萦枫:BAAALgAECggJEwAAAA==.',
['紫色']='紫色职业巅峰:BAAALgAECgcJAgAAAA==.',
['繁星']='繁星漫漫:BAAALgADCgMJAwAAAA==.',
['红尘']='红尘丨孤行:BAAALgAECgUJBQAAAA==.',
['红色']='红色运动员:BAAALgAECgkJCQAAAA==.',
['红衍']='红衍:BAAALgAECgYJBgAAAA==.',
['红豆']='红豆奶昔:BAACLgAFFH8LAAMeAAQJlSEmBwBrAQAeAAQJmx8mBwBrAQAUAAEJnSTQEABqAAAuAAQKfyEABB4ABwlZJGsIALcCAB4ABwkcImsIALcCABQABglGJWURAFcCABwABQmSGpwtAHIBAAAA.',
['纳格']='纳格兰小火球:BAAALgAECgEJAQAAAA==.',
['纷飞']='纷飞的飞:BAAALgAECgQJBgAAAA==.',
['终结']='终结的希望:BAAALgAECgMJAwAAAA==.',
['绿玩']='绿玩羔手:BAABLgAFFH8QAAIIAAUJKiTbEABdAQAIAAUJKiTbEABdAQAAAA==.',
['绿的']='绿的你发慌:BAAALgAECgYJEQAAAA==.',
['绿皮']='绿皮火车丶:BAAALgAECgIJAgAAAA==.',
['羽田']='羽田郎君:BAAALgAECgYJEwAAAA==.',
['老钅']='老钅:BAAALgAFFAIJAwAAAA==.',
['聖一']='聖一:BAABLgAFFH8FAAIPAAIJyRhDFgCRAAAPAAIJyRhDFgCRAAAAAA==.',
['肥的']='肥的办不成事:BAAALgAECgEJAQAAAA==.',
['肺总']='肺总荡漾:BAAALgAECgMJAgAAAA==.',
['胸肌']='胸肌发达:BAAALgAECgUJBQAAAA==.',
['脚猪']='脚猪子:BAACLgAFFH8QAAINAAUJ4x5YAgDhAQANAAUJ4x5YAgDhAQAuAAQKfyUAAw0ACAl4JLQEAFcDAA0ACAl4JLQEAFcDAB0AAQmpCP3dACUAAAAA.',
['腿爷']='腿爷:BAAALgAECgEJAQAAAA==.',
['膝盖']='膝盖迎着风:BAABLgAECn8WAAMWAAgJ4B7TGQBIAgAWAAcJdSLTGQBIAgAaAAcJkBTcJgDbAQAAAA==.',
['自动']='自动刷卡:BAAALgADCgQJBAAAAA==.',
['艾丽']='艾丽茜亚:BAAALgAFFAIJAwAAAA==.',
['艾伊']='艾伊儿:BAAALgAECgYJCAAAAA==.',
['艾伦']='艾伦耶格尔:BAAALgADCgEJAQAAAA==.',
['艾斯']='艾斯艾沐:BAAALgAECgYJBwAAAA==.',
['艾星']='艾星电网公司:BAAALgAECgYJDwAAAA==.',
['艾瑞']='艾瑞贝司:BAAALgAECgYJBwAAAA==.',
['花芯']='花芯歌:BAAALgAECgEJAQAAAA==.',
['苍穹']='苍穹獵丶贡克:BAAALgAFFAEJAQAAAA==.',
['苍蓝']='苍蓝星:BAAALgAECgQJBAAAAA==.',
['草莓']='草莓星冰乐:BAAALgAECgYJBgAAAA==.',
['荒野']='荒野之刃:BAAALgADCgEJAQAAAA==.',
['莎赫']='莎赫扎德:BAAALgADCgEJAQAAAA==.',
['莫桑']='莫桑比克驸马:BAAALgAECgEJAQAAAA==.',
['菈克']='菈克丝:BAABLgAECn8WAAIBAAYJTxrwggDLAQABAAYJTxrwggDLAQAAAA==.',
['菲林']='菲林:BAAALgADCgMJAwAAAA==.',
['萌新']='萌新的希望:BAAALgADCgYJCQAAAA==.',
['萌萌']='萌萌哒丨雯雯:BAAALgADCgcJBwABLgAECgYJDgADAAAAAA==.萌萌的李知恩:BAAALgAECgMJAwAAAA==.',
['萎靡']='萎靡:BAAALgAECgcJBwABLgAFFAUJBQAIADIKAA==.',
['萨勒']='萨勒芬妮:BAAALgADCgEJAQAAAA==.',
['萨萨']='萨萨你按:BAAALgAECgYJCQAAAA==.',
['葵葵']='葵葵不吃饭:BAACLgAFFH8FAAMEAAUJgRhhDwBkAQAEAAQJkxphDwBkAQAFAAEJShIqFABWAAAuAAQKfyoAAwUACQnbIMEDALACAAQACQnlHUYLACEDAAUABwlXIsEDALACAAAA.',
['蒂亚']='蒂亚菠萝:BAAALgAECgUJBQAAAA==.',
['蓝丶']='蓝丶扌:BAAALgAECgYJDAAAAA==.',
['蕉蕉']='蕉蕉:BAAALgAECgMJAwAAAA==.',
['薩勒']='薩勒芬妮:BAAALgADCgcJBwAAAA==.',
['藄藄']='藄藄閴閴:BAAALgADCgYJBgAAAA==.',
['虚空']='虚空调酒师:BAAALgAECgQJBgAAAA==.',
['虞美']='虞美人:BAAALgAECgEJAQAAAA==.',
['蛋糕']='蛋糕寶寶:BAABLgAECn8VAAIOAAcJ5QljhwBsAQAOAAcJ5QljhwBsAQAAAA==.',
['衰變']='衰變灬方程式:BAAALgAECgYJBgABLgAFFAYJFwAUANsRAA==.',
['被羟']='被羟煎的鱼:BAAALgADCgUJBQAAAA==.',
['西王']='西王:BAAALgAFFAIJAwAAAA==.',
['要抱']='要抱抱丶:BAAALgAFFAEJAQAAAA==.',
['親丶']='親丶愛嘀:BAACLgAFFH8FAAIWAAIJ3wVQHACFAAAWAAIJ3wVQHACFAAAuAAQKfxcAAhYACAk1ERAsANwBABYACAk1ERAsANwBAAAA.',
['訫麟']='訫麟:BAAALgAECgEJAQAAAA==.',
['詾围']='詾围剥夺者:BAAALgAECgcJBwAAAA==.',
['謟謟']='謟謟設計申請:BAAALgAECgQJBwAAAA==.',
['让奶']='让奶妈先上:BAACLgAFFH8NAAIhAAQJqR7JAgBaAQAhAAQJqR7JAgBaAQAuAAQKfxcAAiEACQlUG9cVAFsCACEACQlUG9cVAFsCAAAA.',
['谢谢']='谢谢你的爱:BAAALgADCgQJBAAAAA==.',
['谷维']='谷维粒:BAAALgAECgYJCAAAAA==.',
['豪个']='豪个子先生:BAAALgADCgYJBgAAAA==.',
['貝爾']='貝爾摩德:BAAALgAECgMJAwAAAA==.',
['贪玩']='贪玩:BAABLgAFFH8JAAMJAAMJCRwpDAC0AAAIAAMJCRxMLgDgAAAJAAMJrAkpDAC0AAAAAA==.',
['贱血']='贱血封喉:BAAALgAECgYJCgAAAA==.',
['贼拉']='贼拉硬:BAAALgAECgcJDQAAAA==.',
['赤膊']='赤膊上阵:BAAALgAECgEJAQAAAA==.',
['走路']='走路摇:BAAALgADCgIJAgAAAA==.',
['赵丽']='赵丽颖:BAAALgAECgcJBwAAAA==.',
['赵云']='赵云:BAACLgAFFH8NAAIRAAUJCgluBAA3AQARAAUJCgluBAA3AQAuAAQKfxgAAhEABwlnDngdAFoBABEABwlnDngdAFoBAAAA.',
['赶紧']='赶紧散:BAAALgAECgIJAgAAAA==.',
['超人']='超人嘎嘎:BAAALgADCgEJAQAAAA==.',
['超究']='超究武神覇斩:BAEALgAECgEJAQABLgAFFAQJBwAGAJ8OAA==.',
['越努']='越努力越幸運:BAAALgAECgIJAgAAAA==.',
['蹦沙']='蹦沙卡拉卡哈:BAAALgAFFAIJAwAAAA==.',
['辉子']='辉子来了:BAAALgAFFAIJBAAAAA==.',
['辛希']='辛希娅:BAAALgAECgUJBQAAAA==.',
['过分']='过分里:BAAALgAECgcJEgAAAA==.',
['这波']='这波怎么说:BAABLgAECn8UAAIEAAgJARzzKQBoAgAEAAgJARzzKQBoAgAAAA==.',
['这算']='这算夸奖吗:BAAALgAECgIJAwAAAA==.',
['远尘']='远尘:BAAALgAECgcJBwABLgAFFAIJBQAEAFcVAA==.',
['远辰']='远辰:BAAALgAECggJCwAAAA==.',
['迪凯']='迪凯刘琦琦:BAACLgAFFH8NAAIIAAQJgBe0DwBiAQAIAAQJgBe0DwBiAQAuAAQKfxwAAggACQmOIOISAAoDAAgACQmOIOISAAoDAAAA.',
['迷你']='迷你本鸡面:BAAALgAECgYJDAAAAA==.迷你狗不理:BAAALgAECgQJBgAAAA==.',
['迷途']='迷途的精灵:BAAALgAECgQJCAAAAA==.',
['追寻']='追寻武道巅峰:BAAALgAECgEJAQAAAA==.',
['逆天']='逆天恶灵:BAABLgAFFH8EAAIEAAIJsxDIGQChAAAEAAIJsxDIGQChAAAAAA==.',
['逍遥']='逍遥侯:BAAALgADCgYJBgAAAA==.',
['逐风']='逐风者的祝福:BAABLgAFFH8LAAMYAAMJox6/AQAcAQAYAAMJHhu/AQAcAQAXAAIJNx07FgCyAAAAAA==.',
['逹哒']='逹哒:BAAALgAECgcJCAAAAA==.',
['道长']='道长灬:BAAALgAECgQJAQAAAA==.',
['達摩']='達摩院首座:BAAALgAECgYJCwAAAA==.',
['遗忘']='遗忘余辉:BAAALgAECgYJBgAAAA==.',
['遗歌']='遗歌彻夜:BAACLgAFFH8UAAMEAAUJqx+EDQBwAQAEAAQJnR6EDQBwAQAFAAMJOiDABQAUAQAuAAQKfycAAwQACQnDIxUQAPkCAAQACQmCIxUQAPkCAAUABAlGIxUWAJkBAAAA.',
['那哪']='那哪行啊:BAAALgADCgYJBgAAAA==.',
['那條']='那條龍:BAAALgAECgQJBAABLgAFFAIJBAADAAAAAA==.',
['邪恶']='邪恶的小然然:BAAALgADCgQJBAAAAA==.',
['邪殺']='邪殺:BAAALgADCgcJDAAAAA==.',
['部落']='部落丶大混子:BAAALgAFFAQJBAAAAA==.',
['醉颜']='醉颜:BAAALgAECgYJBwAAAA==.',
['醬豆']='醬豆腐:BAAALgADCgUJBQAAAA==.',
['鉮之']='鉮之血訫:BAAALgAECgYJDAAAAA==.',
['钙奶']='钙奶:BAAALgAECgEJAQAAAA==.',
['铁卫']='铁卫:BAAALgAECgIJAgAAAA==.',
['铸丶']='铸丶光:BAAALgAECgYJBwAAAA==.',
['锦鲤']='锦鲤绾绾:BAAALgADCgQJBAAAAA==.',
['镜泷']='镜泷:BAACLgAFFH8KAAMjAAQJlCF3BgCSAQAjAAQJlCF3BgCSAQAkAAEJnhUYCQBYAAAuAAQKfyAAAyMACAlJITwUAD8CACMABwlDITwUAD8CACQABglKHdESALUBAAAA.',
['镰刀']='镰刀与锤子:BAAALgAECgcJBwAAAA==.',
['长夜']='长夜无明:BAABLgAECn8ZAAMUAAgJXROxHAD4AQAUAAgJXROxHAD4AQAcAAEJSgmnYwAxAAAAAA==.',
['长孙']='长孙阿宝:BAAALgAECgYJDAAAAA==.',
['阿兰']='阿兰贝尔:BAAALgADCgEJAQAAAA==.',
['阿蘇']='阿蘇勒:BAAALgAECgQJBgAAAA==.',
['陈列']='陈列师:BAAALgADCgMJAwAAAA==.',
['陈盛']='陈盛:BAAALgAECgMJAwAAAA==.',
['陈绮']='陈绮贞丶:BAACLgAFFH8FAAIBAAIJmxQzOgC2AAABAAIJmxQzOgC2AAAuAAQKfxQAAgEABwmdINEuALcCAAEABwmdINEuALcCAAAA.',
['陌上']='陌上倾寒:BAAALgAECgEJAgAAAA==.',
['雄哥']='雄哥我来了:BAACLgAFFH8JAAINAAQJ9RNKDgD6AAANAAQJ9RNKDgD6AAAuAAQKfxUAAg0ACAngHqANAMECAA0ACAngHqANAMECAAAA.',
['雨落']='雨落抚山河:BAAALgAECgEJAQAAAA==.',
['雪紫']='雪紫夜:BAAALgAECgIJAwAAAA==.',
['雪色']='雪色天空:BAAALgAECgQJBQAAAA==.',
['雪莹']='雪莹:BAACLgAFFH8IAAIBAAIJuwrlHQCcAAABAAIJuwrlHQCcAAAuAAQKfxQAAgEABglqGbuVAKgBAAEABglqGbuVAKgBAAAA.',
['零丶']='零丶离陌:BAAALgAECgQJBAAAAA==.零丶隅曦:BAAALgADCgYJBgAAAA==.',
['雷公']='雷公劈豆腐:BAAALgAFFAIJAgAAAA==.',
['霜之']='霜之男爵:BAAALgADCgYJBgAAAA==.',
['霸气']='霸气魔童:BAAALgAFFAIJAQAAAA==.',
['青柠']='青柠普洱:BAAALgAECgUJBQAAAA==.',
['青灯']='青灯夜游:BAAALgAECgUJBQABLgAFFAEJAQADAAAAAA==.',
['靜尘']='靜尘:BAAALgAECgEJAQAAAA==.',
['顿顿']='顿顿有酒喝:BAAALgADCgMJAwAAAA==.',
['预感']='预感大王:BAAALgAECgYJDwAAAA==.',
['颓丧']='颓丧:BAAALgAECgkJCQAAAA==.',
['颓废']='颓废:BAAALgAECgkJCQAAAA==.',
['风好']='风好大喔:BAAALgAECgcJDQAAAA==.',
['风逝']='风逝残禓笑:BAAALgAECgYJBwAAAA==.',
['风雪']='风雪丶溟泠:BAACLgAFFH8TAAIBAAUJFhMhDQCyAQABAAUJFhMhDQCyAQAuAAQKfywAAgEACAn2IAMGAFACAAEACAn2IAMGAFACAAAA.',
['飘飘']='飘飘拳:BAAALgAECgEJAQAAAA==.',
['食蕉']='食蕉魔男:BAAALgAECgYJBgAAAA==.',
['馒头']='馒头小丸纸:BAAALgAECgYJDAAAAA==.',
['香草']='香草咖啡蛋糕:BAAALgAECgYJBwAAAA==.',
['高戈']='高戈奈斯:BAAALgADCgEJAQAAAA==.',
['高端']='高端的猎手:BAAALgADCgEJAQAAAA==.',
['鬼門']='鬼門龍王:BAABLgAFFH8HAAIiAAQJ5RWmCABeAQAiAAQJ5RWmCABeAQABLgAFFAcJBgAjADUaAA==.',
['魔法']='魔法少女二病:BAAALgAECgQJBAAAAA==.魔法胖次少女:BAABLgAFFH8FAAIdAAQJfRVBCABOAQAdAAQJfRVBCABOAQAAAA==.',
['鲟鳗']='鲟鳗鲩鲵鲍鱼:BAAALgADCgcJBgAAAA==.',
['鲫丶']='鲫丶鱼:BAACLgAFFH8OAAIBAAQJTyUwDAC7AQABAAQJTyUwDAC7AQAuAAQKfxcAAgEACAm8JHYNAFoDAAEACAm8JHYNAFoDAAAA.',
['鸵鸟']='鸵鸟临死前灬:BAAALgAECgIJAgAAAA==.',
['黄花']='黄花狸:BAAALgAECgMJAQAAAA==.',
['黑天']='黑天鹅:BAAALgADCgEJAQAAAA==.',
['黑暗']='黑暗丨伯爵:BAAALgADCgYJBgAAAA==.',
['黑瀧']='黑瀧:BAAALgAECgcJBwAAAA==.',
['黒之']='黒之暴力:BAAALgAECgIJAgAAAA==.',
['黙黙']='黙黙:BAAALgAECgIJAgAAAA==.',
['黯然']='黯然小灰灰:BAAALgAECgYJBgAAAA==.',
['龍湮']='龍湮断魂:BAAALgAECgcJDAAAAA==.',
['龙吟']='龙吟核桃:BAAALgADCgEJAQAAAA==.',
['龙城']='龙城飞将丶骑:BAAALgAECgUJCwAAAA==.',
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
