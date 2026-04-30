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

local lookup = {'Monk-Brewmaster','Mage-Frost','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Warrior-Protection','DemonHunter-Devourer','DemonHunter-Havoc','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Mistweaver','Evoker-Augmentation','Evoker-Devastation','Warlock-Affliction','Warlock-Demonology','Druid-Restoration','Druid-Balance','Warrior-Fury','Priest-Shadow','Druid-Feral',}
local provider = {region='CN',realm='卡扎克',name='CN',type='weekly',zone=46,date='2026-04-25',data={Af='Afdk:BAAALgAECgQJCAAAAA==.',
Al='Allenmage:BAAALgAECgkJBwAAAA==.',
Az='Azdaja:BAAALgAFFAMJAwABLgAFFAMJBQABAN4aAA==.',
Ev='Everfiame:BAAALgADCgIJAgAAAA==.',
Ez='Ezlol:BAACLgAFFH8NAAICAAQJwB+EBQB1AQACAAQJwB+EBQB1AQAuAAQKfxoAAgIACAlOJVIQAEYDAAIACAlOJVIQAEYDAAAA.',
Fr='Friedlljh:BAAALgAFFAMJBAAAAA==.',
Go='Goodb:BAAALgAFFAEJAQAAAA==.',
Ih='Ihwimsm:BAACLgAFFH8KAAIDAAQJyyBIAgCNAQADAAQJyyBIAgCNAQAuAAQKfzEAAwMACQnAIZQBAGQDAAMACQnAIZQBAGQDAAQABgnMFzAkAHIBAAAA.',
Ja='Jasonzhu:BAAALgAECgYJEAAAAA==.',
Ni='Nightlock:BAAALgAECgEJAQABLgAFFAMJBQABAN4aAA==.Nightwish:BAABLgAECn8bAAIFAAgJPRadPgA9AgAFAAgJPRadPgA9AgAAAA==.',
Po='Pokemonx:BAAALgAECgcJDAAAAA==.',
Se='Sestelemento:BAAALgADCgcJCAAAAA==.',
So='Sonny:BAAALgAECgEJAQAAAA==.',
['一块']='一块牛排:BAAALgAECgUJBQAAAA==.',
['一点']='一点点矮:BAABLgAFFH8FAAIGAAMJBxkqCwCVAAAGAAMJBxkqCwCVAAAAAA==.',
['一萱']='一萱萱一:BAACLgAFFH8KAAICAAQJmgY7MADzAAACAAQJmgY7MADzAAAuAAQKfx0AAgIACAlHF6EVAJYBAAIACAlHF6EVAJYBAAAA.',
['丁丁']='丁丁丶半米长:BAAALgAECgMJAwAAAA==.',
['三花']='三花聚顶:BAAALgAECgYJDAAAAA==.',
['不良']='不良牛:BAAALgAECgYJCwAAAA==.',
['专打']='专打小怪兽丷:BAAALgAECgEJAQAAAA==.专打小怪兽灬:BAAALgAECgUJCAABLgAFFAYJFwADANsRAA==.',
['丧钟']='丧钟镇帅小伙:BAAALgADCgUJAwAAAA==.',
['丨丄']='丨丄丨:BAAALgADCgIJAgAAAA==.',
['丨功']='丨功名丨:BAAALgAECgUJBgAAAA==.',
['丶大']='丶大黄蜂:BAAALgAECgUJBQAAAA==.',
['丶遨']='丶遨游四海:BAABLgAFFH8GAAIHAAQJzgjHCwACAQAHAAQJzgjHCwACAQAAAA==.',
['丿辉']='丿辉灬夜:BAABLgAECn8VAAICAAYJIxTpJAA9AQACAAYJIxTpJAA9AQAAAA==.',
['丿阿']='丿阿尔灬泰尔:BAAALgADCgcJBwAAAA==.',
['九啸']='九啸:BAABLgAECn8VAAIIAAgJQB/SBgD5AgAIAAgJQB/SBgD5AgAAAA==.',
['伊莉']='伊莉雅:BAAALgAECgEJAQABLgAECgUJBQAJAAAAAA==.',
['众生']='众生绝离:BAABLgAFFH8FAAIEAAMJ7xHDEgCfAAAEAAMJ7xHDEgCfAAAAAA==.',
['倾城']='倾城蝶舞:BAAALgAECgEJAQAAAA==.',
['储墨']='储墨:BAAALgAECgQJBAAAAA==.',
['傲娇']='傲娇兔儿:BAAALgADCgEJAQAAAA==.',
['冰锋']='冰锋弑魂:BAAALgAFFAIJAgAAAA==.',
['刀锋']='刀锋如浪:BAACLgAFFH8OAAMKAAQJrh2KAQB5AQAKAAQJMh2KAQB5AQALAAIJdRNGIACTAAAuAAQKfyEAAwoACQlOIpYBAIwDAAoACQllIJYBAIwDAAsABwkAInwZAFsCAAAA.',
['别玩']='别玩苍白之主:BAAALgAFFAMJBAAAAA==.',
['卡兹']='卡兹格罗兹:BAAALgAECgEJAQAAAA==.',
['发怒']='发怒的狼人:BAAALgAECgYJBQAAAA==.',
['古拉']='古拉哈骑亚:BAAALgAECgIJAgAAAA==.',
['召唤']='召唤的菲戈:BAAALgAECgMJBAAAAA==.',
['吃果']='吃果盘:BAAALgADCgEJAQAAAA==.',
['吉尔']='吉尔伽美什丶:BAAALgAFFAQJBAAAAA==.',
['呆帝']='呆帝一十九:BAAALgAECgEJAwAAAA==.呆帝一十八:BAAALgAECgIJBwAAAA==.呆帝三十七:BAAALgADCgMJAwAAAA==.',
['和会']='和会街泼妇:BAAALgAECgIJAgAAAA==.',
['和成']='和成大老黑:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜蛋:BAAALgADCgEJAQAAAA==.',
['咖啡']='咖啡是我隐藏:BAAALgAECgcJBwAAAA==.',
['咪酷']='咪酷酱:BAAALgAECgYJBQAAAA==.',
['咿唔']='咿唔吁:BAAALgAECgEJAQAAAA==.',
['善良']='善良的良:BAAALgAECgcJBQAAAA==.',
['喵叔']='喵叔壹号机:BAAALgADCgUJBQAAAA==.',
['囝囝']='囝囝囡囡:BAAALgAFFAEJAQAAAA==.',
['回眸']='回眸:BAAALgADCgYJBgAAAA==.',
['囡拳']='囡拳:BAAALgAECgkJBwABLgAFFAYJBQAMALQGAA==.',
['圣光']='圣光丶牛头人:BAAALgAECgEJAQAAAA==.圣光的阴影:BAAALgAECgcJEQAAAA==.',
['圣羽']='圣羽:BAAALgADCgMJAwAAAA==.',
['圣萨']='圣萨拉丁:BAAALgADCgUJBQAAAA==.',
['夜神']='夜神丶月:BAABLgAFFH8GAAINAAQJWQWHBgAdAQANAAQJWQWHBgAdAQAAAA==.',
['天空']='天空:BAAALgAECgEJAQAAAA==.',
['她说']='她说是晒黑的:BAAALgAECgUJBQAAAA==.',
['宝宝']='宝宝的笨笨:BAAALgAECgYJDAAAAA==.',
['宝矿']='宝矿力:BAAALgAECgcJBwAAAA==.',
['对着']='对着镜子撸:BAAALgAECgIJAgAAAA==.',
['小呆']='小呆瓜:BAAALgAECgYJBwAAAA==.',
['小月']='小月饼:BAAALgADCgIJAQAAAA==.',
['小资']='小资:BAABLgAECn8XAAIOAAYJvgtxHgA7AQAOAAYJvgtxHgA7AQAAAA==.',
['小黄']='小黄人:BAAALgAECgEJAQAAAA==.',
['峭壁']='峭壁库洛米:BAAALgADCgYJBgAAAA==.',
['巨馍']='巨馍蘸酱丶:BAAALgAECgUJBgAAAA==.',
['布鲁']='布鲁托:BAAALgADCgUJBQAAAA==.',
['希里']='希里:BAAALgAECgUJBQAAAA==.',
['師兄']='師兄:BAAALgADCgEJAQAAAA==.',
['得到']='得到如果人:BAAALgAECgEJAQAAAA==.',
['怀念']='怀念不如相见:BAAALgAECgcJBwABLgAFFAUJCAACAKsfAA==.',
['怒龙']='怒龙卷毛:BAABLgAECn8bAAIGAAgJ2gfSIAA5AQAGAAgJ2gfSIAA5AQAAAA==.',
['愤怒']='愤怒的马哥:BAAALgAECgQJBgAAAA==.',
['我爱']='我爱热干面:BAAALgAFFAEJAgAAAA==.',
['我超']='我超甜丶:BAAALgADCgUJBQAAAA==.我超红:BAABLgAECn8UAAICAAcJTCE+ZgALAgACAAcJTCE+ZgALAgAAAA==.',
['括约']='括约肌撕裂者:BAAALgAECgEJAgAAAA==.',
['摇滚']='摇滚骷髅:BAAALgADCgkJCgAAAA==.',
['摸嗯']='摸嗯萌:BAAALgAECgEJAgAAAA==.',
['放学']='放学后别走:BAAALgAECgkJCQAAAA==.',
['无眼']='无眼泪的妞:BAABLgAECn8ZAAMPAAgJoBT6BAAiAgAPAAcJnhX6BAAiAgAQAAYJEg7thABQAQAAAA==.',
['日月']='日月星陈:BAAALgAECgQJBgAAAA==.',
['早安']='早安灬地球:BAACLgAFFH8IAAIRAAQJ9w77CgAtAQARAAQJ9w77CgAtAQAuAAQKfx0AAxEACQlTG3oCAJYCABEACQlTG3oCAJYCABIAAQnfAzaLACQAAAAA.',
['星辰']='星辰月影:BAAALgAFFAMJAwAAAA==.',
['暗之']='暗之夜莺:BAAALgAECgEJAgAAAA==.',
['曼彻']='曼彻斯特传奇:BAABLgAFFH8FAAITAAMJqSLtFwCpAAATAAMJqSLtFwCpAAAAAA==.',
['条子']='条子丶:BAAALgADCgIJAgAAAA==.',
['枫之']='枫之语:BAABLgAECn8TAAMKAAgJaR9uDwDAAgAKAAgJaR9uDwDAAgALAAEJEgPglgAhAAAAAA==.枫之迅捷:BAAALgADCgcJBwAAAA==.',
['格尔']='格尔德:BAAALgAECgYJBwAAAA==.',
['格格']='格格巫:BAAALgAECgEJAQAAAA==.',
['桑叶']='桑叶果:BAAALgADCgkJCQAAAA==.',
['橘子']='橘子姐姐:BAAALgAECgEJAQAAAA==.',
['歆雾']='歆雾风:BAAALgAECgYJBgABLgAFFAUJBQABAFgQAA==.',
['死前']='死前巨饿:BAAALgADCgEJAQAAAA==.',
['殺戮']='殺戮:BAAALgAFFAIJBAABLgAFFAYJEQASAC8aAA==.',
['永带']='永带妹:BAAALgAECgEJAQAAAA==.',
['汝不']='汝不及吾秀:BAAALgAECgMJBQAAAA==.',
['沃尔']='沃尔比:BAAALgAECgUJBQAAAA==.',
['沐慕']='沐慕:BAAALgAECgIJAgAAAA==.',
['沙战']='沙战战:BAAALgADCgEJAQAAAA==.',
['法布']='法布雷加斯:BAAALgAECgEJAQAAAA==.',
['泪滴']='泪滴嘎嘎:BAAALgADCgEJAQAAAA==.',
['润如']='润如酥:BAAALgAECgQJBgAAAA==.',
['渣男']='渣男:BAAALgAECgIJAgAAAA==.',
['火焰']='火焰猫头鹰:BAAALgAECgIJBAAAAA==.',
['灬玖']='灬玖玖灬:BAAALgAECgcJEgAAAA==.',
['熊图']='熊图腾:BAABLgAFFH8FAAIBAAMJ3hoHFwC5AAABAAMJ3hoHFwC5AAAAAA==.',
['熊淘']='熊淘武乐:BAAALgAECgMJBgAAAA==.',
['熟悉']='熟悉橡树的人:BAAALgAECgEJAQAAAA==.',
['爱冬']='爱冬菇:BAAALgAFFAEJAQAAAA==.',
['爱吃']='爱吃回锅肉:BAAALgADCgEJAQAAAA==.爱吃桃子的牛:BAAALgAECgEJAQAAAA==.爱吃辣椒炒肉:BAABLgAFFH8FAAINAAIJ0w9nGAChAAANAAIJ0w9nGAChAAAAAA==.',
['牛某']='牛某瞅饼:BAAALgAFFAIJAgAAAA==.',
['牛鬼']='牛鬼也疯狂:BAAALgAECgEJAQAAAA==.',
['牢大']='牢大啊:BAAALgAECgcJBwAAAA==.',
['牧之']='牧之小麻子:BAAALgAECgEJAgAAAA==.',
['狗蛋']='狗蛋儿丶汪:BAAALgAECgIJAgAAAA==.',
['猛丨']='猛丨牛:BAAALgAECgQJBwAAAA==.',
['猪脚']='猪脚饭:BAAALgAECgQJBAAAAA==.',
['獠牙']='獠牙不长:BAAALgAECgEJAgAAAA==.',
['珝玥']='珝玥婲:BAAALgAECgYJBgAAAA==.',
['留白']='留白:BAAALgAECgcJCAAAAA==.',
['痛哭']='痛哭的人:BAAALgAECgEJAQAAAA==.',
['真的']='真的皮丶:BAAALgAECgYJCQAAAA==.真的难丶:BAAALgAECgMJAwABLgAECgYJCQAJAAAAAA==.',
['米兰']='米兰达德儿:BAAALgADCgUJBQAAAA==.',
['紫红']='紫红的:BAAALgADCgUJBQAAAA==.',
['紫苏']='紫苏回江鱼:BAAALgAECgYJEQAAAA==.',
['给斋']='给斋饭也要打:BAABLgAFFH8FAAIMAAMJEh7EDwCfAAAMAAMJEh7EDwCfAAAAAA==.',
['羽毛']='羽毛小耳环:BAAALgAECgYJBgAAAA==.',
['老妖']='老妖精:BAAALgAECgUJDAAAAA==.',
['老师']='老师带大的:BAAALgAFFAEJAQAAAA==.',
['舞随']='舞随白雪:BAABLgAECn8bAAQEAAgJFh5VCQCmAgAEAAgJYx1VCQCmAgADAAcJ1hCJMQB6AQAUAAQJMwrYTQCcAAAAAA==.',
['苏式']='苏式阿三:BAAALgAECgQJBQAAAA==.',
['萨萨']='萨萨你最好:BAAALgAECgYJCQAAAA==.',
['虚灵']='虚灵刃:BAAALgAECgYJCQAAAA==.',
['蛮荒']='蛮荒九哮:BAAALgAECgkJDQAAAA==.蛮荒九啸:BAAALgAECgcJCwAAAA==.',
['请你']='请你荔枝一点:BAAALgAECgQJCAAAAA==.',
['赞达']='赞达拉大王:BAAALgAECgMJAwAAAA==.',
['赤焰']='赤焰娇:BAAALgAECgYJBgAAAA==.',
['趣多']='趣多多:BAAALgAECgcJBQAAAA==.',
['跑快']='跑快快:BAABLgAFFH8FAAIQAAMJESHpNwCkAAAQAAMJESHpNwCkAAAAAA==.',
['身手']='身手敏捷:BAAALgAECgEJAQAAAA==.',
['辛西']='辛西娅:BAAALgAECgYJDgAAAA==.',
['过期']='过期芬达:BAAALgAECgEJAQAAAA==.',
['还我']='还我名来:BAAALgAECgYJDAAAAA==.',
['醉卧']='醉卧云中:BAAALgADCgIJAgAAAA==.醉卧云端:BAAALgADCgcJBwAAAA==.',
['野生']='野生宝可梦:BAAALgAECgQJBAAAAA==.',
['门先']='门先生小木鸠:BAAALgADCgYJBgAAAA==.',
['阿珂']='阿珂萌德:BAAALgADCgUJBQAAAA==.',
['阿诺']='阿诺史泰龙:BAAALgAECgEJAQAAAA==.',
['随缘']='随缘一砍:BAAALgADCgUJBQAAAA==.',
['霜玲']='霜玲珑:BAAALgAECgcJCQAAAA==.',
['霸气']='霸气牛真牛:BAAALgADCgUJBQAAAA==.',
['青衫']='青衫依旧:BAABLgAFFH8FAAIKAAMJwQ5cFgCsAAAKAAMJwQ5cFgCsAAAAAA==.',
['青青']='青青小板妹:BAAALgAECggJDwAAAA==.',
['风之']='风之魔女:BAAALgAECgQJBAAAAA==.',
['飘飘']='飘飘白雪:BAAALgAFFAEJAQAAAA==.',
['飞飞']='飞飞呀:BAAALgAECgUJBQAAAA==.',
['香辣']='香辣鸡腿堡:BAAALgAECgEJAQAAAA==.',
['魔王']='魔王利姆鲁:BAABLgAECn8aAAIRAAgJBySkBgAhAwARAAgJBySkBgAhAwAAAA==.',
['麻辣']='麻辣香鸡:BAAALgAECgMJAwABLgAFFAQJEAAVAOsiAA==.',
['黑夜']='黑夜梦魇:BAAALgAECgEJAQAAAA==.',
['龍炎']='龍炎焱燚:BAAALgAECgEJAQAAAA==.',
['龙行']='龙行龘龘:BAAALgAECgYJEgAAAA==.',
['龟壳']='龟壳接假死:BAAALgADCgMJAwAAAA==.',
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
