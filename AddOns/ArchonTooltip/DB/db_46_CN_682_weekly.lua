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

local lookup = {'Evoker-Devastation','Evoker-Preservation','Warrior-Fury','Warrior-Arms','Warrior-Protection','Mage-Frost','Unknown-Unknown','Warlock-Demonology','DeathKnight-Unholy','DeathKnight-Blood','Monk-Brewmaster','Paladin-Retribution','Monk-Mistweaver','Monk-Windwalker','Priest-Discipline',}
local provider = {region='CN',realm='戈古纳斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ao='Aom:BAAALgAECgcJEAAAAA==.',
Ar='Aristocrat:BAAALgAECgUJBgAAAA==.',
Be='Berrerway:BAAALgAECgUJBQAAAA==.',
Ca='Canye:BAAALgAFFAIJAgAAAA==.',
Ch='Chuyb:BAAALgADCgYJDAAAAA==.',
Di='Dirge:BAAALgAECgcJDgABLgAFFAYJBgABAAkSAA==.Diveright:BAAALgAECgEJAQAAAA==.',
En='Enkiddu:BAAALgAECgcJCwAAAA==.',
Ho='Hol:BAAALgADCgEJAQAAAA==.',
Ma='Mancky:BAAALgAECgUJAwAAAA==.',
Na='Naturewindy:BAAALgAECgQJBQAAAA==.',
Om='Omniknight:BAAALgAECgEJAQAAAA==.',
Po='Pokopia:BAAALgAECgIJAgAAAA==.',
Ra='Ra:BAAALgAECgMJAwAAAA==.Raindrop:BAAALgAECgUJBAAAAA==.',
Ro='Root:BAAALgAECgQJBAAAAA==.',
Sh='Shadowdemon:BAAALgAECgEJAQAAAA==.Shadowpastor:BAAALgADCgIJAgAAAA==.Shimmer:BAAALgAFFAIJBAAAAA==.',
Ta='Tankdo:BAAALgAFFAEJAQAAAA==.',
Wi='Wickedmoon:BAAALgAECgUJBgAAAA==.',
Xe='Xenon:BAAALgADCgUJBQAAAA==.',
['一滴']='一滴都不剩了:BAAALgAECgYJBgAAAA==.',
['七夕']='七夕之夜:BAAALgAECggJCAAAAA==.',
['不明']='不明眞相群众:BAAALgAECgkJDwAAAA==.',
['不觉']='不觉:BAAALgAECgUJBQAAAA==.',
['乔恩']='乔恩雨:BAAALgAECgUJBgAAAA==.',
['九天']='九天空天母舰:BAABLgAFFH8IAAICAAMJyw4NBgDaAAACAAMJyw4NBgDaAAAAAA==.',
['似血']='似血残阳:BAAALgAECgEJAQAAAA==.',
['低吟']='低吟浅唱:BAAALgAFFAMJAwAAAA==.',
['你瞅']='你瞅瞅你:BAAALgAECgIJAgAAAA==.',
['修行']='修行:BAAALgADCgUJAgAAAA==.',
['偶系']='偶系丶阿冰哥:BAAALgAECgIJAgAAAA==.',
['傲雪']='傲雪天涯:BAAALgAECgcJCwAAAA==.',
['僧撞']='僧撞钟:BAAALgAECgUJBQAAAA==.',
['元华']='元华:BAAALgAECgIJAgAAAA==.',
['元簌']='元簌:BAAALgAECgQJBAAAAA==.',
['光之']='光之审判者:BAAALgAECgYJDQAAAA==.',
['兔丶']='兔丶尐术:BAAALgAFFAEJAQAAAA==.',
['兜兜']='兜兜豆豆:BAAALgAECgcJEgAAAA==.',
['冬神']='冬神龙人:BAAALgAECgcJBwAAAA==.',
['凪雲']='凪雲:BAAALgAFFAIJAgAAAA==.',
['初音']='初音未来:BAAALgAFFAEJAQAAAA==.',
['利维']='利维坦:BAABLgAFFH8HAAMDAAMJVBdJFwCsAAADAAIJwBdJFwCsAAAEAAEJfBa0CgBYAAABLgAFFAcJDQAFAM4ZAA==.',
['别闹']='别闹:BAAALgAECgUJCAAAAA==.',
['千乄']='千乄珏:BAAALgADCgQJBAAAAA==.',
['千早']='千早爱音:BAAALgAECgUJBgAAAA==.',
['南北']='南北:BAAALgADCgUJBQAAAA==.',
['吴同']='吴同学:BAAALgADCgEJAQAAAA==.',
['咕喵']='咕喵王:BAAALgAECgIJAgAAAA==.',
['咖碉']='咖碉勒贤:BAAALgAECgIJAgAAAA==.',
['喜柿']='喜柿多多:BAAALgAECgcJBwAAAA==.',
['圣光']='圣光芥末墩儿:BAAALgAECgEJAQAAAA==.',
['圣殿']='圣殿惩戒:BAAALgADCgMJAwAAAA==.',
['壹花']='壹花壹世界:BAAALgAECgcJCQAAAA==.',
['大不']='大不一样:BAAALgAECggJAQAAAA==.',
['大占']='大占卜师:BAACLgAFFH8JAAIGAAQJghU8BwBnAQAGAAQJghU8BwBnAQAuAAQKfxsAAgYACAnWF9+SAK0BAAYACAnWF9+SAK0BAAAA.',
['大懒']='大懒虫:BAAALgAECgcJBwAAAA==.',
['大火']='大火炮:BAAALgAECgEJAQAAAA==.',
['大笨']='大笨猪哟:BAAALgADCgIJAgAAAA==.',
['大良']='大良造:BAAALgADCgYJBQAAAA==.',
['天空']='天空之鸟:BAAALgAECgcJCwAAAA==.',
['奥力']='奥力给:BAAALgADCgYJBgAAAA==.',
['女王']='女王之刃:BAAALgADCgEJAQAAAA==.',
['好运']='好运乘风:BAAALgADCgMJAwAAAA==.',
['姜还']='姜还是老的辣:BAAALgAECgIJAgAAAA==.',
['孔宣']='孔宣:BAAALgAECgYJCAAAAA==.',
['宇智']='宇智波雪儿:BAAALgADCgkJCQAAAA==.',
['寂静']='寂静狩猎者:BAAALgAECgEJAQAAAA==.',
['寒门']='寒门彪哥:BAAALgAECgQJBAAAAA==.',
['小星']='小星球:BAAALgAECgQJBQAAAA==.',
['小源']='小源源:BAAALgADCgIJAQAAAA==.',
['小苏']='小苏打:BAAALgADCgQJBAAAAA==.',
['屮囗']='屮囗屮:BAAALgAECgMJAwAAAA==.',
['平平']='平平安安盼盼:BAAALgAECgEJAQAAAA==.',
['弑夜']='弑夜龙灵:BAAALgAECgkJCwABLgAFFAUJAQAHAAAAAA==.',
['彩色']='彩色的猫:BAAALgAECgcJDAAAAA==.',
['征战']='征战丶:BAAALgADCgUJBQAAAA==.',
['快乐']='快乐小电萨:BAAALgAECgIJAgAAAA==.',
['情窦']='情窦乱开:BAABLgAFFH8FAAIDAAQJSwjADgAZAQADAAQJSwjADgAZAQAAAA==.',
['懒羊']='懒羊之剑:BAAALgAFFAEJAgAAAA==.',
['戒烟']='戒烟专用:BAAALgADCgMJAgAAAA==.',
['斯莫']='斯莫德:BAAALgAECggJCAAAAA==.',
['无所']='无所畏惧:BAAALgADCgYJCwAAAA==.',
['曹达']='曹达华:BAAALgADCgUJBQAAAA==.',
['月影']='月影梵天:BAAALgAECgYJCQAAAA==.',
['有緣']='有緣無份:BAAALgADCgEJAQAAAA==.',
['李牙']='李牙牙:BAAALgAECgYJEAAAAA==.',
['枫红']='枫红叶:BAACLgAFFH8IAAIIAAMJ/gRnJwDeAAAIAAMJ/gRnJwDeAAAuAAQKfxcAAggACQksE8kuAFICAAgACQksE8kuAFICAAAA.',
['格尼']='格尼薇儿:BAAALgAECgYJCAABLgAFFAQJBAAHAAAAAA==.',
['楚夜']='楚夜白:BAAALgADCgMJAwABLgADCgYJDAAHAAAAAA==.',
['楼上']='楼上男宾三位:BAAALgAECggJAQAAAA==.',
['欧皇']='欧皇运气骑:BAAALgADCgcJBwAAAA==.',
['死于']='死于冲锋:BAAALgAECgEJAQAAAA==.',
['泽宝']='泽宝丶香香的:BAAALgADCgEJAQAAAA==.',
['流枫']='流枫霜:BAAALgAECgEJAQAAAA==.',
['浅唱']='浅唱灬悲伤:BAAALgAECgcJCwAAAA==.',
['浴血']='浴血:BAAALgAECgcJBwAAAA==.',
['海兽']='海兽之牙:BAAALgAECgYJCgAAAA==.',
['海盜']='海盜丶:BAAALgAECgYJAgAAAA==.',
['涟漪']='涟漪北往:BAAALgAECgQJBAAAAA==.',
['深吻']='深吻子眸:BAAALgAECgEJAgAAAA==.',
['清风']='清风不与你:BAAALgAECgEJAQAAAA==.清风朗月:BAABLgAFFH8FAAIIAAMJdA57IwD2AAAIAAMJdA57IwD2AAAAAA==.',
['湛蓝']='湛蓝的歌:BAAALgAECgQJBQAAAA==.',
['火丨']='火丨枪:BAAALgAECgMJAgAAAA==.',
['灬夏']='灬夏尐谦:BAAALgAECgQJBAAAAA==.',
['点丶']='点丶燃:BAAALgAECgIJAgAAAA==.',
['爱墨']='爱墨奥维斯:BAAALgAECgMJAwAAAA==.',
['爱织']='爱织雾的熊猫:BAAALgAECgcJCwAAAA==.',
['玉灵']='玉灵子:BAAALgADCgYJBwAAAA==.',
['琅琊']='琅琊玥:BAACLgAFFH8KAAIJAAQJ+RL3GABBAQAJAAQJ+RL3GABBAQAuAAQKfx0AAwkACAk2Hc1DACoCAAkABwlmIc1DACoCAAoAAQkUBBBIACgAAAAA.',
['甄可']='甄可乐:BAAALgAECgYJBgAAAA==.',
['畅快']='畅快的老龙虾:BAAALgAECgYJCgAAAA==.',
['白羽']='白羽千城:BAAALgAECgEJAQAAAA==.',
['白里']='白里光:BAAALgADCgUJCgAAAA==.',
['瞌睡']='瞌睡的喵嗯:BAAALgAECgcJCwABLgAECgkJFwAFAMAcAA==.',
['神圣']='神圣之力:BAAALgAECgcJDwAAAA==.',
['秃头']='秃头骑士:BAAALgAECgMJAwAAAA==.',
['秩序']='秩序始源:BAABLgAFFH8LAAILAAQJlhOyCgAyAQALAAQJlhOyCgAyAQABLgAFFAUJEQALAOwYAA==.',
['简丶']='简丶:BAAALgAECgcJCgAAAA==.',
['绿皮']='绿皮大西瓜:BAAALgAECgcJCwAAAA==.',
['艾娜']='艾娜丽莎:BAAALgADCgIJAgAAAA==.',
['荣耀']='荣耀星痕:BAAALgAECgcJCwAAAA==.',
['莫格']='莫格莱妳:BAAALgADCgMJAwAAAA==.',
['莱柠']='莱柠斯拽克:BAAALgAECgUJBQAAAA==.',
['蒹葭']='蒹葭白露:BAAALgAECgUJBgAAAA==.',
['蘭蔸']='蘭蔸篼:BAABLgAECn8XAAIMAAgJtR/xEwDzAgAMAAgJtR/xEwDzAgAAAA==.',
['詹姆']='詹姆斯丷哈登:BAAALgAECgIJAwAAAA==.',
['诛歌']='诛歌:BAAALgAFFAEJAQAAAA==.',
['贝鲁']='贝鲁特:BAAALgAECgYJCAAAAA==.',
['赱紅']='赱紅丶:BAAALgAECgcJCwAAAA==.',
['赱红']='赱红丶:BAAALgAECgYJCAAAAA==.',
['超级']='超级马塞克:BAAALgAECgUJBQAAAA==.',
['转赚']='转赚转:BAAALgAECgcJCwAAAA==.',
['轻声']='轻声语:BAACLgAFFH8HAAINAAMJCgasDQDHAAANAAMJCgasDQDHAAAuAAQKfxoAAw0ABwmBGiEVAB8CAA0ABwmBGiEVAB8CAA4AAQkdAweHACkAAAAA.',
['追忆']='追忆往昔:BAAALgADCgIJAgAAAA==.',
['遛迖']='遛迖:BAAALgADCgUJBQAAAA==.',
['重案']='重案组之虎:BAAALgADCgYJBgAAAA==.',
['锁沁']='锁沁:BAAALgAECgcJDAABLgAFFAUJCQAPAD8JAA==.',
['闪耀']='闪耀的猫:BAAALgAECgcJDQAAAA==.',
['阎魔']='阎魔:BAAALgAECgQJBAABLgAECgcJCwAHAAAAAA==.',
['陌人']='陌人陌路:BAAALgADCgcJCQAAAA==.',
['风剑']='风剑侠:BAAALgAFFAEJAwAAAA==.',
['骑车']='骑车去跳海:BAAALgAFFAIJAwAAAA==.',
['魅兰']='魅兰明月:BAAALgAECgEJAQAAAA==.',
['魅影']='魅影之风:BAAALgAECgcJCwAAAA==.',
['鲁迪']='鲁迪:BAAALgAECgQJBAAAAA==.',
['黑无']='黑无常:BAAALgADCgEJAQAAAA==.',
['龙之']='龙之电萨:BAAALgAFFAIJBAAAAA==.',
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
