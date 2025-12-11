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
 local lookup = {'Mage-Arcane','Paladin-Retribution','Mage-Frost','Priest-Discipline','Warrior-Fury','Monk-Brewmaster','Warlock-Demonology','Warlock-Destruction','Evoker-Preservation','Rogue-Assassination','Rogue-Subtlety','Druid-Guardian','Druid-Balance','Hunter-BeastMastery','DemonHunter-Havoc','DeathKnight-Frost','Hunter-Marksmanship','DeathKnight-Blood','DeathKnight-Unholy','DemonHunter-Vengeance','Druid-Restoration','Warrior-Arms','Shaman-Restoration','Paladin-Protection','Rogue-Outlaw','Warrior-Protection','Shaman-Elemental','Mage-Fire','Unknown-Unknown','Paladin-Holy','Hunter-Survival','Priest-Holy','Monk-Mistweaver','Monk-Windwalker','Evoker-Devastation','Warlock-Affliction','Druid-Feral',}; local provider = {region='CN',realm='黑暗魅影',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ai='Aigle:BAAALAAECgEIAQAAAA==.',Al='Allen:BAABLAAFFH8FAAIBAAMI6AjZTQBaAAABAAMI6AjZTQBaAAAAAA==.',Ar='Arthasg:BAABLAAFFH8MAAICAAYIIBaqGACWAQACAAYIIBaqGACWAQAAAA==.',Au='Aurora:BAAALAAFFAIIAgAAAA==.',Bi='Biggie:BAAALAAECggICAAAAA==.',Bo='Boompilipala:BAAALAADCgYIBgAAAA==.',Bu='Buddhist:BAAALAAECgYIBgAAAA==.Bumblejun:BAABLAAFFH8FAAIDAAMIbgW8GAA/AAADAAMIbgW8GAA/AAAAAA==.',Co='Coralgay:BAABLAAFFH8NAAIEAAQISw5wAgDSAAAEAAQISw5wAgDSAAAAAA==.Coralmilk:BAAALAAFFAIIAgAAAA==.Coralover:BAABLAAFFH8PAAICAAIIhiKCMwCoAAACAAIIhiKCMwCoAAABLAAFFAIIEAAFAHkfAA==.Coralsea:BAAALAAECgYIDAAAAA==.',Fa='Fallansky:BAAALAAECgYICQAAAA==.',Ha='Harrykian:BAAALAAECgcIDgAAAA==.',Ho='Howe:BAABLAAFFH8IAAIFAAYIMw8GHwB4AQAFAAYIMw8GHwB4AQAAAA==.',Ja='Jasonwswswws:BAAALAAECggICAABLAAFFAgIBwAGAOkaAA==.',Ke='Keytodeath:BAABLAAFFH8HAAMHAAUI4AmmBgDJAAAHAAQIOwumBgDJAAAIAAIIdwUBXQBDAAAAAA==.',Lo='Locoloco:BAABLAAECn8UAAIIAAgI4wzzcACkAQAIAAgI4wzzcACkAQAAAA==.',Lu='Lulin:BAAALAAECgYIBgAAAA==.',Ma='Magiccape:BAAALAAECgUICAABLAAFFAMICQAIAGUfAA==.',Me='Messi:BAAALAADCggICAAAAA==.',Mi='Mingevoaa:BAABLAAFFH8GAAIJAAYIsyMfBQBJAgAJAAYIsyMfBQBJAgAAAA==.',Ni='Nicorobin:BAAALAAFFAIIAgAAAA==.',No='Nothing:BAACLAAFFH8gAAIKAAYIPwujDABLAQAKAAYIPwujDABLAQAsAAQKfzQAAwoACAhKGqcUAHYCAAoACAhKGqcUAHYCAAsABggwDGkxABUBAAAA.',Pl='Playeraquzbk:BAAALAAECgQIBAAAAA==.Playersqvtyh:BAABLAAFFH8IAAMMAAgIgAJuDgArAAAMAAEIJg1uDgArAAANAAcI+gDXQQAdAAAAAA==.',Re='Renegade:BAAALAADCgMIAwAAAA==.',Ro='Roxrelive:BAAALAAFFAEIAQAAAA==.Royals:BAABLAAFFH8GAAIOAAYISAswVwD7AAAOAAYISAswVwD7AAAAAA==.',Sa='Saber:BAAALAAECgUIDAAAAA==.',Te='Tellulu:BAAALAADCgYIBgAAAA==.',Th='Thea:BAAALAAECgQIBAAAAA==.',Wi='Wintness:BAAALAAECgIIAgAAAA==.',Zy='Zywoo:BAAALAAECgYIDwAAAA==.',['一个']='一个叫木头:BAABLAAFFH8GAAIPAAII7RFgPgCaAAAPAAII7RFgPgCaAAAAAA==.一个小机灵:BAAALAADCgMIAwAAAA==.',['一刀']='一刀入魂:BAAALAAECgYICwAAAA==.',['一卡']='一卡卡瓦夏一:BAAALAAECgQIBAAAAA==.',['一柱']='一柱清烟:BAABLAAFFH8FAAIOAAUIxgXcXgDTAAAOAAUIxgXcXgDTAAAAAA==.',['一爱']='一爱情一:BAAALAAECgUIBwAAAA==.',['一碰']='一碰就散架:BAAALAAECgYIEQAAAA==.',['一里']='一里蛋丶怒风:BAAALAADCgMIAwAAAA==.',['七月']='七月茉莉:BAAALAAECgUIBQAAAA==.',['万叶']='万叶:BAAALAAECgYIEgAAAA==.',['三两']='三两三:BAAALAADCgUIBQAAAA==.',['不信']='不信邪神:BAAALAAECgUIBQAAAA==.',['不安']='不安丶:BAABLAAFFH8HAAIQAAYILQgePQBNAQAQAAYILQgePQBNAQAAAA==.',['不小']='不小心长丑了:BAAALAAECgMIBAAAAA==.',['不爱']='不爱吃鱼的猫:BAAALAAECgYIBgAAAA==.',['东多']='东多鲁玛:BAABLAAECn8fAAMOAAYIOyFcVwAuAgAOAAYIOyFcVwAuAgARAAYISRQ+VABmAQAAAA==.',['东方']='东方姑娘丶:BAAALAAFFAIIAgAAAA==.',['东来']='东来风林:BAAALAAECgEIAQAAAA==.',['东海']='东海帝皇:BAACLAAFFH8LAAIQAAUIrh6PNADLAAAQAAUIrh6PNADLAAAsAAQKfyEABBAABwh0I8NKAGUCABAABwg2I8NKAGUCABIABggIHCcgAIkBABMAAwiIINk7APsAAAEsAAUUCAgvAA4A9B0A.',['丨丶']='丨丶忧郁:BAAALAAFFAMIFQAAAQ==.',['丨卩']='丨卩:BAAALAAECgYIDgAAAA==.',['丨聖']='丨聖光無用丨:BAABLAAFFH8SAAIQAAUIdgshTQACAQAQAAUIdgshTQACAQAAAA==.',['丨艾']='丨艾伦丨:BAABLAAFFH8GAAIUAAMI9wRkEgA9AAAUAAMI9wRkEgA9AAAAAA==.',['丨蜻']='丨蜻蜓队长:BAAALAAECgYICAAAAA==.',['中江']='中江江:BAABLAAFFH8MAAIVAAIIKBfgPQB8AAAVAAIIKBfgPQB8AAAAAA==.',['丶沉']='丶沉鱼落雁:BAAALAAECgMIAwAAAA==.',['丶若']='丶若小离:BAAALAAECgcIBwAAAA==.',['丷好']='丷好氣丫丷:BAABLAAFFH8FAAIPAAUIrgRaNADxAAAPAAUIrgRaNADxAAAAAA==.丷好氣呀丷:BAABLAAFFH8IAAMDAAIIRRG1EQCLAAADAAIIRRG1EQCLAAABAAIIZARWZQBoAAAAAA==.',['为为']='为为同学:BAABLAAECn8fAAMFAAYIqxjAPwBeAQAFAAYIqxjAPwBeAQAWAAQIvQh4KgCjAAAAAA==.',['为了']='为了联盟:BAABLAAFFH8GAAIIAAIIYht3NACoAAAIAAIIYht3NACoAAAAAA==.为了部落:BAAALAAFFAEIAQAAAA==.',['主教']='主教的救赎:BAABLAAFFH8WAAIXAAYIvAhAKwATAQAXAAYIvAhAKwATAQAAAA==.',['乱舞']='乱舞死神:BAAALAAECgYICAAAAA==.',['予你']='予你双重防护:BAACLAAFFH8bAAIYAAYIKhn+BgBiAQAYAAYIKhn+BgBiAQAsAAQKfxQAAhgABgilGssTAIIBABgABgilGssTAIIBAAAA.',['二狗']='二狗你先冲:BAAALAAECgUIBQAAAA==.',['五日']='五日市芽依:BAAALAAECggICAAAAA==.',['人间']='人间微光:BAAALAAECggICQAAAA==.',['亿万']='亿万少女的梦:BAAALAAECgEIAQAAAA==.',['以一']='以一贯之:BAABLAAFFH8GAAMZAAII3RZvBACcAAAKAAIIyRZeFgClAAAZAAII2hZvBACcAAAAAA==.',['以壹']='以壹贯之:BAAALAAECgEIAQAAAA==.',['伊瑟']='伊瑟尔丶:BAABLAAECn8UAAIKAAYIxRbuLgC0AQAKAAYIxRbuLgC0AQAAAA==.',['休闲']='休闲的馒头:BAABLAAFFH8PAAIXAAIIUBcSTQCEAAAXAAIIUBcSTQCEAAAAAA==.',['伴缘']='伴缘:BAACLAAFFH8JAAIFAAIIxR+tLwCfAAAFAAIIxR+tLwCfAAAsAAQKfyQAAgUABwjRIjgSAFcCAAUABwjRIjgSAFcCAAAA.',['你我']='你我的星辰:BAAALAADCgEIAQAAAA==.',['你还']='你还得谢谢我:BAABLAAFFH8rAAIaAAUIgxKeEgC6AAAaAAUIgxKeEgC6AAAAAA==.',['修女']='修女也疯狂:BAAALAAECgIIAgAAAA==.',['借光']='借光:BAAALAADCgEIAQAAAA==.',['偏放']='偏放不下你:BAAALAAECgYIBgAAAA==.',['做咩']='做咩:BAAALAAECgEIAQAAAA==.',['克苏']='克苏恩:BAABLAAFFH8LAAMDAAUIoxA3DgCXAAABAAUI2gw7NwAcAQADAAIIoxs3DgCXAAAAAA==.',['八神']='八神去一:BAACLAAFFH8xAAMQAAUIIhizKAD2AAAQAAUIIhizKAD2AAATAAIIXBSHEQCTAAAsAAQKfxIAAxMACAiuHCUTADECABMACAilFyUTADECABAABgjUHSM8AJABAAAA.',['冥界']='冥界小牛:BAAALAAFFAQIBAAAAA==.',['冰释']='冰释雨飘洋:BAAALAAECgcIBwAAAA==.',['冷库']='冷库二世:BAAALAAECgEIAQAAAA==.',['凤凰']='凤凰天使:BAAALAAECgYIBgAAAA==.',['凤舞']='凤舞丨轩儿:BAAALAAECgMIAwAAAA==.',['凸绝']='凸绝恋乄萨凸:BAACLAAFFH8VAAMbAAUIBgyYKAAIAQAbAAUIBgyYKAAIAQAXAAIIfh/hPQCwAAAsAAQKfy4AAxcACAgOGngrALwBABcABgjGHXgrALwBABsACAgqDpZXALEBAAAA.',['刀圣']='刀圣丶断天:BAABLAAFFH8GAAIFAAIIqgopQwCIAAAFAAIIqgopQwCIAAAAAA==.',['刀把']='刀把子:BAAALAAECgYIDAAAAA==.',['别怕']='别怕我在:BAAALAAECgMIAwAAAA==.',['剩骑']='剩骑士:BAAALAAECgYIDQAAAA==.',['加勒']='加勒比海带:BAAALAAECgYIDQAAAA==.',['午安']='午安丶:BAABLAAFFH8IAAIQAAYIown6OQBbAQAQAAYIown6OQBbAQAAAA==.',['半根']='半根烟丶:BAABLAAFFH8GAAIQAAYImwqLQAA/AQAQAAYImwqLQAA/AQAAAA==.',['卡布']='卡布奇诺灬:BAACLAAFFH8tAAQBAAcIqx6IEwDJAQABAAYIyyCIEwDJAQAcAAEI6hHMCwBJAAADAAIIjgkQFgBEAAAsAAQKfyIAAwEACAi3IvkfAM8CAAEACAhXIvkfAM8CAAMABAiiGh9aAA0BAAAA.',['卡比']='卡比兽:BAABLAAFFH8WAAIQAAYISxYaLQCKAQAQAAYISxYaLQCKAQAAAA==.',['卧槽']='卧槽八个九:BAAALAAECgIIAgABLAAECgYIBgAdAAAAAA==.',['压迫']='压迫众生:BAAALAAFFAIIBAAAAA==.',['厚德']='厚德在无:BAAALAAECgYIBwAAAA==.',['原神']='原神大王周张:BAAALAAECgMIAwAAAA==.',['双刃']='双刃之影:BAAALAADCgIIAgAAAA==.',['只会']='只会寒冰箭:BAAALAAECggIBgAAAA==.',['只爱']='只爱玩奶德:BAABLAAFFH8JAAIXAAUIswkNNQDWAAAXAAUIswkNNQDWAAAAAA==.',['可乐']='可乐加点冰灬:BAABLAAECn8WAAMUAAcI0BKqKABxAQAUAAYIkRSqKABxAQAPAAcIsQsZuABlAQAAAA==.可乐小霸王:BAAALAADCgQIBAAAAA==.',['叶灬']='叶灬傾云:BAAALAAFFAIIAgAAAA==.',['名字']='名字被偷了:BAAALAAECgIIAgABLAAECgYIBgAdAAAAAA==.',['呆呆']='呆呆肥猫:BAAALAAECgYIBgAAAA==.',['呆小']='呆小夏:BAABLAAFFH8FAAIMAAMIXAHlDQAtAAAMAAMIXAHlDQAtAAAAAA==.',['周少']='周少赔钱:BAAALAADCgIIAgAAAA==.',['咆哮']='咆哮决一死战:BAAALAAECgYIBgAAAA==.咆哮幻灵:BAAALAAECgEIAQAAAA==.咆哮幽冥:BAAALAAECgYIEgAAAA==.咆哮影刃:BAAALAAECgYICAAAAA==.咆哮灵法:BAAALAAECggICAAAAA==.',['和諧']='和諧進行曲:BAAALAAECgMIAwAAAA==.',['咔擦']='咔擦一刀:BAAALAADCgEIAQAAAA==.',['哀伤']='哀伤小鱼:BAAALAAECgEIAQAAAA==.',['哀川']='哀川润:BAAALAAFFAIIAgABLAAFFAgILwAOAPQdAA==.',['哈世']='哈世骑:BAABLAAFFH8QAAIeAAgIFw5uCAAIAgAeAAgIFw5uCAAIAgAAAA==.',['哈納']='哈納逹丨漪酷:BAABLAAFFH8UAAIOAAUIax++NwBlAQAOAAUIax++NwBlAQAAAA==.',['唐大']='唐大叔:BAACLAAFFH8IAAICAAIIzg8sbgBAAAACAAIIzg8sbgBAAAAsAAQKfyAAAgIABgg6Hu88AKgBAAIABgg6Hu88AKgBAAAA.',['唐雨']='唐雨柔:BAAALAAECgYIBgAAAA==.',['啸风']='啸风勇者无敌:BAAALAADCgYIDwAAAA==.',['喵兔']='喵兔兔:BAACLAAFFH8IAAIXAAIIfhHzSgBwAAAXAAIIfhHzSgBwAAAsAAQKfxsAAhcABggzF5qBAH0BABcABggzF5qBAH0BAAAA.',['嗜血']='嗜血战魂:BAABLAAFFH8IAAIFAAgIWgFKZwAaAAAFAAgIWgFKZwAaAAAAAA==.嗜血箭魂:BAAALAAFFAIIBAAAAA==.',['嗯丶']='嗯丶我的益达:BAAALAAECgYIBgAAAA==.',['嗳幽']='嗳幽喂:BAAALAAECgYIBgAAAA==.',['嗷呜']='嗷呜:BAAALAAECggIBQAAAA==.',['噗哩']='噗哩噗噜:BAAALAAFFAIIBAAAAA==.',['噗噜']='噗噜噗哩:BAAALAAFFAIIAgAAAA==.',['回归']='回归玩家丶:BAAALAAFFAYIAwAAAA==.',['圣光']='圣光吃了你:BAAALAAFFAMIAwAAAA==.圣光爱河:BAACLAAFFH8GAAIeAAIItAlbIQCFAAAeAAIItAlbIQCFAAAsAAQKfxQAAh4ABggHHMMlAO0BAB4ABggHHMMlAO0BAAAA.圣光牛牛:BAABLAAFFH8GAAICAAIIEhl9NACnAAACAAIIEhl9NACnAAAAAA==.',['圣环']='圣环:BAAALAAECgYICgAAAA==.',['圣骑']='圣骑诗:BAAALAAECgQIBAAAAA==.',['地心']='地心之战:BAAALAAECgQIBAAAAA==.',['地牢']='地牢一刻:BAABLAAFFH8GAAITAAIIJBY6DwCeAAATAAIIJBY6DwCeAAAAAA==.',['坑团']='坑团圣光:BAABLAAECn8WAAICAAcIWxQDnwC4AQACAAcIWxQDnwC4AQAAAA==.',['埃兰']='埃兰迪尔:BAAALAAECgYICAAAAA==.',['墜亠']='墜亠落:BAAALAAFFAIIBAAAAA==.',['夏末']='夏末秋丶:BAAALAAECgYIBgAAAA==.',['多乐']='多乐麦披萨:BAAALAAECgUIBQAAAA==.',['多听']='多听五月天:BAAALAAECgYIBgAAAA==.多听周杰伦:BAAALAAECgUIBQAAAA==.',['夢星']='夢星尘:BAABLAAFFH8GAAIFAAYI1ggOJgBGAQAFAAYI1ggOJgBGAQAAAA==.',['大个']='大个子妞妞:BAABLAAFFH8GAAMUAAYIIgC+HAADAAAUAAUIFQC+HAADAAAPAAEIZgBGdQACAAAAAA==.大个子牛妞:BAAALAAFFAIIAgAAAA==.',['大兽']='大兽猩:BAABLAAECn8UAAIQAAgIHhvoJgDdAQAQAAgIHhvoJgDdAQAAAA==.',['大松']='大松狮:BAABLAAFFH8GAAIGAAIIUxgnFACCAAAGAAIIUxgnFACCAAAAAA==.',['大濕']='大濕兄:BAAALAAECgIIAgAAAA==.',['大炮']='大炮丶:BAAALAAFFAIIBAAAAA==.',['天天']='天天盼队灭:BAAALAAECgYIBgAAAA==.',['天星']='天星余白音:BAAALAADCgMIAwAAAA==.',['天朝']='天朝犀利哥:BAAALAAECgQIBAAAAA==.',['天籁']='天籁丶随缘:BAAALAADCgUICAAAAA==.',['夺妻']='夺妻者伊利蛋:BAAALAAECgIIAgAAAA==.',['奥蕾']='奥蕾亚:BAABLAAECn8wAAIQAAYItBLoaAAfAQAQAAYItBLoaAAfAQABLAAECgYIPAACAA4eAA==.',['奶油']='奶油绿色茶:BAAALAAECgMIAwAAAA==.',['奶牛']='奶牛奶流奶油:BAAALAADCgEIAQAAAA==.奶牛杀手:BAABLAAECn8cAAIFAAgIsxy0KQCWAgAFAAgIsxy0KQCWAgAAAA==.',['好是']='好是橙双:BAABLAAFFH8KAAIQAAYIJg61PQBLAQAQAAYIJg61PQBLAQAAAA==.',['好汉']='好汉绕命:BAAALAAECgQIAgAAAA==.',['妖蛾']='妖蛾子:BAAALAAECgEIAQAAAA==.',['妳的']='妳的名字:BAAALAAECgcIDgABLAAECgYIBgAdAAAAAA==.',['宝爷']='宝爷同款:BAABLAAFFH8OAAIIAAYIQxd7JACNAQAIAAYIQxd7JACNAQAAAA==.',['寶汏']='寶汏蜀:BAAALAAFFAIIBAAAAA==.',['导演']='导演:BAABLAAFFH8LAAIOAAYITQSQVwD5AAAOAAYITQSQVwD5AAAAAA==.',['小乌']='小乌雨:BAAALAAECgYIBgAAAA==.',['小宝']='小宝:BAABLAAFFH8JAAIVAAMIfRjaKADXAAAVAAMIfRjaKADXAAABLAAFFAUICwADAKMQAA==.',['小小']='小小蓉蓉:BAAALAAECgYICAAAAA==.',['小德']='小德真牛:BAAALAAECggICAAAAA==.',['小样']='小样还跑:BAAALAAECgYICwAAAA==.',['小牛']='小牛飞啊飞:BAAALAAECgYIBgAAAA==.',['小艾']='小艾会变身:BAAALAAFFAIIBAAAAA==.小艾会武术:BAAALAAFFAIIAgAAAA==.小艾会闪电:BAABLAAFFH8IAAMXAAIIeBoqSgCMAAAXAAIIeBoqSgCMAAAbAAIIxQsMSwA8AAAAAA==.',['小诺']='小诺诺:BAAALAAECgYIBwAAAA==.',['小麦']='小麦:BAABLAAFFH8QAAIPAAUIRgvpMAAaAQAPAAUIRgvpMAAaAQAAAA==.',['少年']='少年浮云:BAABLAAFFH8aAAMDAAUIWxYQCQD/AAABAAUIeRViMQBBAQADAAUIiw0QCQD/AAAAAA==.',['尹利']='尹利丹丶怒风:BAAALAAECgUICgAAAA==.',['岳绮']='岳绮罗:BAAALAAECgQIAwAAAA==.',['左亦']='左亦是右:BAACLAAFFH8XAAIOAAYI8RtCIwCrAQAOAAYI8RtCIwCrAQAsAAQKfxsAAg4ABghbGYzYAGABAA4ABghbGYzYAGABAAAA.',['巨江']='巨江江:BAAALAAECgEIAQAAAA==.',['巭孬']='巭孬丷嫑粜昆:BAABLAAFFH8YAAIQAAUIZR36KwDpAAAQAAUIZR36KwDpAAAAAA==.',['帆布']='帆布鞋的骄傲:BAAALAAECggICAAAAA==.',['希尔']='希尔瓦那厮:BAABLAAFFH8mAAIOAAUIaRRjTwAYAQAOAAUIaRRjTwAYAQAAAA==.',['带云']='带云携雨:BAABLAAFFH8HAAMbAAIIHQbeNAB+AAAbAAIIHQbeNAB+AAAXAAIIaQCscgBBAAAAAA==.',['带血']='带血的黄瓜:BAABLAAFFH8sAAQWAAYIZRtKAQBaAQAFAAYIVxqHFgCtAQAWAAYINAxKAQBaAQAaAAMIzRcbDgDhAAAAAA==.',['帽失']='帽失鬼:BAAALAADCgMIBAAAAA==.',['幸運']='幸運兒丶青見:BAAALAAECgYIBgAAAA==.',['幻神']='幻神丸:BAABLAAECn8kAAQRAAYIbxisEgAmAQAOAAYIrQ9Y7gBEAQARAAYIYhWsEgAmAQAfAAMInxlQCwDhAAABLAAECgYIPAACAA4eAA==.',['幼稚']='幼稚完:BAABLAAFFH8GAAIgAAIIOATQQQBxAAAgAAIIOATQQQBxAAAAAA==.',['延森']='延森费蕿:BAABLAAFFH8KAAIPAAYIxxEZIACGAQAPAAYIxxEZIACGAQAAAA==.',['开打']='开打我就躺尸:BAAALAAECgYIEgAAAA==.',['张扒']='张扒皮:BAAALAAECggIDgAAAA==.',['弦歌']='弦歌琉琉:BAACLAAFFH8PAAIDAAIIcBW3GAA/AAADAAIIcBW3GAA/AAAsAAQKfyoAAgMACAgWExUqANwBAAMACAgWExUqANwBAAEsAAUUBggUAA8AFhYA.',['影丿']='影丿少龙灬:BAAALAAECgUIBQAAAA==.',['影子']='影子月夜:BAABLAAECn8XAAMDAAYIOh3KEwCXAQADAAYIOh3KEwCXAQABAAIIrwcA+wBGAAABLAAFFAgIBAAdAAAAAA==.',['微江']='微江江:BAABLAAFFH8IAAIXAAMIyA31SwCHAAAXAAMIyA31SwCHAAAAAA==.',['忘忧']='忘忧:BAAALAAFFAIIAgAAAA==.',['怪影']='怪影神骑:BAAALAAECgYIDgAAAA==.',['恶魔']='恶魔的低语:BAAALAAECgYIDAAAAA==.',['悲伤']='悲伤胡辣汤:BAAALAAFFAIIAgAAAA==.',['惊枝']='惊枝寒鸦:BAAALAADCgMIAwAAAA==.',['想啥']='想啥呢赶紧灭:BAAALAAECgYIDQAAAA==.想啥呢速度灭:BAAALAAECgcIEQAAAA==.',['想死']='想死讲一声:BAABLAAECn8cAAMhAAgIrxnQDgDFAQAhAAYIoBrQDgDFAQAiAAgIYhBTKADBAQAAAA==.',['我为']='我为飞翔而生:BAAALAAECgYIDgAAAA==.',['我叫']='我叫呆贼:BAAALAAECgUIBQAAAA==.',['我是']='我是个打工的:BAACLAAFFH83AAICAAYIuR5rDwDPAQACAAYIuR5rDwDPAQAsAAQKfycAAgIACAidIEtBAHgCAAIACAidIEtBAHgCAAEsAAQKBggGAB0AAAAA.我是劣人:BAAALAAECgIIAgABLAAECgYIBgAdAAAAAA==.',['我有']='我有点紧张:BAACLAAFFH8pAAMOAAYItB+hIwCqAQAOAAYItB+hIwCqAQARAAMIUxVuEQDdAAAsAAQKfy0AAxEABgj1JPQpACcCABEABgiMIfQpACcCAA4ABgioI7lBAMoBAAAA.',['我本']='我本良人:BAAALAAECgMIBAAAAA==.',['我的']='我的大牛牛:BAAALAAECgEIAQAAAA==.我的小猎猎:BAAALAAFFAMIAwABLAAFFAMIBwAQAJMbAA==.',['把爱']='把爱带回家:BAACLAAFFH8KAAIVAAMI9w/BKQCFAAAVAAMI9w/BKQCFAAAsAAQKfxoAAxUACAjoEAtTAJ0BABUACAjoEAtTAJ0BAA0AAQjmA7OyACkAAAAA.',['抓牛']='抓牛粪甩你:BAAALAAECgUIBQAAAA==.',['抹茶']='抹茶慕斯:BAAALAAECgUIBQAAAA==.',['拜月']='拜月者:BAAALAAECgYIDwAAAA==.',['指尖']='指尖缠绕年华:BAAALAAECgcIAQAAAA==.',['提里']='提里奥丶扶丁:BAABLAAFFH8QAAICAAYI+R+oEgC5AQACAAYI+R+oEgC5AQAAAA==.',['摸鱼']='摸鱼小能手:BAACLAAFFH8KAAICAAIIcCJiIwDFAAACAAIIcCJiIwDFAAAsAAQKfx4AAwIABghzIsRbADQCAAIABghzIsRbADQCAB4ABghaEx8eAFkBAAAA.',['放弃']='放弃再来:BAAALAAFFAIIAgAAAA==.',['故无']='故无所思:BAACLAAFFH8GAAMbAAQIlwhbMAC4AAAbAAQIlwhbMAC4AAAXAAIIdhdTOgCMAAAsAAQKfy0AAxsACAiJGeMuAFMCABsACAiJGeMuAFMCABcACAjcHedoALMBAAAA.',['斑牛']='斑牛:BAAALAAECgEIAQAAAA==.',['斩月']='斩月热血:BAAALAAECgYICAAAAA==.',['新一']='新一代:BAABLAAFFH8IAAIOAAgIzwC7yAAMAAAOAAgIzwC7yAAMAAAAAA==.',['方特']='方特不好玩:BAAALAADCgYIBgAAAA==.',['无敌']='无敌小宋宋:BAAALAAECgIIAgAAAA==.无敌莽哥:BAAALAAECgYICwAAAA==.',['无言']='无言亦吾言:BAAALAADCgUIBQAAAA==.',['日日']='日日想团灭:BAAALAAECgMIBAAAAA==.',['日能']='日能得很:BAAALAADCgYIBgAAAA==.',['早安']='早安丶:BAAALAAFFAMIAwAAAA==.',['明天']='明天丶你好:BAAALAAECgEIAQAAAA==.',['星夜']='星夜孤行:BAAALAAFFAIIAgAAAA==.',['星落']='星落小白牛:BAAALAAECgIIAgAAAA==.',['晚安']='晚安丶:BAABLAAFFH8IAAICAAYIXhNSHQB9AQACAAYIXhNSHQB9AQAAAA==.',['暗黑']='暗黑周杰伦:BAAALAAFFAIIAgAAAA==.',['暴力']='暴力咕咕熊:BAAALAAECgUIBQAAAA==.暴力男的:BAABLAAFFH8VAAIOAAYIhxw4LgCEAQAOAAYIhxw4LgCEAQAAAA==.',['暴风']='暴风:BAAALAAECgEIAQAAAA==.',['曲苑']='曲苑风荷:BAAALAAECgMIAwAAAA==.',['曾照']='曾照彩雲归:BAABLAAFFH8MAAIVAAUI7xCIIAAhAQAVAAUI7xCIIAAhAQAAAA==.',['最爱']='最爱风清云淡:BAAALAADCggIDAAAAA==.',['月光']='月光淋漓:BAAALAAECgYIBgAAAA==.',['木兆']='木兆子哥:BAAALAAECgYIBwAAAA==.',['木木']='木木小魚:BAABLAAFFH8bAAIgAAYI0SKDBgBqAgAgAAYI0SKDBgBqAgAAAA==.木木小鱼:BAABLAAFFH8KAAIgAAUI7RrdFwCYAQAgAAUI7RrdFwCYAQABLAAFFAYIGwAgANEiAA==.木木枭:BAAALAAFFAIIBAABLAAFFAYIFgAQAEsWAA==.',['木頭']='木頭秂:BAAALAAECgQIBAAAAA==.',['本拉']='本拉斯:BAAALAAFFAQIBAAAAA==.',['杀手']='杀手奶牛:BAAALAADCgEIAQAAAA==.',['来根']='来根华子:BAAALAAECgUIBQAAAA==.',['東東']='東東:BAAALAAECgUIBQAAAA==.',['東篱']='東篱:BAABLAAFFH8GAAIOAAYIigITewBsAAAOAAYIigITewBsAAAAAA==.',['東雲']='東雲諒子:BAAALAAECgYIDAABLAAFFAgILwAOAPQdAA==.',['板大']='板大师:BAAALAAFFAIIAgAAAA==.板大帥:BAAALAAECgYIDAAAAA==.',['林樂']='林樂樂:BAABLAAFFH8KAAIVAAIIkhqPNwCQAAAVAAIIkhqPNwCQAAABLAAFFAYIGwAgANEiAA==.',['果粒']='果粒奶牛:BAABLAAFFH8HAAIFAAII4hVCSABMAAAFAAII4hVCSABMAAAAAA==.',['柒灬']='柒灬柒:BAAALAAECgYIBgAAAA==.',['柚暴']='柚暴富了茶茶:BAAALAAECgYIBgAAAA==.',['柠檬']='柠檬养乐多:BAAALAAECgYICQAAAA==.柠檬士力架:BAAALAAECgYIBgAAAA==.柠檬果冻:BAAALAAECgYIDQAAAA==.柠檬骑士:BAABLAAFFH8KAAICAAYIFhaJEAA/AQACAAYIFhaJEAA/AQAAAA==.',['桃芝']='桃芝妖妖:BAAALAAFFAYIAwAAAA==.',['桑桑']='桑桑威武:BAAALAAECgYIBgAAAA==.',['梦游']='梦游娃娃:BAABLAAFFH8FAAIIAAUILgnGPwACAQAIAAUILgnGPwACAQAAAA==.',['梦红']='梦红楼:BAAALAAECgEIAQAAAA==.',['梦黎']='梦黎甄:BAAALAAECgYIBgAAAA==.',['梵天']='梵天不凡:BAAALAAECgIIAgAAAA==.梵天欢鱼:BAAALAAECgQIBAAAAA==.梵天米:BAAALAAECgUIBQAAAA==.',['楚天']='楚天骑:BAAALAAECgUIBgAAAA==.',['橘座']='橘座:BAAALAAECgUIBwAAAA==.',['死在']='死在冲锋路上:BAAALAAECgIIAwAAAA==.',['死的']='死的快:BAAALAAECgYICgAAAA==.',['永丶']='永丶怡:BAABLAAFFH8MAAIIAAYIvh9eCwAXAgAIAAYIvh9eCwAXAgAAAA==.',['没所']='没所谓:BAAALAAECgYICgAAAA==.',['沫尐']='沫尐柒:BAAALAAECgYICwAAAA==.',['法修']='法修:BAAALAAECgIIAgAAAA==.',['泡泡']='泡泡术丶士:BAAALAAECgYIBgAAAA==.',['泽拉']='泽拉斯:BAAALAAECgEIAQAAAA==.',['洗墨']='洗墨鲲锋:BAABLAAFFH8HAAIPAAQIRQ4/OADDAAAPAAQIRQ4/OADDAAAAAA==.',['流天']='流天类星龙:BAABLAAFFH8FAAIjAAUIMxxCBwC6AQAjAAUIMxxCBwC6AQAAAA==.',['流年']='流年划破容颜:BAAALAAECgYIDQAAAA==.',['涅墨']='涅墨斯基:BAABLAAFFH8NAAIQAAMIRxPvLQDiAAAQAAMIRxPvLQDiAAAAAA==.',['清清']='清清的悠悠来:BAAALAADCgUIBQAAAA==.',['清风']='清风勇者玩惧:BAAALAADCgQIBAAAAA==.清风寒月:BAAALAAECgYIDQAAAA==.',['清香']='清香艾草:BAAALAADCgcIBwAAAA==.',['温柔']='温柔猎魔:BAAALAAECgEIAQAAAA==.',['滑滑']='滑滑小饺子:BAAALAAECgYIBwAAAA==.',['满大']='满大街兄弟:BAABLAAFFH8MAAIOAAQIlByRVAAGAQAOAAQIlByRVAAGAQAAAA==.',['潘达']='潘达利亚之迷:BAABLAAECn8UAAIXAAYIuhu6JgDVAQAXAAYIuhu6JgDVAQAAAA==.',['灬阿']='灬阿强灬:BAAALAAECgYIBgAAAA==.',['灭团']='灭团因为缺德:BAAALAAECgYICAAAAA==.灭团总指挥:BAAALAAECgQIBgAAAA==.',['灭绝']='灭绝师太她爹:BAAALAAECgIIAgAAAA==.',['炙眼']='炙眼紅袖添亂:BAAALAAECggICAAAAA==.',['点点']='点点小雨滴:BAABLAAFFH8OAAIDAAIIExs6FABIAAADAAIIExs6FABIAAAAAA==.',['烮人']='烮人:BAABLAAECn8XAAMOAAYIXiH/SgCzAQAOAAYI7SD/SgCzAQARAAYI3xh/UgBtAQAAAA==.',['煉獄']='煉獄丶死神:BAACLAAFFH8UAAIQAAUIqxGCRAAvAQAQAAUIqxGCRAAvAQAsAAQKfx0AAxAACAgHGKUnANoBABAACAj9F6UnANoBABMABAgIFKQ+AOYAAAAA.',['熟饺']='熟饺子:BAAALAAECgUIBgAAAA==.',['爆米']='爆米花:BAAALAADCgUIBQAAAA==.',['牛大']='牛大官人:BAABLAAECn8WAAIeAAcIDiRuBADSAgAeAAcIDiRuBADSAgAAAA==.',['牛德']='牛德萨斯:BAABLAAFFH8JAAIVAAIISR8BLwCzAAAVAAIISR8BLwCzAAAAAA==.',['牧王']='牧王之王:BAAALAAECgYIBgAAAA==.',['犀利']='犀利兽哥:BAAALAAECgYIBgAAAA==.',['狂蹦']='狂蹦小蚱蜢:BAAALAAECgYIDAAAAA==.',['狼之']='狼之迷惑:BAAALAAECgYIDgAAAA==.',['猎丶']='猎丶刃:BAAALAADCgIIAgAAAA==.',['猛牛']='猛牛丸:BAABLAAECn8sAAQfAAYITyBBBADHAQAfAAYITyBBBADHAQARAAYIoRlREQA5AQAOAAMIaxJyTQGzAAABLAAECgYIPAACAA4eAA==.',['玉娇']='玉娇龙叮当:BAAALAAECgIIAgAAAA==.玉娇龙小叮当:BAAALAAECgQIBAAAAA==.玉娇龙虎虎:BAABLAAFFH8GAAIQAAYI8g1hMQB8AQAQAAYI8g1hMQB8AQAAAA==.玉娇龙赛利亚:BAAALAAECgUIBQAAAA==.',['玉米']='玉米推车:BAAALAAECgYIDAAAAA==.',['玉面']='玉面吟魔:BAAALAAECgIIAgAAAA==.',['玩累']='玩累歇一会儿:BAABLAAFFH8JAAIRAAIIHgNTHAAoAAARAAIIHgNTHAAoAAAAAA==.',['玲珑']='玲珑水色:BAACLAAFFH81AAQHAAYIZyTyBQDcAAAIAAYI9iDMFQDiAQAHAAMIuiTyBQDcAAAkAAEIXSHuBgBaAAAsAAQKfx0AAwcACAh7I7gOAIwCAAgACAgxHtInAKUCAAcABwiUIrgOAIwCAAAA.',['瑷丶']='瑷丶太美:BAAALAAECgYIDwAAAA==.',['璃蛊']='璃蛊迷心:BAACLAAFFH8UAAIPAAYIFhZMGwCfAQAPAAYIFhZMGwCfAQAsAAQKfyIAAg8ACAgFFvhkAP4BAA8ACAgFFvhkAP4BAAAA.',['瓦斯']='瓦斯特:BAAALAAECgcIDwAAAA==.',['生下']='生下来就死了:BAAALAAECgEIAQAAAA==.',['疏远']='疏远的可以:BAABLAAFFH8IAAIQAAIIygugfACJAAAQAAIIygugfACJAAAAAA==.',['疯一']='疯一样的男子:BAABLAAECn8ZAAICAAcI0QjgeQAQAQACAAcI0QjgeQAQAQAAAA==.',['疯狂']='疯狂的皮皮:BAABLAAFFH8SAAICAAUIuRGCKwAtAQACAAUIuRGCKwAtAQABLAAFFAUIGgADAFsWAA==.',['痞子']='痞子坏坏:BAAALAADCgYIBAAAAA==.',['白昼']='白昼行將:BAABLAAFFH8gAAIXAAUIXR53GACfAQAXAAUIXR53GACfAQAAAA==.',['白榆']='白榆的白:BAABLAAFFH8IAAIXAAYIaxkfGACjAQAXAAYIaxkfGACjAQABLAAFFAgIDgAlAIIMAA==.',['白牧']='白牧白:BAAALAADCgYIBgAAAA==.',['白瑜']='白瑜瑜:BAABLAAFFH8HAAIOAAQIHCCDFAB9AQAOAAQIHCCDFAB9AQAAAA==.',['皇族']='皇族水琉璃:BAAALAAECgQIBAAAAA==.',['皮城']='皮城大土豪:BAAALAAFFAIIBAAAAA==.皮城小歪:BAABLAAFFH8GAAIOAAIIrxvwiQBKAAAOAAIIrxvwiQBKAAAAAA==.皮城执法者:BAABLAAFFH8GAAIXAAIIfAQXaABZAAAXAAIIfAQXaABZAAAAAA==.皮城莱因哈特:BAAALAAFFAIIAgAAAA==.',['盈缺']='盈缺:BAAALAAECgQIBAAAAA==.',['盗月']='盗月:BAABLAAFFH8GAAIOAAYIXQ10QABMAQAOAAYIXQ10QABMAQAAAA==.',['盲人']='盲人:BAAALAADCgQIBAAAAA==.',['盼盼']='盼盼防盗:BAABLAAFFH8PAAIXAAMI1ArAVAB0AAAXAAMI1ArAVAB0AAAAAA==.',['眉间']='眉间雪:BAAALAADCgIIAgAAAA==.',['瞧你']='瞧你那揍性:BAABLAAECn8VAAIhAAYIeiGTCQAuAgAhAAYIeiGTCQAuAgAAAA==.',['矫情']='矫情:BAACLAAFFH8RAAMBAAYIPhsECAAxAgABAAYIPhsECAAxAgADAAMIHxb6DACNAAAsAAQKfxcAAwMACAjLFvMlAPUBAAMABwhHGfMlAPUBAAEAAghpA+j8AEIAAAAA.',['硬梆']='硬梆梆:BAAALAAFFAIIAgABLAAFFAMIBwAQAJMbAA==.',['碎南']='碎南瓜:BAAALAADCgQIBAAAAA==.',['祈福']='祈福之光:BAAALAAECgYIBgAAAA==.',['神仙']='神仙的时光:BAAALAAECgYIEgAAAA==.',['神奇']='神奇的时光:BAAALAAECgYIDgAAAA==.',['神我']='神我来救你:BAAALAAECgIIBQAAAA==.',['祢豆']='祢豆子:BAAALAAECgcIBwAAAA==.',['秦端']='秦端雨:BAAALAAECgUIBQAAAA==.',['穿靴']='穿靴子的猫丶:BAABLAAFFH8ZAAIeAAUIDRebEgBnAQAeAAUIDRebEgBnAQABLAAFFAgIAwAdAAAAAA==.',['精灵']='精灵小术:BAAALAAFFAIIBAAAAA==.',['精神']='精神病会传染:BAAALAAECgYIDAAAAA==.',['索利']='索利达尔:BAABLAAFFH8VAAMOAAMISRm/KQDXAAAOAAMISRm/KQDXAAARAAIIpxkHHACYAAAAAA==.',['繁茂']='繁茂紅袖添亂:BAAALAAECggICgAAAA==.',['约德']='约德尔弓兵:BAAALAAECgEIAQAAAA==.',['组我']='组我组我:BAAALAAECggICAAAAA==.',['终极']='终极灵魂:BAAALAAECggIAwAAAA==.',['给我']='给我理由忘记:BAAALAAECgYIDAAAAA==.',['绿熊']='绿熊猫:BAAALAAECgEIAQAAAA==.',['缺德']='缺德带冒烟儿:BAAALAAECgYIDAAAAA==.',['老衲']='老衲启能容你:BAAALAAECgcIBwAAAA==.',['联盟']='联盟万户侯:BAABLAAFFH8WAAICAAQIQRw6JwC7AAACAAQIQRw6JwC7AAAAAA==.',['聖丶']='聖丶光:BAAALAAECgYICQAAAA==.',['聖光']='聖光淑丶:BAABLAAFFH8GAAICAAYI8wA1TgBjAAACAAYI8wA1TgBjAAAAAA==.',['肆月']='肆月初三:BAAALAAECgUIBQAAAA==.',['肥嘟']='肥嘟嘟流口水:BAAALAAECgYICAAAAA==.',['胖丁']='胖丁子:BAAALAAFFAIIAgAAAA==.',['胡牛']='胡牛腰:BAAALAAECgYIAgAAAA==.',['脸滚']='脸滚的荣光:BAABLAAFFH8IAAICAAQI6Q6YNgDZAAACAAQI6Q6YNgDZAAAAAA==.',['至高']='至高岭扛把子:BAAALAAECgYIEgAAAA==.',['舟舟']='舟舟:BAABLAAFFH8GAAIIAAIIeA1HaQA4AAAIAAIIeA1HaQA4AAAAAA==.',['艾欧']='艾欧利亚:BAABLAAFFH8VAAMFAAYIzQVIKgAjAQAFAAYIJgRIKgAjAQAaAAIIJgnQJwBuAAAAAA==.',['芙宁']='芙宁娜:BAABLAAFFH8GAAIGAAYIjwbVEwAQAQAGAAYIjwbVEwAQAQAAAA==.',['花和']='花和尚撸泰森:BAAALAADCgEIAQAAAA==.',['花木']='花木九里虎:BAAALAAECgYICAAAAA==.',['花落']='花落丶莫相随:BAAALAADCgIIAgAAAA==.',['花间']='花间:BAAALAAFFAIIAgAAAA==.花间氵骑:BAAALAAFFAIIAgAAAA==.花间灬战:BAAALAAFFAIIAgAAAA==.',['苍穹']='苍穹的血骑士:BAAALAADCgcIBwAAAA==.',['范二']='范二小青年:BAAALAAECgEIAQAAAA==.',['草莽']='草莽英雄许仙:BAAALAAECgYIBgAAAA==.',['药药']='药药丷切克闹:BAABLAAFFH8gAAQKAAYIZRmvCwBbAQAKAAUIIhqvCwBbAQAZAAMI0BSEAwCQAAALAAEIzAaGHwA3AAAAAA==.',['莉娜']='莉娜樱巴斯:BAAALAADCggICAAAAA==.莉娜茵巴斯:BAAALAAECgQIBAAAAA==.',['莫言']='莫言丶至永恒:BAAALAADCgEIAQAAAA==.',['莹草']='莹草:BAAALAAFFAQIBAABLAAFFAgIBgAOADQGAA==.',['萌小']='萌小蹄:BAAALAAFFAIIAgAAAA==.',['萨丨']='萨丨尔:BAAALAAECgYIAwAAAA==.',['萨卡']='萨卡奥兰:BAACLAAFFH8KAAIXAAIIeQt8ZwBVAAAXAAIIeQt8ZwBVAAAsAAQKfyEAAxcACAg9D9Y7AG8BABcACAg9D9Y7AG8BABsABQiqCMJOANkAAAEsAAUUCAgKABcAzSMA.萨卡雷斯:BAABLAAECn8rAAIQAAcIVgoUZgAlAQAQAAcIVgoUZgAlAQAAAA==.',['萨子']='萨子:BAAALAAECgYICwAAAA==.',['落雪']='落雪白头:BAAALAADCgUIBQAAAA==.',['蓝凌']='蓝凌雨:BAABLAAECn8iAAIDAAgIsB/HDwCtAgADAAgIsB/HDwCtAgABLAAFFAgIBgAQAO4eAA==.',['薄荷']='薄荷味的夏天:BAAALAAFFAEIAgAAAA==.',['蛋夹']='蛋夹膜:BAAALAAECggICAAAAA==.',['蟋蟀']='蟋蟀的坏坏:BAACLAAFFH8YAAIDAAYIpRi8BACHAQADAAYIpRi8BACHAQAsAAQKfyAAAgMACAjAIacJAP4CAAMACAjAIacJAP4CAAAA.',['血之']='血之守护者:BAAALAAECgQIBAAAAA==.',['血染']='血染暗夜:BAAALAAFFAIIAgAAAA==.',['血蹄']='血蹄村古天乐:BAAALAAECggICgAAAA==.',['被解']='被解救的坚果:BAABLAAFFH8KAAIhAAIIeAMXGgBRAAAhAAIIeAMXGgBRAAAAAA==.',['西西']='西西特:BAAALAAECgMIAwAAAA==.',['詩酒']='詩酒璃璃:BAABLAAECn8cAAIKAAgI0AqeLQC8AQAKAAgI0AqeLQC8AQABLAAFFAYIFAAPABYWAA==.',['諸訷']='諸訷灬猎:BAAALAAFFAIIAgAAAA==.諸訷灬黃昏:BAABLAAFFH8xAAIFAAUIehgeGgD3AAAFAAUIehgeGgD3AAAAAA==.',['词穷']='词穷:BAAALAAFFAIIAgAAAA==.',['诶鸡']='诶鸡哥不在:BAACLAAFFH8NAAIPAAUIrg9YFgAsAQAPAAUIrg9YFgAsAQAsAAQKfxYAAg8ABwjOG5dRAC4CAA8ABwjOG5dRAC4CAAAA.',['谁缺']='谁缺德组我:BAAALAAECgYIEwAAAA==.',['谋刹']='谋刹似水年华:BAAALAAFFAMIAwAAAA==.',['豆狼']='豆狼相册锅:BAAALAAECgIIAgAAAA==.',['贝嘶']='贝嘶可乐:BAABLAAECn8UAAICAAgIsh2dMQCrAgACAAgIsh2dMQCrAgAAAA==.',['赤之']='赤之彗星:BAABLAAECn88AAICAAYIDh7vNwC4AQACAAYIDh7vNwC4AQAAAA==.',['赤犬']='赤犬:BAAALAAECgYIDQAAAA==.',['赵家']='赵家三少爷:BAAALAAFFAMIBAAAAA==.',['赶羚']='赶羚羊:BAAALAAFFAEIAQAAAA==.',['跑炮']='跑炮狍:BAAALAAECgYIDwAAAA==.',['路人']='路人丶甲:BAABLAAECn8ZAAIZAAgIuB78AAB/AgAZAAgIuB78AAB/AgAAAA==.',['踏燕']='踏燕:BAAALAADCgEIAQAAAA==.',['身体']='身体快被掏空:BAAALAAECgQIBAAAAA==.',['车顶']='车顶放红牛:BAAALAAECgYIBgAAAA==.',['辣条']='辣条就午饭:BAABLAAFFH8QAAIFAAIIeR/uQQBbAAAFAAIIeR/uQQBbAAAAAA==.辣条就饭饭:BAAALAAECgYIBwAAAA==.',['辰辰']='辰辰不接:BAABLAAFFH8OAAIbAAMIaiNCEwAuAQAbAAMIaiNCEwAuAQAAAA==.辰辰不落:BAAALAADCgIIAgAAAA==.',['迅疾']='迅疾如风:BAABLAAFFH8GAAIVAAIIthvxMwCeAAAVAAIIthvxMwCeAAAAAA==.',['这波']='这波先灭:BAAALAADCgQIBAAAAA==.',['逃跑']='逃跑德木偶:BAABLAAFFH8FAAINAAUItQrTHQDlAAANAAUItQrTHQDlAAAAAA==.',['逝去']='逝去之魂:BAAALAAFFAIIBAAAAA==.',['遨游']='遨游牛必牧:BAAALAAECgYIBgAAAA==.',['邪恶']='邪恶水蜜桃桃:BAAALAAECgQIBAAAAA==.邪恶的河蟹:BAAALAADCgMIBQAAAA==.',['都是']='都是时辰的错:BAAALAADCgcIBwAAAA==.',['释然']='释然的皮皮:BAAALAAECgEIAQABLAAFFAUIGgADAFsWAA==.',['野蛮']='野蛮传奇:BAAALAAECgYIBgAAAA==.',['金泽']='金泽:BAABLAAECn8XAAICAAYIehMAbwAmAQACAAYIehMAbwAmAQAAAA==.',['鉮之']='鉮之御風:BAAALAAECgEIAQAAAA==.',['钢炮']='钢炮安迪:BAAALAAECgMIAwAAAA==.',['铁血']='铁血直男:BAAALAAECgIIAgAAAA==.',['铁风']='铁风铃:BAAALAAFFAEIAQAAAA==.',['锋芒']='锋芒咋仙:BAAALAADCgYIBgAAAA==.',['问就']='问就是爱玩:BAABLAAFFH8SAAIgAAYIZBGDGACTAQAgAAYIZBGDGACTAQABLAAFFAYIGAADAKUYAA==.',['阿瑞']='阿瑞莎特:BAAALAAECggIEwAAAA==.',['阿良']='阿良:BAAALAAECgIIAgAAAA==.',['陈得']='陈得福:BAAALAADCgcIEgAAAA==.',['陨初']='陨初夕阳:BAAALAAECgYIBgAAAA==.',['集合']='集合分担:BAAALAADCgcIBwAAAA==.',['雨落']='雨落青檐:BAAALAAECggIDgAAAA==.',['雪妍']='雪妍:BAAALAAECgYIBgAAAA==.',['雪落']='雪落兮丶:BAAALAAECggIBAAAAA==.',['雷妮']='雷妮坦格利安:BAABLAAFFH8GAAIJAAYIjx/EAQBFAgAJAAYIjx/EAQBFAgAAAA==.',['霜之']='霜之老大:BAABLAAFFH8GAAIVAAYIswIrKQDUAAAVAAYIswIrKQDUAAABLAAFFAYIGAADAKUYAA==.',['霸霸']='霸霸:BAABLAAFFH8MAAIQAAIIhxS9cQBUAAAQAAIIhxS9cQBUAAAAAA==.',['霹雳']='霹雳小贱猪:BAAALAAECgYIEgAAAA==.',['非酋']='非酋之怒:BAAALAAECgYICQAAAA==.',['韭菜']='韭菜:BAABLAAFFH8LAAIgAAIIwQhTQwBkAAAgAAIIwQhTQwBkAAAAAA==.',['额头']='额头凿个猛字:BAAALAAECgUIBwAAAA==.额头刻个勇字:BAABLAAECn8UAAIeAAYIZyJBCwA9AgAeAAYIZyJBCwA9AgAAAA==.',['風飾']='風飾的灰翼:BAAALAAECgYICAAAAA==.',['风乿']='风乿飞:BAAALAAFFAIIAgABLAAFFAgIHgANAOsWAA==.',['风烈']='风烈小萨满:BAAALAAFFAIIAgAAAA==.风烈梦游:BAABLAAECn8aAAICAAgIkyOeEACLAgACAAgIkyOeEACLAgAAAA==.风烈炎:BAABLAAFFH8HAAIOAAMIDx6eQAClAAAOAAMIDx6eQAClAAAAAA==.风烈焰:BAAALAAFFAIIBAAAAA==.风烈焰爆:BAABLAAFFH8GAAIlAAII/R0UCgCrAAAlAAII/R0UCgCrAAAAAA==.风烈雀跃:BAAALAAFFAIIBAAAAA==.风烈顺水:BAAALAAFFAIIBAAAAA==.',['风的']='风的流失:BAAALAADCgIIAgAAAA==.',['飚飚']='飚飚车遛遛狗:BAAALAAECgYIBgAAAA==.',['飞翔']='飞翔的牛牛:BAACLAAFFH8IAAIXAAIIAQnsagBRAAAXAAIIAQnsagBRAAAsAAQKfxgAAhcABgjTCMdtAL4AABcABgjTCMdtAL4AAAAA.',['飞鱼']='飞鱼:BAABLAAFFH8HAAIQAAMIkxvYWgCgAAAQAAMIkxvYWgCgAAAAAA==.',['食人']='食人魔:BAAALAAECgcIEgAAAA==.',['香辣']='香辣牛肉:BAAALAAECgYIBwAAAA==.',['马里']='马里昂:BAAALAAECgMIBAAAAA==.',['骑子']='骑子:BAAALAAECgYICwAAAA==.',['骑牛']='骑牛:BAAALAAECgYIEAAAAA==.',['高压']='高压锅:BAACLAAFFH8fAAIaAAYIVw1xEQDCAAAaAAYIVw1xEQDCAAAsAAQKfx8AAhoABghuEYcrAPsAABoABghuEYcrAPsAAAAA.',['魅影']='魅影千薇:BAAALAAECgIIAgAAAA==.',['魅靈']='魅靈:BAAALAADCgQIBAAAAA==.',['魑魅']='魑魅王良:BAAALAAECgMIAwAAAA==.',['魔法']='魔法大帅:BAAALAAECgIIAgAAAA==.',['鱼儿']='鱼儿小小:BAABLAAFFH8VAAIOAAUI2hLPUAATAQAOAAUI2hLPUAATAQABLAAFFAYIGwAgANEiAA==.鱼儿莜莜:BAAALAAFFAIIAgAAAA==.',['鲜榨']='鲜榨牛奶:BAACLAAFFH8GAAIVAAIIoxKRRQBnAAAVAAIIoxKRRQBnAAAsAAQKfxsAAxUABgj5D6OAAB0BABUABgj5D6OAAB0BAA0AAQhPA6tsABoAAAAA.',['鲜血']='鲜血咏叹:BAAALAADCgYIBwAAAA==.',['鹰旗']='鹰旗护卫者:BAAALAAECgEIAQAAAA==.',['黄昏']='黄昏灬諸訷:BAABLAAFFH8LAAIQAAUIZRJ6RgAnAQAQAAUIZRJ6RgAnAQAAAA==.',['黄鹤']='黄鹤楼面包:BAAALAADCgUIBQAAAA==.',['黑暗']='黑暗并肩:BAAALAAECgYIBgAAAA==.',['黑桃']='黑桃爱:BAAALAAECgYIDwAAAA==.',['黑糖']='黑糖荞麦茶:BAABLAAFFH8ZAAIOAAYI6BhNKACYAQAOAAYI6BhNKACYAQAAAA==.',['黑騎']='黑騎:BAAALAAECgEIAQAAAA==.',['默念']='默念我是败类:BAAALAAECgYIDAAAAA==.默念我是饭桶:BAAALAAECgYICgAAAA==.',['鼓上']='鼓上蚤拆迁:BAAALAADCggICAAAAA==.',['龘龖']='龘龖龘龘龖龘:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end