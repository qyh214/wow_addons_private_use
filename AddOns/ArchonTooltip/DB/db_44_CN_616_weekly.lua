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
 local lookup = {'Shaman-Elemental','Evoker-Devastation','Mage-Arcane','Mage-Fire','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Havoc','Warrior-Fury','Warrior-Protection','Shaman-Restoration','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology','Druid-Balance','Unknown-Unknown','Mage-Frost','Paladin-Retribution','Monk-Windwalker','Priest-Holy','Druid-Restoration','Monk-Brewmaster','Paladin-Protection','Evoker-Preservation','Monk-Mistweaver','Priest-Shadow','Hunter-Survival','DemonHunter-Vengeance','Druid-Feral','Priest-Discipline','Druid-Guardian','Evoker-Augmentation',}; local provider = {region='CN',realm='埃克索图斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acbili:BAAALAAECgYIBwABLAAECgcIFAABAHMZAA==.',Ae='Aegon:BAABLAAFFH8MAAICAAYINA56DQBIAQACAAYINA56DQBIAQAAAA==.',At='Atenza:BAAALAAFFAIIBAAAAA==.',Bi='Bigsoul:BAAALAAECggICAAAAA==.',Ce='Cello:BAACLAAFFH8iAAMDAAcItSG6EQDYAQADAAYIEiO6EQDYAQAEAAIIDx1wCABhAAAsAAQKfysAAgMACAgAJuwGAFgDAAMACAgAJuwGAFgDAAAA.',Co='Comiz:BAAALAAFFAIIAgAAAA==.',Da='Daddy:BAAALAAECgUIBQAAAA==.',De='Dekerbill:BAAALAAECgYIDQAAAA==.Demonkid:BAAALAAECgcIBwAAAA==.Devela:BAAALAAFFAMIAwAAAA==.',Di='Dih:BAAALAAFFAIIAgAAAA==.Dik:BAAALAAECgYIDgAAAA==.Dinozaotong:BAAALAAECgYIDAAAAA==.Dinozzotong:BAAALAAECgQIBAAAAA==.',Dr='Drakedragon:BAAALAAECgYIBgAAAA==.Druggift:BAABLAAFFH8WAAMFAAUIFhm+BwAGAQAFAAMIQRe+BwAGAQAGAAQI1xfWTwDgAAAAAA==.',Ee='Eem:BAABLAAFFH8WAAIHAAYIeReeGQCiAQAHAAYIeReeGQCiAQAAAA==.',En='Enigmazz:BAAALAAECgYIBgAAAA==.',Ev='Evelucky:BAAALAAECgYICwAAAA==.',Hu='Huulk:BAABLAAFFH8QAAMIAAUIyBvMJABIAQAIAAUI7xfMJABIAQAJAAMIjR55HACfAAAAAA==.',Hy='Hypatia:BAAALAAECgYICgAAAA==.',Ic='Ica:BAAALAAFFAIIBAAAAA==.',Jo='Jokerx:BAAALAAECgYICgAAAA==.',Ko='Koomo:BAACLAAFFH8QAAIKAAMIuR+iJQC7AAAKAAMIuR+iJQC7AAAsAAQKfygAAgoABgjrIw0zAEgCAAoABgjrIw0zAEgCAAAA.',Kt='Ktb:BAAALAADCgEIAQAAAA==.',Kx='Kxndgy:BAABLAAFFH8JAAIKAAMIdwumVgBtAAAKAAMIdwumVgBtAAAAAA==.',Lo='Louting:BAAALAADCgQIBAAAAA==.',Lu='Lunatics:BAAALAAECgYIBgAAAA==.',Mi='Missnel:BAAALAAECgQICgAAAA==.',Mo='Moayan:BAABLAAFFH8KAAILAAYIcRwQCgDkAQALAAYIcRwQCgDkAQAAAA==.Mooyan:BAABLAAFFH8JAAILAAYIGxtVCwDPAQALAAYIGxtVCwDPAQAAAA==.',Ne='Nelthario:BAACLAAFFH8bAAMMAAYIuhzfPQBNAQAMAAUIAh3fPQBNAQANAAMIihvMFgC0AAAsAAQKfzIAAw0ABgjmJUsfAGwCAA0ABghQJUsfAGwCAAwABgj8IshNAKkBAAAA.',Or='Orangebones:BAABLAAFFH8HAAMOAAMInQzzFgB+AAAOAAIImQrzFgB+AAAPAAEIpBA4GgAAAAAAAA==.',Re='Rexar:BAAALAAECgYICAAAAA==.',Ro='Ronix:BAAALAAECggICAAAAA==.',Sa='Salvatorer:BAACLAAFFH8JAAIQAAUIWRHeDwD9AAAQAAUIWRHeDwD9AAAsAAQKfxQAAgYABggEIslXAEcCAAYABggEIslXAEcCAAAA.',St='Starcraft:BAAALAAFFAIIAgAAAA==.',Th='Theway:BAAALAAECgYICQAAAA==.',To='Tongdinozzo:BAAALAAECgYIBgAAAA==.Tongtony:BAAALAAECgYIBgAAAA==.',Va='Vara:BAAALAAECggICAAAAA==.',Wa='Warcthyr:BAABLAAFFH8WAAMRAAYIUQ0GNQA+AQARAAYIUQ0GNQA+AQASAAEIjxC1KgBNAAAAAA==.',Xi='Xiaoss:BAABLAAFFH8IAAIHAAUI5CHtNwC3AAAHAAUI5CHtNwC3AAAAAA==.',Xk='Xkingt:BAAALAAECgYIDAABLAAFFAgIHAATAOIkAA==.',Za='Zamir:BAAALAAECgYIDQAAAA==.',Zy='Zynvyr:BAAALAAECgYIDgAAAA==.',['一刀']='一刀冰打:BAAALAAFFAgIAgAAAA==.',['一夜']='一夜一追寻:BAAALAAECgYIDAAAAA==.',['一宝']='一宝:BAAALAAECgYIEAAAAA==.',['一身']='一身轻:BAAALAAFFAIIAgAAAA==.',['七刀']='七刀冰打:BAAALAAFFAgIAQAAAA==.',['三刀']='三刀冰打:BAABLAAFFH8KAAIGAAYIUCSgFADtAQAGAAYIUCSgFADtAQAAAA==.',['三厅']='三厅七排五座:BAAALAAFFAIIBAAAAA==.',['三笠']='三笠乄:BAACLAAFFH8JAAIDAAIIViFpMgDAAAADAAIIViFpMgDAAAAsAAQKfxUAAgMABgh1I1VFADgCAAMABgh1I1VFADgCAAEsAAQKCAgQABQAAAAA.',['三队']='三队那个小德:BAAALAAECgQIBAAAAA==.',['上帝']='上帝归来:BAAALAAFFAIIAgAAAA==.',['下午']='下午茶:BAAALAAECgUICAABLAAFFAgIBQAVAEMdAA==.',['不一']='不一样的烟火:BAAALAAECgIIAgAAAA==.',['不吐']='不吐西瓜皮:BAAALAAECgYIBwAAAA==.',['不咸']='不咸不淡:BAAALAAECgIIAgAAAA==.',['不想']='不想飞的牛:BAAALAAFFAIIAgAAAA==.',['不能']='不能怎么做:BAAALAADCgcIBwAAAA==.不能这么做:BAABLAAFFH8IAAIWAAMIbxOyGwDqAAAWAAMIbxOyGwDqAAAAAA==.',['东东']='东东同学:BAAALAAECgYIBwAAAA==.',['东哥']='东哥:BAAALAAECgYIBgAAAA==.',['东方']='东方冷羽:BAAALAAFFAIIAgAAAA==.',['两刀']='两刀冰打:BAAALAAFFAgIAQAAAA==.',['丨死']='丨死灵灬:BAAALAAFFAEIAQABLAAFFAYIOAAXAAgbAA==.',['丨陌']='丨陌路:BAAALAAECgIIAgAAAA==.',['丶你']='丶你的月亮:BAAALAADCgUIBQAAAA==.',['丶半']='丶半城雪:BAABLAAFFH8LAAIIAAIIVBjTRQBNAAAIAAIIVBjTRQBNAAAAAA==.',['主角']='主角宿命:BAAALAADCgYIBgAAAA==.',['乐之']='乐之爹:BAAALAAECgYIBgAAAA==.',['乐于']='乐于奉献:BAAALAAECgYICwAAAA==.',['书客']='书客被打:BAABLAAFFH8OAAIJAAII5hNMKQA/AAAJAAII5hNMKQA/AAAAAA==.',['乾坤']='乾坤牛转:BAAALAAECgUIBQAAAA==.',['二界']='二界:BAAALAAFFAIIAgAAAA==.',['五刀']='五刀天打:BAAALAAFFAgIAgAAAA==.',['五块']='五块石烂眼儿:BAAALAAECgEIAQAAAA==.',['京观']='京观:BAAALAAFFAIIBAAAAA==.',['人民']='人民较湿:BAAALAAECgYIDgAAAA==.',['他他']='他他丶塔子哥:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利达雷霸主:BAAALAAECgYIDwAAAA==.',['伐克']='伐克尤:BAAALAAECgUIBQAAAA==.',['伯拉']='伯拉多尔:BAAALAAFFAMIAwAAAA==.',['佑缇']='佑缇艾沫:BAAALAADCgcIBwAAAA==.',['何包']='何包菜:BAAALAADCgEIAQAAAA==.',['何子']='何子佩丶:BAAALAAECgQIBAAAAA==.',['何方']='何方:BAABLAAFFH8FAAIYAAQIfhaqIwAhAQAYAAQIfhaqIwAhAQAAAA==.',['你一']='你一溅我就笑:BAAALAAECgYIBgAAAA==.',['使劲']='使劲打用力抽:BAAALAAECgUIBQAAAA==.',['便宜']='便宜一点:BAABLAAFFH8HAAIKAAIIKRTeQgB8AAAKAAIIKRTeQgB8AAAAAA==.',['保护']='保护我:BAAALAAECgYICQAAAA==.',['傻漫']='傻漫:BAAALAAECgIIAgAAAA==.',['元素']='元素丶地球:BAACLAAFFH8JAAMKAAIImghVXQBiAAAKAAIImghVXQBiAAABAAEIdQSaPwA8AAAsAAQKfxgAAgoABwjvFwknANEBAAoABwjvFwknANEBAAAA.',['光暗']='光暗小猫:BAAALAAFFAIIBAAAAA==.',['克丽']='克丽丝叮:BAAALAAECgUIBQAAAA==.',['八刀']='八刀冰打:BAAALAAFFAgIBAAAAA==.',['六刀']='六刀冰打:BAABLAAFFH8GAAIGAAYIMBz+BgA2AgAGAAYIMBz+BgA2AgAAAA==.',['兽神']='兽神演武:BAAALAAECgMIAwAAAA==.',['冰丶']='冰丶媛:BAACLAAFFH8rAAMDAAYI5BYzIgCNAQADAAYI5BYzIgCNAQAVAAIIkA20FgB+AAAsAAQKfx4AAwMABwjRHo9cAO4BAAMABwjzHI9cAO4BABUABgjzFndAAG8BAAAA.',['冰剑']='冰剑丶:BAAALAAECgYIAgAAAA==.',['冰岛']='冰岛:BAAALAAECgEIAQAAAA==.',['冰落']='冰落凡尘:BAAALAAECgYIBgAAAA==.',['冰风']='冰风不朽:BAAALAAECgcIDgAAAA==.',['冲动']='冲动的小指头:BAAALAAFFAIIAgAAAA==.冲动的羊咩咩:BAAALAAFFAIIAgAAAA==.冲动的野丫頭:BAAALAAECgEIAQAAAA==.',['凡尘']='凡尘忆梦:BAACLAAFFH8eAAMZAAYIaBO5CQBwAQAZAAYIaBO5CQBwAQATAAEIGwVNOQA0AAAsAAQKfxwAAhkABwivIHgqADoCABkABwivIHgqADoCAAAA.',['凡尼']='凡尼斯:BAAALAAECgUIBQAAAA==.',['刀刀']='刀刀蛋:BAAALAAECgQIBAAAAA==.',['列塔']='列塔丶高嶺:BAAALAADCgIIAgAAAA==.',['别叫']='别叫我刷智力:BAACLAAFFH8GAAIDAAIIRQyHUgCOAAADAAIIRQyHUgCOAAAsAAQKfxQAAgMABggoEA2WAF4BAAMABggoEA2WAF4BAAEsAAUUAggHAAcARA0A.',['功夫']='功夫母猫:BAABLAAFFH8cAAIaAAYILhLdDgBaAQAaAAYILhLdDgBaAQAAAA==.',['勇敢']='勇敢的什么德:BAAALAAFFAIIAwAAAA==.',['十全']='十全武功:BAAALAAECgYIBwAAAA==.',['千羽']='千羽冰怡:BAABLAAFFH8XAAIbAAYITRgkBgBzAQAbAAYITRgkBgBzAQAAAA==.',['千里']='千里走单骑:BAAALAAFFAIIBAAAAA==.',['半世']='半世的流离:BAAALAADCgIIAgAAAA==.',['半张']='半张脸的神话:BAAALAAECgYIBgAAAA==.',['卑鄙']='卑鄙小法:BAAALAAECgYIBgAAAA==.',['南卡']='南卡:BAAALAAECgYIBgAAAA==.',['卪深']='卪深邃乄清影:BAABLAAFFH8HAAIMAAIIUReXnQA/AAAMAAIIUReXnQA/AAAAAA==.卪深邃乄清晨:BAAALAAFFAIIAgAAAA==.',['叁笙']='叁笙叁誓:BAAALAAECgYIBgAAAA==.',['可乐']='可乐加冰:BAAALAAECgYIDAAAAA==.',['吊爆']='吊爆天:BAAALAAECgUIBQAAAA==.',['君王']='君王丶瓦鲤安:BAAALAAECgcIBwAAAA==.',['吴老']='吴老师:BAAALAADCgcIBwAAAA==.',['呦呦']='呦呦:BAAALAAECgYIDAAAAA==.',['呼噜']='呼噜:BAABLAAFFH8IAAIcAAIIKA2KGgBqAAAcAAIIKA2KGgBqAAAAAA==.',['呼小']='呼小胖:BAACLAAFFH8KAAIdAAIINgKGGgBIAAAdAAIINgKGGgBIAAAsAAQKfxgABB0ABwgiB/07ANYAAB0ABwgiB/07ANYAABoAAwjjAYskAEYAABcAAQifB+Y7ACoAAAAA.',['哈斯']='哈斯笨德:BAAALAAECgQIBAAAAA==.',['哎呦']='哎呦不是吧:BAAALAAFFAIIBAAAAA==.',['哦耶']='哦耶王小明:BAAALAAECgYICQAAAA==.',['喝橙']='喝橙汁出橙:BAAALAAECgQIBAAAAA==.',['喵喵']='喵喵如此美妙:BAAALAADCgUIAwAAAA==.',['噫唏']='噫唏嘘:BAAALAAECgYIDwAAAA==.',['四刀']='四刀冰打:BAABLAAFFH8GAAIGAAYIdh8tKwCLAQAGAAYIdh8tKwCLAQAAAA==.',['四宫']='四宫辉夜:BAAALAAECgYIBgAAAA==.',['回忆']='回忆里的疯狂:BAAALAAECgMIBAAAAA==.',['圓滚']='圓滚滚地圆:BAAALAAFFAIIBAAAAA==.',['土灬']='土灬匪:BAAALAADCgQIBAAAAA==.',['土豆']='土豆炖芸豆:BAAALAADCgEIAQAAAA==.',['圣光']='圣光背叛了窝:BAAALAAECgIIAgAAAA==.',['在遥']='在遥远的附近:BAAALAAECggICAAAAA==.',['地狱']='地狱勇士:BAAALAAECgYIDAAAAA==.',['坊屋']='坊屋春道丶:BAAALAAFFAIIAgAAAA==.',['坑不']='坑不死的深绿:BAAALAAECgYIBgAAAA==.',['壹宝']='壹宝:BAAALAAFFAIIAgAAAA==.',['壹玖']='壹玖伍榴:BAAALAAECgYICwAAAA==.',['壹贰']='壹贰贰零:BAABLAAFFH8GAAIMAAYIOAjnWADnAAAMAAYIOAjnWADnAAAAAA==.',['夏夜']='夏夜星:BAAALAADCgYIBgAAAA==.',['夕颜']='夕颜花开:BAABLAAFFH8MAAIQAAUITxDzDwD6AAAQAAUITxDzDwD6AAAAAA==.',['夜之']='夜之子有纹身:BAABLAAFFH8GAAIVAAII9BTZDwCQAAAVAAII9BTZDwCQAAAAAA==.',['夜灵']='夜灵:BAAALAAECgYIDAAAAA==.',['夢幻']='夢幻球球:BAAALAAFFAIIAwAAAA==.',['大牛']='大牛小牛:BAABLAAFFH8VAAMZAAYIgh+tGQBgAQAZAAQIIiCtGQBgAQATAAQIpR1tGgADAQAAAA==.',['大眼']='大眼小眼:BAAALAAFFAEIAQAAAA==.',['大米']='大米米:BAAALAAECgIIAgAAAA==.',['天上']='天上有个洞:BAAALAAECgEIAQAAAA==.',['天山']='天山雪大红枣:BAAALAAECgMIBAAAAA==.',['天年']='天年:BAACLAAFFH8IAAIdAAQI0QUsEAC4AAAdAAQI0QUsEAC4AAAsAAQKf0gAAh0ACAgjHL0GAG4CAB0ACAgjHL0GAG4CAAAA.',['天月']='天月闪耀:BAAALAAECgIIBAAAAA==.',['天黄']='天黄头鸡:BAAALAAECgMIAwAAAA==.',['头上']='头上插根毛:BAAALAAECgYIBgAAAA==.',['奥塔']='奥塔里斯:BAAALAAECggIDQAAAA==.',['奶壹']='奶壹口:BAABLAAECn8ZAAMeAAYIfhccHgBVAQAeAAYIfhccHgBVAQAYAAYI+g66dgAZAQAAAA==.',['奶盐']='奶盐啵啵:BAAALAAECgMIBAAAAA==.',['好懒']='好懒:BAAALAAFFAIIAgAAAA==.',['威格']='威格:BAAALAAECgcIBwAAAA==.',['娅娅']='娅娅:BAAALAADCggICAAAAA==.',['嫟弥']='嫟弥西斯:BAAALAADCgIIAgAAAA==.',['嫩草']='嫩草血蹄:BAAALAAFFAIIAgAAAA==.',['子墨']='子墨丶:BAAALAAECgYIDAAAAA==.子墨丶战:BAAALAAECgEIAQAAAA==.子墨丶猎:BAAALAAECgIIAgAAAA==.',['孙达']='孙达浪:BAAALAAECgYIBgAAAA==.',['孤山']='孤山远影:BAABLAAFFH8IAAIMAAIInh0YTgCXAAAMAAIInh0YTgCXAAAAAA==.',['守望']='守望猎手:BAAALAAECgYIDAABLAAFFAYIKwADAOQWAA==.',['安小']='安小喏:BAAALAAECgYICAABLAAFFAYIOAAXAAgbAA==.',['宝贝']='宝贝的帮凶:BAAALAAECgIIAQAAAA==.',['寇达']='寇达娜丶魔刃:BAAALAAECgQIBAAAAA==.',['寒丶']='寒丶霜:BAABLAAFFH8HAAIGAAIIaxCFhgBDAAAGAAIIaxCFhgBDAAAAAA==.',['射雕']='射雕:BAAALAAECgUICgAAAA==.',['小堕']='小堕姬:BAABLAAFFH8MAAIRAAIIJRSLSgCKAAARAAIIJRSLSgCKAAAAAA==.',['小明']='小明:BAAALAADCgQICAAAAA==.',['小朦']='小朦朦:BAAALAAECgYICgAAAA==.',['小欢']='小欢乐:BAABLAAFFH8KAAIRAAII+gisZwA4AAARAAII+gisZwA4AAAAAA==.',['小瓜']='小瓜瓜:BAAALAAECgYIBgAAAA==.',['小米']='小米丶酥妻:BAAALAAFFAIIAgAAAA==.',['小萌']='小萌猎:BAAALAAECgYIBgAAAA==.',['小野']='小野丶:BAAALAAFFAIIAgAAAA==.',['小陀']='小陀螺丶:BAAALAAFFAIIBAAAAA==.',['小鸟']='小鸟伏特加:BAAALAAECgIIBQAAAA==.',['小黄']='小黄瓜:BAAALAAECgYIBgAAAA==.',['尛乖']='尛乖:BAABLAAECn8aAAIMAAgIUxurSQBOAgAMAAgIUxurSQBOAgAAAA==.',['尼克']='尼克:BAABLAAFFH8KAAIMAAII9RMlYACLAAAMAAII9RMlYACLAAAAAA==.',['布萊']='布萊克:BAABLAAFFH8MAAIIAAIIphTiNgCXAAAIAAIIphTiNgCXAAAAAA==.',['帅气']='帅气的鲨鱼:BAAALAAECgUICQAAAA==.',['年年']='年年知為誰生:BAAALAAFFAIIAwAAAA==.',['幻影']='幻影之翎:BAAALAAFFAIIAgAAAA==.',['幼儿']='幼儿园扛把子:BAAALAAECgEIAQAAAA==.',['幽谷']='幽谷龙吟:BAABLAAFFH8GAAMcAAIIHwKAHgBMAAAcAAIIHwKAHgBMAAACAAIItQouIAA6AAAAAA==.',['当心']='当心你的背后:BAAALAAFFAIIBAAAAA==.',['彡芉']='彡芉迣鎅:BAAALAADCgIIAgAAAA==.',['彼此']='彼此的牵绊:BAABLAAFFH8MAAQbAAUIMggCDgCjAAAbAAUIMggCDgCjAAALAAIIDxJLIgCCAAAWAAEI2wBXbQAvAAABLAAFFAcIHQAfAJ8YAA==.',['很多']='很多猫:BAABLAAFFH8GAAIgAAIIWACpHAAyAAAgAAIIWACpHAAyAAAAAA==.',['德古']='德古拉:BAAALAAECggICAAAAA==.',['德莱']='德莱文:BAAALAAECgYICgAAAA==.',['心一']='心一:BAABLAAFFH8RAAIHAAQI4hxJMgD7AAAHAAQI4hxJMgD7AAAAAA==.',['念小']='念小妞:BAABLAAFFH8JAAIeAAIIjx9IJQBPAAAeAAIIjx9IJQBPAAAAAA==.',['怎么']='怎么都在打我:BAAALAAFFAIIBAAAAA==.',['性感']='性感冲修斗:BAAALAAECggIDQAAAA==.性感的圣骑丶:BAAALAAECggICAAAAA==.',['恏氼']='恏氼猎:BAAALAAECgYIDAAAAA==.',['恶丨']='恶丨魔猎手:BAAALAAECgMIAwAAAA==.',['恶魔']='恶魔球球:BAACLAAFFH8UAAIHAAMIxxlVGgAHAQAHAAMIxxlVGgAHAQAsAAQKfzUAAgcACAjJII4WACUCAAcACAjJII4WACUCAAAA.恶魔的左耳:BAABLAAFFH8IAAIhAAIIPBuHDABNAAAhAAIIPBuHDABNAAAAAA==.恶魔韦宝宝:BAABLAAFFH8FAAIHAAMIURFfPQCXAAAHAAMIURFfPQCXAAAAAA==.',['悠宁']='悠宁:BAAALAADCgUIBQAAAA==.',['悲伤']='悲伤涅槃:BAABLAAFFH8MAAMDAAUIoQweNwAXAQADAAUIhgseNwAXAQAVAAIInRCmEgCJAAAAAA==.',['想当']='想当高手:BAAALAAECgUIBwAAAA==.',['想戈']='想戈名字好难:BAAALAAECgUIDgAAAA==.',['愉快']='愉快之手:BAAALAAFFAEIAQAAAA==.',['愛妃']='愛妃:BAAALAAECgYIDwAAAA==.',['愤怒']='愤怒的哈里哥:BAAALAAECgEIAQAAAA==.愤怒的小细软:BAABLAAFFH8FAAIKAAMIbgqWLwCjAAAKAAMIbgqWLwCjAAAAAA==.',['我很']='我很好那你呢:BAABLAAFFH8HAAIKAAIICR/GPACwAAAKAAIICR/GPACwAAAAAA==.',['我的']='我的小宝贝:BAAALAAECgYIBgAAAA==.',['戒不']='戒不掉的柔情:BAABLAAFFH8KAAIMAAIImBVXkABFAAAMAAIImBVXkABFAAAAAA==.',['戮光']='戮光:BAAALAAECgYIBgAAAA==.',['打桩']='打桩吗:BAAALAAECgMIAwAAAA==.',['托勒']='托勒密:BAAALAADCgYIBgAAAA==.',['扛不']='扛不住:BAAALAADCggICAAAAA==.',['挖坑']='挖坑九号:BAAALAAECgYIDAAAAA==.挖坑二号:BAAALAAECggIBgAAAA==.',['提奶']='提奶灌顶:BAACLAAFFH8IAAIKAAIIUxWWPgCEAAAKAAIIUxWWPgCEAAAsAAQKfxsAAgoABwjzHHg9ACYCAAoABwjzHHg9ACYCAAAA.',['摇晃']='摇晃:BAABLAAFFH8WAAIDAAYIbxH+JQB9AQADAAYIbxH+JQB9AQAAAA==.',['敏哥']='敏哥:BAAALAAECgYIBgAAAA==.',['斩相']='斩相思:BAABLAAFFH8IAAIGAAII2halggBEAAAGAAII2halggBEAAAAAA==.',['斯巴']='斯巴达血吼:BAAALAAECgYICAAAAA==.',['方嗲']='方嗲:BAAALAAECgUIBQAAAA==.',['无聊']='无聊高峰期:BAAALAAECggICAAAAA==.',['时光']='时光丶:BAABLAAECn8ZAAMiAAgI8hgxBgDaAQAiAAcIGxkxBgDaAQAYAAgILBOcHgDEAQAAAA==.',['暗夜']='暗夜舞姬:BAAALAAFFAIIBAAAAA==.',['暗黑']='暗黑无界:BAAALAAECgYIBwAAAA==.',['暴走']='暴走一号:BAAALAAECgUIBQAAAA==.暴走的猛汉:BAABLAAFFH8HAAIIAAUI2wvEKwAGAQAIAAUI2wvEKwAGAQAAAA==.',['曰尔']='曰尔曼战车:BAAALAAFFAgIAgAAAA==.',['最后']='最后的怒吼:BAACLAAFFH8IAAIGAAIIvhJ0eABJAAAGAAIIvhJ0eABJAAAsAAQKfxYAAgYABgjwHSk7AJEBAAYABgjwHSk7AJEBAAAA.',['最瘦']='最瘦的胖子:BAAALAAECgYIBgAAAA==.',['月月']='月月风:BAAALAAECgUIBQAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8PAAMZAAgIThheCwD9AQAZAAcIkRZeCwD9AQATAAEIOhrmKgBcAAAAAA==.',['有肉']='有肉:BAAALAAECgYIDAAAAA==.',['望风']='望风的蜗牛:BAAALAADCgYIBgAAAA==.',['松坂']='松坂南:BAAALAAECgIIAgAAAA==.',['果籁']='果籁:BAAALAAECgEIAQAAAA==.',['枫椽']='枫椽椽:BAAALAAECgYICAAAAA==.',['某天']='某天:BAAALAAECgEIAQAAAA==.',['柑蕉']='柑蕉桔梨箩柚:BAAALAADCgYIBgAAAA==.',['格拉']='格拉布物语:BAAALAAECgMIAwAAAA==.',['梦境']='梦境丶地球:BAABLAAFFH8MAAMjAAYIbwyKBQDEAAATAAUImQYjHgDXAAAjAAUIAQ2KBQDEAAABLAAFFAgICQAZAGoCAA==.',['椰蔓']='椰蔓桐苨菊花:BAAALAADCgYIBgAAAA==.',['楠楠']='楠楠:BAABLAAFFH8bAAMkAAYI8hHSBQBoAQAkAAYI8hHSBQBoAQACAAMI7gdMGgBdAAAAAA==.',['楼台']='楼台烟雨中:BAAALAAECgEIAQAAAA==.',['樱田']='樱田渚渚:BAAALAAECgYIDAAAAA==.',['樱花']='樱花:BAAALAAECgEIAQAAAA==.',['欢悦']='欢悦今朝:BAAALAADCgMIAwAAAA==.',['欧西']='欧西利斯:BAAALAAFFAEIAQAAAA==.',['歡喜']='歡喜:BAAALAAFFAMIAgABLAAFFAcICgAWANoeAA==.',['死亡']='死亡丶地球:BAACLAAFFH8XAAMGAAUIPxSRKwDrAAAQAAUIaBK3DwABAQAGAAMIdBaRKwDrAAAsAAQKfxQAAwYABwg9HFVjAC8CAAYABwg9HFVjAC8CABAAAQjTFx1LAD4AAAAA.死亡之愿:BAAALAAECgUIBQAAAA==.',['残月']='残月之箭:BAABLAAFFH8MAAIMAAIIkRmJSgCaAAAMAAIIkRmJSgCaAAAAAA==.',['比谢']='比谢狗坦强:BAAALAAECgIIAgAAAA==.',['水墨']='水墨青花:BAABLAAFFH8eAAIWAAYIqyD9CwDkAQAWAAYIqyD9CwDkAQAAAA==.',['水月']='水月小术:BAAALAAECgUIBwAAAA==.水月小朹:BAAALAADCgUIBQAAAA==.',['永冻']='永冻乄黎明:BAAALAAFFAIIBAAAAA==.',['江南']='江南烟雨楼:BAABLAAFFH8NAAIjAAQIvw9/BgCdAAAjAAQIvw9/BgCdAAAAAA==.',['沃尼']='沃尼犸:BAAALAAECggICAAAAA==.',['沙雕']='沙雕追猎者:BAAALAAECgYICQAAAA==.',['没放']='没放盐的咸鱼:BAABLAAFFH8GAAMLAAYI4xFUFgApAQALAAUIKRBUFgApAQAWAAEIKgfhaQBBAAAAAA==.',['油炸']='油炸虾米:BAABLAAFFH8FAAIDAAUINQrvNwAPAQADAAUINQrvNwAPAQAAAA==.',['泰兰']='泰兰物语:BAAALAADCgYIBgAAAA==.',['泰难']='泰难得:BAAALAAECggICAAAAA==.',['泽晓']='泽晓:BAAALAAECggIAQAAAA==.',['流妍']='流妍:BAAALAAECgIIAgAAAA==.',['浅伤']='浅伤丶眠:BAABLAAFFH8mAAIBAAYI8RrpEgCkAQABAAYI8RrpEgCkAQABLAAFFAYIKwADAOQWAA==.',['浅熙']='浅熙:BAAALAADCgUIBQAAAA==.',['浩渺']='浩渺之手:BAABLAAFFH8SAAMdAAYIjAvUDQD+AAAdAAUIKAjUDQD+AAAXAAQIOg/BDgC4AAAAAA==.',['浮世']='浮世記夢:BAABLAAFFH8QAAMKAAYIXRY2FgACAQAKAAYIXRY2FgACAQABAAEIqwSOSwA7AAABLAAFFAgIAgAUAAAAAA==.',['海棠']='海棠落梨花开:BAAALAAFFAIIAgAAAA==.',['涅圣']='涅圣:BAABLAAFFH8GAAIWAAYIchTkHAB5AQAWAAYIchTkHAB5AQAAAA==.',['消消']='消消乐:BAABLAAFFH8GAAIDAAIInAyvWgBBAAADAAIInAyvWgBBAAAAAA==.',['清焱']='清焱凝雪:BAABLAAFFH8JAAIDAAUIhQUbZAA3AAADAAUIhQUbZAA3AAAAAA==.',['清翎']='清翎飘雪:BAABLAAFFH8HAAILAAQI1xebFgAkAQALAAQI1xebFgAkAQAAAA==.',['清荷']='清荷丶:BAAALAAECgUIBQAAAA==.',['温蕾']='温蕾萨丶明翼:BAAALAADCggIDAAAAA==.温蕾蕾:BAAALAADCggIDwAAAA==.',['火捻']='火捻:BAAALAAECgYICAAAAA==.',['火焰']='火焰听我召唤:BAABLAAFFH8HAAIKAAMIqA2WTQCBAAAKAAMIqA2WTQCBAAAAAA==.',['火爆']='火爆的番茄:BAABLAAFFH8HAAIMAAcIwxG9HwCzAQAMAAcIwxG9HwCzAQAAAA==.',['灬猎']='灬猎灬:BAAALAAECgYIBgAAAA==.',['灬骑']='灬骑士灬:BAAALAAECgEIAQAAAA==.',['灵踪']='灵踪:BAAALAAECgcIBwAAAA==.',['灼眼']='灼眼的夏侯惇:BAABLAAFFH8IAAIWAAYIGSOrAgBSAgAWAAYIGSOrAgBSAgAAAA==.',['為誰']='為誰戰天涯:BAABLAAFFH8FAAIRAAIIuwFAWABdAAARAAIIuwFAWABdAAAAAA==.',['烜赫']='烜赫:BAAALAAECgMIAwAAAA==.',['烟雨']='烟雨满江南:BAABLAAFFH8IAAIJAAIIfhCwMAAyAAAJAAIIfhCwMAAyAAAAAA==.烟雨醉江南:BAAALAAFFAIIAgAAAA==.',['焦喘']='焦喘的邦桑迪:BAAALAAECgYICAAAAA==.',['照世']='照世明灯:BAABLAAFFH8GAAIbAAIIKhSlFwBAAAAbAAIIKhSlFwBAAAAAAA==.',['牛德']='牛德狠丶:BAACLAAFFH83AAMZAAcIoxt8BwA1AgAZAAcIoxt8BwA1AgATAAIIswyDJgB+AAAsAAQKfyIAAhkACAjXHFggAG0CABkACAjXHFggAG0CAAAA.',['牛排']='牛排七层熟:BAAALAAECgEIAQAAAA==.',['牜牛']='牜牛:BAAALAAFFAIIAgAAAA==.',['特丶']='特丶仑苏:BAAALAAECgIIAgAAAA==.',['特曼']='特曼:BAAALAAECgMIAwAAAA==.',['犀利']='犀利犀利:BAABLAAFFH8FAAMGAAII1QfgmwA4AAAGAAII1QfgmwA4AAAQAAIIDwLUHwAeAAAAAA==.',['狂怒']='狂怒金刚:BAABLAAFFH8GAAIJAAII1QTHNwAoAAAJAAII1QTHNwAoAAAAAA==.',['狂舞']='狂舞手术刀:BAACLAAFFH8RAAIWAAYIFw8FJgBFAQAWAAYIFw8FJgBFAQAsAAQKfxUAAhYABggJIsBqABQCABYABggJIsBqABQCAAAA.',['狐言']='狐言乱语:BAAALAADCgIIAgAAAA==.',['狼女']='狼女:BAAALAAECgYIBgAAAA==.',['猛犸']='猛犸小小新:BAAALAAFFAIIAgAAAA==.',['王炸']='王炸又不在:BAAALAAECggIEQAAAA==.',['王瓜']='王瓜瓜丶:BAACLAAFFH8HAAIMAAYIXQ8oOQBbAQAMAAYIXQ8oOQBbAQAsAAQKfxoAAgwABghFH7VJALMBAAwABghFH7VJALMBAAAA.',['玩偶']='玩偶好萌啊:BAABLAAFFH8GAAIMAAYIHh5XJwCVAQAMAAYIHh5XJwCVAQAAAA==.',['琦梦']='琦梦:BAACLAAFFH8KAAIbAAII4gFAIQBQAAAbAAII4gFAIQBQAAAsAAQKfycAAxsACAi1D140AHkBABsACAiCDV40AHkBABYABgh2DslzABoBAAAA.',['琪安']='琪安娜丶月影:BAAALAADCgEIAQAAAA==.',['瓦里']='瓦里安:BAAALAAFFAIIBAAAAA==.',['用萨']='用萨忽悠你:BAAALAAECggICAAAAA==.',['电动']='电动小野野:BAAALAAECggICAAAAA==.电动小马达:BAAALAAECgUICwAAAA==.',['画画']='画画的北鼻:BAAALAAFFAIIAgAAAA==.',['疏楼']='疏楼龙宿:BAAALAAFFAIIAgAAAA==.',['疾鹰']='疾鹰七痕斩:BAAALAADCggICAAAAA==.',['痛覚']='痛覚残留:BAABLAAFFH8NAAIGAAYIJyG4GADWAQAGAAYIJyG4GADWAQAAAA==.',['痞味']='痞味小魔女:BAAALAAECgYIBgAAAA==.',['看上']='看上去喜感:BAAALAADCggICAABLAAECgcIFAABAHMZAA==.',['瞄准']='瞄准射击冲锋:BAAALAADCgYIBgAAAA==.',['破灭']='破灭的圣光:BAAALAADCgMIAwAAAA==.',['祁德']='祁德笼东强:BAAALAADCgIIAgAAAA==.',['祖格']='祖格斯图卡:BAAALAAFFAEIAQAAAA==.',['笑着']='笑着流泪:BAAALAADCgUIBQAAAA==.',['笑面']='笑面如花:BAAALAADCgUIBQAAAA==.',['筱米']='筱米丶酥妻:BAAALAAECgYIBgAAAA==.',['紅塵']='紅塵印像:BAABLAAFFH8GAAIMAAIImwhLsQA2AAAMAAIImwhLsQA2AAAAAA==.紅塵堕影:BAAALAAECgQIBAAAAA==.',['紅姬']='紅姬澱芐:BAABLAAFFH8RAAIMAAYICx0yIACxAQAMAAYICx0yIACxAQAAAA==.',['紫日']='紫日:BAABLAAECn8bAAIMAAYISRe1mAAkAQAMAAYISRe1mAAkAQAAAA==.',['紫水']='紫水晶丶:BAABLAAFFH8JAAMKAAUIrRbeLAACAQAKAAQIeRTeLAACAQABAAEIigN6TwA1AAAAAA==.',['紫罗']='紫罗幻灵:BAAALAAECgcIEQAAAA==.',['繁星']='繁星燃尽:BAABLAAFFH8GAAIHAAYIahfjHgCHAQAHAAYIahfjHgCHAQAAAA==.',['纪念']='纪念逝去的你:BAABLAAFFH8FAAIDAAIIHBDCVwBDAAADAAIIHBDCVwBDAAAAAA==.',['纳格']='纳格兰的风:BAAALAAECgIIAgAAAA==.',['终级']='终级战将:BAAALAAECgYICQAAAA==.',['绿绿']='绿绿丶太阳:BAABLAAFFH8fAAIIAAUIXSOvGgCQAQAIAAUIXSOvGgCQAQAAAA==.',['网络']='网络鸟人:BAAALAADCgMIAwAAAA==.',['罪恶']='罪恶的小三:BAAALAAECgQIBAAAAA==.',['罪梦']='罪梦者:BAABLAAFFH8GAAIMAAIIuhMdnABAAAAMAAIIuhMdnABAAAAAAA==.',['老傻']='老傻老贾:BAAALAAECgMIAwAAAA==.',['老司']='老司机超叔:BAABLAAFFH8fAAIHAAYI8Qy9IgDZAAAHAAYI8Qy9IgDZAAAAAA==.',['老婆']='老婆是个猪:BAAALAADCgIIAgAAAA==.',['老子']='老子是斯文人:BAAALAAECgEIAQAAAA==.',['老练']='老练的假冲动:BAABLAAFFH8FAAIZAAIIiBDiLgB3AAAZAAIIiBDiLgB3AAAAAA==.',['聖臩']='聖臩:BAAALAADCgcICgAAAA==.',['肉球']='肉球:BAAALAAFFAIIBAAAAA==.',['股二']='股二蛋:BAAALAAECgcICwAAAA==.',['胡作']='胡作非为的胡:BAAALAAFFAIIBAAAAA==.',['脱剑']='脱剑膝前横:BAAALAAFFAYIAgAAAA==.',['脾气']='脾气茶:BAAALAAECgYIEAAAAA==.',['臨淵']='臨淵:BAAALAAFFAIIAwAAAA==.',['自摸']='自摸恰二条:BAAALAAECgUIBQAAAA==.',['自由']='自由的风霜:BAAALAADCgYIBgAAAA==.',['致命']='致命之罚:BAABLAAFFH8HAAIHAAIIRA09SQCSAAAHAAIIRA09SQCSAAAAAA==.致命守护者:BAAALAAFFAIIBAAAAA==.',['舍予']='舍予土旦:BAAALAAECgEIAQAAAA==.',['艾斯']='艾斯卡诺:BAAALAADCgcIBwAAAA==.',['艾比']='艾比西安:BAAALAADCgYIBgAAAA==.',['芜罗']='芜罗亭魔梨威:BAACLAAFFH8WAAIYAAUIgQu4IwAhAQAYAAUIgQu4IwAhAQAsAAQKfzcAAxgACAjsFiY1AAgCABgACAjsFiY1AAgCAB4ACAggDYJAALkBAAAA.',['芜薇']='芜薇小草芯:BAAALAAECgYICQAAAA==.',['芜铭']='芜铭弑:BAACLAAFFH8YAAMOAAUI9hkrCwBcAQAOAAUI9hkrCwBcAQAPAAEIPQM4IAAzAAAsAAQKfysAAw4ACAjdIJgEAFYCAA4ACAjdIJgEAFYCAA8ABAjXEl01APQAAAAA.',['花开']='花开半夏:BAAALAAECgQIBwAAAA==.',['花心']='花心小甜甜:BAAALAAFFAIIAgAAAA==.',['花无']='花无缺:BAAALAAECgUIBQAAAA==.',['花魂']='花魂泣:BAABLAAFFH8FAAIeAAIIPhxnGQClAAAeAAIIPhxnGQClAAABLAAFFAYIJgAGAHIlAA==.',['苏卡']='苏卡捕猎:BAAALAADCgcIBwAAAA==.',['苏志']='苏志燮丶:BAAALAAFFAIIAgAAAA==.',['苏武']='苏武牧羊:BAAALAAECgMIAwAAAA==.',['若叶']='若叶睦:BAABLAAFFH8bAAMGAAcI8h8gDwDdAQAGAAcI8h8gDwDdAQAFAAIIhBu3CQDJAAAAAA==.',['荒野']='荒野丶地球:BAAALAAFFAIIAgAAAA==.荒野之息:BAAALAAFFAIIBAAAAA==.',['莉亚']='莉亚徳琳:BAAALAAECgYICwAAAA==.',['莫想']='莫想:BAACLAAFFH8GAAIRAAIIqgRRVQBxAAARAAIIqgRRVQBxAAAsAAQKfxcAAhEACAhbGWgyAHICABEACAhbGWgyAHICAAAA.',['莱雅']='莱雅娜:BAABLAAFFH8NAAIZAAQI1w8zJgDnAAAZAAQI1w8zJgDnAAAAAA==.',['菇凉']='菇凉妮别跑:BAAALAAECgYIBgAAAA==.',['菊之']='菊之爆:BAAALAAECgEIAQAAAA==.',['菲克']='菲克大魔王灬:BAAALAAECgYICQAAAA==.菲克尓灬:BAAALAAECgYIBgAAAA==.',['萧笙']='萧笙:BAAALAAFFAIIAgABLAAECggIEAAUAAAAAA==.',['萨满']='萨满丨祭司:BAAALAAECgYIBwAAAA==.',['萨漫']='萨漫:BAAALAAECgYIDAAAAA==.',['落月']='落月:BAAALAAECgYIBwAAAA==.',['蒙牛']='蒙牛真果粒:BAAALAAFFAIIBAAAAA==.',['薩菈']='薩菈塔斯:BAAALAAFFAEIAQAAAA==.',['蛋蛋']='蛋蛋都碎咯:BAAALAAECgUIBQAAAA==.',['血战']='血战骠羁:BAAALAADCgIIAgAAAA==.',['血蹄']='血蹄开恩:BAAALAAECgYIDAAAAA==.血蹄踏花开:BAABLAAECn8UAAIBAAcIcxncUgDAAQABAAcIcxncUgDAAQAAAA==.',['解臾']='解臾:BAAALAADCgQIBAAAAA==.',['请叫']='请叫我烟灰姐:BAAALAAECgYICAAAAA==.',['调皮']='调皮的蛮蛮:BAAALAAECgYICQAAAA==.',['费墨']='费墨:BAAALAADCgcIBwAAAA==.',['赤橙']='赤橙黄绿青蓝:BAAALAAECgIIAgAAAA==.',['赤氺']='赤氺断:BAAALAAECgMIAwAAAA==.',['超甜']='超甜猪猪奶茶:BAAALAAFFAIIAgAAAA==.',['路人']='路人灵修:BAAALAAECgYICQAAAA==.',['转瞬']='转瞬即逝:BAAALAAECgYICgAAAA==.',['转评']='转评赞:BAABLAAFFH8FAAIKAAMIrxOZKgCvAAAKAAMIrxOZKgCvAAAAAA==.',['轻松']='轻松愉快:BAAALAADCgEIAQAAAA==.',['辛多']='辛多雷血誓:BAAALAADCgEIAQAAAA==.',['还我']='还我初液:BAAALAAECggIEAAAAA==.',['还是']='还是开不了口:BAAALAAECgYICwAAAA==.',['进击']='进击的牛牛:BAABLAAFFH8JAAIGAAIIGBUhhQBDAAAGAAIIGBUhhQBDAAAAAA==.',['遗忘']='遗忘者的哀伤:BAAALAADCgQIBAAAAA==.',['遮天']='遮天之翼:BAAALAAECgQIBAAAAA==.',['邪月']='邪月之影:BAAALAAECgIIAgAAAA==.',['酷炫']='酷炫大龙:BAABLAAFFH8GAAICAAYIiBHzCwBhAQACAAYIiBHzCwBhAQAAAA==.',['里飞']='里飞沙:BAABLAAECn8UAAIVAAYI6x5EEQCxAQAVAAYI6x5EEQCxAQAAAA==.',['银狐']='银狐孤雀:BAABLAAECn8+AAIVAAgIyxwVCABFAgAVAAgIyxwVCABFAgAAAA==.',['闪烁']='闪烁之光:BAAALAAFFAIIAgAAAA==.',['闲狼']='闲狼赫萝丶:BAAALAAECgYIBwAAAA==.',['阳光']='阳光锈蚀:BAAALAAECgMIAwAAAA==.',['阿尔']='阿尔利亚德:BAAALAADCgEIAQAAAA==.',['阿巴']='阿巴阿巴丶:BAAALAAECgUIBQAAAA==.',['阿斯']='阿斯麦:BAAALAAFFAYIAwAAAA==.',['阿杉']='阿杉发大财:BAABLAAFFH8eAAINAAYIpxqwBQB7AQANAAYIpxqwBQB7AQAAAA==.',['阿牛']='阿牛:BAAALAADCgQIBAAAAA==.',['阿诗']='阿诗丹顿怒风:BAABLAAFFH8LAAIgAAIIRhJ4FQArAAAgAAIIRhJ4FQArAAAAAA==.',['阿那']='阿那电脑:BAAALAAECgIIAgAAAA==.',['阿里']='阿里多多:BAAALAAECgYIDAAAAA==.',['陌然']='陌然暗殇:BAAALAAECgYIBgAAAA==.',['陌蕗']='陌蕗丶荭蝶:BAAALAAECgYICgAAAA==.',['随便']='随便拽拽:BAAALAAECgMIAwAAAA==.',['隐隐']='隐隐惊雷:BAAALAAFFAIIAgAAAA==.',['雷雨']='雷雨岚牙:BAAALAAECgQIAwAAAA==.',['青絲']='青絲如煙:BAAALAAECgUIBQAAAA==.',['青雀']='青雀衔落花:BAABLAAFFH8IAAIHAAIImR2TSQBRAAAHAAIImR2TSQBRAAAAAA==.',['青青']='青青大草牛:BAAALAAECgEIAQAAAA==.',['静音']='静音丶:BAAALAAECgYIBgAAAA==.',['鞠婧']='鞠婧祎:BAAALAAECgIIAgAAAA==.',['顶部']='顶部顶得住:BAAALAAECgYIBgAAAA==.',['風丶']='風丶怒:BAABLAAECn8XAAIKAAgICCCOGwCrAgAKAAgICCCOGwCrAgAAAA==.',['风吹']='风吹熠熠爽:BAAALAAECgEIAQAAAA==.',['风神']='风神华梦:BAAALAAECgUICAAAAA==.',['飓风']='飓风之牛:BAABLAAECn8VAAIIAAgIJBSbJgDHAQAIAAgIJBSbJgDHAQAAAA==.',['飞扬']='飞扬:BAAALAAECgEIAQAAAA==.',['飞舞']='飞舞的小铁锤:BAABLAAFFH8FAAIKAAII+Q7/XABhAAAKAAII+Q7/XABhAAAAAA==.',['飞驰']='飞驰:BAABLAAFFH8GAAIHAAIImhF8QQCYAAAHAAIImhF8QQCYAAAAAA==.',['香蕉']='香蕉不那那:BAAALAADCgcIAQAAAA==.',['骚猪']='骚猪佩奇:BAAALAAFFAQIBAAAAA==.',['高等']='高等数学:BAAALAAECgYIBwAAAA==.',['鬼卞']='鬼卞:BAAALAAECgYIBgAAAA==.',['鮮血']='鮮血乄凝聚:BAAALAAFFAIIBAAAAA==.',['鱼子']='鱼子酱:BAABLAAFFH8IAAIIAAIINBCwNQCZAAAIAAIINBCwNQCZAAAAAA==.',['鱼摆']='鱼摆摆了不起:BAABLAAECn8eAAITAAcI/hrfGACpAQATAAcI/hrfGACpAQABLAAFFAgINgACAH8cAA==.',['鲁媚']='鲁媚:BAABLAAFFH8IAAIMAAQIWw8cXwDFAAAMAAQIWw8cXwDFAAAAAA==.',['鳌丶']='鳌丶少丶保:BAAALAAECgQIBAAAAA==.',['鹿鹿']='鹿鹿:BAAALAAECgEIAQAAAA==.',['黄昏']='黄昏时:BAABLAAFFH8MAAIGAAQIvxknTQD2AAAGAAQIvxknTQD2AAAAAA==.黄昏枭:BAAALAAECgYIDAAAAA==.',['黯月']='黯月之殇:BAAALAAECgMIAwAAAA==.',['龐嘫']='龐嘫大物:BAAALAAECgUICwAAAA==.',['龙果']='龙果果丶天子:BAAALAAECgIIAgAAAA==.龙果果丶蜃弦:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end