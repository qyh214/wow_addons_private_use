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
 local lookup = {'DeathKnight-Frost','Warrior-Fury','Warlock-Destruction','Shaman-Restoration','Shaman-Elemental','Warrior-Protection','Mage-Arcane','Hunter-BeastMastery','DemonHunter-Havoc','Mage-Frost','Druid-Feral','Paladin-Retribution','Warlock-Demonology','Priest-Holy','Evoker-Preservation','Paladin-Holy','DemonHunter-Vengeance','Druid-Guardian','Druid-Restoration','Monk-Brewmaster','Monk-Mistweaver','Priest-Shadow','Paladin-Protection','Rogue-Subtlety','Warrior-Arms','Warlock-Affliction','Mage-Fire','Monk-Windwalker','Evoker-Devastation','Rogue-Assassination','DeathKnight-Blood',}; local provider = {region='CN',realm='刀塔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bm='Bmk:BAABLAAFFH8bAAIBAAgI7yD/BACvAgABAAgI7yD/BACvAgAAAA==.',Da='Darknass:BAAALAAECgIIAgAAAA==.',De='Deathcomin:BAABLAAFFH8dAAIBAAgIriGTAwDMAgABAAgIriGTAwDMAgAAAA==.Deathnight:BAABLAAFFH8RAAIBAAgIMhXZCwA+AgABAAgIMhXZCwA+AgAAAA==.Despacito:BAAALAAECgYIBgAAAA==.',Dr='Dragonbreath:BAAALAAECgYIDAAAAA==.',Dt='Dtfkk:BAAALAAECgUICQAAAA==.',Du='Duolaam:BAAALAADCgEIAQAAAA==.',Et='Etfkk:BAABLAAFFH8MAAICAAgItCGWAgDVAgACAAgItCGWAgDVAgABLAAFFAgIGwABAO8gAA==.',Eu='Euphoria:BAABLAAFFH8PAAIDAAYI+hK0LgBfAQADAAYI+hK0LgBfAQAAAA==.',Ev='Evolvium:BAABLAAFFH8OAAMEAAMIfggjUQB5AAAEAAMIfggjUQB5AAAFAAMIfAQlOwBhAAABLAAFFAYILwAGAJMbAA==.',Fi='Firestorm:BAABLAAFFH8GAAIHAAIIChEoSwCVAAAHAAIIChEoSwCVAAAAAA==.',Fo='Fortytwodly:BAAALAAECgYIBgAAAA==.Fortytwolr:BAAALAAECgUIBQAAAA==.Fortytwoqs:BAAALAAECgYIBwAAAA==.',Fr='Freya:BAABLAAFFH8aAAIIAAgIABVgDwAPAgAIAAgIABVgDwAPAgAAAA==.Frigga:BAABLAAFFH8QAAIIAAYIRhW0KQCNAQAIAAYIRhW0KQCNAQAAAA==.',Fy='Fy:BAACLAAFFH8nAAMEAAgI3hUxBgDfAQAEAAcIrxcxBgDfAQAFAAUIkw4tEwAvAQAsAAQKfyMAAwUACAjiHRIZANMCAAUACAjiHRIZANMCAAQACAihG6UjAIQCAAAA.',Ga='Galaxyray:BAAALAAECgQIBAAAAA==.',Gt='Gtfkk:BAAALAAECgYIBwAAAA==.',Gu='Guldann:BAAALAAECgYIEgAAAA==.Gusta:BAABLAAECn8gAAIJAAYIOSCpdgDYAQAJAAYIOSCpdgDYAQAAAA==.',He='Hellalleria:BAAALAAECgYIEgAAAA==.Helldryad:BAAALAAECgEIAQAAAA==.Hellknight:BAAALAAECggIDAAAAA==.Hellmedivh:BAACLAAFFH8IAAMHAAII7xwnRwCZAAAHAAII/xQnRwCZAAAKAAEIyx/9HABTAAAsAAQKfx4AAwcABggSIo8eALgBAAcABggSIo8eALgBAAoAAQi7E7WSADYAAAAA.Hesperus:BAABLAAECn8gAAILAAgIFxtMDACKAgALAAgIFxtMDACKAgAAAA==.',Ho='Holyfire:BAACLAAFFH8FAAIMAAII/B/vJADAAAAMAAII/B/vJADAAAAsAAQKfyIAAgwACAj2JU4EAHoDAAwACAj2JU4EAHoDAAEsAAUUBwgmAAEAoR0A.',Il='Iliidan:BAAALAAFFAIIAgAAAA==.',Ix='Ix:BAAALAAFFAgIAQAAAA==.',Jo='Jormagium:BAAALAAFFAIIAgABLAAFFAYILwAGAJMbAA==.',Kt='Ktfkk:BAAALAAECgUIBgABLAAFFAgIGwABAO8gAA==.',La='Lastdancer:BAAALAAECgYICQAAAA==.',Li='Ling:BAAALAADCggIDAAAAA==.',Lo='Loofah:BAABLAAFFH8FAAMDAAMIfxftQgCUAAADAAMIUBLtQgCUAAANAAEIeReDJwBRAAABLAAFFAUIGwALAMYcAA==.Looq:BAABLAAFFH8KAAIIAAQIzBF/YAC8AAAIAAQIzBF/YAC8AAABLAAFFAUIGAABAIcgAA==.',Mo='Moirathausan:BAAALAAECgIIAwAAAA==.Moonkin:BAAALAAECgEIAQAAAA==.Morgaladriel:BAAALAAECgYIDAAAAA==.',Mt='Mtfkk:BAAALAAECgYIBgAAAA==.',Na='Nature:BAAALAAECgYICQAAAA==.',On='Onlyo:BAAALAAECgYIDAAAAA==.',Ot='Ottermeow:BAABLAAFFH8dAAIIAAgIlhrnBwBlAgAIAAgIlhrnBwBlAgAAAA==.',Pa='Passion:BAAALAAFFAYIAgAAAA==.',Pe='Penguin:BAAALAAECgMIAwAAAA==.',Si='Sif:BAABLAAFFH8GAAIIAAYIjRAlOgBYAQAIAAYIjRAlOgBYAQAAAA==.',Sm='Smilence:BAAALAAECggICAAAAA==.',St='Stormhit:BAACLAAFFH8mAAIBAAcIoR0qDwAVAgABAAcIoR0qDwAVAgAsAAQKfxcAAgEABwhtImQ+AIUCAAEABwhtImQ+AIUCAAAA.',Su='Suga:BAACLAAFFH8QAAIOAAUI/RzaFACuAQAOAAUI/RzaFACuAQAsAAQKfx0AAg4ACAhzIDoMAAUDAA4ACAhzIDoMAAUDAAAA.',Sy='Sydneycart:BAAALAAECgMIAwAAAA==.',Ta='Tak:BAAALAAECgEIAQAAAA==.',Th='Thislove:BAAALAAFFAQIBAAAAA==.',Ti='Titanium:BAABLAAFFH8vAAIGAAYIkxtjCgCaAQAGAAYIkxtjCgCaAQAAAA==.',Wh='Whisperer:BAABLAAFFH8GAAIHAAIIUgUBYAB7AAAHAAIIUgUBYAB7AAAAAA==.',Ye='Yep:BAAALAADCggIEQAAAA==.',Zh='Zhendemeiyis:BAACLAAFFH8iAAMHAAYI4x6JHACnAQAHAAYI4x6JHACnAQAKAAEITBlYHgBJAAAsAAQKfx8AAwcACAikHy8oAKwCAAcACAikHy8oAKwCAAoAAQi8ECyYACsAAAAA.',['一只']='一只绿毛龟:BAAALAAECggIBwAAAA==.',['一键']='一键红老先生:BAAALAAECgQIBAAAAA==.',['三水']='三水佑也:BAAALAADCgMIAwAAAA==.',['三角']='三角初华:BAAALAAECgYIBgAAAA==.',['上帝']='上帝之手:BAAALAAECgcIDQAAAA==.上帝之目:BAAALAAECgYICAAAAA==.上帝之裁:BAAALAAECgYIEQAAAA==.',['下次']='下次也不一定:BAAALAAECgQIBAAAAA==.',['不懂']='不懂难过:BAABLAAFFH8GAAIPAAIIZBKAGQBzAAAPAAIIZBKAGQBzAAAAAA==.',['东方']='东方静:BAAALAAECgYIDwAAAA==.',['丶凉']='丶凉栀:BAABLAAECn8UAAIJAAgIWRz3LwCcAgAJAAgIWRz3LwCcAgAAAA==.',['丶暗']='丶暗夜:BAABLAAFFH8GAAIGAAIIrxJ8KwA5AAAGAAIIrxJ8KwA5AAAAAA==.',['丶猫']='丶猫祭:BAACLAAFFH8GAAIKAAMIYBJ9DQCCAAAKAAMIYBJ9DQCCAAAsAAQKfxkAAgoABwhVFiU0AKcBAAoABwhVFiU0AKcBAAAA.',['主力']='主力:BAAALAAFFAIIAwAAAA==.',['二十']='二十一年渣男:BAABLAAFFH8IAAIGAAgI1BczBAAXAgAGAAgI1BczBAAXAgAAAA==.二十二年渣男:BAAALAAFFAMIAwAAAA==.',['二遁']='二遁散:BAAALAADCgEIAQAAAA==.',['云儿']='云儿妖妖:BAABLAAFFH8FAAIIAAUIsQZuXQDOAAAIAAUIsQZuXQDOAAAAAA==.',['云缥']='云缥缈:BAAALAAECgMIAwAAAA==.',['云长']='云长:BAABLAAFFH8SAAMFAAMIKBSDGADuAAAFAAMIKBSDGADuAAAEAAMIfhpANwCSAAAAAA==.',['五花']='五花肉大师:BAAALAAFFAEIAQAAAA==.',['井仁']='井仁芹菜:BAABLAAFFH8OAAIGAAYILBieDwBSAQAGAAYILBieDwBSAQAAAA==.',['井岗']='井岗葫芦娃:BAAALAAECgEIAQAAAA==.',['亚细']='亚细亚:BAABLAAFFH8bAAMQAAYIYBPODwCJAQAQAAYIYBPODwCJAQAMAAEI+hUDUwBPAAAAAA==.',['亮剑']='亮剑:BAABLAAFFH8GAAICAAYIKBOlGQCWAQACAAYIKBOlGQCWAQAAAA==.',['代达']='代达罗斯:BAAALAAECgcIDgAAAA==.',['伊格']='伊格达萨:BAAALAADCgMIAwAAAA==.',['伏美']='伏美替尼:BAAALAAECgYICgAAAA==.',['会点']='会点法术:BAABLAAFFH8KAAIDAAIIkxdMXgBAAAADAAIIkxdMXgBAAAAAAA==.',['伽罗']='伽罗皇后:BAABLAAFFH8GAAIIAAYIAhi6MgBvAQAIAAYIAhi6MgBvAQAAAA==.',['你来']='你来辣:BAABLAAFFH8aAAIIAAYIAyATGQDSAQAIAAYIAyATGQDSAQAAAA==.',['你馬']='你馬哥:BAAALAADCggICAAAAA==.',['俠鵺']='俠鵺:BAAALAAECgMIAwAAAA==.',['俺更']='俺更绿俺更强:BAAALAAECgYIBwAAAA==.',['克拉']='克拉克:BAAALAADCgYIBgAAAA==.',['兰梦']='兰梦心雪:BAAALAADCgMIAwAAAA==.',['兽眼']='兽眼通天:BAAALAAECgQIBwAAAA==.',['冰冰']='冰冰仙贝:BAABLAAFFH8MAAIBAAYIphHeLwB7AQABAAYIphHeLwB7AQAAAA==.',['凉栀']='凉栀丶丶:BAABLAAECn8UAAIJAAgIkxzrFgAjAgAJAAgIkxzrFgAjAgAAAA==.',['凯文']='凯文兄丶:BAAALAAECggICAAAAA==.',['刀塔']='刀塔大魔王:BAABLAAFFH8aAAIIAAgIhBabDQAdAgAIAAgIhBabDQAdAgAAAA==.',['刀锋']='刀锋意志:BAABLAAFFH8IAAIJAAYIZhtNCAAZAgAJAAYIZhtNCAAZAgAAAA==.',['刷吧']='刷吧蛋刀玩玩:BAAALAAECgMIBgAAAA==.',['刹那']='刹那芳华:BAAALAADCgIIAgAAAA==.',['加藤']='加藤蝇:BAAALAAECgYIBgAAAA==.',['动次']='动次打次灬:BAAALAAECgYIBgAAAA==.动次打瓷丶:BAABLAAFFH8GAAICAAYI5gCiZgAPAAACAAYI5gCiZgAPAAAAAA==.',['劲缸']='劲缸葫芦娃:BAAALAAECgYIBgAAAA==.',['半岛']='半岛铁头:BAAALAAECgIIAgAAAA==.',['半熟']='半熟芝士:BAAALAAECgYIDAAAAA==.',['半糖']='半糖美式:BAAALAAECgIIAgAAAA==.',['南北']='南北绿豆丶:BAAALAAECggICgAAAA==.',['卡卡']='卡卡大魔王:BAABLAAFFH8ZAAIIAAcIbRiUFgDfAQAIAAcIbRiUFgDfAQAAAA==.',['厄尔']='厄尔斯娜:BAAALAADCgEIAQAAAA==.',['变形']='变形的鸭梨:BAAALAAECgMIAwAAAA==.',['只能']='只能拉一点点:BAAALAAECgQIBAAAAA==.',['叫我']='叫我大强:BAAALAAECgQIBQAAAA==.',['可愛']='可愛刀:BAABLAAFFH8MAAIIAAgICBBBGQDRAQAIAAgICBBBGQDRAQAAAA==.',['可爱']='可爱贼厉害:BAAALAAECggIDgAAAA==.',['叶晨']='叶晨:BAAALAAECgYIBgAAAA==.',['呱呱']='呱呱的奶瓶:BAAALAAECgYIBgAAAA==.',['哆啦']='哆啦咪梦:BAABLAAFFH8OAAIRAAIIeA6AFAAuAAARAAIIeA6AFAAuAAAAAA==.',['啊份']='啊份酷发:BAAALAAECgEIAQAAAA==.',['喵了']='喵了戈咪:BAAALAAECgYIDwAAAA==.',['喵妮']='喵妮克希亚:BAABLAAFFH8RAAIIAAgI9BIxDgAYAgAIAAgI9BIxDgAYAgAAAA==.',['回雪']='回雪:BAABLAAFFH8RAAIBAAUIOhXlPABHAQABAAUIOhXlPABHAQABLAAFFAUIEgAIABwQAA==.',['圣光']='圣光小魔仙:BAAALAAECgIIAgAAAA==.',['在下']='在下毛毛雨:BAAALAAFFAIIAgAAAA==.',['地板']='地板好凉快:BAAALAAECgYIDAAAAA==.',['增粗']='增粗增大增强:BAAALAAECgQIBAAAAA==.',['夏利']='夏利巴黎春雪:BAACLAAFFH8uAAISAAYIRRUkAgD7AAASAAYIRRUkAgD7AAAsAAQKfygAAxIACAh4GksOAPcBABIACAh4GksOAPcBABMAAQgHEqHkADUAAAAA.',['夏酒']='夏酒:BAABLAAECn8YAAIUAAgIZwlYKQBFAQAUAAgIZwlYKQBFAQAAAA==.',['夜色']='夜色丶:BAABLAAFFH8KAAIBAAYIrQH1qAAhAAABAAYIrQH1qAAhAAAAAA==.',['大夏']='大夏贡:BAAALAAECggICAAAAA==.',['天之']='天之剑神:BAAALAAECgIIAgAAAA==.',['天斬']='天斬:BAAALAAECgEIAQAAAA==.',['奈菲']='奈菲天:BAABLAAFFH8FAAIVAAQIYAsoDwDSAAAVAAQIYAsoDwDSAAAAAA==.',['奶牛']='奶牛刺身:BAAALAAECgQIBAAAAA==.',['奶白']='奶白的学子:BAAALAAECgEIAQAAAA==.',['奶舞']='奶舞影:BAAALAAECgYIBgAAAA==.',['奶萨']='奶萨:BAACLAAFFH8UAAMEAAUIsSByEQDYAQAEAAUIsSByEQDYAQAFAAQIExluKAABAQAsAAQKfxsAAwUACAhvIHoIAJwCAAUACAhvIHoIAJwCAAQABggBIhoWAEACAAAA.',['婉拒']='婉拒王楚然:BAAALAADCgEIAQAAAA==.',['子陵']='子陵:BAAALAAECgYIDwAAAA==.',['小喵']='小喵叽丶:BAABLAAFFH8QAAIIAAgIExaqDAAkAgAIAAgIExaqDAAkAgAAAA==.',['小小']='小小十七:BAAALAAECgMIAwAAAA==.小小猎:BAAALAAECgYIEgAAAA==.小小贼只偷心:BAAALAAECgYIBgAAAA==.',['小月']='小月半:BAAALAAECgYIEAAAAA==.',['小术']='小术女:BAAALAADCgIIAgAAAA==.',['小歪']='小歪插蛇棒:BAABLAAFFH8GAAIEAAII0AJ8bABTAAAEAAII0AJ8bABTAAAAAA==.',['小獭']='小獭叽丶:BAABLAAFFH8GAAIIAAYIdBJGPQBPAQAIAAYIdBJGPQBPAQAAAA==.',['小甩']='小甩甩:BAAALAADCgQIBAAAAA==.',['小禾']='小禾流水:BAACLAAFFH9CAAMOAAYIWCM/CQDCAQAOAAYIWCM/CQDCAQAWAAYIEx02CgCxAQAsAAQKfxYAAxYACAj7HBsnAEECABYABgikIRsnAEECAA4ABAjRHyAsAFgBAAAA.',['小突']='小突突:BAABLAAFFH8LAAIIAAMIORaeZwCXAAAIAAMIORaeZwCXAAAAAA==.',['小野']='小野丶:BAABLAAFFH8dAAIXAAYINByKBQCDAQAXAAYINByKBQCDAQAAAA==.',['巩俐']='巩俐:BAAALAADCgYIBgAAAA==.',['希尔']='希尔佤娜斯:BAAALAAECgQIBAAAAA==.',['幼稚']='幼稚园扛把子:BAABLAAECn8dAAIBAAYI7Bt6VQBHAQABAAYI7Bt6VQBHAQAAAA==.',['应急']='应急食材:BAAALAAECgEIAgAAAA==.',['弗雷']='弗雷德里克尔:BAAALAAECgYIBgAAAA==.',['张婷']='张婷:BAAALAAFFAIIAwAAAA==.',['弹吉']='弹吉勾:BAAALAAFFAIIAgAAAA==.',['强盗']='强盗:BAAALAAFFAIIAgAAAA==.',['彩虹']='彩虹先生:BAAALAAECgQIBAAAAA==.',['很少']='很少开心:BAABLAAFFH8KAAIWAAMIexahHwCLAAAWAAMIexahHwCLAAAAAA==.',['德来']='德来倪:BAAALAAECgUIBgAAAA==.',['心渊']='心渊魔角:BAABLAAFFH8dAAIJAAYIDCDYDgDrAQAJAAYIDCDYDgDrAQABLAAFFAgIRAALAJUiAA==.',['心灵']='心灵不震撼:BAABLAAFFH8PAAIMAAYI4RlfFwCXAQAMAAYI4RlfFwCXAQAAAA==.',['性感']='性感大锤:BAAALAAECgUIBQAAAA==.性感小锤:BAABLAAFFH8dAAMNAAYIux2xAgBrAQADAAYIZBzSHQCnAQANAAUIHCCxAgBrAQAAAA==.性感锤锤:BAABLAAFFH8NAAIJAAUI9BQCLQAwAQAJAAUI9BQCLQAwAQABLAAFFAYIHQANALsdAA==.',['怨念']='怨念丶:BAAALAAECgIIAgAAAA==.',['恩赐']='恩赐丨死骑:BAAALAAECgYICwAAAA==.',['惩戒']='惩戒胡萝卜:BAAALAADCgIIAwAAAA==.',['愚蠢']='愚蠢的一米八:BAABLAAFFH8GAAIMAAQIkhmdMwDlAAAMAAQIkhmdMwDlAAAAAA==.',['慈父']='慈父之锤:BAAALAAECgUIBQAAAA==.',['我有']='我有两个密秘:BAAALAAECgEIAQAAAA==.',['我的']='我的发:BAAALAAECgYIBwAAAA==.',['战土']='战土:BAAALAAECgYIBgAAAA==.',['折光']='折光:BAABLAAFFH8OAAMHAAIIKRuKOACqAAAHAAIIKRuKOACqAAAKAAIInBR5FwBAAAAAAA==.',['披坚']='披坚执锐:BAAALAAECgQIBAAAAA==.',['拼好']='拼好奶:BAAALAADCgQIBAAAAA==.',['插图']='插图腾拉链接:BAAALAAECgYIBgAAAA==.',['摆渡']='摆渡人凯瑟琳:BAAALAADCgMIAwAAAA==.',['摩多']='摩多摩多:BAAALAADCgUIBQAAAA==.',['放火']='放火奶:BAAALAAECgYIBgAAAA==.',['斑驳']='斑驳岁月:BAABLAAFFH8GAAIHAAIIeRfNPwCgAAAHAAIIeRfNPwCgAAAAAA==.',['斯戈']='斯戈特陈:BAAALAAECgEIAQAAAA==.',['方大']='方大灬:BAAALAAECgYIBgAAAA==.',['无丨']='无丨奈何:BAAALAAECgUICgAAAA==.',['无惦']='无惦念:BAACLAAFFH8IAAIBAAIIWR5VTwChAAABAAIIWR5VTwChAAAsAAQKfx4AAgEACAj+GttRAFQCAAEACAj+GttRAFQCAAAA.',['无所']='无所畏惧之人:BAAALAAECgMIAwAAAA==.',['日居']='日居月诸灵土:BAAALAAECgEIAQAAAA==.',['旱地']='旱地牛牛:BAABLAAFFH8TAAISAAQIthaoBQDAAAASAAQIthaoBQDAAAAAAA==.',['春天']='春天的跳动:BAABLAAFFH8JAAIDAAIIngbcVQBuAAADAAIIngbcVQBuAAAAAA==.',['是张']='是张不迟:BAAALAADCgYIBgAAAA==.',['暗咩']='暗咩:BAABLAAFFH8MAAIOAAMIJR79KADlAAAOAAMIJR79KADlAAABLAAFFAYIIwAYAOAfAA==.',['暗夜']='暗夜术:BAAALAAECgEIAQAAAA==.',['暴力']='暴力站桩:BAAALAADCgIIAgAAAA==.',['替补']='替补奶萨:BAAALAAECgYIBgAAAA==.',['月光']='月光大剑:BAAALAAFFAIIAgAAAA==.',['月澜']='月澜衫:BAAALAADCgYIBgAAAA==.',['月独']='月独照:BAAALAADCggICAAAAA==.',['月狮']='月狮舞:BAAALAAECgQIBAAAAA==.',['有个']='有个拽杰:BAABLAAFFH8GAAICAAIInggXVgBAAAACAAIInggXVgBAAAAAAA==.',['有牛']='有牛啊:BAAALAAECgEIAQAAAA==.',['朱度']='朱度因子:BAAALAAFFAIIAwAAAA==.',['朱思']='朱思远:BAAALAAECgQIBAAAAA==.',['枯雏']='枯雏脸:BAAALAADCgMIAwAAAA==.',['桑弗']='桑弗洛尔:BAAALAADCgcIBwAAAA==.',['梦烬']='梦烬呢喃:BAAALAAECggICAAAAA==.',['楼塔']='楼塔:BAAALAAECgUIBQAAAA==.',['橘白']='橘白:BAABLAAFFH8GAAISAAIIzQj3DwAlAAASAAIIzQj3DwAlAAABLAAFFAUIFQAMAEgTAA==.',['橙仙']='橙仙:BAABLAAECn8ZAAIBAAcIXxTyngDJAQABAAcIXxTyngDJAQAAAA==.',['欧内']='欧内的手:BAAALAAECgYICAAAAA==.',['死亡']='死亡在我心:BAAALAAECgMIAwAAAA==.',['死给']='死给阿强尼:BAAALAAFFAIIAgAAAA==.',['沃克']='沃克沃克:BAAALAAECggIDgAAAA==.',['沈老']='沈老师:BAAALAAECgUIBQAAAA==.',['沉沉']='沉沉的睡睡:BAAALAAECgEIAQAAAA==.',['沉鱼']='沉鱼:BAAALAAECgEIAQAAAA==.',['沐沂']='沐沂:BAAALAAFFAMIAwAAAA==.',['沙兜']='沙兜拽根:BAACLAAFFH8gAAQMAAYIhBvJFgAFAQAMAAUIIhzJFgAFAQAQAAUIggOMGgDfAAAXAAMIMgn8EgBcAAAsAAQKfxUAAgwABwgnI7lEAG4CAAwABwgnI7lEAG4CAAAA.',['津港']='津港葫芦娃:BAAALAAECgQIBAAAAA==.',['浪荡']='浪荡公子哥:BAAALAAECggICAAAAA==.浪荡公子爷:BAAALAAECgQIBAAAAA==.浪荡小野兽:BAAALAAECgQIBAAAAA==.浪荡未亡人:BAABLAAECn8ZAAIBAAgIKB4uNwCaAgABAAgIKB4uNwCaAgAAAA==.',['海涵']='海涵彡:BAAALAAECgUICAAAAA==.',['海鸥']='海鸥魂:BAACLAAFFH8gAAMZAAYIXx3FAQAUAQACAAUITRs4IABqAQAZAAQIhR7FAQAUAQAsAAQKfxkAAxkACAgaIaQGAJcCABkABwg2IKQGAJcCAAIABwidH2UtAIUCAAAA.',['清澄']='清澄飞雪真君:BAAALAAECgYIDAAAAA==.',['清璇']='清璇:BAAALAADCgcIBwAAAA==.',['渣男']='渣男大狼狗:BAABLAAECn8mAAQDAAgIaCVtCABUAwADAAgIaCVtCABUAwAaAAYIfxWgEQCcAQANAAII+RGNhwBjAAAAAA==.',['满穗']='满穗良人:BAACLAAFFH8MAAMJAAYIwhyvFQC4AQAJAAYIwhyvFQC4AQARAAEIDxSPEQBAAAAsAAQKfxgAAgkACAgpHSQ8AG8CAAkACAgpHSQ8AG8CAAAA.满穗良仁:BAACLAAFFH8UAAIHAAUIcR+GGwBxAQAHAAUIcR+GGwBxAQAsAAQKfyoAAwcACAh9I0YRABcDAAcACAh9I0YRABcDABsAAghpEyUZAHEAAAAA.',['火箭']='火箭龟:BAABLAAFFH8bAAILAAUIxhztAQDzAQALAAUIxhztAQDzAQAAAA==.',['熊猫']='熊猫烧姜:BAABLAAFFH8LAAMcAAIIMRd3DgCfAAAcAAIIMRd3DgCfAAAUAAEIkAFKJQAAAAAAAA==.',['爱吃']='爱吃米饭:BAABLAAFFH8MAAIVAAQIhRVcDQAOAQAVAAQIhRVcDQAOAQAAAA==.',['爱蕾']='爱蕾莉亚:BAAALAADCgIIAgAAAA==.',['牛之']='牛之:BAAALAADCgQIBAAAAA==.',['狂干']='狂干瘸子好腿:BAAALAAECgYIEAAAAA==.',['独啸']='独啸狂风:BAAALAAFFAIIBAAAAA==.',['猎魂']='猎魂者丶凛:BAABLAAECn8cAAIJAAYIfhZ0SQA+AQAJAAYIfhZ0SQA+AQAAAA==.',['獭獭']='獭獭丶:BAABLAAFFH8MAAIIAAYIwxo4LQCBAQAIAAYIwxo4LQCBAQAAAA==.',['獺獺']='獺獺:BAABLAAFFH8SAAIIAAYItxoiLACFAQAIAAYItxoiLACFAQAAAA==.',['王吕']='王吕晶:BAAALAAFFAIIBAAAAA==.',['王牌']='王牌猎:BAAALAAECgYIBgAAAA==.',['王龙']='王龙女:BAAALAADCgYIBgAAAA==.',['理塘']='理塘猎码人:BAAALAAFFAIIAgAAAA==.',['瑾年']='瑾年丨蒼瞳:BAABLAAECn8bAAIBAAgIMyQZCgCoAgABAAgIMyQZCgCoAgAAAA==.',['璀璨']='璀璨的星:BAABLAAFFH8GAAIOAAYIOgAcSgBUAAAOAAYIOgAcSgBUAAAAAA==.',['甄子']='甄子丹:BAAALAAECgQIBQAAAA==.',['电疗']='电疗大师:BAAALAAECggIDgAAAA==.',['白六']='白六:BAAALAAECgYIBgAAAA==.',['白叁']='白叁:BAAALAAECgYIBgAAAA==.',['白开']='白开水:BAABLAAFFH8KAAIQAAIIYgdAIgCCAAAQAAIIYgdAIgCCAAAAAA==.',['白斩']='白斩鸡:BAABLAAFFH8GAAICAAIIcwxMWQA9AAACAAIIcwxMWQA9AAAAAA==.',['白昼']='白昼:BAAALAADCgIIAgAAAA==.',['白玖']='白玖:BAAALAAECgEIAQAAAA==.',['真的']='真的好笑:BAAALAAECgEIAQAAAA==.',['瞎玩']='瞎玩:BAABLAAFFH8JAAIdAAMIMAV6GgBbAAAdAAMIMAV6GgBbAAAAAA==.',['硪會']='硪會伈疼滒滒:BAAALAADCgIIAgAAAA==.',['祥子']='祥子:BAAALAAECgYIBgAAAA==.',['秋风']='秋风洁雪:BAAALAAECggICAAAAA==.',['科比']='科比布莱恩特:BAABLAAFFH8GAAIBAAIIHApUegCLAAABAAIIHApUegCLAAAAAA==.',['空白']='空白:BAABLAAFFH8sAAMOAAYIpyXmAwCdAgAOAAYIpyXmAwCdAgAWAAUINA9aFQAkAQABLAAFFAYIQgAOAFgjAA==.',['端木']='端木丶玉:BAAALAADCgMIAwAAAA==.',['簫半']='簫半仙:BAAALAADCgYIBgAAAA==.',['米奈']='米奈希尔夫人:BAAALAAECgYICQAAAA==.',['米拉']='米拉娜:BAAALAAECgMIBAAAAA==.',['米莉']='米莉亚姆:BAAALAAECgMIAwAAAA==.',['精钢']='精钢葫芦娃:BAAALAAECgYIBgAAAA==.',['系色']='系色望:BAAALAAECgEIAQAAAA==.',['索恩']='索恩都灵:BAAALAAECgIIAgAAAA==.',['紫幽']='紫幽岚:BAAALAAECgQIBAAAAA==.',['紫霞']='紫霞小魔仙:BAACLAAFFH8jAAMYAAYI4B8JBwBsAQAYAAUI+hwJBwBsAQAeAAQIAR2KDgAhAQAsAAQKfyIAAx4ABwj6IlwXAFwCAB4ABghQI1wXAFwCABgABAhGHTgrAEEBAAAA.',['红眼']='红眼病:BAAALAAFFAIIBAAAAA==.',['纳尼']='纳尼莫诺:BAAALAAFFAIIAgAAAA==.',['罗小']='罗小小猪:BAAALAAECgYICQAAAA==.',['美国']='美国人:BAABLAAFFH8KAAIXAAII6SEdCgDGAAAXAAII6SEdCgDGAAABLAAFFAUIGwALAMYcAA==.',['肥肚']='肥肚肚:BAAALAAECgUIBQAAAA==.',['胖潜']='胖潜:BAAALAAFFAIIAwAAAA==.',['胖虎']='胖虎:BAABLAAFFH8IAAIGAAII7w2FIgB5AAAGAAII7w2FIgB5AAAAAA==.',['胖达']='胖达:BAAALAAECgUIBwAAAA==.',['腐烂']='腐烂的苹果:BAAALAAFFAIIBAAAAA==.',['花花']='花花世界:BAAALAADCgYIBgAAAA==.',['苏妲']='苏妲己儿:BAAALAADCgYIBgAAAA==.',['莱茵']='莱茵丶:BAABLAAECn8VAAMBAAgIziKCMgCqAgABAAgIziKCMgCqAgAfAAEI3Q+GTwAsAAABLAAFFAUICwACAK0VAA==.',['葛温']='葛温:BAABLAAFFH8UAAIBAAUIEhVMQgAxAQABAAUIEhVMQgAxAQAAAA==.',['虫虫']='虫虫丶德:BAAALAADCgIIAgAAAA==.',['血罂']='血罂:BAAALAADCgIIAgAAAA==.',['行将']='行将就牧:BAAALAADCggIEAABLAAFFAYIOAAeAFQeAA==.',['见绮']='见绮鸣丶:BAABLAAFFH8aAAIBAAYI/x29EQDDAQABAAYI/x29EQDDAQAAAA==.',['说啥']='说啥也不奶:BAABLAAFFH8GAAIEAAIILRcuUAB7AAAEAAIILRcuUAB7AAABLAAFFAYIDgAOAOQUAA==.',['诺德']='诺德:BAAALAAECgQIBAAAAA==.',['调查']='调查员:BAAALAADCgUIBQAAAA==.',['谜团']='谜团:BAABLAAFFH8TAAIBAAYIdh+QGgDNAQABAAYIdh+QGgDNAQAAAA==.',['谢彬']='谢彬:BAAALAAECgMIAwAAAA==.',['谭雅']='谭雅丶:BAABLAAFFH8LAAICAAUIrRUtJwA2AQACAAUIrRUtJwA2AQAAAA==.',['贼拉']='贼拉风:BAAALAAECgYICAAAAA==.',['贾斯']='贾斯古杜明忙:BAAALAADCgIIAgAAAA==.',['赀楍']='赀楍財佱:BAAALAAECgEIAQAAAA==.',['赵老']='赵老师:BAAALAAECgYIBgAAAA==.',['超龄']='超龄老木:BAAALAAFFAIIBAAAAA==.超龄老沐:BAAALAAFFAIIBAAAAA==.',['跟我']='跟我一起来:BAAALAAECgEIAQAAAA==.',['达拉']='达拉斯牛仔:BAAALAAECgYICgAAAA==.',['过期']='过期回忆:BAABLAAFFH8HAAIJAAMIyBM4PwCRAAAJAAMIyBM4PwCRAAAAAA==.',['连环']='连环霜冻:BAAALAADCgMIAQAAAA==.',['迪猎']='迪猎:BAABLAAFFH8MAAIIAAYIIhUeNwBhAQAIAAYIIhUeNwBhAQAAAA==.',['迪诶']='迪诶池:BAAALAAECgcICwAAAA==.',['迷雾']='迷雾:BAABLAAFFH8IAAIRAAIIshBREQBuAAARAAIIshBREQBuAAAAAA==.',['那只']='那只丶胖熊猫:BAACLAAFFH8iAAIGAAYIKiDDBwDHAQAGAAYIKiDDBwDHAQAsAAQKfyAAAgYACAgyHn0QALkCAAYACAgyHn0QALkCAAAA.',['邪念']='邪念丶:BAAALAAECgYIBgAAAA==.',['邪恶']='邪恶降临:BAAALAAECgYIBgAAAA==.',['邪王']='邪王针眼:BAAALAAECgYICAAAAA==.',['酱样']='酱样子:BAAALAAECgIIAgAAAA==.',['铁头']='铁头娃:BAAALAAECgIIAgAAAA==.',['铁西']='铁西五虎龙少:BAAALAAECgYIBgAAAA==.',['长的']='长的丑活的久:BAAALAAECgYIEgAAAA==.',['閉月']='閉月:BAABLAAFFH8SAAIIAAUIHBCYUgAFAQAIAAUIHBCYUgAFAQAAAA==.',['闻言']='闻言:BAAALAADCgIIAgAAAA==.',['阿尔']='阿尔萨丝:BAABLAAECn8aAAIBAAcIgh/IPQCHAgABAAcIgh/IPQCHAgAAAA==.',['阿尼']='阿尼亚:BAAALAAECgYICgAAAA==.',['阿油']='阿油踹密密:BAAALAAECgYIBgAAAA==.',['随便']='随便奶奶拉:BAAALAAECggICgAAAA==.随便死死:BAAALAAECggIEAAAAA==.随便瞄瞄:BAAALAAECgMIAwAAAA==.随便跳跳:BAAALAAECgMIBAAAAA==.',['雾刃']='雾刃:BAAALAAECgYIDAAAAA==.',['青山']='青山原不老:BAABLAAFFH8kAAIEAAYIxhq3EQDWAQAEAAYIxhq3EQDWAQAAAA==.',['青椒']='青椒牛肉丝:BAAALAADCgYIBgAAAA==.',['青行']='青行灯:BAAALAAECgUIBQAAAA==.',['青霞']='青霞小魔仙:BAAALAADCgYICgAAAA==.',['香泥']='香泥乐堡杯:BAAALAADCgcIBwAAAA==.',['香蕉']='香蕉奶皮:BAAALAAECgYIBgAAAA==.',['高坚']='高坚果:BAAALAADCgEIAQAAAA==.',['高小']='高小宝丶:BAABLAAFFH8JAAIJAAYIQBAdLAA2AQAJAAYIQBAdLAA2AQAAAA==.',['高崔']='高崔克:BAAALAAECgQICAAAAA==.',['魏期']='魏期有病毒:BAAALAAECgYICQAAAA==.',['黄昏']='黄昏落叶时:BAAALAAECgYICwAAAA==.',['黄渤']='黄渤:BAABLAAECn8UAAIMAAYI4xAodwASAQAMAAYI4xAodwASAQAAAA==.',['黑夜']='黑夜的献诗:BAABLAAFFH8IAAICAAgIJB7uAwCrAgACAAgIJB7uAwCrAgAAAA==.',['黑龙']='黑龙歼灭太刀:BAAALAAECgEIAQAAAA==.',['龙之']='龙之千千矢:BAABLAAFFH8PAAIIAAYI5BxNIQCtAQAIAAYI5BxNIQCtAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end