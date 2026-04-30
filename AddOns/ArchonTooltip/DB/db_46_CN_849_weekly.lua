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

local lookup = {'Priest-Shadow','Priest-Holy','Evoker-Augmentation','Evoker-Devastation','Paladin-Retribution','Priest-Discipline','Warlock-Demonology','Warlock-Destruction','Monk-Windwalker','Monk-Brewmaster','Shaman-Elemental','Warrior-Fury','Mage-Frost','Warrior-Protection','Monk-Mistweaver',}
local provider = {region='CN',realm='迪瑟洛克',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anon:BAABLgAFFH8MAAMBAAUJIhpRAwC3AQABAAUJIhpRAwC3AQACAAEJJgFMGAAxAAAAAA==.',
Bl='Bloobloody:BAAALgAECgcJCgAAAA==.',
Ha='Hannibal:BAAALgADCgEJAQAAAA==.',
Le='Lenaoxton:BAAALgAECgcJCgAAAA==.',
Me='Meltykiss:BAAALgADCgcJBwAAAA==.',
Mu='Mux:BAAALgAECgMJBQAAAA==.',
Ro='Roo:BAAALgADCgMJBAAAAA==.',
Ti='Tiramisu:BAAALgAECgcJEwAAAA==.',
['一叶']='一叶乄知秋:BAAALgADCgIJAgAAAA==.',
['一条']='一条龙:BAABLgAFFH8MAAMDAAQJRR+EBQBKAQADAAQJCheEBQBKAQAEAAEJqCHaBwBnAAAAAA==.',
['伊人']='伊人耳边话:BAABLgAFFH8GAAIFAAMJBhcEDQD9AAAFAAMJBhcEDQD9AAAAAA==.',
['伊泽']='伊泽:BAAALgAECgYJCAABLgAFFAYJBQAFAEkRAA==.',
['休闲']='休闲的大领主:BAAALgAECgEJAgAAAA==.',
['傻满']='傻满:BAAALgADCgEJAQAAAA==.',
['八蚱']='八蚱牛:BAAALgAECgUJCgAAAA==.',
['凸凸']='凸凸曼丶:BAAALgAECgkJDQAAAA==.',
['出月']='出月清风:BAAALgAFFAIJAgAAAA==.',
['刹隙']='刹隙:BAAALgADCgQJBAAAAA==.',
['卡洛']='卡洛北鳯:BAAALgAECgYJCAAAAA==.',
['口袋']='口袋里的口袋:BAAALgAECgIJAwAAAA==.口袋里的香蕉:BAAALgAECgEJAQAAAA==.',
['哈哩']='哈哩路呀:BAAALgAECgUJCQAAAA==.',
['啊留']='啊留沙:BAAALgAECgIJAwAAAA==.',
['天驱']='天驱若若:BAACLgAFFH8PAAMCAAQJIBLvAgAsAQACAAQJshHvAgAsAQAGAAMJygwxDgDpAAAuAAQKfxYABAYACQnfGJQKAI8CAAYACAnbGpQKAI8CAAIABQmmFrI+AD4BAAEABAkfDek7ABMBAAAA.',
['奶油']='奶油加酸奶:BAAALgADCgQJBAAAAA==.',
['妹控']='妹控:BAAALgADCgEJAQAAAA==.',
['完美']='完美熊猫:BAACLgAFFH8NAAICAAQJ6R0lAwBqAQACAAQJ6R0lAwBqAQAuAAQKfysAAgIACQkgIfsCADIDAAIACQkgIfsCADIDAAAA.',
['宫崎']='宫崎美橞:BAAALgAFFAEJAQAAAA==.',
['寒剑']='寒剑:BAAALgADCgIJAgAAAA==.',
['小仔']='小仔崽丶:BAAALgAECgQJAgAAAA==.',
['小小']='小小大口袋:BAAALgAECgMJBQAAAA==.',
['小巴']='小巴:BAAALgADCgUJBQAAAA==.',
['小样']='小样最德意:BAAALgAECgQJBAAAAA==.',
['小烧']='小烧麦:BAAALgAECgcJBwAAAA==.',
['小红']='小红手霸气丶:BAAALgAECgIJAgAAAA==.',
['少年']='少年游:BAACLgAFFH8TAAMHAAUJBxSPBgC4AQAHAAUJBxSPBgC4AQAIAAIJIQgRDgCcAAAuAAQKfyEAAgcACAk8IywQAPkCAAcACAk8IywQAPkCAAAA.',
['帕拉']='帕拉甲:BAAALgAFFAQJAgAAAA==.',
['平胸']='平胸而论:BAAALgAECgQJBAAAAA==.',
['张大']='张大猛:BAAALgAFFAIJAgAAAA==.',
['心有']='心有所悟:BAAALgAECgUJBwAAAA==.',
['心若']='心若琉璃:BAAALgADCgEJAQAAAA==.',
['我代']='我代表小的:BAAALgAECgEJAQAAAA==.',
['我按']='我按了呀:BAAALgAECgYJBgAAAA==.',
['扎布']='扎布瑞尔:BAABLgAFFH8IAAIJAAMJyBTEBADwAAAJAAMJyBTEBADwAAABLgAFFAUJBwAJAIAEAA==.',
['拔高']='拔高的骑士:BAAALgAECgYJBgAAAA==.',
['星染']='星染丶:BAAALgAECgcJDwAAAA==.',
['桃乐']='桃乐茜:BAAALgAFFAEJAQAAAA==.',
['橘子']='橘子丶酱:BAAALgAECgYJBgAAAA==.',
['橙真']='橙真:BAAALgAECgQJBAAAAA==.',
['沐泽']='沐泽:BAAALgADCgEJAQAAAA==.',
['没钱']='没钱花:BAAALgAECgYJCQAAAA==.',
['波特']='波特卡斯艾斯:BAAALgAFFAEJAQAAAA==.',
['活着']='活着的宅男:BAAALgAECgMJAwAAAA==.',
['浊白']='浊白:BAACLgAFFH8LAAMIAAQJhBqUAQDLAAAIAAIJ+CCUAQDLAAAHAAIJEBRaHgCuAAAuAAQKfyoAAwcACQlPIgsCAKsDAAcACQkmIgsCAKsDAAgABQmmHxANAPMBAAAA.',
['温柔']='温柔且细腻:BAAALgADCgEJAQAAAA==.',
['火箭']='火箭:BAABLgAFFH8FAAIKAAMJ6AvAFADQAAAKAAMJ6AvAFADQAAAAAA==.',
['熊大']='熊大王:BAAALgAFFAIJBAAAAA==.',
['爱不']='爱不够的妖精:BAAALgAECgcJBwABLgAFFAYJCgALAIsfAA==.',
['牛大']='牛大王:BAAALgAECgEJAQAAAA==.',
['牢三']='牢三:BAABLgAECn8YAAMIAAkJ3xw0BQCGAgAIAAcJbR40BQCGAgAHAAYJnByzSQDtAQAAAA==.',
['牢二']='牢二:BAAALgADCgEJAQAAAA==.',
['牢伍']='牢伍:BAAALgAECgUJBQAAAA==.',
['牢大']='牢大:BAAALgAECgYJDAAAAA==.',
['牢漆']='牢漆:BAAALgAECgYJCAAAAA==.',
['牢陆']='牢陆:BAABLgAECn8iAAMIAAkJ6R/xAQD6AgAIAAgJWSLxAQD6AgAHAAgJxw9wFgCAAQAAAA==.',
['电竞']='电竞死骑:BAAALgAFFAIJAwAAAA==.',
['看破']='看破灬红尘:BAAALgAECgEJAQAAAA==.',
['穿尘']='穿尘而去:BAAALgAECgEJAgAAAA==.',
['绝版']='绝版菜鸟:BAACLgAFFH8NAAIMAAQJlBZoBABAAQAMAAQJlBZoBABAAQAuAAQKfygAAgwACQlYIdUCAIYDAAwACQlYIdUCAIYDAAAA.',
['绯闻']='绯闻男友:BAAALgAECggJCwAAAA==.',
['羽燃']='羽燃:BAAALgAECgYJBgAAAA==.',
['老子']='老子姓马蚤:BAAALgAECgYJEQAAAA==.',
['老汉']='老汉会推大车:BAAALgAECgEJAQAAAA==.',
['肉蛋']='肉蛋冲击:BAABLgAECn8cAAINAAgJlR8BJgDaAgANAAgJlR8BJgDaAgAAAA==.',
['莉莉']='莉莉安妮:BAAALgAECgQJBAAAAA==.莉莉芙儿:BAAALgAECgQJBAAAAA==.',
['菱梦']='菱梦纱璃:BAAALgAECgYJBgAAAA==.',
['萨琪']='萨琪玛:BAAALgAECgMJBQAAAA==.',
['赵无']='赵无极:BAABLgAFFH8FAAIOAAMJ0A2XCADMAAAOAAMJ0A2XCADMAAAAAA==.',
['过来']='过来乖一点:BAAALgAECgEJAQAAAA==.',
['迪凯']='迪凯灬地狱吼:BAAALgAECgUJBQAAAA==.',
['追忆']='追忆之风:BAAALgAECgEJAgAAAA==.',
['邪能']='邪能机甲:BAAALgAECgEJAQAAAA==.',
['醉雨']='醉雨聆雪弱:BAABLgAFFH8NAAIPAAUJnRRqBACfAQAPAAUJnRRqBACfAQAAAA==.',
['野森']='野森火海:BAAALgAECgcJEQAAAA==.',
['阁楼']='阁楼:BAAALgADCgMJAwAAAA==.',
['阿库']='阿库娅丶:BAABLgAFFH8PAAIBAAQJCR4GBQCCAQABAAQJCR4GBQCCAQAAAA==.',
['阿撒']='阿撒托斯:BAAALgAECgMJAwAAAA==.',
['随风']='随风吟:BAAALgAFFAIJAgAAAA==.',
['青古']='青古甜子:BAAALgAECgQJBAAAAA==.',
['風晴']='風晴雪:BAAALgAECgYJBgAAAA==.',
['风中']='风中轻舞:BAAALgAECgYJEQAAAA==.',
['风过']='风过无伤:BAAALgAECgEJAQAAAA==.',
['飞扬']='飞扬的可乐:BAAALgAECgUJCQAAAA==.',
['魂飞']='魂飞胆丧尽快:BAAALgADCgUJBgAAAA==.',
['龍伈']='龍伈云:BAAALgADCgEJAQAAAA==.',
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
