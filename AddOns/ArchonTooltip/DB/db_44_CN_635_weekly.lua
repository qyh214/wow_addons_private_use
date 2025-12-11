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
 local lookup = {'Druid-Restoration','DemonHunter-Havoc','Mage-Frost','Mage-Arcane','Shaman-Restoration','DeathKnight-Frost','Rogue-Subtlety','Warlock-Destruction','Warrior-Fury','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','DemonHunter-Vengeance','Paladin-Retribution','Evoker-Devastation','Priest-Holy','Priest-Shadow','Mage-Fire','Paladin-Holy','Rogue-Assassination',}; local provider = {region='CN',realm='夺灵者',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alona:BAAALAAECgcIDgAAAA==.',Bo='Boxer:BAABLAAFFH8KAAIBAAYIbCP6BABnAgABAAYIbCP6BABnAgAAAA==.',Br='Brix:BAAALAAECgUIBQAAAA==.',Dc='Dclk:BAAALAADCgIIAgAAAA==.',Dh='Dhqaq:BAABLAAFFH8MAAICAAYIRCDcDQD1AQACAAYIRCDcDQD1AQAAAA==.',Dr='Dreamgg:BAABLAAFFH8LAAMDAAMIbQ8wDQCGAAADAAMIbQ8wDQCGAAAEAAII4QG1bAASAAAAAA==.',Gi='Gigabyte:BAACLAAFFH8OAAIFAAMIIg18LQCnAAAFAAMIIg18LQCnAAAsAAQKfzEAAgUACAh4H9IhAIwCAAUACAh4H9IhAIwCAAAA.',St='Steinsgate:BAABLAAECn8rAAIGAAgI0h4kGgAbAgAGAAgI0h4kGgAbAgAAAA==.',Xi='Xiaowangovo:BAABLAAFFH8iAAIHAAYIICN7AwD0AQAHAAYIICN7AwD0AQAAAA==.',['一且']='一且聽風吟一:BAAALAADCggICAAAAA==.',['一陣']='一陣風:BAAALAADCgEIAgAAAA==.',['丁满']='丁满:BAAALAAFFAIIBAAAAA==.',['不吃']='不吃洋葱:BAAALAAFFAIIBAAAAA==.不吃牛肉:BAAALAADCgIIAgAAAA==.',['丰川']='丰川祥子:BAABLAAFFH8HAAIIAAYIdxSIKQB0AQAIAAYIdxSIKQB0AQAAAA==.',['丹妮']='丹妮莉丝:BAABLAAFFH8FAAIJAAUIch1MIwBTAQAJAAUIch1MIwBTAQAAAA==.',['五谷']='五谷丰登:BAABLAAFFH8FAAIBAAIIgQsnSwBbAAABAAIIgQsnSwBbAAAAAA==.',['从小']='从小就会玩:BAAALAAFFAYIBAAAAA==.从小就很浪:BAABLAAFFH8FAAMKAAUIaA2RHwAKAQAKAAQIrg6RHwAKAQALAAEITwgVMwBKAAAAAA==.',['伊小']='伊小德:BAAALAAECgMIAwAAAA==.',['伊尼']='伊尼达雷:BAAALAAECgYICAAAAA==.',['你什']='你什么袋鳄人:BAAALAAECgcIDgAAAA==.',['佳莉']='佳莉亚丨风影:BAABLAAECn8zAAIKAAgI5RnxVAA0AgAKAAgI5RnxVAA0AgAAAA==.佳莉亚丶星语:BAAALAADCggICAAAAA==.',['八岁']='八岁治好脚气:BAABLAAFFH8IAAIKAAIIcBnTjABGAAAKAAIIcBnTjABGAAAAAA==.',['八零']='八零小骑士:BAAALAAECgEIAQAAAA==.',['凯尔']='凯尔:BAABLAAFFH8GAAIMAAIIgwlbHABrAAAMAAIIgwlbHABrAAAAAA==.',['加肥']='加肥猫:BAAALAAECgYIDAAAAA==.',['只会']='只会心疼妹妹:BAAALAAFFAYIBAAAAA==.',['叶灬']='叶灬傾云:BAAALAAECgEIAQAAAA==.',['吉萨']='吉萨轻浮:BAABLAAFFH8IAAINAAIIIwI8GwAcAAANAAIIIwI8GwAcAAAAAA==.',['吾亦']='吾亦凡图斯:BAABLAAFFH8gAAIIAAgI6Ry8CQBkAgAIAAgI6Ry8CQBkAgAAAA==.',['呆大']='呆大王:BAABLAAFFH8IAAILAAIIvxE5IQCGAAALAAIIvxE5IQCGAAAAAA==.',['哪版']='哪版龙都超神:BAAALAAECgYIBgAAAA==.',['嗡嗡']='嗡嗡:BAAALAAECgcICgAAAA==.',['圣光']='圣光咏叹调:BAABLAAFFH8OAAIOAAYIuBYLIgBcAQAOAAYIuBYLIgBcAQAAAA==.',['圣斗']='圣斗乳:BAAALAADCggICAAAAA==.',['媿聖']='媿聖迋鍺:BAAALAAFFAIIBAAAAA==.',['孤独']='孤独失败:BAAALAAECgYIDAAAAA==.',['小城']='小城夏天:BAAALAAECgYIBgAAAA==.',['尼古']='尼古丁真:BAABLAAFFH8gAAIIAAgIpBw2CgBcAgAIAAgIpBw2CgBcAgAAAA==.',['巴赫']='巴赫穆特:BAAALAAECgYIBgAAAA==.',['布洛']='布洛芬:BAABLAAFFH8FAAIOAAQILBm4MQD1AAAOAAQILBm4MQD1AAAAAA==.',['幻雪']='幻雪梨落:BAAALAAFFAIIAgAAAA==.',['强人']='强人锁侽:BAABLAAFFH8IAAIGAAIIzxu4eABJAAAGAAIIzxu4eABJAAAAAA==.',['忘卻']='忘卻的記憶:BAAALAAECgYIBgAAAA==.',['快樂']='快樂:BAABLAAECn8ZAAIGAAcIgx2BPACMAQAGAAcIgx2BPACMAQAAAA==.',['恩灿']='恩灿:BAAALAAECgUICgAAAA==.',['恶魔']='恶魔的深渊:BAAALAAECgYIBwAAAA==.',['悠幽']='悠幽百合:BAAALAAECgYIDQAAAA==.',['愤怒']='愤怒大南瓜:BAAALAAECgYIBgAAAA==.愤怒风暴:BAAALAADCgcIBwAAAA==.',['我忘']='我忘了:BAAALAADCgEIAQAAAA==.我忘却了:BAAALAAECgIIAwAAAA==.',['戦瀟']='戦瀟娪:BAAALAADCgIIAgAAAA==.戦瀟颯:BAABLAAECn8jAAIPAAgIvwqsFwA+AQAPAAgIvwqsFwA+AQAAAA==.',['扑尼']='扑尼個佳:BAAALAAECgYIBwAAAA==.',['无劫']='无劫:BAAALAAECgYIDAABLAAFFAMICwADAG0PAA==.',['星辰']='星辰的旋律:BAAALAAECgYIBgAAAA==.',['智取']='智取契襦:BAAALAAECgUIBQAAAA==.',['月夜']='月夜无月:BAABLAAFFH8QAAMEAAYIWiCuHABbAQAEAAYIWiCuHABbAQADAAII4RCNEwCHAAAAAA==.月夜杀机:BAAALAAFFAIIBAAAAA==.',['果果']='果果小宝:BAABLAAFFH8GAAIIAAYIhxFsDgD2AQAIAAYIhxFsDgD2AQAAAA==.',['桃桃']='桃桃的意志:BAAALAAECgYIBgAAAA==.',['森林']='森林狼:BAAALAADCgUIBQAAAA==.',['欧气']='欧气腾飞:BAAALAAECgYICAAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8oAAMQAAgIKiDFBACGAgAQAAcIVyDFBACGAgARAAQInBbfEQBOAQABLAAFFAgIpAAQAAUkAA==.',['沃利']='沃利贝尔:BAAALAADCggICAAAAA==.',['海棠']='海棠无香:BAACLAAFFH8GAAIMAAII1QafIAAqAAAMAAII1QafIAAqAAAsAAQKfxoAAwwABgjVFkkcAC4BAAwABgjVFkkcAC4BAA4AAwjuAg51AUwAAAAA.',['深渊']='深渊代行者:BAAALAAECggICQAAAA==.',['深秋']='深秋的落叶:BAAALAADCgIIAgAAAA==.',['清蒸']='清蒸白菜:BAAALAADCgEIAQAAAA==.',['温蕾']='温蕾萨风行者:BAAALAAECgcIBgAAAA==.',['滴血']='滴血龙牙:BAAALAAFFAIIAgAAAA==.',['燃烧']='燃烧的大腿:BAAALAAECgYIDQAAAA==.',['牛儿']='牛儿当横行:BAAALAAECgMIAwAAAA==.',['牛气']='牛气冲天:BAAALAAECgIIAgAAAA==.',['牛马']='牛马头子:BAAALAAECgYIBgAAAA==.',['狂冰']='狂冰导师:BAAALAAECgUIBQAAAA==.',['玄骨']='玄骨上人:BAAALAAECgEIAQAAAA==.',['琪莎']='琪莎拉:BAABLAAFFH8FAAIIAAUI7wrmPQAHAQAIAAUI7wrmPQAHAQAAAA==.',['申智']='申智:BAAALAADCgEIAQAAAA==.',['皇家']='皇家龍騎:BAAALAAECgYICwAAAA==.',['童童']='童童爱吃汉堡:BAAALAAECgMIAwAAAA==.',['老司']='老司机:BAAALAADCgcIBwAAAA==.',['芙莉']='芙莉莲:BAACLAAFFH8iAAMEAAYIoyGRGgCCAQAEAAUI3SCRGgCCAQASAAIIiRi3BgCpAAAsAAQKfx4AAwQACAjdJPQpAKUCAAQABwiEJfQpAKUCABIAAQhPIMobAFsAAAAA.',['血之']='血之哀伤:BAAALAAECgEIAQAAAA==.',['请勿']='请勿调戏喂食:BAAALAADCgEIAQAAAA==.',['谭三']='谭三姐:BAAALAAECgEIAQAAAA==.谭三爷:BAABLAAECn8XAAMDAAgIYB7mHgAkAgADAAgIYB7mHgAkAgAEAAYImA7tPgAQAQAAAA==.',['超越']='超越时间:BAAALAAECgYIAgAAAA==.',['车是']='车是一下:BAABLAAECn8hAAMTAAYIZhdfMwCcAQATAAYIZhdfMwCcAQAOAAEI9wKR8wAcAAAAAA==.',['辕门']='辕门射戟:BAABLAAFFH8GAAIKAAIIDBpzjQBGAAAKAAIIDBpzjQBGAAAAAA==.',['还是']='还是不会玩:BAABLAAFFH8HAAIUAAcIVRnbAwAJAgAUAAcIVRnbAwAJAgAAAA==.',['长沙']='长沙黄宗泽:BAAALAADCgQIBAAAAA==.',['阴木']='阴木:BAAALAAECgYIBgAAAA==.',['雪慕']='雪慕谰:BAAALAADCgEIAQAAAA==.',['雪雪']='雪雪女王大人:BAAALAAECgIIAgAAAA==.',['风不']='风不等你咯:BAAALAAECgEIAQAAAA==.',['风行']='风行者:BAAALAADCggICAAAAA==.',['飛天']='飛天龍:BAAALAAECgYIBgAAAA==.',['黄泉']='黄泉判官:BAAALAAECgUIBQAAAA==.黄泉孟婆:BAAALAAECgUIBQAAAA==.黄泉白无常:BAAALAAECgYICAAAAA==.黄泉黑无常:BAAALAAECgYIDQAAAA==.',['黎明']='黎明的晨星:BAAALAAECggICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end