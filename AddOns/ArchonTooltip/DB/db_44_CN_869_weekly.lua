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
 local lookup = {'Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Protection','Druid-Restoration','Druid-Balance','Warlock-Destruction','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Shaman-Restoration','DemonHunter-Havoc','Priest-Holy','Warrior-Protection','Warrior-Fury','Hunter-Marksmanship','DemonHunter-Vengeance','DeathKnight-Frost','Monk-Windwalker','Monk-Brewmaster','DeathKnight-Unholy','Evoker-Preservation','Unknown-Unknown','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','Druid-Guardian','Priest-Discipline','Paladin-Holy','Rogue-Outlaw','Warrior-Arms','Monk-Mistweaver','Hunter-Survival',}; local provider = {region='CN',realm='阿格拉玛',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ad='Adnachiel:BAACLAAFFH8GAAMBAAIICA9QFQCCAAABAAIICA9QFQCCAAACAAIIjwayZwAzAAAsAAQKfyEAAwIABwgBFtkjAJcBAAEABwgQEuwzAKgBAAIABwisFdkjAJcBAAAA.',Al='Alberta:BAACLAAFFH8gAAMDAAUIIBcJNQDjAAADAAQIbBgJNQDjAAAEAAEI8RH+FwBAAAAsAAQKfyMAAwMACAhJHQIuALoCAAMACAhJHQIuALoCAAQAAghYHOBcAKYAAAAA.All:BAACLAAFFH8cAAMFAAYI4RFlGAByAQAFAAYI4RFlGAByAQAGAAQI7ghNIgCpAAAsAAQKfyYAAwYABwhrGcAxAPgBAAYABwhrGcAxAPgBAAUABgi1G1g/AOIBAAEsAAUUBgg2AAcAfB0A.',Ar='Artz:BAABLAAECn8WAAIIAAgIDCS4HwDbAgAIAAgIDCS4HwDbAgAAAA==.',Av='Avocado:BAABLAAFFH88AAMJAAYIgh2LBgBqAQAKAAYI0htGBQCqAQAJAAQIJx6LBgBqAQAAAA==.Avocadosm:BAABLAAFFH8RAAILAAUIUAzpMQDoAAALAAUIUAzpMQDoAAAAAA==.',Bi='Biubiubiupa:BAAALAAFFAIIAgAAAA==.',Br='Brantmolly:BAAALAADCggICQAAAA==.',Bu='Bujo:BAABLAAFFH8GAAIDAAYIXRZ3FQCnAQADAAYIXRZ3FQCnAQAAAA==.',By='Byexi:BAAALAAECggICAAAAA==.',Ca='Calvados:BAAALAAFFAMIAgAAAA==.Cathy:BAAALAAECgIIAgAAAA==.',Da='Dança:BAABLAAFFH8NAAIMAAMIDRLTHQDzAAAMAAMIDRLTHQDzAAAAAA==.Darkillnight:BAAALAAECgYIBgAAAA==.Dash:BAAALAAECgMIAwAAAA==.',El='Elevenoo:BAABLAAECn8YAAINAAcI3CDwIQBuAgANAAcI3CDwIQBuAgAAAA==.',Fr='Franco:BAAALAAECgIIAgAAAA==.',Gh='Ghost:BAAALAAFFAIIAgAAAA==.',Ha='Haigobin:BAAALAAFFAIIAwAAAA==.',He='Hearthunter:BAABLAAFFH8kAAIIAAUIIx/TNABuAQAIAAUIIx/TNABuAQAAAA==.',Hi='Hingir:BAABLAAFFH8cAAIBAAYInRhqBACRAQABAAYInRhqBACRAQABLAAFFAYIOgAEANkiAA==.',Ja='Jame:BAABLAAFFH8GAAIHAAYI/gRjHQBHAQAHAAYI/gRjHQBHAQAAAA==.',La='Layn:BAAALAAECgMIAwAAAA==.',Le='Leegodamn:BAAALAAECgUIBQAAAA==.',Li='Lisa:BAACLAAFFH8TAAMBAAMIBRyFEwCHAAACAAMIBRxGQgChAAABAAII1Q+FEwCHAAAsAAQKfxYAAwEABwjaHm0ZAE8CAAEABwjgHW0ZAE8CAAIAAwiNIixNANMAAAAA.',Lu='Luxanna:BAABLAAFFH8FAAMBAAII6Qs9HAA5AAACAAIIGAITawBGAAABAAII6Qs9HAA5AAABLAAFFAYIHAACAEsQAA==.',Ma='Macauley:BAAALAAECgYICQAAAA==.Mangogo:BAAALAAECgIIAgAAAA==.',Mo='Moteed:BAAALAAECggICAAAAA==.',Ne='Neuro:BAAALAAFFAMIAwAAAA==.',Pe='Penny:BAABLAAFFH8MAAMOAAIIJBv7GQCRAAAOAAIIKxn7GQCRAAAPAAIIBBjrQwBSAAABLAAFFAMIEwALAAUdAA==.',Ph='Phenix:BAAALAAFFAIIAgAAAA==.Phoebee:BAABLAAECn8aAAIIAAcIuRPWbgBoAQAIAAcIuRPWbgBoAQAAAA==.',Pu='Pupu:BAACLAAFFH8lAAIIAAYICBvDJwCZAQAIAAYICBvDJwCZAQAsAAQKfxYAAwgABgjlIhZBAMsBAAgABgjlIhZBAMsBABAAAQjNAAnZAAgAAAEsAAUUBgg2AAcAfB0A.',Sa='Saber:BAAALAAFFAIIAgAAAA==.',Sh='Shadowstorm:BAAALAAECgUIBwAAAA==.',So='Sona:BAACLAAFFH82AAIHAAYIfB0HFwCgAQAHAAYIfB0HFwCgAQAsAAQKfyQAAgcACAiuHJIwAHoCAAcACAiuHJIwAHoCAAAA.Sorrymaker:BAAALAAFFAIIAgAAAA==.',Th='Thanos:BAAALAAECgQIBAAAAA==.',Ve='Veeshan:BAAALAAECgcIDQAAAA==.Verchiel:BAAALAAECgYIBgAAAA==.',Xh='Xhuger:BAACLAAFFH8dAAIJAAYInRPlCQB8AQAJAAYInRPlCQB8AQAsAAQKfy8AAgkABwiHINgSAIYCAAkABwiHINgSAIYCAAAA.',Ya='Yagamisa:BAAALAAECgMIBAAAAA==.',Yi='Yik:BAAALAADCgYIBgAAAA==.',Za='Zaozaoaoao:BAABLAAFFH8bAAMCAAYIPiJDGgCHAQACAAYIByJDGgCHAQABAAIIziFOEABhAAAAAA==.',['一拳']='一拳哥小迷弟:BAAALAAECgEIAQAAAA==.',['一种']='一种感觉:BAAALAAECgQIBAAAAA==.',['一箭']='一箭走天下:BAAALAAECgYICQAAAA==.',['一魔']='一魔:BAAALAAECgUIBQAAAA==.一魔丨:BAAALAAECgIIAgAAAA==.',['七森']='七森莉莉:BAAALAAFFAIIBAAAAA==.',['上帝']='上帝荣光:BAAALAAECgYIDwAAAA==.',['不屈']='不屈南风丶:BAAALAAECgMIAwAAAA==.',['不是']='不是我开的怪:BAAALAADCgcIBwAAAA==.',['东方']='东方邪术:BAAALAAECgYIBgAAAA==.',['丰胸']='丰胸胶囊:BAAALAAECgMIAgAAAA==.',['丶仟']='丶仟年杀:BAAALAAECgIIAgAAAA==.',['丶邦']='丶邦桑迪丶:BAAALAADCggICAAAAA==.',['乂紫']='乂紫伊乂:BAACLAAFFH8IAAIMAAIIpgI+bgAtAAAMAAIIpgI+bgAtAAAsAAQKfzkAAwwABwgdDWe3AGYBAAwABwjoDGe3AGYBABEABgiLB3ggAJsAAAAA.',['予你']='予你:BAAALAAECgMIAwAAAA==.',['云不']='云不归:BAAALAAECggIEAAAAA==.',['五虎']='五虎将:BAAALAAECgYIDAAAAA==.',['井中']='井中月:BAABLAAFFH8IAAMBAAIIfhc5FwBBAAABAAIIfhc5FwBBAAACAAIIrgXzZwAzAAAAAA==.',['井川']='井川里予:BAABLAAFFH8MAAIIAAYINBLgOgBbAQAIAAYINBLgOgBbAQAAAA==.',['亚伦']='亚伦卡特:BAAALAAECgYIBwAAAA==.',['人世']='人世无常:BAAALAAECgYIDQAAAA==.',['人帅']='人帅刀快:BAAALAAECgYIBwAAAA==.',['从小']='从小听劝:BAABLAAECn8aAAISAAcI0x2eGwAVAgASAAcI0x2eGwAVAgAAAA==.',['从此']='从此不空车:BAAALAADCgMIAwAAAA==.',['仙灵']='仙灵:BAACLAAFFH8eAAITAAYI5B0nBQC6AQATAAYI5B0nBQC6AQAsAAQKfyIAAxMACAgXIC4RAJoCABMACAgXIC4RAJoCABQABghZFzkgAJQBAAAA.',['代达']='代达罗斯之殇:BAAALAAECggIEwAAAA==.',['伊利']='伊利蛋糕:BAAALAADCggICAAAAA==.',['伊洛']='伊洛尔:BAAALAADCgEIAQAAAA==.',['似雨']='似雨若雾:BAAALAAFFAIIBAAAAA==.',['但你']='但你先别急:BAAALAAECggICAAAAA==.',['何必']='何必当真:BAAALAADCggICAAAAA==.',['佚丶']='佚丶名:BAAALAAECgYIEQAAAA==.',['你有']='你有罪:BAAALAAFFAIIAgAAAA==.',['你的']='你的前女友:BAAALAAFFAIIAgAAAA==.',['做死']='做死:BAACLAAFFH8iAAIOAAYIkR1pBgCnAQAOAAYIkR1pBgCnAQAsAAQKfxwAAg4ABghKHmcsAOYBAA4ABghKHmcsAOYBAAAA.做死大人:BAAALAADCggICAAAAA==.',['偶做']='偶做前堂客:BAAALAADCgUIBQAAAA==.',['偶尔']='偶尔非偶然:BAAALAAECgYICQAAAA==.',['光铸']='光铸德莱妮:BAAALAAECgIIAgAAAA==.',['兔儿']='兔儿兜:BAAALAAECgEIAQAAAA==.',['再诞']='再诞之翼:BAAALAAECgYIEgAAAA==.',['冬至']='冬至:BAAALAAECgYIDAAAAA==.',['冰凉']='冰凉:BAACLAAFFH8JAAISAAII2Bt4RQCrAAASAAII2Bt4RQCrAAAsAAQKfxEAAxIABgjwIY5rAB8CABIABgiAH45rAB8CABUABQj7Hm0kAJoBAAAA.',['冻干']='冻干投射机:BAAALAAECgYIDwAAAA==.',['凶灵']='凶灵再现:BAAALAAFFAIIAgAAAA==.',['刀脚']='刀脚发麻:BAABLAAFFH8IAAIWAAgIPA+0BgAUAgAWAAgIPA+0BgAUAgAAAA==.',['刑裁']='刑裁者:BAAALAAECgMIAwAAAA==.',['刘在']='刘在石的微笑:BAAALAAECgYIDAAAAA==.',['剑心']='剑心哥:BAAALAADCgUIBQAAAA==.剑心是牛:BAABLAAFFH8aAAIPAAYIlw6THwByAQAPAAYIlw6THwByAQABLAAFFAcIMQAMANUaAA==.',['加萝']='加萝娜:BAAALAAECgYIBgAAAA==.',['北冥']='北冥棂:BAACLAAFFH8QAAISAAMIHhwbTQCjAAASAAMIHhwbTQCjAAAsAAQKfxQAAhIABwhUF06UANkBABIABwhUF06UANkBAAEsAAUUBggeABMA5B0A.',['北风']='北风使徒:BAAALAADCgcIBwABLAADCggICQAXAAAAAA==.',['十字']='十字军凌叶:BAAALAAECgYIDwAAAA==.',['半只']='半只菜鸡:BAACLAAFFH8MAAIDAAYISxWsIABqAQADAAYISxWsIABqAQAsAAQKfx0AAgMABwhfIPAxAKoCAAMABwhfIPAxAKoCAAAA.',['卡德']='卡德减:BAABLAAFFH8PAAMBAAMILBt/BQD0AAABAAMILBt/BQD0AAACAAIIMxkgPACkAAAAAA==.',['去他']='去他骂的奥丁:BAAALAAECgMIAwAAAA==.',['叁零']='叁零:BAACLAAFFH8KAAISAAYIpiSFFgDmAQASAAYIpiSFFgDmAQAsAAQKfxUAAhIABgi0H1o7AJIBABIABgi0H1o7AJIBAAAA.',['古明']='古明地丶觉:BAAALAAECgYICgAAAA==.',['可可']='可可星冰乐:BAAALAAECgEIAQAAAA==.',['吕凝']='吕凝蝶:BAAALAAECgIIAgAAAA==.',['听说']='听说奶萨很强:BAAALAAFFAIIAgAAAA==.',['吳下']='吳下阿蒙:BAABLAAFFH8fAAIDAAYIgCBQBwDwAQADAAYIgCBQBwDwAQAAAA==.',['吴下']='吴下阿梦:BAABLAAFFH8IAAIFAAIIkQlnPwBgAAAFAAIIkQlnPwBgAAABLAAFFAYIHwADAIAgAA==.',['吾辈']='吾辈大宗师:BAAALAAECgYICQAAAA==.吾辈楷模:BAAALAAECgYIEQAAAA==.',['周防']='周防尊:BAAALAAECgYIDwAAAA==.',['命运']='命运多舛:BAAALAAECgYIDgAAAA==.',['咕嘟']='咕嘟拜哇:BAAALAADCgMIAQAAAA==.',['哈啤']='哈啤超清爽:BAABLAAFFH8NAAIYAAgIEAHsQQBHAAAYAAgIEAHsQQBHAAAAAA==.',['唐克']='唐克八佰:BAAALAAECgYIBgAAAA==.',['喵弎']='喵弎菇凉:BAACLAAFFH8GAAICAAYI9g04MQBAAQACAAYI9g04MQBAAQAsAAQKfxsAAgEABwh5EmMyAK8BAAEABwh5EmMyAK8BAAAA.',['喵星']='喵星达人:BAABLAAFFH8GAAIMAAYIywCATQBNAAAMAAYIywCATQBNAAAAAA==.',['嗨小']='嗨小萨:BAAALAADCgYICQAAAA==.',['噩梦']='噩梦藤:BAAALAAECgQIBAAAAA==.',['囧小']='囧小寶:BAABLAAFFH8GAAIHAAYIfRbyLABqAQAHAAYIfRbyLABqAQAAAA==.',['土豆']='土豆涌泉:BAAALAAECgMIAwAAAA==.',['圣光']='圣光照死你:BAAALAAFFAIIAgAAAA==.圣光麦乐鸡:BAACLAAFFH85AAIDAAgIsh7VAgBNAgADAAgIsh7VAgBNAgAsAAQKfzkAAgMACAheJPoTACcDAAMACAheJPoTACcDAAAA.',['塞林']='塞林木寄卖:BAAALAAECgMIAwAAAA==.',['夏夜']='夏夜的烟火:BAABLAAFFH8TAAISAAYIwRjzIAC2AQASAAYIwRjzIAC2AQAAAA==.',['多来']='多来米:BAAALAAECgYIBgAAAA==.',['大板']='大板鲫:BAAALAAECgUIBQAAAA==.',['大酋']='大酋长:BAAALAAECgYIBwAAAA==.',['天河']='天河王嘉尔:BAAALAAECgEIAQAAAA==.',['天空']='天空是深蓝色:BAAALAAFFAIIBAAAAA==.',['奥利']='奥利奥苹果糖:BAAALAADCgYIDAABLAADCggICQAXAAAAAA==.奥利弗奎恩:BAABLAAFFH8bAAMIAAUI5hlnRgA3AQAIAAUI5hlnRgA3AQAQAAII2wQZMABgAAAAAA==.',['奥恩']='奥恩:BAABLAAFFH8KAAISAAMIHwr9aQB1AAASAAMIHwr9aQB1AAAAAA==.',['奶牛']='奶牛宝可梦:BAAALAAECgMIAwAAAA==.',['奶量']='奶量跟不上啦:BAAALAAFFAIIAgAAAA==.',['妇女']='妇女出虚汗:BAABLAAECn8UAAIDAAcIgRaSRACQAQADAAcIgRaSRACQAQAAAA==.',['婵鸣']='婵鸣在呼唤:BAABLAAECn8iAAIDAAcI5g+aYQBEAQADAAcI5g+aYQBEAQAAAA==.',['宁姚']='宁姚:BAABLAAFFH8GAAIBAAIIFBjGDQCZAAABAAIIFBjGDQCZAAAAAA==.',['宁静']='宁静灬至远:BAAALAAECgYICQAAAA==.',['安藤']='安藤樱:BAAALAADCgQIBAAAAA==.',['完整']='完整的鸡蛋壳:BAAALAAFFAMIAwAAAA==.',['宝宝']='宝宝你先上:BAAALAAECgYICQAAAA==.',['寒溏']='寒溏渡剑影:BAAALAAECgYIBgAAAA==.',['小克']='小克拉莫:BAAALAADCggICAAAAA==.',['小猹']='小猹:BAABLAAFFH8MAAICAAMI3BDkMADIAAACAAMI3BDkMADIAAAAAA==.',['小飞']='小飞姬樣:BAACLAAFFH8UAAMQAAYIUBw9CwBBAQAQAAYIUBw9CwBBAQAIAAII7R75jgBHAAAsAAQKfxIAAhAABwgdJAIXAKsCABAABwgdJAIXAKsCAAAA.小飞盾来咯丶:BAACLAAFFH8IAAIEAAII9RUNGgA2AAAEAAII9RUNGgA2AAAsAAQKfxQAAgQABwjpGRgkANwBAAQABwjpGRgkANwBAAAA.',['小鸟']='小鸟游一花:BAACLAAFFH8MAAMPAAIIfhbkNQCYAAAPAAIIfhbkNQCYAAAOAAIIbQt+JQBzAAAsAAQKfxsAAw8ABwiaF/JnAL8BAA8ABwhRF/JnAL8BAA4AAwgYFoGAAIQAAAAA.小鸟游十花:BAAALAAFFAIIBAAAAA==.',['小鹿']='小鹿的保镖:BAAALAAECgYIBgAAAA==.',['巫婆']='巫婆:BAACLAAFFH8IAAIHAAII/wb5agA2AAAHAAII/wb5agA2AAAsAAQKfzIAAgcABwgbFIlpALcBAAcABwgbFIlpALcBAAAA.',['希妹']='希妹妹:BAAALAAECgYIBgAAAA==.',['干涉']='干涉那个小德:BAAALAAECggICAAAAA==.',['开噬']='开噬雪法诗:BAAALAAECgEIAQAAAA==.',['开水']='开水冰不冰:BAABLAAFFH8ZAAIMAAUIOSD0IgB3AQAMAAUIOSD0IgB3AQABLAAFFAYILgAZAGwiAA==.',['张大']='张大翼:BAABLAAFFH8GAAIPAAYIXAaLKAAxAQAPAAYIXAaLKAAxAQAAAA==.',['往事']='往事:BAAALAAECgUIBwAAAA==.',['得意']='得意忘形:BAAALAAECgUIBQAAAA==.',['心之']='心之飞越:BAAALAAECgcICwAAAA==.',['心若']='心若猛虎:BAAALAAECgYIDAAAAA==.',['忄曼']='忄曼节奏:BAAALAADCgYICQAAAA==.',['快乐']='快乐的灌注:BAABLAAFFH8GAAMNAAYIRRUFDACPAQANAAUIDxYFDACPAQAaAAEIfwdLLABJAAAAAA==.',['快奶']='快奶我一口:BAAALAAFFAIIAgAAAA==.',['急速']='急速冷却:BAAALAADCgYIBgAAAA==.',['恐惧']='恐惧天龙:BAAALAAFFAIIBAAAAA==.恐惧脚步:BAABLAAFFH8lAAIKAAYIfiADBADmAQAKAAYIfiADBADmAQAAAA==.',['悔意']='悔意灬思忆:BAAALAAECgYIDAAAAA==.',['悲剧']='悲剧的奶爸:BAAALAADCgcIBwAAAA==.',['我是']='我是大狐:BAAALAAFFAIIAwAAAA==.',['我有']='我有盾墙:BAAALAAECgYICAAAAA==.',['我滴']='我滴乖乖熊猫:BAAALAAECgYIEAAAAA==.',['战十']='战十八:BAAALAADCgIIAgAAAA==.',['战神']='战神白起:BAAALAAFFAIIAgAAAA==.',['扎西']='扎西德勒:BAAALAAECgYIBwAAAA==.',['扛不']='扛不住打扰了:BAABLAAECn8lAAISAAcIiB4PZAAuAgASAAcIiB4PZAAuAgAAAA==.',['执笔']='执笔画江山:BAABLAAFFH8HAAIDAAQIgQ64IADOAAADAAQIgQ64IADOAAAAAA==.',['扭曲']='扭曲虚空:BAAALAAECgYIDAAAAA==.',['承天']='承天之佑:BAABLAAFFH8iAAIFAAYInSJmBgBNAgAFAAYInSJmBgBNAgABLAAFFAcINgANAJYeAA==.',['揍爆']='揍爆吴小狗:BAAALAAECggIDAAAAA==.',['搬山']='搬山道人:BAAALAAECgYIEwAAAA==.',['摩尔']='摩尔迦娜:BAAALAAECgUIBQAAAA==.',['放脸']='放脸烨:BAAALAADCgYIBQAAAA==.',['斜阳']='斜阳欲落:BAAALAAECgYIBgAAAA==.',['断剑']='断剑红尘:BAAALAAECgUIBgAAAA==.',['方术']='方术大师:BAAALAAECgYIDAAAAA==.',['旋转']='旋转跳跃休息:BAABLAAECn8cAAMRAAcIoQnkHQCwAAARAAcI7gjkHQCwAAAMAAMIdgyknABkAAAAAA==.',['无敌']='无敌单刷王:BAABLAAFFH8GAAISAAIIeBsSRgCqAAASAAIIeBsSRgCqAAAAAA==.',['无聊']='无聊的德:BAABLAAFFH8SAAMbAAYIjRIBBwCSAAAGAAYIqQdRGgAJAQAbAAMIjB0BBwCSAAABLAAFFAYIGQABADQaAA==.无聊的魔:BAABLAAFFH8ZAAMBAAYINBo6CgCxAAACAAYINBqgIAAmAQABAAIIKh46CgCxAAAAAA==.',['无限']='无限恶制:BAAALAAECgYIBgAAAA==.',['星御']='星御:BAAALAAFFAIIBAAAAA==.',['晓美']='晓美灬焰:BAAALAAECgYIBgAAAA==.',['晴晴']='晴晴女王:BAAALAAECgYIBgAAAA==.',['暖浮']='暖浮生:BAAALAAFFAIIAgAAAA==.',['暗夜']='暗夜潜行者:BAAALAADCgMIAwAAAA==.',['暗影']='暗影:BAABLAAFFH8IAAIIAAgIYBlFCgBFAgAIAAgIYBlFCgBFAgAAAA==.',['暗月']='暗月之蚀:BAAALAAFFAIIAgAAAA==.',['暴走']='暴走的钰烨:BAAALAAECgYICgAAAA==.',['暴躁']='暴躁的五阿哥:BAABLAAFFH8GAAIYAAYIeQTCDgCVAQAYAAYIeQTCDgCVAQABLAAFFAgIIwAYACQcAA==.',['最后']='最后一个小白:BAAALAAFFAIIAgAAAA==.最后的归:BAAALAAFFAEIAQAAAA==.',['月叶']='月叶:BAAALAADCgcIBwAAAA==.',['有心']='有心人无名仕:BAAALAADCgYIBgAAAA==.',['有聊']='有聊胜于无:BAAALAAECgMIBgAAAA==.',['朝夕']='朝夕映梦浅:BAAALAADCggICAABLAADCggICQAXAAAAAA==.',['松岛']='松岛灬楓:BAAALAAECgYICgAAAA==.',['林雨']='林雨霞:BAAALAADCgYIBgAAAA==.',['果果']='果果的小巫婆:BAABLAAFFH8GAAMBAAIIEhwcEwBNAAACAAIITxcZUQBNAAABAAII5BkcEwBNAAAAAA==.果果的小怒火:BAAALAAFFAIIAgAAAA==.果果的小虚空:BAABLAAFFH8OAAISAAUI3RVTQAA/AQASAAUI3RVTQAA/AQAAAA==.',['枼子']='枼子辰:BAACLAAFFH8VAAIMAAUIOiBDIgB7AQAMAAUIOiBDIgB7AQAsAAQKfxwAAgwACAhDIHgMAIsCAAwACAhDIHgMAIsCAAAA.',['柊真']='柊真昼:BAAALAAECgYICwAAAA==.',['某球']='某球:BAABLAAFFH8FAAIFAAIIeRjwJACUAAAFAAIIeRjwJACUAAAAAA==.',['柒琪']='柒琪:BAAALAAFFAIIAwAAAA==.',['查内']='查内姆:BAAALAAECgIIBAAAAA==.',['栉川']='栉川鸠子:BAABLAAECn8WAAILAAcIHRMIPABuAQALAAcIHRMIPABuAQAAAA==.',['棂羽']='棂羽衣:BAABLAAFFH8QAAMBAAII9R2lCgCtAAABAAII9R2lCgCtAAACAAIIighjXgA+AAABLAAFFAYIHgATAOQdAA==.',['椒盐']='椒盐可乐鸡:BAAALAAECgEIAQAAAA==.',['欢喜']='欢喜城:BAAALAAFFAIIAgAAAA==.',['正义']='正义的地球人:BAABLAAFFH8IAAIDAAIIPhfXNgClAAADAAIIPhfXNgClAAABLAAFFAgIOQAPANYjAA==.',['步紫']='步紫雪:BAAALAAECgEIAQAAAA==.',['歪比']='歪比吧啵:BAAALAAECgQIBgAAAA==.',['殷忆']='殷忆柏:BAAALAAECggICwAAAA==.',['水元']='水元素:BAAALAAECgEIAQAAAA==.',['水痘']='水痘崽仔:BAAALAAFFAIIAgAAAA==.水痘轰炸机:BAAALAAECgYICQAAAA==.',['汐丿']='汐丿欣然:BAABLAAFFH8GAAIUAAYIvxAjBgCwAQAUAAYIvxAjBgCwAQAAAA==.',['沁凉']='沁凉丶:BAAALAAECgEIAQAAAA==.',['法力']='法力风暴:BAAALAADCgMIAwAAAA==.',['泯灭']='泯灭虚无:BAABLAAFFH8IAAICAAII4yCKMgC/AAACAAII4yCKMgC/AAAAAA==.',['泰达']='泰达希尔:BAAALAAECgIIAgAAAA==.',['洒家']='洒家插图疼:BAABLAAECn8UAAILAAcInREZjwBgAQALAAcInREZjwBgAQAAAA==.',['洛祈']='洛祈:BAAALAADCggIEAAAAA==.',['流年']='流年碎容颜丶:BAAALAAECgEIAQABLAAFFAcILwADAGUkAA==.',['浅梦']='浅梦忆君:BAAALAAECgcIEwAAAA==.',['海森']='海森堡:BAAALAADCgEIAQAAAA==.',['润肠']='润肠通便:BAAALAAFFAIIBAAAAA==.',['混世']='混世者萨饵:BAAALAAECgUIBQAAAA==.',['清混']='清混胖腊子:BAAALAAECgIIAgAAAA==.',['游戏']='游戏时间:BAAALAADCgEIAQAAAA==.',['源神']='源神:BAABLAAECn8wAAMBAAgIOx6JEQCYAgABAAgIOx6JEQCYAgACAAIItgPTDgEgAAAAAA==.',['火影']='火影猎:BAABLAAFFH8FAAIQAAQI2xlWCgBbAQAQAAQI2xlWCgBbAQAAAA==.',['灵长']='灵长类杀手:BAABLAAECn8gAAISAAgIYxyiVQBMAgASAAgIYxyiVQBMAgAAAA==.',['無敌']='無敌晓眼睛:BAAALAAFFAYIBAABLAAFFAgIIgAHAH0lAA==.',['焰影']='焰影苇草:BAABLAAFFH8MAAMNAAMI6xTyIAC5AAANAAII1x7yIAC5AAAaAAEI3QGOMgAqAAABLAAFFAYIFAAQAFAcAA==.',['爪妹']='爪妹酱酱:BAACLAAFFH8NAAINAAMIMQSzIgCvAAANAAMIMQSzIgCvAAAsAAQKfzIAAw0ACAgPCQBiAFcBAA0ACAgPCQBiAFcBABwAAwiHAzU0AFkAAAAA.爪妹醬:BAACLAAFFH8WAAIIAAQIsAwLIAAIAQAIAAQIsAwLIAAIAQAsAAQKfyEAAggACAg0G8BmAA4CAAgACAg0G8BmAA4CAAAA.',['爱吃']='爱吃汉堡:BAAALAAECgYIDAAAAA==.',['爱音']='爱音:BAAALAAECgQIBAAAAA==.',['牧流']='牧流冰:BAAALAAECggIEAAAAA==.',['物丸']='物丸大队长:BAABLAAFFH86AAIEAAYI2SLhAQASAgAEAAYI2SLhAQASAgAAAA==.物丸小混范:BAACLAAFFH8hAAIRAAYIlBYPBQBSAQARAAYIlBYPBQBSAQAsAAQKfxoAAxEABwhqCRo+AO4AABEABwgECBo+AO4AAAwAAQg0GTWoAEkAAAEsAAUUBgg6AAQA2SIA.物丸小混飯:BAACLAAFFH80AAMbAAYIAxpeAgCAAQAbAAYIxBheAgCAAQAGAAYItRPzDwB0AQAsAAQKfxgAAwYABwhUElgvAA4BABsABwgNDl0bAEIBAAYABAgvFlgvAA4BAAEsAAUUBgg6AAQA2SIA.物丸小混饭:BAACLAAFFH8vAAIOAAYIhx8ECQC2AQAOAAYIhx8ECQC2AQAsAAQKfxwAAg4ABwhNGEEuAN0BAA4ABwhNGEEuAN0BAAEsAAUUBgg6AAQA2SIA.物丸小炒饼:BAAALAAFFAQIBAAAAA==.物丸桃桃酱:BAAALAAECgYIBgAAAA==.',['犬来']='犬来八荒:BAACLAAFFH8TAAMLAAMIBR0TIgDGAAALAAII3CMTIgDGAAAYAAMIzxw/MgCfAAAsAAQKfxsAAxgABggJI5oqAGgCABgABggJI5oqAGgCAAsABgiNG4NeAMwBAAAA.',['狂野']='狂野的大蜂子:BAAALAADCgQIBAAAAA==.',['狐狸']='狐狸镜子:BAABLAAFFH8fAAMIAAYIbxxsHADHAQAIAAYIbxxsHADHAQAQAAIIjQWOLgBnAAABLAAFFAYIOgAEANkiAA==.',['狩猎']='狩猎苏苏:BAAALAAECgYIBgAAAA==.',['独苗']='独苗:BAAALAADCgIIAgAAAA==.',['猎杀']='猎杀麦乐鸡:BAACLAAFFH8RAAIIAAQIIBXDHAAeAQAIAAQIIBXDHAAeAQAsAAQKfx8AAwgACAg7IXwgANgCAAgACAg7IXwgANgCABAAAwiDDxOhAHMAAAAA.',['玉人']='玉人歌:BAAALAAFFAIIAgAAAA==.',['玛尔']='玛尔斯丶罪刃:BAAALAAECgYIBwAAAA==.',['玛格']='玛格西男人:BAABLAAFFH8MAAIIAAYIKhZ/NQBsAQAIAAYIKhZ/NQBsAQAAAA==.',['玛里']='玛里奥:BAABLAAFFH8SAAMFAAMIiBH/LQC3AAAFAAMIiBH/LQC3AAAbAAIIrQ0aDwApAAABLAAFFAYIHgATAOQdAA==.',['理想']='理想之城:BAAALAAFFAIIBAAAAA==.',['瓦里']='瓦里安:BAABLAAFFH8OAAIOAAIISCIaFgCkAAAOAAIISCIaFgCkAAAAAA==.',['生杀']='生杀予夺:BAAALAAECggICAAAAA==.',['番茄']='番茄切啊切:BAAALAAFFAIIBAAAAA==.',['百隐']='百隐之鬼:BAAALAAECgYIDAAAAA==.',['皓月']='皓月宁雨:BAACLAAFFH8RAAMPAAUIWAzbKgAbAQAPAAUI8QrbKgAbAQAOAAIIIhCtMgAxAAAsAAQKfxsAAw4ACAjpEWoeAFEBAA4ACAipD2oeAFEBAA8AAwg0GLdqANcAAAEsAAUUBggeABMA5B0A.',['眩目']='眩目的帝王:BAAALAAECgUIBQAAAA==.',['破晓']='破晓晨曦:BAABLAAFFH8eAAMdAAYIPiU4BABuAgAdAAYIPiU4BABuAgADAAYIlCPAAwA3AgABLAAFFAgIEAAGAO8eAA==.',['神之']='神之舞子:BAAALAAECggIBgAAAA==.',['神人']='神人梅西:BAACLAAFFH8wAAQJAAgILCDzAgBKAgAJAAcIBiDzAgBKAgAKAAMIziHBCAAYAQAeAAEIAglBBwBMAAAsAAQKfzIABAkACAjHJDoKAMUBAAkACAheIjoKAMUBAAoABQhjIZsdAKcBAB4AAgiJHaQYAJsAAAAA.',['神棍']='神棍法:BAAALAAFFAIIBAAAAA==.',['祥瑞']='祥瑞狸:BAAALAAECgYIBgAAAA==.',['秀忠']='秀忠:BAAALAADCggICgAAAA==.',['秀真']='秀真:BAAALAAECgEIAQAAAA==.',['秋絮']='秋絮雨:BAABLAAFFH8LAAILAAUI0AxlLwD3AAALAAUI0AxlLwD3AAAAAA==.',['第三']='第三个防骑:BAAALAADCgIIAgAAAA==.',['第四']='第四个防骑:BAAALAADCgYIBgAAAA==.',['等我']='等我读个条:BAAALAAECgQIBQAAAA==.',['米开']='米开朗基罗:BAABLAAFFH8GAAIPAAYIPArjJABNAQAPAAYIPArjJABNAQAAAA==.',['米糯']='米糯糯:BAAALAAECgQIBAAAAA==.',['紫殇']='紫殇:BAABLAAFFH8IAAIDAAMIMSHNEQAuAQADAAMIMSHNEQAuAQAAAA==.',['紫潇']='紫潇:BAAALAADCgEIAQAAAA==.',['红运']='红运正当头:BAAALAAECgYIDwABLAAECgYIHgAJACEhAA==.红运贼当头:BAABLAAECn8eAAIJAAYIISElGQBMAgAJAAYIISElGQBMAgAAAA==.',['纯情']='纯情小火鸡:BAABLAAECn8VAAIfAAYI3RNjCAA2AQAfAAYI3RNjCAA2AQABLAAFFAIICAAZALwcAA==.纯情火鸡:BAACLAAFFH8IAAIZAAIIvBwKBgBgAAAZAAIIvBwKBgBgAAAsAAQKfxUAAhkABwh6Ib0JAFsCABkABwh6Ib0JAFsCAAAA.',['绊倒']='绊倒铁盒:BAAALAAECgEIAQAAAA==.',['维型']='维型生物:BAAALAAECgYIBgAAAA==.',['罪在']='罪在脆皮:BAAALAAFFAIIAgAAAA==.',['美树']='美树沙耶香:BAAALAAECgYIDAAAAA==.',['羽霍']='羽霍飞:BAAALAAFFAIIAgAAAA==.',['老娘']='老娘会法术:BAAALAADCgIIAgAAAA==.',['老拳']='老拳拳碎胸口:BAABLAAFFH8JAAIgAAMIqwiqEgCUAAAgAAMIqwiqEgCUAAABLAAFFAYIFAAQAFAcAA==.',['耶路']='耶路撒冷:BAABLAAFFH8KAAILAAIIfRqENQCWAAALAAIIfRqENQCWAAAAAA==.',['肉厥']='肉厥厥:BAAALAADCgYICgAAAA==.',['胭脂']='胭脂虫:BAAALAAECgQIBAAAAA==.',['脱缰']='脱缰的老马:BAAALAAECgMIAwAAAA==.',['自摸']='自摸乱风向:BAAALAADCgIIAgAAAA==.',['艾希']='艾希:BAACLAAFFH8OAAMIAAUIWhGHUgAMAQAIAAUI1RCHUgAMAQAQAAIIIw4fEAB4AAAsAAQKfx8ABCEACAj8FiQKAAwCACEABwhrFyQKAAwCAAgABwi+D+bmAE4BABAAAQg9C3HEACsAAAAA.',['芙柔']='芙柔桑克斯:BAAALAAECgYICAAAAA==.',['芳心']='芳心纵火犯:BAAALAADCgIIAgAAAA==.',['苏苏']='苏苏:BAABLAAFFH8OAAILAAIIwhNQSAB0AAALAAIIwhNQSAB0AAAAAA==.苏苏老师:BAAALAAECgEIAQAAAA==.',['苏非']='苏非玛索:BAABLAAFFH8IAAIDAAIIaRoRZwBDAAADAAIIaRoRZwBDAAAAAA==.',['茅场']='茅场晶彦:BAAALAAFFAQIBAAAAA==.',['茉莉']='茉莉奶绿:BAAALAAECgEIAQAAAA==.',['茉香']='茉香芋泥:BAABLAAFFH8PAAILAAUIvxZuIwBIAQALAAUIvxZuIwBIAQAAAA==.',['荒芜']='荒芜拉普兰德:BAAALAAFFAYIAgABLAAFFAYIFAAQAFAcAA==.',['菠萝']='菠萝切啊切:BAABLAAFFH8hAAIOAAUIsgufGQDZAAAOAAUIsgufGQDZAAAAAA==.',['萝卜']='萝卜切啊切:BAAALAAFFAIIBAAAAA==.',['萨妃']='萨妃洛斯:BAABLAAECn8ZAAIIAAYItBnYsQCSAQAIAAYItBnYsQCSAQAAAA==.',['萨拉']='萨拉洛佩兹:BAACLAAFFH8IAAIIAAIIGwedqwA6AAAIAAIIGwedqwA6AAAsAAQKfxcAAwgABwhwFN69AIIBAAgABwhwFN69AIIBABAAAQijDf7HACgAAAAA.',['葉子']='葉子辰丶:BAABLAAFFH8qAAISAAYIXCXaCAAdAgASAAYIXCXaCAAdAgAAAA==.',['蓝莓']='蓝莓切啊切:BAABLAAFFH8eAAIRAAUIegYcCgCxAAARAAUIegYcCgCxAAAAAA==.',['蓝血']='蓝血牛牛:BAABLAAECn8bAAILAAYIXxIhoAA+AQALAAYIXxIhoAA+AQAAAA==.',['蕾欧']='蕾欧娜:BAAALAAFFAIIAgAAAA==.',['蕾米']='蕾米莉亚:BAABLAAFFH8HAAISAAMI/A5CLQDlAAASAAMI/A5CLQDlAAABLAAFFAYIFAAQAFAcAA==.',['虎之']='虎之咆哮:BAAALAAECgYIDAAAAA==.虎之骑士:BAAALAAECgYICwAAAA==.',['虚空']='虚空神牧:BAAALAAECgQIBAAAAA==.',['虞妖']='虞妖:BAAALAAFFAIIAgAAAA==.',['蛋糕']='蛋糕切啊切:BAABLAAFFH8GAAIMAAII0xlSNQCiAAAMAAII0xlSNQCiAAAAAA==.',['血煞']='血煞狂徒:BAAALAADCgEIAQAAAA==.',['血鬼']='血鬼狂人:BAACLAAFFH8uAAIDAAgIcCYHAACGAwADAAgIcCYHAACGAwAsAAQKfyIAAgMACAjyJgwCAIwDAAMACAjyJgwCAIwDAAAA.',['行梓']='行梓焚眉:BAAALAAECgUIBQAAAA==.',['行走']='行走的电灯泡:BAAALAAECgYIDgAAAA==.行走的血瓶:BAAALAADCgEIAQAAAA==.',['被流']='被流放的恐惧:BAAALAAECgIIAgAAAA==.',['裂蹄']='裂蹄牛:BAABLAAECn8fAAMIAAYISSCWTgCqAQAhAAYIFiBBCgAKAgAIAAYIvBuWTgCqAQAAAA==.',['裴钱']='裴钱:BAAALAADCgUIBQAAAA==.',['西格']='西格玛男银丶:BAACLAAFFH8SAAIDAAIIthtNQQCdAAADAAIIthtNQQCdAAAsAAQKfyAAAgMABwhFHxdPAFICAAMABwhFHxdPAFICAAAA.',['西瓜']='西瓜切啊切:BAAALAAECgIIAgAAAA==.',['请叫']='请叫我源氏:BAAALAAECgYIEgAAAA==.',['请教']='请教我四爷:BAABLAAFFH8GAAIIAAIIRwtwqgA7AAAIAAIIRwtwqgA7AAAAAA==.',['谢老']='谢老二:BAAALAAECgYIEAAAAA==.',['豆豆']='豆豆先生:BAAALAAECgYIBgAAAA==.',['贝恩']='贝恩丶血蹄:BAAALAAECgYIBgAAAA==.',['赤座']='赤座灯里:BAAALAAECgEIAQAAAA==.',['超想']='超想养只猫:BAAALAAECgMIBgABLAAECggIIAASAGMcAA==.',['超级']='超级虫虫:BAAALAADCgEIAQAAAA==.',['身高']='身高一米八:BAAALAAFFAYIBAAAAA==.',['达光']='达光贵人:BAABLAAFFH8GAAIdAAYIlgmZFABKAQAdAAYIlgmZFABKAQAAAA==.',['迈克']='迈克拉伦:BAAALAAFFAIIBAAAAA==.',['这河']='这河狸吗:BAAALAAFFAIIAgAAAA==.',['远征']='远征意志:BAABLAAECn8WAAIIAAgI5B0IMACZAgAIAAgI5B0IMACZAgABLAAFFAgIEgAIAM0MAA==.',['迪丽']='迪丽滚圆:BAAALAAECgQIBAAAAA==.',['速冻']='速冻麦乐鸡:BAAALAAECgYIBgAAAA==.',['造纸']='造纸农夫三拳:BAAALAADCgcIBwAAAA==.',['道无']='道无痕:BAAALAAFFAEIAQABLAAFFAYIHgATAOQdAA==.',['阿撒']='阿撒谢尔君:BAAALAAECgYIDAAAAA==.',['阿爾']='阿爾薩斯:BAAALAAFFAIIBAAAAA==.',['阿阿']='阿阿吾阮丫:BAABLAAFFH8GAAIaAAYIlQ8rBwDqAQAaAAYIlQ8rBwDqAQAAAA==.',['陆战']='陆战队门板:BAAALAAECgMIBgABLAAFFAYINgAHAHwdAA==.',['隔壁']='隔壁表姐丿:BAAALAAECgYIDAAAAA==.',['难等']='难等佛举:BAAALAAECgQIBAAAAA==.',['雪娜']='雪娜蕊斯:BAACLAAFFH82AAINAAcIlh7QBwBSAgANAAcIlh7QBwBSAgAsAAQKfx0AAg0ACAiTHmIhAHECAA0ACAiTHmIhAHECAAAA.',['雪色']='雪色云清:BAAALAADCggICAAAAA==.',['雪花']='雪花闯天涯:BAAALAAECgYIBgAAAA==.',['雷霆']='雷霆老怒:BAAALAAFFAIIAgAAAA==.',['雾岛']='雾岛熊宝宝:BAAALAAFFAIIAgAAAA==.',['雾霾']='雾霾里有花狸:BAAALAAFFAIIAgAAAA==.',['霸主']='霸主:BAABLAAFFH8GAAIOAAYIxw6mFQASAQAOAAYIxw6mFQASAQAAAA==.',['靈靈']='靈靈妖:BAABLAAFFH8FAAIPAAMIhRYsLQD+AAAPAAMIhRYsLQD+AAAAAA==.',['青花']='青花:BAABLAAECn8UAAMRAAcICBeKJgCBAQARAAcICBeKJgCBAQAMAAMIGQOEUwE6AAAAAA==.',['韩小']='韩小七:BAAALAAECgEIAQAAAA==.',['風随']='風随:BAABLAAFFH8GAAICAAIIbgexWgCEAAACAAIIbgexWgCEAAAAAA==.',['风凌']='风凌薇:BAAALAAECgEIAQAAAA==.',['风斩']='风斩冰华:BAAALAAECgYIBgAAAA==.',['风雅']='风雅雅:BAAALAAECgEIAQAAAA==.',['饺子']='饺子音:BAAALAAECgYIBgAAAA==.',['香草']='香草圣代:BAAALAAECgYIBgAAAA==.',['香菇']='香菇仔:BAAALAAFFAMIAwAAAA==.',['马上']='马上风:BAABLAAFFH8GAAIJAAYIwSGsAABhAgAJAAYIwSGsAABhAgAAAA==.',['马克']='马克丶土鳖:BAAALAAFFAIIAgAAAA==.',['骇人']='骇人鲸:BAAALAAFFAIIAgAAAA==.',['骷髅']='骷髅鬼:BAAALAAECgYIBgAAAA==.',['高桥']='高桥南:BAAALAAFFAIIAwAAAA==.',['鬼拳']='鬼拳:BAAALAADCgUIBQABLAAFFAgIHQASAAQVAA==.',['魂哔']='魂哔哔:BAAALAAECggICAAAAA==.',['魅影']='魅影灬晴晴:BAAALAAECgUIBQAAAA==.',['鱼皮']='鱼皮花生:BAAALAADCgQIBAAAAA==.',['黑海']='黑海岸以东:BAABLAAFFH8SAAMGAAYIkxr3DQCLAQAGAAYIkxr3DQCLAQAFAAQIrB4jGwBWAQAAAA==.',['黑眼']='黑眼圈:BAAALAAECggICAAAAA==.',['黯影']='黯影谜踪:BAABLAAFFH8SAAIgAAYI8wzQCwBHAQAgAAYI8wzQCwBHAQABLAAFFAcINgANAJYeAA==.',['齐静']='齐静春:BAABLAAFFH8XAAIIAAYIqRJURgA3AQAIAAYIqRJURgA3AQABLAAFFAYINgAHAHwdAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end