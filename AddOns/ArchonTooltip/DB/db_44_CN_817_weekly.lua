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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Frost','Hunter-Marksmanship','DeathKnight-Blood','Druid-Balance','Shaman-Restoration','Evoker-Devastation','Warrior-Fury','Druid-Restoration','Paladin-Retribution','Priest-Holy','Priest-Discipline','Shaman-Elemental','Monk-Brewmaster','Warrior-Protection','Druid-Feral','Evoker-Preservation','Evoker-Augmentation','Mage-Arcane','DemonHunter-Havoc','Unknown-Unknown','Monk-Mistweaver','Monk-Windwalker','Paladin-Holy','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','Mage-Frost','DeathKnight-Unholy','DemonHunter-Vengeance','Warrior-Arms',}; local provider = {region='CN',realm='萨格拉斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adona:BAABLAAECn8WAAIBAAYIsB2RYQCAAQABAAYIsB2RYQCAAQAAAA==.',Al='Alanluu:BAAALAADCgQIBAAAAA==.',Am='Amaster:BAAALAADCgUIBQAAAA==.Amo:BAABLAAECn8UAAICAAcInxvBZQAqAgACAAcInxvBZQAqAgAAAA==.',Au='Autism:BAAALAAFFAIIBAAAAA==.',Br='Breeze:BAABLAAFFH8GAAIDAAYIDhhYBADwAQADAAYIDhhYBADwAQAAAA==.',Bw='Bwonsamdi:BAACLAAFFH8aAAIEAAYIoQyADgAeAQAEAAYIoQyADgAeAQAsAAQKfx4AAgQACAjZEVYiAHMBAAQACAjZEVYiAHMBAAAA.',Ca='Calldeath:BAAALAAFFAIIAgAAAA==.Candle:BAAALAAFFAMIAwAAAA==.Cantarella:BAABLAAFFH8FAAIFAAMIQAcLKgBmAAAFAAMIQAcLKgBmAAAAAA==.',Cj='Cjy:BAAALAAECggICAAAAA==.',Cu='Cute:BAABLAAFFH8IAAIBAAIIWBA9oAA+AAABAAIIWBA9oAA+AAABLAAFFAMIGwAGAGASAA==.',Da='Darkkill:BAAALAAECgYIBgAAAA==.',Fe='Fenlix:BAAALAAECgYIBgAAAA==.',Fi='Fin:BAACLAAFFH8fAAIHAAYIjRYBCwBxAQAHAAYIjRYBCwBxAQAsAAQKfyUAAgcACAhNIVwPAL8CAAcACAhNIVwPAL8CAAAA.',Ga='Gannicus:BAAALAADCgIIAgAAAA==.',Go='Goat:BAABLAAFFH8IAAIIAAgIBwGpZAAjAAAIAAgIBwGpZAAjAAAAAA==.',Gy='Gypsy:BAAALAADCgYICwAAAA==.',Ha='Hardtosay:BAAALAAFFAIIBAAAAA==.Haunted:BAABLAAFFH8FAAIJAAMI5xZHKgDJAAAJAAMI5xZHKgDJAAAAAA==.',He='Hellward:BAAALAAECgEIAQAAAA==.',Ku='Kukalon:BAAALAAFFAIIAwAAAA==.',Li='Link:BAAALAAFFAIIBAAAAA==.',Lo='Lostsoul:BAAALAAECgYIBQAAAA==.',Ma='Majesty:BAABLAAFFH8GAAIKAAYI1QsSJQBMAQAKAAYI1QsSJQBMAQAAAA==.Malxkp:BAAALAAECgMIAwAAAA==.Malxkx:BAAALAADCgYIBgAAAA==.Marsaka:BAABLAAFFH8FAAIKAAUIhRV3KgAuAQAKAAUIhRV3KgAuAQAAAA==.',Na='Nancy:BAAALAADCgcIBwAAAA==.Natsuki:BAAALAADCgUIDAAAAA==.',No='Nox:BAAALAAECgQIBAAAAA==.Noxnnox:BAACLAAFFH8dAAILAAUIKB2XFACyAQALAAUIKB2XFACyAQAsAAQKfyoAAwsACAivIe4MAAADAAsACAivIe4MAAADAAwAAQj4A1NHABkAAAAA.',Pa='Patrick:BAAALAAFFAMIAwAAAA==.',Re='Reilay:BAAALAADCgUIBQAAAA==.',Ri='Riddle:BAACLAAFFH8YAAMGAAUI2RmBGwDcAAAGAAUI2RmBGwDcAAANAAIIAwGtVgAMAAAsAAQKfyEAAgYACAgBILkpAGsCAAYACAgBILkpAGsCAAAA.',Sh='Shanna:BAAALAAFFAYIAwAAAA==.',Si='Sigmund:BAAALAAECggIAQAAAA==.',Sp='Speechlessne:BAAALAAECgYICwAAAA==.',St='Stomp:BAAALAADCgcIBwAAAA==.',Sw='Sweetdeath:BAAALAAECggIEAAAAA==.',Wa='Waremperor:BAAALAAECgYICgAAAA==.',Wi='Windranger:BAAALAAECgYIBwAAAA==.',Yu='Yuukide:BAAALAAFFAIIAgAAAA==.',['Æç']='Æçåæç:BAAALAADCgEIAQAAAA==.',['一千']='一千念:BAAALAAECgIIAgAAAA==.',['一只']='一只小青龙:BAAALAAFFAYIAwAAAA==.一只母牛二:BAAALAAECgUIBQAAAA==.',['一生']='一生有爱:BAAALAAECgYIEgAAAA==.',['一锤']='一锤三千:BAAALAADCgYIBgAAAA==.',['七殺']='七殺:BAAALAAECggICAAAAA==.',['七石']='七石头:BAABLAAFFH8GAAIBAAYITx8jHwC3AQABAAYITx8jHwC3AQAAAA==.',['万妖']='万妖骑:BAABLAAFFH8IAAICAAII7wgCggCGAAACAAII7wgCggCGAAAAAA==.',['三万']='三万敌法秒躺:BAAALAAFFAIIAgAAAA==.',['三十']='三十二螺纹钢:BAAALAAECgQIBAAAAA==.',['上官']='上官兰若:BAAALAAECgYIBgAAAA==.',['世外']='世外高人:BAAALAADCgYIBgAAAA==.',['丨怡']='丨怡葉之秋丨:BAAALAAFFAIIAgAAAA==.',['丶李']='丶李冰冰:BAABLAAFFH8GAAIOAAIIJAMLHgBIAAAOAAIIJAMLHgBIAAAAAA==.',['丷黑']='丷黑黑:BAABLAAECn8aAAIPAAcIECCNFACPAgAPAAcIECCNFACPAgAAAA==.',['九五']='九五二丶七:BAAALAAECgYIDwAAAA==.',['二把']='二把刀:BAAALAAFFAIIAgAAAA==.',['二条']='二条稻穗:BAAALAAECgMIBQAAAA==.',['二趾']='二趾残:BAABLAAFFH8GAAIIAAIIghYTRgBNAAAIAAIIghYTRgBNAAAAAA==.',['云舟']='云舟丶:BAAALAADCgcIBwAAAA==.',['五条']='五条悟:BAAALAADCgIIAgAAAA==.',['人无']='人无再少年:BAAALAAECgEIAQAAAA==.',['今夕']='今夕似何年:BAAALAAFFAIIBAAAAA==.',['今晚']='今晚打老狐:BAAALAAECgYIEAAAAA==.',['从何']='从何说起:BAABLAAFFH8bAAIQAAYIziKiAQACAgAQAAYIziKiAQACAgAAAA==.',['仰望']='仰望半夜星空:BAAALAAECgMIAwABLAAFFAgIBwAIAEIWAA==.',['任你']='任你打点话:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利尔丹:BAAALAAECggIEgAAAA==.',['你二']='你二姨:BAAALAAECgUIBQAAAA==.',['信仰']='信仰萨:BAAALAAECggICAAAAA==.',['健忘']='健忘的圣光:BAAALAAECgEIAQAAAA==.',['偷心']='偷心小猫:BAAALAAFFAIIAgABLAAFFAMIGwAGAGASAA==.',['傻丶']='傻丶傻曼:BAAALAAFFAIIAgAAAA==.',['光影']='光影之歌:BAAALAAECgQIBAAAAA==.',['八云']='八云:BAABLAAFFH8SAAQRAAUI2gj6EQABAQARAAUI2gj6EQABAQAHAAIIxBGHFgCRAAASAAIIKBV/EAA6AAAAAA==.',['兽四']='兽四两:BAAALAAECgYIDQAAAA==.',['兽族']='兽族小法:BAAALAAECgUIBQAAAA==.',['冰美']='冰美式多加糖:BAAALAAECgYIBAAAAA==.',['冰阔']='冰阔落:BAAALAAECgYIBgAAAA==.',['凌岩']='凌岩:BAAALAAECgYIDgAAAA==.',['凛风']='凛风冲击:BAAALAAFFAIIAgAAAA==.',['凯东']='凯东:BAAALAAFFAIIAgAAAA==.',['凯撒']='凯撒君:BAABLAAFFH8KAAITAAUIBBh2MwAyAQATAAUIBBh2MwAyAQAAAA==.',['凯棟']='凯棟:BAAALAAECgMIAwAAAA==.',['凯特']='凯特莉娜:BAACLAAFFH8aAAIKAAYI7BmAGQCMAQAKAAYI7BmAGQCMAQAsAAQKfx8AAgoACAioHy44AJMCAAoACAioHy44AJMCAAAA.',['凯萨']='凯萨:BAAALAAECgYIDAAAAA==.',['凯飒']='凯飒:BAAALAAECgUIBwAAAA==.',['凱恩']='凱恩的復仇:BAAALAAECggIAgAAAA==.',['凹凸']='凹凸魔:BAAALAAECgcIEwAAAA==.',['刀剑']='刀剑剑非道:BAAALAAFFAIIAgAAAA==.',['刀锋']='刀锋之影:BAACLAAFFH8FAAIUAAIIDxdmUgBIAAAUAAIIDxdmUgBIAAAsAAQKfxgAAhQABggoIS4mAMUBABQABggoIS4mAMUBAAAA.',['刚刃']='刚刃研磨:BAAALAAECgYIBgABLAAECggICAAVAAAAAA==.',['前面']='前面有光:BAAALAAECgQIBAAAAA==.',['动次']='动次打次:BAAALAAFFAIIBAAAAA==.',['勒米']='勒米:BAAALAAECgUIBQAAAA==.',['北宫']='北宫毛妞儿:BAAALAAECgYIBgAAAA==.北宫毛妹:BAAALAAECgQICAAAAA==.北宫毛球:BAABLAAFFH8dAAIIAAcINAlHHwBxAQAIAAcINAlHHwBxAQAAAA==.',['北極']='北極星的夜:BAABLAAFFH8UAAMWAAYIOSD4BAAMAgAWAAYIOSD4BAAMAgAXAAEIOw41FQBHAAAAAA==.',['医生']='医生乔巴:BAACLAAFFH8eAAIGAAYIExP6HQBtAQAGAAYIExP6HQBtAQAsAAQKfxwAAgYACAg6GlM2AD0CAAYACAg6GlM2AD0CAAAA.',['十一']='十一:BAACLAAFFH8LAAMKAAYINww2IwBWAQAKAAYINww2IwBWAQAYAAMIzRN8HQC6AAAsAAQKfx4AAxgABwhYH1sMACkCABgABwhYH1sMACkCAAoAAggCBjdnAWUAAAAA.',['十字']='十字星辰:BAAALAAECgIIAgAAAA==.',['千里']='千里烟波:BAAALAADCgMIAwAAAA==.',['南过']='南过:BAAALAAECgcIBwAAAA==.',['卡玛']='卡玛扎尔:BAACLAAFFH8kAAIZAAcIYxa0EwDuAQAZAAcIYxa0EwDuAQAsAAQKfxkAAxkACAjNFuhCAC4CABkACAjNFuhCAC4CABoAAQjBBIOdADAAAAAA.',['卧龙']='卧龙凤雏:BAAALAAECgMIAwAAAA==.',['叠加']='叠加力量:BAABLAAFFH8LAAIKAAYIBBs5FwCZAQAKAAYIBBs5FwCZAQAAAA==.',['叫宝']='叫宝宝咬死你:BAAALAAECgcIDwAAAA==.',['叮叮']='叮叮铛铛:BAABLAAFFH8GAAIUAAYI1BddIQB7AQAUAAYI1BddIQB7AQABLAAFFAgIBgAUACEbAA==.',['可口']='可口可:BAAALAADCgIIAgAAAA==.',['可恶']='可恶的尐弟弟:BAAALAAECgYICgAAAA==.',['可爱']='可爱囡囡:BAAALAAECgYICwAAAA==.可爱多:BAABLAAFFH8KAAMLAAYIOQTIKwDJAAALAAUIwAHIKwDJAAAMAAIIOgnqBgBKAAAAAA==.可爱的尐弟弟:BAAALAAECgIIAgAAAA==.',['吖唔']='吖唔呔:BAAALAAECgMIAwAAAA==.',['咒靈']='咒靈闪闪:BAAALAAECgYIBgAAAA==.',['咸鱼']='咸鱼不想翻身:BAABLAAFFH8RAAIGAAII2xoRQACBAAAGAAII2xoRQACBAAAAAA==.',['啊困']='啊困困了:BAAALAAECgUIBgAAAA==.',['圣丶']='圣丶塞勒斯汀:BAAALAAECgcIDAAAAA==.',['圣光']='圣光囡囡:BAAALAAECgYICAAAAA==.圣光征服者:BAAALAAECgYICAAAAA==.',['坏未']='坏未来:BAABLAAFFH8GAAIXAAIIgRUDDwCcAAAXAAIIgRUDDwCcAAAAAA==.',['垂直']='垂直面:BAACLAAFFH8pAAICAAYIGRppJACkAQACAAYIGRppJACkAQAsAAQKfzIAAgIACAgpIPgqAMYCAAIACAgpIPgqAMYCAAAA.',['基内']='基内维亚:BAABLAAFFH8MAAMLAAYIlw+hEgAcAQALAAYIlw+hEgAcAQAbAAII1AybGwCbAAAAAA==.',['堕落']='堕落抉择:BAABLAAFFH8GAAIcAAYItQPDCgDtAAAcAAYItQPDCgDtAAAAAA==.',['塞勒']='塞勒涅丨晨星:BAABLAAFFH8QAAIBAAUIaRsXTQAaAQABAAUIaRsXTQAaAQAAAA==.',['墮落']='墮落断羽:BAAALAAECgUIBQAAAA==.',['壹萌']='壹萌叁肆年:BAAALAAECgYIBgAAAA==.',['多彩']='多彩龙人:BAAALAAECgYIEAAAAA==.',['夜空']='夜空下的牛:BAAALAAFFAgIAgAAAA==.',['夜静']='夜静春山空:BAAALAADCgQIBAAAAA==.',['大姜']='大姜鸭:BAABLAAFFH8FAAIBAAIIWBrbkABFAAABAAIIWBrbkABFAAAAAA==.',['大宗']='大宗師:BAABLAAFFH8PAAIWAAIInxdPEgCWAAAWAAIInxdPEgCWAAAAAA==.',['天上']='天上天下无双:BAACLAAFFH8GAAIKAAIIIRunOwChAAAKAAIIIRunOwChAAAsAAQKfxUAAgoABghwJC5GAGoCAAoABghwJC5GAGoCAAAA.',['天天']='天天流浪汉:BAAALAAFFAYIBAAAAA==.',['天煞']='天煞孤风:BAACLAAFFH8IAAIdAAIISRXXGQCYAAAdAAIISRXXGQCYAAAsAAQKfxkAAx0ABggKHNomAOYBAB0ABggKHNomAOYBABwAAQgmDOpQAC8AAAAA.',['天祈']='天祈:BAAALAADCgMIAwAAAA==.',['太湖']='太湖银鱼:BAAALAAECgYIBgAAAA==.',['套龙']='套龙的汉子:BAACLAAFFH8GAAITAAIIghetQQCeAAATAAIIghetQQCeAAAsAAQKfxsAAx4ACAgWH6UaAEYCAB4ACAgWH6UaAEYCABMABgjTHPdnAM8BAAAA.',['奧蕾']='奧蕾莉亚:BAAALAADCgEIAQAAAA==.',['奶很']='奶很大力:BAAALAAECgYIDQAAAA==.',['如风']='如风随影:BAAALAADCgYIBgAAAA==.',['妖风']='妖风瑟瑟:BAAALAAECgYIDAAAAA==.',['子夜']='子夜:BAAALAAECgUIBQAAAA==.',['孤独']='孤独扛娃娃:BAAALAAECgQIBAAAAA==.',['安之']='安之婼素:BAAALAADCgUIBQAAAA==.',['安室']='安室透:BAAALAAECgQIBAAAAA==.',['安德']='安德莉亚:BAABLAAFFH8GAAIGAAIIqhZWPgCEAAAGAAIIqhZWPgCEAAAAAA==.',['宛若']='宛若星辰:BAAALAAECgMIAwAAAA==.',['宫廷']='宫廷玉液酒:BAAALAAECgMIAwAAAA==.',['小小']='小小列夫:BAAALAAECgYICgAAAA==.小小妲己:BAAALAAECgQIBAAAAA==.小小波:BAABLAAFFH8LAAMDAAYIUBxfAwAMAgADAAYILxxfAwAMAgABAAMIvhsPaACXAAAAAA==.',['小愤']='小愤青:BAAALAADCgIIAgAAAA==.',['小拳']='小拳拳开锤:BAAALAAFFAIIAgAAAA==.',['小波']='小波:BAABLAAFFH8GAAIKAAYIlBWEBQAPAgAKAAYIlBWEBQAPAgAAAA==.小波小:BAABLAAFFH8IAAICAAgI+wrGTgDrAAACAAgI+wrGTgDrAAAAAA==.',['小白']='小白羊先生:BAAALAAECgYIBgAAAA==.',['小花']='小花丶:BAABLAAFFH8GAAIBAAUIhxLATAAbAQABAAUIhxLATAAbAQAAAA==.',['小钻']='小钻风:BAAALAAECgYICAAAAA==.',['山顶']='山顶巅峰:BAABLAAFFH8PAAIJAAYImBXZEQCyAQAJAAYImBXZEQCyAQAAAA==.',['山龙']='山龙隐秀:BAAALAAECgYIBgAAAA==.',['巍峨']='巍峨的尐弟弟:BAAALAAECgUICQAAAA==.',['左狼']='左狼右狈:BAACLAAFFH8VAAILAAYIeiRqCgAjAgALAAYIeiRqCgAjAgAsAAQKfyUAAgsACAh3I4EJAB0DAAsACAh3I4EJAB0DAAAA.',['布劳']='布劳缪克丝:BAABLAAFFH8XAAICAAYItxSaKACVAQACAAYItxSaKACVAQABLAAFFAgIAQAVAAAAAA==.',['布莱']='布莱恩丶铁须:BAACLAAFFH8lAAICAAUIAx+KEADPAQACAAUIAx+KEADPAQAsAAQKfxYAAgIABgggJVQ4AJcCAAIABgggJVQ4AJcCAAAA.',['帅德']='帅德基:BAAALAAFFAIIAgAAAA==.',['希望']='希望祷言:BAACLAAFFH8XAAILAAMI1x+LJAAaAQALAAMI1x+LJAAaAQAsAAQKfyEAAgsACAicIcAMAIICAAsACAicIcAMAIICAAAA.',['弍利']='弍利丹:BAAALAADCgMIAwAAAA==.',['德摩']='德摩希亚:BAAALAADCggICAAAAA==.',['心神']='心神凝聚:BAAALAAECgYIDgAAAA==.',['忘了']='忘了初心:BAAALAAECgYIBgAAAA==.',['忧落']='忧落丶:BAAALAAECgQIBAAAAA==.',['快过']='快过闪电:BAAALAAECgYICwAAAA==.',['怒风']='怒风艾斯:BAAALAAFFAIIAgAAAA==.',['恐怖']='恐怖的尐弟弟:BAAALAAECgYICwAAAA==.',['恐惧']='恐惧降临灬灬:BAABLAAECn8YAAIUAAYIVBxnKgCxAQAUAAYIVBxnKgCxAQAAAA==.',['恒通']='恒通驾校好汤:BAAALAAECgYIBwAAAA==.',['恶之']='恶之邪靈:BAAALAADCgEIAQAAAA==.',['恶魔']='恶魔猎兽:BAAALAADCgIIAgAAAA==.',['情剑']='情剑山河:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的罗西:BAAALAADCgYIBgAAAA==.',['憨厚']='憨厚的眼神:BAABLAAECn8cAAICAAYI0hyihwDtAQACAAYI0hyihwDtAQAAAA==.',['我又']='我又岂能不笑:BAAALAAFFAIIAgAAAA==.',['我反']='我反对:BAABLAAECn8UAAIWAAgIMhyHBgB0AgAWAAgIMhyHBgB0AgAAAA==.',['战豆']='战豆豆:BAAALAAFFAIIAgAAAA==.',['戴斯']='戴斯班克:BAABLAAECn8aAAICAAYITB0TNQClAQACAAYITB0TNQClAQAAAA==.',['把泥']='把泥闷豆沙了:BAAALAADCggICAAAAA==.',['拉布']='拉布布:BAAALAAECgUIBQAAAA==.',['拉斯']='拉斯塔哈大王:BAAALAAECgEIAQAAAA==.',['拉科']='拉科西丝:BAABLAAFFH8GAAIYAAYI0xbdDQCoAQAYAAYI0xbdDQCoAQAAAA==.',['拖布']='拖布它妈妈:BAACLAAFFH8PAAIBAAQI/hZjXQDRAAABAAQI/hZjXQDRAAAsAAQKfxUAAwEABggbIb1BAMgBAAEABggbIb1BAMgBAAMABQgDE81rABgBAAAA.拖布它爸:BAAALAAECgMIAwAAAA==.',['掐烟']='掐烟灭孤独:BAABLAAFFH8JAAIBAAMIpw3UcwB6AAABAAMIpw3UcwB6AAAAAA==.',['搓药']='搓药咕:BAABLAAECn8fAAIFAAgImRaHLgAIAgAFAAgImRaHLgAIAgAAAA==.',['放生']='放生:BAAALAADCgUIBQAAAA==.',['斩机']='斩机圆武:BAAALAAECgYICgAAAA==.',['新生']='新生:BAAALAAECgEIAQAAAA==.',['无人']='无人在意:BAAALAADCggICAAAAA==.',['无敌']='无敌宗师猎:BAAALAAECgEIAQAAAA==.',['无用']='无用萨萨:BAAALAAECgIIAgAAAA==.',['星星']='星星的猛兽:BAAALAAFFAEIAQAAAA==.',['是也']='是也非耶:BAABLAAFFH8eAAILAAYIwQkHHgBeAQALAAYIwQkHHgBeAQABLAAFFAgIEAAYAPsYAA==.',['是耶']='是耶非也:BAABLAAFFH8TAAICAAYI6AwTRQAnAQACAAYI6AwTRQAnAQAAAA==.',['是谁']='是谁言多必失:BAABLAAFFH8bAAICAAcIwBt9EADQAQACAAcIwBt9EADQAQAAAA==.是谁身不由己:BAABLAAFFH8JAAIBAAMI6xyGIAAFAQABAAMI6xyGIAAFAQAAAA==.是谁青春无悔:BAAALAAECgYICQAAAA==.',['時廿']='時廿以後:BAACLAAFFH8mAAMIAAYICRy2EQBXAQAIAAYICRy2EQBXAQAPAAIIZwtaJwBvAAAsAAQKfyMAAwgACAhEHo8pAJcCAAgACAhEHo8pAJcCAA8AAgiDE9qFAG4AAAAA.',['晓寒']='晓寒意浓:BAAALAAECgYICgAAAA==.',['暗夜']='暗夜闪闪:BAAALAAECgYIDAAAAA==.',['暗恋']='暗恋桃花源:BAABLAAFFH8LAAIKAAUIEhw+HgDbAAAKAAUIEhw+HgDbAAAAAA==.',['暮色']='暮色迷离:BAAALAAFFAIIAQAAAA==.',['暴怒']='暴怒丨霜凌:BAAALAAECgYIBgAAAA==.',['暴风']='暴风猎手:BAAALAADCgUIBQAAAA==.',['月明']='月明多被云妨:BAAALAAECgYICAAAAA==.',['朔阳']='朔阳:BAAALAAFFAIIAgAAAA==.',['未来']='未来的伊卡璐:BAAALAAFFAIIBAAAAA==.',['末路']='末路启昊:BAAALAAECgYICAAAAA==.',['杜嶐']='杜嶐坦:BAAALAAECgYIDQAAAA==.',['杰尼']='杰尼龟:BAAALAADCgMIAwAAAA==.',['极品']='极品蛋蛋:BAAALAAECgUIBQAAAA==.',['林二']='林二八:BAABLAAFFH8GAAIYAAII2gugKABqAAAYAAII2gugKABqAAAAAA==.',['林落']='林落葵:BAACLAAFFH8fAAMLAAYIahZZFQCqAQALAAYIahZZFQCqAQAbAAIIQhWIJQBPAAAsAAQKfyAAAgsACAjlFmwyABUCAAsACAjlFmwyABUCAAAA.',['柚子']='柚子丶蜂蜜:BAAALAADCgYIBgAAAA==.',['梅克']='梅克勒伍:BAAALAAECgQIBAAAAA==.',['樱子']='樱子:BAAALAAECggIDQAAAA==.',['橙色']='橙色葡萄酱:BAAALAAECggIEgABLAAFFAgIAgAVAAAAAA==.',['櫻子']='櫻子:BAAALAAECgMIAwAAAA==.',['欢乐']='欢乐送:BAAALAAECgEIAgAAAA==.',['欧皇']='欧皇西瓜猪:BAAALAADCgYIBgAAAA==.',['武玄']='武玄霜:BAABLAAFFH8PAAIKAAMI7ho8HgDbAAAKAAMI7ho8HgDbAAAAAA==.',['死亡']='死亡的审判者:BAAALAADCgEIAQAAAA==.',['比爾']='比爾丶史塔克:BAAALAAFFAIIAgAAAA==.',['毛豆']='毛豆:BAAALAAECgMIAwAAAA==.',['沉默']='沉默的保护:BAABLAAFFH8HAAIYAAMIsARYIwCIAAAYAAMIsARYIwCIAAAAAA==.沉默的死握:BAACLAAFFH8PAAMCAAYIIR13QQA2AQACAAUIXiJ3QQA2AQAEAAEI7QIvHAAxAAAsAAQKfxcAAgIACAiSJeAJAFIDAAIACAiSJeAJAFIDAAAA.',['油炸']='油炸只因米花:BAAALAAECgQIBQAAAA==.',['法号']='法号丶倒满:BAABLAAFFH8LAAICAAMIoBcbWwCaAAACAAMIoBcbWwCaAAAAAA==.',['法尔']='法尔肯:BAABLAAFFH8dAAMZAAgI+hf8FQDbAQAZAAgI+hf8FQDbAQAaAAIInwTQHQB9AAAAAA==.',['波士']='波士顿龙虾:BAABLAAFFH8HAAIbAAIIfAejJgB3AAAbAAIIfAejJgB3AAAAAA==.',['泰莉']='泰莉亚:BAAALAAECgYIBgAAAA==.',['洛丹']='洛丹伦的回忆:BAAALAADCgYIAgAAAA==.',['流传']='流传枫:BAAALAAFFAIIAwAAAA==.',['流苏']='流苏晚晴:BAAALAAECgYICgAAAA==.',['浅若']='浅若夏沫:BAAALAAECgIIAgAAAA==.',['淹死']='淹死的虎纹鲨:BAABLAAFFH8GAAIBAAYIQBTXQgA/AQABAAYIQBTXQgA/AQAAAA==.',['渔火']='渔火丶:BAAALAAECgIIAgAAAA==.',['渺渺']='渺渺更健康:BAAALAAECgYICAAAAA==.',['漆黑']='漆黑的王狼:BAABLAAFFH8FAAICAAMItQlvaAB3AAACAAMItQlvaAB3AAAAAA==.',['漪漪']='漪漪:BAAALAAECgYIBgAAAA==.',['火凛']='火凛冰实:BAAALAAECgUIBQAAAA==.',['灬浅']='灬浅醉灬:BAAALAAFFAIIAgAAAA==.',['炽热']='炽热丶:BAABLAAFFH8LAAIKAAUIIBpZIwBVAQAKAAUIIBpZIwBVAQAAAA==.',['烟花']='烟花归来:BAAALAADCgMIAwAAAA==.',['烤糊']='烤糊的羊:BAABLAAECn8WAAICAAYISB9faAAlAgACAAYISB9faAAlAgAAAA==.',['無心']='無心:BAABLAAFFH8HAAMaAAYI3AWpFgA+AAAaAAIImgKpFgA+AAAZAAQIfAegbQAyAAAAAA==.',['燃烧']='燃烧的奶爸:BAAALAAECgYIDAAAAA==.',['爱丽']='爱丽丝丶迷雾:BAAALAAECgYIBgAAAA==.爱丽速子:BAAALAAECgQIBgAAAA==.',['牛啃']='牛啃菠萝:BAAALAAFFAIIAwAAAA==.',['牛肉']='牛肉面之怒:BAAALAAECgYIDwAAAA==.',['狂暴']='狂暴亚马逊:BAABLAAFFH8OAAIBAAYIIgeDUAAOAQABAAYIIgeDUAAOAQAAAA==.',['狂野']='狂野的尐弟弟:BAAALAAECgYICgAAAA==.',['狐妖']='狐妖鸡:BAAALAAECgYICQAAAA==.',['独倚']='独倚丨烟花笑:BAAALAAECgYIEAAAAA==.',['猫扑']='猫扑:BAABLAAFFH8GAAMFAAYIbRKNCQCYAQAFAAUI8RONCQCYAQAJAAEIngzQTABFAAAAAA==.',['猫猫']='猫猫熊无敌:BAAALAAECgUIBQAAAA==.猫猫萨满:BAACLAAFFH8bAAIGAAMIYBJzPQCvAAAGAAMIYBJzPQCvAAAsAAQKfzkAAgYACAjOHAc3ADsCAAYACAjOHAc3ADsCAAAA.',['玄罡']='玄罡:BAAALAAECgEIAQAAAA==.',['珀罗']='珀罗普斯:BAABLAAFFH8HAAIUAAIIjBp+NACjAAAUAAIIjBp+NACjAAAAAA==.',['琅嬛']='琅嬛:BAAALAAECggIDgAAAA==.',['琼恩']='琼恩丶雪诺:BAAALAAFFAIIAgAAAA==.',['瓦莱']='瓦莱里娅:BAAALAADCgEIAQAAAA==.',['生打']='生打椰椰灬:BAAALAAECgYICwAAAA==.',['电神']='电神杨永信:BAABLAAFFH8IAAIGAAUIUgVZOgC6AAAGAAUIUgVZOgC6AAAAAA==.',['疯狂']='疯狂的制帽匠:BAAALAAECgQIBAAAAA==.',['白斯']='白斯月:BAAALAAECggIEQAAAA==.',['皓形']='皓形使者:BAAALAADCggICAAAAA==.',['皮皮']='皮皮虾快点走:BAAALAAECgcIBwAAAA==.',['真丶']='真丶润发官人:BAAALAADCgIIAgAAAA==.真丶百事可乐:BAAALAADCgEIAQAAAA==.',['眼神']='眼神充满智慧:BAAALAAECgIIAgAAAA==.',['睡不']='睡不着:BAAALAAECgMIAwAAAA==.',['睡着']='睡着了:BAAALAAECgIIAgAAAA==.',['破日']='破日逐龙:BAAALAAFFAIIAgAAAA==.',['神佛']='神佛不佑:BAAALAAECgUIBQAAAA==.',['神秘']='神秘小登:BAABLAAFFH8IAAIJAAIIpRE3MgBwAAAJAAIIpRE3MgBwAAAAAA==.',['秃驴']='秃驴:BAAALAAECgIIBAAAAA==.',['秋叶']='秋叶海棠:BAAALAAECgIIAgAAAA==.',['稀客']='稀客:BAABLAAECn8XAAMGAAcIHhmyIwDlAQAGAAcIHhmyIwDlAQANAAMI3xDkagBoAAAAAA==.',['篆愁']='篆愁君:BAAALAAECgEIAQAAAA==.',['红霸']='红霸:BAAALAAECgYICQAAAA==.',['缘分']='缘分:BAABLAAFFH8RAAIBAAUIbwmmWgDfAAABAAUIbwmmWgDfAAAAAA==.',['罗兰']='罗兰之歌:BAAALAAECgIIAgAAAA==.',['羅羅']='羅羅亞索隆:BAABLAAECn8VAAIIAAgI3RzZEgBPAgAIAAgI3RzZEgBPAgAAAA==.',['羞花']='羞花闭曰:BAAALAAECgYIBwAAAA==.',['老爷']='老爷爷修家电:BAAALAAECgcIEQAAAA==.',['老衲']='老衲说:BAAALAAECgUIBQAAAA==.',['老铁']='老铁奶萨:BAAALAAFFAIIBAAAAA==.',['耐奧']='耐奧祖:BAAALAAFFAIIAgAAAA==.',['自在']='自在仙:BAAALAAECgMIAwAAAA==.',['至尊']='至尊无敌:BAAALAADCggIEAAAAA==.至尊无敌大佬:BAAALAADCgUICQAAAA==.至尊无敌大咪:BAAALAADCgEIAQAAAA==.至尊无敌大哥:BAAALAADCgUIBQAAAA==.至尊无敌瑶:BAAALAADCgMIBQAAAA==.至尊无敌瑶瑶:BAAALAADCgIIAgAAAA==.至尊无敌老大:BAAALAADCgIIAwAAAA==.至尊无敌英雄:BAAALAADCgUIBgAAAA==.至尊无敌财神:BAAALAADCgUIBgAAAA==.至尊猛哥:BAAALAADCgIIAwAAAA==.至尊皇上:BAAALAADCgYIBwAAAA==.',['舞舞']='舞舞花:BAAALAAFFAQIBAAAAA==.',['艾斯']='艾斯德斯:BAAALAAFFAIIBAAAAA==.',['艾格']='艾格雯:BAAALAAECgYICAAAAA==.',['花舞']='花舞舞:BAACLAAFFH8eAAMBAAYIVyM7GADYAQABAAYIVyM7GADYAQADAAEIFA9xNgA8AAAsAAQKfyEAAwEACAhkJfUsAKQCAAEACAgFJfUsAKQCAAMABAhhIAxWAGABAAAA.',['芹菜']='芹菜根:BAAALAAECgIIAgAAAA==.',['苍崎']='苍崎青子:BAABLAAFFH8GAAMPAAIINgmwKQBqAAAIAAIIFgebRgCDAAAPAAII+wewKQBqAAAAAA==.',['苏独']='苏独龙龙:BAACLAAFFH8QAAICAAQIwg+lUgDOAAACAAQIwg+lUgDOAAAsAAQKfx0AAwIACAiqFyQgAPsBAAIACAiqFyQgAPsBAB8ABghOCYUzADIBAAAA.',['范小']='范小心:BAAALAAECggICAAAAA==.',['荆棘']='荆棘花:BAABLAAFFH8FAAIBAAIIgQZ2vAAtAAABAAIIgQZ2vAAtAAAAAA==.',['荷里']='荷里活:BAAALAAECgYIEwAAAA==.',['莉莉']='莉莉丝丶:BAAALAADCgIIAgAAAA==.',['莫多']='莫多想:BAABLAAECn8ZAAIBAAYIPBldcgBgAQABAAYIPBldcgBgAQAAAA==.',['葵花']='葵花:BAAALAAECgYIBgAAAA==.',['蒙奇']='蒙奇猎:BAABLAAFFH8NAAIBAAUIJBZ2SwAgAQABAAUIJBZ2SwAgAQAAAA==.',['蔑绝']='蔑绝:BAAALAAFFAIIBAAAAA==.',['蕰蕾']='蕰蕾萨:BAABLAAECn8WAAIBAAYIOBgqdwBXAQABAAYIOBgqdwBXAQAAAA==.',['蕾娜']='蕾娜天弓:BAAALAAECgQIBAAAAA==.',['薛定']='薛定谔的猫:BAAALAAECgYIBgAAAA==.',['蟹蟹']='蟹蟹灬:BAABLAAFFH8GAAIGAAII0gi6XABiAAAGAAII0gi6XABiAAAAAA==.',['西园']='西园曲水:BAABLAAFFH8GAAIGAAYIEBU6HQB0AQAGAAYIEBU6HQB0AQAAAA==.',['西西']='西西里沙滩:BAAALAAECggICQAAAA==.',['诺亚']='诺亚之子:BAABLAAFFH8LAAIYAAII6g8YJwBwAAAYAAII6g8YJwBwAAAAAA==.诺亚风语者:BAACLAAFFH8fAAIPAAYIvgmTFQAOAQAPAAYIvgmTFQAOAQAsAAQKfyQAAg8ACAgUFL1AAIABAA8ACAgUFL1AAIABAAEsAAUUCAgeAAIAqxwA.',['谈情']='谈情跳舞:BAAALAADCgEIAQAAAA==.',['谜之']='谜之晨曦:BAAALAADCgMIAwAAAA==.',['贝拉']='贝拉特里克斯:BAAALAADCgYIBgAAAA==.',['贱剑']='贱剑:BAAALAAFFAIIBAAAAA==.',['资本']='资本论:BAAALAAFFAIIAgAAAA==.',['赫利']='赫利斯:BAACLAAFFH8fAAITAAYI+RQFIwCKAQATAAYI+RQFIwCKAQAsAAQKfyQAAxMACAgJGaFVAAMCABMACAgJGaFVAAMCAB4AAQhEEmCRADkAAAAA.',['超燃']='超燃真红毛熊:BAABLAAFFH8eAAMXAAUIDRIeCwAnAQAXAAUIDRIeCwAnAQAWAAMIzgKEGQBTAAAAAA==.',['轻音']='轻音之弦:BAAALAAFFAIIAwAAAA==.',['远山']='远山的呼唤:BAABLAAFFH8GAAIIAAMIRBPpGQD4AAAIAAMIRBPpGQD4AAAAAA==.',['迷人']='迷人的反派:BAACLAAFFH89AAIUAAcI2RlBDQD8AQAUAAcI2RlBDQD8AQAsAAQKf0UAAxQACAhaIJIeAOkCABQACAhaIJIeAOkCACAABQgbFfMzACYBAAAA.',['迷你']='迷你小老头:BAAALAAECgIIAgAAAA==.',['迷死']='迷死个人啦:BAABLAAFFH8IAAMaAAMIEgOmEgBHAAAZAAIIjwN3WABcAAAaAAMIEgOmEgBHAAAAAA==.',['逐风']='逐风者:BAAALAADCgIIAgAAAA==.',['那咋']='那咋整啊:BAABLAAECn8UAAMCAAgIpxkdYgAyAgACAAgIIxkdYgAyAgAfAAIIphPPSwCKAAABLAAFFAYICAATAIMRAA==.',['都拉']='都拉了一波融:BAAALAAECgYIBgAAAA==.',['酸酸']='酸酸甜柠檬:BAAALAADCgIIAgAAAA==.',['镇河']='镇河铁牛:BAABLAAECn8bAAIKAAcIuxojMADSAQAKAAcIuxojMADSAQAAAA==.',['长安']='长安:BAABLAAFFH8FAAIUAAIIrRogMQCoAAAUAAIIrRogMQCoAAAAAA==.',['闪电']='闪电狂人:BAAALAAECgYICwAAAA==.',['问问']='问问魔法海螺:BAAALAADCgUIBQAAAA==.',['阡陌']='阡陌客:BAABLAAFFH8MAAIOAAYIWR2ODAB9AQAOAAYIWR2ODAB9AQAAAA==.',['阴川']='阴川蝴蝶君:BAAALAAECgYIBgAAAA==.',['阿塔']='阿塔兰忒:BAAALAADCgYIBgAAAA==.',['阿宇']='阿宇丶死骑:BAAALAAFFAIIAgAAAA==.',['阿斯']='阿斯忒里亚:BAAALAAFFAIIAgAAAA==.',['阿辰']='阿辰:BAAALAAECgIIAgAAAA==.',['阿铁']='阿铁:BAAALAAECgYIEAAAAA==.',['陌上']='陌上吟归雪:BAABLAAFFH8TAAICAAUIMBGwSQARAQACAAUIMBGwSQARAQAAAA==.',['随风']='随风的萨满:BAAALAAFFAMIAwAAAA==.随风葬魂:BAAALAAECgYICQAAAA==.',['雷霆']='雷霆之心:BAAALAAECgQIBAAAAA==.',['霉新']='霉新星:BAAALAAFFAIIAgAAAA==.',['霓红']='霓红:BAACLAAFFH8SAAIYAAUIJgfEGAABAQAYAAUIJgfEGAABAQAsAAQKfxUAAxgACAinCzI4AIQBABgACAinCzI4AIQBAAoABghjEnzMAHYBAAAA.',['青年']='青年才俊:BAAALAAECgIIAwAAAA==.',['青霞']='青霞楚红曼玉:BAABLAAFFH8GAAIUAAYIGg6BDADdAQAUAAYIGg6BDADdAQAAAA==.',['青青']='青青子吟:BAAALAAECggICAAAAA==.',['青麟']='青麟丶萨:BAAALAAECgYIBgAAAA==.',['鞑靼']='鞑靼:BAABLAAECn8lAAIhAAgIVRZ6AwDvAQAhAAgIVRZ6AwDvAQAAAA==.',['风吹']='风吹雪如棉:BAABLAAFFH8GAAIaAAII2BTFDwBNAAAaAAII2BTFDwBNAAAAAA==.',['风怜']='风怜月:BAAALAAFFAIIAgAAAA==.',['飞仔']='飞仔:BAAALAAFFAIIBAAAAA==.',['飞抂']='飞抂:BAAALAAFFAIIBAAAAA==.',['香的']='香的马桶:BAAALAAECgYIEwAAAA==.',['骨头']='骨头破坏者:BAABLAAECn8aAAIBAAcIphyKMQD4AQABAAcIphyKMQD4AQAAAA==.',['鬼大']='鬼大丶:BAAALAAECgcICwAAAA==.',['鳕鱼']='鳕鱼茄子:BAAALAAECgYICgAAAA==.',['鹦鹉']='鹦鹉铃:BAAALAAECgcICwAAAA==.',['麻烦']='麻烦开个灯:BAAALAAECggICAAAAA==.',['黎洛']='黎洛安安:BAAALAAECgYICgAAAA==.',['黑夜']='黑夜玫瑰:BAAALAAECgYIEQAAAA==.',['黑崎']='黑崎一護:BAAALAAECgYIBgAAAA==.',['黑店']='黑店小二:BAABLAAECn8XAAIGAAgIbBJSaQCyAQAGAAgIbBJSaQCyAQAAAA==.',['黑色']='黑色梦中:BAABLAAFFH8GAAICAAYICgKqWACjAAACAAYICgKqWACjAAAAAA==.',['齐刘']='齐刘海灬:BAACLAAFFH8OAAMGAAYIdAr8JwAlAQAGAAYIdAr8JwAlAQANAAUIawr5LQDJAAAsAAQKfxYAAw0ABwgJFKBPAMsBAA0ABwgJFKBPAMsBAAYABgjdEe2mADEBAAAA.',['龙翱']='龙翱浩宇:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end