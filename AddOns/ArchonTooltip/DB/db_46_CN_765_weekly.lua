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

local lookup = {'Druid-Restoration','Paladin-Retribution','Warrior-Protection','Warrior-Fury','Rogue-Subtlety','Priest-Holy','Shaman-Restoration','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship',}
local provider = {region='CN',realm='瓦丝琪',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ap='Appo:BAAALgAECgYJBQAAAA==.',
Dh='Dhh:BAAALgAECgcJDQAAAA==.',
Ma='Max:BAABLgAFFH8HAAIBAAIJWiNuEwDNAAABAAIJWiNuEwDNAAAAAA==.',
['丨眼']='丨眼眸丨:BAABLgAFFH8GAAICAAQJriLEBQCTAQACAAQJriLEBQCTAQAAAA==.',
['云清']='云清:BAAALgADCgEJAQAAAA==.',
['伊人']='伊人猎狩:BAAALgAECgEJAQAAAA==.',
['你老']='你老味啊:BAAALgAECgUJCQAAAA==.',
['冰霜']='冰霜女巫:BAAALgAECgEJAQAAAA==.',
['刘海']='刘海柱:BAAALgAECgEJAQAAAA==.',
['劈头']='劈头士帅牛:BAAALgAECgUJBQAAAA==.',
['南方']='南方老土豆:BAAALgAFFAEJAQAAAA==.',
['南村']='南村熊孩子:BAAALgAECgYJDwAAAA==.',
['变态']='变态幼龙控:BAAALgAECgcJBwAAAA==.',
['地狱']='地狱死骑:BAAALgAECgMJAwAAAA==.',
['复仇']='复仇女神:BAAALgADCgMJAwAAAA==.',
['大宝']='大宝斧:BAAALgADCgEJAQAAAA==.大宝箭:BAAALgAECgYJDQAAAA==.',
['奥拉']='奥拉:BAAALgAECgEJAQAAAA==.',
['奥莱']='奥莱丽娅:BAAALgADCgMJAwAAAA==.',
['孤丶']='孤丶城:BAACLgAFFH8HAAIDAAMJlwZtDgBfAAADAAMJlwZtDgBfAAAuAAQKfxsAAwMACAn5DVMZAIcBAAMACAn5DVMZAIcBAAQAAQl9BeqvACsAAAAA.',
['小珍']='小珍珠:BAAALgAECgMJAgAAAA==.',
['小艺']='小艺:BAAALgAECgcJCgAAAA==.',
['开祷']='开祷:BAAALgADCgMJAwAAAA==.',
['张三']='张三秒:BAAALgAFFAEJAQAAAA==.',
['弦歌']='弦歌枕月:BAAALgADCgUJBQAAAA==.',
['德吧']='德吧嘚:BAAALgADCgMJAwAAAA==.',
['怀念']='怀念灬那风:BAAALgADCgEJAQAAAA==.',
['怪骑']='怪骑骑:BAAALgADCgcJCAAAAA==.',
['怪龍']='怪龍龍:BAAALgAECgYJEAAAAA==.',
['放开']='放开那根竹子:BAAALgAECgEJAQAAAA==.',
['放弃']='放弃治疗速死:BAAALgADCgUJBQAAAA==.',
['斧刃']='斧刃:BAAALgAECgIJAgAAAA==.',
['无敌']='无敌小母牛:BAAALgAECgIJAgAAAA==.',
['无粒']='无粒丹:BAAALgAFFAEJAQAAAA==.',
['明玥']='明玥:BAAALgAECgQJBAAAAA==.',
['晦暗']='晦暗的霍霍:BAAALgAECgYJDAAAAA==.',
['月落']='月落银河:BAAALgAECgEJAgAAAA==.',
['机智']='机智的二头:BAAALgAECgcJCAAAAA==.',
['柒丨']='柒丨號:BAAALgAFFAIJAwAAAA==.',
['氵昆']='氵昆血儿灬:BAAALgAECgYJCgAAAA==.',
['火山']='火山洗头师:BAAALgADCgcJBwAAAA==.',
['烈焰']='烈焰丨焚情:BAAALgAECgcJCAAAAA==.',
['爱情']='爱情限时批:BAAALgAECgUJBgAAAA==.',
['狼爵']='狼爵:BAAALgAFFAIJAgAAAA==.',
['王者']='王者的叹息:BAABLgAFFH8IAAIDAAQJCA/fBQANAQADAAQJCA/fBQANAQAAAA==.',
['珍丶']='珍丶珠:BAAALgAECgEJAgAAAA==.',
['珏比']='珏比珏比珏:BAAALgAECgYJBgAAAA==.',
['碱水']='碱水丨魔芋爽:BAAALgAECgQJBwAAAA==.',
['礼之']='礼之冻霜:BAAALgAECgUJBQAAAA==.',
['祐天']='祐天寺若麦:BAACLgAFFH8SAAIFAAUJOB4jAQCJAQAFAAUJOB4jAQCJAQAuAAQKfx4AAgUACAk4IbUHABUDAAUACAk4IbUHABUDAAAA.',
['神秘']='神秘斗篷人:BAAALgADCgMJAwAAAA==.',
['纯洁']='纯洁小奶糕:BAAALgAECgEJAQAAAA==.',
['美少']='美少女丶壮士:BAAALgAECgEJAQAAAA==.',
['老李']='老李七号:BAABLgAFFH8GAAIGAAQJUA6NBADAAAAGAAQJUA6NBADAAAAAAA==.老李五号:BAAALgAFFAIJAgAAAA==.老李六号:BAABLgAFFH8FAAIHAAMJKxAJEADoAAAHAAMJKxAJEADoAAAAAA==.',
['肉山']='肉山小馍馍:BAAALgADCgUJBQAAAA==.',
['自由']='自由:BAAALgAFFAIJAgAAAA==.',
['艾微']='艾微恩丶上校:BAAALgAECgcJDQAAAA==.艾微恩丶大校:BAAALgAECgYJCAABLgAECgcJDQAIAAAAAA==.',
['芸阿']='芸阿娜:BAAALgAECgYJBwAAAA==.',
['草莓']='草莓冰沙:BAAALgAECgUJBQAAAA==.',
['莱丶']='莱丶爵:BAAALgAECgUJBQAAAA==.',
['蔚蓝']='蔚蓝决斗:BAACLgAFFH8JAAMJAAMJkiBEBwANAQAKAAMJkiCqEQAeAQAJAAMJnRNEBwANAQAuAAQKfx4AAwoACAkMIaENANYCAAoACAkQH6ENANYCAAkAAgkPErkwAIkAAAAA.',
['血泪']='血泪悲伤:BAAALgAECgUJBQAAAA==.',
['钢铁']='钢铁爆牙:BAAALgAECgQJBwAAAA==.',
['隰有']='隰有游龙:BAAALgAFFAMJBAAAAA==.',
['霜冻']='霜冻之礼:BAAALgAFFAEJAQAAAA==.',
['顶唔']='顶唔住了:BAAALgAECgMJAwAAAA==.',
['风暖']='风暖:BAAALgADCgEJAQAAAA==.',
['鲁特']='鲁特尼希:BAAALgAECgYJBgAAAA==.',
['鲸落']='鲸落:BAAALgAECgUJBwAAAA==.',
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
