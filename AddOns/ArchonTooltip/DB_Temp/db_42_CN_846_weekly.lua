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
 local lookup = {'Warrior-Fury','DeathKnight-Blood','Paladin-Retribution','Warlock-Destruction','Mage-Fire','Mage-Arcane','Mage-Frost','Warlock-Affliction','Warlock-Demonology','Evoker-Devastation','Monk-Mistweaver','Druid-Guardian','Unknown-Unknown','Druid-Restoration','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Evoker-Preservation',}; local provider = {region='CN',realm='迦罗娜',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ba='Bayonetta:BAAAKgAECggICAAAAA==.',Ha='Hammerko:BAAAKgAECgQIBAAAAA==.',Jr='Jrlori:BAABKgAFFH8GAAIBAAYIMRbODACBAQABAAYIMRbODACBAQAAAA==.',Mi='Milkway:BAAAKgADCgYIBgAAAA==.',['七十']='七十八号:BAAAKgAECgQIBAAAAA==.',['七尾']='七尾妖狐:BAAAKgADCgEIAQAAAA==.',['专炒']='专炒土豆:BAABKgAFFH8HAAICAAQIlQQfLABjAAACAAQIlQQfLABjAAAAAA==.',['五十']='五十几个死骑:BAAAKgADCgQIBAAAAA==.五十几个骑士:BAAAKgAECggICAAAAA==.',['任小']='任小强:BAABKgAFFH8GAAIDAAYImQYeGgATAQADAAYImQYeGgATAQAAAA==.',['任德']='任德鲁:BAAAKgAECgQIBAAAAA==.',['任我']='任我加:BAAAKgAECggICAAAAA==.任我舒:BAABKgAECn8WAAIEAAgIFgz9HAATAQAEAAgIFgz9HAATAQAAAA==.任我骑:BAAAKgAECggICAAAAA==.',['伊泽']='伊泽瑞尔:BAAAKgADCgMIAwAAAA==.',['伏地']='伏地魔菇:BAAAKgAECgQIBQAAAA==.',['休门']='休门坎水:BAAAKgAECgUIBQAAAA==.',['八号']='八号风球:BAABKgAFFH8KAAQFAAgI2xxFCwBFAQAFAAQIGyVFCwBFAQAGAAQIqxbGFgAuAQAHAAIIKRrzFACJAAAAAA==.',['冇毒']='冇毒:BAABKgAFFH8JAAQIAAUIIROADQC7AAAIAAQIigaADQC7AAAEAAQIphFHMACtAAAJAAEIlRdkJABRAAAAAA==.',['加尔']='加尔鲁什酋长:BAABKgAFFH8IAAIBAAgIywxOBgAbAgABAAgIywxOBgAbAgAAAA==.',['加百']='加百利埃洛:BAAAKgADCggICAAAAA==.加百利埃里:BAAAKgADCgMIAwAAAA==.',['加里']='加里奥:BAABKgAFFH8LAAIKAAgIthrkBgAhAgAKAAgIthrkBgAhAgAAAA==.',['北影']='北影阳葵:BAAAKgADCgEIAgAAAA==.',['十点']='十点差三分:BAAAKgADCgEIAQAAAA==.',['千代']='千代:BAAAKgAECgcIBwAAAA==.',['吞萢']='吞萢萢吐圈圈:BAAAKgAECggIEAAAAA==.',['含盐']='含盐的鱼:BAAAKgAFFAEIAQAAAA==.',['四雨']='四雨:BAAAKgADCgQIBwAAAA==.',['圣光']='圣光的复仇:BAAAKgAECggICAAAAA==.',['墨鱼']='墨鱼嘛德德:BAAAKgAECgEIAQAAAA==.',['复杂']='复杂的猎手:BAAAKgAFFAIIAgAAAA==.',['大拙']='大拙手山一程:BAABKgAFFH8IAAILAAQIVghcJQCOAAALAAQIVghcJQCOAAAAAA==.',['大鸟']='大鸟人:BAAAKgAECgEIAQAAAA==.',['夯夯']='夯夯的劣人:BAAAKgAECgYIDgAAAA==.',['妖怒']='妖怒:BAAAKgADCgIIAgAAAA==.',['封号']='封号斗罗:BAAAKgAECgYIBgAAAA==.',['小星']='小星星:BAAAKgAECgEIAQAAAA==.',['小西']='小西瓜丫丫:BAAAKgAFFAMIAwAAAA==.',['小魔']='小魔女:BAAAKgADCgEIAQAAAA==.',['巴啦']='巴啦啦小魔仙:BAAAKgADCgEIAQAAAA==.',['开门']='开门乾天:BAAAKgAFFAIIAgAAAA==.',['张小']='张小凡:BAAAKgADCggICAAAAA==.',['彩依']='彩依琳:BAAAKgAECgQIBgAAAA==.',['德一']='德一德:BAABKgAFFH8HAAIMAAMIWBjjBADRAAAMAAMIWBjjBADRAAAAAA==.',['德艺']='德艺双馨:BAAAKgADCgIIAgAAAA==.',['忒胖']='忒胖:BAAAKgAECgYIEgAAAA==.',['怒秀']='怒秀演技:BAABKgAFFH8IAAILAAgIHAWaCgB+AQALAAgIHAWaCgB+AQAAAA==.',['恶魔']='恶魔天使:BAAAKgAECgMIBgAAAA==.',['我呲']='我呲你咯:BAABKgAFFH8GAAIKAAYIDBEdEwA5AQAKAAYIDBEdEwA5AQAAAA==.',['我是']='我是谁我在哪:BAAAKgAECgQIBAAAAA==.',['手里']='手里剑:BAAAKgADCggICAAAAA==.',['打倒']='打倒三明治:BAAAKgAFFAIIAwAAAA==.',['承影']='承影:BAAAKgADCggICAAAAA==.',['拿铁']='拿铁多加糖:BAAAKgAECgIIAgAAAA==.',['捏麻']='捏麻麻滴:BAAAKgAFFAIIAgAAAA==.捏麻麻滴德:BAAAKgADCgEIAQABKgAFFAIIAgANAAAAAA==.',['放逐']='放逐灵魂:BAAAKgAECgUICAAAAA==.',['杀手']='杀手皇后丶:BAABKgAFFH8UAAIJAAQI2h2GBwADAQAJAAQI2h2GBwADAQAAAA==.',['柠檬']='柠檬有点酸:BAABKgAFFH8FAAIOAAUIzhVyDgAtAQAOAAUIzhVyDgAtAQAAAA==.',['正趣']='正趣果上果:BAABKgAFFH8FAAMPAAQImiRcBQA9AQAPAAQImiRcBQA9AQAQAAEIowfTKAAzAAAAAA==.',['死神']='死神無極:BAAAKgAECgcIDgAAAA==.',['水冰']='水冰儿:BAAAKgADCgEIAQAAAA==.',['洛贝']='洛贝尔:BAABKgAFFH8GAAIRAAYINQdwHQAyAQARAAYINQdwHQAyAQAAAA==.',['海尾']='海尾巴:BAAAKgAECgYICQABKgAFFAIIAwANAAAAAA==.',['海棉']='海棉:BAAAKgAECgUIBgAAAA==.',['清白']='清白之年:BAACKgAFFH8JAAMCAAQIOBP9IwCJAAARAAQImQddPwChAAACAAIIwxn9IwCJAAAqAAQKfxkAAgIACAjLGtQSABQCAAIACAjLGtQSABQCAAAA.',['灬時']='灬時雨灬:BAAAKgAECgMIAwAAAA==.',['灵猫']='灵猫:BAAAKgADCgEIAQAAAA==.',['熊溅']='熊溅溅:BAABKgAFFH8LAAILAAcILBS7DgDwAAALAAcILBS7DgDwAAAAAA==.',['熊老']='熊老哥:BAAAKgAECgEIAQAAAA==.',['爷给']='爷给妞乐一个:BAAAKgAECgYIBgAAAA==.',['狂暴']='狂暴野牛:BAAAKgAECgUICwAAAA==.',['玛斯']='玛斯菲雅:BAAAKgADCggICAAAAA==.',['琬儿']='琬儿:BAABKgAECn8WAAIHAAgIcAocGgDrAAAHAAgIcAocGgDrAAAAAA==.',['疯狂']='疯狂太婆:BAAAKgADCgEIAwAAAA==.',['痛苦']='痛苦与信仰:BAABKgAFFH8GAAIBAAYIvgutCwBTAQABAAYIvgutCwBTAQAAAA==.',['相思']='相思断肠红:BAAAKgADCgEIAgAAAA==.',['稻江']='稻江:BAAAKgADCgMIAwAAAA==.',['第一']='第一天增辉:BAABKgAFFH8MAAMKAAcIbBIbAgCuAQAKAAcIbBIbAgCuAQASAAEI6AMPCgBNAAAAAA==.',['红瞳']='红瞳:BAAAKgAECgMIAwAAAA==.',['给力']='给力的老湿:BAAAKgAFFAYIBAAAAA==.',['绿心']='绿心:BAAAKgAECgQIBAAAAA==.',['耀世']='耀世月光:BAAAKgADCgEIAQAAAA==.',['职业']='职业刷子:BAAAKgAECgMIAwAAAA==.',['胡一']='胡一锤:BAAAKgAECgYIBgAAAA==.',['胡铁']='胡铁花:BAAAKgAECgIIAgAAAA==.',['艾格']='艾格雯:BAAAKgADCggICAAAAA==.',['苏州']='苏州一条龙:BAAAKgAFFAQIBAAAAA==.苏州大铁牛:BAAAKgAECgMIAgAAAA==.苏州粗又硬:BAAAKgADCgIIAgAAAA==.苏州骷髅头:BAAAKgAECgcIDwAAAA==.',['草莓']='草莓:BAAAKgADCgEIAgAAAA==.',['莎莎']='莎莎:BAAAKgAECgMIAwAAAA==.',['萨雷']='萨雷:BAAAKgAECgYIDQAAAA==.',['落媛']='落媛淡雪:BAAAKgAECgEIAQAAAA==.',['赐你']='赐你一壶毒酒:BAAAKgADCggICAAAAA==.',['逍遥']='逍遥丶小子:BAAAKgADCgEIAQAAAA==.',['酷渣']='酷渣:BAAAKgAECgIIAgAAAA==.',['雅洛']='雅洛蓝海瑟薇:BAAAKgAECggICAAAAA==.',['风中']='风中牛儿:BAAAKgADCgQIBAAAAA==.',['飘魂']='飘魂:BAABKgAFFH8IAAIBAAgIsxI+BQArAgABAAgIsxI+BQArAgAAAA==.',['魔导']='魔导士:BAABKgAECn8jAAIHAAgIKRw+EgAxAgAHAAgIKRw+EgAxAgAAAA==.',['鸢尾']='鸢尾:BAAAKgADCgEIAQAAAA==.',['麦子']='麦子郡主:BAABKgAFFH8GAAIGAAYIIRIYEABrAQAGAAYIIRIYEABrAQAAAA==.',['黑暗']='黑暗掌控者:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end