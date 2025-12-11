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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Protection','Monk-Brewmaster','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Druid-Restoration','Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Protection','DeathKnight-Blood','DeathKnight-Frost','Evoker-Devastation','Unknown-Unknown','Warrior-Arms','DemonHunter-Havoc','Monk-Mistweaver','Warrior-Fury','Priest-Holy','Paladin-Holy','Druid-Balance','Shaman-Elemental','Monk-Windwalker','DeathKnight-Unholy',}; local provider = {region='CN',realm='狂风峭壁',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ap='Apolloone:BAAALAAECgcIBwAAAA==.',Ba='Babyfel:BAAALAAFFAIIBAAAAA==.',Da='Danai:BAABLAAFFH8YAAMBAAUIyhkASQAnAQABAAUIJRcASQAnAQACAAIINhkwHgCQAAAAAA==.',Di='Diana:BAAALAAECgQIBAAAAA==.',Ei='Eilenngu:BAAALAAECgUIBQAAAA==.',El='Elimatton:BAAALAAFFAMIAwAAAA==.Elsa:BAAALAAECgQIBQAAAA==.',Ho='Homelander:BAAALAAECgYIDAAAAA==.',Ji='Jiaxinge:BAABLAAFFH8GAAIDAAYIKBQ5DwBWAQADAAYIKBQ5DwBWAQAAAA==.',Ju='Jumpwithme:BAABLAAFFH8WAAIEAAUI3gf4FQDVAAAEAAUI3gf4FQDVAAAAAA==.',Ma='Malcanthet:BAACLAAFFH8eAAMFAAYI1RQpAwDyAAAGAAUI+xQXNQA+AQAFAAMITw0pAwDyAAAsAAQKfxcABAYACAjDHvgmAL0BAAYABwg3G/gmAL0BAAUABAh0Hq4FAG4BAAcAAggDBdeGAGYAAAAA.',Me='Mercy:BAAALAAECgQIBAAAAA==.Messi:BAAALAAFFAIIBAAAAA==.',No='Noexpectati:BAAALAAECgYIDQAAAA==.Novermouth:BAABLAAFFH8IAAIIAAMIvBSEHwDOAAAIAAMIvBSEHwDOAAAAAA==.',Pl='Playerhldmqk:BAAALAAECgYICgAAAA==.',Pr='Praying:BAABLAAFFH8FAAIJAAUIwCO1CgAFAgAJAAUIwCO1CgAFAgAAAA==.',Se='Secretmask:BAABLAAECn8VAAMKAAYIEBQIIQAYAQAKAAYIARQIIQAYAQALAAQISAzmTADTAAAAAA==.',Sn='Snowstorm:BAAALAAECgcIBwAAAA==.',Sv='Svip:BAACLAAFFH8XAAMMAAYIuhrBHwBqAQAMAAYIrhHBHwBqAQANAAQIPh24CwDeAAAsAAQKfxoAAwwACAhRIchPAFACAAwABwiFIMhPAFACAA0ABwieG6ISAIsBAAAA.',Vi='Vip:BAABLAAFFH8UAAMOAAYI6g5eDQA0AQAOAAYIJA5eDQA0AQAPAAIIOwsLXwCQAAAAAA==.',Xu='Xueyudd:BAABLAAFFH8LAAIQAAYIIw4NDQBPAQAQAAYIIw4NDQBPAQAAAA==.',Ze='Zerok:BAAALAADCggICAAAAA==.',['Äö']='Äöäöä:BAAALAADCgcIBwABLAAECgMIAwARAAAAAA==.',['一为']='一为了孩子:BAAALAAECgYIEgAAAA==.',['一亿']='一亿年太久:BAABLAAECn8jAAMDAAcIRgU4PACgAAADAAcI6wM4PACgAAASAAYIAQUDEQByAAAAAA==.',['一修']='一修罗一:BAABLAAECn8YAAMPAAgIyR4GPQCJAgAPAAgIJR0GPQCJAgAOAAgIkhfGGQDNAQAAAA==.',['一减']='一减:BAAALAAFFAIIAgAAAA==.',['一斩']='一斩霏霜:BAABLAAFFH8MAAITAAYI2A60JwBTAQATAAYI2A60JwBTAQAAAA==.',['一眼']='一眼千年:BAAALAAECgYIBwAAAA==.',['三十']='三十六的汉子:BAABLAAECn8YAAIUAAcIZwGQLABRAAAUAAcIZwGQLABRAAAAAA==.',['上班']='上班不打卡:BAAALAAECgYIDQAAAA==.',['不是']='不是这个洞:BAAALAADCgYIBgAAAA==.',['丑爆']='丑爆了:BAAALAAECgYICwAAAA==.',['世界']='世界那么脏:BAAALAAECgYIEwAAAA==.',['丛林']='丛林之魂:BAAALAAECgMIAwAAAA==.',['丨兎']='丨兎:BAAALAAECgYIEQAAAA==.',['丶杨']='丶杨:BAABLAAFFH8YAAIVAAYIoBqWFwCjAQAVAAYIoBqWFwCjAQAAAA==.',['丹仙']='丹仙丶:BAABLAAFFH8MAAILAAgIXRySCQBJAgALAAgIXRySCQBJAgAAAA==.',['丹圣']='丹圣丶:BAABLAAFFH8GAAILAAYI0BGHDQD7AQALAAYI0BGHDQD7AQAAAA==.',['丹天']='丹天丶:BAABLAAFFH8GAAILAAYIkRSKKgBoAQALAAYIkRSKKgBoAQAAAA==.',['丹宗']='丹宗丶:BAABLAAFFH8IAAILAAgI3h7pAwCyAgALAAgI3h7pAwCyAgAAAA==.',['丹帝']='丹帝丶:BAAALAAFFAgIAgAAAA==.',['丹法']='丹法丶:BAABLAAFFH8JAAILAAgI2RbbDAAdAgALAAgI2RbbDAAdAgAAAA==.',['丹皇']='丹皇丶:BAABLAAFFH8GAAILAAYIDhJ5DQD8AQALAAYIDhJ5DQD8AQAAAA==.',['丹魔']='丹魔丶:BAABLAAFFH8GAAILAAYIyBZqCgAYAgALAAYIyBZqCgAYAgAAAA==.',['乖熊']='乖熊:BAAALAAECggICAAAAA==.',['乱舞']='乱舞舞:BAAALAAFFAIIAgAAAA==.',['二十']='二十七的妹子:BAAALAAECgYIEgAAAA==.',['亚历']='亚历山大:BAAALAAECgIIBAAAAA==.',['似水']='似水:BAABLAAFFH8GAAIBAAIIWw9TXgCNAAABAAIIWw9TXgCNAAAAAA==.似水流年:BAAALAAECgYIDAAAAA==.',['体修']='体修道祖:BAABLAAFFH8IAAIDAAIIthcfHgCCAAADAAIIthcfHgCCAAAAAA==.',['佳缘']='佳缘菠菜:BAAALAAECgYIBgAAAA==.',['便便']='便便不带纸:BAABLAAFFH8IAAICAAYIXgiaCgD2AAACAAYIXgiaCgD2AAAAAA==.',['俺莲']='俺莲莲:BAABLAAECn8VAAIWAAgITweXgQD8AAAWAAgITweXgQD8AAAAAA==.',['倩女']='倩女幽玺:BAABLAAFFH8KAAICAAgIUALCFQBEAAACAAgIUALCFQBEAAAAAA==.',['偶尔']='偶尔忘喘气:BAAALAAFFAIIAgAAAA==.',['光头']='光头德:BAAALAAECgUIBwAAAA==.',['光蛋']='光蛋:BAABLAAFFH8QAAIMAAUIHxtwJABOAQAMAAUIHxtwJABOAQAAAA==.',['八奈']='八奈见杏菜丶:BAAALAAFFAIIAgAAAA==.',['兽洗']='兽洗烧:BAAALAAFFAIIAgAAAA==.',['冰淇']='冰淇淋:BAAALAAFFAIIAgAAAA==.',['冲锋']='冲锋释放:BAAALAAFFAIIBAAAAA==.',['几十']='几十个萨满:BAAALAAECgYICAAAAA==.',['几廿']='几廿个萨满:BAAALAAECgYIBgAAAA==.',['凯莱']='凯莱布帕维许:BAAALAAECgYIBgAAAA==.',['切尔']='切尔茜:BAAALAAECgYICwAAAA==.',['初级']='初级打手:BAAALAADCgQIBAAAAA==.',['劳艾']='劳艾德:BAAALAAECgEIAQAAAA==.',['勾叫']='勾叫什么:BAAALAAFFAIIAwAAAA==.',['勾莓']='勾莓娜赛:BAAALAAFFAIIAgAAAA==.',['十二']='十二翼天使:BAABLAAFFH8GAAIKAAYIOgFfIQAhAAAKAAYIOgFfIQAhAAAAAA==.',['十八']='十八岁的他:BAAALAAECgYICwAAAA==.',['千山']='千山暮雪:BAAALAAECgEIAQAAAA==.',['半巨']='半巨人不怒:BAAALAAECgYIBgAAAA==.',['南域']='南域巫士:BAAALAADCgcIBwAAAA==.南域猎狼:BAAALAAECgMIAwAAAA==.南域神骑:BAAALAAECgEIAQAAAA==.',['吃不']='吃不饱:BAAALAAECgYIBgAAAA==.',['君莫']='君莫思归:BAAALAAECggICAAAAA==.',['呜喵']='呜喵王:BAABLAAFFH8oAAIPAAUIUxx6OABZAQAPAAUIUxx6OABZAQAAAA==.',['咖喱']='咖喱棒棒鸡:BAAALAADCgEIAQAAAA==.',['哈基']='哈基仙:BAAALAAFFAIIBAAAAA==.',['哎翠']='哎翠花啊:BAAALAAECggICAAAAA==.',['哟哟']='哟哟有怪兽:BAAALAADCgIIAgAAAA==.',['啊五']='啊五环:BAAALAAFFAIIAgAAAA==.',['啊哩']='啊哩哩啊哩哩:BAABLAAECn8eAAIJAAcI3gHvegBJAAAJAAcI3gHvegBJAAAAAA==.',['啊牛']='啊牛哥:BAABLAAECn8gAAMNAAgIxgN4OQBkAAANAAcIgQJ4OQBkAAAXAAgI0QEuPABkAAAAAA==.',['喔额']='喔额起见:BAAALAAECgQIBAAAAA==.',['嗜血']='嗜血的卫生棉:BAAALAAECgMIAwAAAA==.',['嘛哩']='嘛哩嘛哩哄:BAABLAAECn8YAAMYAAgI5iEdFgC0AgAYAAgI5iEdFgC0AgAJAAgIQh+9CQCsAgAAAA==.',['四个']='四个字:BAABLAAFFH8JAAIBAAYIqhY1JwCVAQABAAYIqhY1JwCVAQABLAAFFAYIFAAMABAdAA==.',['回归']='回归零叁年:BAAALAAECggICAAAAA==.',['回忆']='回忆中的秋天:BAAALAAECggICAAAAA==.',['国产']='国产奶骑:BAAALAADCgIIAgAAAA==.',['圣光']='圣光照耀:BAAALAAECgIIAgAAAA==.',['堕天']='堕天:BAAALAAECgYIBgAAAA==.堕天丿:BAAALAAECgYICAAAAA==.堕天丿丿:BAAALAAECgYIBgAAAA==.堕天丿丿伊人:BAAALAAECgYIEQAAAA==.堕天丿丿钺:BAAALAAECgYIBgAAAA==.堕天卡皮巴拉:BAAALAAFFAQIBAAAAA==.',['塔姆']='塔姆:BAAALAAFFAIIBAAAAA==.',['夏日']='夏日青岚:BAAALAAECgYIBgAAAA==.',['夏木']='夏木木丶:BAAALAAECggIDQAAAA==.',['夜幽']='夜幽丶:BAAALAAFFAIIBAAAAA==.',['夜舞']='夜舞:BAAALAAECggICAAAAA==.',['夜魔']='夜魔侠:BAAALAAECgMIBQAAAA==.',['大叔']='大叔大叔:BAAALAAECgYICQAAAA==.大叔就是好:BAABLAAECn8YAAITAAYIuhCbuQBjAQATAAYIuhCbuQBjAQAAAA==.大叔怀仁:BAAALAAECgcIBwAAAA==.',['大只']='大只牙:BAAALAAECgYICQAAAA==.',['大川']='大川丶:BAAALAAFFAIIAgAAAA==.',['大火']='大火:BAAALAAFFAIIAgAAAA==.',['大灰']='大灰狼敲你门:BAAALAAFFAIIAgAAAA==.',['大炮']='大炮可可:BAAALAAFFAIIBAAAAA==.',['大熊']='大熊比较懒:BAAALAAECgcICAAAAA==.',['天天']='天天吃素:BAAALAAECgYIDAAAAA==.',['太阳']='太阳神之女:BAABLAAECn8ZAAIGAAcIpQJSggBzAAAGAAcIpQJSggBzAAAAAA==.',['失误']='失误术:BAAALAADCgIIAgAAAA==.',['奈飞']='奈飞天:BAABLAAFFH8SAAIHAAYIxxCeAgBvAQAHAAYIxxCeAgBvAQAAAA==.',['奔跑']='奔跑的红烧肉:BAAALAAECgYIBgAAAA==.',['奥德']='奥德彪洗地毯:BAACLAAFFH8IAAIYAAII/BUTGwCYAAAYAAII/BUTGwCYAAAsAAQKfxQAAhgACAhSIBAdAHgCABgACAhSIBAdAHgCAAAA.',['奶得']='奶得:BAABLAAFFH8IAAMMAAIIFgr3UwCOAAAMAAIIFgr3UwCOAAAXAAII2w0YIACIAAAAAA==.',['如似']='如似清风:BAABLAAECn8WAAIJAAYILhD7PgAeAQAJAAYILhD7PgAeAQAAAA==.',['妇科']='妇科张主任:BAAALAAECgQIBgAAAA==.',['妹子']='妹子请你睡觉:BAAALAAECgYIEQAAAA==.',['宇宙']='宇宙小小尘埃:BAAALAAECgYIBgAAAA==.',['宇枫']='宇枫:BAABLAAFFH8IAAIPAAgIQh3kCABrAgAPAAgIQh3kCABrAgAAAA==.',['安东']='安东尼狂风:BAABLAAECn8YAAMZAAgIfBu3KgBoAgAZAAgIfBu3KgBoAgAIAAgICRxjMgBKAgAAAA==.',['安妮']='安妮妮:BAAALAAECgYIBgAAAA==.',['宝宝']='宝宝无聊:BAAALAAECgYIDQAAAA==.',['寓清']='寓清于浊丶:BAAALAAECgYICAAAAA==.',['寳寳']='寳寳乄灀:BAAALAAECgMIBgAAAA==.',['射死']='射死你:BAAALAAFFAIIAgAAAA==.',['小刀']='小刀之刀:BAAALAAECgYIAwAAAA==.',['小小']='小小飞儿:BAAALAAECgEIAQAAAA==.',['小恶']='小恶魔魔:BAAALAAECgYIDQAAAA==.',['小时']='小时候很帥:BAAALAAECgcIDQAAAA==.',['小箜']='小箜箜:BAAALAAECggICAAAAA==.',['尐冰']='尐冰块:BAAALAADCgYIBgAAAA==.',['幻狼']='幻狼:BAABLAAFFH8GAAIBAAYIaAFbeABsAAABAAYIaAFbeABsAAAAAA==.',['廿四']='廿四小时考拉:BAAALAAECgYICAAAAA==.',['张曼']='张曼成:BAAALAAECgYIEgAAAA==.',['强到']='强到你唔信:BAABLAAFFH8KAAIBAAII3yClRACfAAABAAII3yClRACfAAAAAA==.',['德玛']='德玛西亚亚:BAAALAAECgYIBgAAAA==.',['快乐']='快乐刀男:BAAALAAECgYIBgAAAA==.',['恐怖']='恐怖小说:BAAALAAECgIIAwAAAA==.',['恶魔']='恶魔之瞳:BAAALAAECgIIAgAAAA==.',['感伤']='感伤猎灵:BAAALAAECgIIAgAAAA==.',['愿圣']='愿圣光忽悠伱:BAAALAAECgQIAQAAAA==.',['拉米']='拉米亚斯:BAAALAAECggICAAAAA==.',['插图']='插图腾的小德:BAAALAAECgcICgAAAA==.',['撒拉']='撒拉嘿呦:BAAALAAFFAIIAgAAAA==.',['无心']='无心紫雨:BAAALAAECgYIBgAAAA==.',['无法']='无法大魔:BAAALAAECgUIBQAAAA==.',['星痕']='星痕灬晨曦:BAAALAAECgEIAQAAAA==.',['暮岚']='暮岚寒枫:BAABLAAFFH8IAAIBAAMINgiHdgBxAAABAAMINgiHdgBxAAAAAA==.',['暮色']='暮色消退:BAAALAAECgYIBgAAAA==.',['暮雨']='暮雨朝露:BAAALAAECgYIDwAAAA==.',['暴力']='暴力压制:BAAALAAECgUIBQAAAA==.',['月光']='月光星灵:BAAALAAECgYIBgAAAA==.',['月神']='月神降临:BAAALAAFFAIIBAAAAA==.',['月舞']='月舞飘影:BAAALAAECgYIEQAAAA==.',['木戈']='木戈:BAAALAADCgIIAgAAAA==.',['木珀']='木珀:BAAALAADCgIIAgAAAA==.',['未语']='未语人先羞:BAAALAAECgYICgAAAA==.',['机械']='机械纽扣:BAAALAAECgQIBAAAAA==.',['李与']='李与刘:BAABLAAECn8WAAIVAAYI6RyuWgDiAQAVAAYI6RyuWgDiAQAAAA==.',['柔情']='柔情背后:BAABLAAFFH8GAAIBAAIILxoEUQCVAAABAAIILxoEUQCVAAAAAA==.',['柠檬']='柠檬丶:BAAALAAECgUIBQAAAA==.',['柳如']='柳如烟:BAAALAAECgYIBgAAAA==.',['栽培']='栽培:BAAALAAECgYIDwAAAA==.',['桉树']='桉树叶:BAAALAAFFAEIAQAAAA==.',['梦岚']='梦岚:BAABLAAECn8dAAMHAAYIwhiZPQB2AQAHAAYI0hGZPQB2AQAGAAYIkBKkngA/AQAAAA==.',['棉花']='棉花棒棒:BAAALAAECgYIBwAAAA==.',['棒棒']='棒棒宝宝:BAABLAAFFH8TAAIZAAYIcgi1IAA7AQAZAAYIcgi1IAA7AQAAAA==.',['欢喜']='欢喜牛喜欢:BAAALAAECgIIAgAAAA==.',['欢场']='欢场米妮:BAABLAAFFH8XAAIWAAYIPSGBBwBSAgAWAAYIPSGBBwBSAgAAAA==.',['止战']='止战之殇:BAAALAAECgcIDgAAAA==.',['水深']='水深:BAAALAAFFAIIAgAAAA==.',['永乐']='永乐奶电煞:BAAALAADCgQIBAAAAA==.',['沉魚']='沉魚丶:BAAALAAECgYIBgAAAA==.',['沉鱼']='沉鱼丶:BAAALAADCgcIBwAAAA==.',['没差']='没差:BAAALAAECgYIBgAAAA==.',['浅梦']='浅梦:BAAALAAECgYIDAAAAA==.',['滴滴']='滴滴打怪:BAAALAAFFAIIAwAAAA==.',['潴潴']='潴潴嫒你:BAAALAAECgUICAAAAA==.',['火鸡']='火鸡味锅巴丶:BAAALAAECgIIAgAAAA==.',['灬转']='灬转弯的箭:BAABLAAFFH8GAAIBAAIIJgkabgCBAAABAAIIJgkabgCBAAAAAA==.',['爱上']='爱上夏天的蕓:BAABLAAFFH8HAAIMAAQI6AM/eQA4AAAMAAQI6AM/eQA4AAAAAA==.',['爱原']='爱原始森林:BAACLAAFFH8GAAIWAAIIIAU/RwBcAAAWAAIIIAU/RwBcAAAsAAQKfy0AAhYACAgbC901ABkBABYACAgbC901ABkBAAAA.',['爱雪']='爱雪花飘:BAABLAAECn8fAAMPAAgIZgLdugBoAAAPAAYIggLdugBoAAAOAAYIlwGmLwA9AAAAAA==.',['爱高']='爱高山:BAABLAAECn8ZAAIGAAcIRgNQdACiAAAGAAcIRgNQdACiAAAAAA==.',['牛主']='牛主任:BAAALAAECgYICwAAAA==.',['牛肝']='牛肝菌:BAAALAAECgYIAwAAAA==.',['狂暴']='狂暴的鹌鹑:BAAALAADCgcIBwAAAA==.',['狩猎']='狩猎之声:BAAALAAECgEIAQAAAA==.',['猫北']='猫北:BAAALAAECgYICgAAAA==.',['玄幻']='玄幻小说:BAABLAAECn8bAAMKAAYIGh7tQQBpAQALAAYINhkagACSAQAKAAQI0CHtQQBpAQAAAA==.',['王珊']='王珊琪女王:BAAALAAFFAEIAQAAAA==.',['玥鵺']='玥鵺:BAAALAAECgQICgAAAA==.',['珍妮']='珍妮嘛:BAAALAADCgYIBwAAAA==.珍妮弗:BAAALAADCgMIAwAAAA==.',['瓜田']='瓜田里的猹:BAABLAAFFH8GAAIMAAUI1QMsNwDHAAAMAAUI1QMsNwDHAAAAAA==.',['疯狂']='疯狂的韭菜:BAAALAAFFAQIBAAAAA==.',['疼痛']='疼痛:BAAALAAECgYIBgAAAA==.',['白芍']='白芍:BAAALAADCggIDgAAAA==.',['盖世']='盖世英熊:BAABLAAFFH8IAAIaAAUILwf6DQDWAAAaAAUILwf6DQDWAAAAAA==.',['看灬']='看灬:BAABLAAFFH8FAAIBAAIIPQYqeQBzAAABAAIIPQYqeQBzAAAAAA==.',['真德']='真德香草奶昔:BAACLAAFFH8aAAMJAAYIhBXbEgClAQAJAAYIhBXbEgClAQAYAAQIWxlNIgCgAAAsAAQKfxYAAwkABghzGzAgANEBAAkABghzGzAgANEBABgAAgiwEmROAHsAAAAA.',['秦丨']='秦丨始丨皇:BAAALAAFFAMIAwAAAA==.',['秦少']='秦少游:BAACLAAFFH8rAAMKAAYISBc1BQBzAQAKAAYISBc1BQBzAQALAAIIJQtQVgBFAAAsAAQKfyYAAwoACAh9I3gGAG4CAAoACAhcIHgGAG4CAAsACAg3HA8PAEECAAEsAAUUCAggAAsAnyAA.',['秦观']='秦观:BAABLAAFFH8SAAMKAAYIbRShBQBkAQAKAAYIbRShBQBkAQALAAMIdwdnTABcAAAAAA==.',['穹袁']='穹袁:BAAALAAFFAIIAgAAAA==.',['筒二']='筒二爷:BAAALAAECgIIBQAAAA==.',['筒子']='筒子哥:BAAALAAECgMIAwAAAA==.',['简单']='简单就是漂亮:BAAALAAECgYIBwAAAA==.',['米莉']='米莉娜:BAAALAAECggIEAAAAA==.',['精灵']='精灵之殇:BAAALAAECgQIBwAAAA==.',['素枝']='素枝:BAAALAADCgQIBAAAAA==.',['终极']='终极紫微星:BAAALAADCgMIAwAAAA==.',['绿眼']='绿眼瞎子丶:BAAALAAECgMIAwAAAA==.',['老婆']='老婆蛤蟆妖:BAAALAAECgIIAgAAAA==.',['胎哥']='胎哥:BAAALAAECgYIBgAAAA==.',['自闭']='自闭丶:BAACLAAFFH8JAAIIAAMIiBQpPwCDAAAIAAMIiBQpPwCDAAAsAAQKfxUAAwgABghSG/51AJYBAAgABghSG/51AJYBABkAAQgeB5t/ACcAAAAA.',['舞清']='舞清影:BAABLAAECn8XAAIMAAYI8QyihwDxAAAMAAYI8QyihwDxAAAAAA==.',['花天']='花天狂骨丶:BAAALAAECgYIBgAAAA==.',['茶点']='茶点时光:BAAALAAECgUIBQAAAA==.',['荒野']='荒野大镖客:BAAALAAECgUIBQAAAA==.',['荣耀']='荣耀圣光:BAAALAAECgYIBgAAAA==.',['萨拉']='萨拉塔斯:BAAALAAECgYIBgAAAA==.',['萨摩']='萨摩耶:BAABLAAFFH8GAAIPAAIIBhbbcQCPAAAPAAIIBhbbcQCPAAAAAA==.',['蓝色']='蓝色丨星痕:BAAALAAECgMIAwAAAA==.蓝色忄霜月:BAAALAAECgYIDAAAAA==.蓝色灬晨曦:BAAALAAECgYIBgAAAA==.',['蓝鳍']='蓝鳍:BAAALAADCggICAAAAA==.',['藏藏']='藏藏:BAACLAAFFH8jAAIMAAYIlxt1EgC0AQAMAAYIlxt1EgC0AQAsAAQKfzAAAgwACAi6HzsxAK0CAAwACAi6HzsxAK0CAAAA.',['西利']='西利丝:BAAALAAECgYICgAAAA==.',['言情']='言情小说:BAAALAADCgMIAwAAAA==.',['调理']='调理只西:BAAALAAECgMIAwAAAA==.',['象征']='象征高贵:BAABLAAECn8VAAIIAAYIMyBGGgAgAgAIAAYIMyBGGgAgAgABLAAFFAgICgAIAO4aAA==.',['赏心']='赏心悦目:BAAALAAECgcIDQAAAA==.',['轻柔']='轻柔雨:BAAALAADCgUIBQAAAA==.',['边城']='边城小萨:BAAALAAECgYIBwAAAA==.',['迈克']='迈克沃尔夫:BAAALAAECgcIDwAAAA==.',['迷失']='迷失的节屮:BAAALAAECgYIBgAAAA==.',['逆风']='逆风丶:BAAALAAFFAIIAgAAAA==.',['速猛']='速猛萨:BAABLAAFFH8OAAMIAAQIjxhPOgC5AAAIAAMI9RVPOgC5AAAZAAEIdwoJQABKAAAAAA==.速猛骑:BAAALAADCggIBwAAAA==.',['那一']='那一槍温柔:BAAALAAECgEIAQAAAA==.',['酱油']='酱油瓶:BAAALAAFFAIIBAAAAA==.',['醉享']='醉享风抚:BAAALAAECgEIAQAAAA==.',['银河']='银河配方:BAAALAAFFAIIBAAAAA==.',['销魂']='销魂姐姐:BAAALAADCgEIAQAAAA==.',['阿丹']='阿丹丶:BAABLAAFFH8GAAILAAYI/hRZCwAPAgALAAYI/hRZCwAPAgAAAA==.',['随便']='随便玩玩儿:BAABLAAFFH8MAAIMAAIItxYxOwCiAAAMAAIItxYxOwCiAAAAAA==.',['雪露']='雪露诺姆:BAAALAAECgMIAwAAAA==.',['霸波']='霸波尔渀:BAAALAAFFAIIAgAAAA==.',['青荷']='青荷滴雨:BAAALAAECgUIBQAAAA==.',['靓爆']='靓爆镜:BAAALAAECgYIBgAAAA==.',['韩宝']='韩宝宝:BAAALAAECgYIBgAAAA==.',['韭菜']='韭菜炒鸡蛋:BAACLAAFFH8aAAQPAAcI+yN1BgA+AgAPAAcIhCN1BgA+AgAOAAQIKxUDEwCiAAAbAAEIQxikFwBlAAAsAAQKfyYABA8ACAjqJTIKAFADAA8ACAjqJTIKAFADAA4ABQjlGrsqACYBABsAAQgAJMlRAGcAAAAA.',['風清']='風清露寒:BAAALAAFFAIIBAAAAA==.',['風雲']='風雲弑冰:BAAALAAECgYIBgAAAA==.風雲弑雪:BAAALAAECgYIBgAAAA==.風雲梦雨兮:BAAALAAECgQIBAAAAA==.',['风中']='风中残花:BAAALAAFFAEIAQAAAA==.',['风的']='风的倾诉:BAAALAAECgUIBQAAAA==.',['风笛']='风笛:BAABLAAECn8cAAIKAAYIJAlwVgAbAQAKAAYIJAlwVgAbAQAAAA==.',['飘流']='飘流幻境:BAAALAAECgUIDQAAAA==.',['黑道']='黑道友红老衲:BAACLAAFFH8IAAIMAAIIuh3nJADBAAAMAAIIuh3nJADBAAAsAAQKfxUAAgwABgjKHjluAA0CAAwABgjKHjluAA0CAAAA.',['龘齉']='龘齉齾:BAAALAAECgYIDQAAAA==.',['龙人']='龙人:BAAALAAECgYIEwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end