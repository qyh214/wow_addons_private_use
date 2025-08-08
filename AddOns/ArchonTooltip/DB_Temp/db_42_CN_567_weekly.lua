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
 local lookup = {'Priest-Holy','DeathKnight-Unholy','Shaman-Elemental','Shaman-Restoration','Unknown-Unknown','Warrior-Arms','Mage-Arcane','Priest-Discipline','Evoker-Devastation','Paladin-Retribution','Hunter-BeastMastery','Druid-Balance','Warrior-Fury','Rogue-Assassination','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DeathKnight-Frost','Mage-Frost','Rogue-Subtlety','Evoker-Preservation','Hunter-Marksmanship','Mage-Fire','DemonHunter-Havoc','Monk-Mistweaver','DeathKnight-Blood',}; local provider = {region='CN',realm='伊兰尼库斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={At='Atheistkk:BAAAKgAECggIDQABKgAFFAIIBQABANYHAA==.',Au='Auroray:BAACKgAFFH8WAAICAAgISRVJCQD4AQACAAgISRVJCQD4AQAqAAQKfyAAAgIACAiPHOQnABkCAAIACAiPHOQnABkCAAAA.',Bl='Bliztwing:BAABKgAECn8ZAAIDAAcIGBNZMABgAQADAAcIGBNZMABgAQAAAA==.',Di='Diamonyip:BAAAKgADCgUIBQAAAA==.',Do='Dorangel:BAAAKgADCgYIBgAAAA==.',Dz='Dzzqa:BAABKgAECn8iAAICAAgIxhlGIwAAAgACAAgIxhlGIwAAAgAAAA==.',Et='Ethericess:BAACKgAFFH8VAAIBAAYIvx7zBQCwAQABAAYIvx7zBQCwAQAqAAQKfxoAAgEACAj8HGATADcCAAEACAj8HGATADcCAAAA.',Ev='Evelynn:BAABKgAECn8fAAIEAAgIiRe+MwC3AQAEAAgIiRe+MwC3AQABKgAFFAYIAgAFAAAAAA==.',Ew='Ews:BAAAKgAFFAEIAQAAAA==.',Ji='Jiange:BAABKgAFFH8MAAIGAAYIjxm+BwCSAQAGAAYIjxm+BwCSAQAAAA==.',Le='Levi:BAAAKgADCggICAAAAA==.',Li='Lilacerullo:BAAAKgAECggIEQAAAA==.',Ni='Niree:BAABKgAFFH8IAAIHAAQIVCAVHwDuAAAHAAQIVCAVHwDuAAAAAA==.',Tw='Twoblack:BAABKgAECn8iAAMBAAgIfiUyAwDgAgABAAgIfiUyAwDgAgAIAAEImQk7kwAuAAABKgAFFAgILwAEAK0jAA==.',['三角']='三角初华:BAABKgAFFH8GAAIJAAYImRAQFAAwAQAJAAYImRAQFAAwAQAAAA==.',['不以']='不以为怪:BAAAKgADCggICAAAAA==.',['不要']='不要让哥迷恋:BAAAKgAECgQIBQAAAA==.',['丑八']='丑八怪怪:BAAAKgAECggIEAAAAA==.',['世界']='世界尽头:BAABKgAECn8aAAIKAAgI3BdnXwChAQAKAAgI3BdnXwChAQAAAA==.',['丨义']='丨义父丨:BAACKgAFFH8IAAILAAMIyB2wIAAJAQALAAMIyB2wIAAJAQAqAAQKfyYAAgsACAjuICYYAHACAAsACAjuICYYAHACAAAA.',['丨二']='丨二狗丨:BAAAKgADCgEIAQAAAA==.',['丨嗜']='丨嗜血丨:BAABKgAFFH8JAAIMAAMIIwa3IwCbAAAMAAMIIwa3IwCbAAAAAA==.',['丨居']='丨居中丨:BAACKgAFFH8UAAIKAAMIexyNOwD/AAAKAAMIexyNOwD/AAAqAAQKfx0AAgoACAiLIoIfAIQCAAoACAiLIoIfAIQCAAAA.',['丨怪']='丨怪怪丨:BAABKgAFFH8GAAILAAMIxxrkJQDvAAALAAMIxxrkJQDvAAAAAA==.',['丨惩']='丨惩戒骑丨:BAABKgAFFH8MAAMGAAQIMB2XFQDYAAAGAAQIwBaXFQDYAAANAAQIIxfuHwDUAAAAAA==.',['丨海']='丨海边丨:BAAAKgADCgEIAQAAAA==.',['丨糖']='丨糖门丨:BAAAKgADCgQIBAAAAA==.',['丨花']='丨花花丨:BAAAKgAECgMIAwAAAA==.',['丨见']='丨见怪不怪丨:BAABKgAFFH8JAAICAAMIhwhVGACkAAACAAMIhwhVGACkAAAAAA==.',['中年']='中年时的喜欢:BAAAKgADCgEIAQAAAA==.',['乔雯']='乔雯影刃:BAABKgAFFH8IAAIOAAgIIhdXBQA6AgAOAAgIIhdXBQA6AgAAAA==.乔雯暮风:BAAAKgAFFAYIAgABKgAFFAgICAAOACIXAA==.乔雯雪晨:BAAAKgAECggIEAABKgAFFAgICAAOACIXAA==.',['二手']='二手徳:BAABKgAECn8UAAIPAAcILhDqQwD/AAAPAAcILhDqQwD/AAAAAA==.',['亚星']='亚星:BAABKgAFFH8GAAMPAAYIpgrSDADAAAAPAAUIMwrSDADAAAAMAAEIHhgjLQBQAAAAAA==.',['亚辛']='亚辛:BAABKgAFFH8GAAIKAAYIGRa3EQCEAQAKAAYIGRa3EQCEAQAAAA==.',['亜荬']='亜荬爹:BAAAKgAECgMIAwAAAA==.',['亦影']='亦影:BAAAKgAECgUIBQAAAA==.',['以武']='以武为贵:BAAAKgADCgYIBgAAAA==.',['伊维']='伊维斯:BAAAKgADCgQIBAAAAA==.',['伟大']='伟大的牛:BAAAKgAECgQIBgAAAA==.伟大红:BAAAKgAECggICAAAAA==.',['倒头']='倒头就睡:BAAAKgADCgEIAQAAAA==.',['傲剑']='傲剑风卷残月:BAAAKgAECgYIBgAAAA==.',['冬玄']='冬玄:BAAAKgAECgYIBgAAAA==.',['冰法']='冰法也穿秋裤:BAAAKgADCgEIAQAAAA==.',['冰糕']='冰糕块块:BAAAKgAECgYIBgAAAA==.',['发型']='发型决定命运:BAAAKgADCgYIBgAAAA==.',['古户']='古户艾莉卡:BAAAKgADCggICAAAAA==.',['叶琳']='叶琳:BAAAKgAECggICAABKgAFFAYICAAHAFQgAA==.',['哆啦']='哆啦默默:BAABKgAFFH8KAAIIAAcI6QofCgB1AQAIAAcI6QofCgB1AQAAAA==.',['哎呦']='哎呦为:BAAAKgAECgEIAgAAAA==.',['噩灵']='噩灵继续游荡:BAABKgAFFH8GAAIEAAYIYg43FAA1AQAEAAYIYg43FAA1AQAAAA==.',['圣职']='圣职玛利亚:BAAAKgAECgMIAwAAAA==.',['在部']='在部落卖猪肉:BAAAKgAECgQIBAAAAA==.',['基尔']='基尔加蛋灬:BAABKgAFFH8IAAMQAAgIEhBoGQC7AAAQAAUIoxBoGQC7AAARAAMIpg5yGQCEAAABKgAFFAgIJQASACEcAA==.',['壹叶']='壹叶知秋:BAAAKgAECgYIDAAAAA==.',['天不']='天不高:BAAAKgADCggICAAAAA==.',['天妒']='天妒灬风流:BAAAKgAECggIDQAAAA==.',['天赐']='天赐飞:BAAAKgAECgcIAgAAAA==.',['奶茶']='奶茶刂呼吸:BAABKgAECn8UAAMTAAYIqBXkFwA8AQATAAYIqBXkFwA8AQACAAUI8gnjgQCbAAAAAA==.',['姜小']='姜小白:BAABKgAFFH8GAAILAAYIxRLhEgBfAQALAAYIxRLhEgBfAQAAAA==.',['姜弋']='姜弋:BAABKgAFFH8LAAMQAAcIsBL6DwCRAQAQAAcIsBL6DwCRAQASAAQINQWUGgBtAAAAAA==.',['娅辛']='娅辛:BAAAKgAFFAUIAwAAAA==.',['娜塔']='娜塔莉炙火:BAABKgAFFH8GAAIUAAYIVh5lAwDIAQAUAAYIVh5lAwDIAQAAAA==.',['宇宙']='宇宙浪子:BAABKgAFFH8IAAIEAAQISxueCgADAQAEAAQISxueCgADAQAAAA==.',['安之']='安之的提款机:BAAAKgAECgYIBgAAAA==.',['实战']='实战实在:BAAAKgAECgMIAwAAAA==.',['小丨']='小丨淼淼:BAAAKgAECggIDQAAAA==.',['小蘑']='小蘑菇采姑娘:BAAAKgAECgUIBgAAAA==.',['就爱']='就爱挖冰西瓜:BAABKgAFFH8KAAIEAAYIRBy3CwCMAQAEAAYIRBy3CwCMAQAAAA==.',['尼古']='尼古拉斯铁锅:BAAAKgADCggICAAAAA==.',['山楂']='山楂蛋:BAAAKgADCggICgAAAA==.',['年少']='年少时的喜欢:BAAAKgADCggICAAAAA==.',['幽默']='幽默小刀:BAABKgAFFH8GAAIVAAMIABLNBAC/AAAVAAMIABLNBAC/AAAAAA==.',['彡毒']='彡毒奶彡:BAAAKgAFFAYIBAABKgAFFAgIBAAFAAAAAA==.',['提莫']='提莫:BAAAKgAFFAIIAgAAAA==.',['斯蒂']='斯蒂芬亨得利:BAAAKgAECgUICwAAAA==.',['春水']='春水蜉蝣:BAAAKgAFFAQIBAAAAA==.',['月海']='月海鱼鱼猫:BAACKgAFFH8MAAMJAAMIzhc5DADsAAAJAAMIzhc5DADsAAAWAAEI1wp8CwA5AAAqAAQKfx4AAxYACAgnJKsAAOwCABYACAgnJKsAAOwCAAkABAgaHlY+AOwAAAAA.',['极限']='极限了:BAABKgAFFH8PAAIKAAMIqh+4FQACAQAKAAMIqh+4FQACAQAAAA==.',['死神']='死神归来:BAAAKgAFFAQIBAAAAA==.',['死骑']='死骑之王:BAAAKgAFFAQIBAAAAA==.',['沐小']='沐小菜:BAACKgAFFH8IAAIKAAgIWhgcBwBWAgAKAAgIWhgcBwBWAgAqAAQKfyEAAgoACAjUDuR9AFQBAAoACAjUDuR9AFQBAAAA.',['浅颜']='浅颜默默:BAABKgAFFH8GAAIXAAYIRwfUGwAQAQAXAAYIRwfUGwAQAQAAAA==.',['浓夫']='浓夫叁拳:BAAAKgADCggICAAAAA==.',['浪味']='浪味仙:BAAAKgAECgIIAgAAAA==.',['海蓝']='海蓝:BAAAKgADCggICAAAAA==.',['淡忘']='淡忘凡尘:BAAAKgAECgcIEwAAAA==.',['淡笑']='淡笑凡尘:BAABKgAECn8nAAMYAAgISA5JGgBpAQAYAAgISA5JGgBpAQAUAAUItQU6igB6AAAAAA==.',['混沌']='混沌灬哈迪斯:BAACKgAFFH8MAAMXAAMIkBE3FwCsAAAXAAMIkBE3FwCsAAALAAEIVQh9YQAyAAAqAAQKfxUAAhcACAhHH3IZAAUCABcACAhHH3IZAAUCAAAA.混沌灬奎托斯:BAABKgAFFH8MAAIQAAMInxCwFwDCAAAQAAMInxCwFwDCAAAAAA==.混沌灬怒风:BAACKgAFFH8KAAIZAAMI1RB9GQDDAAAZAAMI1RB9GQDDAAAqAAQKfxQAAhkACAhPHf8bACICABkACAhPHf8bACICAAAA.',['混血']='混血王子:BAAAKgAFFAMIAwAAAA==.',['猫猫']='猫猫:BAABKgAFFH8FAAMEAAMIYAeHKAB9AAAEAAII+AeHKAB9AAADAAEINwFCKwAoAAAAAA==.',['电悍']='电悍公:BAAAKgAECggICwAAAA==.',['白日']='白日夢想家:BAABKgAFFH8GAAICAAYIRRP6FQBsAQACAAYIRRP6FQBsAQAAAA==.',['知了']='知了:BAABKgAECn8nAAIKAAgISCEPCgChAgAKAAgISCEPCgChAgAAAA==.',['神级']='神级偃师:BAAAKgAECggICwAAAA==.',['神龙']='神龙大侠阿波:BAABKgAFFH8IAAIaAAgIkwWrCABhAQAaAAgIkwWrCABhAQAAAA==.',['秋天']='秋天的牛牛:BAAAKgAECgcIBwAAAA==.',['秋水']='秋水静依:BAAAKgAECgYIBgAAAA==.',['科拉']='科拉克斯:BAAAKgADCggIDAAAAA==.',['红茶']='红茶灬恋:BAABKgAECn8fAAIBAAgIPSGdDABrAgABAAgIPSGdDABrAgAAAA==.',['纹火']='纹火玫瑰:BAAAKgADCgIIAgAAAA==.',['羊过']='羊过小龍女:BAAAKgAECggICAAAAA==.',['美杜']='美杜莎克:BAAAKgADCgUIBQAAAA==.',['羽毛']='羽毛灵魂:BAAAKgAECgUIBQAAAA==.',['聪聪']='聪聪呆:BAAAKgAFFAYIAgAAAA==.',['肉丨']='肉丨土豆:BAAAKgAECgEIAQAAAA==.',['肯达']='肯达赫迪:BAABKgAECn8ZAAMNAAgIcB01BgBsAgANAAgIcB01BgBsAgAGAAEIiQPAaQAxAAAAAA==.',['胖母']='胖母熊:BAABKgAFFH8IAAITAAgITQUYBACoAQATAAgITQUYBACoAQAAAA==.',['艾琳']='艾琳同学:BAABKgAFFH8MAAMLAAMIoRcvNQC/AAALAAMIYBMvNQC/AAAXAAIISBPSHgB5AAAAAA==.',['薇尔']='薇尔莉特:BAAAKgAECgcICgAAAA==.',['藤和']='藤和艾莉欧:BAAAKgAECgEIAgAAAA==.',['要吃']='要吃薯条:BAAAKgAECgMIAwAAAA==.',['语風']='语風:BAAAKgAECgUIBQABKgAECgUIBQAFAAAAAA==.',['邦迪']='邦迪大叔:BAAAKgAECgcICgAAAA==.',['邪恶']='邪恶的木偶:BAABKgAFFH8eAAMEAAcI5h8GCACYAQAEAAUIWSMGCACYAQADAAQIoBPzDwDmAAAAAA==.',['醉卧']='醉卧星河:BAAAKgAECgYIBwAAAA==.',['钓鱼']='钓鱼爱好者:BAABKgAFFH8IAAMUAAYITyIFAwDZAQAUAAYIYiEFAwDZAQAYAAIIph14IgClAAAAAA==.',['锦绣']='锦绣櫏橙:BAABKgAFFH8MAAILAAYInxfWFABPAQALAAYInxfWFABPAQAAAA==.',['闪灵']='闪灵猎手:BAAAKgADCgYIBgAAAA==.',['阎火']='阎火蔷薇:BAAAKgAECgQIBgAAAA==.',['随风']='随风灬小小彬:BAAAKgAFFAYIAgAAAA==.随风灬小彬:BAAAKgAFFAQIBAAAAA==.',['零度']='零度疯狂:BAAAKgAECgcICgAAAA==.',['露肚']='露肚谋:BAAAKgAFFAgIAgAAAA==.',['鞣蚌']='鞣蚌大:BAABKgAFFH8HAAIKAAQI+RlMIwDhAAAKAAQI+RlMIwDhAAAAAA==.',['黑暗']='黑暗丶怒风:BAAAKgAECgYICQAAAA==.',['默术']='默术:BAABKgAFFH8IAAIbAAgIEgqBCgBrAQAbAAgIEgqBCgBrAQAAAA==.',['龙陌']='龙陌沐奕:BAAAKgAECggIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end