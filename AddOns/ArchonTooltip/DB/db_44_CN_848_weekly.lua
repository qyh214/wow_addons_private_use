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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Priest-Holy','Mage-Arcane','DeathKnight-Frost','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Evoker-Devastation','Evoker-Augmentation','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Druid-Balance','Rogue-Outlaw','Paladin-Holy','Druid-Restoration','Mage-Frost','Warrior-Protection','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Priest-Shadow','Evoker-Preservation','Warlock-Affliction',}; local provider = {region='CN',realm='迪托马斯',name='CN',type='weekly',zone=44,date='2025-12-08',data={Bi='Bin:BAAALAAECggICAAAAA==.',Bo='Bomer:BAAALAADCgEIAQAAAA==.',Co='Coolhot:BAABLAAECn8YAAMBAAYIUyJDDQCSAQABAAYIUyJDDQCSAQACAAYIPRqvMQCHAQAAAA==.',Dr='Dragonslayer:BAAALAAECgYICAABLAAFFAIICAADAO8dAA==.',Hh='Hhnexus:BAABLAAFFH8FAAIEAAMIaAIqSwBRAAAEAAMIaAIqSwBRAAAAAA==.',Mo='Monstershua:BAAALAAFFAYIBAAAAA==.',No='Novo:BAAALAAECgYICwAAAA==.',Re='Reinhardt:BAAALAADCgQIBAAAAA==.',Sa='Saroti:BAAALAADCggICQAAAA==.',Sh='Shinesoul:BAAALAAFFAIIAgAAAA==.',Th='Theshyshy:BAAALAAECgYIDAAAAA==.',Wa='Waga:BAABLAAFFH8GAAIFAAYIXw4OLwBQAQAFAAYIXw4OLwBQAQAAAA==.',Wd='Wdka:BAABLAAFFH8QAAMGAAgIQSLwBQCiAgAGAAgIQSLwBQCiAgAHAAIIlxLMFAB6AAAAAA==.Wdkly:BAAALAAFFAgIAQAAAA==.',Yn='Ynot:BAAALAAECgYIDAAAAA==.',Zi='Zightimaniac:BAAALAAECgYIBwAAAA==.',['一样']='一样枫隐:BAABLAAECn8YAAMIAAgIIxTgIQAJAgAIAAgIAxTgIQAJAgAJAAMI1gyJQQCPAAAAAA==.',['三鹿']='三鹿凉拌蒙牛:BAAALAADCgEIAQAAAA==.',['丢丢']='丢丢你老木:BAAALAADCgUIBgAAAA==.',['丶圣']='丶圣皇:BAAALAAECgYIBgAAAA==.',['二月']='二月的鱼:BAAALAADCgYIBgAAAA==.',['人杰']='人杰鬼雄:BAAALAADCgYIBgAAAA==.',['伊利']='伊利玬丶怒风:BAABLAAFFH8eAAIKAAYIixcPHQCRAQAKAAYIixcPHQCRAQAAAA==.伊利达奶:BAAALAAECgYIBgAAAA==.',['伯牙']='伯牙断弦:BAAALAAECgYIBgAAAA==.',['佣兽']='佣兽:BAACLAAFFH8eAAMLAAYITBzRCQCHAQALAAYITBzRCQCHAQAMAAQIORBFCAAWAQAsAAQKfy4AAwsABwhXIVEUAIwCAAsABwhXIVEUAIwCAAwABQgPGZAIAAcBAAAA.',['保囖']='保囖炫凌:BAAALAADCgYIBgAAAA==.',['假日']='假日里的圣光:BAAALAADCgYIBgAAAA==.',['先祖']='先祖之魂:BAAALAAECgEIAQAAAA==.',['兰花']='兰花十:BAABLAAFFH8GAAMNAAYIbA+yMADtAAANAAUI9wyyMADtAAAOAAEI7wGlUAA0AAAAAA==.',['冷雨']='冷雨葬名花:BAAALAADCgcIBwAAAA==.',['凤凰']='凤凰小小:BAAALAADCgIIAgAAAA==.',['凤灵']='凤灵:BAAALAAFFAIIBAAAAA==.',['凤羽']='凤羽:BAABLAAFFH8GAAIPAAYIwxaBPQBRAQAPAAYIwxaBPQBRAQAAAA==.',['凱爾']='凱爾崔蘭晨曦:BAAALAAFFAEIAQAAAA==.',['创世']='创世元神:BAABLAAECn8tAAIQAAcIEBBIKgAqAQAQAAcIEBBIKgAqAQAAAA==.',['刹满']='刹满:BAAALAAECgYIBwAAAA==.',['十三']='十三姨:BAAALAAECgEIAQAAAA==.',['卡珊']='卡珊德拉:BAACLAAFFH84AAIRAAYIySCyAADoAQARAAYIySCyAADoAQAsAAQKfyUAAhEABwiFG+cGADYCABEABwiFG+cGADYCAAAA.',['卢卡']='卢卡:BAAALAAFFAIIAgAAAA==.卢卡东七七:BAAALAAECgQIBAAAAA==.',['君临']='君临黑暗:BAAALAAFFAIIBAAAAA==.',['哎呦']='哎呦哇啦:BAAALAAECgYIEwAAAA==.',['哥帥']='哥帥得一逼:BAAALAAECgMIAwAAAA==.',['唯一']='唯一性人:BAABLAAECn8fAAIQAAcI9hw6FADWAQAQAAcI9hw6FADWAQAAAA==.',['嘟巿']='嘟巿蓅氓:BAACLAAFFH8qAAMDAAcI4hWhCwCsAQADAAUIWxyhCwCsAQASAAYIBhOODgDzAAAsAAQKfykAAxIACAjyG0QUAG0CABIACAjyG0QUAG0CAAMABwiBIgpsABECAAAA.',['四百']='四百个萨满:BAABLAAFFH8UAAIDAAYICx/RDQDXAQADAAYICx/RDQDXAQAAAA==.',['坦哥']='坦哥爱你哟:BAAALAAECgMIAwAAAA==.',['多米']='多米尼克:BAAALAAECgYIDAAAAA==.',['夜径']='夜径林溪小牛:BAAALAAECgYIAwAAAA==.',['大丶']='大丶雕:BAAALAADCgYIBgAAAA==.',['大玲']='大玲子:BAAALAAECggICAAAAA==.',['大聪']='大聪明:BAABLAAFFH8IAAITAAIIphtvNACZAAATAAIIphtvNACZAAAAAA==.',['大腿']='大腿轻轻抚:BAACLAAFFH8WAAMFAAgIESG2BgCAAgAFAAgIESG2BgCAAgAUAAMITxD8DgBwAAAsAAQKfzoAAhQACAicIKAQAKMCABQACAicIKAQAKMCAAAA.',['天上']='天上飞:BAAALAADCgcIBwAAAA==.',['奈伊']='奈伊诛特:BAAALAAECgUIBQAAAA==.',['奈门']='奈门摩尔:BAABLAAFFH8FAAMCAAIIIw+YQQCWAAACAAIIIw+YQQCWAAABAAEISg5YKgBNAAAAAA==.',['妞妞']='妞妞侠:BAAALAAFFAIIBAAAAA==.',['娜可']='娜可露露:BAAALAAECgYIEgAAAA==.',['嫩又']='嫩又白:BAAALAAFFAIIAgAAAA==.',['宁静']='宁静志远:BAAALAAECgYIBgAAAA==.',['宝贝']='宝贝儿:BAABLAAFFH8GAAITAAYI5w25GwBPAQATAAYI5w25GwBPAQAAAA==.',['射射']='射射小王子:BAAALAAECgYICAAAAA==.',['小小']='小小无敌:BAABLAAFFH8FAAIDAAQIqwEFbQBAAAADAAQIqwEFbQBAAAAAAA==.',['小暴']='小暴力:BAAALAAECgYIBgAAAA==.',['小汤']='小汤包:BAAALAAECgYICAAAAA==.',['小薯']='小薯条:BAACLAAFFH8IAAMVAAYI4hM1BADuAQAVAAYI4hM1BADuAQAWAAEIggkYCQBEAAAsAAQKfx0AAxUACAi1IpEMAOYCABUACAi1IpEMAOYCABcAAQi/Aw0YASMAAAAA.',['小黑']='小黑子:BAAALAAECgIIAgAAAA==.',['小鼻']='小鼻涕妞妞:BAAALAADCgEIAQAAAA==.',['就说']='就说大不大:BAABLAAECn8UAAICAAYIMQeOaADIAAACAAYIMQeOaADIAAAAAA==.',['岁月']='岁月:BAAALAADCgEIAQAAAA==.',['希儿']='希儿瓦纳斯:BAAALAAFFAIIAgAAAA==.',['帮帮']='帮帮小朋友:BAAALAAECgMIAwAAAA==.',['幼麟']='幼麟:BAABLAAFFH8FAAMIAAUINxPMCgAUAQAIAAMIeBPMCgAUAQAJAAII1RKjDgCpAAAAAA==.',['幽夜']='幽夜之灵:BAAALAAFFAYIAwAAAA==.',['彦祖']='彦祖弟弟:BAAALAAECgYIDAAAAA==.',['德得']='德得德得德:BAAALAAECgIIAgAAAA==.',['忍者']='忍者鱼:BAACLAAFFH8iAAIFAAUIOxdnLwBOAQAFAAUIOxdnLwBOAQAsAAQKfzAAAwUACAjuHnMQADICAAUACAjuHnMQADICABQABQhWFaJaAAsBAAAA.',['快乐']='快乐小老头:BAABLAAFFH8GAAMGAAYItQBBqwAVAAAGAAUIugBBqwAVAAAHAAEIngD8IAAHAAAAAA==.快乐的牛牛:BAAALAADCgEIAQAAAA==.',['悠悠']='悠悠:BAAALAAECgYIBgABLAAFFAIIAgAYAAAAAA==.',['憨憨']='憨憨牛:BAABLAAFFH8GAAIPAAYIkAAJxQASAAAPAAYIkAAJxQASAAAAAA==.',['懒懒']='懒懒的缺缺:BAAALAAFFAIIBAAAAA==.',['抽烟']='抽烟小老头:BAABLAAFFH8GAAIXAAYIcQA7ZwAQAAAXAAYIcQA7ZwAQAAAAAA==.',['挽秋']='挽秋:BAAALAAECgIIAgAAAA==.',['文橙']='文橙功主:BAAALAADCgcIBwAAAA==.',['断流']='断流水:BAAALAAECgYIBgAAAA==.',['无印']='无印之霓裳:BAAALAAECgEIAQAAAA==.无印羽灵:BAAALAAECgUIBQAAAA==.无印龙灵:BAAALAADCgEIAQAAAA==.',['明眸']='明眸善睐:BAAALAAFFAIIAgAAAA==.',['明镜']='明镜非台:BAAALAAECgYIDwAAAA==.',['星火']='星火:BAAALAAFFAIIAgAAAA==.',['星空']='星空之盾:BAAALAAECgYIBgAAAA==.星空乱舞:BAAALAAECgUIBQAAAA==.',['晓风']='晓风残月:BAAALAAECgMIBAAAAA==.',['普琳']='普琳赛丝:BAAALAAECgYIBgAAAA==.',['暗之']='暗之靓靓:BAABLAAFFH8KAAICAAYIHAGIWABIAAACAAYIHAGIWABIAAAAAA==.',['最后']='最后的勇士:BAABLAAFFH8FAAIXAAQI6wBYZgAYAAAXAAQI6wBYZgAYAAAAAA==.',['月下']='月下孤狼:BAAALAAECgYIBgAAAA==.',['木人']='木人:BAAALAAECgYIDAAAAA==.',['李子']='李子:BAAALAADCgIIAgAAAA==.',['桀骜']='桀骜不逊:BAAALAAECgQIBAAAAA==.',['梁上']='梁上淑女:BAAALAADCgYIBgAAAA==.',['梁玄']='梁玄彬:BAAALAAFFAIIAgAAAA==.',['梅肯']='梅肯佣兽:BAAALAAFFAMIAwAAAA==.',['梦游']='梦游的鱼:BAAALAAECgIIAgAAAA==.',['楚紫']='楚紫晴:BAAALAADCgYIBgAAAA==.楚紫瑜:BAAALAAECgEIAQAAAA==.',['死亡']='死亡深度:BAAALAAECgYIBgAAAA==.',['死骑']='死骑:BAAALAADCgEIAQAAAA==.',['比不']='比不比不:BAAALAADCggICAAAAA==.',['沈川']='沈川:BAAALAAFFAIIAgAAAA==.',['沧海']='沧海星辰:BAAALAAECgYIDQAAAA==.',['洛菲']='洛菲儿:BAAALAAECgYIBgAAAA==.',['浪子']='浪子彦钦:BAAALAAECgYIBgAAAA==.',['深渊']='深渊者:BAAALAADCggICAAAAA==.',['深爱']='深爱着橘子:BAAALAAECgYIEgAAAA==.',['湮灭']='湮灭:BAAALAAFFAIIBAAAAA==.',['滴劈']='滴劈艾斯:BAAALAAECgYIDAAAAA==.',['漂泊']='漂泊一世:BAAALAADCgYIBgAAAA==.',['潮爆']='潮爆亚洲:BAAALAAECgQIBgAAAA==.',['火星']='火星上的牛牛:BAAALAAFFAYIBAAAAA==.火星大裤衩:BAAALAADCgcIBwAAAA==.火星男恶魔:BAAALAADCgQIBAAAAA==.',['火法']='火法:BAABLAAFFH8GAAICAAUIoRBXPwD/AAACAAUIoRBXPwD/AAAAAA==.',['灬桃']='灬桃子灬:BAAALAAECgYIBgAAAA==.',['灵魂']='灵魂的枷锁:BAAALAAECgYIBgAAAA==.',['煊赫']='煊赫门门主:BAAALAADCgYICAAAAA==.',['熔岩']='熔岩猛击:BAAALAAECgYIDgAAAA==.',['爹爹']='爹爹:BAAALAAECgIIAgAAAA==.',['牛彼']='牛彼得:BAAALAAECgQIBAABLAAECgYIBgAYAAAAAA==.',['犀利']='犀利点:BAAALAAFFAEIAQAAAA==.',['狐仙']='狐仙儿:BAAALAADCgIIAgAAAA==.',['狩猎']='狩猎嫂子村:BAAALAADCggICAAAAA==.',['独孤']='独孤:BAAALAAECgEIAQAAAA==.独孤刺客:BAAALAADCgMIAwAAAA==.',['独自']='独自冲锋:BAAALAAECgUIBQAAAA==.独自小酌:BAAALAADCgMIBgAAAA==.',['玛丽']='玛丽蕾珊斯卡:BAAALAADCgYICwAAAA==.',['瑅里']='瑅里奥丶弗丁:BAABLAAFFH8YAAIDAAYIGBewGwCCAQADAAYIGBewGwCCAQABLAAFFAYIHgAKAIsXAA==.',['生姜']='生姜人的馕:BAAALAAECgYIBgAAAA==.',['百无']='百无求:BAAALAAECgMIAwAAAA==.',['目光']='目光如炬:BAAALAAECgIIAgAAAA==.',['破罐']='破罐子破摔:BAABLAAFFH8GAAIGAAYIgCC8IQCvAQAGAAYIgCC8IQCvAQAAAA==.',['神之']='神之奏:BAAALAADCgcICgAAAA==.',['神圣']='神圣大救赎:BAACLAAFFH8IAAIDAAIISxdpOACkAAADAAIISxdpOACkAAAsAAQKfxUAAgMABwjJH3IpAO8BAAMABwjJH3IpAO8BAAAA.',['秀气']='秀气小贝:BAABLAAFFH8GAAMEAAIIRgKUQwBrAAAEAAIIRgKUQwBrAAAZAAIICBLCKABGAAAAAA==.',['等等']='等等我:BAAALAAECgUIBQAAAA==.',['粒子']='粒子:BAACLAAFFH8XAAINAAYI6w4FKQAeAQANAAYI6w4FKQAeAQAsAAQKfyQAAg0ABwjXFzVbANUBAA0ABwjXFzVbANUBAAAA.',['紫色']='紫色圣光:BAAALAADCgEIAQAAAA==.',['纳什']='纳什:BAAALAAECgQIBAAAAA==.',['绝世']='绝世神棍:BAAALAAECgIIAgAAAA==.',['维熙']='维熙:BAAALAAECgYIBwAAAA==.',['维萨']='维萨吉:BAAALAAFFAQIBAABLAAFFAYIHgALAEwcAA==.',['美济']='美济:BAAALAAECgYIDAAAAA==.',['老杆']='老杆子:BAAALAAECgIIAwAAAA==.',['肥龙']='肥龙在天:BAACLAAFFH8kAAIaAAYISx6EBgCLAQAaAAYISx6EBgCLAQAsAAQKfy8ABBoACAh/HgsGAN0CABoACAh/HgsGAN0CAAwABwi0HKwHABQCAAsAAgh1HcZWAKcAAAAA.',['舞星']='舞星空:BAAALAAECgYIBgAAAA==.',['苛政']='苛政啊:BAAALAAECgUIBQAAAA==.',['莉兹']='莉兹:BAABLAAFFH8HAAIPAAUIDwUuYgC5AAAPAAUIDwUuYgC5AAAAAA==.',['莫西']='莫西干:BAAALAAECggICAAAAA==.',['萌大']='萌大耐:BAAALAAECgMIAwAAAA==.',['萨琉']='萨琉弥斯:BAAALAADCggICwAAAA==.',['萨百']='萨百万:BAAALAAECgUIBQAAAA==.',['街溜']='街溜子:BAAALAAECgYIBgAAAA==.',['誰不']='誰不低头:BAAALAADCgQIBAAAAA==.',['豿日']='豿日战:BAAALAADCgMIAwAAAA==.',['越来']='越来越猛:BAAALAAECgQIBAAAAA==.',['路大']='路大主教:BAAALAAECgYIDwAAAA==.路大黑骑:BAAALAADCgUIBQAAAA==.',['路小']='路小小白:BAAALAADCgYIBgAAAA==.',['转世']='转世幻影:BAAALAAECgYIBgAAAA==.',['速度']='速度咩:BAAALAAECgIIAgAAAA==.',['钟爱']='钟爱豆包:BAABLAAFFH8IAAIVAAQIaReRGgDDAAAVAAQIaReRGgDDAAAAAA==.',['阿司']='阿司匹林:BAAALAAECgYIDQAAAA==.',['阿米']='阿米诺斯:BAAALAAECgIIAgAAAA==.',['难民']='难民:BAAALAAECgIIAgAAAA==.',['雁翅']='雁翅侠:BAAALAADCgIIAgAAAA==.',['雁赤']='雁赤侠:BAAALAADCgIIAgAAAA==.',['集结']='集结呐喊:BAAALAADCgcIBwAAAA==.',['雪羽']='雪羽:BAAALAAECgYIDwAAAA==.',['霍尔']='霍尔蒙克斯:BAACLAAFFH8OAAICAAIIDhSgOgCeAAACAAIIDhSgOgCeAAAsAAQKfykABAIACAhTFsxFACQCAAIACAhTFsxFACQCABsABggrBSsdABABAAEAAwgACRB7AI4AAAAA.',['霸气']='霸气外露的牛:BAAALAAECgYIBwAAAA==.',['霸波']='霸波尔奔:BAAALAAECgEIAQAAAA==.',['霹雳']='霹雳贝贝:BAAALAADCgYIBgAAAA==.',['魔屠']='魔屠嚜嚜:BAABLAAFFH8OAAINAAMI9hrVIgDEAAANAAMI9hrVIgDEAAAAAA==.魔屠行者:BAACLAAFFH8JAAIKAAMINwygSABXAAAKAAMINwygSABXAAAsAAQKfyAAAgoABwjhGFYsAKoBAAoABwjhGFYsAKoBAAAA.',['鲜血']='鲜血长河:BAAALAADCgIIAgAAAA==.',['鸡尔']='鸡尔加蛋:BAAALAAECgYICwAAAA==.',['黑暗']='黑暗女侠:BAAALAAECgMIAwAAAA==.黑暗的女王:BAAALAADCgEIAQAAAA==.黑暗觉醒:BAABLAAFFH8GAAIGAAII0w06bgCRAAAGAAII0w06bgCRAAAAAA==.黑暗飯团:BAAALAAFFAQIBAAAAA==.黑暗饭团:BAABLAAFFH8GAAIQAAYITgHyKwBVAAAQAAYITgHyKwBVAAAAAA==.',['默默']='默默乖乖:BAAALAAECgIIAgAAAA==.',['龙卷']='龙卷:BAAALAAECgcIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end