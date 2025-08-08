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
 local lookup = {'Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Warrior-Fury','DeathKnight-Blood','Shaman-Restoration','Monk-Mistweaver','Unknown-Unknown','Paladin-Protection','Mage-Fire','Mage-Arcane','DemonHunter-Havoc','Paladin-Retribution','Rogue-Assassination','Rogue-Subtlety','Mage-Ranged','Hunter-BeastMastery','Priest-Shadow','Mage-Frost','Monk-Windwalker','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Hunter-Marksmanship','DeathKnight-Frost','Warrior-Arms','Druid-Balance','Druid-Guardian','Druid-Restoration','Shaman-Elemental','Shaman-Enhancement','Paladin-Holy','Warrior-Protection','Druid-Feral','Monk-Brewmaster',}; local provider = {region='CN',realm='玛洛加尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ae='Aenaiu:BAABKgAFFH8GAAMBAAYITRLPCwD2AAABAAQIzRnPCwD2AAACAAIIDAfnLwCGAAAAAA==.',Al='Alleriä:BAAAKgADCgcIBwAAAA==.',An='Anemone:BAAAKgAECggIAwAAAA==.Animone:BAABKgAFFH8TAAIDAAgIVh5gAwCMAgADAAgIVh5gAwCMAgAAAA==.',Be='Beyourmyth:BAAAKgAFFAYIBAAAAA==.',Bi='Bigtrouble:BAAAKgAECggIDwAAAA==.',Bo='Bomber:BAAAKgAECggICAAAAA==.',Ch='Cherles:BAAAKgAECgYIBgAAAA==.Cherryfox:BAAAKgADCggIEAAAAA==.',Cl='Clawdryad:BAAAKgAECgIIAgAAAA==.',Da='Daylight:BAAAKgAECggICAABKgAFFAgICwAEAI4YAA==.',De='Demontwo:BAAAKgAFFAYIBAABKgAFFAgICAAFAL0eAA==.',Dr='Drla:BAAAKgAECggICAAAAA==.',Dw='Dwcbc:BAAAKgAECgQIBAAAAA==.',Es='Esen:BAAAKgAECgYICAAAAA==.',Fe='Feuilletee:BAABKgAFFH8IAAIGAAgIShCVBgC8AQAGAAgIShCVBgC8AQAAAA==.',Fi='Fiercewind:BAAAKgAECggICQAAAA==.',Ga='Gayi:BAACKgAFFH8HAAIHAAMIThGQHwCnAAAHAAMIThGQHwCnAAAqAAQKfxQAAgcABwifEbcwABoBAAcABwifEbcwABoBAAAA.',Ge='Geminorum:BAABKgAFFH8MAAIEAAYILRkLDACKAQAEAAYILRkLDACKAQAAAA==.',Ha='Harley:BAAAKgADCggICAAAAA==.Hathaway:BAAAKgADCggICgAAAA==.',Ho='Horebb:BAAAKgAECgcICwAAAA==.',Ih='Ihsekat:BAAAKgAFFAQIBAABKgAFFAgIBAAIAAAAAA==.',In='Invu:BAABKgAFFH8GAAIJAAYIyBREDAAyAQAJAAYIyBREDAAyAQAAAA==.',Ji='Jimmorrison:BAABKgAFFH8GAAICAAYIRAehFAAOAQACAAYIRAehFAAOAQAAAA==.',Ka='Kakalotes:BAAAKgAECgEIAQAAAA==.Kakoe:BAAAKgAFFAYIAQAAAA==.',Kk='Kkid:BAAAKgADCgQIBAAAAA==.',Kr='Krizy:BAABKgAFFH8GAAIDAAYIQxVxEgCHAQADAAYIQxVxEgCHAQAAAA==.',La='Laneve:BAAAKgAFFAgIBAAAAA==.',Li='Liepriest:BAAAKgAECggIDwAAAA==.Littlepoint:BAAAKgAECggIDQAAAA==.',Lo='Lovee:BAAAKgAFFAQIBAAAAA==.',Lx='Lxx:BAAAKgAECgMIAwAAAA==.',Ma='Magemiku:BAAAKgAECgUIBQAAAA==.Magerong:BAABKgAFFH8cAAMKAAYI0iQ+AQAxAgAKAAYI0iQ+AQAxAgALAAEI7AWORwA0AAAAAA==.',Mi='Mitsui:BAABKgAFFH8IAAIMAAgIxBBICQD8AQAMAAgIxBBICQD8AQAAAA==.',Nb='Nbstar:BAABKgAFFH8dAAINAAYIqxjYGwCFAQANAAYIqxjYGwCFAQAAAA==.',Ne='Neverheal:BAAAKgADCggICAAAAA==.',Ol='Olivine:BAACKgAFFH8WAAMOAAgIxiEhAgCyAgAOAAgIxiEhAgCyAgAPAAEICAdoCABIAAAqAAQKfxQAAw4ACAjgHVsKAG0CAA4ACAjgHVsKAG0CAA8AAwihEesqAJwAAAAA.',Pa='Pasir:BAAAKgAFFAMIAwAAAA==.',Pl='Playerffqkzb:BAAAKgAECgYICQAAAA==.Playerzvlfgo:BAAAKgAECgcIDQAAAA==.',Re='Revolutionar:BAAAKgAECggICAAAAA==.',Sa='Samllsam:BAAAKgAECgcIBwAAAA==.',Se='Selfishness:BAABKgAFFH8FAAIDAAUIVBR6FgBpAQADAAUIVBR6FgBpAQAAAA==.',Sh='Shaoco:BAAAKgADCggIDAAAAA==.',St='Struers:BAAAKgAECgUIBQAAAA==.',Sy='Syliva:BAAAKgAECgQIBAAAAA==.',Ul='Ula:BAABKgAFFH8GAAIQAAYIEggAAAAAAAAKAAYIEggAAAAAAAAAAA==.',Wi='Wickey:BAABKgAFFH8HAAIMAAQICR6BFgBGAQAMAAQICR6BFgBGAQAAAA==.Wicky:BAABKgAFFH8GAAIFAAYIkBRhCwBbAQAFAAYIkBRhCwBbAQAAAA==.',Ya='Yang:BAAAKgAECgQIBAAAAA==.',Yi='Yilidannufen:BAAAKgAECgEIAQAAAA==.',['一世']='一世无橙丶:BAAAKgADCgMIAwAAAA==.',['一切']='一切如烟:BAABKgAFFH8HAAIRAAcI8hGOFgBDAQARAAcI8hGOFgBDAQAAAA==.',['一只']='一只大老虎:BAABKgAFFH8HAAMSAAcIfQ+9CQBJAQASAAYI9Qy9CQBJAQACAAEIHgv/HgBCAAAAAA==.',['一束']='一束小喷菇:BAACKgAFFH8JAAITAAMI1hJpFADFAAATAAMI1hJpFADFAAAqAAQKfx0AAhMACAj9FYMiAJ8BABMACAj9FYMiAJ8BAAAA.',['一生']='一生情:BAAAKgAFFAYIBAABKgAFFAgICAARAHkgAA==.',['一粒']='一粒卤蛋:BAABKgAFFH8GAAIMAAYITA6tFQBNAQAMAAYITA6tFQBNAQAAAA==.',['丁长']='丁长长:BAAAKgAECggICAAAAA==.',['七彩']='七彩坏坏:BAAAKgAECgIIAwAAAA==.',['七濑']='七濑:BAABKgAFFH8GAAIDAAYIUQ9SGABbAQADAAYIUQ9SGABbAQAAAA==.',['万古']='万古于心:BAAAKgADCgUIBQAAAA==.',['不会']='不会射门:BAAAKgADCggICAAAAA==.',['专抢']='专抢狗狗嗗头:BAAAKgAECgUIBQAAAA==.',['东皇']='东皇太一:BAAAKgAFFAEIAQAAAA==.',['丨丶']='丨丶小白:BAAAKgADCgEIAQAAAA==.',['丨元']='丨元気喵丨:BAAAKgAECgQIBAAAAA==.丨元気贼丨:BAAAKgADCgEIAQAAAA==.丨元気骑丨:BAAAKgAECgQIAwAAAA==.',['丨剑']='丨剑来丨:BAAAKgAECgQIBAAAAA==.',['丨尾']='丨尾上若叶丨:BAAAKgAECggIAQAAAA==.',['丶一']='丶一叽咕:BAAAKgADCgEIAQAAAA==.',['丶小']='丶小残暴:BAABKgAFFH8OAAMFAAQIaiLNCwDkAAADAAQIaiIjEAD5AAAFAAQI+xjNCwDkAAAAAA==.',['丶恶']='丶恶魔猎:BAAAKgADCggICAAAAA==.',['丶梦']='丶梦见:BAAAKgAECgMIAQAAAA==.',['丶聖']='丶聖騎:BAABKgAECn8UAAINAAgInhqtjgB6AQANAAgInhqtjgB6AQAAAA==.',['丶萨']='丶萨戈拉斯:BAAAKgAFFAgIBAAAAA==.',['丶豆']='丶豆豆:BAAAKgAECgQIBwAAAA==.',['丶選']='丶選擇遺莣灬:BAAAKgADCgIIAgAAAA==.',['丶香']='丶香菜丶:BAAAKgAECgYIEQAAAA==.',['丹丹']='丹丹的沙漏:BAAAKgAECgMIBQAAAA==.',['丿但']='丿但愿活长久:BAABKgAFFH8GAAITAAYI1STPAQAVAgATAAYI1STPAQAVAgAAAA==.',['丿弑']='丿弑神丶地震:BAABKgAFFH8IAAIUAAQILBbQCgDnAAAUAAQILBbQCgDnAAAAAA==.',['乃王']='乃王:BAABKgAECn8iAAMMAAgIrhwWHQAaAgAMAAgIrRoWHQAaAgAVAAUIug9bRACeAAAAAA==.',['之狼']='之狼:BAAAKgAECggICAAAAA==.',['乌拉']='乌拉堤:BAABKgAFFH8OAAMWAAgIoBnlBQA4AgAWAAgIoBnlBQA4AgAXAAIIAgfpLQA/AAABKgAFFAgIJQAYACEcAA==.',['九倍']='九倍速的子路:BAAAKgAFFAYIBAAAAA==.',['九月']='九月丶那些年:BAABKgAFFH8IAAIZAAMIYRiuJADaAAAZAAMIYRiuJADaAAAAAA==.',['也曾']='也曾痴狂:BAAAKgADCggICgAAAA==.',['二月']='二月灬霜叶:BAAAKgADCggICAAAAA==.',['云殊']='云殊:BAABKgAFFH8GAAMaAAIIcxCMBgCHAAAaAAIIlAiMBgCHAAADAAIIcxDTRgCFAAAAAA==.',['云间']='云间月:BAABKgAFFH8IAAMLAAgI7QA3OACBAAALAAQIPwE3OACBAAATAAQIgAA9KwA9AAAAAA==.',['五根']='五根香蕉:BAAAKgADCggICAAAAA==.',['亚瑟']='亚瑟丶兰斯洛:BAAAKgAFFAQIBAAAAA==.',['亦如']='亦如:BAAAKgAECgQIBAAAAA==.',['人倒']='人倒势不倒:BAAAKgAECggICwABKgAFFAQIBwANAKQaAA==.',['人字']='人字拖押:BAAAKgAECgcICwAAAA==.',['从前']='从前有个木子:BAAAKgADCggICAAAAA==.从前有个讠午:BAAAKgADCgcIBwAAAA==.',['仙剑']='仙剑奇豆传:BAAAKgADCgQIBAAAAA==.',['伊集']='伊集院隼人:BAACKgAFFH8MAAMbAAYIohbDCgBgAQAbAAYIQRTDCgBgAQAEAAYINQ5iDwBfAQAqAAQKfxYAAgQACAjTEYEjALoBAAQACAjTEYEjALoBAAAA.',['休闲']='休闲玩家丙:BAAAKgADCgQIBAAAAA==.',['众生']='众生灬之灵:BAAAKgADCgYIBgAAAA==.众生颤抖:BAAAKgAECggICAAAAA==.',['传送']='传送失败:BAAAKgAECggIDgAAAA==.',['伤似']='伤似水库:BAABKgAFFH8GAAIMAAYIoANJFADsAAAMAAYIoANJFADsAAAAAA==.',['伯爵']='伯爵哥:BAAAKgAECgYIBwAAAA==.',['低头']='低头思故鄕:BAABKgAFFH8QAAMNAAYIBiWWCAA5AQANAAYI/heWCAA5AQAJAAYI+CRSFwC9AAAAAA==.',['你想']='你想去哪里:BAAAKgAFFAgIBAAAAA==.',['你贩']='你贩剑嘛:BAABKgAFFH8HAAIEAAQIbxdaDwD9AAAEAAQIbxdaDwD9AAAAAA==.',['依然']='依然飯特稀丶:BAAAKgAECggIDwAAAA==.',['俺叫']='俺叫魏淑芬:BAAAKgAECgUIBAAAAA==.',['偷心']='偷心贼:BAAAKgAECgMIBQAAAA==.',['元素']='元素萨满:BAAAKgAFFAIIAgABKgAFFAgIBgANADgYAA==.',['光头']='光头墙:BAACKgAFFH8IAAINAAMIKhaEIgDjAAANAAMIKhaEIgDjAAAqAAQKfyQAAg0ACAg1IQgzAFcCAA0ACAg1IQgzAFcCAAAA.',['光明']='光明黑牛:BAAAKgAECgUICAAAAA==.',['六哥']='六哥丶:BAAAKgAFFAMIAwAAAA==.',['冈崎']='冈崎朋也丶:BAABKgAFFH8RAAIcAAgIGxw5BgBPAgAcAAgIGxw5BgBPAgAAAA==.',['再别']='再别康桥:BAAAKgAECgUIBQAAAA==.',['冬姐']='冬姐来了:BAABKgAFFH8JAAMZAAYIoxhSDACTAQAZAAYIoxhSDACTAQARAAIIXQTwUwBeAAAAAA==.',['冬灬']='冬灬:BAAAKgAECgUIBQAAAA==.',['冰镇']='冰镇菊花茶:BAAAKgAECgYIEAAAAA==.',['冲绳']='冲绳奴隶岛:BAABKgAECn8ZAAIEAAgIARmhDQDGAQAEAAgIARmhDQDGAQAAAA==.',['冲锋']='冲锋撞到猪:BAAAKgAECgMIAwAAAA==.',['凤翔']='凤翔九天:BAAAKgADCggICAAAAA==.',['初夏']='初夏浮生若梦:BAAAKgAFFAYIAgAAAA==.',['别问']='别问糖门滚:BAAAKgADCggICgAAAA==.',['加肥']='加肥猫:BAAAKgAECgIIAgAAAA==.',['加藤']='加藤惠:BAABKgAFFH8FAAMKAAUICQpMKQCnAAAKAAIIoglMKQCnAAATAAMITgqMHgCRAAABKgAFFAgIGAABAOgeAA==.',['劳阿']='劳阿柏:BAAAKgAFFAQIAgABKgAECggIIwAEACcfAA==.',['北纬']='北纬四十七度:BAABKgAFFH8MAAMZAAYIwCJuBwDrAQAZAAYIAyJuBwDrAQARAAYIjx48DACsAQAAAA==.',['十多']='十多亿个骑士:BAAAKgAECgEIAQAAAA==.',['十足']='十足十梁朝伟:BAAAKgAFFAQIBAAAAA==.',['午夜']='午夜飞鱼:BAABKgAECn8hAAIEAAgInR/lDgCPAgAEAAgInR/lDgCPAgAAAA==.',['半夏']='半夏丶微凉:BAAAKgAECggICAAAAA==.',['卡加']='卡加德之滣:BAACKgAFFH8LAAIcAAQIrgYxJQCRAAAcAAQIrgYxJQCRAAAqAAQKfycAAxwACAjHFLZEAJcBABwACAjHFLZEAJcBAB0AAgjhBvMvADMAAAAA.',['卡西']='卡西亚斯:BAAAKgADCggICAAAAA==.',['双刀']='双刀丶:BAAAKgAECgIIAgAAAA==.双刀走天涯:BAAAKgAECgYIBgAAAA==.',['叛逆']='叛逆厸今生:BAAAKgAECgYIAQAAAA==.',['古三']='古三蛋子:BAAAKgAECgEIAQAAAA==.',['古二']='古二丹二世:BAABKgAFFH8IAAIWAAgILREQBgATAgAWAAgILREQBgATAgAAAA==.',['古利']='古利特:BAAAKgAECgYIBgAAAA==.',['只抽']='只抽长嘴利群:BAAAKgAECggICAAAAA==.',['可爱']='可爱到爆:BAAAKgAECgYICgAAAA==.',['叶临']='叶临渊:BAABKgAFFH8MAAQBAAYIiCFQDABQAQABAAQI0CZQDABQAQACAAQIoQ1pDgDJAAASAAMIYh2FFgDHAAAAAA==.',['名字']='名字很头痛:BAAAKgAFFAgIBAAAAA==.',['吼尼']='吼尼蟹特:BAAAKgAECgIIAgAAAA==.',['呆萌']='呆萌丶亨特:BAAAKgAECgQIBAAAAA==.',['告辞']='告辞:BAABKgAFFH8GAAILAAYIqBXWEABiAQALAAYIqBXWEABiAQAAAA==.',['周子']='周子柒小可爱:BAABKgAFFH8IAAMWAAcIrRrcCwDQAQAWAAcIrRrcCwDQAQAXAAEIthI9JgBNAAAAAA==.',['周弢']='周弢啊:BAAAKgAECgIIAgAAAA==.',['咕喵']='咕喵:BAABKgAFFH8YAAMcAAcIYR46BwAxAgAcAAcIYR46BwAxAgAeAAYIkBiTBgCtAQAAAA==.',['哇哈']='哇哈哈嘻嘻:BAACKgAFFH8JAAIGAAMIyhf+LADDAAAGAAMIyhf+LADDAAAqAAQKfywAAwYACAioGVQ1ALEBAAYACAioGVQ1ALEBAB8AAwiMCVtpAFoAAAAA.',['哒哒']='哒哒嗒丶打劫:BAABKgAFFH8UAAIMAAgIihv9BABmAgAMAAgIihv9BABmAgAAAA==.',['哔哔']='哔哔壮吖丶:BAAAKgAECgUIBQAAAA==.哔哔痒丶:BAAAKgAECgIIAgAAAA==.',['哟喂']='哟喂跑得快噢:BAABKgAFFH8IAAIMAAQIlQVTOQCaAAAMAAQIlQVTOQCaAAAAAA==.',['哦来']='哦来呀:BAAAKgAECgUIBgAAAA==.',['哪个']='哪个丶戦士:BAAAKgAECgYICwAAAA==.',['唐牛']='唐牛:BAAAKgAFFAgIAgAAAA==.唐牛才系食神:BAABKgAFFH8FAAIcAAMI/AIqUwBrAAAcAAMI/AIqUwBrAAAAAA==.',['唔战']='唔战:BAAAKgADCggICAAAAA==.',['啊噗']='啊噗噜派:BAAAKgAECgIIAgAAAA==.',['喚靈']='喚靈者丶:BAAAKgAECggICAAAAA==.',['嗄嗄']='嗄嗄:BAABKgAECn8bAAIMAAgIZwsjYwAaAQAMAAgIZwsjYwAaAQAAAA==.',['嗨呀']='嗨呀好气呀:BAAAKgAECgEIAQAAAA==.',['噬魔']='噬魔帝君:BAABKgAECn8bAAITAAgI/hJRDQCmAQATAAgI/hJRDQCmAQAAAA==.',['回家']='回家做饭:BAAAKgAECgYIBgAAAA==.',['团团']='团团饲养员:BAAAKgAECgEIAQAAAA==.',['国服']='国服第一盲僧:BAAAKgADCgIIAgAAAA==.',['圆腰']='圆腰:BAAAKgAECgMIAwAAAA==.',['圣光']='圣光永恒者:BAABKgAECn83AAINAAgIjiFnHACSAgANAAgIjiFnHACSAgAAAA==.圣光玛卖花:BAABKgAFFH8FAAINAAUIMBzsKwA3AQANAAUIMBzsKwA3AQAAAA==.',['圣殿']='圣殿风:BAABKgAFFH8QAAMJAAgItha/BQDWAQAJAAgI2BW/BQDWAQANAAQIphTlMwCiAAAAAA==.圣殿骑士丨殇:BAAAKgAFFAYIAgAAAA==.',['地狱']='地狱跑调:BAAAKgADCgcIBwAAAA==.',['坤拳']='坤拳掌教:BAAAKgAECgQICAAAAA==.',['埃辛']='埃辛诺思:BAAAKgAFFAIIAgAAAA==.',['埴安']='埴安神袿姫:BAACKgAFFH8aAAMfAAYI2iMaAwAYAgAfAAYIySMaAwAYAgAgAAYI3xQ2CQAGAQAqAAQKfyAAAyAACAinJfgCAOwCACAACAinJfgCAOwCAB8AAwihIpQ8ABwBAAEqAAUUCAgGAB8AmBQA.',['堕落']='堕落竞技场:BAAAKgADCggICAAAAA==.',['墮天']='墮天女武神:BAAAKgADCggIEAAAAA==.',['壹伍']='壹伍贰拾:BAAAKgAECgYICgAAAA==.',['夏枫']='夏枫:BAAAKgADCgYIBgAAAA==.',['夕晖']='夕晖:BAAAKgAECggIEgAAAA==.',['夙一']='夙一:BAABKgAFFH8IAAINAAgI2hlXBwBSAgANAAgI2hlXBwBSAgAAAA==.',['多娜']='多娜多娜:BAAAKgADCggIEAAAAA==.',['夜丶']='夜丶亡者叹息:BAAAKgADCggICAAAAA==.',['夜之']='夜之优菈:BAAAKgADCggICAAAAA==.',['夜灬']='夜灬月眠:BAAAKgAFFAIIAgAAAA==.',['夜露']='夜露死酷:BAAAKgAECggICAAAAA==.',['大丶']='大丶瓜皮:BAAAKgAECgMIAwAAAA==.',['大猩']='大猩猩:BAAAKgAFFAEIAQAAAA==.',['大耳']='大耳朵图图:BAAAKgAECgYIDQAAAA==.',['大脑']='大脑虎:BAAAKgAFFAYIAgAAAA==.',['大雪']='大雪:BAAAKgAECgEIAQAAAA==.',['大饼']='大饼:BAAAKgAECgEIAQAAAA==.',['大鼻']='大鼻子绿脑袋:BAABKgAFFH8IAAMCAAQIqAo2GgB+AAACAAMIyw82GgB+AAASAAEI4gMZKQA/AAAAAA==.',['天之']='天之边:BAAAKgAECgYICgAAAA==.',['天堂']='天堂制造:BAAAKgADCggICAAAAA==.',['天天']='天天的泡泡糖:BAAAKgAECggIEQAAAA==.',['天授']='天授唱诗人:BAAAKgADCgQIBAAAAA==.',['天涯']='天涯小小酥:BAABKgAFFH8GAAIcAAYIsQ+WEABfAQAcAAYIsQ+WEABfAQAAAA==.天涯执念:BAAAKgAFFAgIBAAAAA==.',['太默']='太默默被遗忘:BAAAKgAFFAIIAwAAAA==.',['奈文']='奈文灬魔尔:BAAAKgAFFAQIBAAAAA==.',['女装']='女装山脉:BAAAKgADCggIEAAAAA==.',['奶糖']='奶糖哲学:BAABKgAFFH8QAAMNAAgIRxkXFQCzAQANAAUIjR4XFQCzAQAJAAgIaRCfBgB2AQAAAA==.',['如是']='如是丶我闻:BAAAKgADCgIIAgAAAA==.',['妮妮']='妮妮迷迷:BAAAKgADCgYIBgAAAA==.',['孙贰']='孙贰娘:BAAAKgAFFAQIBAAAAA==.',['安之']='安之神:BAAAKgADCgcICAAAAA==.',['宾利']='宾利也将就:BAACKgAFFH8fAAMbAAYIkyH7BQDBAQAbAAYIkyH7BQDBAQAEAAEIAABjPQAAAAAqAAQKfygAAhsACAhlI9cIAIoCABsACAhlI9cIAIoCAAAA.',['寒霜']='寒霜气息:BAAAKgADCggICAAAAA==.',['对魔']='对魔忍:BAAAKgADCggICQAAAA==.',['小丑']='小丑勿语:BAAAKgAFFAIIAgAAAA==.',['小丶']='小丶幸運:BAABKgAFFH8KAAIKAAYISBrwIADTAAAKAAYISBrwIADTAAAAAA==.',['小啡']='小啡丶:BAAAKgAECggICAAAAA==.',['小囧']='小囧囧兔:BAACKgAFFH8SAAMBAAMIpRY4GgDBAAABAAMI7hU4GgDBAAACAAMIBhDHJwCjAAAqAAQKfx0AAwIACAiLEC09ACEBAAIACAgGDy09ACEBAAEABQhyCEV5AGMAAAAA.',['小宝']='小宝吃火锅:BAABKgAECn8dAAICAAgISBRqKACsAQACAAgISBRqKACsAQABKgAFFAYIAgAIAAAAAA==.',['小小']='小小虫:BAAAKgAFFAQIBAAAAA==.',['小麦']='小麦乀:BAAAKgADCgIIAgAAAA==.',['山河']='山河:BAAAKgAECgQIBAAAAA==.山河漫游者:BAAAKgADCggICAAAAA==.',['山海']='山海观雾:BAABKgAFFH8IAAINAAgIoBkABwBIAgANAAgIoBkABwBIAgAAAA==.',['岆顔']='岆顔惑衆:BAAAKgAFFAEIAQAAAA==.',['岚五']='岚五:BAAAKgAECgUIBgAAAA==.',['岚兄']='岚兄:BAAAKgAECggICAAAAA==.',['岚弟']='岚弟:BAABKgAECn8hAAMHAAgIUg18LgAoAQAHAAgIUg18LgAoAQAUAAYICw4ZQwD9AAAAAA==.',['崔丞']='崔丞相觐见:BAAAKgAFFAIIAgAAAA==.',['巧克']='巧克力与香草:BAAAKgAECgcIBwAAAA==.',['巨滑']='巨滑大:BAAAKgAECggIDwAAAA==.',['巴扎']='巴扎黑大王:BAAAKgAFFAgIAgAAAA==.',['巴拉']='巴拉巴巴拉:BAABKgAFFH8MAAMNAAQIaSHOGQD3AAANAAQIaSHOGQD3AAAhAAMI+RLEDgCIAAAAAA==.',['帝罗']='帝罗:BAAAKgAECgYIBwAAAA==.',['幸福']='幸福丶是滴滴:BAAAKgADCggIEAAAAA==.',['张哓']='张哓花:BAAAKgAECgYIDAAAAA==.',['彼岸']='彼岸过客:BAAAKgAECggICAAAAA==.',['微笑']='微笑灬路人甲:BAAAKgADCgcIBwAAAA==.',['德的']='德的奶也有毒:BAACKgAFFH8NAAMcAAQIWxc5GADdAAAcAAQIWxc5GADdAAAeAAMIlBO8DgCmAAAqAAQKfxQAAxwACAjOFXopAAkBABwABAijFHopAAkBAB4ABwgaE2NPAM8AAAAA.',['快乐']='快乐射手:BAAAKgAECgMICQAAAA==.快乐必杀:BAAAKgADCgQIBAAAAA==.',['怀念']='怀念丶:BAAAKgAECgEIAQAAAA==.',['性感']='性感的奶爸:BAAAKgAECgEIAQAAAA==.',['恐怖']='恐怖老奶:BAAAKgAECgIIAgAAAA==.',['恰雪']='恰雪来故:BAABKgAFFH8SAAQCAAgIORdvBQDDAQACAAgIORdvBQDDAQABAAQI6w8JDwAtAQASAAEI0gEOGwA5AAAAAA==.',['恶来']='恶来:BAAAKgAECgIIAgAAAA==.',['悦姑']='悦姑娘:BAAAKgAECggIDgAAAA==.',['情傷']='情傷:BAACKgAFFH8IAAIGAAQI/glTOQCdAAAGAAQI/glTOQCdAAAqAAQKfxQAAgYACAgfEJJNAFYBAAYACAgfEJJNAFYBAAAA.',['情绪']='情绪零碎丶:BAAAKgAECgYIBgAAAA==.',['愢愢']='愢愢丨嘂嘂:BAABKgAFFH8PAAIEAAMI8BMLHADkAAAEAAMI8BMLHADkAAAAAA==.',['慧影']='慧影舞:BAAAKgAECgMIAwAAAA==.',['慧訫']='慧訫:BAAAKgAECgUIBQAAAA==.',['慧风']='慧风倩影:BAAAKgAECgQIBQAAAA==.',['我不']='我不心虚:BAAAKgAFFAYIAgABKgAFFAgIDgAOAMkbAA==.',['我吃']='我吃土:BAABKgAFFH8MAAIRAAMIlhOdMADJAAARAAMIlhOdMADJAAAAAA==.',['我喂']='我喂你农药:BAAAKgAECgIIAgAAAA==.',['我太']='我太想进步了:BAAAKgAFFAYIBAABKgAFFAgIGAALAOchAA==.',['我好']='我好了:BAABKgAFFH8IAAMbAAQIzxTuGQC7AAAbAAQIYhDuGQC7AAAEAAQIbw9WKwCVAAAAAA==.',['我最']='我最近怪好:BAAAKgAECgQIBAAAAA==.我最近挺好:BAAAKgADCgEIAQAAAA==.',['我要']='我要充钱:BAABKgAFFH8GAAICAAYIiQpfEgAfAQACAAYIiQpfEgAfAQAAAA==.',['战斗']='战斗小鱼人:BAABKgAFFH8RAAMKAAYI2Rl8DQBhAQAKAAYI0hZ8DQBhAQALAAUIQBpmGQAYAQAAAA==.',['战术']='战术性天使:BAAAKgAECgQIAQAAAA==.',['战神']='战神龙飞:BAAAKgAECgQIBAAAAA==.',['打不']='打不赢扯鬍子:BAAAKgAECgMIAwAAAA==.打不过我先闪:BAAAKgAECgcIDAAAAA==.',['抓只']='抓只小德:BAAAKgAECgcIEgAAAA==.',['抠脚']='抠脚大汉:BAAAKgAECgYICAAAAA==.',['披着']='披着凉皮的狼:BAAAKgADCggICgAAAA==.',['抹茶']='抹茶桃子:BAAAKgAECgMIAwAAAA==.',['持斧']='持斧:BAABKgAFFH8IAAIbAAgIqRZKAgBVAgAbAAgIqRZKAgBVAgAAAA==.',['挨打']='挨打职业:BAAAKgADCggICgAAAA==.',['摇摇']='摇摇加晃晃:BAAAKgADCggIDAAAAA==.',['摇曳']='摇曳的马尾辫:BAAAKgAFFAIIAgAAAA==.',['摩多']='摩多羅隠岐奈:BAABKgAFFH8bAAIDAAUI8SCfEwB9AQADAAUI8SCfEwB9AQAAAA==.',['撒卡']='撒卡拉斯:BAAAKgAECggICAABKgAFFAgIEwAcAHMfAA==.',['断了']='断了的弦丶:BAABKgAFFH8GAAIGAAYICxP2CwA7AQAGAAYICxP2CwA7AQAAAA==.',['断水']='断水牛大师兄:BAAAKgAFFAEIAQAAAA==.',['断点']='断点灬:BAAAKgAECggICQAAAA==.',['方钰']='方钰清沙遍:BAABKgAFFH8iAAQiAAgInBwcAACGAgAiAAgIHBwcAACGAgAEAAQIXxxLDgACAQAbAAQI4RzNEQD6AAAAAA==.',['旋飞']='旋飞转:BAAAKgAECgIIAgAAAA==.',['无火']='无火的灰烬:BAAAKgAECgMIAwABKgAFFAgIDQAOAO4aAA==.',['日月']='日月同天:BAAAKgADCgcIEwAAAA==.',['旧梦']='旧梦:BAAAKgADCgEIAQAAAA==.',['旧顏']='旧顏丷:BAAAKgAFFAgIBAAAAA==.',['昂桃']='昂桃酱酱:BAAAKgAECggICAAAAA==.',['星星']='星星点灯:BAAAKgAECgEIAQAAAA==.',['星铭']='星铭月:BAAAKgAECgEIAQAAAA==.',['春丽']='春丽丽:BAABKgAFFH8DAAIHAAMIlxv8IACfAAAHAAMIlxv8IACfAAAAAA==.',['晚晚']='晚晚折风:BAABKgAFFH8IAAINAAQIVRz/EAAQAQANAAQIVRz/EAAQAQAAAA==.晚晚折风丶:BAAAKgAFFAYIBAAAAA==.',['晴空']='晴空万厘:BAAAKgADCgQIBAAAAA==.',['暴力']='暴力男:BAAAKgAECgYIBgAAAA==.暴力男二:BAAAKgAECggICgAAAA==.',['最後']='最後壹顆子彈:BAAAKgAECgMIAwAAAA==.',['月下']='月下飛舞:BAAAKgAECgYIBgAAAA==.',['月影']='月影寒霜:BAAAKgADCgEIAgAAAA==.',['月皎']='月皎灵瞳:BAAAKgAFFAIIBAAAAA==.',['月落']='月落星辰:BAABKgAFFH8JAAMcAAgIFhJJDwCqAQAcAAcIqxNJDwCqAQAeAAEIAAW/NgBAAAABKgAFFAgIUAAcABcmAA==.月落柒弦:BAABKgAFFH8GAAIBAAYIrhTJAQC5AQABAAYIrhTJAQC5AQAAAA==.',['月醉']='月醉颜:BAABKgAECn8dAAMGAAgI1xNKQgB+AQAGAAgI1xNKQgB+AQAfAAYIXAFFegBIAAAAAA==.',['有种']='有种爱叫冲锋:BAAAKgADCggICAAAAA==.',['未曾']='未曾忘記:BAAAKgAECgIIAgAAAA==.',['李二']='李二狗:BAAAKgAECggICwAAAA==.',['来自']='来自阴影:BAAAKgAECgYIBwAAAA==.',['東芳']='東芳白:BAABKgAFFH8GAAIeAAYILQriEgAIAQAeAAYILQriEgAIAQAAAA==.',['林北']='林北懒觉你噶:BAAAKgAFFAQIBAAAAA==.',['林夕']='林夕的狐狸:BAAAKgAECggIDwAAAA==.',['柒麻']='柒麻麻:BAAAKgAECgcIBwAAAA==.',['柳下']='柳下舟:BAAAKgAFFAMIAwAAAA==.',['栀子']='栀子扇掩笑颜:BAABKgAFFH8GAAIHAAYIZx6KCQCTAQAHAAYIZx6KCQCTAQAAAA==.',['栤雙']='栤雙兒:BAAAKgAECggICQAAAA==.',['格曼']='格曼:BAAAKgAFFAQIBAAAAA==.',['桥本']='桥本奈奈未:BAABKgAECn8YAAINAAgISB93JgCCAgANAAgISB93JgCCAgAAAA==.',['梁山']='梁山小骑士:BAAAKgAECgIIAwAAAA==.',['楸兲']='楸兲的玩偶:BAABKgAFFH8KAAIEAAQI/Be6EwDoAAAEAAQI/Be6EwDoAAAAAA==.',['楸木']='楸木雅熙:BAAAKgAFFAQIBAAAAA==.',['榴莲']='榴莲:BAABKgAFFH8GAAILAAYILgrvDwAuAQALAAYILgrvDwAuAQAAAA==.',['橙一']='橙一楠:BAAAKgADCgIIAgAAAA==.',['欸泽']='欸泽拉斯:BAABKgAFFH8JAAIGAAMIUg9BNwCiAAAGAAMIUg9BNwCiAAAAAA==.',['武汉']='武汉彭于晏:BAAAKgADCggICAAAAA==.武汉热干面杰:BAAAKgADCgIIAgAAAA==.',['死亦']='死亦若丹丶:BAAAKgAECgUIBgAAAA==.',['歼灭']='歼灭灬战:BAAAKgAFFAIIBAAAAA==.',['残光']='残光:BAAAKgAECgIIAgAAAA==.',['残花']='残花落尽:BAAAKgAECgYIBgAAAA==.',['每天']='每天吃不饱:BAABKgAFFH8LAAIGAAQIQxNiMAC3AAAGAAQIQxNiMAC3AAAAAA==.每天吃低保:BAABKgAFFH8UAAMRAAQIdxdIIADXAAARAAQIFRNIIADXAAAZAAQINRZlLwCwAAAAAA==.',['毫秒']='毫秒华语:BAABKgAFFH8IAAIMAAQIQgphHADTAAAMAAQIQgphHADTAAABKgAFFAgIDgAUANAQAA==.',['永瀨']='永瀨唯:BAAAKgAECgcIBwAAAA==.',['污妖']='污妖亡:BAABKgAFFH8GAAIDAAYICh05CwDaAQADAAYICh05CwDaAQAAAA==.',['法爷']='法爷出击:BAAAKgADCgEIAQAAAA==.',['泸州']='泸州吴彦祖:BAABKgAECn8fAAIZAAgI1Q0PUgAIAQAZAAgI1Q0PUgAIAQAAAA==.',['洛柔']='洛柔:BAABKgAFFH8IAAMCAAgIGSJBAwAaAgACAAcIViFBAwAaAgASAAEIyQGHGwA2AAABKgAFFAgIEgACADkXAA==.',['洛河']='洛河耳畔:BAAAKgAECgYIBgAAAA==.',['流影']='流影箭手:BAAAKgADCgMIBgAAAA==.',['流氓']='流氓在哪飘:BAABKgAECn8nAAMdAAgI/BL/EgB8AQAdAAgI/BL/EgB8AQAcAAYIVwcaoACTAAAAAA==.',['浪沸']='浪沸时间:BAAAKgAECgUIBgAAAA==.',['海贼']='海贼灬甲申由:BAAAKgAECgIIAgAAAA==.',['海阔']='海阔丶风情哥:BAAAKgAECgEIAQAAAA==.',['涤罪']='涤罪之焰:BAABKgAFFH8SAAIOAAgI3xx1AgChAQAOAAgI3xx1AgChAQAAAA==.',['涼風']='涼風真世:BAAAKgAFFAMIAwAAAA==.',['淋雨']='淋雨的小火苗:BAAAKgAECggICAAAAA==.',['深海']='深海葬麋鹿丶:BAAAKgAECgEIAQAAAA==.',['混乱']='混乱终焉:BAAAKgAFFAQIBAAAAA==.',['混元']='混元无极仙:BAABKgAECn8iAAMJAAgIcRD0IwA2AQAJAAgIEw70IwA2AQANAAUIxhIxvwDVAAAAAA==.',['温柔']='温柔行经:BAAAKgAECgYIBgAAAA==.',['游侠']='游侠林徽因:BAAAKgADCggIDAAAAA==.',['漢壽']='漢壽亭侯:BAAAKgAECgYIDQAAAA==.',['潮流']='潮流乌鸦:BAAAKgAECgQIBAAAAA==.',['火羽']='火羽之夏:BAABKgAECn8tAAICAAgIRxJxMQBcAQACAAgIRxJxMQBcAQAAAA==.',['灬草']='灬草蜢仔灬:BAAAKgAECggICQAAAA==.',['灬颖']='灬颖旋律灬:BAAAKgAECgQIBAAAAA==.',['灰原']='灰原萌:BAABKgAFFH8IAAIDAAgIExIzBQAmAgADAAgIExIzBQAmAgAAAA==.',['灰格']='灰格小青年:BAAAKgAECgIIAgAAAA==.',['灵魂']='灵魂鬼步:BAACKgAFFH8HAAIDAAQIYBKYMwDHAAADAAQIYBKYMwDHAAAqAAQKfxgAAgMACAgGG9UwAO8BAAMACAgGG9UwAO8BAAAA.',['炉石']='炉石喵:BAAAKgAFFAIIAgAAAA==.',['炎青']='炎青成:BAAAKgADCggICAAAAA==.',['炙灬']='炙灬丨灬焰:BAABKgAFFH8RAAIMAAMI+hd3KwDLAAAMAAMI+hd3KwDLAAAAAA==.',['烟漁']='烟漁:BAAAKgAECgYIBgAAAA==.',['焚契']='焚契:BAAAKgADCgUIBQAAAA==.',['焦虑']='焦虑的蛋蛋:BAAAKgAECggIDgAAAA==.',['煎餠']='煎餠丶:BAAAKgAFFAIIAgAAAA==.',['熊瞎']='熊瞎子丶:BAAAKgADCggICAAAAA==.',['熬夜']='熬夜的圣骑:BAAAKgADCgEIAQAAAA==.',['爪爪']='爪爪冰棒啦:BAABKgAFFH8HAAINAAQIpBrXTADVAAANAAQIpBrXTADVAAAAAA==.',['爱出']='爱出色的劣人:BAAAKgADCggICAAAAA==.',['爸爸']='爸爸奶我:BAABKgAFFH8eAAMGAAgI9iBUAgBtAgAGAAgI9iBUAgBtAgAfAAEI3BOqJQBLAAAAAA==.',['牛哥']='牛哥哥:BAAAKgAECgIIAgAAAA==.',['牛奶']='牛奶不要跑:BAAAKgAECgQIBAAAAA==.',['牛小']='牛小花:BAAAKgAECgUIBQAAAA==.',['牛战']='牛战鹏爷:BAABKgAFFH8GAAIbAAYIQApYDgArAQAbAAYIQApYDgArAQAAAA==.',['牛敏']='牛敏敏:BAAAKgAECggIEAAAAA==.',['牛油']='牛油果芝士:BAABKgAFFH8GAAICAAYI0gcAFAATAQACAAYI0gcAFAATAQAAAA==.',['牛爷']='牛爷:BAAAKgAECgIIAgAAAA==.',['特级']='特级回复药:BAABKgAFFH8GAAMeAAYIpwPxHgCxAAAeAAUIVQTxHgCxAAAcAAEIMAHcYQAzAAABKgAFFAgIBAAIAAAAAA==.',['狄安']='狄安娜灬怒风:BAAAKgADCgUIBQAAAA==.',['狗带']='狗带你飞:BAAAKgAECggICAAAAA==.',['独走']='独走天涯:BAAAKgAECgYIDgAAAA==.',['猫德']='猫德海洋:BAAAKgADCgEIAQAAAA==.',['獠牙']='獠牙海洋:BAAAKgADCgEIAgAAAA==.',['獣人']='獣人丶武僧:BAAAKgAECggIEAAAAA==.',['獣命']='獣命于天:BAAAKgAFFAgIAgAAAA==.',['獵頭']='獵頭:BAABKgAECn8XAAIRAAgIcBR4PwCoAQARAAgIcBR4PwCoAQAAAA==.',['玉米']='玉米丨穗穗:BAABKgAFFH8MAAIZAAQIMReOEwDLAAAZAAQIMReOEwDLAAAAAA==.玉米丨粒粒:BAABKgAECn8ZAAILAAgIkyDnDACUAgALAAgIkyDnDACUAgAAAA==.玉米氵糊糊:BAAAKgAECggIDgAAAA==.玉米糊糊:BAAAKgAECgYIBgAAAA==.',['王多']='王多鱼:BAAAKgAFFAQIBAAAAA==.',['玩藕']='玩藕姐姐:BAABKgAFFH8GAAIJAAYIvQvBEgDmAAAJAAYIvQvBEgDmAAABKgAFFAgIDQANAOEYAA==.',['珑战']='珑战:BAAAKgADCgIIAgAAAA==.',['生闷']='生闷气大王:BAABKgAFFH8VAAQBAAYIDyK8AAD+AQABAAYIDyK8AAD+AQACAAUIWgX4HABxAAASAAEIBQcyJwBEAAAAAA==.',['番茄']='番茄炒蛋吗:BAAAKgAECgcICQAAAA==.',['白肥']='白肥牛:BAABKgAFFH8IAAIOAAgI3ArtBwDuAQAOAAgI3ArtBwDuAQAAAA==.',['白蒂']='白蒂:BAAAKgADCgYIBgAAAA==.',['看鸽']='看鸽养猪:BAABKgAECn8aAAIbAAcIjQ/cKgA2AQAbAAcIjQ/cKgA2AQAAAA==.',['眼里']='眼里有清风丿:BAAAKgADCggICAAAAA==.',['瞎子']='瞎子雷雷:BAAAKgADCggICAAAAA==.',['破势']='破势:BAAAKgAECggIEAAAAA==.',['碧海']='碧海流煌:BAAAKgADCgYIBgAAAA==.',['碧螺']='碧螺春虾仁:BAAAKgAECggICAAAAA==.',['礼拜']='礼拜九丶雨天:BAAAKgADCgYIBgAAAA==.',['祈风']='祈风:BAAAKgAFFAQIBAAAAA==.',['祖屍']='祖屍爺:BAAAKgAECgMIAwAAAA==.',['祖沃']='祖沃达希尔曼:BAAAKgAECgUIBQAAAA==.',['神圣']='神圣一击:BAAAKgAECggICAAAAA==.',['福熙']='福熙:BAABKgAECn8iAAMcAAgIeSNGDgC0AgAcAAgIeSNGDgC0AgAeAAEIkgf1fgAjAAAAAA==.',['穆德']='穆德:BAAAKgAFFAIIAgABKgAFFAgIHAADAFciAA==.',['笑嘻']='笑嘻嘻:BAAAKgADCgcICwAAAA==.',['笨笨']='笨笨丶酱:BAABKgAFFH8iAAQYAAYI8RMnBQA0AQAYAAYI8RMnBQA0AQAWAAQILgp7GQC6AAAXAAEIfwfuHgA4AAAAAA==.笨笨酱丶:BAAAKgAFFAQIBAAAAA==.',['第六']='第六天魔王:BAAAKgAECgIIAgAAAA==.',['筱晓']='筱晓的沙漏:BAABKgAFFH8GAAMiAAMIQQHmFABTAAAiAAMIQQHmFABTAAAEAAMIxwD7HgBHAAAAAA==.',['简言']='简言素行:BAABKgAFFH8GAAIhAAYIcxVgBQBSAQAhAAYIcxVgBQBSAQAAAA==.',['米拉']='米拉诺:BAAAKgADCggICAAAAA==.',['米斯']='米斯特沐公子:BAAAKgAECgUIBQAAAA==.',['精盐']='精盐加味精:BAAAKgAECgEIAQAAAA==.',['糕手']='糕手凡凡:BAAAKgAECgYICAAAAA==.',['紫霞']='紫霞:BAAAKgADCgYIBgAAAA==.',['纯白']='纯白色记忆:BAAAKgADCgEIAQAAAA==.',['终结']='终结者皮蛋强:BAAAKgAECggIDAAAAA==.',['续写']='续写丶一念沙:BAAAKgAECgcIBwAAAA==.',['维纳']='维纳斯之血:BAAAKgAECgYIBgAAAA==.',['缺德']='缺德的团长:BAAAKgAECgQIBAAAAA==.',['罗大']='罗大泵:BAABKgAFFH8GAAIFAAYIeQUBCwDQAAAFAAYIeQUBCwDQAAABKgAFFAgIBgAFABkJAA==.',['耀光']='耀光丶夜:BAAAKgAFFAgIAwAAAA==.',['老板']='老板喜欢地板:BAAAKgAFFAYIAQAAAA==.',['老沈']='老沈的小小:BAAAKgAECgUIBQAAAA==.',['老生']='老生常谈:BAAAKgAECgcIEAAAAA==.',['聆风']='聆风吟:BAABKgAECn8VAAMEAAgIVxw9GgA8AgAEAAgIVxw9GgA8AgAbAAIIXxC+UQCEAAAAAA==.',['聋瞎']='聋瞎:BAAAKgAECgIIAgAAAA==.',['肇事']='肇事咕儿:BAABKgAFFH8JAAQjAAUIIBEdAwDkAAAjAAQIfgsdAwDkAAAcAAQIbgyhHADMAAAeAAEIVBAPMwBMAAABKgAFFAgIKgARACMgAA==.',['胖子']='胖子的小蛮腰:BAAAKgAFFAEIAQAAAA==.',['至尊']='至尊宝:BAABKgAFFH8IAAIbAAgIhCMVAQDAAgAbAAgIhCMVAQDAAgAAAA==.',['舞动']='舞动青春:BAABKgAFFH8GAAIDAAYIjRByGQBSAQADAAYIjRByGQBSAQAAAA==.',['良好']='良好德大菊观:BAAAKgAECgUIBwAAAA==.',['色牛']='色牛突击队长:BAAAKgADCggIEAAAAA==.',['艾伦']='艾伦格林斯潘:BAAAKgADCggICAAAAA==.',['艾斯']='艾斯塔苹果:BAAAKgAECgUIBQAAAA==.',['花落']='花落羽:BAABKgAFFH8GAAIZAAYIMxyzEABgAQAZAAYIMxyzEABgAQAAAA==.',['苏大']='苏大强:BAAAKgAECgQIBAAAAA==.',['苏灬']='苏灬糊涂灬:BAABKgAFFH8QAAIZAAgINxRsBgDuAQAZAAgINxRsBgDuAQAAAA==.',['苗木']='苗木丶诚:BAAAKgAFFAgIAgAAAA==.',['若水']='若水灬怜纱:BAAAKgAECgEIAQAAAA==.若水灬星纱:BAAAKgAFFAEIAQAAAA==.',['草莓']='草莓酱酱:BAAAKgADCggICAAAAA==.',['莉雅']='莉雅丶夜翼:BAABKgAECn8UAAMZAAYIfRrgMABxAQAZAAYITxngMABxAQARAAMILhsIxACeAAAAAA==.',['菊鹿']='菊鹿:BAAAKgAFFAgIBAAAAA==.',['菳笙']='菳笙:BAAAKgADCgQIBAAAAA==.',['萨帕']='萨帕:BAAAKgADCggICgAAAA==.',['萨满']='萨满开嗜血:BAAAKgAECgQIBAAAAA==.萨满洒满:BAAAKgADCgYIBgAAAA==.',['萨爹']='萨爹出击:BAAAKgADCgMIAwAAAA==.',['萨玛']='萨玛里罕:BAAAKgAECgUIBQAAAA==.',['落叶']='落叶灬归根:BAAAKgADCggICAAAAA==.落叶风:BAABKgAECn8bAAMeAAgITRQmKACQAQAeAAgITRQmKACQAQAcAAgIYgzYaAAiAQAAAA==.',['落墨']='落墨:BAABKgAFFH8GAAINAAYI/g0THAAFAQANAAYI/g0THAAFAQAAAA==.',['落花']='落花雨:BAABKgAECn8bAAINAAgInQcZ+gC/AAANAAgInQcZ+gC/AAAAAA==.',['葫芦']='葫芦酒仙:BAACKgAFFH8GAAIHAAYIdRCpAwCKAQAHAAYIdRCpAwCKAQAqAAQKfxwAAgcACAjcHC8OADICAAcACAjcHC8OADICAAAA.',['蓝星']='蓝星:BAAAKgAECgMIBQAAAA==.',['蕾丝']='蕾丝大汉:BAAAKgAECgYIEgAAAA==.',['薄命']='薄命之花:BAAAKgAECgcICQAAAA==.',['薯丶']='薯丶条:BAABKgAECn8UAAMXAAgIdg9LJQBhAQAXAAgI0AtLJQBhAQAWAAgIBQ4IQwBdAQAAAA==.',['藤林']='藤林杏丶:BAABKgAFFH8QAAMZAAgIKSCHCADTAQAZAAYIHiOHCADTAQARAAUIhRxEKQCrAAAAAA==.',['蜜桃']='蜜桃四季春:BAAAKgAECggICwAAAA==.',['蜡笔']='蜡笔小昆:BAAAKgADCgUIBQAAAA==.',['蝠翼']='蝠翼瞳灵:BAAAKgAFFAYIBAAAAA==.',['表弟']='表弟丶:BAABKgAFFH8dAAQBAAcIGiBDAABkAgABAAcI8B9DAABkAgASAAYIqR/gBgCxAQACAAEItiJjHwBgAAAAAA==.',['西北']='西北周杰伦:BAAAKgAFFAQIBAAAAA==.',['詹姆']='詹姆斯蛋蛋:BAAAKgAECgYIBgAAAA==.',['諾曉']='諾曉然丶:BAABKgAFFH8FAAMGAAQINBANTABcAAAGAAMIXggNTABcAAAgAAEINQE3HwAtAAAAAA==.',['让叔']='让叔叔给你糖:BAAAKgADCgUIBQAAAA==.',['讲唔']='讲唔掂甘串:BAAAKgADCggICAAAAA==.',['诅咒']='诅咒铠甲:BAAAKgADCggIDwAAAA==.',['请叫']='请叫我方丈:BAAAKgADCggICAAAAA==.',['谷兰']='谷兰德玛瑟:BAABKgAECn8gAAIcAAcIcx0QMgDjAQAcAAcIcx0QMgDjAQAAAA==.',['貔貅']='貔貅敿:BAAAKgAFFAQIBAAAAA==.',['费基']='费基尔达:BAABKgAECn8UAAIMAAgInhj1MwDdAQAMAAgInhj1MwDdAQAAAA==.',['贼哥']='贼哥丶哥:BAAAKgAECgMIAwAAAA==.',['躺下']='躺下吃南瓜:BAABKgAFFH8GAAILAAYI4g4aEgBWAQALAAYI4g4aEgBWAQAAAA==.',['轻薄']='轻薄的假象丶:BAABKgAECn8XAAIbAAgInBnzEwAXAgAbAAgInBnzEwAXAgAAAA==.',['辛多']='辛多雷晨歌:BAAAKgAECgEIAQAAAA==.',['达纳']='达纳尔:BAAAKgAECgIIAgAAAA==.',['迪亞']='迪亞丶箥羅:BAAAKgAECgQIBAAAAA==.',['迷戀']='迷戀哥:BAAAKgAFFAEIAQAAAA==.',['退休']='退休后现状:BAABKgAFFH8WAAIRAAgILRqQBwAFAgARAAgILRqQBwAFAgAAAA==.',['逆流']='逆流的沙漏:BAAAKgAECggICAAAAA==.',['逐星']='逐星者的晨光:BAAAKgAFFAIIAgAAAA==.',['逗逼']='逗逼泗灏:BAAAKgADCggICAAAAA==.',['逼逼']='逼逼鸡:BAAAKgAECggIDgAAAA==.',['邪丶']='邪丶飲血饕鬄:BAAAKgAECgcIBwAAAA==.',['酒馆']='酒馆常客:BAAAKgAECggICAAAAA==.',['醉揽']='醉揽清风:BAAAKgAECggIEAAAAA==.',['醉风']='醉风吟:BAAAKgAECggIEAAAAA==.',['里奥']='里奥丶冬强:BAAAKgAFFAUIBAAAAA==.',['重生']='重生之不做人:BAAAKgAECgYIDwAAAA==.',['重紫']='重紫:BAAAKgAECgUIBQAAAA==.',['金色']='金色恶夜:BAAAKgADCggICAAAAA==.',['金龙']='金龙:BAAAKgADCggIEAAAAA==.',['铃音']='铃音天升:BAAAKgAECgcICgAAAA==.',['镜子']='镜子骑士:BAABKgAFFH8HAAMbAAQIYg5KCQDZAAAbAAMINwpKCQDZAAAiAAQIYg7NBQCyAAAAAA==.',['长城']='长城炮:BAACKgAFFH8FAAIRAAII+hFDSQCAAAARAAII+hFDSQCAAAAqAAQKfxoAAxEABgjFHq08ALIBABEABgjFHq08ALIBABkAAQhNC3SvACQAAAAA.',['长期']='长期素食:BAABKgAFFH8KAAMTAAYIoRIUCgDeAAAKAAYIcBEADgBcAQATAAQI2hcUCgDeAAAAAA==.',['长沟']='长沟流月:BAACKgAFFH8uAAMcAAYIBBWEIAAdAQAcAAYIBBWEIAAdAQAeAAMIEQonKQCAAAAqAAQKfxoAAxwACAimHdInACMCABwACAimHdInACMCAB0AAQhXBxI6ABMAAAAA.',['长眉']='长眉毛:BAAAKgAECgIIAgAAAA==.',['长长']='长长常久久玖:BAABKgAFFH8NAAIGAAgIhBMMBQAHAgAGAAgIhBMMBQAHAgAAAA==.',['阿大']='阿大龙:BAAAKgAECgUICgAAAA==.',['阿托']='阿托品:BAABKgAFFH8GAAIdAAYIRxBEAgAnAQAdAAYIRxBEAgAnAQAAAA==.',['阿牜']='阿牜:BAAAKgAFFAQIBAAAAA==.',['阿痛']='阿痛木:BAAAKgAECgYICgAAAA==.',['阿隆']='阿隆索:BAABKgAFFH8KAAIMAAgIGBg4BgBIAgAMAAgIGBg4BgBIAgAAAA==.',['陆沉']='陆沉:BAAAKgADCgQIBAAAAA==.',['陨之']='陨之殇:BAAAKgADCgMIAwAAAA==.',['随变']='随变冰激凌:BAAAKgADCgMIAwAAAA==.',['隔壁']='隔壁扒皮老王:BAAAKgAECgEIAQAAAA==.',['隨機']='隨機師:BAAAKgAECgMIAwAAAA==.',['雕儿']='雕儿浪荡:BAABKgAFFH8GAAIZAAYIlw8zFQA6AQAZAAYIlw8zFQA6AQAAAA==.',['雨绮']='雨绮吃冰激凌:BAAAKgADCggIFgAAAA==.',['雪丨']='雪丨月:BAABKgAFFH8KAAIkAAYI8RAAAQA+AQAkAAYI8RAAAQA+AQABKgAFFAgIBgAkAPgLAA==.',['雪白']='雪白如皎:BAAAKgADCggICAAAAA==.',['雪花']='雪花飘飘:BAAAKgAECgcIBwAAAA==.',['雷欧']='雷欧力欧:BAAAKgADCgEIAQAAAA==.',['青青']='青青河边草:BAAAKgAECgEIAQAAAA==.',['青龙']='青龙剑姬:BAAAKgADCggIEAAAAA==.',['非洲']='非洲的阿昆达:BAAAKgAFFAEIAQAAAA==.',['韩素']='韩素薇:BAABKgAECn8YAAITAAgInh45GgAwAgATAAgInh45GgAwAgAAAA==.',['顶住']='顶住我掩护:BAACKgAFFH8YAAMRAAQISiIVFgD2AAARAAQISiIVFgD2AAAZAAEIERpvJwBFAAAqAAQKfyYAAxkACAicI3oSAD8CABEACAiTI34jAGcCABkACAi2HXoSAD8CAAAA.',['飍得']='飍得狠:BAAAKgADCgQIBAAAAA==.',['风之']='风之乐:BAACKgAFFH8GAAIBAAYIWhLCCwBZAQABAAYIWhLCCwBZAQAqAAQKfxgAAgEACAi+Au5cAIIAAAEACAi+Au5cAIIAAAAA.',['风落']='风落月:BAAAKgADCggICAAAAA==.',['飒飒']='飒飒撒萨:BAAAKgADCgYICgAAAA==.',['飞翔']='飞翔的梦想:BAAAKgAFFAQIBAAAAA==.',['饭依']='饭依然特稀:BAAAKgAECggICAAAAA==.',['高大']='高大富帅:BAABKgAFFH8GAAINAAYI7hUEIwBgAQANAAYI7hUEIwBgAQAAAA==.',['鬼扯']='鬼扯爸爸:BAABKgAFFH8MAAIKAAYIXBJPDgBZAQAKAAYIXBJPDgBZAQAAAA==.',['魔术']='魔术师丨小宝:BAAAKgADCggICwABKgAFFAYIAgAIAAAAAA==.',['麦克']='麦克斯:BAAAKgAECgYIDAAAAA==.',['黑奶']='黑奶牛:BAAAKgAECggIDgAAAA==.',['黑暗']='黑暗代言人:BAAAKgAECggIDAAAAA==.黑暗游戏:BAAAKgAECgMIAwAAAA==.',['黑白']='黑白皆星河:BAAAKgAFFAgIBAAAAA==.',['龍卷']='龍卷風丶:BAAAKgAECgQIBAAAAA==.',['龙哥']='龙哥我爱你啊:BAAAKgAFFAYIBAAAAA==.',['龙蛋']='龙蛋:BAABKgAECn8UAAMBAAgIfiMcBADFAgABAAgIfiMcBADFAgASAAEIuwn5YwAtAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end