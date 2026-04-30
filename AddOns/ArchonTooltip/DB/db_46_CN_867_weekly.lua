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

local lookup = {'Warlock-Demonology','Warrior-Protection','Warrior-Arms','Warrior-Fury','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','Shaman-Restoration','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Monk-Brewmaster','Paladin-Holy','Priest-Holy',}
local provider = {region='CN',realm='阿斯塔洛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ri='Rion:BAAALgAECgIJAgAAAA==.',
Wo='Wolfhunter:BAAALgADCgEJAQAAAA==.',
Zz='Zzsaki:BAAALgAECgYJBgAAAA==.',
['丝绒']='丝绒拿铁:BAAALgADCgEJAQAAAA==.',
['丶嘢']='丶嘢謜訫之助:BAAALgADCgMJAwAAAA==.',
['五月']='五月丨:BAAALgAECgEJAgAAAA==.',
['仲夏']='仲夏夜里的梦:BAAALgAFFAMJAwAAAA==.',
['伊夫']='伊夫利特之德:BAAALgAECgUJCQAAAA==.伊夫利特之祭:BAABLgAECn8WAAIBAAYJlxbhZACcAQABAAYJlxbhZACcAQAAAA==.',
['依娜']='依娜:BAAALgAECgUJBwAAAA==.',
['依露']='依露莉:BAAALgAECgEJAQAAAA==.',
['倒反']='倒反天罡:BAACLgAFFH8JAAICAAMJPwfGBQC5AAACAAMJPwfGBQC5AAAuAAQKfyMAAgIACAkpDwkVALwBAAIACAkpDwkVALwBAAAA.',
['全能']='全能选手:BAAALgAECgYJEAAAAA==.',
['其实']='其实心很痛:BAAALgADCgEJAQAAAA==.',
['凯恩']='凯恩血踢:BAAALgAECgUJDAAAAA==.',
['加尔']='加尔撸死:BAAALgAECgIJAwAAAA==.',
['加浓']='加浓美式:BAAALgAECgEJAwAAAA==.',
['北境']='北境的阿诗娜:BAAALgADCgIJAgAAAA==.',
['半卷']='半卷烟雨入画:BAAALgAFFAEJAQAAAA==.',
['卓耿']='卓耿:BAAALgAECgIJAgAAAA==.',
['又係']='又係你啊文西:BAAALgADCgUJBQAAAA==.',
['发如']='发如雪丷:BAAALgAFFAIJAgAAAA==.',
['噗噗']='噗噗突突柔柔:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光小妹妹:BAAALgAECgMJAwAAAA==.',
['壮牛']='壮牛水牛奶:BAAALgAECgYJCwAAAA==.',
['大叔']='大叔:BAAALgAECgMJBgAAAA==.',
['大的']='大的一批:BAABLgAECn8XAAMDAAYJdh/yBwA7AgADAAYJdh/yBwA7AgAEAAQJlhSfbwD5AAAAAA==.',
['天命']='天命之神:BAACLgAFFH8JAAIFAAMJjBv4DQD/AAAFAAMJjBv4DQD/AAAuAAQKfycAAwUACAkzIAYKAPUCAAUACAkzIAYKAPUCAAYAAglIDUSxAGIAAAAA.',
['天灵']='天灵西:BAAALgAECgUJBgAAAA==.',
['妹妹']='妹妹别夹我:BAACLgAFFH8JAAIHAAMJzhSEFQDrAAAHAAMJzhSEFQDrAAAuAAQKfx8AAgcACAkrHN9EACYCAAcACAkrHN9EACYCAAAA.',
['安小']='安小法:BAAALgAECgEJAQAAAA==.',
['寒丿']='寒丿琛:BAABLgAFFH8JAAIIAAQJkg/MCQA2AQAIAAQJkg/MCQA2AQAAAA==.',
['小小']='小小班保安:BAAALgADCgMJAwAAAA==.',
['小糊']='小糊涂仙:BAABLgAECn8YAAIJAAYJngSYPQDWAAAJAAYJngSYPQDWAAAAAA==.',
['小鸡']='小鸡蒸蘑菇:BAAALgAECgUJCgABLgAFFAQJBwAIAIcHAA==.',
['尛丁']='尛丁寧:BAAALgADCgEJAQAAAA==.',
['弍哥']='弍哥最帅最欧:BAAALgAECgYJCgAAAA==.',
['弗利']='弗利萨:BAAALgAECgQJCAAAAA==.',
['往生']='往生的命运:BAAALgAECgUJBQAAAA==.',
['必须']='必须得回去:BAAALgAECgYJDgAAAA==.',
['思心']='思心思卿:BAAALgAECgMJAwAAAA==.',
['情亂']='情亂丶夜飘雪:BAAALgAFFAEJAQAAAA==.',
['惊蛰']='惊蛰灬:BAAALgAECgYJAQAAAA==.',
['我只']='我只说一次:BAAALgAFFAIJAwAAAA==.',
['我牛']='我牛的批爆:BAAALgADCgEJAQAAAA==.',
['明日']='明日再来:BAAALgAECgEJAQAAAA==.',
['昱狸']='昱狸狸:BAAALgADCgQJBAAAAA==.',
['晴雨']='晴雨灬:BAAALgAFFAMJBAAAAA==.',
['月下']='月下小威:BAAALgADCgEJAQAAAA==.',
['极冰']='极冰盛宴:BAAALgAECgEJAQAAAA==.',
['柯基']='柯基大王:BAAALgAECgcJEwAAAA==.',
['梦开']='梦开始的地方:BAACLgAFFH8OAAMKAAUJQyGRAQCNAQAKAAUJQyGRAQCNAQALAAIJ8gHPIgBuAAAuAAQKfxQAAwoABwkgHcQoABQCAAoABgkhHsQoABQCAAsABgmVFhVDAEoBAAAA.',
['此屮']='此屮非彼叉:BAACLgAFFH8JAAIBAAMJBw1gIwD3AAABAAMJBw1gIwD3AAAuAAQKfyEAAwwACAlBFvANAOcBAAwABwmgFvANAOcBAAEABQnjGNR1AHIBAAAA.',
['水丿']='水丿水:BAAALgAECgEJAQAAAA==.',
['游侠']='游侠:BAAALgAECgIJAgAAAA==.',
['游斗']='游斗:BAAALgAECgYJDAAAAA==.',
['潘嘟']='潘嘟嘟:BAABLgAFFH8FAAINAAMJKhTpCQD1AAANAAMJKhTpCQD1AAAAAA==.',
['火热']='火热的心:BAAALgADCgEJAQAAAA==.',
['灬歡']='灬歡丨:BAAALgAFFAEJAQAAAA==.',
['灭世']='灭世丶惜惜:BAAALgAECgcJBgAAAA==.灭世惜惜:BAAALgAFFAIJBAAAAA==.',
['点绛']='点绛唇丶殇:BAAALgAECgQJBgAAAA==.',
['热血']='热血传说:BAAALgAECgYJCgAAAA==.',
['牛拳']='牛拳大佬湿:BAAALgAECgEJAQAAAA==.',
['牛盾']='牛盾:BAAALgAECgMJBAAAAA==.',
['狼烟']='狼烟萧萧:BAAALgAECgYJCQAAAA==.',
['猫猫']='猫猫德:BAAALgAFFAIJBAAAAA==.',
['痛伤']='痛伤铭记:BAAALgAECgQJBAAAAA==.',
['白鳳']='白鳳:BAAALgAECgIJAgAAAA==.',
['真的']='真的是被逼的:BAAALgAECgcJBwAAAA==.',
['眸哞']='眸哞:BAAALgAECgYJCQAAAA==.',
['神带']='神带董香:BAAALgAECgMJCAAAAA==.',
['空间']='空间上看到你:BAAALgAECgUJBgAAAA==.',
['舍你']='舍你骑谁:BAAALgAECgcJDQAAAA==.',
['落樱']='落樱散华:BAAALgAECgQJCAAAAA==.',
['蓝桉']='蓝桉:BAAALgAECgUJBQAAAA==.',
['要不']='要不你上吧:BAAALgAECgEJAQAAAA==.',
['费斯']='费斯莉:BAABLgAFFH8HAAMOAAQJNAz8CwAfAQAOAAQJNAz8CwAfAQAJAAIJkwHIKgCAAAAAAA==.',
['躺的']='躺的贼快:BAAALgAECgEJAgAAAA==.',
['遗忘']='遗忘者:BAABLgAFFH8FAAICAAIJRgb+DQBpAAACAAIJRgb+DQBpAAAAAA==.',
['那种']='那种事贼猛:BAAALgAECgQJBAAAAA==.',
['邪骑']='邪骑:BAAALgAECgEJAQAAAA==.',
['醉是']='醉是离人泪:BAAALgAFFAQJBAAAAA==.',
['铲开']='铲开心灵:BAAALgADCgEJAQAAAA==.',
['陌小']='陌小曦丶:BAAALgAFFAEJAQAAAA==.',
['非洲']='非洲大酋长:BAAALgAECgYJDAAAAA==.',
['风行']='风行者:BAAALgADCgQJBAAAAA==.',
['飞舞']='飞舞的雪花:BAABLgAECn8VAAIPAAYJDRswJQDAAQAPAAYJDRswJQDAAQAAAA==.',
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
