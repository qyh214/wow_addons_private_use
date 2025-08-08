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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Priest-Discipline','Warrior-Fury','Warrior-Protection','Warrior-Arms','Evoker-Devastation','Unknown-Unknown','Rogue-Assassination','Druid-Guardian','Druid-Balance','Druid-Restoration','Priest-Holy','Priest-Shadow','Paladin-Retribution','Warlock-Destruction','Monk-Windwalker','Monk-Mistweaver','Paladin-Protection','Paladin-Holy','Warlock-Demonology','Mage-Fire','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','Rogue-Subtlety','Shaman-Restoration','Mage-Arcane','Shaman-Elemental','DeathKnight-Frost',}; local provider = {region='CN',realm='伊莫塔尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ap='Applebaby:BAAAKgADCggICAAAAA==.',Ar='Archmage:BAAAKgAECggIEQAAAA==.',Bo='Boboka:BAABKgAFFH8QAAMBAAYIDRU2EgCIAQABAAYI/BI2EgCIAQACAAYIkgseFgDxAAABKgAFFAgIDgABAEoXAA==.',Ci='Citylights:BAABKgAFFH8KAAIDAAYI0BTCCQB9AQADAAYI0BTCCQB9AQAAAA==.',De='Demons:BAAAKgAECgIIAgAAAA==.',Fl='Floyd:BAAAKgAFFAYIBAAAAA==.',Gx='Gx:BAAAKgAFFAQIBAAAAA==.',Ho='Holyblood:BAAAKgAFFAYIBAAAAA==.Holysmoke:BAABKgAFFH8JAAQEAAcIoxQVEgA4AQAEAAQIXxoVEgA4AQAFAAMINgVhCwBzAAAGAAEINxwSKABQAAAAAA==.',Le='Lemontree:BAAAKgADCgIIAgAAAA==.',Lo='Loong:BAABKgAFFH8UAAIHAAQIuhTAHwDEAAAHAAQIuhTAHwDEAAAAAA==.',Ni='Nice:BAAAKgAECgUIBwAAAA==.',Ol='Oldtory:BAAAKgAECgcIBwAAAA==.',Pe='Pereira:BAAAKgAFFAQIBAABKgAFFAYIBAAIAAAAAA==.',Qm='Qm:BAAAKgAECgYIBgAAAA==.',Se='Sephiroth:BAABKgAECn8VAAIJAAgIoBLQDQBIAQAJAAgIoBLQDQBIAQAAAA==.',Ve='Verus:BAAAKgADCgYIBwAAAA==.',Zo='Zouglas:BAAAKgADCgcIBwAAAA==.',['一个']='一个丁老头:BAAAKgAECgQIBAAAAA==.',['一半']='一半邪恶:BAABKgAECn8bAAQKAAgIcAyoCwAYAQAKAAgIcAyoCwAYAQALAAUI5gUcoACFAAAMAAYIRAM5ZgBZAAAAAA==.',['七宝']='七宝琉璃:BAAAKgADCgMIAwAAAA==.',['三宝']='三宝如意:BAAAKgADCgMIAwAAAA==.',['三年']='三年之期未到:BAAAKgAFFAQIAgAAAA==.',['不吃']='不吃鱼的猫:BAAAKgAFFAgIAgAAAA==.',['不自']='不自量力:BAAAKgAFFAQIBAAAAA==.',['不说']='不说话装高手:BAABKgAFFH8NAAMNAAcIDBWIAwArAQANAAUISxSIAwArAQAOAAIIqiHMIABdAAAAAA==.',['丨吾']='丨吾皇丨:BAABKgAFFH8IAAIPAAIIQht/OgCUAAAPAAIIQht/OgCUAAAAAA==.',['丨欧']='丨欧皇丶附体:BAABKgAFFH8MAAMCAAQI0iXTAwBUAQACAAQI0iXTAwBUAQABAAQI0h0rJgD3AAABKgAFFAgIGgABAEwhAA==.',['丶扬']='丶扬帆远航:BAAAKgAFFAEIAQAAAA==.',['丶苏']='丶苏菲:BAABKgAFFH8GAAIQAAYI2Rv+CAD+AQAQAAYI2Rv+CAD+AQAAAA==.',['丽丽']='丽丽丶:BAABKgAFFH8GAAMRAAQIQQzLDQDNAAARAAQIQQzLDQDNAAASAAIIcwU6MQBNAAAAAA==.',['乔安']='乔安妮惠利:BAAAKgAECgYIDgAAAA==.',['于妳']='于妳姝:BAAAKgAECggICAAAAA==.',['云南']='云南酸菜叔士:BAAAKgAECggICwAAAA==.',['仙人']='仙人跳不跳:BAAAKgAECgQIBgAAAA==.',['伊索']='伊索爾德:BAAAKgADCgYIBgAAAA==.',['伊莎']='伊莎贝拉丶:BAAAKgADCggICAAAAA==.',['伐伽']='伐伽:BAAAKgAECggIAQAAAA==.',['会圣']='会圣光的大虾:BAABKgAFFH8IAAMPAAQIiiR0CAA6AQAPAAQIiiR0CAA6AQATAAQIRwp8DwCKAAAAAA==.',['你猜']='你猜我牛不牛:BAAAKgADCgMIAwAAAA==.',['傲娇']='傲娇的小狮子:BAAAKgAECgQIBgAAAA==.傲娇的小竹子:BAAAKgAECgMIAwAAAA==.',['兔战']='兔战:BAAAKgAECggICAAAAA==.',['兵者']='兵者丶胸器也:BAAAKgADCgYIBgAAAA==.',['凛原']='凛原炎上:BAAAKgAECgEIAQAAAA==.',['凯恩']='凯恩血蹄彡:BAAAKgAECgQIBAAAAA==.',['匿名']='匿名的怪爷爷:BAABKgAFFH8IAAMBAAgI1xJHBQAjAgABAAcI1xJHBQAjAgACAAEIAAD5FQAAAAAAAA==.',['南信']='南信双皮奶:BAABKgAECn8kAAMPAAgIlQ/UnwAOAQAPAAcInhHUnwAOAQAUAAgI2wdUKwAEAQAAAA==.',['双层']='双层灬眼罩:BAAAKgAECgIIAgAAAA==.',['古龙']='古龙桑克斯:BAABKgAECn8VAAIHAAgI0Au5OAANAQAHAAgI0Au5OAANAQAAAA==.',['合欢']='合欢宗道子:BAAAKgAECggIBgAAAA==.',['呆弟']='呆弟:BAAAKgAECgEIAQAAAA==.',['咕德']='咕德猫宁比尔:BAABKgAECn8WAAMLAAgIFQ9fHABvAQALAAgIFQ9fHABvAQAMAAEI+gTwggAbAAAAAA==.',['哞哞']='哞哞哒:BAABKgAFFH8IAAILAAQIByOSDwD9AAALAAQIByOSDwD9AAAAAA==.',['啊呱']='啊呱呱:BAABKgAFFH8JAAMQAAUIGhcYDwDsAAAQAAQIGxoYDwDsAAAVAAEIGA5VFABVAAAAAA==.',['啊怪']='啊怪:BAAAKgAECgYIBgAAAA==.',['啊蕉']='啊蕉:BAAAKgAECggICAAAAA==.',['喜之']='喜之郎:BAABKgAFFH8KAAIWAAYI6RA6DgBaAQAWAAYI6RA6DgBaAQAAAA==.',['嘤嘤']='嘤嘤怪:BAAAKgAECggICAAAAA==.',['土豆']='土豆咖喱鸡:BAAAKgAECgQIBgAAAA==.',['夢醒']='夢醒時分:BAACKgAFFH8QAAIXAAMIOx7yJwDlAAAXAAMIOx7yJwDlAAAqAAQKfx0AAhcACAhzHlMwADMCABcACAhzHlMwADMCAAAA.',['大精']='大精同学:BAABKgAFFH8FAAIGAAUIZhRpDwAbAQAGAAUIZhRpDwAbAQAAAA==.',['天芷']='天芷丶若殇:BAAAKgADCggICAAAAA==.',['天高']='天高任鸟飞:BAABKgAFFH8HAAILAAUI3gvXPgCvAAALAAUI3gvXPgCvAAAAAA==.',['太极']='太极拔剑:BAABKgAFFH8UAAISAAQIuhSRHAC6AAASAAQIuhSRHAC6AAAAAA==.',['奶爸']='奶爸嘿嘿黑:BAAAKgAFFAYIAwAAAA==.',['好想']='好想有人爱:BAABKgAFFH8PAAMCAAYIYxn0CAAHAQACAAQIRh30CAAHAQABAAIIjhMqQQCaAAAAAA==.',['小柒']='小柒柒:BAABKgAFFH8KAAMPAAYIVhvjIABrAQAPAAYIVhvjIABrAQAUAAEIUAcCEwBXAAAAAA==.',['尖牙']='尖牙魔:BAABKgAFFH8GAAIYAAYI9wZCHQAHAQAYAAYI9wZCHQAHAQAAAA==.',['就那']='就那样:BAABKgAECn8WAAIPAAgIOR9vHwCFAgAPAAgIOR9vHwCFAgAAAA==.',['山涧']='山涧水谷底天:BAAAKgADCggICAAAAA==.',['岛田']='岛田半藏:BAAAKgAECggIEwAAAA==.',['巨德']='巨德魔鲁:BAABKgAECn8XAAIMAAgIqhJoJQB4AQAMAAgIqhJoJQB4AQAAAA==.',['幸吾']='幸吾技高一筹:BAABKgAFFH8IAAIZAAgImxdbBgBEAgAZAAgImxdbBgBEAgAAAA==.',['张大']='张大夫的大哥:BAAAKgAFFAQIAwAAAA==.',['微微']='微微丨:BAAAKgADCgIIAgAAAA==.',['心外']='心外無物:BAAAKgADCgYIBgAAAA==.',['心梦']='心梦牧痕:BAAAKgAECgYIDQAAAA==.',['恶魔']='恶魔辩护:BAAAKgAFFAQIBAAAAA==.',['悲剧']='悲剧的背后:BAABKgAFFH8IAAILAAgIlgsFCwDZAQALAAgIlgsFCwDZAQAAAA==.',['情非']='情非德已灬:BAAAKgADCggICAAAAA==.',['我高']='我高大威猛啊:BAAAKgAFFAIIAgAAAA==.',['携秋']='携秋水揽星河:BAAAKgADCgEIAQAAAA==.',['放开']='放开那只怪物:BAAAKgAECggIDwAAAA==.',['故事']='故事与烈酒丶:BAAAKgADCggICAAAAA==.',['旋涡']='旋涡刘能:BAAAKgAECggICAAAAA==.',['无言']='无言湘妃泪:BAAAKgAECgIIBAAAAA==.',['星宿']='星宿劫:BAAAKgADCggICAAAAA==.',['春去']='春去春又回:BAAAKgAECggIEwAAAA==.',['晴天']='晴天丶:BAAAKgAECgQIBAAAAA==.',['晴雨']='晴雨表:BAAAKgADCgcIBwAAAA==.',['暴躁']='暴躁牛:BAAAKgADCgEIAgAAAA==.',['曼珠']='曼珠沙华:BAAAKgAFFAQIBAAAAA==.',['最后']='最后的蓝龙:BAAAKgAECggIEQAAAA==.',['月光']='月光如风:BAAAKgAECgYIBgAAAA==.',['柠檬']='柠檬树下的果:BAABKgAECn8iAAMJAAgIyRuwDgAcAgAJAAgIyRuwDgAcAgAaAAEI2xJxEwA2AAAAAA==.',['树枝']='树枝:BAAAKgADCggICAAAAA==.',['楚铁']='楚铁牛:BAABKgAFFH8IAAIbAAgI5hDDBgC2AQAbAAgI5hDDBgC2AQAAAA==.',['極乄']='極乄阿布:BAABKgAFFH8FAAIOAAUI7QqQEgDsAAAOAAUI7QqQEgDsAAABKgAFFAYIBAAIAAAAAA==.',['榆的']='榆的传说:BAAAKgAECgUIBQAAAA==.',['殘丶']='殘丶葉:BAAAKgADCgEIAQAAAA==.',['水晶']='水晶紫葡萄:BAAAKgAECgYIBgAAAA==.',['沙坪']='沙坪垻的风:BAABKgAFFH8YAAIEAAYIZSLKAADqAQAEAAYIZSLKAADqAQAAAA==.',['没病']='没病没灾:BAAAKgAECgEIAQAAAA==.',['河流']='河流之王:BAAAKgAECgcIBwAAAA==.',['洛神']='洛神之魂:BAAAKgAECgcIBwAAAA==.',['洪荒']='洪荒丶之力:BAAAKgADCgEIAgAAAA==.',['淡淡']='淡淡秋色浓香:BAAAKgAECgIIAgAAAA==.',['滴血']='滴血太阳:BAAAKgADCgcIBwAAAA==.',['灿宝']='灿宝宝丶:BAAAKgADCgcIAQAAAA==.',['炒饭']='炒饭先生:BAAAKgADCggICAAAAA==.',['炮二']='炮二:BAABKgAECn8cAAIYAAgISRl/JgDVAQAYAAgISRl/JgDVAQAAAA==.',['焦糖']='焦糖咖啡:BAAAKgAFFAgIAgAAAA==.',['熊猫']='熊猫二百五:BAAAKgAFFAIIAwAAAA==.熊猫猎:BAAAKgADCggICAAAAA==.',['爱喝']='爱喝雪顶咖啡:BAAAKgADCggICAAAAA==.',['爱意']='爱意成灰:BAAAKgAECgcICAAAAA==.',['牛胸']='牛胸膘:BAABKgAFFH8MAAIQAAYIDBQ/FgBSAQAQAAYIDBQ/FgBSAQABKgAFFAgIAgAcAAIWAA==.',['牧夕']='牧夕暮:BAAAKgAECggICAAAAA==.',['狂得']='狂得很:BAAAKgAECgMIAwAAAA==.',['狠灬']='狠灬牛灬叉:BAAAKgAECgIIAgAAAA==.',['独苗']='独苗:BAAAKgADCggICAAAAA==.',['王祖']='王祖贤:BAAAKgAECgYIBgAAAA==.',['瑟瑟']='瑟瑟发抖:BAAAKgADCgMIBgAAAA==.',['生嚼']='生嚼花岗岩:BAAAKgAECgMIAwAAAA==.',['生椰']='生椰拿铁:BAAAKgAECgIIAgAAAA==.',['疾雷']='疾雷奶旋风:BAABKgAECn8VAAMbAAgIdQ2bWAAhAQAbAAgIdQ2bWAAhAQAdAAEIXBeEbwBGAAAAAA==.',['百兽']='百兽凯多:BAACKgAFFH8HAAMeAAMIUw4DCwDGAAAeAAMIaQ0DCwDGAAABAAMIlAlQFwCsAAAqAAQKfxkAAx4ACAhAHlsGAGoCAB4ACAhAHlsGAGoCAAEACAg+FosnAOUBAAAA.百兽润媞:BAAAKgAECgYIBgAAAA==.',['睚眦']='睚眦必报:BAAAKgAECgMIAwAAAA==.',['神諭']='神諭:BAABKgAFFH8OAAIOAAYI9A5KBQBpAQAOAAYI9A5KBQBpAQAAAA==.',['笑得']='笑得灿烂:BAAAKgAECggIEQAAAA==.',['紫丨']='紫丨沫沫:BAAAKgAECgQIBgAAAA==.',['红朱']='红朱赤姬:BAAAKgAECgIIAgAAAA==.',['罹天']='罹天烬:BAAAKgADCgEIAQAAAA==.',['肉皮']='肉皮冻:BAAAKgADCggICAAAAA==.',['肠炎']='肠炎灵:BAAAKgAECggICgAAAA==.',['苁吥']='苁吥菰單:BAABKgAFFH8KAAIXAAQIOBrdEwD+AAAXAAQIOBrdEwD+AAAAAA==.',['苏格']='苏格兰丶:BAAAKgADCgEIAQAAAA==.',['草原']='草原萝卜头:BAAAKgADCgMIAwAAAA==.',['莉娜']='莉娜茵巴斯:BAABKgAFFH8FAAIcAAQIwA8xFgAyAQAcAAQIwA8xFgAyAQAAAA==.',['莪荇']='莪荇莪束:BAAAKgAECgIIAgAAAA==.',['萧夜']='萧夜狼魂:BAAAKgAECgYICgAAAA==.',['藏愛']='藏愛:BAAAKgAECgIIAwAAAA==.',['虾仁']='虾仁不眨眼:BAAAKgAECgYIBgAAAA==.',['血色']='血色华尓兹:BAAAKgAECgIIAgAAAA==.',['術女']='術女依旧窈窕:BAACKgAFFH8PAAIQAAMIiAoWMgCnAAAQAAMIiAoWMgCnAAAqAAQKfxwAAhAACAihE9omAIUBABAACAihE9omAIUBAAAA.',['装胖']='装胖的国宝:BAAAKgAECgcICAAAAA==.',['西格']='西格玛:BAAAKgADCgUIBQAAAA==.',['西红']='西红柿炒蛋:BAABKgAFFH8iAAISAAQIWhWiGgDIAAASAAQIWhWiGgDIAAAAAA==.',['西门']='西门大官人:BAAAKgAECgcIBwAAAA==.',['谷尔']='谷尔丹:BAAAKgADCgQIBAAAAA==.',['败庭']='败庭神威:BAAAKgAFFAgIBAAAAA==.',['贾鲁']='贾鲁:BAABKgAECn8mAAIEAAgIpxlTHADwAQAEAAgIpxlTHADwAQAAAA==.',['赫尔']='赫尔莫思:BAAAKgAFFAIIAgAAAA==.',['赵樱']='赵樱空:BAAAKgAFFAEIAQAAAA==.',['逆之']='逆之承诺:BAAAKgAECgEIAQAAAA==.',['那只']='那只熊猫:BAAAKgAECgIIAgAAAA==.',['鍀也']='鍀也是炬磨好:BAABKgAFFH8IAAMLAAgIJR92CAAcAgALAAcI/B12CAAcAgAMAAEIjRTXFgBJAAAAAA==.',['鍀拉']='鍀拉诺的兽稔:BAABKgAFFH8FAAMYAAUIbRMJDgDiAAAYAAQIPBcJDgDiAAAXAAEIAgjMWQBFAAABKgAFFAgIBAAIAAAAAA==.',['银月']='银月的伊拉:BAAAKgAECgQIBAAAAA==.',['锦瑟']='锦瑟迷:BAABKgAFFH8NAAMXAAgI8xd/BwAHAgAXAAgI8xd/BwAHAgAYAAIIeR5qIwBUAAAAAA==.',['门根']='门根:BAAAKgAECgEIAQAAAA==.',['阿瑞']='阿瑞斯洋葱头:BAABKgAFFH8OAAIQAAYIyBWbFgBOAQAQAAYIyBWbFgBOAQAAAA==.',['隆里']='隆里电丝:BAAAKgAECgYICgAAAA==.',['隐居']='隐居青楼:BAABKgAFFH8JAAMbAAMIlRPXJACIAAAbAAII6hLXJACIAAAdAAEIew+VJwA+AAAAAA==.',['雪夜']='雪夜乄:BAAAKgADCgQIBAAAAA==.',['霍格']='霍格沃茨肄业:BAAAKgAFFAEIAQAAAA==.',['顏淵']='顏淵:BAAAKgADCggICAAAAA==.',['风中']='风中男子:BAAAKgADCggICAAAAA==.',['风铃']='风铃晚:BAAAKgAFFAQIAQAAAA==.',['騰龍']='騰龍:BAAAKgAFFAIIBAAAAA==.',['魔戒']='魔戒一嘟嘟:BAAAKgAECggICAAAAA==.',['鱼乐']='鱼乐不乐:BAACKgAFFH8fAAQEAAMIIxntGwDlAAAEAAMIIxntGwDlAAAGAAIIIglFEQCBAAAFAAEIWxfbDABCAAAqAAQKfyEABAUACAi4IZQHAGkCAAUACAi1H5QHAGkCAAQABgjbH3gNAMkBAAYAAghmIcQXAMcAAAAA.',['鱼拾']='鱼拾叁:BAAAKgAECggIDwAAAA==.',['鱼柒']='鱼柒:BAAAKgAECgUIBQAAAA==.',['龙莹']='龙莹龙:BAAAKgADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end