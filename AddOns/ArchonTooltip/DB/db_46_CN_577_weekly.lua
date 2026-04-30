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

local lookup = {'Monk-Windwalker','Monk-Mistweaver','DemonHunter-Vengeance','Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Rogue-Subtlety','Warrior-Fury','Warrior-Arms','Unknown-Unknown','Warlock-Demonology','Priest-Holy','Evoker-Preservation','Evoker-Augmentation','Mage-Frost','Druid-Guardian','Evoker-Devastation',}
local provider = {region='CN',realm='克苏恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alencon:BAABLgAFFH8HAAMBAAIJfSDmBAC4AAABAAIJfSDmBAC4AAACAAEJzhjBFABZAAAAAA==.',
An='Antimage:BAAALgAECgkJDAAAAA==.',
Ca='Canyon:BAAALgAECgkJDwAAAA==.',
Ch='Chovy:BAAALgAECgkJEgAAAA==.',
De='Deralanmao:BAACLgAFFH8GAAIDAAMJcxqjAQDqAAADAAMJcxqjAQDqAAAuAAQKfxwAAgMABwkwIy4DAKwCAAMABwkwIy4DAKwCAAAA.',
Du='Duckingz:BAAALgAECgIJAgAAAA==.',
Ev='Everloverll:BAAALgAFFAEJAQAAAA==.Evian:BAAALgAECgUJBQAAAA==.',
Li='Liyk:BAAALgAECgEJAQAAAA==.',
Ls='Lsotvoep:BAAALgAECgQJBgAAAA==.',
Ma='Machinegun:BAAALgAECgUJBwAAAA==.',
Sa='Sakuro:BAAALgADCgYJBgAAAA==.',
Se='Semon:BAAALgAECgEJAgAAAA==.',
Ta='Tavins:BAAALgAECgkJBQAAAA==.',
['一槍']='一槍送终:BAAALgADCgcJCAAAAA==.',
['一骑']='一骑当千丶:BAAALgADCgcJBwAAAA==.',
['七界']='七界云天河:BAAALgAECgQJBQAAAA==.',
['三三']='三三:BAAALgAFFAIJAwAAAA==.',
['三气']='三气归来:BAAALgAFFAMJAwAAAA==.',
['上古']='上古法神:BAAALgAECgYJCAAAAA==.上古领主:BAAALgAECgIJAwAAAA==.',
['不在']='不在狀態:BAAALgAECgcJDgAAAA==.',
['临时']='临时演员:BAAALgAECgkJBgAAAA==.',
['九州']='九州天空:BAAALgAECgQJBAAAAA==.',
['云治']='云治:BAAALgAECgcJBwAAAA==.',
['五官']='五官人:BAAALgAECgEJAQAAAA==.',
['你先']='你先跑我殿后:BAABLgAFFH8GAAIEAAMJrhMwGADsAAAEAAMJrhMwGADsAAAAAA==.',
['倾世']='倾世:BAAALgAECgEJAgAAAA==.',
['僧僧']='僧僧不息:BAAALgAECgkJBwAAAA==.',
['光屁']='光屁灬股灬雷:BAABLgAECn8UAAMFAAcJWQu1RwBjAQAFAAcJWQu1RwBjAQAGAAIJVgJEhgAzAAAAAA==.',
['六翼']='六翼天使:BAAALgADCgIJAgAAAA==.',
['冒饭']='冒饭了:BAAALgADCgEJAQAAAA==.',
['冰兮']='冰兮兮:BAAALgAECgUJCQAAAA==.',
['冷灬']='冷灬瞳:BAAALgADCgIJAgAAAA==.',
['凯尔']='凯尔斯云:BAACLgAFFH8FAAIHAAMJFgzqDAD6AAAHAAMJFgzqDAD6AAAuAAQKfxoAAgcABwlBGj4vAPQBAAcABwlBGj4vAPQBAAAA.',
['初音']='初音未来:BAAALgAECgQJBAAAAA==.',
['动次']='动次打次:BAAALgAFFAEJAgAAAA==.',
['可爱']='可爱的三姨太:BAAALgAECggJCQAAAA==.',
['史迪']='史迪崽:BAAALgADCgQJBwAAAA==.',
['咸燏']='咸燏:BAAALgAFFAEJAgAAAA==.',
['哼大']='哼大粮油:BAAALgAECgQJBAAAAA==.',
['啾啾']='啾啾的小星星:BAAALgAECgMJAwAAAA==.',
['嘬了']='嘬了:BAAALgAECgMJAwAAAA==.',
['壹丶']='壹丶:BAABLgAFFH8JAAIIAAUJ7A5nBACrAQAIAAUJ7A5nBACrAQAAAA==.',
['多咪']='多咪西点心:BAAALgADCgcJBwAAAA==.',
['大啊']='大啊啊象:BAAALgAECgUJBQAAAA==.',
['大官']='大官人:BAAALgAFFAIJBAAAAA==.',
['大德']='大德大威天龙:BAAALgADCgUJBQAAAA==.',
['奥法']='奥法塑能:BAAALgAECgkJCQAAAA==.',
['奥莉']='奥莉安娜乄:BAAALgADCgYJBgAAAA==.',
['奶油']='奶油布丁:BAAALgAECgcJDAAAAA==.',
['孤海']='孤海阿豪:BAAALgADCgEJAQAAAA==.',
['孤独']='孤独丶旅行者:BAAALgADCgYJBgAAAA==.',
['守夜']='守夜人的誓言:BAAALgAECgkJCAAAAA==.',
['宝宝']='宝宝别闹:BAAALgAFFAMJAwAAAA==.',
['富豪']='富豪:BAAALgAECgMJBgAAAA==.',
['寒月']='寒月:BAAALgADCgUJBQAAAA==.寒月义:BAAALgADCgEJAQAAAA==.',
['小恼']='小恼斧:BAABLgAFFH8FAAIBAAMJWQfWDgCDAAABAAMJWQfWDgCDAAAAAA==.',
['小洒']='小洒:BAAALgAECgYJBwAAAA==.',
['小烂']='小烂:BAAALgADCgEJAQAAAA==.',
['小给']='小给教授:BAAALgAECgMJAwAAAA==.',
['尘成']='尘成晨:BAACLgAFFH8QAAMJAAQJmR0GBQARAQAJAAMJ9BsGBQARAQAKAAEJiCJvBABrAAAuAAQKfyEAAwoACAmHIv4IACACAAkABwn/GxQaAHsCAAoABgkhH/4IACACAAAA.',
['岁月']='岁月无恨:BAABLgAECn8UAAIHAAYJiRE9TACEAQAHAAYJiRE9TACEAQAAAA==.',
['帅气']='帅气断魂:BAAALgAECgEJAQAAAA==.',
['康娜']='康娜:BAAALgADCgIJAgAAAA==.',
['开飞']='开飞机的库奇:BAAALgAECgYJCwAAAA==.',
['忧郁']='忧郁小猫咪:BAAALgAECgcJEAAAAA==.',
['性感']='性感的水桶腰:BAAALgADCgMJAwAAAA==.',
['悠哉']='悠哉:BAAALgAECgMJAwAAAA==.',
['我吃']='我吃饱了:BAABLgAFFH8IAAIBAAMJShbjBwD4AAABAAMJShbjBwD4AAABLgAFFAIJBAALAAAAAA==.',
['抚菊']='抚菊東篱下:BAAALgAECgkJEAABLgAFFAcJGgAIAJkjAA==.',
['拉面']='拉面:BAAALgAECgMJAwAAAA==.',
['支格']='支格阿鲁:BAAALgAECgEJAQAAAA==.',
['斯斯']='斯斯丶:BAAALgAFFAIJBAAAAA==.',
['无骑']='无骑不有:BAAALgAECgEJAQAAAA==.',
['日记']='日记:BAAALgAECgYJDwAAAA==.',
['时光']='时光中漫步:BAAALgAECgYJCwAAAA==.',
['星垂']='星垂野赴山海:BAABLgAECn8XAAIMAAUJ1SJGRAD/AQAMAAUJ1SJGRAD/AQABLgAFFAIJBAALAAAAAA==.',
['星痕']='星痕:BAAALgAECgEJAQABLgAFFAEJAQALAAAAAA==.',
['暗之']='暗之刀线:BAAALgAECgYJEgAAAA==.',
['暗天']='暗天者:BAAALgAECgcJDAAAAA==.',
['暴走']='暴走啲胖子:BAAALgAECgcJCAAAAA==.暴走滴胖子:BAAALgAECgcJCwAAAA==.暴走荻胖子:BAAALgAFFAEJAQAAAA==.暴走锝胖子:BAAALgAECgYJCQAAAA==.',
['木鱼']='木鱼:BAAALgAECgYJBgAAAA==.',
['棍哥']='棍哥:BAAALgAECgQJBAAAAA==.',
['樱空']='樱空桃:BAAALgAFFAIJAgABLgAFFAMJBQANAHgPAA==.',
['水之']='水之残雪:BAAALgAECgQJBgAAAA==.',
['水月']='水月灬冰晶:BAAALgAECgEJAQAAAA==.',
['流星']='流星会唱歌:BAAALgADCgEJAgAAAA==.',
['溜溜']='溜溜糖:BAAALgAECgkJCQAAAA==.',
['灬熊']='灬熊宝:BAABLgAFFH8JAAIIAAUJlwqtBACiAQAIAAUJlwqtBACiAQAAAA==.',
['灵狐']='灵狐:BAAALgAECgUJBQAAAA==.',
['烟烟']='烟烟:BAABLgAFFH8HAAIIAAUJoRcrAwDKAQAIAAUJoRcrAwDKAQAAAA==.',
['熊宝']='熊宝:BAABLgAFFH8OAAIIAAYJpxShAAAsAgAIAAYJpxShAAAsAgAAAA==.熊宝丶:BAABLgAFFH8HAAIIAAUJhw8WBAC0AQAIAAUJhw8WBAC0AQAAAA==.',
['爱因']='爱因斯坦:BAACLgAFFH8FAAIOAAMJYCPgEAC1AAAOAAMJYCPgEAC1AAAuAAQKfxQAAw4ABwmdG2ECAPIBAA4ABwmdG2ECAPIBAA8ABQk6B4xCANgAAAAA.',
['猫妞']='猫妞:BAAALgAECgEJAQAAAA==.',
['玩具']='玩具茄子:BAAALgAECgcJBwAAAA==.',
['瑟提']='瑟提:BAAALgAECgcJBQAAAA==.',
['疾风']='疾风铃音:BAAALgAECgEJAQAAAA==.',
['白州']='白州:BAAALgAECgcJBwAAAA==.',
['白日']='白日烟火:BAAALgAFFAMJAwAAAA==.',
['盖畜']='盖畜:BAABLgAFFH8JAAIIAAUJhRK5AwC+AQAIAAUJhRK5AwC+AQAAAA==.',
['看我']='看我哼哼哈嘿:BAAALgAECgMJBgAAAA==.',
['神拳']='神拳无敌:BAAALgAECgMJAwAAAA==.',
['绝弑']='绝弑妖孽:BAAALgADCgIJAgAAAA==.',
['肝帝']='肝帝:BAAALgAECgUJBQAAAA==.',
['胡猎']='胡猎猎:BAAALgAECgkJCgAAAA==.',
['苟玲']='苟玲子捌毛:BAAALgAFFAEJAQAAAA==.苟玲子肆毛:BAAALgAECgUJBgAAAA==.',
['萌月']='萌月:BAAALgAECgIJAgAAAA==.',
['行星']='行星丶小奶盖:BAAALgAECgEJAQAAAA==.',
['衣奎']='衣奎斯布林:BAEALgAECgYJBgABLgAFFAQJBgAQALASAA==.',
['谎言']='谎言之躯:BAAALgAECgUJBQAAAA==.',
['豆子']='豆子威:BAABLgAFFH8GAAIBAAMJWhNcCADxAAABAAMJWhNcCADxAAAAAA==.',
['豚豚']='豚豚能吃爱睡:BAAALgAECgEJAQAAAA==.',
['贰丶']='贰丶:BAABLgAFFH8LAAIIAAUJmhK9AwC+AQAIAAUJmhK9AwC+AQAAAA==.',
['贼出']='贼出没注意:BAAALgAECgQJAgAAAA==.',
['赤帝']='赤帝苍星:BAABLgAFFH8FAAIQAAUJ9QP0EgCAAQAQAAUJ9QP0EgCAAQAAAA==.',
['起名']='起名字好难:BAABLgAFFH8KAAIIAAQJTQvICQBUAQAIAAQJTQvICQBUAQAAAA==.',
['跳起']='跳起来打脸:BAABLgAFFH8HAAIQAAMJJxuKOgC2AAAQAAMJJxuKOgC2AAAAAA==.',
['逗哥']='逗哥来啦:BAAALgAECgEJAQAAAA==.',
['邪神']='邪神小脑:BAAALgAECgYJCQAAAA==.',
['野德']='野德新之助:BAAALgADCgQJAgAAAA==.',
['铃木']='铃木瓶瓶奶:BAAALgAECggJCAABLgAFFAQJBQARAGsRAA==.',
['雪碧']='雪碧丶透心凉:BAAALgAECgYJCQAAAA==.',
['雪雪']='雪雪中大奖:BAAALgADCgYJBgAAAA==.',
['零六']='零六捌:BAAALgAECgEJAQAAAA==.',
['雾燥']='雾燥:BAACLgAFFH8OAAMPAAQJWyH/DQAgAQAPAAMJrB//DQAgAQASAAIJQB0wBQDKAAAuAAQKfx0AAxIACAnPIqUHAHACABIABglFJKUHAHACAA8ABQndGhclAJQBAAAA.',
['青鸾']='青鸾慕雪:BAAALgADCgEJAQAAAA==.',
['风停']='风停万物各安:BAAALgAFFAIJBAAAAA==.',
['香香']='香香的你:BAAALgAECgcJBwAAAA==.',
['馨莫']='馨莫:BAAALgADCgYJBgAAAA==.',
['魂之']='魂之哀伤:BAAALgAECgEJAgAAAA==.',
['魂殇']='魂殇痕:BAAALgAFFAMJAwAAAA==.',
['魔王']='魔王白:BAAALgAECgQJBgAAAA==.',
['麦辣']='麦辣鸡翅:BAAALgADCgcJBwAAAA==.',
['黑暗']='黑暗盛宴:BAAALgAECgIJAgAAAA==.',
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
