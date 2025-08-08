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
 local lookup = {'Mage-Fire','Paladin-Retribution','Paladin-Protection','Evoker-Devastation','DeathKnight-Blood','Mage-Arcane','DemonHunter-Havoc','Hunter-BeastMastery','DeathKnight-Frost','DeathKnight-Unholy','Warrior-Protection','Warrior-Arms','Warrior-Fury','Paladin-Holy','Shaman-Restoration','Druid-Restoration','Druid-Balance','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Mage-Frost','Priest-Shadow','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','Monk-Brewmaster','Monk-Mistweaver','Shaman-Elemental','DemonHunter-Vengeance','Rogue-Assassination','Monk-Windwalker',}; local provider = {region='CN',realm='卡扎克',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abadoenvoy:BAAAKgAECgEIAQAAAA==.',Ad='Adiapanda:BAAAKgAECgEIAQAAAA==.',Al='Allenmage:BAABKgAFFH8KAAIBAAYIvBawBQCqAQABAAYIvBawBQCqAQAAAA==.',Ap='Apocalypsor:BAABKgAECn8VAAMCAAgIYwXS0AC3AAACAAcI5gXS0AC3AAADAAEIUAIPbwAGAAAAAA==.',Az='Azdaja:BAACKgAFFH8XAAIEAAQInBFzIADBAAAEAAQInBFzIADBAAAqAAQKfzoAAgQACAjBG2UZAPQBAAQACAjBG2UZAPQBAAEqAAUUBQgaAAUArR8A.',Da='Darkfall:BAABKgAFFH8KAAIFAAYIwhs/CgBwAQAFAAYIwhs/CgBwAQAAAA==.',El='Elderpaladin:BAAAKgAFFAMIAwAAAA==.Elemseismics:BAAAKgAECgQIBAAAAA==.Elizy:BAABKgAFFH8QAAICAAYIPBkiIgBkAQACAAYIPBkiIgBkAQAAAA==.Elsulw:BAAAKgAECggIEQAAAA==.',Ex='Expecto:BAAAKgAECgUIBQAAAA==.',Ey='Eyiksafras:BAAAKgAECgQIBAAAAA==.',Ez='Ezlol:BAABKgAFFH8QAAMGAAgImxtWBgAkAgAGAAgIqRpWBgAkAgABAAYIGhrgDABpAQAAAA==.',Fa='Fangg:BAAAKgAFFAMIAwAAAA==.',Fo='Forzemoon:BAAAKgAECggICAAAAA==.',Fr='Friedlljh:BAACKgAFFH8YAAIHAAUIcBZtJADoAAAHAAUIcBZtJADoAAAqAAQKfycAAgcACAiDHxQZAG4CAAcACAiDHxQZAG4CAAAA.Frontsiege:BAAAKgAECgYIBgAAAA==.',Gr='Greenbot:BAAAKgAECgUIBQAAAA==.',Gu='Guldamn:BAAAKgAFFAYIBAAAAA==.',Jo='Jonny:BAAAKgADCggIEAAAAA==.',Li='Lizzy:BAABKgAFFH8JAAIIAAYIZhp7EgBjAQAIAAYIZhp7EgBjAQAAAA==.',Lu='Luckyzero:BAAAKgAECggICAAAAA==.',Ma='Mastaichier:BAAAKgAECgYIBwAAAA==.',Ni='Nightdragon:BAAAKgADCgQIBAABKgAFFAUIGgAFAK0fAA==.Nightservant:BAACKgAFFH8aAAQFAAUIrR8kDQBDAQAFAAQIVyUkDQBDAQAJAAMIUhvsCgDHAAAKAAEIkxqFLgBPAAAqAAQKf0IAAwUACAhdJcAEALYCAAUACAgPJcAEALYCAAoABwi8JJkWAHkCAAAA.Nighttracer:BAAAKgAECgYICgABKgAFFAUIGgAFAK0fAA==.',Or='Orza:BAAAKgAECgYIBgAAAA==.',Sa='Samelex:BAACKgAFFH8ZAAILAAUIWiDEBQAcAQALAAUIWiDEBQAcAQAqAAQKfzMAAwsACAhPIdYGAHcCAAsACAhPIdYGAHcCAAwAAwiDC1tGAJIAAAAA.',Sk='Skadoosfists:BAAAKgAECgMIAwAAAA==.',Sn='Snoowsm:BAAAKgAECgQIBQAAAA==.',So='Sonny:BAAAKgAECgYICAAAAA==.',St='Stourin:BAAAKgAECgUIDAAAAA==.',Th='Theshy:BAABKgAFFH8JAAMNAAUIpR7qEQA5AQAMAAUIixT9BgBKAQANAAQI9CTqEQA5AQAAAA==.',['一一']='一一点红:BAACKgAFFH8GAAMCAAIIbQ7CVQA/AAACAAEIWwzCVQA/AAAOAAEImAJqFgA4AAAqAAQKfzQABAIACAhSGopLAA8CAAIABwj1HYpLAA8CAAMACAhAFFQcAH0BAA4ABwgKBY8wAN4AAAEqAAUUBAgSAAMAow0A.',['一只']='一只小皮蛋:BAABKgAFFH8IAAIPAAgItg+EBgC9AQAPAAgItg+EBgC9AQAAAA==.',['一叶']='一叶风吹:BAAAKgAFFAEIAQAAAA==.',['一点']='一点点灰:BAACKgAFFH8SAAQDAAQIow0FHQCSAAADAAQIow0FHQCSAAAOAAIIphFqFwB6AAACAAEIUg6liwA8AAAqAAQKfyIABAIACAiOIQgjAHUCAAIACAiOIQgjAHUCAAMACAjwFl0UAMYBAA4AAQgjF01PAEUAAAAA.',['三队']='三队战仕:BAAAKgAECgIIAgAAAA==.',['不良']='不良牛:BAABKgAECn8ZAAMQAAcIehIwMQBbAQAQAAcIehIwMQBbAQARAAEIsglp3wAkAAAAAA==.',['东太']='东太湖论痰:BAAAKgADCggICAAAAA==.',['丨小']='丨小喬丨:BAAAKgAECgcIDQAAAA==.',['丨德']='丨德拉卡丨:BAAAKgAFFAIIAgABKgAFFAgIBAASAAAAAA==.',['丨疯']='丨疯癫丨:BAACKgAFFH8oAAINAAQIgRw0GQDyAAANAAQIgRw0GQDyAAAqAAQKfy8AAg0ACAjCHpoZAEACAA0ACAjCHpoZAEACAAAA.',['中东']='中东大表哥:BAAAKgAECgIIAgAAAA==.',['丶生']='丶生如夏花:BAABKgAFFH8JAAMTAAYIbiOzAQA0AQAUAAUImR3KGAA9AQATAAQINB+zAQA0AQAAAA==.',['丿辉']='丿辉灬夜:BAABKgAFFH8NAAMBAAYI8RVgDABvAQABAAYI8RVgDABvAQAVAAEIAADNJgAAAAAAAA==.',['丿阿']='丿阿尔灬泰尔:BAAAKgAFFAIIAgAAAA==.',['乃嘛']='乃嘛:BAAAKgADCgMIAwAAAA==.',['乌拉']='乌拉圭大菠萝:BAAAKgAECgUIBgAAAA==.',['乌鸡']='乌鸡哥:BAAAKgAECgMIAwAAAA==.',['乔伊']='乔伊:BAABKgAFFH8KAAIPAAgI3R6QAQB9AgAPAAgI3R6QAQB9AgAAAA==.',['九哮']='九哮:BAAAKgAECggICgAAAA==.',['九啸']='九啸:BAABKgAECn8iAAIHAAgIuySbBwCLAgAHAAgIuySbBwCLAgAAAA==.',['九天']='九天雷霆:BAAAKgAECgQIBQAAAA==.',['人间']='人间皮卡丘:BAABKgAFFH8FAAICAAQI/RnGKADPAAACAAQI/RnGKADPAAAAAA==.',['仙人']='仙人摸我鸾:BAABKgAFFH8HAAIPAAYI1RiHCwCPAQAPAAYI1RiHCwCPAQAAAA==.',['仙灵']='仙灵女巫:BAABKgAFFH8UAAIEAAcIDg8WEQBRAQAEAAcIDg8WEQBRAQAAAA==.',['伍柒']='伍柒零叁:BAABKgAECn8cAAIFAAgIJxP5IACEAQAFAAgIJxP5IACEAQAAAA==.',['众生']='众生绝离:BAACKgAFFH8PAAQWAAQIlA3NIgB0AAAWAAMIJA/NIgB0AAAXAAIIsRRMIQBOAAAYAAIIhxVkFQBEAAAqAAQKfzAABBYACAgRG20VAOoBABYACAgRG20VAOoBABgABwh2GlMxAF4BABcABghPC01OAP8AAAAA.',['伴生']='伴生桥亭:BAAAKgAECggICwAAAA==.',['储墨']='储墨:BAABKgAFFH8UAAMUAAYI8iLwBABbAQAUAAUIYCPwBABbAQATAAIIOCG+IQBaAAABKgAFFAgIDAAUAMocAA==.',['元素']='元素之魂:BAAAKgAFFAgIBAAAAA==.',['兜兜']='兜兜里有烟:BAAAKgAECgMIAwAAAA==.',['公元']='公元二零零七:BAAAKgADCgMIAwAAAA==.',['六只']='六只婧婧:BAABKgAFFH8IAAMRAAQI+BLIGwDQAAARAAQI+BLIGwDQAAAQAAIIogWSHABlAAAAAA==.',['六库']='六库仙贼:BAAAKgADCgYIBgAAAA==.',['再次']='再次回首寒暄:BAAAKgAECggIEAAAAA==.',['军团']='军团骑士:BAAAKgADCggICAAAAA==.',['冰歌']='冰歌:BAABKgAFFH8GAAIVAAYIZh5fAwDJAQAVAAYIZh5fAwDJAQAAAA==.',['凉皮']='凉皮:BAABKgAFFH8LAAMZAAQIHiPQBQAbAQAZAAQIHiPQBQAbAQAIAAMIRx/gQgCUAAAAAA==.',['凌波']='凌波微步丶:BAAAKgAFFAYIBAAAAA==.',['刀锋']='刀锋如浪:BAABKgAFFH8JAAIZAAMI7CIXHgACAQAZAAMI7CIXHgACAQAAAA==.',['刘五']='刘五魁:BAAAKgAECggIDgAAAA==.',['别再']='别再吃地板了:BAAAKgAECgEIAQAAAA==.',['别玩']='别玩苍白之主:BAAAKgADCggICAAAAA==.',['剪辑']='剪辑再临:BAABKgAFFH8GAAIUAAYI3xHhAgCkAQAUAAYI3xHhAgCkAQAAAA==.',['北斗']='北斗神桶:BAAAKgAECggICAAAAA==.',['厌恶']='厌恶围城:BAAAKgAECgUIBQAAAA==.',['只影']='只影天涯:BAAAKgAECgUIBQAAAA==.',['史拉']='史拉达:BAAAKgAECgUIBgAAAA==.',['各凭']='各凭本事跑:BAAAKgADCgMIAwAAAA==.',['名字']='名字七个字:BAAAKgADCgEIAQAAAA==.',['向來']='向來緣淺:BAAAKgAFFAMIAwAAAA==.',['向来']='向来如疯:BAAAKgAECggICAAAAA==.向来疯狅:BAAAKgADCgYIBgAAAA==.',['君无']='君无所畏:BAAAKgADCgMIAwAAAA==.',['吾雕']='吾雕腰间绕:BAAAKgADCgYIBgAAAA==.',['周星']='周星星:BAAAKgAFFAQIBAAAAA==.',['哇是']='哇是真的皮:BAAAKgAECgQIBAAAAA==.',['哪像']='哪像伱:BAAAKgADCggICAAAAA==.哪像伱丶:BAAAKgAECgQIBAAAAA==.哪像伱灬:BAAAKgAECgIIAgAAAA==.哪像你灬:BAAAKgADCgIIAgAAAA==.哪像坭:BAAAKgAECggICAAAAA==.哪像妳:BAAAKgAECgMIAwAAAA==.哪像妳灬:BAAAKgAECgMIAwAAAA==.哪像旎:BAAAKgADCggICAAAAA==.',['喵勒']='喵勒戈眯德:BAAAKgAECgMIAwAAAA==.',['回首']='回首多次:BAABKgAECn8UAAIaAAgImxtgCwCMAQAaAAgImxtgCwCMAQAAAA==.回首心冷:BAAAKgAECggIEAAAAA==.回首心疼:BAAAKgAECggIEgAAAA==.',['圣光']='圣光牌手电筒:BAABKgAFFH8IAAICAAgIPgg+DwCuAQACAAgIPgg+DwCuAQAAAA==.圣光的阴影:BAAAKgAECgUICwAAAA==.',['地精']='地精凶猛:BAAAKgADCggICAAAAA==.',['坵彼']='坵彼特:BAAAKgADCggICAAAAA==.',['多次']='多次回首:BAAAKgAECggIEgAAAA==.多次寒暄:BAAAKgAECgcIBwAAAA==.',['夜道']='夜道之雨:BAABKgAFFH8IAAIMAAgInArUAwD0AQAMAAgInArUAwD0AQAAAA==.',['大雨']='大雨吗:BAAAKgAECgMIBAAAAA==.',['大馍']='大馍馍:BAAAKgADCggICAAAAA==.',['天命']='天命半晓:BAAAKgADCgYIBgAAAA==.',['天鸢']='天鸢桜:BAABKgAECn8WAAIKAAgI9xiZKQDZAQAKAAgI9xiZKQDZAQAAAA==.',['太阳']='太阳:BAAAKgADCgIIAgAAAA==.',['奶你']='奶你妹:BAAAKgADCgYIBwAAAA==.',['她说']='她说是晒黑的:BAACKgAFFH8JAAIRAAQIjBu0LQDcAAARAAQIjBu0LQDcAAAqAAQKfycAAhEACAhXJIsQAKQCABEACAhXJIsQAKQCAAAA.',['妒忌']='妒忌围城:BAAAKgAFFAEIAQAAAA==.',['孟波']='孟波辉:BAAAKgADCgIIAgAAAA==.',['宁仙']='宁仙儿:BAACKgAFFH81AAMXAAQIsh3hHADZAAAXAAQIsh3hHADZAAAWAAEIhgQvKwA4AAAqAAQKfyQAAxcACAh7HYolALwBABcACAh7HYolALwBABYAAQiQAD2DAAQAAAAA.',['宋噗']='宋噗噗:BAAAKgAECgIIAgAAAA==.',['宋扑']='宋扑扑:BAAAKgAECgQIBAAAAA==.',['宏先']='宏先生:BAAAKgAECggIAgAAAA==.',['宝宝']='宝宝的笨笨:BAABKgAECn8ZAAICAAgILQwWOQAnAQACAAgILQwWOQAnAQAAAA==.',['富良']='富良野法王:BAAAKgADCgQIAwAAAA==.',['寒江']='寒江夜:BAAAKgAECggIDAAAAA==.',['小十']='小十子:BAAAKgAECgIIAgAAAA==.',['小呆']='小呆瓜:BAABKgAFFH8QAAMXAAYICSMRBwC7AQAXAAYICSMRBwC7AQAWAAQI8BK7GgCrAAAAAA==.',['小小']='小小的麦子:BAAAKgADCggICAAAAA==.',['小苍']='小苍兰:BAABKgAFFH8GAAIbAAYIIQxICwAOAQAbAAYIIQxICwAOAQAAAA==.',['小资']='小资:BAAAKgADCgcICgAAAA==.',['山中']='山中老牛:BAACKgAFFH8NAAIcAAQI8w5AEgCSAAAcAAQI8w5AEgCSAAAqAAQKfzMAAhwACAhsHkIQAGoCABwACAhsHkIQAGoCAAAA.',['山扶']='山扶晚月:BAAAKgADCgUIBQAAAA==.',['岬太']='岬太郎:BAAAKgAECgQIBQAAAA==.',['巴耶']='巴耶克:BAAAKgAECgMIAwAAAA==.',['布鲁']='布鲁托:BAAAKgAECgYIBgAAAA==.',['希里']='希里:BAABKgAFFH8PAAIEAAYIKiXCCQDYAQAEAAYIKiXCCQDYAQABKgAFFAgIBAASAAAAAA==.',['庄颜']='庄颜:BAAAKgADCggICAAAAA==.',['强而']='强而有力:BAAAKgADCggIEAAAAA==.',['御术']='御术临疯:BAACKgAFFH8YAAMUAAUIthp9IQD8AAAUAAMIRxx9IQD8AAATAAMIkhi/EQBdAAAqAAQKfyUAAxQACAjZIecKAJMCABQACAjZIecKAJMCABMABgitGUEyAB0BAAAA.',['怒龙']='怒龙卷毛:BAABKgAECn8tAAILAAgIRwxWIAD/AAALAAgIRwxWIAD/AAAAAA==.',['感伤']='感伤围城:BAACKgAFFH8LAAMHAAMIOhMRMgC3AAAHAAMIoAsRMgC3AAAdAAII/ReZGgB9AAAqAAQKfygAAx0ACAitG3ATAAACAB0ACAiqGXATAAACAAcACAh7ETRWAEwBAAAA.',['愤怒']='愤怒的马哥:BAAAKgAFFAYIBAAAAA==.',['担心']='担心我的学习:BAAAKgAECggICQAAAA==.',['拳头']='拳头弟弟:BAABKgAFFH8IAAIGAAgIEBsvBABpAgAGAAgIEBsvBABpAgAAAA==.',['指间']='指间悟僧:BAAAKgADCgMIAwAAAA==.',['掺水']='掺水的孟婆汤:BAACKgAFFH8QAAMQAAYI4RD1CwBHAQAQAAYI4RD1CwBHAQARAAMINx4rLADiAAAqAAQKfzIAAhEACAhyIfwZAG0CABEACAhyIfwZAG0CAAAA.',['摇滚']='摇滚骷髅:BAAAKgADCgIIAgAAAA==.',['摸嗯']='摸嗯萌:BAAAKgADCgMIAwAAAA==.',['散发']='散发弄扁舟:BAAAKgAECgMIAwAAAA==.',['斗志']='斗志昂扬:BAAAKgAECgYIAwAAAA==.',['无痕']='无痕:BAAAKgADCgcIBwAAAA==.',['星夜']='星夜浸天涯:BAAAKgAECgIIAgAAAA==.',['星球']='星球杯:BAAAKgAECgQIBgAAAA==.',['星辰']='星辰月影:BAACKgAFFH8UAAIZAAUIIxZZIwDiAAAZAAUIIxZZIwDiAAAqAAQKfzcAAhkACAg2IG4RAEoCABkACAg2IG4RAEoCAAAA.',['晨歌']='晨歌:BAABKgAFFH8OAAMRAAgI3iIxBQBwAgARAAcIdSQxBQBwAgAQAAEIbg26NABHAAABKgAFFAgIUAARABcmAA==.',['暗夜']='暗夜使徒:BAAAKgAFFAgIBAAAAA==.',['曲歌']='曲歌:BAABKgAFFH8IAAMWAAYI3h0+BACIAQAWAAUIxR8+BACIAQAXAAMIqyIjFgAEAQABKgAFFAgIBAASAAAAAA==.',['曼彻']='曼彻斯特传奇:BAACKgAFFH8GAAINAAMI+B0dFQAUAQANAAMI+B0dFQAUAQAqAAQKfyAAAg0ACAijJVwDAPoCAA0ACAijJVwDAPoCAAAA.',['曼神']='曼神射手:BAACKgAFFH8bAAMZAAUI0Bc/KQDFAAAZAAUI0Bc/KQDFAAAIAAEIjQh5MAA3AAAqAAQKf0AAAhkACAhnIU0NAHECABkACAhnIU0NAHECAAAA.',['最后']='最后的打手:BAAAKgAECggICgAAAA==.',['有课']='有课题带带我:BAAAKgAECgEIAQAAAA==.',['未来']='未来打手九号:BAAAKgAECgcIEQAAAA==.',['术特']='术特高手:BAAAKgADCgQIBAAAAA==.',['杀怒']='杀怒无止境:BAAAKgADCggICAAAAA==.',['果酱']='果酱味奶糖:BAAAKgAECgYIBgAAAA==.',['枫之']='枫之语:BAABKgAECn83AAMIAAgIgR24NQAeAgAIAAgIEB24NQAeAgAZAAgI/BdGLwCkAQAAAA==.枫之迅捷:BAAAKgADCgcICAAAAA==.',['柳妍']='柳妍妍:BAAAKgAECgYIEAAAAA==.',['桃桃']='桃桃妹:BAABKgAFFH8IAAICAAIIaRDIcwCDAAACAAIIaRDIcwCDAAAAAA==.',['桑叶']='桑叶果:BAAAKgAECgMIAwAAAA==.',['梆击']='梆击大地:BAABKgAFFH8LAAMDAAYIKROFCwCxAAACAAQIoAwpLADAAAADAAUIHRGFCwCxAAAAAA==.',['梦离']='梦离:BAAAKgAECgcICgAAAA==.',['椰飞']='椰飞:BAABKgAFFH8GAAMPAAQI3wyLFgDLAAAPAAQI3wyLFgDLAAAcAAEI5RLPGABKAAAAAA==.',['殺戮']='殺戮:BAABKgAFFH8UAAIeAAMI0SLSCAD+AAAeAAMI0SLSCAD+AAABKgAFFAgIOwARAPIcAA==.',['毛缪']='毛缪缪:BAAAKgAFFAYIBAABKgAFFAgIBAASAAAAAA==.',['沐慕']='沐慕:BAAAKgADCggIFAAAAA==.',['没有']='没有常识的人:BAABKgAECn8iAAIKAAgINxg7JwDnAQAKAAgINxg7JwDnAQAAAA==.',['泰瑞']='泰瑞克:BAAAKgAECggIEwAAAA==.',['满怒']='满怒斬蔱:BAAAKgAECgYIBgAAAA==.',['火炎']='火炎猫头鹰:BAAAKgAECgEIAwAAAA==.',['火焰']='火焰猫头鹰:BAAAKgAECgEIAgAAAA==.',['火焱']='火焱猫头鹰:BAAAKgAECgcICQAAAA==.',['火鸡']='火鸡味锅巴:BAAAKgAECgQIBAAAAA==.',['烈火']='烈火破浪:BAAAKgADCggICAAAAA==.',['爱斯']='爱斯忒莉雅:BAAAKgADCggICAAAAA==.',['牛古']='牛古拉斯凯奇:BAAAKgAECgcIDAAAAA==.',['牛蛙']='牛蛙猪脚鸟:BAAAKgAECggICAAAAA==.',['牛角']='牛角叉:BAAAKgADCgQIBAAAAA==.',['牛鬼']='牛鬼也疯狂:BAAAKgAFFAgIAgAAAA==.',['牧仪']='牧仪天下丨:BAABKgAFFH8IAAIXAAgIHBRcBQDHAQAXAAgIHBRcBQDHAQAAAA==.',['狐狐']='狐狐妹:BAAAKgAECgMIAwAAAA==.',['猎爹']='猎爹试玩:BAABKgAECn8VAAIZAAcIDRM7RABAAQAZAAcIDRM7RABAAQAAAA==.',['猫耳']='猫耳朵:BAABKgAFFH8JAAIRAAYIqxBpPwCtAAARAAYIqxBpPwCtAAAAAA==.',['玄奘']='玄奘:BAAAKgAFFAYIAgAAAA==.',['珝玥']='珝玥婲:BAABKgAFFH8GAAICAAYIFRSfFQBEAQACAAYIFRSfFQBEAQAAAA==.',['痰吐']='痰吐很有档次:BAAAKgAECgUIBQAAAA==.',['白萍']='白萍洲:BAABKgAFFH8IAAICAAgINwoFEACgAQACAAgINwoFEACgAQAAAA==.',['百年']='百年孤寂:BAAAKgAFFAEIAQAAAA==.',['真宝']='真宝珠:BAAAKgADCgEIAQAAAA==.',['破切']='破切口:BAABKgAFFH8GAAICAAYI2SUACQAyAgACAAYI2SUACQAyAgAAAA==.',['神之']='神之爱:BAABKgAFFH8OAAQXAAgIESAVBQDrAQAXAAYIkyAVBQDrAQAYAAYIMR/gBQDYAQAWAAIIrCNrFQDQAAAAAA==.',['神明']='神明灵:BAAAKgAECgcIDgAAAA==.',['神火']='神火兽:BAAAKgAECgEIAQAAAA==.',['神祝']='神祝祷:BAAAKgADCggICAAAAA==.',['秋丨']='秋丨刀鱼:BAAAKgADCggICAAAAA==.',['窦唯']='窦唯:BAAAKgADCggIFwAAAA==.',['章鱼']='章鱼哥灬:BAABKgAFFH8GAAIXAAYIPgz7EQAiAQAXAAYIPgz7EQAiAQAAAA==.',['笕桥']='笕桥往事:BAABKgAECn8YAAIIAAgIOhj9LwDrAQAIAAgIOhj9LwDrAQAAAA==.',['第几']='第几次回收:BAAAKgAECgcICgAAAA==.',['筝丶']='筝丶:BAAAKgAECgQIBAAAAA==.',['粉雪']='粉雪冲浪:BAAAKgAFFAYIAwAAAA==.',['糖来']='糖来丶:BAABKgAECn8TAAMUAAYIhRs3PQB3AQAUAAYIhRs3PQB3AQATAAEIqxGReAA8AAAAAA==.',['紫红']='紫红的:BAAAKgADCgcIBwAAAA==.',['给斋']='给斋饭也要打:BAACKgAFFH8XAAMfAAUIKRt7CwAmAQAfAAMI/iJ7CwAmAQAbAAQIBQpyFQBnAAAqAAQKfy4AAx8ACAgLIAQPAHACAB8ACAgLIAQPAHACABsABwhPFx0tAJ8BAAAA.',['绝岭']='绝岭:BAAAKgAECgMIAwAAAA==.',['继光']='继光香香咕:BAAAKgAFFAIIAwAAAA==.',['罗罗']='罗罗诺阿索罗:BAAAKgADCggICAAAAA==.',['美的']='美的没得比:BAAAKgAECgMIAwAAAA==.美的美的比:BAACKgAFFH8KAAMbAAQIPw5uIgCYAAAbAAQIPw5uIgCYAAAfAAQIXwRjHQB+AAAqAAQKfy0AAhoACAj8F7IKALEBABoACAj8F7IKALEBAAEqAAUUCAgmAAwAeBwA.',['老实']='老实可爱天秀:BAAAKgADCgQIBAAAAA==.',['老牛']='老牛混世界:BAABKgAFFH8HAAIRAAQIAgy2PgCvAAARAAQIAgy2PgCvAAAAAA==.',['老王']='老王:BAAAKgAFFAQIBAAAAA==.',['肥妞']='肥妞我:BAAAKgAECgcIDAAAAA==.',['舞随']='舞随白雪:BAABKgAFFH8GAAMXAAMI/R2ZFwD5AAAXAAMI/R2ZFwD5AAAYAAMIUAg/IwCWAAAAAA==.',['艾莎']='艾莎姐姐:BAAAKgAFFAIIAgAAAA==.',['英姿']='英姿萨爽:BAABKgAECn8VAAIPAAgIsxGcOwCHAQAPAAgIsxGcOwCHAQAAAA==.',['英雄']='英雄的掠影:BAAAKgAECgYIDwAAAA==.',['茶包']='茶包:BAAAKgADCggIFAAAAA==.',['菊鲍']='菊鲍哥:BAAAKgAECgQIBAAAAA==.',['菟纸']='菟纸丨酱:BAAAKgAECggIBgAAAA==.',['萨雷']='萨雷安学长:BAABKgAFFH8FAAIVAAQINQz8GACxAAAVAAQINQz8GACxAAAAAA==.',['虚空']='虚空灬圣:BAABKgAFFH8KAAIXAAYIiR29DABYAQAXAAYIiR29DABYAQAAAA==.',['蛮荒']='蛮荒九哮:BAABKgAFFH8GAAIZAAYIdRKyEwBFAQAZAAYIdRKyEwBFAQAAAA==.蛮荒九啸:BAABKgAECn8dAAIVAAgIfyWWBgDYAgAVAAgIfyWWBgDYAgABKgAFFAgIFQAZAKkcAA==.',['蠡湖']='蠡湖大鹌鹑:BAAAKgAFFAQIBAAAAA==.',['血之']='血之圣印:BAAAKgADCgIIAgAAAA==.',['血色']='血色沙场:BAAAKgAECggICAAAAA==.',['街头']='街头霸王:BAAAKgAECgUIBQAAAA==.',['西阴']='西阴:BAAAKgAFFAQIBAAAAA==.',['詹森']='詹森阿克斯:BAABKgAFFH8IAAIKAAgIcxHNBQARAgAKAAgIcxHNBQARAgAAAA==.',['诸葛']='诸葛青:BAAAKgAECgUIBgAAAA==.',['轻歌']='轻歌漫诵:BAACKgAFFH8VAAICAAUIKxYlQwDpAAACAAUIKxYlQwDpAAAqAAQKfyAAAgIACAhaIlMjAHQCAAIACAhaIlMjAHQCAAAA.',['辛隳']='辛隳瑞拉:BAAAKgADCgEIAQAAAA==.',['逐日']='逐日之沙:BAAAKgAECgEIAQAAAA==.',['野生']='野生大鸡毛:BAAAKgAFFAEIAQAAAA==.',['鑫森']='鑫森淼焱:BAAAKgAECgYIBgAAAA==.',['销魂']='销魂震荡波:BAABKgAFFH8PAAMNAAgI2BaeAwBuAgANAAgI2BaeAwBuAgALAAMIEQlcCgCDAAAAAA==.',['長牙']='長牙的太阳:BAAAKgADCgEIAQAAAA==.',['门先']='门先生小木鸠:BAAAKgADCggICAAAAA==.',['阳澄']='阳澄湖大闸蟹:BAAAKgAECgIIAgAAAA==.',['陇月']='陇月之法:BAABKgAECn8cAAIcAAgIGRQaKgCpAQAcAAgIGRQaKgCpAQAAAA==.',['陈三']='陈三毛:BAAAKgAECgYIBgAAAA==.',['陈无']='陈无敌:BAAAKgADCgMIAwAAAA==.',['陷阵']='陷阵营:BAABKgAECn8YAAIXAAgIQAXiUgDGAAAXAAgIQAXiUgDGAAAAAA==.',['随缘']='随缘一砍:BAAAKgAECgMIAQAAAA==.随缘一锤:BAAAKgAECggICgAAAA==.',['霜玲']='霜玲珑:BAABKgAECn8pAAICAAgIwSJfLgBmAgACAAgIwSJfLgBmAgAAAA==.',['青山']='青山白雪:BAACKgAFFH8FAAIVAAIInwifFwB6AAAVAAIInwifFwB6AAAqAAQKfxkAAxUACAjIGAsiAAACABUACAjIGAsiAAACAAEAAgj6AkWdADQAAAAA.',['青衫']='青衫依旧:BAAAKgAECgIIAgAAAA==.',['青青']='青青小板妹:BAAAKgAECggIEQAAAA==.',['颜里']='颜里:BAAAKgAECgEIAQAAAA==.',['飞鱼']='飞鱼三:BAAAKgAECgcIEQAAAA==.飞鱼二:BAAAKgAECgQIBAAAAA==.',['骑猪']='骑猪娶胖胖:BAAAKgAFFAIIAgAAAA==.',['骑骑']='骑骑马:BAABKgAFFH8GAAICAAYIHgXKNQATAQACAAYIHgXKNQATAQAAAA==.',['鮪魚']='鮪魚:BAABKgAECn8cAAMOAAcI2xS2IQBSAQAOAAYIhhe2IQBSAQACAAYIGxoKuQAmAQAAAA==.',['鱼儿']='鱼儿爸爸:BAAAKgAECggICwABKgAFFAgIDQACAOEYAA==.',['鹌鹑']='鹌鹑蛋蛋:BAAAKgAECggICgAAAA==.',['鹿米']='鹿米露吖:BAAAKgAFFAYIBAAAAA==.',['麻辣']='麻辣香鸡:BAABKgAFFH8OAAIRAAYIFReiFQBsAQARAAYIFReiFQBsAQABKgAFFAgIAgASAAAAAA==.',['龙希']='龙希儿:BAAAKgAECgUIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end