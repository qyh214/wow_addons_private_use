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
 local lookup = {'Paladin-Retribution','Warrior-Arms','Warlock-Destruction','Warrior-Protection','Warrior-Fury','Monk-Mistweaver','DeathKnight-Frost','DeathKnight-Unholy','Mage-Frost','Mage-Arcane','Hunter-BeastMastery','DemonHunter-Havoc','Druid-Balance','Hunter-Marksmanship','Priest-Shadow','Priest-Holy','Shaman-Restoration','Shaman-Elemental','Paladin-Protection','Shaman-Enhancement','Rogue-Assassination','Warlock-Affliction','Warlock-Demonology','Druid-Guardian','DemonHunter-Vengeance','Druid-Restoration','Druid-Feral','Evoker-Devastation','Priest-Discipline','Monk-Brewmaster','Evoker-Preservation','Paladin-Holy','Mage-Fire','DeathKnight-Blood','Unknown-Unknown','Hunter-Survival','Rogue-Subtlety',}; local provider = {region='CN',realm='基尔加丹',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alolo:BAAAKgADCggIEwAAAA==.',Au='Augenstern:BAAAKgAFFAYIAgAAAA==.',Be='Benfly:BAABKgAFFH8IAAIBAAMI4yD2GgANAQABAAMI4yD2GgANAQAAAA==.',Cl='Clegane:BAABKgAFFH8GAAICAAYIFQ4ZCgBqAQACAAYIFQ4ZCgBqAQAAAA==.',Da='Darklady:BAAAKgADCgIIAgAAAA==.',Do='Donblue:BAAAKgADCgYIBgAAAA==.',Dr='Drax:BAABKgAFFH8IAAIDAAgILwh5DgCmAQADAAgILwh5DgCmAQAAAA==.Dront:BAABKgAECn8gAAQEAAgI9hWVFAB8AQAEAAYINRyVFAB8AQAFAAYIfw9ETwAjAQACAAgINQYrNwAMAQABKgAFFAgICgAGAHUSAA==.',Gl='Glolo:BAAAKgADCggIDgAAAA==.',Gr='Grievous:BAABKgAECn8dAAIBAAgIJiWAGgCuAgABAAgIJiWAGgCuAgAAAA==.',Ho='Hongdie:BAACKgAFFH8nAAMHAAYIJhqpAwBxAQAHAAYIJhqpAwBxAQAIAAIIxwygSgB3AAAqAAQKfysAAwgACAhTGU1DAKUBAAgACAiwFU1DAKUBAAcAAghZGiEkAJ0AAAAA.',Hu='Huangkai:BAABKgAECn86AAMJAAgIYB9CBgBVAgAJAAgIYB9CBgBVAgAKAAEIvA9ZmAA0AAAAAA==.',Ja='Jamie:BAAAKgADCgQIBAAAAA==.',Ka='Kasuml:BAAAKgAECgEIAQAAAA==.',Ki='Kimouhunter:BAABKgAFFH8HAAILAAQIMxKhMgDFAAALAAQIMxKhMgDFAAAAAA==.',Ku='Kuia:BAAAKgAECgQIBAAAAA==.',Ma='Magus:BAAAKgAECgMIAwAAAA==.',Me='Megademon:BAACKgAFFH8gAAIMAAUIbhRaHAAeAQAMAAUIbhRaHAAeAQAqAAQKfyoAAgwACAg7HUUKAFsCAAwACAg7HUUKAFsCAAAA.',Na='Nakashima:BAAAKgAFFAYIAQAAAA==.',Ne='Neogem:BAAAKgADCgYIBgAAAA==.',No='Norma:BAABKgAFFH8GAAINAAYIihQZEwCDAQANAAYIihQZEwCDAQAAAA==.',Ov='Ovoxovo:BAAAKgAFFAQIAgAAAA==.',Re='Reguluse:BAABKgAECn8VAAIMAAgIah6CGgBlAgAMAAgIah6CGgBlAgAAAA==.',Rh='Rhaegar:BAABKgAFFH8MAAIKAAYIGxP5EgBNAQAKAAYIGxP5EgBNAQABKgAFFAgIBgAKALAdAA==.',Sd='Sd:BAAAKgAECgQIBAAAAA==.',Sh='Shellyy:BAABKgAFFH8GAAIOAAYI6wVuJwDNAAAOAAYI6wVuJwDNAAAAAA==.',Si='Sibuqulr:BAAAKgADCggICAAAAA==.Siyuan:BAAAKgAECgQIBAAAAA==.',Sr='Sront:BAAAKgAECggIBAAAAA==.',St='Steelballrun:BAAAKgAECgEIAQAAAA==.Steelswarm:BAACKgAFFH8gAAMLAAQIkBfGKQDeAAALAAMIkBfGKQDeAAAOAAQInRQFJwDPAAAqAAQKfzoAAwsACAgRIOImAFgCAAsACAhYH+ImAFgCAA4ACAhHHtgbAPMBAAAA.',Su='Susi:BAAAKgADCgEIAQAAAA==.',Te='Teett:BAAAKgADCgYIBgAAAA==.',Tt='Tturpin:BAAAKgAECgMIAwAAAA==.',Us='Ushi:BAACKgAFFH8gAAMPAAQIJB3dEAD9AAAPAAQIJB3dEAD9AAAQAAIIxSKzDwDCAAAqAAQKfyQAAw8ACAhtGIkVAOkBAA8ACAhtGIkVAOkBABAABgh6IeoyAHUBAAAA.',Va='Valkyrjar:BAABKgAFFH8FAAIBAAUI4RQ5LgAvAQABAAUI4RQ5LgAvAQAAAA==.',Ww='Wwhyc:BAAAKgAECgUICwAAAA==.',Ye='Yeacion:BAABKgAECn8bAAMRAAcIBBaaPgB7AQARAAcIBBaaPgB7AQASAAEI4gMxfgAiAAAAAA==.',Yu='Yuyuko:BAAAKgAFFAQIBAAAAA==.',Zh='Zhldkt:BAAAKgAECgMIAwAAAA==.',['一只']='一只折耳兔:BAAAKgAECgUIBQAAAA==.一只格格巫:BAABKgAFFH8IAAMBAAQIvRqoGgD1AAABAAQIvRqoGgD1AAATAAQIRQ1VDQCdAAAAAA==.',['一煜']='一煜祺一:BAABKgAFFH8IAAILAAYIYyIjCAD3AQALAAYIYyIjCAD3AQAAAA==.',['一菊']='一菊花一:BAAAKgAECgEIAQAAAA==.',['不喝']='不喝假酒:BAAAKgAFFAIIAwAAAA==.',['不是']='不是虚胖:BAAAKgAECggIAgAAAA==.',['不要']='不要放弃吃药:BAACKgAFFH8dAAMRAAQIABvuHgCeAAARAAQIABvuHgCeAAASAAQIzwSeEQCOAAAqAAQKfzUAAxEACAhLHiYXAEkCABEACAhLHiYXAEkCABIAAgj/CVFnAGEAAAAA.',['且听']='且听枫吟:BAAAKgAFFAQIBAAAAA==.',['丨十']='丨十丨十丨:BAAAKgADCggICAAAAA==.',['中年']='中年大叔:BAAAKgAECgYIBgAAAA==.',['丰陀']='丰陀一:BAAAKgAECgcIBwAAAA==.丰陀八号:BAAAKgADCgIIAgAAAA==.',['临时']='临时演员:BAAAKgAFFAMIAwAAAA==.',['丶瞳']='丶瞳话中的晴:BAEBKgAFFH8OAAMUAAgInA/LBADcAQAUAAgInA/LBADcAQARAAIISBNbJQCHAAAAAA==.',['久雨']='久雨初晴:BAABKgAFFH8WAAIVAAYIahM6DACJAQAVAAYIahM6DACJAQAAAA==.',['乌龟']='乌龟骑士:BAAAKgAECggICAAAAA==.',['五块']='五块卵石:BAACKgAFFH8nAAQDAAgI+R3sEACFAQADAAYIlx3sEACFAQAWAAII9RZhFQCSAAAXAAMIwh1yEgBYAAAqAAQKf1YABAMACAgFJtQDANECAAMACAh0JdQDANECABcABghlH28fAIcBABYAAwiAGJEfAPQAAAAA.',['亚瑟']='亚瑟摩根:BAAAKgAFFAIIAgABKgAFFAgICAALAJ0HAA==.',['人头']='人头鱼:BAAAKgAECgUIBgAAAA==.',['代号']='代号灬幻术师:BAACKgAFFH8FAAIYAAMIaBcGBgCzAAAYAAMIaBcGBgCzAAAqAAQKfxoAAhgACAgzIooFAHQCABgACAgzIooFAHQCAAAA.代号灬追猎者:BAABKgAFFH8SAAIZAAQI5R3JCQALAQAZAAQI5R3JCQALAQAAAA==.代号灬阿瑞斯:BAABKgAFFH8ZAAIEAAUI8xQKBwD7AAAEAAUI8xQKBwD7AAAAAA==.',['以德']='以德服丶氼:BAAAKgAECggICQAAAA==.',['仰望']='仰望丶星海:BAABKgAECn8UAAMDAAgILBRIEgCEAQADAAcISRVIEgCEAQAXAAYIzQ24PwD0AAAAAA==.仰望丶星辰:BAAAKgAECggIEAAAAA==.',['伊利']='伊利蛋疼:BAAAKgAECgQIBAAAAA==.',['传说']='传说中的绅士:BAAAKgADCggICQAAAA==.',['伯牙']='伯牙绝弦:BAAAKgAECgMIBAAAAA==.',['伽康']='伽康:BAAAKgAECgQIBAAAAA==.',['余雪']='余雪珍:BAAAKgAECgEIAQAAAA==.',['依然']='依然小牧:BAAAKgAFFAgIAQAAAA==.依然风流:BAAAKgADCggICAAAAA==.',['保安']='保安丶:BAABKgAFFH8GAAMCAAQIGyAPCgDNAAAFAAQIFhTXEQDyAAACAAIIgCYPCgDNAAAAAA==.',['傅炎']='傅炎杰:BAABKgAFFH8IAAIIAAgIdBBVCAAJAgAIAAgIdBBVCAAJAgAAAA==.',['元素']='元素萨:BAAAKgAFFAQIBAAAAA==.',['兔子']='兔子家的小德:BAABKgAECn8aAAIaAAgIpBaDGwDBAQAaAAgIpBaDGwDBAQAAAA==.',['八六']='八六上山了:BAABKgAFFH8MAAIRAAQIlg6XFwDHAAARAAQIlg6XFwDHAAAAAA==.',['八神']='八神劲夫:BAAAKgAECgUIBQAAAA==.',['冥灬']='冥灬亲吻:BAAAKgAECgcICAAAAA==.冥灬唯美:BAAAKgAECgcIDQAAAA==.冥灬夕颜:BAAAKgADCggICAAAAA==.冥灬天天:BAAAKgAECgYICAAAAA==.',['冰雪']='冰雪媚儿:BAAAKgAECgUIBQAAAA==.',['净化']='净化朴哥:BAABKgAFFH8MAAIRAAQIDSLADgDqAAARAAQIDSLADgDqAAABKgAFFAgILwARANweAA==.',['凝望']='凝望群星:BAAAKgAFFAIIAgAAAA==.',['初夏']='初夏夜未央:BAAAKgAFFAYIBAAAAA==.',['劣白']='劣白白:BAABKgAFFH8uAAMOAAYI5RM6DABEAQAOAAYIlRI6DABEAQALAAMI/Bb+KwDWAAAAAA==.',['勒戈']='勒戈拉斯:BAACKgAFFH8OAAILAAQIFhLvGADMAAALAAQIFhLvGADMAAAqAAQKfx8AAwsACAglHNcOACsCAAsACAglHNcOACsCAA4AAwjRETaiADkAAAAA.',['化骨']='化骨绵羊:BAABKgAFFH8cAAMMAAgIPgNgFQDhAAAMAAgIMwNgFQDhAAAZAAYI1wGdFgCUAAAAAA==.',['十年']='十年一觉:BAABKgAECn8gAAQbAAgIWxdYDADrAQAbAAgIQRVYDADrAQAYAAgIchFuFwBDAQAaAAYIyRKyOAAHAQAAAA==.',['华尔']='华尔该下雪了:BAAAKgAECgYICQAAAA==.',['南通']='南通杨超越:BAAAKgAFFAMIAwAAAA==.',['卡拉']='卡拉亚:BAAAKgADCgIIAgAAAA==.',['原神']='原神鸣潮高手:BAACKgAFFH8PAAIRAAMIrhgbKADWAAARAAMIrhgbKADWAAAqAAQKfx4AAhEACAiMGigiAAoCABEACAiMGigiAAoCAAAA.',['双刀']='双刀武器战:BAABKgAECn8yAAIMAAgI+R+uBwCKAgAMAAgI+R+uBwCKAgAAAA==.',['双子']='双子座撒加:BAAAKgADCggIEAAAAA==.',['口水']='口水淹死你丿:BAABKgAECn8VAAIUAAgIkQBtTAAYAAAUAAgIkQBtTAAYAAAAAA==.',['古日']='古日塔嫚之花:BAACKgAFFH8LAAMRAAYIhR3BCQCqAQARAAYIhR3BCQCqAQASAAQIOhGeFgC/AAAqAAQKfycAAxEACAhoGRkhABECABEACAhoGRkhABECABIABghaBz9LANQAAAAA.',['台词']='台词而异:BAABKgAFFH8LAAIZAAMIjgIVIABhAAAZAAMIjgIVIABhAAAAAA==.',['史泰']='史泰龙:BAABKgAECn8UAAIcAAgIIxE0KgBpAQAcAAgIIxE0KgBpAQAAAA==.',['呼巫']='呼巫唬:BAAAKgAECgYIBgAAAA==.',['唐三']='唐三奈灬:BAABKgAECn8bAAMdAAcIEBmrIwCwAQAdAAcINxirIwCwAQAQAAQIbQ2acwBXAAAAAA==.',['唐棠']='唐棠:BAAAKgAECggIEgAAAA==.',['唛豆']='唛豆豆:BAAAKgAECgYICAAAAA==.',['啦啦']='啦啦滴辣:BAAAKgAECgMIAwAAAA==.',['喜羊']='喜羊羊:BAACKgAFFH8YAAIRAAQIpiTrEwA3AQARAAQIpiTrEwA3AQAqAAQKfxQAAhEACAhHIZRDAHkBABEACAhHIZRDAHkBAAAA.',['喵叽']='喵叽别:BAAAKgAFFAMIAwAAAA==.',['嘉亢']='嘉亢:BAAAKgADCggICAAAAA==.',['回家']='回家吃饭:BAACKgAFFH8HAAMRAAII5QMrLwBSAAARAAII5QMrLwBSAAAUAAEIJwUKHwAvAAAqAAQKfyUAAxQACAiJDNEoAH8BABQACAiJDNEoAH8BABEABwhsCPV3ANsAAAAA.回家补个妆:BAAAKgAECggICAAAAA==.',['困兽']='困兽的星空:BAABKgAECn8WAAIMAAgIKRdwEQDnAQAMAAgIKRdwEQDnAQAAAA==.',['圣斗']='圣斗士牛牛:BAABKgAECn8/AAIBAAgI4CIEBwDLAgABAAgI4CIEBwDLAgAAAA==.',['坏家']='坏家伙:BAAAKgAECggICAAAAA==.',['垃圾']='垃圾绿茶:BAAAKgAECgUIBQAAAA==.',['堕天']='堕天雨:BAABKgAFFH8IAAIHAAgIigAHEgBQAAAHAAgIigAHEgBQAAAAAA==.',['塞西']='塞西璃娅:BAAAKgAECgcIDQABKgAFFAMICgAIAIkIAA==.',['壹线']='壹线天:BAAAKgADCggICAAAAA==.',['夜东']='夜东篱:BAABKgAECn8mAAMeAAgIahWVCwCIAQAeAAgIahWVCwCIAQAGAAIITRGvVABqAAAAAA==.',['夜色']='夜色未央:BAAAKgADCgEIAQAAAA==.',['大圆']='大圆子丷:BAAAKgAECgMIAwAAAA==.',['大排']='大排大:BAAAKgAECgQIBAAAAA==.',['大米']='大米霸霸:BAACKgAFFH8KAAIMAAQIvhhZIAC6AAAMAAQIvhhZIAC6AAAqAAQKfyoAAgwACAh7I5UMAMACAAwACAh7I5UMAMACAAAA.',['大胖']='大胖纸:BAAAKgAECgcIBwAAAA==.',['大良']='大良蹦沙:BAAAKgAECgYIBwAAAA==.',['天使']='天使栗子球:BAAAKgAECgMIAwAAAA==.',['天命']='天命人:BAAAKgAFFAQIBAAAAA==.',['太阳']='太阳石:BAAAKgAECggIEwAAAA==.',['失落']='失落时空:BAAAKgADCgMIAwAAAA==.',['夲尐']='夲尐低调:BAABKgAFFH8IAAIFAAgIfAWOCADFAQAFAAgIfAWOCADFAQAAAA==.',['奈扎']='奈扎雷克原罪:BAAAKgAFFAQIAgAAAA==.',['奶鸡']='奶鸡的龙巴:BAACKgAFFH8QAAMXAAMILxwBCQDyAAAXAAMILxwBCQDyAAADAAEIRQgbUQAvAAAqAAQKfxcAAxcACAgwG2oSAPIBABcACAgwG2oSAPIBAAMAAgg8EFqJADwAAAAA.',['妹妹']='妹妹萌萌哒:BAAAKgAECgIIAgAAAA==.',['娜塔']='娜塔亚:BAABKgAECn8cAAMLAAgI+iEwGwCMAgALAAgI+iEwGwCMAgAOAAIItwleiwAzAAAAAA==.',['孺钦']='孺钦:BAAAKgAECggICQAAAA==.',['宇宙']='宇宙图腾:BAAAKgAECgYIBgAAAA==.',['安吉']='安吉丽娜珠丽:BAAAKgADCgcIBwAAAA==.安吉莉娜丶:BAAAKgADCggICAABKgAFFAgIBgAGABUEAA==.',['安琪']='安琪儿的微笑:BAABKgAFFH8NAAMdAAQI8RbmFwChAAAdAAMIQRbmFwChAAAPAAEIRgk/JgBHAAAAAA==.安琪儿的眼泪:BAAAKgAFFAgIBAAAAA==.',['审判']='审判者:BAAAKgAECgYIBgAAAA==.',['家康']='家康:BAAAKgAECgYIBgAAAA==.',['家慷']='家慷:BAAAKgADCgYICQAAAA==.',['寒霜']='寒霜永恒伤感:BAABKgAFFH8SAAIBAAYIXR60CgAsAQABAAYIXR60CgAsAQAAAA==.',['对吾']='对吾嘿住:BAABKgAFFH8GAAMaAAYIBRe1DgArAQAaAAUIMRq1DgArAQANAAEIkANVXgA9AAAAAA==.',['小小']='小小西瓜:BAABKgAECn8nAAMEAAgIAhbEFgCOAQAEAAgIMhTEFgCOAQACAAQI9hT9HQB/AAAAAA==.',['小爱']='小爱无言:BAAAKgADCgYIBgAAAA==.',['小疯']='小疯子打我啊:BAABKgAFFH8QAAIMAAYIoxTsFABTAQAMAAYIoxTsFABTAQAAAA==.',['小菊']='小菊花:BAAAKgAECgUIBwAAAA==.',['小貔']='小貔貅:BAAAKgAECgMIAwAAAA==.',['尛手']='尛手微凉:BAAAKgAECgcICgAAAA==.',['就爱']='就爱软妹子:BAAAKgAFFAQIBAAAAA==.',['屹丨']='屹丨饺子:BAABKgAFFH8FAAMJAAQI9wgDHQCcAAAJAAMI9wgDHQCcAAAKAAIIRQjoRgA3AAAAAA==.',['岛田']='岛田半藏:BAAAKgADCggICAAAAA==.',['年轻']='年轻的小骑士:BAAAKgAFFAQIBAAAAA==.',['应天']='应天风:BAAAKgAECgIIAgAAAA==.',['廿小']='廿小柒:BAABKgAECn8bAAIOAAgI4xmtJADgAQAOAAgI4xmtJADgAQAAAA==.',['弗莱']='弗莱奇:BAAAKgADCgEIAQAAAA==.',['张百']='张百忍:BAABKgAFFH8GAAILAAYI0B20CwC0AQALAAYI0B20CwC0AQAAAA==.',['弦月']='弦月银绒:BAAAKgAECgEIAQAAAA==.',['張豌']='張豌豆:BAABKgAECn8WAAMLAAgIbhB8fgA6AQALAAgIbhB8fgA6AQAOAAEIVwBGmwAMAAAAAA==.',['德鲁']='德鲁兮兮:BAAAKgAECggICAAAAA==.',['忆无']='忆无心:BAAAKgAECgcIBwAAAA==.',['性感']='性感小圣杯:BAAAKgAECgMIAwAAAA==.',['总有']='总有人想抓我:BAAAKgAFFAgIBAAAAA==.',['悠然']='悠然知心:BAAAKgAECgUIBQAAAA==.悠然自在:BAAAKgAECggICwAAAA==.悠然自在心:BAAAKgADCgEIAQAAAA==.悠然自心:BAAAKgADCgEIAgAAAA==.',['想喝']='想喝汽水了:BAAAKgAECgMIAwAAAA==.',['愤怒']='愤怒的小桃子:BAABKgAFFH8GAAMKAAYIIxBGGAAhAQAKAAQIXgxGGAAhAQAJAAIIrheKEwCRAAAAAA==.愤怒的小葫芦:BAAAKgAFFAIIAgAAAA==.',['慈父']='慈父史达林:BAAAKgAECgUIBQAAAA==.',['慢羊']='慢羊羊:BAACKgAFFH8OAAIfAAQI5hpKBADuAAAfAAQI5hpKBADuAAAqAAQKfxwAAh8ACAgxHcYGAMUBAB8ACAgxHcYGAMUBAAAA.',['懒羊']='懒羊羊:BAACKgAFFH8XAAMgAAgI0BEtAgAyAgAgAAgI0BEtAgAyAgATAAQIhArNDgCQAAAqAAQKfyAAAiAACAhvG4ARAOsBACAACAhvG4ARAOsBAAAA.',['战鼠']='战鼠:BAAAKgADCgEIAgAAAA==.',['战龙']='战龙之神:BAAAKgAFFAgIAgAAAA==.',['承歌']='承歌:BAABKgAFFH8OAAQPAAQIZA2LEgDPAAAPAAQIZA2LEgDPAAAdAAQI9xG6HACxAAAQAAQIMRRxKQCdAAAAAA==.',['抓狂']='抓狂的布偶猫:BAAAKgAECgMIAwAAAA==.',['折翼']='折翼乄恶魔:BAAAKgADCggICAAAAA==.',['抹茶']='抹茶冰淇淋:BAAAKgADCggICAAAAA==.',['指着']='指着太阳喊曰:BAAAKgAECgUICgAAAA==.',['按键']='按键伤人:BAAAKgAECgUIBQAAAA==.',['挤挤']='挤挤就能奶:BAAAKgADCgMIAwAAAA==.',['掂过']='掂过碌蔗:BAABKgAECn8oAAMTAAgIlA4TJwAbAQATAAgIlA4TJwAbAQAgAAYIixdELQACAQAAAA==.',['支持']='支持手艺人:BAAAKgAECgUIBQAAAA==.',['敬清']='敬清:BAAAKgAECgYIBwAAAA==.',['斡旋']='斡旋造化:BAAAKgADCgcIBwAAAA==.',['无忧']='无忧丶逍遥:BAAAKgAECgMIAwAAAA==.',['无敌']='无敌大炉石:BAAAKgAECggIEQAAAA==.无敌大牺牲:BAAAKgAECgIIAQAAAA==.无敌小钢炮:BAABKgAECn8cAAMhAAgIriLHDQCoAgAhAAgIViLHDQCoAgAJAAgISSCPIgD9AQAAAA==.',['无稽']='无稽烦忧:BAAAKgAECgEIAQAAAA==.',['无限']='无限边疆:BAAAKgAECgEIAQAAAA==.',['昆吾']='昆吾:BAAAKgAECgMIAwAAAA==.',['明月']='明月照我影:BAAAKgAFFAMIAwAAAA==.',['星空']='星空之刃:BAABKgAFFH8IAAIiAAgI/w9jBACxAQAiAAgI/w9jBACxAQAAAA==.星空之盾:BAAAKgAFFAYIBAAAAA==.',['星辰']='星辰之刄:BAABKgAFFH8MAAIKAAgI0BVGDQBvAQAKAAgI0BVGDQBvAQAAAA==.',['春秋']='春秋花叶呱:BAAAKgADCgIIAgAAAA==.',['普希']='普希尼亚斯:BAABKgAECn8nAAISAAgIVyIjDQCGAgASAAgIVyIjDQCGAgAAAA==.',['暖洋']='暖洋洋:BAACKgAFFH8bAAIGAAYISBbbCABbAQAGAAYISBbbCABbAQAqAAQKfxYAAgYACAgSHtYMAGEBAAYACAgSHtYMAGEBAAAA.',['最黑']='最黑的圣光:BAABKgAFFH8IAAIBAAgIog+RDgDvAQABAAgIog+RDgDvAQAAAA==.',['月光']='月光石:BAABKgAECn8hAAIQAAgIQSHTEABBAgAQAAgIQSHTEABBAgAAAA==.',['月羽']='月羽风行者:BAAAKgAECggIDAAAAA==.',['月逝']='月逝彼山:BAABKgAECn8aAAMMAAgIrhaGOwBkAQAMAAUI0h6GOwBkAQAZAAgImApdMgD4AAAAAA==.',['李达']='李达康:BAACKgAFFH8FAAIFAAMIyQXGKQCeAAAFAAMIyQXGKQCeAAAqAAQKfx4AAwUACAigEQwoAJ0BAAUACAigEQwoAJ0BAAQAAwh1C8Y7AG8AAAAA.',['李逍']='李逍遥:BAAAKgAECgcICgAAAA==.',['林風']='林風:BAAAKgAECgYIBwAAAA==.',['柔声']='柔声轻述:BAAAKgADCggICwAAAA==.',['格格']='格格武六月:BAABKgAFFH8KAAIGAAYINxgmCwB0AQAGAAYINxgmCwB0AQAAAA==.格格狐六月:BAABKgAFFH8GAAIRAAQI4AgQOwCZAAARAAQI4AgQOwCZAAAAAA==.',['梅塔']='梅塔利姆光线:BAABKgAFFH8OAAMBAAgIBx9DBACXAgABAAgIBx9DBACXAgATAAYIQAQxGQCuAAAAAA==.',['棋士']='棋士:BAAAKgAFFAgIBAAAAA==.',['樱岛']='樱岛有蚂蚁爬:BAABKgAFFH8IAAMJAAUIRg+KDAAEAQAJAAUIRg+KDAAEAQAKAAMIUQLBIwBiAAAAAA==.',['残酷']='残酷的大表哥:BAAAKgAECgYICQAAAA==.',['每天']='每天喝两杯:BAACKgAFFH8iAAMdAAQInSI+EAAhAQAdAAQInSI+EAAhAQAQAAQI8h/aGwDfAAAqAAQKfx0AAx0ACAg2JG4KAIECAB0ACAg2JG4KAIECABAABAi3HjZyAIgAAAAA.',['毒心']='毒心术:BAAAKgAECgYIBgAAAA==.',['永遠']='永遠的回憶:BAAAKgAECgUIBgAAAA==.',['污皇']='污皇大帝:BAAAKgAECgYIBgAAAA==.',['汤圆']='汤圆你别跑:BAAAKgAECgcICgAAAA==.',['沉睡']='沉睡的龙:BAAAKgAECggIEgAAAA==.',['沐潆']='沐潆翾:BAABKgAFFH8GAAMLAAQI4gD4YwApAAALAAEIhgL4YwApAAAOAAMIEADnWAAEAAAAAA==.',['没刺']='没刺的仙人掌:BAAAKgAECgcIBwAAAA==.',['沸羊']='沸羊羊:BAACKgAFFH8LAAIaAAQI4BhGGgDPAAAaAAQI4BhGGgDPAAAqAAQKfyQAAhoACAiKI0IFALECABoACAiKI0IFALECAAEqAAUUCAgRABoAPiMA.',['油膩']='油膩的師姐:BAABKgAFFH8GAAICAAYI4BOnCACAAQACAAYI4BOnCACAAQAAAA==.',['泛滥']='泛滥滴小年轻:BAABKgAFFH8hAAMDAAgI1SKeAQDKAgADAAgI1SKeAQDKAgAXAAIIKR4JEgBbAAAAAA==.',['泛舟']='泛舟淡水湖:BAAAKgADCggICAAAAA==.',['泥潭']='泥潭捞月光:BAACKgAFFH8MAAMaAAQIVRMXHADCAAAaAAQIVRMXHADCAAANAAQIeQ1FOwC4AAAqAAQKfzAAAw0ACAjWG80mACgCAA0ACAjWG80mACgCABoACAj4GaAiALQBAAEqAAUUCAgKABoA7RUA.',['流风']='流风轻云:BAACKgAFFH8RAAMJAAYINCECAwDZAQAJAAYI5iACAwDZAQAKAAYIkBaMEABmAQAqAAQKfx4AAwkACAgBG8UfAA4CAAkACAgBG8UfAA4CAAoAAgi7DmyBAGMAAAAA.',['消散']='消散:BAAAKgAECggICAAAAA==.',['涯岸']='涯岸:BAABKgAFFH8UAAQCAAYIiBsrBwChAQACAAYIiBsrBwChAQAFAAQIQBZEDgACAQAEAAYISgtvCADgAAAAAA==.',['淘气']='淘气:BAAAKgADCgEIAQAAAA==.',['清清']='清清草酶:BAAAKgAECgEIAQAAAA==.',['渡临']='渡临渊:BAAAKgAECgUIBQAAAA==.',['漫卷']='漫卷忧尘:BAABKgAFFH8MAAITAAQI1wFHFwA/AAATAAQI1wFHFwA/AAAAAA==.',['漫天']='漫天叶纷飞:BAABKgAECn8XAAMJAAcIOQ9wSQA/AQAJAAcIOQ9wSQA/AQAhAAIIwAJsogArAAAAAA==.',['火花']='火花带闪电:BAAAKgAECggICAAAAA==.',['火鸡']='火鸡味大锅巴:BAAAKgADCgEIAQAAAA==.',['灵机']='灵机:BAAAKgAECgEIAQAAAA==.',['炉石']='炉石塔猴噶:BAAAKgADCgEIAQAAAA==.',['無雙']='無雙蛮:BAAAKgAECgMIAwABKgAECggIIQAQAEEhAA==.',['焦油']='焦油的芬芳:BAAAKgADCggIEAAAAA==.',['熊尛']='熊尛尛:BAABKgAFFH8IAAIBAAgIRAqCEgDIAQABAAgIRAqCEgDIAQAAAA==.',['爪子']='爪子东西:BAABKgAFFH8QAAQXAAYIvxwCBQAmAQAXAAUI3RwCBQAmAQADAAUIoA86DAD/AAAWAAQI/Qz0CgDUAAAAAA==.',['爱在']='爱在那时:BAAAKgADCgQIBAAAAA==.',['爸爸']='爸爸来咯:BAAAKgAECgIIAgAAAA==.',['狂暴']='狂暴战:BAABKgAECn8YAAIFAAgI3Qy8FABmAQAFAAgI3Qy8FABmAQAAAA==.',['狂舞']='狂舞骑士:BAAAKgAECgQIBAAAAA==.',['狗子']='狗子狗子:BAAAKgAECgUICAAAAA==.',['猎丶']='猎丶人:BAAAKgAECgMIAwAAAA==.',['猎艳']='猎艳江湖:BAAAKgADCggICAAAAA==.',['猫仙']='猫仙人:BAAAKgAECgYICQAAAA==.',['玉枕']='玉枕半遮面:BAAAKgAFFAQIBAAAAA==.',['玉溪']='玉溪:BAABKgAFFH8KAAIMAAYIrBhhDAATAQAMAAYIrBhhDAATAQABKgAFFAgIBAAjAAAAAA==.',['王雪']='王雪莲:BAAAKgADCgIIAgAAAA==.',['瑞亜']='瑞亜:BAAAKgAECgUIBQAAAA==.',['瑞亞']='瑞亞:BAAAKgAECgEIAQAAAA==.',['瓢泼']='瓢泼的云:BAAAKgADCgEIAQAAAA==.',['瓦奥']='瓦奥莱特:BAACKgAFFH8GAAIQAAMIKwWwMQB/AAAQAAMIKwWwMQB/AAAqAAQKfxYAAxAACAgiEhM6AFQBABAACAgiEhM6AFQBAB0AAgjzD1tlAGgAAAAA.',['略略']='略略暗战战:BAAAKgAECgUIBQAAAA==.略略熊猫猫:BAAAKgAECgMIAwAAAA==.',['看我']='看我眼神:BAAAKgAFFAQIBAAAAA==.',['看见']='看见不重要:BAAAKgAECgMIAwAAAA==.',['破晓']='破晓晨光:BAACKgAFFH8bAAMEAAgI7g5vAwCBAQAEAAgI7g5vAwCBAQACAAQIjwm7GgC1AAAqAAQKfzEAAwIACAhIG6cTAPUBAAIACAg+G6cTAPUBAAQABAg+DzU3AGcAAAAA.',['破灭']='破灭的怀念:BAAAKgAFFAYIAQABKgAFFAgICwAIADsUAA==.',['磷叶']='磷叶石:BAACKgAFFH8JAAILAAMI5RZxKgCnAAALAAMI5RZxKgCnAAAqAAQKfzUAAwsACAhcJMgNAM0CAAsACAhcJMgNAM0CACQAAgg+F+caAFUAAAAA.',['神将']='神将飞蓬:BAACKgAFFH8eAAIlAAQIIQ+2BADAAAAlAAQIIQ+2BADAAAAqAAQKfyYAAyUACAgZGxoNABUCACUACAgZGxoNABUCABUAAghmBmNJADkAAAAA.',['神灬']='神灬话:BAAAKgAECgcICAAAAA==.',['禺影']='禺影:BAAAKgADCgYIBQAAAA==.',['立秋']='立秋丷:BAABKgAFFH8GAAIFAAYIBAM4FgAJAQAFAAYIBAM4FgAJAQAAAA==.立秋骑:BAABKgAFFH8IAAIBAAgInQhsDgC7AQABAAgInQhsDgC7AQAAAA==.',['竹里']='竹里明日香:BAAAKgADCgQIBAAAAA==.',['笨鸟']='笨鸟也能高飞:BAAAKgAECgEIAQAAAA==.',['米果']='米果天天开心:BAAAKgADCggIGwAAAA==.',['终不']='终不似少年油:BAAAKgAECggIDwAAAA==.',['给爱']='给爱加点糖:BAABKgAFFH8GAAIBAAYIpg1aIwBeAQABAAYIpg1aIwBeAQAAAA==.',['绞肉']='绞肉车:BAABKgAECn8XAAIiAAgI+yHuBgCuAgAiAAgI+yHuBgCuAgAAAA==.',['翔地']='翔地天空:BAABKgAFFH8KAAICAAYImBc2BwD1AAACAAYImBc2BwD1AAAAAA==.',['老仙']='老仙男:BAAAKgAFFAEIAQAAAA==.',['老白']='老白已戒酒丶:BAACKgAFFH8IAAMJAAMI6Ai5DQC8AAAJAAMI6Ai5DQC8AAAhAAMITALBLwCLAAAqAAQKfxYABAoACAiLCjAWAPkAACEACAgXBntYABQBAAoABQh8DTAWAPkAAAkABAgRBP5vAEkAAAAA.',['胡子']='胡子好粗:BAAAKgAECgEIAQAAAA==.',['芙蕾']='芙蕾娅:BAAAKgAECgMIAwAAAA==.',['芦笙']='芦笙:BAACKgAFFH8QAAIYAAQINBqyBADWAAAYAAQINBqyBADWAAAqAAQKfyoAAhgACAjNGVsIAPYBABgACAjNGVsIAPYBAAAA.',['花丛']='花丛丶:BAAAKgAECgIIBAAAAA==.',['花中']='花中取蕊:BAAAKgADCgEIAQAAAA==.',['苏叶']='苏叶:BAAAKgAECgIIBAABKgAFFAMIBgAbAM8QAA==.',['苏尐']='苏尐懒:BAAAKgADCgEIAQAAAA==.',['苏州']='苏州食尸鬼:BAAAKgADCgcIBwAAAA==.',['苏晓']='苏晓懒:BAAAKgAECggICQAAAA==.',['苏筱']='苏筱叶:BAACKgAFFH8GAAIbAAMIzxC0BgDSAAAbAAMIzxC0BgDSAAAqAAQKfyEABBsACAgoFUsQAHoBABsABwhRFksQAHoBABoACAiCEiQ4ADYBABgAAghvDIIpAFcAAAAA.',['苒苒']='苒苒:BAAAKgAECggIEgAAAA==.',['茉莉']='茉莉乌龙茶:BAAAKgAFFAIIAgAAAA==.',['茕兔']='茕兔眠眠:BAAAKgAECgMIAwAAAA==.',['荷兰']='荷兰外墙玫瑰:BAAAKgADCgEIAQAAAA==.',['荷包']='荷包丹:BAAAKgAECggICAAAAA==.',['莹仔']='莹仔别打瞌睡:BAAAKgADCggICAAAAA==.',['萌妹']='萌妹球:BAABKgAFFH8MAAIVAAgI7B0dAgCzAgAVAAgI7B0dAgCzAgAAAA==.',['萌萌']='萌萌的蹄子:BAAAKgAECggICAAAAA==.',['萨其']='萨其马马:BAAAKgADCggICAAAAA==.',['葡萄']='葡萄成熟时:BAAAKgAECggIEgAAAA==.',['蓝篮']='蓝篮路:BAABKgAECn8+AAINAAgI4yEJEQCiAgANAAgI4yEJEQCiAgAAAA==.',['蓝莓']='蓝莓麦酥:BAAAKgADCgUICgAAAA==.',['蓬莱']='蓬莱人形:BAAAKgADCgYIBgAAAA==.',['虚空']='虚空发丝:BAAAKgADCggICAAAAA==.',['虾饺']='虾饺妈:BAAAKgAECgMIAwAAAA==.',['蛋蛋']='蛋蛋终结者:BAAAKgAECggICAAAAA==.',['融化']='融化的一滩水:BAAAKgAECggICAAAAA==.',['血兽']='血兽走了:BAABKgAFFH8GAAIIAAYILhBGFgBqAQAIAAYILhBGFgBqAQAAAA==.',['袍师']='袍师:BAAAKgADCgEIAQAAAA==.',['被剥']='被剥削噶肥鸡:BAAAKgADCgcIBwAAAA==.',['裂痕']='裂痕:BAAAKgAECggIDAAAAA==.',['装饭']='装饭的桶:BAAAKgAFFAQIBAAAAA==.',['见光']='见光死:BAAAKgAECgYIBgAAAA==.',['让我']='让我躺着:BAAAKgAECgcIEgAAAA==.',['象饼']='象饼干:BAACKgAFFH8dAAIBAAQINCWmMwAbAQABAAQINCWmMwAbAQAqAAQKfzkAAgEACAioJTMLAO0CAAEACAioJTMLAO0CAAAA.',['贝蕾']='贝蕾瑞娅:BAAAKgAFFAIIAgAAAA==.',['踏风']='踏风而行:BAABKgAFFH8NAAIGAAgIcRD5BgCWAQAGAAgIcRD5BgCWAQAAAA==.',['蹬晃']='蹬晃:BAAAKgADCggICAAAAA==.',['辉煌']='辉煌丨镭:BAAAKgADCgQIBAAAAA==.',['这是']='这是怎么个事:BAAAKgAFFAYIAwAAAA==.',['迪科']='迪科小野:BAABKgAECn8aAAIiAAgIzhErHQBkAQAiAAgIzhErHQBkAQAAAA==.',['迷人']='迷人的妖妖:BAAAKgADCgYIBgAAAA==.',['迷踪']='迷踪谍影:BAAAKgAECggICAAAAA==.',['追寻']='追寻回忆:BAAAKgAECgQIBAAAAA==.',['部落']='部落頭號通緝:BAABKgAECn8ZAAIgAAgInhVjFQDFAQAgAAgInhVjFQDFAQAAAA==.',['酒仙']='酒仙满:BAAAKgADCggICAAAAA==.',['重生']='重生的陌蓝:BAAAKgAECgYIDAAAAA==.',['银河']='银河星落:BAACKgAFFH8IAAIIAAMIiRBdMwDIAAAIAAMIiRBdMwDIAAAqAAQKfysAAggACAieGTgqANYBAAgACAieGTgqANYBAAAA.',['长沙']='长沙吴彦祖:BAAAKgAECggICAAAAA==.',['问就']='问就三秒:BAAAKgAECgEIAQAAAA==.',['阿克']='阿克萌德:BAABKgAECn8VAAQNAAgIGxMPSQCIAQANAAcI5xQPSQCIAQAYAAYIuwc1LwB3AAAaAAEILQXDggAcAAAAAA==.',['阿尔']='阿尔雅:BAABKgAFFH8dAAIBAAYI2h2QCwAnAQABAAYI2h2QCwAnAQABKgAFFAgIJQAMAEgfAA==.',['阿牛']='阿牛弟:BAABKgAECn8WAAMLAAgIjhRYPwCpAQALAAgI4BNYPwCpAQAOAAMIeBHZcwCbAAAAAA==.',['霍比']='霍比特矮子:BAABKgAFFH8WAAIDAAgIgB+bAgCYAgADAAgIgB+bAgCYAgAAAA==.',['顶不']='顶不住也得顶:BAAAKgADCgIIAgAAAA==.',['風之']='風之旅:BAAAKgAFFAQIBAAAAA==.',['风烟']='风烟愺树:BAACKgAFFH8ZAAICAAMIIR4lEQACAQACAAMIIR4lEQACAQAqAAQKfygAAgIACAi2HqALAGoCAAIACAi2HqALAGoCAAAA.',['飞虎']='飞虎神鹰:BAACKgAFFH8GAAMOAAMIBQtMGQCeAAAOAAMIBQtMGQCeAAALAAIIPgX4KABhAAAqAAQKfx8AAw4ACAj9GK4iAO0BAA4ACAj9GK4iAO0BAAsABQilCOvDAJ4AAAAA.',['饭多']='饭多二号:BAAAKgADCgIIAgAAAA==.',['饼干']='饼干总代理:BAAAKgAECgQIBAAAAA==.',['鬼头']='鬼头:BAAAKgAECggICAAAAA==.',['鬼虎']='鬼虎之魂:BAAAKgAFFAQIBAAAAA==.',['鹰阵']='鹰阵的骑士:BAACKgAFFH8IAAIgAAMIoRLMDwDDAAAgAAMIoRLMDwDDAAAqAAQKfxgAAiAACAiqE2MaAI8BACAACAiqE2MaAI8BAAAA.',['麒麟']='麒麟儿:BAAAKgAECgYIDQAAAA==.',['麻辣']='麻辣串串:BAAAKgAECgYIBgAAAA==.',['黎明']='黎明使者:BAAAKgAFFAYIAgAAAA==.',['黑剑']='黑剑:BAAAKgAFFAMIAwAAAA==.',['黑山']='黑山老妖怪:BAABKgAFFH8HAAINAAcIehyyCQD6AQANAAcIehyyCQD6AQABKgAFFAgIBAAjAAAAAA==.',['黯香']='黯香疏影:BAACKgAFFH8GAAIMAAMIwQudHQClAAAMAAMIwQudHQClAAAqAAQKfx4AAgwACAjfE1gxAJgBAAwACAjfE1gxAJgBAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end