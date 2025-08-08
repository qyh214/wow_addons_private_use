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
 local lookup = {'Warrior-Arms','Warrior-Fury','Warrior-Protection','Warlock-Destruction','Druid-Balance','Paladin-Protection','Hunter-BeastMastery','Unknown-Unknown','Hunter-Marksmanship','DemonHunter-Havoc','DeathKnight-Unholy','Paladin-Retribution','Paladin-Holy','Priest-Holy','Warlock-Demonology','DeathKnight-Blood','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','DemonHunter-Vengeance','Monk-Mistweaver','Mage-Frost','Shaman-Elemental','Druid-Restoration','Rogue-Assassination','Rogue-Outlaw','Mage-Arcane','Shaman-Restoration',}; local provider = {region='CN',realm='阿扎达斯',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ah='Ahkam:BAAAKgAFFAIIAgAAAA==.',Al='Allenalex:BAACKgAFFH8fAAMBAAgIVRzwCgBeAQABAAUIVR/wCgBeAQACAAMI1hQwJgBYAAAqAAQKfzgABAIACAhVJYACAAQDAAIACAhKJYACAAQDAAEABQjTJKMRAA4CAAMAAQg2E0ohADwAAAAA.',Ar='Arlsa:BAAAKgAECgYICwAAAA==.',Cl='Clearlove:BAAAKgAECggICAAAAA==.',Dd='Ddan:BAAAKgADCggICAAAAA==.',Dr='Drankrobber:BAAAKgAFFAEIAQAAAA==.',El='Elegant:BAAAKgADCggICAAAAA==.',Ey='Eye:BAABKgAFFH8GAAIEAAYIqBxjEQB/AQAEAAYIqBxjEQB/AQAAAA==.',Ji='Jiaran:BAABKgAECn8VAAIFAAgIChwoJAApAgAFAAgIChwoJAApAgAAAA==.',Ki='Kin:BAAAKgAECggICAAAAA==.',Mo='Months:BAACKgAFFH8MAAIGAAQIVBpXBwDsAAAGAAQIVBpXBwDsAAAqAAQKfxQAAgYACAiNA4xNAFwAAAYACAiNA4xNAFwAAAAA.',Ti='Tima:BAABKgAFFH8MAAIHAAQIUxT8GgDoAAAHAAQIUxT8GgDoAAAAAA==.',Yl='Yld:BAAAKgAECgMIAwAAAA==.',Yo='Youngj:BAAAKgAECgEIAQAAAA==.Youngn:BAAAKgAECgEIAQAAAA==.',Za='Za:BAAAKgAECgcIBwAAAA==.',['一抹']='一抹气质倾城:BAAAKgAECgIIAgAAAA==.',['七八']='七八五十六:BAAAKgADCggIEAAAAA==.',['丑霸']='丑霸乖:BAAAKgADCgEIAQAAAA==.',['丷筱']='丷筱乄默:BAAAKgADCgcIBwABKgAFFAgIBgAIAAAAAA==.',['二两']='二两肉:BAAAKgAECgMIAwAAAA==.',['云云']='云云丶风行者:BAABKgAFFH8GAAIHAAYIgBn2EQBnAQAHAAYIgBn2EQBnAQAAAA==.',['亢龍']='亢龍有悔:BAABKgAFFH8IAAIJAAgIDRVTBgAFAgAJAAgIDRVTBgAFAgAAAA==.',['以血']='以血洗礼:BAAAKgADCgcIBwAAAA==.',['伊邪']='伊邪那岐丶:BAABKgAFFH8OAAIKAAYIOiLyAAAUAgAKAAYIOiLyAAAUAgAAAA==.',['八八']='八八六十四:BAAAKgAECgYIBgAAAA==.',['八奈']='八奈见杏菜:BAAAKgAECgEIAQAAAA==.',['六德']='六德法:BAAAKgAECgQIBAAAAA==.',['兰纳']='兰纳瑟尔:BAAAKgAECggIDwAAAA==.',['再睡']='再睡一夏:BAAAKgADCgIIAgAAAA==.',['冰封']='冰封雪痕:BAAAKgAECgQIBAAAAA==.',['冷雨']='冷雨幽客:BAAAKgAECgQIBAAAAA==.',['凛冽']='凛冽寒风:BAAAKgAECgMIAwAAAA==.',['初七']='初七:BAAAKgAECgcIDwAAAA==.',['别急']='别急:BAAAKgADCgEIAQAAAA==.',['劳斯']='劳斯丹顿:BAACKgAFFH8HAAILAAII8SSdHAC1AAALAAII8SSdHAC1AAAqAAQKfy4AAgsACAgKIgoVAIICAAsACAgKIgoVAIICAAAA.',['午夜']='午夜听雨:BAABKgAFFH8GAAIMAAYI4RZfIgBjAQAMAAYI4RZfIgBjAQAAAA==.午夜猫猫:BAAAKgAECgIIAgAAAA==.',['卧龙']='卧龙终得雨:BAABKgAECn8WAAMMAAgIlQ0awQAZAQAMAAcIeAkawQAZAQANAAgICQsQKwAPAQAAAA==.',['厑児']='厑児殺斯:BAAAKgADCgEIAQAAAA==.',['叉烧']='叉烧糯米鸡:BAAAKgAECggICAAAAA==.',['只给']='只给男人发烟:BAAAKgAFFAEIAgAAAA==.',['听梦']='听梦:BAABKgAFFH8FAAIOAAMIEAROMgB8AAAOAAMIEAROMgB8AAAAAA==.',['和谐']='和谐排骨:BAAAKgAECgEIAQAAAA==.',['咕我']='咕我在:BAAAKgAECggIDgAAAA==.',['啊排']='啊排归来:BAABKgAECn8YAAMEAAgILhwZCQAKAgAEAAgIyRsZCQAKAgAPAAQISRTkUwCqAAAAAA==.',['土豆']='土豆王子:BAAAKgAECgYIBgAAAA==.',['地狱']='地狱灬:BAACKgAFFH8MAAILAAQImR5ILgDWAAALAAQImR5ILgDWAAAqAAQKfxoAAgsACAjoFXE6AMYBAAsACAjoFXE6AMYBAAAA.',['垂念']='垂念愈恭:BAAAKgAECgEIAQAAAA==.',['堕月']='堕月:BAAAKgAECgQIBAAAAA==.',['墨羽']='墨羽落南山:BAAAKgADCgEIAQAAAA==.',['墨菲']='墨菲斯托丶:BAAAKgAECggICAAAAA==.',['夏川']='夏川丨真凉:BAAAKgADCgcIBwAAAA==.',['夜雨']='夜雨声繁:BAAAKgADCgMIAwAAAA==.',['大佬']='大佬黄灬:BAAAKgAFFAEIAQAAAA==.',['天命']='天命:BAAAKgAECgEIAQAAAA==.',['天天']='天天红豆汤:BAAAKgADCggICAAAAA==.',['天心']='天心:BAAAKgAFFAQIBAAAAA==.',['夯大']='夯大力:BAAAKgAFFAIIAgAAAA==.',['好霸']='好霸霸丶:BAAAKgAFFAQIBAAAAA==.',['妹思']='妹思他棒威:BAAAKgAECgMIAwAAAA==.',['姜明']='姜明子:BAAAKgAFFAIIAgAAAA==.姜明孓:BAAAKgAECgMIAwAAAA==.',['姝释']='姝释:BAAAKgAECgMIAwAAAA==.',['娇姐']='娇姐请抽烟:BAAAKgADCggIDgAAAA==.',['孤独']='孤独落幕:BAAAKgADCggICAAAAA==.',['安然']='安然如一:BAAAKgADCggICAAAAA==.',['小小']='小小的很可爱:BAAAKgAECgUIBQAAAA==.',['小章']='小章鱼:BAAAKgAFFAQIBAAAAA==.',['小黑']='小黑:BAAAKgADCgcIBwAAAA==.小黑骑:BAABKgAFFH8OAAMLAAUIGxAhNADGAAALAAUIGxAhNADGAAAQAAQItQbwKgBpAAABKgAFFAgIFQACALEaAA==.',['尐给']='尐给给:BAABKgAFFH8OAAMRAAYIkBcfBgA2AQARAAUI0hMfBgA2AQASAAQI2R9/AQAqAQAAAA==.',['少女']='少女彐白洁:BAABKgAFFH8QAAMTAAYIFB0iCgB0AQATAAYIAxgiCgB0AQAOAAYIlheHDABbAQAAAA==.少女的梦:BAAAKgAECgYICgAAAA==.',['少惹']='少惹我:BAAAKgADCgUIBQAAAA==.',['布莱']='布莱恩丶铁蛋:BAAAKgAECgcIBwAAAA==.',['幻影']='幻影灬之殇:BAABKgAFFH8FAAIQAAUIPAteGwDIAAAQAAUIPAteGwDIAAAAAA==.',['幽幽']='幽幽狐:BAAAKgAECgEIAQAAAA==.',['影羽']='影羽:BAABKgAFFH8HAAMKAAII2wz9LACAAAAKAAII2wz9LACAAAAUAAEIZghRGwAvAAAAAA==.',['彼岸']='彼岸杀戮:BAAAKgAECgEIAQAAAA==.彼岸永恒:BAAAKgAECggIDgAAAA==.',['德不']='德不到的最好:BAAAKgADCgEIAQAAAA==.',['心之']='心之译文录:BAAAKgAECggICAAAAA==.',['思念']='思念愈涌:BAAAKgAFFAcIAwAAAA==.',['感觉']='感觉被掏空:BAAAKgAECgMIAwAAAA==.',['战牛']='战牛在野:BAAAKgAFFAQIAgAAAA==.',['把钱']='把钱交出来:BAAAKgAECgMIAwAAAA==.',['断绝']='断绝末路:BAABKgAFFH8OAAIVAAYIuh7ZCAChAQAVAAYIuh7ZCAChAQAAAA==.',['无常']='无常美纳斯:BAAAKgAFFAQIAQAAAA==.',['晚风']='晚风斜阳:BAAAKgADCgEIAQAAAA==.',['晨曦']='晨曦秋景:BAAAKgAECgcIDQABKgAFFAYIDgAVALoeAA==.',['杰尼']='杰尼斯:BAAAKgAECgEIAQAAAA==.杰尼斯伍:BAAAKgAECgcIDQAAAA==.杰尼斯六:BAAAKgAECgYICwAAAA==.杰尼斯壹:BAAAKgAECgEIAQAAAA==.杰尼斯拾:BAAAKgAECgYICAAAAA==.杰尼斯斯:BAAAKgAECgQIBAAAAA==.杰尼斯柒:BAAAKgAECgEIAQAAAA==.杰尼斯贰:BAAAKgAECgYICgAAAA==.',['极地']='极地王子:BAAAKgAECgUIBQAAAA==.',['枫之']='枫之哀殇:BAAAKgAECgYIAwAAAA==.',['枫子']='枫子:BAACKgAFFH8LAAIHAAMIExhDKgDcAAAHAAMIExhDKgDcAAAqAAQKfz0AAgcACAglITYQAKQCAAcACAglITYQAKQCAAEqAAUUCAg9AAcAWiMA.',['枼耐']='枼耐法:BAAAKgAECgQIBAAAAA==.',['格瑞']='格瑞夫:BAAAKgAECggIEAAAAA==.',['欧皇']='欧皇丨小萨:BAAAKgADCgEIAQAAAA==.',['水墨']='水墨:BAACKgAFFH8ZAAMMAAQITxSpJADUAAAMAAQITxSpJADUAAAGAAEIjgP8FgAcAAAqAAQKfxgAAgwACAhnHdQ0ACwCAAwACAhnHdQ0ACwCAAAA.',['永远']='永远完美:BAAAKgAFFAgIBAAAAA==.',['流水']='流水飞烟:BAAAKgAFFAIIAgAAAA==.',['海英']='海英特:BAAAKgAECggIBQAAAA==.',['清水']='清水先生:BAAAKgAECgEIAQAAAA==.',['渣女']='渣女蔡思贝:BAAAKgADCggIEAAAAA==.',['温柔']='温柔的兰博:BAAAKgAECgYIEQAAAA==.',['湮糖']='湮糖:BAAAKgAFFAQIBAAAAA==.',['滥精']='滥精灵:BAAAKgAFFAEIAQAAAA==.',['火龙']='火龙伊格尼尔:BAABKgAFFH8eAAIWAAQIyBY2DQDCAAAWAAQIyBY2DQDCAAAAAA==.',['灬神']='灬神牛:BAACKgAFFH8FAAIXAAII5gnUFQBzAAAXAAII5gnUFQBzAAAqAAQKfysAAhcACAigHd8YACQCABcACAigHd8YACQCAAAA.',['灵魂']='灵魂毁灭者:BAABKgAECn8zAAIJAAgI0hrRCwASAgAJAAgI0hrRCwASAgABKgAFFAgICAAHABcdAA==.灵魂鸡米花:BAABKgAFFH8GAAMYAAYIqArmDAC9AAAYAAUIhwnmDAC9AAAFAAEIoghjLwBDAAAAAA==.',['炒饼']='炒饼:BAAAKgAECgEIAgAAAA==.',['烟雨']='烟雨雷电:BAAAKgADCgcIBwAAAA==.',['热烈']='热烈丶的马:BAAAKgADCgEIAQAAAA==.',['焰影']='焰影苇草:BAABKgAFFH8JAAIRAAMIVg8OIwC0AAARAAMIVg8OIwC0AAAAAA==.',['熊猫']='熊猫罐头:BAAAKgADCgYIBgAAAA==.',['爱打']='爱打架的猫:BAABKgAFFH8GAAIMAAYI+haUGwCHAQAMAAYI+haUGwCHAQAAAA==.',['爱贫']='爱贫嘴的猫:BAABKgAFFH8MAAIEAAYIfSGzDwCVAQAEAAYIfSGzDwCVAQAAAA==.',['爱逆']='爱逆推的猫:BAABKgAFFH8KAAIZAAYIQxHNDACAAQAZAAYIQxHNDACAAQAAAA==.',['狼铛']='狼铛:BAACKgAFFH8bAAIaAAQIESG6AgAbAQAaAAQIESG6AgAbAQAqAAQKfx8AAhoACAgyIWUCAJ8CABoACAgyIWUCAJ8CAAEqAAUUCAgnABoASBoA.',['玄德']='玄德爱香香:BAAAKgAFFAMIAwAAAA==.',['王睿']='王睿哥哥啊哒:BAAAKgAECgQIBAAAAA==.',['百里']='百里东君:BAAAKgAECgYICAAAAA==.',['看起']='看起来很好吃:BAAAKgAECgMIAwAAAA==.',['碳棒']='碳棒:BAAAKgADCgMIBAAAAA==.',['祎祎']='祎祎不舍:BAAAKgAECgcICAAAAA==.',['神灬']='神灬奇奶茶:BAAAKgAECgUIBQAAAA==.',['神箭']='神箭阿菠萝:BAAAKgAECgEIAQAAAA==.',['空条']='空条徐伦:BAAAKgADCgcIBwAAAA==.',['筱绿']='筱绿绿:BAABKgAFFH8IAAIEAAgI0w1nDADGAQAEAAgI0w1nDADGAQAAAA==.',['织法']='织法者:BAABKgAECn8dAAMWAAgIxyKnCADEAgAWAAgIxyKnCADEAgAbAAUIhRVCUQD5AAABKgAFFAYIDgAVALoeAA==.',['肉酱']='肉酱君:BAAAKgAECgQIBAAAAA==.',['花花']='花花很忧郁:BAAAKgADCgEIAQAAAA==.',['花边']='花边边:BAAAKgADCggICAAAAA==.',['草色']='草色烟光:BAAAKgADCggICAAAAA==.',['荷塘']='荷塘路小佩奇:BAAAKgAECgYIBgAAAA==.',['莫问']='莫问大叔:BAAAKgADCggIFgAAAA==.',['蓑笠']='蓑笠翁:BAAAKgAFFAIIBAAAAA==.',['蔡思']='蔡思贝:BAAAKgADCggICAAAAA==.',['薯条']='薯条:BAAAKgAECggIEQAAAA==.',['虾仁']='虾仁丶不眨眼:BAABKgAFFH8FAAIcAAUIeATbIAD2AAAcAAUIeATbIAD2AAAAAA==.',['蛋猪']='蛋猪超人:BAAAKgADCggICAAAAA==.',['西北']='西北望:BAAAKgAFFAIIAgAAAA==.',['谜语']='谜语人邪:BAAAKgAECgIIAgAAAA==.',['辣星']='辣星星:BAAAKgAFFAcIBAAAAA==.',['辣辣']='辣辣星:BAAAKgAFFAQIBAAAAA==.',['迈向']='迈向阳光余晖:BAAAKgADCggICAAAAA==.',['迪亚']='迪亚波罗丶:BAABKgAFFH8HAAILAAcINRxmBwAcAgALAAcINRxmBwAcAgAAAA==.',['那怎']='那怎么办呢:BAAAKgADCggICAAAAA==.',['酷酷']='酷酷小萌德:BAAAKgADCgQIBQAAAA==.',['野牛']='野牛两个半:BAAAKgAECgEIAQAAAA==.',['铁铳']='铁铳酋长:BAABKgAFFH8GAAIJAAYIYxLYFgAvAQAJAAYIYxLYFgAvAQABKgAFFAgIBAAIAAAAAA==.',['長風']='長風:BAAAKgAECgMIAwAAAA==.',['阿格']='阿格拉玛:BAAAKgAECgQIBQAAAA==.',['隐秘']='隐秘追猎:BAAAKgAECggICAAAAA==.',['雪舞']='雪舞凌霜:BAAAKgADCgYIBgAAAA==.',['雷克']='雷克斯:BAAAKgAFFAIIBAAAAA==.',['霜寒']='霜寒裁决使:BAACKgAFFH8SAAMWAAQIvg2qGACzAAAWAAQIvg2qGACzAAAbAAIIrgSdQABVAAAqAAQKfyIAAxYACAgXGuAUABUCABYACAgXGuAUABUCABsAAgh9CEKUADwAAAAA.',['颓废']='颓废陈小囧:BAAAKgAFFAIIAgAAAA==.',['风里']='风里有詩句:BAAAKgAFFAgIBAAAAA==.',['骑猪']='骑猪看日出:BAAAKgAECggICwAAAA==.',['黑幕']='黑幕魅影:BAAAKgADCgIIAgAAAA==.',['龙星']='龙星:BAAAKgAECgMIAwAAAA==.',['龙蛇']='龙蛇福至:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end