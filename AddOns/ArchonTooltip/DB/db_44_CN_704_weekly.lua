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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Retribution','DemonHunter-Vengeance','DeathKnight-Frost','Mage-Arcane','Mage-Frost','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Warlock-Destruction','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','Warlock-Demonology','Priest-Holy','Priest-Shadow','Paladin-Holy','Druid-Balance','Paladin-Protection','Druid-Feral','Warlock-Affliction','Druid-Restoration','Monk-Mistweaver','Warrior-Protection','Shaman-Enhancement','Rogue-Assassination','Mage-Fire','DeathKnight-Blood','Unknown-Unknown','DeathKnight-Unholy',}; local provider = {region='CN',realm='暗影迷宫',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Artemisdao:BAABLAAECn8ZAAMBAAcI/SBtRQBZAgABAAcI/SBtRQBZAgACAAYIexfsSQCNAQAAAA==.',As='Asasins:BAAALAAECgIIAgAAAA==.',Av='Avenger:BAABLAAECn8UAAIDAAYIHA+OzABFAQADAAYIHA+OzABFAQAAAA==.',Ba='Barsarker:BAAALAADCgEIAQAAAA==.',Ca='Callmemt:BAAALAAECgMIAwAAAA==.Carlando:BAAALAADCggICAAAAA==.Casterming:BAAALAAECgYICwAAAA==.',Cw='Cwj:BAABLAAECn8XAAIEAAYIzB/FeQD3AQAEAAYIzB/FeQD3AQAAAA==.',Cy='Cyka:BAACLAAFFH8PAAIFAAIIcBi7DACOAAAFAAIIcBi7DACOAAAsAAQKfxcAAgUACAgzHIARAFICAAUACAgzHIARAFICAAAA.',De='Demonehunter:BAAALAADCgYIBgAAAA==.',Di='Diospada:BAABLAAFFH8FAAIGAAIIyh0nOgC9AAAGAAIIyh0nOgC9AAAAAA==.',Dr='Druiddao:BAAALAADCgYIBgABLAAECgcIGQABAP0gAA==.',Dw='Dwarff:BAAALAAECgUICAAAAA==.',Fe='Felknight:BAABLAAFFH8GAAIEAAYI4AadKwAlAQAEAAYI4AadKwAlAQAAAA==.',Gi='Gio:BAAALAAECgYIBgAAAA==.',Gu='Guyzz:BAACLAAFFH80AAIDAAcIfR5ICgAhAgADAAcIfR5ICgAhAgAsAAQKfzwAAgMACAjrJGkIAFoDAAMACAjrJGkIAFoDAAAA.',Ha='Hayabusa:BAAALAAECgYIBgAAAA==.',He='Hellow:BAAALAAFFAIIAgAAAA==.',La='Laa:BAACLAAFFH8jAAMHAAcIaRynDAAfAgAHAAcIaRynDAAfAgAIAAIICxA8FQBEAAAsAAQKfzEAAwcACAjkJNQFALoCAAcACAjkJNQFALoCAAgABwiuFy85AI8BAAAA.',Li='Lièrén:BAAALAADCgUICAAAAA==.',Ma='Maze:BAAALAAECgYICQAAAA==.',Ne='Neekey:BAAALAAECgYIBgAAAA==.',Ra='Rainside:BAABLAAFFH8IAAIHAAIImg5zVACMAAAHAAIImg5zVACMAAAAAA==.',Sa='Saberr:BAAALAAFFAIIAgAAAA==.Sasioverlxrd:BAAALAAECgYIBgAAAA==.',Se='Seed:BAAALAAFFAIIBAAAAA==.',St='Stella:BAAALAAFFAIIBAAAAA==.',Ta='Tavarisch:BAAALAAECgEIAQAAAA==.',Ty='Tyro:BAACLAAFFH8nAAQJAAcIhBzYBwCsAQAJAAUIQhnYBwCsAQAKAAYIgBziBQCiAQALAAEIZQmVDwBBAAAsAAQKfxkAAwoACAjEHBoKAI4CAAoACAjEHBoKAI4CAAkABwiRHaMdAC4CAAAA.',Vi='Vicky:BAAALAADCgEIAQAAAA==.',Wa='Wanda:BAABLAAFFH8KAAIEAAUIph++GQCJAQAEAAUIph++GQCJAQAAAA==.Wandà:BAABLAAFFH8NAAIGAAUIMRJaQAA5AQAGAAUIMRJaQAA5AQAAAA==.',We='Wenda:BAAALAAFFAIIAgAAAA==.',Yu='Yueguangxiao:BAAALAADCgMIAwAAAA==.',['一个']='一个好人丶:BAAALAAECgYIBgAAAA==.',['一刀']='一刀了:BAAALAAECgQIBAAAAA==.',['一碗']='一碗沧海:BAAALAADCgYIBgAAAA==.',['一稚']='一稚:BAAALAAECgYIEAAAAA==.',['一起']='一起一:BAAALAADCgYIBgAAAA==.一起来放血:BAAALAADCgEIAQAAAA==.',['一锤']='一锤捣似:BAABLAAFFH8GAAIMAAIIQwq2RwCOAAAMAAIIQwq2RwCOAAAAAA==.',['丈城']='丈城:BAAALAAECgEIAQAAAA==.',['不过']='不过尔尔:BAAALAAECgIIAgAAAA==.',['东城']='东城故人:BAAALAAFFAMIAwAAAA==.',['东方']='东方嗨啊嗨啊:BAAALAAECgcICgAAAA==.东方嗯啊嘤噢:BAABLAAECn8bAAINAAgIUBukIQDjAQANAAgIUBukIQDjAQAAAA==.东方碎碎念念:BAAALAAECgUIBQAAAA==.',['两仪']='两仪未娜:BAAALAAFFAIIAgAAAA==.',['两炮']='两炮泯恩仇:BAAALAAFFAIIAgAAAA==.',['丶锦']='丶锦衣卫:BAAALAAFFAQIAwAAAA==.',['为联']='为联盟:BAAALAADCgEIAQAAAA==.',['乂粒']='乂粒蛋:BAABLAAFFH8FAAIDAAUIoARaMwDtAAADAAUIoARaMwDtAAAAAA==.',['久伊']='久伊:BAAALAAECgEIAQAAAA==.',['乌喵']='乌喵王:BAAALAAFFAIIBAAAAA==.',['云之']='云之殇:BAAALAAECgIIAgAAAA==.',['云幕']='云幕山:BAAALAAFFAIIAgAAAA==.',['云暮']='云暮山:BAABLAAECn8wAAMOAAYIPiC1GgDVAQAOAAYIPiC1GgDVAQAPAAMIVAgAKwFaAAAAAA==.',['云朮']='云朮士:BAABLAAFFH8OAAIQAAIIUiT8CQC6AAAQAAIIUiT8CQC6AAAAAA==.',['云烟']='云烟雨:BAAALAAECgYIDAAAAA==.',['亭亭']='亭亭:BAAALAAECgYIBgAAAA==.',['人间']='人间武媚娘:BAAALAAECggICAAAAA==.',['休闲']='休闲猎:BAAALAAECgYIBgAAAA==.',['侽冋']='侽冋:BAAALAAECgYIDgAAAA==.',['俺直']='俺直接一牛牛:BAAALAAECgcIBwAAAA==.',['僵尸']='僵尸屠夫:BAAALAAFFAIIBAAAAA==.',['元素']='元素少女朵莉:BAAALAAECgQIBAAAAA==.',['光铸']='光铸骑:BAAALAADCggICwAAAA==.',['八零']='八零的回忆:BAAALAAECgMIAwAAAA==.',['冬己']='冬己:BAABLAAFFH8GAAMRAAIIiROuKwCUAAARAAIIiROuKwCUAAASAAEItxN8LABIAAABLAAFFAgIEQARAEQaAA==.',['冬森']='冬森爱思妹儿:BAAALAADCggICAAAAA==.',['冰霜']='冰霜惩戒骑:BAABLAAFFH8SAAIGAAUIlwusRwAbAQAGAAUIlwusRwAbAQAAAA==.',['凶导']='凶导的白骑士:BAABLAAFFH8HAAIEAAMI/RFARQCEAAAEAAMI/RFARQCEAAAAAA==.',['分手']='分手锅带走:BAAALAAFFAIIAgAAAA==.',['刘正']='刘正正:BAAALAADCggIDQAAAA==.',['别挡']='别挡我:BAAALAAECggICAAAAA==.',['剪下']='剪下的云呢:BAAALAADCggICgAAAA==.',['劲脆']='劲脆鸡腿堡:BAAALAAECgYIBgAAAA==.',['勿詪']='勿詪:BAAALAAECgUIBQAAAA==.',['千霖']='千霖:BAABLAAECn8bAAIBAAYIfh7KSwCuAQABAAYIfh7KSwCuAQAAAA==.',['半夜']='半夜洗屁屁:BAAALAAFFAIIAgAAAA==.',['卑贱']='卑贱:BAABLAAFFH8OAAINAAUISxTJJwAyAQANAAUISxTJJwAyAQAAAA==.',['卖艺']='卖艺丶毒奶起:BAAALAAECgIIAgAAAA==.',['卡鲁']='卡鲁克特:BAAALAAECgcIBwAAAA==.',['历久']='历久成絮:BAAALAAECgYIBgAAAA==.',['受不']='受不了受不了:BAACLAAFFH8NAAIEAAMIzhDPHgDXAAAEAAMIzhDPHgDXAAAsAAQKfxkAAgQACAgjH60uALcCAAQACAgjH60uALcCAAAA.',['古兒']='古兒丹:BAAALAADCgcICQAAAA==.',['古杖']='古杖技奇人:BAABLAAFFH8JAAMMAAMImyTwLgDCAAAMAAMImyTwLgDCAAAQAAEIECUWIABsAAAAAA==.',['只会']='只会拉链子:BAABLAAFFH8GAAIPAAIItwiQaABSAAAPAAIItwiQaABSAAAAAA==.',['吉你']='吉你一下:BAABLAAFFH8ZAAINAAYInA+KIgBZAQANAAYInA+KIgBZAQAAAA==.',['后跳']='后跳假死:BAAALAAFFAIIAgAAAA==.',['吖树']='吖树:BAAALAADCgcIBwAAAA==.',['君唇']='君唇为谁红:BAAALAAECgIIAgAAAA==.',['吴亦']='吴亦几:BAAALAAECgYICgAAAA==.',['呉朙']='呉朙丨十七:BAABLAAFFH8UAAIRAAgIeB6mAgDQAgARAAgIeB6mAgDQAgAAAA==.呉朙丨十八:BAABLAAFFH8GAAIRAAYInBfRFgCbAQARAAYInBfRFgCbAQAAAA==.呉朙丨十六:BAABLAAFFH8FAAIRAAQISxnKHgBUAQARAAQISxnKHgBUAQAAAA==.',['呐绕']='呐绕斯:BAAALAADCgYIBgAAAA==.',['哀绿']='哀绿绮思:BAAALAAECgUIBQAAAA==.',['哈德']='哈德曼妖怪:BAAALAAECgYIDwAAAA==.',['哥谭']='哥谭明星:BAAALAAECgMIAwAAAA==.',['唯美']='唯美的谎言:BAAALAAECgYICwAAAA==.',['商隐']='商隐小鹿:BAAALAAECgYIBgAAAA==.',['啊来']='啊来客撕獭飒:BAAALAAECgIIAgAAAA==.',['啸魂']='啸魂:BAAALAAECgYIEgAAAA==.',['善恶']='善恶之人:BAAALAAECgIIAgAAAA==.',['喵了']='喵了个咪丶:BAAALAADCgUIBQAAAA==.',['嘟嘟']='嘟嘟奶茶:BAAALAAECgIIAgAAAA==.',['圣丶']='圣丶心:BAAALAAECggIEAAAAA==.',['圣光']='圣光放弃了我:BAAALAADCggICAAAAA==.圣光没放弃我:BAAALAAECgQIBQAAAA==.圣光辛多雷:BAAALAAECgUIBQAAAA==.',['圣玛']='圣玛蒂亚:BAAALAADCgEIAQAAAA==.',['圣约']='圣约翰:BAABLAAFFH8MAAMTAAYI+B2hCAD/AQATAAYI+B2hCAD/AQAEAAYIRx/TDgDOAQAAAA==.',['坠星']='坠星之击:BAAALAADCgYIBgAAAA==.',['埃蒙']='埃蒙:BAABLAAECn8jAAIEAAgILh2dOwCIAgAEAAgILh2dOwCIAgAAAA==.',['塔露']='塔露拉:BAABLAAFFH8IAAIJAAII3R8vFgCbAAAJAAII3R8vFgCbAAABLAAFFAgIEgAUAHkdAA==.',['塞伯']='塞伯鲁斯:BAAALAADCgQIBAAAAA==.',['墨丶']='墨丶琴:BAABLAAFFH8IAAIBAAUInBKMNgC3AAABAAUInBKMNgC3AAAAAA==.',['夜已']='夜已醉丿灬:BAAALAADCggICwAAAA==.',['夜攮']='夜攮子丶:BAAALAAFFAEIAQAAAA==.',['大奎']='大奎思:BAAALAAFFAIIAgAAAA==.',['大概']='大概是离黎:BAABLAAECn8ZAAIVAAcIVwd7TAD8AAAVAAcIVwd7TAD8AAAAAA==.',['大皮']='大皮袄:BAAALAAECgIIAgAAAA==.',['大红']='大红袍:BAAALAAECgUIBQAAAA==.',['大花']='大花生:BAABLAAFFH8NAAIVAAMIGQ0IEgBkAAAVAAMIGQ0IEgBkAAAAAA==.',['大追']='大追猎:BAAALAAECgIIAgAAAA==.',['大风']='大风起:BAAALAAECgYIBgAAAA==.',['大飞']='大飞将军:BAAALAADCgIIAgAAAA==.',['天草']='天草四郎时珍:BAABLAAECn8YAAMIAAYIqhKDIAAcAQAIAAYIqhKDIAAcAQAHAAUINQawWQCaAAAAAA==.',['天龙']='天龙流曐:BAAALAAECggICAAAAA==.',['太阳']='太阳施诗:BAAALAAFFAIIAgAAAA==.',['奇袭']='奇袭:BAAALAADCgUIBQAAAA==.',['奈奈']='奈奈喔:BAAALAAFFAIIAgAAAA==.',['奶不']='奶不动的:BAAALAADCgEIAQAAAA==.',['奶王']='奶王之王:BAABLAAFFH8HAAIRAAIITxwmLgCRAAARAAIITxwmLgCRAAAAAA==.',['奶瓶']='奶瓶大人:BAAALAAECgEIAQAAAA==.',['她是']='她是呆子:BAAALAADCgYIBgAAAA==.',['妖幺']='妖幺:BAAALAAECgMIAwAAAA==.',['妮妮']='妮妮:BAAALAAECgEIAQAAAA==.',['妲己']='妲己:BAAALAAFFAIIBAAAAA==.',['娇弱']='娇弱战:BAAALAAECgYIBgAAAA==.',['娜丶']='娜丶扎:BAAALAADCgYIBgAAAA==.',['娜塔']='娜塔莉丶幻灵:BAABLAAFFH8WAAIRAAUIWA7tIgAqAQARAAUIWA7tIgAqAQAAAA==.',['孤独']='孤独的蜗牛:BAAALAAECgYICgAAAA==.',['宇宙']='宇宙无敌威猛:BAAALAADCggIEAAAAA==.',['小哈']='小哈迪斯:BAAALAADCggICQAAAA==.',['小夜']='小夜骑士:BAAALAAFFAIIAgAAAA==.',['小弥']='小弥:BAAALAADCggICAAAAA==.',['小晓']='小晓小晓然:BAAALAAECgEIAQAAAA==.',['小柯']='小柯基:BAAALAAECgQIBAAAAA==.',['小棉']='小棉裤:BAAALAAECgEIAQAAAA==.',['小汤']='小汤圆:BAABLAAFFH8TAAIRAAYIqhfyEgDCAQARAAYIqhfyEgDCAQAAAA==.',['小泪']='小泪光:BAAALAAECggIBgAAAA==.小泪光呐:BAAALAAECgYIBgAAAA==.',['小狐']='小狐哩:BAAALAAFFAMIAwAAAA==.',['小紫']='小紫薯:BAABLAAECn8fAAMQAAgIzBndEgBKAQAMAAYIQBboOgBcAQAQAAcIWhTdEgBKAQAAAA==.',['小蔫']='小蔫向陽花児:BAAALAAFFAIIAgAAAA==.',['尔萨']='尔萨父亲:BAAALAAECgYIBgAAAA==.',['尛同']='尛同学:BAAALAAECgYIDAAAAA==.',['尼娅']='尼娅米:BAAALAADCggICAAAAA==.',['尽揽']='尽揽臣民心:BAAALAAECgYIBwAAAA==.',['山海']='山海白泽:BAAALAAECgQIBAAAAA==.',['巴林']='巴林一棵树:BAAALAAECgYIEAAAAA==.',['帅东']='帅东丶:BAABLAAFFH8FAAIMAAUIUwDNdAAPAAAMAAUIUwDNdAAPAAAAAA==.',['希尓']='希尓瓦娜丝灬:BAAALAAECgQIBAAAAA==.',['希尔']='希尔瓦娜心:BAABLAAECn8VAAIBAAYIex++fgDhAQABAAYIex++fgDhAQAAAA==.',['幼稚']='幼稚园扛把子:BAAALAAFFAIIAgAAAA==.幼稚园的淑娟:BAACLAAFFH8FAAIBAAMIPwhLdQB0AAABAAMIPwhLdQB0AAAsAAQKfxgAAgEACAjqIPsPAKMCAAEACAjqIPsPAKMCAAAA.',['库路']='库路鹿:BAAALAAECgYICAAAAA==.',['开心']='开心果生牛乳:BAAALAAECgIIAgAAAA==.',['弓长']='弓长丨霸气:BAAALAADCgIIAgAAAA==.',['强壮']='强壮的杜龙坦:BAAALAADCgcIBwAAAA==.',['影歌']='影歌南:BAAALAAECgYIBgAAAA==.',['影照']='影照幽梦:BAAALAADCgYIBgAAAA==.',['德灬']='德灬德:BAABLAAFFH8HAAIWAAUIgA8eBwAVAQAWAAUIgA8eBwAVAQAAAA==.',['心跳']='心跳吗:BAAALAAECggICwAAAA==.',['忏悔']='忏悔妹妹:BAAALAAECgQIBAAAAA==.',['快使']='快使用军体拳:BAAALAAFFAIIBAAAAA==.',['快走']='快走:BAABLAAECn8oAAIBAAgIcCFiHgDhAgABAAgIcCFiHgDhAgAAAA==.',['念原']='念原额:BAACLAAFFH8uAAIMAAUIpiNIIgCSAQAMAAUIpiNIIgCSAQAsAAQKfxcABAwABwgJIhNUAPQBAAwABgjbIBNUAPQBABAAAggKJZhsAMQAABcAAgguFSAqAJoAAAAA.',['性感']='性感彬哥:BAAALAADCgMIAwAAAA==.',['悍丶']='悍丶匪:BAAALAAECgYIDAAAAA==.',['悟詪']='悟詪:BAAALAAECgYICwAAAA==.',['悠莱']='悠莱:BAAALAAFFAIIAgAAAA==.',['愣头']='愣头青:BAAALAAFFAMIBAAAAA==.',['我不']='我不是奶龙:BAAALAADCgEIAQAAAA==.',['我就']='我就是溜得快:BAAALAAFFAIIAgAAAA==.',['我很']='我很愤怒:BAAALAAECgMIAwAAAA==.',['我直']='我直接一刀:BAAALAAFFAIIBAAAAA==.我直接一削凿:BAAALAAECgYIBgAAAA==.',['我真']='我真不想这样:BAAALAAECggIDwAAAA==.',['战至']='战至终章:BAAALAAFFAIIAgAAAA==.',['战阎']='战阎:BAAALAAECgMIAwAAAA==.',['打野']='打野给个蓝:BAABLAAFFH8kAAMHAAYI1SEpFADaAQAHAAYI1SEpFADaAQAIAAII1wcjHwAxAAAAAA==.',['扭转']='扭转万象:BAAALAADCgIIAgAAAA==.',['把把']='把把空车:BAAALAAECgYIDAAAAA==.',['抠脚']='抠脚大汗:BAAALAAECgQIBAAAAA==.',['抽空']='抽空打点输出:BAACLAAFFH8IAAIRAAIIuxZ/JwCbAAARAAIIuxZ/JwCbAAAsAAQKfxYAAhEACAjmIv0HACoDABEACAjmIv0HACoDAAAA.',['挨尺']='挨尺滴板:BAAALAAFFAQIBAAAAA==.',['捡肥']='捡肥皂:BAAALAADCgEIAQAAAA==.',['提起']='提起盼似:BAAALAAECggIAgAAAA==.',['救一']='救一下救一下:BAAALAAECgQIBAAAAA==.',['文化']='文化:BAAALAAECggICAAAAA==.',['斧王']='斧王斩敌无数:BAAALAAECgMIAwAAAA==.',['斩丶']='斩丶魂:BAAALAADCgEIAQAAAA==.',['新伙']='新伙子:BAAALAAECggICAAAAA==.',['旋转']='旋转的战吊:BAAALAAECgYIBgAAAA==.',['无敌']='无敌大可爱:BAAALAADCgcIBwAAAA==.',['无菇']='无菇的人:BAABLAAECn8XAAMYAAcIbRvSRwDDAQAYAAYI/BrSRwDDAQAUAAMIdAeNlAB0AAAAAA==.',['明诺']='明诺:BAAALAADCggICAAAAA==.',['星乐']='星乐思:BAAALAAECgYIBgAAAA==.',['春日']='春日影:BAABLAAFFH8QAAIPAAgIERH0EADdAQAPAAgIERH0EADdAQAAAA==.',['晨訫']='晨訫:BAAALAADCgYIBgAAAA==.',['智法']='智法一:BAABLAAFFH8IAAIHAAgIGxldBwBwAgAHAAgIGxldBwBwAgAAAA==.智法二:BAABLAAFFH8IAAIHAAgIVx3aCwApAgAHAAgIVx3aCwApAgAAAA==.',['月光']='月光女妖:BAAALAAECgYIBgAAAA==.月光小战:BAAALAAECgIIAgAAAA==.月光小旗:BAAALAAECgMIAwAAAA==.月光小牧:BAAALAAECgUIBQAAAA==.',['月夜']='月夜猎神:BAAALAADCgMIAwAAAA==.',['术灬']='术灬释:BAAALAAFFAMIAwAAAA==.',['朱虾']='朱虾仁:BAABLAAFFH8qAAIGAAYIuRs5EwCzAQAGAAYIuRs5EwCzAQAAAA==.',['杭州']='杭州湾宋仲基:BAAALAAECggICAAAAA==.',['杯面']='杯面:BAABLAAFFH8FAAIEAAMI3xKyQACSAAAEAAMI3xKyQACSAAAAAA==.',['极品']='极品嫩豆腐:BAAALAAECgYIDAAAAA==.',['柚子']='柚子与柠檬:BAAALAAECgIIAgAAAA==.柚子与樱桃:BAAALAAECgEIAQAAAA==.柚子与橙子:BAAALAAECgEIAQAAAA==.柚子与甜瓜:BAAALAAFFAIIBAAAAA==.',['柠檬']='柠檬味嘎嘣脆:BAAALAAFFAIIAgAAAA==.',['柳媚']='柳媚:BAAALAAECgMIAwAAAA==.',['桃子']='桃子蘸酱:BAAALAADCgYIBgAAAA==.',['梦与']='梦与彼岸:BAAALAAECggIDwAAAA==.',['梨涡']='梨涡浅笑:BAABLAAFFH8FAAIBAAIIsgrUwQAbAAABAAIIsgrUwQAbAAAAAA==.',['森之']='森之空依:BAAALAAFFAMIAwAAAA==.',['椒丘']='椒丘:BAAALAAECggICAAAAA==.',['橘之']='橘之吻:BAACLAAFFH8HAAMCAAIICAmSGQA4AAACAAIItQiSGQA4AAABAAII6AVnwAAiAAAsAAQKfxoAAgIACAhWDlsRADYBAAIACAhWDlsRADYBAAAA.',['欣赏']='欣赏风景:BAAALAADCggICAAAAA==.',['歌舞']='歌舞生萧:BAAALAAECgMIAwAAAA==.',['歪比']='歪比巴卜:BAAALAAECgYIBgAAAA==.',['死亡']='死亡大牛角:BAAALAAECgYIDwAAAA==.',['毒奶']='毒奶骑士:BAAALAAECgMIAgAAAA==.',['永恒']='永恒之影:BAAALAAECgUIBQAAAA==.',['沐丝']='沐丝仑回:BAAALAAFFAIIBAAAAA==.',['沦陷']='沦陷:BAABLAAFFH8FAAIDAAUIaRV4LAAzAQADAAUIaRV4LAAzAQAAAA==.',['河南']='河南人要自信:BAABLAAECn8pAAIDAAgI8CH2CgCaAgADAAgI8CH2CgCaAgAAAA==.',['泡泡']='泡泡先生:BAAALAAECgYIBgAAAA==.',['洗面']='洗面奶:BAAALAAFFAIIBAAAAA==.',['活蹦']='活蹦乱跳:BAAALAAECgcIDgAAAA==.',['派大']='派大兴:BAAALAAECgYIBgAAAA==.',['浅盈']='浅盈盈:BAAALAAECgMIAwAAAA==.',['淑娟']='淑娟:BAABLAAFFH8KAAIMAAIIehBfWwBEAAAMAAIIehBfWwBEAAAAAA==.淑娟吖:BAABLAAFFH8JAAIRAAQIdRV9IwAjAQARAAQIdRV9IwAjAQAAAA==.淑娟呀:BAAALAAFFAIIAgAAAA==.淑娟呐:BAAALAAFFAIIBAAAAA==.',['满地']='满地插棍:BAABLAAFFH8GAAIPAAYIIhUBaABTAAAPAAYIIhUBaABTAAAAAA==.',['满满']='满满都是土豆:BAAALAADCgIIAgAAAA==.',['滴欸']='滴欸叱仑回:BAAALAAECgUIBQAAAA==.',['漫长']='漫长季节:BAAALAAECggICQAAAA==.',['火鸡']='火鸡味锅芭丶:BAAALAAFFAIIAgAAAA==.',['灯影']='灯影:BAABLAAFFH8GAAINAAIIkwhVWAA+AAANAAIIkwhVWAA+AAAAAA==.',['灵魂']='灵魂之引:BAAALAAECgYIBgAAAA==.',['炁体']='炁体丨源流:BAABLAAFFH8aAAIZAAYIrQsZCwBWAQAZAAYIrQsZCwBWAQAAAA==.',['点点']='点点鼠标:BAAALAADCgEIAQAAAA==.',['烈焰']='烈焰燃心:BAABLAAFFH8PAAINAAYIvxmlFQCvAQANAAYIvxmlFQCvAQAAAA==.',['烟波']='烟波人长安:BAAALAADCgMIAwAAAA==.',['烟锁']='烟锁池塘柳:BAAALAAECgYIBgAAAA==.',['燃丶']='燃丶东漓:BAAALAAECgYIBQAAAA==.燃丶夜刃:BAAALAAECgEIAQAAAA==.',['爱喝']='爱喝红牛:BAAALAAECgYIDAAAAA==.爱喝花茶:BAAALAAECgMIAwAAAA==.',['牛大']='牛大勇:BAAALAAECgYICgAAAA==.',['牛牛']='牛牛搬运工:BAAALAAECgYIBgAAAA==.',['牧丶']='牧丶云:BAAALAADCggICAAAAA==.',['特兰']='特兰克斯丶萨:BAAALAAECgUIBQAAAA==.',['狂野']='狂野宝贝:BAAALAAECggICQAAAA==.',['狄迦']='狄迦:BAAALAAECgYIBgAAAA==.',['狡猾']='狡猾的牛:BAACLAAFFH8OAAMaAAYIOgbaHgCEAAAaAAUI0wbaHgCEAAANAAMIRAIcUABEAAAsAAQKfyoAAxoACAhRDT1EAHEBABoACAg+DT1EAHEBAA0ABgjnCdFrANEAAAAA.狡猾的狗子:BAAALAADCgEIAQAAAA==.',['独灬']='独灬半吨:BAAALAAECgYIEQAAAA==.',['狼族']='狼族变中变:BAAALAAECggIDgAAAA==.狼族叫瘦:BAAALAAECgQIAQAAAA==.狼族天中天:BAAALAAECgYICQAAAA==.狼族忍忠忍:BAAALAADCgEIAQAAAA==.狼族恶中恶:BAAALAAECgUIBQAAAA==.狼族爆中爆:BAAALAADCgcICAAAAA==.狼族猛中猛:BAAALAAECgEIAQAAAA==.狼族琴瘦:BAAALAAECgQIBAAAAA==.狼族虎忠虎:BAAALAAECgQIBAAAAA==.狼族魂中魂:BAAALAAECgUIBgAAAA==.',['猫娘']='猫娘:BAAALAADCgcIBwAAAA==.',['王一']='王一博:BAACLAAFFH8qAAQOAAYIxCXXCAAiAgAOAAYIdyXXCAAiAgAPAAYIfR1WBgDcAQAbAAYImhdbAQDLAQAsAAQKfxcAAw4ACAhYG6sfAKgCAA4ACAhYG6sfAKgCAA8AAwhJIPW4ABEBAAAA.',['由于']='由于智乃:BAAALAAFFAIIAgAAAA==.',['白云']='白云谷李娇娇:BAAALAAECgEIAQAAAA==.',['白刀']='白刀进红刀出:BAABLAAECn8XAAIcAAgI0BN2CwCrAQAcAAgI0BN2CwCrAQAAAA==.',['白日']='白日梦夜里吊:BAABLAAECn8fAAMDAAcIqBiQLACnAQADAAcIqBiQLACnAQAFAAEI0Q91LgAxAAAAAA==.白日梦夜里疯:BAAALAAFFAIIAgAAAA==.白日衣衫尽:BAAALAAECgYICQAAAA==.',['白玫']='白玫瑰夜里香:BAABLAAFFH8JAAIBAAMICg1rewBiAAABAAMICg1rewBiAAAAAA==.',['白百']='白百荷:BAACLAAFFH8KAAIQAAQIdQcRCACjAAAQAAQIdQcRCACjAAAsAAQKfxcAAxAACAhnDFYQAGcBABAACAhnDFYQAGcBAAwAAQiWAwSiABwAAAAA.',['皮佬']='皮佬板:BAABLAAFFH8KAAIYAAIIdBDVOwBkAAAYAAIIdBDVOwBkAAAAAA==.',['皮老']='皮老木反:BAABLAAFFH8IAAIPAAIIywhUYgBeAAAPAAIIywhUYgBeAAAAAA==.皮老版:BAABLAAFFH8MAAIYAAIIgBJiQgBsAAAYAAIIgBJiQgBsAAAAAA==.',['看看']='看看侃栞栞刊:BAACLAAFFH8YAAMIAAUI8iRTAwCxAQAIAAUI8iRTAwCxAQAdAAIIVhjbCQBUAAAsAAQKfxIAAggACAhjJfwJAB0CAAgACAhjJfwJAB0CAAAA.',['瞎蹦']='瞎蹦跶:BAAALAAECgQIBAAAAA==.',['知易']='知易行:BAAALAADCgIIAgAAAA==.',['知道']='知道易行很难:BAAALAAECgYIBgAAAA==.',['短咦']='短咦巴兔:BAACLAAFFH8PAAIeAAIIMxRFDwCNAAAeAAIIMxRFDwCNAAAsAAQKfx0AAh4ACAi1GSoQAE8CAB4ACAi1GSoQAE8CAAAA.',['神必']='神必灵打男:BAAALAAECgIIAgAAAA==.',['神灭']='神灭斩:BAAALAADCgIIAgAAAA==.',['福星']='福星阿拉蕾:BAAALAAECgYICwAAAA==.',['秋分']='秋分落日:BAACLAAFFH8LAAIPAAMI5CKYJAC+AAAPAAMI5CKYJAC+AAAsAAQKfyMAAw8ABwjPIIogAJECAA8ABwjPIIogAJECAA4ABQhUBAmnALwAAAAA.',['秋风']='秋风仇雨:BAAALAAECgEIAQAAAA==.',['科尼']='科尼吉娃:BAAALAAECgYIDAAAAA==.',['窕灬']='窕灬娆:BAAALAAFFAIIAgAAAA==.',['精细']='精细鬼:BAAALAADCggICAAAAA==.',['索尔']='索尔格林:BAABLAAFFH8IAAIEAAIInCHRKwCyAAAEAAIInCHRKwCyAAAAAA==.',['索林']='索林丶橡木盾:BAAALAAECggIEAAAAA==.',['红莲']='红莲三三:BAABLAAECn8XAAMQAAcI1xuHKwDEAQAMAAcIChpZSwARAgAQAAcIZBSHKwDEAQABLAAFFAIIAwAfAAAAAA==.',['终归']='终归永夜:BAAALAAECgQIBAAAAA==.',['给我']='给我圣疗:BAAALAAECgYICwAAAA==.',['绵羊']='绵羊萨守:BAABLAAFFH8MAAIOAAUIKhLfIwAlAQAOAAUIKhLfIwAlAQAAAA==.',['缥缈']='缥缈蕊蕊:BAABLAAECn8VAAIDAAcI5A8jngCPAQADAAcI5A8jngCPAQAAAA==.',['网上']='网上邻居:BAAALAAECgEIAQAAAA==.',['美咸']='美咸之鱼:BAAALAADCgQIBAAAAA==.',['羽人']='羽人非獍:BAAALAADCgQIBAAAAA==.',['老兵']='老兵安帕赫:BAAALAAECgYICAAAAA==.',['肥屁']='肥屁是我:BAAALAAECgYIDQAAAA==.',['胡美']='胡美丽:BAABLAAFFH8GAAMPAAIIEhNTRgB3AAAPAAIIEhNTRgB3AAAOAAIIHwPZOABtAAAAAA==.',['脚滑']='脚滑的骑士:BAAALAAFFAIIBAAAAA==.',['自然']='自然治愈者:BAAALAAECgQIBAAAAA==.',['舞动']='舞动风停:BAAALAADCggICAAAAA==.',['艾克']='艾克塞琳:BAAALAAFFAIIBAAAAA==.',['艾雅']='艾雅玛亚:BAAALAADCgYIBgAAAA==.',['芙柠']='芙柠娜足下犬:BAAALAAECgMIAwAAAA==.',['芙蓉']='芙蓉王:BAAALAAECgUIBQAAAA==.',['芝士']='芝士叨贼:BAAALAAFFAIIAwAAAA==.芝士法斯:BAAALAAECgYIBgABLAAFFAIIAwAfAAAAAA==.芝士莉尔:BAAALAAFFAIIAgAAAA==.',['花雨']='花雨落:BAAALAADCgIIAgAAAA==.',['茗丶']='茗丶芳:BAAALAAFFAIIBAAAAA==.',['荇菜']='荇菜流之:BAABLAAFFH8GAAIPAAIIOAx4VABoAAAPAAIIOAx4VABoAAAAAA==.',['菜菜']='菜菜的骑士:BAAALAAFFAIIBAAAAA==.',['菲兹']='菲兹班锈盾:BAAALAAFFAIIBAAAAA==.',['萧瑟']='萧瑟仙贝:BAAALAAECgcIDQAAAA==.',['萨鹅']='萨鹅:BAAALAADCgcIBwAAAA==.',['虚无']='虚无缥缈:BAAALAAECgYIDQAAAA==.',['蛋刀']='蛋刀恶魔:BAAALAAECgcIBwAAAA==.',['蝴蝶']='蝴蝶漫天飞:BAAALAAFFAIIBAAAAA==.',['西西']='西西骑士:BAAALAAECgYICwAAAA==.',['西门']='西门吹雪:BAAALAAECgEIAQAAAA==.',['贼猛']='贼猛:BAABLAAFFH8HAAIHAAUIOwbbOwDkAAAHAAUIOwbbOwDkAAAAAA==.',['赛博']='赛博企鹅:BAABLAAFFH8XAAIPAAYIVwfXFQAFAQAPAAYIVwfXFQAFAQABLAAFFAcIMwATAEEcAA==.',['走鸡']='走鸡丶:BAABLAAFFH8JAAINAAMIlAzUPQByAAANAAMIlAzUPQByAAAAAA==.',['赵春']='赵春花:BAAALAAECgIIAgAAAA==.',['趴下']='趴下别动:BAAALAAECgYIBgAAAA==.',['这是']='这是一个恶人:BAACLAAFFH8SAAIHAAMI6xkWQQCiAAAHAAMI6xkWQQCiAAAsAAQKfxcAAgcACAjQGk1SAA4CAAcACAjQGk1SAA4CAAAA.',['这瓜']='这瓜多钱一斤:BAACLAAFFH8GAAIYAAIITyYfFADWAAAYAAIITyYfFADWAAAsAAQKfx4AAxgACAj+JdADAE8DABgACAj+JdADAE8DABQAAQh6BaWwAC0AAAAA.',['逢场']='逢场作戏:BAAALAAECgMIAwAAAA==.逢场做戏:BAAALAAECgYIDQAAAA==.',['邪能']='邪能了解一下:BAAALAAECgYIEgAAAA==.',['酒和']='酒和故事:BAAALAADCgcIBwAAAA==.',['酒红']='酒红色的:BAAALAAECgMIAwAAAA==.',['醍醐']='醍醐灌顶:BAAALAAECggICAAAAA==.',['醒酒']='醒酒器:BAAALAAECgEIAQAAAA==.',['采菇']='采菇凉的蘑菇:BAAALAAFFAMIAwAAAA==.',['野原']='野原一心:BAAALAAECgYIBgAAAA==.',['钱有']='钱有才:BAAALAADCgEIAQAAAA==.',['长角']='长角牛:BAAALAAECgEIAQAAAA==.',['阵白']='阵白冶:BAAALAAECgIIAgAAAA==.',['阿修']='阿修罗霸凰拳:BAAALAADCggICAAAAA==.',['阿圣']='阿圣呐:BAAALAAECgUIBQAAAA==.',['阿尔']='阿尔忒:BAAALAAECgMIAwAAAA==.',['阿斗']='阿斗:BAAALAAECgUIBQAAAA==.阿斗一号:BAAALAAECgUIBAAAAA==.阿斗七号:BAAALAADCgIIAgAAAA==.',['阿爾']='阿爾托利亞:BAAALAAFFAIIAgAAAA==.',['阿猎']='阿猎呦:BAABLAAECn8oAAIBAAYISxESpQATAQABAAYISxESpQATAQAAAA==.',['阿祖']='阿祖收手吧:BAAALAAFFAYIAwAAAA==.',['阿莱']='阿莱莎:BAAALAAECgIIAgAAAA==.',['随风']='随风意难平:BAAALAAECgYICgAAAA==.',['零漾']='零漾儿:BAAALAAECgYICQAAAA==.',['雷加']='雷加大地之怒:BAABLAAFFH8WAAIPAAUITAcjNQDRAAAPAAUITAcjNQDRAAAAAA==.',['雾瞳']='雾瞳:BAABLAAFFH8kAAIZAAYI7RZfCACiAQAZAAYI7RZfCACiAQAAAA==.',['霸主']='霸主天下:BAABLAAFFH8GAAIBAAYICwF+wwATAAABAAYICwF+wwATAAAAAA==.',['霹雳']='霹雳小飞侠:BAABLAAFFH8IAAIKAAMI2hDYDADXAAAKAAMI2hDYDADXAAAAAA==.',['青灯']='青灯伴佳人:BAABLAAECn8aAAMFAAYI5RE+PAD3AAADAAYIpg+mxQBQAQAFAAYIeg0+PAD3AAAAAA==.',['静之']='静之杺烔:BAAALAAECgYICQAAAA==.',['飛雪']='飛雪:BAAALAADCgcIDQAAAA==.',['香蕉']='香蕉个卜娜娜:BAABLAAECn8dAAMQAAYIFQkjUwApAQAQAAYInAcjUwApAQAMAAIIMQtviQBfAAAAAA==.',['騩手']='騩手:BAAALAAECgYIDAAAAA==.',['骑士']='骑士骑驴:BAAALAADCgQIBAAAAA==.',['骨杖']='骨杖技奇人:BAAALAAECgMIAwAAAA==.',['鬣丶']='鬣丶心:BAAALAAFFAIIAgABLAAFFAgICAABAOEZAA==.',['鬼多']='鬼多是重:BAAALAAFFAIIAgAAAA==.',['鬼灬']='鬼灬鬼:BAAALAAECgYIBgAAAA==.',['魃魈']='魃魈魑魅魍魉:BAACLAAFFH8TAAMMAAYIBQ1yMQBRAQAMAAYIBQ1yMQBRAQAQAAEIHxJXKgBNAAAsAAQKfxwAAwwACAiFHKMpAJwCAAwACAiFHKMpAJwCABAAAQg6FBGRAEYAAAAA.',['魑灬']='魑灬魅:BAAALAAECgMIAwAAAA==.',['麻大']='麻大哥:BAAALAAFFAIIBAAAAA==.',['黎欣']='黎欣:BAABLAAFFH8FAAIHAAUIshMqMgA5AQAHAAUIshMqMgA5AQAAAA==.',['黎沐']='黎沐影:BAAALAAECggIDwAAAA==.',['黑指']='黑指甲油:BAAALAAECgYIBgAAAA==.',['黑棒']='黑棒:BAAALAAECgIIAQAAAA==.',['黑狗']='黑狗萨满:BAAALAAECgEIAQAAAA==.',['鼑鬡']='鼑鬡:BAAALAAECgYIBgAAAA==.',['鼠标']='鼠标滚技能:BAAALAADCgIIAgAAAA==.',['龘龘']='龘龘龙:BAABLAAFFH8GAAIgAAYINQD3FwAPAAAgAAYINQD3FwAPAAAAAA==.',['龙姬']='龙姬妮娜:BAAALAAFFAIIAgAAAA==.',['龙翔']='龙翔九州:BAAALAAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end