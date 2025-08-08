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
 local lookup = {'Monk-Windwalker','Monk-Brewmaster','Mage-Arcane','Mage-Frost','Warrior-Fury','Warrior-Arms','Mage-Fire','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','Priest-Discipline','Paladin-Retribution','Paladin-Holy','Monk-Mistweaver','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Warrior-Protection','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','Rogue-Assassination','Paladin-Protection','Priest-Holy','DeathKnight-Frost','DemonHunter-Vengeance','DeathKnight-Blood','Priest-Shadow','Shaman-Enhancement',}; local provider = {region='CN',realm='巴尔古恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abbymilo:BAAAKgAECgUICQAAAA==.',An='Angelhymn:BAACKgAFFH8KAAIBAAII/iFrEgCbAAABAAII/iFrEgCbAAAqAAQKfyoAAwEACAiHI/wHALsCAAEACAiHI/wHALsCAAIAAgjKDO0gAGAAAAAA.',Cl='Classrhodey:BAACKgAFFH8RAAMDAAcI9xbeFAA9AQADAAQIaxneFAA9AQAEAAMIsRNHFgC9AAAqAAQKfx8AAgQACAh8H8IaAC0CAAQACAh8H8IaAC0CAAAA.',Cm='Cmx:BAACKgAFFH8JAAIFAAQIMw/FEgDuAAAFAAQIMw/FEgDuAAAqAAQKfxwAAgUACAgdGKUqAN8BAAUACAgdGKUqAN8BAAAA.',Ga='Garrosh:BAABKgAFFH8GAAIGAAYIGAriDABBAQAGAAYIGAriDABBAQAAAA==.',Ha='Hanfeng:BAAAKgAECgMIAwAAAA==.Happiness:BAAAKgAECgEIAQAAAA==.',He='Hee:BAAAKgAECggICAAAAA==.',Hu='Huigui:BAABKgAECn8VAAQEAAgIZBUpKwDNAQAEAAgIHBUpKwDNAQAHAAII3AqgkABVAAADAAEIEBFgmAA0AAAAAA==.',Ju='Juejuezhu:BAAAKgADCggIGwAAAA==.',Ma='Mabinogihero:BAAAKgAECggIDwAAAA==.Makemecry:BAAAKgAECgYIBgAAAA==.Marcowong:BAAAKgAECgUIBQAAAA==.',Me='Mengzs:BAAAKgADCggICAAAAA==.',Mi='Mikadohana:BAAAKgAFFAYIAQABKgAFFAgIDQAIAPMWAA==.',Nm='Nmd:BAAAKgAECgMIAwAAAA==.',No='Novemberrain:BAAAKgAFFAIIAgAAAA==.',Oy='Oywk:BAAAKgADCgEIAQAAAA==.',Ra='Raguel:BAAAKgAFFAIIAgABKgAFFAIICgABAP4hAA==.',Sh='Shadows:BAABKgAECn8XAAIJAAgI/h9mBgCBAgAJAAgI/h9mBgCBAgABKgAFFAgICAAKABcdAA==.Shiningff:BAAAKgAFFAIIAgAAAA==.',Zh='Zhaowenwen:BAAAKgAECgYICAAAAA==.',['一刕']='一刕蛋:BAAAKgADCgMIAwAAAA==.',['七叶']='七叶团团:BAABKgAECn8aAAILAAgIzBtsMwCpAQALAAgIzBtsMwCpAQAAAA==.七叶梧桐:BAAAKgAECgQIBAAAAA==.七叶海棠:BAABKgAFFH8GAAIMAAYI7QT8BABEAQAMAAYI7QT8BABEAQAAAA==.',['与你']='与你共舞:BAAAKgAECgcIDQAAAA==.',['为倪']='为倪消瘦:BAACKgAFFH8HAAILAAMIRxKINQCnAAALAAMIRxKINQCnAAAqAAQKfxUAAgsACAioF6ErANwBAAsACAioF6ErANwBAAAA.',['丿小']='丿小虎:BAACKgAFFH8kAAMNAAYI3hfLGwCFAQANAAYI3hfLGwCFAQAOAAIIcRmRDgCKAAAqAAQKfzAAAw0ACAhmIFY1ACoCAA0ACAhmIFY1ACoCAA4ABghXF38nACIBAAAA.',['五叔']='五叔:BAABKgAFFH8IAAIPAAgIaAWYCABjAQAPAAgIaAWYCABjAQAAAA==.',['仍然']='仍然想当年:BAABKgAFFH8PAAQQAAQIrg04BAATAQAQAAQIhQw4BAATAQARAAMIiQbgHgCOAAASAAMIhAYRGQCGAAAAAA==.',['他会']='他会魔法吧:BAAAKgAECgUIBwAAAA==.',['以圣']='以圣光之名:BAAAKgAECgIIAgAAAA==.',['伊塔']='伊塔之辉:BAAAKgADCggICAAAAA==.',['何处']='何处觅青龙:BAACKgAFFH8PAAMEAAQI/RbwDADFAAAEAAQI/RbwDADFAAAHAAIIDQoKNAB5AAAqAAQKfyMAAwQACAgVI/YGAL0CAAQACAgVI/YGAL0CAAMABghkGyswAJIBAAEqAAUUCAgQAAcAsB8A.',['何昕']='何昕橙:BAABKgAECn8UAAIJAAgIxRwxGAA3AgAJAAgIxRwxGAA3AgAAAA==.',['佛老']='佛老瓦:BAAAKgAECgQIBAAAAA==.',['依风']='依风听雨:BAAAKgAECgUICAAAAA==.',['倚风']='倚风听雨:BAAAKgAECgIIAgAAAA==.',['假如']='假如:BAABKgAFFH8FAAIEAAMImQTfHgCPAAAEAAMImQTfHgCPAAAAAA==.',['傲月']='傲月风:BAAAKgAECgMIAwAAAA==.',['傲气']='傲气之法:BAABKgAFFH8NAAMEAAUIux4sCgAiAQAEAAUI2x0sCgAiAQAHAAQIsR+3EQAMAQAAAA==.',['光明']='光明冰砖:BAABKgAFFH8SAAMJAAYIbCFWBQAgAQAJAAYIbCFWBQAgAQAKAAQItxP7HwDYAAAAAA==.',['冷酷']='冷酷骑士:BAABKgAECn8aAAINAAgIiiAzDgBwAgANAAgIiiAzDgBwAgAAAA==.',['利姆']='利姆鲁:BAABKgAFFH8KAAILAAMIiiCbGwAQAQALAAMIiiCbGwAQAQAAAA==.',['勝奇']='勝奇石:BAAAKgADCgQIBAAAAA==.',['包浆']='包浆瑜伽裤:BAAAKgADCgIIAgAAAA==.',['北顾']='北顾:BAAAKgADCgUIBwAAAA==.',['医帆']='医帆丰顺:BAABKgAFFH8FAAIKAAUIBg3XIwD5AAAKAAUIBg3XIwD5AAAAAA==.',['十年']='十年泪:BAAAKgADCgQIBAAAAA==.',['南城']='南城逆流:BAABKgAFFH8LAAITAAMIaxb0CQDFAAATAAMIaxb0CQDFAAAAAA==.',['卡琳']='卡琳娜丶:BAAAKgADCgEIAgAAAA==.',['厄尔']='厄尔斯:BAABKgAFFH8MAAIUAAYIXw3mFwA8AQAUAAYIXw3mFwA8AQAAAA==.',['变心']='变心精钢:BAAAKgADCgQIBAAAAA==.',['口牌']='口牌深啊:BAAAKgAECggIDwAAAA==.',['叮当']='叮当喵:BAAAKgAFFAgIBAAAAA==.叮当是只猫:BAABKgAFFH8SAAMVAAQISw5COADAAAAVAAMISw5COADAAAAWAAQI7RShIQCiAAAAAA==.',['可爱']='可爱容颜倾城:BAAAKgAECggICAAAAA==.',['号没']='号没啦:BAABKgAECn8WAAIEAAcI5hV/KAB2AQAEAAcI5hV/KAB2AQAAAA==.',['听涛']='听涛:BAABKgAFFH8JAAIXAAYIiRI7DgBtAQAXAAYIiRI7DgBtAQAAAA==.',['咧琛']='咧琛:BAABKgAFFH8OAAINAAYIZRmCBwBCAQANAAYIZRmCBwBCAQAAAA==.',['哎欧']='哎欧娜:BAABKgAFFH8KAAINAAYIgBseDwCwAQANAAYIgBseDwCwAQAAAA==.',['喆喆']='喆喆的小奶嘴:BAABKgAFFH8eAAQGAAQIjCBqEAALAQAGAAMIjCBqEAALAQAFAAMImhdhKwCVAAATAAIIJwayFABVAAAAAA==.',['四根']='四根一疗程:BAAAKgAECgYIBgAAAA==.',['国宝']='国宝特供:BAAAKgADCgQIBAAAAA==.',['圣土']='圣土:BAAAKgAECgMIAQAAAA==.',['坏蛋']='坏蛋蛋:BAAAKgAECggICAAAAA==.',['垚磊']='垚磊:BAAAKgADCgEIAQAAAA==.',['夏媞']='夏媞雅:BAABKgAFFH8FAAIIAAMIkBFkNQDCAAAIAAMIkBFkNQDCAAAAAA==.',['夜色']='夜色大叔:BAAAKgADCgYIBgAAAA==.',['夜里']='夜里无眠:BAAAKgAFFAIIAgAAAA==.',['天亮']='天亮才说晚安:BAABKgAFFH8TAAMNAAgIVSNrBACTAgANAAgIVSNrBACTAgAYAAgIXxLYBwCTAQAAAA==.',['天空']='天空之殒:BAAAKgADCgQIBQAAAA==.天空之泪:BAAAKgADCgQIBAAAAA==.',['娜贝']='娜贝拉尔:BAABKgAFFH8PAAINAAMIChlGPgD2AAANAAMIChlGPgD2AAAAAA==.',['安度']='安度西亚:BAAAKgAECgYIEQAAAA==.',['小六']='小六先生:BAAAKgADCgIIAwAAAA==.',['小宝']='小宝贝丶:BAAAKgADCgYIBgAAAA==.',['小小']='小小战意:BAAAKgADCgQIBAAAAA==.',['小强']='小强灰太狼:BAAAKgADCggIEAAAAA==.',['小泽']='小泽玛力雅:BAAAKgADCgEIAQAAAA==.',['小牛']='小牛疯了:BAACKgAFFH8KAAINAAQIggX9MgCXAAANAAQIggX9MgCXAAAqAAQKfxwAAg0ACAgsF+RWALkBAA0ACAgsF+RWALkBAAAA.',['小狐']='小狐狸:BAAAKgAECgcIEgAAAA==.',['小猪']='小猪疯了:BAAAKgADCgUIBQAAAA==.',['小贝']='小贝贝:BAAAKgAFFAMIAwAAAA==.',['希尔']='希尔瓦纳斯:BAAAKgADCgIIAgAAAA==.',['幻想']='幻想少女物語:BAABKgAFFH8QAAMRAAMI+SPYJwDQAAARAAII7STYJwDQAAAQAAIIqyDyEwCeAAAAAA==.',['幽灵']='幽灵宫宫主:BAAAKgAECgQIBAAAAA==.',['弍公']='弍公主:BAAAKgAECggIEAAAAA==.弍公子:BAAAKgAECggICAAAAA==.',['德鲁']='德鲁依依:BAAAKgADCggIDwAAAA==.',['怒怒']='怒怒的潮:BAABKgAFFH8GAAIYAAYIbBbNCwA7AQAYAAYIbBbNCwA7AQAAAA==.',['怿心']='怿心:BAAAKgAECggICAAAAA==.',['恶魔']='恶魔兽兽:BAABKgAFFH8IAAIJAAYIRRRREQBaAQAJAAYIRRRREQBaAQAAAA==.恶魔牛牛:BAABKgAFFH8GAAIZAAYI2AYiFQALAQAZAAYI2AYiFQALAQAAAA==.',['戈尔']='戈尔甘耐斯:BAAAKgADCgQIBAAAAA==.',['我会']='我会永远爱你:BAABKgAFFH8VAAQHAAgI+yNAAgD9AQAEAAcI1iCiAQBTAgAHAAgIyyJAAgD9AQADAAII/SFfIwBlAAAAAA==.',['我叫']='我叫霎聪君:BAABKgAECn8mAAIFAAgIthu8DgC0AQAFAAgIthu8DgC0AQAAAA==.',['我有']='我有心事:BAAAKgADCgEIAgAAAA==.',['打发']='打发打发时间:BAABKgAFFH8SAAMVAAUIshkkJAAIAQAVAAMIqh8kJAAIAQAWAAUIEAvzGQDRAAAAAA==.',['拉妮']='拉妮过莱:BAAAKgAECgIIAgAAAA==.',['撒克']='撒克斯:BAAAKgAECgUIBQAAAA==.',['撩人']='撩人浊酒:BAAAKgAECgQIBAAAAA==.撩人浊酒一:BAACKgAFFH8OAAMKAAMI6hgWKgDdAAAKAAMI6hgWKgDdAAAJAAMIbwTwRQBoAAAqAAQKfxkAAwkACAhVFpwqAJIBAAkACAiBEZwqAJIBAAoABwjPFUaTAAUBAAAA.',['文华']='文华殿大学士:BAAAKgADCgEIAQAAAA==.',['斯特']='斯特拉斯纨绔:BAAAKgAECgUIBwAAAA==.',['无糖']='无糖:BAAAKgAECgQIBAAAAA==.',['无间']='无间地狱:BAAAKgAECgQIBQAAAA==.',['明明']='明明灬狗:BAAAKgAECgYICAAAAA==.',['晨曦']='晨曦若岚:BAABKgAFFH8MAAILAAQILSOyCQAJAQALAAQILSOyCQAJAQAAAA==.',['暗黑']='暗黑魔法:BAAAKgADCgEIAQAAAA==.',['月光']='月光姬:BAAAKgAECgcIDgAAAA==.',['月影']='月影追魂:BAAAKgADCggIDgAAAA==.',['有容']='有容乃:BAAAKgAFFAMIAwAAAA==.',['有角']='有角角:BAAAKgAECgEIAQAAAA==.',['未知']='未知劣人:BAAAKgAFFAEIAQAAAA==.',['来自']='来自猩猩的你:BAACKgAFFH8KAAIQAAQIUx1dCQDvAAAQAAQIUx1dCQDvAAAqAAQKfxUAAhAACAh1HCQHAPkBABAACAh1HCQHAPkBAAAA.',['柯基']='柯基不爱洗澡:BAABKgAFFH8PAAIaAAMIbRq5BwDvAAAaAAMIbRq5BwDvAAAAAA==.柯基小短腿:BAAAKgAECgQIBAAAAA==.',['柰子']='柰子死骑:BAAAKgADCgYIBgAAAA==.',['桂小']='桂小镁:BAAAKgAECgMIAwAAAA==.',['梦一']='梦一般的结局:BAAAKgADCgEIAQAAAA==.',['梦境']='梦境的米迪娅:BAAAKgAFFAIIAgAAAA==.',['梦里']='梦里啥都没有:BAACKgAFFH8SAAIPAAQIORdaGgDKAAAPAAQIORdaGgDKAAAqAAQKfxgAAg8ACAiVGOEnALwBAA8ACAiVGOEnALwBAAAA.',['步步']='步步追踪:BAAAKgADCggICAAAAA==.',['武僧']='武僧:BAAAKgAECggIEAAAAA==.',['武当']='武当当武:BAABKgAFFH8GAAIBAAYIpwXoCAAdAQABAAYIpwXoCAAdAQAAAA==.',['每日']='每日依恋:BAACKgAFFH8SAAIEAAMIggoyGwCnAAAEAAMIggoyGwCnAAAqAAQKfyQAAgQACAjaEz8oAHcBAAQACAjaEz8oAHcBAAAA.',['毛毛']='毛毛妹:BAAAKgAECgUIBQAAAA==.',['毛牛']='毛牛:BAAAKgAECgEIAQAAAA==.',['江屿']='江屿:BAABKgAFFH8LAAMZAAYIdg5XEQAnAQAZAAYIEA1XEQAnAQAMAAMIMw7wHgCoAAAAAA==.',['江烟']='江烟万缕:BAABKgAFFH8FAAINAAMIjCRVFgA8AQANAAMIjCRVFgA8AQAAAA==.',['洛士']='洛士琦:BAAAKgAECgQIBAAAAA==.',['涳涳']='涳涳如也:BAAAKgAECgMIAwAAAA==.',['清净']='清净灵珑:BAACKgAFFH8MAAIPAAYIOBMuBQBfAQAPAAYIOBMuBQBfAQAqAAQKfxoAAg8ACAiPFV8iAN8BAA8ACAiPFV8iAN8BAAAA.',['灬威']='灬威利旺卡灬:BAAAKgAFFAMIAwAAAA==.',['灵鹫']='灵鹫宫宫主:BAAAKgADCgUIBgAAAA==.',['炼狱']='炼狱游龙:BAACKgAFFH8SAAIFAAMImBX8HQDcAAAFAAMImBX8HQDcAAAqAAQKfxYAAgUACAjnFkgdAOkBAAUACAjnFkgdAOkBAAAA.',['炽炎']='炽炎罗刹:BAAAKgAECgQIBAAAAA==.',['独自']='独自风飘一:BAABKgAFFH8HAAINAAMIJQ/GKADEAAANAAMIJQ/GKADEAAAAAA==.',['猎杀']='猎杀者丶影歌:BAAAKgADCgIIAgAAAA==.',['王昭']='王昭:BAABKgAFFH8SAAMNAAYIMRoJHwB0AQANAAYIBRgJHwB0AQAYAAYIXxKTEAD/AAABKgAFFAgIEAANAIwiAA==.',['玖伍']='玖伍贰柒囧:BAAAKgAECggICAAAAA==.',['玛尔']='玛尔兰:BAABKgAFFH8PAAINAAQIMiPSFwD8AAANAAQIMiPSFwD8AAABKgAFFAgIEQAYAFUbAA==.',['玥溪']='玥溪:BAAAKgADCggICwAAAA==.',['画影']='画影:BAAAKgAECggICAAAAA==.',['白梦']='白梦妍:BAAAKgAECggICAAAAA==.',['百威']='百威啤:BAAAKgAECgUIBQAAAA==.',['百花']='百花羞丶罗兰:BAAAKgAECgYIBgAAAA==.',['眷影']='眷影年华:BAAAKgAECgEIAQAAAA==.',['眼眸']='眼眸里的微笑:BAAAKgADCgMIAwAAAA==.',['知了']='知了知了:BAAAKgADCgYIBgAAAA==.',['矮穷']='矮穷挫的逆袭:BAAAKgADCggICAAAAA==.',['神圣']='神圣弑魂:BAABKgAFFH8aAAMUAAYIvBreDwCJAQAUAAYIvBreDwCJAQAbAAYIvQoaBgABAQABKgAFFAgIDgARAPkhAA==.',['种田']='种田大爷:BAACKgAFFH8KAAINAAgIgxqiBgBQAgANAAgIgxqiBgBQAgAqAAQKfxYAAg0ABwicERiUACUBAA0ABwicERiUACUBAAAA.',['移花']='移花宫宫主:BAAAKgAECgUIBgAAAA==.',['究极']='究极小短腿:BAAAKgAFFAIIBAABKgAFFAIICgABAP4hAA==.',['箭拔']='箭拔弩张:BAAAKgADCgMIAwAAAA==.',['红手']='红手哥布林:BAAAKgAECgcICwAAAA==.',['给我']='给我加个嗜血:BAABKgAFFH8IAAQQAAgISB/IAwAjAQAQAAMIGiPIAwAjAQARAAIIaRyLGAC7AAASAAMIaxyqCgCoAAAAAA==.',['罗伦']='罗伦亚:BAAAKgAECgUIBQAAAA==.',['耀光']='耀光如炬:BAABKgAFFH8MAAINAAYIoiWMAAAWAgANAAYIoiWMAAAWAgAAAA==.',['老中']='老中医:BAAAKgADCgUIBQAAAA==.',['老暴']='老暴叁:BAAAKgADCggICAAAAA==.老暴壹:BAAAKgAECgMIAwAAAA==.老暴肆:BAAAKgADCggICAAAAA==.',['聂庞']='聂庞重生:BAABKgAFFH8OAAMcAAYI2B30AADPAQAcAAYIiR30AADPAQAIAAQIJCAYKQDpAAAAAA==.',['聊听']='聊听风:BAAAKgADCgYIBgAAAA==.',['联盟']='联盟死骑:BAAAKgAECgEIAQAAAA==.联盟騎士:BAABKgAFFH8LAAINAAMI/ArAXwCxAAANAAMI/ArAXwCxAAAAAA==.联盟骑士:BAAAKgAFFAgIAgAAAA==.',['臊气']='臊气丶:BAAAKgAECgQIBAAAAA==.',['舞动']='舞动的弓弦:BAACKgAFFH8fAAIKAAQI6xewGwDmAAAKAAQI6xewGwDmAAAqAAQKf1IAAwoACAgtIU4dAFACAAoACAgtIU4dAFACAAkAAQhoDjiRACgAAAAA.',['花田']='花田半亩:BAAAKgADCgQIBAAAAA==.',['芸尛']='芸尛咿:BAACKgAFFH8HAAIHAAcIeBIjCQCsAQAHAAcIeBIjCQCsAQAqAAQKfxcAAgQABwg6IcxDAFgBAAQABwg6IcxDAFgBAAEqAAUUCAgMAAMAIhMA.',['莉丝']='莉丝缇亚:BAAAKgAECggICQAAAA==.',['莉蕾']='莉蕾萨:BAAAKgAECgEIAQAAAA==.',['蓝莓']='蓝莓糖糖糕丶:BAAAKgAFFAgIBAAAAA==.',['蘑菇']='蘑菇头:BAAAKgAECgMIBAAAAA==.',['虞姬']='虞姬:BAAAKgAECgQIBAAAAA==.',['袜子']='袜子少一只:BAAAKgAECggICwAAAA==.',['诗桃']='诗桃微白:BAAAKgAECgUIBQAAAA==.',['请叫']='请叫我芸大王:BAAAKgAECgMIAwAAAA==.',['贼少']='贼少:BAAAKgAECgYIBgAAAA==.',['赑屃']='赑屃:BAAAKgAECgYIBgAAAA==.',['赤龙']='赤龙影:BAACKgAFFH8nAAMFAAcIlhtpEABPAQAFAAUIjBxpEABPAQAGAAQI7BUVCgDxAAAqAAQKfyEAAgUACAi+HrASAHICAAUACAi+HrASAHICAAAA.',['赫斐']='赫斐斯托斯顿:BAAAKgAFFAIIAgAAAA==.',['超美']='超美小猪:BAACKgAFFH8XAAIVAAQI+R/1EgDvAAAVAAQI+R/1EgDvAAAqAAQKfywAAhUACAhTIikZAHECABUACAhTIikZAHECAAAA.',['软绵']='软绵绵:BAAAKgAECgcIBwAAAA==.',['轻度']='轻度脂肪肝:BAAAKgAFFAYIBAAAAA==.',['送你']='送你飞:BAAAKgADCgEIAgAAAA==.',['逍遥']='逍遥骑仕:BAAAKgAECgUIBQAAAA==.',['逼盎']='逼盎丝:BAAAKgADCgMIAwAAAA==.',['遺夨']='遺夨十年:BAAAKgAECggICAAAAA==.',['郑一']='郑一个小目标:BAAAKgADCgQIBAAAAA==.',['郭蝈']='郭蝈蝈郭:BAAAKgADCgUIBQAAAA==.',['酩酊']='酩酊旅途:BAAAKgADCgQIBAAAAA==.',['锟铻']='锟铻:BAAAKgAECgYIBgAAAA==.',['长夜']='长夜烬明:BAAAKgAECgUICQAAAA==.',['阿布']='阿布贾大人:BAAAKgADCgIIAgAAAA==.阿布贾爱吃鱼:BAAAKgAECgUIBQAAAA==.',['阿木']='阿木木:BAABKgAFFH8OAAMZAAgIEhmaAwAKAgAZAAgIEhmaAwAKAgAdAAEI6A0tGQBLAAAAAA==.',['随便']='随便整一号:BAAAKgAECggIDAAAAA==.随便整三号:BAABKgAFFH8VAAMLAAQIGRjMJgDbAAALAAMIGRjMJgDbAAAeAAQIPArkFACtAAAAAA==.随便整二号:BAAAKgAECgEIAQAAAA==.',['雪之']='雪之下丶雪乃:BAAAKgAFFAIIAgABKgAFFAMIDwANAAoZAA==.',['雪灬']='雪灬物语:BAAAKgAECgEIAQAAAA==.',['雯雯']='雯雯的肥咕咕:BAAAKgAECgIIAgAAAA==.',['露普']='露普斯蕾琪娜:BAABKgAFFH8YAAQFAAcI0xZ8DACEAQAFAAYIUxV8DACEAQATAAIICAe3FABUAAAGAAEIWB7SJwBRAAAAAA==.',['青鸢']='青鸢丶罗兰:BAAAKgAECgUICAAAAA==.',['颖女']='颖女宠:BAAAKgADCggICAAAAA==.颖女祭:BAAAKgADCgQIBAAAAA==.',['风暴']='风暴汽水:BAAAKgAFFAMIAwAAAA==.',['馨怡']='馨怡:BAAAKgADCgcICAAAAA==.',['马戏']='马戏团公约:BAAAKgAECgEIAQAAAA==.',['高端']='高端商务:BAAAKgAECgIIAgAAAA==.',['鬼魅']='鬼魅月光:BAABKgAFFH8GAAIOAAYI1goSBwBGAQAOAAYI1goSBwBGAQAAAA==.',['魔界']='魔界之圣寂:BAAAKgAECgMIAwAAAA==.魔界之幽雅:BAAAKgADCgYIBgAAAA==.魔界之星幻:BAAAKgADCgEIAQAAAA==.魔界之武圣:BAAAKgAECgIIAgAAAA==.魔界之法神:BAAAKgAECgQIBgAAAA==.魔界之混沌:BAAAKgAECgMIAwAAAA==.魔界之猎刃:BAAAKgAECgYIBgAAAA==.魔界之米老鼠:BAAAKgAECgIIAgAAAA==.',['麦吉']='麦吉:BAAAKgAECgcICQAAAA==.',['黄沙']='黄沙满天飞:BAAAKgAECgcICwAAAA==.',['黑暗']='黑暗虚空:BAAAKgAECggIDgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end