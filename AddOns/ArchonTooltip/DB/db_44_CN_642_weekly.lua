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
 local lookup = {'Warlock-Destruction','Evoker-Preservation','Paladin-Retribution','Druid-Restoration','Monk-Mistweaver','Druid-Balance','Priest-Shadow','Mage-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Evoker-Devastation','Mage-Arcane','Evoker-Augmentation','DeathKnight-Frost','DeathKnight-Unholy','Monk-Windwalker','Warrior-Protection','Shaman-Elemental','DemonHunter-Havoc','Shaman-Restoration','DemonHunter-Vengeance','Druid-Guardian','Warlock-Demonology','Druid-Feral','Monk-Brewmaster','Priest-Holy','Warrior-Fury','Rogue-Subtlety','DeathKnight-Blood','Warlock-Affliction','Unknown-Unknown','Shaman-Enhancement','Druid-Any','Paladin-Protection','Hunter-Survival',}; local provider = {region='CN',realm='奥拉基尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ae='Aether:BAABLAAFFH8LAAIBAAYIAhtwVQBSAAABAAYIAhtwVQBSAAAAAA==.',Ba='Ballyhackjj:BAAALAAECgYICgAAAA==.',Bl='Blackfish:BAAALAAECgYIBgAAAA==.Blackjoke:BAAALAAECgYIBgAAAA==.Blacksheep:BAAALAAECgQIBgAAAA==.',Co='Confetti:BAAALAAECgYICAAAAA==.',De='Delight:BAAALAAECgYIBgAAAA==.',Do='Doge:BAABLAAFFH8LAAICAAYIhBcnCQDLAQACAAYIhBcnCQDLAQAAAA==.',Ed='Edwin:BAAALAADCgYIBgAAAA==.',Et='Eth:BAABLAAFFH8GAAICAAYIjxn5CADPAQACAAYIjxn5CADPAQAAAA==.',Fe='Felix:BAACLAAFFH8oAAIDAAYIvyPDBgAbAgADAAYIvyPDBgAbAgAsAAQKfyQAAgMACAhDJIUWABwDAAMACAhDJIUWABwDAAAA.',Fi='Fires:BAAALAAECgYIBgAAAA==.',Fo='Forseken:BAAALAAFFAIIBAAAAA==.',Fr='Fredd:BAABLAAFFH8NAAIEAAMIRBxWIACiAAAEAAMIRBxWIACiAAAAAA==.Freem:BAAALAAECgYIDAAAAA==.Frewo:BAABLAAFFH8NAAIFAAMIQhkVDgD3AAAFAAMIQhkVDgD3AAAAAA==.Frostbit:BAAALAADCgEIAQAAAA==.',Gg='Ggoo:BAAALAADCgYIBgAAAA==.',Gr='Groott:BAABLAAFFH8IAAIEAAII+ReGJwCMAAAEAAII+ReGJwCMAAAAAA==.',Gt='Gt:BAAALAAECgIIAgAAAA==.',Ho='Holybull:BAAALAAECgUIBQAAAA==.Hongmo:BAAALAADCgUIBQAAAA==.',Lo='Lockedrock:BAAALAAFFAIIAgAAAA==.',Lu='Luckymage:BAAALAAECgYIDQAAAA==.Luda:BAAALAAECgYIEAAAAA==.',Ma='Madara:BAABLAAFFH8HAAMGAAMICRvDFQCzAAAGAAII2iDDFQCzAAAEAAII5w/XNABrAAAAAA==.',Mi='Mikaelson:BAAALAADCgYIBgAAAA==.',Mo='Mortis:BAABLAAFFH8JAAICAAIIMw6AFgB/AAACAAIIMw6AFgB/AAAAAA==.',Ni='Nizhiai:BAAALAAECgcIBwAAAA==.',Oc='Octfirst:BAAALAAECgQIBAAAAA==.',Og='Ogilvy:BAAALAADCgQIBAAAAA==.',Pe='Penitent:BAAALAAECgIIAgAAAA==.Pepe:BAABLAAFFH8GAAICAAYIQBjkCADSAQACAAYIQBjkCADSAQAAAA==.',Ra='Rachelmcadms:BAAALAAECggIDgAAAA==.Rainbowfish:BAAALAAFFAMIAgAAAA==.',Re='Rebirth:BAAALAAFFAMIAgAAAA==.Renee:BAABLAAFFH8UAAIHAAYIlQ2JEQBSAQAHAAYIlQ2JEQBSAQABLAAFFAgIJwAIAEQYAA==.',Ro='Rockyou:BAAALAAECgUIBgAAAA==.Rogueminnie:BAAALAAECggICAAAAA==.',Sa='Same:BAACLAAFFH8GAAMJAAIITggMMABgAAAKAAIIegaxfQBqAAAJAAIIxQUMMABgAAAsAAQKfyUAAwkACAgoGYI2AOMBAAoACAiyFvp6AOgBAAkABwg1GYI2AOMBAAAA.Sandt:BAAALAADCgEIAQAAAA==.',Sh='Showtimex:BAAALAADCgcIBwAAAA==.',Si='Silverstein:BAAALAAECgYICwAAAA==.',So='Soullink:BAAALAADCgEIAQAAAA==.',Su='Sums:BAAALAADCggICAAAAA==.',Sy='Syrk:BAAALAADCggICAAAAA==.',Th='Thanato:BAAALAAFFAIIAgAAAA==.',Ut='Utherlight:BAABLAAFFH8GAAMDAAYI/guhNwDDAAADAAQIVA6hNwDDAAALAAIIbxJ0IwCHAAAAAA==.',Ve='Vermilion:BAAALAAFFAIIBAAAAA==.',Vi='Violence:BAAALAAECgYIBgAAAA==.',Wi='Wi:BAABLAAFFH8IAAIMAAII8Bv/HABFAAAMAAII8Bv/HABFAAAAAA==.',Xi='Xiaoshuang:BAAALAAECgYIEgAAAA==.',['Âã']='Âã:BAAALAAECgUIBQAAAA==.',['一十']='一十六:BAAALAAFFAgIAgAAAA==.',['一只']='一只耳:BAAALAADCgMIAwAAAA==.',['一地']='一地的篮子:BAAALAAFFAIIAgAAAA==.',['一如']='一如一:BAABLAAFFH8TAAINAAUIJRfNOwDkAAANAAUIJRfNOwDkAAAAAA==.',['一百']='一百一:BAABLAAFFH8OAAIOAAgIbyKYAADMAgAOAAgIbyKYAADMAgAAAA==.',['一鸟']='一鸟一天堂:BAAALAAECgQIBQAAAA==.',['七夜']='七夜灬听雪丶:BAAALAADCgIIAgAAAA==.',['七尺']='七尺指尖:BAAALAAECgMIAwAAAA==.',['万古']='万古长存:BAAALAAECgYICQAAAA==.',['三十']='三十九:BAABLAAFFH8VAAIOAAgItiVCAAD2AgAOAAgItiVCAAD2AgAAAA==.',['三開']='三開賊法德:BAAALAAECgQIBAAAAA==.',['不懂']='不懂是什么人:BAABLAAFFH8OAAMPAAgIfx7yCQBbAgAPAAgIQB7yCQBbAgAQAAEIVRtEFwBoAAAAAA==.',['不知']='不知道啊:BAABLAAFFH8GAAIRAAII0R3uDACuAAARAAII0R3uDACuAAAAAA==.',['不肯']='不肯過江東:BAAALAAECgcIBQABLAAFFAgIOgASAOgjAA==.',['不过']='不过些许风霜:BAABLAAFFH8GAAITAAIIhBx6IgClAAATAAIIhBx6IgClAAAAAA==.',['世一']='世一战:BAAALAAFFAEIAQAAAA==.',['东方']='东方歌白:BAACLAAFFH8IAAILAAIIuRjfIgCLAAALAAIIuRjfIgCLAAAsAAQKfyQAAgsACAhOICgEANkCAAsACAhOICgEANkCAAAA.',['丨刺']='丨刺骨寒冰丨:BAAALAAFFAIIBAAAAA==.',['丨大']='丨大楽透丨:BAAALAAECgMIAwAAAA==.',['丨憇']='丨憇窩窩丨:BAAALAAECgYIBgAAAA==.',['中年']='中年大叔:BAABLAAFFH8IAAIKAAIIzCF/NAC7AAAKAAIIzCF/NAC7AAAAAA==.',['丶浅']='丶浅梦:BAAALAAFFAIIBAAAAA==.',['丶黑']='丶黑色的猫:BAABLAAFFH8ZAAIUAAUIuxmOJgBbAQAUAAUIuxmOJgBbAQAAAA==.',['主宰']='主宰依然:BAAALAADCgIIAgAAAA==.',['乂丨']='乂丨筱瑶:BAAALAAECgMIAwABLAAFFAIICAADAPAXAA==.',['乂灬']='乂灬筱瑶:BAAALAAFFAEIAQABLAAFFAIICAADAPAXAA==.',['乌雅']='乌雅:BAAALAADCgcIBwAAAA==.',['乙一']='乙一:BAAALAAFFAIIAgAAAA==.',['九十']='九十一:BAABLAAFFH8GAAIOAAYI8yVIAgAzAgAOAAYI8yVIAgAzAgAAAA==.',['二月']='二月花开:BAAALAADCgEIAQAAAA==.',['二等']='二等兵出列:BAABLAAFFH8LAAIVAAYIVhVUGwCAAQAVAAYIVhVUGwCAAQAAAA==.',['五十']='五十五:BAABLAAFFH8MAAIOAAYIvCSmAgAXAgAOAAYIvCSmAgAXAgAAAA==.',['亚萨']='亚萨星耀:BAAALAAFFAIIAgAAAA==.',['亜木']='亜木査:BAAALAAECgUIBQAAAA==.',['京墨']='京墨朝颜四号:BAAALAADCgQICAAAAA==.',['仅仅']='仅仅一笑而过:BAAALAAECgEIAQAAAA==.',['以丶']='以丶德服人:BAAALAAECgMIAwAAAA==.',['以床']='以床丶会友:BAAALAAECgMIAwAAAA==.',['仰泳']='仰泳的鱼:BAAALAAECgYIBgAAAA==.',['伊裴']='伊裴尔塔尔:BAAALAADCgEIAQAAAA==.',['伊达']='伊达雷尔:BAABLAAFFH8KAAIWAAQIAQ4QCwCRAAAWAAQIAQ4QCwCRAAAAAA==.',['优雅']='优雅依然:BAAALAADCgYICwAAAA==.',['会武']='会武术的小妞:BAAALAAECgYIDAAAAA==.',['会溜']='会溜达的萝卜:BAABLAAECn8WAAMKAAgIuyL6EQAbAwAKAAgIuyL6EQAbAwAJAAIInxa5nwB2AAAAAA==.',['会玩']='会玩的萝卜:BAAALAAECgQIBAAAAA==.',['似雨']='似雨若离:BAAALAAECgcIEQAAAA==.',['体面']='体面人:BAAALAAECgYICAAAAA==.',['何以']='何以圣光:BAABLAAFFH8GAAIDAAIIziMEIQDNAAADAAIIziMEIQDNAAAAAA==.',['依宝']='依宝贝二:BAAALAAECgIIAgAAAA==.',['依然']='依然主宰:BAAALAAECgYIBgAAAA==.',['倾城']='倾城一箭:BAABLAAFFH8QAAIKAAYIywwJRQA1AQAKAAYIywwJRQA1AQAAAA==.',['倾心']='倾心语:BAACLAAFFH8IAAIUAAIIgxP5QQCYAAAUAAIIgxP5QQCYAAAsAAQKfxcAAhQABwiRIo0/AGQCABQABwiRIo0/AGQCAAAA.',['元素']='元素灬涌动:BAABLAAFFH8LAAIVAAMIBx4VJgC6AAAVAAMIBx4VJgC6AAAAAA==.元素震荡:BAAALAADCggICAAAAA==.',['光之']='光之勇者:BAAALAAECgMIAwAAAA==.',['光合']='光合作用咕:BAABLAAFFH8PAAIGAAUI5hQsGQAOAQAGAAUI5hQsGQAOAQAAAA==.',['光明']='光明达雷:BAAALAAECgYICgAAAA==.',['光骑']='光骑乌瑟尔:BAAALAAECgIIAgAAAA==.',['八幡']='八幡大菩萨:BAAALAADCgQIBAAAAA==.',['六神']='六神花露髓:BAAALAAECgQICgAAAA==.',['六翼']='六翼的天使:BAAALAAECgQICAAAAA==.',['兲沚']='兲沚詪:BAABLAAFFH8KAAIKAAQInBfRWQDhAAAKAAQInBfRWQDhAAAAAA==.',['关羽']='关羽:BAABLAAFFH8RAAIDAAUI9B1hJQBJAQADAAUI9B1hJQBJAQAAAA==.',['关门']='关门放川宝:BAAALAAFFAIIBAAAAA==.',['冈拉']='冈拉美朵:BAAALAAECgYIDAAAAA==.',['冉冉']='冉冉升起:BAAALAAECgIIAgAAAA==.',['再跑']='再跑腿打折:BAAALAAECgYIBgAAAA==.',['冥王']='冥王一闪:BAAALAADCgYIBgAAAA==.',['冬季']='冬季火焰:BAAALAAECgMIAwAAAA==.',['冰封']='冰封的八氵壹:BAABLAAFFH8SAAIPAAYIgxfdIwClAQAPAAYIgxfdIwClAQAAAA==.',['冰蓝']='冰蓝:BAABLAAFFH8SAAIPAAYI3Q1jNQBmAQAPAAYI3Q1jNQBmAQAAAA==.',['凛冬']='凛冬丨将至:BAACLAAFFH8NAAIPAAQIbw+eHwAlAQAPAAQIbw+eHwAlAQAsAAQKfx4AAg8ACAhEIG8rAMQCAA8ACAhEIG8rAMQCAAAA.',['凯瑟']='凯瑟琳丶黛儿:BAAALAAFFAIIAgAAAA==.',['初夏']='初夏落雪:BAAALAADCgIIAgAAAA==.',['勇敢']='勇敢德胖猫:BAAALAADCgYIBgAAAA==.',['匆匆']='匆匆过客:BAAALAAECggICAAAAA==.',['北原']='北原多香:BAABLAAFFH8GAAIDAAIIBhLhdgA6AAADAAIIBhLhdgA6AAAAAA==.',['十方']='十方灭丶:BAAALAAECgQIBAAAAA==.',['半城']='半城灬煙雨:BAAALAAECgMIBgAAAA==.',['半夜']='半夜挠墙:BAABLAAFFH8FAAIPAAUItQm1TwDhAAAPAAUItQm1TwDhAAAAAA==.',['卖女']='卖女孩的火财:BAAALAAECgYIDgAAAA==.',['卖火']='卖火财的女孩:BAABLAAECn8VAAIJAAYIJRE7agAdAQAJAAYIJRE7agAdAQAAAA==.卖火财的男孩:BAAALAAECgYIEgAAAA==.',['卖男']='卖男孩的火财:BAAALAAECgYIDwAAAA==.',['南宫']='南宫仆射:BAAALAAFFAIIAgAAAA==.',['卡蒂']='卡蒂弗兰克:BAAALAAECgYIBgAAAA==.',['卢瑟']='卢瑟的小德:BAABLAAECn8fAAMEAAcIGhZNKgCNAQAEAAcIGhZNKgCNAQAXAAYIRAR/HgCLAAAAAA==.',['卩尐']='卩尐嚇丶:BAAALAADCggICAAAAA==.',['卷毛']='卷毛的大玉米:BAAALAAECgQIBAAAAA==.',['原天']='原天衣:BAAALAADCgQIBgAAAA==.',['双刀']='双刀小老妹儿:BAAALAADCgQIBAAAAA==.',['变身']='变身汤圆:BAABLAAFFH8SAAMGAAYIqQoMGgAGAQAGAAYIqQoMGgAGAQAEAAII7iBbIACiAAAAAA==.',['古袖']='古袖之沁:BAAALAAECgYICwAAAA==.古袖之瀚:BAAALAAECgYIAwAAAA==.古袖之翼:BAAALAAECgYIDAAAAA==.',['只是']='只是天赋而已:BAAALAADCgYIBgAAAA==.',['可乐']='可乐要加冰:BAAALAADCgEIAQAAAA==.',['可口']='可口香蕉:BAACLAAFFH8MAAIDAAIIHRv6OACjAAADAAIIHRv6OACjAAAsAAQKf0EAAgMACAi2IhkMALECAAMACAi2IhkMALECAAAA.',['右臉']='右臉蒼白:BAAALAAECgUIBQAAAA==.',['叶无']='叶无九:BAAALAADCgIIAgAAAA==.',['叶非']='叶非非:BAAALAADCggICQAAAA==.',['叽哩']='叽哩咕咕:BAABLAAFFH8HAAIEAAMIRCPMEwDYAAAEAAMIRCPMEwDYAAAAAA==.',['吃我']='吃我一拳:BAAALAADCgYIBgAAAA==.',['吉祥']='吉祥果果:BAABLAAFFH8TAAIKAAgIYxG7KACQAQAKAAgIYxG7KACQAQAAAA==.',['吥忍']='吥忍:BAABLAAFFH8TAAMBAAYIhhJgJgCAAQABAAYIPxJgJgCAAQAYAAEIRxMoLABLAAAAAA==.',['吥甜']='吥甜:BAAALAAECgcIBwAAAA==.',['吥萌']='吥萌:BAAALAAFFAIIAgAAAA==.',['听安']='听安:BAAALAAFFAMIBAAAAA==.',['启扬']='启扬:BAAALAAECgQIBAAAAA==.',['吾入']='吾入歧途:BAAALAADCgMIAwAAAA==.',['呦嘻']='呦嘻:BAACLAAFFH8GAAMZAAIIYAgSEAA5AAAZAAIIYAgSEAA5AAAXAAIIwAUtEAAlAAAsAAQKfxQABBkABgioFoAnAFMBABkABgioFoAnAFMBABcABghQDSoYAMkAAAQABggoAge9AJEAAAAA.',['和神']='和神:BAAALAAECgYIBgAAAA==.和神输出:BAAALAAECgYIBgAAAA==.',['咒文']='咒文佩里尔:BAABLAAFFH8cAAIBAAUIhhqrMQBQAQABAAUIhhqrMQBQAQABLAAFFAgIJwAIAEQYAA==.',['咕噜']='咕噜噜:BAAALAAFFAQIBAAAAA==.',['哪吒']='哪吒三太子:BAAALAAFFAIIAgAAAA==.',['商鞅']='商鞅知马力:BAABLAAFFH8RAAIVAAIINRqyMwCZAAAVAAIINRqyMwCZAAAAAA==.',['啪啪']='啪啪干:BAAALAADCggICAAAAA==.',['喵咪']='喵咪萌萌哒:BAAALAAECgYIBgAAAA==.',['嘚路']='嘚路壹:BAAALAADCggICAAAAA==.',['四丶']='四丶叶:BAAALAADCgQIBAAAAA==.',['四十']='四十九:BAAALAAFFAgIAwAAAA==.',['国服']='国服第一蓝牛:BAABLAAFFH8GAAIKAAYI4w76QABDAQAKAAYI4w76QABDAQAAAA==.',['圣光']='圣光永存:BAAALAAECgMIBgAAAA==.圣光的复仇:BAAALAADCgYIBgAAAA==.圣光老司机:BAAALAAFFAQIBAAAAA==.',['圣堂']='圣堂:BAAALAAECgYIBgAAAA==.',['圣灬']='圣灬泷:BAAALAADCgEIAQAAAA==.',['圣骑']='圣骑肆:BAAALAADCgQIBAAAAA==.',['地狱']='地狱岩魂:BAAALAAFFAIIAgAAAA==.',['堕落']='堕落的影:BAAALAAECgEIAQAAAA==.',['壹柱']='壹柱擎天:BAAALAAFFAIIBAAAAA==.',['夏侯']='夏侯蹲女厕:BAAALAAECgYICQAAAA==.',['夜丨']='夜丨冰凉:BAAALAAECgYIDAAAAA==.',['夜光']='夜光裤衩:BAABLAAFFH8HAAIDAAMINApjRwB9AAADAAMINApjRwB9AAAAAA==.',['夜神']='夜神光辉:BAAALAAFFAIIAgAAAA==.',['夜雨']='夜雨风华:BAABLAAFFH8JAAIKAAIIfhZWVACTAAAKAAIIfhZWVACTAAAAAA==.',['大伯']='大伯嗑药:BAAALAAFFAIIBAAAAA==.',['大地']='大地风雷:BAAALAADCgYIBgAAAA==.',['大师']='大师级:BAAALAAFFAIIBAAAAA==.',['大爱']='大爱糖醋鱼:BAACLAAFFH8OAAMRAAIIwQWoGABcAAARAAIIsQWoGABcAAAaAAIIVQJxHQBQAAAsAAQKfx4AAxEACAh/DDo2AGsBABEACAh/DDo2AGsBABoAAQhfAcRSABEAAAAA.',['大神']='大神汤圆:BAABLAAFFH8PAAIVAAIIciBOPQCvAAAVAAIIciBOPQCvAAAAAA==.',['大鹌']='大鹌鹑:BAAALAAECgMIAwAAAA==.',['天地']='天地广山川险:BAAALAAFFAIIAgAAAA==.天地鬼魂:BAAALAAECgcIBwAAAA==.',['天神']='天神灵:BAAALAAFFAIIBAAAAA==.天神礼:BAAALAAECgYIBgAAAA==.',['太寿']='太寿鸠猫:BAAALAAECgYIBgAAAA==.',['奇奇']='奇奇勇士:BAAALAADCgMIAwAAAA==.',['奈奈']='奈奈骑士:BAAALAAECgYIDAAAAA==.',['奈洛']='奈洛归来:BAAALAADCgUIBQAAAA==.',['奈萝']='奈萝:BAAALAAFFAIIAgAAAA==.',['奔翎']='奔翎:BAABLAAFFH8GAAIKAAIInguQmwBAAAAKAAIInguQmwBAAAAAAA==.',['奥丁']='奥丁小蜜:BAAALAADCgIIAgAAAA==.',['奥术']='奥术华尔滋:BAAALAADCgQIBAAAAA==.',['奶油']='奶油冰淇淋:BAAALAADCgcIBwAAAA==.',['奶萨']='奶萨蛮:BAAALAADCgMIAwAAAA==.',['奶香']='奶香小桔子:BAABLAAECn8hAAMbAAgIXhu2JwBMAgAbAAgIXhu2JwBMAgAHAAcIdhxvPADMAQAAAA==.奶香小橘子:BAAALAAECgQIBAABLAAECggIIQAbAF4bAA==.',['如是']='如是我闻:BAAALAAECgYIBAAAAA==.',['妙玉']='妙玉:BAAALAAFFAIIAgAAAA==.',['妞妞']='妞妞你很美:BAAALAADCgYIBgAAAA==.',['妩媚']='妩媚小妖精:BAAALAAFFAYIBAABLAAFFAgIRQAQAI0gAA==.妩媚小颖:BAAALAAFFAMIAwAAAA==.',['姝士']='姝士:BAAALAAECgYIBgAAAA==.',['嫵媚']='嫵媚小法:BAAALAAFFAQIBAAAAA==.',['孙上']='孙上香:BAAALAAFFAMIAwAAAA==.',['孙俪']='孙俪:BAABLAAFFH8KAAIKAAYI8gnqfgBZAAAKAAYI8gnqfgBZAAAAAA==.',['孤独']='孤独圣光:BAAALAAECgYIEgAAAA==.孤独独:BAABLAAECn8UAAIWAAYIuwiBQgDZAAAWAAYIuwiBQgDZAAAAAA==.',['宇哥']='宇哥大魔王:BAABLAAFFH8GAAIcAAMIfwauWAA9AAAcAAMIfwauWAA9AAAAAA==.',['安康']='安康:BAAALAAECgYIBgAAAA==.',['宝贝']='宝贝闹闹:BAABLAAECn8VAAIYAAYI1w7SGQAGAQAYAAYI1w7SGQAGAQAAAA==.',['宝鸡']='宝鸡马尔扎哈:BAAALAAECgUIBQAAAA==.',['寂静']='寂静烟花:BAAALAAFFAEIAgAAAA==.',['寅溟']='寅溟:BAABLAAFFH8IAAIXAAMIzBPGBwBuAAAXAAMIzBPGBwBuAAAAAA==.',['寒冬']='寒冬女王:BAAALAAECgEIAQAAAA==.',['寓清']='寓清于浊:BAABLAAFFH8GAAIDAAIIghHsYQBFAAADAAIIghHsYQBFAAAAAA==.',['小丶']='小丶公举:BAAALAAFFAEIAQAAAA==.',['小小']='小小丫头楠:BAAALAAECgMIAwAAAA==.',['小手']='小手丶炽热:BAAALAADCggICAAAAA==.',['小拳']='小拳拳:BAAALAADCgcIBwAAAA==.',['小旋']='小旋风:BAAALAAECgYIBgAAAA==.',['小月']='小月未央:BAAALAAFFAIIAgAAAA==.',['小毒']='小毒物:BAAALAADCgEIAQAAAA==.',['小灬']='小灬手:BAAALAAECgYIBgAAAA==.',['小猪']='小猪丶佩奇:BAABLAAFFH8FAAIIAAUI8wPmCQDWAAAIAAUI8wPmCQDWAAAAAA==.',['小田']='小田甜:BAAALAAECgYIBgAAAA==.',['小箭']='小箭嗖嗖射:BAAALAAECgUIBQAAAA==.',['小舒']='小舒淇:BAACLAAFFH8KAAIVAAII6xCsTABuAAAVAAII6xCsTABuAAAsAAQKfxYAAhUABgh2FC6hADwBABUABgh2FC6hADwBAAAA.',['小蛋']='小蛋玩玩:BAAALAAECgQIBgAAAA==.',['小迷']='小迷雾:BAAALAADCgYIBgAAAA==.',['小酌']='小酌怡个情:BAABLAAFFH8HAAIbAAMIKhMuKwDNAAAbAAMIKhMuKwDNAAAAAA==.',['小钻']='小钻風:BAABLAAFFH8GAAIUAAYIDhQYCQANAgAUAAYIDhQYCQANAgAAAA==.',['小风']='小风殘月:BAAALAAECgIIAwAAAA==.',['尐灬']='尐灬萌喵:BAABLAAFFH8RAAIVAAYIawUiLwD0AAAVAAYIawUiLwD0AAAAAA==.尐灬萌熊:BAABLAAFFH8UAAIEAAYIERGKFQCKAQAEAAYIERGKFQCKAQAAAA==.',['尘封']='尘封柔情:BAAALAAECgYICAAAAA==.',['就像']='就像来世:BAAALAADCgEIAQAAAA==.',['就跟']='就跟哥闹:BAAALAAECgMIAwAAAA==.',['屁小']='屁小屁:BAAALAAFFAIIAgAAAA==.',['屠日']='屠日者:BAACLAAFFH8GAAIcAAIIBhczNACaAAAcAAIIBhczNACaAAAsAAQKfyEAAhwABwieIfUSAE0CABwABwieIfUSAE0CAAAA.',['左手']='左手右手:BAAALAADCgYIBgAAAA==.',['左氏']='左氏:BAAALAAECgYIBwAAAA==.',['巧楽']='巧楽淄丶:BAAALAADCggICAAAAA==.',['巨无']='巨无霸:BAAALAAFFAQIBAAAAA==.',['布皮']='布皮狼打工人:BAACLAAFFH8QAAIEAAMIhBVlMACoAAAEAAMIhBVlMACoAAAsAAQKfy0AAgQACAibGygcAIYCAAQACAibGygcAIYCAAAA.',['希尔']='希尔瓦拉斯:BAAALAAECgYIDgAAAA==.',['帕拉']='帕拉丁丷:BAAALAAECgUICAAAAA==.',['带头']='带头大爷:BAAALAADCgYIBgAAAA==.',['带弓']='带弓不打猎:BAAALAAECgYIDAAAAA==.',['席瓦']='席瓦娜儿:BAAALAAECgEIAQAAAA==.',['幽冥']='幽冥絶殇:BAAALAADCgEIAQAAAA==.',['幽幽']='幽幽羽诺:BAAALAAECggICwAAAA==.',['庄生']='庄生梦蝶:BAAALAAFFAIIAgAAAA==.',['库库']='库库林白夜:BAAALAAECgQIBQABLAAFFAgIDAANAMMWAA==.',['康养']='康养圣手:BAAALAAFFAIIBAAAAA==.康养大师:BAAALAAFFAIIAgAAAA==.',['张可']='张可以:BAABLAAFFH8HAAIDAAIIahpdKAC5AAADAAIIahpdKAC5AAAAAA==.张可可:BAAALAAFFAIIBAAAAA==.',['张颖']='张颖啊:BAAALAAECggIDwAAAA==.',['张驰']='张驰一心:BAAALAAECgYICwAAAA==.',['影武']='影武者:BAAALAAFFAIIBAAAAA==.',['往哪']='往哪跑:BAAALAAECgYICQAAAA==.',['微醺']='微醺岁月:BAABLAAFFH8KAAIKAAII3h9lSgCaAAAKAAII3h9lSgCaAAAAAA==.',['心醉']='心醉阿萨姆:BAAALAAECggIDgAAAA==.',['忘却']='忘却是种思念:BAAALAAECgYICQAAAA==.',['忘尘']='忘尘无忧:BAABLAAFFH8OAAIbAAMIIwlKMwCbAAAbAAMIIwlKMwCbAAAAAA==.',['忧郁']='忧郁蓝调:BAAALAAECgYIBgAAAA==.',['快速']='快速射击:BAAALAAECgYICAAAAA==.',['怒波']='怒波顿:BAAALAAECgEIAQAAAA==.',['恶女']='恶女置乱:BAACLAAFFH8GAAIUAAIIGw0+TQCPAAAUAAIIGw0+TQCPAAAsAAQKfygAAhQACAjfHBxCAFwCABQACAjfHBxCAFwCAAAA.',['恶魔']='恶魔灬刃:BAAALAAECggICAAAAA==.',['悠小']='悠小柒:BAACLAAFFH8GAAIKAAII2xZThwBKAAAKAAII2xZThwBKAAAsAAQKfxQAAwoABghoFh6OADIBAAoABghoFh6OADIBAAkABQgWDiB6AO4AAAEsAAUUAwgNAAUAmQ8A.',['悠然']='悠然素梦:BAAALAAECgUIBgAAAA==.',['情义']='情义迅捷:BAAALAAECgIIAwAAAA==.',['慕容']='慕容晓晓:BAACLAAFFH8JAAIdAAIILwVDFgA/AAAdAAIILwVDFgA/AAAsAAQKfyUAAh0ACAheDiIKAHEBAB0ACAheDiIKAHEBAAAA.',['懒小']='懒小二:BAABLAAFFH8GAAIbAAII0gXvRQBfAAAbAAII0gXvRQBfAAAAAA==.懒小屁:BAABLAAECn8YAAIKAAcIkBueWACRAQAKAAcIkBueWACRAQAAAA==.懒小牛:BAAALAAECgMIAwAAAA==.',['我女']='我女儿属蛇:BAAALAAFFAYIAwAAAA==.',['我来']='我来组成凶部:BAAALAAECgEIAQAAAA==.我来组成档部:BAAALAAECgYIEAAAAA==.我来组成鞭部:BAAALAAECgIIAgAAAA==.',['战国']='战国策:BAACLAAFFH8jAAIDAAYIPBdrGwCAAQADAAYIPBdrGwCAAQAsAAQKfyYAAgMACAj5Hx8tAL0CAAMACAj5Hx8tAL0CAAAA.',['户山']='户山香橙:BAAALAAFFAIIAgAAAA==.',['扑腾']='扑腾吧豆包:BAAALAADCgQIBAAAAA==.扑腾扑腾:BAAALAADCgQIBAAAAA==.',['扛不']='扛不住阿:BAAALAAECgYIAwAAAA==.',['抓娃']='抓娃娃:BAAALAAECgUIBgAAAA==.',['拾酒']='拾酒闲客:BAABLAAFFH8JAAIOAAYIKiW6AgATAgAOAAYIKiW6AgATAgAAAA==.',['挽月']='挽月破风尘:BAABLAAFFH8IAAIPAAQIsAo7UgDOAAAPAAQIsAo7UgDOAAABLAAFFAgIEQAeAIgVAA==.',['挽风']='挽风:BAABLAAECn8VAAIDAAgI5x/FIgDnAgADAAgI5x/FIgDnAgAAAA==.',['放光']='放光:BAAALAAECgYIBgAAAA==.',['放开']='放开那个宝箱:BAABLAAFFH8GAAMDAAYI/BNZNwDGAAADAAMI3BpZNwDGAAALAAMItQ0oHQC9AAAAAA==.',['文宣']='文宣舞斗:BAAALAADCggICAAAAA==.',['文盲']='文盲小法:BAABLAAECn8jAAIIAAcI9RJqGgBPAQAIAAcI9RJqGgBPAQAAAA==.',['文魁']='文魁:BAAALAADCggICAAAAA==.',['斑尼']='斑尼迪克:BAACLAAFFH8LAAMNAAIIuQlDYgB1AAANAAIIuQlDYgB1AAAIAAEIlQJkIwAtAAAsAAQKfyMAAw0ABwhyGWYlAI4BAA0ABwjhFGYlAI4BAAgABwj0DYFBAGoBAAAA.',['断了']='断了滴弦:BAAALAAFFAIIBAAAAA==.',['方尖']='方尖碑:BAAALAAECgIIAgAAAA==.',['施主']='施主请自重:BAAALAAECgYIDAAAAA==.',['施华']='施华洛:BAAALAAECgMIBQAAAA==.',['施恶']='施恶:BAAALAAFFAIIBAAAAA==.',['旅行']='旅行雨蛙:BAAALAAECgcIEAAAAA==.',['无丶']='无丶情:BAACLAAFFH8oAAMPAAYIZheaIwCmAQAPAAYIZheaIwCmAQAQAAMIqxD4CgCnAAAsAAQKfxYABA8ABgj1FzZQAFQBAA8ABgj5FjZQAFQBABAABAgsGhk1ACkBAB4AAQgOCww4AAAAAAAA.',['无冕']='无冕无赦:BAAALAAECgYIBgAAAA==.',['无明']='无明长夜:BAAALAAECgYIAwAAAA==.',['无问']='无问西东:BAAALAAECggICAAAAA==.',['日帷']='日帷睿:BAAALAAECgYIBgAAAA==.',['日琟']='日琟睿:BAAALAAECgEIAQAAAA==.',['星坠']='星坠了无痕:BAABLAAECn8VAAIbAAYIPw5vcQAnAQAbAAYIPw5vcQAnAQAAAA==.',['星小']='星小星:BAAALAAECgIIAgAAAA==.',['星月']='星月靈:BAABLAAECn8kAAIGAAcIuR3LIgBOAgAGAAcIuR3LIgBOAgAAAA==.',['春思']='春思秋愁:BAAALAAECgYIBgAAAA==.',['是我']='是我冒犯了:BAAALAADCggICQAAAA==.',['晓风']='晓风残夜:BAAALAAECgIIBAAAAA==.晓风残樂:BAAALAADCgYIBgAAAA==.',['晚枫']='晚枫落叶:BAAALAAECggIDAAAAA==.',['晚街']='晚街丨听风:BAACLAAFFH8YAAIBAAUItxDpOQAjAQABAAUItxDpOQAjAQAsAAQKf0MABAEACAhaHUsTAEkCAAEACAi7HEsTAEkCAB8ABAjqGboKANUAABgAAQgkCOKfACoAAAAA.',['景天']='景天:BAAALAAECgIIAgAAAA==.',['暗兽']='暗兽战:BAAALAAECgMIAwAAAA==.',['暗夜']='暗夜零:BAAALAAECgYIEQAAAA==.',['暗暗']='暗暗汤圆:BAABLAAFFH8KAAIUAAYIOAwAKgBDAQAUAAYIOAwAKgBDAQAAAA==.',['暗言']='暗言:BAACLAAFFH86AAINAAgIXyL2AQDgAgANAAgIXyL2AQDgAgAsAAQKfzkAAw0ACAh4I0gbAOYCAA0ACAh4I0gbAOYCAAgABwjkFPc5AIwBAAAA.',['暮光']='暮光华尔滋:BAAALAADCgQICQAAAA==.',['暮雨']='暮雨聆风:BAAALAAECgYIBgAAAA==.',['暴风']='暴风猎手:BAAALAADCgIIAgAAAA==.',['曉丶']='曉丶回龍馭:BAAALAAECgMIAwAAAA==.',['月守']='月守:BAAALAAECgYIBwAAAA==.',['月影']='月影风吹:BAAALAAFFAQIAQAAAA==.',['有尸']='有尸必有德:BAAALAAFFAIIAgAAAA==.',['末日']='末日星辰:BAABLAAFFH8IAAIVAAIIeAqvaABSAAAVAAIIeAqvaABSAAAAAA==.',['杀姐']='杀姐姐:BAAALAADCgIIAgAAAA==.',['杀戒']='杀戒只影:BAAALAAECgYIDAAAAA==.',['李不']='李不空:BAAALAADCgIIAgAAAA==.',['李云']='李云鹤:BAAALAAECgUICQAAAA==.',['李野']='李野狼:BAAALAAECgYIDwAAAA==.',['来来']='来来:BAAALAADCgMIAwAAAA==.',['杰森']='杰森波恩:BAAALAAECgIIAgAAAA==.',['枫千']='枫千雪:BAAALAAFFAIIBAABLAAFFAgIAQAgAAAAAA==.',['柒幽']='柒幽:BAAALAAECgUIBQAAAA==.',['柚子']='柚子柚子丶:BAAALAAECgYICAAAAA==.',['柠蒙']='柠蒙:BAACLAAFFH8IAAINAAMIdhOtRACQAAANAAMIdhOtRACQAAAsAAQKfxsAAg0ABwgSHgYSACACAA0ABwgSHgYSACACAAAA.',['桔子']='桔子橘子丶:BAAALAADCgIIAgAAAA==.',['桖銫']='桖銫殀姬:BAAALAAECgEIAQAAAA==.',['梅染']='梅染:BAAALAAFFAIIAgAAAA==.',['梦梦']='梦梦想想:BAAALAAECgYICAAAAA==.',['森之']='森之勇者:BAAALAADCgUIBQAAAA==.',['樱羽']='樱羽艾玛:BAABLAAFFH8KAAMEAAYI7QxKDAA1AQAEAAUItwxKDAA1AQAGAAEIvAgWLABNAAABLAAFFAgICAAGAA4YAA==.',['欲望']='欲望格斗:BAAALAAECgUICgAAAA==.',['欲罢']='欲罢:BAAALAAFFAIIAgAAAA==.',['止水']='止水湖畔:BAAALAAFFAIIAgAAAA==.',['正义']='正义的化身:BAAALAAFFAEIAQAAAA==.',['死亡']='死亡之影:BAAALAADCgcIBwAAAA==.死亡华尔滋:BAAALAADCgUIEAAAAA==.死亡比亚迪:BAAALAADCggICAAAAA==.',['死神']='死神终结者:BAAALAADCgEIAQAAAA==.',['死骑']='死骑士暗:BAAALAAECgcICAAAAA==.',['毫无']='毫无美感:BAABLAAECn8UAAMTAAYIZQ7tRQD3AAATAAYItA3tRQD3AAAhAAUIFAyrDgDNAAAAAA==.',['氰灬']='氰灬岚:BAACLAAFFH8NAAMFAAMImQ86EQCkAAAFAAMImQ86EQCkAAARAAIIpwPUFwBqAAAsAAQKfywAAwUACAhtFJsdAMUBAAUABwg4FZsdAMUBABEACAh7CgA1AHIBAAAA.',['水中']='水中的风筝:BAAALAADCgIIAgAAAA==.',['水墨']='水墨云烟:BAAALAAFFAIIBAAAAA==.',['汀香']='汀香水榭:BAAALAAFFAIIAgAAAA==.',['沐乙']='沐乙:BAAALAAFFAYIAQAAAA==.',['沙提']='沙提拉:BAAALAAECgYIBgAAAA==.',['法宝']='法宝:BAAALAAECgQIBAAAAA==.',['波加']='波加查丶:BAAALAAECgYIBgAAAA==.',['泯灭']='泯灭之光:BAAALAAFFAIIAgAAAA==.',['泰疯']='泰疯:BAAALAAECgcIDAAAAA==.',['洋蛋']='洋蛋蛋:BAAALAAECgYIBwAAAA==.',['洛星']='洛星辰:BAAALAAECgUIBwAAAA==.',['洛轩']='洛轩丶祺:BAACLAAFFH8gAAINAAYI0BQxJgB8AQANAAYI0BQxJgB8AQAsAAQKfxcAAg0ACAgsFL9jANoBAA0ACAgsFL9jANoBAAAA.',['洞庭']='洞庭白开水:BAAALAAECgYIBwAAAA==.',['浩劫']='浩劫华尔滋:BAAALAADCgIIAgAAAA==.',['浩彬']='浩彬雅:BAAALAAECgYICwAAAA==.',['浮生']='浮生半日闲:BAAALAAECgQIBQAAAA==.',['海藻']='海藻脑袋:BAAALAAFFAIIAgAAAA==.',['涅槃']='涅槃丶兰刺:BAABLAAFFH8HAAIEAAIIfQxvOQBmAAAEAAIIfQxvOQBmAAAAAA==.',['清风']='清风环佩:BAAALAAFFAIIAgAAAA==.',['渔赋']='渔赋尔惠再临:BAAALAADCgQIBAAAAA==.',['游戏']='游戏看人性:BAAALAAECgUICAAAAA==.',['湘峰']='湘峰:BAAALAAECgYIDgAAAA==.',['滑翔']='滑翔:BAAALAAECgcIBwAAAA==.',['滕小']='滕小抽:BAAALAAFFAIIAgAAAA==.',['火财']='火财:BAAALAAECgQIBAAAAA==.',['灬不']='灬不服就干灬:BAAALAAECgYICwAAAA==.',['灬生']='灬生死看淡灬:BAAALAAECgYIEwAAAA==.',['灬筱']='灬筱海灬:BAACLAAFFH8IAAIDAAII8Bd8NgClAAADAAII8Bd8NgClAAAsAAQKfxwAAgMACAgeIZ9IAGMCAAMACAgeIZ9IAGMCAAAA.',['灵儿']='灵儿:BAAALAAFFAIIAwAAAA==.',['灵巧']='灵巧儿:BAAALAAECgMIAwAAAA==.',['灵战']='灵战八荒:BAAALAAECgEIAQAAAA==.',['灵自']='灵自灵:BAAALAADCgEIAQAAAA==.',['灵魂']='灵魂灬归宿:BAAALAAFFAIIAgAAAA==.',['炎凉']='炎凉:BAAALAAFFAIIAgABLAAFFAIICAADAPAXAA==.',['热百']='热百搭巧克力:BAABLAAFFH8GAAIPAAIIgwQgjwB4AAAPAAIIgwQgjwB4AAAAAA==.',['焦糖']='焦糖小蛋挞:BAAALAAECgYICwABLAAECggIIQAbAF4bAA==.',['煉獄']='煉獄:BAAALAAECgEIAQAAAA==.',['煌极']='煌极惊天拳:BAAALAAECgYIEAAAAA==.',['煞羽']='煞羽:BAABLAAFFH8IAAIKAAYIGg79PQBNAQAKAAYIGg79PQBNAQAAAA==.',['熊丶']='熊丶熊:BAAALAAECgYIBgAAAA==.',['熊灬']='熊灬样儿:BAAALAAECgYIBwAAAA==.',['燚龖']='燚龖:BAAALAAECgYIBgAAAA==.',['爱别']='爱别离苦:BAAALAAECgYIBwAAAA==.',['爱喝']='爱喝点啤啤:BAAALAAECgYIBgAAAA==.',['牢麦']='牢麦:BAABLAAFFH8fAAINAAgIDhwDCwA0AgANAAgIDhwDCwA0AgAAAA==.',['特效']='特效师:BAAALAADCgcIBwAAAA==.',['特辣']='特辣鸡哥:BAAALAAECgEIAQAAAA==.',['狄野']='狄野千寻:BAAALAADCgYIBgAAAA==.',['狐仙']='狐仙:BAAALAADCgIIAgAAAA==.',['狐狸']='狐狸萨满:BAAALAAECgYIBgAAAA==.',['独瘤']='独瘤:BAAALAAECgYIBgAAAA==.',['狼上']='狼上了羊:BAAALAAECgUIBQAAAA==.',['狼叔']='狼叔杰克曼:BAABLAAFFH8GAAMiAAYIdQAAAAAAAAAGAAMIAAAAAAAAAAAEAAMIywAAAAAAAAAAAA==.',['猎头']='猎头人:BAABLAAFFH8FAAIKAAMIaBOZaACTAAAKAAMIaBOZaACTAAAAAA==.',['玄音']='玄音:BAAALAAFFAEIAQAAAA==.',['王远']='王远山:BAAALAADCgIIAgAAAA==.',['玛雅']='玛雅圣光:BAAALAAFFAIIBAAAAA==.',['琪开']='琪开得胜:BAAALAAECgMIBAAAAA==.',['琳矢']='琳矢弓:BAAALAADCggIEAAAAA==.',['甜甜']='甜甜妙嫣:BAAALAADCgYIBgAAAA==.',['生死']='生死簿:BAAALAADCggICAAAAA==.',['生鱼']='生鱼脆片:BAAALAADCggICAAAAA==.',['男人']='男人的史诗:BAAALAADCggICAAAAA==.',['疃春']='疃春:BAAALAAFFAIIAgAAAA==.',['疾风']='疾风落叶斩:BAAALAAECgYIBgAAAA==.',['白狼']='白狼传说:BAAALAADCgQIBAAAAA==.',['白雪']='白雪皑皑:BAAALAAECgYIBwAAAA==.',['相约']='相约一九九八:BAAALAAFFAIIAgAAAA==.',['看我']='看我眼神:BAABLAAFFH8IAAMPAAIInBpJUwCfAAAPAAIInBpJUwCfAAAeAAEI1Q4vIQAAAAAAAA==.',['真是']='真是帅气:BAAALAADCgEIAQAAAA==.',['真爱']='真爱无悔:BAAALAAECgQIBAAAAA==.',['真神']='真神捞了:BAAALAAECgYICQAAAA==.',['睦月']='睦月:BAAALAAECgYIEgAAAA==.',['破碎']='破碎灵魂:BAABLAAFFH8GAAIBAAYImhz9HwCcAQABAAYImhz9HwCcAQAAAA==.',['社会']='社会你黄毛哥:BAABLAAFFH8MAAIPAAYIpAAZqwAPAAAPAAYIpAAZqwAPAAAAAA==.',['神化']='神化飞翼零:BAABLAAFFH8NAAIIAAMIKg9LDwBpAAAIAAMIKg9LDwBpAAAAAA==.',['神棍']='神棍二代:BAAALAAECgIIAgAAAA==.',['秋雪']='秋雪季节:BAAALAAFFAIIAgAAAA==.',['窝窝']='窝窝糖:BAAALAAFFAIIAgAAAA==.',['等我']='等我一会儿:BAABLAAFFH8FAAIcAAMIRxMaOQCOAAAcAAMIRxMaOQCOAAAAAA==.',['米晓']='米晓:BAAALAAECgYIDwAAAA==.',['糖不']='糖不免费:BAAALAAECgUIBQAAAA==.',['糖门']='糖门秘术:BAAALAAECgUIBgAAAA==.',['素士']='素士:BAAALAADCgYIBgAAAA==.',['红火']='红火:BAAALAAECgQIBQAAAA==.',['红钻']='红钻二代:BAAALAADCggICAAAAA==.',['纽约']='纽约龙须面:BAACLAAFFH8aAAIMAAYIxBWwCwBlAQAMAAYIxBWwCwBlAQAsAAQKfyUAAgwACAh2HKUXAGYCAAwACAh2HKUXAGYCAAAA.',['绚影']='绚影:BAABLAAFFH8NAAIHAAYIkgskEgBKAQAHAAYIkgskEgBKAQAAAA==.',['缚光']='缚光者拉尔涅:BAAALAAECggICAAAAA==.',['罐头']='罐头:BAABLAAFFH8GAAIDAAYIRgBShgANAAADAAYIRgBShgANAAAAAA==.',['罗峰']='罗峰:BAAALAAECgUIBQAAAA==.',['羊羊']='羊羊灬羊羊:BAACLAAFFH8OAAITAAIIDAZpNgB5AAATAAIIDAZpNgB5AAAsAAQKfy4AAhMABwjmFOBQAMcBABMABwjmFOBQAMcBAAAA.',['羽墨']='羽墨凌霄:BAAALAAECgYIDAAAAA==.',['羽心']='羽心:BAAALAAFFAIIBAAAAA==.',['翻滚']='翻滚的肉墩:BAAALAADCgEIAQAAAA==.翻滚的肉蛋:BAAALAADCgQIBAAAAA==.',['翼龙']='翼龙:BAAALAADCgYIBgAAAA==.',['老丶']='老丶中医:BAAALAAECgIIAgAAAA==.',['老鸭']='老鸭:BAABLAAFFH8GAAIbAAIIvBIbOQB8AAAbAAIIvBIbOQB8AAAAAA==.',['耐瑟']='耐瑟瑞尔:BAACLAAFFH8VAAINAAYIugi/MgA1AQANAAYIugi/MgA1AQAsAAQKfyYAAwgACAh4ECg7AIYBAA0ACAhqDAR0ALABAAgABwjwDyg7AIYBAAAA.',['肉灬']='肉灬呼呼:BAAALAAECgIIAgAAAA==.',['背对']='背对圣光:BAAALAAECgYICwAAAA==.',['自然']='自然之心:BAAALAAFFAIIAgAAAA==.',['自由']='自由圣光:BAABLAAFFH8FAAIDAAIIvxkyNQCmAAADAAIIvxkyNQCmAAAAAA==.',['舍命']='舍命不舍财:BAAALAAECgcIBwAAAA==.',['艾倩']='艾倩倩:BAACLAAFFH8MAAIWAAII0g69EgBoAAAWAAII0g69EgBoAAAsAAQKfxwAAhYACAhuIZ4MAJICABYACAhuIZ4MAJICAAAA.',['芥末']='芥末汤圆:BAABLAAFFH8GAAILAAIInw8JJwBvAAALAAIInw8JJwBvAAAAAA==.',['芳名']='芳名千载何用:BAAALAADCgEIAQAAAA==.',['芳心']='芳心纵火犯灬:BAAALAAECgUIBQAAAA==.',['苍狼']='苍狼幽鬼:BAAALAADCgMIBAAAAA==.',['英雄']='英雄説再见:BAAALAAFFAIIBAAAAA==.',['荒野']='荒野雄狮:BAABLAAFFH8GAAIKAAYIMBdpNABqAQAKAAYIMBdpNABqAQAAAA==.',['荷鲁']='荷鲁斯之眼:BAAALAAECgUICgAAAA==.',['菲尔']='菲尔德:BAABLAAFFH8RAAMaAAYIZgWvEwAMAQAaAAYIZgWvEwAMAQAFAAIIugqvFgBmAAAAAA==.',['菲米']='菲米斯战锤:BAABLAAECn8fAAMKAAcI3Bn7TgCnAQAKAAYIThz7TgCnAQAJAAcITQ60XwA/AQAAAA==.',['萌箭']='萌箭也骚气:BAAALAAFFAIIAgAAAA==.',['萨贝']='萨贝宁:BAABLAAECn8iAAIVAAgIXAwRlgBSAQAVAAgIXAwRlgBSAQAAAA==.',['萬人']='萬人敵:BAAALAADCggICAAAAA==.',['落叶']='落叶疾风斩:BAAALAAECgYIBgAAAA==.',['葡萄']='葡萄:BAAALAAFFAIIAgAAAA==.',['葬夜']='葬夜噬魂:BAAALAAFFAIIBAAAAA==.',['葬爱']='葬爱俊少:BAAALAAECgQIBAAAAA==.',['蓝绿']='蓝绿红绿蓝:BAAALAAECgYICwAAAA==.',['蓝色']='蓝色季风:BAAALAAECgEIAQAAAA==.',['蕾姆']='蕾姆我老婆:BAABLAAFFH8GAAIUAAYIEQe9DwCvAQAUAAYIEQe9DwCvAQAAAA==.',['虎虎']='虎虎是胡胡:BAAALAAECgQIBAAAAA==.',['虚灵']='虚灵华尔滋:BAAALAADCgYIBgAAAA==.',['虚空']='虚空灬之遗:BAAALAAECggICAAAAA==.',['蛇宝']='蛇宝儿:BAABLAAFFH8IAAIKAAYIwAnqgABUAAAKAAYIwAnqgABUAAAAAA==.',['蜗角']='蜗角虚名:BAAALAAECgYICAAAAA==.',['血与']='血与光荣:BAEBLAAFFH8KAAIcAAIIrA8/PACRAAAcAAIIrA8/PACRAAAAAA==.',['血匕']='血匕丶透心狼:BAAALAADCgYIBgAAAA==.',['血影']='血影圣光:BAAALAADCgIIAgAAAA==.',['行神']='行神如空:BAAALAAECgYIBgAAAA==.',['补妆']='补妆:BAAALAAECgYIBgAAAA==.',['西蒙']='西蒙海椰:BAABLAAFFH8GAAIKAAYIQgtuRAA3AQAKAAYIQgtuRAA3AQAAAA==.',['西门']='西门大官人:BAABLAAFFH8GAAIPAAYIshphHwC3AQAPAAYIshphHwC3AQAAAA==.',['观闲']='观闲弑骑:BAAALAADCgcIBwAAAA==.',['譭丷']='譭丷灭:BAABLAAFFH8GAAIDAAYIlh/lFQCgAQADAAYIlh/lFQCgAQAAAA==.',['记忆']='记忆犹在:BAAALAAFFAMIBAAAAA==.',['该增']='该增肥了吧:BAAALAAFFAIIAgABLAAFFAgIBgALAOIhAA==.',['谁言']='谁言重剑无锋:BAAALAAECgYICAAAAA==.',['谢帝']='谢帝皇铠甲:BAAALAAECgYIBgAAAA==.',['貳寳']='貳寳:BAAALAAFFAIIBAAAAA==.',['贱射']='贱射的爱:BAAALAADCgQIBAAAAA==.',['贼靓']='贼靓的贼:BAAALAAFFAIIAgAAAA==.',['赃薪']='赃薪滥费:BAAALAADCgEIAgAAAA==.',['赚够']='赚够三百万:BAAALAADCgYIBgAAAA==.',['赛亚']='赛亚圣人:BAAALAAFFAIIBAAAAA==.赛亚术师:BAAALAAECgYIBgAAAA==.赛亚潮人:BAAALAAECgIIAgAAAA==.赛亚牛人:BAABLAAFFH8HAAMEAAIIMBSLOQCGAAAEAAIIMBSLOQCGAAAGAAIIXhATMQBAAAAAAA==.赛亚牛妹:BAAALAAFFAIIBAAAAA==.赛亚贼人:BAAALAAFFAIIAgAAAA==.赛亚魔人:BAAALAAFFAIIBAAAAA==.',['赛莉']='赛莉斯冷:BAABLAAFFH8IAAMjAAIIOhAiFwB6AAAjAAIIOhAiFwB6AAADAAII+gYFhAAdAAAAAA==.',['赤言']='赤言:BAAALAAECgIIAgAAAA==.',['软萌']='软萌易推倒:BAAALAADCgIIAgAAAA==.',['轻扬']='轻扬:BAAALAAECgcICwAAAA==.',['轻舞']='轻舞微涩:BAABLAAECn8VAAIDAAYImSGSMwDFAQADAAYImSGSMwDFAQAAAA==.',['辣个']='辣个戦士:BAAALAAFFAIIAgAAAA==.',['迅驰']='迅驰科技:BAAALAAECgYICAAAAA==.',['还有']='还有人寿:BAABLAAFFH8GAAIkAAIIPg11BQBFAAAkAAIIPg11BQBFAAAAAA==.',['迪丽']='迪丽热九:BAABLAAFFH8HAAIIAAYI9gIiDgB6AAAIAAYI9gIiDgB6AAAAAA==.',['迷你']='迷你:BAAALAADCgEIAQAAAA==.',['追魂']='追魂夺命锤:BAAALAADCggICQAAAA==.',['透明']='透明火焰:BAAALAAECgQIBAAAAA==.',['遗忘']='遗忘丶之名:BAAALAADCgIIAgAAAA==.',['邓丶']='邓丶小可:BAAALAAECgUIBQAAAA==.',['酷酷']='酷酷就是炫:BAAALAADCgQIBAAAAA==.',['醉卧']='醉卧怅然:BAAALAADCgUIBQAAAA==.',['钢锁']='钢锁:BAAALAAECgYIBgAAAA==.',['铁腿']='铁腿水上漂:BAAALAAECgYIBgAAAA==.',['锦州']='锦州奥利奥:BAAALAAECgMIAwAAAA==.',['长春']='长春彭于晏:BAAALAAECgYIBgAAAA==.',['门神']='门神:BAAALAAECgUIAgAAAA==.',['阿廖']='阿廖沙:BAABLAAFFH8FAAIOAAUI2wGpCwCUAAAOAAUI2wGpCwCUAAAAAA==.',['阿黑']='阿黑颜:BAAALAAECgEIAQAAAA==.',['雨季']='雨季依然在:BAAALAADCggICAAAAA==.',['雪之']='雪之夕冰咖啡:BAAALAAECgIIAgAAAA==.',['雷寻']='雷寻欢:BAAALAAECgEIAQAAAA==.',['雷幻']='雷幻:BAAALAADCgYIBgAAAA==.',['雷鸣']='雷鸣八卦:BAAALAAECgUICQAAAA==.',['雾丶']='雾丶风暴烈炮:BAAALAAECgMIAwAAAA==.',['露往']='露往霜来:BAAALAADCggICAAAAA==.',['霸占']='霸占你的人:BAAALAADCgEIAQAAAA==.',['霸王']='霸王华尔滋:BAAALAADCgYICgAAAA==.',['靈魂']='靈魂依托:BAAALAAECgcIBwAAAA==.',['青岚']='青岚乄憶:BAABLAAFFH8MAAIPAAUIqg/1RQAiAQAPAAUIqg/1RQAiAQAAAA==.',['青莲']='青莲剑歌:BAABLAAFFH8SAAMBAAUI5hMKOgAiAQABAAUI5hMKOgAiAQAYAAEInxenKgBNAAAAAA==.',['静默']='静默雷暴:BAAALAAECggIDgAAAA==.',['風止']='風止:BAAALAAFFAIIAgAAAA==.',['风之']='风之第七章:BAABLAAFFH8nAAIIAAYIRBh0BACLAQAIAAYIRBh0BACLAQAAAA==.',['风雷']='风雷旌旗:BAAALAADCgQIBAAAAA==.',['风霞']='风霞之光:BAAALAADCgYIBgAAAA==.',['飒冉']='飒冉:BAAALAADCgcIBwABLAAFFAIICAADAPAXAA==.',['飞伐']='飞伐伐:BAAALAAECgQIBAAAAA==.',['飞越']='飞越地平线:BAAALAAECgYIBgAAAA==.',['香吉']='香吉:BAAALAAECgMIAwAAAA==.',['馥薇']='馥薇:BAABLAAFFH8GAAILAAII+gUMKwBhAAALAAII+gUMKwBhAAAAAA==.',['马小']='马小萨萨:BAABLAAFFH8IAAIVAAIIIwNKdABEAAAVAAIIIwNKdABEAAAAAA==.',['马思']='马思唯维豆奶:BAAALAAFFAIIAgAAAA==.',['驭龙']='驭龙行者:BAAALAAECgYIBgAAAA==.',['魂兮']='魂兮归来:BAAALAADCgYIBgAAAA==.',['魔主']='魔主化神:BAAALAADCgYICQAAAA==.',['魔力']='魔力汤圆:BAABLAAFFH8IAAINAAIIihavRwCYAAANAAIIihavRwCYAAAAAA==.',['鱼泡']='鱼泡泡的主人:BAABLAAECn8SAAIKAAYI5x+ePwDNAQAKAAYI5x+ePwDNAQAAAA==.',['鱼非']='鱼非鱼:BAAALAADCgcIBwAAAA==.',['鲁辣']='鲁辣辣:BAABLAAFFH8GAAIIAAIIRhECFQCDAAAIAAIIRhECFQCDAAAAAA==.',['鸭我']='鸭我闪电链:BAACLAAFFH8OAAITAAMIzgN+PABUAAATAAMIzgN+PABUAAAsAAQKfyAAAxMACAiZDU9TAL8BABMACAiZDU9TAL8BABUAAwgLBNkzAU0AAAAA.',['麻汁']='麻汁牛肉饼:BAAALAADCgQIBAAAAA==.',['黎明']='黎明灬圣光:BAEBLAAFFH8iAAIDAAYIUBxNEQC8AQADAAYIUBxNEQC8AQAAAA==.',['黑夜']='黑夜骑士:BAAALAAECgYIBgAAAA==.',['黑火']='黑火:BAAALAAFFAIIAwAAAA==.',['黑石']='黑石华尔滋:BAAALAADCgQIBAAAAA==.',['黑神']='黑神话丶雷军:BAABLAAFFH8HAAIVAAMIWQgLUwB1AAAVAAMIWQgLUwB1AAAAAA==.',['黯沐']='黯沐丶:BAABLAAECn8VAAIJAAgIkByAGwCIAgAJAAgIkByAGwCIAgAAAA==.',['龙烈']='龙烈:BAAALAAECgYIBgAAAA==.',['龙组']='龙组:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end