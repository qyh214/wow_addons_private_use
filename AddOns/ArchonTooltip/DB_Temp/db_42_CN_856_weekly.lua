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
 local lookup = {'Druid-Balance','Druid-Restoration','Unknown-Unknown','DeathKnight-Unholy','Monk-Windwalker','Rogue-Subtlety','Shaman-Restoration','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Frost','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Priest-Shadow','Priest-Holy','Rogue-Assassination','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Discipline','Evoker-Devastation','Druid-Feral','Druid-Guardian','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Warrior-Protection','Warrior-Fury','Mage-Fire','Mage-Arcane','Shaman-Elemental','Monk-Mistweaver','Evoker-Preservation','Warrior-Arms','Shaman-Enhancement','Monk-Brewmaster','Rogue-Outlaw','Evoker-Augmentation','DeathKnight-Frost','DeathKnight-Blood',}; local provider = {region='CN',realm='银月',name='CN',type='weekly',zone=42,date='2025-08-03',data={Aa='Aan:BAACKgAFFH8KAAIBAAMIQguNQACpAAABAAMIQguNQACpAAAqAAQKfxsAAwIACAhEGcwYAP4BAAIACAhEGcwYAP4BAAEABQgjHr8/ALcBAAAA.',Ab='Abijahq:BAAAKgAECgcICAABKgAECggIDAADAAAAAA==.',Al='Alaric:BAAAKgAECggIDAAAAA==.',An='Andsun:BAAAKgAECgcIDgABKgAFFAMICwAEABoZAA==.Anian:BAABKgAFFH8LAAIEAAMIGhnXKgDhAAAEAAMIGhnXKgDhAAAAAA==.',Ap='Aprilstory:BAAAKgAFFAQIBAABKgAFFAgIAgADAAAAAA==.',Av='Avanna:BAAAKgAECggICAAAAA==.',Br='Breeze:BAAAKgAECggICAAAAA==.',Co='Cooper:BAAAKgAECgEIAQAAAA==.',Cp='Cpcianes:BAAAKgAECgQIBQAAAA==.',Cs='Csl:BAAAKgAFFAQIBAAAAA==.',De='Der:BAAAKgAECgMIAwABKgAFFAgIDgAFALwMAA==.',Di='Didar:BAAAKgAFFAYIAQAAAA==.',Ec='Echocho:BAAAKgAFFAQIBAABKgAFFAgIBgAGAAQQAA==.',Er='Ericartman:BAABKgAECn8jAAIHAAgIZRyUHgARAgAHAAgIZRyUHgARAgAAAA==.',Ev='Evildora:BAACKgAFFH8cAAMIAAYIGRcACAAhAQAIAAYIyBIACAAhAQAJAAMIshr7JQDgAAAqAAQKf00AAgkACAgMI7kIAMcCAAkACAgMI7kIAMcCAAAA.',Fs='Fsugar:BAABKgAFFH8MAAIKAAYI6xqzBACZAQAKAAYI6xqzBACZAQAAAA==.',Gq='Gqin:BAAAKgAFFAIIBAAAAA==.',Im='Imbabbq:BAAAKgAECggIEgAAAA==.',In='Inna:BAACKgAFFH8xAAQLAAgIThfEDwDjAQALAAUI+R/EDwDjAQAMAAQIzSGUBwDaAAANAAMItALCDwCCAAAqAAQKfygAAwwACAggHWUOABMCAAwACAggHWUOABMCAAsABAhdG1uaABkBAAAA.',Li='Lightingzz:BAAAKgADCgQIBAAAAA==.',Lm='Lminz:BAABKgAECn8VAAILAAgIyRtFXwDeAQALAAgIyRtFXwDeAQAAAA==.',Ma='Makinami:BAAAKgAFFAgIBAAAAA==.',Me='Melon:BAACKgAFFH9rAAMOAAgIhiWKAAABAwAOAAgIhiWKAAABAwAPAAQIgwkqEQC4AAAqAAQKfy8AAw8ACAiLJNEFALgCAA8ACAiLJNEFALgCAA4ACAiFI6QJAKUCAAAA.',Mi='Miakhalifa:BAACKgAFFH8NAAIBAAQIoB4fJgD+AAABAAQIoB4fJgD+AAAqAAQKfxQAAgEABwiJITgqABcCAAEABwiJITgqABcCAAAA.Mils:BAAAKgADCggICAAAAA==.',Na='Natasha:BAABKgAFFH8VAAMQAAYI/RLhAQC3AQAQAAYI/RLhAQC3AQAGAAEIAAAKFAAAAAAAAA==.',Ni='Nicess:BAAAKgADCggICAAAAA==.',Nr='Nryu:BAAAKgAECgIIAgAAAA==.',Pl='Playeryfqilu:BAAAKgAECgEIAQAAAA==.',Po='Polo:BAAAKgAECgUIBQAAAA==.',Qo='Qoqo:BAAAKgAECgUICQAAAA==.Qoqosfn:BAAAKgAECgYIDQAAAA==.',Ra='Radint:BAAAKgAFFAMIAwAAAA==.',Rp='Rpfish:BAAAKgAECgcIBwAAAA==.Rpoon:BAACKgAFFH8LAAMRAAQIOCVUDgDgAAASAAQIByKCIwD6AAARAAMIOCVUDgDgAAAqAAQKfyAAAhEACAiIJCYFAM0CABEACAiIJCYFAM0CAAAA.',Sa='Sanalusi:BAABKgAFFH8GAAICAAYIxBKyDAA+AQACAAYIxBKyDAA+AQAAAA==.',St='Stellalou:BAAAKgAECgEIAQAAAA==.',Sw='Swordovo:BAAAKgAECggIEgAAAA==.',Ta='Taren:BAACKgAFFH8LAAILAAcIiBVUEgDKAQALAAcIiBVUEgDKAQAqAAQKfxUAAgsACAgPHA47ABQCAAsACAgPHA47ABQCAAEqAAUUCAgSAAsARh8A.',Ti='Titano:BAAAKgAECgYIDAAAAA==.',Vi='Vincentia:BAACKgAFFH8vAAMPAAYIoCThAwAQAgAPAAYIoCThAwAQAgATAAQI0STZBABHAQAqAAQKfy0ABBMACAgqJZcDAM4CABMACAiyJJcDAM4CAA8ACAibI3gPAFcCAA4ACAhiEsIgAH8BAAAA.',Wi='Wildfire:BAACKgAFFH8GAAMIAAMIfSBNDADrAAAIAAMImRxNDADrAAAJAAMIbBmZKwDKAAAqAAQKfzUAAwkACAieJLYSAJYCAAkACAiVJLYSAJYCAAgABgisFV8xAP4AAAAA.',Wo='Woasni:BAAAKgAECgcICwAAAA==.',Wr='Wrangler:BAAAKgADCggICAAAAA==.',Yo='Yokuka:BAAAKgAECgIIAwABKgAFFAgIDQAUAJofAA==.',Zl='Zlatan:BAABKgAECn8YAAIUAAgI+gJPRQCsAAAUAAgI+gJPRQCsAAAAAA==.',['一个']='一个毒妇:BAAAKgADCgMIAwAAAA==.',['一只']='一只小泡芙:BAABKgAFFH8RAAMVAAMI9RkRBQDwAAAVAAMI0RcRBQDwAAAWAAMIYhLhBgChAAAAAA==.',['一掌']='一掌拍死你:BAAAKgAECggIDwAAAA==.',['一片']='一片乌云:BAAAKgAECggIEAAAAA==.',['一颤']='一颤抖三抖:BAAAKgAECggIEwAAAA==.',['七月']='七月的忧郁:BAABKgAFFH8KAAMLAAYIuBt6JQBTAQALAAYIPRd6JQBTAQANAAQI4RqZFQDLAAAAAA==.七月银河:BAABKgAFFH8HAAIPAAMIuBMyJACyAAAPAAMIuBMyJACyAAAAAA==.',['七煌']='七煌宝术:BAABKgAFFH8GAAQXAAMIxxBUGAB9AAAXAAIIZg1UGAB9AAAYAAEIiBfYKQBGAAAZAAEI5wcINgA4AAAAAA==.',['三修']='三修:BAABKgAFFH8IAAIHAAMIwhYyKwDKAAAHAAMIwhYyKwDKAAAAAA==.',['三分']='三分恶气:BAABKgAFFH8KAAIRAAQIih4/HQAHAQARAAQIih4/HQAHAQAAAA==.',['三岁']='三岁爱冠希:BAAAKgADCggICAAAAA==.',['下雨']='下雨要打雷:BAAAKgADCggICAAAAA==.',['不要']='不要点我名:BAAAKgAFFAUIAQAAAA==.',['专杀']='专杀座机:BAABKgAECn8dAAIaAAcIswSANgCNAAAaAAcIswSANgCNAAAAAA==.',['世界']='世界第一猎:BAAAKgAECgYIBgAAAA==.',['东方']='东方丶树叶:BAABKgAFFH8UAAIbAAYIzRvoDAB/AQAbAAYIzRvoDAB/AQAAAA==.东方丶樹葉:BAAAKgAFFAQIBAAAAA==.',['两岁']='两岁:BAABKgAFFH8GAAIJAAYIHRBZDgBhAQAJAAYIHRBZDgBhAQAAAA==.',['丨囚']='丨囚牛丨:BAAAKgAECgQIBAAAAA==.',['丨掌']='丨掌中萌虎丨:BAAAKgAECggICAAAAA==.',['丨灵']='丨灵狐丨:BAABKgAECn8YAAIRAAgI8RnyJACzAQARAAgI8RnyJACzAQAAAA==.',['丶融']='丶融化:BAACKgAFFH8FAAMKAAQIwR+cAgAqAQAKAAQIwR+cAgAqAQAcAAEIiAGAQgAqAAAqAAQKfxoAAwoACAiuGHEyAKgBAAoACAhvGHEyAKgBABwABgjTFpVRADQBAAAA.',['为了']='为了圣光丶:BAAAKgAFFAQIBAAAAA==.为了虚空:BAAAKgAECgMIAwAAAA==.',['为妇']='为妇不仁:BAAAKgAECgYICwAAAA==.',['丿牧']='丿牧詩:BAAAKgADCggICwAAAA==.',['乙宗']='乙宗梢:BAAAKgADCgcIBwAAAA==.',['也许']='也许不:BAACKgAFFH8JAAIQAAMISQuKDADdAAAQAAMISQuKDADdAAAqAAQKfxcAAhAACAgYHiIMAFcCABAACAgYHiIMAFcCAAAA.',['乱牛']='乱牛的野:BAAAKgAECgMIAwAAAA==.',['二三']='二三一溜:BAAAKgAFFAQIBAAAAA==.',['云出']='云出无心:BAABKgAFFH8JAAMRAAYIhxn1EgBLAQARAAUIghn1EgBLAQASAAQIIhKTOAC2AAAAAA==.',['云月']='云月:BAAAKgAECggIDAAAAA==.',['云耀']='云耀:BAABKgAFFH8QAAILAAQIYiG5EAARAQALAAQIYiG5EAARAQAAAA==.',['五气']='五气灬朝元:BAAAKgAFFAIIAgAAAA==.',['京东']='京东优选法神:BAAAKgAFFAQIBAAAAA==.',['人一']='人一大:BAABKgAFFH8RAAMYAAMIZxedFgCTAAAYAAII9xmdFgCTAAAXAAEIRxKNIQBGAAAAAA==.',['人间']='人间一两风:BAAAKgADCggICAAAAA==.',['以德']='以德湖人:BAAAKgAFFAIIAgAAAA==.',['以沫']='以沫灬:BAAAKgADCggICAAAAA==.',['伊戈']='伊戈奈亚:BAAAKgAFFAQIBAAAAA==.',['伊莉']='伊莉妮丝:BAAAKgADCgMIAwAAAA==.',['伍岚']='伍岚正:BAABKgAFFH8IAAIRAAQIAgtYMwCkAAARAAQIAgtYMwCkAAAAAA==.',['会飞']='会飞的土豆:BAAAKgAECggIDwAAAA==.',['伤追']='伤追人:BAABKgAFFH8GAAIdAAYIlxhoDQCPAQAdAAYIlxhoDQCPAQAAAA==.',['你在']='你在教我做事:BAAAKgAECggIEQAAAA==.',['你当']='你当我瞎啊:BAAAKgAFFAIIAgAAAA==.',['你若']='你若盛开:BAAAKgADCgIIAgAAAA==.',['佳得']='佳得乐丶:BAAAKgADCggICAAAAA==.',['使劲']='使劲奶啊好疼:BAAAKgAECgMIAwAAAA==.',['侯殿']='侯殿坤:BAAAKgAECgEIAQAAAA==.',['傲霜']='傲霜冰蓝:BAAAKgADCgEIAQAAAA==.',['僑風']='僑風:BAABKgAECn9AAAQZAAgIRyNvBgCgAgAZAAcIciJvBgCgAgAXAAcIbhcDDQCiAQAYAAYI6iHxGwCdAQAAAA==.',['儿茶']='儿茶:BAAAKgAFFAQIBAABKgAFFAgICwAdACwVAA==.',['元素']='元素葱击:BAAAKgAECgYIBgAAAA==.',['光铸']='光铸伊瑞尔:BAAAKgAFFAMIBAAAAA==.光铸幽雨听梦:BAAAKgAECgYIBgAAAA==.',['全村']='全村人的力量:BAAAKgAECgYICwAAAA==.',['兴皿']='兴皿:BAABKgAFFH8VAAISAAQIFBhYFQDhAAASAAQIFBhYFQDhAAAAAA==.',['冉懒']='冉懒:BAABKgAFFH8FAAIHAAMImQaYPQCRAAAHAAMImQaYPQCRAAAAAA==.',['冥河']='冥河引苍生:BAAAKgADCgEIAQAAAA==.',['凌雨']='凌雨:BAAAKgAECgUIBQAAAA==.',['凤千']='凤千寻:BAABKgAFFH8MAAMKAAgI2ARbBQBcAQAKAAgIWgRbBQBcAQAdAAQI2QIYIgBvAAAAAA==.',['凭栏']='凭栏听雨:BAAAKgADCgEIAQAAAA==.',['判官']='判官:BAAAKgAECgYICQAAAA==.',['刷不']='刷不起来:BAAAKgAECgYIDAAAAA==.',['副团']='副团长:BAAAKgAECgMIAwAAAA==.',['勒经']='勒经德尔瑞:BAABKgAFFH8MAAIRAAQIuiDVGgAXAQARAAQIuiDVGgAXAQABKgAFFAQIEQARAGEdAA==.',['匿名']='匿名:BAABKgAFFH8HAAMCAAYI+QZgCgDpAAACAAYI+QZgCgDpAAABAAEIKwJ0MQA1AAAAAA==.',['十万']='十万八千梦:BAAAKgADCggICAAAAA==.',['十月']='十月的雪天:BAABKgAFFH8GAAIQAAYIeRUhEQA+AQAQAAYIeRUhEQA+AQAAAA==.',['千刃']='千刃散浮华:BAABKgAFFH8JAAIJAAQIAA5sGgDbAAAJAAQIAA5sGgDbAAAAAA==.',['千觅']='千觅:BAAAKgAFFAIIAwAAAA==.',['千重']='千重浪:BAAAKgADCgMIAwAAAA==.',['半醒']='半醒半梦之间:BAAAKgAFFAIIBAAAAA==.',['单曲']='单曲循环:BAABKgAFFH8FAAIbAAUI3R4REgA4AQAbAAUI3R4REgA4AQAAAA==.',['南山']='南山:BAABKgAFFH8FAAIZAAMIrQUoHwCKAAAZAAMIrQUoHwCKAAAAAA==.',['南璐']='南璐:BAAAKgAFFAEIAQABKgAFFAgIRgAXALQmAA==.',['原味']='原味麦片:BAAAKgAECgYIDQAAAA==.',['原神']='原神启动:BAAAKgADCgMIAwAAAA==.',['双剑']='双剑闯江湖:BAAAKgAECggIDAAAAA==.',['受伤']='受伤的小鱼:BAACKgAFFH8IAAIKAAMIkApuGwClAAAKAAMIkApuGwClAAAqAAQKfxYAAgoACAhFEJEpAG8BAAoACAhFEJEpAG8BAAAA.',['变体']='变体精灵:BAAAKgAFFAQIAQABKgAFFAgIAQADAAAAAA==.',['变形']='变形大师:BAABKgAFFH8HAAMBAAcIhB07BwAxAgABAAYIQR87BwAxAgACAAEIDANANwA/AAAAAA==.',['古法']='古法厚切鹿排:BAABKgAFFH8GAAIBAAUI/h06GQBPAQABAAUI/h06GQBPAQAAAA==.',['叶子']='叶子纷飞:BAAAKgAECggICAAAAA==.',['司阿']='司阿莫安:BAAAKgAECgEIAQAAAA==.',['叽里']='叽里咕噜德:BAAAKgADCgEIAQAAAA==.',['呀勒']='呀勒呀勒:BAAAKgADCgYIBgAAAA==.',['咆哮']='咆哮的比熊:BAAAKgADCgIIAgAAAA==.',['咬春']='咬春:BAABKgAFFH8HAAMeAAMI0QNXHQCOAAAeAAMI0QNXHQCOAAAHAAMIHAdnKAB+AAAAAA==.',['哈利']='哈利波特圆:BAAAKgADCggICAAAAA==.',['哈黎']='哈黎露雅:BAABKgAECn8vAAQPAAgIxAdWUgDIAAAPAAgI+wZWUgDIAAAOAAgIfwMhSgCGAAATAAQIFAQ/dgBCAAAAAA==.',['啊诺']='啊诺:BAABKgAFFH8JAAMPAAcIuA1FDwDVAAAPAAUINAxFDwDVAAATAAMIiguIIQBzAAAAAA==.',['喂我']='喂我有麦吗:BAAAKgAECggIEAAAAA==.',['喃海']='喃海神尼:BAABKgAFFH8BAAIfAAEIWB/kFgBRAAAfAAEIWB/kFgBRAAAAAA==.',['喷火']='喷火小怪兽:BAAAKgADCggICAAAAA==.',['嘤嘤']='嘤嘤怪丶:BAAAKgAECgEIAQAAAA==.',['四号']='四号坦克:BAABKgAFFH8IAAIEAAgIdw/jCAAAAgAEAAgIdw/jCAAAAgAAAA==.',['四四']='四四七:BAAAKgAECgYIBgAAAA==.',['四大']='四大威慑:BAABKgAFFH8GAAIRAAYIXBjoDQB9AQARAAYIXBjoDQB9AQAAAA==.',['四妹']='四妹:BAABKgAFFH8LAAILAAYIYCKeAAAQAgALAAYIYCKeAAAQAgAAAA==.',['回忆']='回忆永存:BAAAKgADCggICAAAAA==.',['因为']='因为我善:BAAAKgAECgEIAQAAAA==.',['囿嶸']='囿嶸:BAABKgAFFH8IAAIHAAgI1xjBAwAwAgAHAAgI1xjBAwAwAgAAAA==.',['圣光']='圣光之火:BAAAKgAECggIEAAAAA==.圣光之皿:BAAAKgAECgEIAQAAAA==.',['圣天']='圣天芒:BAAAKgAECgEIAQAAAA==.',['地爆']='地爆天星:BAAAKgAECggICAAAAA==.',['埃辛']='埃辛烈焰:BAABKgAFFH8NAAIJAAMIwA/TLQDEAAAJAAMIwA/TLQDEAAAAAA==.',['堕落']='堕落训兽者:BAACKgAFFH8VAAMRAAUI5BsQFwAtAQARAAUI5hoQFwAtAQASAAMIsBt5KQDfAAAqAAQKf0gAAxIACAhTIp8OAK8CABIACAhTIp8OAK8CABEABgiHGn4rAI0BAAAA.',['塔兰']='塔兰泰拉:BAAAKgAECgMIAwAAAA==.',['墨灵']='墨灵:BAABKgAECn8oAAMCAAgI3BzIEwAnAgACAAgI3BzIEwAnAgABAAcIbhlBPwCrAQAAAA==.',['壹個']='壹個書仕:BAAAKgAFFAUIAgABKgAFFAgIDwAZAJIcAA==.',['壹条']='壹条龍:BAABKgAFFH8MAAMUAAQImxv3DADnAAAUAAQImxv3DADnAAAgAAEIkA4ACwA9AAAAAA==.',['夏一']='夏一可:BAAAKgAECgMIAwAAAA==.',['夏乌']='夏乌拉:BAAAKgAECgQIBAAAAA==.',['夏夜']='夏夜晚风:BAACKgAFFH8IAAITAAgI/hieAwAkAgATAAgI/hieAwAkAgAqAAQKfxwAAg8ACAjbEGUuAIsBAA8ACAjbEGUuAIsBAAAA.',['夏天']='夏天烨:BAAAKgAECgEIAQAAAA==.',['夜兰']='夜兰:BAAAKgADCgMIAwAAAA==.',['夜航']='夜航星:BAAAKgAECgYIBgABKgAFFAgIAQADAAAAAA==.',['大壮']='大壮舅舅:BAAAKgADCgQIBAAAAA==.',['大愛']='大愛無悔:BAABKgAFFH8GAAMTAAMImR2qEgAFAQATAAMImR2qEgAFAQAOAAMI+AohHACiAAAAAA==.',['大野']='大野和小野:BAABKgAECn8aAAMaAAgIAgUwMwCiAAAaAAgIAgUwMwCiAAAhAAQIjQHyYQAnAAAAAA==.',['天堂']='天堂之拳:BAABKgAECn8TAAILAAgIKiZYCgDrAgALAAgIKiZYCgDrAgAAAA==.',['天竺']='天竺长公主:BAAAKgAFFAgIBAAAAA==.',['天降']='天降人才:BAAAKgAFFAYIBAAAAA==.',['太子']='太子文武:BAABKgAFFH8GAAIRAAYIhhUMDwBwAQARAAYIhhUMDwBwAQAAAA==.',['头铁']='头铁:BAABKgAFFH8hAAIbAAgIbSNhBABPAgAbAAgIbSNhBABPAgAAAA==.',['奈妃']='奈妃妮:BAABKgAFFH8MAAIHAAgIlxrhBAAMAgAHAAgIlxrhBAAMAgAAAA==.',['好想']='好想伱:BAAAKgAFFAIIAgAAAA==.',['妙龄']='妙龄尼姑:BAABKgAFFH8aAAQdAAgIciWRAQDKAgAdAAgIuyKRAQDKAgAcAAgI2h6lBAA+AgAKAAQIWRv1DgDrAAAAAA==.妙龄师太:BAABKgAFFH8aAAILAAgI9CWOAQDuAgALAAgI9CWOAQDuAgAAAA==.',['姥姥']='姥姥:BAAAKgAFFAIIBAAAAA==.',['婉若']='婉若游龙:BAAAKgAECgQIBAAAAA==.',['婷丫']='婷丫头:BAAAKgAECggIEAAAAA==.',['孤独']='孤独的旅行者:BAABKgAFFH8dAAQCAAMIaRKMJACTAAACAAMIaRKMJACTAAABAAMI/QS5JACTAAAWAAMIQgj6BQB1AAAAAA==.',['安和']='安和昴:BAAAKgAFFAMIAwABKgAFFAYIDAAJALQjAA==.',['宝贝']='宝贝静静:BAABKgAFFH8GAAIHAAMI+hr7HgCeAAAHAAMI+hr7HgCeAAAAAA==.',['寇玛']='寇玛可:BAAAKgAECggICAAAAA==.',['小刀']='小刀炉尖风:BAABKgAECn8tAAIbAAgIvQ3UFwA9AQAbAAgIvQ3UFwA9AQAAAA==.小刀芦间风:BAAAKgAECggIDwAAAA==.',['小码']='小码鸽:BAABKgAECn8YAAMSAAYILxQchwAjAQASAAYIig8chwAjAQARAAUIlRKNTgDiAAABKgAFFAUIDQAKAHIJAA==.',['小空']='小空丶:BAAAKgAECgUIBQAAAA==.',['小米']='小米失踪了:BAAAKgAECgIIAgAAAA==.',['小花']='小花菜:BAAAKgAECgYIBgAAAA==.',['小莫']='小莫格莱尼:BAAAKgAECgYIBgAAAA==.',['小豆']='小豆包:BAAAKgAECgcIBwAAAA==.',['小超']='小超灬:BAACKgAFFH8HAAMiAAIIFQ//GABHAAAiAAEICAj/GABHAAAHAAEIrgNGNAA+AAAqAAQKfx0AAyIACAgrF5ghALkBACIABgjXFJghALkBAAcACAjND+ZHAGkBAAAA.',['小雄']='小雄杰里米:BAAAKgAECggICAAAAA==.',['少囡']='少囡榨汁机:BAAAKgAECgcIBwAAAA==.',['山野']='山野栀子:BAAAKgAECggICAAAAA==.',['屿誓']='屿誓:BAAAKgAFFAQIBAAAAA==.',['岳露']='岳露清颖:BAAAKgAFFAIIAgAAAA==.',['島田']='島田聖光:BAAAKgAECggICwAAAA==.',['崩断']='崩断的线:BAAAKgAFFAQIBAAAAA==.',['工具']='工具人古二蛋:BAAAKgADCggICQAAAA==.',['左零']='左零右火:BAABKgAFFH8GAAIHAAQIkBlFJgDdAAAHAAQIkBlFJgDdAAAAAA==.',['布裴']='布裴:BAACKgAFFH8RAAMFAAMIERP6EQDSAAAFAAMIERP6EQDSAAAfAAMI7Qq8IwCUAAAqAAQKfx0ABB8ACAgoFfobAKgBAB8ACAgoFfobAKgBAAUABQj3Fo88ACEBACMAAQiYAT0qABYAAAAA.',['幺伍']='幺伍柒叁:BAAAKgAFFAQIAwABKgAFFAgIEQARAPEhAA==.',['幻丶']='幻丶海:BAAAKgAFFAEIAQAAAA==.',['幻影']='幻影无名:BAAAKgAECgcIBwAAAA==.幻影神奇:BAAAKgAECgIIAgAAAA==.幻影胖达:BAAAKgAECgMIAwAAAA==.',['幻心']='幻心落梦:BAACKgAFFH8SAAIPAAQI5hc2IQDBAAAPAAQI5hc2IQDBAAAqAAQKfxoAAg8ACAjvFwUyAHkBAA8ACAjvFwUyAHkBAAEqAAUUCAgIACQAMQ0A.',['幼稚']='幼稚园长:BAAAKgAECgQIBAAAAA==.',['幽萤']='幽萤:BAAAKgAECgEIAQAAAA==.',['幽雨']='幽雨听梦:BAABKgAFFH8IAAIkAAQIMQ0fBwCeAAAkAAQIMQ0fBwCeAAAAAA==.',['幽默']='幽默小黄人:BAAAKgAECgEIAQAAAA==.',['弄堂']='弄堂里修水表:BAAAKgADCggICgAAAA==.',['弑灭']='弑灭情:BAAAKgADCggIFQAAAA==.',['张宗']='张宗轩:BAABKgAFFH8MAAILAAgINxIhEgDLAQALAAgINxIhEgDLAQAAAA==.',['张小']='张小凡:BAABKgAFFH8IAAIEAAYILCAKDwCoAQAEAAYILCAKDwCoAQAAAA==.',['张罗']='张罗地:BAACKgAFFH8NAAQUAAgImh++DQCGAQAUAAgImh++DQCGAQAgAAIIHRSLBgCPAAAlAAIISgYnBABNAAAqAAQKfzsABBQACAjVIPwaAN4BABQACAhsHfwaAN4BACAABghxE9ELAD0BACUABQh0GakDAPwAAAAA.',['弥撒']='弥撒狂速:BAAAKgAECgQIBAAAAA==.',['强大']='强大的圣骑:BAAAKgADCggICAAAAA==.',['御天']='御天霜:BAACKgAFFH8GAAIEAAMIHAoLJgCOAAAEAAMIHAoLJgCOAAAqAAQKfx0AAwQACAh6F3stAP4BAAQACAh6F3stAP4BACYABQj4EAIgAMMAAAAA.',['微笑']='微笑的眼泪:BAABKgAFFH8FAAICAAQIHQfYKACBAAACAAQIHQfYKACBAAAAAA==.',['微胖']='微胖皇后:BAABKgAFFH8IAAISAAgIoxbiBABYAgASAAgIoxbiBABYAgAAAA==.',['徳一']='徳一分很难:BAABKgAFFH8KAAMBAAgIOxDQEACZAQABAAcIRw/QEACZAQACAAEItRKqMwBKAAAAAA==.',['德光']='德光幼龙:BAAAKgAECggIEwAAAA==.',['心华']='心华:BAAAKgAFFAIIAgAAAA==.',['心爱']='心爱的小摩托:BAAAKgAECgQIBAAAAA==.',['心花']='心花朵朵开:BAAAKgAECgUICgAAAA==.',['忆起']='忆起夏曰:BAAAKgADCgUIBQAAAA==.',['忧郁']='忧郁咖啡色:BAAAKgAECgMIBQAAAA==.',['思念']='思念成空:BAAAKgAECgEIAQAAAA==.',['恶狗']='恶狗大王:BAAAKgADCgMIAwAAAA==.',['悟心']='悟心:BAAAKgADCggIEAAAAA==.',['悟满']='悟满:BAAAKgAFFAEIAQAAAA==.',['惹是']='惹是僧非:BAAAKgADCgMIAwAAAA==.',['慕容']='慕容小妞:BAAAKgAECggICAAAAA==.慕容清儿:BAAAKgADCgEIAQAAAA==.慕容的骑士:BAAAKgADCgEIAQAAAA==.',['我发']='我发烧了额:BAAAKgADCgIIAgAAAA==.',['我吥']='我吥吃牛肉:BAAAKgADCggICAAAAA==.',['我爱']='我爱吃泡芙:BAAAKgAFFAYIAQABKgAFFAgICAASABcdAA==.',['战歌']='战歌:BAABKgAFFH8GAAIJAAYIXgkGHAAgAQAJAAYIXgkGHAAgAQAAAA==.',['战神']='战神丶:BAABKgAFFH8QAAMhAAYIGh2xCQBwAQAhAAYIzhuxCQBwAQAbAAQIyR0nCwAQAQAAAA==.',['扎马']='扎马斯:BAAAKgAFFAQIAgABKgAFFAgIDQALAOEYAA==.',['执爱']='执爱:BAABKgAFFH8IAAIaAAgIUg9pAwCCAQAaAAgIUg9pAwCCAQAAAA==.',['把豆']='把豆包咬哭:BAAAKgAECgcIBwAAAA==.',['抓不']='抓不了别点了:BAAAKgAECgYIDAAAAA==.',['抱抱']='抱抱龙王:BAAAKgADCggICAAAAA==.',['拉灬']='拉灬酷:BAAAKgADCggICAAAAA==.',['拼装']='拼装小萝莉:BAABKgAECn8ZAAQKAAgILB1NNQCbAQAKAAcIshlNNQCbAQAcAAYIZxWDSgBYAQAdAAQIDhsRWwDVAAAAAA==.',['拾指']='拾指緊扣:BAABKgAFFH8HAAMYAAMI9xC5CAC7AAAYAAMImBC5CAC7AAAXAAIIkhHQFwCAAAAAAA==.',['摩卡']='摩卡喵:BAAAKgAECgMIAwAAAA==.',['收手']='收手吧阿祖:BAAAKgADCgcIBwAAAA==.',['救赎']='救赎之路:BAABKgAFFH8IAAInAAgIPxv5AgBDAgAnAAgIPxv5AgBDAgAAAA==.',['文野']='文野亚弥:BAACKgAFFH8UAAITAAgIcRoVAwD1AQATAAgIcRoVAwD1AQAqAAQKfyAAAg8ACAjWFvIjAKoBAA8ACAjWFvIjAKoBAAAA.',['新塘']='新塘吊那星:BAABKgAFFH8gAAIKAAQIXxFzCgDVAAAKAAQIXxFzCgDVAAAAAA==.',['新宠']='新宠:BAAAKgAECgUIBQAAAA==.',['新爱']='新爱的小摩托:BAAAKgADCggIBQAAAA==.',['无心']='无心无相:BAAAKgAECgMIAwAAAA==.',['无惧']='无惧:BAABKgAFFH8GAAIUAAYIVAOhEgDeAAAUAAYIVAOhEgDeAAAAAA==.',['时空']='时空之刃:BAAAKgAECgQIBAAAAA==.',['明朝']='明朝别离:BAAAKgAECgQIBQABKgAECggIDAADAAAAAA==.明朝相见:BAAAKgAECggIDAAAAA==.',['星期']='星期七七:BAAAKgAFFAIIAgAAAA==.',['春庭']='春庭雪丶:BAAAKgAFFAUIBAAAAA==.',['春秋']='春秋战国:BAAAKgAFFAMIAwAAAA==.',['晓得']='晓得的:BAAAKgADCgIIAgAAAA==.',['晓芙']='晓芙:BAAAKgAECggIDAAAAA==.',['晓蚪']='晓蚪:BAAAKgAECgEIAgAAAA==.',['晕晕']='晕晕苓:BAAAKgAECgQIBAAAAA==.',['暗夜']='暗夜乐乐:BAAAKgADCggICAAAAA==.暗夜无影箭:BAAAKgAECgYIDQAAAA==.暗夜黎明:BAAAKgAFFAMIAwAAAA==.',['暴龙']='暴龙神:BAAAKgADCgcIBwAAAA==.',['曲江']='曲江春:BAAAKgAECgMIAwAAAA==.',['最美']='最美德:BAAAKgAECgQIBgAAAA==.',['月灵']='月灵银羽:BAACKgAFFH8VAAISAAMIzBXzKQDdAAASAAMIzBXzKQDdAAAqAAQKfx0AAhIACAgWE7VmAH4BABIACAgWE7VmAH4BAAAA.',['有德']='有德医:BAAAKgAECgMIAwAAAA==.',['有意']='有意见你就说:BAAAKgADCggICAAAAA==.',['木易']='木易战:BAABKgAFFH8mAAMaAAQIowSDEQBwAAAbAAQI7wF7LgCEAAAaAAQIowSDEQBwAAAAAA==.',['木耳']='木耳五分熟:BAABKgAFFH8UAAMiAAgIaB1+AgByAgAiAAgIaB1+AgByAgAHAAQIAiJbBgAmAQAAAA==.',['术师']='术师七:BAAAKgAECgYIBgAAAA==.',['杀手']='杀手爽爽:BAABKgAECn8iAAMSAAgIaCUsDgCzAgASAAgIaCUsDgCzAgARAAUIEyPaMwCMAQAAAA==.杀手皇后丷:BAAAKgAFFAMIAwAAAA==.',['李大']='李大黑:BAAAKgAECgYIBgAAAA==.',['李政']='李政宰:BAABKgAFFH8LAAMSAAQIuCTXDgATAQASAAQI8RzXDgATAQARAAQIuCRxHQAGAQAAAA==.',['李青']='李青:BAABKgAFFH8GAAIfAAYIRgjTCwD+AAAfAAYIRgjTCwD+AAAAAA==.',['杭州']='杭州大宝剑:BAAAKgAECgMIAwAAAA==.',['果果']='果果是淘气鬼:BAAAKgAECgEIAQAAAA==.',['枪爷']='枪爷:BAAAKgAFFAYIBAABKgAFFAgICAASAHkgAA==.',['柒哥']='柒哥:BAAAKgAFFAMIAwAAAA==.',['桖帝']='桖帝凯:BAABKgAFFH8MAAInAAQIHxlVGQDXAAAnAAQIHxlVGQDXAAABKgAFFAgIAgADAAAAAA==.',['梦伴']='梦伴:BAABKgAFFH8HAAMBAAQIACY9BQBTAQABAAMIACY9BQBTAQACAAQIaxHWHwCsAAAAAA==.',['梦安']='梦安魂于玖霄:BAAAKgADCgMIAwAAAA==.',['梦旅']='梦旅:BAAAKgADCggICAAAAA==.',['槍丶']='槍丶菽:BAABKgAECn8oAAMBAAgIJhWdPQCxAQABAAgIJhWdPQCxAQACAAEIpgULjQApAAAAAA==.',['樊黎']='樊黎佳:BAAAKgAECggICAAAAA==.',['樱花']='樱花雪落:BAABKgAFFH8IAAMBAAgIORXWDQCWAQABAAYIsxfWDQCWAQACAAIIJRiEEACSAAAAAA==.',['橙子']='橙子元宵:BAABKgAFFH8SAAMLAAYIPR2+AQDUAQALAAYIPR2+AQDUAQANAAYILBRwDQAkAQAAAA==.橙子的圣光啊:BAACKgAFFH8IAAMTAAMIbwSPIAB5AAATAAIIPgaPIAB5AAAPAAEI0QAGRAAeAAAqAAQKfygAAxMACAhkGG4ZAPgBABMACAhkGG4ZAPgBAA8AAgg/CGmJAEsAAAAA.',['歌兰']='歌兰蒂斯:BAAAKgAECggIEwAAAA==.',['正义']='正义的大伙伴:BAAAKgADCgIIAgAAAA==.',['此恨']='此恨凭谁拆:BAABKgAFFH8JAAITAAYI1A4XBwAnAQATAAYI1A4XBwAnAQAAAA==.',['死亡']='死亡之名:BAABKgAFFH8IAAMEAAMIqAYQGQCdAAAEAAMIqAYQGQCdAAAnAAMIWgJcEgBRAAAAAA==.死亡甜甜:BAAAKgAFFAgIAwAAAA==.',['死灵']='死灵武憎:BAABKgAFFH8GAAIhAAYIEBUmCQB4AQAhAAYIEBUmCQB4AQAAAA==.',['比熊']='比熊:BAAAKgAECgEIAQAAAA==.',['水平']='水平如镜:BAAAKgAFFAEIAQAAAA==.',['江湖']='江湖漂流记:BAABKgAFFH8GAAIMAAYIzxxSBACzAQAMAAYIzxxSBACzAQAAAA==.',['沃德']='沃德内哥儿:BAAAKgAFFAgIAgAAAA==.沃德杨永信:BAABKgAECn8aAAIeAAgIhiGQCQCpAgAeAAgIhiGQCQCpAgABKgAFFAgIAgADAAAAAA==.',['沉睡']='沉睡者一号:BAAAKgAECgIIAgAAAA==.沉睡者五号:BAAAKgAECgcIBwAAAA==.',['沙棘']='沙棘杀鸡:BAABKgAFFH8KAAIHAAMIoh5LGwC0AAAHAAMIoh5LGwC0AAAAAA==.',['沙漫']='沙漫:BAAAKgADCggICAAAAA==.',['沙耶']='沙耶之歌:BAAAKgAECggIEQAAAA==.',['洛昭']='洛昭言:BAAAKgADCgYIBgAAAA==.',['洛颉']='洛颉:BAABKgAFFH8FAAMdAAMIfQ3OGAC2AAAdAAMIKg3OGAC2AAAcAAIIOAgAMwB/AAAAAA==.',['流水']='流水残阳:BAAAKgAFFAMIAwAAAA==.',['流风']='流风漫步:BAAAKgAECgUICQAAAA==.',['浅丶']='浅丶笑:BAAAKgAECgQIBAABKgAECggIDAADAAAAAA==.',['浅挚']='浅挚半离兮:BAAAKgADCgMIAwAAAA==.',['海南']='海南鸡饭:BAAAKgAECggIEAAAAA==.',['涅芙']='涅芙瑞塔:BAAAKgAFFAQIBAAAAA==.',['涩刁']='涩刁馋:BAAAKgAFFAQIAwAAAA==.',['涩琅']='涩琅正是在下:BAAAKgADCgMIAwAAAA==.',['深刻']='深刻:BAABKgAFFH8GAAIEAAYIniQcCgDrAQAEAAYIniQcCgDrAQAAAA==.',['混沌']='混沌:BAAAKgAECgQIBAAAAA==.混沌出羊刀:BAAAKgAECgEIAQAAAA==.',['清风']='清风自来:BAAAKgADCggICAAAAA==.',['满天']='满天星丶圣骑:BAAAKgADCgEIAQAAAA==.',['漂泊']='漂泊沉沦:BAAAKgAFFAIIAgAAAA==.',['演帝']='演帝威叔:BAAAKgADCgcICwAAAA==.',['漪粼']='漪粼粼:BAAAKgAECggICAAAAA==.',['潇洒']='潇洒一七五:BAAAKgAECgcICAAAAA==.',['澹然']='澹然离言说:BAAAKgAECgQIAQAAAA==.',['火球']='火球来一发:BAAAKgAECggICAAAAA==.',['火花']='火花骑士可莉:BAABKgAFFH8FAAMSAAQI+hj+RACMAAASAAQIqgz+RACMAAARAAEIbSXdSgBUAAAAAA==.',['灵活']='灵活死胖纸:BAAAKgAECgIIAgAAAA==.',['灵灵']='灵灵柒:BAAAKgAECgUIBQAAAA==.',['炎爆']='炎爆炎爆:BAACKgAFFH8MAAMdAAYIqRGPEABlAQAdAAYIlhGPEABlAQAKAAYIUgnaBgAgAQAqAAQKfxUAAx0ACAiiFTszAIIBAB0ABgjwFTszAIIBAAoACAhUCvE6AAoBAAAA.',['炖咸']='炖咸鱼:BAAAKgAFFAEIAQAAAA==.',['炽燃']='炽燃:BAABKgAFFH8SAAMUAAYIGRpUBABeAQAUAAUIGRpUBABeAQAgAAMIkAo2CAB0AAAAAA==.',['烛照']='烛照:BAAAKgAFFAYIAgAAAA==.',['烛阴']='烛阴:BAAAKgAFFAMIAwAAAA==.',['烟胧']='烟胧雨:BAACKgAFFH8fAAIdAAYIfiN5CADwAQAdAAYIfiN5CADwAQAqAAQKfyEAAh0ACAhwJJwGANQCAB0ACAhwJJwGANQCAAEqAAUUCAhkAA4ARSYA.',['烧酒']='烧酒不甜:BAAAKgAECgQIBAAAAA==.',['热心']='热心市民小苏:BAABKgAFFH8IAAIHAAQI+Bb9LgC7AAAHAAQI+Bb9LgC7AAAAAA==.',['焦糖']='焦糖奶昔:BAAAKgADCgEIAQAAAA==.',['爱伊']='爱伊:BAAAKgAFFAQIBAAAAA==.',['爱吃']='爱吃青苹果:BAABKgAECn80AAMhAAgIdSYEBQDFAgAhAAgI/yQEBQDFAgAbAAcIcSRNEwBsAgAAAA==.',['爱笑']='爱笑的眼睛:BAAAKgADCgYIBgAAAA==.',['爱雪']='爱雪无痕:BAAAKgAECgcIBwAAAA==.',['牛牛']='牛牛单人饭:BAABKgAECn8WAAIBAAgIfxtOJgArAgABAAgIfxtOJgArAgAAAA==.',['牧之']='牧之本桃矢:BAAAKgAFFAgIAgAAAA==.',['牧心']='牧心在野:BAAAKgAFFAMIAwAAAA==.',['狗岁']='狗岁叮叮:BAABKgAFFH8ZAAMcAAUIvyDqCQBYAQAcAAUIFxvqCQBYAQAKAAQIcSJACwAUAQAAAA==.',['狙擊']='狙擊之王:BAAAKgAECgcICQAAAA==.',['独承']='独承雨露:BAAAKgADCggICAAAAA==.',['猫尾']='猫尾草:BAAAKgAFFAQIBAABKgAFFAgIAgAdAAIWAA==.',['猫皇']='猫皇陛下:BAAAKgAFFAIIAgAAAA==.',['獨依']='獨依無噯:BAAAKgAFFAMIAwAAAA==.',['玄空']='玄空:BAAAKgAECgYIBgAAAA==.',['王赢']='王赢儿:BAAAKgAFFAgIAgAAAA==.',['玖柒']='玖柒:BAACKgAFFH8bAAMNAAgI9g3nCAB2AQANAAgI9g3nCAB2AQAMAAQIbBoZBQD4AAAqAAQKfyEAAwwACAjmF8QZAJkBAAwACAjmF8QZAJkBAAsABggiEzioAP4AAAAA.',['玖玖']='玖玖:BAAAKgADCggICAAAAA==.',['玖玥']='玖玥:BAACKgAFFH8SAAIfAAgI6xkZCACxAQAfAAgI6xkZCACxAQAqAAQKfxcAAh8ACAidD6FNAAQBAB8ACAidD6FNAAQBAAAA.',['玛圣']='玛圣:BAABKgAECn8VAAILAAgIyQ+0cQByAQALAAgIyQ+0cQByAQAAAA==.',['珐诗']='珐诗:BAAAKgAECgUIBQAAAA==.',['珠珠']='珠珠宝贝丫:BAAAKgAECggICAAAAA==.珠珠小宝贝儿:BAAAKgADCgUIBQAAAA==.',['璎錵']='璎錵:BAAAKgAFFAIIAgAAAA==.',['疯丫']='疯丫頭:BAABKgAFFH8FAAISAAMIdQoDOwCvAAASAAMIdQoDOwCvAAAAAA==.',['疯狂']='疯狂折耳根:BAABKgAECn8XAAIBAAgInQ2vXQBBAQABAAgInQ2vXQBBAQAAAA==.',['白子']='白子真奶:BAABKgAFFH8FAAIfAAQIGhNOEQDgAAAfAAQIGhNOEQDgAAABKgAFFAgIBgAfAFMhAA==.',['白无']='白无常:BAAAKgAECggICQAAAA==.',['白泽']='白泽丿:BAAAKgAECgMIAwAAAA==.',['百变']='百变大猫:BAABKgAECn8WAAIVAAcI+R/wCwDIAQAVAAcI+R/wCwDIAQAAAA==.',['看我']='看我干嘛上啊:BAAAKgAECgcIDQAAAA==.',['知风']='知风丿:BAAAKgADCggICAAAAA==.',['矮脚']='矮脚虎:BAAAKgAFFAgIBAAAAA==.',['社会']='社会大宝贝:BAAAKgAECggICAAAAA==.',['神仙']='神仙:BAAAKgAECgMIAwAAAA==.',['祸斗']='祸斗:BAAAKgAFFAQIAgAAAA==.',['科迈']='科迈罗:BAAAKgAECgUIAQAAAA==.',['第二']='第二十任酋长:BAAAKgADCgMIAwAAAA==.',['粉色']='粉色体育生:BAABKgAFFH8NAAILAAMIjBpISQDcAAALAAMIjBpISQDcAAAAAA==.',['糊糊']='糊糊涂牛:BAAAKgAECggIEwAAAA==.',['糖荳']='糖荳儿:BAAAKgAFFAIIAwAAAA==.',['糖锘']='糖锘儿:BAAAKgADCgUIBQAAAA==.',['素前']='素前小乖:BAABKgAFFH8FAAIcAAUIKRCOFQAJAQAcAAUIKRCOFQAJAQAAAA==.素前小狗:BAABKgAFFH8NAAIJAAYI1RMyAwCzAQAJAAYI1RMyAwCzAQABKgAFFAgIGQAEAOghAA==.',['素縤']='素縤:BAAAKgADCgUIBQAAAA==.',['紫千']='紫千荨:BAABKgAFFH8UAAQTAAgIthk3CACeAQATAAYIAhg3CACeAQAPAAII9x1GIgC8AAAOAAIIjgxWIACJAAAAAA==.',['紫灵']='紫灵水仙:BAAAKgADCgEIAQAAAA==.',['紫魅']='紫魅血兮:BAAAKgAECggICAAAAA==.',['絶鈑']='絶鈑籹孖:BAABKgAFFH8MAAILAAYIoCKVDQD5AQALAAYIoCKVDQD5AQAAAA==.',['红色']='红色和蓝色:BAABKgAFFH8HAAQXAAYIuwwjFQCUAAAZAAIIvRf7NgCVAAAXAAMIZAUjFQCUAAAYAAEIAADkNQAAAAAAAA==.',['绯亦']='绯亦:BAAAKgADCggICAAAAA==.',['绵绵']='绵绵的亿风:BAABKgAECn8VAAIKAAgIawKVaQBZAAAKAAgIawKVaQBZAAAAAA==.绵绵的小毅:BAAAKgAECggICAAAAA==.',['绿豆']='绿豆芽:BAABKgAECn9AAAIFAAgIISQVBADiAgAFAAgIISQVBADiAgABKgAFFAYIBgABAOkUAA==.',['罗湖']='罗湖:BAAAKgAFFAIIAgAAAA==.',['羊头']='羊头:BAAAKgADCgMIAwAAAA==.',['美式']='美式标糖:BAABKgAFFH8MAAMTAAYItRNLBgBJAQATAAYIPRJLBgBJAQAPAAYIyxDFCgAgAQABKgAFFAgIDgAZAPkhAA==.',['老严']='老严:BAAAKgAECgIIAgAAAA==.',['老花']='老花菜:BAAAKgAFFAIIAgAAAA==.',['耶梦']='耶梦加德:BAAAKgAFFAQIBAAAAA==.',['聖骑']='聖骑士:BAABKgAFFH8GAAIEAAMIIQlFOQC3AAAEAAMIIQlFOQC3AAAAAA==.',['肆德']='肆德:BAABKgAFFH8IAAIWAAMIpQgaCgBvAAAWAAMIpQgaCgBvAAAAAA==.',['肉到']='肉到你呕:BAAAKgADCgMIAwAAAA==.',['肥益']='肥益:BAABKgAFFH8XAAIHAAQIsRviEgDfAAAHAAQIsRviEgDfAAAAAA==.',['胖之']='胖之煞:BAAAKgAECgUIBAAAAA==.',['胖是']='胖是哥的错:BAAAKgAECgQIBAAAAA==.',['胖胖']='胖胖的凯先生:BAAAKgAFFAIIAwAAAA==.',['膜片']='膜片钳:BAAAKgAFFAYIBAABKgAFFAgICQALAKIYAA==.',['至秦']='至秦:BAABKgAFFH8PAAILAAMIDRJUJADVAAALAAMIDRJUJADVAAAAAA==.',['舰娘']='舰娘:BAABKgAFFH8IAAILAAgIeB+iAwCnAgALAAgIeB+iAwCnAgAAAA==.',['色遍']='色遍天下:BAAAKgAECggIEQAAAA==.',['色霸']='色霸霸:BAACKgAFFH8cAAIbAAQISw9GDQAhAQAbAAQISw9GDQAhAQAqAAQKfyAAAhsACAiAGckbAPQBABsACAiAGckbAPQBAAAA.',['艾丝']='艾丝丝:BAAAKgAFFAMIAwAAAA==.',['花儿']='花儿丶:BAAAKgADCggICAAAAA==.',['花样']='花样精:BAABKgAFFH8UAAIRAAYIlxw7CwCjAQARAAYIlxw7CwCjAQAAAA==.',['花楹']='花楹:BAAAKgADCggIDwAAAA==.',['花花']='花花吃手手:BAABKgAFFH8HAAIBAAQIsRl7EwDtAAABAAQIsRl7EwDtAAABKgAFFAgIDwACAJ4TAA==.花花咿呀呀:BAAAKgAFFAQIBAAAAA==.花花果赖:BAAAKgADCgUIBQAAAA==.',['芹澤']='芹澤丶多麼慫:BAAAKgAFFAgIBAAAAA==.',['苏小']='苏小美:BAAAKgAECgIIAgAAAA==.',['苏锦']='苏锦浅清颜:BAACKgAFFH8dAAIOAAQIthAcFgDKAAAOAAQIthAcFgDKAAAqAAQKfyMAAg4ACAglGWwcAPMBAA4ACAglGWwcAPMBAAAA.',['若惜']='若惜莫相离:BAAAKgADCgIIAgAAAA==.',['茶韵']='茶韵如兰:BAAAKgAECgIIAgAAAA==.',['荣耀']='荣耀之炫:BAACKgAFFH8IAAMPAAYIpBqcOQBaAAAPAAII1AicOQBaAAATAAYIpBqMNwAAAAAqAAQKfxoABA8ACAjmE1Y8ACUBAA8ACAj5ElY8ACUBABMABQhnC0leAH0AAA4AAwgACrNeAHYAAAAA.',['菲奥']='菲奥拉:BAACKgAFFH8yAAMLAAUIvxMVIwDaAAALAAQIRBcVIwDaAAANAAEIMQnyLQAhAAAqAAQKfy4AAwsACAjRIOwpAHYCAAsACAjRIOwpAHYCAA0AAQifDAJhACUAAAAA.',['菲菲']='菲菲宝宝:BAAAKgAFFAEIAQAAAA==.',['萌妞']='萌妞:BAAAKgAECgYIBgAAAA==.',['萌新']='萌新小哥:BAAAKgAECgYIDwAAAA==.',['萌老']='萌老婆爱烤鸭:BAAAKgAFFAQIAwAAAA==.',['萌萌']='萌萌的小锤锤:BAAAKgAFFAMIAwAAAA==.',['萌面']='萌面大瞎:BAAAKgAECgMIAwAAAA==.',['萨天']='萨天使:BAAAKgAECgIIAgAAAA==.',['萨巴']='萨巴伦卡:BAAAKgAECgEIAQAAAA==.',['萨库']='萨库拉酱:BAAAKgAFFAgIAQAAAA==.',['萨满']='萨满小祭司:BAAAKgADCgEIAQAAAA==.',['落小']='落小小:BAAAKgADCgIIAgAAAA==.',['落沫']='落沫沫:BAABKgAFFH8TAAIEAAQIMBgHGADUAAAEAAQIMBgHGADUAAAAAA==.',['蒙面']='蒙面虾仁:BAAAKgAECggIDAAAAA==.',['蓝色']='蓝色鸟:BAAAKgAECggIDwAAAA==.',['蔚海']='蔚海:BAAAKgAECgYIBgAAAA==.',['蛋的']='蛋的蛋:BAAAKgADCggICAAAAA==.',['融化']='融化:BAABKgAFFH8PAAIBAAUIdR2nEgA0AQABAAUIdR2nEgA0AQAAAA==.融化丶:BAABKgAFFH8KAAIBAAQIlhi8LwDVAAABAAQIlhi8LwDVAAAAAA==.',['血兽']='血兽来咯:BAABKgAFFH8SAAIEAAYIkyXBCAACAgAEAAYIkyXBCAACAgAAAA==.',['血炎']='血炎丨冰瞳:BAAAKgAFFAMIAwAAAA==.',['血翼']='血翼丶恶魔:BAABKgAFFH8wAAQKAAgIfyBPAQBBAgAKAAgItxhPAQBBAgAcAAgIURTtBgDtAQAdAAQIryG+DgB8AQAAAA==.',['裂您']='裂您:BAAAKgADCggICAAAAA==.',['请以']='请以我为焦点:BAAAKgAECgcICQAAAA==.',['请你']='请你吃冰淇淋:BAAAKgAECgIIAgAAAA==.',['豆包']='豆包:BAAAKgAECgcICAAAAA==.',['豆奶']='豆奶:BAABKgAECn8VAAITAAgIIxy2DwAtAgATAAgIIxy2DwAtAgAAAA==.',['豌豆']='豌豆芽:BAABKgAECn8nAAIJAAgIFiJBBQC2AgAJAAgIFiJBBQC2AgABKgAFFAYIBgABAOkUAA==.',['貝優']='貝優妮撻:BAABKgAFFH8QAAMnAAYIPgvQHAC8AAAnAAYIEQnQHAC8AAAEAAMI/QXRQQCXAAABKgAFFAgICAALAC8jAA==.',['贴苏']='贴苏菲显神威:BAAAKgAFFAEIAQAAAA==.',['超量']='超量恢复:BAAAKgAFFAIIBAABKgAFFAMIBQAdAH0NAA==.',['路过']='路过的七分:BAAAKgADCgUIBQAAAA==.',['跳跳']='跳跳侠:BAAAKgAECgMIAwAAAA==.',['蹦蹦']='蹦蹦球:BAABKgAFFH8LAAIBAAQIWxMcGgDWAAABAAQIWxMcGgDWAAABKgAFFAYIGQAcAL8gAA==.',['辣粥']='辣粥:BAAAKgADCggICAAAAA==.',['达摩']='达摩克利斯:BAABKgAFFH8IAAISAAgITh8IAwCaAgASAAgITh8IAwCaAgAAAA==.',['近水']='近水楼台:BAAAKgAFFAMIAwAAAA==.',['还会']='还会二段跳:BAAAKgADCggICAAAAA==.',['还魂']='还魂:BAAAKgAFFAIIAgAAAA==.',['这儿']='这儿有活人:BAAAKgADCgIIAgAAAA==.',['逆风']='逆风起航:BAAAKgAECgYIBgAAAA==.',['透明']='透明桥:BAACKgAFFH8mAAMkAAQITSVtAgDjAAAQAAQITSUGEQBAAQAkAAMIOhJtAgDjAAAqAAQKfyAAAxAACAhrItsIAHkCABAACAhrItsIAHkCACQABwgaGPEGAOIBAAEqAAUUBAgjABUAcyUA.',['逸朗']='逸朗丶:BAAAKgADCgUIBQAAAA==.',['遁形']='遁形蜘蛛:BAAAKgAECgYIBgABKgAFFAgIBwAQAJYWAA==.',['那一']='那一夜的风光:BAAAKgAECgUIAwAAAA==.',['郭瑞']='郭瑞:BAABKgAECn8WAAIbAAYI3wdfWwDrAAAbAAYI3wdfWwDrAAAAAA==.',['酒杯']='酒杯干碧婷:BAAAKgAFFAYIBAAAAA==.',['酱酱']='酱酱喵:BAAAKgAFFAIIAgAAAA==.',['酸辣']='酸辣汤不要辣:BAAAKgAECgEIAQAAAA==.',['酸酸']='酸酸灬甜甜:BAAAKgADCgYIBgAAAA==.',['野花']='野花的微香:BAABKgAFFH8JAAIHAAMIZhLpMwCrAAAHAAMIZhLpMwCrAAAAAA==.',['鏡花']='鏡花氺月:BAAAKgAECgcIBwAAAA==.',['钟离']='钟离:BAAAKgAECgYIBgAAAA==.',['铁锤']='铁锤丶妹妹:BAAAKgAECgcIBwAAAA==.',['银牛']='银牛姣姣:BAAAKgAECggICgAAAA==.',['锤子']='锤子剪刀布:BAAAKgAFFAIIAgAAAA==.',['长崎']='长崎术世:BAABKgAFFH8GAAIZAAYI1RMBFgBTAQAZAAYI1RMBFgBTAQAAAA==.',['阿修']='阿修罗皇:BAABKgAECn8VAAMbAAgISQfdTQDYAAAbAAgIOwfdTQDYAAAaAAII1wFcSwAMAAAAAA==.',['阿卜']='阿卜杜拉:BAAAKgAECgQIBAAAAA==.',['阿弥']='阿弥陀佛:BAAAKgAECgYIBgAAAA==.',['阿格']='阿格尔斯:BAAAKgADCggICAAAAA==.',['阿法']='阿法新灵:BAAAKgAECggICQAAAA==.',['阿离']='阿离一直调皮:BAAAKgAECgMIAwAAAA==.',['阿舟']='阿舟:BAACKgAFFH8WAAIKAAQIDxZ7FADFAAAKAAQIDxZ7FADFAAAqAAQKf0oAAgoACAinIW8JAJsCAAoACAinIW8JAJsCAAEqAAUUCAgyAAIARRcA.阿舟小德:BAACKgAFFH8yAAICAAgIRRfdAwDUAQACAAgIRRfdAwDUAQAqAAQKf2oAAgIACAhGIKsQAEMCAAIACAhGIKsQAEMCAAAA.阿舟小武:BAACKgAFFH8XAAIfAAQIDhsHFwDqAAAfAAQIDhsHFwDqAAAqAAQKf1YAAh8ACAj1IYgGAJwCAB8ACAj1IYgGAJwCAAEqAAUUCAgyAAIARRcA.阿舟小牧:BAACKgAFFH8aAAIPAAQI9h4CFgAFAQAPAAQI9h4CFgAFAQAqAAQKf1wAAg8ACAifI4gHAKUCAA8ACAifI4gHAKUCAAEqAAUUCAgyAAIARRcA.阿舟小猎:BAACKgAFFH8rAAISAAUI4RuWDwAtAQASAAUI4RuWDwAtAQAqAAQKfzsAAhIACAhkIm4QAKICABIACAhkIm4QAKICAAEqAAUUCAgyAAIARRcA.阿舟小骑:BAACKgAFFH8bAAIMAAQI+h1VDADmAAAMAAQI+h1VDADmAAAqAAQKf2AAAgwACAhwIqkBAKUCAAwACAhwIqkBAKUCAAEqAAUUCAgyAAIARRcA.阿舟小龙:BAACKgAFFH8iAAIgAAQI9CL2AgAnAQAgAAQI9CL2AgAnAQAqAAQKf0EAAiAACAgfIzMBAMMCACAACAgfIzMBAMMCAAEqAAUUCAgyAAIARRcA.阿舟撒满:BAACKgAFFH8iAAIHAAYI7BaUCgBXAQAHAAYI7BaUCgBXAQAqAAQKf0gAAgcACAgUJNoHALMCAAcACAgUJNoHALMCAAEqAAUUCAgyAAIARRcA.',['阿諾']='阿諾:BAAAKgAECgEIAQAAAA==.阿諾丶:BAABKgAECn8UAAIgAAYIrx7DDACcAQAgAAYIrx7DDACcAQAAAA==.',['阿讠']='阿讠若:BAABKgAFFH8SAAIfAAUIBRw2EAAsAQAfAAUIBRw2EAAsAQAAAA==.',['隔壁']='隔壁师兄:BAAAKgAFFAIIAgAAAA==.隔壁老王:BAAAKgADCggIDwAAAA==.',['雪叶']='雪叶新生:BAAAKgAFFAIIAgAAAA==.',['雪步']='雪步:BAAAKgAECgUIBQAAAA==.',['雷电']='雷电奶萨:BAAAKgAECgIIAgAAAA==.',['雷霆']='雷霆法王:BAAAKgAFFAEIAQAAAA==.',['露德']='露德米拉:BAACKgAFFH8KAAIRAAMIshXmEADVAAARAAMIshXmEADVAAAqAAQKfxYAAhEACAi4Hy0PAF4CABEACAi4Hy0PAF4CAAAA.',['青夜']='青夜曠:BAABKgAFFH8OAAMnAAgIzgiwFgDsAAAnAAQIEg2wFgDsAAAEAAQIHQOmRgCFAAAAAA==.',['青木']='青木:BAAAKgAFFAQIBAABKgAFFAgIBgAbABYNAA==.',['青衣']='青衣似水:BAAAKgAECgcICQAAAA==.',['顽皮']='顽皮的七酱:BAABKgAFFH8GAAIZAAYIZgtAGgAzAQAZAAYIZgtAGgAzAQAAAA==.',['风为']='风为:BAACKgAFFH8QAAMcAAUImibNAwDQAQAcAAUImibNAwDQAQAdAAMIaiGrLgCpAAAqAAQKfxYAAxwACAiiJSUFAOsCABwACAiiJSUFAOsCAAoABQgIIqBcAPcAAAAA.',['风吹']='风吹过的夏天:BAAAKgAECgcICQAAAA==.',['风语']='风语烟岚:BAABKgAFFH8QAAILAAYIkRxxDgAaAQALAAYIkRxxDgAaAQAAAA==.',['风间']='风间殇月:BAAAKgAECgEIAQAAAA==.',['风鼓']='风鼓玄旌:BAAAKgAECggIAwAAAA==.',['飞翔']='飞翔小冬冬:BAAAKgAECgEIAQAAAA==.',['馋相']='馋相思:BAAAKgAECgYIDAAAAA==.',['马杀']='马杀鸡:BAAAKgAFFAQIBAAAAA==.',['骑剑']='骑剑:BAAAKgAECgYIBgAAAA==.',['骑士']='骑士七:BAAAKgAECgIIAwAAAA==.骑士乙:BAAAKgAFFAMIAwAAAA==.',['高允']='高允貞:BAAAKgAFFAIIAgAAAA==.',['魔法']='魔法七:BAAAKgADCgEIAQAAAA==.',['鲨手']='鲨手企鹅:BAAAKgAECgYIDgABKgAFFAgIAgADAAAAAA==.',['麦克']='麦克米兰:BAAAKgADCggICQAAAA==.',['黄飞']='黄飞鸿:BAAAKgAFFAMIBAAAAA==.',['黎厉']='黎厉害:BAAAKgAFFAYIBAABKgAFFAgIFAAJAGEfAA==.',['黑羽']='黑羽快斗:BAAAKgAECgEIAQAAAA==.',['默兽']='默兽:BAAAKgAECgMIAwAAAA==.',['黯夜']='黯夜女:BAAAKgAFFAQIBAAAAA==.',['黯朮']='黯朮魅影:BAAAKgAECgQIBAAAAA==.',['黯汐']='黯汐:BAAAKgAECggICwAAAA==.',['黯然']='黯然过往:BAAAKgAECgIIAgAAAA==.',['龙共']='龙共哇哇叫:BAAAKgAECggIDgAAAA==.',['龙臣']='龙臣天下:BAABKgAFFH8FAAIJAAMI2A7sLQDEAAAJAAMI2A7sLQDEAAAAAA==.',['龙龙']='龙龙干趴菜:BAABKgAECn8XAAIUAAgIsgQIIQCWAAAUAAgIsgQIIQCWAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end