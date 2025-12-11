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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Priest-Holy','Mage-Frost','Mage-Arcane','DemonHunter-Havoc','Warlock-Destruction','Paladin-Retribution','Hunter-BeastMastery','Paladin-Holy','Unknown-Unknown','DemonHunter-Vengeance','Druid-Balance','Druid-Restoration','Shaman-Restoration','Priest-Shadow','Priest-Discipline','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','Shaman-Elemental','Paladin-Protection','Warrior-Fury','Hunter-Marksmanship','Mage-Fire',}; local provider = {region='CN',realm='伊兰尼库斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Andrei:BAAALAADCgIIBAAAAA==.',Au='Auroray:BAACLAAFFH8IAAIBAAMIyQwOMwDQAAABAAMIyQwOMwDQAAAsAAQKfyAAAwEACAg5HQ45AJQCAAEACAg5HQ45AJQCAAIACAh/ChclAJUBAAAA.',Bl='Bliztwing:BAAALAADCgIIBAAAAA==.',De='Devilrcma:BAAALAAECgMIBgAAAA==.',Dr='Dreaman:BAAALAAECgYIBgAAAA==.',Et='Ethericess:BAABLAAFFH8oAAIDAAYIOyEYCABHAgADAAYIOyEYCABHAgAAAA==.',Ka='Kahlan:BAAALAAECgUIBQAAAA==.',Ku='Kumo:BAABLAAFFH8LAAIBAAgIsR/nBACxAgABAAgIsR/nBACxAgAAAA==.',Li='Lilacerullo:BAABLAAECn8gAAIEAAgIHB6yCQAjAgAEAAgIHB6yCQAjAgAAAA==.Lilo:BAAALAADCgYIBgAAAA==.',Ni='Nicanm:BAAALAADCggICAAAAA==.Niree:BAABLAAFFH8OAAIFAAYILxHZKwBgAQAFAAYILxHZKwBgAQABLAAFFAYIEAAGAF8SAA==.',Pl='Playerkiqnos:BAAALAAFFAIIBAAAAA==.',Rt='Rtjjrt:BAABLAAFFH8SAAIHAAUI2BePNgA2AQAHAAUI2BePNgA2AQAAAA==.',Va='Valkyrier:BAAALAAFFAIIBAAAAA==.',Wa='Wardeath:BAAALAADCgIIAgAAAA==.',['一蹦']='一蹦丶老高了:BAAALAADCgQIBAAAAA==.',['不要']='不要让哥迷恋:BAAALAAECgYIBwAAAA==.',['世界']='世界尽头:BAABLAAFFH8HAAIIAAIIaQq4ewA1AAAIAAIIaQq4ewA1AAAAAA==.',['丨义']='丨义父丨:BAACLAAFFH8MAAIJAAIIOxUlWwCPAAAJAAIIOxUlWwCPAAAsAAQKfx8AAgkABgiwH2ebALMBAAkABgiwH2ebALMBAAAA.',['丨曹']='丨曹贼丨:BAABLAAFFH8IAAIBAAIIHBcdfQBHAAABAAIIHBcdfQBHAAAAAA==.',['丨糖']='丨糖门丨:BAAALAAECgMIAwAAAA==.',['丨花']='丨花花丨:BAABLAAECn8ZAAMIAAYIWB9CMQDOAQAIAAYIWB9CMQDOAQAKAAQIpQwyMQC8AAAAAA==.',['丶江']='丶江南烟语:BAAALAADCgIIAgAAAA==.丶江南烟雨:BAAALAAFFAIIBAAAAA==.',['丶玛']='丶玛卡巴卡:BAAALAAECgYICQAAAA==.',['乔雯']='乔雯影刃:BAAALAAFFAIIAgAAAA==.乔雯晨风:BAAALAAECgYIBgABLAAFFAIIAgALAAAAAA==.乔雯潮汐:BAAALAAECggICAAAAA==.',['二手']='二手徳:BAAALAAECgYIDwAAAA==.',['亚索']='亚索:BAAALAAECgMIAwAAAA==.',['亦影']='亦影:BAAALAADCgcIBwAAAA==.',['伟大']='伟大红:BAAALAAFFAIIAwAAAA==.',['你的']='你的强:BAAALAADCggICAAAAA==.',['保安']='保安:BAAALAAFFAIIAgAAAA==.',['冰糕']='冰糕块块:BAAALAAECgYIDwAAAA==.',['冷冷']='冷冷:BAAALAAECggICAAAAA==.',['凌封']='凌封:BAAALAAECgYICwAAAA==.',['凸凸']='凸凸凹:BAAALAAECgYIEAAAAA==.',['加鲁']='加鲁鲁灬:BAAALAAECgMIAwAAAA==.',['南方']='南方小土豆:BAAALAAECgQIBAAAAA==.',['发型']='发型决定命运:BAAALAADCgcIBwAAAA==.',['只为']='只为娇娇:BAAALAADCggIBgAAAA==.',['叶琳']='叶琳:BAABLAAFFH8QAAMGAAYIXxIaLQAvAQAGAAUIIhQaLQAvAQAMAAEIkQnNEwAyAAAAAA==.',['哆啦']='哆啦默默:BAABLAAECn8iAAIDAAgIYwnjZgBHAQADAAgIYwnjZgBHAQAAAA==.',['哈斯']='哈斯乌拉:BAAALAAECgYIBwAAAA==.',['嗜血']='嗜血土豆泥:BAAALAAECgYIBgAAAA==.',['嗷乄']='嗷乄:BAABLAAECn8XAAIBAAYI0B0jPgCHAQABAAYI0B0jPgCHAQAAAA==.',['噩灵']='噩灵游荡:BAABLAAFFH8GAAINAAIIGgZHOQA0AAANAAIIGgZHOQA0AAABLAAFFAgICQAOAGoCAA==.噩灵继续游荡:BAAALAAFFAIIBAAAAA==.噩灵风刹:BAABLAAFFH8HAAIPAAIIhwoBWQBlAAAPAAIIhwoBWQBlAAAAAA==.',['圣职']='圣职玛利亚:BAACLAAFFH8yAAMQAAYIzwyPFgATAQAQAAUISw2PFgATAQADAAUIYBeZFgDyAAAsAAQKfzAABAMACAiKFvUqADsCAAMACAiKFvUqADsCABAABwjvEPZMAIMBABEAAgjtBs84AEcAAAAA.',['在下']='在下王林丶:BAABLAAFFH8GAAIBAAYIxhvNIgCpAQABAAYIxhvNIgCpAQAAAA==.',['在部']='在部落打酱油:BAABLAAFFH8FAAIBAAII5w9lcACQAAABAAII5w9lcACQAAAAAA==.',['壹叶']='壹叶知秋:BAAALAAECgYIEQAAAA==.',['夏特']='夏特兒:BAAALAADCgQIBAAAAA==.',['多吃']='多吃水果:BAAALAADCggICAAAAA==.',['夜浊']='夜浊:BAAALAADCgYIBgAAAA==.',['大块']='大块头大智慧:BAAALAAECgEIAQAAAA==.',['天不']='天不高:BAABLAAECn8WAAIJAAYIrxM4hgA+AQAJAAYIrxM4hgA+AQAAAA==.',['天妒']='天妒灬风流:BAAALAAECgYICAAAAA==.',['太极']='太极八荒:BAAALAAFFAIIAgAAAA==.',['奇亜']='奇亜:BAAALAAFFAIIAgAAAA==.',['奇亞']='奇亞:BAAALAAECgEIAQAAAA==.',['奇圠']='奇圠:BAAALAAECgEIAQAAAA==.',['奶油']='奶油包:BAAALAAECgYICwAAAA==.',['奶茶']='奶茶刂呼吸:BAAALAAECgYIDgAAAA==.',['妙脆']='妙脆角:BAAALAAECgYICQAAAA==.',['姚太']='姚太郎:BAAALAAECgQIBAAAAA==.',['姜小']='姜小丫:BAAALAAECgIIAgAAAA==.',['宁波']='宁波劳改:BAAALAAECgYIBgAAAA==.',['宇宙']='宇宙浪子:BAAALAAECggICAAAAA==.',['实战']='实战实在:BAAALAAECgUIBQAAAA==.',['寒酥']='寒酥:BAAALAADCgcIBwAAAA==.',['小滑']='小滑头:BAAALAAECgYICQAAAA==.',['小短']='小短腿:BAAALAAECgYIDQAAAA==.',['小骑']='小骑士:BAAALAAFFAIIAgAAAA==.',['巍峨']='巍峨如山:BAAALAAFFAIIAwAAAA==.',['巫喵']='巫喵王:BAABLAAFFH8IAAMBAAIIVgoseACMAAABAAIIVgoseACMAAASAAEISgM2GQAvAAAAAA==.',['年华']='年华:BAAALAADCgMIAwAAAA==.',['年少']='年少时的喜欢:BAAALAAECgMIAwAAAA==.',['幻象']='幻象:BAAALAAECgIIAgAAAA==.',['幽默']='幽默小刀:BAACLAAFFH85AAMTAAYISB9OBQDXAQATAAYISB9OBQDXAQAUAAMImhPGCwDbAAAsAAQKfy8AAxMACAiSGr0UAHQCABMACAiSGr0UAHQCABQABQgsErQwABoBAAAA.',['弔戼']='弔戼:BAAALAADCgYIBgAAAA==.',['弥弥']='弥弥丶:BAAALAAECgYIEgAAAA==.',['德意']='德意的笑:BAAALAAECgQIBAAAAA==.',['惊鸿']='惊鸿:BAAALAAECgYIBwAAAA==.',['懦夫']='懦夫救星:BAAALAAFFAIIAgAAAA==.',['我爱']='我爱喝酸奶:BAABLAAFFH8GAAIJAAYI/AAxxAAPAAAJAAYI/AAxxAAPAAAAAA==.',['报废']='报废车头:BAAALAAECgQIBAAAAA==.',['断牙']='断牙:BAAALAAECgYICAAAAA==.',['斯蒂']='斯蒂芬亨得利:BAABLAAECn8iAAIVAAgIgh7WDgBFAgAVAAgIgh7WDgBFAgAAAA==.',['春水']='春水蜉蝣:BAAALAAECgYICAAAAA==.',['春风']='春风十里:BAAALAAECgEIAQAAAA==.',['曉薇']='曉薇:BAAALAAFFAIIAgAAAA==.',['最爱']='最爱浮潜丶:BAABLAAFFH8OAAIBAAgI8h6aCgBQAgABAAgI8h6aCgBQAgAAAA==.',['月夕']='月夕花晨:BAAALAADCgQIBAAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8VAAMOAAgIShkqCAApAgAOAAcI9xgqCAApAgANAAEIPh6TKgBfAAAAAA==.',['本人']='本人飘过:BAABLAAFFH8GAAIJAAYIphG4OQBaAQAJAAYIphG4OQBaAQAAAA==.',['来者']='来者何人:BAAALAAECgYIBwAAAA==.',['极限']='极限了:BAACLAAFFH82AAMIAAYIByQuBwAWAgAIAAYIByQuBwAWAgAWAAMIkQqADACyAAAsAAQKfy0ABAgACAgoIOIrAMICAAgACAgoIOIrAMICABYACAi7D0wuAJwBAAoABAi5A/t3AEMAAAAA.',['柒夕']='柒夕:BAAALAADCgYIBgAAAA==.',['檐前']='檐前露已团:BAABLAAFFH8GAAIJAAIIHArtuwAtAAAJAAIIHArtuwAtAAAAAA==.',['欣凝']='欣凝:BAAALAAECgEIAQAAAA==.',['沐小']='沐小菜:BAAALAAECgYIEwAAAA==.',['沙隆']='沙隆巴斯:BAAALAADCgIIAgAAAA==.',['泼該']='泼該亡:BAABLAAFFH8HAAIJAAQIcBCXbQCHAAAJAAQIcBCXbQCHAAABLAAFFAYINgAIAAckAA==.',['浪味']='浪味仙:BAAALAADCgYIBgAAAA==.',['淡忘']='淡忘凡尘:BAAALAAECgYIBgAAAA==.',['淡笑']='淡笑凡尘:BAAALAAECgYIDwAAAA==.',['混沌']='混沌灬哈迪斯:BAABLAAFFH8OAAIJAAIIrxA7ZgCHAAAJAAIIrxA7ZgCHAAAAAA==.混沌灬奎托斯:BAABLAAFFH8OAAIHAAIIChMqRACSAAAHAAIIChMqRACSAAAAAA==.混沌灬怒风:BAABLAAFFH8KAAIGAAIIihMnTABNAAAGAAIIihMnTABNAAAAAA==.',['混血']='混血王子:BAAALAAECggICAAAAA==.',['滥竽']='滥竽充术:BAAALAAECgYIDwAAAA==.',['灵魂']='灵魂凯特:BAAALAAECgYIBgAAAA==.',['烧酒']='烧酒和尺八:BAAALAAECgIIAgAAAA==.',['牛不']='牛不牛德:BAAALAADCgEIAQAAAA==.',['猪有']='猪有劲:BAABLAAFFH8GAAIXAAQIpgs5OgCKAAAXAAQIpgs5OgCKAAABLAAFFAYINgAIAAckAA==.',['猫猫']='猫猫:BAAALAAFFAIIBAAAAA==.',['白日']='白日夢想家:BAABLAAFFH8FAAICAAMITBQrCADqAAACAAMITBQrCADqAAAAAA==.',['白色']='白色小美人:BAACLAAFFH8eAAIOAAYIzB0OCwABAgAOAAYIzB0OCwABAgAsAAQKfxQAAw4ACAhyFsM/AOABAA4ACAhyFsM/AOABAA0AAQj6BxCuADAAAAAA.',['皮卡']='皮卡丘丘:BAABLAAFFH8GAAIYAAYIyRqhAwAEAgAYAAYIyRqhAwAEAgAAAA==.',['知了']='知了:BAACLAAFFH8IAAIIAAII7iQJTABmAAAIAAII7iQJTABmAAAsAAQKfxUAAwgABggPH+JAAJkBAAgABggPH+JAAJkBAAoAAghQEy06AHIAAAAA.',['秋天']='秋天的牛牛:BAAALAAECgcICwAAAA==.',['米麻']='米麻薯了:BAAALAAECgEIAQAAAA==.',['繁华']='繁华泡影:BAAALAAECgUIBQAAAA==.',['绯雪']='绯雪:BAACLAAFFH8xAAIEAAYInhMaBQB2AQAEAAYInhMaBQB2AQAsAAQKfyAABAQACAi+GwcaAEoCAAQACAi+GwcaAEoCAAUABAifC2TFAOgAABkAAghlEd0XAIIAAAAA.',['美杜']='美杜莎克:BAAALAAECgYICQAAAA==.',['羽毛']='羽毛灵魂:BAAALAAECgIIAgAAAA==.',['老实']='老实人毛海峰:BAAALAAECgEIAQAAAA==.',['老龚']='老龚:BAACLAAFFH8gAAIBAAYIMSEgMAB6AQABAAYIMSEgMAB6AQAsAAQKfxgAAgEACAg+JCMFAOACAAEACAg+JCMFAOACAAAA.',['聪聪']='聪聪呆:BAAALAAFFAIIAgABLAAFFAQIBAALAAAAAA==.',['肉丨']='肉丨土豆:BAAALAAFFAIIBAAAAA==.',['肯达']='肯达赫迪:BAABLAAECn8uAAIXAAgIoR4gKACfAgAXAAgIoR4gKACfAgAAAA==.',['艾利']='艾利之书:BAAALAAECggICAAAAA==.',['艾尔']='艾尔文丶:BAACLAAFFH8kAAMJAAYIpB9HGQDRAQAJAAYIvR5HGQDRAQAYAAEIQBANFQBGAAAsAAQKfyUAAgkACAiGJMUWAAMDAAkACAiGJMUWAAMDAAAA.',['艾琳']='艾琳同学:BAABLAAFFH8UAAMJAAYIHxVLNwBhAQAJAAYIHxVLNwBhAQAYAAIIMRc1IACIAAAAAA==.',['茵琪']='茵琪:BAAALAAFFAIIAgAAAA==.',['荣誉']='荣誉既吾命:BAAALAAECgYIEQAAAA==.',['萨斯']='萨斯给给:BAAALAADCggIEQAAAA==.',['薇尔']='薇尔莉特:BAAALAAECggIEwAAAA==.',['薯片']='薯片妹:BAAALAAECgQIBAAAAA==.',['蛋总']='蛋总本总:BAAALAAECgEIAQAAAA==.',['血法']='血法兜兜:BAAALAAECgYIBgAAAA==.',['血液']='血液燃烧:BAAALAAFFAIIBAAAAA==.',['血猎']='血猎冬冬:BAAALAAECgYICQAAAA==.',['语風']='语風:BAAALAADCgEIAQABLAADCgcIBwALAAAAAA==.',['貓豆']='貓豆:BAAALAAFFAIIAgAAAA==.',['账房']='账房姑娘:BAAALAAECgUIBQAAAA==.',['辣个']='辣个小德:BAAALAAECgYIBgAAAA==.',['邪恶']='邪恶的木偶:BAACLAAFFH8uAAMVAAYIxh1sDQDaAQAVAAYIxh1sDQDaAQAPAAQIAiCtEQAuAQAsAAQKfycAAw8ACAjUI4UUANACAA8ACAjUI4UUANACABUABQhyHR4zAEQBAAAA.',['针灸']='针灸坚持游戏:BAAALAAFFAIIAgAAAA==.',['锋不']='锋不可挡:BAAALAAECgYIDQAAAA==.',['锦绣']='锦绣櫏橙:BAAALAAECggICAAAAA==.',['阿克']='阿克贝德:BAAALAAECgYICQAAAA==.',['集火']='集火吉俺娜:BAAALAAECgYIAwAAAA==.',['零度']='零度疯狂:BAAALAAECgYIBwAAAA==.零度赞歌:BAAALAAECgYIBgAAAA==.',['雷斯']='雷斯:BAAALAAFFAIIAgAAAA==.雷斯丶德穆兰:BAAALAAECgYICgAAAA==.雷斯丶赛义德:BAAALAAECgQIBwAAAA==.',['霜之']='霜之裁决:BAABLAAFFH8GAAIBAAYI/wCAcgBOAAABAAYI/wCAcgBOAAAAAA==.',['露肚']='露肚谋:BAAALAAFFAgIAwAAAA==.',['靚仔']='靚仔丨缺德否:BAAALAAECgMIBAAAAA==.',['鞣蚌']='鞣蚌大:BAAALAAECgYICAAAAA==.',['风林']='风林火山:BAAALAAFFAMIAwAAAA==.',['食人']='食人花大帝:BAAALAAECgYIBgAAAA==.',['骑毛']='骑毛驴上高速:BAAALAAFFAIIAgAAAA==.',['鮮血']='鮮血淋漓:BAAALAAFFAIIBAAAAA==.',['麻辣']='麻辣小龙虾:BAAALAAECgYICAAAAA==.',['黑夜']='黑夜月想曲:BAAALAADCgEIAQAAAA==.',['黑暗']='黑暗丶怒风:BAAALAAECgYIBgAAAA==.',['默默']='默默宝宝:BAABLAAFFH8HAAIOAAIILArzTABYAAAOAAIILArzTABYAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end