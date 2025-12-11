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
 local lookup = {'Paladin-Holy','Paladin-Retribution','Druid-Restoration','Monk-Brewmaster','Hunter-BeastMastery','Priest-Holy','Hunter-Marksmanship','Evoker-Devastation','Warlock-Destruction','Shaman-Restoration','Warrior-Fury','Mage-Frost','Warrior-Protection','DemonHunter-Havoc','Druid-Balance','Evoker-Preservation','Evoker-Augmentation','DeathKnight-Frost','DeathKnight-Unholy','Druid-Guardian','Warlock-Affliction','Warlock-Demonology','Shaman-Elemental','Mage-Arcane','Paladin-Protection','DemonHunter-Vengeance','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='奥杜尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Az='Azuki:BAAALAAFFAIIAgAAAA==.',Bo='Boom:BAAALAAECgUIBQAAAA==.',Ca='Calmdown:BAAALAAECgIIAQAAAA==.',Ch='Cheng:BAAALAADCgcIBwAAAA==.Cher:BAAALAADCgYIBgAAAA==.',Ep='Epic:BAAALAADCgMIAwAAAA==.',Fy='Fyuyuyuyu:BAABLAAFFH8QAAMBAAUIpxLwFwARAQABAAQIShLwFwARAQACAAQILAsVOADCAAABLAAFFAYIIgADACYiAA==.',Hu='Huang:BAABLAAFFH8PAAIDAAYIHxaDFQCLAQADAAYIHxaDFQCLAQAAAA==.',Le='Leoji:BAAALAAECgYICgAAAA==.',Ny='Nymphzhao:BAAALAAECgYIBgAAAA==.',Pe='Peche:BAAALAAECgYIDAAAAA==.',Pl='Pluto:BAAALAAECgUIBQAAAA==.',Po='Posche:BAACLAAFFH8/AAIEAAgIIwjUBgCZAQAEAAgIIwjUBgCZAQAsAAQKfyYAAgQACAimFKcaANABAAQACAimFKcaANABAAAA.',Re='Redarrow:BAABLAAFFH8OAAIFAAYImw3fSAApAQAFAAYImw3fSAApAQAAAA==.',Sa='Sakame:BAAALAAECgMIBQAAAA==.Satori:BAAALAAECgYICQAAAA==.',Se='Sendorym:BAAALAAECgYICQAAAA==.',Wi='Wizz:BAAALAAECgUIBQAAAA==.',Wy='Wydk:BAAALAAECggIDgAAAA==.',Yi='Yishouge:BAAALAADCgcIBwAAAA==.',['一个']='一个人的婚礼:BAAALAADCggICAAAAA==.',['一品']='一品:BAAALAAECgEIAQAAAA==.',['一定']='一定中大奖:BAABLAAECn8bAAIGAAgIrxR8HwC9AQAGAAgIrxR8HwC9AQAAAA==.',['一滚']='一滚一咕噜:BAAALAADCgUIBQAAAA==.',['一看']='一看你媚一:BAAALAAECgUIBQAAAA==.',['一飞']='一飞影一:BAAALAADCggICQAAAA==.',['与君']='与君离别意:BAAALAAECggICAAAAA==.',['丨燚']='丨燚丨:BAAALAADCgYIBgAAAA==.',['为了']='为了生命精华:BAAALAAECgEIAQAAAA==.',['买菜']='买菜女路人:BAACLAAFFH8GAAIFAAII+wVjvAAtAAAFAAII+wVjvAAtAAAsAAQKfyEAAwUABwhxE2SYACUBAAcABwjgCshnACUBAAUABggpFWSYACUBAAAA.',['人民']='人民的名义:BAAALAADCgcIBwAAAA==.',['修马']='修马呀修马:BAABLAAFFH8TAAICAAUIJhnZJQBIAQACAAUIJhnZJQBIAQAAAA==.',['傲慢']='傲慢的萨满:BAAALAAECgUIBwAAAA==.',['傻馒']='傻馒:BAAALAAECgYIEwAAAA==.',['克尔']='克尔苏缺德:BAAALAAECgYIBwAAAA==.',['冬日']='冬日可爱:BAABLAAFFH8iAAIIAAgIASHFAQClAgAIAAgIASHFAQClAgAAAA==.',['凄凉']='凄凉丶不思量:BAABLAAECn8WAAIJAAYI2hAgUgALAQAJAAYI2hAgUgALAQAAAA==.',['利群']='利群王中王:BAAALAAECgYICQAAAA==.',['别看']='别看我矮:BAAALAAECgYIBgAAAA==.',['发疯']='发疯丶:BAAALAADCgQIBAAAAA==.',['古代']='古代熊猫:BAABLAAFFH8KAAIKAAYI1hwTEADnAQAKAAYI1hwTEADnAQAAAA==.',['吊带']='吊带教授:BAAALAAECgMIAQAAAA==.',['君耀']='君耀华鬼:BAAALAADCgMIAwAAAA==.',['含家']='含家富贵:BAABLAAFFH8IAAIFAAYIfw4FSAAsAQAFAAYIfw4FSAAsAQAAAA==.',['吱吱']='吱吱:BAABLAAFFH8cAAIIAAgIYSNRAQDFAgAIAAgIYSNRAQDFAgAAAA==.',['呔站']='呔站住:BAAALAAECgEIAQAAAA==.',['咥个']='咥个肉夹馍:BAAALAAECgUIBwAAAA==.',['哈吉']='哈吉羊:BAAALAAECgYIBgAAAA==.',['哥谭']='哥谭李宗盛:BAABLAAFFH8GAAILAAIIxRIMNQCZAAALAAIIxRIMNQCZAAAAAA==.',['嘎嘎']='嘎嘎香:BAAALAAECgYICgAAAA==.',['土萨']='土萨:BAAALAADCgcIBwAAAA==.',['土豆']='土豆炖牛肉:BAAALAAECgYIDgAAAA==.土豆片炒肉:BAAALAAECgMIAwAAAA==.',['圣佑']='圣佑骁骑:BAAALAADCgUIBgAAAA==.',['圣光']='圣光大忽悠:BAAALAADCgIIAgAAAA==.圣光帮帮忙:BAAALAAFFAIIAgAAAA==.圣光阴影:BAAALAAECgYIBgAAAA==.',['圣虚']='圣虚道人:BAAALAADCgIIAgAAAA==.',['堂吉']='堂吉诃德:BAAALAAFFAIIAgAAAA==.',['墨丶']='墨丶迹:BAAALAAECgcIDAAAAA==.',['士气']='士气:BAAALAAFFAIIAgAAAA==.',['夏日']='夏日可畏:BAABLAAFFH8kAAIIAAgI3CRzAAD8AgAIAAgI3CRzAAD8AgAAAA==.',['夏洛']='夏洛特丶玲玲:BAAALAADCgIIAgAAAA==.',['多吃']='多吃魔芋:BAAALAAECgQIBAAAAA==.',['多恩']='多恩保安:BAAALAAECgUIBQAAAA==.',['夜夜']='夜夜有小酒:BAAALAAFFAIIAgAAAA==.',['夜的']='夜的安魂曲:BAAALAAFFAIIAgAAAA==.',['大不']='大不净者:BAAALAAECgQIBgAAAA==.',['大歼']='大歼灭者:BAAALAAECgYIBgAAAA==.',['大牌']='大牌战:BAAALAAFFAMIAwAAAA==.',['大美']='大美女:BAAALAAECggIDwABLAAFFAgIBQAJAIQIAA==.',['大荣']='大荣耀者:BAAALAAECggICAAAAA==.',['大郎']='大郎吃药:BAAALAAECgQIBAAAAA==.',['大锤']='大锤仈十:BAAALAAFFAIIBAAAAA==.',['太寿']='太寿鸠毛:BAAALAAECgUIBQAAAA==.',['奥杜']='奥杜尔真好玩:BAAALAADCgIIAgAAAA==.',['如月']='如月群真:BAAALAAECgEIAgAAAA==.',['妹妹']='妹妹有魅魔:BAAALAAECgUIBQAAAA==.',['学妹']='学妹别这样:BAAALAAECgYIDgAAAA==.',['守夜']='守夜人丶丶:BAAALAAECggICAAAAA==.',['小星']='小星辰啊:BAAALAAECgYICgAAAA==.',['小熊']='小熊软糖:BAABLAAFFH8GAAIMAAIIrhO6FQBDAAAMAAIIrhO6FQBDAAAAAA==.',['小牌']='小牌战:BAABLAAFFH8HAAINAAQIvAk2HQCZAAANAAQIvAk2HQCZAAAAAA==.小牌战战:BAAALAAFFAMIAwAAAA==.',['小罗']='小罗:BAAALAAECgMIAwAAAA==.小罗纳尔多:BAAALAAECgYIBgAAAA==.',['小野']='小野麻里亞:BAABLAAFFH8KAAICAAIIiBh3MgCpAAACAAIIiBh3MgCpAAAAAA==.',['小锤']='小锤四什:BAAALAAFFAIIAgAAAA==.',['巴伊']='巴伊老司机:BAAALAAECgYIBgAAAA==.',['开局']='开局一个碗:BAAALAADCggICAAAAA==.',['影山']='影山飞雄:BAAALAAECgYIBgAAAA==.',['影心']='影心:BAABLAAECn8YAAIOAAYIxhiEfgDIAQAOAAYIxhiEfgDIAQAAAA==.',['很好']='很好吃:BAAALAAECgYIBgAAAA==.',['御驾']='御驾亲征:BAAALAAECgQIBAAAAA==.',['怒风']='怒风:BAAALAAFFAIIBAAAAA==.',['怕噶']='怕噶就点防御:BAAALAADCgIIAgAAAA==.',['恶魔']='恶魔之吻:BAAALAAECgYIBgAAAA==.恶魔的眼:BAAALAAECgEIAQAAAA==.',['愛笑']='愛笑旳眼睛:BAAALAAECggICAAAAA==.',['我不']='我不是宠物:BAABLAAFFH8iAAMDAAYIJiI/BgBMAgADAAYIJiI/BgBMAgAPAAEITBFKMQBAAAAAAA==.',['我是']='我是奶龙:BAABLAAFFH8aAAMQAAYINxl1CQDFAQAQAAYINxl1CQDFAQARAAQIdw5ZCgDGAAABLAAFFAYIIgADACYiAA==.我是萌新:BAAALAADCgYIBgAAAA==.',['我曾']='我曾信仰圣光:BAABLAAFFH8MAAMSAAYIzQ1nOABbAQASAAYIzQ1nOABbAQATAAEI2gcZFQBEAAABLAAFFAYIDgAFAJsNAA==.',['我来']='我来奶:BAAALAADCgQIBAAAAA==.',['手上']='手上有真理:BAAALAADCgEIAQAAAA==.',['搁浅']='搁浅丫:BAAALAAECgYICAAAAA==.搁浅的带鱼:BAAALAAECgYICQAAAA==.',['搞点']='搞点胡萝卜素:BAAALAAECggICAAAAA==.',['放空']='放空灬去旅行:BAABLAAECn8UAAIDAAYIERuZIQDHAQADAAYIERuZIQDHAQAAAA==.',['无风']='无风不起浪:BAAALAAECgMIBAAAAA==.',['日倒']='日倒扶桑:BAAALAAECgUIBwAAAA==.',['星辰']='星辰大魔王:BAAALAAECgEIAQAAAA==.',['春祺']='春祺夏安:BAAALAAECgcIDAAAAA==.',['昨夜']='昨夜丶辰星:BAAALAAECgUIBQAAAA==.',['暗影']='暗影之心:BAAALAADCgIIAgAAAA==.',['曙光']='曙光大魔王:BAAALAAECgIIAgAAAA==.',['朴信']='朴信男:BAABLAAFFH8IAAICAAgIGALuRACGAAACAAgIGALuRACGAAAAAA==.',['枝枝']='枝枝:BAABLAAFFH8oAAIIAAgIBiWeAADvAgAIAAgIBiWeAADvAgAAAA==.',['枫暴']='枫暴之灵:BAABLAAFFH8kAAIUAAYIMQtTBAAEAQAUAAYIMQtTBAAEAQAAAA==.',['枯鬼']='枯鬼:BAAALAAFFAIIBAAAAA==.',['桂林']='桂林米粉丶:BAAALAAECgYIEAAAAA==.',['桔中']='桔中秘:BAAALAAFFAIIAgAAAA==.',['棘忆']='棘忆:BAAALAAECgYIBgAAAA==.',['橙黏']='橙黏人:BAACLAAFFH8RAAQVAAYIvxT2BQBjAAAJAAUIRxLSRADEAAAVAAEIGCH2BQBjAAAWAAEIoSHkHAAAAAAsAAQKfxsABAkABwjvJJUYABsCAAkABgjGJJUYABsCABUAAwgeEyEPAHIAABYAAQi/IDg+AAAAAAAA.',['死亡']='死亡如影随行:BAAALAADCggICAAAAA==.',['比戈']='比戈尼根儿:BAAALAADCgEIAQAAAA==.',['汪呜']='汪呜:BAAALAADCgIIAgAAAA==.',['沐丝']='沐丝:BAAALAADCgQIBAAAAA==.',['活死']='活死人牧:BAAALAAFFAIIBAAAAA==.',['流光']='流光丶岁月:BAABLAAFFH8FAAIFAAMINg2mdQB1AAAFAAMINg2mdQB1AAABLAAFFAYIIgADACYiAA==.',['流浪']='流浪的愚者:BAAALAAECgIIAgAAAA==.',['流转']='流转的音符:BAACLAAFFH8IAAIOAAIIIR64JwDAAAAOAAIIIR64JwDAAAAsAAQKfxcAAg4ABggLIvkoALgBAA4ABggLIvkoALgBAAEsAAUUCAgiABIA5RoA.',['浩劫']='浩劫小橘子:BAAALAADCgEIAQAAAA==.',['浪迹']='浪迹丶随风:BAAALAAECgYIDgAAAA==.',['淼淼']='淼淼矮墩墩:BAAALAAECgYIDAAAAA==.',['火舞']='火舞一仨小孩:BAAALAAECgQIBAAAAA==.',['灬莫']='灬莫离:BAAALAADCgIIBgAAAA==.',['灵衣']='灵衣兮被被:BAAALAAECgYIDwAAAA==.',['熊猫']='熊猫咕咕树:BAAALAAECgEIAQAAAA==.熊猫用萌福掌:BAAALAAECggICAAAAA==.',['爱喝']='爱喝陨石拿铁:BAAALAADCgYIBgAAAA==.',['牛马']='牛马精神:BAAALAAECgYICAAAAA==.',['牧有']='牧有粗面:BAAALAAECgYIBwAAAA==.',['狐图']='狐图图:BAAALAAECgYIBgAAAA==.',['狗尔']='狗尔丹:BAAALAAECgYIEgAAAA==.',['狼叔']='狼叔术:BAAALAAECgYIDwAAAA==.',['猛哥']='猛哥很猛:BAAALAAECgYIBgAAAA==.',['玄鸟']='玄鸟灬惊春风:BAAALAAECggICAAAAA==.',['王某']='王某人:BAAALAADCgEIAQAAAA==.',['玛雅']='玛雅丶妲婕妮:BAAALAADCgMIAwAAAA==.',['瑶池']='瑶池有溪:BAAALAAECgQIBAAAAA==.',['画中']='画中仙:BAAALAADCgIIAQAAAA==.',['番茄']='番茄土豆鱼:BAAALAADCggICAAAAA==.',['白花']='白花蛇草水:BAABLAAFFH8UAAMCAAgIBg15HQB3AQACAAYITRF5HQB3AQABAAgIDQBQMgAAAAAAAA==.',['秋绥']='秋绥冬禧:BAAALAAECgYICwAAAA==.',['等等']='等等吖:BAAALAAECgQIBAAAAA==.等等啊:BAAALAAFFAgIAwAAAA==.',['糯米']='糯米兮兮丶:BAACLAAFFH8SAAIGAAYIdxGwGACNAQAGAAYIdxGwGACNAQAsAAQKfzAAAgYACAjnG+0nAEsCAAYACAjnG+0nAEsCAAAA.',['紫陌']='紫陌:BAAALAAECgIIAgAAAA==.',['红烧']='红烧茄子:BAAALAAECgMIAgAAAA==.',['纳瑞']='纳瑞安丶银风:BAABLAAECn8kAAIFAAYIXhkBgwBDAQAFAAYIXhkBgwBDAQAAAA==.',['织影']='织影小龙:BAABLAAFFH8FAAIGAAII4AqaNgCGAAAGAAII4AqaNgCGAAAAAA==.',['罐装']='罐装大白兔:BAAALAAECgIIAgAAAA==.',['美丽']='美丽不解释:BAAALAAECgYIDAAAAA==.',['美女']='美女一个:BAABLAAECn8iAAMJAAcI6BCBSAAqAQAJAAcI5xCBSAAqAQAWAAYIaAfZWAATAQAAAA==.',['老衲']='老衲老洗头:BAAALAADCgUIAwAAAA==.',['耍娃']='耍娃儿噜哒哒:BAABLAAFFH8KAAIXAAQIDwxbLwC6AAAXAAQIDwxbLwC6AAAAAA==.',['聖光']='聖光忽悠着你:BAAALAAECggIEAAAAA==.',['聪明']='聪明的星仔:BAABLAAECn8ZAAIFAAcIKBQzZwB0AQAFAAcIKBQzZwB0AQAAAA==.',['肥肠']='肥肠可乐:BAAALAAECgYIBwAAAA==.',['艾撒']='艾撒拉:BAAALAAECgYIBgAAAA==.',['艾欧']='艾欧瑟拉:BAAALAADCgQIBAAAAA==.',['艾泽']='艾泽拉澌之魂:BAAALAAECgYIBgAAAA==.',['花名']='花名册灬权:BAAALAAECgYIDgAAAA==.',['花开']='花开丶季节:BAAALAAECgYIEwAAAA==.',['花牌']='花牌战:BAAALAAFFAQIBAAAAA==.',['花语']='花语:BAAALAAECgYICgAAAA==.',['苏八']='苏八吃肉:BAAALAAFFAEIAQAAAA==.',['苯苯']='苯苯的领袖:BAACLAAFFH8hAAMFAAUIlxByUQALAQAFAAUIlxByUQALAQAHAAMIrwlbFgA+AAAsAAQKfy8AAwUABwj7HywpABMCAAUABwj7HywpABMCAAcABwheFTlYAFgBAAAA.',['莫言']='莫言看鸟:BAAALAAFFAQIBAAAAA==.',['蒲公']='蒲公英的旅行:BAABLAAFFH8GAAILAAQIfRixLQDwAAALAAQIfRixLQDwAAAAAA==.',['蛄蛹']='蛄蛹:BAAALAAFFAIIAgAAAA==.',['袁绍']='袁绍的小弟:BAAALAAECgIIAwAAAA==.',['裤当']='裤当有聖光:BAAALAAECggICAAAAA==.',['西门']='西门庆吃葡萄:BAAALAAECgQIBAAAAA==.',['诗悠']='诗悠洛:BAABLAAECn8UAAMFAAcI0xeEeQDqAQAFAAcItxeEeQDqAQAHAAMIohMilwCRAAAAAA==.',['诚实']='诚实者:BAAALAAECgQIBAAAAA==.',['误空']='误空:BAAALAADCgUIBQAAAA==.',['谷尔']='谷尔丹:BAAALAAECgMIAwABLAAFFAYIEQAVAL8UAA==.',['赞达']='赞达拉的传承:BAABLAAFFH8GAAIEAAYItQltEQA1AQAEAAYItQltEQA1AQAAAA==.',['赤色']='赤色彗星夏亚:BAAALAAECgYICwAAAA==.',['跳舞']='跳舞喵:BAAALAADCgQIBAAAAA==.',['迪亚']='迪亚:BAAALAAECgIIAgAAAA==.',['逆风']='逆风快递:BAAALAAECgYIBgAAAA==.',['那个']='那个奶德:BAABLAAFFH8IAAMMAAIIviM9BwDRAAAMAAIIviM9BwDRAAAYAAEIMQ5yagBJAAAAAA==.那个输出:BAAALAAECgEIAQAAAA==.',['邪能']='邪能路由器:BAABLAAECn8WAAISAAcIyx+9ZAAsAgASAAcIyx+9ZAAsAgAAAA==.',['郎情']='郎情妾意:BAAALAADCgcIBwAAAA==.',['醉蟹']='醉蟹醉蟹:BAABLAAFFH8JAAINAAUI3AIHHACnAAANAAUI3AIHHACnAAAAAA==.',['镇魂']='镇魂歌:BAAALAAECgcICAAAAA==.',['闵政']='闵政浩:BAAALAAFFAIIAgAAAA==.',['阳光']='阳光腐朽了心:BAAALAAECgYIDAAAAA==.',['难忘']='难忘的岁月:BAAALAAECgYIDgAAAA==.',['雄鹰']='雄鹰一样的咕:BAAALAADCgQIBAAAAA==.',['雅若']='雅若诗画:BAAALAADCgYIBgAAAA==.',['雷丶']='雷丶德:BAAALAAECgEIAQAAAA==.',['风之']='风之优雅:BAABLAAFFH8GAAIZAAMIigEaFwB6AAAZAAMIigEaFwB6AAAAAA==.风之圣灵:BAABLAAFFH8KAAIaAAYIRAj4BwDsAAAaAAYIRAj4BwDsAAAAAA==.',['风息']='风息的梦乡:BAAALAAECgIIAgAAAA==.',['骑士']='骑士我最怂:BAAALAAFFAIIBAAAAA==.',['鬼嗣']='鬼嗣:BAAALAAECgMIAwAAAA==.',['鬼烧']='鬼烧丶暴风:BAACLAAFFH8VAAMbAAUIhxy3CABhAQAbAAUIhxy3CABhAQAcAAIIYwePFQB2AAAsAAQKfxUAAxsACAhXIvgDAKQCABsACAhXIvgDAKQCABwAAQiVC6pVACwAAAAA.',['魔兽']='魔兽小英雄:BAAALAAECgYIDAAAAA==.',['鸑丶']='鸑丶鷟:BAABLAAFFH8GAAIFAAYItxDXNQBnAQAFAAYItxDXNQBnAQAAAA==.',['黑胡']='黑胡椒肋排:BAAALAAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end