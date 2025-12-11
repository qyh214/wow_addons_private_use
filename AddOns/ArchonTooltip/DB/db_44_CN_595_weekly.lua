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
 local lookup = {'Mage-Frost','Hunter-BeastMastery','Shaman-Elemental','Warlock-Destruction','Warlock-Demonology','Druid-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Paladin-Retribution','Mage-Arcane','Unknown-Unknown','Warrior-Fury','Hunter-Marksmanship','Druid-Balance','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Protection','Priest-Holy','Priest-Shadow','Warrior-Arms','Evoker-Preservation','Mage-Fire','Shaman-Restoration','Warrior-Protection','Rogue-Assassination','Rogue-Subtlety','Druid-Guardian','Druid-Feral','DeathKnight-Blood','Monk-Windwalker','Rogue-Outlaw','Evoker-Devastation','Paladin-Holy','Priest-Discipline','Monk-Brewmaster',}; local provider = {region='CN',realm='勇士岛',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alexluo:BAAALAAFFAYIBAAAAA==.',Ar='Arrtis:BAAALAAECgYIBgAAAA==.',As='Ashbringer:BAAALAAECgYICAAAAA==.',Ca='Catlina:BAAALAAECgYIBwAAAA==.',Cr='Crazydk:BAAALAAECgEIAQAAAA==.',Da='Dart:BAAALAAECgIIAgAAAA==.',De='Devilcapt:BAAALAADCgIIAgAAAA==.',Dh='Dhccic:BAAALAAECgQIBQAAAA==.Dheroj:BAAALAADCggIEAAAAA==.',Du='Dumieone:BAABLAAECn8VAAIBAAYIbwytKADiAAABAAYIbwytKADiAAAAAA==.',Et='Eternalbonds:BAABLAAFFH8KAAICAAYIoCDEHgC3AQACAAYIoCDEHgC3AQAAAA==.',Fe='Fele:BAAALAAECgYIBgAAAA==.',Fr='Frostmoon:BAAALAAECgYIBgAAAA==.',Gr='Grill:BAAALAADCgIIAgAAAA==.',He='Hermitage:BAAALAAFFAIIAgAAAA==.',In='Inori:BAAALAADCgMIAwAAAA==.',Kh='Khuntoria:BAACLAAFFH8qAAIDAAcIyR2JCAAnAgADAAcIyR2JCAAnAgAsAAQKfykAAgMACAiYJS0WAPoBAAMACAiYJS0WAPoBAAAA.',Ki='Killuakeeper:BAAALAAECggIDQAAAA==.Killuakeepor:BAAALAAECggICAAAAA==.',Ky='Kyo:BAABLAAFFH8FAAMEAAIIeQ/FVABzAAAEAAIIeQ/FVABzAAAFAAEIBQufLABKAAAAAA==.',La='Latesaii:BAAALAADCgUIBgAAAA==.',Li='Liquidtobo:BAAALAAECgYIBgAAAA==.',Mi='Milklove:BAAALAAECgYICAAAAA==.Misslr:BAAALAAECgYIBgAAAA==.',Mo='Morghulis:BAABLAAFFH8OAAIGAAUIyhVGDgAVAQAGAAUIyhVGDgAVAQAAAA==.',Ms='Msorry:BAAALAADCggICQAAAA==.',Mu='Muguadegua:BAABLAAFFH8SAAMHAAUIOxH9IwDTAAAHAAUIOxH9IwDTAAAIAAEI7gGiGAAkAAAAAA==.',Na='Nakiyuu:BAAALAAECgIIAgAAAA==.Nakyiou:BAAALAAFFAIIBAAAAA==.',Rl='Rlyeh:BAAALAAFFAgIBAAAAA==.',Si='Siky:BAAALAAFFAIIBAAAAA==.Simon:BAAALAAECgIIBAAAAA==.',Sk='Skying:BAAALAADCggICAAAAA==.',So='Sosai:BAABLAAFFH8IAAIGAAIIdhW8NgBpAAAGAAIIdhW8NgBpAAAAAA==.',St='Starlight:BAABLAAFFH8GAAIJAAYI/QOZMQD2AAAJAAYI/QOZMQD2AAAAAA==.',Su='Succubus:BAAALAAECggICAAAAA==.Superorange:BAAALAADCgMIAwAAAA==.',Sy='Sycamore:BAAALAADCggICAAAAA==.',Tf='Tfgirl:BAABLAAFFH8TAAICAAMIbyDoYQC0AAACAAMIbyDoYQC0AAAAAA==.',Tt='Tt:BAAALAADCgEIAQAAAA==.Tta:BAAALAAECgEIAQAAAA==.Ttxx:BAAALAAECgYIDAAAAA==.',Va='Valac:BAAALAAECggICAAAAA==.',Vo='Vollerei:BAAALAAECgUIBQAAAA==.',Wa='Waagh:BAAALAADCgcIBwAAAA==.',Yu='Yuki:BAAALAAECgYIBgAAAA==.',Zo='Zong:BAAALAAECgQIBAAAAA==.',['一刀']='一刀快感:BAAALAAECgEIAQAAAA==.',['一翩']='一翩若惊鸿一:BAABLAAECn8VAAICAAYI3xMhrwAFAQACAAYI3xMhrwAFAQAAAA==.',['一首']='一首陌离歌:BAAALAAECgEIAQAAAA==.',['七七']='七七小妖狐:BAAALAAECgUIBQAAAA==.',['七小']='七小喵:BAAALAADCgQIBAAAAA==.',['三号']='三号小菜鸡:BAAALAAECggICAAAAA==.',['上官']='上官翠花:BAAALAAECgYIBgAAAA==.',['上帝']='上帝的人:BAAALAAECgYIBwAAAA==.',['上门']='上门龙婿:BAABLAAFFH8eAAIKAAcI7iDYDAABAgAKAAcI7iDYDAABAgAAAA==.',['下次']='下次我请:BAAALAAECgUIBQAAAA==.',['不一']='不一样的颜色:BAAALAADCgEIAQAAAA==.',['不可']='不可想象:BAAALAADCgYICAAAAA==.',['不擅']='不擅杀伐:BAAALAAECgQIBAABLAAECgQIBAALAAAAAA==.',['不朽']='不朽者:BAAALAAECgcIBwAAAA==.',['不知']='不知冬:BAABLAAECn8YAAIJAAYIoBAaeAAQAQAJAAYIoBAaeAAQAQAAAA==.',['不语']='不语有香来:BAAALAADCgQIBgAAAA==.',['东星']='东星耀阳:BAAALAAECgYIEwAAAA==.',['丨一']='丨一哥丨:BAABLAAFFH8NAAIIAAQIYQgjDAB6AAAIAAQIYQgjDAB6AAAAAA==.',['丨时']='丨时雨落枫丨:BAAALAAECgYIEgAAAA==.',['丨遗']='丨遗丶憾丨:BAAALAAECggICAAAAA==.',['丶时']='丶时雨落枫丶:BAAALAAECgYIEgAAAA==.',['丶獵']='丶獵:BAAALAAECgcIEQAAAA==.',['丶罪']='丶罪恶教父:BAABLAAFFH8GAAIMAAYIVQ4/HwBwAQAMAAYIVQ4/HwBwAQAAAA==.',['丶谢']='丶谢幕:BAAALAAFFAIIBAAAAA==.',['丶黯']='丶黯幕:BAAALAAFFAIIBAAAAA==.',['为了']='为了联盟灬:BAACLAAFFH8JAAICAAIIphM9VQCTAAACAAIIphM9VQCTAAAsAAQKfyEAAwIABwj4HCVsAAMCAAIABwj4HCVsAAMCAA0AAgj4BIG9ADUAAAAA.',['丿丶']='丿丶大迷糊:BAABLAAFFH8GAAIOAAMIohvhIgCZAAAOAAMIohvhIgCZAAAAAA==.',['丿斩']='丿斩:BAAALAAECgYICQAAAA==.',['久远']='久远银海:BAABLAAFFH8OAAMPAAYIrSEgGADZAQAPAAYIrSEgGADZAQAQAAEIQQY0EwBKAAAAAA==.',['九児']='九児:BAAALAAECgUIBQAAAA==.',['九士']='九士衞:BAAALAADCgMIAwAAAA==.',['九天']='九天丶:BAABLAAFFH8GAAICAAMIEhsLawCMAAACAAMIEhsLawCMAAAAAA==.',['九帝']='九帝:BAAALAAECgUIBQAAAA==.',['九徳']='九徳嶽:BAAALAAECgYICwAAAA==.',['九戨']='九戨:BAAALAAECgYICAAAAA==.',['九歌']='九歌:BAAALAAECgYIBwAAAA==.',['九牛']='九牛:BAABLAAECn8UAAMJAAYIlwpPNgHFAAAJAAYI0QRPNgHFAAARAAMIaw46bABbAAAAAA==.',['二三']='二三四五六:BAABLAAECn8VAAIJAAYIlhpGmgDAAQAJAAYIlhpGmgDAAQAAAA==.',['二壮']='二壮:BAAALAADCgYIBwAAAA==.',['云枫']='云枫乔:BAAALAADCggIDwAAAA==.',['产后']='产后喂八个:BAABLAAFFH8VAAMSAAYIkR4sCwAXAgASAAYIkR4sCwAXAgATAAYIZgrJEwA3AQAAAA==.',['人有']='人有点色:BAAALAAECgYICwAAAA==.',['亿之']='亿之水月:BAAALAAECgcIDwAAAA==.',['今晚']='今晚打脑斧:BAABLAAFFH8FAAIPAAIIViF2PwC0AAAPAAIIViF2PwC0AAABLAAFFAgIEQAPAOEUAA==.',['仙道']='仙道浮沉:BAABLAAFFH8GAAIJAAIIqgkedAA7AAAJAAIIqgkedAA7AAAAAA==.',['伊俐']='伊俐丹怒風:BAAALAAECgQIBwAAAA==.',['伊莉']='伊莉丹丶怒風:BAAALAAECgYIEQAAAA==.',['休闲']='休闲的风语者:BAAALAAECgQIBAAAAA==.',['会开']='会开花的云:BAAALAADCgEIAQAAAA==.',['传说']='传说哥:BAAALAAFFAIIAgAAAA==.',['佟大']='佟大为:BAAALAAECgMIBAAAAA==.',['你才']='你才是奶龙:BAAALAAFFAIIAwAAAA==.',['你给']='你给我记住:BAAALAAECgYICgAAAA==.',['依台']='依台望月梢:BAAALAAFFAIIAgAAAA==.',['倚长']='倚长剑凌清秋:BAAALAADCgYIBgAAAA==.',['偗委']='偗委高育良:BAAALAADCgIIAgAAAA==.',['做零']='做零的大号:BAAALAAECgYICwAAAA==.做零的小号:BAAALAAECgYIBgAAAA==.',['傲天']='傲天大兵:BAACLAAFFH8JAAICAAMIWw4WcQB/AAACAAMIWw4WcQB/AAAsAAQKfx4AAgIABgivHgONAMkBAAIABgivHgONAMkBAAAA.',['光芒']='光芒之瞳:BAAALAAECgQIBAAAAA==.光芒出鞘:BAAALAADCgYIBgAAAA==.',['克莉']='克莉斯蒂亚诺:BAABLAAECn8YAAIPAAYI2BUnVABKAQAPAAYI2BUnVABKAQAAAA==.',['八橙']='八橙在手:BAAALAAFFAIIAgAAAA==.',['八珍']='八珍豆腐:BAABLAAFFH8KAAIMAAYIPxALHgB5AQAMAAYIPxALHgB5AQAAAA==.',['六五']='六五三灵一:BAAALAAECgYIDgAAAA==.',['兰蒂']='兰蒂斯之长云:BAABLAAECn8YAAIJAAYIUxvhRgCHAQAJAAYIUxvhRgCHAQAAAA==.',['冥界']='冥界哈迪斯:BAAALAAECgMIAwAAAA==.冥界猎兽斯:BAAALAAECgUICAAAAA==.',['冰火']='冰火奥术真君:BAAALAAECgYIBgAAAA==.',['冰环']='冰环骑士:BAAALAAECgYIBgAAAA==.',['冰颜']='冰颜:BAAALAADCgEIAQAAAA==.',['冲浪']='冲浪的鲨鱼:BAABLAAFFH8IAAIMAAYIywOZLgDjAAAMAAYIywOZLgDjAAAAAA==.',['冲锋']='冲锋乆乆:BAABLAAECn8bAAMUAAgI8R7wBQCsAgAUAAgIdR7wBQCsAgAMAAYIqh9cSQAVAgAAAA==.',['冷月']='冷月孤影:BAABLAAFFH8FAAICAAMIxBUWbACKAAACAAMIxBUWbACKAAAAAA==.冷月曦:BAABLAAFFH8IAAIPAAIIbyT0MwDNAAAPAAIIbyT0MwDNAAABLAAFFAIICgAHANUiAA==.冷月焰:BAABLAAFFH8KAAIHAAII1SLNLgCsAAAHAAII1SLNLgCsAAAAAA==.',['冻鸡']='冻鸡:BAAALAAECggIBgAAAA==.',['凌乱']='凌乱的人生:BAABLAAECn8UAAMCAAYInhRrFgEQAQACAAUIxBNrFgEQAQANAAMIdhGEkgCgAAAAAA==.',['凌雲']='凌雲之羽:BAAALAAECgYIBgAAAA==.',['刘华']='刘华强:BAAALAADCggICAAAAA==.',['别搞']='别搞了呀:BAAALAAECgQIBAAAAA==.',['别给']='别给我奶:BAAALAAECgYICAAAAA==.',['割肉']='割肉大师:BAAALAAECgYIDgAAAA==.',['加尔']='加尔泰里奥:BAAALAAECgYIBgAAAA==.',['勇士']='勇士王子:BAAALAAECgIIAgAAAA==.',['勇者']='勇者无畏:BAAALAAECgYIBgAAAA==.',['卖萌']='卖萌骑骑:BAABLAAFFH8NAAIPAAUI+xUvQwAuAQAPAAUI+xUvQwAuAQAAAA==.',['南寒']='南寒:BAABLAAFFH8KAAIVAAIIgxUMEgCXAAAVAAIIgxUMEgCXAAAAAA==.',['南瓜']='南瓜超硬:BAAALAAECgYIDQAAAA==.',['南霸']='南霸天:BAAALAAECgYICwAAAA==.',['卡萨']='卡萨武士:BAAALAADCgcIBwAAAA==.',['卢饮']='卢饮溪:BAAALAAECggICAAAAA==.',['压力']='压力怪:BAAALAAFFAIIAgAAAA==.',['又红']='又红又硬:BAAALAAECgQIBwAAAA==.',['发型']='发型的熔光:BAAALAADCgQIBAAAAA==.',['变形']='变形乆乆:BAAALAAFFAgIAgAAAA==.',['口也']='口也鹏:BAABLAAFFH8KAAMHAAIIeh3kOACfAAAHAAIIVxrkOACfAAAIAAIIxhfVEgA4AAAAAA==.',['古术']='古术纯粮酒夜:BAAALAAECgQIBAABLAAFFAcIDQAEABcJAA==.古术纯粮酒虚:BAAALAAECgYICwABLAAFFAcIDQAEABcJAA==.',['古风']='古风淦:BAAALAAECgYICgAAAA==.',['可完']='可完事了:BAAALAADCggICAAAAA==.',['台台']='台台子怒海:BAAALAADCgEIAQAAAA==.',['吃不']='吃不胖的胖妞:BAAALAAECgUIBQAAAA==.',['同窗']='同窗:BAAALAAFFAIIAgAAAA==.',['呆萌']='呆萌小恶魔:BAABLAAFFH8OAAIFAAYIyRJUAgCAAQAFAAYIyRJUAgCAAQAAAA==.',['呜呜']='呜呜大喵:BAAALAAECgYICwAAAA==.',['周肥']='周肥錀:BAABLAAFFH8GAAIFAAIIdiC8EQCgAAAFAAIIdiC8EQCgAAAAAA==.',['周防']='周防天音:BAACLAAFFH8NAAMJAAIIRhQfSwCWAAAJAAIINQ0fSwCWAAARAAIIkBNJGQB0AAAsAAQKfyEAAwkABgggGauzAJkBAAkABggGF6uzAJkBABEABggsFtw+AEEBAAAA.',['哀求']='哀求:BAACLAAFFH8JAAIJAAMICxSHQwCKAAAJAAMICxSHQwCKAAAsAAQKfxcAAgkABggRGsqwAJ0BAAkABggRGsqwAJ0BAAAA.',['哈哩']='哈哩咕噜几:BAABLAAFFH8JAAMNAAIIDiGDFQC8AAANAAII1x+DFQC8AAACAAIIJhycZQCIAAAAAA==.',['哎呀']='哎呀我咬:BAAALAADCgEIAQAAAA==.',['唐初']='唐初排骨:BAAALAAECgYICwAAAA==.',['唐萌']='唐萌萌:BAAALAAECgEIAQABLAAFFAcIDQAEABcJAA==.',['喝不']='喝不完的酒瓶:BAAALAAECgMIAwAAAA==.',['喵若']='喵若兮:BAAALAAFFAIIBAAAAA==.',['嘟嘟']='嘟嘟小强:BAAALAAECgYIEgAAAA==.',['嘟大']='嘟大少:BAAALAADCggIDAAAAA==.',['嘟少']='嘟少归来:BAAALAADCgEIAQAAAA==.',['嘤吹']='嘤吹雪:BAAALAAECgUIBgAAAA==.',['嘻样']='嘻样样:BAAALAAECgUIBQAAAA==.',['噬之']='噬之魂:BAABLAAFFH8QAAMPAAYIiCNnEAALAgAPAAYIiCNnEAALAgAQAAII3hcCDgClAAAAAA==.',['团灭']='团灭发动机:BAAALAAECggICAAAAA==.',['图腾']='图腾乆乆:BAAALAAFFAYIAwAAAA==.',['圣光']='圣光壁垒:BAABLAAFFH8LAAMRAAMIvRdJDgCdAAARAAMIKxZJDgCdAAAJAAMIYQoAAAAAAAAAAA==.',['圣无']='圣无界三号:BAAALAAECgYIBgAAAA==.',['埃及']='埃及女王:BAACLAAFFH8NAAMEAAcIFwmZJgB/AQAEAAcIhgiZJgB/AQAFAAEI2wUuGAA4AAAsAAQKfxkAAwUABgjkFItCAGQBAAUABggYEotCAGQBAAQABghaEh1DADwBAAAA.',['埃尔']='埃尔文薛定谔:BAACLAAFFH8hAAIRAAYIFiJKAwDRAQARAAYIFiJKAwDRAQAsAAQKfysAAhEACAjTJYU+AEMBABEACAjTJYU+AEMBAAAA.',['埃里']='埃里尼斯:BAAALAADCggICAAAAA==.',['塔萨']='塔萨达尔:BAAALAAFFAIIAgAAAA==.',['墨染']='墨染沙场:BAAALAADCggICAAAAA==.墨染衣襟:BAAALAAECgIIAgAAAA==.',['墨洒']='墨洒丹心:BAAALAAECgYIBgAAAA==.',['墨灬']='墨灬灬者:BAAALAAECgQIBAAAAA==.',['士法']='士法:BAAALAAECgQIBAAAAA==.',['壹贰']='壹贰叁肆伍:BAAALAAECgIIAgAAAA==.',['夏未']='夏未至:BAABLAAFFH8IAAIPAAYIexnzIQCsAQAPAAYIexnzIQCsAQAAAA==.',['夜月']='夜月追风:BAACLAAFFH8yAAMKAAcI6hjbDgAGAgAKAAcI6hjbDgAGAgAWAAEIugd3DQBBAAAsAAQKfy0AAgoACAgtIBCUAGMBAAoACAgtIBCUAGMBAAAA.',['夜羽']='夜羽:BAAALAAFFAMIAwAAAA==.',['夜色']='夜色一奶:BAABLAAFFH8HAAIXAAMIDhXNOgC3AAAXAAMIDhXNOgC3AAAAAA==.',['夜风']='夜风骑士:BAAALAAFFAIIAwAAAA==.',['夜魔']='夜魔月:BAAALAAECgYICgAAAA==.',['大丶']='大丶爷:BAAALAAECgYICgABLAAECgYIFQAXADoSAA==.',['大主']='大主教伊蕊尔:BAABLAAFFH8GAAIXAAIIXxjUOQCNAAAXAAIIXxjUOQCNAAAAAA==.',['大丽']='大丽花的咆哮:BAAALAAECgIIBAAAAA==.',['大兵']='大兵:BAACLAAFFH8MAAIJAAIImg3ZXwBGAAAJAAIImg3ZXwBGAAAsAAQKfy8AAgkACAhoG7ceACMCAAkACAhoG7ceACMCAAAA.',['大沐']='大沐沐:BAAALAADCgEIAQAAAA==.',['大牛']='大牛追小牛:BAAALAAECgMIAwAAAA==.',['大风']='大风吹:BAACLAAFFH8bAAMGAAUIJwwGIwAEAQAGAAUIJwwGIwAEAQAOAAMIXwhGKQBsAAAsAAQKfyQAAgYACAgTFzYaAPwBAAYACAgTFzYaAPwBAAAA.',['天之']='天之城:BAAALAAECgEIAQAAAA==.',['天天']='天天一样:BAAALAAFFAIIAgAAAA==.天天又天天:BAAALAAECgUIBQAAAA==.天天向上:BAAALAAECgYIBgAAAA==.天天熊:BAAALAAECgMIAwAAAA==.',['天线']='天线小宝宝:BAAALAAECgEIAQAAAA==.',['奈何']='奈何花已谢:BAAALAAECgQIBQAAAA==.',['奋进']='奋进的小强:BAAALAAECgYIDAAAAA==.',['奔雷']='奔雷羽:BAAALAAFFAIIAgAAAA==.',['套马']='套马杆的汉子:BAAALAADCgMIAwAAAA==.',['女澡']='女澡堂搓背工:BAAALAAECgQIBAAAAA==.',['好名']='好名字:BAABLAAECn8aAAICAAgIGRGIYQB/AQACAAgIGRGIYQB/AQAAAA==.',['好想']='好想吃红烧鱼:BAABLAAFFH8GAAIGAAYIURoxEQC3AQAGAAYIURoxEQC3AQAAAA==.好想吃芝士:BAABLAAFFH8SAAIXAAYI0yGFCAA8AgAXAAYI0yGFCAA8AgAAAA==.好想吃蛋糕:BAABLAAFFH8JAAIEAAYIhx28HwCdAQAEAAYIhx28HwCdAQAAAA==.好想吃面包:BAAALAAFFAEIAQAAAA==.',['好战']='好战的大叔:BAABLAAECn8VAAIMAAYIlwhvbwDHAAAMAAYIlwhvbwDHAAAAAA==.',['妮璐']='妮璐:BAAALAAECgUIBQAAAA==.',['威哥']='威哥:BAAALAADCgIIAgAAAA==.',['孑然']='孑然妒火:BAAALAAFFAIIAgAAAA==.',['孤城']='孤城不危:BAABLAAFFH8HAAIXAAMIdAOpYwBXAAAXAAMIdAOpYwBXAAAAAA==.',['孤独']='孤独旅途:BAAALAAECgMIAwAAAA==.',['安度']='安度余生:BAAALAAECggIEQAAAA==.',['安静']='安静的大叔:BAAALAAECgIIAgAAAA==.',['宋雨']='宋雨琦:BAAALAADCgYIBgAAAA==.',['完美']='完美音调:BAABLAAFFH8JAAICAAYIbxCdQQBBAQACAAYIbxCdQQBBAQAAAA==.完美音韵:BAAALAAECgYIEwAAAA==.',['宗先']='宗先生:BAAALAAECgcICQAAAA==.',['宝宝']='宝宝猎手:BAAALAADCgcIBwAAAA==.宝宝雙:BAAALAAECgYIBgAAAA==.宝宝霜:BAAALAAECgYICgAAAA==.',['寂寞']='寂寞一枪:BAAALAAECgYICAAAAA==.',['对波']='对波太大:BAAALAAECgYIBwAAAA==.',['小宝']='小宝贝儿:BAACLAAFFH8GAAINAAIInwfJLwBiAAANAAIInwfJLwBiAAAsAAQKfxkAAg0ABggvFZ5SAGwBAA0ABggvFZ5SAGwBAAAA.',['小小']='小小仔仔:BAABLAAECn8YAAIJAAgI0BqQTgBTAgAJAAgI0BqQTgBTAgAAAA==.小小福:BAAALAADCgEIAQAAAA==.小小闹钟:BAAALAAECgYIDgAAAA==.',['小布']='小布丁:BAAALAAECgMIAwAAAA==.',['小弄']='小弄月:BAABLAAFFH8GAAIHAAII5Ba7TwBJAAAHAAII5Ba7TwBJAAAAAA==.',['小灰']='小灰灰解决:BAABLAAECn8XAAIPAAgI9xhQagAhAgAPAAgI9xhQagAhAgAAAA==.',['小皮']='小皮皮:BAAALAAECgYIDAAAAA==.',['小盒']='小盒子灬:BAAALAAECggICQAAAA==.',['小瞎']='小瞎眼:BAAALAADCggICAAAAA==.',['小米']='小米苏柒:BAAALAAECggICAAAAA==.',['小蹄']='小蹄子:BAAALAAECgIIAgAAAA==.',['小锅']='小锅米线:BAAALAADCggICAAAAA==.',['小闷']='小闷骚:BAAALAAECgMIAwAAAA==.',['小青']='小青儿:BAABLAAFFH8KAAISAAII5QSYRwBbAAASAAII5QSYRwBbAAABLAAFFAMICQAJAAsUAA==.小青青:BAABLAAFFH8KAAICAAIIRApFoQA+AAACAAIIRApFoQA+AAABLAAFFAMICQAJAAsUAA==.',['小鱼']='小鱼蛋:BAABLAAECn8UAAICAAgIMhIEdwBXAQACAAgIMhIEdwBXAQAAAA==.小鱼鱼:BAABLAAECn8eAAQBAAYI7BdaGABiAQABAAYI7BdaGABiAQAKAAQITguoTgDLAAAWAAEIuwgRGAAAAAAAAA==.',['小龙']='小龙人烧烤:BAAALAAECgYIDAAAAA==.',['峰理']='峰理子:BAAALAAECgYIDAAAAA==.',['嵐筱']='嵐筱玥:BAAALAADCggICAAAAA==.',['工程']='工程设备:BAAALAAECgEIAQAAAA==.',['左右']='左右围南:BAABLAAFFH8MAAIHAAYIaRlwHACTAQAHAAYIaRlwHACTAQAAAA==.',['巳白']='巳白:BAACLAAFFH8TAAQBAAMI0BpjDACQAAABAAMI0BpjDACQAAAWAAEIHA45DQBCAAAKAAIIBAVkawAiAAAsAAQKfyAAAwEABwgqGwoqANwBAAEABwg/GQoqANwBAAoABgjwFIuAAJEBAAAA.',['希尔']='希尔佤玲龙:BAAALAADCgEIAQAAAA==.',['帝煌']='帝煌:BAAALAAECggIDgAAAA==.',['幸福']='幸福旳闪光:BAAALAAECgYIBgAAAA==.',['幻想']='幻想小德:BAAALAAFFAIIBAAAAA==.',['幻灵']='幻灵幽幽:BAAALAAECgYIEgAAAA==.',['幻魔']='幻魔颜色:BAAALAADCgEIAQAAAA==.',['幽冥']='幽冥暮色:BAAALAAECgQIBAAAAA==.',['幽梦']='幽梦之兰:BAAALAAECgQIBAAAAA==.',['幽荧']='幽荧:BAAALAAFFAIIAwAAAA==.',['幽默']='幽默绿火人:BAAALAAFFAIIAgAAAA==.',['库伊']='库伊特温:BAAALAAECgQIBAAAAA==.',['康师']='康师傅冰红茶:BAAALAAECgMIAwAAAA==.',['康忙']='康忙泽喂:BAAALAAECgYIBgAAAA==.',['弄弄']='弄弄:BAABLAAFFH8JAAIPAAII2hNAfABHAAAPAAII2hNAfABHAAAAAA==.',['影之']='影之魔魂:BAAALAAECgYIBgAAAA==.',['影凉']='影凉:BAAALAAECgEIAQAAAA==.',['影心']='影心:BAACLAAFFH8GAAIVAAIIYhdmFwCQAAAVAAIIYhdmFwCQAAAsAAQKfxUAAhUABghCG6IXAMkBABUABghCG6IXAMkBAAAA.',['得非']='得非所求:BAAALAAECgYIEAAAAA==.',['微雨']='微雨雰霏:BAAALAADCggICAAAAA==.',['德国']='德国珠宝大师:BAAALAAECgYICgAAAA==.',['德樀']='德樀樀:BAAALAAFFAIIAgAAAA==.',['德鲁']='德鲁一:BAAALAADCgcIBwAAAA==.',['心尘']='心尘:BAAALAAFFAIIAgAAAA==.',['心想']='心想事橙:BAAALAADCgIIAgAAAA==.',['心的']='心的发现:BAABLAAFFH8JAAIEAAMIbRN1SgCRAAAEAAMIbRN1SgCRAAAAAA==.',['怒吼']='怒吼的大叔:BAABLAAECn8VAAIPAAcIchToOQCUAQAPAAcIchToOQCUAQAAAA==.',['思寒']='思寒梅:BAAALAAECgUIBQAAAA==.',['思琪']='思琪琦:BAAALAAECgYIBgAAAA==.',['恋上']='恋上熊的咕咕:BAAALAAECgEIAQAAAA==.恋上狗的狼:BAAALAAFFAMIAwAAAA==.恋上酒的猫:BAABLAAFFH8IAAICAAMIwhERfQBeAAACAAMIwhERfQBeAAAAAA==.',['恐怖']='恐怖死亡騎士:BAAALAAFFAIIBAAAAA==.',['恩里']='恩里克普奇:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔乄市銀丸:BAAALAAECgUIBQAAAA==.恶魔乆乆:BAAALAAFFAYIAwAAAA==.恶魔娃娃:BAAALAAECgYICwAAAA==.恶魔烈首:BAAALAAECgUICQAAAA==.',['悠哉']='悠哉丶:BAAALAAFFAIIBAAAAA==.',['愤怒']='愤怒的企鹅:BAAALAADCgIIAgAAAA==.',['慕红']='慕红绫:BAAALAAECgUIBQAAAA==.',['我就']='我就是天神:BAAALAAECgYIBgAAAA==.',['我想']='我想吃人:BAAALAADCgQIBAAAAA==.',['我来']='我来组成头部:BAAALAAECgYICQAAAA==.',['我欲']='我欲我狂:BAAALAAECgQIBAAAAA==.',['我热']='我热:BAAALAADCgYIBgAAAA==.',['我爱']='我爱小动物:BAAALAADCgYIBgAAAA==.',['战珏']='战珏丶:BAAALAADCggIEAAAAA==.',['战神']='战神丶贝塔:BAABLAAFFH8NAAIYAAIIkQQ/MABTAAAYAAIIkQQ/MABTAAAAAA==.',['戰岚']='戰岚破海:BAABLAAFFH8GAAIMAAYISQXUKQAeAQAMAAYISQXUKQAeAQABLAAFFAgIOAAMAHgjAA==.',['戰魂']='戰魂灬:BAAALAADCggIDAAAAA==.',['扭曲']='扭曲切割者:BAAALAAFFAMIAwAAAA==.',['摁着']='摁着来:BAAALAADCgQIBAAAAA==.',['收售']='收售买卖:BAAALAAECgYIDAAAAA==.',['故事']='故事书:BAAALAAECgEIAQAAAA==.',['故人']='故人:BAABLAAFFH8GAAIMAAII4QydOwCSAAAMAAII4QydOwCSAAAAAA==.',['敏而']='敏而杰出:BAAALAAECgYIBgAAAA==.',['敗家']='敗家佐將:BAAALAAECgYICwAAAA==.',['敬一']='敬一静:BAAALAAECgYIBgAAAA==.',['文文']='文文哥哥:BAABLAAFFH8HAAMZAAUIIgueEAD7AAAZAAUILgqeEAD7AAAaAAEIIgYUFwA8AAAAAA==.',['断线']='断线远飞:BAABLAAECn8YAAMDAAYIgRaKMwBCAQADAAYIgRaKMwBCAQAXAAYIZQR7gACIAAAAAA==.',['新月']='新月之痕:BAAALAAECgIIAgAAAA==.',['方丈']='方丈出山:BAAALAAECgYICQAAAA==.',['无力']='无力小萱:BAABLAAFFH8JAAIHAAUIqxIcLAA2AQAHAAUIqxIcLAA2AQAAAA==.',['无双']='无双绯花:BAAALAAECgMIAwAAAA==.',['无情']='无情修罗:BAAALAAECgMIBAAAAA==.',['无敌']='无敌大虾:BAABLAAECn8XAAIEAAcIQQxrggB6AQAEAAcIQQxrggB6AQAAAA==.无敌的饲养员:BAAALAAECgMIAwAAAA==.',['无盐']='无盐女丶钟离:BAAALAAECgYICAAAAA==.',['无苛']='无苛取玳:BAAALAAECgQIBAAAAA==.',['旦旦']='旦旦哥哥:BAAALAAECgYIBgAAAA==.',['时似']='时似初冬:BAAALAAECgEIAQAAAA==.',['时光']='时光漫步:BAAALAAECgYIBgAAAA==.',['时间']='时间煮客:BAABLAAFFH8YAAQbAAYI2g0nBAAKAQAbAAYI2g0nBAAKAQAcAAMI0Ac7CwBvAAAOAAEI0wYSNwA4AAAAAA==.',['旺旺']='旺旺泰和:BAAALAAFFAIIAgAAAA==.',['明明']='明明不是天使:BAAALAAECgcIBwAAAA==.明明很愤怒:BAAALAAECgYIDAAAAA==.',['易见']='易见宗亲:BAAALAAECgcICgAAAA==.',['星也']='星也丶:BAAALAADCgMIAwAAAA==.',['星浅']='星浅丶:BAAALAAECggICAAAAA==.',['昨晚']='昨晚星辰:BAAALAAECgYICgAAAA==.',['是壮']='是壮嗄:BAAALAAFFAMIBAAAAA==.',['普莉']='普莉梅拉:BAAALAAFFAIIAgAAAA==.',['暖风']='暖风袭我心:BAAALAADCggICAAAAA==.',['暗之']='暗之猎杀:BAAALAAECgEIAQAAAA==.',['暗夜']='暗夜小萱萱:BAABLAAFFH8ZAAIPAAUIphkhPgBCAQAPAAUIphkhPgBCAQAAAA==.',['曹阿']='曹阿满呀:BAABLAAFFH8IAAIXAAIIfhD+WgBlAAAXAAIIfhD+WgBlAAAAAA==.',['月樱']='月樱落落:BAABLAAFFH8FAAIOAAUI3wJIIgChAAAOAAUI3wJIIgChAAAAAA==.',['月蚀']='月蚀之舞:BAABLAAFFH8aAAMYAAcI2Qh2FAAaAQAYAAYIqAl2FAAaAQAMAAMILwJcXwA1AAAAAA==.',['朝天']='朝天公:BAAALAAECgYIBgAAAA==.',['木一']='木一一:BAAALAADCggICAAAAA==.',['木瓜']='木瓜惹的祸:BAABLAAFFH8ZAAIPAAUICBhlQAA5AQAPAAUICBhlQAA5AQAAAA==.木瓜的俏女狼:BAABLAAFFH8FAAIYAAUIEAloGQDTAAAYAAUIEAloGQDTAAAAAA==.木瓜的萨满:BAABLAAFFH8NAAMDAAYIawe4KwDeAAADAAQIPwa4KwDeAAAXAAMI5gzgTwB8AAAAAA==.木瓜的骑士:BAABLAAFFH8QAAMJAAUILRP7KQAvAQAJAAUILRP7KQAvAQARAAIIZQV9IABWAAAAAA==.',['木石']='木石枚子:BAAALAAECggICAAAAA==.',['朱加']='朱加什维利:BAAALAAECgMIAwAAAA==.',['李善']='李善心:BAABLAAFFH8JAAITAAIIIx9PFwC6AAATAAIIIx9PFwC6AAABLAAFFAIICgAHANUiAA==.',['李清']='李清照丶:BAABLAAFFH8jAAIRAAYIHiMhAgAAAgARAAYIHiMhAgAAAgAAAA==.',['李逍']='李逍遙:BAABLAAFFH8GAAIHAAYIMxSRIAB/AQAHAAYIMxSRIAB/AQAAAA==.',['村尾']='村尾娇花:BAAALAADCggICAAAAA==.',['杜甫']='杜甫丶:BAABLAAFFH8kAAMdAAcImxxIBwC5AQAdAAYIGB1IBwC5AQAPAAQI8hYPKwDsAAAAAA==.',['来吧']='来吧啦:BAAALAAECgcIBwAAAA==.',['杨教']='杨教授:BAAALAADCgUIBQAAAA==.',['板凳']='板凳宽:BAAALAAECgYIBgAAAA==.',['极博']='极博大的胸怀:BAAALAAECgMIAwAAAA==.',['果果']='果果小猎手:BAAALAADCgIIAgAAAA==.',['枪枪']='枪枪不落空:BAAALAADCgYIBgAAAA==.',['枫叶']='枫叶飘落:BAABLAAECn8kAAQUAAYIxxXlCAAjAQAUAAYIzxPlCAAjAQAYAAYI2BEQLAD2AAAMAAYItRD7xgDoAAAAAA==.',['枫哥']='枫哥:BAAALAADCgEIAQAAAA==.',['枫珏']='枫珏丶:BAAALAAECgcIDwAAAA==.',['柠檬']='柠檬养乐多:BAAALAADCggICAAAAA==.',['桔子']='桔子熊:BAAALAAECggIBgAAAA==.',['梦予']='梦予:BAAALAAECgYIBgAAAA==.',['梦境']='梦境之忆:BAAALAAFFAIIAgAAAA==.',['梦娜']='梦娜:BAAALAADCgIIAgAAAA==.',['梦菲']='梦菲菲:BAAALAAECgYIBgAAAA==.',['梦醒']='梦醒的嘟少:BAAALAADCgUIBQAAAA==.',['森林']='森林丶:BAAALAADCgEIAQAAAA==.',['森语']='森语鹿鸣:BAAALAAFFAIIAgAAAA==.',['椰果']='椰果奶茶:BAAALAAECggICAAAAA==.',['樱洛']='樱洛咲绮:BAAALAAECgIIAgAAAA==.',['橘子']='橘子熊:BAAALAAECggICAAAAA==.',['橘色']='橘色摇裤儿:BAAALAAECgYIBgABLAAFFAgIBgAYAJwbAA==.',['武器']='武器小王子:BAACLAAFFH8KAAIYAAIIfhrAHQCDAAAYAAIIfhrAHQCDAAAsAAQKfxkAAhgABwiMHxkYAHACABgABwiMHxkYAHACAAAA.',['歪瑞']='歪瑞固德:BAAALAAECgYICQAAAA==.',['歪萨']='歪萨:BAAALAAECgYIDAAAAA==.',['死白']='死白菜:BAABLAAFFH8dAAIPAAYIjxcqKQCSAQAPAAYIjxcqKQCSAQAAAA==.',['死而']='死而后已:BAAALAAECgYIBgAAAA==.',['残云']='残云丶:BAACLAAFFH8JAAIPAAIItAjjgACGAAAPAAIItAjjgACGAAAsAAQKfx8AAg8ABwifH5NDAHcCAA8ABwifH5NDAHcCAAAA.残云野鹤:BAAALAAFFAIIAgAAAA==.',['殘酷']='殘酷天使:BAAALAAECgIIAgAAAA==.',['段小']='段小贱:BAAALAAECgQIBQAAAA==.',['毁灭']='毁灭归来:BAABLAAFFH8FAAIEAAIIJQRvVQBwAAAEAAIIJQRvVQBwAAAAAA==.',['每天']='每天都来:BAAALAAECgYIBgAAAA==.',['氯化']='氯化鈉:BAAALAAECgcIBwAAAA==.',['水城']='水城:BAAALAAECgEIAQAAAA==.',['水无']='水无月丶辉夜:BAAALAAFFAIIAgAAAA==.',['水波']='水波啵:BAAALAAFFAIIAwAAAA==.',['汤圆']='汤圆麻麻:BAAALAAECgMIAwAAAA==.',['沃尔']='沃尔夫冈泡利:BAABLAAFFH8FAAIaAAUIsgrzCwDYAAAaAAUIsgrzCwDYAAAAAA==.',['没点']='没点逼术:BAACLAAFFH8QAAMFAAII7xxHFQCaAAAFAAII8RJHFQCaAAAEAAII7xzEWABHAAAsAAQKfy8AAwQABwhbHIVGACICAAQABgjOHoVGACICAAUABgi+GOw2AJEBAAAA.',['泡沫']='泡沫冰茶:BAAALAAECgYICwAAAA==.泡沫流梨:BAAALAAECgYIEwAAAA==.',['泪血']='泪血狂徒:BAAALAAECgcIBwAAAA==.',['活力']='活力小萱:BAABLAAFFH8XAAISAAUIWh1ZFQCpAQASAAUIWh1ZFQCpAQAAAA==.',['活得']='活得不耐烦:BAAALAAECgYIBgAAAA==.',['流羽']='流羽牛掰奶爸:BAABLAAFFH8FAAIbAAMIqQn8BQCPAAAbAAMIqQn8BQCPAAAAAA==.',['浦江']='浦江一号:BAAALAADCggIDwAAAA==.',['海之']='海之心猎:BAAALAAECgYICAAAAA==.',['消失']='消失嘚美俪:BAAALAAECgQIBAAAAA==.',['涣然']='涣然:BAAALAAECgIIAgAAAA==.',['清娃']='清娃儿:BAAALAADCggICAAAAA==.',['温小']='温小暖:BAABLAAFFH8IAAIJAAYIuR3mEQC4AQAJAAYIuR3mEQC4AQAAAA==.',['湾仔']='湾仔大飞哥:BAABLAAFFH8NAAIMAAUIuBHUJgA5AQAMAAUIuBHUJgA5AQAAAA==.',['潮基']='潮基玛丽:BAAALAAFFAIIAgAAAA==.',['潮湿']='潮湿鍀记忆:BAABLAAFFH8UAAMGAAYIoRnTEQDqAAAGAAUIjRrTEQDqAAAbAAYI0xDxBADhAAAAAA==.',['澤塔']='澤塔瓊斯:BAAALAADCgYICQAAAA==.',['瀙灬']='瀙灬啈冨漩嵂:BAAALAAECgYIBwAAAA==.',['火吻']='火吻:BAAALAAECgYIBgAAAA==.',['火羽']='火羽白熠:BAAALAADCgUIBQAAAA==.',['灬乾']='灬乾坤灬:BAAALAAECgEIAQAAAA==.',['灬时']='灬时雨落枫灬:BAABLAAECn8XAAIeAAYI3A4bHgAMAQAeAAYI3A4bHgAMAQAAAA==.',['灬灬']='灬灬风灬灬:BAAALAAECgYIDAAAAA==.',['灭绝']='灭绝贼太:BAABLAAECn8ZAAQaAAcI0RiwHACuAQAaAAcIAxSwHACuAQAZAAUIfxuBNwCBAQAfAAEIIADLIwAEAAAAAA==.',['灵魂']='灵魂边缘:BAABLAAECn8XAAMEAAYIfh9VJADMAQAEAAYIfh9VJADMAQAFAAEIWALvOwAPAAABLAAFFAIIBAALAAAAAA==.',['烈焰']='烈焰猎手:BAAALAAECgYIDQAAAA==.',['热情']='热情的大叔:BAAALAAFFAEIAQAAAA==.',['無办']='無办法:BAAALAAECgEIAQAAAA==.',['焦如']='焦如花:BAAALAAECgYICwAAAA==.',['熊五']='熊五:BAAALAAFFAEIAQAAAA==.',['熊猫']='熊猫茄子:BAABLAAFFH8GAAIXAAMIURG3QwCaAAAXAAMIURG3QwCaAAAAAA==.',['爆不']='爆不够:BAAALAAFFAIIAgAAAA==.',['爆弹']='爆弹狂鼠:BAAALAAFFAIIBAAAAA==.',['爆爷']='爆爷脾气大:BAAALAAFFAMIAwAAAA==.',['爫人']='爫人爫:BAAALAADCggICAAAAA==.',['爱菟']='爱菟孖:BAABLAAFFH8GAAIdAAYI0AyWBQCXAQAdAAYI0AyWBQCXAQAAAA==.',['牧马']='牧马南山:BAAALAAECgEIAQAAAA==.',['狂暴']='狂暴狂暴战神:BAAALAAFFAIIAgAAAA==.',['狂灬']='狂灬飘渺灬:BAAALAAECggICAAAAA==.',['狂烈']='狂烈焰吻:BAAALAAECgMIAwAAAA==.',['狼之']='狼之嚎叫:BAAALAAECgYIBgAAAA==.',['猎手']='猎手仁心:BAAALAAECgYIBgAAAA==.',['猎灵']='猎灵:BAAALAAECgYICwAAAA==.',['猎物']='猎物不够:BAABLAAFFH8FAAICAAMIwwdwrAA5AAACAAMIwwdwrAA5AAAAAA==.',['猫猫']='猫猫爱吃鱼:BAAALAAECgYIAwAAAA==.',['王者']='王者歸來:BAAALAAECgYICgAAAA==.',['生煎']='生煎若干鸡蛋:BAACLAAFFH8XAAIYAAYI6Q9cEwAoAQAYAAYI6Q9cEwAoAQAsAAQKfxgAAhgACAjvFmUhACoCABgACAjvFmUhACoCAAAA.',['电子']='电子德:BAAALAAECgYICgAAAA==.',['當爱']='當爱已成往事:BAABLAAFFH8FAAMMAAIIcgTdYQAvAAAMAAIIcgTdYQAvAAAYAAIIPAMbOQAmAAAAAA==.',['疾风']='疾风破袭:BAABLAAFFH8MAAIBAAMI3xJ4DQCDAAABAAMI3xJ4DQCDAAAAAA==.',['痴迷']='痴迷丶凹凸曼:BAAALAAECgYIBgAAAA==.',['白石']='白石麻衣:BAAALAAECgYIBgAAAA==.',['白马']='白马度春风:BAAALAAFFAIIBAAAAA==.',['皎兮']='皎兮:BAAALAADCgMIAwAAAA==.',['皮克']='皮克逃:BAAALAADCgUIBQAAAA==.',['盾在']='盾在手人在抖:BAAALAAECgEIAQAAAA==.',['眉间']='眉间点血:BAAALAAECgYICQAAAA==.',['看撒']='看撒啊:BAAALAAECggIDwAAAA==.',['砹氰']='砹氰:BAABLAAECn8UAAMFAAYIZh4bMgClAQAFAAUI/h8bMgClAQAEAAYIghh6dwCUAQAAAA==.',['社会']='社会平爷:BAABLAAFFH8EAAIOAAQIAxfWHgDNAAAOAAQIAxfWHgDNAAAAAA==.',['神户']='神户小鸟:BAAALAAECggIEAABLAAFFAYIBgAOAHsWAA==.',['神箭']='神箭丘比特:BAAALAAFFAIIBAAAAA==.',['神话']='神话天山:BAAALAAECgQIBQAAAA==.',['秋葉']='秋葉蒝:BAACLAAFFH8LAAICAAMIXxA7cQB/AAACAAMIXxA7cQB/AAAsAAQKfywAAgIACAjxG5QtAAQCAAIACAjxG5QtAAQCAAAA.',['窝暧']='窝暧丨条柴:BAAALAAFFAIIBAAAAA==.',['立定']='立定跳远两米:BAAALAAECgYIBwAAAA==.',['竹灬']='竹灬子:BAAALAAECgYIBgAAAA==.竹灬灬笋:BAAALAAECgQIBAAAAA==.',['笼中']='笼中鸟:BAAALAADCgYIEgAAAA==.',['箭下']='箭下亡魂:BAABLAAFFH8GAAINAAYICg1sBwCoAQANAAYICg1sBwCoAQAAAA==.',['米度']='米度沙:BAAALAAFFAIIBAAAAA==.',['米色']='米色极光:BAAALAAECgYIDAAAAA==.',['糊涂']='糊涂老墨:BAAALAAECgYIBgAAAA==.',['糖醋']='糖醋鲤鱼:BAAALAAECgYIDAAAAA==.',['素杜']='素杜放弃:BAAALAAFFAIIAgABLAAFFAcIDQAEABcJAA==.',['紫荆']='紫荆依然:BAAALAAECgYIDwAAAA==.紫荆月漓:BAAALAADCgYICQAAAA==.',['红尘']='红尘似夢:BAAALAAFFAIIBAAAAA==.',['红茶']='红茶拿铁:BAAALAAECggIEgAAAA==.',['练拳']='练拳先练嘴:BAAALAAECgYIBwAAAA==.',['绅不']='绅不由己:BAAALAAFFAIIAgAAAA==.',['给你']='给你一烈焰:BAAALAAFFAQIBAAAAA==.',['绝灭']='绝灭:BAAALAAECgcIDQAAAA==.',['绯室']='绯室丶灯:BAAALAAECgMIAwAAAA==.',['罗刹']='罗刹夜舞:BAAALAAECgEIAQAAAA==.',['羅雨']='羅雨:BAAALAADCgcIDAAAAA==.',['美人']='美人如画:BAAALAAECgMIAwAAAA==.美人如诗:BAAALAAECgIIAgAAAA==.',['翁雪']='翁雪:BAABLAAFFH8KAAIKAAYIkxt1JACDAQAKAAYIkxt1JACDAQABLAAFFAgIFAAJAKIWAA==.',['翔龙']='翔龙破空:BAAALAAECgUICgAAAA==.',['翩纤']='翩纤:BAAALAAECgYIEgAAAA==.',['老丁']='老丁豆:BAAALAAECgcIBwAAAA==.',['老娘']='老娘奶水淘淘:BAAALAAECgMIAwABLAAFFAIICQANAA4hAA==.',['老干']='老干部处主任:BAAALAADCgIIAgAAAA==.',['耂孒']='耂孒葽丄牀:BAAALAADCgEIAQAAAA==.',['胖哒']='胖哒:BAABLAAFFH8GAAICAAIIuhp3jABHAAACAAIIuhp3jABHAAAAAA==.',['胖奶']='胖奶:BAAALAAECgEIAQAAAA==.',['胡椒']='胡椒与盐:BAAALAAECgYICgAAAA==.',['胡风']='胡风岭:BAAALAAECgEIAQAAAA==.',['脾气']='脾气温顺的哥:BAAALAAECgYIDAAAAA==.',['腾飞']='腾飞我是秀姨:BAAALAAFFAIIAgAAAA==.',['自然']='自然猎手:BAAALAADCggIEAAAAA==.',['舞丶']='舞丶不练了:BAABLAAECn8UAAICAAYI6RFDwQDsAAACAAYI6RFDwQDsAAAAAA==.',['艾丽']='艾丽瑞亚:BAAALAADCgYIBgAAAA==.',['艾俄']='艾俄洛斯:BAAALAAECgYIBgAAAA==.',['艾利']='艾利亚罗:BAAALAAECgYICwAAAA==.',['艾萨']='艾萨克:BAAALAAECgYIBgAAAA==.',['艾黎']='艾黎娅罗:BAAALAADCgYIBgAAAA==.',['花思']='花思愁丶忆喵:BAAALAADCgcIBwABLAAECgYIFQAXADoSAA==.',['花间']='花间丶一壶酒:BAAALAAECgYIEQAAAA==.',['苍穹']='苍穹夜鸦:BAAALAAFFAIIAgAAAA==.',['苏打']='苏打汽水:BAAALAAFFAIIBAABLAAFFAMIDgAOAIYXAA==.',['苏酥']='苏酥头号粉丝:BAABLAAFFH8OAAIOAAMIhhdMEADwAAAOAAMIhhdMEADwAAAAAA==.',['若叶']='若叶牧:BAABLAAFFH8PAAISAAIIOCS4IwCqAAASAAIIOCS4IwCqAAAAAA==.',['英雄']='英雄风车车:BAAALAAECgEIAQAAAA==.',['茉莉']='茉莉小猫:BAAALAAECgYIDAAAAA==.',['茭白']='茭白:BAAALAAECgMIAwAAAA==.',['莉莉']='莉莉丝丶光刃:BAAALAADCgUIBQAAAA==.',['莫西']='莫西欧赖:BAAALAAECggIBQAAAA==.',['莫隐']='莫隐:BAAALAAECgQIBAAAAA==.',['華扇']='華扇:BAAALAAECggIAgAAAA==.',['萃香']='萃香:BAAALAAECgYIBgAAAA==.',['萨摩']='萨摩耶爷:BAACLAAFFH8MAAIXAAIIwhJbWgBmAAAXAAIIwhJbWgBmAAAsAAQKfxkAAhcABwipGDgzAJIBABcABwipGDgzAJIBAAEsAAUUAwgJAAkACxQA.',['萨森']='萨森斯坦森:BAAALAAECgYICgAAAA==.',['萨满']='萨满尼:BAAALAAFFAIIBAAAAA==.',['落花']='落花菲:BAAALAADCggICAAAAA==.',['蓄力']='蓄力小萱:BAABLAAFFH8aAAIgAAUIPxc/DwAnAQAgAAUIPxc/DwAnAQAAAA==.',['蓓哈']='蓓哈丽雅:BAAALAAFFAQIBAAAAA==.',['蓝颜']='蓝颜知己:BAAALAAECgEIAQAAAA==.',['蔷薇']='蔷薇之溅:BAAALAAECggICAAAAA==.',['薇尔']='薇尔丽特:BAAALAAECgYIBgAAAA==.',['藏玛']='藏玛然特:BAABLAAFFH8FAAIEAAUI+A3XOwAWAQAEAAUI+A3XOwAWAQAAAA==.',['虎逼']='虎逼猎:BAAALAAECgYIBgAAAA==.',['行到']='行到水穷:BAAALAAECgYIBgAAAA==.',['覃沐']='覃沐:BAAALAAFFAIIAgAAAA==.',['覆盆']='覆盆子:BAAALAAECggIDQAAAA==.',['见贤']='见贤思骑:BAAALAAECggIDwAAAA==.',['諵蛮']='諵蛮乁笙箫亥:BAAALAAECgYIDAAAAA==.諵蛮乁笙箫卯:BAAALAAECgEIAQAAAA==.諵蛮乁笙箫子:BAAALAAECgQICQAAAA==.諵蛮乁笙箫未:BAAALAAECgMIAwAAAA==.諵蛮乁笙箫酉:BAAALAAECgMIAwAAAA==.',['请你']='请你喝阿帕茶:BAAALAAECgYICQAAAA==.',['谁为']='谁为天使忧愁:BAACLAAFFH8kAAMPAAYIUR63IQCtAQAPAAYIUR63IQCtAQAdAAII7hbfDgCQAAAsAAQKfy0AAw8ACAh1IW8wALECAA8ACAh1IW8wALECAB0ABgjaGisjAGoBAAAA.',['谁会']='谁会记得我:BAAALAAECgYIDQAAAA==.',['调皮']='调皮软脚虾:BAAALAAECgYIBgAAAA==.',['豆沙']='豆沙饼:BAABLAAFFH8JAAIBAAIIcSB4CQC4AAABAAIIcSB4CQC4AAAAAA==.',['豆花']='豆花米线:BAAALAAECgYIDAAAAA==.',['贝亚']='贝亚特丽斯丶:BAAALAAECgQIBAAAAA==.',['费尔']='费尔南多:BAAALAAECgUIBQAAAA==.',['赖床']='赖床大叔:BAAALAAECgQIBgAAAA==.',['赛亚']='赛亚人丶:BAAALAAECggICgAAAA==.',['超级']='超级狼弓大王:BAABLAAFFH8IAAICAAYIkSLQEwDwAQACAAYIkSLQEwDwAQAAAA==.超级钢板:BAAALAAECgYIDAAAAA==.',['越过']='越过那高墙:BAAALAAECgYICgAAAA==.',['跳跳']='跳跳魅:BAAALAAECgYICAAAAA==.',['蹦叉']='蹦叉叉:BAAALAADCgEIAQAAAA==.',['轟轟']='轟轟烮烮:BAAALAADCgMIAwAAAA==.',['辣白']='辣白菜:BAACLAAFFH8TAAIDAAYI9RO0GQBxAQADAAYI9RO0GQBxAQAsAAQKfxYAAgMABwivIRErAGYCAAMABwivIRErAGYCAAAA.',['达克']='达克萌:BAAALAAECgYIBgAAAA==.',['还不']='还不削弱嘛:BAABLAAFFH8HAAICAAIIEySdeABrAAACAAIIEySdeABrAAAAAA==.',['迦娜']='迦娜西亞:BAAALAADCgQIBAAAAA==.',['追萌']='追萌狄霹艾斯:BAAALAAFFAIIAgAAAA==.追萌芙蕾雅:BAABLAAFFH8FAAIJAAIIZgeRggAlAAAJAAIIZgeRggAlAAAAAA==.',['逆風']='逆風:BAAALAAECgEIAQAAAA==.',['逆风']='逆风的泪:BAABLAAECn8aAAIBAAYIGQ48JwDrAAABAAYIGQ48JwDrAAAAAA==.',['逐风']='逐风烨月:BAAALAAECgQIBAAAAA==.',['遗失']='遗失滴梦境:BAAALAAECgIIAgAAAA==.',['那么']='那么稳:BAAALAAECgYIBgAAAA==.',['那年']='那年十八岁:BAAALAADCggIEQAAAA==.那年的春夏:BAACLAAFFH8OAAIJAAUIZBIuLAAiAQAJAAUIZBIuLAAiAQAsAAQKfxYAAwkACAieGCFDAJIBAAkACAicGCFDAJIBABEABghFE9M6AFYBAAAA.',['邪恶']='邪恶冷月:BAAALAAECgYIBgAAAA==.',['部落']='部落的敌人:BAACLAAFFH8XAAMCAAYImwtJUAANAQACAAYImwtJUAANAQANAAEIfAG8HAAjAAAsAAQKfyoAAwIACAjbFL+aACEBAAIACAjPFL+aACEBAA0AAgiSDTyqAFwAAAAA.',['酒鬼']='酒鬼猎手:BAAALAAFFAIIAgAAAA==.',['酥油']='酥油丶奶茶:BAAALAAECgQIBwABLAAFFAcIDQAEABcJAA==.',['醉恨']='醉恨聖逗士:BAABLAAFFH8OAAMCAAIIkBZ4lwBCAAANAAIILAbkLQBpAAACAAIIkBZ4lwBCAAAAAA==.醉恨誑寳戰:BAABLAAFFH8GAAIYAAIIVQr4MQAxAAAYAAIIVQr4MQAxAAAAAA==.',['醉梦']='醉梦浮生:BAAALAAECgYICAAAAA==.',['醉酒']='醉酒战将:BAAALAADCggICAAAAA==.',['釉子']='釉子茶:BAAALAADCgQIBAAAAA==.',['重击']='重击光环:BAAALAADCgQIBAAAAA==.',['金刚']='金刚不倒:BAAALAAECgYIBgAAAA==.',['长期']='长期术世:BAAALAAECgYICgAAAA==.',['长角']='长角的美女:BAABLAAECn8VAAIXAAYIOhIcoAA+AQAXAAYIOhIcoAA+AQAAAA==.',['閃耀']='閃耀:BAABLAAFFH8JAAIhAAYI/w6gBgDFAQAhAAYI/w6gBgDFAQAAAA==.',['闪电']='闪电五连鞭:BAAALAAECgYIDQAAAA==.',['闪闪']='闪闪不泡茶:BAAALAAFFAIIBAAAAA==.',['闯荡']='闯荡:BAABLAAFFH8MAAIXAAIIAQ3HXgBeAAAXAAIIAQ3HXgBeAAAAAA==.',['闹伊']='闹伊做特:BAAALAAFFAIIBAAAAA==.',['闹麻']='闹麻了:BAAALAADCgYIBgAAAA==.',['阝灬']='阝灬傻傻彡:BAABLAAECn8dAAQTAAYIIg8WJwARAQATAAYIIg8WJwARAQASAAUIBQ7lQQDXAAAiAAEIdw1jHwAsAAAAAA==.阝灬熊熊彡:BAABLAAFFH8NAAQcAAMIeRvBCAC4AAAcAAMIeRvBCAC4AAAGAAIImAGeSwBKAAAOAAIIPglLOAA2AAAAAA==.',['阿克']='阿克塞尔:BAAALAADCgEIAQAAAA==.阿克西莫:BAAALAADCgQIBAAAAA==.阿克赛斯:BAAALAADCgQIBAAAAA==.',['阿尔']='阿尔塞斯之女:BAAALAAECgYIEgAAAA==.阿尔塞斯他妹:BAAALAAECgYICAAAAA==.阿尔塞斯他姐:BAAALAAECgYIBwAAAA==.阿尔塞斯他弟:BAAALAAECgYIBgAAAA==.阿尔塞斯他舅:BAAALAAECgYIBgAAAA==.阿尔塞斯姐夫:BAAALAAECgYIBgAAAA==.阿尔塞斯婶婶:BAAALAAECgYIBgAAAA==.阿尔塞斯是他:BAAALAADCgQIBAAAAA==.阿尔塞斯是你:BAAALAAECgMIAwAAAA==.阿尔塞斯是我:BAAALAAECgYIBgAAAA==.阿尔赛斯:BAAALAAECgYICAAAAA==.阿尔达:BAAALAAECgYIBgAAAA==.',['阿恺']='阿恺大帝:BAAALAADCggICgAAAA==.',['阿拉']='阿拉斯加湾:BAABLAAFFH8UAAIJAAYIohZCGwCBAQAJAAYIohZCGwCBAQAAAA==.',['阿瓦']='阿瓦可:BAABLAAECn8VAAMBAAgIaQ69HgAqAQABAAgIaQ69HgAqAQAKAAYISAXXVACwAAAAAA==.',['阿诚']='阿诚哥哥:BAAALAAECgYIDAAAAA==.',['阿鸡']='阿鸡:BAAALAAECgcICwAAAA==.',['陆啦']='陆啦啦辣:BAAALAAFFAIIAgAAAA==.陆啦啦黑黑:BAABLAAFFH8FAAIPAAUIGyD6DADxAQAPAAUIGyD6DADxAQAAAA==.',['陈佳']='陈佳佳:BAABLAAECn8VAAMeAAcIyhkHIgDxAQAeAAcIyhkHIgDxAQAjAAEIBxIzTAA2AAAAAA==.',['雅儿']='雅儿呗德:BAABLAAFFH8GAAMJAAYIRggKGQD5AAAJAAMIAw0KGQD5AAAhAAMIYQfjEQDRAAAAAA==.',['雨若']='雨若夕:BAABLAAFFH8MAAICAAYIGR3lIwCiAQACAAYIGR3lIwCiAQAAAA==.',['雨落']='雨落栀晓:BAAALAADCgEIAQAAAA==.',['雪山']='雪山哥:BAAALAAECgcICwAAAA==.',['雪舞']='雪舞血舞:BAAALAAECgMIBgAAAA==.',['零点']='零点乁枫如歌:BAAALAAECgQIBgAAAA==.',['雾都']='雾都老登:BAAALAAECggIEAAAAA==.',['霄雲']='霄雲:BAAALAAECgIIAgAAAA==.',['霉超']='霉超疯:BAAALAAECgIIAgAAAA==.',['霜花']='霜花丶堕:BAAALAAECgYIBgAAAA==.',['青山']='青山几重:BAABLAAFFH8IAAISAAIITQaSRQBgAAASAAIITQaSRQBgAAAAAA==.',['青春']='青春的大叔:BAAALAAFFAIIAwAAAA==.',['靠近']='靠近靠近:BAAALAAECgYIDAAAAA==.',['颜色']='颜色依旧:BAAALAADCgIIAgAAAA==.颜色颓废:BAAALAADCgEIAQAAAA==.',['风之']='风之猎影:BAAALAAFFAIIBAAAAA==.',['馒头']='馒头灬太硬:BAAALAAECgYIDgAAAA==.',['骑士']='骑士魅影:BAABLAAFFH8MAAIJAAII4h9BLQCvAAAJAAII4h9BLQCvAAABLAAFFAcIKgAOAAQfAA==.',['髅本']='髅本伟:BAABLAAFFH8LAAIMAAQIIBQKLwDdAAAMAAQIIBQKLwDdAAAAAA==.',['魅小']='魅小影:BAABLAAFFH8RAAIHAAUIeRYRLAA2AQAHAAUIeRYRLAA2AQABLAAFFAcIKgAOAAQfAA==.',['魚雷']='魚雷雷:BAABLAAFFH8NAAIGAAIICCWaKQDMAAAGAAIICCWaKQDMAAABLAAFFAMICQAJAAsUAA==.',['鹏亲']='鹏亲亲:BAAALAAECgYIDgAAAA==.',['鹰鹜']='鹰鹜:BAABLAAFFH8MAAMdAAYIThF9BQCcAQAdAAYIQgp9BQCcAQAPAAYIrA4eNgBjAQAAAA==.',['黄仁']='黄仁勋:BAAALAAECgIIBAAAAA==.',['黄泉']='黄泉路维护中:BAAALAAECgUIBQAAAA==.',['黑择']='黑择明:BAAALAAECggICAAAAA==.',['黑白']='黑白颜色:BAAALAADCgQIBAAAAA==.',['龍丶']='龍丶神:BAAALAAECgYICwAAAA==.',['龍之']='龍之嘟少:BAAALAADCgUICQAAAA==.',['龍神']='龍神:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end