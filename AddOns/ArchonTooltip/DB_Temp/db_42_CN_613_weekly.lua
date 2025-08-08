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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Paladin-Retribution','Warrior-Fury','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Mage-Arcane','Priest-Holy','DeathKnight-Blood','DeathKnight-Frost','Shaman-Restoration','Warrior-Arms','Warrior-Protection','Monk-Mistweaver','Druid-Feral','Priest-Discipline','Evoker-Preservation','DemonHunter-Havoc','DemonHunter-Vengeance','Mage-Frost','Priest-Shadow','Monk-Windwalker','Hunter-Marksmanship','Evoker-Devastation',}; local provider = {region='CN',realm='圣火神殿',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Anthony:BAAAKgAECgEIAQAAAA==.',Ar='Areshs:BAABKgAECn8XAAMBAAgIyBhdNwCQAQABAAcI3RhdNwCQAQACAAUILBMFNQARAQAAAA==.',Co='Conquest:BAABKgAECn8iAAIDAAgIMR7YHQAjAgADAAgIMR7YHQAjAgAAAA==.',Da='Darius:BAAAKgAECgQIBAAAAA==.',De='Deathgun:BAAAKgAECgUIBQAAAA==.',Dz='Dzyang:BAAAKgAECggIDAAAAA==.',Ec='Echoma:BAAAKgAECgMIAwAAAA==.',Fo='Foii:BAAAKgAFFAQIBAAAAA==.',Gh='Ghyhuijn:BAAAKgADCggICQAAAA==.',Ha='Harish:BAABKgAECn88AAIEAAgIUSI3FgCvAgAEAAgIUSI3FgCvAgAAAA==.',Hy='Hyeve:BAAAKgAFFAMIAwAAAA==.',Ja='Jason:BAAAKgADCgQIBAAAAA==.',Ke='Kerwin:BAABKgAECn8WAAIFAAgICBWbIADOAQAFAAgICBWbIADOAQAAAA==.',La='Lauralogan:BAABKgAFFH8IAAMGAAQIlRKbGgDVAAAGAAQIlRKbGgDVAAAHAAQImBTmHgCyAAAAAA==.',Li='Lierena:BAABKgAECn9CAAIIAAgIFyQJBQDHAgAIAAgIFyQJBQDHAgAAAA==.',Mb='Mbaiqi:BAAAKgAECgYICAAAAA==.',Me='Mellifluous:BAAAKgAFFAQIBAAAAA==.Meltryllis:BAAAKgAECgYIBgAAAA==.',Od='Odidt:BAAAKgAFFAQIBAAAAA==.',Oo='Ooxxd:BAABKgAFFH8IAAIJAAgIdQgACgDHAQAJAAgIdQgACgDHAQAAAA==.',Pa='Passion:BAAAKgAECgUICAAAAA==.',Pu='Pureblue:BAAAKgAECgIIAgAAAA==.',Qt='Qtuu:BAAAKgADCgcIBwAAAA==.',Re='Relock:BAAAKgADCggIDAAAAA==.',Ru='Rurb:BAAAKgAECgYIBwAAAA==.',Sa='Samana:BAAAKgAECgIIAgAAAA==.',Si='Simitpro:BAAAKgAFFAQIBAAAAA==.',St='Sti:BAAAKgADCgYIBgAAAA==.',Tm='Tmskii:BAABKgAECn8VAAIKAAgIvhnLLAB1AQAKAAgIvhnLLAB1AQAAAA==.',Wa='Wata:BAABKgAFFH8FAAIDAAUIoQRYEgDVAAADAAUIoQRYEgDVAAAAAA==.',['一个']='一个大王:BAAAKgADCgUIBQAAAA==.',['一幻']='一幻兽一:BAAAKgAECgUIBQAAAA==.一幻化僧一:BAAAKgAECgYIBgAAAA==.一幻化恶魔一:BAAAKgAECgcICgAAAA==.一幻化骑士一:BAAAKgAECgMIAwAAAA==.一幻战一:BAAAKgADCggICAAAAA==.一幻法一:BAAAKgAECgEIAQAAAA==.一幻狼一:BAAAKgADCgUIBwAAAA==.一幻骑一:BAAAKgAECggIDgAAAA==.一幻龙女一:BAAAKgAECggICAAAAA==.',['一梦']='一梦不醒:BAAAKgAECgIIAgAAAA==.',['一清']='一清枫一:BAAAKgADCgYIBgAAAA==.',['一蹦']='一蹦多老高:BAAAKgADCgMIAwAAAA==.',['不会']='不会奶不会防:BAABKgAECn8cAAIEAAgI4SVoDACGAgAEAAgI4SVoDACGAgAAAA==.',['不哭']='不哭不闹:BAAAKgAECggIEwAAAA==.',['不讲']='不讲理大王:BAAAKgAECgUIBQAAAA==.',['不过']='不过尔尔:BAAAKgADCggICAAAAA==.',['丑牛']='丑牛武德:BAACKgAFFH8QAAIFAAQIHhcBGwCsAAAFAAQIHhcBGwCsAAAqAAQKfxcAAgUACAhZHaIbADQCAAUACAhZHaIbADQCAAAA.',['东风']='东风雷诺:BAAAKgAECgYIBgAAAA==.',['丨祈']='丨祈愿丨:BAACKgAFFH8FAAIHAAMIgxmUGQDUAAAHAAMIgxmUGQDUAAAqAAQKfyMAAwcACAhSIEYMAFUCAAcACAhSIEYMAFUCAAYABQjoDEaSALIAAAAA.',['临时']='临时数据:BAACKgAFFH8iAAIIAAgI9BawBQBBAgAIAAgI9BawBQBBAgAqAAQKfyAAAggACAhyIMYkAGECAAgACAhyIMYkAGECAAAA.',['丶诸']='丶诸神之怒:BAABKgAFFH8FAAMLAAQIlgx1FwDmAAALAAQIDAp1FwDmAAADAAEIYBKKUQBNAAAAAA==.',['丿小']='丿小胖:BAAAKgAECggICwAAAA==.',['乐乐']='乐乐清风:BAAAKgADCggICgAAAA==.',['二大']='二大爷:BAABKgAFFH8IAAIMAAQISgMxDgCEAAAMAAQISgMxDgCEAAAAAA==.',['优尼']='优尼克孜:BAAAKgAECgIIAgAAAA==.',['伯牙']='伯牙绝弦:BAAAKgADCgUIBgAAAA==.',['低调']='低调法爺:BAAAKgADCgYIBgAAAA==.',['余罪']='余罪:BAAAKgAFFAQIBAAAAA==.',['你杀']='你杀了我吧:BAAAKgAECgMIAwAAAA==.',['依然']='依然十月:BAACKgAFFH8LAAINAAMIQhiGJgDcAAANAAMIQhiGJgDcAAAqAAQKfxUAAg0ACAi5EyJFAHQBAA0ACAi5EyJFAHQBAAAA.依然在巅峰:BAAAKgAECgIIBAAAAA==.',['兜兜']='兜兜有寂寞:BAAAKgADCggIDQAAAA==.',['农家']='农家小炒肉:BAABKgAFFH8GAAIFAAYIehzlCQCwAQAFAAYIehzlCQCwAQAAAA==.',['冫粦']='冫粦:BAAAKgAECgQIBwAAAA==.',['冰点']='冰点:BAAAKgADCgcIBwAAAA==.',['冰雪']='冰雪之蒂:BAAAKgAECgEIAQAAAA==.',['决战']='决战回忆:BAAAKgAFFAIIAgAAAA==.',['凛时']='凛时曲:BAAAKgAFFAEIAQAAAA==.',['勉励']='勉励狮子:BAAAKgADCggICQAAAA==.',['勋丽']='勋丽一:BAAAKgADCgIIAgAAAA==.',['北京']='北京苑望卖车:BAAAKgAECgMIBQAAAA==.',['十字']='十字银月:BAAAKgADCgEIAQAAAA==.',['十点']='十点半下线:BAAAKgAFFAYIBAAAAA==.',['南小']='南小鸟:BAABKgAFFH8GAAMOAAMIfwhyEgCMAAAOAAII/gtyEgCMAAAPAAMI0gGVFABWAAAAAA==.',['叁零']='叁零萨满:BAAAKgAFFAEIAQABKgAFFAgILQAQAGsmAA==.',['双倒']='双倒数:BAAAKgAECgYIBgAAAA==.',['叨叨']='叨叨:BAAAKgAFFAMIAwAAAA==.',['吃饱']='吃饱了就不饿:BAAAKgAECgQIBAAAAA==.',['呆呆']='呆呆兽:BAABKgAFFH8IAAIBAAgIRyEbAwCGAgABAAgIRyEbAwCGAgAAAA==.',['和发']='和发个就:BAABKgAFFH8MAAIRAAMIQhALBQDSAAARAAMIQhALBQDSAAAAAA==.',['咕德']='咕德猫柠:BAAAKgAFFAMIAwAAAA==.',['咯弄']='咯弄泥:BAAAKgAECgUIAQAAAA==.',['哎呀']='哎呀妈:BAAAKgAECgcICAAAAA==.',['唯生']='唯生素:BAAAKgADCgUIBQAAAA==.',['單人']='單人旁:BAAAKgAECgEIAQAAAA==.',['嘟嘟']='嘟嘟噜:BAAAKgADCggICAAAAA==.',['团一']='团一个:BAAAKgADCgYIBgAAAA==.',['圣光']='圣光至上:BAAAKgADCgMIAwAAAA==.',['夜落']='夜落星河:BAAAKgAECgEIAQAAAA==.',['天下']='天下都是贼:BAAAKgADCgYIBgAAAA==.',['天棒']='天棒坤哥:BAAAKgAECgQIBwAAAA==.',['天道']='天道:BAAAKgADCgUIBQAAAA==.',['太阳']='太阳骑士:BAAAKgAECgYICAAAAA==.',['子夜']='子夜魂殇:BAAAKgAECgUIBQAAAA==.',['安瑟']='安瑟:BAAAKgADCgEIAQAAAA==.',['对白']='对白:BAAAKgADCggIDAAAAA==.',['小六']='小六:BAAAKgAFFAIIBAAAAA==.',['小肥']='小肥爱嘉丽:BAABKgAFFH8HAAIIAAcI1g9hCgCuAQAIAAcI1g9hCgCuAQAAAA==.',['小闫']='小闫爱吃香菜:BAAAKgAECgQIBAAAAA==.',['尘缘']='尘缘:BAAAKgADCgEIAQAAAA==.',['就不']='就不奶你:BAABKgAECn8VAAMSAAgIFA8GZwCOAAAKAAUIEgyJWgCrAAASAAUIVBAGZwCOAAAAAA==.就不带娃:BAAAKgAECgYIBgAAAA==.',['就是']='就是敦实:BAAAKgAECgYIBgAAAA==.',['山寨']='山寨之王:BAAAKgAECgQIBQAAAA==.',['岩岩']='岩岩:BAAAKgADCgEIAQAAAA==.',['庇佑']='庇佑极:BAAAKgAECggICAAAAA==.',['开心']='开心一下:BAAAKgADCgYIBgAAAA==.',['影色']='影色舞:BAAAKgAECggIEAAAAA==.',['很多']='很多有你的梦:BAAAKgAECgEIAQAAAA==.',['徐一']='徐一枫:BAAAKgAECgUICAAAAA==.',['恶魔']='恶魔爱玩牛:BAAAKgAECgEIAQAAAA==.',['我照']='我照密码:BAAAKgADCgYICQAAAA==.',['扑克']='扑克:BAAAKgADCggICgAAAA==.',['打我']='打我正七头:BAAAKgAECgYIBgAAAA==.',['扬仔']='扬仔:BAAAKgADCggIEQAAAA==.',['抓走']='抓走你的嫲嫲:BAAAKgADCgIIAwAAAA==.',['接化']='接化发:BAAAKgADCgYIBgAAAA==.',['提百']='提百万:BAAAKgAECgMIAwAAAA==.',['文思']='文思月:BAAAKgADCgYIBgAAAA==.',['方片']='方片:BAAAKgADCggIDgAAAA==.',['时砂']='时砂修士:BAABKgAFFH8FAAITAAMIiBbSBADZAAATAAMIiBbSBADZAAAAAA==.',['旺德']='旺德发:BAACKgAFFH8OAAIGAAQIMxGIGwDOAAAGAAQIMxGIGwDOAAAqAAQKfyEAAgYACAh3GbsQAO0BAAYACAh3GbsQAO0BAAAA.',['星空']='星空夜谈:BAAAKgADCgEIAQAAAA==.',['星辰']='星辰之陨:BAABKgAFFH8HAAIEAAcI+RM8GQCUAQAEAAcI+RM8GQCUAQAAAA==.',['暖冬']='暖冬:BAAAKgADCgMIBAAAAA==.',['月悦']='月悦:BAABKgAECn8VAAMGAAgIbRZfNwDLAQAGAAgIbRZfNwDLAQAHAAYIIxPQPgDqAAAAAA==.',['有冇']='有冇有冇有:BAAAKgAECgIIAgAAAA==.',['有种']='有种回归:BAACKgAFFH8JAAIUAAMIkgxlGgC9AAAUAAMIkgxlGgC9AAAqAAQKfxQAAxQACAjWFcYsALEBABQACAjTFMYsALEBABUAAQhaEWdhADQAAAAA.',['术爷']='术爷丶:BAAAKgADCggICAAAAA==.',['李含']='李含笑:BAAAKgADCgYIDwAAAA==.',['极道']='极道乐师:BAAAKgAECgEIAgAAAA==.',['林品']='林品如:BAAAKgAECggIBwAAAA==.',['枭妖']='枭妖:BAAAKgAECgQIAgAAAA==.',['枯藤']='枯藤老树昏鸦:BAAAKgADCgUIBQAAAA==.',['桂馥']='桂馥兰香:BAAAKgADCgQIBQAAAA==.',['桐小']='桐小喵:BAABKgAFFH8MAAIUAAYIrgw0GAA6AQAUAAYIrgw0GAA6AQAAAA==.',['梅花']='梅花:BAAAKgADCgcIBwAAAA==.',['橙子']='橙子皮:BAABKgAFFH8IAAIIAAgIvRvKAwB+AgAIAAgIvRvKAwB+AgAAAA==.',['欧阳']='欧阳伯伯:BAAAKgADCggICAAAAA==.',['残酷']='残酷一丁:BAAAKgAECgYICwAAAA==.残酷一渣:BAAAKgAECgYIBgAAAA==.',['水问']='水问月:BAAAKgADCgMICQAAAA==.',['氷焱']='氷焱:BAAAKgADCggICAAAAA==.',['永安']='永安丶卿酒酒:BAAAKgADCgUIBQAAAA==.',['汉普']='汉普顿公爵:BAAAKgAECgYIBgAAAA==.',['沃特']='沃特:BAAAKgADCgMIAwAAAA==.',['没有']='没有琳的带土:BAAAKgADCgUIBQAAAA==.',['浅浅']='浅浅清茉:BAAAKgAECgcICQAAAA==.',['滑道']='滑道:BAAAKgADCgIIAgAAAA==.',['灰袍']='灰袍干豆腐:BAAAKgADCgYIBgAAAA==.',['烈炎']='烈炎飞龙:BAAAKgADCgMIAwAAAA==.',['熊猫']='熊猫烈人儿:BAAAKgAECggICAAAAA==.',['爱熊']='爱熊壹:BAAAKgAECgQIBAAAAA==.',['牛如']='牛如花:BAAAKgAECgMIAwAAAA==.',['狂徒']='狂徒丷:BAAAKgADCgYIBgAAAA==.',['狂野']='狂野的放肆:BAAAKgAECgIIAwAAAA==.',['猛的']='猛的不得了:BAAAKgAECgQIBAAAAA==.',['猾鎏']='猾鎏鍀橘孑:BAAAKgADCgQIBAAAAA==.',['瑟匹']='瑟匹头子:BAAAKgAECggICAAAAA==.',['瑾瑟']='瑾瑟无端:BAAAKgAECgEIAQAAAA==.',['用脸']='用脸拉怪:BAAAKgAFFAQIBAAAAA==.',['疼爱']='疼爱一生:BAAAKgAECgEIAQAAAA==.',['疾如']='疾如风:BAAAKgAECgYIBgAAAA==.',['癞蛤']='癞蛤蟆:BAAAKgADCggICAAAAA==.',['白歌']='白歌笑:BAABKgAFFH8MAAINAAQIuSHmHgAAAQANAAQIuSHmHgAAAQAAAA==.',['百事']='百事可乐:BAAAKgADCgMIAgAAAA==.',['相逢']='相逢在巅峰:BAAAKgAECgEIAgAAAA==.',['石法']='石法:BAAAKgADCgIIAwAAAA==.',['石烈']='石烈:BAAAKgAECgcICQAAAA==.',['神奇']='神奇一萨:BAAAKgAFFAMIAwAAAA==.',['神女']='神女归来:BAAAKgAECgIIAgAAAA==.',['神梦']='神梦一刀:BAAAKgADCggICAAAAA==.',['神死']='神死:BAAAKgAECgUIBQAAAA==.',['离别']='离别后的冬天:BAAAKgADCgcIBwAAAA==.离别后的春天:BAACKgAFFH8IAAIJAAgI2hdIBQBEAgAJAAgI2hdIBQBEAgAqAAQKfywAAxYACAiAIGoOAF0CABYACAhNH2oOAF0CAAkABQgZGmYnAOQAAAAA.',['笑江']='笑江湖:BAAAKgADCggICAAAAA==.',['紧握']='紧握大锤:BAAAKgAECgUICAAAAA==.',['红方']='红方片:BAAAKgADCgQIBAAAAA==.',['缺曰']='缺曰:BAAAKgAFFAIIAgAAAA==.',['老秦']='老秦六:BAAAKgAECgYIDQAAAA==.',['联盟']='联盟最辣鸡:BAAAKgAECgMIAwAAAA==.联盟炒股佬:BAAAKgAECgEIAQAAAA==.',['胖子']='胖子有点矮:BAAAKgAECgYICgAAAA==.',['胖胖']='胖胖龙:BAACKgAFFH8RAAIEAAYIyxEHEwBuAQAEAAYIyxEHEwBuAQAqAAQKfxQAAgQACAhKH5spAFkCAAQACAhKH5spAFkCAAAA.胖胖龙一:BAAAKgAFFAIIAgAAAA==.',['艾婷']='艾婷婷:BAAAKgAECgMIAwAAAA==.',['艾瑞']='艾瑞亚:BAAAKgAECgYIBgAAAA==.',['蕾欧']='蕾欧娜:BAAAKgAECgMIAwAAAA==.',['蘑菇']='蘑菇王:BAAAKgAFFAQIBAAAAA==.',['虚妄']='虚妄之诺:BAABKgAFFH8GAAMXAAUIbAsPIwBzAAAXAAIIfggPIwBzAAAKAAMIKwWwOQBZAAAAAA==.',['血兽']='血兽爱我一次:BAAAKgAFFAMIAwAAAA==.',['西蜀']='西蜀一点红:BAABKgAECn8ZAAMKAAgISQqXSgDnAAAKAAgISQqXSgDnAAASAAEI6gSFigAYAAAAAA==.西蜀红尘飘:BAABKgAFFH8GAAICAAMIpQ2/DwC9AAACAAMIpQ2/DwC9AAAAAA==.',['请叫']='请叫我佑佑:BAAAKgADCgIIAgAAAA==.',['贫僧']='贫僧不厚道:BAAAKgADCggICAAAAA==.',['足下']='足下生风:BAACKgAFFH8tAAMQAAgIayYhAAARAwAQAAgIayYhAAARAwAYAAEIhgxvJQA6AAAqAAQKfyoAAxAACAj3JYoCAO0CABAACAj3JYoCAO0CABgAAQjlBjB5ADEAAAAA.',['跟我']='跟我走吧:BAAAKgAECgEIAQAAAA==.',['转瞬']='转瞬即逝:BAAAKgADCggIEQAAAA==.',['轻啾']='轻啾:BAAAKgAFFAYIAgABKgAFFAgIBgABAC4mAA==.',['达文']='达文西:BAAAKgADCgYIBgAAAA==.',['迈出']='迈出第一步:BAAAKgADCgMIAwAAAA==.',['还是']='还是你缺德:BAAAKgADCgMIAwAAAA==.',['逝殇']='逝殇易云:BAAAKgAECgYIBgAAAA==.',['達拉']='達拉然的光輝:BAAAKgAECgcIDAAAAA==.',['部落']='部落大漂亮:BAACKgAFFH8QAAMZAAMICgloOwCKAAAZAAMIagZoOwCKAAAIAAIIWguSTQBzAAAqAAQKfyIAAxkACAhiFjY8AGQBAAgABgjHGuNLAHsBABkACAgVETY8AGQBAAAA.',['鑫鑫']='鑫鑫金:BAACKgAFFH8MAAIBAAMILAY0NwCUAAABAAMILAY0NwCUAAAqAAQKfyUAAwEACAhzFacNAL8BAAEACAhzFacNAL8BAAIAAwgEDCswADYAAAAA.',['银盌']='银盌盛雪:BAAAKgAECgYIBgAAAA==.',['阿星']='阿星:BAAAKgADCggICAAAAA==.',['陌生']='陌生人:BAAAKgAECgcIDAAAAA==.',['隻狼']='隻狼:BAAAKgAECgYIAgAAAA==.',['雅修']='雅修特拉:BAACKgAFFH8GAAIXAAQIuBS/GwClAAAXAAQIuBS/GwClAAAqAAQKfyAAAwoACAjHH38LAHwCAAoACAjHH38LAHwCABIACAitC/Y1AEUBAAAA.',['霹雳']='霹雳娇猛:BAABKgAECn8ZAAMTAAgIGQrLFQD5AAATAAgIGQrLFQD5AAAaAAgINgidPgDrAAAAAA==.',['顺子']='顺子:BAAAKgADCggICAAAAA==.',['风中']='风中火焰:BAAAKgADCgMIBQAAAA==.',['风蚀']='风蚀之弦:BAABKgAFFH8GAAIIAAQIaBxVDgAVAQAIAAQIaBxVDgAVAQAAAA==.',['飘影']='飘影如风:BAAAKgAFFAEIAQAAAA==.',['飞云']='飞云:BAAAKgAFFAQIBAAAAA==.',['马蚤']='马蚤女未:BAAAKgAECgcIDQAAAA==.',['马踏']='马踏飞燕:BAAAKgAECgcICwAAAA==.',['马马']='马马呼呼:BAAAKgADCggICwAAAA==.',['骑宾']='骑宾:BAAAKgAECgQIBAAAAA==.',['鬼鬼']='鬼鬼鼠鼠:BAAAKgADCggICAAAAA==.',['魔扎']='魔扎:BAAAKgADCggICAAAAA==.',['黑方']='黑方片:BAAAKgAECgIIAgAAAA==.',['黑桃']='黑桃:BAAAKgADCgIIAgAAAA==.',['黑蚀']='黑蚀丿乱:BAABKgAFFH8LAAMIAAYIsR0pDgAWAQAIAAUINB4pDgAWAQAZAAIIpxjVNACfAAAAAA==.',['黯然']='黯然忧伤:BAABKgAFFH8HAAMDAAQIixEoFgDfAAADAAQIixEoFgDfAAALAAEIAAABKgAAAAAAAA==.',['齐天']='齐天大圣:BAABKgAFFH8IAAIEAAgIgRArDAAIAgAEAAgIgRArDAAIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end