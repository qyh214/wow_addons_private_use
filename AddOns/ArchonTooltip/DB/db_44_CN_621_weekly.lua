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
 local lookup = {'Rogue-Subtlety','Paladin-Retribution','Hunter-BeastMastery','Mage-Arcane','DeathKnight-Frost','Mage-Frost','DemonHunter-Havoc','Paladin-Holy','Warlock-Destruction','Hunter-Marksmanship','Shaman-Restoration','Druid-Balance','Shaman-Elemental','Warrior-Protection','DemonHunter-Vengeance','Monk-Mistweaver','Priest-Holy','Warlock-Demonology','Warlock-Affliction','Druid-Guardian','Warrior-Arms','Druid-Feral','DeathKnight-Unholy','Druid-Restoration','Priest-Shadow','Rogue-Assassination','Evoker-Preservation','Warrior-Fury','Evoker-Augmentation','Hunter-Survival','Priest-Discipline','Unknown-Unknown','Monk-Brewmaster','Monk-Windwalker',}; local provider = {region='CN',realm='基尔加丹',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alecto:BAABLAAFFH8GAAIBAAYIViLEAQBYAgABAAYIViLEAQBYAgAAAA==.Alolo:BAAALAAECgYICQAAAA==.',Am='Amanpushcar:BAAALAAECgYIDgAAAA==.',Ar='Arcana:BAAALAADCgMIAwAAAA==.',Be='Benfly:BAABLAAFFH8NAAICAAIIvhxMNwClAAACAAIIvhxMNwClAAAAAA==.',Ch='Cheesekayee:BAAALAAFFAIIAgAAAA==.',Cr='Crysta:BAAALAAECgMIAwABLAAFFAMIDQADALsWAA==.',Da='Darkerblack:BAAALAAECggIEwAAAA==.',De='Demonkiller:BAAALAAECgMIAwAAAA==.Deutsche:BAAALAAFFAgIBAAAAA==.',Do='Donblue:BAAALAAECgQIBAAAAA==.',Dp='Dph:BAAALAADCgYIBgAAAA==.',Dy='Dymj:BAAALAAECgEIAQAAAA==.',Fi='Findurdeath:BAAALAAECgIIAgAAAA==.Firewood:BAAALAADCggIEAAAAA==.',Gl='Glolo:BAABLAAECn8UAAIEAAYIliBnQwA/AgAEAAYIliBnQwA/AgAAAA==.',Gr='Grievous:BAACLAAFFH8hAAICAAUIZx33DACQAQACAAUIZx33DACQAQAsAAQKfyYAAgIACAgkI8kgAO8CAAIACAgkI8kgAO8CAAAA.',Ho='Hongdie:BAACLAAFFH8fAAIFAAcIjxf8EgC1AQAFAAcIjxf8EgC1AQAsAAQKfycAAgUACAhmIrMgAO0CAAUACAhmIrMgAO0CAAAA.',Hu='Huangkai:BAACLAAFFH8FAAIGAAMIJxL0DQB8AAAGAAMIJxL0DQB8AAAsAAQKfxoAAgYACAibG6cLAAECAAYACAibG6cLAAECAAAA.',Il='Ilolo:BAAALAAECgEIAQAAAA==.',Im='Imba:BAAALAAFFAIIAgAAAA==.',Ka='Kaley:BAAALAAECgQIBQAAAA==.Kasuml:BAAALAAECgIIAgAAAA==.',Lo='Logos:BAAALAADCgcIBwAAAA==.Lorraine:BAAALAAECgYIBgAAAA==.Lowki:BAAALAADCgQIBAAAAA==.',Ma='Magus:BAABLAAFFH8TAAIEAAIIaR1PPgChAAAEAAIIaR1PPgChAAAAAA==.',Me='Megademon:BAACLAAFFH8tAAIHAAYISBKPIgDaAAAHAAYISBKPIgDaAAAsAAQKfyoAAgcACAiyIGUKAKACAAcACAiyIGUKAKACAAAA.',Mi='Milabo:BAAALAADCgcIBwAAAA==.',Ov='Ovoxovo:BAAALAAECgQIBAAAAA==.',Pi='Pigeoncn:BAAALAAECgEIAwAAAA==.',Pl='Playervwospk:BAABLAAECn8cAAMCAAYIWSTEPwB8AgACAAYIWSTEPwB8AgAIAAYIsh/sDAAhAgAAAA==.',Sc='Scarlettj:BAAALAAECgYIBgAAAA==.',Sh='Shion:BAABLAAFFH8GAAIJAAYIhBtFHwCgAQAJAAYIhBtFHwCgAQAAAA==.',Si='Sibuqulr:BAAALAADCgQIBAAAAA==.Siyuan:BAAALAAECgQIBAAAAA==.',Sm='Smlrsmlr:BAAALAADCgMIAwAAAA==.',St='Steelballrun:BAAALAAECgIIAgAAAA==.Steelswarm:BAACLAAFFH8NAAIDAAMIuxZURgCdAAADAAMIuxZURgCdAAAsAAQKfywAAwMACAgBIMopALECAAMACAgBIMopALECAAoAAghNBpW/ADEAAAAA.',Su='Superhunter:BAAALAAECgYIBgAAAA==.Susi:BAAALAAECgYIBgAAAA==.',Te='Teett:BAAALAAECgQIBQAAAA==.',Ti='Tiktok:BAAALAAECgMIAwAAAA==.',Ya='Yachiruu:BAAALAAFFAMIAwAAAA==.',Ye='Yeacion:BAABLAAECn8cAAILAAYIPxg5PwBdAQALAAYIPxg5PwBdAQAAAA==.',Yl='Ylkee:BAAALAAECgcICAAAAA==.',['一影']='一影雪雪一:BAAALAAECgYICAAAAA==.',['一护']='一护士一:BAAALAAFFAIIAgAAAA==.',['一煜']='一煜祺一:BAABLAAFFH8IAAIDAAYIHRm4BgAVAgADAAYIHRm4BgAVAgAAAA==.',['一老']='一老薛一:BAAALAAECgIIAwAAAA==.',['三个']='三个六斋:BAAALAAFFAIIBAABLAAFFAIICgAMADsLAA==.',['三岁']='三岁就有角:BAAALAAECgYIBgAAAA==.',['不是']='不是虚胖:BAABLAAFFH8IAAILAAIIRRMVSAB0AAALAAIIRRMVSAB0AAAAAA==.',['不要']='不要放弃吃药:BAACLAAFFH8NAAMLAAMI2BbVJwC1AAALAAMI2BbVJwC1AAANAAEIPAPfPwA6AAAsAAQKfy4AAwsACAjiHusYALgCAAsACAjiHusYALgCAA0ABwipDWpmAIYBAAAA.',['且听']='且听枫吟:BAAALAAECgIIAgAAAA==.',['丛林']='丛林追迹者:BAACLAAFFH8HAAIDAAMI2Q7ULQDMAAADAAMI2Q7ULQDMAAAsAAQKfxYAAgMABgi7HeJqAAUCAAMABgi7HeJqAAUCAAAA.',['东琪']='东琪琪:BAAALAAECgMIBgAAAA==.',['丨悟']='丨悟天克斯丨:BAABLAAFFH8GAAIOAAYI1xXqDwBOAQAOAAYI1xXqDwBOAQAAAA==.',['丨荄']='丨荄丨:BAAALAADCgIIAgAAAA==.',['丨醋']='丨醋溜茄子丨:BAAALAADCgYIBgAAAA==.',['丫大']='丫大队:BAAALAAECgMIAwAAAA==.',['临时']='临时演员:BAAALAAECggIBgAAAA==.',['丶丶']='丶丶苏:BAABLAAFFH8GAAIFAAIIBAvwgABFAAAFAAIIBAvwgABFAAAAAA==.',['丶苏']='丶苏丶:BAAALAAFFAIIBAAAAA==.',['丸子']='丸子老爹:BAAALAAECgcIBwAAAA==.',['为谁']='为谁说情话:BAAALAAFFAQIBAAAAA==.',['久雨']='久雨初晴:BAAALAAFFAIIAgAAAA==.',['九五']='九五冲啊:BAABLAAFFH8MAAMHAAYIZQf/KgA8AQAHAAYIcwb/KgA8AQAPAAIIBAvFFQBeAAAAAA==.',['九莲']='九莲宝灯:BAAALAADCggICAAAAA==.',['也不']='也不会比你:BAABLAAFFH8aAAIQAAYIYxrvBgDNAQAQAAYIYxrvBgDNAQAAAA==.',['乳动']='乳动奇迹丶:BAAALAAECgYIBgAAAA==.',['二人']='二人季節:BAAALAAECgYIBgAAAA==.',['云雾']='云雾纪元:BAABLAAFFH8FAAIRAAMIQQ9mLQC6AAARAAMIQQ9mLQC6AAAAAA==.',['五块']='五块卵石:BAACLAAFFH8tAAIJAAcI5SHqDwASAgAJAAcI5SHqDwASAgAsAAQKfyoABAkACAi4JOYQACADAAkACAi4JOYQACADABIAAwi6HXFoANUAABMAAgglGvAqAJQAAAAA.',['亚大']='亚大队:BAAALAAFFAIIBAAAAA==.',['亦心']='亦心为橙:BAAALAADCgYIBgAAAA==.',['今天']='今天不打莹仔:BAAALAAECgYIDQAAAA==.',['他若']='他若有情:BAAALAADCgMIAwAAAA==.',['代号']='代号灬加百列:BAAALAAFFAIIAgAAAA==.代号灬幻术师:BAABLAAFFH8FAAIUAAQIphp6BAD7AAAUAAQIphp6BAD7AAAAAA==.代号灬追猎者:BAABLAAFFH8MAAIPAAYIghVnBQBBAQAPAAYIghVnBQBBAQAAAA==.代号灬阿瑞斯:BAACLAAFFH8qAAIOAAcIKxh0CAC7AQAOAAcIKxh0CAC7AQAsAAQKfyIAAg4ACAhKHnMSAKMCAA4ACAhKHnMSAKMCAAAA.',['以前']='以前是个暗牧:BAAALAAFFAIIAgAAAA==.',['传说']='传说中的绅士:BAAALAADCgEIAQAAAA==.',['伽康']='伽康:BAAALAAECgIIAgAAAA==.',['佐佐']='佐佐木明希:BAAALAAECgYIBgAAAA==.',['何二']='何二娃:BAAALAAECgMIBQAAAA==.',['佩岑']='佩岑:BAAALAAECgYIBgAAAA==.',['佩露']='佩露夏:BAAALAAECggICAAAAA==.',['佳康']='佳康:BAAALAAECgIIAgAAAA==.',['依旧']='依旧丶残秋:BAAALAAFFAIIAgAAAA==.',['依然']='依然小石头:BAAALAAFFAIIBAAAAA==.',['保护']='保护我家鸽鸽:BAAALAAECggICAAAAA==.',['傅炎']='傅炎杰:BAAALAAECggIDAAAAA==.',['八六']='八六上山了:BAAALAAFFAIIAgAAAA==.',['再怎']='再怎么残酷:BAABLAAFFH8eAAIQAAYIhBjgBwCxAQAQAAYIhBjgBwCxAQAAAA==.',['军师']='军师祭酒郭嘉:BAAALAADCgMIAwAAAA==.',['冷小']='冷小柒:BAAALAADCgQIBAAAAA==.冷小玖:BAAALAADCgQIBAAAAA==.',['冷淡']='冷淡的小表妹:BAAALAAECgYIEQABLAAECgcIHwAVANAiAA==.',['净化']='净化朴哥:BAAALAAFFAIIAgABLAAFFAgICAALAB4AAA==.',['凌莲']='凌莲:BAAALAAECgYIBgAAAA==.',['凛冬']='凛冬之怒:BAAALAAECgYIBgAAAA==.',['凝望']='凝望群星:BAABLAAFFH8WAAILAAYIhxprEgDQAQALAAYIhxprEgDQAQAAAA==.',['初夏']='初夏夜未央:BAAALAAFFAIIBAAAAA==.',['剑小']='剑小宝:BAAALAADCgQIBQAAAA==.',['劣白']='劣白白:BAACLAAFFH8cAAMDAAYINhvCIwDwAAADAAQIahzCIwDwAAAKAAQIdRkFDgCYAAAsAAQKfywAAwoABwjFJHAIAN4BAAMABwhZIaNKAEsCAAoABwivInAIAN4BAAAA.',['动次']='动次大次:BAAALAAFFAIIAgAAAA==.',['勒戈']='勒戈拉斯:BAACLAAFFH8JAAIDAAMIoBKcbACJAAADAAMIoBKcbACJAAAsAAQKfyIAAgMACAhoHuMgADcCAAMACAhoHuMgADcCAAAA.',['十年']='十年一觉:BAAALAAECgYIEQAAAA==.',['南方']='南方最南丨术:BAAALAADCgMIAwAAAA==.南方最南丨猎:BAAALAADCgQIBAAAAA==.南方最南丨血:BAAALAADCgEIAQAAAA==.南方最南丨骑:BAAALAADCgYIBgAAAA==.南方最南丶猎:BAAALAADCgIIAgAAAA==.',['双刀']='双刀武器战:BAAALAAECgQIBAAAAA==.',['口水']='口水淹死你丿:BAAALAAECggIEgAAAA==.',['古日']='古日塔嫚之花:BAABLAAFFH8SAAILAAYIdBYmKwANAQALAAYIdBYmKwANAQAAAA==.',['古月']='古月方源:BAABLAAFFH8OAAIWAAYItA4YBgA6AQAWAAYItA4YBgA6AQAAAA==.',['叶之']='叶之悲伤:BAAALAAECgYIDQAAAA==.',['叶傾']='叶傾城:BAAALAAECgEIAQAAAA==.',['吼少']='吼少侠:BAAALAAECgIIAgAAAA==.',['品行']='品行崩壊:BAAALAAECgUIBQAAAA==.',['哥有']='哥有三条腿:BAABLAAFFH8IAAIJAAgIJA1pEwDuAQAJAAgIJA1pEwDuAQAAAA==.',['哼想']='哼想逃:BAAALAAECgcIDAAAAA==.',['唛豆']='唛豆豆:BAAALAAECgYICwABLAAECgcIHwAVANAiAA==.',['商务']='商务阿扎西:BAAALAAFFAYIAgAAAA==.',['啦啦']='啦啦滴辣:BAAALAAECgYIBgAAAA==.',['喜欢']='喜欢钻洞:BAAALAAECgYIAQAAAA==.',['喜羊']='喜羊羊:BAABLAAFFH8SAAILAAIIByXxOQC7AAALAAIIByXxOQC7AAAAAA==.',['嘉亢']='嘉亢:BAAALAAECgQIBAAAAA==.',['嘉康']='嘉康:BAAALAAFFAIIAgAAAA==.',['四世']='四世小盗:BAAALAADCgEIAQAAAA==.',['四元']='四元:BAAALAAECgEIAQAAAA==.',['困兽']='困兽的星空:BAABLAAECn8UAAIHAAYIORb0QwBPAQAHAAYIORb0QwBPAQAAAA==.',['国服']='国服第一深情:BAAALAAECgEIAQAAAA==.',['圣光']='圣光与你同在:BAAALAAECgYIEAAAAA==.圣光安抚你:BAAALAAECgIIAgAAAA==.圣光熊:BAAALAAECgEIAQAAAA==.',['圣斗']='圣斗士牛牛:BAAALAAECgQIBAAAAA==.',['地狱']='地狱邪眼师:BAABLAAFFH8NAAIJAAUI6xF5NwAwAQAJAAUI6xF5NwAwAQAAAA==.',['坏家']='坏家伙:BAABLAAFFH8IAAIDAAIIFBjxVwCRAAADAAIIFBjxVwCRAAAAAA==.',['堕天']='堕天雨:BAABLAAFFH8GAAIXAAYIhQDJEQBPAAAXAAYIhQDJEQBPAAAAAA==.',['堕落']='堕落无罪:BAAALAAECggICQAAAA==.',['壹點']='壹點點萨:BAAALAAECgMIAwAAAA==.',['复杂']='复杂:BAAALAAFFAIIAgABLAAFFAMIBQAQAL4UAA==.',['夏娜']='夏娜酱:BAAALAADCgYIBgAAAA==.',['夏末']='夏末未央:BAABLAAFFH8IAAIRAAIIyBV+OwBzAAARAAIIyBV+OwBzAAAAAA==.',['夜之']='夜之瞳:BAAALAAECgMIAwAAAA==.',['夜夜']='夜夜魂:BAAALAADCgYIBgAAAA==.',['夜幕']='夜幕:BAAALAAFFAIIAgAAAA==.',['夜熙']='夜熙:BAAALAAECgQIBQAAAA==.',['大悪']='大悪魔:BAAALAAECgYIBgAAAA==.',['大球']='大球球:BAAALAAECggIAgAAAA==.',['大米']='大米霸霸:BAACLAAFFH8OAAIHAAMIgR5sLACyAAAHAAMIgR5sLACyAAAsAAQKfyIAAgcABwgGJNkwAJkCAAcABwgGJNkwAJkCAAAA.',['大良']='大良蹦沙:BAAALAAFFAEIAQAAAA==.',['天下']='天下为龙:BAAALAAECgIIAgAAAA==.',['天启']='天启亡骑士:BAAALAADCgIIAgAAAA==.',['天堂']='天堂不寂寞:BAAALAAECgIIAgAAAA==.天堂狩猎者:BAAALAADCggICgAAAA==.',['天空']='天空有间房子:BAAALAADCgIIAgAAAA==.',['太阳']='太阳女神:BAAALAAECgYIBgAAAA==.太阳石:BAABLAAECn8UAAIYAAYIlRyrOwDwAQAYAAYIlRyrOwDwAQAAAA==.',['失落']='失落时空:BAAALAAECgMIAwAAAA==.',['奈布']='奈布丶皮皮:BAAALAAECgUIBQAAAA==.',['如愿']='如愿:BAAALAAECgYICAAAAA==.',['娜梅']='娜梅莉雅:BAAALAAFFAIIAgAAAA==.',['孑的']='孑的良孓:BAAALAAECgIIAgAAAA==.',['宇宙']='宇宙超级浪:BAAALAAECgYIBgAAAA==.',['安之']='安之荷兰乳牛:BAAALAADCgQIBAAAAA==.',['宝宝']='宝宝巴士丶:BAAALAAECgYICQAAAA==.',['家康']='家康:BAAALAAFFAIIAwAAAA==.',['寵滴']='寵滴將軍:BAAALAAECgYIBgAAAA==.',['射你']='射你个屁屁:BAAALAAFFAIIAgAAAA==.',['将来']='将来丶的歌:BAAALAAECgYIDwAAAA==.',['小丑']='小丑女:BAAALAAECgYICwABLAAECgcIHwAVANAiAA==.',['小学']='小学扛把子:BAAALAAFFAIIAwAAAA==.',['小小']='小小无言:BAAALAAECgYIBgAAAA==.小小西瓜:BAAALAAECgYIEwAAAA==.',['小时']='小时候可萌了:BAAALAAECggICAAAAA==.',['小爱']='小爱无言:BAAALAAECgYIBgAAAA==.',['小荔']='小荔枝灬:BAABLAAFFH8LAAMRAAUIewt7KwDKAAARAAQIWAV7KwDKAAAZAAQIsgUtHAC0AAAAAA==.',['小贼']='小贼看刀:BAAALAADCgcIBwAAAA==.',['就打']='就打那个小德:BAAALAADCgMIAwAAAA==.',['就算']='就算我再:BAABLAAFFH8QAAIQAAYIjRQUCQCMAQAQAAYIjRQUCQCMAQAAAA==.',['就这']='就这个吧:BAAALAAECgYIBgAAAA==.',['尼特']='尼特三三:BAABLAAFFH8JAAIaAAQIzBDPEQDlAAAaAAQIzBDPEQDlAAAAAA==.',['幽蓝']='幽蓝冰魄:BAAALAAECgUIBQAAAA==.',['廿四']='廿四味:BAABLAAFFH8IAAMYAAUIJBOvJwDaAAAYAAQIzQ6vJwDaAAAMAAMIHQjYKQBmAAAAAA==.',['廿小']='廿小柒:BAAALAAECgYIBgAAAA==.',['弗莱']='弗莱奇:BAAALAAECgQIBAAAAA==.',['张百']='张百忍:BAAALAAECgQIBAAAAA==.',['張豌']='張豌豆:BAAALAADCgEIAQAAAA==.',['影凌']='影凌乱:BAAALAAECgMIAwAAAA==.',['影雪']='影雪雪:BAAALAAECgYIDwAAAA==.',['往日']='往日回响:BAAALAAECgEIAQAAAA==.',['微电']='微电机点:BAABLAAFFH8FAAIJAAMIzwPHUwBfAAAJAAMIzwPHUwBfAAAAAA==.',['德善']='德善:BAAALAAECgUIBQAAAA==.',['德鲁']='德鲁兮兮:BAAALAADCgUIBQAAAA==.',['怀特']='怀特麽个舅舅:BAAALAAECggIDgAAAA==.',['怎么']='怎么无情:BAABLAAFFH8WAAIQAAYIiR4NBQAIAgAQAAYIiR4NBQAIAgAAAA==.怎么无理取闹:BAABLAAFFH8WAAIQAAYIGR2hBQD0AQAQAAYIGR2hBQD0AQAAAA==.',['性感']='性感小圣杯:BAAALAAECgcIDwAAAA==.',['恒字']='恒字耀文:BAAALAADCggICAAAAA==.',['恶魔']='恶魔猎鼠:BAAALAAFFAIIAgAAAA==.',['悠然']='悠然自在心:BAAALAADCgMIAwAAAA==.',['您好']='您好我躺哪:BAAALAAECggICAAAAA==.',['情迷']='情迷小肚兜:BAAALAAFFAMIAwAAAA==.',['意在']='意在:BAABLAAFFH8FAAIDAAQIXQ5rcQB+AAADAAQIXQ5rcQB+AAAAAA==.意在死骑:BAABLAAFFH8KAAIFAAQIghl/TwDiAAAFAAQIghl/TwDiAAAAAA==.意在骑:BAABLAAECn8UAAICAAcIHhzDQwCQAQACAAcIHhzDQwCQAQAAAA==.',['慈父']='慈父史达林:BAABLAAECn8XAAMXAAgIxRNDIAC4AQAXAAgIQxNDIAC4AQAFAAEI4RTIzgBAAAAAAA==.',['慢羊']='慢羊羊:BAABLAAFFH8OAAIbAAII4xmUFwCOAAAbAAII4xmUFwCOAAAAAA==.',['懒羊']='懒羊羊:BAACLAAFFH8KAAIIAAIIJiJ5FQCxAAAIAAIIJiJ5FQCxAAAsAAQKfxQAAggACAhGGLAKAEQCAAgACAhGGLAKAEQCAAEsAAUUAggSAAsAByUA.',['我不']='我不爱吃鱼:BAAALAAECgYICgAAAA==.我不爱幻想:BAAALAADCgEIAQAAAA==.',['我叫']='我叫什么哦:BAAALAAFFAIIBAAAAA==.',['我好']='我好像迷路了:BAAALAAFFAYIBAAAAA==.',['我燃']='我燃烧你的梦:BAABLAAFFH8IAAICAAYInBuaFACnAQACAAYInBuaFACnAQAAAA==.',['我的']='我的兜小兜:BAAALAAFFAIIBAAAAA==.',['我被']='我被打就会死:BAABLAAECn8bAAMSAAgIyBFtLQC7AQAJAAgIAw7xZQDBAQASAAcIORNtLQC7AQAAAA==.',['战鼠']='战鼠:BAAALAAECgcIBwAAAA==.',['打劫']='打劫一生缘:BAACLAAFFH8KAAIcAAIIIw1fWwA7AAAcAAIIIw1fWwA7AAAsAAQKfyUAAhwACAjTFkoiAN8BABwACAjTFkoiAN8BAAAA.',['技师']='技师:BAABLAAFFH8HAAIDAAUIXw9TWwDZAAADAAUIXw9TWwDZAAABLAAFFAYIDgAWALQOAA==.',['抖动']='抖动的胸肌:BAABLAAFFH8IAAIYAAII6g8ZNQBrAAAYAAII6g8ZNQBrAAAAAA==.',['折翼']='折翼乄恶魔:BAAALAAECgYIBwAAAA==.',['按键']='按键伤人:BAAALAAECgYIDwAAAA==.',['挤挤']='挤挤就能奶:BAAALAADCgcIBwAAAA==.',['提枪']='提枪上马:BAAALAADCgMIAwAAAA==.',['支持']='支持手艺人:BAAALAAFFAIIAwAAAA==.',['放牧']='放牧员:BAAALAAFFAIIBAAAAA==.',['救星']='救星再临:BAAALAAECgYIBgAAAA==.',['敬清']='敬清:BAAALAAECgYICQAAAA==.',['斯克']='斯克莱斯威特:BAACLAAFFH8LAAQOAAYIxw0rFwD1AAAOAAUIVRArFwD1AAAcAAII7QHdZQAWAAAVAAEILAE8BwANAAAsAAQKfxoABA4ABwhVF+8VAJcBAA4ABwhVF+8VAJcBABwABQjuBWXbAK4AABUAAgjUBE8XACkAAAAA.',['斯芬']='斯芬克斯之翼:BAAALAADCgcIBwAAAA==.',['无天']='无天富祖:BAAALAAECgYIBgAAAA==.',['无忧']='无忧丶逍遥:BAAALAADCgEIAQAAAA==.',['无情']='无情:BAAALAAECgYIDAAAAA==.',['无敌']='无敌大钢炮:BAAALAAECggICAAAAA==.',['无稽']='无稽烦忧:BAAALAAECgQIBAAAAA==.',['无限']='无限边疆:BAABLAAFFH8IAAICAAII6RHgXgBHAAACAAII6RHgXgBHAAAAAA==.',['昊典']='昊典:BAAALAAECgEIAQAAAA==.',['星夜']='星夜流明:BAACLAAFFH8PAAIFAAMI+Bx8JAAJAQAFAAMI+Bx8JAAJAQAsAAQKfy4AAwUABwhNItY0AKICAAUABwhNItY0AKICABcAAwgtG1k/AOAAAAAA.',['星空']='星空之刃:BAAALAAECggICAAAAA==.',['星辰']='星辰不眨眼:BAAALAAFFAIIAgAAAA==.星辰之刄:BAAALAAECggIDgAAAA==.',['普希']='普希尼亚斯:BAAALAAECgcIDgAAAA==.',['晴天']='晴天丶:BAABLAAFFH8UAAIdAAgIuR8MAQCZAgAdAAgIuR8MAQCZAgAAAA==.',['暖洋']='暖洋洋:BAACLAAFFH8LAAIQAAIIfx6PEACwAAAQAAIIfx6PEACwAAAsAAQKfxYAAhAACAhWGyIIAEsCABAACAhWGyIIAEsCAAEsAAUUAggSAAsAByUA.',['曾经']='曾经的记忆:BAAALAADCgUIBQAAAA==.',['月光']='月光石:BAAALAAECgYICgABLAAFFAIICgAMADsLAA==.',['月徘']='月徘徊:BAAALAAECgYICgAAAA==.',['月球']='月球上的人:BAABLAAFFH8KAAMMAAIIOwtRIwCDAAAMAAIIOwtRIwCDAAAYAAIIahvzLwB0AAAAAA==.',['月羽']='月羽风行者:BAABLAAECn8aAAIeAAYIJBtFDQDTAQAeAAYIJBtFDQDTAQAAAA==.',['月逝']='月逝彼山:BAAALAADCgYIBgAAAA==.',['有雨']='有雨的夜:BAAALAAECgYIBgAAAA==.',['末夜']='末夜曲调:BAAALAADCgEIAQAAAA==.',['术大']='术大招风:BAAALAAECgIIAgAAAA==.',['术甲']='术甲:BAAALAAECgcICAAAAA==.',['李达']='李达康:BAAALAAECgUIBgAAAA==.',['杰西']='杰西卡阿尔巴:BAAALAADCgIIAgAAAA==.',['林風']='林風:BAAALAADCggICAAAAA==.',['栖阳']='栖阳:BAAALAAECgMIAwAAAA==.',['桀发']='桀发受长生:BAAALAAFFAIIAgAAAA==.',['棋士']='棋士:BAACLAAFFH8WAAICAAQI8hnQMgDsAAACAAQI8hnQMgDsAAAsAAQKf0UAAgIACAhtJTAGAOwCAAIACAhtJTAGAOwCAAAA.',['樂丨']='樂丨樂:BAAALAAECgYICgAAAA==.',['武井']='武井咲:BAACLAAFFH8HAAIJAAYIGgRtQgDaAAAJAAYIGgRtQgDaAAAsAAQKfxcAAgkABwheFGczAH0BAAkABwheFGczAH0BAAAA.',['死都']='死都五掂:BAAALAAECgYIBgAAAA==.',['殆尽']='殆尽:BAAALAADCggICAAAAA==.',['残烬']='残烬星散:BAAALAAECgYIBQAAAA==.',['残酷']='残酷的大表哥:BAABLAAECn8fAAMVAAcI0CIcCABwAgAVAAcIACIcCABwAgAOAAYIkx6xKgDwAQAAAA==.',['每天']='每天喝两杯:BAABLAAFFH8RAAMfAAIIhxqgAwCaAAAfAAIIhxqgAwCaAAARAAII5xU3LACTAAABLAAFFAIIEgALAAclAA==.',['毛毛']='毛毛的妹妹:BAAALAAECgUIBQAAAA==.',['水泥']='水泥厂甜心:BAAALAAECgYIBgAAAA==.',['沉睡']='沉睡的龙:BAAALAAFFAIIAgAAAA==.',['沐潆']='沐潆的圣光:BAAALAADCggICAAAAA==.沐潆翾:BAAALAAFFAIIAgAAAA==.',['没刺']='没刺的仙人掌:BAAALAAFFAMIAwAAAA==.',['沸羊']='沸羊羊:BAACLAAFFH8QAAIYAAIIFhmMOACJAAAYAAIIFhmMOACJAAAsAAQKfxQAAhgACAhGGCRTAJ0BABgACAhGGCRTAJ0BAAEsAAUUCAgDACAAAAAA.',['油膩']='油膩的師姐:BAAALAAECgQIBAAAAA==.',['泛泛']='泛泛之辈的泛:BAABLAAFFH8PAAIDAAYIkwzOWgDcAAADAAYIkwzOWgDcAAAAAA==.',['泛滥']='泛滥滴小年轻:BAAALAAFFAgIAwAAAA==.',['泛舟']='泛舟淡水湖:BAAALAAECgYIDAAAAA==.',['波利']='波利在吉芬:BAABLAAFFH8GAAMLAAMIJgF0eQA3AAALAAIIIgF0eQA3AAANAAIIyQCMVgAJAAAAAA==.',['泥潭']='泥潭捞月光:BAACLAAFFH8PAAIYAAMIsSDWGAC+AAAYAAMIsSDWGAC+AAAsAAQKfyUAAhgABwiJJMcXAKICABgABwiJJMcXAKICAAAA.',['洛宁']='洛宁:BAABLAAECn8VAAICAAcIphmoRACOAQACAAcIphmoRACOAQAAAA==.',['流苏']='流苏晚晴:BAAALAADCgIIAgAAAA==.',['流风']='流风轻云:BAAALAAECgYICAAAAA==.',['浮图']='浮图:BAAALAAECgEIAQAAAA==.',['混乱']='混乱夜色:BAAALAAECggIDAAAAA==.',['清平']='清平乐:BAAALAAECgYIEAAAAA==.',['湿湿']='湿湿的莫莫:BAAALAAECgYIDQAAAA==.',['漫天']='漫天叶纷飞:BAABLAAECn8WAAIEAAYIUQ+5oQBEAQAEAAYIUQ+5oQBEAQAAAA==.',['火吻']='火吻而生:BAABLAAFFH8KAAIHAAYIugxgLwAdAQAHAAYIugxgLwAdAQAAAA==.',['灵芝']='灵芝剑刃:BAAALAADCgYIBgAAAA==.',['灿灿']='灿灿:BAAALAAECgQIBAAAAA==.',['炎与']='炎与永远:BAAALAAECgYIEgAAAA==.',['点心']='点心:BAABLAAFFH8IAAIbAAIIkwifGwBjAAAbAAIIkwifGwBjAAAAAA==.',['烟雨']='烟雨醉蒙胧:BAAALAADCgQIBAAAAA==.',['烧肉']='烧肉定食:BAACLAAFFH8LAAIDAAUIUxdGTgAVAQADAAUIUxdGTgAVAQAsAAQKfyAAAgMACAgiHYMjACsCAAMACAgiHYMjACsCAAAA.',['烫头']='烫头不敌纹身:BAAALAAECgYIBgABLAAFFAMIDQADALsWAA==.',['热爱']='热爱大自然:BAAALAAECgEIAQAAAA==.',['爸爸']='爸爸来咯:BAAALAAFFAMIAwAAAA==.',['爻魔']='爻魔:BAAALAAECggICAAAAA==.',['牟宝']='牟宝宝丶:BAAALAAECgYIBgAAAA==.',['猎艳']='猎艳江湖:BAAALAAECgMIAwAAAA==.',['猛的']='猛的丫劈:BAAALAAECgEIAQAAAA==.',['猫猫']='猫猫龙:BAAALAAFFAIIBAAAAA==.',['玛力']='玛力喀喀:BAAALAAECgYIEgAAAA==.',['理查']='理查德米勒:BAABLAAFFH8IAAICAAYIswlILAAiAQACAAYIswlILAAiAQAAAA==.',['瑞亜']='瑞亜:BAAALAAECgYIBgAAAA==.',['瑞亞']='瑞亞:BAAALAAECgYIDAAAAA==.',['瓢泼']='瓢泼的云:BAAALAAECgMIBQAAAA==.',['瓦奥']='瓦奥莱特:BAABLAAECn8XAAIRAAcIkwjUcgAjAQARAAcIkwjUcgAjAQAAAA==.',['留着']='留着泪的灵魂:BAAALAAECgQIBAAAAA==.',['疾風']='疾風怒濤:BAABLAAFFH8GAAIHAAIItBoGMgCmAAAHAAIItBoGMgCmAAAAAA==.',['白栗']='白栗粟木锦棉:BAABLAAFFH8GAAICAAYI3RgIGgCIAQACAAYI3RgIGgCIAQAAAA==.',['百事']='百事公爵:BAAALAADCgEIAQAAAA==.',['看我']='看我眼神:BAABLAAFFH8IAAIPAAIIMB27CwCXAAAPAAIIMB27CwCXAAAAAA==.',['真鸡']='真鸡児小:BAAALAADCgQIBAAAAA==.',['瞅瞅']='瞅瞅:BAAALAAECgEIAQAAAA==.',['破晓']='破晓晨光:BAACLAAFFH8PAAIOAAMIaQ4eIgBqAAAOAAMIaQ4eIgBqAAAsAAQKfyoABA4ACAh3G/0aAFkCAA4ACAitGv0aAFkCABUABghuEo4XAHABABwAAQgNCwEYASMAAAAA.',['破灭']='破灭的怀念:BAABLAAFFH8KAAIFAAYIYgqePQBEAQAFAAYIYgqePQBEAQAAAA==.',['硬的']='硬的一劈:BAAALAAECgMIAwAAAA==.',['磷叶']='磷叶石:BAAALAAECgcIDQAAAA==.',['神将']='神将飞蓬:BAACLAAFFH8QAAIBAAMI6w2/EQCUAAABAAMI6w2/EQCUAAAsAAQKfywAAgEACAiwGp4NAGICAAEACAiwGp4NAGICAAAA.',['神龙']='神龙大侠肥波:BAAALAAECgEIAQAAAA==.',['私欲']='私欲乱人心:BAAALAAFFAIIAgAAAA==.',['科场']='科场问:BAACLAAFFH8GAAIJAAII6AJAcQAqAAAJAAII6AJAcQAqAAAsAAQKfykAAwkACAjGDR09AFMBAAkACAjGDR09AFMBABIABQgEBPlsAMIAAAAA.',['科技']='科技改变命运:BAAALAAECgQIBAAAAA==.',['秦倚']='秦倚天:BAAALAAFFAMIBAAAAA==.',['立秋']='立秋丷:BAABLAAFFH8OAAIcAAgIESOYAQDwAgAcAAgIESOYAQDwAgAAAA==.立秋僧:BAAALAAECggICAAAAA==.立秋骑:BAABLAAFFH8fAAICAAYIKyXGBgAbAgACAAYIKyXGBgAbAgAAAA==.',['站起']='站起来蹬:BAAALAAFFAIIAgAAAA==.',['竹里']='竹里明日香:BAAALAADCggIDAAAAA==.',['笨鸟']='笨鸟也能高飞:BAABLAAFFH8GAAIJAAIIxB80QgCVAAAJAAIIxB80QgCVAAAAAA==.',['米果']='米果天天开心:BAAALAAECgIIAgAAAA==.',['粤韵']='粤韵风华:BAAALAADCgIIAgAAAA==.',['紊乱']='紊乱秩序:BAAALAAFFAIIAwAAAA==.',['红赤']='红赤朱秋叶:BAABLAAFFH8GAAIFAAIIdBJQcwCOAAAFAAIIdBJQcwCOAAAAAA==.',['红龙']='红龙咆哮:BAAALAADCgIIAgAAAA==.',['约德']='约德尔大王:BAAALAADCgcIBwAAAA==.',['给爱']='给爱加点糖:BAAALAAFFAIIAgAAAA==.',['绝影']='绝影:BAABLAAFFH8kAAIHAAgIHR2uBACbAgAHAAgIHR2uBACbAgAAAA==.',['绯丶']='绯丶单翼:BAAALAAECgYICAAAAA==.',['绿桑']='绿桑:BAAALAAECgYIBgAAAA==.',['美好']='美好的日子:BAAALAAECgYICwAAAA==.',['羽清']='羽清玄:BAAALAAECgUIBgAAAA==.',['翡翠']='翡翠星空:BAAALAAFFAIIAgAAAA==.',['老仙']='老仙男:BAACLAAFFH8gAAIEAAUIABpxHgBAAQAEAAUIABpxHgBAAQAsAAQKfzoAAgQACAiaIYAOAEcCAAQACAiaIYAOAEcCAAAA.',['胡子']='胡子好粗:BAAALAAFFAIIAgAAAA==.',['脆桃']='脆桃:BAAALAAFFAIIAgAAAA==.',['舞动']='舞动的弓弦:BAAALAAFFAQIBAAAAA==.',['艾录']='艾录奀:BAAALAADCgEIAQAAAA==.',['芙莉']='芙莉莲:BAAALAAECgQICAABLAAFFAcISQAhAB4mAA==.',['芙蕾']='芙蕾娅:BAAALAAFFAIIBAAAAA==.',['花鸟']='花鸟卷:BAAALAADCgMIAwAAAA==.',['苇名']='苇名一心:BAAALAAECgYIAwABLAAFFAYIBgAOAKsJAA==.',['苍气']='苍气炮:BAAALAAFFAIIAwAAAA==.',['苍白']='苍白骑士:BAAALAAECgIIAgAAAA==.',['苏丶']='苏丶墨染:BAAALAAFFAIIAgAAAA==.',['苏叶']='苏叶:BAAALAAECgQIBAABLAAFFAIIDAAWADUbAA==.',['苏州']='苏州食尸鬼:BAAALAADCgcIFAAAAA==.',['苏晓']='苏晓懒:BAAALAAFFAIIAgAAAA==.',['苏筱']='苏筱叶:BAACLAAFFH8MAAMWAAIINRvGDQBEAAAWAAIINRvGDQBEAAAUAAIICgQwEQAhAAAsAAQKfzQABBYACAjTH0sEAEwCABYABwiHI0sEAEwCABgABAiHF2GxAK4AABQAAggpB6I4ADkAAAAA.',['茉莉']='茉莉乌龙茶:BAABLAAFFH8GAAIJAAIIBxUuOgCeAAAJAAIIBxUuOgCeAAAAAA==.',['菊花']='菊花花:BAAALAAECgUIBQAAAA==.',['萌萌']='萌萌的蹄子:BAAALAAECgYICwAAAA==.',['葛洛']='葛洛莉亚医生:BAABLAAFFH8HAAMLAAYIKxJEKQCyAAALAAMIYgxEKQCyAAANAAQIVQctIgCmAAAAAA==.',['葡萄']='葡萄成熟时:BAAALAADCgYIBgAAAA==.',['蓝篮']='蓝篮路:BAACLAAFFH8KAAIMAAMIWR6HDgAKAQAMAAMIWR6HDgAKAQAsAAQKfzMAAgwACAgbI9wKAB0DAAwACAgbI9wKAB0DAAAA.',['蓝莓']='蓝莓麦酥:BAAALAAFFAIIBAABLAAFFAgIXgAEAKcmAA==.',['蛋蛋']='蛋蛋终结者:BAAALAADCgYIBgAAAA==.',['蝴蝶']='蝴蝶冢:BAAALAAECgYIBgAAAA==.蝴蝶梦冢:BAAALAAECgUIBQAAAA==.蝴蝶飞了:BAAALAAECgYICwAAAA==.',['袍师']='袍师:BAAALAAFFAgIBAAAAA==.',['被剥']='被剥削噶肥鸡:BAAALAAECgUIBQAAAA==.',['被迫']='被迫营业:BAABLAAFFH8FAAIFAAQIxRD8UADXAAAFAAQIxRD8UADXAAAAAA==.',['装了']='装了逼就跑:BAAALAAFFAIIAwAAAA==.',['装饭']='装饭的桶:BAAALAAECggIEAAAAA==.',['让我']='让我躺着:BAABLAAECn8fAAMEAAcIhA+KggCMAQAEAAcIZw6KggCMAQAGAAYI7QtpUgArAQAAAA==.',['象饼']='象饼干:BAACLAAFFH8OAAICAAMIlCOPNgDNAAACAAMIlCOPNgDNAAAsAAQKfxwAAgIACAhYImQbAAUDAAIACAhYImQbAAUDAAAA.',['贝蕾']='贝蕾瑞娅:BAABLAAFFH8GAAICAAIIEhbYUQBSAAACAAIIEhbYUQBSAAAAAA==.',['赞劲']='赞劲:BAAALAAECgUIBQAAAA==.',['超大']='超大杯柚美式:BAABLAAFFH8GAAIDAAYINxTqDQDEAQADAAYINxTqDQDEAQAAAA==.',['路边']='路边一涩牛:BAACLAAFFH8IAAIcAAIIeB0dQQBYAAAcAAIIeB0dQQBYAAAsAAQKfxQAAxwABgiSGx0+AGEBAA4ABgh7GXs6AJ0BABwABgiZFR0+AGEBAAAA.',['踏风']='踏风而行:BAABLAAFFH8RAAIhAAYICx7kCQCpAQAhAAYICx7kCQCpAQABLAAFFAgIIAAhAB0cAA==.',['蹦擦']='蹦擦擦:BAABLAAFFH8KAAIJAAMIiBquSACZAAAJAAMIiBquSACZAAAAAA==.',['躺尸']='躺尸老闆:BAABLAAFFH8FAAIFAAUIxQ6RSAAWAQAFAAUIxQ6RSAAWAQAAAA==.',['边塞']='边塞七哥:BAAALAAECgEIAQAAAA==.',['近战']='近战停手:BAAALAAECgUIBQAAAA==.',['迪科']='迪科小野:BAAALAAECgYIBgAAAA==.',['迷人']='迷人的妖妖:BAAALAADCgcIBwAAAA==.',['迷踪']='迷踪谍影:BAACLAAFFH8IAAIiAAIIzgomGQA7AAAiAAIIzgomGQA7AAAsAAQKfxcAAiIABgjaF3QVAGQBACIABgjaF3QVAGQBAAAA.',['遗忘']='遗忘的永恒:BAAALAADCgIIAgAAAA==.',['遥远']='遥远辰星:BAABLAAECn8ZAAILAAcIhxeUVgDhAQALAAcIhxeUVgDhAQAAAA==.',['邪能']='邪能李伯清:BAAALAAECgMIAwAAAA==.',['部落']='部落它爷爷:BAABLAAFFH8RAAIIAAYI+QmbEwBTAQAIAAYI+QmbEwBTAQAAAA==.',['酒酿']='酒酿大芋圆:BAABLAAFFH8HAAIFAAQIuAf4UwDAAAAFAAQIuAf4UwDAAAAAAA==.酒酿小萌萌:BAAALAAECgIIAgAAAA==.',['醉花']='醉花二两酒:BAAALAAECggICAAAAA==.',['重生']='重生的陌蓝:BAAALAAECgYICAAAAA==.',['钻石']='钻石肥:BAACLAAFFH8GAAIOAAIIGxKiHgCBAAAOAAIIGxKiHgCBAAAsAAQKfxQAAg4ABwhGGh8tAOMBAA4ABwhGGh8tAOMBAAAA.',['铁血']='铁血战无情:BAAALAADCgIIAgAAAA==.铁血无情:BAAALAAECgYIDAAAAA==.',['银河']='银河星落:BAACLAAFFH8OAAIFAAMIoQpRaAB2AAAFAAMIoQpRaAB2AAAsAAQKfxcAAgUABwiBGfRQAFIBAAUABwiBGfRQAFIBAAAA.银河魔装机神:BAABLAAFFH8HAAIHAAIIZxKjTQCPAAAHAAIIZxKjTQCPAAABLAAFFAIICgAMADsLAA==.',['键盘']='键盘侠:BAAALAADCgQIBAAAAA==.',['阿拉']='阿拉贡陨灭:BAAALAAECgYIBgAAAA==.',['阿斯']='阿斯塔罗特:BAAALAAFFAIIAgAAAA==.',['阿牛']='阿牛弟:BAAALAAECggICgAAAA==.',['阿肥']='阿肥:BAAALAAECgcIDQAAAA==.',['陌殇']='陌殇别离:BAAALAAFFAIIAgAAAA==.',['雁鸠']='雁鸠雕狸狮狒:BAAALAADCgQIBQAAAA==.',['雷切']='雷切:BAABLAAFFH8UAAIHAAYIcx7ZEADaAQAHAAYIcx7ZEADaAQAAAA==.雷切波罗蜜:BAAALAADCgEIAQAAAA==.',['霍比']='霍比特矮子:BAABLAAFFH8KAAIJAAYIkQ6gMQBRAQAJAAYIkQ6gMQBRAQAAAA==.',['霸鼻']='霸鼻主理人:BAABLAAFFH8MAAMHAAYIjgjUGAATAQAHAAYIjgjUGAATAQAPAAEIegEdHQAsAAAAAA==.霸鼻大湾仔:BAABLAAFFH8GAAIDAAYIggTxGgAuAQADAAYIggTxGgAuAQAAAA==.',['青茶']='青茶丷苦涩:BAAALAAECgYICwAAAA==.',['靓仔']='靓仔看下手牌:BAAALAAECgYICAAAAA==.',['音樂']='音樂盒的回憶:BAABLAAFFH8FAAIFAAIIfQ/FhwBCAAAFAAIIfQ/FhwBCAAAAAA==.',['风暴']='风暴烈乳:BAAALAAFFAIIAgAAAA==.',['风烟']='风烟愺树:BAABLAAFFH8RAAIVAAII6h90AwCmAAAVAAII6h90AwCmAAAAAA==.风烟花树:BAAALAAFFAIIBAABLAAFFAIIEQAVAOofAA==.',['风錨']='风錨錨:BAABLAAFFH8HAAILAAIIIw9lVABoAAALAAIIIw9lVABoAAAAAA==.',['飛龍']='飛龍在地:BAAALAAECggIEAAAAA==.',['飞翔']='飞翔的兔子:BAAALAADCgUIBQAAAA==.飞翔的大白兔:BAAALAAECgQIBAAAAA==.',['飞虎']='飞虎神鹰:BAABLAAFFH8JAAIDAAMIMhAebQCIAAADAAMIMhAebQCIAAAAAA==.',['马可']='马可波罗蜜:BAABLAAFFH80AAIJAAcI/yIVCgBeAgAJAAcI/yIVCgBeAgABLAAFFAcINAAJAP8iAA==.',['骑剑']='骑剑下海:BAAALAADCgYIBgAAAA==.',['高小']='高小琴:BAAALAAECgYICgAAAA==.',['高等']='高等数学下:BAAALAAECgUIBgAAAA==.',['鬼头']='鬼头:BAAALAAECgcIEgAAAA==.',['魔法']='魔法鼠:BAAALAADCgcIBwAAAA==.',['鳍英']='鳍英:BAABLAAECn8VAAIFAAYIbBppowDCAQAFAAYIbBppowDCAQAAAA==.',['鸡毛']='鸡毛在燃烧:BAAALAAECgYIBgAAAA==.',['鹧鸪']='鹧鸪菜:BAAALAAFFAEIAQAAAA==.',['麒麟']='麒麟儿:BAAALAAECgMIAwAAAA==.',['黑剑']='黑剑玛里喀斯:BAAALAAECgYIBgAAAA==.',['黑天']='黑天白夜:BAAALAAECgYICwAAAA==.',['黑择']='黑择明:BAABLAAFFH8KAAIFAAIIXgxgcACQAAAFAAIIXgxgcACQAAABLAAFFAIICgAMADsLAA==.',['黯香']='黯香疏影:BAABLAAFFH8GAAIHAAII+RH9TgBKAAAHAAII+RH9TgBKAAAAAA==.',['龍虾']='龍虾:BAAALAAECgYICQAAAA==.',['龙背']='龙背上的必吃:BAAALAAECgYIBgAAAA==.',['龙须']='龙须面:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end