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
 local lookup = {'Priest-Shadow','DeathKnight-Frost','Hunter-BeastMastery','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Mage-Arcane','Paladin-Retribution','Priest-Holy','Warlock-Demonology','Warlock-Destruction','Mage-Frost','DemonHunter-Havoc','Monk-Mistweaver','Druid-Restoration','Paladin-Holy','Unknown-Unknown','Druid-Guardian','Warrior-Fury','Warrior-Protection','Evoker-Preservation','Monk-Windwalker','Paladin-Protection','Warrior-Arms','Druid-Balance','Hunter-Marksmanship','Shaman-Enhancement','Druid-Feral',}; local provider = {region='CN',realm='火羽山',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Ai:BAAALAAFFAIIAgAAAA==.',Cm='Cmyk:BAAALAAECggICAAAAA==.',Ep='Epidemic:BAAALAAECgMIAwAAAA==.',Fl='Flxsdiy:BAAALAAFFAIIBAAAAA==.',Je='Jeanerent:BAABLAAFFH8GAAIBAAIILAroIgCGAAABAAIILAroIgCGAAAAAA==.',Ke='Keany:BAAALAAECgYIBgAAAA==.',Kn='Knave:BAAALAAECgcIDgAAAA==.',Ku='Kumo:BAABLAAFFH8SAAICAAgIrCKCBgCTAgACAAgIrCKCBgCTAgAAAA==.',Le='Lee:BAAALAADCgYIBgAAAA==.',Lo='Love:BAABLAAFFH8HAAIDAAIIBAg7uAAxAAADAAIIBAg7uAAxAAAAAA==.',Lu='Luck:BAACLAAFFH8KAAMEAAMIgwv+SQCJAAAEAAMIgwv+SQCJAAAFAAEIWgNyUQAxAAAsAAQKfxUAAwUABgibDQF5AFUBAAUABgibDQF5AFUBAAQABgjoEEJgAOQAAAAA.',Ni='Nino:BAACLAAFFH8QAAMGAAIIMhfiDwCaAAAGAAIIEhbiDwCaAAACAAIIMxYcfwBGAAAsAAQKfxgAAwYACAiuHFYLAJ0CAAYACAjOGlYLAJ0CAAIABwjWGQsxALIBAAAA.',Pl='Playergyppov:BAAALAAECgIIAgAAAA==.',Su='Superrailgun:BAACLAAFFH8GAAIEAAIIUiVUNgDLAAAEAAIIUiVUNgDLAAAsAAQKfxUAAgQABgiNHKwrALgBAAQABgiNHKwrALgBAAAA.',Te='Teoyceasr:BAAALAADCgQIBAAAAA==.',Tm='Tmto:BAAALAAFFAMIBAAAAA==.',Tu='Tuzki:BAAALAAECgYIBgAAAA==.',['一柱']='一柱擎天:BAAALAAECgEIAQAAAA==.',['一箭']='一箭倾心:BAABLAAFFH8MAAIDAAYIOg8yEQChAQADAAYIOg8yEQChAQAAAA==.',['一衣']='一衣带水:BAAALAAECgYIBgAAAA==.',['七鬼']='七鬼五二三:BAAALAAECgIIAwAAAA==.',['三戒']='三戒圣:BAAALAAECgYIEgAAAA==.',['不要']='不要发抖:BAAALAADCggICAAAAA==.',['丶天']='丶天黑再下手:BAAALAAECgIIAwAAAA==.',['丶文']='丶文老师:BAABLAAFFH8KAAIEAAIInBk5NQCWAAAEAAIInBk5NQCWAAAAAA==.',['为了']='为了圣光:BAAALAAECgUIBQAAAA==.',['乎乎']='乎乎:BAAALAAECgYIBgAAAA==.',['乖巧']='乖巧的糖喵喵:BAAALAAFFAIIAgAAAA==.',['云泽']='云泽哥:BAABLAAFFH8FAAMEAAUIdBlgFgAAAQAEAAQI3hdgFgAAAQAFAAEIBwKLPQBHAAAAAA==.',['云端']='云端的灯塔:BAABLAAFFH8ZAAIHAAQIFAazPwCxAAAHAAQIFAazPwCxAAAAAA==.',['五五']='五五开:BAAALAAFFAIIBAAAAA==.',['仄仄']='仄仄:BAABLAAFFH8HAAIIAAIIkBRmTgCTAAAIAAIIkBRmTgCTAAAAAA==.',['你是']='你是我的碗:BAACLAAFFH8GAAIDAAIIygXEpQA8AAADAAIIygXEpQA8AAAsAAQKfxUAAgMACAixDp1yAF8BAAMACAixDp1yAF8BAAAA.',['倾城']='倾城斩月:BAAALAADCgYIDAAAAA==.',['像个']='像个人:BAAALAAECgEIAQAAAA==.',['元気']='元気満満:BAAALAAECgYIBgAAAA==.',['克莱']='克莱恩:BAAALAAECgYIDAAAAA==.',['克里']='克里斯蒂特:BAAALAAFFAIIAwAAAA==.',['兔子']='兔子发言人:BAAALAADCgIIAgAAAA==.',['再次']='再次死亡:BAAALAAECggICAAAAA==.',['冯宝']='冯宝宝:BAAALAAFFAYIAgAAAA==.',['冰冰']='冰冰凉红茶:BAABLAAECn8XAAIJAAgIsxOfOAD4AQAJAAgIsxOfOAD4AQAAAA==.',['冰凝']='冰凝瑞雪:BAACLAAFFH8MAAIKAAMI7RF5CQCLAAAKAAMI7RF5CQCLAAAsAAQKfxsAAwoACAitJOQOAIsCAAoABghlJeQOAIsCAAsABQhLIKNhAMwBAAAA.',['刃破']='刃破星河:BAAALAAECgEIAQAAAA==.',['创世']='创世女神:BAAALAAECgYICwAAAA==.',['初始']='初始丶绮罗香:BAAALAAECggIDgAAAA==.',['刮三']='刮三脸:BAAALAAECgMIAwAAAA==.',['功夫']='功夫女孩:BAAALAAFFAIIBAAAAA==.功夫法神:BAACLAAFFH8JAAIMAAUILRZfCAARAQAMAAUILRZfCAARAQAsAAQKfxQAAwcACAjwGjhWAAECAAcACAgEGThWAAECAAwABAjDGlJTACgBAAAA.',['勇敢']='勇敢哞哞:BAAALAADCgEIAQAAAA==.',['勺叮']='勺叮叮:BAAALAAECgQIBQAAAA==.',['千里']='千里兵戈血染:BAAALAAECggIDwAAAA==.',['半岁']='半岁:BAAALAAECgYIBgAAAA==.',['半糖']='半糖烤奶:BAAALAADCgcIBwAAAA==.',['另一']='另一粒丹:BAABLAAFFH8GAAINAAMIlg2xQACLAAANAAMIlg2xQACLAAAAAA==.',['只会']='只会玩蓝猫:BAAALAAFFAIIBAAAAA==.',['可爱']='可爱的小钱钱:BAABLAAFFH8HAAIEAAMIbhA2IADMAAAEAAMIbhA2IADMAAAAAA==.',['叹息']='叹息风中:BAAALAAFFAIIAgAAAA==.',['吕布']='吕布:BAABLAAFFH8JAAMEAAMILgQGWQBpAAAEAAMILgQGWQBpAAAFAAIIZg1LRABEAAAAAA==.',['吹泡']='吹泡泡丶:BAABLAAFFH8JAAIEAAIIlw4XZgBVAAAEAAIIlw4XZgBVAAAAAA==.',['周瑜']='周瑜:BAABLAAFFH8IAAIOAAIIDgiiFwBgAAAOAAIIDgiiFwBgAAAAAA==.',['呼你']='呼你熊脸:BAAALAAECgQIBAAAAA==.',['哈斯']='哈斯沃德:BAABLAAFFH8LAAIIAAII1hSIYQBFAAAIAAII1hSIYQBFAAAAAA==.',['喵丶']='喵丶喵丶喵呜:BAABLAAFFH8KAAIPAAIIXhLhQABwAAAPAAIIXhLhQABwAAAAAA==.',['喵喵']='喵喵爱你哟:BAAALAADCgIIAgAAAA==.',['嘿咻']='嘿咻咻灬:BAABLAAFFH8SAAMQAAgIQBKOEAB9AQAQAAYIahGOEAB9AQAIAAIIzg59PgCZAAAAAA==.',['回忆']='回忆丶终难忘:BAAALAAECgYIDQAAAA==.',['国士']='国士无双:BAAALAAECgYIDgAAAA==.',['圣光']='圣光忽悠这你:BAABLAAFFH8FAAIIAAIIMAcjeQA4AAAIAAIIMAcjeQA4AAAAAA==.',['圣骑']='圣骑:BAABLAAFFH8GAAIIAAYIWRszFwCYAQAIAAYIWRszFwCYAQABLAAFFAgIAgARAAAAAA==.',['在哪']='在哪躺在哪睡:BAABLAAFFH8WAAICAAYILxIgMQB2AQACAAYILxIgMQB2AQAAAA==.',['墓中']='墓中无人丶:BAAALAAECgMIAwAAAA==.',['夏末']='夏末记忆丶:BAAALAAECgIIAgAAAA==.',['夜侠']='夜侠:BAAALAAECgEIAQAAAA==.',['夜影']='夜影柳柳:BAABLAAFFH8xAAMSAAUIbxwVAwBBAQASAAUIbxwVAwBBAQAPAAIIiATtRQBYAAAAAA==.',['夜邪']='夜邪:BAAALAAECgYIBQAAAA==.',['大绿']='大绿豆胆:BAACLAAFFH8oAAICAAYIxxxuIgCqAQACAAYIxxxuIgCqAQAsAAQKfzgAAgIACAhMJP8EAOICAAIACAhMJP8EAOICAAAA.',['大肥']='大肥鱼:BAAALAAECggIDgAAAA==.',['大脚']='大脚德:BAAALAAECgMIBgAAAA==.',['大跳']='大跳崴到脚:BAABLAAFFH8LAAITAAQIgAp0MADIAAATAAQIgAp0MADIAAAAAA==.',['大锤']='大锤手脱臼:BAAALAAECgEIAQAAAA==.',['天下']='天下第一战:BAABLAAFFH8eAAMTAAYIVxkNFgCsAQATAAYIJRkNFgCsAQAUAAIIyBpwLAA4AAAAAA==.',['天煞']='天煞血诀:BAACLAAFFH8RAAMCAAQIgB3EGgBQAQACAAQIgB3EGgBQAQAGAAII0BJxDQCqAAAsAAQKfyQAAwIACAhIIz0pAMwCAAIACAgAIT0pAMwCAAYAAwiFG3U+AOcAAAAA.',['奶牛']='奶牛奶奶:BAABLAAECn8XAAMEAAcIShBfWAD+AAAEAAYItw5fWAD+AAAFAAUIbwk7ogDQAAAAAA==.',['好姐']='好姐妹:BAABLAAFFH8JAAINAAIIixueTgBKAAANAAIIixueTgBKAAAAAA==.',['好时']='好时冰淇淋:BAAALAAFFAIIBAAAAA==.好时牛肉卷:BAABLAAFFH8GAAIVAAIIHQ2eGgBqAAAVAAIIHQ2eGgBqAAAAAA==.好时甜甜圈:BAAALAAFFAIIAwAAAA==.',['妈咪']='妈咪爱:BAAALAAECgQIBAAAAA==.',['姜青']='姜青娥:BAAALAAECgYIBgAAAA==.',['姬丝']='姬丝秀忒:BAABLAAFFH8KAAILAAIIhwwARQCSAAALAAIIhwwARQCSAAAAAA==.',['富贵']='富贵十七号:BAABLAAFFH8YAAMEAAYIiw69LwDwAAAEAAUIlw29LwDwAAAFAAIIjQZINwB/AAAAAA==.富贵十三号:BAABLAAFFH8aAAMEAAYIFBLqLAACAQAEAAUI6g/qLAACAQAFAAEIhQ7dQABJAAAAAA==.富贵十五号:BAABLAAFFH8aAAMEAAYItxJ2KwALAQAEAAUIVxF2KwALAQAFAAEIqgkrRQBDAAAAAA==.富贵十六号:BAABLAAFFH8kAAMEAAYIIBWiKQAYAQAEAAUIIxKiKQAYAQAFAAUICQk/KQD5AAAAAA==.富贵十四号:BAABLAAFFH8gAAMFAAYIuAY5JAAjAQAFAAYIuAY5JAAjAQAEAAUItg5YLAAFAQAAAA==.',['寥若']='寥若晨星:BAABLAAFFH8HAAIIAAIIdBcbPQCgAAAIAAIIdBcbPQCgAAABLAAFFAIIDAAMAEMkAA==.寥若晨汐:BAABLAAFFH8MAAIMAAIIQyT8BgDUAAAMAAIIQyT8BgDUAAAAAA==.',['寸板']='寸板:BAAALAAECgcIEAAAAA==.',['对焦']='对焦:BAAALAADCgUIBQAAAA==.',['封村']='封村阳:BAAALAADCgYIBQAAAA==.',['射个']='射个蛋:BAAALAAECgEIAQAAAA==.',['将军']='将军:BAAALAAFFAIIAgAAAA==.',['小小']='小小丶小猎:BAAALAAFFAIIAgAAAA==.小小阿杜灬:BAAALAAFFAIIBAAAAA==.小小麦多:BAAALAAECgYIBgAAAA==.',['小恶']='小恶魔提里昂:BAABLAAFFH8FAAIJAAMIRQh5MwCaAAAJAAMIRQh5MwCaAAAAAA==.',['小正']='小正的宝宝:BAAALAADCgUIBQAAAA==.',['小水']='小水仙到处跑:BAAALAADCgQIBAAAAA==.',['小红']='小红手:BAAALAADCgQIBAAAAA==.',['小肥']='小肥星灬:BAABLAAFFH8FAAIDAAUIUBO6SAAoAQADAAUIUBO6SAAoAQAAAA==.',['小锶']='小锶:BAABLAAECn8YAAIDAAYIWhlscABjAQADAAYIWhlscABjAQAAAA==.',['小镭']='小镭:BAAALAAFFAIIAgAAAA==.',['岁月']='岁月堕落圣光:BAABLAAFFH8JAAIIAAYIOxZoGQCLAQAIAAYIOxZoGQCLAQAAAA==.岁月烬灭狂歌:BAABLAAFFH8NAAIMAAYIQxwBAwC8AQAMAAYIQxwBAwC8AQAAAA==.',['巴适']='巴适的板:BAACLAAFFH8OAAINAAIIXx+iLgCsAAANAAIIXx+iLgCsAAAsAAQKfyIAAg0ABwioItE0AIkCAA0ABwioItE0AIkCAAAA.',['帅锅']='帅锅丶求合体:BAABLAAFFH8JAAIQAAMILRFIHgCwAAAQAAMILRFIHgCwAAAAAA==.',['帕琪']='帕琪维克:BAAALAAFFAIIAgAAAA==.',['干掉']='干掉圣光:BAAALAADCggICAAAAA==.',['幻影']='幻影狼洛根:BAAALAAECgEIAQAAAA==.',['幽悠']='幽悠:BAABLAAFFH8FAAIMAAIIhApnHgAzAAAMAAIIhApnHgAzAAAAAA==.',['幽霜']='幽霜:BAAALAAFFAIIBAAAAA==.',['开门']='开门小能手:BAAALAAFFAIIBAAAAA==.',['弓弯']='弓弯羽落:BAAALAAECgEIAQAAAA==.',['张利']='张利霞:BAAALAAFFAIIAgAAAA==.',['弯西']='弯西的白月光:BAAALAAECgMIAwAAAA==.',['徐电']='徐电池:BAAALAAECgUIBgAAAA==.徐电电:BAAALAAFFAEIAQAAAA==.',['御前']='御前侍卫:BAABLAAECn8kAAMOAAcIDAz2GgAAAQAOAAcIDAz2GgAAAQAWAAII0wp3XwBrAAAAAA==.',['忧伤']='忧伤不会的:BAAALAAECggIBgAAAA==.',['快乐']='快乐的蝽鸽:BAAALAAECggICAAAAA==.',['怒斩']='怒斩高富帅:BAABLAAFFH8FAAIOAAUI9AD0EACoAAAOAAUI9AD0EACoAAAAAA==.',['总冠']='总冠军:BAABLAAFFH8IAAMFAAIIyRd5LgCMAAAFAAIIyRd5LgCMAAAEAAIICQUXZgBbAAAAAA==.',['悠幽']='悠幽:BAACLAAFFH8FAAIPAAIIkhcTOACKAAAPAAIIkhcTOACKAAAsAAQKfxcAAg8ABgiIHORCANUBAA8ABgiIHORCANUBAAAA.',['我乀']='我乀千与千寻:BAAALAAECgUIBQAAAA==.',['我有']='我有两只猫:BAABLAAFFH8IAAIEAAIIwRkpaQBRAAAEAAIIwRkpaQBRAAAAAA==.',['我的']='我的哔哟哔哟:BAAALAAECgYIBgAAAA==.',['打死']='打死不练牛:BAAALAADCgUICgAAAA==.',['招财']='招财的猫:BAAALAAECgYICQAAAA==.',['断灬']='断灬牙:BAAALAAECgIIAgAAAA==.',['无敌']='无敌大魔王:BAAALAADCgcIBwAAAA==.',['无雨']='无雨恋风:BAAALAAECgYIBgAAAA==.',['星辰']='星辰聚:BAAALAAFFAIIBAAAAA==.',['是糖']='是糖乀喵喵哈:BAAALAAECgYIBgAAAA==.是糖喵喵啊:BAAALAAECgQIBAAAAA==.',['暴风']='暴风老人物:BAACLAAFFH8NAAIXAAMIiATwFQBKAAAXAAMIiATwFQBKAAAsAAQKfxoAAhcABwi/DRUfABgBABcABwi/DRUfABgBAAAA.',['有洁']='有洁僻的细菌:BAAALAADCgYIBgAAAA==.',['李太']='李太医:BAABLAAFFH8MAAIJAAIIXh4UMACrAAAJAAIIXh4UMACrAAAAAA==.',['李沐']='李沐恩:BAABLAAFFH8FAAMOAAIIgRT7EwB+AAAOAAIIgRT7EwB+AAAWAAIITg7QFQBHAAAAAA==.',['李鎏']='李鎏昕:BAAALAAFFAIIAgAAAA==.',['核武']='核武狐:BAAALAAFFAIIAgAAAA==.',['格瑞']='格瑞恩:BAAALAADCgMIAwAAAA==.',['桑妮']='桑妮:BAABLAAFFH8LAAMIAAMIOB4dPQCeAAAIAAMIOB4dPQCeAAAQAAIIIBa+IgCMAAAAAA==.',['梦寐']='梦寐之眼:BAAALAAECgYICQAAAA==.',['楼兰']='楼兰时光:BAAALAAECgYIBgAAAA==.',['此奶']='此奶不详之罩:BAABLAAFFH8KAAIJAAMIkQVhNACVAAAJAAMIkQVhNACVAAAAAA==.',['歲月']='歲月龍龍:BAABLAAFFH8KAAITAAUIVxAvKAAuAQATAAUIVxAvKAAuAQAAAA==.',['毁灭']='毁灭过去:BAAALAADCgIIAgAAAA==.',['水晶']='水晶双子星:BAAALAAECgYIBgAAAA==.',['水水']='水水是两个:BAAALAAECgYIBwAAAA==.',['沙华']='沙华凋零:BAAALAAECggICAAAAA==.',['沙若']='沙若:BAAALAADCgIIAgAAAA==.',['没图']='没图你说个碉:BAAALAAECgIIAgAAAA==.',['没心']='没心的要不要:BAAALAAECgYICQAAAA==.',['沧海']='沧海遗粟邓:BAACLAAFFH8qAAQUAAYIzRnxDAB0AQAUAAYIGxnxDAB0AQATAAUIhRJVGAACAQAYAAEIzA61CABJAAAsAAQKfycAAxMACAh3ILoZAO4CABMACAh3ILoZAO4CABQAAghCGJI/AI4AAAAA.',['洋葱']='洋葱头:BAAALAAECgEIAQAAAA==.',['洛洛']='洛洛娜:BAABLAAFFH8OAAMZAAUIDRRaHgDTAAAZAAQIuBhaHgDTAAAPAAEIswHUYAAiAAAAAA==.洛洛家的保安:BAAALAAFFAIIAgAAAA==.洛洛家的术师:BAAALAAFFAIIAgAAAA==.',['洪猫']='洪猫:BAAALAADCgEIAQAAAA==.',['涓涓']='涓涓细流:BAAALAADCgUIBQAAAA==.',['淡淡']='淡淡的香水:BAAALAAECgYIBgAAAA==.',['淡若']='淡若悠然:BAAALAAFFAIIBAAAAA==.',['混血']='混血小魔姬:BAAALAAFFAIIAgAAAA==.',['清水']='清水健:BAAALAAFFAIIAgAAAA==.',['滚来']='滚来滚去香肠:BAAALAAECgYIBgAAAA==.',['漫天']='漫天枫痕:BAAALAAFFAIIAgAAAA==.',['潮柒']='潮柒洛:BAABLAAFFH8IAAIEAAIINxcXOwCKAAAEAAIINxcXOwCKAAAAAA==.',['熊猫']='熊猫与傻瓜:BAAALAAECggICAAAAA==.',['熊霸']='熊霸霸:BAAALAAFFAIIAgAAAA==.',['爱丝']='爱丝鸡磨人:BAACLAAFFH8NAAIDAAQIJRiuWwDXAAADAAQIJRiuWwDXAAAsAAQKfycAAgMACAjlHlNGALsBAAMACAjlHlNGALsBAAAA.',['牛小']='牛小花灬:BAABLAAFFH8eAAMQAAgIOxsNCQCFAQAQAAYIuhoNCQCFAQAIAAMITBfHMAD/AAAAAA==.',['牛油']='牛油果:BAAALAAECgYIBwAAAA==.',['牛牛']='牛牛犇特牛:BAAALAAECgQIAgAAAA==.',['牛肉']='牛肉干的妈妈:BAABLAAFFH8bAAIJAAUI+BqBFQCnAQAJAAUI+BqBFQCnAQABLAAFFAYIHQAPAKkeAA==.牛肉干的妹妹:BAABLAAFFH8HAAIEAAUI9xbqIQBOAQAEAAUI9xbqIQBOAQAAAA==.牛肉干的弟弟:BAABLAAFFH8FAAIDAAUI8wSjXQDNAAADAAUI8wSjXQDNAAAAAA==.牛肉干的爸爸:BAABLAAFFH8dAAIPAAYIqR7FCwD5AQAPAAYIqR7FCwD5AQAAAA==.',['牛逼']='牛逼坏了:BAAALAAECgYIDwAAAA==.',['特洛']='特洛伊之恺撒:BAAALAAECgUIBwAAAA==.',['狂暴']='狂暴怒怒:BAACLAAFFH8MAAITAAII8RgqLwCgAAATAAII8RgqLwCgAAAsAAQKfyIAAhMACAi2IOYjALYCABMACAi2IOYjALYCAAAA.',['狐小']='狐小妖:BAAALAAECggICAAAAA==.',['王力']='王力宏:BAAALAAFFAIIAwAAAA==.',['王帝']='王帝的子孙:BAAALAAFFAIIAgAAAA==.',['班门']='班门弄大斧:BAAALAAFFAIIBAAAAA==.',['瓦乌']='瓦乌:BAAALAADCgEIAQAAAA==.',['疾风']='疾风之战:BAAALAADCgQIBAAAAA==.疾风之术:BAAALAADCgcIBwAAAA==.疾风之猎:BAAALAADCgIIAgAAAA==.疾风紫嫣:BAAALAADCgcICQAAAA==.',['白丶']='白丶兰地:BAAALAAECgYIBgAAAA==.',['白生']='白生生:BAAALAAECgYIBgAAAA==.',['百步']='百步剑方:BAABLAAFFH8FAAITAAMIexJfOACRAAATAAMIexJfOACRAAAAAA==.',['皆为']='皆为序章:BAAALAAECgEIAQAAAA==.',['皆非']='皆非丶:BAAALAAECgYIBgAAAA==.',['真看']='真看不透红尘:BAAALAADCgEIAQAAAA==.',['瞎猫']='瞎猫:BAAALAAECgYIBgAAAA==.',['知来']='知来者:BAAALAAECggICAAAAA==.',['矮之']='矮之哀伤:BAABLAAFFH8IAAICAAIIfRLJfQBHAAACAAIIfRLJfQBHAAAAAA==.',['石中']='石中火:BAAALAAECgIIAgAAAA==.',['破障']='破障:BAAALAAECgcIBwAAAA==.',['祭忆']='祭忆:BAAALAAECgYIBgAAAA==.',['童姥']='童姥:BAAALAAECgYIBgAAAA==.',['笔染']='笔染秋渡:BAAALAAECgYICwAAAA==.',['米兰']='米兰小铁匠:BAAALAAECggICAAAAA==.',['精终']='精终报妻:BAAALAAECgYICAAAAA==.',['紫眼']='紫眼泪导师:BAAALAADCgYIBgAAAA==.',['红日']='红日一号:BAAALAAFFAIIAgAAAA==.',['红的']='红的发紫:BAAALAAECgYIDQAAAA==.',['红袖']='红袖半遮面:BAAALAADCgYIBgAAAA==.',['纯爱']='纯爱战神:BAAALAAECgYIBwAAAA==.',['纳西']='纳西妲:BAAALAAFFAMIAgAAAA==.',['绵绵']='绵绵冰:BAABLAAFFH8GAAIHAAII7Q85SgCWAAAHAAII7Q85SgCWAAAAAA==.',['绿豆']='绿豆大的胆:BAABLAAECn8VAAICAAgIohg7ggD2AQACAAgIohg7ggD2AQABLAAFFAYIKAACAMccAA==.',['缺德']='缺德不缺德:BAAALAAECgUIBwAAAA==.',['群主']='群主大人:BAAALAAECgEIAQAAAA==.',['老北']='老北鼻:BAAALAAFFAYIAgAAAA==.',['联盟']='联盟追猎者:BAAALAAECgUIBQAAAA==.',['聪明']='聪明峰峰:BAABLAAFFH8IAAIDAAYIOAbPUAALAQADAAYIOAbPUAALAQAAAA==.',['胃了']='胃了布洛芬:BAAALAAECgYIBgAAAA==.',['胡广']='胡广生:BAAALAAECgYICQAAAA==.',['腰圆']='腰圆棍粗:BAAALAAECgUICAAAAA==.',['艾殇']='艾殇的怒吼:BAAALAAECgEIAQAAAA==.',['艾瑞']='艾瑞:BAAALAADCgcICQAAAA==.',['芙蕾']='芙蕾雅薇恩:BAAALAAECggIAwAAAA==.',['茂爷']='茂爷的冲锋:BAAALAAFFAIIAgAAAA==.茂爷的图腾:BAABLAAFFH8JAAMEAAUILw49OwC2AAAEAAQI+gs9OwC2AAAFAAEIoAoHRABEAAAAAA==.茂爷的审判:BAABLAAFFH8KAAIIAAMIpBDbRACFAAAIAAMIpBDbRACFAAAAAA==.茂爷的深呼吸:BAAALAAECgYIBgAAAA==.',['草飞']='草飞机:BAABLAAFFH8ZAAMPAAYIZBLTGwBKAQAPAAUIKBTTGwBKAQAZAAMIfg0EJwB7AAAAAA==.',['莎拉']='莎拉菌:BAAALAADCgMIBQAAAA==.',['莫若']='莫若不在:BAAALAADCgYIBgAAAA==.',['莽夫']='莽夫:BAABLAAFFH8GAAITAAUI2RN0DQDCAQATAAUI2RN0DQDCAQAAAA==.',['菓橘']='菓橘糖:BAAALAADCgIIAgAAAA==.',['萌萌']='萌萌小独孤丶:BAABLAAECn8YAAIaAAgI2SP6HAB9AgAaAAgI2SP6HAB9AgABLAAFFAgIPgADAJcaAA==.',['萧碧']='萧碧宰紫:BAAALAADCgYIBgAAAA==.',['萨拉']='萨拉峻:BAAALAAECgUIBwAAAA==.',['蔡依']='蔡依林:BAAALAADCgQIBAAAAA==.',['薄荷']='薄荷冰美式:BAABLAAFFH8LAAIaAAIIDQhcGgA1AAAaAAIIDQhcGgA1AAAAAA==.',['虎豆']='虎豆豆:BAABLAAFFH8OAAMEAAMIkxbwTQCAAAAEAAIIoBbwTQCAAAAbAAIIIgKDCAA4AAAAAA==.',['血渊']='血渊:BAABLAAECn8UAAIMAAYIJwi6LwC4AAAMAAYIJwi6LwC4AAAAAA==.',['術士']='術士大叔邓:BAABLAAFFH8RAAILAAYIARQgKAB5AQALAAYIARQgKAB5AQAAAA==.',['衣着']='衣着浅斟:BAAALAAECgMIAwAAAA==.',['西夏']='西夏啤酒:BAAALAADCgEIAQAAAA==.',['见手']='见手青冰美式:BAAALAAECgYIBwAAAA==.',['计本']='计本六班:BAABLAAFFH8KAAICAAUI8RBlRgAhAQACAAUI8RBlRgAhAQAAAA==.',['请叫']='请叫我冒险者:BAAALAAECgIIAgAAAA==.',['诺拉']='诺拉:BAAALAADCgQIBAAAAA==.',['赖小']='赖小七:BAAALAAECgYIDQAAAA==.',['超级']='超级赛亚人:BAAALAADCgQIBAAAAA==.',['趙雲']='趙雲:BAAALAAFFAIIAgAAAA==.',['路妃']='路妃:BAAALAAFFAIIBAAAAA==.',['轩辕']='轩辕乔丹歌:BAAALAAECgYICwAAAA==.',['达卡']='达卡什:BAABLAAECn8XAAIUAAcIohxEFACnAQAUAAcIohxEFACnAQAAAA==.',['迪斯']='迪斯:BAAALAAFFAIIAgAAAA==.',['那年']='那年我十八岁:BAAALAADCgMIAwAAAA==.',['邦加']='邦加啦什:BAAALAAECgEIAQAAAA==.',['邪战']='邪战:BAAALAAECgUIBQAAAA==.',['酷睿']='酷睿门森:BAAALAADCgUIBQAAAA==.',['重生']='重生成骑士:BAAALAAECgUIBQAAAA==.',['重铸']='重铸圣光:BAAALAADCgcIBwAAAA==.',['野性']='野性德丨晓阳:BAABLAAFFH8GAAMcAAIIxRrwCwBYAAAcAAIIxRrwCwBYAAAPAAIIxAXiUQBQAAABLAAFFAgIPQAPAD4mAA==.',['野百']='野百合:BAAALAAECgIIAgAAAA==.',['钟吾']='钟吾奇奇:BAAALAAECgYIEgAAAA==.钟吾飞雪:BAAALAAECgYIDAAAAA==.',['钢琴']='钢琴里的猫:BAABLAAFFH8JAAIBAAgI4hsfAwBsAgABAAgI4hsfAwBsAgAAAA==.',['阿强']='阿强:BAABLAAFFH8GAAIIAAYI7hRKGwCBAQAIAAYI7hRKGwCBAQAAAA==.',['阿枝']='阿枝:BAAALAAECggIEAAAAA==.',['阿肚']='阿肚灬:BAABLAAFFH8QAAIOAAUI9A9xDAAsAQAOAAUI9A9xDAAsAQAAAA==.',['陌阡']='陌阡荟:BAAALAAECgQIBgAAAA==.陌阡韵:BAAALAAECgYIBgAAAA==.',['陪宝']='陪宝宝旅行:BAABLAAFFH8GAAIDAAUISAu5UwAAAQADAAUISAu5UwAAAQAAAA==.',['雷公']='雷公助我:BAABLAAFFH8LAAIEAAIIQRPlUABrAAAEAAIIQRPlUABrAAAAAA==.',['雾满']='雾满拦江:BAAALAADCggICAAAAA==.',['露营']='露营必须酒:BAAALAAFFAIIAgAAAA==.',['青青']='青青国王:BAABLAAECn8XAAIaAAcIXw7WWgBPAQAaAAcIXw7WWgBPAQAAAA==.',['风一']='风一样的什么:BAABLAAECn8VAAIQAAYIswvmUQANAQAQAAYIswvmUQANAQAAAA==.',['风中']='风中的脆脆冰:BAAALAADCgIIAgAAAA==.',['飒拉']='飒拉俊:BAAALAAECgYIBgAAAA==.',['飘落']='飘落枫叶:BAAALAAECgQIBAAAAA==.',['饼饼']='饼饼帝:BAAALAAECgYIDAAAAA==.',['魂武']='魂武:BAAALAADCgEIAQAAAA==.',['鸡你']='鸡你太美:BAAALAAECgYIBgAAAA==.',['黄帝']='黄帝昭曰:BAAALAAECgYIDAAAAA==.',['黄昏']='黄昏的凄美:BAAALAAECgIIBAAAAA==.',['黑灵']='黑灵凤:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end