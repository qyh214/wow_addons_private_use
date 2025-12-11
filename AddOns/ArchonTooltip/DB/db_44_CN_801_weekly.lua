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
 local lookup = {'Paladin-Retribution','DemonHunter-Havoc','Mage-Frost','DemonHunter-Vengeance','Paladin-Holy','Evoker-Augmentation','Evoker-Preservation','Druid-Restoration','Hunter-BeastMastery','Warlock-Destruction','Priest-Discipline','Priest-Holy','Warrior-Protection','Warrior-Fury','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Hunter-Marksmanship','Monk-Mistweaver','Druid-Guardian','DeathKnight-Frost','Warrior-Arms','Paladin-Protection','Warlock-Demonology','Priest-Shadow','Evoker-Devastation','Mage-Arcane','Unknown-Unknown',}; local provider = {region='CN',realm='艾苏恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Angelkiss:BAABLAAFFH8GAAIBAAII3g6CVQCNAAABAAII3g6CVQCNAAAAAA==.',Ay='Ayuml:BAAALAAECgYICwAAAA==.',Br='Bronya:BAAALAAFFAMIBAAAAA==.',Cl='Clinch:BAAALAAFFAIIBAAAAA==.',Co='Condiment:BAAALAAFFAIIBAAAAA==.',Dr='Dribbler:BAAALAAECgYIEAAAAA==.',Ee='Eendlness:BAAALAAFFAIIBAABLAAFFAYIEgACAPYdAA==.',Ho='Holy:BAAALAAECggICgAAAA==.',Ic='Icecruise:BAABLAAFFH8SAAICAAYI9h3NHQCMAQACAAYI9h3NHQCMAQAAAA==.',Ko='Koler:BAABLAAFFH8LAAIDAAIIYRI2EwCHAAADAAIIYRI2EwCHAAAAAA==.',Le='Lezard:BAECLAAFFH8TAAICAAYIrSB9BQBFAgACAAYIrSB9BQBFAgAsAAQKfxsAAwIACAhtIZQbAPcCAAIACAjCIJQbAPcCAAQABghaIRMTAD4CAAEsAAUUBwgmAAUASCUA.',Ma='Magicmoon:BAAALAAECgYIBgAAAA==.Magicshadow:BAAALAAECgIIAwAAAA==.',Mi='Mikeos:BAAALAAECgMIAwAAAA==.Minsco:BAAALAAECgYICQAAAA==.',My='Mysher:BAAALAADCgYICAAAAA==.',Na='Nanako:BAABLAAFFH8GAAMGAAQIjyWYBgBKAQAGAAMIECWYBgBKAQAHAAEIYwCvIgAdAAAAAA==.Nathan:BAAALAAECgcIEQAAAA==.Naughtyboy:BAAALAAECgEIAgAAAA==.',Pl='Playerotesic:BAAALAAFFAIIAgAAAA==.',Qw='Qwqa:BAAALAAECggICgAAAA==.',Re='Rechun:BAAALAAECgEIAQAAAA==.Retriever:BAAALAAECgIIAgAAAA==.',Sa='Sana:BAAALAAECgEIAQAAAA==.Sapphiron:BAAALAADCgEIAQAAAA==.',To='Topreally:BAAALAAECgYIBgAAAA==.',Vi='Vincentia:BAABLAAFFH8QAAIFAAgIJR+1AQDeAgAFAAgIJR+1AQDeAgAAAA==.',Wi='Windcaster:BAAALAAECgUIBQAAAA==.',['一叶']='一叶障目:BAABLAAFFH8GAAIIAAIIFx34HQCqAAAIAAIIFx34HQCqAAAAAA==.',['一期']='一期一会:BAABLAAFFH8RAAIJAAUI5B7YPgBKAQAJAAUI5B7YPgBKAQABLAAFFAYIEgACAPYdAA==.',['一条']='一条咸鱼王:BAAALAAECgcICgAAAA==.',['一炮']='一炮丶:BAAALAAECgYIBgAAAA==.',['七叶']='七叶壹枝花:BAAALAAECggICAABLAAFFAQIBgAKAJgKAA==.',['七彩']='七彩云:BAAALAAECgYIDwAAAA==.七彩斩:BAAALAAECgYIDAAAAA==.七彩雨:BAABLAAECn8oAAMLAAYIoB2tCgABAgALAAYIoB2tCgABAgAMAAIIAQRRZAA2AAAAAA==.七彩雪:BAAALAADCgIIAgAAAA==.七彩魔:BAAALAAECgYICQAAAA==.',['上下']='上下相易:BAABLAAFFH8HAAMFAAMIPhh2FgCqAAAFAAIIuCJ2FgCqAAABAAIISwMhgAAuAAAAAA==.',['专猎']='专猎死人头:BAAALAAECgYICwAAAA==.',['东风']='东风破:BAAALAAECgQIBAAAAA==.',['两颗']='两颗小虎牙:BAAALAADCgUIBQAAAA==.两颗爆牙:BAAALAADCgYIBgAAAA==.',['丨旋']='丨旋灬木:BAAALAAECgYIEgAAAA==.',['丨漩']='丨漩灬木:BAABLAAECn8VAAICAAYIuCJWHAD9AQACAAYIuCJWHAD9AQAAAA==.',['丨璇']='丨璇灬木:BAAALAAECgYICwAAAA==.',['丶五']='丶五木唯:BAABLAAFFH8LAAIHAAYImB7QBgALAgAHAAYImB7QBgALAgAAAA==.',['丶四']='丶四木唯:BAAALAAFFAQIBAAAAA==.',['主宰']='主宰丶尤涅若:BAAALAAECgYICwAAAA==.',['九莲']='九莲宝灯:BAAALAADCggIEgAAAA==.',['云汐']='云汐:BAAALAAECgcIBwAAAA==.',['五帝']='五帝棋士:BAAALAAECgYIBgAAAA==.',['五杀']='五杀:BAAALAAFFAIIAgAAAA==.',['亚麻']='亚麻得欧巴:BAAALAAECgYIDAAAAA==.',['今宵']='今宵有美酒:BAACLAAFFH8iAAMNAAgIXRo1BQD9AQANAAgItRg1BQD9AQAOAAIIeyM9QABdAAAsAAQKfyUAAw4ABgiSJfsoAJoCAA4ABgiSJfsoAJoCAA0AAwiECe9GAGYAAAAA.',['伊俐']='伊俐丹丶怒风:BAAALAAECgYIBgAAAA==.',['伊利']='伊利心照汗青:BAACLAAFFH8WAAICAAYIrBkXBwAsAgACAAYIrBkXBwAsAgAsAAQKfxYAAgIABghBFZWaAJUBAAIABghBFZWaAJUBAAEsAAUUCAgiAA0AXRoA.',['休利']='休利耶尔:BAAALAAFFAIIBAAAAA==.',['似狐']='似狐似猫:BAACLAAFFH8GAAMPAAIIfAdpbgBMAAAPAAIIfAdpbgBMAAAQAAEIOACpQQAUAAAsAAQKfxgAAg8ABwjCD/SmADEBAA8ABwjCD/SmADEBAAAA.',['你抱']='你抱孩子先走:BAAALAAECgYIBgAAAA==.',['做人']='做人要有狼性:BAAALAAECgIIAgAAAA==.',['傻蔓']='傻蔓:BAAALAAECgcIBwAAAA==.',['元素']='元素兔:BAAALAADCgYIBgAAAA==.',['光明']='光明使者:BAAALAADCgEIAQAAAA==.',['兔兔']='兔兔吃萝卜:BAAALAAECgYIBgAAAA==.',['六道']='六道:BAAALAAECgIIAgAAAA==.',['其實']='其實我是戰士:BAAALAAECgYICAAAAA==.',['冀翼']='冀翼圣哲:BAAALAAECgYIBwAAAA==.冀翼圣灵:BAAALAAECgMIAwAAAA==.冀翼无畏:BAAALAAECgYIBgAAAA==.冀翼盖世:BAAALAAECgUIBQAAAA==.',['冰开']='冰开水:BAABLAAFFH8UAAIOAAYImwy2IgBXAQAOAAYImwy2IgBXAQAAAA==.',['冰血']='冰血暴:BAAALAAECgYIDgAAAA==.',['凉开']='凉开水:BAABLAAFFH8sAAIRAAYISB0mCwCuAQARAAYISB0mCwCuAQAAAA==.',['凌乱']='凌乱的小钢炮:BAABLAAFFH8LAAIJAAUIKhhXRAA4AQAJAAUIKhhXRAA4AQAAAA==.凌乱的小黄瓜:BAABLAAFFH8fAAIOAAYI2x5SEwC/AQAOAAYI2x5SEwC/AQAAAA==.凌乱的胡萝卜:BAABLAAFFH8LAAIIAAMI6RjPJwDZAAAIAAMI6RjPJwDZAAAAAA==.',['凛岚']='凛岚:BAAALAADCgYIBgAAAA==.',['凝訷']='凝訷:BAAALAAECgYIBgAAAA==.',['剑随']='剑随心:BAAALAAECgYIBgAAAA==.',['加布']='加布兽:BAABLAAFFH8MAAIBAAYI+RwyDwDLAQABAAYI+RwyDwDLAQAAAA==.',['加鲁']='加鲁鲁兽:BAABLAAFFH8GAAIBAAYIox7pDwDGAQABAAYIox7pDwDGAQAAAA==.',['十方']='十方暗杀:BAAALAAECgYIDAAAAA==.',['千裏']='千裏煙:BAABLAAFFH8HAAIMAAYI0Bz0EgDCAQAMAAYI0Bz0EgDCAQAAAA==.',['华尔']='华尔兹:BAAALAAECggICAAAAA==.',['华熊']='华熊猫:BAABLAAFFH8JAAMJAAYI7RU2OQBbAQAJAAYIZRI2OQBbAQASAAMIDA/SFgC0AAAAAA==.',['卡娃']='卡娃思思:BAAALAAECgYIDAAAAA==.',['卡娜']='卡娜娃丝:BAAALAAECgIIAgAAAA==.',['卡普']='卡普拉:BAAALAAECgYIEAAAAA==.',['古二']='古二丹:BAAALAAECgEIAQAAAA==.',['古斯']='古斯塔夫:BAAALAADCgcIBwAAAA==.',['可丨']='可丨楽:BAAALAAFFAIIBAAAAA==.',['吃兔']='吃兔兔的蘿蔔:BAAALAAECgYIDAAAAA==.',['吃猫']='吃猫的小老鼠:BAAALAAECgYIBgAAAA==.',['吉安']='吉安那丶救赎:BAAALAAECgYIBgAAAA==.',['名茗']='名茗溟:BAAALAADCgMIAQAAAA==.',['吴作']='吴作佩:BAAALAAECggIEAAAAA==.',['吴同']='吴同学:BAAALAAECgYIBgAAAA==.',['命中']='命中带杀气:BAABLAAFFH8GAAIOAAYIVQTyNgCXAAAOAAYIVQTyNgCXAAAAAA==.',['咕迩']='咕迩丹:BAAALAAECgYICgAAAA==.',['咖啡']='咖啡潴:BAAALAAECgYIBwAAAA==.',['咪了']='咪了个喵的:BAAALAADCggICAAAAA==.',['哈色']='哈色:BAAALAAECggIBwAAAA==.',['唐古']='唐古拉波斯乐:BAAALAAECggIEQAAAA==.',['噗啊']='噗啊噗噗:BAAALAAFFAIIBAAAAA==.',['四川']='四川张学友:BAAALAAECgQIBAAAAA==.',['图拉']='图拉扬:BAAALAAFFAIIAgAAAA==.',['圣之']='圣之星:BAAALAAECgYICAAAAA==.',['圣枪']='圣枪小修女:BAAALAAFFAIIAgAAAA==.',['圣诞']='圣诞节的白雪:BAAALAAECgQIBAAAAA==.',['塞帕']='塞帕斯:BAAALAAECgYIDQAAAA==.',['复仇']='复仇的魔女:BAABLAAFFH8UAAICAAYIfgdJLAA1AQACAAYIfgdJLAA1AQAAAA==.',['夏夜']='夏夜微凉:BAAALAAECgYIBgAAAA==.',['夏寒']='夏寒冬烈:BAAALAAECgQIBQAAAA==.',['外星']='外星鹿腿:BAAALAADCgQIBAAAAA==.',['夜夜']='夜夜笙歌:BAAALAAECgYIEQAAAA==.',['大叔']='大叔大度:BAAALAAECgYIDwAAAA==.',['大天']='大天狼星:BAAALAAECgcIDgAAAA==.',['大萝']='大萝卜:BAAALAAECgQIBAAAAA==.',['大跳']='大跳闪到腰:BAAALAAFFAIIAgAAAA==.',['大雷']='大雷子:BAAALAAECgYIDQAAAA==.',['大鼻']='大鼻噶:BAAALAAECgcICAAAAA==.',['天启']='天启之光:BAAALAAFFAEIAQAAAA==.',['天天']='天天吃撑等死:BAAALAAECgMIAwAAAA==.',['天涯']='天涯冷血剑:BAAALAAECgYICwAAAA==.',['天谴']='天谴之光:BAAALAAECgEIAQAAAA==.',['奥塞']='奥塞里斯:BAAALAADCgIIAgAAAA==.',['奥斯']='奥斯丁丶圣光:BAAALAAECgYIEAAAAA==.',['奥菲']='奥菲利亚:BAAALAAECgMIAwAAAA==.',['奶油']='奶油芝士:BAAALAAECgYIBgAAAA==.',['好哥']='好哥哥:BAAALAAFFAEIAQAAAA==.',['寂静']='寂静之歌:BAABLAAECn8UAAIIAAYIQBYHLQB9AQAIAAYIQBYHLQB9AQAAAA==.',['寒山']='寒山:BAAALAAECgYICgAAAA==.',['寶寶']='寶寶熊亭亭:BAABLAAFFH8GAAITAAIIfAMsGgBLAAATAAIIfAMsGgBLAAAAAA==.',['小豆']='小豆豆的痘:BAABLAAFFH8IAAIMAAYIKh7lEgDCAQAMAAYIKh7lEgDCAQAAAA==.',['小雪']='小雪猪:BAABLAAFFH8HAAIIAAUI8gpaIwABAQAIAAUI8gpaIwABAQAAAA==.',['尘埃']='尘埃丶:BAABLAAFFH8HAAIOAAMIWwqJPgBrAAAOAAMIWwqJPgBrAAAAAA==.',['尼克']='尼克拉斯:BAAALAAECgUIBgAAAA==.',['峰丿']='峰丿:BAAALAAECgYIEAAAAA==.',['巴啦']='巴啦啦老魔仙:BAABLAAFFH8GAAIPAAYIAgB1egAEAAAPAAYIAgB1egAEAAAAAA==.',['帕拉']='帕拉汀:BAAALAADCgYICAAAAA==.',['席尔']='席尔瓦娜斯:BAACLAAFFH8OAAIJAAIIaR6DSgCaAAAJAAIIaR6DSgCaAAAsAAQKfxwAAgkABggCIghxAPoBAAkABggCIghxAPoBAAAA.',['席拉']='席拉奈:BAAALAAECgYIBgAAAA==.',['年卡']='年卡要到期了:BAAALAAECgYIDgAAAA==.',['幻忧']='幻忧尘:BAAALAAECgQIBAAAAA==.',['幽兰']='幽兰黛尔:BAAALAADCgUIBwAAAA==.',['幽涯']='幽涯岚:BAAALAAECgYIBgAAAA==.',['幽魂']='幽魂之殇:BAAALAAECgYIEwAAAA==.',['影法']='影法丶凯瑟琳:BAAALAAECgYIBgAAAA==.',['德露']='德露西:BAAALAAECgYIBgAAAA==.',['心碎']='心碎无言:BAACLAAFFH8QAAIOAAMIxhYNNwCWAAAOAAMIxhYNNwCWAAAsAAQKfx8AAg4ACAj3G3ETAEgCAA4ACAj3G3ETAEgCAAAA.',['忆霜']='忆霜:BAABLAAECn8hAAMIAAgI6x5sCAC/AgAIAAgI6x5sCAC/AgARAAEIWg4qZAAsAAAAAA==.',['快乐']='快乐长生:BAAALAAECgYIBgAAAA==.',['悠悠']='悠悠花武:BAACLAAFFH8PAAIOAAMIuhKQOACQAAAOAAMIuhKQOACQAAAsAAQKfxUAAw4ABggvIBMnAMUBAA4ABggvIBMnAMUBAA0ABggbBZBxAMMAAAAA.',['懒得']='懒得起床:BAAALAADCggICAAAAA==.',['懵逼']='懵逼且伤脑:BAAALAAFFAQIBAAAAA==.懵逼又伤脑:BAABLAAFFH8GAAIQAAYIhQP5KwDcAAAQAAYIhQP5KwDcAAAAAA==.',['我是']='我是壹个龙人:BAAALAADCgQIBAAAAA==.我是奶茶:BAACLAAFFH8IAAIIAAIIcB34MQCiAAAIAAIIcB34MQCiAAAsAAQKfyoABBEACAgEFtwgAGcBABEABgg8GNwgAGcBAAgACAgrEG9rAFMBABQACAgDDqIPAD0BAAAA.',['我真']='我真好看:BAAALAAECgEIAQAAAA==.',['我还']='我还是个妹子:BAABLAAFFH8GAAIVAAYIBx5eKACUAQAVAAYIBx5eKACUAQAAAA==.',['所有']='所有人脱离:BAAALAADCgYIBgAAAA==.',['打丶']='打丶那個法師:BAAALAAECgIIAgAAAA==.',['打那']='打那个幻神:BAAALAAFFAIIAgAAAA==.',['扭丷']='扭丷扭丷:BAAALAAFFAIIAgAAAA==.',['拉德']='拉德茨:BAAALAAECgEIAQAAAA==.',['拿莫']='拿莫稳:BAACLAAFFH8PAAIPAAQIvAxDKwCtAAAPAAQIvAxDKwCtAAAsAAQKfzAAAg8ACAiyF9JNAPgBAA8ACAiyF9JNAPgBAAAA.',['提拉']='提拉娅:BAAALAAECgYIBgAAAA==.',['搁浅']='搁浅的云丶:BAAALAADCgIIAgAAAA==.',['旋轉']='旋轉的優雅:BAAALAADCgIIAgAAAA==.',['无尽']='无尽凋零:BAAALAAECgEIAQAAAA==.',['早晚']='早晚都是我的:BAAALAAECggICAAAAA==.',['星之']='星之鹰:BAAALAAECgEIAQAAAA==.',['星巴']='星巴克天森:BAAALAAECgYICAAAAA==.',['星期']='星期九:BAAALAAECgYIBgAAAA==.',['星河']='星河旧梦:BAAALAAFFAIIAwAAAA==.星河浩瀚:BAAALAAECgMIAwAAAA==.',['春丨']='春丨麗:BAAALAAFFAIIBAAAAA==.',['春华']='春华秋月:BAAALAAECgYIBgAAAA==.',['春天']='春天的回忆:BAAALAADCggIDAAAAA==.',['普朗']='普朗克丶诺娃:BAAALAAECgYIBgAAAA==.',['晴霜']='晴霜:BAAALAAECgEIAQAAAA==.',['暖暖']='暖暖布丁:BAACLAAFFH8FAAIIAAMInhLwJgCNAAAIAAMInhLwJgCNAAAsAAQKfxYAAggABghUGa5RAKEBAAgABghUGa5RAKEBAAAA.',['最后']='最后的祈祷:BAAALAAFFAIIAgAAAA==.',['月之']='月之祭司:BAAALAADCgYICwAAAA==.',['木木']='木木灵儿:BAACLAAFFH8GAAMPAAII+wKWdQBBAAAPAAII+wKWdQBBAAAQAAEIpwHDQAA0AAAsAAQKfzAAAw8ACAjtFyxEABICAA8ACAjtFyxEABICABAABQgpCSVWALkAAAAA.',['本丶']='本丶尼迪塔斯:BAAALAAECgYIDAAAAA==.',['机械']='机械暴龙兽:BAAALAAFFAIIAgAAAA==.',['朽霜']='朽霜:BAAALAAECgIIAgAAAA==.',['来者']='来者不拒:BAABLAAECn8ZAAMOAAYIVhW2gACFAQAOAAYIVhW2gACFAQAWAAEICAPEGAATAAAAAA==.',['柔波']='柔波特:BAAALAAFFAIIBAAAAA==.',['柳飞']='柳飞扬:BAABLAAECn8vAAQXAAgICg4cFwBdAQAXAAgIcA0cFwBdAQAFAAYIrA1xJAAeAQABAAUIJQbXWQF+AAAAAA==.',['栋哥']='栋哥不是东哥:BAAALAAFFAIIAgAAAA==.',['格子']='格子里的夜寒:BAAALAAECgYIDQAAAA==.',['桥木']='桥木猎:BAAALAAFFAIIAgAAAA==.',['梅子']='梅子黄时雨:BAAALAAECgQIBAAAAA==.',['梦淑']='梦淑颖:BAAALAAECgIIAgAAAA==.',['榕城']='榕城大虾:BAABLAAFFH8GAAMKAAMIfhKTSwCLAAAKAAMIfhKTSwCLAAAYAAEINw/rKQBOAAAAAA==.榕城跳跳鱼:BAAALAAFFAYIAgAAAA==.',['欧洲']='欧洲之巅:BAAALAAECgQIBAAAAA==.',['死与']='死与新生:BAAALAADCggICAAAAA==.',['毕宿']='毕宿:BAAALAAECgYIBgAAAA==.',['水贼']='水贼:BAAALAAECgQIBAAAAA==.',['永恒']='永恒信仰:BAAALAAECggICgAAAA==.',['沉默']='沉默星瞳:BAAALAAECggIBwAAAA==.',['法玛']='法玛里澳:BAAALAAFFAIIAwAAAA==.',['泡菜']='泡菜烤肉:BAAALAAFFAIIAgAAAA==.',['泰瑞']='泰瑞达:BAAALAADCgYIBgAAAA==.',['洁白']='洁白的救赎:BAABLAAFFH8OAAIPAAIIaxezPACHAAAPAAIIaxezPACHAAAAAA==.',['流光']='流光电:BAABLAAFFH8HAAIPAAMImRLBQgCdAAAPAAMImRLBQgCdAAAAAA==.',['流鼻']='流鼻涕:BAAALAAECggIBgAAAA==.',['温开']='温开水:BAABLAAFFH8NAAMKAAYIgA3dNQA5AQAKAAYIZwzdNQA5AQAYAAII3hgSHACHAAABLAAFFAgIIgAKAH0lAA==.',['游街']='游街的疯子:BAAALAAECggIEAAAAA==.',['漆黑']='漆黑的审判:BAABLAAFFH8GAAIMAAIItBXPKQCXAAAMAAIItBXPKQCXAAAAAA==.',['漠雪']='漠雪之你妹:BAAALAAECgYIBgAAAA==.',['潘达']='潘达敦:BAAALAAECgUIBQAAAA==.',['灬紫']='灬紫默灬:BAAALAAECgQIBAAAAA==.',['灬蓝']='灬蓝若茗灬:BAAALAAECgIIAgAAAA==.',['灵感']='灵感大王:BAAALAAECggIDwAAAA==.',['灵柩']='灵柩骑士:BAAALAAECgQIBAAAAA==.',['炽天']='炽天使洛洛:BAAALAADCgUIBQAAAA==.',['热开']='热开水:BAABLAAFFH8FAAIZAAUI1QQIGwDKAAAZAAUI1QQIGwDKAAABLAAFFAgIJAAaAAYcAA==.',['煤开']='煤开水:BAABLAAFFH8GAAMPAAYISA8bMQDoAAAPAAUIjwobMQDoAAAQAAEI/gN5UAAzAAAAAA==.',['熊八']='熊八:BAAALAADCgYIBgAAAA==.',['熊猫']='熊猫不是能猫:BAAALAAECgYIBgAAAA==.熊猫甜甜:BAAALAADCgYIBgAAAA==.',['熊飞']='熊飞豹舞:BAAALAAECgQIBAAAAA==.',['熙沄']='熙沄:BAAALAAECgQIBQAAAA==.',['燕十']='燕十三:BAABLAAFFH8GAAIJAAII2wYCrgA4AAAJAAII2wYCrgA4AAAAAA==.',['爱神']='爱神丶丘比特:BAAALAAECgEIAQAAAA==.',['牛了']='牛了个头:BAAALAADCgYIBgAAAA==.',['牛板']='牛板筋:BAAALAAECgQIBAAAAA==.',['牛逼']='牛逼克拉斯:BAABLAAECn8ZAAIPAAgIJA5TQwBNAQAPAAgIJA5TQwBNAQAAAA==.',['狂暴']='狂暴虚空:BAAALAAECgQIBAAAAA==.',['狐妖']='狐妖雅雅:BAAALAADCgcICQAAAA==.',['独丶']='独丶角兽:BAAALAAECgEIAQAAAA==.',['狼人']='狼人加鲁鲁兽:BAABLAAFFH8IAAIBAAYI6xv1EwCrAQABAAYI6xv1EwCrAQAAAA==.',['猎丶']='猎丶爹:BAAALAAECggIEgAAAA==.',['猎艳']='猎艳红尘:BAAALAADCgIIAgAAAA==.',['猪猪']='猪猪要水水:BAAALAADCgcIBwAAAA==.',['玛丽']='玛丽奥特曼:BAABLAAFFH8MAAMEAAYI+Qn3CADMAAAEAAUIUQv3CADMAAACAAEIQAPsbAAtAAABLAAFFAcIKwAbAEwXAA==.',['玩摇']='玩摇滚的浣熊:BAAALAADCgYIBgAAAA==.',['玲珑']='玲珑圣光:BAAALAAFFAYIAgAAAA==.',['琳哒']='琳哒的小熊:BAAALAAECgYICAAAAA==.琳哒的小跟班:BAAALAAECgEIAgAAAA==.',['瓦博']='瓦博:BAABLAAFFH8GAAIMAAIIOwmrOACDAAAMAAIIOwmrOACDAAAAAA==.',['生吞']='生吞葫芦娃:BAAALAAFFAIIAgAAAA==.',['畾畾']='畾畾:BAABLAAECn8WAAIJAAgIlx43XgAgAgAJAAgIlx43XgAgAgAAAA==.',['疯狂']='疯狂毒龙钻:BAAALAADCgYIBgAAAA==.',['白玫']='白玫瑰:BAAALAADCgYIBgAAAA==.',['白衣']='白衣丶:BAAALAAFFAIIAgAAAA==.',['看什']='看什么看:BAAALAAFFAgIAgAAAA==.',['硬界']='硬界毕业生:BAAALAAECgYIBgAAAA==.',['神馬']='神馬都是浮云:BAAALAAECgYIEAAAAA==.',['祭墨']='祭墨墨:BAAALAAECgcICgAAAA==.',['禁庭']='禁庭秋暮:BAAALAAECgYIBgAAAA==.',['简墨']='简墨:BAACLAAFFH8eAAMMAAgIvBbNCwANAgAMAAgIvBbNCwANAgAZAAMIdQ53HwCMAAAsAAQKfyUAAwwACAh7IB0UAMkCAAwACAh7IB0UAMkCABkAAwirDwt+AK8AAAAA.',['算你']='算你厉害:BAAALAAECgcIEwAAAA==.',['納尔']='納尔袔:BAAALAAECggICAAAAA==.',['納薾']='納薾克:BAAALAAECggICAAAAA==.',['素开']='素开水:BAABLAAFFH8TAAIBAAYIJBPeHAB5AQABAAYIJBPeHAB5AQAAAA==.',['繻靈']='繻靈:BAABLAAFFH8OAAIIAAQIeg9eJwDdAAAIAAQIeg9eJwDdAAAAAA==.',['红发']='红发沧桑叔叔:BAACLAAFFH8NAAMPAAQIfRKCOgC5AAAPAAMIChWCOgC5AAAQAAIIHgN0TQA4AAAsAAQKfxgAAw8ABwjfF0YsALQBAA8ABwjfF0YsALQBABAAAwhACV1jAIUAAAAA.',['红叶']='红叶丶:BAAALAAECgYIBgAAAA==.',['红透']='红透晚烟青:BAAALAAFFAIIAgAAAA==.',['给你']='给你出蛋刀:BAAALAAECgYIBgAAAA==.',['绯雪']='绯雪倾城狐:BAAALAAECgYIBgAAAA==.',['绿豆']='绿豆配芝麻:BAAALAAECgYIBgAAAA==.',['羽人']='羽人绯獍:BAAALAAECgYICgAAAA==.',['胖弟']='胖弟弟:BAABLAAFFH8GAAICAAIIaxphLgCtAAACAAIIaxphLgCtAAAAAA==.',['胖法']='胖法:BAAALAAFFAIIBAAAAA==.',['脱缰']='脱缰的野狗:BAAALAAFFAIIAgAAAA==.',['自然']='自然多水水:BAAALAADCggICAAAAA==.',['艾爾']='艾爾度因:BAAALAAECgUICAAAAA==.',['艾蔻']='艾蔻:BAAALAAECgYICwAAAA==.',['花玲']='花玲:BAAALAADCgIIAgAAAA==.',['若小']='若小西:BAAALAAFFAIIAgABLAAFFAgIBgAVAIwUAA==.',['若轻']='若轻云之蔽月:BAAALAAFFAIIBAAAAA==.',['茉莉']='茉莉的芬芳:BAAALAADCgIIAgAAAA==.',['荒猫']='荒猫:BAABLAAFFH8KAAIPAAIILhkATACEAAAPAAIILhkATACEAAAAAA==.',['萌萌']='萌萌哒路过丶:BAABLAAECn8aAAICAAYI6h+rJwC9AQACAAYI6h+rJwC9AQAAAA==.',['萌面']='萌面娇汗:BAAALAAECgMIBAAAAA==.',['落花']='落花轻似雪:BAAALAADCgEIAQAAAA==.',['葬送']='葬送的芙莉莲:BAABLAAFFH9EAAMKAAgI3iGdBgCVAgAKAAgI3iGdBgCVAgAYAAEIRRadJwBRAAAAAA==.',['血腥']='血腥瘟疫:BAAALAAECgYIBgAAAA==.',['西北']='西北小狼:BAAALAAECgcIBwAAAA==.',['西柚']='西柚:BAAALAAFFAIIAgAAAA==.',['西楼']='西楼哥哥:BAABLAAFFH8GAAIVAAYIDwJ2awBkAAAVAAYIDwJ2awBkAAABLAAFFAgIDAAFAKUUAA==.西楼老公:BAAALAAFFAQIAwAAAA==.',['西瓜']='西瓜土豆泥:BAAALAAFFAIIAgAAAA==.',['西虹']='西虹市猎魔人:BAABLAAFFH8LAAIBAAIIIyAlLgCuAAABAAIIIyAlLgCuAAAAAA==.',['见猎']='见猎心喜:BAAALAAFFAEIAQAAAA==.',['视力']='视力有点弱:BAAALAAECggICAAAAA==.',['讲秩']='讲秩序:BAAALAADCgYIBgAAAA==.',['讲道']='讲道德:BAAALAADCgYIBgAAAA==.',['貌似']='貌似姗姗:BAAALAADCgYICgAAAA==.',['贱贱']='贱贱的龙战:BAAALAADCgMIBAAAAA==.',['赏金']='赏金獵人:BAAALAADCgcIBwAAAA==.',['超级']='超级爱妞妞:BAAALAAECgYICgAAAA==.',['转角']='转角遇甜瓜:BAACLAAFFH8MAAIBAAIIxBerOwChAAABAAIIxBerOwChAAAsAAQKfzEAAgEACAg1ILwqAOgBAAEACAg1ILwqAOgBAAAA.',['近卫']='近卫军秒杀:BAAALAADCgEIAQAAAA==.',['那一']='那一眼而深陷:BAAALAAFFAIIBAAAAA==.',['那个']='那个萨满丶:BAABLAAFFH8SAAIFAAgI1CAqAQAFAwAFAAgI1CAqAQAFAwAAAA==.',['那我']='那我没办法:BAECLAAFFH8mAAMFAAcISCWTAAC2AgAFAAcISCWTAAC2AgABAAEIBgmTiQAAAAAsAAQKfx4ABAUACAg0I5kEABwDAAUACAg0I5kEABwDABcAAQgJJfk4AGcAAAEAAQhMHkvWAE8AAAAA.',['邱淑']='邱淑贞:BAAALAAFFAIIAgABLAAFFAgIAQAcAAAAAA==.',['酋长']='酋长加尔鲁什:BAAALAAECgYIDQAAAA==.',['酸萝']='酸萝卜别吃丶:BAAALAAECgEIAQAAAA==.',['鍅師']='鍅師:BAAALAAECggICAAAAA==.',['鑫森']='鑫森淼焱磊:BAAALAADCggIHQAAAA==.',['钢仁']='钢仁:BAAALAAECgIIAgAAAA==.',['钢铁']='钢铁加鲁鲁:BAABLAAFFH8UAAIBAAYI2h9RDQDZAQABAAYI2h9RDQDZAQAAAA==.',['银发']='银发大叔:BAAALAAECgYIDAAAAA==.',['银鱼']='银鱼儿:BAAALAADCggICAAAAA==.',['阁壁']='阁壁老王:BAABLAAFFH8JAAMCAAMICgavQwB6AAACAAMICgavQwB6AAAEAAIIQAHVGwATAAAAAA==.',['阿兰']='阿兰米娅:BAAALAAECggIBgAAAA==.',['阿真']='阿真:BAAALAAECgYIBgAAAA==.',['阿福']='阿福满足:BAACLAAFFH8GAAIPAAIIyxnQRgCRAAAPAAIIyxnQRgCRAAAsAAQKfyEAAg8ACAgPHTdHAAkCAA8ACAgPHTdHAAkCAAAA.',['陌生']='陌生:BAAALAAECgYICwAAAA==.',['降谷']='降谷灬零:BAAALAADCgYIBgABLAAECgYIBgAcAAAAAA==.',['隔墙']='隔墙囸仙人:BAAALAAECgIIAgAAAA==.',['隔壁']='隔壁王大爷:BAABLAAFFH8GAAIDAAIIawNqIQAhAAADAAIIawNqIQAhAAAAAA==.',['零度']='零度的亲吻:BAAALAAECgYICAAAAA==.',['雷刃']='雷刃:BAACLAAFFH8fAAMDAAUIgCPtAwCbAQADAAUIgCPtAwCbAQAbAAEIvxJHVQBGAAAsAAQKfxQAAwMABwjQHtY2AJsBAAMABwgEG9Y2AJsBABsABgivFl6FAIUBAAAA.',['霜岚']='霜岚:BAAALAADCgQIBAAAAA==.',['霜狼']='霜狼族丶萨迩:BAAALAAECgYIBgAAAA==.',['露露']='露露:BAABLAAFFH8JAAIJAAMIrRTzdAB1AAAJAAMIrRTzdAB1AAAAAA==.',['青鸢']='青鸢:BAAALAAECgUIBQAAAA==.',['靓闪']='靓闪闪:BAABLAAFFH8TAAIKAAYIqAtIMQBSAQAKAAYIqAtIMQBSAQAAAA==.',['靛开']='靛开水:BAABLAAFFH8LAAIDAAYIYg7TBgBAAQADAAYIYg7TBgBAAQAAAA==.',['面包']='面包的奶萨:BAABLAAFFH8QAAIPAAUIhAxZLwDzAAAPAAUIhAxZLwDzAAAAAA==.面包的奶酪:BAABLAAFFH8KAAMEAAYIaxIFBgAqAQAEAAYIihEFBgAqAQACAAIIEBw6SQCSAAAAAA==.',['風雲']='風雲出我輩:BAAALAAECgEIAQAAAA==.',['风骚']='风骚伯起棍:BAAALAAFFAIIAgAAAA==.',['飘飘']='飘飘小夫:BAAALAADCgcICQAAAA==.',['马儿']='马儿子:BAABLAAFFH8NAAMJAAMIMRlqaQCRAAAJAAMIMRlqaQCRAAASAAII1AV6GgA0AAAAAA==.',['马走']='马走日:BAABLAAFFH8LAAIPAAIIZhSoVQBwAAAPAAIIZhSoVQBwAAAAAA==.',['骑士']='骑士亡魂:BAAALAAFFAIIAgAAAA==.',['髒尐']='髒尐月:BAAALAAECgIIAgAAAA==.髒尐糖:BAAALAADCgQIBAAAAA==.',['魔牧']='魔牧妖妖:BAAALAADCgEIAQAAAA==.',['魔萨']='魔萨小妖妖:BAAALAAECgMIAwAAAA==.',['黎落']='黎落花飘:BAAALAAECgMIAwAAAA==.',['黑开']='黑开水:BAABLAAFFH8MAAIVAAYI2A90LwB9AQAVAAYI2A90LwB9AQAAAA==.',['黑毒']='黑毒奶:BAAALAAECgIIAgAAAA==.',['黛梵']='黛梵妲:BAAALAAECgcICgAAAA==.',['黯光']='黯光麻薯:BAAALAADCgIIAgAAAA==.',['黯淡']='黯淡的锋刃:BAABLAAFFH8OAAIVAAgI3RUtCQBnAgAVAAgI3RUtCQBnAgAAAA==.',['龅牙']='龅牙叔:BAAALAADCgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end