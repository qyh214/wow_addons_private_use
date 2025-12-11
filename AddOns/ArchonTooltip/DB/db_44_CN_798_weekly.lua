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
 local lookup = {'DeathKnight-Frost','Warlock-Destruction','Shaman-Restoration','Hunter-BeastMastery','Shaman-Elemental','Mage-Frost','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Retribution','Hunter-Marksmanship','Rogue-Assassination','Priest-Discipline','Monk-Windwalker','Warrior-Arms','Warrior-Fury','Druid-Feral','Warlock-Affliction','Monk-Mistweaver','Warrior-Protection','Priest-Holy','Druid-Restoration','Paladin-Protection','Evoker-Devastation','Warlock-Demonology','DemonHunter-Vengeance','Druid-Balance','Unknown-Unknown','Paladin-Holy','Mage-Fire','Mage-Arcane','Monk-Brewmaster','DemonHunter-Havoc','Hunter-Survival','Druid-Guardian',}; local provider = {region='CN',realm='艾森娜',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ba='Banshee:BAAALAAECgYIEAAAAA==.',Be='Becalm:BAAALAAECgYICAAAAA==.',Ch='Cheers:BAAALAAECgIIAgAAAA==.Cherijk:BAABLAAFFH8KAAIBAAII0RW0dwBKAAABAAII0RW0dwBKAAAAAA==.Christmas:BAAALAAECgYICAAAAA==.',Da='Dawnbreaker:BAAALAAECggICAAAAA==.',De='Desdemona:BAABLAAFFH8FAAICAAIIKBxMVgBNAAACAAIIKBxMVgBNAAAAAA==.',Di='Diary:BAABLAAFFH8NAAIDAAIIAR22QACAAAADAAIIAR22QACAAAAAAA==.',Hi='Hightemplar:BAAALAAFFAIIAgAAAA==.',In='Innocence:BAAALAAECggICAAAAA==.',Ka='Kanroseate:BAAALAAECgMIBAAAAA==.',Mo='Monroe:BAAALAAECgMIAwAAAA==.',Ne='Newsmatrix:BAABLAAFFH8GAAIEAAIIWRDIiQBIAAAEAAIIWRDIiQBIAAAAAA==.Newswizard:BAAALAAFFAIIAwAAAA==.',Ni='Nihil:BAAALAADCgMIAwAAAA==.',No='Novice:BAABLAAFFH8OAAMDAAUIrh1gHgDSAAADAAQIBh9gHgDSAAAFAAEICQPGTQA4AAABLAAFFAYIKQAGABMhAA==.',Pi='Pinkladin:BAAALAAECgMIBAAAAA==.',Ra='Rashford:BAAALAADCgQIBwAAAA==.',Re='Re:BAABLAAFFH8wAAQBAAYIkSVVEAAMAgABAAYIhyVVEAAMAgAHAAYIZB4+BwC7AQAIAAQI7h0zBwD/AAAAAA==.',Sa='Sadasdsad:BAAALAADCgcIBwAAAA==.',Si='Siisiisiis:BAAALAAECgYIBgAAAA==.',St='Staysober:BAACLAAFFH8NAAIBAAUIcR7POQBUAQABAAUIcR7POQBUAQAsAAQKfxgAAgEACAglIxUIAMACAAEACAglIxUIAMACAAAA.',Ta='Takeiteasy:BAAALAAFFAIIAgAAAA==.',Tu='Turu:BAAALAAECgYIBgAAAA==.',Wa='Walena:BAAALAADCgcIBwAAAA==.',Xe='Xeria:BAAALAAECgIIAgABLAAFFAgIBQACAIQIAA==.',['一安']='一安:BAABLAAFFH8KAAIDAAIIWBYFRgB3AAADAAIIWBYFRgB3AAAAAA==.',['一茗']='一茗茗一:BAAALAAECgYICQAAAA==.',['万卷']='万卷云:BAABLAAFFH8FAAIJAAIIUAfudgA6AAAJAAIIUAfudgA6AAAAAA==.',['不可']='不可宽恕:BAAALAAFFAMIAgAAAA==.',['专注']='专注抓小德:BAABLAAECn8XAAMEAAYIBBQdoAAZAQAEAAYIBBQdoAAZAQAKAAYIxwp/dAD+AAAAAA==.',['两粒']='两粒小蛋:BAAALAAECgQIBwAAAA==.',['丨妖']='丨妖妖丨:BAAALAAECgYIEgAAAA==.',['丨姜']='丨姜珏丨:BAEBLAAFFH8GAAILAAIIBBD9GQBMAAALAAIIBBD9GQBMAAABLAAFFAUIEQAMAIAWAA==.',['乌梅']='乌梅味的猫:BAACLAAFFH8LAAIEAAUI6B0SNQBoAQAEAAUI6B0SNQBoAQAsAAQKfxYAAgQACAjIHywUAIUCAAQACAjIHywUAIUCAAAA.',['九灯']='九灯灬长歌:BAAALAAFFAIIAgAAAA==.',['云栖']='云栖松子糖:BAAALAAECggICwAAAA==.',['伊万']='伊万卡梅尔:BAAALAAFFAIIAgAAAA==.伊万杰琳莉莉:BAABLAAFFH8GAAINAAMIkhSQEACQAAANAAMIkhSQEACQAAAAAA==.',['伊兰']='伊兰特智界:BAABLAAECn8YAAMOAAYIChOTCQAQAQAOAAYI5RKTCQAQAQAPAAYI0gsAXgD7AAAAAA==.',['伊莎']='伊莎贝拉问界:BAAALAAFFAIIAgAAAA==.',['伊萨']='伊萨贝拉:BAAALAAECggICwAAAA==.',['伊达']='伊达航:BAAALAAFFAIIAgABLAAFFAcIHAAQAOIjAA==.',['伐楼']='伐楼那:BAAALAAECgYICQAAAA==.',['佛祖']='佛祖身前灯:BAAALAAECgQIBAAAAA==.',['俺叫']='俺叫不紧张:BAABLAAFFH8IAAIEAAQI5wk/ZACnAAAEAAQI5wk/ZACnAAAAAA==.',['借根']='借根烟点个火:BAABLAAECn8dAAIPAAYIbxmAOQByAQAPAAYIbxmAOQByAQAAAA==.',['克娄']='克娄帕特拉:BAAALAAFFAIIAgAAAA==.',['六指']='六指夺魂:BAAALAAECgYIDQAAAA==.',['兰色']='兰色的海洋:BAAALAAFFAIIBAAAAA==.',['冬熊']='冬熊夏猫:BAABLAAFFH8HAAIQAAII2hacCwCiAAAQAAII2hacCwCiAAAAAA==.',['冰水']='冰水谣:BAAALAAECgUIBgAAAA==.',['冰雪']='冰雪:BAAALAADCggICAAAAA==.',['冰魄']='冰魄炎神:BAAALAAECgYIEQAAAA==.',['凄凉']='凄凉的乌米:BAABLAAFFH8KAAMRAAII3QjiBAB8AAARAAIIsAbiBAB8AAACAAII6wSIUgB6AAAAAA==.',['凱蕾']='凱蕾莉亞:BAAALAADCgMIAwAAAA==.',['副节']='副节龙出击:BAABLAAFFH8HAAISAAIIHxVGFAB6AAASAAIIHxVGFAB6AAAAAA==.',['北极']='北极之魔:BAABLAAECn8WAAIJAAYIwReOrQCiAQAJAAYIwReOrQCiAQAAAA==.北极极:BAACLAAFFH8aAAMHAAYIuwqeDQAvAQAHAAYIewqeDQAvAQAIAAMICQmnDACSAAAsAAQKf1wAAwcACAhgD4guAAgBAAcABggWFIguAAgBAAEACAhqAIi6AQQAAAEsAAUUBwgtABMA+yUA.',['千雪']='千雪:BAAALAAFFAIIAgAAAA==.',['升腾']='升腾者乌米:BAAALAAECgUIBwAAAA==.',['午夜']='午夜小奶嘴:BAABLAAFFH8GAAIUAAIIMAp9OACDAAAUAAIIMAp9OACDAAAAAA==.',['卡捷']='卡捷琳娜:BAABLAAFFH8IAAIBAAIIuRQ0ZACWAAABAAIIuRQ0ZACWAAAAAA==.',['反复']='反复攻击小明:BAAALAAECgYIBgABLAAFFAUICQAPALsNAA==.',['吉田']='吉田步美:BAACLAAFFH8cAAIQAAcI4iO2AABzAgAQAAcI4iO2AABzAgAsAAQKfyoAAhAACAjwJgoAAC4DABAACAjwJgoAAC4DAAAA.',['告诉']='告诉过你:BAAALAAFFAIIBAAAAA==.',['呢喃']='呢喃:BAABLAAFFH8KAAIVAAIIAxgdKQCHAAAVAAIIAxgdKQCHAAABLAAFFAYIFgADAHsSAA==.',['和气']='和气勿喷:BAABLAAFFH8KAAIJAAYIZhy+FACmAQAJAAYIZhy+FACmAQAAAA==.',['咕咚']='咕咚:BAAALAAECgQIBAAAAA==.',['咕嘟']='咕嘟:BAAALAAECgYIDAABLAAFFAYIFgADAHsSAA==.',['唯为']='唯为君倾:BAAALAAECggIBAAAAA==.',['回到']='回到最初:BAAALAAECgEIAQAAAA==.',['图拉']='图拉阳:BAAALAAFFAIIBAAAAA==.',['土拨']='土拨鼠吖丶:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光重现:BAACLAAFFH8GAAMJAAIIFQ9zUQCRAAAJAAIIsAlzUQCRAAAWAAIIFQ/SHQAvAAAsAAQKfxQAAgkABgi1H5JaADcCAAkABgi1H5JaADcCAAAA.',['圣神']='圣神意念:BAABLAAECn8XAAIJAAYIzhgUSwB8AQAJAAYIzhgUSwB8AQAAAA==.',['塔娜']='塔娜亚:BAABLAAFFH8MAAIEAAIIjBA0jwBFAAAEAAIIjBA0jwBFAAAAAA==.',['墨萊']='墨萊尼灬长歌:BAAALAAECgIIAgAAAA==.',['夏天']='夏天我穿棉袄:BAAALAADCgEIAQAAAA==.',['夏末']='夏末之秋:BAAALAAECgYIBAAAAA==.',['夜丶']='夜丶魅颖:BAAALAAECgYIBgABLAAFFAgIJAAXAAYcAA==.',['夜祸']='夜祸津:BAABLAAFFH8HAAMBAAUI5w9jSgAKAQABAAUIpw5jSgAKAQAIAAEI6RFEHABTAAAAAA==.',['大司']='大司寇:BAAALAAECgQIBAAAAA==.',['大王']='大王庄火车王:BAAALAAECggIAgAAAA==.',['天之']='天之子云:BAEBLAAFFH8GAAMYAAIItg6nFgA+AAAYAAIItg6nFgA+AAACAAIIRgb3ZQA6AAABLAAFFAUIEQAMAIAWAA==.',['天天']='天天加:BAABLAAFFH8JAAIUAAIIcAhbRABiAAAUAAIIcAhbRABiAAAAAA==.',['天澄']='天澄:BAAALAAECgYICAAAAA==.',['天翼']='天翼飞侠:BAAALAAFFAIIBAAAAA==.',['奥莱']='奥莱利亚:BAABLAAFFH8FAAIEAAMIKRjCJwDdAAAEAAMIKRjCJwDdAAAAAA==.奥莱萨满:BAAALAAFFAIIBAAAAA==.',['奥蕾']='奥蕾西娅:BAABLAAFFH8MAAIZAAII/gbJGAAkAAAZAAII/gbJGAAkAAAAAA==.',['女帝']='女帝丶蛇姬:BAABLAAFFH8IAAIEAAgIyQI3bgCFAAAEAAgIyQI3bgCFAAAAAA==.',['奶谁']='奶谁我说了算:BAAALAAECgUIBwAAAA==.',['妖丨']='妖丨妖:BAAALAAECgQIBAAAAA==.',['妖妖']='妖妖:BAAALAAECgYIEAAAAA==.',['妳豆']='妳豆子丶:BAAALAAECgYICgAAAA==.',['威娜']='威娜:BAAALAADCgIIAgAAAA==.',['子如']='子如云:BAEBLAAFFH8PAAIEAAUISg06UwACAQAEAAUISg06UwACAQABLAAFFAUIEQAMAIAWAA==.',['实在']='实在太丑了:BAAALAADCgEIAQAAAA==.',['寒夜']='寒夜青风:BAABLAAFFH8GAAMaAAII2QaCJgB5AAAaAAII2QaCJgB5AAAVAAIIbQf6UABSAAAAAA==.',['封印']='封印堕落:BAABLAAFFH8FAAIJAAMIkBWnGAD7AAAJAAMIkBWnGAD7AAAAAA==.',['小呲']='小呲花:BAAALAADCgMIAwAAAA==.',['小土']='小土豆丶:BAAALAAFFAEIAQAAAA==.',['小泽']='小泽德:BAAALAAECgUIBwAAAA==.',['小潘']='小潘三号:BAAALAAFFAQIBAABLAAFFAYILgAPAOMjAA==.小潘二号:BAAALAAFFAIIAgABLAAFFAYILgAPAOMjAA==.小潘兄台:BAACLAAFFH8uAAIPAAYI4yPUCQAXAgAPAAYI4yPUCQAXAgAsAAQKf0QAAg8ACAhmJYoYAPUCAA8ACAhmJYoYAPUCAAAA.',['小生']='小生好帅:BAAALAAECgMIAwAAAA==.',['小面']='小面包:BAAALAAECgEIAQABLAAFFAIIAgAbAAAAAA==.',['小饭']='小饭团:BAABLAAFFH8GAAIcAAIIzgNhLABZAAAcAAIIzgNhLABZAAAAAA==.',['小馒']='小馒头:BAABLAAECn8XAAMJAAgIcxuKIQAUAgAJAAgIcxuKIQAUAgAcAAYIEAWANQCYAAAAAA==.',['尐伊']='尐伊渃水:BAAALAAECgMIAwAAAA==.',['就是']='就是清新:BAABLAAFFH8MAAIBAAII2SIlOQC/AAABAAII2SIlOQC/AAAAAA==.',['尼芙']='尼芙蕾雅:BAAALAAECgYICwAAAA==.',['嵇康']='嵇康:BAEBLAAFFH8OAAIGAAUIERCpCAAGAQAGAAUIERCpCAAGAQABLAAFFAUIEQAMAIAWAA==.',['布鲁']='布鲁斯邢:BAACLAAFFH8dAAISAAYIWhPXCACTAQASAAYIWhPXCACTAQAsAAQKfx4AAhIACAiXHBYOAIgCABIACAiXHBYOAIgCAAAA.',['希望']='希望人没事:BAAALAAFFAIIAgABLAAFFAgIBgABAF8TAA==.',['帝国']='帝国之大督军:BAAALAAFFAIIAgAAAA==.',['平凡']='平凡的平凡:BAABLAAFFH8IAAIEAAYIlBspJgCaAQAEAAYIlBspJgCaAQAAAA==.',['年轻']='年轻的信赖:BAABLAAFFH8FAAIWAAMI0g/4CgC+AAAWAAMI0g/4CgC+AAAAAA==.',['幻夜']='幻夜:BAAALAAECgEIAQAAAA==.',['幽眀']='幽眀孤神:BAAALAAECgYIEwAAAA==.',['彩云']='彩云间:BAACLAAFFH8pAAIGAAYIEyE8AgDcAQAGAAYIEyE8AgDcAQAsAAQKfxwAAwYACAg9IAERAJ4CAAYACAg9IAERAJ4CAB0AAggPCXUbAF4AAAAA.',['彩霞']='彩霞:BAAALAAECgYICQAAAA==.',['影月']='影月晴空:BAACLAAFFH8NAAIaAAUIqQ+8HQDcAAAaAAUIqQ+8HQDcAAAsAAQKfyMAAhoABghTI2URAPUBABoABghTI2URAPUBAAAA.',['往日']='往日岁月:BAAALAAECgYIDAAAAA==.往日时光:BAAALAAECgYIDAAAAA==.',['征伐']='征伐:BAAALAAECgYIBgAAAA==.',['德勒']='德勒克斯汀:BAABLAAFFH8MAAIGAAIIZCD/DACeAAAGAAIIZCD/DACeAAAAAA==.',['德莱']='德莱文:BAAALAAECgYIDgAAAA==.',['怀逸']='怀逸:BAAALAAECgYIBwAAAA==.',['怕是']='怕是失了智:BAAALAADCggICAAAAA==.',['恶魔']='恶魔的允诺:BAAALAAECgcIEwAAAA==.',['惊蛰']='惊蛰韶光:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒橘子:BAABLAAFFH8GAAMPAAII6BgSNACaAAAPAAIISRMSNACaAAAOAAEIyCA0BwBfAAAAAA==.',['懐忆']='懐忆:BAAALAAECgYIDgAAAA==.',['成飞']='成飞秋山澪:BAAALAADCgEIAQAAAA==.',['成龙']='成龙大哥:BAAALAAECgYIDAAAAA==.',['我是']='我是小蛀牙:BAABLAAFFH8OAAIWAAIIWxTPHAAxAAAWAAIIWxTPHAAxAAAAAA==.',['我爱']='我爱说实话:BAAALAAFFAIIAgAAAA==.',['我败']='我败了:BAAALAAECgYIBgAAAA==.',['战神']='战神王者:BAAALAAECgYIBgAAAA==.',['执政']='执政官:BAAALAAECgYIBgAAAA==.',['承诺']='承诺无悔:BAAALAAECggICAAAAA==.',['披萨']='披萨心肠:BAACLAAFFH8SAAIWAAYI3BUfBgB0AQAWAAYI3BUfBgB0AQAsAAQKf1AAAxYACAheAFqFAAIAABYAAghFAVqFAAIAAAkACAhYAAAAAAAAAAEsAAUUBwgtABMA+yUA.',['拉斐']='拉斐尔:BAABLAAFFH8LAAIEAAIIZx11XQCNAAAEAAIIZx11XQCNAAAAAA==.',['拉的']='拉的牛:BAAALAAFFAIIAgAAAA==.',['拔山']='拔山扛鼎:BAABLAAFFH8IAAITAAIIXwQhMQBLAAATAAIIXwQhMQBLAAAAAA==.',['拾光']='拾光:BAAALAAFFAEIAQAAAA==.',['摩呼']='摩呼罗迦:BAAALAADCgEIAQAAAA==.',['敌法']='敌法爱你呦:BAAALAAECgYICwAAAA==.',['无谓']='无谓悲伤:BAAALAAECgQIBAAAAA==.',['时光']='时光她寂寞:BAAALAAECgcIDAAAAA==.',['明睿']='明睿:BAAALAADCggICAAAAA==.',['昵称']='昵称都是浮云:BAABLAAFFH8GAAIcAAIIPBNJJQB4AAAcAAIIPBNJJQB4AAAAAA==.',['智信']='智信大师:BAAALAAECgYICgAAAA==.',['暖了']='暖了个暖:BAAALAADCggICAAAAA==.',['暴怒']='暴怒的哲人:BAABLAAFFH8KAAIBAAYIoxRBOQBWAQABAAYIoxRBOQBWAQAAAA==.',['替我']='替我朋友问问:BAAALAAECgUIBQAAAA==.',['最后']='最后的希望:BAAALAAECgQIBAAAAA==.最后的救赎:BAAALAAECgYIEQAAAA==.最后的荣耀:BAAALAAECgYIDwAAAA==.最后的觉醒:BAACLAAFFH8XAAIDAAUI7RIqGQDoAAADAAUI7RIqGQDoAAAsAAQKfyMAAwMACAj8GnlIAAUCAAMACAj8GnlIAAUCAAUAAQggBhh+ACsAAAAA.',['月娆']='月娆之兰:BAAALAAECgYIBgAAAA==.',['月璃']='月璃灬长歌:BAAALAAFFAIIBAAAAA==.',['月神']='月神灬长歌:BAAALAAECgYIBgAAAA==.',['月舞']='月舞若若:BAAALAADCgMIAwAAAA==.',['朱泙']='朱泙漫:BAAALAAECgYIDwAAAA==.',['来了']='来了看看:BAABLAAECn8aAAIPAAgILRLvKgCxAQAPAAgILRLvKgCxAQAAAA==.',['松籁']='松籁响起之时:BAAALAADCggICAAAAA==.',['极限']='极限特工:BAAALAAECgUICAAAAA==.',['林林']='林林津京:BAAALAADCgQIBAAAAA==.',['栀子']='栀子比众木:BAAALAAFFAIIAgAAAA==.',['标准']='标准的猎者:BAAALAAECgYIBgAAAA==.',['桑塔']='桑塔纳:BAAALAAFFAIIAgAAAA==.',['梁朝']='梁朝伟:BAAALAAECgIIAgAAAA==.',['梅丽']='梅丽塔丶:BAAALAAECgIIAgAAAA==.',['梅赛']='梅赛德斯:BAAALAADCgIIAgAAAA==.',['梦想']='梦想之光:BAAALAAECgYIEAAAAA==.',['梦鱼']='梦鱼银依:BAAALAAECgEIAQAAAA==.',['極樂']='極樂丨主宰:BAAALAAECgYIDAAAAA==.極樂丨揍敵客:BAAALAAECgYICgAAAA==.',['橘子']='橘子味的猫:BAABLAAFFH8FAAIJAAMIVhPyQQCOAAAJAAMIVhPyQQCOAAAAAA==.',['欧阳']='欧阳伊雅:BAAALAAECgEIAQAAAA==.',['正义']='正义审判者:BAAALAAECgYIBwAAAA==.',['死亡']='死亡抉择:BAABLAAFFH8FAAIBAAII9ARAmQA6AAABAAII9ARAmQA6AAAAAA==.死亡镇魂歌:BAAALAAECgYICAAAAA==.',['死骑']='死骑:BAAALAAECgYIDAAAAA==.',['毁灭']='毁灭少年的诗:BAABLAAECn8VAAIUAAYIJB6dHgDEAQAUAAYIJB6dHgDEAQAAAA==.',['永恒']='永恒的终结:BAABLAAFFH8GAAIXAAIINgsWIAA7AAAXAAIINgsWIAA7AAAAAA==.',['沉睡']='沉睡的小猫:BAABLAAFFH8GAAICAAIIowfOTACGAAACAAIIowfOTACGAAABLAAFFAgIPgACAL0lAA==.',['沙洋']='沙洋那拉:BAABLAAFFH8HAAIeAAIInQKCaQAtAAAeAAIInQKCaQAtAAAAAA==.',['沸雾']='沸雾:BAAALAAECgcIBwAAAA==.',['法力']='法力丶残渣:BAAALAADCgYIBgAAAA==.',['海外']='海外小猪:BAAALAAECgYIDwAAAA==.',['深渊']='深渊彼岸花:BAAALAAECgMIAwAAAA==.',['混乱']='混乱浩劫丶泽:BAAALAAFFAMIBAAAAA==.',['清风']='清风铃醉影:BAAALAAECgIIAgAAAA==.',['溪明']='溪明:BAAALAAECgMIAwAAAA==.',['漠雪']='漠雪:BAABLAAFFH8IAAICAAYImxsRKQB1AQACAAYImxsRKQB1AQAAAA==.',['火眼']='火眼初试:BAAALAAECgYIBgAAAA==.',['火酒']='火酒灬长歌:BAAALAAFFAIIBAABLAAFFAgIDwAfAL4hAA==.',['灬汐']='灬汐瞳灬:BAAALAADCgEIAQAAAA==.',['灬清']='灬清风知雨灬:BAAALAAECgQIBAAAAA==.',['灬菩']='灬菩蕯灬:BAAALAAECgQIBAAAAA==.',['灬飞']='灬飞仙诀灬:BAAALAAECgYIBgAAAA==.',['灼热']='灼热双目:BAAALAAFFAIIAgAAAA==.',['炖虾']='炖虾大王:BAACLAAFFH8IAAIEAAIIvg/XjwBFAAAEAAIIvg/XjwBFAAAsAAQKfx8AAgQACAhqJm8EAG8DAAQACAhqJm8EAG8DAAEsAAUUCAgBABsAAAAA.',['炽鳯']='炽鳯:BAAALAAECgYIBwAAAA==.',['烈性']='烈性伏特加:BAAALAAECgUIBwAAAA==.',['热心']='热心市民:BAAALAAECgIIAgAAAA==.',['燕舞']='燕舞莺歌:BAABLAAFFH8NAAILAAIIzwo6HQCCAAALAAIIzwo6HQCCAAAAAA==.',['爱因']='爱因思念:BAAALAAECgQIBAAAAA==.',['牧志']='牧志铭:BAEBLAAFFH8RAAIMAAUIgBZIAQBlAQAMAAUIgBZIAQBlAQAAAA==.',['狂傲']='狂傲不羁:BAAALAAECgYIBwAAAA==.',['狼人']='狼人小杖:BAAALAAFFAIIBAAAAA==.',['猎头']='猎头公司:BAAALAAECgYIDAAAAA==.',['猫咪']='猫咪公主:BAAALAAECgYIDAAAAA==.',['猫王']='猫王在世:BAAALAAFFAIIAgAAAA==.',['王牌']='王牌技师:BAAALAAECggICAAAAA==.',['玛利']='玛利喀斯:BAAALAAECgMIAwAAAA==.',['琴瑟']='琴瑟:BAACLAAFFH8WAAIDAAYIexJtCQCnAQADAAYIexJtCQCnAQAsAAQKfyQAAgMACAiBHTcrAGUCAAMACAiBHTcrAGUCAAAA.',['瓦丁']='瓦丁米儿猎豹:BAAALAAECgYICwAAAA==.',['瓦洛']='瓦洛伽:BAAALAAECgYIDAAAAA==.瓦洛嘉:BAAALAADCggICAAAAA==.',['瓦罗']='瓦罗嘉:BAAALAAECgYIDQAAAA==.瓦罗葭:BAAALAAECgYICgAAAA==.',['瘟疫']='瘟疫快走開:BAAALAAECgUIBQAAAA==.',['白煞']='白煞浩杰:BAAALAAECgYICAAAAA==.',['百兽']='百兽精灵王:BAAALAAFFAIIBAAAAA==.',['看我']='看我眼神行事:BAAALAAECgIIAgAAAA==.',['看死']='看死你:BAABLAAFFH8MAAMgAAYISRJhIQB6AQAgAAYIIBJhIQB6AQAZAAIIfhfyEgA3AAAAAA==.',['码维']='码维丶影歌:BAAALAAFFAIIAgAAAA==.',['硬汉']='硬汉棒棒军:BAAALAAFFAIIBAAAAA==.',['福娃']='福娃骑士京京:BAABLAAFFH8KAAIIAAMIABCRDACTAAAIAAMIABCRDACTAAAAAA==.',['秋山']='秋山小澪:BAAALAADCggICAAAAA==.',['竖尸']='竖尸:BAAALAAFFAIIAgAAAA==.',['等等']='等等泽:BAABLAAECn8WAAMhAAgIOR1dCQAaAgAhAAgIOR1dCQAaAgAEAAYIYBQefgBLAQAAAA==.',['简单']='简单狂暴:BAAALAAECgYIDAAAAA==.',['米罗']='米罗丹银歌:BAAALAAFFAEIAQAAAA==.',['紫夜']='紫夜:BAAALAADCgQIBAAAAA==.紫夜蓝月:BAAALAAECgYIBgAAAA==.',['紫晶']='紫晶铃:BAAALAAECgYIBgAAAA==.',['纪大']='纪大德:BAAALAAECgYIEgAAAA==.',['纪小']='纪小德:BAABLAAECn8UAAIVAAYINA0sUQDRAAAVAAYINA0sUQDRAAAAAA==.',['纯情']='纯情女大:BAACLAAFFH8MAAIJAAYInx6SDwDIAQAJAAYInx6SDwDIAQAsAAQKfxUAAwkABwixGW1DAJEBAAkABwixGW1DAJEBABwABAgaBpE4AH8AAAAA.',['绝地']='绝地游侠:BAABLAAFFH8GAAITAAIIJgiyLgBcAAATAAIIJgiyLgBcAAAAAA==.',['维生']='维生素逸果酱:BAABLAAFFH8uAAIfAAcI2SDyBAAWAgAfAAcI2SDyBAAWAgAAAA==.',['罗门']='罗门达特:BAAALAAECgIIAgAAAA==.',['美丽']='美丽我的爱:BAAALAAECgIIAgAAAA==.',['翟星']='翟星:BAEBLAAFFH8JAAIPAAMI0g5EOQCNAAAPAAMI0g5EOQCNAAABLAAFFAUIEQAMAIAWAA==.',['耀光']='耀光光:BAAALAAECgYIDAAAAA==.',['老道']='老道来个武僧:BAAALAAECgYICwAAAA==.',['耐瑟']='耐瑟城牧羊人:BAAALAAECgMIAwAAAA==.',['肥头']='肥头小耳:BAAALAAECgYICgAAAA==.',['胖大']='胖大新:BAAALAAECgUIBQAAAA==.',['胖帆']='胖帆:BAABLAAFFH8FAAIFAAMIQQznOwBYAAAFAAMIQQznOwBYAAAAAA==.',['胡子']='胡子:BAAALAAECgYIDAAAAA==.',['自恋']='自恋的猪:BAABLAAFFH8KAAIWAAII2xY7GgBxAAAWAAII2xY7GgBxAAAAAA==.',['艾森']='艾森娜的云:BAAALAAECgYIBwAAAA==.艾森娜的门:BAAALAAFFAIIBAAAAA==.艾森娜的风:BAABLAAFFH8HAAIEAAIIMAZ6rgA4AAAEAAIIMAZ6rgA4AAAAAA==.',['艾瑞']='艾瑞贝丝:BAABLAAFFH8IAAIWAAIIXhsuGgA2AAAWAAIIXhsuGgA2AAAAAA==.艾瑞贝丝卡:BAABLAAFFH8HAAITAAIIgwfGOAAmAAATAAIIgwfGOAAmAAAAAA==.',['艾蕾']='艾蕾西娅:BAAALAAFFAIIAgAAAA==.',['艾薾']='艾薾旎莔莔:BAAALAAECgYICAAAAA==.艾薾旎蒾萘:BAABLAAFFH8aAAIUAAUIXBqaFgCdAQAUAAUIXBqaFgCdAQAAAA==.',['芬鸭']='芬鸭:BAAALAAECgMIAwAAAA==.',['苏图']='苏图:BAABLAAFFH8KAAIBAAMI+RTiXACVAAABAAMI+RTiXACVAAAAAA==.',['苦信']='苦信大师:BAAALAAECgIIAgAAAA==.',['茱蒂']='茱蒂斯泰琳:BAAALAAFFAIIAgABLAAFFAcIHAAQAOIjAA==.',['莎朗']='莎朗温亚德:BAAALAAECgEIAQAAAA==.',['莱姆']='莱姆:BAAALAADCgEIAQAAAA==.',['萌叔']='萌叔不喂奶:BAABLAAFFH8NAAIgAAUIjRnQKABMAQAgAAUIjRnQKABMAQAAAA==.',['萨满']='萨满大叔:BAAALAAECgYIDAAAAA==.',['萨菲']='萨菲娜:BAAALAAECgEIAQAAAA==.',['落雁']='落雁丶:BAAALAAECgYICQAAAA==.',['蓝云']='蓝云琳月:BAAALAADCgcIBwAAAA==.',['蕾伊']='蕾伊:BAAALAAECgYIBgAAAA==.',['虚淵']='虚淵玄:BAAALAAECgYIDAAAAA==.',['蝎子']='蝎子莱莱:BAAALAAECgYIBgAAAA==.',['蝰蛇']='蝰蛇钉刺:BAAALAAECgIIAgABLAAFFAgICwADAEofAA==.',['西亭']='西亭月:BAAALAAECgIIAgAAAA==.',['西马']='西马拉雅:BAAALAAFFAIIBAAAAA==.',['说好']='说好不再见:BAABLAAFFH8QAAIgAAUICRkaDQDWAQAgAAUICRkaDQDWAQAAAA==.',['诸星']='诸星大:BAAALAAECggICAABLAAFFAcIHAAQAOIjAA==.',['诺克']='诺克斯:BAAALAAFFAIIAgAAAA==.',['谢霆']='谢霆锋:BAAALAAECgEIAQAAAA==.',['豹豹']='豹豹猫猫:BAAALAAECgYIBgABLAAFFAIIAgAbAAAAAA==.',['贝蕾']='贝蕾莉尔:BAAALAADCgEIAQAAAA==.',['贱笑']='贱笑:BAAALAAFFAMIAwAAAA==.',['赤瞳']='赤瞳灬:BAAALAAFFAIIBAAAAA==.',['起手']='起手英勇:BAAALAAECgYIDAAAAA==.',['车宝']='车宝贝:BAAALAAFFAIIAgAAAA==.',['辛龙']='辛龙:BAEBLAAFFH8QAAIJAAUIFBRNKQAzAQAJAAUIFBRNKQAzAQABLAAFFAUIEQAMAIAWAA==.',['迈克']='迈克劫个色:BAABLAAFFH8GAAIiAAII5Qg/CgBhAAAiAAII5Qg/CgBhAAAAAA==.',['迦叶']='迦叶灬长歌:BAABLAAFFH8IAAMSAAIIyQoRFAB+AAASAAIIyQoRFAB+AAANAAIIBQjFGQA5AAAAAA==.',['迦楼']='迦楼罗:BAAALAAECgQIBQAAAA==.',['迪丽']='迪丽热嘛:BAACLAAFFH8JAAITAAII/QSJLQBgAAATAAII/QSJLQBgAAAsAAQKfy0AAhMABgitDetaABkBABMABgitDetaABkBAAAA.',['退至']='退至众人身后:BAAALAAECgEIAQAAAA==.',['那都']='那都不算事:BAAALAAFFAIIAgAAAA==.',['邪恶']='邪恶的代言人:BAAALAADCgIIAgAAAA==.',['部落']='部落永不洗头:BAAALAAECgUICgAAAA==.',['金眼']='金眼狻猊:BAAALAAECgIIAgAAAA==.',['铁皮']='铁皮:BAAALAAECgIIAgAAAA==.',['铁钩']='铁钩船长:BAAALAAECgEIAgAAAA==.',['银河']='银河之旖:BAAALAAFFAIIAwAAAA==.银河之汐:BAAALAAECgYIDAAAAA==.银河之舞:BAAALAAFFAIIAgAAAA==.银河之锋:BAABLAAECn8UAAIgAAYIEhmFhQC7AQAgAAYIEhmFhQC7AQAAAA==.',['长尾']='长尾巴的猫:BAAALAAECgYIDQAAAA==.',['阎摩']='阎摩:BAAALAADCgMIAwAAAA==.',['防火']='防火龙:BAABLAAFFH8IAAIXAAIIPBQOGwBRAAAXAAIIPBQOGwBRAAAAAA==.',['阿列']='阿列克:BAAALAAECgYIDwAAAA==.',['阿尔']='阿尔蒂娜:BAAALAAECggICAAAAA==.',['陆月']='陆月拾柒:BAAALAAFFAEIAQAAAA==.',['雨蝶']='雨蝶儿:BAAALAAECgYIDAAAAA==.',['雪晴']='雪晴:BAAALAAECgIIAgAAAA==.',['雪落']='雪落无迹:BAAALAAECgYIEgAAAA==.',['雪魂']='雪魂归来:BAACLAAFFH8VAAIZAAUIzg7tAgBPAQAZAAUIzg7tAgBPAQAsAAQKfyIAAxkACAh1G5AfAL0BACAABgh+Hbx4ANMBABkACAgzFZAfAL0BAAAA.',['雲鬼']='雲鬼:BAABLAAECn8WAAIgAAgIfxryRABTAgAgAAgIfxryRABTAgAAAA==.',['雷奔']='雷奔云谲:BAABLAAFFH8MAAIDAAIIwxjcSgCHAAADAAIIwxjcSgCHAAAAAA==.',['青黛']='青黛:BAAALAAECgcIBAAAAA==.',['静待']='静待丨醉蝶:BAAALAADCgMIAwAAAA==.',['韦小']='韦小宝的老婆:BAACLAAFFH8MAAIDAAIIHhT2UQB3AAADAAIIHhT2UQB3AAAsAAQKfx8AAgMABwhqGGQkAOABAAMABwhqGGQkAOABAAAA.',['颜丶']='颜丶如玉:BAAALAAECgUICQAAAA==.',['風林']='風林火山:BAAALAADCgcIBwAAAA==.',['风不']='风不消去:BAAALAAECgUIBQAAAA==.',['风暴']='风暴小雪:BAAALAAECgYICQAAAA==.风暴雀鹰:BAAALAAECgYIDAAAAA==.',['风牛']='风牛:BAAALAADCgcIBwAAAA==.',['风神']='风神女:BAABLAAECn8WAAIEAAYIixTChQA/AQAEAAYIixTChQA/AQAAAA==.',['风雷']='风雷企鹅:BAAALAADCgUIBQAAAA==.',['飘影']='飘影之嗣:BAAALAAECgYIEAAAAA==.',['飘渺']='飘渺灬雪域:BAAALAAECgYIBgAAAA==.',['飞翔']='飞翔的果果:BAABLAAECn8VAAIUAAYIlQJcmAC5AAAUAAYIlQJcmAC5AAAAAA==.',['骨头']='骨头汤:BAAALAAECgMIAwAAAA==.',['魅影']='魅影天狼:BAAALAAECgQIBQAAAA==.',['魏柔']='魏柔:BAABLAAFFH8GAAIEAAIIqw5HYgCKAAAEAAIIqw5HYgCKAAAAAA==.',['鸡安']='鸡安娜:BAAALAAECgYIBgAAAA==.',['黑煞']='黑煞余庆:BAAALAAECgYIDwAAAA==.',['齐柏']='齐柏林飞船:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end