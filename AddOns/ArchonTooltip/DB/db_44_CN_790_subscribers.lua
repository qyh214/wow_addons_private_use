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
 local lookup = {'Mage-Arcane','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','Shaman-Elemental','Mage-Fire','Priest-Holy','Paladin-Holy','Druid-Feral','Shaman-Restoration','Evoker-Preservation','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Monk-Mistweaver','DeathKnight-Frost','Evoker-Augmentation','Warrior-Protection','DeathKnight-Blood','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Monk-Brewmaster',}; local provider = {region='CN',realm='罗宁',name='CN',type='subscribers',zone=44,date='2025-12-11',data={Cl='Clorislol:BAEBLAAFFH8QAAIBAAgIjhWeCgBAAgg5DAAAAgBIADsMAAACAEQAOgwAAAIAMQA8DAAAAgAlADIMAAACADIAPQwAAAIAQQA+DAAAAgAoAD8MAAACADgAAQAICI4VngoAQAIIOQwAAAIASAA7DAAAAgBEADoMAAACADEAPAwAAAIAJQAyDAAAAgAyAD0MAAACAEEAPgwAAAIAKAA/DAAAAgA4AAAA.',Lu='Luvlesshawn:BAEBLAAFFH85AAMCAAgIkxxnBQBhAgg5DAAACgBjADsMAAAKAGMAOgwAAAsAYwA8DAAACQBiADIMAAAHAGMAPQwAAAgAWAA+DAAAAQAAAD8MAAABAAAAAgAICJMcZwUAYQIIOQwAAAoAYwA7DAAACgBjADoMAAAKAGMAPAwAAAkAYgAyDAAABwBjAD0MAAAIAFgAPgwAAAEAAAA/DAAAAQAAAAMAAQjaILQjAFYAAToMAAABAFQAAAA=.',Ne='Nekofriends:BAEALAAFFAIIAgABLAAFFAgIEAAEAKIUAA==.',Re='Reallpcy:BAEBLAAFFH8SAAIBAAgIKxxhCABlAgg5DAAABQBPADsMAAABADoAOgwAAAUAYwA8DAAAAQBCADIMAAACAFAAPQwAAAIASAA+DAAAAQBWAD8MAAABACIAAQAICCscYQgAZQIIOQwAAAUATwA7DAAAAQA6ADoMAAAFAGMAPAwAAAEAQgAyDAAAAgBQAD0MAAACAEgAPgwAAAEAVgA/DAAAAQAiAAAA.',['一只']='一只小狼德:BAEALAAECgQIBAABLAAFFAgIFgAFAMohAA==.',['云烟']='云烟成雨丨:BAECLAAFFH80AAMBAAcIdSR3BgCIAgc5DAAACABjADsMAAAKAGMAOgwAAAoAYwA8DAAACABiADIMAAAGAF8APQwAAAgAYwA+DAAAAgA8AAEABwh1JHcGAIgCBzkMAAAHAGMAOwwAAAoAYwA6DAAACgBjADwMAAAIAGIAMgwAAAMAXwA9DAAACABjAD4MAAACADwABgACCIAfIQcAoAACOQwAAAEARgAyDAAAAwBaACwABAp/PAADAQAICIUmFAIA+QIAAQAICHYmFAIA+QIABgAGCC0kjQcA9AEAAAA=.',['冷萃']='冷萃花魁:BAEALAAECgYIBgABLAAFFAcIMwAHADsiAA==.',['准备']='准备放监:BAECLAAFFH8WAAIIAAYI5xrDCgDgAQY5DAAABgBVADsMAAAEAGEAOgwAAAcAVQA8DAAAAgAzADIMAAABACsAPQwAAAIAMgAIAAYI5xrDCgDgAQY5DAAABgBVADsMAAAEAGEAOgwAAAcAVQA8DAAAAgAzADIMAAABACsAPQwAAAIAMgAsAAQKfxgAAwgACAhTGpEdACMCAAgACAhTGpEdACMCAAQABghmGpSQANABAAAA.',['利爪']='利爪挠兔:BAEBLAAFFH8IAAIJAAIIIgzDDgBAAAI5DAAABAAkADoMAAAEABkACQACCCIMww4AQAACOQwAAAQAJAA6DAAABAAZAAEsAAUUBggRAAoAwRUA.',['可酷']='可酷伯:BAEBLAAFFH8HAAIBAAMIeBbXJQD9AAM5DAAAAwBaADsMAAABABUAOgwAAAMAPAABAAMIeBbXJQD9AAM5DAAAAwBaADsMAAABABUAOgwAAAMAPAAAAA==.',['唤魔']='唤魔师工具人:BAEBLAAFFH8eAAILAAYI/yQHBABzAgY5DAAABgBhADsMAAAGAFwAOgwAAAYAYgA8DAAABQBVADIMAAACAGMAPQwAAAUAXgALAAYI/yQHBABzAgY5DAAABgBhADsMAAAGAFwAOgwAAAYAYgA8DAAABQBVADIMAAACAGMAPQwAAAUAXgABLAAFFAgINgALAEUkAA==.',['大头']='大头栗子:BAEALAAFFAIIBAABLAAFFAcIJwACAGUlAA==.',['安瓜']='安瓜:BAEBLAAFFH8GAAIMAAIIeA/IQwCWAAI5DAAAAwAtADoMAAADACEADAACCHgPyEMAlgACOQwAAAMALQA6DAAAAwAhAAEsAAUUCAgQAAQAohQA.',['安蜜']='安蜜莉雅:BAECLAAFFH86AAMHAAgIXyV4AABgAwg5DAAABwBkADsMAAAJAGIAOgwAAAYAYwA8DAAACABiADIMAAAIAGMAPQwAAAoAYQA+DAAABgBbAD8MAAAEAFAABwAICF8leAAAYAMIOQwAAAcAZAA7DAAACQBiADoMAAAGAGMAPAwAAAgAYgAyDAAACABjAD0MAAAJAGEAPgwAAAYAWwA/DAAABABQAA0AAQgODEUIADoAAT0MAAABAB4ALAAECn8oAAMHAAgIUSUrBgA9AwAHAAgIUSUrBgA9AwANAAIIdhK2MABsAAAAAA==.',['对的']='对的对的:BAECLAAFFH8QAAMHAAIIPyAyIQC4AAI5DAAACABNADoMAAAIAFcABwACCD8gMiEAuAACOQwAAAUATQA6DAAABQBXAA4AAgjtHzkaAKEAAjkMAAADAFAAOgwAAAMAUgAsAAQKfyIAAw4ACAhmI+gPAPMCAA4ACAhmI+gPAPMCAAcABQgIFAFsADcBAAEsAAUUBwgnAAIAZSUA.',['封存']='封存的小菊花:BAEBLAAFFH8TAAIPAAUI/BRDCgB0AQU5DAAACABdADsMAAACABIAOgwAAAcASgA8DAAAAQAFAD0MAAABAEsADwAFCPwUQwoAdAEFOQwAAAgAXQA7DAAAAgASADoMAAAHAEoAPAwAAAEABQA9DAAAAQBLAAEsAAUUBwgyAAsAmx0A.',['小草']='小草狗:BAEALAAECggIAgABLAAFFAgIFgAFAMohAA==.',['心理']='心理变态了吗:BAEALAAFFAIIAgABLAAFFAYIDgACACQNAA==.心理变态了吧:BAEBLAAFFH8OAAICAAYIJA2eOwAfAQY5DAAABQBLADsMAAABACEAOgwAAAUAPAA8DAAAAQAYADIMAAABAAAAPQwAAAEABwACAAYIJA2eOwAfAQY5DAAABQBLADsMAAABACEAOgwAAAUAPAA8DAAAAQAYADIMAAABAAAAPQwAAAEABwAAAA==.心理变态了呀:BAEBLAAFFH8JAAIBAAYI0gh+OAARAQY5DAAAAwApADsMAAABAAUAOgwAAAIAPwA8DAAAAQAKADIMAAABAAoAPQwAAAEAAwABAAYI0gh+OAARAQY5DAAAAwApADsMAAABAAUAOgwAAAIAPwA8DAAAAQAKADIMAAABAAoAPQwAAAEAAwABLAAFFAYIDgACACQNAA==.心理变态了呢:BAEALAAFFAIIBAABLAAFFAYIDgACACQNAA==.心理变态了哟:BAEBLAAFFH8KAAIEAAQIaxRKNgDbAAQ5DAAABABGADsMAAABACgAOgwAAAQAOwA8DAAAAQAmAAQABAhrFEo2ANsABDkMAAAEAEYAOwwAAAEAKAA6DAAABAA7ADwMAAABACYAASwABRQGCA4AAgAkDQA=.心理变态了噻:BAEALAAFFAIIBAABLAAFFAYIDgACACQNAA==.',['恋狐']='恋狐少:BAECLAAFFH8rAAIHAAcIWxKeCwCXAQc5DAAACgBHADsMAAAHAEgAOgwAAAoAPAA8DAAABgAqADIMAAAEAB0APQwAAAUALwA+DAAAAQAEAAcABwhbEp4LAJcBBzkMAAAKAEcAOwwAAAcASAA6DAAACgA8ADwMAAAGACoAMgwAAAQAHQA9DAAABQAvAD4MAAABAAQALAAECn85AAIHAAgI1yAcFADJAgAHAAgI1yAcFADJAgAAAA==.',['懋耋']='懋耋:BAEALAAECgYIBgABLAAFFAgIHAAIAN4RAA==.',['攫取']='攫取思绪:BAEALAAFFAIIAgABLAAFFAcIJwACAGUlAA==.',['暗兰']='暗兰息:BAECLAAFFH8GAAIQAAIIdhH+cQCPAAI5DAAAAwAjADoMAAADADUAEAACCHYR/nEAjwACOQwAAAMAIwA6DAAAAwA1ACwABAp/FwACEAAICDsgnCoAxwIAEAAICDsgnCoAxwIAAAA=.',['残酷']='残酷通牒:BAECLAAFFH8nAAMCAAYIZSXFCgAcAgY5DAAACABjADsMAAAIAGMAOgwAAAgAXQA8DAAABgBeADIMAAAEAFwAPQwAAAUAXwACAAYIPSXFCgAcAgY5DAAACABjADsMAAAIAGMAOgwAAAYAWwA8DAAABgBeADIMAAAEAFwAPQwAAAUAXwADAAEIjSRLIABqAAE6DAAAAgBdACwABAp/KAACAgAICCcmGgIADAMAAgAICCcmGgIADAMAAAA=.',['毒蔷']='毒蔷薇:BAECLAAFFH8KAAIOAAQIaRGEDgA5AQQ5DAAAAwBCADsMAAADACYAOgwAAAMAMwA8DAAAAQAVAA4ABAhpEYQOADkBBDkMAAADAEIAOwwAAAMAJgA6DAAAAwAzADwMAAABABUALAAECn8nAAMOAAgI0SNsCwAaAwAOAAgI0SNsCwAaAwANAAEIqhZ4NwBNAAAAAA==.',['浮生']='浮生若伤:BAECLAAFFH8TAAIKAAUI/w1mLAALAQU5DAAACABLADsMAAABAAYAOgwAAAgAOwA8DAAAAQAJAD0MAAABABwACgAFCP8NZiwACwEFOQwAAAgASwA7DAAAAQAGADoMAAAIADsAPAwAAAEACQA9DAAAAQAcACwABAp/GQACCgAHCC8d7zUAPgIACgAHCC8d7zUAPgIAASwABRQHCCsABwBbEgA=.',['游泳']='游泳体育生:BAEBLAAFFH8yAAMLAAcImx28BABWAgc5DAAACwBXADsMAAAIAD8AOgwAAAsAXAA8DAAABwBMADIMAAAFAFoAPQwAAAcATgA+DAAAAQApAAsABwibHbwEAFYCBzkMAAAIAFcAOwwAAAYAPwA6DAAACQBcADwMAAABAEwAMgwAAAUAWgA9DAAABQBOAD4MAAABACkAEQAFCHQTgAQATAEFOQwAAAMATQA7DAAAAgAwADoMAAACAC8APAwAAAYAPwA9DAAAAgAMAAAA.',['猫耋']='猫耋:BAEBLAAFFH8cAAMIAAgI3hG/BwAXAgg5DAAABAAPADsMAAAEACgAOgwAAAQALgA8DAAABABFADIMAAAEAEEAPQwAAAQAFQA+DAAAAgAxAD8MAAACADoACAAICN4RvwcAFwIIOQwAAAIADwA7DAAAAgAoADoMAAACAC4APAwAAAIARQAyDAAAAgBBAD0MAAACABUAPgwAAAIAMQA/DAAAAgA6AAQABgjAI8UOANMBBjkMAAACAGAAOwwAAAIAXwA6DAAAAgBjADwMAAACAFYAMgwAAAIAWAA9DAAAAgBSAAAA.',['白色']='白色工具人:BAEALAAFFAYIAgABLAAFFAgINgALAEUkAA==.',['粉色']='粉色皮皮龙:BAEBLAAFFH8GAAMIAAIINSRDEgDOAAI5DAAAAwBfADoMAAADAFoACAACCDUkQxIAzgACOQwAAAMAXwA6DAAAAgBaAAQAAQi2A+hrAD4AAToMAAABAAkAASwABRQGCAsAEgBiGQA=.',['糙作']='糙作猛如虎:BAEALAAECgYIDwABLAAFFAYIGgAQAFYWAA==.',['老土']='老土狗丶:BAECLAAFFH8bAAMOAAYIfyNoAgBrAgY5DAAABgBbADsMAAAFAGEAOgwAAAYAYAA8DAAABABhADIMAAACAFMAPQwAAAQATgAOAAYIfyNoAgBrAgY5DAAABQBbADsMAAAFAGEAOgwAAAYAYAA8DAAABABhADIMAAACAFMAPQwAAAQATgANAAEIcAoXBgBCAAE5DAAAAQAaACwABAp/NgADDgAICFsmrQEAgQMADgAICFsmrQEAgQMADQABCKwRfDoAQAAAASwABRQICBYABQDKIQA=.',['花蝶']='花蝶风月:BAEBLAAECn8oAAQTAAgIBSUnBAAwAwg5DAAABQBbADsMAAAFAGIAOgwAAAUAYgA8DAAABQBiADIMAAAGAF4APQwAAAYAYgA+DAAABQBeAD8MAAADAFQAEwAICOEkJwQAMAMIOQwAAAMAWwA7DAAAAwBiADoMAAADAGIAPAwAAAMAYgAyDAAABABeAD0MAAAEAGIAPgwAAAMAWwA/DAAAAwBUABQABgjUIloXAAYCBjkMAAABAFgAOwwAAAEAVAA6DAAAAQBbADwMAAABAF0APQwAAAIAUwA+DAAAAgBeABAABQhCElM8AeYABTkMAAABAAQAOwwAAAEAGQA6DAAAAQA2ADwMAAABADkAMgwAAAIAWgABLAAFFAcIRQASAOcmAA==.',['苦尽']='苦尽甘來:BAEBLAAFFH8KAAMVAAYIMh+WAABrAgY5DAAAAwBjADsMAAABACwAOgwAAAMAYAA8DAAAAQBPADIMAAABAFoAPQwAAAEARAAVAAYIMh+WAABrAgY5DAAAAwBjADsMAAABACwAOgwAAAIAYAA8DAAAAQBPADIMAAABAFoAPQwAAAEARAAWAAEInhN+HABEAAE6DAAAAQAyAAAA.',['蓝烁']='蓝烁丶:BAEBLAAFFH8FAAIQAAII4RJ+VQCeAAI5DAAAAgAVADoMAAADAEsAEAACCOESflUAngACOQwAAAIAFQA6DAAAAwBLAAAA.',['蕾茉']='蕾茉妮雅:BAECLAAFFH9CAAIXAAgIlQ/hBgCXAQg5DAAADAA8ADsMAAALACIAOgwAAAwANQA8DAAACgA+ADIMAAAHABsAPQwAAAkALQA+DAAABAAeAD8MAAABAAQAFwAICJUP4QYAlwEIOQwAAAwAPAA7DAAACwAiADoMAAAMADUAPAwAAAoAPgAyDAAABwAbAD0MAAAJAC0APgwAAAQAHgA/DAAAAQAEACwABAp/MwACFwAICPkbfxIANwIAFwAICPkbfxIANwIAAAA=.',['蜜甜']='蜜甜甜:BAEBLAAFFH8UAAMOAAYIaBmcEgBKAQY5DAAABgBTADsMAAADAE4AOgwAAAUAWwA8DAAAAgBOADIMAAACAAIAPQwAAAIANgAOAAUIQR6cEgBKAQU5DAAAAwBTADsMAAACAE4AOgwAAAMAWwA8DAAAAgBOAD0MAAACADYABwAECNwHuysAzwAEOQwAAAMAEwA7DAAAAQAUADoMAAACABgAMgwAAAIAEAAAAA==.',['迪迪']='迪迪恺:BAEBLAAFFH8WAAIQAAYIIyJQEgC9AQY5DAAABQBbADsMAAADAFoAOgwAAAUAWwA8DAAAAwBVADIMAAACAFAAPQwAAAQAVQAQAAYIIyJQEgC9AQY5DAAABQBbADsMAAADAFoAOgwAAAUAWwA8DAAAAwBVADIMAAACAFAAPQwAAAQAVQABLAAFFAgIFgAFAMohAA==.',['长顾']='长顾:BAEALAADCgMIAwABLAAFFAMIBwABAHgWAA==.',['雪饼']='雪饼坍缩星:BAEBLAAFFH8GAAIMAAIIdRR5RQCVAAI5DAAAAwA8ADoMAAADACwADAACCHUUeUUAlQACOQwAAAMAPAA6DAAAAwAsAAAA.',['风灬']='风灬焰:BAECLAAFFH8sAAMQAAcIvyX6AQCaAgc5DAAABwBjADsMAAAIAGEAOgwAAAkAYAA8DAAACABiADIMAAADAGEAPQwAAAcAYwA+DAAAAgBXABAABwiqJfoBAJoCBzkMAAAEAGIAOwwAAAUAYQA6DAAABQBgADwMAAAGAGIAMgwAAAMAYQA9DAAABQBjAD4MAAACAFcAFAAFCMcf+AAA9QEFOQwAAAMAYwA7DAAAAwBXADoMAAAEAFkAPAwAAAIANgA9DAAAAgBLACwABAp/HwADFAAICGgmNwEAagMAFAAICGImNwEAagMAEAAECOQm150AygEAAAA=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end