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

local lookup = {'Unknown-Unknown','Paladin-Retribution','Paladin-Protection','DemonHunter-Devourer','Priest-Holy','Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Druid-Balance','Druid-Guardian','Warlock-Demonology','Mage-Frost','DeathKnight-Blood','Warrior-Arms','Warrior-Fury','Warrior-Protection','Druid-Restoration','Hunter-Marksmanship','DeathKnight-Unholy','Shaman-Restoration','Shaman-Elemental','DeathKnight-Frost',}
local provider = {region='CN',realm='奥妮克希亚',name='CN',type='weekly',zone=46,date='2026-04-25',data={De='Deathgun:BAAALgADCgYJBgAAAA==.',
Do='Dounnai:BAAALgAECgIJAgABLgAECgcJDAABAAAAAA==.',
Ga='Gakki:BAAALgAECgcJBwAAAA==.',
Gi='Gil:BAAALgAECgEJAQAAAA==.',
Ho='Holyroller:BAAALgADCgIJAgAAAA==.',
Hz='Hz:BAAALgADCgUJBQAAAA==.',
Ii='Iissio:BAAALgAECgIJAgAAAA==.',
Mi='Mimika:BAAALgAECgEJAQAAAA==.',
Oi='Oissii:BAAALgAECgcJCQAAAA==.',
Pa='Pasts:BAAALgAFFAEJAQAAAA==.',
Pz='Pzzp:BAAALgADCgcJBwAAAA==.',
Qo='Qo:BAAALgAFFAEJAQAAAA==.',
Sk='Skytielo:BAAALgAECgYJDgAAAA==.',
To='Torukmakto:BAACLgAFFH8KAAICAAQJHRCiDABHAQACAAQJHRCiDABHAQAuAAQKfyEAAgIABwmYIqEpAH4CAAIABwmYIqEpAH4CAAAA.',
Up='Uprising:BAACLgAFFH8FAAICAAIJ0RiRIQCqAAACAAIJ0RiRIQCqAAAuAAQKfxQAAgIABgkcIi8+ACwCAAIABgkcIi8+ACwCAAAA.',
Wa='Warlockzpj:BAAALgAECgYJDwAAAA==.',
Wi='Wiingwiing:BAAALgAECgYJDgAAAA==.',
Zt='Ztide:BAABLgAECn8iAAMCAAcJzBEtbQCjAQACAAcJzBEtbQCjAQADAAMJewj5NQBsAAAAAA==.',
['一小']='一小哦一:BAAALgADCgEJAQAAAA==.',
['七天']='七天叁岁:BAAALgAFFAQJBAAAAA==.',
['三角']='三角钱的故事:BAAALgAECgYJCgAAAA==.',
['上帝']='上帝的骨架:BAAALgAECgcJBwAAAA==.',
['不加']='不加的小法:BAAALgADCgcJBwAAAA==.',
['不死']='不死青年:BAAALgAFFAIJBAAAAA==.',
['久五']='久五二七:BAAALgAECgEJAgAAAA==.',
['乌蒙']='乌蒙圣骑:BAAALgAECgYJDgAAAA==.',
['乐乐']='乐乐:BAAALgAECgMJAwAAAA==.',
['五条']='五条悟:BAACLgAFFH8MAAIEAAQJqRvxBQBKAQAEAAQJqRvxBQBKAQAuAAQKfyAAAgQABwmWII8jAHwCAAQABwmWII8jAHwCAAAA.',
['人辶']='人辶告革:BAAALgAECgYJDAABLgAECgYJEQABAAAAAA==.',
['人造']='人造棉:BAAALgAECgYJEQAAAA==.',
['伊人']='伊人相忘:BAABLgAECn8dAAQFAAcJGB7QEQBTAgAFAAcJGB7QEQBTAgAGAAIJUwVMWQBVAAAHAAIJNQKNUQBFAAAAAA==.',
['伊利']='伊利达雷暗影:BAAALgADCgcJBwAAAA==.',
['何事']='何事九:BAAALgAECgkJDgAAAA==.',
['余额']='余额不足了啊:BAAALgAECgMJAwAAAA==.余额不足了额:BAAALgAECgYJBgAAAA==.',
['元宝']='元宝之辰:BAAALgAECgYJBgAAAA==.',
['入魂']='入魂一箭:BAABLgAFFH8FAAIIAAMJoxqkCQAUAQAIAAMJoxqkCQAUAQAAAA==.',
['六角']='六角钱的故事:BAAALgAECgUJCQAAAA==.',
['兰颜']='兰颜知己:BAAALgAECgYJEgAAAA==.',
['兿無']='兿無所侑:BAAALgAECgMJAwAAAA==.',
['冰淇']='冰淇淋可乐:BAAALgAECgEJAQAAAA==.',
['凸勒']='凸勒拔姬:BAAALgADCgYJBgAAAA==.',
['剑啸']='剑啸江湖:BAAALgAECgEJAQAAAA==.',
['剩奇']='剩奇石:BAAALgAFFAEJAwAAAA==.',
['功夫']='功夫熊貓:BAAALgADCgEJAQAAAA==.',
['十三']='十三厶:BAAALgAECgYJBgABLgAECgYJEQABAAAAAA==.',
['十五']='十五楼的娇娇:BAAALgADCgUJCAAAAA==.',
['十年']='十年人间丶:BAAALgAFFAIJAwAAAA==.',
['千尾']='千尾离鸢:BAAALgAFFAEJAQAAAA==.',
['变熊']='变熊当输出:BAABLgAECn8dAAMJAAgJNhpYKgCtAQAJAAcJaxxYKgCtAQAKAAgJ5Qn4FQATAQAAAA==.',
['可爱']='可爱:BAABLgAFFH8GAAILAAIJeiPBKADTAAALAAIJeiPBKADTAAAAAA==.',
['可青']='可青可:BAAALgAECgYJBgAAAA==.',
['呀咩']='呀咩了个蝶:BAAALgAECgcJBwAAAA==.',
['呼噜']='呼噜灵波:BAAALgAECgUJBQAAAA==.',
['啤酒']='啤酒肚拳王:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光伊伊:BAAALgAECgMJAwAAAA==.',
['坑地']='坑地天坑基友:BAAALgADCgEJAQAAAA==.',
['埋姑']='埋姑娘的:BAAALgADCgIJAgAAAA==.',
['墨染']='墨染:BAAALgAECgQJBAAAAA==.',
['夜恋']='夜恋晨:BAAALgAECgUJBQAAAA==.',
['夜色']='夜色配咖啡:BAAALgADCgEJAQAAAA==.',
['奥妮']='奥妮克希雅:BAAALgAECgEJAQAAAA==.',
['媛沐']='媛沐歌谣:BAAALgAECgUJBQAAAA==.',
['季伯']='季伯:BAAALgADCgEJAQAAAA==.',
['富春']='富春山居:BAAALgAECgYJCwAAAA==.',
['寵妳']='寵妳一玍:BAAALgAECgEJAQAAAA==.',
['小媚']='小媚半步癫:BAAALgAECgYJDQAAAA==.',
['小小']='小小丶法:BAAALgAECgYJDQAAAA==.小小快跑:BAACLgAFFH8FAAIMAAIJOxAWPQCyAAAMAAIJOxAWPQCyAAAuAAQKfxQAAgwABgmDG8d/ANEBAAwABgmDG8d/ANEBAAAA.',
['小拾']='小拾壹:BAAALgAECgYJBgAAAA==.',
['小沫']='小沫小娴:BAAALgAECgIJAgAAAA==.',
['小螺']='小螺号嘀嘀吹:BAAALgAECgYJCAAAAA==.',
['屯溪']='屯溪丶曼波:BAAALgAECgEJAQAAAA==.',
['工具']='工具人败家:BAAALgADCgQJBAAAAA==.',
['帝牙']='帝牙卢卡:BAAALgAECgMJAwAAAA==.',
['幽幽']='幽幽相随:BAAALgAECgIJBAAAAA==.',
['彼得']='彼得潘达:BAAALgAECgYJBgAAAA==.',
['德道']='德道成仙:BAAALgAECgEJAQAAAA==.',
['心随']='心随我動:BAAALgAECgEJAQAAAA==.',
['想你']='想你成疯:BAAALgAECgEJAQAAAA==.',
['慕容']='慕容烟花:BAAALgAECgMJAwAAAA==.',
['慕玥']='慕玥儿:BAAALgAECgQJCwAAAA==.',
['我来']='我来时的路:BAAALgAECgUJCQAAAA==.',
['扯蛋']='扯蛋因步子大:BAAALgAFFAEJAgAAAA==.',
['抓根']='抓根宝丶:BAAALgAECgMJBAAAAA==.',
['拉索']='拉索米索拉索:BAAALgAECgEJAQAAAA==.',
['拉蒂']='拉蒂欧斯:BAAALgAECgQJBgAAAA==.',
['接种']='接种而来:BAABLgAFFH8FAAINAAMJORRXCgDdAAANAAMJORRXCgDdAAAAAA==.',
['提里']='提里奥皮卡丘:BAAALgAECgcJDAAAAA==.',
['搅局']='搅局者:BAAALgAECgMJAwAAAA==.',
['无双']='无双丶战神:BAAALgAECgcJCAAAAA==.',
['无敌']='无敌小七:BAAALgAECgcJEwAAAA==.',
['时光']='时光如梦:BAAALgAECgcJBgAAAA==.',
['时间']='时间嘚玫瑰:BAAALgAECgYJCwAAAA==.',
['最终']='最终之守望:BAAALgADCgUJBQAAAA==.',
['月落']='月落凝霜:BAABLgAFFH8UAAMOAAYJkB9aAAAQAgAOAAYJ4x1aAAAQAgAPAAUJNhMqBQCgAQABLgAFFAcJDQAQAM4ZAA==.月落无霜:BAAALgAECgcJCAAAAA==.',
['朵莉']='朵莉亚:BAAALgAECgQJCQAAAA==.',
['梦断']='梦断蓝桥:BAAALgAECgcJCQAAAA==.',
['榴莲']='榴莲侠:BAAALgAECgYJDQAAAA==.',
['橘栗']='橘栗橘气:BAAALgADCgEJAQAAAA==.',
['橙子']='橙子菠萝汁:BAAALgAECgQJAwAAAA==.',
['橙鱼']='橙鱼零度空间:BAACLgAFFH8KAAIMAAMJ8xK/DwARAQAMAAMJ8xK/DwARAQAuAAQKfyEAAgwACAl4IjkQAEcDAAwACAl4IjkQAEcDAAAA.',
['欧米']='欧米茄丶暗翼:BAAALgAECgQJBAABLgAFFAQJCgAPAB8ZAA==.欧米茄骑士:BAACLgAFFH8KAAIPAAQJHxkLDwAUAQAPAAQJHxkLDwAUAQAuAAQKfyMAAw8ACQm2IgAEAGwDAA8ACQm2IgAEAGwDAA4AAQlmGqw4AEwAAAAA.',
['正义']='正义花生:BAAALgAECgMJAwAAAA==.',
['死亡']='死亡灬孑然:BAAALgAECgYJCwAAAA==.',
['毛毛']='毛毛虫儿:BAAALgAECgUJCgABLgAFFAQJCgAPAB8ZAA==.',
['江左']='江左萌:BAAALgAECgIJAgAAAA==.',
['汽水']='汽水大将军:BAABLgAFFH8FAAILAAMJ2QtEJADzAAALAAMJ2QtEJADzAAAAAA==.',
['沐歌']='沐歌遥:BAAALgAECgUJCwAAAA==.',
['沐遥']='沐遥小朋友:BAAALgAECgUJBQAAAA==.',
['法丝']='法丝:BAAALgAECgEJAQAAAA==.',
['洁白']='洁白如墨:BAAALgAECgMJAwAAAA==.',
['洛羽']='洛羽:BAAALgADCgEJAQAAAA==.',
['流莺']='流莺舞月:BAAALgADCgMJAwAAAA==.',
['涂山']='涂山:BAAALgAECgkJBwAAAA==.',
['淡漠']='淡漠:BAAALgAECgQJBQAAAA==.',
['灬克']='灬克蕾雅:BAAALgAFFAEJAQAAAA==.',
['爬行']='爬行动物:BAABLgAFFH8HAAIKAAUJcRX9AACLAQAKAAUJcRX9AACLAQAAAA==.',
['狠妞']='狠妞儿:BAABLgAECn8UAAIRAAcJEhQdPQCvAQARAAcJEhQdPQCvAQABLgAFFAYJFQAJAHIhAA==.',
['獠牙']='獠牙:BAAALgADCgEJAQAAAA==.',
['玫蓝']='玫蓝就瑰:BAAALgAECgYJDAAAAA==.',
['疯丶']='疯丶狂奏曲:BAAALgADCgUJBQAAAA==.',
['皮卡']='皮卡丘丘:BAAALgADCgMJAwABLgAECgcJDAABAAAAAA==.',
['礥燺']='礥燺:BAAALgAECgQJBgAAAA==.',
['神之']='神之拳拳:BAAALgAFFAEJAQAAAA==.',
['神奇']='神奇小白龙:BAABLgAFFH8HAAIFAAQJPgjaBgAIAQAFAAQJPgjaBgAIAQAAAA==.',
['秀逗']='秀逗吴:BAAALgADCgIJAgAAAA==.',
['秋叶']='秋叶澜:BAAALgADCgEJAQAAAA==.',
['稀有']='稀有品种:BAAALgAECgEJAQAAAA==.',
['穆娴']='穆娴:BAAALgAECgEJAQAAAA==.',
['筱馨']='筱馨甜甜:BAAALgAECgYJBgABLgAFFAQJCgAPAB8ZAA==.',
['箭男']='箭男春:BAABLgAECn8ZAAIIAAcJexsBJAAuAgAIAAcJexsBJAAuAgAAAA==.',
['纯情']='纯情母蟑螂:BAAALgAECgUJBQAAAA==.',
['绿茵']='绿茵冉冉:BAAALgAECgUJBQAAAA==.',
['聖光']='聖光降臨:BAAALgAECgMJAwAAAA==.',
['艾尼']='艾尼维亚:BAAALgAECgMJAwAAAA==.',
['芬芳']='芬芳善射:BAAALgAECgMJAwAAAA==.芬芳年华:BAAALgAECgQJBwAAAA==.',
['花生']='花生小孔:BAAALgAECgEJAgAAAA==.',
['花镜']='花镜丶僧:BAAALgAECgIJBQAAAA==.花镜丶锋:BAAALgAECgIJBgAAAA==.',
['苍珦']='苍珦:BAAALgADCgEJAQAAAA==.',
['苦逼']='苦逼的大完美:BAAALgAECgIJAgAAAA==.',
['莎丶']='莎丶点:BAAALgAECgYJCAAAAA==.',
['莣誋']='莣誋蓯葥:BAAALgADCgEJAQAAAA==.',
['蒂法']='蒂法:BAAALgAECgUJDgAAAA==.',
['虫虫']='虫虫不知:BAAALgAECgUJCAAAAA==.',
['蛋黄']='蛋黄大圣:BAAALgAECgEJAgAAAA==.',
['血海']='血海芬芳:BAAALgAECgYJCQAAAA==.',
['血艺']='血艺味精:BAAALgAECgUJBgAAAA==.',
['言宁']='言宁宝宝:BAAALgAECgYJCAAAAA==.',
['豆渣']='豆渣:BAAALgAECgEJAgAAAA==.',
['跳起']='跳起一巴掌:BAAALgAECgYJBgAAAA==.',
['轻影']='轻影:BAABLgAECn8YAAICAAcJPRasUwDnAQACAAcJPRasUwDnAQAAAA==.',
['迦陵']='迦陵晚:BAAALgAECgYJBgABLgAFFAYJBQASACQLAA==.',
['迷宫']='迷宫世界:BAAALgAECgIJBAAAAA==.',
['选择']='选择大于努力:BAABLgAFFH8FAAITAAIJ6BeUPQCjAAATAAIJ6BeUPQCjAAAAAA==.',
['逐风']='逐风之心:BAAALgAECgMJBAAAAA==.',
['铁蛋']='铁蛋:BAAALgAECgYJBwAAAA==.',
['铷花']='铷花世玉:BAAALgAECgYJDAAAAA==.',
['门清']='门清无花果:BAABLgAFFH8FAAIUAAMJUgWbEgDOAAAUAAMJUgWbEgDOAAAAAA==.',
['闪闪']='闪闪的你:BAAALgAECgEJAQAAAA==.',
['阿橙']='阿橙:BAAALgADCgEJAQAAAA==.',
['隐梦']='隐梦:BAAALgAECgcJBwAAAA==.',
['雷神']='雷神之力:BAAALgAECgcJDQAAAA==.',
['霸气']='霸气的牛:BAAALgAECgEJAwAAAA==.',
['非常']='非常阔气:BAAALgAECgUJBQAAAA==.',
['顶不']='顶不住打击:BAAALgADCgEJAQAAAA==.',
['颜歌']='颜歌冰冰:BAABLgAECn8cAAMUAAcJFh8GFQBtAgAUAAcJFh8GFQBtAgAVAAQJWwosZQCuAAAAAA==.',
['风中']='风中歌声:BAAALgAECgIJAgAAAA==.',
['风雨']='风雨丶:BAABLgAFFH8KAAMTAAMJKBfEJgD8AAATAAMJKBfEJgD8AAAWAAEJ1wIAAAAAAAABLgAFFAYJDAANABkYAA==.',
['饭团']='饭团恶魔:BAAALgAECgkJAgABLgAFFAUJBQAPAIAYAA==.',
['馒头']='馒头苦干:BAAALgADCgcJBwAAAA==.',
['香烟']='香烟烫手:BAAALgAECgYJDAAAAA==.',
['骑小']='骑小猪看小妞:BAAALgAECgIJAgAAAA==.',
['高手']='高手麻衣:BAAALgAECgQJBAAAAA==.',
['鬼辰']='鬼辰:BAAALgAECgEJAQAAAA==.',
['魔法']='魔法大爷:BAAALgAECgQJBQAAAA==.',
['鲜血']='鲜血中的寒冰:BAAALgAECgIJAgAAAA==.',
['黄昏']='黄昏丶:BAAALgAECgIJAwAAAA==.',
['黑瑟']='黑瑟斯:BAAALgAECgIJAwAAAA==.',
['龙坎']='龙坎:BAAALgAECgcJBwABLgAFFAUJCQASAAIQAA==.',
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
