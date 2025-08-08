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
 local lookup = {'Warrior-Fury','Warrior-Arms','DeathKnight-Blood','DeathKnight-Unholy','Druid-Balance','Paladin-Retribution','Monk-Mistweaver','Mage-Fire','Mage-Frost','Warlock-Destruction','Priest-Shadow','Priest-Discipline','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Windwalker','Unknown-Unknown','Warlock-Demonology','Druid-Restoration','Mage-Arcane','DeathKnight-Frost','Druid-Guardian','Paladin-Holy','Paladin-Protection','Warrior-Protection','Shaman-Enhancement','Priest-Holy',}; local provider = {region='CN',realm='织亡者',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Along:BAAAKgAECgcICgAAAA==.',Ar='Aris:BAABKgAFFH8RAAMBAAYImBKpDwBbAQABAAUIyRGpDwBbAQACAAEInhZJKABOAAABKgAFFAgIBgABABcZAA==.',Da='Daixudk:BAABKgAFFH8HAAMDAAUIhwnuIgCQAAADAAMIowvuIgCQAAAEAAIIXQYmRACOAAAAAA==.',De='Ded:BAABKgAFFH8GAAIFAAYINw3eGwA7AQAFAAYINw3eGwA7AQAAAA==.',Di='Dier:BAAAKgADCgQIBAAAAA==.',Dk='Dkill:BAABKgAECn8WAAIEAAgIISJmDACqAgAEAAgIISJmDACqAgAAAA==.',El='Elitaeca:BAABKgAECn8aAAIGAAgIWST5EQDPAgAGAAgIWST5EQDPAgAAAA==.',Fa='Fattytuna:BAABKgAFFH8KAAIHAAYIdAtzBAB0AQAHAAYIdAtzBAB0AQAAAA==.',Ic='Icywind:BAABKgAFFH8QAAMIAAYIBxZ6CQBiAQAIAAYIfwd6CQBiAQAJAAQIKSFaDADLAAAAAA==.',Jo='Joker:BAABKgAECn8iAAIKAAgIbRzRFgA6AgAKAAgIbRzRFgA6AgAAAA==.',Li='Liar:BAAAKgADCgEIAQAAAA==.',Lm='Lmunan:BAABKgAFFH8GAAIGAAYI8w7BWgC8AAAGAAYI8w7BWgC8AAAAAA==.',Lu='Luckyxing:BAAAKgAECggIDwAAAA==.Luckyxue:BAAAKgAECggIDwAAAA==.',St='Strelitzia:BAABKgAFFH8MAAMLAAYIExunAgCwAQALAAYIExunAgCwAQAMAAQIiBlnCQALAQAAAA==.',Th='Theworld:BAAAKgAECggIBgAAAA==.',To='Tot:BAABKgAFFH8lAAMNAAYIiBBGEQBLAQANAAYIiBBGEQBLAQAOAAQI0RMjCwDWAAABKgAFFAgICAANALsbAA==.Toxwind:BAABKgAFFH8MAAIBAAYIQxpGAQDLAQABAAYIQxpGAQDLAQAAAA==.',Ve='Venom:BAABKgAFFH8MAAMPAAYInhlpAQDIAQAPAAYInhlpAQDIAQAQAAIIxBGaDQCNAAAAAA==.',Vi='Viento:BAABKgAFFH8MAAIRAAYI3xNVAwCwAQARAAYI3xNVAwCwAQAAAA==.Vitaminb:BAAAKgAECgEIAQAAAA==.',Wi='Windflower:BAABKgAFFH8GAAMSAAYIcRLLFQCzAAASAAQIcQvLFQCzAAATAAII7xxMQgCWAAAAAA==.',Xo='Xoo:BAABKgAFFH8KAAIFAAYIuxKFAwCQAQAFAAYIuxKFAwCQAQAAAA==.',['一曰']='一曰三疯:BAAAKgADCggICAAAAA==.',['万乜']='万乜乜万:BAAAKgAECgIIAgAAAA==.',['三碗']='三碗土豆粉:BAAAKgAECggICAAAAA==.',['丨速']='丨速度兄丨:BAAAKgAECgIIAQAAAA==.',['丶旧']='丶旧屿:BAAAKgADCgEIAQAAAA==.',['丶颜']='丶颜颜丶:BAAAKgAECgYICAAAAA==.',['丶龙']='丶龙戰士:BAAAKgAFFAEIAQAAAA==.',['丿丶']='丿丶刂:BAABKgAFFH8XAAIIAAUIpQwjFgACAQAIAAUIpQwjFgACAQAAAA==.',['亮一']='亮一亮静一静:BAACKgAFFH8NAAMTAAUIFRdQLgDPAAATAAMImxVQLgDPAAASAAIIShndNACfAAAqAAQKfyAAAhMACAhwFd5HAN0BABMACAhwFd5HAN0BAAAA.',['伊利']='伊利蛋蛋:BAAAKgAECggIDgAAAA==.',['伊綾']='伊綾:BAAAKgAECgIIAgAAAA==.',['优质']='优质蛋白质:BAAAKgAFFAQIBAAAAA==.',['传奇']='传奇射手:BAAAKgAECgIIAgAAAA==.',['低調']='低調的小艾:BAAAKgADCggICAAAAA==.',['倾颜']='倾颜笑:BAAAKgAECggICAAAAA==.',['八神']='八神疾风:BAAAKgADCgUICQAAAA==.',['冰冷']='冰冷的骑士:BAAAKgAECgMIBQAAAA==.',['刃物']='刃物息无声:BAAAKgAECgEIAgAAAA==.',['加不']='加不起快点跑:BAAAKgAFFAIIAgAAAA==.',['加尔']='加尔鲁什酋长:BAAAKgAECgEIAgAAAA==.',['十二']='十二月的猫猫:BAACKgAFFH8IAAIUAAYIIx3yAAD9AQAUAAYIIx3yAAD9AQAqAAQKfxwAAhQABwjHGVAdALMBABQABwjHGVAdALMBAAAA.',['升龙']='升龙旺旺:BAAAKgAECgIIAgAAAA==.',['叄川']='叄川樱雯:BAABKgAFFH8GAAIRAAYIiAuoGAA3AQARAAYIiAuoGAA3AQAAAA==.',['又挨']='又挨骂咯:BAAAKgAFFAUIBAABKgAFFAgIBAAVAAAAAA==.',['反方']='反方向的钟:BAAAKgADCgEIAQAAAA==.',['可乐']='可乐不加冰:BAAAKgADCggICAAAAA==.',['司徒']='司徒厄:BAABKgAFFH8IAAITAAgI1w90CgDHAQATAAgI1w90CgDHAQAAAA==.',['吱毛']='吱毛:BAABKgAFFH8IAAIGAAgIrROfDAADAgAGAAgIrROfDAADAgAAAA==.',['周壹']='周壹不想睡觉:BAABKgAFFH8FAAIWAAMI6RaIEgCtAAAWAAMI6RaIEgCtAAAAAA==.周壹的德:BAABKgAFFH8IAAIXAAgITgfoCAB5AQAXAAgITgfoCAB5AQAAAA==.周壹老师:BAABKgAECn8bAAINAAgIoRgkJgDpAQANAAgIoRgkJgDpAQAAAA==.',['周师']='周师傅:BAAAKgAECgQIBgAAAA==.',['周无']='周无心:BAAAKgAFFAEIAQAAAA==.',['咕嘟']='咕嘟咕嘟咕嘟:BAAAKgADCggICAAAAA==.',['咕德']='咕德喵咛:BAAAKgADCggICAAAAA==.',['哇传']='哇传说:BAACKgAFFH8KAAINAAQI4CBmCQAMAQANAAQI4CBmCQAMAQAqAAQKfz8AAg0ACAhTJtEDAN0CAA0ACAhTJtEDAN0CAAAA.',['啊哈']='啊哈哈:BAAAKgAECgMIAwAAAA==.',['喜雨']='喜雨林塘:BAAAKgADCggICAAAAA==.',['囧囧']='囧囧滴潴潴:BAAAKgADCggICAABKgAFFAUIFgANAJMJAA==.',['圣旺']='圣旺旺:BAABKgAFFH8FAAIGAAUITBpILwArAQAGAAUITBpILwArAQAAAA==.',['地精']='地精萨满:BAAAKgAFFAEIAQAAAA==.',['坤哥']='坤哥:BAABKgAFFH8JAAIEAAIIJRHEIwCXAAAEAAIIJRHEIwCXAAAAAA==.',['基督']='基督山伯爵:BAAAKgAECgYICgAAAA==.',['夜的']='夜的第七章丶:BAAAKgAECgEIAQAAAA==.',['夜隼']='夜隼:BAAAKgAECgEIAQAAAA==.',['大白']='大白菜:BAAAKgAECgUICwAAAA==.',['大雨']='大雨过后:BAABKgAFFH8GAAIJAAII+BIzIwB0AAAJAAII+BIzIwB0AAAAAA==.',['天一']='天一宝贝:BAAAKgADCgEIAQAAAA==.',['奎尔']='奎尔萨斯王子:BAAAKgAFFAEIAQAAAA==.',['寒冰']='寒冰丨飞龙:BAAAKgAECgIIAgAAAA==.',['小小']='小小神:BAABKgAFFH8GAAIBAAQIAhvEDgAAAQABAAQIAhvEDgAAAQAAAA==.',['小毛']='小毛毛熊:BAAAKgAECgMIAwAAAA==.',['小病']='小病人丶:BAAAKgAECggIEAAAAA==.',['小舅']='小舅:BAAAKgAECgcIDgAAAA==.',['小黄']='小黄兔:BAAAKgAECgEIAQAAAA==.',['小龙']='小龙神:BAAAKgAECggICAAAAA==.',['岳绮']='岳绮罗丶:BAAAKgADCgEIAgAAAA==.',['巴洛']='巴洛斯:BAACKgAFFH8LAAITAAMIIwvqHQCuAAATAAMIIwvqHQCuAAAqAAQKfyAAAhMACAgrILcjACoCABMACAgrILcjACoCAAAA.',['市井']='市井小贼:BAAAKgAECggICAAAAA==.',['带我']='带我去流浪:BAAAKgAECgMIAwAAAA==.',['康熙']='康熙大帝:BAABKgAFFH8GAAIKAAQIHwg0NgCXAAAKAAQIHwg0NgCXAAAAAA==.',['张能']='张能能:BAACKgAFFH8IAAIJAAII6h5IEgCXAAAJAAII6h5IEgCXAAAqAAQKfx8ABAkACAiwIkcLAIQCAAkACAiwIkcLAIQCABgABQi1F3NOAAQBAAgAAQg9ChebADkAAAAA.',['彭于']='彭于晏:BAAAKgAECggICAAAAA==.',['往佑']='往佑走打怪兽:BAACKgAFFH8XAAIZAAYInAZ5BgAcAQAZAAYInAZ5BgAcAQAqAAQKfxYAAhkACAjuDfMRAHYBABkACAjuDfMRAHYBAAAA.',['待续']='待续:BAAAKgAFFAQIBAAAAA==.',['怒风']='怒风丶左耳:BAACKgAFFH8ZAAQXAAUIaCKGCACBAQAXAAUIaCKGCACBAQAFAAMIRwvyKgCJAAAaAAEIQxGeBwAxAAAqAAQKfxQAAxcACAgrE801AEIBABcACAgrE801AEIBABoAAQjXHFYqAFMAAAAA.',['怵歪']='怵歪:BAACKgAFFH8GAAIGAAIIEQmFewByAAAGAAIIEQmFewByAAAqAAQKfxwAAxsABwiODrA5ALUAABsABgiyCbA5ALUAAAYAAwiyEeDhAJ0AAAAA.',['愿圣']='愿圣光照死你:BAABKgAECn8tAAIGAAgINyTPDgDTAgAGAAgINyTPDgDTAgAAAA==.',['憨厚']='憨厚小脸猫:BAACKgAFFH8JAAQJAAYIqwsXCwDWAAAJAAQIvBEXCwDWAAAYAAMIygKBOQB8AAAIAAIIkwIwKwBpAAAqAAQKfx4AAxgACAgwH1cHAHMCABgACAjJHVcHAHMCAAkACAj6GxQrAM0BAAAA.',['我射']='我射的贼准:BAABKgAFFH8FAAISAAUIqBHrHgD9AAASAAUIqBHrHgD9AAAAAA==.',['扁鹊']='扁鹊:BAAAKgADCgYIBgAAAA==.',['打拳']='打拳小王:BAAAKgAECgEIAQAAAA==.',['托兰']='托兰斯提安:BAAAKgAFFAMIAwAAAA==.',['抬头']='抬头就放毒:BAAAKgAECgQIBgAAAA==.',['搞不']='搞不懂吧:BAABKgAFFH8JAAIcAAMIagxAHgCJAAAcAAMIagxAHgCJAAAAAA==.',['改天']='改天我请:BAAAKgAFFAYIAgAAAA==.',['斯派']='斯派克:BAAAKgAECgYIBgAAAA==.',['无敌']='无敌嘉宝:BAAAKgAECgUIBwAAAA==.',['旧城']='旧城忆流年:BAAAKgAECgYICQAAAA==.',['晨舸']='晨舸:BAAAKgAECgYIBwAAAA==.',['暴力']='暴力的美学:BAABKgAECn8YAAICAAYIWRgBJgCJAQACAAYIWRgBJgCJAQAAAA==.',['最后']='最后的磐石:BAABKgAFFH8IAAICAAgI6CIzAQC3AgACAAgI6CIzAQC3AgAAAA==.',['朋克']='朋克飛:BAAAKgAECgEIAwAAAA==.',['枫叶']='枫叶:BAAAKgAECggIEwAAAA==.',['柳如']='柳如烟丶:BAAAKgAECgMIAwAAAA==.',['栖凤']='栖凤渡:BAAAKgADCggICAAAAA==.',['桀骜']='桀骜小妖怪:BAAAKgAECgEIAQAAAA==.',['梅塔']='梅塔特珑:BAAAKgADCgMIAwAAAA==.',['橘色']='橘色的猫:BAAAKgAECgcIBwAAAA==.',['死灵']='死灵战骑:BAAAKgAECggIEgAAAA==.',['毛毛']='毛毛穷:BAAAKgAFFAQIBAAAAA==.',['法誓']='法誓:BAAAKgAFFAEIAQAAAA==.',['泪泪']='泪泪酱:BAABKgAFFH8FAAIJAAMILgrXHACdAAAJAAMILgrXHACdAAAAAA==.',['泰瑞']='泰瑞利亚:BAAAKgAECgMIAgAAAA==.',['洛克']='洛克马丁尼:BAAAKgADCgYIBgAAAA==.',['海洋']='海洋王子:BAAAKgAECggICgAAAA==.',['深丶']='深丶蓝:BAAAKgAECggIAQAAAA==.',['清风']='清风之浩泽:BAAAKgAFFAQIBAAAAA==.清风之铭浩:BAAAKgAECgQIBAAAAA==.',['满达']='满达:BAAAKgADCggICAAAAA==.',['激萌']='激萌小宝贝:BAABKgAFFH8FAAIFAAUIUBUJGwBBAQAFAAUIUBUJGwBBAQAAAA==.',['火灬']='火灬雨:BAABKgAFFH8JAAIKAAMImBHaFwDBAAAKAAMImBHaFwDBAAAAAA==.',['牛一']='牛一牛:BAAAKgAECgEIAQAAAA==.',['牛仔']='牛仔酷:BAAAKgADCggICAAAAA==.',['狐猎']='狐猎咋个玩:BAAAKgAFFAQIBAAAAA==.',['玉千']='玉千荨:BAAAKgAECgIIAgAAAA==.',['王灵']='王灵官:BAAAKgAECgMIBAAAAA==.',['痞子']='痞子锋:BAAAKgAFFAEIAQAAAA==.',['白菜']='白菜的驯兽思:BAACKgAFFH8XAAMSAAYIpAqEEQDkAAASAAYIpAqEEQDkAAATAAEIBQlZYAA1AAAqAAQKfxYAAxMACAgvEA9kAIUBABMACAgvEA9kAIUBABIAAQiQBySXABwAAAAA.',['盾白']='盾白菜:BAABKgAFFH8XAAIdAAYI0Q4lBQACAQAdAAYI0Q4lBQACAQAAAA==.',['真谛']='真谛:BAAAKgAFFAYIBAAAAA==.',['矮大']='矮大紧:BAACKgAFFH8OAAIGAAMIPxKCUADPAAAGAAMIPxKCUADPAAAqAAQKfxkAAwYACAgvE0VqAIUBAAYACAgvE0VqAIUBABwACAi9BHo7AJkAAAAA.',['祭灬']='祭灬祀:BAACKgAFFH8UAAMOAAMI4B1XCwDYAAAeAAMIQBoMDgDsAAAOAAMIAhpXCwDYAAAqAAQKfxQAAg4ABgjLH6MxAH0BAA4ABgjLH6MxAH0BAAAA.',['稀稀']='稀稀饭:BAAAKgAECgMIAwAAAA==.',['空谷']='空谷僧哥:BAAAKgAFFAIIAgAAAA==.',['第九']='第九:BAABKgAFFH8PAAIXAAMI2QVrKgB4AAAXAAMI2QVrKgB4AAAAAA==.',['箭灬']='箭灬雨:BAAAKgAECgQIAgAAAA==.',['糖果']='糖果屋的幽灵:BAABKgAFFH8WAAMfAAgIsx4WAwAxAgAfAAgIsx4WAwAxAgAMAAIIfAuhHwB+AAAAAA==.',['索灬']='索灬隆:BAABKgAFFH8TAAIGAAMIciIZMwAdAQAGAAMIciIZMwAdAQAAAA==.',['紫旺']='紫旺旺:BAABKgAFFH8GAAIKAAYI5hXaGgAvAQAKAAYI5hXaGgAvAQAAAA==.',['纏綿']='纏綿丶丶:BAAAKgAECgUIBQAAAA==.',['红牛']='红牛:BAAAKgAFFAQIBAAAAA==.',['给你']='给你一瓶可乐:BAABKgAFFH8KAAMSAAcIcBlSCQD9AAASAAcIcBlSCQD9AAATAAMIcRN7OwB9AAABKgAFFAgIEQAMADMcAA==.',['翼川']='翼川樱雯:BAAAKgAFFAMIAwAAAA==.',['老吴']='老吴之家:BAAAKgAECgYICgAAAA==.老吴之恶:BAAAKgAECgYIBgAAAA==.老吴在家:BAAAKgAECgYICwAAAA==.老吴归来:BAAAKgAECgYICQAAAA==.老吴爱人:BAAAKgAECgIIAgAAAA==.老吴看海:BAAAKgAECgQIBwAAAA==.老吴铁律:BAAAKgADCgYIBgAAAA==.',['老舅']='老舅:BAAAKgADCgMIAwAAAA==.',['老诺']='老诺德术:BAAAKgAECgYIBgAAAA==.',['胖胖']='胖胖小盼:BAAAKgAFFAIIAwAAAA==.',['胡芦']='胡芦娃:BAAAKgAECggICwAAAA==.',['舞川']='舞川樱雯:BAAAKgAECggICAAAAA==.',['艾莉']='艾莉:BAAAKgAECgcIBwAAAA==.',['芊芊']='芊芊:BAAAKgADCgYIBgAAAA==.',['花样']='花样华年:BAAAKgAECgIIAgAAAA==.',['花间']='花间酒:BAAAKgAFFAgIBAAAAA==.',['英语']='英语龙:BAAAKgAECgUIBQABKgAFFAQICgANAOAgAA==.',['蕉太']='蕉太狼:BAAAKgAFFAIIAwAAAA==.蕉太狼二号:BAAAKgAFFAIIAwAAAA==.',['血红']='血红色的右手:BAAAKgADCgEIAQAAAA==.',['西瓜']='西瓜太妹:BAAAKgAECgIIAgAAAA==.西瓜子:BAAAKgAECgIIAQAAAA==.',['谁记']='谁记得危安:BAAAKgADCgcIBwAAAA==.',['貌似']='貌似我还好丶:BAAAKgAECgIIAgAAAA==.',['贝拉']='贝拉:BAAAKgAECgcIBwAAAA==.',['赵子']='赵子龙:BAAAKgADCggICAAAAA==.',['軒轅']='軒轅丨申公豹:BAAAKgAFFAMIAwAAAA==.',['退堂']='退堂鼓大王:BAAAKgAECggICgAAAA==.',['速度']='速度射掉:BAAAKgAECgYICQAAAA==.',['那瓜']='那瓜那潴那鳖:BAACKgAFFH8WAAINAAUIkwm/FwC3AAANAAUIkwm/FwC3AAAqAAQKfxYAAg0ACAjREZFBAIABAA0ACAjREZFBAIABAAAA.',['铁甲']='铁甲丶依然在:BAABKgAFFH8GAAIGAAYI2hDlHwBwAQAGAAYI2hDlHwBwAQAAAA==.',['防骑']='防骑兴星:BAAAKgAFFAEIAQAAAA==.',['阿达']='阿达尔之手:BAAAKgAECgcICwAAAA==.',['陸噵']='陸噵論囬:BAAAKgAECgYICAAAAA==.',['随风']='随风的细尘:BAAAKgAFFAMIAwAAAA==.',['雨歇']='雨歇微凉:BAAAKgAECggIDgAAAA==.',['青紫']='青紫色的奶牛:BAAAKgADCgMIAwAAAA==.',['静婧']='静婧:BAABKgAFFH8IAAIKAAgIvQuLCADZAQAKAAgIvQuLCADZAQAAAA==.',['風殤']='風殤丨宇涵:BAAAKgADCgYIBgAAAA==.',['风之']='风之歩影:BAABKgAFFH8GAAIGAAYIniMRFQCzAQAGAAYIniMRFQCzAQAAAA==.',['风吹']='风吹乱了你我:BAACKgAFFH8GAAIFAAYIrBnXEgCGAQAFAAYIrBnXEgCGAQAqAAQKfxUAAgUABghSFYxnACcBAAUABghSFYxnACcBAAAA.风吹半夏:BAAAKgAECgcICwAAAA==.',['风和']='风和煦:BAABKgAFFH8IAAMTAAQI6A7+HAAdAQATAAQIjQv+HAAdAQASAAQIRQzoGgAWAQAAAA==.',['风影']='风影炫动:BAAAKgAFFAEIAQAAAA==.',['饭饭']='饭饭猫:BAAAKgAECgIIAwAAAA==.',['香香']='香香:BAABKgAFFH8IAAIRAAgIrhC+CAD8AQARAAgIrhC+CAD8AQAAAA==.',['鬼夜']='鬼夜号角:BAAAKgAECgYIBgAAAA==.',['魑魅']='魑魅波:BAABKgAFFH8UAAMBAAUIURL5DQBzAQABAAUIDhL5DQBzAQAdAAMIDQxDDwCFAAAAAA==.',['鲁克']='鲁克丶:BAAAKgAFFAEIAQAAAA==.',['鸡丶']='鸡丶你太美:BAAAKgADCgEIAgAAAA==.',['黎明']='黎明前的疯狂:BAAAKgADCggICAAAAA==.',['黑色']='黑色的猫:BAACKgAFFH8TAAQfAAgIYyHsAgApAgAfAAcIhyDsAgApAgALAAQIgwUVFgCzAAAMAAIIwBAsIACiAAAqAAQKfygABAsACAhlGF4bAPwBAAsACAhlGF4bAPwBAAwAAwjQDXtxAHMAAB8AAgiLCEWTADMAAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end