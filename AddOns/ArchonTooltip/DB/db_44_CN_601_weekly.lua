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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Mage-Frost','Shaman-Restoration','Monk-Mistweaver','Paladin-Protection','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Paladin-Retribution','Priest-Shadow','Priest-Holy','Mage-Arcane','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Unknown-Unknown','Warrior-Protection','Druid-Feral','Druid-Restoration','Shaman-Elemental','Warrior-Fury','Druid-Balance',}; local provider = {region='CN',realm='卡珊德拉',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bl='Blast:BAACLAAFFH8NAAMBAAII6wsXLQBrAAABAAIIzAsXLQBrAAACAAEIAQd/tgAzAAAsAAQKfxwAAwEABwhaHi4gAGUCAAEABwhaHi4gAGUCAAIAAQgIFJqSAT4AAAAA.',Bo='Bosa:BAAALAAECgUICgABLAAFFAIIBQADAIkGAA==.',Cu='Curten:BAAALAAECgMIAwAAAA==.',Cy='Cyanide:BAAALAAECggICgAAAA==.',Da='Dannmm:BAACLAAFFH8FAAIDAAIIiQZxXAB7AAADAAIIiQZxXAB7AAAsAAQKfycAAgMACAiSEQeZAJgBAAMACAiSEQeZAJgBAAAA.Darkblade:BAAALAADCgIIAgAAAA==.',Fa='Fantastic:BAABLAAFFH8IAAIEAAIIuAiGKgBjAAAEAAIIuAiGKgBjAAAAAA==.',Fo='Fox:BAAALAAECgEIAQAAAA==.',Hl='Hlidskiaf:BAACLAAFFH8GAAIFAAIIfQqCTQCFAAAFAAIIfQqCTQCFAAAsAAQKfyUABAUACAg+HuAuAIMCAAUACAg+HuAuAIMCAAYAAgjbBLczAGQAAAcAAgixCDSIAGEAAAAA.',Ju='Junble:BAAALAAECgYIDAABLAAFFAIIBQADAIkGAA==.',Li='Lina:BAAALAADCgQIBAAAAA==.Littlelily:BAAALAADCgIIAgAAAA==.',Lo='Lostangle:BAACLAAFFH8kAAIIAAUI/RpDBgBRAQAIAAUI/RpDBgBRAQAsAAQKfyEAAggACAiYIbkKAO4CAAgACAiYIbkKAO4CAAAA.',Ms='Ms:BAABLAAFFH8TAAIJAAYIKAxIJQA2AQAJAAYIKAxIJQA2AQAAAA==.',Na='Natsuki:BAAALAAECgMIBQAAAA==.',No='Noxa:BAAALAAECgEIAQAAAA==.',Ra='Rapeter:BAAALAAFFAIIBAAAAA==.',To='Touchgirl:BAAALAAECgYIDwAAAA==.',Vi='Vickyy:BAAALAAECgYIBgAAAA==.',['一把']='一把老骨头:BAAALAAECgIIAgAAAA==.',['一步']='一步之遥:BAAALAAECgEIAQAAAA==.',['一贱']='一贱伱就笑:BAAALAAECgEIAQAAAA==.',['七月']='七月微风:BAAALAAECgYIDAAAAA==.',['乌拉']='乌拉诺祀:BAAALAAECgQIBAAAAA==.',['二十']='二十九号昆师:BAABLAAECn8UAAIKAAgIpADDVgAmAAAKAAgIpADDVgAmAAAAAA==.',['亿利']='亿利蛋:BAAALAADCgIIAgAAAA==.',['伊蕾']='伊蕾娜:BAAALAAECgUIBQAAAA==.',['伱大']='伱大爷:BAAALAAECgQIBAAAAA==.',['佛系']='佛系挖矿:BAAALAAECgMIAwAAAA==.',['你的']='你的布洛芬:BAAALAAECgYICwAAAA==.',['信仰']='信仰圣光:BAAALAAFFAIIBAAAAA==.',['偶像']='偶像来也:BAAALAAECgUIBQAAAA==.',['先打']='先打德:BAAALAAFFAIIBAAAAA==.',['光之']='光之双刃:BAAALAAECgYIDQAAAA==.光之律者:BAABLAAFFH8KAAMEAAIIBgN/LABYAAAEAAIIBgN/LABYAAALAAIIFg1kIAArAAAAAA==.',['克里']='克里丝叮:BAAALAADCggICAAAAA==.',['八月']='八月微风:BAAALAAECgYIBgAAAA==.',['刘逼']='刘逼诚:BAAALAAECggIDwAAAA==.',['刘铋']='刘铋诚:BAACLAAFFH86AAQMAAgIwyF/AADGAgAMAAgIwyF/AADGAgANAAYI7hWLCgB4AQAOAAMIYBTMDgBMAAAsAAQKfyMABAwACAijHrYIAKcCAAwACAijHrYIAKcCAA0ABQjLI1kLAOABAA4AAgjgGUQYAHoAAAAA.',['北极']='北极的北极熊:BAAALAAECgYICgAAAA==.北极的极地狐:BAAALAAFFAEIAQAAAA==.',['卖女']='卖女孩得火柴:BAABLAAFFH8OAAIJAAII0hpeRQCWAAAJAAII0hpeRQCWAAAAAA==.',['卡西']='卡西亚:BAAALAAECgIIAgAAAA==.',['只会']='只会假死:BAAALAAFFAIIBAAAAA==.',['司美']='司美格鲁肽:BAAALAAECggICAAAAA==.',['咖色']='咖色:BAAALAADCgMIAwAAAA==.',['哆一']='哆一点点:BAABLAAFFH8IAAIPAAIIzhMFPwCfAAAPAAIIzhMFPwCfAAAAAA==.',['哎呦']='哎呦不错:BAAALAAFFAMIAgAAAA==.',['哒啦']='哒啦术术:BAACLAAFFH8mAAMGAAYIfyILAQDVAQAGAAYIfyILAQDVAQAHAAEIlANEMABBAAAsAAQKfyYAAwYACAiLJSABAFYDAAYACAiLJSABAFYDAAUAAQg6G836AEsAAAAA.哒啦沐沐:BAABLAAFFH8SAAMQAAUIaBeQEgBFAQAQAAUIaBeQEgBFAQARAAIIsREuMQCNAAAAAA==.哒啦珐珐:BAAALAAECgEIAQAAAA==.哒啦迪迪:BAAALAAECgYIBgAAAA==.哒啦隆隆:BAAALAAFFAIIAgAAAA==.',['啃嘀']='啃嘀草冒嘀奶:BAAALAAECgYIBgAAAA==.',['夏煙']='夏煙凝:BAAALAADCgQIBAAAAA==.',['大蛋']='大蛋蛋:BAABLAAFFH8GAAIDAAYIfAL5OACsAAADAAYIfAL5OACsAAAAAA==.',['妖怪']='妖怪大魔王:BAAALAAFFAIIAgAAAA==.',['婥礿']='婥礿:BAAALAAFFAMIAwAAAA==.',['密雪']='密雪冰城:BAAALAAECggIDAAAAA==.',['小手']='小手冰凉:BAAALAADCggIEQAAAA==.',['小番']='小番茄大冬瓜:BAABLAAFFH8GAAIPAAYIfhLRHwBpAQAPAAYIfhLRHwBpAQAAAA==.',['小风']='小风华月夜:BAABLAAFFH8GAAIPAAYIBwLhSQBxAAAPAAYIBwLhSQBxAAAAAA==.',['少先']='少先队:BAAALAAFFAIIBAAAAA==.',['帕拉']='帕拉斯:BAAALAADCgMIAwAAAA==.',['幻影']='幻影蛋蛋:BAABLAAFFH8GAAISAAYI8ACRSwBmAAASAAYI8ACRSwBmAAABLAAFFAgICAASAA0eAA==.',['幻滅']='幻滅花火:BAABLAAFFH8GAAIFAAIIvwnwXwA/AAAFAAIIvwnwXwA/AAAAAA==.',['弓之']='弓之月神:BAABLAAFFH8KAAICAAUIBRBVVwDvAAACAAUIBRBVVwDvAAAAAA==.',['德莱']='德莱妮丝:BAAALAAECgYIBgAAAA==.',['怒火']='怒火圣光:BAAALAAECgYIDwAAAA==.',['恩佐']='恩佐斯的副官:BAACLAAFFH8qAAITAAcIuByeFADtAQATAAcIuByeFADtAQAsAAQKfysABBMACAg5JIMkAN4CABMACAgkJIMkAN4CABQABwg8HwoKAOsBABUAAQjVCblfAC8AAAAA.',['悟空']='悟空在世:BAABLAAFFH8NAAMBAAYIzRNDCgBdAQABAAUIDxJDCgBdAQACAAMIehB/JADsAAAAAA==.',['情已']='情已沫丶:BAAALAAECgQIBAAAAA==.',['我是']='我是丶大叔:BAAALAAECgYIDgABLAAFFAgIAwAWAAAAAA==.',['我萨']='我萨满真牛逼:BAAALAAECgUIBQAAAA==.',['战一']='战一加一:BAABLAAFFH8NAAIXAAgIVAsvCwCOAQAXAAgIVAsvCwCOAQAAAA==.',['战三']='战三:BAABLAAFFH8PAAIXAAgI+g1kCQCsAQAXAAgI+g1kCQCsAQAAAA==.',['战五']='战五:BAABLAAFFH8GAAIXAAYI1QWOGADgAAAXAAYI1QWOGADgAAAAAA==.',['战四']='战四:BAABLAAFFH8UAAIXAAgIxwvGCwCFAQAXAAgIxwvGCwCFAQAAAA==.',['战胜']='战胜它呀:BAAALAAFFAIIAgAAAA==.',['拉布']='拉布拉多:BAAALAAECgUIBQAAAA==.',['挚爱']='挚爱:BAAALAAECggICAAAAA==.',['旅行']='旅行箱:BAAALAAECgYICwAAAA==.',['无所']='无所吊谓:BAAALAAECgYICQAAAA==.',['无敌']='无敌的姐姐:BAAALAAECgIIAgAAAA==.',['木辛']='木辛龍:BAAALAAECgUIBQAAAA==.木辛龙:BAAALAAECgQICQAAAA==.',['本瑞']='本瑞利珠:BAABLAAFFH8GAAIYAAYIPwHIEQAqAAAYAAYIPwHIEQAqAAAAAA==.',['李梅']='李梅烧烤:BAABLAAFFH8QAAMUAAgI0R+MAQClAgAUAAgI0R+MAQClAgATAAgIIQsoDwDcAQAAAA==.',['杏涵']='杏涵成:BAAALAAECgUIBgAAAA==.',['条街']='条街最萌妹:BAABLAAFFH8KAAIRAAIISRPlOgB1AAARAAIISRPlOgB1AAAAAA==.',['枫逝']='枫逝秋殘:BAABLAAFFH8GAAIXAAIIuQ1lLwA0AAAXAAIIuQ1lLwA0AAAAAA==.',['某凡']='某凡的咸鱼:BAABLAAFFH8HAAIZAAUIlwarJgDiAAAZAAUIlwarJgDiAAAAAA==.',['桃花']='桃花小幺妹:BAAALAAECgEIAQAAAA==.',['欲望']='欲望作祟:BAAALAAECgYIBgAAAA==.',['死亡']='死亡脚步:BAAALAAFFAIIAgAAAA==.死亡风暴领主:BAABLAAFFH8IAAIUAAII0gE6IAAYAAAUAAII0gE6IAAYAAAAAA==.',['每日']='每日涨停:BAABLAAFFH8GAAIZAAII/g+6LwB1AAAZAAII/g+6LwB1AAAAAA==.',['氵木']='氵木丶德:BAAALAAECgcIDAAAAA==.',['泥奏']='泥奏垲:BAAALAAECgYICwAAAA==.',['涵成']='涵成杏:BAAALAAECgUIBgAAAA==.',['涵诚']='涵诚杏:BAAALAAECgYIBgAAAA==.',['灬鬼']='灬鬼鬼灬:BAAALAAECgEIAQAAAA==.',['炫个']='炫个德丶:BAAALAAECgYICAAAAA==.炫个骑丶:BAAALAAECgYICwAAAA==.',['炫丶']='炫丶彩:BAAALAAECgYIBgAAAA==.',['炫二']='炫二彩:BAAALAAECgMIAwAAAA==.',['炫四']='炫四彩丶:BAAALAAECgEIAQAAAA==.',['炫彩']='炫彩:BAAALAADCgUIBQAAAA==.',['烟丶']='烟丶花:BAABLAAFFH8GAAIRAAIISgpCNwCFAAARAAIISgpCNwCFAAAAAA==.',['牛牛']='牛牛没有奶:BAAALAAECgYIBgAAAA==.',['玛达']='玛达拉:BAAALAADCgIIAgAAAA==.',['白兮']='白兮兮丶:BAAALAAECgEIAQAAAA==.',['空崎']='空崎日奈丶:BAABLAAFFH8SAAMIAAYIzQ6nCAAGAQAIAAYIMA6nCAAGAQASAAQI7AZ3RwCEAAAAAA==.',['粽弃']='粽弃疾:BAACLAAFFH8dAAIDAAcIows3GQCkAQADAAcIows3GQCkAQAsAAQKfxYAAgMABgjMGCekAIUBAAMABgjMGCekAIUBAAAA.',['紫电']='紫电青龙:BAAALAAECgYIBgABLAAFFAcIOwALAG0ZAA==.',['绿灯']='绿灯丶:BAAALAAECgYIBgAAAA==.',['罗爵']='罗爵灬:BAAALAAFFAIIAgAAAA==.',['翱翔']='翱翔炎:BAABLAAFFH8YAAMTAAYITxyWHADEAQATAAYIERuWHADEAQAUAAUIjhkODQA4AQAAAA==.翱翔羽:BAABLAAFFH8aAAMRAAUISiBMEQDRAQARAAUISiBMEQDRAQAQAAQIwBTJGQDhAAAAAA==.',['育红']='育红班班:BAAALAAFFAIIAgAAAA==.',['艺术']='艺术私房写真:BAAALAAFFAEIAQAAAA==.',['艾莉']='艾莉丝:BAAALAAECgIIAgAAAA==.',['芙莉']='芙莉德薇尔:BAAALAAECggIEgAAAA==.',['菊花']='菊花中的蛋蛋:BAABLAAFFH8GAAIBAAYIGQKHFgBBAAABAAYIGQKHFgBBAAAAAA==.菊花蛋蛋:BAABLAAFFH8GAAIaAAYIHQLQMgCUAAAaAAYIHQLQMgCUAAAAAA==.',['菩提']='菩提小主:BAABLAAFFH8GAAIbAAIIshRbLgCgAAAbAAIIshRbLgCgAAAAAA==.菩提小祖丶:BAABLAAFFH8GAAITAAIIPxXeWQCbAAATAAIIPxXeWQCbAAAAAA==.菩提尛祖:BAABLAAECn8cAAMcAAYI9hLOVABkAQAcAAYI9hLOVABkAQAZAAUIcBZfNgBHAQAAAA==.',['薄荷']='薄荷肉松:BAAALAAECgUIBQAAAA==.',['蛋蛋']='蛋蛋炸菊花:BAAALAAECggICAAAAA==.蛋蛋王:BAABLAAFFH8FAAITAAUIgQLxVQCxAAATAAUIgQLxVQCxAAABLAAFFAgIAQAWAAAAAA==.',['豆包']='豆包:BAACLAAFFH8IAAMJAAMIVRMMPACzAAAJAAMIVRMMPACzAAAaAAEIUwFsVQAaAAAsAAQKfzcAAgkACAhVHM0OAIICAAkACAhVHM0OAIICAAAA.',['追魂']='追魂梦扬之心:BAABLAAECn8bAAMCAAcIFh34kwC+AQACAAcIFh34kwC+AQABAAIIKA4AqwBaAAAAAA==.',['醉卧']='醉卧紅尘中:BAAALAAECgYIBgAAAA==.',['野德']='野德心之助:BAAALAADCgUIBQAAAA==.',['野性']='野性之呼唤:BAABLAAFFH8JAAIZAAMIKB7SHACvAAAZAAMIKB7SHACvAAAAAA==.',['闹闹']='闹闹卝鸿轩:BAABLAAECn8aAAIPAAgIUhw9LADBAgAPAAgIUhw9LADBAgAAAA==.',['阿尔']='阿尔灬萨斯:BAAALAAECggICgAAAA==.',['阿武']='阿武卵:BAABLAAFFH8GAAIaAAYIEwH3PABSAAAaAAYIEwH3PABSAAAAAA==.',['随便']='随便:BAABLAAFFH8MAAIRAAYIhhKcFwCVAQARAAYIhhKcFwCVAQAAAA==.',['随心']='随心的风:BAAALAAFFAIIAgAAAA==.',['难忘']='难忘妹妹:BAABLAAFFH8IAAIbAAIIPwo/VABBAAAbAAIIPwo/VABBAAAAAA==.',['雅典']='雅典纳:BAAALAAECgYIDAAAAA==.',['雪拉']='雪拉比:BAAALAAECgYIBgAAAA==.',['风之']='风之律者:BAAALAADCgYIBgAAAA==.',['高欢']='高欢:BAAALAAECgYICAAAAA==.',['鲁瑜']='鲁瑜潇:BAAALAAECgcIDAAAAA==.',['龙涵']='龙涵杏:BAAALAAECggICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end