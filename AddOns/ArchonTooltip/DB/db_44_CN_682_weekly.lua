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
 local lookup = {'Priest-Discipline','Priest-Holy','DeathKnight-Frost','Hunter-BeastMastery','Mage-Arcane','Mage-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Unknown-Unknown','Warrior-Fury','Druid-Restoration','Paladin-Retribution','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Monk-Mistweaver','Warrior-Arms','Warrior-Protection','Druid-Guardian','Druid-Balance','Hunter-Marksmanship','Hunter-Survival','Shaman-Restoration','Paladin-Protection','Rogue-Outlaw','Shaman-Elemental','Rogue-Assassination','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Unholy','Rogue-Subtlety','DeathKnight-Blood',}; local provider = {region='CN',realm='戈古纳斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Ageless:BAAALAAECgEIAQAAAA==.',As='Ashveil:BAAALAADCgcIBwAAAA==.',At='Atlantls:BAAALAAECggIDAAAAA==.',Ba='Babyrain:BAABLAAFFH8IAAMBAAIIohY9BACFAAABAAIIohY9BACFAAACAAIIdwHkTABGAAAAAA==.',Bl='Bluecherry:BAAALAAECgYIBgAAAA==.',Bu='Buestos:BAAALAAECgUICAAAAA==.',Ca='Canye:BAABLAAFFH8ZAAIDAAYInBvTHwC1AQADAAYInBvTHwC1AQAAAA==.',Ch='Cherries:BAABLAAFFH8MAAIEAAYINxs3DADWAQAEAAYINxs3DADWAQAAAA==.Cherrypink:BAAALAAECgQIBAAAAA==.Chouwendesi:BAAALAAECgYIBgAAAA==.Chuyb:BAAALAAFFAIIAwAAAA==.',Cr='Crescentrose:BAAALAAFFAIIAgAAAA==.Crz:BAABLAAECn8gAAMFAAYIsRv+JACQAQAFAAYIsRv+JACQAQAGAAEIahtIQgBNAAAAAA==.',De='Deris:BAAALAAFFAIIAgAAAA==.',Di='Diamonds:BAAALAAECgYIBgAAAA==.Dirge:BAAALAAECgYIEAAAAA==.',He='Herman:BAAALAAECgcICwAAAA==.',Hu='Huntingheart:BAAALAAECgYIBgAAAA==.',Ik='Ikun:BAAALAAECgQIBAAAAA==.',Ko='Kongmencang:BAAALAAECgYIEgAAAA==.',Li='Lilith:BAAALAAECgQIBAAAAA==.',Lo='Lovelymoon:BAABLAAECn8XAAIEAAcIMxqfRwC4AQAEAAcIMxqfRwC4AQAAAA==.',Mi='Mimimo:BAAALAAFFAIIBAAAAA==.',Mo='Mortis:BAABLAAFFH8GAAIHAAIIewjIFwBXAAAHAAIIewjIFwBXAAAAAA==.',Nr='Nrcc:BAAALAAECgYICQAAAA==.',Pi='Piscesl:BAAALAADCgQIBAAAAA==.',Qu='Qunatum:BAAALAAECgYICQAAAA==.',Ro='Root:BAAALAAECgUICAAAAA==.',Tr='Tristan:BAAALAAECgYICAAAAA==.',Vo='Voodo:BAAALAADCgYIBgAAAA==.',Wi='Wickedmoon:BAACLAAFFH8FAAIIAAIIqQoeZQA7AAAIAAIIqQoeZQA7AAAsAAQKfx0AAggABgjVIPkeAOwBAAgABgjVIPkeAOwBAAAA.',Yc='Ycyc:BAABLAAFFH8XAAIEAAYI6x+KGwDFAQAEAAYI6x+KGwDFAQAAAA==.',['一口']='一口吐息奶满:BAAALAAECgIIAgAAAA==.',['一滴']='一滴都不剩了:BAAALAAFFAIIAgAAAA==.',['七个']='七个小妖姬:BAAALAAECgMIAwAAAA==.七个小妖婦:BAAALAAECggICAAAAA==.七个小妖精:BAAALAAECgcIBwABLAAFFAgIAgAJAAAAAA==.七个小灵姬:BAAALAAECgUIBQAAAA==.七个小瘙婦:BAAALAAECgEIAQAAAA==.七个小簜婦:BAAALAAECgYIBgAAAA==.七个小霪徒:BAAALAAFFAIIAgAAAA==.',['七夕']='七夕之夜:BAAALAAECggICQAAAA==.',['万宁']='万宁:BAAALAAECgIIAgAAAA==.',['不器']='不器:BAAALAAECgYICgAAAA==.',['不必']='不必流浪:BAAALAADCgEIAQAAAA==.',['不明']='不明眞相群众:BAABLAAECn8oAAIKAAgIaR4+JwCkAgAKAAgIaR4+JwCkAgAAAA==.',['不由']='不由衷:BAAALAAECgYIBgAAAA==.',['与你']='与你常在:BAAALAAECgUIBQAAAA==.',['专打']='专打馒头:BAAALAADCggICAAAAA==.',['丨无']='丨无赖丨:BAAALAAECggICAAAAA==.',['丶水']='丶水丶水丶:BAAALAAECgYIEwAAAA==.',['人头']='人头马轩尼诗:BAAALAAFFAIIBAAAAA==.',['今夕']='今夕是何年:BAAALAAFFAIIBAAAAA==.',['今天']='今天又胖了:BAAALAAECgYIDQAAAA==.',['仰望']='仰望星夜:BAABLAAECn8YAAIIAAYIRiOuPgBnAgAIAAYIRiOuPgBnAgAAAA==.',['优雅']='优雅二牛:BAAALAADCgMIAwAAAA==.优雅二蛮:BAAALAAECgMIAwAAAA==.',['似血']='似血残阳:BAAALAAECgYIBwAAAA==.',['低语']='低语沉沦:BAAALAAECgEIAQAAAA==.',['你真']='你真特么高:BAAALAAFFAIIAgAAAA==.',['你瞅']='你瞅瞅你:BAABLAAFFH8NAAILAAMI5xAIMACqAAALAAMI5xAIMACqAAAAAA==.',['偶系']='偶系丶阿冰哥:BAABLAAFFH8dAAIIAAYIBhzXEgDLAQAIAAYIBhzXEgDLAQAAAA==.',['偷看']='偷看女寝室:BAAALAAECgEIAQAAAA==.',['傲雪']='傲雪冰淩:BAAALAAECgUIBAAAAA==.傲雪天涯:BAACLAAFFH8QAAIMAAIIACL0TABiAAAMAAIIACL0TABiAAAsAAQKfyIAAwwACAgjIUwgAPECAAwACAgjIUwgAPECAA0AAwjuIkpLACsBAAAA.傲雪霏霏:BAABLAAECn8gAAIEAAcIbR5qKAAWAgAEAAcIbR5qKAAWAgAAAA==.',['光之']='光之审判者:BAACLAAFFH8QAAMNAAIIkhNaJAB/AAANAAIIkhNaJAB/AAAMAAII+RXGWQBKAAAsAAQKfzQAAwwACAjZH7gmANYCAAwACAjZH7gmANYCAA0ABQgVF8BEAEkBAAAA.',['兔丶']='兔丶尐术:BAACLAAFFH8QAAIOAAIIwBSOQgCVAAAOAAIIwBSOQgCVAAAsAAQKf0QAAw4ACAg2HHYaAA0CAA4ACAg2HHYaAA0CAA8ABAhbCS0jANAAAAAA.兔丶尐魔:BAABLAAECn8fAAIIAAYIOCBIIgDZAQAIAAYIOCBIIgDZAQAAAA==.',['兜兜']='兜兜豆豆:BAAALAAECggIDgAAAA==.',['八级']='八级大狂疯:BAABLAAFFH8HAAIMAAIIDxQuQgCdAAAMAAIIDxQuQgCdAAAAAA==.',['六弦']='六弦天秤:BAACLAAFFH8QAAIOAAII3R1FQwCUAAAOAAII3R1FQwCUAAAsAAQKf0UAAw4ACAjFHgcWAC4CAA4ACAjFHgcWAC4CABAAAwhGFEhvALkAAAAA.',['养一']='养一条死一条:BAAALAAFFAIIBAAAAA==.',['养猪']='养猪专业户:BAAALAADCgYIBgAAAA==.',['冰蓝']='冰蓝的风:BAABLAAECn8UAAIIAAcIQA07SABCAQAIAAcIQA07SABCAQAAAA==.',['冷酷']='冷酷彩虹:BAABLAAFFH8IAAIDAAIInBRsfABHAAADAAIInBRsfABHAAAAAA==.',['冻空']='冻空粉雪:BAAALAAECggICAAAAA==.',['凪雲']='凪雲:BAAALAAFFAIIAgAAAA==.',['凯瑟']='凯瑟琳娜:BAAALAAECgYIBgAAAA==.',['出来']='出来吓唬人:BAAALAADCgcIDAAAAA==.',['刀鋒']='刀鋒所向:BAAALAAECgYIDgAAAA==.',['初音']='初音未来:BAACLAAFFH8MAAIRAAIIUyQzCwDWAAARAAIIUyQzCwDWAAAsAAQKfyAAAhEACAi2HZELAKwCABEACAi2HZELAKwCAAAA.',['利维']='利维坦:BAACLAAFFH8SAAQKAAYIWhdKCQD9AQAKAAYIWhdKCQD9AQASAAEIiQ+CBABOAAATAAIILQryMgAvAAAsAAQKfxcAAxIABwi6I48GAGsBAAoABQhhJJUvAJsBABIABAhTHo8GAGsBAAEsAAUUCAg4AAoAeCMA.',['别打']='别打我我哭:BAAALAAECgcIBwAAAA==.',['刺客']='刺客伍陆柒:BAAALAADCgYIBgAAAA==.',['力量']='力量与农药:BAAALAAECgIIAgAAAA==.',['千乄']='千乄珏:BAAALAAECggIAQAAAA==.',['南北']='南北:BAABLAAECn8nAAIFAAcIWRDrfACZAQAFAAcIWRDrfACZAQAAAA==.',['博赫']='博赫斯逐日者:BAAALAAECgUIBQAAAA==.',['叛逆']='叛逆熊熊:BAAALAAECgQIBAAAAA==.',['可爱']='可爱到爆了:BAABLAAFFH8GAAILAAYIgBmNEAC/AQALAAYIgBmNEAC/AQAAAA==.',['司月']='司月:BAAALAAECgIIAgAAAA==.',['吴先']='吴先生:BAAALAADCgQIBQAAAA==.',['吴同']='吴同学:BAAALAAECgUIBQAAAA==.',['咕咕']='咕咕哒丶怒疯:BAACLAAFFH8FAAMLAAIIdRHNRABmAAALAAIIdRHNRABmAAAUAAII4Q7uDgAoAAAsAAQKfxsABAsACAgGHDctAC0CAAsACAgGHDctAC0CABQABAjGDwcYAMoAABUAAQg3EWpvAAAAAAAA.',['咕喵']='咕喵王:BAAALAAFFAIIAgAAAA==.',['哈基']='哈基糯米:BAAALAAECgMIBAAAAA==.',['哒哒']='哒哒:BAAALAAECgIIAQAAAA==.',['哲貨']='哲貨哥:BAAALAADCgIIAgAAAA==.',['唯爱']='唯爱丶雅典娜:BAAALAAFFAIIAgAAAA==.',['嘎玛']='嘎玛朵昂:BAAALAAECgYIBgAAAA==.',['囍刚']='囍刚刚:BAABLAAECn8UAAIMAAYIfR5qUQBrAQAMAAYIfR5qUQBrAQAAAA==.',['堕落']='堕落彩虹:BAAALAAFFAIIAgAAAA==.',['壹条']='壹条龙:BAAALAAECgQIBAAAAA==.',['壹粒']='壹粒蛋:BAAALAADCgIIAgAAAA==.',['复仇']='复仇者吉安那:BAAALAAECgEIAQAAAA==.',['大占']='大占卜师:BAAALAAECgYIDAAAAA==.',['大头']='大头爱生活:BAAALAAFFAIIAgAAAA==.',['大懒']='大懒虫:BAACLAAFFH8FAAIIAAIIGwlGVQCHAAAIAAIIGwlGVQCHAAAsAAQKfyMAAwgACAgRGoFqAPIBAAgACAgRGoFqAPIBAAcAAQjtBnJqACoAAAAA.',['大笨']='大笨猪哟:BAABLAAFFH8NAAIKAAMILBfSNQCbAAAKAAMILBfSNQCbAAAAAA==.',['大飞']='大飞二号:BAAALAAFFAIIAgAAAA==.',['天下']='天下大乱:BAAALAADCgIIAgAAAA==.',['天使']='天使的懲罰:BAAALAAECggICAAAAA==.',['天南']='天南星:BAAALAAECgIIAgAAAA==.',['天堂']='天堂引渡者:BAAALAADCgIIAgAAAA==.天堂手:BAAALAADCgIIAgAAAA==.',['天空']='天空之鸟:BAACLAAFFH8OAAILAAIInwn0TABYAAALAAIInwn0TABYAAAsAAQKf0wAAwsACAizEoYnAJ8BAAsABwhVFIYnAJ8BABUABwj3BeKEALAAAAAA.',['女武']='女武神:BAAALAAECgYICgAAAA==.',['好事']='好事的驼鹿:BAAALAAECgEIAQAAAA==.',['妃萱']='妃萱:BAACLAAFFH8MAAINAAIIVQn5KQBlAAANAAIIVQn5KQBlAAAsAAQKfycAAg0ABwhwD1ccAGUBAA0ABwhwD1ccAGUBAAAA.',['姜还']='姜还是老的辣:BAABLAAFFH8GAAIDAAIIwxBHaACUAAADAAIIwxBHaACUAAAAAA==.',['姬安']='姬安娜:BAABLAAFFH8YAAICAAYIKBEIGQCJAQACAAYIKBEIGQCJAQAAAA==.',['宿乄']='宿乄命:BAAALAAECgMIAwAAAA==.',['寂静']='寂静狩猎者:BAACLAAFFH80AAIEAAYIMiCoKACQAQAEAAYIMiCoKACQAQAsAAQKfx0AAgQACAjPIA0hADcCAAQACAjPIA0hADcCAAEsAAUUCAgcABUA4iQA.',['射不']='射不到人:BAAALAAECgYICwABLAAFFAMIDQAMAIoQAA==.',['小凶']='小凶许:BAAALAAECgYIBgAAAA==.',['小小']='小小笨猪:BAABLAAFFH8KAAIMAAUIExlFKAA4AQAMAAUIExlFKAA4AQAAAA==.',['小心']='小心我射你:BAAALAAECggIEAAAAA==.',['小爪']='小爪挠人:BAABLAAECn8fAAQWAAcIdBl8PwC5AQAWAAcIUxV8PwC5AQAEAAYIDRWOlwAlAQAXAAUIAQVrGwDcAAAAAA==.',['小蛮']='小蛮牛将军:BAAALAADCggICAAAAA==.',['小釭']='小釭炮:BAAALAADCgMIAwAAAA==.',['就想']='就想灬赖著你:BAAALAADCggICAAAAA==.',['屮囗']='屮囗屮:BAAALAAECgUIBgAAAA==.',['布兰']='布兰特:BAAALAAECgMIAwAAAA==.',['希莉']='希莉娅:BAAALAADCgEIAQAAAA==.',['常盘']='常盘台电磁炮:BAAALAADCgIIAgAAAA==.',['幻梦']='幻梦时空:BAAALAAECgcIBwAAAA==.',['弑夜']='弑夜龙灵:BAAALAAFFAIIAgAAAA==.',['形单']='形单:BAAALAAECgYICQAAAA==.',['影氺']='影氺瑶:BAAALAAECgYIBgAAAA==.',['影輕']='影輕岚:BAAALAAFFAMIAwAAAA==.影輕語:BAAALAAECgYIBwAAAA==.',['往事']='往事随臀:BAAALAADCggIHQAAAA==.',['微分']='微分丨几何:BAAALAADCgMIAwAAAA==.',['心术']='心术不正:BAAALAAECgYIDQAAAA==.',['恶魔']='恶魔女猎手:BAAALAADCgIIAgAAAA==.',['悬凌']='悬凌木:BAAALAAECgMIAwAAAA==.',['憂郁']='憂郁有罪:BAAALAADCggICAAAAA==.',['我们']='我们周一:BAAALAADCgIIAgAAAA==.',['我想']='我想加血:BAAALAAECgMIAwAAAA==.',['我是']='我是条小青龙:BAAALAAECgYICwAAAA==.',['战神']='战神幻梦:BAAALAADCgEIAQAAAA==.',['战胜']='战胜雅典娜:BAAALAADCgQIBAAAAA==.',['扎雷']='扎雷殁缇斯:BAAALAAECggIEAAAAA==.',['打人']='打人不太疼:BAACLAAFFH8NAAIMAAIIihB0bQA/AAAMAAIIihB0bQA/AAAsAAQKfzkAAgwACAgLGaczAMQBAAwACAgLGaczAMQBAAAA.',['打你']='打你妹三千:BAAALAAECgUIBQAAAA==.',['抹茶']='抹茶乐乐:BAAALAAECgYIDAAAAA==.',['拳击']='拳击手马大帅:BAAALAAECgEIAQAAAA==.',['挚扌']='挚扌月:BAAALAAFFAIIAgAAAA==.',['提里']='提里奥费丁:BAACLAAFFH8PAAIMAAMIMx2sJADBAAAMAAMIMx2sJADBAAAsAAQKfywAAgwACAj0I1kUACYDAAwACAj0I1kUACYDAAAA.',['敗者']='敗者食塵:BAAALAAECgYIBwAAAA==.',['旋饰']='旋饰:BAAALAAECgYICAAAAA==.',['昆卡']='昆卡:BAAALAAECgEIAQAAAA==.',['晓小']='晓小小:BAAALAADCgQIBAAAAA==.',['晨洋']='晨洋心宇:BAAALAADCgcIBwAAAA==.',['暗中']='暗中突刺:BAAALAAECggICAAAAA==.',['暴躁']='暴躁的无花果:BAAALAADCgUIBQAAAA==.',['更多']='更多等待:BAAALAAECgYIBgAAAA==.',['月半']='月半月半:BAAALAAFFAIIAgAAAA==.',['月影']='月影梵天:BAABLAAECn8gAAIEAAcIAh6LTQBEAgAEAAcIAh6LTQBEAgAAAA==.',['有一']='有一天没一天:BAAALAAFFAIIAgAAAA==.',['有緣']='有緣無份:BAAALAADCgIIBAAAAA==.',['朕和']='朕和你拼了:BAAALAAECgYICAAAAA==.',['未葬']='未葬的梦魇:BAABLAAECn8WAAIMAAcI7gjjeAAPAQAMAAcI7gjjeAAPAQAAAA==.',['术人']='术人:BAAALAAECgYICwAAAA==.',['朽木']='朽木露琪亚:BAAALAADCgQIBAAAAA==.',['李三']='李三刀:BAAALAAFFAYIAgAAAA==.',['杰瑞']='杰瑞熊:BAAALAADCgIIAgAAAA==.',['林允']='林允儿:BAAALAAFFAIIBAAAAA==.',['林夕']='林夕辰:BAAALAAECgMIAwAAAA==.',['枫红']='枫红叶:BAACLAAFFH8RAAMOAAYI8RGFLABpAQAOAAYIRxGFLABpAQAQAAIIoxejEgBHAAAsAAQKfxQAAg4ACAg+GgYZABcCAA4ACAg+GgYZABcCAAEsAAUUCAhOAA4AIyMA.',['某红']='某红人:BAAALAADCggICAAAAA==.',['柒鬼']='柒鬼:BAAALAAECgYIBgAAAA==.',['格尼']='格尼薇儿:BAABLAAFFH8GAAIMAAYItwmeJABNAQAMAAYItwmeJABNAQABLAAFFAcIGQAMAOMZAA==.',['格雷']='格雷希尔:BAAALAADCgMIAwAAAA==.',['桃子']='桃子:BAAALAADCgcICgAAAA==.',['梅丽']='梅丽奥达斯:BAAALAAECgEIAQAAAA==.',['梦星']='梦星辰:BAAALAAECgMIAwAAAA==.',['梦是']='梦是这样的:BAAALAAFFAIIAgAAAA==.',['梵蒂']='梵蒂冈之王:BAAALAADCgYIBgAAAA==.',['棍子']='棍子比我还高:BAAALAADCgMIAwAAAA==.',['楚夜']='楚夜白:BAABLAAFFH8FAAIYAAII+QOncQBIAAAYAAII+QOncQBIAAAAAA==.',['欧皇']='欧皇运气骑:BAABLAAFFH8IAAMMAAMIDCBsGgDxAAAMAAMIDCBsGgDxAAAZAAEIvQuVIwAyAAAAAA==.',['欲穷']='欲穷千里目:BAAALAADCgQIBAAAAA==.',['歼灭']='歼灭天使铃:BAAALAADCggICAAAAA==.',['残血']='残血的梦魇:BAABLAAECn8ZAAIDAAgIuQdfcQAMAQADAAgIuQdfcQAMAQAAAA==.',['残酷']='残酷月光:BAAALAAECgYIBgAAAA==.',['沁锁']='沁锁:BAAALAAECgYIDgAAAA==.',['沃特']='沃特伐柯:BAAALAADCggIDAAAAA==.',['法号']='法号戒色:BAABLAAFFH8GAAIOAAIILQu9YgA9AAAOAAIILQu9YgA9AAAAAA==.',['泰岚']='泰岚德雨风:BAAALAAECgYIBgAAAA==.',['泽泽']='泽泽宝宝:BAACLAAFFH8FAAIEAAIIRAYeqAA7AAAEAAIIRAYeqAA7AAAsAAQKfxYAAgQABwiFDiOLADcBAAQABwiFDiOLADcBAAAA.泽泽宝宝丶贼:BAAALAADCgQIBAAAAA==.',['流浪']='流浪喵:BAAALAADCgIIAgAAAA==.',['浪德']='浪德虚名:BAAALAADCgEIAQAAAA==.',['海兽']='海兽之牙:BAAALAADCgUIBwAAAA==.',['海盜']='海盜丶:BAAALAAECgUIBQAAAA==.',['深吻']='深吻子眸:BAAALAAFFAIIAwAAAA==.',['清舞']='清舞:BAAALAAECgMIAwAAAA==.',['温柔']='温柔一刀秒:BAAALAAECgYIBgAAAA==.',['温蒂']='温蒂:BAAALAAECgYICwAAAA==.',['湛蓝']='湛蓝的歌:BAABLAAFFH8JAAIFAAMIBgrKTABZAAAFAAMIBgrKTABZAAAAAA==.',['溜迖']='溜迖:BAABLAAFFH8IAAIaAAIIkx+FBACbAAAaAAIIkx+FBACbAAABLAAFFAYICgATABAfAA==.',['潆洄']='潆洄:BAAALAAECgcIBwABLAAFFAgIBgATAJwbAA==.',['澔澔']='澔澔:BAAALAAECgYIBgAAAA==.',['瀚宇']='瀚宇轩:BAAALAAECgYIBgAAAA==.',['火丨']='火丨枪:BAAALAADCggICwAAAA==.',['炎铭']='炎铭铭炎:BAAALAADCgIIAgAAAA==.',['点丶']='点丶燃:BAAALAAFFAMIAwAAAA==.',['炽天']='炽天使撒拉弗:BAAALAADCgIIAgABLAAECgYIEAAJAAAAAA==.',['烈酒']='烈酒断愁肠:BAAALAAECggICAAAAA==.',['烙饼']='烙饼卷披萨:BAAALAAECgYIBwAAAA==.烙饼卷榴莲:BAAALAAECgYIDAAAAA==.烙饼就豆汁儿:BAAALAAECgYIBgAAAA==.',['烬雪']='烬雪千川:BAAALAAECgUIBQAAAA==.',['然然']='然然:BAABLAAFFH8KAAIbAAYIwhQWHwBIAQAbAAYIwhQWHwBIAQABLAAFFAgIAQAJAAAAAA==.',['熊太']='熊太子:BAABLAAFFH8FAAILAAIIVw1QRQBkAAALAAIIVw1QRQBkAAAAAA==.',['熠熠']='熠熠星辉:BAAALAADCgEIAQAAAA==.',['燃血']='燃血圣光:BAAALAAECgMIAwAAAA==.',['爱冒']='爱冒险的梦:BAAALAAFFAIIAgAAAA==.',['爱墨']='爱墨奥维斯:BAABLAAECn8VAAIQAAcIMxzbJQDhAQAQAAcIMxzbJQDhAQAAAA==.',['独身']='独身一人:BAABLAAFFH8IAAIcAAIIGQp5GwBHAAAcAAIIGQp5GwBHAAAAAA==.',['狼人']='狼人加鲁鲁:BAAALAAFFAIIBAAAAA==.',['狼娜']='狼娜贝儿:BAABLAAFFH8IAAIDAAQIwR4BFwCKAQADAAQIwR4BFwCKAQAAAA==.',['狼里']='狼里格狼:BAAALAADCggICQAAAA==.',['猫菇']='猫菇凉:BAAALAAECgcIBwAAAA==.',['玉灵']='玉灵子:BAACLAAFFH8JAAIYAAIIxxY2TQCCAAAYAAIIxxY2TQCCAAAsAAQKfykAAhgACAhmHrIjAIQCABgACAhmHrIjAIQCAAAA.',['玉米']='玉米须不好吃:BAABLAAFFH8GAAIDAAIItQlaggCFAAADAAIItQlaggCFAAAAAA==.',['玛卡']='玛卡芭卡:BAAALAAECgYIBgAAAA==.',['环境']='环境保护:BAAALAAECgYIBgAAAA==.',['珊妮']='珊妮:BAAALAADCgEIAQAAAA==.',['球球']='球球爸爸:BAAALAADCgYIBgAAAA==.',['甄厉']='甄厉害:BAABLAAFFH8GAAIKAAYIvBEFIABsAQAKAAYIvBEFIABsAQAAAA==.',['甄可']='甄可爱:BAAALAAECgYICQAAAA==.',['畅快']='畅快的老龙虾:BAAALAAFFAIIAgAAAA==.',['白里']='白里光:BAAALAAFFAIIAgAAAA==.',['百万']='百万伏特:BAABLAAFFH8GAAMYAAYI+xaSLAAEAQAYAAQIGReSLAAEAQAbAAIIrAqPNACLAAAAAA==.',['百变']='百变灬妖妖:BAABLAAFFH8LAAMLAAYIgBslDQDoAQALAAYIgBslDQDoAQAVAAUIhRApGgAFAQAAAA==.',['盖世']='盖世英雄:BAABLAAFFH8LAAIKAAQIEwZRPwBkAAAKAAQIEwZRPwBkAAAAAA==.',['真乄']='真乄极霸丶剑:BAABLAAFFH8FAAMKAAIIFxhaQwBRAAAKAAIIFxhaQwBRAAATAAII/QdxNwApAAAAAA==.真乄极霸剑:BAABLAAECn8UAAITAAgIegxmRABwAQATAAgIegxmRABwAQAAAA==.',['眼神']='眼神放绿光:BAAALAAECgYIDAAAAA==.',['睁一']='睁一眼闭一眼:BAAALAAFFAIIAgAAAA==.',['神圣']='神圣之力:BAACLAAFFH8OAAIMAAIIWSUNJADDAAAMAAIIWSUNJADDAAAsAAQKf0QAAgwACAjlJdkLAFADAAwACAjlJdkLAFADAAAA.',['秋冷']='秋冷了月光:BAACLAAFFH8OAAIKAAIIXhw4LwCfAAAKAAIIXhw4LwCfAAAsAAQKfyoAAwoABgiyJREqAJQCAAoABgiyJREqAJQCABIAAQiOJCgzAGIAAAAA.秋冷了玥光:BAABLAAFFH8IAAIYAAIIUxBdTABvAAAYAAIIUxBdTABvAAABLAAFFAIIDgAKAF4cAA==.',['秩序']='秩序始源:BAACLAAFFH8dAAMdAAYIMhquCwCJAQAdAAYIMhquCwCJAQAeAAIIaAG/GQBKAAAsAAQKfzsAAx0ACAhjImwCAK0CAB0ACAhjImwCAK0CAB4ABggpE0kgAPgAAAAA.',['精灵']='精灵小萨:BAAALAAECgYIBgAAAA==.',['精神']='精神点别丢份:BAAALAADCgQIBAAAAA==.',['纪念']='纪念那年夏天:BAABLAAFFH8SAAIDAAUIERWNQgAwAQADAAUIERWNQgAwAQAAAA==.',['纸月']='纸月:BAAALAAECgYICgAAAA==.',['绛玥']='绛玥璃瑕:BAAALAAFFAQIAgAAAA==.',['绿皮']='绿皮大西瓜:BAABLAAECn8bAAMYAAgItiIKDAAEAwAYAAgItiIKDAAEAwAbAAEI0wj9fQArAAAAAA==.',['美味']='美味蟹黄堡:BAAALAAFFAMIAwAAAA==.',['翅膀']='翅膀大:BAAALAADCgIIAgAAAA==.',['翠星']='翠星石头:BAAALAAFFAIIBAAAAA==.',['老于']='老于:BAAALAAFFAIIBAAAAA==.',['脸滚']='脸滚键盘:BAAALAAECgIIAgAAAA==.',['舞刃']='舞刃:BAAALAAECgYIBgAAAA==.',['艾娜']='艾娜丽莎:BAAALAADCgQIBAAAAA==.',['荣耀']='荣耀星痕:BAACLAAFFH8QAAITAAIIng0bMgAwAAATAAIIng0bMgAwAAAsAAQKf0MABBMACAgnHBoXAIwBABMACAixGBoXAIwBAAoAAwjkHd9YAAsBABIAAQiBGf8TAEwAAAAA.',['莎拉']='莎拉布莱曼:BAAALAAECggICAAAAA==.',['莫格']='莫格莱妳:BAAALAAECgYIDwAAAA==.',['萌萌']='萌萌的灰太狼:BAAALAAECgYIDAAAAA==.',['萨满']='萨满来了:BAAALAAECgYIBgAAAA==.',['萨米']='萨米基纳:BAAALAADCgYIBgAAAA==.',['落叶']='落叶舞秋风:BAAALAAECgYICgAAAA==.落叶随风逍遥:BAAALAAECgUICgAAAA==.',['落婲']='落婲无痕:BAAALAAFFAIIAgAAAA==.',['蒜球']='蒜球:BAAALAAECgYIBgAAAA==.',['蒹葭']='蒹葭白露:BAAALAAECgQICwAAAA==.',['蘭蔸']='蘭蔸篼:BAABLAAFFH8JAAIMAAMIlxmhPQCcAAAMAAMIlxmhPQCcAAAAAA==.',['虎太']='虎太子:BAAALAAFFAIIAgAAAA==.',['蛇夫']='蛇夫座戒律王:BAACLAAFFH8MAAIEAAIIZAibcwB7AAAEAAIIZAibcwB7AAAsAAQKfyYAAgQABwg3DuKlABEBAAQABwg3DuKlABEBAAAA.',['詹姆']='詹姆斯丷哈登:BAAALAAECgYIBwAAAA==.',['诗成']='诗成绮韵:BAAALAAECgYIAQAAAA==.',['诛歌']='诛歌:BAAALAAECgQIAwABLAAECgYIBgAJAAAAAA==.',['贝鲁']='贝鲁特:BAAALAAECgcIBwAAAA==.',['败者']='败者食塵:BAAALAAECgYIBgAAAA==.',['赱紅']='赱紅丶:BAACLAAFFH8QAAIDAAIIOhYLfABHAAADAAIIOhYLfABHAAAsAAQKf0YAAgMACAhuH24wALECAAMACAhuH24wALECAAAA.',['赱红']='赱红:BAABLAAECn8aAAIMAAYIyRuVTQB1AQAMAAYIyRuVTQB1AQAAAA==.赱红丶:BAAALAAECgcIDwAAAA==.',['赵小']='赵小甜:BAAALAAECgQIBAAAAA==.',['超级']='超级战舰:BAAALAADCgEIAQAAAA==.超级马塞克:BAABLAAFFH8MAAMfAAIIpAvlEgBLAAAfAAEIWw3lEgBLAAADAAII4AcUmwA5AAAAAA==.超级马赛克:BAACLAAFFH8GAAIIAAIIRhX2SwBNAAAIAAIIRhX2SwBNAAAsAAQKfx8AAggABggdHrFdAA8CAAgABggdHrFdAA8CAAAA.',['跟我']='跟我走:BAAALAAECgYICAAAAA==.',['路有']='路有饿死骨:BAAALAADCgQIBAAAAA==.',['蹓跶']='蹓跶:BAAALAAECgIIAgABLAAFFAYICgATABAfAA==.',['转赚']='转赚转:BAAALAAFFAIIAgAAAA==.',['轻声']='轻声语:BAAALAAFFAIIBAAAAA==.',['远山']='远山如墨:BAAALAADCgYIBgAAAA==.远山如黛:BAAALAAFFAIIAwAAAA==.',['造化']='造化钟神秀:BAABLAAFFH8oAAIMAAYIoSFOCwDqAQAMAAYIoSFOCwDqAQAAAA==.',['遛跶']='遛跶:BAACLAAFFH8KAAITAAIIEB8oFACvAAATAAIIEB8oFACvAAAsAAQKfxcAAhMACAjKIQwKAC4CABMACAjKIQwKAC4CAAAA.',['遛迏']='遛迏:BAAALAAECggICAABLAAFFAYICgATABAfAA==.',['遛迖']='遛迖:BAACLAAFFH8GAAIEAAIIGSQdeQBpAAAEAAIIGSQdeQBpAAAsAAQKfx8AAgQACAiIJZgEAPkCAAQACAiIJZgEAPkCAAEsAAUUBggKABMAEB8A.',['酒一']='酒一酒:BAAALAADCgYIBgAAAA==.',['野牛']='野牛癫癫:BAAALAADCgYIBwAAAA==.',['金枝']='金枝宝贝:BAABLAAECn8aAAIEAAYIMxYkhgA+AQAEAAYIMxYkhgA+AQAAAA==.',['钟烟']='钟烟花:BAAALAAECgQIBAAAAA==.',['铁嘴']='铁嘴:BAABLAAFFH8FAAIEAAMIZRiVYwCqAAAEAAMIZRiVYwCqAAAAAA==.',['锁沁']='锁沁:BAABLAAFFH8FAAICAAII4iMaHwDEAAACAAII4iMaHwDEAAAAAA==.',['锦鲤']='锦鲤本鲤:BAABLAAECn8cAAIEAAgIFhwLOADjAQAEAAgIFhwLOADjAQAAAA==.',['闪耀']='闪耀的猫:BAABLAAFFH8MAAMbAAYIhiECCQDtAQAbAAUItiACCQDtAQAYAAEIHiNcXQBiAAAAAA==.',['闪闪']='闪闪小精灵:BAAALAAECgMIAgAAAA==.闪闪紅星:BAAALAAECgYIBgAAAA==.',['闲人']='闲人米米呀:BAAALAADCgYIBgAAAA==.',['阎魔']='阎魔:BAAALAAECgYIDwAAAA==.',['阿塔']='阿塔兰忒:BAAALAAFFAIIAgAAAA==.',['阿萨']='阿萨带个刀:BAACLAAFFH8JAAIDAAII+QSXpAAwAAADAAII+QSXpAAwAAAsAAQKfy4AAgMABwi6D4xQAFMBAAMABwi6D4xQAFMBAAAA.',['阿诗']='阿诗玛:BAACLAAFFH8JAAMgAAIIJhX7EACXAAAgAAIIJhX7EACXAAAcAAEI+AjzHABDAAAsAAQKfzUAAyAACAhGGT4QADkCACAACAjeGD4QADkCABwABAghFSUXAAcBAAAA.',['附魔']='附魔彩虹:BAACLAAFFH8KAAIOAAIIaxbiRQCQAAAOAAIIaxbiRQCQAAAsAAQKfxUAAg4ACAhRGc1eANQBAA4ACAhRGc1eANQBAAAA.',['随风']='随风潜入夜:BAABLAAFFH8KAAMGAAIIbh3SCgCsAAAGAAIIbh3SCgCsAAAFAAEIuwacawBEAAAAAA==.',['零灵']='零灵零:BAAALAAFFAIIAgAAAA==.',['颜值']='颜值国王:BAAALAAECgYIBgAAAA==.',['风剑']='风剑侠:BAABLAAFFH8nAAIDAAYIxBquIACxAQADAAYIxBquIACxAQAAAA==.',['风晓']='风晓月:BAAALAAECgMIAwAAAA==.',['风语']='风语者:BAAALAAECgYIBgAAAA==.',['骑个']='骑个烂摩托:BAAALAAECgYIBgAAAA==.',['骑德']='骑德龍东墙:BAAALAAECgYIDQAAAA==.',['骑车']='骑车去跳海:BAABLAAFFH8FAAMSAAMI+A+rBABNAAASAAIIFxGrBABNAAATAAIIcQ6dLgA1AAAAAA==.',['高胤']='高胤祯:BAAALAAECgQIBAAAAA==.',['魅影']='魅影之风:BAACLAAFFH8QAAIhAAIIKB+pDwCKAAAhAAIIKB+pDwCKAAAsAAQKf0sAAyEACAgRHkcHACwCACEACAihHUcHACwCAAMABQgNHYlWAEUBAAAA.',['鱿总']='鱿总:BAAALAAFFAIIAgAAAA==.',['鱿鱼']='鱿鱼干什么:BAAALAADCgcIBwAAAA==.',['鲁迪']='鲁迪:BAAALAAECgUICAAAAA==.',['鹾茱']='鹾茱茱:BAAALAADCggICgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end