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
 local lookup = {'Warrior-Fury','DemonHunter-Havoc','Hunter-BeastMastery','DeathKnight-Blood','Warrior-Protection','Mage-Arcane','Mage-Fire','Mage-Frost','Shaman-Elemental','Hunter-Marksmanship','Monk-Windwalker','Monk-Brewmaster','DemonHunter-Vengeance','Rogue-Assassination','Druid-Guardian','Druid-Balance','Druid-Restoration','Paladin-Retribution','DeathKnight-Frost','Evoker-Devastation','Shaman-Restoration','Unknown-Unknown','DeathKnight-Unholy','Warlock-Destruction',}; local provider = {region='CN',realm='燃烧之刃',name='CN',type='subscribers',zone=44,date='2025-12-11',data={An='Aniya:BAECLAAFFH8OAAIBAAYIihV/BgAuAgY5DAAABQBjADsMAAABADsAOgwAAAUAWAA8DAAAAQAfADIMAAABABYAPQwAAAEAHQABAAYIihV/BgAuAgY5DAAABQBjADsMAAABADsAOgwAAAUAWAA8DAAAAQAfADIMAAABABYAPQwAAAEAHQAsAAQKfxUAAgEABgjdH75LAA0CAAEABgjdH75LAA0CAAAA.',Ar='Arkama:BAEBLAAFFH8GAAIBAAIIVh7tIQC8AAI5DAAAAwBZADoMAAADAEEAAQACCFYe7SEAvAACOQwAAAMAWQA6DAAAAwBBAAEsAAUUBgg0AAIAYSQA.',Ha='Hakuho:BAEBLAAFFH8kAAIDAAcI6R/9DwARAgc5DAAABgBVADsMAAAGAFYAOgwAAAYATAA8DAAABQBaADIMAAAFAFUAPQwAAAUAQgA+DAAAAwBRAAMABwjpH/0PABECBzkMAAAGAFUAOwwAAAYAVgA6DAAABgBMADwMAAAFAFoAMgwAAAUAVQA9DAAABQBCAD4MAAADAFEAAAA=.',Li='Lifengdk:BAEBLAAFFH8SAAIEAAYISyMjBwDDAQY5DAAAAwBfADsMAAADAFEAOgwAAAMAXgA8DAAAAwBaADIMAAADAFUAPQwAAAMAXwAEAAYISyMjBwDDAQY5DAAAAwBfADsMAAADAFEAOgwAAAMAXgA8DAAAAwBaADIMAAADAFUAPQwAAAMAXwABLAAFFAgIQQAFAMgjAA==.',Me='Meiple:BAECLAAFFH8rAAMGAAYI7hzZEgDPAQY5DAAACwBWADsMAAAJAFYAOgwAAAoAXgA8DAAABgBCADIMAAABABUAPQwAAAYAWQAGAAUIESHZEgDPAQU5DAAACwBWADsMAAAJAFYAOgwAAAoAXgA8DAAABgBCAD0MAAAGAFkABwABCEEI2w0APwABMgwAAAEAFQAsAAQKfxUABAYACAhHJh4DAHYDAAYACAj1JR4DAHYDAAgACAjpIesMANICAAcAAQguHXocAFUAAAEsAAUUCAgVAAkAzBgA.',Ry='Rylaicrestfa:BAEBLAAFFH8kAAIGAAgIuhkKGADEAQg5DAAABgBRADsMAAAGAEoAOgwAAAYAYQA8DAAABgBeADIMAAAEAF0APQwAAAYAVAA+DAAAAQAAAD8MAAABAAAABgAICLoZChgAxAEIOQwAAAYAUQA7DAAABgBKADoMAAAGAGEAPAwAAAYAXgAyDAAABABdAD0MAAAGAFQAPgwAAAEAAAA/DAAAAQAAAAAA.',Vi='Vicx:BAEALAAFFAgIAgAAAA==.',Ye='Yexxdh:BAEBLAAFFH8GAAICAAIIyh2oLACxAAI5DAAAAwBJADoMAAADAE8AAgACCModqCwAsQACOQwAAAMASQA6DAAAAwBPAAEsAAUUCAgUAAoAtxQA.Yexxws:BAEBLAAFFH8OAAILAAYIMgnrBQB7AQY5DAAABQA/ADsMAAABAAoAOgwAAAUAOwA8DAAAAQACADIMAAABAAEAPQwAAAEABAALAAYIMgnrBQB7AQY5DAAABQA/ADsMAAABAAoAOgwAAAUAOwA8DAAAAQACADIMAAABAAEAPQwAAAEABAABLAAFFAgIFAAKALcUAA==.',['丨千']='丨千早爱音丨:BAEALAAFFAIIAgABLAAFFAYIBwADAHwCAA==.',['丨神']='丨神崎兰子丨:BAEALAAFFAQIAgABLAAFFAYIBwADAHwCAA==.',['丨纯']='丨纯田真奈丨:BAEBLAAFFH8HAAMDAAYIfAJHHQAaAQY5DAAAAQAEADsMAAABAAYAOgwAAAIACgA8DAAAAQAEADIMAAABAAMAPQwAAAEACQADAAUIqQJHHQAaAQU7DAAAAQAGADoMAAABAAoAPAwAAAEABAAyDAAAAQADAD0MAAABAAkACgACCKUB+TIASwACOQwAAAEABAA6DAAAAQAEAAAA.',['丶浪']='丶浪巫谣:BAEBLAAFFH8NAAIMAAMIhyCACgAaAQM5DAAABABXADsMAAAEAEsAOgwAAAUAVwAMAAMIhyCACgAaAQM5DAAABABXADsMAAAEAEsAOgwAAAUAVwABLAAFFAYIDgABAIoVAA==.',['优米']='优米雅丶:BAEBLAAFFH8MAAICAAUIdxNyGwAAAQU5DAAABABQADsMAAACAC0AOgwAAAQASwA8DAAAAQAWAD0MAAABABkAAgAFCHcTchsAAAEFOQwAAAQAUAA7DAAAAgAtADoMAAAEAEsAPAwAAAEAFgA9DAAAAQAZAAEsAAUUBwgkAAMA6R8A.',['单推']='单推朴孝敏:BAEBLAAFFH8MAAMCAAUIaBirKQBOAQU5DAAABABUADsMAAACAD8AOgwAAAQARQA8DAAAAQAoAD0MAAABADcAAgAFCGgYqykATgEFOQwAAAIAVAA7DAAAAgA/ADoMAAACAEUAPAwAAAEAKAA9DAAAAQA3AA0AAghFEFoVAF8AAjkMAAACACMAOgwAAAIALwABLAAFFAYIDwAOALwkAA==.',['友善']='友善和蔼温柔:BAECLAAFFH84AAQPAAgICBeBAgBwAQg5DAAACABjADsMAAAHAGEAOgwAAAgATwA8DAAABgAWADIMAAAGABMAPQwAAAYATAA+DAAACQAmAD8MAAAGACYAEAAECG8iRQoAhgEEOQwAAAcAYwA7DAAABABhADoMAAAHAE8APQwAAAQATAAPAAgI4QuBAgBwAQg5DAAAAQAnADsMAAADACIAOgwAAAEAIgA8DAAABgAWADIMAAABABMAPQwAAAIADwA+DAAACQAmAD8MAAAGACYAEQABCGoKNU0AQwABMgwAAAUAGgAsAAQKfyEAAxAACAilJrEHAD0DABAACAilJrEHAD0DAA8AAQjGBxY8ACUAAAAA.',['塞巴']='塞巴斯塔丶:BAEBLAAFFH8OAAMDAAQIAiAiNwC1AAQ5DAAABQBfADsMAAACAFAAOgwAAAYAXAA8DAAAAQA6AAMAAghsIiI3ALUAAjkMAAADAF8AOwwAAAIAUAAKAAMIiR6HGACrAAM5DAAAAgBSADoMAAAGAFwAPAwAAAEAOgABLAAFFAYINAACAGEkAA==.',['好梦']='好梦环游丨:BAEBLAAFFH8nAAIDAAYIYiWADgAcAgY5DAAABwBeADsMAAAIAGMAOgwAAAgAYAA8DAAABwBVADIMAAAEAGIAPQwAAAUAYwADAAYIYiWADgAcAgY5DAAABwBeADsMAAAIAGMAOgwAAAgAYAA8DAAABwBVADIMAAAEAGIAPQwAAAUAYwABLAAFFAgIJAAGALoZAA==.',['安爪']='安爪不安瓜:BAEBLAAFFH8IAAISAAYIDwa/MQACAQY5DAAAAgAaADsMAAABAA4AOgwAAAIAIAA8DAAAAQAIADIMAAABAAcAPQwAAAEAAwASAAYIDwa/MQACAQY5DAAAAgAaADsMAAABAA4AOgwAAAIAIAA8DAAAAQAIADIMAAABAAcAPQwAAAEAAwABLAAFFAgIEAASAKIUAA==.',['小鹿']='小鹿无敌:BAEALAAFFAEIAQABLAAFFAYINAACAGEkAA==.',['待宵']='待宵:BAEBLAAFFH8KAAITAAQIFxq/QACyAAQ5DAAABABWADoMAAAEAF0APAwAAAEAIQA9DAAAAQA1ABMABAgXGr9AALIABDkMAAAEAFYAOgwAAAQAXQA8DAAAAQAhAD0MAAABADUAASwABRQGCDQAAgBhJAA=.',['总想']='总想吃宵夜:BAEBLAAFFH8FAAIUAAMIwARsHwA+AAM5DAAAAgAXADsMAAABAAAAOgwAAAIADAAUAAMIwARsHwA+AAM5DAAAAgAXADsMAAABAAAAOgwAAAIADAAAAA==.',['恋魂']='恋魂丶:BAECLAAFFH8MAAICAAIIxR2cNACjAAI5DAAABgBBADoMAAAGAFcAAgACCMUdnDQAowACOQwAAAYAQQA6DAAABgBXACwABAp/FgACAgAICMAkgxEAKAMAAgAICMAkgxEAKAMAAAA=.',['是绿']='是绿色职业啊:BAEALAAFFAQIBAABLAAFFAgIJAAGALoZAA==.',['普露']='普露梅灬:BAEBLAAFFH8VAAMJAAYIzBgMFwCJAQY5DAAABABYADsMAAAEAEoAOgwAAAQAQAA8DAAAAwBIADIMAAADABYAPQwAAAMAOwAJAAYIzBgMFwCJAQY5DAAAAwBYADsMAAADAEoAOgwAAAQAQAA8DAAAAwBIADIMAAADABYAPQwAAAMAOwAVAAII3QB+cABJAAI5DAAAAQACADsMAAABAAEAAAA=.',['月儿']='月儿欣欣:BAECLAAFFH8UAAMKAAYItxTABQDOAQY5DAAACABcADsMAAABACwAOgwAAAgAWgA8DAAAAQAOADIMAAABABcAPQwAAAEANgAKAAYIeRPABQDOAQY5DAAABABSADsMAAABACwAOgwAAAQAUQA8DAAAAQAOADIMAAABABcAPQwAAAEANgADAAIIpCNqLQDNAAI5DAAABABcADoMAAAEAFoALAAECn8dAAMKAAYI6yQjIABlAgAKAAYImiQjIABlAgADAAMIBiB2zwDbAAAAAA==.',['木村']='木村夏樹:BAECLAAFFH8IAAMRAAIIKBY2KQCHAAI5DAAABAAoADoMAAAEAEkAEQACCCgWNikAhwACOQwAAAMAKAA6DAAABABJABAAAQjhGSMtAEcAATkMAAABAEIALAAECn8bAAMQAAYINSN4JQA9AgAQAAYINSN4JQA9AgARAAYIOBqWRADPAQAAAA==.木村虾樹:BAEALAAFFAIIBAABLAAFFAIICAARACgWAA==.',['桃柒']='桃柒:BAEALAAECgYIBgABLAAECgYICAAWAAAAAA==.',['楸楸']='楸楸大魔王:BAEALAAECgYICAAAAA==.',['烨嬅']='烨嬅:BAEBLAAECn8eAAMTAAgIFSEdQACAAgg5DAAABQBWADsMAAAFAFoAOgwAAAUAXwA8DAAABABUADIMAAAEAEkAPQwAAAQAUgA+DAAAAgBGAD8MAAABAFwAEwAICB4gHUAAgAIIOQwAAAIAVgA7DAAAAgBXADoMAAAEAF8APAwAAAMAQwAyDAAAAwBJAD0MAAADAFIAPgwAAAIARgA/DAAAAQBcABcABggxHswmAIkBBjkMAAADAE0AOwwAAAMAWgA6DAAAAQBUADwMAAABAFQAMgwAAAEARAA9DAAAAQA6AAEsAAUUAggIABEAKBYA.',['热烈']='热烈马:BAEBLAAFFH9BAAIFAAgIyCPMAADcAgg5DAAACQBgADsMAAAKAGEAOgwAAAoAYAA8DAAACgBWADIMAAAKAGIAPQwAAAoAYAA+DAAAAwBKAD8MAAADAFQABQAICMgjzAAA3AIIOQwAAAkAYAA7DAAACgBhADoMAAAKAGAAPAwAAAoAVgAyDAAACgBiAD0MAAAKAGAAPgwAAAMASgA/DAAAAwBUAAAA.',['珂朵']='珂朵莉丶:BAEALAAFFAIIAgABLAAFFAcIJAADAOkfAA==.',['米澤']='米澤茜:BAECLAAFFH8GAAIYAAIIIhnsNACnAAI5DAAAAwBEADoMAAADADwAGAACCCIZ7DQApwACOQwAAAMARAA6DAAAAwA8ACwABAp/IAACGAAICMAcDiYArgIAGAAICMAcDiYArgIAASwABRQCCAgAEQAoFgA=.',['罗马']='罗马王子:BAEALAAECgEIAQAAAA==.',['虾粥']='虾粥:BAEALAAFFAIIBAABLAAFFAIICAARACgWAA==.',['雪華']='雪華綺晶:BAEALAAFFAIIAgABLAAFFAYIBwADAHwCAA==.',['鱼呀']='鱼呀鱼灬:BAEBLAAFFH8TAAIGAAUItxctFQC7AQU5DAAABQBdADsMAAADADEAOgwAAAUAXgA8DAAAAwApAD0MAAADABgABgAFCLcXLRUAuwEFOQwAAAUAXQA7DAAAAwAxADoMAAAFAF4APAwAAAMAKQA9DAAAAwAYAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end