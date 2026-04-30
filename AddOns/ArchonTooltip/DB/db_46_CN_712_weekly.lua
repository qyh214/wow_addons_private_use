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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Mage-Frost','Monk-Brewmaster','DemonHunter-Devourer','Shaman-Restoration','Druid-Restoration','Druid-Balance','Warrior-Fury','DemonHunter-Havoc','Priest-Shadow','Priest-Discipline',}
local provider = {region='CN',realm='杜隆坦',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amani:BAAALgAECgIJAgAAAA==.',
Gt='Gtbrh:BAAALgAECgYJCgAAAA==.',
Ja='Jayang:BAAALgAECgMJBQAAAA==.',
Kh='Khunter:BAAALgAECgEJAQAAAA==.',
La='Lancome:BAAALgAECgIJAgAAAA==.',
Na='Navigator:BAAALgADCgIJAgAAAA==.',
Po='Poem:BAAALgAECgUJBgAAAA==.',
Sa='Samann:BAAALgAECgEJAQAAAA==.',
Va='Valenti:BAAALgAECgEJAgAAAA==.',
Yo='Yonsize:BAAALgAECgYJCQAAAA==.',
['Yù']='Yùyc:BAAALgAECgcJDAAAAA==.',
['一击']='一击即中:BAAALgAECgQJBwAAAA==.',
['一栀']='一栀子紫一:BAAALgAECgYJBgAAAA==.',
['一闪']='一闪一亮:BAAALgADCgcJBwAAAA==.',
['丶董']='丶董盼盼:BAAALgADCgIJAgAAAA==.',
['乔佳']='乔佳:BAAALgADCgEJAQAAAA==.',
['九尾']='九尾雪狐:BAAALgAECgEJAQAAAA==.',
['云熙']='云熙阅朗:BAABLgAFFH8FAAIBAAIJlw8XPQCyAAABAAIJlw8XPQCyAAAAAA==.',
['五道']='五道杠大队长:BAAALgADCgYJBgAAAA==.',
['代春']='代春花:BAAALgAECgEJAwAAAA==.',
['伍肆']='伍肆柒:BAABLgAFFH8HAAICAAMJyA4dFADWAAACAAMJyA4dFADWAAAAAA==.',
['兔击']='兔击哼唧:BAAALgAECgEJAQAAAA==.',
['八月']='八月札:BAAALgAECgEJAQAAAA==.',
['冰火']='冰火两重天:BAAALgAECgMJBAAAAA==.',
['冷江']='冷江:BAABLgAFFH8JAAIDAAMJWAWYIADOAAADAAMJWAWYIADOAAAAAA==.',
['加特']='加特琳:BAAALgAECgcJCgAAAA==.',
['半卷']='半卷西风:BAAALgAECgcJDwAAAA==.',
['南木']='南木离风:BAAALgADCgMJAwAAAA==.',
['又是']='又是小小星:BAAALgAECgIJAgAAAA==.',
['可爱']='可爱小骑士:BAAALgADCgYJBwAAAA==.',
['吳彦']='吳彦祖:BAAALgAECgQJBQAAAA==.',
['哦啦']='哦啦土豆:BAAALgAECgQJBAAAAA==.',
['唯你']='唯你而来:BAAALgAECgYJBgAAAA==.',
['喵乄']='喵乄晓灬玲:BAAALgADCgEJAQAAAA==.',
['喵喵']='喵喵怪:BAABLgAFFH8FAAICAAIJyg36CwCUAAACAAIJyg36CwCUAAAAAA==.',
['喵萌']='喵萌萌:BAAALgAECggJEAAAAA==.',
['土佬']='土佬肥:BAAALgAECgYJCwAAAA==.',
['土蚕']='土蚕:BAAALgAECgYJBwAAAA==.',
['地狱']='地狱之箭:BAAALgAECgEJBQAAAA==.',
['墨月']='墨月白:BAAALgAECgQJBQAAAA==.',
['夏日']='夏日的颂歌:BAAALgAECgIJAgAAAA==.',
['多罗']='多罗罗:BAAALgAECgQJBwAAAA==.',
['夜清']='夜清醒:BAABLgAFFH8LAAIEAAQJwQ/eBQAFAQAEAAQJwQ/eBQAFAQAAAA==.',
['大叔']='大叔的丫头:BAAALgAECgUJBQAAAA==.',
['大唐']='大唐不良人:BAAALgAECgcJCwAAAA==.',
['大器']='大器哥:BAAALgAECgMJAwAAAA==.',
['大宝']='大宝贝:BAAALgADCgYJCAAAAA==.',
['奎木']='奎木狼:BAAALgAECgUJBQAAAA==.',
['好运']='好运卡卡:BAAALgADCgkJCgAAAA==.好运啊毛:BAAALgADCgYJCQAAAA==.好运毛毛:BAAALgADCgQJBAAAAA==.',
['威威']='威威龍:BAAALgAECgkJBgAAAA==.',
['宁仪']='宁仪:BAAALgAECgEJAQAAAA==.',
['小卡']='小卡皮巴拉星:BAAALgAECgYJBwAAAA==.',
['小木']='小木曽雪菜:BAAALgAECgUJBQAAAA==.',
['小盟']='小盟:BAAALgAECgYJCgAAAA==.',
['尐狐']='尐狐丸:BAAALgAECgQJBAAAAA==.',
['山兜']='山兜口兜山:BAAALgADCgcJDAAAAA==.',
['崔斯']='崔斯特飞刃:BAAALgAECgEJAQAAAA==.',
['布川']='布川依酷:BAAALgAECgEJAQAAAA==.',
['张颖']='张颖啊:BAAALgAECgMJAwAAAA==.',
['影轩']='影轩:BAAALgAECgYJBgAAAA==.',
['得财']='得财艰倍:BAAALgADCgEJAQAAAA==.',
['德努']='德努力:BAAALgADCgQJBAAAAA==.',
['悟法']='悟法悟天:BAAALgAECgIJAgAAAA==.',
['慕容']='慕容云雪:BAAALgAECgYJBgAAAA==.',
['我一']='我一直是七:BAAALgAFFAQJBAABLgAFFAYJDwADAMQPAA==.我一直是五:BAAALgAFFAMJAwABLgAFFAYJDwADAMQPAA==.我一直是六:BAAALgAFFAQJAwABLgAFFAYJDwADAMQPAA==.我一直是四:BAABLgAFFH8HAAIDAAUJagd9DgBbAQADAAUJagd9DgBbAQABLgAFFAYJDwADAMQPAA==.',
['承影']='承影:BAABLgAECn8UAAMFAAcJqiFtFACSAgAFAAcJqiFtFACSAgAGAAMJvBuKTQDzAAAAAA==.',
['拈花']='拈花笑梦红尘:BAAALgADCgUJBQAAAA==.',
['无尽']='无尽虚空:BAAALgADCgEJAQAAAA==.',
['星辰']='星辰火焰:BAAALgAECgEJAQAAAA==.',
['春雨']='春雨惊雷化风:BAAALgAFFAIJAgAAAA==.',
['春风']='春风惊雷化雨:BAAALgAFFAIJAgAAAA==.',
['晓灬']='晓灬菜刀队长:BAABLgAECn8VAAIHAAgJgxMzKgAQAgAHAAgJgxMzKgAQAgAAAA==.',
['晓骐']='晓骐:BAACLgAFFH8IAAIIAAMJqCFsAgDVAAAIAAMJqCFsAgDVAAAuAAQKfxoAAwgACAkEHxYIAOICAAgACAkEHxYIAOICAAMABQn0CMacAN4AAAAA.',
['暗心']='暗心天堂:BAAALgAECgQJBwAAAA==.',
['最后']='最后的战歌:BAAALgAECgkJCQAAAA==.',
['李下']='李下小猎:BAAALgAECgYJBgAAAA==.',
['果然']='果然嗡:BAAALgADCgUJBQAAAA==.',
['柒筱']='柒筱柒:BAAALgAECgkJCQAAAA==.',
['柳溯']='柳溯雪:BAAALgAECgEJAQAAAA==.',
['楛藤']='楛藤老树昏鸦:BAAALgAECgQJBQAAAA==.',
['死亡']='死亡法骑:BAAALgAECgQJBAAAAA==.',
['死骑']='死骑十七:BAAALgAECgYJAwAAAA==.死骑十九:BAAALgAECgcJBwAAAA==.',
['比比']='比比拉布:BAAALgAECgYJBgAAAA==.',
['毛毛']='毛毛球:BAAALgAECgMJBgAAAA==.',
['水晶']='水晶灬忧伤:BAAALgADCgYJBgAAAA==.',
['水清']='水清风静:BAAALgAECgIJAgAAAA==.',
['池田']='池田依来沙:BAAALgAECgUJBQAAAA==.',
['沐璃']='沐璃晴:BAAALgAECgYJCQAAAA==.',
['没衣']='没衣服:BAAALgADCgEJAQAAAA==.',
['泠风']='泠风:BAAALgAECgEJAQAAAA==.',
['涴秴']='涴秴无心:BAAALgAECgUJCwAAAA==.',
['淡茶']='淡茶逍遥:BAAALgAECgUJAgAAAA==.',
['澟冬']='澟冬将至:BAABLgAECn8bAAIBAAcJXRbWbgD3AQABAAcJXRbWbgD3AQAAAA==.',
['灬糖']='灬糖喵喵:BAABLgAECn8XAAMJAAgJtxJTIQDNAQAJAAcJ9BRTIQDNAQAKAAEJxwHuXQAmAAAAAA==.',
['点亮']='点亮世界:BAAALgAFFAEJAQAAAA==.',
['烛烬']='烛烬:BAAALgADCgEJAQAAAA==.',
['牛牛']='牛牛向前冲:BAAALgAECgMJAgAAAA==.',
['玛格']='玛格辣汉:BAAALgAECgYJDAAAAA==.',
['珍妮']='珍妮玛黛烬丶:BAAALgADCgUJBQAAAA==.',
['理查']='理查德迈耶:BAAALgAECgYJCAAAAA==.',
['琥珀']='琥珀:BAACLgAFFH8MAAIFAAQJXBdsEADmAAAFAAQJXBdsEADmAAAuAAQKfxgAAgUACQlnH64IAAQDAAUACQlnH64IAAQDAAAA.',
['琪琪']='琪琪:BAAALgAECgQJBQAAAA==.',
['瑞亚']='瑞亚丶风行者:BAAALgADCgYJBgAAAA==.',
['璃月']='璃月:BAAALgADCgUJBQAAAA==.',
['甜刃']='甜刃:BAAALgAECgcJBwABLgAFFAUJBQAIAP4TAA==.',
['疾风']='疾风逐岳:BAAALgAECgIJBAAAAA==.',
['百鬼']='百鬼丸:BAAALgADCgYJBgAAAA==.',
['真炎']='真炎八重樱:BAAALgAECgEJAgAAAA==.',
['秋水']='秋水落霞:BAAALgADCgEJAgAAAA==.',
['纷乱']='纷乱雪月花:BAAALgADCgUJBQAAAA==.',
['绝不']='绝不拉怪:BAAALgAECgYJBgAAAA==.',
['翻滚']='翻滚的球球丶:BAAALgAECgYJBgAAAA==.',
['老约']='老约翰中药铺:BAAALgAECgQJBQAAAA==.',
['聖光']='聖光天堂:BAAALgAECgEJAQAAAA==.',
['肉蛋']='肉蛋冲姬:BAAALgAFFAIJAwAAAA==.',
['胖子']='胖子猎:BAAALgADCgMJAwAAAA==.',
['芒果']='芒果色的鹌鹑:BAAALgADCgEJAQAAAA==.',
['花开']='花开小君君:BAAALgAECgMJAwAAAA==.',
['苍邪']='苍邪:BAAALgAECgEJAgAAAA==.',
['苏打']='苏打水:BAAALgAECgcJCQAAAA==.',
['若干']='若干骑:BAAALgADCgUJBQAAAA==.',
['萧碧']='萧碧宰治丶:BAAALgAECgQJBwAAAA==.',
['萧蘅']='萧蘅哟:BAABLgAECn8VAAIIAAYJ9hDqLgBWAQAIAAYJ9hDqLgBWAQAAAA==.',
['董盼']='董盼丶盼:BAAALgADCgcJBwAAAA==.',
['蒜小']='蒜小叶:BAAALgAFFAIJAgAAAA==.',
['虎哥']='虎哥是个传说:BAAALgAECggJDgAAAA==.',
['蜜拉']='蜜拉贝儿:BAAALgADCgIJAgAAAA==.',
['血兽']='血兽:BAAALgAECgMJBgAAAA==.',
['裂荏']='裂荏小扉:BAAALgAECgEJAQAAAA==.',
['西风']='西风烈:BAAALgAECgYJDAAAAA==.',
['诸葛']='诸葛钢钉:BAAALgAECgIJAwAAAA==.',
['豚豚']='豚豚必定欧:BAAALgAECgcJBwAAAA==.',
['超超']='超超冰淇淋:BAAALgADCgcJBwAAAA==.超超大魔王:BAAALgAECgIJAgAAAA==.超超泪邪痕:BAAALgAECgcJBwAAAA==.',
['逗逗']='逗逗猪遛虎:BAAALgAECgkJCQAAAA==.',
['醉凊']='醉凊秋:BAAALgAFFAMJAwAAAA==.',
['隔壁']='隔壁李大爷:BAAALgAECgEJAQAAAA==.',
['雪箭']='雪箭:BAAALgAECgUJBQAAAA==.',
['雷公']='雷公助我:BAAALgAECgQJBQAAAA==.',
['青酱']='青酱:BAAALgAECgEJAQAAAA==.',
['面面']='面面大魔王法:BAAALgADCgEJAQAAAA==.',
['颜尹']='颜尹尘:BAAALgAECgcJDAAAAA==.',
['风吹']='风吹悠悠:BAAALgADCgIJAgAAAA==.',
['风暴']='风暴白酒:BAABLgAECn8ZAAICAAgJbhrzGgAtAgACAAgJbhrzGgAtAgAAAA==.',
['风雨']='风雨:BAAALgAECgMJAwAAAA==.风雨潇潇:BAAALgAECgYJBgAAAA==.',
['马潇']='马潇洒:BAAALgAECgcJCwAAAA==.',
['魅惑']='魅惑之魂:BAAALgAECgEJAQAAAA==.',
['黄小']='黄小邪:BAAALgAECgMJAwAAAA==.',
['黄老']='黄老柒:BAAALgAECgIJAgAAAA==.黄老鬼:BAAALgAECgIJAwAAAA==.',
['黑色']='黑色信仰:BAAALgADCgMJAwAAAA==.',
['默然']='默然冷对:BAAALgAECgMJAwAAAA==.',
['龙族']='龙族法魔:BAAALgAECgUJBQAAAA==.',
['龙炎']='龙炎血魂:BAAALgAECgEJAQAAAA==.',
['龙语']='龙语归来:BAAALgADCgYJBgAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
