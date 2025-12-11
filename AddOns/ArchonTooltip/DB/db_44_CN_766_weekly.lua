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
 local lookup = {'Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','DeathKnight-Frost','Warrior-Protection','Unknown-Unknown','Mage-Arcane','Mage-Fire','Warrior-Fury','DeathKnight-Blood','Druid-Balance','Warlock-Destruction','Warlock-Demonology','Evoker-Devastation','Druid-Restoration','Mage-Frost','DemonHunter-Vengeance','Priest-Discipline','Monk-Brewmaster','Shaman-Restoration','Priest-Holy','Paladin-Holy','Priest-Shadow','Evoker-Preservation','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Hunter-Marksmanship',}; local provider = {region='CN',realm='瓦拉斯塔兹',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Angela:BAAALAAECgYIDQAAAA==.',Bi='Bielle:BAAALAAECgIIAgAAAA==.',Bl='Bluff:BAABLAAFFH8VAAIBAAYISBlOKACSAQABAAYISBlOKACSAQAAAA==.',Ch='Chinamobile:BAACLAAFFH8bAAICAAYIyRukFwCUAQACAAYIyRukFwCUAQAsAAQKfyUAAgIACAjxJCMOAEQDAAIACAjxJCMOAEQDAAAA.Chrisqq:BAABLAAFFH8aAAIDAAYI8BQLBwBbAQADAAYI8BQLBwBbAQAAAA==.',Cr='Crissy:BAAALAADCggICAAAAA==.',Ga='Gawain:BAAALAAECgUIBQAAAA==.',Ha='Hades:BAAALAADCgcIDQAAAA==.',Ic='Iceredtea:BAAALAAECgYIDAAAAA==.',La='Laknight:BAAALAAECggICAAAAA==.Laphy:BAAALAAECggICAAAAA==.',Ni='Nightstalke:BAAALAAFFAEIAQAAAA==.',Sh='Shandelzare:BAAALAAECgYICQAAAA==.',Sl='Slytherin:BAABLAAFFH8NAAIEAAUI0g39RwAZAQAEAAUI0g39RwAZAQAAAA==.',So='Soul:BAAALAAECggIEAABLAAFFAgIBgAEALoRAA==.',Th='Thoomars:BAAALAAECgQIBAAAAA==.',To='Tomas:BAAALAAECgYIBwAAAA==.',Yu='Yueyue:BAABLAAFFH8LAAIFAAIIIBSzLQA2AAAFAAIIIBSzLQA2AAABLAAFFAgIBAAGAAAAAA==.',['一发']='一发奶穿你:BAAALAAECgcIBwAAAA==.',['一砖']='一砖闹倒:BAAALAAECgYICgAAAA==.',['万碧']='万碧瑶:BAAALAAECgUIBgAAAA==.',['不给']='不给马儿吃草:BAAALAAFFAQIBAAAAA==.',['专打']='专打小屁屁:BAAALAAFFAIIAgAAAA==.',['东关']='东关咚咚霸:BAAALAAECgIIAgAAAA==.',['东隅']='东隅:BAACLAAFFH8TAAMHAAYI2hnUCwALAgAHAAYI2hnUCwALAgAIAAEIzQzlDABEAAAsAAQKfyMAAgcACAgZIA4nALACAAcACAgZIA4nALACAAAA.',['丨擎']='丨擎天丨:BAABLAAFFH8NAAIBAAUIhRYIRwAuAQABAAUIhRYIRwAuAQAAAA==.',['丷维']='丷维多利亚丷:BAAALAAECgYIBgAAAA==.',['丷重']='丷重返巅峰丷:BAAALAAFFAIIBAABLAAFFAcIDgAJAPoQAA==.',['丹尼']='丹尼爵士:BAAALAAECgYIDgAAAA==.',['乐乐']='乐乐:BAABLAAFFH8GAAIKAAIIkw2jGgA2AAAKAAIIkw2jGgA2AAAAAA==.',['亵渎']='亵渎:BAAALAADCgEIAQAAAA==.',['人没']='人没脸树没皮:BAAALAAECgUIBQAAAA==.',['伊珞']='伊珞恩:BAACLAAFFH8lAAILAAUIqB+mEwBIAQALAAUIqB+mEwBIAQAsAAQKfx4AAgsACAifHgIZAJkCAAsACAifHgIZAJkCAAAA.',['信仰']='信仰孤狼:BAAALAAECgYIEgAAAA==.',['倾刃']='倾刃:BAABLAAFFH8KAAIEAAIItBVIYACYAAAEAAIItBVIYACYAAAAAA==.',['偷偷']='偷偷开心:BAAALAAECgYIBgAAAA==.',['傲气']='傲气嗜战:BAAALAAECgEIAQAAAA==.傲气寒冰:BAAALAADCgIIAgAAAA==.',['儺翼']='儺翼:BAABLAAECn8iAAMMAAgIXhQOKQCyAQAMAAgIXhQOKQCyAQANAAEI8wkLNwA1AAABLAAFFAQIEAAOANIPAA==.',['元宝']='元宝:BAABLAAFFH8OAAMLAAUIKQkaHwDJAAALAAUIKQkaHwDJAAAPAAQIDgX9MgCdAAAAAA==.',['先祖']='先祖老妈:BAAALAADCgQIBAAAAA==.',['克图']='克图格亚:BAAALAAECgYICAAAAA==.',['兔巴']='兔巴妹:BAAALAADCggICAAAAA==.',['兔骑']='兔骑士:BAABLAAECn8YAAICAAcIwhl4TgByAQACAAcIwhl4TgByAQAAAA==.',['养了']='养了只羊:BAAALAAECgEIAQAAAA==.',['冰镇']='冰镇酸梅汤:BAAALAAFFAIIAgAAAA==.',['凝视']='凝视深渊:BAAALAAFFAIIAgAAAA==.',['刘德']='刘德华:BAAALAAFFAgIBAAAAA==.',['勿入']='勿入天堂:BAACLAAFFH8ZAAIQAAYIpRygAwClAQAQAAYIpRygAwClAQAsAAQKfyoAAxAACAhfJZIEAEkDABAACAhfJZIEAEkDAAcAAQj7DVAKASkAAAAA.',['南家']='南家丨千秋:BAAALAAECgYICgAAAA==.南家丨夏奈:BAACLAAFFH8vAAMHAAYITiIXFwDGAQAHAAYITiIXFwDGAQAQAAEIMiAlHQBRAAAsAAQKfyUAAwcACAjwInsVAAIDAAcACAilInsVAAIDABAABAiRI4E/AHMBAAAA.',['占戈']='占戈士向右:BAAALAAECgYIDwAAAA==.',['原来']='原来乳刺:BAAALAAECgYIDAAAAA==.',['叮裆']='叮裆猫:BAAALAAECgYICgAAAA==.',['吉尔']='吉尔格拉德:BAAALAAECgQIBAAAAA==.',['君無']='君無憂:BAAALAADCggICAAAAA==.',['君醉']='君醉笑紅颜:BAAALAAECgEIAQAAAA==.君醉笑红颜:BAAALAAECgQIBAAAAA==.',['哈斯']='哈斯塔:BAAALAAECgYIBgAAAA==.',['嘿小']='嘿小猩猩:BAAALAAECgcIBwAAAA==.',['嚯鹅']='嚯鹅丶好水儿:BAAALAADCgMIAwAAAA==.',['土丢']='土丢丢:BAABLAAFFH8IAAIBAAgI5QOEYwCrAAABAAgI5QOEYwCrAAAAAA==.',['圣光']='圣光大地:BAAALAAECgYIDwAAAA==.',['圣域']='圣域传奇:BAABLAAFFH8IAAICAAII1wkVcgA9AAACAAII1wkVcgA9AAAAAA==.',['夜烬']='夜烬离:BAAALAAECgYICgAAAA==.',['大啵']='大啵浪:BAAALAAFFAIIBAAAAA==.',['大家']='大家说累不累:BAABLAAFFH8JAAIBAAYIwxSTPABRAQABAAYIwxSTPABRAQAAAA==.',['大帝']='大帝丶:BAABLAAFFH8JAAIEAAIIUQ7geQBJAAAEAAIIUQ7geQBJAAAAAA==.',['大戟']='大戟戟:BAAALAAFFAIIBAAAAA==.',['大橙']='大橙崽汁:BAAALAAECgYICgAAAA==.',['大汉']='大汉棋圣刘启:BAABLAAFFH8IAAIEAAIICBqZZACWAAAEAAIICBqZZACWAAAAAA==.',['大老']='大老白:BAAALAAECggICAAAAA==.',['天后']='天后:BAABLAAFFH8OAAICAAUIhx6rIgBYAQACAAUIhx6rIgBYAQAAAA==.',['天桥']='天桥大呲花:BAAALAAECgIIAgAAAA==.',['太老']='太老爷:BAABLAAFFH8GAAIEAAIIpSEHNgDHAAAEAAIIpSEHNgDHAAAAAA==.',['夸克']='夸克:BAABLAAFFH8hAAIBAAUIOSOhJACfAQABAAUIOSOhJACfAQAAAA==.',['奈何']='奈何桥灬渡:BAABLAAECn8WAAIEAAYIKh99cgASAgAEAAYIKh99cgASAgAAAA==.',['好烦']='好烦:BAABLAAFFH8GAAIRAAII3gEZGwBGAAARAAII3gEZGwBGAAAAAA==.',['将离']='将离:BAAALAADCgYIBgAAAA==.',['小娘']='小娘子丶:BAAALAADCggICAAAAA==.',['小狗']='小狗狗快跑跑:BAAALAAECgYIBwAAAA==.',['小訫']='小訫摘月:BAAALAADCgYIDAAAAA==.',['小龍']='小龍女:BAABLAAFFH8GAAISAAIIwgiBBABzAAASAAIIwgiBBABzAAAAAA==.',['尐娘']='尐娘子:BAAALAADCggICAAAAA==.',['尐灬']='尐灬洒满:BAAALAAECgEIAQAAAA==.',['尛曦']='尛曦:BAABLAAECn8UAAIJAAgImRqoOABTAgAJAAgImRqoOABTAgAAAA==.',['就是']='就是这么鸽:BAAALAAFFAIIBAAAAA==.',['就这']='就这吧:BAABLAAFFH8GAAITAAIIkAr7IAAxAAATAAIIkAr7IAAxAAABLAAFFAgIDwATAL4hAA==.',['山花']='山花烂漫时丶:BAAALAAFFAIIAgAAAA==.',['带走']='带走在一损间:BAAALAAECggICAAAAA==.',['弎栗']='弎栗:BAAALAAECgUIBQAAAA==.',['得儿']='得儿呛:BAAALAAECgYIBgAAAA==.',['德憋']='德憋:BAAALAAFFAIIAgAAAA==.',['怒天']='怒天刑者:BAAALAADCgEIAQAAAA==.',['想被']='想被大调查吗:BAAALAAECgQIBAAAAA==.',['愈灵']='愈灵者乔纳斯:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的大虾:BAAALAAECgYIBgAAAA==.',['我爱']='我爱吃煎饼:BAAALAADCgcIBwAAAA==.',['扑滿']='扑滿乌力:BAAALAAECgYIDAAAAA==.',['打个']='打个响指:BAAALAAFFAYIBAAAAA==.',['扶摇']='扶摇:BAAALAAECgMIAwAAAA==.',['撸牛']='撸牛妞:BAAALAAECgMIAwAAAA==.',['擎天']='擎天:BAAALAAECgYIDAAAAA==.',['断筱']='断筱竹:BAAALAAECgYIBgAAAA==.',['旅者']='旅者:BAAALAADCgIIAgABLAAFFAMIEQAUAB8gAA==.',['无影']='无影山:BAAALAAECgMIBgAAAA==.',['无聊']='无聊的夜晚:BAAALAAECgUIBgAAAA==.',['无言']='无言:BAAALAAECgIIAgAAAA==.',['星願']='星願丿天堂:BAAALAAECgYIDwAAAA==.',['暴胎']='暴胎易经丸:BAAALAAECgIIAgAAAA==.',['最终']='最终皆亡:BAAALAAECgYIDQAAAA==.',['月桂']='月桂葉:BAABLAAFFH8KAAIBAAII9xQpZwCGAAABAAII9xQpZwCGAAAAAA==.',['术学']='术学叫兽:BAABLAAECn8UAAIMAAYIMwUgdQCfAAAMAAYIMwUgdQCfAAAAAA==.',['桐桐']='桐桐丶含含:BAAALAAFFAIIBAAAAA==.',['檀香']='檀香:BAAALAADCggICAAAAA==.',['死涛']='死涛涛:BAAALAAECgYIBgAAAA==.',['毛麦']='毛麦坑坑:BAAALAAECgcIBgAAAA==.毛麦非狗:BAAALAAECggICAAAAA==.',['永不']='永不为奴:BAAALAAECgYIBwAAAA==.',['永远']='永远的永远:BAAALAAECgYIDAAAAA==.',['汉德']='汉德汗死:BAAALAAECgYIEgAAAA==.',['洞庭']='洞庭皮皮虾:BAABLAAFFH8qAAIBAAcISibVBACjAgABAAcISibVBACjAgABLAAFFAgINAAVAJ0jAA==.',['海烟']='海烟:BAAALAAECgYIBgAAAA==.',['深攻']='深攻鲍:BAABLAAECn8YAAIQAAYINxBpIwAFAQAQAAYINxBpIwAFAQAAAA==.',['温柔']='温柔的守护:BAAALAAECgYICAAAAA==.',['渴饮']='渴饮风霜:BAABLAAFFH8cAAIHAAUIYRWcMwAwAQAHAAUIYRWcMwAwAQABLAAFFAYIFQABAEgZAA==.',['满堂']='满堂华彩:BAAALAAECgMIAwAAAA==.',['满满']='满满回忆:BAAALAAECgMIAwAAAA==.',['灵风']='灵风窃影:BAAALAAFFAIIAgAAAA==.',['炫天']='炫天:BAAALAAECgYIBgAAAA==.',['牛氣']='牛氣冲天:BAAALAADCggICgAAAA==.',['牛牪']='牛牪犇:BAABLAAFFH8XAAMCAAYIQhjJIQBdAQACAAUIKxvJIQBdAQAWAAQI8R25GQDuAAAAAA==.',['玄武']='玄武酷酷熊:BAAALAAECgUIBQAAAA==.',['珐岚']='珐岚:BAACLAAFFH8JAAIHAAIIhBICSACYAAAHAAIIhBICSACYAAAsAAQKfxgAAwcABggLHWdWAAECAAcABggLHWdWAAECABAAAQi+C1aTADQAAAEsAAUUAggKAAQAtBUA.',['班纳']='班纳:BAAALAADCgMIAwAAAA==.',['真無']='真無霜:BAABLAAFFH8IAAMLAAYIsA1nGgADAQALAAUIXQ9nGgADAQAPAAMIXQkZNwCOAAAAAA==.',['瞄人']='瞄人奉:BAABLAAECn8WAAICAAYIFxGxawArAQACAAYIFxGxawArAQAAAA==.',['碧雪']='碧雪琪:BAACLAAFFH8fAAIQAAYIOBbPBACAAQAQAAYIOBbPBACAAQAsAAQKfyYABBAABghMH10QAL4BABAABghMH10QAL4BAAcAAgjYD0diAHYAAAgAAQiICH0VACoAAAAA.',['秋刀']='秋刀鱼的滋味:BAAALAAECgMIAwAAAA==.',['秋深']='秋深渐入冬:BAAALAAFFAIIAgAAAA==.',['等下']='等下个季节:BAACLAAFFH8KAAMVAAIIxA6RMgCLAAAVAAIIxA6RMgCLAAAXAAII0hqzJQBOAAAsAAQKfxgAAhUACAj+FJU4APkBABUACAj+FJU4APkBAAAA.',['等价']='等价交换:BAAALAAECgIIAgAAAA==.',['粉色']='粉色回忆:BAAALAAECgYIBgAAAA==.粉色海洋:BAABLAAFFH8HAAMOAAIIbhANGgCLAAAOAAIIbhANGgCLAAAYAAIIoxb/FwCIAAAAAA==.',['糖豆']='糖豆不甜:BAAALAAECgYIBgAAAA==.',['绚烂']='绚烂丶烟花祭:BAABLAAECn8gAAICAAYIyBOauACSAQACAAYIyBOauACSAQAAAA==.',['美女']='美女如画:BAAALAADCgMIAwAAAA==.',['老腊']='老腊肉:BAAALAADCgEIAQAAAA==.',['耐瑟']='耐瑟瑞尔:BAABLAAFFH8WAAMMAAUIhw+SPQAKAQAMAAUIhw+SPQAKAQANAAIIew2zGwCJAAABLAAFFAgIEAAMAKEMAA==.',['胜利']='胜利图腾:BAAALAADCgEIAQAAAA==.',['脸皮']='脸皮能格擋:BAAALAAECgUICAAAAA==.',['臭没']='臭没溜儿:BAAALAADCgEIAQAAAA==.',['致青']='致青春:BAAALAAFFAIIAgAAAA==.',['艾俄']='艾俄洛斯:BAAALAAECggIEAAAAA==.',['若雨']='若雨:BAAALAAECgEIAQAAAA==.',['莫知']='莫知冬:BAAALAAECgMIBAAAAA==.莫知夏:BAAALAAECgYIBgAAAA==.莫知春:BAAALAAFFAEIAQAAAA==.',['菝菝']='菝菝:BAAALAADCggICwAAAA==.',['菩提']='菩提小牧:BAAALAAFFAIIAgAAAA==.',['蓝翔']='蓝翔高级陪读:BAAALAAECgYICQAAAA==.',['蛋蛋']='蛋蛋抠脚:BAAALAAECgYICgAAAA==.',['蝶乱']='蝶乱蜂狂:BAAALAADCgMIAwAAAA==.',['融化']='融化的召唤:BAABLAAECn8XAAMZAAcIlQcPGwDWAAAZAAcIlQcPGwDWAAAaAAEIkwOmUgApAAAAAA==.',['蟹子']='蟹子莱莱:BAAALAADCgMIAwAAAA==.',['血夜']='血夜圣光:BAAALAAECgIIAgAAAA==.',['街角']='街角抽烟:BAABLAAECn8WAAIZAAYIegfOGgDZAAAZAAYIegfOGgDZAAAAAA==.',['西红']='西红柿首富:BAAALAAECgIIAwAAAA==.',['诡异']='诡异墨水:BAABLAAFFH8hAAIHAAYI0BEnJQCAAQAHAAYI0BEnJQCAAQAAAA==.诡异的丹:BAABLAAFFH8UAAIbAAYIxRoGFgC2AQAbAAYIxRoGFgC2AQAAAA==.诡异的傲:BAABLAAFFH8UAAICAAYIVx7uDwDFAQACAAYIVx7uDwDFAQAAAA==.诡异的战:BAABLAAFFH8bAAIJAAYIkBLfGgCOAQAJAAYIkBLfGgCOAQAAAA==.诡异的猎:BAABLAAFFH8bAAIBAAYI7B1DIgCpAQABAAYI7B1DIgCpAQAAAA==.',['起个']='起个名字好难:BAAALAAECgIIAgAAAA==.',['辞暮']='辞暮尔尔:BAAALAAECgYICwAAAA==.辞暮尔尔丶:BAAALAAECgYIBgAAAA==.',['过去']='过去也是人:BAAALAAECgYICwAAAA==.',['还不']='还不错:BAAALAAECgYIEAAAAA==.',['那一']='那一秒丶後灬:BAAALAAECggIEAAAAA==.',['郑映']='郑映宇:BAAALAAFFAIIAgAAAA==.郑映熹:BAAALAAFFAIIAgAAAA==.',['醉云']='醉云逐月牛:BAAALAAECgYIBgAAAA==.',['钟跑']='钟跑跑:BAAALAAECgYIDQAAAA==.',['铠盾']='铠盾:BAAALAAECgQIBgAAAA==.',['锁甲']='锁甲三废:BAABLAAECn8YAAMBAAgI2SMhGwDvAgABAAgI2SMhGwDvAgAcAAgI8xt1BgASAgAAAA==.锁甲不废:BAAALAAFFAIIAgAAAA==.',['阿修']='阿修罗:BAABLAAECn8VAAIbAAYIugobaQDnAAAbAAYIugobaQDnAAAAAA==.',['隅东']='隅东东:BAAALAAECggIDAAAAA==.',['隐杀']='隐杀风灵:BAAALAAFFAIIAgAAAA==.',['霸气']='霸气双刀:BAABLAAECn8kAAIbAAYIPhSeTwAsAQAbAAYIPhSeTwAsAQAAAA==.',['青丘']='青丘:BAAALAAECgYICQAAAA==.',['青面']='青面猎獠牙:BAAALAADCgEIAQAAAA==.',['领悟']='领悟的赐福:BAAALAAECgYIBgAAAA==.',['风尘']='风尘:BAABLAAFFH8GAAIEAAYIIQCIqAAkAAAEAAYIIQCIqAAkAAAAAA==.',['飘逸']='飘逸之狂冰:BAAALAAECgEIAQAAAA==.飘逸冰冰:BAAALAAECgQIBAAAAA==.',['饺子']='饺子:BAAALAAECgYICgAAAA==.',['马大']='马大胆儿:BAAALAAECggICAAAAA==.',['驱风']='驱风者:BAAALAAECgUIBwAAAA==.',['鬼蜮']='鬼蜮先驱:BAACLAAFFH8RAAIUAAIIuBabPQCGAAAUAAIIuBabPQCGAAAsAAQKfywAAhQACAjKGHM6AC8CABQACAjKGHM6AC8CAAAA.鬼蜮神箭手:BAAALAAFFAIIAwAAAA==.',['魇梦']='魇梦:BAAALAAECgEIAQAAAA==.',['魔羯']='魔羯:BAABLAAFFH8HAAIbAAIIxxZuUABJAAAbAAIIxxZuUABJAAABLAAFFAIICgAEALQVAA==.',['鸡触']='鸡触:BAAALAADCggICAAAAA==.',['麦兜']='麦兜炎爆贼溜:BAAALAAECgUIDAAAAA==.麦兜的敵氪:BAAALAAECgYICgAAAA==.麦兜的朮爹:BAAALAAECgYICQAAAA==.麦兜的皮卡丘:BAAALAAECgIIAgAAAA==.',['麻花']='麻花儿:BAAALAAECgYIDQAAAA==.',['黑小']='黑小牛:BAAALAADCggICAAAAA==.',['黝黑']='黝黑的小刚:BAAALAAECgYICQAAAA==.',['龙城']='龙城少帅:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end