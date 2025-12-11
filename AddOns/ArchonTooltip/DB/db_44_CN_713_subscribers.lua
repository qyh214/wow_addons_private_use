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
 local lookup = {'Evoker-Preservation','Druid-Restoration','Priest-Holy','Paladin-Holy','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Druid-Feral','Druid-Balance','Warlock-Destruction','Warlock-Demonology','DeathKnight-Frost','Shaman-Elemental','DeathKnight-Blood','Warrior-Protection','Evoker-Augmentation','Unknown-Unknown','DeathKnight-Unholy','Monk-Windwalker','Monk-Brewmaster',}; local provider = {region='CN',realm='格瑞姆巴托',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Ha='Havertz:BAEBLAAFFH8IAAIBAAYIEwihEAAnAQY5DAAAAgAsADsMAAABAAIAOgwAAAIAIAA8DAAAAQAQADIMAAABABQAPQwAAAEACAABAAYIEwihEAAnAQY5DAAAAgAsADsMAAABAAIAOgwAAAIAIAA8DAAAAQAQADIMAAABABQAPQwAAAEACAABLAAFFAYIJQACAOQjAA==.',Hu='Hummels:BAEBLAAFFH8LAAIDAAYICxqIDgD0AQY5DAAAAwBCADsMAAACAE8AOgwAAAMAXQA8DAAAAQAtADIMAAABAFYAPQwAAAEAHAADAAYICxqIDgD0AQY5DAAAAwBCADsMAAACAE8AOgwAAAMAXQA8DAAAAQAtADIMAAABAFYAPQwAAAEAHAABLAAFFAYIJQACAOQjAA==.',Ka='Kane:BAEBLAAFFH8cAAMEAAYI/x8wBwAjAgY5DAAABgBFADsMAAAFAFUAOgwAAAYAVQA8DAAABQBJADIMAAABAF0APQwAAAUAUwAEAAYI/x8wBwAjAgY5DAAABQBFADsMAAAFAFUAOgwAAAUAVQA8DAAAAwBJADIMAAABAF0APQwAAAUAUwAFAAMILBq6VgBMAAM5DAAAAQBRADoMAAABAEgAPAwAAAIALwABLAAFFAYIJQACAOQjAA==.',Ki='Kimmich:BAEALAAECgQIBAABLAAFFAYIJQACAOQjAA==.',Kl='Klose:BAEALAAECgQIBAABLAAFFAYIJQACAOQjAA==.',Kr='Kroos:BAEALAAECgMIAwABLAAFFAYIJQACAOQjAA==.',Le='Lewandowski:BAEBLAAFFH8cAAMGAAYITh0kIAC3AQY5DAAACABDADsMAAAFAFMAOgwAAAgAWAA8DAAAAwBfADIMAAABADwAPQwAAAMANQAGAAYITh0kIAC3AQY5DAAABwBDADsMAAAEAFMAOgwAAAcAWAA8DAAAAwBfADIMAAABADwAPQwAAAMANQAHAAMI7woZEgBbAAM5DAAAAQAQADsMAAABAAkAOgwAAAEAOgABLAAFFAYIJQACAOQjAA==.',Mu='Mueller:BAEALAAFFAIIBAABLAAFFAYIJQACAOQjAA==.Musiala:BAEBLAAFFH8QAAIIAAYInhtPEQDgAQY5DAAABABZADsMAAADAE0AOgwAAAQAUAA8DAAAAgAiADIMAAABAEoAPQwAAAIAQgAIAAYInhtPEQDgAQY5DAAABABZADsMAAADAE0AOgwAAAQAUAA8DAAAAgAiADIMAAABAEoAPQwAAAIAQgABLAAFFAYIJQACAOQjAA==.',Ne='Neuer:BAEALAAECgQIBAABLAAFFAYIJQACAOQjAA==.',Pr='Prussia:BAEBLAAFFH8lAAQCAAYI5CMJCAAyAgY5DAAACABhADsMAAAIAF4AOgwAAAgAYQA8DAAABQBIADIMAAADAGEAPQwAAAUAWgACAAYI5CMJCAAyAgY5DAAABgBhADsMAAAGAF4AOgwAAAYAYQA8DAAAAQBIADIMAAADAGEAPQwAAAUAWgAJAAQI0g6dCADLAAQ5DAAAAQAhADsMAAACABsAOgwAAAEAHAA8DAAABAA+AAoAAghzDIshAIgAAjkMAAABACMAOgwAAAEAHAAAAA==.',Wa='Warlockshawn:BAEBLAAFFH8qAAMLAAUI1iVqGwC6AQU5DAAADABjADsMAAAKAGEAOgwAAAwAYwA8DAAABQBiAD0MAAADAFoACwAFCNYlahsAugEFOQwAAAwAYwA7DAAACgBhADoMAAAIAGMAPAwAAAUAYgA9DAAAAwBaAAwAAQgDJucfAG0AAToMAAAEAGEAASwABRQICDcACwCHHAA=.',['信仰']='信仰丶德:BAEBLAAFFH8XAAMCAAYIqhQFHQBDAQY5DAAABgBVADsMAAAEAEIAOgwAAAYAUwA8DAAAAwA0ADIMAAACAAoAPQwAAAIAEwACAAQIFhwFHQBDAQQ5DAAABABVADsMAAACAEIAOgwAAAQAUwA8DAAAAQA0AAoABgiUD+sUAEEBBjkMAAACAC4AOwwAAAIAFwA6DAAAAgA/ADwMAAACABYAMgwAAAIAKgA9DAAAAgAnAAEsAAUUBgglAA0AKyUA.信仰丶飒:BAEBLAAECn8UAAMIAAYIvxsVKgDEAQY5DAAAAwBAADsMAAADADcAOgwAAAMAYAA8DAAABABSADIMAAAEADUAPQwAAAMASgAIAAYIvxsVKgDEAQY5DAAAAgBAADsMAAACADcAOgwAAAIAYAA8DAAAAgBSADIMAAACADUAPQwAAAIASgAOAAYIng4xdgBcAQY5DAAAAQAqADsMAAABABMAOgwAAAEAHQA8DAAAAgArADIMAAACACcAPQwAAAEAMgABLAAFFAYIJQANACslAA==.',['光之']='光之晨曦:BAEBLAAFFH8lAAINAAYIKyWFEQAKAgY5DAAABwBdADsMAAAGAGEAOgwAAAgAYwA8DAAABgBcADIMAAAFAFoAPQwAAAUAYQANAAYIKyWFEQAKAgY5DAAABwBdADsMAAAGAGEAOgwAAAgAYwA8DAAABgBcADIMAAAFAFoAPQwAAAUAYQAAAA==.',['周老']='周老师吃饱了:BAEBLAAFFH8cAAMPAAYI0R4ABwDHAQY5DAAABgBhADsMAAAEAFoAOgwAAAYAWgA8DAAABQA3ADIMAAADAEAAPQwAAAQATAAPAAYI0R4ABwDHAQY5DAAABQBhADsMAAAEAFoAOgwAAAUAWgA8DAAABQA3ADIMAAADAEAAPQwAAAQATAANAAIIUhyubABoAAI5DAAAAQBZADoMAAABADcAASwABRQHCDUAEAClHQA=.',['咕兰']='咕兰桑克斯:BAECLAAFFH8gAAMRAAcIchc0BgBhAQc5DAAABAA1ADsMAAAGAEAAOgwAAAcAOwA8DAAABgBAADIMAAACAGIAPQwAAAYARQA+DAAAAQAJABEABgjxFDQGAGEBBjkMAAACADUAOwwAAAUAQAA6DAAABAA7ADwMAAAFAEAAPQwAAAQARQA+DAAAAQAJAAEABghoEb0IADoBBjkMAAACAC8AOwwAAAEAJwA6DAAAAwA/ADwMAAABAAQAMgwAAAIAHQA9DAAAAgBSACwABAp/FwADEQAICNYfigUAYAIAEQAHCO0eigUAYAIAAQAICM8KlCEAXAEAAAA=.',['哈克']='哈克龍:BAEALAAECggICAABLAAECggIDgASAAAAAA==.',['大堃']='大堃法:BAEALAAECgIIAgAAAA==.',['大蔥']='大蔥鴨:BAEALAAECgYIBgABLAAECggIDgASAAAAAA==.',['小光']='小光有意:BAECLAAFFH9IAAINAAgIBiaWAAAVAwg5DAAADgBjADsMAAAMAGMAOgwAAAwAYgA8DAAABwBjADIMAAAHAGEAPQwAAAoAYwA+DAAABgBiAD8MAAAEAFQADQAICAYmlgAAFQMIOQwAAA4AYwA7DAAADABjADoMAAAMAGIAPAwAAAcAYwAyDAAABwBhAD0MAAAKAGMAPgwAAAYAYgA/DAAABABUACwABAp/OgADDQAICGQmWwEAEgMADQAICGQmWwEAEgMAEwACCNAhpUUAsQAAAAA=.',['小动']='小动物爱吃果:BAEBLAAFFH8MAAMHAAcIzBkqEgDVAAc5DAAAAgBOADsMAAABAAUAOgwAAAIARwAyDAAAAQBcAD0MAAABAE8APgwAAAMAPgA/DAAAAgBHAAcABggGGCoSANUABjkMAAACAE4AOwwAAAEABQA6DAAAAgBHADIMAAABAFwAPQwAAAEATwA+DAAAAQAoAAYAAggoGttlAKwAAj4MAAACAD4APwwAAAIARwAAAA==.',['尘枫']='尘枫:BAEALAAECgEIAQABLAAFFAgIDAAHAMwZAA==.尘枫依枼:BAEBLAAFFH8UAAMNAAYIPh7FIgCvAQY5DAAABwBXADsMAAACAE0AOgwAAAYAVgA8DAAAAgBHADIMAAABADYAPQwAAAIAVwANAAYIPh7FIgCvAQY5DAAABwBXADsMAAACAE0AOgwAAAYAVgA8DAAAAgBHADIMAAABADYAPQwAAAEAVwATAAEIjgsFEgBOAAE9DAAAAQAdAAEsAAUUCAgMAAcAzBkA.',['帅气']='帅气的康师傅:BAEBLAAFFH8GAAIUAAIIcAXyFgB0AAI5DAAAAwARADoMAAADAAoAFAACCHAF8hYAdAACOQwAAAMAEQA6DAAAAwAKAAAA.',['暖暖']='暖暖豬:BAEALAAECgYIBgABLAAECggIDgASAAAAAA==.',['桂七']='桂七香芒:BAEBLAAFFH8OAAMEAAcIixSnCAAEAgc5DAAABABUADsMAAACAFYAOgwAAAMAPAA8DAAAAgAiADIMAAABAC0APQwAAAEAMAA+DAAAAQAIAAQABwiLFKcIAAQCBzkMAAACAFQAOwwAAAEAVgA6DAAAAgA8ADwMAAABACIAMgwAAAEALQA9DAAAAQAwAD4MAAABAAgABQAECOoUXTQA6wAEOQwAAAIAQwA7DAAAAQBGADoMAAABACUAPAwAAAEAJgABLAAFFAgIDAAHAMwZAA==.',['猫耋']='猫耋:BAEALAAFFAMIAwABLAAFFAgIHAAEAN4RAA==.',['綠毛']='綠毛蟲:BAEALAAECggIDgAAAA==.',['艾晓']='艾晓晓丶:BAEALAADCgYIBgAAAA==.',['苏生']='苏生栗子球丶:BAEALAAFFAYIBAAAAA==.',['铁拳']='铁拳凌晓雨:BAECLAAFFH8/AAIVAAgIByKJAQCyAgg5DAAACwBfADsMAAALAGAAOgwAAAwAXQA8DAAACQBXADIMAAAHAF0APQwAAAkAWwA+DAAAAwBbAD8MAAABAC4AFQAICAciiQEAsgIIOQwAAAsAXwA7DAAACwBgADoMAAAMAF0APAwAAAkAVwAyDAAABwBdAD0MAAAJAFsAPgwAAAMAWwA/DAAAAQAuACwABAp/LAADFQAICH4jAgcA/AIAFQAICNkiAgcA/AIAFAAHCI0g6CgAvQEAAAA=.',['魔牆']='魔牆人偶:BAEALAADCgMIAwABLAAECggIDgASAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end