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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Paladin-Retribution','Warrior-Fury','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Monk-Mistweaver','Shaman-Restoration','DeathKnight-Blood','Paladin-Protection','Mage-Arcane','Mage-Fire','Warrior-Arms','Rogue-Assassination','Mage-Frost','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Unholy','Shaman-Enhancement',}; local provider = {region='CN',realm='卡珊德拉',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Angelzj:BAAAKgAECgcIBwAAAA==.',Cu='Curten:BAAAKgADCggIDQAAAA==.',Cy='Cyanide:BAAAKgAECgEIAgAAAA==.',Da='Dannmm:BAAAKgAECgIIAgAAAA==.Darkblade:BAAAKgAECgEIAQAAAA==.',He='Helianthus:BAAAKgADCggICAAAAA==.Hermit:BAABKgAFFH8XAAMBAAgI1hdhAwCmAQABAAgI1hdhAwCmAQACAAQIfhpCLAC6AAAAAA==.',Hl='Hlidskiaf:BAACKgAFFH8TAAMDAAYI7wrUCwCNAQADAAYI7wrUCwCNAQAEAAEIswM9FAAzAAAqAAQKfzIAAwMACAjXIBADAKQCAAMACAiwIBADAKQCAAUABwhWHKYIALoBAAAA.',Ho='Hour:BAABKgAECn8gAAIGAAgIQw17MgBIAQAGAAgIQw17MgBIAQAAAA==.',Ia='Iautumnwind:BAAAKgAECgMIBAAAAA==.',Ka='Kareluy:BAAAKgAECgYIBgAAAA==.',Ki='Kiligx:BAAAKgAECgYIBgAAAA==.',Rd='Rdii:BAAAKgAECgYIBwAAAA==.',Sk='Skyhunter:BAAAKgADCgQIBAAAAA==.',To='Today:BAABKgAECn8XAAIBAAgIqg1IMAAFAQABAAgIqg1IMAAFAQAAAA==.Toto:BAAAKgAECggICAAAAA==.Touchgirl:BAABKgAECn8UAAIHAAcIfA1KPwAfAQAHAAcIfA1KPwAfAQAAAA==.',['一起']='一起去看伱妹:BAAAKgADCgcIBwAAAA==.',['乌拉']='乌拉诺祀:BAAAKgADCggIDQAAAA==.',['九五']='九五奶不住:BAAAKgAECgIIAgAAAA==.',['二刀']='二刀流:BAAAKgADCgEIAgAAAA==.',['俏俏']='俏俏娇娘:BAAAKgAECgQIBAAAAA==.',['信仰']='信仰圣光:BAAAKgAECgYIBgAAAA==.',['光之']='光之双刃:BAAAKgAECgYICwAAAA==.光之律者:BAAAKgAECgYICQAAAA==.',['刘铋']='刘铋成:BAAAKgAECgMIAwAAAA==.刘铋诚:BAACKgAFFH8lAAQIAAgI8xXPAQCgAQAIAAUI6BvPAQCgAQAJAAcI2hYCDgCBAQAKAAEITwUZBQAnAAAqAAQKfyAAAwgACAgjG2UGACoCAAgACAgjG2UGACoCAAkABgiVGbI9APAAAAAA.',['勇敢']='勇敢牛牛:BAABKgAFFH8IAAILAAgIXwf8BwB2AQALAAgIXwf8BwB2AQAAAA==.',['北极']='北极的企鹅:BAAAKgAFFAQIBAABKgAFFAgICAAMALsbAA==.北极的北极熊:BAABKgAFFH8GAAINAAQIugh6JwB5AAANAAQIugh6JwB5AAAAAA==.',['卡了']='卡了卡了:BAABKgAECn8VAAIFAAgIlAoqJwBVAQAFAAgIlAoqJwBVAQAAAA==.',['司美']='司美格鲁肽:BAABKgAFFH8KAAMCAAgIthFmEgBQAQACAAQITxdmEgBQAQABAAQIPwqaPgCjAAAAAA==.',['哒啦']='哒啦术术:BAABKgAECn8UAAMEAAgIwhf2CwCvAQAEAAgIwhf2CwCvAQAFAAIIMgzrbABfAAAAAA==.',['地板']='地板战:BAAAKgADCggIDQAAAA==.',['夏威']='夏威夷的青葱:BAAAKgADCgIIAgAAAA==.',['大力']='大力促奇迹:BAAAKgAECgUIBQAAAA==.',['大眼']='大眼亮晶晶:BAAAKgADCgIIAgAAAA==.',['大蟒']='大蟒蛇:BAAAKgAECgIIAgAAAA==.',['天国']='天国武装:BAAAKgAECgMIBAAAAA==.',['妖月']='妖月:BAAAKgAFFAQIBAAAAA==.',['宦海']='宦海帝国:BAAAKgAFFAYIBAAAAA==.',['密雪']='密雪冰城:BAAAKgAFFAQIBAAAAA==.',['小手']='小手冰凉:BAAAKgAECgUICQAAAA==.',['小灬']='小灬劣人:BAAAKgADCggICAAAAA==.小灬萌德:BAAAKgAECgMIAwAAAA==.',['小番']='小番茄大冬瓜:BAABKgAFFH8JAAIGAAYIDhSHNgARAQAGAAYIDhSHNgARAQABKgAFFAgIBgAOAIcTAA==.',['小风']='小风华月夜:BAABKgAFFH8LAAIGAAgI3B9VBgBmAgAGAAgI3B9VBgBmAgAAAA==.',['小鹿']='小鹿丷:BAAAKgAECgMIAwAAAA==.',['少先']='少先队:BAAAKgAFFAgIAgAAAA==.',['尼古']='尼古拉斯:BAAAKgAECggICAAAAA==.',['巴蒂']='巴蒂斯塔:BAAAKgADCgMIAwAAAA==.',['幻影']='幻影蛋蛋:BAABKgAFFH8KAAMPAAYIaRVwFwApAQAQAAYI6g2dEQA0AQAPAAQIkyJwFwApAQABKgAFFAgIDgAPAMAhAA==.',['幻滅']='幻滅花火:BAABKgAFFH8MAAIDAAgI3B0lCwCcAQADAAgI3B0lCwCcAQAAAA==.',['幽殇']='幽殇之冥:BAAAKgADCggICAAAAA==.',['弑榊']='弑榊殺狱:BAABKgAFFH8GAAINAAYI5AR/CgDbAAANAAYI5AR/CgDbAAAAAA==.',['我戒']='我戒律真牛逼:BAAAKgAFFAQIBAAAAA==.',['我是']='我是丶大叔:BAACKgAFFH8XAAMRAAYIrxasCQBxAQARAAYIrxasCQBxAQAHAAQIMQ4fFADmAAAqAAQKfyUAAwcACAi4G7sjAAQCAAcACAi4G7sjAAQCABEAAgi0CF1rAC0AAAEqAAUUCAgTABIALhsA.',['拉布']='拉布拉多:BAAAKgAECgUICAAAAA==.',['无法']='无法爱:BAAAKgAECgIIAgAAAA==.',['星光']='星光的火焰:BAABKgAFFH8GAAITAAYIDxBEBQBhAQATAAYIDxBEBQBhAQAAAA==.',['普贤']='普贤:BAAAKgAECgIIAgAAAA==.',['暗矛']='暗矛之音:BAABKgAFFH8KAAIUAAYIWBZ9CgBvAQAUAAYIWBZ9CgBvAQAAAA==.',['暴龙']='暴龙兽:BAAAKgAECggICAAAAA==.',['月满']='月满轩尼斯:BAAAKgAECgQIBAAAAA==.',['木辛']='木辛龍:BAABKgAFFH8HAAIHAAcIBRnoBQAWAgAHAAcIBRnoBQAWAgAAAA==.木辛龙:BAABKgAFFH8HAAIGAAcIRhQxEQDVAQAGAAcIRhQxEQDVAQAAAA==.',['本瑞']='本瑞利珠:BAAAKgAFFAMIAwAAAA==.',['条街']='条街最萌妹:BAAAKgAFFAIIAgAAAA==.',['条该']='条该:BAABKgAFFH8GAAIMAAQI6xwwCQAOAQAMAAQI6xwwCQAOAQAAAA==.',['来治']='来治猩猩的你:BAABKgAFFH8IAAIGAAgI1gdzDwCqAQAGAAgI1gdzDwCqAQAAAA==.',['栗悟']='栗悟饭龟波功:BAAAKgADCgUIBQAAAA==.',['水月']='水月审判者:BAAAKgAECgEIAQAAAA==.',['氵木']='氵木丶德:BAAAKgADCgUIBQAAAA==.',['沐风']='沐风之歌:BAAAKgADCgUIBQAAAA==.',['沒有']='沒有水的魚:BAABKgAFFH8MAAIUAAYIxBlDCACdAQAUAAYIxBlDCACdAQAAAA==.',['海大']='海大力:BAAAKgAECggICAAAAA==.',['海边']='海边的卡夫卡:BAAAKgAECgIIAQAAAA==.',['烟丶']='烟丶花:BAACKgAFFH8HAAIUAAcIQhPOBQDaAQAUAAcIQhPOBQDaAQAqAAQKfxUAAhUACAi3Hk4SAD8CABUACAi3Hk4SAD8CAAAA.',['牛牛']='牛牛没有奶:BAABKgAECn8dAAIGAAgIUiOIDgDVAgAGAAgIUiOIDgDVAgAAAA==.',['牛羊']='牛羊河:BAAAKgADCggICAAAAA==.',['牛魔']='牛魔族大江君:BAACKgAFFH8RAAIHAAMIKQtrIwDFAAAHAAMIKQtrIwDFAAAqAAQKfz0AAgcACAjPGFEbAPcBAAcACAjPGFEbAPcBAAAA.',['牧丨']='牧丨师:BAAAKgADCgIIAgAAAA==.',['猪儿']='猪儿虫:BAAAKgAECgYIBgAAAA==.',['玖六']='玖六:BAACKgAFFH8WAAMQAAQImRA/HgDcAAAQAAMImRA/HgDcAAAPAAQIgw5qLACyAAAqAAQKfx8AAxAACAiPHGwhACsCABAACAiPHGwhACsCABMAAgikEU+vAC4AAAAA.',['玛达']='玛达拉:BAAAKgADCggIDQAAAA==.',['瓦德']='瓦德拉肯之犄:BAAAKgAFFAIIAgABKgAFFAgICAAMALsbAA==.',['白小']='白小纯:BAAAKgAECgEIAQAAAA==.',['瞳瞳']='瞳瞳犟丶丨丨:BAAAKgAECgQIBAAAAA==.',['粽弃']='粽弃疾:BAABKgAFFH8hAAMWAAgIDAx/FQBOAQAWAAgIDAx/FQBOAQAXAAEIFQagJgArAAAAAA==.',['罒蟹']='罒蟹黄包:BAABKgAFFH8GAAMYAAQIpwrLBQCQAAAYAAQITQrLBQCQAAAZAAIIEAseFgCFAAAAAA==.',['羊河']='羊河牛:BAAAKgAECgYIBgAAAA==.',['翅膀']='翅膀下的风:BAAAKgADCgMIAwAAAA==.',['翱翔']='翱翔羽:BAABKgAFFH8GAAIUAAQIzQlZIQCeAAAUAAQIzQlZIQCeAAAAAA==.',['老枪']='老枪杆子:BAAAKgAECgYIBgAAAA==.',['芙莉']='芙莉德薇尔:BAAAKgAECgIIAwAAAA==.',['荒诞']='荒诞行刑者:BAAAKgAECggIDAAAAA==.',['菊花']='菊花中的蛋蛋:BAABKgAFFH8WAAICAAYIoxqrDgB1AQACAAYIoxqrDgB1AQAAAA==.菊花蛋蛋:BAABKgAFFH8NAAIMAAcIyBHdCgCaAQAMAAcIyBHdCgCaAQAAAA==.',['薄荷']='薄荷肉松:BAAAKgAECgYIBgAAAA==.',['蛋蛋']='蛋蛋炸菊花:BAABKgAFFH8KAAIVAAYISSGFBADlAQAVAAYISSGFBADlAQAAAA==.蛋蛋王:BAABKgAFFH8TAAMaAAgIABn9DADBAQAaAAgInhf9DADBAQANAAYIGBmaBACnAQAAAA==.',['蜜雪']='蜜雪:BAABKgAFFH8IAAIVAAgIKgqJBwB9AQAVAAgIKgqJBwB9AQAAAA==.',['许德']='许德:BAAAKgAECgIIAgAAAA==.',['诸神']='诸神之泪:BAAAKgADCggIBgAAAA==.诸神黎明:BAAAKgAECgYIBgAAAA==.',['豆包']='豆包:BAABKgAECn8YAAIMAAgIKhBRIQAlAQAMAAgIKhBRIQAlAQAAAA==.',['貔貅']='貔貅貔貅:BAAAKgAFFAMIAwAAAA==.',['追魂']='追魂梦扬之心:BAACKgAFFH8iAAMBAAUIqBrQEQAKAQABAAUIwxfQEQAKAQACAAQIFBaUJwDMAAAqAAQKfxwAAwEACAjxHVsoAFICAAEACAjxHVsoAFICAAIAAgghD0OEAEIAAAAA.',['野火']='野火哈基米:BAAAKgAECgQIBAAAAA==.',['闹闹']='闹闹卝鸿轩:BAAAKgAECgYIBgAAAA==.',['阿武']='阿武卵:BAABKgAFFH8OAAIbAAYI2xpUBgCRAQAbAAYI2xpUBgCRAQAAAA==.',['随心']='随心的风:BAABKgAFFH8GAAIGAAQI6CG4FwAsAQAGAAQI6CG4FwAsAQAAAA==.',['非个']='非个人:BAAAKgAFFAYIAgAAAA==.',['鸿运']='鸿运当蛋:BAAAKgAFFAgIBAAAAA==.',['黑椒']='黑椒香菜汁:BAABKgAFFH8IAAIRAAgI0gsABQDoAQARAAgI0gsABQDoAQAAAA==.',['龍成']='龍成:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end