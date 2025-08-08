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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Druid-Balance','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Assassination','Mage-Arcane','Mage-Frost','Mage-Fire','DeathKnight-Blood','Warlock-Destruction','Paladin-Protection','Evoker-Devastation','Monk-Brewmaster','Shaman-Restoration','Paladin-Retribution','Priest-Discipline','Priest-Holy','Paladin-Holy','Warrior-Arms','Warlock-Demonology','Warrior-Protection','Druid-Guardian','Warrior-Fury','Monk-Mistweaver','Monk-Windwalker','Unknown-Unknown','Shaman-Elemental','Rogue-Outlaw','Priest-Shadow',}; local provider = {region='CN',realm='瓦里玛萨斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Archidden:BAAAKgAECgYICwAAAA==.',As='Asetulip:BAACKgAFFH8WAAIBAAUIUBudIAAcAQABAAUIUBudIAAcAQAqAAQKfyMAAwEACAhgICQZAEQCAAEACAhgICQZAEQCAAIABgjNBa8hALMAAAAA.',Cy='Cyndi:BAABKgAFFH8GAAIDAAYIuwyWEQBLAQADAAYIuwyWEQBLAQAAAA==.',De='Derson:BAAAKgADCgEIAQAAAA==.',Go='Gojin:BAAAKgADCgEIAQAAAA==.',Io='Iotk:BAAAKgAECgMIAwAAAA==.',Jo='Jomi:BAAAKgADCgcICgAAAA==.',Ke='Keyker:BAAAKgAECgYIBgAAAA==.',Op='Opill:BAAAKgADCggICAAAAA==.',Ti='Timmy:BAABKgAFFH8QAAMEAAYIthhoBAByAQAEAAYIthhoBAByAQAFAAQIngk3HQDOAAAAAA==.',Yo='Yoly:BAAAKgADCggIBgAAAA==.',['一只']='一只奶咕咕:BAAAKgAFFAYIAgAAAA==.',['一库']='一库:BAAAKgADCggICAAAAA==.',['一森']='一森林一:BAACKgAFFH9HAAMDAAgIhSDOBAB8AgADAAgIhSDOBAB8AgAGAAQIaAZDKQCAAAAqAAQKfysAAgMACAiPIxQRAKICAAMACAiPIxQRAKICAAAA.',['三级']='三级模特:BAAAKgADCgcIBwAAAA==.',['不羁']='不羁的灵魂:BAAAKgAECgcICwAAAA==.',['且末']='且末:BAAAKgAECggICAAAAA==.',['丛林']='丛林是我家:BAAAKgADCgMIAwAAAA==.',['丨我']='丨我宝宝呢:BAABKgAECn8VAAMHAAgIbh9jEwA3AgAHAAgInx5jEwA3AgAIAAUI+hmfZACEAQAAAA==.',['丨遗']='丨遗忘丶夢:BAAAKgAECggIDgAAAA==.',['丶木']='丶木丶木丶:BAAAKgAECgUIBQAAAA==.',['丽影']='丽影鬼魅:BAAAKgADCggICwAAAA==.',['乘风']='乘风子:BAAAKgAECgUIBQAAAA==.',['九九']='九九归真:BAABKgAFFH8JAAIJAAYIqh3hAADoAQAJAAYIqh3hAADoAQAAAA==.',['九宝']='九宝:BAABKgAFFH8NAAQKAAYIyx6VCgC4AQAKAAYI7RuVCgC4AQALAAQI3xsTEQDaAAAMAAIINwuqMACIAAABKgAFFAgIJwAMAOgeAA==.九宝琉璃塔:BAAAKgAFFAYIBAAAAA==.',['从接']='从接吻开始:BAAAKgAFFAIIAgAAAA==.',['仟丶']='仟丶锋:BAAAKgAECggICgAAAA==.',['仰天']='仰天长啸:BAABKgAFFH8OAAMBAAYIeQtMGgBLAQABAAYIeQtMGgBLAQANAAQITgZVKwBnAAAAAA==.',['伊瑟']='伊瑟莱尔:BAAAKgAECgQIBAAAAA==.',['你伤']='你伤不起:BAAAKgAFFAQIBAAAAA==.',['你哥']='你哥我突然就:BAAAKgAECgYIBgAAAA==.',['侵蚀']='侵蚀之影:BAAAKgADCggICAAAAA==.',['光速']='光速任者:BAACKgAFFH8IAAMKAAMIiQOKOwBzAAAKAAMIFQOKOwBzAAALAAEIsAMIJQAtAAAqAAQKfyoAAwoACAjGDZgeAC8BAAoACAitDZgeAC8BAAsABwhQBhJjAOIAAAAA.',['六岁']='六岁逃课刷本:BAAAKgADCggICAAAAA==.六岁逃课接怪:BAAAKgADCgEIAQAAAA==.',['冯万']='冯万宁别整我:BAAAKgAECgMIAwAAAA==.',['冰之']='冰之哀:BAAAKgADCggICAAAAA==.',['冰血']='冰血邪魂:BAABKgAFFH8IAAMBAAIINwIHIABQAAABAAIINwIHIABQAAANAAIIoAHiEwA6AAAAAA==.',['冰镇']='冰镇饮料:BAAAKgADCggIDgAAAA==.',['初吻']='初吻给了谁:BAABKgAFFH8OAAIOAAgItROnCAAEAgAOAAgItROnCAAEAgAAAA==.',['别打']='别打字看不懂:BAABKgAFFH8GAAIPAAYITw0FEQD6AAAPAAYITw0FEQD6AAAAAA==.',['刹月']='刹月:BAAAKgAFFAQIBAAAAA==.',['加勒']='加勒比幽兰:BAAAKgADCgQIBAAAAA==.',['十亿']='十亿少女的梦:BAABKgAFFH8IAAIQAAYIvxhgDwBqAQAQAAYIvxhgDwBqAQAAAA==.',['千棱']='千棱幻玉:BAAAKgAECgMIBAAAAA==.',['千煌']='千煌雷烈:BAAAKgAECgYICQAAAA==.',['半部']='半部人生:BAAAKgAECgQIBAAAAA==.',['双生']='双生火焰:BAAAKgADCggICAAAAA==.',['反者']='反者道之动:BAAAKgAECgQICAAAAA==.',['发光']='发光的蹄妹:BAAAKgAECggIDAAAAA==.',['取名']='取名废:BAABKgAECn8dAAIMAAgIkA39QgB9AQAMAAgIkA39QgB9AQAAAA==.',['后盾']='后盾:BAABKgAFFH8HAAIIAAMIAA5mGwC9AAAIAAMIAA5mGwC9AAAAAA==.',['哼哼']='哼哼哈嘿:BAAAKgADCggICAAAAA==.',['啊喀']='啊喀琉斯:BAABKgAECn8dAAMBAAgIQRbCNwDSAQABAAgIQRbCNwDSAQANAAEIAwo2aQAlAAABKgAFFAgICAANAL0eAA==.',['四点']='四点水:BAAAKgAECgIIAgAAAA==.',['困死']='困死了:BAAAKgAFFAQIBAAAAA==.',['圣菲']='圣菲尔璐丝:BAAAKgADCggICAAAAA==.',['大杰']='大杰森:BAAAKgAFFAYIAgAAAA==.',['大羿']='大羿:BAAAKgADCgEIAQAAAA==.',['大肥']='大肥鹌鹑:BAAAKgAECgIIAgAAAA==.',['奉先']='奉先:BAAAKgADCgYIBgAAAA==.',['奉眠']='奉眠:BAABKgAFFH8MAAMNAAYIZiWYBAAHAgANAAYIZiWYBAAHAgABAAYI1BLeFgBmAQAAAA==.',['奥丁']='奥丁:BAAAKgAECgMIAwAAAA==.',['奥利']='奥利维亚:BAABKgAFFH8FAAIRAAMImwVyCABvAAARAAMImwVyCABvAAAAAA==.',['奧妮']='奧妮克希亞:BAABKgAFFH8MAAIQAAYITx1PEABcAQAQAAYITx1PEABcAQABKgAFFAgIGwAQACwhAA==.',['奶萨']='奶萨:BAAAKgAECggIAgAAAA==.',['如若']='如若往生:BAABKgAECn9JAAISAAgIGx2AHQAXAgASAAgIGx2AHQAXAgAAAA==.',['宁羽']='宁羽星城:BAABKgAECn8WAAMHAAcI8QUFewCJAAAHAAcIPAUFewCJAAAIAAII2wS+wwA8AAAAAA==.',['完美']='完美净化:BAABKgAFFH8GAAITAAIIOwzxeAB3AAATAAIIOwzxeAB3AAAAAA==.',['宫妃']='宫妃娜羊:BAAAKgAECgIIAgAAAA==.',['審判']='審判魔女:BAAAKgADCgYIBgAAAA==.',['射月']='射月战将:BAAAKgADCgIIAgAAAA==.',['小乔']='小乔刘水人家:BAABKgAFFH8GAAISAAMITw/YHACUAAASAAMITw/YHACUAAAAAA==.',['小德']='小德玛利亚:BAABKgAFFH8IAAIDAAMIHwT6JgCFAAADAAMIHwT6JgCFAAAAAA==.',['小猪']='小猪最乖:BAABKgAFFH8IAAMUAAMIxgVlJQCKAAAUAAMIwwVlJQCKAAAVAAIIQgMOHwBBAAAAAA==.',['小莫']='小莫加:BAABKgAFFH8MAAIOAAYIYw6RHAAiAQAOAAYIYw6RHAAiAQAAAA==.',['小魚']='小魚:BAABKgAECn8fAAMTAAgIAQxuRgDuAAATAAgIAQxuRgDuAAAWAAIIEQrtIABIAAAAAA==.',['小鱼']='小鱼人:BAAAKgAECgcIEAAAAA==.',['希尔']='希尔瓦纳丝:BAABKgAFFH8IAAIIAAgIVw6oCgDDAQAIAAgIVw6oCgDDAQAAAA==.',['平凡']='平凡的男人:BAAAKgADCgQIBAAAAA==.',['幻龙']='幻龙师:BAAAKgAECgcIDgAAAA==.',['幽幽']='幽幽天狼:BAAAKgAFFAgIBAAAAA==.幽幽天行:BAAAKgAECggICAAAAA==.',['库拉']='库拉莎:BAAAKgAECgUICgABKgAECggIMQAHAAcQAA==.',['库斯']='库斯卡雷:BAABKgAFFH8KAAMNAAYIxw38DQDPAAABAAQIdRbwLQDXAAANAAYIFwP8DQDPAAAAAA==.',['建御']='建御名方:BAABKgAECn8dAAIXAAcIYxKLDgBUAQAXAAcIYxKLDgBUAQAAAA==.',['弹指']='弹指托油塔:BAAAKgADCgQIBAAAAA==.',['德克']='德克嘉尔:BAAAKgADCgUIBQAAAA==.',['怒海']='怒海孤鸿:BAABKgAFFH8HAAIYAAMI3g7uCAC6AAAYAAMI3g7uCAC6AAAAAA==.',['恶小']='恶小恶:BAAAKgAECgYIBgAAAA==.',['悠茗']='悠茗:BAAAKgAECgYIBgAAAA==.',['想个']='想个名字先:BAABKgAECn8dAAITAAgIYiY4BAAPAwATAAgIYiY4BAAPAwAAAA==.',['意中']='意中人:BAAAKgAECgIIAgAAAA==.',['愤怒']='愤怒孤鸿:BAABKgAECn8bAAIZAAgI1AjFKQDgAAAZAAgI1AjFKQDgAAAAAA==.',['慈溪']='慈溪太后:BAABKgAECn8iAAMDAAgIbREgHABxAQADAAgIbREgHABxAQAGAAgIDgtgGgDrAAAAAA==.',['我是']='我是男人呀:BAAAKgAECgMIAwAAAA==.',['战栗']='战栗的龙卷:BAAAKgAECgEIAQAAAA==.',['打企']='打企鹅豆豆:BAAAKgAECgIIAgAAAA==.',['搭小']='搭小辫子就长:BAAAKgAECgYIBgAAAA==.',['教兽']='教兽:BAAAKgAECgQIBAAAAA==.',['文夏']='文夏奈尔:BAABKgAFFH8IAAIKAAgIKQ4DCQDkAQAKAAgIKQ4DCQDkAQAAAA==.',['新的']='新的航行:BAAAKgAFFAYIBAAAAA==.',['无愧']='无愧于心:BAAAKgAECgUIBQAAAA==.',['无雨']='无雨之鱼:BAAAKgAECggICQAAAA==.',['晓枫']='晓枫残月:BAABKgAFFH8IAAITAAQIlRR2JADWAAATAAQIlRR2JADWAAAAAA==.晓枫殘月:BAAAKgAFFAQIBAAAAA==.',['晓琳']='晓琳:BAABKgAFFH8GAAIJAAYIIAnFEABEAQAJAAYIIAnFEABEAQAAAA==.',['暖阳']='暖阳阳:BAAAKgADCggICAAAAA==.',['暗夜']='暗夜魅姬:BAACKgAFFH8IAAMEAAMIogLgDwBkAAAEAAMIogLgDwBkAAAFAAEIvQFETwAgAAAqAAQKfxUAAwQACAhUDKQvAAoBAAQACAhLDKQvAAoBAAUAAQiDDQabADAAAAAA.',['暗黑']='暗黑蹄妹:BAAAKgAECgYIBgAAAA==.',['月光']='月光小酸酸:BAABKgAFFH8IAAIXAAQIXRZGCgDtAAAXAAQIXRZGCgDtAAAAAA==.',['月舞']='月舞凝曦:BAABKgAFFH8KAAMOAAYI/h3eEQB6AQAOAAUIch/eEQB6AQAYAAIIMBi8JgBLAAAAAA==.',['来了']='来了老弟:BAAAKgADCggICgAAAA==.',['杯中']='杯中喵:BAAAKgAFFAgIAgAAAA==.',['林灵']='林灵灵:BAAAKgADCgEIAQAAAA==.',['法力']='法力宝贝:BAAAKgADCgQIBAAAAA==.',['泰美']='泰美眉和香蕉:BAAAKgADCggIDwAAAA==.',['流行']='流行色:BAABKgAFFH8FAAISAAUIXhTdFgAnAQASAAUIXhTdFgAnAQAAAA==.',['济世']='济世清风:BAAAKgADCggIDAAAAA==.',['浮光']='浮光掠影:BAAAKgAFFAEIAQAAAA==.',['海绵']='海绵宝宝:BAAAKgADCgIIAgAAAA==.',['淡蛋']='淡蛋的忧伤:BAAAKgAECggIEAAAAA==.',['清净']='清净:BAAAKgAECggICAAAAA==.',['清风']='清风孤鸿:BAAAKgAECgMIAwAAAA==.清风明月孤鸿:BAAAKgAECggIEgAAAA==.清风朗月:BAABKgAFFH8LAAILAAMI2Ab/DgCdAAALAAMI2Ab/DgCdAAAAAA==.清风清风:BAACKgAFFH8hAAIaAAQIQxD/AgCYAAAaAAQIQxD/AgCYAAAqAAQKfy0AAhoACAjyEqENAHoBABoACAjyEqENAHoBAAAA.清风萨萨:BAABKgAFFH8QAAISAAMIVBjeLADDAAASAAMIVBjeLADDAAAAAA==.',['渝渊']='渝渊:BAAAKgAECggICAAAAA==.',['漫天']='漫天风雪:BAABKgAFFH8FAAIHAAMIwg/nLQC1AAAHAAMIwg/nLQC1AAAAAA==.',['激流']='激流:BAABKgAECn8cAAISAAgI1xlqJQDsAQASAAgI1xlqJQDsAQAAAA==.',['灭绝']='灭绝师妹:BAAAKgAECgMIAwAAAA==.',['烤串']='烤串大青柠:BAAAKgAECggICAAAAA==.',['然叶']='然叶:BAAAKgADCggICAAAAA==.',['熙熙']='熙熙不熙熙:BAAAKgAECggICAAAAA==.',['牛人']='牛人头人牛:BAAAKgAECgMIAwAAAA==.',['牛牛']='牛牛拧妞妞:BAAAKgAECgMIAwAAAA==.',['特克']='特克塞爾:BAAAKgADCgEIAQAAAA==.',['特利']='特利丝杰娜:BAAAKgAECgEIAQAAAA==.',['特立']='特立独行的猪:BAABKgAFFH8GAAILAAYIySF1AgDyAQALAAYIySF1AgDyAQAAAA==.',['狂吃']='狂吃两大碗:BAAAKgADCgQIBAAAAA==.',['猎小']='猎小猎:BAAAKgADCgIIAgAAAA==.',['猎杀']='猎杀新手:BAAAKgAECgYIBgAAAA==.',['琉璃']='琉璃:BAABKgAFFH8QAAMLAAgICBKFAgAOAgALAAgICBKFAgAOAgAKAAIIggN0SAAwAAAAAA==.',['瓦纳']='瓦纳多罗:BAAAKgADCgQIBAAAAA==.',['瓦雷']='瓦雷迪斯:BAABKgAFFH8GAAMFAAYI+A4OHwDDAAAFAAIIzBkOHwDDAAAEAAQIwAeYGgB9AAAAAA==.',['甜品']='甜品:BAAAKgADCggIEAAAAA==.',['白银']='白银之灵:BAAAKgAECgIIAgAAAA==.',['相思']='相思重相忆:BAABKgAFFH8YAAMXAAYIRhhFCACHAQAXAAYIRhhFCACHAQAbAAYIZxDoDgBmAQAAAA==.',['神秘']='神秘百合:BAAAKgADCggIEAAAAA==.',['稻天']='稻天盗地:BAAAKgAECgIIAgAAAA==.',['笑天']='笑天笑天:BAAAKgADCgUIBQAAAA==.',['红浪']='红浪漫十六号:BAAAKgAECggIEgAAAA==.',['约书']='约书亚加百列:BAAAKgADCgcIBwAAAA==.',['绚彩']='绚彩猪猪:BAAAKgADCgIIAgAAAA==.',['绯色']='绯色清空:BAAAKgAFFAIIAgAAAA==.',['罪之']='罪之辛德蕾拉:BAAAKgADCgYIBgAAAA==.',['翠色']='翠色芳菲:BAABKgAFFH8GAAIEAAYINxQmBwAtAQAEAAYINxQmBwAtAQAAAA==.',['老懒']='老懒:BAAAKgAECgIIAgAAAA==.',['老灰']='老灰狗:BAAAKgADCgMIAwAAAA==.',['老炮']='老炮儿:BAAAKgAFFAQIBAAAAA==.',['老鼠']='老鼠夹子:BAAAKgADCggICAAAAA==.',['胡图']='胡图鲁鲁:BAAAKgAECggICAAAAA==.',['舞之']='舞之花幻月:BAAAKgAECgUIBwAAAA==.',['艾露']='艾露妮萨:BAAAKgADCgQIBAAAAA==.',['花前']='花前月下:BAAAKgAECgUIBQAAAA==.',['花果']='花果山:BAAAKgADCgMIAwAAAA==.',['花花']='花花下的太阳:BAABKgAFFH8IAAIWAAQI+iVoBwA9AQAWAAQI+iVoBwA9AQAAAA==.花花生西西:BAACKgAFFH8HAAIcAAYIVAuJBAByAQAcAAYIVAuJBAByAQAqAAQKfxoAAxwACAgWFJ4qAK0BABwACAgWFJ4qAK0BAB0AAwj1C9NUAKkAAAAA.',['苏达']='苏达姬:BAABKgAECn8XAAIVAAgIIQjPHwDQAAAVAAgIIQjPHwDQAAAAAA==.',['莉卡']='莉卡茜娜:BAABKgAECn8xAAIHAAgIBxCBRQA7AQAHAAgIBxCBRQA7AQAAAA==.',['菲尔']='菲尔加斯:BAAAKgAECgcIDgABKgAECggIMQAHAAcQAA==.',['萨小']='萨小萨:BAAAKgAECgcIBwAAAA==.',['蓝色']='蓝色法神:BAABKgAFFH8IAAMLAAQIjxmMFQDAAAALAAQIjxmMFQDAAAAKAAQI+hNjKgC5AAAAAA==.蓝色游魂:BAABKgAFFH8OAAMHAAYIHhpzEQBYAQAHAAYIpRdzEQBYAQAIAAQIjyDWKgDaAAAAAA==.蓝色萨满:BAABKgAFFH8SAAISAAYIix/gAADKAQASAAYIix/gAADKAQAAAA==.',['虚妄']='虚妄之光:BAAAKgADCgUIBQABKgAECggIQAASAMMXAA==.',['蚀魄']='蚀魄:BAAAKgAECgEIAQAAAA==.',['蜡笔']='蜡笔不二熊:BAAAKgAECgYIDQAAAA==.蜡笔文心兰:BAAAKgADCggICAABKgAECgYIDQAeAAAAAA==.',['行者']='行者熊:BAAAKgADCgIIAgAAAA==.',['袴田']='袴田日向:BAACKgAFFH8sAAITAAcIZBwlDADgAQATAAcIZBwlDADgAQAqAAQKfzUAAhMACAjKJHkPANACABMACAjKJHkPANACAAAA.',['诉予']='诉予汹涌:BAABKgAECn8XAAITAAgIPxsRPgA1AgATAAgIPxsRPgA1AgAAAA==.',['贝塔']='贝塔:BAABKgAECn83AAMSAAgIXw0WIwAXAQASAAgIXw0WIwAXAQAfAAcIKAooHQDkAAAAAA==.',['赫小']='赫小敏:BAAAKgAFFAQIBAAAAA==.',['路痴']='路痴美美:BAAAKgAECgUICQAAAA==.',['轻烟']='轻烟漫舞:BAAAKgAFFAIIAgAAAA==.',['轻舟']='轻舟:BAABKgAFFH8GAAIHAAYIeRsUCQCbAQAHAAYIeRsUCQCbAQAAAA==.',['轻风']='轻风之呢喃:BAAAKgAFFAIIAgABKgAFFAgIBgAEADcUAA==.',['迢迢']='迢迢:BAAAKgAECgYIBgAAAA==.',['迷人']='迷人的小姨子:BAAAKgAECgMIAwAAAA==.',['追星']='追星逐月:BAABKgAECn8bAAMCAAgIMxaqEgCAAQACAAYIDBqqEgCAAQANAAcI+AmdMQDIAAAAAA==.',['逝幕']='逝幕旳年华:BAABKgAFFH8GAAIMAAYIUSOdCAC6AQAMAAYIUSOdCAC6AQAAAA==.',['邪蜜']='邪蜜:BAAAKgAECgMIAwAAAA==.',['部落']='部落投石车:BAABKgAFFH8IAAIgAAgIOQ5JAQDiAQAgAAgIOQ5JAQDiAQAAAA==.',['醉美']='醉美是相遇:BAABKgAFFH8RAAIcAAcI2RVZBwA0AQAcAAcI2RVZBwA0AQAAAA==.',['钱多']='钱多多:BAAAKgADCggICAAAAA==.',['锦之']='锦之苍龙:BAAAKgADCgEIAQAAAA==.',['闪电']='闪电奔涌:BAABKgAECn8YAAIfAAgIECENDQCHAgAfAAgIECENDQCHAgAAAA==.',['阮大']='阮大发丶:BAAAKgAFFAIIAgABKgAFFAgICAAUAPoIAA==.',['防骑']='防骑:BAAAKgAECgIIAgAAAA==.',['阿佛']='阿佛洛狄忒:BAAAKgAECggICAAAAA==.',['阿斯']='阿斯图利亚斯:BAABKgAECn8hAAQXAAgIqBY2KAB4AQAXAAgIIwo2KAB4AQAbAAUIYhimOwAxAQAZAAYImQ6qIQD0AAAAAA==.',['阿氪']='阿氪萌德:BAABKgAECn8UAAMDAAgIMBfQMwDbAQADAAcIlRrQMwDbAQAaAAEI0wJrSAAJAAAAAA==.',['阿泽']='阿泽:BAABKgAFFH8HAAIQAAMIfx0FIADDAAAQAAMIfx0FIADDAAAAAA==.',['降龙']='降龙拾捌掌:BAAAKgAECgYIDAAAAA==.',['难德']='难德糊涂:BAABKgAFFH8MAAMDAAYIyQw0HwAlAQADAAYIyQw0HwAlAQAGAAQIzBAqIQCkAAAAAA==.',['雄狮']='雄狮之安德烈:BAAAKgADCgIIAgAAAA==.',['雨落']='雨落弦断:BAAAKgADCgUICQAAAA==.',['靓仔']='靓仔麦迪:BAAAKgADCggIDgAAAA==.',['风暴']='风暴之结:BAAAKgAFFAQIBAAAAA==.',['马戏']='马戏团出来的:BAAAKgAECgYIDQAAAA==.',['骄矜']='骄矜必败:BAAAKgAECggIDAAAAA==.',['骆神']='骆神:BAAAKgAECgMIBAAAAA==.',['骑士']='骑士科特:BAAAKgAECggICQAAAA==.',['骑小']='骑小骑:BAABKgAECn8qAAITAAgICBJ9bAB/AQATAAgICBJ9bAB/AQAAAA==.',['骑蜗']='骑蜗牛的猪:BAAAKgAFFAgIBAAAAA==.',['鬼雄']='鬼雄项羽:BAAAKgAECgIIAgAAAA==.',['魔域']='魔域来生:BAAAKgAFFAQIBAAAAA==.',['麦当']='麦当劳帮主:BAAAKgAECgMIAwAAAA==.',['黑帝']='黑帝斯:BAAAKgAECgMIAwAAAA==.',['黑麦']='黑麦别士忌:BAABKgAECn9IAAMOAAgIjyZrAAAXAwAOAAgIjyZrAAAXAwAYAAEI7iEVcQBWAAAAAA==.',['龙吟']='龙吟姚姚:BAAAKgAECgUIBQAAAA==.龙吟瑶瑶:BAABKgAECn9JAAQUAAgIqh+kDgA5AgAUAAcIdyGkDgA5AgAVAAgIJxvzHADbAQAhAAYIhQ4UQgDwAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end