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
 local lookup = {'Mage-Arcane','Mage-Fire','Mage-Frost','Warlock-Destruction','DeathKnight-Frost','DemonHunter-Havoc','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Priest-Holy','Shaman-Restoration','Priest-Shadow','Priest-Discipline','Evoker-Augmentation','Evoker-Preservation','Hunter-Marksmanship','Warrior-Fury','Druid-Balance','Hunter-BeastMastery','Rogue-Assassination','Monk-Brewmaster','Monk-Mistweaver','DeathKnight-Unholy','Unknown-Unknown','Shaman-Elemental','DemonHunter-Vengeance','Druid-Restoration','DeathKnight-Blood','Warrior-Protection','Rogue-Subtlety','Druid-Guardian','Warlock-Affliction','Warrior-Arms','Monk-Windwalker','Shaman-Enhancement','Warlock-Demonology','Druid-Feral','Evoker-Devastation',}; local provider = {region='CN',realm='安东尼达斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aieliovo:BAABLAAFFH8gAAQBAAgIqyHPAgDNAgABAAgIqyHPAgDNAgACAAEINh9zCwBOAAADAAEI+hUiHwBGAAAAAA==.',Al='Aly:BAAALAAECgQIBAAAAA==.',Ar='Arrebol:BAAALAAFFAIIBAAAAA==.',Bi='Bigsword:BAAALAAECgMIBQAAAA==.',Bu='Burning:BAABLAAFFH8xAAIEAAYIXBryHwCeAQAEAAYIXBryHwCeAQAAAA==.',Co='Colorfu:BAAALAAFFAIIAgAAAA==.',Cy='Cynicism:BAAALAAECgYICQAAAA==.',Da='Daikii:BAABLAAFFH8JAAIFAAMIYQ8ZXgCTAAAFAAMIYQ8ZXgCTAAAAAA==.',Dd='Ddcc:BAAALAAECgIIAgAAAA==.Ddsweqw:BAABLAAFFH8GAAIGAAII5AxaSACTAAAGAAII5AxaSACTAAAAAA==.',Dh='Dhqaq:BAABLAAFFH8KAAIGAAYIcR59FQC6AQAGAAYIcR59FQC6AQAAAA==.',Do='Dollarsa:BAAALAAECgYICAAAAA==.Doudoub:BAABLAAECn8eAAQHAAgIdRZaNADCAQAHAAcIgxhaNADCAQAIAAYIcgqHKwDAAAAJAAcIRAPcMQC4AAAAAA==.',Ev='Evwn:BAABLAAFFH8fAAIHAAYIdCK/DwDIAQAHAAYIdCK/DwDIAQAAAA==.',Fe='Felithoth:BAAALAAECgYIDAABLAAFFAUICQADANgcAA==.',Fl='Flamboyant:BAAALAAECgIIAgAAAA==.',Hp='Hpccn:BAAALAAECgIIAgAAAA==.',Ih='Ihwimsm:BAABLAAFFH8WAAIKAAcI2Ry4CAA/AgAKAAcI2Ry4CAA/AgAAAA==.',Io='Io:BAAALAAFFAIIAgAAAA==.',Je='Jeredwhu:BAACLAAFFH8YAAIKAAYIMRf8FQCkAQAKAAYIMRf8FQCkAQAsAAQKfyMAAgoACAhxHx0ZAKQCAAoACAhxHx0ZAKQCAAAA.Jessicar:BAAALAAECgYIBgAAAA==.',Ju='Jungling:BAABLAAFFH8uAAILAAYIEhzBDQD+AQALAAYIEhzBDQD+AQAAAA==.',Jv='Jv:BAAALAADCgMIAwAAAA==.',Ka='Kayanomi:BAACLAAFFH8sAAMKAAYIgyUwBgBqAgAKAAYIgyUwBgBqAgAMAAIIuxkVJABaAAAsAAQKfzsABAoACAhvJVgEAFADAAoACAhvJVgEAFADAAwAAwhWG85/AKcAAA0AAwiHBYsaAFQAAAAA.',Li='Limerence:BAAALAADCgYIBgAAAA==.',Lo='Loveyour:BAACLAAFFH8IAAIDAAIIZxiVDgCVAAADAAIIZxiVDgCVAAAsAAQKfxYAAgMABgi2IuoMAO8BAAMABgi2IuoMAO8BAAAA.',Ma='Malcoonm:BAAALAAFFAIIAgAAAA==.Mazzystar:BAAALAAECgMIAwAAAA==.',Mg='Mgbz:BAAALAAECgcIEgAAAA==.',Mi='Mieheal:BAABLAAFFH8RAAIDAAUIAhYpBwA1AQADAAUIAhYpBwA1AQAAAA==.',Na='Nanako:BAABLAAFFH8GAAMOAAYI2SLrAwC/AQAOAAUIAiLrAwC/AQAPAAEIWQCxIgAgAAAAAA==.Nathielangu:BAAALAAECgcIDwAAAA==.',Ne='Nero:BAABLAAECn8XAAIFAAgIhxIShQDxAQAFAAgIhxIShQDxAQAAAA==.',Or='Ori:BAABLAAFFH8IAAMBAAIIBRlLOwClAAABAAIIBRlLOwClAAACAAEI3gqjDABJAAAAAA==.',Ou='Ouyxxb:BAAALAAFFAIIAgAAAA==.',Pe='Pengge:BAAALAADCgIIAgAAAA==.',Ro='Rodd:BAAALAAECgYIDAAAAA==.Rollinglover:BAABLAAFFH8xAAIBAAYIpR3aGQC2AQABAAYIpR3aGQC2AQAAAA==.',Ru='Ruese:BAAALAAECgcICAAAAA==.',Sa='Sakuraa:BAAALAAECggICAAAAA==.',Sh='Sheeny:BAAALAADCgYIBgAAAA==.',Ti='Tiktok:BAAALAAECgIIAgAAAA==.',Yf='Yfhu:BAACLAAFFH81AAIDAAYIZCUHAQAkAgADAAYIZCUHAQAkAgAsAAQKfxwAAgMACAg3JvsKAOoCAAMACAg3JvsKAOoCAAAA.',['Ðï']='Ðï:BAAALAADCgIIAgAAAA==.',['一头']='一头钢毛:BAABLAAFFH8PAAIQAAMI9QU8FABHAAAQAAMI9QU8FABHAAAAAA==.',['一笑']='一笑:BAAALAADCggICQAAAA==.',['一般']='一般通过战:BAABLAAFFH8IAAIRAAQI/xukKwALAQARAAQI/xukKwALAQAAAA==.',['一飞']='一飞火一:BAAALAAECgcIDQAAAA==.',['七四']='七四八弄:BAABLAAECn8bAAIJAAcI7hOgMACsAQAJAAcI7hOgMACsAQAAAA==.',['三千']='三千琉璃月:BAABLAAFFH8IAAIHAAMIFh0ZEwAgAQAHAAMIFh0ZEwAgAQAAAA==.',['上海']='上海小鸟德:BAABLAAFFH8MAAISAAYI8xBzEgBUAQASAAYI8xBzEgBUAQAAAA==.',['不醒']='不醒人氏:BAAALAAECgYICQAAAA==.',['丨无']='丨无敌炉石丨:BAAALAADCgQIBAAAAA==.',['丨陵']='丨陵车漂移丨:BAAALAAFFAIIAgAAAA==.',['中单']='中单法王:BAACLAAFFH8FAAIDAAMI2gqEDgB2AAADAAMI2gqEDgB2AAAsAAQKfx8AAgMACAhyHDwYAFkCAAMACAhyHDwYAFkCAAAA.',['丶小']='丶小冰块:BAACLAAFFH8WAAIFAAUIixhbKAD4AAAFAAUIixhbKAD4AAAsAAQKfx4AAgUACAheINUqAMcCAAUACAheINUqAMcCAAAA.',['丶猫']='丶猫爬架:BAACLAAFFH8NAAMIAAMItBTbDwCDAAAHAAIIrxBMQQCdAAAIAAMItBTbDwCDAAAsAAQKfxgAAgcABgjFHnpoABkCAAcABgjFHnpoABkCAAAA.',['举杯']='举杯敬岁月:BAABLAAFFH8IAAITAAYIChAyPABUAQATAAYIChAyPABUAQAAAA==.',['丿唐']='丿唐宋元明清:BAAALAAECgQIAwAAAA==.',['丿娃']='丿娃哈哈:BAAALAAFFAYIAgAAAA==.',['丿芝']='丿芝华士:BAABLAAECn8VAAIRAAYI3gZJvAAEAQARAAYI3gZJvAAEAQAAAA==.',['习武']='习武圣马可:BAAALAAECgYIBgAAAA==.',['乾坤']='乾坤纪元:BAAALAAECggICAAAAA==.',['于晦']='于晦暗中期许:BAAALAAECgQICgAAAA==.',['五乘']='五乘恩:BAAALAAECgUICgAAAA==.',['亚历']='亚历山德罗斯:BAAALAAECgEIAQAAAA==.',['人社']='人社知识通:BAAALAADCgIIAwAAAA==.',['今天']='今天要下雨:BAAALAAECgYIBwAAAA==.',['伊什']='伊什塔尔:BAAALAAECgYIEQAAAA==.',['伊佳']='伊佳颂:BAAALAAECgYIBgAAAA==.',['伊利']='伊利牧场灬:BAABLAAFFH8WAAIGAAgIriCSBQCHAgAGAAgIriCSBQCHAgAAAA==.',['伏特']='伏特加丶:BAABLAAFFH8PAAIUAAcIvR4dAwA5AgAUAAcIvR4dAwA5AgAAAA==.',['优秀']='优秀士兵:BAABLAAFFH8FAAIJAAMIIQTzIwCEAAAJAAMIIQTzIwCEAAABLAAFFAYIIgAPAMwSAA==.',['低保']='低保分割线:BAABLAAFFH8OAAMVAAQIcQBhHQBEAAAVAAQIcQBhHQBEAAAWAAIIrgBJHAAtAAAAAA==.',['你才']='你才是傲娇呢:BAAALAADCggICAAAAA==.',['倚扇']='倚扇:BAAALAAECgcICQAAAA==.',['停电']='停电了:BAAALAAECgYIBgAAAA==.',['健怡']='健怡丶牛奶:BAAALAAECgYIDAAAAA==.健怡丶雪碧:BAABLAAECn8YAAIHAAYIWAs4iwDqAAAHAAYIWAs4iwDqAAAAAA==.',['傭兵']='傭兵八幡海鈴:BAAALAAECgEIAQAAAA==.',['元旦']='元旦:BAABLAAFFH8gAAQMAAUIyRa2EwA5AQAMAAUIyRa2EwA5AQAKAAQIpAj7IAC5AAANAAEIVgwNCAA6AAAAAA==.',['光明']='光明内敛:BAAALAAECgMIAwAAAA==.',['八六']='八六上山啦:BAAALAAECgIIAwAAAA==.',['八级']='八级小狂风:BAABLAAFFH8cAAIFAAUIMSKyLACHAQAFAAUIMSKyLACHAQAAAA==.',['兰柯']='兰柯撒:BAACLAAFFH8GAAIFAAIIpAO9jQB6AAAFAAIIpAO9jQB6AAAsAAQKfyYAAgUABgjqFffOAIQBAAUABgjqFffOAIQBAAAA.',['冥道']='冥道人:BAABLAAFFH8LAAMXAAYInB99CgDBAAAFAAUI1B7zOQBVAQAXAAMIBR99CgDBAAAAAA==.',['冬冬']='冬冬三十六亿:BAABLAAFFH8JAAILAAUIkgWyOwC1AAALAAUIkgWyOwC1AAABLAAFFAUIEQADAAIWAA==.',['冯登']='冯登明:BAAALAAECgYICAAAAA==.',['冰棍']='冰棍侠:BAAALAAECgMIAwAAAA==.',['冰河']='冰河时代:BAAALAAECggIDQAAAA==.',['凄夜']='凄夜丶毒茶:BAAALAADCgEIAQAAAA==.',['凝霜']='凝霜冬至:BAAALAAECgUICgAAAA==.',['别搞']='别搞笑:BAABLAAECn8cAAILAAYIrRdwggB7AQALAAYIrRdwggB7AQAAAA==.',['刻骨']='刻骨记忆:BAAALAAECgEIAQAAAA==.',['剁你']='剁你和剁他:BAABLAAFFH8MAAIUAAMIjQA2IAAuAAAUAAMIjQA2IAAuAAAAAA==.',['功夫']='功夫之辉:BAAALAADCgYIBgAAAA==.',['加佐']='加佐:BAAALAADCggIDAAAAA==.',['加州']='加州招待所:BAAALAAECgYIBgAAAA==.',['北美']='北美懂王:BAAALAAECgEIAQAAAA==.',['午茶']='午茶五号:BAABLAAFFH8IAAIVAAYI7gncEQAuAQAVAAYI7gncEQAuAQAAAA==.',['卤煮']='卤煮:BAAALAADCgcIBwAAAA==.',['双鱼']='双鱼:BAAALAAECgYIBgAAAA==.',['变不']='变不够的文森:BAAALAAECgYIEQAAAA==.',['古月']='古月晨搏:BAAALAAECgQIBQAAAA==.',['向死']='向死而生:BAAALAAECgIIAgAAAA==.',['吴二']='吴二号:BAAALAADCgYIBgABLAAECgYIBgAYAAAAAA==.',['吾与']='吾与祂:BAAALAAECgYIDAABLAAFFAIIAgAYAAAAAA==.',['呀哈']='呀哈嘛嗒唻嘅:BAAALAAECgYIBgAAAA==.',['周吴']='周吴郑王先生:BAABLAAFFH8NAAMZAAYI6RLNGQBxAQAZAAYI6RLNGQBxAQALAAEIcQJsfgAqAAAAAA==.',['和泉']='和泉守兼定:BAACLAAFFH8zAAIGAAYIhSS5CwAOAgAGAAYIhSS5CwAOAgAsAAQKf0kAAwYACAjtJZYGAGUDAAYACAjtJZYGAGUDABoABQiMIYkNAHcBAAAA.',['咕噜']='咕噜爱吃虾:BAAALAAECgYIBgAAAA==.',['咕神']='咕神降临:BAAALAAFFAIIAgAAAA==.',['咪蜜']='咪蜜哒:BAAALAAECgYICQAAAA==.',['哇咔']='哇咔咔斯迈达:BAAALAADCgQIBAAAAA==.',['哈拉']='哈拉顿魔法使:BAAALAAECgEIAQAAAA==.',['哪吒']='哪吒:BAAALAAFFAIIAgAAAA==.',['商鞅']='商鞅国王:BAAALAAECgQIBQAAAA==.',['喵喵']='喵喵丶林:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血七天:BAAALAAECgYIDgAAAA==.',['四阿']='四阿哥:BAAALAAECgIIAgAAAA==.',['国宝']='国宝宸:BAAALAAECgQIBQAAAA==.',['图腾']='图腾老怪:BAAALAADCgUIBQAAAA==.',['圆圆']='圆圆宝宝:BAAALAAECgYIBgAAAA==.',['土豆']='土豆地蕾斌:BAABLAAFFH8TAAIFAAUIhSMpJQChAQAFAAUIhSMpJQChAQAAAA==.',['圣光']='圣光吉姆:BAAALAAECgYIBgAAAA==.圣光牛光圣:BAABLAAFFH8YAAIIAAQIzwj3DwCBAAAIAAQIzwj3DwCBAAAAAA==.',['圣锋']='圣锋:BAAALAAECgcIBwAAAA==.',['城南']='城南一神:BAAALAAECgMIAwAAAA==.',['墓地']='墓地指挥员:BAAALAAFFAIIAgAAAA==.',['复方']='复方颗粒:BAABLAAFFH8cAAILAAcIoiYWAQB+AgALAAcIoiYWAQB+AgABLAAFFAgIGQALAIkfAA==.',['夏小']='夏小曦:BAABLAAFFH8GAAIDAAIIXApBGQB0AAADAAIIXApBGQB0AAAAAA==.',['夜舞']='夜舞清沙:BAAALAAECgQIBAAAAA==.夜舞清风:BAAALAAECgUIBQAAAA==.',['大乃']='大乃辉:BAAALAADCgcIBwAAAA==.',['大明']='大明举重冠军:BAAALAAFFAIIAgAAAA==.',['大禅']='大禅三藏:BAACLAAFFH8SAAISAAIIvRicLgBFAAASAAIIvRicLgBFAAAsAAQKfz0AAxIABwjiHxIgAGECABIABwjiHxIgAGECABsAAQjeFhN+AEIAAAAA.大禅契经藏:BAABLAAECn8sAAMZAAcInRdXHwC1AQAZAAcInRdXHwC1AQALAAcIdAuUbAC+AAABLAAFFAIIEgASAL0YAA==.大禅鞞尼迦:BAACLAAFFH8OAAIDAAIIhhv5EgBMAAADAAIIhhv5EgBMAAAsAAQKfzQAAgMABwgTHiEYAFkCAAMABwgTHiEYAFkCAAEsAAUUAggSABIAvRgA.',['天之']='天之满萨:BAAALAAECggICAAAAA==.',['奥利']='奥利奥德萨:BAAALAAECgIIAgAAAA==.奥利雅:BAAALAAECgUIBQAAAA==.',['奶妈']='奶妈爆了:BAABLAAFFH8lAAMFAAYI8yXaDQDpAQAFAAYI8yXaDQDpAQAcAAIIrRrCDACpAAAAAA==.',['好大']='好大一只逗比:BAAALAADCgEIAQAAAA==.',['安心']='安心睡:BAAALAAFFAIIAQAAAA==.',['安舍']='安舍之手:BAABLAAFFH8QAAMJAAQI+gNrKABVAAAJAAIImgBrKABVAAAIAAQIlQHGFQBLAAAAAA==.',['宠物']='宠物先上:BAAALAAECgQIBAAAAA==.',['寒逍']='寒逍:BAAALAADCgcIBwAAAA==.',['将它']='将它击杀:BAAALAAECgYICgABLAAFFAYIJgAdAE0fAA==.',['小剑']='小剑人:BAABLAAFFH8aAAIdAAQI0wJ/IQBuAAAdAAQI0wJ/IQBuAAAAAA==.',['小哞']='小哞:BAAALAADCgYIBgAAAA==.',['小小']='小小宝丶:BAABLAAFFH8cAAIBAAYIhCL+GgCvAQABAAYIhCL+GgCvAQAAAA==.小小斌下士:BAACLAAFFH8WAAMeAAUIOBLHCAAXAQAeAAUINA7HCAAXAQAUAAMIahJVFACiAAAsAAQKf0MAAx4ACAi5H0cIAMECAB4ACAgJHkcIAMECABQACAgwGucWAF8CAAAA.',['小布']='小布总:BAAALAADCggIEgAAAA==.',['小熙']='小熙熙:BAAALAAFFAQIBAAAAA==.',['小猎']='小猎猫:BAAALAAECgYIBgAAAA==.',['小白']='小白阿猫:BAAALAADCgMIAwAAAA==.',['小艾']='小艾酱:BAAALAAECgUIBQAAAA==.',['小虾']='小虾吞饭:BAAALAAECgcIDQAAAA==.',['小钢']='小钢毛:BAABLAAFFH8NAAMCAAMIPAHvDgA5AAACAAMIPAHvDgA5AAABAAEIIwFTbAAaAAAAAA==.',['小马']='小马尾:BAAALAAFFAIIAgAAAA==.',['小骆']='小骆快跑:BAAALAAFFAIIAgAAAA==.',['小鸟']='小鸟跳崖:BAAALAAECgYICgAAAA==.',['小鸡']='小鸡毛自己玩:BAAALAAFFAIIAgAAAA==.',['小麦']='小麦酒港:BAABLAAFFH8JAAMDAAMIjg6CDwBoAAADAAMIjg6CDwBoAAABAAEIXANragAqAAAAAA==.',['尼桑']='尼桑公路战神:BAAALAADCgcIBwAAAA==.',['尼采']='尼采的鞭子:BAAALAAECgYICAAAAA==.',['山静']='山静鸟谈天:BAAALAAECgYIEwAAAA==.',['岁月']='岁月安然:BAABLAAFFH8OAAIFAAUIXhErRQAnAQAFAAUIXhErRQAnAQAAAA==.',['崩天']='崩天:BAAALAAFFAIIAgAAAA==.',['左夏']='左夏右弥:BAAALAAFFAIIAgAAAA==.',['已断']='已断开连接:BAACLAAFFH8lAAIBAAYIeBXwFgCrAQABAAYIeBXwFgCrAQAsAAQKfz4AAgEACAi8JBILADsDAAEACAi8JBILADsDAAAA.',['巴黎']='巴黎水:BAAALAADCgMIAwAAAA==.',['布易']='布易班:BAAALAADCgQIBAAAAA==.',['希路']='希路达:BAAALAAECgYIBgAAAA==.',['幚灬']='幚灬硬:BAAALAAECgUICgAAAA==.',['幚硬']='幚硬丶:BAAALAAECgQIBAAAAA==.',['幽夜']='幽夜小猎:BAAALAAECgYIDgAAAA==.',['弑灬']='弑灬梦:BAABLAAFFH8GAAIFAAIIigTPmgA5AAAFAAIIigTPmgA5AAAAAA==.',['弓弧']='弓弧名家:BAAALAAECgYIDgAAAA==.',['弓箭']='弓箭手小鹿:BAABLAAFFH8SAAITAAYIvCAjGgDOAQATAAYIvCAjGgDOAQAAAA==.',['弗特']='弗特莱:BAACLAAFFH8mAAIdAAYITR8tCQCvAQAdAAYITR8tCQCvAQAsAAQKfxUAAh0ACAiaGpAsAOUBAB0ACAiaGpAsAOUBAAAA.',['强壮']='强壮的小黑蛋:BAAALAAECgUIBwAAAA==.',['彪悍']='彪悍的小德:BAABLAAFFH8RAAIfAAMI3ww8CQBVAAAfAAMI3ww8CQBVAAAAAA==.',['影琉']='影琉璃:BAAALAAECgQIBAAAAA==.',['待我']='待我胸毛及腰:BAACLAAFFH8mAAMLAAYI7RxTEwAcAQALAAYI7RxTEwAcAQAZAAMIegT8PwBLAAAsAAQKfxwAAgsACAhBIXAVAMsCAAsACAhBIXAVAMsCAAAA.待我胸髦及腰:BAAALAAFFAIIAgAAAA==.',['很反']='很反感半年报:BAAALAADCggIDAAAAA==.',['德邦']='德邦总管赵信:BAAALAAECgYIDAAAAA==.',['心灵']='心灵圣牧:BAABLAAFFH8RAAIKAAMI4glRMwCcAAAKAAMI4glRMwCcAAAAAA==.',['忘肆']='忘肆:BAABLAAFFH8GAAMKAAYIUwlxJAAbAQAKAAUIFAlxJAAbAQAMAAEIzgbsKwA/AAAAAA==.',['念柔']='念柔:BAAALAAECgYIEwAAAA==.',['思念']='思念在躲避:BAAALAAECgUIBQAAAA==.',['恬淡']='恬淡晴天:BAACLAAFFH8rAAIWAAYIzxizBQCUAQAWAAYIzxizBQCUAQAsAAQKfzUAAhYACAhCIH4JAM0CABYACAhCIH4JAM0CAAAA.',['恶魔']='恶魔乌鸦:BAAALAADCgEIAQAAAA==.恶魔挑逗师:BAABLAAFFH8WAAIgAAMIRQVvBQBzAAAgAAMIRQVvBQBzAAAAAA==.',['悠悠']='悠悠我心丶:BAABLAAFFH8GAAIGAAIIMhMHQwCXAAAGAAIIMhMHQwCXAAAAAA==.',['悲伤']='悲伤小奶狗:BAABLAAFFH8GAAIIAAIIUAS6IwAiAAAIAAIIUAS6IwAiAAAAAA==.',['戀戀']='戀戀依依:BAABLAAFFH8FAAILAAII+ho1QACBAAALAAII+ho1QACBAAAAAA==.',['我刷']='我刷我唰:BAABLAAECn8UAAMJAAgIGhyoGQBAAgAJAAcIOhyoGQBAAgAHAAIIiBTwvwB8AAAAAA==.',['我叫']='我叫俺木涕:BAABLAAFFH8GAAIdAAYI3ARuGADkAAAdAAYI3ARuGADkAAAAAA==.',['我弥']='我弥华没有错:BAACLAAFFH8OAAIFAAQIaRyoGQBjAQAFAAQIaRyoGQBjAQAsAAQKfxgAAgUACAj/I0QIAL4CAAUACAj/I0QIAL4CAAAA.',['战之']='战之咆哮:BAABLAAFFH8IAAIRAAQIvwCcXwA1AAARAAQIvwCcXwA1AAAAAA==.',['战锋']='战锋芒:BAAALAAECgQIBQAAAA==.',['手术']='手术中:BAAALAADCgQIBAAAAA==.',['打工']='打工崽:BAAALAAECgYIDAAAAA==.',['技高']='技高一筹:BAAALAAECgYIBgAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8NAAILAAYI4RaaGgCJAQALAAYI4RaaGgCJAQAAAA==.',['折耳']='折耳小狮叽:BAABLAAECn8bAAIRAAYItSJbOABUAgARAAYItSJbOABUAgABLAAFFAMIEQAQANoZAA==.折耳小老虎:BAACLAAFFH8RAAMQAAMI2hnJDwDxAAAQAAMI6hbJDwDxAAATAAMINBdUbACKAAAsAAQKfzUAAxMABwgzJKwgADoCABAABgi6JQkaAJMCABMABwjCIqwgADoCAAAA.',['拉丝']='拉丝嗒奤:BAAALAAECgYIDwAAAA==.',['拉我']='拉我我能行:BAAALAAECgMIAwAAAA==.',['控制']='控制到死:BAAALAAECgYIDQAAAA==.',['提小']='提小牧:BAAALAAECgIIAgAAAA==.提小米:BAACLAAFFH8jAAIbAAYItxpoDgDYAQAbAAYItxpoDgDYAQAsAAQKfx8AAxsACAjNIQ8TAMMCABsACAjNIQ8TAMMCAB8AAQgoCqg7ACgAAAAA.',['提米']='提米:BAABLAAFFH8XAAIBAAYIUBAiKgBqAQABAAYIUBAiKgBqAQAAAA==.',['敬明']='敬明:BAAALAAECgYIBgAAAA==.',['斜月']='斜月沉沉:BAAALAAECgMIAwAAAA==.',['无敌']='无敌熊蹄:BAAALAADCgcIBwAAAA==.',['日耳']='日耳曼吐水鲨:BAAALAADCgQIBAAAAA==.',['明眸']='明眸善导:BAABLAAECn8XAAIGAAgIDBNFbgDqAQAGAAgIDBNFbgDqAQAAAA==.',['明石']='明石:BAAALAAFFAIIBAAAAA==.',['星沉']='星沉天渊:BAAALAAECgYIDQAAAA==.',['星芒']='星芒月幻:BAAALAAECgEIAQAAAA==.',['星落']='星落荧惑:BAAALAAECgYIBgAAAA==.',['星辉']='星辉骑士:BAABLAAFFH8OAAIdAAYI4h5ECQBLAQAdAAYI4h5ECQBLAQAAAA==.',['春风']='春风一杯酒丶:BAAALAADCggIBwAAAA==.',['晨夕']='晨夕星际:BAAALAAECgYIBwAAAA==.',['暖日']='暖日绒猫:BAAALAAFFAIIAgAAAA==.',['暗夜']='暗夜武僧:BAABLAAFFH8UAAIVAAgI3hfJDAB6AQAVAAgI3hfJDAB6AQAAAA==.',['暗牧']='暗牧法刺:BAAALAAECgIIAgAAAA==.',['暴力']='暴力幽靈:BAACLAAFFH8GAAIRAAYI7gR0LQDzAAARAAYI7gR0LQDzAAAsAAQKfxUABB0ABwjtFyAgAEMBAB0ABwjtFyAgAEMBABEAAgiyELnyAG8AACEAAgj9ErcxAGsAAAAA.暴力爷爷:BAAALAAFFAIIBAAAAA==.',['暴血']='暴血:BAABLAAECn8VAAIRAAcI+xF5OgBwAQARAAcI+xF5OgBwAQAAAA==.',['暴风']='暴风雪:BAAALAAECgYIEQAAAA==.',['月夜']='月夜哈士奇:BAABLAAFFH8VAAMfAAMIEAcACwBEAAAfAAMIEAcACwBEAAAbAAII9gB2TgA8AAAAAA==.',['李阿']='李阿不:BAAALAAECgMIAwAAAA==.',['枯木']='枯木行者:BAAALAAFFAIIBAAAAA==.',['枯法']='枯法者:BAAALAADCgQIBAAAAA==.',['柒閲']='柒閲:BAAALAADCgIIAgABLAAFFAMIFAATAJ4aAA==.',['柠小']='柠小猎丶:BAABLAAFFH8MAAITAAUItSLfNwBhAQATAAUItSLfNwBhAQAAAA==.',['梅琳']='梅琳娜的锋刃:BAAALAAECgYIBgAAAA==.',['梨花']='梨花千树:BAACLAAFFH8OAAIHAAUIBwYVNADjAAAHAAUIBwYVNADjAAAsAAQKfyAAAgcACAiOEb+NANQBAAcACAiOEb+NANQBAAAA.',['橙子']='橙子姐姐:BAAALAAECgYIBgAAAA==.',['檀樱']='檀樱:BAABLAAECn8eAAIHAAgIRSD+HwDyAgAHAAgIRSD+HwDyAgAAAA==.',['止风']='止风眉:BAAALAAFFAIIBAAAAA==.',['武僧']='武僧武松:BAABLAAFFH8YAAIVAAQIFAG9HABJAAAVAAQIFAG9HABJAAAAAA==.',['死鬼']='死鬼:BAAALAAFFAIIAgAAAA==.',['残丶']='残丶梦:BAAALAAECgYICAAAAA==.',['殺戮']='殺戮葬送:BAAALAAFFAEIAQAAAA==.',['殿一']='殿一:BAABLAAFFH8LAAIbAAMInw1ZNQCVAAAbAAMInw1ZNQCVAAAAAA==.',['毛毛']='毛毛球:BAABLAAFFH8aAAMKAAYI2R00DAAJAgAKAAYI2R00DAAJAgAMAAMIVRF5GQDnAAAAAA==.',['毛胖']='毛胖球:BAABLAAFFH+kAAMKAAgIBSTYAAA3AwAKAAgIBSTYAAA3AwAMAAQIFR0QDwByAQAAAA==.',['水宝']='水宝宝灬:BAAALAADCgMIAwAAAA==.',['水流']='水流萨:BAAALAAFFAEIAQAAAA==.',['水蜜']='水蜜桃:BAAALAADCgYIBgAAAA==.',['沃斯']='沃斯卡娅:BAAALAAECgMIAwAAAA==.',['没睡']='没睡醒:BAAALAAECgcIDQAAAA==.',['泡芙']='泡芙:BAAALAAECgYIBgAAAA==.',['洛丨']='洛丨长眠者丨:BAAALAAFFAIIAgAAAA==.',['派达']='派达星:BAAALAADCgcIBgAAAA==.',['流浪']='流浪太阳焊怂:BAABLAAFFH8GAAIRAAIIvBLeMQCdAAARAAIIvBLeMQCdAAAAAA==.',['消消']='消消乐:BAAALAAECgYICgAAAA==.',['淑芬']='淑芬:BAAALAADCgcIBwAAAA==.',['淘气']='淘气的橙子:BAACLAAFFH8OAAIKAAQIMAOSIgCvAAAKAAQIMAOSIgCvAAAsAAQKfx0AAgoACAjMB5VmAEgBAAoACAjMB5VmAEgBAAAA.',['淚弎']='淚弎年:BAABLAAFFH8IAAIHAAgIjRMwBgAiAgAHAAgIjRMwBgAiAgAAAA==.',['淮海']='淮海雲龍:BAAALAAECgcIEwAAAA==.',['淳安']='淳安啊:BAAALAAFFAIIAgAAAA==.',['混世']='混世魔王先生:BAABLAAFFH8RAAIHAAYIbh18EgC1AQAHAAYIbh18EgC1AQAAAA==.',['混沌']='混沌魔导师:BAAALAAECgIIBAAAAA==.',['清纯']='清纯人夫:BAABLAAFFH8KAAIRAAIIPRfqRgBMAAARAAIIPRfqRgBMAAABLAAFFAUIEQADAAIWAA==.',['清蒸']='清蒸猎:BAAALAAECgIIAgABLAAFFAYIKwAWAM8YAQ==.',['清辉']='清辉霜天:BAAALAAECgYIBgABLAAFFAYIKwAWAM8YAA==.',['清风']='清风夜下:BAABLAAFFH8fAAMGAAYIsBK8IgBzAQAGAAYIsBK8IgBzAQAaAAIIQAQ+GQBRAAAAAA==.',['温暖']='温暖的良夜:BAAALAAECgQIBQAAAA==.',['温赛']='温赛尔彡猎风:BAAALAAECgQIAQAAAA==.',['滚智']='滚智深:BAAALAADCgYIBgAAAA==.',['漠漠']='漠漠:BAAALAAECgYICQAAAA==.',['潘达']='潘达华斯基:BAACLAAFFH8cAAMWAAUIJxbMCgBgAQAWAAUIJxbMCgBgAQAiAAMIHAf2EgBnAAAsAAQKfywAAhYACAhWH/sLAKYCABYACAhWH/sLAKYCAAAA.',['激怒']='激怒奶爆:BAABLAAFFH8IAAIjAAMIJySGAgAqAQAjAAMIJySGAgAqAQAAAA==.',['灬小']='灬小熊熊灬:BAAALAADCgYIBgAAAA==.',['灵风']='灵风:BAABLAAECn8ZAAILAAcIOhhpJQDbAQALAAcIOhhpJQDbAQAAAA==.',['灼耀']='灼耀:BAAALAAECgMIAwAAAA==.',['炕上']='炕上最强王者:BAAALAADCgQIBAAAAA==.',['熊丶']='熊丶风暴烈酒:BAAALAADCgYIBgAAAA==.',['熊猫']='熊猫大的:BAAALAADCgEIAQAAAA==.',['燊鲂']='燊鲂:BAACLAAFFH8HAAITAAMINxSoJADrAAATAAMINxSoJADrAAAsAAQKfyAAAxMACAhrGQ94AO0BABMACAg1GQ94AO0BABAACAi1EXFRAHABAAAA.',['爆射']='爆射丶:BAAALAAFFAIIAgAAAA==.',['爆浆']='爆浆酱爆:BAAALAAECgYIBgAAAA==.',['爆裂']='爆裂人偶:BAAALAAECgMIAwAAAA==.爆裂的人偶:BAAALAAECgQIBAAAAA==.',['爱吃']='爱吃茼蒿:BAAALAAFFAIIAgAAAA==.',['爱衣']='爱衣酱大胜利:BAAALAADCggICAAAAA==.',['版本']='版本之子:BAAALAAFFAIIAgAAAA==.',['牛马']='牛马三号:BAABLAAFFH8FAAIVAAUIBQy2FAD3AAAVAAUIBQy2FAD3AAAAAA==.',['牵好']='牵好我的龙:BAACLAAFFH8xAAMWAAYI7BydBQD2AQAWAAYI7BydBQD2AQAiAAIIrAdrEgB1AAAsAAQKfyIAAhYACAhTHz0JANECABYACAhTHz0JANECAAAA.',['狄奥']='狄奥多西:BAAALAADCgYIBgAAAA==.',['狐狸']='狐狸安:BAAALAAECgYIBgAAAA==.',['狗公']='狗公公:BAAALAAECgQIBAAAAA==.',['独倚']='独倚望江楼:BAACLAAFFH8SAAMEAAYIFh/AIACaAQAEAAYIGR7AIACaAQAgAAEI2BvLBgBaAAAsAAQKfxkAAyQABgiiDfoZAAYBACQABgiiDfoZAAYBAAQAAghgBCr/AEAAAAAA.',['独孤']='独孤欲:BAAALAAECgUICAAAAA==.',['猎德']='猎德人:BAAALAAECgYICgABLAAFFAYIJgAdAE0fAA==.',['猫氏']='猫氏财团叫兽:BAAALAAFFAEIAQAAAA==.',['王心']='王心怡:BAABLAAFFH8GAAMSAAYIGQ3NCgBzAQASAAUI9w3NCgBzAQAbAAEIgwFFTwA3AAAAAA==.',['王晋']='王晋涛:BAAALAAECggICAAAAA==.',['王發']='王發抛:BAAALAAECgUICgAAAA==.',['王马']='王马如:BAAALAAFFAIIAgAAAA==.',['玩不']='玩不动了哦:BAAALAAFFAIIAgAAAA==.',['瓜瓜']='瓜瓜:BAAALAADCgcIBwAAAA==.',['由乙']='由乙:BAAALAAECgYIBgAAAA==.',['由甲']='由甲:BAAALAAECggICAAAAA==.',['申蓝']='申蓝天:BAABLAAFFH8MAAILAAYIpyHMCAA5AgALAAYIpyHMCAA5AgAAAA==.',['白银']='白银之猫:BAAALAAECgYIBgAAAA==.',['白雪']='白雪红颜:BAABLAAFFH8SAAIcAAQIGgH/FgBTAAAcAAQIGgH/FgBTAAAAAA==.',['皎兮']='皎兮:BAABLAAFFH8/AAIZAAYIWiazBwA8AgAZAAYIWiazBwA8AgABLAAFFAgIRwAZABwmAA==.',['皮皮']='皮皮杨:BAAALAAECgQIBAAAAA==.',['盗版']='盗版奋斗:BAAALAAECgUIBQAAAA==.',['相沢']='相沢綾香:BAACLAAFFH8RAAIbAAQIcxCiJAD3AAAbAAQIcxCiJAD3AAAsAAQKfyQABRsACAgtE69DANIBABsACAgtE69DANIBAB8ABQioDEkaALUAACUABgjXBUoaAKwAABIAAQjPBlq2ACIAAAAA.',['真是']='真是太烧了:BAABLAAFFH8KAAIBAAYI/A0gEQDdAQABAAYI/A0gEQDdAQAAAA==.',['碧风']='碧风浩扬:BAAALAAECgYIBwAAAA==.',['神牧']='神牧:BAAALAAECgcIBwAAAA==.',['秉持']='秉持传统:BAAALAADCgYIBgAAAA==.',['秋离']='秋离之风吟:BAAALAADCggICAAAAA==.',['秋风']='秋风亦会:BAACLAAFFH8GAAIRAAMIUBWFGQD7AAARAAMIUBWFGQD7AAAsAAQKfxsAAhEABwg2Im8xAHECABEABwg2Im8xAHECAAAA.',['站着']='站着三鸟:BAAALAAECgYIEwAAAA==.',['第一']='第一把特鲁:BAABLAAFFH8FAAIEAAIIUwEJdQAQAAAEAAIIUwEJdQAQAAAAAA==.',['第二']='第二时空裂隙:BAAALAAECgEIAQAAAA==.',['等我']='等我集合打团:BAACLAAFFH8RAAIFAAUIpBCCRAAqAQAFAAUIpBCCRAAqAQAsAAQKfxoAAgUACAg1HL5PAFkCAAUACAg1HL5PAFkCAAAA.',['简单']='简单直接:BAAALAAFFAYIBAAAAA==.',['箐箐']='箐箐子悠:BAAALAAFFAIIAgAAAA==.',['米兔']='米兔枭枭乐:BAABLAAFFH8PAAMbAAYIOyJdDQDmAQAbAAUIqyJdDQDmAQASAAYI9wrSHwDEAAAAAA==.',['粉毛']='粉毛:BAAALAADCgYIBgAAAA==.',['糕手']='糕手二号机:BAAALAAECggICAAAAA==.',['糟佬']='糟佬头:BAABLAAFFH8IAAITAAMIDwkwNAC7AAATAAMIDwkwNAC7AAAAAA==.',['紫依']='紫依媽然:BAAALAAECggICAAAAA==.',['緈諨']='緈諨丿丶乂氼:BAAALAAECgYIBgAAAA==.',['红小']='红小辰:BAABLAAFFH8UAAITAAYIpQrHGgAvAQATAAYIpQrHGgAvAQAAAA==.',['红鸠']='红鸠:BAAALAAECggIEgABLAAFFAEIAQAYAAAAAA==.',['纯爱']='纯爱图腾:BAABLAAECn8bAAMbAAcI+B0gEQBPAgAbAAcI+B0gEQBPAgAfAAcILgQPHgCSAAAAAA==.',['绝望']='绝望信标拿杜:BAAALAAECgYIDAAAAA==.',['绯绯']='绯绯雨雨:BAAALAADCgQICAAAAA==.',['绿龙']='绿龙女王小三:BAABLAAFFH8KAAMPAAMIYgLjGQBwAAAPAAMIYgLjGQBwAAAmAAEI6gITJQAnAAAAAA==.',['羊月']='羊月眠:BAAALAADCgEIAQAAAA==.',['翡翠']='翡翠的德德丶:BAAALAAECgUIBQAAAA==.',['脚滑']='脚滑:BAABLAAFFH8HAAIbAAYIBhttEQC2AQAbAAYIBhttEQC2AQAAAA==.',['自由']='自由发挥丶:BAABLAAECn8VAAMLAAcIIxBASgAyAQALAAcIIxBASgAyAQAZAAII7RM3tgCDAAAAAA==.',['艾了']='艾了个草:BAABLAAFFH8YAAMSAAYIDCS9BwDrAQASAAYIDCS9BwDrAQAbAAIIRxbWLAB8AAAAAA==.',['艾尔']='艾尔丶誓阳:BAAALAAECgYICAAAAA==.',['花有']='花有重开之时:BAAALAAFFAgIBAAAAA==.',['花清']='花清:BAABLAAFFH8GAAILAAIIjRPwVgBmAAALAAIIjRPwVgBmAAAAAA==.',['花花']='花花朵朵:BAAALAAECgYIBgAAAA==.',['芳娘']='芳娘:BAAALAAECgYIBgAAAA==.',['苏菲']='苏菲:BAAALAADCgIIAgAAAA==.',['苦瓜']='苦瓜:BAACLAAFFH82AAMBAAYIcCPeEwDGAQABAAUIFCXeEwDGAQACAAEIOhtlCgBQAAAsAAQKf0oAAwEACAjbJdMCAHkDAAEACAjbJdMCAHkDAAMAAghiD02BAGcAAAAA.',['英勇']='英勇汉堡王:BAAALAAECgIIAgAAAA==.',['范特']='范特西丶德:BAAALAAFFAIIAgABLAAFFAgIQAAKAAglAA==.',['草原']='草原啊草原:BAAALAAFFAIIAgAAAA==.',['莫古']='莫古力之家:BAAALAAECggICAAAAA==.',['菈妮']='菈妮的锋刃:BAAALAAECgIIAgAAAA==.',['萌哒']='萌哒:BAAALAAECgUIBQAAAA==.',['萌萌']='萌萌兔三号机:BAAALAAFFAQIAgAAAA==.萌萌的小德:BAAALAAECgYIBgAAAA==.',['萨飒']='萨飒洒撒:BAAALAAFFAIIAwAAAA==.',['蒲公']='蒲公因:BAAALAAECgYIDAAAAA==.',['薯条']='薯条是只猫:BAAALAADCgUIBQAAAA==.',['蛋蛋']='蛋蛋飘:BAAALAAECggIEAAAAA==.',['血性']='血性狂暴:BAAALAAECgYIBgAAAA==.',['裹脚']='裹脚布在治疗:BAAALAAECgYIBgAAAA==.裹脚布手很长:BAAALAAECgUIBQAAAA==.裹脚布香喷喷:BAAALAAFFAIIBAAAAA==.',['让宣']='让宣:BAAALAAECgYIBwAAAA==.让宣喵:BAABLAAFFH8HAAIBAAUIGg0dOQAFAQABAAUIGg0dOQAFAQAAAA==.',['让让']='让让小宣:BAACLAAFFH8JAAIGAAUICR8BJgBgAQAGAAUICR8BJgBgAQAsAAQKfxsAAwYABwiVInktAKcCAAYABwiVInktAKcCABoABAiJDPdOAJsAAAAA.',['豆丨']='豆丨油:BAACLAAFFH8vAAISAAcISyDWAgBEAgASAAcISyDWAgBEAgAsAAQKfzsAAxIACAi5JpwAAJcDABIACAi5JpwAAJcDABsAAghSCDTXAFIAAAAA.',['败笑']='败笑秋风:BAAALAAECgMIAwAAAA==.',['费奥']='费奥多尔:BAABLAAFFH8lAAIZAAYIuR9hDgDRAQAZAAYIuR9hDgDRAQAAAA==.',['起来']='起来重睡:BAAALAAFFAIIAgAAAA==.',['超污']='超污小萌:BAABLAAFFH8GAAISAAYIPBCbEgBTAQASAAYIPBCbEgBTAQAAAA==.',['趣踏']='趣踏玛德:BAAALAAECgYICQAAAA==.',['跑酷']='跑酷春元:BAAALAAECgYICAAAAA==.',['蹦跶']='蹦跶的大犄角:BAAALAADCgcIBwAAAA==.',['躺者']='躺者:BAAALAAFFAIIAwAAAA==.躺者小宣:BAAALAAECgYICQAAAA==.',['辛德']='辛德瑞拉:BAAALAAECgYIEgAAAA==.',['还是']='还是个孩子:BAAALAAECgYICQAAAA==.',['这是']='这是一个戰士:BAAALAAECgYICAAAAA==.这是一个洒满:BAAALAAECgEIAQAAAA==.这是一个苍蝇:BAAALAAECgQIBAAAAA==.这是一个迪恺:BAAALAAECgIIAgAAAA==.',['那个']='那个奶德:BAABLAAFFH8LAAILAAYIcRNNHQBzAQALAAYIcRNNHQBzAQAAAA==.',['邪刃']='邪刃战姬:BAABLAAFFH8UAAIaAAQIfwKWDwBPAAAaAAQIfwKWDwBPAAAAAA==.',['邪恶']='邪恶战神:BAAALAADCgEIAQAAAA==.',['邪柯']='邪柯基:BAAALAAFFAIIAgAAAA==.',['郭茨']='郭茨口一霸:BAAALAAECgEIAQAAAA==.郭茨口楠楠:BAAALAADCgcIBwAAAA==.',['野性']='野性之心古夫:BAAALAAFFAIIAwAAAA==.',['錑弎']='錑弎年:BAAALAADCgMIAwAAAA==.',['钟楚']='钟楚红:BAAALAAECgYIBgAAAA==.',['钱多']='钱多多:BAAALAAECgYICAAAAA==.',['销皇']='销皇爱妃:BAAALAADCgMIAwAAAA==.',['阿卡']='阿卡丽:BAAALAAFFAIIAgAAAA==.',['阿斯']='阿斯普洛斯:BAAALAAFFAIIBAAAAA==.',['陆得']='陆得哼:BAAALAAECgYICwAAAA==.',['陌丶']='陌丶浅然:BAABLAAFFH8JAAITAAYInxAYDgDCAQATAAYInxAYDgDCAQAAAA==.',['陪老']='陪老大来打鱼:BAABLAAFFH8HAAIDAAMIygfJDACfAAADAAMIygfJDACfAAABLAAFFAcIOQAHAEsmAA==.陪老大来炸鱼:BAACLAAFFH8jAAIRAAYIjxaCGQCYAQARAAYIjxaCGQCYAQAsAAQKfxUAAhEABwiTFyZYAOkBABEABwiTFyZYAOkBAAAA.陪老大来烤鱼:BAABLAAFFH8GAAIKAAMITAR0NgCKAAAKAAMITAR0NgCKAAAAAA==.陪老大来钓鱼:BAAALAAECgYICQAAAA==.',['隔壁']='隔壁三狐狸:BAABLAAFFH8RAAMQAAMILxN1EAByAAAQAAMILxN1EAByAAATAAEIGgzTiwA8AAAAAA==.',['雁啼']='雁啼:BAAALAAFFAMIAwAAAA==.',['雨巷']='雨巷独悲:BAAALAAECgIIAgAAAA==.',['雪之']='雪之下的情愫:BAABLAAFFH8RAAIGAAUIpxdlHwDsAAAGAAUIpxdlHwDsAAAAAA==.',['雪帝']='雪帝凯:BAABLAAFFH8MAAIFAAUIRgu7LgDgAAAFAAUIRgu7LgDgAAAAAA==.',['雪暖']='雪暖晴岚:BAAALAAFFAIIBAAAAA==.',['雷欧']='雷欧格林:BAAALAAECgYIDAAAAA==.',['霜语']='霜语下灵:BAACLAAFFH8LAAMDAAMICRjACgCsAAABAAMI1xNEJwD2AAADAAIIuiDACgCsAAAsAAQKfyEAAwMABwjLH5AgABgCAAEABwjGHkk5AGUCAAMABwh2HZAgABgCAAAA.',['霸气']='霸气轩哥:BAABLAAFFH8KAAMJAAQI2xzWHgCsAAAJAAII1BrWHgCsAAAHAAII6BeZWwBJAAAAAA==.',['青眼']='青眼白龍:BAAALAADCgEIAQAAAA==.',['顽昧']='顽昧:BAABLAAFFH8GAAIMAAQIjwSLHQCgAAAMAAQIjwSLHQCgAAAAAA==.',['風箭']='風箭:BAAALAADCgEIAQAAAA==.',['风中']='风中追风:BAAALAAECgUIBwAAAA==.',['风之']='风之精灵:BAAALAAECgMIBgAAAA==.',['风抽']='风抽我烟:BAAALAAECgEIAQAAAA==.',['风游']='风游:BAACLAAFFH8vAAITAAYIWiXcDwAMAgATAAYIWiXcDwAMAgAsAAQKfxoAAxMABwgSJbQtAKICABMABwgSJbQtAKICABAAAwgJEM6bAIIAAAAA.',['风语']='风语德兰泰:BAAALAAECgYIEgAAAA==.',['风雷']='风雷电闪:BAAALAADCgIIAgAAAA==.',['饕餮']='饕餮战神:BAAALAAECgYICgAAAA==.',['馒头']='馒头不会潜行:BAAALAADCgQIBAAAAA==.',['马筱']='马筱萌:BAAALAAFFAIIBAABLAAFFAYIEQAVAB0SAA==.',['驭雪']='驭雪狂徒:BAABLAAFFH8cAAIdAAYIIQlPDwDUAAAdAAYIIQlPDwDUAAAAAA==.',['骏小']='骏小哥:BAAALAAFFAMIAwAAAA==.骏小爷:BAABLAAFFH8uAAMEAAYIcx2OIACbAQAEAAYIcx2OIACbAQAkAAEIkRYyKABQAAAAAA==.',['高小']='高小柒:BAACLAAFFH8eAAMIAAYImBHxBQAaAQAIAAYIXhHxBQAaAQAHAAIIrRUoXwBHAAAsAAQKfyAAAwgACAjUHJsQAH4CAAgACAgNG5sQAH4CAAcACAi8FpukALABAAAA.',['高等']='高等丶术学:BAABLAAFFH8KAAIEAAUIsAYxQAD1AAAEAAUIsAYxQAD1AAAAAA==.',['鹿港']='鹿港:BAACLAAFFH8bAAIBAAUIZx2DEwDKAQABAAUIZx2DEwDKAQAsAAQKfy8AAwEACAgtJTEJAEgDAAEACAiyJDEJAEgDAAMABAhRHgNGAFgBAAAA.',['麦灬']='麦灬兜:BAAALAAECgcIDAAAAA==.',['黯幽']='黯幽影:BAACLAAFFH8kAAITAAcImxmUEgD5AQATAAcImxmUEgD5AQAsAAQKfx0AAhMACAg+H+k4AHsCABMACAg+H+k4AHsCAAAA.',['龙之']='龙之帝:BAABLAAECn8gAAIcAAYI7h6FDgCTAQAcAAYI7h6FDgCTAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end