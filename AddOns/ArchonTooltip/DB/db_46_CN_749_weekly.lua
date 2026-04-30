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

local lookup = {'Warlock-Demonology','Rogue-Outlaw','Warrior-Fury','Monk-Mistweaver','Druid-Balance','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Unholy','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','DeathKnight-Blood','Mage-Frost','Druid-Restoration','Paladin-Retribution','DemonHunter-Devourer','Paladin-Holy','Hunter-BeastMastery','Monk-Brewmaster','Hunter-Marksmanship','Priest-Holy','Druid-Guardian','Evoker-Preservation','Warlock-Affliction','Priest-Discipline','Paladin-Protection','Monk-Windwalker','Warrior-Protection',}
local provider = {region='CN',realm='熵魔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abaddon:BAAALgAFFAIJAwAAAA==.',
Bi='Biubiubiu:BAAALgADCgMJAwAAAA==.',
Ch='Cheetos:BAAALgADCgUJBQAAAA==.',
Cr='Creative:BAAALgADCgEJAQAAAA==.',
Do='Doken:BAAALgAECgYJCgAAAA==.',
Dr='Drail:BAAALgAECgUJCwAAAA==.Dreamend:BAAALgAECgYJDAAAAA==.',
Ev='Evilisnear:BAABLgAFFH8EAAIBAAIJtxq0FAC9AAABAAIJtxq0FAC9AAAAAA==.',
Ga='Gaura:BAAALgAECgQJBgAAAA==.',
Gg='Ggkiller:BAAALgAECgYJDAABLgAFFAUJDwACAHgXAA==.',
Go='Goblinkiller:BAABLgAFFH8FAAIDAAIJkhfeCAC2AAADAAIJkhfeCAC2AAAAAA==.',
Gw='Gwendolyn:BAAALgADCgMJAwAAAA==.',
Hu='Huskarl:BAAALgAECgUJBQAAAA==.',
['Hé']='Héstía:BAAALgAECgEJAQAAAA==.',
Ic='Icecoffee:BAAALgAECgIJAgAAAA==.',
Ja='Jarl:BAAALgAECgEJAQAAAA==.',
Ju='Justice:BAAALgAECgEJAQAAAA==.',
Jy='Jydk:BAAALgAECgcJDwAAAA==.',
Ko='Kous:BAAALgAFFAIJAwAAAA==.',
La='Lams:BAAALgAECgEJAQAAAA==.Launcelot:BAAALgAECgcJBwAAAA==.',
Lo='Losointa:BAABLgAECn8dAAIEAAgJDCH3AADNAgAEAAgJDCH3AADNAgAAAA==.Louisvuitton:BAAALgAECgQJBgAAAA==.',
Ma='Maxgogo:BAAALgAECgIJAQAAAA==.Maxmom:BAAALgADCgUJBwAAAA==.',
Md='Mdai:BAAALgAECgcJBwAAAA==.',
Mi='Mizuki:BAABLgAECn8VAAIFAAYJdSFzGgAxAgAFAAYJdSFzGgAxAgAAAA==.',
Ni='Nimble:BAACLgAFFH8PAAMCAAUJeBdfAABaAQAGAAUJ0hQ6CABlAQACAAQJgQ5fAABaAQAuAAQKfyIABAYACQlwImYCAIcDAAYACQnSIWYCAIcDAAIABAlGGwIJAOkAAAcAAQnnFwkcAEgAAAAA.Niubility:BAABLgAECn8fAAIIAAcJRCFyMgBtAgAIAAcJRCFyMgBtAgABLgAFFAIJAgAJAAAAAA==.',
Po='Poliwrath:BAAALgAECgQJBAAAAA==.',
Ra='Ray:BAAALgADCgEJAQAAAA==.',
Sm='Smartliu:BAAALgAFFAIJBAAAAA==.',
Ti='Titansnova:BAAALgADCgEJAQAAAA==.',
Xi='Xici:BAAALgAECgIJAgAAAA==.',
Ye='Yewang:BAAALgAECgYJCQAAAA==.',
Yl='Ylinf:BAAALgADCgIJAgAAAA==.',
Zy='Zyh:BAAALgAECgcJDwAAAA==.',
['一个']='一个奶爸:BAACLgAFFH8IAAIKAAMJXBYkDwDvAAAKAAMJXBYkDwDvAAAuAAQKfxQAAgoABwmyHJgaAEMCAAoABwmyHJgaAEMCAAAA.',
['一刀']='一刀掌死你:BAAALgAECgMJAwAAAA==.',
['一切']='一切漠视:BAAALgAECgEJAQAAAA==.',
['一大']='一大波茄子:BAAALgADCgYJBgAAAA==.',
['一杯']='一杯狐狸:BAAALgAECgkJCwAAAA==.',
['一梦']='一梦入星河:BAAALgAECgEJAgAAAA==.',
['一炮']='一炮射死你:BAAALgAECgEJAQAAAA==.',
['一百']='一百多个萨满:BAACLgAFFH8JAAILAAQJqAleBwDjAAALAAQJqAleBwDjAAAuAAQKfxoABAsACAlPE6cmAN0BAAsACAlPE6cmAN0BAAwABgm/Aq8dAPIAAAoAAgkMAnSRAFQAAAAA.',
['七海']='七海娜娜米丷:BAAALgAECgYJDAAAAA==.',
['万妖']='万妖皇:BAAALgAECgEJAQAAAA==.',
['三八']='三八牌烤肥虫:BAAALgAECgcJCQAAAA==.',
['三田']='三田老师:BAAALgAECgMJAwAAAA==.',
['三角']='三角初华:BAABLgAFFH8QAAIBAAQJRRjMEQBWAQABAAQJRRjMEQBWAQAAAA==.',
['丑到']='丑到灵魂深处:BAAALgAECgEJAQAAAA==.',
['丨重']='丨重生丨:BAAALgAECgMJAwAAAA==.',
['丶一']='丶一颗黑蛋丶:BAAALgAECgkJDgAAAA==.',
['丶柠']='丶柠小萌灬:BAAALgAECgkJEAAAAA==.',
['丶沐']='丶沐小雪灬:BAABLgAECn8WAAMNAAkJyB2LBwCyAgANAAkJjRyLBwCyAgAIAAcJXRtXgACCAQAAAA==.丶沐雨橙风:BAAALgAFFAEJAQAAAA==.',
['丶飒']='丶飒丶:BAAALgAECgUJBQAAAA==.',
['举三']='举三反一:BAAALgAECgYJBgAAAA==.',
['乜也']='乜也露露:BAABLgAECn8VAAIOAAgJ8x6CWAAvAgAOAAgJ8x6CWAAvAgAAAA==.',
['二号']='二号机:BAAALgAECgEJAgAAAA==.',
['井空']='井空丶请自重:BAAALgADCgEJAQAAAA==.',
['亚火']='亚火:BAAALgAECgQJBwAAAA==.',
['人心']='人心薄凉丶伤:BAABLgAECn8UAAMFAAkJ9RjVCgDoAgAFAAkJ9RjVCgDoAgAPAAYJZg97bwAHAQABLgAECgkJHAAFAFEjAA==.',
['仓老']='仓老师:BAAALgAECgYJBwAAAA==.',
['伊什']='伊什塔尔:BAAALgAECgEJAQAAAA==.',
['伐白']='伐白相:BAAALgAECgEJAwAAAA==.',
['你愁']='你愁啥:BAABLgAECn8jAAIEAAgJvBYiFQAfAgAEAAgJvBYiFQAfAgAAAA==.',
['侠魍']='侠魍:BAAALgAECgUJCQAAAA==.',
['信仰']='信仰圣光吧:BAABLgAFFH8FAAIQAAIJphplDgCwAAAQAAIJphplDgCwAAAAAA==.',
['光头']='光头牛:BAAALgAECgEJAQAAAA==.',
['光尐']='光尐:BAAALgAECgEJAQAAAA==.',
['光明']='光明乳业:BAAALgAECgYJCwAAAA==.',
['兎兎']='兎兎兔子丶:BAAALgADCgYJBgAAAA==.',
['八百']='八百轻梦丶:BAAALgADCgIJAgAAAA==.',
['公牛']='公牛的血:BAABLgAFFH8FAAMLAAIJ3CDeCACyAAALAAIJ3CDeCACyAAAKAAEJLQOKJgA7AAAAAA==.',
['六九']='六九式:BAABLgAFFH8GAAIRAAMJVA9READQAAARAAMJVA9READQAAAAAA==.',
['兰娜']='兰娜瑟尔丶:BAAALgADCgMJAwAAAA==.',
['冰墓']='冰墓裁决:BAAALgAECgIJAwAAAA==.',
['冰壁']='冰壁的邪宫:BAAALgAECgYJCQAAAA==.',
['冰忆']='冰忆:BAABLgAFFH8IAAISAAQJgBF3CQA+AQASAAQJgBF3CQA+AQAAAA==.',
['冰棠']='冰棠桂圆:BAAALgADCgYJBgAAAA==.',
['冷丶']='冷丶言:BAAALgADCgEJAQAAAA==.',
['凡人']='凡人皆有一死:BAAALgAFFAEJAQAAAA==.',
['别开']='别开枪是我:BAAALgAECgYJDgAAAA==.',
['午夜']='午夜胸岭:BAABLgAECn8YAAITAAcJBhwYJQAoAgATAAcJBhwYJQAoAgAAAA==.',
['卡列']='卡列乌斯:BAAALgAECgkJBwAAAA==.',
['只是']='只是条闲鱼:BAAALgAECgQJBAAAAA==.',
['叫我']='叫我大尸兄:BAAALgAECgUJCAAAAA==.',
['叶子']='叶子:BAAALgAECgMJBAAAAA==.',
['吉尔']='吉尔尼斯德:BAAALgAECgEJAQAAAA==.',
['君临']='君临天下寒:BAAALgAECgQJBAAAAA==.',
['吾宁']='吾宁爱与憎:BAAALgAFFAQJBAAAAA==.',
['咏春']='咏春丶叶问:BAABLgAFFH8FAAIUAAIJnwrJDACIAAAUAAIJnwrJDACIAAAAAA==.',
['咕咕']='咕咕丶:BAAALgAECgQJBAAAAA==.',
['咸鱼']='咸鱼提督:BAAALgAFFAEJAQAAAA==.',
['哈娜']='哈娜琉斯:BAAALgAFFAEJAQAAAA==.',
['啊要']='啊要拉油啊:BAABLgAECn8UAAMTAAcJmxk7JgAhAgATAAcJmxk7JgAhAgAVAAYJvRCrPABqAQAAAA==.',
['四十']='四十几只萨满:BAAALgAFFAIJAwAAAA==.',
['四只']='四只柚子:BAAALgADCgQJBAAAAA==.',
['四糸']='四糸乃:BAAALgADCgEJAQAAAA==.',
['回头']='回头一曰:BAAALgAECgEJAgAAAA==.',
['圣光']='圣光二愣子:BAAALgAECgMJAwAAAA==.',
['地狱']='地狱镇魂曲:BAAALgADCgUJBQAAAA==.',
['垂青']='垂青:BAAALgAECgEJAQAAAA==.',
['堆花']='堆花:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落乱舞:BAAALgADCgMJAwAAAA==.',
['大木']='大木老師:BAAALgAFFAIJAwAAAA==.',
['大黑']='大黑哞:BAAALgAECgcJCAAAAA==.',
['天色']='天色绝艳滟:BAAALgAECgQJBAAAAA==.',
['天降']='天降元素:BAAALgAECgYJCwAAAA==.天降苦痛:BAAALgAECgYJDwAAAA==.',
['太难']='太难得的回忆:BAAALgAECgYJEwAAAA==.',
['奕剑']='奕剑十五:BAAALgADCgEJAQAAAA==.',
['奥术']='奥术麦旋风:BAAALgAFFAEJAQAAAA==.',
['奥泽']='奥泽美咲:BAAALgAFFAQJBAAAAA==.',
['奶茶']='奶茶灬:BAAALgAECgYJBgAAAA==.',
['好抽']='好抽得:BAAALgAFFAEJAQAAAA==.',
['好男']='好男人老婆造:BAAALgAECgIJAgAAAA==.',
['妖性']='妖性凛然:BAAALgAECgkJBwAAAA==.',
['季来']='季来之则安之:BAAALgAECgYJEAAAAA==.',
['安格']='安格斯谷饲:BAAALgAFFAIJAgAAAA==.',
['宝宝']='宝宝蛇快冲:BAAALgAECgUJBgAAAA==.',
['对不']='对不起我要赢:BAAALgAFFAIJAgAAAA==.',
['封印']='封印黄昏:BAAALgAECgQJBAAAAA==.',
['小张']='小张:BAAALgAFFAMJBAAAAA==.',
['小德']='小德你站住:BAAALgADCgUJBQAAAA==.',
['小拉']='小拉布:BAAALgAECgcJDAAAAA==.',
['小狐']='小狐:BAAALgAECgUJCAAAAA==.',
['小盆']='小盆:BAAALgAECgQJAwAAAA==.',
['小羊']='小羊肖恩:BAAALgAECgYJBwAAAA==.',
['小软']='小软软:BAAALgAECgEJAgAAAA==.',
['小雨']='小雨:BAAALgAECgIJAgAAAA==.',
['小黄']='小黄人之怒:BAAALgADCgcJBwAAAA==.',
['小鼠']='小鼠大浪:BAAALgAECgEJAQAAAA==.',
['岚木']='岚木偶:BAAALgAFFAEJAgAAAA==.',
['帝王']='帝王:BAAALgAECgYJCgAAAA==.',
['平安']='平安喜樂:BAAALgAFFAEJAQAAAA==.',
['年年']='年年雪:BAAALgADCgYJBgAAAA==.',
['幽灵']='幽灵之翼:BAAALgAECgkJEAAAAA==.',
['幽狼']='幽狼:BAAALgAECgYJDgAAAA==.',
['幽魅']='幽魅冰影:BAAALgAECgcJDQABLgAFFAYJFwAWANsRAA==.',
['庐州']='庐州月光:BAAALgAECgkJBgAAAA==.',
['弄潮']='弄潮大师:BAAALgADCgYJBgAAAA==.',
['弄白']='弄白相:BAAALgAECgIJAwAAAA==.',
['弑神']='弑神者丶:BAAALgAECgIJBAAAAA==.',
['弦卷']='弦卷心:BAABLgAFFH8IAAIBAAQJeRRcBQBhAQABAAQJeRRcBQBhAQAAAA==.',
['弹凸']='弹凸凸:BAAALgADCgQJBAAAAA==.',
['往后']='往后余生:BAAALgAECgcJCwAAAA==.',
['心陌']='心陌南尘:BAAALgAECgEJAQAAAA==.',
['惊涛']='惊涛骇浪杀:BAAALgADCgYJCQAAAA==.',
['我不']='我不是牛牛:BAACLgAFFH8FAAIXAAIJywklBQBqAAAXAAIJywklBQBqAAAuAAQKfxkAAhcABgktEfQUACIBABcABgktEfQUACIBAAAA.',
['我只']='我只吃肉:BAAALgAECgYJCAAAAA==.',
['我就']='我就喝特仑苏:BAAALgAECgEJAwAAAA==.',
['我心']='我心里:BAAALgAECgIJAgAAAA==.',
['戦之']='戦之棱:BAAALgADCgEJAQAAAA==.',
['扁食']='扁食:BAAALgAECgcJDQAAAA==.',
['才哥']='才哥的愤怒:BAAALgAECgUJBgAAAA==.',
['托身']='托身白刃:BAAALgAECgYJCgAAAA==.',
['扯断']='扯断红尘:BAAALgAECgUJBQAAAA==.',
['捞鱼']='捞鱼骑士:BAACLgAFFH8FAAMSAAIJaBdmFACeAAASAAIJaBdmFACeAAAQAAIJzgnzKQCOAAAuAAQKfxgAAxIABglyHRkpAOYBABIABglyHRkpAOYBABAAAwmwHGDeANAAAAAA.捞鱼龙人:BAAALgAFFAEJAgAAAA==.',
['斩魂']='斩魂使:BAAALgAECgkJDQAAAA==.',
['无敌']='无敌小可爱:BAAALgAECgEJAQAAAA==.无敌王卵大帝:BAABLgAFFH8FAAIRAAIJqAb+FgCFAAARAAIJqAb+FgCFAAAAAA==.',
['旧夏']='旧夏小红手:BAAALgAFFAQJBQAAAA==.',
['易水']='易水歌:BAAALgADCgUJBQAAAA==.',
['星尘']='星尘大海:BAACLgAFFH8JAAIYAAMJNCQ1CwA3AQAYAAMJNCQ1CwA3AQAuAAQKfyYAAhgABwnqJGMFAPQCABgABwnqJGMFAPQCAAAA.',
['星晨']='星晨猎丶:BAAALgAECgEJAQAAAA==.',
['星谋']='星谋:BAAALgAECgcJDgAAAA==.',
['星辰']='星辰之翼:BAAALgAECgcJBwAAAA==.星辰蓝天:BAAALgAFFAIJAgABLgAFFAMJCQAYADQkAA==.',
['春生']='春生夏长:BAAALgAECgIJAgAAAA==.',
['暗夜']='暗夜譕情:BAAALgAFFAEJAQAAAA==.',
['曹小']='曹小贝贝:BAAALgAECgQJBAAAAA==.',
['曾经']='曾经丶爱过:BAAALgAECgMJAwAAAA==.',
['最完']='最完美的孤独:BAAALgADCgMJAwAAAA==.',
['最终']='最终幻想:BAAALgADCgcJBwAAAA==.',
['松本']='松本洋一:BAAALgAECgQJBAAAAA==.',
['林深']='林深时见鹿:BAAALgAECgYJBwAAAA==.',
['果冻']='果冻超人:BAAALgAECgYJCgAAAA==.',
['栗子']='栗子醋:BAAALgAFFAQJBAAAAA==.',
['森林']='森林德:BAAALgAECgMJAwAAAA==.',
['椰椰']='椰椰:BAABLgAFFH8FAAIIAAIJBB1pEwDAAAAIAAIJBB1pEwDAAAAAAA==.',
['榴莲']='榴莲千层:BAAALgADCgEJAQAAAA==.',
['正三']='正三三:BAAALgADCgEJAQAAAA==.',
['歪比']='歪比巴卜:BAAALgAECgYJBwAAAA==.',
['死亡']='死亡体育生:BAAALgAECgYJBwAAAA==.死亡旋涡:BAAALgAFFAEJAgAAAA==.',
['水港']='水港灬长钓:BAAALgAECgQJCAAAAA==.',
['江流']='江流:BAAALgAECgQJBQAAAA==.',
['沁染']='沁染烟雨:BAACLgAFFH8HAAIOAAIJ4A0lQACuAAAOAAIJ4A0lQACuAAAuAAQKfyMAAg4ABwm2H7hEAGoCAA4ABwm2H7hEAGoCAAAA.',
['没可']='没可乐的日子:BAABLgAECn8XAAIIAAcJrRACfwCFAQAIAAcJrRACfwCFAQAAAA==.',
['法圣']='法圣:BAAALgAFFAIJAgAAAA==.',
['泰迪']='泰迪:BAAALgAECgIJAgAAAA==.',
['浅度']='浅度失忆:BAAALgADCgEJAQAAAA==.',
['浅野']='浅野心:BAAALgAECgYJCQAAAA==.',
['浴紫']='浴紫而存:BAAALgADCgYJBgAAAA==.',
['涟灬']='涟灬漪:BAAALgAFFAIJBAAAAA==.',
['深度']='深度失忆:BAABLgAFFH8FAAIIAAIJ3BklNwCtAAAIAAIJ3BklNwCtAAAAAA==.',
['源氏']='源氏:BAAALgADCgQJBAAAAA==.',
['潘凤']='潘凤丶:BAAALgADCgMJAwAAAA==.',
['灥龘']='灥龘:BAAALgAECgYJBgAAAA==.',
['火吻']='火吻而生:BAAALgAECgMJAwAAAA==.',
['灬悟']='灬悟灬:BAAALgAECgMJAwAAAA==.',
['灬殇']='灬殇城灬:BAAALgAECgEJAQAAAA==.',
['灭魔']='灭魔者佐罗斯:BAAALgAECgYJCwAAAA==.',
['炸掉']='炸掉男厕所:BAAALgAECgEJAgAAAA==.',
['烟花']='烟花丶易冷:BAAALgAECgEJAQAAAA==.烟花易冷丶:BAAALgAECgcJAgAAAA==.',
['热凸']='热凸凸:BAAALgAECgUJBgAAAA==.',
['煽动']='煽动:BAABLgAFFH8GAAITAAMJHxzODwDJAAATAAMJHxzODwDJAAAAAA==.',
['熊抱']='熊抱抚细腰:BAAALgAFFAIJAgAAAA==.',
['熵魔']='熵魔魅影:BAAALgAECgUJBQAAAA==.',
['燃烧']='燃烧吼小宇宙:BAAALgADCgUJBQAAAA==.',
['燕过']='燕过留影:BAAALgAECgYJCwAAAA==.',
['爱布']='爱布拉娜:BAAALgAECgYJDwAAAA==.',
['爱莉']='爱莉希雅:BAAALgAFFAQJBAAAAA==.',
['牛牛']='牛牛我很壮:BAAALgAFFAEJAgAAAA==.',
['特斯']='特斯拉面:BAAALgAFFAIJAgAAAA==.',
['猫熊']='猫熊伊:BAAALgAECgkJEgABLgAFFAQJDAAKALAVAA==.',
['玖條']='玖條璃雨:BAAALgADCgEJAQAAAA==.',
['玛丽']='玛丽莲曼森:BAAALgAECgIJAgAAAA==.',
['玩叫']='玩叫卡门:BAAALgAECgEJAQAAAA==.',
['由乃']='由乃:BAAALgAFFAEJAQAAAA==.',
['画画']='画画花钿:BAAALgADCgUJBQAAAA==.',
['留在']='留在你生命里:BAAALgAECgIJAwAAAA==.',
['疯子']='疯子冥泪:BAABLgAECn8aAAISAAYJICCwIAAWAgASAAYJICCwIAAWAgAAAA==.疯子晚餐:BAAALgAECgEJAQAAAA==.',
['疾影']='疾影:BAAALgAECgUJBQAAAA==.',
['痞子']='痞子灬小漠:BAAALgAECgMJAwAAAA==.',
['盲僧']='盲僧:BAAALgAECgEJAQAAAA==.',
['稚辞']='稚辞:BAAALgAECgIJAgAAAA==.',
['立花']='立花正仁:BAAALgAECgUJDQAAAA==.',
['童帝']='童帝结城结弦:BAAALgAECgEJAQAAAA==.',
['米兰']='米兰达小新星:BAAALgAECgEJAQAAAA==.',
['繁尘']='繁尘:BAAALgADCgYJBgAAAA==.',
['红墙']='红墙白雪:BAAALgAECgEJAQAAAA==.',
['红头']='红头发魔鬼:BAABLgAECn8XAAITAAcJoBlvIQA9AgATAAcJoBlvIQA9AgAAAA==.',
['维维']='维维:BAAALgAECgYJCwAAAA==.',
['缥缈']='缥缈星星:BAAALgADCgcJDAAAAA==.',
['罗宾']='罗宾丶妮可:BAACLgAFFH8DAAIBAAIJcSEzEwDNAAABAAIJcSEzEwDNAAAuAAQKfxQAAwEABgk0Jb9BAAgCAAEABQk0Jb9BAAgCABkAAQkAAJ8nAFMAAAAA.',
['老男']='老男孩依旧帥:BAAALgAECgkJCQAAAA==.老男孩依旧酷:BAAALgAECgkJEAABLgAFFAUJBwAOAMcZAA==.老男孩依然帥:BAAALgAECgcJCgAAAA==.',
['耐揍']='耐揍:BAAALgAECgQJBgAAAA==.',
['聃丶']='聃丶尛:BAAALgAECgMJBAAAAA==.聃丶沫:BAAALgADCgUJBQAAAA==.聃丶苒:BAAALgAECgMJAwAAAA==.聃丶言:BAAALgADCgIJAgAAAA==.聃丶陌:BAAALgAECgMJAwAAAA==.',
['肥羊']='肥羊肥羊:BAAALgAECgEJAQAAAA==.',
['背弃']='背弃光明:BAAALgAECgYJDQAAAA==.',
['胖迪']='胖迪凯:BAAALgAECgYJDgAAAA==.',
['能哥']='能哥:BAAALgAECgYJBwAAAA==.',
['舞夜']='舞夜秋楓:BAAALgADCgIJAgAAAA==.',
['艾瑞']='艾瑞莉娅:BAAALgAECggJCAAAAA==.',
['艾蕾']='艾蕾什基伽尔:BAAALgAECgEJAQAAAA==.',
['苍崎']='苍崎青子丶:BAAALgAECgYJDAAAAA==.',
['苏拉']='苏拉玛法爷:BAAALgAECgQJBAAAAA==.',
['荒天']='荒天骑:BAAALgAECgUJBgABLgAFFAUJEwAQAPgkAA==.',
['莉娜']='莉娜丶依巴斯:BAAALgADCgQJCAAAAA==.',
['莽姐']='莽姐姐:BAAALgAFFAIJAgAAAA==.',
['蓖麻']='蓖麻:BAACLgAFFH8FAAIWAAIJlxwNBQCtAAAWAAIJlxwNBQCtAAAuAAQKfxYAAxYABgnSHhsbAAMCABYABgmJHhsbAAMCABoAAgmBF01HAIMAAAAA.',
['蕾塞']='蕾塞:BAABLgAFFH8IAAIBAAQJ0hntDAB0AQABAAQJ0hntDAB0AQAAAA==.',
['薇尔']='薇尔莉特:BAABLgAFFH8GAAIBAAQJaxZ+DwBjAQABAAQJaxZ+DwBjAQAAAA==.',
['虾仁']='虾仁:BAAALgAECgUJCgAAAA==.',
['蜂蜜']='蜂蜜芥末猫:BAAALgADCgYJBgAAAA==.',
['蜜桃']='蜜桃小公主:BAAALgAECgcJCAAAAA==.',
['蜡烛']='蜡烛骑士:BAAALgAFFAEJAQAAAA==.',
['血染']='血染过的凶器:BAABLgAFFH8FAAITAAIJExy8FACxAAATAAIJExy8FACxAAABLgAFFAQJDAATAAgYAA==.',
['西条']='西条克洛迪娜:BAAALgAFFAQJBAAAAA==.',
['读来']='读来过倒才牛:BAAALgAFFAMJAwAAAA==.',
['象拔']='象拔蚌走位:BAAALgAECgUJCQAAAA==.',
['贝西']='贝西西:BAAALgAFFAIJAgAAAA==.',
['贫僧']='贫僧法号能抗:BAAALgAECgMJAwAAAA==.',
['贵阳']='贵阳马东锡丶:BAABLgAFFH8FAAIKAAUJCAy4BACEAQAKAAUJCAy4BACEAQAAAA==.',
['走过']='走过倒一片:BAAALgADCgEJAQAAAA==.',
['软软']='软软:BAAALgAECgQJBgAAAA==.',
['辛德']='辛德穆拉丶:BAAALgAFFAIJBAAAAA==.',
['达芬']='达芬:BAAALgAECgEJAgAAAA==.',
['送老']='送老师:BAAALgADCgEJAQAAAA==.送老师圣光:BAABLgAECn8VAAMQAAcJbRaMVwDcAQAQAAcJbRaMVwDcAQAbAAEJAAAnQwAxAAAAAA==.送老师暗夜:BAAALgAECgcJEQAAAA==.送老师的兔子:BAABLgAECn8WAAIOAAcJvhMckQCxAQAOAAcJvhMckQCxAQAAAA==.',
['送达']='送达傲视:BAAALgAECgYJEAAAAA==.',
['逆鳞']='逆鳞无常:BAAALgAECgQJBgAAAA==.',
['郑三']='郑三娃儿:BAAALgADCgIJAgAAAA==.',
['醉丶']='醉丶墨湮:BAAALgAECgIJAgAAAA==.',
['钟宝']='钟宝儿:BAAALgAECgEJAgAAAA==.',
['钿钿']='钿钿:BAABLgAFFH8FAAIOAAIJ2SSFFgDHAAAOAAIJ2SSFFgDHAAAAAA==.',
['铃木']='铃木一彻:BAAALgADCgIJAgAAAA==.',
['银松']='银松:BAAALgAECgEJAQAAAA==.',
['锅碗']='锅碗瓢盆缸:BAAALgADCgEJAQAAAA==.',
['開心']='開心到转圈:BAAALgAECggJDAABLgAFFAQJCAAcALsjAA==.',
['闪电']='闪电五连缏:BAAALgAECgEJAQAAAA==.',
['闪闪']='闪闪的阿喵:BAAALgAECgYJCAAAAA==.',
['闷聲']='闷聲作大死:BAAALgAECgEJAQAAAA==.',
['阿不']='阿不一:BAAALgAECgYJCAAAAA==.',
['阿殇']='阿殇小刀:BAAALgAECgEJAQAAAA==.',
['阿要']='阿要辣油啊氵:BAAALgAECgYJDgAAAA==.',
['阿里']='阿里粉骑:BAAALgAECgMJAwAAAA==.',
['雨歇']='雨歇留忆:BAAALgAECgEJAQAAAA==.',
['零壹']='零壹零壹零壹:BAACLgAFFH8HAAIKAAMJZSABEQDgAAAKAAMJZSABEQDgAAAuAAQKfyYAAgoACAnRISEEADQCAAoACAnRISEEADQCAAAA.',
['雷勃']='雷勃:BAACLgAFFH8OAAIdAAQJkxdVBAA6AQAdAAQJkxdVBAA6AQAuAAQKfxgAAh0ACAnBGSQLAF0CAB0ACAnBGSQLAF0CAAAA.',
['雷霆']='雷霆灬战斧:BAACLgAFFH8LAAIIAAQJGx8bCwB6AQAIAAQJGx8bCwB6AQAuAAQKfxoAAggACAlbIogPACADAAgACAlbIogPACADAAAA.雷霆牙:BAAALgAECgEJAQAAAA==.',
['青雉']='青雉:BAAALgAECgUJBQAAAA==.',
['青鸟']='青鸟:BAAALgAECgYJDAAAAA==.',
['颤动']='颤动的电棒:BAAALgAECgYJCAAAAA==.',
['風之']='風之哀傷:BAAALgAECgkJCQAAAA==.',
['风傻']='风傻傻:BAABLgAFFH8FAAIMAAIJQw2uAgCcAAAMAAIJQw2uAgCcAAAAAA==.',
['飘落']='飘落的孤心:BAAALgAECgUJBAAAAA==.飘落的豆:BAAALgAECgYJCgAAAA==.',
['饮血']='饮血者辛拜瓦:BAAALgAFFAEJAQAAAA==.',
['香蕉']='香蕉不呐呐:BAAALgADCgYJBgAAAA==.',
['麻美']='麻美老师:BAAALgAECgMJBgAAAA==.',
['麻麻']='麻麻鳗鱼王:BAAALgAECgcJDAAAAA==.',
['黑暗']='黑暗之翼:BAAALgAECgkJEAAAAA==.',
['龍噬']='龍噬血云:BAAALgAECgMJAwAAAA==.',
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
