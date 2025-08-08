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
 local lookup = {'Paladin-Retribution','Priest-Holy','Priest-Discipline','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Fury','Druid-Guardian','Druid-Balance','Druid-Restoration','Priest-Shadow','Hunter-BeastMastery','Warrior-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Mage-Fire','Mage-Frost','Hunter-Marksmanship','Paladin-Protection','Warrior-Arms','Monk-Mistweaver','Paladin-Holy','Warlock-Demonology','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction',}; local provider = {region='CN',realm='军团要塞',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Armstrong:BAABKgAFFH8JAAIBAAQIQAc6LwCoAAABAAQIQAc6LwCoAAAAAA==.',Di='Diana:BAABKgAECn8iAAMCAAgItRHDMwBxAQACAAgItRHDMwBxAQADAAMIAgLihgBFAAAAAA==.',Em='Emo:BAAAKgAECgcIBwAAAA==.',Ev='Eve:BAAAKgAECgQIBAAAAA==.',Ge='Gelvin:BAAAKgAFFAgIAwAAAA==.',He='Hecate:BAAAKgADCgMIAwABKgAECggIIgACALURAA==.',Kd='Kd:BAABKgAFFH8NAAMEAAYISwqhFwDkAAAEAAYISwqhFwDkAAAFAAMIOAc9TABwAAAAAA==.',My='Myang:BAACKgAFFH8LAAIGAAYIkRu+AADwAQAGAAYIkRu+AADwAQAqAAQKfxYAAgYACAh2HVcbADUCAAYACAh2HVcbADUCAAAA.',Sl='Slora:BAABKgAFFH8UAAIBAAYI6B7IEgDGAQABAAYI6B7IEgDGAQAAAA==.',Te='Tethys:BAAAKgAECggIDAABKgAECggIIgACALURAA==.',Th='Thea:BAAAKgAECgIIAgABKgAECggIIgACALURAA==.Throbbingcat:BAAAKgADCggICAAAAA==.',['Üü']='Üü:BAAAKgAECgIIAgAAAA==.',['一七']='一七一:BAAAKgAECggICQAAAA==.',['一极']='一极品天使一:BAABKgAECn8fAAQHAAgIXRfUBgCjAQAIAAgICBV4PwCqAQAHAAgIxhPUBgCjAQAJAAEIHgTvPAAVAAAAAA==.一极品家丁一:BAABKgAECn8XAAQCAAgIzg8NQAAUAQACAAcIwg4NQAAUAQAKAAQIpxH7JQCgAAADAAEIFxZ4dwA/AAAAAA==.一极品少爷一:BAABKgAECn8bAAILAAgIMx3FCwBXAgALAAgIMx3FCwBXAgAAAA==.一极榀镓钉一:BAABKgAECn82AAMMAAgIahcMCADRAQAMAAgIIBcMCADRAQAGAAgIiw0OMgBkAQAAAA==.',['一样']='一样的阴霾:BAACKgAFFH8GAAIGAAII+BDtGACUAAAGAAII+BDtGACUAAAqAAQKfyEAAgYACAjcGg8LAPUBAAYACAjcGg8LAPUBAAAA.',['一起']='一起来瑟瑟:BAAAKgAECgEIAQAAAA==.',['七喜']='七喜泡泡:BAABKgAFFH8KAAIBAAYIwBmxEQAOAQABAAYIwBmxEQAOAQAAAA==.',['三七']='三七三:BAAAKgAECggIEAAAAA==.',['三两']='三两余生:BAAAKgAECgYIBgAAAA==.',['三岁']='三岁喝茅台:BAAAKgAECgcIBwAAAA==.',['丨尐']='丨尐淸蒓灬:BAAAKgADCgIIAQAAAA==.',['丶静']='丶静默之光:BAABKgAFFH8PAAIIAAgIxBLXBwAiAgAIAAgIxBLXBwAiAgAAAA==.',['丿鬼']='丿鬼舞丶乾坤:BAABKgAECn8ZAAMNAAgIzxfoMgCRAQANAAgIeRXoMgCRAQAOAAIImxYHUACCAAAAAA==.',['九十']='九十九:BAAAKgAECggIEAAAAA==.',['二七']='二七二:BAAAKgAECggIDwAAAA==.',['二二']='二二三:BAAAKgAECggIDgAAAA==.',['二妈']='二妈:BAAAKgADCgYIBwAAAA==.',['五六']='五六五:BAAAKgAECggIEAAAAA==.',['伊墨']='伊墨:BAAAKgAECggICAAAAA==.',['伊洛']='伊洛玛丽:BAAAKgADCgUIBQAAAA==.',['优秀']='优秀老王:BAAAKgAFFAEIAQAAAA==.',['佛尔']='佛尔思:BAAAKgADCgYIBgAAAA==.',['你的']='你的影子:BAABKgAFFH8HAAMPAAYIQxYpEwAkAQAPAAYIQxYpEwAkAQAQAAEI8ASfIgA3AAAAAA==.',['依然']='依然椰子:BAAAKgAFFAQIBAAAAA==.',['倾颜']='倾颜:BAAAKgADCgcIBwAAAA==.',['克林']='克林霉素:BAAAKgAECgUICAAAAA==.',['八九']='八九八:BAAAKgAECgYIBgAAAA==.',['冰火']='冰火世界:BAAAKgAFFAIIAgAAAA==.',['剑弑']='剑弑战魂:BAAAKgADCgYIBgAAAA==.',['包不']='包不同:BAAAKgAECgIIAgAAAA==.',['医用']='医用棉签:BAAAKgAECggIEwAAAA==.',['卖糖']='卖糖术神:BAAAKgADCgIIAgAAAA==.',['卡卡']='卡卡特罗:BAABKgAFFH8LAAMLAAYIFhSqFwA8AQALAAYIFhSqFwA8AQARAAQIawMDGACiAAAAAA==.',['古神']='古神苏铭:BAAAKgADCgYIBgAAAA==.',['可乐']='可乐丶:BAAAKgAFFAIIAgAAAA==.可乐丿:BAABKgAFFH8HAAIBAAMI+RerVQDFAAABAAMI+RerVQDFAAAAAA==.',['哇勒']='哇勒戈萨:BAAAKgAFFAgIBAAAAA==.',['哇卅']='哇卅芈:BAAAKgAFFAQIBAAAAA==.',['哇撒']='哇撒芈:BAAAKgAECggIDQAAAA==.',['哦我']='哦我的积分:BAAAKgAECgcIBwAAAA==.',['啊啊']='啊啊袄袄:BAAAKgAECgEIAQAAAA==.',['喵小']='喵小白:BAAAKgAECgIIAgAAAA==.',['嘁哩']='嘁哩咔嚓:BAAAKgADCgIIAgAAAA==.',['圣光']='圣光雅哈:BAAAKgAFFAgIAgAAAA==.',['圣骑']='圣骑仕:BAAAKgADCgQIBAAAAA==.',['地狱']='地狱寻宝者:BAAAKgAECgIIAgAAAA==.',['坏蛋']='坏蛋小月:BAAAKgAECgEIAQAAAA==.',['坐山']='坐山客:BAACKgAFFH8PAAMNAAMIORpVLADIAAANAAMIORpVLADIAAAOAAIIjQYtFABhAAAqAAQKfyoAAg0ACAhYIXsVAFUCAA0ACAhYIXsVAFUCAAAA.',['墓穴']='墓穴的召唤:BAAAKgADCgYIBgAAAA==.',['夢中']='夢中牆薇:BAAAKgADCgQIBAAAAA==.',['大小']='大小王:BAAAKgADCgEIAQAAAA==.',['大残']='大残还剩一丝:BAABKgAECn8fAAMBAAgIJRu8NwAhAgABAAgIJRu8NwAhAgASAAEI6APVYQAHAAAAAA==.',['大爷']='大爷会骑术:BAAAKgAECgEIAQAAAA==.',['天剑']='天剑非天:BAAAKgAFFAEIAQAAAA==.',['奥丽']='奥丽莎:BAAAKgAECgQIBAAAAA==.',['娜儿']='娜儿可爱吖:BAABKgAFFH8IAAILAAgIRQRADAB7AQALAAgIRQRADAB7AQAAAA==.',['婷姐']='婷姐小年糕:BAABKgAECn8WAAMMAAgI5BAMDABsAQAMAAgI5BAMDABsAQAGAAYIdggtUADNAAAAAA==.婷姐小牛宝:BAABKgAFFH8GAAISAAYIHAX4CwDCAAASAAYIHAX4CwDCAAAAAA==.',['孤星']='孤星独吟:BAAAKgADCgQIBAAAAA==.',['宁欢']='宁欢:BAAAKgAFFAQIBAAAAA==.',['守月']='守月傳說:BAABKgAFFH8SAAITAAQIZhpnFADgAAATAAQIZhpnFADgAAAAAA==.',['小太']='小太子奶:BAAAKgAFFAUIBAAAAA==.',['小布']='小布溜丢儿:BAAAKgAECgEIAQAAAA==.',['小月']='小月歌:BAAAKgAECgEIAQAAAA==.',['小杨']='小杨哥:BAAAKgAECgQIBAAAAA==.',['小柠']='小柠:BAAAKgADCgEIAQAAAA==.',['小牛']='小牛妹:BAAAKgADCgcICAAAAA==.',['小短']='小短腿:BAAAKgADCgEIAQAAAA==.',['小胖']='小胖孩:BAABKgAFFH8GAAIGAAYI5Q4mCgCMAQAGAAYI5Q4mCgCMAQABKgAFFAgIBgAGACMOAA==.',['小蜻']='小蜻蜓:BAAAKgAECgYICAAAAA==.',['小豆']='小豆娘:BAAAKgAECgYIBgAAAA==.',['小鱼']='小鱼哥:BAAAKgADCgYICAAAAA==.',['尔玛']='尔玛郎:BAAAKgAECgIIAgAAAA==.',['希尔']='希尔瓦娜丝:BAACKgAFFH8WAAILAAgIXQawFgBCAQALAAgIXQawFgBCAQAqAAQKfxcAAgsACAj2DW12AFEBAAsACAj2DW12AFEBAAAA.',['庆友']='庆友:BAAAKgADCgUIBQAAAA==.',['引领']='引领传奇:BAAAKgAECgMIAwAAAA==.',['往后']='往后稍一稍:BAAAKgAFFAIIAgAAAA==.',['微胖']='微胖:BAABKgAECn8aAAIUAAgIJRADJwBXAQAUAAgIJRADJwBXAQAAAA==.',['心有']='心有蔷薇:BAAAKgADCggICAAAAA==.',['心灵']='心灵风暴:BAABKgAECn8lAAIBAAgIaxd7HQDSAQABAAgIaxd7HQDSAQAAAA==.',['恶魔']='恶魔行者:BAAAKgAECgEIAQAAAA==.',['惊无']='惊无命:BAAAKgAECgcIDAAAAA==.',['戒骄']='戒骄戒躁丶:BAAAKgAFFAQIBAAAAA==.',['戦灬']='戦灬妞:BAAAKgADCgEIAQAAAA==.',['手起']='手起刀落一葒:BAAAKgAECgYICQAAAA==.',['挖了']='挖了个飒飒:BAAAKgAECggICAAAAA==.',['提昂']='提昂:BAAAKgADCgMIAwAAAA==.',['斯瓦']='斯瓦楼麦康姆:BAABKgAFFH8IAAMBAAQIICMECAA+AQABAAQIICMECAA+AQAVAAQIdRQhDwDJAAABKgAFFAgIFQASANAYAA==.',['昭示']='昭示天下:BAAAKgADCggICAAAAA==.',['智力']='智力加十:BAAAKgADCggICAAAAA==.',['暗夜']='暗夜凛冬:BAAAKgAECggICAAAAA==.',['月城']='月城嘉:BAAAKgADCggICAAAAA==.',['朱轩']='朱轩怀雀:BAAAKgADCgMIAwAAAA==.',['杨先']='杨先声:BAAAKgADCggICAAAAA==.',['枯木']='枯木逢春鸽:BAAAKgAECgQIBAAAAA==.',['格鲁']='格鲁姆什:BAAAKgAFFAQIBAAAAA==.',['楪祈']='楪祈灬:BAAAKgAECgcIBwAAAA==.',['武安']='武安君:BAAAKgADCgMIAwAAAA==.',['死之']='死之白牛:BAABKgAECn8hAAIFAAgI4RaeNwCWAQAFAAgI4RaeNwCWAQAAAA==.',['每天']='每天都要看妞:BAAAKgADCgEIAQAAAA==.',['沾血']='沾血的苦瓜:BAAAKgAECggICQAAAA==.',['法不']='法不留情:BAAAKgAECgQIBAAAAA==.',['法克']='法克游:BAAAKgAFFAQIBAABKgAFFAgIDgAFAIsMAA==.',['泰格']='泰格猎风:BAAAKgADCgEIAQAAAA==.泰格獠齿:BAAAKgADCgQIBAAAAA==.',['流觞']='流觞:BAABKgAFFH8LAAMCAAYIRxEGDgBIAQACAAYIug8GDgBIAQADAAMI1Bd2CgDNAAAAAA==.',['浑水']='浑水:BAAAKgAECgIIAgAAAA==.',['涌夜']='涌夜:BAABKgAFFH8OAAMEAAgIcxxrAgBmAgAEAAgIcxxrAgBmAgAFAAUILAznDgAKAQAAAA==.',['灬哇']='灬哇萨芈灬:BAAAKgAECgIIAgAAAA==.',['灬萱']='灬萱萱灬:BAAAKgADCgMIAwAAAA==.',['灯塔']='灯塔:BAABKgAFFH8GAAMEAAYINRAdJACJAAAFAAQIzw9aOgCzAAAEAAIIzRAdJACJAAAAAA==.',['爆爆']='爆爆:BAAAKgAECgcIDgAAAA==.',['爱我']='爱我在心中:BAAAKgADCgIIAgAAAA==.',['牧有']='牧有办法:BAAAKgAECggICAAAAA==.',['玖玖']='玖玖娃儿:BAAAKgADCgcIBwAAAA==.',['玛格']='玛格汉狠爷们:BAAAKgAECgYIDQAAAA==.',['玩具']='玩具骑士:BAAAKgAECggICwAAAA==.玩具龙:BAAAKgAECgMIAwAAAA==.',['璐璐']='璐璐张:BAACKgAFFH8lAAIJAAYIQyNGBADvAQAJAAYIQyNGBADvAQAqAAQKfyEAAwkACAjdFuEiALMBAAkACAjdFuEiALMBAAgAAQh7DibTADUAAAAA.',['甜哈']='甜哈哈呀:BAAAKgADCgIIAgAAAA==.',['瘾大']='瘾大技术差:BAACKgAFFH8mAAMBAAYIPSaJCQAqAgABAAYIPSaJCQAqAgASAAYI2wn6BgDzAAAqAAQKfyoAAgEACAiRJckHAP0CAAEACAiRJckHAP0CAAEqAAUUCAgTABIADRMA.',['白墨']='白墨浅离:BAABKgAECn8dAAIMAAgI5BLqCgCIAQAMAAgI5BLqCgCIAQAAAA==.',['白骑']='白骑:BAAAKgAFFAMIAwABKgAFFAgIHwAWAEQdAA==.',['皮卡']='皮卡丘呵啊:BAABKgAFFH8JAAIIAAMIkhYeMQDRAAAIAAMIkhYeMQDRAAABKgAFFAgILQAXAEAgAA==.皮卡丘啊哈:BAACKgAFFH8hAAMRAAUIrB5sEABiAQARAAUIrB5sEABiAQALAAEIdwOfSwBAAAAqAAQKfywAAxEACAh9JGoGAL0CABEACAh9JGoGAL0CAAsAAgjqFh+wAGEAAAEqAAUUCAgtABcAQCAA.皮卡丘嘿嘿:BAAAKgADCgQIBAABKgAFFAgILQAXAEAgAA==.皮卡丘欸嘿:BAACKgAFFH8tAAQXAAgIQCBiBABuAgAXAAgI1h9iBABuAgAYAAUIsh7AAABBAQAZAAEI5wOSCwAuAAAqAAQKfxkABBgACAihGh4GAGEBABcACAgGF9IhAKsBABgABAjvIR4GAGEBABkAAQg6BiIhACkAAAAA.',['砂狼']='砂狼白子:BAACKgAFFH8WAAMXAAQIgxErIQC9AAAXAAQIgxErIQC9AAAZAAIISQtSCABzAAAqAAQKfxQAAxcACAgAFRQhAKoBABcACAgAFRQhAKoBABkACAjEBkcbAK0AAAAA.',['离空']='离空岛海:BAAAKgAFFAEIAQABKgAFFAgITwALAA8VAA==.',['秦酿']='秦酿:BAAAKgAECggICwAAAA==.',['精中']='精中之王:BAABKgAFFH8UAAMRAAgILRmCBQAeAgARAAgI0hWCBQAeAgALAAgI/Q/RBwD6AQAAAA==.',['索马']='索马里烈风:BAAAKgAECgEIAQAAAA==.',['紫菜']='紫菜蛋花汤:BAAAKgAECgQIBQAAAA==.',['约法']='约法三章:BAAAKgAFFAQIBAABKgAFFAgIFQARAKkcAA==.',['缠中']='缠中说缠:BAAAKgAECgUICgAAAA==.',['美甘']='美甘妮露:BAAAKgADCgcIBwABKgAFFAQIFgAXAIMRAA==.',['老司']='老司机:BAAAKgAECgcIDwAAAA==.',['老子']='老子是兽:BAAAKgAECggICAAAAA==.',['老王']='老王优秀:BAAAKgAECggICAAAAA==.',['老衲']='老衲瘦了呐:BAAAKgADCggICAAAAA==.',['聖光']='聖光丶舞步:BAAAKgAECggICAAAAA==.',['肯德']='肯德基红豆派:BAAAKgADCggICAAAAA==.',['胡吊']='胡吊车:BAAAKgADCgEIAQAAAA==.',['花花']='花花牛:BAAAKgADCgMIAwAAAA==.',['莱铬']='莱铬拉斯:BAAAKgAECgcICAAAAA==.',['萨科']='萨科麦迪克:BAAAKgADCgIIAgAAAA==.',['蒸馏']='蒸馏水:BAAAKgAECgcICwAAAA==.',['蕾蕊']='蕾蕊儿:BAAAKgAECgEIAQAAAA==.',['藏蓝']='藏蓝天蝎座:BAAAKgADCgEIAQAAAA==.',['蟹蟹']='蟹蟹大福:BAAAKgAECgUIBQAAAA==.蟹蟹蛋挞:BAAAKgAECgQIBAAAAA==.',['西瓜']='西瓜小含片:BAAAKgAECggICAAAAA==.西瓜德:BAAAKgAECggIEAAAAA==.西瓜霜含片:BAABKgAECn8dAAIaAAgI8QzCWQAxAQAaAAgI8QzCWQAxAQAAAA==.',['诶呦']='诶呦喂:BAAAKgADCgQIBAAAAA==.',['豆腐']='豆腐爱了:BAABKgAFFH8KAAINAAMIyRnzKQDPAAANAAMIyRnzKQDPAAAAAA==.豆腐硬了:BAAAKgAECgYIBwAAAA==.豆腐黄了:BAAAKgAFFAEIAQAAAA==.',['贝加']='贝加尔之秋:BAAAKgADCggICAAAAA==.',['费翔']='费翔:BAAAKgADCggIEAAAAA==.',['超猛']='超猛的:BAABKgAFFH8IAAMBAAQIBhCqIQDlAAABAAQIBhCqIQDlAAAVAAIIyhhVEwBPAAABKgAFFAgIGgASADESAA==.',['踮脚']='踮脚大美:BAABKgAECn8WAAIUAAgIzA2TNwDyAAAUAAgIzA2TNwDyAAAAAA==.',['过去']='过去的哀伤:BAAAKgAECgYIDgAAAA==.',['迎风']='迎风吹:BAABKgAECn8XAAILAAgIggYJeQDsAAALAAgIggYJeQDsAAAAAA==.迎风吹雪者:BAAAKgAECggICAAAAA==.迎风建魔:BAABKgAECn8YAAIQAAgItQMVWQCMAAAQAAgItQMVWQCMAAAAAA==.迎风隐:BAABKgAECn8YAAIGAAgImgK6WwCbAAAGAAgImgK6WwCbAAAAAA==.',['近战']='近战法爷:BAAAKgAECgEIAQAAAA==.',['逸尚']='逸尚界玖号:BAABKgAECn8vAAIUAAgIGxHpIgB1AQAUAAgIGxHpIgB1AQAAAA==.',['那个']='那个贼丶:BAAAKgAFFAIIAgAAAA==.',['铐迪']='铐迪克四千加:BAAAKgAECgIIAgAAAA==.',['锕尔']='锕尔萨斯:BAAAKgAECgMIAQAAAA==.',['阿古']='阿古利丶嬷嬷:BAAAKgADCgUIBQAAAA==.',['阿甜']='阿甜的张哈:BAAAKgADCggICAAAAA==.',['陛下']='陛下圣光:BAAAKgADCgEIAQAAAA==.',['雲飛']='雲飛兒:BAAAKgAECgEIAQAAAA==.',['霜之']='霜之哀殇丿:BAAAKgAFFAIIBAAAAA==.',['霜牙']='霜牙龙刃:BAAAKgADCggICAAAAA==.',['青车']='青车:BAABKgAFFH8TAAIbAAgI8hVwCQD1AQAbAAgI8hVwCQD1AQAAAA==.',['青鸟']='青鸟:BAAAKgAECggICAAAAA==.',['靖宜']='靖宜小主:BAAAKgADCgQIBAAAAA==.',['非凡']='非凡牛牛:BAABKgAFFH8IAAIaAAgI8Q11BgDmAQAaAAgI8Q11BgDmAQAAAA==.',['頓頓']='頓頓:BAAAKgAECgcIDAAAAA==.',['风月']='风月之尖:BAAAKgAECggICAABKgAFFAgIBQAPAFMfAA==.风月之巅:BAACKgAFFH8FAAIPAAUIUx/1DABoAQAPAAUIUx/1DABoAQAqAAQKfykAAg8ACAhhE+kEAHwBAA8ACAhhE+kEAHwBAAAA.',['风格']='风格九:BAABKgAECn8YAAMcAAgIDAN6JwC/AAAcAAgIDAN6JwC/AAAbAAgI6QDRpgA7AAAAAA==.',['风逍']='风逍:BAABKgAECn8UAAINAAgI3Q3dHgBTAQANAAgI3Q3dHgBTAQAAAA==.',['风雨']='风雨夜归人:BAAAKgAECgcICwAAAA==.',['飞暴']='飞暴:BAAAKgAFFAgIBAAAAA==.',['骑猪']='骑猪上大树:BAABKgAFFH8FAAIaAAUIrxaUFwDHAAAaAAUIrxaUFwDHAAABKgAFFAgIFAAaAOgiAA==.',['骑着']='骑着摩托遛马:BAAAKgAECggIDwAAAA==.',['黑牛']='黑牛大:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end