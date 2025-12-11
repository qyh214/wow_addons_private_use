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
 local lookup = {'Shaman-Elemental','Shaman-Restoration','DeathKnight-Frost','Warrior-Fury','Druid-Restoration','Druid-Balance','Hunter-BeastMastery','Evoker-Preservation','Monk-Brewmaster','Mage-Arcane','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','DemonHunter-Vengeance','Mage-Frost','Paladin-Retribution','Evoker-Augmentation','Evoker-Devastation','Druid-Feral','Rogue-Assassination','Unknown-Unknown','Hunter-Survival','DeathKnight-Unholy','Paladin-Protection','Hunter-Marksmanship','Mage-Fire','DeathKnight-Blood','Monk-Windwalker','Monk-Mistweaver','Warrior-Protection','Rogue-Subtlety','Warlock-Destruction',}; local provider = {region='CN',realm='安加萨',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ch='Choose:BAACLAAFFH8TAAIBAAYI2SPTCQAPAgABAAYI2SPTCQAPAgAsAAQKf8cCAwEACAhXJSELADUDAAEACAhXJSELADUDAAIAAQiNDIQ/ATwAAAAA.',Cr='Creepyc:BAACLAAFFH8UAAIDAAYI+R1jIACzAQADAAYI+R1jIACzAQAsAAQKfysAAgMACAiJH+QZAB0CAAMACAiJH+QZAB0CAAAA.',Do='Dominus:BAABLAAFFH8MAAIDAAIICwtsdQCNAAADAAIICwtsdQCNAAAAAA==.Donny:BAAALAADCgEIAQAAAA==.',Fe='Feather:BAAALAAECgYIBgAAAA==.',Fr='Freyr:BAAALAAECgYIAwAAAA==.',Gh='Ghostnight:BAAALAADCgIIAgAAAA==.',Hz='Hzhkda:BAABLAAFFH8FAAIEAAIItQjvWQA8AAAEAAIItQjvWQA8AAAAAA==.',Lu='Luciano:BAABLAAFFH8KAAMFAAMIUQ4vOACKAAAFAAMIUQ4vOACKAAAGAAII/ANCQQAUAAABLAAFFAgIPQAFAD4mAA==.',Ma='Macmillan:BAAALAADCggICAABLAAFFAMIBwAHAHcQAA==.Maydaymayday:BAAALAADCgEIAQAAAA==.',Mo='Mortis:BAAALAAECgYICgABLAAFFAgIOAAIAKoWAA==.',Na='Natinawind:BAAALAAECgUIBgAAAA==.',Oo='Oops:BAAALAAECggICQABLAAFFAgIIAAJAB0cAA==.',Pl='Playerhqkacu:BAAALAAFFAIIAwAAAA==.Playerxydwcz:BAAALAAECgEIAgAAAA==.',Re='Redsky:BAAALAAECgMIBAAAAA==.',Se='Sevenoneone:BAAALAAECgIIAgAAAA==.',Sl='Sleepyrain:BAABLAAFFH8RAAIKAAcI7iEGCQBSAgAKAAcI7iEGCQBSAgAAAA==.',St='Starrysky:BAAALAAECgIIBAAAAA==.',Ti='Tinyff:BAABLAAFFH8WAAMFAAUIKRwwFQCNAQAFAAUIKRwwFQCNAQAGAAQI+ArMIQCnAAAAAA==.',Ve='Venividivici:BAAALAAECggICAAAAA==.',Wo='Worldender:BAAALAAFFAIIBAAAAA==.',Wq='Wqeqadas:BAAALAAECggICAAAAA==.',Yu='Yumao:BAABLAAFFH8GAAILAAII7QsVTwCNAAALAAII7QsVTwCNAAAAAA==.',['万万']='万万想不到:BAAALAAECgYIDwAAAA==.',['三妻']='三妻弟:BAAALAAECgYIBgAAAA==.',['不落']='不落皇旗前:BAABLAAFFH8QAAIEAAIICQx9PwCNAAAEAAIICQx9PwCNAAAAAA==.',['不蓝']='不蓝角:BAAALAAECgYICQAAAA==.',['不见']='不见岳:BAABLAAFFH8QAAIDAAUItheJTwDiAAADAAUItheJTwDiAAAAAA==.',['专业']='专业开腿大师:BAAALAAFFAIIAgAAAA==.',['丨欧']='丨欧皇毛丨:BAABLAAFFH8GAAIEAAYIxgOsKwAIAQAEAAYIxgOsKwAIAQAAAA==.',['丶劉']='丶劉德華:BAABLAAECn8VAAIEAAYIwiH9OwBFAgAEAAYIwiH9OwBFAgAAAA==.',['丶青']='丶青山劉德華:BAAALAAECgUICAAAAA==.',['二手']='二手电工:BAAALAAFFAIIAgAAAA==.',['二舅']='二舅妈来啦:BAAALAAECgMIBAAAAA==.',['人丑']='人丑爱作怪:BAAALAAECgYICQAAAA==.',['他整']='他整晚在写信:BAAALAAECggICAAAAA==.',['伊落']='伊落玛丽:BAABLAAFFH8HAAMMAAMInROuLADAAAAMAAMInROuLADAAAANAAIIUwcBLQA8AAABLAAFFAgIOAAIAKoWAA==.',['伏羲']='伏羲猎:BAACLAAFFH8GAAILAAYI1hOQIwBuAQALAAYI1hOQIwBuAQAsAAQKfxYAAwsACAiHCxdfAAIBAAsACAiHCxdfAAIBAA4ABgjMA0RNAKMAAAAA.',['优雅']='优雅不过时:BAAALAAECgQIBAAAAA==.',['会稽']='会稽山:BAAALAAECgYICwAAAA==.',['伟哥']='伟哥丶:BAABLAAECn8WAAIPAAcIkhIaNwCZAQAPAAcIkhIaNwCZAQAAAA==.',['佩佩']='佩佩:BAABLAAFFH8dAAIHAAYIJSGLFQDmAQAHAAYIJSGLFQDmAQAAAA==.',['倚楼']='倚楼听风雨:BAABLAAFFH8GAAIQAAYIZRq2FwCUAQAQAAYIZRq2FwCUAQAAAA==.',['倾城']='倾城兽花:BAAALAAECgYIBgAAAA==.',['光年']='光年以北:BAABLAAFFH8KAAIDAAIIAxfgcwBNAAADAAIIAxfgcwBNAAAAAA==.',['光明']='光明中的黑暗:BAAALAAECgYIEwAAAA==.',['八斤']='八斤:BAAALAAECgIIAgAAAA==.',['兮左']='兮左君丶:BAAALAAECgYIBgAAAA==.',['冲魂']='冲魂:BAACLAAFFH8IAAMNAAII5ApLJACCAAANAAII5ApLJACCAAAMAAII6wJRQgBwAAAsAAQKfyMAAg0ACAjEHnQSANwCAA0ACAjEHnQSANwCAAAA.',['凯尔']='凯尔血蹄:BAAALAAECggICAAAAA==.',['刷好']='刷好猫的血:BAABLAAFFH8JAAIFAAMIVwdJOgCEAAAFAAMIVwdJOgCEAAAAAA==.',['勇敢']='勇敢牛牛:BAAALAAFFAIIAgAAAA==.',['北欧']='北欧女人:BAAALAAECgcIBwAAAA==.',['千珏']='千珏:BAAALAAFFAIIAgAAAA==.',['午夜']='午夜屠猪男:BAAALAAFFAIIBAAAAA==.',['又见']='又见流星雨:BAAALAAFFAIIAgAAAA==.',['发光']='发光胡子美女:BAAALAAECgYIBgAAAA==.',['叭噗']='叭噗:BAAALAADCgEIAQAAAA==.',['可爱']='可爱琪宝贝:BAAALAADCgMIAwAAAA==.',['周扒']='周扒皮偷枇杷:BAAALAAECgEIAQAAAA==.周扒皮弹琵琶:BAAALAAECgEIAQAAAA==.',['哈次']='哈次捏米库:BAAALAADCggICAAAAA==.',['哟啊']='哟啊表提佛:BAAALAAECgQIBgAAAA==.',['哥们']='哥们好胸呀:BAAALAAECgIIAgAAAA==.',['哩哩']='哩哩是笨蛋:BAAALAAECgYIBgAAAA==.',['啊肉']='啊肉丶:BAABLAAFFH8GAAIHAAYIMBVVOgBYAQAHAAYIMBVVOgBYAQAAAA==.',['善听']='善听:BAAALAADCgYIBgAAAA==.',['圣光']='圣光一米二:BAAALAADCgMIAwAAAA==.',['地精']='地精:BAAALAAECgMIAwAAAA==.',['夜怨']='夜怨丶冷兮:BAAALAAFFAIIBAAAAA==.夜怨丶芯詪:BAABLAAECn8YAAIDAAYIhR++JwDXAQADAAYIhR++JwDXAQAAAA==.',['大别']='大别熊别又别:BAABLAAFFH8IAAIGAAIIExZYGgCaAAAGAAIIExZYGgCaAAAAAA==.',['大垮']='大垮:BAAALAAECgYICgAAAA==.',['大師']='大師兇:BAAALAAECgcIEAAAAA==.',['大碗']='大碗油茶:BAAALAAFFAMIAwAAAA==.',['大脚']='大脚怪:BAAALAAECgEIAQAAAA==.',['大领']='大领主:BAAALAADCgEIAQAAAA==.',['天命']='天命难违:BAABLAAECn8XAAIHAAYIGhtNbgBnAQAHAAYIGhtNbgBnAQAAAA==.',['天狼']='天狼丨星:BAAALAAECgQIBAAAAA==.',['天相']='天相:BAAALAAECgYIBgAAAA==.',['妹妹']='妹妹别跑呀:BAAALAAECgQIBAAAAA==.',['姐爱']='姐爱加血:BAAALAAECgEIAQAAAA==.',['子子']='子子:BAAALAAECgYIBgAAAA==.',['子弹']='子弹飞一会:BAABLAAFFH8IAAIHAAIIth4wRACgAAAHAAIIth4wRACgAAAAAA==.',['孤独']='孤独的王:BAAALAAFFAIIAwAAAA==.',['宮脇']='宮脇咲良:BAACLAAFFH8oAAMRAAYIEBTPBQBpAQARAAYIJhPPBQBpAQASAAQIThFKDAAuAQAsAAQKfy4ABBEACAgCIf0DAJsCABEABwh2IP0DAJsCABIACAiyHdsZAE8CAAgABgjyBjMwAN4AAAAA.',['对自']='对自己真狠:BAAALAAECgIIAgAAAA==.',['小手']='小手暖呼呼:BAABLAAFFH8IAAICAAII3RtvSgCIAAACAAII3RtvSgCIAAAAAA==.',['小拉']='小拉布:BAAALAADCggIGAAAAA==.',['小松']='小松菜奈:BAAALAAECgYIBQAAAA==.',['小浪']='小浪蹄子:BAAALAAFFAEIAQAAAA==.',['小蘑']='小蘑菇:BAAALAAFFAIIBAAAAA==.',['小贺']='小贺贺:BAAALAAECgMIAwAAAA==.',['小龙']='小龙龙人:BAACLAAFFH8ZAAIIAAcI6xdtBgCOAQAIAAcI6xdtBgCOAQAsAAQKfzwAAggACAhsG50MAGYCAAgACAhsG50MAGYCAAAA.',['尘埃']='尘埃晓法:BAABLAAFFH8GAAIPAAIIlwxjGwA6AAAPAAIIlwxjGwA6AAAAAA==.',['尤帝']='尤帝安:BAAALAAECgIIAgAAAA==.',['尼诺']='尼诺滴咕咕:BAACLAAFFH8iAAQFAAUI4hLIHABBAQAFAAUI4hLIHABBAQAGAAMIUQyQKABxAAATAAEIAQMCEgAlAAAsAAQKfxYAAwUACAgwDxhaAIYBAAUACAgwDxhaAIYBAAYACAgxDftOAHkBAAAA.',['山田']='山田杏奈:BAABLAAFFH8GAAIUAAYIVw1hCgBrAQAUAAYIVw1hCgBrAQAAAA==.',['山顶']='山顶那个坑:BAAALAAECgIIAgAAAA==.',['岁月']='岁月墨染:BAABLAAFFH8NAAIDAAQIfAr1UwDAAAADAAQIfAr1UwDAAAAAAA==.',['崔斯']='崔斯塔娜:BAAALAAECgYICgAAAA==.',['布洛']='布洛克斯丶:BAAALAAECgYIDAAAAA==.',['年轻']='年轻的河神呦:BAAALAAECgYICgAAAA==.',['年迈']='年迈的大领主:BAABLAAFFH8GAAIQAAIIjBo+WABKAAAQAAIIjBo+WABKAAAAAA==.',['库巴']='库巴姬:BAAALAAECgMIAwAAAA==.',['康斯']='康斯坦丁丶:BAACLAAFFH8TAAIGAAUIwB4eEQBhAQAGAAUIwB4eEQBhAQAsAAQKfyAAAgYABghwJKwPAAkCAAYABghwJKwPAAkCAAEsAAUUCAgCABUAAAAA.',['弗斯']='弗斯塔德蛮锤:BAAALAAFFAIIBAAAAA==.',['弹药']='弹药充足:BAABLAAECn8aAAIHAAYIfyQ/UAA+AgAHAAYIfyQ/UAA+AgABLAAFFAgIHAAGAOIkAA==.',['德才']='德才兼备:BAAALAAECgcICgAAAA==.',['心术']='心术不歪:BAAALAAECgYIDAAAAA==.',['忠贞']='忠贞至臻丶:BAABLAAFFH8LAAICAAIIHxaoTwB8AAACAAIIHxaoTwB8AAAAAA==.',['恢复']='恢复德:BAAALAAECgMIAwAAAA==.',['恶陌']='恶陌的咒語:BAAALAAECgUIBQAAAA==.',['情书']='情书:BAABLAAFFH8OAAIQAAUIthmHJwA9AQAQAAUIthmHJwA9AQAAAA==.',['我上']='我上早八:BAAALAADCgYIBgAAAA==.',['我不']='我不是奶龙:BAACLAAFFH8TAAMRAAUIswvOCAABAQARAAUIswvOCAABAQAIAAQIdBltDgDDAAAsAAQKfyYAAwgACAgAIzwBABwDAAgACAgAIzwBABwDABEAAgh0G8cLAKMAAAEsAAUUCAg4AAgAqhYA.',['我只']='我只是太寂寞:BAAALAAECgQIBAAAAA==.',['我是']='我是奶龙:BAACLAAFFH84AAIIAAgIqhaDBABXAgAIAAgIqhaDBABXAgAsAAQKfz0ABAgACAg4JCsEAAgDAAgACAg4JCsEAAgDABIAAgg1FspeAGwAABEAAghAGS0OAF8AAAAA.',['扒勒']='扒勒猛干:BAAALAADCgUIBQAAAA==.',['拉斯']='拉斯塔哈大王:BAABLAAFFH8QAAICAAUIKRLOJwAlAQACAAUIKRLOJwAlAQAAAA==.',['旋风']='旋风冲锋斩:BAAALAAECgcIDQAAAA==.',['昆仑']='昆仑山昆汀:BAAALAAECgMIAwAAAA==.',['晓芙']='晓芙灬丽:BAAALAADCgEIAQAAAA==.',['暗影']='暗影神魔:BAAALAADCgEIAQAAAA==.',['暮雪']='暮雪菲菲:BAAALAADCgEIAQAAAA==.',['更木']='更木剣八:BAAALAAECgYIEAAAAA==.',['月下']='月下灬小乖猫:BAABLAAECn8UAAIHAAYIbhhbowCnAQAHAAYIbhhbowCnAQAAAA==.',['月野']='月野兔:BAAALAADCgEIAQAAAA==.',['朴灬']='朴灬大雷:BAAALAAECgYIBgAAAA==.',['杂念']='杂念:BAAALAAFFAIIBAAAAA==.',['李冰']='李冰冰:BAABLAAFFH8UAAIJAAgInA9kBgDvAQAJAAgInA9kBgDvAQAAAA==.',['李慧']='李慧珍:BAAALAADCgIIAgAAAA==.',['材料']='材料仓库一:BAAALAAECgQIBAAAAA==.',['梅洛']='梅洛:BAAALAAECgYICwAAAA==.',['森林']='森林狼:BAACLAAFFH8oAAIWAAYImRq0AADJAQAWAAYImRq0AADJAQAsAAQKfzAAAhYACAgaJHAAAO4CABYACAgaJHAAAO4CAAAA.',['欢乐']='欢乐的小淇:BAAALAAECgYIEgAAAA==.',['武破']='武破:BAAALAAECgIIAwAAAA==.',['武神']='武神经:BAAALAAECgIIAgAAAA==.',['歧客']='歧客:BAABLAAFFH8KAAMDAAIIiyESOQC/AAADAAIIQyESOQC/AAAXAAEIQB90GgBYAAAAAA==.',['沉默']='沉默狮子:BAAALAAECgYIDgAAAA==.',['沧海']='沧海枉然:BAAALAAECgYIBgAAAA==.',['油条']='油条:BAAALAAFFAIIAgAAAA==.',['油腻']='油腻的师姐儿:BAAALAAECgYIEQAAAA==.',['法海']='法海丶:BAAALAAECgYIBgAAAA==.',['流年']='流年罒反:BAAALAAECgIIAgAAAA==.',['清蒸']='清蒸羊肾丶:BAABLAAFFH8IAAIBAAYICQ9oHQBVAQABAAYICQ9oHQBVAQAAAA==.',['温暖']='温暖小圣光:BAABLAAFFH8aAAIYAAUIHhaeCgD/AAAYAAUIHhaeCgD/AAAAAA==.',['灬寒']='灬寒瞳乄:BAAALAAECgYIBgAAAA==.',['灬战']='灬战好丶:BAAALAAECgYIBgAAAA==.',['灬缺']='灬缺德乄:BAAALAAFFAIIAgAAAA==.',['灵魂']='灵魂绽放:BAAALAAECgYICgAAAA==.',['炽天']='炽天使之夜:BAAALAADCgEIAQAAAA==.',['熊喵']='熊喵酒仙:BAAALAAECggIDgAAAA==.',['牛牛']='牛牛公主:BAAALAAECggICAAAAA==.',['狐仙']='狐仙会法术:BAAALAADCgUIBQAAAA==.',['猕猴']='猕猴桃:BAAALAAECgYIBgAAAA==.',['王冰']='王冰冰:BAABLAAFFH8QAAIJAAgIkhDUBQD+AQAJAAgIkhDUBQD+AQABLAAFFAgIFAAJAJwPAA==.',['王豆']='王豆豆:BAABLAAFFH8UAAIJAAgIJQyfCwCKAQAJAAgIJQyfCwCKAQABLAAFFAgIFAAJAJwPAA==.',['玛恩']='玛恩纳:BAAALAAECgUIBQAAAA==.',['环奈']='环奈桥本:BAAALAADCgcIBwAAAA==.',['疯狂']='疯狂山脉:BAAALAAECgEIAQAAAA==.疯狂的冰狼:BAAALAAECgQIBQAAAA==.',['疯癫']='疯癫:BAAALAAFFAIIAgAAAA==.',['瘦多']='瘦多多:BAAALAAECgYIDAAAAA==.',['白胡']='白胡子老头:BAAALAAECgUIBgAAAA==.',['百草']='百草味:BAAALAADCgIIAgAAAA==.',['皮多']='皮多肉少:BAAALAAECgYIBgAAAA==.',['相逢']='相逢自有时丶:BAAALAAECgYIBgAAAA==.',['真法']='真法力残渣:BAAALAAECgYICwAAAA==.',['神一']='神一:BAAALAAECgUICAAAAA==.',['神兽']='神兽黑子:BAAALAAECggIEAAAAA==.',['穿越']='穿越者:BAAALAAECgYIDAAAAA==.',['笑笑']='笑笑:BAAALAAFFAEIAQAAAA==.',['筑基']='筑基高手:BAACLAAFFH8QAAIHAAII4yWRMgC/AAAHAAII4yWRMgC/AAAsAAQKfxwAAgcABgi1JR0yAJECAAcABgi1JR0yAJECAAAA.',['米高']='米高尔:BAAALAAECgYIBgAAAA==.',['糖菜']='糖菜菜:BAAALAAECgEIAQAAAA==.',['索尔']='索尔丶古德曼:BAAALAAFFAIIAgAAAA==.',['紫色']='紫色包装纸:BAAALAAECgQIBAAAAA==.紫色苍蝇:BAAALAAFFAIIAgAAAA==.',['終丶']='終丶雨:BAABLAAFFH8SAAIDAAgI1AvGJwD6AAADAAgI1AvGJwD6AAAAAA==.',['红鸾']='红鸾:BAAALAADCgQIBAAAAA==.',['绝望']='绝望大咕咕:BAABLAAFFH8nAAIFAAYIHhtMDwDNAQAFAAYIHhtMDwDNAQAAAA==.绝望的圣光:BAAALAADCgEIAQAAAA==.绝望的幻月:BAAALAAECgYIBwAAAA==.',['维他']='维他命可乐:BAAALAAFFAIIAgAAAA==.',['绿色']='绿色飞翔:BAAALAAECgIIAgAAAA==.',['老癫']='老癫咚:BAAALAAECgYICgAAAA==.',['耶格']='耶格尔:BAABLAAFFH8IAAIDAAYIdxqFIACyAQADAAYIdxqFIACyAQAAAA==.',['肚肚']='肚肚子:BAABLAAECn8YAAMPAAYIjAu6UwAmAQAPAAYIowq6UwAmAQAKAAYIzgc0tgATAQAAAA==.',['胖丁']='胖丁:BAAALAAECgYIBgAAAA==.',['胖鹌']='胖鹌鹑:BAAALAAECgIIAgAAAA==.',['脚指']='脚指头:BAABLAAFFH8KAAIFAAII/BQBLwB3AAAFAAII/BQBLwB3AAAAAA==.',['脚趾']='脚趾头:BAABLAAFFH8KAAILAAIIvyCbMQCnAAALAAIIvyCbMQCnAAAAAA==.',['艾贝']='艾贝儿:BAAALAADCgcIBwAAAA==.',['芒果']='芒果丁:BAAALAAECgMIBAAAAA==.',['苦艾']='苦艾酒:BAABLAAFFH8HAAIFAAUI7A7wQgBqAAAFAAUI7A7wQgBqAAAAAA==.',['范廸']='范廸塞尔:BAACLAAFFH8kAAIZAAYI+iILAgD0AQAZAAYI+iILAgD0AQAsAAQKfxwAAhkACAioI9oJABYDABkACAioI9oJABYDAAAA.',['茉莉']='茉莉:BAAALAAECgYIBgAAAA==.',['萌面']='萌面大师兇:BAAALAAECgcICgAAAA==.',['落雨']='落雨丨艾达汀:BAAALAADCgEIAQAAAA==.',['蓝玉']='蓝玉飞鱼:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色妖姬:BAAALAAECgQIBQAAAA==.',['蕾欧']='蕾欧娜:BAABLAAECn8YAAIEAAYI5Rp2WQDlAQAEAAYI5Rp2WQDlAQAAAA==.',['虎头']='虎头鱼伍号盾:BAAALAAFFAIIAQAAAA==.',['血晗']='血晗愁:BAAALAAECgYIBgAAAA==.',['行云']='行云之月:BAAALAADCgcIBwAAAA==.',['西班']='西班牙馅饼:BAAALAAECgMIAwAAAA==.',['观一']='观一叶而知冬:BAABLAAFFH8MAAIJAAYI5xaUDgBeAQAJAAYI5xaUDgBeAQAAAA==.观一叶而知秋:BAABLAAFFH8MAAIJAAYIahvzCgCUAQAJAAYIahvzCgCUAQAAAA==.',['貔貅']='貔貅:BAAALAAECgYIBgAAAA==.',['赞达']='赞达拉牛牛:BAAALAAFFAEIAQAAAA==.',['赤古']='赤古:BAAALAAECgYICgAAAA==.',['赤雪']='赤雪伯爵:BAAALAAECgYIBQAAAA==.',['超级']='超级赛亚朲:BAAALAAECgYICwAAAA==.',['跳跳']='跳跳小绣虎:BAAALAAECgEIAQAAAA==.',['软甜']='软甜糯米糕:BAABLAAFFH8VAAMKAAYI1RtjIQAdAQAKAAUIgB1jIQAdAQAaAAEIgRNACwBLAAAAAA==.',['过期']='过期毒奶:BAAALAAECgYIBgAAAA==.',['迷人']='迷人小陷阱:BAABLAAFFH8LAAIZAAMIwhWOGwCaAAAZAAMIwhWOGwCaAAAAAA==.',['逍遥']='逍遥丨二郎拳:BAABLAAFFH8MAAIJAAYIWBLcDgBaAQAJAAYIWBLcDgBaAQAAAA==.逍遥丨六星拳:BAAALAAFFAIIAgAAAA==.',['逐暗']='逐暗者:BAABLAAFFH8QAAIBAAYIpiB5DQDaAQABAAYIpiB5DQDaAQAAAA==.',['那个']='那个下面滂臭:BAABLAAFFH8SAAIbAAYIlBu2CQB7AQAbAAYIlBu2CQB7AQAAAA==.',['鄧路']='鄧路奇:BAAALAADCgEIAQAAAA==.',['酱爆']='酱爆:BAAALAADCgUIBQAAAA==.',['重生']='重生之向右转:BAABLAAFFH8MAAIHAAUInQ7BUQAIAQAHAAUInQ7BUQAIAQAAAA==.',['金刚']='金刚小子:BAAALAAECgYICQAAAA==.',['钟声']='钟声与狐仙:BAAALAAECgYIEgAAAA==.',['铛那']='铛那个铛:BAAALAAECgYIBgAAAA==.',['锦佑']='锦佑:BAAALAAECgYIBgAAAA==.',['长的']='长的和谐点嘛:BAAALAAECgEIAQAAAA==.',['闪光']='闪光:BAAALAAECgEIAQAAAA==.',['阿尔']='阿尔玟晨星:BAAALAAECgEIAQAAAA==.',['阿牧']='阿牧木:BAABLAAFFH8GAAINAAYI9wSNGgDUAAANAAYI9wSNGgDUAAAAAA==.',['阿皮']='阿皮屁:BAABLAAFFH8FAAILAAMI6gcCQgCFAAALAAMI6gcCQgCFAAAAAA==.',['阿花']='阿花:BAAALAAECgUIBQAAAA==.',['阿萨']='阿萨斯之父:BAAALAAECgIIAgAAAA==.',['阿采']='阿采:BAAALAAECgMIAwAAAA==.',['阿锦']='阿锦欧气满满:BAACLAAFFH8gAAMJAAYIKgpcEgAjAQAJAAYIKgpcEgAjAQAcAAEIJgchHgAAAAAsAAQKfykABAkACAgtFyMWAAcCAAkACAj2FiMWAAcCABwABghGD/Q8AEQBAB0AAQhhBFdYACEAAAAA.',['随风']='随风起舞:BAABLAAFFH8HAAICAAIIAxR7QACAAAACAAIIAxR7QACAAAAAAA==.',['雪莉']='雪莉酒:BAABLAAFFH8LAAICAAQI/xhDKQAaAQACAAQI/xhDKQAaAQAAAA==.',['零六']='零六叁:BAAALAAFFAIIAgAAAA==.',['雷电']='雷电法王:BAAALAAFFAIIAgAAAA==.',['雾里']='雾里看:BAAALAAECgMIAwAAAA==.',['风帆']='风帆:BAABLAAFFH8GAAIDAAYIogvAOABYAQADAAYIogvAOABYAQAAAA==.',['风流']='风流小德糖:BAAALAAECgQICAAAAA==.风流木棉糖:BAAALAAFFAIIAgAAAA==.风流棉花糖:BAAALAAECgIIAgAAAA==.风流牛奶糖:BAAALAAFFAIIBAAAAA==.风流跳跳糖:BAAALAAFFAEIAQAAAA==.风流麦芽糖:BAAALAAECgQIBAAAAA==.',['鬼月']='鬼月神:BAABLAAECn8XAAILAAgIMBCwmQCXAQALAAgIMBCwmQCXAQAAAA==.',['鬼泣']='鬼泣剑风:BAACLAAFFH8JAAIeAAIIyBAxMAAzAAAeAAIIyBAxMAAzAAAsAAQKfyAAAh4ACAiMHJccAE0CAB4ACAiMHJccAE0CAAAA.',['鬼舞']='鬼舞辻無惨:BAAALAAECgYIDwAAAA==.',['魔鬼']='魔鬼小辣椒:BAACLAAFFH8ZAAMUAAYIvR6DDABGAQAUAAMIRCaDDABGAQAfAAQI8xm1DADHAAAsAAQKfzgAAx8ACAjBJQsBAHEDAB8ACAguJQsBAHEDABQABAhjH0QRAFEBAAAA.',['魔龙']='魔龙之芯:BAAALAAECgYIEAAAAA==.',['黄帝']='黄帝术:BAABLAAFFH8MAAIgAAYIzhV2EQDYAQAgAAYIzhV2EQDYAQAAAA==.',['黑心']='黑心肺:BAAALAAECgIIAgAAAA==.',['黑暗']='黑暗圣歌:BAAALAAECgIIAgAAAA==.',['龙猫']='龙猫:BAAALAADCgEIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end