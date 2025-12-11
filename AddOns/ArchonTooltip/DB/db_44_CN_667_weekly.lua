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
 local lookup = {'Mage-Frost','Priest-Shadow','Priest-Holy','Hunter-BeastMastery','Hunter-Survival','Warrior-Protection','Shaman-Restoration','Monk-Brewmaster','Monk-Mistweaver','Monk-Windwalker','Shaman-Elemental','DeathKnight-Frost','Rogue-Subtlety','Paladin-Retribution','Paladin-Holy','Warrior-Fury','Hunter-Marksmanship','Warlock-Demonology','Warlock-Destruction','Mage-Arcane','Mage-Fire','Druid-Balance','Druid-Restoration','Rogue-Assassination','DemonHunter-Havoc','DeathKnight-Blood','Druid-Feral','DeathKnight-Unholy','Warlock-Affliction','DemonHunter-Vengeance','Evoker-Augmentation','Evoker-Devastation','Unknown-Unknown','Paladin-Protection',}; local provider = {region='CN',realm='布莱克摩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Aldyalr:BAAALAAECgYIBgAAAA==.Alydia:BAABLAAECn8UAAIBAAgIlxNOEgCjAQABAAgIlxNOEgCjAQAAAA==.',Br='Breezy:BAAALAAECgQIBQAAAA==.',Ca='Castlee:BAAALAAECgQIBQAAAA==.',Da='Darkest:BAAALAAECgYIBgAAAA==.',Dr='Dreamfyre:BAABLAAFFH8GAAMCAAYIIgq5GQDiAAACAAMInBK5GQDiAAADAAMIPhcPKwDOAAAAAA==.',Il='Ilo:BAAALAAECgYIEgAAAA==.',Ka='Kasieyo:BAAALAAECgUIBQAAAA==.',Lo='Loki:BAAALAAECgIIAgAAAA==.',Ma='Madatdisney:BAAALAAECgMIBQAAAA==.',Me='Mercurys:BAAALAAFFAIIAgAAAA==.',Pl='Playerasdfgh:BAAALAAFFAIIAgAAAA==.',Py='Pya:BAAALAAFFAIIAgAAAA==.',Si='Silverwing:BAAALAAECggICAAAAA==.',Sl='Slina:BAAALAAECgQIBAAAAA==.',Su='Sunfyre:BAABLAAFFH8GAAMDAAYIphm6JAAWAQADAAQIhhq6JAAWAQACAAIIIw52HwCMAAAAAA==.',Vi='Victory:BAABLAAECn8aAAMEAAYIWh6OaAAKAgAEAAYIWh6OaAAKAgAFAAYI7BEIEwB7AQAAAA==.',Wa='Warspite:BAAALAAECgIIAgAAAA==.',Wo='Wolfback:BAAALAAECgQIBgAAAA==.',Ze='Zern:BAAALAAECggIDAAAAA==.',['Ðz']='Ðz:BAAALAAECgYIBgAAAA==.',['一九']='一九八五:BAAALAADCgcIBwAAAA==.',['一剑']='一剑:BAAALAAECgQIBAAAAA==.',['一天']='一天一日:BAAALAAECgYICQAAAA==.',['一箭']='一箭射穿:BAAALAAFFAEIAQAAAA==.',['一色']='一色三节高:BAAALAADCgIIAgAAAA==.',['七枷']='七枷社:BAAALAAECgIIAgAAAA==.',['三三']='三三小贼:BAAALAAECgcICQAAAA==.',['三千']='三千越甲吞吴:BAABLAAECn8UAAIGAAYIQxJAJAAmAQAGAAYIQxJAJAAmAQAAAA==.',['三木']='三木:BAAALAADCgMIAwAAAA==.',['三色']='三色双龙会:BAAALAADCgIIAgAAAA==.',['不碎']='不碎之靈:BAABLAAFFH8LAAIHAAQIZhIrGwDdAAAHAAQIZhIrGwDdAAAAAA==.',['不要']='不要打我的脸:BAAALAAECggICQAAAA==.',['丨止']='丨止爱丶:BAAALAAECgUIBQAAAA==.',['中戏']='中戏女生有毒:BAAALAAFFAIIAgAAAA==.',['中烟']='中烟工业:BAAALAAECgYIBgAAAA==.',['丶椛']='丶椛晓霜:BAABLAAFFH8HAAIGAAUIqxFFCABqAQAGAAUIqxFFCABqAQAAAA==.',['丶舞']='丶舞幽炫:BAABLAAECn8aAAQIAAcIRhnhGQDZAQAIAAcIRhnhGQDZAQAJAAcIbglBMwANAQAKAAEIaBW2ZwBBAAAAAA==.丶舞钢管:BAAALAAFFAMIAwABLAAFFAgIGwALAHAXAA==.',['丹伦']='丹伦之秋:BAAALAADCgcIBwAAAA==.',['乌瑟']='乌瑟尔:BAAALAAECggICAAAAA==.',['乱成']='乱成一片:BAAALAAFFAEIAQAAAA==.',['二月']='二月:BAAALAAECgUIBQAAAA==.',['二西']='二西莫夫:BAAALAAECgIIAQAAAA==.',['云云']='云云:BAABLAAFFH8MAAIEAAYISxGHTAAbAQAEAAYISxGHTAAbAQAAAA==.',['云兄']='云兄:BAAALAAFFAIIAgAAAA==.',['人间']='人间血契:BAAALAAFFAIIAgAAAA==.',['什么']='什么都好:BAAALAAFFAEIAQAAAA==.什么都插:BAABLAAFFH8PAAIHAAUIJA4dLAAHAQAHAAUIJA4dLAAHAQAAAA==.什么都水:BAAALAAFFAMIBAAAAA==.',['仁后']='仁后:BAAALAAFFAMIAwAAAA==.',['从小']='从小就凶:BAAALAAFFAIIAgAAAA==.从小就浪:BAABLAAFFH8MAAIMAAYIow67IQAYAQAMAAYIow67IQAYAQAAAA==.',['任飘']='任飘渺:BAABLAAFFH8FAAINAAMI5AZzEABsAAANAAMI5AZzEABsAAAAAA==.',['伤心']='伤心难过痛苦:BAAALAADCgYICgAAAA==.',['体胖']='体胖心宽:BAABLAAFFH8PAAIOAAQI1RxrMQD4AAAOAAQI1RxrMQD4AAAAAA==.',['佛怜']='佛怜众生苦:BAABLAAFFH8LAAIEAAUI8Qp+VAD8AAAEAAUI8Qp+VAD8AAAAAA==.',['傲成']='傲成一片:BAABLAAECn8VAAMOAAYITQuungDCAAAOAAUIrgeungDCAAAPAAYICgSSMgCyAAAAAA==.',['傻孩']='傻孩子璐璐:BAAALAAFFAMIAwAAAA==.',['光头']='光头真加暴击:BAABLAAFFH8HAAIQAAYIAQ2gIQBgAQAQAAYIAQ2gIQBgAQAAAA==.',['克剌']='克剌斯:BAABLAAFFH8GAAIOAAII1g7saABCAAAOAAII1g7saABCAAAAAA==.',['兔妖']='兔妖妖:BAAALAAFFAIIAgAAAA==.',['八重']='八重神子:BAAALAAECgIIAgAAAA==.',['养猫']='养猫的蜗牛:BAAALAADCgMIBAAAAA==.',['兽面']='兽面人心:BAABLAAECn8cAAMEAAYI8RsaZAB6AQAEAAYI8RsaZAB6AQARAAQIeAvHjwCoAAAAAA==.',['再动']='再动灬开枪了:BAABLAAFFH8IAAIOAAIIswf2XACBAAAOAAIIswf2XACBAAAAAA==.',['冰美']='冰美式加糖:BAACLAAFFH8PAAMSAAUI6xlVEABMAAATAAMIzRz8QADpAAASAAIImBVVEABMAAAsAAQKfxkAAxMACAi2Gtc+AD4CABMACAiFGNc+AD4CABIABgh8Ejw9AHcBAAEsAAUUCAgIABMAORkA.',['凯莉']='凯莉泰瑞尔:BAABLAAFFH8IAAIUAAIItQ+UVACMAAAUAAIItQ+UVACMAAAAAA==.',['凶成']='凶成一片:BAAALAAFFAIIAgAAAA==.',['初倩']='初倩:BAAALAAFFAIIAgAAAA==.',['初冬']='初冬的光:BAAALAADCgMIAwAAAA==.',['刮骨']='刮骨刀:BAAALAAECggICAAAAA==.',['剑二']='剑二十三:BAAALAADCgEIAQAAAA==.',['剑蝶']='剑蝶:BAAALAAECgYIBgAAAA==.',['午夜']='午夜伴侣:BAACLAAFFH8GAAIUAAII6QMXZwAzAAAUAAII6QMXZwAzAAAsAAQKfxQAAwEABgikEOtPADMBABQABgi1DnaaAFUBAAEABghCDOtPADMBAAAA.',['半仙']='半仙:BAABLAAFFH8kAAIHAAUIZRlxFgAAAQAHAAUIZRlxFgAAAQAAAA==.',['南星']='南星:BAABLAAFFH8IAAITAAgIxBSMEAAMAgATAAgIxBSMEAAMAgAAAA==.',['卡九']='卡九万:BAAALAAECgYICQAAAA==.',['卡拉']='卡拉赞之夜:BAAALAADCgYIBwAAAA==.卡拉达丽娜:BAAALAAECgYIDAAAAA==.',['卡西']='卡西莫多:BAAALAAECgYIDwABLAAFFAIIBgAOAD4QAA==.',['卧槽']='卧槽:BAABLAAFFH8KAAITAAgIuxLgEQD+AQATAAgIuxLgEQD+AQAAAA==.',['卷珠']='卷珠帘:BAAALAADCgYIBgAAAA==.',['卿之']='卿之恋歌:BAAALAAECgYICQAAAA==.',['去事']='去事宛如梦幻:BAABLAAFFH8GAAIOAAIIPhAFXwBHAAAOAAIIPhAFXwBHAAAAAA==.',['叁年']='叁年练习生:BAAALAAECgYIBgAAAA==.',['双暗']='双暗刻:BAAALAADCgYIBgAAAA==.',['双月']='双月骑士:BAABLAAECn8ZAAIOAAYIXx8BXwAtAgAOAAYIXx8BXwAtAgAAAA==.',['古尓']='古尓単:BAAALAADCgIIAgAAAA==.',['可乐']='可乐加冰:BAAALAAECggIDQAAAA==.',['吉人']='吉人自有天相:BAAALAAECgQIBAAAAA==.',['名字']='名字太短:BAABLAAECn8aAAQVAAgIERXOBQCAAQAVAAYI5BnOBQCAAQAUAAcI3w+mmgBUAQABAAQIYhJSNACcAAABLAAFFAgIEQATAJYaAA==.',['吴二']='吴二蛋:BAABLAAFFH8JAAITAAMISxzGNwCiAAATAAMISxzGNwCiAAABLAAFFAYIGgAMACUfAA==.',['呆萌']='呆萌不特别:BAABLAAFFH8GAAIMAAII2BGPggCFAAAMAAII2BGPggCFAAAAAA==.',['命丶']='命丶:BAABLAAFFH8GAAIMAAYIDhdZCQAYAgAMAAYIDhdZCQAYAgABLAAFFAgIMwAMAFkjAA==.',['咖啡']='咖啡嘤:BAABLAAFFH8WAAIDAAUIGh5EEQAvAQADAAUIGh5EEQAvAQAAAA==.',['喧嚣']='喧嚣尘世间:BAAALAAECgYICAAAAA==.',['喵大']='喵大大人:BAACLAAFFH85AAIDAAgItx3KAQBoAgADAAgItx3KAQBoAgAsAAQKfygAAgMACAj7HO4gAHMCAAMACAj7HO4gAHMCAAAA.',['喵楽']='喵楽嗰咪:BAABLAAFFH8GAAMWAAYI3hUeFwAiAQAWAAUIkhQeFwAiAQAXAAEIAiNjRABnAAAAAA==.',['嘭嘭']='嘭嘭西:BAACLAAFFH8IAAIEAAIIpBqaTACYAAAEAAIIpBqaTACYAAAsAAQKfxYAAwQABghUIcVgABoCAAQABgjNIMVgABoCABEABggjFHpVAGIBAAAA.',['嘻哈']='嘻哈啲偽娤:BAABLAAFFH8KAAIYAAMIMgYdFwB4AAAYAAMIMgYdFwB4AAAAAA==.',['嘿叽']='嘿叽歪啲强盜:BAAALAAFFAMIBAABLAAFFAQIDQAWABIKAA==.',['噬魂']='噬魂灵:BAAALAAECgUIBQAAAA==.',['国产']='国产鞭妇侠:BAABLAAFFH8HAAIZAAMIDxhKOwCeAAAZAAMIDxhKOwCeAAAAAA==.',['土成']='土成一片:BAAALAAECgYIBwAAAA==.',['圣光']='圣光邓邓:BAABLAAFFH8GAAIOAAII3xm2WwBIAAAOAAII3xm2WwBIAAAAAA==.',['圣曦']='圣曦之辉:BAAALAAECgMIAgAAAA==.',['圣殿']='圣殿裁决者:BAAALAAECgEIAQAAAA==.',['地狱']='地狱血契:BAABLAAFFH8JAAMSAAIIMg0uHgB6AAASAAIIMg0uHgB6AAATAAII8wPFbgAwAAAAAA==.',['增幅']='增幅器:BAAALAAECgYIBgAAAA==.',['夜幕']='夜幕舞者:BAAALAAECgYICgAAAA==.',['夜色']='夜色撩人:BAAALAAFFAEIAQABLAAFFAIIBgAOAD4QAA==.',['夜雨']='夜雨小梦:BAABLAAFFH8hAAIZAAgIyyRQAQD+AgAZAAgIyyRQAQD+AgAAAA==.',['大白']='大白兔奶糖:BAAALAAECgEIAQAAAA==.',['大胡']='大胡子老头:BAAALAAECgYIDQAAAA==.',['大蛇']='大蛇:BAAALAAECgMIAwAAAA==.',['大鸭']='大鸭梨:BAAALAAECgMIAwAAAA==.',['天命']='天命人:BAACLAAFFH85AAIIAAgIDw2BBwCBAQAIAAgIDw2BBwCBAQAsAAQKfygAAggACAgzGCcVABQCAAgACAgzGCcVABQCAAAA.',['天堂']='天堂血契:BAAALAAFFAIIBAAAAA==.',['天涯']='天涯客:BAAALAAECggICAAAAA==.',['威加']='威加海内:BAAALAAFFAIIBAABLAAFFAIIBgAOAD4QAA==.',['威猛']='威猛浩浩:BAAALAAFFAIIAgAAAA==.',['宁雅']='宁雅:BAAALAAECgQIBQAAAA==.',['宇宙']='宇宙大将军:BAAALAAECgcIEQAAAA==.',['守四']='守四方:BAABLAAFFH8FAAIaAAIIfhaNGQA7AAAaAAIIfhaNGQA7AAAAAA==.',['安妮']='安妮女王大人:BAABLAAFFH8IAAMSAAII7wCFGgAbAAATAAII2wAQcwAgAAASAAII4QCFGgAbAAAAAA==.',['定仙']='定仙游:BAACLAAFFH8cAAMEAAYIEiMrGADXAQAEAAYIEiMrGADXAQARAAIIRBxPEwBNAAAsAAQKfx8AAwQACAjUI4IWAAQDAAQACAjUI4IWAAQDABEABQhdHqcXAOMAAAEsAAUUCAghABkAyyQA.',['宝贝']='宝贝灬叫大叔:BAAALAAECgEIAQAAAA==.',['寂寞']='寂寞之逐风:BAAALAADCgEIAQAAAA==.',['寒风']='寒风无泪:BAABLAAECn8VAAMEAAYI2hUQ0QBpAQAEAAYIYhQQ0QBpAQARAAUIrQ/TdQD7AAAAAA==.',['寻斧']='寻斧:BAAALAAECgEIAQAAAA==.',['小丶']='小丶竺竺:BAABLAAFFH8IAAMUAAYI7hrvGAC6AQAUAAYI7hrvGAC6AQABAAIInQTjIAAnAAAAAA==.',['小土']='小土夜行:BAABLAAECn8XAAIHAAgI3B9SFwA3AgAHAAgI3B9SFwA3AgAAAA==.',['小榄']='小榄苟王:BAAALAAFFAMIAwAAAA==.',['小牛']='小牛夜行:BAAALAAECgIIAgAAAA==.',['小狗']='小狗夜行:BAABLAAECn8VAAIbAAgIcAsAIQCLAQAbAAgIcAsAIQCLAQAAAA==.',['小肥']='小肥肥一号:BAAALAAECgIIAgAAAA==.',['小舵']='小舵:BAAALAAECgYICgAAAA==.',['小舷']='小舷:BAAALAADCgMIAwAAAA==.',['小舸']='小舸:BAAALAAECgEIAQAAAA==.',['小船']='小船:BAABLAAFFH8NAAIDAAIIQhaFNwCEAAADAAIIQhaFNwCEAAAAAA==.',['小艅']='小艅:BAAALAAECgYIDAAAAA==.',['小艨']='小艨:BAAALAAECgUIBgAAAA==.',['小芳']='小芳足浴:BAAALAADCgQIBAAAAA==.',['小菜']='小菜一碟:BAABLAAFFH8IAAIOAAIIdRhpQwCcAAAOAAIIdRhpQwCcAAAAAA==.',['小锋']='小锋:BAAALAAECgUICQAAAA==.',['小鬼']='小鬼夜巡:BAACLAAFFH8KAAIEAAIIjiADSACcAAAEAAIIjiADSACcAAAsAAQKfx4AAgQACAgoIz8fAN0CAAQACAgoIz8fAN0CAAAA.小鬼夜游:BAACLAAFFH8OAAIcAAIIKR8QEgCRAAAcAAIIKR8QEgCRAAAsAAQKfxgAAhwACAiqHrQHANwCABwACAiqHrQHANwCAAAA.小鬼夜行:BAACLAAFFH8FAAISAAII8w38FgCWAAASAAII8w38FgCWAAAsAAQKfywAAxIACAi1IoUFABMDABIACAi1IoUFABMDABMABAjaEse5AAEBAAAA.小鬼夜袭:BAACLAAFFH8MAAIZAAIIZB/ISABUAAAZAAIIZB/ISABUAAAsAAQKfx4AAhkACAh/H+EhANoCABkACAh/H+EhANoCAAAA.',['尛菜']='尛菜一碟:BAABLAAFFH8HAAIEAAIIgBi7XgCMAAAEAAIIgBi7XgCMAAAAAA==.',['就爱']='就爱吃香菜:BAABLAAECn8jAAQTAAcIGRipLwCPAQATAAcIGRipLwCPAQASAAIINhZ/egCQAAAdAAEI9AInRgApAAAAAA==.',['尼古']='尼古拉斯丶晋:BAAALAAECgQIBAAAAA==.',['履剑']='履剑千江水:BAAALAAECgYICgAAAA==.',['巨石']='巨石强森:BAABLAAFFH8VAAIQAAUIORZJJQBFAQAQAAUIORZJJQBFAQAAAA==.',['帕里']='帕里斯汀:BAABLAAECn8VAAMDAAgIVSDKDwDqAgADAAgIVSDKDwDqAgACAAQIsBqeNAC4AAAAAA==.',['幺幺']='幺幺:BAAALAAECgYIBgAAAA==.',['幻云']='幻云采风:BAAALAAFFAIIBAAAAA==.',['幽客']='幽客:BAAALAAECgUIBQAAAA==.',['建材']='建材王哥:BAAALAAECgcIDQAAAA==.',['弥生']='弥生三月:BAAALAAECgUIDAAAAA==.',['归丨']='归丨尘:BAAALAAFFAIIAgAAAA==.',['影光']='影光月蝕:BAAALAAFFAIIAgAAAA==.',['影月']='影月之殇:BAAALAAFFAIIBAAAAA==.',['御前']='御前一品猫:BAABLAAFFH8IAAQbAAIIPwzgDwCKAAAbAAIINAfgDwCKAAAXAAIIqhKWQgBrAAAWAAIIPww7NgA5AAAAAA==.',['微水']='微水之凝:BAAALAAFFAIIAgAAAA==.',['微风']='微风艾儿:BAAALAAFFAEIAQAAAA==.',['怒火']='怒火邪风:BAAALAAECgcIBwAAAA==.',['怡宝']='怡宝宝:BAAALAAECgcIBwAAAA==.',['怪物']='怪物来他先上:BAAALAAFFAIIBAAAAA==.',['想不']='想不起来了:BAAALAAECgYIBgAAAA==.',['想睡']='想睡王六堡:BAAALAADCgYICgAAAA==.',['愤怒']='愤怒的大叔:BAAALAAECgYICwAAAA==.',['懿頔']='懿頔两相依:BAAALAAECgYIBgAAAA==.',['我头']='我头上五个旋:BAAALAAECgQIBAAAAA==.',['我将']='我将带头装逼:BAAALAADCggICgAAAA==.',['我要']='我要暴走:BAAALAAECgQIBAAAAA==.',['战暴']='战暴狂:BAAALAAECgUICQAAAA==.',['打灰']='打灰姬:BAAALAAECgYIBgAAAA==.',['折戟']='折戟之殇:BAAALAAFFAIIAgAAAA==.',['拉风']='拉风老爷车:BAABLAAFFH8HAAIEAAMIxxJ4cACAAAAEAAMIxxJ4cACAAAAAAA==.',['挽澜']='挽澜:BAAALAAECgYIDAABLAAFFAIICAAZAGUUAA==.',['撑死']='撑死胆大的:BAABLAAFFH8GAAIXAAIIiAxLOQBmAAAXAAIIiAxLOQBmAAAAAA==.',['斑竹']='斑竹心语:BAABLAAFFH8UAAIXAAUIfiPcCgADAgAXAAUIfiPcCgADAgAAAA==.',['斩钢']='斩钢之刃:BAAALAAECgYICAAAAA==.',['断尾']='断尾熊:BAABLAAFFH8HAAMaAAcIZApTBQCiAQAaAAYIBgtTBQCiAQAMAAEImgb5fABHAAAAAA==.',['断幺']='断幺九:BAAALAAECgQIBAAAAA==.',['无心']='无心易武:BAAALAAECggICwAAAA==.',['无敌']='无敌小波波:BAAALAADCgcIBwAAAA==.',['星丶']='星丶垣:BAABLAAFFH8KAAIBAAIIThzfEgBMAAABAAIIThzfEgBMAAAAAA==.星丶湮:BAABLAAFFH8MAAIDAAMIlRumKQDeAAADAAMIlRumKQDeAAAAAA==.星丶熠:BAABLAAFFH8IAAIOAAII6h/DVQBMAAAOAAII6h/DVQBMAAAAAA==.星丶痕:BAABLAAFFH8LAAIXAAUI/hSNGQBhAQAXAAUI/hSNGQBhAQAAAA==.星丶陨:BAABLAAFFH8QAAIEAAYIGw8gPABTAQAEAAYIGw8gPABTAQAAAA==.',['晓丶']='晓丶枫叶:BAAALAADCgYIBgAAAA==.',['普通']='普通和尚:BAABLAAECn8YAAIKAAgI0hkJCAAuAgAKAAgI0hkJCAAuAgAAAA==.',['暖月']='暖月:BAAALAAECgYICgAAAA==.',['暗影']='暗影天驰:BAABLAAECn8YAAIZAAYIdSCUYQAGAgAZAAYIdSCUYQAGAgAAAA==.',['月之']='月之守卫:BAAALAAECgYIAQAAAA==.月之殇:BAAALAAECgEIAQAAAA==.月之殤:BAABLAAFFH8FAAIOAAMIZhj+QgCLAAAOAAMIZhj+QgCLAAAAAA==.',['有天']='有天:BAAALAADCgIIAgAAAA==.',['末日']='末日审判者:BAAALAAECgYIDQAAAA==.',['机械']='机械黑龙妹:BAAALAAECgYIDAAAAA==.',['林明']='林明菁:BAAALAAFFAIIAgAAAA==.',['枯藤']='枯藤老树昏鸦:BAABLAAFFH8GAAIMAAYI7Bg3CQAZAgAMAAYI7Bg3CQAZAgAAAA==.',['柠檬']='柠檬灬晨曦:BAAALAAECgYICQAAAA==.',['梦三']='梦三国曰貂蝉:BAAALAADCgYICQAAAA==.',['欲為']='欲為诸佛龍象:BAACLAAFFH8gAAMMAAYIaRzkJwCWAQAMAAYIaRzkJwCWAQAcAAIIpQb7EQCRAAAsAAQKfyQAAwwABwhEIWszAKcCAAwABwhEIWszAKcCABwABQgNHSwSAAsBAAAA.',['欲爲']='欲爲诸佛龍象:BAABLAAFFH8OAAIOAAUIaxDELAAfAQAOAAUIaxDELAAfAQAAAA==.',['死亡']='死亡猎灵人:BAAALAAFFAIIAgAAAA==.',['残月']='残月星痕:BAABLAAFFH8TAAMLAAYImgPULQDJAAALAAYImgPULQDJAAAHAAII6BunRQCVAAAAAA==.',['毁天']='毁天灭地:BAAALAAECgUIBQAAAA==.',['水中']='水中月镜中花:BAAALAAECgMIAwAAAA==.',['水色']='水色玫瑰:BAAALAAECgQIBAAAAA==.',['求生']='求生之路:BAACLAAFFH8SAAIZAAUIvhVvKgBAAQAZAAUIvhVvKgBAAQAsAAQKfxsAAhkACAh+HzAPAGsCABkACAh+HzAPAGsCAAAA.',['江上']='江上明月:BAAALAADCgcIBwAAAA==.',['沫灬']='沫灬筱兮丨宇:BAAALAAFFAQIBAAAAA==.',['油炸']='油炸丸子:BAAALAADCgIIAgAAAA==.',['治愈']='治愈血契:BAAALAADCgYIBgAAAA==.',['治疗']='治疗不精:BAAALAADCgMIAwAAAA==.',['注意']='注意看我细节:BAABLAAECn8yAAIEAAgI4yLjGAD5AgAEAAgI4yLjGAD5AgAAAA==.',['洛依']='洛依:BAABLAAFFH8UAAITAAgInRj4DQAnAgATAAgInRj4DQAnAgAAAA==.',['活在']='活在梦里:BAAALAAECgYIBgAAAA==.',['浅笑']='浅笑:BAAALAAFFAIIAgAAAA==.',['浮殇']='浮殇年华:BAABLAAFFH8KAAIMAAIITxWRfgBGAAAMAAIITxWRfgBGAAAAAA==.',['海拉']='海拉:BAAALAAECgcICAAAAA==.',['淑女']='淑女丶:BAAALAAECgQIBwAAAA==.',['混沌']='混沌灭世:BAAALAAFFAIIAgAAAA==.',['清爽']='清爽一夏:BAAALAAECgYIDAAAAA==.',['清风']='清风无痕:BAAALAADCgYIBgAAAA==.清风明月:BAAALAADCgYIBgAAAA==.',['满一']='满一萨:BAAALAAECgYIDwAAAA==.',['激动']='激动地射:BAAALAAFFAIIBAAAAA==.',['灵之']='灵之影:BAAALAAECgYIBgAAAA==.',['烈烈']='烈烈西风摧人:BAAALAAFFAIIBAAAAA==.',['無聊']='無聊的寶寶:BAAALAAECgYIBgAAAA==.',['無関']='無関風月:BAAALAAECggIBgAAAA==.',['熵能']='熵能之祸:BAAALAAECgYIDAAAAA==.',['爆炒']='爆炒小龙虾:BAAALAAECgYIBgAAAA==.',['爱摸']='爱摸鱼的余墨:BAACLAAFFH8GAAIHAAIIVBhaSQCLAAAHAAIIVBhaSQCLAAAsAAQKfxYAAwcABwg5EK9WAAMBAAcABwg5EK9WAAMBAAsAAghMCd98AC4AAAEsAAUUBggfABkAlhEA.',['爱新']='爱新觉罗彩霞:BAAALAADCgIIAgAAAA==.',['爱的']='爱的一切:BAAALAAFFAMIAwAAAA==.',['爱莉']='爱莉希雅:BAAALAAFFAIIBAAAAA==.',['片翼']='片翼天使:BAAALAADCgQIBAAAAA==.',['牧野']='牧野留飞:BAAALAADCgIIAgAAAA==.',['狂风']='狂风之末:BAABLAAECn8YAAIEAAgI9xInoQCqAQAEAAgI9xInoQCqAQAAAA==.',['狡猾']='狡猾的张圆圆:BAAALAADCgYIBgAAAA==.',['狼牙']='狼牙峰峰拳:BAAALAADCgEIAQAAAA==.',['献身']='献身于神:BAACLAAFFH8pAAIQAAgIPxt1BgBgAgAQAAgIPxt1BgBgAgAsAAQKfyUAAhAACAi6HyEgAMsCABAACAi6HyEgAMsCAAAA.',['玫思']='玫思果:BAABLAAFFH8LAAIeAAIIZA+uEQBsAAAeAAIIZA+uEQBsAAAAAA==.',['玲珑']='玲珑:BAABLAAFFH8IAAMfAAUI7w94CQDmAAAfAAMINQ94CQDmAAAgAAIIBhG7HABGAAAAAA==.',['瑞奇']='瑞奇:BAAALAADCgIIAgAAAA==.',['电一']='电一下:BAAALAAFFAIIBAAAAA==.',['男胖']='男胖子:BAAALAADCgQIBAAAAA==.',['皮圣']='皮圣:BAABLAAFFH8dAAMGAAYIiCBrBwDPAQAGAAYIiCBrBwDPAQAQAAIIAAFRWQA9AAABLAAFFAgIJwAUAA8jAA==.',['破冰']='破冰:BAAALAADCgEIAQAAAA==.',['神圣']='神圣大风车:BAACLAAFFH8KAAIOAAIImyQEMQCqAAAOAAIImyQEMQCqAAAsAAQKfxUAAg4ABgi0IpskAAQCAA4ABgi0IpskAAQCAAAA.',['神蛊']='神蛊温皇:BAAALAAECgUICAAAAA==.',['福禄']='福禄喜悦:BAAALAAECgMIAwAAAA==.福禄寿禧财:BAAALAADCgYIBgAAAA==.',['简素']='简素言:BAAALAAECggIDwAAAA==.',['简迷']='简迷离:BAAALAAECggICAAAAA==.',['米勒']='米勒:BAABLAAFFH8UAAIUAAgIMyO9AQDlAgAUAAgIMyO9AQDlAgAAAA==.',['米德']='米德德:BAAALAAECgYICwAAAA==.',['粉马']='粉马尾蝙蝠猫:BAACLAAFFH8GAAIZAAIIfxT4OwCcAAAZAAIIfxT4OwCcAAAsAAQKfxYAAhkABgjTIsJAAGACABkABgjTIsJAAGACAAAA.',['素手']='素手芳華:BAACLAAFFH8qAAMEAAgIuBpRCQBMAgAEAAgIuBpRCQBMAgARAAUIXQ5UCgBbAQAsAAQKfyYAAxEACAgUH4MiAFYCABEACAiBHIMiAFYCAAQABgi2G4ymAKIBAAAA.',['紫燕']='紫燕:BAAALAADCggIDAAAAA==.',['終極']='終極光頭王:BAAALAAECgYIEAAAAA==.',['红成']='红成一片:BAAALAAECgUIBQAAAA==.',['红玉']='红玉:BAABLAAFFH8UAAIZAAgIgR3XBACWAgAZAAgIgR3XBACWAgAAAA==.',['群殴']='群殴小朋友:BAABLAAECn8YAAIBAAYIAiGWHAA2AgABAAYIAiGWHAA2AgAAAA==.',['翱翔']='翱翔孤浪:BAAALAAECgYIBgAAAA==.',['职业']='职业输出:BAAALAAFFAUIAgAAAA==.',['肥仔']='肥仔的远征:BAAALAAECggIDAAAAA==.',['舞是']='舞是零:BAAALAAECggIEAAAAA==.',['艾丽']='艾丽卡:BAACLAAFFH8FAAIDAAIIkw2GPgBtAAADAAIIkw2GPgBtAAAsAAQKfxQAAgMACAgRFPoaAOUBAAMACAgRFPoaAOUBAAAA.',['艾亚']='艾亚哥斯:BAABLAAFFH8FAAIZAAMILAwaPgCVAAAZAAMILAwaPgCVAAAAAA==.',['艾尔']='艾尔文宠物店:BAAALAADCgcIBwAAAA==.',['芝麻']='芝麻龙:BAAALAAFFAIIAgAAAA==.',['花钱']='花钱月下:BAAALAAECgEIAQAAAA==.',['苍吉']='苍吉安:BAAALAAECgQIBAAAAA==.',['苍狼']='苍狼与白鹿:BAAALAAFFAIIBAABLAAFFAIIBgAOAD4QAA==.',['苏陌']='苏陌:BAAALAAECgYIBgAAAA==.',['英俊']='英俊潇洒:BAAALAAECgQIBAAAAA==.',['茉酱']='茉酱紫:BAABLAAFFH8IAAIOAAIIFiVITgBdAAAOAAIIFiVITgBdAAAAAA==.',['茶白']='茶白丶莓莓:BAAALAAFFAIIAgAAAA==.',['莎总']='莎总:BAACLAAFFH8JAAIKAAII9hoUDgCiAAAKAAII9hoUDgCiAAAsAAQKfxYAAgoABwiYHNAYAEUCAAoABwiYHNAYAEUCAAEsAAUUBggSAA4AwB4A.',['莫丶']='莫丶甘丶娜:BAAALAAECgYIBgAAAA==.',['菩萨']='菩萨蛮:BAAALAAECgEIAQAAAA==.',['萨摩']='萨摩开英勇:BAABLAAECn8WAAIHAAYIchLenwA/AQAHAAYIchLenwA/AQAAAA==.',['萨维']='萨维:BAACLAAFFH8GAAIOAAYIViIZCAAJAgAOAAYIViIZCAAJAgAsAAQKfxoAAg4ACAjIIPURAH4CAA4ACAjIIPURAH4CAAAA.',['落叶']='落叶白:BAAALAAECgUIBgAAAA==.',['蓝卡']='蓝卡:BAAALAAECgYIDAAAAA==.',['藏剑']='藏剑:BAAALAAECgUIBQAAAA==.',['虈羋']='虈羋:BAAALAAECgYICQAAAA==.',['虚空']='虚空之牙:BAAALAAECgYIEQAAAA==.',['蛟龙']='蛟龙在天:BAAALAADCgIIAgAAAA==.',['蜗牛']='蜗牛爱养猫:BAAALAAECgEIAQAAAA==.',['血契']='血契大领主:BAAALAAFFAIIAgAAAA==.',['血狐']='血狐血影:BAAALAADCgEIAQAAAA==.',['西包']='西包:BAABLAAFFH8GAAIZAAYIQxDSIwBsAQAZAAYIQxDSIwBsAQAAAA==.',['西江']='西江月:BAAALAAECgYIBwAAAA==.',['西瓜']='西瓜勒个太狼:BAAALAAECgQIBgAAAA==.',['诗瑛']='诗瑛红:BAAALAAECgQIBAAAAA==.',['诸神']='诸神无念:BAAALAAECggICAAAAA==.',['调皮']='调皮大姨妈:BAAALAAECggIDQAAAA==.',['豪鬼']='豪鬼:BAAALAADCgMIAwAAAA==.',['豬豬']='豬豬點點:BAABLAAFFH8GAAIPAAIIHQuAIACHAAAPAAIIHQuAIACHAAAAAA==.',['贼贼']='贼贼:BAAALAAECgYIEAAAAA==.',['赛利']='赛利卡:BAACLAAFFH8yAAIBAAcIZyUbAACYAgABAAcIZyUbAACYAgAsAAQKfyMAAgEACAjgJtsAAIgDAAEACAjgJtsAAIgDAAAA.',['赤沙']='赤沙之蝎:BAAALAAFFAIIAgAAAA==.',['赫卡']='赫卡忒:BAAALAAECgMIAwAAAA==.',['超级']='超级乳娃娃:BAAALAAECgIIAgAAAA==.',['趔葚']='趔葚:BAABLAAFFH8XAAIEAAUIvhc4SQAnAQAEAAUIvhc4SQAnAQAAAA==.',['踏雪']='踏雪寻煤:BAAALAAFFAIIAgAAAA==.',['蹄子']='蹄子嘿嘿:BAAALAAECgYIBgAAAA==.',['身自']='身自在:BAAALAAECgMIAwAAAA==.',['辣条']='辣条小妹:BAAALAAFFAEIAQAAAA==.',['边城']='边城导游:BAAALAAECgQIBQAAAA==.边城游侠:BAAALAADCggICgAAAA==.',['过敏']='过敏世界:BAABLAAFFH8GAAIPAAYIlAAhJQB5AAAPAAYIlAAhJQB5AAABLAAFFAgIAgAhAAAAAA==.',['迫在']='迫在眉睫:BAAALAADCgMIAwAAAA==.',['遮眼']='遮眼司机:BAABLAAFFH8JAAIZAAIIrhEqPwCaAAAZAAIIrhEqPwCaAAAAAA==.',['那一']='那一剑的痛:BAAALAADCgYICQAAAA==.',['那德']='那德:BAAALAADCgYIDAAAAA==.',['酸菜']='酸菜鱼:BAAALAAECgYIBgAAAA==.',['采蘑']='采蘑菇的小熊:BAACLAAFFH8GAAIKAAIIWQ8IFACGAAAKAAIIWQ8IFACGAAAsAAQKfyYAAwoACAgvGBccACUCAAoACAgvGBccACUCAAkAAQhnC15VAC0AAAAA.',['钻石']='钻石裂痕:BAAALAADCgcIBwAAAA==.',['银河']='银河幻:BAABLAAFFH8IAAMcAAMIChfRCwC2AAAcAAII9RXRCwC2AAAMAAII3xK/iwBAAAAAAA==.银河野性:BAAALAAFFAIIAgAAAA==.',['阿奈']='阿奈耶识:BAACLAAFFH8MAAIUAAMIqAyFLADfAAAUAAMIqAyFLADfAAAsAAQKfyIAAhQACAhbGPQ/AEsCABQACAhbGPQ/AEsCAAAA.',['阿尔']='阿尔芒斯:BAAALAAECgQIBAAAAA==.',['阿德']='阿德尔阿萨斯:BAAALAADCgYIBwAAAA==.',['阿斯']='阿斯达尔凯迪:BAAALAADCgMIAwAAAA==.',['陌丶']='陌丶冷:BAAALAAFFAQIBAAAAA==.',['随便']='随便摸摸:BAAALAAFFAEIAQAAAA==.',['难忘']='难忘那片海:BAAALAADCgQIAgAAAA==.',['雨中']='雨中等雨停:BAAALAAECgMIAwAAAA==.',['雨天']='雨天:BAAALAAECgYIBgAAAA==.',['雨文']='雨文宝儿:BAAALAAECgUIBQAAAA==.',['雲水']='雲水謠丶:BAAALAAFFAIIAgAAAA==.',['雷吉']='雷吉:BAACLAAFFH8FAAIWAAUIKhN+GQALAQAWAAUIKhN+GQALAQAsAAQKfxcAAhYACAisIA8LAEkCABYACAisIA8LAEkCAAAA.',['雷姬']='雷姬:BAAALAAFFAMIBAAAAA==.',['雾流']='雾流:BAAALAAECgYIDQAAAA==.',['霜之']='霜之高兴:BAACLAAFFH8nAAIMAAYIShU0LACIAQAMAAYIShU0LACIAQAsAAQKfykAAgwACAg8GABKAGYCAAwACAg8GABKAGYCAAAA.',['霸霸']='霸霸:BAAALAAECgYICgABLAAECggIHQAiAFUeAA==.',['静小']='静小静:BAACLAAFFH8RAAMSAAIIsRcWFgCYAAASAAIIehAWFgCYAAATAAIIthLqVwBJAAAsAAQKfxQAAxIACAgBGxQnANsBABIABgiFHRQnANsBABMABgh2FB1/AIIBAAAA.',['非同']='非同小可:BAACLAAFFH8QAAIDAAMIeQoCMwCdAAADAAMIeQoCMwCdAAAsAAQKfzUAAgMACAg9GmgYAP4BAAMACAg9GmgYAP4BAAEsAAUUBgggAAcAqRoA.',['面具']='面具啲救赎:BAABLAAECn8XAAIUAAcIygfYVQCrAAAUAAcIygfYVQCrAAAAAA==.',['風丶']='風丶:BAAALAAECgMIAwAAAA==.',['风清']='风清揚:BAAALAAECggICgAAAA==.风清月明:BAAALAADCgMIAwAAAA==.',['风过']='风过云端:BAAALAAECgcIDgAAAA==.',['飛起']='飛起壹脚尖:BAACLAAFFH8NAAIWAAQIEgoDLQBLAAAWAAQIEgoDLQBLAAAsAAQKfxgAAhYABwhZChBjADIBABYABwhZChBjADIBAAAA.',['駑鳯']='駑鳯:BAAALAAFFAIIAgAAAA==.',['魔幻']='魔幻丨星辰:BAAALAAECgUIBQAAAA==.魔幻星辰:BAAALAAECgMIAwAAAA==.',['魔爪']='魔爪爪:BAAALAAECgUIBgAAAA==.',['魔纹']='魔纹:BAABLAAFFH8IAAISAAIIyRGCGwCJAAASAAIIyRGCGwCJAAAAAA==.',['黎明']='黎明的勇气:BAAALAAECgcIEwAAAA==.',['黑叔']='黑叔叔:BAAALAAECgYICQAAAA==.',['黑柠']='黑柠茶:BAABLAAFFH8GAAIZAAYINBoZFwCwAQAZAAYINBoZFwCwAQAAAA==.',['龙国']='龙国战神:BAAALAAECggICAAAAA==.',['龙帅']='龙帅:BAABLAAFFH8ZAAIZAAYIxxtNFgC0AQAZAAYIxxtNFgC0AQAAAA==.',['龙渊']='龙渊:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end