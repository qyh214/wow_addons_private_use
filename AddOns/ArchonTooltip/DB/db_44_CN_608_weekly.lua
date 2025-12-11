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
 local lookup = {'Mage-Arcane','Mage-Frost','Druid-Restoration','Priest-Holy','DemonHunter-Havoc','DeathKnight-Frost','Hunter-BeastMastery','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Druid-Balance','Unknown-Unknown','Priest-Shadow','Paladin-Protection','Paladin-Retribution','DeathKnight-Blood','Monk-Windwalker','Warrior-Fury','Warrior-Arms','DemonHunter-Vengeance','Warrior-Protection','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Rogue-Subtlety','Rogue-Outlaw','Shaman-Enhancement','Evoker-Preservation','Evoker-Devastation','Paladin-Holy','Hunter-Marksmanship','Monk-Brewmaster','Warlock-Affliction','Monk-Mistweaver','Druid-Guardian','Druid-Feral',}; local provider = {region='CN',realm='哈卡',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Archmageman:BAAALAADCgcIBwAAAA==.Aries:BAAALAAFFAMIAQAAAA==.',Au='Autoback:BAABLAAFFH8IAAMBAAYIdx89BgBGAgABAAYIdx89BgBGAgACAAIIZw3nFACDAAABLAAFFAgIFAADAK4LAA==.Autocad:BAABLAAFFH8IAAIEAAYIxRejFgCdAQAEAAYIxRejFgCdAQABLAAFFAgIFAADAK4LAA==.Autodesk:BAABLAAFFH8TAAIFAAgIjRz1BACTAgAFAAgIjRz1BACTAgABLAAFFAgIFAADAK4LAA==.',Co='Collector:BAAALAADCggICAAAAA==.',Da='Darkseid:BAAALAAECgYIDAAAAA==.',De='Desolater:BAAALAAECgYIBgAAAA==.Devilbring:BAAALAAECgEIAQAAAA==.',Do='Donkey:BAACLAAFFH81AAIGAAcIlSLfCQBdAgAGAAcIlSLfCQBdAgAsAAQKfzwAAgYACAizJfEMAEIDAAYACAizJfEMAEIDAAAA.Doraémon:BAAALAAFFAIIAgAAAA==.',Ge='Gemini:BAAALAAECgYIDwAAAA==.',He='Hercluero:BAAALAAECgYIBgAAAA==.',Hz='Hzbb:BAAALAAFFAMIAwAAAA==.',Il='Illustrator:BAABLAAFFH8GAAIHAAII2wvTowA9AAAHAAII2wvTowA9AAAAAA==.',Is='Isanmaye:BAAALAAECgIIAgAAAA==.',La='Labubu:BAAALAAECggICAAAAA==.',Lo='Lori:BAACLAAFFH8GAAIHAAIIJhayigBIAAAHAAIIJhayigBIAAAsAAQKfxwAAgcABwjjH/NUADQCAAcABwjjH/NUADQCAAAA.',Ma='Mahakala:BAAALAAECgYICgAAAA==.Malphas:BAAALAADCgYIBgAAAA==.Maya:BAABLAAFFH8RAAMGAAgIxh0ZBgCbAgAGAAgIxh0ZBgCbAgAIAAEIXQNPGgBZAAABLAAFFAgIFAADAK4LAA==.',Me='Mediocreman:BAABLAAFFH8OAAMGAAYIPiJMHgC8AQAGAAYISCBMHgC8AQAIAAMIkh28DQBwAAABLAAFFAgIEAAGALUZAA==.',Mi='Mihotel:BAAALAAECgcIBwAAAA==.Minstrel:BAAALAAECggICAAAAA==.',Na='Nagedk:BAABLAAECn8bAAIGAAYIRgmkigDUAAAGAAYIRgmkigDUAAAAAA==.Naslspsm:BAAALAAECggICAAAAA==.',Ni='Nightmare:BAAALAAFFAIIAgAAAA==.Nightwatch:BAACLAAFFH8RAAIBAAIIjxymQACfAAABAAIIjxymQACfAAAsAAQKfxwAAgEABggsI3Q/AE0CAAEABggsI3Q/AE0CAAAA.',Pl='Playerynxhph:BAAALAAECgYIBgAAAA==.',Po='Powehi:BAAALAADCgQIBAAAAA==.',Ro='Rocky:BAAALAADCgIIAgAAAA==.',Ru='Ruigo:BAABLAAFFH8LAAMJAAQI4RiiHQBEAQAJAAQI4RiiHQBEAQAKAAIIjw1YEgBHAAAAAA==.',Sa='Samaelwrath:BAAALAAECgcIEAAAAA==.Sangels:BAAALAAECgMIAwAAAA==.',Sk='Sketchup:BAABLAAFFH8UAAMDAAgIrgvaEAC7AQADAAgIrgvaEAC7AQALAAYI2x32DACSAQAAAA==.',So='Soulreaper:BAAALAAECggICAABLAAFFAgIAwAMAAAAAA==.',Sv='Sven:BAAALAADCgEIAQAAAA==.',To='Totem:BAAALAADCgIIAgAAAA==.',Un='Unscarred:BAAALAAFFAIIAgAAAA==.',Xm='Xmqishi:BAAALAADCgEIAQAAAA==.',Zp='Zpr:BAABLAAFFH8KAAMEAAYInxSlIQA4AQAEAAUIMxOlIQA4AQANAAMIywqPIACDAAAAAA==.',['一个']='一个大嘴巴子:BAABLAAECn8aAAIDAAYIZxwXHgDhAQADAAYIZxwXHgDhAQAAAA==.',['一斩']='一斩风一:BAAALAAFFAIIBAAAAA==.',['一眼']='一眼定乾坤:BAAALAADCgEIAQAAAA==.',['一美']='一美美一:BAAALAAECgIIAgAAAA==.',['一闪']='一闪靓一:BAACLAAFFH80AAMOAAcISxATBwD4AAAOAAYIZhETBwD4AAAPAAEIqQnuUgBQAAAsAAQKfzwAAg4ACAhDGfMVAEgCAA4ACAhDGfMVAEgCAAAA.',['万事']='万事不求人:BAAALAAFFAIIAgAAAA==.',['万亿']='万亿天:BAABLAAFFH8IAAIJAAIIJhH/QQCVAAAJAAIIJhH/QQCVAAAAAA==.',['三山']='三山有杏:BAABLAAFFH8NAAMBAAIIRwxYWwCEAAABAAII7gpYWwCEAAACAAEINQ5LJAAAAAAAAA==.',['三德']='三德子:BAAALAADCggIFQAAAA==.',['上帝']='上帝厶邻居:BAAALAAFFAIIAwAAAA==.上帝邻居:BAAALAAFFAIIBAAAAA==.',['不死']='不死灬三十六:BAAALAAFFAIIAgAAAA==.不死灬不死:BAABLAAFFH8JAAIQAAMIiQPpHQAqAAAQAAMIiQPpHQAqAAAAAA==.不死灬圣:BAABLAAFFH8PAAIPAAMIzxdyPACiAAAPAAMIzxdyPACiAAAAAA==.不死灬女魔头:BAAALAAFFAIIBAAAAA==.不死灬宠物:BAAALAAFFAIIBAAAAA==.不死灬尔萨:BAABLAAFFH8GAAICAAYIrQ79BgA6AQACAAYIrQ79BgA6AQAAAA==.不死灬战:BAAALAAFFAIIAgAAAA==.不死灬术:BAAALAAFFAIIAgAAAA==.不死灬武猫:BAABLAAFFH8KAAIRAAQIMhDpDQDYAAARAAQIMhDpDQDYAAAAAA==.不死灬猎:BAAALAAFFAQIBAAAAA==.不死灬猎手:BAAALAAFFAIIAgAAAA==.不死灬盗:BAAALAAFFAIIAwAAAA==.不死灬萨:BAAALAAFFAIIAgAAAA==.',['且听']='且听风吟丶:BAAALAADCggICAAAAA==.',['丨逐']='丨逐星丨:BAABLAAECn8YAAMSAAYIlyENRwAcAgASAAYI3B8NRwAcAgATAAMI1BwqJADjAAABLAAECgYIGwAHAE4kAA==.',['中指']='中指引发血案:BAAALAAECgMIAwAAAA==.',['丶哈']='丶哈哈:BAAALAAECgYIDAAAAA==.',['丶大']='丶大姐夫:BAAALAAECgMIAwAAAA==.',['丶头']='丶头上有犄角:BAAALAAECgYICgAAAA==.',['丶星']='丶星尘:BAAALAAECgYIDAAAAA==.',['丶晓']='丶晓星尘:BAAALAAECgYIDAAAAA==.',['丶浩']='丶浩瀚泗海丶:BAAALAAECgQIBAAAAA==.',['丶福']='丶福乐:BAAALAAECgYIBgAAAA==.',['丶逐']='丶逐星:BAAALAAECgYIBgABLAAECgYIGwAHAE4kAA==.',['丸辣']='丸辣:BAAALAADCgIIAgAAAA==.',['丹丹']='丹丹:BAAALAADCgYIDAAAAA==.',['丹羽']='丹羽丨茜禾:BAABLAAFFH8GAAIJAAYIRgzUEQDUAQAJAAYIRgzUEQDUAQAAAA==.',['丿龙']='丿龙小龙:BAAALAAECgEIAQAAAA==.',['乃莫']='乃莫齐:BAAALAADCgUIBwAAAA==.',['乄丷']='乄丷漂白丶:BAAALAAECgYIEwAAAA==.',['久伴']='久伴不如酒伴:BAAALAAECgQIBAAAAA==.',['二哥']='二哥很邪恶:BAAALAAECgYIBgAAAA==.',['五味']='五味子:BAAALAAFFAMIAwAAAA==.',['亚古']='亚古兽进化:BAAALAAECgIIAgAAAA==.',['亡魂']='亡魂者:BAAALAADCgYIBgAAAA==.',['以太']='以太行者:BAAALAAECgYIDAAAAA==.',['以射']='以射止射:BAAALAAECgYIEwAAAA==.',['伊斯']='伊斯伟大种族:BAAALAAECgYIBgAAAA==.',['伊漓']='伊漓丹:BAAALAAECgcIBwAAAA==.',['伊琳']='伊琳娜:BAAALAAECgYIEgAAAA==.',['伊瑞']='伊瑞尔:BAABLAAFFH8FAAIPAAIIGgmpdwA5AAAPAAIIGgmpdwA5AAAAAA==.',['伊鲁']='伊鲁米:BAAALAAECggICAAAAA==.',['优雅']='优雅铁憨憨:BAAALAADCggIDwAAAA==.',['何小']='何小宝:BAAALAAECgEIAQAAAA==.',['你缺']='你缺不缺德:BAAALAAECgYIBgAAAA==.',['佩雷']='佩雷斯:BAABLAAFFH8KAAISAAIIXxLYSABKAAASAAIIXxLYSABKAAAAAA==.',['依听']='依听风雨柔:BAAALAAECgYIBwAAAA==.',['偏见']='偏见:BAACLAAFFH8VAAMUAAQICxerAwArAQAUAAQICxerAwArAQAFAAEIKws6ZgBFAAAsAAQKfzIAAhQACAhRHWwOAHgCABQACAhRHWwOAHgCAAEsAAUUBwg1ABUA0SAA.',['元气']='元气小皮锤:BAAALAADCgMIAwAAAA==.',['光是']='光是纽带:BAABLAAFFH8IAAIPAAII3iMoIQDMAAAPAAII3iMoIQDMAAAAAA==.',['兔酱']='兔酱:BAAALAAECgYIBgAAAA==.',['公主']='公主府:BAAALAADCgYIBgAAAA==.',['兰岚']='兰岚小妹:BAAALAAECgYICgAAAA==.',['其木']='其木格:BAAALAADCgYIBgAAAA==.',['兽血']='兽血沸腾:BAAALAAECgcIBwAAAA==.',['内流']='内流满面:BAAALAADCgcIBwAAAA==.',['再借']='再借五厘米:BAACLAAFFH8GAAIWAAYInx1PDQACAgAWAAYInx1PDQACAgAsAAQKfxQAAhcACAgGFw1CAPwBABcACAgGFw1CAPwBAAEsAAUUCAgZAAMAeCIA.',['再看']='再看就砍你:BAAALAAECgIIAgAAAA==.',['冫假']='冫假如我会飞:BAABLAAFFH8FAAIBAAMIbhTQTQBSAAABAAMIbhTQTQBSAAABLAAFFAgICAACAF4GAA==.',['冰冰']='冰冰滴可耐:BAABLAAFFH8FAAIGAAII1QvbdgCNAAAGAAII1QvbdgCNAAAAAA==.',['冰冷']='冰冷丨办公桌:BAABLAAFFH8HAAINAAUIQQj9GADuAAANAAUIQQj9GADuAAAAAA==.',['冰吸']='冰吸生椰拿铁:BAAALAAECgYIDAAAAA==.',['冰激']='冰激凌奶茶:BAAALAAECgYIBwAAAA==.',['冰释']='冰释前嫌:BAABLAAFFH8JAAISAAIIlRhtKgClAAASAAIIlRhtKgClAAAAAA==.',['冰霜']='冰霜茶茶:BAAALAAFFAIIBAAAAA==.',['决战']='决战牧:BAAALAAECgYIDAAAAA==.决战迪凯:BAABLAAFFH8FAAIGAAMInw18YgCIAAAGAAMInw18YgCIAAAAAA==.',['凌霄']='凌霄:BAAALAAECgYICQAAAA==.',['别了']='别了青春:BAAALAAECggIBgAAAA==.',['别理']='别理我很烦躁:BAAALAADCgYIBgAAAA==.',['别西']='别西卜:BAAALAAECgYIBgAAAA==.',['刮刮']='刮刮乐:BAAALAAECgIIAgAAAA==.',['割魂']='割魂者丶:BAABLAAFFH8YAAQYAAcIKRwwCQApAQAYAAYINR0wCQApAQAZAAIIjhXWEACYAAAaAAEI3xUAAAAAAAABLAAFFAgIEAAGALUZAA==.',['助樱']='助樱啪丶啪啪:BAAALAAFFAgIAgAAAA==.',['十月']='十月:BAAALAAFFAIIAgAAAA==.',['千里']='千里明月:BAAALAAECgIIAgAAAA==.千里月明:BAABLAAECn8cAAICAAYIJBnJMAC3AQACAAYIJBnJMAC3AQAAAA==.',['卖饼']='卖饼的阿花:BAAALAAFFAEIAQAAAA==.',['卡西']='卡西莫多:BAABLAAFFH8WAAIJAAgIIAyuMgBLAQAJAAgIIAyuMgBLAQAAAA==.',['可爱']='可爱:BAABLAAFFH8LAAIDAAMIPRMMLQC4AAADAAMIPRMMLQC4AAAAAA==.',['可笑']='可笑丨孤单:BAAALAADCgEIAQAAAA==.可笑的孤单:BAABLAAECn8bAAQWAAYIkhOvlABVAQAWAAYIkhOvlABVAQAXAAYIZgqpTADdAAAbAAEI0QehGAAAAAAAAA==.',['史莱']='史莱克:BAABLAAFFH8IAAIGAAIIExC/ZgCVAAAGAAIIExC/ZgCVAAAAAA==.',['君君']='君君热干面:BAAALAAFFAIIBAAAAA==.',['听风']='听风逝夜:BAAALAAECgYIEAAAAA==.',['呆呆']='呆呆丶贼:BAABLAAFFH8IAAIYAAYIrhulCACQAQAYAAYIrhulCACQAQABLAAFFAgIEAAGALUZAA==.呆呆丶骑:BAABLAAFFH8GAAIGAAYIbxFIMwBuAQAGAAYIbxFIMwBuAQAAAA==.',['呦呦']='呦呦一一:BAAALAADCgQIBAAAAA==.',['命运']='命运:BAAALAADCgcIBwAAAA==.',['咕嘟']='咕嘟晨光:BAAALAAECgUIBQAAAA==.',['咖喱']='咖喱給給:BAAALAAFFAIIAgAAAA==.',['咬人']='咬人兔:BAAALAAFFAIIAgAAAA==.',['哇不']='哇不哇塞:BAAALAAFFAIIAgAAAA==.',['哈哈']='哈哈酱:BAAALAAECgYIDAABLAAECgYIEwAMAAAAAA==.',['唉你']='唉你欠骂:BAABLAAFFH8MAAMcAAYIsREgBQC6AQAcAAYIsREgBQC6AQAdAAIIHhzEGwCFAAABLAAFFAgIPgAJAL0lAA==.',['啦啦']='啦啦玫瑰:BAAALAADCgQIBAAAAA==.',['喝酒']='喝酒不吃菜:BAAALAAECgYIBgAAAA==.',['嗜血']='嗜血小逐月:BAAALAAFFAQIBAAAAA==.嗜血狂鲛:BAAALAADCgYIBgAAAA==.',['嘟哒']='嘟哒吐露嘟哒:BAAALAAECgYIBgAAAA==.',['嘻哈']='嘻哈晴天小猪:BAAALAADCgYIBgAAAA==.',['嘿丶']='嘿丶朋友:BAAALAAECgYICQAAAA==.',['噬魂']='噬魂魅影:BAAALAADCgYIAQAAAA==.',['嚗雪']='嚗雪靑蛙丶:BAABLAAFFH8KAAIWAAII1SEjNQCXAAAWAAII1SEjNQCXAAAAAA==.',['圣光']='圣光辰星:BAAALAAECggICAAAAA==.',['圣浴']='圣浴紫光:BAAALAADCgQIBAAAAA==.',['地狱']='地狱守护:BAAALAAECgIIAgAAAA==.地狱战火:BAAALAADCgQIBAAAAA==.',['地精']='地精灬小邢:BAAALAAECgYIBgAAAA==.',['坚如']='坚如磐石:BAABLAAFFH8GAAIWAAUI/ghgNADVAAAWAAUI/ghgNADVAAAAAA==.',['基友']='基友乙骑丨士:BAAALAADCgEIAQAAAA==.',['塑料']='塑料娃娃:BAABLAAFFH8mAAQPAAcIjh5EBQAwAgAPAAcIjh5EBQAwAgAOAAEILhYHIgBHAAAeAAEI1AHEKgA4AAAAAA==.',['墙外']='墙外等小歪歪:BAAALAAECgQIBAAAAA==.',['墨神']='墨神归来:BAABLAAECn8cAAMHAAgITh2gIQA0AgAHAAgITh2gIQA0AgAfAAYIFgbwigC4AAAAAA==.',['墨與']='墨與言:BAAALAAECgYIEQAAAA==.',['壹歲']='壹歲殧變壞:BAAALAAECgYIEgAAAA==.',['夏夏']='夏夏:BAAALAAECgEIAgAAAA==.',['夜丿']='夜丿肖丶宇:BAABLAAFFH8GAAIHAAYIkQ1IQQBCAQAHAAYIkQ1IQQBCAQAAAA==.',['大力']='大力汼魔王:BAAALAADCgYIBgAAAA==.大力魔:BAAALAADCgUIBQAAAA==.',['大召']='大召:BAAALAADCgYIBgAAAA==.',['大帅']='大帅逼:BAAALAAECgEIAQAAAA==.',['大帝']='大帝累了:BAAALAADCgMIAwAAAA==.',['大浪']='大浪淘沙:BAAALAAECgYIBgAAAA==.',['大狸']='大狸猫:BAABLAAFFH8RAAIJAAYIuQ/FOAApAQAJAAYIuQ/FOAApAQAAAA==.',['大闹']='大闹古陌岭:BAAALAAECgQIBgAAAA==.',['天下']='天下第一死骑:BAAALAAECgYIBgAAAA==.',['天使']='天使献祭之厅:BAAALAAECgMIBgAAAA==.',['天堂']='天堂向左:BAAALAAECgYIBgAAAA==.',['天天']='天天虚空:BAAALAAECgcICAAAAA==.',['天实']='天实安德:BAAALAAECgYICgAAAA==.',['天真']='天真的橡皮:BAAALAADCgQIBAAAAA==.',['太乙']='太乙溪梦:BAAALAADCgQIBAAAAA==.',['失落']='失落伊甸园:BAABLAAFFH8aAAMSAAYIQRihGACcAQASAAYIQRihGACcAQATAAEIDBYlCABOAAAAAA==.',['奶油']='奶油泡芙喵:BAAALAAECgcIBwAAAA==.',['好友']='好友根:BAAALAAECgYICgAAAA==.',['如龙']='如龙:BAAALAAECgYIEAAAAA==.',['妖妖']='妖妖小静:BAABLAAECn8XAAMgAAcIqggbMQAKAQAgAAcIqggbMQAKAQARAAcI9wMYTQDkAAAAAA==.',['妖精']='妖精一九尾:BAAALAAECgIIAgAAAA==.',['妮索']='妮索珂斯:BAAALAAECgYIEQAAAA==.',['姬狐']='姬狐丨圣洁:BAABLAAFFH8GAAMEAAYIOAeqJgAAAQAEAAUIIQaqJgAAAQANAAEIIAkSKQBEAAABLAAFFAYIFQAWAFYgAA==.姬狐丨娇爃:BAABLAAFFH8VAAMWAAYIViAPCwAcAgAWAAYIViAPCwAcAgAXAAUIRBbPJAAfAQAAAA==.姬狐丨怜悯:BAABLAAFFH8MAAIeAAYIjxgqDgCjAQAeAAYIjxgqDgCjAQABLAAFFAYIFQAWAFYgAA==.姬狐丨機驚:BAAALAAFFAQIBAABLAAFFAYIFQAWAFYgAA==.姬狐丨翩跹:BAAALAAFFAYIAwABLAAFFAYIFQAWAFYgAA==.姬狐丨翱翔:BAABLAAFFH8FAAMdAAUIZgzeFACxAAAdAAQIPwfeFACxAAAcAAEIaQI6IQA0AAABLAAFFAYIFQAWAFYgAA==.',['子非']='子非术:BAACLAAFFH8hAAMJAAYIURXpKgBvAQAJAAYIURXpKgBvAQAKAAEIkgMaMABCAAAsAAQKfx0ABAoACAgKGBQtAL0BAAkACAiyFRpNAAsCAAoABwiHFBQtAL0BACEABQhAE8oZADYBAAAA.',['孤浪']='孤浪大魔王:BAAALAAECgIIAgAAAA==.',['安柒']='安柒:BAAALAADCgEIAQAAAA==.',['安蕾']='安蕾娜沙:BAABLAAFFH8IAAMKAAIIpQ4AFwCWAAAKAAIIwg0AFwCWAAAJAAIIHg21YwA8AAAAAA==.',['寂寞']='寂寞的海洋:BAAALAAECgQIBQAAAA==.寂寞的独行者:BAAALAAECgYIDAAAAA==.',['寒食']='寒食:BAAALAAECgcICQAAAA==.',['将军']='将军衙署:BAAALAADCgEIAQAAAA==.',['小咦']='小咦:BAAALAADCgIIAgAAAA==.',['小城']='小城大事:BAAALAADCgMIAwAAAA==.',['小太']='小太仔奶:BAAALAAFFAIIBAAAAA==.',['小女']='小女孩:BAABLAAFFH8GAAIUAAIINRJfEgBpAAAUAAIINRJfEgBpAAAAAA==.',['小小']='小小张:BAAALAAECggIDAAAAA==.',['小明']='小明和春娇:BAACLAAFFH8GAAMKAAII0iH7HwBsAAAKAAEI+SX7HwBsAAAJAAEIrB0DWwBPAAAsAAQKfyAABAkABwjOIhsqAJkCAAkABwjPIRsqAJkCAAoAAgjOJnloANUAACEAAgi0EnwuAH8AAAAA.',['小桃']='小桃红:BAABLAAECn8YAAIXAAYIlB0XRAD1AQAXAAYIlB0XRAD1AQAAAA==.',['小梅']='小梅童靴丶:BAAALAADCgUIBQAAAA==.',['小歪']='小歪:BAAALAAFFAIIAgAAAA==.',['小灵']='小灵芝丶:BAAALAAECgYIDAAAAA==.',['小牛']='小牛被狗咬:BAAALAAECgQIBAAAAA==.',['小牧']='小牧卡卡:BAAALAAECgMIAwAAAA==.',['小狸']='小狸猫:BAABLAAFFH8GAAIHAAYI6Q7jNgBiAQAHAAYI6Q7jNgBiAQAAAA==.',['小猎']='小猎卡卡:BAAALAAECgYICgAAAA==.',['小的']='小的們给我上:BAAALAAFFAIIBAAAAA==.',['小红']='小红帽快来:BAABLAAECn8kAAMKAAgIXSWqAAADAwAKAAgIXSWqAAADAwAJAAEIqBPolAA/AAAAAA==.小红帽追猎者:BAAALAAECgYIEwAAAA==.',['小聋']='小聋瞎:BAAALAAECgYIBgAAAA==.',['小萨']='小萨卡卡:BAAALAAECgYIEQAAAA==.',['小蛋']='小蛋糕:BAAALAAECgEIAQAAAA==.',['小蜜']='小蜜蜂:BAAALAAECgEIAQAAAA==.',['小豆']='小豆:BAAALAADCgYIBgAAAA==.',['小赞']='小赞卡卡:BAAALAAECgYIBgAAAA==.',['小风']='小风儿凉飕飕:BAAALAAECggICAAAAA==.',['小黑']='小黑哥:BAAALAAFFAIIBAAAAA==.',['尢彡']='尢彡廾:BAAALAAECggICAAAAA==.',['尼伯']='尼伯龙根:BAAALAAECgUIBQABLAAECgYIEwAMAAAAAA==.',['山海']='山海:BAAALAAECgYICwAAAA==.',['岩盐']='岩盐葡萄冻:BAAALAAECgIIAgAAAA==.',['峦山']='峦山:BAACLAAFFH8UAAMSAAYIDxPRGwCIAQASAAYIDxPRGwCIAQAVAAIIzQ48LAA4AAAsAAQKfxQAAxIABgikHwskANUBABIABgikHwskANUBABUABggQEdpQAD4BAAAA.',['嵬灬']='嵬灬嵬:BAAALAADCgMIAwAAAA==.',['巴西']='巴西的世界杯:BAABLAAFFH8FAAIXAAIIkQLwOABtAAAXAAIIkQLwOABtAAAAAA==.',['帆婷']='帆婷淇宝宝:BAACLAAFFH8pAAIFAAYIshDlIAB9AQAFAAYIshDlIAB9AQAsAAQKfzAAAgUACAhUF1YqALEBAAUACAhUF1YqALEBAAAA.',['帆帆']='帆帆大宝宝:BAAALAADCgEIAQAAAA==.',['希丨']='希丨希:BAAALAAFFAIIAgAAAA==.',['希尔']='希尔瓦娜思:BAAALAAFFAIIBAAAAA==.希尔瓦娜灬丝:BAAALAADCgUIBQAAAA==.',['希瑶']='希瑶雨茉:BAAALAAFFAEIAQAAAA==.',['帕里']='帕里斯:BAAALAAECgQIBAAAAA==.',['帝丑']='帝丑法:BAAALAAECgYIBgAAAA==.',['帝神']='帝神牛:BAAALAAECgYICAAAAA==.',['席利']='席利图:BAAALAADCgEIAQAAAA==.',['庸人']='庸人自扰:BAABLAAFFH8GAAMIAAYImRgdCAD/AAAIAAMI6hUdCAD/AAAGAAMISBuNWACiAAABLAAFFAgIEAAGALUZAA==.',['开心']='开心鱼腩煲:BAAALAAECggICAAAAA==.',['弈剑']='弈剑听风雨:BAAALAAECgUIBQAAAA==.',['张不']='张不留行:BAAALAAECgQIBwAAAA==.',['影织']='影织耀:BAABLAAFFH8OAAMPAAMIxBXpPgCYAAAPAAMIxBXpPgCYAAAeAAII0QarKgBiAAAAAA==.',['後發']='後發:BAAALAAECgYIBgAAAA==.',['心想']='心想拾橙:BAABLAAFFH8MAAIHAAYI8w7YOgBWAQAHAAYI8w7YOgBWAQABLAAFFAgICwAHAHceAA==.',['心跳']='心跳很哇塞丶:BAAALAAECgQIBAAAAA==.',['心里']='心里有术:BAAALAAECgYICQAAAA==.',['忘了']='忘了纹身:BAAALAAFFAIIAgAAAA==.',['性感']='性感母蟑螂丶:BAABLAAFFH8IAAIGAAII3hvuTACjAAAGAAII3hvuTACjAAAAAA==.',['恶魔']='恶魔之血呼啦:BAAALAADCgcIBwAAAA==.',['悠悠']='悠悠小水桶:BAAALAAFFAIIAgAAAA==.悠悠麦:BAABLAAFFH8IAAMFAAII9hwMKwC1AAAFAAII9hwMKwC1AAAUAAEIuQkXHQAsAAAAAA==.',['惩戒']='惩戒骑:BAACLAAFFH8PAAIGAAYIRB5eGAB3AQAGAAYIRB5eGAB3AQAsAAQKfy8AAgYACAg9JM4SACYDAAYACAg9JM4SACYDAAAA.',['慕容']='慕容舞倾城:BAAALAAFFAIIAgAAAA==.',['懐埝']='懐埝:BAAALAAECgYIBgAAAA==.',['成都']='成都必玩榜:BAAALAAECgIIAgAAAA==.',['我一']='我一点都不黑:BAAALAAECgYIEgAAAA==.',['我不']='我不知道:BAABLAAFFH8EAAMIAAQIYCDcCQC6AAAGAAIIJyJtUwDFAAAIAAIImh7cCQC6AAABLAAFFAgIEAAGALUZAA==.',['我叫']='我叫色牛:BAACLAAFFH8MAAIDAAIIbA9URgBiAAADAAIIbA9URgBiAAAsAAQKfxcAAgMABgjSE25AABcBAAMABgjSE25AABcBAAAA.',['我是']='我是演员:BAAALAAFFAEIAQAAAA==.',['我有']='我有真奥妙:BAABLAAFFH8hAAMJAAYIaRn/JgB9AQAJAAYIlhj/JgB9AQAKAAMIXhS/EACjAAABLAAFFAgIBgAHANsLAA==.',['战神']='战神狻猊:BAAALAAECgYIBgAAAA==.',['扣弦']='扣弦而舞:BAAALAADCgYIBgAAAA==.',['抿著']='抿著小嘴兒:BAAALAAFFAIIAgAAAA==.',['括约']='括约肌拉伤:BAAALAADCgUIBQAAAA==.',['拳头']='拳头大直接拽:BAAALAAECgUIBQAAAA==.',['提尔']='提尔阿瑞斯:BAAALAAECgQIBAAAAA==.',['擒兽']='擒兽大师:BAAALAAECgUIBQAAAA==.',['收手']='收手吧丿阿祖:BAABLAAFFH8MAAILAAYIXAnNFgAmAQALAAYIXAnNFgAmAQAAAA==.',['斯内']='斯内克:BAABLAAFFH8GAAIHAAYIUw47DgDAAQAHAAYIUw47DgDAAQAAAA==.',['斯琴']='斯琴:BAAALAADCgUIBQAAAA==.',['斯铭']='斯铭:BAAALAAECgYIBgAAAA==.',['方于']='方于飞大炮:BAAALAAFFAEIAQAAAA==.',['无惧']='无惧之战:BAAALAAECgcIDQAAAA==.',['无敌']='无敌么么:BAAALAAECgYIBQAAAA==.无敌小萝莉:BAAALAAFFAIIAgAAAA==.无敌尐浣熊:BAAALAADCgYIBgAAAA==.',['无限']='无限叁火力:BAAALAADCgYIBgAAAA==.',['时间']='时间丶若倒退:BAABLAAECn8mAAIJAAYI3w6qVwD5AAAJAAYI3w6qVwD5AAAAAA==.',['旺旺']='旺旺吉星高照:BAAALAAECggIDwAAAA==.旺旺大魔神:BAAALAADCgUIBQABLAAFFAcIGwAGAMsfAA==.',['昏睡']='昏睡:BAACLAAFFH8MAAMcAAYIziMfAQBzAgAcAAYIziMfAQBzAgAdAAMIlQ8WEQDUAAAsAAQKfxYAAx0ACAhAIPYSAJkCAB0ACAhAIPYSAJkCABwAAwhlDLw4AJEAAAAA.昏睡吴老克:BAAALAAECgcIBwAAAA==.',['星屿']='星屿:BAAALAAFFAIIAgAAAA==.',['星海']='星海德:BAAALAADCgYIBgAAAA==.',['星痕']='星痕:BAABLAAFFH8LAAIJAAYI9SAfEgD8AQAJAAYI9SAfEgD8AQAAAA==.',['是恶']='是恶魔啊:BAAALAAECgYIBQAAAA==.',['晓孔']='晓孔融:BAAALAAECgYICAAAAA==.',['晓星']='晓星尘:BAAALAAECgYIDAAAAA==.',['暗影']='暗影主宰:BAAALAAECgQICAAAAA==.暗影箭矢:BAAALAAFFAIIAgAAAA==.',['暗殺']='暗殺藝術:BAAALAAECgYIBgAAAA==.',['暴打']='暴打小桃子:BAAALAAECgYIDAAAAA==.',['月半']='月半居士:BAAALAAECgMIBAAAAA==.',['月落']='月落丶冬至:BAABLAAFFH8GAAIHAAYIOQT5VwDsAAAHAAYIOQT5VwDsAAABLAAFFAgIHgAHADkbAA==.',['有一']='有一点点酸:BAAALAAECgYICAAAAA==.',['有毛']='有毛猕猴桃:BAAALAAECgQIBwAAAA==.',['木偶']='木偶小小:BAAALAAECggIDAAAAA==.',['木梨']='木梨猎手:BAAALAAFFAIIAgAAAA==.',['松山']='松山湖典狱官:BAABLAAFFH8LAAIFAAIIbxTWSQBQAAAFAAIIbxTWSQBQAAAAAA==.',['林小']='林小溪:BAAALAAECgYIAQABLAAFFAYIBgAEAJUPAA==.',['林溪']='林溪:BAAALAAECggICgABLAAFFAgIHAALAOIkAA==.',['柠檬']='柠檬奥利奥:BAAALAAECgcIEwAAAA==.柠檬水五分糖:BAAALAAECgUICQAAAA==.',['柳智']='柳智敏:BAAALAAFFAQIBAAAAA==.',['树袋']='树袋熊不会咕:BAAALAAECgMIAQAAAA==.',['格兰']='格兰伲:BAABLAAECn8VAAMBAAYILRvAJgCGAQABAAYIWxrAJgCGAQACAAYIWxRhSgBHAQAAAA==.',['梦境']='梦境回廊:BAACLAAFFH8MAAIiAAMI0BDvCwDNAAAiAAMI0BDvCwDNAAAsAAQKfxcAAiIABwgCG5oVACICACIABwgCG5oVACICAAAA.',['梦的']='梦的彼岸:BAABLAAECn8cAAMWAAcIHxb8aQCwAQAWAAcIHxb8aQCwAQAXAAIIJgguwgBeAAAAAA==.',['梦萦']='梦萦银月:BAAALAAECgYIDAAAAA==.',['橙色']='橙色丶圣光:BAAALAAECgMIAwAAAA==.',['橫雲']='橫雲踏月:BAAALAAFFAIIAgAAAA==.',['欢乐']='欢乐:BAAALAAFFAIIAgAAAA==.欢乐天神:BAABLAAECn8ZAAIDAAcI2w4NcwA+AQADAAcI2w4NcwA+AQABLAAFFAgICAADADMeAA==.',['欢喜']='欢喜糖糖:BAAALAAECgYIBwAAAA==.',['欧皇']='欧皇丶:BAABLAAFFH8MAAINAAIIZCB2IQCLAAANAAIIZCB2IQCLAAABLAAFFAgILAAEAAknAA==.',['死骑']='死骑卡卡:BAAALAAECgIIAgAAAA==.',['水绕']='水绕指柔:BAAALAAECgQIBAAAAA==.',['永恒']='永恒之法:BAAALAAECgYIBgAAAA==.永恒之盾:BAAALAAECgIIAgAAAA==.',['永远']='永远的久远:BAAALAADCgcICAAAAA==.',['沈佳']='沈佳宜:BAAALAAECgUIBQAAAA==.',['沉默']='沉默圣光:BAAALAAFFAIIAgAAAA==.沉默的背后:BAAALAAECgIIAgAAAA==.',['沙漠']='沙漠刀妹:BAAALAAECgIIAgAAAA==.沙漠媚娘:BAAALAAECgYIDgAAAA==.沙漠萌妹:BAAALAAECgYIBwAAAA==.沙漠阿宝:BAAALAAECgQIBQAAAA==.沙漠飞雕:BAAALAAECgUICQAAAA==.',['沙琪']='沙琪玛大王:BAAALAAECgYIDwAAAA==.',['没湿']='没湿找抽:BAAALAAECgEIAQAAAA==.',['沧笙']='沧笙踏歌:BAABLAAECn8aAAMHAAYIThYarwCWAQAHAAYIThYarwCWAQAfAAYIygw8bgARAQAAAA==.',['法丝']='法丝丝丶:BAAALAAECgIIAgAAAA==.',['法神']='法神卡卡:BAAALAADCgcIBwAAAA==.',['泰拉']='泰拉尔多尔衮:BAAALAAECgQIBgAAAA==.',['洄梦']='洄梦酒:BAAALAAFFAIIBAAAAA==.',['洛克']='洛克兰:BAAALAADCgQIBAAAAA==.',['洛阿']='洛阿神达拉:BAAALAAECgYIDQABLAAECgYIEwAMAAAAAA==.',['活着']='活着没意思啊:BAAALAADCgEIAQAAAA==.',['海燕']='海燕呐:BAAALAAECgMIAwAAAA==.',['海边']='海边的卡夫卡:BAABLAAFFH8JAAMQAAYI7QwZDgAkAQAQAAYIdwwZDgAkAQAGAAMIxg4nYwCGAAAAAA==.',['淇淇']='淇淇大宝宝:BAAALAADCgIIAgAAAA==.',['清蒸']='清蒸一口气:BAACLAAFFH8QAAIWAAQI9BbNKgAPAQAWAAQI9BbNKgAPAQAsAAQKfxgAAxcABwiOGF4gAK0BABcABggAHF4gAK0BABYAAQhuDN2oACYAAAAA.',['清风']='清风望月丶:BAAALAAECgYICAAAAA==.',['渣喳']='渣喳:BAAALAADCgIIAgAAAA==.',['火流']='火流独舞:BAAALAAECgYIEQAAAA==.',['灬北']='灬北方灬:BAABLAAFFH8GAAIXAAYIaBqMGQByAQAXAAYIaBqMGQByAQAAAA==.',['灬大']='灬大姐姐灬:BAAALAAECggIDgAAAA==.',['灬霓']='灬霓裳幽兰灬:BAAALAAFFAIIAgAAAA==.灬霓裳旖旎灬:BAAALAAFFAIIBAAAAA==.',['烟味']='烟味口中弥漫:BAAALAAECgQIBQAAAA==.',['烟绕']='烟绕指柔:BAABLAAFFH8GAAIWAAYIGhCaIQBQAQAWAAYIGhCaIQBQAQAAAA==.',['烧饵']='烧饵块:BAAALAAFFAIIAgAAAA==.',['热罗']='热罗尼莫:BAAALAAECggICwAAAA==.',['焚河']='焚河:BAACLAAFFH8PAAMSAAMIlwYaIQDBAAASAAMI5gQaIQDBAAAVAAMIcQQTGQCUAAAsAAQKfx0AAxIACAisGJ9MAAoCABIACAisGJ9MAAoCABUAAQiwC4eYADEAAAAA.',['煙雨']='煙雨天:BAABLAAFFH8KAAIHAAYIKh0lCQD2AQAHAAYIKh0lCQD2AQAAAA==.',['熊瞎']='熊瞎额丨:BAAALAAECggICAAAAA==.',['熊霸']='熊霸:BAAALAAFFAIIBAAAAA==.',['燒死']='燒死你丫的:BAAALAAECgUIBQAAAA==.',['爆发']='爆发花椒:BAAALAAECgYIBgAAAA==.',['爱啃']='爱啃小居蹄:BAABLAAFFH8KAAIPAAQI/QSEOwCnAAAPAAQI/QSEOwCnAAAAAA==.',['爱喝']='爱喝小啤酒:BAAALAAECgIIAgAAAA==.爱喝小旺仔:BAAALAAECgYIBgAAAA==.',['牛栏']='牛栏山魔王:BAAALAADCggICAAAAA==.',['牛气']='牛气霸天:BAAALAADCggIDQAAAA==.',['牧丶']='牧丶晓宇:BAAALAAECggICQAAAA==.',['狡猾']='狡猾的伊鲁米:BAAALAAECggICAAAAA==.',['猎丨']='猎丨魔丨人:BAAALAAECgUICAAAAA==.',['猕猴']='猕猴桃:BAAALAAFFAIIAgAAAA==.',['献祭']='献祭天使:BAABLAAFFH8IAAIFAAII6gePZAA7AAAFAAII6gePZAA7AAAAAA==.',['玉铃']='玉铃铛:BAAALAAFFAIIAgAAAA==.',['玛德']='玛德法科:BAABLAAFFH8pAAMGAAYI4iEoFADvAQAGAAYI4iEoFADvAQAIAAIIXBV7EACXAAAAAA==.',['生命']='生命不再绽放:BAAALAAECgQIBAAAAA==.',['甩一']='甩一脸刨冰:BAAALAADCgUIBQAAAA==.',['田师']='田师傅:BAACLAAFFH8xAAIDAAcI3RP7DgDRAQADAAcI3RP7DgDRAQAsAAQKfzwAAwMACAiSIOkUALYCAAMACAiSIOkUALYCAAsABQiAIR02AOIBAAAA.',['疯癫']='疯癫小德:BAAALAAECgYIBgAAAA==.疯癫小萨:BAAALAAECgQIBAAAAA==.',['白露']='白露未晞:BAAALAAECgcIDAAAAA==.',['白骨']='白骨缠身:BAAALAAECggICAAAAA==.',['百医']='百医:BAABLAAFFH8NAAIEAAIIhhK+MgCLAAAEAAIIhhK+MgCLAAABLAAFFAgICQAPAIYPAA==.',['看我']='看我丶鎂嗎:BAAALAADCgMIAwAAAA==.看我眼神行事:BAAALAADCgQIBQAAAA==.看我脸色行事:BAAALAAECgYIBgAAAA==.',['看那']='看那小子真黑:BAAALAAECgYIDQAAAA==.',['真理']='真理所在:BAABLAAFFH8PAAMCAAMIMxlsEQCMAAABAAIIYBmWQACfAAACAAMIoBRsEQCMAAAAAA==.',['瞿老']='瞿老爷:BAAALAAECgMIAwAAAA==.',['砍斯']='砍斯伲丫的:BAAALAAFFAIIAgAAAA==.',['硬梆']='硬梆梆的我:BAACLAAFFH8zAAMIAAcIxyWRAQC+AQAIAAQIVSaRAQC+AQAGAAQIdCX1LQDiAAAsAAQKfy4AAwgACAjKJigCAEwDAAgACAjJJSgCAEwDAAYABQicJhBlACwCAAAA.',['碗和']='碗和盆:BAAALAAECgMIAwAAAA==.',['神之']='神之后羿:BAAALAAECgUIBQAAAA==.',['神小']='神小修墨:BAABLAAECn8WAAISAAYInx30VADyAQASAAYInx30VADyAQAAAA==.神小雨:BAACLAAFFH8LAAMEAAIIbx1dIgCxAAAEAAIIbx1dIgCxAAANAAII7Q6TIACNAAAsAAQKfzgAAw0ACAjuHXAXALECAA0ACAjuHXAXALECAAQABwjhG+g5APIBAAAA.',['神牛']='神牛听我滴:BAAALAAECgYIBgAAAA==.',['福乐']='福乐:BAAALAAECgYIBgAAAA==.',['空谷']='空谷诸尘尽谢:BAAALAAECgYIDQAAAA==.',['等一']='等一个夏天:BAAALAADCggIAgAAAA==.',['米盖']='米盖尔:BAAALAAECgYIEwABLAAECgYIEwAMAAAAAA==.',['糊涂']='糊涂孩:BAAALAADCgYIBgAAAA==.',['終不']='終不似少年遊:BAABLAAFFH8MAAIGAAcIgggHSwAFAQAGAAcIgggHSwAFAQAAAA==.',['繁华']='繁华:BAAALAAECgUIBwAAAA==.',['红世']='红世:BAABLAAECn8XAAIJAAYIox2aYADPAQAJAAYIox2aYADPAQAAAA==.',['绝世']='绝世好牛奶:BAAALAAECggICAAAAA==.',['绝对']='绝对零度:BAAALAAFFAIIAgAAAA==.',['绝望']='绝望的土壤:BAAALAAECgMIAwAAAA==.',['网络']='网络先锋:BAAALAAFFAIIAgAAAA==.',['羿射']='羿射九日:BAAALAAECgIIAgAAAA==.',['翛然']='翛然:BAAALAAECgYIEAAAAA==.',['翠微']='翠微:BAABLAAECn8YAAMjAAYIhxsaDQBkAQAjAAYIhxsaDQBkAQAkAAIIVQVdSABEAAAAAA==.',['老三']='老三按摩院:BAAALAAFFAIIAgAAAA==.老三爷:BAAALAAECgYIBgAAAA==.老三足疗店:BAAALAAFFAIIBAAAAA==.老三酒吧:BAAALAAFFAIIBAAAAA==.',['老婶']='老婶儿:BAAALAAECgYIEQAAAA==.',['老掰']='老掰:BAAALAAECgYICwAAAA==.',['聴风']='聴风:BAAALAAECgQIBAAAAA==.',['聼光']='聼光:BAAALAAECgEIAQAAAA==.',['肆海']='肆海凉生欢:BAAALAAECgYICgAAAA==.',['背对']='背对天堂:BAAALAAFFAMIAwAAAA==.',['腐刃']='腐刃督军:BAAALAADCgEIAQAAAA==.',['自在']='自在如风少年:BAAALAAFFAIIBAAAAA==.',['自己']='自己动:BAABLAAFFH8GAAIJAAYIHh34CgAaAgAJAAYIHh34CgAaAgAAAA==.',['舍瓦']='舍瓦:BAAALAADCgUIBQAAAA==.',['芙蘭']='芙蘭朵露:BAACLAAFFH8mAAIPAAcIBiFqBABDAgAPAAcIBiFqBABDAgAsAAQKfyoAAg8ABwg9JqMOAJoCAA8ABwg9JqMOAJoCAAAA.',['芝士']='芝士酸酸乳:BAAALAAECgIIAgAAAA==.',['花臂']='花臂大佬:BAAALAAECgYIDAAAAA==.',['花谢']='花谢亦会开:BAAALAAECgEIAQAAAA==.',['荒野']='荒野之息:BAAALAAECggIDgAAAA==.',['莫哈']='莫哈特:BAABLAAECn8UAAMJAAgIQxQ2MgCDAQAJAAcIvRQ2MgCDAQAKAAcIIgwKUQAwAQAAAA==.',['莫羡']='莫羡:BAACLAAFFH8OAAIRAAUI4A0YBwAzAQARAAUI4A0YBwAzAQAsAAQKfywAAhEACAgxH7sOALkCABEACAgxH7sOALkCAAAA.',['萌新']='萌新阿噗:BAAALAADCgYIBgAAAA==.',['萨满']='萨满者:BAAALAAFFAIIBAAAAA==.萨满足:BAAALAAECgIIAgAAAA==.',['萨瓦']='萨瓦滴学生卡:BAAALAAECgYIDAAAAA==.',['葛溫']='葛溫德林:BAAALAAECggICAAAAA==.',['蒂斯']='蒂斯貝尔瑟提:BAAALAAECgYICwAAAA==.',['藏锋']='藏锋:BAAALAAECgYIDwAAAA==.',['虎皮']='虎皮鹦鹉:BAAALAAFFAIIAgAAAA==.',['虚空']='虚空诅咒:BAAALAADCgUIBQAAAA==.',['血月']='血月狂人:BAAALAAECgUIBwAAAA==.',['血染']='血染寒江:BAAALAADCgMIAwAAAA==.',['血神']='血神丶:BAABLAAFFH8IAAIBAAgIciEKBACvAgABAAgIciEKBACvAgAAAA==.',['血色']='血色残锋:BAAALAAECgYIBgAAAA==.',['血蹄']='血蹄胞妹:BAAALAADCgIIBAAAAA==.血蹄胞弟:BAAALAADCgIIAgAAAA==.',['行可']='行可以:BAAALAAECgYIBgAAAA==.',['袖手']='袖手天下:BAABLAAFFH8FAAIUAAMI8wRXEABIAAAUAAMI8wRXEABIAAAAAA==.',['西南']='西南拐王:BAABLAAFFH8HAAIJAAMISgjbTwB6AAAJAAMISgjbTwB6AAAAAA==.',['西格']='西格玛男人:BAAALAAECgYICgAAAA==.',['该躲']='该躲不躲:BAAALAADCgUIBQAAAA==.',['请不']='请不用理我:BAAALAAECgUIBQAAAA==.',['诺和']='诺和萨驰:BAAALAAFFAMIAwABLAAFFAgIAwAMAAAAAA==.',['豆角']='豆角君:BAAALAAFFAIIBAAAAA==.',['豪玖']='豪玖邀明月:BAAALAADCgcIBwAAAA==.',['贞洁']='贞洁猎女:BAAALAAECgYIDwAAAA==.',['贱贱']='贱贱的爱上你:BAAALAAECgIIAgAAAA==.',['贼呆']='贼呆丶:BAABLAAFFH8KAAIYAAYIcB/ABgBlAQAYAAYIcB/ABgBlAQABLAAFFAgIEAAGALUZAA==.贼呆呆:BAAALAAFFAYIAgABLAAFFAgIEAAGALUZAA==.',['赤亮']='赤亮靓:BAAALAADCgMIAwAAAA==.',['起门']='起门拉猪:BAAALAAECgYIDAAAAA==.',['身材']='身材不怎么样:BAAALAAECgEIAQAAAA==.',['软绵']='软绵绵的我:BAACLAAFFH8SAAMHAAUINh9IRQA1AQAHAAUINh9IRQA1AQAfAAIIrR4aGQCnAAAsAAQKfxgAAx8ABgjUIzUkAEoCAB8ABgjUIzUkAEoCAAcABAihILTNAG0BAAAA.',['辣炒']='辣炒风油精:BAAALAADCgYIBgAAAA==.',['辣神']='辣神:BAAALAAECggIEgAAAA==.',['过云']='过云雨:BAAALAAECgMIAwAAAA==.',['迎着']='迎着灬风:BAAALAAECgMIAwAAAA==.',['还是']='还是费电:BAACLAAFFH8SAAMFAAYIohP6HgCGAQAFAAYIeBP6HgCGAQAUAAIIPxM1FAAvAAAsAAQKfy0AAxQABwhZGZYiAKEBABQABwitFJYiAKEBAAUABggFGSM8AGoBAAAA.还是躺着吧:BAAALAAFFAIIBAAAAA==.',['追风']='追风筝的人:BAAALAAFFAQIBAAAAA==.',['逍遥']='逍遥菜菜:BAABLAAFFH8GAAMEAAYIzQDPSABYAAAEAAQIXADPSABYAAANAAIIDwH7MwAOAAAAAA==.',['逐星']='逐星丨丨:BAAALAAFFAIIAgABLAAECgYIGwAHAE4kAA==.逐星猎丶:BAABLAAECn8bAAIHAAYITiR5OwBzAgAHAAYITiR5OwBzAgAAAA==.',['遗忘']='遗忘什么:BAACLAAFFH8bAAIBAAYIVxlXJgB7AQABAAYIVxlXJgB7AQAsAAQKfxwAAgEABgglI1c9AFUCAAEABgglI1c9AFUCAAAA.遗忘所有:BAACLAAFFH8ZAAIWAAUILxjlHQBtAQAWAAUILxjlHQBtAQAsAAQKfyAAAhYABghEHzYgAPgBABYABghEHzYgAPgBAAEsAAUUBggbAAEAVxkA.遗忘绿皮:BAAALAAFFAIIAgAAAA==.',['邪恶']='邪恶银渐层:BAAALAAECgYIBgAAAA==.',['邪活']='邪活:BAAALAADCgcIBwABLAAECgYIEwAMAAAAAA==.',['部落']='部落的敌人:BAAALAAECgYIBgAAAA==.部落达人:BAAALAAECgUIBQAAAA==.',['酸甜']='酸甜冰美式:BAAALAAECgIIAgAAAA==.',['酸萝']='酸萝卜别吃:BAAALAAECgQIBAAAAA==.',['酸黃']='酸黃瓜:BAAALAAECggIEAAAAA==.',['醉影']='醉影悠逸:BAAALAAFFAIIAgAAAA==.',['醉梦']='醉梦亦碎:BAAALAADCgMIAwAAAA==.醉梦洛丹伦:BAAALAAECgEIAQAAAA==.',['里苏']='里苏特:BAAALAAECgYIDwAAAA==.',['釭凶']='釭凶滴碰碰:BAAALAADCgQIBAAAAA==.',['铭酱']='铭酱:BAABLAAFFH8HAAIFAAIIlQaNaAA3AAAFAAIIlQaNaAA3AAAAAA==.',['铳墓']='铳墓:BAACLAAFFH8fAAIBAAYIjhJJJwB3AQABAAYIjhJJJwB3AQAsAAQKfzIAAgEACAjLH98MAF0CAAEACAjLH98MAF0CAAAA.',['银月']='银月之傲:BAAALAAECgEIAQAAAA==.',['闪电']='闪电喵变身:BAAALAAFFAIIBAAAAA==.',['闭眼']='闭眼旋转跳跃:BAAALAAECgYICQAAAA==.',['阿丽']='阿丽塔:BAACLAAFFH8PAAIGAAMI9RtvWgCbAAAGAAMI9RtvWgCbAAAsAAQKfyUAAwYACAgxHsQ7AI0CAAYACAjoHMQ7AI0CAAgABwj0HFsZAPIBAAAA.',['阿尔']='阿尔卑斯:BAAALAAECgUIBQAAAA==.阿尔娜特:BAAALAAECgcIBwAAAA==.阿尔萨斯:BAABLAAFFH8JAAIGAAgIbBg/CQBlAgAGAAgIbBg/CQBlAgAAAA==.',['雨落']='雨落:BAAALAAECgUIBQAAAA==.',['雪原']='雪原之歌:BAAALAAECgIIAgAAAA==.',['雪花']='雪花和牛:BAAALAAECgYIEwAAAA==.雪花肥肥:BAAALAAECgYIBgAAAA==.',['雪血']='雪血鹰:BAAALAADCgEIAQAAAA==.',['雷丶']='雷丶霆:BAAALAAECgYIBgAAAA==.',['雷姆']='雷姆我的爱:BAAALAADCgMIAwAAAA==.',['雷斯']='雷斯伲丫的:BAAALAAFFAIIAgAAAA==.',['雷霆']='雷霆之刃:BAAALAAECgYIDAAAAA==.',['霪乄']='霪乄猎:BAAALAAECgYICwAAAA==.',['霸王']='霸王灬斧:BAAALAAECgUIBQAAAA==.',['非主']='非主流:BAAALAAFFAIIAgAAAA==.',['顽偶']='顽偶摇摆:BAAALAAFFAQIAwAAAA==.',['领着']='领着白菜逛街:BAAALAAECgUIBwAAAA==.',['风后']='风后奇门:BAABLAAECn8iAAIUAAcIyRIfJwB8AQAUAAcIyRIfJwB8AQAAAA==.',['风景']='风景这边最好:BAAALAAECgYIBgAAAA==.',['飞扬']='飞扬世界:BAAALAAECgYIEQAAAA==.',['飞行']='飞行员老董:BAABLAAFFH8GAAIFAAYIXyQuBABcAgAFAAYIXyQuBABcAgAAAA==.',['香雪']='香雪海:BAAALAAECgEIAQAAAA==.',['馨馨']='馨馨心語:BAAALAAECgYIDAAAAA==.',['马元']='马元宝:BAAALAAECgIIAgAAAA==.',['魔导']='魔导师林溪:BAAALAAECgIIAgAAAA==.',['魔鬼']='魔鬼客星:BAABLAAFFH8FAAIVAAMIuAayIgBmAAAVAAMIuAayIgBmAAAAAA==.',['鳯若']='鳯若兮:BAAALAAECgYIBgAAAA==.',['鹅鹅']='鹅鹅饿:BAAALAADCgIIAgAAAA==.',['黄瓜']='黄瓜也疯狂:BAAALAADCgEIAQAAAA==.',['黑夜']='黑夜游侠:BAAALAAECgcIBwAAAA==.',['黑暗']='黑暗的恩赐丶:BAAALAAECgEIAQAAAA==.黑暗领主:BAAALAAECgQIBAAAAA==.',['黑猫']='黑猫酋长:BAABLAAECn8VAAIFAAYIxBdolwCaAQAFAAYIxBdolwCaAQAAAA==.',['黑色']='黑色的郁金香:BAAALAADCgEIAQAAAA==.',['鼻顶']='鼻顶豆舌翻肉:BAAALAAECgYIEgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end