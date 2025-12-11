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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Mage-Arcane','DeathKnight-Frost','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Paladin-Retribution','DemonHunter-Havoc','Mage-Fire','Druid-Feral','Shaman-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Protection','Warrior-Fury','Druid-Balance','Paladin-Holy','Shaman-Elemental','Monk-Windwalker','Unknown-Unknown','DeathKnight-Unholy','Hunter-Survival','Druid-Restoration','Monk-Brewmaster','Rogue-Assassination',}; local provider = {region='CN',realm='托尔巴拉德',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ae='Aeiou:BAAALAAECgIIAgAAAA==.',Ar='Aresiphe:BAAALAAECggIEAAAAA==.',As='Astra:BAABLAAFFH8MAAMBAAYIPSHjEQD8AQABAAYIPSHjEQD8AQACAAYI5BGZBwBOAQAAAA==.',Ba='Babayaga:BAAALAADCggICAAAAA==.',Be='Berumotto:BAAALAADCgEIAQAAAA==.',Br='Breach:BAABLAAFFH8GAAICAAYIOQzkCAArAQACAAYIOQzkCAArAQAAAA==.Brimstone:BAABLAAFFH8UAAIBAAgIJhrkCQBDAgABAAgIJhrkCQBDAgAAAA==.',Ch='Chamber:BAABLAAFFH8IAAIBAAgIfB/EBQCOAgABAAgIfB/EBQCOAgAAAA==.',Cl='Claudialol:BAAALAAECgIIAgAAAA==.',Da='Darkwarrior:BAAALAAECgcICAAAAA==.',Gl='Glolin:BAAALAADCggIEwAAAA==.',Ha='Hannari:BAAALAADCgUIBQAAAA==.',He='Heyspirit:BAAALAADCggICAAAAA==.',Io='Ioonvition:BAAALAAECgYIBgAAAA==.',Je='Jett:BAAALAAFFAgIAgAAAA==.',Ka='Kayo:BAABLAAFFH8SAAIBAAgIUSGZAwC+AgABAAgIUSGZAwC+AgAAAA==.',Lo='Louiselys:BAAALAAECgYIEgAAAA==.',Mo='Move:BAACLAAFFH8eAAMDAAUIWCDpBAB9AQADAAUIWCDpBAB9AQAEAAIIUQ1vUgCOAAAsAAQKfyIAAwMACAjMI/YKAOsCAAMACAhKIvYKAOsCAAQABQgFH0aLAHcBAAAA.',Ne='Neon:BAABLAAFFH8GAAIBAAYIIhHBQwA6AQABAAYIIhHBQwA6AQAAAA==.',Ni='Nibusiwude:BAAALAADCgcIBwAAAA==.',Ph='Phyn:BAAALAAFFAIIAgAAAA==.',Ra='Raze:BAABLAAFFH8GAAIBAAYIniAcFgDiAQABAAYIniAcFgDiAQAAAA==.',So='Somnusyiyily:BAAALAAECgMIAwAAAA==.',Th='Theoldone:BAAALAADCgQIBAAAAA==.Threedeer:BAAALAADCgMIBgAAAA==.',Ti='Tilta:BAAALAAECgQICAAAAA==.',Un='Una:BAAALAAECggICgAAAA==.',Vo='Vorika:BAAALAAECgEIAQAAAA==.',Yo='Yoru:BAAALAAFFAgIAQAAAA==.',['七六']='七六出溜:BAAALAAECgYICQAAAA==.',['三加']='三加五去二:BAAALAAECgQIBAAAAA==.',['不吃']='不吃亏:BAAALAAECgYIEAAAAA==.',['不期']='不期而遇我:BAACLAAFFH8JAAIFAAIIih2AXgCZAAAFAAIIih2AXgCZAAAsAAQKfx8AAwUABggvI5AtAL8BAAUABggvI5AtAL8BAAYAAgiuD9gpAGIAAAAA.',['不着']='不着调小圣:BAAALAAECgQIBAAAAA==.',['不说']='不说话:BAAALAAECgIIAgAAAA==.',['不顺']='不顺眼:BAABLAAECn8YAAIFAAgIpxMSgwD1AQAFAAgIpxMSgwD1AQAAAA==.',['专打']='专打没成年:BAAALAAECgcIEgAAAA==.',['两撇']='两撇小胡子:BAAALAADCgEIAQAAAA==.',['丨丶']='丨丶筱依然:BAABLAAFFH8HAAIFAAIIthJIeQBJAAAFAAIIthJIeQBJAAAAAA==.',['丨猫']='丨猫内灬:BAAALAADCgYIBgAAAA==.',['中年']='中年白富美:BAAALAAECgYIBgAAAA==.',['丹总']='丹总啊:BAAALAAFFAQIBAAAAA==.',['丿夜']='丿夜丶允儿灬:BAABLAAFFH8IAAMHAAYIyR6rBgD4AQAHAAUIiR6rBgD4AQAIAAMIvxUzOACAAAAAAA==.丿夜丶舞曲:BAABLAAFFH8IAAIJAAIIIBrYJADBAAAJAAIIIBrYJADBAAAAAA==.',['丿承']='丿承蒙有幸丶:BAAALAADCggICAAAAA==.',['丿拾']='丿拾捌火:BAAALAADCgYIBgAAAA==.',['乂氼']='乂氼:BAABLAAFFH8MAAMCAAYIyhlDCQB6AQACAAUInhVDCQB6AQABAAYIJBgLMgBxAQAAAA==.',['乄糖']='乄糖丶子:BAAALAAECgcIBwAAAA==.',['九色']='九色龙王:BAAALAAECgcIEAAAAA==.',['云知']='云知男:BAAALAADCgUIBQAAAA==.',['人形']='人形传送门:BAAALAADCgEIAQAAAA==.',['人红']='人红橙多:BAABLAAFFH8MAAIJAAII+xRbSwCWAAAJAAII+xRbSwCWAAAAAA==.',['仓本']='仓本麻衣:BAABLAAFFH8IAAIEAAIIyBArXAA/AAAEAAIIyBArXAA/AAAAAA==.',['伴读']='伴读小书童:BAACLAAFFH8IAAIFAAII6xObgQBFAAAFAAII6xObgQBFAAAsAAQKfyMAAgUACAgeHywQAGsCAAUACAgeHywQAGsCAAAA.',['佐妈']='佐妈妈:BAAALAAFFAIIBAAAAA==.',['你是']='你是我的宝贝:BAAALAAECgYIBgAAAA==.',['你的']='你的相好:BAACLAAFFH8GAAIBAAIIzQ0/ZwCGAAABAAIIzQ0/ZwCGAAAsAAQKfyIAAwIACAhDIREXAKoCAAIACAgaHxEXAKoCAAEABgiLIAtWAJcBAAAA.',['依然']='依然心痛:BAABLAAFFH8IAAIFAAIInQgUkwA9AAAFAAIInQgUkwA9AAAAAA==.',['信仰']='信仰叉叉:BAAALAADCgEIAQAAAA==.信仰恶魔:BAAALAADCgMIAwAAAA==.',['克拉']='克拉克休:BAAALAADCggICAABLAAFFAIICAAKAEgPAA==.',['冰奥']='冰奥火之魂:BAAALAADCgIIAgAAAA==.',['几斤']='几斤几两:BAABLAAECn8XAAQDAAYIzRZdGABiAQADAAYIwxZdGABiAQAEAAYIvwWzvgD7AAALAAEIsAELKQAVAAAAAA==.',['分车']='分车溜溜的转:BAAALAAFFAIIBAAAAA==.',['别闹']='别闹别闹:BAAALAADCgYIBgAAAA==.',['剑廿']='剑廿叁:BAAALAAFFAIIAgAAAA==.',['努力']='努力的懒猫:BAABLAAFFH8PAAIFAAUIvQtoRgAhAQAFAAUIvQtoRgAhAQAAAA==.',['北之']='北之极致:BAACLAAFFH8IAAIBAAIImQ6NmQBBAAABAAIImQ6NmQBBAAAsAAQKfxQAAgEABghcHSpUAJsBAAEABghcHSpUAJsBAAAA.',['北大']='北大方小公牛:BAAALAAECggICQAAAA==.北大方小猎牛:BAABLAAFFH8GAAMBAAYI3AU+YQC4AAABAAMIYQg+YQC4AAACAAMIVgN/EwBMAAAAAA==.北大方小雌牛:BAAALAAFFAQIBAAAAA==.',['北极']='北极的雨:BAAALAAECgYIEgAAAA==.北极的雪:BAABLAAFFH8GAAIMAAIIewcdEQAyAAAMAAIIewcdEQAyAAAAAA==.',['卡在']='卡在名字:BAAALAAECgYIDgAAAA==.',['卢旺']='卢旺达卖鱼人:BAAALAAECgEIAQAAAA==.',['反手']='反手上膛:BAAALAAECgYIBgAAAA==.',['口袋']='口袋有糖:BAAALAADCggICAAAAA==.',['可怜']='可怜的小无奈:BAAALAADCgQIBAAAAA==.',['吃我']='吃我一击吧:BAAALAAECgcIBwAAAA==.',['吉祥']='吉祥如意:BAABLAAECn8YAAINAAYIjhpdNQCHAQANAAYIjhpdNQCHAQAAAA==.',['君子']='君子丶怒:BAAALAAFFAIIBAAAAA==.',['吥懂']='吥懂夜的黑:BAAALAAECggICAAAAA==.',['吼哟']='吼哟:BAACLAAFFH80AAMOAAgIcx3dCgBRAgAOAAgIcx3dCgBRAgAPAAEIggmeLQBIAAAsAAQKfzIABA4ACAiVIz8TABIDAA4ACAgfIz8TABIDAA8ABQizGCNDAGIBABAAAQifEBg8AEMAAAAA.',['吾乃']='吾乃战神:BAABLAAFFH8UAAMRAAUIZhhiEADKAAARAAUIZhhiEADKAAASAAIIEgvuUQBDAAAAAA==.',['吾道']='吾道即天命:BAAALAAECgYICgAAAA==.',['咕咕']='咕咕小魔仙:BAAALAADCgYIBgAAAA==.',['哈弗']='哈弗茨:BAAALAAECggICAAAAA==.',['唲丶']='唲丶襪:BAAALAADCggICAAAAA==.',['喬芭']='喬芭:BAABLAAFFH8GAAITAAYIAwL1IwCPAAATAAYIAwL1IwCPAAAAAA==.',['嘞噜']='嘞噜的小冲儿:BAAALAAECgYIDAAAAA==.',['噬魂']='噬魂丶猎:BAABLAAFFH8KAAIBAAYICRlXLgB9AQABAAYICRlXLgB9AQAAAA==.',['四修']='四修骑士:BAABLAAFFH8IAAIJAAMIMAdhTQBgAAAJAAMIMAdhTQBgAAAAAA==.',['圖圖']='圖圖:BAAALAADCgEIAQAAAA==.',['土豆']='土豆洋芋饼:BAAALAAFFAIIBAABLAAFFAYIFAAHALgCAA==.',['圣息']='圣息者爱萝米:BAACLAAFFH8SAAIIAAMI9hp8IwCrAAAIAAMI9hp8IwCrAAAsAAQKfxsAAggACAjYIcsTAMsCAAgACAjYIcsTAMsCAAAA.',['埃辛']='埃辛诺亚:BAAALAAFFAIIBAAAAA==.埃辛诺斯乄殇:BAAALAAECggICAAAAA==.',['壹梦']='壹梦:BAAALAADCggICAAAAA==.',['夏禹']='夏禹:BAAALAADCgUIBQAAAA==.',['夜涩']='夜涩幽兰:BAAALAAECggICAABLAAFFAgIDAAUAKUUAA==.',['夜舞']='夜舞灬倾城:BAABLAAFFH8QAAMJAAYIMgjvLAAdAQAJAAYIMgjvLAAdAQAUAAUI4gwbFwAdAQAAAA==.',['大嫂']='大嫂吃梨不:BAAALAAECgIIAgAAAA==.',['大恶']='大恶魔号:BAAALAADCgIIAgAAAA==.',['大来']='大来:BAAALAAECgUIBQAAAA==.',['大白']='大白兎:BAAALAAECgIIAgAAAA==.大白小细腰儿:BAAALAAECgYIEwAAAA==.大白小细腿儿:BAAALAAECgYICgAAAA==.大白小蛮腰儿:BAAALAADCggIDgAAAA==.',['大罐']='大罐可乐:BAAALAADCgUIBQAAAA==.',['天哪']='天哪我真高啊:BAACLAAFFH8IAAIKAAIIlg2bTgCOAAAKAAIIlg2bTgCOAAAsAAQKfywAAgoACAhcIKEfAOQCAAoACAhcIKEfAOQCAAEsAAUUAggIAAoASA8A.',['天堂']='天堂低语:BAAALAADCgIIAgAAAA==.',['奥奥']='奥奥冲:BAAALAAFFAIIAgAAAA==.',['奥黛']='奥黛丽好笨:BAAALAAFFAIIAgAAAA==.',['好吧']='好吧喜庆:BAAALAADCgUIBQAAAA==.',['妖妹']='妖妹儿:BAAALAAECgIIAgAAAA==.',['安妮']='安妮宝贝灬:BAACLAAFFH8VAAIVAAUI3w/CDwCDAQAVAAUI3w/CDwCDAQAsAAQKfx0AAhUACAgZGpI6ABsCABUACAgZGpI6ABsCAAEsAAUUBggoAAEAXyIA.',['对月']='对月而笑:BAAALAADCgEIAQAAAA==.',['射杀']='射杀白头:BAAALAAECgUIBQAAAA==.',['小七']='小七灬:BAAALAAFFAIIAgAAAA==.',['小小']='小小法系魂:BAAALAAECgYIEQAAAA==.小小矮子小小:BAAALAAFFAIIBAAAAA==.',['小攀']='小攀攀:BAAALAADCgcIBwAAAA==.',['小法']='小法:BAAALAAECgIIAgAAAA==.',['小熊']='小熊士兵:BAAALAADCgYIBgAAAA==.',['小狼']='小狼雪糕:BAABLAAFFH8GAAIWAAIImhBzEQCRAAAWAAIImhBzEQCRAAAAAA==.',['小鑫']='小鑫要砍人:BAAALAADCgMIAwAAAA==.',['巫师']='巫师:BAAALAADCgcIBwAAAA==.',['布兰']='布兰迪:BAAALAAECggIDQAAAA==.',['年幼']='年幼的弟弟:BAAALAADCgMIAwAAAA==.',['弑杀']='弑杀猎:BAAALAAECgIIAgAAAA==.',['彻子']='彻子的小狸花:BAABLAAFFH8NAAINAAQIthgeJgAwAQANAAQIthgeJgAwAQAAAA==.',['德德']='德德打滴:BAAALAAECgYIEAABLAAFFAgIAwAXAAAAAA==.',['德欲']='德欲:BAAALAAECgYIEAAAAA==.',['心中']='心中的月:BAAALAAECgUIBQAAAA==.',['快雪']='快雪时晴灬:BAAALAADCgYIBgAAAA==.',['恶魔']='恶魔天使:BAABLAAFFH8FAAIKAAUINAE+agA0AAAKAAUINAE+agA0AAAAAA==.',['悟不']='悟不空:BAAALAADCgYICAABLAAFFAIIAgAXAAAAAA==.',['惆怅']='惆怅至极:BAAALAAECgYIBgAAAA==.',['惊鲵']='惊鲵:BAAALAAECgUICAAAAA==.',['打枪']='打枪的狼:BAAALAAECgQIBgAAAA==.',['打牌']='打牌:BAAALAAECgYICQABLAAECgMIAwAXAAAAAA==.',['托尼']='托尼老死:BAAALAAECgcIBwAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8GAAINAAYIBxCsIwBBAQANAAYIBxCsIwBBAQAAAA==.',['抗战']='抗战八十周年:BAAALAAECgYIBwAAAA==.',['按倒']='按倒摸扎扎:BAAALAAECgEIAQAAAA==.',['挖矿']='挖矿的牛:BAAALAAECgcIEAAAAA==.',['撒手']='撒手没:BAAALAAECgYIEgAAAA==.',['放肆']='放肆的小飞:BAABLAAFFH8lAAMFAAYItCDWGwDHAQAFAAYItCDWGwDHAQAYAAEIMwQOIABDAAABLAAFFAgITgACAI0kAA==.',['教父']='教父:BAAALAAECgMIBAAAAA==.',['无名']='无名之辈:BAAALAAECgYIBgAAAA==.',['无情']='无情丶奈奈:BAAALAAECgYIBgAAAA==.',['无敌']='无敌:BAABLAAFFH8HAAIRAAIIeQRPLQBhAAARAAIIeQRPLQBhAAAAAA==.',['无色']='无色无香:BAAALAADCgcIBwAAAA==.',['星屿']='星屿:BAAALAAECgYIBgAAAA==.',['星河']='星河杳杳丶:BAAALAADCggICAAAAA==.',['星辰']='星辰大海:BAAALAADCgYIBgAAAA==.',['春天']='春天里的宅男:BAAALAAECgMIBAAAAA==.',['曉野']='曉野妹子:BAAALAADCgIIAgAAAA==.',['曲奇']='曲奇餠干丶:BAAALAAECgMIAwAAAA==.',['木敏']='木敏:BAAALAAECgEIAQAAAA==.',['木頭']='木頭朲:BAABLAAECn8YAAIBAAYIxBiRhQA/AQABAAYIxBiRhQA/AQAAAA==.',['朱鸢']='朱鸢:BAABLAAFFH8FAAIVAAMIiQJ9IQCqAAAVAAMIiQJ9IQCqAAAAAA==.',['李富']='李富贵儿:BAAALAAFFAIIAgAAAA==.',['李贞']='李贞贤:BAABLAAFFH8GAAIEAAYIMQF9PwC1AAAEAAYIMQF9PwC1AAAAAA==.',['李阿']='李阿不:BAAALAAFFAIIAgAAAA==.',['格兰']='格兰蒂亚:BAAALAAECgIIAgAAAA==.',['桂芳']='桂芳:BAAALAAECgUIBwAAAA==.',['梦中']='梦中的回忆:BAAALAAECgUIBQAAAA==.',['梵伽']='梵伽:BAAALAAECgIIAgAAAA==.',['正在']='正在前往花村:BAAALAADCgYIBgAAAA==.',['毛利']='毛利丶小六郎:BAAALAAECgYIBgAAAA==.',['沁雪']='沁雪嫣然:BAAALAADCgUIBQAAAA==.',['沙漠']='沙漠风暴:BAAALAAECgUIBQAAAA==.',['法桐']='法桐:BAAALAAECgUIBQAAAA==.',['法聖']='法聖:BAAALAAECgYICAAAAA==.',['注定']='注定路过天堂:BAABLAAECn8VAAIZAAYIGB2oCgACAgAZAAYIGB2oCgACAgAAAA==.',['洋丶']='洋丶葱:BAAALAAECgYICQAAAA==.',['消逝']='消逝的油条:BAAALAAECgYICgAAAA==.',['深渊']='深渊之蛙:BAAALAAECgMIAwAAAA==.',['温柔']='温柔丶小飞雪:BAAALAAECgUIBQAAAA==.',['潇湘']='潇湘淋:BAAALAAECgYIBgAAAA==.',['火小']='火小邪郎:BAAALAAECgUIDAAAAA==.',['灬劦']='灬劦灬:BAABLAAFFH8NAAIBAAMIMw3JdgBxAAABAAMIMw3JdgBxAAAAAA==.',['灬小']='灬小渔灬:BAAALAAECgYIEgAAAA==.',['灬落']='灬落寞灬:BAAALAAECgUIBQAAAA==.',['灵魂']='灵魂倡导者:BAAALAAECgYIBgAAAA==.',['烟火']='烟火拾壹:BAAALAADCgYIBgAAAA==.',['烽火']='烽火戏诸侯:BAABLAAFFH8OAAIEAAIIvBpWUgBJAAAEAAIIvBpWUgBJAAAAAA==.',['無鎖']='無鎖囚:BAAALAAECgYICwAAAA==.',['無闗']='無闗焚玥:BAAALAAECgYIDAAAAA==.',['焱燠']='焱燠:BAAALAAECgYIDAAAAA==.',['燃燒']='燃燒嘚胸毛:BAAALAAFFAMIAgAAAA==.',['爱莉']='爱莉希雅:BAABLAAFFH8KAAISAAYIlwgsKQAlAQASAAYIlwgsKQAlAQAAAA==.',['牛老']='牛老师:BAAALAADCgYIBgAAAA==.',['牢萨']='牢萨陛:BAAALAAFFAIIBAAAAA==.',['独上']='独上西楼:BAAALAADCggIBQAAAA==.',['狼人']='狼人米有萨满:BAAALAAECgYICgAAAA==.',['狼灬']='狼灬要有气质:BAABLAAFFH8KAAIBAAIIgBO5nQA/AAABAAIIgBO5nQA/AAAAAA==.',['狼群']='狼群食尸鬼:BAABLAAECn8dAAIJAAgI3xWbgQDpAQAJAAgI3xWbgQDpAQAAAA==.',['猎获']='猎获:BAAALAADCgIIAgAAAA==.',['猫骨']='猫骨头:BAAALAAECgIIAgAAAA==.',['珍珠']='珍珠大宝贝:BAAALAAECgYIBgAAAA==.珍珠菠萝包:BAAALAAECgYIBgAAAA==.',['甜梨']='甜梨的小茉莉:BAAALAAECgYIBgAAAA==.',['生姜']='生姜红糖:BAAALAAECgYIBgAAAA==.',['电弧']='电弧匍行者:BAAALAADCgIIAgAAAA==.',['疑似']='疑似高手:BAAALAAECgYIBgAAAA==.',['白夜']='白夜丶:BAAALAADCgEIAQAAAA==.',['白岚']='白岚谛:BAAALAAFFAIIBAAAAA==.',['白虹']='白虹:BAAALAAECgYIDgAAAA==.',['百变']='百变星軍:BAAALAAECgQIBAAAAA==.',['百花']='百花盛放:BAAALAADCgYIBgAAAA==.',['破冰']='破冰船:BAAALAAECgYIBgAAAA==.',['碧玉']='碧玉石:BAAALAAECgMIBAAAAA==.',['神农']='神农:BAABLAAFFH8KAAMaAAIIGgi/TwBUAAAaAAIIGgi/TwBUAAATAAIIzgpINgA5AAAAAA==.',['秋丨']='秋丨僧:BAABLAAECn8UAAMbAAYIiRiiHQCuAQAbAAYIiRiiHQCuAQAWAAYIjQfJTADmAAAAAA==.秋丨恶魔:BAABLAAECn8aAAIKAAYIcRsVbQDsAQAKAAYIcRsVbQDsAQAAAA==.',['秦月']='秦月吟:BAABLAAFFH8GAAMIAAIIJwN9SQBWAAAIAAIIJwN9SQBWAAAHAAEIxACCNQAAAAAAAA==.',['空山']='空山溪雨:BAAALAAECgYIBgAAAA==.',['窃月']='窃月者贝芙宁:BAAALAAECggIDAAAAA==.',['筱飛']='筱飛雪児:BAAALAAECgYICAAAAA==.',['篱笆']='篱笆女人和狗:BAAALAAECgYICAAAAA==.',['米达']='米达伦裁决者:BAAALAAECgYIBgAAAA==.',['素颜']='素颜灬:BAAALAADCggICQAAAA==.',['紫歆']='紫歆:BAAALAADCggIDwAAAA==.',['红莲']='红莲超新星龙:BAAALAAECgMIAwAAAA==.',['纳芙']='纳芙蒂蒂:BAABLAAECn8XAAIJAAgIrQvH0ABwAQAJAAgIrQvH0ABwAQAAAA==.',['老醋']='老醋灬花生:BAABLAAECn8UAAIUAAYILhRoHABlAQAUAAYILhRoHABlAQAAAA==.',['耐澳']='耐澳俎导师:BAAALAAECgIIAgAAAA==.',['脱罪']='脱罪:BAAALAAECgUIBQAAAA==.',['至暗']='至暗夜之子:BAAALAAECgYIDQAAAA==.',['艾塔']='艾塔利亚:BAAALAAECggIDgABLAAFFAgIBwAbAPwWAA==.',['艾米']='艾米丽语风:BAAALAAECgQIBAAAAA==.',['芝华']='芝华士丶:BAABLAAFFH8OAAIcAAgIWSFwAQCuAgAcAAgIWSFwAQCuAgAAAA==.',['芝士']='芝士雪豹:BAAALAADCggICAAAAA==.',['花满']='花满心亦满楼:BAABLAAFFH8FAAIEAAUIZxRaFQC5AQAEAAUIZxRaFQC5AQAAAA==.',['芳咿']='芳咿呀:BAAALAAFFAYIAwAAAA==.',['菲尔']='菲尔琼斯:BAAALAAFFAIIAgAAAA==.',['萱儿']='萱儿:BAAALAAECggIDAAAAA==.',['藿藿']='藿藿:BAAALAAFFAIIAgAAAA==.',['蜂蜜']='蜂蜜辣椒:BAAALAAECgQICAAAAA==.',['行随']='行随你的便:BAAALAADCggIDgABLAAECggIIAAMABcbAA==.',['裤兜']='裤兜子里奇迹:BAAALAAECgQICAAAAA==.',['豌豆']='豌豆包:BAAALAADCgEIAQAAAA==.',['赤木']='赤木茂:BAABLAAFFH8NAAIKAAQIRR98IQDhAAAKAAQIRR98IQDhAAAAAA==.',['赵一']='赵一发儿:BAACLAAFFH8IAAIKAAIISA+oSwCQAAAKAAIISA+oSwCQAAAsAAQKfxoAAgoACAjxIY0cAPMCAAoACAjxIY0cAPMCAAAA.',['超级']='超级马力:BAAALAADCgEIAQAAAA==.',['蹦蹦']='蹦蹦跳的奶妈:BAAALAAECgIIAgAAAA==.蹦蹦跳的奶牧:BAAALAAECgYIBwAAAA==.',['辰青']='辰青:BAAALAADCgEIAQAAAA==.',['达摩']='达摩耶:BAAALAAECgYIDQAAAA==.',['迟墨']='迟墨:BAACLAAFFH8IAAISAAIImg+PTQBGAAASAAIImg+PTQBGAAAsAAQKfyIAAhIACAjNGiMZABoCABIACAjNGiMZABoCAAAA.',['迷路']='迷路的风:BAAALAAECgEIAQAAAA==.',['迷魂']='迷魂片儿:BAAALAAECgcICQAAAA==.',['追风']='追风化影:BAAALAAECgYIEAAAAA==.',['道明']='道明寺灬三少:BAAALAADCgYIBgAAAA==.',['那你']='那你说:BAAALAAECgMIBAAAAA==.',['醉清']='醉清风:BAAALAAECgYIDQAAAA==.',['醉苍']='醉苍穹:BAAALAAECgYIDAAAAA==.',['錵阁']='錵阁:BAAALAADCgMIAwAAAA==.',['铁手']='铁手拦江:BAAALAAECgUIBQAAAA==.铁手既天命:BAAALAAFFAEIAQAAAA==.',['铭哥']='铭哥之杖:BAAALAAECgYIEgAAAA==.',['长崎']='长崎素素食:BAAALAAECgYIBgAAAA==.',['闪光']='闪光的燠:BAAALAAECgMIAwAAAA==.',['陌不']='陌不守:BAAALAAFFAIIAgAAAA==.',['雪梨']='雪梨不加糖:BAAALAAFFAIIAgAAAA==.',['雪羽']='雪羽:BAAALAAECgUIBQAAAA==.',['霜之']='霜之闪电:BAAALAADCgUIBQAAAA==.',['霹雳']='霹雳猫:BAAALAAECgYICwAAAA==.',['青灯']='青灯不归客丶:BAAALAAFFAIIAgAAAA==.',['静丶']='静丶默:BAABLAAECn8aAAIFAAYIzBcLVwBEAQAFAAYIzBcLVwBEAQAAAA==.',['风吹']='风吹来:BAAALAADCgYIBgAAAA==.',['风来']='风来王:BAAALAAECgYIEwAAAA==.',['驭火']='驭火者莫里奥:BAAALAAFFAIIAgAAAA==.',['高小']='高小喵:BAAALAAECgYIDQAAAA==.',['魔婴']='魔婴:BAAALAAECgMIAwAAAA==.',['鲁班']='鲁班一号:BAAALAAECgYIBwAAAA==.',['麒鸣']='麒鸣三声:BAAALAAFFAIIAgAAAA==.',['黄天']='黄天在上:BAAALAAECgIIAwAAAA==.',['黑铁']='黑铁矮猎:BAAALAAECgUICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end