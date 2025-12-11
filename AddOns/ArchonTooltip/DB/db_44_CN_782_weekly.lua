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
 local lookup = {'Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Mage-Arcane','Priest-Shadow','Unknown-Unknown','Druid-Restoration','DemonHunter-Havoc','Hunter-BeastMastery','Paladin-Holy','Evoker-Devastation','Mage-Frost','Mage-Fire','Druid-Guardian','DeathKnight-Unholy','DeathKnight-Frost','Evoker-Preservation','Warrior-Protection','Priest-Holy','Warrior-Arms','Warrior-Fury','Warlock-Destruction','Warlock-Demonology','Monk-Brewmaster','Paladin-Protection','DemonHunter-Vengeance','Monk-Windwalker','Monk-Mistweaver','Shaman-Enhancement','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Blood','Rogue-Subtlety','Rogue-Assassination','Druid-Feral','Warlock-Affliction','Priest-Discipline',}; local provider = {region='CN',realm='索拉丁',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Anglela:BAAALAAECgQIBAAAAA==.Anthea:BAABLAAFFH8GAAIBAAIIGgvyWwCEAAABAAIIGgvyWwCEAAAAAA==.',At='Atalanta:BAAALAADCgMIBAAAAA==.',Bi='Bits:BAAALAAFFAEIAQAAAA==.',Bl='Blackdevil:BAABLAAFFH8KAAMCAAYI0BcEGQCUAQACAAYI0BcEGQCUAQADAAIInhQsRABEAAAAAA==.',Bo='Bobo:BAABLAAFFH8LAAMCAAYIbhimDAB1AQACAAUIPRmmDAB1AQADAAEIZwf5OwBPAAAAAA==.Bombom:BAAALAADCgIIAgAAAA==.',Ca='Captain:BAAALAAFFAgIAgAAAA==.',Dr='Dragon:BAAALAAECgYIBgAAAA==.',Ef='Efrosini:BAACLAAFFH8GAAIEAAIIfwtVNgA5AAAEAAIIfwtVNgA5AAAsAAQKfyMAAgQABwgNHfUjAEcCAAQABwgNHfUjAEcCAAAA.',Ex='Expendable:BAAALAAFFAIIAgAAAA==.',Fl='Flamehaze:BAABLAAFFH8FAAIFAAUI6h4ALwBNAQAFAAUI6h4ALwBNAQAAAA==.',Ga='Gary:BAAALAAFFAYIAgAAAA==.',Ge='Geminimoon:BAAALAADCgYIBgAAAA==.',Hy='Hypersonic:BAAALAAFFAIIAgAAAA==.',Kk='Kkoduck:BAAALAAECgYIBwAAAA==.',Le='Leedaehae:BAAALAAFFAYIAgAAAA==.',Ma='Mal:BAAALAAECgYIBgAAAA==.Masami:BAACLAAFFH8rAAIGAAcI7hyfBQAMAgAGAAcI7hyfBQAMAgAsAAQKfzMAAgYACAgEJNMwAAcCAAYACAgEJNMwAAcCAAEsAAUUCAgBAAcAAAAA.',Md='Mdreadnought:BAAALAAECgYICAAAAA==.',Me='Medusa:BAAALAADCggIDAAAAA==.',Mg='Mghost:BAAALAAECgQICAAAAA==.',Mz='Mzghost:BAAALAAECgYIEAAAAA==.',Na='Naigiao:BAABLAAFFH8NAAIIAAYIYgsCCQCCAQAIAAYIYgsCCQCCAQAAAA==.',Ni='Nicole:BAAALAAECgYIEwAAAA==.Nikita:BAAALAAFFAIIAgAAAA==.Nil:BAAALAAECgYIDQAAAA==.',No='Noble:BAAALAAECgYIEAAAAA==.',Oe='Oenneo:BAAALAAECgIIAgAAAA==.',Pe='Peny:BAAALAADCgYICAAAAA==.',Pl='Playerldfpwf:BAABLAAFFH8GAAIJAAII7AalYgA9AAAJAAII7AalYgA9AAAAAA==.',Po='Poison:BAAALAADCggICAAAAA==.',Pr='Prodk:BAAALAAECgYIBgAAAA==.Promising:BAABLAAFFH8GAAIKAAYIKgoPSQAnAQAKAAYIKgoPSQAnAQAAAA==.Prosperity:BAABLAAFFH8GAAILAAMItx2BGQDyAAALAAMItx2BGQDyAAAAAA==.Prosperityek:BAACLAAFFH8NAAIMAAMIpw8zFwCGAAAMAAMIpw8zFwCGAAAsAAQKfxkAAgwACAhoELkcAAsBAAwACAhoELkcAAsBAAAA.Prrodigal:BAABLAAFFH8IAAMNAAMIeRNbFQBEAAAFAAMITwmFSgBxAAANAAIIKxxbFQBEAAAAAA==.',Ro='Robbie:BAAALAADCgcIBwAAAA==.',Sa='Salxzz:BAABLAAFFH8HAAIOAAUIqRVLBAA+AQAOAAUIqRVLBAA+AQAAAA==.',Se='Selena:BAAALAAFFAIIBAAAAA==.',So='Sophitia:BAAALAAECgEIAQAAAA==.',St='Stheno:BAAALAAECgEIAQAAAA==.',Sv='Sv:BAAALAAECgEIAQAAAA==.',Tr='Trisfal:BAABLAAFFH8GAAIFAAYIUBlqIQCQAQAFAAYIUBlqIQCQAQAAAA==.',Vv='Vvlkhr:BAAALAAECgMIAwAAAA==.',Wa='Waterbady:BAAALAAECgYIBwAAAA==.',Wo='Wonderlandkk:BAAALAADCgMIAwAAAA==.',['一个']='一个时代:BAABLAAFFH8HAAIPAAYIIgQ1BgCpAAAPAAYIIgQ1BgCpAAAAAA==.',['一二']='一二三阿肆:BAAALAAECgEIAQAAAA==.',['一休']='一休师傅:BAAALAAFFAIIAgAAAA==.',['一傻']='一傻馒一:BAAALAAECgMIAwAAAA==.',['一箭']='一箭穿心:BAACLAAFFH8VAAIKAAMIUiJAXgDJAAAKAAMIUiJAXgDJAAAsAAQKfxsAAgoACAhxIXI4AOEBAAoACAhxIXI4AOEBAAAA.',['一粒']='一粒大丹:BAABLAAFFH8MAAIJAAYI8A4NJABrAQAJAAYI8A4NJABrAQAAAA==.',['七夜']='七夜晓晓圣君:BAAALAAFFAYIBAAAAA==.',['七岁']='七岁柠檬:BAABLAAFFH8JAAIKAAIIjgeofQBqAAAKAAIIjgeofQBqAAAAAA==.',['三房']='三房印象:BAAALAAECgMIBAAAAA==.三房神射:BAAALAAECgMIAwAAAA==.三房霜语:BAAALAAECgYICwAAAA==.',['三旬']='三旬老汉:BAAALAAFFAIIAgAAAA==.',['上古']='上古饕餮聖騎:BAACLAAFFH8QAAIBAAMIWBh0PQCdAAABAAMIWBh0PQCdAAAsAAQKfxgAAgEACAjMFSJlADkBAAEACAjMFSJlADkBAAAA.',['上海']='上海龙:BAAALAAFFAYIAwAAAA==.',['不死']='不死也残废:BAAALAADCgEIAQAAAA==.',['丛容']='丛容:BAAALAAECgMIAwAAAA==.',['临舟']='临舟:BAAALAADCgIIAgAAAA==.',['丶不']='丶不会忘记你:BAABLAAFFH8HAAMQAAMIVguMDACTAAAQAAIIEQyMDACTAAARAAIIUgX+qgAQAAAAAA==.',['为了']='为了灰烬使者:BAAALAADCgEIAQAAAA==.',['为你']='为你写诗:BAAALAAFFAIIAgAAAA==.',['乌露']='乌露托:BAAALAAECgEIAQAAAA==.',['乐在']='乐在琦中:BAAALAAECgYIBgAAAA==.',['乖乖']='乖乖龙地咚:BAACLAAFFH8OAAISAAIImAMpGQBtAAASAAIImAMpGQBtAAAsAAQKfxgAAxIABghHChEtAPgAABIABghHChEtAPgAAAwABAg5B5onAJ4AAAAA.',['九八']='九八武:BAAALAAECgEIAQAAAA==.',['九月']='九月:BAAALAAECgIIAgAAAA==.',['二十']='二十一克拉:BAAALAAECgcICwAAAA==.二十七夜月:BAAALAAECgYIDwABLAAFFAMIEwANANAaAA==.',['二班']='二班同学:BAAALAAECgYICAAAAA==.',['人生']='人生丨寂寞:BAAALAAECgYIBgAAAA==.',['人矮']='人矮边长:BAAALAAECgYIDAAAAA==.',['亿人']='亿人斩:BAABLAAFFH8LAAITAAII5Qb2OAAmAAATAAII5Qb2OAAmAAAAAA==.',['仓鼠']='仓鼠叫兽丶:BAAALAAECgEIAQAAAA==.',['伊丽']='伊丽莎白斯:BAAALAADCgUIBQAAAA==.',['伊拉']='伊拉克退休工:BAAALAAFFAIIAgAAAA==.',['伊瑞']='伊瑞妲:BAAALAAECgQIBAAAAA==.',['伊笑']='伊笑泯恩仇:BAAALAAECgcIBwAAAA==.',['伐三']='伐三伐四:BAAALAADCgcIBwAAAA==.',['休息']='休息一下:BAAALAADCgMIAwAAAA==.',['余生']='余生难渡:BAAALAAFFAIIAgAAAA==.',['佛法']='佛法无边无级:BAACLAAFFH8UAAINAAMIRSOvBgDYAAANAAMIRSOvBgDYAAAsAAQKfyYAAg0ACAhnJVIJAAIDAA0ACAhnJVIJAAIDAAEsAAUUBAgZABQAAyAA.',['你们']='你们缺德吗:BAAALAAECgMIAwAAAA==.',['你在']='你在这养鱼呢:BAAALAAECggICAABLAAFFAgIIgAJAGEcAA==.',['你相']='你相信光吗:BAAALAAECgYICQAAAA==.',['依依']='依依妹:BAABLAAFFH8GAAICAAIIfAZXbQBOAAACAAIIfAZXbQBOAAAAAA==.',['依然']='依然丶魔君灬:BAABLAAFFH8IAAIBAAIIgxmYRACbAAABAAIIgxmYRACbAAAAAA==.依然怀恋过去:BAAALAAECgQIAwAAAA==.',['信仰']='信仰战:BAABLAAECn8WAAMVAAgIExvtCgAtAgAVAAgItBbtCgAtAgAWAAcIVRt6QgAsAgABLAAFFAcIDgAWAPoQAA==.',['俺徒']='俺徒弟叫花荣:BAAALAAECgIIAgAAAA==.',['假超']='假超换真屮:BAAALAAECgQIBAAAAA==.',['偶滴']='偶滴神吖:BAAALAAECgMIBAAAAA==.',['偶踢']='偶踢:BAAALAADCgMIAwAAAA==.',['僾洅']='僾洅彼岸:BAAALAAECgQIBAAAAA==.僾洅飒煞:BAAALAADCgIIAgAAAA==.',['光阴']='光阴之外:BAAALAAECgYIDgAAAA==.',['全镇']='全镇的希望:BAABLAAFFH8GAAICAAIIyh43PwCDAAACAAIIyh43PwCDAAAAAA==.',['八条']='八条街:BAAALAAECgEIAQAAAA==.',['具红']='具红:BAAALAAECgYICQAAAA==.',['兽头']='兽头骨气:BAACLAAFFH8ZAAMXAAYIPxAvLgBhAQAXAAYIPxAvLgBhAQAYAAEIZhMdLABLAAAsAAQKfxcAAxcABwhzHXocAP4BABcABgibHHocAP4BABgAAwj+EdmHAGMAAAAA.',['兽眼']='兽眼通天:BAABLAAFFH8ZAAIBAAUIAhoHIwBWAQABAAUIAhoHIwBWAQAAAA==.',['冬叶']='冬叶:BAAALAADCgEIAQAAAA==.',['冰雪']='冰雪梦寒天:BAAALAAECgUIBQAAAA==.',['冲锋']='冲锋大跳飞尸:BAAALAADCgYIBQAAAA==.',['凉水']='凉水:BAAALAAFFAIIAgAAAA==.',['凌晴']='凌晴傲雪:BAACLAAFFH8oAAIPAAYIDBJ8AQA8AQAPAAYIDBJ8AQA8AQAsAAQKfx8AAg8ACAiJEtkTAKIBAA8ACAiJEtkTAKIBAAAA.',['凭栏']='凭栏倚吞云烟:BAACLAAFFH8GAAIBAAII3Rp+XgBHAAABAAII3Rp+XgBHAAAsAAQKfx0AAgEABgjeHck5ALABAAEABgjeHck5ALABAAAA.',['刀板']='刀板香:BAAALAAECgIIAgAAAA==.',['初见']='初见的小当家:BAAALAADCgQIBAAAAA==.',['初露']='初露青提:BAACLAAFFH8HAAMOAAUInQZyCABzAAAFAAMIWQevPgDBAAAOAAMIVwZyCABzAAAsAAQKfxQAAwUABgiUFzcyAEoBAAUABggMFzcyAEoBAA0AAQgYFyGOAEAAAAAA.',['初音']='初音骑士:BAAALAAECgEIAQAAAA==.',['别打']='别打了要碎了:BAABLAAFFH8TAAIZAAMIWAaRGwBYAAAZAAMIWAaRGwBYAAAAAA==.',['别逼']='别逼我:BAAALAAECgYIBgAAAA==.',['剩骑']='剩骑士:BAABLAAFFH8NAAMBAAUIVAaEMwDlAAABAAUIVAaEMwDlAAAaAAIIXwODIQBNAAAAAA==.',['功成']='功成破万骨:BAAALAAECgMIAwAAAA==.',['加纳']='加纳:BAAALAAFFAIIAgAAAA==.',['勥氼']='勥氼慸:BAAALAAECgMIAwAAAA==.',['半吨']='半吨:BAAALAAECgYICgAAAA==.',['半枝']='半枝莲:BAABLAAFFH8GAAIBAAIIjwsoUgCQAAABAAIIjwsoUgCQAAAAAA==.',['卓越']='卓越的玄冰剑:BAABLAAFFH8RAAMTAAYIjwJhIAB2AAATAAUIzAFhIAB2AAAWAAQIwAKQPgBrAAAAAA==.',['南也']='南也:BAAALAAECgYICQAAAA==.',['博拉']='博拉沙火鸟:BAAALAADCggICAAAAA==.',['卜耀']='卜耀霆:BAAALAAECggICAAAAA==.',['卢娜']='卢娜洛夫古德:BAAALAADCgYIBgAAAA==.',['双子']='双子逆鳞:BAAALAADCgEIAQAAAA==.',['反方']='反方向的钟:BAAALAAFFAIIAgAAAA==.',['只手']='只手遮天:BAAALAAECgYIBgAAAA==.',['可爱']='可爱捏:BAABLAAFFH8VAAIRAAUIYBmKOwBMAQARAAUIYBmKOwBMAQAAAA==.',['叹半']='叹半世浮华:BAACLAAFFH8WAAMJAAMI9AqJQACMAAAJAAMIKwqJQACMAAAbAAIIXwqOFwAmAAAsAAQKfxgAAxsACAjRDhMeAKsAAAkABggvD9XUADgBABsABAgeDBMeAKsAAAAA.',['吃了']='吃了莓:BAABLAAFFH8YAAIJAAYIJhzLGQChAQAJAAYIJhzLGQChAQABLAAFFAgICAAJAGkDAA==.',['吉梨']='吉梨窕冥:BAABLAAECn8ZAAMcAAYIhha1FQBhAQAcAAYIhha1FQBhAQAdAAYImwbbIwCeAAAAAA==.',['后弦']='后弦:BAABLAAFFH8ZAAIKAAUI6wWJWgDdAAAKAAUI6wWJWgDdAAAAAA==.',['听话']='听话的娃娃:BAAALAADCgYIBgAAAA==.',['吴一']='吴一凡:BAAALAAECgIIAgAAAA==.',['吾本']='吾本地瓜:BAAALAAECgYIDgAAAA==.',['呦呦']='呦呦奶茶:BAAALAAFFAIIAgAAAA==.',['呵嘻']='呵嘻哈咔:BAABLAAECn8WAAQeAAYIHBNTCQBJAQAeAAYIHBNTCQBJAQADAAQIlQjjpQDBAAACAAEIPggorAAfAAAAAA==.',['咆哮']='咆哮:BAAALAAFFAMIBAAAAA==.',['咕噜']='咕噜牙牙:BAAALAAECgYIBgAAAA==.',['咖啡']='咖啡加牛奶:BAAALAAECgEIAQAAAA==.',['咸酸']='咸酸菜炒乜嘢:BAAALAAFFAEIAQAAAA==.',['哈迪']='哈迪斯:BAAALAAECgYIDgAAAA==.',['哥斯']='哥斯拉:BAAALAADCgEIAQAAAA==.',['哴偲']='哴偲咩語:BAAALAAECgYIDgAAAA==.',['唐吉']='唐吉柯德鲁易:BAAALAAECgEIAQAAAA==.',['啊呀']='啊呀一:BAAALAAECgMIAwAAAA==.',['啥都']='啥都不缺:BAAALAAECgEIAQAAAA==.',['嗜杀']='嗜杀冥皇:BAABLAAECn8mAAQNAAgIPxwSIAAbAgANAAgI4hYSIAAbAgAFAAgIwRoGZwDSAQAOAAQIQQ0JEwDVAAAAAA==.',['嗜血']='嗜血狂骑:BAAALAAECgYICAAAAA==.嗜血胧:BAAALAAFFAIIAgAAAA==.嗜血雷神:BAAALAAECgMIAwAAAA==.嗜血龍:BAAALAAECgYIEgAAAA==.',['四法']='四法靑雲:BAAALAADCgYICAAAAA==.',['四维']='四维三三丶:BAAALAAECgUICAAAAA==.四维维丶三三:BAAALAAECgMIAwAAAA==.',['国宝']='国宝壹号:BAACLAAFFH8WAAIdAAYIDAunCwBEAQAdAAYIDAunCwBEAQAsAAQKfxQAAh0ACAiREU0RAI4BAB0ACAiREU0RAI4BAAAA.',['图腾']='图腾舞清影:BAABLAAFFH8JAAMCAAMIeBH7UgB1AAACAAIIFRf7UgB1AAADAAMIAgxuOQByAAAAAA==.',['圣光']='圣光普照:BAAALAAECgQIBAAAAA==.圣光的魔女:BAAALAADCgYIBgAAAA==.圣光赐福:BAAALAAECgYIBgAAAA==.',['圣诞']='圣诞星:BAAALAAECgUIBQAAAA==.',['圣龙']='圣龙骑士:BAAALAAECgYIBwAAAA==.',['在燃']='在燃烧的天空:BAACLAAFFH8RAAIfAAMIeAvuDwB9AAAfAAMIeAvuDwB9AAAsAAQKfxkAAh8ACAgcEoJYAFcBAB8ACAgcEoJYAFcBAAAA.',['地发']='地发杀机:BAAALAADCgIIAgAAAA==.',['坚强']='坚强的葡萄:BAAALAADCgYIBgAAAA==.',['埃尔']='埃尔莎:BAAALAADCgcIBwAAAA==.',['塔奇']='塔奇克马:BAAALAAECgYIDAAAAA==.塔奇可码:BAAALAAECgYIBgAAAA==.',['塔玛']='塔玛西亚:BAAALAAECgUIBQAAAA==.',['墨竹']='墨竹:BAAALAAECgYIBgAAAA==.',['壹貮']='壹貮貮零:BAAALAAECgUIBQAAAA==.',['壹零']='壹零贰陆:BAAALAAECgYIBgAAAA==.',['夏末']='夏末梧桐:BAAALAAECggICAAAAA==.',['多尔']='多尔南:BAAALAADCgEIAQAAAA==.',['大喵']='大喵使者:BAABLAAECn8UAAMDAAgIHRBEKwBrAQADAAgIHRBEKwBrAQACAAUI0Au76wC+AAAAAA==.',['大地']='大地战骑:BAABLAAFFH8GAAIBAAYIcxwvEADDAQABAAYIcxwvEADDAQAAAA==.',['大黑']='大黑耗子:BAAALAAECgYICAAAAA==.',['天圣']='天圣隼:BAACLAAFFH8XAAILAAMIQw2NHwClAAALAAMIQw2NHwClAAAsAAQKfx4AAgsACAjpEGA6AHkBAAsACAjpEGA6AHkBAAAA.',['天天']='天天锤德萨:BAABLAAFFH8FAAMDAAUIiwz5LQDHAAADAAQI1Ar5LQDHAAACAAEIyQnoeQA2AAAAAA==.天天锤胖子:BAABLAAFFH8JAAITAAYILA2FEwAmAQATAAYILA2FEwAmAQAAAA==.天天锤胖胖:BAABLAAFFH8GAAIKAAYI/RPcDADPAQAKAAYI/RPcDADPAQAAAA==.天天锤贴贴:BAABLAAFFH8GAAIZAAYILBbEDgBbAQAZAAYILBbEDgBbAQABLAAFFAgIBwARAFQYAA==.天天锤锤:BAABLAAFFH8FAAMLAAUIAQrSGwDNAAALAAQINwXSGwDNAAABAAEI3gXGbgA/AAAAAA==.',['天灰']='天灰:BAAALAADCggICAAAAA==.',['天灾']='天灾指挥官:BAAALAAFFAMIAwAAAA==.',['天神']='天神:BAABLAAFFH8HAAIGAAIIuxRuIgCIAAAGAAIIuxRuIgCIAAAAAA==.',['天魔']='天魔隼:BAAALAAECgcICgAAAA==.',['失心']='失心:BAAALAAFFAIIAgAAAA==.',['奔波']='奔波儿灞奈奈:BAAALAAECgMIAwAAAA==.',['奥丁']='奥丁:BAAALAAFFAIIAgAAAA==.',['奥德']='奥德飙:BAABLAAFFH8PAAIFAAgIyBxgCABeAgAFAAgIyBxgCABeAgAAAA==.奥德飙拉香蕉:BAABLAAFFH8HAAIFAAcIyBuTCQAhAgAFAAcIyBuTCQAhAgAAAA==.',['奥菲']='奥菲利雅:BAAALAAECgMIBgAAAA==.',['奥蕾']='奥蕾利亚:BAABLAAFFH8GAAIgAAIIWRVwBQBFAAAgAAIIWRVwBQBFAAAAAA==.',['奶色']='奶色的鹏:BAAALAAECgYICwAAAA==.',['好么']='好么哒哒:BAAALAAECgMICQAAAA==.',['好运']='好运的小熊:BAACLAAFFH8FAAIKAAQIaBDAYAC7AAAKAAQIaBDAYAC7AAAsAAQKfzIAAgoACAgAIfwtAKECAAoACAgAIfwtAKECAAAA.',['妖妖']='妖妖凛:BAABLAAFFH8KAAICAAIIDx+cLgClAAACAAIIDx+cLgClAAAAAA==.',['妖月']='妖月儿:BAABLAAFFH8GAAIUAAMIpgN1NgCJAAAUAAMIpgN1NgCJAAAAAA==.',['妮妮']='妮妮想家了:BAABLAAECn8aAAICAAgIaBoDTwD1AQACAAgIaBoDTwD1AQAAAA==.',['姜子']='姜子牙疼:BAAALAAECgIIAgAAAA==.',['娑迷']='娑迷:BAAALAAECgYIDgAAAA==.',['娜沙']='娜沙:BAAALAAECggICAAAAA==.',['娜莎']='娜莎:BAAALAAECgMIAwAAAA==.',['婉清']='婉清:BAABLAAFFH8JAAIUAAIIjx14MACpAAAUAAIIjx14MACpAAAAAA==.',['子曰']='子曰郁闷:BAAALAADCgMIAwAAAA==.',['宅豚']='宅豚肥鸟:BAAALAADCgMIBwAAAA==.',['寂寞']='寂寞丨人生:BAAALAADCgIIAgAAAA==.',['密斯']='密斯忒琪:BAAALAAECgMIAwAAAA==.',['对我']='对我说慌试试:BAAALAADCgYIBgAAAA==.',['封尘']='封尘后羿:BAAALAAECgQIBAAAAA==.',['将心']='将心比心:BAACLAAFFH8GAAIUAAIIHBBJPABxAAAUAAIIHBBJPABxAAAsAAQKfxYAAhQABggeEbVtADIBABQABggeEbVtADIBAAAA.',['小丨']='小丨猎丨人丨:BAABLAAFFH8OAAIKAAQI6weEZgCcAAAKAAQI6weEZgCcAAAAAA==.',['小吖']='小吖:BAAALAAECgYIEQAAAA==.',['小姜']='小姜维:BAAALAADCgQIBAAAAA==.',['小婕']='小婕婕会放电:BAACLAAFFH8ZAAICAAMIiwyqRQCVAAACAAMIiwyqRQCVAAAsAAQKfyIAAgIACAgVFTxxAKABAAIACAgVFTxxAKABAAAA.',['小小']='小小倬雅:BAABLAAFFH8IAAMCAAgI5xOrHAB2AQACAAYI0xSrHAB2AQADAAIIKAgjNgCEAAAAAA==.小小朱:BAAALAAECgQIBAAAAA==.小小水月:BAAALAAECgYICgAAAA==.小小法:BAAALAAFFAMIBAAAAA==.小小萨满:BAABLAAFFH8IAAIDAAIIyQVSTAA6AAADAAIIyQVSTAA6AAAAAA==.小小骑士:BAAALAAECgYICAAAAA==.小小骑市:BAAALAAECgIIAgAAAA==.',['小尐']='小尐:BAAALAAECgQIBAAAAA==.',['小尒']='小尒:BAAALAAECgYIEgAAAA==.',['小巷']='小巷俏佳人:BAABLAAFFH8KAAMCAAYIlBgJHQB0AQACAAUIkBkJHQB0AQADAAEIJhF9PwBLAAAAAA==.',['小旭']='小旭:BAAALAAECgMIAwAAAA==.',['小米']='小米锅巴:BAABLAAFFH8RAAICAAMI5Bz6LQD7AAACAAMI5Bz6LQD7AAAAAA==.',['小轩']='小轩子:BAAALAAECgUIBQAAAA==.',['小龙']='小龙人四维:BAAALAAECgEIAQAAAA==.',['尼古']='尼古拉斯肇事:BAAALAADCgcIBwAAAA==.',['山居']='山居寒潭:BAAALAAECgQIBAAAAA==.',['岁阳']='岁阳:BAAALAADCggICQAAAA==.',['巫行']='巫行雲:BAAALAAECgYIDAAAAA==.',['希利']='希利苏斯的夜:BAAALAAECgYIBgAAAA==.',['希尔']='希尔瓦娜撕:BAAALAAECgMIBQAAAA==.',['帮紧']='帮紧你帮紧你:BAAALAAECgYICAAAAA==.',['幕后']='幕后水滴:BAAALAAECgcIDAAAAA==.',['幸福']='幸福的麦麦:BAAALAAFFAIIAwAAAA==.',['幻想']='幻想奇侠:BAAALAAFFAIIBAAAAA==.幻想奇侠试玩:BAAALAAFFAEIAQAAAA==.幻想的猎手:BAAALAAFFAIIAwAAAA==.',['幻缘']='幻缘:BAABLAAFFH8iAAITAAYImBEpEgA0AQATAAYImBEpEgA0AQAAAA==.',['幽冥']='幽冥猫:BAAALAAECgYIBgAAAA==.',['幽幽']='幽幽子:BAAALAAECgYIBgAAAA==.幽幽沐丝:BAAALAADCggICAAAAA==.',['幽漓']='幽漓:BAAALAAECgEIAQAAAA==.',['广智']='广智救我:BAABLAAFFH8SAAMRAAYIdSKiBABbAgARAAYIdSKiBABbAgAhAAYIZxHgAwDeAQAAAA==.',['弑魔']='弑魔者之殇:BAAALAAECgMIAwAAAA==.',['引路']='引路的苍蓝星:BAABLAAFFH8HAAIKAAUIoR5NOwBVAQAKAAUIoR5NOwBVAQAAAA==.',['张大']='张大仙:BAABLAAFFH8QAAIIAAUI8gpPIwABAQAIAAUI8gpPIwABAQAAAA==.',['影歌']='影歌:BAAALAAECgcIBgAAAA==.',['往者']='往者已矣:BAABLAAFFH8GAAIRAAIImw6lbACSAAARAAIImw6lbACSAAAAAA==.',['御天']='御天敌:BAAALAAECgUICQAAAA==.',['徳古']='徳古拉:BAACLAAFFH8qAAIBAAcIvRdnCwDpAQABAAcIvRdnCwDpAQAsAAQKf0gAAgEACAgyJSQMAE4DAAEACAgyJSQMAE4DAAAA.',['德萨']='德萨司:BAABLAAFFH8KAAICAAII9w00XwBdAAACAAII9w00XwBdAAAAAA==.',['必出']='必出小红手:BAAALAAECgEIAQAAAA==.',['急速']='急速小淇:BAAALAADCgcIBwAAAA==.',['怪战']='怪战阿男:BAAALAAECgIIAgAAAA==.',['怪戦']='怪戦阿男:BAAALAAECgUIBQAAAA==.',['怪戰']='怪戰阿男:BAAALAAECgUIBgAAAA==.',['怪斬']='怪斬阿男:BAAALAAECgEIAQAAAA==.',['怪法']='怪法阿男:BAAALAAECgYIBgAAAA==.',['怪盗']='怪盗阿男:BAAALAADCgMIAwAAAA==.',['悠然']='悠然自德:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的辣椒:BAAALAADCggIEQAAAA==.',['我叫']='我叫一百六:BAAALAAECggICAAAAA==.',['我是']='我是最强奶龙:BAABLAAFFH8PAAISAAYI1BqvCgCqAQASAAYI1BqvCgCqAQAAAA==.',['戰乄']='戰乄不胜:BAAALAADCgMIAwAAAA==.',['手高']='手高八第下天:BAABLAAFFH8UAAIKAAYIwCGPGQDPAQAKAAYIwCGPGQDPAQABLAAFFAYIHAAIAA4cAA==.',['扑街']='扑街有蛇:BAABLAAFFH8IAAIRAAIItg2jigBBAAARAAIItg2jigBBAAAAAA==.',['打不']='打不过就打滚:BAAALAAECgYIDAAAAA==.',['扬手']='扬手春落手秋:BAAALAAECgYIBgAAAA==.',['把酒']='把酒问青天:BAAALAADCggICAAAAA==.',['折翼']='折翼:BAAALAAECgMIAwAAAA==.',['拈花']='拈花舞剑:BAAALAAECgYIDQAAAA==.拈花舞劎:BAAALAAECgUIBQAAAA==.拈花舞劒:BAAALAAECgYIBgAAAA==.',['拉贵']='拉贵尔昔拉:BAABLAAFFH8FAAIBAAMIzRQZQQCRAAABAAMIzRQZQQCRAAAAAA==.',['拯救']='拯救苍生:BAACLAAFFH8ZAAIaAAMI+Rg2DwCMAAAaAAMI+Rg2DwCMAAAsAAQKfyUAAhoACAiZGwEcABcCABoACAiZGwEcABcCAAAA.',['挽歌']='挽歌:BAAALAAECgYIDAAAAA==.',['排骨']='排骨大叔:BAACLAAFFH8IAAIKAAUInw1bMwC9AAAKAAUInw1bMwC9AAAsAAQKfxsAAwoACAhnGG2qAJwBAAoABwiRFm2qAJwBAB8ABwjxFohWAF4BAAAA.',['搜狐']='搜狐:BAACLAAFFH8iAAIDAAYIuiQWCgALAgADAAYIuiQWCgALAgAsAAQKfx4AAgMACAgmJHUUAPECAAMACAgmJHUUAPECAAAA.',['搞七']='搞七捻三:BAABLAAECn8gAAINAAYIsx/REQCpAQANAAYIsx/REQCpAQAAAA==.',['攬月']='攬月:BAAALAAECgQIBAAAAA==.',['敬业']='敬业的演员:BAABLAAECn8WAAMiAAgIfBXtFAD/AQAiAAgIExXtFAD/AQAjAAYIHAsWSAAnAQABLAAFFAgIMwAjAOQjAA==.',['断悦']='断悦愁:BAAALAAECgcIBwAAAA==.',['断罪']='断罪之翼:BAACLAAFFH8ZAAIUAAQIAyAqGQCHAQAUAAQIAyAqGQCHAQAsAAQKfxkAAxQABwgQJOMkAFwCABQABwgQJOMkAFwCAAYAAgj8G083AKcAAAAA.',['斯蘭']='斯蘭:BAABLAAECn8UAAIRAAYIqB6HfQD+AQARAAYIqB6HfQD+AQAAAA==.',['无光']='无光之赎:BAAALAAECgIIAgAAAA==.',['无声']='无声消退:BAAALAAECgYICAAAAA==.',['无敌']='无敌暴龙兽:BAABLAAFFH8bAAILAAUIeyKHCgDcAQALAAUIeyKHCgDcAQAAAA==.',['无量']='无量佛:BAAALAAECgYIBgAAAA==.',['旺旺']='旺旺大李包:BAABLAAFFH8GAAIRAAII5Q6/aQCTAAARAAII5Q6/aQCTAAAAAA==.',['昆山']='昆山:BAAALAADCgcIBwAAAA==.',['星喵']='星喵辰:BAAALAAECggICAAAAA==.',['星岚']='星岚幽梦:BAABLAAFFH8YAAIKAAUIxgaSWgDdAAAKAAUIxgaSWgDdAAAAAA==.',['星落']='星落汐河:BAAALAAECgYIBgAAAA==.',['春天']='春天里的小德:BAACLAAFFH8ZAAIIAAMIJA4eNQCVAAAIAAMIJA4eNQCVAAAsAAQKfyUAAggACAhAEGRrAFMBAAgACAhAEGRrAFMBAAAA.',['晨曦']='晨曦雨露:BAABLAAFFH8IAAIXAAIIDgROawA1AAAXAAIIDgROawA1AAAAAA==.',['普羅']='普羅德摩尔:BAAALAAFFAIIAgAAAA==.',['暗夜']='暗夜强叔:BAAALAAECgIIAwAAAA==.',['暮丶']='暮丶倾城:BAAALAAECgQIBQAAAA==.',['暮光']='暮光之宸:BAAALAAECgYIDQAAAA==.暮光之珵:BAAALAAECgUIBQAAAA==.',['暴躁']='暴躁的演员:BAABLAAECn8lAAMPAAgIbheZEADTAQAPAAgIbheZEADTAQAIAAYIkQgnnQDbAAAAAA==.',['書心']='書心墨韵:BAACLAAFFH8qAAIaAAUIhBeMCAAzAQAaAAUIhBeMCAAzAQAsAAQKfxoAAhoABggzC5RMAPwAABoABggzC5RMAPwAAAAA.',['月光']='月光杀神:BAAALAAECgYICAAAAA==.',['月影']='月影無雙:BAABLAAFFH8fAAIZAAYIfgqGEgAhAQAZAAYIfgqGEgAhAQAAAA==.月影神木:BAAALAAECgUIBgAAAA==.',['木野']='木野真琴:BAAALAADCgcIBwAAAA==.',['机电']='机电实物:BAAALAADCgEIAQAAAA==.',['极品']='极品狼王:BAABLAAFFH8JAAIKAAMIywbzhgBKAAAKAAMIywbzhgBKAAAAAA==.',['枪王']='枪王:BAAALAAECgMIAwAAAA==.',['柒夜']='柒夜小圣君:BAAALAAECgEIAQAAAA==.',['树士']='树士:BAAALAAECgQIBQAAAA==.',['梦遥']='梦遥:BAAALAAECggIDwAAAA==.',['楚天']='楚天歌:BAACLAAFFH8SAAIFAAUIWA1dNgAeAQAFAAUIWA1dNgAeAQAsAAQKfyQAAwUACAhqHOsfAK4BAAUACAiQG+sfAK4BAA0AAwisHGVlANwAAAAA.',['樱满']='樱满集:BAAALAAECgUICgAAAA==.',['欧萊']='欧萊雅:BAAALAAECgEIAQAAAA==.',['歐萊']='歐萊雅:BAAALAADCgYIBgAAAA==.',['死亡']='死亡之刺:BAAALAAECgQIAwAAAA==.死亡即是新生:BAACLAAFFH8+AAIhAAgIWRQRBQAAAgAhAAgIWRQRBQAAAgAsAAQKfxwAAyEACAhKHVEUABMCACEACAjQHFEUABMCABEAAgiwIZpZAa0AAAAA.',['残缺']='残缺依班娜:BAACLAAFFH8ZAAIJAAMIix46OAC0AAAJAAMIix46OAC0AAAsAAQKfyAAAgkACAjaHcwiANYBAAkACAjaHcwiANYBAAAA.',['毛毛']='毛毛虫的情:BAAALAAECgMIAwAAAA==.',['水之']='水之心圣:BAAALAAFFAIIAgAAAA==.',['水翦']='水翦影:BAAALAAECgYICgAAAA==.',['沉默']='沉默的守护者:BAAALAAECgYIBgAAAA==.',['沐浴']='沐浴圣光:BAAALAAECgMIAgAAAA==.',['没名']='没名气:BAACLAAFFH8KAAMIAAQI3grJNwCMAAAIAAMI9w3JNwCMAAAEAAEIugFzPwAlAAAsAAQKfx0AAggABgjREpA3AEEBAAgABgjREpA3AEEBAAAA.',['没想']='没想好叫什么:BAAALAAFFAIIBAAAAA==.',['没有']='没有过的曾经:BAAALAAECgYIBgAAAA==.',['法丝']='法丝真来斯:BAABLAAFFH8MAAMNAAYIkBrkAgDAAQANAAYIkBrkAgDAAQAFAAIITw2KUQBLAAAAAA==.',['法湿']='法湿:BAAALAAECgcIBwAAAA==.',['法神']='法神天使:BAAALAAECgYIBwAAAA==.',['流星']='流星之缘:BAABLAAFFH8hAAIhAAUIXg1VEADwAAAhAAUIXg1VEADwAAAAAA==.',['浊水']='浊水清尘:BAAALAAECggICgAAAA==.',['海空']='海空:BAAALAAECgUIBgAAAA==.',['海绵']='海绵宝宝:BAABLAAFFH8FAAMkAAIIhw9rDgCUAAAkAAIIhw9rDgCUAAAIAAII+w+LMgBvAAAAAA==.',['淘浆']='淘浆糊:BAACLAAFFH8ZAAMXAAMIrg6KSwCMAAAXAAMIBQ6KSwCMAAAYAAEILg+yKgBNAAAsAAQKfysAAxgACAiOHcMdABACABgABwjKHMMdABACABcABwhaGCksAKABAAAA.',['清泉']='清泉饮月:BAABLAAFFH8SAAMIAAUI2Ra8IQAPAQAIAAQIdRi8IQAPAQAEAAQIuQuEIAC4AAAAAA==.',['游学']='游学者翠花:BAAALAAECgIIAgAAAA==.游学者铁柱:BAAALAADCgIIAgAAAA==.',['湛蓝']='湛蓝天空:BAAALAAECgcIEQAAAA==.湛蓝色的苍穹:BAAALAAFFAIIBAAAAA==.湛蓝苍穹:BAABLAAFFH8HAAMaAAII3gqyHwAsAAABAAIIpAE+YwBpAAAaAAII3gqyHwAsAAAAAA==.',['溪魃']='溪魃:BAAALAAECgUIBQAAAA==.',['滑膛']='滑膛:BAAALAADCgEIAQAAAA==.',['滴滴']='滴滴打德:BAAALAAFFAIIAgAAAA==.',['瀘沽']='瀘沽寻梦:BAAALAADCgYIBgAAAA==.',['灰色']='灰色的魔女:BAABLAAFFH8MAAIFAAIIqxxoTgCSAAAFAAIIqxxoTgCSAAAAAA==.',['炒冰']='炒冰:BAABLAAFFH8HAAICAAIIIAWfawBUAAACAAIIIAWfawBUAAAAAA==.',['烈日']='烈日行者:BAAALAAECgYIBgAAAA==.',['焱霜']='焱霜:BAABLAAFFH8GAAIBAAYIfhZGBQAUAgABAAYIfhZGBQAUAgAAAA==.',['燃烧']='燃烧的烟圈:BAABLAAFFH8GAAIXAAIIHw9eYQA+AAAXAAIIHw9eYQA+AAAAAA==.',['爆雨']='爆雨小萨:BAAALAADCgEIAQAAAA==.',['爱唯']='爱唯一的你:BAAALAAECgYIBgAAAA==.',['爱情']='爱情海的港湾:BAAALAAFFAIIBAABLAAFFAgIAwAHAAAAAA==.',['牛至']='牛至猎杀者:BAAALAAECgIIAgAAAA==.',['犹豫']='犹豫就会败北:BAAALAAECgEIAQAAAA==.',['狂魔']='狂魔战狼:BAAALAAFFAYIAgABLAAFFAgIHAAEAOIkAA==.',['狼凤']='狼凤凰:BAAALAAFFAIIAgAAAA==.',['猪扒']='猪扒都喺肉:BAAALAAFFAIIAgAAAA==.',['猪肚']='猪肚鸡:BAAALAAECgYIBgAAAA==.',['猪肝']='猪肝香肠肉丝:BAAALAADCgYIBgAAAA==.',['玉山']='玉山:BAAALAADCgEIAQAAAA==.',['玉米']='玉米:BAAALAAFFAIIAgAAAA==.',['玉面']='玉面狐狸:BAAALAAECgYIEQABLAAFFAIIDgAUANkLAA==.',['玲珑']='玲珑渵:BAAALAAECgYIDAAAAA==.',['珠圆']='珠圆玉润:BAAALAAFFAQIBAAAAA==.',['瓦尔']='瓦尔基里丝:BAAALAADCgQIBAAAAA==.',['甘草']='甘草啵啵:BAABLAAFFH8GAAIKAAQITw/mYgCuAAAKAAQITw/mYgCuAAAAAA==.',['由月']='由月与地:BAACLAAFFH8RAAIYAAMIDB/jBgC8AAAYAAMIDB/jBgC8AAAsAAQKfxgABBgACAh9HXYTAF8CABgACAh9HXYTAF8CACUAAQjDFVcTAEYAABcAAQjaFKP/AD8AAAAA.',['电梯']='电梯征服者:BAAALAAECgIIAgAAAA==.',['疾风']='疾风英:BAAALAAFFAIIAgAAAA==.',['白日']='白日梦:BAABLAAECn8ZAAICAAcIwAha4gDMAAACAAcIwAha4gDMAAAAAA==.',['百倍']='百倍速的污:BAAALAAECgUIBwAAAA==.',['看我']='看我眼里有光:BAAALAAECgYIBgABLAAFFAgIBgAJANcaAA==.',['石斛']='石斛兰:BAAALAAECgEIAQAAAA==.',['硬功']='硬功夫吃软饭:BAABLAAFFH8GAAITAAYI7QmUFAAZAQATAAYI7QmUFAAZAQAAAA==.',['神劍']='神劍御雷真訣:BAAALAAECgYIBgAAAA==.',['神域']='神域精灵:BAAALAAECgYIBgAAAA==.',['神奇']='神奇且狐狸:BAAALAAECgYIBgAAAA==.',['秋水']='秋水落霞:BAAALAAFFAIIAgAAAA==.',['筑梦']='筑梦之羽:BAABLAAFFH8GAAIWAAYI3ADYYgArAAAWAAYI3ADYYgArAAAAAA==.',['糟老']='糟老头子:BAABLAAFFH8MAAICAAIIiA4ZXwBdAAACAAIIiA4ZXwBdAAAAAA==.',['紫玉']='紫玉玲珑:BAABLAAFFH8hAAIbAAUI4AoACQDKAAAbAAUI4AoACQDKAAAAAA==.',['紫色']='紫色棒棒糖:BAABLAAFFH8GAAIFAAYIXQ9ILQBYAQAFAAYIXQ9ILQBYAQAAAA==.紫色舞蹈生:BAAALAAFFAIIBAAAAA==.紫色艺术生:BAABLAAFFH8RAAMXAAUIQx9YLgBgAQAXAAUIQx9YLgBgAQAYAAEIgxuRHQAAAAAAAA==.',['紫陌']='紫陌琴韵:BAABLAAFFH8PAAMNAAIIbwHgIQAaAAAFAAII+AAYbAAaAAANAAIIbwHgIQAaAAAAAA==.',['緣語']='緣語軒:BAABLAAFFH8MAAMmAAIIhwTPBwA9AAAmAAIIhwTPBwA9AAAUAAIImgBuTwA6AAAAAA==.',['红烧']='红烧牛肉:BAABLAAFFH8PAAICAAMI1hSIPQCuAAACAAMI1hSIPQCuAAAAAA==.',['纯属']='纯属虚构:BAAALAAECgcIEAAAAA==.',['纳格']='纳格兰的风:BAABLAAECn8mAAITAAgI6RgEIQAtAgATAAgI6RgEIQAtAgAAAA==.',['给我']='给我奶住:BAAALAADCggICAAAAA==.',['绯想']='绯想之剑:BAAALAAFFAIIAgAAAA==.',['绿之']='绿之法皇:BAABLAAFFH8HAAMZAAIIjRWPEwCGAAAZAAIIjRWPEwCGAAAdAAIIMxAiFQBvAAAAAA==.',['绿色']='绿色练习生:BAAALAAECgYIBgAAAA==.',['绿豆']='绿豆苍蝇:BAABLAAFFH8FAAMSAAMI8R4hDwC6AAASAAII1R4hDwC6AAAMAAMIOBWIFwCDAAAAAA==.',['缚天']='缚天:BAAALAAECgQIBQAAAA==.',['羊肉']='羊肉藏在书里:BAACLAAFFH8KAAIcAAIIPgvpFgBDAAAcAAIIPgvpFgBDAAAsAAQKfxUAAhwABgjyGj8kAN4BABwABgjyGj8kAN4BAAAA.',['美影']='美影如丝:BAAALAADCgIIAgAAAA==.',['翱翱']='翱翱:BAAALAAECgYIDQAAAA==.',['老板']='老板栗:BAAALAAECgYIBgAAAA==.',['耂王']='耂王:BAAALAAECgYICwAAAA==.耂王你很烧:BAAALAAECgUIBQAAAA==.耂王爱你哦:BAAALAAFFAIIAgAAAA==.',['耳熜']='耳熜:BAABLAAFFH8GAAIKAAYIwRr7JwCTAQAKAAYIwRr7JwCTAQAAAA==.',['聚散']='聚散如沙:BAAALAAECgQIBAAAAA==.',['肉烧']='肉烧饼:BAAALAAFFAIIAgAAAA==.',['股神']='股神左安龙:BAAALAAFFAIIBAAAAA==.',['肥牛']='肥牛牛:BAAALAAECgcIBwAAAA==.',['胖胖']='胖胖小欢子:BAAALAAECgQIBAAAAA==.',['胤蓝']='胤蓝:BAAALAAECggICAABLAAFFAgICAARAJUYAA==.',['臭桂']='臭桂鱼:BAAALAAECgYIBgAAAA==.',['至始']='至始至终:BAAALAAFFAIIBAAAAA==.',['致命']='致命呼吸:BAABLAAFFH8RAAIRAAUIThmsNQBlAQARAAUIThmsNQBlAQAAAA==.',['舟舟']='舟舟:BAAALAAFFAEIAQAAAA==.',['色丨']='色丨色:BAABLAAFFH8GAAIYAAIIPQTpHQB8AAAYAAIIPQTpHQB8AAAAAA==.',['色射']='色射:BAAALAADCgYIBgAAAA==.',['艳阳']='艳阳天:BAAALAAFFAIIAgAAAA==.',['芈苏']='芈苏:BAAALAAECgYIBwAAAA==.',['花小']='花小满:BAABLAAFFH8SAAIXAAUIygV/QADvAAAXAAUIygV/QADvAAAAAA==.',['茉莉']='茉莉清茶:BAAALAADCgEIAQAAAA==.',['荫垠']='荫垠隐印引吟:BAAALAAFFAIIAgAAAA==.',['荷尔']='荷尔荷斯:BAABLAAFFH8HAAIKAAUISxhbSQAmAQAKAAUISxhbSQAmAQAAAA==.',['莫失']='莫失莫忘:BAAALAAECggIDAAAAA==.',['菊花']='菊花毁灭者:BAACLAAFFH8WAAMRAAUIORuLPABJAQARAAUIORuLPABJAQAQAAII4hiQEACXAAAsAAQKfx0AAxEACAgEI10NAIUCABEACAgEI10NAIUCABAABggAHR8iAKoBAAAA.',['菲拉']='菲拉斯:BAAALAAECgYIAwAAAA==.',['萝莉']='萝莉一枚:BAAALAAECgYIBgAAAA==.',['萨幔']='萨幔:BAABLAAFFH8QAAMCAAUI1AVrNwDFAAACAAUI1AVrNwDFAAADAAEI0QGwUwApAAAAAA==.',['萨拉']='萨拉迈恩:BAABLAAFFH8XAAIRAAUInhnpPABHAQARAAUInhnpPABHAQAAAA==.',['萨神']='萨神:BAABLAAFFH8GAAIDAAMITA3JNwB8AAADAAMITA3JNwB8AAAAAA==.',['萨耳']='萨耳:BAAALAAECgEIAQAAAA==.',['蓝瘦']='蓝瘦香菇:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色体育生:BAABLAAFFH8XAAIDAAYICyNrCwD1AQADAAYICyNrCwD1AQAAAA==.',['蓝霆']='蓝霆:BAAALAAECggICAAAAA==.',['蓝鳯']='蓝鳯凰:BAAALAAECgYICAAAAA==.',['蓝鳳']='蓝鳳凰:BAAALAAFFAIIBAAAAA==.',['薄荷']='薄荷芋头:BAAALAAFFAIIBAAAAA==.',['虹爷']='虹爷:BAAALAAECgYIEAAAAA==.',['蛋总']='蛋总下凡:BAAALAADCgEIAQAAAA==.',['血苍']='血苍穹:BAAALAAECgYIBgAAAA==.',['被風']='被風熄滅:BAABLAAFFH8cAAMIAAYIDhx7DQDjAQAIAAYIDhx7DQDjAQAEAAUIRBkcFQA4AQAAAA==.',['西红']='西红柿鸡蛋面:BAAALAAECgEIAQAAAA==.',['识濑']='识濑就濑條界:BAABLAAFFH8LAAIKAAMI3hHqcAB/AAAKAAMI3hHqcAB/AAAAAA==.',['谪世']='谪世黯天使:BAAALAAECgYIDAAAAA==.',['豆瓣']='豆瓣酱泡饭:BAAALAAFFAIIBAABLAAFFAIIDgAUANkLAA==.',['贝璐']='贝璐酱:BAABLAAFFH8bAAMLAAUIBiJtCQDwAQALAAUIBiJtCQDwAQABAAMIWA6TQQCQAAAAAA==.',['赞美']='赞美圣光吧:BAABLAAFFH8PAAIjAAMI5hC0FACdAAAjAAMI5hC0FACdAAAAAA==.',['赵无']='赵无眠:BAABLAAECn8YAAICAAgIcBX3VADlAQACAAgIcBX3VADlAQAAAA==.',['轰贰']='轰贰零:BAAALAAFFAIIBAAAAA==.',['迟到']='迟到的幸福:BAAALAAFFAIIAgAAAA==.',['迪皮']='迪皮诶斯:BAAALAAFFAIIAgAAAA==.',['逐日']='逐日神话:BAAALAAFFAIIAgAAAA==.',['邊渡']='邊渡友次子:BAAALAAECgYIDAAAAA==.',['那壹']='那壹夜笑了:BAAALAAECggICAAAAA==.',['邪恶']='邪恶小刀:BAAALAAECgEIAQAAAA==.',['醉酒']='醉酒鞭名马:BAAALAAECgYICQAAAA==.',['锦鲤']='锦鲤杨超越:BAABLAAFFH8IAAINAAIIMQ18GAA/AAANAAIIMQ18GAA/AAAAAA==.',['阴影']='阴影之刺:BAAALAAFFAIIAgAAAA==.',['阿咔']='阿咔莎:BAACLAAFFH8aAAIUAAUIFRGSJAAYAQAUAAUIFRGSJAAYAQAsAAQKfyEAAhQACAhCGesoAEUCABQACAhCGesoAEUCAAAA.',['阿尓']='阿尓托莉雅:BAACLAAFFH8UAAIaAAUIKBaWCQAaAQAaAAUIKBaWCQAaAQAsAAQKfy8AAxoACAgvGDUnAMgBABoABwi3GTUnAMgBAAEAAQh5DcaCAToAAAAA.',['阿尔']='阿尔忒米斯:BAACLAAFFH8ZAAIGAAMI0hItHwCPAAAGAAMI0hItHwCPAAAsAAQKfyEAAgYACAjiF7c4AN4BAAYACAjiF7c4AN4BAAAA.阿尔法:BAAALAAFFAIIAgAAAA==.',['阿布']='阿布罗狄:BAAALAAECgYIEAAAAA==.',['阿菠']='阿菠萝莅临:BAAALAAECgEIAQAAAA==.',['陌人']='陌人不故丶:BAAALAAECgEIAQAAAA==.',['隐匿']='隐匿之眼:BAAALAAECgYICQAAAA==.',['难嚼']='难嚼:BAABLAAECn8XAAMXAAcI2RY8cQCjAQAXAAYI9hg8cQCjAQAlAAMIDgs4JwCvAAAAAA==.',['雪河']='雪河:BAAALAAECgYIBgAAAA==.',['雪離']='雪離:BAAALAAECggICAAAAA==.',['零度']='零度:BAAALAAFFAIIBAAAAA==.',['雷鸣']='雷鸣八卦:BAACLAAFFH8HAAICAAIIMxGCWwBkAAACAAIIMxGCWwBkAAAsAAQKfy0AAgIACAhvG9sbABUCAAIACAhvG9sbABUCAAAA.',['霎时']='霎时花再开:BAABLAAFFH8NAAMIAAUIcQ5pLwCtAAAIAAMIVhFpLwCtAAAEAAUI0QyMIQCqAAAAAA==.',['霜冷']='霜冷九洲:BAABLAAECn8eAAMGAAgIVw26RgCdAQAGAAgIVw26RgCdAQAUAAYINw+mawA4AQAAAA==.',['露西']='露西法:BAAALAAECgEIAQAAAA==.',['露露']='露露姆:BAAALAAECgIIAgAAAA==.',['静缘']='静缘文随:BAAALAAECgYICwAAAA==.',['韩立']='韩立:BAABLAAFFH8IAAIRAAIIOQ7PcwCOAAARAAIIOQ7PcwCOAAAAAA==.',['韭菜']='韭菜馃:BAAALAAECgQIBAAAAA==.',['飄渺']='飄渺無踪:BAABLAAFFH8NAAICAAQIiAi8QACkAAACAAQIiAi8QACkAAABLAAFFAUIIQAbAOAKAA==.',['风中']='风中烛影:BAABLAAFFH8GAAIKAAIIABG8igBIAAAKAAIIABG8igBIAAAAAA==.',['风定']='风定落花香:BAAALAAECgYIBgAAAA==.',['风青']='风青扬:BAAALAAECgUIBQAAAA==.',['飞翔']='飞翔的小麻雀:BAABLAAFFH8GAAIKAAIIygKyvAArAAAKAAIIygKyvAArAAAAAA==.',['魂梦']='魂梦:BAAALAAECgEIAQAAAA==.',['魅影']='魅影依馨儿:BAAALAAFFAIIBAAAAA==.',['魔兽']='魔兽世界:BAABLAAFFH8GAAIFAAYI/gctMwAzAQAFAAYI/gctMwAzAQAAAA==.魔兽怕怕:BAAALAAECgMIAwAAAA==.',['魔延']='魔延:BAAALAAECgYIBgAAAA==.',['魔王']='魔王:BAABLAAFFH8SAAIJAAYIrBf3GQCgAQAJAAYIrBf3GQCgAQAAAA==.',['魔言']='魔言:BAAALAAECgEIAQAAAA==.',['魔鬼']='魔鬼咬巫婆:BAACLAAFFH8OAAIUAAII2QuBQABpAAAUAAII2QuBQABpAAAsAAQKfzEAAhQACAgPF945APMBABQACAgPF945APMBAAAA.魔鬼筋肉人:BAAALAAECgQIBAAAAA==.',['鮮紅']='鮮紅的漢庫克:BAACLAAFFH8GAAIFAAII5QQBaABVAAAFAAII5QQBaABVAAAsAAQKfxQAAgUABgjIDZ4+ABEBAAUABgjIDZ4+ABEBAAAA.',['鱼与']='鱼与熊掌:BAAALAAECgQICwAAAA==.',['鲜红']='鲜红的汉库克:BAACLAAFFH8HAAIJAAIInQnBYwA8AAAJAAIInQnBYwA8AAAsAAQKfxgAAgkABwjkF9lrAO8BAAkABwjkF9lrAO8BAAAA.',['鹤望']='鹤望兰丶:BAAALAADCgYIBgAAAA==.',['鹿力']='鹿力大仙:BAAALAAECgYICAAAAA==.',['麦唛']='麦唛:BAAALAAFFAIIAwAAAA==.',['麻酥']='麻酥糖:BAAALAADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end