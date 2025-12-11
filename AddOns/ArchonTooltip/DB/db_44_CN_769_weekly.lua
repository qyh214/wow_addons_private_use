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
 local lookup = {'Hunter-BeastMastery','Paladin-Retribution','Shaman-Restoration','DemonHunter-Havoc','Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','Warrior-Fury','Priest-Holy','DeathKnight-Blood','DeathKnight-Frost','Druid-Restoration','Mage-Frost','Hunter-Marksmanship','Evoker-Devastation','Rogue-Assassination','Monk-Brewmaster','Paladin-Protection','Mage-Arcane','Shaman-Elemental','Evoker-Preservation','Priest-Discipline','Druid-Balance','DeathKnight-Unholy','Warrior-Melee','Priest-Shadow','Evoker-Augmentation','Mage-Fire','Druid-Guardian','Warrior-Protection','Druid-Feral','Monk-Mistweaver','Paladin-Holy','Rogue-Subtlety','Warrior-Arms','Monk-Windwalker','DeathKnight-Melee','Warlock-Affliction',}; local provider = {region='CN',realm='生态船',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ah='Aheidi:BAAALAAECgYIBwAAAA==.',At='Atom:BAABLAAFFH8GAAIBAAIIGAyBoQA9AAABAAIIGAyBoQA9AAAAAA==.Atticus:BAABLAAFFH8GAAIBAAII6xbviQBIAAABAAII6xbviQBIAAAAAA==.Atyourside:BAACLAAFFH8xAAICAAcI1SACBQA2AgACAAcI1SACBQA2AgAsAAQKfxsAAgIABwiSI5wuALgCAAIABwiSI5wuALgCAAAA.',Cl='Clav:BAABLAAFFH8HAAIDAAIIkQ5RYABbAAADAAIIkQ5RYABbAAAAAA==.',Co='Cowsgirl:BAAALAAFFAMIAwAAAA==.',Da='Dalao:BAAALAADCgcIBwAAAA==.',Dc='Dcgga:BAAALAAFFAQIBAAAAA==.',Dh='Dhqaq:BAABLAAFFH8GAAIEAAYIZBH9HwCBAQAEAAYIZBH9HwCBAQAAAA==.',Do='Dogthing:BAABLAAFFH8ZAAMFAAUI9xiVDQCqAAAGAAUIohggNQA9AQAFAAIIXRmVDQCqAAAAAA==.Douzi:BAAALAAECgYIEAAAAA==.',El='Elegancekill:BAABLAAFFH8NAAIEAAUIvgtIMAAUAQAEAAUIvgtIMAAUAQAAAA==.',Gr='Grave:BAAALAADCgMIAwAAAA==.',Ha='Happybug:BAAALAAECgUIBQAAAA==.',Ho='Hoodrycho:BAAALAADCgUIBQAAAA==.',Hu='Huntme:BAABLAAFFH8FAAIHAAMI0A8cCAC7AAAHAAMI0A8cCAC7AAAAAA==.Huntmedown:BAAALAAFFAIIBAAAAA==.',['Iâ']='Iâhateâyou:BAABLAAFFH8FAAIBAAUIuAduWADpAAABAAUIuAduWADpAAAAAA==.',Ku='Kumomo:BAACLAAFFH8fAAIIAAYI4yJMAgCEAgAIAAYI4yJMAgCEAgAsAAQKfxYAAggACAhZJeILAD0DAAgACAhZJeILAD0DAAEsAAUUCAgKAAkAqxUA.',La='Laevatain:BAAALAAECgEIAQAAAA==.',Lu='Lurifer:BAABLAAFFH8GAAMKAAYIYAD8HgAkAAAKAAQIIwD8HgAkAAALAAII2QCmqwALAAAAAA==.',Mi='Minecrsft:BAABLAAFFH8NAAICAAUIeR0LHwBuAQACAAUIeR0LHwBuAQAAAA==.',Ms='Mslzl:BAAALAADCgEIAQAAAA==.',My='Mythnoir:BAABLAAFFH8GAAMFAAIILxeQEQBJAAAGAAIILxc/OAChAAAFAAEIVBeQEQBJAAAAAA==.',Nt='Nt:BAABLAAFFH8HAAICAAUIkQ0TMgDyAAACAAUIkQ0TMgDyAAAAAA==.',Ol='Oliviaj:BAABLAAFFH8KAAIMAAIIJw00PQBjAAAMAAIIJw00PQBjAAAAAA==.',Pa='Palmuss:BAAALAAECgYICQAAAA==.Pastere:BAAALAADCgUIBQAAAA==.',Pe='Pengyuyan:BAAALAADCgIIAgAAAA==.',Pl='Plato:BAAALAAECgIIAgAAAA==.',Po='Potato:BAABLAAFFH8YAAIEAAgIQSKQAgDYAgAEAAgIQSKQAgDYAgAAAA==.',Qu='Quéeness:BAAALAAFFAUIBAAAAA==.',Re='Remii:BAABLAAFFH8HAAINAAIIMxZHFwBBAAANAAIIMxZHFwBBAAAAAA==.',Sa='Sakura:BAABLAAECn8dAAMBAAgIgBgmOADiAQABAAgIgBgmOADiAQAOAAYItQxLbgARAQAAAA==.',Se='Selene:BAAALAAECgYIBwAAAA==.Serendipity:BAAALAAECgMIBQAAAA==.',Sv='Svagrant:BAAALAAECgQIBAAAAA==.',Th='Thore:BAAALAAECgYIBgAAAA==.',To='Tomrat:BAAALAADCgMIAwAAAA==.',Un='Uncleseen:BAAALAADCgcIBwAAAA==.',Vi='Vicxd:BAAALAAECgYIBgAAAA==.Vitality:BAABLAAFFH8KAAICAAUIjBRbKwAnAQACAAUIjBRbKwAnAQAAAA==.',Vp='Vpoz:BAAALAAECgYICAAAAA==.',Xi='Xiaohei:BAABLAAFFH8GAAIBAAYI6AAtpQA8AAABAAYI6AAtpQA8AAAAAA==.Xiaoji:BAAALAADCgIIAgAAAA==.',Xy='Xyeternal:BAAALAAFFAIIBAAAAA==.',Yi='Yijiandh:BAAALAAECgUICAABLAAFFAgIHwAEAEEkAA==.',['一剑']='一剑孤行:BAAALAADCgEIAQAAAA==.',['一坨']='一坨超人:BAAALAAFFAIIAgAAAA==.',['一片']='一片情天:BAAALAAFFAIIAgAAAA==.',['七秒']='七秒记忆:BAAALAAECgQIBAAAAA==.',['三十']='三十烟波:BAAALAADCgIIAgAAAA==.',['上帝']='上帝牧无语:BAAALAAECgYIBgAAAA==.',['下流']='下流灬:BAAALAAFFAIIBAAAAA==.',['不卡']='不卡不卡:BAAALAAFFAIIAgAAAA==.',['丨十']='丨十灬七丨:BAAALAAFFAIIAgAAAA==.',['丨拾']='丨拾柒丶:BAAALAAECgYIBgAAAA==.',['丨舒']='丨舒克丨:BAABLAAFFH8dAAIBAAYIExzTNQBlAQABAAYIExzTNQBlAQAAAA==.',['丨雷']='丨雷霆丨:BAAALAAECgYIBgAAAA==.',['临时']='临时工丶:BAABLAAFFH8GAAIDAAIINRTcVwBrAAADAAIINRTcVwBrAAAAAA==.临时抱佛脚:BAABLAAFFH8GAAIPAAIIZBSxGgCJAAAPAAIIZBSxGgCJAAAAAA==.',['丶乌']='丶乌勒尔丶:BAAALAAECgIIAgAAAA==.',['丶夜']='丶夜凉如水:BAAALAAFFAIIBAAAAA==.',['丶阿']='丶阿狸:BAAALAAECgQIBAAAAA==.',['丶青']='丶青溟丶:BAAALAAECgMIAwAAAA==.',['九天']='九天境主:BAABLAAFFH8FAAIDAAII7ByKRgCSAAADAAII7ByKRgCSAAAAAA==.',['云彩']='云彩儿:BAABLAAFFH8HAAICAAMIthhdPwCWAAACAAMIthhdPwCWAAAAAA==.',['五十']='五十不惑:BAAALAADCgEIAQAAAA==.',['亡命']='亡命之徒:BAAALAAFFAYIBAAAAA==.',['人家']='人家有伞:BAAALAAFFAIIAgAAAA==.',['人老']='人老手残玩贼:BAABLAAFFH8FAAIQAAIIeAkYGgCXAAAQAAIIeAkYGgCXAAAAAA==.',['仅有']='仅有的姿态:BAAALAAECgMIAQAAAA==.',['他为']='他为我而活:BAAALAAECgYICwAAAA==.',['以太']='以太寻龙:BAAALAAECgYIBgAAAA==.',['伊卡']='伊卡洛斯丶:BAAALAAECgMIAwAAAA==.',['伊甸']='伊甸失落园:BAAALAADCgQIBAAAAA==.',['优然']='优然自德:BAAALAAECgQIBAAAAA==.',['会功']='会功夫的貓:BAAALAAECgYIBgAAAA==.',['传奇']='传奇术:BAAALAADCgQIBAAAAA==.传奇萨:BAAALAADCgIIAgAAAA==.',['伺机']='伺机而动:BAAALAAECgMIBAAAAA==.',['伽罗']='伽罗:BAAALAAFFAIIBAAAAA==.',['你下']='你下错站了:BAABLAAFFH8UAAIBAAYIPRhDMwBuAQABAAYIPRhDMwBuAQABLAAFFAcIOQARANMUAA==.',['依然']='依然执着:BAAALAAECggIBgAAAA==.',['假死']='假死玩的溜啊:BAABLAAECn8UAAIBAAYIVxaKegBRAQABAAYIVxaKegBRAQAAAA==.',['假装']='假装羞怯:BAABLAAFFH8FAAISAAIIBASRIABWAAASAAIIBASRIABWAAAAAA==.',['光丶']='光丶头丨佬:BAAALAAECgEIAQAAAA==.',['光头']='光头吴克:BAAALAAECgIIAgAAAA==.',['光明']='光明归来:BAAALAAECgYIEQAAAA==.',['兜里']='兜里有糖糖:BAAALAAECgYIBgAAAA==.',['全体']='全体萨满:BAAALAAECgYICQAAAA==.',['全团']='全团:BAAALAADCgcIBwAAAA==.',['八二']='八二年的辣条:BAABLAAFFH8SAAIDAAIIvBusQQChAAADAAIIvBusQQChAAAAAA==.八二年的雪碧:BAAALAAECgEIAQAAAA==.',['八佰']='八佰一锤:BAACLAAFFH8QAAICAAUIoR5IIABnAQACAAUIoR5IIABnAQAsAAQKfyEAAgIACAjsI3kPAD4DAAIACAjsI3kPAD4DAAAA.',['六六']='六六酱:BAAALAADCgIIAgAAAA==.',['六发']='六发子弹:BAAALAAECgYIDQAAAA==.',['六号']='六号床的老匡:BAAALAAECgYICgAAAA==.',['兰花']='兰花豆:BAAALAAECgYIBgAAAA==.',['关于']='关于信仰:BAAALAAECgYIDAAAAA==.',['关谷']='关谷神奇丶:BAAALAAECgYIBgAAAA==.',['兵部']='兵部尚书:BAAALAADCgcIBwAAAA==.',['其实']='其实我是杀手:BAAALAADCgYIBgAAAA==.',['再见']='再见钟情:BAAALAAECgYIBgAAAA==.',['冰凛']='冰凛暗月:BAABLAAECn8aAAIJAAcI2yBOIQBxAgAJAAcI2yBOIQBxAgAAAA==.',['冰镇']='冰镇蜂蜜:BAACLAAFFH86AAIBAAgI0x7uBwBlAgABAAgI0x7uBwBlAgAsAAQKfz0AAwEACAhwJTYJAE0DAAEACAhwJTYJAE0DAA4ABQjpGMxfAD8BAAAA.冰镇豆腐:BAAALAADCggICAAAAA==.',['凌一']='凌一国:BAAALAAECgYIBgAAAA==.',['凛霜']='凛霜:BAABLAAFFH8GAAILAAYIKwknRgAhAQALAAYIKwknRgAhAQAAAA==.',['凝影']='凝影丶:BAAALAADCgYIBwAAAA==.',['凯尔']='凯尔提托:BAAALAAFFAIIAgAAAA==.',['创可']='创可贴:BAAALAAECgIIAgAAAA==.',['初九']='初九:BAAALAAECgYIBgAAAA==.',['初夏']='初夏灬:BAAALAAECgIIAgAAAA==.',['利休']='利休白茶:BAAALAAECgQICAAAAA==.',['刹那']='刹那烟云:BAAALAAFFAQIAgAAAA==.',['剑也']='剑也未尝不利:BAAALAADCgMIAwAAAA==.',['功夫']='功夫小猫猫:BAAALAADCgEIAQAAAA==.',['十四']='十四丶白:BAAALAAFFAIIAgAAAA==.',['千古']='千古魔尊:BAACLAAFFH8OAAMTAAIIQAkjWQCHAAATAAIIUAgjWQCHAAANAAEIfwprIQA+AAAsAAQKfxQAAw0ABwgxFBs+AHkBABMABwivD/F/AJIBAA0ABwguERs+AHkBAAAA.',['千斗']='千斗五十铃:BAABLAAFFH8IAAIBAAYIhRxgIwCkAQABAAYIhRxgIwCkAQAAAA==.',['午夜']='午夜幽灵灬:BAAALAADCgYICQAAAA==.',['单车']='单车武士:BAAALAAECgQIBAAAAA==.',['南瓜']='南瓜二米粥:BAACLAAFFH8lAAMGAAgIgx+qBQClAgAGAAgI2h6qBQClAgAFAAUIlSMkAgCLAQAsAAQKfyAAAwUACAjYJWAGAAQDAAUABwhYJmAGAAQDAAYABghZI21CAD8BAAAA.',['南部']='南部之星:BAABLAAECn8XAAILAAcIqBmHcQAUAgALAAcIqBmHcQAUAgABLAAFFAYICAALAGUPAA==.',['卡德']='卡德咖:BAAALAADCgIIAgAAAA==.',['卡拉']='卡拉安:BAAALAADCggICAAAAA==.',['卢克']='卢克西西卡:BAAALAAECgEIAQAAAA==.',['卷了']='卷了个卷:BAAALAAFFAIIAgAAAA==.',['厌食']='厌食症:BAACLAAFFH8xAAIDAAgIPx93AgBAAgADAAgIPx93AgBAAgAsAAQKfx4AAwMABwhBJXofAJYCAAMABwhBJXofAJYCABQAAQigElHKAEMAAAAA.',['収鈊']='収鈊懩性:BAAALAAECgcIEgAAAA==.',['古小']='古小丹:BAABLAAFFH8LAAIFAAII1hQhEwCeAAAFAAII1hQhEwCeAAAAAA==.',['只想']='只想划划氺:BAABLAAFFH8HAAMPAAMIgxJzEQDQAAAPAAMIgxJzEQDQAAAVAAEIwgb9IQArAAABLAAFFAYIJwAOAI0lAA==.',['叮叮']='叮叮猫丶:BAABLAAFFH8KAAMJAAQI4QzfKQCXAAAJAAQI4QzfKQCXAAAWAAEIkw7mBQBGAAABLAAFFAUIDwADADsSAA==.',['吊问']='吊问我:BAAALAAECggICAAAAA==.',['后街']='后街少女:BAABLAAFFH8FAAIHAAMIsQsyDgBaAAAHAAMIsQsyDgBaAAAAAA==.',['君不']='君不涧:BAAALAADCggICAAAAA==.',['呆呆']='呆呆凶:BAAALAAECgYIBgAAAA==.',['呆瓜']='呆瓜小贼:BAAALAAECgYIBwAAAA==.',['呼尼']='呼尼十三章:BAAALAADCgYIBgAAAA==.',['咕咕']='咕咕鸡丶:BAAALAAECgQIBAAAAA==.',['咕哒']='咕哒夫灬:BAAALAADCggICAAAAA==.',['咕灬']='咕灬哒灬子:BAAALAADCgYIBgAAAA==.',['咩团']='咩团紫:BAAALAAECgYIBgAAAA==.',['哥谭']='哥谭噩梦:BAAALAAECgYICQAAAA==.',['唐沢']='唐沢雪穗:BAACLAAFFH8KAAMMAAYIUBDdIgAFAQAMAAMIHSDdIgAFAQAXAAMIjgHqLQBGAAAsAAQKfx0AAgwACAijHZkZAJYCAAwACAijHZkZAJYCAAAA.',['唐泊']='唐泊虎:BAAALAADCgQIBAAAAA==.',['唯乙']='唯乙安:BAABLAAECn8XAAMLAAgI5h10VQBMAgALAAcIvx10VQBMAgAYAAYI+BtBGwDhAQAAAA==.',['喵喵']='喵喵多多:BAAALAAFFAIIAgAAAA==.',['四年']='四年一月:BAAALAAECgUIBQAAAA==.',['回憶']='回憶幸福:BAAALAAFFAIIAgAAAA==.',['回眸']='回眸且如意:BAAALAAECgUICgAAAA==.',['回首']='回首彼岸:BAABLAAFFH8IAAIZAAgIzCMAAAAAAAAIAAgIzCMAAAAAAAAAAA==.',['囧架']='囧架架:BAAALAAECggICAAAAA==.',['国足']='国足团团:BAAALAAECgYIBgAAAA==.',['圆小']='圆小星:BAAALAAECgUIAgAAAA==.',['圣光']='圣光丶之影:BAAALAAECgYIDwAAAA==.圣光小蹄子:BAAALAAECgYIDAAAAA==.',['圣灵']='圣灵之耀:BAABLAAFFH8GAAIMAAYInA+bGgBXAQAMAAYInA+bGgBXAQAAAA==.',['圣羽']='圣羽安歌:BAABLAAFFH8VAAMaAAYIXxSEFAAuAQAaAAUIphCEFAAuAQAJAAMIZhTiJwCbAAAAAA==.',['地底']='地底人:BAAALAAECgYIBgAAAA==.',['地瓜']='地瓜小米汤:BAABLAAFFH8IAAIMAAIIcA9mQgBsAAAMAAIIcA9mQgBsAAAAAA==.',['坠落']='坠落的雨菲:BAAALAADCgIIAgAAAA==.',['夏有']='夏有森光:BAACLAAFFH8JAAMPAAMIkhILEQDVAAAPAAMIkhILEQDVAAAbAAIIKAlrCQCCAAAsAAQKfxQAAg8ACAgSHbYdAC4CAA8ACAgSHbYdAC4CAAAA.',['夕阳']='夕阳舞步:BAABLAAFFH8NAAILAAQImw6SUgDMAAALAAQImw6SUgDMAAAAAA==.',['夜之']='夜之魍魉:BAABLAAFFH8GAAIGAAYIWB5wHACvAQAGAAYIWB5wHACvAQAAAA==.',['大乃']='大乃:BAAALAAFFAIIBAAAAA==.',['大力']='大力欧霸:BAAALAAECgYIBgAAAA==.大力的捏:BAAALAAFFAMIBAAAAA==.',['大可']='大可可朵:BAABLAAFFH8IAAIDAAIIdBjZSgCHAAADAAIIdBjZSgCHAAAAAA==.',['天方']='天方亱譚:BAAALAADCgIIAgAAAA==.天方夜覃:BAABLAAFFH8KAAILAAIIohBwiQBBAAALAAIIohBwiQBBAAAAAA==.天方夜谈:BAACLAAFFH8GAAIIAAIIpgarXgA2AAAIAAIIpgarXgA2AAAsAAQKfxoAAggABgjyDyxSAB8BAAgABgjyDyxSAB8BAAAA.',['天清']='天清色等烟雨:BAAALAAECgQIBAAAAA==.',['天空']='天空的海:BAAALAAECgYIBgAAAA==.',['奇尺']='奇尺大咪:BAAALAAFFAIIAgAAAA==.',['奔波']='奔波儿壩:BAAALAAECgEIAQAAAA==.奔波尔蛋:BAAALAAECgYICgAAAA==.',['奔雷']='奔雷手文泰来:BAABLAAFFH8IAAIcAAQIDAWeBgCsAAAcAAQIDAWeBgCsAAAAAA==.',['奶僧']='奶僧宝宝:BAAALAAECgYIBgAAAA==.',['奶白']='奶白得雪子:BAAALAAECgYIDAAAAA==.',['好个']='好个部落贼:BAAALAAECgYIDAAAAA==.',['如意']='如意合美:BAAALAAECgYIDAAAAA==.',['嫩嫩']='嫩嫩嘚:BAAALAAFFAIIAgAAAA==.',['嬲羊']='嬲羊羊:BAAALAAECgYICgAAAA==.',['孟钰']='孟钰:BAABLAAFFH8GAAIKAAIICw0uHAAwAAAKAAIICw0uHAAwAAAAAA==.',['守护']='守护信仰:BAAALAAFFAIIBAAAAA==.',['安舒']='安舒雅:BAAALAAFFAIIAgAAAA==.',['寂寞']='寂寞之怒:BAAALAAECgYIBgAAAA==.',['寧靜']='寧靜呢:BAACLAAFFH8hAAIMAAgIMRbNCACHAQAMAAgIMRbNCACHAQAsAAQKfx0AAgwACAiiHDciAGMCAAwACAiiHDciAGMCAAAA.',['射到']='射到你崩溃:BAAALAAECgMIAwAAAA==.',['小丸']='小丸犊子:BAAALAAECgEIAQAAAA==.',['小冰']='小冰锥:BAAALAAECgYIBwAAAA==.',['小圆']='小圆只吃不圆:BAAALAAECgYIBwAAAA==.',['小坏']='小坏蛋丶么:BAAALAAECgQIBAAAAA==.',['小学']='小学一年级:BAAALAAECgYIBgAAAA==.',['小小']='小小嘟嘟熊:BAAALAADCggIBgAAAA==.小小怪下士:BAABLAAFFH8IAAICAAIIYQ9ecgA9AAACAAIIYQ9ecgA9AAAAAA==.',['小熊']='小熊快开车:BAAALAAECgYIBgAAAA==.',['小狗']='小狗:BAABLAAFFH8GAAIBAAMImiOWGQA8AQABAAMImiOWGQA8AQAAAA==.',['小脸']='小脸红扑扑丶:BAAALAAFFAIIBAAAAA==.',['小萨']='小萨快跑:BAAALAAECgYICQAAAA==.',['小鱼']='小鱼很忙:BAABLAAFFH8HAAIIAAIIZR3MJQCuAAAIAAIIZR3MJQCuAAAAAA==.',['尖尖']='尖尖角:BAAALAAECgQIBAAAAA==.',['尘事']='尘事美:BAAALAAFFAIIAgAAAA==.',['尛尛']='尛尛鳄魚:BAAALAAFFAMIAgAAAA==.',['尼古']='尼古拉斯德:BAAALAAECgYIBgAAAA==.尼古拉斯歪歪:BAAALAAECggICAAAAA==.',['尼弥']='尼弥西斯:BAAALAAECgUICAAAAA==.',['尽快']='尽快初始登记:BAAALAADCgcIBwAAAA==.',['尾莺']='尾莺一流:BAAALAADCgcIDgAAAA==.',['尿玉']='尿玉昆:BAABLAAFFH8GAAIQAAYIZQeyEgDMAAAQAAYIZQeyEgDMAAAAAA==.',['屁桃']='屁桃:BAABLAAFFH8GAAIBAAYIFB4RLwB7AQABAAYIFB4RLwB7AQAAAA==.',['岩井']='岩井茶:BAAALAAFFAIIBAAAAA==.',['峰仙']='峰仙人:BAAALAAFFAIIAgAAAA==.',['巴掌']='巴掌扇灰机:BAAALAAECgEIAQAAAA==.',['希厼']='希厼瓦纳斯:BAACLAAFFH8GAAMBAAMIfRoFJwDgAAABAAMIfRoFJwDgAAAOAAEIIwYFOQAzAAAsAAQKfxkAAwEABgixIys+ANEBAAEABgixIys+ANEBAA4ABAgVE6eAANoAAAAA.',['幽兰']='幽兰酱:BAABLAAFFH8VAAICAAYI/RzXDgDOAQACAAYI/RzXDgDOAQAAAA==.',['幽冥']='幽冥鬼主:BAABLAAECn8WAAMFAAYIQA+rSABOAQAGAAYIFw5tlQBSAQAFAAYISQurSABOAQAAAA==.',['库尔']='库尔提拉:BAAALAAECgYIBwAAAA==.',['库洛']='库洛艾:BAACLAAFFH8GAAILAAIIaxtfWgCbAAALAAIIaxtfWgCbAAAsAAQKfxgAAgsABggXIBM1AKQBAAsABggXIBM1AKQBAAAA.',['开始']='开始杀:BAAALAAECgMIAwAAAA==.',['强尼']='强尼:BAAALAAFFAMIAwAAAA==.',['当心']='当心你的包包:BAAALAAECgIIAgAAAA==.',['彩色']='彩色钥匙:BAAALAAECgQIBAAAAA==.',['影子']='影子猎手:BAAALAAECgYICAAAAA==.',['徒手']='徒手接白刃:BAAALAAECgEIAQAAAA==.',['得了']='得了吧你:BAABLAAFFH8GAAIdAAIICAWkCwBVAAAdAAIICAWkCwBVAAAAAA==.',['御姐']='御姐好风骚:BAABLAAFFH8KAAIBAAYI9g6+RAA2AQABAAYI9g6+RAA2AQAAAA==.',['快樂']='快樂的四柱香:BAAALAADCgIIAgAAAA==.',['怀念']='怀念:BAAALAAECgYIBgAAAA==.',['怎么']='怎么没刀了:BAAALAADCgMIAQAAAA==.',['性大']='性大汉:BAABLAAECn8UAAMIAAgIshxjFgAuAgAIAAgIjBxjFgAuAgAeAAQIbxZ9NwC4AAAAAA==.',['悠然']='悠然自德:BAAALAADCgMIAwAAAA==.',['惜若']='惜若水:BAAALAAECgYIEAAAAA==.',['意大']='意大利面:BAAALAAFFAIIAgAAAA==.',['意难']='意难平:BAAALAAFFAgIBAAAAA==.',['愿风']='愿风指引着你:BAAALAAECgYIBgAAAA==.',['慧能']='慧能:BAAALAAECgYIDAAAAA==.',['戏月']='戏月:BAAALAAFFAIIBAAAAA==.',['我不']='我不要你懂丶:BAABLAAFFH8GAAMNAAIIehVdEACOAAANAAIIehVdEACOAAATAAIIMQq5VQCLAAAAAA==.',['我为']='我为峰:BAAALAADCgYIBgAAAA==.',['我会']='我会出手丶:BAAALAAECgYIDQAAAA==.',['我哥']='我哥是肝帝:BAAALAAECgEIAQAAAA==.',['我躲']='我躲进風里:BAAALAAECgYIBgAAAA==.',['战嘤']='战嘤嘤:BAABLAAECn8UAAIIAAcIMR0tPABEAgAIAAcIMR0tPABEAgAAAA==.',['战时']='战时开怪:BAAALAAECgEIAQAAAA==.',['戰小']='戰小涛:BAABLAAFFH8FAAIIAAMILAdGQgBTAAAIAAMILAdGQgBTAAAAAA==.',['托比']='托比昂:BAAALAAECgYIBgAAAA==.',['抗怪']='抗怪的钢镚:BAAALAAECgYIBgAAAA==.',['抱抱']='抱抱弟弟:BAAALAAECggICQAAAA==.',['拉你']='拉你过来:BAAALAADCgMIAwAAAA==.',['拉布']='拉布布:BAAALAADCgIIAgAAAA==.',['拔个']='拔个垂杨柳:BAABLAAFFH8GAAIHAAII/gZOGQBRAAAHAAII/gZOGQBRAAAAAA==.',['招财']='招财进靌:BAAALAAECgEIAQAAAA==.',['按黑']='按黑箭很难吗:BAABLAAFFH8GAAIBAAYI4BQCNgBlAQABAAYI4BQCNgBlAQAAAA==.',['振衣']='振衣乘风:BAAALAADCgEIAQAAAA==.',['搞色']='搞色特弄:BAAALAAECgUIBQAAAA==.',['摸鱼']='摸鱼大王:BAACLAAFFH8OAAIIAAUIixu/IgBXAQAIAAUIixu/IgBXAQAsAAQKfygAAggACAhIId4MAI0CAAgACAhIId4MAI0CAAAA.',['撒有']='撒有嘛达:BAAALAAFFAMIAgAAAA==.',['撒蛮']='撒蛮:BAAALAAECgQIBgAAAA==.',['整不']='整不好啊:BAAALAADCgIIAgAAAA==.',['斗转']='斗转星不移:BAAALAAECgQIBAAAAA==.',['斩个']='斩个痛快:BAABLAAFFH8VAAIIAAYIDxJ7HQB9AQAIAAYIDxJ7HQB9AQAAAA==.',['新手']='新手丶小白:BAABLAAFFH8GAAIMAAYIoAAkGADBAAAMAAYIoAAkGADBAAAAAA==.',['新条']='新条茜:BAAALAAECgIIAgAAAA==.',['无敌']='无敌大军:BAAALAADCgQIBAAAAA==.',['无路']='无路塞:BAAALAAECgYIBwAAAA==.',['早蕨']='早蕨之舞:BAABLAAFFH8HAAICAAUIqwUeNQDYAAACAAUIqwUeNQDYAAAAAA==.',['晴岚']='晴岚小涛:BAACLAAFFH8OAAIDAAYIKxWGFwChAQADAAYIKxWGFwChAQAsAAQKfx4AAgMACAg5D/iCAHoBAAMACAg5D/iCAHoBAAEsAAUUBggiAAwA7hcA.',['暗夜']='暗夜灬:BAABLAAFFH8KAAILAAIIqxMHdwBKAAALAAIIqxMHdwBKAAAAAA==.',['曉濤']='曉濤:BAACLAAFFH8iAAMMAAYI7hd/EAC/AQAMAAYI7hd/EAC/AQAXAAIIxAnkNwA3AAAsAAQKfxgAAgwACAhPFEtMALQBAAwACAhPFEtMALQBAAAA.',['月与']='月与海丶:BAAALAADCgYIBgAAAA==.',['月祭']='月祭挽歌:BAABLAAFFH8IAAIaAAII0wySKABFAAAaAAII0wySKABFAAAAAA==.',['望舒']='望舒:BAAALAAECgYICwAAAA==.',['木青']='木青:BAABLAAFFH8aAAICAAUI9CFbGwCBAQACAAUI9CFbGwCBAQAAAA==.木青儿:BAABLAAFFH8RAAIDAAMIyBZhNgDKAAADAAMIyBZhNgDKAAAAAA==.',['末日']='末日之枫:BAABLAAFFH8KAAINAAIIjRUBGgA8AAANAAIIjRUBGgA8AAAAAA==.',['本宫']='本宫本宫:BAAALAAFFAIIAgAAAA==.',['朴朴']='朴朴乐:BAAALAAECgYIBgAAAA==.',['机械']='机械凋零:BAABLAAECn8gAAMKAAgIGRQ4DQCoAQAKAAgIGRQ4DQCoAQALAAQIwAgWvABlAAAAAA==.',['杀破']='杀破狼灬隐:BAAALAAECgYIBgAAAA==.',['李梁']='李梁斌:BAAALAAFFAIIBAABLAAFFAUIBwABAJsdAA==.',['林木']='林木秀:BAACLAAFFH8cAAMMAAUIAxP2GgBUAQAMAAUIAxP2GgBUAQAXAAEI8ASuOgAyAAAsAAQKf0UABQwACAjqHcsNAHUCAAwACAjqHcsNAHUCABcACAhlElM7AMkBAB8ABghWCDgXAM4AAB0AAQi8B+0rAB8AAAAA.',['枫林']='枫林晚来:BAAALAADCgYIBgAAAA==.',['枫翔']='枫翔之泪:BAAALAAECgYICgAAAA==.',['柚子']='柚子:BAAALAAFFAIIBAAAAA==.',['柳叶']='柳叶纷飞:BAABLAAFFH8IAAIgAAIISA3wFQBrAAAgAAIISA3wFQBrAAAAAA==.',['格德']='格德斯:BAAALAAECgYIDAAAAA==.',['桀驁']='桀驁小涛:BAABLAAFFH8XAAMCAAYIjhVSKAA4AQACAAUI2xNSKAA4AQAhAAMIZggdIgCCAAABLAAFFAYIIgAMAO4XAA==.',['桃子']='桃子上的血:BAABLAAECn8hAAINAAgIyBh0DAD1AQANAAgIyBh0DAD1AQAAAA==.',['梦寒']='梦寒雪:BAAALAADCgMIAwAAAA==.',['棍儿']='棍儿哥:BAABLAAFFH8GAAMQAAYIxBwUBQCJAQAQAAQI/BsUBQCJAQAiAAIIUh64DQC0AAAAAA==.',['森林']='森林迷惑:BAABLAAECn8YAAIBAAcITArW9gA6AQABAAcITArW9gA6AQAAAA==.',['次奥']='次奥次奥草:BAAALAAECgQIBAAAAA==.',['欢迎']='欢迎光临:BAAALAADCgEIAQAAAA==.',['欧式']='欧式的疯狂:BAAALAADCgIIAgAAAA==.',['欺诈']='欺诈魔心:BAABLAAFFH8GAAIMAAYIqBAQGwBTAQAMAAYIqBAQGwBTAQAAAA==.',['歌德']='歌德丶沃特:BAAALAAECgQIBAAAAA==.',['正义']='正义之剑:BAAALAADCgEIAQAAAA==.',['武闯']='武闯:BAAALAAECgIIAgAAAA==.',['歪丫']='歪丫女:BAAALAAECgYIBgAAAA==.',['歪歪']='歪歪女:BAABLAAFFH8gAAICAAYI+x5SDwDKAQACAAYI+x5SDwDKAQAAAA==.',['歪牛']='歪牛:BAAALAADCgYIBgAAAA==.',['死亡']='死亡的终结:BAABLAAFFH8LAAILAAMIKhkaPwC0AAALAAMIKhkaPwC0AAAAAA==.',['残魂']='残魂断:BAAALAAECgYIDwAAAA==.',['水四']='水四号:BAABLAAFFH8OAAIEAAYIIhH1CQABAgAEAAYIIhH1CQABAgAAAA==.',['水树']='水树奈奈桑:BAAALAADCgcICAAAAA==.',['没有']='没有那么简单:BAAALAAFFAIIAgAAAA==.',['法力']='法力无心:BAAALAADCggICAAAAA==.',['法国']='法国队风格:BAAALAADCgQIBAAAAA==.',['泰蘭']='泰蘭德尐妹:BAAALAAECgMIAwAAAA==.',['泽天']='泽天:BAAALAAECgIIAgAAAA==.',['洋芋']='洋芋粑:BAABLAAFFH8GAAIGAAIISQniYwA8AAAGAAIISQniYwA8AAAAAA==.',['流星']='流星:BAAALAAECgIIAgAAAA==.',['浑元']='浑元接化发:BAAALAAECgYIBgAAAA==.',['消炎']='消炎止咳:BAAALAAECgQIBAAAAA==.',['涝汁']='涝汁笋尖:BAAALAAECgMIAwAAAA==.',['淡定']='淡定的麦兜:BAABLAAECn8XAAMIAAYIcB52RQAiAgAIAAYIcB52RQAiAgAjAAQIUxXNIQD+AAAAAA==.',['淡水']='淡水捌度:BAABLAAFFH8KAAIDAAII2RngNgCTAAADAAII2RngNgCTAAAAAA==.',['清风']='清风微拂:BAAALAADCgYIBgAAAA==.',['湿灬']='湿灬哥:BAAALAADCgUIBQAAAA==.',['潛水']='潛水艇:BAAALAAECgYIBgAAAA==.',['火雨']='火雨法:BAABLAAFFH8IAAIGAAYIwhQ7IwCOAQAGAAYIwhQ7IwCOAQAAAA==.',['灬小']='灬小小百合灬:BAABLAAFFH8GAAILAAYIWQFfUwDFAAALAAYIWQFfUwDFAAAAAA==.',['灵魂']='灵魂舞动:BAABLAAFFH8YAAMUAAYILg8zJQAcAQAUAAUIrA4zJQAcAQADAAUIwBDNLAACAQAAAA==.',['灼热']='灼热凶器:BAABLAAECn8UAAIeAAYInhyjLQDgAQAeAAYInhyjLQDgAQAAAA==.',['灿灿']='灿灿:BAAALAAECgYIBgAAAA==.',['点点']='点点滴滴不能:BAAALAADCgYIBgAAAA==.',['為你']='為你瘋颠:BAABLAAFFH8GAAIQAAIIFgW4HQBAAAAQAAIIFgW4HQBAAAAAAA==.',['烈火']='烈火撒尔:BAAALAAECgUIBQAAAA==.烈火烈火:BAAALAAECgYICgAAAA==.',['烟徐']='烟徐往诗思琪:BAAALAADCgQIBAAAAA==.',['烟烟']='烟烟罗:BAAALAAECgYICQAAAA==.',['無双']='無双小涛:BAABLAAFFH8OAAIBAAYIFQ4CPgBNAQABAAYIFQ4CPgBNAQAAAA==.',['煎饼']='煎饼果子丶:BAAALAAECgMIAwAAAA==.',['燃烧']='燃烧重生:BAAALAAECgMIAwAAAA==.',['燃爆']='燃爆混沌:BAAALAAECgQIBAAAAA==.',['爱吃']='爱吃爆米花:BAABLAAFFH8PAAICAAMIgBRYRwB9AAACAAMIgBRYRwB9AAAAAA==.',['爱随']='爱随风逝:BAAALAAECgUIDAAAAA==.',['爸比']='爸比二代:BAAALAAFFAIIAgAAAA==.',['牙咩']='牙咩呆:BAAALAADCgMIAwABLAAFFAgIEQAJAEQaAA==.',['牛哥']='牛哥:BAAALAAECggICAAAAA==.',['牛菠']='牛菠一:BAABLAAFFH8GAAMYAAIIOyMjDwCeAAAYAAIIYxkjDwCeAAALAAIIOyMmawBmAAAAAA==.',['牛鞭']='牛鞭撕裂者:BAAALAAECgYIDAAAAA==.',['狐图']='狐图图:BAAALAAECgUICQAAAA==.',['狗蛋']='狗蛋大师:BAAALAADCggICAABLAAFFAYIIwAQAMgaAA==.',['狼牙']='狼牙牙:BAAALAAECgcIDAAAAA==.',['猛大']='猛大帅灬:BAAALAAECgUIBQAAAA==.',['猪儿']='猪儿虫丶:BAACLAAFFH8cAAMMAAYISRzhBgC0AQAMAAYISRzhBgC0AQAXAAIIkQmnIwCCAAAsAAQKfywAAxcABgjjIeYlADoCABcABgjjIeYlADoCAAwABgjwIWUqADoCAAAA.',['猫的']='猫的:BAAALAAECgIIAgAAAA==.',['猿猱']='猿猱愁度:BAABLAAFFH8OAAIEAAYItw0tJQBkAQAEAAYItw0tJQBkAQAAAA==.',['王大']='王大福:BAABLAAFFH8IAAIDAAIIFguMZgBUAAADAAIIFguMZgBUAAAAAA==.',['王淑']='王淑芬:BAAALAAECgQIBAAAAA==.',['玖月']='玖月十三:BAAALAADCgUIBQAAAA==.',['玖贰']='玖贰:BAABLAAFFH8FAAILAAIIXBEgmQA6AAALAAIIXBEgmQA6AAAAAA==.',['珍妮']='珍妮的日记:BAAALAAECgIIAgAAAA==.',['瑶池']='瑶池醉酒:BAAALAAFFAIIBAAAAA==.',['瓔珞']='瓔珞小涛:BAABLAAFFH8JAAITAAYIkQs+LQBYAQATAAYIkQs+LQBYAQAAAA==.',['生吃']='生吃榴莲壳:BAAALAAECgUIBQAAAA==.',['用芯']='用芯良苦:BAAALAAECgQIBAAAAA==.',['畏不']='畏不可攀:BAABLAAFFH8LAAIEAAYIjRTgHgCHAQAEAAYIjRTgHgCHAQAAAA==.',['疯虎']='疯虎:BAAALAAECgYIDAAAAA==.',['白银']='白银之月:BAAALAAECgYIBgAAAA==.',['百老']='百老汇丶八戒:BAAALAADCgYIBgAAAA==.',['皛胖']='皛胖尔:BAAALAAFFAIIAgAAAA==.',['看你']='看你双眼冒光:BAAALAADCgQIBAAAAA==.',['真新']='真新镇的小智:BAAALAAFFAIIAgAAAA==.',['破邪']='破邪丶刀杀:BAAALAAECgIIAgAAAA==.',['神秘']='神秘:BAAALAAFFAIIAgAAAA==.',['神隐']='神隐藏的少女:BAABLAAFFH8MAAIIAAQI1hbxNQCaAAAIAAQI1hbxNQCaAAAAAA==.',['神龙']='神龙斗士:BAAALAAECgEIAgAAAA==.',['秀神']='秀神:BAAALAAFFAIIBAAAAA==.',['秋叶']='秋叶无边:BAAALAAECgUIBQAAAA==.',['科恩']='科恩丶:BAABLAAFFH8NAAIQAAgI/iFdAAD7AgAQAAgI/iFdAAD7AgAAAA==.',['突然']='突然灬你姐:BAAALAAFFAYIBAAAAA==.',['笑里']='笑里不藏刀:BAACLAAFFH8gAAMFAAUIWxRECgB3AAAGAAUIhRHbOQAjAQAFAAMI7BVECgB3AAAsAAQKfxsAAwUABwjeHm4OAIABAAUABghMHm4OAIABAAYABQh6F92QAFwBAAAA.',['第一']='第一丶坑神:BAAALAAECggIEAAAAA==.',['筒子']='筒子哥:BAAALAAECggICAAAAA==.',['糖门']='糖门门主:BAABLAAFFH8LAAIGAAUIlw4rOgAhAQAGAAUIlw4rOgAhAQAAAA==.',['糯香']='糯香柠檬茶:BAABLAAFFH8MAAIMAAIIQBh+OgCDAAAMAAIIQBh+OgCDAAABLAAFFAYIFAAVAP8NAA==.',['紫苓']='紫苓哟:BAABLAAECn8UAAINAAYIRxSJPQB8AQANAAYIRxSJPQB8AQAAAA==.',['紫血']='紫血战神:BAAALAADCgYIBgAAAA==.',['红色']='红色火龙:BAAALAAFFAIIAwAAAA==.',['红豆']='红豆很忙:BAABLAAECn8WAAMNAAYIMRZuTQA8AQANAAYIMRZuTQA8AQATAAYI9wuIpQA7AQAAAA==.',['纯真']='纯真男孩:BAAALAAECgYIDAAAAA==.',['绛紫']='绛紫小涛:BAABLAAFFH8MAAIEAAYIIw6ZIwBtAQAEAAYIIw6ZIwBtAQAAAA==.',['继清']='继清桀如新生:BAAALAAFFAMIAwAAAA==.',['缘灭']='缘灭缘生:BAAALAADCgQIBAAAAA==.',['美丽']='美丽发生:BAABLAAFFH8FAAISAAIIORABHAAzAAASAAIIORABHAAzAAAAAA==.',['美年']='美年达丶:BAAALAAECgQIBAAAAA==.',['肥嘟']='肥嘟嘟左卫门:BAAALAAECgYIDQAAAA==.',['胖胖']='胖胖嘚:BAAALAAECgUIBQAAAA==.',['胡多']='胡多多:BAABLAAFFH8FAAIHAAMIbgdbDACRAAAHAAMIbgdbDACRAAAAAA==.',['胸口']='胸口卄碎大石:BAAALAAECgYICAAAAA==.胸口碎大饼:BAAALAAECgEIAQAAAA==.',['脑浆']='脑浆炸裂少女:BAACLAAFFH8kAAIJAAYIBCHfDAAAAgAJAAYIBCHfDAAAAgAsAAQKfx4AAgkACAjVGmYlAFkCAAkACAjVGmYlAFkCAAEsAAUUCAhPAAkAQyMA.',['舞双']='舞双刀的老妖:BAAALAAFFAIIAgAAAA==.',['舞娅']='舞娅儿:BAABLAAFFH8ZAAIJAAUI3AZtIAC8AAAJAAUI3AZtIAC8AAAAAA==.',['舞轻']='舞轻扬:BAAALAADCgQIBAAAAA==.',['航航']='航航不听话:BAAALAAECgIIAgAAAA==.',['艾仒']='艾仒米:BAABLAAFFH8JAAIgAAIILgzBEwB/AAAgAAIILgzBEwB/AAAAAA==.',['艾利']='艾利乌德:BAAALAADCgQIEAAAAA==.',['艾欧']='艾欧尼亚的:BAAALAAECgIIAgAAAA==.',['芙萝']='芙萝娅:BAAALAADCgEIAQAAAA==.',['花容']='花容:BAAALAADCgYIBgAAAA==.',['花花']='花花华:BAAALAAECggICAAAAA==.',['若芷']='若芷幽兰丶:BAAALAADCggICAAAAA==.',['苦集']='苦集滅道:BAAALAAFFAIIAgAAAA==.苦集灭道:BAAALAAECgYIEAAAAA==.',['范晓']='范晓萱:BAAALAAECgMIAwAAAA==.',['茶小']='茶小涛:BAABLAAFFH8IAAMkAAYINAi3CgAxAQAkAAYINAi3CgAxAQARAAIISgJTJAAfAAABLAAFFAYIIgAMAO4XAA==.',['荼蘼']='荼蘼小涛:BAABLAAFFH8hAAIJAAYIxg8DGQDiAAAJAAYIxg8DGQDiAAABLAAFFAYIIgAMAO4XAA==.',['莉芙']='莉芙娅:BAAALAAFFAIIAgAAAA==.',['莪彵']='莪彵朩倁檤:BAAALAAECgYICwAAAA==.',['莫里']='莫里亚:BAABLAAFFH8IAAIGAAIImxlmOQCfAAAGAAIImxlmOQCfAAAAAA==.',['萌小']='萌小曼:BAAALAAECgIIAgAAAA==.',['萧萧']='萧萧暗影:BAABLAAFFH8RAAIGAAUIpBgDNQA+AQAGAAUIpBgDNQA+AQAAAA==.',['萨满']='萨满很忙:BAABLAAFFH8MAAIDAAYItwlpOwCKAAADAAYItwlpOwCKAAAAAA==.',['葬小']='葬小涛:BAABLAAFFH8PAAIGAAYIwhElLABqAQAGAAYIwhElLABqAQABLAAFFAYIIgAMAO4XAA==.',['薄荷']='薄荷伏特加:BAAALAAECgIIAgAAAA==.薄荷撞可乐:BAAALAAECgYICAAAAA==.薄荷红茶:BAAALAAECgIIAgAAAA==.',['藏元']='藏元汉:BAAALAAFFAEIAQAAAA==.',['蘸点']='蘸点甜妹酱:BAAALAAECgcIEQAAAA==.',['虫虫']='虫虫児:BAAALAAECgYIBgAAAA==.',['蛋优']='蛋优:BAAALAAECgUIBQAAAA==.',['蜘蛛']='蜘蛛奇士:BAABLAAFFH8IAAIRAAII7wJAHgBEAAARAAII7wJAHgBEAAAAAA==.蜘蛛恶魔:BAAALAAFFAIIAgAAAA==.',['蜜蜂']='蜜蜂终结者:BAAALAAECgYIEgAAAA==.',['血蚀']='血蚀:BAAALAAECgUIBQAAAA==.',['西瓜']='西瓜的大宝贝:BAAALAAECgYIEwAAAA==.',['讲丶']='讲丶者:BAABLAAECn8WAAIJAAcIpRNnLQBPAQAJAAcIpRNnLQBPAQAAAA==.',['请输']='请输入:BAAALAADCgYIBgAAAA==.',['诺贝']='诺贝尔可爱奖:BAAALAAFFAIIAwAAAA==.',['赤伶']='赤伶:BAABLAAFFH8GAAIBAAIIphGiVACTAAABAAIIphGiVACTAAAAAA==.',['赤松']='赤松:BAAALAADCgMIAwAAAA==.',['赤羽']='赤羽:BAAALAADCgYIBgAAAA==.',['超强']='超强小龙人:BAAALAAECggIEQAAAA==.',['超能']='超能骑士:BAAALAAECgYICgAAAA==.',['路由']='路由器:BAAALAAECggICAAAAA==.',['蹦迪']='蹦迪小满满:BAABLAAFFH8GAAIDAAIIhBXdQACAAAADAAIIhBXdQACAAAAAAA==.',['辰光']='辰光风影:BAAALAAECgYIDgAAAA==.',['边竹']='边竹:BAABLAAFFH8GAAIBAAIICRBgjgBGAAABAAIICRBgjgBGAAAAAA==.',['远若']='远若止水:BAAALAAECgYIEAAAAA==.',['迪迦']='迪迦嗷特曼:BAAALAADCgIIAgAAAA==.',['迷失']='迷失森林:BAABLAAFFH8FAAINAAMIUgWSEQBUAAANAAMIUgWSEQBUAAAAAA==.',['迷途']='迷途丶:BAAALAAECgYIBgAAAA==.',['遥看']='遥看青山依旧:BAAALAADCgUIBQAAAA==.',['那一']='那一炮的温柔:BAAALAAFFAIIAgAAAA==.',['邪小']='邪小涛:BAABLAAFFH8IAAILAAYIwAwGNQBoAQALAAYIwAwGNQBoAQABLAAFFAYIIgAMAO4XAA==.',['酷尔']='酷尔提拉斯:BAAALAAECgYIEgAAAA==.',['酸萝']='酸萝卜别吃:BAABLAAFFH8WAAILAAUIWBzKMwBsAQALAAUIWBzKMwBsAQAAAA==.',['鉨为']='鉨为我而活:BAAALAAFFAIIAgAAAA==.',['钢琴']='钢琴里的猫:BAABLAAFFH8JAAIaAAgIbRwYAwBtAgAaAAgIbRwYAwBtAgAAAA==.',['银笺']='银笺别梦:BAAALAAECggIEQAAAA==.',['镇魂']='镇魂灬撇:BAABLAAFFH8GAAIlAAYIvhIAAAAAAAALAAYIvhIAAAAAAAAAAA==.',['镜华']='镜华:BAACLAAFFH8wAAIGAAYIIiAlGwC2AQAGAAYIIiAlGwC2AQAsAAQKfzoAAwYACAj0I/IJAEkDAAYACAj0I/IJAEkDACYABgi6II4DANMBAAAA.',['闪电']='闪电疯子:BAAALAAECgEIAQAAAA==.',['问何']='问何时还:BAABLAAFFH8SAAIEAAYIQRiPGwCYAQAEAAYIQRiPGwCYAQAAAA==.',['阴险']='阴险的部落猪:BAAALAAECggICAAAAA==.',['阿丽']='阿丽塔:BAAALAAECgYIDwAAAA==.',['阿克']='阿克灬蒙德:BAAALAAFFAIIAgAAAA==.',['阿历']='阿历克斯滚筒:BAAALAAECgYIDAAAAA==.',['阿斯']='阿斯迪纳:BAAALAAECgQIAgAAAA==.',['阿离']='阿离:BAAALAAECgYIDgAAAA==.',['雨师']='雨师妾:BAAALAAECgIIAgAAAA==.',['雨木']='雨木:BAAALAAECgUICAAAAA==.',['雨纷']='雨纷纷:BAAALAAECgYICAAAAA==.',['零柒']='零柒叁陆:BAAALAAECgYIBgAAAA==.',['雷电']='雷电将军:BAABLAAFFH8JAAIeAAMIdQqZEwCzAAAeAAMIdQqZEwCzAAAAAA==.',['雷诺']='雷诺丶杰克逊:BAAALAAECgIIAgAAAA==.',['霸道']='霸道的葡萄:BAAALAAECgYIDgAAAA==.',['青春']='青春微微:BAAALAAECgYICwAAAA==.',['青梅']='青梅怀袖:BAABLAAFFH8NAAILAAMIuxraWACgAAALAAMIuxraWACgAAAAAA==.',['青藤']='青藤茶:BAAALAAECgIIAgAAAA==.',['非常']='非常高端娴熟:BAAALAAECgYIDAAAAA==.',['頑皮']='頑皮西米露:BAAALAAECgYIDwAAAA==.',['風之']='風之哀伤:BAAALAAECggICAAAAA==.',['风一']='风一般的棉拖:BAAALAAECgQIBAAAAA==.',['风中']='风中的鱼:BAAALAAECgUIBwAAAA==.',['风云']='风云再起兮:BAAALAAECgYICAAAAA==.',['风情']='风情豆:BAAALAAECgQIBQAAAA==.',['风逍']='风逍遥:BAAALAADCgcIBwAAAA==.',['风驰']='风驰天下:BAAALAAECgYIBQAAAA==.',['飞华']='飞华:BAAALAADCgYIBgAAAA==.飞华丨安然:BAAALAADCggICQAAAA==.飞华逐月:BAAALAADCggICAAAAA==.',['香蕉']='香蕉水:BAAALAAECgYIEAAAAA==.',['马克']='马克狼人:BAABLAAFFH8IAAIeAAIIigF2OwAXAAAeAAIIigF2OwAXAAAAAA==.',['骑猪']='骑猪看风景:BAABLAAECn8XAAICAAgI0BR9dgD9AQACAAgI0BR9dgD9AQAAAA==.',['魔惑']='魔惑:BAAALAAECgYIBgAAAA==.',['魔神']='魔神思密达:BAAALAAFFAEIAQABLAAFFAUIIAAFAFsUAA==.',['鱼传']='鱼传尺素丶:BAABLAAFFH8LAAMTAAIIZhxKOQCpAAATAAIIZhxKOQCpAAANAAEIvBlDHgBJAAAAAA==.',['鱼泪']='鱼泪满江:BAABLAAFFH8IAAIhAAII9A3RHgCLAAAhAAII9A3RHgCLAAAAAA==.',['鲜肉']='鲜肉月饼:BAABLAAFFH8JAAICAAIIfxIRYwBFAAACAAIIfxIRYwBFAAAAAA==.',['鸭蛋']='鸭蛋超人:BAAALAADCgMIAwAAAA==.',['麻辣']='麻辣小龙虾:BAABLAAFFH8GAAIIAAIIeg0MUwBCAAAIAAIIeg0MUwBCAAAAAA==.',['黑灵']='黑灵:BAAALAAECgUIBQAAAA==.',['黯小']='黯小涛:BAABLAAFFH8GAAMQAAYIbwjwDQAtAQAQAAUIYwnwDQAtAQAiAAEIpwOKFwA5AAAAAA==.',['龍小']='龍小涛:BAABLAAFFH8TAAIVAAYIxgVuEAAlAQAVAAYIxgVuEAAlAQABLAAFFAYIIgAMAO4XAA==.',['龙利']='龙利马:BAAALAAFFAUIBAAAAA==.',['龙魂']='龙魂改:BAAALAAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end