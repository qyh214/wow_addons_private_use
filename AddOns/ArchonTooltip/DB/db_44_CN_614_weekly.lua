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
 local lookup = {'Mage-Arcane','Warlock-Destruction','Priest-Shadow','Priest-Holy','Druid-Restoration','Paladin-Holy','Paladin-Protection','Paladin-Retribution','Druid-Balance','Priest-Discipline','DeathKnight-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Brewmaster','Warlock-Demonology','Warlock-Affliction','Shaman-Restoration','Shaman-Elemental','Unknown-Unknown','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Monk-Mistweaver','Monk-Windwalker','Warrior-Protection','Warrior-Arms','Warrior-Fury','DemonHunter-Vengeance','DeathKnight-Unholy','Druid-Guardian','DeathKnight-Blood','Evoker-Preservation','Evoker-Devastation','Mage-Frost','Mage-Fire',}; local provider = {region='CN',realm='地狱之石',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Achilleus:BAABLAAECn8UAAIBAAgIQg4qbQDCAQABAAgIQg4qbQDCAQAAAA==.',Ai='Ailele:BAAALAAECgIIAgAAAA==.',Aq='Aqu:BAABLAAFFH8GAAICAAYIKxzJIQCUAQACAAYIKxzJIQCUAQAAAA==.',Bo='Bottlelln:BAACLAAFFH8cAAIDAAcIVxxfBwDkAQADAAcIVxxfBwDkAQAsAAQKfx8AAwMACAgyI6gKACADAAMACAgyI6gKACADAAQABAiiA21aAGAAAAAA.Bottleln:BAABLAAFFH8GAAICAAYI5gnCNQA6AQACAAYI5gnCNQA6AQAAAA==.Bottlelnn:BAAALAADCggICAAAAA==.Bottlepri:BAAALAADCggICAAAAA==.',['Bè']='Bèar:BAABLAAFFH8HAAIFAAMIbxITLgCzAAAFAAMIbxITLgCzAAAAAA==.',Ca='Caoguiruisb:BAAALAAFFAMIAgAAAA==.',Co='Colorful:BAABLAAECn8aAAQGAAcIfQ7FPgBkAQAGAAcIfQ7FPgBkAQAHAAYIARaUFwBZAQAIAAEI5hHbkAEqAAAAAA==.',De='Decondestiny:BAAALAAECgYIBgAAAA==.Demeter:BAABLAAFFH8KAAIIAAIIsiRIPgCfAAAIAAIIsiRIPgCfAAAAAA==.',Di='Discord:BAAALAADCgQIBAAAAA==.',Du='Dulex:BAAALAADCgYIBgAAAA==.',Ea='Eaisar:BAAALAADCgYIBgAAAA==.',Eu='Euphoria:BAACLAAFFH8dAAMJAAYI1xiVBAAPAgAJAAYI1xiVBAAPAgAFAAMImATiGAC+AAAsAAQKfyQAAwkACAi4IAEWALUCAAkACAi4IAEWALUCAAUABgibDZFGAPwAAAAA.',Fo='Footloose:BAAALAAFFAIIAgAAAA==.',Ga='Gabbriel:BAABLAAFFH8ZAAMDAAYIORRcDQCGAQADAAYIORRcDQCGAQAKAAEITQlFCAA1AAAAAA==.Galatea:BAAALAADCgEIAQAAAA==.',Gr='Grit:BAABLAAFFH8FAAILAAMI3AcWNADNAAALAAMI3AcWNADNAAAAAA==.',Hu='Huaier:BAAALAAFFAIIAgAAAA==.',Ka='Kaldaris:BAAALAADCgIIAgAAAA==.',La='Landul:BAAALAAFFAIIAgAAAA==.',Le='Lemondonk:BAAALAAFFAEIAQAAAA==.',Mo='Mortal:BAABLAAFFH8JAAILAAYIgwp5PgBBAQALAAYIgwp5PgBBAQAAAA==.',Pe='Pepsimidax:BAAALAAECgQIBAAAAA==.',Re='Reda:BAACLAAFFH8tAAMMAAYI5xg9BwBWAQANAAYI9hY6LwB6AQAMAAYIoxM9BwBWAQAsAAQKfy0AAwwACAjxHdYZAJQCAAwACAiiHdYZAJQCAA0ABwj6GfNOAKcBAAAA.',Rh='Rhapsodyy:BAAALAAECgEIAQAAAA==.',Sh='Shae:BAAALAAECgcIDgAAAA==.Shersonw:BAAALAAECgYIAQAAAA==.',So='Soundsgood:BAAALAADCgYIBgAAAA==.',Su='Supernova:BAAALAAECgYICQAAAA==.',To='Toss:BAAALAAECgEIAQAAAA==.',Ul='Ultrafuxk:BAAALAAECgYIBgAAAA==.',Ve='Vengeance:BAAALAAECgQIBAAAAA==.',Wh='Whiz:BAAALAAFFAIIBAAAAA==.',Za='Zavadoni:BAAALAAECggIBgAAAA==.',['一抹']='一抹灬清茶:BAABLAAFFH8LAAILAAUI1RFxRwAcAQALAAUI1RFxRwAcAQAAAA==.',['一路']='一路向钱:BAABLAAFFH8HAAMGAAUIPAr6FwAOAQAGAAUIPAr6FwAOAQAIAAEIFRUaiQAAAAAAAA==.',['七袭']='七袭:BAABLAAFFH8JAAINAAYIfA7ASgAhAQANAAYIfA7ASgAhAQAAAA==.',['三开']='三开战猎萨:BAAALAAFFAIIAgAAAA==.',['下雨']='下雨捡葡萄:BAAALAAECgcIDgAAAA==.',['不唐']='不唐:BAAALAADCgEIAQAAAA==.',['不胖']='不胖不瘦:BAABLAAFFH8KAAIOAAIIoQTlIwAiAAAOAAIIoQTlIwAiAAAAAA==.',['世界']='世界终曲:BAABLAAFFH8GAAILAAIIsReMVgCdAAALAAIIsReMVgCdAAAAAA==.',['丨一']='丨一丿:BAAALAADCgYIBgAAAA==.',['丨旒']='丨旒歆丨:BAACLAAFFH8LAAMCAAUIQxLnHQBAAQACAAQI1xPnHQBAAQAPAAEI9QuELABKAAAsAAQKfxYABAIACAhRHac2AGACAAIACAhRHac2AGACABAAAgi1CNwxAG0AAA8AAQj+AEygACkAAAAA.',['丨阿']='丨阿尒萨斯丨:BAAALAAECgMIAwAAAA==.',['丰川']='丰川祥子:BAABLAAECn8jAAIBAAcIZRYnLQBkAQABAAcIZRYnLQBkAQAAAA==.',['临渊']='临渊:BAAALAAFFAIIAgAAAA==.',['丶侧']='丶侧耳倾听:BAAALAAECgYIDAAAAA==.',['丶大']='丶大叔:BAAALAAECgYIBgAAAA==.',['丶鲁']='丶鲁鲁丨:BAABLAAFFH8HAAIRAAII8AeNXgBhAAARAAII8AeNXgBhAAAAAA==.',['丿一']='丿一丨丶:BAAALAAECgQIBwAAAA==.',['乌龙']='乌龙茶:BAABLAAFFH8GAAIIAAIIEAZpWgCGAAAIAAIIEAZpWgCGAAAAAA==.',['乐坛']='乐坛永远的神:BAAALAADCgEIAQAAAA==.',['乖宝']='乖宝宝兔兔:BAAALAADCggICAAAAA==.乖宝宝喵喵:BAAALAADCggICAAAAA==.',['九寒']='九寒丶:BAABLAAFFH8LAAILAAMIlRMHYACOAAALAAMIlRMHYACOAAAAAA==.',['乱箭']='乱箭穿鸟:BAAALAADCgQIBAAAAA==.',['乾龍']='乾龍:BAAALAADCgEIAQAAAA==.',['二宝']='二宝傍身:BAAALAAECgcIBwAAAA==.',['五十']='五十强:BAAALAAECgEIAQAAAA==.',['任五']='任五郎:BAAALAAECgMIAwAAAA==.',['伊夫']='伊夫里特:BAAALAAFFAIIAgAAAA==.',['倚楼']='倚楼听风雨:BAAALAADCgQIBAAAAA==.',['偷吃']='偷吃的猫:BAAALAAFFAIIAgAAAA==.',['元素']='元素天罡:BAAALAAFFAIIBAAAAA==.元素寂灭:BAABLAAECn8XAAISAAYIXRhLXwCaAQASAAYIXRhLXwCaAQAAAA==.',['元龙']='元龙战魂:BAABLAAFFH8NAAMFAAIIDwNTVgBHAAAFAAIIDwNTVgBHAAAJAAIIwg1ANgA5AAAAAA==.',['光之']='光之无法无天:BAAALAADCgcIBwAAAA==.',['克兰']='克兰蒂尔:BAAALAAFFAIIAgAAAA==.',['克洛']='克洛马古斯:BAAALAAECgIIAgAAAA==.',['六铺']='六铺炕老司机:BAAALAAECgEIAQAAAA==.',['再战']='再战夕阳红:BAAALAADCgEIAQAAAA==.',['冰冷']='冰冷拥抱:BAAALAADCgIIAgAAAA==.',['冰封']='冰封岚:BAABLAAFFH8PAAIIAAUIfhxZIwBUAQAIAAUIfhxZIwBUAQABLAAFFAYICQANAHwOAA==.',['冰火']='冰火之语:BAAALAAECgIIAgABLAAECgcICgATAAAAAA==.',['凯琳']='凯琳赛斯:BAAALAAECggICAAAAA==.',['凶梦']='凶梦的残影:BAABLAAFFH8cAAMSAAYI0hh0FgCJAQASAAYI0hh0FgCJAQARAAIIvQjPcgBAAAAAAA==.',['分叉']='分叉屁屁毛:BAAALAAECgYIDAAAAA==.',['动如']='动如雷震:BAAALAAFFAIIAgAAAA==.',['十字']='十字卫兵守卫:BAAALAADCgYIBgAAAA==.',['卓美']='卓美拉之梦:BAAALAAECgEIAQAAAA==.',['南风']='南风知我意:BAAALAAECgcIDQAAAA==.',['原来']='原来你也是:BAAALAAECgYIBgAAAA==.',['发哥']='发哥嘎嘎棒:BAAALAAECgIIAgAAAA==.',['取星']='取星河为礼:BAAALAAECgcICQAAAA==.',['口吐']='口吐莲花:BAABLAAFFH8QAAIBAAYI7AhRLwBLAQABAAYI7AhRLwBLAQABLAAFFAgINwASAH0bAA==.',['古德']='古德丨里安:BAABLAAECn8fAAILAAYI1h6pKADTAQALAAYI1h6pKADTAQAAAA==.',['古铁']='古铁:BAAALAAECgYICAAAAA==.',['古风']='古风韵味:BAAALAAECgIIAgAAAA==.',['可爱']='可爱小狮子:BAAALAAECgYIDAAAAA==.',['台风']='台风摸小鱼干:BAAALAADCgQIBAAAAA==.',['司马']='司马天命:BAACLAAFFH8vAAMUAAcIihk2BAD5AQAUAAcIIxk2BAD5AQAVAAII8BM6EQCWAAAsAAQKfywAAxUACAjWHi8aAMYBABQABgh0HiMkAPcBABUABwjnFy8aAMYBAAAA.',['吃我']='吃我劈头灵:BAAALAAECgYIBgAAAA==.',['吃饱']='吃饱打胖子:BAAALAAECgQIAgAAAA==.',['呼哈']='呼哈一声吼:BAABLAAFFH8KAAIWAAIIwxivSwBNAAAWAAIIwxivSwBNAAAAAA==.',['咪哥']='咪哥:BAACLAAFFH8GAAINAAIIDQWXewBvAAANAAIIDQWXewBvAAAsAAQKfyUAAg0ACAjbGIB0APMBAA0ACAjbGIB0APMBAAAA.',['哎呀']='哎呀丶唉哟:BAAALAADCgYIBgAAAA==.',['哥很']='哥很淡定:BAAALAAECggIBgAAAA==.',['唯爱']='唯爱丨不离:BAAALAAECgYICQAAAA==.',['嗜血']='嗜血大胖:BAAALAAECgMIBAAAAA==.嗜血血月:BAAALAADCgMIAgAAAA==.',['嘎嘣']='嘎嘣脆鸡肉味:BAAALAADCgMIAwAAAA==.',['四岁']='四岁就很拽:BAAALAAECgYIEQAAAA==.',['回复']='回复术:BAACLAAFFH8hAAMRAAYICyCCDQAAAgARAAYICyCCDQAAAgASAAMIgAXbOAB1AAAsAAQKfx0AAhEACAjqGa82ADwCABEACAjqGa82ADwCAAAA.',['地狱']='地狱灬邪影:BAAALAAECgYICAAAAA==.地狱的邪影:BAAALAAECgYICwAAAA==.地狱邪影:BAAALAAECgYIEgAAAA==.',['塔卡']='塔卡拉欣:BAAALAAECgYICgAAAA==.塔卡拉芯:BAAALAAECgQIBAAAAA==.',['墨星']='墨星辰:BAAALAAFFAEIAQAAAA==.',['壹命']='壹命不凡:BAABLAAFFH8GAAIIAAIIlBfwVgBLAAAIAAIIlBfwVgBLAAAAAA==.',['壹炮']='壹炮泯恩仇:BAAALAAECggICAAAAA==.',['夏季']='夏季的惆怅:BAABLAAFFH8IAAIBAAIIBROWUACQAAABAAIIBROWUACQAAAAAA==.',['夏日']='夏日阳光:BAAALAAFFAIIAgAAAA==.',['夜殇']='夜殇丶幻灭:BAAALAAECgIIAgAAAA==.',['夜色']='夜色黎明:BAAALAAECgEIAQAAAA==.',['大哥']='大哥来喽:BAAALAAECgMIBgAAAA==.',['大碗']='大碗宫主:BAAALAAECgIIAgAAAA==.',['天天']='天天出橙:BAAALAAFFAEIAQAAAA==.',['天鸣']='天鸣:BAAALAADCgQIBAAAAA==.',['太虚']='太虚任遨游:BAAALAADCgYIBQAAAA==.',['奇迹']='奇迹创造者干:BAAALAADCgMIAwAAAA==.',['奔驰']='奔驰得小野马:BAACLAAFFH8UAAIGAAYIRBYcCACjAQAGAAYIRBYcCACjAQAsAAQKfyYAAwYACAiRHu4SAHkCAAYACAiRHu4SAHkCAAgAAwi5C7tdAXYAAAAA.',['女王']='女王的弃从:BAAALAADCgYIBgAAAA==.',['奶粉']='奶粉:BAAALAAFFAIIBAAAAA==.',['妙妙']='妙妙鱼:BAAALAAECgEIAQAAAA==.',['子龍']='子龍:BAAALAADCgQIBAAAAA==.',['孤独']='孤独患者:BAAALAAECgIIAwAAAA==.',['宁小']='宁小闲:BAABLAAFFH8TAAQXAAYIkRw4BgDhAQAXAAYIkRw4BgDhAQAOAAEI+gDzHwAkAAAYAAEI2wFKHgAAAAABLAAFFAYIGgAIALQcAA==.',['守擭']='守擭:BAAALAAECgMIBAAAAA==.',['安度']='安度因怒风:BAAALAADCgQIBwAAAA==.',['宫野']='宫野志保:BAAALAAECggICAABLAAFFAgIBwAOAPwWAA==.',['寂寥']='寂寥:BAAALAAECgYIBgAAAA==.',['寂小']='寂小寞:BAAALAAFFAEIAQAAAA==.',['寂灭']='寂灭:BAAALAAECgMIAwAAAA==.',['寒江']='寒江孤影:BAAALAAFFAIIAgAAAA==.',['寒雨']='寒雨紫烟:BAABLAAFFH8KAAILAAIIvBmHUwCfAAALAAIIvBmHUwCfAAAAAA==.',['导航']='导航系统:BAAALAAECgQIBAAAAA==.',['小当']='小当午:BAAALAADCgMIAwAAAA==.',['小时']='小时候:BAAALAAECggICAAAAA==.',['小星']='小星辰:BAABLAAECn8ZAAMGAAcI7BuKCwA2AgAGAAcI7BuKCwA2AgAIAAUIXQS0UwGJAAAAAA==.',['小浣']='小浣熊:BAAALAAECgUIBQAAAA==.',['小浪']='小浪妞呀:BAAALAAFFAIIAgAAAA==.',['小牛']='小牛阿秋:BAAALAAECgYIDAAAAA==.',['小猫']='小猫儿:BAAALAAECgYIBgAAAA==.',['小野']='小野抡大锤:BAABLAAFFH8GAAIIAAYIswvdKQAvAQAIAAYIswvdKQAvAQAAAA==.小野皮卡皮:BAABLAAFFH8GAAISAAYI6wYRIwArAQASAAYI6wYRIwArAQAAAA==.',['小鹿']='小鹿妈妈:BAAALAADCgIIAgAAAA==.',['屠猪']='屠猪贩狗:BAAALAAECgUIBwAAAA==.',['山村']='山村羊羊:BAAALAAFFAIIAgAAAA==.',['山里']='山里灵活的狗:BAAALAAECgcICgAAAA==.',['巴索']='巴索罗米灬牛:BAAALAAECgcIBwAAAA==.',['帝狱']='帝狱:BAACLAAFFH8MAAIOAAMIiSE/CgAjAQAOAAMIiSE/CgAjAQAsAAQKfxQAAg4ACAhuIXcNAIMCAA4ACAhuIXcNAIMCAAEsAAUUBwgnABUAERoA.',['帝道']='帝道赤霄:BAACLAAFFH89AAMIAAYI6hXTJgBBAQAIAAUIKxjTJgBBAQAGAAUI1QiXFwAVAQAsAAQKf0YAAwgACAigFZZuAAwCAAgACAigFZZuAAwCAAYABwh/EXI1AJEBAAAA.',['年份']='年份:BAAALAAECgQIBQAAAA==.',['幸福']='幸福的小霸王:BAACLAAFFH86AAIZAAYIXhY8DQBwAQAZAAYIXhY8DQBwAQAsAAQKf0MABBkACAiuGnYeAD8CABkACAiuGnYeAD8CABoAAgi4BBU+AC0AABsAAQjMBNAXASQAAAAA.',['幽能']='幽能幻刃:BAAALAAFFAIIAgAAAA==.',['幽风']='幽风:BAAALAAECgUIBQAAAA==.',['序曲']='序曲一断点:BAAALAAECgYIBgAAAA==.',['廖莎']='廖莎:BAAALAAFFAIIAgAAAA==.',['廿壹']='廿壹:BAAALAAECgYIBgAAAA==.',['开天']='开天:BAABLAAFFH8JAAIFAAIIyAq0TABYAAAFAAIIyAq0TABYAAAAAA==.',['异族']='异族牛王:BAAALAAECgUIBgAAAA==.',['得意']='得意地飘:BAABLAAECn8VAAMWAAgInBS7bwDmAQAWAAgInBS7bwDmAQAcAAII/AsNXgBTAAAAAA==.',['德伊']='德伊鲁:BAAALAAECgYICgAAAA==.',['忧郁']='忧郁大喷菇:BAAALAAECgYICAAAAA==.忧郁天狼星:BAABLAAFFH8GAAIRAAIIKgc7bABPAAARAAIIKgc7bABPAAAAAA==.',['快乐']='快乐踩着悲伤:BAAALAADCgYIBgAAAA==.',['悯瑟']='悯瑟圣光:BAAALAAECggIDAAAAA==.',['我刀']='我刀呢:BAAALAAECgYIDwAAAA==.',['我叫']='我叫耸皮:BAABLAAFFH8FAAILAAMIGQrWZgB8AAALAAMIGQrWZgB8AAAAAA==.',['我救']='我救个毛啊:BAABLAAFFH8GAAIGAAIIthZoIwCHAAAGAAIIthZoIwCHAAAAAA==.',['我是']='我是个奶萨:BAAALAAFFAIIAgAAAA==.我是喵大人:BAACLAAFFH8lAAMCAAcInRQ5EQDaAQACAAcInRQ5EQDaAQAPAAEIqgpBLABKAAAsAAQKfyYAAwIABwjYIDc4AFoCAAIABwjYIDc4AFoCAA8ABQgPE05MAEEBAAAA.我是骑士:BAAALAAECgYIBgAAAA==.',['我这']='我这小红手:BAABLAAFFH8GAAIBAAII5xrsRQCaAAABAAII5xrsRQCaAAAAAA==.',['我配']='我配我配:BAAALAADCgIIAgAAAA==.',['托莉']='托莉娜的锋刃:BAACLAAFFH8mAAMbAAcIyB+eCQAaAgAbAAcIyB+eCQAaAgAZAAEISRE7MABTAAAsAAQKf0QAAxsACAirJYkHAFkDABsACAiKJYkHAFkDABkABgjGIqYMAAQCAAAA.',['把酒']='把酒成疯:BAABLAAFFH8GAAILAAIIBhigVQCdAAALAAIIBhigVQCdAAAAAA==.',['抗到']='抗到天明:BAAALAAECgMIBgAAAA==.',['抗至']='抗至天明:BAAALAAECgIIAgAAAA==.',['推倒']='推倒浅唱:BAAALAAECgYIDwAAAA==.',['提里']='提里奥丨弗丁:BAABLAAECn8UAAIHAAYIkRcUNAB7AQAHAAYIkRcUNAB7AQAAAA==.',['摇摆']='摇摆的奶牛:BAAALAAECgIIAgABLAAFFAIICgAIALIkAA==.',['改錐']='改錐:BAAALAAECgYIBgAAAA==.',['斯巴']='斯巴拉西:BAAALAADCgcIBwAAAA==.',['方大']='方大拿:BAAALAAECggICAAAAA==.',['无尽']='无尽的荣耀:BAABLAAFFH8MAAIbAAIIqwtUVABBAAAbAAIIqwtUVABBAAAAAA==.',['无毒']='无毒有呕:BAABLAAFFH8YAAMXAAYItwOODQAIAQAXAAYItwOODQAIAQAOAAIIExMfFwByAAABLAAFFAgINwASAH0bAA==.',['无限']='无限循环:BAABLAAFFH8cAAICAAYIvw4WMwBJAQACAAYIvw4WMwBJAQABLAAFFAgINwASAH0bAA==.',['明若']='明若轻兮:BAAALAADCggICAAAAA==.',['明里']='明里紬:BAAALAAECgYIBgAAAA==.',['星火']='星火燎原:BAABLAAFFH8nAAMVAAcIERqeAwDvAQAVAAcIERqeAwDvAQAUAAQIkhXZBgBjAQAAAA==.',['晓涵']='晓涵:BAAALAAECgUICgAAAA==.',['晴山']='晴山:BAAALAADCgIIAgAAAA==.',['暖月']='暖月烟火:BAAALAADCggICAAAAA==.',['暖风']='暖风烟火:BAAALAAECgcIEQAAAA==.',['暗黑']='暗黑乐儿:BAAALAAECgYIBwAAAA==.暗黑欣术:BAACLAAFFH8IAAICAAYIdAIqXwBAAAACAAYIdAIqXwBAAAAsAAQKfxQAAw8ABwheFARGAFcBAAIABwj7Ed+KAGkBAA8ABggrEgRGAFcBAAAA.暗黑猎手:BAAALAAECgYIDwAAAA==.暗黑芯术:BAAALAAECgYIDwAAAA==.',['暴躁']='暴躁小黑胖子:BAAALAAECggICAAAAA==.暴躁的小龙人:BAAALAAFFAIIAgAAAA==.',['最后']='最后的倔强:BAAALAAFFAIIBAAAAA==.',['月影']='月影清舞:BAAALAADCgYICQAAAA==.',['月无']='月无名:BAAALAAFFAIIAgAAAA==.',['有关']='有关部门領捣:BAAALAAECgYIBgAAAA==.',['望舒']='望舒:BAAALAAECgQIBAAAAA==.',['未醒']='未醒灬:BAACLAAFFH85AAQaAAYI1CFyAADzAQAaAAYIGSFyAADzAQAbAAYI9SBVEADWAQAZAAMIpx7fHACbAAAsAAQKfz0ABBsACAiyIWEZAPACABsACAgKIWEZAPACABkABwhFHmQZAGQCABoABgiNITAGAHcBAAAA.',['朱敛']='朱敛:BAACLAAFFH89AAMRAAgIZBsbBgDgAQARAAcIyRwbBgDgAQASAAUIFhCUKAAAAQAsAAQKfxoAAhEACAh4F+dOAPUBABEACAh4F+dOAPUBAAAA.',['朴刀']='朴刀爱:BAAALAADCggICgAAAA==.',['杀噫']='杀噫来袭:BAABLAAFFH8OAAILAAIIogi6jgA/AAALAAIIogi6jgA/AAAAAA==.',['杀马']='杀马特团长:BAABLAAFFH8NAAIFAAUICSRJCgALAgAFAAUICSRJCgALAgAAAA==.',['极地']='极地灬血骑士:BAAALAAECgYIDgAAAA==.',['柒小']='柒小小:BAAALAAECgYICgAAAA==.',['梅坎']='梅坎特隆:BAAALAAECgEIAQAAAA==.',['楠丶']='楠丶阿萨斯:BAAALAAFFAYIBAAAAA==.',['槑犇']='槑犇刕刕:BAAALAAECgYIBgAAAA==.',['樱桃']='樱桃小完犊子:BAAALAAECgEIAQAAAA==.樱桃泡泡:BAAALAADCgYIBgAAAA==.',['欣有']='欣有萌虎:BAAALAAECgcIBwAAAA==.',['江如']='江如意:BAAALAADCgIIAgAAAA==.',['江河']='江河湖海:BAAALAAECgIIAgAAAA==.',['沁白']='沁白灬昨天:BAAALAAECgEIAQAAAA==.',['泰蓝']='泰蓝德:BAAALAADCgYIBgAAAA==.',['洛克']='洛克加:BAABLAAECn8XAAIJAAcIwBdJMQD6AQAJAAcIwBdJMQD6AQAAAA==.',['流觞']='流觞逝忆:BAAALAADCgEIAQAAAA==.',['浩瀚']='浩瀚晨月:BAAALAAECgEIAQAAAA==.',['淡定']='淡定中:BAAALAAECgYIDAAAAA==.',['淡淡']='淡淡的红色:BAACLAAFFH8MAAILAAIIOhoKcABTAAALAAIIOhoKcABTAAAsAAQKfxYAAgsACAjsH48MAI0CAAsACAjsH48MAI0CAAAA.淡淡的蓝色:BAAALAAFFAIIAgAAAA==.',['深黑']='深黑色:BAABLAAFFH8IAAIIAAII0Q6qaQBBAAAIAAII0Q6qaQBBAAAAAA==.',['清纯']='清纯小茉莉:BAAALAADCggICAAAAA==.',['湮丶']='湮丶灭:BAAALAAECgMIAwABLAAECgYIBgATAAAAAA==.',['源秀']='源秀一:BAACLAAFFH8rAAILAAYIRCGAEQACAgALAAYIRCGAEQACAgAsAAQKfxoAAwsABgi/IJ6RAN0BAAsABgi/IJ6RAN0BAB0ABAgsEgs8APkAAAAA.',['潴毛']='潴毛归来:BAAALAAECgYIDAAAAA==.潴毛归来死骑:BAAALAAECgMIAwAAAA==.潴毛归来萨:BAAALAADCggICQAAAA==.',['瀤吖']='瀤吖:BAAALAADCgQIBAAAAA==.',['火辉']='火辉:BAAALAADCgMIAwAAAA==.',['灬莫']='灬莫娜灬:BAAALAAECgcIEAAAAA==.',['灬裁']='灬裁云:BAABLAAECn8aAAIWAAYI6Bs7PwBfAQAWAAYI6Bs7PwBfAQAAAA==.',['炼药']='炼药师萧炎:BAAALAAECgYIBgAAAA==.',['烛龍']='烛龍:BAAALAADCgYICQAAAA==.',['煎饼']='煎饼乄初心:BAACLAAFFH8RAAIFAAMImRvyFQDMAAAFAAMImRvyFQDMAAAsAAQKfxwABAUACAiPH70IALkCAAUACAiPH70IALkCAB4ABgjCCZMkAOYAAAkAAgjZF19KAI0AAAAA.',['爆炸']='爆炸射击:BAAALAADCgYICwAAAA==.',['爱小']='爱小小:BAAALAAECgYICAAAAA==.爱小柒:BAAALAAECgMIAwAAAA==.',['爱情']='爱情杀殇:BAAALAADCggICAAAAA==.',['爱无']='爱无处不在:BAAALAAFFAQIBAAAAA==.',['爱柒']='爱柒柒:BAAALAAECgYIDgAAAA==.',['爲妳']='爲妳写詩:BAAALAAECgYIBgAAAA==.',['牛大']='牛大白:BAAALAAFFAIIAgAAAA==.',['牛妞']='牛妞:BAAALAADCgUIBQAAAA==.',['牛灬']='牛灬欢灬喜:BAAALAAECggIEAAAAA==.',['牛牛']='牛牛不怕不怕:BAAALAAECgYIBgAAAA==.',['牧一']='牧一:BAAALAAECgYIDAAAAA==.',['牧之']='牧之殇:BAAALAAECgMIBAAAAA==.',['特别']='特别有理想:BAABLAAFFH8KAAIRAAMIeRbcOgC3AAARAAMIeRbcOgC3AAAAAA==.',['犯二']='犯二小王子:BAAALAAFFAIIAgAAAA==.',['狂牛']='狂牛原地转圈:BAAALAAECgQIBAAAAA==.',['狸的']='狸的之之:BAAALAAECgYIBgAAAA==.',['猎小']='猎小野:BAAALAAECgcIBwAAAA==.',['猪毛']='猪毛:BAAALAADCgIIAgAAAA==.',['玉鳯']='玉鳯:BAAALAADCggIDAAAAA==.',['王筱']='王筱姐姐:BAAALAADCgEIAQAAAA==.',['玖载']='玖载重拾:BAAALAADCgQIBAAAAA==.',['玛格']='玛格汉浩克:BAAALAADCggICAAAAA==.',['玫瑰']='玫瑰火腿:BAAALAAECgYIBwAAAA==.',['珍子']='珍子:BAAALAADCgYIBgAAAA==.',['瓏少']='瓏少爷:BAAALAADCggICQAAAA==.',['瓷器']='瓷器水水:BAAALAAECgYIDgAAAA==.',['用圣']='用圣光打劫你:BAAALAADCgIIAgAAAA==.',['用户']='用户连接中:BAABLAAFFH8KAAIRAAIIkB6VMgCcAAARAAIIkB6VMgCcAAABLAAFFAIICgAIALIkAA==.',['番茄']='番茄炒蛋:BAACLAAFFH8nAAIfAAYIPw/UDAA9AQAfAAYIPw/UDAA9AQAsAAQKfxgAAwsABwi/FZXeAHABAAsABQj8F5XeAHABAB8ABwh8DwUsABwBAAAA.',['痛苦']='痛苦骑士:BAAALAAECgMIAwAAAA==.',['白月']='白月教主丶:BAAALAAECgUIBQAAAA==.',['白毛']='白毛萝莉丶:BAABLAAECn8YAAMaAAgIFxbBAwDfAQAaAAgIFxbBAwDfAQAZAAQIog2EPQCZAAAAAA==.',['皮卡']='皮卡丘儿:BAAALAAECgYIDAAAAA==.',['真冬']='真冬之雪:BAABLAAFFH8RAAILAAUIRxedJgD/AAALAAUIRxedJgD/AAAAAA==.',['真的']='真的栓扣:BAAALAAFFAIIAgAAAA==.',['知白']='知白守黑:BAAALAAFFAIIBAAAAA==.',['石井']='石井御莲:BAAALAADCgcIBwAAAA==.',['破坏']='破坏月神:BAAALAAECgMIAwAAAA==.破坏灵神:BAAALAAECgYIBgAAAA==.破坏猎神:BAAALAAECgQIBAAAAA==.',['硬撑']='硬撑:BAAALAAECgcICQAAAA==.',['神之']='神之忏悔:BAAALAAECggICAAAAA==.',['神仙']='神仙石头:BAABLAAFFH8aAAINAAYIQiLlFwDYAQANAAYIQiLlFwDYAQAAAA==.',['神棍']='神棍德:BAAALAAECgYIEQAAAA==.',['神里']='神里绫华的狗:BAABLAAFFH8FAAINAAUIVBr8RAA1AQANAAUIVBr8RAA1AQAAAA==.',['稚圭']='稚圭:BAACLAAFFH8qAAMgAAcItB+XBABVAgAgAAcItB+XBABVAgAhAAIINRCOGACRAAAsAAQKfyUAAyAACAgPJNgAADkDACAACAgPJNgAADkDACEABgiEGHguAK4BAAAA.',['空訫']='空訫糖果丶:BAACLAAFFH8TAAIIAAYIBhwICwC2AQAIAAYIBhwICwC2AQAsAAQKfyUAAggACAh5JBsVACIDAAgACAh5JBsVACIDAAAA.',['章鱼']='章鱼哥丶:BAAALAAFFAgIAgAAAA==.',['童妈']='童妈妈:BAAALAADCgIIAgAAAA==.',['筱妖']='筱妖儿:BAAALAAECgYIDAAAAA==.',['筱神']='筱神猄:BAAALAAECgIIAgAAAA==.',['米尔']='米尔拉:BAAALAADCggICgAAAA==.',['精灵']='精灵男:BAABLAAFFH8KAAIIAAYIchAvIABnAQAIAAYIchAvIABnAQAAAA==.',['糖门']='糖门长老:BAAALAADCgQIBAAAAA==.',['索提']='索提克:BAAALAAECgYIDgAAAA==.',['紫晶']='紫晶灬:BAAALAADCgQIBAAAAA==.',['紫月']='紫月小德:BAAALAAECgMIAwAAAA==.',['红龍']='红龍:BAAALAADCgIIAwAAAA==.',['终焉']='终焉:BAAALAAECgQIBAAAAA==.',['绿野']='绿野回响:BAACLAAFFH8oAAIOAAcI/x14BQDGAQAOAAcI/x14BQDGAQAsAAQKfy8AAg4ACAglJFgCALECAA4ACAglJFgCALECAAAA.',['绿龍']='绿龍:BAAALAADCggIEAAAAA==.',['羽逸']='羽逸之光:BAAALAAECgIIAgAAAA==.',['老君']='老君的青牛:BAAALAADCggICAAAAA==.',['聆听']='聆听雨声:BAAALAADCgYIBgAAAA==.',['聆夜']='聆夜:BAACLAAFFH8GAAIWAAIIsxrUMgClAAAWAAIIsxrUMgClAAAsAAQKfxkAAhYACAicIJkfAOUCABYACAicIJkfAOUCAAAA.',['聖光']='聖光譕用:BAAALAAECgYIBgAAAA==.',['背水']='背水:BAAALAAECgMIBAAAAA==.',['胤卉']='胤卉:BAABLAAFFH8JAAIWAAUIggM1RAB1AAAWAAUIggM1RAB1AAAAAA==.',['腰要']='腰要灵:BAABLAAFFH8GAAINAAYImRH9OQBZAQANAAYImRH9OQBZAQAAAA==.',['艾因']='艾因:BAACLAAFFH8bAAIZAAUIgySVCwCIAQAZAAUIgySVCwCIAQAsAAQKfxYAAhkABghPJccLABACABkABghPJccLABACAAAA.',['艾维']='艾维克鲁斯:BAAALAAFFAMIAwABLAAFFAcIJwAVABEaAA==.',['芣婹']='芣婹芣嬡莪:BAAALAADCgUIBQAAAA==.',['花开']='花开花落后:BAAALAAECgQIBgAAAA==.花开花落时:BAABLAAFFH8GAAIiAAMIdA3TDQB+AAAiAAMIdA3TDQB+AAAAAA==.',['花气']='花气袭人丶:BAACLAAFFH8sAAQCAAYICiZ3DQAtAgACAAYIpiV3DQAtAgAPAAQIlx6qBwDIAAAQAAIIsRvMAwC5AAAsAAQKfxwAAwIACAj2IjMmAK0CAAIACAhkIjMmAK0CAA8ABgjuHXEbAB8CAAAA.',['花钩']='花钩:BAAALAAFFAIIBAABLAAFFAYICQANAHwOAA==.',['萨其']='萨其马:BAAALAAECgUIBQAAAA==.',['萨总']='萨总:BAABLAAFFH8YAAILAAYI/gwONgBjAQALAAYI/gwONgBjAQAAAA==.',['萨蕾']='萨蕾菲尔:BAAALAADCgIIAgAAAA==.',['萨鲁']='萨鲁法尔:BAAALAAECgYICQAAAA==.',['落丶']='落丶魔:BAAALAAECgYIEgAAAA==.',['落雪']='落雪:BAAALAAECgYIBgAAAA==.落雪无痕:BAAALAAECgUIBQAAAA==.',['葛弗']='葛弗雷:BAABLAAFFH8GAAIbAAYICgqtIwBRAQAbAAYICgqtIwBRAQAAAA==.',['蒂伊']='蒂伊:BAAALAAFFAEIAQAAAA==.',['蒜蓉']='蒜蓉烤扇贝:BAAALAAECgYICAAAAA==.',['蓝色']='蓝色雪:BAAALAADCgIIAgAAAA==.',['蓝龍']='蓝龍:BAAALAADCgIIAwAAAA==.',['蕾姆']='蕾姆蕾姆:BAAALAAECgYICgAAAA==.',['薇薇']='薇薇简:BAABLAAFFH8FAAIIAAII6hR3OwChAAAIAAII6hR3OwChAAAAAA==.',['蛟龍']='蛟龍:BAAALAADCgYIBgAAAA==.',['蟠龍']='蟠龍:BAAALAADCgMIBAAAAA==.',['血凝']='血凝梦魇:BAAALAADCgIIAgAAAA==.',['血染']='血染的征程:BAAALAAECgYICQAAAA==.',['血魂']='血魂之歌:BAAALAADCggICAABLAAECgcICgATAAAAAA==.',['衣以']='衣以候丶:BAABLAAFFH8SAAMEAAYIOAhPHwBQAQAEAAYIOAhPHwBQAQADAAIIyBoaGwCdAAABLAAFFAYIJQACAL4eAA==.',['西出']='西出玉门:BAAALAAECgEIAQAAAA==.',['誓约']='誓约之剑:BAAALAAECgIIAgAAAA==.',['让子']='让子弹飞一会:BAAALAADCgEIAQAAAA==.',['诺拉']='诺拉杰:BAABLAAFFH8GAAILAAYIGhe5KgCNAQALAAYIGhe5KgCNAQAAAA==.',['貓貓']='貓貓魚:BAAALAAECgMIAwAAAA==.',['贝尔']='贝尔蒙多:BAAALAAECggICAAAAA==.',['贰非']='贰非:BAACLAAFFH8rAAIhAAYIaBO9CwBlAQAhAAYIaBO9CwBlAQAsAAQKfzYAAiEACAjBGOINALYBACEACAjBGOINALYBAAAA.',['赞达']='赞达拉骑士:BAAALAAECgEIAQAAAA==.',['超梦']='超梦:BAAALAADCgcIBwAAAA==.',['超电']='超电磁炮美琴:BAAALAAECgYIBgAAAA==.',['超级']='超级晚:BAAALAAECgIIAgAAAA==.',['踏疯']='踏疯:BAABLAAECn8YAAIXAAYICw7GMgARAQAXAAYICw7GMgARAQAAAA==.',['轩辕']='轩辕没文化:BAAALAADCgQIBAAAAA==.',['轻风']='轻风之语:BAAALAAECgYIEgABLAAECgcICgATAAAAAA==.',['辞云']='辞云:BAAALAADCgIIBAAAAA==.',['辣椒']='辣椒炒雪糕:BAAALAAECgQIBAAAAA==.',['这锅']='这锅我的别抢:BAAALAAECgMIAwABLAAFFAIICgAIALIkAA==.',['逐风']='逐风之语:BAAALAAECgcICgAAAA==.',['速度']='速度速度速度:BAACLAAFFH8iAAMdAAcIEh4IAgCaAQALAAcIAhzxFADrAQAdAAQILSEIAgCaAQAsAAQKfy8AAx0ACAhqJS8DADUDAB0ACAhqJS8DADUDAAsABAiUHokTASkBAAAA.',['鄩山']='鄩山杂技猎:BAAALAADCggICAAAAA==.',['采矿']='采矿和锻造:BAAALAAECgQIBwAAAA==.',['锡安']='锡安:BAAALAAECgYIBgAAAA==.',['门小']='门小猩:BAAALAAFFAIIBAAAAA==.',['间歇']='间歇清醒:BAAALAAECgQIBAAAAA==.',['阎魔']='阎魔丨聖光:BAAALAAECggICAAAAA==.',['阿特']='阿特兰特:BAAALAAECgMIAwAAAA==.',['阿萨']='阿萨兹勒:BAAALAAECgEIAQAAAA==.阿萨忽悠着你:BAAALAADCgEIAQAAAA==.',['雙刃']='雙刃:BAAALAADCgQIBAAAAA==.',['雪慕']='雪慕啊:BAAALAAFFAIIAgAAAA==.',['雷索']='雷索:BAACLAAFFH8qAAMPAAcI6RiDAwAVAQACAAcIGxWVGADGAQAPAAQI1B+DAwAVAQAsAAQKfzsAAw8ACAjzI2MHAPMCAA8ACAixImMHAPMCAAIACAgvIYUPAG8CAAAA.',['雷霆']='雷霆咔嚓:BAAALAAECgEIAQAAAA==.',['非月']='非月:BAAALAADCgEIAQAAAA==.',['风之']='风之雀跃:BAAALAAECgQIBAAAAA==.',['风带']='风带走了什么:BAACLAAFFH89AAMjAAYIJApmBAA6AQAjAAYI3ghmBAA6AQABAAUImgnhMADIAAAsAAQKf0wAAwEACAhvGA5GADYCAAEACAg8GA5GADYCACMABgiEE7EHADcBAAAA.',['风清']='风清雲淡:BAAALAAECgQIBgAAAA==.',['风逐']='风逐雲:BAAALAADCgYIBgAAAA==.',['骄杨']='骄杨:BAAALAADCgEIAQAAAA==.',['鬼猫']='鬼猫番茄:BAAALAAECgUIBQAAAA==.',['魔战']='魔战之魂:BAABLAAECn8UAAINAAYIliKwNQDqAQANAAYIliKwNQDqAQAAAA==.',['魔鬼']='魔鬼筋肉人丶:BAAALAAECggIDwAAAA==.',['鳗鱼']='鳗鱼手握:BAAALAADCgYIBgAAAA==.',['鸾鳯']='鸾鳯:BAAALAADCggIEAAAAA==.',['麗璐']='麗璐阿歌特:BAABLAAFFH8GAAIfAAIIFAJLFwBKAAAfAAIIFAJLFwBKAAAAAA==.',['黑铁']='黑铁兽兽:BAAALAADCgEIAQAAAA==.',['黒龍']='黒龍:BAAALAADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end