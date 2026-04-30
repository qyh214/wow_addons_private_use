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

local lookup = {'Hunter-Marksmanship','Shaman-Elemental','Warlock-Demonology','Mage-Frost','Mage-Fire','Warrior-Fury','Unknown-Unknown','Monk-Brewmaster','Priest-Discipline','Priest-Holy','Monk-Mistweaver','Paladin-Holy','Shaman-Restoration','Druid-Balance','Druid-Restoration',}
local provider = {region='CN',realm='奈法利安',name='CN',type='weekly',zone=46,date='2026-04-25',data={Br='Brontodie:BAAALgAECgQJBAAAAA==.',
Ch='Chronoswyn:BAAALgADCgYJBgAAAA==.',
De='Devilcraft:BAAALgADCgEJAQAAAA==.',
Ev='Evill:BAAALgAECgEJAQAAAA==.',
Gr='Grarl:BAAALgAECgYJBgAAAA==.Graves:BAAALgAFFAEJAQABLgAFFAUJBQABABkgAA==.',
He='Hebrewprinc:BAAALgAECggJDgAAAA==.',
Jo='Jojo:BAAALgADCgUJBQAAAA==.',
Ku='Kuburllur:BAAALgAECgEJAQAAAA==.',
Le='Lee:BAAALgAECgcJCgAAAA==.',
Sh='Shashousha:BAAALgAECgQJBAAAAA==.',
Si='Sitri:BAAALgAECgIJAgAAAA==.',
Sl='Slvakw:BAAALgAECgIJAgAAAA==.',
To='Tom:BAAALgAECgIJAgAAAA==.',
['一克']='一克拉青春:BAAALgAECgEJAwAAAA==.',
['一杨']='一杨过一:BAAALgADCgEJAQAAAA==.',
['不二']='不二术:BAAALgAECgMJAwAAAA==.',
['丨神']='丨神威丨:BAAALgAECgQJBAAAAA==.',
['中流']='中流砥柱:BAAALgAECgMJBAAAAA==.',
['丶王']='丶王迪恺:BAAALgAECgUJBQAAAA==.',
['从前']='从前的豆豆:BAAALgAECgEJAgAAAA==.',
['从未']='从未拥有:BAAALgAECgMJAwAAAA==.',
['伊斯']='伊斯瑞尔:BAAALgAECgYJEAAAAA==.',
['伊葛']='伊葛裂仁:BAAALgAECgEJAQAAAA==.',
['你被']='你被牛打过:BAAALgAFFAMJAgAAAA==.',
['冬郭']='冬郭先生:BAAALgAECgYJBgAAAA==.',
['冷夜']='冷夜雨:BAAALgAECgkJCQAAAA==.',
['冷血']='冷血图腾:BAAALgAECgUJBgAAAA==.',
['凌风']='凌风傲雪:BAAALgAECgIJAgAAAA==.',
['刻蔼']='刻蔼:BAAALgADCgUJBQAAAA==.',
['加油']='加油至宝婷:BAAALgAECgQJBAAAAA==.',
['千山']='千山墨雪:BAAALgAECgYJCQAAAA==.',
['千幻']='千幻丶:BAACLgAFFH8RAAICAAQJohkHAwBFAQACAAQJohkHAwBFAQAuAAQKfx8AAgIACQlOJCUCAJUDAAIACQlOJCUCAJUDAAAA.',
['右手']='右手:BAAALgAECgYJBgAAAA==.右手写爱:BAAALgAFFAIJAwAAAA==.',
['后丶']='后丶羿:BAAALgAECgYJBgAAAA==.',
['咖啡']='咖啡味啾啾:BAAALgAECgIJAgAAAA==.',
['啊塔']='啊塔尼斯:BAAALgADCgcJBwAAAA==.',
['圣光']='圣光熊:BAAALgAFFAIJAgAAAA==.',
['壹玖']='壹玖玖贰:BAAALgAFFAIJBAAAAA==.',
['夏韭']='夏韭菜:BAAALgADCgEJAQAAAA==.',
['夜激']='夜激舞情:BAAALgADCgIJAgAAAA==.',
['夜瓣']='夜瓣无眠:BAAALgADCgYJBgAAAA==.',
['夜色']='夜色凝霜:BAAALgAECgQJBQAAAA==.',
['大水']='大水德:BAAALgADCgQJBAAAAA==.',
['天堂']='天堂咖啡:BAAALgADCgcJBwAAAA==.',
['天玄']='天玄罗刹:BAAALgADCgEJAQAAAA==.',
['奥瑞']='奥瑞莉娅:BAAALgAECgQJAwAAAA==.',
['女乃']='女乃大吃八方:BAAALgAECgYJBwAAAA==.',
['妖娆']='妖娆小晴:BAAALgADCgYJBgAAAA==.',
['妖怪']='妖怪:BAAALgADCgMJAwAAAA==.',
['宁姚']='宁姚:BAAALgAECgEJAQAAAA==.',
['守护']='守护冰灵:BAAALgAFFAEJAQAAAA==.',
['定江']='定江山:BAAALgAECgUJCwAAAA==.',
['小嘴']='小嘴真甜:BAAALgAECgQJBwAAAA==.',
['小昕']='小昕洁:BAAALgAECgcJBgAAAA==.',
['尐武']='尐武僧:BAAALgAECgcJBwAAAA==.',
['尐灬']='尐灬情话:BAABLgAFFH8FAAIDAAUJVhXwBgCzAQADAAUJVhXwBgCzAQAAAA==.',
['尐闪']='尐闪电:BAAALgAECggJCAAAAA==.',
['尐飞']='尐飞侠:BAAALgAECgcJBgAAAA==.',
['山岭']='山岭行者巨角:BAAALgADCgIJAgAAAA==.',
['山海']='山海丨草東:BAAALgAECgQJBAAAAA==.',
['左手']='左手冰霜:BAAALgADCgIJAgAAAA==.',
['巴拉']='巴拉松:BAAALgAECgQJBAAAAA==.',
['布道']='布道者丶谍影:BAAALgADCgMJAwAAAA==.',
['幻夜']='幻夜精灵王:BAAALgAECgIJAgAAAA==.',
['建维']='建维:BAAALgAECgMJAgAAAA==.',
['彪悍']='彪悍纯牛:BAAALgAECgUJBQAAAA==.',
['德洗']='德洗浴:BAAALgAFFAMJAwAAAA==.',
['心一']='心一:BAAALgAFFAIJBAAAAA==.心一丶:BAAALgAFFAMJBAAAAA==.',
['心梦']='心梦缘飞:BAAALgAECgQJBQAAAA==.',
['思恩']='思恩僧:BAAALgAECgIJAgAAAA==.',
['怨灵']='怨灵一夜:BAAALgADCgMJAwAAAA==.',
['恐惧']='恐惧之灾:BAAALgADCgMJAwAAAA==.',
['恩地']='恩地:BAAALgAFFAEJAgAAAA==.',
['悄然']='悄然入梦:BAAALgAECgMJAwAAAA==.',
['慕斯']='慕斯小奶糕:BAAALgAECgYJBwAAAA==.',
['我你']='我你本良人:BAAALgAECgEJAQAAAA==.',
['我又']='我又又回来了:BAAALgAECgUJAwAAAA==.',
['我带']='我带地狱犬:BAAALgAECgEJAQAAAA==.',
['我闷']='我闷大饼:BAAALgAECggJEwAAAA==.',
['戒律']='戒律牧高手:BAAALgAECgIJBgAAAA==.',
['戦神']='戦神阿怒:BAAALgAECgIJAgAAAA==.',
['打滚']='打滚的小黄瓜:BAAALgAECgMJAwAAAA==.',
['无忌']='无忌丶暖暖:BAAALgAECgEJAQAAAA==.',
['春风']='春风沐宇:BAAALgAECgQJBQAAAA==.',
['昭明']='昭明丶监兵:BAAALgAECgEJAQAAAA==.',
['晨昏']='晨昏线:BAAALgAECgYJEgAAAA==.',
['普普']='普普通通:BAAALgADCgcJBwAAAA==.',
['暴躁']='暴躁的蛆:BAACLgAFFH8HAAIEAAMJHwqhLwD3AAAEAAMJHwqhLwD3AAAuAAQKfxsAAwQACAnzFtsPAMQBAAQACAnzFtsPAMQBAAUAAQkABIUEAC8AAAAA.',
['暴龙']='暴龙小子:BAABLgAFFH8IAAIGAAMJZBo1BQAOAQAGAAMJZBo1BQAOAQAAAA==.',
['月光']='月光终成沙漠:BAAALgAECggJDgAAAA==.',
['木落']='木落兔猪:BAAALgADCgUJBQAAAA==.',
['本人']='本人十八未婚:BAAALgAECgQJBAABLgAFFAgJBAAHAAAAAA==.',
['朱珠']='朱珠:BAAALgAECgEJAQAAAA==.',
['李杀']='李杀神:BAABLgAFFH8IAAIIAAQJ0xAPDAAlAQAIAAQJ0xAPDAAlAQAAAA==.',
['杨小']='杨小萌:BAAALgAECgYJCgAAAA==.',
['枫可']='枫可恋:BAAALgAECgYJCgAAAA==.',
['柊出']='柊出萝莉:BAAALgAECgkJCwAAAA==.',
['桀骜']='桀骜不驯:BAABLgAFFH8FAAIJAAIJWgI/FgB+AAAJAAIJWgI/FgB+AAAAAA==.',
['毁灭']='毁灭者佩鲁斯:BAAALgAECgMJAwAAAA==.',
['毗沙']='毗沙门天:BAAALgAECgkJCwAAAA==.',
['江米']='江米条:BAAALgAECgYJBgAAAA==.',
['汤叔']='汤叔叔:BAAALgADCgEJAQAAAA==.',
['洋气']='洋气的一天:BAAALgAECgMJBQAAAA==.',
['浅雪']='浅雪:BAAALgAECgEJAQAAAA==.',
['深海']='深海萝莉凤灬:BAAALgAFFAIJAwAAAA==.',
['清晨']='清晨:BAABLgAFFH8FAAIKAAIJyhpNCwCuAAAKAAIJyhpNCwCuAAAAAA==.',
['渲染']='渲染了离别:BAAALgAECgIJAwAAAA==.',
['火妖']='火妖法:BAAALgADCgcJCwAAAA==.',
['灬渲']='灬渲染了离别:BAAALgAECgIJAgABLgAECgIJAwAHAAAAAA==.',
['熊丨']='熊丨生之响往:BAAALgAECgcJDgAAAA==.',
['猫爷']='猫爷:BAAALgAECgEJAQAAAA==.',
['玄一']='玄一:BAAALgAECgQJCAAAAA==.',
['玖炎']='玖炎:BAAALgADCgEJAQAAAA==.',
['琪姐']='琪姐:BAAALgAECgQJBAAAAA==.',
['甜橙']='甜橙真好吃:BAAALgADCgUJBgAAAA==.',
['碧雲']='碧雲光环:BAAALgAECgIJAwAAAA==.',
['神奇']='神奇的豆豆:BAAALgAECgEJAQAAAA==.',
['神明']='神明灵:BAAALgAECgYJDAAAAA==.',
['簡單']='簡單叁丶丶:BAAALgAECgEJAgAAAA==.',
['米托']='米托维奥斯:BAAALgADCgMJAwAAAA==.',
['紫韵']='紫韵梧桐:BAAALgADCgUJBQAAAA==.',
['绽放']='绽放死亡:BAAALgAECgQJBAAAAA==.',
['老子']='老子射死你:BAAALgAECgEJAQAAAA==.',
['老邱']='老邱:BAABLgAECn8VAAILAAYJ6yCVEgA8AgALAAYJ6yCVEgA8AgABLgAFFAYJCwALAPIdAA==.',
['老雪']='老雪花丶冰蓝:BAAALgAECgQJBAAAAA==.',
['聖靈']='聖靈飞飞:BAAALgAECgUJBQAAAA==.',
['肆战']='肆战丶:BAAALgAECgIJAgAAAA==.',
['芋泥']='芋泥波波:BAAALgAECgcJEQABLgAFFAUJCgAJAJ4TAA==.',
['芒果']='芒果:BAAALgADCgEJAQAAAA==.',
['芝士']='芝士芒芒:BAACLgAFFH8GAAIMAAQJWx5oBgBxAQAMAAQJWx5oBgBxAQAuAAQKfyIAAgwACAm7HqQNAKsCAAwACAm7HqQNAKsCAAEuAAUUBQkKAAkAnhMA.',
['苏沐']='苏沐橙:BAABLgAFFH8GAAINAAMJQiIdCgAzAQANAAMJQiIdCgAzAQAAAA==.',
['苏苏']='苏苏的喵:BAAALgAECgYJCwAAAA==.',
['英俊']='英俊的青年人:BAAALgADCgUJBQAAAA==.',
['茎弹']='茎弹丨使者:BAAALgAECgQJBQAAAA==.',
['莫晚']='莫晚云:BAAALgAECgYJEAAAAA==.',
['蓝酪']='蓝酪啵啵:BAAALgAECgEJAQABLgAFFAUJCgAJAJ4TAA==.',
['血咒']='血咒战歌:BAAALgADCgYJBgAAAA==.',
['谷雨']='谷雨的立夏:BAAALgADCgEJAQAAAA==.',
['贝鲁']='贝鲁尼:BAAALgAECgIJAgAAAA==.',
['起个']='起个名真难:BAAALgAECgIJAgAAAA==.',
['超级']='超级德鲁牛:BAAALgADCgMJAwAAAA==.',
['越过']='越过山丘:BAAALgAFFAIJAgAAAA==.',
['轻狂']='轻狂落叶:BAAALgAECgYJBgAAAA==.',
['这牛']='这牛有点意思:BAAALgAECgEJAQAAAA==.',
['迪西']='迪西唔西:BAAALgAECgYJCQAAAA==.',
['逍遥']='逍遥追风:BAABLgAFFH8JAAMOAAQJjhMOCwA7AQAOAAQJjhMOCwA7AQAPAAEJhwXCJQBEAAABLgAFFAUJCwAIAPYMAA==.',
['道法']='道法禅心:BAAALgAECgIJAgAAAA==.',
['雮尘']='雮尘:BAAALgADCgEJAQAAAA==.',
['零度']='零度基因:BAAALgAECgMJAwAAAA==.',
['雷神']='雷神丿之怒:BAAALgAECgYJCgAAAA==.',
['青提']='青提茉莉:BAABLgAFFH8KAAIJAAUJnhOkBAChAQAJAAUJnhOkBAChAQAAAA==.',
['风絮']='风絮:BAAALgAECgEJAQAAAA==.',
['鬼之']='鬼之副长:BAAALgADCgUJBQAAAA==.',
['鲁克']='鲁克杨丶利刃:BAAALgADCgMJBAAAAA==.',
['麻辣']='麻辣钢板:BAAALgAFFAEJAQAAAA==.',
['黯熙']='黯熙徵伖:BAAALgADCgIJAgAAAA==.',
['龍术']='龍术:BAAALgAECgUJBgAAAA==.',
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
