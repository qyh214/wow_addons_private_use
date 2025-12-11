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
 local lookup = {'Paladin-Retribution','Paladin-Holy','DemonHunter-Havoc','Hunter-BeastMastery','Warrior-Protection','DeathKnight-Frost','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Hunter-Marksmanship','Mage-Arcane','Mage-Frost','Druid-Balance','DeathKnight-Unholy','Paladin-Protection','Warrior-Fury','Priest-Holy','DeathKnight-Blood','Shaman-Elemental','Priest-Shadow',}; local provider = {region='CN',realm='恐怖图腾',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alita:BAABLAAFFH8OAAMBAAMIxx0cHQDiAAABAAMIxx0cHQDiAAACAAIIEweBIwB+AAAAAA==.Alwaysqing:BAAALAAFFAIIBAAAAA==.',Ar='Arolurker:BAAALAAECgYIDgAAAA==.',Ch='Chance:BAAALAAFFAIIAgAAAA==.',Da='Dajsa:BAAALAAECggICAAAAA==.',De='Devilurustao:BAAALAAFFAIIBAAAAA==.',Ji='Jinyu:BAAALAADCgYICgAAAA==.',Ks='Ks:BAAALAAECgUIAwAAAA==.',Me='Memorize:BAAALAAECgYIEQAAAA==.',Mi='Migne:BAAALAAFFAIIBAAAAA==.',Nz='Nz:BAAALAAECgEIAQAAAA==.',Ta='Tark:BAAALAAECgYIBgAAAA==.',Un='Unbelievable:BAABLAAFFH8GAAIDAAII6gh7WwB9AAADAAII6gh7WwB9AAAAAA==.',['一橙']='一橙丿不染:BAAALAAECgEIAQAAAA==.',['一贱']='一贱你就笑:BAABLAAFFH8GAAIDAAIIyCPaIwDTAAADAAIIyCPaIwDTAAAAAA==.',['上帝']='上帝的狗:BAAALAAECgYIEwAAAA==.',['上海']='上海一九四三:BAAALAAECgMIBAAAAA==.',['下雪']='下雪懿橙:BAAALAAECgYIEQAAAA==.',['不要']='不要崇拜哥:BAAALAADCgMIAwAAAA==.',['专业']='专业切蛋:BAAALAAFFAIIBAABLAAFFAgIEAAEAOAGAA==.',['世界']='世界小可爱:BAAALAAFFAIIAgAAAA==.',['中意']='中意你丶:BAAALAADCgMIAwAAAA==.',['丶为']='丶为你写诗:BAAALAAECgQIBAAAAA==.',['丶你']='丶你中意:BAAALAAFFAIIAgAAAA==.丶你钟意:BAABLAAFFH8TAAIBAAUIbSAGGwCDAQABAAUIbSAGGwCDAQAAAA==.',['丶心']='丶心:BAAALAADCgQIBAAAAA==.',['乌黑']='乌黑的长耳朵:BAAALAADCgcIDgAAAA==.',['二笔']='二笔嘲讽脸:BAABLAAFFH8RAAIFAAMI6Ax5IgBnAAAFAAMI6Ax5IgBnAAAAAA==.',['亚奇']='亚奇洛贝丶:BAAALAADCgUIBQAAAA==.',['亢龍']='亢龍有悔:BAAALAADCgIIAgAAAA==.',['任我']='任我行:BAAALAAECgYIEQABLAAFFAIICQABAIIfAA==.',['伊博']='伊博爽诶:BAABLAAFFH8GAAIGAAII7AdsgwCEAAAGAAII7AdsgwCEAAAAAA==.',['伍月']='伍月:BAAALAADCgQIBAAAAA==.',['依城']='依城泷:BAAALAADCgYIBgAAAA==.',['依莎']='依莎贝尔:BAABLAAECn8nAAIBAAcINxwnUwBIAgABAAcINxwnUwBIAgAAAA==.',['俥傌']='俥傌炮:BAAALAAECgYIDAAAAA==.',['倪哥']='倪哥:BAAALAADCggICAAAAA==.',['健身']='健身狂魔:BAABLAAFFH8JAAIBAAMIwhPmRwB7AAABAAMIwhPmRwB7AAAAAA==.',['傻蔓']='傻蔓蔓:BAAALAAECgcICwAAAA==.',['僧爱']='僧爱尼:BAAALAAECgYIBwAAAA==.',['八神']='八神:BAAALAAECgYIDAAAAA==.',['八级']='八级大狂风哇:BAAALAAECgQIBAAAAA==.',['凤与']='凤与梧桐:BAAALAAECgYICQAAAA==.',['凤凰']='凤凰栖息梧桐:BAABLAAFFH8eAAIHAAYIYBevGACXAQAHAAYIYBevGACXAQAAAA==.',['凹依']='凹依稀特:BAAALAAECgMIBAAAAA==.',['出门']='出门左转:BAABLAAECn8xAAQIAAcITBnrMQCmAQAJAAYI3RnGZgC/AQAIAAYI2hXrMQCmAQAKAAEIoQObRQArAAAAAA==.',['勾丶']='勾丶八:BAAALAAFFAIIAgAAAA==.',['勾灬']='勾灬八:BAABLAAFFH8bAAIGAAYIeBg+NgBjAQAGAAYIeBg+NgBjAQAAAA==.',['包健']='包健玮:BAAALAAFFAYIAQAAAA==.',['十月']='十月三十一:BAAALAAECgYIDAAAAA==.',['卡子']='卡子:BAAALAADCgYIBgAAAA==.',['卡莎']='卡莎:BAAALAADCgMIAwAAAA==.',['卩臉']='卩臉上粑颗饭:BAAALAAECgQIBAAAAA==.',['又见']='又见喵星人:BAAALAAECgEIAQAAAA==.',['吃个']='吃个嘴子:BAAALAAECgEIAQAAAA==.',['吉祥']='吉祥赶猪棒:BAAALAAECgIIBgAAAA==.',['吥洅']='吥洅逥頭:BAAALAAECgYIDQAAAA==.',['吴散']='吴散弹:BAAALAAECgcIEAAAAA==.',['呦呦']='呦呦君:BAAALAAECgYICQAAAA==.',['咆哮']='咆哮熊德:BAAALAAECggIBwAAAA==.',['咔鮭']='咔鮭咿丨小鳥:BAACLAAFFH8nAAIBAAYIcyXmBgAaAgABAAYIcyXmBgAaAgAsAAQKfxgAAgEABwgAJhsYAE4CAAEABwgAJhsYAE4CAAAA.',['哈似']='哈似骑:BAAALAAFFAIIBAAAAA==.',['哎呀']='哎呀叶子:BAACLAAFFH8KAAIEAAIITw8/nABAAAAEAAIITw8/nABAAAAsAAQKfyIAAwQABwjyE4/AAH8BAAQABwjyE4/AAH8BAAsAAwhkBXmlAGcAAAAA.',['啊又']='啊又死了:BAAALAADCgYIDQAAAA==.',['喵尾']='喵尾巴:BAAALAAFFAIIAgAAAA==.',['喵翠']='喵翠花:BAAALAAFFAQIAwAAAA==.',['嘚嘚']='嘚嘚的德:BAAALAAECgcICAAAAA==.',['噩梦']='噩梦猎手:BAABLAAECn8YAAIDAAYIkxoPiQC0AQADAAYIkxoPiQC0AQAAAA==.',['嚣翱']='嚣翱神咒:BAACLAAFFH8IAAIGAAIIhBQwbACSAAAGAAIIhBQwbACSAAAsAAQKfx4AAgYABwi0IzMcAA8CAAYABwi0IzMcAA8CAAAA.',['团队']='团队毒瘤:BAABLAAFFH8MAAIGAAMIDxmOUACgAAAGAAMIDxmOUACgAAAAAA==.',['圣洁']='圣洁化身:BAAALAAECgYICQAAAA==.',['埃德']='埃德:BAAALAAFFAIIAgAAAA==.',['塞尔']='塞尔达是天:BAAALAADCgEIAQAAAA==.',['大妞']='大妞:BAABLAAFFH8MAAIFAAMISAgVJABbAAAFAAMISAgVJABbAAAAAA==.',['大愚']='大愚:BAAALAAECgIIAgAAAA==.',['大耳']='大耳先生:BAABLAAFFH8PAAIHAAUIhQ7tKwAIAQAHAAUIhQ7tKwAIAQAAAA==.大耳朵图图:BAAALAAFFAQIBAAAAA==.',['大飞']='大飞:BAAALAADCgIIAgAAAA==.',['大饭']='大饭团:BAAALAAECgYIBgAAAA==.',['天灾']='天灾风起云涌:BAABLAAFFH8FAAIMAAIIxyGaPgDCAAAMAAIIxyGaPgDCAAAAAA==.',['天然']='天然能量:BAABLAAFFH8GAAINAAIIFRGPFwBAAAANAAIIFRGPFwBAAAAAAA==.',['奈斯']='奈斯:BAAALAADCgQIBAAAAA==.',['奥利']='奥利奥丶:BAAALAAFFAIIBAAAAA==.',['奥术']='奥术智慧:BAAALAAECggIEAAAAA==.',['奥瑞']='奥瑞克:BAACLAAFFH8IAAIJAAMI2g+8QACXAAAJAAMI2g+8QACXAAAsAAQKfxUAAwkACAiTIe0SAE0CAAkACAiJIO0SAE0CAAgAAQhqIH8vAF0AAAAA.',['奥魂']='奥魂神奥魂:BAABLAAECn8lAAINAAYIAh4gEwCaAQANAAYIAh4gEwCaAQAAAA==.',['奶芙']='奶芙芙:BAAALAAECgMIAwAAAA==.',['好可']='好可爱啊:BAAALAAECgMIAwAAAA==.',['妖的']='妖的冤魂:BAAALAAECgIIAgAAAA==.',['威猛']='威猛先森:BAAALAAECgIIAgAAAA==.',['婉欣']='婉欣公主:BAAALAADCgYICQAAAA==.',['孤单']='孤单抗体:BAAALAAECgEIAQAAAA==.',['寻龙']='寻龙:BAAALAAECgcICgAAAA==.',['导演']='导演我想火:BAABLAAFFH8JAAIFAAMIYgVAGACYAAAFAAMIYgVAGACYAAAAAA==.',['小兒']='小兒:BAAALAAECgUIBgAAAA==.',['小冰']='小冰牛:BAAALAAECgIIAgAAAA==.',['小浣']='小浣熊丶:BAAALAAECgUIBgAAAA==.',['小肥']='小肥肥:BAAALAAECgYIDQAAAA==.',['小苏']='小苏仔:BAABLAAFFH8MAAIOAAIILgwSNAA8AAAOAAIILgwSNAA8AAAAAA==.',['小饭']='小饭粒:BAAALAAECgYIEgAAAA==.',['小鸡']='小鸡毛:BAAALAAECgYIEgAAAA==.',['就打']='就打那个德:BAAALAAECgQIBAAAAA==.',['尼诗']='尼诗灬埖:BAAALAADCgEIAQAAAA==.',['希尔']='希尔瓦娜一思:BAACLAAFFH8PAAIBAAIIKA36UACRAAABAAIIKA36UACRAAAsAAQKfycAAgEACAiiG8JDAHECAAEACAiiG8JDAHECAAAA.',['廿四']='廿四橋明月夜:BAAALAAFFAIIAgAAAA==.',['彩色']='彩色沙漠:BAAALAAECgQIBAAAAA==.',['很正']='很正经:BAAALAADCgYICQAAAA==.',['急于']='急于求橙:BAAALAAFFAIIBAAAAA==.',['恐怖']='恐怖的獠牙:BAABLAAFFH8RAAIEAAUI0Ao8WgDfAAAEAAUI0Ao8WgDfAAAAAA==.',['我热']='我热烈的马:BAAALAAECgMIAwAAAA==.',['戛爽']='戛爽:BAACLAAFFH8IAAIEAAII3xe6ZgCHAAAEAAII3xe6ZgCHAAAsAAQKfxgAAwsABggwH/BMAIIBAAsABghtF/BMAIIBAAQABgiAHBCjABUBAAAA.',['扎外']='扎外:BAABLAAFFH8JAAMLAAII/R/LFgC0AAALAAII/R/LFgC0AAAEAAEIex+2hwBHAAAAAA==.',['打你']='打你的屁啊屁:BAAALAADCgYIEgAAAA==.',['捡起']='捡起梦想:BAAALAAECgEIAQAAAA==.',['撤退']='撤退的矮子:BAAALAAECgUICAAAAA==.',['放开']='放开那位小妞:BAAALAADCgYICgAAAA==.',['斗力']='斗力:BAAALAADCgYIAgAAAA==.',['无敌']='无敌大炮:BAABLAAFFH8KAAINAAIIeRhFFgBCAAANAAIIeRhFFgBCAAAAAA==.',['暮鼓']='暮鼓晨钟:BAAALAAECggIAgAAAA==.',['月丶']='月丶刃:BAAALAAECgMIAwAAAA==.',['木尸']='木尸:BAAALAADCgYICAABLAAFFAQIDQAHAHQeAA==.',['术大']='术大招风:BAAALAAECgYIDgAAAA==.',['机车']='机车男孩小夏:BAABLAAFFH8RAAMGAAYIeCDhCgAGAgAGAAUILSLhCgAGAgAPAAEI8BeBFwBmAAABLAAFFAgIKQAGAMQlAA==.',['权志']='权志龙:BAAALAAECgIIAgAAAA==.',['松下']='松下裤带:BAAALAAECgcIDwAAAA==.',['柒月']='柒月丨流火:BAAALAAECgIIAgAAAA==.',['梧桐']='梧桐御风:BAABLAAFFH8JAAIQAAII+RGlHgAuAAAQAAII+RGlHgAuAAAAAA==.',['橙多']='橙多多撸撸力:BAAALAAECgYICwAAAA==.',['歌舞']='歌舞青春:BAAALAAECgYIBgAAAA==.',['死亡']='死亡唤魔:BAAALAADCgUIBQAAAA==.死亡怒吼:BAAALAADCgMIAwAAAA==.死亡怜悯:BAAALAADCgUIBQAAAA==.死亡掠袭:BAAALAADCgQIBAAAAA==.死亡旋风:BAAALAADCgMIAwAAAA==.死亡聖靈:BAAALAADCgYIDQAAAA==.死亡風舞:BAAALAADCgMIAwAAAA==.',['死誓']='死誓:BAAALAAECgUIBQAAAA==.',['毒甜']='毒甜心:BAAALAAECgYIDAAAAA==.',['水中']='水中月:BAAALAADCgIIAgAAAA==.',['永不']='永不为奴:BAABLAAFFH8IAAMRAAMIHQlmTQBGAAAFAAIInAjIKgBnAAARAAEIHQpmTQBGAAAAAA==.',['永恒']='永恒的执念:BAAALAAECgMIAwAAAA==.',['沁达']='沁达利亚:BAABLAAFFH8FAAIEAAIIEBZJYACLAAAEAAIIEBZJYACLAAAAAA==.',['沃德']='沃德霸霸:BAABLAAECn8ZAAIDAAcISxt0XwALAgADAAcISxt0XwALAgAAAA==.',['泡泡']='泡泡茶壶儿:BAAALAADCgYIBgAAAA==.',['流月']='流月苍岚:BAAALAAECgYIBgAAAA==.',['浅殇']='浅殇止水:BAAALAAFFAIIBAAAAA==.',['浙北']='浙北大厦:BAAALAADCgYIBgAAAA==.',['海奈']='海奈奈:BAAALAAECgMIAwAAAA==.',['深蓝']='深蓝浅蓝:BAAALAAECgUIBQAAAA==.',['渊渊']='渊渊自来:BAAALAAECgYIBgAAAA==.',['满世']='满世界瞎逛丶:BAAALAAFFAIIAgAAAA==.',['潇洒']='潇洒小豆子:BAAALAAECgIIAgAAAA==.潇洒狂刀:BAAALAAECgYICQAAAA==.',['火之']='火之高兴:BAAALAAECgUIBwAAAA==.',['灬活']='灬活力鱼串灬:BAAALAADCgUIBgAAAA==.',['熹熹']='熹熹怪兽:BAAALAADCgYIBgAAAA==.',['爱在']='爱在西元前:BAAALAAECgQICQAAAA==.',['牧不']='牧不转睛:BAAALAADCgYIBgAAAA==.',['特倫']='特倫苏:BAAALAAFFAIIAgAAAA==.',['狂牛']='狂牛莫问:BAAALAAFFAIIAgAAAA==.',['王者']='王者之泪:BAAALAAFFAIIAgAAAA==.',['瑛瑶']='瑛瑶其质:BAABLAAFFH8GAAILAAYIGwPACwDQAAALAAYIGwPACwDQAAAAAA==.',['生鱼']='生鱼:BAABLAAFFH8MAAIBAAYIkAN1WQBKAAABAAYIkAN1WQBKAAAAAA==.',['異想']='異想兲開:BAAALAAFFAIIBAAAAA==.',['疯疯']='疯疯狂骷髅:BAAALAAECgEIAQAAAA==.',['眼镜']='眼镜掉了:BAAALAAFFAIIAwAAAA==.',['睡也']='睡也睡不着:BAAALAADCgIIAgAAAA==.',['破风']='破风之骑:BAAALAAFFAIIAgAAAA==.',['神棍']='神棍德丶:BAAALAAFFAEIAQAAAA==.',['秋山']='秋山:BAAALAADCggICAAAAA==.',['空灬']='空灬城:BAABLAAECn8XAAMNAAYIzRRCGwBHAQANAAYIzRRCGwBHAQAMAAUI2gkpwgDyAAAAAA==.',['筋钢']='筋钢大:BAAALAAFFAIIAgAAAA==.',['粥粥']='粥粥児:BAABLAAFFH8LAAISAAMI4g2RLwCtAAASAAMI4g2RLwCtAAAAAA==.',['紫色']='紫色苍蝇:BAAALAAECgUIBQAAAA==.',['绯红']='绯红丨女皇:BAABLAAFFH8GAAIRAAYINAHDRwBLAAARAAYINAHDRwBLAAAAAA==.',['老牛']='老牛特黑:BAAALAAECgYIEAAAAA==.',['老许']='老许:BAAALAAECgYICwAAAA==.',['膀大']='膀大腰圆:BAAALAAFFAIIBAAAAA==.',['自动']='自动瞄准:BAAALAAECgYIBgAAAA==.',['艾斯']='艾斯卡玛利:BAAALAAECgYIDAAAAA==.',['花天']='花天狂骨丿:BAAALAAECgMIAwAAAA==.',['花开']='花开满:BAABLAAFFH8KAAIIAAIInA5DFgCYAAAIAAIInA5DFgCYAAAAAA==.',['苍之']='苍之怒:BAAALAAFFAMIAwAAAA==.',['若葉']='若葉牧:BAAALAAECggICwAAAA==.',['苦艾']='苦艾酒:BAAALAAECggICAAAAA==.',['菊花']='菊花有杀气:BAAALAADCgMIAwAAAA==.',['菊苣']='菊苣的杀气:BAAALAADCgUIBwAAAA==.',['菊菊']='菊菊有杀气:BAAALAADCgYICgAAAA==.',['萌之']='萌之麻友友:BAACLAAFFH8PAAIBAAUIwhYaKAA5AQABAAUIwhYaKAA5AQAsAAQKfx0AAgEACAhHIJYlAAACAAEACAhHIJYlAAACAAAA.',['萧萧']='萧萧瑟瑟:BAAALAAECggIEQAAAA==.',['萨格']='萨格拉满:BAAALAAECgEIAQAAAA==.',['萨维']='萨维奥拉:BAAALAAECgYIBwAAAA==.',['落叶']='落叶雲飛:BAAALAADCgYICgAAAA==.',['落小']='落小米:BAAALAADCgYIBgAAAA==.',['蕾姆']='蕾姆:BAAALAADCgQIBAAAAA==.',['虎贲']='虎贲校尉李:BAABLAAFFH8LAAMGAAYIHwH+kgA9AAAGAAYI/QD+kgA9AAATAAIIEwHnHQAqAAAAAA==.',['蜂蜜']='蜂蜜柚子糖:BAAALAAFFAIIAgAAAA==.',['血圣']='血圣天使:BAABLAAFFH8PAAIBAAUITBWtKQAwAQABAAUITBWtKQAwAQAAAA==.',['血屠']='血屠:BAAALAAECgEIAQAAAA==.',['街溜']='街溜子:BAABLAAFFH8TAAIJAAYI5xkbEQDbAQAJAAYI5xkbEQDbAQAAAA==.',['触手']='触手可及:BAAALAAECgYIBgAAAA==.',['詭刺']='詭刺:BAAALAAECgYIBgAAAA==.',['试试']='试试就逝世:BAAALAAFFAIIAgAAAA==.',['诺尔']='诺尔萨:BAAALAAECgYICwAAAA==.',['豆豆']='豆豆君:BAAALAADCgQIBAAAAA==.',['贫道']='贫道不戒:BAAALAAFFAIIAgAAAA==.',['赎魂']='赎魂:BAABLAAFFH8GAAIUAAYIHAFWQwBFAAAUAAYIHAFWQwBFAAAAAA==.',['赏金']='赏金游戏:BAAALAAFFAMIAwAAAA==.',['趣多']='趣多多丶:BAABLAAFFH8IAAIBAAIILwztaABCAAABAAIILwztaABCAAAAAA==.',['路人']='路人小米:BAAALAAECgYIEQAAAA==.',['蹲在']='蹲在茅坑玩蛆:BAAALAADCgYIDAAAAA==.',['转过']='转过来转过去:BAAALAADCgEIAQAAAA==.',['迪丽']='迪丽娜扎:BAABLAAFFH8WAAIEAAgIAB8pBgCGAgAEAAgIAB8pBgCGAgAAAA==.',['迪克']='迪克斯特朗:BAAALAADCgcICwAAAA==.',['那年']='那年夏天:BAAALAAECgIIAgAAAA==.那年秋天:BAAALAAECgMIAwAAAA==.',['邪恶']='邪恶的小米:BAAALAAECgMIAwAAAA==.',['野到']='野到腰闪:BAAALAADCgMIAwAAAA==.',['钟意']='钟意你丶:BAABLAAFFH8YAAIRAAUIKxu7IABmAQARAAUIKxu7IABmAQABLAAFFAgIBQAJAIQIAA==.',['铜曲']='铜曲:BAAALAADCggICAAAAA==.',['铜鞋']='铜鞋:BAAALAAECgYICgAAAA==.',['银河']='银河眼光子龙:BAAALAADCgcIDQAAAA==.',['闊少']='闊少爺:BAAALAAFFAIIBAAAAA==.',['阔少']='阔少爷:BAABLAAFFH8IAAMBAAIIPBQqOgCiAAABAAIIPBQqOgCiAAAQAAIICQf6HQBlAAAAAA==.',['阿达']='阿达逗:BAAALAAECgYIBwAAAA==.',['阿鬼']='阿鬼:BAAALAAECgYICAAAAA==.',['隂陽']='隂陽師:BAAALAAECgEIAQAAAA==.',['随波']='随波浮沉:BAAALAADCgQIBAAAAA==.',['隐隐']='隐隐青山:BAAALAAECgYIDwABLAAECgcIMQAIAEwZAA==.',['雨田']='雨田木羽:BAAALAAECgYIBgAAAA==.',['雪子']='雪子奶白:BAABLAAFFH8NAAIHAAYITgqgQwCbAAAHAAYITgqgQwCbAAAAAA==.',['霖耀']='霖耀咚咚:BAABLAAECn8ZAAMJAAYICRB5WAD2AAAJAAYICRB5WAD2AAAIAAMITAtoLQBnAAAAAA==.',['霜凌']='霜凌法影:BAACLAAFFH8FAAINAAUIxQZIEgBPAAANAAUIxQZIEgBPAAAsAAQKfygAAg0ABwiJHyUZAFECAA0ABwiJHyUZAFECAAAA.',['霜雨']='霜雨琪月:BAAALAAECgEIAQAAAA==.',['霞桜']='霞桜:BAAALAAECgYIDQAAAA==.',['霸击']='霸击大:BAAALAAECgcIBwAAAA==.',['非酋']='非酋永不为奴:BAAALAAECgMIBQAAAA==.',['颖约']='颖约记的:BAAALAADCggICAAAAA==.',['颯蠻']='颯蠻:BAAALAADCggICAAAAA==.',['风雨']='风雨雷电:BAAALAAECggICAAAAA==.',['飞下']='飞下孤白:BAAALAADCggICAAAAA==.',['馒头']='馒头馅:BAABLAAFFH8VAAMJAAYIGA/fLwBZAQAJAAUIawzfLwBZAQAIAAIIPBFQGgCOAAAAAA==.',['魅影']='魅影阑珊:BAABLAAFFH8MAAMIAAMIfRj2BADyAAAIAAMIIhj2BADyAAAJAAEIpwiYYAA+AAAAAA==.',['鳥鳥']='鳥鳥丶:BAABLAAFFH8zAAMSAAYIkCRPEADbAQASAAUIPCRPEADbAQAVAAUIvyTZCQC2AQAAAA==.',['鳳凰']='鳳凰:BAABLAAFFH8hAAITAAYIDg3GDAA+AQATAAYIDg3GDAA+AQAAAA==.',['鸿运']='鸿运当头丶:BAAALAADCgcIBwAAAA==.',['麦尖']='麦尖上的舞者:BAAALAADCgUIBQAAAA==.',['黑旋']='黑旋风李小逵:BAAALAAECgEIAQAAAA==.黑旋风李逵逵:BAAALAADCgIIAgAAAA==.',['黑牛']='黑牛德:BAAALAAECgYIBgAAAA==.',['黑狂']='黑狂君:BAAALAAECggICAAAAA==.',['龙麟']='龙麟儿:BAABLAAFFH8GAAIRAAIIYBUESgBJAAARAAIIYBUESgBJAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end