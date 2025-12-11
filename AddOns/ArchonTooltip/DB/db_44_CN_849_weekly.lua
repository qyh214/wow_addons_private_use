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
 local lookup = {'Druid-Balance','Druid-Restoration','DeathKnight-Frost','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','Warrior-Fury','DemonHunter-Havoc','Paladin-Retribution','DeathKnight-Blood','Monk-Mistweaver','Monk-Windwalker','Priest-Holy','Mage-Arcane','Mage-Frost','Warlock-Destruction','Paladin-Holy','Shaman-Elemental','Monk-Brewmaster','Warrior-Protection','Warlock-Affliction','Mage-Fire','Warlock-Demonology','Druid-Feral','Paladin-Protection',}; local provider = {region='CN',realm='迪瑟洛克',name='CN',type='weekly',zone=44,date='2025-12-08',data={Al='Alexander:BAAALAAECgYIBgAAAA==.Alison:BAAALAAECgYIBgAAAA==.',Bl='Bloobloody:BAAALAAECgYIBgAAAA==.',Co='Coriander:BAACLAAFFH8VAAMBAAUIlhMpEADxAAABAAUIlhMpEADxAAACAAEIFQFfUwAiAAAsAAQKfy0AAwEACAi7ICATAM8CAAEACAi7ICATAM8CAAIABggmDZKHAAwBAAAA.',Ha='Hannibal:BAACLAAFFH8QAAMDAAIIayU2MADaAAADAAIIayU2MADaAAAEAAEI+ReMGwBVAAAsAAQKfyoAAwMACAgwJfsHAFsDAAMACAgwJfsHAFsDAAQAAgj/HGFIAJ8AAAAA.',Je='Jessicacheng:BAAALAADCggIEAAAAA==.',['一叶']='一叶乄知秋:BAAALAAECgQIBAAAAA==.',['一月']='一月一号:BAAALAADCgYICwAAAA==.',['一矢']='一矢光明:BAABLAAFFH8GAAMFAAYIRhV8BgBrAQAFAAQIQhN8BgBrAQAGAAIITxlJDgCtAAAAAA==.',['七彩']='七彩翔云:BAAALAAECgMIAwAAAA==.',['三条']='三条唉丝:BAAALAAECgEIAQAAAA==.',['不懂']='不懂浪漫:BAAALAADCggICAAAAA==.',['丨栗']='丨栗子丨:BAABLAAECn8bAAMHAAgIchfzOwDIAQAHAAcIYhjzOwDIAQAIAAIIRgsoiwFKAAAAAA==.',['丶烈']='丶烈风:BAAALAAECgYIBgAAAA==.',['为时']='为时已晚:BAABLAAFFH8OAAIJAAYIphDOIQBRAQAJAAYIphDOIQBRAQAAAA==.',['乌鸦']='乌鸦哥:BAABLAAFFH8GAAIKAAYIkATNKgAWAQAKAAYIkATNKgAWAQAAAA==.',['乔巴']='乔巴船长:BAAALAAFFAIIBAAAAA==.',['二点']='二点哥:BAAALAADCgMIAwAAAA==.',['云中']='云中轻舞:BAABLAAFFH8GAAILAAIIqQ5UUABJAAALAAIIqQ5UUABJAAAAAA==.',['云声']='云声:BAAALAADCgEIAQAAAA==.',['云朵']='云朵朵:BAABLAAFFH8IAAICAAII1RNqNABsAAACAAII1RNqNABsAAAAAA==.',['亚特']='亚特丶兰宙斯:BAAALAAECgEIAQAAAA==.',['伊人']='伊人耳边话:BAAALAAECggIDgAAAA==.',['伊泽']='伊泽:BAABLAAFFH8HAAIMAAMIIxNTGgDyAAAMAAMIIxNTGgDyAAAAAA==.',['休闲']='休闲的大领主:BAAALAADCgYIBgAAAA==.休闲的猎手:BAAALAADCgQIBQAAAA==.',['余榆']='余榆:BAACLAAFFH85AAILAAcI/iPiBgBsAgALAAcI/iPiBgBsAgAsAAQKf0IAAgsACAgWJiIEAHYDAAsACAgWJiIEAHYDAAAA.',['你过']='你过来啊:BAAALAAECgUIBQAAAA==.',['兽大']='兽大王:BAABLAAFFH8hAAIIAAYITh5oHwC3AQAIAAYITh5oHwC3AQAAAA==.',['冬云']='冬云儿:BAABLAAFFH8IAAIIAAIIuwnoswA1AAAIAAIIuwnoswA1AAAAAA==.',['冬末']='冬末雪霁:BAAALAAECggICAABLAAFFAcIPgACAEkiAA==.',['冯二']='冯二狗:BAABLAAFFH8IAAIIAAIIWBm+VACTAAAIAAIIWBm+VACTAAAAAA==.',['出月']='出月清风:BAACLAAFFH8rAAILAAcIDBgPDgD1AQALAAcIDBgPDgD1AQAsAAQKfx8AAgsACAiVIL8vAJ0CAAsACAiVIL8vAJ0CAAAA.',['午夜']='午夜屠姬:BAABLAAFFH8oAAMEAAYIdB1vAgB+AQANAAUIahb2BQCGAQAEAAUIzh5vAgB+AQAAAA==.',['卡洛']='卡洛北鳯:BAAALAAECgYIBgAAAA==.',['变啊']='变啊变:BAAALAAECgYIEwAAAA==.',['口袋']='口袋里的口袋:BAAALAAECgYIBgAAAA==.',['向剑']='向剑底斩桃花:BAAALAAECgYIEAAAAA==.',['吮指']='吮指原味鸡:BAAALAAFFAIIBAABLAAFFAgIBgADALoRAA==.',['周扒']='周扒皮:BAAALAADCgMIAwAAAA==.',['哈哩']='哈哩路呀:BAABLAAFFH8FAAIMAAMIMgz8SwBpAAAMAAMIMgz8SwBpAAAAAA==.',['嘬嘬']='嘬嘬:BAAALAADCgYIBgAAAA==.',['图腾']='图腾医逝:BAAALAAECgYIBgAAAA==.',['土地']='土地爷:BAABLAAFFH8GAAMOAAYIgwJZFAB7AAAOAAQIEAJZFAB7AAAPAAIItQN+FABLAAAAAA==.',['基督']='基督山伯爵:BAAALAAECgIIAgAAAA==.',['塔哚']='塔哚哩亚:BAAALAADCgQIBwAAAA==.',['大弯']='大弯刀:BAAALAAECgQIBAAAAA==.',['天堂']='天堂在我身后:BAABLAAFFH8LAAIKAAMI/w56PACBAAAKAAMI/w56PACBAAAAAA==.',['天驱']='天驱若若:BAACLAAFFH8OAAIQAAUIOBNzDQB2AQAQAAUIOBNzDQB2AQAsAAQKfxcAAhAABwhyGws4APsBABAABwhyGws4APsBAAAA.',['头发']='头发不少:BAAALAAECggICAAAAA==.',['奇葩']='奇葩猫:BAAALAAECgQIBgAAAA==.',['奥特']='奥特曼打怪兽:BAAALAADCgQIBAAAAA==.',['姬亭']='姬亭:BAACLAAFFH8bAAMHAAYItBzYCwAyAQAIAAYIQxvBKgCMAQAHAAQIBhbYCwAyAQAsAAQKfxQAAgcACAgpG6caAI8CAAcACAgpG6caAI8CAAAA.',['完美']='完美熊猫:BAACLAAFFH88AAIQAAcIXRQJDACPAQAQAAcIXRQJDACPAQAsAAQKf0EAAhAACAiIG48lAFgCABAACAiIG48lAFgCAAAA.',['客户']='客户二:BAAALAAFFAMIAwAAAA==.客户四:BAAALAAECgEIAgAAAA==.',['宫崎']='宫崎美橞:BAABLAAECn8lAAMOAAgIoA19JQB5AQAOAAgIoA19JQB5AQAPAAUIFwgsTwDWAAAAAA==.',['寒衣']='寒衣伴楚歌:BAACLAAFFH8cAAIMAAYI0xvQCwCoAQAMAAYI0xvQCwCoAQAsAAQKfxgAAgwACAj7G1QxAK0CAAwACAj7G1QxAK0CAAAA.',['小仔']='小仔崽丶:BAAALAAECgUIBQAAAA==.',['小媳']='小媳妇坐莲:BAAALAAECgYIBgAAAA==.',['小小']='小小大口袋:BAAALAADCgQIBAAAAA==.',['小布']='小布蕾:BAAALAAFFAIIAgAAAA==.',['小红']='小红手霸气丶:BAABLAAFFH8HAAMRAAIIsBfjSQCWAAARAAIIGQ/jSQCWAAASAAEIUCRCGwBlAAAAAA==.',['小胖']='小胖子德德:BAAALAAFFAEIAQAAAA==.',['少年']='少年游:BAABLAAFFH8IAAITAAYIzwakPgAFAQATAAYIzwakPgAFAQAAAA==.',['帕拉']='帕拉甲:BAABLAAFFH8RAAIUAAgInxXMAwB3AgAUAAgInxXMAwB3AgAAAA==.',['幽冥']='幽冥圣光:BAAALAAFFAIIBAAAAA==.幽冥武灵:BAAALAAFFAIIAgAAAA==.幽冥神罚:BAABLAAFFH8MAAIMAAQIQBV+NADjAAAMAAQIQBV+NADjAAAAAA==.幽冥精灵:BAAALAAFFAIIAgAAAA==.幽冥邪皇:BAABLAAFFH8KAAIDAAQIlAQ4WACnAAADAAQIlAQ4WACnAAAAAA==.幽冥雲飛:BAAALAAFFAIIAgAAAA==.幽冥魔龍:BAAALAAFFAIIBAAAAA==.',['德不']='德不常湿:BAAALAAECgIIAgAAAA==.',['心有']='心有所悟:BAAALAAECgYIBgAAAA==.',['心若']='心若琉璃:BAAALAAECgYIBwAAAA==.',['心跳']='心跳滴回忆:BAAALAAECgQIBQAAAA==.',['恶模']='恶模劣狩:BAAALAAECgYIBgAAAA==.',['懵德']='懵德:BAAALAAFFAIIAgABLAAFFAcINgAVAF0iAA==.',['我代']='我代表小的:BAAALAAECgEIAQAAAA==.',['我冲']='我冲啦:BAAALAAECgIIAgAAAA==.',['我按']='我按了呀:BAABLAAFFH8KAAIIAAYICQdYUwAFAQAIAAYICQdYUwAFAQAAAA==.',['扎布']='扎布瑞尔:BAABLAAFFH8nAAMWAAgIix1XAgB+AgAWAAgIAR1XAgB+AgAPAAUI3hSJBAC+AQAAAA==.',['托儿']='托儿所罒总裁:BAAALAAECgQICAAAAA==.',['拉布']='拉布拉多糖:BAABLAAFFH8FAAITAAUIAwJYSgCTAAATAAUIAwJYSgCTAAAAAA==.',['新基']='新基督山伯爵:BAAALAAECgYIEQAAAA==.',['无为']='无为:BAAALAAECgYIEgAAAA==.',['时遇']='时遇:BAAALAAECgQIBAAAAA==.',['暗燃']='暗燃空蓝:BAAALAAECgYIBgAAAA==.',['暴风']='暴风元素:BAAALAAECgYIBgAAAA==.',['月之']='月之慕情:BAAALAAECgIIAgAAAA==.',['月清']='月清疏:BAAALAAFFAIIAwAAAA==.',['木兰']='木兰辞:BAAALAAECgYIBgAAAA==.',['桃白']='桃白白:BAAALAADCgYIBgAAAA==.',['橙真']='橙真:BAABLAAFFH8IAAIXAAII1hBeIAB9AAAXAAII1hBeIAB9AAAAAA==.',['欲买']='欲买桂花载酒:BAAALAAECgYIBwAAAA==.',['死神']='死神不乖:BAAALAAECgUIBQAAAA==.',['没钱']='没钱花:BAAALAAFFAIIBAAAAA==.',['沫年']='沫年:BAABLAAFFH8HAAIQAAMI9REoJwCcAAAQAAMI9REoJwCcAAAAAA==.',['油腻']='油腻的师姐丶:BAACLAAFFH8qAAMDAAcITx8KEADUAQADAAcITx8KEADUAQAEAAEIHw7fEABRAAAsAAQKfxsAAgMACAgyJUgLAEoDAAMACAgyJUgLAEoDAAAA.',['法力']='法力玲珑:BAAALAAECgYICQAAAA==.',['波特']='波特卡斯艾斯:BAACLAAFFH8pAAIRAAcIOCAtDwAFAgARAAcIOCAtDwAFAgAsAAQKfyEAAxEABwh1IWE2AHECABEABwh1IWE2AHECABIABQhPGzpYABQBAAAA.',['流星']='流星:BAAALAAECgEIAQAAAA==.',['浊白']='浊白:BAACLAAFFH8+AAITAAcIQSTNCgBVAgATAAcIQSTNCgBVAgAsAAQKf0EAAxMACAhtJVAFAGwDABMACAhtJVAFAGwDABgAAwhbDW0oAKUAAAAA.',['浮生']='浮生若梦丶:BAABLAAFFH8GAAIJAAIIThnWRwB0AAAJAAIIThnWRwB0AAABLAAFFAIIEAADAGslAA==.',['淼焱']='淼焱追命:BAAALAADCgEIAQAAAA==.',['清风']='清风拂山岗:BAAALAAFFAIIBAAAAA==.',['湖南']='湖南米粉:BAAALAADCgEIAQAAAA==.',['潶丶']='潶丶祸:BAAALAAECgUIBQAAAA==.',['火花']='火花泡泡:BAAALAADCgYIBgAAAA==.',['灰烬']='灰烬使者:BAAALAAECgQIBAAAAA==.',['烈暮']='烈暮壮:BAAALAAECgUIBQAAAA==.',['热心']='热心网友艳儿:BAAALAAECggIDAAAAA==.',['热星']='热星网友小成:BAAALAAECgUIBQAAAA==.',['熊大']='熊大王:BAABLAAFFH8eAAMJAAYIVRgBGgCOAQAJAAUIXBsBGgCOAQAVAAUIkwh9KQD8AAAAAA==.',['熊猫']='熊猫烧香丶:BAABLAAFFH8LAAIDAAUINQzuSQARAQADAAUINQzuSQARAQAAAA==.',['爆血']='爆血丶:BAAALAAECgMIAwAAAA==.',['爱不']='爱不够的妖精:BAAALAAECgYICwAAAA==.',['牛大']='牛大王:BAABLAAFFH8bAAMCAAYIUxs/DgDbAQACAAYIUxs/DgDbAQABAAUIhw8oGgAIAQAAAA==.',['牛排']='牛排爱罐头:BAAALAADCgIIAgAAAA==.',['牛牛']='牛牛功德无量:BAABLAAFFH8TAAMJAAYIox+5CwAXAgAJAAYIox+5CwAXAgAVAAEItAp8RQBDAAAAAA==.牛牛呀:BAABLAAFFH8SAAMRAAYIJCFUFQDUAQARAAYIJCFUFQDUAQAZAAYImxDMAwBcAQAAAA==.',['狂怒']='狂怒的灭世者:BAAALAAECgYIBQAAAA==.',['独孤']='独孤小强:BAAALAAECgYICwAAAA==.',['猎德']='猎德:BAABLAAFFH8GAAIIAAYIchLZCwDZAQAIAAYIchLZCwDZAQAAAA==.',['猜猜']='猜猜我是谁:BAAALAADCgUIBAAAAA==.',['猪二']='猪二妹:BAAALAAFFAEIAQAAAA==.',['猪是']='猪是念来着倒:BAAALAADCggICAAAAA==.',['猪肉']='猪肉炖粉条:BAAALAAECgMIBAAAAA==.',['玄霄']='玄霄:BAAALAAFFAMIAwAAAA==.',['珍藏']='珍藏版沫沫:BAAALAAECgMIAwAAAA==.',['瑜于']='瑜于鱼:BAAALAAECgYICwAAAA==.',['璀璨']='璀璨火花:BAABLAAFFH8GAAIRAAIIWwgSWgCFAAARAAIIWwgSWgCFAAAAAA==.',['白花']='白花恋诗:BAABLAAFFH8PAAIJAAYIQxTTIQBRAQAJAAYIQxTTIQBRAQAAAA==.',['皮特']='皮特:BAAALAADCggICAAAAA==.',['盲流']='盲流子不尿炕:BAAALAAECgIIAgAAAA==.',['真的']='真的我不骗你:BAAALAAECgIIAgAAAA==.',['石头']='石头汤:BAAALAAECgQIBAAAAA==.',['祖国']='祖国小花朵:BAAALAAFFAIIBAAAAA==.',['神邸']='神邸丶:BAAALAADCgQIBAAAAA==.神邸灬:BAACLAAFFH8YAAIDAAUIwhNBFwCIAQADAAUIwhNBFwCIAQAsAAQKfyEAAgMABwhVG+pyABECAAMABwhVG+pyABECAAAA.',['稀有']='稀有精英夜猫:BAAALAAECgYICQAAAA==.',['立正']='立正:BAAALAAECgYIBgAAAA==.',['粉色']='粉色奶油布丁:BAAALAAFFAIIBAAAAA==.',['紫月']='紫月雪儿:BAAALAAECgMIAwAAAA==.',['红双']='红双喜:BAAALAADCggICAAAAA==.',['红杏']='红杏又出墙:BAAALAAECgUICAAAAA==.',['红烧']='红烧大鹌鹑:BAAALAADCggICAAAAA==.',['给你']='给你一刀:BAAALAAECgMIBQAAAA==.',['绝版']='绝版菜鸟:BAACLAAFFH8xAAIKAAcI+iH8BwA8AgAKAAcI+iH8BwA8AgAsAAQKfzYAAgoACAgVJrADAHcDAAoACAgVJrADAHcDAAAA.',['缄绪']='缄绪:BAAALAAECgYIDAAAAA==.',['羅曼']='羅曼羅籣:BAAALAADCggIBgAAAA==.',['羽燃']='羽燃:BAAALAAECgYIBgAAAA==.',['老汉']='老汉会推大车:BAAALAAFFAIIAwAAAA==.',['耐在']='耐在西元前:BAAALAAECgIIAgAAAA==.',['肉丸']='肉丸胡辣汤:BAAALAADCggICwAAAA==.',['肉夹']='肉夹馍之神:BAAALAAECgcIDAAAAA==.',['艾格']='艾格温:BAAALAAECgIIBAAAAA==.',['莉妮']='莉妮西娅:BAAALAAECgQICAAAAA==.',['莉莉']='莉莉芙儿:BAAALAAECgIIAgAAAA==.',['菱梦']='菱梦纱璃:BAACLAAFFH8KAAITAAYIWw20OgAhAQATAAYIWw20OgAhAQAsAAQKfyQAAxMACAgUHTAlALMCABMACAgUHTAlALMCABoABAh4EnljAOkAAAAA.',['萨丨']='萨丨蓝凌飛:BAAALAADCgYIDQAAAA==.',['萨勒']='萨勒芬妮:BAAALAAFFAIIAwAAAA==.',['萨拉']='萨拉塔斯的狗:BAAALAAECgYIEwAAAA==.',['萨爽']='萨爽阴滋:BAAALAAFFAIIAgAAAA==.',['萨琪']='萨琪玛:BAAALAAFFAIIBAAAAA==.',['萬箭']='萬箭皈空:BAAALAAECgQIBAAAAA==.',['葳蕤']='葳蕤菡萏:BAAALAADCgYIBgAAAA==.',['蓝宝']='蓝宝石西梅派:BAAALAADCggICAAAAA==.',['虾仁']='虾仁不眨眼:BAABLAAECn8lAAIHAAgIcSBGEADhAgAHAAgIcSBGEADhAgAAAA==.',['蛇朋']='蛇朋:BAABLAAFFH8MAAQBAAYIahIfBgDoAQABAAYIrREfBgDoAQACAAIIDhsPNgCTAAAbAAIITBmGDABOAAAAAA==.',['血之']='血之伤一怒风:BAAALAAECgYICQAAAA==.',['西直']='西直门三太子:BAABLAAFFH8GAAIKAAIISQlNQgCKAAAKAAIISQlNQgCKAAAAAA==.',['请叫']='请叫我可爱多:BAAALAAECgMIAwAAAA==.',['谈笑']='谈笑风生丶:BAAALAAECgEIAQAAAA==.',['贰十']='贰十七:BAAALAAECgQIBAAAAA==.',['贰奶']='贰奶奶:BAACLAAFFH8PAAIJAAQI3haVLgD6AAAJAAQI3haVLgD6AAAsAAQKfx0AAgkACAi+HHUuAFkCAAkACAi+HHUuAFkCAAAA.',['赵无']='赵无极:BAABLAAECn8UAAIXAAcITRkyFACpAQAXAAcITRkyFACpAQAAAA==.',['过来']='过来乖一点:BAAALAAFFAIIAgAAAA==.',['迪凯']='迪凯:BAAALAAECgYIBgAAAA==.',['邪能']='邪能机甲:BAAALAADCgMIAwAAAA==.',['野森']='野森海:BAAALAAECgQIBAAAAA==.野森炫海:BAABLAAECn8VAAMcAAgIWRchIwDjAQAcAAYILhwhIwDjAQAUAAgIAxDKFwCXAQAAAA==.',['阿兹']='阿兹卡班囚徒:BAAALAAECgQIBAAAAA==.',['阿冬']='阿冬吖:BAABLAAFFH8HAAIKAAcIWxjzCgAJAgAKAAcIWxjzCgAJAgAAAA==.',['阿撒']='阿撒托斯:BAAALAAECgEIAQAAAA==.',['青古']='青古甜子:BAAALAAECgUICQAAAA==.',['面对']='面对疾风吧:BAAALAADCgEIAQAAAA==.',['颓废']='颓废的干饭:BAAALAAECgMIAwAAAA==.',['風晴']='風晴雪:BAAALAAECgYIBgAAAA==.',['风中']='风中轻舞:BAACLAAFFH8GAAMSAAIIoRc8FwBBAAASAAIIoRc8FwBBAAARAAEIUQAbcAAAAAAsAAQKfxwAAxIACAh6F2QbAEkBABIABwiiGWQbAEkBABEABAgUCa9hAHoAAAAA.',['风儿']='风儿:BAAALAADCgEIAQAAAA==.',['风吹']='风吹过夏天:BAAALAADCgEIAQAAAA==.',['风起']='风起云飞扬:BAABLAAFFH8HAAIMAAYIWwxOJABSAQAMAAYIWwxOJABSAQAAAA==.',['飞扬']='飞扬的可乐:BAAALAAECgYIDgAAAA==.',['香辣']='香辣钵钵鸡:BAAALAAFFAEIAQAAAA==.',['鸡脚']='鸡脚趾:BAAALAAECgYIBwAAAA==.',['鸡蛋']='鸡蛋之怒:BAAALAADCgMIAwAAAA==.',['麦德']='麦德安:BAAALAAFFAIIAgAAAA==.',['黄皮']='黄皮沙法:BAAALAADCgYIBgAAAA==.',['龍伈']='龍伈云:BAAALAAECgYICQAAAA==.',['龙大']='龙大王:BAAALAAECgMIAwAAAA==.',['龟仙']='龟仙人:BAABLAAFFH8FAAIJAAIIWQI2bABTAAAJAAIIWQI2bABTAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end