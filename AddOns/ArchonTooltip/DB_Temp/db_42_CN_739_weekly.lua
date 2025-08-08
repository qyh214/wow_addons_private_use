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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Evoker-Devastation','DeathKnight-Unholy','Priest-Holy','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Warrior-Arms','DeathKnight-Blood','Warrior-Fury','Shaman-Restoration','Mage-Arcane','Evoker-Preservation','Rogue-Assassination','Hunter-Survival','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Warlock-Affliction','Paladin-Protection','Paladin-Holy','Shaman-Enhancement','Mage-Fire',}; local provider = {region='CN',realm='激流堡',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aiden:BAABKgAFFH8MAAMBAAYIYyF+BwDqAQABAAYIYyF+BwDqAQACAAYI5AyJFwA9AQAAAA==.',Al='Alex:BAAAKgAECgIIAgAAAA==.',He='Heipeiba:BAAAKgADCgcIBwAAAA==.',Ia='Iamjudy:BAAAKgADCgEIAQAAAA==.',Ji='Jiuyongyixia:BAAAKgAECgUICgAAAA==.',Ju='Justdaisy:BAAAKgADCgQIBAAAAA==.',Jz='Jzdblz:BAAAKgADCgMIDAAAAA==.',La='Lastoneday:BAABKgAFFH8GAAMDAAUIvgopHACcAAADAAUIvgopHACcAAAEAAEIqg72IgBNAAAAAA==.',Li='Living:BAABKgAECn82AAIFAAgIvB51GQBvAgAFAAgIvB51GQBvAgAAAA==.',Lo='Lovelesslisa:BAAAKgAFFAIIBAAAAA==.',Ma='Makabaka:BAAAKgAECgIIAgAAAA==.',Na='Nature:BAAAKgAECgYIBgAAAA==.',Ne='Neverrepent:BAABKgAECn8YAAIBAAgI4xqbFACSAQABAAgI4xqbFACSAQABKgAFFAgIEgABAPELAA==.',Ra='Rainoverme:BAAAKgAECgIIAgAAAA==.',Sc='Science:BAAAKgAECggIEQAAAA==.',Si='Silenceice:BAABKgAFFH8GAAIBAAYI2xSKDgB2AQABAAYI2xSKDgB2AQAAAA==.',Vc='Vc:BAAAKgADCgEIAQAAAA==.',Wo='Wonn:BAABKgAFFH8FAAIGAAUIqQvuGgDpAAAGAAUIqQvuGgDpAAABKgAFFAgICAAHACsiAA==.',['一火']='一火云邪神一:BAAAKgAECgQIBAAAAA==.',['三叔']='三叔公:BAAAKgAECgIIAgAAAA==.',['三更']='三更雨:BAAAKgADCggIEAAAAA==.',['上帝']='上帝跟我混:BAAAKgAFFAgIAwAAAA==.',['不为']='不为:BAAAKgAECgYIBwAAAA==.',['不老']='不老神仙:BAAAKgAECgYICAAAAA==.',['丶七']='丶七堇年华:BAAAKgAECggIBQAAAA==.',['丶北']='丶北极:BAAAKgADCggICgAAAA==.丶北极丨德:BAAAKgAECggIEQAAAA==.丶北极丨术:BAAAKgADCgEIAQAAAA==.丶北极丨死:BAAAKgAECgcIDQAAAA==.丶北极丨法:BAAAKgAECgQIBAAAAA==.丶北极丨牧:BAABKgAFFH8GAAIIAAMI7A/gFQCPAAAIAAMI7A/gFQCPAAAAAA==.丶北极丨萨:BAAAKgAECgQIBAAAAA==.丶北极丨骑:BAABKgAFFH8GAAIJAAMIeATiNACPAAAJAAMIeATiNACPAAAAAA==.',['丶头']='丶头上有犄角:BAAAKgAECgQIBAAAAA==.',['丶红']='丶红烧排骨:BAABKgAECn8eAAICAAgIhR1BJQAiAgACAAgIhR1BJQAiAgABKgAFFAgICAACABcdAA==.',['丿獨']='丿獨家丶記憶:BAACKgAFFH8MAAIJAAYIHx/0EQDNAQAJAAYIHx/0EQDNAQAqAAQKfxcAAgkACAirJKkbAKkCAAkACAirJKkbAKkCAAAA.',['乖宝']='乖宝宝小语:BAAAKgAECggIDgAAAA==.',['九唔']='九唔搭八:BAAAKgAECgQIBQAAAA==.',['于很']='于很横狗蛋:BAABKgAECn8cAAMKAAgI1x5DAgCCAgAKAAgI1x5DAgCCAgALAAgIPhC4XQD2AAAAAA==.',['伊利']='伊利:BAAAKgAECgIIAgAAAA==.伊利达雷:BAAAKgAFFAYIAwAAAA==.',['伽古']='伽古拉:BAAAKgADCgMIAwAAAA==.',['光年']='光年:BAAAKgAECggIEQAAAA==.',['冰霜']='冰霜之心:BAAAKgAFFAQIBAABKgAFFAYICAAJAH0fAA==.',['冲钅']='冲钅:BAABKgAFFH8GAAIMAAYI0h4jCACKAQAMAAYI0h4jCACKAQAAAA==.',['冷暖']='冷暖两用:BAAAKgADCggICQAAAA==.',['凌云']='凌云海阁:BAAAKgADCgIIAgAAAA==.',['凡心']='凡心凡骑:BAAAKgAECgIIAgABKgAFFAgICgACAMERAA==.凡心迪凯:BAABKgAFFH8GAAINAAYI6wnfFwDiAAANAAYI6wnfFwDiAAAAAA==.',['加加']='加加:BAAAKgAECgIIAgAAAA==.',['勇者']='勇者斗恶龙:BAABKgAECn8fAAMMAAgIqxeTIACAAQAMAAgI3hSTIACAAQAOAAgIfRRwPAAtAQAAAA==.',['北极']='北极的巨人:BAAAKgAECgUIBQAAAA==.',['叉棍']='叉棍二零二四:BAAAKgAECgUIBQAAAA==.',['友友']='友友苟斯:BAAAKgAECgEIAQAAAA==.',['取名']='取名困难症:BAAAKgAECgEIAQAAAA==.',['召唤']='召唤职业:BAAAKgADCggICAAAAA==.',['同九']='同九年何汝秀:BAAAKgADCgUIBQAAAA==.',['君不']='君不见:BAAAKgAECgEIAgAAAA==.',['和稀']='和稀泥:BAAAKgAECgMIAwAAAA==.',['咚咚']='咚咚锵:BAABKgAFFH8FAAIPAAMIrhOPLwC5AAAPAAMIrhOPLwC5AAAAAA==.',['咻咻']='咻咻:BAABKgAFFH8IAAIQAAgIOwutCQDVAQAQAAgIOwutCQDVAQAAAA==.',['噤若']='噤若寒蝉:BAAAKgADCggICAAAAA==.',['圣光']='圣光击毙你:BAAAKgADCggICAAAAA==.圣光天使:BAAAKgAECgYIBgAAAA==.',['圣剑']='圣剑缘缘:BAAAKgAECgYIBgAAAA==.',['埃兰']='埃兰晨行者:BAAAKgADCgEIAQAAAA==.',['夜羽']='夜羽:BAACKgAFFH8GAAIBAAQIbROTLQC1AAABAAQIbROTLQC1AAAqAAQKfxUAAgEACAguGNIjAOYBAAEACAguGNIjAOYBAAAA.',['大头']='大头杨杨:BAAAKgAECgQIAwAAAA==.',['天使']='天使之约:BAAAKgAECgcIDAAAAA==.',['天才']='天才小阿吉:BAAAKgAECgMIBgAAAA==.',['头上']='头上有犄角:BAABKgAECn8XAAIRAAgIcAzoDwBfAQARAAgIcAzoDwBfAQAAAA==.',['女女']='女女我大晒:BAAAKgAECgcIEAAAAA==.',['女王']='女王:BAAAKgAECgEIAQAAAA==.',['女神']='女神:BAAAKgAFFAEIAgAAAA==.',['威猛']='威猛五爷:BAAAKgAECgIIAgAAAA==.',['学习']='学习侠:BAABKgAECn8WAAISAAgIPw8oIAB5AQASAAgIPw8oIAB5AQAAAA==.',['宫园']='宫园丶薰:BAAAKgAECgQIBQAAAA==.',['寂寞']='寂寞一根烟:BAACKgAFFH8FAAMCAAIIugSTVABbAAACAAIIPwSTVABbAAABAAIIugQFSwBUAAAqAAQKfx0ABAEACAgFEXtcAOMAAAEABggvEHtcAOMAAAIABgiWCz2wAMQAABMAAghXFIcYAHAAAAAA.',['寂灭']='寂灭邪罗:BAAAKgAFFAIIAgAAAA==.',['寒露']='寒露:BAAAKgAFFAIIAgAAAA==.',['小峻']='小峻峻:BAABKgAFFH8FAAIPAAUIKSLWCwCKAQAPAAUIKSLWCwCKAQAAAA==.',['小鬼']='小鬼们给我上:BAAAKgAFFAQIBAAAAA==.',['小鸡']='小鸡:BAAAKgAECggICAAAAA==.',['尘归']='尘归于尘:BAAAKgAFFAYIAQAAAA==.',['巧克']='巧克力丶楪祈:BAAAKgADCgMIBgAAAA==.',['巳月']='巳月海棠:BAAAKgAFFAUIAwAAAA==.',['师太']='师太:BAAAKgAECgUIBQAAAA==.',['彼岸']='彼岸花开成海:BAAAKgAFFAQIBAAAAA==.',['徐夕']='徐夕瑶:BAAAKgAECgEIAQAAAA==.',['德才']='德才兼备:BAAAKgADCgQIBAAAAA==.',['快乐']='快乐源泉:BAABKgAFFH8GAAIJAAYIswliKwA5AQAJAAYIswliKwA5AQABKgAFFAgIBAAUAAAAAA==.',['快播']='快播小视频:BAAAKgADCgUIBQAAAA==.',['惊蛰']='惊蛰:BAAAKgAFFAgIBAAAAA==.',['惠山']='惠山古镇:BAAAKgAECgIIAgAAAA==.',['惩戒']='惩戒之心:BAABKgAFFH8IAAIJAAQIfR/HDAAhAQAJAAQIfR/HDAAhAQAAAA==.',['慕斯']='慕斯:BAABKgAFFH8GAAMVAAYIkxB1BwAgAQAVAAUI+gx1BwAgAQAWAAEIJwq6IgBRAAAAAA==.',['慕蓉']='慕蓉萱:BAAAKgADCgQIBAAAAA==.',['战天']='战天使:BAAAKgAECgUIBgAAAA==.',['插图']='插图腾:BAAAKgAECgUIBwAAAA==.',['撼地']='撼地者:BAABKgAECn8vAAIPAAgIGhbrLgDNAQAPAAgIGhbrLgDNAQAAAA==.',['无声']='无声:BAAAKgAECgQIBAAAAA==.无声血:BAAAKgAECgQIBgAAAA==.',['日帝']='日帝:BAAAKgAECgMIAwAAAA==.',['日月']='日月同辉:BAAAKgAFFAIIAgAAAA==.',['明人']='明人不放暗屁:BAAAKgAFFAYIAgABKgAFFAgIAgAUAAAAAA==.',['明珠']='明珠求瑕:BAAAKgAECgUIDAAAAA==.',['明语']='明语:BAAAKgAECggICAAAAA==.',['星语']='星语如梦:BAABKgAFFH8GAAMLAAYIXw3JEQAVAQALAAUIZxDJEQAVAQAXAAEIQAFCEwA/AAABKgAFFAYIBgASAIYXAA==.',['時丶']='時丶雨:BAABKgAFFH8tAAQJAAQIvxmGHwDqAAAJAAMI+RaGHwDqAAAYAAQINxFPGwCeAAAZAAIIKgbCHQAzAAAAAA==.',['晓君']='晓君:BAABKgAFFH8IAAISAAQIuRKGDwBZAQASAAQIuRKGDwBZAQAAAA==.',['暗影']='暗影突击鹅:BAAAKgAECgYIBgAAAA==.',['曲你']='曲你妹:BAAAKgAECgMIAwAAAA==.',['月光']='月光罗刹:BAAAKgADCgEIAQAAAA==.',['月女']='月女神:BAABKgAFFH8GAAIaAAYICwTgCwANAQAaAAYICwTgCwANAQAAAA==.',['村上']='村上春树:BAAAKgAECgMIAwAAAA==.',['条子']='条子来了快跑:BAAAKgAECgUIBQAAAA==.',['松岛']='松岛菜菜鸟:BAABKgAFFH8GAAIbAAYIFwt4CAB5AQAbAAYIFwt4CAB5AQAAAA==.',['果味']='果味奶糖:BAAAKgAFFAQIBAABKgAFFAgICAACAKoYAA==.',['果果']='果果的妥妥:BAAAKgADCgUIBQAAAA==.',['柠檬']='柠檬果茶:BAAAKgAFFAgIBAAAAA==.',['梁少']='梁少一雕流:BAAAKgADCgIIAgAAAA==.',['梁桑']='梁桑一雕流:BAAAKgADCggICAAAAA==.梁桑牛牛大:BAAAKgADCgYIBgAAAA==.梁桑牛牛长:BAAAKgADCgIIAgAAAA==.',['梧桐']='梧桐轻语:BAAAKgAFFAQIBAAAAA==.',['毕方']='毕方:BAAAKgAECgUIBQAAAA==.',['水仙']='水仙兒:BAABKgAFFH8GAAIVAAMI5xZEGwC6AAAVAAMI5xZEGwC6AAAAAA==.',['沙奈']='沙奈朵:BAACKgAFFH8LAAINAAYIihnlAQCeAQANAAYIihnlAQCeAQAqAAQKfxsAAg0ACAjvHO0SABMCAA0ACAjvHO0SABMCAAAA.',['流汗']='流汗的小黑:BAAAKgAECgIIAgAAAA==.',['海水']='海水之心:BAAAKgAFFAIIAgAAAA==.',['淘淘']='淘淘小老六:BAACKgAFFH8ZAAIJAAUIGBW/HAD+AAAJAAUIGBW/HAD+AAAqAAQKfxgAAgkACAhjGz9FACACAAkACAhjGz9FACACAAAA.',['深秋']='深秋之殇:BAAAKgAFFAQIBAAAAA==.',['溪流']='溪流氺:BAAAKgAECgUICQAAAA==.',['灬索']='灬索利达尔灬:BAAAKgAECgcIEQAAAA==.',['炽天']='炽天使炎:BAAAKgAECgUIBQAAAA==.',['烤年']='烤年糕:BAAAKgADCgYIBgAAAA==.',['烤牛']='烤牛:BAAAKgADCgEIAQAAAA==.',['牛胡']='牛胡子:BAAAKgADCggICgAAAA==.',['牵只']='牵只猫去流浪:BAABKgAFFH8MAAMCAAQIowq8IADVAAACAAQIowq8IADVAAABAAEIAAD8LgAAAAAAAA==.',['狡诈']='狡诈的部落猪:BAACKgAFFH8OAAMLAAYIryI2CwAHAQALAAYIryI2CwAHAQAXAAQImRhBDgDEAAAqAAQKfzcABBcACAgIJlsAAPsCABcACAgIJlsAAPsCAAoAAQhQJOllAGcAAAsAAQiOGpWhAEYAAAAA.',['猛交']='猛交作业:BAAAKgAFFAQIBAAAAA==.',['玄改']='玄改不改欧:BAAAKgAFFAgIBAAAAA==.',['甘礼']='甘礼两:BAAAKgAECggICAAAAA==.',['白银']='白银之卡:BAAAKgAFFAIIAwAAAA==.',['百宠']='百宠王:BAAAKgAECgEIAQAAAA==.',['皇室']='皇室小骑:BAAAKgAECgQIBQAAAA==.',['皇旸']='皇旸惊霆:BAAAKgAFFAIIBAAAAA==.',['皓匀']='皓匀:BAAAKgADCgEIAgAAAA==.',['知男']='知男而上:BAAAKgAECgQICAAAAA==.',['神秘']='神秘纽头仁友:BAAAKgAFFAIIBAAAAA==.',['秋风']='秋风舞红叶:BAAAKgAECgMIAwAAAA==.',['秘法']='秘法缘缘:BAAAKgAECgIIAgAAAA==.',['空空']='空空然自自在:BAABKgAFFH8aAAMVAAYIaRYyCACeAQAVAAYIaRYyCACeAQAWAAMIKAzeHgCSAAAAAA==.',['童话']='童话小诗:BAAAKgAECgQIBAAAAA==.',['筱雪']='筱雪精灵:BAAAKgAECgYIDAAAAA==.',['红尘']='红尘素衣:BAAAKgADCgIIAwAAAA==.',['纳兰']='纳兰若雪:BAAAKgADCgcIBwAAAA==.',['绚烂']='绚烂的色彩:BAAAKgAECgEIAQAAAA==.',['绫濑']='绫濑遥:BAAAKgAFFAgIAgAAAA==.',['美丽']='美丽不冻人:BAAAKgAECggIEAAAAA==.',['至今']='至今思北:BAAAKgAECgEIAQAAAA==.',['苏荨']='苏荨:BAAAKgAFFAYIBAABKgAFFAgIBAAUAAAAAA==.',['茧茧']='茧茧:BAAAKgAECgYIDQAAAA==.',['莉娅']='莉娅:BAABKgAFFH8GAAISAAYIhhdHCwCYAQASAAYIhhdHCwCYAQAAAA==.',['菲帝']='菲帝力:BAAAKgAECgMIAwAAAA==.',['萎缩']='萎缩相当萎缩:BAAAKgAECgQICAAAAA==.',['萧邦']='萧邦:BAAAKgADCgYIBQAAAA==.',['萨滿']='萨滿祭司:BAABKgAFFH8KAAIPAAYIoxbWDgBkAQAPAAYIoxbWDgBkAQAAAA==.',['落地']='落地无法:BAAAKgADCgIIAgAAAA==.',['落英']='落英清影:BAABKgAFFH8IAAMBAAYIRx0iDACVAQABAAYIYRsiDACVAQACAAIIOQ7NOgCAAAAAAA==.',['蝶之']='蝶之影:BAABKgAECn80AAIWAAgIExzSEwBBAgAWAAgIExzSEwBBAgAAAA==.蝶之舞:BAAAKgADCggICAAAAA==.',['蝶羽']='蝶羽清影:BAAAKgAECgIIAgAAAA==.',['诗允']='诗允:BAAAKgAECgYIBgAAAA==.',['赤色']='赤色战歌:BAAAKgADCggIGAAAAA==.',['赮毕']='赮毕钵罗:BAAAKgADCgUIBQAAAA==.',['转转']='转转滚滚:BAAAKgADCggICAAAAA==.',['迷失']='迷失夜色:BAABKgAFFH8GAAISAAYIhx0KAQDdAQASAAYIhx0KAQDdAQAAAA==.',['邪恶']='邪恶之心:BAAAKgAFFAQIBAABKgAFFAYICAAJAH0fAA==.',['邪神']='邪神:BAAAKgADCgMIAwAAAA==.',['邹大']='邹大財:BAAAKgAECgUIBQAAAA==.',['铲车']='铲车人集合:BAABKgAECn8nAAICAAgIPB8oIQA4AgACAAgIPB8oIQA4AgAAAA==.',['阴霾']='阴霾暗霜:BAAAKgAECgEIAQAAAA==.',['霜之']='霜之爱殇:BAAAKgADCggICAAAAA==.',['顽闪']='顽闪:BAAAKgAECgMIAwAAAA==.',['顽风']='顽风:BAAAKgAECgEIAQAAAA==.',['颖隳']='颖隳萧萧:BAAAKgAECgcICAAAAA==.',['风寂']='风寂寞雨逍遥:BAAAKgAECggIDAAAAA==.',['风暴']='风暴之灵:BAAAKgADCgMICQAAAA==.',['飘叶']='飘叶:BAAAKgADCgMIAwAAAA==.',['飞云']='飞云之下:BAAAKgADCgEIAQAAAA==.',['饭团']='饭团刺客:BAAAKgAECgYIBgAAAA==.',['魂守']='魂守之矢:BAABKgAECn8nAAMBAAgIzB8vGAA3AgABAAgIzB8vGAA3AgATAAEIcRYYHgA2AAAAAA==.',['鹅浪']='鹅浪古:BAAAKgADCggICAAAAA==.',['黑帅']='黑帅壹号:BAAAKgADCggICAAAAA==.',['黑暗']='黑暗使者:BAAAKgAECgQIBAAAAA==.',['龙骑']='龙骑士:BAAAKgADCgMICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end