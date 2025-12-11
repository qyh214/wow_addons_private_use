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
 local lookup = {'DemonHunter-Havoc','Mage-Arcane','Monk-Mistweaver','Monk-Windwalker','Priest-Holy','Priest-Shadow','Hunter-BeastMastery','DeathKnight-Frost','Shaman-Elemental','Warrior-Fury','Druid-Balance','Warrior-Protection','Unknown-Unknown','Paladin-Retribution','DeathKnight-Blood','Mage-Fire','Hunter-Marksmanship','Hunter-Survival','Shaman-Restoration','Druid-Restoration','DemonHunter-Vengeance','Evoker-Preservation','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Paladin-Protection','Monk-Brewmaster','Druid-Guardian','Rogue-Assassination','Rogue-Outlaw','Mage-Frost','Paladin-Holy','Evoker-Devastation',}; local provider = {region='CN',realm='达纳斯',name='CN',type='weekly',zone=44,date='2025-12-08',data={Al='Allisom:BAAALAAFFAIIAgAAAA==.',An='Andromeda:BAAALAAECgYICAAAAA==.Angely:BAAALAAFFAIIBAAAAA==.',As='Ashbringerr:BAABLAAFFH8FAAIBAAIIMRVqPwCaAAABAAIIMRVqPwCaAAAAAA==.',Bl='Bloodandsand:BAAALAAECgUICAAAAA==.',Ca='Casstiel:BAAALAAECgMIAwAAAA==.',Ch='Chocolate:BAAALAAFFAIIAwAAAA==.',Cs='Csisr:BAAALAAFFAIIBAAAAA==.',Da='Darklady:BAAALAAECgYICwAAAA==.',Et='Eternal:BAAALAAECgYIBgAAAA==.',Fi='Fireroy:BAAALAADCgUICAAAAA==.',Fr='Frieren:BAAALAAECgMIAwAAAA==.',Gr='Graceniu:BAAALAADCgEIAQAAAA==.',He='Hebby:BAAALAAECgYIBgAAAA==.',Hm='Hms:BAAALAAFFAMIAwAAAA==.',Ii='Iiris:BAAALAAFFAIIAgAAAA==.',Il='Illida:BAAALAAECgQIBAAAAA==.',Is='Isolation:BAABLAAFFH8IAAICAAIIdgssUwCOAAACAAIIdgssUwCOAAAAAA==.',Ji='Jinsir:BAAALAAECgEIAQAAAA==.',Jo='Joyelmilk:BAAALAAECggIDAAAAA==.',Ju='Jude:BAABLAAFFH8HAAMDAAMIvxELFwBlAAADAAIIlwoLFwBlAAAEAAEIFwSQGgA1AAAAAA==.Juliy:BAAALAAFFAIIAgAAAA==.',Ki='Kitelin:BAAALAAECgYIBgAAAA==.',Lo='Lovedoughnu:BAAALAAECgMIAwAAAA==.',Ma='Maus:BAACLAAFFH9HAAMFAAgIXx+6AgBIAgAFAAcIQCK6AgBIAgAGAAcI2ATlEABcAQAsAAQKf1AAAwUACAjKIjcPAO4CAAUACAjKIjcPAO4CAAYACAguEUkeAFUBAAAA.',Mi='Michee:BAAALAAFFAIIAgAAAA==.Milly:BAAALAAECgYICQAAAA==.',My='My:BAAALAAECgMIAwAAAA==.',Re='Readerc:BAAALAAFFAIIBAAAAA==.',Rh='Rhoaias:BAAALAAECggIEQAAAA==.',Sk='Skyla:BAABLAAFFH8pAAIFAAYI5xRaFgCiAQAFAAYI5xRaFgCiAQAAAA==.',St='Stardust:BAABLAAFFH8JAAIHAAUIKSWrJACiAQAHAAUIKSWrJACiAQAAAA==.',Sw='Sweetty:BAAALAAFFAIIAgAAAA==.',Sy='Syou:BAACLAAFFH8GAAIBAAIIlBJXWgBDAAABAAIIlBJXWgBDAAAsAAQKfxgAAgEABggQHkE7AG8BAAEABggQHkE7AG8BAAEsAAUUBQgnAAUAyxsA.',Te='Tearsgirl:BAAALAAECgYICAAAAA==.',To='Top:BAAALAADCgIIAgAAAA==.Topaz:BAAALAAFFAIIAgAAAA==.',Vi='Viwen:BAAALAAECgYIBgAAAA==.',Wi='Wireshark:BAABLAAFFH8iAAIIAAYIhyGuKACWAQAIAAYIhyGuKACWAQABLAAFFAYIIwAJAFcYAA==.',Xs='Xstxst:BAAALAADCgEIAQAAAA==.',Ya='Yangzixuan:BAABLAAECn8WAAIKAAcIXwfXdAC5AAAKAAcIXwfXdAC5AAAAAA==.',['一叮']='一叮:BAAALAADCgIIAgAAAA==.',['一吻']='一吻天荒:BAABLAAFFH8GAAILAAIIwQilOgAzAAALAAIIwQilOgAzAAAAAA==.',['一念']='一念一輪回:BAABLAAFFH8LAAMKAAQIwxRwLQD1AAAKAAQInxRwLQD1AAAMAAEIJRlEPQAAAAAAAA==.',['一朝']='一朝酒晚舞一:BAAALAAECgYIBgAAAA==.',['一氧']='一氧化三氢:BAAALAAECgYIBgAAAA==.',['一雪']='一雪团团一:BAAALAAFFAIIAgABLAAFFAgIBAANAAAAAA==.',['丁自']='丁自酷:BAABLAAFFH8OAAIOAAIIiyRQIQDMAAAOAAIIiyRQIQDMAAAAAA==.',['七夜']='七夜圣光:BAAALAAECgIIAgAAAA==.',['三太']='三太子敖丙:BAAALAAECggICAAAAA==.',['三百']='三百天的守候:BAAALAAECgQIBAAAAA==.三百天的沐言:BAAALAAECggIDAAAAA==.',['不可']='不可名状:BAAALAAFFAIIAgAAAA==.',['不想']='不想游泳的鱼:BAAALAAECgYICQAAAA==.',['不爱']='不爱洗澡:BAAALAAFFAEIAQAAAA==.',['不醉']='不醉酒:BAAALAADCggIDwAAAA==.',['世宗']='世宗大王:BAABLAAFFH8GAAIOAAIIbQmMcAA+AAAOAAIIbQmMcAA+AAAAAA==.',['两只']='两只小白兔:BAAALAAFFAIIAgAAAA==.',['两片']='两片菜叶:BAAALAADCgIIAgAAAA==.',['丶俄']='丶俄性空虚:BAAALAAECgYIBgAAAA==.',['丶痛']='丶痛哭流涕:BAABLAAFFH8FAAIMAAIIxAesOAAnAAAMAAIIxAesOAAnAAAAAA==.',['丷夜']='丷夜火琉萤丷:BAAALAAFFAIIAgAAAA==.',['为了']='为了奥丁:BAAALAAECgYIBgAAAA==.',['乊夜']='乊夜火琉萤乊:BAACLAAFFH8JAAMPAAUI7AVgEwCcAAAPAAUIqwNgEwCcAAAIAAIIXwtrewCKAAAsAAQKfycAAwgACAgXIOZXAEcCAAgACAgXIOZXAEcCAA8ABwiYElYhAH0BAAAA.',['乌兰']='乌兰巴托的夜:BAAALAAECgYIBgAAAA==.',['九月']='九月狂战:BAAALAAECgYICAAAAA==.',['九鬼']='九鬼:BAAALAADCgUIBQAAAA==.',['二汤']='二汤圆:BAAALAADCgMIAwAAAA==.',['云霄']='云霄鶬:BAABLAAFFH8JAAMCAAIIwRtQOQCoAAACAAIIwRtQOQCoAAAQAAEIygJADgA9AAABLAAFFAMIEAARAB8TAA==.',['亦兮']='亦兮若之:BAACLAAFFH8JAAISAAIIPB/bAgCxAAASAAIIPB/bAgCxAAAsAAQKfyYAAhIACAjyI3cCAAcDABIACAjyI3cCAAcDAAAA.',['仲夏']='仲夏夜语:BAABLAAFFH8IAAITAAII4ASgZgBaAAATAAII4ASgZgBaAAAAAA==.',['企鹅']='企鹅不会飞:BAABLAAFFH8FAAIUAAMIEASDQQBwAAAUAAMIEASDQQBwAAAAAA==.',['伊俐']='伊俐丹灬怒风:BAABLAAFFH8IAAIBAAgIAgGhawAyAAABAAgIAgGhawAyAAAAAA==.',['伊梅']='伊梅尔达:BAAALAAECgQIBQAAAA==.',['伍月']='伍月飘:BAAALAADCgIIAgAAAA==.',['会放']='会放电的木木:BAAALAADCggIDgAAAA==.',['你付']='你付出了什么:BAACLAAFFH8jAAIBAAYIMhzZDQDLAQABAAYIMhzZDQDLAQAsAAQKfyAAAwEACAjQHvQ7AHACAAEACAjQHvQ7AHACABUAAQgRBwRvAB8AAAAA.',['你是']='你是不是聋鸣:BAABLAAFFH8NAAIWAAcIPRj0BQApAgAWAAcIPRj0BQApAgAAAA==.',['你的']='你的朋友:BAAALAAFFAQIBAAAAA==.',['你踩']='你踩我尾巴了:BAAALAAECgQIBgAAAA==.',['偏爱']='偏爱狐狸精:BAAALAAECgYIBgAAAA==.',['元丶']='元丶青花:BAAALAAECgQIBAAAAA==.',['先登']='先登斩将者:BAAALAAFFAIIBAAAAA==.',['光的']='光的阴影:BAAALAAFFAIIBAAAAA==.',['兜兜']='兜兜里有糖:BAAALAAECgMIAwAAAA==.兜兜里没箭:BAAALAAFFAIIAgAAAA==.',['六十']='六十一号快递:BAAALAAECgEIAQAAAA==.',['兮黎']='兮黎:BAACLAAFFH8dAAIBAAUI7xqUHAD5AAABAAUI7xqUHAD5AAAsAAQKfyEAAgEACAjeIAouAKUCAAEACAjeIAouAKUCAAAA.',['兰姨']='兰姨:BAAALAAECgYIBgAAAA==.',['兰婆']='兰婆婆:BAAALAAECgYIDAAAAA==.',['兰心']='兰心蕙性:BAAALAAECgYIDQAAAA==.',['冰冷']='冰冷的小贤:BAABLAAFFH8QAAIXAAUIBxR3NwAzAQAXAAUIBxR3NwAzAQAAAA==.',['冰峰']='冰峰骑士:BAAALAAECgMIAwAAAA==.',['净魂']='净魂之刃丶:BAAALAAFFAIIAgAAAA==.',['凤凰']='凤凰传奇:BAAALAAECgYICQAAAA==.',['划水']='划水的鱼:BAAALAAECgIIAgAAAA==.',['剑影']='剑影无痕:BAABLAAFFH8IAAIKAAIIHAaBWgA8AAAKAAIIHAaBWgA8AAAAAA==.',['剑盾']='剑盾华尔兹:BAAALAADCgIIAgAAAA==.',['剑魄']='剑魄:BAAALAAFFAIIAgAAAA==.',['勤劳']='勤劳的社畜:BAABLAAECn8eAAIIAAgI6wsUTQBeAQAIAAgI6wsUTQBeAQAAAA==.',['北宸']='北宸闪闪:BAAALAAECgcIBwAAAA==.',['十三']='十三猎幺:BAABLAAECn8YAAIHAAgIvRR9awBtAQAHAAgIvRR9awBtAQAAAA==.',['千寻']='千寻:BAAALAADCgYIBAAAAA==.',['卓尔']='卓尔狂箭:BAAALAAECggICAAAAA==.',['卡尔']='卡尔丶弗兰兹:BAAALAAECgEIAQAAAA==.',['卡特']='卡特尼娜:BAAALAAFFAIIAgAAAA==.',['卡瑞']='卡瑞亚斯德:BAABLAAECn8XAAIYAAYIyBDkPQB1AQAYAAYIyBDkPQB1AQAAAA==.',['印紫']='印紫:BAAALAAECgYIDAAAAA==.',['又是']='又是新的一天:BAAALAADCgMIAwAAAA==.',['古小']='古小龟:BAAALAAECgUICAAAAA==.',['只想']='只想抓宝宝:BAAALAAECgMIAwAAAA==.只想用头撞墙:BAACLAAFFH8SAAIIAAYI+RXtLQCEAQAIAAYI+RXtLQCEAQAsAAQKfywABAgACAi2IAsxAK8CAAgACAhaHgsxAK8CAA8ABwh9INoMAIUCABkABAieE407AP0AAAEsAAUUBQgRAA4A/x8A.',['史域']='史域黄:BAAALAADCgIIAgAAAA==.',['号子']='号子也疯狂:BAAALAADCgUIBQAAAA==.',['司舞']='司舞柳:BAAALAAECgYIBgAAAA==.',['吃不']='吃不胖的胖子:BAAALAAFFAIIAwAAAA==.',['吉尓']='吉尓伽美什:BAAALAADCgYIBgAAAA==.',['吊丝']='吊丝睡韩红:BAAALAAECggICAAAAA==.',['向左']='向左向右:BAABLAAECn8bAAMXAAcI0xKWOQBkAQAXAAcI0xKWOQBkAQAYAAEI5AsHNwA4AAAAAA==.',['听雨']='听雨书望太湖:BAAALAAFFAIIAgAAAA==.',['吾之']='吾之所往:BAABLAAFFH8QAAIKAAMIahv/MwCnAAAKAAMIahv/MwCnAAAAAA==.',['和道']='和道一文字:BAABLAAFFH8GAAIOAAIIEgU3dAA8AAAOAAIIEgU3dAA8AAAAAA==.',['咻咻']='咻咻:BAABLAAFFH8FAAIHAAMIaAoLeABwAAAHAAMIaAoLeABwAAAAAA==.',['哈基']='哈基龙:BAAALAAFFAIIAwAAAA==.',['哈士']='哈士骑:BAAALAAECgcIDgAAAA==.',['啥也']='啥也不知道:BAAALAADCgEIAQAAAA==.',['喜仔']='喜仔:BAAALAAECgUIBQAAAA==.',['嗜血']='嗜血的流星雨:BAAALAADCgIIAgAAAA==.',['嘉维']='嘉维尔:BAAALAAFFAIIAgAAAA==.',['嘘灬']='嘘灬:BAAALAAFFAIIAgAAAA==.',['囚牛']='囚牛:BAAALAAECgEIAQAAAA==.',['四灵']='四灵牛:BAAALAAECgYIEgAAAA==.四灵驱邪之牛:BAAALAAECgcIDQAAAA==.',['回到']='回到昨天:BAAALAADCgIIAgAAAA==.',['圄圄']='圄圄兔:BAAALAADCgcIBwAAAA==.',['圣光']='圣光大叔:BAABLAAFFH8IAAIOAAIIdRHiRACbAAAOAAIIdRHiRACbAAAAAA==.圣光大哥:BAAALAAECgIIAgAAAA==.圣光热不死你:BAAALAAECgcICQAAAA==.',['地狱']='地狱碎魂者:BAABLAAFFH8IAAIXAAMIChCMTgCCAAAXAAMIChCMTgCCAAAAAA==.地狱邪眼:BAAALAADCgEIAQAAAA==.',['地那']='地那:BAAALAAECgIIAgAAAA==.',['基恩']='基恩么:BAACLAAFFH8OAAMBAAQIrxkLNADrAAABAAQIgBYLNADrAAAVAAIIWRsqDwBTAAAsAAQKfxUAAxUABgg5HMcjAJcBAAEABgjwGbp3ANYBABUABggrGccjAJcBAAAA.',['塔拉']='塔拉夏之魂:BAAALAAECgYIBgAAAA==.',['塞巴']='塞巴斯蒂安丶:BAAALAADCgUICAABLAAFFAgIGAACAAomAA==.',['壹米']='壹米陽光:BAAALAAECgUIBQAAAA==.',['复活']='复活猫猫:BAAALAAFFAIIAgAAAA==.',['夏冬']='夏冬没回来:BAAALAAECgIIAwAAAA==.',['夏日']='夏日海滨:BAAALAAECgYIEAAAAA==.',['夕梨']='夕梨:BAABLAAFFH8IAAIFAAIISRktLgCRAAAFAAIISRktLgCRAAAAAA==.',['外强']='外强中干:BAAALAAECgUIBQAAAA==.',['夜之']='夜之姬:BAAALAAECgUIBQAAAA==.',['夜天']='夜天之书:BAAALAAECggIDgAAAA==.',['夜幽']='夜幽游:BAAALAADCgMIAwAAAA==.',['夜影']='夜影蓝:BAAALAAECgIIAgAAAA==.',['夜憂']='夜憂慯:BAAALAAFFAIIAgAAAA==.',['夢幻']='夢幻丶薄桜:BAACLAAFFH8nAAMFAAUIyxuqGQCFAQAFAAUIyxuqGQCFAQAGAAMIDRPBGQDkAAAsAAQKfz0AAwYACAjiG00fAHgCAAYACAjiG00fAHgCAAUACAhcFa5IALMBAAAA.',['大伙']='大伙一起上丶:BAABLAAFFH8HAAIHAAUIRxBsVQD8AAAHAAUIRxBsVQD8AAAAAA==.',['大只']='大只青头籽:BAACLAAFFH8GAAIIAAIIyRZndACOAAAIAAIIyRZndACOAAAsAAQKfyEAAxkABggsINMbANwBABkABgjNG9MbANwBAAgABghEHgREAHcBAAAA.',['大圣']='大圣:BAAALAAFFAIIBAAAAA==.',['大梦']='大梦无涯:BAAALAAECgIIAgAAAA==.',['大火']='大火锅:BAAALAAECgIIAgAAAA==.',['大眼']='大眼猎猎:BAABLAAFFH8GAAIHAAII+wddeAB1AAAHAAII+wddeAB1AAAAAA==.大眼睛狂战:BAABLAAFFH8HAAIMAAMIwQobIwBlAAAMAAMIwQobIwBlAAAAAA==.大眼睛的乖乖:BAAALAADCgcIBwAAAA==.大眼睛萨满:BAABLAAFFH8FAAITAAMI1g7XSACNAAATAAMI1g7XSACNAAAAAA==.大眼睛骑士:BAAALAAECgYIBgAAAA==.',['天使']='天使小朱:BAAALAAECgUIBAAAAA==.天使陨落:BAAALAAECgYIBgAAAA==.',['天台']='天台上了泪水:BAAALAAFFAIIAgAAAA==.',['天堂']='天堂妖妖:BAABLAAFFH8IAAIOAAII+BPbXgBHAAAOAAII+BPbXgBHAAAAAA==.',['天风']='天风小个子:BAAALAAFFAIIAgAAAA==.',['天魔']='天魔行:BAAALAAFFAIIBAAAAA==.',['失业']='失业的江南:BAAALAAFFAIIAgAAAA==.',['头上']='头上有对犄角:BAAALAADCgQIBAAAAA==.',['头顶']='头顶灰机灰过:BAAALAAECgYIDAAAAA==.',['夸乌']='夸乌特莫克:BAAALAAFFAIIBAAAAA==.',['好大']='好大一坨:BAAALAAFFAIIAgAAAA==.',['妖丶']='妖丶月:BAAALAAECgMIAwAAAA==.',['妖月']='妖月丶:BAAALAAFFAIIAwAAAA==.',['妙不']='妙不可言:BAAALAAECgYICwAAAA==.',['姜嬷']='姜嬷嬷:BAAALAAECgYIBgAAAA==.',['姜小']='姜小焱:BAAALAAECgYICQAAAA==.',['姜笑']='姜笑笑:BAAALAAECgYIBgAAAA==.',['姿势']='姿势乱摆:BAABLAAFFH8MAAIIAAQIfhZscgBPAAAIAAQIfhZscgBPAAAAAA==.',['娜格']='娜格斯风语者:BAAALAAECgMIBQAAAA==.',['子龙']='子龙卸了甲:BAAALAAECgUIBQAAAA==.',['孤独']='孤独之猎:BAABLAAFFH8PAAIHAAUI1AyLWgDjAAAHAAUI1AyLWgDjAAAAAA==.',['安东']='安东尼奥:BAAALAAECggIBgAAAA==.安东尼奥斯基:BAABLAAFFH8OAAIKAAUIwBSxJABLAQAKAAUIwBSxJABLAQAAAA==.',['安赫']='安赫尔:BAAALAAECgYIBwAAAA==.',['安静']='安静的猫爪子:BAAALAAECgYIBgAAAA==.',['完颜']='完颜亮:BAABLAAFFH8MAAIBAAYIcRRfHQCQAQABAAYIcRRfHQCQAQAAAA==.',['寂夜']='寂夜:BAAALAAFFAQIBAAAAA==.',['寳貝']='寳貝猎:BAABLAAFFH8GAAIRAAII2Qf+GgAvAAARAAII2Qf+GgAvAAAAAA==.',['寶貝']='寶貝丶尐龙人:BAAALAAFFAIIBAAAAA==.寶貝尐棍棍:BAABLAAFFH8KAAITAAII4wkNZwBUAAATAAII4wkNZwBUAAAAAA==.寶貝尐騎士:BAABLAAFFH8KAAMOAAIIhAPwfwAwAAAOAAIIUwPwfwAwAAAaAAIIWgJAJQAWAAAAAA==.寶貝术妹:BAAALAAFFAIIBAAAAA==.寶貝熊:BAABLAAFFH8GAAIbAAIIIQOoJAAcAAAbAAIIIQOoJAAcAAAAAA==.寶貝贼:BAAALAAFFAIIAgAAAA==.',['射击']='射击假死:BAAALAAFFAIIAgAAAA==.',['小巧']='小巧卝朦胧:BAACLAAFFH8ZAAIFAAYIzQm7CwCUAQAFAAYIzQm7CwCUAQAsAAQKfxkAAgUACAhWEU5CAM4BAAUACAhWEU5CAM4BAAAA.',['小瘦']='小瘦猫:BAAALAAECgYIBgAAAA==.',['小馨']='小馨猪:BAABLAAFFH8GAAIXAAIIywUDbQA0AAAXAAIIywUDbQA0AAABLAAFFAYIGwAIACcgAA==.',['屠龙']='屠龙咆哮:BAACLAAFFH8PAAIHAAMICxiDSQCbAAAHAAMICxiDSQCbAAAsAAQKfyMAAgcACAifH1AnALoCAAcACAifH1AnALoCAAAA.',['左右']='左右开弓:BAACLAAFFH8fAAITAAYIphtuEgDRAQATAAYIphtuEgDRAQAsAAQKfxgAAhMACAjoHOAkAH8CABMACAjoHOAkAH8CAAAA.',['年糕']='年糕大兄本尊:BAABLAAFFH8MAAIcAAIIBRYBCAByAAAcAAIIBRYBCAByAAAAAA==.',['幽火']='幽火凝霜:BAAALAAECgYICwAAAA==.',['幽若']='幽若蓝:BAAALAAECgYIDgAAAA==.',['弗吉']='弗吉达之怒丶:BAABLAAFFH8FAAIKAAMISBOOPACAAAAKAAMISBOOPACAAAAAAA==.',['张凌']='张凌远:BAAALAAECgQIBwAAAA==.',['强妹']='强妹:BAACLAAFFH8QAAIIAAUI3Q0LSgARAQAIAAUI3Q0LSgARAQAsAAQKfycAAwgACAjOGsMaABkCAAgACAjOGsMaABkCABkAAggTDP9OAHcAAAAA.',['当个']='当个好奶爸:BAAALAADCgMIAwAAAA==.',['得意']='得意:BAAALAAECgYIDAAAAA==.',['得闲']='得闲执翻剂:BAABLAAECn8cAAMdAAYIfhxmJAD2AQAdAAYIfhxmJAD2AQAeAAUIXQZQFwC2AAAAAA==.',['德尼']='德尼骑:BAAALAAECgYIDAAAAA==.',['心语']='心语:BAACLAAFFH8bAAQIAAUIJyBqFwCGAQAIAAQIsCBqFwCGAQAZAAMIARkIBwACAQAPAAII0BItEwByAAAsAAQKfxQABBkACAh/GKMaAOYBABkACAgoF6MaAOYBAA8ABghsDJotAA8BAAgAAggOFPivAIMAAAAA.',['必须']='必须修改名字:BAAALAADCgYIBgAAAA==.',['忍你']='忍你好久啦:BAAALAAFFAIIBAAAAA==.',['忘了']='忘了什么:BAAALAAFFAIIAgAAAA==.',['快乐']='快乐鹰:BAAALAAECgEIAQAAAA==.',['恩歌']='恩歌拉夏:BAAALAAECggICgAAAA==.',['恶灵']='恶灵骑士:BAAALAAECgYIDAAAAA==.',['恶魔']='恶魔教主:BAAALAAECgMIAwAAAA==.恶魔猫:BAAALAAECgYIBgAAAA==.',['情字']='情字何解:BAAALAADCgUIBQAAAA==.',['愤怒']='愤怒的無隐:BAAALAAECgUIBQAAAA==.愤怒的达芬奇:BAAALAAECgUIBQAAAA==.愤怒的野马:BAAALAADCgQIBAAAAA==.',['戈达']='戈达克咒角:BAAALAAECgUIBQAAAA==.',['成虫']='成虫:BAAALAAECgQIBAAAAA==.',['我们']='我们不一样:BAAALAAFFAIIAgAAAA==.',['我是']='我是天上无敌:BAAALAAECgYIDQAAAA==.我是狮子座丶:BAABLAAFFH8GAAIIAAIISR/6OgC8AAAIAAIISR/6OgC8AAABLAAFFAgIFQAIAM4TAA==.',['我木']='我木有小黄花:BAAALAAECgEIAQAAAA==.',['我碌']='我碌嘢好劲:BAABLAAFFH8MAAIMAAIIhhcjJwBLAAAMAAIIhhcjJwBLAAAAAA==.',['托尼']='托尼贾:BAAALAAECgYIBgAAAA==.',['报告']='报告典狱长:BAAALAAECgIIAgAAAA==.',['掰喵']='掰喵咪:BAAALAAECgEIAQAAAA==.',['插头']='插头:BAAALAADCgUIBQAAAA==.',['摩拉']='摩拉克斯:BAAALAADCgEIAQAAAA==.',['故乡']='故乡的夜狼犬:BAAALAADCggICAAAAA==.',['斬魔']='斬魔者:BAAALAADCgYIBgAAAA==.',['无双']='无双避风港:BAAALAAECgUIBQAAAA==.',['无所']='无所谓的冲锋:BAAALAAECgUIBgAAAA==.无所谓的飞盾:BAAALAADCgcIBwAAAA==.',['无畏']='无畏之心:BAAALAAECgMIAwAAAA==.',['无限']='无限复仇:BAAALAADCgMIAwAAAA==.',['昊丶']='昊丶:BAAALAAECgYIBgAAAA==.',['星野']='星野残红:BAAALAAECgYIBgAAAA==.',['春蚕']='春蚕到丝方尽:BAABLAAFFH8FAAIJAAUIHRO+IgAvAQAJAAUIHRO+IgAvAQAAAA==.',['晓安']='晓安:BAACLAAFFH8UAAIHAAgIlhzIBQAjAgAHAAgIlhzIBQAjAgAsAAQKfyAAAwcACAhEIdAxAJICAAcACAieINAxAJICABEACAg5GzIhAF8CAAAA.',['晚晴']='晚晴暮暮:BAAALAADCgIIAgAAAA==.',['晨曦']='晨曦月影:BAAALAAFFAIIBAAAAA==.',['暗夜']='暗夜猫爪:BAAALAAECgQIBAAAAA==.',['暗香']='暗香盈秀:BAAALAAECgQIBAAAAA==.',['暮筱']='暮筱:BAAALAAECggIAgAAAA==.',['暮雪']='暮雪微雨:BAABLAAFFH8GAAIOAAII6wRDgQAtAAAOAAII6wRDgQAtAAAAAA==.',['暴走']='暴走一戟灞:BAABLAAFFH8IAAIBAAII4RlINgChAAABAAII4RlINgChAAAAAA==.',['最伟']='最伟大的骑士:BAAALAAECgYIBgAAAA==.',['最后']='最后旳挽歌:BAAALAAECgEIAQAAAA==.',['月下']='月下:BAAALAAFFAIIAgAAAA==.月下美人醉:BAAALAAECgEIAQAAAA==.',['月半']='月半熊:BAABLAAFFH8VAAMXAAYIrhueJQCFAQAXAAYI9BqeJQCFAQAYAAEIbyTlIQBgAAABLAAFFAgIDgAYAMkdAA==.',['月神']='月神:BAABLAAFFH8JAAIUAAIIgxjtLgB3AAAUAAIIgxjtLgB3AAAAAA==.',['月色']='月色繁华:BAAALAAECgYIDQAAAA==.',['有生']='有生之年:BAAALAADCgYIBgAAAA==.',['未来']='未来之音:BAAALAAECgYIEwAAAA==.',['术手']='术手巫策:BAACLAAFFH8IAAIXAAUIegw8PQAQAQAXAAUIegw8PQAQAQAsAAQKfxoAAhcABgiUFxpCAEIBABcABgiUFxpCAEIBAAAA.',['杀到']='杀到满意:BAAALAAECgEIAQAAAA==.',['李娜']='李娜莉:BAABLAAFFH8PAAIOAAMIWxHFRgCCAAAOAAMIWxHFRgCCAAAAAA==.',['李干']='李干嘛:BAABLAAFFH8GAAIOAAQIYh8PMgD4AAAOAAQIYh8PMgD4AAAAAA==.',['杨过']='杨过在哪里:BAAALAAECgYIEgAAAA==.',['杰克']='杰克使佩洛:BAAALAADCgYIBgAAAA==.',['极丶']='极丶光:BAAALAAFFAIIAgAAAA==.',['枫雨']='枫雨无晴:BAAALAADCgEIAQAAAA==.',['柜子']='柜子里的美丽:BAABLAAECn8ZAAIYAAcIwBf9HQAOAgAYAAcIwBf9HQAOAgAAAA==.',['树屿']='树屿牧歌:BAAALAAECggICAAAAA==.',['桃之']='桃之幺幺:BAABLAAFFH8FAAIBAAIIRwdrYwA9AAABAAIIRwdrYwA9AAAAAA==.',['桑德']='桑德兰之风:BAAALAAECgIIAgAAAA==.',['樱花']='樱花草莓糖:BAAALAAFFAIIBAABLAAFFAMIBwAFAPURAA==.',['橘味']='橘味汽水:BAABLAAFFH8FAAIOAAMIowsHSwBvAAAOAAMIowsHSwBvAAAAAA==.',['武极']='武极:BAAALAAECgcIBwAAAA==.',['歪头']='歪头大棒槌:BAAALAADCgYIBgAAAA==.',['死亡']='死亡之狐:BAABLAAFFH8NAAIIAAII6wzfiQBCAAAIAAII6wzfiQBCAAAAAA==.',['气死']='气死人:BAAALAAECgUIBgAAAA==.',['水波']='水波波:BAABLAAFFH8JAAIOAAYIYwZsNADjAAAOAAYIYwZsNADjAAAAAA==.',['永恒']='永恒灬之术:BAABLAAFFH8FAAMYAAUIswUnCwBpAAAXAAMIqARsUQB1AAAYAAIIRQcnCwBpAAAAAA==.永恒灬保安:BAAALAAECgYIDQAAAA==.永恒的希女王:BAAALAAFFAIIAgAAAA==.',['汝之']='汝之所向:BAABLAAFFH8rAAIFAAcIQCQNAwC/AgAFAAcIQCQNAwC/AgAAAA==.',['江浸']='江浸月丶:BAAALAAFFAIIAgAAAA==.',['沐子']='沐子:BAAALAAECgMIAwAAAA==.',['沙司']='沙司避雷:BAAALAADCgYIDAAAAA==.',['沙布']='沙布兰尼古:BAABLAAFFH8hAAMCAAYIUxwCGQC8AQACAAYIUxwCGQC8AQAfAAEIIxbeHgBHAAABLAAFFAYIIwAJAFcYAA==.',['沙漠']='沙漠之狐:BAABLAAFFH8GAAIOAAIINhnJXABIAAAOAAIINhnJXABIAAAAAA==.沙漠独角兽:BAAALAAFFAMIAwAAAA==.',['泛泛']='泛泛于滨:BAAALAAFFAIIAwAAAA==.',['波涛']='波涛呀:BAABLAAFFH8GAAIIAAIIgAZBkwA9AAAIAAIIgAZBkwA9AAAAAA==.',['泰岚']='泰岚鍀丶语风:BAAALAAECgUIBQAAAA==.',['泰沙']='泰沙拉克重工:BAABLAAFFH8FAAIOAAIIfAr5cwA8AAAOAAIIfAr5cwA8AAAAAA==.',['洪九']='洪九:BAAALAAECgQIBQAAAA==.',['派大']='派大星的智慧:BAAALAAECgQIBAAAAA==.',['流光']='流光剑:BAABLAAFFH8FAAIIAAMIyw9DaAB5AAAIAAMIyw9DaAB5AAAAAA==.流光夏央:BAAALAAECggICwAAAA==.',['流刃']='流刃若火:BAAALAAFFAIIAwAAAA==.',['浅尝']='浅尝思念:BAABLAAFFH8MAAIVAAIIdBdmDQCJAAAVAAIIdBdmDQCJAAAAAA==.',['浮生']='浮生半日:BAAALAAFFAIIAgAAAA==.浮生尽:BAAALAAECgQICAAAAA==.',['海洋']='海洋之翼:BAABLAAFFH8HAAMCAAIIvxRXSgCWAAACAAIInQ9XSgCWAAAfAAEI3hgCHgBKAAAAAA==.',['淺笑']='淺笑随訫:BAAALAAECgQIBAAAAA==.',['漂亮']='漂亮的流氓:BAAALAAECgIIAgAAAA==.',['潇洒']='潇洒奶一回:BAAALAAECgYICAAAAA==.',['瀍壑']='瀍壑朱樱:BAAALAAECgMIBAAAAA==.',['火青']='火青雲:BAAALAAECggICAAAAA==.',['灰太']='灰太狼大官人:BAAALAAECgMIAwAAAA==.',['灵冰']='灵冰:BAAALAAFFAIIBAAAAA==.',['灵魂']='灵魂无畏:BAACLAAFFH8NAAIJAAMI/hRgNACOAAAJAAMI/hRgNACOAAAsAAQKfyAAAgkABwhqHMstAFgCAAkABwhqHMstAFgCAAAA.',['炒年']='炒年糕:BAACLAAFFH8KAAIOAAIIohTHPwCeAAAOAAIIohTHPwCeAAAsAAQKfxQAAg4ABgjWIqc3ALgBAA4ABgjWIqc3ALgBAAAA.',['炙萱']='炙萱:BAAALAAECgcIBwAAAA==.',['爱吃']='爱吃饺子:BAABLAAFFH8NAAIdAAMI7BNBFQCZAAAdAAMI7BNBFQCZAAAAAA==.',['牛牛']='牛牛奔:BAAALAAECgYIDAAAAA==.',['牛筋']='牛筋干挑:BAABLAAFFH8KAAIOAAQIhQ4GNwDPAAAOAAQIhQ4GNwDPAAAAAA==.',['牧得']='牧得办法:BAAALAAECgYIBgAAAA==.',['牧羊']='牧羊人麻薯:BAAALAAECgUIBQAAAA==.',['狂猎']='狂猎天灾:BAAALAADCgUIBQAAAA==.',['独品']='独品:BAAALAAECgYICgAAAA==.',['狼面']='狼面仁心:BAAALAAECgYICQAAAA==.',['猎妈']='猎妈:BAAALAAECgMIAwAAAA==.',['猎手']='猎手与猎物:BAAALAAECgEIAQAAAA==.',['猫薄']='猫薄荷:BAAALAAECgYICwAAAA==.',['王者']='王者永恒:BAAALAADCgYIBwAAAA==.',['玖玥']='玖玥:BAAALAADCgMIAwAAAA==.',['玛格']='玛格汉灬酋长:BAAALAAFFAIIAgAAAA==.',['玝後']='玝後丶艿茶:BAAALAAFFAIIBAAAAA==.',['琉璃']='琉璃冬:BAAALAADCggICAAAAA==.',['甲乙']='甲乙丙丁:BAAALAADCgMIAwAAAA==.',['疯狂']='疯狂输絀:BAAALAAECgYICAAAAA==.',['疾風']='疾風訊雷:BAAALAAECgYIBgAAAA==.',['白河']='白河愁:BAAALAAFFAIIAgAAAA==.',['白虎']='白虎:BAAALAADCgMIAwAAAA==.',['白银']='白银爵士:BAAALAAECgUIBQAAAA==.',['白雪']='白雪夏夜:BAAALAADCgYIBgAAAA==.',['百撕']='百撕卜得骑姐:BAAALAAECgMIBQAAAA==.',['皮皮']='皮皮浪:BAABLAAECn8WAAMOAAgIcxuwbQAOAgAOAAgIMxqwbQAOAgAaAAgIEBadJwDGAQAAAA==.',['盗猎']='盗猎者卡卡西:BAAALAAFFAIIBAAAAA==.',['盼盼']='盼盼:BAACLAAFFH8nAAIKAAYILw4EIQBmAQAKAAYILw4EIQBmAQAsAAQKfy4AAgoACAgAF4I9AD8CAAoACAgAF4I9AD8CAAAA.',['短尾']='短尾猫不吃鱼:BAABLAAFFH8GAAIIAAIIZRW9cwBNAAAIAAIIZRW9cwBNAAAAAA==.短尾猫爱吃鱼:BAABLAAFFH8GAAITAAIIAAUdcQBKAAATAAIIAAUdcQBKAAAAAA==.',['破晓']='破晓晨星:BAABLAAFFH8JAAIHAAYITAozUwAGAQAHAAYITAozUwAGAQAAAA==.',['神秘']='神秘壹号演员:BAACLAAFFH8IAAIHAAII9gwOrAA6AAAHAAII9gwOrAA6AAAsAAQKfxgAAgcABghUF1SGAD8BAAcABghUF1SGAD8BAAAA.',['秦广']='秦广王:BAAALAAFFAIIAgAAAA==.',['秦皇']='秦皇扫六合:BAABLAAECn8YAAIIAAYIJBnxowDBAQAIAAYIJBnxowDBAQAAAA==.',['空空']='空空没那么难:BAAALAAECgIIAgAAAA==.',['竹曉']='竹曉曉:BAAALAAECgQIBAAAAA==.',['箭破']='箭破水中月:BAACLAAFFH8MAAIHAAMI/RinbQCJAAAHAAMI/RinbQCJAAAsAAQKfx0AAwcABghXIVk8ANgBAAcABghXIVk8ANgBABEABAgIEyR8AOgAAAEsAAUUBQgRAA4A/x8A.',['米兰']='米兰小裁缝:BAAALAAFFAIIAgAAAA==.',['糖三']='糖三葬:BAAALAAFFAIIAgAAAA==.',['紅叶']='紅叶舞:BAAALAAECgUICQAAAA==.',['紅葉']='紅葉舞:BAAALAAECgYIEwAAAA==.',['紫色']='紫色虚无:BAAALAAFFAIIBAAAAA==.紫色隐身者:BAAALAAFFAIIAgAAAA==.',['红叶']='红叶舞:BAAALAAECgYIBgAAAA==.',['红灬']='红灬茶:BAABLAAFFH8GAAITAAYIgR4NDwDyAQATAAYIgR4NDwDyAQAAAA==.',['红葉']='红葉舞:BAAALAAECgYICQAAAA==.',['纪念']='纪念:BAAALAAECgYICQAAAA==.',['纯情']='纯情小凤凰:BAAALAAECgYIBgAAAA==.纯情小狐狸:BAACLAAFFH8lAAITAAYIEQ+pKAAgAQATAAYIEQ+pKAAgAQAsAAQKfzQAAhMACAhgG0MSAGICABMACAhgG0MSAGICAAAA.',['纳比']='纳比斯町:BAAALAAECgYIDAABLAAFFAYIIQAIACUbAA==.',['纸皮']='纸皮核桃:BAAALAAFFAIIAgAAAA==.',['终极']='终极皮皮怪:BAAALAAFFAIIAgAAAA==.',['给你']='给你一片天:BAAALAAFFAIIBAAAAA==.',['绝版']='绝版娘们:BAAALAAECggICAAAAA==.',['绯红']='绯红若梦:BAAALAAECggIDQAAAA==.',['维迪']='维迪卡尔之盾:BAAALAAECggICAAAAA==.',['绵绵']='绵绵酥:BAAALAAECgcIBwAAAA==.',['绽放']='绽放吧杠上花:BAAALAAFFAIIAgAAAA==.',['绿皮']='绿皮:BAAALAAECgYICAAAAA==.',['羅澜']='羅澜雲天:BAAALAAFFAIIAgAAAA==.',['羯猪']='羯猪:BAAALAADCgMIAwAAAA==.',['翻滚']='翻滚吧蛋炒饭:BAAALAAFFAEIAQAAAA==.',['翻转']='翻转再来壹發:BAAALAAECgMIAwAAAA==.',['老年']='老年神龙大侠:BAAALAAFFAIIBAAAAA==.',['耳朵']='耳朵不能摸:BAAALAAECgUIBQAAAA==.',['耶米']='耶米夜影:BAAALAAECgYICAAAAA==.耶米莫格莱尼:BAABLAAECn8XAAIIAAgIwQzmTABfAQAIAAgIwQzmTABfAQAAAA==.',['联盟']='联盟公主:BAAALAAECgUIBQAAAA==.联盟国王:BAAALAAFFAIIAgAAAA==.',['聪明']='聪明的笨蛋:BAABLAAFFH8IAAIOAAIIdyCXJwC6AAAOAAIIdyCXJwC6AAAAAA==.',['肆壹']='肆壹:BAAALAAECgIIAgAAAA==.',['背叛']='背叛天使:BAAALAADCggICAAAAA==.',['胖胖']='胖胖的德:BAAALAAECgMIAwAAAA==.',['胸口']='胸口有根毛:BAAALAAECgMIAwAAAA==.',['脑袋']='脑袋沙拉:BAABLAAECn8gAAIOAAYIxxUWWwBTAQAOAAYIxxUWWwBTAQAAAA==.脑袋球球:BAAALAAECgIIAgAAAA==.',['色韵']='色韵东方:BAAALAAECgIIAgAAAA==.',['艾丽']='艾丽希亚:BAAALAADCgIIAgAAAA==.',['艾欧']='艾欧罗斯:BAAALAAECgYIBgAAAA==.艾欧逻斯:BAABLAAFFH8FAAIBAAIILwtyVgBFAAABAAIILwtyVgBFAAAAAA==.',['芙拉']='芙拉什:BAAALAAECgMIAwAAAA==.',['花下']='花下杨柳:BAABLAAFFH8FAAIOAAQIxBiDNADjAAAOAAQIxBiDNADjAAAAAA==.',['花好']='花好月未圆:BAABLAAECn8bAAIfAAYIGhc9NQCiAQAfAAYIGhc9NQCiAQAAAA==.',['苏醒']='苏醒之风:BAABLAAFFH8jAAMJAAYIVxitFgCJAQAJAAYIVxitFgCJAQATAAIIlgwvVABoAAAAAA==.',['苦修']='苦修盾苦修盾:BAAALAAFFAIIAgAAAA==.',['范塔']='范塔斯笛:BAAALAAECgIIAgAAAA==.',['荧焰']='荧焰丶:BAAALAAECgYICwAAAA==.',['莫贺']='莫贺延碛:BAABLAAFFH8GAAIDAAIIawKEGgBJAAADAAIIawKEGgBJAAAAAA==.',['莱格']='莱格拉斯:BAAALAAECgYICQAAAA==.',['菇菇']='菇菇大喷菇:BAAALAAECgMIAwAAAA==.',['萌宝']='萌宝总动员:BAAALAAECgYIEAAAAA==.',['萝卜']='萝卜萝卜脆:BAAALAAECgYICgAAAA==.',['萨恩']='萨恩多暴风:BAAALAAFFAIIAgAAAA==.',['萨萨']='萨萨情人:BAABLAAFFH8HAAIIAAIIhBUceABKAAAIAAIIhBUceABKAAAAAA==.',['葡萄']='葡萄有多甜:BAABLAAFFH8IAAMFAAYIrg9+GQDgAAAFAAYIrg9+GQDgAAAGAAEI1w02KwBPAAAAAA==.',['蒹葭']='蒹葭:BAAALAAECgYIAgAAAA==.',['蓝色']='蓝色星尘:BAAALAAECggICAAAAA==.蓝色羽悠然:BAAALAADCgEIAQAAAA==.',['蔑视']='蔑视大自然:BAAALAAECgQIBAAAAA==.',['蕾米']='蕾米欧娜:BAAALAADCgYIBgAAAA==.',['蕾贝']='蕾贝卡钱伯斯:BAAALAAFFAIIBAAAAA==.',['蘇眉']='蘇眉:BAAALAADCgQIBAAAAA==.',['蛋蛋']='蛋蛋的优桑:BAACLAAFFH8KAAIfAAYIMgYICQD5AAAfAAYIMgYICQD5AAAsAAQKfxcAAh8ABwjZGYcjAAQCAB8ABwjZGYcjAAQCAAAA.',['蛮三']='蛮三刀:BAACLAAFFH8ZAAMZAAYIkxPDCQDJAAAIAAYI2xCmNABrAQAZAAII9R7DCQDJAAAsAAQKfyIAAxkACAgsHM4PAFsCABkACAhkG84PAFsCAAgAAgh/FXKtAIgAAAAA.',['融融']='融融:BAAALAAECgQIBAAAAA==.',['血色']='血色尘风:BAAALAAECgMIAwAAAA==.',['西域']='西域团团:BAABLAAFFH8GAAIHAAYInRiYOABgAQAHAAYInRiYOABgAQAAAA==.西域大侠:BAAALAADCgQIBAAAAA==.西域战神:BAAALAADCgYIBgAAAA==.西域暴风:BAAALAAECgUIBQAAAA==.西域水镜:BAAALAADCgQIBAAAAA==.西域的小号:BAAALAADCgYIBgAAAA==.西域虚空:BAAALAAECgUIBgAAAA==.',['西门']='西门岚:BAABLAAFFH8MAAIBAAIIfxVvUQBJAAABAAIIfxVvUQBJAAAAAA==.',['親親']='親親丶寶貝:BAAALAAFFAIIAgAAAA==.',['言不']='言不清:BAACLAAFFH8RAAIOAAUI/x/nHAB7AQAOAAUI/x/nHAB7AQAsAAQKfygABBoACAjZILwHAC4CAA4ACAh7HGMtALwCABoABwggIrwHAC4CACAABQj9DYNSAAoBAAAA.',['让开']='让开我来挡:BAAALAAECgYICgAAAA==.',['让我']='让我想想:BAACLAAFFH8sAAMWAAYIDhOJCgCwAQAWAAYIDhOJCgCwAQAhAAUIDA/rEAAMAQAsAAQKfyAAAyEACAjFFiwNAMIBACEACAjFFiwNAMIBABYABQjRG4ENAIgBAAEsAAUUCAhHAAUAXx8A.',['译心']='译心:BAAALAAFFAgIAQAAAA==.',['诗画']='诗画相逢:BAACLAAFFH8GAAIHAAIIpRbgZQCHAAAHAAIIpRbgZQCHAAAsAAQKfxUAAgcABwhBF1OWALoBAAcABwhBF1OWALoBAAAA.',['诗蕐']='诗蕐相逢:BAAALAAECgIIAgAAAA==.',['谜橙']='谜橙橙:BAAALAAFFAIIBAAAAA==.',['贼娃']='贼娃娃:BAAALAAECgYICwABLAAFFAYIIwAJAFcYAA==.',['赏金']='赏金狩猎者:BAAALAAFFAIIAgAAAA==.',['赛莉']='赛莉卡:BAAALAAECgYIBgAAAA==.',['赛里']='赛里昂:BAAALAAECgMIAwAAAA==.',['赤色']='赤色冲击:BAAALAAECgYIDgAAAA==.',['赫敏']='赫敏格兰杰:BAAALAAECgYIBgAAAA==.',['起个']='起个好名字:BAAALAAFFAIIBAAAAA==.',['跟着']='跟着你的背:BAAALAAFFAEIAQAAAA==.',['踏碎']='踏碎灬凌霄:BAAALAAFFAIIBAAAAA==.',['轩妃']='轩妃:BAABLAAFFH8HAAIcAAIILgb6EQAeAAAcAAIILgb6EQAeAAAAAA==.',['轩辕']='轩辕灬大藏:BAABLAAFFH8IAAIRAAIIFgrPGQAzAAARAAIIFgrPGQAzAAAAAA==.轩辕筱猎:BAABLAAFFH8MAAIHAAIINhQ5aQCFAAAHAAIINhQ5aQCFAAAAAA==.',['轻纱']='轻纱缦绯舞:BAAALAAECgYIBgAAAA==.',['辉飞']='辉飞湮灭:BAAALAAECgYIBgAAAA==.',['达纳']='达纳斯小贩:BAAALAAFFAIIAgABLAAFFAgIBAANAAAAAA==.达纳斯扛把子:BAABLAAFFH8LAAIOAAMIECTMNgDQAAAOAAMIECTMNgDQAAAAAA==.',['连续']='连续弥斯:BAAALAAFFAIIAgAAAA==.',['迪托']='迪托马斯:BAAALAAECgYIDQABLAAECgYIDwANAAAAAA==.',['迪波']='迪波威:BAAALAADCgYIBgAAAA==.',['迷失']='迷失囡囡:BAAALAADCgMIAwAAAA==.',['通行']='通行:BAAALAAECgQIBAAAAA==.',['通道']='通道:BAAALAAFFAIIAgAAAA==.',['通风']='通风:BAABLAAFFH8JAAIKAAUIoQ0cKQAoAQAKAAUIoQ0cKQAoAQAAAA==.',['酸辣']='酸辣土豆奈斯:BAAALAAECgMIAwAAAA==.',['醉生']='醉生梦死:BAAALAAECgQIBQAAAA==.',['采菊']='采菊东篱下:BAAALAAECgYIDAAAAA==.',['野德']='野德新知住:BAAALAAECgMIAwAAAA==.',['野蛮']='野蛮痞子:BAAALAAECgMIBAAAAA==.',['钟馗']='钟馗:BAAALAAECgYIBgAAAA==.',['闪开']='闪开我大蹦:BAAALAAFFAIIBAAAAA==.',['闪闪']='闪闪惹人哎:BAAALAAECgYIDwAAAA==.',['阳光']='阳光柠檬:BAAALAAECgMIAwAAAA==.',['阿勇']='阿勇叫我勇哥:BAAALAAECgYIBgAAAA==.',['阿布']='阿布罗笛:BAAALAAECgYIDwAAAA==.',['阿斯']='阿斯特蕾雅:BAAALAAECgYIBwAAAA==.',['阿波']='阿波胡萝卜:BAAALAAECgYIBgAAAA==.',['阿荣']='阿荣:BAAALAADCgYIBgAAAA==.',['阿莉']='阿莉希亚:BAAALAADCgEIAQABLAAECgEIAQANAAAAAA==.',['阿莲']='阿莲:BAAALAAECgQIBAAAAA==.',['阿薩']='阿薩絲:BAAALAAECgUIBQAAAA==.',['陆玥']='陆玥:BAAALAAFFAIIAgAAAA==.',['陽光']='陽光真強烈:BAAALAAECgMIBQAAAA==.',['随乄']='随乄缘:BAAALAADCgQIBAAAAA==.',['随便']='随便玩玩看:BAAALAADCgIIAgAAAA==.',['雨馨']='雨馨:BAAALAAFFAQIBAAAAA==.',['雪绒']='雪绒花:BAAALAAECgYICwAAAA==.',['雲和']='雲和山的彼端:BAACLAAFFH8bAAIOAAYIgxYxFwCaAQAOAAYIgxYxFwCaAQAsAAQKfyUAAg4ACAjgFBY8AKkBAA4ACAjgFBY8AKkBAAAA.',['雷影']='雷影:BAAALAADCggICAAAAA==.',['露露']='露露的女王:BAAALAAFFAIIAgAAAA==.',['霸者']='霸者的小黄花:BAAALAADCggICAAAAA==.霸者苍蝇宝宝:BAABLAAFFH8GAAIUAAUIDgKLLwCuAAAUAAUIDgKLLwCuAAAAAA==.',['青枫']='青枫:BAACLAAFFH8QAAIHAAMIZxioMADEAAAHAAMIZxioMADEAAAsAAQKfxQAAgcABgjMH/h1APEBAAcABgjMH/h1APEBAAAA.',['靓飘']='靓飘飘:BAAALAADCgYIEgAAAA==.',['非常']='非常无姜君:BAAALAAECgYIEgAAAA==.',['顷刻']='顷刻炼化:BAAALAAECgIIAgAAAA==.',['顺势']='顺势:BAABLAAFFH8NAAMRAAYIlBlDBADyAQARAAYIlBlDBADyAQAHAAIITRLFUgCUAAAAAA==.',['風中']='風中奇緣:BAAALAADCgQIBAAAAA==.',['风中']='风中一粒雪:BAAALAADCgcIBwAAAA==.',['风御']='风御凌:BAAALAAECggICAABLAAFFAgIBQAXAIQIAA==.',['风舞']='风舞红尘:BAABLAAFFH8GAAIhAAIIEwJsJQAlAAAhAAIIEwJsJQAlAAAAAA==.',['风铃']='风铃丶:BAAALAADCgIIAgAAAA==.',['飛虎']='飛虎:BAAALAAECgYIDAAAAA==.',['飞天']='飞天小狐狸:BAABLAAFFH8UAAIbAAII0xVbGgBjAAAbAAII0xVbGgBjAAABLAAFFAYIGwAIACcgAA==.',['飞翼']='飞翼之星:BAAALAAFFAIIAgAAAA==.',['飞花']='飞花轻似梦:BAAALAAECgEIAQAAAA==.',['饭梵']='饭梵:BAABLAAFFH8LAAIHAAYIohsOJQCgAQAHAAYIohsOJQCgAQAAAA==.',['香蕉']='香蕉大王:BAAALAAFFAIIBAAAAA==.',['馬卡']='馬卡洛夫:BAABLAAFFH8GAAIOAAIIJhZuPAChAAAOAAIIJhZuPAChAAAAAA==.',['马保']='马保国:BAAALAADCgcIBwAAAA==.',['魅兰']='魅兰:BAAALAAECggIEgAAAA==.',['魅娴']='魅娴:BAAALAAECgYIDwAAAA==.',['魅焱']='魅焱:BAAALAAECgQIBAAAAA==.',['魅芸']='魅芸:BAAALAAECgUIBQAAAA==.',['鳯煌']='鳯煌:BAAALAAECgYIBgAAAA==.',['鸭梨']='鸭梨吗斯:BAACLAAFFH8gAAMaAAYIABM3BwBXAQAaAAYIABM3BwBXAQAgAAYI6ALAFwAXAQAsAAQKfy4ABCAACAg9EuQSANABACAACAg9EuQSANABABoACAiMF8QQAKMBAA4AAwjXCgO2AJMAAAEsAAUUCAhHAAUAXx8A.',['麦亚']='麦亚糖:BAAALAAECgYIBgAAAA==.',['麦天']='麦天使:BAAALAAECgUIBQAAAA==.',['黄金']='黄金神斗士:BAAALAAECgYIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end