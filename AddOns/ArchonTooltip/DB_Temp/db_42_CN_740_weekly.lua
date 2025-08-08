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
 local lookup = {'Hunter-Marksmanship','Unknown-Unknown','DemonHunter-Vengeance','Paladin-Protection','Paladin-Retribution','Mage-Arcane','Warrior-Fury','Warrior-Arms','Druid-Guardian','Paladin-Holy','DeathKnight-Unholy','Hunter-BeastMastery','Priest-Holy','Priest-Shadow','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','Druid-Balance','Monk-Windwalker','Warrior-Protection','Druid-Restoration','DeathKnight-Frost','Priest-Discipline','Shaman-Restoration','Shaman-Elemental',}; local provider = {region='CN',realm='火喉',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Asahi:BAAAKgAECgIIAgAAAA==.Asassainq:BAAAKgAECgYIDAAAAA==.',Do='Doomhunter:BAAAKgAECgYICAAAAA==.',Ho='Holyhigh:BAEBKgAFFH8GAAIBAAYInx25DwBqAQABAAYInx25DwBqAQABKgAFFAgIAgACAAAAAA==.',Ic='Iceiceice:BAAAKgAFFAQIBAAAAA==.',Im='Imshaman:BAAAKgAECggICgAAAA==.',Ki='Kisslucky:BAAAKgADCgMIAwAAAA==.',Le='Lepriest:BAAAKgAECgUIBgAAAA==.',Li='Lilian:BAAAKgAECgMIBQAAAA==.',Lo='Lolv:BAAAKgAECggICgAAAA==.Loridad:BAAAKgAFFAQIBAAAAA==.Lostparadise:BAAAKgADCggICAAAAA==.',Va='Vanilla:BAAAKgADCgYIBwAAAA==.',['一剑']='一剑西來:BAAAKgAFFAEIAQAAAA==.',['不死']='不死大腿:BAAAKgAECgYIBwAAAA==.',['不稳']='不稳定的心能:BAAAKgAFFAIIAgAAAA==.',['与世']='与世无争:BAAAKgAECgUIBQAAAA==.',['丶萌']='丶萌你一脸:BAAAKgAECgMIAwAAAA==.',['乐乐']='乐乐:BAAAKgAFFAQIBAAAAA==.',['伊吹']='伊吹萃香:BAAAKgAFFAIIAgAAAA==.',['何琪']='何琪琪:BAAAKgAECgYICAAAAA==.',['兜兜']='兜兜爱跳舞:BAABKgAECn8XAAIDAAcITAhjQQCrAAADAAcITAhjQQCrAAAAAA==.',['再见']='再见小时候:BAAAKgAECgUIBQAAAA==.',['冽冬']='冽冬将至:BAAAKgAFFAIIAgAAAA==.',['初春']='初春饰利:BAACKgAFFH8PAAIEAAUIUBMcCADeAAAEAAUIUBMcCADeAAAqAAQKfysAAgQACAipHoUMAD8CAAQACAipHoUMAD8CAAAA.',['力丸']='力丸:BAAAKgAECgUIBQAAAA==.',['半夏']='半夏的留念:BAAAKgAECgIIAgAAAA==.',['卡卡']='卡卡小白:BAAAKgAFFAIIAgABKgAFFAgIDgAFACocAA==.卡卡蜀道山:BAAAKgAFFAQIBAAAAA==.卡卡霸道婷哥:BAAAKgAFFAYIBAAAAA==.',['卡西']='卡西奥佩娅:BAABKgAFFH8GAAIGAAYIFRpKDgCCAQAGAAYIFRpKDgCCAQAAAA==.',['卡里']='卡里古拉:BAAAKgAECgEIAQAAAA==.',['叫我']='叫我亚瑟:BAAAKgAFFAYIBAAAAA==.',['吹牛']='吹牛女公子:BAABKgAECn8nAAMHAAgIzx+EDgBvAgAHAAgIzB+EDgBvAgAIAAYIaximIgBxAQAAAA==.',['呐男']='呐男的:BAAAKgAECgIIAgAAAA==.',['哼哼']='哼哼的哼:BAAAKgAECggICgAAAA==.',['啊傻']='啊傻:BAAAKgAECgYIBwAAAA==.',['嗷呜']='嗷呜:BAABKgAFFH8IAAIJAAMIfQvfCQByAAAJAAMIfQvfCQByAAAAAA==.',['国服']='国服男枪:BAABKgAFFH8KAAIBAAYIlRYMEgBTAQABAAYIlRYMEgBTAQAAAA==.',['圣光']='圣光去哪了:BAABKgAFFH8GAAIFAAYI9BgFGgCQAQAFAAYI9BgFGgCQAQAAAA==.',['壹尒']='壹尒仐糸:BAABKgAFFH8VAAIKAAcIuRxMBACbAQAKAAcIuRxMBACbAQAAAA==.',['夜杀']='夜杀狂:BAABKgAFFH8IAAIGAAgI2Q4tCQDhAQAGAAgI2Q4tCQDhAQAAAA==.',['大腿']='大腿吱吱:BAAAKgAECgYIBgAAAA==.',['奇妙']='奇妙冰法:BAAAKgAFFAEIAQAAAA==.',['姐姐']='姐姐下班我接:BAAAKgAECggICAAAAA==.',['完美']='完美舞步:BAAAKgADCgcIBwAAAA==.',['小八']='小八:BAAAKgAFFAgIAgAAAA==.',['小呆']='小呆立:BAEAKgAECgYIBgABKgAFFAgIAgACAAAAAA==.',['小拳']='小拳拳锤胸胸:BAAAKgAECgUICQAAAA==.',['小猫']='小猫老师:BAAAKgAECggIDgABKgAFFAgIDwALALYgAA==.',['小龙']='小龙:BAAAKgAECgIIAgAAAA==.',['巨石']='巨石强森:BAACKgAFFH8ZAAMBAAYIfRWYCwBUAQABAAYIkBSYCwBUAQAMAAQI+BnTEwDxAAAqAAQKfzYAAwEACAgmIaIbAB0CAAEACAjPHKIbAB0CAAwABAguI95FAJABAAAA.',['帅比']='帅比无敌发丝:BAACKgAFFH8VAAIGAAQI+xkQBACgAAAGAAQI+xkQBACgAAAqAAQKfzQAAgYACAgqISYOAIoCAAYACAgqISYOAIoCAAAA.',['废蛙']='废蛙丶:BAABKgAFFH8FAAMNAAUI8At+DwDDAAANAAQIEwx+DwDDAAAOAAEI6x1tJwBWAAAAAA==.',['性能']='性能狂潮:BAAAKgAECggIDwAAAA==.',['恶魔']='恶魔安娜:BAAAKgAECgcIBwAAAA==.恶魔红叶:BAAAKgAECggICAAAAA==.恶魔翼贰一:BAAAKgAECgUICAAAAA==.恶魔贞德:BAAAKgAFFAQIBAAAAA==.',['我不']='我不会喝酒:BAAAKgADCgYIBgAAAA==.',['我藏']='我藏好了:BAACKgAFFH8QAAMPAAQIghxvDwCoAAAPAAMImRdvDwCoAAAQAAQILxfTHwCSAAAqAAQKfysABBAACAgCJGUHALUCABAACAgCJGUHALUCAA8AAgiTISApALUAABEAAgglGs5wAEoAAAAA.',['打蛋']='打蛋揉面粉:BAAAKgAECgcICAAAAA==.',['星星']='星星骑士:BAABKgAFFH8FAAIKAAQITREbCADVAAAKAAQITREbCADVAAAAAA==.',['暮幽']='暮幽:BAAAKgAFFAIIAgAAAA==.',['暴虐']='暴虐的灬华光:BAAAKgAECgUIBQABKgAFFAYIBgACAAAAAA==.',['曹丕']='曹丕:BAAAKgADCggICAAAAA==.',['最爱']='最爱彩虹糖:BAABKgAFFH8GAAISAAYIbA3MEwADAQASAAYIbA3MEwADAQABKgAFFAgIDQAFAOEYAA==.',['月光']='月光幼儿园:BAABKgAFFH8HAAITAAQIswgbQwChAAATAAQIswgbQwChAAABKgAFFAgIHAANANkiAA==.',['月影']='月影魂殇:BAAAKgAECggIBwAAAA==.',['杰森']='杰森斯坦森:BAACKgAFFH8MAAIFAAQIPyQEGgAWAQAFAAQIPyQEGgAWAQAqAAQKf1cAAwUACAhoJtkJAPMCAAUACAhoJtkJAPMCAAQABwgeJJAKAE0CAAAA.',['池田']='池田天天:BAAAKgAECgcIBwAAAA==.',['淡若']='淡若清风:BAAAKgADCgIIAgAAAA==.',['烈焰']='烈焰洪拳:BAAAKgAECgUICAAAAA==.',['熊猫']='熊猫人还迷:BAABKgAECn8UAAIUAAgIsh3PEQApAgAUAAgIsh3PEQApAgAAAA==.',['熟睡']='熟睡的丈夫:BAAAKgADCgEIAQAAAA==.',['燃烧']='燃烧的双刀:BAAAKgAECggICQAAAA==.',['玛格']='玛格战神:BAABKgAFFH8WAAIVAAQIVgTyEQBtAAAVAAQIVgTyEQBtAAAAAA==.',['生死']='生死有命:BAAAKgAECgMIAwAAAA==.',['疾风']='疾风冷:BAAAKgAECgEIAQAAAA==.',['神圣']='神圣蛙:BAAAKgADCggICAAAAA==.',['约翰']='约翰塞纳:BAACKgAFFH8UAAMLAAYIQRYuEgCIAQALAAYIQRYuEgCIAQASAAQIJQVRKwBoAAAqAAQKfxUAAwsACAgnIuUQAJ4CAAsACAgnIuUQAJ4CABIABAgCGowuANwAAAAA.',['纯情']='纯情丶大表哥:BAAAKgAFFAIIAwAAAA==.',['纯爱']='纯爱赛高:BAAAKgAECgUIBQAAAA==.',['美女']='美女騎士:BAABKgAFFH8FAAIEAAII/wBoGAA5AAAEAAII/wBoGAA5AAAAAA==.',['翘班']='翘班小王子:BAAAKgAECgIIBQAAAA==.',['老大']='老大当会计:BAAAKgADCgQICQAAAA==.',['老肥']='老肥:BAAAKgAFFAMIAwAAAA==.',['苍雪']='苍雪:BAABKgAFFH8YAAIOAAYI/iPuBQDRAQAOAAYI/iPuBQDRAQABKgAFFAgIBgAWAOUQAA==.',['范海']='范海辛:BAAAKgADCgIIAgAAAA==.',['范迪']='范迪塞尔:BAACKgAFFH8HAAIIAAQISw21GgC1AAAIAAQISw21GgC1AAAqAAQKfxoAAwgACAgGGQ0VAOYBAAgACAjVGA0VAOYBABUABwjCDt8mAPUAAAAA.',['莫名']='莫名的忧伤:BAABKgAECn8gAAMIAAgIRiE/DwArAgAIAAgIcx8/DwArAgAHAAgIVBsUHwAfAgABKgAFFAgIEwAIAE0hAA==.',['萨昂']='萨昂:BAAAKgADCgYIBgAAAA==.',['血破']='血破军:BAAAKgAECgcICgAAAA==.',['西北']='西北望射天狼:BAABKgAECn8xAAMBAAgI6hQHMwCRAQABAAgIuhQHMwCRAQAMAAYI0A4ciQAeAQAAAA==.',['西西']='西西比怒牛:BAAAKgAFFAIIAgAAAA==.',['詺門']='詺門鑫尐:BAABKgAFFH8PAAMHAAYITSLoAgCOAQAHAAYI9R7oAgCOAQAIAAEIWCFMFQBnAAABKgAFFAgIEQABAPEhAA==.',['记忆']='记忆似手中水:BAAAKgAECgIIAgAAAA==.',['谈影']='谈影空人心:BAABKgAFFH8OAAINAAgIwBXpAwAPAgANAAgIwBXpAwAPAgAAAA==.',['贪丨']='贪丨嗔丨痴:BAAAKgAFFAYIBgAAAA==.',['身高']='身高定战斗力:BAACKgAFFH8FAAIQAAMIqxlnEgDbAAAQAAMIqxlnEgDbAAAqAAQKfyUABBAACAiEHvcfAAUCABAACAiEHvcfAAUCABEAAwgUGVpvAE4AAA8AAQi0E7dIAC0AAAAA.',['轻描']='轻描淡写灬肆:BAAAKgAECgIIAgAAAA==.',['辛辛']='辛辛虫:BAACKgAFFH8IAAINAAgI8w4fBgCrAQANAAgI8w4fBgCrAQAqAAQKfxYAAg0ACAheGP8ZAPEBAA0ACAheGP8ZAPEBAAAA.',['达达']='达达馥裕:BAAAKgAFFAQIAgAAAA==.',['醉爱']='醉爱红尘:BAACKgAFFH8PAAMMAAMIIhS1GgDBAAAMAAMIIhS1GgDBAAABAAEI4QM3KwAlAAAqAAQKfyEAAgwACAi+HpYfAHkCAAwACAi+HpYfAHkCAAAA.',['门口']='门口干涉:BAAAKgAECggIDgAAAA==.',['阳光']='阳光下的温柔:BAAAKgADCggICQAAAA==.',['限量']='限量版灬绝情:BAABKgAECn8VAAMXAAgIHxgFDQDYAQAXAAgIHxgFDQDYAQALAAMILwdTpwBHAAAAAA==.',['陶大']='陶大奋:BAABKgAECn8iAAMNAAgIHBppJQC9AQANAAgIHBppJQC9AQAYAAIIJwu1mAAlAAABKgAFFAgIQAAZAJ8jAA==.',['面对']='面对我的宠物:BAAAKgADCgcIBwAAAA==.',['顶住']='顶住我先撤:BAAAKgADCgYIBgAAAA==.',['飘杨']='飘杨的蒲公英:BAACKgAFFH8JAAISAAQIkQnOFwCTAAASAAQIkQnOFwCTAAAqAAQKfyIAAhIACAhEHO4QACoCABIACAhEHO4QACoCAAAA.',['飞天']='飞天熊猫:BAABKgAECn8cAAIZAAgIihfmEgCsAQAZAAgIihfmEgCsAQAAAA==.',['骑豬']='骑豬玩漂移:BAAAKgADCgUIBQAAAA==.',['麦乐']='麦乐:BAACKgAFFH8QAAMZAAcI9guHGQAaAQAZAAQI4AqHGQAaAQAaAAMIjh2ODQD+AAAqAAQKfykAAxoACAh0GGMbAO0BABoACAh0GGMbAO0BABkACAiLCcxrAOkAAAAA.',['黑铁']='黑铁战神:BAABKgAECn8dAAIVAAgItAe+KwDTAAAVAAgItAe+KwDTAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end