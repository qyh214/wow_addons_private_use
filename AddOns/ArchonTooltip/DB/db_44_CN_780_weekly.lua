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
 local lookup = {'Druid-Restoration','Priest-Holy','Warlock-Destruction','Warlock-Demonology','Mage-Arcane','DeathKnight-Frost','DemonHunter-Havoc','Druid-Feral','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Fury','Hunter-Survival','Rogue-Assassination','Rogue-Subtlety','Shaman-Restoration','Druid-Balance','DemonHunter-Vengeance','DeathKnight-Unholy','Shaman-Elemental','Monk-Mistweaver','Druid-Guardian','Warrior-Protection','Rogue-Outlaw','Paladin-Retribution','DeathKnight-Blood','Mage-Frost','Warrior-Arms','Unknown-Unknown','Monk-Windwalker','Monk-Brewmaster','Evoker-Preservation','Evoker-Devastation','Priest-Discipline','Shaman-Enhancement','Priest-Shadow',}; local provider = {region='CN',realm='符文图腾',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acelyydd:BAABLAAFFH8IAAIBAAMIiBP5KgDDAAABAAMIiBP5KgDDAAAAAA==.',Ai='Aithpos:BAAALAAECgMIAwAAAA==.',Al='Alien:BAAALAAECggIDQAAAA==.',Am='Amni:BAAALAADCgQIBAAAAA==.',Ap='Apocalypse:BAAALAADCgYICAAAAA==.',Bl='Blueegg:BAAALAAECgYIBgAAAA==.',Ch='Chensoo:BAAALAAECgYIBgAAAA==.',Do='Doctere:BAABLAAFFH8PAAICAAYIWRiHGwByAQACAAYIWRiHGwByAQAAAA==.Doggie:BAABLAAECn8UAAMDAAgIdBDyXADZAQADAAgI9Q/yXADZAQAEAAMIFQxMcgCvAAAAAA==.',Ei='Eiie:BAAALAAECgUICQAAAA==.Einmyria:BAAALAAECgUIBwAAAA==.',Ev='Eveer:BAAALAADCgIIAgAAAA==.',Fg='Fgdjghjh:BAABLAAFFH8IAAIFAAgI+BopDAAlAgAFAAgI+BopDAAlAgAAAA==.',Fo='Forest:BAAALAAECgYIBAAAAA==.',Go='Goudan:BAAALAADCgMIAwAAAA==.',He='Heavensgate:BAABLAAECn8bAAIGAAgI1htqawAfAgAGAAgI1htqawAfAgAAAA==.Helishow:BAAALAAECgIIAgAAAA==.',Ko='Komo:BAAALAAECgYIDAAAAA==.',Ma='Martinan:BAABLAAECn8bAAIHAAYIfxHLVAAdAQAHAAYIfxHLVAAdAQAAAA==.',Me='Medk:BAAALAAFFAEIAQAAAA==.',Oc='Ocean:BAAALAAECgIIAgAAAA==.',Pg='Pgg:BAABLAAFFH8GAAIFAAII0w7XSwCUAAAFAAII0w7XSwCUAAAAAA==.',Ry='Ryzen:BAABLAAFFH8IAAIIAAIILw5GDQCaAAAIAAIILw5GDQCaAAAAAA==.',Se='Seasons:BAAALAAECgEIAQAAAA==.',So='Sophtia:BAAALAAECgYIBgAAAA==.',Sp='Spr:BAAALAAECgYIBgAAAA==.',Um='Umika:BAABLAAFFH8NAAIGAAMIRhyPJgD/AAAGAAMIRhyPJgD/AAAAAA==.Umikk:BAAALAAECgQIBAAAAA==.',Wo='Worlfugun:BAAALAAECgIIAgAAAA==.',Wu='Wudishushi:BAAALAAECgUIBQAAAA==.',Zz='Zzga:BAABLAAFFH8SAAIJAAYIGSD/BgAfAgAJAAYIGSD/BgAfAgAAAA==.',['一个']='一个小朋友:BAAALAADCgQIBAAAAA==.',['一灰']='一灰烬之刃一:BAAALAAECgYICQAAAA==.',['一百']='一百多个戦士:BAAALAAFFAIIAgAAAA==.',['一箭']='一箭一小朋友:BAABLAAECn8UAAIKAAYIDxbppQARAQAKAAYIDxbppQARAQAAAA==.',['一精']='一精灵骑士一:BAAALAAECggICAAAAA==.',['一缕']='一缕青丝:BAABLAAFFH8GAAIHAAIILQgDaAA3AAAHAAIILQgDaAA3AAAAAA==.',['一西']='一西毒一:BAAALAAECgYICwAAAA==.',['一阿']='一阿休罗一:BAAALAAECgYICwAAAA==.',['七夜']='七夜应月:BAAALAADCgYIBgAAAA==.七夜破军:BAAALAADCgIIAgAAAA==.',['七尺']='七尺大儒:BAAALAAFFAIIAgAAAA==.',['三十']='三十六变:BAAALAAECgYIEgAAAA==.',['三杯']='三杯倒:BAAALAAECgUIBwAAAA==.',['三花']='三花聚顶:BAAALAADCgMIAwAAAA==.',['上善']='上善如水:BAAALAADCgUIBQAAAA==.',['下山']='下山抓绵羊:BAACLAAFFH8LAAMLAAMIZwsjHwCMAAALAAMINgMjHwCMAAAKAAMIZwtVegBmAAAsAAQKfzMAAwoACAi1HmxGAFYCAAoACAi1HmxGAFYCAAsABgilEkdbAE0BAAAA.',['不乖']='不乖不可爱:BAAALAAECgcIDQAAAA==.',['不明']='不明不白大小:BAAALAAECgIIAgAAAA==.',['与时']='与时:BAACLAAFFH8LAAIMAAMIPwq2HgDSAAAMAAMIPwq2HgDSAAAsAAQKfzEAAgwACAgvGBNBADECAAwACAgvGBNBADECAAAA.',['业余']='业余的狼:BAAALAADCgQIBAAAAA==.',['丨妮']='丨妮児:BAABLAAFFH8fAAMDAAYINAwjMQBTAQADAAYINAwjMQBTAQAEAAIIaQibGgCNAAAAAA==.',['中门']='中门对狙:BAAALAADCgQIBAAAAA==.',['临海']='临海:BAAALAAFFAMIAwAAAA==.',['丶尐']='丶尐夜:BAABLAAFFH8kAAMNAAUInRusAQDyAAAKAAUInRv3PgBKAQANAAMIzQ+sAQDyAAAAAA==.',['丶火']='丶火苗:BAAALAAECgYICgAAAA==.',['丿柔']='丿柔骨小牧丿:BAAALAAECgYICwAAAA==.',['乌妖']='乌妖王大表哥:BAABLAAFFH8GAAIGAAII6gghhACEAAAGAAII6gghhACEAAAAAA==.',['乔治']='乔治基维斯:BAACLAAFFH8GAAMOAAMIZA+xFwCgAAAOAAIIxg2xFwCgAAAPAAEInxK5HABDAAAsAAQKfyAAAw4ACAirH7wOALICAA4ACAirH7wOALICAA8ABAj2FWIyAA0BAAAA.',['二莽']='二莽子:BAAALAAECgEIAQAAAA==.',['云深']='云深不知处:BAAALAAECgYIEwAAAA==.',['云璃']='云璃:BAAALAAECgMIAwAAAA==.',['云间']='云间月:BAAALAAECgEIAQAAAA==.',['亚洲']='亚洲舞王:BAABLAAFFH8KAAIHAAMIlAnHMACoAAAHAAMIlAnHMACoAAAAAA==.',['亡者']='亡者:BAAALAAECgcIDQAAAA==.',['人族']='人族圣体:BAAALAAECgYIBgAAAA==.',['亿尘']='亿尘不染:BAAALAAECgEIAQAAAA==.',['什么']='什么憨憨职业:BAAALAAFFAEIAQAAAA==.',['今夜']='今夜打虎虎:BAAALAAFFAIIBAAAAA==.',['今天']='今天打虎虎:BAACLAAFFH8fAAIGAAUIWBuYPABIAQAGAAUIWBuYPABIAQAsAAQKfxQAAgYABwiIHw9FAHMCAAYABwiIHw9FAHMCAAAA.',['仙贝']='仙贝:BAABLAAFFH8KAAIFAAIIiAx7WQCGAAAFAAIIiAx7WQCGAAAAAA==.',['以徳']='以徳服人:BAAALAAECgYIBgAAAA==.',['仲夏']='仲夏沫之恋:BAABLAAFFH8JAAICAAMIShmCKQDgAAACAAMIShmCKQDgAAAAAA==.',['伊伊']='伊伊布兰达:BAAALAAECggIEAAAAA==.',['伊力']='伊力蛋怒风:BAABLAAFFH8JAAIHAAYILhlmHACTAQAHAAYILhlmHACTAQAAAA==.',['你个']='你个鳖孙:BAAALAAFFAIIAgAAAA==.',['你还']='你还在嘛:BAAALAAFFAIIBAAAAA==.',['侏侏']='侏侏与儒儒:BAACLAAFFH8QAAIEAAIICCBlEACjAAAEAAIICCBlEACjAAAsAAQKfyMAAgQACAjmH/4CAIkCAAQACAjmH/4CAIkCAAAA.',['依旧']='依旧憧憬:BAAALAAFFAIIAgAAAA==.',['俄赛']='俄赛里斯:BAAALAAFFAIIBAABLAAFFAIIDAAGAJcZAA==.',['俺们']='俺们村里最瘦:BAAALAADCgIIAgAAAA==.',['俺是']='俺是白牛:BAABLAAFFH8GAAIQAAII4Q4rWwBlAAAQAAII4Q4rWwBlAAAAAA==.',['僵丝']='僵丝坦丁:BAAALAAECgYIBgAAAA==.',['光明']='光明丿荣耀:BAAALAADCgEIAQAAAA==.',['养一']='养一个嘎一个:BAAALAADCgUIBQAAAA==.',['冥姬']='冥姬:BAAALAAECgYIBgAAAA==.',['冰冷']='冰冷易水寒:BAAALAAECgYIEgAAAA==.',['冰封']='冰封之忻:BAAALAADCggICAAAAA==.冰封乱城:BAAALAAECgcIBwAAAA==.',['冰雨']='冰雨残阳:BAAALAAECgYIBgAAAA==.冰雨流星:BAAALAAECgYIBgAAAA==.冰雨狂魔:BAAALAADCgIIAgAAAA==.',['冰霜']='冰霜万里:BAAALAAECgYIDAAAAA==.',['冷月']='冷月:BAABLAAFFH8GAAIRAAYI0wpKFgAqAQARAAYI0wpKFgAqAQAAAA==.',['凯珐']='凯珐囧咕:BAAALAAECgQIBAAAAA==.凯珐囧玖:BAAALAADCgcIBwAAAA==.',['初十']='初十:BAABLAAECn8WAAIDAAYIchSURQAzAQADAAYIchSURQAzAQAAAA==.',['勇敢']='勇敢牛牛啊:BAAALAAECgYIEAAAAA==.',['勥氼']='勥氼:BAACLAAFFH8KAAIMAAIIeh9KJwCqAAAMAAIIeh9KJwCqAAAsAAQKfzkAAgwACAhHIsYKAKQCAAwACAhHIsYKAKQCAAAA.',['十步']='十步一杀:BAAALAAFFAIIBAAAAA==.十步殺壹人:BAAALAAFFAEIAQAAAA==.',['千穗']='千穗:BAAALAAECgcIDgAAAA==.',['千金']='千金买邻:BAAALAAECggIDAAAAA==.',['半面']='半面不怠:BAACLAAFFH8LAAISAAMIOQ3YCQCoAAASAAMIOQ3YCQCoAAAsAAQKfykAAhIACAipFBUcAN0BABIACAipFBUcAN0BAAAA.半面痴狂:BAAALAAECgYICwAAAA==.',['单蓝']='单蓝色:BAAALAAECgUIBgAAAA==.',['卟饰']='卟饰劣人:BAAALAAECgYIDAAAAA==.',['卿尘']='卿尘:BAABLAAFFH8GAAIRAAIImA0AMgA/AAARAAIImA0AMgA/AAABLAAFFAIIDAAGAJcZAA==.',['原野']='原野战狼:BAAALAAECgYICgAAAA==.',['变起']='变起花样整:BAAALAAECgYIBgAAAA==.',['古力']='古力娜扎灬:BAAALAAECgMIBAAAAA==.',['古尓']='古尓丹:BAAALAAECgQIBAAAAA==.',['可可']='可可宝贝:BAAALAAFFAIIAgAAAA==.',['叶师']='叶师兄:BAABLAAFFH8mAAMGAAYIShYcKQCSAQAGAAYIShYcKQCSAQATAAMI5gg2CQDYAAAAAA==.',['司羊']='司羊仙:BAABLAAFFH8UAAMQAAYIrh1dEADjAQAQAAYIrh1dEADjAQAUAAEI6QF+TwA1AAAAAA==.',['司马']='司马仙:BAABLAAFFH8NAAIVAAYIxBlxBgDbAQAVAAYIxBlxBgDbAQAAAA==.',['吾且']='吾且任吾囚:BAAALAAECgEIAQAAAA==.',['呆小']='呆小萌可爱:BAAALAAFFAIIBAAAAA==.',['哀姆']='哀姆踢:BAAALAAECgIIAgAAAA==.',['哆丶']='哆丶哆:BAABLAAFFH8MAAIVAAYIexjxBgDMAQAVAAYIexjxBgDMAQAAAA==.哆丶啦:BAACLAAFFH8TAAMBAAYIBhmQDgDWAQABAAYIBhmQDgDWAQARAAEIuQQ9OQA0AAAsAAQKfx0ABAEACAjUICcMAIsCAAEACAjUICcMAIsCABEABAhLEt55AN4AABYAAQj2B98rACAAAAAA.',['哆啦']='哆啦啦:BAAALAAFFAIIBAAAAA==.',['哈托']='哈托尔:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['哈起']='哈起一坨:BAAALAAECgYICQAAAA==.',['哈默']='哈默迪:BAAALAAECgYIDAABLAAFFAIIDAAGAJcZAA==.',['哲别']='哲别:BAAALAAECgUICgAAAA==.',['唉沐']='唉沐踢:BAABLAAECn8kAAMXAAYIWQ75MQDUAAAMAAYIdAxCoQBCAQAXAAYI9gz5MQDUAAAAAA==.',['唯我']='唯我忆风尘:BAABLAAECn8hAAIKAAYIMx5KaAByAQAKAAYIMx5KaAByAQAAAA==.',['喜儿']='喜儿瓦拉斯:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血起速度灭:BAAALAAECgYIBgAAAA==.',['嘎的']='嘎的一下抽了:BAAALAADCgUIBQAAAA==.',['嘚比']='嘚比嘚的德:BAACLAAFFH8zAAQRAAYIDCU8BgANAgARAAYIDCU8BgANAgABAAUIuhqOFwB2AQAWAAIIWBhCCgBLAAAsAAQKfykAAxEACAgWJBwIADoDABEACAgWJBwIADoDAAEAAgjuIymrALwAAAEsAAUUCAgJAAEAagIA.',['嘟嘟']='嘟嘟大水怪:BAAALAAECggICAAAAA==.',['噢卟']='噢卟饰劣人:BAAALAAFFAEIAQAAAA==.',['因为']='因为所以:BAACLAAFFH8GAAIUAAMIlRUaJACgAAAUAAMIlRUaJACgAAAsAAQKfxkAAhQACAgGGo4tAFoCABQACAgGGo4tAFoCAAAA.',['圆兜']='圆兜兜:BAAALAADCgMIAwAAAA==.',['圈圈']='圈圈波比:BAAALAAECgYICAABLAAFFAIICAAKACEgAA==.',['圣光']='圣光忽悠着妳:BAAALAAECgMIAwAAAA==.圣光的奶:BAAALAAECgYIBgAAAA==.',['圥忈']='圥忈甲:BAAALAAECgMIAwAAAA==.',['型男']='型男的小号:BAAALAAECgUICgAAAA==.',['埃西']='埃西斯:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['埋葬']='埋葬我的愛:BAAALAAECgEIAQAAAA==.',['堕落']='堕落的血法:BAABLAAECn8ZAAIFAAYIbhSMNAA/AQAFAAYIbhSMNAA/AQAAAA==.堕落迪萨:BAAALAADCgQIBAAAAA==.',['塞赫']='塞赫美特:BAABLAAFFH8GAAIYAAII9gl4BQBDAAAYAAII9gl4BQBDAAABLAAFFAIIDAAGAJcZAA==.',['壹隊']='壹隊倵僧:BAABLAAFFH8LAAIZAAII/hiyOwChAAAZAAII/hiyOwChAAAAAA==.',['夕尧']='夕尧紫龙:BAAALAAECgYICAAAAA==.',['夜幕']='夜幕之刃:BAAALAAECgUIBQAAAA==.',['夜影']='夜影契约:BAAALAAECgYIBgAAAA==.',['夜色']='夜色微明:BAAALAAECgIIAgAAAA==.夜色萌萌:BAAALAAECgYIEAAAAA==.',['大伐']='大伐克尔:BAAALAAECgYIBgAAAA==.',['大橘']='大橘猫:BAAALAAECgYICQAAAA==.',['大白']='大白兔奶牛:BAABLAAFFH8GAAIBAAIIExArOwBlAAABAAIIExArOwBlAAAAAA==.',['天亡']='天亡天下:BAAALAAFFAIIAgAAAA==.',['天树']='天树:BAAALAAFFAIIBAAAAA==.',['天火']='天火憨儿:BAAALAAECgYICQAAAA==.',['天谴']='天谴之光:BAAALAAECggICAAAAA==.',['天车']='天车上搞锤子:BAACLAAFFH8JAAMKAAII4hTAlwBBAAAKAAII4hTAlwBBAAALAAEIxwYFOAA3AAAsAAQKfx4AAwoACAhLGuNhABgCAAoACAgmGuNhABgCAAsABgiYEHdgADwBAAAA.',['失落']='失落寒冬:BAAALAAECgYIDQAAAA==.',['奇美']='奇美拉:BAAALAADCgEIAQAAAA==.',['奈何']='奈何一叶知秋:BAACLAAFFH8ZAAIGAAYI/RdYIgCrAQAGAAYI/RdYIgCrAQAsAAQKfxwAAwYACAjwISkfAPMCAAYACAjwISkfAPMCABoACAi/DpckAF0BAAAA.奈何雪落无声:BAACLAAFFH8GAAIbAAMIsAv2DgBvAAAbAAMIsAv2DgBvAAAsAAQKfxUAAwUACAiJEih2AKoBAAUABwheESh2AKoBABsAAgh7FUx3AI4AAAAA.',['奈芙']='奈芙蒂斯:BAABLAAFFH8KAAIKAAIIUxOSWACQAAAKAAIIUxOSWACQAAABLAAFFAIIDAAGAJcZAA==.',['奥格']='奥格带头大哥:BAAALAAECgEIAQAAAA==.',['奥西']='奥西里斯:BAABLAAFFH8MAAIGAAIIlxlvdgBLAAAGAAIIlxlvdgBLAAAAAA==.',['女神']='女神凉冰:BAAALAADCggICAAAAA==.',['奶油']='奶油沼泽岛:BAAALAAFFAIIBAABLAAFFAIIDAAFAPMhAA==.',['奶锤']='奶锤:BAACLAAFFH8qAAIJAAYIAx9PCQDyAQAJAAYIAx9PCQDyAQAsAAQKfxwAAgkABwi6HzoOAA4CAAkABwi6HzoOAA4CAAAA.',['她摸']='她摸我:BAAALAAFFAIIAwAAAA==.',['好把']='好把他们上市:BAAALAAECgIIAgAAAA==.',['好耍']='好耍第三:BAAALAAECgYIBgAAAA==.',['如故']='如故:BAAALAAECggICAAAAA==.',['如画']='如画灬:BAAALAAECgYICQAAAA==.',['孤身']='孤身走暗巷:BAAALAAECgYICAAAAA==.',['安妮']='安妮:BAAALAAECgYIEQAAAA==.',['安舍']='安舍:BAACLAAFFH8oAAIZAAYI2RzWEgCyAQAZAAYI2RzWEgCyAQAsAAQKf1AAAhkACAi6JCsSADADABkACAi6JCsSADADAAAA.',['安逸']='安逸哈:BAAALAAECgMIAwAAAA==.',['宋老']='宋老师:BAABLAAFFH8iAAMMAAYIShrdFAC0AQAMAAYIShrdFAC0AQAcAAEIuQOrCQA0AAAAAA==.',['宝芝']='宝芝灵:BAAALAADCgcIBwAAAA==.',['宠妃']='宠妃風莫羽:BAACLAAFFH8qAAIQAAYIOxldFQC1AQAQAAYIOxldFQC1AQAsAAQKfxYAAhAABgitI0I4ADcCABAABgitI0I4ADcCAAAA.',['寂灭']='寂灭之影:BAAALAADCgIIAgAAAA==.',['小呆']='小呆爷爷:BAABLAAECn8bAAMXAAgIFxlrHgA/AgAXAAgIFxlrHgA/AgAMAAIIMgil/QBVAAAAAA==.',['小小']='小小护士:BAABLAAFFH8OAAICAAIIPh5SIQC3AAACAAIIPh5SIQC3AAAAAA==.',['小屋']='小屋的倆人:BAAALAADCgUIBQAAAA==.',['小汤']='小汤圆软软:BAABLAAFFH8RAAIZAAYI5CKzCgDwAQAZAAYI5CKzCgDwAQAAAA==.',['小泽']='小泽老师:BAAALAAECgMIAwAAAA==.',['小涵']='小涵涵:BAAALAAECgUIBQABLAAFFAQIBAAdAAAAAA==.',['小白']='小白心里软:BAAALAAFFAIIAgAAAA==.',['小胖']='小胖囡囡:BAABLAAFFH8GAAMKAAIIhg74bACCAAAKAAIIhg74bACCAAALAAEIUQ1PNgA8AAAAAA==.小胖沐沐:BAABLAAFFH8KAAIHAAIIUBXKPgCaAAAHAAIIUBXKPgCaAAAAAA==.',['小蓝']='小蓝莓:BAAALAADCgEIAQAAAA==.',['小路']='小路飛:BAAALAAECgUIBwAAAA==.',['小酒']='小酒窝丶:BAABLAAFFH8GAAIQAAIIWwwDYgBZAAAQAAIIWwwDYgBZAAAAAA==.',['小鲍']='小鲍快跑:BAABLAAECn8UAAMZAAgIYSJ6CwC3AgAZAAgIYSJ6CwC3AgAJAAEIVAjbRgAkAAAAAA==.',['少刷']='少刷抖音:BAAALAAECgYIBwAAAA==.',['就地']='就地正法:BAAALAAECgEIAQAAAA==.',['局部']='局部放电:BAAALAAECgYIBgAAAA==.',['山炮']='山炮大术:BAAALAAFFAIIBAAAAA==.',['左手']='左手捏蛋:BAAALAAECgYIBgAAAA==.',['左老']='左老师:BAABLAAFFH8FAAMKAAUIhhNgKwDTAAAKAAMIVhlgKwDTAAALAAIIzwo+HQCTAAAAAA==.',['巴比']='巴比隆丶卤蹄:BAABLAAECn8UAAMQAAcIyxqbQAAcAgAQAAcIyxqbQAAcAgAUAAUIqAEiwgBeAAAAAA==.',['布衣']='布衣买清闲:BAAALAAECgQIBAAAAA==.',['希尔']='希尔莉亚:BAAALAAECggIEAAAAA==.',['希爾']='希爾瓦娜斯丶:BAAALAAECgIIAgAAAA==.',['希瓦']='希瓦娜斯:BAACLAAFFH8MAAMKAAMIVRaULgDKAAAKAAMI7RKULgDKAAALAAIIjhbMIACHAAAsAAQKfzcAAwoACAi6IbozAIwCAAoABwhIIbozAIwCAAsACAgDHfkdAHYCAAAA.',['带带']='带带小师姐:BAAALAAECgYICQAAAA==.',['幸福']='幸福陪伴你:BAAALAAECgYIDwAAAA==.',['康拉']='康拉德科兹:BAAALAADCgUIBgAAAA==.',['异曈']='异曈:BAAALAAECgYIBgAAAA==.',['张沉']='张沉心丶:BAAALAAECgYIBgAAAA==.',['强大']='强大的米尔:BAAALAAECgYICgAAAA==.',['彩瓷']='彩瓷:BAAALAAECgQIBAAAAA==.',['御风']='御风亚索:BAAALAAECgYIEQAAAA==.',['忧郁']='忧郁小猫猫:BAAALAADCgcIBwAAAA==.',['快驱']='快驱散:BAACLAAFFH8JAAMEAAMINhwTCwC1AAAEAAIIkSETCwC1AAADAAMIfBGCRgCQAAAsAAQKfyoAAwQACAjvITUPAIgCAAMACAhtHskiAL8CAAQACAjtHzUPAIgCAAAA.',['性格']='性格好脾气躁:BAAALAADCgEIAQAAAA==.',['恶魔']='恶魔猎少女:BAAALAAFFAIIAgAAAA==.',['悄然']='悄然花开:BAAALAAECgMIAwAAAA==.',['懒觉']='懒觉睡天天:BAAALAADCgcIBwAAAA==.',['懦夫']='懦夫克星:BAAALAADCggICAAAAA==.',['成都']='成都市战神:BAAALAAECgQIBAAAAA==.',['我不']='我不是绵花:BAAALAAFFAEIAQAAAA==.',['我只']='我只能卖萌:BAABLAAFFH8MAAMBAAYIJQ52GgBZAQABAAYIJQ52GgBZAQARAAUI9g5PGgAEAQAAAA==.',['我想']='我想要变强丶:BAAALAAECgEIAQAAAA==.',['我是']='我是一头鹿:BAAALAAECgYIBgAAAA==.',['我有']='我有奶:BAAALAADCgUIBQAAAA==.',['我爱']='我爱吃乳酪:BAAALAAFFAIIAgAAAA==.我爱喝大窑:BAAALAAFFAIIBAAAAA==.',['我脸']='我脸疼:BAABLAAFFH8GAAIZAAII5g0OdAA7AAAZAAII5g0OdAA7AAAAAA==.',['我说']='我说改天吧丶:BAAALAAECgYICQAAAA==.',['战神']='战神老白:BAAALAAECgYIBgAAAA==.',['把头']='把头发盘起来:BAAALAAFFAIIBAAAAA==.',['折耳']='折耳根杀手:BAAALAAECgIIAgAAAA==.',['拂衣']='拂衣而去:BAAALAAECgIIBAAAAA==.',['掉线']='掉线喵:BAABLAAFFH8MAAIYAAIIpiO4AgDPAAAYAAIIpiO4AgDPAAAAAA==.',['提拉']='提拉米蘇:BAAALAAECgUIBgAAAA==.',['擎擎']='擎擎车:BAAALAAECgYIBgAAAA==.',['放开']='放开那群太婆:BAAALAADCgIIAgAAAA==.',['旋风']='旋风冰火:BAABLAAFFH8SAAIMAAYIxxcmGQCZAQAMAAYIxxcmGQCZAQAAAA==.旋风大锤:BAAALAAECgYIBwAAAA==.',['无限']='无限绵延的心:BAABLAAFFH8IAAIbAAIIPgu9GAB2AAAbAAIIPgu9GAB2AAAAAA==.',['旺小']='旺小圣:BAAALAAFFAIIAwAAAA==.',['旺财']='旺财小吗:BAACLAAFFH8IAAICAAMIxwrHHQDLAAACAAMIxwrHHQDLAAAsAAQKfyUAAgIACAiKDixSAI4BAAIACAiKDixSAI4BAAAA.旺财泡泡糖:BAAALAAECgYICwAAAA==.',['昆仑']='昆仑镜:BAACLAAFFH8OAAIJAAYI0A6PEADcAAAJAAYI0A6PEADcAAAsAAQKfxwAAgkACAgZHxcRAIoCAAkACAgZHxcRAIoCAAAA.',['明月']='明月地:BAAALAAECgIIAgAAAA==.',['明步']='明步老师:BAAALAADCggICAAAAA==.',['星域']='星域:BAAALAADCgIIAgAAAA==.',['星空']='星空迷彩:BAAALAAECgcIDQAAAA==.',['昭月']='昭月炫星辰:BAAALAAECgYIDAAAAA==.',['是大']='是大叔啊:BAABLAAFFH8GAAIQAAIILhFWSwBvAAAQAAIILhFWSwBvAAAAAA==.',['是美']='是美丽啊:BAABLAAFFH8FAAMUAAMIEgXTOgBkAAAUAAMIEgXTOgBkAAAQAAIIrQj5XABiAAAAAA==.',['智商']='智商无:BAAALAAECgEIAQAAAA==.',['暂时']='暂时:BAAALAAECgYIBgAAAA==.',['暮色']='暮色银月:BAABLAAECn8UAAIeAAYIAhebLgCYAQAeAAYIAhebLgCYAQABLAAFFAIIDAAGAJcZAA==.',['暴躁']='暴躁的秋裤:BAAALAAECgYIBgAAAA==.',['曾经']='曾经未来之王:BAABLAAFFH8SAAIXAAYIsgePFgD+AAAXAAYIsgePFgD+AAAAAA==.',['月影']='月影成双:BAAALAAECgMIBAAAAA==.',['月明']='月明:BAAALAAECgYIBgAAAA==.',['有德']='有德必有尸:BAAALAADCgIIAgAAAA==.',['未尽']='未尽的幸福:BAAALAAECgYICQAAAA==.',['本服']='本服第一萌:BAAALAAECgYIBgAAAA==.',['杀死']='杀死蛋蛋:BAACLAAFFH8KAAMEAAIIyQxzGwCKAAAEAAIIyQxzGwCKAAADAAEICwMccgAmAAAsAAQKfxYAAwMACAj+FN+GAHEBAAMABwjGDt+GAHEBAAQABQjDFD0fANgAAAAA.',['村头']='村头大美丽:BAABLAAFFH8JAAMUAAMImgeFHwC3AAAUAAMImgeFHwC3AAAQAAIIAAZZYwBdAAAAAA==.',['杜康']='杜康:BAABLAAECn8VAAIfAAYIHgTLPACyAAAfAAYIHgTLPACyAAAAAA==.',['来吖']='来吖互相伤害:BAAALAAFFAIIAgAAAA==.',['来回']='来回插:BAAALAAFFAIIAgAAAA==.',['松老']='松老师:BAAALAAECgYICgAAAA==.',['极速']='极速野蛮:BAAALAAECgYIBgAAAA==.',['枫桥']='枫桥夜泊丶:BAAALAADCggIDgAAAA==.',['柠檬']='柠檬奶油包:BAABLAAFFH8MAAMFAAII8yFaNQC0AAAFAAII8yFaNQC0AAAbAAEIQhmsHgBIAAAAAA==.',['核桃']='核桃仔:BAAALAAECgQIBgAAAA==.',['桃兔']='桃兔兔:BAAALAAECgYIDgAAAA==.',['梅川']='梅川裤子:BAACLAAFFH8IAAIZAAIIUgvmVQCMAAAZAAIIUgvmVQCMAAAsAAQKfxUAAhkABwgPFHOSAM0BABkABwgPFHOSAM0BAAAA.',['梦之']='梦之约定:BAAALAAECgcICQAAAA==.',['梦灵']='梦灵画银潭:BAAALAAECgYIDAAAAA==.',['梨三']='梨三蒸三酿:BAAALAAECgEIAQAAAA==.',['梨天']='梨天行:BAAALAAECgIIAgAAAA==.',['梨留']='梨留香:BAABLAAECn8lAAIKAAgI0heecgD3AQAKAAgI0heecgD3AQAAAA==.',['梨花']='梨花压海棠:BAAALAAECgYICAAAAA==.',['椎名']='椎名林檎:BAABLAAFFH8GAAIHAAMIIBr+GwD9AAAHAAMIIBr+GwD9AAAAAA==.',['椰子']='椰子粒儿:BAAALAAECgYIBgAAAA==.',['樱田']='樱田明日花:BAAALAAECgcICQAAAA==.',['橙小']='橙小战:BAAALAAECgYIDAAAAA==.橙小麦:BAABLAAECn8XAAIKAAgIAB93GwBXAgAKAAgIAB93GwBXAgAAAA==.',['款款']='款款:BAAALAAFFAMIAwAAAA==.',['死弑']='死弑:BAAALAAECggICwAAAA==.',['水丨']='水丨水:BAAALAAFFAIIAgAAAA==.',['水墨']='水墨丨灬星垂:BAAALAAECgYIBgAAAA==.',['水妖']='水妖儿:BAAALAAECgYIBgAAAA==.',['水风']='水风电火石:BAAALAAECgQIBAAAAA==.',['没穿']='没穿裤子:BAAALAAECgYIBgAAAA==.',['沫沫']='沫沫大人:BAABLAAFFH8VAAIKAAYIxRxCLQCBAQAKAAYIxRxCLQCBAQAAAA==.',['油炸']='油炸薯条:BAAALAAECgYIBwAAAA==.',['波波']='波波可乐:BAAALAAECgYIBgAAAA==.',['泪的']='泪的肉肉:BAAALAAECgYIBgAAAA==.',['泰芙']='泰芙努特:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['流星']='流星冰雨:BAAALAAECgYIDAAAAA==.',['流窜']='流窜作案:BAAALAAECggICwAAAA==.',['浅浅']='浅浅菊花:BAAALAAECgcICAAAAA==.',['浪漫']='浪漫的莽子:BAACLAAFFH8UAAMMAAUIWxmXGAABAQAMAAUIWxmXGAABAQAXAAIIrAOqLgBcAAAsAAQKfyAAAwwACAh2H7krAI0CAAwACAiEHLkrAI0CABwABwjgGqQNAPoBAAAA.',['浮小']='浮小桐:BAAALAAECgYIDAAAAA==.',['海姆']='海姆赫尔:BAAALAAECgYIBgAAAA==.',['淡看']='淡看江湖丶:BAABLAAFFH8JAAIZAAUIpBc/JgBEAQAZAAUIpBc/JgBEAQAAAA==.',['滚弹']='滚弹子娃娃:BAABLAAFFH8GAAIHAAIIlxZvNwCgAAAHAAIIlxZvNwCgAAAAAA==.',['滚滚']='滚滚套饭:BAAALAADCgQIBAAAAA==.',['漠烟']='漠烟烟:BAACLAAFFH8LAAIFAAMI/hQOLADiAAAFAAMI/hQOLADiAAAsAAQKfyYAAwUACAhSHQ4uAJMCAAUACAhSHQ4uAJMCABsAAwjKEGd4AIgAAAEsAAUUCAgMAAUA5RwA.',['潶德']='潶德贰逼:BAAALAADCgYIBgAAAA==.',['火焚']='火焚城郭:BAAALAADCgYIBgAAAA==.',['火苗']='火苗丶:BAAALAAECgEIAQAAAA==.',['灬隔']='灬隔壁老仇灬:BAAALAAFFAIIAgAAAA==.',['灵异']='灵异之血:BAACLAAFFH8ZAAIMAAYIFxDNHACCAQAMAAYIFxDNHACCAQAsAAQKfyMAAgwACAjlFbYuAKABAAwACAjlFbYuAKABAAAA.',['灵芸']='灵芸:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['烬雪']='烬雪栖画:BAAALAAECgYIDwAAAA==.',['煤山']='煤山黑狐:BAAALAAECgYICQAAAA==.',['熊出']='熊出没:BAAALAAECgQIBAAAAA==.',['熔化']='熔化:BAAALAAFFAIIAgAAAA==.',['爆米']='爆米花二号:BAAALAAECggICAAAAA==.爆米花五号:BAAALAAFFAEIAQAAAA==.',['爱情']='爱情暖暖:BAAALAAFFAYIBAAAAA==.',['爱神']='爱神丘比特:BAAALAAFFAYIBAAAAA==.',['牛哒']='牛哒力:BAAALAADCgYIBgAAAA==.',['牛油']='牛油果:BAAALAAECgUICgAAAA==.',['物理']='物理易伤:BAAALAAECgYIBgAAAA==.',['特莉']='特莉丝:BAAALAADCgYIBgAAAA==.',['狂暴']='狂暴丶喵:BAAALAAECgYIEgAAAA==.',['狂野']='狂野生存:BAABLAAECn8UAAMBAAcIwhAHaABdAQABAAcIwhAHaABdAQAWAAYIFgRpKgCyAAAAAA==.',['狗子']='狗子你变了:BAAALAAECgYIBgAAAA==.',['独奏']='独奏千本桜丶:BAABLAAFFH8MAAIGAAYI7hwIHADGAQAGAAYI7hwIHADGAQABLAAFFAgIDAAKAKEcAA==.',['狼兄']='狼兄:BAABLAAFFH8MAAIGAAMIWBUdWwCZAAAGAAMIWBUdWwCZAAAAAA==.',['王德']='王德丶法:BAABLAAFFH8IAAMgAAYI0xSyDgBPAQAgAAUI2ReyDgBPAQAhAAEIwwEcIwAyAAAAAA==.',['玖尾']='玖尾奶魅:BAACLAAFFH8KAAIQAAMIEQmRPACHAAAQAAMIEQmRPACHAAAsAAQKfyEAAhAACAg4DdiYAE0BABAACAg4DdiYAE0BAAAA.',['珍妮']='珍妮玛丶士多:BAAALAAECgcIEAAAAA==.',['瑞卡']='瑞卡多:BAAALAAECgYIDAAAAA==.',['瓜天']='瓜天蛆影:BAACLAAFFH8jAAMTAAUIJRWXBQBGAQATAAUIqROXBQBGAQAGAAQIxA4jUgDPAAAsAAQKfx0AAxMACAhjGCMkAJwBAAYABwghFEupALkBABMACAikFyMkAJwBAAAA.',['男神']='男神你山哥:BAABLAAFFH8JAAMQAAgIDxH1EQArAQAQAAcI+A71EQArAQAUAAEILwPvPABKAAAAAA==.',['當歌']='當歌:BAAALAAECgEIAQAAAA==.',['疯子']='疯子捅他:BAAALAAECgMIBAAAAA==.',['疾风']='疾风之铃音:BAAALAAECgEIAQAAAA==.',['痞子']='痞子丶笨蛋:BAABLAAFFH8LAAIFAAYIcRFzKAByAQAFAAYIcRFzKAByAQAAAA==.',['白桃']='白桃慕斯丶:BAACLAAFFH8JAAICAAUIkgmgJAAXAQACAAUIkgmgJAAXAQAsAAQKfxQAAyIABgh8DakqAJUAAAIABgi+CmB+AAQBACIAAwioDakqAJUAAAAA.',['皓丶']='皓丶月:BAACLAAFFH8OAAMQAAYIBBpXFgCtAQAQAAYIBBpXFgCtAQAUAAEIpg9+QgBGAAAsAAQKfxoAAxAACAg7IYMRAOECABAACAg7IYMRAOECACMAAghoBMMnAE8AAAAA.',['瞄准']='瞄准:BAAALAAECgYIEQAAAA==.',['砍爆']='砍爆:BAABLAAECn8YAAIMAAgIgCOsCgClAgAMAAgIgCOsCgClAgAAAA==.',['硬條']='硬條:BAABLAAFFH8GAAIZAAIIYAr5cwA8AAAZAAIIYAr5cwA8AAAAAA==.',['硬汉']='硬汉不跳舞:BAAALAAECgYIEgAAAA==.',['祖公']='祖公威武:BAAALAAECgYICgAAAA==.',['神奇']='神奇女流氓:BAAALAADCgcIBwAAAA==.',['科塔']='科塔娜邪风:BAABLAAFFH8GAAIBAAIIlwqoOwBkAAABAAIIlwqoOwBkAAAAAA==.',['程序']='程序错误:BAAALAAECgYICwAAAA==.',['突突']='突突斩:BAACLAAFFH8IAAIMAAQImQ84LwDaAAAMAAQImQ84LwDaAAAsAAQKfxwAAwwABwhNIdcpAJYCAAwABwhNIdcpAJYCABwAAwjrFHQoALYAAAAA.',['箭随']='箭随心动:BAAALAAECgYIBgAAAA==.',['米奥']='米奥虾条:BAAALAAFFAIIAgAAAA==.',['米莉']='米莉卡:BAABLAAFFH8GAAMGAAIIFyAKPQC4AAAGAAIIFyAKPQC4AAATAAEIZBAbHQBRAAAAAA==.',['米菲']='米菲小胖:BAAALAAECgYIEQABLAAFFAgIAwAdAAAAAA==.米菲小麒:BAAALAAECgYIDQAAAA==.米菲术术:BAAALAAECgYIBwAAAA==.',['米蕾']='米蕾优:BAABLAAFFH8GAAIXAAIIWg1/IwB3AAAXAAIIWg1/IwB3AAABLAAFFAIIBgAGABcgAA==.',['粉红']='粉红容嬷嬷:BAAALAAECgYIDAAAAA==.',['糊涂']='糊涂塌客:BAAALAAECgMIAwAAAA==.',['素裕']='素裕:BAAALAAECggICAAAAA==.',['索尔']='索尔蒂绯亚:BAAALAAECgYICQAAAA==.',['索林']='索林丶铜须:BAAALAAECgcIBwAAAA==.',['紫霞']='紫霞仙子丶:BAAALAADCgYIBgAAAA==.',['繆大']='繆大将军:BAAALAAECgYIBgAAAA==.',['红肠']='红肠九块肌:BAACLAAFFH8UAAMDAAYIIBOrKAB3AQADAAYIIBOrKAB3AQAEAAEIkgH1GAA0AAAsAAQKfxkAAgMABgiiIVAjANMBAAMABgiiIVAjANMBAAAA.',['约定']='约定:BAAALAAECgUIBQAAAA==.',['维妮']='维妮卡:BAAALAAECgIIAgAAAA==.',['绿火']='绿火小恶魔:BAAALAAECgYIEAAAAA==.',['罗刹']='罗刹夜舞:BAAALAADCgQIBAAAAA==.',['羅罗']='羅罗诺亚索隆:BAAALAADCgEIAQAAAA==.',['翻滚']='翻滚拳:BAAALAADCgYIBgAAAA==.',['老师']='老师你好:BAABLAAFFH8fAAMVAAgIkhgrAwD4AQAVAAYIfxYrAwD4AQAeAAgI/Qy+AwDhAQAAAA==.',['老登']='老登你要起舞:BAAALAADCggICAAAAA==.',['耗子']='耗子不哭:BAABLAAFFH8IAAIZAAII/xwyNgCmAAAZAAII/xwyNgCmAAAAAA==.',['胡丽']='胡丽丽:BAAALAAFFAMIAwAAAA==.',['自在']='自在装比功丶:BAAALAAECgYIBgAAAA==.',['舍弃']='舍弃的密集:BAAALAAECgUIBQAAAA==.',['艾米']='艾米莉亚:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['艾露']='艾露尼斯:BAAALAAECgUIBwAAAA==.',['芋圆']='芋圆宝:BAAALAAFFAEIAQABLAAFFAIIAgAdAAAAAA==.',['花街']='花街龙少:BAACLAAFFH8wAAIjAAYIJxYRAgCTAQAjAAYIJxYRAgCTAQAsAAQKfzQAAiMACAiYIrYDAPwCACMACAiYIrYDAPwCAAAA.',['荒堂']='荒堂:BAAALAAECgUIBQAAAA==.',['荷鲁']='荷鲁斯:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['荼啊']='荼啊:BAACLAAFFH8pAAMCAAYIxh1aCwAUAgACAAYIxh1aCwAUAgAkAAQIjAi8GwC9AAAsAAQKfzQAAwIACAjeG2cVAB0CAAIACAjeG2cVAB0CACQAAgigBKFMADEAAAAA.',['莉莉']='莉莉斯:BAAALAADCgEIAQAAAA==.',['莎琪']='莎琪兜粥:BAAALAAECgYIBgAAAA==.',['莫问']='莫问:BAAALAADCgYIBgAAAA==.莫问归途:BAAALAADCgIIAgAAAA==.',['菜鸟']='菜鸟至尊:BAAALAAECgYIBgAAAA==.',['萌萌']='萌萌汉子:BAAALAAECgYIBgAAAA==.',['萌面']='萌面大瞎:BAAALAADCgQIBAAAAA==.',['萤火']='萤火:BAAALAADCgYIBgAAAA==.',['萧丷']='萧丷哥:BAAALAAECgYIDAAAAA==.',['萧瑟']='萧瑟瑟:BAAALAAECgYIBgAAAA==.',['蛋疼']='蛋疼的一批:BAAALAADCgQIBAAAAA==.',['蛋蛋']='蛋蛋的忧伤啊:BAAALAAECgcIEAAAAA==.',['蜀道']='蜀道丨难:BAAALAAECgEIAQAAAA==.',['蜜汁']='蜜汁脆皮牛:BAAALAADCgcIBwAAAA==.',['蝴蝶']='蝴蝶飝飝:BAABLAAFFH8JAAIZAAMIOw9JRACHAAAZAAMIOw9JRACHAAAAAA==.',['血条']='血条消失术:BAABLAAFFH8GAAIDAAYIuwsRNQA+AQADAAYIuwsRNQA+AQAAAA==.',['血祭']='血祭苍天:BAABLAAFFH8GAAIFAAYI/BznHAClAQAFAAYI/BznHAClAQAAAA==.',['西丁']='西丁卡特尔:BAAALAAECgYICwAAAA==.',['西格']='西格玛龙:BAABLAAFFH8FAAIgAAII0QvEGgBpAAAgAAII0QvEGgBpAAAAAA==.',['西红']='西红柿炒饭:BAABLAAECn8UAAMhAAcIfAjVQAA/AQAhAAcIfAjVQAA/AQAgAAUIjgUyNAC7AAAAAA==.',['西门']='西门吹火:BAAALAAECgMIAwAAAA==.',['观棋']='观棋:BAAALAAECggICgAAAA==.',['试试']='试试头铁不铁:BAABLAAFFH8QAAIQAAMILRBRQQCiAAAQAAMILRBRQQCiAAAAAA==.',['贝斯']='贝斯特:BAAALAAFFAIIAgABLAAFFAIIDAAGAJcZAA==.',['超级']='超级哒哒沐师:BAAALAAECgMIAwAAAA==.',['路边']='路边蹲一虎妞:BAABLAAFFH8JAAIQAAIIeiG+JQC7AAAQAAIIeiG+JQC7AAAAAA==.',['踢你']='踢你噢哞丁:BAAALAADCgQIBAAAAA==.',['轰隆']='轰隆医生:BAABLAAFFH8KAAIhAAIIbA8ZGgCLAAAhAAIIbA8ZGgCLAAAAAA==.',['进击']='进击的墨西哥:BAABLAAFFH8IAAMjAAYI1g5tAgBxAQAjAAYI1g5tAgBxAQAQAAIIIgKrdgA+AAAAAA==.',['迪丽']='迪丽热巴灬:BAAALAAECgMIAwAAAA==.',['迷人']='迷人二哥:BAAALAADCggICAAAAA==.',['追光']='追光:BAAALAAECgIIAgAAAA==.',['逆天']='逆天之自来也:BAABLAAECn8VAAMFAAcImQWExADrAAAFAAcImQWExADrAAAbAAEIAwGPoAAMAAAAAA==.',['逐术']='逐术:BAAALAAECgQIBAAAAA==.',['逐风']='逐风猎影:BAAALAAECgUIBQAAAA==.',['通灵']='通灵师:BAABLAAFFH8WAAIGAAgItRSMCgBRAgAGAAgItRSMCgBRAgAAAA==.',['遇术']='遇术临疯丷:BAAALAAECgYIBgAAAA==.遇术琳疯:BAAALAAFFAEIAQAAAA==.',['那个']='那个战吊:BAACLAAFFH8IAAIMAAYIXyF8FAC3AQAMAAYIXyF8FAC3AQAsAAQKfxcAAgwABwjaFglkAMkBAAwABwjaFglkAMkBAAAA.',['邦摁']='邦摁:BAABLAAFFH8KAAIXAAIInxXwKABBAAAXAAIInxXwKABBAAAAAA==.',['邪百']='邪百万:BAAALAAFFAIIAgAAAA==.',['酥麻']='酥麻妹:BAABLAAFFH8KAAIQAAIIwRMqQgB+AAAQAAIIwRMqQgB+AAAAAA==.',['酷霸']='酷霸:BAAALAAFFAIIAgABLAAFFAYIKAAMAIsfAA==.',['醉醺']='醉醺醺的爱你:BAAALAAECgYICgAAAA==.',['银色']='银色丶黎明:BAAALAAECgYICAAAAA==.',['长脸']='长脸皮:BAAALAAECgYICQAAAA==.',['闪电']='闪电飞吻:BAAALAAECgYICQAAAA==.',['阳哥']='阳哥:BAAALAAECgUICAAAAA==.',['阿克']='阿克萌徳:BAAALAAFFAIIAgAAAA==.',['阿垃']='阿垃垃圾君灬:BAAALAAECgIIAgAAAA==.',['阿尔']='阿尔法苟:BAAALAADCgEIAQAAAA==.',['阿斯']='阿斯特娜:BAAALAAFFAIIAgAAAA==.',['阿甲']='阿甲:BAAALAAECgYICAAAAA==.',['阿莲']='阿莲娜:BAAALAAECgYIEAAAAA==.',['陈厂']='陈厂长莫奈子:BAAALAAECgcIBwAAAA==.',['陈汉']='陈汉生:BAABLAAFFH8GAAIQAAII5AkVWQBlAAAQAAII5AkVWQBlAAAAAA==.',['随凤']='随凤狂舞:BAAALAADCgMIAwAAAA==.',['随风']='随风战心:BAAALAAECgYICgAAAA==.随风狂舞:BAAALAAFFAIIAgAAAA==.随风躲猫猫:BAAALAAFFAIIAgABLAAFFAIIBwAbAG0eAA==.',['雪华']='雪华:BAAALAADCgMIAwAAAA==.',['零翼']='零翼:BAAALAADCgYIBgAAAA==.',['雷光']='雷光闪过:BAAALAADCgQIBAAAAA==.',['雷神']='雷神泪:BAAALAADCgQIBAAAAA==.',['雷霆']='雷霆牛:BAACLAAFFH8IAAIGAAMIZQ3qaAByAAAGAAMIZQ3qaAByAAAsAAQKfx4AAgYACAjYG+JOAFsCAAYACAjYG+JOAFsCAAAA.',['電灬']='電灬:BAAALAAECgMIAwAAAA==.',['震天']='震天怒:BAAALAAECgYIEwAAAA==.',['霜舞']='霜舞沐琉苏:BAAALAAECgYIDgAAAA==.',['青眼']='青眼白龙:BAAALAAFFAIIAgAAAA==.',['青羊']='青羊区射神:BAACLAAFFH8KAAIKAAMIwxG4MQDBAAAKAAMIwxG4MQDBAAAsAAQKfxQAAgoACAj5HddpAAcCAAoACAj5HddpAAcCAAAA.',['静姐']='静姐姐:BAAALAAECgYIBgAAAA==.',['非常']='非常地恶魔:BAAALAADCgMIAwAAAA==.',['韩佳']='韩佳人:BAAALAAFFAIIAwAAAA==.',['韩式']='韩式炒年糕:BAABLAAFFH8KAAIhAAQIAgpzFAC6AAAhAAQIAgpzFAC6AAAAAA==.',['韩盗']='韩盗:BAAALAAECgYICgAAAA==.',['顺风']='顺风灬僧:BAABLAAFFH8VAAIeAAYICRkgBwCIAQAeAAYICRkgBwCIAQAAAA==.',['風灬']='風灬:BAAALAAECgYIBgAAAA==.',['风中']='风中奇冤:BAAALAADCgYIBgAAAA==.风中奇原:BAAALAAECgYIDwAAAA==.风中奇媛图腾:BAAALAAECgYICwAAAA==.风中奇瑗:BAAALAAECgYIDwAAAA==.',['风之']='风之幻影:BAAALAAECgYIBgAAAA==.',['风流']='风流小骑:BAABLAAFFH8KAAIZAAIIJh8BUgBSAAAZAAIIJh8BUgBSAAAAAA==.',['风雨']='风雨黑夜:BAAALAAECgYICAAAAA==.',['飛影']='飛影覓潺悠:BAAALAAECgYICQAAAA==.',['飞翔']='飞翔的风:BAAALAADCgQIBAAAAA==.',['骨头']='骨头二世:BAAALAAECgYIBgAAAA==.骨头盾:BAAALAAFFAEIAQAAAA==.',['鬼哭']='鬼哭丶牛嚎:BAACLAAFFH8JAAIBAAMI7RwnEAD9AAABAAMI7RwnEAD9AAAsAAQKfycAAwEACAheIXEXAKQCAAEACAheIXEXAKQCABEABgieELJcAEgBAAAA.',['魔域']='魔域圣法神:BAAALAADCgIIAgAAAA==.',['魔幻']='魔幻水晶:BAAALAAECgQIBQAAAA==.',['魔法']='魔法张张包:BAAALAADCgEIAQAAAA==.',['鲜血']='鲜血之吻:BAAALAAECgcIBwAAAA==.',['鲨农']='鲨农巴斯:BAABLAAFFH8IAAIZAAIIKhlmSACYAAAZAAIIKhlmSACYAAAAAA==.',['黎夏']='黎夏不冷:BAAALAAECgIIAgAAAA==.',['黑乃']='黑乃胡梦:BAAALAAECgYIDAAAAA==.',['黑白']='黑白倒影:BAAALAAECgMIAwAAAA==.',['黑的']='黑的咬卵:BAAALAAECgYICAAAAA==.',['默斯']='默斯莫:BAAALAADCgYIBgAAAA==.',['龍神']='龍神:BAAALAAECgUIBQAAAA==.',['龙龙']='龙龙不哭:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end