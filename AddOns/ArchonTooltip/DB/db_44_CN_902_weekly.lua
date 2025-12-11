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
 local lookup = {'Rogue-Assassination','Warrior-Protection','Mage-Frost','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Mage-Arcane','Paladin-Retribution','Druid-Balance','Priest-Holy','Priest-Shadow','Shaman-Restoration','Warrior-Fury','Warrior-Arms','Rogue-Outlaw','DeathKnight-Frost','Hunter-BeastMastery','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Paladin-Protection',}; local provider = {region='CN',realm='黑锋哨站',name='CN',type='weekly',zone=44,date='2025-12-10',data={Bi='Biubiua:BAAALAAECgUIBQAAAA==.',He='Hedy:BAAALAAECgYIDQAAAA==.',Ly='Lynne:BAAALAAECgUIBQAAAA==.',Na='Nai:BAAALAAECgYIBgAAAA==.',Rm='Rmrogueo:BAABLAAFFH8OAAIBAAgINh+VAQCqAgABAAgINh+VAQCqAgAAAA==.Rmroguez:BAABLAAFFH8GAAIBAAYIwBNnCQCGAQABAAYIwBNnCQCGAQAAAA==.',Sd='Sder:BAAALAAFFAEIAQAAAA==.',Tr='Trickster:BAAALAAECgYIBwAAAA==.',Xg='Xguzz:BAAALAADCggICQAAAA==.',['一个']='一个全家桶:BAAALAAFFAIIAgAAAA==.',['一個']='一個路人:BAAALAAECgYICwAAAA==.',['一杀']='一杀千年:BAABLAAFFH8HAAICAAMIVRLOIAB5AAACAAMIVRLOIAB5AAAAAA==.',['一眸']='一眸照人寒:BAAALAADCgQIBAAAAA==.',['丨暖']='丨暖阳丶:BAAALAADCgEIAQAAAA==.',['丫晋']='丫晋阳郡苗丫:BAAALAAECgUIBQAAAA==.',['丶點']='丶點:BAABLAAECn8iAAIDAAYIrRewGwBJAQADAAYIrRewGwBJAQAAAA==.',['举射']='举射无双:BAAALAAECgYIDAAAAA==.',['乐玲']='乐玲利:BAAALAAECgYICAAAAA==.',['乖巧']='乖巧宝宝的狸:BAAALAAECgQIBAAAAA==.',['九叶']='九叶重楼:BAAALAAECgEIAQAAAA==.',['你也']='你也是龙:BAACLAAFFH8rAAMEAAcIYB8hBAAiAgAEAAcIYB8hBAAiAgAFAAIIvxPICwCXAAAsAAQKf0IAAwQACAi5JFYFADgDAAQACAi5JFYFADgDAAYAAgh9BOwlADEAAAAA.',['你妹']='你妹德:BAAALAAECggICAABLAAFFAgILwAHAOkjAA==.',['兰因']='兰因絮果:BAAALAAECgQIBAAAAA==.',['初会']='初会冬雪:BAAALAAECgQIBAAAAA==.',['初雨']='初雨:BAAALAAECgMIAwAAAA==.',['判罪']='判罪:BAAALAAECgYIAwAAAA==.',['半途']='半途:BAAALAAECgYIBQAAAA==.',['卡露']='卡露琪亚:BAABLAAFFH8OAAMDAAII0hBSFwB8AAADAAII0hBSFwB8AAAHAAEItwHJcAAAAAAAAA==.',['叮丶']='叮丶骑士:BAAALAAECgEIAQAAAA==.',['可甜']='可甜可盐:BAAALAAFFAIIBAAAAA==.',['吃洋']='吃洋芋吃到涨:BAAALAADCgEIAQAAAA==.',['听雨']='听雨望云:BAAALAAECggIEAAAAA==.',['咕咕']='咕咕哒:BAAALAAECgMIAwAAAA==.',['咱们']='咱们来捉泥鳅:BAAALAADCgYIBgAAAA==.',['哥就']='哥就是传说哥:BAABLAAFFH8OAAICAAIIBwraLQBfAAACAAIIBwraLQBfAAAAAA==.',['圣光']='圣光游侠:BAAALAAECggIDQAAAA==.',['多米']='多米诺:BAAALAAECgYIBgAAAA==.',['天下']='天下无双:BAAALAAFFAIIAgAAAA==.',['天懿']='天懿:BAAALAADCggICAAAAA==.',['失魂']='失魂者:BAAALAADCggIDQAAAA==.',['奔波']='奔波儿豹:BAAALAAECgcICAAAAA==.',['安妮']='安妮可姬:BAAALAAECgUIBQABLAAECggIGAAIAKcfAA==.',['小安']='小安子的大哥:BAAALAAECgYIDQAAAA==.',['小小']='小小孑凡人:BAAALAAECgYICAAAAA==.',['小德']='小德啊答:BAABLAAFFH8GAAIJAAMIGwavKwBdAAAJAAMIGwavKwBdAAAAAA==.',['小懒']='小懒虫:BAABLAAFFH8WAAMKAAgI6RoBBACjAgAKAAgI6RoBBACjAgALAAEITQiaKgBDAAAAAA==.',['小搞']='小搞搞:BAAALAAECgYIDwAAAA==.',['少侠']='少侠:BAAALAAECgYICAAAAA==.',['尚武']='尚武之魂:BAAALAAECgYIBgAAAA==.',['山渐']='山渐青:BAAALAADCgUIBQAAAA==.',['巳弥']='巳弥:BAAALAAECgIIAgAAAA==.',['弗拉']='弗拉梅尔:BAAALAAFFAIIBAAAAA==.',['张飞']='张飞牛肉:BAAALAAFFAIIBAAAAA==.',['影子']='影子:BAAALAAECgYIBgAAAA==.',['我在']='我在微笑:BAAALAADCgIIAgAAAA==.',['我爱']='我爱喝三鹿:BAAALAADCgUIBQAAAA==.',['打那']='打那個法師:BAAALAAECggIEQAAAA==.',['扶苏']='扶苏丶尾灯:BAAALAAECgEIAQAAAA==.',['拉个']='拉个糖:BAAALAAFFAIIAwAAAA==.',['拟态']='拟态德:BAAALAADCgcIBwAAAA==.拟态牛:BAABLAAFFH8UAAIMAAUIIBQGHwDQAAAMAAUIIBQGHwDQAAAAAA==.拟态蛇:BAABLAAFFH8GAAMNAAII6RuvJQCuAAANAAII6RuvJQCuAAAOAAEICAdaCQA/AAAAAA==.',['撕想']='撕想家:BAAALAAECgcIDwAAAA==.',['明日']='明日大侠四:BAABLAAFFH8FAAIIAAUIbQ3ALwATAQAIAAUIbQ3ALwATAQAAAA==.',['未知']='未知目标:BAAALAAECggICAAAAA==.',['梅西']='梅西:BAAALAADCgQIBAAAAA==.',['死判']='死判丶夜刺:BAAALAAECgQIBAAAAA==.死判丶抠脚:BAAALAAECgYIBgAAAA==.死判丶拂晓:BAAALAAECgYICAAAAA==.死判丶晨曦:BAAALAAECgMIAwAAAA==.死判丶桀骜:BAAALAADCgEIAQAAAA==.死判丶羽落:BAAALAAECgYIAwAAAA==.死判丶莉萨:BAAALAAECgQIBAAAAA==.死判丶醒目:BAAALAAECgIIAgAAAA==.',['毁灭']='毁灭重生:BAABLAAECn8cAAIPAAgIRQJ7GgB5AAAPAAgIRQJ7GgB5AAAAAA==.',['灵幻']='灵幻子:BAAALAAECgEIAQAAAA==.灵幻风行者:BAAALAAECgUIBQAAAA==.',['爬起']='爬起来当没死:BAAALAAECgUIBgAAAA==.',['狡猾']='狡猾的丶麦兜:BAAALAAECgYICAAAAA==.',['男人']='男人的奶:BAAALAAECgYIBgAAAA==.',['界靖']='界靖水:BAAALAAECgcIEwAAAA==.',['皇甫']='皇甫罡門宏冢:BAAALAAECgEIAQAAAA==.皇甫龙斗可甜:BAABLAAFFH8GAAIQAAQIixTtUQDeAAAQAAQIixTtUQDeAAAAAA==.',['皮卡']='皮卡狮子:BAAALAADCgIIAgABLAAFFAgICgAMAO4aAA==.',['紧道']='紧道岩:BAABLAAFFH8GAAIRAAIItA1rcQB+AAARAAIItA1rcQB+AAAAAA==.',['紫萨']='紫萨:BAAALAAECgYIBgAAAA==.',['紫骑']='紫骑:BAAALAAECgIIAgAAAA==.',['组我']='组我发大财:BAABLAAFFH8KAAISAAII0x2EHQCsAAASAAII0x2EHQCsAAAAAA==.',['美团']='美团骑手:BAAALAAECgQIBAAAAA==.',['美羊']='美羊羊爱抠脚:BAAALAAECgMIAwAAAA==.',['胸狠']='胸狠丶男人:BAAALAADCgcIBwAAAA==.',['自然']='自然萌:BAAALAAECgYICgAAAA==.',['艾丽']='艾丽丝的梦:BAAALAAFFAIIAgAAAA==.',['花翎']='花翎月:BAAALAAECgQIBwAAAA==.',['莫七']='莫七托:BAAALAAECggIEwAAAA==.',['菊姬']='菊姬:BAABLAAFFH8HAAIQAAIIrA1ReQCLAAAQAAIIrA1ReQCLAAAAAA==.',['萬古']='萬古长存:BAAALAAECgMIBQAAAA==.',['蒙海']='蒙海燕:BAAALAAECgYICAAAAA==.',['许觉']='许觉尹:BAAALAAECgEIAQAAAA==.',['贪吃']='贪吃蛇:BAAALAAFFAIIAgAAAA==.',['赤目']='赤目妖瞳:BAAALAAECggICAAAAA==.',['赵丶']='赵丶信:BAAALAAECggIDwAAAA==.',['起舞']='起舞画我意:BAAALAAFFAIIBAAAAA==.',['路過']='路過人间:BAAALAAECgEIAQAAAA==.',['轩辕']='轩辕战:BAAALAAECgYIEAAAAA==.',['这锅']='这锅我背:BAAALAAECgEIAQAAAA==.',['迷恋']='迷恋阳光:BAAALAADCgUICQAAAA==.',['邪能']='邪能小紫薯:BAAALAAECgYIBwAAAA==.',['醉舞']='醉舞红妆偃月:BAAALAAECgYIBgAAAA==.',['雨宫']='雨宫纱月:BAACLAAFFH8aAAMTAAUIcCPOIQAQAQATAAUIcCPOIQAQAQAUAAEIniOOIQBiAAAsAAQKfx8ABBMACAh0IMAmAKoCABMACAglIMAmAKoCABUAAwjNH2oeAAEBABQAAgjPGAuBAHcAAAAA.',['雨落']='雨落青檐:BAABLAAFFH8NAAIWAAYIRg2mCgAEAQAWAAYIRg2mCgAEAQAAAA==.',['食人']='食人魔死骑:BAABLAAFFH8GAAIQAAIIcxXmXgCZAAAQAAIIcxXmXgCZAAAAAA==.',['饮水']='饮水机:BAAALAAFFAIIAgAAAA==.',['鸟毛']='鸟毛曲四曲:BAAALAAFFAQIBAAAAA==.',['點點']='點點丶:BAABLAAECn8VAAIIAAcIpxZ6YwBAAQAIAAcIpxZ6YwBAAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end