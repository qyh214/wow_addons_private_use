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
 local lookup = {'Warlock-Destruction','Shaman-Elemental','Druid-Restoration','Shaman-Restoration','Evoker-Augmentation','Priest-Discipline','Evoker-Preservation','DeathKnight-Frost','DemonHunter-Havoc','Druid-Balance','DemonHunter-Vengeance','Warrior-Fury','Warrior-Arms','Paladin-Retribution','Hunter-BeastMastery','Priest-Shadow','Hunter-Marksmanship','Warlock-Demonology','Warlock-Affliction','Paladin-Holy','Monk-Windwalker','Evoker-Devastation','Priest-Holy','Mage-Frost','Warrior-Protection','Mage-Arcane','Unknown-Unknown','DeathKnight-Unholy','Monk-Brewmaster','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='奎尔萨拉斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Agnesclaudel:BAAALAAECgQIBAAAAA==.',Ar='Aruna:BAAALAAECgYIBgAAAA==.',Be='Beback:BAABLAAFFH8GAAIBAAIIIwngUwB2AAABAAIIIwngUwB2AAAAAA==.',Bi='Bitoy:BAACLAAFFH8eAAICAAYIBx1XCgDZAQACAAYIBx1XCgDZAQAsAAQKfx0AAgIACAifIlEPABYDAAIACAifIlEPABYDAAAA.Bittoy:BAABLAAFFH8GAAIDAAIIYBAYNABsAAADAAIIYBAYNABsAAAAAA==.',Co='Comeinthroat:BAAALAADCgEIAQAAAA==.',Dh='Dhpaopao:BAAALAAECgYIBgAAAA==.',Fu='Fufu:BAAALAAFFAIIBAAAAA==.Fufufu:BAAALAAFFAIIAgAAAA==.',Ka='Kainmir:BAAALAAECgYIEgAAAA==.',Ke='Kelis:BAABLAAFFH8SAAIEAAgIMQAzggAGAAAEAAgIMQAzggAGAAAAAA==.',Kk='Kk:BAAALAAECgMIAwAAAA==.',Ko='Koicc:BAABLAAFFH8GAAIFAAYInRjKBQBpAQAFAAYInRjKBQBpAQAAAA==.Koivv:BAABLAAFFH8GAAIFAAYIVRsZBQCEAQAFAAYIVRsZBQCEAQAAAA==.Koixx:BAABLAAFFH8GAAIFAAYIqBq3BQBsAQAFAAYIqBq3BQBsAQAAAA==.',Mo='Mooly:BAAALAAECgIIAgAAAA==.',Oo='Oopslr:BAAALAADCgMIAwAAAA==.',Pa='Pastboy:BAABLAAFFH8KAAIGAAIIKRjZAwCTAAAGAAIIKRjZAwCTAAAAAA==.',Pu='Pullback:BAABLAAFFH8MAAIHAAYIlBdACgC0AQAHAAYIlBdACgC0AQAAAA==.',Re='Rereborn:BAAALAADCgEIAQAAAA==.',Ru='Runtoyou:BAAALAAECggICAAAAA==.',Si='Silentter:BAAALAADCgMIBAAAAA==.',Tr='Traxex:BAAALAADCgQIBAAAAA==.',Ts='Tsla:BAABLAAFFH8LAAIHAAYI8xhQCgCyAQAHAAYI8xhQCgCyAQAAAA==.',Vc='Vc:BAAALAAECgYIBgAAAA==.',Zo='Zorro:BAAALAAECgYIBgAAAA==.',['一套']='一套爷一:BAAALAAECgUICwAAAA==.',['一点']='一点红:BAAALAAECggICgAAAA==.',['一砣']='一砣子:BAABLAAFFH8KAAIIAAIIIhDRfwBGAAAIAAIIIhDRfwBGAAABLAAFFAIICgAJAAwQAA==.',['一鸟']='一鸟在手:BAAALAAECgYIDgAAAA==.',['三三']='三三的守护:BAAALAAECgYIDAAAAA==.',['三希']='三希:BAABLAAFFH8YAAIIAAYILg0UPAC5AAAIAAYILg0UPAC5AAAAAA==.',['下半']='下半蛆职业:BAAALAAFFAEIAQAAAA==.',['不喝']='不喝牛奶:BAABLAAFFH8GAAIKAAYIVwz1EQDeAAAKAAYIVwz1EQDeAAAAAA==.',['与狼']='与狼共伍:BAAALAAECgYIBwAAAA==.',['两砣']='两砣子:BAABLAAFFH8KAAMJAAIIDBAlTQCPAAAJAAIIywslTQCPAAALAAEIFQ9/HAAAAAAAAA==.',['丨丶']='丨丶棒棒溏:BAAALAAECgYIBgAAAA==.',['中中']='中中间:BAAALAADCgQIBAAAAA==.',['丶王']='丶王妃:BAABLAAFFH8LAAMMAAgItAzqFQCtAQAMAAUI3RPqFQCtAQANAAYIWgHcBgAkAAAAAA==.',['丷小']='丷小领主丷:BAABLAAFFH8ZAAIOAAUISxUOKAA5AQAOAAUISxUOKAA5AQAAAA==.',['乄命']='乄命孤独:BAAALAAECgYIBgAAAA==.',['乄铭']='乄铭孤独:BAAALAAECgYIDAABLAAFFAYIDQAIADMVAA==.',['亚莎']='亚莎:BAAALAAECgYIBgAAAA==.',['人造']='人造人七号:BAABLAAECn8VAAIPAAgIWxlnNADuAQAPAAgIWxlnNADuAQAAAA==.',['今天']='今天喝绿茶:BAABLAAFFH8QAAIOAAII4h5bNwClAAAOAAII4h5bNwClAAAAAA==.',['从小']='从小就拽:BAAALAAFFAIIBAAAAA==.从小就暴:BAAALAAFFAIIAgAAAA==.从小就猛:BAAALAAFFAMIAwAAAA==.',['仰望']='仰望黎明:BAAALAADCggICAAAAA==.',['仲夏']='仲夏夜之夢:BAAALAAECgYICwAAAA==.',['你就']='你就是个鬼:BAAALAAECgYIBgAAAA==.',['佬捌']='佬捌:BAAALAAECgYIDAAAAA==.',['保保']='保保:BAAALAAECgIIAgAAAA==.',['倾丶']='倾丶一屡阳光:BAAALAAECgYIBgAAAA==.',['八叭']='八叭叭:BAAALAADCgYIBgAAAA==.',['再見']='再見灬青春:BAABLAAECn8hAAIEAAgIdxvqEgBbAgAEAAgIdxvqEgBbAgAAAA==.',['冰箱']='冰箱里有老头:BAAALAAECgYIBwAAAA==.',['冰霜']='冰霜后裔:BAAALAAECgUIBQAAAA==.',['冷空']='冷空气:BAAALAAECgUIBwAAAA==.',['凯尔']='凯尔萨凘:BAAALAAFFAIIAgAAAA==.',['初尘']='初尘:BAAALAAFFAIIAgAAAA==.',['到处']='到处乱插:BAABLAAECn8VAAIEAAgI+ArmpgAxAQAEAAgI+ArmpgAxAQAAAA==.',['刺盾']='刺盾:BAAALAAECggIDgAAAA==.',['刺骨']='刺骨寒冰:BAAALAADCgYIBgAAAA==.',['加不']='加不住啊:BAACLAAFFH8HAAIQAAMIJRT9FADXAAAQAAMIJRT9FADXAAAsAAQKfxYAAhAACAgKIrAWALgCABAACAgKIrAWALgCAAAA.',['劲凉']='劲凉麻辣烫:BAAALAAECgcICQAAAA==.',['十八']='十八般武艺:BAAALAAECgYIBgAAAA==.',['十月']='十月零貳灬:BAAALAADCgIIAgAAAA==.',['又又']='又又不适双:BAAALAADCggICAAAAA==.又又吥是双:BAAALAADCgUIBQAAAA==.又又布是双:BAAALAADCgMIAwAAAA==.',['口马']='口马口非:BAAALAAECgYIDgAAAA==.',['可乐']='可乐可口:BAABLAAFFH8IAAMPAAIINiSJewBiAAARAAII/wlnKwBwAAAPAAIINiSJewBiAAAAAA==.',['哇酷']='哇酷哇酷:BAACLAAFFH8iAAMBAAYIJB60FgDUAQABAAYIJB60FgDUAQASAAEIIxpqJQBUAAAsAAQKfykABAEACAhfIPMcAN4CAAEACAhfIPMcAN4CABIABAgxFyxhAPMAABMAAgg9EMouAH0AAAAA.',['哈斯']='哈斯朝鲁:BAAALAAECgYIBgAAAA==.',['唯物']='唯物劣人:BAAALAAECgMIAwAAAA==.',['唯美']='唯美丶黯殇:BAAALAAECgYIBAAAAA==.',['啸男']='啸男蝴:BAABLAAFFH8KAAIUAAIIcRQmIwCJAAAUAAIIcRQmIwCJAAAAAA==.',['喃喃']='喃喃头:BAAALAADCgEIAQAAAA==.',['喵呜']='喵呜小甜豆:BAAALAAECgQIBAAAAA==.',['嘎啦']='嘎啦美朵:BAAALAADCgEIAQAAAA==.',['噗叽']='噗叽菜菜:BAACLAAFFH83AAIHAAcI6CaNAAC5AgAHAAcI6CaNAAC5AgAsAAQKfzkAAgcACAiWJh0AAI8DAAcACAiWJh0AAI8DAAAA.',['噩魔']='噩魔猎首:BAAALAADCgQIBAAAAA==.',['四叶']='四叶草:BAAALAAECgQIBAAAAA==.',['图腾']='图腾旗舰店:BAAALAAECgYIBgAAAA==.',['圣域']='圣域灵主:BAAALAAECgYIBgAAAA==.',['垩女']='垩女:BAAALAADCgYICQAAAA==.',['壮熊']='壮熊可乐:BAAALAAECgMIAwAAAA==.',['复仇']='复仇之路:BAAALAAECgYIBgAAAA==.',['夏天']='夏天小小号:BAAALAADCgIIAgAAAA==.夏天的雪:BAAALAAECgYIBgAAAA==.夏天的风雪:BAAALAAECgcIDwAAAA==.',['大夜']='大夜弥天:BAABLAAFFH8KAAIIAAgIShnwCABrAgAIAAgIShnwCABrAgAAAA==.',['大家']='大家长:BAAALAAECgcICgAAAA==.',['大寂']='大寂灭神:BAABLAAFFH8PAAIVAAUIGw2+DQDdAAAVAAUIGw2+DQDdAAABLAAFFAYIEgAWAKIOAA==.',['大者']='大者咧没图腾:BAABLAAECn8aAAIEAAcIoRxWTAD7AQAEAAcIoRxWTAD7AQAAAA==.',['大肚']='大肚子:BAAALAADCgEIAQAAAA==.',['大贤']='大贤良师:BAAALAAFFAIIAgAAAA==.',['太平']='太平间小硬人:BAAALAAECgYIBwAAAA==.',['奈扎']='奈扎雷克:BAAALAAECgMIAwAAAA==.',['奶油']='奶油大白白:BAAALAAECgYICgAAAA==.',['娜缇']='娜缇灬慕斯:BAAALAAFFAIIAgAAAA==.娜缇灬纱幔:BAAALAAFFAYIAQAAAA==.',['孟尝']='孟尝君:BAABLAAECn8eAAIJAAYI1x1CLACpAQAJAAYI1x1CLACpAQAAAA==.',['孤独']='孤独的北极星:BAAALAAFFAIIBAAAAA==.',['宇宙']='宇宙战舰:BAAALAAFFAIIAgAAAA==.',['寂寞']='寂寞灬恶魔:BAABLAAFFH8OAAIPAAIIgBrtSwCZAAAPAAIIgBrtSwCZAAAAAA==.寂寞的老鹰:BAABLAAFFH8TAAIIAAUIHha9PABIAQAIAAUIHha9PABIAQAAAA==.',['小小']='小小懒虫:BAABLAAFFH8QAAMXAAgIpRoQBACYAgAXAAgIpRoQBACYAgAQAAIIzQzyHQCaAAAAAA==.',['小橘']='小橘皮皮丶:BAAALAAECggIAgAAAA==.',['小白']='小白龙:BAABLAAECn8WAAIJAAcIGBxmTAA8AgAJAAcIGBxmTAA8AgAAAA==.',['小龙']='小龙之神:BAACLAAFFH8SAAIWAAYIog5kDABaAQAWAAYIog5kDABaAQAsAAQKfxsAAhYACAiKF04gABcCABYACAiKF04gABcCAAAA.',['尚方']='尚方小树:BAAALAAECgUIBQAAAA==.',['尤格']='尤格萨:BAAALAAECgYICQAAAA==.',['屠戮']='屠戮之霸:BAAALAAECgYIBgAAAA==.',['平凡']='平凡的生活:BAAALAAECgYIBwAAAA==.',['幽冥']='幽冥特使:BAAALAAECgQIBAAAAA==.',['幽灵']='幽灵公主:BAAALAAECgYICAAAAA==.幽灵吨吨:BAAALAAECgIIAgAAAA==.',['弑神']='弑神之完美:BAAALAAECgMIAwAAAA==.',['弓长']='弓长:BAAALAAECgYIBgAAAA==.',['弟理']='弟理士多德:BAAALAAFFAIIBAAAAA==.',['张大']='张大爷:BAAALAAECgEIAQAAAA==.',['德偿']='德偿所愿:BAAALAADCgIIAgAAAA==.',['思南']='思南:BAAALAAFFAIIBAAAAA==.',['恶魔']='恶魔降临:BAAALAAFFAIIBAAAAA==.',['悠悠']='悠悠雪:BAAALAAECgYICgAAAA==.',['悠扬']='悠扬丶挽歌:BAAALAADCgYICAAAAA==.',['想明']='想明白了:BAABLAAECn8WAAIYAAYIGR17FQB/AQAYAAYIGR17FQB/AQAAAA==.',['愛上']='愛上龖龘麵:BAAALAADCgQIBwAAAA==.',['我又']='我又留了长发:BAAALAAECgcIBwAAAA==.',['我是']='我是乃龙:BAAALAAECgUICQAAAA==.我是逆蝶丶:BAABLAAFFH8MAAIIAAYIHR2wJQCeAQAIAAYIHR2wJQCeAQAAAA==.',['我知']='我知你生名:BAAALAAECgcICwAAAA==.',['折戟']='折戟灬壁垒:BAABLAAFFH8FAAMMAAII+hlhRQBOAAAMAAII+hlhRQBOAAAZAAEIwQcxPQAAAAAAAA==.',['拂红']='拂红茶:BAAALAAFFAIIAwAAAA==.',['摧丶']='摧丶残:BAABLAAFFH8KAAIPAAIIvBWjlABDAAAPAAIIvBWjlABDAAAAAA==.',['摧灬']='摧灬残:BAABLAAFFH8JAAIaAAII5hMLSgCWAAAaAAII5hMLSgCWAAAAAA==.',['摸鱼']='摸鱼喝咖啡:BAAALAAECgYIBwAAAA==.摸鱼的胖狐狸:BAAALAADCgcIBwAAAA==.',['斩了']='斩了:BAAALAAECggICAAAAA==.',['施主']='施主灬给点情:BAAALAAECgYIBgAAAA==.',['明枪']='明枪易躲:BAAALAAECgYIDAAAAA==.',['星野']='星野介:BAABLAAFFH8GAAIPAAMIbQ9LbQCHAAAPAAMIbQ9LbQCHAAAAAA==.',['晶晶']='晶晶宝宝:BAAALAADCggICAAAAA==.',['暗黑']='暗黑女皇:BAAALAAFFAIIAwABLAAECgYIDwAbAAAAAA==.',['暴徒']='暴徒:BAAALAADCggIFQAAAA==.',['月枕']='月枕星河:BAAALAAECgEIAQAAAA==.',['望月']='望月溪:BAAALAADCgYIBgAAAA==.',['朝夕']='朝夕:BAAALAADCgMIAwAAAA==.',['木雁']='木雁龙蛇:BAABLAAFFH8IAAIOAAII2R2zNACnAAAOAAII2R2zNACnAAAAAA==.',['木頭']='木頭亼:BAAALAAFFAIIAgAAAA==.',['朴人']='朴人猛:BAAALAAECgUIBgAAAA==.',['村里']='村里的小个:BAAALAAECgEIAQAAAA==.',['杜晓']='杜晓猴:BAAALAADCgEIAQAAAA==.',['杰克']='杰克灬布朗:BAAALAADCgEIAQABLAAFFAgIGgABAFEfAA==.',['松风']='松风万壑:BAAALAAECgYIBgAAAA==.',['林烁']='林烁阳:BAAALAAECgEIAQAAAA==.',['林间']='林间星月:BAAALAAECgYIBgAAAA==.',['某某']='某某蝎子:BAAALAADCgMIBQAAAA==.',['柚柚']='柚柚:BAAALAADCgcIBwAAAA==.',['柯锦']='柯锦:BAABLAAFFH8GAAIOAAYILRmhBQANAgAOAAYILRmhBQANAgAAAA==.',['死亡']='死亡守望:BAABLAAFFH8GAAIIAAYISgBRqwANAAAIAAYISgBRqwANAAAAAA==.',['残暴']='残暴者:BAAALAAECgYICwAAAA==.',['泪桥']='泪桥:BAAALAAECgYIBgAAAA==.',['活力']='活力鱼串:BAAALAAECgUIBQAAAA==.',['派大']='派大猩:BAABLAAFFH8FAAIIAAMIzwOjaAB0AAAIAAMIzwOjaAB0AAAAAA==.',['海河']='海河江山:BAAALAADCgcIBwAAAA==.',['海象']='海象人逃跑者:BAAALAAECgYIBgAAAA==.',['海贼']='海贼玲玲:BAAALAADCgIIAgAAAA==.',['淘气']='淘气的小猴:BAAALAAECggICAAAAA==.',['湾风']='湾风行者:BAABLAAFFH8FAAIPAAII9gxajQBGAAAPAAII9gxajQBGAAAAAA==.',['滑蛋']='滑蛋炒牛肉:BAAALAAFFAIIAgAAAA==.',['澄夜']='澄夜:BAAALAADCgIIAwAAAA==.',['火头']='火头狼王:BAAALAADCgcICgAAAA==.',['火锅']='火锅:BAAALAAECgYIBgAAAA==.',['灬硳']='灬硳瞳灬:BAAALAAFFAIIBAAAAA==.',['灰鸦']='灰鸦丶:BAAALAAECggICAAAAA==.',['烟花']='烟花不堪剪:BAAALAADCgYIBwAAAA==.',['燃烧']='燃烧吧小宇宙:BAAALAAECgUIAgAAAA==.',['爆椒']='爆椒牛肉面:BAABLAAFFH8KAAIcAAIINgxIFACHAAAcAAIINgxIFACHAAAAAA==.',['爱莲']='爱莲娜:BAAALAAECgUIBgAAAA==.',['牛奶']='牛奶大:BAAALAAFFAIIAgAAAA==.',['牛得']='牛得一比:BAABLAAFFH8KAAIKAAIIsgQTKQBqAAAKAAIIsgQTKQBqAAAAAA==.',['牛牛']='牛牛的牛牛:BAAALAAECggICAAAAA==.',['牛的']='牛的一批啊:BAAALAADCgQIBAAAAA==.',['狂兽']='狂兽噬道:BAAALAADCgcIBwAAAA==.',['狐丶']='狐丶尼克:BAAALAAFFAMIBAAAAA==.',['狡诈']='狡诈的猎狐者:BAABLAAFFH8GAAIPAAIIehQQTgCXAAAPAAIIehQQTgCXAAAAAA==.',['璟笙']='璟笙:BAAALAAECgQIBAAAAA==.',['百度']='百度不到的爱:BAAALAAECgIIAgAAAA==.',['皮卡']='皮卡球:BAAALAAECggIEgAAAA==.',['看你']='看你妹:BAABLAAFFH8GAAIJAAII8hGWTwBJAAAJAAII8hGWTwBJAAAAAA==.',['看我']='看我不羊死你:BAAALAAECgUIBQAAAA==.',['神光']='神光之神:BAAALAAECgYIDAABLAAFFAYIEgAWAKIOAA==.',['神圣']='神圣女王:BAAALAAECgYIBgAAAA==.',['秋枫']='秋枫里的秋裤:BAAALAADCgIIAgAAAA==.',['竹月']='竹月丶螭吻:BAAALAADCggICAAAAA==.',['繁华']='繁华遗失:BAABLAAECn8pAAQBAAgI3x4/IADmAQABAAcIHRw/IADmAQATAAQINB97BQB1AQASAAQIBxUKIQDKAAAAAA==.',['红莲']='红莲灬天使:BAAALAAFFAEIAQAAAA==.',['练练']='练练级泡泡妞:BAAALAAECgYIBgAAAA==.',['编号']='编号九五二七:BAAALAAECgYIEAAAAA==.',['老大']='老大哥:BAABLAAFFH8KAAIIAAIIsBT9gwBEAAAIAAIIsBT9gwBEAAAAAA==.老大哥二号:BAAALAAFFAIIAgAAAA==.',['耶苏']='耶苏尔德:BAAALAAECgYIBgAAAA==.',['聖光']='聖光星耀:BAAALAAECgYIBgAAAA==.',['胖叔']='胖叔叔的武僧:BAABLAAFFH8FAAIdAAUISgXiFQDXAAAdAAUISgXiFQDXAAAAAA==.',['脑袋']='脑袋弯弯的:BAAALAAECgEIAQAAAA==.',['自由']='自由的鸟:BAAALAADCgIIAgAAAA==.',['至高']='至高之法:BAAALAAECgYICQAAAA==.',['艮啾']='艮啾啾:BAAALAADCgEIAgAAAA==.',['艾克']='艾克莉西娅:BAAALAADCgYIBgAAAA==.',['芙芙']='芙芙丫:BAABLAAFFH8FAAIOAAIIwA8xbwA+AAAOAAIIwA8xbwA+AAAAAA==.芙芙呀:BAABLAAFFH8GAAIPAAIIaRA8lABDAAAPAAIIaRA8lABDAAAAAA==.',['苦瓜']='苦瓜办黄连:BAAALAAECgYIBgAAAA==.苦瓜秚黄连:BAAALAAECggICAAAAA==.苦瓜跘黄连:BAAALAAECgEIAQAAAA==.',['萨拉']='萨拉咀铭:BAAALAAECggICAAAAA==.萨拉妞妞:BAAALAAECggIBgAAAA==.萨拉明明:BAAALAAECggIBwAAAA==.',['蒂亚']='蒂亚娜:BAAALAAECgQIBAAAAA==.',['蓝色']='蓝色海洋:BAAALAAECgEIAQAAAA==.',['薛定']='薛定谔的闪电:BAAALAAFFAYIAgAAAA==.',['蛋蛋']='蛋蛋丶忧伤:BAAALAAECgUICQAAAA==.',['血帆']='血帆海盗:BAAALAAECgYICAAAAA==.',['血影']='血影霜天:BAAALAAFFAIIAgAAAA==.',['血灵']='血灵放肆:BAAALAAFFAMIBAAAAA==.',['血骑']='血骑靈主:BAAALAAECgYIBgAAAA==.',['行更']='行更名做改姓:BAAALAAECggICAAAAA==.',['西瓜']='西瓜地里的猹:BAAALAAECggIDgAAAA==.',['言其']='言其不语:BAACLAAFFH8mAAMIAAcICx3nDwAQAgAIAAcICx3nDwAQAgAcAAMIJRX7BwDuAAAsAAQKfygAAwgACAjkIkgNAIYCAAgACAjhIkgNAIYCABwACAgfGhcSAD8CAAAA.',['贺强']='贺强:BAAALAAECgIIAwAAAA==.',['赛跑']='赛跑第一名:BAAALAADCgQIBAAAAA==.',['输出']='输出质检员:BAABLAAFFH8KAAIaAAMIbxZ6QgCZAAAaAAMIbxZ6QgCZAAAAAA==.',['远赴']='远赴人间:BAACLAAFFH8cAAIOAAYI3SPiBgAaAgAOAAYI3SPiBgAaAgAsAAQKfygAAg4ABgjUJVYgABoCAA4ABgjUJVYgABoCAAEsAAUUCAgUAAIAbhQA.',['逆爱']='逆爱:BAAALAAECgIIAgAAAA==.',['逐风']='逐风追雷:BAAALAADCgYIBgAAAA==.',['银鹰']='银鹰:BAAALAAECgUICAAAAA==.',['闪开']='闪开我要拉裤:BAACLAAFFH8MAAIOAAIITx9bJgC9AAAOAAIITx9bJgC9AAAsAAQKfyIAAg4ABggRJRw/AH4CAA4ABggRJRw/AH4CAAAA.',['阿克']='阿克萌贼:BAABLAAFFH8OAAMeAAgIJSAVBgCLAQAeAAYI2xcVBgCLAQAfAAgIOR8AAAAAAAAAAA==.',['阿姐']='阿姐:BAAALAAECgUIBgAAAA==.',['阿拉']='阿拉丁神经:BAAALAADCgQIBAAAAA==.',['阿贼']='阿贼:BAAALAADCgQIBAAAAA==.',['雅哈']='雅哈马他了给:BAAALAAECgIIAgAAAA==.',['雨中']='雨中节奏:BAAALAADCgUIBQAAAA==.',['雪夜']='雪夜异乡人:BAAALAAECgIIAgAAAA==.',['青柑']='青柑普洱:BAAALAADCgUIBQAAAA==.',['飘雪']='飘雪的夏天:BAAALAADCggIEQAAAA==.',['鬼王']='鬼王下山了:BAAALAAECgYIBgAAAA==.',['魂不']='魂不守舍:BAAALAAECgIIAgAAAA==.',['鲸落']='鲸落万物生:BAAALAAECgQIBAAAAA==.',['黑市']='黑市拳王:BAAALAADCgUIBQAAAA==.',['黑暗']='黑暗騎士:BAAALAADCgcIBwAAAA==.',['龙运']='龙运:BAAALAAECgYIEAAAAA==.',['龙龙']='龙龙:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end