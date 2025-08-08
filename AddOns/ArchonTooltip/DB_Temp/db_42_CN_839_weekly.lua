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
 local lookup = {'Warrior-Arms','Paladin-Retribution','Monk-Brewmaster','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Protection','Priest-Discipline','Priest-Holy','Warlock-Affliction','Druid-Balance','Druid-Restoration','Mage-Arcane','Mage-Frost','Shaman-Restoration','Hunter-Marksmanship','Mage-Fire','Priest-Shadow','Hunter-BeastMastery','Warrior-Fury','DemonHunter-Vengeance','Monk-Mistweaver','Rogue-Assassination','Rogue-Outlaw','DemonHunter-Havoc','Paladin-Holy','Shaman-Elemental','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Rogue-Subtlety','Monk-Windwalker','DeathKnight-Frost','Warrior-Protection','Shaman-Enhancement',}; local provider = {region='CN',realm='达斯雷玛',name='CN',type='weekly',zone=42,date='2025-08-02',data={Am='Aminat:BAAAKgAECggICQAAAA==.',Ap='Apocalypse:BAAAKgAFFAQIBAAAAA==.Applegol:BAAAKgAECgMIAwAAAA==.',Av='Avenger:BAAAKgAFFAQIBAAAAA==.',Be='Benetnasch:BAAAKgADCgcIBwAAAA==.',Ec='Echopchy:BAAAKgAECgQIBQAAAA==.',El='Ellywick:BAABKgAFFH8KAAIBAAgIfxOKBAD4AQABAAgIfxOKBAD4AQAAAA==.',Fo='Foreverjh:BAAAKgADCgEIAQAAAA==.',Ma='Macrosszts:BAAAKgAECgYIBgAAAA==.Makoto:BAABKgAECn8XAAICAAgIbhs/OwA9AgACAAgIbhs/OwA9AgAAAA==.',Mi='Mika:BAAAKgAECgYICwAAAA==.',Si='Silverwolf:BAABKgAFFH8IAAIDAAgIfgkYAgBxAQADAAgIfgkYAgBxAQAAAA==.',Vi='Vigarst:BAAAKgAECgEIAQAAAA==.',Wh='Whitepanda:BAAAKgAECgIIAgAAAA==.',Wo='Wordnuo:BAABKgAFFH8FAAIEAAUIOg3qIwAFAQAEAAUIOg3qIwAFAQAAAA==.',Xx='Xxiao:BAAAKgAECgMIAwAAAA==.',['一二']='一二:BAABKgAFFH8QAAMEAAQI4yAOCAAqAQAEAAQI4yAOCAAqAQAFAAQIyxsGGgDSAAABKgAFFAgIBgAFAOACAA==.',['一无']='一无情一:BAAAKgAFFAEIAQAAAA==.',['一言']='一言难尽:BAAAKgADCgQIBAAAAA==.',['一黄']='一黄金太阳一:BAAAKgAECgUIBgAAAA==.',['七喜']='七喜:BAAAKgAECgEIAQAAAA==.',['上帝']='上帝禁区丨:BAAAKgAECgMIAwAAAA==.',['不吃']='不吃靖哥哥:BAAAKgAECggICAAAAA==.',['与妮']='与妮共舞:BAAAKgAFFAYIAgAAAA==.',['丨小']='丨小浣熊丨:BAAAKgAECgMIAwAAAA==.',['丶羁']='丶羁绊:BAAAKgADCgMIAwAAAA==.',['丶青']='丶青莲剑歌:BAABKgAFFH8SAAMGAAgISxyRAgBxAgAGAAgISxyRAgBxAgACAAQI1xCOWgC8AAAAAA==.',['主治']='主治医师飘飘:BAABKgAFFH8SAAMHAAYIdiIaBgDPAQAHAAYIQR8aBgDPAQAIAAYIUh63CACbAQABKgAFFAgIEgAHAGQaAA==.',['乄灬']='乄灬礻申:BAAAKgADCgEIAQAAAA==.',['乄黑']='乄黑眼圈乄:BAAAKgAECgEIAQAAAA==.',['二大']='二大妈:BAAAKgAECgQIBAAAAA==.',['五晨']='五晨寺小拳王:BAAAKgADCggICAAAAA==.',['仁狐']='仁狐:BAABKgAECn9AAAIJAAgIfwNcJwCpAAAJAAgIfwNcJwCpAAAAAA==.',['仙咕']='仙咕丶:BAACKgAFFH8bAAMKAAQIawtCPgCxAAAKAAQIawtCPgCxAAALAAEIPgIxJwAuAAAqAAQKf1sAAwoACAiiHUMgAEACAAoACAiiHUMgAEACAAsAAgiNA+B3ADAAAAAA.',['传说']='传说中的天蝎:BAAAKgADCgEIAQAAAA==.传说的高育良:BAAAKgAECggIBgAAAA==.',['你压']='你压我头发了:BAAAKgAFFAQIBAAAAA==.',['你又']='你又:BAACKgAFFH8KAAIKAAYIsB6/BwAyAQAKAAYIsB6/BwAyAQAqAAQKfxoAAgsACAgoGG4JAN0BAAsACAgoGG4JAN0BAAAA.',['你还']='你还有遗憾吗:BAABKgAFFH8PAAICAAQIGhQVTwDRAAACAAQIGhQVTwDRAAAAAA==.',['俺家']='俺家俺最富:BAABKgAFFH8GAAIMAAYIvRkkEABqAQAMAAYIvRkkEABqAQAAAA==.',['倚天']='倚天箭:BAACKgAFFH8VAAINAAQIUhRBFADGAAANAAQIUhRBFADGAAAqAAQKfzcAAw0ACAjlID8LAIUCAA0ACAjlID8LAIUCAAwAAggjDdI8AFsAAAAA.',['光头']='光头睿睿:BAAAKgADCgEIAQAAAA==.',['六道']='六道众生:BAAAKgAECgYIBwAAAA==.',['兰珑']='兰珑:BAAAKgADCgIIAgAAAA==.',['再不']='再不斩丶:BAAAKgAECggIEAABKgAFFAgIDgAOABUPAA==.',['再长']='再长一百斤:BAABKgAFFH8GAAIEAAYIMhegEQDzAAAEAAYIMhegEQDzAAAAAA==.',['冰火']='冰火王子:BAAAKgADCgUIBQAAAA==.',['冰糖']='冰糖葫璐儿:BAAAKgAECgMIBQAAAA==.',['凝乐']='凝乐:BAABKgAECn8XAAIFAAgIdAmRNQCxAAAFAAgIdAmRNQCxAAAAAA==.',['凯西']='凯西:BAAAKgADCgMIAwAAAA==.',['凱西']='凱西:BAAAKgADCgEIAQAAAA==.',['别特']='别特耀跳了:BAAAKgAECgYIBgAAAA==.',['剩豆']='剩豆士:BAAAKgADCggICAAAAA==.',['劳资']='劳资蜀道山:BAABKgAECn8dAAIPAAgI8RVXEwCbAQAPAAgI8RVXEwCbAQAAAA==.',['勤瘦']='勤瘦:BAACKgAFFH8GAAIQAAYIRyEYDAA8AQAQAAYIRyEYDAA8AQAqAAQKfxcAAxAACAiGGy4PAOYBABAACAjdGi4PAOYBAAwAAwiJEl9BAEkAAAAA.',['勥丨']='勥丨夜殇:BAAAKgAECgcIBwAAAA==.勥丨審判:BAAAKgAECgYIDwAAAA==.',['千万']='千万伏特:BAAAKgAFFAIIAgAAAA==.',['华帝']='华帝:BAAAKgADCgEIAQAAAA==.',['卡布']='卡布力拓:BAAAKgADCggIDgAAAA==.',['可爱']='可爱的小德:BAAAKgAFFAEIAQAAAA==.',['叶华']='叶华:BAAAKgAFFAIIAgAAAA==.',['叶子']='叶子要飞了:BAAAKgAECgMIAwAAAA==.',['叶落']='叶落深秋:BAAAKgADCgcICgAAAA==.',['后半']='后半夜的小二:BAABKgAFFH8GAAIGAAYIMAVmCwDMAAAGAAYIMAVmCwDMAAAAAA==.后半夜的鱼:BAABKgAFFH8NAAMGAAcIBxDLBgBoAQAGAAcIbg/LBgBoAQACAAIIAxEAAAAAAAAAAA==.后半夜的黑:BAABKgAFFH8GAAIFAAYIywFSDQCiAAAFAAYIywFSDQCiAAAAAA==.',['吹蜜']='吹蜜儿:BAAAKgAECgIIAQAAAA==.',['咋哒']='咋哒啦猎任:BAAAKgADCggICAAAAA==.',['咲玖']='咲玖玖灬:BAAAKgAECggICgAAAA==.',['响当']='响当当:BAAAKgAECggIEQAAAA==.',['哎呀']='哎呀丶难顶:BAACKgAFFH81AAQHAAgIYR01CACeAQAHAAcISiA1CACeAQAIAAYIMx2lCgB3AQARAAIIoxpBHACiAAAqAAQKf0IABAcACAi1JiEEANACAAcACAiJJiEEANACAAgACAirHnwxAHwBABEABQiOC7FSAKEAAAAA.',['喝水']='喝水时憋气:BAAAKgAECgIIAgAAAA==.',['喵小']='喵小乖:BAAAKgADCggICAAAAA==.',['噬魂']='噬魂子夜:BAAAKgADCgcIBwAAAA==.',['回忆']='回忆的天空:BAAAKgAFFAEIAQAAAA==.',['坡上']='坡上村副村长:BAAAKgADCggICAAAAA==.坡上村高富帅:BAAAKgADCgIIAgAAAA==.',['墓地']='墓地老板丨火:BAAAKgADCggICAAAAA==.墓地老板丨电:BAAAKgADCggICAAAAA==.',['声波']='声波:BAAAKgAECgMIAwAAAA==.',['复仇']='复仇之魂:BAAAKgAECggICAAAAA==.',['夏末']='夏末晨曦:BAABKgAFFH8GAAISAAYIigniGwAjAQASAAYIigniGwAjAQAAAA==.',['多福']='多福战神:BAAAKgAECgcIBwAAAA==.',['夜雨']='夜雨风轻:BAAAKgAECgcICgAAAA==.',['大叔']='大叔就是好:BAAAKgAECggICwAAAA==.',['大司']='大司命:BAAAKgAFFAMIAwAAAA==.',['大胡']='大胡子:BAABKgAFFH8QAAMHAAYIAiFEAgCbAQAHAAYIAiFEAgCbAQARAAQImBR3EADcAAAAAA==.',['天海']='天海春香:BAAAKgADCgYIBgAAAA==.',['天野']='天野殇:BAAAKgADCgEIAQAAAA==.',['奔跑']='奔跑的大叔:BAAAKgAECgMIBQAAAA==.',['奶量']='奶量如果有限:BAAAKgADCgUIBQAAAA==.',['好运']='好运宝宝:BAABKgAFFH8IAAIMAAYIpBmvDwBwAQAMAAYIpBmvDwBwAQAAAA==.',['妖妖']='妖妖零:BAACKgAFFH8RAAITAAQINRhLEAD5AAATAAQINRhLEAD5AAAqAAQKfx4AAhMACAgCIAYTAG8CABMACAgCIAYTAG8CAAAA.',['妖精']='妖精的旋律:BAABKgAFFH8GAAIIAAYI8haMCABYAQAIAAYI8haMCABYAQAAAA==.',['娇滴']='娇滴滴的肉丸:BAAAKgAFFAEIAQAAAA==.',['孟德']='孟德的白月光:BAAAKgAFFAYIAgAAAA==.',['守门']='守门大爷:BAAAKgAECgMIBAAAAA==.',['安妮']='安妮没有熊丶:BAAAKgAECgQIBAAAAA==.',['家有']='家有小姨子:BAAAKgAFFAgIBAAAAA==.',['寂寞']='寂寞长天:BAAAKgAECgIIAgAAAA==.',['小嘎']='小嘎哩皇不辣:BAAAKgAECggIDwAAAA==.',['小小']='小小飞牛:BAAAKgAECgEIAgAAAA==.',['小豆']='小豆角:BAABKgAFFH8GAAIKAAYILggSIAAfAQAKAAYILggSIAAfAQAAAA==.',['少昊']='少昊:BAAAKgAFFAgIBAAAAA==.',['尘暮']='尘暮夕:BAABKgAECn8bAAIUAAgI7wy+EAAcAQAUAAgI7wy+EAAcAQAAAA==.',['尼哥']='尼哥丶:BAAAKgAFFAYIBAAAAA==.',['屠龙']='屠龙刀:BAABKgAECn8XAAIOAAgI/guwXAAVAQAOAAgI/guwXAAVAQAAAA==.',['帛曳']='帛曳:BAAAKgADCgUIBQAAAA==.',['幸玉']='幸玉强:BAAAKgADCggICwAAAA==.',['幻西']='幻西:BAAAKgADCggIEAAAAA==.',['床底']='床底下的黑影:BAAAKgADCgMIBAAAAA==.',['康斯']='康斯父:BAAAKgAECgYIBwAAAA==.',['影月']='影月风行者:BAAAKgAFFAYIAgAAAA==.',['心飞']='心飞扬丶雪碧:BAAAKgAECgIIAgAAAA==.',['思愿']='思愿:BAABKgAFFH8FAAIVAAUIjxDNFAAAAQAVAAUIjxDNFAAAAQAAAA==.',['恶魔']='恶魔悟空:BAAAKgAFFAQIBAAAAA==.',['我在']='我在故我变:BAAAKgAECggICgAAAA==.',['扎两']='扎两个马尾吧:BAAAKgAECgYIBwAAAA==.',['扎个']='扎个双马尾丶:BAAAKgAECggIBQAAAA==.',['打个']='打个栗子:BAABKgAECn8fAAICAAgIPx+0PAA5AgACAAgIPx+0PAA5AgAAAA==.',['拾拾']='拾拾贰:BAAAKgAFFAQIAQAAAA==.',['撒斯']='撒斯阿尔:BAAAKgADCgcIBwAAAA==.',['撼天']='撼天者逍遥:BAABKgAFFH8FAAIKAAUIZxxcGABVAQAKAAUIZxxcGABVAQAAAA==.',['改名']='改名也叫牛德:BAAAKgAECgUICAAAAA==.',['无限']='无限修仙:BAAAKgAECgUIBQAAAA==.',['星德']='星德守月:BAACKgAFFH8HAAIWAAYIlBJSBwCZAQAWAAYIlBJSBwCZAQAqAAQKfxQAAxYACAgDE20NAEgBABYACAgDE20NAEgBABcAAggTEIUOAGIAAAAA.',['是风']='是风动:BAAAKgADCggICAAAAA==.',['晓月']='晓月残雪:BAAAKgAECgIIAgAAAA==.',['晓楠']='晓楠:BAAAKgAFFAEIAQAAAA==.',['月丶']='月丶夜神:BAABKgAFFH8VAAMFAAQItxn7GgDKAAAEAAMI6RehKwDfAAAFAAQItxn7GgDKAAAAAA==.',['木子']='木子:BAAAKgAECggIDgAAAA==.木子一小德:BAAAKgAECgQIBgAAAA==.木子一恶魔:BAAAKgAFFAIIAgAAAA==.',['朴实']='朴实无华:BAAAKgAECgYIBwAAAA==.',['朴素']='朴素无华:BAAAKgADCggICwAAAA==.',['来自']='来自海底:BAAAKgADCgYIBgAAAA==.',['梦里']='梦里回梦如她:BAABKgAECn9AAQMCAAgI7SbiAQAgAwACAAgI7SbiAQAgAwAGAAIIlQq/XQAuAAABKgAFFAgIEgAGAOocAA==.',['武穆']='武穆逸风:BAAAKgADCggICAAAAA==.',['毒傷']='毒傷:BAAAKgAFFAgIAgAAAA==.',['毛文']='毛文婕:BAAAKgADCgUIBQAAAA==.',['毛骑']='毛骑配霞:BAAAKgAECgQIBAAAAA==.',['没事']='没事溜溜:BAAAKgADCggICAAAAA==.',['没有']='没有双手武器:BAAAKgADCgEIAQAAAA==.',['洛丹']='洛丹伦的记忆:BAAAKgADCgUIBQAAAA==.',['活噗']='活噗萨:BAAAKgAFFAIIAgAAAA==.',['流氓']='流氓难啊:BAAAKgADCggICwAAAA==.',['海边']='海边小筑:BAABKgAFFH8GAAICAAYIVhsmGACbAQACAAYIVhsmGACbAQAAAA==.海边小茿:BAAAKgAFFAYIAQAAAA==.',['清笙']='清笙挽喻:BAABKgAFFH8HAAIEAAYIJxEICwBjAQAEAAYIJxEICwBjAQAAAA==.清笙挽歌:BAABKgAFFH8FAAIYAAUIJwVmFADpAAAYAAUIJwVmFADpAAAAAA==.',['清蒸']='清蒸狮子头:BAAAKgAFFAIIAgAAAA==.',['清风']='清风丶小骚蹄:BAAAKgADCggICAAAAA==.',['灬孽']='灬孽魂:BAABKgAFFH8GAAMNAAYIzRC2CQDhAAANAAQIvBG2CQDhAAAMAAIIZw9RMQCeAAAAAA==.',['灬神']='灬神棍德:BAAAKgAFFAIIBAAAAA==.',['灬阿']='灬阿桀灬:BAABKgAFFH8bAAMCAAYIGBC+IgBhAQACAAYIGBC+IgBhAQAZAAQIPQctFACaAAAAAA==.',['灬魍']='灬魍魉鬼魅:BAAAKgAECggICAAAAA==.',['灬魔']='灬魔魇:BAAAKgADCggICAAAAA==.',['灵朵']='灵朵:BAABKgAFFH8IAAMPAAgIqBNpCACrAQAPAAcIvxVpCACrAQASAAEIHAf3LABJAAAAAA==.',['為妳']='為妳變乖:BAAAKgAECggIDQAAAA==.',['烟雨']='烟雨行舟:BAAAKgAECgYIBgAAAA==.',['無上']='無上大梵天:BAAAKgAFFAgIAgAAAA==.',['熊貓']='熊貓妹紙:BAAAKgADCgYIBgAAAA==.',['燃尽']='燃尽风华:BAAAKgAECgQIBAAAAA==.',['爆炒']='爆炒黑芝麻:BAAAKgADCgEIAQAAAA==.',['爱晒']='爱晒太阳的云:BAAAKgAECgUICgAAAA==.',['狂野']='狂野之刃:BAABKgAFFH8HAAIEAAcIOwMgDQAqAQAEAAcIOwMgDQAqAQAAAA==.',['独爱']='独爱月:BAABKgAFFH8QAAMSAAgIax29CwAlAQAPAAYIsSGiDwBqAQASAAgIVRm9CwAlAQAAAA==.',['琉璃']='琉璃终易碎:BAABKgAFFH8GAAINAAYI8w7MCQAoAQANAAYI8w7MCQAoAQAAAA==.',['疯狂']='疯狂的大叔:BAAAKgAECgIIAwAAAA==.',['皇爷']='皇爷爷:BAAAKgAECgYIEAAAAA==.',['盘古']='盘古之力:BAAAKgAECgYIBgAAAA==.',['睡到']='睡到丶自然醒:BAAAKgADCgcIBwAAAA==.',['矮子']='矮子里面拔大:BAAAKgADCggIEAAAAA==.',['神昭']='神昭焚天:BAAAKgAECgcIBwAAAA==.',['秀荣']='秀荣:BAAAKgAECgMIAwAAAA==.',['空空']='空空伊:BAABKgAFFH8IAAIPAAgITxGmBwDmAQAPAAgITxGmBwDmAQAAAA==.',['等等']='等等硪灬:BAABKgAECn8fAAIEAAgICBqVKwDOAQAEAAgICBqVKwDOAQAAAA==.',['筱潇']='筱潇:BAAAKgAECgYIBgAAAA==.',['简娜']='简娜:BAABKgAFFH8NAAMYAAQI0QreHQDLAAAYAAQI0QreHQDLAAAUAAIIkAGmFgBHAAAAAA==.',['米奈']='米奈希尔灬灵:BAABKgAFFH8GAAMEAAQIGAg7HAC3AAAEAAQImQc7HAC3AAAFAAII2wHfIwA/AAAAAA==.',['索大']='索大妈:BAAAKgADCggICAAAAA==.索大爷:BAAAKgAECgcIDAAAAA==.',['红葱']='红葱哥:BAABKgAFFH8QAAMPAAQIkiFpBAAsAQAPAAQIkiFpBAAsAQASAAQIQB0AHQDiAAABKgAFFAgIHAAMAPgfAA==.',['纯变']='纯变态:BAAAKgAFFAUIAQAAAA==.',['纯棉']='纯棉:BAAAKgAECgMIAwAAAA==.',['组我']='组我丶有灌注:BAAAKgAECgcIBwAAAA==.',['绅士']='绅士疯范:BAABKgAECn8ZAAITAAgIFB9dFQAsAgATAAgIFB9dFQAsAgAAAA==.',['绿光']='绿光之意:BAABKgAECn8ZAAIIAAgIVBQyLgBuAQAIAAgIVBQyLgBuAQAAAA==.',['绿萝']='绿萝裙之舞:BAAAKgAECgMIBAAAAA==.',['翻滾']='翻滾吧牛寶寶:BAABKgAECn8iAAIaAAgIXxUYCwDUAQAaAAgIXxUYCwDUAQAAAA==.',['老牛']='老牛看像你不:BAAAKgADCggICAAAAA==.',['聖光']='聖光的祈祷:BAAAKgAFFAMIAwAAAA==.',['舞夜']='舞夜狂飙:BAABKgAFFH8GAAIBAAYIZx/nBgCpAQABAAYIZx/nBgCpAQAAAA==.',['艾斯']='艾斯:BAAAKgAECgcIDAAAAA==.',['芝士']='芝士小猫:BAABKgAECn8lAAQbAAgI3RycDwBSAgAbAAgIzRycDwBSAgAcAAgICRwjBgDaAQAdAAQIQBmcBADFAAAAAA==.',['芭比']='芭比丨牧:BAAAKgADCgEIAQAAAA==.',['若无']='若无:BAAAKgAECgUIBQAAAA==.',['莫非']='莫非不空:BAABKgAFFH8OAAIZAAYIqhYwBAAGAQAZAAYIqhYwBAAGAQAAAA==.',['菜瓜']='菜瓜:BAAAKgAFFAQIBAAAAA==.',['萌了']='萌了吧唧:BAAAKgAECgMIAwAAAA==.',['萌萌']='萌萌哒的秃头:BAAAKgADCgYIBgAAAA==.',['萘紫']='萘紫:BAAAKgADCgMIAwAAAA==.',['蓝色']='蓝色烟花:BAAAKgADCgEIAQAAAA==.',['蓝莓']='蓝莓慕斯:BAAAKgAFFAQIBAAAAA==.',['薇尔']='薇尔麗特:BAAAKgAFFAgIAgAAAA==.',['蜂蜜']='蜂蜜柚子茶:BAAAKgADCggICAAAAA==.',['血查']='血查理诺兰:BAACKgAFFH8GAAINAAIIAQo+JABuAAANAAIIAQo+JABuAAAqAAQKfxwAAg0ACAgDFvkKAM0BAA0ACAgDFvkKAM0BAAAA.',['血祭']='血祭天涯:BAABKgAECn8XAAMEAAgIPyBfNADgAQAEAAgIPyBfNADgAQAFAAYI0gQnTgCDAAABKgAFFAYIEQAeADgXAA==.',['血管']='血管外科:BAAAKgAECggICQAAAA==.',['血色']='血色丨回忆:BAAAKgADCgEICAAAAA==.',['装饰']='装饰你的梦:BAAAKgAFFAEIAQAAAA==.',['西门']='西门塔尔:BAAAKgADCgEIAQAAAA==.',['調戲']='調戲伱:BAAAKgAFFAQIAwAAAA==.',['诗诗']='诗诗:BAAAKgADCgIIAgAAAA==.',['请先']='请先生赴死丶:BAAAKgAECgQIBgAAAA==.',['诺基']='诺基亚:BAAAKgAECgIIAgAAAA==.',['诺米']='诺米叔叔:BAACKgAFFH8SAAQMAAcImBHwEABhAQAMAAUIgRPwEABhAQAQAAMI5grZIQDPAAANAAIIiwKOLgAtAAAqAAQKfy4ABBAACAggHFUpAAECABAACAiJGlUpAAECAA0ABwgXDTFTABgBAAwABQhHErlQAPwAAAAA.',['赛貂']='赛貂蝉:BAABKgAFFH8IAAIYAAQIpBOaMAC8AAAYAAQIpBOaMAC8AAAAAA==.',['赵柒']='赵柒柒:BAAAKgAFFAgIBAAAAA==.',['起大']='起大飞:BAABKgAFFH8DAAIVAAMIHA4mDwC2AAAVAAMIHA4mDwC2AAAAAA==.',['起飞']='起飞飞:BAABKgAECn8VAAMfAAcIUhVuIwCEAQAfAAcI0xRuIwCEAQADAAEIfBNEIgA5AAAAAA==.',['超级']='超级大苦力:BAAAKgAFFAgIBAAAAA==.',['躺尸']='躺尸三百宿:BAAAKgAFFAEIAQAAAA==.',['还能']='还能再顶一下:BAAAKgAECgYIBgAAAA==.',['逐风']='逐风者一炮神:BAAAKgAECgMIBgAAAA==.',['郑阿']='郑阿伦:BAAAKgAECgQIBAAAAA==.',['钓鱼']='钓鱼要带头盔:BAAAKgADCgMIAwAAAA==.',['铁牢']='铁牢里的囚徒:BAAAKgADCggIFAAAAA==.',['闹一']='闹一气:BAACKgAFFH8lAAMNAAUIzho3DgDyAAANAAQI4Rg3DgDyAAAMAAUIkA5hNQCMAAAqAAQKfxgAAg0ACAiDHwwRAHcCAA0ACAiDHwwRAHcCAAAA.',['闹来']='闹来闹去:BAACKgAFFH8hAAMEAAQIVRkgKgDkAAAEAAQIVRkgKgDkAAAgAAMIlAi9CwCsAAAqAAQKfxwAAgQACAhIGwElACgCAAQACAhIGwElACgCAAAA.',['阴影']='阴影徘徊者:BAAAKgAFFAQIBAAAAA==.',['阿尔']='阿尔班神牛:BAABKgAFFH8KAAMBAAgIbRvxAwAQAgABAAYIqyTxAwAQAgAhAAQI7wnIAQAvAQAAAA==.',['阿布']='阿布无敌丨猎:BAABKgAFFH8FAAIPAAUIWB6lFQA2AQAPAAUIWB6lFQA2AQAAAA==.',['阿花']='阿花:BAAAKgAECgUICAAAAA==.',['陈伟']='陈伟达:BAAAKgAECgQIBAAAAA==.',['随便']='随便遛哒:BAABKgAFFH8GAAIWAAYIMxYYDQB8AQAWAAYIMxYYDQB8AQAAAA==.',['雅雅']='雅雅小红手:BAAAKgAECgYIBgAAAA==.',['雪之']='雪之韵:BAAAKgAFFAQIBAAAAA==.',['雷雷']='雷雷德:BAABKgAFFH8GAAMLAAYIrwy7FwDjAAALAAUIsg67FwDjAAAKAAEI5gaNXABCAAAAAA==.',['霓裳']='霓裳:BAAAKgAECgQIBAAAAA==.',['青岛']='青岛大姨:BAABKgAFFH8PAAMBAAYIJhaMAQCzAQABAAYIJhaMAQCzAQATAAQI5RYQDwD+AAAAAA==.',['青柑']='青柑普洱:BAAAKgAFFAEIAQAAAA==.',['静待']='静待花开:BAAAKgADCggICQAAAA==.',['韦德']='韦德伍兹:BAABKgAFFH8GAAIVAAYI+h4uBwDFAQAVAAYI+h4uBwDFAQAAAA==.',['香莲']='香莲:BAAAKgAECgUIBQAAAA==.',['魂之']='魂之守卫敌法:BAABKgAFFH8GAAIYAAYI/hrnDgCWAQAYAAYI/hrnDgCWAQAAAA==.魂之挽歌:BAABKgAFFH8FAAMEAAMI1xduKgDjAAAEAAMI1xduKgDjAAAFAAII1QlBLwBSAAAAAA==.',['鸡子']='鸡子儿:BAAAKgAECggICAAAAA==.',['鸡血']='鸡血注入:BAAAKgAECggIAwAAAA==.',['麦兜']='麦兜好大叔:BAAAKgAECgcIBwAAAA==.',['麦扣']='麦扣儿乔丹丶:BAAAKgAFFAQIBAAAAA==.',['麦淇']='麦淇酪灬幻西:BAABKgAECn8XAAQOAAgI7gZTYgAZAQAOAAgI7gZTYgAZAQAaAAYIVB31RgAGAQAiAAMIogRFWABOAAAAAA==.',['黑嘎']='黑嘎嘎的黑:BAAAKgADCgEIAQAAAA==.',['黑旋']='黑旋风儿:BAAAKgAFFAgIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end