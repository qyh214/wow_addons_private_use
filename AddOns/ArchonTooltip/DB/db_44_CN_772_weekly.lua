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
 local lookup = {'Monk-Brewmaster','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Frost','Warlock-Destruction','Warlock-Demonology','Warrior-Fury','Shaman-Restoration','DemonHunter-Havoc','Druid-Balance','Mage-Arcane','Shaman-Elemental','Paladin-Retribution','Paladin-Protection','Mage-Frost','Shaman-Enhancement','Monk-Windwalker','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Evoker-Augmentation','Shaman-Any','Priest-Shadow','Monk-Mistweaver','Druid-Guardian','DemonHunter-Vengeance','Warrior-Protection','Druid-Restoration','Paladin-Holy','Druid-Feral','Evoker-Preservation','DeathKnight-Unholy','DeathKnight-Blood',}; local provider = {region='CN',realm='盖斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Aries:BAAALAAECgYIDQAAAA==.',Be='Beanzi:BAAALAAECgUIBQAAAA==.Beatrice:BAAALAAECgEIAQAAAA==.',Bi='Bikini:BAAALAADCggICAAAAA==.',Bl='Blackleather:BAAALAAFFAIIBAAAAA==.',Bu='Burry:BAABLAAFFH8FAAIBAAMIcwzIGgBkAAABAAMIcwzIGgBkAAAAAA==.',Ca='Carolyn:BAAALAADCgUIBQAAAA==.Cassandra:BAACLAAFFH8wAAQCAAcI0B9pHgC4AQACAAcIIR9pHgC4AQADAAUIXxQfDgAKAQAEAAEIbxfSAwBYAAAsAAQKfx8ABAIACAiHJV0lACICAAMABwhAInwgAGMCAAIABwhLJV0lACICAAQAAQhiJv8OAHQAAAAA.',De='Deathcg:BAABLAAFFH8OAAIFAAII/SGwSgClAAAFAAII/SGwSgClAAAAAA==.Deathkbs:BAABLAAFFH8TAAIFAAYI1Bj0KQCPAQAFAAYI1Bj0KQCPAQAAAA==.Deco:BAABLAAFFH8NAAMGAAMIAg6eSwCLAAAGAAMIAg6eSwCLAAAHAAEIpwEsMgAvAAAAAA==.',Do='Doom:BAAALAAECgEIAQAAAA==.',Dr='Driver:BAAALAAFFAIIBAAAAA==.',Fa='Farshore:BAABLAAFFH8PAAIFAAIIxCXYOQC+AAAFAAIIxCXYOQC+AAAAAA==.',Fl='Flyingx:BAAALAAECgYIDQAAAA==.',Hl='Hlkho:BAAALAAECgMIAwAAAA==.',Ke='Keyoo:BAAALAAECgYIBgAAAA==.',Lu='Luciferss:BAAALAAFFAQIBAAAAA==.',Ma='Maii:BAABLAAFFH8FAAIIAAMImhRLGQD8AAAIAAMImhRLGQD8AAAAAA==.Markbs:BAAALAAECgYICQAAAA==.',Mi='Mikec:BAAALAAECgIIAgAAAA==.Milik:BAABLAAFFH8IAAIJAAIIlhmlTwB8AAAJAAIIlhmlTwB8AAAAAA==.',Mo='Mock:BAAALAADCgYICAAAAA==.Mockssi:BAAALAAECgYIBwAAAA==.Mondayone:BAAALAAFFAYIAgAAAA==.',Na='Navzul:BAABLAAFFH8NAAIFAAYIOBYHMQB3AQAFAAYIOBYHMQB3AQABLAAFFAcILQABAJgXAA==.',Pa='Paella:BAAALAAECgUIBgABLAAECgYIFQADAGogAA==.',Pe='Pescado:BAAALAAECgYIBwABLAAECgYIFQADAGogAA==.',Pl='Playeragtgue:BAAALAADCgYIBgAAAA==.',Sh='Shuri:BAAALAAECggIBgAAAA==.',To='Tom:BAAALAAECgUICAAAAA==.',Ty='Tyana:BAAALAAECgYIBgAAAA==.',Tz='Tzeentch:BAAALAAECgYICwAAAA==.',Xy='Xy:BAAALAAECgEIAQAAAA==.',Ya='Yangy:BAAALAAECgUIBwAAAA==.',Yi='Yiyo:BAAALAADCgYIBgAAAA==.',Yr='Yrsgogo:BAAALAAECgYICQAAAA==.',['一夜']='一夜仙:BAAALAAECggICAAAAA==.',['一扁']='一扁一:BAAALAADCgcIBwAAAA==.',['一瞬']='一瞬间丶:BAACLAAFFH8KAAIKAAQI/g1yNgDJAAAKAAQI/g1yNgDJAAAsAAQKfxUAAgoABgiOGtQ4AHcBAAoABgiOGtQ4AHcBAAAA.',['一般']='一般砖:BAAALAADCgMIAwAAAA==.',['三季']='三季稻胖:BAACLAAFFH8KAAILAAMIJhCoKQBoAAALAAMIJhCoKQBoAAAsAAQKfxkAAgsACAhNHvMZAJICAAsACAhNHvMZAJICAAAA.',['三杯']='三杯鸡侠:BAAALAAECggICAAAAA==.',['上课']='上课觉觉:BAAALAAFFAMIBAAAAA==.',['不会']='不会玩奶骑:BAAALAAECgYIBwAAAA==.',['不减']='不减当年:BAABLAAFFH8NAAIMAAIINRoaSgCWAAAMAAIINRoaSgCWAAAAAA==.',['不怕']='不怕冷:BAAALAAECgYIBgAAAA==.',['不會']='不會起名字:BAAALAAECggIEAAAAA==.',['与欲']='与欲娱余生:BAAALAAFFAIIAgAAAA==.',['丛步']='丛步圣光:BAAALAAECgMIAwAAAA==.',['丨妮']='丨妮妮天使丨:BAAALAAECgYIDAAAAA==.',['丨神']='丨神选丨:BAAALAADCgYIBgAAAA==.',['丶你']='丶你丑我瞎:BAAALAAECgUIBQAAAA==.',['丶农']='丶农夫山泉:BAAALAAECgMIAwAAAA==.',['丶忆']='丶忆澜:BAAALAAECgYICQAAAA==.',['丶碎']='丶碎碎念:BAAALAAFFAIIAgAAAA==.',['丶精']='丶精靈復甦:BAAALAAFFAIIAwAAAA==.',['丶隐']='丶隐伤:BAAALAAECgYICQAAAA==.',['二少']='二少爺:BAAALAAECggICQAAAA==.',['二道']='二道贩子:BAAALAAECgUIBQAAAA==.',['于斜']='于斜:BAAALAAECgIIAgAAAA==.',['伊斯']='伊斯佩尔:BAAALAAECgYIBgAAAA==.',['伊芙']='伊芙蕾儿:BAAALAAECgYIBgAAAA==.',['众神']='众神谎言:BAABLAAFFH8IAAIFAAIIoxTwiQBBAAAFAAIIoxTwiQBBAAAAAA==.',['传说']='传说中的三鞭:BAABLAAECn8zAAMNAAgIGBWoHgC5AQANAAgIGBWoHgC5AQAJAAcIhgYX6ADDAAAAAA==.',['伽羅']='伽羅娜:BAAALAAECgQIBwAAAA==.',['你头']='你头像真牛:BAABLAAFFH8GAAICAAIIiBcGhABNAAACAAIIiBcGhABNAAAAAA==.',['你巳']='你巳经:BAAALAADCgEIAQAAAA==.',['傲剑']='傲剑寒霜:BAAALAAECgYIBgAAAA==.',['僧灬']='僧灬住:BAAALAADCgIIAgABLAAFFAgIEgAFAPwbAA==.',['光义']='光义圣君:BAAALAADCgQIBAAAAA==.',['光影']='光影独行:BAAALAAECggICAAAAA==.',['兔兔']='兔兔大魔王丶:BAAALAAFFAIIAgAAAA==.',['其实']='其实我是蛋蛋:BAAALAAECgIIAgAAAA==.',['冥茵']='冥茵:BAAALAAECgYIBgAAAA==.',['冥音']='冥音:BAACLAAFFH8FAAIOAAII7RMzOwCiAAAOAAII7RMzOwCiAAAsAAQKfxgAAg4ACAiAIBI3ALkBAA4ACAiAIBI3ALkBAAAA.',['冬枫']='冬枫:BAABLAAECn8cAAIOAAcIYhSWmQDBAQAOAAcIYhSWmQDBAQAAAA==.',['冰骸']='冰骸邪君:BAABLAAFFH8TAAIFAAQIqg3cUQDRAAAFAAQIqg3cUQDRAAAAAA==.',['冷清']='冷清秋:BAAALAAECgQIBAAAAA==.',['凝眸']='凝眸:BAAALAAFFAIIAgAAAA==.',['凨筝']='凨筝的艺术:BAAALAAECgYIBgAAAA==.',['凶残']='凶残的我:BAABLAAFFH8NAAIIAAYIiRvZBABOAgAIAAYIiRvZBABOAgAAAA==.',['分外']='分外妖嬈:BAAALAAECgUIBQAAAA==.',['利亚']='利亚德林:BAAALAAECgIIAgAAAA==.',['别点']='别点我怕死:BAAALAADCgEIAQAAAA==.',['劈佢']='劈佢:BAAALAAECgYIBgAAAA==.',['功夫']='功夫熊貓俠:BAAALAAECgEIAQAAAA==.',['加特']='加特林菩萨:BAAALAAECgYIDAAAAA==.',['北极']='北极熊先生:BAAALAAECgQIBAAAAA==.',['千娅']='千娅:BAABLAAFFH8GAAICAAYI6wDfwgAWAAACAAYI6wDfwgAWAAAAAA==.',['卡哇']='卡哇伊小车:BAAALAAECgYIDwAAAA==.卡哇伊猎:BAAALAAFFAIIBAAAAA==.',['原来']='原来还有梦丿:BAAALAAECgYIBgAAAA==.',['叁脚']='叁脚:BAAALAAECgYIBgAAAA==.',['只取']='只取一瓢饮:BAAALAAFFAIIAgAAAA==.',['只抽']='只抽红双喜:BAAALAAECgcIBwAAAA==.',['司幽']='司幽:BAAALAADCgYIBgAAAA==.',['司徒']='司徒晓宝:BAAALAADCgEIAQAAAA==.',['名字']='名字不好想啊:BAAALAAECgUIBQAAAA==.',['呀咦']='呀咦呀哦:BAAALAAECggIEAAAAA==.',['命运']='命运守护夜:BAABLAAFFH8LAAIJAAMIxBHcJQC6AAAJAAMIxBHcJQC6AAAAAA==.命运神骑:BAABLAAECn8UAAMPAAYIFhFHIwD3AAAPAAYIFhFHIwD3AAAOAAIIMQjKbQFZAAAAAA==.',['咕咕']='咕咕在哪里:BAAALAADCggICAAAAA==.',['哀川']='哀川和彦:BAABLAAFFH8HAAMQAAMIaQydDgBzAAAQAAMIaQydDgBzAAAMAAEI5QFXbwAAAAAAAA==.',['哆啦']='哆啦滴梦:BAAALAAFFAIIBAAAAA==.',['哦在']='哦在这停顿:BAAALAAECgUIBAAAAA==.',['唐三']='唐三葬:BAABLAAECn8UAAMPAAYIjxApRgAcAQAPAAYIjxApRgAcAQAOAAQIGQhxQwGpAAAAAA==.',['啊八']='啊八级大狂风:BAAALAAECgEIAQAAAA==.',['啊咿']='啊咿呀嘿:BAAALAADCgcIBwAAAA==.',['問天']='問天可敢爲敌:BAAALAAECgYIBgAAAA==.',['嗲宝']='嗲宝贝玲玲:BAAALAAECgQIBQAAAA==.',['噬魂']='噬魂灬啸龙:BAABLAAECn8UAAIRAAgIGxGqBwB4AQARAAgIGxGqBwB4AQAAAA==.',['四分']='四分五猎:BAABLAAFFH8IAAICAAgI7ACoxAANAAACAAgI7ACoxAANAAAAAA==.',['四灬']='四灬灬季:BAAALAADCgIIAgAAAA==.',['圆圆']='圆圆爱鱼儿丶:BAACLAAFFH8IAAISAAIIWw43FQBJAAASAAIIWw43FQBJAAAsAAQKfxUAAhIABgj8Eas3AGIBABIABgj8Eas3AGIBAAAA.',['土灵']='土灵:BAAALAAECgUIBQAAAA==.',['土耳']='土耳其小钢炮:BAAALAAECggICAAAAA==.',['圣光']='圣光会庇护我:BAAALAAECgYIBgABLAAECgYIFQADAGogAA==.圣光搅搅糖:BAAALAADCgEIAQAAAA==.',['圣灬']='圣灬鍅:BAAALAAFFAIIAgAAAA==.',['圣诞']='圣诞节敢死队:BAACLAAFFH8NAAITAAMItRE0FgClAAATAAMItRE0FgClAAAsAAQKfxkAAxMACAjlFtYbADYCABMACAjlFtYbADYCABQAAgiUEDlFAHMAAAAA.',['地狱']='地狱夫人:BAACLAAFFH8aAAIVAAUI1Q9MIgAwAQAVAAUI1Q9MIgAwAQAsAAQKfxkAAhUACAi2GqEQAFECABUACAi2GqEQAFECAAEsAAUUCAgiABYANxgA.',['埃辛']='埃辛诺斯:BAAALAAECgYIDAAAAA==.',['基德']='基德:BAAALAAECgIIBgAAAA==.',['塔兰']='塔兰吉:BAAALAAECgIIAgAAAA==.',['塞克']='塞克熊猫:BAACLAAFFH8dAAIJAAYI/xlSDQBqAQAJAAYI/xlSDQBqAQAsAAQKfx4AAgkACAh+HQciAIsCAAkACAh+HQciAIsCAAAA.',['墨落']='墨落画卷:BAAALAAECgYIBgAAAA==.',['多年']='多年的记忆:BAAALAAECgYIBgAAAA==.',['夜姬']='夜姬:BAAALAAFFAIIBAAAAA==.',['夜灬']='夜灬魅惑:BAAALAAECgYICwAAAA==.',['大三']='大三:BAAALAAECgMIAwAAAA==.',['大山']='大山:BAAALAAECgYIEwAAAA==.',['大调']='大调查避税:BAAALAAECgQIBgAAAA==.',['天丶']='天丶空:BAABLAAFFH8VAAIFAAUIcxaZPwA8AQAFAAUIcxaZPwA8AQAAAA==.',['天南']='天南盖地虎:BAABLAAECn8jAAIKAAYIMBFyUQAnAQAKAAYIMBFyUQAnAQAAAA==.',['天才']='天才小狐:BAAALAADCgMIAwAAAA==.',['天青']='天青色瞪眼鱼:BAAALAAECgQIBAAAAA==.',['奶瓶']='奶瓶:BAAALAADCgIIAgAAAA==.',['好嗨']='好嗨芭比:BAABLAAECn8VAAIMAAcIEAz8NwAvAQAMAAcIEAz8NwAvAQAAAA==.',['好酒']='好酒不溅:BAAALAAECgYIBgAAAA==.',['威严']='威严的大角鹿:BAAALAAECgEIAQAAAA==.',['娅媚']='娅媚蝶:BAAALAAECgYICgAAAA==.',['娟喵']='娟喵喵丶:BAAALAAFFAIIAgAAAA==.',['嫣乄']='嫣乄然:BAAALAAECgUICAAAAA==.',['孙刑']='孙刑者:BAAALAAECgYIDAAAAA==.',['守护']='守护个大怪兽:BAAALAAFFAIIAgAAAA==.',['完美']='完美无瑕战世:BAAALAAECgMIAwAAAA==.',['宫微']='宫微羽:BAABLAAFFH8GAAIXAAYIEA8AAAAAAAAJAAYIEA8AAAAAAAAAAA==.',['宵暗']='宵暗之韵:BAAALAAECgYIBwAAAA==.',['小奈']='小奈家姐:BAABLAAFFH8VAAMYAAMImxdPGgChAAAYAAMImxdPGgChAAAVAAII1BzyJwCaAAAAAA==.',['小柰']='小柰家姐:BAABLAAFFH8MAAIDAAIIwAwYJwB6AAADAAIIwAwYJwB6AAAAAA==.',['小漓']='小漓:BAABLAAFFH8kAAIVAAcIfhjICgAcAgAVAAcIfhjICgAcAgAAAA==.',['小点']='小点心:BAAALAAFFAIIBAAAAA==.',['小白']='小白入坑:BAAALAAECgYIBwAAAA==.',['小萝']='小萝卜:BAAALAAFFAIIAQAAAA==.',['小风']='小风:BAABLAAFFH8HAAIGAAIISgxmUACAAAAGAAIISgxmUACAAAAAAA==.',['尤红']='尤红:BAAALAAECgYICwAAAA==.',['就是']='就是为了萌:BAABLAAFFH8LAAIBAAQIRgW/GACKAAABAAQIRgW/GACKAAAAAA==.',['尽天']='尽天下:BAAALAADCgYIBgAAAA==.',['山野']='山野牧笛:BAAALAADCgQIBAAAAA==.',['岸然']='岸然辉煌:BAAALAAECgYIBgAAAA==.',['左手']='左手倒影:BAAALAADCgIIAgAAAA==.',['巴布']='巴布罗:BAABLAAFFH8FAAIIAAIIAgtFXgA3AAAIAAIIAgtFXgA3AAAAAA==.',['布鲁']='布鲁可:BAAALAAECgQIBAAAAA==.',['帅捷']='帅捷:BAAALAAECgYIDAAAAA==.',['帆崽']='帆崽再回归:BAAALAAECgMIAwAAAA==.',['希女']='希女王的舔狗:BAAALAAECgYIBwAAAA==.',['希爾']='希爾瓦納斯:BAAALAAECgIIAwAAAA==.',['幻梦']='幻梦似泪:BAAALAAECgYIEQAAAA==.',['幽幽']='幽幽黎歌:BAAALAADCggICAAAAA==.',['强力']='强力无敌:BAABLAAFFH8FAAIMAAUI2gLCHQBJAQAMAAUI2gLCHQBJAQAAAA==.强力男:BAAALAAECgMIAwAAAA==.',['当时']='当时明月在:BAAALAAECgYICwAAAA==.',['很好']='很好吃:BAAALAAECgYIBgAAAA==.',['很美']='很美味:BAAALAAECgEIAQAAAA==.',['德闲']='德闲博野:BAAALAAECgQIBAAAAA==.',['德鲁']='德鲁大叔:BAAALAAFFAMIAwAAAA==.',['忲怮']='忲怮稚:BAAALAAECgUIBQAAAA==.',['怕鬼']='怕鬼:BAAALAAFFAIIBAAAAA==.',['悲剧']='悲剧战:BAABLAAFFH8GAAIIAAYINSDqEADRAQAIAAYINSDqEADRAQAAAA==.',['想踹']='想踹人:BAAALAAECgMIAwAAAA==.',['愛羅']='愛羅丶星矢:BAAALAAFFAIIAgAAAA==.',['愤怒']='愤怒的机关枪:BAAALAAECgUIBQAAAA==.',['慕思']='慕思风华:BAABLAAFFH8NAAIVAAUIcQV3JgADAQAVAAUIcQV3JgADAQAAAA==.',['我不']='我不会加血:BAABLAAFFH8GAAIJAAIIwAmGagBQAAAJAAIIwAmGagBQAAAAAA==.我不美吗:BAABLAAFFH8MAAIYAAMI9hLrEQD3AAAYAAMI9hLrEQD3AAAAAA==.',['我想']='我想玩亚索:BAAALAAFFAIIBAAAAA==.我想要个名:BAAALAAECgYIBgAAAA==.',['我是']='我是爱哭鬼:BAAALAAECggICwABLAAFFAgIBQAGAIQIAA==.',['我选']='我选择死亡:BAABLAAFFH8IAAMQAAII/xpxDAChAAAQAAII/xpxDAChAAAMAAEIuA38awBDAAAAAA==.',['我頭']='我頭上有犄角:BAABLAAFFH8IAAIKAAIIrBYHSwCRAAAKAAIIrBYHSwCRAAAAAA==.',['或昱']='或昱或愚:BAABLAAFFH8rAAMDAAcI9iByBACaAQADAAYITx1yBACaAQACAAQInCCvKQCNAQAAAA==.',['手术']='手术的术:BAAALAADCgIIAgAAAA==.',['扭抹']='扭抹亡:BAAALAAFFAEIAQAAAA==.',['抓不']='抓不住:BAABLAAFFH8IAAICAAIIKCEZfwBYAAACAAIIKCEZfwBYAAAAAA==.',['抓咕']='抓咕大队长:BAAALAADCgUICAAAAA==.',['拯救']='拯救自己:BAAALAAECgYIBgAAAA==.',['拾贰']='拾贰巴:BAABLAAFFH8FAAIMAAMI1RCMQwCVAAAMAAMI1RCMQwCVAAAAAA==.',['提钱']='提钱退休:BAAALAAECggIEQAAAA==.',['擘开']='擘开大髀晒夹:BAAALAAECgYIBgAAAA==.',['放开']='放开那个萌叔:BAAALAAECgMIAwAAAA==.',['放飞']='放飞的梦:BAAALAADCgUIBwAAAA==.',['敢杀']='敢杀丨恶灵骑:BAAALAAFFAIIAQABLAAFFAgIDAAFANsdAA==.',['无影']='无影:BAAALAADCgcIBwAAAA==.',['无灬']='无灬花果:BAAALAAFFAUIAgABLAAFFAgIIQAZAFYbAA==.',['无颜']='无颜色的天空:BAABLAAFFH8FAAIaAAMImRAtCABkAAAaAAMImRAtCABkAAAAAA==.',['明天']='明天吃牛排:BAAALAAECgUIBQAAAA==.',['明爱']='明爱雨:BAAALAAECgMIAwAAAA==.',['星丶']='星丶白:BAAALAAECgYIDwAAAA==.',['星灬']='星灬矢:BAAALAAECgQIBwAAAA==.',['星际']='星际漫游:BAAALAAECgEIAQAAAA==.',['春丶']='春丶:BAAALAADCgIIAgAAAA==.',['春心']='春心一荡漾:BAABLAAFFH8IAAIGAAMI6xIOKADsAAAGAAMI6xIOKADsAAAAAA==.',['是东']='是东山啊:BAAALAAECgYIBgAAAA==.',['暴仔']='暴仔丨:BAAALAAFFAIIAgAAAA==.',['暴打']='暴打小姨妹:BAAALAAECgYIBgAAAA==.',['有罪']='有罪滴少爷:BAABLAAFFH8FAAICAAMIFhmwIgD3AAACAAMIFhmwIgD3AAAAAA==.',['有间']='有间客栈:BAAALAAECgQIBQAAAA==.',['杀务']='杀务尽:BAABLAAECn8YAAIbAAYI7BZgEQA2AQAbAAYI7BZgEQA2AQAAAA==.',['杀式']='杀式殇:BAAALAADCgIIAgAAAA==.',['极乐']='极乐净土:BAABLAAFFH8HAAIcAAIITxKXHgCBAAAcAAIITxKXHgCBAAAAAA==.',['枫林']='枫林星语:BAAALAAECgYICwAAAA==.',['柠檬']='柠檬忆灬:BAAALAAECgIIAgAAAA==.',['树师']='树师:BAAALAAECggICAAAAA==.',['栓牛']='栓牛:BAAALAAECgYIBgAAAA==.',['梦成']='梦成:BAAALAAECgYIDAAAAA==.',['梦醒']='梦醒之殇:BAAALAADCgEIAQAAAA==.',['棒棒']='棒棒冰:BAAALAAFFAIIAgAAAA==.',['欢喜']='欢喜我仲要:BAAALAAECgYIBwAAAA==.',['欲望']='欲望天使:BAAALAAFFAgIAQAAAA==.',['欲语']='欲语还休:BAABLAAFFH8IAAIdAAMIMQbOPQB5AAAdAAMIMQbOPQB5AAAAAA==.',['正正']='正正玲玲:BAAALAADCggICAAAAA==.',['殇丨']='殇丨灬優:BAABLAAFFH8GAAIPAAIIKhfIGgA1AAAPAAIIKhfIGgA1AAAAAA==.',['水星']='水星养德:BAAALAADCgIIAgAAAA==.',['水水']='水水猎:BAABLAAECn8VAAIDAAYIaiDnKgAiAgADAAYIaiDnKgAiAgAAAA==.',['沙滩']='沙滩之子:BAACLAAFFH8aAAIFAAYI2RFbNABqAQAFAAYI2RFbNABqAQAsAAQKfyQAAgUACAhiHfRIAGkCAAUACAhiHfRIAGkCAAAA.沙滩阳光:BAABLAAFFH8RAAIFAAUI1A5wRgAgAQAFAAUI1A5wRgAgAQAAAA==.',['浮生']='浮生若梦:BAAALAADCgYIDAAAAA==.',['涂抹']='涂抹心情:BAACLAAFFH8IAAIFAAII4BB+gQBFAAAFAAII4BB+gQBFAAAsAAQKfx0AAgUABggyHfuCAPUBAAUABggyHfuCAPUBAAAA.',['深渊']='深渊之刺丶:BAABLAAFFH8OAAIFAAUIWQcoTQD1AAAFAAUIWQcoTQD1AAAAAA==.',['清一']='清一色自摸:BAAALAAFFAIIBAAAAA==.',['清歌']='清歌酌酒:BAAALAAECgEIAQAAAA==.',['温柔']='温柔的脸型:BAAALAAECgYIBgAAAA==.',['漆黑']='漆黑:BAAALAAECgEIAQAAAA==.',['灬丨']='灬丨天机丨灬:BAABLAAFFH8KAAIJAAII2Rw2NACYAAAJAAII2Rw2NACYAAAAAA==.灬丨妖姬丨灬:BAAALAAECgYIBgAAAA==.灬丨血医丨灬:BAAALAAFFAIIAgAAAA==.',['灬暖']='灬暖肉肉:BAAALAADCgEIAQAAAA==.',['灬無']='灬無丶趣:BAAALAAECgYIDQAAAA==.',['灵车']='灵车在漂移:BAAALAADCgIIAgAAAA==.',['烟花']='烟花的葬礼:BAAALAAECgYIBwAAAA==.',['無影']='無影:BAABLAAFFH8HAAIOAAQIEA6pOAC8AAAOAAQIEA6pOAC8AAAAAA==.',['焦面']='焦面包:BAAALAAECgYIDAAAAA==.',['爱吃']='爱吃糖的牛牛:BAAALAAECgcIBwAAAA==.',['爱情']='爱情火箭蛋:BAAALAADCggICAAAAA==.',['牙齿']='牙齿有点大:BAABLAAFFH8GAAICAAIIUAbXsgA1AAACAAIIUAbXsgA1AAAAAA==.',['牛角']='牛角面包:BAAALAAECgYIDAABLAAECgYIFQADAGogAA==.',['狂拽']='狂拽吊霸天:BAAALAADCgYIBgAAAA==.',['狂暴']='狂暴的蛮牛:BAAALAADCgcICAAAAA==.',['王得']='王得好:BAAALAADCggICAAAAA==.',['珑玥']='珑玥:BAAALAAFFAIIBAAAAA==.',['珠宝']='珠宝大亨:BAAALAAECgMIAwAAAA==.',['理查']='理查德钛砷:BAABLAAFFH8QAAICAAUIsxaNRgAwAQACAAUIsxaNRgAwAQAAAA==.',['瑞文']='瑞文她奶奶:BAAALAADCggICAAAAA==.',['璀璨']='璀璨中的凋零:BAAALAAECgUIBQAAAA==.',['甘乃']='甘乃迪:BAAALAAFFAIIAgAAAA==.',['电弧']='电弧音:BAAALAAFFAIIAgAAAA==.',['男闺']='男闺蜜丶黄忠:BAAALAAECgYIBgAAAA==.',['留钱']='留钱玩:BAAALAAECgMIAwAAAA==.',['白日']='白日游魂:BAABLAAFFH8MAAIOAAUIYQtpLwALAQAOAAUIYQtpLwALAQAAAA==.',['白曰']='白曰游魂:BAABLAAFFH8PAAIKAAUIuAv3MAAMAQAKAAUIuAv3MAAMAQAAAA==.',['白梦']='白梦咖啡:BAABLAAFFH8IAAIHAAIIuRIlGACTAAAHAAIIuRIlGACTAAAAAA==.',['盖了']='盖了:BAABLAAFFH8KAAIeAAIIwwZNIwB+AAAeAAIIwwZNIwB+AAAAAA==.',['瞄准']='瞄准菊花:BAAALAAECgYIDQAAAA==.',['短腿']='短腿地板流:BAAALAAFFAIIBAAAAA==.',['砖头']='砖头一殇一:BAABLAAFFH8GAAMLAAYI3BEeGwD8AAALAAUIYRAeGwD8AAAdAAEIrBB1WQA9AAAAAA==.',['碎星']='碎星拉塔恩:BAAALAAECgYIBwAAAA==.',['神罗']='神罗天征:BAAALAAECgYIBwAAAA==.',['神诺']='神诺:BAAALAAFFAIIAwAAAA==.',['禾禾']='禾禾的老霸:BAAALAAECgUIBgAAAA==.',['章鱼']='章鱼小丸子:BAABLAAFFH8cAAIFAAcIvhjdEQD/AQAFAAcIvhjdEQD/AQAAAA==.',['竹灬']='竹灬酒:BAAALAAECgYICQAAAA==.',['红手']='红手丶玛麦毗:BAAALAAECgMIAwAAAA==.红手迪凯帝:BAAALAAECgMIBAAAAA==.',['红装']='红装素裹:BAAALAAECgQIBAAAAA==.',['红颜']='红颜易老:BAABLAAFFH8GAAIFAAIIswjThACDAAAFAAIIswjThACDAAAAAA==.',['纯召']='纯召死灵法:BAABLAAFFH8GAAIFAAIIDQ3WbwCQAAAFAAIIDQ3WbwCQAAAAAA==.',['纳垢']='纳垢:BAAALAAFFAIIBAAAAA==.',['绝恋']='绝恋丶星矢:BAAALAADCgYIBgAAAA==.',['绝无']='绝无眠:BAAALAADCggICAAAAA==.',['缥缈']='缥缈:BAABLAAFFH8IAAIHAAIIBR65DABaAAAHAAIIBR65DABaAAAAAA==.',['网瘾']='网瘾老嘢:BAAALAAECgcICwAAAA==.',['老渔']='老渔民:BAAALAAECgYIBgAAAA==.',['耶也']='耶也野夜:BAAALAAECgYIDwAAAA==.',['肝姐']='肝姐姐:BAAALAAECgUIBQAAAA==.',['肾胱']='肾胱使者:BAAALAAECgQIBQAAAA==.',['胸爆']='胸爆:BAAALAAECgYIBgAAAA==.',['致胜']='致胜小榔头:BAAALAAFFAIIAgAAAA==.',['舒心']='舒心安然:BAAALAAFFAEIAQAAAA==.',['若水']='若水纷飞:BAABLAAFFH8LAAIQAAII3B7ICgCsAAAQAAII3B7ICgCsAAAAAA==.',['茄子']='茄子盖饭:BAAALAADCgUIBQAAAA==.',['草履']='草履虫:BAABLAAECn8YAAIFAAgIGCXSCwBHAwAFAAgIGCXSCwBHAwAAAA==.',['药不']='药不奇:BAABLAAFFH8GAAIMAAIIBRI/TgCSAAAMAAIIBRI/TgCSAAAAAA==.',['荷马']='荷马先生丶:BAAALAAECgIIAgAAAA==.',['莫妮']='莫妮咖:BAABLAAECn8YAAIfAAYIYB4tFAAWAgAfAAYIYB4tFAAWAgAAAA==.',['莫高']='莫高雷毒奶:BAAALAAFFAIIAgAAAA==.',['萌牛']='萌牛猛妞:BAAALAAECgIIAgAAAA==.',['萌翻']='萌翻你:BAAALAADCggICAAAAA==.',['萌萌']='萌萌嗒:BAAALAAECgQIBAAAAA==.',['萨一']='萨一下满了:BAAALAAECgYIEgABLAAECgYIFQADAGogAA==.',['落发']='落发为僧:BAAALAAECgcIBwAAAA==.',['蒙古']='蒙古海军上将:BAAALAAECgQIBAAAAA==.',['薄荷']='薄荷糖冰冰凉:BAAALAAFFAIIAwAAAA==.',['血剑']='血剑染江山:BAAALAAECggICAAAAA==.',['裤儿']='裤儿提拉丝:BAAALAAECgYIDwAAAA==.',['角落']='角落的摄像机:BAAALAAECgYIDAAAAA==.',['诛八']='诛八界:BAAALAAFFAIIBAAAAA==.',['话梅']='话梅糖石头人:BAAALAADCgcIBwAAAA==.',['请叫']='请叫我哒叔:BAAALAAECgEIAQAAAA==.请叫我奶僧:BAAALAAECgYIDAAAAA==.',['谈笑']='谈笑有紅乳:BAAALAAECgYICAAAAA==.',['豆芽']='豆芽芽:BAAALAAECgYIBgAAAA==.',['貌似']='貌似很妖精:BAAALAAECgMIAwAAAA==.',['贝贝']='贝贝加鲁鲁:BAAALAAECgEIAQAAAA==.',['贪睡']='贪睡的恶魔:BAAALAAECgYIBgAAAA==.',['贫僧']='贫僧法号戒空:BAAALAAECgUICQAAAA==.',['贰拾']='贰拾巴:BAACLAAFFH8HAAIgAAMIIBryEgDkAAAgAAMIIBryEgDkAAAsAAQKfyAAAyAABggxHtwLAKkBACAABggxHtwLAKkBABYABggNCmQSABQBAAAA.贰拾贰:BAABLAAFFH8GAAIJAAII8BZbVQBwAAAJAAII8BZbVQBwAAAAAA==.',['费伦']='费伦事安奴:BAAALAAECgYICQAAAA==.',['赵丽']='赵丽颖:BAAALAADCgMIAwAAAA==.',['超级']='超级变變变:BAAALAAECgYICQAAAA==.',['路里']='路里:BAAALAAECgYIBgAAAA==.',['辣子']='辣子佷厉害:BAAALAADCgQIBAAAAA==.',['辰丶']='辰丶萨菲罗斯:BAABLAAFFH8UAAQhAAYIChN1AwCSAQAhAAYIChN1AwCSAQAFAAQIPwaxSwAAAQAiAAYIJgPaEADhAAAAAA==.',['进桥']='进桥里:BAAALAAECgIIAgAAAA==.',['逐风']='逐风者出右脸:BAABLAAFFH8GAAIOAAYI9hNEGwCBAQAOAAYI9hNEGwCBAQAAAA==.',['逸风']='逸风栈:BAAALAAFFAIIBAAAAA==.',['遗矢']='遗矢的丶美:BAAALAAECgYIBgAAAA==.',['遵义']='遵义染牦蛋:BAAALAADCgEIAQAAAA==.',['那么']='那么简单:BAAALAAECgQICAAAAA==.',['酷酷']='酷酷的小虎牙:BAAALAAECgMIAwAAAA==.',['重生']='重生十字章:BAAALAAECgEIAQAAAA==.',['野性']='野性艾露思:BAABLAAFFH8YAAMaAAYINhdfAgB1AQAaAAYINhdfAgB1AQAdAAMIoxDDLQC1AAAAAA==.',['鎏魔']='鎏魔王:BAAALAADCgEIAQAAAA==.',['锤锤']='锤锤威武:BAAALAAECgYIBgAAAA==.',['锦衣']='锦衣夜行:BAAALAADCgEIAQAAAA==.',['闯子']='闯子:BAAALAAECggICAAAAA==.闯子变了:BAAALAAECgUIBgAAAA==.',['阿宝']='阿宝的哥哥:BAAALAAECgEIAQAAAA==.',['阿寶']='阿寶的哥哥:BAAALAAECgYICgAAAA==.',['阿来']='阿来老湿:BAAALAAECgMIAwAAAA==.',['陳丶']='陳丶喬恩:BAAALAAECgYIBgAAAA==.',['陵陵']='陵陵:BAAALAADCggICAAAAA==.',['霍去']='霍去病丶:BAAALAAFFAYIAgAAAA==.',['霜风']='霜风:BAAALAADCgIIAgAAAA==.',['霹雳']='霹雳哈哈:BAAALAADCgYIDAAAAA==.',['静流']='静流:BAAALAADCgIIAgAAAA==.',['非言']='非言非:BAAALAAECgQIBAAAAA==.',['风骚']='风骚丫麦呆:BAAALAAFFAIIBAAAAA==.',['飞机']='飞机丿舒克:BAAALAADCgIIAgAAAA==.',['鬼术']='鬼术妖姬:BAABLAAFFH8KAAMHAAIIgRHuFQA/AAAGAAIIHAwbXwBAAAAHAAIInhDuFQA/AAAAAA==.',['鲨鱼']='鲨鱼爆打:BAABLAAFFH8bAAIIAAUIuiHXGwCIAQAIAAUIuiHXGwCIAQAAAA==.',['鹿大']='鹿大力丶:BAABLAAFFH8GAAICAAYIqQLtdgBwAAACAAYIqQLtdgBwAAAAAA==.',['黑凤']='黑凤:BAABLAAFFH8RAAMJAAUIHBa0IQBPAQAJAAUIHBa0IQBPAQANAAEIKQQRTQA5AAAAAA==.',['黑夜']='黑夜逐风:BAAALAAECgYIBwAAAA==.',['黑暗']='黑暗守护咕咕:BAAALAAECgQIBAAAAA==.',['黑牛']='黑牛贝贝:BAAALAAECgMIAwAAAA==.',['黑球']='黑球:BAAALAAECgYIEQAAAA==.',['黑色']='黑色十九:BAAALAAECgMIAwAAAA==.黑色衣服:BAABLAAFFH8HAAIOAAUIvg+ALAAgAQAOAAUIvg+ALAAgAQAAAA==.',['黑黑']='黑黑煞:BAAALAAECgcIEAAAAA==.',['黑黯']='黑黯中的獨影:BAABLAAFFH8SAAIIAAUIbxEsJwA2AQAIAAUIbxEsJwA2AQAAAA==.',['龍戰']='龍戰丶星矢:BAAALAAECgYICQAAAA==.',['龙晶']='龙晶:BAAALAAFFAIIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end