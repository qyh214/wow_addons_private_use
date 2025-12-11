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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Warrior-Fury','Rogue-Assassination','Rogue-Subtlety','Shaman-Elemental','Shaman-Restoration','Mage-Arcane','DemonHunter-Vengeance','DeathKnight-Blood','Warrior-Protection','Evoker-Augmentation','Paladin-Protection','Paladin-Holy','Monk-Mistweaver','Druid-Restoration','Druid-Balance','Mage-Frost','Evoker-Preservation','Druid-Feral','Evoker-Devastation','Warlock-Destruction','Warlock-Affliction','Druid-Guardian','DemonHunter-Havoc','Warlock-Demonology','Priest-Holy','Priest-Shadow','Monk-Windwalker','Warrior-Arms','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='阿曼尼',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ad='Adamxx:BAABLAAFFH8GAAMBAAYICxDWFwCAAQABAAUI4RLWFwCAAQACAAEI3QEgGwBWAAAAAA==.Adc:BAABLAAFFH8IAAMDAAMI3xaPJADrAAADAAMI3xaPJADrAAAEAAIItQmgMABdAAAAAA==.Advaa:BAAALAAECgYIBwAAAA==.',Al='Allegro:BAAALAAFFAIIAgAAAA==.',At='At:BAAALAAECgUIBQAAAA==.Ataraxia:BAABLAAFFH8GAAIFAAIIwx0lJADCAAAFAAIIwx0lJADCAAAAAA==.',Au='Auqarseele:BAAALAAECgQIBAAAAA==.',Aw='Awm:BAAALAAECgUIDgAAAA==.',Ca='Cadenza:BAABLAAFFH8IAAIBAAIItAsjfACKAAABAAIItAsjfACKAAAAAA==.',Ch='Chanel:BAAALAAECgIIAgAAAA==.',De='Demonbell:BAAALAAECgMIAwAAAA==.',Eg='Egg:BAAALAAECgQIBAAAAA==.Eggz:BAAALAAECgYIDgAAAA==.',Fi='Firely:BAAALAAECgEIAQAAAA==.Fishman:BAABLAAFFH8GAAIDAAYI5xDaNwBkAQADAAYI5xDaNwBkAQAAAA==.',Ge='Genz:BAABLAAFFH8QAAIGAAYIPhbbIADCAAAGAAYIPhbbIADCAAAAAA==.Genzei:BAAALAAFFAIIBAAAAA==.',Gu='Gustas:BAAALAAECgYIBwAAAA==.',In='Inuzukakiba:BAAALAAECgUIBQAAAA==.',Ja='Jarlaxle:BAAALAAECggIEAAAAA==.',Ka='Kalon:BAAALAADCggICAAAAA==.',Ke='Keiko:BAABLAAFFH8QAAMHAAIIRiIZEwCxAAAHAAIIRiIZEwCxAAAIAAEIjhYMHQBCAAAAAA==.',Ky='Kyouxz:BAABLAAECn8WAAIGAAgIxx37HQD8AQAGAAgIxx37HQD8AQAAAA==.',Lu='Luvisa:BAAALAAECgYIBgAAAA==.',Ma='Madeinchina:BAAALAAECgYIBgAAAA==.Malcolm:BAAALAAFFAIIAgAAAA==.',Mi='Mizuu:BAAALAAECgQIBAAAAA==.',Ml='Mlgbz:BAAALAAECggIEAAAAA==.',Qi='Qiyi:BAABLAAFFH8FAAIEAAII+BgCIgCEAAAEAAII+BgCIgCEAAAAAA==.',Ri='Rita:BAABLAAFFH8LAAMJAAIIDQ5SLQCOAAAJAAIIDQ5SLQCOAAAKAAIITBerPACHAAAAAA==.',Se='Serenata:BAABLAAFFH8GAAILAAIIgwm2XgB+AAALAAIIgwm2XgB+AAAAAA==.',Si='Sixsixsixs:BAAALAAECgYIDgAAAA==.',Su='Sunlv:BAAALAAECgMIAwAAAA==.',Te='Tender:BAAALAADCgIIAgAAAA==.',Va='Vamplress:BAAALAAECgYIEgAAAA==.',Vi='Vivienne:BAAALAAECggIBAAAAA==.',Yo='Yoyol:BAAALAAECgcICwAAAA==.',['一万']='一万二:BAAALAAFFAgIBAAAAA==.',['一不']='一不小心就丶:BAAALAAFFAIIBAAAAA==.',['一世']='一世无橙:BAAALAAECgEIAQAAAA==.',['一只']='一只中脉动:BAABLAAFFH8GAAIMAAIIhhMHEAB2AAAMAAIIhhMHEAB2AAAAAA==.一只大脉动:BAABLAAFFH8GAAINAAIIERNUDwCMAAANAAIIERNUDwCMAAAAAA==.一只微脉动:BAACLAAFFH8GAAIOAAII/hCzIAB8AAAOAAII/hCzIAB8AAAsAAQKfxYAAg4ACAgrFfQoAPoBAA4ACAgrFfQoAPoBAAAA.一只老脉动:BAAALAAECgUICQAAAA==.',['一弦']='一弦一柱:BAAALAAECgUIBwAAAA==.',['一抹']='一抹丿涟漪:BAAALAAECgcIBwAAAA==.',['一碰']='一碰就倒:BAAALAAECgYIDwAAAA==.',['一起']='一起跳舞吧:BAAALAAECgEIAQAAAA==.',['七仟']='七仟二:BAABLAAFFH8NAAIPAAYIOyWZAgAjAgAPAAYIOyWZAgAjAgAAAA==.',['七妹']='七妹:BAAALAAECgUIBwAAAA==.',['三英']='三英战貂禅:BAABLAAFFH8HAAIQAAII4QvPGwBtAAAQAAII4QvPGwBtAAAAAA==.',['不会']='不会无敌:BAAALAAECgQIBAAAAA==.',['不能']='不能說的秘密:BAAALAAECgYICQAAAA==.',['不要']='不要叫我靓仔:BAAALAAECgYIDAAAAA==.',['东朗']='东朗路欧巴:BAAALAAECgUIBQAAAA==.',['两爪']='两爪空空:BAAALAAECgYIDwAAAA==.',['丧钟']='丧钟为你而鸣:BAAALAAECgUIEAAAAA==.',['丨残']='丨残美丶:BAAALAAECgYIEQAAAA==.',['丨美']='丨美女与野兽:BAAALAAECgEIAQAAAA==.',['丫头']='丫头肉:BAAALAAECgUIBQAAAA==.',['丶小']='丶小鸠:BAAALAAECgQIBAAAAA==.',['丶書']='丶書歌:BAAALAAECgIIAgAAAA==.',['丶楓']='丶楓:BAABLAAECn8dAAIRAAcIHyFtEgB/AgARAAcIHyFtEgB/AgAAAA==.',['丶欧']='丶欧气重重丶:BAABLAAFFH8GAAIBAAYIYBG+NgBmAQABAAYIYBG+NgBmAQAAAA==.',['丶残']='丶残雪:BAAALAAECgEIAQAAAA==.',['丶纠']='丶纠结丶:BAAALAAFFAIIAgAAAA==.',['丶阿']='丶阿丿寳丶:BAABLAAFFH8IAAISAAIIaRR1EQCKAAASAAIIaRR1EQCKAAAAAA==.',['举世']='举世无敌:BAAALAAECgUIBQAAAA==.',['丿暮']='丿暮色灬:BAAALAAECgYIBgAAAA==.',['丿疾']='丿疾风者:BAAALAADCgEIAQAAAA==.',['丿茉']='丿茉莉初雪:BAAALAAFFAIIBAABLAAFFAYIKgATAIIhAA==.',['丿落']='丿落叶丶:BAABLAAFFH8GAAIBAAYIVAQ6RwAjAQABAAYIVAQ6RwAjAQAAAA==.',['丿麻']='丿麻辣火锅:BAABLAAFFH8qAAMTAAYIgiEdCAAvAgATAAYIgiEdCAAvAgAUAAUI0ApyHgDbAAAAAA==.',['乖乖']='乖乖不乖:BAAALAADCgUIBQAAAA==.',['九丈']='九丈:BAAALAADCgQIBAAAAA==.',['九千']='九千八:BAABLAAFFH8OAAIPAAgIMSHNAAC8AgAPAAgIMSHNAAC8AgAAAA==.',['九点']='九点过后:BAAALAAECgUICAAAAA==.',['习惯']='习惯淋雨:BAABLAAFFH8GAAIFAAMIYwTeTABoAAAFAAMIYwTeTABoAAAAAA==.',['乱毛']='乱毛和奶牛:BAAALAADCgIIAgAAAA==.',['云端']='云端幽灵:BAAALAAECgYIBgAAAA==.',['亲儿']='亲儿子不虚:BAABLAAFFH8GAAIVAAIIrg0YFwB9AAAVAAIIrg0YFwB9AAAAAA==.',['亲缺']='亲缺德么:BAACLAAFFH8WAAITAAIINhzPIQCeAAATAAIINhzPIQCeAAAsAAQKfy8AAhMACAhDHTQUADQCABMACAhDHTQUADQCAAAA.',['人贱']='人贱就是矫情:BAAALAAECgQIBAAAAA==.',['人龙']='人龙小:BAABLAAECn8VAAIWAAYI2xavDQCHAQAWAAYI2xavDQCHAQAAAA==.',['亼皃']='亼皃丶:BAAALAAECgcIBwAAAA==.',['什巴']='什巴拉古大师:BAAALAAECgQIBAAAAA==.',['仁者']='仁者無敵:BAAALAADCggIDgAAAA==.',['今晚']='今晚去东村:BAAALAAECgYICgAAAA==.今晚吃兔兔丷:BAAALAAECgYIBwAAAA==.',['以圣']='以圣光之名丶:BAAALAADCgUIBQAAAA==.',['伊伊']='伊伊苏的起源:BAAALAADCggIDgAAAA==.',['伊邪']='伊邪那瑜:BAABLAAFFH8IAAIDAAII/w4KjABIAAADAAII/w4KjABIAAAAAA==.',['伍仟']='伍仟酒:BAABLAAFFH8MAAIPAAgIrCR2AADdAgAPAAgIrCR2AADdAgAAAA==.',['伍号']='伍号推土机:BAAALAAECgYIDQAAAA==.',['优昙']='优昙华院:BAABLAAFFH8IAAIDAAgInwNGZwCiAAADAAgInwNGZwCiAAAAAA==.',['你们']='你们缺德么丶:BAAALAAECgQICAAAAA==.',['你六']='你六哥:BAABLAAECn8WAAMGAAYIkg9DUwAdAQAGAAYILA9DUwAdAQAOAAQIQwvhOwClAAAAAA==.',['你在']='你在教我做事:BAAALAAECgIIAgAAAA==.',['你让']='你让玩圣骑的:BAAALAAFFAIIAgAAAA==.',['你这']='你这瓜保熟吗:BAAALAAECgEIAQAAAA==.',['佩佩']='佩佩妮妮:BAAALAAFFAIIAgAAAA==.',['傲视']='傲视九九:BAABLAAECn8UAAIKAAYInhADTwAjAQAKAAYInhADTwAjAQAAAA==.',['傲雪']='傲雪寒:BAAALAAFFAIIAgAAAA==.',['傻僈']='傻僈:BAACLAAFFH8IAAIKAAIIhA1RYABdAAAKAAIIhA1RYABdAAAsAAQKfxUAAgoABgh2EhJLADEBAAoABgh2EhJLADEBAAAA.',['八千']='八千四:BAABLAAFFH8KAAIPAAgIsRzKAQBYAgAPAAgIsRzKAQBYAgAAAA==.',['八尺']='八尺:BAABLAAFFH8GAAIXAAIIcRZ/DABQAAAXAAIIcRZ/DABQAAAAAA==.',['六仟']='六仟一:BAABLAAFFH8IAAIPAAYILySBAgAoAgAPAAYILySBAgAoAgAAAA==.',['六六']='六六大魔王:BAAALAAECggIDQABLAAECggIFwALAHgXAA==.',['六爷']='六爷张:BAABLAAFFH8GAAIGAAMIhA3SOACUAAAGAAMIhA3SOACUAAAAAA==.',['兰斯']='兰斯班尼:BAAALAAECgYIDAAAAA==.',['兽兽']='兽兽大司命:BAAALAAFFAIIBAAAAA==.',['军少']='军少:BAAALAAECgUICwAAAA==.',['冥河']='冥河:BAABLAAFFH8IAAIKAAII9wudYABdAAAKAAII9wudYABdAAAAAA==.',['冫钅']='冫钅至今未归:BAAALAAECgYIBgAAAA==.',['冰糖']='冰糖葫璐娃娃:BAAALAAFFAIIAgAAAA==.',['冰翎']='冰翎:BAABLAAFFH8GAAIHAAIIUwqHGwBIAAAHAAIIUwqHGwBIAAAAAA==.',['冰骑']='冰骑灵:BAAALAAECgYIBgAAAA==.',['冰鳞']='冰鳞:BAABLAAFFH8GAAIYAAIIGgwNIABvAAAYAAIIGgwNIABvAAAAAA==.',['凌虚']='凌虚子:BAABLAAFFH8MAAMZAAgIzhq7CAB5AgAZAAgIzhq7CAB5AgAaAAIIPRHACQBGAAAAAA==.',['凯恩']='凯恩的呼唤:BAABLAAFFH8KAAIbAAIIJhJfDwAoAAAbAAIIJhJfDwAoAAAAAA==.',['刀削']='刀削面:BAAALAAECgYICQAAAA==.',['别怕']='别怕姐在:BAAALAAECggICAAAAA==.',['别摧']='别摧毁物品:BAAALAAECgEIAQAAAA==.',['前世']='前世情人丶:BAAALAAFFAgIAQAAAA==.',['剑来']='剑来丶阮秀:BAAALAAECgEIAQAAAA==.',['加米']='加米勒:BAAALAAECgYIBgAAAA==.',['化神']='化神老祖:BAAALAAECgYIBgAAAA==.',['半条']='半条命:BAAALAAECgYICwAAAA==.',['单依']='单依纯丶:BAAALAAFFAIIAgAAAA==.',['卡露']='卡露露丿:BAAALAAECgYICAAAAA==.',['印第']='印第安老斑鳩:BAAALAAECgUIBwAAAA==.',['压迫']='压迫灬众生:BAABLAAFFH8JAAIBAAMIPxjFYQCNAAABAAMIPxjFYQCNAAAAAA==.',['叁仟']='叁仟陆:BAAALAAFFAgIAgAAAA==.',['叁柒']='叁柒贰拾壹:BAABLAAFFH8JAAIDAAMITREATQCYAAADAAMITREATQCYAAAAAA==.',['又又']='又又的小龙人:BAABLAAFFH8dAAQYAAcI8BJ4DABdAQAYAAYIHxR4DABdAQAPAAMIrRRtCwCiAAAWAAEIdAFOIgAtAAAAAA==.又又的戒指:BAACLAAFFH8dAAIJAAYIzw8WDAC+AQAJAAYIzw8WDAC+AQAsAAQKfyoAAwkACAg1HxknAHwCAAkACAg1HxknAHwCAAoABwiTCL/LAPAAAAAA.又又的钱袋:BAAALAAECggICAAAAA==.',['变身']='变身吧妞:BAAALAAECgYIDQAAAA==.',['叹茶']='叹茶:BAAALAAECggICAAAAA==.',['叽咕']='叽咕叽咕:BAAALAAFFAIIBAAAAA==.',['吃饱']='吃饱就想睡觉:BAAALAAECgMIAwAAAA==.',['后巷']='后巷乌龙茶:BAACLAAFFH8gAAMBAAcIBBomFgDpAQABAAcIBBomFgDpAQACAAEIiSQyFwBpAAAsAAQKfyEAAwEACAgfJUETACQDAAEACAiRJEETACQDAAIAAwiFIl81ACcBAAAA.后巷奶茶:BAAALAADCggICAAAAA==.后巷茉莉茶:BAABLAAFFH8aAAIFAAYIRx/TDQDZAQAFAAYIRx/TDQDZAQAAAA==.',['向日']='向日葵:BAAALAAECgYICgAAAA==.',['吨吨']='吨吨大魔王:BAAALAAECggIDgAAAA==.',['吸橙']='吸橙器:BAABLAAECn8bAAIcAAYItROaRwBGAQAcAAYItROaRwBGAQAAAA==.',['吾乃']='吾乃小狐仙:BAAALAADCgIIAgAAAA==.',['吾皇']='吾皇之魂:BAAALAADCgcIBwAAAA==.',['告白']='告白铁球:BAABLAAFFH8FAAIcAAUIugm1MgADAQAcAAUIugm1MgADAQAAAA==.',['周公']='周公:BAAALAADCgUIBQAAAA==.',['咆哮']='咆哮的小恶魔:BAAALAAECgUIBQAAAA==.',['咑瞌']='咑瞌睡的枫叶:BAAALAAECgYIBgAAAA==.',['哀木']='哀木風:BAAALAAFFAYIAgAAAA==.',['品如']='品如的奉献:BAAALAADCggICwAAAA==.',['哗啦']='哗啦啦滴滴答:BAAALAAECgIIAgAAAA==.',['哦吼']='哦吼吼:BAABLAAFFH8NAAITAAIIrRXHPgB5AAATAAIIrRXHPgB5AAAAAA==.',['啵啵']='啵啵咪:BAAALAAECgMIAwAAAA==.',['善良']='善良的大白牛:BAAALAAFFAIIBAAAAA==.',['喵丷']='喵丷唲:BAAALAAECgIIAwAAAA==.喵丷寳:BAABLAAFFH8GAAIDAAYIhggHTAAjAQADAAYIhggHTAAjAQAAAA==.',['嗜酒']='嗜酒小虾米:BAACLAAFFH8GAAIUAAII7ghwOgA0AAAUAAII7ghwOgA0AAAsAAQKfxYAAxQABwjQFOkdAIMBABQABwjQFOkdAIMBABMAAQhZAUP3ABUAAAAA.嗜酒虾米:BAABLAAFFH8GAAIVAAIIdASpGgBrAAAVAAIIdASpGgBrAAAAAA==.',['噜啦']='噜啦啦憨哟:BAAALAAFFAIIAwAAAA==.',['回春']='回春术:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光战:BAAALAAECgYICQAAAA==.圣光斗士:BAAALAAECgYIBwAAAA==.圣光狐狸:BAAALAAFFAIIAgAAAA==.圣光眷顾牛:BAABLAAFFH8GAAIFAAYI/BTNHQB5AQAFAAYI/BTNHQB5AQAAAA==.圣光骑士:BAABLAAECn8cAAIRAAYIsB0cEgDcAQARAAYIsB0cEgDcAQAAAA==.',['圣殿']='圣殿吹血:BAAALAAECgQIAQAAAA==.圣殿血月:BAAALAAECgYIBgAAAA==.',['圣灵']='圣灵十字架:BAAALAADCgEIAQAAAA==.',['地主']='地主家的老虎:BAAALAAECgYIBgAAAA==.',['地狱']='地狱小吼:BAAALAAECgEIAQAAAA==.',['坦克']='坦克手呗塔:BAAALAAECgYIDQAAAA==.',['埃辛']='埃辛诺斯乄:BAAALAAECgYIBgAAAA==.',['城南']='城南花已开:BAAALAAECgIIAgAAAA==.',['墨丶']='墨丶雪:BAAALAAFFAIIAgAAAA==.',['壹仟']='壹仟叁:BAAALAAFFAgIAgAAAA==.',['壹号']='壹号推土机:BAAALAAECgYIDQAAAA==.',['复活']='复活的失杺:BAACLAAFFH8bAAIKAAYIGBXQHwBiAQAKAAYIGBXQHwBiAQAsAAQKfxkAAwoABwgHE5iCAHsBAAoABwgHE5iCAHsBAAkAAwh6DhuvAJ4AAAAA.',['夏狐']='夏狐狸:BAAALAAECgUIBQAAAA==.',['夜之']='夜之魔王:BAAALAAFFAIIBAAAAA==.',['夜的']='夜的第七章:BAAALAAECggIEAAAAA==.',['大墙']='大墙小警:BAAALAAFFAMIAwAAAA==.',['大学']='大学生活真棒:BAAALAADCgcIBwAAAA==.',['大德']='大德鲁:BAAALAAECgYIEgAAAA==.',['大条']='大条橙子:BAAALAADCgYIBgAAAA==.',['大漠']='大漠白杨:BAAALAAECgYIBgAAAA==.',['大董']='大董来了:BAAALAAFFAIIAgABLAAFFAgIDQAGAMYhAA==.',['天堂']='天堂的审判:BAAALAAECgIIAgAAAA==.',['天生']='天生励志丶:BAAALAAECgIIAgAAAA==.',['天蝎']='天蝎座之靡:BAAALAAECgcIBwAAAA==.天蝎玺玉猴:BAAALAADCgEIAQAAAA==.',['天道']='天道即王道:BAAALAAFFAIIAgAAAA==.',['奇趣']='奇趣熊:BAAALAAFFAIIAgAAAA==.',['奥格']='奥格外卖仔:BAAALAADCggICAAAAA==.',['女神']='女神的心:BAAALAAECgYIBgAAAA==.',['奶香']='奶香一刀:BAABLAAECn8bAAIJAAcIAhEOMQBRAQAJAAcIAhEOMQBRAQABLAAFFAUIDwAFADsWAA==.',['好运']='好运到:BAAALAAECgcICAAAAA==.',['如是']='如是心:BAABLAAFFH8GAAINAAIIUQ69EQB8AAANAAIIUQ69EQB8AAAAAA==.',['妞妞']='妞妞:BAAALAAECgcIEQAAAA==.',['妹不']='妹不在:BAAALAAECggICQAAAA==.',['妹在']='妹在不在:BAAALAAECggIDwAAAA==.',['姬尼']='姬尼太寐:BAAALAAECgUIBgAAAA==.',['孙子']='孙子冰法:BAAALAADCgEIAQAAAA==.',['孙策']='孙策:BAAALAAECggICAAAAA==.',['安雅']='安雅泰勒乔伊:BAAALAAFFAIIAgAAAA==.',['宜兴']='宜兴龙傲天:BAAALAAFFAIIAgAAAA==.',['宸伊']='宸伊大魔王:BAAALAAFFAQIAQAAAA==.',['宽心']='宽心:BAAALAAECgYIDwAAAA==.',['宿醉']='宿醉烈酒丶:BAACLAAFFH8IAAIcAAIIaQ2xTgCOAAAcAAIIaQ2xTgCOAAAsAAQKfyMAAhwACAjaHKwsAKoCABwACAjaHKwsAKoCAAAA.',['寂寞']='寂寞术控:BAACLAAFFH8NAAMZAAMI3BAJKQDoAAAZAAMI3BAJKQDoAAAdAAII0Q8dGACTAAAsAAQKfygAAx0ACAgvGPkuALMBAB0ABgj+GfkuALMBABkABghhFRd2AJcBAAAA.',['寥若']='寥若星辰:BAAALAADCggICAABLAAFFAgIEgADAM0MAA==.',['封之']='封之月:BAAALAADCgEIAQAAAA==.',['小头']='小头爸爸:BAAALAAECgYIDAAAAA==.',['小德']='小德德不是德:BAAALAAECgYIBgAAAA==.',['小怪']='小怪兽丨:BAAALAAECgIIAgAAAA==.',['小时']='小时候可白了:BAAALAAECgIIAgAAAA==.',['小星']='小星球:BAAALAAECgMIAwAAAA==.',['小米']='小米粥煮狐狸:BAABLAAFFH8GAAMeAAIIGBnFNQCSAAAeAAIIGBnFNQCSAAAfAAEI8QLZMgAoAAAAAA==.',['小红']='小红手一老黑:BAAALAAECggIDwAAAA==.',['小老']='小老虎:BAAALAAECgYIDQAAAA==.',['小虾']='小虾米:BAACLAAFFH8KAAMFAAIIHhBpRQCaAAAFAAIIHhBpRQCaAAAQAAIIggaBIgAnAAAsAAQKfx4AAwUACAjSGFwkAAgCAAUACAg7F1wkAAgCABAACAijB/xSANoAAAAA.',['小诺']='小诺:BAABLAAECn8ZAAIeAAgIcw+mKgBnAQAeAAgIcw+mKgBnAQAAAA==.',['小贱']='小贱贱:BAAALAADCgYIBgAAAA==.',['尛尾']='尛尾巴贔贔:BAAALAAECgYIBgAAAA==.',['尼沽']='尼沽拉:BAAALAAECgMIAwAAAA==.',['尽欢']='尽欢:BAAALAAECggICAAAAA==.',['屁大']='屁大坐天下:BAABLAAFFH8FAAIeAAIIbRbROgB3AAAeAAIIbRbROgB3AAAAAA==.',['岁月']='岁月在默数:BAAALAAECgcIBwAAAA==.',['左手']='左手勾右手圈:BAABLAAECn8aAAIgAAYIDhAVHQAaAQAgAAYIDhAVHQAaAQAAAA==.',['巨物']='巨物鬼打墙:BAAALAAECgYICQAAAA==.',['帝丶']='帝丶右手:BAAALAADCggICAAAAA==.',['常威']='常威在打莱福:BAAALAAFFAMIAgAAAA==.',['平头']='平头哥:BAAALAAFFAIIAgAAAA==.',['幻紫']='幻紫轩:BAAALAAFFAIIAgAAAA==.',['弑神']='弑神狂魔:BAAALAAECgYIDgAAAA==.',['张艺']='张艺兴:BAAALAADCgQIBAAAAA==.',['弹棉']='弹棉花的二娃:BAAALAADCgIIAgAAAA==.',['彩虹']='彩虹的瞬间:BAABLAAECn8YAAIRAAgIAxriGQA/AgARAAgIAxriGQA/AgAAAA==.',['彳亍']='彳亍小小风:BAABLAAFFH8FAAIDAAUIkxHfFAB5AQADAAUIkxHfFAB5AQAAAA==.彳亍小风:BAABLAAFFH8GAAIDAAYITBGqDADQAQADAAYITBGqDADQAQAAAA==.',['御坂']='御坂美琴丶:BAABLAAFFH8JAAIJAAII1AfDMwCBAAAJAAII1AfDMwCBAAAAAA==.',['德不']='德不胜气:BAABLAAECn8UAAITAAYI6hV0OQA8AQATAAYI6hV0OQA8AQAAAA==.',['德丨']='德丨服:BAAALAADCggICAAAAA==.',['德儿']='德儿隆冬强:BAAALAAFFAIIAgAAAA==.',['心上']='心上弦:BAAALAAECggIDwAAAA==.',['怀旧']='怀旧牛萨满:BAAALAAECgYIBgAAAA==.',['思年']='思年华:BAAALAAECgYIDAAAAA==.',['性感']='性感的牛蛙:BAAALAAECggIEQAAAA==.',['恶犬']='恶犬俊介:BAAALAADCgYIBgAAAA==.',['悦色']='悦色迷人眼:BAABLAAFFH8FAAITAAII9RCZMwBtAAATAAII9RCZMwBtAAAAAA==.',['惧人']='惧人心:BAAALAAECgYIBgAAAA==.',['愛寫']='愛寫在西元前:BAAALAAECgEIAQAAAA==.',['愤怒']='愤怒嘚丶蛋阔:BAABLAAECn8bAAQFAAYIXBxphwDfAQAFAAYIXBxphwDfAQARAAQIHge2ZQCnAAAQAAMIPwtrPgBQAAAAAA==.',['成追']='成追忆:BAAALAAECgYIEQAAAA==.',['我好']='我好像:BAAALAAFFAIIAgAAAA==.',['我差']='我差点笑出声:BAAALAAECgUIBQAAAA==.',['我是']='我是小傻馒:BAAALAAECgYIDAAAAA==.我是小恶魔:BAAALAAFFAIIAgAAAA==.',['我有']='我有一个帽衫:BAAALAAECgYIBgAAAA==.',['扌召']='扌召贝才犭苗:BAAALAAECgYIBgAAAA==.',['执念']='执念:BAAALAAECgYIBgAAAA==.',['拔刀']='拔刀留住落樱:BAAALAADCgEIAQAAAA==.',['捌号']='捌号推土机:BAAALAAECgYIBgAAAA==.',['握拳']='握拳:BAAALAAECgYIDgAAAA==.',['敌法']='敌法灬李青:BAABLAAFFH8HAAIMAAIIDBZ7DQCIAAAMAAIIDBZ7DQCIAAAAAA==.',['教丨']='教丨父:BAAALAADCgEIAQAAAA==.',['斯洛']='斯洛尼:BAABLAAFFH8FAAIDAAIIOwTDtQA1AAADAAIIOwTDtQA1AAAAAA==.',['无上']='无上凶器:BAACLAAFFH8GAAIKAAIIBA/1TgBsAAAKAAIIBA/1TgBsAAAsAAQKfxUAAgoABggJDn/FAPsAAAoABggJDn/FAPsAAAAA.',['无冕']='无冕者:BAABLAAECn8dAAIGAAcI6xMEOgByAQAGAAcI6xMEOgByAQABLAAFFAUIDwAFADsWAA==.',['无冠']='无冠者:BAACLAAFFH8PAAIFAAUIOxauKgAxAQAFAAUIOxauKgAxAQAsAAQKfycAAgUACAheIfAaADwCAAUACAheIfAaADwCAAAA.',['无可']='无可奶合:BAABLAAECn8WAAIKAAgIXhl3TgD2AQAKAAgIXhl3TgD2AQAAAA==.',['无才']='无才有德:BAABLAAFFH8IAAITAAIIphSiPgB5AAATAAIIphSiPgB5AAAAAA==.',['无边']='无边落木潇潇:BAABLAAFFH8KAAIBAAIIxxE5egCLAAABAAIIxxE5egCLAAAAAA==.',['无限']='无限哔哔流:BAAALAAECgYICAAAAA==.',['既见']='既见未来:BAAALAAECgMIAwAAAA==.',['明月']='明月依旧:BAAALAAECgYIDAAAAA==.明月戏清风:BAAALAAECgIIAgAAAA==.明月朗:BAAALAAECgYIDQAAAA==.',['昔羽']='昔羽:BAABLAAECn8XAAIfAAcIkRwSJwBBAgAfAAcIkRwSJwBBAgAAAA==.',['昔鸟']='昔鸟:BAABLAAFFH8GAAMEAAYIugsNCwDpAAAEAAUIVwwNCwDpAAADAAEIpwiSpAA9AAAAAA==.',['是十']='是十八啊:BAAALAAECgYIBgAAAA==.',['晓刚']='晓刚学姐:BAAALAAECgYICwAAAA==.',['晓梦']='晓梦庄生:BAAALAAECgIIAgAAAA==.',['晓樓']='晓樓聼風雨:BAAALAADCgIIAgAAAA==.',['晨曦']='晨曦亦如初见:BAABLAAFFH8GAAIFAAIIvR2SKQC2AAAFAAIIvR2SKQC2AAAAAA==.晨曦茳祉:BAABLAAFFH8HAAIBAAMIRA6LLgDgAAABAAMIRA6LLgDgAAAAAA==.',['暗夜']='暗夜丶战天下:BAAALAADCgYICAAAAA==.暗夜之盾:BAAALAAECgYICgAAAA==.暗夜战歌:BAAALAAECgQIBAAAAA==.暗夜星河:BAABLAAFFH8FAAIVAAMIyQ9uEQBXAAAVAAMIyQ9uEQBXAAAAAA==.',['暗影']='暗影国度:BAAALAAECgYIDwAAAA==.',['最後']='最後的戰役:BAAALAAECgYIBgAAAA==.',['月下']='月下鬼影:BAAALAAECgYIBgAAAA==.',['月光']='月光之城:BAAALAADCgYIBgAAAA==.',['月舞']='月舞神殇:BAACLAAFFH8NAAIHAAUITghODwAZAQAHAAUITghODwAZAQAsAAQKfxYAAgcABgiAEKg8AGYBAAcABgiAEKg8AGYBAAAA.',['有丶']='有丶去无回:BAAALAAECgYIBgAAAA==.',['朔月']='朔月小恶魔:BAAALAADCgQIBAAAAA==.',['木头']='木头呐:BAABLAAFFH8IAAIBAAQIJAIAbABpAAABAAQIJAIAbABpAAAAAA==.',['木木']='木木狐:BAAALAAECgYIBgAAAA==.',['未来']='未来小萨萨:BAAALAAECgYIDAAAAA==.',['术神']='术神姜葱蒜:BAAALAADCggIDgAAAA==.',['杀戮']='杀戮猎手船长:BAACLAAFFH8jAAIcAAYIgxEOIwB2AQAcAAYIgxEOIwB2AQAsAAQKfykAAhwACAjBHVsrALACABwACAjBHVsrALACAAAA.',['杨大']='杨大饼:BAAALAAECgIIAgAAAA==.',['杨树']='杨树林:BAABLAAECn8gAAMEAAgIzCQtBwAvAwAEAAgIkyQtBwAvAwADAAgIah8OHgBLAgABLAAFFAgIBgADAIoVAA==.',['杯莫']='杯莫停丶:BAACLAAFFH84AAMBAAYIHhtwJgCgAQABAAYIHhtwJgCgAQANAAQIlwMsFgBlAAAsAAQKfyEAAwEACAioGY1QAFcCAAEACAgaGY1QAFcCAA0ABgiOESMtABMBAAAA.',['板栗']='板栗和奶牛:BAAALAAECgYIDQAAAA==.',['林品']='林品如:BAAALAAFFAIIAgAAAA==.',['林熙']='林熙堂:BAABLAAFFH8NAAIKAAMIyxadOADEAAAKAAMIyxadOADEAAAAAA==.',['果宝']='果宝:BAAALAAECgQIBAAAAA==.',['枫叶']='枫叶刃锋:BAAALAADCgUIBQAAAA==.枫叶小白:BAAALAAECgMIAwAAAA==.',['枫的']='枫的记忆:BAAALAAECgIIAgAAAA==.',['柒号']='柒号推土机:BAABLAAECn8UAAMhAAYIDBj0FQCDAQAhAAYIBBj0FQCDAQAGAAQIahTCcgDAAAAAAA==.',['柒柒']='柒柒大魔王:BAABLAAFFH8HAAMLAAIImQ8QYQA8AAAVAAEIKRJaHwBGAAALAAIImQ8QYQA8AAAAAA==.',['柠檬']='柠檬不萌丶:BAAALAAECgMIAwAAAA==.',['柳长']='柳长街:BAAALAAECggICAAAAA==.',['核弹']='核弹一直来:BAABLAAECn8YAAMDAAgIhyGAMwCMAgADAAgIhyGAMwCMAgAEAAEIWwsZxQArAAAAAA==.',['格格']='格格舞:BAAALAAECgUIBQAAAA==.',['桂花']='桂花糕:BAAALAAECgUIBQAAAA==.',['桃丶']='桃丶白白:BAAALAAECgQIBAAAAA==.',['桃白']='桃白白丶:BAAALAAECgUIBQAAAA==.',['梅拉']='梅拉德芙:BAAALAAECgYIBwAAAA==.',['棒丶']='棒丶棒灬棒:BAAALAAFFAIIBAAAAA==.',['楊耂']='楊耂蒒:BAABLAAFFH8FAAIDAAIIIxzCPwCmAAADAAIIIxzCPwCmAAAAAA==.',['楚昭']='楚昭南:BAAALAAECgMIAwAAAA==.',['樱木']='樱木花花:BAAALAADCggICAAAAA==.',['橙吟']='橙吟不语:BAAALAAECgYIEgAAAA==.',['橙大']='橙大牛:BAAALAAECgYICQABLAAECgYIFAATAOoVAA==.',['橡皮']='橡皮丶:BAABLAAFFH8cAAIcAAYI6Bu6FgC3AQAcAAYI6Bu6FgC3AQABLAAFFAYIKgATAIIhAA==.',['欧皇']='欧皇丶七七:BAAALAAECgUICgAAAA==.欧皇肥宝宝:BAABLAAECn8XAAMLAAcIeBfTWAD5AQALAAcIeBfTWAD5AQAiAAQIVxDgEgDYAAAAAA==.',['款爷']='款爷太帅了:BAAALAAECgYIBwAAAA==.',['正义']='正义王冠:BAAALAAECgYIBgAAAA==.',['死骑']='死骑呢:BAAALAAECgYIDAAAAA==.',['水墨']='水墨黄昏:BAAALAAECgIIAgAAAA==.',['永恒']='永恒丿挚爱单:BAAALAAECgYIBgAAAA==.',['江湖']='江湖故人:BAAALAAECgYIBgAAAA==.',['污喵']='污喵王:BAAALAAECgYIDAAAAA==.',['汤面']='汤面:BAAALAAFFAIIAgAAAA==.',['沙梦']='沙梦:BAAALAAECgMIAwAAAA==.',['没事']='没事就玩:BAAALAAECgUIBQAAAA==.',['油油']='油油圈:BAAALAAECgYIDAAAAA==.',['波尔']='波尔多斯:BAAALAAECgEIAQAAAA==.',['波比']='波比小佑:BAABLAAFFH8GAAIFAAIIegwHTQCVAAAFAAIIegwHTQCVAAAAAA==.',['波澜']='波澜:BAAALAAECgYICwAAAA==.',['消失']='消失的影子:BAAALAAECgUIBQAAAA==.',['淮南']='淮南牛肉汤:BAAALAAECgMIAwAAAA==.淮南牛肉糖:BAAALAAECgYIBgAAAA==.',['淺灬']='淺灬语:BAAALAAFFAIIBAAAAA==.',['清汤']='清汤面:BAAALAAECgYICQAAAA==.',['清风']='清风依旧:BAAALAADCgYIBgAAAA==.',['湮灭']='湮灭船长:BAAALAADCgYIBgAAAA==.',['潮泳']='潮泳:BAAALAAECggIAwAAAA==.',['澄闪']='澄闪:BAAALAAECgYIBgAAAA==.',['濛濛']='濛濛哒:BAAALAAECgYIDQAAAA==.',['灬丷']='灬丷龘龘丷灬:BAAALAADCgQIBAAAAA==.',['灬圣']='灬圣光审判灬:BAAALAAECggICAAAAA==.',['灬楊']='灬楊灬:BAABLAAFFH8GAAMLAAIIiBS6RACbAAALAAIIzhG6RACbAAAVAAIIiBTvFwBAAAAAAA==.',['灬浪']='灬浪裏媽灬:BAAALAAFFAIIAgAAAA==.',['灬诗']='灬诗怡灬:BAAALAAFFAIIAgAAAA==.',['灬龘']='灬龘眔龘灬:BAAALAADCggICAAAAA==.灬龘龖龘灬:BAAALAAECgIIAgAAAA==.',['灵感']='灵感大王:BAABLAAFFH8HAAITAAMIuRdnKgDLAAATAAMIuRdnKgDLAAAAAA==.',['灵风']='灵风:BAABLAAFFH8FAAIRAAMIERH8HQC3AAARAAMIERH8HQC3AAAAAA==.',['烟花']='烟花落尽:BAAALAAECgYIBwAAAA==.',['烟雨']='烟雨漫天:BAABLAAECn8YAAIVAAgIRx4/FAB9AgAVAAgIRx4/FAB9AgAAAA==.',['烦死']='烦死个仙人:BAAALAAECgQIBAAAAA==.',['焚天']='焚天烬:BAABLAAFFH8MAAIFAAYIwiDIDADhAQAFAAYIwiDIDADhAQAAAA==.',['熊貓']='熊貓時代:BAAALAADCgcIBwAAAA==.',['爆丨']='爆丨雨:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃薯条的卿:BAAALAAFFAIIBAAAAA==.',['爱哟']='爱哟喂:BAAALAAECgYIBgAAAA==.',['爱比']='爱比死更冷:BAAALAAECgQIBAAAAA==.',['牡丹']='牡丹:BAAALAAECgYIDwAAAA==.',['牧之']='牧之魔王:BAAALAAFFAIIAgAAAA==.',['牧瑶']='牧瑶:BAABLAAFFH8FAAILAAII4waEXwB8AAALAAII4waEXwB8AAAAAA==.',['犬风']='犬风之伤:BAAALAADCgEIAQAAAA==.',['狂暴']='狂暴得菊花:BAAALAAECgYIBgAAAA==.狂暴船长:BAAALAAECgUIBQAAAA==.狂暴菊花:BAAALAAECgQIBAAAAA==.',['狐沙']='狐沙曼:BAAALAAECgMIAwAAAA==.',['狐狸']='狐狸:BAABLAAECn8WAAMTAAYIDRnhJgCnAQATAAYIDRnhJgCnAQAbAAYI8gqBGQC/AAAAAA==.狐狸龙:BAAALAAECgYICAAAAA==.',['狐猎']='狐猎娜:BAAALAAECgYICQAAAA==.',['狡猾']='狡猾的尼克:BAAALAAECgYIBgAAAA==.',['狼丨']='狼丨魂:BAAALAAECgYIBwAAAA==.',['狼的']='狼的死骑:BAAALAADCgEIAQAAAA==.',['猎了']='猎了个鸽:BAAALAADCgcIBwAAAA==.',['猎魔']='猎魔恶手丶:BAAALAAECgYICQAAAA==.',['猩猩']='猩猩的守护神:BAAALAAECgIIAgAAAA==.',['玉升']='玉升烟:BAAALAAECgYIDAAAAA==.',['玖号']='玖号推土机:BAAALAAFFAIIAgAAAA==.',['玛咖']='玛咖巴咔:BAAALAAECggIEgAAAA==.',['玛法']='玛法丶:BAAALAAECgcIBwAAAA==.',['琳德']='琳德:BAAALAAECgMIAwAAAA==.',['瑾瑟']='瑾瑟无端:BAAALAAECgQIBwAAAA==.',['瓜哥']='瓜哥止痛丸:BAAALAAECgIIAgAAAA==.',['电动']='电动小牛:BAAALAAECgYICwAAAA==.',['男人']='男人不怕黑:BAACLAAFFH8KAAIOAAII0AehLwBXAAAOAAII0AehLwBXAAAsAAQKfyQAAw4ABwhtDpAqAAABAA4ABwieC5AqAAABAAYABAjFDv1oAN0AAAAA.男人不怕黑嘛:BAABLAAFFH8GAAMcAAII7gTQZgA6AAAcAAII7gTQZgA6AAAMAAIIkgB2HAA2AAAAAA==.',['疯狂']='疯狂的豆奶:BAAALAAFFAIIBAAAAA==.',['白娘']='白娘子砍传奇:BAABLAAFFH8LAAIBAAYIzQ+wNgBmAQABAAYIzQ+wNgBmAQAAAA==.',['白家']='白家老七:BAABLAAFFH8GAAIFAAIISRDtaQBCAAAFAAIISRDtaQBCAAAAAA==.',['百事']='百事可口可乐:BAAALAAECgYIBgAAAA==.',['皮皮']='皮皮鲁:BAAALAAECgIIAgAAAA==.',['真的']='真的硬:BAABLAAFFH8GAAIbAAIInREUCAByAAAbAAIInREUCAByAAAAAA==.',['瞬间']='瞬间:BAAALAAECggIEAABLAAFFAgIPgAXAMMlAA==.',['砂锅']='砂锅牛肉抄手:BAACLAAFFH8GAAIgAAIIiRZCDwCbAAAgAAIIiRZCDwCbAAAsAAQKfxUAAiAABghdH7gdABcCACAABghdH7gdABcCAAAA.',['破天']='破天刀:BAAALAAECgYIEQAAAA==.',['碳烤']='碳烤牛排:BAAALAAECgcICwAAAA==.',['神奇']='神奇的马鹿:BAAALAAECgEIAQAAAA==.',['神灬']='神灬焱:BAABLAAFFH8GAAIZAAIIEAiubQAzAAAZAAIIEAiubQAzAAAAAA==.',['神的']='神的孩子:BAAALAAFFAIIAgAAAA==.',['秋云']='秋云不雨长阴:BAAALAAECgYIBgAAAA==.',['秋月']='秋月:BAAALAAECgYIBgAAAA==.',['秋高']='秋高气爽:BAAALAAECgEIAQAAAA==.',['穷胸']='穷胸极饿:BAAALAAECgEIAQAAAA==.',['笑小']='笑小羊:BAAALAADCggICAAAAA==.',['筱姐']='筱姐姐:BAAALAAECgYIBgAAAA==.',['米锵']='米锵锵:BAAALAAFFAIIBAABLAAFFAYIEAAZAFceAA==.',['純愛']='純愛牛頭人:BAAALAAECgYIDAAAAA==.',['紫涩']='紫涩丶:BAAALAAECgYIBgAAAA==.',['紫瞳']='紫瞳蛮牛:BAABLAAFFH8GAAIGAAYIaAi4JQBHAQAGAAYIaAi4JQBHAQAAAA==.',['紫陌']='紫陌浮纱:BAAALAAECgEIAQAAAA==.',['练气']='练气七层:BAAALAAECgYIDAAAAA==.',['练着']='练着玩玩:BAAALAADCgMIAwAAAA==.',['维维']='维维萨安:BAAALAAECgEIAQAAAA==.',['综合']='综合水果武士:BAAALAAECgYIBgAAAA==.',['网红']='网红法:BAAALAAECgUIBwAAAA==.',['習惯']='習惯:BAAALAAECgMIAwAAAA==.',['老猫']='老猫沃夫:BAAALAAECgYICgAAAA==.',['老衲']='老衲法号叫兽:BAAALAAECgUIBQAAAA==.',['肆仟']='肆仟柒:BAABLAAFFH8SAAIPAAgIMCUxAAABAwAPAAgIMCUxAAABAwAAAA==.',['肆号']='肆号推土机:BAAALAAECgcIDAAAAA==.',['肉肉']='肉肉也疯狂:BAAALAAECgQIBAAAAA==.肉肉我爱吃:BAAALAAECgYICwAAAA==.',['肌肉']='肌肉娘娘腔丶:BAACLAAFFH8fAAIOAAYIaBhpDgBmAQAOAAYIaBhpDgBmAQAsAAQKfyYAAg4ACAg5I14DAMcCAA4ACAg5I14DAMcCAAAA.',['胖乎']='胖乎乎的瞬间:BAAALAAECggICAABLAAFFAgIHgABAKscAA==.',['能豆']='能豆豆萌萌哒:BAAALAADCggICAAAAA==.',['脉冲']='脉冲发生器:BAAALAAECgMIBAAAAA==.',['腊梅']='腊梅:BAAALAAECgYIBgAAAA==.',['與绛']='與绛唇的故事:BAAALAADCgMIAwAAAA==.',['船长']='船长归来:BAAALAAECgQIBAAAAA==.',['艾特']='艾特凯沃:BAAALAAECgYIBgAAAA==.',['花儿']='花儿笨:BAAALAAFFAIIBAAAAA==.',['花盗']='花盗二号:BAACLAAFFH8JAAIKAAII1RgjSACQAAAKAAII1RgjSACQAAAsAAQKfzAAAwoABwi2EOKgAD0BAAoABwi2EOKgAD0BAAkABgjqCOqOABYBAAAA.',['苏富']='苏富贵:BAABLAAFFH8IAAIBAAIIfxo/fwBHAAABAAIIfxo/fwBHAAABLAAFFAgIAQAjAAAAAA==.',['苏小']='苏小七:BAAALAAFFAIIAgAAAA==.',['苏海']='苏海伦:BAAALAAECgYICQAAAA==.',['若若']='若若:BAAALAAECgYIBgAAAA==.',['英倫']='英倫海岸線:BAAALAADCgIIAgAAAA==.',['莫言']='莫言:BAAALAAECgYIEAAAAA==.',['菲儿']='菲儿凌蒂斯:BAAALAAECgMIBgAAAA==.',['菲尔']='菲尔艾维:BAAALAAECgYIBgAAAA==.',['萨囧']='萨囧囧:BAABLAAECn8VAAIKAAgI5xGxegCLAQAKAAgI5xGxegCLAQAAAA==.',['落丨']='落丨葉:BAAALAAECgYICgAAAA==.',['落花']='落花雨无泪:BAAALAAECgYICQAAAA==.',['蒋欣']='蒋欣:BAAALAAECgUIBQAAAA==.',['蒜鸟']='蒜鸟算鸟:BAABLAAFFH8KAAIUAAII5x7oFQCxAAAUAAII5x7oFQCxAAAAAA==.',['蓝田']='蓝田暖玉:BAAALAAECgYICQAAAA==.',['蓝色']='蓝色小胖:BAAALAADCgYIBgAAAA==.',['蓝若']='蓝若昔:BAAALAADCgEIAQAAAA==.',['薄荷']='薄荷朱莉普:BAAALAAECgQIBAAAAA==.',['薇尔']='薇尔莉特丶:BAAALAAECgYICQAAAA==.',['虎牙']='虎牙天刺:BAAALAAECgYICwAAAA==.',['虚灵']='虚灵咒术师:BAAALAADCgIIAgAAAA==.',['虚空']='虚空行者:BAAALAAFFAIIBAAAAA==.',['蛋蛋']='蛋蛋丶蛋疼:BAAALAAFFAIIAgAAAA==.',['血妖']='血妖月:BAAALAADCgcICgAAAA==.',['血漫']='血漫银山:BAACLAAFFH8HAAIKAAII6w2bZABXAAAKAAII6w2bZABXAAAsAAQKfxYAAgoABwjjDZ+sACcBAAoABwjjDZ+sACcBAAAA.',['被遗']='被遗忘的心弦:BAAALAAECgYIDQAAAA==.被遗忘的心程:BAAALAAECgEIAQAAAA==.',['裴公']='裴公子丶:BAACLAAFFH8IAAIFAAIIiiTbNACnAAAFAAIIiiTbNACnAAAsAAQKfx0AAgUABggJJrRQAE4CAAUABggJJrRQAE4CAAAA.',['見獵']='見獵心囍:BAAALAAECgYIBgAAAA==.',['謝汶']='謝汶東:BAAALAAFFAIIBAAAAA==.',['请输']='请输入名称:BAAALAADCgUIBQAAAA==.',['贰仟']='贰仟伍:BAAALAAFFAgIAgAAAA==.',['贰号']='贰号推土机:BAABLAAECn8VAAMFAAYISxJr0gBtAQAFAAYISxJr0gBtAQARAAIIbhLGbAB9AAAAAA==.',['贰拾']='贰拾贰:BAABLAAFFH8NAAIcAAYIEBaDGwCdAQAcAAYIEBaDGwCdAQAAAA==.',['贾静']='贾静雯:BAABLAAFFH8SAAMLAAMItSJvMQDEAAALAAMItSJvMQDEAAAiAAEI4w5PDgA9AAAAAA==.',['起个']='起个门拉个糖:BAABLAAECn8eAAMdAAgIlCEzCADkAgAdAAgIRCAzCADkAgAZAAIIciDw2QClAAAAAA==.',['起伏']='起伏:BAAALAADCgEIAQAAAA==.',['超级']='超级小思嘉:BAABLAAFFH8FAAIKAAIIhwUnZgBbAAAKAAIIhwUnZgBbAAAAAA==.超级打井机:BAABLAAECn8ZAAMWAAcIWAl9KAAeAQAWAAcIWAl9KAAeAQAYAAMI8AbQXAB4AAAAAA==.',['轩丶']='轩丶末华:BAAALAAFFAIIAgAAAA==.',['辉欧']='辉欧皇庇护:BAAALAAFFAYIAwAAAA==.',['辰灬']='辰灬不二:BAABLAAFFH8GAAMdAAII6A65FwCUAAAdAAIIDQy5FwCUAAAZAAIIlA6HaAA5AAAAAA==.',['过油']='过油肉拌面:BAAALAAECgMIAwAAAA==.',['这是']='这是什么鬼:BAAALAAECgMIBAAAAA==.',['迪玛']='迪玛利亚:BAAALAAECgYIBgAAAA==.',['迷茫']='迷茫的小猎:BAABLAAFFH8GAAIDAAYI7RF9PQBUAQADAAYI7RF9PQBUAQAAAA==.',['迷蝴']='迷蝴蝶:BAAALAAECgQIBAAAAA==.',['追不']='追不到的風:BAABLAAFFH8GAAIcAAYIsBd4HACXAQAcAAYIsBd4HACXAQAAAA==.',['逆风']='逆风行:BAAALAAECgYIBgAAAA==.',['邓狗']='邓狗:BAAALAAECgYIBgAAAA==.邓狗老婆:BAAALAAFFAIIBAAAAA==.',['邪恶']='邪恶梦魇:BAAALAAECgQIBAAAAA==.邪恶的阿昆达:BAAALAAECgcICgAAAA==.',['邱老']='邱老師:BAAALAADCgYIBgAAAA==.',['酒神']='酒神给你大药:BAABLAAFFH8HAAITAAIIZxGWRgBjAAATAAIIZxGWRgBjAAAAAA==.',['采九']='采九朵莲:BAAALAAECgYIBgAAAA==.',['钓鱼']='钓鱼佬:BAAALAAECgYICQAAAA==.',['钙奶']='钙奶:BAAALAAECgYICAAAAA==.',['钱烈']='钱烈宪发言:BAACLAAFFH8dAAMTAAUIRRSzGQBkAQATAAUIRRSzGQBkAQAUAAUIrgetHQDlAAAsAAQKfy4AAxMACAg1FVw6APYBABMACAg1FVw6APYBABQABwhfFV86AM0BAAAA.',['铁甲']='铁甲小宝:BAAALAAECggIBgAAAA==.',['長沙']='長沙满鍋:BAACLAAFFH82AAINAAgI9CPFAACSAgANAAgI9CPFAACSAgAsAAQKfyQAAg0ACAjUJT8EAC4DAA0ACAjUJT8EAC4DAAAA.',['长威']='长威打来福:BAAALAAECgYIDQAAAA==.',['闪电']='闪电灬五连鞭:BAAALAAECgIIAgAAAA==.',['阎丨']='阎丨月刃:BAAALAADCgEIAQAAAA==.',['阿呆']='阿呆丶:BAAALAAECggICAAAAA==.',['阿拉']='阿拉比卡:BAAALAAECgUIBQAAAA==.',['阿萨']='阿萨:BAAALAADCgMIAwAAAA==.阿萨馨:BAAALAADCggIBwAAAA==.',['阿进']='阿进快还钱:BAAALAAFFAIIAgAAAA==.',['陈七']='陈七七:BAAALAAFFAIIAgAAAA==.',['陈二']='陈二十七:BAAALAAFFAIIAgAAAA==.',['陈小']='陈小倾:BAABLAAECn8VAAIhAAYI6QlXDQC+AAAhAAYI6QlXDQC+AAAAAA==.',['陈柒']='陈柒柒:BAAALAAFFAIIAgAAAA==.',['雨下']='雨下一整晚:BAABLAAFFH8JAAMPAAYIQRBSBABXAQAPAAUInApSBABXAQAYAAMIShNWFgCaAAAAAA==.',['霜云']='霜云:BAAALAAECgYIEgAAAA==.',['靈丶']='靈丶犇:BAACLAAFFH8kAAMTAAYIuRbyFACTAQATAAYIuRbyFACTAQAUAAQI1wJ3KQBwAAAsAAQKfxgAAxsACAhMFVoPAOYBABsACAhMFVoPAOYBABMACAhrDvxcAH0BAAAA.',['青阎']='青阎:BAAALAADCgMIAwAAAA==.',['静听']='静听松风:BAABLAAFFH8JAAIMAAIIBQzjFABhAAAMAAIIBQzjFABhAAAAAA==.',['非常']='非常粗糙:BAAALAAFFAYIAgAAAA==.',['面壁']='面壁者:BAAALAAECgYIEgAAAA==.',['面朝']='面朝灬大海:BAABLAAFFH8JAAISAAMIZQnhEgCRAAASAAMIZQnhEgCRAAAAAA==.',['顺昌']='顺昌逆亡:BAAALAAECgMIBgAAAA==.',['風舞']='風舞:BAAALAAECgUIBQAAAA==.',['風雨']='風雨夜無笙:BAAALAAECgcIEwAAAA==.',['风之']='风之魔王:BAAALAAFFAIIAgAAAA==.',['风从']='风从东方来:BAAALAAFFAIIBAAAAA==.',['风尘']='风尘仆仆:BAAALAAECgIIAwAAAA==.',['飘渺']='飘渺迷人香水:BAABLAAFFH8HAAIVAAIIkxtwCwCnAAAVAAIIkxtwCwCnAAAAAA==.',['飞羽']='飞羽骑士:BAABLAAFFH8HAAIZAAIIxQmPbQA0AAAZAAIIxQmPbQA0AAAAAA==.',['飞行']='飞行员舒克:BAAALAAECgYICAAAAA==.',['饮血']='饮血者玛鲁斯:BAABLAAFFH8UAAIHAAgI0gWRFgCkAAAHAAgI0gWRFgCkAAAAAA==.',['饺子']='饺子嫂子:BAAALAAECgYICQAAAA==.',['饿丨']='饿丨魔:BAABLAAFFH8FAAIcAAUITBKAEACiAQAcAAUITBKAEACiAQAAAA==.',['香烤']='香烤牛心大串:BAABLAAFFH8GAAIWAAYIOhabCwCaAQAWAAYIOhabCwCaAQAAAA==.',['骑骑']='骑骑呀:BAABLAAFFH8IAAIFAAII/yRRHwDVAAAFAAII/yRRHwDVAAAAAA==.',['骨汤']='骨汤牛肉面:BAAALAAFFAIIBAAAAA==.',['鬼冰']='鬼冰狂:BAAALAADCgYIBgAAAA==.',['魔法']='魔法披风:BAABLAAFFH8GAAIeAAIIiALAQgBuAAAeAAIIiALAQgBuAAAAAA==.',['麦肯']='麦肯娜格瑞丝:BAABLAAFFH8NAAMHAAUIFxHkEgDSAAAHAAMIXBHkEgDSAAAIAAIIsRAYGgBTAAAAAA==.',['麦辣']='麦辣鸡腿堡:BAAALAAECgYIEAAAAA==.',['黄公']='黄公子:BAAALAAECgcIBwAAAA==.',['黑痒']='黑痒痒:BAAALAAFFAIIBAAAAA==.',['黑白']='黑白红:BAAALAAECgUIBQAAAA==.',['黑色']='黑色月光:BAAALAAECgIIAgAAAA==.',['黑蕾']='黑蕾丝:BAAALAADCgcICQAAAA==.',['龘齌']='龘齌矲:BAABLAAECn8YAAIGAAYI7g9GUgAgAQAGAAYI7g9GUgAgAQAAAA==.',['龙喷']='龙喷工具人:BAABLAAFFH8GAAIBAAIIbAvfewCKAAABAAIIbAvfewCKAAAAAA==.',['龙小']='龙小倾:BAAALAAECgUICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end