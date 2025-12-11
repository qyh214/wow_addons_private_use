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
 local lookup = {'DeathKnight-Unholy','Mage-Arcane','DeathKnight-Frost','Warlock-Demonology','Warrior-Fury','Mage-Frost','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Paladin-Retribution','Druid-Restoration','Warrior-Protection','Druid-Balance','Shaman-Restoration','Warlock-Destruction','Warrior-Arms','Monk-Mistweaver','Rogue-Outlaw','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-Marksmanship','Unknown-Unknown','Mage-Fire','Paladin-Protection','Shaman-Elemental','DeathKnight-Blood','Paladin-Holy','Monk-Brewmaster','Monk-Windwalker','Priest-Holy','Druid-Feral','Priest-Shadow','Priest-Discipline',}; local provider = {region='CN',realm='玛法里奥',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alielie:BAAALAAECggICwAAAA==.',An='Angelina:BAABLAAFFH8SAAIBAAIImCOuCgC/AAABAAIImCOuCgC/AAAAAA==.',As='Asulic:BAABLAAFFH8PAAICAAQIfxFCPQDUAAACAAQIfxFCPQDUAAAAAA==.',Bp='Bpdine:BAACLAAFFH8JAAIDAAIIjiBAQwCuAAADAAIIjiBAQwCuAAAsAAQKfxkAAgMABwinJPYxAKwCAAMABwinJPYxAKwCAAAA.',Ch='Chanelcoco:BAAALAAECgYIBgAAAA==.Christina:BAABLAAFFH8GAAIEAAIITQ6zGgCNAAAEAAIITQ6zGgCNAAAAAA==.',Co='Coco:BAAALAAECgQIBAAAAA==.',Da='Darkmyth:BAABLAAECn8aAAIFAAYI7RKIjABsAQAFAAYI7RKIjABsAQAAAA==.',Dj='Djboom:BAAALAAECgYICwAAAA==.Djkiller:BAAALAAECgYIDwAAAA==.Djpika:BAAALAAECgYIBwAAAA==.Djpikacue:BAABLAAECn8XAAIGAAYIQBlsMAC5AQAGAAYIQBlsMAC5AQAAAA==.',Dk='Dkings:BAAALAAFFAMIAwAAAA==.',Gq='Gqdb:BAABLAAFFH8LAAIHAAYIHRjiKACQAQAHAAYIHRjiKACQAQAAAA==.Gqddk:BAAALAAECgIIAgAAAA==.Gqddz:BAACLAAFFH8IAAMIAAIIVxECGQCbAAAIAAIIBQ8CGQCbAAAJAAEIvQk6GwAAAAAsAAQKfxgAAwgABgjvHK0jAPwBAAgABgjvHK0jAPwBAAkAAQgCCwwlAAAAAAAA.Gqdsm:BAAALAAECgYIDwAAAA==.',Hy='Hyman:BAAALAAECgEIAQAAAA==.',Iz='Izumisakai:BAAALAAECgQIBAAAAA==.',Ka='Katherina:BAACLAAFFH8MAAIKAAIIah6bKgC0AAAKAAIIah6bKgC0AAAsAAQKfyIAAgoACAjLHGsyAKgCAAoACAjLHGsyAKgCAAAA.',Ki='Killercow:BAABLAAFFH8GAAILAAIIQQ+TNQBqAAALAAIIQQ+TNQBqAAAAAA==.Killingpart:BAAALAADCgQIBAAAAA==.',Ku='Kumo:BAABLAAFFH8GAAIDAAYIjRUYGgBbAQADAAYIjRUYGgBbAQAAAA==.',Le='Leon:BAAALAAFFAEIAQAAAA==.',Li='Licorice:BAAALAAECgYIBwAAAA==.Lifengzs:BAABLAAFFH8GAAIMAAYIzRMbEgA1AQAMAAYIzRMbEgA1AQAAAA==.Lightstalker:BAAALAAECgcIEAAAAA==.',Lo='Lonedruid:BAAALAAECgYIBgAAAA==.',Ly='Lynx:BAABLAAFFH8IAAILAAYIowGUQABxAAALAAYIowGUQABxAAAAAA==.',Mp='Mplusempress:BAABLAAFFH8RAAMNAAYI9hGZEwBIAQANAAYI9hGZEwBIAQALAAIIHBY/PgB4AAAAAA==.',Pa='Panamera:BAABLAAFFH8HAAMGAAMIoBDoEwBHAAACAAMIHgchSgB0AAAGAAIIihfoEwBHAAAAAA==.Paradisekiss:BAABLAAFFH8jAAIFAAYIvyEYDgDoAQAFAAYIvyEYDgDoAQABLAAFFAYIJQAHAMkgAA==.',Pr='Promise:BAAALAADCgQIBAAAAA==.',Qc='Qc:BAAALAAECgYICAAAAA==.',Ra='Raccoonhill:BAAALAAECgcICQAAAA==.Rad:BAABLAAFFH8HAAIGAAIIDBGaFACEAAAGAAIIDBGaFACEAAAAAA==.',Re='Renata:BAAALAAECgUICAAAAA==.',Se='Serendipity:BAABLAAECn8VAAIKAAgIMB1tGQBEAgAKAAgIMB1tGQBEAgAAAA==.',Sh='Shuoshuo:BAABLAAFFH8KAAIOAAIIIBwqQACBAAAOAAIIIBwqQACBAAAAAA==.',Sp='Spectator:BAAALAAECggICAAAAA==.',St='Starle:BAABLAAFFH8GAAIPAAMIew6RTQCEAAAPAAMIew6RTQCEAAAAAA==.Stefsunyanzi:BAAALAAECgYIDQAAAA==.',Su='Sumton:BAAALAAECgUIBQAAAA==.',Ta='Taoist:BAAALAADCgEIAQAAAA==.',Tr='Traxex:BAAALAAECgYICwAAAA==.',Ve='Ventgo:BAAALAAECgYICwAAAA==.',Wa='Warforever:BAAALAAECggIDgAAAA==.',Wo='Wolftotme:BAAALAADCggICAAAAA==.',Zd='Zd:BAABLAAECn8WAAMQAAYIwhoGBgB8AQAQAAYIwhoGBgB8AQAMAAEI3wNOoQAcAAAAAA==.',['一秒']='一秒的记忆:BAAALAAFFAIIAwAAAA==.',['一路']='一路奶粉:BAACLAAFFH8wAAIRAAYIOSJkAwBFAgARAAYIOSJkAwBFAgAsAAQKfx4AAhEACAhqH6YJAMsCABEACAhqH6YJAMsCAAAA.',['一踏']='一踏雪归来一:BAAALAADCgIIAgAAAA==.',['一醉']='一醉影盗魂一:BAAALAAFFAIIAgAAAA==.',['七夜']='七夜:BAAALAAECgUIBQAAAA==.',['七小']='七小度:BAAALAADCgcIBwAAAA==.',['七度']='七度:BAABLAAECn8UAAISAAgI5xHOBABVAQASAAgI5xHOBABVAQAAAA==.',['三秒']='三秒的记忆:BAABLAAFFH8HAAMTAAMICAp+IgDbAAATAAMIXwl+IgDbAAAUAAII7goDFQBgAAAAAA==.',['三路']='三路奶粉:BAAALAAFFAMIBAAAAA==.',['上啊']='上啊皮卡丘:BAAALAAECgEIAQAAAA==.',['不吃']='不吃香菜:BAAALAAECgIIAgAAAA==.',['不朽']='不朽之息:BAABLAAFFH8GAAIDAAYISAZ1EwCxAQADAAYISAZ1EwCxAQAAAA==.',['东东']='东东包:BAACLAAFFH8LAAMHAAMIXhZfagCOAAAHAAMIXhZfagCOAAAVAAII5QzyJgB6AAAsAAQKfxsAAwcABgiNHa5VAJgBAAcABgiNHa5VAJgBABUABggsGX5IAJMBAAAA.东东包的小熊:BAAALAAECgYIBgAAAA==.',['两千']='两千次全胜:BAABLAAFFH8jAAIDAAYIUB/JGgDMAQADAAYIUB/JGgDMAQABLAAFFAYIJQAHAMkgAA==.',['丶屠']='丶屠戮:BAAALAAECgIIAgABLAAFFAUIHwAFAJobAA==.',['丶昼']='丶昼光:BAAALAAECgIIAgAAAA==.',['丶暮']='丶暮霞:BAABLAAECn8UAAIKAAgIoCQ1EQA1AwAKAAgIoCQ1EQA1AwAAAA==.',['丶桃']='丶桃之夭夭丶:BAAALAADCgIIAgAAAA==.',['丶溜']='丶溜肉段:BAAALAAFFAEIAQAAAA==.',['丶独']='丶独钓寒江雪:BAAALAAFFAIIAgAAAA==.',['丶赤']='丶赤炼:BAAALAADCgYIBgAAAA==.',['丶飞']='丶飞锻:BAAALAADCgQIBAAAAA==.',['丶龙']='丶龙希尔:BAAALAADCgYIBgAAAA==.',['丿不']='丿不羁:BAAALAAECgYICQAAAA==.',['丿余']='丿余生:BAAALAAECgYICQAAAA==.',['丿奈']='丿奈何:BAAALAAECgIIAgAAAA==.',['乐乐']='乐乐球球:BAAALAAECgUIBQAAAA==.',['乐悠']='乐悠然:BAAALAAECgYICAAAAA==.',['乱者']='乱者:BAAALAAECggIEgAAAA==.',['二八']='二八二五六:BAAALAAECgcIBwAAAA==.',['二十']='二十八华生:BAAALAAECgUIDwAAAA==.',['人生']='人生若如初见:BAABLAAFFH8SAAIKAAMIhxMWQgCOAAAKAAMIhxMWQgCOAAAAAA==.',['今日']='今日清风拂面:BAABLAAFFH8IAAIHAAIIIxl0gABVAAAHAAIIIxl0gABVAAABLAAFFAgIBAAWAAAAAA==.',['仧小']='仧小吉:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利蛋蒙牛奶:BAAALAAECgYIEgAAAA==.',['你们']='你们的奶爸:BAAALAAECgYIBgAAAA==.',['你会']='你会变身吗:BAAALAADCgcIBwAAAA==.',['保安']='保安九五二七:BAAALAADCgQIBAAAAA==.保安老窝囊:BAAALAAECgMIAwAAAA==.',['光之']='光之怒吼:BAAALAAFFAEIAQAAAA==.',['六翼']='六翼使徒:BAABLAAECn8aAAIKAAgI+h2WQgB0AgAKAAgI+h2WQgB0AgAAAA==.',['兰陵']='兰陵夜影:BAAALAADCgQIBAAAAA==.',['再现']='再现繁华:BAAALAAECggICAAAAA==.',['冰封']='冰封千里:BAAALAAECgYIBgAAAA==.冰封的恋:BAABLAAFFH8IAAIDAAII0wntgACGAAADAAII0wntgACGAAAAAA==.',['冰箱']='冰箱里的胖丁:BAACLAAFFH8RAAMCAAUI2w/VNgAaAQACAAUIZA7VNgAaAQAXAAII6Q8TDQBDAAAsAAQKfxQABAIACAhPHLFSAAwCAAIACAjJGbFSAAwCAAYAAQhjG3CIAFEAABcAAQgkB4clAC4AAAAA.',['冰美']='冰美式不加糖:BAAALAAECgYIBgAAAA==.',['凉透']='凉透德蛋炒饭:BAAALAAECggIDgAAAA==.',['出门']='出门遛萨摩耶:BAABLAAFFH8GAAILAAIIBA7JNgBpAAALAAIIBA7JNgBpAAAAAA==.',['刘坤']='刘坤:BAABLAAFFH8MAAIDAAYImhaHJACiAQADAAYImhaHJACiAQAAAA==.',['刘宏']='刘宏辉:BAAALAAECgIIAgAAAA==.',['别让']='别让我加血:BAAALAAECgYIBwAAAA==.',['刺儿']='刺儿丫头:BAACLAAFFH8GAAIHAAYIwR3OIACvAQAHAAYIwR3OIACvAQAsAAQKfx8AAgcABghyJMcrAAkCAAcABghyJMcrAAkCAAAA.',['前进']='前进路:BAAALAADCggICAAAAA==.',['劣人']='劣人甲:BAABLAAFFH8GAAIHAAIIQwcHqQA6AAAHAAIIQwcHqQA6AAAAAA==.',['勿语']='勿语:BAAALAAFFAMIAQAAAA==.',['十二']='十二路奶粉:BAAALAAFFAIIAgAAAA==.',['千千']='千千雪:BAABLAAFFH8GAAMCAAYImAG8QQCeAAACAAUIiQG8QQCeAAAXAAEI3wFjEAAoAAAAAA==.',['千颜']='千颜人仙:BAAALAAECggICQAAAA==.',['半糖']='半糖丶椰汁:BAAALAAECggICAAAAA==.',['卢樱']='卢樱花:BAAALAAECgYICgAAAA==.',['原价']='原价:BAABLAAFFH8VAAMYAAQI0xRTDADMAAAYAAQI0xRTDADMAAAKAAMILgeXSgBtAAAAAA==.',['去叭']='去叭皮卡丘:BAAALAAECgQIBAAAAA==.',['及格']='及格线:BAAALAAECgYIEgAAAA==.',['反杀']='反杀:BAAALAAECgMIBQAAAA==.',['口袋']='口袋小石头:BAAALAAECggICAABLAAFFAgIHAANAOIkAA==.',['吃饭']='吃饭吧唧嘴:BAABLAAFFH8GAAMLAAYIbAcuNgCRAAALAAQITwMuNgCRAAANAAIIXwHZKwBTAAAAAA==.',['吉尔']='吉尔伽美什:BAAALAAECgYIBgAAAA==.',['名字']='名字也是送的:BAABLAAFFH8FAAIDAAIIyxEyYACYAAADAAIIyxEyYACYAAAAAA==.',['吸血']='吸血闪避插槽:BAAALAAECgYIDQAAAA==.',['呼吸']='呼吸大魔王:BAAALAAFFAIIBAAAAA==.',['命归']='命归尘:BAAALAAFFAIIAgAAAA==.',['咏春']='咏春别问:BAAALAADCgcIBwAAAA==.',['品如']='品如的衣柜:BAAALAADCgcIBwAAAA==.',['喜剧']='喜剧人啊:BAAALAAECgMIAgAAAA==.',['喵儿']='喵儿哇:BAAALAAECgYIDAAAAA==.',['嘂兽']='嘂兽:BAAALAAECgYIBgAAAA==.',['嘟嘟']='嘟嘟宝:BAABLAAFFH8KAAIZAAYIcgThJgAQAQAZAAYIcgThJgAQAQAAAA==.',['噗滋']='噗滋灬噗滋:BAAALAAECgMIAwAAAA==.',['噯悠']='噯悠喂:BAAALAAECgMIAwAAAA==.',['回到']='回到最初:BAABLAAFFH8GAAIaAAYIQxjRCQB5AQAaAAYIQxjRCQB5AQAAAA==.',['国宝']='国宝要睡觉:BAAALAAECgYIBgAAAA==.',['圣光']='圣光亮瞎你:BAAALAAECgYIBgAAAA==.圣光又忽悠你:BAAALAADCgMIAwAAAA==.',['圣壂']='圣壂骑士:BAAALAAECgYIDAAAAA==.',['在世']='在世真龍:BAAALAAECgEIAQAAAA==.',['坂井']='坂井泉水:BAAALAAECgYIBgAAAA==.',['均衡']='均衡之镰:BAABLAAFFH8RAAITAAUIABzsIwBsAQATAAUIABzsIwBsAQAAAA==.',['坑到']='坑到底:BAAALAAECgYIDAAAAA==.',['坚果']='坚果墙丶:BAAALAAECgYIBgAAAA==.',['声声']='声声入耳:BAAALAAFFAIIAgAAAA==.',['大橘']='大橘子:BAAALAAECgcIDAAAAA==.',['大跳']='大跳飞逝:BAAALAAECgUIBQAAAA==.',['大香']='大香蕉:BAAALAAECgUICgAAAA==.',['大髙']='大髙个:BAAALAAECgMIAwAAAA==.',['天下']='天下为公:BAAALAAECgYIBgAAAA==.',['天意']='天意宝贝:BAAALAADCgUIBQAAAA==.天意归来:BAAALAAECgIIAgAAAA==.天意猎狂:BAAALAAECgcIEQAAAA==.',['天海']='天海翼:BAAALAADCgMIAwAAAA==.',['天涯']='天涯海阁:BAAALAAECgYIDQAAAA==.',['天真']='天真小流氓:BAAALAADCgIIAgAAAA==.',['太岁']='太岁神:BAABLAAFFH8FAAMOAAMIuhJnOgC5AAAOAAMIuhJnOgC5AAAZAAEI3AitSQA9AAAAAA==.',['太有']='太有波哈了:BAAALAAECgYICAAAAA==.',['失误']='失误的术:BAACLAAFFH8KAAIPAAIIJQsGUACBAAAPAAIIJQsGUACBAAAsAAQKfx8AAw8ABwhtGf07AFgBAAQABQhHF4NBAGgBAA8ABgiDGv07AFgBAAAA.',['奎托']='奎托斯:BAAALAAECgEIAQAAAA==.',['奥蕾']='奥蕾:BAAALAAECgQICQAAAA==.',['奧博']='奧博倫影歌:BAAALAAECgYIEgAAAA==.',['如熙']='如熙:BAABLAAECn8YAAIGAAYI6ByCKADmAQAGAAYI6ByCKADmAQAAAA==.',['如约']='如约而至丶:BAAALAAECgYIEgAAAA==.',['妖妖']='妖妖白玉猫:BAAALAAECgYICAAAAA==.',['威武']='威武梁会长:BAAALAAECgYIBwAAAA==.',['娜宝']='娜宝宝:BAABLAAECn8pAAIGAAcIfSEXCABFAgAGAAcIfSEXCABFAgAAAA==.',['娜美']='娜美丶:BAAALAAFFAQIBAAAAA==.',['娲娲']='娲娲:BAABLAAFFH8QAAIMAAUI8BdFDQDvAAAMAAUI8BdFDQDvAAAAAA==.',['婀娜']='婀娜辛迪:BAAALAADCggICAAAAA==.',['孙培']='孙培元:BAABLAAFFH8GAAIDAAYIIxYaKACVAQADAAYIIxYaKACVAQAAAA==.',['安七']='安七炫:BAAALAAECgMIAwAAAA==.',['寒羽']='寒羽良:BAAALAADCgcIDQAAAA==.',['射虚']='射虚:BAAALAADCgYIBgAAAA==.',['射雷']='射雷:BAAALAAECgcIDgAAAA==.',['小吱']='小吱吱:BAABLAAFFH8eAAIMAAYILBGuEQA6AQAMAAYILBGuEQA6AQAAAA==.',['小团']='小团子丶:BAABLAAFFH8MAAIOAAII0hUPTgCAAAAOAAII0hUPTgCAAAAAAA==.',['小怪']='小怪快打:BAAALAADCgQIBAAAAA==.',['小术']='小术丨点:BAAALAADCgYIBgAAAA==.',['小短']='小短腿啊:BAAALAAECgYIDAAAAA==.',['小鈅']='小鈅鈅:BAABLAAFFH8HAAIKAAIIqg03agBBAAAKAAIIqg03agBBAAAAAA==.',['小陈']='小陈不吃苹果:BAAALAAFFAMIAwAAAA==.',['小静']='小静:BAAALAAECgEIAQAAAA==.',['尛嘉']='尛嘉嘉:BAAALAADCgMIAwAAAA==.',['尛媚']='尛媚娘:BAAALAAECggIBQAAAA==.',['就勾']='就勾巴她了:BAAALAAECgMIAwAAAA==.',['就是']='就是不让骑:BAAALAAECgIIAgAAAA==.',['屠魔']='屠魔者:BAAALAADCgMIAwAAAA==.',['岁岁']='岁岁:BAAALAAECgIIAgAAAA==.',['崩哒']='崩哒啦:BAAALAAECgYIBwAAAA==.',['布拉']='布拉多尔:BAABLAAECn8cAAMKAAYIzhOgaAAxAQAKAAYIzhOgaAAxAQAbAAYIUxKlIwAlAQAAAA==.',['希尔']='希尔梅斯:BAABLAAECn8hAAMGAAYIMBcJNQCjAQAGAAYICBcJNQCjAQACAAYIJxJ5PAAbAQAAAA==.',['帕娜']='帕娜索尼克:BAAALAADCgYIBgAAAA==.',['帕帕']='帕帕索尼克:BAAALAAECgYIBwAAAA==.',['常赢']='常赢:BAAALAAECgYICgAAAA==.',['幕星']='幕星公主:BAAALAAECggICAAAAA==.',['幻影']='幻影奇袭:BAAALAAFFAIIAgAAAA==.',['张小']='张小弟:BAACLAAFFH8mAAIcAAYIfhdsDAB9AQAcAAYIfhdsDAB9AQAsAAQKfz4AAx0ACAhIIfoDAKICAB0ACAiWIPoDAKICABwACAidGtIGAAsCAAAA.',['影魔']='影魔魂之挽歌:BAAALAAECggIDwAAAA==.',['心宅']='心宅人厚:BAAALAAECggICAAAAA==.',['心悦']='心悦橙服:BAABLAAFFH8GAAITAAIIvRRzPQCbAAATAAIIvRRzPQCbAAAAAA==.',['心照']='心照一生:BAACLAAFFH8fAAIOAAcIzR48BACFAgAOAAcIzR48BACFAgAsAAQKfzUAAw4ACAhEJhQBAF0DAA4ACAhEJhQBAF0DABkABwiFDy97AE8BAAAA.',['怡寶']='怡寶:BAAALAAECgIIAgAAAA==.',['意外']='意外之外:BAAALAAECgcIBwAAAA==.',['慈悲']='慈悲度魂落:BAAALAADCgYIBgAAAA==.',['慢读']='慢读:BAAALAAECgQIBAAAAA==.',['懿贰']='懿贰叁肆伍:BAAALAAECgIIAgAAAA==.',['我宝']='我宝宝呢:BAAALAAFFAMIAwAAAA==.',['我想']='我想恰火锅了:BAAALAAECggICgAAAA==.',['我掩']='我掩护你送死:BAAALAAECggICgAAAA==.',['或许']='或许会离别:BAABLAAFFH8GAAMbAAIIqA1yHgCMAAAbAAIIqA1yHgCMAAAKAAIITxx5WgBJAAAAAA==.',['戮世']='戮世魔罗:BAAALAAECgYIDgAAAA==.',['抓一']='抓一只是一只:BAAALAAECggIEQAAAA==.',['拉不']='拉不拉都稀:BAABLAAFFH8NAAIDAAMIlR9YVAC9AAADAAMIlR9YVAC9AAABLAAFFAgIBAAWAAAAAA==.',['提爾']='提爾:BAAALAADCgQIBAAAAA==.',['摸电']='摸电门的喵喵:BAABLAAFFH8GAAIOAAIISgfpZQBbAAAOAAIISgfpZQBbAAABLAAFFAUIEQATAAAcAA==.摸电门的烈雀:BAAALAADCgYIBgABLAAFFAUIEQATAAAcAA==.',['改名']='改名字是送的:BAABLAAFFH8FAAIFAAIIKRVRLgChAAAFAAIIKRVRLgChAAAAAA==.',['攻守']='攻守道:BAAALAAECgYIBgAAAA==.',['斯慕']='斯慕吉:BAAALAAFFAIIAgAAAA==.',['无尽']='无尽丶输出:BAABLAAFFH8FAAITAAIIwxd0VwBEAAATAAIIwxd0VwBEAAAAAA==.',['无敌']='无敌卡布达丶:BAAALAAECgYIBgAAAA==.无敌大怪兽:BAAALAADCgMIAwAAAA==.',['无能']='无能狂怒:BAAALAAECgQIBQAAAA==.',['无需']='无需多言:BAABLAAFFH8QAAILAAUIPBs1BwCrAQALAAUIPBs1BwCrAQAAAA==.',['旺仔']='旺仔大馒头:BAABLAAFFH8HAAIOAAcIphxiBwBMAgAOAAcIphxiBwBMAgAAAA==.',['昂寇']='昂寇:BAABLAAECn8hAAIDAAgIGCNnJwDTAgADAAgIGCNnJwDTAgAAAA==.',['晚霞']='晚霞:BAABLAAFFH8KAAIbAAMIuBr0GwDLAAAbAAMIuBr0GwDLAAAAAA==.',['普贤']='普贤:BAAALAADCggICAAAAA==.',['智鱼']='智鱼:BAAALAAECgYIBwAAAA==.',['暖山']='暖山语:BAAALAADCgIIAgAAAA==.',['最后']='最后的怀念:BAABLAAFFH8GAAILAAII3A3tNgBpAAALAAII3A3tNgBpAAAAAA==.',['月夜']='月夜幻歌:BAAALAADCgMIAwAAAA==.',['有医']='有医保的熊猫:BAAALAAFFAIIBAAAAA==.',['木瓜']='木瓜:BAAALAAECgYIBgAAAA==.木瓜很瞌睡:BAAALAAECgYIBgAAAA==.',['末路']='末路狂猫:BAAALAADCgQIBAAAAA==.',['朵娜']='朵娜丶:BAAALAADCgMIAwAAAA==.',['杠上']='杠上开花:BAAALAAFFAIIBAAAAA==.',['杨声']='杨声波:BAABLAAFFH8GAAIDAAYIzxDHLgB/AQADAAYIzxDHLgB/AQAAAA==.',['杨小']='杨小颖:BAAALAAECggICAAAAA==.',['枼小']='枼小钗:BAABLAAFFH8HAAIDAAII2xGzhgBCAAADAAII2xGzhgBCAAAAAA==.',['柠檬']='柠檬水五分糖:BAABLAAFFH8IAAIDAAII4wTGoQA0AAADAAII4wTGoQA0AAABLAAFFAgICgATAJ0EAA==.',['树林']='树林里的毛球:BAAALAAECgMIAwABLAAFFAUIEQATAAAcAA==.',['格衬']='格衬衫:BAAALAAECgYICwAAAA==.',['格雷']='格雷琴:BAAALAAECgYICAAAAA==.',['梦依']='梦依然:BAAALAADCgUIBQABLAAECggIGgAKAPodAA==.',['梦深']='梦深渊:BAABLAAFFH8OAAMOAAYIyQ6rLgD3AAAOAAUIbBCrLgD3AAAZAAIIYQJ4OwBdAAAAAA==.',['橘子']='橘子:BAAALAAECgYIDAAAAA==.',['欲死']='欲死欲仙:BAAALAADCgIIAgAAAA==.',['死灰']='死灰:BAAALAAECgEIAQAAAA==.',['死神']='死神来了:BAAALAAECgYIDQAAAA==.',['残响']='残响死灭:BAABLAAFFH8LAAIaAAMIZBwQDAC0AAAaAAMIZBwQDAC0AAAAAA==.',['水葫']='水葫芦:BAAALAAECgYICAAAAA==.',['水蜻']='水蜻蜓:BAAALAAECggIEQAAAA==.',['江天']='江天君:BAABLAAFFH8OAAIOAAMIrx3qMwDXAAAOAAMIrx3qMwDXAAAAAA==.',['江晴']='江晴:BAABLAAECn8mAAIOAAgINw49hQB1AQAOAAgINw49hQB1AQAAAA==.',['江船']='江船夜雨:BAAALAAECgYICwAAAA==.',['油炸']='油炸冰淇淋:BAAALAAECggIDgAAAA==.',['沿海']='沿海地带:BAABLAAFFH8FAAILAAIIEg83RwBgAAALAAIIEg83RwBgAAAAAA==.',['洽宝']='洽宝:BAAALAAECgMIAwAAAA==.',['流浪']='流浪的螺丝钉:BAAALAADCgEIAQAAAA==.',['浅川']='浅川:BAAALAADCgIIAgAAAA==.',['浅逝']='浅逝一袭琉璃:BAAALAAFFAEIAQAAAA==.',['海格']='海格拉:BAABLAAECn8WAAIPAAYI0xqiMQCGAQAPAAYI0xqiMQCGAQAAAA==.',['淡定']='淡定喝酸奶:BAAALAAFFAIIBAAAAA==.',['渺小']='渺小坦克车:BAAALAAFFAIIBAAAAA==.',['溪下']='溪下清影:BAAALAAFFAIIAgAAAA==.溪下雪舞:BAABLAAFFH8JAAMLAAIIfA4bSQBdAAALAAIIfA4bSQBdAAANAAEIXgqULQBEAAAAAA==.',['漭沆']='漭沆纁洲:BAABLAAFFH8OAAITAAgIVSXgBgBoAgATAAgIVSXgBgBoAgAAAA==.',['火火']='火火炎:BAAALAAECgcIBwAAAA==.',['灬爱']='灬爱喝咖啡灬:BAAALAAFFAgIAgAAAA==.',['灭霸']='灭霸有理想:BAABLAAECn8ZAAMMAAYIpwqvagDgAAAMAAYIhQmvagDgAAAFAAUIcwdRiAB7AAAAAA==.',['灵儿']='灵儿疯丫头:BAAALAAFFAIIAgAAAA==.',['灵境']='灵境之风:BAAALAADCgMIAwAAAA==.',['灵戎']='灵戎:BAABLAAFFH8HAAMYAAcI4gFvIwAjAAAYAAUI+QBvIwAjAAAbAAIIHAC/MQARAAAAAA==.',['灾难']='灾难慢我一步:BAAALAAFFAIIAwAAAA==.',['炙热']='炙热的花生:BAAALAAECgUIDAAAAA==.',['炯兮']='炯兮:BAAALAAFFAMIBAAAAA==.',['热带']='热带鱼:BAABLAAECn8iAAMGAAgIcR3/GQBKAgAGAAgIKhz/GQBKAgACAAcIIxi0WAD6AQAAAA==.',['然然']='然然:BAABLAAFFH8IAAINAAYI7xOgEwBIAQANAAYI7xOgEwBIAQABLAAFFAgIAQAWAAAAAA==.',['熊丶']='熊丶小兔:BAAALAAECgcICAAAAA==.',['燃烧']='燃烧的花生:BAABLAAFFH8GAAMbAAIIvRHLJQB1AAAbAAIIvRHLJQB1AAAKAAIIzgjPcgA8AAAAAA==.',['爱乃']='爱乃娜美:BAAALAAECgEIAgAAAA==.',['爱莎']='爱莎莉:BAACLAAFFH9FAAIPAAgIix/TBwB/AgAPAAgIix/TBwB/AgAsAAQKf00AAg8ACAg6JWEKAEcDAA8ACAg6JWEKAEcDAAAA.',['狂怒']='狂怒冰者:BAAALAAECgYIBgAAAA==.狂怒猎者:BAAALAAFFAIIAgAAAA==.狂怒腾德尔:BAABLAAECn8UAAIHAAYIphQtiQA6AQAHAAYIphQtiQA6AQAAAA==.',['狐苏']='狐苏茗悠米:BAABLAAFFH8UAAIHAAYI/SIVEQACAgAHAAYI/SIVEQACAgAAAA==.',['猎影']='猎影釖鎽:BAAALAADCgMIAwAAAA==.',['猎杀']='猎杀灬者:BAAALAAECgIIAgAAAA==.',['猫筱']='猫筱牧:BAABLAAFFH8HAAIeAAIIBgsiNwCFAAAeAAIIBgsiNwCFAAAAAA==.',['王大']='王大胆:BAAALAAECgYIEAAAAA==.王大胆会武术:BAAALAAECgMIAwAAAA==.',['玖捌']='玖捌伍:BAABLAAFFH8IAAITAAIIZhrJKwCzAAATAAIIZhrJKwCzAAAAAA==.',['玫月']='玫月:BAAALAAFFAIIBAAAAA==.',['琦玉']='琦玉:BAAALAADCggICAAAAA==.',['甜瓜']='甜瓜:BAAALAADCgQIBAAAAA==.',['生前']='生前很純潔:BAABLAAFFH8FAAQNAAMILA2uJgB9AAANAAIIaw6uJgB9AAALAAIIUxMyQQBvAAAfAAEIrQpOEwAAAAAAAA==.',['生死']='生死一念:BAAALAADCgYIBgAAAA==.',['盛夏']='盛夏灬光年:BAAALAAECgYIDAAAAA==.',['睡不']='睡不醒丶天蝎:BAAALAADCggIEQAAAA==.',['矮壮']='矮壮俏佳人:BAAALAAECgYIDQAAAA==.',['硬哥']='硬哥们:BAAALAAECgYIBgAAAA==.',['神奇']='神奇小饼干:BAAALAAFFAEIAQAAAA==.',['秀儿']='秀儿瓦纳斯:BAAALAAECgMIAwAAAA==.',['秋月']='秋月无边:BAABLAAECn80AAIRAAgIBRuFEQBWAgARAAgIBRuFEQBWAgABLAAFFAgIBwAFAEIWAA==.',['筱璟']='筱璟瑜:BAAALAAECgYIBgAAAA==.',['箭走']='箭走偏锋:BAAALAAECgEIAQAAAA==.',['精精']='精精糊:BAABLAAFFH8GAAIUAAYIKQxvBwD8AAAUAAYIKQxvBwD8AAAAAA==.',['紫氣']='紫氣东来:BAAALAAECgYICAAAAA==.',['紫色']='紫色繁华:BAAALAADCgIIAgAAAA==.',['紫芙']='紫芙:BAABLAAFFH8NAAIPAAMIow/sTgB/AAAPAAMIow/sTgB/AAAAAA==.',['紫雨']='紫雨冰封:BAAALAADCgMIAwAAAA==.',['縵步']='縵步街頭:BAABLAAFFH8GAAIGAAIIvAc5HgA0AAAGAAIIvAc5HgA0AAAAAA==.',['红色']='红色体育生:BAAALAADCgQIBAAAAA==.',['结城']='结城结弦:BAAALAAECgEIAQAAAA==.',['绮罗']='绮罗香:BAAALAAECgUIBwAAAA==.',['罗西']='罗西明:BAAALAADCgEIAQAAAA==.',['罗雷']='罗雷:BAAALAADCgEIAQAAAA==.',['翼翔']='翼翔天空院:BAAALAADCgQIBAAAAA==.',['联盟']='联盟暴丝:BAAALAAECgcIBwAAAA==.',['聖殿']='聖殿小賊:BAAALAAECgQIBAAAAA==.聖殿法老:BAAALAAECgYIEwAAAA==.聖殿猎魂:BAAALAAFFAIIAgAAAA==.聖殿黯黑:BAAALAAECgYIBgAAAA==.',['股尔']='股尔丹:BAAALAAECgIIAwAAAA==.',['肯塔']='肯塔基波旁:BAACLAAFFH8jAAIPAAYI9BX8HQA/AQAPAAYI9BX8HQA/AQAsAAQKfyEAAg8ABwg4HU9GACMCAA8ABwg4HU9GACMCAAAA.',['胖橘']='胖橘子:BAAALAAECgYIEgAAAA==.',['胖琥']='胖琥:BAABLAAECn8YAAIPAAYIiB39MQCEAQAPAAYIiB39MQCEAQAAAA==.',['艾尔']='艾尔菲娅:BAAALAAFFAIIBAAAAA==.',['芷閖']='芷閖:BAAALAAECgIIAgAAAA==.',['芷风']='芷风:BAABLAAFFH8GAAITAAIIKA0OTQCPAAATAAIIKA0OTQCPAAAAAA==.',['苍煜']='苍煜青岚:BAAALAAECgYIDAAAAA==.',['苏拉']='苏拉玛扛把子:BAAALAAECgYIBwAAAA==.',['若语']='若语無尽:BAAALAAECggICAAAAA==.',['菀柔']='菀柔灬:BAAALAAECggICAAAAA==.',['菲尔']='菲尔西斯:BAAALAAECgEIAQAAAA==.',['菲尼']='菲尼克丝:BAAALAAFFAYIAQAAAA==.',['萌悍']='萌悍药:BAAALAAECgYIDAAAAA==.',['落叶']='落叶而知秋:BAAALAAECgYIBgAAAA==.',['蓝天']='蓝天中的阴影:BAACLAAFFH8FAAIeAAII/Q2XNACIAAAeAAII/Q2XNACIAAAsAAQKfxgABCAABwisE+RBALIBACAABwisE+RBALIBACEABQiAF3AVAF8BAB4ABQiYEsJ1ABsBAAAA.',['蔫头']='蔫头耷拉脑:BAAALAADCgcIBwAAAA==.',['藏镜']='藏镜人:BAACLAAFFH8GAAIKAAUIXwisMgDtAAAKAAUIXwisMgDtAAAsAAQKfxYABBgABwhqGyAgAPkBABgABgibHSAgAPkBAAoAAQhADjvgAD4AABsAAwjFASNDADgAAAEsAAUUBggNAAMAMxUA.',['虚空']='虚空行者:BAAALAAECgYICwABLAAFFAUIEQATAAAcAA==.',['蜜袋']='蜜袋鼯轰炸机:BAABLAAFFH8lAAIHAAYIySC9GwDEAQAHAAYIySC9GwDEAQAAAA==.蜜袋鼯飞行员:BAABLAAFFH8MAAIKAAMIihnSOwCmAAAKAAMIihnSOwCmAAABLAAFFAYIJQAHAMkgAA==.',['装饰']='装饰的苹果:BAABLAAECn8cAAIMAAgI+ROPKwDrAQAMAAgI+ROPKwDrAQAAAA==.',['说你']='说你爱我:BAABLAAFFH8GAAMBAAIIoRD8EwCJAAABAAIIoQr8EwCJAAADAAIIoRBMjQA/AAAAAA==.',['请嫑']='请嫑打我:BAAALAAECgYICwAAAA==.',['诸神']='诸神丶心雨:BAACLAAFFH8cAAMVAAYI5iArAgAvAgAVAAYIHyArAgAvAgAHAAQIux78VwDsAAAsAAQKfx4AAxUACAibJJwGADQDABUACAibJJwGADQDAAcAAQgSIQ9/AV0AAAAA.',['读书']='读书有益健康:BAAALAAFFAIIBAAAAA==.',['豹式']='豹式:BAAALAADCgEIAQAAAA==.',['走路']='走路抖露手:BAABLAAFFH8HAAIKAAUIIhoNCQDVAQAKAAUIIhoNCQDVAQAAAA==.',['走错']='走错:BAABLAAFFH8UAAIOAAYIRQq5KgAQAQAOAAYIRQq5KgAQAQAAAA==.',['起舞']='起舞紫牛:BAABLAAFFH8QAAIcAAgIzR4CAgCSAgAcAAgIzR4CAgCSAgAAAA==.',['辛多']='辛多雷的荣耀:BAAALAAECgEIAQAAAA==.',['这光']='这光棍有毒:BAAALAADCgYIBgAAAA==.',['迪菲']='迪菲亚恶霸:BAABLAAFFH8FAAIEAAMIvQ4YGAA4AAAEAAMIvQ4YGAA4AAAAAA==.',['送教']='送教授:BAABLAAFFH8IAAIDAAIIVwxOgQBFAAADAAIIVwxOgQBFAAAAAA==.',['逍遥']='逍遥之德:BAABLAAFFH8NAAILAAMISxMWLgCzAAALAAMISxMWLgCzAAAAAA==.',['逝去']='逝去的秦春:BAAALAAECgYICgAAAA==.',['邦桑']='邦桑迪:BAABLAAFFH8GAAILAAIIDhQwLwB2AAALAAIIDhQwLwB2AAAAAA==.',['酋长']='酋长派来卧底:BAAALAADCgEIAQAAAA==.',['醉影']='醉影:BAABLAAECn8WAAIHAAYIJBASuQD3AAAHAAYIJBASuQD3AAAAAA==.',['重生']='重生的沉鱼:BAAALAADCgEIAQAAAA==.',['铁槌']='铁槌妹妹丶:BAAALAAECgYICQAAAA==.',['铭牌']='铭牌女子:BAABLAAFFH8FAAIHAAIIFg90jgBGAAAHAAIIFg90jgBGAAAAAA==.',['阿彻']='阿彻鲁斯之刃:BAABLAAFFH8GAAIDAAIIkwXljAB7AAADAAIIkwXljAB7AAAAAA==.',['阿良']='阿良丶:BAAALAAECgQICAAAAA==.',['阿里']='阿里满满:BAAALAAFFAIIBAAAAA==.',['陈平']='陈平安:BAAALAAECgQIBAAAAA==.',['陌上']='陌上默默:BAAALAAECgQIBAAAAA==.',['雷熔']='雷熔:BAAALAADCgYIBgAAAA==.',['雷神']='雷神风暴烈酒:BAAALAAFFAIIAgAAAA==.',['静大']='静大人的猫:BAAALAAECgYIEgAAAA==.',['静宝']='静宝:BAAALAAECgUIBQAAAA==.',['风中']='风中丨墨雪:BAABLAAFFH8GAAIDAAIIchqoVgCdAAADAAIIchqoVgCdAAAAAA==.',['风之']='风之喧嚣:BAAALAAECgYICgAAAA==.',['风影']='风影格:BAAALAADCgEIAQAAAA==.',['风灵']='风灵薇:BAABLAAFFH8IAAMHAAIITxP3ZQCHAAAHAAIITxP3ZQCHAAAVAAEIlhO+NABCAAAAAA==.',['风萤']='风萤:BAAALAADCgMIAwAAAA==.',['飘忽']='飘忽不定:BAAALAAECgYICwAAAA==.',['飘雪']='飘雪清风月朗:BAACLAAFFH8kAAIMAAYInCMgBQAAAgAMAAYInCMgBQAAAgAsAAQKfzQAAgwACAhAJb8CANYCAAwACAhAJb8CANYCAAAA.',['飛翔']='飛翔啲燃燃:BAABLAAFFH8OAAIPAAYIiBTlDwDoAQAPAAYIiBTlDwDoAQAAAA==.',['飞舞']='飞舞的苹果:BAABLAAECn8aAAMCAAgIUA4zJwCEAQACAAgIUA4zJwCEAQAGAAUIBwivYgDpAAAAAA==.',['飞霄']='飞霄:BAAALAAECgYIDAAAAA==.',['首席']='首席烤串儿:BAAALAAECgcICgAAAA==.',['香格']='香格里拉疯:BAAALAAECgUIBQAAAA==.',['马二']='马二饼:BAABLAAFFH8IAAIKAAgIwBIOBQA0AgAKAAgIwBIOBQA0AgAAAA==.',['骑士']='骑士四月六:BAABLAAFFH8QAAMbAAUIeRrvDgCXAQAbAAUIeRrvDgCXAQAKAAQIdxffMAD+AAAAAA==.',['骑桶']='骑桶者卡夫卡:BAAALAAECgYIBgAAAA==.',['高松']='高松灯:BAAALAAECgYIDAAAAA==.',['鬼山']='鬼山莲泉:BAABLAAFFH8JAAIDAAQIcxShVwCnAAADAAQIcxShVwCnAAAAAA==.',['鬼灬']='鬼灬兔:BAAALAAECgEIAQAAAA==.',['魅惑']='魅惑嗳:BAAALAAECgcIBwAAAA==.',['魔瘾']='魔瘾患者:BAAALAADCgEIAQAAAA==.',['鲨鱼']='鲨鱼辢椒丶:BAAALAAECgEIAQAAAA==.',['鲸落']='鲸落:BAAALAAFFAIIAgABLAAFFAUIDgAOAIIcAA==.',['鸢蓝']='鸢蓝:BAABLAAFFH8HAAILAAMIxBEPNACZAAALAAMIxBEPNACZAAAAAA==.',['鹌鹑']='鹌鹑在减肥:BAAALAADCgEIAQAAAA==.',['黑白']='黑白郎君:BAAALAAECgYIDAAAAA==.',['黒碳']='黒碳:BAABLAAFFH8JAAMeAAIIvxCDMwCKAAAeAAIIvxCDMwCKAAAgAAEImQI3MAAvAAAAAA==.',['齐静']='齐静春:BAAALAAECgUIBQAAAA==.',['龍滴']='龍滴传人:BAABLAAFFH8GAAIDAAIICBYgXgCZAAADAAIICBYgXgCZAAAAAA==.',['龙希']='龙希尔瓦纳斯:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end