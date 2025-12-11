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
 local lookup = {'DemonHunter-Havoc','Mage-Arcane','Mage-Frost','DeathKnight-Frost','Paladin-Retribution','Hunter-Marksmanship','Paladin-Holy','Druid-Restoration','Druid-Balance','Warrior-Fury','Warrior-Protection','Shaman-Elemental','Hunter-BeastMastery','Unknown-Unknown','Shaman-Restoration','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Rogue-Assassination','Priest-Holy','Monk-Brewmaster','Hunter-Survival','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation',}; local provider = {region='CN',realm='巴尔古恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abbymilo:BAAALAAECgYIEgAAAA==.',Al='Aleif:BAABLAAFFH8FAAIBAAUIEh0VJwBYAQABAAUIEh0VJwBYAQAAAA==.Aleij:BAABLAAFFH8GAAIBAAYIWhSGHgCJAQABAAYIWhSGHgCJAQAAAA==.Aliee:BAAALAAECgYIEQAAAA==.',Av='Ava:BAAALAADCgIIAgAAAA==.',Cl='Classrhodey:BAACLAAFFH8IAAICAAIIrwotYAB7AAACAAIIrwotYAB7AAAsAAQKfxYAAwIABgivFMSJAHsBAAIABgiBE8SJAHsBAAMABAhAD/hpAMgAAAAA.',Cm='Cm:BAAALAAECgcIBwAAAA==.Cmx:BAAALAAECgYIDAAAAA==.',De='Deathoknight:BAAALAADCgYIBgAAAA==.',Ha='Halsey:BAAALAAECgQIBAAAAA==.Happiness:BAAALAAECgYICgAAAA==.',Hi='Hickey:BAABLAAFFH8GAAIEAAQI3xnqSwD/AAAEAAQI3xnqSwD/AAAAAA==.Hikari:BAAALAAFFAIIBAAAAA==.',Je='Jerrydh:BAAALAADCgcIBwAAAA==.',Li='Lingling:BAAALAAECgYIBgAAAA==.',Lo='Lovesong:BAAALAADCgQIBAAAAA==.',Ly='Lydk:BAAALAAECgYIBgAAAA==.',Ma='Makemecry:BAAALAAFFAMIAwAAAA==.',Mc='Mcdonaldmage:BAABLAAFFH8GAAICAAIIMyPCSgBvAAACAAIIMyPCSgBvAAAAAA==.',Me='Mengd:BAAALAADCgEIAQAAAA==.Mengzs:BAAALAAECgMIAwAAAA==.',Mi='Mikadohana:BAAALAAFFAIIAgABLAAFFAgIEgAEAPwbAA==.',Ra='Random:BAAALAAECgMIBgAAAA==.',Sa='Sacrifice:BAABLAAFFH8GAAIFAAMIgxiVPwCVAAAFAAMIgxiVPwCVAAAAAA==.',Se='Setsuna:BAAALAADCgQIBAAAAA==.',Sh='Shadows:BAACLAAFFH8KAAIGAAYIrAafEwBLAAAGAAYIrAafEwBLAAAsAAQKfyAAAgYACAiGHPYEAEACAAYACAiGHPYEAEACAAAA.',So='Sorakadoao:BAACLAAFFH8PAAIEAAUIiR5uMQDWAAAEAAUIiR5uMQDWAAAsAAQKfxoAAgQACAhyITcPAHMCAAQACAhyITcPAHMCAAAA.',Tt='Ttbivlzqncnu:BAABLAAFFH8IAAICAAYIrQ+HLABdAQACAAYIrQ+HLABdAQAAAA==.',Wb='Wbtno:BAAALAADCggICAAAAA==.',Wh='Whisperwindy:BAAALAAECgYIDgAAAA==.',['一夕']='一夕云一:BAAALAAECgYIDgAAAA==.',['七叶']='七叶团团:BAAALAAFFAIIAgAAAA==.七叶梧桐:BAAALAAECgQIBAAAAA==.七叶海棠:BAAALAAECgYICwAAAA==.',['七月']='七月:BAAALAAFFAIIAgAAAA==.',['万孚']='万孚马达:BAAALAADCgEIAQAAAA==.',['为倪']='为倪消瘦:BAAALAAECgEIAQAAAA==.',['丿小']='丿小虎:BAABLAAECn8rAAMFAAgI8R7tMACuAgAFAAgI8R7tMACuAgAHAAYIrhgeKQD4AAAAAA==.',['亦菲']='亦菲伊扬:BAAALAADCgYIBgAAAA==.',['今晚']='今晚秒七你:BAAALAAECgYICwAAAA==.',['仍然']='仍然想当年:BAAALAAECgYICgAAAA==.',['以圣']='以圣光之名:BAAALAAECgYIBgAAAA==.',['仮屋']='仮屋和奏:BAAALAAECgIIAwAAAA==.',['佛罗']='佛罗多:BAAALAAECgUIBgAAAA==.',['佛老']='佛老瓦:BAAALAAECgYICwAAAA==.',['依风']='依风听雨:BAAALAAECgYIDAAAAA==.',['倚风']='倚风听雨:BAAALAAECgIIAgAAAA==.',['假如']='假如:BAAALAAECgMIAwAAAA==.',['傲气']='傲气之法:BAABLAAFFH8OAAICAAYInBufBwA2AgACAAYInBufBwA2AgAAAA==.',['傻牛']='傻牛蛋:BAAALAADCgIIAgAAAA==.',['兔兔']='兔兔倪:BAAALAADCgYIBgAAAA==.',['公主']='公主:BAAALAADCggICAAAAA==.',['兽道']='兽道:BAAALAAECgYICgAAAA==.',['冕礼']='冕礼:BAAALAADCgQIBAAAAA==.',['冰糖']='冰糖丶雪梨:BAAALAAFFAIIAgAAAA==.',['冰魄']='冰魄:BAAALAAECgYIBgAAAA==.',['冷酷']='冷酷骑士:BAACLAAFFH8HAAIFAAIIvxItXQBIAAAFAAIIvxItXQBIAAAsAAQKfxUAAgUABwjxHdcsAOABAAUABwjxHdcsAOABAAAA.',['凛冬']='凛冬夜王:BAAALAAECgIIAgAAAA==.',['十万']='十万伏特:BAAALAADCgYIBgAAAA==.',['十九']='十九岁的骚年:BAAALAADCgcIBwAAAA==.',['十年']='十年泪:BAAALAAECgQIBwAAAA==.',['南城']='南城逆流:BAAALAAFFAIIAgAAAA==.',['卡琳']='卡琳娜丶:BAAALAAECggICAAAAA==.',['厄尔']='厄尔斯:BAAALAAECgEIAgAAAA==.',['叮当']='叮当是只猫:BAABLAAFFH8eAAMIAAUIXQwJIwAEAQAIAAUIXQwJIwAEAQAJAAQIZQhQJwB5AAAAAA==.',['可圈']='可圈可點:BAAALAAFFAMIBAAAAA==.',['叶落']='叶落之桔:BAAALAAECgYIDAAAAA==.',['吾家']='吾家有果宝:BAAALAAECgYIBgAAAA==.',['咧琛']='咧琛:BAAALAAECggIBwAAAA==.',['喆喆']='喆喆的小奶嘴:BAACLAAFFH8yAAMKAAYIiyG2DAD1AQAKAAYIiyG2DAD1AQALAAEIwQBpNAAkAAAsAAQKfy4AAwoACAi6IXQdANkCAAoABwjGJHQdANkCAAsAAgjIDGyIAGQAAAAA.',['地狱']='地狱猎魂者:BAAALAADCgUIBwAAAA==.',['埃辛']='埃辛诺斯烈焰:BAAALAAFFAIIAgAAAA==.',['夏天']='夏天的小雨:BAAALAAECgIIAgAAAA==.',['夏媞']='夏媞雅:BAAALAADCgcIBwAAAA==.',['夏孤']='夏孤离:BAABLAAFFH8MAAICAAIITRyYTQBTAAACAAIITRyYTQBTAAAAAA==.',['夕妖']='夕妖:BAAALAAECgUIBQAAAA==.',['夜色']='夜色大叔:BAAALAADCgUIBQAAAA==.',['夜里']='夜里无眠:BAACLAAFFH8TAAIMAAYIQBGsGAB5AQAMAAYIQBGsGAB5AQAsAAQKfxcAAgwACAg3Guc4ACMCAAwACAg3Guc4ACMCAAAA.',['大招']='大招丶怒火:BAAALAADCgMIAwAAAA==.大招动感光波:BAAALAADCgcIBwAAAA==.',['大爷']='大爷爸爸:BAABLAAFFH8IAAIFAAgIpAjLKwAkAQAFAAgIpAjLKwAkAQAAAA==.',['大篱']='大篱笆:BAABLAAFFH8IAAIKAAIIYRLUMwCbAAAKAAIIYRLUMwCbAAABLAAFFAUIDgAIABEMAA==.',['大米']='大米酿:BAAALAADCgQIBAAAAA==.',['天王']='天王星星:BAAALAAECgUIBQAAAA==.',['天空']='天空之泪:BAAALAAECgYIBwAAAA==.',['太一']='太一:BAAALAADCgMIAwAAAA==.',['奈亚']='奈亚子:BAACLAAFFH82AAMNAAgIXCKRAgDYAgANAAgIfSGRAgDYAgAGAAYIRyUhAQBgAgAsAAQKfx0AAgYACAi/IqMNAPYCAAYACAi/IqMNAPYCAAEsAAUUCAhfAA0A9CUA.',['奥丁']='奥丁圣:BAAALAAECgYIBgAAAA==.',['妮可']='妮可罗滨:BAAALAAECgMIAwAAAA==.',['娜美']='娜美薇薇安:BAAALAAECgYICAAAAA==.',['娜贝']='娜贝拉尔:BAAALAAECgEIAQAAAA==.',['孤问']='孤问万古愁:BAAALAAFFAIIAgAAAA==.',['孽畜']='孽畜还不跪下:BAAALAADCgYIBgAAAA==.',['密涅']='密涅瓦:BAAALAADCgQIBAAAAA==.',['射射']='射射丶更健康:BAAALAAECgYIBgAAAA==.',['小咸']='小咸鱼的猎手:BAAALAAECgYIDAABLAAFFAIIAgAOAAAAAA==.',['小喵']='小喵咪:BAAALAAECgYIEQAAAA==.',['小小']='小小战意:BAAALAAECgYIBgAAAA==.',['小明']='小明明灬:BAAALAADCgYIBgAAAA==.',['小牛']='小牛疯了:BAAALAADCgcIBwAAAA==.',['小诺']='小诺糖果落了:BAAALAADCgYIBgAAAA==.',['少爷']='少爷:BAAALAAFFAIIAgAAAA==.',['左右']='左右:BAAALAAECgMIAwAAAA==.',['师弟']='师弟:BAAALAAECgYIBgAAAA==.',['希尔']='希尔瓦娜嘶:BAAALAAECggICAAAAA==.',['帕拉']='帕拉汀:BAAALAADCggIEAAAAA==.',['幻境']='幻境制造者:BAAALAADCgIIAgAAAA==.',['弍公']='弍公子:BAAALAAECgYICwAAAA==.',['弯弓']='弯弓射雕:BAAALAADCggIDgAAAA==.',['快意']='快意的终潦倒:BAACLAAFFH8rAAMNAAYIQxwWIgCpAQANAAYIQxwWIgCpAQAGAAMIGA8FJgB8AAAsAAQKfyAAAwYABghzIpIuAA0CAAYABggHIZIuAA0CAA0AAwglI9X/AC8BAAAA.',['怪盗']='怪盗贞德:BAAALAAECgcIDAAAAA==.',['怿心']='怿心:BAAALAADCgEIAQAAAA==.',['恶魔']='恶魔猎物:BAAALAADCgIIAgAAAA==.',['情囚']='情囚丶:BAABLAAFFH8GAAIKAAII/RhPSQBKAAAKAAII/RhPSQBKAAABLAAFFAQIBgAEAN8ZAA==.',['我会']='我会永远爱桃:BAABLAAFFH8MAAMCAAMI3CTMHgA7AQACAAMI3CTMHgA7AQADAAEIzRdhHgBJAAAAAA==.',['我叫']='我叫霎聪君:BAABLAAECn8WAAIKAAgILhoMHQAAAgAKAAgILhoMHQAAAgAAAA==.',['我是']='我是真的蠢:BAAALAADCggICQAAAA==.',['战国']='战国英雄:BAAALAADCggICAAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8MAAIPAAYIJhxBEgDRAQAPAAYIJhxBEgDRAQAAAA==.',['拉妮']='拉妮过莱:BAAALAADCgEIAQAAAA==.',['撒克']='撒克斯:BAAALAAECgQIBAAAAA==.',['撩人']='撩人浊酒:BAACLAAFFH8VAAIQAAYIKxftAQCYAQAQAAYIKxftAQCYAQAsAAQKfxQAAhAACAj2HO8LAK4CABAACAj2HO8LAK4CAAAA.撩人浊酒一:BAABLAAFFH8dAAINAAYIEBS0NQBlAQANAAYIEBS0NQBlAQAAAA==.',['无处']='无处安放灵魂:BAAALAADCgYIDAAAAA==.',['旧日']='旧日:BAAALAAECgEIAQAAAA==.',['明日']='明日大侠一:BAABLAAFFH8MAAIFAAYIlBJ4JwA9AQAFAAYIlBJ4JwA9AQAAAA==.',['明明']='明明灬狗:BAAALAAECgYIDAAAAA==.',['晨曦']='晨曦若岚:BAABLAAFFH8IAAMMAAYIlQL8KQDxAAAMAAYIlQL8KQDxAAAPAAIIXBYXUAB7AAAAAA==.',['曙光']='曙光:BAAALAAECgYIDAAAAA==.',['曜光']='曜光如炬:BAABLAAFFH8GAAIFAAYIcA84CADjAQAFAAYIcA84CADjAQAAAA==.',['曼玉']='曼玉张:BAAALAADCgEIAQAAAA==.',['月光']='月光姬:BAAALAAECgcIDgAAAA==.',['未知']='未知劣人:BAAALAAECgEIAQAAAA==.',['朴朴']='朴朴:BAAALAAECgIIAgAAAA==.',['来自']='来自猩猩的你:BAABLAAFFH8MAAMRAAIIqBtxBACQAAASAAII8BhPNQCmAAARAAIIMxBxBACQAAAAAA==.',['柒柒']='柒柒:BAAALAAECgYIBgAAAA==.',['柯基']='柯基不爱洗澡:BAABLAAFFH8fAAIEAAYIZiLhGgDLAQAEAAYIZiLhGgDLAQAAAA==.柯基小短腿:BAABLAAFFH8KAAIBAAUIeRdoKQBHAQABAAUIeRdoKQBHAQAAAA==.',['桂小']='桂小镁:BAAALAAFFAgIBAAAAA==.',['桦哥']='桦哥桀骜:BAAALAAECgYIDAAAAA==.',['梦境']='梦境的米迪娅:BAAALAAECgYICwAAAA==.',['梦里']='梦里迷路:BAAALAADCgIIAgAAAA==.',['武当']='武当当武:BAAALAAECggICAAAAA==.',['死出']='死出个未来:BAAALAADCgYIBgAAAA==.',['死灵']='死灵骑士领主:BAAALAADCgYICAAAAA==.',['每日']='每日依恋:BAAALAAFFAIIBAAAAA==.',['毛姐']='毛姐:BAABLAAFFH8OAAIKAAIIrBAqTgBGAAAKAAIIrBAqTgBGAAAAAA==.',['永恒']='永恒的小水:BAAALAAECgYIBwAAAA==.',['江烟']='江烟万缕:BAABLAAECn8aAAIFAAgIryPuIgDmAgAFAAgIryPuIgDmAgABLAAFFAgISgAKALIhAA==.',['沐雨']='沐雨橙风:BAAALAADCggICwAAAA==.',['沐霂']='沐霂:BAAALAAECgEIAQAAAA==.',['法涛']='法涛无赦:BAACLAAFFH8XAAMCAAYIDRTuKQDrAAACAAYIDRTuKQDrAAADAAEIkiMQHABdAAAsAAQKfyEAAwMACAh/Hg4jAAcCAAIACAjNGY4+AFECAAMABgiwIA4jAAcCAAAA.',['波本']='波本酒丶:BAABLAAFFH8UAAITAAgIuiM/AAANAwATAAgIuiM/AAANAwAAAA==.',['流浪']='流浪剑客:BAAALAAECgYIBwAAAA==.',['海盗']='海盗比卡:BAAALAAECgEIAQAAAA==.海盗逼比:BAAALAAECgYIBgAAAA==.',['灬威']='灬威利旺卡灬:BAAALAAECgcICgAAAA==.',['灵儿']='灵儿逍遥:BAAALAAECgYIEgAAAA==.',['炽炎']='炽炎罗刹:BAAALAADCgEIAQAAAA==.',['熊熊']='熊熊臭臭香:BAAALAAECgQIBAAAAA==.',['熔岩']='熔岩领主:BAAALAAECgEIAQAAAA==.',['牛人']='牛人终结者:BAAALAADCgYIBgAAAA==.',['牛而']='牛而逼之:BAAALAAECgYIBgAAAA==.',['牧落']='牧落星尘:BAAALAADCgQIBAAAAA==.',['独自']='独自风飘一:BAABLAAFFH8YAAIFAAYIjhp8GACQAQAFAAYIjhp8GACQAQAAAA==.',['猫爪']='猫爪子米米:BAAALAAECgYIEgAAAA==.',['玖伍']='玖伍贰柒囧:BAAALAADCgEIAgAAAA==.',['玛尔']='玛尔兰:BAAALAAECgEIAQAAAA==.',['玥溪']='玥溪:BAAALAADCggICAAAAA==.',['生死']='生死囿命:BAAALAADCggICAAAAA==.',['甲子']='甲子年:BAABLAAECn8UAAIEAAgIQxeIVwBIAgAEAAgIQxeIVwBIAgAAAA==.',['电钻']='电钻:BAAALAAECgcIBwAAAA==.',['白鹤']='白鹤童子:BAAALAAFFAIIAgAAAA==.',['眷影']='眷影年华:BAAALAADCggICAAAAA==.',['眼眸']='眼眸里的微笑:BAAALAADCgEIAQAAAA==.',['祢灬']='祢灬豆子:BAAALAAFFAQIBAAAAA==.',['秋夜']='秋夜萤火:BAAALAAECgIIAgAAAA==.',['种田']='种田大爷:BAABLAAFFH8IAAIFAAIIswdpVwCLAAAFAAIIswdpVwCLAAAAAA==.',['童心']='童心未泯:BAAALAADCgcIBwAAAA==.',['精灵']='精灵之箭:BAAALAAECgYIBwAAAA==.',['糖果']='糖果仔:BAAALAAECgYICgAAAA==.',['紫怡']='紫怡嫣然:BAAALAAECgIIAgAAAA==.',['红牛']='红牛宝宝:BAAALAADCgQIBQAAAA==.',['纯情']='纯情:BAAALAADCgMIAwAAAA==.',['纹身']='纹身噶:BAAALAAECgYIDQAAAA==.',['给你']='给你的承诺:BAAALAAECgYIEAAAAA==.',['给我']='给我加个嗜血:BAABLAAFFH8JAAISAAII6gaDTgCEAAASAAII6gaDTgCEAAAAAA==.',['绝代']='绝代佳人:BAAALAAECgMIAwAAAA==.',['绫绡']='绫绡:BAABLAAFFH8GAAIFAAIIjiA8TgBdAAAFAAIIjiA8TgBdAAAAAA==.',['罗伦']='罗伦亚:BAAALAAECgYIBgAAAA==.罗伦亚佐罗:BAAALAAECgEIAQAAAA==.',['翻滚']='翻滚吧灬小贤:BAAALAAECgUICgAAAA==.',['老暴']='老暴伍:BAABLAAFFH8IAAIFAAUIrRTtKQAvAQAFAAUIrRTtKQAvAQAAAA==.老暴叁:BAAALAAECgYIBgAAAA==.老暴壹:BAABLAAFFH8FAAIIAAUIIg4cIQAWAQAIAAUIIg4cIQAWAQAAAA==.老暴拾叁:BAAALAAFFAIIAgAAAA==.老暴陆:BAAALAAFFAIIAgAAAA==.',['聂庞']='聂庞重生:BAABLAAFFH8LAAIEAAcIVQnWawBiAAAEAAcIVQnWawBiAAAAAA==.',['胖蜀']='胖蜀黍:BAAALAADCggIDgAAAA==.',['自己']='自己开减伤:BAABLAAFFH8GAAIIAAYIXBtHEADCAQAIAAYIXBtHEADCAQAAAA==.',['自然']='自然祝福:BAAALAAFFAIIAgAAAA==.',['與子']='與子偕老丶默:BAABLAAECn8XAAIUAAgI3A3MUgCMAQAUAAgI3A3MUgCMAQAAAA==.',['舞动']='舞动的弓弦:BAACLAAFFH8jAAINAAYISBYMNgBkAQANAAYISBYMNgBkAQAsAAQKfzQAAg0ACAhTIJYvAJoCAA0ACAhTIJYvAJoCAAAA.',['花田']='花田半亩:BAAALAAECgYICgAAAA==.',['花间']='花间晚照:BAAALAAFFAgIAgAAAA==.',['芸尛']='芸尛咿:BAAALAAECgUICwABLAAFFAgIMQACAK8aAA==.',['苏轼']='苏轼:BAAALAAFFAgIAwAAAA==.',['苏辙']='苏辙:BAABLAAFFH8OAAIVAAgIZyJjBgDwAQAVAAgIZyJjBgDwAQAAAA==.',['若叶']='若叶睦:BAAALAAFFAQIBAAAAA==.',['莉丝']='莉丝缇亚:BAAALAAECgYIDwAAAA==.',['萨拉']='萨拉塔丝:BAAALAAECgUIBQAAAA==.',['萨莽']='萨莽禅心:BAAALAAFFAIIAgAAAA==.',['蓝衣']='蓝衣筱筱:BAAALAADCgQIBAAAAA==.',['蠕动']='蠕动的猎豹:BAABLAAFFH8SAAIJAAUIqg6yGwD2AAAJAAUIqg6yGwD2AAAAAA==.',['袜子']='袜子少一只:BAAALAAECgEIAQAAAA==.',['诅咒']='诅咒之血:BAAALAAECgYIDQAAAA==.',['诗桃']='诗桃微白:BAAALAAECgYIBgAAAA==.',['请给']='请给我面包:BAAALAAFFAYIAgAAAA==.',['贼少']='贼少:BAAALAADCgcIBwAAAA==.',['赤龙']='赤龙影:BAABLAAFFH8FAAIKAAUIahGtJwAyAQAKAAUIahGtJwAyAQAAAA==.',['超美']='超美小猪:BAACLAAFFH8HAAIJAAII7SEDFADHAAAJAAII7SEDFADHAAAsAAQKfzUAAwkACAhyI1oJAC0DAAkACAhyI1oJAC0DAAgABwj5DKZxAEIBAAAA.',['超萌']='超萌小猪:BAABLAAFFH8KAAMIAAYIXhCOJAD2AAAIAAQIVBOOJAD2AAAJAAMIoxfkHQDaAAAAAA==.',['辛洛']='辛洛斯毁灭者:BAAALAAECgYIDQAAAA==.',['辣堡']='辣堡:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥骑仕:BAABLAAFFH8GAAIFAAIIIAjacQA9AAAFAAIIIAjacQA9AAAAAA==.',['逐渐']='逐渐同化:BAAALAAECgYIBgAAAA==.',['遺夨']='遺夨十年:BAABLAAFFH8HAAIFAAIIoR5tVABNAAAFAAIIoR5tVABNAAAAAA==.',['郭蝈']='郭蝈蝈郭:BAAALAADCggIDwAAAA==.',['酩酊']='酩酊旅途:BAAALAAECgIIAgAAAA==.',['采矿']='采矿二号:BAAALAADCgEIAQAAAA==.',['采药']='采药二号:BAAALAAECgMIAwAAAA==.',['野兽']='野兽精灵:BAAALAADCgEIAQAAAA==.',['银狼']='银狼哮月:BAAALAADCgEIAQAAAA==.',['锟铻']='锟铻:BAAALAAECgYIBgAAAA==.',['闲鱼']='闲鱼:BAAALAADCgYIBgAAAA==.',['陈汐']='陈汐雯小猪头:BAAALAAECgQICAAAAA==.陈汐雯的爸爸:BAAALAAECgYIDQAAAA==.',['随便']='随便整一号:BAAALAAECgIIAgAAAA==.随便整三号:BAAALAAECgEIAQAAAA==.',['雨小']='雨小点:BAABLAAFFH8IAAINAAIIVwV7rQA4AAANAAIIVwV7rQA4AAAAAA==.雨小面:BAAALAAFFAIIAgAAAA==.',['雪霁']='雪霁仞霜:BAABLAAFFH8KAAIEAAgIjgW7bQBaAAAEAAgIjgW7bQBaAAAAAA==.',['雲海']='雲海弦月:BAABLAAFFH8IAAINAAYIIgaIhABMAAANAAYIIgaIhABMAAAAAA==.',['露普']='露普斯蕾琪娜:BAAALAAECgEIAQAAAA==.',['青柠']='青柠檬:BAAALAAFFAIIAgAAAA==.',['青笺']='青笺:BAAALAAECgEIAgAAAA==.',['青鱂']='青鱂:BAAALAADCgMIAwAAAA==.',['青鸢']='青鸢丶罗兰:BAACLAAFFH8IAAMNAAIIiBXWlQBCAAAGAAII9wZ+LABtAAANAAIIiBXWlQBCAAAsAAQKfxUABA0ABgi2HMGHANIBAA0ABgi2HMGHANIBABYAAgjvCRgiAGEAAAYAAQhiFEPAADAAAAAA.',['面对']='面对死亡吧:BAAALAADCgEIAQAAAA==.',['頭上']='頭上有犄角:BAABLAAFFH8QAAIUAAYI4h8kCgAmAgAUAAYI4h8kCgAmAgAAAA==.',['颖女']='颖女奥:BAAALAAECgYIBgAAAA==.颖女宠:BAAALAADCgQIAQAAAA==.颖女帝:BAAALAAECgYIDQAAAA==.颖女狂:BAAALAAECgYIEAAAAA==.颖女祭:BAAALAAECgYICQAAAA==.',['风云']='风云第一刀:BAAALAAECgYIDQAAAA==.',['风婷']='风婷格:BAAALAAECgYIBgAAAA==.风婷阁:BAAALAAECgYIBgAAAA==.',['风暴']='风暴汽水:BAAALAAFFAIIAgAAAA==.',['风梳']='风梳烟沐:BAAALAADCgYICwAAAA==.',['飞哥']='飞哥仔:BAAALAADCgYIBgAAAA==.',['飞飞']='飞飞的猪猪:BAAALAAECgYIBgAAAA==.',['马戏']='马戏团公约:BAAALAAECgYIDQAAAA==.',['鬼服']='鬼服玩蛇:BAABLAAFFH8GAAINAAIICSElhABNAAANAAIICSElhABNAAAAAA==.',['魔界']='魔界之圣寂:BAABLAAECn8XAAIFAAYI1yIfJwD5AQAFAAYI1yIfJwD5AQAAAA==.魔界之大鼻涕:BAAALAAECgYIEAAAAA==.魔界之小德:BAAALAADCgMIAwAAAA==.魔界之幽雅:BAAALAAECgIIAgAAAA==.魔界之星幻:BAAALAADCgYIBgAAAA==.魔界之法神:BAAALAAECgYIEQAAAA==.魔界之混沌:BAAALAAECgYICwAAAA==.魔界之游迪安:BAAALAAECgYIBgAAAA==.魔界之猎刃:BAAALAAECgYIDgAAAA==.魔界之索尔:BAAALAAECgYIBgAAAA==.魔界之迪克:BAAALAAECgYIBgAAAA==.魔界之鼻涕:BAAALAAECgYIDAAAAA==.',['黑暗']='黑暗撒满:BAAALAADCgUIBQAAAA==.黑暗若水:BAAALAADCgIIAgAAAA==.黑暗虚空:BAAALAADCggIFAAAAA==.',['黑珍']='黑珍珠帕特:BAAALAAECgUIBwAAAA==.',['龙之']='龙之呼吸:BAACLAAFFH8dAAQXAAYIDwyJDwA8AQAXAAYIDwyJDwA8AQAYAAMIzxEEDACJAAAZAAII+ALLGQBnAAAsAAQKfxkABBcABwi0EzgPAGMBABcABwi0EzgPAGMBABgABAgGDnEUAOAAABkABAjiCMtTAMAAAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end