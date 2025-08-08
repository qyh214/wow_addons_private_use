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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Rogue-Subtlety','Rogue-Assassination','Warrior-Fury','Priest-Discipline','Hunter-Marksmanship','Paladin-Retribution','Warrior-Arms','Mage-Fire','DeathKnight-Unholy','Hunter-BeastMastery','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Shaman-Restoration','Mage-Frost','Mage-Arcane','Paladin-Protection','DeathKnight-Blood','DemonHunter-Vengeance','Monk-Mistweaver','Monk-Brewmaster','DemonHunter-Havoc','Druid-Restoration','Druid-Balance','Hunter-Survival','Paladin-Holy','Shaman-Enhancement','Priest-Holy','Priest-Shadow',}; local provider = {region='CN',realm='普瑞斯托',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Adencol:BAABKgAFFH8ZAAQBAAMIuCE+HgBqAAABAAEIHSU+HgBqAAACAAEI1yKnQgBhAAADAAEINB17HgBRAAAAAA==.',Al='Alcantara:BAAAKgAFFAEIAgAAAA==.',An='Anne:BAAAKgAECgUIBQAAAA==.',Bl='Bleachdream:BAABKgAECn8bAAICAAgIPheXHADCAQACAAgIPheXHADCAQAAAA==.Blooddagger:BAACKgAFFH8NAAMEAAcIaA2BCQDYAAAFAAYI6g42CwD1AAAEAAMIogqBCQDYAAAqAAQKfzwAAwQACAjvHkALADQCAAQACAj/HUALADQCAAUABwguG64bAKcBAAAA.',Cl='Clonehero:BAAAKgADCgcIBwAAAA==.',Gu='Gugul:BAAAKgAFFAIIAwAAAA==.',Is='Isra:BAAAKgAECggICAAAAA==.',Jk='Jklbln:BAAAKgAECgIIAgAAAA==.',Ju='Justitia:BAAAKgAECgQIBQAAAA==.',Ka='Karolck:BAAAKgADCggICAAAAA==.',Ma='Mahapralaya:BAABKgAFFH8OAAIGAAYIWRgeAQDUAQAGAAYIWRgeAQDUAQAAAA==.',My='Mysimple:BAAAKgADCgYIBgAAAA==.',Ni='Nikandjay:BAAAKgADCgMIAwAAAA==.',Su='Suriel:BAAAKgADCgEIAQAAAA==.',Te='Tend:BAABKgAFFH8PAAIHAAMI2hyQFADyAAAHAAMI2hyQFADyAAAAAA==.',To='Tongchen:BAAAKgAFFAIIAgAAAA==.',Wo='Wolfgonzalez:BAAAKgAECgYIBgAAAA==.',Xd='Xdj:BAAAKgAECggICAAAAA==.',['一弯']='一弯丹桂:BAAAKgADCgUIBQAAAA==.',['一念']='一念丹香:BAABKgAFFH8GAAIIAAQIxRTnDgDeAAAIAAQIxRTnDgDeAAAAAA==.',['一杯']='一杯红酒:BAAAKgADCgQIBQAAAA==.',['一锤']='一锤八十:BAABKgAFFH8NAAIJAAMIehbYTwDQAAAJAAMIehbYTwDQAAAAAA==.',['三餐']='三餐只吃豆腐:BAAAKgAECgcIAgAAAA==.',['丝丝']='丝丝月夏:BAAAKgAECgYICAAAAA==.',['丨丨']='丨丨淑:BAAAKgADCggICAAAAA==.',['丨淑']='丨淑丨:BAAAKgAECgUIBQAAAA==.',['丶梧']='丶梧桐叶:BAAAKgAECgQIBAAAAA==.',['为你']='为你断刀弃戟:BAAAKgAFFAQIBAAAAA==.',['乱丶']='乱丶:BAABKgAFFH8IAAIKAAgIdQutBADzAQAKAAgIdQutBADzAQAAAA==.',['亚米']='亚米莎:BAAAKgAFFAgIAgAAAA==.',['亲亲']='亲亲皮皮马:BAAAKgADCggIDQAAAA==.',['仰望']='仰望头顶星空:BAAAKgAECggIEAAAAA==.',['休闲']='休闲老司机:BAAAKgADCgcIBwAAAA==.',['会嗜']='会嗜血的萨满:BAAAKgAECgUIBQAAAA==.',['佐高']='佐高皖腾:BAAAKgAECgMIAwAAAA==.',['佑一']='佑一天:BAAAKgADCgQIBAAAAA==.',['何伯']='何伯:BAAAKgAECggIEwAAAA==.',['你无']='你无敌了:BAAAKgAECgQIBAAAAA==.',['你矮']='你矮你有道理:BAAAKgADCgEIAQAAAA==.',['修仙']='修仙小蚂蚁:BAAAKgAECgYIDQAAAA==.',['俺是']='俺是晓徳:BAAAKgAECgYICQAAAA==.',['倾听']='倾听安琪儿:BAAAKgAFFAgIAQAAAA==.',['偷天']='偷天盗盗:BAAAKgAECgYIBgAAAA==.',['冲吖']='冲吖:BAAAKgAECgYICwAAAA==.',['凯尔']='凯尔利斯:BAAAKgAECggIDgAAAA==.',['别毛']='别毛小怪了:BAAAKgAFFAIIAgAAAA==.',['剑戟']='剑戟与塔盾:BAAAKgAECgYIBgAAAA==.',['千颂']='千颂伊:BAAAKgADCggICAAAAA==.',['午武']='午武舞:BAAAKgADCggICAABKgAFFAgIOAACAEkgAA==.',['卡纳']='卡纳莉斯:BAAAKgAFFAYIAgAAAA==.',['可愛']='可愛茉莉:BAABKgAECn8rAAILAAgIPR+oBwBsAgALAAgIPR+oBwBsAgAAAA==.',['司徒']='司徒纤语:BAAAKgADCggICAAAAA==.',['叽叽']='叽叽咕咕:BAAAKgAFFAQIBAAAAA==.',['君丶']='君丶五公子:BAAAKgAECggICAAAAA==.',['吴彦']='吴彦筝:BAAAKgAECgYIEAAAAA==.',['吸血']='吸血莱恩:BAAAKgAFFAgIAQAAAA==.',['呼啸']='呼啸骑士:BAABKgAECn8sAAIMAAYIVCZJHQAnAgAMAAYIVCZJHQAnAgAAAA==.',['咔布']='咔布奇诺:BAAAKgADCggICAAAAA==.',['嘉嘉']='嘉嘉莉娅:BAAAKgAECgcIDQAAAA==.',['噫辰']='噫辰龙:BAACKgAFFH8PAAMNAAQIsxojGgDqAAANAAQIsxojGgDqAAAIAAEIVQtdKABCAAAqAAQKfxwAAg0ACAjkGkQ/APsBAA0ACAjkGkQ/APsBAAEqAAUUCAgIAA0AeSAA.',['囗凵']='囗凵囗:BAAAKgAFFAQIBAABKgAFFAgIAgAOAAAAAA==.',['回眸']='回眸的安琪儿:BAAAKgAFFAYIBAAAAA==.',['圣光']='圣光了解一下:BAAAKgADCggIEAAAAA==.圣光苏妲己:BAAAKgAFFAQIBAAAAA==.',['地狱']='地狱访客:BAAAKgADCgUIBQAAAA==.',['增辉']='增辉龙:BAABKgAFFH8VAAMPAAQIMCMGFQAlAQAPAAQIMCMGFQAlAQAQAAEIahLpCgA+AAAAAA==.',['夏洛']='夏洛特魔刃:BAAAKgAFFAgIAQAAAA==.',['夜三']='夜三爷:BAAAKgAECggICAAAAA==.',['夜中']='夜中的安琪儿:BAABKgAFFH8IAAIRAAQIxSREIQD0AAARAAQIxSREIQD0AAAAAA==.',['夜老']='夜老大:BAAAKgAECggICAAAAA==.',['大宗']='大宗师转死你:BAAAKgAECgQIBAAAAA==.',['大锤']='大锤八十:BAABKgAFFH8GAAIJAAYIOQLqQgDpAAAJAAYIOQLqQgDpAAAAAA==.',['天际']='天际萨:BAAAKgADCgMIAwAAAA==.',['奈兒']='奈兒:BAACKgAFFH8LAAIRAAMIBCKZGQAaAQARAAMIBCKZGQAaAQAqAAQKfxYAAhEACAjVHfUiAAYCABEACAjVHfUiAAYCAAAA.',['奥妮']='奥妮克茜亚:BAABKgAFFH8HAAMSAAYIPBj8BgBYAQASAAYIPBj8BgBYAQATAAEIWBUPQwBGAAABKgAFFAgICAATAFcSAA==.',['女粉']='女粉很多的人:BAAAKgAECgYICQAAAA==.',['她说']='她说晒黑的:BAABKgAECn8bAAMNAAgI/xXgVQBZAQANAAgISBTgVQBZAQAIAAUIIA+1SwDuAAAAAA==.',['好玩']='好玩的火焰:BAAAKgAECgMIAwAAAA==.',['妖丶']='妖丶血纹:BAAAKgAECggIEwABKgAFFAgICAAUAIEjAA==.',['姜姜']='姜姜:BAABKgAFFH8IAAMCAAgI2hchCgDqAQACAAcIuBghCgDqAQABAAEIpxJDJgBNAAAAAA==.',['娜露']='娜露希娅:BAAAKgADCggICAAAAA==.',['子栖']='子栖墨染:BAAAKgAECggIEQAAAA==.',['容赦']='容赦丶姬:BAABKgAFFH8GAAINAAQInxtuHQDhAAANAAQInxtuHQDhAAABKgAFFAgICQANAM8VAA==.容赦姬灬:BAABKgAFFH8EAAIPAAQIbha2DQBGAQAPAAQIbha2DQBGAQAAAA==.容赦灬姬:BAABKgAFFH8GAAIVAAYI7wfwCQDoAAAVAAYI7wfwCQDoAAAAAA==.',['小天']='小天鹅:BAABKgAFFH8GAAIWAAYI8QDeFgCSAAAWAAYI8QDeFgCSAAABKgAFFAgIDgAWALELAA==.',['小手']='小手搓搓:BAABKgAFFH8RAAMXAAYIkhrpCQCNAQAXAAYIkhrpCQCNAQAYAAQIfwgHBgCKAAABKgAFFAgICAAJAC8jAA==.小手轻柔:BAABKgAFFH8UAAICAAgI0xmQBgAFAgACAAgI0xmQBgAFAgAAAA==.小手黑黑:BAABKgAFFH8SAAMNAAYIUx/UDgCIAQANAAYIdx7UDgCIAQAIAAYIUBcyEgBSAQAAAA==.',['小月']='小月魂:BAAAKgAECgQIBAAAAA==.',['小笼']='小笼人参包:BAAAKgAFFAgIBAAAAA==.',['小角']='小角漂亮:BAABKgAFFH8JAAIZAAMIng19LwC/AAAZAAMIng19LwC/AAAAAA==.',['小鬼']='小鬼领主基兰:BAAAKgAECgYIBgAAAA==.',['尘合']='尘合:BAAAKgAFFAIIAwAAAA==.',['就打']='就打德:BAABKgAFFH8HAAIaAAcILBNOBwCcAQAaAAcILBNOBwCcAQAAAA==.',['广智']='广智救我:BAAAKgADCggICAAAAA==.',['异步']='异步基金:BAABKgAECn8VAAICAAgIdhjmCQAAAgACAAgIdhjmCQAAAgAAAA==.',['弑魔']='弑魔:BAAAKgAECgYICgABKgAFFAEIAQAOAAAAAA==.',['微尔']='微尔莉特:BAAAKgAECgcICAAAAA==.',['心浪']='心浪微勃丶:BAAAKgADCgMIAwAAAA==.',['思念']='思念安琪儿:BAAAKgAECggICwAAAA==.',['憨憨']='憨憨杏:BAAAKgADCgQIBAAAAA==.',['我家']='我家狗叫旺财:BAAAKgAECgMIAwAAAA==.',['我有']='我有个胖脑子:BAAAKgADCgUIBQAAAA==.',['扶老']='扶老奶奶过街:BAABKgAECn8dAAIXAAcI7RdiKwCpAQAXAAcI7RdiKwCpAQAAAA==.',['护心']='护心毛:BAAAKgAECgMIAwAAAA==.',['披着']='披着熊皮的猪:BAAAKgAFFAMIAwAAAA==.',['提莫']='提莫:BAABKgAECn8fAAMNAAgIMSLXGQCSAgANAAgIMSLXGQCSAgAIAAgIDxrLIQDIAQAAAA==.',['摧心']='摧心魔:BAAAKgAECgYIBgABKgAECggIHQAXAO0XAA==.',['播播']='播播:BAAAKgAECggICAABKgAFFAgIBQAbAO0QAA==.',['新建']='新建小角色:BAAAKgAECggICAAAAA==.新建文本文档:BAAAKgADCggIDwAAAA==.',['无尽']='无尽风雪:BAAAKgAECgIIAwAAAA==.',['无辜']='无辜者的悼词:BAAAKgAFFAIIAwABKgAFFAgIOAACAEkgAA==.',['时分']='时分:BAAAKgAFFAgIAgAAAA==.',['景井']='景井阳菜:BAAAKgAECggIDQAAAA==.',['暗夜']='暗夜傳說:BAABKgAFFH8SAAIFAAgIwhmJBQA2AgAFAAgIwhmJBQA2AgAAAA==.暗夜小坏:BAACKgAFFH8MAAINAAYIUhptAgDAAQANAAYIUhptAgDAAQAqAAQKfx0AAxwACAgSJTMBANUCABwACAgSJTMBANUCAAgAAwiLG6xHAP8AAAAA.暗夜影子:BAAAKgAFFAIIAgAAAA==.',['暗影']='暗影惩罚者:BAAAKgADCgYIBgAAAA==.',['月下']='月下的安琪儿:BAAAKgAFFAQIBAAAAA==.',['月影']='月影云际:BAAAKgAFFAQIBAAAAA==.',['未定']='未定之天命:BAABKgAFFH8OAAMEAAYIqh/TBAAMAQAFAAYI4RtXCwCXAQAEAAQIeh3TBAAMAQAAAA==.',['机械']='机械大宝贝:BAAAKgAECgYIDgAAAA==.',['杨小']='杨小术:BAAAKgADCgIIAgAAAA==.杨小法:BAAAKgADCggICAAAAA==.',['柒圆']='柒圆丶:BAAAKgADCgcIBwAAAA==.',['梦想']='梦想传说:BAAAKgAECgQIBQAAAA==.',['樊雅']='樊雅:BAAAKgAFFAEIAQAAAA==.',['橫渡']='橫渡七海的风:BAAAKgADCgUIBQAAAA==.',['比翼']='比翼齐飞:BAAAKgAFFAIIAgAAAA==.',['永恒']='永恒丨瞬间:BAAAKgAECgIIAgAAAA==.',['江暗']='江暗雨欲来:BAAAKgAFFAcIBAAAAA==.',['沉静']='沉静陛下:BAAAKgAECgEIAQAAAA==.',['洋泾']='洋泾浜:BAAAKgAFFAQIBAAAAA==.',['浓绑']='浓绑吾豆皮撬:BAAAKgADCggICAAAAA==.',['涅法']='涅法雷姆:BAAAKgAECgcICwAAAA==.',['渊恸']='渊恸:BAABKgAFFH8IAAMMAAYIPBrwEgCDAQAMAAYIPBrwEgCDAQAVAAII1gkRKgBtAAAAAA==.',['潘盼']='潘盼的熊猫:BAAAKgAECggIEAAAAA==.',['火之']='火之凋零:BAAAKgAECgcICgAAAA==.',['灵光']='灵光一闪:BAAAKgADCggICAAAAA==.',['烈玄']='烈玄:BAAAKgAFFAYIBAABKgAFFAgIBgAIAOIXAA==.',['烛阴']='烛阴:BAAAKgAFFAMIBAAAAA==.',['烟火']='烟火:BAAAKgAFFAIIAgAAAA==.',['燃烧']='燃烧灬青春:BAAAKgAFFAQIAwAAAA==.',['燎澜']='燎澜:BAABKgAFFH8NAAMJAAgIkRU7FAAGAQAJAAQIHiA7FAAGAQAUAAUIpw2JEgDoAAAAAA==.',['爱拼']='爱拼才会赢:BAAAKgAECgMIAwAAAA==.',['爱莉']='爱莉希雅:BAABKgAFFH8XAAIJAAUIXCC9GACXAQAJAAUIXCC9GACXAQAAAA==.',['牙牙']='牙牙乐乐:BAAAKgADCggICgAAAA==.',['牛德']='牛德华:BAAAKgADCggICAAAAA==.',['牛牛']='牛牛的西北方:BAABKgAFFH8GAAIKAAYIoRvoBQDDAQAKAAYIoRvoBQDDAQAAAA==.',['牧小']='牧小神医:BAAAKgADCggICAAAAA==.',['独行']='独行者的挽歌:BAAAKgAECgIIAgAAAA==.',['猎龙']='猎龙专家:BAAAKgAECgYIDAAAAA==.',['猪猪']='猪猪啵:BAABKgAFFH8JAAIJAAMIIhZmWQC+AAAJAAMIIhZmWQC+AAAAAA==.',['玛丶']='玛丶里苟斯:BAAAKgAECgQIBAAAAA==.',['玛格']='玛格汉猛:BAAAKgAECgIIAgAAAA==.',['环境']='环境与滋润:BAAAKgAECgQIBAAAAA==.',['痘痘']='痘痘玛丽:BAABKgAFFH8HAAIXAAQIZBYNHAC9AAAXAAQIZBYNHAC9AAAAAA==.',['百事']='百事柒喜:BAAAKgAFFAIIAgAAAA==.',['真没']='真没关系吗:BAABKgAFFH8HAAIMAAQIHB0zIwAKAQAMAAQIHB0zIwAKAQAAAA==.',['短尾']='短尾小福尼:BAAAKgAFFAEIAQAAAA==.',['碧螺']='碧螺春:BAABKgAFFH8RAAMZAAQI0yPjGwAhAQAZAAQI0yPjGwAhAQAWAAMIvAtcGACJAAAAAA==.',['神仙']='神仙姐夫:BAAAKgADCgQIBAAAAA==.',['祺祺']='祺祺大乖:BAAAKgAECggICAAAAA==.',['离殇']='离殇:BAAAKgAECgQIBgAAAA==.',['究极']='究极小强:BAAAKgAFFAEIAQAAAA==.',['章鱼']='章鱼烧:BAACKgAFFH8NAAIRAAMIcQdDQACHAAARAAMIcQdDQACHAAAqAAQKfycAAhEACAghDSdMAFsBABEACAghDSdMAFsBAAAA.',['米罗']='米罗:BAAAKgAECgIIAgAAAA==.',['索林']='索林:BAAAKgAECgYICQAAAA==.',['紫兰']='紫兰色:BAAAKgAECgYIDAAAAA==.',['紫色']='紫色的恶魔:BAABKgAECn8WAAMWAAgIqg0BNQDpAAAWAAgIewkBNQDpAAAZAAIICxTnewB4AAAAAA==.',['红唇']='红唇一族:BAAAKgADCgMIAwAAAA==.',['红彤']='红彤彤:BAABKgAFFH8GAAIIAAYIXg+ZFAA+AQAIAAYIXg+ZFAA+AQAAAA==.',['约格']='约格莫夫:BAAAKgADCgcIBwAAAA==.',['线性']='线性时不变:BAABKgAFFH8MAAMJAAgI7iSaAQDtAgAJAAgI7iSaAQDtAgAdAAEIAADdFwAAAAAAAA==.',['美洛']='美洛蒂:BAABKgAFFH8HAAIRAAcIQBb0BgCyAQARAAcIQBb0BgCyAQAAAA==.',['翰丶']='翰丶雷霆烈酒:BAAAKgADCggIEAAAAA==.',['老逮']='老逮:BAAAKgADCgYIBgAAAA==.',['聪聪']='聪聪:BAAAKgAFFAMIAwAAAA==.',['肥菜']='肥菜花:BAAAKgAFFAQIBAAAAA==.',['脆皮']='脆皮鸡:BAAAKgAECgIIAgAAAA==.',['自然']='自然的柠乐:BAAAKgAECggIDgAAAA==.自然的柠檬:BAAAKgAECgUICAAAAA==.',['花样']='花样作死亚军:BAAAKgADCgQIBAAAAA==.花样作死冠军:BAACKgAFFH87AAMIAAgIkiFAAgCZAgAIAAgIkiFAAgCZAgANAAIITB/IKQCpAAAqAAQKfzYAAggACAjTJZgGALsCAAgACAjTJZgGALsCAAAA.',['花繁']='花繁似锦:BAABKgAFFH8GAAIJAAYImQewFwAtAQAJAAYImQewFwAtAQAAAA==.',['花里']='花里个花:BAAAKgAECgMIAwAAAA==.',['茜亚']='茜亚影之歌:BAABKgAFFH8FAAMIAAQIKhQEMACuAAAIAAQIKhQEMACuAAANAAEIAAD7VAAAAAABKgAFFAgICAANAHkgAA==.',['荣耀']='荣耀圣光:BAAAKgAFFAQIBAAAAA==.',['莱安']='莱安娜:BAAAKgAFFAYIBAAAAA==.',['萨诺']='萨诺斯:BAAAKgAFFAEIAQAAAA==.',['落叶']='落叶终末嗟叹:BAAAKgAECgEIAQAAAA==.',['薇尔']='薇尔贝特:BAABKgAFFH8MAAIFAAYIHyJrCQDBAQAFAAYIHyJrCQDBAQAAAA==.',['蘭伍']='蘭伍贰:BAABKgAFFH8HAAMZAAYIehAwEgD3AAAZAAQIvRMwEgD3AAAWAAMIlgsKHgBsAAAAAA==.',['蜜蜜']='蜜蜜公主:BAAAKgAECgEIAQAAAA==.',['血月']='血月:BAAAKgADCgQIBAAAAA==.',['血腥']='血腥真红:BAAAKgAECgYIBgAAAA==.',['血色']='血色勇士雷莉:BAAAKgAFFAgIBAAAAA==.',['諾尼']='諾尼:BAAAKgAECgIIAgAAAA==.',['讷愚']='讷愚:BAABKgAFFH8KAAICAAYI1BRYFABhAQACAAYI1BRYFABhAQAAAA==.',['赖皮']='赖皮牛:BAABKgAFFH8HAAMaAAcIlhP2CwBHAQAaAAQIBBb2CwBHAQAbAAMIsR0wRQCZAAAAAA==.',['赛利']='赛利卡:BAABKgAFFH8UAAMIAAgI1hxEBQAlAgAIAAgI1hxEBQAlAgANAAQI5hYTFwDzAAAAAA==.',['赛博']='赛博义父:BAAAKgAECgQIBAAAAA==.',['赫里']='赫里斯塔:BAABKgAFFH8HAAIJAAQIEhfzGAD5AAAJAAQIEhfzGAD5AAAAAA==.',['躏鳢']='躏鳢萎:BAAAKgAFFAEIAQAAAA==.',['辉煌']='辉煌丿暗:BAAAKgADCgUIBQAAAA==.',['迷之']='迷之倩影:BAAAKgAECgIIAgAAAA==.',['那个']='那个武僧:BAAAKgADCgcIBwAAAA==.',['邪恶']='邪恶终结:BAAAKgAECgQIBQAAAA==.',['长命']='长命熊:BAAAKgAECggICAAAAA==.',['阿塔']='阿塔拉:BAAAKgAECgcIAwAAAA==.',['阿尔']='阿尔芙:BAAAKgAECggICwAAAA==.',['雨夜']='雨夜听风:BAABKgAECn8VAAMSAAgIpQ2/QADtAAASAAgIUA2/QADtAAATAAQIyw7ZcACQAAAAAA==.',['雨文']='雨文祺彧:BAAAKgAECgIIAgAAAA==.',['雾里']='雾里寻花:BAAAKgAFFAEIAQAAAA==.',['雾雨']='雾雨广藿香:BAABKgAFFH8PAAMeAAYIfBTTAQC3AQAeAAYIfBTTAQC3AQARAAYI2BCdEgBAAQAAAA==.雾雨爱丽丝:BAABKgAFFH8GAAQLAAYIqwq4JwCCAAALAAIIvAe4JwCCAAASAAIIYQpiJQBnAAATAAIIHhGVRQA8AAAAAA==.',['露茜']='露茜亚:BAABKgAFFH8GAAIaAAYIcwg+FAD+AAAaAAYIcwg+FAD+AAAAAA==.',['青峰']='青峰:BAABKgAFFH8MAAMUAAYInSQUDgAcAQAUAAYInSQUDgAcAQAJAAQIUBdQRgDiAAAAAA==.',['高达']='高达:BAAAKgAECgUIBwAAAA==.高达正义必胜:BAAAKgAECgcIBwAAAA==.',['魔术']='魔术斯:BAAAKgAECgIIAgAAAA==.',['魔魔']='魔魔天:BAABKgAFFH8IAAQfAAYIVwukDQDwAAAfAAQIYwukDQDwAAAHAAIIlw6SIQCdAAAgAAIISwEsKABCAAAAAA==.',['鲲鹏']='鲲鹏:BAAAKgADCggIDQAAAA==.',['麻辣']='麻辣小聋瞎:BAAAKgADCgEIAQAAAA==.',['黎厉']='黎厉害:BAAAKgAECggICgAAAA==.',['黑尔']='黑尔发纳斯:BAABKgAFFH8GAAIIAAYI4heOEABhAQAIAAYI4heOEABhAQAAAA==.',['黑豆']='黑豆:BAAAKgAFFAMIAwAAAA==.',['黑龙']='黑龙王子:BAAAKgAECgYIBgAAAA==.',['黒荳']='黒荳:BAAAKgAFFAUIAwAAAA==.',['龙傲']='龙傲天:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end