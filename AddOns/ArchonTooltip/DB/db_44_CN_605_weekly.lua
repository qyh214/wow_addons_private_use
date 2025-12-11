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
 local lookup = {'Shaman-Elemental','Druid-Restoration','Mage-Arcane','Hunter-BeastMastery','Mage-Frost','Warlock-Destruction','Paladin-Holy','Rogue-Subtlety','Druid-Feral','Druid-Guardian','DeathKnight-Frost','DeathKnight-Blood','Hunter-Marksmanship','Shaman-Restoration','Priest-Holy','Warrior-Protection','Paladin-Retribution','Unknown-Unknown','Druid-Balance',}; local provider = {region='CN',realm='古拉巴什',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Allin:BAAALAADCggICAAAAA==.',Ar='Art:BAABLAAFFH8HAAIBAAUIWAxbDwCLAQABAAUIWAxbDwCLAQABLAAFFAgICAACAL8fAA==.',Bf='Bfo:BAAALAAECggICgAAAA==.',Ca='Calypso:BAAALAAECggICAAAAA==.',El='Elain:BAAALAADCgEIAQAAAA==.Elsanto:BAAALAAFFAQIBAAAAA==.',Es='Est:BAABLAAFFH8LAAIDAAYIaxPLEADgAQADAAYIaxPLEADgAQAAAA==.',Ha='Harukalr:BAABLAAFFH8MAAIEAAYI1RhEKgCLAQAEAAYI1RhEKgCLAQAAAA==.Haung:BAAALAAFFAIIBAAAAA==.',Hu='Huraca:BAAALAADCgEIAQAAAA==.',Ni='Nitoucar:BAABLAAECn8VAAMDAAYIZBVXgwCKAQADAAYIDRRXgwCKAQAFAAIIZxOregB/AAAAAA==.',Rf='Rfo:BAAALAADCgEIAQAAAA==.',Ro='Rorschach:BAABLAAFFH8IAAIGAAMIQQdwUgBrAAAGAAMIQQdwUgBrAAAAAA==.',Sh='Shadowalker:BAAALAAFFAIIAwABLAAFFAgIBgAHAPEJAA==.',Yu='Yui:BAABLAAFFH8MAAICAAYI0QhZJACWAAACAAYI0QhZJACWAAAAAA==.',Zu='Zuiaimeirenb:BAAALAADCgMIAwAAAA==.',['一叶']='一叶书红尘:BAAALAAECgYIBwAAAA==.',['东南']='东南西北:BAAALAAECgIIAgAAAA==.',['丧钟']='丧钟术丶:BAAALAAECgYIDgAAAA==.',['乌云']='乌云弥漫:BAAALAAECggICgAAAA==.',['二混']='二混孒:BAAALAAECgQIBAAAAA==.',['二粒']='二粒蛋:BAAALAADCgYIBgAAAA==.',['五斤']='五斤二两:BAABLAAECn8eAAIIAAcIWQazEgDjAAAIAAcIWQazEgDjAAAAAA==.',['亚日']='亚日:BAAALAAFFAEIAQAAAA==.',['什么']='什么都能忘记:BAAALAAECgYIBgAAAA==.',['伴你']='伴你主城溜达:BAACLAAFFH8cAAIEAAYIKxmnJwCUAQAEAAYIKxmnJwCUAQAsAAQKfx8AAgQABwjyIdcgADgCAAQABwjyIdcgADgCAAAA.',['你们']='你们缺不缺德:BAAALAADCggICAAAAA==.',['光明']='光明天堂:BAAALAAECgYICQAAAA==.',['克里']='克里斯汀娜:BAAALAAECgYIBgAAAA==.',['冷意']='冷意:BAAALAAECgYIBgAAAA==.',['加油']='加油牛牛:BAABLAAFFH8GAAMJAAIIKg2uDgBAAAAJAAIIKg2uDgBAAAAKAAIIdgmBDwAnAAAAAA==.',['千手']='千手大人:BAAALAADCgUIBQAAAA==.',['卷卷']='卷卷毛:BAAALAADCgYIBgAAAA==.卷卷菜:BAAALAADCgYIBgAAAA==.',['吃了']='吃了吗:BAACLAAFFH8JAAIEAAIIQRv3kABEAAAEAAIIQRv3kABEAAAsAAQKfyAAAgQACAgdH7MYAGgCAAQACAgdH7MYAGgCAAAA.',['名字']='名字有点长:BAABLAAFFH8MAAMLAAQIURq0SwAAAQALAAQI+Bm0SwAAAQAMAAIIGBKoDwCKAAAAAA==.',['吾易']='吾易烦:BAAALAAECgYIBgAAAA==.',['哔哔']='哔哔哥:BAAALAAECgYIBgAAAA==.',['多多']='多多学长:BAAALAADCgMIAwAAAA==.',['大地']='大地飞歌:BAAALAAFFAIIAgAAAA==.',['大宇']='大宇哥哥:BAABLAAECn8eAAINAAYIyBWdEQAyAQANAAYIyBWdEQAyAQAAAA==.',['天堂']='天堂向左:BAAALAAECgYIDgAAAA==.',['夭夜']='夭夜:BAAALAAFFAIIAgAAAA==.',['孤星']='孤星:BAABLAAECn8fAAIGAAgIRwmOTQAZAQAGAAgIRwmOTQAZAQAAAA==.',['寒光']='寒光:BAAALAAECgEIAQAAAA==.',['射手']='射手座小欧皇:BAABLAAFFH8RAAIEAAMIuhPwcQB9AAAEAAMIuhPwcQB9AAAAAA==.',['小氯']='小氯:BAAALAAECgYIBgAAAA==.',['小狗']='小狗砸:BAAALAAECgYIDAAAAA==.',['布拉']='布拉维坎屠夫:BAAALAAFFAYIAwAAAA==.',['希尔']='希尔瓦娜丝:BAABLAAFFH8NAAIEAAYImBRCMQB0AQAEAAYImBRCMQB0AQAAAA==.',['慕白']='慕白丶:BAAALAAFFAIIBAAAAA==.',['搓澡']='搓澡:BAAALAADCgcIDQAAAA==.',['无名']='无名的流浪者:BAAALAAECgQIBAAAAA==.',['星月']='星月瞳影:BAABLAAFFH8FAAILAAII9ga5lQA8AAALAAII9ga5lQA8AAAAAA==.',['星界']='星界咏者:BAAALAAECgcIDgAAAA==.',['晴空']='晴空烁星:BAAALAAECgMIAwAAAA==.',['柳如']='柳如烟二帝:BAAALAAECgMIAwAAAA==.',['校尉']='校尉:BAAALAADCgEIAQAAAA==.',['榴莲']='榴莲披萨:BAAALAADCgYIBgAAAA==.',['泥嚎']='泥嚎沃系糕咻:BAABLAAFFH8jAAIEAAYI/CLEEgD2AQAEAAYI/CLEEgD2AQAAAA==.',['清扬']='清扬婉兮:BAACLAAFFH8XAAMBAAUIQg9OJQAcAQABAAUIQg9OJQAcAQAOAAIIcBc/TwB9AAAsAAQKfxUAAw4ABgj8GOItAKwBAA4ABgj8GOItAKwBAAEABgiSF+FiAJABAAAA.',['潮汐']='潮汐:BAAALAAECgIIAgAAAA==.',['爱吃']='爱吃小动物儿:BAAALAAECgYIBwAAAA==.',['牛丸']='牛丸灰灰:BAAALAADCgMIAwAAAA==.',['獠牙']='獠牙之羽:BAAALAAECgUIBQAAAA==.',['痛苦']='痛苦女王:BAAALAADCgYIBgAAAA==.',['白白']='白白的牛:BAAALAAECggICAAAAA==.',['笨笨']='笨笨:BAABLAAFFH8LAAILAAYI2iADIwCoAQALAAYI2iADIwCoAQAAAA==.笨笨丶:BAABLAAFFH8GAAIPAAYIwxjaFwCTAQAPAAYIwxjaFwCTAQAAAA==.笨笨吖:BAABLAAFFH8FAAIEAAUIVg4CVQD6AAAEAAUIVg4CVQD6AAAAAA==.',['红红']='红红宝石:BAAALAAFFAIIAgAAAA==.',['肉末']='肉末茄子:BAAALAAECgYIBgAAAA==.',['胖大']='胖大星:BAABLAAFFH8IAAIQAAIIuAhCKgBpAAAQAAIIuAhCKgBpAAAAAA==.',['胖毛']='胖毛丶:BAAALAAECgMIAgAAAA==.',['花月']='花月軽舞:BAAALAAECggICQAAAA==.',['苍穹']='苍穹之殇:BAAALAAECgIIAgAAAA==.苍穹圣光:BAAALAAECgEIAQAAAA==.苍穹怒风:BAAALAAECgYIBgAAAA==.苍穹撼岳:BAAALAAECgYIBgAAAA==.苍穹灭世:BAAALAAFFAMIAgAAAA==.',['范馬']='范馬勇次郞:BAAALAAECggICAAAAA==.',['藤源']='藤源杰伦:BAABLAAECn8pAAIRAAgIKyLGGQANAwARAAgIKyLGGQANAwAAAA==.',['蟹黄']='蟹黄味瓜子仁:BAAALAAECgMIAwABLAAECgYIBwASAAAAAA==.蟹黄味花生碎:BAAALAAECgYIBgAAAA==.',['血刃']='血刃契约:BAABLAAFFH8MAAMNAAIIhRYWIwCCAAAEAAIITxIjXACOAAANAAIIAxUWIwCCAAAAAA==.',['血色']='血色玫瑰丶:BAAALAAECgIIAgAAAA==.',['裟椤']='裟椤嵐茵:BAAALAADCgIIAgAAAA==.',['诅咒']='诅咒传说:BAACLAAFFH8bAAMFAAUIsA4eEwBLAAADAAQIjw11PQDRAAAFAAEINBMeEwBLAAAsAAQKfxoAAwMACAgiFWMmAIgBAAMACAgiFWMmAIgBAAUABQgbDulcAAEBAAAA.',['请叫']='请叫我帅囻:BAAALAAFFAIIBAAAAA==.',['贝贝']='贝贝:BAAALAADCgIIAgAAAA==.',['逆鳞']='逆鳞之殇:BAAALAAECgYIEAAAAA==.',['酷兰']='酷兰:BAABLAAECn8YAAIPAAgIkxsUFgAWAgAPAAgIkxsUFgAWAgABLAAFFAgILAAPAAknAA==.',['里美']='里美尤利娅:BAAALAADCggICAAAAA==.',['阿泰']='阿泰在冲锋:BAAALAAFFAIIBAAAAA==.',['陌生']='陌生:BAAALAAECgYIBgAAAA==.',['隆骑']='隆骑士:BAAALAAECgYIBgAAAA==.',['霸者']='霸者归来:BAAALAADCggICAAAAA==.',['韦斯']='韦斯特布鲁克:BAABLAAECn8oAAMLAAgI6CD2EgBRAgALAAgI6CD2EgBRAgAMAAgIYw+rIACEAQAAAA==.',['韩哥']='韩哥吃了么:BAAALAAFFAEIAQAAAA==.韩哥吃了吗:BAABLAAFFH8LAAIRAAMILRO9QgCMAAARAAMILRO9QgCMAAAAAA==.韩哥吃了没:BAABLAAFFH8GAAITAAIIIBGyMQA/AAATAAIIIBGyMQA/AAAAAA==.',['飛蛾']='飛蛾:BAAALAADCgEIAQAAAA==.',['飞飞']='飞飞牛:BAABLAAECn8UAAMBAAgIbhZbJQCOAQABAAYIthpbJQCOAQAOAAgIgw84hQB1AQAAAA==.',['骷髅']='骷髅兵:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end