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

local lookup = {'Paladin-Retribution','Druid-Restoration','Druid-Balance','Warlock-Demonology','DeathKnight-Unholy','Warlock-Destruction','Warrior-Protection','Monk-Brewmaster','Monk-Mistweaver','Unknown-Unknown','Shaman-Elemental','Warrior-Fury','Warrior-Arms','DeathKnight-Frost','Priest-Holy',}
local provider = {region='CN',realm='古达克',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alecto:BAAALgAECgEJAQAAAA==.',
An='Angrymonk:BAAALgAECgEJAQAAAA==.',
As='Asanctuary:BAABLgAECn8XAAIBAAYJJyHyPAAwAgABAAYJJyHyPAAwAgAAAA==.',
Ci='Ciri:BAAALgADCgUJBQAAAA==.',
Eu='Eunomia:BAAALgAECgUJCgAAAA==.',
Ff='Ffork:BAAALgAFFAIJAwAAAA==.',
My='Myladies:BAABLgAFFH8KAAICAAQJhg4PBABOAQACAAQJhg4PBABOAQAAAA==.',
Pl='Playergqnlij:BAAALgAECgMJAgAAAA==.',
Si='Sia:BAAALgAECgEJAQAAAA==.',
Sm='Smokypan:BAAALgAFFAIJAwAAAA==.',
['不明']='不明死亡:BAAALgAECgUJBQAAAA==.',
['不爱']='不爱吃大蒜:BAAALgAECgIJAwAAAA==.',
['不给']='不给不给:BAAALgAFFAMJBAAAAA==.',
['且听']='且听龙吟:BAAALgAECgcJCQAAAA==.',
['丶泪']='丶泪残:BAAALgADCgcJBwAAAA==.',
['乐成']='乐成:BAABLgAFFH8HAAICAAMJtiIGCgA4AQACAAMJtiIGCgA4AQAAAA==.',
['亲丨']='亲丨宝贝蛋蛋:BAAALgAECgEJAQAAAA==.',
['伊丶']='伊丶瑟拉:BAAALgADCgEJAQAAAA==.',
['你被']='你被牛打过:BAABLgAFFH8HAAIDAAQJuhbUBwBjAQADAAQJuhbUBwBjAQAAAA==.',
['依然']='依然十八:BAAALgAECgEJAQAAAA==.',
['信仰']='信仰圣光吧:BAAALgAECgEJAQAAAA==.',
['信诺']='信诺千:BAAALgAFFAQJAwAAAA==.',
['兄弟']='兄弟缺德么:BAAALgAECgQJBQAAAA==.',
['克罗']='克罗玛什:BAAALgADCgYJBgAAAA==.',
['八大']='八大山人:BAAALgAECgEJAQAAAA==.',
['冷笑']='冷笑话时间:BAAALgAECgIJAwAAAA==.',
['化夙']='化夙忆蝶:BAABLgAFFH8EAAIEAAQJLg0sTgBLAAAEAAQJLg0sTgBLAAAAAA==.',
['十步']='十步杀一人:BAABLgAFFH8FAAIFAAIJYhz1GACkAAAFAAIJYhz1GACkAAAAAA==.',
['可乐']='可乐:BAAALgAECggJDgAAAA==.',
['可可']='可可脂:BAAALgAECgMJAwAAAA==.',
['咕咕']='咕咕向前冲:BAAALgAECgYJCwAAAA==.',
['哈哈']='哈哈淡定:BAAALgAECgMJAwAAAA==.',
['啊暴']='啊暴夫:BAAALgAECgQJBAAAAA==.',
['喵梦']='喵梦:BAAALgAECgEJAQAAAA==.',
['嘿咻']='嘿咻嘿咻:BAAALgADCgEJAQAAAA==.',
['土逼']='土逼:BAAALgAECgUJBgAAAA==.',
['圣光']='圣光小妞:BAAALgAECgEJAQAAAA==.',
['圣殿']='圣殿暴走王:BAAALgADCgMJAwAAAA==.',
['在下']='在下毛毛雨:BAAALgAECgMJBwAAAA==.',
['堕落']='堕落暗影:BAABLgAECn8SAAMEAAYJkhojjQA/AQAEAAUJkhojjQA/AQAGAAMJiBTbOwDFAAAAAA==.',
['大跳']='大跳冲锋躺:BAABLgAFFH8FAAIHAAQJowITCADbAAAHAAQJowITCADbAAAAAA==.',
['大鑫']='大鑫丶:BAAALgAFFAEJAQAAAA==.',
['天上']='天上不下雪:BAAALgAECgQJBAAAAA==.',
['奈斯']='奈斯米兔欧:BAAALgAECgYJCAAAAA==.',
['威仕']='威仕忌:BAAALgAECgUJBQAAAA==.',
['婉若']='婉若游龙:BAACLgAFFH8IAAIIAAQJQB0EBwBjAQAIAAQJQB0EBwBjAQAuAAQKfxUAAwgACQklGH4VAF8CAAgACAmYG34VAF8CAAkABwkDAOl4AAMAAAEuAAUUBQkBAAoAAAAA.',
['孝为']='孝为先:BAACLgAFFH8NAAMEAAUJvhRnCgCKAQAEAAUJ6QpnCgCKAQAGAAMJ/xPvBgACAQAuAAQKfxQAAgQABwlPHQ1EAAACAAQABwlPHQ1EAAACAAAA.',
['小手']='小手菇凉:BAAALgAECgEJAQAAAA==.',
['小武']='小武僧:BAACLgAFFH8WAAIIAAYJxxCgAgDCAQAIAAYJxxCgAgDCAQAuAAQKfyIAAggACQkjIL4KAN4CAAgACQkjIL4KAN4CAAAA.',
['平头']='平头哥:BAAALgAECgkJEAAAAA==.',
['张涛']='张涛涛:BAAALgADCgQJBAAAAA==.',
['彦斌']='彦斌:BAAALgAFFAIJBAAAAA==.',
['忠骨']='忠骨寒:BAABLgAFFH8GAAMGAAUJAw2tBwDzAAAGAAMJogutBwDzAAAEAAIJJBHZOQCfAAAAAA==.',
['悌连']='悌连枝:BAABLgAFFH8HAAMGAAUJjhZFBgAKAQAGAAMJdxhFBgAKAQAEAAIJ0RD0NQCnAAAAAA==.',
['惧乳']='惧乳:BAAALgADCgEJAQAAAA==.',
['我们']='我们的爱:BAAALgAECgEJAQAAAA==.',
['戦言']='戦言申:BAABLgAFFH8GAAILAAQJUgFLEQDjAAALAAQJUgFLEQDjAAAAAA==.',
['月光']='月光猪:BAAALgAFFAEJAQAAAA==.',
['朕无']='朕无罪:BAAALgAECgMJAwAAAA==.',
['末丶']='末丶洛:BAAALgAECgkJEwABLgAFFAUJDgABAE4mAA==.',
['术十']='术十二郎:BAAALgAECgIJAgABLgAFFAYJDwAEALsgAA==.',
['杰豆']='杰豆小子:BAAALgAECgIJAwAAAA==.',
['水流']='水流蝅蝅:BAAALgADCgIJAgAAAA==.',
['沙丶']='沙丶宝:BAAALgAECgYJCgAAAA==.',
['爆炸']='爆炸头:BAABLgAFFH8GAAIEAAMJ1xvUGgAdAQAEAAMJ1xvUGgAdAQAAAA==.',
['猪富']='猪富贵:BAABLgAFFH8FAAMMAAMJBhZyEAAEAQAMAAMJBhZyEAAEAQANAAEJBxCVCgBYAAAAAA==.',
['玛法']='玛法奥丨小德:BAAALgAECgQJBAAAAA==.',
['笨笨']='笨笨丶文:BAAALgAECgYJBgAAAA==.',
['筋肉']='筋肉大只佬:BAAALgAECgYJBgAAAA==.',
['紫浠']='紫浠:BAAALgAECgQJBwAAAA==.',
['紫色']='紫色斩月:BAAALgAECgYJCQAAAA==.',
['翩若']='翩若惊鸿:BAAALgAFFAMJAwABLgAFFAUJAQAKAAAAAA==.',
['脸上']='脸上的小人物:BAAALgADCgEJAQAAAA==.',
['舒子']='舒子咕咕嘎嘎:BAAALgAECgYJDAAAAA==.舒子猛得鸭痞:BAAALgAECgIJAgAAAA==.',
['若时']='若时间逆流:BAAALgAECgYJCQAAAA==.',
['萤火']='萤火流光:BAAALgAECgYJBgAAAA==.',
['蓝帶']='蓝帶:BAACLgAFFH8NAAIFAAQJCBsCDgBqAQAFAAQJCBsCDgBqAQAuAAQKfyMAAwUABwmDHhdAADgCAAUABwmDHhdAADgCAA4AAgnLFzUSAG0AAAAA.',
['赵老']='赵老师:BAAALgAECgEJAgAAAA==.',
['这不']='这不是小号:BAAALgAECgEJAgAAAA==.',
['这次']='这次对了吧:BAABLgAECn8cAAIPAAcJ4CMvAgBYAgAPAAcJ4CMvAgBYAgAAAA==.',
['邻家']='邻家的狼太妹:BAABLgAFFH8JAAIHAAQJgRT4BAAnAQAHAAQJgRT4BAAnAQAAAA==.',
['都不']='都不能缺德:BAABLgAECn8UAAICAAgJNRT0LAD6AQACAAgJNRT0LAD6AQAAAA==.',
['锤帝']='锤帝:BAAALgAECgIJAwAAAA==.',
['雄霸']='雄霸:BAAALgAECgcJDQAAAA==.',
['鬼哭']='鬼哭狼嚎:BAAALgAECgYJBgAAAA==.',
['魔道']='魔道尊者:BAAALgAFFAIJAgAAAA==.',
['鲜儿']='鲜儿:BAAALgAECgQJBgAAAA==.',
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
