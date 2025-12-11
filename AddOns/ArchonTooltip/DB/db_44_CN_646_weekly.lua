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
 local lookup = {'Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Protection','Shaman-Elemental','Warlock-Demonology','Mage-Frost','Shaman-Restoration','Warrior-Fury','Paladin-Protection','Monk-Brewmaster','Hunter-Survival','Hunter-Marksmanship','Monk-Mistweaver','Warlock-Destruction','Warlock-Affliction','Unknown-Unknown','Paladin-Holy','Druid-Restoration','Druid-Feral','Rogue-Outlaw','Rogue-Subtlety','Mage-Arcane','Evoker-Preservation','Evoker-Devastation','DeathKnight-Unholy','Priest-Holy','Priest-Shadow','Druid-Balance','Druid-Any','Monk-Windwalker','DeathKnight-Blood','Druid-Guardian','Evoker-Augmentation','Rogue-Assassination',}; local provider = {region='CN',realm='奥达曼',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Allan:BAAALAAECgYIBgAAAA==.Altriacaster:BAAALAAFFAIIAgAAAA==.',At='Atalante:BAABLAAECn8cAAIBAAYI1xd1awBsAQABAAYI1xd1awBsAQAAAA==.Ationg:BAAALAAFFAIIAgAAAA==.',Ch='Chriss:BAAALAAECggICAAAAA==.',Ci='Cindynica:BAAALAADCgQIBAAAAA==.',Cy='Cyberfever:BAAALAADCggICAAAAA==.',De='Deathfeather:BAABLAAFFH8iAAICAAYIeR1bEADCAQACAAYIeR1bEADCAQAAAA==.Deedeed:BAABLAAECn8eAAIDAAYIuwX2lAC9AAADAAYIuwX2lAC9AAAAAA==.Deedeedee:BAAALAAECgYIDwAAAA==.Devil:BAABLAAFFH8JAAIEAAMIzAk2DgBaAAAEAAMIzAk2DgBaAAAAAA==.',Di='Diomars:BAAALAADCgQIBAAAAA==.',Do='Doremon:BAAALAAECgcIBwAAAA==.',Em='Emolie:BAACLAAFFH8GAAIFAAIIshFdVABGAAAFAAIIshFdVABGAAAsAAQKfxoAAwQABwiJIkcHAAICAAQABgiiI0cHAAICAAUABwgJG3YfAOkBAAAA.',Fa='Fayevalentin:BAAALAAECgMIAwAAAA==.',Gv='Gvlnaz:BAAALAAECgMIBAAAAA==.',He='Heartseaman:BAABLAAFFH8GAAIGAAYIOg4OFAAgAQAGAAYIOg4OFAAgAQAAAA==.',Ho='Hotlala:BAABLAAFFH8PAAIBAAUIyAjHXQDMAAABAAUIyAjHXQDMAAAAAA==.',In='Infinity:BAAALAAFFAIIAgAAAA==.',Ja='Jackren:BAAALAADCgcIBwAAAA==.Jackss:BAAALAAECgQIBAAAAA==.',Je='Jessicajones:BAAALAAECgYIBgAAAA==.',Ki='Kiones:BAAALAAECgYIBwAAAA==.',Li='Liekkas:BAAALAAECgEIAQAAAA==.Lifedrain:BAABLAAFFH8IAAIHAAIIGx8xIQCrAAAHAAIIGx8xIQCrAAAAAA==.Lihudrain:BAAALAAFFAIIAgABLAAFFAIICAAHABsfAA==.',Ma='Manamisery:BAABLAAFFH8HAAIIAAIIKiGUBwDJAAAIAAIIKiGUBwDJAAAAAA==.',Mi='Minerva:BAAALAAECgcIEgAAAA==.',Ne='Neinei:BAAALAAFFAIIBAAAAA==.',Sh='Shanos:BAABLAAFFH8GAAIJAAIItArsHQA1AAAJAAIItArsHQA1AAAAAA==.',Sp='Sparrows:BAAALAAFFAIIAgAAAA==.',Ur='Urmyservant:BAACLAAFFH8KAAIKAAMIXgFNawBPAAAKAAMIXgFNawBPAAAsAAQKfzMAAgoACAiVDZWXAE8BAAoACAiVDZWXAE8BAAAA.',Ve='Verfolger:BAABLAAFFH8FAAIBAAUILADexwAEAAABAAUILADexwAEAAAAAA==.',Wa='Wa:BAAALAAECgYIBgAAAA==.',We='Weiquq:BAABLAAFFH8IAAIHAAIIdQ8JLQCOAAAHAAIIdQ8JLQCOAAAAAA==.',Wi='Winnow:BAAALAADCgYIBgAAAA==.',Wy='Wyrd:BAAALAAECgcIEgAAAA==.',Xi='Xias:BAAALAAECgMIAwAAAA==.',Yi='Yiyu:BAAALAAFFAIIBAAAAA==.',Yu='Yuukiasuna:BAAALAADCgMIAwAAAA==.',Ze='Zeref:BAABLAAFFH8GAAILAAYImRu9EgDDAQALAAYImRu9EgDDAQAAAA==.Zeusxu:BAAALAAECgYIBwAAAA==.',['一千']='一千叔叔:BAABLAAFFH8LAAMHAAYIVwL2KwDcAAAHAAYIVwL2KwDcAAAKAAEIggRxfwAmAAAAAA==.一千叔啊啊:BAABLAAFFH8OAAMCAAgITg5DBwDxAQACAAgITg5DBwDxAQAMAAEICgigGwAzAAAAAA==.',['一只']='一只稀有萨满:BAABLAAFFH8lAAIKAAYIvheYGACXAQAKAAYIvheYGACXAQAAAA==.',['一叶']='一叶知秋:BAAALAAECgIIAgAAAA==.',['一吻']='一吻上天堂:BAAALAADCggICAAAAA==.',['一坨']='一坨牛粪:BAABLAAFFH8GAAINAAYIJwgVCABuAQANAAYIJwgVCABuAQAAAA==.',['一夕']='一夕:BAAALAAECgYIBgAAAA==.',['一悟']='一悟众生:BAAALAADCgcIBwAAAA==.',['一抹']='一抹映疏林:BAAALAAECgYIBwAAAA==.',['七夜']='七夜空城:BAABLAAECn8ZAAQOAAYIMx1+BQCcAQAOAAYIMx1+BQCcAQABAAUI5RQaJwH3AAAPAAMIMRTWigC4AAAAAA==.',['万江']='万江南:BAABLAAECn8UAAIBAAYIohvWWgCNAQABAAYIohvWWgCNAQAAAA==.',['三尺']='三尺剑:BAACLAAFFH8MAAIQAAIInxJ9FAB3AAAQAAIInxJ9FAB3AAAsAAQKfx8AAhAABgjqHO8MAOIBABAABgjqHO8MAOIBAAAA.',['上树']='上树野吠:BAAALAAECgYIBgABLAAFFAgIBgALAJYbAA==.',['上苍']='上苍月:BAAALAADCgQIBAAAAA==.',['不会']='不会后退:BAAALAAECggICAAAAA==.',['不帅']='不帅你打我:BAAALAADCgMIAwAAAA==.',['不惑']='不惑之痒:BAAALAAECgYICgAAAA==.',['不是']='不是宠物:BAAALAADCggICAAAAA==.',['不玩']='不玩惩戒骑:BAABLAAFFH8GAAICAAYI3Q+WIwBTAQACAAYI3Q+WIwBTAQAAAA==.',['丨差']='丨差一点丨:BAABLAAFFH8OAAIKAAIIOyAtOgC6AAAKAAIIOyAtOgC6AAAAAA==.',['中发']='中发白:BAAALAADCgQIBAAAAA==.',['中年']='中年油腻大叔:BAAALAAFFAIIAgAAAA==.',['丶扒']='丶扒衣老爷丶:BAAALAAECgYIBgAAAA==.',['九影']='九影裟:BAAALAAECgEIAQAAAA==.',['九秋']='九秋莲:BAACLAAFFH8KAAIRAAIIXhIHXQBCAAARAAIIXhIHXQBCAAAsAAQKfyUAAxEABgiXHBgwAI0BABEABggBHBgwAI0BABIABgjcD1kWAF0BAAAA.',['云破']='云破风敲雪:BAAALAADCgIIAgAAAA==.',['云销']='云销雨霁:BAAALAADCgQIBAAAAA==.',['五月']='五月的图腾:BAABLAAFFH8GAAIKAAIITA24YgBYAAAKAAIITA24YgBYAAAAAA==.',['亚吉']='亚吉特:BAAALAAECgcIBwAAAA==.',['亚琉']='亚琉哲:BAAALAADCggICAAAAA==.',['亞灬']='亞灬誼:BAAALAADCgEIAQAAAA==.',['亵渎']='亵渎之靓:BAAALAAECgQIBQAAAA==.',['亽牸']='亽牸拖:BAAALAADCgYIBgAAAA==.',['仲夏']='仲夏之魂:BAAALAAECgEIAQAAAA==.',['伊无']='伊无双:BAAALAADCgYIBgAAAA==.',['伊晓']='伊晓万:BAAALAAFFAIIAgAAAA==.',['优伶']='优伶丨虚:BAAALAAECggIDgAAAA==.',['伦敦']='伦敦依恋雨点:BAAALAAECggICAAAAA==.',['何必']='何必呢:BAAALAAECggIDQAAAA==.',['佛特']='佛特:BAAALAAECgYICQAAAA==.',['你以']='你以为我不帅:BAAALAAECgYIDQAAAA==.',['佶尔']='佶尔伽羙什:BAAALAAECgYICQABLAAECggIDgATAAAAAA==.',['使徒']='使徒:BAAALAADCgMIAwAAAA==.',['來都']='來都來了:BAACLAAFFH8lAAMHAAYINhQcGQB2AQAHAAYINhQcGQB2AQAKAAIItwFCbwBNAAAsAAQKfxcAAgcABwhBH98WAPQBAAcABwhBH98WAPQBAAAA.',['保安']='保安:BAAALAAFFAIIAgAAAA==.保安大队长:BAAALAAECgEIAQAAAA==.',['保护']='保护萝莉:BAAALAADCgMIAwAAAA==.',['修特']='修特伦:BAAALAAECgYIBgAAAA==.',['假面']='假面涅盘:BAAALAAECgcICwAAAA==.',['光光']='光光绿丶:BAACLAAFFH8aAAIHAAYI2xJaGwBkAQAHAAYI2xJaGwBkAQAsAAQKfyQAAgcACAikHh4mAIECAAcACAikHh4mAIECAAAA.',['光明']='光明的挽歌:BAAALAADCgIIAgAAAA==.',['光脚']='光脚容易感冒:BAAALAADCgIIAgAAAA==.',['光頭']='光頭文:BAAALAADCgEIAQAAAA==.',['八点']='八点钟有骨气:BAAALAAECgIIAgAAAA==.',['六水']='六水厂:BAAALAADCggICAAAAA==.',['六钧']='六钧弓:BAABLAAFFH8HAAMUAAII4yAgHQC9AAAUAAII4yAgHQC9AAACAAIItBm0VQBMAAAAAA==.',['册乌']='册乌伐盖屁谷:BAAALAAFFAIIAgAAAA==.',['军团']='军团大当家:BAABLAAECn8eAAILAAcI7RbvWADnAQALAAcI7RbvWADnAQAAAA==.',['冬枯']='冬枯草:BAABLAAFFH8LAAMVAAII2hjRKACIAAAVAAII2hjRKACIAAAWAAEI5A5IEwAAAAAAAA==.',['冰棒']='冰棒好甜:BAAALAAFFAIIAwAAAA==.',['冰魂']='冰魂血魄:BAAALAAECgIIAgAAAA==.',['冷夜']='冷夜幽幽:BAAALAADCgQIBAAAAA==.',['凉灬']='凉灬卅:BAAALAAFFAIIAgAAAA==.凉灬裂爪:BAAALAAFFAIIAgAAAA==.',['凌雨']='凌雨洁:BAAALAAECgYIBgAAAA==.',['劉鞴']='劉鞴丈夫:BAACLAAFFH8WAAICAAUIVB8pIQBhAQACAAUIVB8pIQBhAQAsAAQKfycAAgIABwiFIfw2AJgCAAIABwiFIfw2AJgCAAAA.',['包包']='包包快快跑:BAAALAADCgEIAQAAAA==.',['北极']='北极甜虾:BAABLAAFFH8YAAIRAAYIixFlLQBlAQARAAYIixFlLQBlAQAAAA==.',['十三']='十三月:BAAALAAFFAIIAgAAAA==.',['单纯']='单纯的暴力:BAACLAAFFH8GAAIXAAIInRYVBACgAAAXAAIInRYVBACgAAAsAAQKfxwAAxcABgjnIwQFAHwCABcABgjnIwQFAHwCABgABgjtHiQWAPABAAAA.',['南方']='南方小土豆:BAAALAADCggICAAAAA==.',['卡多']='卡多雷之愛:BAACLAAFFH8mAAMBAAYIVSBvNwBhAQABAAYIXB1vNwBhAQAPAAEIOR4VEgBaAAAsAAQKfxYAAwEACAirIf4QAJwCAAEACAirIf4QAJwCAA8AAghEGnaYAI0AAAAA.',['卡拉']='卡拉夏:BAAALAAECggICQAAAA==.',['卡露']='卡露雅:BAAALAAECgEIAQAAAA==.',['受死']='受死吧武器战:BAAALAAFFAIIAgAAAA==.',['叛军']='叛军雇佣兵:BAAALAADCgcIBwAAAA==.',['古镇']='古镇刘亦菲:BAAALAAECgQIBAAAAA==.',['古馆']='古馆魔术师忧:BAACLAAFFH8NAAIZAAUIbQ5fPQDSAAAZAAUIbQ5fPQDSAAAsAAQKfxoAAhkABgjOIZJBAEYCABkABgjOIZJBAEYCAAAA.',['叫爸']='叫爸爸丶:BAAALAADCgIIAgAAAA==.',['叶公']='叶公龙:BAACLAAFFH8IAAIaAAIIQBRlGACCAAAaAAIIQBRlGACCAAAsAAQKfyAAAxoABgifHq8HABMCABoABgifHq8HABMCABsAAgg3BpVkAEkAAAAA.',['叶青']='叶青柠:BAAALAAFFAEIAQAAAA==.',['叶飘']='叶飘飘:BAAALAAECgYIBgAAAA==.',['吃橙']='吃橙子的殇弢:BAAALAAFFAIIAgAAAA==.',['各务']='各务原樱:BAABLAAFFH8SAAMCAAUIryE0HAB9AQACAAUIryE0HAB9AQAMAAMIRBczEQCSAAAAAA==.',['吉矮']='吉矮娜:BAAALAAECgcIBwAAAA==.',['后山']='后山冷飕飕:BAAALAAECgUIBQAAAA==.',['吮指']='吮指原味咕:BAAALAAFFAIIBAAAAA==.',['告死']='告死之靈:BAAALAAFFAIIAgAAAA==.',['告白']='告白气球:BAAALAAECgUIBgAAAA==.',['呼呼']='呼呼大仙:BAAALAADCggICAAAAA==.',['呼啦']='呼啦丶:BAABLAAFFH8OAAMCAAUIEBT9KwAjAQACAAUIEBT9KwAjAQAMAAEIhQp6IwAzAAAAAA==.',['咕神']='咕神的茶叶蛋:BAAALAAECgIIAgAAAA==.',['咩吖']='咩吖:BAAALAADCgcIDgAAAA==.',['哑蠛']='哑蠛蝶:BAAALAAECgYICAAAAA==.',['哟哟']='哟哟帅气:BAACLAAFFH8KAAICAAIITBaNPQCgAAACAAIITBaNPQCgAAAsAAQKfxcAAgIABgh/IikmAP0BAAIABgh/IikmAP0BAAAA.',['唐纳']='唐纳德:BAAALAAFFAMIAwAAAA==.',['啊喔']='啊喔呃:BAAALAAFFAIIAgAAAA==.',['啊拉']='啊拉贡:BAAALAAECgQIBgAAAA==.',['喔唷']='喔唷哈搞:BAAALAAFFAIIBAAAAA==.',['喝酒']='喝酒崴到脚:BAAALAADCgIIAgAAAA==.',['喵十']='喵十七:BAACLAAFFH8IAAIaAAYIpgSMEgDvAAAaAAYIpgSMEgDvAAAsAAQKfyAAAhoABgheIBsHACQCABoABgheIBsHACQCAAAA.',['噬灵']='噬灵天火:BAAALAAFFAIIAgAAAA==.',['回避']='回避暧昧:BAAALAAECgMIAwAAAA==.',['图腾']='图腾医逝:BAAALAAFFAMIAwAAAA==.',['土豆']='土豆不吃牛肉:BAAALAAFFAIIBAAAAA==.',['圣光']='圣光小梦:BAAALAAFFAIIAgAAAA==.圣光小法:BAAALAAECgMIAwAAAA==.圣光小莫:BAAALAAECgYIBgAAAA==.圣光洗脑:BAAALAAECgUICQAAAA==.',['地狱']='地狱象拔蚌:BAAALAAECgYIBgAAAA==.地狱追猎:BAAALAAECgIIAgAAAA==.地狱邮差:BAACLAAFFH8IAAIDAAIIRxK4iQBBAAADAAIIRxK4iQBBAAAsAAQKfxYAAgMABghhHuZ2AAoCAAMABghhHuZ2AAoCAAAA.',['城北']='城北徐工:BAAALAAFFAIIBAAAAA==.',['城南']='城南徐公:BAACLAAFFH8IAAIPAAIIaBx9GwCbAAAPAAIIaBx9GwCbAAAsAAQKfxwAAg8ACAi5Hv0SAMwCAA8ACAi5Hv0SAMwCAAAA.',['壞鞋']='壞鞋子:BAAALAADCgYIBgAAAA==.',['夏末']='夏末挽歌:BAACLAAFFH8ZAAIcAAYIChr0AgCjAQAcAAYIChr0AgCjAQAsAAQKfycAAhwACAjKIykDADUDABwACAjKIykDADUDAAAA.',['夏花']='夏花糕点师:BAACLAAFFH8IAAIZAAIISSFNMQDFAAAZAAIISSFNMQDFAAAsAAQKfxkAAhkACAjiIbp4AKQBABkACAjiIbp4AKQBAAAA.',['夙丨']='夙丨夜寐:BAAALAAECgYIDQAAAA==.',['夜丶']='夜丶且听风吟:BAABLAAFFH8LAAIJAAII9xdeDQCbAAAJAAII9xdeDQCbAAAAAA==.夜丶流星丨雨:BAABLAAFFH8MAAIMAAIIfRkTGQA5AAAMAAIIfRkTGQA5AAAAAA==.',['夜未']='夜未央夜微凉:BAABLAAFFH8JAAIRAAYIqg8iEADlAQARAAYIqg8iEADlAQAAAA==.',['夜灬']='夜灬流星丨雨:BAABLAAFFH8KAAIEAAIIxAf9FgBZAAAEAAIIxAf9FgBZAAAAAA==.',['夜雨']='夜雨风歌:BAAALAAFFAIIAgAAAA==.',['大叔']='大叔玩治疗:BAAALAAFFAIIBAAAAA==.',['大橙']='大橙在德:BAAALAAECgMIAwAAAA==.',['大王']='大王丶:BAAALAAECgMIBAAAAA==.',['大瞎']='大瞎咪少奶奶:BAAALAAECgYIBgAAAA==.',['大象']='大象伯伯:BAAALAAECgYIDAAAAA==.大象叔叔:BAAALAAFFAIIBAAAAA==.大象姥爷:BAAALAAFFAIIBAAAAA==.大象舅舅:BAAALAAECgQIBAAAAA==.',['天幕']='天幕:BAABLAAFFH8IAAILAAIIYg13TgBFAAALAAIIYg13TgBFAAAAAA==.',['天灵']='天灵灵:BAAALAAECgMIAwAAAA==.',['天空']='天空:BAABLAAFFH8JAAIGAAMIYRXmFwCaAAAGAAMIYRXmFwCaAAAAAA==.天空灬:BAAALAAECgYICQAAAA==.',['天蓬']='天蓬元帅八戒:BAAALAAECgIIAgAAAA==.',['天降']='天降橙色:BAAALAAECgEIAQAAAA==.',['天青']='天青的骑士:BAAALAAFFAIIAgAAAA==.',['奇蒂']='奇蒂拉马哲理:BAAALAAECgYICQAAAA==.',['奇迹']='奇迹我信了:BAABLAAECn8ZAAIJAAYIKSEjHQAyAgAJAAYIKSEjHQAyAgAAAA==.',['奈奎']='奈奎思特:BAACLAAFFH8GAAIdAAIIFBjINgCIAAAdAAIIFBjINgCIAAAsAAQKfxwAAx0ABwgQHuAPAFkCAB0ABwgQHuAPAFkCAB4ABgjGGfEYAIQBAAAA.',['奥灬']='奥灬法:BAAALAADCgMIAwAAAA==.',['奥黛']='奥黛麗赫本:BAAALAAECgMIAwAAAA==.',['女神']='女神之息:BAAALAADCggICAAAAA==.',['妖妖']='妖妖靥:BAAALAAECgYICQAAAA==.',['姽婳']='姽婳菀:BAAALAAECggICAAAAA==.',['嫑藏']='嫑藏獒的二嬢:BAAALAAECgIIAgAAAA==.',['孙小']='孙小美:BAAALAADCgUICQAAAA==.',['孙猴']='孙猴王悟空:BAAALAAECgYIBgAAAA==.',['孤儿']='孤儿:BAABLAAFFH8GAAINAAYIMg4EEQA6AQANAAYIMg4EEQA6AQAAAA==.',['孤单']='孤单灵魂:BAAALAAFFAIIBAAAAA==.',['孫小']='孫小美:BAAALAADCgEIAQAAAA==.',['守夜']='守夜者雪诺:BAAALAAFFAIIAgAAAA==.',['安娜']='安娜斯塔西亚:BAAALAAECggICAAAAA==.',['安安']='安安:BAAALAAECggICgAAAA==.',['安阿']='安阿苏:BAAALAAECgYICwAAAA==.',['宋宗']='宋宗鸡:BAABLAAECn8xAAMKAAcIlR98EABxAgAKAAcIlR98EABxAgAHAAcIkBoDHgC9AQAAAA==.',['宝囡']='宝囡囡:BAAALAADCgIIAgAAAA==.',['宝石']='宝石的流霞:BAAALAAECgIIAgAAAA==.',['害怕']='害怕:BAABLAAFFH8JAAIJAAUIvxCCCAANAQAJAAUIvxCCCAANAQAAAA==.',['寂寞']='寂寞之殇:BAAALAAECgYIEAAAAA==.寂寞烟圈:BAABLAAFFH8KAAIDAAYI4gj1RgAeAQADAAYI4gj1RgAeAQAAAA==.',['寂滅']='寂滅之刃:BAABLAAFFH8XAAIFAAYIVRtkFQC6AQAFAAYIVRtkFQC6AQAAAA==.',['寂舞']='寂舞笙湘:BAAALAADCgYIBgAAAA==.',['封城']='封城魔舞:BAAALAAECggICAAAAA==.',['射太']='射太阳的人:BAABLAAECn8VAAIBAAYI0BQNkAAwAQABAAYI0BQNkAAwAQAAAA==.',['小兰']='小兰:BAAALAADCgMIAwAAAA==.',['小卷']='小卷卷:BAAALAAECgUIBQAAAA==.',['小喜']='小喜力:BAAALAAECgUIBQAAAA==.',['小奶']='小奶妈无敌:BAAALAADCgEIAQAAAA==.',['小小']='小小一射手:BAAALAADCgYIBgAAAA==.',['小誉']='小誉胖胖:BAABLAAFFH8GAAIfAAIIIRXNMgA+AAAfAAIIIRXNMgA+AAAAAA==.',['尐丸']='尐丸籽酿酒:BAAALAAFFAIIAgAAAA==.',['尛尛']='尛尛萨児:BAAALAAECgYIDAAAAA==.',['尼希']='尼希尔:BAAALAAECgYIBwAAAA==.',['岩斗']='岩斗罗:BAAALAAECggIBQAAAA==.',['左肩']='左肩天使:BAAALAADCggICAAAAA==.',['巴哈']='巴哈姆特之怒:BAAALAAECgYIBgAAAA==.',['布拉']='布拉曼修:BAAALAAECgEIAQAAAA==.',['帅骑']='帅骑帅骑帅:BAAALAAECgQIAwAAAA==.',['希瓦']='希瓦娜斯娅:BAABLAAFFH8MAAIBAAYI+wx+RAA3AQABAAYI+wx+RAA3AQAAAA==.',['带我']='带我呀:BAAALAAECgYICgAAAA==.',['常萌']='常萌有希:BAAALAADCgIIAgAAAA==.',['干果']='干果:BAAALAADCgcIBwAAAA==.',['幻影']='幻影丶弑月:BAABLAAFFH8IAAIBAAIISRlhhgBKAAABAAIISRlhhgBKAAAAAA==.',['幽灵']='幽灵鬼鬼:BAAALAADCgIIAgAAAA==.',['库丘']='库丘林:BAABLAAECn8YAAIVAAcI7wntSQDuAAAVAAcI7wntSQDuAAAAAA==.',['开心']='开心锤锤:BAABLAAECn8qAAIDAAYIkyLGIgDtAQADAAYIkyLGIgDtAQAAAA==.',['强壮']='强壮的大熊:BAAALAADCgYIBgAAAA==.',['德甲']='德甲天下:BAAALAAECgEIAQAAAA==.',['心易']='心易:BAAALAAECgYIDAAAAA==.',['快餐']='快餐上门一百:BAAALAAECgYIDQAAAA==.快餐上门九百:BAAALAAECgMIAwAAAA==.快餐上门二百:BAAALAAECgYIDAAAAA==.快餐上门五百:BAAALAAECgYIBgAAAA==.快餐上门六百:BAAALAAECgYIDgAAAA==.',['念起']='念起灵:BAAALAAECgYICgAAAA==.',['怒光']='怒光:BAAALAAECgUIBQAAAA==.',['恋香']='恋香灬:BAABLAAECn8VAAIBAAcIeRZCUwCdAQABAAcIeRZCUwCdAQAAAA==.',['恶魔']='恶魔滴泪:BAAALAAECgYIDwAAAA==.',['悲剧']='悲剧的雪:BAAALAAFFAUIBAAAAA==.',['情况']='情况不对就闪:BAAALAAECgcIBwAAAA==.',['惑德']='惑德:BAAALAAECgYIBgAAAA==.',['我会']='我会开无敌:BAABLAAFFH8lAAICAAYIWR0xEgC2AQACAAYIWR0xEgC2AQAAAA==.',['我是']='我是欧根亲王:BAAALAAFFAIIBAAAAA==.',['我的']='我的名字是:BAAALAADCgEIAQAAAA==.',['我若']='我若为王:BAAALAAECgYICgAAAA==.',['我要']='我要拾个:BAAALAAECgYIEwAAAA==.',['战争']='战争狂人:BAACLAAFFH8jAAILAAUIMR5xGAABAQALAAUIMR5xGAABAQAsAAQKfyYAAwsACAixIRoTABQDAAsACAixIRoTABQDAAYAAwiQFThCAH8AAAAA.',['打杂']='打杂的:BAABLAAFFH8FAAIBAAIIbx2KfgBaAAABAAIIbx2KfgBaAAAAAA==.',['抵消']='抵消分录:BAABLAAFFH8KAAIKAAII8Q3cUABrAAAKAAII8Q3cUABrAAAAAA==.',['拉斯']='拉斯塔哈国王:BAAALAAECgYIBgAAAA==.',['捌级']='捌级小狂风:BAAALAAECgYIBgAAAA==.',['摩睺']='摩睺罗伽:BAAALAAECgYIDAAAAA==.',['撕裂']='撕裂重罪:BAAALAAECgIIAgAAAA==.',['斋藤']='斋藤飞鸟丶:BAABLAAFFH8IAAIDAAYIiRkDNwBfAQADAAYIiRkDNwBfAQAAAA==.',['斗牛']='斗牛又抓鸡:BAAALAAECgMIAwAAAA==.',['斯巴']='斯巴达勇士:BAAALAADCgMIAwAAAA==.',['方园']='方园:BAACLAAFFH8GAAIQAAII9RAWFQBwAAAQAAII9RAWFQBwAAAsAAQKfxcAAhAABwiJGTkYAAECABAABwiJGTkYAAECAAEsAAQKCAgqABsAWRkA.',['无光']='无光之盾:BAAALAAECgYIEgAAAA==.',['无双']='无双千珏:BAAALAAECgYIDAAAAA==.无双城千珏:BAAALAAECgQIAgAAAA==.',['无敌']='无敌霹雳:BAAALAAECgEIAQAAAA==.',['日么']='日么疼:BAAALAAFFAIIAgAAAA==.',['星河']='星河不及你:BAAALAAECgYICQAAAA==.',['晓野']='晓野妹纸:BAABLAAFFH8GAAIRAAIIKQNFcwAfAAARAAIIKQNFcwAfAAAAAA==.',['晨鑫']='晨鑫:BAAALAAFFAIIAgAAAA==.',['暗影']='暗影相随:BAAALAAFFAIIAwAAAA==.暗影相随毁:BAAALAAECgEIAQAAAA==.',['暗暗']='暗暗:BAAALAADCgUIBgAAAA==.',['暴风']='暴风牛马:BAAALAAECgYIEgAAAA==.',['最爱']='最爱吃榴莲:BAAALAADCgcICQAAAA==.最爱吃菠萝:BAAALAADCgcIBwAAAA==.',['月落']='月落咕啼:BAAALAAFFAIIAgAAAA==.',['朝暮']='朝暮不闻:BAABLAAFFH8GAAIZAAYIaBMYDQD/AQAZAAYIaBMYDQD/AQAAAA==.',['术你']='术你无罪:BAABLAAFFH8GAAIRAAYITRX0KwBrAQARAAYITRX0KwBrAQAAAA==.',['术我']='术我貌美:BAAALAAECgUIBQAAAA==.',['朱敛']='朱敛:BAAALAAFFAEIAQAAAA==.',['朱雀']='朱雀纪维纳斯:BAABLAAFFH8GAAMKAAYIMh43IABaAQAKAAQIFh83IABaAQAHAAIIaBgdMQCiAAAAAA==.',['李滇']='李滇滇:BAABLAAFFH8IAAIFAAIIZyBMLACyAAAFAAIIZyBMLACyAAAAAA==.',['杨嘤']='杨嘤:BAABLAAFFH8IAAIEAAIIvw+VFwBXAAAEAAIIvw+VFwBXAAAAAA==.',['林正']='林正英:BAAALAAFFAIIBAAAAA==.',['柳絮']='柳絮寒月:BAAALAAECgcIBwAAAA==.',['栀浅']='栀浅:BAAALAAECgQIBAAAAA==.',['格兰']='格兰特希尔:BAAALAADCgQIBAAAAA==.',['梅川']='梅川裤子:BAABLAAFFH8FAAIBAAMIPR9+IgD4AAABAAMIPR9+IgD4AAAAAA==.',['梦回']='梦回什么来着:BAAALAAECgYIBgAAAA==.',['棍捣']='棍捣橘芯:BAAALAAECgYIBgAAAA==.',['棍棍']='棍棍神:BAABLAAFFH8MAAIKAAMIlBlENwDGAAAKAAMIlBlENwDGAAAAAA==.',['横霸']='横霸小天:BAAALAAECgMIAwAAAA==.',['橙色']='橙色爱马仕:BAABLAAFFH8GAAIgAAYIEQAAAAAAAAAfAAYIEQAAAAAAAAAAAA==.',['武夷']='武夷君:BAABLAAFFH8GAAIBAAYIPgBJxAAOAAABAAYIPgBJxAAOAAAAAA==.',['残梦']='残梦慰清愁:BAABLAAFFH8OAAICAAUIiBGqLgAQAQACAAUIiBGqLgAQAQAAAA==.',['毙肾']='毙肾客:BAAALAAECgYIDAAAAA==.',['永生']='永生灭:BAABLAAECn8hAAIdAAYIQgxwPgDpAAAdAAYIQgxwPgDpAAAAAA==.',['江一']='江一毛子:BAABLAAECn8VAAICAAcIBxsysACeAQACAAcIBxsysACeAQAAAA==.',['汪汪']='汪汪队立大功:BAAALAAECgcIBwAAAA==.',['沪小']='沪小白的拉拉:BAAALAAECgUICQAAAA==.',['河马']='河马大魔王:BAAALAAECgEIAQAAAA==.',['法兰']='法兰波瓦兹:BAAALAAECgcIBwAAAA==.',['注意']='注意灬脚下:BAAALAAECgYIBgAAAA==.',['洋大']='洋大宝:BAAALAAFFAIIAgAAAA==.',['浅唱']='浅唱钻钻:BAAALAAECgYIBgAAAA==.',['浮华']='浮华醉影:BAAALAADCgQIBAAAAA==.',['涵涵']='涵涵没烦恼:BAAALAAECggICAABLAAFFAcIMgAeAMwaAA==.',['淚灬']='淚灬淚:BAAALAADCgMIAwAAAA==.',['混班']='混班子:BAAALAAFFAIIAgAAAA==.',['清水']='清水清悦:BAAALAADCgYICAAAAA==.',['清风']='清风七号:BAAALAAECggIEwAAAA==.清风十三妹:BAABLAAFFH8FAAIXAAII/A4QBQCUAAAXAAII/A4QBQCUAAAAAA==.清风四号:BAAALAAFFAIIAgAAAA==.',['湮灭']='湮灭之暗:BAABLAAFFH8lAAIDAAYILxkDHADGAQADAAYILxkDHADGAQAAAA==.',['滨边']='滨边美波丶:BAABLAAFFH8GAAIaAAYIPCKcBABUAgAaAAYIPCKcBABUAgAAAA==.',['潴籽']='潴籽芃:BAABLAAFFH8KAAICAAIILBlARQCaAAACAAIILBlARQCaAAAAAA==.',['灬壹']='灬壹怒爲紅顔:BAABLAAFFH8GAAIFAAYIqRGVIgBzAQAFAAYIqRGVIgBzAQAAAA==.',['灬寂']='灬寂寞小猎灬:BAAALAAECgMICAAAAA==.',['灬小']='灬小保灬:BAAALAAECgYIBgAAAA==.',['灶马']='灶马子:BAAALAAECgIIAgAAAA==.',['烈火']='烈火奶奶:BAAALAADCgQIBAAAAA==.',['烈焰']='烈焰凤凰:BAAALAAECgYICQAAAA==.',['烙绅']='烙绅:BAABLAAECn8jAAMKAAgI5CC/HQCeAgAKAAgI5CC/HQCeAgAHAAcIGQkJeABXAQAAAA==.',['焦糖']='焦糖馥芮白:BAABLAAFFH8JAAIVAAIIbQ9iRwBgAAAVAAIIbQ9iRwBgAAAAAA==.',['熊猫']='熊猫挽歌:BAABLAAFFH8bAAMNAAcIkxY/CgCiAQANAAYIvhY/CgCiAQAhAAEIjBUrFABOAAAAAA==.熊猫烧香丶:BAABLAAFFH8GAAMKAAYI/BgmMQDnAAAKAAQILhQmMQDnAAAHAAIIuhXrMQCaAAAAAA==.熊猫爱薇:BAAALAAFFAIIBAAAAA==.',['爪毛']='爪毛君:BAAALAAECgIIAgAAAA==.',['爱不']='爱不离手:BAAALAADCgEIAQAAAA==.',['牛奶']='牛奶树:BAAALAAFFAYIAwAAAA==.',['特猫']='特猫柔:BAACLAAFFH8IAAIUAAMIHBEkIACHAAAUAAMIHBEkIACHAAAsAAQKfzoAAhQACAgyINcJANgCABQACAgyINcJANgCAAEsAAUUBggIABoApgQA.',['狂妄']='狂妄之雄:BAAALAAFFAIIAgAAAA==.',['狂热']='狂热之锋:BAABLAAFFH8GAAICAAYIvQkNKgAuAQACAAYIvQkNKgAuAQAAAA==.',['狂雷']='狂雷妖焰:BAAALAAECgYIBgAAAA==.',['猫猫']='猫猫丨大人:BAAALAAECgIIAgAAAA==.',['玄天']='玄天舞者:BAABLAAFFH8MAAILAAIIPBtZRABPAAALAAIIPBtZRABPAAAAAA==.',['玄武']='玄武纪冥王:BAAALAAECgYIBgABLAAFFAYIBgAFALUbAA==.',['玉子']='玉子:BAAALAAECgIIAgAAAA==.',['玛修']='玛修拉姆:BAAALAAECgEIAQAAAA==.',['玫斯']='玫斯特拉:BAAALAAECgYIBwAAAA==.',['瑞丝']='瑞丝奎拉希雅:BAAALAADCgIIAgAAAA==.',['瓦里']='瓦里安纯二郎:BAABLAAECn8ZAAIKAAgIiBfFSwD9AQAKAAgIiBfFSwD9AQAAAA==.',['生腌']='生腌大咕咕:BAAALAAECgEIAQAAAA==.',['电漏']='电漏了:BAAALAADCgYIBgAAAA==.',['疏影']='疏影织晚意:BAAALAAECggICAAAAA==.',['瘦了']='瘦了吧唧:BAAALAAECgYICAAAAA==.',['白猫']='白猫挽歌:BAAALAAFFAIIAgAAAA==.',['白貓']='白貓美樂蒂:BAAALAAECgYICQAAAA==.',['皮卡']='皮卡啾啾:BAAALAAFFAIIAgAAAA==.',['盲眼']='盲眼行者:BAAALAAECgYIBgAAAA==.',['看你']='看你的脚下:BAAALAAECggIBgAAAA==.',['看汐']='看汐:BAAALAAECgIIAQAAAA==.',['看看']='看看脚下:BAAALAADCggIAgAAAA==.',['真是']='真是蛋疼:BAAALAAFFAIIAwAAAA==.',['破冰']='破冰之刃:BAAALAAECgYIDwAAAA==.',['破天']='破天号士兵:BAAALAAFFAIIBAAAAA==.',['破晓']='破晓咸鱼汤:BAAALAAECgYIBgAAAA==.',['硌手']='硌手的松鼠航:BAAALAADCgYIBgAAAA==.',['硬棒']='硬棒棒丶:BAABLAAFFH8FAAMGAAMI4hb+IwBcAAAGAAIIciH+IwBcAAALAAEIwgEqYwAqAAAAAA==.',['碧月']='碧月蓝天:BAAALAADCgMIAwAAAA==.',['祁曰']='祁曰天:BAAALAAFFAIIBAAAAA==.',['神秘']='神秘伏击:BAAALAAECgIIAgAAAA==.',['神话']='神话夜空:BAABLAAECn8XAAIFAAYIHQdwdwDAAAAFAAYIHQdwdwDAAAAAAA==.神话星空:BAACLAAFFH8LAAICAAII+gUTXgB/AAACAAII+gUTXgB/AAAsAAQKfywAAgIACAgaGNYnAPUBAAIACAgaGNYnAPUBAAAA.',['秋水']='秋水迎风:BAAALAADCgIIBQAAAA==.',['空心']='空心禅:BAABLAAFFH8XAAMJAAYIMxWtBQBjAQAJAAYIUBKtBQBjAQAZAAYIKA4uMgA4AQAAAA==.',['空車']='空車王:BAAALAAECgYIBgAAAA==.',['第五']='第五号:BAAALAAFFAIIAgAAAA==.',['答应']='答应不愛你:BAABLAAFFH8IAAICAAgItxnWAwBXAgACAAgItxnWAwBXAgAAAA==.',['筱爱']='筱爱萨:BAAALAAFFAIIAgAAAA==.筱爱魂:BAABLAAFFH8FAAIDAAUINQMJUADeAAADAAUINQMJUADeAAAAAA==.',['箭之']='箭之影:BAAALAAECgYIDgAAAA==.',['米兰']='米兰的打铁匠:BAAALAAFFAIIAgAAAA==.',['米影']='米影縈繞丶:BAAALAAECgUIBQAAAA==.',['粗暴']='粗暴有活力:BAAALAAFFAIIBAAAAA==.',['精工']='精工炒:BAAALAAFFAYIAgAAAA==.',['紫凝']='紫凝:BAAALAAECgIIAgAAAA==.',['紫色']='紫色大苍蝇:BAAALAAECgYIBgAAAA==.',['紫訫']='紫訫:BAAALAAECgYIDAAAAA==.',['紫风']='紫风铃:BAAALAAECgYICAAAAA==.',['繁花']='繁花湮红尘:BAABLAAECn8XAAILAAYILxPUTQAsAQALAAYILxPUTQAsAQAAAA==.',['给奶']='给奶娘顶住:BAAALAAECgYIDQAAAA==.',['绿林']='绿林小妖:BAABLAAFFH8GAAIBAAIIJgqmqgA6AAABAAIIJgqmqgA6AAAAAA==.',['罐罐']='罐罐灬希希:BAAALAAECgMIAwAAAA==.罐罐灬晓猎:BAAALAAECgEIAQAAAA==.罐罐灬缇娜:BAAALAAECgUIBQAAAA==.',['罒厶']='罒厶罒:BAAALAADCgQIBQAAAA==.',['罗拉']='罗拉娜米莎凯:BAAALAAECgIIAgAAAA==.',['罗莎']='罗莎琳德:BAABLAAFFH8IAAMfAAIIthAwHgCQAAAfAAIIthAwHgCQAAAVAAII0AnwPgBhAAAAAA==.',['羽月']='羽月战神:BAAALAADCgIIAgAAAA==.',['翌日']='翌日不当差:BAAALAAECgQIBAAAAA==.',['耀骑']='耀骑士临光:BAABLAAECn8lAAMCAAYISxajXABNAQACAAYI8hWjXABNAQAMAAYICg3uJgDdAAAAAA==.',['老司']='老司机乐乐猪:BAAALAAECgcIDgAAAA==.',['老陌']='老陌:BAAALAAECggICAAAAA==.',['耐炖']='耐炖王:BAAALAADCgEIAQAAAA==.',['聆聽']='聆聽者丨風玲:BAAALAAECgYIBwAAAA==.',['肉筋']='肉筋卷饼:BAAALAAECgYICwAAAA==.',['胡亿']='胡亿菲:BAAALAAECgYIEAAAAA==.',['胤祥']='胤祥:BAACLAAFFH8MAAIDAAIImAyThQBDAAADAAIImAyThQBDAAAsAAQKfx4AAwMABgh5Ggk6AJQBAAMABgh5Ggk6AJQBACIABgiWBZ8jAJoAAAAA.',['自然']='自然沉睡:BAABLAAECn8ZAAIjAAYIwx+dCAC9AQAjAAYIwx+dCAC9AQAAAA==.',['艾仕']='艾仕梵女勋爵:BAAALAADCggICAAAAA==.',['艾瑞']='艾瑞达骑士:BAAALAADCgQIBAAAAA==.',['艾露']='艾露蒽女祭司:BAAALAAECgYICwAAAA==.',['芋泥']='芋泥啵啵:BAACLAAFFH8fAAMdAAYI/BYxFAC0AQAdAAYI/BYxFAC0AQAeAAEIUQFtMgAmAAAsAAQKfykAAx0ACAjqHQERAEwCAB0ACAjqHQERAEwCAB4AAgiYDMJJADwAAAAA.',['芙蘭']='芙蘭朵露:BAABLAAFFH8NAAILAAMIBwe+HgDRAAALAAMIBwe+HgDRAAAAAA==.',['芦苇']='芦苇笑倾城:BAAALAAFFAEIAQAAAA==.',['芬理']='芬理尔:BAAALAAFFAMIBAAAAA==.',['芭芭']='芭芭拉罗伯茨:BAAALAADCgQIBAAAAA==.',['苏利']='苏利文:BAAALAADCgcIBwAAAA==.',['莎莎']='莎莎蔓:BAAALAAECgIIAgAAAA==.',['莎蔓']='莎蔓莎:BAABLAAFFH8bAAMhAAYI5hC8CgAxAQAhAAUIqhO8CgAxAQAQAAUI0wCnEACuAAAAAA==.',['莴苣']='莴苣女士:BAAALAAECgEIAQAAAA==.莴苣姑娘:BAAALAAECgMIAwAAAA==.',['萌兽']='萌兽饲养员:BAAALAAECgYIBwAAAA==.',['萨斯']='萨斯壁嘞丶:BAABLAAFFH8JAAMKAAIIFhbOPwCCAAAKAAIIFhbOPwCCAAAHAAIIDwcTSgA9AAAAAA==.',['萨血']='萨血人生:BAAALAADCgYIBgAAAA==.',['蓝月']='蓝月凝:BAAALAAECgYICgAAAA==.',['蓝色']='蓝色圣翼会长:BAAALAAECgYIBgAAAA==.',['蕾西']='蕾西:BAABLAAFFH8IAAIJAAII5RqsEgBNAAAJAAII5RqsEgBNAAAAAA==.',['虹舞']='虹舞鸢翔:BAAALAADCggIDAAAAA==.',['蚑蚑']='蚑蚑:BAABLAAECn8qAAQbAAgIWRn/GQBOAgAbAAgI9hj/GQBOAgAaAAcIURMFGgCtAQAkAAQIxRF6EwD4AAAAAA==.',['蜀道']='蜀道山:BAAALAAECgYIDAAAAA==.',['血兽']='血兽:BAAALAAFFAIIAgAAAA==.',['血色']='血色洗礼:BAACLAAFFH86AAIZAAcIZyDlCQBDAgAZAAcIZyDlCQBDAgAsAAQKfzcAAhkACAjmIqMIAJICABkACAjmIqMIAJICAAAA.',['術灬']='術灬仕:BAAALAADCgEIAQAAAA==.',['西猫']='西猫:BAAALAAECggICAAAAA==.',['角落']='角落微光:BAAALAADCgMICQAAAA==.',['言涩']='言涩可好:BAAALAAECgYIDgAAAA==.',['誓约']='誓约胜利之剑:BAAALAAFFAIIAgAAAA==.',['语秋']='语秋:BAAALAAECgYIBwAAAA==.',['诺兰']='诺兰:BAAALAAECgUIBQAAAA==.',['谜丶']='谜丶:BAAALAAECgMIAwAAAA==.',['豪七']='豪七丶:BAABLAAFFH8JAAIBAAUIIxCzVwDtAAABAAUIIxCzVwDtAAAAAA==.',['貓狗']='貓狗雙全:BAABLAAFFH8MAAMlAAYIaxikBwBRAQAlAAQIzxOkBwBRAQAYAAQInRdlBwBKAQAAAA==.',['贾斯']='贾斯汀鼻伯:BAAALAAECgYIBgAAAA==.',['起什']='起什么名字:BAAALAAECgYIEgAAAA==.起什么破名字:BAABLAAECn8YAAMPAAYIFSBhLwAIAgAPAAYIFSBhLwAIAgABAAEIhBq0KAFEAAAAAA==.',['超极']='超极巨化木头:BAAALAADCgYIBgAAAA==.',['超熊']='超熊小狸猫:BAAALAAECgYIDAABLAAFFAIIBgALACUbAA==.',['輪回']='輪回之黯:BAAALAAECgMIAwAAAA==.',['辉丶']='辉丶夜:BAAALAAFFAIIBAAAAA==.',['过来']='过来撮一口丶:BAAALAAECgYIBgAAAA==.',['迦楼']='迦楼罗:BAAALAAECgYIBgAAAA==.',['追星']='追星逐日:BAAALAAECgEIAQAAAA==.',['逆风']='逆风收割者:BAAALAAECgQIBwAAAA==.',['遇求']='遇求得道:BAAALAAECgYIBgAAAA==.',['部落']='部落丶话事人:BAABLAAECn8XAAICAAYIsyOWKADyAQACAAYIsyOWKADyAQAAAA==.',['郭将']='郭将军:BAAALAAECgEIAQAAAA==.',['酒酿']='酒酿小马蹄:BAABLAAFFH8GAAICAAYIlQCtgwAfAAACAAYIlQCtgwAfAAAAAA==.',['鎏智']='鎏智湘:BAABLAAFFH8FAAMRAAUIXQ/ZQQDgAAARAAQIyRLZQQDgAAASAAEIrwH/CgAzAAAAAA==.',['铁乳']='铁乳堡守卫:BAAALAAECgQIBAAAAA==.',['铜须']='铜须领主:BAAALAAFFAIIAgAAAA==.',['银月']='银月之星:BAAALAAECgEIAQAAAA==.',['长大']='长大了不好:BAAALAAFFAIIAgAAAA==.',['长崎']='长崎爽世:BAAALAAECggIDQABLAAFFAIIAwATAAAAAA==.',['长期']='长期素食:BAAALAAECgMIAQAAAA==.',['长江']='长江魂:BAAALAAFFAIIAgAAAA==.',['问天']='问天要白头:BAAALAAFFAEIAQAAAA==.',['闲卿']='闲卿灬:BAABLAAFFH8RAAMVAAYI5BE0FgCDAQAVAAYI5BE0FgCDAQAfAAEIiQHnPwAiAAAAAA==.',['阿二']='阿二萨斯:BAAALAAECgYIDAAAAA==.',['阿尓']='阿尓托莉蕥:BAAALAAECggIDgAAAA==.',['阿祖']='阿祖没时间:BAABLAAFFH8aAAMRAAYIQybZDQAoAgARAAYI9yXZDQAoAgASAAQI/iNHAgBQAQABLAAFFAgIIgARAH0lAA==.',['阿美']='阿美利卡:BAAALAAECgYIBgAAAA==.',['陕北']='陕北铁皮皮:BAABLAAFFH8IAAIDAAIItgc1iwB+AAADAAIItgc1iwB+AAAAAA==.',['雷斯']='雷斯琳马哲理:BAAALAAECgUIBQAAAA==.',['雷米']='雷米莉亚:BAACLAAFFH8KAAIFAAMIug7xQgCAAAAFAAMIug7xQgCAAAAsAAQKfxcAAgUACAiUGiklAMkBAAUACAiUGiklAMkBAAAA.',['雾落']='雾落无垠:BAABLAAFFH8HAAIGAAIIjw/7LwAzAAAGAAIIjw/7LwAzAAAAAA==.',['霊儿']='霊儿曦諾:BAAALAAFFAIIAgABLAAFFAYIJgABAFUgAA==.霊儿钰琪:BAAALAAFFAMIAwABLAAFFAYIJgABAFUgAA==.',['霏雨']='霏雨:BAAALAAECgUIBQAAAA==.',['露西']='露西安:BAAALAADCgQIBAAAAA==.',['霸气']='霸气角斗士:BAABLAAFFH8GAAMPAAIImghoKwBwAAAPAAIImghoKwBwAAABAAEI5gY6rwA3AAAAAA==.',['青柠']='青柠:BAAALAAECgcIBwAAAA==.青柠劲爽无糖:BAAALAAECgYIBgAAAA==.',['青莲']='青莲之炎:BAABLAAECn8UAAMVAAgIDxsGHQCBAgAVAAgIDxsGHQCBAgAfAAIIxxM/kQCBAAAAAA==.',['靓到']='靓到爆炸:BAAALAADCgEIAQAAAA==.',['非墨']='非墨:BAAALAAECgcIBwAAAA==.',['非常']='非常帅帅:BAAALAAECgYIBgAAAA==.非常的有钱:BAAALAAECggIDQAAAA==.',['響今']='響今:BAAALAAECgYIBwAAAA==.',['风中']='风中摇曳桃子:BAAALAAECgMIAwAAAA==.',['风残']='风残凌云:BAAALAAECgYIBgAAAA==.风残凌曰:BAAALAAECgQIBAAAAA==.',['风灵']='风灵喵:BAAALAAFFAEIAQAAAA==.',['飒飒']='飒飒伊:BAAALAADCgcIDAAAAA==.',['飘宝']='飘宝丶:BAAALAAECgEIAQAAAA==.',['飘摇']='飘摇的风筝:BAAALAAECgcIEwAAAA==.',['飘飘']='飘飘小仙:BAAALAAECgYIBgAAAA==.',['飞雪']='飞雪:BAAALAADCgIIAgAAAA==.',['飞龙']='飞龙一族:BAAALAAECgEIAQAAAA==.',['香芋']='香芋牛奶:BAABLAAFFH8IAAIFAAIIKQWAWgB/AAAFAAIIKQWAWgB/AAAAAA==.',['马油']='马油:BAAALAAECgYICgAAAA==.',['魅惑']='魅惑骑士:BAAALAAECgYICwAAAA==.',['魑魅']='魑魅魍魉魍魉:BAAALAAECgEIAQAAAA==.',['魔女']='魔女琪莉:BAAALAADCgYIBgAAAA==.',['魔魂']='魔魂小烈:BAAALAAECgYIDAAAAA==.',['鲜血']='鲜血的刃:BAAALAAECgUIBQAAAA==.',['鲸鱼']='鲸鱼的羽毛:BAAALAAECgMIAwAAAA==.',['鸟小']='鸟小妹:BAAALAAECgYICgAAAA==.',['鸡蛋']='鸡蛋饼:BAAALAAECggIAgAAAA==.',['麻倉']='麻倉憂:BAAALAAECgQIBAAAAA==.',['黄少']='黄少天:BAAALAAECggICAAAAA==.黄少天丶:BAAALAADCgQIAwAAAA==.',['黄昏']='黄昏现白骨:BAAALAAECgMIBAAAAA==.',['黄甩']='黄甩花:BAAALAAECgYIBQAAAA==.',['黑妹']='黑妹来了:BAAALAAECgcICAAAAA==.',['黑暗']='黑暗骑士:BAAALAAECgIIAgAAAA==.',['黑柃']='黑柃:BAAALAAECgMIAwAAAA==.',['黑猫']='黑猫挽歌:BAAALAAECgcIBwAAAA==.',['黑空']='黑空:BAAALAAECgUIBQAAAA==.',['黯织']='黯织:BAAALAAFFAIIAgAAAA==.',['龍兒']='龍兒咕咕:BAAALAAFFAIIAgAAAA==.',['龙猫']='龙猫挽歌:BAABLAAFFH8GAAIGAAYIjAAiMgAwAAAGAAYIjAAiMgAwAAAAAA==.',['龙鳞']='龙鳞马:BAABLAAFFH8GAAIDAAUITBACRgAiAQADAAUITBACRgAiAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end