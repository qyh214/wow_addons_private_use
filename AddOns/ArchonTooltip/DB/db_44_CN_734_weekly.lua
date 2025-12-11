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
 local lookup = {'Shaman-Elemental','Druid-Restoration','DemonHunter-Vengeance','DemonHunter-Havoc','DeathKnight-Frost','Paladin-Retribution','DeathKnight-Unholy','Evoker-Preservation','Paladin-Protection','Monk-Brewmaster','Priest-Holy','Rogue-Assassination','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Windwalker','Mage-Frost','Shaman-Restoration','Mage-Arcane','Warrior-Protection','Warlock-Destruction','Warlock-Demonology','Druid-Balance','Warrior-Fury','Mage-Fire','Evoker-Augmentation','Priest-Shadow','Paladin-Holy','Unknown-Unknown','Druid-Guardian','DeathKnight-Blood','Hunter-Survival','Druid-Feral','Evoker-Devastation',}; local provider = {region='CN',realm='海达希亚',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acholo:BAAALAAFFAIIBAAAAA==.Achoso:BAAALAAECgQIBAAAAA==.Achouo:BAABLAAFFH8JAAIBAAYIuRwSBQA4AgABAAYIuRwSBQA4AgAAAA==.Achoxo:BAAALAAECgEIAQAAAA==.',Ak='Akoe:BAAALAADCgcIBwAAAA==.',Ap='Aphrodlte:BAAALAADCggICAAAAA==.',Ar='Arths:BAAALAAECggICAAAAA==.',As='Astrid:BAAALAADCggIDgAAAA==.',Az='Az:BAAALAAFFAIIBAAAAA==.',Be='Bellemm:BAAALAADCgYIBgAAAA==.',Bi='Bigboss:BAAALAADCgQIBAAAAA==.',Cl='Cloudvzai:BAABLAAECn8YAAICAAgIexLHjwD5AAACAAgIexLHjwD5AAAAAA==.',Cy='Cydiaforever:BAAALAAECgQIBAAAAA==.',De='Demomine:BAABLAAFFH8LAAMDAAIIEBhlDwB6AAAEAAIIPgdUVQCHAAADAAIIEBhlDwB6AAAAAA==.',Dk='Dktank:BAABLAAFFH8GAAIFAAIIYQWviACAAAAFAAIIYQWviACAAAAAAA==.',Ed='Eden:BAAALAAECgQIBAAAAA==.',Fu='Fufu:BAAALAADCgIIAgAAAA==.',Hy='Hydraseren:BAAALAADCggIEgAAAA==.',Im='Imfiredup:BAAALAADCggICAAAAA==.',Iv='Ivanna:BAAALAAECgcIEwAAAA==.',Ke='Keeploving:BAAALAADCgEIAQAAAA==.',Ki='Kittywo:BAABLAAFFH8XAAIGAAYIqiIICgD3AQAGAAYIqiIICgD3AQAAAA==.Kittyyue:BAAALAAFFAYIAwAAAA==.',Ku='Kumo:BAABLAAFFH8PAAIFAAgIHx6/BgCOAgAFAAgIHx6/BgCOAgAAAA==.',La='Laopao:BAAALAAECgYIEgAAAA==.',Lg='Lggbicu:BAAALAADCgIIAgAAAA==.',Ly='Lyi:BAAALAAECgYIDQAAAA==.',Na='Naxx:BAAALAADCgIIAgAAAA==.',Ol='Oliviapaler:BAAALAADCgYIDQAAAA==.',Pl='Playeredmsag:BAAALAAECggICAAAAA==.',Pp='Ppoison:BAABLAAFFH8GAAIHAAIIihEIEwCNAAAHAAIIihEIEwCNAAAAAA==.',Sa='Santamina:BAACLAAFFH9UAAIIAAgIoSYKAAB2AwAIAAgIoSYKAAB2AwAsAAQKfyMAAggACAi5JQEBAGIDAAgACAi5JQEBAGIDAAAA.',Se='Sersbhsdh:BAAALAAFFAIIAgAAAA==.',So='Souldk:BAAALAAECgYIBAAAAA==.Soulweaver:BAAALAAECgMIAwAAAA==.',St='Stankss:BAABLAAFFH8eAAIJAAUIyxOeCQDLAAAJAAUIyxOeCQDLAAAAAA==.Stonn:BAABLAAFFH8wAAIKAAcI+gp9EQAyAQAKAAcI+gp9EQAyAQAAAA==.',Te='Tenet:BAAALAAECgYIBgAAAA==.',To='Toobe:BAAALAAECgEIAQAAAA==.Tortville:BAABLAAFFH8tAAILAAYI3B6sCgAeAgALAAYI3B6sCgAeAgAAAA==.',Vi='Vitruvianus:BAAALAAFFAMIAwABLAAFFAgISAAMAI4mAA==.Vitruvius:BAACLAAFFH9IAAMMAAgIjiZOAACLAgAMAAgIjiZOAACLAgANAAMI0hf3CQD6AAAsAAQKfzMAAwwACAjDJRICAGEDAAwACAjDJRICAGEDAA0ABAjLIW0kAHIBAAAA.Vivvan:BAABLAAECn8VAAMOAAgIUx6wNACIAgAOAAgIUx6wNACIAgAPAAYIBRCwZAAvAQAAAA==.',Vs='Vshaman:BAAALAADCgQIBAAAAA==.',Ww='Wwsilent:BAAALAADCggICgAAAA==.',Xe='Xenoblade:BAACLAAFFH8IAAIBAAUIyxA+JgAVAQABAAUIyxA+JgAVAQAsAAQKfyUAAgEABgicIQs4ACcCAAEABgicIQs4ACcCAAAA.',['一岁']='一岁就很美丽:BAAALAADCggIDAAAAA==.一岁就很賊:BAAALAADCgYIBgAAAA==.',['一度']='一度迷失:BAAALAAFFAIIAgAAAA==.',['一梦']='一梦华胥:BAAALAADCgMIAwAAAA==.',['一箭']='一箭风骚:BAAALAAECgYIBgAAAA==.',['一粒']='一粒丶仙丹:BAAALAAECggICAAAAA==.',['一素']='一素年一:BAABLAAECn8WAAIQAAcIsQULSQD/AAAQAAcIsQULSQD/AAAAAA==.',['七宗']='七宗罪一傲慢:BAAALAAFFAMIAwAAAA==.七宗罪一暴怒:BAAALAAFFAcIAgAAAA==.七宗罪一贪食:BAAALAAECgYIBgAAAA==.',['万年']='万年铃铛:BAAALAAECgYIBwAAAA==.',['不甜']='不甜也不咸:BAACLAAFFH8UAAIRAAUI9BK9BQDtAAARAAUI9BK9BQDtAAAsAAQKfzMAAhEACAhnIUMKAPQCABEACAhnIUMKAPQCAAAA.',['专射']='专射玩家:BAAALAADCgEIAQAAAA==.',['丘比']='丘比特之神射:BAACLAAFFH9LAAMOAAgIQB4SBABCAgAOAAgI+B0SBABCAgAPAAUINhYhBwCuAQAsAAQKfx8AAw8ACAjaIhorACECAA8ABwh5IhorACECAA4ABwgKHTnCAHwBAAAA.',['两发']='两发和平卫士:BAAALAAECgYIDAAAAA==.',['丨鼻']='丨鼻涕虫丨:BAAALAAFFAMIAwAAAA==.',['丿雷']='丿雷电法王:BAABLAAFFH8IAAISAAYIaQHbRgCRAAASAAYIaQHbRgCRAAAAAA==.',['乂永']='乂永恒乂:BAAALAAECgcIBwAAAA==.',['久久']='久久:BAAALAAFFAMIBAAAAA==.',['乱侃']='乱侃:BAAALAAECgYIDQAAAA==.',['亦正']='亦正亦邪:BAAALAADCgQIBAAAAA==.',['人艰']='人艰不拆法:BAACLAAFFH8bAAITAAUInh4SEADnAQATAAUInh4SEADnAQAsAAQKfxoAAhMACAgrJi4MADUDABMACAgrJi4MADUDAAAA.人艰不拆猎:BAAALAAFFAIIBAAAAA==.',['仚屳']='仚屳屲冚:BAAALAAECgYIEgAAAA==.',['以德']='以德负人:BAAALAAECgYIBgAAAA==.',['伊凉']='伊凉:BAAALAADCgYIBgAAAA==.',['伊利']='伊利蛋风怒:BAAALAAFFAIIAgAAAA==.',['余音']='余音回响:BAAALAAECgIIAgAAAA==.',['你沐']='你沐什么霂:BAABLAAFFH8FAAIDAAMIaROyDABtAAADAAMIaROyDABtAAAAAA==.',['光明']='光明圣使:BAAALAADCgYIBgAAAA==.光明晨风:BAAALAADCgUIBQAAAA==.',['光脚']='光脚的劣人:BAAALAAECgQIBAAAAA==.光脚的咕咕:BAAALAAECgYICQAAAA==.光脚的奶萨:BAAALAAFFAIIAgAAAA==.光脚的恶魔:BAAALAAECgYICwAAAA==.光脚的狂战:BAABLAAFFH8FAAIUAAUIKAa4GgC8AAAUAAUIKAa4GgC8AAAAAA==.光脚的踏风:BAAALAAFFAEIAQAAAA==.光脚的防骑:BAAALAAECgMIAwAAAA==.',['兔子']='兔子芙芙:BAAALAAECgQIBAAAAA==.',['全球']='全球的闪电链:BAAALAAECgUICgAAAA==.',['其实']='其实是死骑:BAACLAAFFH8GAAIGAAYIhBDjHgBvAQAGAAYIhBDjHgBvAQAsAAQKfxgAAgYABggmIOA/AJ0BAAYABggmIOA/AJ0BAAAA.',['冬月']='冬月老师:BAABLAAFFH8FAAIOAAIIMhxKiABJAAAOAAIIMhxKiABJAAABLAAFFAMICQAFAMsPAA==.',['冰火']='冰火小小法:BAAALAAECgMIAwAAAA==.',['冷雨']='冷雨夜:BAAALAAFFAIIAgAAAA==.',['凉风']='凉风:BAAALAADCgYIBgAAAA==.',['凌晨']='凌晨两点:BAAALAADCgcIBwAAAA==.',['凡尘']='凡尘如梦:BAABLAAFFH8KAAIGAAMIGRnrPwCUAAAGAAMIGRnrPwCUAAAAAA==.',['凤雅']='凤雅玲:BAACLAAFFH8nAAIVAAYIFxTdLgBeAQAVAAYIFxTdLgBeAQAsAAQKfxkAAxUACAiXG2kvAIACABUACAiXG2kvAIACABYAAQgFG8+QAEYAAAEsAAUUBgg0ABcACRwA.',['刘橙']='刘橙橙:BAABLAAFFH8TAAIYAAUIHxoDJABOAQAYAAUIHxoDJABOAQAAAA==.',['刘莉']='刘莉莉:BAABLAAECn8YAAIEAAYICyN0JADNAQAEAAYICyN0JADNAQAAAA==.',['加里']='加里瑟斯:BAACLAAFFH8fAAIGAAUIuCPPEgAjAQAGAAUIuCPPEgAjAQAsAAQKfyQAAgYABgi5Jm4eACQCAAYABgi5Jm4eACQCAAAA.',['匪城']='匪城发哥:BAAALAAECgYICwAAAA==.匪城裁决:BAAALAAECgYIDAAAAA==.',['午茶']='午茶歇会儿:BAABLAAFFH8FAAITAAUIeBaSNQAjAQATAAUIeBaSNQAjAQAAAA==.',['华梅']='华梅丶李:BAABLAAFFH8IAAIJAAIIgyCuEwBXAAAJAAIIgyCuEwBXAAAAAA==.',['卡伦']='卡伦西:BAABLAAECn8cAAMVAAcIVxaAYgDKAQAVAAcIVxaAYgDKAQAWAAEI+wIUnAAyAAAAAA==.',['卡比']='卡比又隐身了:BAABLAAFFH81AAMMAAcIghreBQB2AQAMAAYIYRfeBQB2AQANAAQI7hJPCwDcAAAAAA==.卡比太嗯了:BAABLAAFFH8SAAMYAAYIORDPHwBtAQAYAAYIORDPHwBtAQAUAAIIowrsNAAtAAAAAA==.卡比起飞了:BAAALAAECgYIBgAAAA==.',['古爾']='古爾丹:BAACLAAFFH8KAAIVAAIIPAgEYQA+AAAVAAIIPAgEYQA+AAAsAAQKfxcAAhUABwgTFcMxAIUBABUABwgTFcMxAIUBAAAA.',['可口']='可口可乐:BAABLAAFFH8MAAIFAAIIER++cQBPAAAFAAIIER++cQBPAAAAAA==.',['可爱']='可爱小小球:BAAALAADCgcIBwAAAA==.可爱小小豆:BAAALAAECgIIAgAAAA==.',['叶子']='叶子雨露:BAAALAADCgYIAwAAAA==.',['名字']='名字太难想了:BAABLAAFFH8KAAIUAAMIggm6FACsAAAUAAMIggm6FACsAAAAAA==.',['吐泡']='吐泡泡:BAAALAAECgYIEAAAAA==.',['含笑']='含笑凋零:BAABLAAFFH8NAAIEAAMI3xvuFwAaAQAEAAMI3xvuFwAaAQAAAA==.',['咏玖']='咏玖月神:BAAALAAFFAIIBAAAAA==.咏玖略略:BAABLAAFFH8KAAIWAAII1RwLCwC1AAAWAAII1RwLCwC1AAAAAA==.咏玖瞎打:BAAALAAECgYICQAAAA==.咏玖阳雪:BAABLAAFFH8OAAICAAMIFxrlEAD0AAACAAMIFxrlEAD0AAAAAA==.',['咸鱼']='咸鱼大作战:BAACLAAFFH9PAAMTAAgIXyIhAgCYAgATAAgIXyIhAgCYAgAZAAEIjhxKCQBYAAAsAAQKfx0AAhMACAg2I50gAM0CABMACAg2I50gAM0CAAAA.咸鱼小神龙:BAABLAAFFH8UAAIaAAYIiBfLBACRAQAaAAYIiBfLBACRAQAAAA==.',['哀伤']='哀伤之握:BAABLAAFFH8IAAIFAAIIghDnhABDAAAFAAIIghDnhABDAAAAAA==.',['哈基']='哈基米:BAAALAADCgIIAgAAAA==.',['哈帝']='哈帝斯:BAAALAAECgIIAgAAAA==.',['哎呀']='哎呀丶啊呀:BAACLAAFFH8lAAIGAAcI4BwWEgC3AQAGAAcI4BwWEgC3AQAsAAQKfxQAAgYACAjnImUYABMDAAYACAjnImUYABMDAAAA.',['啾咪']='啾咪:BAABLAAFFH8SAAIbAAYIOhUCDgB/AQAbAAYIOhUCDgB/AQAAAA==.',['善变']='善变:BAAALAAFFAIIAgAAAA==.',['喵不']='喵不可言:BAABLAAFFH8SAAIcAAYIGhXKDwCJAQAcAAYIGhXKDwCJAQAAAA==.',['囚困']='囚困者:BAAALAAECgYIBgAAAA==.',['固伦']='固伦和孝:BAAALAAFFAYIBAABLAAFFAgIAgAdAAAAAA==.',['圣光']='圣光下的低泣:BAABLAAFFH8FAAIcAAII+iRxHADFAAAcAAII+iRxHADFAAAAAA==.圣光小妮蹄:BAAALAAFFAIIAgAAAA==.',['地狱']='地狱蛮妞:BAAALAADCgIIAgAAAA==.地狱魔人:BAAALAAECgQIBAAAAA==.',['坤坤']='坤坤练习生:BAABLAAECn8VAAIVAAgIhBqHGgANAgAVAAgIhBqHGgANAgAAAA==.坤坤话事人:BAAALAADCgYIBgAAAA==.',['堂岛']='堂岛之龙:BAAALAAECgEIAQAAAA==.',['墨瑾']='墨瑾小汐:BAAALAADCgUIBQAAAA==.',['夏和']='夏和小:BAACLAAFFH9JAAMLAAgIRyAMAAA7AwALAAgIRyAMAAA7AwAbAAYIhRYcDQCJAQAsAAQKfyUAAwsACAgsH90YAKYCAAsACAgsH90YAKYCABsABwjEIxQgAHICAAAA.',['夜醉']='夜醉弦楼:BAAALAAECgEIAQAAAA==.',['大地']='大地惊雷:BAAALAAECgMIAwAAAA==.',['大壮']='大壮丶:BAAALAAFFAIIAgAAAA==.',['大酋']='大酋长:BAAALAAFFAIIAgAAAA==.',['天哥']='天哥:BAAALAAECgYIBgAAAA==.',['天涯']='天涯孤客心:BAAALAAECgYICQAAAA==.',['天生']='天生大块头:BAAALAADCggICAAAAA==.',['天籁']='天籁小痕:BAAALAAFFAIIBAAAAA==.',['天语']='天语清音:BAAALAAFFAIIAgAAAA==.',['天选']='天选魔眼:BAAALAADCgEIAQAAAA==.',['奇洛']='奇洛:BAABLAAFFH8gAAIeAAUIegrDBQC8AAAeAAUIegrDBQC8AAAAAA==.',['奇纪']='奇纪死骑:BAABLAAFFH8GAAIFAAYIrQEYaQBxAAAFAAYIrQEYaQBxAAAAAA==.',['女神']='女神和女汉子:BAAALAADCgIIAgAAAA==.',['奶油']='奶油灬冰棍:BAAALAADCgcIBwAAAA==.',['妖娆']='妖娆的舞姿:BAAALAAECgUIBQAAAA==.',['宁姚']='宁姚:BAAALAAECgcIBwAAAA==.',['守护']='守护可可:BAAALAAECgMIAwAAAA==.',['宙斯']='宙斯跳大:BAABLAAFFH8FAAIfAAIIcRc8GQA8AAAfAAIIcRc8GQA8AAAAAA==.',['宝宝']='宝宝皮:BAABLAAFFH8PAAIgAAMIFRUeAwCLAAAgAAMIFRUeAwCLAAAAAA==.',['寂寞']='寂寞的图腾:BAAALAAECgYIEgAAAA==.',['小亚']='小亚雄:BAAALAAECgYIBgAAAA==.',['小小']='小小的新娘:BAAALAADCgQIBAAAAA==.小小赖:BAABLAAFFH8GAAILAAIIhSC2MACoAAALAAIIhSC2MACoAAAAAA==.小小钟:BAABLAAFFH8LAAICAAIIcRrKOgCDAAACAAIIcRrKOgCDAAAAAA==.',['小猪']='小猪存钱罐:BAACLAAFFH9OAAQTAAgIECQXAQD6AgATAAgI5SMXAQD6AgAZAAYIgh6vAAARAgARAAMI/SIFCgDSAAAsAAQKfyEABBMACAgfJfgUAAQDABMACAhPJPgUAAQDABkAAwiCIfAQAAcBABEAAgg1JfNpAMgAAAAA.',['小贼']='小贼无名:BAABLAAECn8WAAIMAAYIqhQAEwA5AQAMAAYIqhQAEwA5AQAAAA==.',['岁岁']='岁岁小雪花:BAAALAAECgYIBgAAAA==.',['岁数']='岁数小凭次数:BAAALAAECgEIAQAAAA==.',['崩拳']='崩拳:BAAALAAECgYIBwAAAA==.',['川北']='川北凉粉:BAAALAAECgcIEwAAAA==.',['巫山']='巫山不是云:BAAALAAECgYIDAAAAA==.',['弑天']='弑天无敌:BAAALAADCgQIBAAAAA==.弑天飞翔:BAAALAAECgIIAgAAAA==.',['张小']='张小馋:BAAALAAECgUIBQAAAA==.',['御兵']='御兵:BAAALAAECgIIAgAAAA==.',['心似']='心似天河:BAAALAAECgUICAAAAA==.',['心如']='心如汁水:BAAALAADCgMIAgAAAA==.',['忍者']='忍者神龟:BAAALAAECggIEgABLAAECggIFQAVAIQaAA==.',['思考']='思考的技术:BAABLAAFFH8FAAIFAAII+RIGZACWAAAFAAII+RIGZACWAAAAAA==.',['怪诶']='怪诶:BAAALAADCgYICQAAAA==.',['恶魔']='恶魔之握:BAAALAAECgYIBwAAAA==.恶魔鼻嘎:BAAALAAECgQIBwAAAA==.',['慢走']='慢走看云:BAABLAAFFH8MAAITAAYIFRZsDAAFAgATAAYIFRZsDAAFAgAAAA==.',['我也']='我也很无奈吖:BAABLAAFFH8hAAIcAAYI6RL2CACHAQAcAAYI6RL2CACHAQAAAA==.',['我选']='我选李德全:BAAALAAECgcIDQABLAAECggIFQAVAIQaAA==.',['战丶']='战丶凡尘:BAABLAAFFH8FAAIYAAIIUgs3QwCIAAAYAAIIUgs3QwCIAAAAAA==.',['托尼']='托尼大人:BAABLAAFFH8WAAIOAAYIMgyURAA3AQAOAAYIMgyURAA3AQAAAA==.',['折丶']='折丶戟:BAAALAAFFAYIAgAAAA==.',['指尖']='指尖起舞:BAAALAADCgYIBgAAAA==.',['散雪']='散雪千桜:BAAALAAECgUIBQAAAA==.散雪千樱:BAAALAAECgYIDAAAAA==.',['斯派']='斯派洛:BAAALAADCgYIBgAAAA==.',['斯迪']='斯迪安娜:BAAALAAECgQIBAAAAA==.',['新鲜']='新鲜感的救赎:BAAALAAECgIIAgAAAA==.',['无冬']='无冬城的月光:BAAALAAFFAIIAgAAAA==.',['无息']='无息梵炎:BAAALAAECggIDwAAAA==.',['无相']='无相之月:BAACLAAFFH8MAAIMAAIIzRR8FQCnAAAMAAIIzRR8FQCnAAAsAAQKfxcAAwwACAihFSkgABUCAAwACAihFSkgABUCAA0AAwiTCN1AAJUAAAAA.',['无限']='无限符文:BAAALAADCgQIBAAAAA==.',['明日']='明日圣斗士:BAAALAAECgEIAQAAAA==.',['易者']='易者:BAAALAADCgYIBgAAAA==.',['星川']='星川莉莉:BAAALAAECgYIBgAAAA==.',['星辰']='星辰武神:BAAALAAECgcIBwAAAA==.',['是梦']='是梦:BAABLAAFFH8VAAILAAMIjxkiKgDZAAALAAMIjxkiKgDZAAAAAA==.',['暴走']='暴走本子:BAABLAAFFH8OAAIBAAYIgAndIwAmAQABAAYIgAndIwAmAQAAAA==.',['未然']='未然清风:BAABLAAFFH8GAAIOAAYIyRWrNABpAQAOAAYIyRWrNABpAQAAAA==.',['枕头']='枕头:BAAALAADCgYICQAAAA==.',['柒片']='柒片:BAAALAAFFAIIAgAAAA==.',['桃夭']='桃夭:BAABLAAFFH8FAAIBAAUIKQAoVwACAAABAAUIKQAoVwACAAAAAA==.',['楼小']='楼小楼:BAAALAAECgEIAQAAAA==.',['樱灬']='樱灬风:BAAALAAECgQIBAAAAA==.',['樱花']='樱花残月:BAAALAAECgYIDAAAAA==.',['死灵']='死灵酒鬼:BAAALAAECgMIBQAAAA==.',['毛毛']='毛毛雨:BAAALAADCgQIBAAAAA==.',['水中']='水中望月:BAAALAAECgMIAwAAAA==.',['水粉']='水粉芊:BAABLAAFFH8GAAIEAAYIVQZCLgAnAQAEAAYIVQZCLgAnAQAAAA==.',['沧海']='沧海:BAAALAAECgYIBgAAAA==.',['法杖']='法杖上有眼睛:BAAALAADCggICAAAAA==.',['法球']='法球洛基:BAABLAAFFH8KAAMXAAYI5AylFAA9AQAXAAYI5AylFAA9AQAeAAIIlgZjEQAgAAAAAA==.',['法老']='法老王:BAAALAADCggICAAAAA==.',['浮生']='浮生偷闲:BAAALAAECggICAAAAA==.',['海力']='海力布:BAAALAAECgYICQAAAA==.',['海达']='海达叁世:BAAALAADCgYIBgAAAA==.',['清晨']='清晨的风:BAAALAADCggICAAAAA==.',['渤海']='渤海狍狍猪:BAAALAADCgEIAQAAAA==.渤海香猪:BAAALAADCggICgAAAA==.',['游侠']='游侠行者:BAAALAAECgMIAwAAAA==.',['漂浮']='漂浮炸弾:BAACLAAFFH80AAIXAAYICRwmDACfAQAXAAYICRwmDACfAQAsAAQKfxwAAhcACAh1IqQYAJ0CABcACAh1IqQYAJ0CAAAA.',['漫步']='漫步晴天:BAABLAAFFH8JAAIDAAII3QP5GQBOAAADAAII3QP5GQBOAAAAAA==.',['潘驴']='潘驴:BAAALAAECgYIDQAAAA==.',['灬淡']='灬淡陌灬:BAABLAAFFH8FAAIRAAIIJAZWIQAiAAARAAIIJAZWIQAiAAAAAA==.',['炎火']='炎火灬淼:BAABLAAFFH8GAAIeAAYIIh7fAQCgAQAeAAYIIh7fAQCgAQAAAA==.',['炫风']='炫风太子:BAAALAAECgcICQAAAA==.',['烧饼']='烧饼:BAAALAAFFAIIBAAAAA==.',['烬龙']='烬龙:BAAALAAECgIIAgAAAA==.',['熊萨']='熊萨:BAABLAAFFH8lAAMCAAYITCXMAACNAgACAAYITCXMAACNAgAhAAMIdhUbBwDkAAABLAAFFAgIAgAdAAAAAA==.',['熾天']='熾天使灬聖光:BAAALAAECgUIBQAAAA==.',['爱上']='爱上九点半:BAAALAAFFAMIAwAAAA==.',['爱好']='爱好是睡觉:BAAALAAECgIIAgAAAA==.',['特和']='特和的德:BAAALAADCgMIAwAAAA==.',['特色']='特色啊:BAAALAAFFAIIAgAAAA==.',['猎头']='猎头鲁鲁:BAAALAAECgQICQAAAA==.',['猪猪']='猪猪:BAAALAAFFAIIAgAAAA==.猪猪不迷路:BAABLAAFFH8GAAIUAAIIAyJ4HgCBAAAUAAIIAyJ4HgCBAAAAAA==.',['猪蛋']='猪蛋蛋:BAACLAAFFH8lAAITAAYIKCNBEgDnAQATAAYIKCNBEgDnAQAsAAQKfx4AAhMABwi6Iw47AF4CABMABwi6Iw47AF4CAAAA.',['猫熊']='猫熊的小伙伴:BAAALAADCgIIAgAAAA==.',['王权']='王权霸业:BAAALAAFFAIIAgAAAA==.',['王牛']='王牛奶:BAABLAAFFH8MAAIUAAIIyiOiFwCbAAAUAAIIyiOiFwCbAAAAAA==.',['王语']='王语嫣:BAAALAADCgcIBwAAAA==.',['玖伴']='玖伴酒:BAAALAAECggIDwAAAA==.',['玩玩']='玩玩想想:BAAALAADCgMIAwAAAA==.',['球咪']='球咪的胡子肉:BAAALAADCgIIAgAAAA==.',['瑟莱']='瑟莱德丝:BAAALAAECgYIEAAAAA==.',['甘道']='甘道夫:BAAALAADCgEIAQAAAA==.',['电子']='电子狂欢:BAAALAADCgIIAgAAAA==.',['电闪']='电闪雷鸣:BAAALAAECgcIDAAAAA==.',['疯狂']='疯狂豪哥:BAAALAAECgYICgAAAA==.',['白发']='白发老头:BAACLAAFFH8KAAMRAAQIORLTBQDrAAARAAMIsBfTBQDrAAATAAEI0gFEbgA6AAAsAAQKfxgAAxEABwiVIkYQAKcCABEABwiVIkYQAKcCABMAAwhvG6bGAOQAAAAA.',['百薇']='百薇:BAACLAAFFH8qAAMaAAcI6xd0AwDeAQAaAAcIsRZ0AwDeAQAiAAYIIxiACACeAQAsAAQKfy4AAyIACAjhH0IOAMsCACIACAjhH0IOAMsCABoAAQhjGBAPAEoAAAAA.',['看看']='看看我的小熊:BAAALAAECgYIDAAAAA==.',['石头']='石头小哥哥:BAAALAAECgYICgAAAA==.',['碧波']='碧波斜阳:BAABLAAFFH8GAAIGAAYIOA4QIwBWAQAGAAYIOA4QIwBWAQAAAA==.',['神王']='神王宙斯:BAACLAAFFH8QAAIGAAIIGBmEMgCpAAAGAAIIGBmEMgCpAAAsAAQKfyAAAgYACAgfIKo4AJICAAYACAgfIKo4AJICAAAA.',['离别']='离别电影:BAABLAAFFH8SAAITAAIIcx6KRQCaAAATAAIIcx6KRQCaAAABLAAFFAYIEgAVAPMlAA==.',['秋水']='秋水浮萍:BAABLAAFFH8JAAIGAAIILh4KNACnAAAGAAIILh4KNACnAAAAAA==.',['秋雅']='秋雅:BAABLAAFFH8GAAITAAYI8QL/OQD6AAATAAYI8QL/OQD6AAAAAA==.',['积雪']='积雪浮云端:BAAALAAECgMIAwAAAA==.',['稀丶']='稀丶薄:BAAALAAECgYIBgAAAA==.',['窗看']='窗看雨落:BAABLAAFFH8GAAITAAYIpRlxKAByAQATAAYIpRlxKAByAQAAAA==.',['第二']='第二勇士:BAAALAAECgYIBwAAAA==.',['筱丷']='筱丷绒绒:BAAALAADCgcIBwAAAA==.',['筱芙']='筱芙:BAABLAAECn8aAAIOAAYIuBQU1wBiAQAOAAYIuBQU1wBiAQAAAA==.',['粿条']='粿条超人:BAABLAAECn8VAAICAAgIoR0cHACGAgACAAgIoR0cHACGAgAAAA==.',['糖伯']='糖伯虎点蚊香:BAAALAAECgIIAgAAAA==.',['糖豆']='糖豆多多:BAAALAAFFAIIAgAAAA==.',['紫月']='紫月猎手:BAAALAAECgYIBgAAAA==.',['紫色']='紫色千幻:BAAALAAECgYIBwAAAA==.紫色幻箭:BAAALAADCgIIAgAAAA==.紫色狼牙:BAAALAAECggIDgAAAA==.',['紫辕']='紫辕璇艨:BAAALAAECgYICQAAAA==.',['緈諨']='緈諨囿點傻:BAABLAAFFH8KAAISAAMI/w22KgCuAAASAAMI/w22KgCuAAAAAA==.',['红龙']='红龙奇洛:BAACLAAFFH8wAAIIAAcIEh51BwD6AQAIAAcIEh51BwD6AQAsAAQKfyAAAggACAjhGnwRABoCAAgACAjhGnwRABoCAAAA.',['绊爱']='绊爱:BAAALAAFFAIIAgAAAA==.',['罗娜']='罗娜凯达:BAABLAAFFH8eAAIOAAYIzhehKwCGAQAOAAYIzhehKwCGAQABLAAFFAYINAAXAAkcAA==.',['罗红']='罗红霉素:BAAALAAECgcIEgAAAA==.',['美丽']='美丽无间:BAAALAAECgUIBQAAAA==.',['老僵']='老僵尸:BAABLAAFFH8GAAMWAAMIQRFgEgCfAAAWAAIIyxVgEgCfAAAVAAEILggRXQBKAAAAAA==.',['老枪']='老枪老炮:BAABLAAECn8WAAIOAAYI1wliyADiAAAOAAYI1wliyADiAAAAAA==.',['胖三']='胖三郎:BAAALAAECgYIDQAAAA==.',['胖妞']='胖妞:BAAALAAFFAIIBAAAAA==.',['胡须']='胡须儿:BAAALAAFFAIIBAAAAA==.',['花晨']='花晨月夕:BAAALAAECgYIDAAAAA==.',['花间']='花间未眠:BAABLAAFFH8UAAIRAAMINSEuCgCxAAARAAMINSEuCgCxAAAAAA==.',['芸海']='芸海深蓝:BAAALAAECgEIAQAAAA==.',['苏拉']='苏拉呢:BAABLAAFFH8TAAIMAAUIJBH/DQD0AAAMAAUIJBH/DQD0AAABLAAFFAUIHwAGALgjAA==.',['英雄']='英雄不朽:BAACLAAFFH8LAAIGAAMIpRj9FwD+AAAGAAMIpRj9FwD+AAAsAAQKfzcAAgYACAgaIoweAPgCAAYACAgaIoweAPgCAAAA.',['莫兰']='莫兰蒂斯:BAAALAAECgUIBQAAAA==.',['莫怡']='莫怡悠悠:BAABLAAFFH8kAAILAAYIRiAfDAAJAgALAAYIRiAfDAAJAgAAAA==.',['萌萌']='萌萌哒:BAABLAAFFH8RAAIVAAMIMh1cIAAiAQAVAAMIMh1cIAAiAQAAAA==.',['萨凯']='萨凯:BAABLAAFFH8OAAISAAUIlBkfHQDWAAASAAUIlBkfHQDWAAABLAAFFAgIAgAdAAAAAA==.',['萨鲁']='萨鲁法凛大王:BAABLAAFFH8MAAMUAAYIohSkCABeAQAYAAYIohTAGwCJAQAUAAYIrQWkCABeAQAAAA==.',['蓝瑟']='蓝瑟犹豫:BAAALAAECgYIDAAAAA==.',['蔚然']='蔚然橙风:BAAALAAECgIIAgAAAA==.',['藏镜']='藏镜人:BAAALAAFFAEIAQAAAA==.',['血月']='血月残天:BAAALAAECgQIAQAAAA==.',['血染']='血染哀伤:BAAALAAECgIIAgAAAA==.',['血疫']='血疫圆舞曲:BAABLAAECn8YAAMFAAYIfSNxZgApAgAFAAYIfSNxZgApAgAfAAQIOR40GQADAQAAAA==.',['西风']='西风狂诗:BAAALAAECgEIAQAAAA==.',['言念']='言念君子:BAAALAADCgMIAwAAAA==.',['讨厌']='讨厌:BAACLAAFFH9CAAMbAAgITCJiAAAdAwAbAAgITCJiAAAdAwALAAEI7AIBSwA5AAAsAAQKfxwAAhsACAiEJSpGAJ8BABsACAiEJSpGAJ8BAAAA.',['请叫']='请叫我绿毛怪:BAAALAAECgMIAgAAAA==.',['豆三']='豆三包丶:BAAALAADCgYIDAABLAADCggICAAdAAAAAA==.',['豪正']='豪正雄:BAABLAAFFH8FAAIKAAIIBxhrHQBDAAAKAAIIBxhrHQBDAAAAAA==.',['赖小']='赖小小:BAABLAAFFH8JAAIGAAMIYguXHgDZAAAGAAMIYguXHgDZAAAAAA==.',['赛塔']='赛塔洛斯:BAABLAAFFH8ZAAIGAAUImB3FEwAbAQAGAAUImB3FEwAbAQAAAA==.',['走样']='走样:BAABLAAFFH8IAAIFAAIIzA0UfgBGAAAFAAIIzA0UfgBGAAAAAA==.',['超元']='超元气萌你妹:BAABLAAFFH8bAAIUAAUITRWeCwAQAQAUAAUITRWeCwAQAQAAAA==.',['超级']='超级工程师:BAAALAADCgEIAQAAAA==.',['路德']='路德维希:BAAALAAECgMIAwAAAA==.',['轩辕']='轩辕天狂:BAAALAAECgEIAQAAAA==.',['迟到']='迟到的下午:BAABLAAFFH8MAAILAAMIowN+NgCJAAALAAMIowN+NgCJAAAAAA==.',['迪尔']='迪尔梅林:BAABLAAFFH8aAAIBAAUIERNNJQAcAQABAAUIERNNJQAcAQABLAAFFAYINAAXAAkcAA==.',['迷你']='迷你死之骑士:BAAALAADCgQIBAAAAA==.',['逍遥']='逍遥丶羽翎:BAAALAAECgUIBwAAAA==.',['邪火']='邪火:BAAALAAECgIIAgAAAA==.',['部落']='部落骑士:BAAALAAECgcICQAAAA==.',['酸酸']='酸酸的是我:BAAALAADCgEIAQAAAA==.',['醉梦']='醉梦忆生:BAABLAAFFH8SAAMVAAMI8yVwHwAuAQAVAAMI8yVwHwAuAQAWAAEI+iA4IwBZAAAAAA==.',['野性']='野性狂怒:BAAALAADCgEIAQAAAA==.',['铁蹄']='铁蹄:BAAALAADCgYIBgAAAA==.',['铜钱']='铜钱:BAAALAAECgIIAgAAAA==.',['银色']='银色月光:BAAALAADCgIIAgAAAA==.',['阿亿']='阿亿克:BAAALAAECgUIBQAAAA==.',['阿尔']='阿尔托利亚灬:BAAALAAECgMIAwAAAA==.',['阿萨']='阿萨姆德萨:BAAALAAECgYIBwAAAA==.',['陈风']='陈风笑:BAAALAAECgQIBQAAAA==.',['随机']='随机嗨姓刷子:BAAALAADCggICAAAAA==.',['隔壁']='隔壁老王:BAAALAAECgYIBgAAAA==.',['难于']='难于上青楼:BAABLAAFFH8NAAITAAUIDAyhOAAJAQATAAUIDAyhOAAJAQAAAA==.',['雨終']='雨終晴天:BAAALAAECgYIEgAAAA==.',['雷诺']='雷诺杰克逊:BAAALAAFFAIIAgAAAA==.',['雾去']='雾去哪了:BAAALAADCgYIBgAAAA==.',['霹雳']='霹雳苍穹:BAAALAAECgYIBgAAAA==.',['静葔']='静葔椛开:BAABLAAFFH8eAAIOAAYIMhqhJQCcAQAOAAYIMhqhJQCcAQABLAAFFAIIAgAdAAAAAA==.',['非著']='非著名财主:BAACLAAFFH8SAAICAAUIDBbJGgBWAQACAAUIDBbJGgBWAQAsAAQKfx4AAgIACAhtGbIRAEkCAAIACAhtGbIRAEkCAAAA.',['頑皮']='頑皮乄球:BAAALAADCgUIBQAAAA==.',['风之']='风之天香:BAABLAAFFH8GAAILAAQISwkWKgDaAAALAAQISwkWKgDaAAAAAA==.',['风暴']='风暴萨:BAABLAAFFH8KAAISAAII2BxEQAClAAASAAII2BxEQAClAAAAAA==.',['风雀']='风雀夜:BAAALAAFFAIIAgAAAA==.',['飞天']='飞天大蛆:BAAALAAFFAIIBAAAAA==.飞天神德:BAABLAAFFH8GAAICAAYIFxsUDwDPAQACAAYIFxsUDwDPAQAAAA==.',['飞翔']='飞翔的乌鸦:BAAALAAECggIDQAAAA==.',['饿么']='饿么猎手:BAAALAAECgEIAQAAAA==.',['骑士']='骑士小鱼:BAAALAADCgcIBwAAAA==.',['鬼卿']='鬼卿:BAABLAAFFH8NAAIOAAMIBRyZLgDKAAAOAAMIBRyZLgDKAAAAAA==.',['鬼斩']='鬼斩:BAAALAAECgMIAwAAAA==.',['鲸落']='鲸落于海:BAABLAAFFH8GAAMNAAII/xq4EACZAAAMAAIIdhZIFwChAAANAAIIShm4EACZAAABLAAFFAgIBgAMAPYbAA==.',['黎夕']='黎夕:BAAALAAECgYIDgAAAA==.',['黎雪']='黎雪:BAAALAAECgYIDwAAAA==.',['黑索']='黑索协奏曲:BAAALAAECgYICQAAAA==.',['黒镰']='黒镰:BAAALAADCgYIBgAAAA==.',['鼠尾']='鼠尾草:BAABLAAECn8pAAIOAAYIIxhWcwBdAQAOAAYIIxhWcwBdAQAAAA==.',['龍龖']='龍龖龘:BAABLAAFFH8KAAMOAAMIRhF7bwCDAAAOAAMItRB7bwCDAAAPAAIIJwyfLQBqAAAAAA==.',['龙哥']='龙哥上别怕:BAAALAADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end