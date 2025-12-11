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
 local lookup = {'Hunter-BeastMastery','Paladin-Holy','Shaman-Elemental','Paladin-Retribution','Priest-Holy','Mage-Arcane','Druid-Guardian','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','DeathKnight-Frost',}; local provider = {region='CN',realm='格鲁尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Fr='Freebox:BAAALAAECgMIBQAAAA==.',Pi='Piikii:BAABLAAFFH8GAAIBAAYIWhydBQAmAgABAAYIWhydBQAmAgAAAA==.',Ul='Ullr:BAAALAAFFAIIAgAAAA==.',Wi='Wiik:BAAALAAECgYIBgAAAA==.Wiln:BAAALAAECgEIAQAAAA==.',['一只']='一只不高兴:BAAALAAECgYIBgABLAAFFAgIBgACAOIhAA==.',['不也']='不也挺好:BAAALAADCggICQAAAA==.',['世界']='世界我最棒:BAAALAAFFAIIBAAAAA==.世界第一萨:BAABLAAFFH8FAAIDAAIICA5oRQBDAAADAAIICA5oRQBDAAAAAA==.',['东门']='东门第一猎:BAAALAAECgcIBwAAAA==.',['九生']='九生:BAAALAAECgUICAAAAA==.',['人帅']='人帅气质佳:BAABLAAECn8UAAIEAAYIBCBTOgCuAQAEAAYIBCBTOgCuAQAAAA==.',['仙家']='仙家:BAAALAAECgYIBgAAAA==.',['叡枫']='叡枫枫:BAAALAAECgQIBAAAAA==.',['叡筱']='叡筱筱:BAAALAAFFAIIAgAAAA==.',['叭咪']='叭咪:BAAALAAFFAIIBAAAAA==.',['叽里']='叽里咕噜呛:BAAALAAECgYIDAAAAA==.',['嗜血']='嗜血潘多拉:BAAALAAECgEIAQAAAA==.',['圣光']='圣光骑:BAABLAAFFH8FAAIEAAUIqg7DKgAqAQAEAAUIqg7DKgAqAQAAAA==.',['夏漠']='夏漠灬秋雨:BAAALAADCggICAAAAA==.',['夕阳']='夕阳一龖龖:BAAALAAECgIIAgAAAA==.',['夜行']='夜行:BAAALAAECgQIBAAAAA==.',['夜览']='夜览:BAAALAAECgYIBwAAAA==.',['大女']='大女丑:BAAALAADCggICAAAAA==.',['夭孽']='夭孽:BAAALAAECgUIBwAAAA==.',['女大']='女大三抱鑫砖:BAAALAAFFAYIAgAAAA==.',['宠物']='宠物饲养员:BAAALAADCgIIAgAAAA==.',['寳貝']='寳貝貓:BAABLAAFFH8GAAIFAAQIhwdvKgDWAAAFAAQIhwdvKgDWAAAAAA==.',['小岚']='小岚岚:BAABLAAFFH8HAAIBAAII2yJKfgBaAAABAAII2yJKfgBaAAAAAA==.',['小情']='小情人:BAAALAAECgYIDAAAAA==.',['小猿']='小猿:BAAALAADCgEIAQAAAA==.',['弑凰']='弑凰:BAAALAAECgUIBQAAAA==.',['弑月']='弑月:BAAALAAECgYIBgAAAA==.',['怀念']='怀念:BAAALAADCgYIBgAAAA==.',['恶魔']='恶魔达卡:BAAALAAECgQIBAAAAA==.',['找乐']='找乐天使:BAAALAAECgMIAwAAAA==.',['抹茶']='抹茶芭菲:BAAALAAECggICAAAAA==.',['斩月']='斩月风云:BAABLAAECn8UAAIEAAYIPAcIngDEAAAEAAYIPAcIngDEAAAAAA==.',['暮日']='暮日猎杀:BAAALAAECgYIDAAAAA==.',['欧皇']='欧皇灬叭咪:BAAALAAECgYIBgAAAA==.',['永吥']='永吥为奴:BAAALAAECgYIBwAAAA==.',['泉此']='泉此方丶:BAAALAAFFAIIBAABLAAFFAcIIQAGAFYVAA==.',['泽屹']='泽屹:BAAALAAECgYIBgAAAA==.',['派拉']='派拉蒙的小猪:BAAALAAFFAIIBAAAAA==.',['湮斯']='湮斯特灭灭:BAAALAADCgMIAwABLAAFFAcIIQAGAFYVAA==.',['灬饼']='灬饼干灬:BAAALAAECgUIBQAAAA==.',['爱吃']='爱吃西瓜:BAAALAAECgYIBgAAAA==.',['猎乂']='猎乂影:BAAALAAECgYICAAAAA==.',['獵手']='獵手:BAAALAAECgQIBAAAAA==.',['甜蜜']='甜蜜哀伤:BAABLAAFFH8JAAIFAAIIyhHAOQB5AAAFAAIIyhHAOQB5AAAAAA==.甜蜜的哀伤:BAAALAAECggIBAAAAA==.',['碧螺']='碧螺春:BAAALAAECgYICwAAAA==.',['绝版']='绝版小春:BAABLAAECn8XAAIHAAYILRKlEgAPAQAHAAYILRKlEgAPAQAAAA==.',['老林']='老林家大孙女:BAAALAAECgYICQAAAA==.',['船长']='船长:BAAALAAECgMIAwAAAA==.',['芙莉']='芙莉莲:BAACLAAFFH9JAAIIAAcIHiaFAQBxAgAIAAcIHiaFAQBxAgAsAAQKfyIAAwgACAjoJdABAGYDAAgACAjoJdABAGYDAAkAAggNIrhWAKEAAAAA.',['览夜']='览夜:BAAALAAECgQIBAAAAA==.',['誓言']='誓言随風:BAAALAAECgYIDAAAAA==.',['贝弩']='贝弩鸟辉火:BAAALAAECgIIAgAAAA==.',['远离']='远离我:BAAALAADCgQIBAAAAA==.',['迪亚']='迪亚波罗:BAAALAAECgYICwAAAA==.',['邪恶']='邪恶老牛:BAAALAAECgUIBQAAAA==.',['金砖']='金砖儿:BAACLAAFFH8JAAMKAAYIIBQtCQAlAQAKAAUI6RctCQAlAQACAAEItQDcMQAKAAAsAAQKfxoAAwoABgjJIP4LAOIBAAoABgjJIP4LAOIBAAIABgilCk1RABABAAEsAAUUCAgGAAIAmCEA.',['雨夜']='雨夜大衣人:BAABLAAFFH8IAAILAAYIDRXKPACZAAALAAYIDRXKPACZAAAAAA==.',['雪花']='雪花沉睡:BAACLAAFFH8hAAIGAAcIVhXiFwDBAQAGAAcIVhXiFwDBAQAsAAQKfxcAAgYACAifHUNMACACAAYACAifHUNMACACAAAA.',['霜之']='霜之:BAAALAADCgcIDwABLAAFFAYIDQAMACwPAA==.',['霜点']='霜点殇:BAACLAAFFH8NAAMMAAIILA+qFABFAAANAAIIogpQGQBOAAAMAAIIbQyqFABFAAAsAAQKfxgABAwACAhCFXEKAGsBAAwABgg1GHEKAGsBAA0ACAjbD4UYAPQAAA4AAQj0CNoNACoAAAAA.',['静末']='静末:BAACLAAFFH8GAAIPAAII0hPTbwCQAAAPAAII0hPTbwCQAAAsAAQKfy0AAg8ACAg8HIBYAEUCAA8ACAg8HIBYAEUCAAAA.',['非玖']='非玖月曦:BAAALAAECgEIAQAAAA==.',['高尔']='高尔旋风:BAAALAAECgUICQAAAA==.',['鼬子']='鼬子:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end