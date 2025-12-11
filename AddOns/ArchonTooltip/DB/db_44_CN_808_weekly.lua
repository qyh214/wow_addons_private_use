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
 local lookup = {'Rogue-Assassination','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Warlock-Affliction','Druid-Feral','Druid-Balance','DeathKnight-Frost','Priest-Holy','Shaman-Restoration','Mage-Fire','Mage-Arcane','Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Fury','Priest-Shadow','Warrior-Protection','Paladin-Holy','Evoker-Preservation','Shaman-Elemental','DemonHunter-Vengeance','Rogue-Subtlety','Monk-Brewmaster',}; local provider = {region='CN',realm='范达尔鹿盔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adnachiel:BAAALAADCggICQAAAA==.',Al='Alhena:BAACLAAFFH8OAAIBAAgIagFkEAD/AAABAAgIagFkEAD/AAAsAAQKfxgAAgEACAh0HaUOALQCAAEACAh0HaUOALQCAAAA.',Cl='Clyne:BAABLAAECn8nAAMCAAgIuSJGEQBzAgADAAgIIx8rMgBzAgACAAYI0CVGEQBzAgAAAA==.',In='Inch:BAAALAADCgIIAgAAAA==.',La='Labubu:BAAALAAFFAIIBAABLAAFFAQICgAEAIEhAA==.Laixi:BAAALAAECgQIBAAAAA==.',Lu='Luckystar:BAAALAADCgMIAwAAAA==.Luoluo:BAAALAAFFAIIAgAAAA==.',Ma='Maomaosea:BAAALAAECgMIAwAAAA==.',Mo='Moteheart:BAABLAAFFH8GAAIFAAYIIACJCwAHAAAFAAYIIACJCwAHAAAAAA==.',St='Strhfg:BAAALAADCgMIAwAAAA==.',Th='Thriller:BAAALAAECgYIBgAAAA==.',Vo='Voyage:BAAALAAECgYIBgAAAA==.',Wa='Walawaka:BAAALAAECgYIDAAAAA==.',Zx='Zxolin:BAAALAAECgIIAgAAAA==.',['一宏']='一宏儿一:BAAALAAFFAIIBAAAAA==.',['一碗']='一碗蛋炒饭:BAAALAAECgYIBgAAAA==.',['丢丢']='丢丢今天没丢:BAAALAAECggIDQAAAA==.丢丢我拿捏了:BAAALAAECgYIBgAAAA==.',['丨吃']='丨吃了就睡丨:BAAALAAECgEIAQAAAA==.',['丨流']='丨流氓丶貔貅:BAABLAAFFH8SAAMGAAIIgxu0CwBeAAAGAAIIgxu0CwBeAAAHAAEIQQEuRAAAAAAAAA==.',['丶幕']='丶幕幕:BAAALAAECggICwAAAA==.',['丶海']='丶海拉之射:BAAALAAECgYIBwAAAA==.丶海拉之骑:BAAALAAFFAIIAgAAAA==.丶海拉之魔:BAAALAAECgYIDAAAAA==.',['丶神']='丶神秀開天:BAABLAAFFH8MAAIIAAIIGSA2PQC3AAAIAAIIGSA2PQC3AAAAAA==.',['九五']='九五二柒:BAAALAAECgYIEgAAAA==.',['也似']='也似风撩你丶:BAAALAAECgYIBgAAAA==.',['了凡']='了凡洋一:BAAALAAECgcICwAAAA==.',['二令']='二令丰色贝戎:BAAALAAECgEIAQAAAA==.',['云吞']='云吞面面:BAAALAAECgYIBgAAAA==.',['五重']='五重唱:BAAALAAECgEIAQAAAA==.',['从小']='从小不学好:BAAALAAECggICAAAAA==.',['代号']='代号四十七:BAAALAAECgIIAgAAAA==.',['伊薇']='伊薇丝猎龙者:BAAALAAECgYIBgAAAA==.',['你是']='你是鬼:BAAALAAECgYICwAAAA==.',['依旧']='依旧念她:BAAALAAECgYIBgAAAA==.',['侢戰']='侢戰:BAAALAAECgYIBwAAAA==.',['倾落']='倾落伽蓝:BAAALAAECgQIBAAAAA==.',['克雷']='克雷奇:BAAALAADCgIIAgAAAA==.',['八小']='八小戒戒:BAAALAAECgEIAQAAAA==.',['冰川']='冰川狂潮:BAAALAADCgUIBQAAAA==.',['凉夏']='凉夏:BAABLAAFFH8LAAIJAAMI9g5uLgC0AAAJAAMI9g5uLgC0AAAAAA==.',['千变']='千变卤蛋蛋:BAAALAAECgYIBgAAAA==.',['占戈']='占戈馬奇:BAABLAAFFH8IAAIEAAMIgxvlKgC0AAAEAAMIgxvlKgC0AAAAAA==.',['双刺']='双刺:BAAALAAECgYIBgAAAA==.',['只有']='只有天知道:BAAALAAECgcIDQAAAA==.',['叮叮']='叮叮铛铛吖:BAAALAAECgEIAQAAAA==.',['可乐']='可乐碧碧:BAAALAAFFAIIBAAAAA==.',['可罗']='可罗米:BAAALAADCgQIBAAAAA==.',['叶砂']='叶砂:BAAALAAECgMIAwAAAA==.',['吃宝']='吃宝石长大:BAABLAAECn8WAAIKAAYIkxzoWgDWAQAKAAYIkxzoWgDWAQAAAA==.',['回头']='回头一刀:BAABLAAECn8jAAQLAAgImxN+CAAhAQAMAAgILBHBZADYAQALAAYIKA9+CAAhAQANAAQI/RT1YQDsAAAAAA==.',['回收']='回收二手女友:BAAALAAECgYIBgAAAA==.',['圆滚']='圆滚滚的程程:BAABLAAFFH8mAAIEAAYIaCBcDgDSAQAEAAYIaCBcDgDSAQAAAA==.',['圣十']='圣十字天神:BAAALAAECgQIBAAAAA==.',['城市']='城市一劣人:BAAALAAFFAYIBAAAAA==.',['大喊']='大喊十:BAAALAAECgYIBgAAAA==.',['大细']='大细超:BAAALAAECgcIBwAAAA==.',['奔跑']='奔跑的死骑:BAAALAAECgMIAwAAAA==.',['奥蕾']='奥蕾莉娅:BAAALAADCgIIAgAAAA==.',['姑奶']='姑奶奶的冬天:BAAALAAECgMIAwAAAA==.姑奶奶的春天:BAABLAAECn8ZAAMOAAcIYhY5rQCZAQAOAAcIYhY5rQCZAQAPAAEIZw3+wgAtAAAAAA==.',['嫣然']='嫣然小萨:BAAALAADCgQIBAAAAA==.嫣然雪落:BAAALAAECgMIAwAAAA==.',['孤寂']='孤寂的精灵:BAAALAAECgYIAwAAAA==.',['孤独']='孤独的柏拉图:BAAALAAECgYIBgAAAA==.',['宏儿']='宏儿的保镖:BAAALAAECgUIBgAAAA==.',['寂静']='寂静的黄昏:BAAALAAECgMIAwAAAA==.',['寒提']='寒提:BAAALAAECgYICwAAAA==.',['小心']='小心大人:BAAALAAFFAIIAgAAAA==.',['小疾']='小疾风:BAAALAAECgYIDAAAAA==.',['小神']='小神之神:BAACLAAFFH8OAAMCAAMIRBPjGACSAAACAAIILhHjGACSAAADAAIIFg0kUgBvAAAsAAQKfx0AAwIACAg9HEgZAC4CAAIABwjrG0gZAC4CAAMABwi8FQteANYBAAAA.',['小记']='小记号:BAABLAAFFH8GAAIIAAYIEhOIMQB2AQAIAAYIEhOIMQB2AQAAAA==.',['小霖']='小霖霖:BAAALAAECgUICQAAAA==.',['屁屁']='屁屁然:BAAALAADCgYIBgABLAAFFAcIDgAQAPoQAA==.',['带刀']='带刀蝴蝶:BAABLAAECn8gAAMPAAgIviPPEADdAgAPAAgIKiLPEADdAgAOAAgIWiIMZAATAgAAAA==.',['张翠']='张翠翠:BAACLAAFFH8lAAMJAAUI1CO8CwAPAgAJAAUI1CO8CwAPAgARAAII0gPvJwBvAAAsAAQKfxYAAgkABwinIcQaAJkCAAkABwinIcQaAJkCAAAA.',['彩虹']='彩虹天国:BAAALAADCgIIAgAAAA==.',['微风']='微风:BAAALAAECgUIAwAAAA==.',['德哥']='德哥:BAAALAAECgQIBAAAAA==.',['怒砧']='怒砧:BAAALAADCgQIBAAAAA==.',['恶魔']='恶魔情殇:BAAALAAFFAQIAgAAAA==.恶魔棍棍:BAAALAAECggICAAAAA==.',['慈母']='慈母守中线:BAAALAADCggICAAAAA==.',['慵懒']='慵懒小暖:BAAALAAECgYIDAAAAA==.',['所遇']='所遇皆暖:BAAALAADCggICAAAAA==.',['执笔']='执笔丶绘流年:BAAALAAECgYICwAAAA==.',['拉图']='拉图修斯:BAAALAAECgYIBgAAAA==.',['掏出']='掏出来比一比:BAAALAAECgcICAAAAA==.',['断长']='断长风:BAAALAAECgYIBgAAAA==.',['无情']='无情绞肉机:BAAALAAECgMIAwAAAA==.',['无敌']='无敌幸运星:BAABLAAFFH8GAAISAAIINQcNNQAtAAASAAIINQcNNQAtAAAAAA==.',['时间']='时间差不多喽:BAAALAADCgQIBAAAAA==.',['昊天']='昊天锤:BAAALAAECgQIBgAAAA==.',['明汐']='明汐晨星:BAAALAADCgQIBAAAAA==.',['晨汐']='晨汐:BAAALAADCgYIBgAAAA==.',['晨霜']='晨霜晚露:BAAALAAECgMIAwAAAA==.',['暖雨']='暖雨晴风:BAAALAAECgEIAQAAAA==.',['暴风']='暴风海:BAAALAADCgMIAwAAAA==.',['最後']='最後的抉擇:BAAALAAECgMIAwAAAA==.最後的薩滿:BAAALAAFFAIIAgAAAA==.',['月光']='月光下的喵:BAAALAADCggIDgAAAA==.',['月夜']='月夜舞霓裳:BAAALAAECggIDgAAAA==.',['有有']='有有守护神:BAAALAAFFAIIAgAAAA==.',['有期']='有期三十天:BAAALAAECgYIBgAAAA==.',['望璧']='望璧:BAAALAAECgEIAQAAAA==.',['末日']='末日的回响:BAAALAAECgUIBQAAAA==.',['朱晓']='朱晓雨:BAAALAADCgIIAgAAAA==.',['极冰']='极冰焱焱:BAACLAAFFH8mAAIMAAYIAxmvJAAFAQAMAAYIAxmvJAAFAQAsAAQKfyEAAwwACAiCINkcAN4CAAwACAiCINkcAN4CAA0AAghVHBd9AHUAAAAA.',['枫之']='枫之童话:BAAALAADCgYICwAAAA==.',['栗山']='栗山未来:BAABLAAECn8WAAIIAAgI8BsITwBbAgAIAAgI8BsITwBbAgAAAA==.',['桂圆']='桂圆:BAAALAAECgMIAwAAAA==.',['梅狸']='梅狸猫:BAAALAAECgYIBgAAAA==.',['歌剧']='歌剧魅影:BAAALAAECgYIDAAAAA==.',['武器']='武器战狂暴:BAAALAAECgEIAQAAAA==.',['死灵']='死灵战神:BAAALAAECgYICAAAAA==.',['沧海']='沧海牧蛙:BAABLAAECn8UAAIEAAYIISXYXAAyAgAEAAYIISXYXAAyAgAAAA==.',['泰蓝']='泰蓝德语风:BAAALAAECgMIAwAAAA==.',['洅不']='洅不斬:BAAALAAECgYIEgAAAA==.',['流星']='流星逐月:BAAALAADCgIIAgAAAA==.',['浮元']='浮元兔兔:BAAALAAFFAIIAgAAAA==.',['浮光']='浮光与掠影:BAAALAAECgYIBgAAAA==.',['淡离']='淡离:BAAALAAECgIIAgAAAA==.',['深田']='深田永美:BAAALAADCgEIAQAAAA==.',['渐行']='渐行如风远:BAAALAADCgQIBAAAAA==.',['湮灭']='湮灭无术:BAAALAAECgYICgAAAA==.湮灭灵魂:BAAALAAECgYIDgAAAA==.',['火工']='火工头陀:BAAALAAECgQIBAAAAA==.',['火猫']='火猫的怨念:BAAALAAECgMIBAAAAA==.',['灭世']='灭世者之影:BAACLAAFFH8VAAIBAAUI8RcTDQD/AAABAAUI8RcTDQD/AAAsAAQKfyIAAgEABwgUHeUZAEUCAAEABwgUHeUZAEUCAAAA.',['烧钱']='烧钱一号:BAAALAAFFAIIBAAAAA==.',['牛老']='牛老道:BAAALAAECgYICAAAAA==.',['狼战']='狼战八荒:BAAALAAECgYIBwAAAA==.',['猎祖']='猎祖猎宗:BAAALAAFFAIIAgAAAA==.',['猎薇']='猎薇:BAAALAAECgUIBQAAAA==.',['猛踹']='猛踹那条断腿:BAAALAAECgYIBgAAAA==.',['猴毛']='猴毛毛:BAAALAAFFAIIBAAAAA==.',['瓦塔']='瓦塔诺森部:BAAALAAECgYIBgAAAA==.',['电电']='电电萨:BAAALAAECgQIBAAAAA==.',['笑鱼']='笑鱼:BAAALAADCggICAAAAA==.',['第二']='第二梦:BAAALAAECgcIBwAAAA==.',['精糊']='精糊糊:BAABLAAFFH8KAAIMAAgIwRLxDAAdAgAMAAgIwRLxDAAdAgAAAA==.',['糊精']='糊精精:BAABLAAFFH8OAAITAAgIPxGOBwAVAgATAAgIPxGOBwAVAgAAAA==.',['糊糊']='糊糊精精:BAABLAAFFH8IAAMJAAgIBxRrFgCgAQAJAAYIaxVrFgCgAQARAAII6Q70HQCcAAAAAA==.',['繁花']='繁花灬挽歌:BAAALAAECgMIBQAAAA==.繁花落尽:BAAALAAECgUIBQAAAA==.',['绽放']='绽放的噬灵:BAAALAAECgYIBgAAAA==.',['美树']='美树:BAABLAAFFH8MAAIUAAUIvg2DEAAlAQAUAAUIvg2DEAAlAQAAAA==.',['老牛']='老牛吃嫩草:BAAALAAECgcIBwAAAA==.',['致命']='致命華彩:BAAALAAECgUIBQAAAA==.',['艾许']='艾许斯灵叶:BAAALAADCgYIBgAAAA==.',['花仙']='花仙子粉丝丶:BAAALAADCgIIAgAAAA==.',['苹果']='苹果粘豆包:BAAALAADCggICAAAAA==.',['草莓']='草莓粘豆包:BAAALAAECgYICQAAAA==.',['莱恩']='莱恩:BAAALAAECgEIAQAAAA==.',['萌兔']='萌兔子:BAAALAAECgUICAAAAA==.',['萌萌']='萌萌的艾佳:BAACLAAFFH8kAAIKAAYIRxCuIABYAQAKAAYIRxCuIABYAQAsAAQKfyIAAwoACAhKFsldAM4BAAoACAhKFsldAM4BABUABwjLCNyJACYBAAAA.',['萧雨']='萧雨亦馨:BAAALAADCggIBwAAAA==.',['萬兽']='萬兽:BAAALAAECgYIBgAAAA==.',['蒜鸟']='蒜鸟蒜鸟:BAAALAAECggIAQAAAA==.',['蒲荟']='蒲荟:BAAALAAECggIBQAAAA==.',['螳螂']='螳螂:BAABLAAFFH8IAAIWAAIIpgNKGwBEAAAWAAIIpgNKGwBEAAAAAA==.',['记号']='记号的宝宝:BAAALAAECgIIAgAAAA==.',['许个']='许个愿吧:BAAALAADCgUIBQAAAA==.',['诺达']='诺达希尔的风:BAAALAADCgEIAQAAAA==.',['贫道']='贫道不知道:BAAALAAFFAIIAgAAAA==.',['路人']='路人丶殇:BAABLAAFFH8FAAIMAAIIbQ1eTwCRAAAMAAIIbQ1eTwCRAAAAAA==.',['达丽']='达丽安娜:BAAALAAECgYIBwAAAA==.',['这个']='这个名字六臂:BAAALAAECgYICwAAAA==.这个名字流弊:BAABLAAECn8UAAIWAAYIihLsMQAzAQAWAAYIihLsMQAzAQAAAA==.',['迪卡']='迪卡戮咭:BAAALAADCgIIAgAAAA==.',['迷惘']='迷惘鬼余生:BAAALAAECgYICAAAAA==.',['部落']='部落天敵:BAAALAAECgQIBAAAAA==.',['醉丨']='醉丨猎手:BAAALAAECgMIAwAAAA==.',['长空']='长空烈阳:BAAALAADCgEIAQAAAA==.长空骄阳:BAAALAADCgYIBgAAAA==.',['闪电']='闪电勾魂使:BAAALAADCggICAAAAA==.',['阿普']='阿普:BAAALAAECgIIAgAAAA==.',['阿诗']='阿诗娅:BAABLAAFFH8gAAMBAAUIxCHRCACOAQABAAUIWB7RCACOAQAXAAEIeiZfGQAAAAAAAA==.',['降龙']='降龙丶伏虎:BAABLAAFFH8JAAIYAAYI4gxVEQA3AQAYAAYI4gxVEQA3AQAAAA==.',['风来']='风来听风:BAAALAADCgQIBAAAAA==.',['风轻']='风轻花落:BAAALAAECgYICQAAAA==.',['马小']='马小花:BAAALAAECgYIBgAAAA==.',['鹿角']='鹿角牛:BAAALAAECgYIDAAAAA==.',['黑崎']='黑崎一护:BAAALAAECgEIAQAAAA==.',['黑海']='黑海岸猎鹰:BAAALAADCgYIBgAAAA==.',['黑漆']='黑漆漆是辆猫:BAAALAAECgMIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end