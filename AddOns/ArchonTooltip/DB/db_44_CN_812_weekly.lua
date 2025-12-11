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
 local lookup = {'Unknown-Unknown','DeathKnight-Frost','Paladin-Retribution','Druid-Restoration','Druid-Balance','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Warlock-Destruction','DemonHunter-Havoc','Shaman-Restoration','Mage-Frost','Mage-Arcane','Priest-Holy','Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Shaman-Elemental','Hunter-Marksmanship','Paladin-Holy','Paladin-Protection','DemonHunter-Vengeance','Druid-Guardian','DeathKnight-Blood','Shaman-Enhancement','Evoker-Augmentation','Evoker-Devastation','Hunter-Survival','Monk-Windwalker','Monk-Brewmaster','Monk-Mistweaver','Evoker-Preservation','Warrior-Arms','DeathKnight-Unholy','Warlock-Affliction',}; local provider = {region='CN',realm='莱索恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Achillesheel:BAAALAADCgYIDAAAAA==.',Al='Alvin:BAAALAAECgYICAAAAA==.',Bi='Bigboomm:BAAALAAECgYIBgAAAA==.',Co='Cortez:BAAALAAFFAMIAgAAAA==.',Cr='Crazymaster:BAAALAADCgMIAwAAAA==.',Da='Darkjokerr:BAAALAAECgYICAAAAA==.',Dk='Dkii:BAAALAAECgYIEwAAAA==.',Dr='Druids:BAAALAAECgUIBgAAAA==.',Eo='Eotrisingsun:BAAALAAFFAIIAgABLAAFFAQIAwABAAAAAA==.',Fe='Fenton:BAAALAAFFAIIAgAAAA==.',Fr='Fragrant:BAABLAAFFH8IAAICAAII+QiUgwBEAAACAAII+QiUgwBEAAAAAA==.',Gr='Groms:BAAALAAECggIDQAAAA==.',Ha='Hanabi:BAAALAAECgUIBQABLAAFFAQIAwABAAAAAA==.',Hi='Hikaru:BAAALAAECgYIBgAAAA==.',Ji='Jijimaoa:BAABLAAECn8VAAIDAAYI2iKhJwD3AQADAAYI2iKhJwD3AQAAAA==.',Ka='Kassandra:BAAALAAECgQIBAAAAA==.',Lv='Lvelve:BAABLAAFFH8VAAMEAAYIRRnTDQDgAQAEAAYIRRnTDQDgAQAFAAEIRAXfOQA0AAAAAA==.',Ma='Marklh:BAAALAADCgUIBQAAAA==.Marlboroo:BAAALAAECgMIAwAAAA==.Marteau:BAAALAAFFAIIAgAAAA==.',Mi='Mirana:BAABLAAFFH8IAAIEAAIIjh2DIQCfAAAEAAIIjh2DIQCfAAAAAA==.',Or='Orianshow:BAAALAAFFAIIBAAAAA==.',Pl='Playeropjowl:BAAALAADCgcIBwAAAA==.',Pr='Protect:BAAALAAECgEIAQAAAA==.',Sa='Sampana:BAACLAAFFH8SAAIGAAUIARikIwBSAQAGAAUIARikIwBSAQAsAAQKfx8AAwYABwi8FTZiAM4BAAYABwgXFTZiAM4BAAcABgiRDKpkAPYAAAAA.',Sg='Sgwanna:BAABLAAECn8WAAMIAAgIyxQJRQBbAQAJAAUIExeNjwBeAQAIAAcIdxAJRQBbAQAAAA==.',Sh='Shgpool:BAAALAAECggICAAAAA==.',Su='Sunrise:BAAALAAECgIIAgAAAA==.',Th='Thesavior:BAAALAAECgYIDwAAAA==.',Tl='Tlee:BAACLAAFFH8gAAIKAAYIihbUGgCcAQAKAAYIihbUGgCcAQAsAAQKfyQAAgoACAhGHtE4AHsCAAoACAhGHtE4AHsCAAAA.',To='Towerrush:BAAALAADCgQIBAAAAA==.',Tu='Tulipas:BAAALAADCgYIBgAAAA==.',Wo='Wogn:BAAALAAECgUICgAAAA==.',Ze='Zelcer:BAAALAAFFAQIAwAAAA==.',['一个']='一个萨满:BAAALAAECgYIBgAAAA==.',['一利']='一利丹丶怒风:BAAALAADCggICAAAAA==.',['一失']='一失控一:BAAALAADCgUIBQAAAA==.',['一戒']='一戒牧一:BAABLAAFFH8IAAILAAIIISKOIgDEAAALAAIIISKOIgDEAAAAAA==.',['一曲']='一曲震魂:BAABLAAFFH8JAAMMAAUILhHODgCUAAANAAMIZg2kPQDRAAAMAAII2hbODgCUAAABLAAFFAgIKQANABshAA==.',['一样']='一样的夜:BAAALAAECgYIBgAAAA==.',['一直']='一直很忧郁:BAAALAAECgUIBQAAAA==.',['一神']='一神牧一:BAACLAAFFH89AAMOAAcIKiNcAgDdAgAOAAcIKiNcAgDdAgAPAAIIegrwIQB3AAAsAAQKfzEABA4ACAjOJUIEAFADAA4ACAjOJUIEAFADAA8ABwjGGpcxAAMCABAAAghoGrwpAJwAAAAA.',['三十']='三十而立玩:BAAALAAECgYICQAAAA==.',['三月']='三月雨如烟:BAABLAAFFH8OAAIRAAMIjQledQB2AAARAAMIjQledQB2AAABLAAFFAgIHAAFAOIkAA==.',['上层']='上层精灵:BAAALAAFFAIIAgAAAA==.',['上课']='上课暴你菊:BAAALAAECgUICgAAAA==.',['上马']='上马就走:BAAALAAECgcIBwAAAA==.',['不久']='不久嘿嗖:BAAALAAECgYIBwAAAA==.',['专业']='专业混子:BAAALAAECgYICQAAAA==.',['丢丢']='丢丢小笨笨:BAABLAAFFH8MAAISAAIITBonJwCZAAASAAIITBonJwCZAAAAAA==.',['丨伊']='丨伊凰丨:BAAALAAECgYIDQAAAA==.',['丨凤']='丨凤舞九天丶:BAAALAADCgUIBQAAAA==.',['丨分']='丨分阴错阳丶:BAAALAADCgIIAgAAAA==.',['丨德']='丨德丨:BAAALAAECgYIBAAAAA==.',['中单']='中单不买鸡:BAAALAAECgYICAAAAA==.',['丶八']='丶八神丶:BAAALAAECgUIBQAAAA==.',['丶晴']='丶晴空:BAACLAAFFH8GAAIRAAIILQwJsQA3AAARAAIILQwJsQA3AAAsAAQKfxwAAxEACAjWHec3AH4CABEACAjWHec3AH4CABMABgiZCwJ4APQAAAAA.',['主教']='主教用力些:BAAALAADCgMIAwAAAA==.',['丿淡']='丿淡淡灬:BAAALAAFFAIIBAAAAA==.',['丿风']='丿风中追风灬:BAABLAAFFH8GAAIHAAII7wYXNwAqAAAHAAII7wYXNwAqAAAAAA==.',['乌迪']='乌迪尔丶:BAAALAAFFAIIAgAAAA==.',['九五']='九五罒二七:BAABLAAFFH8IAAIHAAIIQAKDMABRAAAHAAIIQAKDMABRAAAAAA==.',['九天']='九天荡魔祖师:BAABLAAECn8VAAIDAAYIohSTswCaAQADAAYIohSTswCaAQAAAA==.',['于是']='于是葛格:BAAALAAECgMIAwAAAA==.',['云天']='云天泪:BAAALAAECgYIEAAAAA==.',['云鼎']='云鼎:BAAALAAECgEIAQAAAA==.',['亦父']='亦父:BAAALAAECgYIBgAAAA==.',['人月']='人月亠神话:BAAALAADCgMIAwAAAA==.',['人生']='人生没有再见:BAAALAAECgIIAgAAAA==.',['伊利']='伊利达雷之怒:BAAALAAECggICAAAAA==.',['伊登']='伊登的苹果:BAACLAAFFH8fAAIUAAYIMhhECwDRAQAUAAYIMhhECwDRAQAsAAQKfxYAAxQACAgYEIctAL0BABQACAgYEIctAL0BAAMAAQgJAbabARQAAAAA.',['伍六']='伍六七:BAABLAAFFH8HAAMGAAMIKwLlUgBCAAAHAAIIDwFXMQBIAAAGAAEIYgTlUgBCAAAAAA==.',['会夢']='会夢之圈:BAAALAAECggICAAAAA==.',['会梦']='会梦之圈:BAACLAAFFH8hAAIOAAYIshymDgBZAQAOAAYIshymDgBZAQAsAAQKfx8AAg4ACAgUIv8PAOgCAA4ACAgUIv8PAOgCAAAA.会梦之巻:BAAALAAECgcICQAAAA==.',['你们']='你们的姥姥:BAABLAAECn8XAAIDAAYIuSGpKgDpAQADAAYIuSGpKgDpAQAAAA==.',['你打']='你打我就跑:BAAALAAECgUICAAAAA==.',['你没']='你没有目标:BAAALAADCgIIAgAAAA==.',['促醉']='促醉:BAACLAAFFH8HAAIGAAYIwwONEwAzAQAGAAYIwwONEwAzAQAsAAQKfxoAAgYABghAHIwuAKEBAAYABghAHIwuAKEBAAAA.',['俢囉']='俢囉戰將:BAABLAAFFH8NAAIVAAMIXgrsEgBdAAAVAAMIXgrsEgBdAAAAAA==.俢囉戰鉮:BAABLAAFFH8VAAMWAAMIvQrwDgBUAAAWAAMIvQrwDgBUAAAKAAIIkgBzZwA9AAAAAA==.俢囉戰魂:BAACLAAFFH8KAAMEAAMIMAqyRgBXAAAEAAIIZQSyRgBXAAAXAAMINwXYCgBGAAAsAAQKfxQAAwQACAh+FCJDANQBAAQACAh+FCJDANQBABcABgirBcQdAJUAAAAA.俢囉戰魄:BAAALAAFFAIIAgAAAA==.',['俢羅']='俢羅戰噫:BAAALAAFFAIIAgAAAA==.',['修儸']='修儸栤:BAABLAAFFH8MAAMYAAMILQUJFwBTAAAYAAMI1QQJFwBTAAACAAEIBAjZrwAAAAAAAA==.',['偶尔']='偶尔的神丶:BAAALAAECggICAAAAA==.',['偷裤']='偷裤衩的男人:BAAALAADCgIIAgAAAA==.',['元素']='元素萨:BAABLAAFFH8WAAILAAQIGg9KOADDAAALAAQIGg9KOADDAAAAAA==.',['光影']='光影星空:BAAALAAECgQIBAAAAA==.',['光的']='光的暗影:BAABLAAECn8WAAMOAAcInAtKbQAzAQAOAAcInAtKbQAzAQAPAAII5gLJmgA8AAAAAA==.',['兜兜']='兜兜有洞:BAAALAAECgEIAQAAAA==.',['八字']='八字排盤:BAAALAAFFAIIAgAAAA==.',['六爻']='六爻算命:BAAALAAFFAEIAQAAAA==.',['再见']='再见三戒:BAACLAAFFH8JAAMLAAMIXQxZRgCUAAALAAMIXQxZRgCUAAASAAIIdAWUNwB1AAAsAAQKfxwABBIABwgqFGpPAMwBABIABwgqFGpPAMwBABkABwgQCTkYAGkBAAsABQgBDOpwALIAAAAA.',['冰冰']='冰冰沃特麦冷:BAAALAAECgMIAwAAAA==.',['冰冷']='冰冷的眼:BAAALAADCgIIAQAAAA==.',['冰抹']='冰抹茶:BAAALAAFFAMIAwAAAA==.',['冰飘']='冰飘雪:BAAALAAECgIIAgAAAA==.',['冷酷']='冷酷的泪:BAAALAAECgIIBAAAAA==.',['凤丫']='凤丫头:BAABLAAECn8WAAILAAcIrg8LmgBKAQALAAcIrg8LmgBKAQAAAA==.',['凯特']='凯特鬼魅丽影:BAAALAADCgYIBgAAAA==.',['刀疤']='刀疤贝里钱:BAAALAAECggIBwAAAA==.',['创始']='创始元灵:BAAALAAECgUICAAAAA==.',['剑啸']='剑啸龙吟:BAAALAAFFAIIAwAAAA==.',['勾人']='勾人:BAAALAAECgYIBgAAAA==.',['北笙']='北笙:BAABLAAFFH8LAAIMAAMIMQneDwBjAAAMAAMIMQneDwBjAAAAAA==.',['北饮']='北饮风:BAAALAAECgUIBwAAAA==.',['十元']='十元骄子:BAAALAADCgQIBAAAAA==.',['十字']='十字軍咄咄:BAAALAAFFAIIBAAAAA==.',['千年']='千年妖狐:BAAALAAECgIIBAAAAA==.',['千幻']='千幻无情道:BAABLAAFFH8GAAICAAYIUA8RTQD5AAACAAYIUA8RTQD5AAAAAA==.',['千谷']='千谷:BAAALAADCgIIAgAAAA==.',['半世']='半世灬迷离:BAABLAAFFH8GAAICAAIIuhHiggBEAAACAAIIuhHiggBEAAAAAA==.',['单小']='单小龙:BAACLAAFFH8IAAIaAAgI4R2YAQBkAgAaAAgI4R2YAQBkAgAsAAQKfyYAAhsACAjaIUQTAJYCABsACAjaIUQTAJYCAAAA.',['南歌']='南歌:BAACLAAFFH8JAAQTAAMIxhETIwCCAAATAAIIKRITIwCCAAARAAMItQoGeQBrAAAcAAIIgRPTBABKAAAsAAQKfxgAAxMABwg3FtpDAKcBABMABwgLFtpDAKcBABEAAQiRGE8nAUgAAAAA.',['卿卿']='卿卿子衿:BAAALAADCgQIBAAAAA==.',['取名']='取名字好难:BAAALAAFFAIIAgAAAA==.',['可爱']='可爱小兔子:BAABLAAECn8XAAIIAAYItR20HgAKAgAIAAYItR20HgAKAgAAAA==.',['叶丿']='叶丿无双:BAABLAAFFH8FAAIOAAIIpAaHPAB9AAAOAAIIpAaHPAB9AAAAAA==.叶丿無双:BAAALAADCgcIBwAAAA==.',['叽翅']='叽翅:BAACLAAFFH8QAAISAAYIMRVnEQBXAQASAAYIMRVnEQBXAQAsAAQKf4AAAxIACAhbJQwEAG8DABIACAhbJQwEAG8DAAsAAQh6Bc5aARcAAAAA.',['吒斯']='吒斯特兎亦特:BAAALAAECgQIBwAAAA==.',['吾单']='吾单叁路:BAAALAAECgYIEgABLAAECggICwABAAAAAA==.吾单弎路:BAAALAAECgYIDAABLAAECggICwABAAAAAA==.',['吾愛']='吾愛國:BAABLAAFFH8JAAIGAAIIkxabSQBKAAAGAAIIkxabSQBKAAAAAA==.',['呲啦']='呲啦啦:BAAALAAECgYICAAAAA==.',['咕哒']='咕哒子本咕:BAAALAAFFAIIAgAAAA==.',['哈大']='哈大高铁:BAABLAAFFH8IAAIYAAIIIwxbGwA0AAAYAAIIIwxbGwA0AAAAAA==.',['哈库']='哈库娜玛嗒:BAAALAAECgYIDAAAAA==.',['哞哞']='哞哞哒:BAABLAAECn8UAAIFAAcIjh3wJwAuAgAFAAcIjh3wJwAuAgAAAA==.',['哥布']='哥布林王子:BAABLAAFFH8UAAMJAAgInBhNEAAQAgAJAAgIDxhNEAAQAgAIAAII+SLuCwCxAAAAAA==.',['哦哦']='哦哦了:BAAALAAECgYIDQAAAA==.',['哼哼']='哼哼的粉猪:BAAALAAECgYICgAAAA==.',['嘎嘎']='嘎嘎:BAAALAAECgYIBgAAAA==.',['嘿哈']='嘿哈嘿:BAAALAAECgYIBgAAAA==.',['嘿逗']='嘿逗:BAAALAADCgMIBQAAAA==.',['团队']='团队灬领袖:BAAALAAECgIIAgAAAA==.',['国民']='国民好姑娘:BAAALAAECgIIAgAAAA==.',['圣光']='圣光之莉:BAABLAAFFH8IAAIDAAQIFxQcNgDTAAADAAQIFxQcNgDTAAABLAAFFAcIKAAFABEdAA==.圣光奶萨:BAABLAAFFH8QAAILAAYIjQSPPgCrAAALAAYIjQSPPgCrAAAAAA==.圣光追随者:BAAALAAECggICQAAAA==.',['圣殿']='圣殿白骑:BAAALAAECgYIBgAAAA==.',['地狱']='地狱术弑:BAACLAAFFH8SAAIJAAMIQQpYTwB9AAAJAAMIQQpYTwB9AAAsAAQKf0AAAgkACAjzErAuAJUBAAkACAjzErAuAJUBAAAA.',['坚定']='坚定的小九:BAAALAAECgQIBAABLAAFFAEIAQABAAAAAA==.',['坦克']='坦克没后视镜:BAABLAAFFH8NAAIDAAMI2RMxIgDIAAADAAMI2RMxIgDIAAABLAAFFAYIDgAHAFMYAA==.',['埃辛']='埃辛諾斯戰刃:BAAALAADCgYIBgAAAA==.',['壶中']='壶中仙:BAAALAADCgYIBgAAAA==.',['夏天']='夏天下雪:BAAALAAFFAIIBAAAAA==.',['多尼']='多尼多尼:BAAALAAECgcIEQAAAA==.',['夜丶']='夜丶翠香:BAAALAADCgYIBgAAAA==.夜丶雾雨:BAAALAADCgIIAgAAAA==.',['夜之']='夜之森叁:BAABLAAECn8VAAIRAAcI0iDLZQAQAgARAAcI0iDLZQAQAgAAAA==.',['夜幕']='夜幕暗杀者:BAAALAAFFAIIAgAAAA==.',['夜暮']='夜暮降龙:BAAALAAECgQIBAAAAA==.',['夢九']='夢九旅人:BAAALAAECgEIAQAAAA==.',['夢幻']='夢幻泡影:BAAALAAECgYIDQAAAA==.',['大尐']='大尐姐啊:BAAALAAFFAIIAwAAAA==.',['大瞗']='大瞗哥:BAAALAAECgYIBgAAAA==.',['大迪']='大迪奥戈:BAAALAAFFAIIAgAAAA==.',['大黑']='大黑牛丿:BAAALAAECgEIAQAAAA==.',['天使']='天使长奥莉尔:BAAALAADCgEIAQAAAA==.',['太贰']='太贰真人:BAABLAAFFH8KAAMKAAIIRRVPOACfAAAKAAIIRRVPOACfAAAWAAIINwvNFgAoAAAAAA==.',['夲夲']='夲夲丶圣骑:BAAALAAECgYIEAAAAA==.',['奉天']='奉天都督:BAAALAAFFAIIAwAAAA==.',['好奇']='好奇害死猫丶:BAABLAAFFH8QAAIRAAYIwBVIDgC/AQARAAYIwBVIDgC/AQAAAA==.',['如川']='如川之方至:BAAALAAFFAIIBAAAAA==.',['妮蔻']='妮蔻妮蔻:BAABLAAFFH8IAAILAAgIUwBgewAzAAALAAgIUwBgewAzAAAAAA==.',['姚总']='姚总摆摊:BAAALAADCgYIBgAAAA==.',['威尔']='威尔斯凯:BAABLAAFFH8GAAIRAAYIfQMKYwCwAAARAAYIfQMKYwCwAAAAAA==.',['字节']='字节邪恶跳动:BAAALAADCgUIBQAAAA==.',['孤独']='孤独的探索者:BAACLAAFFH8lAAMOAAYINxbnGwBwAQAOAAUIxhXnGwBwAQAPAAEIRgewKgBBAAAsAAQKfxgAAg4ABgiWFydSAI4BAA4ABgiWFydSAI4BAAEsAAUUBggsABEAixsA.',['宁小']='宁小左儿:BAABLAAECn8jAAIMAAgINCICBACuAgAMAAgINCICBACuAgAAAA==.',['宇智']='宇智波鼬:BAABLAAFFH8KAAIKAAgI9xxcBQCMAgAKAAgI9xxcBQCMAgAAAA==.',['宝贝']='宝贝小德:BAAALAAECgMIAwAAAA==.宝贝小猎:BAAALAADCgIIAgAAAA==.',['寒月']='寒月恋雪:BAAALAAECggICAAAAA==.',['射几']='射几箭:BAAALAAECgYICwAAAA==.',['小可']='小可乃:BAAALAAECgIIAgAAAA==.小可怜兔子:BAABLAAECn8XAAIEAAYIexIPeAAxAQAEAAYIexIPeAAxAQAAAA==.',['小奶']='小奶锤球球:BAAALAAECgUIBQAAAA==.',['小小']='小小蛆:BAACLAAFFH8iAAIDAAcIuCLbAgBMAgADAAcIuCLbAgBMAgAsAAQKfycAAgMACAibJRAOAEQDAAMACAibJRAOAEQDAAAA.',['小手']='小手拔拔凉:BAAALAAECgYIBgAAAA==.',['小柠']='小柠萌吖:BAABLAAFFH8OAAIRAAgInRqCDAAnAgARAAgInRqCDAAnAgAAAA==.',['小熊']='小熊猫的奶茶:BAAALAAECgYIDAAAAA==.小熊猫的汉堡:BAABLAAFFH8FAAMLAAMIRRUpZABXAAALAAIIgwwpZABXAAASAAMIaQFMSQA+AAAAAA==.小熊猫的蛋挞:BAAALAADCgMIAwAAAA==.',['小狐']='小狐狸宝宝:BAAALAADCgYIBgAAAA==.',['小皮']='小皮鞭儿张飞:BAAALAAFFAIIBAAAAA==.',['小胖']='小胖飞起来:BAAALAAFFAIIAgAAAA==.',['小野']='小野蛮:BAABLAAFFH8NAAIRAAYIzRK0MQB0AQARAAYIzRK0MQB0AQAAAA==.',['小马']='小马同学:BAAALAAECgYIEwAAAA==.',['小龙']='小龙卷:BAABLAAFFH8IAAIKAAIINh5ZNQCiAAAKAAIINh5ZNQCiAAABLAAFFAgIFAAJAJwYAA==.',['山海']='山海經:BAAALAAFFAIIBAAAAA==.',['巍剑']='巍剑鸣:BAAALAAFFAIIAgAAAA==.',['左边']='左边丶永恒:BAAALAAECgEIAQAAAA==.',['巧克']='巧克力:BAAALAADCgUIBQAAAA==.巧克力布朗尼:BAABLAAFFH8rAAIKAAgIjCQXAQAGAwAKAAgIjCQXAQAGAwAAAA==.',['希尔']='希尔瓦娜思:BAABLAAECn8VAAIRAAcIsRnRigDNAQARAAcIsRnRigDNAQAAAA==.',['带秀']='带秀:BAACLAAFFH8LAAILAAMIExqnGQDlAAALAAMIExqnGQDlAAAsAAQKfxQAAgsACAieHLAqAGcCAAsACAieHLAqAGcCAAAA.',['带花']='带花:BAAALAADCgMIAwAAAA==.',['幸福']='幸福的八点五:BAAALAAECgEIAQAAAA==.',['幸运']='幸运的小九:BAAALAAFFAEIAQAAAA==.',['张灬']='张灬翼德:BAAALAAFFAYIAwAAAA==.',['强子']='强子哥:BAAALAADCgYIBgAAAA==.',['强扭']='强扭的甜瓜:BAAALAADCggIEQAAAA==.',['得加']='得加钱:BAABLAAFFH8FAAIEAAUI9w79IAAZAQAEAAUI9w79IAAZAQAAAA==.',['忧郁']='忧郁的小刺猬:BAAALAADCgIIAgAAAA==.',['怒小']='怒小风:BAAALAAECgYIBgAAAA==.',['思该']='思该:BAAALAAFFAIIAgAAAA==.',['息影']='息影皇后:BAAALAAECgMIAwAAAA==.',['恶魔']='恶魔丨之心:BAAALAAFFAIIAgAAAA==.',['情情']='情情:BAAALAAECgEIAQAAAA==.',['愤怒']='愤怒的小九:BAAALAAECgYIDAAAAA==.',['慢慢']='慢慢摸吧:BAABLAAFFH8IAAIXAAII0QnZDwAmAAAXAAII0QnZDwAmAAAAAA==.',['我从']='我从山里来:BAAALAADCggICQAAAA==.',['我儿']='我儿子兜兜:BAAALAAECgMIAwAAAA==.',['我就']='我就在后面打:BAAALAAECgYIDAAAAA==.',['我是']='我是小毛驴:BAAALAADCgIIAgAAAA==.',['我来']='我来打头阵:BAAALAAFFAEIAQAAAA==.',['我的']='我的心好冷:BAABLAAFFH8bAAIDAAYImCJLDwDMAQADAAYImCJLDwDMAQAAAA==.',['战似']='战似一猛虎:BAAALAAECgYIBgAAAA==.',['战神']='战神一小猎:BAAALAAFFAIIBAAAAA==.',['戰弑']='戰弑:BAAALAADCggICwAAAA==.',['把根']='把根留住:BAAALAADCgIIAgABLAAFFAYIJAANACklAA==.',['提小']='提小莫:BAAALAADCggICAAAAA==.',['摩西']='摩西尐姐:BAABLAAFFH8GAAIRAAYIDg5CJwDfAAARAAYIDg5CJwDfAAAAAA==.',['撩蔭']='撩蔭手王五:BAABLAAFFH8IAAMdAAIIDAodFgB7AAAdAAIIMAgdFgB7AAAeAAIIoghAGgBjAAAAAA==.',['无心']='无心想静静:BAABLAAFFH8KAAMfAAYIlhqSBQD4AQAfAAYIlhqSBQD4AQAeAAQIbgdUGACWAAAAAA==.',['无忧']='无忧嗄吖:BAAALAADCgQIBAAAAA==.',['无极']='无极剑士:BAAALAAECgIIAgAAAA==.',['无聊']='无聊的虎妞:BAAALAAECgYIBgAAAA==.',['无能']='无能的丈夫:BAAALAAFFAIIAgAAAA==.',['无良']='无良小僧:BAAALAAECgEIAQAAAA==.',['星熠']='星熠:BAAALAAECgYIBgAAAA==.',['星空']='星空丶丶:BAAALAAECgYIBwAAAA==.',['星黛']='星黛露:BAAALAAECgYIBwAAAA==.',['映橪']='映橪柒語:BAABLAAFFH8UAAMEAAYIqA9dGwBRAQAEAAYIqA9dGwBRAQAFAAUIPgrCHADrAAAAAA==.',['春来']='春来猪满园:BAABLAAFFH8OAAMHAAYIUxh+DQBtAQAHAAYIUxh+DQBtAQAGAAMIzQIAQQBaAAAAAA==.',['晓可']='晓可乃:BAAALAAECgYIBgAAAA==.',['晴天']='晴天:BAAALAAECgMIAwAAAA==.',['晴晴']='晴晴天天:BAAALAAECgQIBQAAAA==.',['暖暖']='暖暖的翡冷翠:BAAALAAECgYICAAAAA==.',['暗夜']='暗夜酱:BAAALAAECgQIBAAAAA==.',['暴力']='暴力代言人:BAACLAAFFH8QAAIGAAMISR2dNACiAAAGAAMISR2dNACiAAAsAAQKfxwAAgYACAgMHrgWACwCAAYACAgMHrgWACwCAAAA.暴力天使:BAAALAADCgIIAgAAAA==.',['暴躁']='暴躁小喵:BAACLAAFFH8OAAIRAAIIFCKSOgCvAAARAAIIFCKSOgCvAAAsAAQKfx0AAhEACAjJIdtBAGICABEACAjJIdtBAGICAAAA.',['最靓']='最靓的那个妹:BAAALAADCgYIBgAAAA==.',['月丶']='月丶运转:BAAALAAFFAIIBAABLAAFFAYIDgAOAKIbAA==.',['月夜']='月夜雨狸:BAABLAAECn8XAAILAAYIgBX4QABXAQALAAYIgBX4QABXAQAAAA==.',['月沐']='月沐神谕:BAAALAAECgMIAwAAAA==.',['有什']='有什么黑什么:BAAALAAECgYICQAAAA==.',['木仓']='木仓示申:BAAALAAFFAEIAQAAAA==.',['本命']='本命有希:BAAALAAECgcIDgAAAA==.',['枫花']='枫花韶华:BAAALAAFFAIIAgAAAA==.',['架下']='架下蔷薇:BAAALAADCgEIAQAAAA==.',['柠萌']='柠萌:BAABLAAFFH8HAAIRAAYIzRVnFAB/AQARAAYIzRVnFAB/AQAAAA==.柠萌冰激凌:BAABLAAFFH8JAAIRAAYIexQECgDtAQARAAYIexQECgDtAQAAAA==.柠萌小冻梨:BAAALAAFFAYIBAAAAA==.柠萌尐姐:BAABLAAFFH8MAAIRAAYIgBc0NABsAQARAAYIgBc0NABsAQAAAA==.柠萌达薇琪:BAAALAAFFAIIAgAAAA==.',['根号']='根号:BAACLAAFFH8sAAMRAAYIixvqJwCUAQARAAYIixvqJwCUAQATAAIICxk8HACYAAAsAAQKfyQAAxEABgi1JL5MAEYCABEABgiZI75MAEYCABMABgglIZ0rAB4CAAAA.',['桑杰']='桑杰斯:BAABLAAFFH8GAAIJAAYITwOTPwD8AAAJAAYITwOTPwD8AAAAAA==.',['桔梗']='桔梗之箭:BAAALAAECgYIBgAAAA==.',['桔豆']='桔豆豆:BAAALAADCgIIAgAAAA==.',['梅德']='梅德音侪纳尔:BAAALAAECgYIDQAAAA==.',['梦丶']='梦丶点滴五世:BAABLAAFFH8JAAIDAAIIohwZSACYAAADAAIIohwZSACYAAAAAA==.',['梦幻']='梦幻坏笑:BAAALAAECgQIBAAAAA==.',['棍子']='棍子放哪啦:BAAALAAFFAIIBAAAAA==.',['楚兮']='楚兮:BAABLAAECn8WAAIeAAcIQBqZFwD2AQAeAAcIQBqZFwD2AQAAAA==.',['檀裳']='檀裳:BAABLAAFFH8IAAMfAAIINgHQGQBDAAAfAAIINgHQGQBDAAAeAAII0QLlIwAjAAAAAA==.',['欢愉']='欢愉丶咖啡豆:BAAALAAECgYICwAAAA==.',['欧尼']='欧尼酱:BAAALAAFFAIIAgAAAA==.',['正义']='正义之光:BAAALAAECgUICgAAAA==.',['死亡']='死亡预兆:BAABLAAFFH8PAAMIAAMINQrcCQCEAAAIAAMINQrcCQCEAAAJAAIIFAPacQApAAAAAA==.',['死掉']='死掉的骑士:BAAALAAFFAEIAQAAAA==.',['死神']='死神猎手:BAAALAAECggICAAAAA==.',['水咲']='水咲萝拉:BAAALAAECgEIAQAAAA==.',['汉德']='汉德神牛:BAAALAAECgQIBAAAAA==.',['汩汩']='汩汩:BAABLAAFFH8PAAMXAAMIDwZfCwBYAAAXAAIIkwdfCwBYAAAFAAEICAM2PAAwAAAAAA==.',['沐丶']='沐丶丝:BAAALAADCgIIAgAAAA==.',['油炸']='油炸灬花生米:BAAALAAECgMIAwAAAA==.',['泯族']='泯族凨:BAABLAAFFH8IAAILAAIIfBi3SQCKAAALAAIIfBi3SQCKAAAAAA==.',['洛丹']='洛丹伦的秋叶:BAABLAAECn8WAAIYAAcIDhWUHQCjAQAYAAcIDhWUHQCjAQAAAA==.',['洛天']='洛天赋:BAAALAAFFAIIAgAAAA==.',['流年']='流年似水:BAAALAAFFAIIAwAAAA==.',['浅醉']='浅醉丶:BAAALAAECgYIDwAAAA==.',['浍夢']='浍夢之卷:BAAALAAECgYIBgAAAA==.',['海苔']='海苔饭团:BAACLAAFFH9BAAMbAAcINyQ1AwAmAgAbAAYInSQ1AwAmAgAgAAQI/g5qEwDZAAAsAAQKfygAAxsACAilImMJAAMDABsACAilImMJAAMDACAABghVIZYOAEYCAAAA.',['淡烟']='淡烟流水:BAACLAAFFH8dAAILAAYI8xZIFADAAQALAAYI8xZIFADAAQAsAAQKfxgAAgsABgg9If8cAA8CAAsABgg9If8cAA8CAAAA.',['深渊']='深渊:BAABLAAFFH8GAAINAAII+RnnNgCvAAANAAII+RnnNgCvAAABLAAFFAIICAAEAI4dAA==.',['清清']='清清小溪:BAAALAADCgUIBQAAAA==.',['温顺']='温顺的老虎:BAAALAAECgIIAgAAAA==.',['溡緔']='溡緔瘋雪:BAAALAAECgIIAgAAAA==.',['溪水']='溪水流风:BAAALAADCgIIAgAAAA==.',['潜行']='潜行小鸡:BAAALAAECgIIAgABLAAFFAQIAwABAAAAAA==.',['濑娅']='濑娅美莉:BAAALAAECgcIBwAAAA==.',['火火']='火火爱将:BAABLAAFFH8IAAMRAAII3Aa0rAA5AAARAAII3Aa0rAA5AAATAAEIMwMVHwAAAAAAAA==.',['火雷']='火雷水猫:BAAALAAECgUIBQAAAA==.',['灬夜']='灬夜雨凝伤:BAACLAAFFH8IAAIEAAIIjho3NACZAAAEAAIIjho3NACZAAAsAAQKfxsAAgQACAj0FlQmAKgBAAQACAj0FlQmAKgBAAAA.',['灬护']='灬护熊牛灬:BAAALAAECgYIDQAAAA==.',['灬炎']='灬炎帝灬:BAAALAAECgEIAQAAAA==.',['灬熙']='灬熙:BAABLAAFFH8IAAIKAAIIZRR6RQCVAAAKAAIIZRR6RQCVAAAAAA==.',['灬霜']='灬霜枫怜灬:BAAALAAECgEIAQAAAA==.',['灬风']='灬风华灬:BAAALAAECgIIAgAAAA==.',['灰灰']='灰灰牛:BAAALAAECgYIDgAAAA==.',['炊事']='炊事班长:BAACLAAFFH8HAAIMAAII3xTvFgBBAAAMAAII3xTvFgBBAAAsAAQKfygAAgwACAjkHXAHAFcCAAwACAjkHXAHAFcCAAAA.',['炸毛']='炸毛男:BAAALAADCggICAAAAA==.',['炼乳']='炼乳丶稀奶油:BAAALAADCgEIAQAAAA==.',['烈焰']='烈焰灼天:BAAALAAFFAIIAgAAAA==.',['烟雨']='烟雨疏行:BAAALAAFFAIIBAAAAA==.',['烣烬']='烣烬使者:BAAALAADCgIIAgAAAA==.',['焖鸡']='焖鸡兄:BAAALAAECgEIAQAAAA==.',['煮茶']='煮茶丶:BAAALAADCgQIBAAAAA==.',['爪哇']='爪哇夜未眠:BAAALAADCgEIAQAAAA==.',['牛奶']='牛奶丶猎手:BAAALAAECgIIAgAAAA==.',['牧泽']='牧泽:BAAALAAECgYIBgAAAA==.',['牧灬']='牧灬心:BAAALAADCgQIBAAAAA==.',['狐老']='狐老妖:BAAALAADCgcICQAAAA==.',['狠贪']='狠贪玩:BAAALAAECgIIAgAAAA==.',['狩魔']='狩魔者:BAAALAAFFAIIBAAAAA==.',['独依']='独依望江楼:BAAALAAECggICAAAAA==.',['独角']='独角兽吃豆芽:BAAALAAECgcIAwAAAA==.',['狼殿']='狼殿下:BAABLAAFFH8JAAIDAAQIpAmfOAC/AAADAAQIpAmfOAC/AAAAAA==.',['猎影']='猎影:BAAALAAECggIEwAAAA==.',['猪小']='猪小熊:BAAALAAECgcIEgAAAA==.猪小绮:BAAALAAECgUIBwAAAA==.',['猫熊']='猫熊酒仙:BAABLAAFFH8tAAMhAAYIQR6tAQAnAQAGAAYI8RJ4JABMAQAhAAMImiGtAQAnAQAAAA==.',['班主']='班主任:BAAALAAECgYIDwAAAA==.',['琉光']='琉光丶:BAABLAAFFH8KAAIDAAYI6CGOAwA6AgADAAYI6CGOAwA6AgAAAA==.',['琴键']='琴键上的黑白:BAAALAAFFAIIBAAAAA==.',['电你']='电你叽三千:BAABLAAFFH8JAAISAAQIcRzREABpAQASAAQIcRzREABpAQAAAA==.',['电机']='电机马特:BAAALAAFFAIIBAAAAA==.',['电鸡']='电鸡小子:BAAALAADCgMIAwAAAA==.',['略懂']='略懂一二:BAAALAAECgEIAQAAAA==.',['疑是']='疑是银河:BAABLAAFFH8HAAIHAAQIRA32GQCRAAAHAAQIRA32GQCRAAAAAA==.',['疯狂']='疯狂的灬戦:BAAALAAECgYIBgAAAA==.',['百变']='百变星牛:BAAALAAFFAIIAgAAAA==.',['盜丶']='盜丶賊:BAAALAADCgMIAwAAAA==.',['盾牌']='盾牌护菊花:BAAALAAECgYIBgAAAA==.',['瞅一']='瞅一下:BAAALAAECgQIBAAAAA==.',['瞬间']='瞬间丶永恒:BAAALAAECgYIDwAAAA==.',['硬核']='硬核:BAABLAAFFH8GAAIRAAIIViS1egBmAAARAAIIViS1egBmAAAAAA==.',['神圣']='神圣:BAAALAAECgMIAwAAAA==.',['神知']='神知吾知:BAACLAAFFH8GAAMiAAIIehlpDQCrAAAiAAIIehlpDQCrAAACAAIIvQdinQA3AAAsAAQKfxQAAwIABgiUFZ/bAHQBAAIABggbFZ/bAHQBACIAAQhHEtxYAEUAAAAA.',['祥瑞']='祥瑞:BAAALAAECgYIDQABLAAFFAIICQADAKMPAA==.',['移动']='移动的城堡:BAABLAAFFH8NAAILAAIIwAIfdQBDAAALAAIIwAIfdQBDAAAAAA==.',['竖起']='竖起来:BAAALAAECgYIBgAAAA==.',['笼中']='笼中雀:BAABLAAFFH8NAAIRAAgIIgeXaACVAAARAAgIIgeXaACVAAAAAA==.',['糖醋']='糖醋鲤鱼:BAAALAADCgIIAgAAAA==.',['糖门']='糖门拱工具人:BAAALAADCgYIBgAAAA==.',['糜夫']='糜夫人:BAAALAAFFAIIAgAAAA==.',['紫炎']='紫炎焚天:BAAALAAECggIAQAAAA==.',['紫色']='紫色恋歌:BAAALAADCgcIDQAAAA==.',['终于']='终于了解自由:BAAALAAECgEIAQAAAA==.',['绘梦']='绘梦之全:BAAALAAECgYIBgAAAA==.',['统领']='统领牛牛:BAAALAAECgYIDAAAAA==.',['罗贝']='罗贝尔特:BAAALAAECgUIBgAAAA==.',['美丽']='美丽的可爱:BAAALAADCgIIAgAAAA==.',['美艳']='美艳如花:BAACLAAFFH8hAAIEAAYIbxaCCgBcAQAEAAYIbxaCCgBcAQAsAAQKfxwAAgQACAhXG4goAEMCAAQACAhXG4goAEMCAAAA.',['老是']='老是歪:BAAALAADCggIBwAAAA==.',['老茶']='老茶的第二天:BAABLAAFFH8HAAIMAAII9xgHDQCdAAAMAAII9xgHDQCdAAAAAA==.',['肆灬']='肆灬魔:BAAALAAECgIIAgAAAA==.',['肥嘟']='肥嘟嘟:BAABLAAFFH8OAAMIAAYIyR3aCgC2AAAJAAYIyR3kKAB3AQAIAAIINB/aCgC2AAAAAA==.',['良乐']='良乐:BAAALAADCgMIAwAAAA==.',['艾音']='艾音塞露:BAACLAAFFH8UAAIJAAYIbSOHFADnAQAJAAYIbSOHFADnAQAsAAQKfxUABAkABgg/HfstAJkBAAkABghAHPstAJkBACMAAQjkHZ42AFYAAAgAAQiVFHSWADwAAAEsAAUUCAgNAAkAXwYA.',['芳心']='芳心纵火犯:BAAALAAFFAIIBAAAAA==.',['苗淼']='苗淼开风车:BAACLAAFFH8MAAMTAAMIHgmMGQClAAATAAMIuQaMGQClAAARAAMINggHfQBgAAAsAAQKfxUAAxMACAgeFS8yAPkBABMACAgeFS8yAPkBABEABQjSDcDdAMMAAAAA.',['茉儿']='茉儿:BAAALAADCgYIBgAAAA==.',['莣尘']='莣尘:BAAALAAECgMIAwAAAA==.',['莱恩']='莱恩暗语:BAAALAAECgEIAQAAAA==.莱恩雪影:BAAALAAECgIIAQABLAAFFAgIOAAGAHgjAA==.',['萨小']='萨小蒙:BAAALAAFFAIIBAAAAA==.',['落花']='落花听风:BAAALAADCggIEAAAAA==.',['蓄意']='蓄意挑衅丶:BAABLAAFFH8IAAIKAAIIRAnBVACHAAAKAAIIRAnBVACHAAAAAA==.',['蓝色']='蓝色梦想:BAAALAAECggIEAAAAA==.',['蓝莓']='蓝莓拿铁:BAAALAAECgEIAQAAAA==.蓝莓柠檬奶茶:BAAALAAECgIIAgAAAA==.',['薄荷']='薄荷丨红茶:BAAALAAECgEIAQAAAA==.薄荷丶紅嗏:BAACLAAFFH8HAAIYAAIIhwnTFABnAAAYAAIIhwnTFABnAAAsAAQKfxgAAhgACAjkDtsUADgBABgACAjkDtsUADgBAAAA.',['薇薇']='薇薇安:BAAALAAECggICAAAAA==.',['藥到']='藥到命除:BAAALAAFFAIIAgAAAA==.',['虎必']='虎必煭怒风:BAAALAADCgQIBAAAAA==.',['虚光']='虚光:BAAALAADCggICwAAAA==.',['虚白']='虚白:BAAALAAECgYIBgAAAA==.',['血溅']='血溅黄沙:BAABLAAFFH8IAAIHAAII7ATcOQAkAAAHAAII7ATcOQAkAAAAAA==.',['血色']='血色丨邦桑迪:BAABLAAFFH8RAAIYAAYIixlJCQCFAQAYAAYIixlJCQCFAQAAAA==.血色的黄昏:BAAALAADCgEIAQAAAA==.',['补精']='补精返脑:BAAALAAECgMIAwAAAA==.',['西鎍']='西鎍:BAABLAAFFH8NAAIRAAIIBRYQZQCIAAARAAIIBRYQZQCIAAAAAA==.',['詩言']='詩言丶:BAABLAAFFH8IAAIHAAgIsxinAwApAgAHAAgIsxinAwApAgAAAA==.',['譕煈']='譕煈:BAAALAAFFAYIAQAAAA==.',['许普']='许普諾斯:BAAALAAECgEIAQAAAA==.',['调皮']='调皮牛牛:BAAALAAECgYICAAAAA==.调皮贝贝:BAAALAADCgYIBgAAAA==.',['谜之']='谜之吉祥物:BAAALAADCgUIBgAAAA==.',['赊刀']='赊刀人:BAAALAADCgYIBgAAAA==.',['赫本']='赫本:BAACLAAFFH8FAAICAAIIRhmhegBIAAACAAIIRhmhegBIAAAsAAQKfxcAAgIABggcHBpFAHQBAAIABggcHBpFAHQBAAAA.',['躺尸']='躺尸老木反:BAAALAADCgQIBAAAAA==.',['轩狠']='轩狠贪玩:BAABLAAECn8WAAILAAcIaR8hNgA9AgALAAcIaR8hNgA9AgAAAA==.',['过河']='过河卒:BAAALAAFFAIIAgAAAA==.',['追忆']='追忆灬兜兜:BAAALAADCgUIBwAAAA==.',['逐风']='逐风者艾希尔:BAAALAAECgYIBgAAAA==.',['逝去']='逝去的靈繉:BAAALAAECgEIAQAAAA==.',['速布']='速布台:BAAALAADCgUICQAAAA==.',['逸灬']='逸灬风:BAAALAADCggICAAAAA==.',['邪念']='邪念:BAABLAAFFH8KAAMIAAIIvAqFHwBvAAAJAAIIQgq+SgCKAAAIAAIIuAWFHwBvAAAAAA==.',['邪焰']='邪焰丶星辰:BAAALAAECgMIAwAAAA==.',['部落']='部落上等兵:BAABLAAECn8WAAIGAAcIeQ5oiwBvAQAGAAcIeQ5oiwBvAQAAAA==.',['酥脆']='酥脆曲奇:BAAALAAFFAIIAgAAAA==.',['醉后']='醉后一螩喍:BAAALAAFFAIIAgAAAA==.醉后一阵风:BAAALAAFFAIIAQAAAA==.',['醉意']='醉意丶:BAABLAAFFH8GAAIUAAYIEyKFBQBCAgAUAAYIEyKFBQBCAgAAAA==.',['醉爱']='醉爱杀戮:BAABLAAFFH8MAAICAAMIRRIQYgCKAAACAAMIRRIQYgCKAAAAAA==.醉爱秋天:BAABLAAFFH8PAAIKAAUIPAvhMQAEAQAKAAUIPAvhMQAEAQAAAA==.',['醉笑']='醉笑人生:BAAALAAECggIBAAAAA==.',['醉落']='醉落沙场:BAABLAAECn8WAAMLAAYINRfddwCSAQALAAYINRfddwCSAQASAAYIQxTpawB3AQAAAA==.',['醉风']='醉风行:BAAALAAECgYIBgAAAA==.',['鐵心']='鐵心:BAACLAAFFH8iAAMCAAUIMBk7RgCqAAACAAQIOB07RgCqAAAYAAMICAi8FQBnAAAsAAQKfyoAAwIACAjbH20aAAYDAAIACAjbH20aAAYDABgABwhYCy8rACMBAAAA.',['钢铁']='钢铁娘们:BAABLAAFFH8HAAIEAAIIbAkfPgBiAAAEAAIIbAkfPgBiAAAAAA==.',['锐变']='锐变绝:BAAALAAFFAIIAgAAAA==.',['锦江']='锦江渝:BAABLAAECn8VAAIGAAcI1xlDTQAJAgAGAAcI1xlDTQAJAgAAAA==.',['闪光']='闪光的哈萨维:BAABLAAFFH8GAAISAAYISgAiVQAhAAASAAYISgAiVQAhAAAAAA==.',['阿什']='阿什丽:BAACLAAFFH8XAAIgAAUIYhQhDQByAQAgAAUIYhQhDQByAQAsAAQKfycAAiAACAg8JMwAAD0DACAACAg8JMwAAD0DAAAA.',['阿尔']='阿尔图罗:BAAALAAECgIIAgAAAA==.',['阿桃']='阿桃:BAAALAADCggICwAAAA==.',['阿洛']='阿洛伊斯塔萨:BAABLAAFFH8OAAIbAAMIPB1lDgD4AAAbAAMIPB1lDgD4AAABLAAFFAgIGwANALcgAA==.',['阿芙']='阿芙罗狄蒂:BAAALAAECgIIAgAAAA==.',['陆伯']='陆伯言:BAABLAAFFH8KAAMOAAMIhgR1NQCQAAAOAAMIhgR1NQCQAAAPAAEIngKlMgAlAAAAAA==.',['隔壁']='隔壁的绿茶:BAAALAAECgYICAAAAA==.',['雨天']='雨天下的阳光:BAAALAAFFAIIBAAAAA==.',['雲芒']='雲芒:BAABLAAFFH8IAAICAAQIHAwfVADCAAACAAQIHAwfVADCAAAAAA==.',['零度']='零度可乐:BAABLAAFFH8FAAIOAAII4AWJRgBeAAAOAAII4AWJRgBeAAAAAA==.',['零点']='零点狂拽:BAAALAADCgYIBgAAAA==.',['雷人']='雷人:BAAALAAECgYIBgAAAA==.',['雷王']='雷王:BAAALAAECgUIBAAAAA==.',['霓裳']='霓裳叮当:BAAALAAECgYIBgAAAA==.',['霸道']='霸道的老二:BAABLAAFFH8HAAICAAUIcAXKUwDFAAACAAUIcAXKUwDFAAAAAA==.',['靈魂']='靈魂脫臼:BAACLAAFFH8UAAIOAAMIYQZ6NQCQAAAOAAMIYQZ6NQCQAAAsAAQKfxgAAg4ABghoDK5DANAAAA4ABghoDK5DANAAAAAA.',['青段']='青段:BAAALAAECgYICAAAAA==.',['靚点']='靚点无所谓:BAAALAADCgQIBAAAAA==.',['面包']='面包机:BAACLAAFFH8bAAMNAAgItyA0BACtAgANAAgItyA0BACtAgAMAAIIUwv2FgB9AAAsAAQKfyIAAw0ACAi0H20jAMACAA0ACAjLHm0jAMACAAwABwhLFkkwALoBAAAA.',['颜汐']='颜汐:BAAALAAECgUIBQAAAA==.',['风尘']='风尘悠悠:BAAALAAECgYICwAAAA==.',['风帆']='风帆:BAABLAAECn8WAAIMAAcIhhvKHQAtAgAMAAcIhhvKHQAtAgAAAA==.',['风暴']='风暴丨烈酒:BAAALAAECggICAAAAA==.',['风轻']='风轻云淡丶:BAAALAAECgYICQAAAA==.',['风雷']='风雷之翼:BAACLAAFFH8HAAICAAQIcAiAUwDHAAACAAQIcAiAUwDHAAAsAAQKfygAAgIACAjFHF8UAEUCAAIACAjFHF8UAEUCAAAA.',['风骚']='风骚马特:BAAALAAFFAYIAwAAAA==.',['飢寒']='飢寒之末:BAAALAAECggICAAAAA==.',['饿昏']='饿昏的猪:BAAALAAECgIIAgAAAA==.',['马哥']='马哥爱大胖彤:BAAALAAECgQIBAAAAA==.',['骨殇']='骨殇:BAAALAAECggICAAAAA==.',['魂之']='魂之挽歌:BAAALAAECgEIAQAAAA==.',['魅力']='魅力丨华少爷:BAAALAAECggICAAAAA==.',['魔法']='魔法少女喵:BAABLAAFFH8SAAILAAYI6BXgGgCGAQALAAYI6BXgGgCGAQAAAA==.',['魔異']='魔異貝貝:BAAALAAECgYICAAAAA==.',['魔鬼']='魔鬼:BAAALAAECggIBgAAAA==.魔鬼的步伐:BAAALAAECggIAwAAAA==.',['麟子']='麟子:BAAALAAECgUIBQAAAA==.',['麻辣']='麻辣咸鱼:BAAALAAECgYICgAAAA==.',['黑市']='黑市拾贰:BAAALAAFFAQIBAAAAA==.',['黑暗']='黑暗大主教:BAAALAAECgEIAQAAAA==.',['黑牛']='黑牛的妹妹:BAAALAADCgIIAgAAAA==.',['黑骑']='黑骑士灬:BAABLAAFFH8FAAMCAAMI3A/KXACaAAACAAII3BbKXACaAAAYAAEI3AFrGwAzAAAAAA==.',['龍丶']='龍丶熙熙:BAABLAAFFH8OAAIQAAIIGAbrBABlAAAQAAIIGAbrBABlAAAAAA==.龍丶艳:BAAALAADCggICgAAAA==.',['龍艳']='龍艳缘:BAAALAAECgIIAgAAAA==.',['龍訡']='龍訡:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end