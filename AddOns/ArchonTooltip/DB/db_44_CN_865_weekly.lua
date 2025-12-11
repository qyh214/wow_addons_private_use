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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Frost','Warlock-Demonology','Shaman-Restoration','Shaman-Elemental','Hunter-Marksmanship','Warrior-Fury','Druid-Restoration','Druid-Balance','Warrior-Protection','Monk-Mistweaver','Monk-Windwalker','Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Vengeance','Mage-Arcane','Warlock-Destruction','Priest-Holy','Priest-Shadow','Paladin-Protection','Mage-Frost','DeathKnight-Blood','Paladin-Holy','Druid-Guardian','DeathKnight-Unholy','Warrior-Arms','Rogue-Assassination','Druid-Feral','Shaman-Enhancement','Mage-Fire','Rogue-Subtlety','Warlock-Affliction','Monk-Brewmaster','Evoker-Preservation',}; local provider = {region='CN',realm='阿拉希',name='CN',type='weekly',zone=44,date='2025-12-09',data={Au='Aurira:BAAALAAFFAEIAQAAAA==.',Bm='Bmwninet:BAAALAADCgEIAQAAAA==.',By='Byaneiu:BAABLAAFFH8IAAIBAAgIJCB/BACwAgABAAgIJCB/BACwAgAAAA==.',Ca='Caliban:BAAALAAECgQIAQAAAA==.Carryevelynn:BAAALAAFFAIIAgAAAA==.',Ce='Cerdi:BAAALAAECgYIDAAAAA==.',Cl='Clkg:BAAALAAFFAIIAgAAAA==.',Co='Coco:BAAALAAECgYIDQAAAA==.',De='Deadgame:BAAALAAECgYICwAAAA==.Desire:BAACLAAFFH8KAAICAAII8BddTgCiAAACAAII8BddTgCiAAAsAAQKfxwAAgIACAgYICJBAH4CAAIACAgYICJBAH4CAAAA.Desmo:BAAALAADCgQIBAAAAA==.',Do='Dom:BAAALAAECgEIAQAAAA==.Doomart:BAABLAAFFH8IAAIDAAIIQSG6CQC7AAADAAIIQSG6CQC7AAAAAA==.',Dr='Druidsoul:BAAALAAECgMIAwAAAA==.',['Dí']='Dísir:BAAALAAECgYIBgAAAA==.',Et='Eternal:BAAALAAECgYIBgAAAA==.',Ez='Ezel:BAAALAAECgIIAgAAAA==.',Fa='Faith:BAAALAADCgIIAgAAAA==.',Fu='Fuwawa:BAACLAAFFH8tAAMEAAUIkB3QFAAOAQAEAAUIkB3QFAAOAQAFAAEImwKOWQAAAAAsAAQKfzcAAgQACAhOJNwLAAUDAAQACAhOJNwLAAUDAAAA.',Ge='Gervin:BAAALAAECgYIDAAAAA==.',He='Hellohades:BAABLAAECn8XAAICAAYIQhyjSQBoAQACAAYIQhyjSQBoAQAAAA==.Hellovenus:BAAALAAECgIIAgAAAA==.Hemetnswy:BAACLAAFFH8NAAMBAAMICRmAKwDSAAABAAMIERaAKwDSAAAGAAIIhxWiHQCSAAAsAAQKfxwAAgEACAgXIoEQAKECAAEACAgXIoEQAKECAAAA.Hetrshy:BAABLAAFFH8HAAICAAII9RsWUAChAAACAAII9RsWUAChAAAAAA==.',Ho='Honeyorange:BAAALAAFFAIIAgAAAA==.',In='Invincibl:BAAALAAECggIDgAAAA==.',Je='Jennie:BAABLAAFFH8IAAIBAAIIGg0XrQA6AAABAAIIGg0XrQA6AAAAAA==.',Ka='Kadgar:BAAALAADCgIIAwAAAA==.Kawasakizx:BAABLAAFFH8HAAIHAAQIZQIDKwClAAAHAAQIZQIDKwClAAAAAA==.Kayneqs:BAAALAAFFAIIAwABLAAFFAYIBgABAHchAA==.',Lo='Logan:BAAALAAECggICAAAAA==.',Ls='Lsskykg:BAAALAAECgYIBwAAAA==.',Lu='Lunarzzy:BAABLAAFFH8MAAIIAAIIghxfKwCAAAAIAAIIghxfKwCAAAAAAA==.',Ly='Lyqssr:BAABLAAFFH8QAAMIAAUI7RMMJgDuAAAIAAMIOB8MJgDuAAAJAAMINAyhIAC/AAABLAAFFAcIHgAKAAYfAA==.',Ma='Maheight:BAAALAAECgIIAgAAAA==.Mahfour:BAAALAAECgEIAQAAAA==.Mahone:BAAALAAECgYIBgAAAA==.Mahzero:BAAALAAECgMIAwAAAA==.',Mi='Mios:BAAALAAECgYIBgAAAA==.Misselina:BAAALAAECgUIBgAAAA==.Missx:BAACLAAFFH8ZAAMLAAMIyRR8EAC3AAALAAMIyRR8EAC3AAAMAAII8Qe5FwBAAAAsAAQKfzYAAwsACAh6GQkMAPkBAAsACAh6GQkMAPkBAAwABwjKFJ8vAJIBAAEsAAUUBQgYAAIAKyAA.',Mo='Moaobo:BAAALAAECgEIAQAAAA==.Monik:BAAALAADCgIIAgAAAA==.',Mu='Muamua:BAAALAAECgUICwAAAA==.',Pa='Parisian:BAAALAAECgMIAwAAAA==.',Qi='Qiangkuan:BAAALAAECgYICAAAAA==.',Sa='Sargelas:BAAALAADCgEIAQAAAA==.',Se='Seraphina:BAAALAAECgQIBAAAAA==.',So='Soft:BAAALAAECggIDgAAAA==.',Ti='Tinatina:BAAALAAECgEIAQAAAA==.Tiriontom:BAAALAAFFAIIAgAAAA==.',Ve='Velen:BAAALAAECgYICQAAAA==.',Wi='Windranger:BAABLAAFFH8GAAIBAAYIrxJMQABLAQABAAYIrxJMQABLAQAAAA==.',Wo='Wowaxe:BAACLAAFFH8FAAIHAAII+Q7KTwBFAAAHAAII+Q7KTwBFAAAsAAQKfxcAAgcABwihGnZHABsCAAcABwihGnZHABsCAAAA.',Wr='Wrysunny:BAAALAAECggICAAAAA==.',['一个']='一个也不能少:BAAALAAECgUIDwAAAA==.',['一二']='一二三:BAABLAAFFH8LAAIKAAQIWRyAGADqAAAKAAQIWRyAGADqAAAAAA==.',['一壶']='一壶奶茶:BAAALAAECggICAAAAA==.',['一撕']='一撕就得:BAAALAAFFAIIAgAAAA==.',['一泥']='一泥菩萨一:BAABLAAFFH8HAAIEAAMIoRY9OQCOAAAEAAMIoRY9OQCOAAAAAA==.',['一球']='一球成名:BAAALAADCgYIBgAAAA==.',['一黑']='一黑暗领主一:BAAALAAECgYIDAAAAA==.',['七仔']='七仔:BAABLAAFFH8MAAINAAIIYSBNMACrAAANAAIIYSBNMACrAAAAAA==.七仔丶:BAAALAAFFAMIAwAAAA==.',['七崽']='七崽丶:BAABLAAFFH8MAAIOAAMITxdgKAC9AAAOAAMITxdgKAC9AAAAAA==.',['七里']='七里香丶:BAAALAAECgYIBgAAAA==.',['三军']='三军:BAAALAAFFAIIBAAAAA==.',['三千']='三千千:BAAALAAECggIAgAAAA==.',['三战']='三战神三:BAABLAAFFH8FAAIEAAIIDxB1TgBtAAAEAAIIDxB1TgBtAAAAAA==.',['上弄']='上弄死它:BAAALAAECgcIDAAAAA==.',['业余']='业余巨星:BAAALAADCgEIBAAAAA==.',['东方']='东方壮士:BAAALAAECgQIBAAAAA==.',['东风']='东风破:BAAALAADCgYIBgAAAA==.',['丨夜']='丨夜丶落寞:BAAALAADCgYIBgAAAA==.',['丨小']='丨小丶智丨:BAAALAADCggICAAAAA==.丨小智丨:BAAALAAECgQIBAAAAA==.',['丨屠']='丨屠夫丶:BAAALAAECgIIAgAAAA==.',['丨执']='丨执笔畫江山:BAAALAAFFAIIBAAAAA==.',['丨芷']='丨芷柠丨:BAABLAAFFH8OAAIBAAYIAB0uCwDhAQABAAYIAB0uCwDhAQAAAA==.',['丨青']='丨青山独归远:BAABLAAFFH8GAAICAAIIByK1OADAAAACAAIIByK1OADAAAABLAAFFAUIDQACABUQAA==.',['丶他']='丶他二姨:BAABLAAFFH8KAAIPAAIIFQfHFwBXAAAPAAIIFQfHFwBXAAAAAA==.',['丶晨']='丶晨祭:BAABLAAFFH8FAAIIAAUItRRiCgBgAQAIAAUItRRiCgBgAQABLAAFFAgIEgAJAHkdAA==.',['丶沉']='丶沉祭:BAAALAAECggICAAAAA==.',['丶牛']='丶牛小战:BAAALAADCgMIAwAAAA==.',['丶蜡']='丶蜡笔小新:BAAALAAECgMIAwAAAA==.',['丶靚']='丶靚仔:BAABLAAFFH8mAAIMAAYIKyJXAwD1AQAMAAYIKyJXAwD1AQABLAAFFAgICwABAH4JAA==.',['丸冰']='丸冰丸邪丶:BAAALAAFFAIIAgAAAA==.',['丸言']='丸言丸语丶:BAABLAAECn8fAAINAAgIoyJUHgAnAgANAAgIoyJUHgAnAgAAAA==.',['丹心']='丹心:BAAALAAECgYIBwAAAA==.',['为了']='为了坐骑:BAAALAAECgYIBgAAAA==.',['丿痴']='丿痴心灬绝对:BAAALAAECgMIAwAAAA==.',['乄放']='乄放縱鍀遊蕩:BAAALAAFFAIIBAAAAA==.',['久鬼']='久鬼月抄:BAAALAAFFAIIAgAAAA==.',['乌龙']='乌龙茶丶:BAAALAAECgYIDgAAAA==.',['乐伊']='乐伊凹蹽:BAAALAAECgYICAAAAA==.',['乖乖']='乖乖狠:BAAALAAECgYIBgAAAA==.',['九尾']='九尾:BAAALAAECgMIAwAAAA==.',['九朝']='九朝感悟:BAACLAAFFH8HAAINAAMI0AdDSwBxAAANAAMI0AdDSwBxAAAsAAQKfzMAAg0ABwgmHYUkAAcCAA0ABwgmHYUkAAcCAAAA.',['九朵']='九朵玫瑰恋:BAAALAAECgEIAQAAAA==.',['乱世']='乱世枭雄:BAAALAAECgEIAQAAAA==.',['二二']='二二三四:BAAALAADCgQIBAAAAA==.',['二楼']='二楼后座:BAAALAAECgUIBgAAAA==.',['二零']='二零二六无敌:BAAALAAECgcICAAAAA==.',['人民']='人民卫士:BAABLAAFFH8GAAIHAAIIsQ9RNgCYAAAHAAIIsQ9RNgCYAAAAAA==.',['仙帝']='仙帝:BAAALAAFFAIIAgAAAA==.',['仟仟']='仟仟:BAABLAAFFH8GAAIBAAMI9wDRxQAVAAABAAMI9wDRxQAVAAAAAA==.',['仲商']='仲商晓梦:BAAALAAECggICAAAAA==.',['伊利']='伊利木有蛋:BAAALAAECgQIBAAAAA==.',['伊若']='伊若萨古纳尔:BAAALAAECgIIAgAAAA==.',['伊莉']='伊莉莎怒风:BAABLAAECn8UAAIBAAYIHw4SwADxAAABAAYIHw4SwADxAAAAAA==.',['会上']='会上树的海参:BAAALAAECgQIBAAAAA==.',['会打']='会打猎的老灭:BAAALAAFFAIIAgAAAA==.',['会放']='会放闪电的牛:BAAALAAECgYICwAAAA==.',['伤心']='伤心阿飞:BAAALAADCgMIBAAAAA==.',['佑恋']='佑恋:BAABLAAECn8YAAMBAAgICxhWQADOAQABAAgIsRZWQADOAQAGAAgIdhGKRwCWAQAAAA==.',['佛龍']='佛龍死:BAAALAADCgUIBQAAAA==.佛龍萨满:BAAALAAFFAIIAgAAAA==.',['你是']='你是星辰大海:BAAALAAFFAEIAQAAAA==.',['你的']='你的瞳我的影:BAABLAAECn8UAAIBAAYICBtWigA6AQABAAYICBtWigA6AQAAAA==.',['你艾']='你艾希我奶吗:BAAALAAFFAIIAgAAAA==.',['保镖']='保镖:BAAALAAECgQIBAAAAA==.',['信仰']='信仰:BAAALAADCgYIBgAAAA==.信仰之萨:BAAALAAFFAIIAgAAAA==.信仰之骑:BAAALAAECgYICQAAAA==.',['修罗']='修罗之爱:BAAALAAECgYICAAAAA==.',['傲世']='傲世皇妃:BAABLAAFFH8GAAIIAAIIJxC2RgBjAAAIAAIIJxC2RgBjAAAAAA==.',['傷别']='傷别灕灬逍遥:BAABLAAFFH8GAAIQAAYItySBAgCLAgAQAAYItySBAgCLAgAAAA==.',['兄弟']='兄弟看我眼神:BAACLAAFFH8GAAIOAAIIrBZbMQCnAAAOAAIIrBZbMQCnAAAsAAQKfxsAAg4ACAhdGxMvAKACAA4ACAhdGxMvAKACAAAA.',['光辉']='光辉出鞘:BAAALAAECgUIBQAAAA==.',['克拉']='克拉迪斯:BAAALAADCgEIAQAAAA==.',['兜兜']='兜兜嘟嘟:BAAALAADCgYICgAAAA==.',['全開']='全開哈拉少:BAAALAAFFAIIAgAAAA==.',['八尾']='八尾:BAABLAAFFH8GAAIEAAIIaQoEWQBlAAAEAAIIaQoEWQBlAAAAAA==.',['八零']='八零带妹输出:BAABLAAFFH8NAAIBAAYIIxUINABwAQABAAYIIxUINABwAQAAAA==.八零扶墙输出:BAABLAAFFH8JAAMRAAMIOBn2MwCpAAARAAMIOBn2MwCpAAADAAEI3gZ8LgBGAAAAAA==.',['六畜']='六畜兴旺:BAAALAAECgYICwAAAA==.',['兰犹']='兰犹若:BAAALAADCgYIBgAAAA==.',['兰若']='兰若琳:BAAALAADCgQIBAAAAA==.',['兽刃']='兽刃永不为奴:BAACLAAFFH8rAAIKAAUIEh86DwBbAQAKAAUIEh86DwBbAQAsAAQKfy0AAgoACAgJH2gPAMUCAAoACAgJH2gPAMUCAAAA.',['再次']='再次野性生长:BAAALAAECgYIBwAAAA==.',['冰封']='冰封血月:BAAALAAFFAIIBAAAAA==.',['冲你']='冲你丫的:BAABLAAFFH8IAAIHAAgIigFpYwAvAAAHAAgIigFpYwAvAAAAAA==.',['冲锋']='冲锋咆哮:BAAALAADCgMIAwAAAA==.',['决战']='决战湘北山王:BAAALAAECgYIBgAAAA==.',['凛冬']='凛冬的繁星:BAAALAAECggIDAAAAA==.',['凯撒']='凯撒:BAAALAAECggIEAAAAA==.',['剑影']='剑影潇湘:BAACLAAFFH8XAAMSAAcIXR2MBgBoAgASAAcIXR2MBgBoAgATAAEI4QTILgA6AAAsAAQKfxoAAhIABggPJJIOAGwCABIABggPJJIOAGwCAAAA.',['剑雨']='剑雨魂:BAAALAAFFAIIAgAAAA==.',['北铁']='北铁:BAABLAAFFH8JAAIBAAUIVwTQYQDBAAABAAUIVwTQYQDBAAAAAA==.',['十一']='十一爹:BAAALAAECgIIAgAAAA==.十一的爸爸:BAAALAAECgIIAwAAAA==.',['十六']='十六夜丶:BAAALAADCgEIAQAAAA==.',['卡瓦']='卡瓦普:BAAALAAECgQIBAAAAA==.',['印第']='印第安老斑鸠:BAACLAAFFH8VAAMNAAUIXB8jHgB3AQANAAUIXB8jHgB3AQAUAAII5xl6EACWAAAsAAQKfyAAAg0ABwhkHzVpABcCAA0ABwhkHzVpABcCAAAA.',['卿尘']='卿尘:BAAALAADCgYIBgAAAA==.',['厚德']='厚德载物:BAAALAAECgYIDAAAAA==.',['又要']='又要改名字:BAAALAADCggICAAAAA==.',['双刃']='双刃前刺:BAAALAAECgYIEAAAAA==.',['双子']='双子十二星:BAAALAAECgEIAQAAAA==.',['反季']='反季雪:BAAALAAECgUICQAAAA==.',['发飙']='发飙的牛:BAAALAAECgUIBQAAAA==.',['口麦']='口麦克老狼口:BAABLAAECn8UAAIVAAYIjhjWGABiAQAVAAYIjhjWGABiAQAAAA==.',['古月']='古月娜:BAABLAAFFH8GAAICAAIIYgI2pgAwAAACAAIIYgI2pgAwAAAAAA==.',['可乐']='可乐大呲花:BAAALAADCgEIAQAAAA==.',['可爱']='可爱包包:BAABLAAFFH8RAAMWAAUIeQg3EgDBAAAWAAUIVgY3EgDBAAACAAEIsguRfABIAAAAAA==.',['可苦']='可苦丶可乐:BAAALAAECgYIBgAAAA==.',['吃苹']='吃苹菓的瓶子:BAAALAADCgcIBwAAAA==.',['各有']='各有所爱:BAAALAAECgEIAQAAAA==.',['吆喝']='吆喝圣光吧:BAABLAAFFH8GAAINAAIIZw5RSwCWAAANAAIIZw5RSwCWAAAAAA==.',['吖丶']='吖丶大熊猫:BAAALAADCggICQAAAA==.',['听风']='听风丶丶:BAAALAAECgIIAgAAAA==.',['呜呜']='呜呜哇:BAAALAAECgYICwAAAA==.',['命为']='命为志存:BAACLAAFFH8UAAICAAUIIBOORAAuAQACAAUIIBOORAAuAQAsAAQKfyYAAgIACAgJIHANAIcCAAIACAgJIHANAIcCAAAA.',['咕叽']='咕叽咕叽牧:BAAALAAECggIEAABLAAFFAgICAAIADMeAA==.',['咸蛋']='咸蛋超人:BAABLAAFFH8UAAIKAAII8QL3LwBVAAAKAAII8QL3LwBVAAABLAAFFAgIBwAHAEIWAA==.',['唐舞']='唐舞彤:BAAALAAECgQIBAAAAA==.',['唤醒']='唤醒沉睡的伱:BAAALAAECggIAQAAAA==.',['善意']='善意的坏:BAAALAADCggIDAAAAA==.',['喝酒']='喝酒吐咑架輸:BAAALAADCgYIBgAAAA==.',['喵汪']='喵汪靓仔:BAAALAAFFAIIBAAAAA==.',['嘟嘟']='嘟嘟囔囔:BAAALAAFFAIIBAAAAA==.',['囧囧']='囧囧的笨之煞:BAAALAADCgIIAgAAAA==.',['固悟']='固悟风:BAAALAAFFAIIAgAAAA==.',['国士']='国士丶无双:BAACLAAFFH8QAAIQAAQI/gMqVgBGAAAQAAQI/gMqVgBGAAAsAAQKfx4AAxAACAg8Gj5AAEoCABAACAg8Gj5AAEoCABUAAggBBHyMAEQAAAAA.',['圖腾']='圖腾:BAAALAAECgMIAwAAAA==.',['圣光']='圣光熔炉:BAAALAADCgMIAwAAAA==.圣光铁憨憨:BAABLAAECn8VAAINAAYI1B42bgANAgANAAYI1B42bgANAgAAAA==.圣光闪现:BAACLAAFFH8FAAIXAAIIUgW5JAB5AAAXAAIIUgW5JAB5AAAsAAQKfxgAAhcABgjnGRctAMABABcABgjnGRctAMABAAAA.',['地獄']='地獄使者:BAAALAAECgYICQAAAA==.',['塞壬']='塞壬之泣:BAAALAAFFAIIAgAAAA==.',['夏涵']='夏涵:BAABLAAFFH8GAAIFAAYI+QCBTAA6AAAFAAYI+QCBTAA6AAAAAA==.',['夏蘭']='夏蘭行德流:BAAALAAECgYICgABLAAFFAgIBgAJAJAcAA==.',['大傻']='大傻笔:BAABLAAFFH8QAAIKAAYI+iEuCQCzAQAKAAYI+iEuCQCzAQAAAA==.',['大哥']='大哥灬别喷我:BAAALAAECgYIBgAAAA==.大哥灬别开炮:BAAALAAECgYICQAAAA==.',['大宝']='大宝贝可爱萍:BAAALAADCggICwAAAA==.',['大怪']='大怪兽:BAAALAAECgQIBAAAAA==.',['大蜀']='大蜀山老司机:BAAALAAFFAgIAgAAAA==.',['大锤']='大锤:BAAALAAFFAIIBAAAAA==.',['天堂']='天堂安魂曲丨:BAAALAAECgMIAwAAAA==.',['天微']='天微蓝:BAAALAAFFAIIBAAAAA==.',['天生']='天生的双采德:BAAALAAECgMIAwAAAA==.',['天秤']='天秤座的偶:BAAALAAFFAIIAgAAAA==.天秤座的德:BAAALAAFFAIIAgAAAA==.天秤座的猎:BAAALAAFFAIIAgAAAA==.',['天空']='天空之痕:BAAALAAECgQIBAAAAA==.',['奶茶']='奶茶五分糖:BAAALAAECgYIBgAAAA==.',['好想']='好想再问一遍:BAAALAAECgUIBQAAAA==.',['嫣然']='嫣然笑:BAAALAAFFAIIAgAAAA==.',['子夕']='子夕:BAAALAAECgUIBwAAAA==.',['孤独']='孤独巡礼:BAAALAAFFAIIAgAAAA==.',['孤狼']='孤狼影逝:BAAALAAECggICAAAAA==.',['孵蛋']='孵蛋蒙少:BAABLAAFFH8TAAMPAAUIWxGqCADaAAAPAAUI9g6qCADaAAAOAAQI6hB/NwDJAAAAAA==.',['完完']='完完:BAABLAAFFH8GAAICAAYI1gCgqwAaAAACAAYI1gCgqwAaAAAAAA==.',['寂寞']='寂寞的小萨:BAAALAAECgUIBQAAAA==.',['对韭']='对韭当割:BAAALAAECgUIBQAAAA==.',['小丶']='小丶晶:BAAALAADCgcIBwAAAA==.',['小倉']='小倉由菜:BAAALAAECgMIAwAAAA==.',['小勋']='小勋勛:BAAALAAFFAQIBAABLAAFFAgIOgARAPghAA==.',['小小']='小小迪奥:BAAALAAFFAEIAQAAAA==.',['小幻']='小幻彩:BAAALAAECggICAAAAA==.',['小浣']='小浣熊滴芭比:BAABLAAFFH8RAAIIAAMI7BO5LAC9AAAIAAMI7BO5LAC9AAAAAA==.',['小狮']='小狮子滚绣球:BAAALAAECgYIEgAAAA==.',['小蜗']='小蜗牛快跑:BAAALAAECgQIBAAAAA==.',['小霞']='小霞:BAAALAAFFAIIBAAAAA==.',['尾行']='尾行:BAAALAADCgIIAgAAAA==.',['屠丶']='屠丶:BAAALAAECgYIBgAAAA==.',['山遥']='山遥水远:BAABLAAFFH8IAAIUAAIIVg/mGwAzAAAUAAIIVg/mGwAzAAAAAA==.',['巴根']='巴根:BAACLAAFFH8JAAIEAAMIog2eSQCMAAAEAAMIog2eSQCMAAAsAAQKfyIAAgQABwhuFwZ+AIQBAAQABwhuFwZ+AIQBAAAA.',['市场']='市场调查:BAAALAADCgEIAQAAAA==.',['布洛']='布洛克斯悉加:BAAALAADCgYIBgAAAA==.布洛琉斯:BAAALAADCggICAAAAA==.',['布脱']='布脱脱:BAAALAAFFAIIAgAAAA==.',['帅的']='帅的很明显:BAAALAAECgYIDAAAAA==.',['希伊']='希伊凹削:BAAALAAECgYIDAAAAA==.',['帝国']='帝国之手:BAAALAADCgYIBgAAAA==.',['帥鍀']='帥鍀不朙显:BAAALAAECgYIEQAAAA==.',['带刺']='带刺毒玫瑰:BAAALAAFFAIIAgAAAA==.',['平生']='平生欢:BAAALAAECgYIBgAAAA==.',['开盖']='开盖有蒋:BAAALAAECgUICQAAAA==.',['开脑']='开脑壳就一刀:BAAALAADCgEIAQAAAA==.',['弑血']='弑血残痕:BAAALAAFFAIIBAABLAAFFAIICAAEAMofAA==.',['张师']='张师傅:BAAALAAFFAIIAgAAAA==.',['强的']='强的阔怕:BAAALAAFFAMIAwAAAA==.',['强行']='强行酋长:BAAALAAECgIIAgAAAA==.',['彧竹']='彧竹:BAAALAAECgQIBAAAAA==.',['得之']='得之我幸:BAAALAAFFAIIBAAAAA==.',['微笑']='微笑:BAAALAADCgMIAwAAAA==.',['德云']='德云社:BAAALAADCgEIAQAAAA==.',['德里']='德里个德:BAABLAAFFH8fAAMIAAUIChcbGQBqAQAIAAUIChcbGQBqAQAJAAEIugFVMAAxAAAAAA==.',['心中']='心中的恶魔:BAAALAAFFAIIAgAAAA==.',['心情']='心情烦躁:BAAALAAECgYIBgAAAA==.心情煩燥:BAAALAAECgcIBwAAAA==.',['忄寶']='忄寶寶出沒:BAAALAAECgYIBgAAAA==.',['必中']='必中大奖:BAAALAADCgEIAQAAAA==.',['忆兮']='忆兮:BAAALAADCgQIBAAAAA==.',['忧郁']='忧郁的小德:BAAALAAECgMIAwAAAA==.',['怎么']='怎么这么好看:BAAALAAECgYIDAAAAA==.',['怒暴']='怒暴:BAAALAADCgEIAQAAAA==.',['思路']='思路的小萨:BAAALAADCggIAgAAAA==.',['恰似']='恰似你的温柔:BAAALAAECgQIBwAAAA==.',['恶怨']='恶怨:BAAALAAECgcICgAAAA==.',['悬崖']='悬崖上的鱼:BAAALAAECggIDgAAAA==.',['情人']='情人游天地:BAAALAAECgYIBgAAAA==.',['情深']='情深终化蝶:BAACLAAFFH8KAAIYAAIIwwrbCQBkAAAYAAIIwwrbCQBkAAAsAAQKfxoAAhgABwgDCyEiAP0AABgABwgDCyEiAP0AAAAA.',['慕容']='慕容娜美:BAAALAAFFAIIAgAAAA==.',['我和']='我和你拼了:BAAALAAFFAIIAgAAAA==.',['我是']='我是被逼的:BAAALAAECgYIBgAAAA==.',['我纯']='我纯故我在:BAABLAAFFH8KAAIZAAIIpyHCCQDJAAAZAAIIpyHCCQDJAAAAAA==.',['我胖']='我胖古我壮:BAABLAAFFH8LAAIUAAMILAtoDwCdAAAUAAMILAtoDwCdAAAAAA==.',['战无']='战无为:BAABLAAFFH8GAAIHAAYIzQHpZwARAAAHAAYIzQHpZwARAAAAAA==.',['戰士']='戰士:BAAALAAFFAIIBAAAAA==.',['戳你']='戳你大白兔:BAAALAADCgYICwAAAA==.',['戳圈']='戳圈先生:BAAALAAECgYIBgAAAA==.',['戴面']='戴面罩看姑娘:BAACLAAFFH8KAAMPAAIINhG3EQBsAAAPAAIINhG3EQBsAAAOAAEIRgadZgBDAAAsAAQKfxoAAw4ABghREMy9AFwBAA4ABghREMy9AFwBAA8ABgihBnUgAJsAAAAA.',['手提']='手提西瓜刀:BAAALAAECgIIAgAAAA==.',['打野']='打野小书生:BAAALAAFFAIIAwAAAA==.',['技高']='技高一筹:BAABLAAFFH8FAAICAAIIuQ/TcACQAAACAAIIuQ/TcACQAAAAAA==.技高二筹:BAAALAAFFAIIBAAAAA==.',['抓妹']='抓妹子做宝宝:BAAALAAFFAIIBAAAAA==.',['拾取']='拾取绑定:BAAALAAECgYIDAAAAA==.',['捌壹']='捌壹伍:BAAALAAECgQIBAAAAA==.',['捺美']='捺美丽的回忆:BAAALAAECgIIAgAAAA==.',['搞囧']='搞囧搞蒙:BAAALAAECgQIBAAAAA==.',['摇摆']='摇摆的小牛丶:BAAALAAECggICAAAAA==.',['摩西']='摩西:BAAALAAECgQIBAAAAA==.',['擂擂']='擂擂:BAAALAAECgYICQAAAA==.',['放縱']='放縱的遊蕩:BAAALAADCgEIAQAAAA==.',['救祓']='救祓少女:BAABLAAFFH8KAAIOAAYInxivHgCMAQAOAAYInxivHgCMAQABLAAFFAgIEgAOAPUgAA==.',['文轩']='文轩苒義:BAAALAAECggICAAAAA==.',['斩骨']='斩骨:BAABLAAFFH8IAAIHAAMIgQ1FHQDfAAAHAAMIgQ1FHQDfAAAAAA==.',['斩龙']='斩龙:BAAALAAFFAIIAgAAAA==.',['旅艾']='旅艾华侨:BAACLAAFFH8IAAINAAII/A6ZSgCXAAANAAII/A6ZSgCXAAAsAAQKfxcAAw0ABgg+F7FgAEYBAA0ABgg+F7FgAEYBABQAAQhvA2BKABoAAAAA.',['旋转']='旋转无敌跳跃:BAAALAAECgEIAQAAAA==.',['无恶']='无恶不作:BAAALAADCgYIBgAAAA==.',['无敌']='无敌最凶狠:BAABLAAFFH8NAAMFAAgImxy8BACQAgAFAAgImxy8BACQAgAEAAEIsBqvbgBOAAAAAA==.',['星丘']='星丘:BAAALAAFFAIIAgAAAA==.',['星星']='星星堆满天:BAAALAAECgYIDAAAAA==.',['是丸']='是丸子阿丶:BAAALAAECgYIBgAAAA==.',['晕晕']='晕晕迷糊:BAAALAAFFAgIBAAAAA==.',['晨晨']='晨晨清颖:BAAALAAECgUIBQAAAA==.',['普瑞']='普瑞斯托丶:BAAALAAECgYIBgAAAA==.',['暗影']='暗影大领主:BAACLAAFFH8KAAICAAgIZR37BwCCAgACAAgIZR37BwCCAgAsAAQKfxQAAgIABgiEEwpOAFwBAAIABgiEEwpOAFwBAAAA.',['暗语']='暗语:BAAALAAECgYIBgAAAA==.',['暮雪']='暮雪:BAAALAADCgYIBgAAAA==.',['月夏']='月夏霖雨:BAAALAADCgEIAQAAAA==.',['月舞']='月舞長空:BAAALAADCgIIAgAAAA==.',['有个']='有个萨满:BAAALAADCgIIAgAAAA==.',['朝云']='朝云暮雨:BAAALAAECgYIDAAAAA==.',['朝飒']='朝飒乌瑞恩:BAAALAAECgcIBwAAAA==.',['木丂']='木丂:BAABLAAECn8dAAMRAAYIaBO2RQA1AQARAAYIaBO2RQA1AQADAAMIjQldKQCKAAAAAA==.',['未曾']='未曾离去:BAABLAAFFH8GAAINAAYIqw7nIQBjAQANAAYIqw7nIQBjAQAAAA==.',['朱元']='朱元璋:BAABLAAFFH8NAAMKAAQIUQhXGACXAAAKAAQI2QVXGACXAAAaAAIItQu6BQCGAAAAAA==.',['朱星']='朱星寒:BAAALAAECgYIBgAAAA==.',['杀马']='杀马特之泪:BAAALAAECgYIBgAAAA==.',['杜泽']='杜泽尔:BAACLAAFFH8MAAIbAAQI9Qp4EwC5AAAbAAQI9Qp4EwC5AAAsAAQKfxoAAhsABgiDHTIiAAYCABsABgiDHTIiAAYCAAAA.',['来去']='来去匆匆芳:BAAALAAECgIIAgAAAA==.',['来碗']='来碗沙冰:BAABLAAFFH8GAAIXAAIIdAfjIgCAAAAXAAIIdAfjIgCAAAAAAA==.',['杨林']='杨林欧:BAABLAAECn8VAAMBAAgI0RNofQDjAQABAAgI0RNofQDjAQAGAAMIkQ4FmQCLAAAAAA==.',['松鼠']='松鼠的松果:BAAALAAECgYIDAAAAA==.',['林深']='林深时現狐:BAAALAAECggICAAAAA==.',['枫之']='枫之语:BAACLAAFFH8NAAMGAAMIgSHIDwDxAAAGAAMIoRzIDwDxAAABAAMIlRxbNQC5AAAsAAQKfyQAAwEABwh0Ia82AIICAAEABwiDH682AIICAAYABgjoH0gtABQCAAAA.',['枫钥']='枫钥无边:BAAALAAFFAIIAgAAAA==.',['柒崽']='柒崽:BAABLAAFFH8IAAIBAAMI3hvGIAADAQABAAMI3hvGIAADAQAAAA==.柒崽丶:BAAALAAFFAIIBAAAAA==.',['柳西']='柳西:BAAALAAECgUIBQAAAA==.',['梦幻']='梦幻浪漫:BAAALAADCgIIAgAAAA==.',['梦魇']='梦魇幻魔:BAABLAAFFH8GAAIVAAIIPiBsCQC4AAAVAAIIPiBsCQC4AAAAAA==.',['棋盘']='棋盘山老司机:BAABLAAFFH8NAAIBAAQISwsgZgCoAAABAAQISwsgZgCoAAAAAA==.',['止戰']='止戰之慯:BAABLAAFFH8JAAMGAAIIUBVYJAB/AAABAAIIjBHaWgCPAAAGAAII7xBYJAB/AAAAAA==.',['死亡']='死亡之痕:BAAALAAECgIIBAAAAA==.',['残年']='残年:BAAALAAECgUIBQAAAA==.',['残酷']='残酷天使纲领:BAABLAAECn8WAAIBAAYIaBL8oQAZAQABAAYIaBL8oQAZAQAAAA==.',['毁天']='毁天灭地:BAABLAAFFH8FAAIHAAUI3AVPEAB/AQAHAAUI3AVPEAB/AQAAAA==.',['毁灭']='毁灭之痕:BAAALAAECgYICQAAAA==.毁灭天使:BAAALAAECgMIAwAAAA==.',['比丝']='比丝姬:BAAALAAECgYIBgAAAA==.',['沉浮']='沉浮丶:BAAALAAECgMIAwAAAA==.',['没错']='没错:BAACLAAFFH8HAAIIAAMIkA6rNQCWAAAIAAMIkA6rNQCWAAAsAAQKfxgAAggABgjNCxlOAOEAAAgABgjNCxlOAOEAAAAA.',['河豚']='河豚辣酱:BAABLAAFFH8GAAICAAII2x9wRwCpAAACAAII2x9wRwCpAAAAAA==.',['法十']='法十三:BAAALAAECgYIBgAAAA==.',['法号']='法号仪琳:BAAALAAECggICAAAAA==.',['泰兰']='泰兰徳:BAAALAAFFAIIAgAAAA==.',['泰雷']='泰雷莎:BAAALAADCgQIBAAAAA==.',['洙澜']='洙澜:BAAALAAECgYIDQAAAA==.',['洛丹']='洛丹伦带孝子:BAAALAAECgYIDAAAAA==.',['洛阿']='洛阿:BAAALAADCgIIAgAAAA==.',['流离']='流离:BAAALAADCgMIAwAAAA==.',['流花']='流花思一郎:BAAALAAECggICAAAAA==.',['浅唱']='浅唱小艾:BAAALAAECgIIAgAAAA==.',['浩哥']='浩哥在这:BAAALAADCggICAAAAA==.',['浪迹']='浪迹:BAABLAAFFH8OAAIBAAMI+wxBegBtAAABAAMI+wxBegBtAAAAAA==.',['浮光']='浮光:BAAALAADCgEIAQAAAA==.',['海盗']='海盗伯爵:BAABLAAFFH8FAAIWAAIIFwS4HgApAAAWAAIIFwS4HgApAAAAAA==.海盗侯爵:BAAALAAECgYIBgAAAA==.海盗小男爵:BAAALAAECgcIDQABLAAFFAIIBQAWABcEAA==.',['海誓']='海誓丶山萌:BAABLAAFFH8GAAIcAAQIRQ58CADQAAAcAAQIRQ58CADQAAAAAA==.',['消逝']='消逝的光茫:BAAALAAECgYIEQAAAA==.',['淘气']='淘气依旧:BAABLAAFFH8NAAIRAAIIOQ0HSwCJAAARAAIIOQ0HSwCJAAAAAA==.',['深不']='深不可测:BAAALAAECgcIDQAAAA==.',['混子']='混子中的疯子:BAAALAAECgIIAgAAAA==.',['滴溜']='滴溜圆:BAAALAAFFAIIBAAAAA==.',['漫步']='漫步经心:BAACLAAFFH8RAAIQAAUI8AgvOgD+AAAQAAUI8AgvOgD+AAAsAAQKfygAAxUACAicFWAsAM8BABUACAhYEWAsAM8BABAABwiqFSonAIQBAAAA.',['瀛將']='瀛將:BAAALAAECgYIBgAAAA==.',['火鸢']='火鸢:BAAALAADCggIDQAAAA==.',['灬格']='灬格格笑笑灬:BAAALAADCgQIBAAAAA==.灬格格艾艾灬:BAAALAADCgYIBgAAAA==.',['灬游']='灬游走边缘灬:BAACLAAFFH8sAAILAAUIiiCnBwC8AQALAAUIiiCnBwC8AQAsAAQKfy8AAgsACAgDICwKAMICAAsACAgDICwKAMICAAAA.',['灬灬']='灬灬清風:BAABLAAFFH8IAAIXAAIIABQMGgCXAAAXAAIIABQMGgCXAAAAAA==.灬灬熊猫:BAAALAAECggICAAAAA==.灬灬面包:BAABLAAFFH8GAAICAAIIahsfQQCxAAACAAIIahsfQQCxAAAAAA==.',['点头']='点头:BAAALAAFFAIIBAAAAA==.',['烈咬']='烈咬陆鲨丶:BAAALAADCgYICgAAAA==.',['烈酒']='烈酒禅心:BAAALAAFFAIIAgAAAA==.',['烟羽']='烟羽:BAACLAAFFH8IAAIGAAgI5ACdHQARAAAGAAgI5ACdHQARAAAsAAQKfxcAAgYACAi7CGYaAMcAAAYACAi7CGYaAMcAAAAA.',['热乎']='热乎的炊饼:BAAALAAECgQIBAAAAA==.',['焱山']='焱山:BAAALAAECgQIBAAAAA==.',['照脸']='照脸上砍:BAAALAADCgcIBwAAAA==.',['熊猫']='熊猫小团子:BAABLAAECn8UAAMVAAgIJRhIQABwAQAQAAgIRhTSjQBxAQAVAAYI9BRIQABwAQAAAA==.',['爆浆']='爆浆牛肉:BAAALAAECgYIBgAAAA==.',['爆裂']='爆裂火焰:BAAALAAECgMIBQAAAA==.',['爱与']='爱与救赎:BAABLAAFFH8GAAISAAIIFwbsRwBcAAASAAIIFwbsRwBcAAAAAA==.',['爱丶']='爱丶谁誰:BAAALAAECgYIDgAAAA==.',['爱琴']='爱琴海中渔:BAABLAAFFH8IAAIQAAIIIRoyTgCSAAAQAAIIIRoyTgCSAAAAAA==.',['牛三']='牛三亨:BAAALAAFFAIIAwAAAA==.',['牛二']='牛二亨:BAABLAAFFH8MAAIHAAUIMQenLgDsAAAHAAUIMQenLgDsAAAAAA==.',['牛盲']='牛盲:BAAALAAECgYIBwAAAA==.',['牲口']='牲口:BAABLAAFFH8GAAICAAYIgQgXQQA8AQACAAYIgQgXQQA8AQAAAA==.',['特蕾']='特蕾莎二丫:BAAALAADCgYICQAAAA==.',['狂野']='狂野女猎手:BAAALAADCggIFAAAAA==.',['狄阿']='狄阿娜:BAAALAAFFAIIAgAAAA==.',['狐不']='狐不皈:BAAALAAECgYIBwAAAA==.',['狐九']='狐九:BAABLAAFFH8IAAIEAAIIyh//OwC2AAAEAAIIyh//OwC2AAAAAA==.',['狐作']='狐作妃为:BAAALAAFFAIIBAAAAA==.',['狐狸']='狐狸细雪:BAABLAAECn8UAAMBAAYIHRQ45QBQAQABAAYIZRM45QBQAQAGAAIIDApDsgBLAAAAAA==.',['狩猎']='狩猎夜行:BAAALAAECgMIAwAAAA==.',['猎魂']='猎魂之翼:BAAALAAECgYICwAAAA==.',['玛德']='玛德:BAAALAAECgYIEQAAAA==.',['玛格']='玛格汉猎手:BAABLAAFFH8KAAIBAAUIYhaxRwAyAQABAAUIYhaxRwAyAQAAAA==.',['班花']='班花:BAABLAAFFH8GAAIEAAIIGRkjOACQAAAEAAIIGRkjOACQAAAAAA==.',['瑞斯']='瑞斯拜:BAAALAAECgYICQAAAA==.',['生绝']='生绝俱灭:BAAALAAECgYIBgAAAA==.',['电诈']='电诈系毕业生:BAAALAAECgEIAQAAAA==.',['男再']='男再有:BAABLAAFFH8ZAAIRAAgI8iG/BAC6AgARAAgI8iG/BAC6AgAAAA==.',['疑心']='疑心秀才:BAAALAAECgYIBgAAAA==.',['白海']='白海魔:BAACLAAFFH8nAAIBAAYItx7THADEAQABAAYItx7THADEAQAsAAQKfyMAAwEACAiJIIk2AIICAAEACAiJIIk2AIICAAYABQjCE9diADUBAAAA.',['白灵']='白灵淼:BAAALAAECgYIBwAAAA==.白灵緈:BAAALAAECgUIBgAAAA==.',['白狐']='白狐妖姬:BAABLAAFFH8YAAINAAUI7B3EIQBjAQANAAUI7B3EIQBjAQAAAA==.',['白马']='白马啸西风:BAAALAAECgYICAAAAA==.',['百变']='百变小郎君:BAAALAADCgQIBAAAAA==.',['盗魂']='盗魂:BAAALAADCgQIBAAAAA==.',['相当']='相当凶残:BAABLAAFFH8KAAIHAAIIKxTbMgCcAAAHAAIIKxTbMgCcAAAAAA==.',['相思']='相思花海:BAABLAAECn8ZAAMCAAgIERImRAB4AQACAAgIcA4mRAB4AQAZAAYIIhSRKgBtAQAAAA==.',['看上']='看上去啊很刁:BAAALAAFFAcIAwAAAA==.',['看我']='看我眼神行动:BAAALAADCgMIAwAAAA==.',['瞄准']='瞄准射击:BAAALAAECgYIBgAAAA==.',['矿物']='矿物质水:BAABLAAFFH8aAAICAAUIRh2bMwByAQACAAUIRh2bMwByAQAAAA==.',['碧游']='碧游特佛:BAAALAAECgYIBgAAAA==.',['神圣']='神圣十字军:BAAALAAFFAIIAgAAAA==.',['窝使']='窝使歪果碰友:BAAALAAECgIIAgAAAA==.',['简单']='简单绿茶:BAAALAAFFAIIAgAAAA==.',['簘释']='簘释:BAAALAAFFAQIBAAAAA==.',['簫释']='簫释:BAAALAADCggICgAAAA==.',['粉红']='粉红肚兜儿:BAABLAAFFH8GAAICAAIIihqFSACnAAACAAIIihqFSACnAAAAAA==.',['精神']='精神的铁虎:BAAALAAECgYIEAAAAA==.',['糯桃']='糯桃:BAAALAAECggIEAAAAA==.',['紫荆']='紫荆藤:BAAALAAECgMIBAAAAA==.紫荆雨:BAAALAAECgMIAwAAAA==.',['綾波']='綾波丽:BAAALAAFFAEIAQAAAA==.',['纠结']='纠结的小德:BAAALAAFFAQIBAAAAA==.',['红哥']='红哥:BAAALAAECgEIAQAAAA==.',['红星']='红星二锅头:BAAALAAECgYIBgAAAA==.',['红烧']='红烧可乐:BAAALAADCgYIBgAAAA==.',['纯洁']='纯洁的大叔:BAACLAAFFH8FAAIJAAII+Q91IQCIAAAJAAII+Q91IQCIAAAsAAQKfxQAAgkABwgbHSESAO8BAAkABwgbHSESAO8BAAAA.',['细雪']='细雪:BAAALAAECgYIBgAAAA==.',['给我']='给我点希望:BAAALAADCgUIBgAAAA==.',['绝世']='绝世关云长:BAABLAAFFH8IAAINAAIIbh1eJwC7AAANAAIIbh1eJwC7AAAAAA==.',['罪恶']='罪恶苍穹:BAAALAAECgEIAQAAAA==.',['美麗']='美麗要打折:BAAALAAECggICAAAAA==.',['老牛']='老牛真怒了:BAAALAADCgcICwAAAA==.老牛鼻了:BAAALAAECgYIBwAAAA==.',['聆听']='聆听我的召唤:BAAALAADCggIDwAAAA==.聆听我的声音:BAAALAADCgcICQAAAA==.',['联盟']='联盟被杀:BAAALAADCggICQAAAA==.',['肝胆']='肝胆两昆仑丶:BAAALAAECgIIAgAAAA==.',['胖胖']='胖胖:BAABLAAFFH8IAAQdAAYIEQFnBwA/AAAdAAUIHwFnBwA/AAAEAAIIwQAvgwASAAAFAAEIygBZVwAQAAAAAA==.',['艾世']='艾世界:BAAALAADCgYIBwAAAA==.',['艾吉']='艾吉奥撒卡:BAAALAAECgcIEQAAAA==.',['芸醉']='芸醉月薇眠:BAAALAAFFAMIAgAAAA==.',['若雍']='若雍其口:BAAALAAECgIIAgAAAA==.',['苦根']='苦根:BAABLAAFFH8SAAIeAAMIWhUKBQCfAAAeAAMIWhUKBQCfAAAAAA==.',['英雄']='英雄脚臭:BAAALAADCgQIBAAAAA==.',['苹果']='苹果乖不哭:BAABLAAECn8ZAAISAAcIehQELABdAQASAAcIehQELABdAQAAAA==.',['莉亚']='莉亚德琳:BAAALAAECgYICQAAAA==.',['萌萌']='萌萌大咕咕:BAAALAADCgEIAQAAAA==.萌萌的晓彦祖:BAAALAADCgEIAQAAAA==.',['萨雷']='萨雷飒飒:BAAALAAECgYIBgAAAA==.',['落叶']='落叶瑰根:BAAALAAECgIIAgAAAA==.',['蒙牙']='蒙牙:BAAALAAECgYIDwAAAA==.',['蓝色']='蓝色毒药:BAAALAAFFAIIAgAAAA==.',['蓝若']='蓝若林:BAAALAAECgUIBwAAAA==.',['蓝达']='蓝达斯:BAAALAAECgMIAwAAAA==.',['蛮力']='蛮力:BAAALAADCgYICwAAAA==.',['蛮干']='蛮干:BAAALAADCgYIBgAAAA==.',['蛮弟']='蛮弟:BAAALAADCgUIBQAAAA==.',['蛮汉']='蛮汉:BAAALAADCgMIAwAAAA==.',['蛮魔']='蛮魔:BAAALAADCgcICQAAAA==.',['蜘蛛']='蜘蛛欢乐多:BAAALAADCgEIAQAAAA==.',['血丶']='血丶刺:BAABLAAECn8VAAMfAAgILAMxGQCQAAAbAAcIHgPIUQDiAAAfAAcINwIxGQCQAAAAAA==.',['血缘']='血缘诅咒:BAAALAADCgIIAgAAAA==.',['訫囌']='訫囌鍀懿铍:BAAALAAECgUIBQAAAA==.',['誰懂']='誰懂爺的芯:BAACLAAFFH8GAAIBAAIIuBqckABGAAABAAIIuBqckABGAAAsAAQKfxYAAgEABggLHlBhAIIBAAEABggLHlBhAIIBAAAA.',['请叫']='请叫我大胖:BAAALAADCgcICwAAAA==.',['谈胸']='谈胸论弟:BAAALAADCgIIAgAAAA==.',['貳拾']='貳拾壹克:BAAALAAECgYIBgAAAA==.',['贫瘠']='贫瘠之地的风:BAAALAAECgcIBwAAAA==.',['贾昆']='贾昆灬赫加尔:BAAALAAECgYIDgAAAA==.',['贾百']='贾百万:BAACLAAFFH8LAAMRAAMItBseKADsAAARAAMILBQeKADsAAADAAEInx1pJABVAAAsAAQKfxoABAMACAgtG/sXADgCAAMABwgiGvsXADgCABEABwiIEr14AJEBACAAAQiHCV4+AD4AAAAA.',['赛茜']='赛茜莉雅:BAAALAAECggICAAAAA==.',['赤炎']='赤炎猎鬼:BAAALAADCgYIBgAAAA==.',['赤西']='赤西仁丶:BAAALAADCgQIBAAAAA==.',['超速']='超速的小蜗牛:BAAALAAECgcIDgAAAA==.',['踢飞']='踢飞的易拉罐:BAAALAADCgEIAQAAAA==.',['轰鼓']='轰鼓:BAABLAAFFH8GAAIhAAMIjQNrHQBEAAAhAAMIjQNrHQBEAAAAAA==.',['辛巴']='辛巴德丶:BAAALAAECgEIAQAAAA==.',['达克']='达克莱伊丶:BAAALAADCgIIAgAAAA==.',['过期']='过期月饼:BAABLAAFFH8IAAIbAAIITRM+GwCSAAAbAAIITRM+GwCSAAAAAA==.过期牛扒:BAABLAAFFH8KAAILAAIIfQjxFwBgAAALAAIIfQjxFwBgAAAAAA==.',['迈克']='迈克尔灬唐僧:BAAALAAECgYIBgAAAA==.',['迪奥']='迪奥斯库里:BAAALAAFFAIIAgAAAA==.',['迷惑']='迷惑丶猫:BAAALAAECgYIBgAAAA==.迷惑描:BAAALAAFFAIIAgAAAA==.迷惑緢:BAAALAADCggICAAAAA==.',['迷糊']='迷糊喵:BAAALAAECgIIAgAAAA==.迷糊緢:BAAALAAECgMIAwAAAA==.',['遇见']='遇见时间:BAAALAAECgYIBgAAAA==.',['遥远']='遥远的苹果:BAAALAAECggIEAAAAA==.',['邪月']='邪月苍炎:BAACLAAFFH8JAAMRAAIItSNnMgCvAAARAAIItSNnMgCvAAADAAEInB+TIgBcAAAsAAQKfxYABBEABwiwI3MaABACABEABwiwI3MaABACACAAAwg3EpsjAMsAAAMAAQiBJHSKAFoAAAAA.',['醉月']='醉月湖畔:BAAALAAECgMIAwAAAA==.',['醉染']='醉染青山:BAAALAAECgEIAQAAAA==.',['醒时']='醒时春山:BAACLAAFFH8IAAICAAIIDBEXZACWAAACAAIIDBEXZACWAAAsAAQKfxQAAgIABwjqFOdnACEBAAIABwjqFOdnACEBAAAA.',['释永']='释永信打响指:BAAALAAECgYIBgAAAA==.',['金钢']='金钢牛:BAAALAAFFAIIAgAAAA==.',['钢子']='钢子:BAAALAAECgMIAwAAAA==.',['钢铁']='钢铁柱:BAAALAAFFAIIAgAAAA==.',['钢镚']='钢镚:BAABLAAFFH8ZAAIBAAYICh1oJgCeAQABAAYICh1oJgCeAQAAAA==.',['长天']='长天:BAAALAAECgUIAQAAAA==.',['阎罗']='阎罗小花:BAACLAAFFH8MAAINAAIIPSAUUABbAAANAAIIPSAUUABbAAAsAAQKfxwAAg0ABwgRIko2AL4BAA0ABwgRIko2AL4BAAAA.',['阿克']='阿克汉斯:BAAALAADCggICgAAAA==.',['阿尔']='阿尔萨司:BAAALAAFFAIIAgAAAA==.',['阿尼']='阿尼克扎尔:BAAALAAECgYIBgAAAA==.',['阿莉']='阿莉雅:BAAALAAECgYIBgAAAA==.',['陆壹']='陆壹柒:BAAALAAECgUIBgAAAA==.陆壹柒丶:BAAALAAECgQIBAAAAA==.',['随丶']='随丶缘:BAABLAAFFH8aAAIPAAUIdhIvCADpAAAPAAUIdhIvCADpAAAAAA==.',['随机']='随机奶:BAAALAAFFAEIAQAAAA==.',['随缘']='随缘丶:BAABLAAFFH8nAAMQAAYI6B37GAC8AQAQAAYIWxr7GAC8AQAVAAIIAyEHEQBbAAAAAA==.',['雄赳']='雄赳赳气昂昂:BAAALAAFFAIIBAABLAAFFAIIBgAEABkZAA==.',['雄起']='雄起吧:BAAALAAFFAIIAgAAAA==.',['雨落']='雨落天下:BAAALAAECgQIBAAAAA==.雨落天天:BAAALAAECgYIAwAAAA==.雨落天晴:BAAALAAECgYIDAAAAA==.雨落晴天:BAAALAAECgYIBgAAAA==.雨落牛奔:BAAALAAECgEIAQAAAA==.',['雪之']='雪之小样:BAACLAAFFH8dAAMNAAUIEyIyHACBAQANAAUI7yAyHACBAQAUAAQIyxkcDQC9AAAsAAQKfx0AAw0ACAitI4ErAMMCAA0ABwjTJIErAMMCABQAAQikG6c+AE8AAAAA.',['雪满']='雪满弓刀:BAAALAAECgMIAwAAAA==.',['露茜']='露茜亚:BAAALAAECgUIBQAAAA==.',['霸气']='霸气毁三观:BAAALAADCgQIBAAAAA==.',['霹雳']='霹雳小娇娃:BAAALAAFFAMIAwABLAAFFAgIDgAQAEUjAA==.霹雳闪雷真君:BAAALAAECgUIBQAAAA==.',['青溪']='青溪浅水:BAAALAADCgMIAwAAAA==.',['鞍山']='鞍山老司机:BAABLAAFFH8MAAIOAAYIzRNGIgB6AQAOAAYIzRNGIgB6AQAAAA==.',['顽皮']='顽皮爱绅士:BAAALAAECgYIDAAAAA==.',['风再']='风再起时:BAAALAAECgYIBgAAAA==.',['风怒']='风怒:BAACLAAFFH8KAAIOAAQIRh6VMAAbAQAOAAQIRh6VMAAbAQAsAAQKfxcAAg4ABwgRI0UzAI8CAA4ABwgRI0UzAI8CAAEsAAUUBggGAAEAdyEA.',['风铃']='风铃:BAAALAAECgYICwAAAA==.',['香烟']='香烟先生丶:BAAALAAECgYIBgAAAA==.香烟先生丿:BAAALAAECgYIDAAAAA==.',['馨婷']='馨婷疫誓:BAAALAAECggIEAAAAA==.',['马铁']='马铁锤:BAAALAAECgYICAAAAA==.',['驾驭']='驾驭魔鬼:BAAALAADCgIIAgAAAA==.',['骐骥']='骐骥:BAAALAAFFAIIAgAAAA==.',['骑士']='骑士的皮肤:BAAALAADCgEIAQAAAA==.',['骑得']='骑得隆冬强:BAAALAAECgEIAQAAAA==.',['骗老']='骗老头医保:BAAALAAFFAIIAgAAAA==.',['高端']='高端黑:BAAALAAECgMIAwAAAA==.',['鬼舞']='鬼舞天泉:BAAALAAFFAIIBAAAAA==.',['魂域']='魂域暴风:BAAALAAECgEIAQAAAA==.',['鸡不']='鸡不可濕:BAAALAAECgYIBgAAAA==.',['鸡毛']='鸡毛蒜皮:BAAALAAFFAIIAgAAAA==.',['鹤竹']='鹤竹:BAAALAAECggIDwAAAA==.',['麟听']='麟听:BAAALAAECgUIBQAAAA==.',['黑不']='黑不流球就行:BAABLAAECn8YAAIBAAgIdw3jcABkAQABAAgIdw3jcABkAQAAAA==.',['黑夜']='黑夜灬紫瞬:BAAALAADCgIIAgAAAA==.',['黑尔']='黑尔海姆:BAABLAAFFH8MAAIOAAMIrAsgIwDXAAAOAAMIrAsgIwDXAAAAAA==.',['黑影']='黑影的追随:BAAALAAECgEIAQAAAA==.',['黑暗']='黑暗小圈圈:BAABLAAECn8YAAICAAYIZxY1WgA/AQACAAYIZxY1WgA/AQAAAA==.',['黑铁']='黑铁猛人:BAAALAAECgEIAQAAAA==.',['黛箖']='黛箖:BAABLAAECn8WAAIIAAYIIRJPOQA9AQAIAAYIIRJPOQA9AQAAAA==.',['龙拳']='龙拳:BAAALAAECgIIAgAAAA==.',['龙行']='龙行有雨:BAAALAAECgMIAwAAAA==.',['龙里']='龙里格隆:BAABLAAFFH8LAAIiAAYIFBGvDgBUAQAiAAYIFBGvDgBUAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end