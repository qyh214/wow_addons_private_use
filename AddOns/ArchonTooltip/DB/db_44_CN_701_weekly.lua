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
 local lookup = {'Druid-Balance','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Frost','Paladin-Retribution','Shaman-Restoration','Priest-Holy','DemonHunter-Vengeance','DemonHunter-Havoc','Hunter-BeastMastery','Warrior-Fury','Warrior-Protection','DeathKnight-Blood','Monk-Brewmaster','Evoker-Preservation','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Evoker-Devastation','Evoker-Augmentation','Rogue-Assassination','Hunter-Marksmanship','Warrior-Arms','Druid-Guardian','Druid-Feral','Druid-Restoration','Mage-Frost','Mage-Arcane','Paladin-Protection','Priest-Shadow','Rogue-Outlaw','Rogue-Subtlety','Paladin-Holy','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='普罗德摩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Activation:BAAALAAECgYICgAAAA==.',Ar='Ararram:BAAALAAECgYICAAAAA==.',Bi='Biubiubiu:BAAALAADCgEIAQAAAA==.',Bl='Bloodseeker:BAABLAAECn8XAAIBAAYINyAJLQAQAgABAAYINyAJLQAQAgAAAA==.',Bo='Bossboy:BAAALAAECgMIAwAAAA==.',Br='Breeze:BAABLAAFFH8KAAICAAUILxPaDQCjAQACAAUILxPaDQCjAQAAAA==.',Ch='Chernobylem:BAAALAAECgYIBgAAAA==.',Dd='Ddxx:BAAALAADCgcIBwAAAA==.',Dy='Dylandk:BAACLAAFFH9CAAMDAAgIMCBHAQDYAQADAAUIrx1HAQDYAQAEAAYIkxz6GABuAQAsAAQKfyUAAwMACAh9JKIGAO4CAAMACAg4JKIGAO4CAAQABwjoFGOnALwBAAAA.',Em='Emolieshou:BAAALAADCgUIBQAAAA==.',Gr='Gry:BAAALAAECgYIBgAAAA==.Gryphon:BAAALAAECgYIBgAAAA==.',Gu='Guccb:BAAALAAECgYIDQAAAA==.',Ha='Haguu:BAAALAAFFAIIAgAAAA==.',Ic='Icee:BAABLAAFFH8KAAIEAAMIURnmKAD1AAAEAAMIURnmKAD1AAAAAA==.',Is='Isler:BAAALAAFFAIIAgAAAA==.',Jo='Johnnybegood:BAAALAAFFAIIAgAAAA==.',Ka='Kathy:BAACLAAFFH8IAAIFAAIIjQsJbwA/AAAFAAIIjQsJbwA/AAAsAAQKfxcAAgUABggTG2lHAIYBAAUABggTG2lHAIYBAAAA.',Kl='Klfion:BAAALAAECgMIAwAAAA==.',Kt='Ktv:BAACLAAFFH8qAAMGAAcIkBW9DwDoAQAGAAcIkBW9DwDoAQACAAQIcQbeMQCaAAAsAAQKfyYAAwIACAg8Ea1kAIsBAAIABwhiDq1kAIsBAAYACAjjC3mYAE0BAAAA.',Le='Letmedk:BAACLAAFFH84AAMEAAgIqyS3AgCDAgAEAAcIUCS3AgCDAgADAAMInSTFAwBBAQAsAAQKfyMAAwQACAiPJjcmANgCAAQACAguJjcmANgCAAMAAwhqJm4yADkBAAAA.',Lo='Lowo:BAABLAAFFH8iAAICAAYIxBY7FwCDAQACAAYIxBY7FwCDAQAAAA==.',Lu='Luchao:BAAALAAECgUIBAAAAA==.',Mo='Molisa:BAABLAAFFH8FAAIHAAII/RBwPQBvAAAHAAII/RBwPQBvAAAAAA==.Moonoon:BAAALAAECgUIBQAAAA==.',No='Nowuseeme:BAAALAAECgYIBgAAAA==.',Ol='Olivan:BAAALAAECggICgAAAA==.',Or='Orion:BAAALAAECgYIBgAAAA==.',Pz='Pzh:BAAALAAECgYIDgAAAA==.',Re='Reina:BAAALAAECgIIAwAAAA==.',Ro='Rosedenuit:BAABLAAFFH8OAAMIAAII8BUiEgA8AAAJAAIIgwJsXwBxAAAIAAII8BUiEgA8AAAAAA==.',Sw='Sworks:BAAALAAFFAIIAwAAAA==.',Te='Teresa:BAAALAAECgYIEgAAAA==.',To='Tobyg:BAAALAAECgEIAQAAAA==.',Tu='Turecolor:BAAALAAECgYIDAAAAA==.',Un='Unicron:BAAALAAECgEIAQAAAA==.',Xi='Ximiko:BAAALAAFFAIIBAAAAA==.',Xx='Xxcc:BAAALAAECgUICQAAAA==.',Yi='Yian:BAABLAAFFH8FAAIKAAIIDAxijQBGAAAKAAIIDAxijQBGAAAAAA==.',Yo='Yoanbabe:BAAALAAECgYICAAAAA==.',Yx='Yx:BAAALAAECgYIBgAAAA==.',['一一']='一一壹佰:BAABLAAFFH8GAAIGAAII1xSiVQBwAAAGAAII1xSiVQBwAAAAAA==.一一得伊:BAAALAAFFAIIBAAAAA==.一一泗:BAAALAAECgYIDgAAAA==.一一点点:BAABLAAFFH8FAAIHAAIIvR7CMwCZAAAHAAIIvR7CMwCZAAAAAA==.一一的德:BAAALAAFFAIIAgAAAA==.一一駟:BAAALAAECgYIBwAAAA==.',['一品']='一品江南:BAAALAADCggICAAAAA==.',['一嘀']='一嘀嘀:BAAALAAECggIBgAAAA==.',['一季']='一季花开:BAABLAAECn8pAAIFAAgInxljTgBUAgAFAAgInxljTgBUAgAAAA==.',['一浪']='一浪一浪:BAAALAAECgYIDAAAAA==.',['一炽']='一炽一:BAABLAAFFH8FAAILAAMImA0fPgBvAAALAAMImA0fPgBvAAAAAA==.',['一生']='一生为你:BAAALAAECgYIBgAAAA==.',['一米']='一米五八:BAABLAAFFH8KAAIHAAIINB3dLACTAAAHAAIINB3dLACTAAAAAA==.',['一薪']='一薪一亿:BAAALAAFFAIIAgAAAA==.',['一起']='一起养猫吗:BAABLAAFFH8eAAIMAAcI1xd/CgAoAQAMAAcI1xd/CgAoAQAAAA==.一起浪迹天涯:BAAALAAECgIIAgAAAA==.一起笑看風雲:BAAALAAECgYIBgAAAA==.',['一路']='一路旺顺发:BAAALAAECgYIDAAAAA==.一路顺发旺:BAAALAAECgcIBAAAAA==.',['七块']='七块五大嫦发:BAAALAADCgcIBwAAAA==.',['万古']='万古魔性:BAAALAAECgQIBAAAAA==.',['三丿']='三丿须:BAAALAADCgEIAQAAAA==.',['三分']='三分归元气:BAAALAAECgIIAgAAAA==.',['三岁']='三岁就狠猛:BAABLAAFFH8RAAMEAAYIwxlIMAB5AQAEAAUIRx5IMAB5AQANAAEILgMAAAAAAAAAAA==.',['三笠']='三笠一阿克曼:BAABLAAECn8VAAILAAgIQBYKRAAnAgALAAgIQBYKRAAnAgAAAA==.',['不动']='不动斗士:BAAALAAECggICAAAAA==.不动熊猫:BAACLAAFFH8zAAIOAAYIuR82CQC1AQAOAAYIuR82CQC1AQAsAAQKfysAAg4ACAh4HtoNAHsCAA4ACAh4HtoNAHsCAAAA.不动神无:BAAALAAECgIIAgAAAA==.',['不哭']='不哭丶站搓:BAAALAAECgcICQAAAA==.不哭丶站撸:BAAALAAECgUIBgAAAA==.',['不多']='不多:BAABLAAFFH8aAAIPAAYIFhJUCwCcAQAPAAYIFhJUCwCcAQAAAA==.',['不葙']='不葙:BAACLAAFFH8JAAIQAAIImhy2MwCqAAAQAAIImhy2MwCqAAAsAAQKfzgABBAACAggIqwUAAkDABAACAi7IawUAAkDABEAAwgeFLUiANQAABIAAgi+EsiBAHUAAAAA.',['不讲']='不讲冷笑话:BAABLAAFFH8FAAIMAAIInAKsOQAkAAAMAAIInAKsOQAkAAAAAA==.',['世味']='世味煮成茶:BAAALAAECgYIBgAAAA==.',['丛林']='丛林:BAAALAAFFAIIAgAAAA==.丛林啊猫:BAAALAAECgYIDgAAAA==.',['丝黛']='丝黛拉苟萨:BAACLAAFFH9LAAITAAgIWCI0AQDLAgATAAgIWCI0AQDLAgAsAAQKfykAAxMACAjDI+4GACIDABMACAiEI+4GACIDABQACAg0ICICAPkCAAAA.',['丨影']='丨影魑丨:BAAALAAECgEIAQAAAA==.',['丨风']='丨风丨:BAAALAAECgYIBgAAAA==.',['丶御']='丶御坂妹妹丶:BAAALAADCgcIBwAAAA==.',['丿橋']='丿橋本侑菜灬:BAABLAAFFH8GAAIQAAYIex65IwCMAQAQAAYIex65IwCMAQAAAA==.',['乐芙']='乐芙兰:BAABLAAECn8WAAMQAAcIKh9wUAAAAgAQAAYIFyBwUAAAAgASAAQI+hY6YgDvAAAAAA==.',['九月']='九月酒:BAAALAAECgYICAAAAA==.',['乱嗨']='乱嗨来:BAABLAAECn8VAAIKAAgIcRVtXACKAQAKAAgIcRVtXACKAQAAAA==.',['乱试']='乱试佳人:BAAALAAECgEIAQAAAA==.',['乾坤']='乾坤戴:BAAALAAECgUICAAAAA==.乾坤挪移:BAABLAAFFH8GAAIVAAYIxg0zCgBvAQAVAAYIxg0zCgBvAQAAAA==.',['二龙']='二龙妈:BAAALAAECgQIBAAAAA==.',['云若']='云若幽幽:BAAALAADCgEIAQAAAA==.',['五千']='五千万:BAAALAADCgcIBwAAAA==.',['亦菲']='亦菲:BAACLAAFFH8FAAIKAAMIvQszeABsAAAKAAMIvQszeABsAAAsAAQKfxYAAwoACAjJEE3VAGQBAAoACAjJEE3VAGQBABYABQiZBhONALEAAAAA.',['从此']='从此丶低调:BAAALAAECgQIBQAAAA==.',['令页']='令页导:BAAALAADCgEIAQAAAA==.',['以得']='以得俘人:BAAALAAECgYIEgAAAA==.',['任飘']='任飘零:BAAALAAECgYICQAAAA==.',['伊谢']='伊谢尔丶风歌:BAAALAAFFAIIAgAAAA==.',['伟瑞']='伟瑞固德:BAAALAADCgYICwAAAA==.',['何金']='何金银:BAAALAAECgEIAQAAAA==.',['你慢']='你慢慢听我说:BAAALAAECgYIBgAAAA==.',['俺也']='俺也德:BAAALAAECgUIBwAAAA==.',['偶蕾']='偶蕾蕾:BAAALAAECgMIAwAAAA==.',['偷心']='偷心贼零命中:BAAALAAECgYIBgAAAA==.',['傲视']='傲视天下:BAACLAAFFH8IAAILAAIIIReyKgClAAALAAIIIReyKgClAAAsAAQKfxgAAwsACAgEGGsuAKEBAAsACAhpFmsuAKEBABcABgiHFAEVAJABAAAA.',['傳说']='傳说中的風哥:BAAALAADCgMIAwAAAA==.',['元素']='元素:BAACLAAFFH8pAAUYAAUIuxaTAgDhAAAZAAMIAhXMBgDuAAAYAAUIihKTAgDhAAABAAIInRLbGQCbAAAaAAEI8BJkWQA9AAAsAAQKfzAABBgACAjxICcGAKsCABgACAghHicGAKsCABkABwhAINoQAEICAAEAAQhLHZ+iAEsAAAAA.',['充话']='充话费送骑士:BAAALAAECggICAAAAA==.',['光之']='光之琥珀:BAAALAAECgQIBgAAAA==.',['光兄']='光兄:BAACLAAFFH8aAAIFAAYIaxv5CADXAQAFAAYIaxv5CADXAQAsAAQKfxcAAgUACAilJPkoAM0CAAUACAilJPkoAM0CAAAA.',['光歌']='光歌:BAABLAAFFH8HAAMaAAIIfBxmMgCgAAAaAAIIfBxmMgCgAAABAAII7w95MwA9AAABLAAFFAQIEwAbAPscAA==.',['八级']='八级大狂风:BAAALAAECgYIBgAAAA==.',['养啥']='养啥子死啥子:BAAALAAECgYICwAAAA==.',['再现']='再现天骄:BAAALAADCgMIAwAAAA==.',['冰冰']='冰冰妹夫:BAAALAAECgMIAwAAAA==.冰冰淇淋:BAAALAADCgEIAQAAAA==.',['冰封']='冰封灬旖旎:BAAALAAECgEIAQAAAA==.',['冰泪']='冰泪:BAAALAAECgYIBgAAAA==.',['冰霜']='冰霜之刃:BAAALAADCggICAAAAA==.',['冰风']='冰风溪:BAAALAAFFAQIAgAAAA==.',['凌冬']='凌冬之歌:BAAALAAECgIIAgAAAA==.',['凛冬']='凛冬丶:BAAALAAECgYIBgAAAA==.',['刁炸']='刁炸天:BAAALAAFFAIIBAAAAA==.',['划船']='划船不用桨:BAABLAAFFH8IAAIcAAIIdhiIRACbAAAcAAIIdhiIRACbAAAAAA==.',['初翎']='初翎丶山风:BAAALAAECgQIBAAAAA==.',['别叫']='别叫我德鲁一:BAABLAAECn8VAAIaAAgITAVkYgCUAAAaAAgITAVkYgCUAAAAAA==.',['劈色']='劈色特弄:BAACLAAFFH8IAAIJAAIIOh89SQBSAAAJAAIIOh89SQBSAAAsAAQKfx8AAgkABwjLIrgQAFsCAAkABwjLIrgQAFsCAAAA.',['北北']='北北再临:BAABLAAECn8VAAIMAAgIpROZLADlAQAMAAgIpROZLADlAQAAAA==.',['匪类']='匪类:BAAALAAECgUICQAAAA==.',['医疗']='医疗训练假人:BAABLAAFFH8NAAIDAAUIFw4xBgA1AQADAAUIFw4xBgA1AQAAAA==.',['匿迹']='匿迹:BAABLAAFFH8fAAIFAAYIgSFQDgDSAQAFAAYIgSFQDgDSAQAAAA==.',['十六']='十六夜秋:BAAALAAECgYICwAAAA==.',['十点']='十点半睡觉:BAAALAAECgEIAQAAAA==.',['十环']='十环:BAAALAAECgIIAgAAAA==.',['千翻']='千翻到天亮:BAAALAAECgYIDQAAAA==.千翻情人:BAAALAAECgYICQAAAA==.',['午夜']='午夜迷墙:BAAALAAECgMIAwAAAA==.',['单玉']='单玉:BAAALAAECgUIBQAAAA==.',['博士']='博士研究僧:BAAALAAFFAIIAgAAAA==.',['卡其']='卡其的小布藕:BAACLAAFFH8JAAIMAAIIdAzpKgBnAAAMAAIIdAzpKgBnAAAsAAQKf0AAAgwACAhIH9oHAFwCAAwACAhIH9oHAFwCAAAA.',['卡沙']='卡沙:BAABLAAECn8VAAMbAAYItBhbPQB8AQAbAAUInxlbPQB8AQAcAAYI3Q6POQAnAQAAAA==.',['卡迪']='卡迪亚:BAABLAAFFH8IAAMaAAMIQg9GKwCBAAAaAAIIBhJGKwCBAAABAAIICALpKQBiAAAAAA==.卡迪亚蒂凡尼:BAAALAAECgYIDAAAAA==.',['卢克']='卢克莱修:BAAALAAECgYIBgAAAA==.',['卵秀']='卵秀飞:BAAALAAECgQIBAAAAA==.',['原野']='原野上的风铃:BAAALAAECgEIAQABLAAFFAcICgAFANoeAA==.',['只会']='只会惩戒骑:BAAALAAECgQICwAAAA==.',['司命']='司命:BAABLAAFFH8FAAIEAAMI0ggwZgB+AAAEAAMI0ggwZgB+AAAAAA==.',['后无']='后无来者:BAAALAAECgUICgAAAA==.',['向我']='向我看齐:BAABLAAFFH8IAAIFAAgIqB/YAQCzAgAFAAgIqB/YAQCzAgAAAA==.',['吕炮']='吕炮:BAABLAAFFH8GAAIEAAII/hqXTgCiAAAEAAII/hqXTgCiAAABLAAFFAYIMQACALMiAA==.',['君宇']='君宇:BAAALAAECgMIAwAAAA==.',['含剎']='含剎射影:BAABLAAECn8XAAIKAAYIEh5ASQC0AQAKAAYIEh5ASQC0AQAAAA==.',['吹冷']='吹冷风:BAAALAADCgQIBAAAAA==.',['咒夜']='咒夜:BAAALAAFFAIIAgAAAA==.',['咖喱']='咖喱給給:BAAALAAECgEIAQAAAA==.',['哀木']='哀木涕劣人:BAAALAAECgIIAgAAAA==.',['哇哦']='哇哦:BAAALAAECgEIAgAAAA==.',['哟你']='哟你妹:BAAALAAECgUIBQAAAA==.',['哪里']='哪里亮点哪里:BAAALAAECgYIBgAAAA==.',['唐门']='唐门高人:BAAALAAECgYICgAAAA==.',['唐雨']='唐雨:BAAALAAECgYIBgAAAA==.',['啊克']='啊克蒙德:BAAALAADCgYIBgAAAA==.',['啊对']='啊对对對:BAABLAAFFH8IAAIUAAgInBzgAQBSAgAUAAgInBzgAQBSAgAAAA==.',['喵蕾']='喵蕾蕾喵:BAAALAAECgYICwAAAA==.',['嗯你']='嗯你说的都对:BAAALAADCgIIAgAAAA==.',['嘚兄']='嘚兄:BAAALAAECgEIAQAAAA==.',['嘟嘟']='嘟嘟侠:BAABLAAECn8YAAIEAAYIIg838gBWAQAEAAYIIg838gBWAQAAAA==.',['四喜']='四喜愛丸子:BAAALAAECgYIBgAAAA==.',['四顾']='四顾剑:BAAALAAECgUICQAAAA==.',['图腾']='图腾张:BAABLAAFFH8KAAIGAAYIrCIzBwBOAgAGAAYIrCIzBwBOAgABLAAFFAgIBgAHAKwPAA==.',['圣光']='圣光之誓:BAAALAAECgYICQAAAA==.圣光在心中:BAABLAAECn8UAAIEAAYIswn9gwDjAAAEAAYIswn9gwDjAAAAAA==.圣光的正义:BAAALAAECgYIEAAAAA==.圣光蓝教主:BAAALAAECgQIBAAAAA==.',['圣所']='圣所:BAAALAAFFAIIAgAAAA==.',['地狱']='地狱埃里克:BAAALAAECggICAAAAA==.',['地球']='地球仪:BAAALAADCgMICAAAAA==.',['垚丶']='垚丶:BAAALAAFFAIIAgAAAA==.',['堕落']='堕落灬兽狩:BAAALAAFFAIIAgAAAA==.堕落灬圣光:BAABLAAFFH8IAAIFAAII+hPlaQBBAAAFAAII+hPlaQBBAAAAAA==.堕落灬狂怒:BAAALAADCgMIAwAAAA==.堕落灬聖光:BAABLAAFFH8HAAIFAAIIIxmkYwBEAAAFAAIIIxmkYwBEAAAAAA==.堕落灬霜焱:BAAALAAFFAIIAwAAAA==.堕落灬風怒:BAAALAADCgcIBwAAAA==.堕落灬魂焱:BAAALAAFFAIIAgAAAA==.',['塔琳']='塔琳:BAAALAADCgEIAQAAAA==.',['壵乄']='壵乄壵:BAAALAAECgYIBgAAAA==.',['壹伍']='壹伍零壹:BAABLAAECn8rAAIJAAgIkyEOIgDZAgAJAAgIkyEOIgDZAgAAAA==.',['壹支']='壹支穿云箭:BAABLAAFFH8KAAIKAAUIXSG8MwBsAQAKAAUIXSG8MwBsAQAAAA==.',['壹玖']='壹玖柒捌:BAAALAAECgYIBgAAAA==.',['复仇']='复仇者丶:BAAALAAECgMIAwAAAA==.',['夏侯']='夏侯春秋:BAAALAAECgUIBQAAAA==.',['夏天']='夏天的雨:BAABLAAFFH8GAAIbAAYIkh2pAgDIAQAbAAYIkh2pAgDIAQAAAA==.',['多三']='多三点:BAAALAAECgYIBgAAAA==.',['夜下']='夜下:BAABLAAECn8VAAMDAAcIzhDwHwC7AQADAAcIzhDwHwC7AQAEAAYILQqHewD2AAAAAA==.',['夜星']='夜星河:BAAALAAFFAIIAgAAAA==.',['夜空']='夜空的琉璃鸟:BAAALAAECgYIDgAAAA==.',['夜芷']='夜芷长弓:BAABLAAFFH8GAAIKAAYIkAFmkQBEAAAKAAYIkAFmkQBEAAAAAA==.',['大笑']='大笑红尘:BAAALAAECgIIAgAAAA==.',['大罗']='大罗罗:BAAALAAECgYIDwAAAA==.',['天呐']='天呐你真高:BAAALAADCgYIBgAAAA==.',['天喔']='天喔蜂蜜柚子:BAAALAAECggICAAAAA==.',['头上']='头上带点绿:BAACLAAFFH82AAIJAAcIcyUJBQCRAgAJAAcIcyUJBQCRAgAsAAQKfzoAAgkACAjWJq0AAJoDAAkACAjWJq0AAJoDAAAA.',['夺命']='夺命剪刀脚:BAAALAAFFAIIAgAAAA==.夺命红药水:BAAALAAECgEIAQAAAA==.',['夺魂']='夺魂之镰:BAAALAAECgEIAQAAAA==.',['奥卓']='奥卓卡尔:BAACLAAFFH8OAAIJAAIIFCGyRgBeAAAJAAIIFCGyRgBeAAAsAAQKfxcAAgkACAg2JMgEAOkCAAkACAg2JMgEAOkCAAAA.',['奥斯']='奥斯尔:BAAALAAFFAIIAwAAAA==.',['奥萨']='奥萨利安:BAAALAAFFAIIBAAAAA==.',['女神']='女神的宝宝:BAACLAAFFH8JAAIaAAIIbiARGwC2AAAaAAIIbiARGwC2AAAsAAQKf0AAAhoACAhSHfobAIcCABoACAhSHfobAIcCAAAA.',['奶霜']='奶霜绵绵猫:BAACLAAFFH8lAAIdAAYIHRf8BgBdAQAdAAYIHRf8BgBdAQAsAAQKfyYAAh0ACAgEIIgHADECAB0ACAgEIIgHADECAAAA.',['好腰']='好腰菇:BAACLAAFFH8KAAMGAAIIiCR6HwDOAAAGAAIIiCR6HwDOAAACAAIIMhQpJgCbAAAsAAQKfxkAAwIABwhEHZA0ADYCAAIABwhEHZA0ADYCAAYABQhZFvqwAB8BAAAA.',['妈妈']='妈妈咪呀:BAAALAAECgMIAwAAAA==.',['妲己']='妲己本是妖:BAAALAAECggICAAAAA==.',['妹夫']='妹夫哥:BAAALAAECgEIAQAAAA==.',['嫂子']='嫂子好玩:BAAALAAECgYIDwAAAA==.',['孤雪']='孤雪飘零:BAAALAAFFAIIAwAAAA==.',['宝宝']='宝宝猫:BAAALAAFFAIIAgAAAA==.',['寂灭']='寂灭:BAAALAAECgYIBgAAAA==.',['寒光']='寒光孤影:BAAALAAECggIDgAAAA==.',['射歪']='射歪了别笑:BAAALAAECgUIBwAAAA==.',['射的']='射的你喊疼:BAAALAAECgUIBQAAAA==.',['小天']='小天使:BAACLAAFFH8iAAIHAAYISxe0EgDEAQAHAAYISxe0EgDEAQAsAAQKfxYAAgcACAinFvkpAGcBAAcACAinFvkpAGcBAAAA.',['小德']='小德不德:BAAALAADCgcIBwAAAA==.',['小情']='小情绪丶:BAAALAADCgEIAQAAAA==.',['小指']='小指头艾瑞克:BAABLAAECn8XAAMLAAgIaQv6VwANAQALAAgIRQv6VwANAQAMAAII0Q8HigBeAAAAAA==.',['小猪']='小猪哥:BAABLAAFFH8MAAIEAAIIEAuHiABCAAAEAAIIEAuHiABCAAAAAA==.',['小胡']='小胡君救命丶:BAAALAAECgYIDAAAAA==.',['小萨']='小萨:BAAALAAECgUIBQAAAA==.',['尐珺']='尐珺珺:BAAALAAECgYICQAAAA==.',['尛沫']='尛沫沫:BAABLAAFFH8FAAIFAAIINgh5ewA1AAAFAAIINgh5ewA1AAAAAA==.',['尛魅']='尛魅影:BAAALAAFFAIIAwAAAA==.',['就打']='就打脸的矮子:BAAALAADCgUIBQAAAA==.',['尼妹']='尼妹丶贵姓:BAAALAAECggIDgAAAA==.',['屠联']='屠联圣者:BAAALAADCgEIAQAAAA==.',['左勾']='左勾拳右勾拳:BAAALAAECgEIAQAAAA==.',['左右']='左右往右:BAAALAAECgYIBgAAAA==.',['左手']='左手往左:BAAALAAECgUIBQAAAA==.',['巴黎']='巴黎世家:BAAALAAECgIIAgAAAA==.',['帅气']='帅气恶魔:BAAALAAECgUIBQAAAA==.',['希娅']='希娅丶奎因:BAABLAAFFH8UAAMHAAUIVg8lIQA9AQAHAAUIVg8lIQA9AQAeAAEIrwf0LQA6AAAAAA==.',['帝君']='帝君:BAAALAAECgYICAAAAA==.',['帝隐']='帝隐:BAAALAAECggIDgAAAA==.',['平凡']='平凡萨:BAAALAAECgYIEwAAAA==.',['幻之']='幻之暗殇:BAAALAAECgQICQAAAA==.',['幼稚']='幼稚園球崽:BAABLAAFFH8cAAIKAAYIrhJuPABSAQAKAAYIrhJuPABSAQABLAAFFAYIJQAdAB0XAA==.',['广末']='广末凉子的碗:BAAALAAECgYIBgAAAA==.',['广汉']='广汉沙舵爷:BAABLAAECn8nAAIKAAgIqBMpggBEAQAKAAgIqBMpggBEAQAAAA==.',['庶弑']='庶弑:BAAALAAECgUIBQAAAA==.',['弄点']='弄点吃的:BAAALAADCgEIAQAAAA==.',['弹眼']='弹眼落睛:BAAALAAECgMIAwAAAA==.',['彩虹']='彩虹边的雨云:BAAALAAECgYIEgAAAA==.',['影月']='影月小幽幽:BAAALAAECgYIEQAAAA==.影月幽幽:BAABLAAECn8WAAIGAAYIMBVFOwBuAQAGAAYIMBVFOwBuAQAAAA==.',['御神']='御神光同在:BAACLAAFFH8QAAIFAAYIXR+5EADAAQAFAAYIXR+5EADAAQAsAAQKfzkAAgUACAhEJK4UACQDAAUACAhEJK4UACQDAAAA.',['微雨']='微雨笙寒:BAABLAAFFH8QAAIHAAIISRlVLgCRAAAHAAIISRlVLgCRAAAAAA==.',['德洛']='德洛芮丝:BAAALAAECgYIBgAAAA==.',['德鲁']='德鲁咿呀:BAAALAADCgIIAgAAAA==.',['心中']='心中之橙:BAAALAAECgYICQAAAA==.',['心如']='心如琉璃:BAABLAAFFH8RAAMdAAIIvg9HGgBxAAAFAAII8AiwVwCKAAAdAAII0Q1HGgBxAAAAAA==.',['忘不']='忘不掉的傷:BAAALAAECgUIBQAAAA==.',['快乐']='快乐的球崽:BAABLAAFFH8aAAIOAAYIBAt+EwAPAQAOAAYIBAt+EwAPAQABLAAFFAYIJQAdAB0XAA==.',['念念']='念念不莣:BAAALAAECgMIAwAAAA==.',['怀武']='怀武侠梦:BAAALAAECgYIBgAAAA==.',['怒风']='怒风:BAAALAAECgYIBwAAAA==.怒风大侠:BAAALAAECgEIAQAAAA==.',['思思']='思思:BAAALAADCgIIAgAAAA==.',['思诗']='思诗:BAAALAADCgMIAwAAAA==.',['性感']='性感小尾巴:BAABLAAFFH8QAAIFAAIIBh/rKAC3AAAFAAIIBh/rKAC3AAABLAAFFAIIEAAHAEkZAA==.',['怪大']='怪大叔:BAAALAAECgQIBAAAAA==.',['恶魔']='恶魔狂牛:BAAALAAFFAIIAgAAAA==.恶魔猎猎:BAAALAADCggIEAAAAA==.恶魔骑:BAAALAAECgcIDwAAAA==.',['悠久']='悠久:BAACLAAFFH8PAAQVAAIIqhW+FgCjAAAVAAIIqhW+FgCjAAAfAAEI1Aa8BwBDAAAgAAEIOAElHAAAAAAsAAQKfyoABBUACAjoHuwFACkCABUACAjkHuwFACkCACAABgh7FnkfAJgBAB8AAwiBHg8UAAQBAAEsAAUUAggQAAcASRkA.',['悠凛']='悠凛:BAACLAAFFH8SAAMMAAMIXBS/HwB7AAAMAAMIXBS/HwB7AAALAAIIHwT+XAA5AAAsAAQKfxwAAwwABghaHNoYAHwBAAwABghnG9oYAHwBAAsABQgrHH8+AGABAAEsAAUUBggiAAcASxcA.',['惩魔']='惩魔导:BAAALAAECgYIDAAAAA==.',['想念']='想念燃烧:BAAALAAFFAIIAwAAAA==.',['愤怒']='愤怒的右手:BAAALAAECgYIBgAAAA==.愤怒的左手:BAACLAAFFH8GAAILAAIIFQ73OACVAAALAAIIFQ73OACVAAAsAAQKfywAAwsACAgTEzRZAOYBAAsACAgTEzRZAOYBAAwABgitC3BgAAYBAAAA.愤怒的柠檬茶:BAAALAAECgYIBgAAAA==.',['懒的']='懒的想名字:BAAALAADCgYICwAAAA==.',['我为']='我为逝者哀哭:BAABLAAFFH8OAAMDAAYI9AyACAD1AAADAAYI3giACAD1AAAEAAIIGh1aeQBJAAAAAA==.',['我会']='我会用魔法:BAAALAADCgYIBgAAAA==.',['我头']='我头发呢:BAAALAAECgYIDwAAAA==.',['我是']='我是小帅丶:BAAALAADCggIEAAAAA==.',['我负']='我负责乱杀:BAABLAAFFH8IAAQhAAIIbyOVHADEAAAhAAIIbyOVHADEAAAdAAIILRljEACWAAAFAAIIeCYETABmAAAAAA==.',['战霸']='战霸天:BAAALAADCgUIBQAAAA==.',['戦將']='戦將出征:BAAALAAFFAIIBAAAAA==.',['戴安']='戴安娜普林斯:BAAALAAECgYIBwAAAA==.',['打晕']='打晕小鹿:BAAALAAFFAIIAgABLAAFFAYIJQAdAB0XAA==.',['抽象']='抽象变态狂:BAABLAAFFH8IAAIGAAIIPSFVJQC8AAAGAAIIPSFVJQC8AAAAAA==.',['拉奇']='拉奇恩古拉:BAAALAAECgQIBwAAAA==.',['拓跋']='拓跋玉兒:BAAALAADCgYIEAAAAA==.',['拯救']='拯救之手:BAAALAAFFAIIAgAAAA==.',['指尖']='指尖沙:BAAALAAECgEIAQAAAA==.',['掐死']='掐死你的温柔:BAAALAADCgYICQAAAA==.',['搞樂']='搞樂:BAABLAAFFH8MAAMWAAYIyBl1AwAJAgAWAAYIyBl1AwAJAgAKAAEIVQ+5lgBCAAAAAA==.',['摘星']='摘星咕咕:BAABLAAFFH8GAAIBAAII2Qg9NgA5AAABAAII2Qg9NgA5AAAAAA==.摘星辰大师:BAAALAAFFAIIAwAAAA==.',['收款']='收款小账本:BAAALAADCgMIAwAAAA==.',['放肆']='放肆情人:BAAALAAECgYIDQAAAA==.',['故事']='故事很长风:BAAALAADCgIIAgAAAA==.',['敲开']='敲开异域之门:BAAALAAECgYIDgAAAA==.',['文阿']='文阿婧丶:BAAALAAECgIIAgAAAA==.',['新被']='新被宾风:BAAALAAECgYIDgAAAA==.',['无丨']='无丨糖:BAAALAAECgIIAgAAAA==.',['无情']='无情的大辫子:BAAALAAECgYICgAAAA==.',['无意']='无意义:BAAALAAECgQIBAAAAA==.',['无涯']='无涯月:BAAALAAECgUIBQAAAA==.',['无聊']='无聊德:BAAALAAECgIIBAABLAAFFAYIIwAFALEXAA==.无聊战:BAACLAAFFH8KAAILAAUI9weILAD7AAALAAUI9weILAD7AAAsAAQKfzUAAwsACAiaHCMUAEICAAsACAh9GyMUAEICAAwABwgCGcgqAO8BAAEsAAUUBggjAAUAsRcA.无聊猎:BAACLAAFFH8SAAIKAAUIwxByUQAJAQAKAAUIwxByUQAJAQAsAAQKfyUAAwoABwhjHmVFAFkCAAoABwhjHmVFAFkCABYAAghmGterAFgAAAEsAAUUBggjAAUAsRcA.无聊骑:BAACLAAFFH8jAAMFAAYIsRdgFwCXAQAFAAYIsRdgFwCXAQAdAAEInBnyHQAvAAAsAAQKfyYAAwUACAh4HeFeAC0CAAUACAhbHOFeAC0CAB0ABwhSFBIwAJEBAAAA.',['无良']='无良毒奶:BAAALAAECgUIBQAAAA==.',['时光']='时光正好:BAAALAADCgIIAgAAAA==.',['明夕']='明夕灬:BAAALAADCgEIAQAAAA==.',['明月']='明月小楼:BAAALAAECgYIEwAAAA==.明月邀约:BAAALAAECgEIAQAAAA==.',['星尘']='星尘水月:BAAALAADCgMIAwAAAA==.',['星眸']='星眸:BAAALAAFFAIIAgAAAA==.',['星罗']='星罗天际:BAAALAADCgcIBwAAAA==.',['星诀']='星诀:BAAALAAECggIEwAAAA==.',['春水']='春水向东流:BAAALAAECggIDQAAAA==.',['是球']='是球球呀:BAAALAAECgUIBQAAAA==.',['是秀']='是秀虎呀:BAAALAAECgYIEgAAAA==.',['晓晓']='晓晓虎:BAABLAAECn8hAAIBAAgI0BOFGwCSAQABAAgI0BOFGwCSAQAAAA==.',['普罗']='普罗提诺:BAAALAAECgYIEQAAAA==.',['晴风']='晴风村:BAAALAAECgYIBgAAAA==.',['智剑']='智剑平八方:BAAALAAECgYIBwAAAA==.',['暗影']='暗影幽寒:BAAALAAECgYIDQAAAA==.暗影灬尐:BAABLAAECn8UAAMKAAYImRCMswD/AAAKAAYImRCMswD/AAAWAAMIfAnVnwB2AAAAAA==.暗影虚空:BAAALAADCgIIAgAAAA==.',['暗电']='暗电花:BAAALAAECgEIAQAAAA==.暗电闪:BAAALAAECgYICwAAAA==.',['暗色']='暗色利亚:BAABLAAFFH8FAAIHAAIIRwMxSgBTAAAHAAIIRwMxSgBTAAAAAA==.',['暮色']='暮色灬晨曦:BAAALAAECgYICAAAAA==.',['暮雨']='暮雨菲菲:BAAALAAFFAIIAgAAAA==.',['暴风']='暴风:BAACLAAFFH8KAAMKAAIIhQ6TXgCMAAAKAAIIXA6TXgCMAAAWAAIIvAtGKQB1AAAsAAQKfzUAAwoACAhlGsRPAD8CAAoACAgoGcRPAD8CABYACAjRElI8AMYBAAAA.',['最后']='最后的战役:BAAALAAECgYIBgAAAA==.最后的抉择:BAABLAAFFH8MAAIJAAUIPxnXKABLAQAJAAUIPxnXKABLAQAAAA==.',['最爱']='最爱吐司边儿:BAABLAAECn8cAAMeAAgILhrjJABQAgAeAAgILhrjJABQAgAHAAEIzQxnvQA4AAAAAA==.',['月光']='月光下的血红:BAAALAAECgYIDgAAAA==.月光残影:BAAALAAECgYICgAAAA==.月光魅影:BAABLAAFFH8IAAIaAAIIbRPwPwBzAAAaAAIIbRPwPwBzAAAAAA==.',['月袭']='月袭人:BAAALAAECgYIDQAAAA==.',['月见']='月见草:BAAALAADCgEIAQAAAA==.',['有事']='有事躺下说:BAAALAADCgUIBQAAAA==.',['有度']='有度:BAAALAAECggIDAAAAA==.',['有法']='有法可衣:BAAALAAECgYIBwAAAA==.',['有点']='有点小清新:BAAALAAECgQIAwAAAA==.',['望江']='望江海:BAAALAAECgIIAgAAAA==.',['未来']='未来的漩涡:BAAALAAECgIIAgAAAA==.',['朰兮']='朰兮:BAAALAADCgEIAQAAAA==.',['李小']='李小黑:BAAALAAFFAIIAgAAAA==.',['村长']='村长:BAAALAAECgIIAgAAAA==.',['来喝']='来喝一杯嗝儿:BAAALAADCgMIAwAAAA==.',['杨幂']='杨幂的奶:BAAALAAECgQICAAAAA==.',['杰克']='杰克范马:BAAALAAECgIIAgAAAA==.',['柚子']='柚子柚子:BAAALAAFFAIIAgAAAA==.',['柴禾']='柴禾妞抡大锤:BAAALAAECgYIBwAAAA==.',['格子']='格子:BAACLAAFFH8FAAMGAAUIgwb+UQB3AAAGAAQIrwH+UQB3AAACAAEIvAFjUwArAAAsAAQKfykAAwIACAhOEtFPAMsBAAIACAhOEtFPAMsBAAYACAg8EmyMAGYBAAAA.',['格格']='格格巫:BAAALAAFFAIIAwAAAA==.',['格莱']='格莱尔瑞:BAAALAAECgMIAwAAAA==.',['格鐳']='格鐳瑪燍:BAABLAAFFH8GAAILAAIIwwhZRgCDAAALAAIIwwhZRgCDAAAAAA==.',['桑葚']='桑葚:BAACLAAFFH8pAAIHAAcIlB5fBgBlAgAHAAcIlB5fBgBlAgAsAAQKfy4AAwcACAgYJV4EAE8DAAcACAgYJV4EAE8DAB4AAghJB3qSAFgAAAAA.',['桥本']='桥本香菜:BAABLAAFFH8GAAIEAAIIQRo3egBIAAAEAAIIQRo3egBIAAAAAA==.',['梦一']='梦一样自由:BAABLAAECn8ZAAIEAAgIbxnnXQA6AgAEAAgIbxnnXQA6AgAAAA==.',['梦青']='梦青春:BAAALAAECgYICgAAAA==.',['梵克']='梵克雅宝:BAAALAAECgEIAQAAAA==.',['森冢']='森冢三乃:BAAALAAECgUIBQAAAA==.',['椰奶']='椰奶的眼泪:BAAALAAFFAMIAwAAAA==.',['椰果']='椰果泡泡鹿:BAACLAAFFH8WAAMEAAYIGA8bRwAeAQANAAYItQhoDgAgAQAEAAYIbQwbRwAeAQAsAAQKfyEAAwQACAiIFh++AJsBAAQABghMGR++AJsBAA0ACAiKCI8yAOkAAAEsAAUUBgglAB0AHRcA.',['樂丨']='樂丨以德服人:BAAALAADCggICAAAAA==.樂丨风暴烈酒:BAAALAAECggICAAAAA==.',['樱桃']='樱桃蛋蛋子:BAAALAAECgEIAQAAAA==.',['橙汁']='橙汁管够:BAABLAAFFH8FAAMXAAMItATmAwBbAAAXAAMI2wPmAwBbAAALAAEIYQUaagAAAAAAAA==.',['歌颂']='歌颂:BAAALAAECggICAAAAA==.',['正能']='正能量何雍正:BAAALAAECgYIBgAAAA==.',['武汉']='武汉欢欢:BAAALAAFFAIIAgAAAA==.',['武灬']='武灬魂:BAAALAADCgEIAQAAAA==.',['歪掰']='歪掰:BAAALAAECgYIBgAAAA==.',['死亡']='死亡伴你行:BAAALAAECgEIAQAAAA==.',['残月']='残月之殇:BAAALAAECgYIEgAAAA==.',['毛兄']='毛兄:BAAALAAFFAIIAgAAAA==.',['永夜']='永夜丶无眠:BAAALAAECgYIDAAAAA==.',['求求']='求求你给点力:BAAALAAFFAIIAgAAAA==.',['汉唐']='汉唐:BAAALAAECgYIBgAAAA==.',['汐丶']='汐丶舊時光:BAABLAAFFH8GAAIEAAII6BjJTwChAAAEAAII6BjJTwChAAAAAA==.',['江城']='江城圣光:BAAALAAFFAIIAgAAAA==.江城夏日:BAABLAAFFH8JAAIEAAII3wrojABAAAAEAAII3wrojABAAAAAAA==.江城来电:BAAALAAECgIIAgAAAA==.',['沉溺']='沉溺:BAAALAAECgUIBQAAAA==.',['没事']='没事去兜风:BAAALAAECgYIDQAAAA==.',['沧桑']='沧桑男人:BAABLAAFFH8IAAILAAIIWQsLQQCLAAALAAIIWQsLQQCLAAAAAA==.',['法码']='法码里奥:BAAALAAECgYICgAAAA==.',['泠逸']='泠逸尘:BAAALAAECggIBQAAAA==.',['波波']='波波奶奶:BAAALAAECgIIAgAAAA==.波波奶射:BAAALAAECgMIAwAAAA==.',['洛丹']='洛丹伦的夕阳:BAABLAAECn8UAAMFAAYINRjLXQBLAQAFAAYINRjLXQBLAQAhAAIIABXrOAB9AAAAAA==.',['洛洛']='洛洛白:BAACLAAFFH8wAAMQAAcI1x2VEgD3AQAQAAcIxR2VEgD3AQASAAIIqxroCgC1AAAsAAQKf0QAAxAACAgZJX0JAEwDABAACAj3JH0JAEwDABIABwi3Gk8jAO8BAAAA.',['活祭']='活祭:BAAALAAECgYIDAAAAA==.',['海样']='海样蓝:BAAALAADCgEIAQAAAA==.',['海边']='海边的卡卡:BAABLAAFFH8NAAIEAAIIMh/HQACyAAAEAAIIMh/HQACyAAABLAAFFAIIEAAHAEkZAA==.',['涎水']='涎水媚娘:BAAALAAECgQIBAAAAA==.',['涯角']='涯角:BAAALAAFFAIIAgAAAA==.',['淘气']='淘气小熊:BAACLAAFFH8gAAMcAAYIyh7qJgB5AQAcAAUI7SHqJgB5AQAiAAEIHA+9CwBJAAAsAAQKfzQAAxwACAgcJWkIAE0DABwACAgcJWkIAE0DACIAAQiTFAkjADcAAAAA.',['深藏']='深藏:BAAALAAECgEIAQAAAA==.',['温妮']='温妮斯:BAAALAADCgcIBwAAAA==.',['温柔']='温柔的大白:BAAALAADCgQIBAAAAA==.',['游鱼']='游鱼与星辰:BAABLAAECn8WAAMGAAgI4w26jQBjAQAGAAgI4w26jQBjAQACAAUIwgtulQABAQAAAA==.',['渺渺']='渺渺天无际:BAAALAAECgYICAAAAA==.',['漏电']='漏电的冲击钻:BAAALAAECgIIAgAAAA==.',['潇潇']='潇潇德:BAAALAAFFAIIAgAAAA==.',['潜在']='潜在的杀伤力:BAAALAAECgYICAAAAA==.',['瀧傲']='瀧傲天:BAAALAAECgcIBwAAAA==.',['火云']='火云无刀:BAAALAAECgcICQAAAA==.',['灬牽']='灬牽牛椛灬:BAAALAAECgYIBgAAAA==.',['灭咩']='灭咩子:BAACLAAFFH8LAAMPAAMIcBQJFQC1AAAPAAMIcBQJFQC1AAAUAAEItwPUEgAAAAAsAAQKfxQAAw8ACAhjEHccAJIBAA8ACAhjEHccAJIBABQAAwiaDzwLALQAAAAA.',['灰常']='灰常荡:BAAALAAECgYIDgAAAA==.',['灵梦']='灵梦讴歌:BAAALAAECgYIBgAAAA==.',['炎如']='炎如狱:BAAALAAFFAIIBAAAAA==.',['炎龙']='炎龙侠:BAAALAAECggIEQAAAA==.',['点不']='点不着:BAAALAADCgcIBwAAAA==.',['炽皎']='炽皎:BAAALAAFFAIIAgAAAA==.',['烈日']='烈日风雨:BAAALAAECgYIDwAAAA==.',['焕醒']='焕醒神明:BAAALAAECgcIBwAAAA==.',['燃烧']='燃烧二代目:BAAALAAECgYIBgAAAA==.',['爱上']='爱上王老吉:BAABLAAFFH8KAAMaAAIInSGlLgCwAAAaAAIInSGlLgCwAAABAAEIbAM4LwA7AAAAAA==.',['爱吃']='爱吃红薯的猫:BAAALAAECgMIAwAAAA==.',['爽歪']='爽歪歪啊:BAABLAAFFH8GAAIEAAYIngHFbQBaAAAEAAYIngHFbQBaAAAAAA==.',['牛夫']='牛夫人:BAAALAAECgMIAwAAAA==.',['牛牛']='牛牛哞:BAAALAAECgYIEQAAAA==.牛牛的虎虎:BAAALAAECgQIBAAAAA==.',['牛糊']='牛糊螂:BAAALAAECggIDgAAAA==.',['犇腾']='犇腾破产哈:BAAALAADCggICAAAAA==.犇腾破产哦:BAAALAADCgEIAQAAAA==.',['犯错']='犯错的夏天:BAABLAAFFH8MAAIiAAYIvRrxAgCJAQAiAAYIvRrxAgCJAQAAAA==.',['狂雷']='狂雷:BAAALAADCggICAAAAA==.',['狂风']='狂风行者:BAAALAAECggICQAAAA==.',['独孤']='独孤肥天:BAAALAAFFAMIAwAAAA==.',['狼来']='狼来了:BAAALAAECgYIBgAAAA==.',['猎魔']='猎魔导:BAAALAADCgYIBgAAAA==.',['猫小']='猫小肉:BAAALAAECgYICAAAAA==.',['猫猫']='猫猫嘴里的鱼:BAABLAAFFH8GAAIbAAIIqRUKEACPAAAbAAIIqRUKEACPAAABLAAFFAYIAgAjAAAAAA==.猫猫爱吃鱼:BAABLAAFFH8QAAMeAAYIyRmfCwCcAQAeAAYIyRmfCwCcAQAHAAIIEhDXPQBuAAAAAA==.',['玄仙']='玄仙:BAAALAADCggICAAAAA==.',['玛卡']='玛卡巴卡姆:BAAALAADCgUIBQAAAA==.',['珊蒂']='珊蒂斯丶风歌:BAAALAAECgcIEwAAAA==.',['珑月']='珑月:BAAALAAECgEIAQAAAA==.',['琥珀']='琥珀菌:BAAALAAECgYIBgAAAA==.',['璐伊']='璐伊:BAAALAADCgQIBAAAAA==.',['生命']='生命壹号:BAAALAADCgEIAQAAAA==.',['生椰']='生椰黑铁:BAAALAAECgYIDwAAAA==.',['电拿']='电拿杨师傅:BAAALAAECgYIDQAAAA==.',['电死']='电死都要吃:BAAALAADCggIDgAAAA==.',['疯狂']='疯狂小奶牛:BAABLAAFFH8JAAIGAAIIhxw4QQCiAAAGAAIIhxw4QQCiAAAAAA==.疯狂的小摆柳:BAAALAAECgIIAgAAAA==.疯狂的背叛者:BAAALAAECgYIBgAAAA==.',['疾风']='疾风剑影:BAAALAAECgYIDQAAAA==.疾风影:BAAALAAECgMIAwAAAA==.',['癞葛']='癞葛宝:BAABLAAFFH8HAAIKAAUIChEKVAD/AAAKAAUIChEKVAD/AAAAAA==.',['白教']='白教主:BAAALAAFFAIIAgAAAA==.',['白骨']='白骨夫人:BAAALAAECgYIBgAAAA==.',['百乱']='百乱喵多喵多:BAABLAAFFH8LAAIKAAYI+BVSNQBnAQAKAAYI+BVSNQBnAQAAAA==.',['皮卡']='皮卡喵丶:BAAALAAFFAIIAgABLAAECggIGgAGABEbAA==.',['盏茶']='盏茶浅抿:BAABLAAECn8rAAIFAAgI5xzmKQDsAQAFAAgI5xzmKQDsAQAAAA==.',['盐水']='盐水凤梨:BAACLAAFFH8KAAMWAAMIrh9aFADEAAAWAAIIciNaFADEAAAKAAMI0RZUbACJAAAsAAQKfxsAAwoACAgBI0RbACYCAAoACAgkIkRbACYCABYABQgaH05LAIgBAAAA.',['盖尔']='盖尔丶加朵:BAAALAAECgYICgAAAA==.',['盲人']='盲人模橙:BAAALAAECgYICAAAAA==.',['相见']='相见不如怀念:BAAALAADCgQIBAAAAA==.',['真无']='真无霜:BAABLAAFFH8IAAMKAAYI+BGqOgBXAQAKAAYI+BGqOgBXAQAWAAIIBBOIKAB3AAAAAA==.',['砂仁']='砂仁石娲:BAAALAAECggICwAAAA==.',['破军']='破军无敌:BAAALAAECgYIBgAAAA==.',['神射']='神射:BAAALAAECgUICgAAAA==.神射手米兔:BAABLAAFFH8NAAIKAAYIih37IwCiAQAKAAYIih37IwCiAQAAAA==.',['神被']='神被苹果咬晕:BAAALAAECgYIBgAAAA==.',['福布']='福布斯:BAAALAADCggICAAAAA==.',['秀虎']='秀虎小分队:BAAALAAFFAIIAgAAAA==.',['秋叶']='秋叶:BAACLAAFFH8dAAIcAAUIVhnzLABaAQAcAAUIVhnzLABaAQAsAAQKfxcAAxwABgiQHNJpAMsBABwABgiQHNJpAMsBABsABginDBBcAAUBAAEsAAUUBggiAAcASxcA.',['秋过']='秋过落叶飞:BAABLAAFFH8KAAIJAAYIkhHcCgD0AQAJAAYIkhHcCgD0AQAAAA==.',['秋风']='秋风之刃:BAACLAAFFH8zAAIHAAYIbRSjEQAqAQAHAAYIbRSjEQAqAQAsAAQKf0AAAwcACAhPHWEPAF8CAAcACAhPHWEPAF8CAB4AAgjqAnmbADoAAAAA.',['科鲁']='科鲁坦图:BAAALAAECgMIBAAAAA==.',['穆戀']='穆戀:BAAALAAECgIIAgABLAAFFAgIBgAGABEgAA==.',['空晴']='空晴宝宝:BAAALAAECgYIBgAAAA==.',['笑笑']='笑笑猪宝仔:BAAALAADCgcIBwAAAA==.',['笛卡']='笛卡尔:BAAALAAFFAIIAgAAAA==.',['笨笨']='笨笨鸟:BAAALAAECgYIBwAAAA==.',['米亚']='米亚:BAAALAAECgIIAgAAAA==.',['米瑞']='米瑞特之阻碍:BAACLAAFFH8PAAMQAAUIUxo1FAC8AQAQAAUIUxo1FAC8AQASAAEIBhQEKQBPAAAsAAQKfyoABBAACAjtJBcNADYDABAACAgdJBcNADYDABIABAiKH5lOADkBABEAAgjXIQEmALgAAAAA.',['米莉']='米莉亚:BAAALAAECgUIBgAAAA==.',['素手']='素手抚琴:BAAALAAECgYIBgAAAA==.',['紫川']='紫川参星:BAAALAAECgMIAwAAAA==.',['絕鈑']='絕鈑灬壞壞:BAAALAAFFAIIAgAAAA==.',['絮絮']='絮絮叨叨的旭:BAAALAAFFAIIAgAAAA==.',['繁星']='繁星:BAAALAAECgcIDQAAAA==.',['纯情']='纯情的狗公腰:BAABLAAFFH8WAAMdAAYIywqcDADEAAAFAAYImgTBMQD1AAAdAAUIrgqcDADEAAAAAA==.',['细路']='细路要饮奶:BAAALAADCgIIAgAAAA==.',['给你']='给你套军体拳:BAAALAAFFAIIAgAAAA==.',['绚夜']='绚夜灬幻咒:BAAALAADCgMIAwAAAA==.绚夜灬灵契:BAAALAADCggICAAAAA==.',['绝绝']='绝绝子:BAAALAAECgYICAAAAA==.',['翔舞']='翔舞醉空:BAAALAAECggIEAAAAA==.',['肥猫']='肥猫菌:BAAALAAECgUIBgAAAA==.',['肿小']='肿小喵:BAAALAAECgYIDAAAAA==.',['胖头']='胖头陀:BAAALAAECgYIEAAAAA==.',['胡子']='胡子喳喳:BAABLAAFFH8GAAIKAAIIAQfLswA1AAAKAAIIAQfLswA1AAAAAA==.',['腾理']='腾理溪:BAAALAAFFAIIBAAAAA==.',['致命']='致命的大辫子:BAAALAADCgIIAgAAAA==.',['色媚']='色媚:BAAALAAECgYIBgAAAA==.',['色美']='色美:BAAALAAECgEIAQAAAA==.',['艾莉']='艾莉欧穹:BAAALAADCgIIAgAAAA==.',['艾马']='艾马仕:BAABLAAFFH8FAAIKAAUIpQ08VwDwAAAKAAUIpQ08VwDwAAAAAA==.',['花泽']='花泽香菜的碗:BAAALAAECgcICQAAAA==.',['花生']='花生:BAAALAAFFAIIBAAAAA==.',['苍穹']='苍穹:BAAALAADCgcIBwAAAA==.',['荣耀']='荣耀属于部落:BAAALAADCgYIBgAAAA==.荣耀肠旺面:BAABLAAFFH8IAAIBAAUI6gbFEQDfAAABAAUI6gbFEQDfAAAAAA==.',['荷鲁']='荷鲁斯:BAAALAAFFAIIAgAAAA==.',['莫南']='莫南:BAAALAAECgQICAAAAA==.',['莹月']='莹月:BAAALAAECgcIEgAAAA==.',['萌萌']='萌萌的术爸:BAAALAAECgQIBAAAAA==.',['萨拉']='萨拉姆斯:BAAALAAECgYICwAAAA==.',['萨满']='萨满开嗜血:BAAALAAECgYIBgAAAA==.',['萨穆']='萨穆罗:BAAALAAECgYIBgAAAA==.',['蒙哥']='蒙哥卡恩:BAAALAADCgYICgAAAA==.',['蒼龍']='蒼龍雲傲天:BAAALAAECgYIEQAAAA==.',['蓝色']='蓝色油腻奶瓶:BAABLAAECn8pAAIGAAgI0w2tmwBHAQAGAAgI0w2tmwBHAQAAAA==.',['蕾丷']='蕾丷蕾:BAAALAAECgYIDgAAAA==.',['藏風']='藏風:BAAALAADCgYIBgAAAA==.',['蘑菇']='蘑菇叮叮:BAAALAAECgEIAQAAAA==.',['蛋蛋']='蛋蛋博士:BAAALAAECgYIBgAAAA==.',['血神']='血神修罗:BAAALAAECgIIAgAAAA==.',['袭影']='袭影:BAAALAAECgIIAgAAAA==.',['裂颅']='裂颅者血蹄:BAAALAAECgYIBgAAAA==.',['西尔']='西尔雅娜澌:BAABLAAFFH8KAAIEAAYIvSGALgCAAQAEAAYIvSGALgCAAQAAAA==.',['西毒']='西毒丶丶:BAAALAADCgIIAgAAAA==.',['西西']='西西随意:BAAALAAECgcIBwAAAA==.',['西部']='西部老狼回归:BAAALAADCggICAAAAA==.',['西门']='西门灬大官人:BAAALAAECgcICQAAAA==.',['见文']='见文色:BAAALAAECgcIDAAAAA==.',['言西']='言西早:BAAALAAECgYIDgAAAA==.',['謸呜']='謸呜:BAACLAAFFH8vAAIQAAYITiD7GgC3AQAQAAYITiD7GgC3AQAsAAQKfx0AAhAACAhoIwsXAP0CABAACAhoIwsXAP0CAAAA.',['豌豆']='豌豆苗苗:BAABLAAECn8UAAMQAAYIUhLnSwAeAQAQAAYI6BHnSwAeAQASAAIIUxB2LABrAAAAAA==.',['财务']='财务管理:BAAALAAECgYIBgAAAA==.',['贫道']='贫道法号贼尼:BAAALAAECgMIAwAAAA==.',['费纳']='费纳希雅:BAABLAAECn8ZAAIKAAgI/hUnZQB4AQAKAAgI/hUnZQB4AQAAAA==.',['贾斯']='贾斯丁盾墙:BAAALAAFFAIIAgAAAA==.',['超级']='超级奶爹:BAABLAAECn8XAAIFAAYI5xn/WQBVAQAFAAYI5xn/WQBVAQAAAA==.',['轻松']='轻松熊:BAABLAAFFH8KAAIBAAIINBLDLgBEAAABAAIINBLDLgBEAAAAAA==.',['辛菲']='辛菲儿丶暗誓:BAAALAAECgYICQAAAA==.',['迎接']='迎接你们的尊:BAAALAAECgYIBgAAAA==.',['进口']='进口香蕉丶:BAABLAAFFH8KAAMcAAYIBRkwDQD+AQAcAAYIBRkwDQD+AQAbAAII0wc+GAB5AAAAAA==.',['迦楼']='迦楼逻帝君:BAABLAAECn8UAAIVAAcIfxDsLQC6AQAVAAcIfxDsLQC6AQAAAA==.',['迪古']='迪古拉斯:BAABLAAECn8YAAIFAAYIVh9ZaAAZAgAFAAYIVh9ZaAAZAgAAAA==.',['迪纳']='迪纳尔:BAAALAAECgYIBgAAAA==.',['追风']='追风的蚂蚁:BAAALAAECgYICgAAAA==.',['逍遥']='逍遥剑游:BAAALAAECgYIEAAAAA==.',['透明']='透明的羽翼:BAAALAAECgYICAAAAA==.',['逐云']='逐云:BAAALAAECgQIBgAAAA==.',['通天']='通天狼:BAAALAAFFAIIAgAAAA==.',['逝去']='逝去的年华:BAAALAAECgYIEwAAAA==.',['那一']='那一刻的温柔:BAAALAAECgEIAQAAAA==.',['邪念']='邪念:BAAALAADCgEIAQAAAA==.',['邪恶']='邪恶妹子:BAAALAAECgUIBQAAAA==.邪恶的益虫:BAAALAAECgUIBQAAAA==.',['邪能']='邪能英短喵:BAABLAAFFH8GAAIJAAYIWBwhFwCwAQAJAAYIWBwhFwCwAQAAAA==.',['邪鹿']='邪鹿:BAAALAAECgUICwAAAA==.',['郁闷']='郁闷小恶:BAACLAAFFH8JAAIJAAIIHReuOgCdAAAJAAIIHReuOgCdAAAsAAQKfyMAAgkACAhRIecdAO0CAAkACAhRIecdAO0CAAAA.郁闷小牧:BAAALAAECgYIBgAAAA==.郁闷小阿:BAAALAAECgUIBwAAAA==.',['酒吧']='酒吧舞:BAAALAADCgYIBgAAAA==.',['醉之']='醉之狂刀:BAAALAAECgYIBgAAAA==.',['野兽']='野兽的疯狂:BAAALAAECgIIAgAAAA==.',['野性']='野性的暗夜:BAABLAAFFH8fAAMaAAYIrxxcDADxAQAaAAYIrxxcDADxAQABAAEIpwlHNwA4AAAAAA==.',['钢兄']='钢兄:BAABLAAFFH8FAAIQAAMIwQkLVQBUAAAQAAMIwQkLVQBUAAABLAAFFAQIEwAbAPscAA==.',['铁丶']='铁丶脑壳:BAABLAAECn8cAAIJAAYIVRbwoQCJAQAJAAYIVRbwoQCJAQAAAA==.',['银枫']='银枫小鱼:BAAALAAECgYIBgAAAA==.银枫黑鱼:BAAALAAECgYIBgAAAA==.',['闪光']='闪光电击:BAAALAAECgYIDgABLAAFFAgIBwASAMwgAA==.',['闷棍']='闷棍:BAAALAAECgIIAgAAAA==.',['阿尔']='阿尔法:BAABLAAFFH8JAAIbAAIILBSSFABFAAAbAAIILBSSFABFAAAAAA==.阿尔特亚斯:BAAALAAECgQIBgAAAA==.阿尔萨丝:BAABLAAECn8ZAAMEAAgI9A57PwCDAQAEAAgIRA57PwCDAQANAAQILgjWKgBcAAAAAA==.',['阿布']='阿布:BAAALAAECgQIBwAAAA==.阿布的德:BAAALAAECgYIDQAAAA==.阿布的戒律:BAAALAAECgMIAwAAAA==.阿布的风行者:BAAALAAECgMIBAAAAA==.',['阿立']='阿立与你同在:BAACLAAFFH8dAAIFAAcIehvXBwAMAgAFAAcIehvXBwAMAgAsAAQKfx4AAwUACAhJIVoaAAoDAAUACAhJIVoaAAoDAB0ABghXDyRQAOoAAAEsAAUUCAhIAA8AhCQA.',['陈靖']='陈靖仇:BAAALAAECgUIBQAAAA==.',['隔壁']='隔壁大叔:BAABLAAFFH8GAAIFAAIIYxWySQCXAAAFAAIIYxWySQCXAAAAAA==.',['雅丽']='雅丽史卓莎:BAAALAAECgYIBgAAAA==.',['雅婷']='雅婷:BAAALAAECgYIBgAAAA==.',['雨中']='雨中玫瑰:BAAALAAECgcIBwAAAA==.',['零飘']='零飘:BAAALAAECgYIDAAAAA==.',['雷神']='雷神乔帮主:BAABLAAECn8XAAIEAAcIHRfVigDoAQAEAAcIHRfVigDoAQAAAA==.',['青春']='青春梦:BAAALAAECgYICgAAAA==.',['青青']='青青竹:BAABLAAFFH8NAAIKAAYI7BjRLQB/AQAKAAYI7BjRLQB/AQAAAA==.',['须佐']='须佐丶之男:BAAALAAECgYIBgAAAA==.',['额嗯']='额嗯嗯:BAAALAAECgYIBgAAAA==.',['風雪']='風雪刃冰霜:BAACLAAFFH8GAAIVAAII0AaHHACKAAAVAAII0AaHHACKAAAsAAQKfxYAAhUABwhLFcsnAN8BABUABwhLFcsnAN8BAAAA.',['风叶']='风叶刀:BAAALAAECggICAAAAA==.',['风的']='风的意志:BAAALAAECggICAAAAA==.',['风神']='风神半月:BAABLAAFFH8IAAIFAAQIRRZoNADeAAAFAAQIRRZoNADeAAAAAA==.',['风箫']='风箫云:BAAALAADCgMIAwAAAA==.',['飘逸']='飘逸随行者:BAAALAAECgYICAAAAA==.',['飘飘']='飘飘:BAABLAAFFH8IAAIQAAMIaBQdSQCXAAAQAAMIaBQdSQCXAAAAAA==.',['飞天']='飞天鬼:BAAALAAECgIIAgAAAA==.',['驭风']='驭风之刃:BAABLAAFFH8GAAIEAAYIeRNtNQBmAQAEAAYIeRNtNQBmAQAAAA==.',['驳驳']='驳驳:BAABLAAFFH8NAAIMAAgI0hCgAwABAgAMAAgI0hCgAwABAgAAAA==.',['魔主']='魔主:BAAALAADCgYIBgAAAA==.',['魔女']='魔女悠悠:BAAALAAECgQIBAAAAA==.',['鱼丸']='鱼丸:BAABLAAECn8hAAIIAAgI6A+sJACQAQAIAAgI6A+sJACQAQAAAA==.',['黄美']='黄美丽:BAAALAAECgMIAwAAAA==.',['黑夜']='黑夜问白天:BAAALAAECgIIAgAAAA==.',['黑白']='黑白电视:BAABLAAECn8UAAIEAAYIoxUaTgBaAQAEAAYIoxUaTgBaAQAAAA==.',['黑眼']='黑眼豆豆:BAAALAAECgEIAQAAAA==.',['黑神']='黑神話悟空:BAAALAAECgUIBQAAAA==.',['黑锋']='黑锋大王:BAAALAAECgYIDAAAAA==.',['黯淡']='黯淡汐夜:BAABLAAFFH8mAAIJAAYIaBWVGwCYAQAJAAYIaBWVGwCYAQAAAA==.黯淡蘿嵐:BAAALAAECgYIBgAAAA==.黯淡雪姬:BAAALAAECgYIEQAAAA==.',['龍三']='龍三郎:BAABLAAFFH8LAAMPAAYIIhpNCQApAQAPAAUIKhpNCQApAQATAAUIGQygEQD9AAAAAA==.',['龍嘯']='龍嘯丶傲天:BAAALAAECgYICQAAAA==.',['龙喷']='龙喷猫:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end