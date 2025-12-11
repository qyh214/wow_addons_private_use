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
 local lookup = {'DemonHunter-Havoc','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Druid-Restoration','Unknown-Unknown','Shaman-Restoration','Druid-Balance','Shaman-Elemental','Monk-Windwalker','Paladin-Protection','DeathKnight-Unholy','DeathKnight-Frost','Monk-Brewmaster','Mage-Frost','Monk-Mistweaver','Druid-Guardian','Priest-Holy','Mage-Arcane','Mage-Fire','Warrior-Arms','DeathKnight-Blood','Paladin-Holy',}; local provider = {region='CN',realm='达隆米尔',name='CN',type='weekly',zone=44,date='2025-12-08',data={Aj='Aj:BAAALAAECgQIBAAAAA==.',At='Atlant:BAAALAAECgYICwAAAA==.Atlantsanke:BAAALAAECgUIBQAAAA==.',Bi='Biubiubi:BAAALAADCgYIBgAAAA==.',Ca='Caooco:BAAALAAECgYIBgAAAA==.',De='Destinyl:BAAALAAECgIIAgAAAA==.',Ha='Hami:BAAALAAECgQICwAAAA==.',Ic='Icce:BAAALAAFFAIIBAAAAA==.Iccee:BAAALAAECgYIEgAAAA==.Icee:BAAALAAECgYIDAAAAA==.',Ii='Iice:BAAALAAECgYICAAAAA==.Iicee:BAAALAAECgYIBgABLAAFFAgIBgABANcaAA==.',Ju='Juice:BAAALAAECgYIBgAAAA==.',Ko='Koice:BAAALAAECggICAAAAA==.',Le='Leiyiwei:BAABLAAECn8cAAICAAYIaAvJkQDeAAACAAYIaAvJkQDeAAAAAA==.',Na='Namo:BAAALAAECgYIBgAAAA==.',Ne='Nevermoree:BAAALAADCggIDgAAAA==.',Po='Popodh:BAAALAAECgYIBgAAAA==.Popofq:BAAALAAECggICAAAAA==.Popolrx:BAABLAAFFH8HAAMDAAMIfBfKSwCZAAADAAMIfBfKSwCZAAAEAAEI+QUpOQAzAAAAAA==.',Pu='Pumpkin:BAAALAAECgYIBgAAAA==.',Sh='Shirler:BAAALAADCgEIAQAAAA==.',So='Sorcererfs:BAABLAAECn8aAAIDAAYI6RoCbABsAQADAAYI6RoCbABsAQAAAA==.',Sr='Sraahwayne:BAAALAAECgYICwAAAA==.',St='Stanford:BAAALAAECgUIBQAAAA==.',Wi='Wismartly:BAAALAAFFAIIAgAAAA==.',Wu='Wu:BAAALAAECgMIAwAAAA==.',Xz='Xzjz:BAAALAADCgQIBAAAAA==.',['一个']='一个德的寂寞:BAAALAAECggICAAAAA==.',['一只']='一只宠物猫:BAAALAAECgUIBQAAAA==.',['一皮']='一皮卡丘一:BAAALAADCggICAAAAA==.',['一看']='一看就会:BAAALAADCgMIAwAAAA==.',['一碗']='一碗四百:BAABLAAFFH8GAAIFAAYICA1/OAAtAQAFAAYICA1/OAAtAQAAAA==.',['一骑']='一骑:BAAALAAECgEIAQAAAA==.',['丁真']='丁真:BAAALAAECgYIDAAAAA==.',['七十']='七十六号:BAAALAAECggIEAAAAA==.',['万箭']='万箭:BAAALAADCggICAAAAA==.',['上夐']='上夐月:BAAALAADCgIIAgAAAA==.',['下一']='下一战巨星:BAABLAAECn81AAIGAAYInB8CQgAuAgAGAAYInB8CQgAuAgAAAA==.',['不死']='不死的社长:BAAALAAFFAIIBAAAAA==.',['不爱']='不爱香菜:BAAALAADCgYIBgAAAA==.',['世界']='世界萨彡:BAAALAAECgYIDQAAAA==.',['丨沛']='丨沛艾丨:BAABLAAFFH8GAAIDAAIIEgYyrgA5AAADAAIIEgYyrgA5AAAAAA==.',['临风']='临风:BAAALAAFFAgIAwAAAA==.',['丶树']='丶树娃:BAAALAAFFAIIAgAAAA==.',['丶燬']='丶燬炢紅塵丶:BAABLAAFFH8UAAIFAAYI0RttHACxAQAFAAYI0RttHACxAQAAAA==.',['为了']='为了冲锋:BAABLAAFFH8FAAIHAAUIVxhOEwArAQAHAAUIVxhOEwArAQAAAA==.',['主力']='主力队员:BAAALAAECgQIBgAAAA==.',['九二']='九二:BAAALAAECgYIBgAAAA==.',['二泉']='二泉映月:BAAALAADCgMIAwAAAA==.',['任添']='任添糖:BAAALAADCgEIAQAAAA==.',['伊西']='伊西斯:BAAALAAFFAIIAgAAAA==.',['伊里']='伊里娅特弦灵:BAABLAAFFH8IAAIDAAYIVAGnvgAqAAADAAYIVAGnvgAqAAAAAA==.',['伏魔']='伏魔御厨子丶:BAAALAAFFAIIAgAAAA==.',['伤心']='伤心小剑:BAAALAADCgMIAwAAAA==.',['伯爵']='伯爵德库拉:BAAALAAECgEIAQAAAA==.',['估算']='估算师:BAAALAAECgYIBgAAAA==.',['低语']='低语:BAABLAAFFH8LAAMIAAIITBnjJABUAAAIAAEILhnjJABUAAAFAAIITBnDXABCAAAAAA==.',['你们']='你们冲我掩护:BAAALAAECgYIBgAAAA==.',['你没']='你没有坦克:BAAALAAFFAIIAgAAAA==.',['你艾']='你艾希我奶妈:BAABLAAFFH8IAAIJAAIIiQrJSwBaAAAJAAIIiQrJSwBaAAAAAA==.',['使劲']='使劲儿往上加:BAAALAAECgYIDAAAAA==.',['倒霉']='倒霉蛋儿:BAAALAAECgcIBgABLAAFFAgIBAAKAAAAAA==.',['元述']='元述:BAACLAAFFH81AAMDAAcIyx7AFgBgAQAEAAUICh+jCQBxAQADAAYImh7AFgBgAQAsAAQKfy8AAwQACAh/IwMMAAMDAAQACAgRIwMMAAMDAAMABgjUGe2nABABAAAA.',['兄弟']='兄弟:BAABLAAFFH8IAAILAAIIoRHEVABzAAALAAIIoRHEVABzAAAAAA==.',['兎笓']='兎笓:BAACLAAFFH8QAAMJAAIIFCRiFQDPAAAJAAIIFCRiFQDPAAAMAAIIVyNdFQC3AAAsAAQKfyIAAwkABwg2I5olAFECAAkABghXI5olAFECAAwABwjQI5QSAOoBAAAA.',['八块']='八块腹肌:BAAALAAECgQIBAAAAA==.',['冰冷']='冰冷的叶子:BAAALAADCgYIBgAAAA==.',['冰糖']='冰糖雪梨丶:BAAALAAECgUIBQAAAA==.',['凋叶']='凋叶棕:BAAALAAECgMIBQAAAA==.',['凤岭']='凤岭一波流:BAAALAAECgMIAwAAAA==.',['刘瑾']='刘瑾优:BAAALAAFFAIIAgAAAA==.',['别奶']='别奶我了:BAABLAAFFH8MAAMLAAYIgR+kGACZAQALAAUIWB+kGACZAQANAAIIvwTnOAB5AAAAAA==.',['北海']='北海鱿魚杀手:BAAALAAECgQIBAAAAA==.',['十字']='十字军骑士:BAACLAAFFH8FAAICAAMIpAc2WACKAAACAAMIpAc2WACKAAAsAAQKfxsAAgIACAg0F/tYADsCAAIACAg0F/tYADsCAAAA.',['千寒']='千寒:BAAALAAFFAIIBAAAAA==.',['南瓜']='南瓜豆豆:BAABLAAFFH8GAAIGAAIIQBW8MACeAAAGAAIIQBW8MACeAAAAAA==.',['原野']='原野:BAAALAADCgQIBAAAAA==.',['叫我']='叫我哥:BAAALAADCggIEAAAAA==.',['史莱']='史莱克:BAAALAAECgYIBgAAAA==.',['史迪']='史迪奇:BAAALAAECgYICwAAAA==.史迪奇的迪凯:BAAALAAFFAYIBAAAAA==.',['叶知']='叶知秋:BAAALAAECggICAAAAA==.',['吖克']='吖克萌德:BAAALAAECgYIDAAAAA==.',['吟游']='吟游诗四驴:BAAALAAECgUIBQAAAA==.',['咖啡']='咖啡煮酒:BAAALAAECgQIBAAAAA==.',['咿利']='咿利丹灬舅舅:BAAALAAECgYIBgAAAA==.',['哈里']='哈里的小姨:BAAALAAECgYIBgAAAA==.',['唯了']='唯了部落:BAAALAADCgYIBgAAAA==.',['啊嘛']='啊嘛忒拉斯:BAAALAAECgYIBgAAAA==.',['噬心']='噬心隐为者:BAACLAAFFH8MAAIDAAYIeBkkMQB3AQADAAYIeBkkMQB3AQAsAAQKfxgAAwQACAihIhoPAOoCAAQACAjOIRoPAOoCAAMABwjDITNHALsBAAEsAAUUCAgGAAMAihUA.',['圈圈']='圈圈肉:BAABLAAECn8WAAIOAAgI8htSGABJAgAOAAgI8htSGABJAgAAAA==.',['圣光']='圣光之雨:BAAALAAFFAIIAgAAAA==.圣光小骑士:BAAALAAECgIIAgAAAA==.',['圣灬']='圣灬言:BAAALAAECgUIBQAAAA==.',['塞拉']='塞拉苏斯的空:BAAALAAECgYIDwAAAA==.',['外敷']='外敷型奶牛:BAABLAAFFH8GAAIPAAIIyw0kHAAyAAAPAAIIyw0kHAAyAAAAAA==.',['多么']='多么克萨拉莫:BAAALAAECgYIBgAAAA==.',['夜月']='夜月由良:BAAALAAECgQIBAAAAA==.',['大姐']='大姐达奶:BAAALAAECgQIBgAAAA==.',['大王']='大王有深度:BAAALAADCgMIAwAAAA==.',['大石']='大石头:BAAALAAFFAIIBAAAAA==.',['大胡']='大胡子老头:BAAALAAECgYIDwAAAA==.',['天姿']='天姿绝色:BAAALAAECgYIDwAAAA==.',['天怒']='天怒:BAAALAAECgYIBgAAAA==.',['天翌']='天翌:BAAALAAECgIIAgAAAA==.',['天锁']='天锁斩月丶:BAAALAAFFAIIAgAAAA==.',['太平']='太平洋的眼泪:BAACLAAFFH8SAAICAAUITh30EwAZAQACAAUITh30EwAZAQAsAAQKfxsAAgIACAhZJG0OAEMDAAIACAhZJG0OAEMDAAAA.',['太熊']='太熊猫了:BAAALAAFFAIIBAAAAA==.',['失落']='失落的人:BAABLAAFFH8NAAMQAAMIPh1PDgCjAAAQAAMIZBZPDgCjAAARAAIIkyOObABiAAAAAA==.',['奥帝']='奥帝努斯:BAAALAAFFAIIAgAAAA==.',['奶王']='奶王:BAABLAAFFH8RAAILAAUIWxu+HAB4AQALAAUIWxu+HAB4AQAAAA==.',['奶萨']='奶萨的秘密:BAAALAADCgIIAgAAAA==.',['她一']='她一脸孩子气:BAAALAAFFAIIBAAAAA==.',['娶灬']='娶灬紅太狼:BAAALAAFFAIIAgAAAA==.',['学长']='学长不凶:BAACLAAFFH86AAISAAcIJxG7CABXAQASAAcIJxG7CABXAQAsAAQKf0gAAhIACAjTGzUHAAICABIACAjTGzUHAAICAAAA.',['完美']='完美帝:BAAALAAECgUIBQAAAA==.完美蓝凤凰:BAABLAAFFH8GAAIMAAYIMAuXFgApAQAMAAYIMAuXFgApAQAAAA==.',['富士']='富士山下:BAAALAADCgYICgAAAA==.',['射太']='射太阳的后羿:BAABLAAECn8jAAMDAAYIYB+3VACbAQAEAAYIdxpBOgDQAQADAAYIrhu3VACbAQAAAA==.',['小光']='小光明:BAABLAAFFH8GAAMPAAIIeRtXDgCkAAAPAAIIeRtXDgCkAAACAAEInQHcbAA2AAAAAA==.',['小剑']='小剑:BAAALAAECgYIDwAAAA==.',['小小']='小小狐妖:BAABLAAFFH8GAAILAAIIHhRiQQB/AAALAAIIHhRiQQB/AAAAAA==.',['小年']='小年糕丶:BAAALAAECgYICwAAAA==.',['小抹']='小抹香鲸:BAAALAAECgEIAQAAAA==.',['小激']='小激凌:BAABLAAFFH8KAAITAAUIVBFKCAAWAQATAAUIVBFKCAAWAQAAAA==.',['小纳']='小纳尔:BAAALAAECgUIBgAAAA==.',['小蜜']='小蜜桃丶:BAAALAAFFAIIAgAAAA==.',['小黑']='小黑呀:BAAALAAECgYIBgAAAA==.',['尤迪']='尤迪安:BAAALAAECgYIBgAAAA==.',['山城']='山城魔女:BAAALAAECgUIBQAAAA==.',['岚心']='岚心贝贝:BAACLAAFFH8QAAIGAAYIxwgqKwATAQAGAAYIxwgqKwATAQAsAAQKfyAAAgYACAiBFM82AH8BAAYACAiBFM82AH8BAAAA.',['希尔']='希尔瓦拉斯:BAABLAAFFH8RAAIDAAgIuB0sBwB3AgADAAgIuB0sBwB3AgAAAA==.',['干啥']='干啥嚒讨厌:BAAALAAECgMIBQAAAA==.',['幽灵']='幽灵小怪兽:BAAALAAECgYIBgAAAA==.',['幽魂']='幽魂行者:BAACLAAFFH8GAAIRAAIIoxFpbgCRAAARAAIIoxFpbgCRAAAsAAQKfxgAAhEABwh8Gfl+APwBABEABwh8Gfl+APwBAAAA.',['廣州']='廣州渣渣輝:BAAALAAECgYIEAAAAA==.',['弗丶']='弗丶拉基米尔:BAAALAAECgIIAgAAAA==.',['张飞']='张飞:BAAALAAECgYIBwAAAA==.',['彼岸']='彼岸草:BAAALAAECgYIBgAAAA==.',['德神']='德神:BAABLAAFFH8RAAIJAAUIBRKvJgDmAAAJAAUIBRKvJgDmAAAAAA==.',['心宽']='心宽体更胖:BAACLAAFFH8hAAMSAAYIphSaDQDKAAASAAUIRBGaDQDKAAAUAAYI2gB+EACzAAAsAAQKfxQAAhIACAiEGTwIAOcBABIACAiEGTwIAOcBAAAA.',['心忧']='心忧灵曦:BAAALAAECgUIBQAAAA==.',['念秋']='念秋意:BAAALAADCgMIAwAAAA==.',['惊雷']='惊雷:BAAALAAECgUIBQAAAA==.',['愤怒']='愤怒小鸟:BAAALAAECgEIAQAAAA==.',['我为']='我为法狂:BAAALAADCgUIBQAAAA==.',['我听']='我听风之语:BAAALAAECgYIEwAAAA==.',['我是']='我是一头牛:BAACLAAFFH8PAAICAAUIHBJrLAAkAQACAAUIHBJrLAAkAQAsAAQKfxwAAwIABgg5GK5gAEUBAAIABgg5GK5gAEUBAA8AAQh8CX9GACkAAAAA.',['我遇']='我遇女心惊:BAAALAAECgUIBQAAAA==.',['战神']='战神:BAAALAAECgMIAwAAAA==.',['戰士']='戰士:BAAALAAECgcIDgAAAA==.',['戰骑']='戰骑:BAAALAAECgYIEwAAAA==.',['戰魔']='戰魔:BAAALAAECgQIBwAAAA==.',['手起']='手起刀落:BAAALAAECgIIAgAAAA==.',['打啵']='打啵浪子:BAACLAAFFH8LAAILAAMIcAkrUwB2AAALAAMIcAkrUwB2AAAsAAQKfx0AAgsABwj2D3uqACsBAAsABwj2D3uqACsBAAAA.',['打断']='打断你狗腿:BAAALAAFFAEIAQAAAA==.',['执酒']='执酒笑白衣丶:BAAALAAECgcIBwAAAA==.',['拽哥']='拽哥神萨:BAAALAADCgEIAQAAAA==.',['拽姐']='拽姐姐:BAAALAADCggICAAAAA==.',['摘星']='摘星辰:BAABLAAFFH8FAAIVAAIICBQFBwB+AAAVAAIICBQFBwB+AAAAAA==.',['攻强']='攻强:BAAALAAECgcIBwAAAA==.',['效果']='效果拔群:BAAALAAECgMIAwAAAA==.',['斋藤']='斋藤千和:BAAALAAFFAEIAQAAAA==.',['无所']='无所谓去:BAAALAAFFAIIBAAAAA==.',['无敌']='无敌圣光骑士:BAAALAADCggIEQAAAA==.无敌小秀:BAAALAADCgcIBwAAAA==.',['无火']='无火余灰:BAAALAAFFAIIAgAAAA==.',['易丽']='易丽丹怒风:BAAALAAECgcIBwAAAA==.',['星座']='星座王子:BAAALAAECgYICwAAAA==.',['星雨']='星雨森林:BAAALAAECgYIDgAAAA==.',['昼夜']='昼夜乱了和谐:BAAALAAECgYICQABLAAFFAgIDgASAC4TAA==.',['晓影']='晓影乄:BAAALAAECgcIEAAAAA==.',['晓得']='晓得来:BAABLAAFFH8lAAIJAAYIewbPIQASAQAJAAYIewbPIQASAQAAAA==.',['暗之']='暗之光者:BAABLAAECn8YAAIWAAYINAMElgDBAAAWAAYINAMElgDBAAAAAA==.',['暗月']='暗月丨:BAAALAAFFAMIAwAAAA==.',['月夜']='月夜猎刃:BAAALAAECgMIAwAAAA==.',['机智']='机智的估算师:BAAALAAECgcIDQAAAA==.',['杀戮']='杀戮血屠:BAAALAAFFAIIBAAAAA==.',['杀认']='杀认如麻:BAAALAADCgMIAwAAAA==.',['林夕']='林夕碟衣:BAAALAAFFAMIAQAAAA==.林夕魅儿:BAACLAAFFH85AAMNAAcIXRx7CQAYAgANAAcIXRx7CQAYAgALAAUIKiErFAAUAQAsAAQKfyYAAw0ACAhWHnMnAHkCAA0ACAhWHnMnAHkCAAsABwh5H9o+ACICAAAA.',['林熊']='林熊猫:BAAALAAECgYICQAAAA==.',['柒玥']='柒玥丶:BAAALAAECgYIBgAAAA==.',['柠檬']='柠檬德:BAAALAADCggIFgAAAA==.柠檬绿茶:BAAALAADCgUIBQAAAA==.',['格斗']='格斗八神庵:BAAALAAECgYIBgAAAA==.格斗玛莉:BAAALAAECgYIDgAAAA==.',['梅林']='梅林丶转生:BAABLAAFFH8LAAIWAAIIAhnzKwCUAAAWAAIIAhnzKwCUAAAAAA==.',['梦蝶']='梦蝶:BAAALAAECgYIBgAAAA==.',['森德']='森德伊:BAAALAAECgIIBAAAAA==.',['森林']='森林中的美女:BAAALAAFFAIIAgAAAA==.',['棱丶']='棱丶镜:BAAALAAECgIIAgAAAA==.',['椰岛']='椰岛雄风:BAAALAAECgYIBgAAAA==.',['橡果']='橡果果:BAAALAAECgYIDAAAAA==.',['正方']='正方形铁板:BAACLAAFFH8KAAICAAIIzhT4RgCZAAACAAIIzhT4RgCZAAAsAAQKfxgAAwIABwj9FPW0AJgBAAIABwiRFPW0AJgBAA8AAgjaFBNpAGcAAAAA.',['武德']='武德充沛:BAAALAAECgYIBgAAAA==.',['死亡']='死亡之旅:BAAALAAECgYIEgAAAA==.',['殇殇']='殇殇小梅:BAAALAAECggICAAAAA==.',['毁灭']='毁灭之域:BAAALAADCgcIDQAAAA==.',['比德']='比德格拉斯:BAAALAAECgYICwAAAA==.',['水獭']='水獭:BAAALAAFFAIIAgAAAA==.',['没活']='没活儿:BAAALAAECgYIBgAAAA==.',['油炸']='油炸豆腐泡:BAAALAAECgYIDgAAAA==.油炸酒鬼花生:BAABLAAFFH8GAAIRAAIIeQo1fQCJAAARAAIIeQo1fQCJAAAAAA==.',['深夜']='深夜的狂欢:BAAALAAECgMIAwAAAA==.',['渣渣']='渣渣波:BAAALAADCgcIBwAAAA==.',['温柔']='温柔丶:BAABLAAECn8YAAILAAYIiBo4MQCdAQALAAYIiBo4MQCdAQAAAA==.',['潄石']='潄石:BAAALAAECgYIDAAAAA==.',['澪月']='澪月使魔:BAAALAAECgYIDAAAAA==.',['火烷']='火烷:BAABLAAFFH8SAAMLAAYIFCI1FQC4AQALAAUIQCE1FQC4AQANAAIIcgIBOwBpAAAAAA==.',['灬囵']='灬囵:BAAALAAFFAIIBAAAAA==.',['灬圣']='灬圣光灬:BAAALAADCgQIBAAAAA==.',['灬法']='灬法海丶丨:BAABLAAECn8lAAIMAAYI6B/mFADPAQAMAAYI6B/mFADPAQAAAA==.',['灬爽']='灬爽灬:BAAALAAECgMIBAAAAA==.',['灬被']='灬被遗忘者灬:BAAALAAECgMIAwAAAA==.',['灭炎']='灭炎:BAABLAAFFH8KAAILAAIIjiPsKgCuAAALAAIIjiPsKgCuAAAAAA==.',['灰色']='灰色幽神:BAAALAADCgYIBgAAAA==.灰色憂鬱:BAAALAAECgUIBQAAAA==.',['灵韵']='灵韵之风:BAABLAAFFH8GAAIWAAIIPQ7mOQCBAAAWAAIIPQ7mOQCBAAAAAA==.',['炽热']='炽热的骨头:BAAALAAECgEIAQAAAA==.',['然子']='然子:BAABLAAFFH8FAAICAAMIlhKKQgCPAAACAAMIlhKKQgCPAAAAAA==.',['煮熟']='煮熟的螃蟹萨:BAAALAADCgEIAQAAAA==.',['熙月']='熙月灬:BAAALAAECgcIBwAAAA==.',['熟睡']='熟睡的考拉:BAAALAAECggIEgAAAA==.',['爆打']='爆打红烧肉:BAACLAAFFH8OAAIXAAII1R7BSgCVAAAXAAII1R7BSgCVAAAsAAQKfxYAAxgABwgWGOcIAMkBABgABwjSE+cIAMkBABcABQhxGOKkADwBAAAA.',['爱淳']='爱淳旭:BAAALAAECgEIAQAAAA==.',['爱睡']='爱睡觉的客户:BAAALAADCgYIBgAAAA==.',['牧柛']='牧柛:BAABLAAFFH8NAAIWAAIIhg+pPgBtAAAWAAIIhg+pPgBtAAAAAA==.',['狄塞']='狄塞拉:BAABLAAFFH8GAAIFAAYIVwdONgA6AQAFAAYIVwdONgA6AQAAAA==.',['独孤']='独孤云:BAAALAADCgcIBwAAAA==.',['王叔']='王叔叔:BAAALAADCgEIAQAAAA==.',['玖伍']='玖伍二柒:BAAALAAECgUIBwAAAA==.',['玛卡']='玛卡巴卡欣:BAAALAAFFAIIAgAAAA==.',['玩兔']='玩兔睡:BAAALAADCgIIAgAAAA==.',['瓦转']='瓦转魔兽丶:BAACLAAFFH8WAAICAAYIEx9iDwDMAQACAAYIEx9iDwDMAQAsAAQKfxQAAgIACAihHfUWAFgCAAIACAihHfUWAFgCAAAA.',['疯狂']='疯狂戴夫:BAAALAADCgcIBwAAAA==.',['痴情']='痴情小狼:BAAALAAECgcICAAAAA==.',['看我']='看我牛逼吗:BAABLAAFFH8GAAIHAAII1xHjLwA0AAAHAAII1xHjLwA0AAAAAA==.',['硬汉']='硬汉:BAAALAAECgQIBAAAAA==.',['碧儿']='碧儿达茗:BAAALAAFFAIIAgAAAA==.',['神王']='神王牧:BAAALAAFFAIIAgAAAA==.神王猎:BAAALAAFFAIIBAAAAA==.神王萨:BAAALAAFFAIIBAAAAA==.神王迪凯:BAAALAAFFAIIAgAAAA==.神王骑:BAAALAAFFAIIAgAAAA==.',['福心']='福心杰:BAAALAAECgIIAwAAAA==.',['离美']='离美人:BAAALAAECgYICgAAAA==.',['空山']='空山清雨:BAAALAAECgYICAAAAA==.',['站进']='站进大雨:BAABLAAFFH8FAAILAAMIshzBKACzAAALAAMIshzBKACzAAAAAA==.',['笑给']='笑给风听:BAAALAAFFAIIAgABLAAFFAIIAgAKAAAAAA==.',['筝筝']='筝筝纸鸢:BAACLAAFFH8WAAIDAAcIBxvHCAD6AQADAAcIBxvHCAD6AQAsAAQKfxcAAwMACAiSI8IZAGMCAAMACAiSI8IZAGMCAAQABQh0DwCKALsAAAAA.',['简约']='简约机械:BAABLAAFFH8OAAISAAII0RsJFwByAAASAAII0RsJFwByAAAAAA==.',['箖笓']='箖笓:BAAALAAFFAIIAgAAAA==.',['米欧']='米欧克:BAAALAAFFAEIAQAAAA==.米欧珂:BAABLAAFFH8jAAMJAAcIQRrfDADtAQAJAAYIqB3fDADtAQAMAAEI+QaFLQBKAAAAAA==.',['米浆']='米浆粑粑:BAACLAAFFH8+AAMMAAcIuB2OBgAHAgAMAAcIuB2OBgAHAgAJAAYIWB7bBQDKAQAsAAQKfz0AAwkACAiSIzEKAAsDAAkACAiSIzEKAAsDAAwABwiFIpEXAKcCAAAA.',['粟米']='粟米:BAAALAAECggIBgAAAA==.',['紫夜']='紫夜君:BAAALAADCgYIBgAAAA==.',['红色']='红色憂鬱:BAAALAAECgUIBQAAAA==.',['纳尔']='纳尔:BAAALAAECgIIAgAAAA==.',['给本']='给本宫站住:BAAALAADCggICAAAAA==.',['绿色']='绿色憂鬱:BAAALAAECgQIBAAAAA==.',['美如']='美如的德:BAAALAAFFAIIAgAAAA==.',['老汉']='老汉:BAAALAADCgEIAQAAAA==.',['老白']='老白涮肉坊:BAABLAAECn8cAAQGAAYIQhzYXgDXAQAGAAYI4BvYXgDXAQAHAAIIyRn5fwCGAAAZAAEIPg6pPwAnAAABLAAFFAgIOAAGAHgjAA==.',['老骑']='老骑:BAAALAAFFAIIAgAAAA==.',['胖僧']='胖僧:BAAALAAECgYICgAAAA==.',['胡椒']='胡椒猪肚鸡:BAAALAADCgUIBQAAAA==.',['艾瑞']='艾瑞利婭:BAAALAAECgYICQAAAA==.',['苍穹']='苍穹一刀丶:BAAALAAFFAIIAgAAAA==.',['范尼']='范尼是德鲁衣:BAAALAAECgIIAgAAAA==.',['草莓']='草莓啵啵:BAABLAAECn8UAAIWAAYI0QiOhwDsAAAWAAYI0QiOhwDsAAAAAA==.',['莉娜']='莉娜因巴斯:BAAALAADCgMIAwAAAA==.',['莱恩']='莱恩斯:BAAALAAECgYIBwAAAA==.',['营养']='营养快奶:BAAALAADCgMIAwAAAA==.',['蓝色']='蓝色憂鬱:BAAALAAFFAIIAgAAAA==.',['虚无']='虚无术:BAAALAAECgQICAAAAA==.',['虚空']='虚空牢大:BAAALAAECgYICQAAAA==.',['蛋仔']='蛋仔派对:BAAALAAECgMIAwAAAA==.',['血色']='血色美杜莎:BAABLAAFFH8IAAIDAAgI/gDgvQArAAADAAgI/gDgvQArAAAAAA==.',['西尓']='西尓瓦納斯:BAAALAAECgIIAgAAAA==.',['許小']='許小佡:BAABLAAECn8dAAIBAAYI1SKzIgDZAQABAAYI1SKzIgDZAQAAAA==.',['识坐']='识坐又肯坐:BAAALAAECggICAAAAA==.',['说走']='说走咱就走啊:BAAALAADCgQIBAAAAA==.',['请叫']='请叫我倾城君:BAABLAAFFH8KAAIJAAII2CKCIgCbAAAJAAII2CKCIgCbAAAAAA==.请叫我黑哥哥:BAABLAAECn8XAAMaAAgI8SBLAwCpAgAaAAgI8SBLAwCpAgAQAAYICBWwJgCKAQABLAAFFAgIGwAaAPIcAA==.',['诺基']='诺基亚:BAAALAAECgQIBAAAAA==.',['赖着']='赖着不死:BAAALAAFFAIIBAAAAA==.',['赤兔']='赤兔马保国:BAAALAAECgEIAQAAAA==.',['赤色']='赤色彗星:BAAALAAECgYICgAAAA==.',['超市']='超市里扫货:BAABLAAECn8cAAIGAAgIZheJRgAeAgAGAAgIZheJRgAeAgABLAAFFAgIDwAHAKYjAA==.',['超级']='超级卡卡:BAAALAAECgYIBwAAAA==.',['路鬼']='路鬼鬼先生:BAAALAAECgYIBgAAAA==.',['轻羽']='轻羽:BAAALAAFFAIIAgAAAA==.',['辰儿']='辰儿:BAABLAAFFH8GAAIBAAYI8g5BJABsAQABAAYI8g5BJABsAQAAAA==.',['达锦']='达锦壹圣:BAAALAAFFAMIAwAAAA==.',['迪奥']='迪奥驰昂:BAAALAADCgIIAgAAAA==.',['迷蝶']='迷蝶香:BAAALAAECgcIBwAAAA==.',['通哔']='通哔归来了:BAABLAAFFH8GAAIGAAIIxRd5KwCkAAAGAAIIxRd5KwCkAAAAAA==.',['逸笑']='逸笑奈何:BAAALAAFFAEIAQAAAA==.',['遗忘']='遗忘的圣光:BAAALAAECgYIBgAAAA==.',['那个']='那个萨丶满:BAAALAAECgYIDQAAAA==.',['那丶']='那丶个战丶士:BAAALAADCggICwAAAA==.',['邪恶']='邪恶小海盗:BAAALAAFFAIIAgAAAA==.',['邪气']='邪气男子:BAABLAAECn8UAAIYAAgIERHJBQCDAQAYAAgIERHJBQCDAQAAAA==.',['鎏歌']='鎏歌:BAAALAAECgEIAQAAAA==.',['铁血']='铁血长歌:BAAALAAFFAIIAgAAAA==.',['铜钱']='铜钱宝娘:BAAALAADCgYIBgAAAA==.',['长醉']='长醉不醒:BAAALAAECgYIBgAAAA==.',['门口']='门口江:BAAALAAFFAIIAgAAAA==.',['阿佛']='阿佛洛狄忒:BAABLAAFFH8GAAIbAAQIxAOnHgCvAAAbAAQIxAOnHgCvAAAAAA==.',['阿吉']='阿吉:BAAALAAFFAIIAgAAAA==.',['阿尓']='阿尓托莉雅:BAABLAAFFH8IAAIDAAgIJRrtCgA5AgADAAgIJRrtCgA5AgAAAA==.',['阿怜']='阿怜:BAAALAAECggICAAAAA==.',['阿赞']='阿赞:BAAALAAECgMIAwAAAA==.',['陆小']='陆小宝:BAAALAAECgQIBAAAAA==.',['陆玥']='陆玥伊:BAAALAAECgMIBQAAAA==.',['随风']='随风漂流:BAAALAAECgYIDAAAAA==.',['隐秘']='隐秘果实:BAAALAAFFAIIAwAAAA==.',['难道']='难道没天理:BAAALAAECgQIBAAAAA==.',['雨凯']='雨凯:BAAALAADCggICAAAAA==.',['雨落']='雨落凡尘:BAABLAAFFH8YAAMXAAYI0SIxEwDiAQAXAAYIJSIxEwDiAQATAAQI4BqYCQC3AAAAAA==.',['雪碧']='雪碧:BAAALAADCgQIBAAAAA==.',['霜雨']='霜雨丶:BAAALAAFFAMIAwAAAA==.',['靜待']='靜待徍陰:BAAALAAECgIIAgAAAA==.',['非常']='非常有趣:BAAALAAECgIIAgAAAA==.非常骨感:BAAALAAECgIIAgAAAA==.',['風流']='風流歸來:BAAALAAECgYIBgAAAA==.',['风中']='风中玫瑰:BAAALAAECgEIAQAAAA==.',['风之']='风之利刃:BAABLAAECn8aAAIJAAcIjBH1OAA9AQAJAAcIjBH1OAA9AQAAAA==.风之谜:BAABLAAFFH8GAAIRAAII4xUHcwCPAAARAAII4xUHcwCPAAAAAA==.',['风吹']='风吹尿叁章:BAAALAAECgUIBQAAAA==.',['风怒']='风怒丹利伊:BAAALAAECgYIEgAAAA==.',['风神']='风神摇曳灬:BAAALAAFFAIIBAAAAA==.',['风语']='风语燕归来:BAAALAAECgYIDAAAAA==.',['风阁']='风阁:BAAALAAECgIIBQAAAA==.',['饭貓']='饭貓:BAAALAAECgYIBwAAAA==.',['馊裤']='馊裤泰裤辣:BAAALAAECggIBgAAAA==.',['骑了']='骑了个怪:BAAALAAECgYICQAAAA==.',['骑单']='骑单车:BAAALAAECgMIBQAAAA==.',['骑空']='骑空士:BAAALAADCgEIAQAAAA==.',['鲲鹏']='鲲鹏:BAABLAAECn8eAAICAAYIOQ2fgQD/AAACAAYIOQ2fgQD/AAAAAA==.',['麒麟']='麒麟丶牙:BAAALAAFFAIIAgAAAA==.',['麻辣']='麻辣小鱼干:BAAALAADCgEIAQAAAA==.',['黄昏']='黄昏之光:BAAALAAECgIIAgAAAA==.',['黑司']='黑司蓜小高丶:BAAALAAECgYIBgAAAA==.',['黑死']='黑死牟:BAABLAAFFH8KAAILAAIIFCE+PwCqAAALAAIIFCE+PwCqAAAAAA==.',['黑皮']='黑皮牛哇:BAAALAAECgQIBAAAAA==.',['龙与']='龙与玫瑰:BAAALAAFFAIIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end