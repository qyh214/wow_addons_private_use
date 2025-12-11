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
 local lookup = {'DeathKnight-Frost','Rogue-Assassination','Rogue-Subtlety','Warrior-Protection','Warrior-Fury','Mage-Frost','Priest-Holy','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Elemental','Shaman-Restoration','Mage-Arcane','Paladin-Holy','Priest-Discipline','DemonHunter-Havoc','Warlock-Demonology','Paladin-Retribution','Mage-Fire','Unknown-Unknown','Warlock-Destruction',}; local provider = {region='CN',realm='古达克',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alecto:BAAALAAFFAEIAQAAAA==.Algebra:BAABLAAFFH8HAAIBAAIIag6+dwCMAAABAAIIag6+dwCMAAAAAA==.',As='Ashadow:BAACLAAFFH8JAAMCAAMIrRArFgCLAAACAAMIFwwrFgCLAAADAAEI3RTSHQA/AAAsAAQKfyAAAwMABgjFHC0aAMYBAAMABgjQGi0aAMYBAAIABQhLGLY8AGUBAAAA.',Ba='Barbarian:BAAALAADCgMIAwAAAA==.',Bu='Bunny:BAAALAAECgIIAgAAAA==.',Ci='Cibo:BAAALAAECgEIAQAAAA==.Ciri:BAABLAAECn8VAAMEAAYIiRWMIwAqAQAEAAYIGBWMIwAqAQAFAAQIPRKaugAIAQAAAA==.',Dr='Dryad:BAAALAADCgEIAQAAAA==.',Ds='Dsj:BAAALAAECgUIBgAAAA==.',Eu='Eunomia:BAABLAAECn8UAAIGAAYI5RZYHQA1AQAGAAYI5RZYHQA1AQAAAA==.',Ff='Ffork:BAABLAAFFH8QAAIHAAIIvBYmLQCSAAAHAAIIvBYmLQCSAAAAAA==.',Go='Goosh:BAABLAAFFH8GAAMIAAYIiQg2JQDwAAAIAAUI1Qg2JQDwAAAJAAEIJhkxLwBDAAAAAA==.',Gr='Groot:BAAALAAECgYIBgAAAA==.',Ji='Jinx:BAAALAAFFAIIBAAAAA==.',Jo='Johnathon:BAAALAAECgEIAQAAAA==.',Mo='Moomoo:BAAALAAECgEIAQAAAA==.',Pl='Playergqnlij:BAAALAAECgIIAgAAAA==.',Ra='Rane:BAAALAAECgIIAwAAAA==.',Ro='Roronoazoro:BAAALAADCgMIAwAAAA==.',Sx='Sxyang:BAAALAADCgMIAwAAAA==.',Th='Theia:BAAALAAECgEIAQAAAA==.',Tq='Tqy:BAAALAAECgQIAgAAAA==.',Va='Valerie:BAAALAAECgUIBQAAAA==.',['一刀']='一刀贼:BAABLAAFFH8SAAMDAAUINxMcCwDjAAACAAUI6hJgDQA3AQADAAQIyBAcCwDjAAAAAA==.',['上古']='上古战神要水:BAAALAADCgcIBwAAAA==.',['不想']='不想做任务:BAAALAADCgIIAgAAAA==.',['丧家']='丧家之犬:BAAALAAFFAQIBAAAAA==.',['丧彪']='丧彪:BAAALAAECgYIBgAAAA==.',['丨加']='丨加菲猫丶:BAAALAAECgYIBgAAAA==.',['为了']='为了灰烬:BAAALAADCgUIBQAAAA==.',['为时']='为时已晚:BAAALAAECgYIBgAAAA==.',['井芹']='井芹仁菜:BAABLAAECn8XAAMKAAcIsReDTwB4AQAKAAcIfxSDTwB4AQALAAYIdBYNygByAQAAAA==.',['亣煞']='亣煞霹:BAAALAADCgQIBAAAAA==.',['亲丨']='亲丨宝贝蛋儿:BAAALAAECgMIAwAAAA==.亲丨宝贝蛋蛋:BAAALAAECgQIBAAAAA==.',['付付']='付付:BAAALAADCgYIBgAAAA==.',['仙之']='仙之下我无敌:BAAALAAFFAMIAwAAAA==.',['克罗']='克罗玛什:BAACLAAFFH8kAAMMAAYIVBVrGAB6AQAMAAYIVBVrGAB6AQANAAMIvApyRgCSAAAsAAQKfx0AAgwACAj6GuoQACwCAAwACAj6GuoQACwCAAAA.',['冰冻']='冰冻的邪恶:BAAALAAECgEIAQAAAA==.',['冷月']='冷月飞霜:BAAALAAECgYICgAAAA==.',['冷熱']='冷熱:BAAALAAECgIIAgAAAA==.',['冷笑']='冷笑话时间:BAAALAAECgYIBgAAAA==.',['列斯']='列斯尼奶奶:BAAALAAECgQIBgAAAA==.',['利威']='利威尔阿克曼:BAAALAAECgIIAgAAAA==.',['加尔']='加尔鲁什丶:BAAALAAECgYIBgAAAA==.',['动次']='动次达次:BAAALAAECgQIBAAAAA==.',['化叶']='化叶丶为尘:BAAALAAECgYICgAAAA==.',['十步']='十步杀一人:BAABLAAFFH8UAAIBAAUItxD3RAAnAQABAAUItxD3RAAnAQAAAA==.',['千里']='千里亦醉:BAAALAADCggICAAAAA==.',['古的']='古的利亚:BAAALAADCgIIAgAAAA==.',['可乐']='可乐:BAABLAAFFH8MAAIOAAMI4BIuKgDqAAAOAAMI4BIuKgDqAAAAAA==.',['可可']='可可脂:BAAALAADCgIIAgAAAA==.',['台风']='台风天:BAAALAADCgEIAQAAAA==.',['哈哈']='哈哈淡定:BAAALAAFFAIIAwAAAA==.',['啊暴']='啊暴夫:BAABLAAFFH8HAAIBAAMI9wtUZwB6AAABAAMI9wtUZwB6AAAAAA==.',['喪彪']='喪彪的爷:BAABLAAFFH8FAAIMAAUIswFdPABVAAAMAAUIswFdPABVAAAAAA==.',['圣光']='圣光照照宝藏:BAACLAAFFH8GAAIPAAIIeQkJKgBlAAAPAAIIeQkJKgBlAAAsAAQKfxgAAg8ABwgSFzAoAN0BAA8ABwgSFzAoAN0BAAAA.',['圣殿']='圣殿暴走王:BAAALAAECgYIBgAAAA==.',['在下']='在下毛毛雨:BAAALAADCggICAAAAA==.',['大口']='大口真神:BAAALAAFFAIIAgAAAA==.',['大鑫']='大鑫丶:BAAALAAECgUIBgAAAA==.',['天天']='天天吃饭:BAAALAAECgIIAgAAAA==.',['奈文']='奈文:BAAALAAECgYIDAAAAA==.',['奶潮']='奶潮:BAABLAAFFH8JAAMNAAIIPBElSwBwAAANAAIIPBElSwBwAAAMAAEIgABhQQAoAAAAAA==.奶潮汹涌:BAAALAAECgEIAQAAAA==.',['姗姗']='姗姗公主:BAAALAAECgIIAgAAAA==.',['娜妹']='娜妹宝贝:BAAALAAECgIIAgAAAA==.',['宁世']='宁世萨爷:BAABLAAFFH8GAAINAAII/xAVQgB+AAANAAII/xAVQgB+AAAAAA==.',['寂寞']='寂寞如歌:BAAALAAECgYICgAAAA==.',['富贵']='富贵小火锅:BAAALAAFFAIIBAAAAA==.',['小丽']='小丽:BAAALAAFFAIIAwAAAA==.',['小小']='小小丶法:BAAALAADCgMIAwAAAA==.',['小手']='小手菇凉:BAABLAAECn8WAAIQAAYIMhOZGAA5AQAQAAYIMhOZGAA5AQAAAA==.',['左左']='左左咿:BAAALAAECgYIEwAAAA==.',['帝尅']='帝尅:BAAALAAECgQIBAAAAA==.',['张涛']='张涛涛:BAAALAAECgMIAgAAAA==.',['彡西']='彡西楚霸王彡:BAABLAAECn8WAAIRAAYIFBFlvwBZAQARAAYIFBFlvwBZAQAAAA==.',['彦斌']='彦斌:BAABLAAFFH8OAAMLAAIIpx59OgCvAAALAAIIpx59OgCvAAAKAAIIAxc/IgCDAAAAAA==.',['很多']='很多年以后:BAAALAADCgQIBAAAAA==.',['恶聋']='恶聋咆哮:BAAALAADCggICAAAAA==.',['我不']='我不会翻跟头:BAAALAAECggICAAAAA==.',['戦言']='戦言申:BAAALAAFFAMIAwAAAA==.',['斯考']='斯考特丶:BAABLAAFFH8aAAICAAgIYyFmAAD5AgACAAgIYyFmAAD5AgAAAA==.',['晴雨']='晴雨天:BAABLAAFFH8IAAIFAAIIjAoAQQCLAAAFAAIIjAoAQQCLAAAAAA==.',['暴走']='暴走王中王:BAAALAAFFAQIBAAAAA==.',['暴雨']='暴雨天:BAABLAAFFH8IAAISAAII9B+PCgC3AAASAAII9B+PCgC3AAAAAA==.',['朕无']='朕无罪:BAAALAAECgcIBwAAAA==.',['末丶']='末丶洛:BAABLAAFFH8JAAITAAYI5RUJBgAGAgATAAYI5RUJBgAGAgAAAA==.',['术十']='术十二郎:BAAALAAFFAgIBAAAAA==.',['柔情']='柔情珊珊:BAAALAAECgYICAAAAA==.',['欧皇']='欧皇:BAAALAAECgYICAAAAA==.',['武陵']='武陵萌主:BAAALAAECgYIBgAAAA==.',['水流']='水流蝅蝅:BAAALAAECgIIBAAAAA==.',['沙丶']='沙丶宝:BAABLAAECn8WAAIBAAcIOxz/WABEAgABAAcIOxz/WABEAgAAAA==.',['烟花']='烟花散尽:BAAALAADCggIDQAAAA==.',['燎原']='燎原之骑:BAAALAAECgQIBAAAAA==.',['爱守']='爱守护天使:BAABLAAECn8cAAMGAAgIgyHyAwCvAgAGAAgIgyHyAwCvAgAUAAEIUgr2IwA0AAAAAA==.',['特拉']='特拉维斯:BAAALAAFFAIIAgAAAA==.',['狂野']='狂野怒火:BAAALAAECgYIDQAAAA==.',['珍珠']='珍珠白玉汤:BAAALAAECgMIAwAAAA==.',['男护']='男护士:BAAALAAECgYIAQAAAA==.',['真龍']='真龍小公主:BAABLAAFFH8IAAITAAUISBHGLQAYAQATAAUISBHGLQAYAQAAAA==.',['真龙']='真龙小天子:BAABLAAFFH8FAAIGAAIIuwxFGQA9AAAGAAIIuwxFGQA9AAAAAA==.',['神王']='神王之王:BAAALAAFFAIIAgAAAA==.',['福八']='福八亿:BAAALAADCggICAAAAA==.',['秋澤']='秋澤晉:BAAALAAECgYICQAAAA==.',['秋芸']='秋芸世界:BAAALAAECgMIBwAAAA==.',['糯猫']='糯猫猫囍囍:BAAALAAECggICAAAAA==.',['紫浠']='紫浠:BAABLAAFFH8IAAIPAAIIJQqmIACGAAAPAAIIJQqmIACGAAAAAA==.',['紫色']='紫色斩月:BAAALAAECgYIBwAAAA==.',['红胡']='红胡子:BAAALAAECgUIBQAAAA==.',['肉弹']='肉弹湛车:BAAALAAECgQICAAAAA==.',['胡灬']='胡灬尼克:BAAALAADCggICAAAAA==.',['脸上']='脸上的小人物:BAAALAAECgYIDgAAAA==.',['舒子']='舒子信仰冲锋:BAAALAAECgUIDQAAAA==.',['蒼穹']='蒼穹天空:BAAALAAECgYIBgAAAA==.',['蓝天']='蓝天玉暖:BAAALAAECgYIBgAAAA==.',['蓝帶']='蓝帶:BAAALAAECgYIDgAAAA==.',['血舞']='血舞之刃:BAEALAAECgMIAwABLAAECgYIDAAVAAAAAA==.',['西瓜']='西瓜头子:BAABLAAFFH8JAAILAAMI0xG/NQC4AAALAAMI0xG/NQC4AAAAAA==.西瓜贩子:BAAALAAFFAIIAwAAAA==.',['超重']='超重拳先生:BAAALAAECgMIAwAAAA==.',['都不']='都不能缺德:BAABLAAFFH8KAAIIAAIIvRaDLwB2AAAIAAIIvRaDLwB2AAAAAA==.',['钺战']='钺战天:BAABLAAFFH8GAAIBAAII9wkufwCIAAABAAII9wkufwCIAAAAAA==.',['锦晟']='锦晟纸业:BAAALAADCgIIAgAAAA==.',['阿尔']='阿尔忒弥斯:BAAALAAFFAIIAgAAAA==.',['阿狸']='阿狸哈佘莜:BAAALAAECgIIAgAAAA==.',['阿里']='阿里奎恩:BAAALAADCggICAAAAA==.',['随风']='随风落叶:BAABLAAFFH8IAAMLAAII4RunggBQAAALAAII4RunggBQAAAKAAEI+gXWGgAyAAAAAA==.',['雷鸣']='雷鸣之力:BAAALAAECgQIBAAAAA==.',['风冰']='风冰火花:BAAALAAECgYICQAAAA==.',['风筝']='风筝:BAAALAAECgQIBAAAAA==.',['鬼哭']='鬼哭狼嚎:BAACLAAFFH8NAAMWAAMIchS8PACbAAAWAAMIchS8PACbAAASAAEIiwMmMABBAAAsAAQKfyUAAxYABwgNHpknALkBABYABgiIH5knALkBABIABgiOGswyAKIBAAAA.',['鬼舞']='鬼舞狂刀:BAABLAAFFH8GAAIFAAIIlhYiTQBGAAAFAAIIlhYiTQBGAAAAAA==.',['魔道']='魔道尊者:BAAALAAFFAIIBAAAAA==.',['鸭鸭']='鸭鸭乐:BAABLAAFFH8fAAILAAgIEx8XBwB1AgALAAgIEx8XBwB1AgAAAA==.鸭鸭樂:BAACLAAFFH9KAAILAAgIySPPAwC6AgALAAgIySPPAwC6AgAsAAQKfyYAAgsACAgBJRImAB8CAAsACAgBJRImAB8CAAAA.',['黑牛']='黑牛犇犇:BAAALAADCgMIAwAAAA==.',['龙晶']='龙晶:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end