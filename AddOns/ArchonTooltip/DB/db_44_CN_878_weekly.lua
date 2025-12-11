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
 local lookup = {'DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Warrior-Protection','DeathKnight-Frost','Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Holy','Evoker-Preservation','Evoker-Devastation','Monk-Mistweaver','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','Druid-Restoration','Priest-Holy','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Monk-Brewmaster','Priest-Shadow','Monk-Windwalker','Warlock-Affliction','DeathKnight-Unholy',}; local provider = {region='CN',realm='雷霆号角',name='CN',type='weekly',zone=44,date='2025-12-09',data={Al='Altolia:BAAALAAECgUIBQAAAA==.',An='Andy:BAAALAADCgIIAgAAAA==.',Ci='Cirilla:BAAALAADCgEIAQAAAA==.',Dh='Dhqaq:BAABLAAFFH8MAAIBAAYIEho7HACZAQABAAYIEho7HACZAQAAAA==.',Dp='Dpaladin:BAAALAAECgYIBwAAAA==.',Eu='Euemenides:BAAALAAECgYIBgAAAA==.',Ev='Evy:BAAALAAECgQIBAAAAA==.',Ga='Gaea:BAAALAAECgcIDwAAAA==.',Gr='Groot:BAAALAAECgEIAQAAAA==.',Ha='Hackenlee:BAAALAADCgEIAQAAAA==.',He='Heimdall:BAAALAAECgYIBgAAAA==.',Kl='Klarke:BAABLAAECn8oAAQCAAYIsR01LACtAQACAAYIsR01LACtAQADAAMIOheGJwDAAAAEAAEIfhF4lQA6AAAAAA==.',Li='Lightofhell:BAAALAAECgYIBQAAAA==.',Lu='Luna:BAAALAAECgIIAgAAAA==.',Ma='Maydesnow:BAAALAAFFAEIAQAAAA==.',Mi='Miebai:BAAALAAFFAIIAgABLAAFFAgIDAAFAJceAA==.',Mo='Monore:BAAALAAECgYICAAAAA==.Mozei:BAAALAAECgYIBwAAAA==.',Na='Nagies:BAABLAAFFH8UAAMGAAYIIxPrCAADAQAHAAUIbQzDNwAWAQAGAAUILxHrCAADAQAAAA==.',Ni='Nightsorrow:BAAALAAECgYIDAAAAA==.',Oc='Octc:BAABLAAFFH8KAAIIAAYICwdFKwAuAQAIAAYICwdFKwAuAQAAAA==.',Pa='Pale:BAAALAAECgEIAQAAAA==.',Qu='Quake:BAAALAADCgEIAQAAAA==.',Ri='Rina:BAAALAAECgQIBAAAAA==.',Si='Simpleton:BAACLAAFFH8YAAIIAAYIDh+cDgBiAQAIAAYIDh+cDgBiAQAsAAQKfzAAAggACAhqI8hOAFMCAAgACAhqI8hOAFMCAAAA.Simpletonlol:BAACLAAFFH8IAAIIAAII2yPVJwC6AAAIAAII2yPVJwC6AAAsAAQKfxcAAggACAjoGhkIAR0BAAgACAjoGhkIAR0BAAAA.',So='Sophie:BAAALAAECgYIBgAAAA==.',Sw='Swarovski:BAAALAAECgYIBgAAAA==.',Th='Thor:BAABLAAFFH8GAAIJAAYIsgL3FwAXAQAJAAYIsgL3FwAXAQAAAA==.',To='Tonystark:BAAALAADCgEIAQAAAA==.',Va='Valerious:BAAALAAECgQIBAAAAA==.',Vo='Voidweaver:BAABLAAFFH8MAAIGAAIINBdTFQCCAAAGAAIINBdTFQCCAAAAAA==.',Ya='Yaya:BAAALAAECgIIAgAAAA==.',Ye='Yemo:BAAALAADCgQIBAAAAA==.',['一个']='一个胖纸居然:BAAALAAECgYIBgAAAA==.',['一脸']='一脸懵逼:BAABLAAFFH8IAAMKAAMI2gz2GQByAAAKAAMI2gz2GQByAAALAAII4A8SIQA5AAAAAA==.',['丁香']='丁香:BAABLAAFFH8KAAIMAAYIxBGNCgBqAQAMAAYIxBGNCgBqAQAAAA==.',['七仔']='七仔:BAAALAAECgYIBgAAAA==.',['三月']='三月:BAAALAAECgYICAAAAA==.',['不朽']='不朽之王:BAAALAAECgUICQAAAA==.不朽的憂傷:BAABLAAFFH8GAAINAAIIAgt1FABGAAANAAIIAgt1FABGAAAAAA==.',['且战']='且战且退:BAAALAAECgUIBQAAAA==.',['东方']='东方无涯:BAAALAAECgUIBQAAAA==.',['丝缕']='丝缕缠流:BAAALAAFFAIIBAAAAA==.',['义父']='义父:BAAALAAECgYICwAAAA==.',['云小']='云小星:BAACLAAFFH8bAAIIAAcI6RkzCgD5AQAIAAcI6RkzCgD5AQAsAAQKfx4AAggACAh9IYgqAMcCAAgACAh9IYgqAMcCAAAA.云小枫:BAAALAAECgQIBAAAAA==.',['休得']='休得无礼:BAAALAAECgcIBwAAAA==.',['伽勒']='伽勒比海带:BAACLAAFFH8dAAMOAAcI+BlQGADcAQAOAAcIbRhQGADcAQAPAAQIOBMvEwDMAAAsAAQKfx0AAw8ACAiuHlEhAF4CAA8ACAhHHVEhAF4CAA4ABginGdy4AIkBAAAA.',['信仰']='信仰黑暗:BAAALAADCgQIBAAAAA==.',['假大']='假大空:BAAALAAECgYIEAAAAA==.',['光电']='光电石:BAAALAAFFAIIAgAAAA==.',['六神']='六神:BAAALAAFFAIIAgAAAA==.',['兹拉']='兹拉坦:BAAALAAECgIIAgAAAA==.',['兽魂']='兽魂夜灵:BAAALAAFFAIIAgAAAA==.',['冰戒']='冰戒魂:BAAALAAFFAIIBAAAAA==.',['冰火']='冰火兩重天:BAAALAADCgIIAgAAAA==.冰火随风息:BAAALAADCgYIBgAAAA==.',['凛冬']='凛冬丶之刄:BAABLAAECn8UAAIFAAYIYhiN6ABjAQAFAAYIYhiN6ABjAQAAAA==.',['刘太']='刘太医:BAAALAAECgcIDwAAAA==.',['功夫']='功夫熊猫丨:BAAALAAECggIDwAAAA==.',['加尔']='加尔鲁什:BAABLAAECn8VAAMCAAYIUxqNaQC8AQACAAYIEhmNaQC8AQADAAIIbBZoLQCJAAAAAA==.',['动如']='动如雷霆:BAABLAAFFH8eAAIEAAYIGQvYFAAcAQAEAAYIGQvYFAAcAQAAAA==.',['勇者']='勇者不死:BAAALAAECgMIAwAAAA==.',['十廿']='十廿卅卌:BAAALAAECgYIDwAAAA==.',['千变']='千变:BAAALAAECgYICwAAAA==.',['千影']='千影道尊:BAAALAAECgYICQAAAA==.',['卑鄙']='卑鄙的我:BAABLAAECn8bAAMQAAgI4BAkJQDxAQAQAAgI4BAkJQDxAQANAAUIuwSMPAC2AAAAAA==.',['博丽']='博丽霊梦:BAAALAAFFAIIAgAAAA==.',['卡佳']='卡佳利丝:BAAALAAECgYIDQAAAA==.',['卡多']='卡多尔:BAABLAAECn8kAAIJAAYIwxd6GQCGAQAJAAYIwxd6GQCGAQAAAA==.',['叮来']='叮来的发丝:BAAALAADCgMIAwAAAA==.',['可爱']='可爱天使:BAAALAAECgYICgAAAA==.可爱的甜甜:BAABLAAFFH8IAAIIAAMI7hRGQwCOAAAIAAMI7hRGQwCOAAAAAA==.',['史矛']='史矛革:BAAALAAECgYIBgAAAA==.',['呈诺']='呈诺:BAAALAAFFAIIAgAAAA==.',['周纸']='周纸弱:BAABLAAFFH8GAAIIAAIIDyJDTwBeAAAIAAIIDyJDTwBeAAAAAA==.',['命运']='命运:BAAALAAFFAIIAgAAAA==.',['哎利']='哎利达嘶:BAAALAAECgQIBQAAAA==.',['啊库']='啊库娜玛塔塔:BAACLAAFFH8MAAIIAAMIUhs4QACXAAAIAAMIUhs4QACXAAAsAAQKfxwAAggABwiTH+ZlAB4CAAgABwiTH+ZlAB4CAAAA.',['啋啋']='啋啋:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血邪神:BAAALAAECgYIDAAAAA==.',['嗳卟']='嗳卟咧:BAAALAAECgYICwAAAA==.',['嗳木']='嗳木涕:BAAALAAECgIIAgAAAA==.',['四阿']='四阿哥:BAAALAAFFAIIAgAAAA==.',['国产']='国产零零发:BAAALAAECgYIBgAAAA==.',['堕堕']='堕堕鸡:BAAALAAECgYIDgAAAA==.',['墨渊']='墨渊:BAAALAAECgUIBQAAAA==.',['大侠']='大侠:BAAALAAECgYIDAAAAA==.',['大嶋']='大嶋优子:BAAALAAECgEIAQAAAA==.',['大帝']='大帝:BAAALAADCgEIAQAAAA==.',['大惡']='大惡魔丶:BAABLAAFFH8HAAIFAAIIgSBYcgBRAAAFAAIIgSBYcgBRAAAAAA==.',['大满']='大满贯:BAAALAADCgIIAgAAAA==.',['大漂']='大漂亮丶:BAAALAAECgEIAQAAAA==.',['大漠']='大漠孤烟:BAAALAADCgQIBAAAAA==.大漠飞鹰:BAAALAADCgIIAgAAAA==.',['大风']='大风的二哈:BAAALAAECgYICQAAAA==.',['天之']='天之我痕:BAAALAAECgYIBgAAAA==.',['天无']='天无语:BAABLAAECn8VAAIRAAcIrxACRgADAQARAAcIrxACRgADAQAAAA==.',['天涯']='天涯共银辉:BAAALAAECgYIBgAAAA==.',['天青']='天青色等烟雨:BAABLAAFFH8SAAMOAAQIGBQhZQCtAAAOAAQIGBQhZQCtAAAPAAEIEAQ8OQAyAAAAAA==.',['太烧']='太烧了:BAAALAADCgYICAAAAA==.',['奈非']='奈非天:BAAALAAECgYIEAAAAA==.',['奥恩']='奥恩:BAAALAADCgYICwAAAA==.',['奶酪']='奶酪的杀手:BAAALAADCgMIAwAAAA==.',['好人']='好人缘:BAABLAAFFH8HAAIFAAUIqQHUWgCfAAAFAAUIqQHUWgCfAAAAAA==.',['孙尚']='孙尚香丶:BAAALAAFFAIIAgAAAA==.',['孙红']='孙红雷丶:BAACLAAFFH8QAAIBAAIIoRGETwBLAAABAAIIoRGETwBLAAAsAAQKfxUAAgEABgh3H5liAAQCAAEABgh3H5liAAQCAAAA.',['守云']='守云:BAAALAADCgYIBgAAAA==.',['安保']='安保大帝:BAABLAAECn8VAAMDAAgI+Rz7EwCcAQADAAUIPBz7EwCcAQACAAYI8RRAgACGAQAAAA==.',['安卡']='安卡希雅:BAAALAAECgYIBgAAAA==.',['完美']='完美谢幕:BAAALAAFFAIIBAAAAA==.',['寂寞']='寂寞的烟花:BAABLAAFFH8GAAISAAIIRAXdRwBdAAASAAIIRAXdRwBdAAAAAA==.',['对影']='对影成三人:BAABLAAFFH8UAAIBAAcIURTeFQC8AQABAAcIURTeFQC8AQAAAA==.',['射死']='射死你:BAAALAAECgEIAQAAAA==.射死矮子:BAAALAAECgcIBgAAAA==.',['小倒']='小倒莓:BAAALAAECgYIDAAAAA==.',['小兔']='小兔米纱:BAAALAAECgIIAgAAAA==.',['小竹']='小竹:BAABLAAFFH8FAAIBAAIIfxUvSQBXAAABAAIIfxUvSQBXAAAAAA==.小竹妈:BAAALAAFFAIIBAAAAA==.小竹妹:BAABLAAFFH8FAAICAAIIGA4TOQCVAAACAAIIGA4TOQCVAAABLAAFFAgIMAAHAN0fAA==.小竹姐:BAABLAAFFH8IAAIGAAIIHiDbDwCQAAAGAAIIHiDbDwCQAAAAAA==.小竹姑妈:BAABLAAFFH8SAAILAAYIRA3TDQBHAQALAAYIRA3TDQBHAQAAAA==.小竹小姨妈:BAAALAAFFAIIBAAAAA==.',['小红']='小红手菈妮:BAACLAAFFH8iAAMOAAcIBwrCMQB3AQAOAAcIBwrCMQB3AQAPAAMImgFXKgBzAAAsAAQKfxsAAg8ACAgWEZBDAKgBAA8ACAgWEZBDAKgBAAAA.',['小船']='小船不用桨:BAABLAAFFH8GAAIJAAIIQhEZHwCKAAAJAAIIQhEZHwCKAAAAAA==.',['小草']='小草莓:BAAALAAECgUIBQAAAA==.',['小贝']='小贝:BAAALAADCggICAAAAA==.',['山三']='山三:BAAALAAECgUIBQAAAA==.',['左眼']='左眼见鬼:BAAALAAECgQIBAAAAA==.',['巫祝']='巫祝:BAACLAAFFH8NAAITAAMIexzJNwCiAAATAAMIexzJNwCiAAAsAAQKfx4AAxMABwiaIs0WACsCABMABwiaIs0WACsCABQAAQgDI2SHAGQAAAAA.',['巴斯']='巴斯托尼小猪:BAAALAAECgYIBgAAAA==.',['布丁']='布丁:BAAALAAECgQIBAAAAA==.',['布劳']='布劳缪克斯:BAAALAAECgYICwAAAA==.',['希纳']='希纳瓦尔斯:BAAALAAECgYIBgAAAA==.',['幸福']='幸福像花一样:BAABLAAFFH8dAAMVAAcI0hJwHwBlAQAVAAYI7RJwHwBlAQAWAAIIzwQDOQB6AAAAAA==.',['强力']='强力猪宝宝:BAAALAAFFAYIAgAAAA==.',['归易']='归易:BAAALAAECgMIAwAAAA==.',['形象']='形象好:BAAALAAECgEIAQAAAA==.',['征战']='征战艾泽拉思:BAAALAADCgYIBgAAAA==.',['得天']='得天独厚:BAAALAAFFAIIAgAAAA==.',['得瑟']='得瑟的小宝:BAAALAAECgEIAQAAAA==.',['德发']='德发鲁伊:BAABLAAFFH8HAAIRAAYIcwcaJQD3AAARAAYIcwcaJQD3AAAAAA==.',['心凌']='心凌甄宝:BAABLAAECn8WAAIVAAYI7hogKQDJAQAVAAYI7hogKQDJAQAAAA==.',['忽必']='忽必猎:BAAALAAFFAIIAgAAAA==.',['怀特']='怀特先生:BAABLAAFFH8IAAIFAAYI4xYSKwCQAQAFAAYI4xYSKwCQAQAAAA==.',['恭喜']='恭喜你妹:BAAALAAECgYIBgAAAA==.',['愤青']='愤青:BAAALAAECgYICwAAAA==.',['我叫']='我叫死骑:BAAALAAFFAIIAgAAAA==.',['战国']='战国奇熊:BAAALAAECgQIBAAAAA==.',['战歌']='战歌嘹亮:BAAALAAECgYIBgAAAA==.',['打个']='打个大气球:BAAALAAFFAIIAwAAAA==.',['折花']='折花之人:BAACLAAFFH8LAAICAAMIqBE9OACWAAACAAMIqBE9OACWAAAsAAQKfxkAAgIABggHHHMzAI0BAAIABggHHHMzAI0BAAAA.',['故事']='故事没有故事:BAAALAAECgIIBAAAAA==.',['无名']='无名圣骑:BAABLAAECn8eAAIIAAYIKR/vMgDJAQAIAAYIKR/vMgDJAQAAAA==.无名小术:BAAALAAECgIIAwAAAA==.无名小萨:BAAALAAECgUICQAAAA==.无名晓猎:BAABLAAECn8cAAIOAAcIdhj9VACcAQAOAAcIdhj9VACcAQAAAA==.无名死骑:BAAALAAECgIIAgAAAA==.',['无声']='无声铃鹿:BAAALAAECgIIAgAAAA==.',['无畏']='无畏冲锋:BAABLAAECn8YAAICAAYIcxN0PgBiAQACAAYIcxN0PgBiAQAAAA==.',['晓晴']='晓晴:BAAALAAECgQIBAAAAA==.',['晓月']='晓月媚儿:BAAALAADCgQIBAAAAA==.',['晓胖']='晓胖胖:BAAALAADCgYIBgAAAA==.',['晓靑']='晓靑:BAAALAAECgYICAAAAA==.',['暗黑']='暗黑大叔:BAACLAAFFH8KAAIFAAMI3Q/zYgCLAAAFAAMI3Q/zYgCLAAAsAAQKfxQAAgUACAhdGRBPAFsCAAUACAhdGRBPAFsCAAEsAAUUBwgdAA4A+BkA.',['暗黯']='暗黯谙闇:BAABLAAFFH8MAAISAAIIQxNoLACTAAASAAIIQxNoLACTAAAAAA==.',['暧哟']='暧哟喂:BAAALAAECgYIEwAAAA==.',['會上']='會上树的猫:BAAALAAECgYIDQAAAA==.',['月丶']='月丶夜:BAAALAADCggICAAAAA==.',['月倾']='月倾浅丶:BAABLAAFFH8pAAMKAAYIEhbzCAAzAQAKAAYIEhbzCAAzAQALAAIIeBd5FACqAAAAAA==.',['月瞳']='月瞳灬:BAABLAAFFH8RAAIBAAQIjhlVFABJAQABAAQIjhlVFABJAQAAAA==.',['月神']='月神祈祷:BAABLAAFFH8GAAIRAAIIhQsuSwBcAAARAAIIhQsuSwBcAAAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8QAAMRAAgIHhl/CgALAgARAAcI/Rh/CgALAgAXAAEIfBUPLABYAAAAAA==.',['月薇']='月薇乔安娜:BAACLAAFFH8RAAIPAAQI9xCHEQDcAAAPAAQI9xCHEQDcAAAsAAQKfxYAAg8ACAhSHDchAF8CAA8ACAhSHDchAF8CAAAA.',['杀死']='杀死索索:BAAALAAFFAIIAgAAAA==.',['村里']='村里的小白白:BAAALAADCgYIBgAAAA==.',['来打']='来打打我啊:BAAALAAFFAMIAwAAAA==.',['杨紫']='杨紫琼:BAACLAAFFH8iAAIYAAcIRxUlCgCqAQAYAAcIRxUlCgCqAQAsAAQKfxsAAhgACAj7G1kQAFUCABgACAj7G1kQAFUCAAAA.',['杯莫']='杯莫婷:BAAALAADCgcIBwAAAA==.',['枫僷']='枫僷琳娜:BAAALAAECgMIAwAAAA==.',['柳眠']='柳眠棠丶:BAAALAAECggICgAAAA==.',['桃桃']='桃桃龙:BAAALAAECggIEwAAAA==.',['梦丨']='梦丨璃子:BAAALAAECgYIBgAAAA==.',['椰菜']='椰菜宝宝:BAABLAAFFH8MAAIWAAYIKAKPLQDUAAAWAAYIKAKPLQDUAAAAAA==.',['橙子']='橙子和鹿:BAABLAAFFH8MAAIOAAYIVQl6cgCBAAAOAAYIVQl6cgCBAAAAAA==.',['此物']='此物与我有缘:BAAALAAFFAIIBAAAAA==.',['死亡']='死亡墓穴:BAABLAAECn80AAIFAAgIUx1ZEQBjAgAFAAgIUx1ZEQBjAgAAAA==.死亡阴影:BAAALAAECgcIDgAAAA==.',['比翼']='比翼双刃:BAAALAAECgYICQAAAA==.',['水月']='水月无恒:BAAALAAECgYIBgAAAA==.',['汀烟']='汀烟轻冉冉:BAAALAAECggIAgAAAA==.',['江南']='江南:BAAALAAECgYIBgAAAA==.',['汤圆']='汤圆:BAAALAAECgYICgAAAA==.',['沐雨']='沐雨听风:BAAALAAECgIIAgAAAA==.沐雨橙風:BAAALAAECgYIDQAAAA==.',['泡菜']='泡菜炒面:BAAALAADCgQIBAAAAA==.',['泽兰']='泽兰:BAABLAAFFH8IAAIMAAYIaw/OCgBkAQAMAAYIaw/OCgBkAQAAAA==.',['洛阳']='洛阳:BAAALAAECgYICgAAAA==.',['清酒']='清酒:BAABLAAFFH8IAAITAAMIAgORVABhAAATAAMIAgORVABhAAAAAA==.',['清风']='清风沐雨:BAAALAAECgYICgAAAA==.',['游泳']='游泳的鱼:BAAALAAECgIIAgAAAA==.',['游羽']='游羽入:BAACLAAFFH8bAAMZAAYImBJMDwAnAQAZAAUIpxVMDwAnAQASAAMIhgw0LgC5AAAsAAQKfxkAAhkACAiLHCoeAIACABkACAiLHCoeAIACAAAA.',['漩涡']='漩涡狼人:BAAALAAFFAIIBAAAAA==.',['灬彼']='灬彼岸花灬:BAAALAAECgYIDAAAAA==.',['灬樱']='灬樱木花道灬:BAACLAAFFH8OAAIaAAII5SHPEwBYAAAaAAII5SHPEwBYAAAsAAQKfxkAAhoABgjEIcsYAEUCABoABgjEIcsYAEUCAAAA.',['灬淡']='灬淡然:BAACLAAFFH8mAAMOAAcIBiH/DgC4AQAOAAYIVyT/DgC4AQAPAAQInRg4DwD6AAAsAAQKfxYAAw4ABwhNJUFOAEMCAA4ABgiTJEFOAEMCAA8ABgj9JDctABUCAAAA.',['灬示']='灬示神灬:BAAALAAECgYIDAAAAA==.',['灭却']='灭却诡:BAABLAAFFH8UAAIbAAYIChDHAQCJAQAbAAYIChDHAQCJAQAAAA==.',['灵微']='灵微玄同:BAAALAAECgYIBgAAAA==.',['烈烈']='烈烈风中:BAAALAADCgMIAwAAAA==.',['烈焰']='烈焰灼心:BAAALAAFFAIIAgAAAA==.',['無忧']='無忧:BAAALAAECggICAAAAA==.',['無念']='無念:BAAALAAFFAMIBAAAAA==.',['爱灬']='爱灬致死不愈:BAAALAAECggICAAAAA==.',['爱野']='爱野美奈子:BAAALAAECgUIBQAAAA==.',['爸爸']='爸爸爱你:BAAALAAECgYIBgAAAA==.',['狂二']='狂二老牛:BAABLAAFFH8UAAIFAAcIeROCHADJAQAFAAcIeROCHADJAQAAAA==.',['狂暴']='狂暴之箭:BAAALAAECgYIBgAAAA==.',['独孤']='独孤一剑:BAABLAAFFH8GAAICAAIISxkzRwBNAAACAAIISxkzRwBNAAAAAA==.',['玉骄']='玉骄龙:BAAALAAFFAIIAwAAAA==.',['玛尔']='玛尔戈克黑血:BAABLAAECn8YAAIFAAcIkBxTVgBKAgAFAAcIkBxTVgBKAgAAAA==.',['瑞文']='瑞文摩尔:BAABLAAFFH8MAAITAAYIaQTBRwCpAAATAAYIaQTBRwCpAAAAAA==.',['瑰冰']='瑰冰玉:BAAALAAECggICAAAAA==.',['瓜田']='瓜田里的猹:BAAALAAECgYIDAAAAA==.',['瓦里']='瓦里安丶逐月:BAAALAAECgYIBgAAAA==.',['画沙']='画沙:BAAALAAECgYICAAAAA==.',['疯狂']='疯狂艾米丽:BAAALAAFFAIIAgAAAA==.',['疾风']='疾风:BAAALAAECgEIAQAAAA==.',['皮鞭']='皮鞭和木马:BAABLAAFFH8GAAIVAAIIpw81TgBtAAAVAAIIpw81TgBtAAAAAA==.',['盐煮']='盐煮:BAAALAAFFAIIAgAAAA==.',['盛大']='盛大登场:BAAALAAFFAIIAgAAAA==.',['相忘']='相忘于江湖:BAAALAAECgUIBQAAAA==.',['破心']='破心:BAABLAAFFH8iAAIIAAYI5yFWCwDuAQAIAAYI5yFWCwDuAQAAAA==.',['碧螺']='碧螺春水:BAACLAAFFH8HAAIIAAUI2QZ2IQDLAAAIAAUI2QZ2IQDLAAAsAAQKfxsAAggACAghFn9hACgCAAgACAghFn9hACgCAAAA.',['礻申']='礻申灬禾必:BAABLAAFFH8OAAIFAAMIFxS4YQCNAAAFAAMIFxS4YQCNAAAAAA==.',['礼小']='礼小异:BAAALAAECgIIAgAAAA==.',['礼手']='礼手一挥:BAABLAAFFH8NAAIGAAIIcSHRDACfAAAGAAIIcSHRDACfAAAAAA==.',['祁祁']='祁祁四十九变:BAAALAAECgYIBgAAAA==.',['祁纪']='祁纪:BAACLAAFFH8KAAMUAAYISx5cCADCAAATAAYIhR1sIQAVAQAUAAIIzSRcCADCAAAsAAQKfxoABBQACAjXJTcIAOQCABQABwjbJTcIAOQCABMABghoIxE5AFYCABsAAQgfDQc9AEEAAAAA.',['神龙']='神龙烈焰:BAAALAAFFAYIBAAAAA==.',['程潇']='程潇:BAAALAAECgYICwAAAA==.',['程肖']='程肖宇:BAAALAAECgYICQAAAA==.',['立立']='立立的小法法:BAAALAAECgIIAgAAAA==.',['筱蕊']='筱蕊:BAAALAAECgYIBgAAAA==.',['精灵']='精灵力量:BAAALAADCgMIAwAAAA==.',['索尓']='索尓:BAABLAAFFH8QAAMVAAIIrBhESwCIAAAVAAIIrBhESwCIAAAWAAIIvwPIOQBlAAAAAA==.',['紫云']='紫云悠悠:BAAALAAFFAIIAgAAAA==.',['紫光']='紫光:BAAALAAECgUIBQAAAA==.',['綻鴋']='綻鴋:BAAALAAECgYICQAAAA==.',['纛麤']='纛麤靐爨:BAAALAAECggICwAAAA==.',['网恋']='网恋骑:BAAALAAECgIIAgAAAA==.',['罗哌']='罗哌卡因:BAAALAADCgYIBgAAAA==.',['罗斯']='罗斯劈扣:BAABLAAFFH8IAAIIAAIIVRvnKwCyAAAIAAIIVRvnKwCyAAAAAA==.',['美女']='美女泡泡:BAAALAAECgQIBAAAAA==.',['翻白']='翻白眼的船:BAABLAAFFH8RAAIOAAYIrxXcNABuAQAOAAYIrxXcNABuAQAAAA==.',['聂克']='聂克猫:BAACLAAFFH8IAAIWAAQIKgyyLwC+AAAWAAQIKgyyLwC+AAAsAAQKfxYAAhYABwjtHMlBAP0BABYABwjtHMlBAP0BAAAA.',['肥嘎']='肥嘎嘎:BAAALAAECgYICwAAAA==.',['胖胖']='胖胖一术:BAABLAAFFH8dAAITAAYInhYjJQCIAQATAAYInhYjJQCIAQAAAA==.',['胡子']='胡子小爹:BAAALAAECgYIDAAAAA==.',['芭乐']='芭乐:BAAALAAECgYIBgAAAA==.芭乐梦干书服:BAAALAAFFAIIAgAAAA==.',['茄咧']='茄咧菲:BAAALAAFFAIIBAAAAA==.',['茯苓']='茯苓:BAABLAAFFH8UAAISAAYIchv5EgDGAQASAAYIchv5EgDGAQAAAA==.',['莫根']='莫根:BAAALAAECgQIBgAAAA==.',['莫邪']='莫邪剑使:BAACLAAFFH8bAAMEAAUIIBOhFgAEAQACAAUIfg0lKAA0AQAEAAUIrhKhFgAEAQAsAAQKfxcAAwIABwjvG9U+ADoCAAIABwi8G9U+ADoCAAQABAirG4BWACkBAAAA.',['落魄']='落魄山刀刀:BAABLAAFFH8KAAIRAAYIYgEJQwBsAAARAAYIYgEJQwBsAAABLAAFFAgIEwAFANYXAA==.',['蒂玛']='蒂玛:BAAALAAECgEIAQAAAA==.',['蝶刺']='蝶刺:BAAALAAFFAIIAgAAAA==.',['蟠韬']='蟠韬:BAAALAAECgQIBAAAAA==.',['西湖']='西湖月:BAAALAAECgYICAAAAA==.',['见手']='见手青:BAACLAAFFH82AAMFAAYIGhsUFwCKAQAFAAYIGhsUFwCKAQAcAAII7wOoFgBxAAAsAAQKfzQAAwUACAiBJP8ZAAgDAAUACAiBJP8ZAAgDABwABAj9DGJHAKUAAAAA.',['让雨']='让雨下进灵魂:BAAALAAECgYICQAAAA==.',['谁来']='谁来:BAAALAAECgMIAwAAAA==.',['调皮']='调皮的雪琳:BAAALAAECgYIBgAAAA==.',['谢榭']='谢榭:BAABLAAFFH8FAAIOAAUIkgg0YQDEAAAOAAUIkgg0YQDEAAAAAA==.',['谢霆']='谢霆锋:BAAALAAECggIEwAAAA==.',['赛尔']='赛尔贝莉娅:BAAALAAECgQIBAAAAA==.',['超级']='超级经济人:BAAALAAECgYIBgAAAA==.',['超限']='超限爆闪:BAAALAAFFAIIBAAAAA==.',['轩辕']='轩辕何何:BAAALAAECgYIDAAAAA==.',['转圈']='转圈圈:BAABLAAECn8WAAIaAAYI4hDYGwAlAQAaAAYI4hDYGwAlAQAAAA==.',['轻抚']='轻抚板凳腿儿:BAAALAAECgYIBgAAAA==.',['远古']='远古捕猎者:BAAALAADCgIIAgAAAA==.',['逍遥']='逍遥龍影:BAAALAADCgIIAgAAAA==.',['酩殇']='酩殇法夜:BAAALAAFFAIIBAAAAA==.',['采采']='采采:BAAALAAECgYICAAAAA==.',['铁木']='铁木真:BAABLAAFFH8MAAIVAAIIUQ+LYABdAAAVAAIIUQ+LYABdAAAAAA==.',['陳大']='陳大發:BAABLAAFFH8QAAMCAAMIyBsNNQCkAAACAAMIyBsNNQCkAAAEAAII1A9lIwB3AAAAAA==.',['雪琳']='雪琳:BAAALAAECgYIDAAAAA==.',['霍哈']='霍哈霍哈:BAAALAAECgYICwAAAA==.',['青丘']='青丘皮卡丘:BAACLAAFFH8hAAMVAAYIjwVLMgDlAAAVAAYIjwVLMgDlAAAWAAIIoAHCPQBTAAAsAAQKfxwAAxUACAgOEiJBAFkBABUACAgOEiJBAFkBABYAAQjdBK3ZACcAAAAA.',['青乀']='青乀春:BAAALAAECgcIBwAAAA==.',['青灬']='青灬乀春:BAAALAAECgYIDAAAAA==.青灬春:BAAALAAECgEIAQAAAA==.',['靓仔']='靓仔:BAAALAAECgYIBgAAAA==.',['非法']='非法行医:BAAALAAFFAIIAgAAAA==.',['风中']='风中的承諾:BAAALAAECgIIAwAAAA==.',['风之']='风之庭:BAABLAAFFH8LAAMWAAYIexBKJQAgAQAWAAUI+g9KJQAgAQAVAAIIjAnwWwBlAAAAAA==.',['风暴']='风暴大地:BAAALAAECgYIDQAAAA==.',['风舞']='风舞恋:BAAALAAECgMIAwAAAA==.',['风雪']='风雪:BAAALAAECggICAAAAA==.',['风风']='风风丶:BAAALAADCgUIBQAAAA==.',['高兴']='高兴:BAAALAAFFAIIAgAAAA==.',['高大']='高大侠:BAAALAAFFAEIAQAAAA==.',['鬼人']='鬼人再不斩:BAAALAAECgYIBwAAAA==.',['鬼影']='鬼影缠身:BAACLAAFFH8SAAIFAAIICSZHVQCeAAAFAAIICSZHVQCeAAAsAAQKfyQAAgUABwjsI4ARAGICAAUABwjsI4ARAGICAAAA.',['黄宗']='黄宗泽:BAAALAAECgIIAgAAAA==.',['黑腩']='黑腩:BAABLAAFFH8IAAMWAAgIPRXkCwD0AQAWAAcImhbkCwD0AQAVAAEIKB47YwBZAAAAAA==.',['龍傲']='龍傲天:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end