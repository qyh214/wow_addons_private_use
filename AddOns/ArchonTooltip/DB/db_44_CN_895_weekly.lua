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
 local lookup = {'Priest-Holy','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Paladin-Holy','DeathKnight-Unholy','DemonHunter-Havoc','DeathKnight-Frost','Warrior-Fury','Warrior-Arms','Unknown-Unknown','Mage-Arcane','Druid-Restoration','Monk-Mistweaver','Monk-Windwalker','Priest-Discipline','Hunter-Marksmanship','Mage-Frost','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Paladin-Retribution','Druid-Balance','Warlock-Destruction','Monk-Brewmaster','Warlock-Affliction','DemonHunter-Vengeance','Warrior-Protection','DeathKnight-Blood','Warlock-Demonology','Paladin-Protection','Priest-Shadow','Hunter-Survival','Mage-Fire',}; local provider = {region='CN',realm='黑暗之矛',name='CN',type='weekly',zone=44,date='2025-12-10',data={Aa='Aaillusionxx:BAAALAADCgYIBgAAAA==.',Al='Alexl:BAAALAAECgYIDAAAAA==.',Am='Amyyo:BAABLAAFFH8VAAIBAAYIkA51HABwAQABAAYIkA51HABwAQAAAA==.',As='Asukal:BAAALAAECgEIAQAAAA==.',Be='Bearfish:BAAALAAECgYIDAAAAA==.',Bl='Blueming:BAAALAAECgYIBgAAAA==.',Bt='Bth:BAAALAADCgYICAAAAA==.',Ca='Candyfish:BAAALAAECgIIAgAAAA==.',Ce='Celecoxib:BAABLAAECn8eAAMCAAYISiDtQQAYAgACAAYISiDtQQAYAgADAAYI2h0bPgAMAgABLAAFFAYICAAEAOoeAA==.',Cl='Clarmre:BAABLAAFFH8lAAIFAAYItyEdBwAlAgAFAAYItyEdBwAlAgAAAA==.',Cr='Crazybaby:BAAALAAECgYICQAAAA==.',Da='Darktifa:BAABLAAFFH8MAAIGAAIIFBDqEwCJAAAGAAIIFBDqEwCJAAAAAA==.',De='Deathfish:BAAALAAECgYIDAAAAA==.',Do='Downatlance:BAAALAAECgYIBgAAAA==.',Ev='Evilfish:BAAALAAECgYIBgAAAA==.',Fu='Fullyfully:BAAALAADCggICAAAAA==.Funeralx:BAABLAAECn8YAAIEAAYIMBzfngCtAQAEAAYIMBzfngCtAQAAAA==.Funeraly:BAAALAADCgYIBgAAAA==.',Hy='Hymenopus:BAABLAAFFH8mAAIHAAYIcyUoCwAdAgAHAAYIcyUoCwAdAgABLAAFFAgIDAAFAKUUAA==.',Ke='Keepreal:BAAALAAECgYIBgAAAA==.',Le='Letber:BAAALAAECgMIAwAAAA==.',Li='Likp:BAAALAAECgYIDAAAAA==.Lilasikuta:BAAALAAFFAIIAgAAAA==.',Ma='Marquis:BAABLAAFFH8KAAIIAAIIOxB/cgCPAAAIAAIIOxB/cgCPAAAAAA==.',Mi='Mitsuha:BAAALAAFFAIIAgAAAA==.',Mu='Mushroomfish:BAAALAAECgYIBgAAAA==.',Na='Nanvy:BAAALAAECgUIBwAAAA==.Natureparmer:BAAALAAECgEIAQAAAA==.',Ov='Ovoa:BAAALAADCgYIBgAAAA==.Ovoqq:BAAALAADCgcICgAAAA==.Ovot:BAABLAAFFH8LAAMIAAUIgx1ZPABRAQAIAAUIgx1ZPABRAQAGAAEIQQGUFgA+AAAAAA==.',Se='Secd:BAAALAADCgEIAQAAAA==.',Si='Siegheil:BAAALAAECgQIDgAAAA==.',Sl='Slithice:BAAALAADCgYIBgAAAA==.',Su='Sunny:BAAALAAECgMIBAAAAA==.',To='Tomorrow:BAAALAAECgEIAQAAAA==.Topi:BAABLAAFFH8GAAIBAAIINQoqOwB/AAABAAIINQoqOwB/AAAAAA==.',Vo='Voice:BAABLAAFFH8FAAIIAAMIrwpzaAB9AAAIAAMIrwpzaAB9AAAAAA==.',Xx='Xxs:BAAALAAECgMIAwAAAA==.',Zh='Zhjw:BAAALAAECgcIAQAAAA==.',['一只']='一只牛的寂寞:BAAALAAECgQIBAAAAA==.',['一头']='一头猛牛:BAACLAAFFH8cAAMJAAUI1haKJQBKAQAJAAUI1haKJQBKAQAKAAEIvxfLBwAAAAAsAAQKfxcAAwkABwjYIcAUAEACAAkABwjYIcAUAEACAAoAAgiQEqwzAF8AAAAA.',['一念']='一念神魔:BAAALAAECgMIAwAAAA==.',['一抹']='一抹夏凉:BAAALAAFFAIIAgABLAAFFAYIAgALAAAAAA==.',['一袋']='一袋米抗几楼:BAABLAAFFH8GAAIIAAIIFhc3eQBKAAAIAAIIFhc3eQBKAAAAAA==.',['一路']='一路繁华:BAAALAAECgIIAgAAAA==.',['丈夫']='丈夫的无能:BAAALAAECgIIAgAAAA==.',['三千']='三千个圣骑:BAAALAAECgIIAwAAAA==.',['不落']='不落的荣燿:BAABLAAECn8UAAIMAAgItRgwFwDxAQAMAAgItRgwFwDxAQAAAA==.',['不要']='不要奶拒绝污:BAAALAAECgYIBgAAAA==.',['不解']='不解風情:BAAALAADCgEIAQAAAA==.',['专踹']='专踹瘸子好腿:BAAALAAECgUIBQAAAA==.',['丨陌']='丨陌灵丨:BAAALAADCgEIAQAAAA==.',['丶冥']='丶冥冥:BAABLAAECn8aAAIIAAYIMiKXaAAkAgAIAAYIMiKXaAAkAgAAAA==.',['丶女']='丶女士不爽:BAAALAAFFAIIBAAAAA==.',['丶硬']='丶硬梆梆:BAABLAAFFH8KAAIIAAIIAhsCdABOAAAIAAIIAhsCdABOAAAAAA==.',['丶莉']='丶莉莉丝:BAAALAAFFAIIBAAAAA==.',['丶软']='丶软绵绵:BAABLAAFFH8JAAINAAIIcxeMOQCJAAANAAIIcxeMOQCJAAAAAA==.',['为你']='为你而疯狂:BAAALAAECgYIDgAAAA==.',['丿灬']='丿灬香草:BAAALAAECgIIAgAAAA==.',['乘风']='乘风踏浪:BAAALAAECgYIBgAAAA==.',['二丶']='二丶五:BAAALAADCgcICQAAAA==.',['二五']='二五:BAAALAADCgcICQAAAA==.',['二踢']='二踢脚:BAACLAAFFH9GAAMOAAYIvAhmBwA/AQAOAAYIvAhmBwA/AQAPAAUI4QtYDAAPAQAsAAQKfxoAAw8ACAhHEvIxAIQBAA8ABghcFfIxAIQBAA4ABggHCi82APoAAAAA.',['井上']='井上奈奈子:BAACLAAFFH8GAAIBAAMIZA00MgCjAAABAAMIZA00MgCjAAAsAAQKfxYAAwEABgjYH7AXAAkCAAEABgjYH7AXAAkCABAABgj5E4cUAGsBAAAA.',['人心']='人心薄凉丶伤:BAAALAAFFAgIAgAAAA==.',['人造']='人造甜味剂:BAAALAADCgIIAgAAAA==.',['人间']='人间漫浪:BAAALAADCgEIAQAAAA==.',['仔仔']='仔仔:BAAALAAECgYIBwAAAA==.',['仙尊']='仙尊洛尘:BAABLAAFFH8MAAIRAAYI6BayBACWAQARAAYI6BayBACWAQAAAA==.',['代天']='代天寻狩:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利单丶怒风:BAAALAADCgcIBwAAAA==.',['伊斯']='伊斯塔战灵:BAACLAAFFH8hAAMSAAYIKyVnAQAQAgAMAAYI4yJtCQAiAgASAAYI6yNnAQAQAgAsAAQKfzAAAhIACAgxJdMDAFQDABIACAgxJdMDAFQDAAEsAAUUCAgFABIAQx0A.',['体体']='体体:BAAALAAECgIIAwAAAA==.',['你是']='你是我宠物:BAAALAAECgMIBAAAAA==.',['你真']='你真高:BAAALAAECgYIDAAAAA==.',['做生']='做生意的:BAAALAAECgUICAAAAA==.',['傲風']='傲風殘玥:BAAALAADCgEIAQAAAA==.',['元气']='元气少女于谦:BAAALAAFFAIIAgAAAA==.',['光头']='光头李哥:BAAALAAECgEIAQAAAA==.',['克里']='克里斯蒂亚诺:BAAALAAECgYIBgAAAA==.',['兜兜']='兜兜卜:BAAALAAECgYIBwAAAA==.',['全踏']='全踏马妈格汗:BAABLAAFFH8YAAIEAAYIORmkJgCeAQAEAAYIORmkJgCeAQAAAA==.',['八叉']='八叉胡:BAAALAAECgYIDgAAAA==.',['养几']='养几个死几个:BAAALAADCgUIBQAAAA==.',['再来']='再来壹瓶:BAACLAAFFH8zAAMIAAcI1iIQBgBEAgAIAAcI1iIQBgBEAgAGAAMI3h/cBgAGAQAsAAQKfygAAwgACAjsI9ALAJgCAAgACAjaItALAJgCAAYABwgfInEMAIwCAAAA.',['冰媛']='冰媛:BAACLAAFFH8KAAMTAAIIdASuHwByAAATAAIIdASuHwByAAAUAAIImQtqGwBnAAAsAAQKfxgAAxUACAgbFJgOAGgBABUABggtEpgOAGgBABMABggxEh49AFMBAAAA.',['冰糕']='冰糕块块:BAABLAAFFH8bAAIWAAUImhcMJgBMAQAWAAUImhcMJgBMAQAAAA==.',['冷面']='冷面郎君:BAACLAAFFH8IAAIEAAII2RHybgCAAAAEAAII2RHybgCAAAAsAAQKfzIAAgQACAj8HQpKALUBAAQACAj8HQpKALUBAAAA.',['凌空']='凌空抽射:BAABLAAFFH8MAAMSAAIIBRkIFwBCAAAMAAIIBRlISwCVAAASAAEIFxUIFwBCAAAAAA==.',['凛冬']='凛冬疾风:BAAALAAECgYIBwAAAA==.',['凝雪']='凝雪:BAAALAAFFAIIBAAAAA==.',['凡星']='凡星之怒:BAAALAAECggICAAAAA==.',['凤凰']='凤凰之岚:BAABLAAFFH8HAAMNAAIIjhaFKACJAAANAAIIjhaFKACJAAAXAAEI4RCeNQA7AAABLAAFFAMIDgAYAKQYAA==.',['凰笑']='凰笑天:BAAALAAECgIIAwAAAA==.',['出门']='出门要迷路:BAABLAAFFH8GAAIFAAYICACxMgAKAAAFAAYICACxMgAKAAAAAA==.',['刀巴']='刀巴刀巴:BAAALAAFFAIIAgAAAA==.',['判官']='判官:BAAALAAECgEIAQAAAA==.',['刺桐']='刺桐:BAAALAAECgEIAQAAAA==.',['刺身']='刺身见手青:BAABLAAFFH8GAAIKAAYIcQNBAwCKAAAKAAYIcQNBAwCKAAAAAA==.',['刺鱼']='刺鱼:BAAALAAFFAIIBAAAAA==.',['剑刃']='剑刃不朽:BAACLAAFFH8XAAIWAAYItCFfDADmAQAWAAYItCFfDADmAQAsAAQKfyAAAhYACAgeI04dAP0CABYACAgeI04dAP0CAAAA.',['勒个']='勒个痛不痛:BAABLAAFFH8MAAIEAAYIPRyoJACmAQAEAAYIPRyoJACmAQAAAA==.',['千阳']='千阳子:BAABLAAFFH8HAAIZAAYIzBK5DgBjAQAZAAYIzBK5DgBjAQAAAA==.',['华里']='华里六六:BAAALAAECggIDQAAAA==.华里六叔:BAAALAAECgcIDAAAAA==.华里六月:BAAALAAECgYICwAAAA==.华里六魔:BAABLAAECn8dAAIIAAgI6gmSUABWAQAIAAgI6gmSUABWAQAAAA==.华里六鸢:BAAALAAECgYIDAAAAA==.华里十七:BAAALAAECgYIBgAAAA==.华里十三:BAAALAAECgYIBgAAAA==.华里十二:BAAALAAECgYIBwAAAA==.华里十六:BAAALAAECggICQAAAA==.华里大德:BAAALAAECgcICQAAAA==.华里威武:BAAALAAECgYICAAAAA==.华里怒怒:BAAALAAECggIDAAAAA==.华里鹭鹭:BAAALAADCggICAAAAA==.',['单线']='单线程:BAABLAAFFH8JAAIYAAUImxKKHgA5AQAYAAUImxKKHgA5AQAAAA==.',['南方']='南方大叔:BAAALAAECgIIAgAAAA==.',['博学']='博学者残月:BAABLAAFFH8iAAIMAAYIhRhpEQDbAQAMAAYIhRhpEQDbAQAAAA==.',['卡多']='卡多雷正黄旗:BAABLAAFFH8GAAIHAAII+BZtNwCgAAAHAAII+BZtNwCgAAAAAA==.',['卡波']='卡波基炮灰:BAAALAAECgEIAQAAAA==.',['卡着']='卡着射:BAAALAAECgIIAgAAAA==.',['卯月']='卯月麻衣:BAABLAAFFH8IAAIWAAIIch6eUQBXAAAWAAIIch6eUQBXAAAAAA==.',['卷王']='卷王:BAABLAAFFH8SAAIJAAII2x4nQgBaAAAJAAII2x4nQgBaAAAAAA==.',['双氧']='双氧水泡澡:BAAALAAECgYIBgAAAA==.',['变的']='变的心烦:BAABLAAECn8WAAMNAAcI1ROnXgB3AQANAAcI1ROnXgB3AQAXAAYIrhaKJQBLAQAAAA==.',['古龍']='古龍:BAABLAAFFH8FAAIHAAUIfBZyHgCOAQAHAAUIfBZyHgCOAQAAAA==.',['合波']='合波:BAABLAAFFH8GAAIIAAMIPRbsKQDxAAAIAAMIPRbsKQDxAAAAAA==.',['吊儿']='吊儿郎当:BAABLAAFFH8XAAIIAAYIpRBnMgB4AQAIAAYIpRBnMgB4AQAAAA==.',['吟风']='吟风:BAAALAAECgYIBgAAAA==.',['吴织']='吴织亚切:BAACLAAFFH8JAAIYAAMI6hPHKQDkAAAYAAMI6hPHKQDkAAAsAAQKfxYAAxgACAjeHXwyAHICABgACAiiHHwyAHICABoABAjxFtAdAAgBAAAA.',['呆萌']='呆萌恶魔:BAAALAAECgYICQAAAA==.',['周润']='周润发:BAAALAADCgMIAwAAAA==.',['咆哮']='咆哮的蛋蛋:BAAALAAECggICAAAAA==.',['咔溜']='咔溜咔溜:BAAALAADCgMIAwAAAA==.',['咖啡']='咖啡混美酒:BAAALAAFFAIIAgAAAA==.',['咦你']='咦你蛋:BAACLAAFFH8WAAIHAAUIPRYxKQBRAQAHAAUIPRYxKQBRAQAsAAQKfyAAAwcABggMIlQjANYBAAcABggMIlQjANYBABsAAgjXCDFhAEkAAAAA.',['哈尔']='哈尔琳丶:BAAALAAECgMIAwAAAA==.',['哎内']='哎内个谁:BAAALAAECgYIBgAAAA==.',['哓法']='哓法残月:BAABLAAFFH8jAAMMAAYI4hlPEgDTAQAMAAYIOBlPEgDTAQASAAEI1h/6EgBOAAAAAA==.',['喀秋']='喀秋鲨:BAAALAAECgYIBgAAAA==.',['喵喵']='喵喵旺:BAAALAADCgIIAgAAAA==.喵喵柒:BAAALAAECgMIAwAAAA==.',['嗜血']='嗜血朝天椒:BAAALAAECggICAAAAA==.嗜血警魂:BAAALAAECgQIBQAAAA==.',['嗷呜']='嗷呜就一口:BAAALAAECgEIAQAAAA==.',['嘿百']='嘿百合:BAAALAAECgYIBgAAAA==.',['噩梦']='噩梦中的舞者:BAAALAAFFAIIBAAAAA==.',['噩耗']='噩耗乌鸦:BAAALAAECgQICAAAAA==.',['回忆']='回忆:BAAALAAFFAIIAgAAAA==.回忆丿那么美:BAAALAAECgcICQABLAAFFAYIMAAcADgYAA==.回忆的海风:BAAALAAECgYIBwAAAA==.',['土豆']='土豆马铃薯:BAAALAAECgEIAQAAAA==.',['圣光']='圣光将熄丶:BAACLAAFFH9AAAMIAAcIKyRXBwCRAgAIAAcIKyRXBwCRAgAGAAEIUxpIIABBAAAsAAQKfxUAAwYACAhGIQwXAAkCAAYACAhcHQwXAAkCAAgABAjvJViuALEBAAAA.圣光骑:BAABLAAFFH8GAAIWAAIIJAR1fgA0AAAWAAIIJAR1fgA0AAAAAA==.',['圣火']='圣火徽章:BAAALAAFFAIIBAAAAA==.',['圣装']='圣装舞步:BAAALAADCgMIAwAAAA==.',['地狱']='地狱镇魂歌丶:BAABLAAFFH8MAAIJAAIIshBVTgBHAAAJAAIIshBVTgBHAAAAAA==.地狱震魂歌:BAACLAAFFH8GAAIIAAIIXBo7VgCdAAAIAAIIXBo7VgCdAAAsAAQKfxQAAggABggbIs1XAEcCAAgABggbIs1XAEcCAAAA.',['墨爺']='墨爺:BAAALAAECgYIDAAAAA==.',['夕梦']='夕梦:BAAALAAECgQICQAAAA==.',['夙命']='夙命的逆袭:BAAALAAECgEIAQAAAA==.',['多宝']='多宝无敌:BAAALAAECgYIBgAAAA==.',['多情']='多情小牛:BAABLAAFFH8hAAIcAAYI7h+OBwDSAQAcAAYI7h+OBwDSAQABLAAFFAgIEQAdAIgVAA==.',['夜暮']='夜暮色倾城:BAAALAAECgMIAwAAAA==.',['夜风']='夜风琪士:BAAALAAFFAYIBAAAAA==.',['夜魔']='夜魔之神:BAAALAADCgYIBgAAAA==.',['大披']='大披风:BAAALAAECgYICAAAAA==.',['天地']='天地有清风:BAABLAAFFH8GAAIWAAII+xcJLQCwAAAWAAII+xcJLQCwAAAAAA==.',['天天']='天天:BAAALAAECggICAAAAA==.',['天迹']='天迹:BAAALAAECgMIBAAAAA==.',['天青']='天青色等艳遇:BAAALAAECgYICAAAAA==.',['太极']='太极冰莫寒:BAABLAAFFH8MAAMCAAYI2yPNCACwAQACAAYI2yPNCACwAQADAAEI8iBKOgBfAAAAAA==.太极熊抱月:BAAALAAECgMIBAAAAA==.',['太阳']='太阳花:BAAALAAECgQIBAAAAA==.',['奈何']='奈何志:BAAALAAECgQIBAAAAA==.',['奔波']='奔波儿灞:BAAALAAECgYIBgAAAA==.',['奔跑']='奔跑的酱油:BAAALAAECgQIBQAAAA==.',['奔雷']='奔雷手文泰:BAABLAAECn8cAAMEAAYIXyFUWAAsAgAEAAYIXyFUWAAsAgARAAUIsgveiwC1AAAAAA==.',['奥术']='奥术会醒:BAABLAAFFH8UAAMSAAYIGRefCgDJAAAMAAYIGRe3IACUAQASAAQIPw+fCgDJAAAAAA==.',['奥特']='奥特曼六十七:BAAALAAECgYICgAAAA==.',['女兽']='女兽神:BAAALAADCgcIBwAAAA==.',['女馁']='女馁:BAAALAAECgMIBQAAAA==.',['奶油']='奶油流沙包:BAABLAAECn8gAAINAAgI2wyMcABFAQANAAgI2wyMcABFAQAAAA==.',['奶神']='奶神翻车鱼:BAAALAADCgMIAwAAAA==.',['妄念']='妄念:BAABLAAFFH8LAAIMAAYIHRshIwCKAQAMAAYIHRshIwCKAQAAAA==.',['妈个']='妈个汗售任:BAABLAAFFH8vAAMRAAYImCLaAQACAgARAAYImCLaAQACAgAEAAYI0Q/EDQDFAQAAAA==.',['妖精']='妖精十尾巴:BAAALAADCggICAAAAA==.妖精十弑魂:BAAALAAECgYIDAAAAA==.',['姆巴']='姆巴巴:BAAALAAECgYICAAAAA==.',['媚祸']='媚祸无穷:BAAALAAECgYICwAAAA==.',['子墨']='子墨抒画:BAAALAAECgcIDAAAAA==.',['宇梦']='宇梦璇中藏:BAAALAAECgYIAgAAAA==.',['安居']='安居乐业:BAABLAAFFH8qAAIRAAYI+h+LAgDhAQARAAYI+h+LAgDhAQAAAA==.',['安布']='安布雷拉:BAAALAAECgUIBQAAAA==.',['宝贝']='宝贝熊熊:BAAALAAECgYICgAAAA==.',['客串']='客串的:BAAALAAECgYIEAAAAA==.',['寻山']='寻山:BAAALAAECgYICQAAAA==.',['寻找']='寻找圣光:BAAALAAECgIIAgAAAA==.',['封号']='封号斗锣:BAABLAAFFH8oAAIRAAYIHSMkAgDzAQARAAYIHSMkAgDzAQAAAA==.',['小圆']='小圆脸:BAAALAAFFAIIBAAAAA==.',['小小']='小小圆脸:BAABLAAFFH8KAAIEAAIIXxbHYQCKAAAEAAIIXxbHYQCKAAAAAA==.',['小披']='小披风:BAAALAAECgYICQAAAA==.',['小气']='小气鬼泡芙:BAAALAAECgYICgAAAA==.',['小猎']='小猎残月:BAABLAAFFH8wAAIRAAYIwyGlAwAEAgARAAYIwyGlAwAEAgAAAA==.',['小贼']='小贼玛莉亚:BAABLAAFFH8IAAIMAAIITghxWwCDAAAMAAIITghxWwCDAAAAAA==.',['尖刺']='尖刺:BAAALAAECgYIDAAAAA==.',['尖头']='尖头叉子:BAAALAAECgIIAgAAAA==.',['尘曦']='尘曦:BAAALAAECgYIDAAAAA==.',['尘緣']='尘緣淺:BAABLAAFFH8OAAMeAAIIqg6sFgCXAAAeAAIIAg6sFgCXAAAYAAII8AtoVAB0AAAAAA==.',['尘缘']='尘缘:BAABLAAFFH8IAAIHAAIInRGvWQBEAAAHAAIInRGvWQBEAAAAAA==.尘缘淺:BAABLAAFFH8QAAIYAAYI1yIjRwC0AAAYAAYI1yIjRwC0AAAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8eAAIZAAgIWxC9BgDwAQAZAAgIWxC9BgDwAQAAAA==.',['山水']='山水:BAAALAAFFAIIAgAAAA==.',['山涧']='山涧的雨:BAABLAAFFH8OAAIMAAII4xwKOgCnAAAMAAII4xwKOgCnAAAAAA==.',['崽崽']='崽崽:BAAALAAECgYIAwAAAA==.',['左手']='左手指月:BAAALAADCgUIBQAAAA==.',['巴尔']='巴尔:BAACLAAFFH8JAAMJAAIIYRlySABMAAAJAAIIYRlySABMAAAcAAIIvwxwLwA1AAAsAAQKfx4AAwkACAhwE5BQAP8BAAkACAgsE5BQAP8BABwABAjRDS1yAMAAAAAA.巴尔之殇:BAACLAAFFH8JAAIbAAIIIwcDGQBSAAAbAAIIIwcDGQBSAAAsAAQKfxcAAxsACAi9FQQiAKcBAAcACAgoD7qLAK8BABsABghKGAQiAKcBAAAA.巴尔之灵:BAAALAAFFAIIAgAAAA==.巴尔之魂:BAACLAAFFH8IAAMIAAIIlwbrjwB3AAAIAAIIWwTrjwB3AAAdAAIIbAZlHgArAAAsAAQKfxYAAwgACAj1GMBsABwCAAgACAj1GMBsABwCAB0ACAiABvwuAAUBAAAA.',['巴达']='巴达木:BAAALAAECgQIBAAAAA==.',['布狄']='布狄卡:BAAALAADCgcIBwAAAA==.',['帅气']='帅气无比的牛:BAAALAAECgYIBwAAAA==.',['希瑞']='希瑞瑞:BAABLAAFFH8HAAIEAAMIfhRjdQB7AAAEAAMIfhRjdQB7AAAAAA==.',['带罩']='带罩看命:BAAALAAECgcIEgAAAA==.',['干饭']='干饭与射射:BAAALAADCgEIAQAAAA==.',['幻灵']='幻灵月光之吻:BAAALAAECgUIBQAAAA==.幻灵虾米:BAAALAAECgUIBQAAAA==.幻灵鬼尊:BAAALAAECgYIBgAAAA==.',['开拓']='开拓者:BAABLAAFFH8LAAIJAAUIPwUTMADeAAAJAAUIPwUTMADeAAAAAA==.',['弗拉']='弗拉基宓尔:BAABLAAFFH8IAAMeAAII7SCoDABcAAAeAAII7SCoDABcAAAYAAEImAkAZgA7AAABLAAFFAgIHgAEADkbAA==.',['强風']='强風吹拂:BAAALAADCgMIAwAAAA==.',['强风']='强风吹拂:BAAALAAECgYIBwAAAA==.',['影枫']='影枫叶:BAACLAAFFH8wAAIWAAcI9R5pBABOAgAWAAcI9R5pBABOAgAsAAQKfyYAAxYACAjZIrgfAPMCABYACAjZIrgfAPMCAAUABgjiE2keAFcBAAAA.',['影魔']='影魔:BAAALAAFFAEIAQAAAA==.',['德喵']='德喵:BAAALAAECgYIBgAAAA==.',['德德']='德德晓枫:BAAALAAECgQIBAAAAA==.德德的逆袭:BAAALAAECgYIBgAAAA==.',['心电']='心电心:BAAALAAECgEIAQAAAA==.',['思媛']='思媛妹妹:BAABLAAFFH8KAAMfAAIIaBoeGAB3AAAfAAIIRRMeGAB3AAAWAAIIaBpUXgBIAAABLAAFFAgISAAgAGgeAA==.',['性感']='性感小罩罩丶:BAABLAAFFH8kAAIWAAUIVhCdLgAbAQAWAAUIVhCdLgAbAQAAAA==.',['怯情']='怯情:BAAALAAFFAIIBAAAAA==.',['恶灵']='恶灵骑者:BAAALAAECgQIBAAAAA==.',['悠然']='悠然南山:BAAALAADCgIIAgAAAA==.',['情俩']='情俩难:BAABLAAFFH8HAAIIAAIIdxLAZwCUAAAIAAIIdxLAZwCUAAAAAA==.',['意大']='意大利炮:BAAALAAECgEIAQAAAA==.',['愤怒']='愤怒的暮雪:BAAALAADCggICAAAAA==.',['懵乖']='懵乖乖:BAAALAAECgYICAAAAA==.',['戏吇']='戏吇多秋:BAAALAAFFAYIBAAAAA==.',['我一']='我一不小心:BAABLAAFFH8KAAIJAAYIpg6VJgBCAQAJAAYIpg6VJgBCAQABLAAFFAYIEAAMABYOAA==.',['我人']='我人傻了:BAAALAAECgYIDQAAAA==.',['我信']='我信了你的斜:BAAALAAECgUIBgAAAA==.',['我去']='我去丢个垃圾:BAABLAAECn8UAAIWAAgIahoBRABwAgAWAAgIahoBRABwAgAAAA==.',['我我']='我我爱一条柴:BAAALAAFFAMIAwABLAAFFAgIEgAEAM0MAA==.',['我是']='我是传奇:BAAALAADCggICAAAAA==.',['我骑']='我骑我袖:BAAALAAECgUICQAAAA==.',['战役']='战役:BAAALAAFFAMIAwAAAA==.',['戰吴']='戰吴卟勝:BAABLAAFFH8JAAIcAAIIHwRDLgBdAAAcAAIIHwRDLgBdAAAAAA==.',['戴斯']='戴斯艾克神:BAABLAAFFH8GAAIYAAYI7RE3LQBqAQAYAAYI7RE3LQBqAQAAAA==.',['打不']='打不赢就滚:BAABLAAFFH8jAAIPAAYI1xWbBgCVAQAPAAYI1xWbBgCVAQAAAA==.打不过就加入:BAAALAAECgEIAQAAAA==.',['打雷']='打雷要下雨:BAAALAAECggIDgAAAA==.',['扶摇']='扶摇:BAABLAAFFH8KAAMBAAIICxLuOwBzAAABAAIICxLuOwBzAAAQAAEISghFBgA/AAAAAA==.',['抠鼻']='抠鼻:BAAALAAFFAIIBAAAAA==.',['择鹿']='择鹿:BAAALAAFFAIIAgAAAA==.择鹿鹿:BAAALAAECgIIAgAAAA==.',['拽到']='拽到底:BAAALAAECgQIBQAAAA==.',['搥溯']='搥溯摤嗳嗳:BAAALAAECgYIEQAAAA==.',['携手']='携手挽清风:BAAALAAECgEIAQAAAA==.',['摇滚']='摇滚鈿鈊:BAAALAAFFAIIAgAAAA==.',['摩法']='摩法披风:BAABLAAFFH8KAAIEAAIIjiARgABdAAAEAAIIjiARgABdAAAAAA==.',['撒撕']='撒撕给:BAABLAAFFH8eAAMRAAYIZR1IAwDEAQARAAYIZR1IAwDEAQAEAAYITgiZVAAGAQAAAA==.',['放开']='放开丨淡薄:BAAALAAECgYIBgAAAA==.',['放牛']='放牛的小星星:BAAALAAECgUIBQAAAA==.',['斩月']='斩月:BAAALAAECgUIBQAAAA==.',['无情']='无情的空狗:BAAALAADCgIIAgAAAA==.',['无所']='无所事事:BAAALAAECgIIAgAAAA==.',['无聊']='无聊壹号:BAABLAAFFH8sAAIRAAYIQCERBAD3AQARAAYIQCERBAD3AQAAAA==.',['星小']='星小狐:BAAALAAECgUIBQAAAA==.',['星空']='星空海螺:BAABLAAFFH8GAAIEAAIIfRe7kQBFAAAEAAIIfRe7kQBFAAAAAA==.',['是你']='是你太暖心:BAAALAAECgUICAAAAA==.',['普洛']='普洛米修斯:BAAALAAECgUIBAAAAA==.',['暗夜']='暗夜劣:BAAALAAFFAIIAgAAAA==.暗夜劣手:BAACLAAFFH8FAAIEAAIIMAL/wgAkAAAEAAIIMAL/wgAkAAAsAAQKfxgAAgQABgiWBkPiAMAAAAQABgiWBkPiAMAAAAAA.暗夜术:BAABLAAFFH8GAAMeAAII3wBqGwAOAAAYAAII3gBZdgARAAAeAAII2gBqGwAOAAAAAA==.',['暗影']='暗影大叔:BAACLAAFFH8hAAMaAAYI5B1zAAACAgAaAAYI5B1zAAACAgAYAAUI9BnMEwDAAQAsAAQKfxwAAxoACAgQIqoEAKsCABoACAisHaoEAKsCABgACAgLHB07AE0CAAAA.暗影肖恩:BAAALAAFFAIIBAAAAA==.',['暴躁']='暴躁:BAABLAAFFH8QAAIWAAMIORWpLwCsAAAWAAMIORWpLwCsAAAAAA==.',['最后']='最后的亲雨:BAABLAAFFH8xAAIRAAYIniO0AgAeAgARAAYIniO0AgAeAgAAAA==.',['月影']='月影依枪:BAAALAAECggICAAAAA==.',['月曦']='月曦言:BAABLAAFFH8WAAIWAAYIdgq3KAA9AQAWAAYIdgq3KAA9AQAAAA==.',['月球']='月球兔宝宝:BAAALAAECgMIBAAAAA==.',['木木']='木木虹:BAAALAAECgYIBgAAAA==.',['束丨']='束丨缚:BAAALAAECgYIDQAAAA==.',['杨乃']='杨乃五:BAAALAAECgIIAgAAAA==.',['林北']='林北丶:BAAALAAECgYIEQAAAA==.',['枯萎']='枯萎的温柔:BAAALAAECgEIAQAAAA==.',['枯雪']='枯雪:BAAALAAECgYIBgAAAA==.',['柒零']='柒零:BAABLAAFFH8IAAICAAIIsBaYPwCCAAACAAIIsBaYPwCCAAAAAA==.',['柳丷']='柳丷:BAABLAAFFH8LAAICAAYIdyPABwBMAgACAAYIdyPABwBMAgAAAA==.',['格瓦']='格瓦迪奥尔:BAAALAAECgcIBwAAAA==.',['格蕾']='格蕾丝:BAAALAAFFAIIBAAAAA==.',['格調']='格調乀:BAAALAAECgYIEwAAAA==.',['梦醒']='梦醒十分:BAAALAAECgEIAQAAAA==.',['棍儿']='棍儿:BAAALAAECgYICwAAAA==.',['椛橘']='椛橘杍:BAAALAADCgcIBwAAAA==.',['楚乔']='楚乔:BAABLAAECn8ZAAMRAAgIsBy6NQDnAQAEAAgI7hsqegDpAQARAAgIVRa6NQDnAQABLAAFFAcIFgAEAIgPAA==.',['欧皇']='欧皇刑天:BAABLAAFFH8GAAIHAAIIVh5cTwBLAAAHAAIIVh5cTwBLAAABLAAFFAMIDgAYAKQYAA==.',['此号']='此号女人:BAAALAADCgYIBgAAAA==.此号有人:BAABLAAFFH8UAAIEAAYI/SJ5EQAHAgAEAAYI/SJ5EQAHAgAAAA==.',['武器']='武器战:BAAALAAECgMIAwAAAA==.',['歪乖']='歪乖乖:BAAALAAECgYIBgAAAA==.',['歪崽']='歪崽崽:BAAALAAECgYICwAAAA==.',['死亡']='死亡的圆舞曲:BAABLAAECn8UAAMIAAYIZhdiTgBcAQAIAAYIZhdiTgBcAQAGAAEIOgn9WgA9AAAAAA==.死亡的舞曲:BAABLAAECn8VAAQRAAYIZRW1FQD9AAARAAYI6RS1FQD9AAAhAAEI6w5LEgA0AAAEAAIIIgiyPgEsAAAAAA==.',['死神']='死神卡卡:BAAALAADCgMIAwAAAA==.死神的斩月:BAABLAAECn8cAAMSAAgI5iDqCQD6AgASAAgI5iDqCQD6AgAMAAEIsRe4/ABCAAAAAA==.',['残血']='残血:BAAALAADCgIIAgAAAA==.',['每天']='每天高乐高:BAABLAAFFH8zAAMMAAYI7CO1DQAaAgAMAAYI7CO1DQAaAgASAAEIEhqnHgBIAAAAAA==.',['毛团']='毛团子:BAACLAAFFH8bAAIcAAUIjRHkFwD1AAAcAAUIjRHkFwD1AAAsAAQKfxYAAwkABwgOGV9sALUBAAkABgg8GV9sALUBABwABAg5E1o6AK0AAAEsAAUUCAg5AAkA1CMA.',['江湖']='江湖人称神皇:BAAALAAECggIDgAAAA==.',['法力']='法力残渣:BAAALAAECgMIAwAAAA==.',['法式']='法式小面包:BAABLAAFFH8OAAIMAAYIexdoIQCRAQAMAAYIexdoIQCRAQAAAA==.',['泡芙']='泡芙甜心:BAAALAAECgMIAwAAAA==.',['泡菜']='泡菜下饭:BAAALAADCgUIBQAAAA==.',['泥鳅']='泥鳅:BAAALAAECgUICAAAAA==.',['泪痕']='泪痕:BAAALAADCgcICAAAAA==.',['泰瑞']='泰瑞昂黎明:BAACLAAFFH8mAAIIAAYI3yHLFgDnAQAIAAYI3yHLFgDnAQAsAAQKfyEAAwgACAhpJHIfAPECAAgACAgpJHIfAPECAAYABQjbHtEsAFwBAAAA.',['洛克']='洛克塔:BAABLAAFFH8gAAIGAAUIRhyDBABmAQAGAAUIRhyDBABmAQAAAA==.',['洛琪']='洛琪希:BAACLAAFFH8MAAICAAUI4BXIJQA5AQACAAUI4BXIJQA5AQAsAAQKfxQAAgIACAjpGp0iAO0BAAIACAjpGp0iAO0BAAAA.',['洛青']='洛青鸾:BAABLAAFFH8FAAIgAAUIpRKaFAAyAQAgAAUIpRKaFAAyAQAAAA==.',['浅灰']='浅灰蓝:BAAALAAFFAIIAgAAAA==.',['浮生']='浮生若清风:BAABLAAFFH8GAAIIAAII2RXiVgCdAAAIAAII2RXiVgCdAAAAAA==.',['海公']='海公牛:BAAALAAFFAIIAgAAAA==.',['淚痕']='淚痕:BAAALAADCgEIAQAAAA==.',['淡漠']='淡漠丶:BAAALAAECgIIAgAAAA==.淡漠丶文:BAAALAAECgEIAQAAAA==.淡漠丶赐:BAABLAAFFH8KAAICAAIIqA2OUQBqAAACAAIIqA2OUQBqAAAAAA==.',['清泪']='清泪无痕:BAAALAAECgYIBgAAAA==.',['清辞']='清辞:BAAALAADCgUIBQAAAA==.',['清风']='清风拂山岗:BAAALAAFFAIIBAAAAA==.',['湛蓝']='湛蓝乀:BAAALAAECgYIBgAAAA==.',['满仓']='满仓加杠杆:BAABLAAECn8ZAAIWAAYI4x7vbwAKAgAWAAYI4x7vbwAKAgAAAA==.',['满大']='满大人:BAAALAAECggICAAAAA==.',['澹灏']='澹灏悦:BAAALAAFFAIIAgAAAA==.',['火火']='火火的歌谣:BAAALAAECgcIBwAAAA==.',['火鸡']='火鸡锅巴:BAAALAADCgQIBAAAAA==.',['灬影']='灬影丶少灬:BAAALAAECgIIAwAAAA==.',['灬輚']='灬輚狂灬:BAABLAAFFH8KAAMcAAYISAAWLwA1AAAcAAYIRQAWLwA1AAAJAAQIBQAUagAHAAAAAA==.',['灭绝']='灭绝师太:BAABLAAECn8iAAMeAAgIZhdBEQBgAQAYAAgIRBNLUwD3AQAeAAYIfhhBEQBgAQAAAA==.',['灿若']='灿若灬星辰:BAAALAADCgYIBgAAAA==.',['烈焰']='烈焰魔剑:BAAALAAFFAIIBAAAAA==.',['烟纹']='烟纹酒好女孩:BAAALAAECgEIAQAAAA==.',['無心']='無心恋戰:BAABLAAFFH8eAAIJAAYIXBgBGQCeAQAJAAYIXBgBGQCeAQAAAA==.',['熊嘎']='熊嘎婆:BAACLAAFFH8MAAIEAAUIVxD9WADyAAAEAAUIVxD9WADyAAAsAAQKfxcAAwQABgiqGkCtAJkBAAQABgiqGkCtAJkBABEABgiODxBpACEBAAAA.',['熊大']='熊大如牛:BAAALAAECgEIAQAAAA==.',['燃烧']='燃烧的大胡子:BAAALAADCgcIBwAAAA==.燃烧的獠牙:BAABLAAECn8UAAMRAAYI5Q/kGgDDAAARAAYI/w7kGgDDAAAEAAQIhgXgZgGFAAAAAA==.',['爱吸']='爱吸吸:BAAALAAECgQIBAAAAA==.',['爱德']='爱德华纽盖特:BAAALAADCgMIAwAAAA==.',['爱芷']='爱芷灵儿:BAABLAAECn8aAAIWAAYIdxI1dQAZAQAWAAYIdxI1dQAZAQAAAA==.',['牛小']='牛小花:BAAALAAECggICAAAAA==.',['牛莽']='牛莽会武术:BAAALAAECgEIAQAAAA==.',['狂霸']='狂霸天:BAAALAADCgcIBwAAAA==.',['狂风']='狂风闪电:BAACLAAFFH8eAAIDAAYI8RuKEQC3AQADAAYI8RuKEQC3AQAsAAQKfxUAAgMABggSHAEpAHwBAAMABggSHAEpAHwBAAAA.',['狠彪']='狠彪悍:BAABLAAFFH8KAAIIAAYI+RrXJACnAQAIAAYI+RrXJACnAQAAAA==.',['独孤']='独孤煌琊:BAAALAADCgIIAgAAAA==.',['猪猪']='猪猪大魔王:BAAALAADCggICAAAAA==.',['猫榕']='猫榕榕:BAAALAADCggICAAAAA==.',['猫猫']='猫猫侠:BAAALAAECgYICwAAAA==.猫猫的小牙虫:BAAALAAECgQIBAAAAA==.',['猫老']='猫老喵:BAAALAADCggICAABLAAFFAgICAASAGwEAA==.',['王临']='王临天下:BAAALAAFFAMIAwAAAA==.',['王如']='王如意:BAABLAAFFH8GAAIdAAYI0Q2wDQA0AQAdAAYI0Q2wDQA0AQAAAA==.',['王牛']='王牛牛快跑:BAAALAAECgEIAgAAAA==.',['玛格']='玛格丽特丶:BAAALAADCgIIAgAAAA==.',['珈尔']='珈尔鲁什:BAAALAAFFAQIBAAAAA==.',['珐烨']='珐烨:BAACLAAFFH8GAAMSAAMIlhVjDQCHAAASAAMIlhVjDQCHAAAMAAIIqwELbwAGAAAsAAQKfxgAAxIABwh5G9QNAOQBABIABghHHtQNAOQBAAwABwg4D6MvAFgBAAAA.',['璇影']='璇影落星宇:BAABLAAECn8WAAIEAAgIDyPbFAAMAwAEAAgIDyPbFAAMAwAAAA==.',['电城']='电城小杨杨:BAAALAAECgUIBgAAAA==.电城猪肠粉:BAAALAAECgYIBwAAAA==.',['电子']='电子竞技无心:BAAALAAECgIIAgAAAA==.',['男孩']='男孩本色:BAACLAAFFH8IAAISAAIIpB3qEQBUAAASAAIIpB3qEQBUAAAsAAQKfyMAAhIACAjNHCEJADMCABIACAjNHCEJADMCAAAA.',['男波']='男波:BAAALAAECgIIAgAAAA==.',['白面']='白面花卷:BAAALAAECgUIBgAAAA==.',['百鬼']='百鬼宴刹罗:BAAALAAECgcIDQAAAA==.',['瞘丗']='瞘丗馫飝:BAAALAADCgMIAwAAAA==.',['矮子']='矮子快跑:BAAALAADCggICAAAAA==.',['神牛']='神牛飞蹄:BAAALAAFFAIIBAAAAA==.',['神说']='神说我最美:BAAALAAECgIIAwAAAA==.神说我来了:BAAALAAECgYIBgAAAA==.神说有光:BAAALAAECgYICwAAAA==.',['福星']='福星宝宝:BAAALAAECgYIDgAAAA==.',['秋月']='秋月:BAAALAAFFAQIBAAAAA==.',['秋豆']='秋豆子:BAAALAAECggIDAAAAA==.',['秋风']='秋风秋雨:BAAALAAECgcIDgAAAA==.',['童斧']='童斧:BAAALAAFFAIIBAAAAA==.',['简蒂']='简蒂丝:BAAALAAECgMIAwAAAA==.',['管辂']='管辂:BAAALAADCgEIAQAAAA==.',['箭扬']='箭扬天下:BAAALAADCgYIBgAAAA==.',['精霊']='精霊之涙:BAABLAAECn8aAAISAAYIGBUtHABFAQASAAYIGBUtHABFAQAAAA==.',['糖果']='糖果儿:BAAALAAECgYIBgAAAA==.',['素椒']='素椒杂酱面:BAAALAAECggICAAAAA==.',['紫色']='紫色初雪:BAABLAAFFH8QAAIMAAYIFg6ZLQBZAQAMAAYIFg6ZLQBZAQAAAA==.紫色柠檬:BAABLAAFFH8FAAIEAAUI2wtNVwD6AAAEAAUI2wtNVwD6AAAAAA==.',['红葱']='红葱头:BAAALAAECgMIAwAAAA==.',['纪昌']='纪昌:BAAALAAECggICwAAAA==.',['纳如']='纳如脱:BAABLAAFFH8SAAIEAAYIoRk1KACYAQAEAAYIoRk1KACYAQAAAA==.',['终极']='终极萨满:BAAALAAECgcICAAAAA==.',['维生']='维生素萨萨:BAAALAAECgYIBgAAAA==.',['缥缈']='缥缈回忆:BAAALAAECgYICQAAAA==.',['罗包']='罗包包:BAAALAAFFAIIAgAAAA==.',['美好']='美好保留:BAAALAADCgYIBgAAAA==.',['羞羞']='羞羞的小气包:BAAALAADCgQIBgAAAA==.',['翎羽']='翎羽寒歌:BAAALAAECgYIBgAAAA==.',['老婆']='老婆饼:BAAALAADCgcIBwAAAA==.',['老子']='老子蜀道山:BAAALAAFFAIIAgAAAA==.',['老德']='老德益壮:BAAALAADCggICAAAAA==.',['老村']='老村长:BAAALAAECgYIDAAAAA==.',['老纸']='老纸还不信了:BAABLAAFFH8XAAIRAAYI/iB0AgDlAQARAAYI/iB0AgDlAQAAAA==.',['老衲']='老衲戒色多年:BAAALAAFFAIIAgAAAA==.',['聪明']='聪明的顺溜:BAAALAAECgYICQAAAA==.',['肆虐']='肆虐的回忆:BAAALAAFFAMIAwAAAA==.',['肉丸']='肉丸儿:BAAALAAFFAIIAgAAAA==.',['肥肠']='肥肠面:BAAALAAFFAIIAgAAAA==.',['能不']='能不能玩:BAAALAAFFAIIBAAAAA==.',['脚趾']='脚趾野草味:BAAALAAECgEIAQAAAA==.',['自由']='自由自在:BAAALAAECgIIAgAAAA==.',['艾克']='艾克佐尼亚:BAAALAAFFAIIBAAAAA==.',['芒果']='芒果很黄:BAABLAAECn8XAAMYAAYIwwnCrQAeAQAYAAYIEAjCrQAeAQAeAAQIygv5JwCXAAAAAA==.',['花开']='花开的时候:BAAALAAECgYICwAAAA==.',['苍白']='苍白的公正:BAAALAAECgYIDwAAAA==.',['若灬']='若灬:BAABLAAFFH8HAAIWAAIIHRIwYwBFAAAWAAIIHRIwYwBFAAAAAA==.',['茆苧']='茆苧:BAABLAAFFH8WAAIBAAYIuBaMFwCbAQABAAYIuBaMFwCbAQAAAA==.',['茉莉']='茉莉乌龙:BAAALAADCgcICAAAAA==.',['莉萝']='莉萝丶艾:BAAALAAECgUIBQAAAA==.',['菲蕾']='菲蕾丝:BAAALAADCgYIBgAAAA==.',['萊莎']='萊莎雷爾丷:BAAALAAECggICAAAAA==.',['萌不']='萌不起来:BAAALAAFFAIIAgAAAA==.',['萌噗']='萌噗噗:BAAALAAECgYIBgAAAA==.',['萨子']='萨子都不满:BAAALAAECgYIBgAAAA==.',['萨岗']='萨岗灬珍珍:BAAALAAFFAIIAgAAAA==.',['萨斯']='萨斯比利:BAABLAAFFH8LAAMCAAMIpxE7RQCZAAACAAMIpxE7RQCZAAADAAII6gaqTQA5AAAAAA==.',['萨迩']='萨迩之怒:BAAALAADCgQIBAAAAA==.',['葛先']='葛先生:BAAALAAECgYICQAAAA==.',['董导']='董导威风:BAAALAAFFAIIAgAAAA==.',['虎式']='虎式坦克丶:BAAALAAECgIIAgAAAA==.',['虚空']='虚空花生:BAACLAAFFH8TAAIBAAUILhGdIQBAAQABAAUILhGdIQBAAQAsAAQKfycABBAACAhGGB4MAOkBABAABwi+Fh4MAOkBAAEACAgzFGNBANEBACAABAi7AUOXAEYAAAAA.',['蚩罗']='蚩罗:BAAALAAECgYIBgAAAA==.',['蛮蛮']='蛮蛮滴:BAAALAAECgQIBAAAAA==.',['装睡']='装睡的丈夫:BAAALAAECgQIBQAAAA==.',['西北']='西北大兴:BAAALAAECgEIAQAAAA==.',['西红']='西红柿:BAAALAAECgYIBgAAAA==.',['见血']='见血就疯狂:BAAALAAECgYICQAAAA==.',['言不']='言不欲:BAAALAAECgYIBgAAAA==.',['言步']='言步欲:BAAALAADCgIIAgAAAA==.',['謝佳']='謝佳:BAAALAADCgQIBAAAAA==.',['记得']='记得吃饭:BAAALAADCgYIBgAAAA==.',['诚挚']='诚挚的欺骗:BAAALAAFFAIIAgAAAA==.',['谁家']='谁家的小奶妹:BAABLAAFFH8JAAIFAAIIOSOwHADJAAAFAAIIOSOwHADJAAAAAA==.',['豆浆']='豆浆烩面:BAABLAAFFH8QAAIPAAIIAhkhEQCTAAAPAAIIAhkhEQCTAAAAAA==.',['豌灬']='豌灬豆:BAAALAAECgYIBgAAAA==.',['豌豆']='豌豆灬:BAAALAAFFAIIAgAAAA==.',['贰伍']='贰伍贰玖:BAABLAAFFH8IAAINAAIIjBVRPwB4AAANAAIIjBVRPwB4AAAAAA==.',['起个']='起个民真难:BAAALAAECgYIBwAAAA==.',['超危']='超危险牛排:BAAALAAECgYIBgAAAA==.',['超级']='超级大猎魔:BAAALAAECgUIBwAAAA==.超级大黑牛:BAAALAAECgYICwAAAA==.',['越烨']='越烨越冷漠:BAAALAAFFAMIAgAAAA==.',['趙山']='趙山河:BAAALAAECgYIBgAAAA==.',['跟屁']='跟屁虫泡芙:BAAALAADCgIIAgAAAA==.',['轻舟']='轻舟已过:BAAALAADCgcIBwAAAA==.',['轻语']='轻语琉璃:BAAALAAECgYIBgAAAA==.',['辉夜']='辉夜球:BAAALAAECgYIBgAAAA==.',['辛巴']='辛巴之王:BAAALAAFFAIIAgAAAA==.',['辛辣']='辛辣天森:BAABLAAFFH8kAAMRAAYItR9fAwC/AQARAAYIthxfAwC/AQAEAAYIqRphKACXAQAAAA==.',['达拉']='达拉崩吧:BAAALAADCgYIBgAAAA==.',['过路']='过路蜻蜓:BAAALAAECgQIBAAAAA==.',['迷糊']='迷糊:BAAALAAECgUIBQAAAA==.',['适丷']='适丷:BAABLAAFFH8HAAICAAYIXCDuCQAwAgACAAYIXCDuCQAwAgAAAA==.',['逆袭']='逆袭的夙命:BAABLAAECn8UAAIJAAcI6hr7YQDPAQAJAAcI6hr7YQDPAQAAAA==.逆袭的箭矢:BAAALAAFFAYIBAAAAA==.',['通天']='通天箓:BAAALAAECgYICQAAAA==.',['遺忘']='遺忘好久:BAABLAAECn8UAAIIAAgIGiIRFAAhAwAIAAgIGiIRFAAhAwAAAA==.',['邓聪']='邓聪的灵爷爷:BAABLAAFFH8GAAIIAAYILxLONwBjAQAIAAYILxLONwBjAQAAAA==.',['那小']='那小子真帅:BAAALAAECgMIAwAAAA==.',['部落']='部落一霸:BAAALAAECgIIAwAAAA==.',['郭芙']='郭芙蓉行啊:BAABLAAFFH8wAAMRAAYITCLZAQADAgARAAYIPyLZAQADAgAEAAYIah4kJQCkAQAAAA==.',['酒鬼']='酒鬼丸子:BAAALAADCgEIAQAAAA==.',['重庆']='重庆夏季:BAABLAAFFH8QAAICAAUIgBIvKgAaAQACAAUIgBIvKgAaAQAAAA==.重庆夏德:BAABLAAFFH8FAAINAAIIGhamPACAAAANAAIIGhamPACAAAAAAA==.重庆夏曰:BAAALAAFFAIIAgAAAA==.重庆夏末:BAABLAAFFH8FAAIRAAIIYhtmHwCLAAARAAIIYhtmHwCLAAAAAA==.重庆夏牧:BAABLAAFFH8IAAIBAAIIlBy8NQCSAAABAAIIlBy8NQCSAAAAAA==.重庆夏骑:BAAALAAFFAIIBAAAAA==.',['重生']='重生军团仙尊:BAABLAAFFH8RAAIRAAYIohhHBAChAQARAAYIohhHBAChAQAAAA==.',['野蛮']='野蛮将军:BAAALAAECgYIDAAAAA==.',['金牌']='金牌小郎君:BAAALAAECgYIDAAAAA==.',['钉锤']='钉锤:BAAALAAFFAIIAgAAAA==.',['钢铁']='钢铁匣:BAAALAAECgYIBgAAAA==.',['钻石']='钻石亮晶晶:BAAALAAECgYIBgAAAA==.',['铁棍']='铁棍:BAAALAADCgUIBQAAAA==.',['长崎']='长崎素世:BAABLAAFFH8YAAMGAAYIJBKFAgB6AQAGAAUI9giFAgB6AQAIAAYIJBL3GABuAQAAAA==.',['长相']='长相拉的仇恨:BAAALAAECgYIDQAAAA==.',['闪电']='闪电虎:BAACLAAFFH8RAAIEAAUIwQ2tLADPAAAEAAUIwQ2tLADPAAAsAAQKfx8AAgQABgi6HUNqAHEBAAQABgi6HUNqAHEBAAAA.',['阳光']='阳光小帅锅:BAAALAAECgYICwAAAA==.',['阴影']='阴影的逆袭:BAAALAAECgYIDQAAAA==.',['阿玛']='阿玛忒辣死:BAABLAAFFH8jAAIEAAYI0SEwEwD7AQAEAAYI0SEwEwD7AQAAAA==.',['阿西']='阿西果果:BAACLAAFFH84AAMMAAgI9SS1AgDRAgAMAAgI9SS1AgDRAgAiAAII+Ar0BwCMAAAsAAQKfxcAAwwABwhaIWQyAIACAAwABwhEIWQyAIACACIAAwj2HBMRAAQBAAAA.',['降临']='降临哀木涕:BAABLAAFFH8QAAIJAAYIdRs8FgCvAQAJAAYIdRs8FgCvAQAAAA==.降临烈仁:BAABLAAECn8iAAIEAAYIkiIxNgDrAQAEAAYIkiIxNgDrAQAAAA==.',['隐秘']='隐秘的角落:BAAALAAECgQICQAAAA==.',['隔壁']='隔壁我姓王:BAAALAAECgIIAgAAAA==.',['雨歇']='雨歇:BAAALAADCggICAAAAA==.',['雲灬']='雲灬烟:BAAALAAECgYIBgAAAA==.雲灬烟丨:BAAALAAECgIIAgAAAA==.',['雲烟']='雲烟:BAAALAAECgYIBwAAAA==.雲烟灬:BAAALAAECgUIBQAAAA==.',['雷神']='雷神的锤子丶:BAAALAAECgMIBQAAAA==.',['雾丷']='雾丷:BAABLAAFFH8MAAICAAYIdR0gDgD/AQACAAYIdR0gDgD/AQAAAA==.',['霜之']='霜之伤痕:BAAALAAECgYICAAAAA==.',['青青']='青青丶子菁:BAAALAAECgYICQAAAA==.',['风之']='风之轻扬:BAAALAAECgIIAgAAAA==.',['风云']='风云无忌:BAAALAAECgYIDAAAAA==.',['风刃']='风刃隐灵:BAAALAADCgQIBAAAAA==.',['风暴']='风暴丶英雄:BAAALAADCgQIBAAAAA==.',['风起']='风起鹤归:BAAALAAFFAYIAgAAAA==.',['飘落']='飘落的云:BAAALAAECgYIBgAAAA==.',['飛雷']='飛雷神:BAAALAAECgYIBwAAAA==.',['飞将']='飞将:BAABLAAFFH8LAAIEAAIIthUYVACTAAAEAAIIthUYVACTAAAAAA==.',['飞虎']='飞虎子:BAAALAAECggICAAAAA==.',['食野']='食野之苹:BAAALAADCggICAAAAA==.',['饕餮']='饕餮儿:BAABLAAECn8WAAIIAAYIPRdJyQCMAQAIAAYIPRdJyQCMAQAAAA==.',['馒頭']='馒頭:BAAALAAECgQIBgAAAA==.',['香芋']='香芋排骨:BAAALAADCgMIAwAAAA==.',['驱魔']='驱魔人段晓姐:BAAALAAECgYICAAAAA==.',['骑咕']='骑咕咕:BAABLAAFFH8RAAIBAAQIGgn4KgDYAAABAAQIGgn4KgDYAAAAAA==.',['魄星']='魄星:BAAALAADCgEIAQAAAA==.',['魅丶']='魅丶色:BAABLAAECn8iAAMeAAcITR/RFABTAgAeAAcIBR/RFABTAgAYAAYIQBgrOABsAQAAAA==.',['魅族']='魅族小生:BAAALAAECgYICwAAAA==.',['魔法']='魔法的逆袭:BAAALAAECgYICwAAAA==.',['鲜血']='鲜血与荣耀:BAAALAADCggIFgAAAA==.鲜血概念:BAAALAAFFAIIAgAAAA==.',['鸭梨']='鸭梨:BAAALAAFFAIIAgAAAA==.',['黄老']='黄老师:BAACLAAFFH9cAAMYAAgIbCONAQDQAgAYAAgIbCONAQDQAgAeAAIIvQ6gGACSAAAsAAQKfyYAAxgACAh5Jr0EAHADABgACAgpJr0EAHADAB4ABgjZIUIfAAcCAAAA.',['龍灵']='龍灵:BAAALAAFFAIIAgAAAA==.',['龙魂']='龙魂兽神:BAAALAAECgYICgAAAA==.龙魂圣光:BAAALAADCgcIBwAAAA==.龙魂狐狸:BAAALAADCgYIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end