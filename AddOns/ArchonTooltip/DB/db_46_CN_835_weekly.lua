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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','Unknown-Unknown','Warrior-Arms','Monk-Mistweaver','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','DemonHunter-Havoc','DemonHunter-Vengeance','DemonHunter-Devourer','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','DeathKnight-Unholy',}
local provider = {region='CN',realm='达克萨隆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Baby:BAAALgADCgcJBwAAAA==.',
Be='Bee:BAAALgADCgcJBwAAAA==.',
Cg='Cgmmi:BAAALgAFFAIJAgAAAA==.',
Li='Lillness:BAACLgAFFH8RAAIBAAUJkRm/BAC8AQABAAUJkRm/BAC8AQAuAAQKfyMAAwEACAnvIoYJAN8CAAEACAnvIoYJAN8CAAIABgnvEDkdAEUBAAAA.',
Ma='Manjusaka:BAAALgAECgYJBgAAAA==.',
Ro='Rocveadealan:BAAALgAECgcJCAABLgAFFAcJAwADAAAAAA==.',
Sh='Shashuo:BAAALgAECgYJBgAAAA==.',
Sn='Snakiehollic:BAAALgAECgcJBwAAAA==.',
Th='Thejuguguovo:BAAALgAECgYJBgAAAA==.',
Va='Valeera:BAAALgAECgIJAQAAAA==.',
Yo='Yohko:BAABLgAFFH8KAAIEAAQJmgn1AgAoAQAEAAQJmgn1AgAoAQAAAA==.Yoziko:BAAALgAECgYJCwAAAA==.',
Zz='Zzq:BAAALgAECgkJCQAAAA==.',
['一般']='一般路过原友:BAAALgAECgMJAwAAAA==.',
['不玩']='不玩奶萨:BAAALgAECgcJBwAAAA==.',
['专业']='专业送快递:BAAALgAECgEJAQAAAA==.',
['丶涟']='丶涟漪灬:BAAALgAECgYJBgAAAA==.',
['乌利']='乌利尔:BAAALgADCgIJAgAAAA==.',
['做咖']='做咖啡的:BAAALgAECgYJCgAAAA==.',
['元素']='元素灰烬:BAAALgAFFAQJAwAAAA==.',
['兔默']='兔默默:BAAALgAECgQJCAAAAA==.',
['六个']='六个六:BAAALgAECgEJAQAAAA==.',
['冰中']='冰中的火焰:BAAALgAECgcJDwAAAA==.',
['分劣']='分劣:BAAALgAECgIJAgAAAA==.',
['别杀']='别杀小熊:BAAALgADCgQJBAAAAA==.',
['剑击']='剑击长空:BAAALgAECgMJAwAAAA==.',
['十香']='十香:BAAALgAFFAIJAgAAAA==.',
['叫我']='叫我大呲花:BAAALgADCgIJAgAAAA==.',
['哈哈']='哈哈不咳了:BAAALgAECgYJDAAAAA==.',
['四系']='四系乃:BAAALgAECgUJBgAAAA==.',
['夏日']='夏日微寒:BAAALgADCgEJAQAAAA==.',
['夜小']='夜小柒:BAAALgAECgMJAwAAAA==.',
['夜晓']='夜晓柒:BAAALgAECgUJBQAAAA==.',
['奥客']='奥客:BAAALgADCgEJAQAAAA==.',
['好运']='好运爆彭女士:BAAALgAECgYJAgAAAA==.',
['宇宙']='宇宙的宇:BAAALgAECgMJAwAAAA==.',
['小丶']='小丶旋风:BAAALgAECgcJCgAAAA==.',
['巅峰']='巅峰滑水员:BAAALgAECgIJAgAAAA==.',
['我叫']='我叫小邪恶:BAAALgAECgMJBAAAAA==.',
['我既']='我既是众生:BAAALgAECgMJAgAAAA==.',
['我要']='我要上天丶:BAAALgAECgEJAQAAAA==.',
['散花']='散花礼弥:BAAALgAFFAIJAgAAAA==.',
['无魔']='无魔兽不兄弟:BAAALgAECgcJDwAAAA==.',
['暴走']='暴走的捡漏王:BAAALgAECgcJDAAAAA==.',
['月光']='月光舞夜:BAAALgAECgEJAQAAAA==.',
['月蚀']='月蚀星穹:BAAALgADCgQJBAAAAA==.',
['朵喵']='朵喵喵丶:BAAALgAFFAIJAgABLgAFFAIJBAADAAAAAA==.',
['梅超']='梅超风:BAAALgAECgYJBgAAAA==.',
['水中']='水中的火焰:BAAALgAECgYJBgAAAA==.',
['沈清']='沈清河:BAEBLgAFFH8MAAIFAAYJACUYAACNAgAFAAYJACUYAACNAgAAAA==.',
['涛升']='涛升云灭:BAAALgAECgUJCQAAAA==.',
['游戏']='游戏菜鸟:BAAALgAECgYJBgAAAA==.',
['火山']='火山灰:BAACLgAFFH8WAAMGAAcJgBa0AQBlAgAGAAcJfxW0AQBlAgAHAAIJFQ9BFgCtAAAuAAQKfx0AAwYACQl0H6cRAKkCAAYACQlqGKcRAKkCAAcABwkvHOIzAOABAAAA.',
['玄牝']='玄牝之门:BAAALgAECgEJAQAAAA==.',
['瑪琉']='瑪琉染柒:BAABLgAFFH8OAAMIAAUJkSRiAQC5AQAIAAUJkSRiAQC5AQAJAAEJyR3tEQBbAAABLgAFFAcJBwAIANgSAA==.',
['箭头']='箭头向:BAAALgAECgIJAgAAAA==.',
['红丶']='红丶枣:BAAALgAECgcJEAAAAA==.',
['红叶']='红叶:BAABLgAFFH8TAAQKAAUJohf1AgBdAQAKAAQJohf1AgBdAQALAAQJUQTzAQDQAAAMAAEJ6AQoKgA7AAAAAA==.',
['联盟']='联盟你等着:BAAALgADCgMJAwAAAA==.',
['胡豆']='胡豆豆:BAAALgADCgEJAQAAAA==.',
['花染']='花染丶墨:BAABLgAECn8lAAMNAAkJJRmFBAAAAgANAAkJJRmFBAAAAgAOAAEJAABJMAAeAAAAAA==.',
['芷兮']='芷兮丶:BAAALgAFFAIJBAAAAA==.',
['菩提']='菩提小德:BAAALgAECgMJBAAAAA==.',
['落地']='落地还钱:BAAALgAECgYJDQABLgAFFAUJEQAPAIwhAA==.',
['落霞']='落霞有个小慕:BAABLgAECn8VAAIQAAYJ7SCVdwCWAQAQAAYJ7SCVdwCWAQAAAA==.',
['虚空']='虚空大君:BAAALgADCgEJAQAAAA==.',
['蜂蜜']='蜂蜜柚子:BAAALgAECgQJBAAAAA==.',
['诺格']='诺格弗格:BAAALgAECgYJBgAAAA==.',
['赱馬']='赱馬覌畵:BAAALgAECgEJAQAAAA==.',
['转正']='转正小猫:BAAALgAECgMJAwAAAA==.',
['轻舟']='轻舟繁霜鬓:BAAALgAECgMJAwAAAA==.',
['逃之']='逃之夭夭:BAAALgADCgQJBAAAAA==.',
['都给']='都给我嘎:BAAALgAECgQJBAAAAA==.',
['酒馆']='酒馆战骑:BAAALgAECgQJBAAAAA==.',
['醒醒']='醒醒睡不醒丷:BAAALgADCgQJBAAAAA==.',
['阎魔']='阎魔奇迹:BAAALgADCgMJAwAAAA==.',
['阐释']='阐释者:BAABLgAECn8VAAINAAkJWBqyDQDGAgANAAkJWBqyDQDGAgAAAA==.',
['雷霆']='雷霆烧刚福瑞:BAAALgAECgkJCgAAAA==.',
['青灯']='青灯佛茶:BAAALgAECgIJAgAAAA==.',
['龙姨']='龙姨:BAAALgAECgMJAwAAAA==.',
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
