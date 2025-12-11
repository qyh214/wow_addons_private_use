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
 local lookup = {'Druid-Restoration','Druid-Feral','Druid-Guardian','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Warlock-Destruction','Warrior-Fury','Warrior-Protection','Shaman-Elemental','Mage-Arcane','Paladin-Retribution','Shaman-Restoration','DemonHunter-Havoc','Unknown-Unknown','Mage-Frost','DeathKnight-Unholy','Priest-Shadow','Priest-Holy','Druid-Balance',}; local provider = {region='CN',realm='迦罗娜',name='CN',type='weekly',zone=44,date='2025-12-08',data={Al='Al:BAABLAAECn8bAAIBAAYIEx+tHQDmAQABAAYIEx+tHQDmAQAAAA==.Altria:BAABLAAFFH8KAAIBAAII9xvvIAChAAABAAII9xvvIAChAAAAAA==.Alvitr:BAAALAAECgYIEwAAAA==.',Aq='Aqsef:BAAALAAECgIIAgAAAA==.',Cu='Cuxy:BAAALAAFFAIIAgAAAA==.',Da='Daug:BAABLAAECn8WAAMCAAgIpQ+2JQBgAQACAAgIpQ+2JQBgAQADAAQIfAU2LwCBAAAAAA==.',Ha='Hammerko:BAAALAAFFAIIAgAAAA==.',Ku='Kumo:BAABLAAFFH8GAAIEAAYIhRjWKgCOAQAEAAYIhRjWKgCOAQAAAA==.',Ma='Masfia:BAAALAAFFAIIBAAAAA==.',Qu='Quaswexexort:BAAALAAFFAIIAgAAAA==.',Te='Tendnerss:BAAALAAECgYICgAAAA==.',['一威']='一威震天一:BAAALAAECgYICQAAAA==.',['一片']='一片海苔:BAAALAAFFAIIBAAAAA==.',['一荤']='一荤一素:BAAALAADCggICAAAAA==.',['丁丁']='丁丁咕:BAABLAAFFH8GAAIBAAII5SCdGwC0AAABAAII5SCdGwC0AAAAAA==.丁丁猫:BAAALAAFFAIIBAAAAA==.',['不讲']='不讲武德哟:BAABLAAFFH8IAAQFAAIIWx2TUwCTAAAFAAIIWx2TUwCTAAAGAAEIrx5bBwBZAAAHAAEIZxejNABCAAAAAA==.',['专炒']='专炒土豆:BAAALAAECgcICAAAAA==.',['丨猎']='丨猎丨:BAAALAAECgQIBAAAAA==.',['丶毒']='丶毒少:BAABLAAFFH8TAAIFAAgIdxUwGwDKAQAFAAgIdxUwGwDKAQAAAA==.',['九度']='九度心伤:BAAALAAECgMIAwAAAA==.',['九書']='九書:BAAALAAECggICAAAAA==.',['乱窜']='乱窜的跳跳糖:BAABLAAFFH8YAAIIAAgIbxUZDwAcAgAIAAgIbxUZDwAcAgAAAA==.',['亮剑']='亮剑:BAABLAAFFH8NAAMJAAYISgy5JgA8AQAJAAYISgy5JgA8AQAKAAEI5wANPAANAAAAAA==.',['任我']='任我游:BAAALAAECggICQAAAA==.任我萨:BAABLAAECn8lAAILAAgIkA5nKAB+AQALAAgIkA5nKAB+AQAAAA==.',['伊泽']='伊泽瑞尔:BAAALAAECgQIAwAAAA==.',['倍儿']='倍儿能喷:BAAALAAFFAUIBAABLAAFFAYICQAMAMkiAA==.倍儿能旋:BAAALAAFFAIIAwABLAAFFAYICQAMAMkiAA==.',['八号']='八号风球:BAAALAAECgUIBAAAAA==.',['冠希']='冠希:BAAALAAECgYIBgAAAA==.',['冰凌']='冰凌咿喏:BAAALAAECgYIBgAAAA==.',['加尔']='加尔鲁什酋长:BAACLAAFFH8HAAIJAAMIxQgMPwBrAAAJAAMIxQgMPwBrAAAsAAQKfxQAAgkACAhkEwYpAL0BAAkACAhkEwYpAL0BAAAA.',['加百']='加百利埃箩:BAAALAADCgEIAQAAAA==.',['十二']='十二月四日:BAABLAAFFH8MAAINAAII3BQ/QACeAAANAAII3BQ/QACeAAAAAA==.',['南天']='南天门怀草诗:BAAALAAECgYIBgAAAA==.',['又见']='又见一帘幽梦:BAABLAAFFH8IAAINAAYI9QZGPQChAAANAAYI9QZGPQChAAAAAA==.',['吞萢']='吞萢萢吐圈圈:BAAALAAECggIEQAAAA==.',['含盐']='含盐的鱼:BAAALAADCgIIAgAAAA==.',['咆哮']='咆哮的爷爷:BAAALAAECgIIAgAAAA==.',['哦野']='哦野蛮人:BAABLAAFFH8IAAIBAAIImAkKTgBXAAABAAIImAkKTgBXAAAAAA==.',['四雨']='四雨:BAAALAADCgcICwAAAA==.',['圣光']='圣光的复仇:BAAALAAECgcIBwAAAA==.',['地狱']='地狱咆啸:BAAALAAECgYIBgAAAA==.',['夯夯']='夯夯的劣人:BAAALAAECgUICQAAAA==.',['奔三']='奔三了:BAAALAAECgUIBQAAAA==.',['如霜']='如霜:BAAALAAECgYIBgAAAA==.',['孑琅']='孑琅:BAAALAAECgYICAAAAA==.',['孔明']='孔明小乔:BAAALAADCgIIAgAAAA==.',['学霸']='学霸:BAAALAAECgYIBgAAAA==.',['寳儿']='寳儿姐:BAABLAAECn8WAAIOAAYI4gUBfQCUAAAOAAYI4gUBfQCUAAAAAA==.',['小肥']='小肥羊:BAAALAAFFAIIAwAAAA==.',['少林']='少林十九罗汉:BAAALAADCgIIAgAAAA==.',['尔的']='尔的时代已过:BAAALAAECgMIAwAAAA==.',['居你']='居你夫人:BAAALAADCgYIBgAAAA==.',['席琳']='席琳娜娜:BAAALAAFFAIIAgAAAA==.',['彦潼']='彦潼:BAAALAAECgYICgAAAA==.',['彩旗']='彩旗飘飘:BAABLAAFFH8LAAIPAAYIzQWeMgD+AAAPAAYIzQWeMgD+AAAAAA==.',['德一']='德一德:BAAALAAECggICAAAAA==.',['念未']='念未央:BAAALAAECgMIBAAAAA==.',['怒秀']='怒秀演技:BAAALAAECgUIBQAAAA==.',['恶魔']='恶魔天使:BAAALAAECgYIBgAAAA==.',['您好']='您好要喝奶吗:BAAALAAECgYIBgAAAA==.',['戈壁']='戈壁任:BAAALAAFFAIIAgAAAA==.',['我是']='我是谁我在哪:BAAALAAECgUIBQAAAA==.',['战豆']='战豆豆:BAAALAAFFAIIAwAAAA==.',['手里']='手里剑:BAACLAAFFH8SAAIJAAUI3x0WHgB6AQAJAAUI3x0WHgB6AQAsAAQKfyQAAgkACAjsImQIAMMCAAkACAjsImQIAMMCAAAA.',['抓一']='抓一个死一个:BAAALAAECgYIBgAAAA==.',['抓狂']='抓狂:BAAALAAECgcIDQAAAA==.',['折齿']='折齿的该隐:BAABLAAFFH8LAAINAAIImQjTbwA/AAANAAIImQjTbwA/AAAAAA==.',['拿铁']='拿铁多加糖:BAAALAADCgIIAgAAAA==.',['捏麻']='捏麻麻滴:BAAALAAFFAIIAgABLAAFFAIIBAAQAAAAAA==.捏麻麻滴战:BAAALAAFFAIIBAAAAA==.捏麻麻滴骑士:BAAALAAECgYIBgABLAAFFAIIBAAQAAAAAA==.',['明绣']='明绣:BAAALAAECgYICQAAAA==.',['星之']='星之子:BAAALAAECggICQAAAA==.',['暗中']='暗中观察:BAAALAAFFAgIBAAAAA==.',['暗月']='暗月舞之魂:BAABLAAFFH8GAAIFAAYIHQNycQCBAAAFAAYIHQNycQCBAAAAAA==.',['暮鼓']='暮鼓晨钟:BAAALAAECgYIDQAAAA==.',['暴击']='暴击绿巨人:BAAALAAFFAIIAgAAAA==.',['月夜']='月夜西瓜:BAAALAADCgQIBAAAAA==.月夜西瓦:BAAALAAECgYIBgAAAA==.',['月醉']='月醉:BAABLAAFFH8GAAIRAAIIThh2GQA9AAARAAIIThh2GQA9AAAAAA==.',['有点']='有点硬:BAAALAAECgQIBAAAAA==.',['柠檬']='柠檬有点酸:BAAALAAFFAIIBAAAAA==.',['樱桃']='樱桃小丸子:BAABLAAFFH8MAAMEAAUI6A8zUQDbAAAEAAQIpREzUQDbAAASAAEI9gh9EQBPAAAAAA==.',['正趣']='正趣果上果:BAAALAAFFAIIBAAAAA==.',['死亡']='死亡风暴:BAAALAADCggICAAAAA==.',['死神']='死神無極:BAAALAAECgYIDQAAAA==.',['毛毛']='毛毛球:BAAALAAECggICAAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8mAAMTAAgI4xrlEgBEAQATAAQI0RPlEgBEAQAUAAUIgxrZEgAaAQABLAAFFAgIpAAUAAUkAA==.',['沐川']='沐川流:BAAALAAECgUIBQAAAA==.',['沙沙']='沙沙心:BAACLAAFFH8zAAIFAAYIQiUzCQD2AQAFAAYIQiUzCQD2AQAsAAQKfyEAAgUACAg6JXwHAFkDAAUACAg6JXwHAFkDAAEsAAUUCAhDAAUALSUA.',['海棉']='海棉:BAACLAAFFH8FAAMVAAMIrQPWKgBgAAAVAAMIrQPWKgBgAAABAAIIGQE9YAApAAAsAAQKfxUAAhUACAgKD8wgAGoBABUACAgKD8wgAGoBAAAA.',['無憂']='無憂君:BAAALAAECgYIBgAAAA==.',['爽爸']='爽爸:BAABLAAFFH8GAAILAAIIbhlSPwBMAAALAAIIbhlSPwBMAAAAAA==.',['牧月']='牧月人:BAAALAAECgYIDAAAAA==.',['猫古']='猫古斯:BAAALAAECgEIAQAAAA==.',['玛斯']='玛斯菲雅:BAAALAAFFAIIAwAAAA==.',['琬儿']='琬儿:BAABLAAECn8ZAAIRAAcIOAzhIwAFAQARAAcIOAzhIwAFAQAAAA==.',['电饭']='电饭宝:BAAALAAFFAIIBAAAAA==.',['男人']='男人的玩物:BAAALAADCgEIAQAAAA==.',['疯狂']='疯狂的地瓜:BAAALAADCgYIBwAAAA==.',['祭奠']='祭奠逝去的爱:BAAALAAECgIIAgAAAA==.',['米砂']='米砂:BAACLAAFFH8MAAINAAIIaRM4YgBFAAANAAIIaRM4YgBFAAAsAAQKfxkAAg0ABgjBG6ydALoBAA0ABgjBG6ydALoBAAAA.',['红温']='红温的牛儿:BAAALAAFFAIIAgAAAA==.',['红瞳']='红瞳:BAACLAAFFH8GAAIVAAIItwuuOAA2AAAVAAIItwuuOAA2AAAsAAQKfxUAAhUABgjWFEwnAD0BABUABgjWFEwnAD0BAAAA.',['终点']='终点:BAAALAAFFAIIAwAAAA==.',['给力']='给力的老湿:BAABLAAFFH8OAAIEAAII9hdSZgCVAAAEAAII9hdSZgCVAAAAAA==.',['维维']='维维:BAAALAAECgYIBgAAAA==.',['绿头']='绿头大苍蝇:BAAALAAECgEIAQAAAA==.',['绿心']='绿心:BAAALAAECgUIBQAAAA==.',['胡一']='胡一锤:BAAALAADCgEIAQAAAA==.',['自卫']='自卫队长:BAAALAAECgEIAQAAAA==.',['艳遇']='艳遇:BAABLAAFFH8LAAIFAAYIFxFVQABIAQAFAAYIFxFVQABIAQAAAA==.',['艾格']='艾格雯:BAABLAAECn8UAAIRAAcIiRzoDADwAQARAAcIiRzoDADwAQAAAA==.',['艾蕾']='艾蕾利亚:BAAALAAECgYICAAAAA==.',['苏州']='苏州大铁牛:BAAALAAECgYIBgAAAA==.苏州粗又硬:BAAALAAECgYIBgAAAA==.苏州骷髅头:BAAALAAECgYIDAAAAA==.',['萨你']='萨你的满:BAAALAAECgEIAQAAAA==.',['萨雷']='萨雷:BAAALAAECgYIBgAAAA==.',['萨鲁']='萨鲁法尔大王:BAAALAAECgYIDAAAAA==.',['蓬莱']='蓬莱东路姜泥:BAAALAAECgUIBQAAAA==.',['许愿']='许愿者:BAACLAAFFH8WAAIDAAYIaBfeAgBTAQADAAYIaBfeAgBTAQAsAAQKfxQAAgMACAiLGWkOAPUBAAMACAiLGWkOAPUBAAAA.',['超质']='超质量制动阀:BAAALAAFFAIIAgAAAA==.',['迷途']='迷途知返:BAAALAAECgYICAAAAA==.',['逗猫']='逗猫跳海的鱼:BAAALAAECggICAAAAA==.',['阳春']='阳春白雪:BAAALAAECgYICQAAAA==.',['雁北']='雁北:BAAALAAECgQIBAAAAA==.',['雪域']='雪域风铃:BAABLAAFFH8MAAMBAAII6CWAFwDEAAABAAII6CWAFwDEAAAVAAIIWRtvLABRAAAAAA==.',['颜值']='颜值既是正义:BAAALAAFFAgIAgAAAA==.',['马克']='马克斯:BAAALAAECgYIBgAAAA==.',['魔导']='魔导士:BAAALAAECgMIBgAAAA==.',['麦子']='麦子公举:BAAALAAECgYIBgAAAA==.',['黑岛']='黑岛:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end