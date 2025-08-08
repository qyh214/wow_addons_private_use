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
 local lookup = {'Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','Shaman-Restoration','Shaman-Enhancement','Monk-Mistweaver','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Priest-Holy','DeathKnight-Blood','Hunter-Survival',}; local provider = {region='CN',realm='格鲁尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Da='Darkrose:BAAAKgAFFAIIBAAAAA==.',Df='Dfaeetgd:BAAAKgAFFAQIBAAAAA==.',Ki='Killerblood:BAAAKgAECgQIBAAAAA==.',Ma='Magician:BAAAKgADCggIEAAAAA==.',Pl='Playertjsrcs:BAAAKgAECgIIBAAAAA==.',Tn='Tndp:BAAAKgAECgIIAgAAAA==.',['丶枕']='丶枕边书:BAAAKgADCggIEQAAAA==.',['人帅']='人帅气质佳:BAAAKgAECgIIAgAAAA==.',['别丶']='别丶天:BAAAKgADCggIDwAAAA==.',['叭咪']='叭咪:BAAAKgAFFAIIAgAAAA==.',['圣光']='圣光之殇:BAABKgAECn8fAAIBAAgIVRIMcQB0AQABAAgIVRIMcQB0AQAAAA==.',['夕阳']='夕阳一法王:BAAAKgAECgMIAwAAAA==.夕阳一龖龖:BAAAKgADCgEIAQAAAA==.',['大粘']='大粘鱼:BAAAKgAECgUIBgAAAA==.',['女大']='女大三抱鑫砖:BAAAKgAECgMIAwAAAA==.',['好色']='好色加菲猫:BAABKgAECn8XAAMCAAgIixS1PAC+AQACAAgIixS1PAC+AQADAAEIwwlkNwAoAAAAAA==.',['小情']='小情人:BAAAKgAECgQIBQAAAA==.',['小龍']='小龍人:BAAAKgADCggICgAAAA==.',['希思']='希思黎:BAAAKgAECgcICAAAAA==.',['怀念']='怀念:BAAAKgADCggIDAAAAA==.',['找乐']='找乐天使:BAAAKgADCggICAAAAA==.',['无常']='无常道法:BAAAKgAECggICAAAAA==.',['星星']='星星尼格星星:BAAAKgAECggIEQAAAA==.',['晓萌']='晓萌熊:BAAAKgADCgQIBQAAAA==.',['木子']='木子徽:BAAAKgADCgQIBAAAAA==.',['杀戮']='杀戮黑牛:BAAAKgAECgEIAQAAAA==.',['杜康']='杜康:BAAAKgADCgEIAgAAAA==.',['永吥']='永吥为奴:BAAAKgAECgUIBQAAAA==.',['沃玖']='沃玖拾杀壁:BAAAKgAECgUIBQAAAA==.',['泉此']='泉此方丶:BAACKgAFFH8WAAMEAAYIwR7EEAD4AAAEAAYIwR7EEAD4AAAFAAMI0g8WDADuAAAqAAQKfyQAAwUACAhuI9sHAK4CAAUACAhuI9sHAK4CAAQABghYDhGFALkAAAEqAAUUCAgaAAIA8BsA.',['派拉']='派拉蒙的小猪:BAACKgAFFH8kAAIGAAgIewfPFAAAAQAGAAgIewfPFAAAAQAqAAQKfx8AAgYACAilGHkiAN4BAAYACAilGHkiAN4BAAAA.',['温暖']='温暖人心:BAAAKgAECgUIBQAAAA==.',['湮斯']='湮斯特灭灭:BAAAKgAFFAQIBAABKgAFFAgIGgACAPAbAA==.',['灬饼']='灬饼干灬:BAACKgAFFH8FAAIHAAMITgmWQQCZAAAHAAMITgmWQQCZAAAqAAQKfxwAAgcACAgSFvxGAOABAAcACAgSFvxGAOABAAAA.',['猎乂']='猎乂影:BAACKgAFFH8FAAIHAAIIdROKSwB5AAAHAAIIdROKSwB5AAAqAAQKfxoAAwcACAjxGkdsAG4BAAcABghyGUdsAG4BAAgAAwhIHxpNAOgAAAAA.',['甜蜜']='甜蜜的哀伤:BAABKgAFFH8OAAMJAAgI7x5LAQBnAgAJAAgItR1LAQBnAgAKAAYIRSHNBADaAQAAAA==.',['秋晨']='秋晨:BAAAKgADCggICAAAAA==.',['糖葫']='糖葫芦:BAAAKgAECgQIBAAAAA==.',['紫霞']='紫霞:BAAAKgADCggIEwAAAA==.',['红发']='红发一香克斯:BAAAKgADCgYIBgAAAA==.',['绝版']='绝版小春:BAAAKgAECgEIAQAAAA==.',['老林']='老林家大孙女:BAAAKgAECgUIBQAAAA==.',['茉莉']='茉莉雨:BAAAKgAECgIIAgAAAA==.',['萌寶']='萌寶寶:BAAAKgADCggICAAAAA==.',['萌萌']='萌萌丶德:BAAAKgADCggICQAAAA==.',['落入']='落入凡尘:BAAAKgAFFAIIAgAAAA==.',['記憶']='記憶塵埃:BAAAKgADCgUIBQAAAA==.',['记忆']='记忆的尘埃:BAAAKgADCgYIBgAAAA==.',['路人']='路人乙丶:BAAAKgAECgcIDAAAAA==.',['轩辕']='轩辕晓龙:BAAAKgAECgQIBAAAAA==.',['迷失']='迷失的伊甸园:BAAAKgADCgQIBAAAAA==.',['道琼']='道琼斯:BAAAKgADCggICAAAAA==.',['金砖']='金砖儿:BAAAKgAECggIDQAAAA==.',['阴影']='阴影中的壁垒:BAAAKgADCgIIAgAAAA==.',['风语']='风语梦境:BAAAKgAECgQIBwAAAA==.',['高尔']='高尔旋风:BAAAKgAECgQIBwAAAA==.',['鹧鸪']='鹧鸪天:BAAAKgAECggICAAAAA==.',['黄昏']='黄昏黑星:BAABKgAFFH8aAAMCAAgI8BvZCwDRAQACAAgI8BvZCwDRAQALAAQIpBY5GwDJAAAAAA==.',['鼬子']='鼬子:BAABKgAECn8iAAQHAAgI3SLsFQCkAgAHAAgI3SLsFQCkAgAMAAQI4RdNDwABAQAIAAII1BT+hQBuAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end