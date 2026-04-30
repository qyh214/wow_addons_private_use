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

local lookup = {'Evoker-Augmentation','Hunter-Marksmanship','DemonHunter-Devourer','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Druid-Guardian',}
local provider = {region='CN',realm='阿卡玛',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Ashes:BAAALgAECgMJAwAAAA==.',
Bl='Blacklink:BAAALgAECgYJBgAAAA==.',
Ca='Catastropher:BAAALgAECgkJCQAAAA==.',
Fu='Fuwafuwa:BAAALgAECgEJAQAAAA==.',
Lc='Lcx:BAAALgAECgYJEQAAAA==.',
Ps='Psndmy:BAAALgADCgYJBgABLgAFFAQJCQABAAkPAA==.',
Sa='Samjun:BAAALgAECgYJCwAAAA==.',
Sh='Shadowfiend:BAAALgAECgYJEQAAAA==.',
['一骑']='一骑当千:BAAALgAECgEJAQAAAA==.',
['三尺']='三尺秋水尘:BAAALgAFFAIJAgAAAA==.',
['乐邦']='乐邦詹士:BAAALgAECgkJCQAAAA==.',
['云间']='云间月落:BAAALgAFFAIJAgAAAA==.',
['亲爱']='亲爱的亲爱的:BAAALgAECgkJDAAAAA==.',
['今晚']='今晚看星星:BAAALgAECgEJAQAAAA==.',
['傻馒']='傻馒小萨:BAAALgAECgcJBwAAAA==.',
['光与']='光与影之子:BAAALgADCgEJAQAAAA==.',
['双刀']='双刀灬流:BAAALgAECgYJCAAAAA==.',
['和光']='和光同尘:BAAALgAECgIJAgAAAA==.',
['啊小']='啊小叮当:BAABLgAECn8gAAICAAgJTCOPAAB+AgACAAgJTCOPAAB+AgAAAA==.',
['啰完']='啰完了吗:BAAALgAFFAIJAgAAAA==.',
['大水']='大水猫:BAAALgADCgcJBwAAAA==.',
['大漠']='大漠沙铷雪:BAAALgADCgUJBQAAAA==.',
['天堂']='天堂制造:BAAALgAFFAEJAQAAAA==.',
['天神']='天神丶使徒:BAAALgAECgIJAgAAAA==.',
['夯贔']='夯贔:BAAALgAECgEJAQAAAA==.',
['头好']='头好痒丶:BAAALgAECgEJAQAAAA==.',
['契约']='契约之殇:BAAALgAECgEJAQAAAA==.',
['娘子']='娘子:BAAALgAFFAQJBAAAAA==.',
['小丶']='小丶小妹:BAAALgADCgEJAgAAAA==.',
['小宇']='小宇宙人:BAAALgAECgYJAgAAAA==.',
['小花']='小花:BAAALgADCgYJBgAAAA==.',
['岁月']='岁月:BAAALgAECgYJCAAAAA==.',
['我就']='我就是条鱼:BAAALgADCgEJAQAAAA==.',
['战无']='战无不胜:BAAALgAECgEJAQAAAA==.',
['抬头']='抬头看月又沉:BAAALgAECgEJAgAAAA==.',
['挥棒']='挥棒断情丝:BAAALgADCgEJAQAAAA==.',
['方块']='方块圈:BAAALgAECgYJDAAAAA==.',
['日照']='日照砍王:BAAALgAECgcJAQAAAA==.',
['暗夜']='暗夜之孙:BAAALgAECgYJCgAAAA==.',
['暗香']='暗香疏影:BAAALgAECgMJBAAAAA==.',
['月神']='月神之光:BAAALgAECgEJAQAAAA==.',
['月隐']='月隐:BAAALgAECgkJCQAAAA==.',
['朗多']='朗多雷:BAABLgAFFH8FAAIDAAUJNxb0BQBZAQADAAUJNxb0BQBZAQAAAA==.',
['橙多']='橙多多:BAAALgADCgIJAgAAAA==.',
['欧尔']='欧尔莉亚:BAAALgAECgUJDAAAAA==.',
['沐雨']='沐雨临风:BAAALgAECgMJAwAAAA==.',
['流光']='流光映影:BAAALgADCgYJBgAAAA==.',
['浅语']='浅语石兰:BAAALgAECgUJBgAAAA==.',
['淡淡']='淡淡的光明丶:BAAALgAECgYJBAAAAA==.',
['烈焰']='烈焰凤凰雨:BAAALgADCgEJAQAAAA==.',
['热月']='热月:BAAALgADCgYJBgAAAA==.',
['狂风']='狂风吹我心:BAAALgAFFAIJAwAAAA==.',
['王者']='王者尤文:BAAALgAECgQJBAAAAA==.',
['真是']='真是治疗啊:BAAALgAECgYJBgAAAA==.',
['神锅']='神锅锅:BAAALgADCgQJBAAAAA==.',
['素色']='素色的猫:BAAALgAECgEJAQAAAA==.',
['腼腼']='腼腼雪:BAAALgAECgYJBgAAAA==.',
['萝卜']='萝卜烧肥肠:BAABLgAECn8gAAIEAAgJrxknBwADAgAEAAgJrxknBwADAgAAAA==.',
['萨骑']='萨骑马:BAAALgAECgEJAQAAAA==.',
['蓝领']='蓝领球员:BAABLgAFFH8FAAIFAAMJPA8jEQDlAAAFAAMJPA8jEQDlAAAAAA==.',
['谋曹']='谋曹丕:BAAALgAECgkJEgAAAA==.',
['赵樱']='赵樱空:BAAALgAECgcJEwAAAA==.',
['达达']='达达利亚:BAAALgAECgYJCQAAAA==.',
['醉酒']='醉酒死骑:BAAALgADCgQJBAAAAA==.',
['金枝']='金枝玉叶:BAAALgAECgQJBAAAAA==.',
['金色']='金色閃光:BAAALgAECgMJAwAAAA==.',
['锤猪']='锤猪剑客:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔丽斯:BAACLgAFFH8HAAIGAAMJVxPFJwD5AAAGAAMJVxPFJwD5AAAuAAQKfxkAAgYABwmSHBszAGoCAAYABwmSHBszAGoCAAAA.',
['阿库']='阿库娅的微笑:BAAALgADCgYJBgAAAA==.',
['阿法']='阿法牛:BAAALgAECgQJCAAAAA==.',
['阿珥']='阿珥忒妮斯:BAAALgAECgcJDAAAAA==.',
['阿芙']='阿芙珞蒂忒:BAAALgAECgcJCAAAAA==.',
['阿蒂']='阿蒂珥安娜:BAAALgAECgQJBQAAAA==.',
['阿贾']='阿贾克斯:BAAALgAECgMJAwAAAA==.',
['雾漫']='雾漫山横:BAAALgAECgQJBAAAAA==.',
['青元']='青元玄歌:BAABLgAECn8YAAIGAAcJlh27DADUAQAGAAcJlh27DADUAQAAAA==.',
['青花']='青花:BAAALgAECgEJAQAAAA==.',
['风吹']='风吹酒醒:BAAALgAFFAEJAwAAAA==.',
['风见']='风见幽香:BAABLgAECn8XAAIDAAkJIBaoPQD9AQADAAkJIBaoPQD9AQAAAA==.',
['风起']='风起月明:BAAALgAFFAIJAwABLgAFFAgJGAAHAFobAA==.',
['飒沓']='飒沓照山河:BAAALgADCgEJAQAAAA==.',
['饿有']='饿有饿豹:BAAALgAECgIJAgAAAA==.',
['鲸神']='鲸神:BAABLgAFFH8JAAIBAAQJCQ/EDAAzAQABAAQJCQ/EDAAzAQAAAA==.',
['麦香']='麦香猪柳蛋堡:BAAALgADCgMJAwAAAA==.',
['黄初']='黄初八年雨:BAAALgAECgEJAQAAAA==.',
['黑白']='黑白蕾丝:BAAALgAECgQJBAAAAA==.',
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
