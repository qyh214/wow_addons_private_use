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
 local lookup = {'Warrior-Protection','Warrior-Fury','Mage-Arcane','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Unknown-Unknown','Druid-Restoration','Warlock-Demonology','Priest-Holy','DemonHunter-Havoc','Warlock-Destruction','Warlock-Affliction','Druid-Balance','Mage-Fire','Mage-Frost','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','Priest-Shadow','Shaman-Restoration','Shaman-Elemental','Warrior-Arms','Druid-Feral','Druid-Guardian','DeathKnight-Frost','Hunter-BeastMastery','DeathKnight-Blood','DemonHunter-Vengeance','Hunter-Marksmanship','Evoker-Preservation','DeathKnight-Unholy','Evoker-Augmentation','Monk-Mistweaver','Monk-Windwalker',}; local provider = {region='CN',realm='大地之怒',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Anwärter:BAABLAAFFH8PAAMBAAYIdh7kAwD5AQABAAYIixjkAwD5AQACAAYILxqXEwC9AQAAAA==.',As='Asunayasina:BAAALAAFFAIIAgAAAA==.',Au='Aurorius:BAACLAAFFH8aAAIDAAUIIx3kLABaAQADAAUIIx3kLABaAQAsAAQKfxsAAgMACAhTH84nAK0CAAMACAhTH84nAK0CAAAA.',Bl='Blackboy:BAAALAAECgEIAQAAAA==.',Br='Brüno:BAAALAADCgYICQAAAA==.',Ca='Caitlin:BAAALAAECggICAAAAA==.Carllic:BAABLAAFFH8pAAIDAAYI7xWiHQCiAQADAAYI7xWiHQCiAQAAAA==.Carving:BAABLAAFFH8LAAMEAAMIrCKaNwDDAAAEAAMIrCKaNwDDAAAFAAIIOCJzEgBgAAAAAA==.',Ch='Chengdurc:BAAALAAFFAIIAgAAAA==.',Ci='Cill:BAAALAAECgYICAAAAA==.',Da='Daname:BAAALAAECgYIBgABLAAFFAYICAAEAJMQAA==.',Dd='Ddname:BAACLAAFFH8IAAMEAAYIkxBmIABmAQAEAAYIkxBmIABmAQAGAAIIiApTIACHAAAsAAQKfygABAUABggQHb0QAKIBAAUABggQHb0QAKIBAAYABgjmE+IdAFcBAAQAAgg7F/O5AIcAAAAA.',De='Devimon:BAAALAADCgYIBgABLAAECgEIAQAHAAAAAA==.',Dl='Dlname:BAAALAAECgQIBAABLAAFFAYICAAEAJMQAA==.',Do='Doname:BAACLAAFFH8KAAIIAAMIziKHIAAbAQAIAAMIziKHIAAbAQAsAAQKfyUAAggABgjEHpw9AOkBAAgABgjEHpw9AOkBAAEsAAUUBggIAAQAkxAA.Donk:BAAALAADCgcIDQAAAA==.Doublem:BAAALAAECgQICAAAAA==.',Dr='Drenched:BAAALAAECgYICQAAAA==.',El='Elysia:BAAALAAFFAIIAgAAAA==.',Er='Ernstwang:BAAALAAECgQIBAAAAA==.',Go='Goel:BAAALAADCgcIBwAAAA==.',Gu='Guitar:BAAALAAECgYIBwAAAA==.',['Gò']='Gòdlikes:BAABLAAFFH8QAAICAAUI2BUqJQBFAQACAAUI2BUqJQBFAQAAAA==.',Il='Illusion:BAABLAAFFH8GAAIJAAIIeSEaDQBYAAAJAAIIeSEaDQBYAAAAAA==.',Im='Imtired:BAAALAAFFAIIAgAAAA==.',Ja='Jaychen:BAABLAAFFH8fAAIKAAYIshdKEgDIAQAKAAYIshdKEgDIAQABLAAFFAYIKQADAO8VAA==.',Li='Linksp:BAAALAADCgcICwAAAA==.',Ma='Macchiatoo:BAABLAAFFH8LAAILAAMIHxxIFwAhAQALAAMIHxxIFwAhAQAAAA==.Maxm:BAAALAAECgMIBAAAAA==.',Mo='Moguls:BAAALAAFFAYIAgAAAA==.Momhunter:BAABLAAFFH8GAAILAAII3wYyXwA/AAALAAII3wYyXwA/AAAAAA==.Moonchild:BAAALAAECgUIBgAAAA==.',Ne='Neverbrecth:BAABLAAFFH8GAAIEAAIIViBMIwDFAAAEAAIIViBMIwDFAAAAAA==.',Ni='Nightmars:BAAALAADCgUIBQAAAA==.',Pa='Patapon:BAAALAAECgYIBgAAAA==.',Pl='Playerjsxexp:BAAALAADCgQIBAAAAA==.',Re='Regrets:BAAALAAECgUIBQAAAA==.Reisenbeer:BAACLAAFFH8yAAMMAAgIGSLKBgCRAgAMAAgIxCHKBgCRAgANAAII9B26AgC5AAAsAAQKfz0AAwwACAjoJckEAHADAAwACAizJckEAHADAA0ACAjwGRUIAEQCAAAA.Reislin:BAAALAAECgcIDgABLAAFFAgIDQAOAKoDAA==.',Ro='Rongcheng:BAABLAAFFH8MAAIEAAMIrxopOwCqAAAEAAMIrxopOwCqAAAAAA==.',Ry='Rylynn:BAACLAAFFH8GAAIDAAIIZhDXVgBEAAADAAIIZhDXVgBEAAAsAAQKfxcAAwMACAgEGmAbAM4BAAMACAgEGmAbAM4BAA8AAghvEQMTAD8AAAAA.',Sc='Scrooged:BAAALAAECgYIBwAAAA==.',Si='Simondemon:BAAALAAECgQIBwAAAA==.Simonmage:BAAALAAECgQIBgAAAA==.Simonmonk:BAAALAAECgIIAgAAAA==.',Sl='Slaughtermen:BAAALAAFFAIIAgAAAA==.',So='Solazola:BAAALAAECgEIAQAAAA==.Sorata:BAABLAAFFH8GAAIQAAII2hQZEACPAAAQAAII2hQZEACPAAAAAA==.',St='Staatlich:BAABLAAFFH8FAAQRAAII+xAYBQCTAAARAAIIag4YBQCTAAASAAEI7xTKGQBMAAATAAIIjgdbFwA6AAABLAAFFAgIIgALAGEcAA==.Stargazerc:BAAALAAECgQIBAAAAA==.',Th='Thebs:BAAALAADCgMIAwAAAA==.',Ub='Ubear:BAAALAADCgcIBwAAAA==.',Va='Vavan:BAAALAAECgcIBwAAAA==.',Ve='Veznan:BAABLAAFFH8IAAIDAAYIVgyFEQDaAQADAAYIVgyFEQDaAQAAAA==.',Wl='Wly:BAAALAAECgUIBQAAAA==.',Xi='Xiaosun:BAABLAAFFH8FAAIUAAUIgAAmNAALAAAUAAUIgAAmNAALAAAAAA==.',Yi='Yilidan:BAAALAADCggICAAAAA==.',Zo='Zolpidem:BAABLAAFFH8XAAMVAAYI3x7lCgAeAgAVAAYI3x7lCgAeAgAWAAIIKQc1TwA2AAAAAA==.',Zy='Zypressen:BAAALAAFFAIIAgAAAA==.',['一万']='一万次悲伤:BAAALAAECgUIBQAAAA==.',['一个']='一个人的任性:BAAALAAECgYIBgAAAA==.一个人的天空:BAAALAAECgEIAQAAAA==.',['一减']='一减伤开:BAAALAAECgUICwAAAA==.',['一千']='一千减七:BAAALAADCggICgAAAA==.',['一笑']='一笑奈何:BAAALAAFFAIIAwAAAA==.',['一箭']='一箭穿昕:BAAALAAFFAYIBAAAAA==.',['一路']='一路向北:BAAALAAECgYIBgAAAA==.',['丁达']='丁达尔:BAAALAADCgIIBAAAAA==.',['七夕']='七夕:BAAALAAECgYIBgAAAA==.',['七月']='七月尾鸢:BAAALAAFFAIIAgAAAA==.',['三千']='三千焱焱:BAAALAADCggICAAAAA==.',['上白']='上白沢慧音:BAAALAAFFAIIAgAAAA==.',['且听']='且听風吟:BAABLAAFFH8WAAQCAAYI8w+MHgB1AQACAAYI5A2MHgB1AQABAAIIyxebGwCKAAAXAAIIoAnfBQCEAAAAAA==.',['且弑']='且弑天下:BAACLAAFFH8ZAAQYAAYIDx9KBAB9AQAYAAUIIiFKBAB9AQAOAAQIHA9gFADCAAAZAAEIsBRyCwA/AAAsAAQKfxoAAg4ABwjRHdUpACICAA4ABwjRHdUpACICAAAA.',['世一']='世一牧:BAABLAAFFH8GAAIKAAII/wV+RgBeAAAKAAII/wV+RgBeAAAAAA==.',['两巴']='两巴掌铲死你:BAABLAAFFH8MAAICAAMINBGkNwCUAAACAAMINBGkNwCUAAAAAA==.',['丨莽']='丨莽夫丨:BAAALAAECgMIAwAAAA==.',['丶北']='丶北归:BAABLAAFFH8GAAIaAAII7RK5agCTAAAaAAII7RK5agCTAAAAAA==.',['丶弗']='丶弗蕾亚丶:BAAALAAECgIIAgAAAA==.',['丶打']='丶打酱油丶:BAAALAAECgYIDAAAAA==.',['丶蕾']='丶蕾娜丝丶:BAAALAAECgMIBAAAAA==.',['丶頹']='丶頹廢記憶灬:BAABLAAFFH8JAAIbAAYIgQ4GSgAjAQAbAAYIgQ4GSgAjAQAAAA==.',['主題']='主題曲:BAABLAAFFH8MAAQJAAII5xilGgCNAAAJAAIIFBelGgCNAAANAAEILBZICABQAAAMAAEIKgZ1bgAxAAAAAA==.',['乌喜']='乌喜空:BAAALAAECgYICAAAAA==.',['乌喵']='乌喵喵王:BAAALAAECgIIAgAAAA==.',['乱世']='乱世之主:BAAALAAFFAIIAgAAAA==.',['于大']='于大咪:BAAALAADCgQIBAAAAA==.',['五指']='五指拳心剑:BAABLAAFFH8NAAMaAAUI3xTBQwAsAQAaAAUI3xTBQwAsAQAcAAII3hFmEACEAAAAAA==.',['五柳']='五柳先生:BAAALAAECgUIBQAAAA==.',['五百']='五百亿:BAAALAADCgYIBgAAAA==.',['人生']='人生如此纠结:BAABLAAFFH8KAAIaAAMIkhieWQCeAAAaAAMIkhieWQCeAAAAAA==.',['从小']='从小愛萌萌:BAAALAAECgUIBQAAAA==.',['仙女']='仙女:BAAALAAECgYIBgAAAA==.',['伊犁']='伊犁鸽子蛋:BAAALAAECgYIBgAAAA==.',['伏心']='伏心猿降意马:BAABLAAECn8XAAMLAAcIIBrVJADLAQALAAcIIBrVJADLAQAdAAYI8g6MFgDzAAAAAA==.',['低调']='低调的小白:BAAALAAFFAEIAgAAAA==.',['你哪']='你哪个单位的:BAAALAAECgYIBwAAAA==.',['俐風']='俐風兹:BAAALAAECgYIBgAAAA==.',['俺是']='俺是耕田嗲:BAAALAAECgIIAgAAAA==.',['傲娇']='傲娇的凯哥哥:BAAALAADCgYIBgAAAA==.',['元素']='元素无用:BAAALAAECgYICwAAAA==.',['克利']='克利夫兰:BAAALAADCgEIAQAAAA==.',['克鲁']='克鲁索尔刃拳:BAABLAAFFH8MAAIaAAIIkQ4gdQCNAAAaAAIIkQ4gdQCNAAAAAA==.',['六道']='六道灬菩提:BAAALAADCgcIBwAAAA==.',['养什']='养什么都会死:BAABLAAFFH8GAAIeAAIIuxdPFQBFAAAeAAIIuxdPFQBFAAAAAA==.',['再狗']='再狗叫:BAABLAAFFH8SAAIfAAYIdRb8CgCkAQAfAAYIdRb8CgCkAQAAAA==.',['冲动']='冲动的结果:BAAALAAFFAMIAwAAAA==.',['冲锋']='冲锋吧宝宝:BAAALAADCgMIAwAAAA==.',['冷锋']='冷锋:BAAALAAECgYIEgAAAA==.',['凌乱']='凌乱的长发:BAAALAAECgYIBgAAAA==.',['凌塔']='凌塔风歌:BAAALAAFFAMIAwAAAA==.',['凌夜']='凌夜:BAACLAAFFH8JAAISAAIIkg8vGACeAAASAAIIkg8vGACeAAAsAAQKfxQAAhIABgjxIR0YAFQCABIABgjxIR0YAFQCAAAA.',['刀锋']='刀锋易冷:BAAALAAECgYIDwAAAA==.刀锋釹王:BAAALAAECgYIBgAAAA==.',['刘能']='刘能:BAAALAAECgYIBgAAAA==.',['删号']='删号重来:BAAALAAECgEIAQAAAA==.',['别狗']='别狗叫:BAABLAAFFH8oAAIfAAgIaxpeAgC4AgAfAAgIaxpeAgC4AgAAAA==.',['前羿']='前羿:BAAALAAECgUIBQAAAA==.',['剑湾']='剑湾魅影:BAAALAAFFAQIBAAAAA==.',['劍與']='劍與玫瑰:BAAALAADCgEIAQAAAA==.',['动感']='动感蜗牛:BAAALAAFFAIIAgAAAA==.',['动物']='动物变形记:BAAALAAECgYIBwAAAA==.',['劲杀']='劲杀绝:BAACLAAFFH8WAAICAAYIIRVlHACFAQACAAYIIRVlHACFAQAsAAQKfxQAAgIABgieH6tVAPABAAIABgieH6tVAPABAAAA.',['劳资']='劳资又没蓝了:BAAALAAECgYIBgAAAA==.',['北丶']='北丶嘚嘚:BAAALAAECgYIBgAAAA==.',['北川']='北川真由香:BAABLAAFFH8OAAMQAAIIOxqaFQBEAAAQAAIIOxqaFQBEAAADAAIILgiHYAA7AAAAAA==.',['北极']='北极:BAAALAAECgYIBgAAAA==.',['午后']='午后的喵小乌:BAAALAAECgQIBAAAAA==.',['半只']='半只月丶:BAAALAAECgYIBgAAAA==.',['半夏']='半夏微寒:BAABLAAFFH8GAAIQAAIIqhFDGQB0AAAQAAIIqhFDGQB0AAAAAA==.',['卡卡']='卡卡诺斯:BAABLAAFFH8GAAIIAAYI7x24AgAiAgAIAAYI7x24AgAiAgAAAA==.',['卡珊']='卡珊雷蹄:BAAALAAECgIIAgAAAA==.',['卢卡']='卢卡东契奇:BAABLAAFFH8FAAIDAAIIig4IUACRAAADAAIIig4IUACRAAAAAA==.',['卷卷']='卷卷芽芽:BAAALAAECgMIAwAAAA==.',['双刀']='双刀就看你:BAAALAAECgEIAQAAAA==.',['双剑']='双剑华斩:BAAALAAECgIIAgAAAA==.',['变的']='变的心烦:BAAALAAECggICgAAAA==.',['叛逆']='叛逆的丫丫:BAAALAAFFAIIAgAAAA==.',['古伊']='古伊爾:BAAALAAECgYIEQAAAA==.',['古尔']='古尔加:BAAALAADCgQIBAAAAA==.',['叶子']='叶子殿下灬:BAAALAAECgYICwAAAA==.',['叶落']='叶落花繁:BAAALAAFFAIIBAAAAA==.',['吃毒']='吃毒蘑菇啦:BAABLAAFFH8OAAIfAAYIthpDCQDJAQAfAAYIthpDCQDJAQAAAA==.',['听讲']='听讲你叫我:BAACLAAFFH8wAAMEAAYIaSUABgAkAgAEAAYIaSUABgAkAgAFAAMIWRf4BwDhAAAsAAQKfyUAAwQACAhDJd0HAGQDAAQACAhDJd0HAGQDAAUABQh3H6o1AHIBAAAA.',['吻痕']='吻痕:BAAALAAFFAIIBAAAAA==.',['呜丶']='呜丶妖気丶:BAAALAAFFAIIAgAAAA==.',['和蔼']='和蔼的庆姐姐:BAAALAADCgYIBgAAAA==.',['咖啡']='咖啡豆:BAABLAAFFH8WAAIIAAUIfhQwGwBSAQAIAAUIfhQwGwBSAQAAAA==.',['哆啦']='哆啦果:BAAALAAECgMIAwAAAA==.',['哇呀']='哇呀哇呀哇:BAAALAAECgYICwAAAA==.',['哈丶']='哈丶妖気丶:BAAALAAFFAIIAgAAAA==.',['哈廖']='哈廖尔雷蹄:BAAALAAFFAEIAQAAAA==.',['哎呦']='哎呦不错:BAAALAAFFAIIBAAAAA==.',['唰丶']='唰丶妖気丶:BAACLAAFFH9OAAMDAAcI4RuXEQDZAQADAAYIpxyXEQDZAQAPAAEIOxd5CgBPAAAsAAQKfxYAAgMACAjnIY0cAOACAAMACAjnIY0cAOACAAAA.',['唱歌']='唱歌的好美:BAAALAAECgYIBwAAAA==.',['喵喵']='喵喵影风:BAAALAAECggICQAAAA==.喵喵灵风:BAAALAAECgUIBQAAAA==.喵喵迅风:BAAALAAECgEIAQAAAA==.喵喵龍风:BAAALAAECggICAAAAA==.',['嗖丶']='嗖丶妖気:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血雷霆:BAAALAAECggIDwAAAA==.',['嗮鸡']='嗮鸡:BAAALAAECgYIBgAAAA==.',['嗯哼']='嗯哼嗯哼:BAAALAAFFAIIBAAAAA==.',['嗯嗯']='嗯嗯:BAAALAAFFAIIAgAAAA==.',['噗霪']='噗霪鎏:BAAALAAECgYIBwAAAA==.',['嚒嚒']='嚒嚒牛:BAABLAAECn8hAAIZAAcIZh+FCABrAgAZAAcIZh+FCABrAgAAAA==.',['嚣张']='嚣张的很:BAAALAAECgYIBgAAAA==.',['团灭']='团灭小助手:BAAALAAECgUIBQAAAA==.团灭小帮手:BAAALAAECgQIBAAAAA==.',['图腾']='图腾肥牛:BAABLAAFFH8OAAIVAAMIICTcIADKAAAVAAMIICTcIADKAAAAAA==.',['土巴']='土巴拉鸡:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光的动力煤:BAAALAAECggICAAAAA==.',['圣弗']='圣弗丁:BAAALAADCgIIAgAAAA==.',['塞萨']='塞萨里安:BAAALAAECggIBwAAAA==.',['墨邪']='墨邪邪:BAAALAAFFAIIAgAAAA==.',['墨非']='墨非:BAABLAAFFH8cAAMGAAUI/BuLDAAZAQAGAAUI/BuLDAAZAQAEAAQI2hUwNQDYAAABLAAFFAgIIgALAGEcAA==.',['壹俐']='壹俐箪:BAAALAADCgQIBAAAAA==.',['夏季']='夏季八取:BAAALAAFFAIIBAAAAA==.',['夏小']='夏小正丿:BAAALAADCgYIBgAAAA==.',['夏沫']='夏沫诗韵:BAABLAAFFH8KAAIDAAIIyAsYXgA9AAADAAIIyAsYXgA9AAAAAA==.',['夏雨']='夏雨下鱼:BAABLAAFFH8KAAMbAAgIrwVCYQC4AAAbAAgIwQJCYQC4AAAeAAIIuw87EAB5AAAAAA==.',['夏雪']='夏雪瑶:BAAALAAFFAIIBAAAAA==.',['多莫']='多莫克萨拉莫:BAAALAAECgYIBgAAAA==.',['夜幕']='夜幕:BAAALAAECgQIBAAAAA==.',['夜空']='夜空最亮星:BAAALAAECgYICAAAAA==.',['大久']='大久保龄球:BAABLAAFFH8GAAIaAAIIyyIvNQDKAAAaAAIIyyIvNQDKAAAAAA==.',['大八']='大八鸡:BAACLAAFFH8IAAMeAAIItRAYLQBrAAAbAAIIpAwfeQBzAAAeAAIIHAgYLQBrAAAsAAQKfyIAAxsABwgQHO6BANsBABsABgiGHu6BANsBAB4ABwgBE6JPAHcBAAAA.',['大吧']='大吧唧:BAABLAAFFH8WAAICAAYIWxmaGQCWAQACAAYIWxmaGQCWAQAAAA==.',['大地']='大地的猎变:BAAALAAFFAIIAgAAAA==.',['大排']='大排球:BAAALAADCgIIAgAAAA==.',['大白']='大白兔吃萝卜:BAAALAAECggIEAAAAA==.大白兔收萝卜:BAAALAAECggICAAAAA==.',['大肠']='大肠头:BAABLAAFFH8GAAIBAAIIqQjkKABsAAABAAIIqQjkKABsAAAAAA==.',['大脑']='大脑一片空白:BAAALAAECgYIBgAAAA==.',['大霸']='大霸鸡:BAABLAAFFH8NAAIbAAMIOh50IAAFAQAbAAMIOh50IAAFAQAAAA==.',['天地']='天地会陈进南:BAAALAADCggICAAAAA==.',['天天']='天天使:BAACLAAFFH8LAAIDAAMILBr7QgCXAAADAAMILBr7QgCXAAAsAAQKfxcAAgMABgjcHUBSAA4CAAMABgjcHUBSAA4CAAAA.',['天空']='天空与风之王:BAAALAAECgQIBAAAAA==.',['天籁']='天籁纸鸢:BAAALAADCgIIAgAAAA==.',['天赐']='天赐良鸡:BAABLAAFFH8GAAMaAAIIJhzHQgCvAAAaAAIIJhzHQgCvAAAgAAEI1AqDHgBMAAAAAA==.',['失忆']='失忆之蝶:BAAALAAFFAIIAgAAAA==.',['夺宝']='夺宝奇兵:BAAALAAECgYIDAAAAA==.',['奔跑']='奔跑的咸鱼丶:BAAALAADCgIIAgAAAA==.',['奥蛋']='奥蛋肥牛:BAAALAAECgEIAQAAAA==.',['奶牛']='奶牛麻麻:BAABLAAFFH8KAAIIAAQIOA82KADVAAAIAAQIOA82KADVAAAAAA==.',['奶量']='奶量不足:BAABLAAFFH8IAAIVAAIItSLKOQC8AAAVAAIItSLKOQC8AAAAAA==.',['好牛']='好牛:BAAALAADCgYIDAAAAA==.',['如何']='如何回忆我:BAAALAADCgYIBwAAAA==.',['如初']='如初丶:BAAALAAFFAYIBAAAAA==.',['如影']='如影随形:BAAALAAECgQIBAAAAA==.',['妈宝']='妈宝男:BAAALAAFFAIIAgAAAA==.',['威武']='威武超哥:BAAALAADCggICAAAAA==.',['安东']='安东尼的玫瑰:BAAALAAECgEIAQAAAA==.',['安安']='安安牧:BAAALAAECgIIAgAAAA==.',['安杰']='安杰贼哥:BAACLAAFFH8HAAISAAIIjBIOHACNAAASAAIIjBIOHACNAAAsAAQKfxgAAhIABginGowNAIsBABIABginGowNAIsBAAAA.',['安若']='安若丶浮生:BAAALAAFFAIIAgAAAA==.安若忆浮生:BAAALAAECggICAAAAA==.',['寒山']='寒山寺:BAACLAAFFH8IAAIIAAIILwlJTgBWAAAIAAIILwlJTgBWAAAsAAQKfxQAAggACAjpFeQhAMQBAAgACAjpFeQhAMQBAAAA.',['對我']='對我彈琴我懂:BAAALAAFFAIIAgAAAA==.',['小四']='小四龙:BAABLAAFFH8RAAIhAAYImgBvDACAAAAhAAYImgBvDACAAAAAAA==.',['小奶']='小奶娘:BAAALAAFFAIIAgAAAA==.小奶萨:BAAALAAFFAIIBAAAAA==.',['小排']='小排球:BAAALAADCgYICQAAAA==.',['小新']='小新没蜡笔:BAABLAAFFH8PAAIEAAYIMweVQwCcAAAEAAYIMweVQwCcAAAAAA==.',['小甜']='小甜甜牛夫人:BAAALAAECgUIBQAAAA==.',['小羊']='小羊:BAAALAAECgYIBgAAAA==.',['小苏']='小苏苏:BAABLAAECn8bAAIMAAgIYRSMUAAAAgAMAAgIYRSMUAAAAgAAAA==.',['小鑫']='小鑫鑫有梦想:BAAALAAECgQIBgAAAA==.',['小铭']='小铭同学:BAABLAAFFH8KAAIiAAII3RfODgCgAAAiAAII3RfODgCgAAAAAA==.',['尣巛']='尣巛怹:BAAALAAECgMIBAAAAA==.',['尼古']='尼古拉赵四:BAAALAAECgYICwAAAA==.',['山有']='山有牧:BAAALAAECgYIBwAAAA==.',['巜巜']='巜巜巛丄:BAAALAAECgYIBgAAAA==.',['左手']='左手拿刀:BAAALAAFFAIIAgAAAA==.',['左角']='左角清明:BAABLAAFFH8GAAIWAAIIIRBoRABEAAAWAAIIIRBoRABEAAAAAA==.',['帕拉']='帕拉丁:BAAALAAFFAIIBAAAAA==.帕拉梅拉煤:BAABLAAFFH8LAAIFAAMIWg4hEgBjAAAFAAMIWg4hEgBjAAAAAA==.',['帝狱']='帝狱男爵:BAAALAAECggICQAAAA==.',['帶倪']='帶倪俬渀:BAAALAAFFAIIAgAAAA==.',['庆乖']='庆乖乖:BAAALAADCgUIBQAAAA==.',['库萨']='库萨帕利:BAAALAAECggICAAAAA==.',['建南']='建南春春:BAAALAAECgYIBgAAAA==.',['弃世']='弃世裁决:BAAALAAFFAIIBAAAAA==.',['弓弯']='弓弯羽落:BAAALAADCggICAAAAA==.',['弹琴']='弹琴的牛顿:BAAALAAECggIEwAAAA==.弹琴的猛牛:BAAALAAECggICAAAAA==.',['影丢']='影丢丢:BAACLAAFFH8QAAMbAAMIBhuINQC5AAAbAAMIBhuINQC5AAAeAAIIxQ77JwB4AAAsAAQKfxkAAxsACAi6IJU0AIkCABsACAjFHpU0AIkCAB4ABwg/FuhAALMBAAAA.',['彳亍']='彳亍:BAAALAAECgMIAgAAAA==.',['很久']='很久很久以后:BAABLAAFFH8PAAMEAAYIDAxzLgASAQAEAAYIYwRzLgASAQAFAAMIIhT3DwCAAAAAAA==.',['微笑']='微笑的眼睛:BAAALAAECgYIBgAAAA==.',['德憨']='德憨憨:BAAALAAECgMIAwAAAA==.',['心袁']='心袁灬懿马:BAACLAAFFH8OAAMMAAYI0x18HgCjAQAMAAYI0x18HgCjAQAJAAIIBw3MGACSAAAsAAQKfxYAAwwACAi/IR0LAJ4CAAwACAi/IR0LAJ4CAAkABAh2FlteAP4AAAAA.',['忧郁']='忧郁啊:BAAALAAECgQIBgAAAA==.',['快乐']='快乐德玩耍:BAAALAADCggICAAAAA==.',['忽然']='忽然之间:BAAALAAFFAEIAQAAAA==.',['恐怖']='恐怖双刀人:BAAALAAFFAIIAwAAAA==.',['恒小']='恒小球:BAAALAAECgUICgAAAA==.',['恴甪']='恴甪弈:BAAALAAECgQIBAAAAA==.',['情定']='情定雪月天:BAAALAAECgIIAwAAAA==.',['惊异']='惊异卡布尔:BAABLAAFFH8MAAIaAAIIKh05TACkAAAaAAIIKh05TACkAAAAAA==.惊异巴斯塔:BAAALAAFFAIIBAAAAA==.惊异百式改:BAAALAAECgYIBgAAAA==.惊异红武者:BAABLAAFFH8KAAIbAAIIXB8WOACzAAAbAAIIXB8WOACzAAAAAA==.',['慌得']='慌得一批:BAAALAAECgYICQAAAA==.',['憨憨']='憨憨小德:BAABLAAFFH8FAAIIAAUIXBroEgClAQAIAAUIXBroEgClAQAAAA==.憨憨小术:BAAALAAFFAIIAgABLAAFFAYIBQAIAFwaAA==.憨憨小法:BAACLAAFFH8KAAIDAAII9hxGNwCuAAADAAII9hxGNwCuAAAsAAQKfxQAAgMABwiBHqFEADsCAAMABwiBHqFEADsCAAEsAAUUBggFAAgAXBoA.憨憨小萨:BAABLAAFFH8GAAIVAAII8SPLHgDQAAAVAAII8SPLHgDQAAABLAAFFAYIBQAIAFwaAA==.憨憨小默:BAABLAAFFH8HAAIaAAMI4RcwXACWAAAaAAMI4RcwXACWAAABLAAFFAYIBQAIAFwaAA==.憨憨小龙:BAABLAAFFH8IAAIfAAMIWSJxEQALAQAfAAMIWSJxEQALAQABLAAFFAYIBQAIAFwaAA==.',['我不']='我不听我没错:BAAALAAECggIAQAAAA==.',['我会']='我会插棒子:BAAALAAECgUIBQAAAA==.',['我又']='我又躲起来了:BAAALAADCgYIBgAAAA==.',['我帅']='我帅的挨千刀:BAAALAAFFAIIBAAAAA==.',['我想']='我想抓个熊:BAAALAAECgcIBwAAAA==.',['我是']='我是小骑士:BAAALAAFFAEIAQAAAA==.我是真滴菜:BAAALAAECggICAABLAAFFAMIBgAaAGkSAA==.',['我王']='我王铠牙:BAAALAAFFAIIAgAAAA==.',['我脆']='我脆:BAAALAAECgQIBgAAAA==.',['我花']='我花开后:BAABLAAECn8cAAIaAAYIwxBQYwAoAQAaAAYIwxBQYwAoAQAAAA==.',['战憨']='战憨憨:BAAALAADCgMIAwAAAA==.',['战硬']='战硬战:BAAALAAECgIIAgAAAA==.',['战神']='战神啤酒:BAAALAAECgQIBAAAAA==.',['所念']='所念皆如愿:BAABLAAFFH8GAAIQAAIIZQzAFgB+AAAQAAIIZQzAFgB+AAAAAA==.',['所蓝']='所蓝:BAABLAAFFH8xAAIKAAcIbBvBCQAtAgAKAAcIbBvBCQAtAgAAAA==.',['托柒']='托柒唔识转驳:BAABLAAFFH8tAAIMAAYIEiHKGADFAQAMAAYIEiHKGADFAQAAAA==.',['把鼠']='把鼠标拿开:BAAALAAECgEIAQAAAA==.',['投内']='投内酷:BAAALAAFFAMIAwAAAA==.',['拉轰']='拉轰的凯哥哥:BAAALAADCgUIBQAAAA==.',['招财']='招财进宝侠:BAAALAAECgIIAgAAAA==.',['拳脚']='拳脚双绝:BAAALAAECgQIBQAAAA==.',['拾初']='拾初:BAAALAAECgYIBgAAAA==.',['拾柒']='拾柒:BAAALAAECgYICQAAAA==.',['拾玖']='拾玖:BAAALAAECgUICAAAAA==.',['拾贰']='拾贰:BAAALAAECgYIBgAAAA==.',['挺胸']='挺胸左放胯:BAAALAAECgcIEAAAAA==.',['排骨']='排骨炖萝卜:BAAALAAECgYICAAAAA==.',['接盘']='接盘侠:BAAALAADCgYIBgAAAA==.',['搂入']='搂入我怀中:BAAALAAFFAYIAgAAAA==.',['摩变']='摩变老的大二:BAAALAAECgMICAAAAA==.',['攥着']='攥着小糖:BAAALAADCgIIAgAAAA==.',['斯内']='斯内普:BAAALAADCgEIAQAAAA==.',['无心']='无心大师:BAABLAAFFH8OAAMQAAUIAxOJBwAqAQAQAAUIAxOJBwAqAQADAAUIBwoUOAAOAQAAAA==.',['无聊']='无聊的黑骑:BAAALAAFFAIIBAAAAA==.无聊练小号耍:BAAALAAECgIIAgAAAA==.',['时光']='时光会骗人:BAABLAAFFH8FAAIKAAIIWAFDTABKAAAKAAIIWAFDTABKAAAAAA==.',['明天']='明天会更好:BAAALAAECgMIBQAAAA==.',['昏豆']='昏豆花儿:BAABLAAFFH8MAAIaAAYIWRBuOABaAQAaAAYIWRBuOABaAQAAAA==.',['星辰']='星辰小小飞:BAAALAADCggICAAAAA==.',['昨天']='昨天的潇洒:BAAALAADCgcICAAAAA==.',['晓蘇']='晓蘇:BAAALAAECgMIAwAAAA==.',['晴微']='晴微:BAAALAAECgIIAgAAAA==.',['暴力']='暴力老英:BAAALAAECgIIAwAAAA==.',['曼珠']='曼珠莎华:BAAALAADCggICwAAAA==.',['月之']='月之暗刃:BAAALAAECgYIDAAAAA==.',['月色']='月色黎明:BAAALAAFFAIIAgAAAA==.',['月落']='月落风翎:BAAALAAFFAIIAgAAAA==.月落风萦:BAABLAAFFH8XAAICAAYIrQyFHADmAAACAAYIrQyFHADmAAAAAA==.',['有时']='有时微风天:BAAALAAECgMIAwABLAAFFAgIBgAGAOIhAA==.',['望月']='望月眠:BAAALAAECgcIBwAAAA==.',['木木']='木木夕木目心:BAABLAAFFH8HAAIaAAIIhQx+hQBDAAAaAAIIhQx+hQBDAAAAAA==.',['未饮']='未饮醉苍穹:BAABLAAFFH8FAAIdAAIIlAokFgBcAAAdAAIIlAokFgBcAAAAAA==.',['本兮']='本兮:BAAALAAFFAIIAgAAAA==.',['术憨']='术憨憨:BAAALAAECgYIBgAAAA==.',['杀戮']='杀戮本色丶:BAAALAADCgMIAwAAAA==.',['杏花']='杏花雨沾衣:BAAALAAECgMIAwAAAA==.',['来不']='来不得神:BAAALAAFFAIIAgAAAA==.',['杰路']='杰路刚帝士:BAAALAAECgQIBAAAAA==.',['枣丶']='枣丶亚夜:BAAALAAECgMIAwAAAA==.枣丶真夜:BAAALAAFFAIIAgAAAA==.',['柠檬']='柠檬味口香糖:BAABLAAFFH8QAAIDAAUI8wz2OQD6AAADAAUI8wz2OQD6AAAAAA==.',['核动']='核动力挖掘机:BAAALAAECgUIBQAAAA==.',['格蕾']='格蕾:BAACLAAFFH8cAAIEAAYIkxfbGgCEAQAEAAYIkxfbGgCEAQAsAAQKfzsAAwUACAj4ItEGAEECAAQACAjRH6dEAG4CAAUABwgoIdEGAEECAAAA.',['梅尔']='梅尔加斯:BAAALAAECgUIBQAAAA==.',['梦飘']='梦飘摇:BAAALAAECgYICAAAAA==.',['横扫']='横扫一大片:BAABLAAECn8gAAIbAAcImRjQegDoAQAbAAcImRjQegDoAQAAAA==.',['欧皇']='欧皇骑士:BAABLAAFFH8GAAIaAAQIFgbvVgCrAAAaAAQIFgbvVgCrAAAAAA==.',['欧码']='欧码机里曼波:BAAALAAECgQICAAAAA==.',['歃血']='歃血:BAAALAAECgQIBAAAAA==.',['正义']='正义的超超酱:BAABLAAFFH8IAAMIAAIICBD1RABlAAAIAAIICBD1RABlAAAOAAII2wQVKgBhAAAAAA==.',['歪头']='歪头杀:BAAALAAFFAIIAwAAAA==.',['死亡']='死亡战斧:BAAALAADCgQIBAAAAA==.死亡骑射:BAAALAAECgYIBgAAAA==.',['毁灭']='毁灭:BAAALAAECgEIAQAAAA==.',['水上']='水上由岐:BAAALAAFFAIIAwAAAA==.',['沐春']='沐春风:BAAALAAECgIIAwAAAA==.',['沐晨']='沐晨丶:BAABLAAFFH8GAAISAAIIoRC4GACcAAASAAIIoRC4GACcAAAAAA==.',['沙市']='沙市一羽:BAAALAAECgQIBAAAAA==.沙市黑土:BAAALAAECgUICQAAAA==.',['没有']='没有游戏玩:BAABLAAFFH8GAAIEAAIIFwwacgA9AAAEAAIIFwwacgA9AAAAAA==.',['油豆']='油豆腐:BAAALAAFFAIIBAAAAA==.',['法大']='法大王:BAAALAAECgUIBgAAAA==.',['法爷']='法爷:BAABLAAFFH8fAAIGAAYIvBrYCQDoAQAGAAYIvBrYCQDoAQABLAAFFAYIKQADAO8VAA==.',['泯灭']='泯灭灬:BAAALAAECgUIBwAAAA==.',['泰瑞']='泰瑞纳斯:BAACLAAFFH86AAIEAAYIaR+WCADdAQAEAAYIaR+WCADdAQAsAAQKfx4AAgQACAjLImcVACEDAAQACAjLImcVACEDAAAA.',['洛玉']='洛玉衡:BAAALAAECgYIEQAAAA==.',['洛神']='洛神打灰机:BAAALAAECgUIBQAAAA==.',['洪泽']='洪泽湖大乌鳢:BAAALAAECgYIBgAAAA==.',['浅笑']='浅笑丶:BAAALAAECgUICgAAAA==.',['浓情']='浓情可可:BAAALAAECgMIAwAAAA==.',['浪一']='浪一浪:BAAALAAFFAIIAgAAAA==.',['浮云']='浮云遮:BAAALAADCgIIAgAAAA==.',['浮华']='浮华立夏:BAAALAAECggICAAAAA==.',['浮生']='浮生轻叹:BAAALAAECgMIAwAAAA==.浮生载雪:BAAALAAECgYICgAAAA==.',['海公']='海公牛:BAAALAAECgYIDQAAAA==.',['海鸟']='海鸟丶和鱼:BAABLAAFFH8GAAIbAAIIdxOAjwBFAAAbAAIIdxOAjwBFAAAAAA==.',['涂山']='涂山雅雅:BAABLAAFFH8GAAIQAAIIQwhwHAA4AAAQAAIIQwhwHAA4AAAAAA==.',['淡淡']='淡淡的清风:BAAALAAFFAIIAgAAAA==.',['淡笑']='淡笑:BAAALAAECgUIBQAAAA==.',['混沌']='混沌野狼:BAABLAAFFH8GAAIEAAII5hX0QQCdAAAEAAII5hX0QQCdAAAAAA==.',['清纯']='清纯钱钱:BAAALAAECgYICgAAAA==.',['清蒸']='清蒸小奶牛:BAAALAAECggIBgAAAA==.',['渝州']='渝州熊猫叔:BAAALAAECgYIBwAAAA==.',['温天']='温天仁:BAAALAAECgYIBgAAAA==.',['湛泸']='湛泸:BAAALAAFFAUIAgAAAA==.',['滚滚']='滚滚大做饭:BAAALAAFFAIIAgAAAA==.',['激进']='激进的张老三:BAAALAADCgYIBgAAAA==.',['火因']='火因木仓:BAACLAAFFH8ZAAIDAAUITBTDMwAvAQADAAUITBTDMwAvAQAsAAQKfx4AAwMACAj+GnAvAI0CAAMACAj+GnAvAI0CABAAAggGDH5/AG0AAAAA.',['灬庆']='灬庆乖乖灬:BAAALAADCgYIBgAAAA==.',['灵魂']='灵魂莲华:BAAALAAECgUIBQAAAA==.',['炙热']='炙热海风:BAAALAAFFAIIAgAAAA==.',['炸豆']='炸豆腐:BAABLAAFFH8GAAIVAAIIlh/NNgCTAAAVAAIIlh/NNgCTAAAAAA==.',['為所']='為所慾為:BAAALAAECgIIBAAAAA==.',['烈女']='烈女怕缠狗:BAAALAAFFAIIAgAAAA==.',['烈日']='烈日行者:BAAALAAECgMIAwAAAA==.',['焉有']='焉有火光:BAAALAAECgUIBgAAAA==.',['焦糖']='焦糖玛奇朵:BAAALAAECgYICwAAAA==.',['煞气']='煞气怒炎:BAAALAADCggICAAAAA==.',['熊本']='熊本熊:BAAALAAECgQIBwAAAA==.熊本熊本熊:BAAALAADCgIIAgAAAA==.',['爱咋']='爱咋咋的:BAACLAAFFH8MAAMJAAMICRKCEACjAAAJAAIIahiCEACjAAAMAAMI0QV9UQByAAAsAAQKfx8AAwkACAj/HyYMAKsCAAkACAj/HyYMAKsCAAwAAwhKF0RvALEAAAAA.',['牛公']='牛公海公牛:BAAALAAECgQIDAAAAA==.',['牛妞']='牛妞儿:BAAALAADCggICAAAAA==.',['牛小']='牛小卉:BAAALAADCggICAAAAA==.',['牛牛']='牛牛很牛:BAAALAADCgYICwAAAA==.牛牛恶霸:BAABLAAFFH8GAAIWAAYIiwYuIwAqAQAWAAYIiwYuIwAqAQAAAA==.',['牛肉']='牛肉糖狂奔:BAAALAAECgUIBwAAAA==.',['牛菠']='牛菠萝:BAAALAAFFAIIBAAAAA==.',['牛黄']='牛黄丸:BAAALAADCgcIDAAAAA==.',['牧憨']='牧憨憨:BAAALAAECgEIAQAAAA==.',['犭苗']='犭苗口乌:BAAALAADCgYIBgAAAA==.',['狐咪']='狐咪香:BAAALAAECgYICgAAAA==.',['狐教']='狐教授电疗:BAAALAAECggICAAAAA==.',['狗叫']='狗叫啥:BAABLAAFFH8kAAIfAAgIuBz9AQDOAgAfAAgIuBz9AQDOAgAAAA==.',['狗尿']='狗尿台:BAABLAAFFH8UAAIfAAgI+RdgAwCFAgAfAAgI+RdgAwCFAgAAAA==.',['狠人']='狠人一刀:BAABLAAECn8gAAILAAYImhVXSABBAQALAAYImhVXSABBAQAAAA==.',['狠牛']='狠牛一刀:BAAALAAFFAIIBAAAAA==.',['猎意']='猎意:BAAALAAECgUIAgAAAA==.',['猎憨']='猎憨憨:BAAALAAECgYIDAAAAA==.',['猛踹']='猛踹瘸子好腿:BAAALAADCgEIAQAAAA==.',['猪拉']='猪拉密:BAABLAAFFH8GAAIIAAYIlxowEQC3AQAIAAYIlxowEQC3AQAAAA==.',['猪杂']='猪杂汤:BAAALAAECgEIAQAAAA==.',['猫仓']='猫仓唯:BAAALAAECgQIBAABLAAFFAIIAgAHAAAAAA==.',['玉绪']='玉绪绝佳丽斩:BAAALAAFFAIIBAAAAA==.',['玛奇']='玛奇朵:BAAALAAECgQIBAAAAA==.',['玩宫']='玩宫射大鸟:BAAALAAECgYICgAAAA==.',['玲兒']='玲兒:BAABLAAFFH8IAAIFAAIILhj9GAA5AAAFAAIILhj9GAA5AAAAAA==.',['琴授']='琴授不入:BAAALAAECgMIAwAAAA==.',['璀璨']='璀璨心橙:BAAALAAECgUIBQAAAA==.',['瓦勒']='瓦勒里昂邪焰:BAAALAAFFAIIAgABLAAFFAYICwAMAJ8fAA==.',['甜之']='甜之源儿:BAAALAAFFAIIBAAAAA==.',['界之']='界之天歌:BAAALAAECgUIBQAAAA==.',['疯狂']='疯狂嘘曲:BAAALAAECgMIAwAAAA==.疯狂小书生:BAACLAAFFH8PAAMJAAQI0xBNGQCRAAAMAAQIpQ6MQwDOAAAJAAII5Q9NGQCRAAAsAAQKfzgAAwwABgg3IIEfAOsBAAwABgjYH4EfAOsBAAkABQgnHu0XABYBAAEsAAUUCAgOAAkAyR0A.疯狂猎手:BAAALAAECgMIAwAAAA==.',['疯癫']='疯癫废:BAAALAAECgYIBgAAAA==.',['白大']='白大王:BAAALAAECgYICwAAAA==.',['白日']='白日依衫尽:BAABLAAECn8cAAIEAAYIdSTTRABuAgAEAAYIdSTTRABuAgAAAA==.',['白火']='白火石:BAAALAAFFAIIAgAAAA==.',['白龍']='白龍天舞:BAABLAAFFH8GAAIfAAIIIA16GgBqAAAfAAIIIA16GgBqAAAAAA==.',['百万']='百万伏特:BAABLAAFFH8dAAMVAAYIYBwgDwDvAQAVAAYIYBwgDwDvAQAWAAUIlwawKQD0AAAAAA==.',['看什']='看什么看:BAABLAAFFH8QAAIfAAgItBbzAwBuAgAfAAgItBbzAwBuAgAAAA==.',['瞎子']='瞎子阿饼:BAAALAAECggICAAAAA==.',['知音']='知音冢:BAAALAADCgYIBgAAAA==.',['短发']='短发希瓦:BAAALAADCgIIAgAAAA==.',['矮子']='矮子:BAAALAAECgYIBgAAAA==.',['祖传']='祖传老军医:BAAALAAECggIAgAAAA==.',['祖国']='祖国老花朵:BAAALAAECgYICwAAAA==.',['神佑']='神佑圣光:BAAALAAECgYIBwAAAA==.',['神圣']='神圣武器战:BAAALAAECgMIAwAAAA==.',['神明']='神明自在天:BAABLAAFFH8UAAICAAMItBquNACgAAACAAMItBquNACgAAAAAA==.',['神龙']='神龙教主:BAAALAAECgMIBQAAAA==.',['离晒']='离晒大谱:BAABLAAFFH8fAAIWAAYICCFUDgDRAQAWAAYICCFUDgDRAQAAAA==.',['种桃']='种桃花的熊猫:BAAALAAECgUIBQAAAA==.',['稀有']='稀有宝宝:BAAALAADCggICAAAAA==.',['空谷']='空谷幽兰:BAAALAAECgEIAQAAAA==.',['窦文']='窦文涛:BAAALAAECgcIBwAAAA==.',['笑鼠']='笑鼠人:BAAALAAECgcIBwAAAA==.',['第四']='第四教条:BAAALAAFFAIIAgAAAA==.',['筱筱']='筱筱花椒呢:BAAALAADCgcIBwAAAA==.',['筱花']='筱花椒粒:BAABLAAFFH8IAAMMAAUImge0QgDXAAAMAAUI7Aa0QgDXAAAJAAIIGAjjGgAOAAAAAA==.筱花椒粒呀:BAABLAAFFH8IAAICAAUINBPwJgA5AQACAAUINBPwJgA5AQAAAA==.',['箭箭']='箭箭达:BAABLAAFFH8LAAIbAAYIhBtSLACEAQAbAAYIhBtSLACEAQAAAA==.',['米饭']='米饭貝貝:BAAALAAECgYICAAAAA==.',['糯米']='糯米糕:BAAALAAECgEIAQAAAA==.',['素阳']='素阳子:BAAALAADCgIIAgAAAA==.',['素颜']='素颜也倾城:BAAALAAECggICAAAAA==.',['紫郢']='紫郢:BAABLAAFFH8JAAITAAMIewd1DwCEAAATAAMIewd1DwCEAAABLAAFFAYIHQAVAGAcAA==.',['維貳']='維貳:BAAALAAFFAIIAgAAAA==.',['织舞']='织舞:BAAALAAECgIIAgAAAA==.',['给你']='给你发颗糖:BAAALAADCggICAAAAA==.',['绝世']='绝世碎碎念:BAAALAAECgUIBQAAAA==.',['绿茶']='绿茶泡枸杞:BAAALAAECgUIBgAAAA==.',['网恋']='网恋加我秋秋:BAAALAAECgYIBgAAAA==.',['羁風']='羁風:BAACLAAFFH8SAAIMAAYIaw63MABVAQAMAAYIaw63MABVAQAsAAQKfyIAAgwABginHWUqAKoBAAwABginHWUqAKoBAAAA.',['羁风']='羁风:BAABLAAFFH8OAAIeAAUITA52CgD7AAAeAAUITA52CgD7AAABLAAFFAYIEgAMAGsOAA==.',['羈風']='羈風:BAACLAAFFH8LAAIEAAUIFw93MwDmAAAEAAUIFw93MwDmAAAsAAQKfx4AAgQABgi0H+M1AL0BAAQABgi0H+M1AL0BAAEsAAUUBggSAAwAaw4A.',['老仙']='老仙师:BAAALAAECgYIAgAAAA==.',['老司']='老司机请留步:BAAALAAECgUICgAAAA==.',['老子']='老子和你拼了:BAAALAAFFAIIBAAAAA==.',['自成']='自成风月丶:BAABLAAFFH8KAAMcAAIIpg5hEwBxAAAaAAIIpgKMkQB0AAAcAAIIpg5hEwBxAAAAAA==.',['至尊']='至尊天神棍:BAAALAAECgYIBgAAAA==.',['舜桜']='舜桜:BAABLAAECn8ZAAMEAAgINRz2VABEAgAEAAgINRz2VABEAgAFAAgIvgAUgAAcAAAAAA==.',['芗籿']='芗籿非主蓅:BAABLAAFFH8MAAICAAYIXhVEHQB/AQACAAYIXhVEHQB/AQAAAA==.',['芙蘭']='芙蘭朵露:BAAALAAFFAIIAgAAAA==.',['芝士']='芝士奶糖:BAAALAAECgEIAgAAAA==.',['花椒']='花椒粒:BAAALAAFFAIIBAAAAA==.花椒粒讷:BAABLAAFFH8HAAIIAAUIIwbtJgDgAAAIAAUIIwbtJgDgAAAAAA==.',['花生']='花生冲啊:BAAALAAFFAIIAwAAAA==.花生殼殼:BAACLAAFFH8MAAMJAAMIgxVKCwC0AAAJAAIIMh9KCwC0AAAMAAEIJwKWcAAsAAAsAAQKfyIAAwkACAijIRUHAPkCAAkACAijIRUHAPkCAAwAAgi5EALqAHYAAAAA.花生锤啊:BAABLAAFFH8GAAIjAAYIVQdQCwAjAQAjAAYIVQdQCwAjAQAAAA==.',['茜茜']='茜茜小奶包:BAAALAAECgUIBgAAAA==.',['莉莉']='莉莉娅斯:BAAALAAECgYIBgAAAA==.',['菠菜']='菠菜殿下:BAAALAAECgYIBgAAAA==.',['萌萌']='萌萌的晓晓:BAAALAAECgUIBQAAAA==.',['萝卜']='萝卜叔叔:BAAALAAECgYIEAAAAA==.',['萨憨']='萨憨憨:BAACLAAFFH8JAAIVAAMIuB/YMgDdAAAVAAMIuB/YMgDdAAAsAAQKfx4AAhUACAjOFJc2AIIBABUACAjOFJc2AIIBAAAA.',['萨琪']='萨琪玛:BAABLAAFFH8SAAIVAAUIHBfmIQBOAQAVAAUIHBfmIQBOAQAAAA==.',['萨鲁']='萨鲁加尔雷霆:BAABLAAFFH8IAAIWAAIIoAtkLwCKAAAWAAIIoAtkLwCKAAAAAA==.',['落雪']='落雪听梅:BAAALAAECgYIBgAAAA==.',['葬送']='葬送的芙蓉王:BAAALAAECgUIBgAAAA==.',['葱爆']='葱爆小豆腐:BAAALAAFFAIIBAAAAA==.',['蘭丶']='蘭丶铅笔:BAAALAAFFAIIAgAAAA==.',['虎啸']='虎啸山林:BAAALAADCggICAAAAA==.',['虽然']='虽然歌声无形:BAAALAADCgIIAgAAAA==.',['虾子']='虾子:BAAALAAECgUIBQAAAA==.虾子儿:BAAALAAECgcIDgAAAA==.',['蛋蛋']='蛋蛋三明治:BAAALAAFFAYIBAAAAA==.',['蛋里']='蛋里蛋气:BAAALAAECgYICAAAAA==.',['蟲兒']='蟲兒飛:BAABLAAECn8WAAIEAAcIwxlCRACPAQAEAAcIwxlCRACPAQAAAA==.',['血羿']='血羿:BAAALAAFFAIIBAABLAAFFAYIHQAVAGAcAA==.',['血色']='血色蒙牛金帝:BAABLAAECn8WAAIIAAgI3xS5GwDxAQAIAAgI3xS5GwDxAQAAAA==.',['血魔']='血魔狂战:BAAALAAECgcIDAAAAA==.',['西北']='西北砍王:BAAALAADCgcIBwAAAA==.',['许仙']='许仙骑蟒蛇:BAAALAAECgYIBgAAAA==.',['诉风']='诉风和叶:BAAALAAECgMIAwAAAA==.',['谷雨']='谷雨依先贤丶:BAAALAAFFAgIBAAAAA==.',['豆子']='豆子鬼:BAABLAAFFH8GAAIaAAII5xwAdQBMAAAaAAII5xwAdQBMAAAAAA==.',['貔貅']='貔貅:BAABLAAFFH8eAAIbAAYIgR+yFwDaAQAbAAYIgR+yFwDaAQAAAA==.',['贝吉']='贝吉嗒:BAAALAAFFAMIBAAAAA==.',['赔钱']='赔钱货小伊伊:BAAALAAFFAEIAQAAAA==.',['赞美']='赞美约科:BAAALAADCgEIAQAAAA==.',['赫尔']='赫尔幸根:BAAALAAECgYIEAAAAA==.',['超越']='超越时间:BAAALAAECgQIBwAAAA==.',['路西']='路西法牛牛:BAAALAAFFAIIBAAAAA==.',['轩辕']='轩辕梵天:BAAALAAECgUIBQAAAA==.',['辰光']='辰光:BAAALAAFFAIIAgAAAA==.',['达菲']='达菲机:BAAALAAECgEIAQAAAA==.',['迈克']='迈克尔泰森:BAAALAAECgMIAwAAAA==.',['迷途']='迷途萌萌德:BAAALAAECgYIDAAAAA==.',['追逐']='追逐时间:BAAALAAECgYICgAAAA==.',['逃离']='逃离:BAAALAAECgIIAwAAAA==.',['逆天']='逆天:BAABLAAFFH8KAAMLAAYIMxEcLQAvAQALAAUI6BEcLQAvAQAdAAEIqg0gEwA2AAAAAA==.',['通大']='通大杏林学院:BAAALAAFFAIIAgAAAA==.',['遗憾']='遗憾丶:BAABLAAFFH8PAAMDAAYIdRgsJQCAAQADAAYIdRgsJQCAAQAQAAEINw+hIABBAAAAAA==.',['那个']='那个劣人丶:BAABLAAFFH8GAAIVAAIIkhY0PgCFAAAVAAIIkhY0PgCFAAAAAA==.',['那什']='那什么什么了:BAACLAAFFH8+AAMbAAgIRyEbBABBAgAbAAgIRyEbBABBAgAeAAIIxA4iKAB3AAAsAAQKfy0AAxsACAiCJGYcAOkCABsACAiCJGYcAOkCAB4ACAhyGhklAEUCAAAA.',['那母']='那母牛对我说:BAAALAAECgYICgAAAA==.',['邪恶']='邪恶狻猊:BAAALAAFFAIIAwAAAA==.',['邪神']='邪神:BAABLAAFFH8dAAIEAAYI3B3aDgDOAQAEAAYI3B3aDgDOAQAAAA==.',['部落']='部落的勇士:BAAALAAECgYIEQAAAA==.',['酥爆']='酥爆杨杨:BAABLAAFFH8GAAILAAIInRBJRQCVAAALAAIInRBJRQCVAAAAAA==.',['醉酒']='醉酒只候深情:BAAALAADCgYIBgAAAA==.',['里丶']='里丶贝留斯:BAAALAAFFAQIAQAAAA==.',['銀色']='銀色的永生:BAACLAAFFH8/AAQRAAYIMx4hAQCwAQASAAYIpBzgBQDKAQARAAYIbRghAQCwAQATAAQIJRAoCwDhAAAsAAQKfyMABBEACAhYIAkEAKkCABEACAhlHgkEAKkCABMABwgaGWwdAKgBABIAAwigFnslAFgAAAAA.銀色黎眀:BAAALAAECgEIAQAAAA==.',['铠牙']='铠牙:BAAALAAFFAIIBAAAAA==.铠牙猪:BAAALAAFFAIIBAAAAA==.',['银月']='银月露娜:BAAALAAFFAIIBAAAAA==.',['闪电']='闪电小南:BAAALAAFFAQIBAAAAA==.',['闻夕']='闻夕:BAAALAAFFAIIAgAAAA==.',['阴暗']='阴暗的炼焦煤:BAAALAAECggICAAAAA==.',['阿兰']='阿兰:BAAALAAECgQIBAAAAA==.',['阿兵']='阿兵:BAACLAAFFH8MAAICAAMIiRgRNQCeAAACAAMIiRgRNQCeAAAsAAQKfx0AAgIABgg3I0UgAOwBAAIABgg3I0UgAOwBAAAA.',['阿尔']='阿尔忒弥思:BAAALAADCgQIBAAAAA==.',['阿楠']='阿楠丶:BAAALAAFFAYIBAAAAA==.',['阿特']='阿特兰斯猎风:BAABLAAFFH8SAAIbAAIIoR2hQQCkAAAbAAIIoR2hQQCkAAAAAA==.',['阿辉']='阿辉打电动:BAAALAAFFAIIAgAAAA==.',['阿里']='阿里壮壮:BAAALAAECgMIAwABLAAECgYIHAAEAHUkAA==.',['陈卝']='陈卝暴风烈酒:BAAALAAECgQIBAAAAA==.',['陈昆']='陈昆勇:BAAALAAECgYIDAAAAA==.',['雷恩']='雷恩加尔:BAAALAADCgQIBAAAAA==.',['雷欧']='雷欧大侠:BAAALAAECggIBgAAAA==.',['雷雨']='雷雨:BAACLAAFFH8ZAAMKAAUIMxg9GACQAQAKAAUIMxg9GACQAQAUAAMICQiwJABTAAAsAAQKfyQAAxQABwhpE6Q7ANABABQABwhpE6Q7ANABAAoABwjGG3cdAM4BAAAA.',['雷霆']='雷霆女侠:BAAALAADCggICAAAAA==.',['霜狼']='霜狼老兵:BAAALAAFFAIIBAAAAA==.',['霸气']='霸气的营销:BAABLAAFFH8GAAMWAAYISBOVDQCnAQAWAAUIWxaVDQCnAQAVAAEIiwN1dAA3AAAAAA==.',['青峰']='青峰飘阳:BAAALAADCgMIAwAAAA==.',['青青']='青青子矜:BAABLAAFFH8GAAIQAAIIxRWVEgBNAAAQAAIIxRWVEgBNAAAAAA==.',['顾念']='顾念熙:BAAALAAECgcIDAAAAA==.',['風前']='風前雨后:BAABLAAECn8WAAICAAYIvA/nlQBZAQACAAYIvA/nlQBZAQAAAA==.',['風的']='風的季节:BAAALAADCgcICQAAAA==.',['风景']='风景褪色:BAAALAADCgEIAQAAAA==.',['风橗']='风橗:BAAALAAECgUICAAAAA==.',['飒大']='飒大王:BAAALAAECgQIBAAAAA==.',['飞天']='飞天大糙:BAAALAADCgEIAQAAAA==.飞天怪得:BAAALAADCgUIBQAAAA==.',['飞翔']='飞翔的西瓜:BAAALAAECgUIAwAAAA==.',['饕餮']='饕餮:BAAALAAECgEIAQAAAA==.',['骑憨']='骑憨憨:BAAALAAFFAIIAgAAAA==.',['骑猪']='骑猪看夕阳:BAAALAAECgQIBAAAAA==.',['骑龟']='骑龟撞熊德:BAAALAAECgYIBgAAAA==.骑龟看世界:BAAALAAFFAIIAgAAAA==.骑龟赏樱花:BAACLAAFFH8GAAIaAAII0gaegwCEAAAaAAII0gaegwCEAAAsAAQKfxYAAxoABwhaD3fpAGIBABoABwhaD3fpAGIBABwAAQhLAxw1AB8AAAAA.骑龟逗蛐蛐:BAAALAAFFAIIBAAAAA==.骑龟闯红灯:BAAALAAECgcIEgAAAA==.',['骷骨']='骷骨:BAAALAADCgIIAgAAAA==.',['魔血']='魔血魔剑:BAAALAAECgQIBAAAAA==.',['鸡火']='鸡火味锅巴丶:BAAALAADCgEIAQAAAA==.',['鹤协']='鹤协大师:BAAALAAECgMIAwAAAA==.',['黎明']='黎明破晓前:BAAALAAFFAIIAgAAAA==.',['黑山']='黑山:BAAALAAECgMIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end