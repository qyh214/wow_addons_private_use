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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','Shaman-Restoration','Shaman-Elemental','Priest-Discipline','Priest-Holy','Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Devourer','DemonHunter-Vengeance','Mage-Frost','Warlock-Demonology','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction',}
local provider = {region='CN',realm='日落沼泽',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alice:BAAALgAECgYJCAAAAA==.',
Bo='Bozoreter:BAAALgAECgYJBgAAAA==.',
Ca='Camden:BAAALgAECgEJAQAAAA==.',
Ch='Charming:BAAALgAECgcJBwAAAA==.',
Ez='Ezra:BAAALgAECgEJAQAAAA==.',
Hy='Hyouka:BAAALgAECgYJDwAAAA==.',
Jj='Jjdfw:BAAALgAECgEJAQAAAA==.',
Ku='Kungfulee:BAAALgAECgEJAQAAAA==.',
Kw='Kwashiorkor:BAAALgAECgMJBAAAAA==.',
Na='Nanana:BAAALgAFFAQJBAAAAA==.',
Or='Orange:BAAALgADCgEJAQAAAA==.',
To='Toadoil:BAAALgAECgEJAQAAAA==.',
['一点']='一点浩然气:BAAALgADCgcJBwAAAA==.',
['一百']='一百个萨满:BAAALgAECgcJAQAAAA==.',
['一蓑']='一蓑烟雨:BAAALgADCgQJBAAAAA==.',
['七星']='七星龙渊:BAACLgAFFH8UAAMBAAYJOBbxBAC3AQABAAYJOBbxBAC3AQACAAEJAADFCABaAAAuAAQKfxcAAwEACAlgGaITAEcCAAEACAneGKITAEcCAAIACAmsE8UQANEBAAAA.',
['三射']='三射定乾坤:BAAALgAFFAEJAQAAAA==.',
['三队']='三队的猎手:BAAALgAECgEJAQAAAA==.',
['乄冷']='乄冷:BAAALgAECgMJAwAAAA==.',
['乄凤']='乄凤凰:BAAALgAECgMJAgAAAA==.',
['义气']='义气哥的骑士:BAAALgAECgMJBAAAAA==.',
['乖巧']='乖巧:BAAALgAECgEJAQAAAA==.',
['你不']='你不要過來啊:BAABLgAECn8ZAAMDAAcJ7x+kFQBoAgADAAcJ7x+kFQBoAgAEAAYJ9gApbgCKAAAAAA==.',
['元丶']='元丶神:BAAALgAECgcJBwAAAA==.',
['冷無']='冷無情:BAAALgADCgEJAQAAAA==.',
['卧龙']='卧龙一出山:BAABLgAECn8dAAMFAAkJdBsRBQADAwAFAAkJ7xoRBQADAwAGAAgJJhWLGQAQAgAAAA==.卧龙七出山:BAACLgAFFH8GAAIFAAQJZh1VAwBlAQAFAAQJZh1VAwBlAQAuAAQKfyMABAUACQnhG94FAO8CAAUACQnhG94FAO8CAAYABwn7Dco0AGsBAAcAAQltDtpgADYAAAAA.卧龙三出山:BAACLgAFFH8GAAIFAAQJahx5AwBgAQAFAAQJahx5AwBgAQAuAAQKfyEAAwUACQmzHgkDAEADAAUACQmzHgkDAEADAAYACQnGDq0hANYBAAAA.卧龙九出山:BAAALgAECgYJBgAAAA==.卧龙二出山:BAACLgAFFH8JAAIFAAQJXx1ZBgB8AQAFAAQJXx1ZBgB8AQAuAAQKfygABAUACQmhIi8BAIkDAAUACQmhIi8BAIkDAAYACQkaDwgeAO4BAAcAAgk+Ib9MAKMAAAAA.卧龙五出山:BAACLgAFFH8IAAIFAAQJGBUkBABGAQAFAAQJGBUkBABGAQAuAAQKfx8AAwUACQkHHyUCAF8DAAUACQkHHyUCAF8DAAYACQm2DB8gAOEBAAAA.卧龙八出山:BAAALgAFFAMJAwAAAA==.卧龙六出山:BAACLgAFFH8GAAIFAAQJ8Bo+AwBsAQAFAAQJ8Bo+AwBsAQAuAAQKfyQAAwUACQkyHqYCAEwDAAUACQkyHqYCAEwDAAYACAk4DMUqAJ4BAAAA.卧龙十一出山:BAAALgAECgYJBgAAAA==.卧龙十二出山:BAAALgAECgYJBgAAAA==.卧龙十出山:BAAALgAECgYJBgAAAA==.卧龙四出山:BAACLgAFFH8GAAIFAAQJ3B8ZEgClAAAFAAQJ3B8ZEgClAAAuAAQKfyEAAwUACQnlG70JAJ8CAAUABwmXIL0JAJ8CAAYACQmGE0gUADwCAAAA.',
['卩丶']='卩丶聖光灬誠:BAAALgAECgYJBwAAAA==.',
['只会']='只会开无敌:BAAALgAECgEJAwAAAA==.',
['右亦']='右亦香:BAACLgAFFH8MAAIIAAQJPxJdCQBaAQAIAAQJPxJdCQBaAQAuAAQKfxsAAwgACAkwGBIRAJkCAAgACAkwGBIRAJkCAAkAAQk6C9IeADgAAAAA.',
['喀秋']='喀秋莎:BAAALgADCgUJBgAAAA==.',
['困兽']='困兽之僧:BAAALgAECgUJBgAAAA==.困兽之斗:BAAALgAECgUJCAAAAA==.困兽之死骑:BAAALgAECgEJAQAAAA==.困兽之猎头:BAAALgAECgUJBgAAAA==.困兽之贼:BAAALgAECgQJBwAAAA==.',
['地精']='地精工兵:BAAALgADCgEJAQAAAA==.',
['堕落']='堕落天城:BAAALgAFFAIJAgAAAA==.',
['墨丶']='墨丶墨:BAAALgAECgYJAQAAAA==.',
['壹丶']='壹丶壹:BAAALgAECgQJBgAAAA==.',
['夏赏']='夏赏:BAAALgAECgcJBwAAAA==.',
['夜不']='夜不收:BAAALgAECgMJAwAAAA==.',
['夜羅']='夜羅刹:BAAALgAECgcJEQAAAA==.',
['头上']='头上有犄角丶:BAACLgAFFH8LAAIKAAQJkhVWEABMAQAKAAQJkhVWEABMAQAuAAQKfyUAAwoACAlgIHwUAN0CAAoACAlgIHwUAN0CAAsAAQmBEeEwAB8AAAAA.',
['容凌']='容凌:BAABLgAFFH8HAAIMAAQJjhGoLAAEAQAMAAQJjhGoLAAEAQAAAA==.',
['小旭']='小旭旭:BAAALgADCgYJBgAAAA==.',
['小歪']='小歪丶:BAAALgADCgUJCgAAAA==.',
['小黄']='小黄丶:BAAALgADCgMJAwAAAA==.',
['山山']='山山而川:BAAALgAECgEJAQAAAA==.',
['崔希']='崔希丝:BAAALgAECgQJBAAAAA==.',
['希希']='希希酱紫:BAAALgAFFAEJAQAAAA==.',
['希贝']='希贝尔:BAAALgAECgMJAwAAAA==.',
['干死']='干死文饶:BAAALgADCgMJAwAAAA==.',
['德鲁']='德鲁丶伊德:BAAALgADCgYJBgAAAA==.',
['怕瓦']='怕瓦落地:BAAALgADCgcJBwAAAA==.',
['情丶']='情丶兽:BAAALgAECgEJAQAAAA==.',
['旭旭']='旭旭术丶:BAAALgAECgUJBQAAAA==.旭旭牧丶:BAAALgAECgcJDAAAAA==.',
['暗影']='暗影猫:BAAALgADCgMJAwAAAA==.',
['暮色']='暮色丶源尽:BAABLgAECn8VAAIKAAgJiAyabgBYAQAKAAgJiAyabgBYAQAAAA==.暮色流雲:BAABLgAFFH8FAAINAAIJCCJCKQDPAAANAAIJCCJCKQDPAAAAAA==.暮色铃瑛:BAAALgAECgEJAgAAAA==.',
['暴暴']='暴暴:BAAALgAECgYJDQAAAA==.',
['暴风']='暴风烈酒丶弑:BAAALgAECgIJAgAAAA==.',
['曓虐']='曓虐:BAAALgAECgYJEQAAAA==.',
['杰森']='杰森赫沃斯:BAAALgAECgkJCQAAAA==.',
['杰洛']='杰洛特:BAAALgAECgQJCQAAAA==.',
['枫丶']='枫丶泷:BAAALgAECgEJAQAAAA==.',
['棍状']='棍状生物体:BAAALgAECgcJBwAAAA==.',
['水悳']='水悳是个传说:BAAALgAECgkJEAAAAA==.',
['永远']='永远的牛战:BAAALgAECgEJAQAAAA==.',
['汪身']='汪身后有尾巴:BAAALgAECgYJCAAAAA==.',
['浅渡']='浅渡尘缘:BAAALgAECgUJAgAAAA==.',
['淡季']='淡季狄豹侠:BAAALgAECgIJAQAAAA==.',
['混断']='混断木桥:BAAALgADCgIJAgAAAA==.',
['清角']='清角吹寒:BAACLgAFFH8KAAIMAAMJnSFBIwAsAQAMAAMJnSFBIwAsAQAuAAQKfxMAAgwABgkMI4YSAK4BAAwABgkMI4YSAK4BAAAA.',
['湖人']='湖人总冠军:BAAALgADCgIJAgAAAA==.',
['灬不']='灬不缺牧:BAACLgAFFH8FAAIFAAQJWg43CwBRAAAFAAQJWg43CwBRAAAuAAQKfxUABAYACAmkFcopAKQBAAYABwlJFMopAKQBAAcABgkPErsKAEQBAAUAAQlmCyQaAC4AAAEuAAUUBgkGAAIACRIA.',
['灬幽']='灬幽暗丿练少:BAAALgAECgEJAQAAAA==.',
['灵月']='灵月仙子:BAAALgAECgkJCQAAAA==.',
['燃烧']='燃烧的胸毛:BAAALgADCgQJBAAAAA==.',
['牧尸']='牧尸:BAAALgADCgUJBQAAAA==.',
['牧灵']='牧灵果子:BAAALgAECgEJAQAAAA==.',
['生产']='生产队的驴:BAAALgAECgMJAwAAAA==.',
['白雾']='白雾红尘:BAAALgAECgYJBwABLgAFFAMJCQAOAB4cAA==.',
['盖拉']='盖拉多:BAAALgAECgYJDAAAAA==.',
['眠眠']='眠眠有鹿:BAAALgAECgUJBwAAAA==.',
['矛盾']='矛盾属实:BAAALgADCgMJAwAAAA==.',
['章台']='章台柳:BAAALgADCgYJBgABLgAFFAIJBQANAAgiAA==.',
['篲兒']='篲兒:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门:BAAALgAECgUJBQAAAA==.',
['纯之']='纯之父:BAAALgAFFAMJBAAAAA==.',
['纯情']='纯情老鼠人:BAAALgAECgcJDgAAAA==.',
['缺鱼']='缺鱼小水:BAAALgAECgkJCQABLgAFFAYJFwAGANsRAA==.',
['美味']='美味小王蟹:BAAALgAFFAQJBAAAAA==.',
['翠花']='翠花俺家牛呢:BAAALgAECgIJAQAAAA==.',
['老丶']='老丶虎丶熊:BAAALgADCgEJAgAAAA==.老丶虎丶牛:BAAALgAECgcJDQAAAA==.',
['至尊']='至尊寶:BAAALgAECgEJAQAAAA==.',
['艺术']='艺术:BAAALgAECgEJAQAAAA==.',
['苍白']='苍白怜悯:BAAALgAECgMJAwAAAA==.',
['萨尼']='萨尼泰特:BAAALgAECgEJAgAAAA==.',
['術心']='術心:BAAALgAECgEJAgAAAA==.',
['贵族']='贵族逸飞:BAAALgAFFAIJBAAAAA==.',
['超神']='超神乐乐:BAAALgAECgUJAwAAAA==.',
['追梦']='追梦的大叔:BAAALgAFFAIJAgAAAA==.',
['逐风']='逐风者夜羽:BAAALgADCgcJBwAAAA==.',
['邓超']='邓超:BAAALgADCgIJAgAAAA==.',
['邪鬼']='邪鬼皇族公主:BAABLgAECn8SAAQNAAUJcxcksgD0AAANAAQJlhUksgD0AAAPAAIJsRNfTQCFAAAQAAEJAAB3LgBBAAAAAA==.',
['酒吧']='酒吧长谈:BAAALgAECgMJAwAAAA==.',
['铁拳']='铁拳熊猫:BAAALgADCgEJAgAAAA==.',
['铅笔']='铅笔与橡皮:BAAALgAECgEJAQAAAA==.',
['长安']='长安一片月:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔托莉亚:BAAALgADCgcJBwAAAA==.',
['雅典']='雅典娜:BAAALgAFFAQJBAAAAA==.',
['雷霆']='雷霆猛战:BAAALgAECgQJBAAAAA==.',
['霭醭']='霭醭髟:BAAALgAECgkJCQAAAA==.',
['静朗']='静朗:BAAALgAECgMJBgAAAA==.',
['风暴']='风暴与雷鸣:BAAALgADCgEJAQAAAA==.',
['麦当']='麦当牛:BAAALgAECgEJAgAAAA==.',
['黑暗']='黑暗伊贝:BAAALgAECgEJAQAAAA==.',
['黑皮']='黑皮体育生:BAAALgAECgEJAQAAAA==.',
['龙弦']='龙弦:BAABLgAFFH8KAAIMAAQJ9RaBDwATAQAMAAQJ9RaBDwATAQAAAA==.',
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
