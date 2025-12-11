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
 local lookup = {'Mage-Arcane','Monk-Windwalker','Shaman-Restoration','DeathKnight-Frost','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Warrior-Fury','Mage-Frost','Priest-Discipline','Priest-Holy','Evoker-Preservation','Hunter-BeastMastery','Warlock-Destruction','DeathKnight-Blood','Warrior-Protection','Warlock-Demonology','Druid-Feral','Paladin-Retribution','Shaman-Elemental','Paladin-Protection',}; local provider = {region='CN',realm='烈焰荆棘',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alistair:BAAALAAECgYIBgAAAA==.',An='Annaly:BAAALAADCgcIBwAAAA==.',Bi='Bigboon:BAAALAADCgMIAwAAAA==.',Co='Cooldog:BAAALAAECgQIBAAAAA==.',De='Destiny:BAAALAADCgUIBQAAAA==.',Ec='Echo:BAAALAADCgIIAgAAAA==.',El='Elysia:BAABLAAFFH8YAAIBAAUIVxkTMgA5AQABAAUIVxkTMgA5AQAAAA==.',Fa='Fat:BAABLAAFFH8IAAICAAYI8wVsDAAHAQACAAYI8wVsDAAHAQAAAA==.',Ho='Hohoh:BAABLAAFFH8LAAIDAAQI/yIuCgCaAQADAAQI/yIuCgCaAQAAAA==.',Ju='Justeak:BAABLAAFFH8KAAIEAAgIVBwxCAB2AgAEAAgIVBwxCAB2AgAAAA==.',Li='Liurui:BAAALAADCgIIAgAAAA==.',Ma='Maggle:BAAALAAECgMIAwAAAA==.',Mu='Mugaid:BAAALAAECgYICwAAAA==.',Pl='Playercsumsi:BAAALAAECgMIAwAAAA==.',Wa='Wahaha:BAABLAAFFH8NAAMFAAYIbBhSCQCdAQAFAAQI0SJSCQCdAQAGAAYIehIXGQBmAQAAAA==.',['一指']='一指:BAABLAAFFH8IAAIDAAMIKg93RwCQAAADAAMIKg93RwCQAAAAAA==.',['一电']='一电穿八个:BAAALAAECgIIAgAAAA==.',['丁瑞']='丁瑞明:BAACLAAFFH8GAAIHAAYIOQwFKgBDAQAHAAYIOQwFKgBDAQAsAAQKfxUAAgcACAiEE14oALoBAAcACAiEE14oALoBAAAA.',['不懂']='不懂:BAACLAAFFH8GAAIIAAIIOhSiMACeAAAIAAIIOhSiMACeAAAsAAQKfzAAAggACAjhI6UGANUCAAgACAjhI6UGANUCAAAA.',['丨少']='丨少帅乄:BAAALAAFFAIIAgAAAA==.',['丶糯']='丶糯米浠丨:BAABLAAFFH8LAAMBAAMIexEHRgCKAAABAAMIexEHRgCKAAAJAAEISA3EGQA8AAAAAA==.丶糯米饭丨:BAAALAAECggICAAAAA==.',['丶红']='丶红:BAAALAAECgMIAwAAAA==.',['乱世']='乱世神牛:BAAALAADCggIAgAAAA==.',['二零']='二零四六:BAAALAAECgUICQAAAA==.',['井上']='井上眞央:BAAALAADCgMIBQAAAA==.',['亚瑟']='亚瑟:BAAALAADCggIDgAAAA==.',['亜喺']='亜喺亜:BAAALAAECggIDwAAAA==.',['伊然']='伊然爱睿:BAABLAAFFH8KAAMKAAIIOhOjBAB6AAAKAAIIOhOjBAB6AAALAAIIwwJ3QgBvAAAAAA==.',['伊甸']='伊甸:BAACLAAFFH8OAAIMAAYIYg0ZDgBbAQAMAAYIYg0ZDgBbAQAsAAQKfxYAAgwACAg1F/8HAAgCAAwACAg1F/8HAAgCAAAA.',['佐佐']='佐佐木希:BAACLAAFFH8gAAINAAgIQBYrGwDIAQANAAgIQBYrGwDIAQAsAAQKfxkAAg0ABghwGPNsAGkBAA0ABghwGPNsAGkBAAAA.',['你很']='你很紧张同学:BAABLAAFFH8GAAIOAAYITBd/KQB0AQAOAAYITBd/KQB0AQAAAA==.',['你说']='你说咋啦:BAAALAAECggICAAAAA==.',['元氣']='元氣戰:BAAALAAFFAYIAgAAAA==.',['光之']='光之耀:BAAALAAECgEIAQAAAA==.',['八尺']='八尺琼勾玉:BAAALAAECgYIBgAAAA==.',['冷誓']='冷誓狂言:BAAALAAECgYIAgAAAA==.',['凛冬']='凛冬降至:BAAALAAECgMIAwAAAA==.',['凯文']='凯文卡斯兰娜:BAAALAAECgUIBQAAAA==.',['别吃']='别吃果冻呢:BAABLAAFFH8MAAMEAAYIJwrgPgA/AQAEAAYIJwrgPgA/AQAPAAYIZQN4EADrAAAAAA==.',['千劫']='千劫:BAAALAAFFAIIAgAAAA==.',['卡尼']='卡尼吉亚:BAAALAADCgQIBAAAAA==.',['双刀']='双刀飞舞:BAABLAAFFH8cAAMIAAYIphq0EgDEAQAIAAYIKRq0EgDEAQAQAAUIkxSiFAAYAQAAAA==.',['吴钩']='吴钩霜雪明:BAAALAAFFAMIAgAAAA==.',['周六']='周六:BAABLAAFFH8GAAIGAAIIwQS7UwBNAAAGAAIIwQS7UwBNAAAAAA==.',['周末']='周末:BAAALAAFFAIIAgAAAA==.',['喷火']='喷火小水龙:BAAALAAECgUIBQAAAA==.',['地狱']='地狱熔炉之拳:BAAALAAFFAIIAgAAAA==.',['夕络']='夕络:BAAALAADCgYIBgAAAA==.',['夜色']='夜色小猫:BAAALAADCgUIAwAAAA==.',['天灵']='天灵灵:BAAALAAFFAIIAgAAAA==.',['奇拉']='奇拉维特:BAAALAADCgQIBAAAAA==.',['女皇']='女皇武则天:BAAALAAECgYIAwAAAA==.',['好大']='好大的一头牛:BAAALAAECgcIBwAAAA==.',['嫣然']='嫣然丶笑语:BAABLAAFFH8JAAINAAIICBFGkgBEAAANAAIICBFGkgBEAAAAAA==.',['孤冷']='孤冷渊:BAABLAAFFH8PAAIEAAYIaRTFMQB0AQAEAAYIaRTFMQB0AQAAAA==.',['小学']='小学生:BAAALAAFFAQIBAAAAA==.',['小小']='小小脚丫:BAAALAAECgIIAwAAAA==.',['小锤']='小锤四十:BAAALAAECgUIBQABLAAFFAgICgAEAFQcAA==.',['尛猪']='尛猪:BAAALAAECgEIAQAAAA==.',['尛魔']='尛魔女:BAAALAAECgcIEgAAAA==.',['屠梦']='屠梦者:BAAALAAECgUIBgAAAA==.',['左摇']='左摇右摆:BAAALAADCgQIBAAAAA==.',['德治']='德治萨批:BAABLAAFFH8KAAMGAAYIqAciIQAWAQAGAAYIqAciIQAWAQAFAAQIUwvrIACzAAABLAAFFAgICgAEAFQcAA==.',['悠久']='悠久之伤:BAAALAADCgcIBwAAAA==.悠久之翼:BAAALAAECgQIBAAAAA==.',['戈罗']='戈罗姆咆哮:BAAALAAECgYIBgAAAA==.',['我需']='我需要治疗:BAAALAAECgEIAQAAAA==.',['战丨']='战丨士:BAAALAAFFAIIAgAAAA==.',['扶墙']='扶墙站好:BAAALAAECgYICwAAAA==.',['拉啦']='拉啦小法:BAABLAAECn8WAAIJAAgIgRvbDgDSAQAJAAgIgRvbDgDSAQAAAA==.',['提里']='提里奥弗丁:BAAALAAECgYIBgAAAA==.',['明俐']='明俐汽修前台:BAAALAAECgIIAgAAAA==.',['明月']='明月风流:BAAALAAFFAIIAwAAAA==.',['是烈']='是烈火是枯枝:BAABLAAFFH8GAAIRAAIIshyLDwClAAARAAIIshyLDwClAAAAAA==.',['朽木']='朽木可雕:BAAALAAECgEIAQAAAA==.',['梦厶']='梦厶吟:BAACLAAFFH8GAAIBAAYI3RzrGwCqAQABAAYI3RzrGwCqAQAsAAQKfxoAAgkACAjWHG8HAFYCAAkACAjWHG8HAFYCAAAA.',['楚默']='楚默:BAAALAAFFAYIAwAAAA==.',['此子']='此子断不可留:BAAALAADCgcIBwAAAA==.',['水煮']='水煮熊掌:BAAALAAECgQIBAAAAA==.',['清朗']='清朗少年:BAAALAADCgIIAgAAAA==.',['牛的']='牛的一鼻:BAAALAADCgYIBgAAAA==.',['独狼']='独狼:BAAALAAECgYIEgAAAA==.',['狻猊']='狻猊:BAABLAAFFH8HAAIFAAMI3AuVKABxAAAFAAMI3AuVKABxAAAAAA==.',['猎杀']='猎杀视线:BAAALAAECgcIDwAAAA==.',['玩个']='玩个萨满:BAAALAADCggICAAAAA==.',['玩的']='玩的开心:BAAALAADCgcIDQAAAA==.',['白银']='白银之风:BAAALAADCgYIDAAAAA==.',['皇战']='皇战:BAAALAAECgQIBAAAAA==.',['礼拜']='礼拜天:BAAALAAFFAIIAgAAAA==.',['神鬼']='神鬼迷踪步:BAACLAAFFH8XAAIJAAMIUiIsCgDNAAAJAAMIUiIsCgDNAAAsAAQKfxUAAgkACAgQIGINAOcBAAkACAgQIGINAOcBAAAA.',['科比']='科比:BAABLAAECn8cAAISAAgIgh1UCgCtAgASAAgIgh1UCgCtAgAAAA==.',['笑尽']='笑尽一杯酒:BAAALAADCgIIAgAAAA==.',['笑语']='笑语嫣云:BAAALAAFFAIIAgAAAA==.笑语嫣然:BAAALAAFFAIIBAAAAA==.',['紫殿']='紫殿流星:BAABLAAFFH8KAAMRAAIIOw36FwCUAAARAAII4Qv6FwCUAAAOAAII3guKUgB6AAAAAA==.',['紫气']='紫气东来:BAAALAAECgEIAQAAAA==.',['组人']='组人专用号:BAAALAAECgYIDAAAAA==.',['维生']='维生素泡腾片:BAAALAAFFAIIAgAAAA==.',['羿射']='羿射九日:BAAALAAECgYIBgAAAA==.',['花岗']='花岗岩:BAAALAAECgEIAQAAAA==.',['花语']='花语和薰:BAAALAAECgYIBAAAAA==.',['萌萌']='萌萌的宝宝:BAABLAAFFH8FAAITAAIIhwuMcAA+AAATAAIIhwuMcAA+AAAAAA==.',['萨顶']='萨顶顶:BAABLAAFFH8RAAMUAAYIYA61GwBiAQAUAAYIYA61GwBiAQADAAEIlAGRgQAWAAABLAAFFAgICgAEAFQcAA==.',['萨鲁']='萨鲁法尔大王:BAAALAAECgIIAgAAAA==.',['落叶']='落叶不随风:BAAALAAECgYIDgAAAA==.',['血铃']='血铃铛:BAAALAADCgYIBgAAAA==.',['训练']='训练中的英雄:BAAALAAFFAIIAgAAAA==.',['语笑']='语笑嫣然:BAABLAAFFH8GAAIJAAIIYBTVEQCLAAAJAAIIYBTVEQCLAAABLAAFFAIICQANAAgRAA==.',['赞达']='赞达拉万古长:BAAALAAECgIIAgAAAA==.',['路边']='路边一条丶丶:BAABLAAFFH8VAAINAAYIWR51HADBAQANAAYIWR51HADBAQABLAAFFAgICgAEAFQcAA==.',['逆风']='逆风猎杀:BAAALAAECgcICAAAAA==.',['逍遥']='逍遥一射:BAAALAAECggIEAAAAA==.',['都怪']='都怪我太执着:BAAALAAECgYIDAAAAA==.',['采花']='采花大盗:BAAALAAFFAIIBAAAAA==.',['钟神']='钟神秀:BAABLAAFFH8KAAILAAII+QekOgB/AAALAAII+QekOgB/AAAAAA==.',['铂爵']='铂爵瓦坎达:BAACLAAFFH8dAAITAAUIbx9XHQB3AQATAAUIbx9XHQB3AQAsAAQKfy8AAxMACAhqJEMkAOACABMACAhgJEMkAOACABUABgiUGhoVAHEBAAAA.',['银翼']='银翼之狐:BAAALAAECgYICwAAAA==.',['闪电']='闪电五连鞭:BAABLAAFFH8GAAIDAAII2AZ7bABOAAADAAII2AZ7bABOAAAAAA==.',['阿九']='阿九丶:BAABLAAFFH8FAAITAAUI2ALUVwBLAAATAAUI2ALUVwBLAAAAAA==.',['阿波']='阿波尼亚:BAAALAAECgYICAAAAA==.',['雪之']='雪之武神:BAAALAADCgQIBAAAAA==.雪之离离:BAAALAADCgQIBAAAAA==.雪之红牛:BAAALAADCgQIBAAAAA==.',['风涯']='风涯:BAABLAAFFH8LAAMDAAYI3CAACwAdAgADAAYI3CAACwAdAgAUAAIIjgW7NwB9AAAAAA==.',['香瓜']='香瓜瓜:BAAALAADCgQIBAAAAA==.',['馨馨']='馨馨相映:BAAALAAECgYICAAAAA==.',['骑士']='骑士四重奏:BAAALAAECggICQAAAA==.',['齐天']='齐天大圣:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end