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
 local lookup = {'DeathKnight-Frost','DeathKnight-Blood','Hunter-BeastMastery','Druid-Restoration','Druid-Balance','Paladin-Holy','DemonHunter-Havoc','Mage-Arcane','Shaman-Elemental','Warrior-Fury','Priest-Holy','Shaman-Restoration','Warrior-Protection','Paladin-Retribution','Hunter-Marksmanship','Monk-Windwalker','Mage-Fire','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Shadow','DeathKnight-Unholy','Evoker-Preservation','Evoker-Devastation','Monk-Mistweaver','Mage-Frost','Warrior-Arms',}; local provider = {region='CN',realm='耐普图隆',name='CN',type='weekly',zone=44,date='2025-12-06',data={Af='Afatinib:BAABLAAFFH8NAAMBAAYIEQ+HQwCuAAABAAYIZQ2HQwCuAAACAAIISiC6FgBWAAAAAA==.',Al='Alin:BAAALAADCggICQAAAA==.',Ar='Arenas:BAAALAADCgQIBAAAAA==.',Bu='Bulabulamar:BAABLAAFFH8GAAIDAAYI7wkGRwAuAQADAAYI7wkGRwAuAQAAAA==.',Ch='Chfive:BAABLAAFFH8MAAMEAAYIihxeDwDMAQAEAAUIhR9eDwDMAQAFAAIIsRJnJACMAAABLAAFFAYIDwAEALohAA==.Chfour:BAABLAAFFH8MAAIEAAYIphuhDQDhAQAEAAYIphuhDQDhAQAAAA==.Chone:BAABLAAFFH8PAAMEAAYIuiFFBgBKAgAEAAYIuiFFBgBKAgAFAAIIUAq2JgB9AAAAAA==.Chseven:BAABLAAFFH8GAAMEAAYI4BXKGgBWAQAEAAUIBRbKGgBWAQAFAAEIFgesMgA+AAAAAA==.Chthree:BAABLAAFFH8VAAMEAAYINB/BCQARAgAEAAYINB/BCQARAgAFAAIIRQfPJwB2AAAAAA==.Chtwo:BAABLAAFFH8SAAMEAAYIjR8zEgCsAQAEAAUI3x4zEgCsAQAFAAIIdw+IJQCEAAAAAA==.',Er='Erinyes:BAABLAAFFH8FAAIGAAMIuQ14HwCmAAAGAAMIuQ14HwCmAAAAAA==.',Ev='Evatrice:BAABLAAFFH8MAAIHAAYIGyXVCQAoAgAHAAYIGyXVCQAoAgAAAA==.',Fi='Firefox:BAAALAAECgYICwAAAA==.',Fl='Flylead:BAAALAAFFAIIBAAAAA==.Flyleaf:BAABLAAFFH8GAAIIAAII5g31XgA9AAAIAAII5g31XgA9AAAAAA==.Flyleap:BAAALAAFFAIIAgAAAA==.',Go='Gohel:BAAALAAECgEIAQAAAA==.Good:BAAALAAECgYICwAAAA==.Gosick:BAAALAADCggICAAAAA==.',Ha='Haohei:BAABLAAFFH8GAAIJAAII2QwfQQBIAAAJAAII2QwfQQBIAAAAAA==.Harcar:BAAALAAFFAIIBAAAAA==.',Hi='Higher:BAACLAAFFH8MAAIKAAIIjA4vSQBKAAAKAAIIjA4vSQBKAAAsAAQKfyAAAgoACAgOEIl2AJwBAAoACAgOEIl2AJwBAAAA.',Ko='Kotka:BAAALAADCgQIBQAAAA==.',La='Launcelot:BAABLAAFFH8GAAIHAAYI2R3EEwDFAQAHAAYI2R3EEwDFAQAAAA==.',Ma='Magi:BAAALAAECgYICAAAAA==.',Me='Memories:BAAALAAFFAIIAgAAAA==.',Ni='Niuer:BAAALAAECgUIBgAAAA==.',On='Onebo:BAAALAAECgUIBQAAAA==.',Pi='Piag:BAABLAAFFH8vAAILAAYInyaeAwCnAgALAAYInyaeAwCnAgABLAAFFAgIXQAMAHQdAA==.',Rd='Rdss:BAAALAAECgcIBwAAAA==.',Sh='Shell:BAAALAAECgYIBgAAAA==.',St='Stewie:BAAALAADCgEIAQAAAA==.',Sw='Swaggyp:BAAALAADCgcIBwAAAA==.',Ta='Talona:BAAALAAFFAIIBAAAAA==.Talone:BAAALAAECgIIAgAAAA==.',Tr='Triassicus:BAAALAAECgYIBgAAAA==.',Vc='Vcc:BAAALAAECgYIEQAAAA==.',Wa='Wantanything:BAABLAAFFH8IAAINAAIIhA4gKwBnAAANAAIIhA4gKwBnAAAAAA==.',We='Wendy:BAAALAAECgYIBgAAAA==.',['一刻']='一刻晚风:BAAALAAFFAIIBAAAAA==.',['一氧']='一氧化碳:BAAALAAECgUIBQAAAA==.',['一锤']='一锤干爆你:BAABLAAFFH8eAAMGAAYIJxKjEwBSAQAGAAYIJxKjEwBSAQAOAAUIwhOqLQAYAQAAAA==.',['一零']='一零八天下:BAAALAAECgYICwAAAA==.',['一颗']='一颗小土豆:BAAALAAECgIIAgAAAA==.',['三开']='三开战猎萨:BAABLAAFFH8GAAIDAAIIqhwsgABWAAADAAIIqhwsgABWAAAAAA==.',['不三']='不三不四:BAAALAAECgcICQAAAA==.',['不似']='不似丶少年游:BAABLAAFFH8FAAIBAAMICw7OZACCAAABAAMICw7OZACCAAAAAA==.',['不充']='不充值咋变强:BAAALAADCgcIBwAAAA==.',['不打']='不打了退了:BAAALAAECgUIBQAAAA==.',['丨小']='丨小丶丫头丨:BAAALAAECgYICgAAAA==.丨小可爱:BAAALAAECgEIAQAAAA==.',['丨等']='丨等我开:BAAALAAECgUIBgAAAA==.',['丰川']='丰川祥子:BAAALAAFFAIIBAAAAA==.',['丶梦']='丶梦沉:BAAALAAECgIIAgAAAA==.',['丶珀']='丶珀亚拉枫影:BAABLAAFFH8PAAIOAAUI3RIaKgAuAQAOAAUI3RIaKgAuAQAAAA==.',['丶雨']='丶雨露:BAABLAAECn8fAAMPAAgIRiNqHwBrAgAPAAgIsyJqHwBrAgADAAYIYSJyWAAsAgAAAA==.',['丷小']='丷小布:BAAALAADCggICAAAAA==.',['丽莎']='丽莎娜丶火恒:BAAALAADCgYIBgAAAA==.',['乄乛']='乄乛鐡頭:BAAALAAECgYIDAAAAA==.',['云和']='云和山的彼端:BAABLAAFFH8OAAIEAAIIghYPPAB+AAAEAAIIghYPPAB+AAAAAA==.',['五花']='五花丶小烤肉:BAAALAAECgIIAgAAAA==.',['五香']='五香牛肉干:BAAALAAECgIIAgAAAA==.',['从容']='从容:BAAALAAECgYIDAAAAA==.',['休格']='休格拉斯斯:BAAALAADCgQIBAAAAA==.',['优利']='优利安丶怒火:BAAALAAECgYICgAAAA==.',['你曾']='你曾是真爱:BAAALAAECgYIDgAAAA==.',['你认']='你认识他吗:BAAALAAFFAIIAgAAAA==.',['倚泪']='倚泪潇湘:BAAALAAFFAQIBAAAAA==.',['做我']='做我的宝宝:BAAALAAFFAYIAgAAAA==.',['克菈']='克菈蒂雅:BAAALAADCgcIBwAAAA==.',['全部']='全部木大:BAAALAAFFAIIAgAAAA==.',['八个']='八个棒棒:BAABLAAFFH8GAAIMAAYIEwAFgwABAAAMAAYIEwAFgwABAAAAAA==.',['六月']='六月乄雪:BAAALAADCggICAAAAA==.',['农民']='农民开宝马:BAAALAAECgIIAgAAAA==.',['冬灵']='冬灵:BAAALAAFFAgIBAAAAA==.',['冰魂']='冰魂雪魄:BAAALAAFFAIIAgAAAA==.',['凌寒']='凌寒锋:BAABLAAECn8UAAIBAAYIFwpdhADiAAABAAYIFwpdhADiAAAAAA==.',['凯文']='凯文暗刃:BAAALAAECgcICQAAAA==.',['划船']='划船不用桨:BAAALAADCgIIAgAAAA==.',['别处']='别处夕阳:BAABLAAFFH8GAAIHAAIIeQljXQBAAAAHAAIIeQljXQBAAAAAAA==.',['剧摸']='剧摸:BAABLAAFFH8FAAIMAAIIrCCCJwC2AAAMAAIIrCCCJwC2AAAAAA==.',['十迪']='十迪亚波罗十:BAAALAAECgYIDAAAAA==.',['千早']='千早爱音:BAABLAAFFH8GAAIHAAQICR3VEQCIAQAHAAQICR3VEQCIAQAAAA==.',['千灬']='千灬年:BAAALAADCggICAAAAA==.',['午夜']='午夜猫哥:BAABLAAECn8VAAIQAAgIZA73FABpAQAQAAgIZA73FABpAQAAAA==.',['南南']='南南希:BAEBLAAFFH8HAAIIAAIIgSGHMADKAAAIAAIIgSGHMADKAAABLAAFFAgIIgAOAIQhAA==.',['南萧']='南萧萧:BAAALAAFFAIIBAAAAA==.',['卡西']='卡西法:BAAALAAECgYIBgAAAA==.',['双持']='双持小辣椒:BAAALAAECggICQAAAA==.',['双马']='双马尾唤起爱:BAABLAAFFH8KAAIRAAMISRNMBgCPAAARAAMISRNMBgCPAAAAAA==.',['可可']='可可大人:BAABLAAFFH8VAAIOAAYI9RfnFwCTAQAOAAYI9RfnFwCTAQAAAA==.',['吃鸡']='吃鸡腿摄影师:BAAALAADCgMIAwAAAA==.',['呕咖']='呕咖喱唝:BAAALAAECgYIEAAAAA==.',['呗儿']='呗儿肉头儿:BAAALAAECgYIBgAAAA==.',['咕咕']='咕咕嘎嘎:BAAALAAECgIIAgAAAA==.',['哈土']='哈土奇丶:BAABLAAFFH8GAAIHAAIItSEYKAC+AAAHAAIItSEYKAC+AAAAAA==.',['喂丶']='喂丶站住呀:BAAALAAFFAIIAgAAAA==.',['喵法']='喵法自然:BAAALAAECgMIBQAAAA==.',['嘤国']='嘤国大理石:BAABLAAFFH8SAAIHAAYIkg5dGwABAQAHAAYIkg5dGwABAQAAAA==.',['噬魂']='噬魂魅影:BAAALAADCgQIBAAAAA==.',['四溅']='四溅:BAAALAADCgUIBwAAAA==.',['圣誓']='圣誓丨铁蹄:BAAALAAECgQIBAAAAA==.',['堕落']='堕落小魅魔:BAAALAAFFAIIAgAAAA==.',['壹支']='壹支穿云箭:BAAALAAECgEIAQAAAA==.',['壹橙']='壹橙不染:BAAALAADCgIIAgAAAA==.',['壹鬼']='壹鬼吹灯:BAAALAADCgMIAwAAAA==.壹鬼恶魔:BAAALAAECgUIBQAAAA==.',['复古']='复古风格:BAAALAAECgYICAAAAA==.',['多情']='多情贱客:BAAALAAECgYIDAAAAA==.',['大毛']='大毛:BAABLAAFFH8KAAIGAAMIyiKXCwAwAQAGAAMIyiKXCwAwAQABLAAFFAgIDAAGAKUUAA==.',['大珠']='大珠儿:BAAALAAECgcIDQAAAA==.',['大石']='大石碎胸口:BAAALAADCgUIBQAAAA==.',['大良']='大良民:BAAALAAFFAIIBAAAAA==.',['天地']='天地有雪:BAABLAAFFH8MAAMSAAIIaBV5YgA9AAATAAEIIRr5KQBOAAASAAEIrhB5YgA9AAAAAA==.',['天顶']='天顶星狐狸:BAAALAAECgIIAgAAAA==.',['失落']='失落国度:BAAALAAECgIIAgAAAA==.',['奇东']='奇东呛:BAABLAAFFH8IAAIMAAIIxAp2awBPAAAMAAIIxAp2awBPAAAAAA==.',['契卡']='契卡:BAABLAAFFH8HAAIOAAIIbBDRUgCQAAAOAAIIbBDRUgCQAAAAAA==.',['妙手']='妙手小华佗:BAABLAAECn8WAAILAAgIkRijMQAYAgALAAgIkRijMQAYAgAAAA==.',['妞仔']='妞仔:BAAALAAFFAIIAwAAAA==.',['嫣雨']='嫣雨婉情:BAAALAAECgUICQAAAA==.',['宵醉']='宵醉:BAAALAADCgIIAgAAAA==.',['寻找']='寻找千芊的飘:BAAALAADCgEIAQAAAA==.',['将军']='将军的恩情:BAAALAAECggICAAAAA==.',['小卟']='小卟叽:BAABLAAFFH8HAAMPAAIIzRQEJAB/AAADAAII9hCtXACOAAAPAAIIZBEEJAB/AAAAAA==.',['小恐']='小恐龙哦吼:BAABLAAFFH8GAAIIAAYIjx8lGgCzAQAIAAYIjx8lGgCzAQAAAA==.',['小牛']='小牛叉叉:BAAALAAFFAgIAgAAAA==.',['小翊']='小翊豪:BAAALAAECggICQAAAA==.',['小鸟']='小鸟壁纸:BAAALAAECgQIBAAAAA==.',['小黄']='小黄龙:BAABLAAFFH8IAAMTAAIIQB1ADACwAAATAAIIQB1ADACwAAASAAEIERWpXQBBAAAAAA==.',['左岸']='左岸风海:BAAALAAECgUIBQAAAA==.',['常夫']='常夫人:BAAALAAECgYICAAAAA==.',['常山']='常山阴:BAACLAAFFH8bAAMSAAcIThMyDQAFAgASAAcIWxIyDQAFAgATAAIInxElFwCWAAAsAAQKfxYABBIABwj7HpVFACUCABIABwjVHZVFACUCABMABQipFUhKAEgBABQAAQgTEqQ7AEQAAAAA.',['幽兰']='幽兰茗香:BAAALAADCgYICQAAAA==.',['幽明']='幽明大帝:BAABLAAECn8mAAIHAAcIKg90UQAnAQAHAAcIKg90UQAnAQAAAA==.',['幽灵']='幽灵伪装:BAABLAAFFH8FAAISAAIILgV/bAAzAAASAAIILgV/bAAzAAAAAA==.',['异质']='异质结:BAABLAAFFH8GAAMLAAII/RjAJgCeAAALAAII/RjAJgCeAAAVAAIIrAyFIQCLAAAAAA==.',['弗力']='弗力霸:BAABLAAFFH8GAAIEAAII9wRmUwBOAAAEAAII9wRmUwBOAAAAAA==.',['归来']='归来梓灬:BAABLAAFFH8LAAIKAAIIJhnMNgCXAAAKAAIIJhnMNgCXAAAAAA==.',['彼岸']='彼岸花丶:BAEBLAAFFH8IAAIBAAIIqB9VQgCvAAABAAIIqB9VQgCvAAABLAAFFAgIIgAOAIQhAA==.',['微微']='微微:BAAALAAFFAIIAgAAAA==.',['德意']='德意忘形:BAAALAAECgYICQAAAA==.',['心态']='心态要放松:BAABLAAFFH8UAAMBAAUI4hDuQwArAQABAAUI4hDuQwArAQACAAEIXABTIAAXAAABLAAFFAYIFgAIAMIPAA==.',['忆晨']='忆晨:BAECLAAFFH8iAAIOAAgIhCFUAQCCAgAOAAgIhCFUAQCCAgAsAAQKfysAAg4ACAjKJh4BAJYDAA4ACAjKJh4BAJYDAAAA.',['快去']='快去找奈非天:BAABLAAECn8ZAAIHAAYIqBdoSwA4AQAHAAYIqBdoSwA4AQAAAA==.',['恒心']='恒心:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔工艺:BAAALAAECgEIAQAAAA==.',['悠航']='悠航:BAAALAAECgEIAQAAAA==.',['情依']='情依:BAAALAADCgEIAQAAAA==.',['惊鸿']='惊鸿:BAABLAAFFH8XAAMOAAYInh9bEQAzAQAOAAUIpCVbEQAzAQAGAAEIoxooLgBIAAAAAA==.',['我不']='我不怕你:BAAALAAECgYIDQAAAA==.',['我勒']='我勒个嚓儿:BAAALAADCgEIAQAAAA==.我勒个国宝:BAAALAAECgYIAwAAAA==.我勒个逗儿:BAABLAAECn8VAAIJAAYIOwlwiwAhAQAJAAYIOwlwiwAhAQAAAA==.',['我没']='我没交医保啊:BAAALAAFFAIIAgAAAA==.',['我跑']='我跑你别追:BAAALAADCgYIBgAAAA==.',['战神']='战神白起:BAAALAAECgYIBgAAAA==.',['战纹']='战纹:BAABLAAFFH8NAAINAAYI7h4SCADCAQANAAYI7h4SCADCAQAAAA==.',['手机']='手机质检员:BAACLAAFFH8oAAIEAAcIcxurCAAiAgAEAAcIcxurCAAiAgAsAAQKfyIAAwQACAgAHNQkAFUCAAQACAgAHNQkAFUCAAUAAQjNFxdcAEYAAAAA.',['拉姆']='拉姆:BAAALAAECgYIBgAAAA==.',['招摇']='招摇点心:BAAALAAECggICAAAAA==.',['放肆']='放肆骄傲丶:BAAALAAECgYIBgAAAA==.',['施瓦']='施瓦辛格:BAABLAAFFH8HAAIBAAMIjg9bNQDJAAABAAMIjg9bNQDJAAAAAA==.',['无敌']='无敌和炉石:BAAALAAFFAMIBAAAAA==.无敌至尊王:BAAALAAFFAIIAgAAAA==.',['无聊']='无聊的深井冰:BAAALAAECgYIBgAAAA==.',['日暮']='日暮天寒:BAABLAAECn8gAAMFAAcIihhnGACtAQAFAAcIihhnGACtAQAEAAMIZQ0JaQB+AAAAAA==.',['明則']='明則:BAAALAAECgUIBQAAAA==.',['易天']='易天绝卦:BAAALAAECgYIEAAAAA==.',['晓之']='晓之以礼:BAABLAAFFH8GAAILAAIIRQ3wPQBuAAALAAIIRQ3wPQBuAAAAAA==.',['晓雪']='晓雪江烟:BAACLAAFFH8OAAMEAAIIqAkXPQBjAAAEAAIIqAkXPQBjAAAFAAIIOgQoPAAvAAAsAAQKfxYAAgQABwhvE/5UAJcBAAQABwhvE/5UAJcBAAAA.',['晴城']='晴城夜:BAAALAAECgQIBAAAAA==.',['晴朗']='晴朗:BAABLAAFFH8JAAIDAAUILRxxQABFAQADAAUILRxxQABFAQAAAA==.',['暗影']='暗影追猎者:BAAALAAECgYIDwAAAA==.',['暴力']='暴力战法:BAAALAAECgEIAQAAAA==.暴力战牛:BAAALAAFFAEIAQAAAA==.暴力战萨:BAAALAAFFAIIAgAAAA==.',['暴鲤']='暴鲤龙:BAAALAADCgYIBgAAAA==.',['来瓶']='来瓶果粒橙:BAAALAAECgYIBgAAAA==.来瓶绿茶:BAAALAADCgEIAQAAAA==.来瓶脉动:BAAALAAFFAIIAgAAAA==.来瓶雷碧:BAAALAAFFAIIAgAAAA==.',['果冻']='果冻的拥抱:BAAALAAECgYIDwAAAA==.',['枭申']='枭申克:BAAALAAECgUIBQAAAA==.',['柔和']='柔和的泪光:BAABLAAFFH8sAAIBAAYIwR4pHQDBAQABAAYIwR4pHQDBAQAAAA==.',['桃心']='桃心兔子牙:BAABLAAFFH8aAAIBAAYIGBdUKACVAQABAAYIGBdUKACVAQAAAA==.',['梅穿']='梅穿苦茶:BAAALAAECgEIAQAAAA==.',['椰羊']='椰羊:BAABLAAFFH8LAAIBAAMIXgzKMADYAAABAAMIXgzKMADYAAAAAA==.',['横冲']='横冲直撞:BAAALAAECgUIBQAAAA==.',['欧德']='欧德沃福:BAAALAAECgEIAQAAAA==.',['歌狂']='歌狂:BAAALAAECgQIBAAAAA==.',['此去']='此去丶小半生:BAAALAAECgYIDwAAAA==.',['殴打']='殴打团长:BAAALAAECgYICAAAAA==.',['毛毛']='毛毛:BAAALAAECgYIBgAAAA==.毛毛妮儿:BAAALAAECgYIBwAAAA==.',['永神']='永神夜:BAABLAAECn8XAAIIAAcIJRWJagDIAQAIAAcIJRWJagDIAQAAAA==.',['汀兰']='汀兰丨零:BAAALAAECgYIBgAAAA==.',['江南']='江南岸:BAAALAAECgIIAgAAAA==.',['沃德']='沃德亿负:BAABLAAFFH8OAAQWAAYInhgwAwCcAQAWAAYIMxgwAwCcAQABAAQIBxcKGwBNAQACAAQIQwIRFACIAAAAAA==.',['泰妮']='泰妮布里雅:BAAALAADCggICAAAAA==.',['泽卷']='泽卷大饼:BAAALAAECgEIAQAAAA==.',['洛十']='洛十方:BAAALAAECgQICAAAAA==.',['浪蹄']='浪蹄子:BAABLAAFFH8IAAIDAAMIzBpnIQD/AAADAAMIzBpnIQD/AAAAAA==.',['海棠']='海棠蛮:BAAALAAECgUIBQAAAA==.',['湮灭']='湮灭之鳞:BAAALAADCgYIBgAAAA==.',['潘小']='潘小闲:BAAALAADCgYIBgAAAA==.',['火箭']='火箭跳跳:BAAALAADCgYIBgAAAA==.',['灰阿']='灰阿灰阿灰:BAAALAAFFAIIAgAAAA==.',['灾厄']='灾厄林克:BAAALAADCgUIBQAAAA==.',['炎烬']='炎烬:BAAALAAECgUIBQAAAA==.',['炒不']='炒不熟的排骨:BAABLAAFFH8IAAIBAAYIyiAgIQCwAQABAAYIyiAgIQCwAQAAAA==.',['炖不']='炖不熟的排骨:BAAALAAECgYIDAAAAA==.',['炫之']='炫之图腾萨:BAAALAAFFAIIBAAAAA==.炫之践踏牛:BAAALAAFFAIIAgAAAA==.',['炮哥']='炮哥加油:BAAALAAECgMIAwAAAA==.',['烈焰']='烈焰叹息:BAAALAAECgMIBQAAAA==.',['烟雨']='烟雨任平生:BAABLAAFFH8FAAIKAAUI4gKfOgCIAAAKAAUI4gKfOgCIAAAAAA==.',['烤不']='烤不熟的排骨:BAAALAAECggICAAAAA==.',['焖不']='焖不熟的排骨:BAABLAAFFH8JAAIOAAYIqiRPDwBSAQAOAAYIqiRPDwBSAQABLAAFFAgIBwATAMwgAA==.',['焖得']='焖得熟的排骨:BAABLAAFFH8GAAMXAAYI8Q3BBwBfAQAXAAUIEA/BBwBfAQAYAAEIXAByJQA1AAAAAA==.',['無雙']='無雙之刃:BAAALAAECgYIBgAAAA==.',['爱情']='爱情殺手:BAABLAAFFH8IAAMSAAIILBKxRACSAAASAAIILBKxRACSAAATAAEIZwlcIQAAAAAAAA==.',['牛哞']='牛哞牛哞哞:BAAALAAECgQIBwAAAA==.',['牛肉']='牛肉老板:BAACLAAFFH8GAAILAAIIbAqyQQBnAAALAAIIbAqyQQBnAAAsAAQKfx8AAgsACAj4FXkeAMUBAAsACAj4FXkeAMUBAAAA.',['狂浪']='狂浪:BAAALAAECgYIBgAAAA==.',['狂骑']='狂骑必胜:BAABLAAECn8XAAIBAAgImBj6aAAkAgABAAgImBj6aAAkAgAAAA==.',['狐小']='狐小睿:BAAALAAECgMIAwAAAA==.',['玩到']='玩到养老:BAAALAAECgYICgAAAA==.',['琉丶']='琉丶克:BAAALAAFFAIIAgAAAA==.',['瑞文']='瑞文:BAABLAAECn8VAAIBAAgIsB/dMgCpAgABAAgIsB/dMgCpAgAAAA==.',['瑞雯']='瑞雯:BAAALAAECggICAAAAA==.瑞雯丶:BAABLAAFFH8JAAMPAAII0yDYFwCuAAAPAAII0yDYFwCuAAADAAEIqws+qgA6AAAAAA==.',['瑾歆']='瑾歆:BAAALAAECgEIAQAAAA==.',['电你']='电你菊花:BAAALAADCgIIAgAAAA==.',['疯爆']='疯爆打击:BAAALAAECgYICQAAAA==.',['疯狂']='疯狂的牛仔:BAABLAAFFH8KAAMKAAIIQh2uQwBQAAAKAAIIQh2uQwBQAAANAAIIFAo/MQAyAAAAAA==.',['疯行']='疯行:BAAALAAECgYIDwAAAA==.',['瘟疫']='瘟疫龙妞:BAAALAAFFAMIAwAAAA==.',['百分']='百分之四十牧:BAACLAAFFH8iAAMVAAUIFBJqDAB4AQAVAAUIFBJqDAB4AQALAAII6wLMSQBVAAAsAAQKfyoAAhUACAhcHg4YAKwCABUACAhcHg4YAKwCAAAA.',['皺著']='皺著眉頭的你:BAACLAAFFH8UAAIOAAMIaB5jOgCvAAAOAAMIaB5jOgCvAAAsAAQKfyAAAg4ABwiUIP45AK8BAA4ABwiUIP45AK8BAAAA.皺著眉頭看雨:BAABLAAFFH8WAAIBAAMICh7SWAChAAABAAMICh7SWAChAAAAAA==.皺著眉頭看雲:BAABLAAFFH8SAAMLAAYIOBveEwC4AQALAAYIOBveEwC4AQAVAAYIOBtNCwChAQAAAA==.',['看我']='看我牛角行事:BAABLAAFFH8GAAINAAII1Q/CIwB2AAANAAII1Q/CIwB2AAAAAA==.',['眼睛']='眼睛的小珍珠:BAAALAAFFAIIBAAAAA==.',['祖尔']='祖尔德纲:BAAALAAECgYIEgAAAA==.',['竹间']='竹间烟泛泛:BAAALAAECgQIBAAAAA==.',['粉红']='粉红色玳:BAAALAAECgcIEwAAAA==.',['糯米']='糯米:BAAALAAFFAEIAQAAAA==.',['納蘭']='納蘭飄風:BAABLAAECn8WAAIOAAgI4BqqHQAoAgAOAAgI4BqqHQAoAgAAAA==.',['红油']='红油凉皮:BAABLAAFFH8FAAIBAAIIphlgXQCZAAABAAIIphlgXQCZAAAAAA==.红油辣子:BAAALAAFFAMIBAAAAA==.',['红色']='红色体育生:BAAALAAFFAMIAwAAAA==.',['绿皮']='绿皮波比:BAABLAAFFH8SAAMSAAgIuyMgAgDpAgASAAgIuyMgAgDpAgATAAEIhQmQLQBIAAAAAA==.',['美艳']='美艳大龄宅女:BAAALAAECgMIAwAAAA==.',['翊豪']='翊豪啊:BAAALAAECgYIBwAAAA==.',['翼戾']='翼戾丹丶怒风:BAAALAAECgUIBQAAAA==.',['老王']='老王虾面好吃:BAEBLAAFFH8KAAIKAAMILxdOHADnAAAKAAMILxdOHADnAAABLAAFFAgIIgAOAIQhAA==.',['联盟']='联盟追踪者:BAAALAAECgIIAgAAAA==.',['肆意']='肆意丶大哥:BAAALAAECgYIBgAAAA==.',['肥嘟']='肥嘟嘟左卫门:BAAALAAECgQIBgABLAAFFAgIBgAFAJAcAA==.',['胖胖']='胖胖的高乐橙:BAAALAAFFAIIAgAAAA==.',['胸毛']='胸毛随风飘:BAAALAAECgIIAgAAAA==.',['脚穿']='脚穿拖鞋:BAAALAAECgYIBgAAAA==.',['舒适']='舒适的黄蜜桃:BAABLAAFFH8GAAISAAYIEwBPdgACAAASAAYIEwBPdgACAAAAAA==.',['舟唱']='舟唱晚雁惊寒:BAAALAAFFAMIAwAAAA==.',['艾丶']='艾丶斯:BAAALAADCgMIAwAAAA==.',['苏萧']='苏萧若:BAAALAAECgUIBQAAAA==.',['范尼']='范尼斯特鲁伊:BAAALAADCgYIBgAAAA==.',['茶余']='茶余饭后:BAAALAAECgYICAAAAA==.',['茶包']='茶包:BAABLAAFFH8GAAIZAAIIQggYGABdAAAZAAIIQggYGABdAAAAAA==.',['菜皮']='菜皮儿:BAAALAAFFAIIBAAAAA==.',['葡萄']='葡萄物语:BAAALAAFFAMIAgAAAA==.',['蒙牛']='蒙牛达雷:BAAALAADCgMIAwAAAA==.',['蛋妃']='蛋妃飞飞:BAAALAAFFAIIBAAAAA==.',['赫丽']='赫丽贝児:BAAALAADCgUIBQAAAA==.',['赫傲']='赫傲伯兴:BAAALAAECgcIDQAAAA==.',['跕丶']='跕丶飞扬:BAAALAAECgYIBgAAAA==.',['踏雪']='踏雪飞歌:BAAALAAECgMIAwAAAA==.',['輚丶']='輚丶飞扬:BAAALAAFFAIIAgAAAA==.',['软香']='软香蕉:BAAALAADCgIIAgAAAA==.',['还得']='还得是楠哥:BAAALAAECgYICgAAAA==.',['这妞']='这妞真帅:BAAALAAFFAIIAgAAAA==.',['迪蒙']='迪蒙丶亨特:BAAALAADCgMIAwAAAA==.',['迷离']='迷离时刻:BAAALAADCgUICAAAAA==.',['追火']='追火车:BAABLAAFFH8KAAIBAAMI7BsgJAALAQABAAMI7BsgJAALAQAAAA==.',['逍遥']='逍遥雪天:BAABLAAFFH8JAAILAAIIyAJESgBTAAALAAIIyAJESgBTAAAAAA==.',['通灵']='通灵领主:BAACLAAFFH8yAAQWAAcIHiNNAABjAgAWAAcIHiNNAABjAgABAAQIGBOZVgCtAAACAAEIywVFIQAAAAAsAAQKfxUAAxYABwhhJVIMAI0CABYABwivJFIMAI0CAAEABAivIBI6AeoAAAAA.',['逝去']='逝去的无奈:BAAALAADCgQIBAAAAA==.',['邪灵']='邪灵怒吼:BAACLAAFFH8IAAIKAAIIrwQMWwA7AAAKAAIIrwQMWwA7AAAsAAQKfxYAAgoABghFC4i9AAEBAAoABghFC4i9AAEBAAAA.',['都赖']='都赖蒙特拉:BAAALAADCgQIBAAAAA==.',['释怀']='释怀呐段情:BAAALAAECggICAAAAA==.',['银月']='银月城的光丨:BAAALAAECgMIAwAAAA==.',['锤你']='锤你小胸胸:BAAALAAECgQIBAAAAA==.',['锦衣']='锦衣夜行:BAAALAAECgQIBQAAAA==.',['长崎']='长崎素世:BAABLAAFFH8hAAMSAAYIKhpyDwDsAQASAAYIpxhyDwDsAQATAAEIehz1JABUAAAAAA==.',['闪电']='闪电魔影:BAABLAAECn8YAAMTAAYIWhQBPAB8AQATAAYIWhQBPAB8AQASAAEIOwLupAAOAAAAAA==.',['闲杂']='闲杂人等:BAAALAADCgEIAQAAAA==.',['阿华']='阿华田侑嘉:BAACLAAFFH8UAAIOAAYIPxM9HwBtAQAOAAYIPxM9HwBtAQAsAAQKfxwAAg4ABwiVIahOAFMCAA4ABwiVIahOAFMCAAAA.',['阿楠']='阿楠喜欢养猫:BAAALAAECgcIBwAAAA==.',['雪乄']='雪乄碧:BAAALAAECgIIAgAAAA==.',['零丨']='零丨祭渊灬:BAAALAADCgQIBAAAAA==.',['零零']='零零碎碎:BAAALAAECgYIBgAAAA==.',['霹雳']='霹雳双刀小吼:BAABLAAFFH8GAAIKAAYIOwBraAAGAAAKAAYIOwBraAAGAAAAAA==.霹雳术术:BAAALAADCgEIAQAAAA==.',['青火']='青火:BAAALAADCgIIAgAAAA==.',['風箏']='風箏舞紛飛:BAACLAAFFH8JAAIIAAMIkBJ0QgCaAAAIAAMIkBJ0QgCaAAAsAAQKfxYAAwgACAgiGkpMACACAAgACAiMGUpMACACABoAAwhrHaBkAOAAAAAA.',['首长']='首长:BAAALAAECgUIBQAAAA==.',['马里']='马里奥利奥:BAAALAAECgIIAgAAAA==.',['魅影']='魅影小关服:BAABLAAFFH8GAAIKAAII0xGmSABKAAAKAAII0xGmSABKAAAAAA==.魅影小圣骑:BAAALAAFFAIIBAAAAA==.魅影小死骑:BAABLAAFFH8GAAIBAAIIsRuBdQBLAAABAAIIsRuBdQBLAAAAAA==.魅影小海鬼:BAAALAAFFAIIAgAAAA==.魅影小胖熊:BAAALAAECgMIAwAAAA==.魅影小萨满:BAABLAAFFH8GAAIMAAIIbBRUUQB4AAAMAAIIbBRUUQB4AAAAAA==.魅影小酒仙:BAAALAAECgIIAgAAAA==.',['魔了']='魔了个兽:BAAALAADCgYIBgAAAA==.',['鴆羽']='鴆羽千夜:BAABLAAFFH8YAAMLAAYIMh2nDQD4AQALAAYIMh2nDQD4AQAVAAYI3Rk/DgB8AQAAAA==.',['麻婆']='麻婆豆腐:BAABLAAFFH8GAAIOAAIIsSRLIwDFAAAOAAIIsSRLIwDFAAAAAA==.',['黑心']='黑心糖:BAAALAADCgIIAgAAAA==.',['黑暗']='黑暗天界:BAAALAAECgIIAgAAAA==.',['黯月']='黯月焚星:BAAALAAECgYIEwAAAA==.',['龍杰']='龍杰:BAACLAAFFH8LAAQKAAQIzAfYMADCAAAKAAQIzAfYMADCAAAbAAII1AR6BgB1AAANAAIIqANBKwBmAAAsAAQKfywABAoACAhWGCwkANUBABsACAhqE+cNAPcBAAoACAijFywkANUBAA0AAggaEhaOAFIAAAAA.',['龙跃']='龙跃:BAAALAAECgYICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end