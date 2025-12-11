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
 local lookup = {'DeathKnight-Frost','Mage-Frost','Mage-Arcane','Warlock-Affliction','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Shaman-Restoration','Shaman-Elemental','DemonHunter-Havoc','Druid-Restoration','Druid-Guardian','Warrior-Protection','Paladin-Holy','Shaman-Enhancement','Hunter-Marksmanship','Monk-Brewmaster','Monk-Windwalker','Priest-Holy','DeathKnight-Blood','DemonHunter-Vengeance','Druid-Feral','Warrior-Fury','Monk-Mistweaver','DeathKnight-Unholy','Hunter-Survival','Rogue-Assassination','Warlock-Destruction',}; local provider = {region='CN',realm='祖阿曼',name='CN',type='weekly',zone=44,date='2025-12-06',data={Da='Dawnwing:BAAALAAECgIIAgAAAA==.',Di='Distance:BAAALAADCggICAAAAA==.',Et='Eternity:BAAALAADCgYIBgAAAA==.',Go='Goodbye:BAABLAAFFH8FAAIBAAII7Af0kAA+AAABAAII7Af0kAA+AAAAAA==.',Gu='Gurban:BAABLAAFFH8FAAMCAAMIyRIuDgB6AAACAAMIyRIuDgB6AAADAAEIPQZOawBGAAAAAA==.',La='Landscape:BAACLAAFFH8OAAIEAAMI/RCiAwCjAAAEAAMI/RCiAwCjAAAsAAQKfxwAAgQACAimIvwBACUDAAQACAimIvwBACUDAAAA.',Ma='Marstema:BAAALAAECgMIAwAAAA==.',Mi='Mikulu:BAAALAAECgYIEwAAAA==.',Ot='Ot:BAAALAAFFAEIAQAAAA==.',Sk='Skyzero:BAABLAAFFH8KAAIFAAII0hVWTwCTAAAFAAII0hVWTwCTAAAAAA==.',Sm='Smallpanpan:BAABLAAFFH8IAAIBAAIIbCNLOQC/AAABAAIIbCNLOQC/AAAAAA==.',St='Starxcc:BAACLAAFFH8PAAMGAAQIEhL2DQCnAAAFAAQINAzyOQCyAAAGAAIIkRz2DQCnAAAsAAQKfygAAwUACAj2GXJfACwCAAUACAgQGHJfACwCAAYABghUHEUkANsBAAAA.',Su='Summer:BAAALAAFFAIIAgAAAA==.',Yo='Yo:BAABLAAFFH8ZAAIHAAgIxxelGQDPAQAHAAgIxxelGQDPAQAAAA==.',['一乐']='一乐:BAAALAAECgYIDQAAAA==.',['一抹']='一抹夜光:BAABLAAFFH8eAAMIAAYIuBa3FwCfAQAIAAYIuBa3FwCfAQAJAAEIUQNGTwA2AAAAAA==.一抹星光:BAABLAAFFH8ZAAMIAAYIDhWeKAAfAQAIAAUIehKeKAAfAQAJAAEIFQLZUQAwAAAAAA==.一抹晨光:BAABLAAFFH8UAAMIAAYIjhCFIwBCAQAIAAYIjhCFIwBCAQAJAAEIpAHaUwAoAAAAAA==.一抹月光:BAABLAAFFH8TAAMIAAYIQRUBKQAcAQAIAAUIVhIBKQAcAQAJAAEI7AH5UAAyAAAAAA==.一抹阳光:BAABLAAFFH8eAAMIAAYI9RNOIwBEAQAIAAYI9RNOIwBEAQAJAAEINgGGVQAZAAAAAA==.',['一薩']='一薩格拉斯一:BAAALAADCgIIAgAAAA==.',['一袋']='一袋甜椒:BAAALAAECgYICgAAAA==.',['三花']='三花溜溜球:BAAALAADCggICAAAAA==.',['不一']='不一般关系:BAAALAAECgMIAwAAAA==.',['东方']='东方土著丶:BAAALAAECgcIDQAAAA==.',['丨毛']='丨毛毛雨丨:BAAALAAECgIIAgAAAA==.',['丶乔']='丶乔巴:BAAALAAECgYIEAAAAA==.',['丶啸']='丶啸尘:BAAALAAECgEIAQAAAA==.',['丶幽']='丶幽蓝蝶:BAABLAAECn8YAAIKAAYIiB55KQC1AQAKAAYIiB55KQC1AQAAAA==.',['丶微']='丶微尘:BAAALAAECgMIAwAAAA==.',['丶无']='丶无尘:BAAALAAECgEIAQAAAA==.',['丶河']='丶河蟹灬软蛋:BAABLAAFFH8JAAMLAAII8AJwSABTAAALAAII8AJwSABTAAAMAAII7goFDwAoAAAAAA==.',['丶红']='丶红魔:BAAALAAECgYIDQAAAA==.',['乆蒋']='乆蒋奇明:BAAALAAECgYICAAAAA==.',['九死']='九死生:BAAALAAECgcIBwAAAA==.',['二狗']='二狗:BAAALAAECgIIAgAAAA==.',['云治']='云治:BAABLAAFFH8HAAINAAcI9RCADAB6AQANAAcI9RCADAB6AQAAAA==.',['亚雷']='亚雷修罗:BAAALAAECgIIAgAAAA==.',['亲亲']='亲亲小相公:BAAALAAECgYIDwAAAA==.',['人间']='人间风雪客:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利蛋幼儿园:BAAALAADCgMIAwABLAAFFAcIDwAOAFYeAA==.',['会發']='会發光:BAAALAAECgMIBwAAAA==.',['佈德']='佈德鸟:BAAALAAFFAIIAgAAAA==.',['低调']='低调的小骑:BAAALAAFFAIIAgAAAA==.',['信仰']='信仰战哀木涕:BAAALAAECggIDwAAAA==.',['個众']='個众塰陸控:BAAALAADCgQIBAAAAA==.',['倏忽']='倏忽如风:BAAALAAFFAEIAQAAAA==.',['兜兜']='兜兜里藏的糖:BAAALAAFFAIIAgAAAA==.',['六把']='六把猎:BAAALAAFFAIIBAAAAA==.',['六条']='六条德:BAAALAAECgIIAgAAAA==.',['六次']='六次骑:BAAALAAECgYIDAAAAA==.',['冰火']='冰火精灵:BAAALAAECgMIAwAAAA==.',['冰点']='冰点小心:BAABLAAFFH8FAAIPAAMIUBTiBACbAAAPAAMIUBTiBACbAAAAAA==.',['冰谶']='冰谶玫瑰:BAABLAAECn8XAAIFAAYISQ5N3wBbAQAFAAYISQ5N3wBbAQAAAA==.',['冷秋']='冷秋遥:BAAALAAECgQIBwAAAA==.',['冷风']='冷风:BAACLAAFFH8MAAIHAAIIDh6khwBJAAAHAAIIDh6khwBJAAAsAAQKfxkAAwcACAj2HSkgADwCAAcACAj2HSkgADwCABAABAg7BIqkAGoAAAAA.',['凯萨']='凯萨大米粒:BAAALAADCgMIAwAAAA==.',['刀神']='刀神:BAABLAAFFH8GAAIIAAIITgHneAA5AAAIAAIITgHneAA5AAAAAA==.',['刘诗']='刘诗诗:BAABLAAFFH8KAAIRAAgIuQvQBwDSAQARAAgIuQvQBwDSAQABLAAFFAgIGgARADISAA==.',['刺哥']='刺哥:BAAALAAECgIIAgAAAA==.',['刺灬']='刺灬瑰:BAABLAAFFH8FAAIFAAIIQhh6WQBKAAAFAAIIQhh6WQBKAAAAAA==.',['十六']='十六丶天玑:BAAALAAECgYIBgAAAA==.',['厨神']='厨神唐牛:BAAALAADCgUIBQAAAA==.',['及时']='及时雨:BAAALAAECgYIAgAAAA==.',['可乐']='可乐小法:BAAALAAECgUICAAAAA==.',['可爱']='可爱的小小龙:BAAALAAECgcIEgAAAA==.',['名动']='名动天下:BAAALAAFFAQIAgAAAA==.',['听泉']='听泉逐星:BAABLAAFFH8GAAIHAAYIRACexQAKAAAHAAYIRACexQAKAAAAAA==.',['呱呱']='呱呱护卫:BAAALAADCgUIBQAAAA==.',['和绅']='和绅老婆:BAAALAADCgUICAAAAA==.',['咸蛋']='咸蛋:BAABLAAFFH8FAAMHAAQI5hRsXQDOAAAHAAQI5hRsXQDOAAAQAAEIswfOHgAAAAAAAA==.',['嘚瑟']='嘚瑟骑士:BAAALAAECgUIBQAAAA==.',['嘿咻']='嘿咻咻灬:BAABLAAFFH8QAAMOAAcI0xRLDAAfAQAOAAUIRhVLDAAfAQAFAAIIGRLAUgBQAAAAAA==.',['圣光']='圣光婴宁:BAABLAAFFH8IAAIFAAIIexRsQQCdAAAFAAIIexRsQQCdAAAAAA==.圣光絮儿:BAAALAAECggICAAAAA==.',['垃圾']='垃圾转运车:BAABLAAFFH8FAAISAAMInhR2CQDuAAASAAMInhR2CQDuAAAAAA==.',['城里']='城里的奶奶:BAABLAAFFH8GAAITAAYIMBe+BQAAAgATAAYIMBe+BQAAAgAAAA==.',['墨邪']='墨邪无痕:BAAALAAFFAIIBAAAAA==.',['夜枫']='夜枫丶岚:BAABLAAFFH8IAAIUAAIIaxfxDQCXAAAUAAIIaxfxDQCXAAAAAA==.',['夜神']='夜神一笑:BAABLAAFFH8JAAIHAAII6RUZlABDAAAHAAII6RUZlABDAAAAAA==.夜神一菲:BAAALAAECgcIBwABLAAFFAIICQAHAOkVAA==.',['夜雨']='夜雨潇潇:BAABLAAFFH8IAAIHAAYIkwoUVAD+AAAHAAYIkwoUVAD+AAAAAA==.',['大秦']='大秦铁甲如云:BAABLAAFFH8MAAIBAAIIESO8PQC2AAABAAIIESO8PQC2AAAAAA==.',['大老']='大老虎:BAAALAADCggICAAAAA==.',['天堂']='天堂制造:BAAALAAECgQIBAAAAA==.',['天空']='天空的恶魔:BAAALAAECgMIAwAAAA==.天空的猎仁:BAAALAAECgYIDAAAAA==.天空的骑士:BAABLAAFFH8GAAIGAAIIag0sHQAxAAAGAAIIag0sHQAxAAAAAA==.',['天行']='天行者:BAAALAAECgQIBQAAAA==.',['女伯']='女伯爵赛琳娜:BAAALAAECgcIDwAAAA==.',['威猛']='威猛先生:BAAALAAFFAIIBAAAAA==.',['娇龙']='娇龙:BAAALAAECgEIAQAAAA==.',['娜塔']='娜塔亚:BAABLAAFFH8OAAIHAAYINBWtNgBjAQAHAAYINBWtNgBjAQAAAA==.',['寒霜']='寒霜怒雪:BAAALAAECgQIBwAAAA==.',['射你']='射你个不吱声:BAAALAAECgYIDAAAAA==.',['小妹']='小妹:BAAALAADCgEIAQAAAA==.',['小李']='小李广:BAAALAAECgUIBQAAAA==.',['小皮']='小皮球:BAAALAAFFAIIAgAAAA==.',['小裤']='小裤衩:BAACLAAFFH8KAAIDAAIIwhCTTQCTAAADAAIIwhCTTQCTAAAsAAQKfxwAAwMACAgvG/ocAMMBAAMACAgkG/ocAMMBAAIABQh2DTphAO8AAAAA.',['小蹦']='小蹦豆:BAAALAAECgEIAQAAAA==.',['就喜']='就喜欢巨无霸:BAAALAAECgEIAQAAAA==.',['屋檐']='屋檐下你我:BAAALAAECggIEgAAAA==.屋檐下有你:BAAALAADCggICAAAAA==.屋檐下的你:BAAALAAECgQIBgAAAA==.',['崔崔']='崔崔:BAAALAAFFAIIBAAAAA==.',['巫灬']='巫灬妖一:BAABLAAFFH8XAAINAAgIyg2aCAC4AQANAAgIyg2aCAC4AQAAAA==.巫灬妖三:BAABLAAFFH8JAAINAAUIwgplGADiAAANAAUIwgplGADiAAAAAA==.巫灬妖二:BAABLAAFFH8XAAINAAgIXwzNCQCkAQANAAgIXwzNCQCkAQAAAA==.巫灬妖四:BAABLAAFFH8XAAINAAgIUQ77BwDDAQANAAgIUQ77BwDDAQAAAA==.',['干饭']='干饭熊阿树:BAACLAAFFH8SAAMIAAYI5h1JDQACAgAIAAYI5h1JDQACAgAJAAII1gSeOABvAAAsAAQKfxkAAgkABwgiEycqAHIBAAkABwgiEycqAHIBAAAA.',['年轻']='年轻老头:BAAALAAECgYIEgAAAA==.',['幻痛']='幻痛萤:BAAALAAECgYIDQAAAA==.',['幽骑']='幽骑:BAABLAAFFH8GAAIFAAIIsQWyfAA0AAAFAAIIsQWyfAA0AAAAAA==.',['很皮']='很皮的小脑辅:BAAALAAECgYICQAAAA==.',['御劍']='御劍乘風:BAAALAAECgQIDwAAAA==.',['德鲁']='德鲁之灵:BAAALAAFFAIIAgAAAA==.',['忘形']='忘形丶:BAAALAAFFAIIAgAAAA==.',['忧伤']='忧伤:BAAALAAECgQIBQAAAA==.忧伤帅:BAAALAAFFAIIAgAAAA==.忧伤猎:BAABLAAFFH8FAAIHAAIIWxhNfgBaAAAHAAIIWxhNfgBaAAAAAA==.忧伤萨满:BAAALAAFFAIIAgAAAA==.忧伤还是快乐:BAAALAAFFAIIAgAAAA==.忧伤骑士:BAAALAAFFAIIAgAAAA==.',['慕容']='慕容怜香:BAAALAADCgIIAwAAAA==.',['我也']='我也是个宝宝:BAAALAAFFAIIAgAAAA==.',['我是']='我是坦克:BAABLAAFFH8IAAIVAAII0gPAGQBPAAAVAAII0gPAGQBPAAAAAA==.',['我美']='我美吗:BAAALAAECgQIBAAAAA==.',['扑棱']='扑棱蛾子:BAAALAAECgYIBgAAAA==.',['抖音']='抖音玩物丧智:BAABLAAECn8bAAIFAAgIuBrvQwBwAgAFAAgIuBrvQwBwAgABLAAFFAQIBwABAKoNAA==.',['抱皂']='抱皂不安:BAAALAAFFAIIBAAAAA==.',['挤挤']='挤挤不露:BAABLAAFFH8OAAINAAII/Qm5JwBvAAANAAII/Qm5JwBvAAAAAA==.挤挤布鲁:BAABLAAFFH8OAAIGAAIIMwZHIQApAAAGAAIIMwZHIQApAAAAAA==.',['撼地']='撼地神牛:BAAALAAECgMIAwAAAA==.',['斗牛']='斗牛牛:BAAALAAFFAQIBAAAAA==.',['斩月']='斩月:BAAALAADCgYIBgAAAA==.',['斯人']='斯人如逝:BAABLAAFFH8MAAMWAAUIZgxUBwAIAQAWAAUIZgxUBwAIAQALAAIInQJCSwBLAAAAAA==.',['旋转']='旋转的陀螺:BAAALAADCgcIBwAAAA==.',['无影']='无影:BAAALAAFFAIIAgAAAA==.',['无情']='无情无意狂:BAAALAAECgYIDAAAAA==.无情灬:BAAALAAECgIIAgAAAA==.',['无求']='无求心静:BAAALAAFFAIIBAAAAA==.',['无法']='无法不狂:BAAALAAECgYIBgAAAA==.',['星语']='星语夜翼:BAAALAADCggIDgAAAA==.',['晕晕']='晕晕萨:BAAALAAFFAIIAgAAAA==.',['晴天']='晴天的小铖:BAAALAAECgQIBAAAAA==.',['暗夜']='暗夜精翎:BAAALAAFFAQIBAAAAA==.',['暴躁']='暴躁的周公瑾:BAABLAAFFH8XAAIHAAYIRhiELwB5AQAHAAYIRhiELwB5AQAAAA==.',['曾德']='曾德帅丶:BAAALAADCgYIBgAAAA==.',['月亮']='月亮之子:BAAALAADCgEIAQAAAA==.',['月半']='月半亻子:BAAALAAECgYIDQAAAA==.',['未來']='未來永劫斬:BAAALAAECgcIBwAAAA==.',['术不']='术不语:BAAALAAECgYICgAAAA==.',['李思']='李思思:BAABLAAFFH8UAAIRAAgIvw2/BwDTAQARAAgIvw2/BwDTAQABLAAFFAgIGgARADISAA==.',['李拜']='李拜天:BAAALAAECgYIBgAAAA==.',['杜康']='杜康:BAAALAAECgYIBgAAAA==.',['林狗']='林狗狗:BAAALAAECgIIAgAAAA==.',['柒院']='柒院脊梁:BAAALAAECgIIAgABLAAFFAQICwAJAOkMAA==.',['核动']='核动力呲水枪:BAAALAAECgcICQAAAA==.核动力搅拌机:BAABLAAECn8bAAMXAAcIURIycACrAQAXAAcIURIycACrAQANAAYINQZJbwDNAAAAAA==.核动力洗衣机:BAABLAAECn8UAAMSAAYIAxCAHAAbAQASAAYIAxCAHAAbAQAYAAYIzRMiGgAKAQAAAA==.',['次级']='次级风暴元素:BAACLAAFFH8TAAMJAAYIJA32HgBKAQAJAAYIJA32HgBKAQAIAAEIChMzbgBPAAAsAAQKfzEAAgkACAhCIcAIAJgCAAkACAhCIcAIAJgCAAAA.',['死亡']='死亡之网:BAABLAAFFH8GAAMZAAIIKAxBEwBKAAAZAAIIKAxBEwBKAAABAAEIBQPjpAAvAAAAAA==.',['残刀']='残刀刀:BAAALAAECgYIBgAAAA==.',['水木']='水木倾城:BAAALAAFFAIIAgAAAA==.',['江湖']='江湖术:BAAALAAFFAIIBAAAAA==.',['沁雪']='沁雪:BAABLAAFFH8MAAMBAAYI7w5EFgCUAQABAAYIyA1EFgCUAQAZAAEIqhD3EQBOAAAAAA==.',['沉蒾']='沉蒾伱啲羙丶:BAAALAAECgQIBAAAAA==.',['沉默']='沉默之剑:BAABLAAFFH8IAAMNAAIItQNxOAAnAAANAAIItQNxOAAnAAAXAAIISwG5ZQAXAAAAAA==.',['没有']='没有蛀牙:BAAALAADCgIIAgAAAA==.',['流漓']='流漓:BAABLAAFFH8IAAIHAAYIMwP8YwCoAAAHAAYIMwP8YwCoAAAAAA==.',['浦蒲']='浦蒲:BAAALAADCgIIAgAAAA==.',['浪人']='浪人:BAAALAAECgYICAAAAA==.',['海瑟']='海瑟丶薇:BAABLAAFFH8mAAIHAAYIYxQENQBoAQAHAAYIYxQENQBoAQABLAAFFAYIJwAFABcjAA==.海瑟薇丶安妮:BAABLAAFFH8hAAIMAAYItBpIAgCAAQAMAAYItBpIAgCAAQABLAAFFAYIJwAFABcjAA==.',['海蓝']='海蓝之迷:BAAALAAECgYIBgAAAA==.',['浸泪']='浸泪无殇:BAAALAAECgUICAAAAA==.',['淘气']='淘气的小猫咪:BAAALAAECgYICwAAAA==.',['淡淡']='淡淡独白:BAAALAADCgEIAQAAAA==.淡淡的雪花:BAABLAAFFH8FAAINAAIIUwmVJwBvAAANAAIIUwmVJwBvAAAAAA==.',['深蓝']='深蓝:BAAALAAECgYIEwAAAA==.',['溜得']='溜得一批:BAAALAAECgYIBgAAAA==.',['灬幻']='灬幻海灬:BAAALAADCgEIAQAAAA==.',['灰浊']='灰浊:BAAALAAECgYIDAAAAA==.',['炎黄']='炎黄龙魂:BAAALAAFFAIIAwAAAA==.',['炮炮']='炮炮糖:BAABLAAFFH8LAAIHAAMI5RCmcACAAAAHAAMI5RCmcACAAAAAAA==.',['烟台']='烟台小哥:BAAALAAECgcICAAAAA==.',['燎原']='燎原妖:BAABLAAFFH8IAAIaAAIISB2PBABMAAAaAAIISB2PBABMAAAAAA==.',['爱曲']='爱曲:BAAALAAECgYIDAAAAA==.',['牛小']='牛小花灬:BAABLAAFFH8fAAMOAAgIHRooCwA9AQAOAAYIMhgoCwA9AQAFAAIIpxQfPACkAAAAAA==.',['牜仔']='牜仔:BAAALAAECgEIAQAAAA==.',['狂野']='狂野的怒风:BAACLAAFFH8TAAIKAAMIWwvdQQCGAAAKAAMIWwvdQQCGAAAsAAQKfy8AAgoACAi+Fa5ZABkCAAoACAi+Fa5ZABkCAAAA.狂野的愤怒:BAAALAAFFAIIBAAAAA==.',['独奶']='独奶天下:BAAALAADCgYIBgAAAA==.',['独射']='独射天下丶:BAAALAAECgIIAgAAAA==.',['独瘤']='独瘤天下:BAAALAADCgYIBgAAAA==.',['独盗']='独盗天下:BAAALAADCgQIBAAAAA==.',['狼人']='狼人微微:BAAALAAECgYICgAAAA==.',['猎灬']='猎灬王:BAAALAADCgcICQAAAA==.',['猛思']='猛思君:BAAALAAFFAEIAQAAAA==.',['王冰']='王冰冰:BAABLAAFFH8aAAIRAAgIMhKeBgDqAQARAAgIMhKeBgDqAQAAAA==.',['王阿']='王阿斗:BAAALAAECgMIAwAAAA==.',['琅琊']='琅琊王:BAABLAAECn8UAAIbAAYIowyfQABQAQAbAAYIowyfQABQAQAAAA==.',['瑞文']='瑞文戴爾女爵:BAACLAAFFH8IAAIFAAMIvQVYUQBTAAAFAAMIvQVYUQBTAAAsAAQKfxUAAgUACAjrEXI5ALEBAAUACAjrEXI5ALEBAAAA.',['瓜子']='瓜子花生:BAABLAAFFH8GAAIDAAII1gyAUQCPAAADAAII1gyAUQCPAAAAAA==.',['瓦斯']='瓦斯琪:BAABLAAFFH8ZAAIRAAYIrg4hEABIAQARAAYIrg4hEABIAQAAAA==.',['电动']='电动香蕉:BAAALAAECgUIAgAAAA==.',['疯狂']='疯狂的摇滚熊:BAABLAAECn8jAAMSAAgIkxbpJADaAQASAAYIGhzpJADaAQARAAgIsQisLgAcAQAAAA==.',['皮蛋']='皮蛋:BAABLAAFFH8MAAIHAAgIOh+NCwAvAgAHAAgIOh+NCwAvAgAAAA==.',['眾生']='眾生繁華:BAACLAAFFH8nAAMFAAYIFyM7CwDrAQAFAAYIFyM7CwDrAQAGAAII9QsgGwBvAAAsAAQKfxkAAwYABgguH+8mAMoBAAUABggCHzd7APQBAAYABgh5Gu8mAMoBAAAA.',['瞄准']='瞄准:BAAALAAECgYICAAAAA==.',['知道']='知道什么了:BAABLAAECn8XAAIKAAYIWxQ2qwB5AQAKAAYIWxQ2qwB5AQAAAA==.',['神赐']='神赐之名:BAACLAAFFH8fAAMQAAcImAraDwDwAAAQAAUIpwnaDwDwAAAHAAUIGwteLADQAAAsAAQKfy4ABBAACAgsF8cuAAwCABAACAj2FscuAAwCAAcABgi8EVXcAFsBABoAAQiSDSImADYAAAAA.',['秋枫']='秋枫易醉:BAAALAAECggIDwAAAA==.',['窗间']='窗间过马:BAABLAAFFH8PAAMDAAYITBRvIACUAQADAAYITBRvIACUAQACAAEIwRFxEwBJAAAAAA==.',['粒粒']='粒粒大魔王:BAAALAADCgMIAwAAAA==.',['紫薇']='紫薇花开:BAAALAAECgUIBQAAAA==.',['絶戀']='絶戀乄夜雨:BAABLAAFFH8VAAIXAAUIaB3mHwBsAQAXAAUIaB3mHwBsAQAAAA==.絶戀乄巫師:BAABLAAFFH8QAAIcAAMI6hZ8RwCiAAAcAAMI6hZ8RwCiAAAAAA==.',['红光']='红光满面:BAAALAADCggICAAAAA==.',['红尘']='红尘丶虾仁:BAABLAAFFH8GAAMIAAII3QxBUwBpAAAIAAII3QxBUwBpAAAJAAIIlwLwUQAvAAAAAA==.',['约翰']='约翰尼丶德普:BAAALAAECgYIBgAAAA==.',['美好']='美好时光:BAAALAAECgYIEwAAAA==.',['義穆']='義穆池:BAAALAAFFAEIAQAAAA==.',['老登']='老登黄毛来了:BAACLAAFFH8TAAIFAAYI4gxYLAAhAQAFAAYI4gxYLAAhAQAsAAQKfykAAgUACAhLIpkQAIkCAAUACAhLIpkQAIkCAAAA.',['联盟']='联盟疤痕:BAABLAAECn8XAAIFAAYI7B6nNQC+AQAFAAYI7B6nNQC+AQAAAA==.',['胡萝']='胡萝卜中人:BAAALAAFFAIIAgAAAA==.',['脆皮']='脆皮五花肉:BAAALAAECgMIAwAAAA==.',['花叶']='花叶:BAAALAADCgMIAwAAAA==.',['苍岚']='苍岚:BAAALAAFFAIIAgAAAA==.',['苞米']='苞米地的王:BAAALAADCgcIBwAAAA==.',['荣耀']='荣耀之箭:BAAALAAECgYICQAAAA==.',['萨拉']='萨拉隆:BAAALAAFFAIIAwAAAA==.',['葉小']='葉小風:BAAALAAFFAIIBAAAAA==.',['蒋奇']='蒋奇明亅:BAAALAAECgIIAgAAAA==.',['蒲公']='蒲公英的旅行:BAAALAAFFAMIBAAAAA==.',['薇薇']='薇薇逗奶:BAABLAAFFH8IAAIFAAIIuB7TVgBLAAAFAAIIuB7TVgBLAAAAAA==.',['虚空']='虚空蕾丝:BAAALAAECgEIAQAAAA==.',['蛊月']='蛊月:BAABLAAFFH8IAAIcAAMIZwRKUwBjAAAcAAMIZwRKUwBjAAAAAA==.',['蜘蛛']='蜘蛛泡酒:BAAALAAFFAMIAwAAAA==.',['血灬']='血灬战:BAAALAAECgMIBwAAAA==.',['行云']='行云流水:BAAALAAECgcICwAAAA==.',['詮釋']='詮釋傳說:BAABLAAECn8UAAILAAcItxZhIQDIAQALAAcItxZhIQDIAQAAAA==.',['謬丶']='謬丶論:BAABLAAFFH8mAAMXAAYIdRz3EgDCAQAXAAYIWxn3EgDCAQANAAYI9xnPDAB2AQABLAAFFAYIJwAFABcjAA==.',['豆比']='豆比别跑:BAAALAADCggICAAAAA==.',['豆豆']='豆豆快跑:BAABLAAFFH8UAAMJAAYIRg5FHQBWAQAJAAYIRg5FHQBWAQAIAAIItQsDVgBnAAAAAA==.豆豆骑士:BAABLAAFFH8OAAIFAAYI6RQ4GgCHAQAFAAYI6RQ4GgCHAQAAAA==.',['豬小']='豬小黑:BAAALAAECgEIAQAAAA==.',['貌似']='貌似单纯:BAAALAADCgMIAwAAAA==.',['超市']='超市里扫货:BAAALAADCgEIAQAAAA==.',['超爱']='超爱玩:BAABLAAFFH8GAAIFAAIIXgWZXACCAAAFAAIIXgWZXACCAAAAAA==.',['跳舞']='跳舞的圣歌:BAAALAAECgIIAgAAAA==.',['还是']='还是哐哐呀:BAABLAAFFH8IAAIBAAYIxCBdEgD8AQABAAYIxCBdEgD8AQAAAA==.',['迪莉']='迪莉娅丶语风:BAAALAAECggICAAAAA==.',['逆蜂']='逆蜂:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥物外人:BAABLAAFFH8OAAIDAAYI1hFeKwBjAQADAAYI1hFeKwBjAQAAAA==.逍遥的天空:BAAALAAECgIIAgAAAA==.',['道艰']='道艰难唯志成:BAAALAADCggICAAAAA==.',['那个']='那个逗哔:BAACLAAFFH8LAAIBAAMI/g9uVwCcAAABAAMI/g9uVwCcAAAsAAQKfxQAAgEABwjNIPA1AJ4CAAEABwjNIPA1AJ4CAAAA.',['邪能']='邪能卡比兽:BAABLAAFFH8GAAINAAYITAuUBwCDAQANAAYITAuUBwCDAQABLAAFFAgIBgANAJwbAA==.',['部落']='部落大肉盾:BAACLAAFFH8KAAIGAAMI3Qk2DgClAAAGAAMI3Qk2DgClAAAsAAQKfxkAAwYACAhrFhMlANYBAAYACAhrFhMlANYBAAUAAwiAB+BPAZAAAAAA.',['量子']='量子打工人:BAAALAAECggIEQAAAA==.',['银一']='银一霏:BAABLAAFFH8KAAIHAAIIdR1aggBRAAAHAAIIdR1aggBRAAABLAAFFAQIBwABAKoNAA==.',['闹呢']='闹呢:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔赛利亚:BAACLAAFFH8TAAMFAAUI+Qc5MgDxAAAFAAUI+Qc5MgDxAAAOAAQIowEaIgCRAAAsAAQKfzMAAwUACAieD3NYAFkBAAUABwiMEHNYAFkBAA4ACAg3CL9EAEkBAAAA.',['阿狸']='阿狸小哥:BAABLAAFFH8HAAIHAAUIkQ9EVAD9AAAHAAUIkQ9EVAD9AAAAAA==.',['阿破']='阿破主:BAAALAAECgYIEQAAAA==.',['阿达']='阿达尔之手:BAAALAADCgEIAQAAAA==.',['雾里']='雾里看花:BAAALAAECgUIBQAAAA==.',['青冥']='青冥浩荡:BAAALAADCgEIAQAAAA==.',['風凌']='風凌之黑雪:BAAALAAECgYIDgAAAA==.',['風行']='風行者丶春秋:BAAALAADCgIIAgAAAA==.',['风潇']='风潇易临:BAAALAAECgQIAgAAAA==.',['风起']='风起长林:BAABLAAFFH8HAAIHAAIIxBtbUACVAAAHAAIIxBtbUACVAAAAAA==.',['飯小']='飯小團:BAAALAAECgEIAQAAAA==.',['驭龙']='驭龙漂移:BAAALAAFFAIIBAAAAA==.',['骁风']='骁风:BAABLAAFFH8QAAMNAAYIVxJ/BQDEAQANAAYI0BB/BQDEAQAXAAUI8hAvKgAaAQAAAA==.',['骨頭']='骨頭:BAAALAADCgQIBAAAAA==.',['魔神']='魔神丸:BAAALAAECgQIBAAAAA==.',['鱼摆']='鱼摆摆了不起:BAAALAAECgYIDAAAAA==.',['黄四']='黄四郎:BAAALAAECggICAAAAA==.',['黑狼']='黑狼骑:BAAALAAECgEIAgAAAA==.',['鼠式']='鼠式坦克:BAABLAAECn8UAAMBAAYINBxNtwCkAQABAAYI6RtNtwCkAQAZAAUItRQMMwA1AQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end