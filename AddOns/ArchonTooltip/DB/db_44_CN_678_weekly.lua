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
 local lookup = {'Paladin-Holy','Paladin-Protection','Paladin-Retribution','DeathKnight-Frost','Druid-Restoration','Druid-Guardian','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Priest-Holy','DemonHunter-Havoc','Hunter-BeastMastery','Rogue-Assassination','DemonHunter-Vengeance','Warrior-Fury','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Unholy','Rogue-Outlaw','Rogue-Subtlety','Warrior-Protection','Druid-Feral','Evoker-Augmentation','Hunter-Marksmanship','Mage-Arcane','Shaman-Enhancement','Hunter-Survival','Warrior-Arms','Priest-Shadow','Unknown-Unknown','Monk-Windwalker','Mage-Frost',}; local provider = {region='CN',realm='德拉诺',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acrobat:BAAALAADCgIIAgAAAA==.',Al='Alita:BAACLAAFFH8zAAIBAAYIFRHADwCKAQABAAYIFRHADwCKAQAsAAQKfzkAAgEACAhKHawRAIUCAAEACAhKHawRAIUCAAAA.',Am='Ametharan:BAAALAAECgYIDgAAAA==.',An='Andy:BAABLAAFFH8IAAMCAAIIRQt9IAArAAACAAIIRQt9IAArAAADAAIILgFMggAmAAAAAA==.Andysky:BAABLAAFFH8FAAIEAAIINAdIigBBAAAEAAIINAdIigBBAAAAAA==.Andysweet:BAAALAAFFAIIAgAAAA==.Andywind:BAABLAAECn8YAAMCAAYI5BaPGABPAQACAAYI5BaPGABPAQADAAYIsQbFmwDIAAAAAA==.',Ap='Aphrodite:BAAALAAECgYIEQAAAA==.',As='Astraia:BAAALAAECgQIBAAAAA==.',Au='Augenste:BAAALAAECgQIBAAAAA==.',Ba='Baleme:BAAALAAECgYIBgAAAA==.',Be='Beatsangel:BAAALAADCgIIAgAAAA==.',Da='Darknessun:BAAALAAECgQIBwAAAA==.Davinci:BAAALAADCgMIAwAAAA==.',De='Demeter:BAACLAAFFH8zAAIFAAYI3hzaDADrAQAFAAYI3hzaDADrAQAsAAQKf0EAAwUACAiLJIMHACYDAAUACAiLJIMHACYDAAYAAgjMIhcYAMoAAAAA.',Di='Diurd:BAABLAAECn8XAAMFAAgIlxP8XwBzAQAFAAgIlxP8XwBzAQAHAAYIXg2LZQAqAQAAAA==.',Dk='Dkily:BAABLAAECn8WAAIEAAYIdxt8kgDbAQAEAAYIdxt8kgDbAQAAAA==.',Dr='Druidical:BAABLAAFFH8MAAIFAAIIKB0BTwBVAAAFAAIIKB0BTwBVAAAAAA==.',En='Engrave:BAAALAADCgMIAwAAAA==.',Gl='Gloss:BAAALAADCgYIBgAAAA==.',Go='Goffy:BAABLAAFFH8xAAIDAAYIux0yEQC9AQADAAYIux0yEQC9AQAAAA==.Gogo:BAAALAAECggICAAAAA==.',Ku='Kurokyà:BAAALAAECgIIAgAAAA==.',Le='Lee:BAABLAAFFH8GAAIIAAIITQtqZABWAAAIAAIITQtqZABWAAAAAA==.Leona:BAAALAAFFAIIBAAAAA==.',Li='Liecc:BAABLAAFFH8IAAIEAAIIEBjfUQCgAAAEAAIIEBjfUQCgAAAAAA==.Lieoo:BAAALAAFFAIIBAAAAA==.',Lq='Lqwjb:BAAALAADCgIIAgAAAA==.',Mi='Miria:BAABLAAFFH8OAAIDAAIIrSKIKwCyAAADAAIIrSKIKwCyAAAAAA==.',Mo='Moonvirgo:BAABLAAFFH8GAAIBAAIItAwYIwB/AAABAAIItAwYIwB/AAAAAA==.',Mu='Murderous:BAABLAAFFH8GAAIDAAIIUQRxewA1AAADAAIIUQRxewA1AAAAAA==.',Ne='Newwsbe:BAAALAADCgYIBgAAAA==.',Ov='Overtaunt:BAAALAAECgQIBAAAAA==.',Ra='Rapeter:BAABLAAFFH8kAAIJAAYI4x8vDwDJAQAJAAYI4x8vDwDJAQAAAA==.',Ri='Ringsong:BAAALAADCggICAAAAA==.',Sm='Smokingguns:BAAALAAECgQIBAAAAA==.',Sp='Spider:BAAALAAECggICAAAAA==.',Th='Theweak:BAABLAAECn8WAAIEAAgIrx0UUQBWAgAEAAgIrx0UUQBWAgAAAA==.',Tr='Truizz:BAAALAADCgUIBgAAAA==.',Ve='Vengeancecal:BAAALAADCggICAAAAA==.Venividivici:BAAALAADCgQIBAAAAA==.',Vo='Vorazun:BAAALAAECgIIAgAAAA==.',Wh='Whysoserious:BAAALAAECgQIBAAAAA==.',Xc='Xcjchishi:BAAALAAECgYIEgAAAA==.',Yy='Yyxx:BAABLAAECn8fAAIKAAgImAQjcwAjAQAKAAgImAQjcwAjAQAAAA==.',Ze='Zeromissyou:BAAALAAECggIDgAAAA==.',['一丢']='一丢丢儿:BAAALAAECgYIDAAAAA==.',['一个']='一个小猎手:BAABLAAFFH8IAAILAAII+iO+IwDUAAALAAII+iO+IwDUAAAAAA==.',['一夜']='一夜:BAAALAADCggICAAAAA==.',['一杯']='一杯浓茶:BAAALAAECgMIBQAAAA==.',['一王']='一王灬者一:BAAALAAECgYIDAAAAA==.',['一石']='一石上流一:BAAALAAECgYIDAAAAA==.',['三指']='三指:BAAALAAECgQICgAAAA==.',['三月']='三月雨纷飞:BAAALAADCgYICQAAAA==.',['三猪']='三猪猪:BAAALAAECgMIAwAAAA==.',['下辈']='下辈子不爱你:BAAALAAECgYIBwAAAA==.',['不听']='不听不听:BAAALAAECgQIBAAAAA==.',['不玩']='不玩望天涌:BAAALAAFFAMIAwAAAA==.',['不要']='不要死小强:BAACLAAFFH8IAAIIAAIIHQ6eYABbAAAIAAIIHQ6eYABbAAAsAAQKfx8AAggACAiDGJIdAAoCAAgACAiDGJIdAAoCAAAA.',['不讲']='不讲珷德:BAABLAAFFH8GAAIFAAYIRBWuBQDPAQAFAAYIRBWuBQDPAQAAAA==.',['丧坤']='丧坤:BAAALAADCgQIBAAAAA==.',['丨为']='丨为了脸萌:BAAALAAECgQIBAAAAA==.',['丨喪']='丨喪彪丨:BAAALAADCgMIAwAAAA==.',['丨地']='丨地痞丨:BAAALAAECgYIBgAAAA==.',['丨小']='丨小浣熊丨:BAABLAAFFH8HAAIMAAMIvR0SZACoAAAMAAMIvR0SZACoAAAAAA==.',['丨欧']='丨欧莱雅丨:BAACLAAFFH8kAAMDAAYIFh2zDgDPAQADAAYIFh2zDgDPAQABAAIItApBIgCCAAAsAAQKfx8AAwMACAgdH8lEAG4CAAMACAgdH8lEAG4CAAEACAjWDzAxAKkBAAAA.',['丨雷']='丨雷三炮丨:BAAALAAECgYIBgAAAA==.',['中泰']='中泰百货第一:BAABLAAFFH8OAAIMAAYIJAc4TgAVAQAMAAYIJAc4TgAVAQAAAA==.',['丰聪']='丰聪耳神子:BAAALAAECgUIBwAAAA==.',['丶侵']='丶侵略如火丶:BAAALAAECgEIAQAAAA==.',['丶杀']='丶杀戮盛宴:BAABLAAECn8UAAINAAcIQxmGIgAEAgANAAcIQxmGIgAEAgAAAA==.',['丶祈']='丶祈:BAABLAAFFH8GAAIKAAYIFBmwFQClAQAKAAYIFBmwFQClAQAAAA==.',['丶聚']='丶聚散流沙:BAAALAADCggIEwAAAA==.',['丶释']='丶释迦:BAAALAAECgEIAQAAAA==.',['为你']='为你熬翔:BAAALAAECggICAAAAA==.',['丿烟']='丿烟雨任平生:BAAALAAECgMIAwAAAA==.',['丿神']='丿神裂火织:BAAALAAFFAIIAgAAAA==.',['丿蓦']='丿蓦然回首丶:BAAALAAFFAIIBAAAAA==.',['久久']='久久炎:BAABLAAECn8VAAMOAAgILwxQOQAHAQAOAAcISAlQOQAHAQALAAQIKw/8+QD0AAAAAA==.久久牧士:BAAALAAECgcICAAAAA==.',['么木']='么木阿:BAACLAAFFH8KAAIKAAMITgySMQCkAAAKAAMITgySMQCkAAAsAAQKfxgAAgoABwiYFYokAJABAAoABwiYFYokAJABAAAA.',['之裤']='之裤他跌:BAAALAAECgQIBAAAAA==.',['乐居']='乐居:BAAALAAECgYICQAAAA==.',['九五']='九五:BAABLAAFFH8QAAIEAAMI3hgwLADoAAAEAAMI3hgwLADoAAAAAA==.',['九幽']='九幽挽歌:BAAALAAECgQIBAAAAA==.',['乱世']='乱世中女:BAAALAAECgIIAgAAAA==.',['乱了']='乱了头发:BAAALAADCgMIAwAAAA==.',['二向']='二向箔:BAAALAAFFAIIAgAAAA==.',['二蛋']='二蛋的拳头:BAAALAAECgIIAgAAAA==.',['云中']='云中丶飞:BAAALAADCggICAAAAA==.',['五七']='五七战:BAAALAADCgYIBgAAAA==.',['亦寒']='亦寒紫:BAAALAAFFAIIAgAAAA==.',['亦言']='亦言:BAAALAAECggIDgAAAA==.',['人中']='人中灬吕布:BAAALAAFFAIIAgAAAA==.',['人见']='人见人吐:BAAALAAECgYIBwAAAA==.',['仒小']='仒小嘿嘿:BAAALAADCgEIAQAAAA==.',['仓井']='仓井满:BAAALAAFFAIIBAAAAA==.',['以舟']='以舟:BAAALAAECgYIBgAAAA==.',['伊利']='伊利弾:BAAALAAECgQICAAAAA==.',['伊瑞']='伊瑞尔灬主教:BAABLAAFFH8MAAMBAAIIqyDIHgCrAAABAAIIqyDIHgCrAAACAAIIhBfvGAA6AAAAAA==.',['传承']='传承护甲一号:BAAALAAECgYIDAAAAA==.',['伽喱']='伽喱:BAAALAAECgYIBgAAAA==.',['佟丽']='佟丽娅:BAAALAADCgcIBwAAAA==.',['你没']='你没钱:BAABLAAFFH8KAAIEAAIIUBuzRACsAAAEAAIIUBuzRACsAAAAAA==.',['你的']='你的德:BAAALAADCgUIBQAAAA==.',['你赢']='你赢得:BAAALAAECgYICwAAAA==.',['佩佩']='佩佩的小刀:BAAALAAECgYIBgAAAA==.',['侵掠']='侵掠如火:BAAALAAECgYIBgAAAA==.',['信仰']='信仰与荣耀:BAAALAAECgYIBgAAAA==.',['倚剑']='倚剑挽流沙:BAAALAAFFAQIAgAAAA==.',['偶豆']='偶豆豆喲:BAABLAAFFH8FAAIPAAMI4QkPPACAAAAPAAMI4QkPPACAAAAAAA==.',['傲慢']='傲慢骑骑:BAAALAAECgIIAgAAAA==.',['僧龍']='僧龍大俠:BAAALAAECggIBQAAAA==.',['元气']='元气满满:BAAALAAFFAIIAgAAAA==.',['先定']='先定个小目标:BAACLAAFFH8RAAIOAAMICA5FCwCbAAAOAAMICA5FCwCbAAAsAAQKfxQAAg4ABwj5FGgfAL8BAA4ABwj5FGgfAL8BAAAA.',['光影']='光影之灵:BAAALAADCgIIAgAAAA==.光影迷殇:BAAALAAFFAIIBAAAAA==.',['免疫']='免疫节珲:BAABLAAFFH8FAAMQAAUIuwTDEwBEAAARAAQIYQTTRgCpAAAQAAEIIgbDEwBEAAAAAA==.',['其徐']='其徐如林:BAAALAAECgEIAQAAAA==.',['其疾']='其疾如風:BAAALAAECgYIBwAAAA==.',['养乐']='养乐多:BAAALAAECggIBAAAAA==.',['兽闪']='兽闪电:BAAALAADCgUIBQAAAA==.',['冫哦']='冫哦吼吼:BAABLAAECn8eAAIPAAgIhRjbHAACAgAPAAgIhRjbHAACAgAAAA==.',['冫小']='冫小嘿嘿:BAABLAAFFH8GAAIBAAII9xmNIQCWAAABAAII9xmNIQCWAAAAAA==.',['冰冰']='冰冰忍:BAAALAAECgQICQAAAA==.',['冰凉']='冰凉丶:BAACLAAFFH8MAAIPAAIIvh5UQQBXAAAPAAIIvh5UQQBXAAAsAAQKfygAAg8ACAiTIlIJALYCAA8ACAiTIlIJALYCAAAA.',['冰火']='冰火忍者:BAAALAAFFAIIAgAAAA==.',['冰爽']='冰爽乃茶:BAAALAAECgEIAQAAAA==.',['冰银']='冰银骑士:BAAALAAECgIIAgAAAA==.',['决战']='决战宣武门:BAAALAADCgMIAwAAAA==.',['冷语']='冷语深痕:BAABLAAFFH8KAAISAAIICRFHEwByAAASAAIICRFHEwByAAAAAA==.',['凄凉']='凄凉的故事丶:BAAALAADCgQIBAAAAA==.',['凉先']='凉先生:BAAALAADCgYIBgAAAA==.',['凉生']='凉生初雨:BAAALAAECgYIDgAAAA==.',['凝香']='凝香筱筱:BAACLAAFFH8IAAITAAQI6gO5EACsAAATAAQI6gO5EACsAAAsAAQKfxcAAxMACAiHH88OAH0CABMACAiHH88OAH0CABQABgjgEpUSABsBAAAA.',['刃牙']='刃牙:BAAALAADCgcIBwAAAA==.',['勇者']='勇者胜:BAAALAAECgMIAwAAAA==.',['動如']='動如雷霆:BAAALAAECgUIBQAAAA==.',['北大']='北大街一枝花:BAAALAADCgUIBQAAAA==.',['北辰']='北辰明:BAAALAAECgUIBQAAAA==.',['医疗']='医疗圣者:BAAALAADCgcIBwAAAA==.',['十年']='十年彩虹:BAAALAAFFAIIBAAAAA==.',['千里']='千里燎烽火:BAABLAAFFH8TAAIEAAYIXRHUMQB0AQAEAAYIXRHUMQB0AQAAAA==.',['午夜']='午夜销魂:BAAALAADCgEIAQAAAA==.',['单名']='单名一个源:BAAALAAECgcIDwAAAA==.',['南倪']='南倪:BAAALAAFFAIIAgAAAA==.',['南尼']='南尼:BAAALAAECgYIEgAAAA==.',['南方']='南方记忆:BAAALAAECgIIAgAAAA==.',['南旎']='南旎:BAABLAAFFH8IAAIEAAII+QKplwBcAAAEAAII+QKplwBcAAAAAA==.',['南泥']='南泥:BAAALAAFFAIIAgAAAA==.',['南逆']='南逆:BAAALAAFFAIIAgAAAA==.',['卡加']='卡加:BAAALAAFFAEIAQAAAA==.',['卫三']='卫三爷:BAAALAAFFAIIBAAAAA==.',['双刀']='双刀狼:BAABLAAECn8ZAAMLAAcIvBZCjwCpAQALAAcIvBZCjwCpAQAOAAIIAA2GKABVAAAAAA==.',['叫兽']='叫兽的贱解:BAABLAAECn8cAAMVAAYI8xaqJACYAQAVAAYIAhSqJACYAQAEAAYIGxYxVgBGAQAAAA==.',['史帝']='史帝芬或斤:BAAALAAECgYIBwAAAA==.',['右转']='右转:BAAALAAECgUIBQAAAA==.',['合欢']='合欢冢:BAAALAAECgYICQAAAA==.',['名字']='名字不确定:BAAALAADCgMIAwAAAA==.',['君央']='君央灬:BAABLAAFFH8LAAMWAAUIbgPRAgDMAAAWAAUIbgPRAgDMAAAXAAII7wNnGAAwAAAAAA==.',['吟冰']='吟冰火凤:BAAALAADCgIIAgAAAA==.',['含嘴']='含嘴里别说话:BAAALAAECgYIDAAAAA==.',['吾儿']='吾儿快起:BAAALAAECgYIBgAAAA==.',['呆在']='呆在你身边:BAAALAADCgYICgAAAA==.',['咆哮']='咆哮的鹌鹑:BAABLAAFFH8TAAIHAAYI8hdaEABqAQAHAAYI8hdaEABqAQAAAA==.',['哈迪']='哈迪斯的自由:BAABLAAFFH8FAAIEAAUIHxRYRAApAQAEAAUIHxRYRAApAQAAAA==.',['哥小']='哥小阳灬:BAAALAAECgIIAgAAAA==.',['唐丶']='唐丶吉坷德:BAACLAAFFH8JAAICAAMIFw3BCwC4AAACAAMIFw3BCwC4AAAsAAQKfycAAgIACAhfHH4TAGECAAIACAhfHH4TAGECAAAA.',['喂丨']='喂丨嘿嘿:BAABLAAECn8hAAISAAgIuQYhLAAbAQASAAgIuQYhLAAbAQAAAA==.',['嗜血']='嗜血灬残阳:BAAALAAECgYIBgAAAA==.',['嗦爾']='嗦爾:BAAALAAECgYIBgAAAA==.',['四夕']='四夕若若:BAAALAADCgIIAgAAAA==.',['回眸']='回眸:BAAALAAFFAMIAwAAAA==.',['回血']='回血王:BAAALAADCggICAAAAA==.',['国士']='国士无双:BAABLAAECn8XAAIEAAYI7CHsNAClAQAEAAYI7CHsNAClAQAAAA==.',['圆咕']='圆咕咕噜:BAAALAAFFAIIBAAAAA==.',['圆圆']='圆圆爱球球:BAAALAAECgYICQAAAA==.',['圆魄']='圆魄上寒空:BAABLAAECn8UAAMCAAgIEwHWQQA9AAACAAYIVQHWQQA9AAABAAgIMQB3SgAEAAAAAA==.',['土灵']='土灵粗又硬:BAAALAADCgYIBgAAAA==.',['圣光']='圣光凤梨:BAABLAAFFH8GAAIDAAYIFgjhRwB7AAADAAYIFgjhRwB7AAAAAA==.圣光天赐:BAAALAAECgYIDAAAAA==.',['块来']='块来宝贝:BAACLAAFFH8GAAIYAAMIfgh+FQCnAAAYAAMIfgh+FQCnAAAsAAQKfyYAAhgACAgGFuUmAAYCABgACAgGFuUmAAYCAAAA.',['埃辛']='埃辛诺斯戰刃:BAABLAAECn8dAAILAAgIaCPUFAAYAwALAAgIaCPUFAAYAwAAAA==.',['堕落']='堕落灬晓:BAAALAAECgYICQAAAA==.',['墨丶']='墨丶水:BAAALAAECgYIDAAAAA==.',['墨染']='墨染悠幽:BAAALAAECgYIBgAAAA==.',['墨殇']='墨殇:BAABLAAFFH8GAAMNAAIIZhZVGQBOAAANAAIIZhZVGQBOAAAXAAEI7AH1GwAAAAAAAA==.',['墨莎']='墨莎菇凉:BAABLAAFFH8IAAIZAAIIaRrhCwChAAAZAAIIaRrhCwChAAAAAA==.',['墮落']='墮落的騎士:BAAALAAFFAIIBAAAAA==.',['壹辈']='壹辈子丶嚯嚯:BAAALAAECgUICgAAAA==.',['壹骑']='壹骑当万:BAAALAAECgYICgAAAA==.',['夏昆']='夏昆吾:BAAALAAECggICAAAAA==.',['外卖']='外卖:BAAALAAECgYIDgAAAA==.外卖员:BAAALAAECgQIBAAAAA==.',['夜幕']='夜幕下的微光:BAAALAAECgEIAQAAAA==.',['夜月']='夜月杀:BAAALAAFFAIIBAAAAA==.',['大哥']='大哥我真抽了:BAAALAADCgMIAwAAAA==.',['大地']='大地传说:BAAALAADCgMIAwAAAA==.',['大城']='大城小垣:BAAALAAECgMIBAAAAA==.',['大春']='大春丽:BAAALAAECgYIDQAAAA==.',['大波']='大波浪:BAAALAAECgMIBgAAAA==.',['大猛']='大猛战丶:BAAALAADCgIIAgAAAA==.',['大闪']='大闪电:BAABLAAECn8VAAIBAAcILAljRwA8AQABAAcILAljRwA8AQAAAA==.',['大黑']='大黑手噙獣:BAAALAAECgYIEAAAAA==.',['天情']='天情悟箭声:BAAALAAECgYIBgAAAA==.',['天才']='天才猫猫:BAAALAAECgUIBQAAAA==.',['天野']='天野:BAAALAAECgYIBgAAAA==.',['奎克']='奎克:BAABLAAFFH8GAAMBAAIIXxVpJQB3AAABAAIIXxVpJQB3AAADAAIIwAtxfQAzAAAAAA==.',['奢华']='奢华灬低调:BAAALAAECgYIBgAAAA==.',['女施']='女施主使不得:BAAALAAECgYIBgAAAA==.',['如果']='如果奶:BAAALAAECgYIBgAAAA==.',['妹妹']='妹妹不高兴:BAABLAAECn8mAAIDAAgIxxueOQCPAgADAAgIxxueOQCPAgAAAA==.',['姑奶']='姑奶奶:BAAALAAECgEIAQAAAA==.',['嫣然']='嫣然一笑:BAAALAAECgYIBgAAAA==.嫣然暮光:BAAALAAECgYIEAAAAA==.',['孝感']='孝感王祖贤:BAAALAADCggICAAAAA==.',['孤芳']='孤芳自赏:BAAALAADCgcIBwAAAA==.',['孵烧']='孵烧鹅:BAABLAAECn8ZAAQGAAcImiBfBgD8AQAGAAYIuiJfBgD8AQAZAAcICg84EgAQAQAFAAQI0hIsTQDgAAAAAA==.',['宁姚']='宁姚:BAAALAAFFAIIAgAAAA==.',['宅字']='宅字当头:BAABLAAFFH8HAAIGAAMIqQfyBQCPAAAGAAMIqQfyBQCPAAAAAA==.',['宇宙']='宇宙第一蝾螈:BAAALAAECgEIAQAAAA==.',['安东']='安东大将军:BAABLAAFFH8PAAIIAAUIMxdKLAAGAQAIAAUIMxdKLAAGAQABLAAFFAgICgAEAJ8VAA==.',['安琪']='安琪儿乐乐:BAAALAAECgEIAQAAAA==.',['宝贝']='宝贝喵:BAABLAAFFH8GAAIEAAYINBecKACUAQAEAAYINBecKACUAQAAAA==.',['宮下']='宮下玲奈:BAABLAAFFH8IAAIaAAgIARtyAgAoAgAaAAgIARtyAgAoAgAAAA==.',['家佳']='家佳康:BAAALAAECgUIBQAAAA==.',['寂寞']='寂寞狆哋樱花:BAAALAAECgUICAAAAA==.',['寒跑']='寒跑跑:BAAALAADCgcICQAAAA==.',['寸心']='寸心尽焚:BAAALAAECgYICAAAAA==.',['导师']='导师丿乌瑟尔:BAABLAAFFH8GAAIDAAIITh6EVQBMAAADAAIITh6EVQBMAAAAAA==.',['封面']='封面人物熙:BAAALAAECgYIBgAAAA==.封面人物膧:BAAALAAFFAEIAQAAAA==.',['小坦']='小坦克:BAAALAAECgQIBAAAAA==.',['小子']='小子放学别走:BAAALAADCgYIBgAAAA==.小子放学单挑:BAAALAADCgIIAgAAAA==.',['小导']='小导演:BAAALAAECgYICQABLAAFFAgICgAEAJ8VAA==.',['小小']='小小崽:BAAALAAFFAIIAgAAAA==.',['小德']='小德不晓得:BAAALAAECgYIEQAAAA==.',['小流']='小流水:BAAALAAECgUIBgAAAA==.',['小璿']='小璿璿:BAAALAADCgQIBAAAAA==.',['小男']='小男孩和胖子:BAAALAAECgIIAgAAAA==.',['小筱']='小筱铄:BAABLAAFFH8KAAMHAAII+SH5FQCxAAAHAAII+SH5FQCxAAAZAAEIhhW7EgBTAAAAAA==.',['小虎']='小虎:BAAALAADCggICAAAAA==.',['小虫']='小虫虫:BAAALAADCggICAAAAA==.',['小郡']='小郡肝串串:BAAALAAECgYICwAAAA==.小郡肝肉丸:BAAALAADCgYIBgAAAA==.',['小阳']='小阳哥灬:BAAALAAECgEIAQAAAA==.',['小风']='小风残月:BAAALAAECgYIBgAAAA==.',['小飞']='小飞机小火车:BAAALAAFFAIIAgAAAA==.',['少年']='少年机器猫:BAAALAAECgQIBAAAAA==.',['尛灬']='尛灬酒窩:BAAALAAECggICAAAAA==.',['尛酒']='尛酒窩:BAAALAAECggIDwABLAAFFAYIEgALAO0QAA==.',['就差']='就差一丢丢儿:BAABLAAFFH8CAAIEAAIIbR6DcABSAAAEAAIIbR6DcABSAAAAAA==.',['屮萌']='屮萌德:BAAALAAECgYIBgAAAA==.',['山里']='山里的二营长:BAAALAAECgYIEgAAAA==.山里的圆圆:BAACLAAFFH8LAAIBAAIIKiFpEwDEAAABAAIIKiFpEwDEAAAsAAQKfxsAAwEABwiBGoQWAKQBAAEABwiBGoQWAKQBAAMAAwjVEQpBAa4AAAAA.山里的尛伙:BAACLAAFFH8KAAILAAIILBJRUgBHAAALAAIILBJRUgBHAAAsAAQKfxQAAgsABgjSHA1xAOMBAAsABgjSHA1xAOMBAAAA.山里的尛红人:BAACLAAFFH8KAAMMAAIIKhxZTACYAAAMAAIIKhxZTACYAAAbAAEIUA5CNgA9AAAsAAQKfxkAAwwABgirI2pJAE4CAAwABgirI2pJAE4CABsAAggSGBaeAHsAAAAA.山里的法爺:BAABLAAFFH8JAAIcAAYI8h/6BQBJAgAcAAYI8h/6BQBJAgAAAA==.山里的老登:BAAALAAECgUIBgAAAA==.',['岸边']='岸边的狮子:BAAALAAFFAIIAgAAAA==.',['左转']='左转:BAAALAAECgYICwAAAA==.',['市杵']='市杵宍姬命:BAAALAAECgcIEAAAAA==.',['帅气']='帅气逼人:BAAALAAECgIIAwAAAA==.',['希尔']='希尔梅里亚:BAAALAAECgUICwAAAA==.',['希灬']='希灬冀:BAABLAAFFH8GAAIMAAYIpADAwgAWAAAMAAYIpADAwgAWAAAAAA==.希灬锦:BAAALAAECggICAAAAA==.',['帕奇']='帕奇维克:BAAALAAFFAIIAwAAAA==.',['帝弑']='帝弑天:BAABLAAFFH8GAAIYAAIIEAMBOgAjAAAYAAIIEAMBOgAjAAAAAA==.',['帝獄']='帝獄孤狼:BAABLAAFFH8bAAIEAAUIBBXtQQAzAQAEAAUIBBXtQQAzAQAAAA==.',['幻月']='幻月灬:BAABLAAFFH8KAAIDAAYI8A6aIgBYAQADAAYI8A6aIgBYAQAAAA==.',['幽冥']='幽冥之霜:BAABLAAFFH8HAAMSAAIIQAM5HgAoAAAEAAIIJANooAA1AAASAAEIHAQ5HgAoAAAAAA==.幽冥寒霜:BAABLAAFFH8GAAICAAIIzAghIgAnAAACAAIIzAghIgAnAAAAAA==.幽冥血神:BAAALAAECgIIAgAAAA==.幽冥魔神:BAABLAAFFH8JAAMEAAIICA0xkgA9AAAEAAIImQYxkgA9AAASAAIIVwz8HAAtAAAAAA==.',['库夫']='库夫林:BAAALAADCgYIBwAAAA==.',['库帕']='库帕城堡:BAABLAAFFH8IAAMdAAIIqh/1BACxAAAdAAIIqh/1BACxAAAJAAEI6gycPgBCAAAAAA==.',['康康']='康康:BAAALAAECgYIBgAAAA==.',['开心']='开心大西瓜:BAAALAAECgIIAwAAAA==.',['当我']='当我脏时爱我:BAAALAAECgYIBwAAAA==.',['彼岸']='彼岸華:BAAALAADCgQIBAAAAA==.',['很傻']='很傻很呆萌:BAAALAAECggICAAAAA==.',['微灬']='微灬凉:BAACLAAFFH8hAAIRAAUIWh1FMQBSAQARAAUIWh1FMQBSAQAsAAQKfyoAAxEACAjSHk4aAOsCABEACAjSHk4aAOsCABAAAQjAHYyMAFMAAAAA.',['德尔']='德尔皮耶罗:BAAALAADCgMIAwAAAA==.',['心比']='心比眼瞎:BAAALAADCgYIBgAAAA==.',['心静']='心静抚涟:BAAALAADCggICAAAAA==.',['忽必']='忽必烈烈:BAAALAADCgMIAwAAAA==.',['怀庆']='怀庆:BAACLAAFFH8KAAMDAAIIUQaneQA3AAADAAIIUQaneQA3AAACAAIIswKuJAAbAAAsAAQKfxQAAwIABgjJFFYgAA4BAAMABgitDq7uAEUBAAIABgg5E1YgAA4BAAAA.',['怪味']='怪味叔叔:BAAALAAECgYIEQAAAA==.',['恐怖']='恐怖风车人:BAAALAAFFAIIAgAAAA==.',['息忆']='息忆:BAAALAADCgcICwAAAA==.',['恶魔']='恶魔女猎手:BAAALAADCgIIAgAAAA==.',['悾惧']='悾惧利刃:BAAALAAFFAIIAgAAAA==.',['情歌']='情歌唱晚:BAABLAAFFH8GAAIMAAYIZwobaACVAAAMAAYIZwobaACVAAAAAA==.',['慕月']='慕月清风:BAAALAAECgcIDgAAAA==.',['懂音']='懂音乐的熊:BAAALAAECgEIAQAAAA==.',['懒信']='懒信仰:BAAALAADCgYIBgAAAA==.',['懒得']='懒得孤独:BAAALAAECgYIDAAAAA==.懒得开门:BAAALAAECgEIAQAAAA==.',['懒猎']='懒猎手:BAAALAADCgMIAwAAAA==.',['懒鹌']='懒鹌鹑:BAAALAADCgQIBAAAAA==.',['我放']='我放了个屁就:BAAALAAFFAIIAwAAAA==.',['我有']='我有钱:BAABLAAFFH8GAAIJAAIItQjWOABtAAAJAAIItQjWOABtAAAAAA==.',['我爱']='我爱宝蓝:BAABLAAFFH8IAAILAAgI9BFACABFAgALAAgI9BFACABFAgAAAA==.',['我的']='我的小钢炮:BAABLAAFFH8KAAIMAAYIDxoABwARAgAMAAYIDxoABwARAgAAAA==.',['战帝']='战帝紫霄:BAAALAADCggICAAAAA==.战帝龙渊:BAAALAAECgYIBwAAAA==.',['战狼']='战狼六号:BAAALAADCgUIBQAAAA==.',['戰師']='戰師:BAAALAAECgYIBgAAAA==.',['托桃']='托桃李天王:BAAALAAECgIIAgAAAA==.',['执剑']='执剑开天门:BAAALAAECgEIAQAAAA==.',['扶瑶']='扶瑶九霄:BAAALAAFFAMIAwAAAA==.',['拟墨']='拟墨画扇:BAAALAAECgcIEwAAAA==.',['指南']='指南:BAAALAAECggIDwAAAA==.',['接近']='接近神的人:BAAALAAECgMIAwAAAA==.',['摇摆']='摇摆的熊猫:BAAALAADCgYIBgAAAA==.',['摇滚']='摇滚德:BAAALAAECgYIEQAAAA==.',['撒拉']='撒拉塔斯:BAAALAAECgYIBgAAAA==.',['撒汤']='撒汤小笼包:BAACLAAFFH8kAAQEAAYIdBF8NwBdAQAEAAYIYg18NwBdAQASAAYICA2mDQAuAQAVAAIITgf7DACMAAAsAAQKfyMABBIACAjmGwYbAL0BABIACAjXEQYbAL0BABUABggQG7YlAJABAAQABQimG0bVAHwBAAAA.',['擒兽']='擒兽:BAABLAAFFH8JAAIMAAYIdA+WSQAlAQAMAAYIdA+WSQAlAQAAAA==.',['放肆']='放肆丨为红颜:BAACLAAFFH8HAAIMAAYIzw3DTQAWAQAMAAYIzw3DTQAWAQAsAAQKfxgABAwACAhpHq1KALEBAAwACAhuHK1KALEBABsACAgiEqZTAGgBAB4AAQgEGjMlAD0AAAAA.',['教育']='教育网专区:BAACLAAFFH8cAAQfAAUIPh54AgDAAAAPAAUIPh68FwAHAQAfAAII3R94AgDAAAAYAAEIdA4WPQAAAAAsAAQKfzEABA8ACAh5JZ0LAJsCAB8ACAjFIEYGAKMCAA8ACAgRJZ0LAJsCABgABgjwFcg+AIkBAAAA.教育网专区噗:BAAALAAFFAIIBAABLAAFFAUIHAAfAD4eAA==.',['数尸']='数尸爸爸:BAAALAAFFAIIAgAAAA==.',['文艺']='文艺朮士:BAAALAAFFAIIBAABLAAFFAgIHQAcACEhAA==.',['文雀']='文雀:BAAALAAECgYIEAAAAA==.',['斑大']='斑大人:BAAALAAFFAIIAgAAAA==.',['斧子']='斧子大爷:BAAALAAECgYIEAAAAA==.',['新武']='新武士:BAAALAAECgYIBgAAAA==.',['旁边']='旁边有雪碧:BAAALAAECgQIBAAAAA==.',['无才']='无才便是:BAABLAAFFH8GAAIFAAIILBy1IAChAAAFAAIILBy1IAChAAAAAA==.',['无敌']='无敌:BAAALAAECgYIEQAAAA==.',['无碍']='无碍:BAABLAAFFH8IAAIgAAgIxhjvBAAjAgAgAAgIxhjvBAAjAgAAAA==.',['无量']='无量氵天尊:BAAALAAFFAIIAgAAAA==.',['无间']='无间不摧:BAAALAAECgUIBQAAAA==.',['既宅']='既宅又腐:BAAALAADCgMIAwAAAA==.',['早饭']='早饭吃的啥丶:BAAALAAECgIIAgABLAAFFAIIBAAhAAAAAA==.',['时光']='时光逝少年:BAAALAAECgYIBgAAAA==.',['时辰']='时辰:BAAALAAECgEIAQAAAA==.',['明月']='明月照大江:BAAALAAECgYICAAAAA==.',['星辰']='星辰幻影:BAAALAAECgQIBAAAAA==.',['春冰']='春冰:BAAALAAECgYIDQAAAA==.',['春秀']='春秀路一哥:BAAALAADCgYIBgAAAA==.',['春风']='春风随我:BAAALAAFFAIIAwAAAA==.',['晨雀']='晨雀:BAACLAAFFH8UAAIIAAQI9RVnLwDyAAAIAAQI9RVnLwDyAAAsAAQKfxYAAggACAjGGpBFAA4CAAgACAjGGpBFAA4CAAAA.',['暗乂']='暗乂天使:BAAALAAECgYIBgAAAA==.',['暗之']='暗之右手:BAAALAAECgcIBAAAAA==.',['暗炉']='暗炉烤地瓜:BAAALAAECgYIDwAAAA==.',['暴躁']='暴躁前任小陈:BAABLAAFFH8GAAIEAAYIUwZ7SgAJAQAEAAYIUwZ7SgAJAQAAAA==.',['曾经']='曾经的钢铁侠:BAAALAADCgQIBAAAAA==.',['最后']='最后一次优雅:BAAALAAECgYIBgAAAA==.',['月中']='月中眠:BAAALAAECgQIBAAAAA==.',['月夜']='月夜亡璎:BAAALAAECgUIBwAAAA==.',['月影']='月影残空:BAAALAAECgYIEQAAAA==.月影芳踪:BAAALAADCgcIBwAAAA==.',['月野']='月野兔:BAAALAADCgYIBgAAAA==.',['有四']='有四个棍子:BAABLAAFFH8JAAIIAAIIlRNUVQBwAAAIAAIIlRNUVQBwAAAAAA==.',['期待']='期待依旧空白:BAAALAAECggICAAAAA==.',['木子']='木子芃萱:BAAALAAECgYIDgAAAA==.',['未梦']='未梦:BAAALAAECgYIBgAAAA==.',['机械']='机械之心:BAAALAAECgUIBQAAAA==.',['李蜀']='李蜀师:BAAALAADCgQIBAAAAA==.',['杨崽']='杨崽儿:BAAALAAFFAIIAgAAAA==.杨崽尔:BAAALAAECgYIDAAAAA==.',['杨教']='杨教授之吻:BAABLAAFFH8IAAIIAAIIrhSYRgB2AAAIAAIIrhSYRgB2AAAAAA==.',['果丹']='果丹皮:BAAALAADCgMIAwAAAA==.',['枭兽']='枭兽大火球:BAAALAAECgYIBgAAAA==.',['枯荣']='枯荣残月:BAAALAAECgIIAgAAAA==.',['柒月']='柒月:BAAALAAECgIIAgAAAA==.',['查瑞']='查瑞:BAAALAAECgQIBAAAAA==.',['柯罗']='柯罗诺斯圣盾:BAACLAAFFH8FAAICAAMIOQeMFgBGAAACAAMIOQeMFgBGAAAsAAQKfxkAAgIABwgKFWEeAB0BAAIABwgKFWEeAB0BAAAA.柯罗诺斯炽焰:BAABLAAFFH8OAAMRAAIItBasVwBJAAARAAIItBasVwBJAAAQAAEInA0fLQBJAAAAAA==.',['格蕾']='格蕾科:BAAALAAECgYIBgAAAA==.',['桥下']='桥下望天涌:BAAALAAFFAEIAQAAAA==.',['梦想']='梦想今日必成:BAAALAAECgYIBgAAAA==.',['梦行']='梦行烟雨夜:BAAALAAECgYICAAAAA==.',['梦龍']='梦龍飛雪:BAABLAAFFH8RAAIDAAUIYhWFKQAxAQADAAUIYhWFKQAxAQAAAA==.',['梵月']='梵月:BAAALAAFFAIIBAAAAA==.',['森目']='森目灬:BAABLAAFFH8KAAIMAAYIQgsEWQDmAAAMAAYIQgsEWQDmAAAAAA==.',['欲望']='欲望妖魔:BAAALAAECgYIDAAAAA==.欲望战魔:BAABLAAECn8ZAAIFAAYIoxKeNgBGAQAFAAYIoxKeNgBGAQAAAA==.',['正义']='正义使者:BAAALAAECgQIBAAAAA==.',['此刻']='此刻应有烟火:BAAALAAECgcIDQAAAA==.',['死神']='死神归来:BAAALAAECgUIBwAAAA==.',['水是']='水是睡醒的冰:BAABLAAFFH8QAAMJAAUIFwx8JwAKAQAJAAUIFwx8JwAKAQAIAAMIrA8dRgCUAAAAAA==.',['水月']='水月镜花:BAAALAADCgcIDAAAAA==.',['水睡']='水睡醒的冰块:BAAALAAFFAIIAgAAAA==.',['永恒']='永恒天权星:BAAALAAECgYIDgAAAA==.永恒天罡星:BAAALAAECgYIBgAAAA==.永恒猎仙:BAAALAAECggICAAAAA==.',['汉尼']='汉尼巴:BAABLAAFFH8KAAIEAAUInxV0PQBFAQAEAAUInxV0PQBFAQAAAA==.',['江边']='江边清风:BAAALAADCggICAAAAA==.',['污氵']='污氵糖:BAAALAAECggICAAAAA==.',['沐尘']='沐尘灬:BAABLAAFFH8NAAILAAUIUQwJMAAXAQALAAUIUQwJMAAXAQAAAA==.',['法妮']='法妮娅丶黯刃:BAAALAAECgIIAgAAAA==.',['泰兰']='泰兰徳丶语风:BAABLAAFFH8GAAIgAAQIQA0JHgCUAAAgAAQIQA0JHgCUAAAAAA==.',['泽睿']='泽睿:BAAALAAECgYIBwAAAA==.',['洛丹']='洛丹沦的忧伤:BAAALAAECgYIBgABLAAFFAgIXgABAGglAA==.',['洫傷']='洫傷:BAAALAAECgcIBwAAAA==.',['活力']='活力夜空:BAAALAADCgYIBgAAAA==.',['浪人']='浪人重修:BAAALAADCggICAAAAA==.',['浪灬']='浪灬人:BAABLAAFFH8KAAIMAAIIZB3sfwBWAAAMAAIIZB3sfwBWAAAAAA==.',['海之']='海之妖僧:BAAALAAECgYIDwAAAA==.',['消散']='消散的圣光:BAABLAAFFH8dAAIKAAUIMx2jFACwAQAKAAUIMx2jFACwAQAAAA==.',['淡淡']='淡淡的稻香:BAABLAAFFH8KAAINAAIINgegHABEAAANAAIINgegHABEAAAAAA==.',['深渊']='深渊追猎者:BAAALAADCggICAAAAA==.',['清风']='清风拂山岗:BAAALAADCgIIAgAAAA==.',['温蒂']='温蒂:BAAALAAFFAIIAgAAAA==.',['游小']='游小鱼:BAAALAADCggICAAAAA==.',['溪谷']='溪谷的牧師:BAABLAAFFH8PAAMKAAYISwUOKwDOAAAKAAQIIQcOKwDOAAAgAAQIZQI6JABWAAAAAA==.溪谷的骑士:BAABLAAFFH8FAAIBAAMITwSBIwCGAAABAAMITwSBIwCGAAAAAA==.',['潍潍']='潍潍:BAAALAAECgQIBwAAAA==.',['澎湃']='澎湃小正太:BAABLAAFFH8YAAIcAAYIQg8BKgBqAQAcAAYIQg8BKgBqAQAAAA==.',['灌篮']='灌篮子高手:BAAALAADCgMIAwAAAA==.',['火灾']='火灾:BAABLAAECn8UAAIMAAYIfBlJkgDBAQAMAAYIfBlJkgDBAQAAAA==.',['火锅']='火锅丸子:BAAALAADCgcIBwAAAA==.火锅好吃:BAABLAAFFH8OAAIiAAgI3QT4EACLAAAiAAgI3QT4EACLAAAAAA==.',['灬余']='灬余生共挽:BAAALAAECgEIAQAAAA==.',['灬尛']='灬尛酒窩灬:BAABLAAFFH8GAAIMAAYIag8MRQA1AQAMAAYIag8MRQA1AQAAAA==.',['灬熊']='灬熊猫公主灬:BAAALAAECgEIAQAAAA==.',['灬瓦']='灬瓦罗兰特:BAAALAAECggICAAAAA==.',['灬阿']='灬阿伦灬:BAAALAAECgQIBAAAAA==.',['灵活']='灵活的胖子:BAAALAADCgYICAAAAA==.',['為了']='為了臉盟:BAAALAAECgIIBAAAAA==.',['烟敛']='烟敛寒林:BAAALAAECgYICwAAAA==.',['熊撞']='熊撞树上了:BAAALAAFFAIIAgAAAA==.',['熊熊']='熊熊有责:BAAALAAECgQIBAAAAA==.熊熊果实:BAABLAAECn8gAAMMAAgIdRxfJQAiAgAMAAgIdRxfJQAiAgAbAAgIWAwsVABmAQAAAA==.',['熊爷']='熊爷不做奶:BAACLAAFFH8SAAMFAAMIyAUIQgBdAAAFAAIIeAgIQgBdAAAHAAMIoAazMABBAAAsAAQKfxQAAwUABghXFL9kAGUBAAUABghXFL9kAGUBAAcABggREUUtABYBAAAA.',['爆走']='爆走小哥:BAAALAADCgIIAgAAAA==.',['爱忘']='爱忘东西的我:BAAALAAECgYICAAAAA==.',['爸爸']='爸爸也是爹:BAAALAADCgYIBgAAAA==.',['牛孑']='牛孑精灵:BAAALAAECgYIBgAAAA==.',['牛思']='牛思拉:BAAALAAECgYIBwAAAA==.',['牛肉']='牛肉串串:BAAALAAECgUIBQAAAA==.',['狂噬']='狂噬:BAAALAAECgYIDAAAAA==.',['狂野']='狂野叶子:BAABLAAFFH8MAAMFAAII0gkSTgBWAAAFAAII0gkSTgBWAAAGAAIIZxc6DAA4AAAAAA==.',['独孤']='独孤善:BAAALAAECgYIBgAAAA==.',['狼一']='狼一德:BAAALAAFFAIIBAAAAA==.',['猎儿']='猎儿郎:BAAALAAECgIIAgAAAA==.',['猛牛']='猛牛酸酸乳:BAAALAAFFAMIAwAAAA==.',['猫猫']='猫猫叹气:BAAALAAFFAMIAwAAAA==.',['獨逍']='獨逍:BAAALAAECgYIBgAAAA==.',['王蜀']='王蜀黍:BAACLAAFFH8xAAMJAAYIoRdzFQCQAQAJAAYIoRdzFQCQAQAIAAUINxZcIgBLAQAsAAQKf0EAAwkACAiJIZQYANYCAAkACAiJIZQYANYCAAgACAgKHOMOAIICAAAA.',['玖五']='玖五:BAABLAAFFH8IAAIKAAII2g1JPwBrAAAKAAII2g1JPwBrAAAAAA==.',['玛雅']='玛雅王:BAABLAAFFH8GAAICAAIIxw1bHwAtAAACAAIIxw1bHwAtAAAAAA==.',['玩会']='玩会儿:BAAALAADCgYIBgAAAA==.',['瑪维']='瑪维影歌:BAAALAAFFAIIAgAAAA==.',['瓜子']='瓜子:BAAALAADCgQIAwAAAA==.',['瓦砾']='瓦砾:BAAALAAECgUICQAAAA==.',['甜到']='甜到爆团子:BAABLAAFFH8JAAIcAAIIoB90OQCoAAAcAAIIoB90OQCoAAAAAA==.',['生前']='生前是个奶霸:BAAALAAFFAIIAgAAAA==.',['田小']='田小花:BAAALAAECggICAAAAA==.',['电光']='电光霹雳:BAAALAAECgQIBQAAAA==.',['疯狂']='疯狂星期八:BAAALAAECggIEAAAAA==.',['瘋情']='瘋情:BAAALAAECgIIAgAAAA==.',['發發']='發發犇發發:BAAALAADCggICAAAAA==.',['白天']='白天空洞洞:BAAALAAECgYIBwAAAA==.',['白小']='白小妞:BAAALAAECgYIBgAAAA==.',['白熊']='白熊:BAACLAAFFH8mAAIEAAYIyBjnKACTAQAEAAYIyBjnKACTAQAsAAQKfzUAAgQABwi0HyUgAPoBAAQABwi0HyUgAPoBAAAA.',['白银']='白银骑士:BAABLAAFFH8KAAIDAAIIZB3MNQCmAAADAAIIZB3MNQCmAAAAAA==.',['百变']='百变小櫻:BAAALAAECgYIDQAAAA==.',['的露']='的露琪亚:BAAALAAFFAIIAgAAAA==.',['盜版']='盜版超人:BAAALAAECgcICAABLAAECggICAAhAAAAAA==.',['盲鬼']='盲鬼筋肉人:BAAALAAECgYIDQAAAA==.',['盾墙']='盾墙战吼怪:BAAALAAECgMIAwAAAA==.',['眼神']='眼神娱乐术:BAAALAAECgUIBgAAAA==.',['知者']='知者不言:BAAALAAECgMIAwAAAA==.',['矼死']='矼死的魚:BAABLAAFFH8JAAIEAAMISQTGawBiAAAEAAMISQTGawBiAAAAAA==.',['矿山']='矿山民工:BAAALAAECgcIEQAAAA==.',['砂糖']='砂糖灬:BAAALAAECgYIBgAAAA==.',['砥砺']='砥砺前行:BAAALAADCgIIAgAAAA==.',['硬馒']='硬馒头:BAAALAAECgYIDAAAAA==.',['碧水']='碧水悠蓝:BAAALAADCgEIAQAAAA==.',['磨牙']='磨牙磨牙:BAAALAAECgIIAgAAAA==.',['神圣']='神圣圣骑:BAAALAAECgcIBwAAAA==.神圣小德:BAAALAAECgYICgAAAA==.',['神泣']='神泣耶啝華:BAAALAAECgcICQAAAA==.',['神采']='神采飞杨灬:BAAALAAFFAIIAgAAAA==.',['科技']='科技与狠活:BAAALAAECggICAAAAA==.',['秧歌']='秧歌斯达:BAABLAAECn8VAAMcAAgIXCANOwBeAgAcAAgImB0NOwBeAgAjAAUICR5FGgBQAQABLAAFFAgIFgAcADMTAA==.',['移情']='移情丶别恋:BAABLAAFFH8HAAINAAIIfwySGgCVAAANAAIIfwySGgCVAAAAAA==.',['空灵']='空灵:BAAALAADCgMIAwAAAA==.',['穿心']='穿心:BAAALAAECgQIBAAAAA==.',['竖锯']='竖锯无常:BAABLAAFFH8dAAIYAAUIHQzaFACrAAAYAAUIHQzaFACrAAAAAA==.',['章凯']='章凯凤:BAAALAAECggIEAAAAA==.',['第七']='第七页序:BAAALAAECgcIBwAAAA==.',['第二']='第二梦:BAAALAAECgYIDQAAAA==.',['箭雨']='箭雨飘零:BAAALAAECggIDQAAAA==.',['粉色']='粉色体育生:BAAALAADCgYIBgAAAA==.',['精灵']='精灵六号:BAAALAAECgQIBAAAAA==.',['糖丶']='糖丶汐儿:BAAALAAECgMIAwAAAA==.',['糯米']='糯米帽子:BAAALAAECggICAAAAA==.',['红叶']='红叶:BAAALAADCggICgAAAA==.',['红月']='红月夜之猎:BAAALAAECggICQAAAA==.',['纵情']='纵情于荒野:BAABLAAECn8pAAIMAAYISyX3JgAcAgAMAAYISyX3JgAcAgAAAA==.',['绝世']='绝世灬李:BAAALAAECgYIBgAAAA==.',['绿茶']='绿茶:BAAALAAECgYIEQAAAA==.',['缘来']='缘来有你:BAACLAAFFH8cAAMFAAYIqhbLEgCmAQAFAAYIqhbLEgCmAQAHAAMIrAvuIACzAAAsAAQKfxsAAgUACAhwHbQVALACAAUACAhwHbQVALACAAAA.',['羊羊']='羊羊丶很暴力:BAAALAADCgEIAQAAAA==.',['美丽']='美丽小糖果:BAAALAADCgQIBAAAAA==.',['羡慕']='羡慕曹贼:BAABLAAFFH8GAAIYAAYIfQ4wFAAeAQAYAAYIfQ4wFAAeAQAAAA==.',['群星']='群星之怒:BAAALAAECgYIBgAAAA==.',['翻滚']='翻滚的艺术:BAAALAADCgYIBgAAAA==.',['老王']='老王不穿瑶裤:BAABLAAFFH8GAAIcAAII5gUFYQB5AAAcAAII5gUFYQB5AAAAAA==.',['职业']='职业萨满:BAAALAAECgcICgAAAA==.',['胖子']='胖子:BAAALAADCgIIAgAAAA==.',['胭脂']='胭脂送葬:BAAALAAECgUIBgAAAA==.胭脂颂葬:BAABLAAECn8fAAILAAYIXRwAdADdAQALAAYIXRwAdADdAQAAAA==.',['能擦']='能擦那里吗:BAAALAADCgQIBAAAAA==.',['脑瓜']='脑瓜子铮亮:BAAALAADCgcIDQAAAA==.',['艾格']='艾格丽丝:BAAALAAECgYIDwAAAA==.',['艾瑟']='艾瑟里奇:BAABLAAFFH8GAAIEAAIIBQrSegCKAAAEAAIIBQrSegCKAAAAAA==.',['艾薇']='艾薇:BAACLAAFFH8jAAMMAAYIJRG2OwBUAQAMAAYIJRG2OwBUAQAbAAEIlQLgOQAvAAAsAAQKfxsAAgwACAiuHVQcAFICAAwACAiuHVQcAFICAAAA.',['艾露']='艾露莎:BAAALAAECggICAAAAA==.',['花丶']='花丶溅泪:BAAALAAECgYIDgAAAA==.',['花生']='花生:BAAALAADCgMIAwAAAA==.',['花舞']='花舞花落泪:BAAALAAECgYIDQAAAA==.',['苏沁']='苏沁琉璃:BAAALAAECggIDgAAAA==.',['苏烬']='苏烬:BAAALAAECgUIBQAAAA==.',['英勇']='英勇怒火:BAAALAAECgEIAQAAAA==.',['英普']='英普瑞斯:BAAALAAECgUIBQAAAA==.',['范甘']='范甘迪哥:BAAALAAECgIIAgAAAA==.',['茄子']='茄子豆角:BAAALAADCgYIBgAAAA==.',['荣耀']='荣耀戦:BAAALAAECgYIBgAAAA==.',['莎儿']='莎儿:BAAALAADCgIIAgAAAA==.',['萌萌']='萌萌的小月:BAAALAAFFAIIBAAAAA==.',['营养']='营养快线丶:BAAALAADCgQIBAAAAA==.',['萨萨']='萨萨罗:BAACLAAFFH8IAAIJAAII3g4aLQCOAAAJAAII3g4aLQCOAAAsAAQKfx8AAgkABghsH3o1ADICAAkABghsH3o1ADICAAAA.',['萨那']='萨那也路:BAAALAAFFAIIAgAAAA==.',['董三']='董三更:BAAALAAFFAIIBAAAAA==.',['蓝之']='蓝之魅:BAAALAADCgYIBgAAAA==.',['虚空']='虚空一号:BAACLAAFFH8HAAMjAAMIORL9EQBRAAAjAAIIYBr9EQBRAAAcAAIIjQGmUgBJAAAsAAQKfxoAAiMABgi4FVEcAD4BACMABgi4FVEcAD4BAAAA.',['虾仁']='虾仁不眨眼:BAAALAADCggICAAAAA==.',['虾米']='虾米酥:BAABLAAECn8gAAIMAAgI3h+PHABRAgAMAAgI3h+PHABRAgAAAA==.',['蛋那']='蛋那个蛋:BAAALAAECgYICAAAAA==.',['蜗牛']='蜗牛慢慢跑:BAAALAAFFAIIAgAAAA==.',['血没']='血没掉命没了:BAAALAAECgUIBgAAAA==.',['西米']='西米鹿鹿:BAAALAAECgYIDAAAAA==.',['覆亦']='覆亦:BAABLAAFFH8MAAMIAAYIhxFlKwALAQAIAAQIZhhlKwALAQAJAAIILRg3MQCgAAAAAA==.',['让我']='让我绿了你:BAABLAAFFH8JAAIDAAUI+ht0IwBUAQADAAUI+ht0IwBUAQAAAA==.',['败者']='败者食尘:BAABLAAECn8XAAIDAAgI+BpkIAAaAgADAAgI+BpkIAAaAgAAAA==.',['贫僧']='贫僧法号三葬:BAAALAAECgIIAgAAAA==.',['贰爺']='贰爺丶蛋姐:BAAALAADCgcIBwAAAA==.',['贼爹']='贼爹:BAAALAAECgUIBgAAAA==.',['赤脊']='赤脊山的猪:BAAALAAECgIIAgAAAA==.',['赵鹏']='赵鹏伟:BAAALAAFFAIIAgAAAA==.',['超级']='超级尛呱籽:BAABLAAECn8WAAIGAAYIhxIrHgAiAQAGAAYIhxIrHgAiAQAAAA==.超级萨:BAAALAAECgYICAAAAA==.',['軒尼']='軒尼詩:BAAALAAECgIIAgAAAA==.',['输入']='输入一个姓名:BAAALAAECgYIBgAAAA==.',['辛普']='辛普雷:BAAALAADCgYIBgAAAA==.',['运运']='运运:BAACLAAFFH8nAAIFAAcIKRZZBwCoAQAFAAcIKRZZBwCoAQAsAAQKfygAAwUABwhwJZEPAN8CAAUABwhwJZEPAN8CAAcAAQiSDm+yACoAAAAA.',['远乄']='远乄远:BAAALAAECgMIAwAAAA==.',['迷茫']='迷茫的神:BAAALAAECgIIAwAAAA==.',['追星']='追星逐月:BAACLAAFFH8qAAIMAAYITB7eIgCmAQAMAAYITB7eIgCmAQAsAAQKfy8AAgwACAhYJNIsAKUCAAwACAhYJNIsAKUCAAAA.',['逆水']='逆水寒参上:BAAALAAFFAIIAgAAAA==.',['遥望']='遥望远帆:BAAALAAFFAIIAgAAAA==.',['那一']='那一抹曙光:BAAALAAECgYIBgAAAA==.',['那年']='那年黑海岸:BAAALAADCgEIAQAAAA==.',['邪恶']='邪恶的排骨:BAABLAAFFH8GAAIMAAIIPAsYaACGAAAMAAIIPAsYaACGAAAAAA==.',['郇大']='郇大锤:BAAALAADCgEIAQAAAA==.',['郑氵']='郑氵华仔:BAAALAAFFAIIAgAAAA==.',['都说']='都说我瞎面咸:BAACLAAFFH8KAAILAAIIGB+KPwCaAAALAAIIGB+KPwCaAAAsAAQKfxoAAgsABghWImkhAN0BAAsABghWImkhAN0BAAAA.',['酒豪']='酒豪:BAAALAAECgEIAQAAAA==.',['酷酷']='酷酷的叮叮:BAAALAAFFAIIAgAAAA==.',['酸菜']='酸菜鱼粉丝:BAAALAAECgYIBgAAAA==.',['醉卧']='醉卧风云笑:BAAALAAECgEIAQAAAA==.',['重新']='重新莱过:BAAALAAECgEIAQAAAA==.',['锅盖']='锅盖面:BAAALAAECggICAAAAA==.',['锐眼']='锐眼穿杨:BAAALAADCgEIAQAAAA==.',['镜影']='镜影:BAABLAAFFH8FAAIEAAMIgAhaaAB1AAAEAAMIgAhaaAB1AAAAAA==.',['镜花']='镜花血月:BAAALAAECgIIAgAAAA==.',['闪电']='闪电球:BAAALAADCgcIBwAAAA==.',['闭月']='闭月灬:BAAALAAECggICAAAAA==.',['阿伦']='阿伦艾弗森:BAAALAAFFAIIBAAAAA==.',['阿塔']='阿塔兰歆:BAABLAAECn8eAAIDAAYIEhkAUQBsAQADAAYIEhkAUQBsAQAAAA==.',['阿巴']='阿巴阿巴:BAAALAAFFAIIAgABLAAFFAgIDgAcAEUjAA==.阿巴阿巴阿巴:BAAALAAFFAIIAwAAAA==.',['阿斯']='阿斯卡纶:BAABLAAFFH8SAAMEAAYI+whCPABKAQAEAAYIvwhCPABKAQASAAUIXAMyEwCdAAABLAAFFAcIHAAMAIoSAA==.',['阿爾']='阿爾托利亞:BAAALAAECgYIDAAAAA==.',['阿莫']='阿莫西林:BAAALAADCggICAAAAA==.',['陌上']='陌上花开等蜂:BAAALAAECgYIEQAAAA==.',['陳平']='陳平安:BAAALAAFFAIIAgAAAA==.',['随我']='随我婆娑:BAAALAADCgEIAQAAAA==.',['随风']='随风的奶萨丶:BAAALAAECgMIAwAAAA==.随风的小奶萨:BAAALAAECgMIAwAAAA==.',['集火']='集火哪个傻馒:BAAALAAECgQICAAAAA==.',['難知']='難知如陰:BAAALAAECgIIAgAAAA==.',['雨夜']='雨夜青楼:BAABLAAFFH8GAAMRAAIICRQEXgBBAAARAAIICRQEXgBBAAAQAAEIkxFCHwAAAAAAAA==.',['雪船']='雪船:BAAALAAECgIIAgAAAA==.',['雪风']='雪风:BAAALAAECgYICwAAAA==.',['零度']='零度闪电:BAAALAADCgcIBwAAAA==.',['雷电']='雷电灬琺王:BAAALAADCgcIBwAAAA==.',['雾殇']='雾殇:BAAALAAFFAIIAgAAAA==.',['霸気']='霸気丨复仇者:BAAALAAECgYIBgAAAA==.霸気殺戮:BAAALAAECgYIBgAAAA==.',['霹雳']='霹雳火影:BAAALAAECgQICAAAAA==.',['青城']='青城山莽撞人:BAAALAAECgYIDAAAAA==.',['青提']='青提柠檬:BAAALAAECgYIBgAAAA==.',['青澜']='青澜:BAAALAAECgEIAQAAAA==.',['静花']='静花火月:BAAALAAECgEIAQAAAA==.',['颖檬']='颖檬:BAAALAADCgYIBgAAAA==.',['颛瞬']='颛瞬黑白:BAABLAAFFH8GAAIDAAIIBCRbIQDLAAADAAIIBCRbIQDLAAAAAA==.',['風林']='風林火山:BAAALAAECgcIDwAAAA==.',['風灬']='風灬崭:BAAALAADCgUICAAAAA==.',['风后']='风后奇门:BAAALAAECgEIAQAAAA==.',['风晴']='风晴雪:BAAALAADCgEIAQAAAA==.',['风暴']='风暴呢喃:BAAALAAECgEIAQABLAAFFAgIBAAhAAAAAA==.',['风洐']='风洐之翼:BAAALAAECgEIAQAAAA==.',['风舞']='风舞龙溟:BAACLAAFFH8JAAMRAAII9RlOXQBBAAARAAIIeA5OXQBBAAAQAAEISR8FHQAAAAAsAAQKfx0AAxEABgg9Il0fAOwBABEABQhdIV0fAOwBABAAAwjyFsGIAGAAAAAA.',['风语']='风语:BAABLAAFFH8GAAIMAAIIAxgoUACWAAAMAAIIAxgoUACWAAAAAA==.',['风过']='风过灬凄凉:BAAALAAECgMIAQABLAAFFAgIDAAMAHghAA==.',['风雨']='风雨飞:BAAALAAECgUIBQAAAA==.',['风飘']='风飘:BAAALAADCgcICgAAAA==.',['飒哥']='飒哥哥:BAAALAAECgQIBAAAAA==.',['飘渺']='飘渺灬奥天:BAAALAADCgYIBgAAAA==.',['饥急']='饥急击鸡纪:BAAALAAECgQIBAAAAA==.',['饭萌']='饭萌了没:BAAALAAFFAIIBAAAAA==.',['香椿']='香椿菇凉:BAAALAAFFAIIBAAAAA==.',['驭灵']='驭灵风:BAAALAADCgEIAQAAAA==.',['鬼切']='鬼切:BAAALAADCgIIAgAAAA==.',['鬼影']='鬼影月狼:BAAALAAECgYICgAAAA==.',['魂的']='魂的右手:BAAALAADCgYICQAAAA==.',['鱼传']='鱼传舍:BAAALAADCgcIBwAAAA==.',['黎玥']='黎玥儿:BAABLAAFFH8YAAILAAUICRaMKQBGAQALAAUICRaMKQBGAQAAAA==.',['黑旋']='黑旋风:BAAALAADCgEIAQAAAA==.',['黑暗']='黑暗媚贼:BAAALAAECggICAAAAA==.黑暗美骑:BAAALAAECgcIBwAAAA==.',['黑锋']='黑锋丿姥姥:BAABLAAFFH8GAAIEAAIIFR10cQBQAAAEAAIIFR10cQBQAAAAAA==.',['黑魔']='黑魔导女孩:BAAALAAECgEIAQAAAA==.',['默小']='默小羽:BAABLAAFFH8GAAIMAAIIpRRymQBBAAAMAAIIpRRymQBBAAABLAAFFAgIBwAMAGQVAA==.',['默尛']='默尛羽:BAAALAAECgYIBgAAAA==.',['黙凡']='黙凡:BAAALAAECgYIBgAAAA==.',['龍丨']='龍丨渊丨:BAAALAAECgUIBQAAAA==.',['龙泉']='龙泉小密:BAAALAADCgEIAQAAAA==.',['龙渊']='龙渊:BAAALAAECgQICAAAAA==.',['龙须']='龙须面僧:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end