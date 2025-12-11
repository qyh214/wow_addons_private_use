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
 local lookup = {'Rogue-Assassination','Shaman-Elemental','DeathKnight-Frost','Warrior-Fury','Druid-Guardian','Druid-Balance','Mage-Arcane','Mage-Frost','DemonHunter-Havoc','Paladin-Holy','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Shaman-Restoration','Paladin-Protection',}; local provider = {region='CN',realm='塞拉赞恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Agrius:BAAALAAECggIEAABLAAFFAgIBgABAMcWAA==.',Al='Alfa:BAAALAADCgcIBwAAAA==.',Do='Doll:BAAALAADCggICAAAAA==.',Ga='Gastonxudu:BAAALAADCgEIAQAAAA==.',Ge='Gevjon:BAAALAAECgQIBAAAAA==.',Go='Gozi:BAABLAAFFH8eAAICAAUIBxLXIgAsAQACAAUIBxLXIgAsAQAAAA==.',Mo='Morebeare:BAAALAAFFAIIAgAAAA==.Mosaic:BAAALAAFFAIIAgAAAA==.',Oo='Oops:BAAALAAFFAYIAgAAAA==.',['一米']='一米吧:BAAALAADCgEIAQAAAA==.',['上帝']='上帝的茶几:BAAALAAFFAIIAgAAAA==.',['乐多']='乐多一多乐:BAAALAADCgMIAwAAAA==.乐多多乐:BAAALAADCgIIAgAAAA==.',['仟煞']='仟煞:BAABLAAFFH8KAAIDAAUI+hecOABZAQADAAUI+hecOABZAQAAAA==.',['传说']='传说中的魍魉:BAAALAADCgcIBwAAAA==.',['全新']='全新职业:BAAALAAECgYIDAAAAA==.',['冉冉']='冉冉:BAAALAAECgIIAgAAAA==.',['冰殇']='冰殇丶丶:BAAALAAECgQIBAAAAA==.',['冰糖']='冰糖萌萌哒:BAAALAAECgYIBwAAAA==.',['冲锋']='冲锋:BAABLAAECn8VAAIEAAcIxQe+ZgDhAAAEAAcIxQe+ZgDhAAAAAA==.',['刚猎']='刚猎:BAAALAAFFAIIAgAAAA==.',['十月']='十月秋风:BAAALAAECgYIDwAAAA==.',['千变']='千变万化牛牛:BAAALAAECgYIBgAAAA==.',['半根']='半根神秘:BAAALAAECgIIAgAAAA==.',['原来']='原来不是你:BAAALAAECgIIAgAAAA==.',['呜喵']='呜喵王:BAAALAAECgYICQAAAA==.',['哼哼']='哼哼熊:BAAALAAECgYICQAAAA==.',['嗜血']='嗜血的小鸟:BAAALAAECgYICgAAAA==.',['团队']='团队杀手:BAABLAAECn8UAAICAAcI1Bc6LABlAQACAAcI1Bc6LABlAQAAAA==.',['堕落']='堕落为魂丶:BAAALAAECgYIBwAAAA==.',['塞拉']='塞拉赞恩牛:BAABLAAFFH8JAAMFAAIIMQ0LDgArAAAGAAIIWQmJNgA5AAAFAAIIMQ0LDgArAAAAAA==.',['墜星']='墜星:BAABLAAFFH8FAAMHAAII7wv9XQB/AAAHAAIIsAX9XQB/AAAIAAEIQxT1HgBHAAAAAA==.',['多乐']='多乐多多:BAAALAAECgQIBAAAAA==.',['夜的']='夜的最终章:BAAALAADCgMIAwAAAA==.',['大地']='大地之子萨满:BAAALAAECgYIBgAAAA==.',['大橘']='大橘子:BAAALAADCggICQAAAA==.',['天五']='天五:BAAALAADCgIIAgAAAA==.',['天地']='天地无法:BAABLAAFFH8GAAIHAAYIEwZuMQA+AQAHAAYIEwZuMQA+AQAAAA==.',['妖娆']='妖娆的风:BAAALAAECgUIBgAAAA==.',['姈钰']='姈钰:BAAALAADCgYIBgAAAA==.',['导弹']='导弹即将发射:BAAALAAFFAIIAgAAAA==.',['小學']='小學二年級:BAAALAADCgcIBwAAAA==.',['小小']='小小喵呜:BAABLAAFFH8JAAIJAAMIXRPxPgCSAAAJAAMIXRPxPgCSAAAAAA==.',['小戆']='小戆度:BAAALAAECgMIAwAAAA==.',['小朋']='小朋友:BAAALAAECgQIBAAAAA==.',['小蛋']='小蛋蛋:BAAALAAECgYICAAAAA==.',['小雪']='小雪飘零:BAAALAAECgYIBwAAAA==.',['小鸟']='小鸟:BAAALAAECgMIBAAAAA==.',['岁月']='岁月如歌:BAABLAAFFH8GAAMKAAYIswYuGAALAQAKAAUIlwYuGAALAQALAAEIegVWcAA+AAAAAA==.',['庇护']='庇护审判:BAAALAAECgMIAwAAAA==.',['弯刀']='弯刀:BAABLAAFFH8IAAIJAAIIwA+qRACWAAAJAAIIwA+qRACWAAAAAA==.',['悲剧']='悲剧虎:BAAALAAECgIIAgAAAA==.',['愛哭']='愛哭的天使:BAAALAAFFAIIAgAAAA==.',['我叫']='我叫刘华强:BAAALAAECgMIAwAAAA==.',['我是']='我是卧底:BAAALAAECgIIAQAAAA==.',['插棍']='插棍棍儿:BAAALAAECgUIBQAAAA==.',['无情']='无情:BAAALAAECgYIDgAAAA==.',['无敌']='无敌炉石呢:BAAALAADCggICAAAAA==.',['无聊']='无聊中等待:BAAALAAECgEIAQAAAA==.',['无限']='无限神:BAAALAAFFAIIAgAAAA==.',['旧人']='旧人难忆:BAAALAADCgEIAQABLAAFFAcIEgAMAKYPAA==.',['朵拉']='朵拉:BAAALAAFFAUIBAAAAA==.',['来自']='来自星星的拖:BAAALAADCgcIBwAAAA==.',['柳岩']='柳岩:BAAALAADCggICAAAAA==.',['椎名']='椎名真白:BAAALAAECggIEQABLAAECggIjwANAPomAA==.',['永不']='永不厌弃:BAAALAAFFAIIAgAAAA==.',['浩劫']='浩劫不当保安:BAAALAADCgIIAgABLAAFFAMIDwAJAHEUAA==.',['温暖']='温暖的小鸟:BAAALAAECgUIBgAAAA==.',['灬柒']='灬柒丷柒灬:BAAALAADCggICAAAAA==.',['煎饼']='煎饼摊老板:BAAALAADCggICAAAAA==.',['牧野']='牧野狂风:BAAALAAECgYIBgAAAA==.',['狂野']='狂野昊天:BAABLAAECn8bAAIEAAYIaBGOTQAtAQAEAAYIaBGOTQAtAQAAAA==.',['瓦王']='瓦王不朽:BAAALAADCggICAAAAA==.',['白月']='白月魁:BAAALAAECgYIBgAAAA==.',['破嗯']='破嗯哈博:BAAALAAECgYIBgAAAA==.',['碎花']='碎花雨:BAABLAAFFH8bAAICAAgILyTEAQDmAgACAAgILyTEAQDmAgAAAA==.',['突然']='突然醒来:BAAALAAECgQIBAAAAA==.',['红色']='红色体育生:BAAALAAECggIAgAAAA==.',['纸老']='纸老虎:BAAALAAECgIIAgAAAA==.',['绯红']='绯红蜗牛:BAAALAAECgYIBgAAAA==.',['美布']='美布列:BAAALAAECgIIAgAAAA==.',['艳兆']='艳兆菛:BAAALAAECgYIBgAAAA==.',['艾达']='艾达梅斯默:BAABLAAFFH8PAAIJAAMIcRTYHAD4AAAJAAMIcRTYHAD4AAAAAA==.',['芙蓉']='芙蓉王源:BAABLAAFFH8oAAIOAAgI/h/yBgCPAgAOAAgI/h/yBgCPAgAAAA==.',['花田']='花田错:BAABLAAFFH8JAAIOAAYImwb5OgAcAQAOAAYImwb5OgAcAQAAAA==.',['荒天']='荒天帝:BAAALAAECgYICgAAAA==.',['萌萌']='萌萌:BAAALAAECgIIAgAAAA==.萌萌旳拖拖:BAAALAAECggIEwAAAA==.萌萌的拖拖:BAAALAAECgEIAQAAAA==.',['裤链']='裤链卡毛:BAAALAADCgIIAgAAAA==.',['諾心']='諾心心:BAAALAAFFAIIAgAAAA==.',['诺雪']='诺雪:BAAALAADCggICAAAAA==.',['起名']='起名字费脑子:BAAALAADCgEIAQAAAA==.',['逮虾']='逮虾户:BAAALAAECgYICwAAAA==.',['那羅']='那羅無双華:BAAALAAECgcIEwAAAA==.',['里克']='里克休比:BAAALAAFFAIIBAABLAAFFAgIQgAHAMYhAA==.',['镜小']='镜小小:BAABLAAFFH8VAAIPAAYIPBfuFgCnAQAPAAYIPBfuFgCnAQAAAA==.',['阴沟']='阴沟巨蟒:BAAALAAECgYIBgAAAA==.',['陌小']='陌小帆:BAAALAAECgUIBQAAAA==.陌小忛:BAAALAAECgYIBgAAAA==.',['雀斑']='雀斑少女:BAAALAAECgYIBgAAAA==.',['霜满']='霜满天:BAABLAAFFH8sAAIPAAYI9xnEGACWAQAPAAYI9xnEGACWAQAAAA==.',['风怒']='风怒无常:BAAALAAECgYIBgAAAA==.',['骑个']='骑个隆咚呛:BAACLAAFFH8JAAIQAAIIEhc0EgCMAAAQAAIIEhc0EgCMAAAsAAQKfywAAhAABwhSHjQVAFACABAABwhSHjQVAFACAAAA.',['骑德']='骑德龙冬强:BAAALAAECggICAAAAA==.',['龙骑']='龙骑士骑龙:BAABLAAECn8VAAILAAgIQxZgLwDVAQALAAgIQxZgLwDVAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end