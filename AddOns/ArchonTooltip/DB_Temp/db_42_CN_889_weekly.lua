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
 local lookup = {'Shaman-Restoration','Warrior-Fury','Druid-Guardian','Mage-Frost','Paladin-Retribution','Monk-Windwalker','Hunter-Marksmanship','Hunter-BeastMastery','Evoker-Preservation','Mage-Arcane','Mage-Fire','Druid-Balance','Priest-Holy','Priest-Shadow','Priest-Discipline','Warrior-Arms','Warrior-Protection','DemonHunter-Havoc','Shaman-Elemental','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Rogue-Assassination','Monk-Mistweaver','Paladin-Protection','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Druid-Restoration','Druid-Feral','DemonHunter-Vengeance','Shaman-Enhancement','Paladin-Holy','Monk-Brewmaster','Rogue-Outlaw','Rogue-Subtlety','Hunter-Survival',}; local provider = {region='CN',realm='鹰巢山',name='CN',type='weekly',zone=42,date='2025-08-04',data={Al='Alexcjq:BAAAKgAECgQIBAAAAA==.Althea:BAABKgAFFH8GAAIBAAYI+BrVCQCoAQABAAYI+BrVCQCoAQABKgAFFAgICAABALsbAA==.',Ar='Arx:BAAAKgAFFAQIBAABKgAFFAYICAACAI4XAA==.',As='Asdestiny:BAAAKgAECgYIBgAAAA==.',Bi='Bigbro:BAAAKgAECgcIDgAAAA==.',Bo='Bojaxhiu:BAAAKgAECgMIAwAAAA==.',Bu='Burden:BAAAKgAECgIIAgAAAA==.',Ce='Cenalius:BAABKgAECn8YAAIDAAgIDRrkBwABAgADAAgIDRrkBwABAgAAAA==.',Ch='Character:BAABKgAFFH8OAAIEAAgIqBVJCAA+AQAEAAgIqBVJCAA+AQAAAA==.Chrisp:BAACKgAFFH8UAAIFAAUIPBv5KwA3AQAFAAUIPBv5KwA3AQAqAAQKfyQAAgUACAgbHU0/ADECAAUACAgbHU0/ADECAAAA.',Ek='Eklampsus:BAAAKgADCgcIBwAAAA==.',Fl='Flyingeggegg:BAAAKgAFFAYIBAABKgAFFAgIDgAGANAQAA==.',Ge='Genius:BAAAKgAECgMIAwAAAA==.',Ha='Handwin:BAACKgAFFH9pAAMHAAgI/h9PAwBpAgAHAAgIFh9PAwBpAgAIAAMIlB5yHQDgAAAqAAQKfzUAAwcACAgcIvARAEQCAAcACAgcIvARAEQCAAgABwhtFZp3AE4BAAAA.',Is='Israphael:BAAAKgAECgQIBAAAAA==.',Ka='Kapa:BAAAKgAECgUIBgAAAA==.',La='Langrisser:BAAAKgAECgcIBwAAAA==.Lansseax:BAABKgAFFH8FAAIJAAMIIw5NBwB/AAAJAAMIIw5NBwB/AAAAAA==.',Li='Listendung:BAAAKgAECgQIBAAAAA==.',Ma='Mathilde:BAAAKgADCggICAAAAA==.',Mc='Mcga:BAACKgAFFH8NAAQKAAMIKgtyAwCzAAAKAAMIogpyAwCzAAAEAAMIdggUHgCVAAALAAIIvALjQAA1AAAqAAQKfx4ABAoACAj5GgQPAF0BAAsACAipFjM8AKABAAoABgjgFwQPAF0BAAQABQi5F9dPACYBAAEqAAUUCAgKAAwAwwYA.',Mi='Mimo:BAAAKgAECgMIBAAAAA==.',Ms='Msuqq:BAABKgAECn8WAAQNAAgIKQ+DNABtAQANAAgIKQ+DNABtAQAOAAQIqxRANQDzAAAPAAEILhEGkQAxAAAAAA==.',Ne='Neonati:BAAAKgADCgIIAgAAAA==.',On='Onlyrail:BAAAKgAECgEIAQAAAA==.',Po='Polaris:BAABKgAFFH8IAAIFAAQI2yBwCwAoAQAFAAQI2yBwCwAoAQAAAA==.',Re='Reiayanami:BAAAKgAFFAgIAgAAAA==.',Ri='Ririhanna:BAAAKgADCgcIBwAAAA==.',Sa='Sagittaurus:BAAAKgAECgcIDwAAAA==.Sawa:BAABKgAFFH8QAAQQAAQIGhxrBwDyAAAQAAQISRVrBwDyAAACAAQI7RndGwDlAAARAAQImBLjBADBAAAAAA==.Sawatani:BAAAKgAECgIIAgAAAA==.',Sc='Scorpion:BAABKgAFFH8IAAISAAgIsRewBgAzAgASAAgIsRewBgAzAgAAAA==.',St='Sting:BAAAKgADCggICAAAAA==.',To='Tobacoo:BAABKgAFFH8MAAITAAQIshrqEwDMAAATAAQIshrqEwDMAAAAAA==.',Ty='Tyrus:BAAAKgADCgcIBwAAAA==.',Ze='Zeus:BAAAKgADCgEIAQAAAA==.',Zs='Zsess:BAABKgAECn8XAAQUAAcITxiiQADeAAAVAAcITxicXQD2AAAUAAUIAhGiQADeAAAWAAIIGQoxPQBRAAAAAA==.',['一刀']='一刀鸽:BAAAKgADCgEIAQAAAA==.',['一口']='一口伏特加:BAAAKgAFFAQIBAAAAA==.',['一夜']='一夜白了头:BAAAKgAECgMIAwAAAA==.',['一尐']='一尐柒一:BAAAKgAECggIEQAAAA==.一尐柒乀:BAAAKgADCggIEAAAAA==.',['一路']='一路电过去:BAABKgAFFH8IAAIBAAgI6BTLBAAOAgABAAgI6BTLBAAOAgAAAA==.',['七情']='七情渡:BAAAKgAECgYICQAAAA==.',['万恶']='万恶的狗麦:BAAAKgAECgEIAQAAAA==.',['三下']='三下悠亚:BAAAKgADCgIIAgAAAA==.',['上官']='上官无筵:BAACKgAFFH8YAAIIAAQI+yTwGgApAQAIAAQI+yTwGgApAQAqAAQKfyQAAggACAjaJO4KANwCAAgACAjaJO4KANwCAAEqAAUUCAgvABcAgyMA.',['不争']='不争不灭:BAAAKgAECgcIBwAAAA==.',['不就']='不就你一个么:BAABKgAECn8XAAMQAAYI4xSxLQBPAQAQAAYI4xSxLQBPAQACAAIIJwlPhwBPAAAAAA==.',['不必']='不必等天晴:BAABKgAFFH8UAAMYAAYIjRSuAwCJAQAYAAYIjRSuAwCJAQAGAAQIFyBdDwDtAAAAAA==.',['不锈']='不锈钢的心:BAAAKgAFFAgIBAAAAA==.',['与卿']='与卿赴韶华:BAAAKgADCggICAAAAA==.',['丨弎']='丨弎纸情书丨:BAAAKgAECgcICAAAAA==.',['丨秋']='丨秋乌磊丨:BAABKgAFFH8HAAIZAAQIeh17BgD9AAAZAAQIeh17BgD9AAAAAA==.',['丶彩']='丶彩葒餹:BAAAKgAECgMIAwAAAA==.',['丶灬']='丶灬尐鑫:BAAAKgAECggIEQAAAA==.丶灬鑫:BAAAKgADCggICAAAAA==.',['丶獨']='丶獨角戱丶:BAABKgAFFH8MAAMaAAYIwSAhCgDrAQAaAAYIwSAhCgDrAQAbAAYImRxvCACTAQAAAA==.',['丶青']='丶青青子衿:BAAAKgADCggICAAAAA==.',['为爱']='为爱守玲丶:BAAAKgAECggIEQAAAA==.',['乃乃']='乃乃苏:BAAAKgAECgIIAgAAAA==.',['乌鸦']='乌鸦哥:BAAAKgAECgEIAQAAAA==.',['乐乐']='乐乐茶:BAABKgAFFH8IAAIHAAQI4Q8kFAC/AAAHAAQI4Q8kFAC/AAAAAA==.',['乔治']='乔治不拿盾:BAAAKgAECggIEgAAAA==.',['云稀']='云稀夜:BAAAKgAECgMIAwAAAA==.',['亲亲']='亲亲小可爱:BAAAKgAECgcICwAAAA==.',['人狠']='人狠话不多:BAAAKgAECgQIBAAAAA==.',['仙本']='仙本那:BAABKgAFFH8OAAMaAAQIgBHnNADEAAAaAAQIgBHnNADEAAAbAAQI0gtnDgCRAAAAAA==.',['以小']='以小德服人:BAAAKgADCggICAAAAA==.',['任梦']='任梦不会奶人:BAAAKgAFFAEIAQAAAA==.',['伊斯']='伊斯:BAACKgAFFH8HAAMOAAYI5QjGFwClAAAOAAIIownGFwClAAANAAQIEQKNFACbAAAqAAQKfxoAAw4ACAh2FqsOAKgBAA4ACAh2FqsOAKgBAA0ABggRDwtcAM0AAAEqAAUUCAgCABwAAAAA.',['伊芙']='伊芙雷妮:BAAAKgAFFAgIAgAAAA==.',['众生']='众生万物之父:BAAAKgAECggICAABKgAFFAgICgAMAMMGAA==.',['传说']='传说的胖子:BAAAKgADCgQIBAAAAA==.',['你别']='你别发烧了:BAAAKgAFFAQIBAAAAA==.',['你脸']='你脸红个嘚啊:BAAAKgADCgQIBAAAAA==.',['侠义']='侠义天下:BAAAKgAECgEIAQAAAA==.',['傻傻']='傻傻牛妹妹:BAAAKgAECgQIBAAAAA==.',['兔子']='兔子二号:BAAAKgAECgQIBQAAAA==.',['八福']='八福子:BAACKgAFFH9BAAICAAgIJx29AgCZAgACAAgIJx29AgCZAgAqAAQKfy0AAwIACAgPJLoHAM8CAAIACAgPJLoHAM8CABEAAQhxAtVRAAwAAAAA.',['六月']='六月:BAAAKgAECggIDgAAAA==.',['冬瓜']='冬瓜顶不顶:BAAAKgADCggICAAAAA==.',['冰之']='冰之青雉丶:BAABKgAFFH8GAAILAAYIqRdMDwBOAQALAAYIqRdMDwBOAQAAAA==.',['冲锋']='冲锋释放睡觉:BAAAKgAECgEIAQAAAA==.',['冷冷']='冷冷的冰鱼:BAABKgAFFH8KAAQMAAUIwwYJRgCXAAAMAAQILQYJRgCXAAAdAAQI2AkGJwCJAAAeAAEIiAjaCABOAAAAAA==.',['凤青']='凤青:BAAAKgAFFAQIBAAAAA==.',['划船']='划船看雪落:BAACKgAFFH8zAAILAAgIfxomBABVAgALAAgIfxomBABVAgAqAAQKf0cABAsACAgwI44NAKoCAAsACAi+Io4NAKoCAAoACAheHfAIAFECAAQAAQjbFn6iAEQAAAAA.',['加文']='加文拉德厄运:BAAAKgADCgIIAgAAAA==.',['劳得']='劳得逸:BAAAKgAECgIIAgAAAA==.',['北极']='北极夜光:BAAAKgAECgQIBQAAAA==.',['十一']='十一境武夫:BAAAKgAECgQIBAAAAA==.十一月的轨迹:BAAAKgADCgEIAQAAAA==.',['华丽']='华丽击杀:BAAAKgADCgMIAwAAAA==.',['华亭']='华亭海小商贩:BAAAKgAFFAEIAQAAAA==.',['华佗']='华佗:BAAAKgAECgYIBgAAAA==.',['卑鄙']='卑鄙的夜归人:BAAAKgAECgQIBAAAAA==.',['卡丽']='卡丽熙丶:BAAAKgADCggICAAAAA==.',['卡卡']='卡卡拉梦想:BAAAKgAECgIIAgAAAA==.',['卡尔']='卡尔萨斯:BAAAKgAFFAYIBAAAAA==.',['叁岁']='叁岁含奶补刀:BAAAKgAFFAYIBAAAAA==.',['又欠']='又欠儿:BAAAKgADCgQIBAAAAA==.',['发牌']='发牌大师:BAABKgAFFH8GAAILAAYIowuVEABAAQALAAYIowuVEABAAQAAAA==.',['古伊']='古伊萨:BAABKgAECn8WAAIEAAgIBRoaHgAXAgAEAAgIBRoaHgAXAgAAAA==.',['可洛']='可洛洛:BAAAKgAECgQIBAAAAA==.',['司凹']='司凹利利:BAABKgAFFH8JAAMZAAYIWRrvCwA4AQAZAAYIzRLvCwA4AQAFAAMIQRJTVQDGAAAAAA==.',['名狗']='名狗官余沧海:BAABKgAECn8UAAIaAAgI6xfOQQBrAQAaAAgI6xfOQQBrAQAAAA==.',['吕归']='吕归尘阿苏勒:BAABKgAECn8bAAMSAAgIqgzaTgAOAQASAAcIjQ3aTgAOAQAfAAgIwwbhPADAAAAAAA==.',['吴家']='吴家体彩均:BAAAKgADCgMIAwAAAA==.',['呀唛']='呀唛德:BAACKgAFFH8GAAIMAAYIxxWwEgCHAQAMAAYIxxWwEgCHAQAqAAQKfx4AAgwACAj3IagnACQCAAwACAj3IagnACQCAAAA.',['呆呆']='呆呆丶小囡:BAAAKgAFFAgIBAAAAA==.',['呆德']='呆德瞎:BAAAKgAECgcIBwAAAA==.呆德骑:BAAAKgAECggICAAAAA==.',['呦丶']='呦丶宋威:BAACKgAFFH8pAAMEAAUIsiBVBgD9AAAKAAQIIh2zHAAAAQAEAAUIsiBVBgD9AAAqAAQKf1cAAwQACAi+JaUDAO8CAAQACAiUJaUDAO8CAAoABwiEHcUPANMBAAAA.',['命運']='命運的落葉:BAABKgAFFH8LAAIFAAYIfBcyJgBQAQAFAAYIfBcyJgBQAQAAAA==.',['哟我']='哟我的小乖乖:BAAAKgADCgUIBQAAAA==.',['唠唠']='唠唠:BAABKgAFFH8SAAIVAAYIYh1sDwCZAQAVAAYIYh1sDwCZAQAAAA==.',['唱过']='唱过陈奕迅:BAAAKgADCggICAAAAA==.',['啊但']='啊但:BAAAKgAECgYIEwAAAA==.',['嗯叽']='嗯叽哇塞:BAAAKgAECgQICQAAAA==.',['嘛哩']='嘛哩丶古韵:BAAAKgAFFAIIAgAAAA==.',['团灭']='团灭发动机:BAAAKgADCgQIBAAAAA==.',['团队']='团队输出木桩:BAAAKgAECgUIBwAAAA==.',['地藏']='地藏王菩萨:BAAAKgAECggICAAAAA==.',['坚持']='坚持动态清零:BAABKgAFFH8SAAIFAAYI5xrQGgCLAQAFAAYI5xrQGgCLAQAAAA==.坚持居家办公:BAABKgAFFH8NAAMgAAQIchr1DQDtAAAgAAMIchr1DQDtAAABAAIIaAYWUgA2AAAAAA==.坚持接种疫苗:BAABKgAFFH8dAAMMAAQIdiTSEAD3AAAMAAQIdiTSEAD3AAAdAAMIJRliJQCQAAAAAA==.',['夏夜']='夏夜的柔风:BAABKgAFFH8FAAIFAAUIQx0SJwBMAQAFAAUIQx0SJwBMAQAAAA==.',['多拉']='多拉贡:BAAAKgADCgEIAQAAAA==.',['多蒙']='多蒙卡修:BAABKgAFFH8MAAIYAAYIrQ2xCgAcAQAYAAYIrQ2xCgAcAQAAAA==.',['大松']='大松狮:BAAAKgADCggICAAAAA==.',['大泵']='大泵动:BAAAKgAECggICAAAAA==.',['大白']='大白柰子:BAAAKgADCgMIAwAAAA==.',['大码']='大码领主:BAAAKgADCgEIAgAAAA==.',['大苹']='大苹果:BAAAKgAECgUIBQAAAA==.',['大酒']='大酒缸:BAAAKgAECggIEAAAAA==.',['天火']='天火丶天火:BAABKgAFFH8LAAMUAAMIxhoYDADUAAAVAAMIphX6JgDVAAAUAAMIHxgYDADUAAAAAA==.',['天猎']='天猎战虎:BAAAKgAECgEIAQAAAA==.',['头真']='头真大:BAAAKgAECgUICAAAAA==.',['套住']='套住唔好玩:BAABKgAECn8VAAIEAAgIrRb4CQDqAQAEAAgIrRb4CQDqAQAAAA==.',['奶油']='奶油烩蜊饭:BAAAKgAECggIEQAAAA==.',['她德']='她德撸一发:BAAAKgAECgIIAgAAAA==.',['妖之']='妖之小萝莉:BAAAKgAECgUIBQAAAA==.妖之杏:BAAAKgADCggICAAAAA==.妖之魂:BAAAKgAECgEIAQAAAA==.',['子柒']='子柒:BAAAKgAECgYIBgAAAA==.',['子非']='子非鱼:BAAAKgAECgMIAwAAAA==.',['它好']='它好我也好:BAAAKgADCggICAAAAA==.',['安普']='安普:BAAAKgAECgYIBgAAAA==.',['安氻']='安氻:BAAAKgADCgMIAwAAAA==.',['射射']='射射已经谢了:BAABKgAFFH8MAAIHAAYIsR9+CADUAQAHAAYIsR9+CADUAQAAAA==.',['小困']='小困包:BAAAKgAECgQIBAAAAA==.',['小小']='小小美美:BAAAKgAFFAQIBAAAAA==.',['小水']='小水杯:BAAAKgADCgcICQAAAA==.',['小游']='小游猪猪:BAABKgAFFH8QAAIFAAYIsCIRDgD0AQAFAAYIsCIRDgD0AQAAAA==.',['小片']='小片儿:BAAAKgADCgYIBgAAAA==.',['小猴']='小猴晨晨:BAAAKgADCggICgAAAA==.',['尛海']='尛海螺:BAAAKgAECgUICAABKgAFFAQICwAEALEgAA==.',['尛虾']='尛虾米:BAACKgAFFH8LAAIEAAQIsSBqBQAFAQAEAAQIsSBqBQAFAQAqAAQKfzAABAQACAiyJcYEAOsCAAQACAiyJcYEAOsCAAoABghDGBwNAIABAAsABgiDDWdiAOgAAAAA.',['就想']='就想再瘦点:BAAAKgAECgYICAAAAA==.',['康斯']='康斯坦汀:BAACKgAFFH8IAAIFAAQIcBpAGQD5AAAFAAQIcBpAGQD5AAAqAAQKfxoAAyEACAh8I1oJAFYCACEACAh8I1oJAFYCAAUABggIFhwYAZgAAAAA.',['强力']='强力混子:BAAAKgAECgMIBQAAAA==.',['彡微']='彡微笑:BAAAKgADCgcIBwAAAA==.',['彬少']='彬少:BAAAKgAECgQIBQAAAA==.',['影兰']='影兰:BAACKgAFFH82AAIEAAgIBCJiAQA5AgAEAAgIBCJiAQA5AgAqAAQKfy4AAgQACAhHJoMCAAUDAAQACAhHJoMCAAUDAAAA.',['微笑']='微笑似暖阳:BAAAKgAECgYIBgAAAA==.',['德莱']='德莱文辅助:BAACKgAFFH8RAAMdAAMIcxgtHQC7AAAdAAMIcxgtHQC7AAAMAAEIjQB6ZQAdAAAqAAQKfx0AAx0ABwjAFikkAH8BAB0ABwjAFikkAH8BAAwABQjtCwhDAHQAAAAA.',['忆释']='忆释然:BAAAKgAFFAgIBAAAAA==.',['怠惰']='怠惰丶:BAACKgAFFH8WAAIaAAQIpCWoBQBKAQAaAAQIpCWoBQBKAQAqAAQKfycAAhoACAiLJboDAP0CABoACAiLJboDAP0CAAAA.',['恋爱']='恋爱高手:BAABKgAFFH8GAAIiAAQI/g2IBQCYAAAiAAQI/g2IBQCYAAAAAA==.',['愤怒']='愤怒的小猫猫:BAAAKgADCggICAAAAA==.',['我有']='我有一个特长:BAACKgAFFH8nAAIFAAUIHR/JDAAhAQAFAAUIHR/JDAAhAQAqAAQKfzMAAgUACAi1JQQHAP0CAAUACAi1JQQHAP0CAAAA.我有在锻炼:BAAAKgADCgcIEQAAAA==.',['我超']='我超勇:BAAAKgADCggICgAAAA==.',['战争']='战争机器:BAAAKgAECgYIBgAAAA==.',['戚少']='戚少正丶花雕:BAAAKgAECgcIBwAAAA==.',['手到']='手到出水:BAAAKgADCgQIBAAAAA==.',['手抢']='手抢火人矮:BAAAKgADCggICAAAAA==.',['手更']='手更残的冷坑:BAAAKgADCgEIAQAAAA==.',['拉姆']='拉姆司菲尔德:BAAAKgADCgIIAgAAAA==.',['拉蓝']='拉蓝诺:BAAAKgAECgQIBAAAAA==.',['拳头']='拳头四百:BAAAKgAECgEIAQAAAA==.',['拾丶']='拾丶柒:BAAAKgAECgEIAQAAAA==.',['拾柒']='拾柒:BAAAKgAECgUIBQAAAA==.',['放开']='放开那老奶:BAAAKgAFFAMIAwAAAA==.',['文君']='文君元气弹:BAAAKgAFFAQIBAAAAA==.',['文西']='文西:BAAAKgAECgQICwAAAA==.',['斩首']='斩首行动:BAAAKgADCgYIBgAAAA==.',['无情']='无情:BAABKgAFFH8GAAIFAAYI6CVrFwChAQAFAAYI6CVrFwChAQAAAA==.',['无语']='无语丨灬橙子:BAABKgAFFH8aAAQKAAYI0BeVAQD1AAALAAYIehJRDgBYAQAKAAQIrBuVAQD1AAAEAAQILyACCADtAAAAAA==.',['日不']='日不落:BAAAKgADCggIEAAAAA==.',['旧得']='旧得很好看:BAABKgAFFH8OAAQOAAYI2ArnCAAbAQAOAAUI+wznCAAbAQAPAAQIFg9eDgDkAAANAAEIAAAFKwAAAAAAAA==.',['星光']='星光灭绝:BAACKgAFFH8MAAIFAAgIChjYCgAYAgAFAAgIChjYCgAYAgAqAAQKfzcAAgUACAiEJowGAAADAAUACAiEJowGAAADAAAA.',['星宸']='星宸:BAABKgAFFH8KAAISAAMIuQoQHQCpAAASAAMIuQoQHQCpAAAAAA==.',['星尘']='星尘:BAAAKgAFFAMIAwAAAA==.',['星星']='星星与太阳:BAAAKgAFFAQIBAAAAA==.',['星空']='星空下的幻想:BAACKgAFFH8MAAMZAAQITCGXBQAOAQAZAAQIWx6XBQAOAQAFAAQITCFhEgAMAQAqAAQKfxYAAgUACAhHIuUyAFcCAAUACAhHIuUyAFcCAAAA.',['景秀']='景秀衣:BAAAKgADCgQIBgAAAA==.',['暗夜']='暗夜猎手:BAAAKgAECgYIBgAAAA==.',['木子']='木子星辰:BAAAKgAECgIIAgAAAA==.',['杰杰']='杰杰阿童木:BAAAKgAFFAgIBAAAAA==.',['极夜']='极夜辉光:BAAAKgAFFAIIAgAAAA==.',['果汁']='果汁:BAAAKgAFFAQIBAAAAA==.',['柳如']='柳如烟:BAAAKgAECgYIBgAAAA==.',['梦羽']='梦羽衣:BAABKgAECn8WAAMPAAgIaRWqCQCzAQAPAAgIaRWqCQCzAQAOAAYIPgGkXQA9AAAAAA==.',['橘阳']='橘阳菜丶:BAABKgAFFH8MAAMbAAQI9hvtEQCzAAAaAAQI9htRLwDTAAAbAAQIXRDtEQCzAAAAAA==.',['橙心']='橙心丶:BAABKgAFFH8GAAISAAQIkBGlKwDKAAASAAQIkBGlKwDKAAABKgAFFAgIMgAXAIkjAA==.',['橙色']='橙色的迪凯:BAAAKgAECggICAAAAA==.',['欢乐']='欢乐树的喷友:BAAAKgAECgYIDAAAAA==.',['残丶']='残丶剑:BAAAKgAFFAYIAQAAAA==.',['残剱']='残剱:BAAAKgAECgIIAgAAAA==.',['残劒']='残劒:BAAAKgAECggICAAAAA==.',['毒菇']='毒菇猫猫:BAABKgAFFH8OAAMHAAgIuBeQAwBeAgAHAAgIuBeQAwBeAgAIAAQIOxR0JADDAAAAAA==.',['沉睡']='沉睡中的卡卡:BAAAKgAFFAQIBAAAAA==.',['沐沐']='沐沐丨丶:BAAAKgAFFAYIAQABKgAFFAgIIAANADMhAA==.',['泉鸽']='泉鸽:BAAAKgAFFAQIBAAAAA==.',['泡伊']='泡伊珂:BAAAKgAECggIEQAAAA==.',['泣雷']='泣雷:BAABKgAFFH8LAAMCAAMIsweuFQC1AAACAAMIYAeuFQC1AAARAAMIsAJRFQBOAAAAAA==.',['洒曼']='洒曼:BAAAKgAECgEIAQAAAA==.',['流年']='流年之伤:BAAAKgAFFAIIAgAAAA==.',['海水']='海水梦悠悠:BAAAKgADCggICAAAAA==.',['海瑟']='海瑟薇:BAAAKgAFFAQIBAAAAA==.',['消失']='消失的星期二:BAABKgAFFH8IAAIZAAgIHRk4AwAUAgAZAAgIHRk4AwAUAgAAAA==.',['漂泊']='漂泊一:BAAAKgAECgcIBwAAAA==.',['漆乄']='漆乄雅吇:BAAAKgAECgMIAwAAAA==.',['漠漠']='漠漠摸鱼:BAAAKgAECgIIAgAAAA==.',['潜行']='潜行的奈亚子:BAACKgAFFH8vAAIXAAgIgyO+AgCXAgAXAAgIgyO+AgCXAgAqAAQKfywAAhcACAi/I4gFAK8CABcACAi/I4gFAK8CAAAA.',['澹台']='澹台旋:BAAAKgAECggICAAAAA==.',['火星']='火星爆炸头:BAABKgAFFH8JAAMVAAQInyFyDAD9AAAVAAQInyFyDAD9AAAUAAEIxhWIKgBFAAAAAA==.',['灬尐']='灬尐菟灬:BAAAKgAFFAIIAgAAAA==.',['灬拂']='灬拂曉灬:BAAAKgAECgQIBQAAAA==.',['灬赛']='灬赛尔提:BAAAKgAECgcIDAAAAA==.',['灾难']='灾难狂欢丶:BAAAKgAFFAQIBAAAAA==.',['炙焰']='炙焰:BAAAKgADCggICAAAAA==.',['煜柯']='煜柯宝贝:BAAAKgAECgEIAQAAAA==.',['熊猫']='熊猫甜甜圈:BAAAKgAECgMIAwAAAA==.',['牛哥']='牛哥向前冲:BAAAKgAECgEIAQAAAA==.',['牛喜']='牛喜欢:BAAAKgADCgQIBAAAAA==.',['牛德']='牛德一塌糊涂:BAAAKgAECgYICQAAAA==.',['牛懒']='牛懒汉:BAAAKgAECgcIDwAAAA==.',['牛欢']='牛欢喜:BAAAKgAFFAMIAwAAAA==.',['牛肉']='牛肉盖饭:BAAAKgADCgMIAwAAAA==.',['犀牛']='犀牛图拉:BAAAKgAECgEIAQAAAA==.',['猎刃']='猎刃之矛:BAABKgAFFH8GAAIIAAYIYh+mCwC1AQAIAAYIYh+mCwC1AQAAAA==.',['猫又']='猫又:BAAAKgADCgQIBAAAAA==.',['獨奏']='獨奏悲歌:BAABKgAFFH8IAAMjAAQINxqgBADXAAAkAAQIpAl8CQDZAAAjAAQINxqgBADXAAAAAA==.',['玉絮']='玉絮:BAAAKgAFFAMIAwAAAA==.',['王阿']='王阿姨:BAAAKgADCgEIAgAAAA==.',['玛琉']='玛琉:BAABKgAFFH8GAAIfAAYI9gIhCgCqAAAfAAYI9gIhCgCqAAAAAA==.',['琬荭']='琬荭髷:BAAAKgADCggICAAAAA==.',['甜我']='甜我妲己吧:BAAAKgAECgcIDAAAAA==.',['癞皮']='癞皮狗:BAAAKgAFFAIIAgAAAA==.',['百变']='百变牛钢:BAAAKgAECggIDwAAAA==.',['皮奥']='皮奥:BAAAKgAECgMIBAAAAA==.',['盛情']='盛情之醉:BAAAKgAFFAIIAgAAAA==.',['相対']='相対性理论:BAAAKgAECgcICgAAAA==.',['看看']='看看怎么个事:BAABKgAFFH8HAAIKAAQIQB9FGQAaAQAKAAQIQB9FGQAaAQABKgAFFAgILwAXAIMjAA==.',['睡梦']='睡梦罗汉拳:BAABKgAECn8dAAMiAAgIgxT1CgCVAQAiAAgIgxT1CgCVAQAYAAgIHAo5QQA8AQAAAA==.',['碧柠']='碧柠酱:BAABKgAFFH8GAAIKAAYIXxw7CgC+AQAKAAYIXxw7CgC+AQABKgAFFAgIGAAPAOgeAA==.',['碧火']='碧火青天:BAAAKgAECgQIBAAAAA==.',['碧青']='碧青波澜:BAABKgAFFH8OAAMEAAMIUSPNDAABAQAEAAMIICDNDAABAQAKAAEIsCK/PgBhAAAAAA==.',['神威']='神威是头狼:BAAAKgAECgEIAQAAAA==.',['神枪']='神枪手龟龟:BAABKgAECn8bAAMIAAgIUBXXUABqAQAIAAgIUBXXUABqAQAHAAYI/w/+XADhAAAAAA==.',['禪心']='禪心定不忘生:BAAAKgAECgUIBgAAAA==.',['秋丶']='秋丶秋:BAABKgAFFH8IAAIaAAQI4SMVCQAhAQAaAAQI4SMVCQAhAQAAAA==.',['索马']='索马里渔夫:BAABKgAFFH8GAAIhAAYIZxB1BgBZAQAhAAYIZxB1BgBZAQAAAA==.',['紫月']='紫月晨星:BAAAKgADCgEIAQAAAA==.',['紫焰']='紫焰幽兰:BAAAKgAECgcIBwAAAA==.',['红肚']='红肚兜丶:BAACKgAFFH8VAAIXAAgIXx7IAgCVAgAXAAgIXx7IAgCVAgAqAAQKfykAAxcACAg/JBYGAKYCABcACAg/JBYGAKYCACMAAghIBpsaADQAAAAA.',['红色']='红色的忧郁:BAAAKgAECggICQAAAA==.',['红豆']='红豆思豆:BAAAKgAFFAYIAwAAAA==.',['练霓']='练霓裳:BAAAKgADCggIDAAAAA==.',['维莱']='维莱里奥:BAABKgAFFH8LAAMbAAYIhiDJAADcAQAbAAYIAx7JAADcAQAaAAUI3RufGwBAAQAAAA==.',['绿大']='绿大佬:BAAAKgAECggIEQAAAA==.',['绿皮']='绿皮鬼:BAACKgAFFH8RAAQVAAYIjSIYAQDzAQAVAAYIjSIYAQDzAQAUAAMIGhGAGQCDAAAWAAEIrBufGQBUAAAqAAQKfyIABBUACAjhGqM3AI8BABUACAivE6M3AI8BABQABAgSGmA6APgAABYAAQhmHns8AFQAAAAA.',['羿鸽']='羿鸽枭德:BAAAKgAFFAQIBAAAAA==.',['翔里']='翔里有毒:BAABKgAECn8cAAMTAAgImyELDgBtAgATAAgImyELDgBtAgABAAgIQRsGKQDbAQABKgAFFAgIDwAgAC4bAA==.',['翻滚']='翻滚吧阮:BAAAKgAECggICAAAAA==.',['老侯']='老侯:BAAAKgAECgYIBgAAAA==.',['考试']='考试得了一百:BAAAKgADCgYIBgAAAA==.',['聖光']='聖光終曲:BAABKgAFFH8IAAIFAAgI8QuPEQDRAQAFAAgI8QuPEQDRAQAAAA==.',['肉弹']='肉弹丶:BAAAKgAFFAEIAQAAAA==.',['胖熊']='胖熊猫:BAAAKgADCgEIAQAAAA==.',['胡椒']='胡椒粉:BAAAKgADCgcIBwAAAA==.',['脆皮']='脆皮炸咕咕:BAABKgAFFH8GAAIdAAYI3hVUCQByAQAdAAYI3hVUCQByAQAAAA==.脆皮甜甜圈:BAABKgAECn8hAAIFAAgIDiFcNABSAgAFAAgIDiFcNABSAgAAAA==.',['腐国']='腐国大西瓜:BAAAKgAECgQIBAAAAA==.',['舆龍']='舆龍共舞:BAAAKgAECgYIBgAAAA==.',['艾尔']='艾尔奎特:BAAAKgAECgcICgAAAA==.',['芯芯']='芯芯:BAABKgAFFH8UAAMEAAQIrRgHEgDSAAAEAAQIrRgHEgDSAAAKAAEI5QnuRQA7AAAAAA==.',['花村']='花村如梦:BAAAKgADCgEIAQAAAA==.花村清洁工:BAAAKgAECgYIBgAAAA==.花村的杏痒:BAAAKgAECgUICAAAAA==.',['若艳']='若艳:BAAAKgAECgUIBQAAAA==.',['菊籽']='菊籽:BAAAKgAECgIIAgAAAA==.',['菲特']='菲特塔罗莎:BAABKgAFFH8GAAIXAAYIjQGQFwDqAAAXAAYIjQGQFwDqAAAAAA==.',['萌工']='萌工:BAAAKgADCggICAAAAA==.',['萨鲁']='萨鲁灬曼:BAAAKgAFFAEIAQAAAA==.',['蒹丶']='蒹丶葭:BAABKgAFFH8VAAMLAAYIpyJxAwDYAQALAAYIeB5xAwDYAQAKAAYIlR1ADwB1AQAAAA==.',['蓁蓁']='蓁蓁丷:BAAAKgAECgEIAQAAAA==.',['薄荷']='薄荷烧仙草:BAAAKgAECgUIBQABKgAFFAgIIgAdAL8eAA==.',['藏而']='藏而内敛锋芒:BAACKgAFFH8GAAIMAAYIIx2FEgCIAQAMAAYIIx2FEgCIAQAqAAQKfxcAAh4ACAiNHGEDADACAB4ACAiNHGEDADACAAAA.',['虚空']='虚空打火机:BAAAKgAECgQIBQAAAA==.',['虚黑']='虚黑城烤肉:BAAAKgAECgQIBAAAAA==.',['蛋蛋']='蛋蛋不太傲娇:BAAAKgAECgUIBwAAAA==.',['蠢胖']='蠢胖子:BAABKgAFFH8GAAISAAYITh6VAQDvAQASAAYITh6VAQDvAQAAAA==.',['血弑']='血弑:BAAAKgAFFAIIAgAAAA==.',['褲儅']='褲儅悝有殺暣:BAAAKgAECgIIAgAAAA==.',['西瓜']='西瓜酱:BAAAKgAECggIBAAAAA==.',['西雅']='西雅図夜未眠:BAAAKgAECgcIDgAAAA==.西雅圖夜未眠:BAAAKgAECgQIBAAAAA==.西雅圗不眠夜:BAAAKgAECgQIBAAAAA==.',['请跟']='请跟我姓焦:BAAAKgADCgMIAwAAAA==.',['贰魃']='贰魃垨丶咕天:BAABKgAFFH8MAAMZAAYI0RQBAgB+AQAZAAYI0RQBAgB+AQAFAAYIqwZ1MQAjAQAAAA==.',['赛弗']='赛弗里德:BAAAKgAFFAQIBAAAAA==.',['超级']='超级好吃:BAABKgAFFH8IAAIZAAMIORd3FgDEAAAZAAMIORd3FgDEAAAAAA==.',['路在']='路在丶何方:BAABKgAFFH8oAAISAAgIJBkQBgBGAgASAAgIJBkQBgBGAgAAAA==.',['跳舞']='跳舞的咕咕:BAAAKgADCgEIAQAAAA==.',['辰辰']='辰辰:BAAAKgAECgIIAQAAAA==.',['过的']='过的魅魔:BAAAKgAECgIIAgAAAA==.',['逐月']='逐月清风:BAABKgAFFH8KAAMPAAYIBCJNHgCqAAAPAAQIiA9NHgCqAAANAAYIBCIAAAAAAAAAAA==.',['逐焱']='逐焱者明:BAABKgAFFH8IAAIHAAII7h1/HgB/AAAHAAII7h1/HgB/AAAAAA==.',['道古']='道古一指:BAAAKgADCgYIBgAAAA==.',['都是']='都是泪:BAABKgAFFH8FAAIQAAUIWxA3EAAOAQAQAAUIWxA3EAAOAQAAAA==.',['都灵']='都灵彩虹:BAAAKgADCgcIBwAAAA==.',['酱油']='酱油法:BAAAKgADCgEIAQAAAA==.',['醉梦']='醉梦仙霖:BAABKgAFFH8JAAIVAAMIJA9QLgC0AAAVAAMIJA9QLgC0AAAAAA==.',['采矿']='采矿学训练师:BAAAKgAFFAQIBAAAAA==.',['重生']='重生之剑来:BAAAKgADCggICAAAAA==.',['钉崎']='钉崎丶野蔷薇:BAABKgAFFH8GAAIaAAYI2h8qAQDxAQAaAAYI2h8qAQDxAQAAAA==.',['闪电']='闪电猫:BAAAKgAECggICwAAAA==.',['阎煌']='阎煌枷炎:BAAAKgAECgMIAwAAAA==.',['阔海']='阔海小法:BAAAKgADCgIIAgAAAA==.',['阿予']='阿予:BAAAKgADCgEIAQAAAA==.',['阿弥']='阿弥陀佛:BAABKgAECn8VAAMiAAgI9BLZEAAxAQAiAAcIsBHZEAAxAQAYAAcIgQ1oMwAKAQAAAA==.',['阿路']='阿路灬:BAAAKgAFFAgIBAAAAA==.',['陋夜']='陋夜过东莞:BAAAKgAFFAMIAwAAAA==.',['随便']='随便一插:BAAAKgAECgUIBQAAAA==.',['雄起']='雄起勇敢牛牛:BAAAKgAECggIDAAAAA==.',['雪糕']='雪糕刺客:BAAAKgAFFAIIAgAAAA==.',['雾之']='雾之守护者:BAAAKgAECggICAAAAA==.',['霜语']='霜语:BAAAKgAFFAMIBAAAAA==.',['霸王']='霸王別急:BAAAKgADCggICAAAAA==.霸王龟龟:BAAAKgAECgcIEQAAAA==.',['面条']='面条呱:BAAAKgAECgEIAQAAAA==.',['领萨']='领萨:BAAAKgAFFAQIBAAAAA==.',['颠颠']='颠颠大魔王:BAAAKgAFFAIIAgAAAA==.',['風雲']='風雲啸:BAABKgAFFH8GAAIIAAYIgAoRHwASAQAIAAYIgAoRHwASAQAAAA==.',['风一']='风一样飘:BAACKgAFFH8sAAIFAAQIxB+MIADoAAAFAAQIxB+MIADoAAAqAAQKfyEAAgUACAi6HjFNAAoCAAUACAi6HjFNAAoCAAAA.',['风之']='风之圣痕:BAAAKgADCgYIBgAAAA==.',['风怜']='风怜:BAAAKgAECgUIBwAAAA==.',['风舞']='风舞惊雷:BAAAKgAFFAMIAwAAAA==.',['风蛟']='风蛟之怒:BAAAKgADCgIIBAAAAA==.',['飞过']='飞过苍海:BAAAKgAECgcICQAAAA==.',['飞飞']='飞飞让人:BAABKgAFFH8IAAIXAAYI0R9sDQDQAAAXAAYI0R9sDQDQAAAAAA==.',['饺子']='饺子:BAAAKgAECgEIAQAAAA==.',['马蓉']='马蓉:BAAAKgAECggICAAAAA==.',['鸿海']='鸿海:BAAAKgADCgEIAQAAAA==.',['麦子']='麦子茶:BAAAKgAECggICAAAAA==.',['黎明']='黎明之剑:BAAAKgAECgQIBgAAAA==.',['黑色']='黑色沉沦:BAACKgAFFH8UAAQHAAYISSJxBQAfAQAHAAQI3yJxBQAfAQAIAAYIphjLEAAYAQAlAAII4RjkAgCjAAAqAAQKfy8AAwcACAhdHKkQAMEBAAcACAhSGKkQAMEBAAgABwjYGatTALYBAAAA.',['黑铁']='黑铁骑:BAAAKgAECgEIAQAAAA==.',['黛朵']='黛朵的悲歌:BAAAKgAFFAYIAwABKgAFFAgICAAFAC8jAA==.',['齐晏']='齐晏:BAAAKgAECggIEAAAAA==.',['龙舌']='龙舌蓝:BAAAKgADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end