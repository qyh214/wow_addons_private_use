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
 local lookup = {'Priest-Shadow','Priest-Holy','DeathKnight-Frost','Warrior-Protection','Warrior-Fury','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Shaman-Restoration','Warlock-Destruction','Hunter-BeastMastery','Mage-Fire','Hunter-Marksmanship','Hunter-Survival','Evoker-Preservation','Shaman-Elemental','Monk-Windwalker','Mage-Arcane','Druid-Restoration','Druid-Balance','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Frost','Warlock-Demonology','Warrior-Arms','Priest-Discipline','Monk-Mistweaver','Monk-Brewmaster','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Unholy','Evoker-Devastation','Warlock-Affliction','Unknown-Unknown','Druid-Guardian',}; local provider = {region='CN',realm='藏宝海湾',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Agon:BAAALAAECgYIBgAAAA==.',Al='Albedo:BAAALAADCgYIBgAAAA==.',Bl='Bloodyfox:BAABLAAFFH8dAAMBAAYIXg1vFgAWAQABAAUIzQ1vFgAWAQACAAMI1QdwOQCBAAAAAA==.Bluestone:BAAALAAECgIIAgAAAA==.',Bu='Busi:BAAALAAECgYIDAAAAA==.',Ch='Chaos:BAAALAAECgMIAwAAAA==.',Ci='Cill:BAAALAADCgIIAgAAAA==.',De='Deathknighta:BAABLAAFFH8FAAIDAAIIeRB0ZwCUAAADAAIIeRB0ZwCUAAAAAA==.Deng:BAAALAAECgYICgAAAA==.',Eu='Eureka:BAAALAAECgYICQAAAA==.',He='Headache:BAAALAAECgYIBgAAAA==.Heidi:BAAALAADCggICAAAAA==.',Ja='Jaychou:BAAALAAFFAIIAgAAAA==.',La='Labubu:BAAALAAECgYIBgAAAA==.',Ma='Marika:BAABLAAFFH8YAAMEAAUI8g4gGQDaAAAEAAUI8g4gGQDaAAAFAAII6wj+QACLAAAAAA==.Martyr:BAAALAAECgUIBQAAAA==.',Ol='Oliveiraw:BAAALAAFFAQIAgAAAA==.',Oo='Oolisa:BAACLAAFFH8HAAIGAAIIzh3oMACqAAAGAAIIzh3oMACqAAAsAAQKfyQABAYACAjJHs0UAGgCAAYACAjJHs0UAGgCAAcAAQiLDQxFAC4AAAgAAQgcB39HACMAAAAA.',Pl='Playerjkgxgs:BAAALAAECgYIEAAAAA==.',Ru='Runan:BAAALAAECgUIBQAAAA==.',Sa='Sacri:BAAALAADCgIIAgAAAA==.',Sc='Scarletty:BAAALAAECgYICAABLAAFFAgICwAJAEofAA==.',Sd='Sdutiger:BAABLAAFFH8OAAIGAAQIDhIiNgDTAAAGAAQIDhIiNgDTAAAAAA==.',Sh='Shoprop:BAAALAAECgIIAgAAAA==.',Sn='Snower:BAABLAAFFH8ZAAIDAAUIOh7FMgBxAQADAAUIOh7FMgBxAQAAAA==.',St='Stephanie:BAABLAAFFH8MAAIKAAIISg1PUQB9AAAKAAIISg1PUQB9AAAAAA==.Stuart:BAAALAAECgUIBQABLAAFFAIIDAAKAEoNAA==.',Tr='Trnt:BAAALAAECgMIAwAAAA==.',Vi='Villia:BAAALAAECgIIAgAAAA==.',Vo='Vodkamartini:BAACLAAFFH8hAAILAAUIyyAaMwBvAQALAAUIyyAaMwBvAQAsAAQKfyEAAgsACAjEJRQEAP0CAAsACAjEJRQEAP0CAAAA.',Zo='Zombie:BAACLAAFFH8qAAIMAAYIcBogAgC3AQAMAAYIcBogAgC3AQAsAAQKfzAAAgwACAiCHeYCALUCAAwACAiCHeYCALUCAAAA.',['一念']='一念成魔:BAAALAADCgQIBAAAAA==.',['一条']='一条恶龙:BAABLAAFFH8PAAMLAAYIExDIQQBCAQALAAYIExDIQQBCAQANAAII2RCNGAA4AAAAAA==.',['一狩']='一狩猎一:BAACLAAFFH8mAAQLAAYIPB5BGADYAQALAAYIFx5BGADYAQAOAAMIYxqXAgC2AAANAAIIwRTqEwBJAAAsAAQKfxwABA4ACAhhIxkCABkDAA4ACAiMIhkCABkDAA0ABwgBFtFdAEUBAAsAAgjgI1DTANMAAAAA.',['一箭']='一箭一个:BAAALAAECgYICwAAAA==.',['一起']='一起做咸鱼:BAAALAAECgUIBQAAAA==.',['三色']='三色灰:BAAALAAECggIEgAAAA==.',['不了']='不了了之:BAAALAAECgYIBgAAAA==.',['不朽']='不朽:BAAALAAECggICAAAAA==.',['不死']='不死深冬:BAAALAAFFAIIBAAAAA==.',['不灭']='不灭的信仰:BAAALAADCgYIBgAAAA==.',['专业']='专业群众演员:BAAALAADCgQIBAAAAA==.',['丨狩']='丨狩猎丨:BAABLAAFFH8PAAIPAAUIhxTBDQBlAQAPAAUIhxTBDQBlAQABLAAFFAYIJgALADweAA==.',['丶萨']='丶萨神:BAAALAAECgYICgAAAA==.',['乄天']='乄天狼:BAABLAAFFH8PAAIEAAgIxh+kAQCPAgAEAAgIxh+kAQCPAgAAAA==.',['乄说']='乄说爱太烫嘴:BAAALAADCggICAAAAA==.',['九曲']='九曲桥:BAAALAAECgUIBQAAAA==.',['九沑']='九沑一氍:BAABLAAECn8YAAMJAAgIGiAbGwCtAgAJAAgIGiAbGwCtAgAQAAUIzwgRYQCQAAABLAAFFAUIIwARAGoYAA==.',['乱七']='乱七八糟的:BAABLAAFFH8GAAIDAAIIUQrVeQCLAAADAAIIUQrVeQCLAAAAAA==.',['云中']='云中歌:BAAALAAECgYIDAAAAA==.',['云朵']='云朵团团:BAACLAAFFH89AAICAAgIjyTRAAA5AwACAAgIjyTRAAA5AwAsAAQKfycAAgIACAjHIcUVALwCAAIACAjHIcUVALwCAAAA.',['从小']='从小就很胖:BAAALAAECgYIBgAAAA==.',['伊利']='伊利达:BAAALAAECgIIAgAAAA==.',['你很']='你很牛吗:BAAALAAECgYIBgAAAA==.',['你相']='你相信光嗎:BAACLAAFFH8jAAIRAAUIahg9CgA9AQARAAUIahg9CgA9AQAsAAQKfyQAAhEACAhwHnoGAFgCABEACAhwHnoGAFgCAAAA.',['倚天']='倚天寒:BAAALAAECgQIBAAAAA==.',['假死']='假死骗战复:BAABLAAFFH8MAAILAAUI3g59UgAHAQALAAUI3g59UgAHAQAAAA==.',['傲世']='傲世霹雳:BAAALAAECggICAAAAA==.',['傻右']='傻右右:BAAALAAFFAIIBAAAAA==.',['光头']='光头佬:BAAALAAECgIIAgAAAA==.光头大人:BAAALAADCgUIBQABLAAFFAgIDwAEAKYjAA==.',['克洛']='克洛诺斯:BAAALAAFFAIIAwAAAA==.',['兜里']='兜里有糖糖:BAAALAAECgYIEQAAAA==.',['写忆']='写忆:BAAALAAECgMIAwAAAA==.',['冰之']='冰之咆哮:BAAALAAECgYICQAAAA==.',['别聊']='别聊了奶我:BAAALAADCgEIAQAAAA==.',['劈萨']='劈萨狐了:BAABLAAFFH8KAAIQAAIILQvSLwCJAAAQAAIILQvSLwCJAAAAAA==.',['千殇']='千殇灬愈烈:BAAALAAFFAIIAgAAAA==.',['千重']='千重:BAAALAAFFAIIAgAAAA==.',['午后']='午后悠怡:BAAALAAECggICAAAAA==.',['南极']='南极长生大帝:BAAALAAECgQIBAAAAA==.',['卡冈']='卡冈图雅:BAABLAAFFH8GAAISAAYIzRv+JACBAQASAAYIzRv+JACBAQAAAA==.',['卡厄']='卡厄斯:BAAALAAFFAIIBAAAAA==.',['卡咩']='卡咩咩:BAACLAAFFH8OAAITAAMIyg65NACXAAATAAMIyg65NACXAAAsAAQKfxkAAhMABwgnFzNzAD4BABMABwgnFzNzAD4BAAAA.',['卡皮']='卡皮吧啦:BAABLAAFFH8NAAIGAAYIDQtYOADAAAAGAAYIDQtYOADAAAAAAA==.',['印第']='印第安老斑鸠:BAAALAAECgYIDQAAAA==.',['厄瑞']='厄瑞玻斯:BAAALAAFFAIIAwAAAA==.',['双马']='双马尾萌妹:BAAALAADCgUIBQAAAA==.',['叶卡']='叶卡丶:BAAALAAECgYIDAAAAA==.',['名字']='名字最长的牛:BAAALAAECgQIBAAAAA==.',['含丶']='含丶笑:BAAALAAFFAIIBAABLAAFFAYIKwACAKcdAA==.',['咕德']='咕德猫咛:BAACLAAFFH8iAAIUAAYIyBshCwCvAQAUAAYIyBshCwCvAQAsAAQKfxgAAhQACAi3InUNAAQDABQACAi3InUNAAQDAAAA.',['哆哆']='哆哆嗦嗦:BAAALAAECgIIAgAAAA==.',['哈米']='哈米什:BAABLAAFFH8GAAILAAIIwCE8QQCkAAALAAIIwCE8QQCkAAAAAA==.',['哈里']='哈里露丫:BAAALAAECgYIBwAAAA==.',['哦你']='哦你真棒:BAABLAAFFH8MAAIGAAIIPBS5OwChAAAGAAIIPBS5OwChAAAAAA==.',['啾啾']='啾啾:BAAALAAFFAIIBAAAAA==.',['喜欢']='喜欢死亡丶:BAAALAAFFAIIAgAAAA==.',['喵叔']='喵叔:BAAALAAECgYIBgAAAA==.',['喷射']='喷射戦士:BAAALAAECgMIAwAAAA==.',['因幡']='因幡月夜:BAAALAAFFAIIBAAAAA==.',['圣光']='圣光丶女神:BAAALAAECgYIDwAAAA==.',['城市']='城市猎丶人:BAABLAAECn8ZAAMNAAcI9B4oNwDgAQANAAYIExsoNwDgAQALAAcIOR7ZhQDVAQAAAA==.',['墨月']='墨月殃歌:BAAALAADCgIIAgAAAA==.',['墨燊']='墨燊:BAABLAAFFH8bAAMVAAUI3Q4dDACUAAAWAAUI3Q6xMAASAQAVAAII4BkdDACUAAABLAAFFAYIKwACAKcdAA==.',['壹枪']='壹枪插四方:BAAALAADCggICQAAAA==.',['壹歳']='壹歳就很酷:BAAALAAECgYIBgAAAA==.',['夕夕']='夕夕恩:BAAALAADCgIIAgAAAA==.夕夕桂花糕:BAAALAAECgMIAwAAAA==.夕夕荣耀:BAAALAAFFAEIAQAAAA==.',['多多']='多多的橙子:BAAALAADCgIIAgAAAA==.',['夜凉']='夜凉如水:BAAALAAECgYIBgAAAA==.',['夜曲']='夜曲:BAAALAAFFAIIBAABLAAFFAYIKwACAKcdAA==.',['大黑']='大黑牛的灵魂:BAAALAAECgUIBQAAAA==.',['天弦']='天弦呤:BAAALAAECgYIBgAAAA==.',['天怒']='天怒:BAABLAAFFH8LAAIQAAUIyBMTIQA5AQAQAAUIyBMTIQA5AQABLAAFFAUIKAADAE0mAA==.',['天毁']='天毁:BAAALAAFFAQIAQAAAA==.',['天罗']='天罗地网丨狂:BAAALAAECggICAAAAA==.',['奶到']='奶到你心慌:BAABLAAECn8bAAIGAAgIBh7+NACgAgAGAAgIBh7+NACgAgAAAA==.',['奶量']='奶量超低:BAACLAAFFH8kAAIIAAUIiiDjCwDHAQAIAAUIiiDjCwDHAQAsAAQKf0YAAwgACAjaIgYDAPsCAAgACAjaIgYDAPsCAAYACAhqIB8mANkCAAAA.',['妖族']='妖族圣男:BAAALAADCgEIAQAAAA==.',['娴熟']='娴熟虎:BAACLAAFFH8qAAMQAAUIThvwHQBTAQAQAAUIThvwHQBTAQAJAAMIPhQTSACPAAAsAAQKf0YAAxAACAh/IrEKAHwCABAACAh/IrEKAHwCAAkAAghYD7ejADQAAAAA.',['安德']='安德斯巴鲁:BAABLAAECn8YAAIFAAYIxB2mKQC5AQAFAAYIxB2mKQC5AQAAAA==.',['安静']='安静成思:BAAALAAFFAIIBAAAAA==.',['宛宛']='宛宛:BAAALAAECgYICwAAAA==.',['射击']='射击的优熊:BAAALAAECgYIDQAAAA==.',['射血']='射血的烂香蕉:BAAALAAECgMIBQAAAA==.',['小云']='小云之痛苦:BAACLAAFFH8MAAIXAAMIFQn+DgBvAAAXAAMIFQn+DgBvAAAsAAQKfyoAAhcACAhwF8MdAC0CABcACAhwF8MdAC0CAAAA.',['小亖']='小亖:BAAALAAFFAQIBAAAAA==.',['小力']='小力飞道:BAACLAAFFH8hAAMKAAUIERGXOgAgAQAKAAUIERGXOgAgAQAYAAIIuQcMHACHAAAsAAQKfz8AAxgACAg5HjsRAHMCABgACAjaGzsRAHMCAAoACAjfGIMmAMEBAAAA.',['小呀']='小呀小么牛:BAABLAAFFH8RAAIJAAYIEw2/IQDHAAAJAAYIEw2/IQDHAAAAAA==.',['小唐']='小唐不会肘:BAAALAAECgYIBgAAAA==.小唐挺糖:BAACLAAFFH8rAAIEAAYIOBPBEABGAQAEAAYIOBPBEABGAQAsAAQKfy8AAwQACAiUGmchACoCAAQACAhUGmchACoCABkABAj4GBoLAOoAAAAA.小唐没睡醒:BAAALAAECgcICgAAAA==.',['小小']='小小修修:BAACLAAFFH8pAAMCAAUIzwa/JQANAQACAAUIzwa/JQANAQAaAAEIDAdZCQAkAAAsAAQKf0YAAgIACAhtDrMvAEEBAAIACAhtDrMvAEEBAAAA.小小的死骑:BAABLAAFFH8UAAIDAAUI3BAORgAjAQADAAUI3BAORgAjAQABLAAFFAYIJgALADweAA==.小小的酒仙:BAABLAAFFH8XAAMbAAUIVxfrCQB3AQAbAAUIVxfrCQB3AQAcAAUIUQTFFgDBAAABLAAFFAYIJgALADweAA==.',['小怪']='小怪物:BAAALAADCgYIBgAAAA==.',['小惠']='小惠:BAAALAAECgUICQAAAA==.',['小朋']='小朋友:BAAALAAECggIDgAAAA==.',['小空']='小空:BAAALAAECgUIBQAAAA==.',['小蒹']='小蒹蝶:BAAALAADCgIIAgAAAA==.',['小蜜']='小蜜蜂:BAAALAAFFAIIAgAAAA==.',['尛洁']='尛洁洁:BAAALAAFFAIIAwAAAA==.',['尤涅']='尤涅若:BAAALAAECgYIDAAAAA==.',['尼克']='尼克斯:BAAALAAFFAIIBAAAAA==.',['尼德']='尼德霍格:BAAALAAFFAIIBAAAAA==.',['帅就']='帅就完事:BAAALAAFFAIIAgAAAA==.',['帅本']='帅本一狼:BAAALAAECgYIDAAAAA==.',['幻海']='幻海梦蝶:BAACLAAFFH8hAAMWAAUIwRrSJQBhAQAWAAUIwRrSJQBhAQAVAAIIzBSbDgB/AAAsAAQKfzIAAxYACAjjHH40AIsCABYACAjjHH40AIsCABUAAgixFbJeAFEAAAAA.',['幽兰']='幽兰黛尔:BAABLAAFFH8IAAIHAAIIrRpqFgBHAAAHAAIIrRpqFgBHAAAAAA==.',['幽幽']='幽幽小叮当:BAAALAAFFAEIAQABLAAFFAgICAAXAF4GAA==.',['弎幺']='弎幺柒:BAAALAAECgYIBgAAAA==.',['当当']='当当小红手儿:BAABLAAFFH8GAAIdAAYIThF0CgBrAQAdAAYIThF0CgBrAQAAAA==.',['彦祖']='彦祖议会会长:BAAALAAECgcIBwAAAA==.',['影遁']='影遁看风景:BAACLAAFFH8mAAMVAAYIPRWTBQA7AQAWAAUIvhLKKABOAQAVAAYIvRKTBQA7AQAsAAQKfxkAAxUACAhuGdETADUCABUACAhuGdETADUCABYACAgcDVymAIEBAAAA.',['後會']='後會丶無期:BAAALAAFFAIIBAAAAA==.',['忘忧']='忘忧:BAAALAAECgYIBgAAAA==.',['思离']='思离谱:BAAALAAECgYIDgAAAA==.',['悟空']='悟空你哥:BAAALAAECgYIBgAAAA==.',['慕容']='慕容灬姼姼:BAAALAAECgQIBAAAAA==.慕容灬芊芊:BAAALAAECgUIBQAAAA==.慕容馨児:BAACLAAFFH8nAAISAAUIYSBAKABzAQASAAUIYSBAKABzAQAsAAQKfzoAAhIACAgEIwcRABgDABIACAgEIwcRABgDAAAA.',['慕思']='慕思果果:BAABLAAECn8WAAQCAAYIGRBlbAA2AQACAAYI1Q9lbAA2AQABAAIIfgVKlgBKAAAaAAEI/g84PgAxAAAAAA==.',['我很']='我很忙:BAAALAAECgYIBgAAAA==.',['我是']='我是低端小德:BAABLAAFFH8GAAIUAAYIyRCmBgDdAQAUAAYIyRCmBgDdAQAAAA==.',['我有']='我有小跟班:BAAALAADCgQIBQAAAA==.',['我没']='我没魅魔纹:BAAALAAECgUIBQAAAA==.',['我的']='我的手法很渣:BAAALAAECgMIBAAAAA==.',['我要']='我要变白:BAAALAAECgYIEAAAAA==.我要的安逸:BAAALAAECgIIAgAAAA==.',['战挚']='战挚:BAAALAAECgQIBAAAAA==.',['战神']='战神小佑佑:BAAALAAFFAIIAgAAAA==.',['折翼']='折翼的蝴蝶:BAAALAAECgYICgAAAA==.',['拽拽']='拽拽狐狐崽:BAACLAAFFH8VAAMEAAUI8wy7EgC5AAAEAAUIIQy7EgC5AAAFAAIIvRNjTwBFAAAsAAQKfzcAAwQACAiLG7seAD0CAAQACAgDGrseAD0CAAUABwioGwIrALIBAAAA.',['指尖']='指尖:BAACLAAFFH8LAAIGAAMIwyNgNwDIAAAGAAMIwyNgNwDIAAAsAAQKfx4ABAYABwiLIes7AIcCAAYABwgPIes7AIcCAAgABgi5IXgKAEgCAAcABgjXFCEyAIYBAAAA.',['放松']='放松一下:BAAALAAECgYICgAAAA==.',['敏丶']='敏丶宝:BAAALAAECgQIBAAAAA==.',['敬山']='敬山遥:BAAALAAECgUIBQAAAA==.',['新鲜']='新鲜葡萄:BAAALAAECgIIAgAAAA==.',['无声']='无声仿有声丶:BAAALAAECgYIDQAAAA==.',['无极']='无极:BAABLAAFFH8GAAIFAAYItRzcAwBiAgAFAAYItRzcAwBiAgAAAA==.',['无理']='无理走遍天下:BAABLAAFFH8GAAIDAAIIixRCbwBWAAADAAIIixRCbwBWAAAAAA==.',['旺旺']='旺旺牙牙:BAACLAAFFH8HAAMeAAIIQhRwGwBIAAAdAAEIsw+FIQBSAAAeAAEI0RhwGwBIAAAsAAQKfycAAx4ACAiKHswOAE4CAB4ACAikHMwOAE4CAB0ABAiNHxE/AFkBAAEsAAUUBQgjABEAahgA.',['旺猫']='旺猫猫来啦:BAABLAAFFH8MAAIFAAUIoAwcKgAdAQAFAAUIoAwcKgAdAQAAAA==.',['明月']='明月晓星辰:BAAALAAFFAIIAgAAAA==.',['星光']='星光湮灭:BAAALAAECgEIAQAAAA==.',['星空']='星空下的妖孽:BAAALAAFFAIIAgAAAA==.星空下的月影:BAABLAAFFH8IAAIVAAII3QX/GgBHAAAVAAII3QX/GgBHAAAAAA==.星空下的童话:BAAALAAECgYIBgAAAA==.',['昭昭']='昭昭:BAACLAAFFH8PAAIIAAcIFA+9DwCLAQAIAAcIFA+9DwCLAQAsAAQKfxcAAggACAh+G9gvALABAAgACAh+G9gvALABAAAA.',['暗之']='暗之狂奔:BAACLAAFFH8JAAIUAAIIxA/kHwCMAAAUAAIIxA/kHwCMAAAsAAQKfxYAAhQACAgZGZtJAI4BABQACAgZGZtJAI4BAAAA.',['曾经']='曾经是老大:BAAALAAECgYIEgAAAA==.',['最豆']='最豆的时光:BAAALAAECgQIAwAAAA==.',['有点']='有点猫饼:BAAALAAECgMIAwAAAA==.',['朗尼']='朗尼先生:BAAALAAECgYIBgAAAA==.',['木易']='木易王月:BAAALAAECgMIAwAAAA==.',['术心']='术心:BAAALAADCgMIAwAAAA==.',['杀戮']='杀戮小黑:BAAALAAECgYIBgAAAA==.杀戮战神:BAAALAAECgMIAwAAAA==.',['枫叶']='枫叶冰骑:BAAALAAECgUIBgAAAA==.枫叶射射:BAAALAAFFAIIBAAAAA==.枫叶德德:BAAALAAFFAIIBAAAAA==.枫叶术爷:BAAALAAFFAIIAgAAAA==.枫叶萨客:BAAALAAFFAIIAgAAAA==.枫叶血骑:BAABLAAFFH8GAAIGAAIIWRfwbABAAAAGAAIIWRfwbABAAAAAAA==.',['枫林']='枫林晚:BAAALAADCggICAAAAA==.',['梦珂']='梦珂雅:BAABLAAFFH8NAAILAAUIfguOXQDQAAALAAUIfguOXQDQAAAAAA==.',['欧墨']='欧墨尼德丝:BAAALAAFFAIIAgAAAA==.',['欧贝']='欧贝利斯:BAACLAAFFH8qAAIEAAUIpR+3DQBqAQAEAAUIpR+3DQBqAQAsAAQKfz8AAgQACAg0IjQFAJUCAAQACAg0IjQFAJUCAAAA.',['死亡']='死亡:BAAALAAECgYIBgAAAA==.死亡中复活:BAAALAAECgEIAQAAAA==.死亡弹药:BAAALAAFFAIIAgAAAA==.死亡蜂:BAAALAAFFAIIAgAAAA==.',['死噬']='死噬:BAACLAAFFH8oAAMDAAUITSbIOQBVAQADAAQIaybIOQBVAQAfAAIINSS5DQByAAAsAAQKf0UAAwMACAgZJuADAHcDAAMACAgZJuADAHcDAB8AAwgvIys7AAABAAAA.',['死歌']='死歌:BAABLAAFFH8LAAIBAAUIjxOfFQAhAQABAAUIjxOfFQAhAQABLAAFFAUIKAADAE0mAA==.',['毅力']='毅力丹:BAAALAADCgQIBAAAAA==.',['毒奶']='毒奶十八式:BAAALAAECggIEAAAAA==.',['水月']='水月大师:BAABLAAFFH8GAAIbAAIIJAdXFQB4AAAbAAIIJAdXFQB4AAAAAA==.',['沈羡']='沈羡:BAABLAAFFH8SAAIKAAYIqiJHEgD8AQAKAAYIqiJHEgD8AQAAAA==.',['沙扬']='沙扬娜拉:BAACLAAFFH8JAAMdAAII1BxkHgBqAAAdAAEIOCVkHgBqAAAeAAEIbxRXHABFAAAsAAQKfy8AAx0ACAj/JQoCAGEDAB0ACAj/JQoCAGEDAB4AAgjIHaE/AJ4AAAAA.',['河北']='河北彩花:BAAALAADCgMIAwAAAA==.',['浩骑']='浩骑南防:BAABLAAFFH8jAAIHAAUIOBR4CgAEAQAHAAUIOBR4CgAEAQAAAA==.',['淡淡']='淡淡稻花香:BAAALAAECgUICAAAAA==.',['清火']='清火小柚子:BAAALAADCgYIBgAAAA==.',['游然']='游然自德:BAABLAAECn8ZAAIWAAYIpRe3iAC1AQAWAAYIpRe3iAC1AQAAAA==.',['漆黑']='漆黑凝望:BAAALAAECgYIEAAAAA==.漆黑漆黑漆黑:BAAALAAECgMIAwAAAA==.',['火之']='火之暴躁:BAAALAAFFAIIAgAAAA==.',['火山']='火山飄雪:BAAALAADCgEIAQAAAA==.',['灬格']='灬格格灵灬:BAAALAADCgQIBQAAAA==.灬格格美灬:BAAALAAECgYIBgAAAA==.灬格格萌萌灬:BAAALAADCgEIAQAAAA==.',['灰灰']='灰灰会飞:BAAALAADCgYIBgAAAA==.',['炎魔']='炎魔之王:BAABLAAFFH8FAAIDAAMIvw0PdwBLAAADAAMIvw0PdwBLAAAAAA==.',['煌影']='煌影飘渺:BAABLAAFFH8IAAIUAAgIjADKQQARAAAUAAgIjADKQQARAAAAAA==.',['熊猫']='熊猫糕手:BAABLAAFFH8XAAIcAAUILARUFwCzAAAcAAUILARUFwCzAAAAAA==.熊猫茶餐厅:BAABLAAFFH8HAAINAAMImAz6IgCCAAANAAMImAz6IgCCAAAAAA==.',['燃情']='燃情火雨:BAAALAADCgQIBAAAAA==.',['爱吃']='爱吃草的牛:BAAALAAECgIIAgAAAA==.爱吃麻辣烫:BAAALAADCgEIAQAAAA==.',['爷的']='爷的第七章:BAAALAAECgYIBwAAAA==.',['爸爸']='爸爸猪:BAAALAAECgYICQAAAA==.',['牛啦']='牛啦梦:BAACLAAFFH8MAAITAAIIuh3GHgCoAAATAAIIuh3GHgCoAAAsAAQKfzYAAhMACAh2Ib4OAOUCABMACAh2Ib4OAOUCAAAA.',['牛德']='牛德德:BAACLAAFFH8JAAIUAAIILRDeIwCBAAAUAAIILRDeIwCBAAAsAAQKfxkAAhQACAieGmQQAAECABQACAieGmQQAAECAAAA.',['牛必']='牛必大荆龙:BAACLAAFFH8cAAMPAAUItBBFEAArAQAPAAUItBBFEAArAQAgAAIItwCiJQAyAAAsAAQKfxUAAg8ACAjoDZ4cAJABAA8ACAjoDZ4cAJABAAAA.牛必德德:BAABLAAECn8UAAITAAgI2hIaLgB4AQATAAgI2hIaLgB4AQAAAA==.',['牛有']='牛有仙:BAAALAAECgYIDgAAAA==.牛有刀:BAACLAAFFH8mAAIFAAUINh6nIABoAQAFAAUINh6nIABoAQAsAAQKfz0AAgUACAhHIUQYAPYCAAUACAhHIUQYAPYCAAAA.',['牛牛']='牛牛往前冲:BAAALAAECgUIBQAAAA==.',['狂战']='狂战天下:BAABLAAFFH8GAAIEAAMIwxvEHQCSAAAEAAMIwxvEHQCSAAAAAA==.',['狐假']='狐假虎哥威:BAABLAAFFH8HAAILAAUIegqlWgDfAAALAAUIegqlWgDfAAAAAA==.',['狐冷']='狐冷:BAAALAAECgIIBAAAAA==.',['狐狸']='狐狸怎么叫:BAAALAAECgYICQAAAA==.',['猎柠']='猎柠:BAABLAAFFH8LAAILAAMI8h3YZACmAAALAAMI8h3YZACmAAAAAA==.',['猛将']='猛将哥丶:BAAALAAECgYICAAAAA==.',['猷拉']='猷拉诺斯:BAAALAAFFAIIBAAAAA==.',['獸王']='獸王獵人:BAACLAAFFH8nAAILAAUICiHSLgB9AQALAAUICiHSLgB9AQAsAAQKfzoAAgsACAhDJSUKAEgDAAsACAhDJSUKAEgDAAAA.',['玄丶']='玄丶马:BAABLAAFFH8FAAICAAMICgZXNQCRAAACAAMICgZXNQCRAAAAAA==.',['王朝']='王朝陨落:BAAALAAFFAIIBAAAAA==.',['球形']='球形霸天虎:BAAALAAFFAIIAgAAAA==.',['瑞德']='瑞德:BAAALAAFFAIIAgAAAA==.',['留点']='留点情喂狗:BAAALAADCgIIAgAAAA==.',['白色']='白色韵味:BAABLAAFFH8HAAMKAAUIYRp0MwBIAQAKAAUIYRp0MwBIAQAYAAIIxgnEFQBAAAAAAA==.',['白萝']='白萝卜:BAAALAAECgYIDwAAAA==.',['百丶']='百丶万:BAAALAAECgUIBgAAAA==.',['百变']='百变肉球:BAAALAAECggICgAAAA==.',['盗心']='盗心:BAAALAADCgMIBQAAAA==.',['硬朗']='硬朗男子:BAABLAAFFH8JAAILAAcI3w2xRwAtAQALAAcI3w2xRwAtAQAAAA==.',['祖师']='祖师婆:BAABLAAFFH8KAAIKAAUIzBaDNgA3AQAKAAUIzBaDNgA3AQABLAAFFAUIKAADAE0mAA==.',['神兜']='神兜兜的猫:BAAALAAECgYICQAAAA==.',['福禄']='福禄寿仙:BAAALAAECgUIBQAAAA==.',['离开']='离开以后:BAAALAAECgMIAwAAAA==.',['秀气']='秀气小犄角:BAABLAAECn8WAAIWAAYIjxLxtwBlAQAWAAYIjxLxtwBlAQAAAA==.',['秋色']='秋色无边:BAAALAAECgYIBgAAAA==.',['种花']='种花小当家:BAAALAAECgUIBQAAAA==.',['空谷']='空谷传声:BAABLAAFFH8FAAIdAAMIGA+dFQCTAAAdAAMIGA+dFQCTAAAAAA==.',['米且']='米且人:BAACLAAFFH8ZAAIFAAUIawtDKgAbAQAFAAUIawtDKgAbAQAsAAQKfzQAAgUACAjUFWohAOYBAAUACAjUFWohAOYBAAAA.',['粉丝']='粉丝鸡:BAAALAAECgYICQAAAA==.',['红栾']='红栾炮:BAAALAAECggICwAAAA==.',['红顶']='红顶水仙:BAAALAAECgYIDgAAAA==.',['组撒']='组撒噶扎台型:BAAALAAECgYIEgAAAA==.',['终场']='终场的困兽:BAACLAAFFH8NAAITAAIIiCCCGwC0AAATAAIIiCCCGwC0AAAsAAQKfxgAAhMACAhEHz8TAMICABMACAhEHz8TAMICAAAA.',['统一']='统一冰激凌:BAACLAAFFH8HAAIXAAIIKBNmFgBCAAAXAAIIKBNmFgBCAAAsAAQKfxQAAhcABghjGoctAMgBABcABghjGoctAMgBAAAA.',['绵绵']='绵绵沙冰:BAAALAADCggIEAAAAA==.',['老陳']='老陳:BAACLAAFFH80AAQhAAcI7yBlAABLAgAhAAcIhyBlAABLAgAKAAQIkyBZGwBjAQAYAAEIVhp5KABPAAAsAAQKfzUABCEACAhHImQEALcCACEACAgDH2QEALcCAAoACAhNHUU8AEkCABgAAggUIJJyAK4AAAEsAAUUCAgEACIAAAAA.',['耗子']='耗子扛枪:BAAALAAECgUICAAAAA==.',['舞动']='舞动双马尾:BAAALAAECggICAAAAA==.',['苍越']='苍越孤鸣:BAAALAADCgEIAQAAAA==.',['荔枝']='荔枝肉:BAACLAAFFH8dAAIWAAUINBiAJQBjAQAWAAUINBiAJQBjAQAsAAQKfzwAAxYACAh0IF0KAKECABYACAh0IF0KAKECABUABQgpDywYAOAAAAAA.',['莉亚']='莉亚德琳:BAACLAAFFH8WAAIGAAUIDxtwIwBVAQAGAAUIDxtwIwBVAQAsAAQKfzMAAgYACAhsJA4RADYDAAYACAhsJA4RADYDAAAA.',['菲尼']='菲尼克丝:BAAALAAECggIDwAAAA==.',['萨拉']='萨拉塔丝:BAAALAADCggICAAAAA==.',['萬歲']='萬歲:BAAALAAECgUIBQAAAA==.',['蒲公']='蒲公英的旅行:BAABLAAFFH8GAAIFAAII9x0pQgBVAAAFAAII9x0pQgBVAAAAAA==.',['蒼月']='蒼月丿刻印:BAAALAAECgIIAgAAAA==.',['蓝黑']='蓝黑色的忧伤:BAACLAAFFH8eAAIBAAUIiBr9EQBNAQABAAUIiBr9EQBNAQAsAAQKfyYAAgEACAhNH70LACECAAEACAhNH70LACECAAAA.',['薄荷']='薄荷叶:BAABLAAFFH8SAAIKAAQI5x0tPwD/AAAKAAQI5x0tPwD/AAAAAA==.',['薇薇']='薇薇安丶乔:BAAALAAECgIIAgAAAA==.薇薇安丶牧:BAAALAAECgYIBwAAAA==.',['虾仁']='虾仁不假演:BAABLAAFFH8MAAIWAAMI1RS7NwCgAAAWAAMI1RS7NwCgAAAAAA==.',['蜜糖']='蜜糖有毒:BAAALAAECgMIBAAAAA==.蜜糖橙:BAAALAAECgcICwAAAA==.',['術爷']='術爷:BAABLAAFFH8WAAQKAAUIpBkNMQBVAQAKAAUIpBkNMQBVAQAYAAEIuhIHKQBPAAAhAAEIiBf5BwBMAAABLAAFFAgIBAAiAAAAAA==.',['西瓜']='西瓜的皮:BAAALAAECgYIBwAAAA==.',['誘丶']='誘丶惑:BAAALAAECgMIAwAAAA==.',['许伯']='许伯里翁:BAAALAAFFAIIAgAAAA==.',['谁又']='谁又是谁的猫:BAAALAADCgEIAQAAAA==.',['谈谈']='谈谈:BAABLAAFFH8KAAIWAAYI4QuvDADbAQAWAAYI4QuvDADbAQAAAA==.',['貝恩']='貝恩血蹄:BAACLAAFFH8JAAIFAAIIsBGEUwBCAAAFAAIIsBGEUwBCAAAsAAQKfyQAAwUACAhuHOQwAHMCAAUACAhuHOQwAHMCAAQAAggMEvhEAHAAAAAA.',['赛博']='赛博坦之牙:BAABLAAFFH8GAAIjAAIITBD1DQAsAAAjAAIITBD1DQAsAAAAAA==.',['赫菲']='赫菲斯乇斯:BAAALAAECgQIBAAAAA==.',['走开']='走开别叫我抗:BAAALAAFFAIIAwAAAA==.',['跛豪']='跛豪:BAAALAAECggIEgAAAA==.',['踏雪']='踏雪風無痕:BAAALAAECgcIDgAAAA==.',['迷了']='迷了路的鹿:BAACLAAFFH8eAAMSAAUIMhT4MABCAQASAAUIMhT4MABCAQAXAAIIeBFxEwCHAAAsAAQKfzcAAxcACAiGIQUPALcCABcACAgEIAUPALcCABIACAj6HJ4qAKECAAAA.',['追丶']='追丶龍:BAABLAAFFH8IAAILAAMIqBz9aACUAAALAAMIqBz9aACUAAAAAA==.',['遇術']='遇術則鈈咑:BAAALAAECgEIAQAAAA==.',['邪恶']='邪恶师傅:BAAALAADCgMIAwAAAA==.邪恶师娘:BAAALAADCggICAAAAA==.',['邪能']='邪能侵蚀了我:BAAALAAFFAIIAgAAAA==.',['郁闷']='郁闷的牛牛:BAAALAAECgYIBwAAAA==.郁闷的龙战:BAAALAAECgcICgAAAA==.',['醉月']='醉月听雨:BAAALAAECgIIAgAAAA==.',['铁柱']='铁柱复仇:BAAALAAECgYIBgAAAA==.',['锋火']='锋火炼三月:BAAALAADCgQIBAAAAA==.',['锐血']='锐血:BAAALAAECgUIBQAAAA==.',['闪电']='闪电:BAAALAAECgYIDAAAAA==.',['阴阳']='阴阳人鲍勃:BAAALAAECgYICQAAAA==.',['阿佛']='阿佛洛荻忒:BAAALAAFFAIIBAAAAA==.',['阿叡']='阿叡斯:BAAALAAFFAIIAgAAAA==.',['阿赖']='阿赖耶识:BAAALAAECggIDQAAAA==.',['阿鲁']='阿鲁因丶青石:BAAALAAECgMIAwAAAA==.',['陈风']='陈风破浪:BAABLAAECn8bAAIRAAYI8xwUDwC2AQARAAYI8xwUDwC2AQAAAA==.',['雪落']='雪落:BAAALAAECgUIBQAAAA==.',['雪衣']='雪衣豆沙:BAABLAAFFH8eAAIDAAUIQxRnKwDrAAADAAUIQxRnKwDrAAAAAA==.',['雲那']='雲那個雲:BAABLAAFFH8eAAQTAAUIkyC5GQBhAQATAAQICx+5GQBhAQAUAAIIWAtjMgA/AAAjAAEIPgmkDwAmAAAAAA==.',['雷炮']='雷炮:BAAALAAECgYIEAAAAA==.',['露妮']='露妮吖:BAAALAAECgQIBAAAAA==.',['青眼']='青眼白狼:BAAALAAECgEIAQAAAA==.',['青螭']='青螭:BAAALAAFFAIIAgAAAA==.',['青霖']='青霖谣:BAAALAAECgIIAgAAAA==.',['风语']='风语竹心:BAAALAAFFAMIAwAAAA==.',['风走']='风走过的天空:BAABLAAECn8aAAMCAAgIlgwxVwB7AQACAAgIlgwxVwB7AQAaAAIInQQDOwA+AAAAAA==.',['飞猫']='飞猫精:BAABLAAFFH8JAAIXAAUI/A/cCAD9AAAXAAUI/A/cCAD9AAAAAA==.',['飞翔']='飞翔的白猪:BAAALAAECgYIDwAAAA==.',['香草']='香草喵露露:BAAALAAECggICgAAAA==.',['马向']='马向阳术记:BAAALAAECgUIBQAAAA==.',['鬼鬼']='鬼鬼火火:BAACLAAFFH8YAAIKAAUIngnJPwD5AAAKAAUIngnJPwD5AAAsAAQKfygAAgoACAj4E0pSAPoBAAoACAj4E0pSAPoBAAAA.',['鲩鲤']='鲩鲤鲍鱼:BAAALAADCgYIBgAAAA==.',['麦克']='麦克:BAAALAAFFAIIAgAAAA==.',['麦崖']='麦崖:BAACLAAFFH8iAAIGAAUIfBUVKwAqAQAGAAUIfBUVKwAqAQAsAAQKfzgAAgYACAgFIC0iABECAAYACAgFIC0iABECAAAA.',['麦王']='麦王:BAAALAAFFAIIAgAAAA==.',['麦琳']='麦琳:BAABLAAFFH8FAAIKAAII6BKEaAA4AAAKAAII6BKEaAA4AAAAAA==.',['麦麦']='麦麦噱鳕:BAABLAAFFH8FAAMXAAMIzArtDwBiAAAXAAMIzArtDwBiAAASAAEI7QGzbwAvAAAAAA==.麦麦嚼鳕:BAAALAAFFAIIBAAAAA==.麦麦沐慕:BAAALAAECgYICAAAAA==.',['黎明']='黎明:BAAALAAECggIDwAAAA==.',['黑利']='黑利丹:BAAALAAECgQIBAAAAA==.',['龙云']='龙云:BAABLAAFFH8RAAIKAAUIqwb2QADsAAAKAAUIqwb2QADsAAAAAA==.',['龙魂']='龙魂之最:BAABLAAECn8bAAILAAgIbBdWVgCXAQALAAgIbBdWVgCXAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end