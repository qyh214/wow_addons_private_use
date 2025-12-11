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
 local lookup = {'Druid-Restoration','Druid-Balance','Mage-Arcane','Paladin-Retribution','Druid-Guardian','Hunter-BeastMastery','DemonHunter-Vengeance','Unknown-Unknown','DemonHunter-Havoc','Mage-Fire','Mage-Frost','Shaman-Elemental','Warlock-Destruction','Priest-Holy','Shaman-Restoration','Monk-Mistweaver','Monk-Windwalker','Priest-Shadow','Rogue-Assassination','Paladin-Protection','Evoker-Devastation','Evoker-Preservation','Rogue-Subtlety','Monk-Brewmaster','Hunter-Marksmanship','Warlock-Demonology','Warrior-Fury','DeathKnight-Frost','Priest-Discipline','Warlock-Affliction','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection',}; local provider = {region='CN',realm='羽月',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Addoil:BAAALAADCgYIBgAAAA==.',Ap='Apoll:BAAALAAFFAIIAgAAAA==.',Aq='Aqua:BAAALAAECgUIBQAAAA==.',Ar='Artemisdw:BAABLAAFFH8QAAMBAAYIigniNACWAAABAAMIsxLiNACWAAACAAMIQAD6KQBiAAAAAA==.',Ba='Balbeleet:BAAALAAECgYIBgAAAA==.Basara:BAAALAAFFAIIAgAAAA==.',Bl='Blindlegend:BAAALAAECgYIEQAAAA==.',Cd='Cdx:BAAALAAECgUIBQAAAA==.',Cr='Crazyseven:BAABLAAFFH8GAAIDAAYIHCHLAwBrAgADAAYIHCHLAwBrAgAAAA==.',Do='Donk:BAACLAAFFH8bAAIDAAYIpgyILABcAQADAAYIpgyILABcAQAsAAQKfxgAAgMABgjIHgZQABUCAAMABgjIHgZQABUCAAEsAAUUBggkAAQAQyYA.',Eg='Egoist:BAAALAAECggICAAAAA==.',El='Ella:BAAALAAECgYIDwAAAA==.',En='Enjoy:BAABLAAECn8UAAMBAAYIMglNVADEAAABAAYIMglNVADEAAAFAAQI7ApOLACeAAAAAA==.',It='Itsgodlike:BAABLAAFFH8LAAIGAAMI0BdLaQCRAAAGAAMI0BdLaQCRAAAAAA==.',Ka='Kakarot:BAAALAAECgYIBgAAAA==.Kaladz:BAAALAAECgYIDwAAAA==.Karina:BAAALAADCgcIBwAAAA==.',Kl='Klmss:BAAALAAECgYIDQABLAAFFAQIEAAHALwOAA==.',Kr='Krane:BAAALAAECgcICAAAAA==.',Kt='Ktsheeran:BAABLAAFFH8QAAIGAAQIuRvmVQD2AAAGAAQIuRvmVQD2AAAAAA==.',La='Latoureiffel:BAAALAAECgYIBgAAAA==.',Li='Littlelight:BAAALAAECgMIBQAAAA==.',Lo='Loktarr:BAAALAADCgIIAgAAAA==.',Ma='Mareeta:BAAALAAECggIBgAAAA==.Maybach:BAAALAAECgcIBwAAAA==.',Mi='Miamia:BAAALAADCggICAABLAAFFAIIBAAIAAAAAA==.Miinjure:BAAALAAECggICAAAAA==.Mikatsuki:BAAALAAECggICAAAAA==.Mirrid:BAABLAAFFH8KAAIBAAYIMxBAGABvAQABAAYIMxBAGABvAQAAAA==.',Mo='Moonwish:BAAALAAECgIIAgAAAA==.Mortarione:BAAALAADCgEIAQAAAA==.',Ne='Negotron:BAAALAADCgMIAwAAAA==.Neil:BAABLAAFFH8FAAIJAAUIAxjRLQAqAQAJAAUIAxjRLQAqAQAAAA==.',Nu='Nuus:BAAALAADCgcIBwAAAA==.',Oy='Oyzh:BAABLAAFFH8PAAIGAAYIaxFnNwBhAQAGAAYIaxFnNwBhAQAAAA==.',Pe='Persephoney:BAAALAADCgUIBQAAAA==.',Pl='Pluto:BAAALAAECgYIDAAAAA==.',Pr='Prometheus:BAACLAAFFH8aAAMKAAYIHBzTAQBLAQAKAAYIiRvTAQBLAQADAAIISRJLVQBGAAAsAAQKfyEABAoACAhrHxQGACoCAAoACAiJHRQGACoCAAsABghGG7orANIBAAMABwj9E6GGAIIBAAAA.',Pu='Puzzle:BAABLAAFFH8KAAIMAAUIgiDdHgBKAQAMAAUIgiDdHgBKAQAAAA==.',Re='Redbean:BAAALAAFFAIIBAAAAA==.',Ro='Rosicky:BAACLAAFFH8PAAINAAQIdRMuQgDcAAANAAQIdRMuQgDcAAAsAAQKfxUAAg0ACAhHHyYOAH0CAA0ACAhHHyYOAH0CAAAA.',Se='Serein:BAAALAAFFAIIAgAAAA==.',Sn='Snowy:BAABLAAFFH8bAAIOAAYIQBr3DQDzAQAOAAYIQBr3DQDzAQAAAA==.',St='Stelle:BAAALAAECgYICAAAAA==.',Ta='Tali:BAAALAADCgYIBgAAAA==.',Th='Thierry:BAACLAAFFH8eAAMPAAUIDR7ZFgCoAQAPAAUIDR7ZFgCoAQAMAAQIQwhULwC3AAAsAAQKfzMAAw8ACAgLIAYJAMkCAA8ACAgLIAYJAMkCAAwABwhzFUlPAMwBAAEsAAUUCAgFAA4AsB8A.',Ys='Ysasuka:BAAALAAECgYIEwAAAA==.',Yu='Yushar:BAAALAADCgIIAgAAAA==.',Za='Zahzy:BAACLAAFFH8QAAIJAAgI5SCMBACeAgAJAAgI5SCMBACeAgAsAAQKfxkAAgkABghLGeI+AGEBAAkABghLGeI+AGEBAAAA.Zakty:BAACLAAFFH8OAAIQAAIIWR5fDgCoAAAQAAIIWR5fDgCoAAAsAAQKfygAAxAABgisJNAPAG4CABAABgisJNAPAG4CABEAAwhHGGUjANwAAAAA.Zarr:BAABLAAFFH8IAAIDAAII2hZRSgCWAAADAAII2hZRSgCWAAAAAA==.',Zo='Zonl:BAACLAAFFH84AAIGAAcIyyD1CQBDAgAGAAcIyyD1CQBDAgAsAAQKfxUAAgYACAgPHyI8ANcBAAYACAgPHyI8ANcBAAAA.',Zx='Zxlcmj:BAAALAADCgIIAgAAAA==.',['一只']='一只可爱熊猫:BAAALAAECgYIBgAAAA==.',['一喝']='一喝就喝高:BAABLAAFFH8FAAICAAUIpxK3CACtAQACAAUIpxK3CACtAQAAAA==.',['一箭']='一箭追月:BAAALAAECgIIAgAAAA==.',['一色']='一色若葉:BAAALAAECgcIBwAAAA==.',['三分']='三分钟灬温暖:BAAALAAECgYIBgAAAA==.',['三指']='三指弹天:BAABLAAFFH8MAAIDAAQIBANpMADKAAADAAQIBANpMADKAAAAAA==.',['三花']='三花聚鼎:BAAALAAECgYIBgAAAA==.',['三角']='三角初音:BAAALAAECgYICgAAAA==.',['上善']='上善渃水:BAAALAADCgYIDQAAAA==.',['上弦']='上弦月:BAAALAAECgYICQAAAA==.',['上来']='上来别怕疼:BAAALAADCgcIBwAAAA==.',['下狼']='下狼:BAAALAAFFAEIAQAAAA==.',['不及']='不及她可爱:BAAALAAECgYIBgAAAA==.',['不可']='不可撼动:BAAALAAECgYIBgAAAA==.',['不好']='不好点长肥了:BAAALAAFFAIIAgABLAAFFAgIBgAEAMsRAA==.',['专属']='专属妳的温柔:BAAALAAECgYIEAAAAA==.',['且看']='且看云舒:BAAALAAECgYIBgAAAA==.',['东方']='东方树叶:BAAALAAFFAIIAgAAAA==.',['两袖']='两袖青蛇:BAAALAAFFAMIAwAAAA==.',['丨深']='丨深海巨鳗丨:BAAALAAECgYIDAAAAA==.',['丨紫']='丨紫丶小囡:BAACLAAFFH8FAAIGAAMIDR1LZACmAAAGAAMIDR1LZACmAAAsAAQKfxUAAgYABgj4IvExAPYBAAYABgj4IvExAPYBAAAA.丨紫丶小薇:BAABLAAFFH8HAAILAAII0Qx1GQA9AAALAAII0Qx1GQA9AAAAAA==.',['临云']='临云:BAAALAADCgMIAwAAAA==.',['丶小']='丶小七:BAAALAAECgIIAgAAAA==.',['丶琉']='丶琉璃:BAAALAAFFAIIBAAAAA==.',['乌蝇']='乌蝇哥:BAAALAAECgYIBwAAAA==.',['乐无']='乐无丶忧:BAAALAAECgEIAQAAAA==.乐无忧:BAAALAADCgIIAgAAAA==.',['乔乔']='乔乔:BAAALAAECgYICgAAAA==.',['九块']='九块九:BAAALAADCgYICAAAAA==.',['九曦']='九曦:BAABLAAFFH8GAAISAAIIfAt8IgCHAAASAAIIfAt8IgCHAAAAAA==.',['云思']='云思:BAAALAADCgMIAwAAAA==.',['云雀']='云雀丶:BAAALAAFFAIIAgAAAA==.',['五條']='五條悟:BAAALAAECgYIDAAAAA==.',['人间']='人间油物:BAAALAAECgIIAgABLAAECggICwAIAAAAAA==.',['人鱼']='人鱼:BAAALAAECgYIBgAAAA==.',['伊人']='伊人娜:BAAALAAECgYICwAAAA==.',['伊堡']='伊堡神骑:BAAALAAECggICQAAAA==.',['伊瑞']='伊瑞尔丶:BAAALAAECgYIDAAAAA==.',['伊蕾']='伊蕾影歌:BAABLAAFFH8GAAIHAAIIoQ+XFQArAAAHAAIIoQ+XFQArAAAAAA==.',['伤懐']='伤懐:BAAALAAECgMIAwAAAA==.',['佐倉']='佐倉双葉:BAAALAAECgUIBAAAAA==.',['何当']='何当载酒来:BAACLAAFFH8fAAMJAAUIsBjJJwBTAQAJAAUIsBjJJwBTAQAHAAIIwAAOHAA7AAAsAAQKfxsAAwkABwiaHM5dAA4CAAkABgiGIM5dAA4CAAcABwi2A+VGAMQAAAAA.',['何處']='何處惹塵埃:BAAALAADCgcIBwAAAA==.',['你你']='你你我我他他:BAAALAAECgQICQAAAA==.',['你泛']='你泛起山川:BAABLAAFFH8MAAITAAYIFRyrBgC1AQATAAYIFRyrBgC1AQAAAA==.',['佽沅']='佽沅誶爿:BAAALAAECgIIAgAAAA==.',['信仰']='信仰之依滢:BAAALAAFFAMIAwAAAA==.',['信德']='信德维菈:BAAALAAECgYIBgAAAA==.',['倚剑']='倚剑秋:BAAALAADCgYIBgAAAA==.',['偷鱼']='偷鱼罐头的猫:BAABLAAFFH8JAAIBAAMI1gV9PAB9AAABAAMI1gV9PAB9AAAAAA==.',['元素']='元素之歌:BAAALAAECgYICAAAAA==.元素烈焰:BAABLAAFFH8NAAIPAAMIqwOXWgBmAAAPAAMIqwOXWgBmAAAAAA==.',['光与']='光与影之诗:BAAALAAECgYIBgAAAA==.',['光中']='光中之影:BAABLAAFFH8GAAIOAAYIQBM1GgB+AQAOAAYIQBM1GgB+AQAAAA==.',['光之']='光之灵:BAAALAADCgQIBAAAAA==.',['光怪']='光怪陆离丶:BAABLAAECn8YAAIGAAYIwxiasgCRAQAGAAYIwxiasgCRAQAAAA==.',['光辉']='光辉圣骑:BAABLAAFFH8IAAMEAAIIihR0VQBMAAAEAAIIihR0VQBMAAAUAAIIHAjMIAAqAAAAAA==.',['光颜']='光颜:BAAALAADCgIIAgAAAA==.',['八月']='八月八月:BAAALAAECgYIBgAAAA==.',['八费']='八费四杠九:BAAALAAECgUIBQAAAA==.',['六月']='六月的橘子酱:BAAALAADCgEIAQAAAA==.',['再见']='再见卡门:BAAALAAECgMIAwAAAA==.',['农村']='农村副主任:BAAALAAECgEIAQAAAA==.',['冰封']='冰封祭:BAAALAADCgYIBgAAAA==.',['冰摇']='冰摇:BAAALAADCgUIBQAAAA==.冰摇马提尼:BAAALAADCgcICwAAAA==.',['冰河']='冰河之纪:BAAALAADCgcIDQAAAA==.冰河剑虎:BAAALAAFFAIIAgAAAA==.冰河永恒:BAAALAAECgMIBAAAAA==.',['冰法']='冰法残渣:BAAALAAECgIIAgAAAA==.',['冰美']='冰美女:BAAALAAECgYIBgAAAA==.',['冰蓝']='冰蓝悲忆:BAAALAAECgYIDwAAAA==.',['冰颦']='冰颦轩轩:BAAALAAECgcIBwAAAA==.',['冲钅']='冲钅叉叉:BAAALAAECgEIAQAAAA==.',['冷一']='冷一鸣:BAAALAAECgYIDAAAAA==.',['冷傲']='冷傲天:BAAALAADCgcIBwAAAA==.',['冷峯']='冷峯:BAAALAADCgIIAgAAAA==.',['冷萃']='冷萃:BAAALAAECgYIDAAAAA==.',['凡尔']='凡尔塞玫瑰:BAAALAAECgYIBgAAAA==.凡尔赛四叶草:BAAALAAECgMIAwAAAA==.',['凤凰']='凤凰浴火:BAAALAAECgEIAQAAAA==.',['凨凪']='凨凪風夙:BAACLAAFFH8IAAIEAAIIRBTIQwCbAAAEAAIIRBTIQwCbAAAsAAQKfxsAAgQACAgmIJ4wAK8CAAQACAgmIJ4wAK8CAAAA.',['凶狠']='凶狠的二咕父:BAAALAADCgUIBQAAAA==.',['凶郎']='凶郎:BAABLAAECn8ZAAIGAAYISR9yRwC4AQAGAAYISR9yRwC4AQAAAA==.',['刘青']='刘青云:BAABLAAFFH8IAAIBAAUImxMVHQA+AQABAAUImxMVHQA+AQAAAA==.',['别站']='别站冰箱上:BAAALAAECgYICQAAAA==.',['前尘']='前尘镜:BAABLAAFFH8IAAIJAAIInBMFTgBLAAAJAAIInBMFTgBLAAAAAA==.',['剑履']='剑履上殿:BAABLAAFFH8GAAMVAAYImA1IDAAuAQAVAAQIQxFIDAAuAQAWAAII3xWwEQCaAAAAAA==.',['加诺']='加诺一代:BAAALAAECgYICgAAAA==.加诺德斯:BAAALAAECgYICwAAAA==.加诺德萨:BAAALAAECgYIDAAAAA==.加诺魁刚:BAAALAAECgYIBgAAAA==.',['动物']='动物园丶园长:BAAALAAECgQIBAABLAAFFAMIAwAIAAAAAA==.',['勇敢']='勇敢犇犇:BAAALAAECgYICAAAAA==.勇敢的咕咕:BAAALAAECgYIBgAAAA==.',['北北']='北北:BAABLAAFFH8OAAIGAAUI5BEzTwARAQAGAAUI5BEzTwARAQAAAA==.',['十一']='十一月:BAAALAAECgYIBgAAAA==.',['千帆']='千帆舞影:BAACLAAFFH8PAAIOAAUI8BiDGwBzAQAOAAUI8BiDGwBzAQAsAAQKfxYAAg4ABghCHbM+AN4BAA4ABghCHbM+AN4BAAAA.',['千月']='千月:BAAALAADCgMIAwAAAA==.',['半只']='半只鸡:BAAALAAECgYICwAAAA==.',['南京']='南京龙:BAAALAAECggICwAAAA==.',['博娅']='博娅:BAAALAADCgQIBgAAAA==.',['卜拉']='卜拉怪:BAAALAAECgYIBgAAAA==.',['卜萝']='卜萝:BAABLAAFFH8MAAMTAAYItR4CBwCuAQATAAYIKBgCBwCuAQAXAAIIPiGhEQBUAAAAAA==.',['卡珊']='卡珊拉:BAABLAAFFH8GAAMFAAIIZhkeDAA5AAAFAAIIZhkeDAA5AAABAAEIdwJdYQAeAAAAAA==.',['卡米']='卡米奇亚:BAAALAAFFAMIAQAAAA==.',['双手']='双手插兜儿:BAABLAAFFH8LAAMLAAIICxbuFgBBAAADAAIIJg7ETgBQAAALAAIIUBTuFgBBAAAAAA==.',['双轴']='双轴加载:BAAALAAECgYIBgAAAA==.',['发财']='发财:BAABLAAFFH8MAAITAAYIfQmECwBWAQATAAYIfQmECwBWAQAAAA==.',['叠最']='叠最厚的甲:BAAALAAECgIIAgAAAA==.',['古城']='古城旧梦:BAAALAADCgEIAQAAAA==.',['古天']='古天乐:BAAALAAECgIIAwAAAA==.',['只会']='只会拉链子:BAAALAAFFAIIBAAAAA==.',['只因']='只因览胜探奇:BAAALAAECgEIAQAAAA==.',['可乐']='可乐公爵:BAAALAADCgQIBAAAAA==.',['可以']='可以吗:BAABLAAFFH8FAAMOAAQIpQxWHQDNAAAOAAMIhAlWHQDNAAASAAEIBSXwJwBvAAAAAA==.',['叶梓']='叶梓易:BAAALAAECgYIBgAAAA==.',['叶绿']='叶绿素:BAAALAAECgYICQABLAAECggICwAIAAAAAA==.',['吉村']='吉村车钛:BAABLAAFFH8SAAINAAUItwnuPgD/AAANAAUItwnuPgD/AAAAAA==.',['同音']='同音:BAACLAAFFH8GAAIBAAYI5AAtVgBHAAABAAYI5AAtVgBHAAAsAAQKfxoAAwEABwgcE34yAF0BAAEABggFFH4yAF0BAAIABwjJCQY0APIAAAAA.',['名茶']='名茶:BAAALAADCgMIBAAAAA==.',['君向']='君向潇湘:BAAALAAECgQIBgAAAA==.',['呈影']='呈影:BAAALAAECgYIDAAAAA==.',['呜喵']='呜喵王:BAAALAAECgQIBAAAAA==.',['命运']='命运的枷锁:BAAALAAECgUIBgAAAA==.',['和风']='和风细雨:BAACLAAFFH8YAAIEAAcIvhqgBwAPAgAEAAcIvhqgBwAPAgAsAAQKfxYAAgQACAhJJEITAHMCAAQACAhJJEITAHMCAAAA.',['哀嚎']='哀嚎:BAAALAAECgEIAQAAAA==.',['哈莉']='哈莉奎因丶:BAAALAAFFAIIBAAAAA==.',['哈里']='哈里斯:BAAALAADCgQIBAAAAA==.',['哔哩']='哔哩哔哩丶战:BAAALAAECgMIAwAAAA==.',['喜欢']='喜欢你让我哭:BAABLAAFFH8MAAITAAYIJhYOCACZAQATAAYIJhYOCACZAQAAAA==.',['嘟嘟']='嘟嘟米米:BAAALAAECggICQAAAA==.',['嘟小']='嘟小牧:BAAALAAECgYIBgABLAAFFAgIMQAOAHUiAA==.',['嘿妹']='嘿妹:BAAALAAFFAIIAgAAAA==.',['四季']='四季发财:BAAALAAECgEIAQAAAA==.',['圆溜']='圆溜溜爹弟:BAAALAADCgQIBAAAAA==.',['土豆']='土豆超人:BAAALAAFFAMIAwAAAA==.',['圣光']='圣光余辉:BAAALAAECgMIAwAAAA==.圣光大呆瓜:BAAALAAECgYIBgAAAA==.圣光永不灭:BAABLAAECn8jAAIEAAYIeRwlSQCBAQAEAAYIeRwlSQCBAQAAAA==.圣光的萌妹子:BAAALAAECgYIBgAAAA==.',['圣殿']='圣殿:BAAALAAECgYICwAAAA==.',['圣灵']='圣灵天怒:BAAALAAECgYIDgAAAA==.',['在冬']='在冬天死去:BAABLAAFFH8IAAITAAYI/huNBgC4AQATAAYI/huNBgC4AQAAAA==.',['在魅']='在魅边:BAAALAAECgYICgAAAA==.',['塞恩']='塞恩希尔:BAAALAAECgYICQAAAA==.',['墨兰']='墨兰德:BAAALAAECgYIBgAAAA==.',['墨心']='墨心掌柜:BAAALAAECgEIAgAAAA==.墨心灬小心肝:BAAALAAECgYIBgAAAA==.',['墨殇']='墨殇丶:BAAALAAECgIIAgAAAA==.',['墩儿']='墩儿喵喵:BAABLAAFFH8GAAMBAAMILhYnKQDPAAABAAMILhYnKQDPAAACAAII8gx9OwAxAAAAAA==.',['壮壮']='壮壮不打大米:BAAALAAECgIIAgAAAA==.',['壹月']='壹月:BAAALAAECgUIBQAAAA==.',['壹頁']='壹頁书:BAABLAAFFH8aAAILAAUIHBa0BwAkAQALAAUIHBa0BwAkAQAAAA==.',['夏夜']='夏夜清风:BAAALAAFFAIIAgAAAA==.',['夏月']='夏月戴勒琳:BAABLAAFFH8SAAMXAAYIvR+HBADFAQAXAAYIvR+HBADFAQATAAYIoQaEDQA1AQAAAA==.',['夏莉']='夏莉欧:BAABLAAFFH8cAAMXAAYIOiVOAwD+AQAXAAYI8yJOAwD+AQATAAYIeSNvBADyAQABLAAFFAcISAATADMmAA==.',['夕阳']='夕阳昔阳:BAAALAAECgYIDgAAAA==.夕阳西风:BAAALAAECgYIBgAAAA==.',['夕颜']='夕颜葬:BAAALAADCgUIBQAAAA==.',['夜与']='夜与梦:BAAALAAECgMIAwAAAA==.',['夜之']='夜之伤:BAAALAADCgQIBAAAAA==.夜之暗巫:BAAALAAECgQIBwAAAA==.夜之语:BAAALAAFFAIIBAAAAA==.夜之飘舞:BAAALAAECgQIBAAAAA==.',['夜曦']='夜曦如梦:BAAALAAECgYIBgAAAA==.',['夜色']='夜色无涯丶:BAABLAAFFH8FAAIYAAUI/QI4FwC0AAAYAAUI/QI4FwC0AAAAAA==.',['夜魇']='夜魇骑士:BAAALAAECgQIBQAAAA==.',['大主']='大主教伊瑞尔:BAAALAAECgYIBAAAAA==.',['大地']='大地母亲:BAAALAAECgIIAgAAAA==.',['大夫']='大夫:BAAALAAECgYIBgAAAA==.',['大宅']='大宅一子:BAAALAAECgMIAwAAAA==.',['大掌']='大掌柜:BAACLAAFFH8OAAIEAAMIiQuCHQDfAAAEAAMIiQuCHQDfAAAsAAQKfxoAAgQACAi4GL0wAM8BAAQACAi4GL0wAM8BAAAA.',['大满']='大满贯:BAAALAAECgEIAQAAAA==.',['大灰']='大灰狼来啦:BAAALAAECgYICwAAAA==.',['大队']='大队长助理:BAAALAAFFAIIAgAAAA==.',['大雁']='大雁南飞:BAAALAAECgYICQABLAAECggICwAIAAAAAA==.',['大领']='大领主:BAAALAADCgMIAwAAAA==.',['大鷲']='大鷲伊迪丝:BAABLAAFFH8GAAIBAAII/xixKACIAAABAAII/xixKACIAAAAAA==.',['天堂']='天堂之声:BAAALAADCgIIAgAAAA==.天堂神光:BAAALAAFFAEIAQAAAA==.',['天真']='天真:BAAALAADCggICAAAAA==.',['天边']='天边的你:BAAALAAFFAEIAQAAAA==.',['太阳']='太阳神:BAABLAAECn8eAAMGAAYItx+KWAAsAgAGAAYIsx+KWAAsAgAZAAYIoxgURQChAQAAAA==.',['夹克']='夹克:BAAALAAECgYICwAAAA==.夹克大叔:BAAALAAECgMIAwAAAA==.',['奥村']='奥村春:BAAALAAECgQIBAAAAA==.',['奥能']='奥能术式:BAAALAAECgIIBAAAAA==.',['奶油']='奶油味牛肉饼:BAAALAAECgMIAwAAAA==.',['奶雪']='奶雪:BAAALAAECgMIAwAAAA==.',['妇科']='妇科手术大夫:BAACLAAFFH8TAAINAAUIixUAOQAoAQANAAUIixUAOQAoAQAsAAQKf0wAAg0ABghBJioWAC0CAA0ABghBJioWAC0CAAAA.',['妞牛']='妞牛纽拗:BAAALAAECgYICAAAAA==.',['妹岛']='妹岛和世:BAAALAAFFAIIAgAAAA==.',['姐姐']='姐姐:BAAALAAECgYIEQAAAA==.',['婉若']='婉若游龙:BAAALAAECgMIAwAAAA==.',['婕婕']='婕婕:BAAALAAECgIIAgAAAA==.',['季末']='季末春闱:BAAALAAECggICAAAAA==.',['孤儿']='孤儿:BAAALAAECgcIDQAAAA==.',['安杜']='安杜尼苏斯:BAAALAAECgIIAgAAAA==.',['安监']='安监科副科长:BAAALAAECgYIBgAAAA==.',['安迪']='安迪利奥:BAAALAAFFAYIBAAAAA==.',['完颜']='完颜兀术:BAABLAAECn8fAAIJAAgIbR2rMgCRAgAJAAgIbR2rMgCRAgAAAA==.',['宝宝']='宝宝虫:BAAALAAECgYIBwAAAA==.',['害人']='害人精猎手:BAAALAADCgMIAwAAAA==.',['寂寞']='寂寞灬宿命:BAAALAAFFAIIAgAAAA==.',['寒碧']='寒碧琦:BAAALAAFFAIIAgAAAA==.',['寒芒']='寒芒:BAAALAAECgYICgAAAA==.',['射个']='射个痛:BAAALAAECgYICAAAAA==.',['小不']='小不点清婵:BAAALAAFFAIIBAAAAA==.',['小加']='小加诺:BAABLAAECn8VAAMNAAYInxlhWQDzAAAaAAMIsBz1XQD/AAANAAUIDhRhWQDzAAAAAA==.',['小寶']='小寶貝:BAAALAAFFAIIAgAAAA==.',['小小']='小小的蚂蚁子:BAAALAAECgYIBgAAAA==.小小风儿:BAAALAAECgcIEAAAAA==.',['小恬']='小恬恬:BAABLAAECn8kAAIJAAcI8SBeOgB2AgAJAAcI8SBeOgB2AgAAAA==.',['小手']='小手乱揉:BAAALAAECgUIBQAAAA==.',['小林']='小林哥哥:BAAALAAECgYICQAAAA==.',['小爱']='小爱心:BAAALAAECggICAAAAA==.',['小牧']='小牧丶瓜:BAAALAAECgQIBAAAAA==.',['小琦']='小琦琦殿下:BAAALAAECgYIEQAAAA==.',['小甜']='小甜点:BAAALAAECgYIEAAAAA==.',['小米']='小米嘟嘟:BAAALAAECgYIDgAAAA==.小米豆豆:BAABLAAECn8WAAIGAAgInBVUzABvAQAGAAgInBVUzABvAQAAAA==.',['小蛋']='小蛋糕:BAABLAAFFH8GAAIGAAIIsgaBsgA1AAAGAAIIsgaBsgA1AAAAAA==.',['小西']='小西瓜丶怒风:BAACLAAFFH8KAAMJAAII8Q7HRQCVAAAJAAII8Q7HRQCVAAAHAAII6AXdGABTAAAsAAQKfxYAAwkABgiFGi9zAN8BAAkABgiFGi9zAN8BAAcABgjqCWVAAOMAAAAA.',['小龙']='小龙人高达:BAABLAAFFH8PAAMVAAYIwxqECACfAQAVAAYIwxqECACfAQAWAAEIzQbhIQAtAAABLAAFFAYIIQAOAPkYAA==.',['尤丽']='尤丽迪丝:BAAALAAECgcIEwAAAA==.',['山水']='山水不相逢:BAABLAAFFH8FAAMNAAII6w8RXQBCAAANAAII4goRXQBCAAAaAAEIshCyHwAAAAAAAA==.',['岛崎']='岛崎遥香:BAAALAAECgUIBQAAAA==.',['川上']='川上貞代:BAAALAAECgUIBQAAAA==.',['巴巴']='巴巴博一:BAAALAAFFAIIAgAAAA==.',['巷口']='巷口的那只猫:BAAALAAECgQIBAAAAA==.',['布布']='布布不可以:BAAALAADCgYIBwAAAA==.布布不拉稀:BAAALAAECgMIAwAAAA==.',['布衣']='布衣骑士:BAAALAAFFAEIAQAAAA==.',['帝三']='帝三只脚:BAAALAAECgEIAQAAAA==.',['帮你']='帮你打官司:BAAALAAFFAIIAgAAAA==.',['常夜']='常夜樱:BAAALAAFFAIIAwAAAA==.',['幕后']='幕后凋零:BAABLAAFFH8MAAIbAAUIRQwPKgAbAQAbAAUIRQwPKgAbAQAAAA==.幕后幕后凋零:BAABLAAFFH8TAAIEAAUIHRboKAA1AQAEAAUIHRboKAA1AQAAAA==.',['幸福']='幸福小米:BAAALAAECgYIDQAAAA==.幸福米米豆:BAAALAAECgIIAgAAAA==.',['幺儿']='幺儿幺幺:BAAALAADCgEIAQABLAAFFAQIEAAHALwOAA==.',['幻想']='幻想的可乐:BAAALAAECggICQAAAA==.',['幻魔']='幻魔师欧阳:BAAALAAECgMIBQAAAA==.',['幽蓝']='幽蓝眼眸:BAAALAAFFAIIBAAAAA==.',['应是']='应是人間凬流:BAAALAAFFAIIBAAAAA==.',['彩筆']='彩筆畫中人:BAABLAAFFH8IAAIMAAIIrBv0JgCZAAAMAAIIrBv0JgCZAAAAAA==.',['影袭']='影袭:BAAALAAECgcICAAAAA==.',['得闲']='得闲:BAAALAAECgYIBgAAAA==.',['御船']='御船千早:BAAALAAECgEIAQAAAA==.',['微笑']='微笑在左:BAAALAADCgEIAQAAAA==.',['德人']='德人精:BAAALAAECgYIDAAAAA==.',['心灵']='心灵捕手:BAAALAAECgIIAgAAAA==.',['忍野']='忍野咩咩:BAABLAAFFH8UAAIcAAYIjxcyJgCcAQAcAAYIjxcyJgCcAQAAAA==.',['忧棂']='忧棂:BAAALAAECgUIBQAAAA==.',['忿怒']='忿怒的西红柿:BAAALAAECgUIBQAAAA==.',['怀思']='怀思:BAAALAAECgYIBgAAAA==.',['总经']='总经理助理:BAAALAAECgEIAQAAAA==.',['恋上']='恋上你爱上你:BAAALAADCgIIAgAAAA==.',['恶堕']='恶堕季森:BAACLAAFFH8zAAIPAAYIvx9aDwDsAQAPAAYIvx9aDwDsAQAsAAQKfxkAAg8ABwj/Hbc1AD8CAA8ABwj/Hbc1AD8CAAAA.',['悠黯']='悠黯:BAABLAAFFH8LAAIDAAYI5iKaFADXAQADAAYI5iKaFADXAQAAAA==.',['悲鸣']='悲鸣月:BAAALAAECgYIDgAAAA==.',['情初']='情初:BAAALAAFFAEIAQAAAA==.',['情绪']='情绪病:BAAALAAFFAIIAgAAAA==.',['惡魔']='惡魔小寶:BAABLAAFFH8FAAINAAUIOx8lEgDRAQANAAUIOx8lEgDRAQAAAA==.',['懂事']='懂事能长大:BAAALAAFFAIIAwAAAA==.',['我之']='我之救赎:BAAALAADCgEIAQAAAA==.',['我会']='我会发激光:BAAALAAECgYIBgAAAA==.',['我叫']='我叫张健:BAABLAAFFH8LAAIcAAYI8BdECQAZAgAcAAYI8BdECQAZAgAAAA==.',['我吃']='我吃两个饼术:BAAALAAECgYIBgAAAA==.',['我向']='我向秦:BAAALAAECgQIBAAAAA==.',['我好']='我好饿:BAABLAAFFH8GAAIXAAYIihUWBgCLAQAXAAYIihUWBgCLAQAAAA==.',['我感']='我感觉很难受:BAAALAAECgYICgAAAA==.',['我老']='我老爸是姚明:BAAALAAECgYIDAAAAA==.',['戒了']='戒了个戒:BAAALAADCgcIBwAAAA==.',['扉页']='扉页悠然:BAAALAAFFAIIAgAAAA==.',['手捧']='手捧雷:BAAALAAECgYIBgAAAA==.',['扣子']='扣子:BAABLAAFFH8YAAMXAAYIoSQVAwALAgAXAAYIFyQVAwALAgATAAYI5B4+BQCEAQAAAA==.',['抓宝']='抓宝宝的矮子:BAAALAAECgYIDAAAAA==.',['折戟']='折戟:BAAALAAFFAIIAgAAAA==.折戟沉沙:BAACLAAFFH8IAAIUAAIIfga8HgBhAAAUAAIIfga8HgBhAAAsAAQKfxgAAhQABwhVF2EkANoBABQABwhVF2EkANoBAAAA.',['拆左']='拆左耳的司机:BAAALAADCggICAAAAA==.',['拾一']='拾一:BAABLAAFFH8GAAIPAAYIySHaCAA4AgAPAAYIySHaCAA4AgAAAA==.',['握了']='握了棵草:BAAALAAECgYIBgAAAA==.',['放逐']='放逐者:BAAALAAECgYIBgAAAA==.',['救世']='救世星龙:BAABLAAFFH8UAAMWAAYIlSDHAgATAgAWAAYIlSDHAgATAgAVAAUILg22EAANAQABLAAFFAYIFgAWAMMjAA==.',['斯露']='斯露恩邪眼:BAAALAAECgYIDAAAAA==.',['新島']='新島冴:BAAALAAECgQIBAAAAA==.新島真:BAAALAAECgQIBAAAAA==.',['新手']='新手走天下:BAAALAADCgEIAQAAAA==.',['无尽']='无尽暗夜猎手:BAAALAAECgYIBgAAAA==.',['无惧']='无惧千越:BAAALAAECgYIBgAAAA==.',['无敌']='无敌夹克:BAAALAAFFAQIBAAAAA==.无敌妞妞魔:BAAALAAFFAMIAwAAAA==.',['无眠']='无眠怒火:BAAALAAECgUIBQAAAA==.',['时光']='时光流丶:BAABLAAFFH8SAAIEAAUIjREZLgAVAQAEAAUIjREZLgAVAQABLAAFFAYINgALAPAeAA==.',['时间']='时间:BAAALAAECgYICgAAAA==.时间就系我:BAAALAAECgYIBgAAAA==.时间魔术师:BAAALAAECgUIBQAAAA==.',['昆仑']='昆仑悠闲:BAAALAAECgYIEAAAAA==.',['易丨']='易丨安:BAAALAAECgYIBgAAAA==.',['星夜']='星夜:BAAALAAECgUIBAAAAA==.',['星怒']='星怒:BAAALAAFFAIIAgAAAA==.',['星辰']='星辰九天:BAABLAAECn8qAAMOAAgITB+cEQDbAgAOAAgITB+cEQDbAgASAAgIpxvNIQBlAgAAAA==.星辰耀长空:BAAALAAECgcIBwAAAA==.',['春破']='春破虏:BAAALAAECgYICwABLAAFFAIIBgAUAGAfAA==.',['是恋']='是恋爱脑吧:BAABLAAFFH8QAAIcAAYIGxrOKgCMAQAcAAYIGxrOKgCMAQAAAA==.',['是老']='是老相好吧:BAAALAAECgQIBAAAAA==.',['晓丶']='晓丶点点:BAAALAAFFAIIAgABLAAFFAgIGQABAHgiAA==.',['晓情']='晓情卓意:BAAALAAECgYIBgAAAA==.',['晨光']='晨光:BAAALAAECggIEAAAAA==.',['晴旼']='晴旼:BAAALAADCgIIAgAAAA==.',['暗夜']='暗夜风行者:BAAALAAECgYIBgAAAA==.',['暗里']='暗里着迷:BAAALAAECgYIDAABLAAECggICwAIAAAAAA==.',['暮夜']='暮夜丶:BAAALAAECgYIBgAAAA==.',['曜日']='曜日:BAAALAADCgUIBQAAAA==.',['月下']='月下炎:BAABLAAFFH8GAAIDAAYIEhBaKQBtAQADAAYIEhBaKQBtAQAAAA==.',['月之']='月之翎:BAAALAAECgMIAwAAAA==.',['月影']='月影之翼:BAAALAAECgYIBgAAAA==.',['月若']='月若花开:BAAALAAECgYIDAAAAA==.',['本间']='本间芽衣:BAAALAAECgYICQAAAA==.',['术术']='术术来喽:BAAALAADCgcIBwAAAA==.',['术静']='术静:BAAALAADCgMIAwAAAA==.',['机智']='机智如我:BAAALAAECgMIAwAAAA==.',['机械']='机械猎神:BAAALAAFFAIIAgAAAA==.',['朽木']='朽木白哉丶:BAAALAADCgYIBgAAAA==.',['杀气']='杀气十足:BAABLAAFFH8GAAIbAAYIaxAeCgDxAQAbAAYIaxAeCgDxAQAAAA==.',['李知']='李知恩:BAAALAAFFAIIAgAAAA==.',['杯中']='杯中酒丶:BAAALAAECgQIBAAAAA==.',['東郷']='東郷一二三:BAAALAAECgYIBwAAAA==.',['板蓝']='板蓝根拿铁:BAAALAAECgMIAwAAAA==.',['果汁']='果汁的死亡:BAAALAADCgEIAQAAAA==.',['枫萧']='枫萧逝:BAAALAAFFAIIBAAAAA==.',['柳如']='柳如烟:BAACLAAFFH8hAAMOAAYI+RiDFQD8AAAOAAUILRmDFQD8AAASAAEITw4eJwBJAAAsAAQKfx0AAw4ACAhJHqEtACwCAA4ACAhJHqEtACwCABIAAQigFqaXAEUAAAAA.',['柳柳']='柳柳:BAAALAAECgQIBQAAAA==.',['桃喜']='桃喜:BAAALAAFFAIIAgAAAA==.',['梦回']='梦回一零年:BAAALAAFFAIIAgAAAA==.',['梦紫']='梦紫莲:BAAALAADCgEIAQAAAA==.',['椒盐']='椒盐皮皮虾:BAAALAAECgYICgAAAA==.',['樱牧']='樱牧华稻:BAAALAAECgYIDQAAAA==.',['橘子']='橘子皮不错:BAAALAAFFAIIAgAAAA==.',['欢愉']='欢愉虚空:BAAALAAECgYIBgAAAA==.',['欧洲']='欧洲小熊猫:BAAALAAECgYIDwAAAA==.',['欧阳']='欧阳耀泉:BAABLAAFFH8XAAMOAAYIgiGABwBSAgAOAAYIgiGABwBSAgAdAAIIWQ6TBQBgAAAAAA==.欧阳菲兒:BAAALAAFFAMIBAAAAA==.欧阳震华:BAACLAAFFH8PAAMLAAUIwBA0CAAWAQALAAUIwBA0CAAWAQADAAMIrwMMSwBsAAAsAAQKfxYAAwsACAg0HrMGAGgCAAsACAh4HbMGAGgCAAMABggeF5CtACgBAAAA.欧阳霏兒:BAABLAAFFH8IAAIQAAQIaxauDAAjAQAQAAQIaxauDAAjAQAAAA==.',['欧陽']='欧陽震華:BAAALAAFFAIIAgAAAA==.',['歐阳']='歐阳菲儿:BAABLAAFFH8SAAMGAAgIHRKFLwB5AQAGAAYIjxeFLwB5AQAZAAcIngSZCwDWAAAAAA==.',['歐陽']='歐陽菲儿:BAABLAAFFH8KAAMNAAYIDQlnNwAwAQANAAYIsQZnNwAwAQAaAAIINBJLEgBHAAAAAA==.歐陽震华:BAAALAAECggIDgAAAA==.歐陽震華:BAAALAAECgcIBwAAAA==.',['正义']='正义之歌:BAAALAAECgYIBgAAAA==.',['武小']='武小优:BAABLAAFFH8OAAIRAAQIZAcdDwCtAAARAAQIZAcdDwCtAAAAAA==.',['武見']='武見妙:BAAALAAECgcIDQAAAA==.',['歧途']='歧途悲歌:BAACLAAFFH8WAAIaAAUIWRwKBAAKAQAaAAUIWRwKBAAKAQAsAAQKfy0AAhoACAj6In0FABQDABoACAj6In0FABQDAAAA.',['毒药']='毒药小火龙:BAABLAAFFH8OAAMTAAYIZiNlBADzAQATAAYIZiNlBADzAQAXAAEI3B3CGQAAAAAAAA==.',['比的']='比的是演技:BAAALAAECgIIAgAAAA==.',['毛小']='毛小小八七:BAAALAAECgIIAgAAAA==.毛小小六:BAAALAADCgIIAgAAAA==.',['水晶']='水晶鼕瓜茶:BAAALAAECgYIBgAAAA==.',['水火']='水火风雷:BAAALAAECgYIBgAAAA==.',['水灵']='水灵光:BAAALAAECgQICwAAAA==.',['氵各']='氵各萨:BAAALAAFFAQIBAAAAA==.',['永夜']='永夜丶無解:BAAALAAECggIEAAAAA==.永夜之歌:BAAALAAECgYICQAAAA==.',['汪汪']='汪汪仙贝:BAABLAAFFH8IAAIJAAgIBxdjBgBzAgAJAAgIBxdjBgBzAgAAAA==.',['法拉']='法拉卡:BAAALAAECgUIBQAAAA==.',['法神']='法神求稳:BAAALAAECgIIAgAAAA==.',['泰难']='泰难德:BAAALAAECgMIAwAAAA==.',['流天']='流天类星龙:BAABLAAFFH8WAAMWAAYIwyNwAQBaAgAWAAYIwyNwAQBaAgAVAAUIqA4vEAAWAQAAAA==.',['浅墨']='浅墨幽兰:BAAALAAECgMIAwAAAA==.',['海蓮']='海蓮娜:BAAALAADCgEIAQAAAA==.',['淑士']='淑士:BAAALAAECgYIEgAAAA==.',['深渊']='深渊之歌:BAACLAAFFH8GAAINAAYI8xZuKwBtAQANAAYI8xZuKwBtAQAsAAQKfxkAAg0ABwg4Ea9zAJ0BAA0ABwg4Ea9zAJ0BAAAA.',['深蓝']='深蓝之歌:BAAALAADCgQIBAAAAA==.',['清水']='清水依依:BAAALAAECgYICQAAAA==.',['温柔']='温柔风暴:BAAALAAECgcIBwAAAA==.',['湘玉']='湘玉:BAAALAAFFAIIAgABLAAFFAIIBgAUAGAfAA==.',['湫兮']='湫兮如风:BAAALAAECgYIBgAAAA==.',['溶月']='溶月淡风:BAAALAAECgMIAwAAAA==.',['满月']='满月居于崆:BAAALAAECgYIBgAAAA==.',['满满']='满满:BAAALAAECgYICgAAAA==.',['火雷']='火雷神:BAABLAAFFH8JAAMMAAYIDxbYFwB+AQAMAAYIDxbYFwB+AQAPAAEIkAMvfQAsAAAAAA==.',['灬勿']='灬勿忘我灬:BAABLAAFFH8GAAIEAAYIUhNlGQCLAQAEAAYIUhNlGQCLAQAAAA==.',['灵钻']='灵钻:BAAALAAECgUICAAAAA==.',['炽末']='炽末荼迷:BAACLAAFFH8KAAIPAAIIyx9ELwCjAAAPAAIIyx9ELwCjAAAsAAQKfxQAAw8ABwhBG8lCABYCAA8ABwhBG8lCABYCAAwAAwhEBT67AHIAAAAA.',['無心']='無心傷害:BAAALAAECgYIEwAAAA==.',['燃烧']='燃烧的卷毛:BAAALAAFFAQIBAAAAA==.',['爱在']='爱在芯馒头:BAAALAADCgEIAQAAAA==.',['爱慕']='爱慕有法则丶:BAAALAAECgUIBQAAAA==.',['版本']='版本之子:BAABLAAFFH8JAAIUAAIIGxB2HQAwAAAUAAIIGxB2HQAwAAAAAA==.',['牛里']='牛里牛气:BAAALAADCgcICAAAAA==.',['特洛']='特洛伊悍马:BAAALAAECgQIBAABLAAECgYIBgAIAAAAAA==.特洛伊河马:BAAALAAECgYIDAAAAA==.特洛伊穗康码:BAAALAADCgYIBgAAAA==.特洛伊行程码:BAAALAAECgEIAQAAAA==.',['犀利']='犀利丶奇葩:BAAALAAECgEIAQAAAA==.',['狂乱']='狂乱中年母鸡:BAACLAAFFH8TAAMaAAYIUyBECwBnAAANAAUIZRkKLABqAQAaAAIInSRECwBnAAAsAAQKfxcABBoABwgkJMQ2AJIBABoABQiKIMQ2AJIBAA0ABAjyJM9AAEUBAB4AAwgeGVEgAO0AAAAA.',['狂暴']='狂暴的鱼哥:BAAALAADCggICAAAAA==.',['独孤']='独孤九箭:BAAALAAECgEIAQAAAA==.',['独步']='独步江畔:BAAALAAECgYIBgAAAA==.',['猎手']='猎手夹克:BAAALAADCgQIBwAAAA==.',['猎萌']='猎萌新:BAAALAAFFAIIBAAAAA==.',['猪母']='猪母狼马蜂:BAAALAADCgUIBQAAAA==.',['猪鼓']='猪鼓励:BAABLAAFFH8SAAITAAYIvx5WBgC9AQATAAYIvx5WBgC9AQAAAA==.',['獐麂']='獐麂神:BAAALAAECgYIBwAAAA==.',['王经']='王经理:BAAALAAECgYIBgAAAA==.',['玖灵']='玖灵墨:BAACLAAFFH81AAMSAAgI0xzIBAAoAgASAAcIWR/IBAAoAgAOAAcIXh7oAwAoAgAsAAQKfy8AAxIACAh5JXwFAFEDABIACAh5JXwFAFEDAA4ACAhnIGwiAGsCAAAA.',['琪児']='琪児丶酱:BAAALAAECggICAAAAA==.',['瑶池']='瑶池月姬:BAABLAAFFH8KAAIDAAIIqBjnQwCcAAADAAIIqBjnQwCcAAAAAA==.',['瓦里']='瓦里安大爷:BAAALAAECgYIBgAAAA==.',['甜在']='甜在心馒头:BAAALAAECgYIBgAAAA==.',['甜沫']='甜沫子:BAAALAAECgUIBQAAAA==.',['用亮']='用亮光闪瞎你:BAABLAAFFH8HAAIEAAIIJRU8QwCcAAAEAAIIJRU8QwCcAAAAAA==.',['甩狙']='甩狙枪枪爆头:BAACLAAFFH8IAAIGAAIIQRz1PACrAAAGAAIIQRz1PACrAAAsAAQKfygAAwYABwhKHpZUADQCAAYABgiVIZZUADQCABkABwhbFEBSAG0BAAAA.',['甲贺']='甲贺忍蛙:BAABLAAFFH8RAAIQAAYIoCN6AwBDAgAQAAYIoCN6AwBDAgABLAAFFAYIFgAWAMMjAA==.',['番茄']='番茄:BAAALAADCgQIBAAAAA==.',['疯癫']='疯癫琉璃:BAAALAAECggICgAAAA==.',['痛苦']='痛苦收割鸡:BAAALAADCgcIBwAAAA==.',['皓云']='皓云:BAAALAADCgQIBAAAAA==.',['眼不']='眼不见心还念:BAAALAAECggICAAAAA==.',['破晓']='破晓苍炎:BAAALAAECgEIAQAAAA==.',['祎祎']='祎祎殿下:BAAALAADCgYIBgAAAA==.',['神之']='神之战:BAAALAADCgcIBwAAAA==.',['神圣']='神圣的伪君子:BAAALAAECggIBQAAAA==.',['神是']='神是谁说:BAABLAAECn8VAAIOAAYITRC4aABBAQAOAAYITRC4aABBAQAAAA==.',['秋凛']='秋凛然:BAACLAAFFH8GAAIUAAIIYB+YFwBAAAAUAAIIYB+YFwBAAAAsAAQKfxgAAxQABgizF1oXAFsBABQABgizF1oXAFsBAB8ABggREBBEAEwBAAAA.',['秋叶']='秋叶之歌:BAAALAAECgQIBAAAAA==.',['科技']='科技狩猎:BAAALAAECgYIBgAAAA==.',['空气']='空气中密蔓:BAABLAAFFH8KAAIWAAII+w24FACIAAAWAAII+w24FACIAAAAAA==.空气中弥漫:BAABLAAFFH8RAAIQAAUIQwqQDQAHAQAQAAUIQwqQDQAHAQAAAA==.空气中米慢:BAABLAAFFH8FAAMfAAIIKAQtLABaAAAfAAIIKAQtLABaAAAEAAIISQfUiQAAAAAAAA==.空气中迷漫:BAABLAAFFH8IAAIgAAIIdQmVFQBCAAAgAAIIdQmVFQBCAAAAAA==.',['空见']='空见:BAAALAAECgYIBgAAAA==.',['竹影']='竹影清瞳:BAAALAAFFAIIAgAAAA==.',['符文']='符文之歌:BAAALAAECgUIBQAAAA==.',['第一']='第一帝国:BAAALAADCgEIAQAAAA==.',['等不']='等不到天亮:BAACLAAFFH82AAMLAAYI8B7hAgBqAQADAAYIox6GFADBAQALAAQIfiDhAgBqAQAsAAQKfz4AAwMACAj2JNIDANgCAAsACAgqJEIIABIDAAMACAgpJNIDANgCAAAA.等不到天亮吖:BAABLAAFFH8YAAIDAAcIYh0VEgDpAQADAAcIYh0VEgDpAQAAAA==.',['筱兩']='筱兩口超幸福:BAAALAADCgQIBAAAAA==.',['米兰']='米兰没有铁匠:BAABLAAFFH8GAAIEAAYIDgRzLwAKAQAEAAYIDgRzLwAKAQAAAA==.',['米利']='米利森:BAAALAAECggIDQAAAA==.',['粉色']='粉色回忆:BAABLAAFFH8GAAINAAMI6A2dXQBBAAANAAMI6A2dXQBBAAAAAA==.',['紫丶']='紫丶薇:BAAALAAFFAIIBAAAAA==.',['繁华']='繁华落尽時丨:BAAALAAECgYIBgAAAA==.',['繁花']='繁花落尽時丨:BAAALAAECgYIDAAAAA==.',['纯洁']='纯洁心灵:BAAALAADCgYICQAAAA==.',['纳兰']='纳兰若曦:BAAALAADCgYIAQAAAA==.',['绚烂']='绚烂的烟花:BAAALAAFFAEIAQAAAA==.',['绛红']='绛红:BAAALAAECggIDwAAAA==.',['绝命']='绝命一石:BAABLAAFFH8FAAIbAAUIHAF/ZAAhAAAbAAUIHAF/ZAAhAAAAAA==.',['绝地']='绝地天通:BAAALAAECgIIAgAAAA==.',['绝对']='绝对领袖:BAABLAAECn8iAAILAAgI/BpkFAB7AgALAAgI/BpkFAB7AgAAAA==.',['绝版']='绝版猎手:BAAALAADCgIIAgAAAA==.',['绿焰']='绿焰之歌:BAAALAAECggIEQAAAA==.',['绿豆']='绿豆芽:BAAALAAECgQIBAABLAAECggICAAIAAAAAA==.',['缪雪']='缪雪:BAACLAAFFH8nAAQcAAYIHyE6FADvAQAcAAYIHyE6FADvAQAgAAIITCP6DgBZAAAhAAMI0A9LGQA8AAAsAAQKfysABBwACAgYJQMpAM0CABwACAgNJQMpAM0CACAABAgqJIItAFgBACEAAgj6DeAtAEgAAAAA.',['缺耳']='缺耳朵:BAAALAADCggICAAAAA==.',['老图']='老图:BAAALAAFFAEIAQAAAA==.',['老徒']='老徒:BAAALAAECgMIBQAAAA==.',['老板']='老板:BAAALAAECgYIDAAAAA==.老板来桶酱油:BAACLAAFFH8LAAIUAAMIjBi8DQCoAAAUAAMIjBi8DQCoAAAsAAQKfxYAAhQABgjgIhYXAD8CABQABgjgIhYXAD8CAAAA.',['老油']='老油条子:BAAALAAECgMIBAABLAAFFAYIBgAEAKEIAA==.',['聆夜']='聆夜雨:BAAALAAECggICAAAAA==.',['肌肉']='肌肉恨天高:BAAALAADCgcIBwAAAA==.',['胎神']='胎神之王:BAAALAADCgEIAQAAAA==.',['脚少']='脚少:BAAALAAECgcICQAAAA==.',['艾玛']='艾玛斯通:BAAALAAECgYIBwAAAA==.',['芙尔']='芙尔思:BAAALAADCgYIBgAAAA==.',['芬霏']='芬霏心雨:BAAALAAECgYIBgAAAA==.',['芭啦']='芭啦啦:BAAALAAECgUIBQAAAA==.',['芳澤']='芳澤堇:BAAALAAECgIIAgAAAA==.',['若如']='若如初见:BAABLAAECn8UAAIaAAYIXheKEABlAQAaAAYIXheKEABlAQAAAA==.',['若隐']='若隐若現:BAAALAAECgYIEAABLAAECggICwAIAAAAAA==.',['英雄']='英雄器杜安:BAAALAAECgYIDAABLAAECggICwAIAAAAAA==.',['茄咧']='茄咧菲:BAAALAAECgMIAwAAAA==.',['荀彧']='荀彧:BAAALAAECgYIEgAAAA==.',['莫里']='莫里亚蒂:BAAALAAECgIIAgAAAA==.',['萨姆']='萨姆斯艾兰:BAAALAAECgYIBgAAAA==.',['落霞']='落霞孤鹜齐飞:BAACLAAFFH8mAAMGAAcIkBcLGADYAQAGAAcIkBcLGADYAQAZAAMI8ASnGwCaAAAsAAQKfyQAAwYABwiUHvpNAKkBAAYABwiUHvpNAKkBABkABQhUEYJwAAoBAAAA.',['葬月']='葬月幽然:BAAALAAFFAEIAQAAAA==.',['蓝藻']='蓝藻头:BAAALAAECgcIEwAAAA==.',['薯条']='薯条鸡块:BAAALAAECgQIBAAAAA==.',['蛇喰']='蛇喰梦子:BAABLAAFFH8KAAIcAAIIvxCLdwCMAAAcAAIIvxCLdwCMAAAAAA==.',['蜜拉']='蜜拉底儿:BAABLAAECn8aAAMXAAcIhhuaGADWAQAXAAcIFRuaGADWAQATAAUIsxAASgAaAQAAAA==.蜜拉馨儿:BAAALAAECgEIAQAAAA==.',['血羽']='血羽汐汐:BAAALAAECgIIBAAAAA==.',['血色']='血色将至:BAAALAAFFAIIBAAAAA==.',['行千']='行千里致广大:BAAALAAFFAIIAgAAAA==.',['行者']='行者武丛:BAAALAADCgEIAQAAAA==.',['衣之']='衣之哀伤:BAAALAAECgQICAAAAA==.衣之暗舞:BAAALAAECgIIAgAAAA==.',['西瓜']='西瓜炒饭:BAABLAAFFH8HAAIcAAII4ALAowAxAAAcAAII4ALAowAxAAAAAA==.',['解放']='解放碑:BAABLAAECn8VAAIJAAYIrBJhwABYAQAJAAYIrBJhwABYAQAAAA==.',['誓羽']='誓羽:BAAALAAECgUIBgAAAA==.',['诗景']='诗景景:BAAALAAECgcIBwAAAA==.',['诛月']='诛月:BAABLAAFFH8FAAIcAAIIVggLhQCDAAAcAAIIVggLhQCDAAAAAA==.',['诸神']='诸神之城:BAABLAAFFH8GAAIJAAII0xKuRgCUAAAJAAII0xKuRgCUAAAAAA==.诸神之恋:BAACLAAFFH8JAAIPAAIIQgqbXABjAAAPAAIIQgqbXABjAAAsAAQKfxoAAg8ABgilE+Y/AFsBAA8ABgilE+Y/AFsBAAAA.诸神之猪:BAACLAAFFH8UAAIDAAMIURZWQgCaAAADAAMIURZWQgCaAAAsAAQKfzcAAgMACAgOIJsQADACAAMACAgOIJsQADACAAAA.诸神之空:BAAALAAECgUIBQAAAA==.',['诸葛']='诸葛钢铁:BAAALAAECgYIBgAAAA==.',['诺丁']='诺丁:BAAALAAECgUIBQAAAA==.',['谢晓']='谢晓京:BAAALAAFFAIIAgAAAA==.',['豆拌']='豆拌克尔酥:BAAALAAECgYIBgAAAA==.',['豌豆']='豌豆芽:BAAALAAECggICAAAAA==.',['贝甜']='贝甜:BAAALAAECggICgAAAA==.',['贷帝']='贷帝:BAAALAAFFAIIAgAAAA==.',['费猎']='费猎罗:BAAALAAECgYICgAAAA==.',['贼小']='贼小的贼:BAAALAAECgMIBgAAAA==.',['超绝']='超绝肌肉线条:BAAALAAECgIIAwAAAA==.',['超薄']='超薄也有距厘:BAAALAAFFAIIBAAAAA==.',['躬耕']='躬耕于南阳:BAABLAAFFH8GAAIcAAIIbRqLgQBFAAAcAAIIbRqLgQBFAAAAAA==.',['达利']='达利园:BAAALAAECgYIEwAAAA==.',['迅荷']='迅荷:BAAALAAECgcIBwAAAA==.',['迦罗']='迦罗娜丶影杀:BAAALAAFFAIIAgAAAA==.',['适意']='适意:BAAALAAECggIBgAAAA==.',['逍遥']='逍遥无涯:BAABLAAECn8XAAIbAAgIix2qDwBvAgAbAAgIix2qDwBvAgAAAA==.',['途漫']='途漫漫而孑然:BAAALAAECgYIBgAAAA==.',['遇到']='遇到帥哥喽:BAAALAADCgEIAQAAAA==.',['遇见']='遇见八月:BAAALAAECgYIBgABLAAECggICwAIAAAAAA==.',['重修']='重修:BAAALAADCgUIBQAAAA==.',['鎮魂']='鎮魂曲:BAAALAAECgIIAgAAAA==.',['铗勊']='铗勊:BAAALAAECgYICgAAAA==.',['银丝']='银丝三千:BAAALAADCgQIBgAAAA==.',['镜尘']='镜尘:BAAALAAECgYIBgAAAA==.',['长沙']='长沙杠精:BAABLAAFFH8HAAIiAAII+wfRNAAtAAAiAAII+wfRNAAtAAAAAA==.',['閃電']='閃電:BAABLAAECn80AAIcAAcIrh7mKADSAQAcAAcIrh7mKADSAQAAAA==.',['阿予']='阿予想喷火:BAAALAAECgQIBAAAAA==.阿予想摸鱼:BAAALAAECgYIBgAAAA==.阿予想睡觉:BAABLAAFFH8GAAIBAAIIeRjIPQB5AAABAAIIeRjIPQB5AAAAAA==.',['阿兔']='阿兔兔:BAAALAAECgcICgAAAA==.',['阿尔']='阿尔托麗雅:BAAALAAECgIIAgAAAA==.阿尔特留斯:BAAALAADCggICAAAAA==.',['阿爾']='阿爾薩斯:BAAALAADCgIIAgAAAA==.',['阿琳']='阿琳:BAAALAAECgYICwAAAA==.',['阿瓦']='阿瓦达啃大瓜:BAACLAAFFH8kAAIDAAYI6RwAFgC0AQADAAYI6RwAFgC0AQAsAAQKfyoAAgMACAjKIQQmALUCAAMACAjKIQQmALUCAAAA.',['陈信']='陈信宏:BAAALAAECgIIAgAAAA==.',['隆梅']='隆梅尔:BAAALAAECgYIBgAAAA==.',['隔壁']='隔壁佬王:BAAALAAECgYIDAABLAAECggICwAIAAAAAA==.',['雨花']='雨花丶:BAAALAAFFAIIAgAAAA==.',['雪域']='雪域倾城:BAAALAAECgYIBgAAAA==.',['雪山']='雪山飞壶:BAAALAAECgcIDQAAAA==.',['雪月']='雪月華:BAAALAADCggIDQAAAA==.',['雪花']='雪花肥:BAAALAAFFAEIAQAAAA==.',['雷迪']='雷迪斯:BAAALAADCgYIBgAAAA==.',['霸月']='霸月魅魂:BAAALAAECgYIDAAAAA==.',['霸柳']='霸柳染颜秀青:BAAALAAECgUIBQAAAA==.',['颜清']='颜清清:BAAALAAECgYIDQAAAA==.',['风云']='风云冰荷:BAAALAAECgUIBQAAAA==.',['风刀']='风刀雪剑:BAAALAAECgIIAgAAAA==.',['风早']='风早神人:BAAALAAECgYIBgAAAA==.',['风雪']='风雪满天:BAAALAAECgYIBgAAAA==.',['风颜']='风颜:BAAALAADCgQIBAAAAA==.',['飞行']='飞行阿瓜:BAAALAAFFAIIBAAAAA==.',['香葱']='香葱蛋炒饭:BAAALAAECgYIDQAAAA==.',['马化']='马化腾亲哥哥:BAAALAAECgcIBwAAAA==.马化腾亲弟弟:BAAALAAECgUICAAAAA==.',['马达']='马达马达:BAABLAAFFH8vAAINAAYIphnfIQCUAQANAAYIphnfIQCUAQABLAAFFAYINgALAPAeAA==.',['马里']='马里奥格策:BAAALAAECgYIBwAAAA==.',['骑云']='骑云追艾露蒽:BAAALAADCgIIAgAAAA==.',['骑牛']='骑牛打天下:BAAALAAECgYIBgAAAA==.',['骑蜗']='骑蜗牛上天:BAAALAAECgcIAQAAAA==.',['骨箫']='骨箫范凄凉:BAABLAAECn8YAAIEAAYIAR7EbAAQAgAEAAYIAR7EbAAQAgAAAA==.',['高堡']='高堡奇人:BAAALAADCggICAABLAAECggICAAIAAAAAA==.',['鬼见']='鬼见愁:BAAALAADCgYIBgAAAA==.',['鬽影']='鬽影浪子:BAAALAAECgYIDAAAAA==.',['魔洞']='魔洞:BAAALAAFFAIIAgAAAA==.',['魔源']='魔源之心:BAAALAADCgYIBgAAAA==.',['鸥啼']='鸥啼:BAAALAAFFAIIAgAAAA==.',['鹿野']='鹿野千夏:BAAALAAECgUICQAAAA==.',['麓逸']='麓逸:BAAALAAECgYIDgAAAA==.',['黎明']='黎明之光:BAAALAAECgMIBQAAAA==.',['黑头']='黑头子:BAAALAAECgIIAgAAAA==.',['點點']='點點児:BAAALAAECgIIAgAAAA==.',['龊龌']='龊龌断断:BAAALAAECgYIDAAAAA==.',['龌龊']='龌龊断断:BAAALAAECgYIBwAAAA==.',['龙一']='龙一鸣:BAAALAAECgYIDAAAAA==.',['龙囡']='龙囡囡:BAAALAAECgYIEAAAAA==.',['龙晨']='龙晨燚:BAACLAAFFH8KAAIEAAII5Bp4MACrAAAEAAII5Bp4MACrAAAsAAQKfxUAAwQABwhuG5tnABoCAAQABwhuG5tnABoCABQAAgixCaNsAFkAAAAA.',['龙血']='龙血兔兔:BAAALAADCgcICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end