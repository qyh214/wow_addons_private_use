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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','Shaman-Restoration','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Fury','Mage-Frost','Druid-Restoration','Druid-Balance','DemonHunter-Havoc','Warlock-Demonology','Hunter-Survival','Mage-Arcane','Evoker-Preservation','Evoker-Augmentation','Priest-Holy',}; local provider = {region='CN',realm='嚎风峡湾',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akanoth:BAABLAAECn8nAAQBAAgIvCJrBwDgAgACAAgIIyF7IADuAgABAAgIOh9rBwDgAgADAAgIMhpACQD+AQAAAA==.',Cr='Crazyz:BAACLAAFFH8NAAICAAUIBA76RAAnAQACAAUIBA76RAAnAQAsAAQKfxwAAgIABwi4EmhTAEwBAAIABwi4EmhTAEwBAAAA.',Ct='Ctmafk:BAACLAAFFH8hAAIEAAcIExYzDQBsAQAEAAcIExYzDQBsAQAsAAQKfykAAgQACAj4IZcVAMoCAAQACAj4IZcVAMoCAAAA.',Ji='Jianghe:BAAALAAECgUIBgAAAA==.',Ko='Korfax:BAACLAAFFH8IAAIFAAgIJgMHTgBeAAAFAAgIJgMHTgBeAAAsAAQKfyYABAUACAg3InATACoDAAUACAg3InATACoDAAYACAgVFw0dACcCAAcACAiHCAIhAAkBAAAA.',Sa='Sarmat:BAAALAAFFAIIBAAAAA==.',Sk='Sknduck:BAABLAAFFH8RAAMIAAMIOA5adAB3AAAJAAII3w/YJAB+AAAIAAMIuA1adAB3AAAAAA==.Skog:BAAALAAECgYIBgAAAA==.',So='Solong:BAAALAAECgYIBwAAAA==.',St='Starluv:BAAALAAECgYICAAAAA==.',['一如']='一如沐春风:BAAALAAECgIIBAAAAA==.',['一指']='一指流砂丶:BAAALAAFFAIIBAAAAA==.',['一火']='一火暴火乍一:BAAALAADCgQIBgAAAA==.',['一闪']='一闪一闪:BAAALAAECgYIBgAAAA==.',['不吃']='不吃折耳根:BAAALAAECgYIBgAAAA==.不吃犇肉:BAABLAAFFH8GAAIKAAYIWQXrKwADAQAKAAYIWQXrKwADAQAAAA==.',['交叉']='交叉火力网:BAAALAAECgYIBwAAAA==.交叉火力网丶:BAAALAAFFAIIBAAAAA==.',['亨特']='亨特儿:BAABLAAECn8WAAIIAAYIURXByAB0AQAIAAYIURXByAB0AQAAAA==.',['人间']='人间杀器:BAAALAADCgYIBgAAAA==.',['代理']='代理骑士:BAAALAAECgcIBwAAAA==.',['伴伴']='伴伴巧:BAAALAADCgYICAAAAA==.',['使徒']='使徒行者:BAACLAAFFH8dAAIFAAUITBOiKgArAQAFAAUITBOiKgArAQAsAAQKfyEAAgUABwgoHVc+AKEBAAUABwgoHVc+AKEBAAAA.',['俺不']='俺不会治疗:BAAALAAECgYIBgAAAA==.',['冬马']='冬马:BAAALAAFFAIIAgAAAA==.',['剁祂']='剁祂:BAAALAAFFAIIBAAAAA==.',['加尔']='加尔鲁什:BAAALAAECgUIBQAAAA==.',['卢彦']='卢彦祖丶:BAABLAAFFH8GAAIIAAYIpAnWRgAvAQAIAAYIpAnWRgAvAQAAAA==.',['吞吞']='吞吞:BAAALAAECgYIBgAAAA==.',['咄塔']='咄塔:BAAALAAECgYIBgAAAA==.',['啊雾']='啊雾雾三一:BAAALAAFFAQIAwAAAA==.啊雾雾三二:BAAALAAFFAYIAwAAAA==.',['塔莉']='塔莉萨:BAABLAAECn8XAAILAAYITRjUFwBnAQALAAYITRjUFwBnAQAAAA==.',['壹畝']='壹畝良田:BAABLAAFFH8MAAMMAAYInB1DFQCMAQAMAAUIvxtDFQCMAQANAAEIuQrSNAA7AAAAAA==.',['多塔']='多塔:BAAALAAFFAIIBAAAAA==.多塔零捌:BAAALAADCgIIAgAAAA==.',['天灬']='天灬仙儿:BAAALAAECgQIBAAAAA==.',['天神']='天神:BAACLAAFFH8NAAIKAAUIkQhKKwAMAQAKAAUIkQhKKwAMAQAsAAQKfxgAAgoACAhJFdk2AH0BAAoACAhJFdk2AH0BAAAA.',['奥都']='奥都都:BAAALAADCgIIAgAAAA==.',['如沐']='如沐春风:BAAALAAECgIIAgAAAA==.',['嫖正']='嫖正嗨:BAAALAAFFAIIAgAAAA==.',['安宝']='安宝宝:BAAALAADCgEIAQAAAA==.',['客官']='客官丶伍:BAAALAAECgYIDAAAAA==.',['小沐']='小沐头:BAAALAADCgQIBAAAAA==.',['尼斯']='尼斯纳沙比:BAAALAAFFAIIBAAAAA==.',['巴布']='巴布:BAAALAADCgUIBQAAAA==.',['幻听']='幻听:BAAALAAECgIIAwAAAA==.',['张伟']='张伟律师所:BAAALAAECgYICwAAAA==.',['惡魔']='惡魔猎手:BAABLAAFFH8MAAIOAAYI1A/LIgByAQAOAAYI1A/LIgByAQAAAA==.惡魔獵手:BAABLAAFFH8GAAIOAAIIUg74VACHAAAOAAIIUg74VACHAAAAAA==.',['戦无']='戦无不勝:BAAALAAFFAQIBAAAAA==.',['无涯']='无涯:BAAALAAECgYICwAAAA==.',['日妮']='日妮仙人:BAAALAADCgIIAgAAAA==.',['星野']='星野:BAABLAAFFH8FAAIIAAII0RZETgCXAAAIAAII0RZETgCXAAAAAA==.',['有角']='有角男:BAABLAAFFH8IAAIIAAIIBhOcmgBAAAAIAAIIBhOcmgBAAAAAAA==.',['村姑']='村姑妹:BAAALAAECggIDgAAAA==.',['杨益']='杨益丹:BAAALAAFFAIIAgAAAA==.',['櫻花']='櫻花入夢:BAABLAAFFH8RAAMMAAYI9RpxGABtAQAMAAUIwxhxGABtAQANAAEIqAxeMwA9AAAAAA==.',['欧尼']='欧尼酱大笨蛋:BAAALAADCgIIAgAAAA==.',['死神']='死神的梦魇:BAACLAAFFH8GAAIPAAIIlAo5HACHAAAPAAIIlAo5HACHAAAsAAQKfxkAAg8ABwigEqA0AJoBAA8ABwigEqA0AJoBAAAA.',['浪浪']='浪浪山小妖怪:BAAALAAFFAIIAgAAAA==.',['淡淡']='淡淡:BAAALAAECggICAAAAA==.',['烟雨']='烟雨霓裳:BAACLAAFFH8PAAIIAAYI5w7pPgBKAQAIAAYI5w7pPgBKAQAsAAQKfx0AAggACAhdHfKDANcBAAgACAhdHfKDANcBAAAA.',['爱看']='爱看你的样子:BAABLAAFFH8GAAICAAQIohQxUADdAAACAAQIohQxUADdAAAAAA==.',['牛油']='牛油果味奶砖:BAAALAAFFAMIAwAAAA==.',['牛牛']='牛牛犇犇:BAAALAADCgYIBwAAAA==.',['物喜']='物喜:BAAALAAFFAIIBAAAAA==.',['神奇']='神奇宝贝大师:BAAALAAECggIAwABLAAFFAcINQAIACkZAA==.',['等一']='等一一长大:BAAALAAFFAIIBAAAAA==.',['红祭']='红祭:BAAALAAECgIIAgAAAA==.',['老哞']='老哞:BAAALAAECgMIAwAAAA==.',['肆叁']='肆叁贰壹:BAAALAAECgQIBAAAAA==.',['背锅']='背锅侠:BAABLAAFFH8FAAMIAAMIQxBWLADQAAAIAAMIQxBWLADQAAAQAAEIhgZwCABJAAAAAA==.',['脆皮']='脆皮法式筒:BAABLAAFFH8JAAIRAAIIWBDaSQCWAAARAAIIWBDaSQCWAAAAAA==.',['舒克']='舒克和贝塔:BAAALAAECgYICAAAAA==.',['茶花']='茶花開:BAABLAAFFH8IAAMSAAYI0At2EQALAQASAAUIGgp2EQALAQATAAEI8AHjEAA3AAAAAA==.',['萝莉']='萝莉正义:BAABLAAFFH8KAAIUAAMIzwbNHgDFAAAUAAMIzwbNHgDFAAAAAA==.',['萬物']='萬物生:BAABLAAFFH8GAAMMAAQIfxezMgCfAAAMAAMIaxSzMgCfAAANAAEI5ASHOQA0AAAAAA==.',['萬畝']='萬畝花開:BAABLAAFFH8SAAMMAAYIMB9sEADAAQAMAAUI3R9sEADAAQANAAEI0w+LMQA/AAAAAA==.',['落跑']='落跑老新娘:BAAALAAECgEIAQAAAA==.',['血腥']='血腥上帝:BAAALAAECgYIBgAAAA==.',['血莫']='血莫有兮:BAAALAADCgcIBwAAAA==.',['行咧']='行咧:BAAALAAECgEIAQAAAA==.',['费尔']='费尔北多:BAAALAAFFAIIAgAAAA==.',['踢你']='踢你嗷丶狐丁:BAAALAAECgYIBgAAAA==.',['银月']='银月城名媛:BAAALAAECgYIBgAAAA==.',['阿丘']='阿丘达:BAAALAADCgQIBAAAAA==.',['香精']='香精煎鱼:BAABLAAFFH8SAAICAAMI0w+0MQDVAAACAAMI0w+0MQDVAAAAAA==.',['鸽鸽']='鸽鸽叫咕咕:BAABLAAFFH8MAAMMAAYIMht0DQAiAQAMAAQI+xd0DQAiAQANAAMIbgynFgCsAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end