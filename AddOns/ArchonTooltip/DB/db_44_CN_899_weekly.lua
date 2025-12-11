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
 local lookup = {'DeathKnight-Frost','Warrior-Fury','DemonHunter-Vengeance','DemonHunter-Havoc','Paladin-Retribution','Hunter-BeastMastery','Warlock-Destruction','Warrior-Protection','Paladin-Holy','Unknown-Unknown','Druid-Restoration','Shaman-Restoration','Monk-Brewmaster','Druid-Balance','Shaman-Elemental','DeathKnight-Unholy','Evoker-Preservation','Priest-Holy','Rogue-Assassination','Paladin-Protection','Warlock-Demonology','Mage-Arcane','Priest-Shadow','Mage-Fire','Mage-Frost','Monk-Mistweaver','Monk-Windwalker','Hunter-Marksmanship','Evoker-Devastation','Evoker-Augmentation','Rogue-Subtlety','Hunter-Survival','Druid-Guardian',}; local provider = {region='CN',realm='黑石尖塔',name='CN',type='weekly',zone=44,date='2025-12-10',data={Al='Allelement:BAAALAAECggICAAAAA==.Allessence:BAAALAAECggICAAAAA==.Allshoot:BAAALAAECggICAAAAA==.',Ba='Badgley:BAAALAADCgIIAgAAAA==.',Br='Brightcat:BAACLAAFFH8IAAIBAAUIXx0CPgBKAQABAAUIXx0CPgBKAQAsAAQKfxsAAgEABgg7Hz90AA4CAAEABgg7Hz90AA4CAAAA.',Cr='Crazydese:BAABLAAFFH8IAAICAAUIuw5mIQBoAQACAAUIuw5mIQBoAQAAAA==.',Da='David:BAAALAAECggIEwAAAA==.',De='Deceiver:BAAALAADCgUIBQAAAA==.',Dh='Dh:BAABLAAECn8aAAMDAAcI6xW7EwAbAQAEAAcIdRG+lgCbAQADAAYIhhS7EwAbAQAAAA==.',Ds='Dskarthus:BAAALAAECgYIDAAAAA==.',Dt='Dtmiss:BAABLAAFFH8GAAIFAAIIQBsbYABHAAAFAAIIQBsbYABHAAAAAA==.',El='Elysium:BAABLAAFFH8GAAIGAAII1g2zqgA7AAAGAAII1g2zqgA7AAAAAA==.',Es='Essex:BAAALAAFFAIIAgAAAA==.',Fi='Finishi:BAAALAAECgEIAQAAAA==.',Jo='Jokerlin:BAAALAAECgEIAQAAAA==.',Kj='Kjolle:BAABLAAFFH8JAAIHAAgIQSSIAQD8AgAHAAgIQSSIAQD8AgAAAA==.',Ku='Kudaranai:BAAALAAECgYIDwAAAA==.',Le='Le:BAAALAAECgEIAQAAAA==.Leonsoso:BAAALAADCgYIBgAAAA==.',Li='Lifengzs:BAABLAAFFH8YAAIIAAYIiiHvAgAcAgAIAAYIiiHvAgAcAgAAAA==.',Lr='Lr:BAAALAADCgQIBAAAAA==.',Ly='Lyfly:BAAALAAECgIIAgAAAA==.',Ma='Magicelf:BAABLAAFFH8PAAIJAAUIsBQiEwBhAQAJAAUIsBQiEwBhAQAAAA==.',Me='Mending:BAAALAADCgEIAQAAAA==.',Op='Option:BAAALAAFFAYIBAAAAA==.',Pe='Pecan:BAAALAADCgYIBgAAAA==.',Re='Redrosid:BAAALAAFFAMIAwAAAA==.',Ro='Rosel:BAAALAAFFAIIAgABLAAFFAIIAgAKAAAAAA==.',Sa='Salvition:BAAALAAFFAMIAwAAAA==.',Si='Silents:BAAALAAECgYIBQAAAA==.Silenty:BAABLAAFFH8FAAIEAAMITRF/RAB/AAAEAAMITRF/RAB/AAAAAA==.',Sk='Skylove:BAAALAAECgUIBQAAAA==.',Su='Sukhavati:BAAALAAECgYIDAAAAA==.',Tu='Turain:BAAALAAFFAIIAgAAAA==.',Ve='Vespera:BAAALAADCgYIBgAAAA==.',Vi='Visteria:BAAALAAECgYIDgAAAA==.',Wh='Whosudaddy:BAAALAAECgYIBgAAAA==.',Wr='Wrath:BAAALAAFFAIIBAAAAA==.',Yi='Yiyiicee:BAAALAAFFAIIAwAAAA==.Yiyiicelr:BAAALAAECgQIBAAAAA==.Yiyiiceq:BAAALAAECgIIAgAAAA==.Yiyiicez:BAAALAAECgYIBwAAAA==.',Za='Zack:BAAALAAFFAIIBAAAAA==.',['一切']='一切为了联盟:BAAALAADCgYIBgAAAA==.',['一大']='一大新手:BAABLAAFFH8GAAILAAIIsA4LSgBeAAALAAIIsA4LSgBeAAAAAA==.',['一撮']='一撮毛:BAAALAAFFAIIAgAAAA==.',['一狐']='一狐平川:BAAALAAECgUIBQAAAA==.',['七步']='七步之外枪快:BAABLAAFFH8FAAIGAAMIvgqRewBrAAAGAAMIvgqRewBrAAAAAA==.',['上帝']='上帝的使女:BAABLAAFFH8FAAIGAAIIhAiddQB5AAAGAAIIhAiddQB5AAAAAA==.',['不会']='不会翻跟斗:BAABLAAFFH8MAAIGAAQI9A5BYwC7AAAGAAQI9A5BYwC7AAAAAA==.',['丛林']='丛林之狐:BAAALAADCgIIAgAAAA==.',['丨叶']='丨叶丨:BAABLAAFFH8bAAIMAAYIGxdhFgCzAQAMAAYIGxdhFgCzAQAAAA==.',['丨水']='丨水无月丨:BAAALAAECgMIAwAAAA==.',['丨温']='丨温润如雨丨:BAABLAAECn8aAAIFAAcIfCFAGwA7AgAFAAcIfCFAGwA7AgABLAAFFAgIOAANAO4kAA==.',['丶猎']='丶猎猎風中:BAAALAAECggICAAAAA==.',['丹尔']='丹尔古:BAAALAAECgYIDAAAAA==.',['为了']='为了荣誉:BAAALAAECgIIAgAAAA==.',['乌鲁']='乌鲁克:BAAALAAECgEIAQAAAA==.',['乐邦']='乐邦简史:BAAALAAECgYIBgAAAA==.',['乖丶']='乖丶趴趴熊:BAAALAAFFAIIAgAAAA==.',['乙德']='乙德唬人:BAAALAAFFAIIAgAAAA==.',['九太']='九太子玄灭:BAAALAAFFAIIAgAAAA==.',['九州']='九州风凌雪:BAAALAAECgIIAgAAAA==.',['九爷']='九爷:BAAALAADCgMIAwAAAA==.九爷的小德:BAABLAAECn8VAAMLAAYIDA99QgATAQALAAYIDA99QgATAQAOAAMI9AwNjwCJAAAAAA==.',['九爺']='九爺:BAAALAAECgUIBQAAAA==.',['九老']='九老爺:BAAALAADCgIIAwAAAA==.',['云天']='云天灬修:BAAALAAECgIIAgAAAA==.',['五花']='五花马:BAAALAAFFAIIAgAAAA==.',['五菱']='五菱宏光:BAAALAAECgIIAgAAAA==.',['亚森']='亚森罗萍:BAAALAAECgYIBgAAAA==.',['京东']='京东热炕头:BAAALAAECgMIAwAAAA==.',['人心']='人心薄凉丶伤:BAABLAAFFH8HAAILAAcIkxNuBwClAQALAAcIkxNuBwClAQAAAA==.',['人民']='人民志愿牛:BAAALAAECgEIAQAAAA==.',['仙儿']='仙儿:BAACLAAFFH8xAAIPAAYIsyLzCQDfAQAPAAYIsyLzCQDfAQAsAAQKfzwAAg8ACAi5JcACAHwDAA8ACAi5JcACAHwDAAAA.',['以父']='以父之名:BAAALAAECgYIBgAAAA==.',['伊格']='伊格诺斯:BAAALAADCgIIAgAAAA==.',['伊胜']='伊胜小雪:BAAALAAECgYIBgAAAA==.',['伍玖']='伍玖肆拾伍:BAAALAAECgEIAQAAAA==.',['传奇']='传奇拉面王:BAAALAAECgYIDwAAAA==.',['伦茵']='伦茵大仙:BAAALAAECgYIBgAAAA==.',['你有']='你有血光之灾:BAAALAADCgMIAwABLAADCgQIBAAKAAAAAA==.',['你老']='你老婆真好看:BAAALAADCgcIDQAAAA==.',['侠骨']='侠骨柔情:BAAALAAECgIIAgAAAA==.',['傻虎']='傻虎吹牛王:BAABLAAFFH8GAAIGAAIIihW4gwBUAAAGAAIIihW4gwBUAAAAAA==.',['兮儿']='兮儿瓦纳斯:BAAALAAECgEIAQAAAA==.',['兽性']='兽性死亡:BAAALAAECgEIAQAAAA==.',['兽血']='兽血:BAAALAAECgIIAgAAAA==.',['内侬']='内侬组特:BAAALAAECgYIBwAAAA==.',['冰可']='冰可乐要加冰:BAAALAAFFAIIAgAAAA==.',['冰摇']='冰摇绿茶:BAABLAAFFH8HAAMFAAIIIQVaXQCBAAAFAAIIIQVaXQCBAAAJAAIIjwRyJQB2AAAAAA==.',['冰龙']='冰龙之翼:BAAALAAECgMIBgAAAA==.',['冲锋']='冲锋减智商:BAAALAAECgYIBgAAAA==.',['凤雏']='凤雏丶:BAAALAADCgQIBAAAAA==.',['别叫']='别叫我猪头:BAABLAAFFH8KAAIQAAII/BA6FQBEAAAQAAII/BA6FQBEAAAAAA==.',['北冥']='北冥狂牛:BAAALAADCgEIAQAAAA==.',['南居']='南居扛把子:BAAALAADCgYICQAAAA==.',['南柯']='南柯丶一梦:BAAALAAECgYIBgAAAA==.',['卡奇']='卡奇诺软糖:BAAALAAECgQIBAAAAA==.',['卡米']='卡米娜:BAABLAAFFH8GAAIHAAII0APjVQBuAAAHAAII0APjVQBuAAAAAA==.',['卡齐']='卡齐诺果冻:BAAALAAECgIIAgAAAA==.',['双采']='双采增辉:BAACLAAFFH8ZAAIRAAYI4B/YBADEAQARAAYI4B/YBADEAQAsAAQKfzIAAhEACAjQIUsEAAUDABEACAjQIUsEAAUDAAAA.',['变的']='变的心烦:BAAALAADCgQIBAAAAA==.',['古二']='古二爷:BAABLAAECn8WAAIOAAYIoxQ1UAB1AQAOAAYIoxQ1UAB1AQAAAA==.',['可爱']='可爱的小涩郎:BAABLAAFFH8PAAISAAMIcgU6OACEAAASAAMIcgU6OACEAAAAAA==.可爱的水懒:BAABLAAFFH8SAAIGAAYI0BgLGQBBAQAGAAYI0BgLGQBBAQAAAA==.',['向异']='向异翅:BAAALAAECgcIEQAAAA==.',['吕嵩']='吕嵩:BAAALAAECgYIDAAAAA==.',['呆弟']='呆弟弟:BAACLAAFFH8dAAITAAUIJhWYDABLAQATAAUIJhWYDABLAQAsAAQKfx0AAhMACAg3HbQUAHUCABMACAg3HbQUAHUCAAAA.呆弟弟丨:BAAALAAFFAMIAwAAAA==.呆弟弟丶:BAABLAAFFH8FAAIEAAMIVwiHRQB3AAAEAAMIVwiHRQB3AAAAAA==.',['咔卜']='咔卜啰多姆:BAAALAADCgYIBgAAAA==.',['咖啡']='咖啡乌:BAAALAAECggIBQAAAA==.',['咩咩']='咩咩兔丶:BAAALAAECggICAAAAA==.',['哆咪']='哆咪:BAAALAAECgYICQAAAA==.',['哈丽']='哈丽波特:BAABLAAFFH8GAAIMAAII7Q5HSwBwAAAMAAII7Q5HSwBwAAAAAA==.',['哈欠']='哈欠灬:BAABLAAFFH8MAAIHAAUIOQd7QQDxAAAHAAUIOQd7QQDxAAAAAA==.',['哎哟']='哎哟吃不下了:BAABLAAFFH8SAAIQAAYI+BJ2AwCVAQAQAAYI+BJ2AwCVAQAAAA==.',['哦豁']='哦豁豁:BAAALAAECgYICAAAAA==.',['唢呐']='唢呐流氓:BAAALAAECgYIBgAAAA==.',['唯一']='唯一一线:BAAALAAECgYIBgAAAA==.',['啦啦']='啦啦肥不肥:BAAALAAFFAIIAgAAAA==.',['喵也']='喵也喵不准:BAABLAAFFH8KAAIGAAYIdQEkqQA8AAAGAAYIdQEkqQA8AAAAAA==.',['喵喵']='喵喵修:BAABLAAFFH8cAAIIAAgIJCGMAQCfAgAIAAgIJCGMAQCfAgAAAA==.',['喵見']='喵見团子:BAABLAAFFH8HAAMPAAUIpgxCKQABAQAPAAUIpgxCKQABAQAMAAIIZRVsPgCEAAAAAA==.',['嚒哈']='嚒哈:BAABLAAFFH8GAAIUAAIIkgajIQApAAAUAAIIkgajIQApAAAAAA==.',['四修']='四修小德:BAAALAADCgIIAgAAAA==.',['囝囡']='囝囡囡囝:BAAALAADCgYIBgAAAA==.',['圣光']='圣光大仙:BAAALAAECgYIBgAAAA==.',['圣雾']='圣雾大仙:BAAALAADCgMIAwAAAA==.',['地狱']='地狱鬼魅:BAAALAAECgQIBAAAAA==.',['坚持']='坚持养着:BAAALAADCgIIAgAAAA==.',['坠落']='坠落不停:BAABLAAFFH8GAAIGAAYI9gSiXwDPAAAGAAYI9gSiXwDPAAAAAA==.',['基情']='基情四射:BAAALAAECgcIBwAAAA==.',['堕落']='堕落之焮:BAABLAAFFH84AAMVAAYIEyRTBQDnAAAHAAYIzyNlEwD4AQAVAAMIyiVTBQDnAAAAAA==.堕落天使之翼:BAAALAADCgUICAAAAA==.',['夏花']='夏花灿烂:BAAALAAECgUIBQAAAA==.',['夜幕']='夜幕丶双魂:BAABLAAFFH8IAAIMAAYIvxIGHwBqAQAMAAYIvxIGHwBqAQAAAA==.夜幕丶神龙:BAABLAAFFH8GAAIIAAYIywntFQAQAQAIAAYIywntFQAQAQAAAA==.',['夜影']='夜影龙葵:BAAALAADCgQIBAAAAA==.',['夜牧']='夜牧:BAABLAAFFH8JAAISAAIIrRVAJQCjAAASAAIIrRVAJQCjAAAAAA==.',['夜风']='夜风澜落:BAABLAAFFH8FAAMMAAIIpAJgdwBBAAAMAAIIpAJgdwBBAAAPAAII7AEGVgAkAAAAAA==.',['大卫']='大卫不可以:BAAALAAFFAUIBAAAAA==.',['大猪']='大猪蹄子:BAAALAAECgYICQAAAA==.',['大瓦']='大瓦利:BAAALAAECgUIBQAAAA==.大瓦里:BAAALAAECgYICwAAAA==.',['大秘']='大秘一哥:BAAALAAFFAIIBAAAAA==.',['天使']='天使之尘:BAAALAAFFAIIBAAAAA==.',['天刹']='天刹孤星:BAAALAAECgYIBgAAAA==.',['天山']='天山美少女:BAABLAAFFH8GAAIJAAYIERk7DgCpAQAJAAYIERk7DgCpAQAAAA==.',['天赐']='天赐祝福:BAAALAAECgYICgAAAA==.',['夷有']='夷有个靓仔:BAAALAADCgQIBAAAAA==.',['奥古']='奥古斯塔丶:BAAALAAECggICAAAAA==.',['奥妮']='奥妮克希:BAAALAAECgMIAwAAAA==.',['奶人']='奶人不偿命:BAAALAAFFAIIAwAAAA==.',['奶油']='奶油烩饭粒:BAABLAAFFH8gAAICAAgIlyIuAgDkAgACAAgIlyIuAgDkAgAAAA==.',['妖妖']='妖妖玲:BAAALAAFFAIIAgAAAA==.',['妖怪']='妖怪:BAAALAAFFAIIAgAAAA==.',['妖狐']='妖狐:BAAALAAECgcIDwAAAA==.',['姜子']='姜子牙:BAAALAAECgQIBQAAAA==.',['娃哈']='娃哈哈矿泉水:BAAALAADCgEIAQAAAA==.',['娅蕾']='娅蕾珂:BAAALAAECggICAAAAA==.',['婺桐']='婺桐:BAAALAAECggICQAAAA==.',['婺空']='婺空:BAAALAAECgIIAgAAAA==.',['媚人']='媚人心魄:BAAALAAECgQIBgAAAA==.',['嫒之']='嫒之矢影歌:BAABLAAFFH8ZAAIGAAYIMx7IHADHAQAGAAYIMx7IHADHAQAAAA==.',['宇间']='宇间星痕:BAABLAAFFH8FAAIWAAMIpA0SLgDYAAAWAAMIpA0SLgDYAAAAAA==.',['宋帝']='宋帝:BAAALAADCgUIBQAAAA==.宋帝丶:BAACLAAFFH8GAAIFAAII0h2AVwBMAAAFAAII0h2AVwBMAAAsAAQKfxoAAgUABggzInFnABsCAAUABggzInFnABsCAAAA.',['宝哥']='宝哥哥:BAAALAAECgYICwAAAA==.',['宝宝']='宝宝要睡觉:BAAALAAECgUICQAAAA==.',['寶寶']='寶寶真乖:BAAALAAECgUIBQAAAA==.',['寻道']='寻道:BAAALAAECgUICQAAAA==.',['将功']='将功成万骨枯:BAAALAAECggIEAAAAA==.',['小井']='小井亚津子:BAAALAAFFAIIAgAAAA==.',['小德']='小德奶奶:BAAALAADCgMIAwAAAA==.',['小旻']='小旻:BAAALAAECgYIEAAAAA==.',['小栗']='小栗子:BAAALAADCgUIBQAAAA==.',['小熊']='小熊欧妮酱:BAABLAAFFH8mAAIHAAgIUR6DBwCNAgAHAAgIUR6DBwCNAgAAAA==.',['小猎']='小猎刃:BAABLAAFFH8JAAIHAAYISh1xJQCIAQAHAAYISh1xJQCIAQAAAA==.',['小篮']='小篮头:BAACLAAFFH8FAAIGAAMI6AUQfgBjAAAGAAMI6AUQfgBjAAAsAAQKfyUAAgYABwgAEk22AIwBAAYABwgAEk22AIwBAAAA.',['小马']='小马佩德罗:BAAALAADCgEIAQAAAA==.',['小龙']='小龙嘻:BAAALAAECgMIAwAAAA==.',['少年']='少年时:BAAALAADCgcICQAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8QAAINAAgIvghbCQC6AQANAAgIvghbCQC6AQAAAA==.',['山碧']='山碧空:BAAALAAECgUIBwAAAA==.',['巧克']='巧克力雪糕:BAAALAAECgIIAgAAAA==.',['巴都']='巴都猛干:BAAALAAECggIBgAAAA==.',['希格']='希格尔德:BAAALAAECgYIDwAAAA==.',['幻兽']='幻兽钠鲁:BAABLAAFFH8dAAMXAAYIaRsxBgACAgAXAAYIaRsxBgACAgASAAIIUwFDOgCAAAAAAA==.',['幽灵']='幽灵黑骑:BAABLAAFFH8FAAIBAAMImxROWwCfAAABAAMImxROWwCfAAAAAA==.',['开喉']='开喉剑:BAAALAADCgUIBQAAAA==.',['影歌']='影歌追猎者:BAAALAAECgYIBgAAAA==.',['徳丶']='徳丶九爺:BAAALAAECgIIAgAAAA==.',['德莱']='德莱骑士:BAAALAADCgMIAgAAAA==.',['怎么']='怎么又下雨:BAABLAAFFH8LAAIGAAYIuhYrHwANAQAGAAYIuhYrHwANAQAAAA==.',['恋花']='恋花蝶舞:BAAALAAECgMIAwAAAA==.',['恋静']='恋静曦:BAACLAAFFH8IAAMYAAMIqgxTBgCPAAAYAAIIOA1TBgCPAAAWAAMIqgzxVACMAAAsAAQKfxQAAxYACAjQIAVKACgCABYACAjQIAVKACgCABkAAwjOHMtjAOQAAAAA.',['惡魔']='惡魔在身边:BAAALAAECgYIBgAAAA==.',['慕容']='慕容重复:BAABLAAFFH8FAAMVAAUIYAPbHACEAAAHAAMIOALNSwCQAAAVAAIIHAXbHACEAAAAAA==.',['我是']='我是红牛:BAAALAADCgEIAQAAAA==.',['战争']='战争獠牙:BAAALAAECgIIAgAAAA==.',['战损']='战损小薇:BAAALAAECgMIAwAAAA==.',['战斗']='战斗爽:BAAALAAECggIAQAAAA==.',['打个']='打个滚:BAAALAAECgIIBAAAAA==.',['拎着']='拎着夜壶冲:BAAALAAECgMIAwAAAA==.',['拓丫']='拓丫霸丫硬:BAACLAAFFH8NAAIBAAUIVgP7UgDVAAABAAUIVgP7UgDVAAAsAAQKfxUAAgEABghFFWVSAFIBAAEABghFFWVSAFIBAAAA.',['拓荒']='拓荒镇魂曲:BAAALAAECggICQAAAA==.',['拓跋']='拓跋珪:BAABLAAFFH8GAAIFAAYIAgnnMAAJAQAFAAYIAgnnMAAJAQAAAA==.',['招蜂']='招蜂引蝶:BAAALAAECgIIAgAAAA==.',['捣蛋']='捣蛋的蛋:BAAALAAECgUIBQAAAA==.',['掌控']='掌控大菊:BAAALAAECgIIAgABLAAFFAYILQAPAKoWAA==.',['敏菲']='敏菲利亚:BAABLAAFFH8GAAIGAAYI2QiPUwAJAQAGAAYI2QiPUwAJAQAAAA==.',['散场']='散场的小迷妹:BAAALAAFFAIIAwABLAAFFAYIGwAMAIEfAA==.',['整点']='整点薯条:BAABLAAFFH8JAAIBAAMIzBRvMQDWAAABAAMIzBRvMQDWAAABLAAFFAgIAQAKAAAAAA==.',['斩地']='斩地乄:BAAALAAECggICAAAAA==.',['斯文']='斯文丶败类:BAAALAAECgcIBwAAAA==.',['新手']='新手村村花:BAAALAAFFAIIAgAAAA==.',['无头']='无头哒哒滴:BAAALAAECgUIBQAAAA==.',['无形']='无形之刃丶:BAAALAAFFAMIBAAAAA==.',['时雨']='时雨:BAAALAAECgQIBQABLAAFFAIIAgAKAAAAAA==.',['星期']='星期六男爵:BAABLAAECn8VAAIBAAgI8hwhMQCvAgABAAgI8hwhMQCvAgAAAA==.',['晓銠']='晓銠斧:BAABLAAFFH8OAAMJAAYIzg5yEwBdAQAJAAYIzg5yEwBdAQAFAAIIVg9gXgBIAAAAAA==.',['晨曦']='晨曦风行耀:BAABLAAFFH8cAAMJAAYITR+yBwAYAgAJAAYITR+yBwAYAgAFAAYIQhUdGgCNAQAAAA==.',['晴川']='晴川夏:BAABLAAFFH8GAAIUAAIIQRhFEQCRAAAUAAIIQRhFEQCRAAAAAA==.',['晶歌']='晶歌蓓儿:BAABLAAECn8YAAIGAAYIdyMoOADmAQAGAAYIdyMoOADmAQAAAA==.',['暗之']='暗之星光:BAAALAAECggICAAAAA==.',['暴风']='暴风行者:BAAALAAECgYICAABLAAFFAIIAgAKAAAAAA==.',['曰理']='曰理万基:BAACLAAFFH8KAAIMAAIIyBprRwCTAAAMAAIIyBprRwCTAAAsAAQKfxcAAgwABggsHvJdAM4BAAwABggsHvJdAM4BAAAA.',['月儿']='月儿弯弯:BAACLAAFFH8tAAMBAAcI8yILBQBTAgABAAcI8yILBQBTAgAQAAEI7w4oHgBNAAAsAAQKfzMAAgEACAhEJvcFAGgDAAEACAhEJvcFAGgDAAAA.',['有货']='有货:BAAALAAFFAIIAgAAAA==.',['未竞']='未竞的事业:BAABLAAFFH8GAAICAAIIygQoXwA4AAACAAIIygQoXwA4AAAAAA==.',['朵朵']='朵朵闪闪:BAAALAADCgIIAgAAAA==.',['杀耳']='杀耳:BAABLAAFFH8aAAMaAAYIbhbjBwC5AQAaAAYIbhbjBwC5AQAbAAMIjwe/EQCEAAABLAAFFAYIHAAJAE0fAA==.',['杏仁']='杏仁核桃饼:BAABLAAECn8cAAISAAgILB3yGAClAgASAAgILB3yGAClAgAAAA==.',['村口']='村口背尸人:BAABLAAFFH8dAAITAAYIrBKtCACVAQATAAYIrBKtCACVAQAAAA==.',['梦梦']='梦梦:BAAALAAECgUIBgAAAA==.',['榨菜']='榨菜牛肉:BAAALAAECgYIBAAAAA==.',['欲星']='欲星移:BAAALAAECgcIBwAAAA==.',['正义']='正义东征:BAAALAAECgYIBgAAAA==.',['武僧']='武僧熊猫:BAAALAAECgQIBAAAAA==.',['比萝']='比萝蒂丝:BAAALAAECgYIDAAAAA==.',['汐水']='汐水如嫣丶:BAAALAAECggIDgABLAAFFAYIIgABAIIQAA==.',['沉鱼']='沉鱼:BAAALAAECgUIBQAAAA==.',['沧玥']='沧玥:BAAALAAECgMIAwAAAA==.',['沧蝶']='沧蝶:BAABLAAFFH8MAAMGAAMI7B0fQACmAAAGAAMI7B0fQACmAAAcAAIIdRL0JAB+AAAAAA==.',['油压']='油压按摩:BAAALAAECgUICQAAAA==.',['流水']='流水无弦:BAABLAAFFH8cAAMdAAYIbB+GBgDSAQAdAAYIbB+GBgDSAQAeAAEIRBACDABHAAAAAA==.',['浮沉']='浮沉:BAAALAAFFAIIAgAAAA==.',['涩小']='涩小美:BAAALAAFFAIIBAAAAA==.',['涮羊']='涮羊肉:BAAALAADCgYIBgAAAA==.',['清风']='清风拂明月:BAAALAAECgYICgAAAA==.',['温暖']='温暖的僵尸:BAABLAAECn8aAAMfAAcI8Bv6EwAJAgAfAAYI+B36EwAJAgATAAcI8hhBJwDjAQAAAA==.',['温柔']='温柔一刀死:BAAALAAECgUIBgAAAA==.',['滋养']='滋养者魔理沙:BAABLAAFFH8FAAILAAMIghIgMQCpAAALAAMIghIgMQCpAAABLAAFFAcIMwAMAKIhAA==.',['潘多']='潘多拉:BAABLAAECn8eAAMOAAYIQBGOawAVAQAOAAYIQBGOawAVAQALAAYIqwXFYwCWAAAAAA==.',['火辣']='火辣靓仔:BAABLAAECn8YAAIBAAgIgyT9FQAZAwABAAgIgyT9FQAZAwAAAA==.',['灬摩']='灬摩卡灬:BAAALAAECggICAAAAA==.',['灰烬']='灰烬裁决:BAAALAAECggICAAAAA==.',['灰色']='灰色的幻想:BAAALAAECgYIEQAAAA==.',['灵魂']='灵魂元素:BAABLAAECn8WAAMMAAgIexdnRQAOAgAMAAYI9R5nRQAOAgAPAAgIOwBD4QAQAAAAAA==.灵魂引导者:BAABLAAFFH8XAAISAAUINxozGQCNAQASAAUINxozGQCNAQABLAAFFAYIHAAJAE0fAA==.灵魂得叹息:BAACLAAFFH82AAICAAgIciM4AgDjAgACAAgIciM4AgDjAgAsAAQKfysAAgIACAhVJvkGAF4DAAIACAhVJvkGAF4DAAAA.',['炫烈']='炫烈风尘:BAAALAAECgMIBAAAAA==.',['然然']='然然:BAABLAAFFH8GAAIPAAYIEhj/FwCCAQAPAAYIEhj/FwCCAQAAAA==.然然带我走吧:BAAALAAFFAIIAgAAAA==.',['燃烧']='燃烧吧少年:BAABLAAFFH8SAAIZAAUIjBmqBgBMAQAZAAUIjBmqBgBMAQAAAA==.',['爱梅']='爱梅特赛尔号:BAAALAADCgUIBQAAAA==.',['爱狠']='爱狠交加:BAABLAAFFH8GAAIZAAYIRQHPIQAlAAAZAAYIRQHPIQAlAAAAAA==.',['牛哥']='牛哥哥:BAAALAAFFAYIAwAAAA==.牛哥锤双胸:BAAALAAECggIDwAAAA==.',['牛牛']='牛牛不洗澡:BAACLAAFFH8XAAIFAAUIoh5FJQBQAQAFAAUIoh5FJQBQAQAsAAQKfx8AAgUABgh1Jds7AIcCAAUABgh1Jds7AIcCAAEsAAUUBggxAA8AsyIA.',['牛的']='牛的可爱:BAAALAAFFAIIBAAAAA==.',['牛蒡']='牛蒡子:BAAALAAFFAIIAgAAAA==.',['牛鞭']='牛鞭老妖:BAAALAADCgEIAQAAAA==.',['牧有']='牧有鱼丸丶:BAAALAAFFAIIAgAAAA==.',['狂风']='狂风小小猎:BAABLAAFFH8UAAMGAAYIUxqcIwCqAQAGAAYI4RmcIwCqAQAgAAIILxqhBACcAAAAAA==.',['狐猎']='狐猎:BAAALAADCgIIAgAAAA==.',['狸狸']='狸狸原上狐:BAAALAADCgMIAwAAAA==.',['玖七']='玖七:BAAALAAFFAMIAwAAAA==.',['玖宝']='玖宝至尊:BAABLAAFFH8MAAMEAAYIkAUMMwACAQAEAAUIjwYMMwACAQADAAEIlQB4HAAOAAAAAA==.',['玖尾']='玖尾妖猫:BAAALAAFFAIIAgAAAA==.',['玖玖']='玖玖归一:BAABLAAFFH8GAAIBAAYIagIdUADrAAABAAYIagIdUADrAAAAAA==.',['玛玛']='玛玛米雅:BAAALAAECgEIAQAAAA==.',['玲娜']='玲娜贝儿:BAABLAAECn8jAAMVAAYIPQtzTQA9AQAVAAYIIApzTQA9AQAHAAYI0QjibgC3AAAAAA==.',['珊丷']='珊丷:BAABLAAFFH8KAAIMAAYIgBpTEwDNAQAMAAYIgBpTEwDNAQAAAA==.',['珊珊']='珊珊可爱:BAAALAAECgMIAwAAAA==.',['琼蒽']='琼蒽雪诺:BAAALAAECgQIBAAAAA==.',['瓦料']='瓦料:BAAALAAFFAEIAQAAAA==.',['甜到']='甜到你心里:BAAALAAECgEIAQAAAA==.',['甜甜']='甜甜圈的甜:BAAALAAECgYIDgAAAA==.',['甲辰']='甲辰一号:BAABLAAFFH8NAAIZAAUIGhQ/CAAcAQAZAAUIGhQ/CAAcAQABLAAFFAgIBQAWAMoSAA==.甲辰小法:BAACLAAFFH8FAAIZAAMImw4wFACFAAAZAAMImw4wFACFAAAsAAQKfxQAAhkABwiUHSYfACICABkABwiUHSYfACICAAAA.',['电的']='电的你嗷嗷叫:BAABLAAFFH8GAAMPAAYIZwmGLADgAAAPAAUI8AiGLADgAAAMAAEIzgHWfwAqAAAAAA==.',['男人']='男人中的男人:BAAALAAECgQIBAAAAA==.',['疏远']='疏远我:BAAALAAFFAMIAwAAAA==.',['疯狂']='疯狂大黑牛:BAAALAAECggIDgAAAA==.疯狂星期四:BAAALAAFFAIIAgAAAA==.疯狂的复仇:BAAALAAECgEIAQAAAA==.疯狂的小溪:BAAALAAECgYIBgAAAA==.',['白小']='白小葵:BAABLAAFFH8GAAILAAIIUxrxPAB/AAALAAIIUxrxPAB/AAAAAA==.',['白糖']='白糖小飞牛:BAAALAAECgMIAwAAAA==.白糖还是甜:BAAALAAFFAIIBAAAAA==.',['白织']='白织:BAAALAAFFAIIAgAAAA==.',['白色']='白色十字架:BAACLAAFFH8JAAIWAAMILAacTQBdAAAWAAMILAacTQBdAAAsAAQKfxoAAhYACAhfEkNaAPUBABYACAhfEkNaAPUBAAAA.',['白花']='白花蛇草:BAAALAAECgcIBwAAAA==.',['百变']='百变释小槐:BAAALAAECgUIAgAAAA==.',['石拳']='石拳毁灭者:BAAALAAECgMICgAAAA==.',['祭奠']='祭奠丶秋:BAABLAAFFH8XAAMFAAYITCBWDADmAQAFAAYITCBWDADmAQAJAAII9SGZEgDLAAAAAA==.',['秋夜']='秋夜之风:BAAALAAECgYICQAAAA==.',['空灵']='空灵乍现:BAAALAADCgIIAgAAAA==.',['站在']='站在云端的鸡:BAABLAAFFH8GAAMPAAYIoRsXHQBdAQAPAAUItB0XHQBdAQAMAAEIqwo/ewA3AAAAAA==.',['笨蛋']='笨蛋快快跑:BAAALAADCgEIAQAAAA==.',['简单']='简单一点:BAAALAAECgMIAwAAAA==.',['箕子']='箕子:BAAALAAECgUIBgAAAA==.',['米兰']='米兰灬卡卡:BAAALAADCgIIAgAAAA==.',['索德']='索德罗斯:BAAALAAFFAIIBAABLAAFFAMIBQAWAKQNAA==.',['紫羽']='紫羽飛璇:BAAALAAECgYIBgAAAA==.',['红之']='红之机神将:BAAALAADCgEIAQAAAA==.',['红烧']='红烧大猪蹄:BAAALAAECgYICwAAAA==.',['绛宫']='绛宫:BAAALAAECgQIBAAAAA==.',['绝刹']='绝刹无泪:BAAALAAECgYIBgAAAA==.',['绫波']='绫波俪:BAABLAAFFH8SAAMcAAYIPA8iCABBAQAcAAYIPA8iCABBAQAGAAQIxwq1aQCZAAAAAA==.',['维斯']='维斯:BAAALAAFFAIIBAAAAA==.',['缇娅']='缇娅莫:BAAALAAECgYIBgAAAA==.',['羊蝎']='羊蝎:BAAALAADCgYIBgAAAA==.',['美企']='美企鹅骑士:BAAALAAECgMIAwAAAA==.',['羲泽']='羲泽:BAAALAADCgIIAgAAAA==.',['翻个']='翻个身:BAAALAADCgIIAgAAAA==.',['老吴']='老吴:BAAALAAFFAQIBAAAAA==.',['脾气']='脾气好:BAABLAAECn8XAAIBAAYIiQ6iagAcAQABAAYIiQ6iagAcAQAAAA==.',['芝麻']='芝麻葵葵球:BAABLAAFFH8QAAIGAAYIZSQyFwDjAQAGAAYIZSQyFwDjAQAAAA==.',['芭乐']='芭乐波波:BAABLAAFFH8GAAMWAAYIMxK0GQCOAQAWAAUIYBS0GQCOAQAYAAEIVAezDABIAAAAAA==.',['苍白']='苍白血色:BAAALAADCgMIAwAAAA==.',['苏海']='苏海伦:BAAALAAFFAIIAgAAAA==.',['苏西']='苏西玛丽苏:BAACLAAFFH8zAAIMAAcIoiF/AwCeAgAMAAcIoiF/AwCeAgAsAAQKfzcAAgwABwiVIx8VAEwCAAwABwiVIx8VAEwCAAAA.',['苹果']='苹果脆:BAAALAADCgYIBQAAAA==.',['莉莉']='莉莉哈特:BAAALAAECgQIBAAAAA==.',['莉莲']='莉莲娜维斯:BAAALAAFFAIIBAAAAA==.',['莱轲']='莱轲尼:BAAALAADCgcICgAAAA==.',['菲龙']='菲龙在天:BAAALAAECgIIAgAAAA==.',['萌萌']='萌萌小湿弟:BAAALAAECgcIBwAAAA==.萌萌德开水:BAAALAAECgcIEAAAAA==.',['萨丽']='萨丽丝:BAAALAAFFAIIAgAAAA==.',['蓝色']='蓝色闪电:BAABLAAFFH8FAAIPAAIIrREVQABLAAAPAAIIrREVQABLAAAAAA==.',['蔚一']='蔚一:BAAALAAFFAIIAgAAAA==.',['蔚三']='蔚三:BAAALAAFFAIIAgAAAA==.',['蔚四']='蔚四:BAAALAAECgYIBgAAAA==.',['蕉大']='蕉大狼:BAABLAAFFH8GAAIEAAIIxgSnbQAwAAAEAAIIxgSnbQAwAAAAAA==.',['蕉太']='蕉太狼:BAABLAAFFH8NAAIZAAIIOxlSEQCMAAAZAAIIOxlSEQCMAAAAAA==.',['血之']='血之哀伤丶:BAAALAAECgYIBgAAAA==.',['血域']='血域魅影:BAAALAAECggICAAAAA==.',['血港']='血港鬼影丶:BAAALAADCgIIAgAAAA==.',['裤兜']='裤兜里空空:BAAALAAECgYIEAAAAA==.',['西地']='西地那非:BAAALAAFFAIIAgAAAA==.',['要暴']='要暴击不要血:BAAALAADCgQICAAAAA==.',['角很']='角很大:BAAALAAECgUICQAAAA==.',['诈尸']='诈尸:BAABLAAFFH8FAAIMAAIIkRxmQQClAAAMAAIIkRxmQQClAAAAAA==.',['诗丷']='诗丷:BAABLAAFFH8MAAMMAAYI0xpXGACgAQAMAAYI0xpXGACgAQAPAAIIXRnMMACzAAAAAA==.',['说太']='说太岁:BAAALAAECgMIAwAAAA==.',['请容']='请容我失礼了:BAAALAAFFAIIAgAAAA==.',['豹子']='豹子头丶林冲:BAABLAAFFH8IAAIGAAgIKho9CQBYAgAGAAgIKho9CQBYAgAAAA==.',['財达']='財达器粗:BAAALAAFFAIIAgAAAA==.',['贰月']='贰月丶流年:BAABLAAFFH8KAAMQAAMIihE0DACaAAAQAAMIihE0DACaAAABAAEIFAFoowAzAAAAAA==.',['赞达']='赞达拉巨模:BAABLAAECn8XAAIFAAgIJRx3UwBIAgAFAAgIJRx3UwBIAgAAAA==.',['赫连']='赫连宝:BAAALAAFFAMIAwAAAA==.',['超超']='超超萌小熊猫:BAAALAAECgEIAQAAAA==.',['路西']='路西法文:BAAALAADCgYIBgAAAA==.',['躲起']='躲起来插旗:BAAALAAECgIIAgAAAA==.',['辉耀']='辉耀龙心:BAAALAAECgYIBgAAAA==.',['过期']='过期的汽水:BAAALAADCgYIBgAAAA==.',['过气']='过气演员:BAAALAAFFAIIAgAAAA==.',['进击']='进击的锅巴菜:BAAALAADCgMIAwAAAA==.',['迪丽']='迪丽冷巴:BAABLAAFFH8FAAIdAAUIcQFgFgCcAAAdAAUIcQFgFgCcAAAAAA==.',['送你']='送你上路:BAAALAADCgUIBQAAAA==.',['邪伯']='邪伯伯:BAAALAAFFAIIAgAAAA==.',['部落']='部落先遣队:BAABLAAFFH8GAAIEAAIILhNUUQBJAAAEAAIILhNUUQBJAAAAAA==.',['郭襄']='郭襄:BAAALAAECgYIBgAAAA==.',['都行']='都行:BAAALAAECgYIEAAAAA==.',['酒酿']='酒酿萝卜皮:BAAALAAECggICAAAAA==.',['酥麻']='酥麻小风尘:BAAALAADCgMIAwAAAA==.',['酸檸']='酸檸檬:BAABLAAFFH8JAAILAAMIJBfcIQCeAAALAAMIJBfcIQCeAAAAAA==.',['酸汤']='酸汤清江鱼:BAAALAADCgQIBAAAAA==.',['释槐']='释槐:BAABLAAFFH8jAAIMAAYITyNgAwAhAgAMAAYITyNgAwAhAgAAAA==.',['鏾丶']='鏾丶九爺:BAAALAAECgYIBgAAAA==.',['铁人']='铁人克克:BAABLAAFFH8GAAIIAAIIDSPUDwDPAAAIAAIIDSPUDwDPAAAAAA==.',['铁锅']='铁锅炖熊掌:BAAALAAECgYIBgAAAA==.铁锅炖熊猫:BAAALAAECgcIDQAAAA==.',['长长']='长长见识:BAAALAADCgQIBAAAAA==.',['防弹']='防弹小叮当:BAAALAADCgMIAwAAAA==.',['阿勒']='阿勒斯蠱:BAAALAAECgUIBQAAAA==.',['阿强']='阿强:BAAALAAFFAIIAgAAAA==.',['阿斯']='阿斯忒瑞亚:BAAALAAFFAEIAQAAAA==.',['阿諾']='阿諾死也性格:BAAALAAFFAIIAgAAAA==.',['陈景']='陈景清:BAAALAAECgUIBQAAAA==.',['陈洁']='陈洁齐:BAAALAAECgYICAAAAA==.',['陈老']='陈老师会摄影:BAAALAAECgYIBgAAAA==.',['陌予']='陌予倾年:BAAALAAECgEIAQAAAA==.',['雪狼']='雪狼土灵守护:BAAALAAECgEIAQAAAA==.',['零纳']='零纳呗尔:BAAALAAFFAIIBAAAAA==.',['雷碧']='雷碧城:BAAALAAECgYIBwAAAA==.',['雾老']='雾老狗:BAAALAAECgYICwAAAA==.',['雾都']='雾都啊:BAAALAAECgYICwAAAA==.',['霜杯']='霜杯雪盏:BAAALAAECggICAAAAA==.',['靓仔']='靓仔王:BAABLAAECn8WAAIFAAgIDCOZHQD8AgAFAAgIDCOZHQD8AgAAAA==.',['静幽']='静幽暗魔丶:BAAALAAECggICAAAAA==.',['風風']='風風雨雨:BAAALAAFFAIIAgAAAA==.',['风之']='风之喜怒无常:BAABLAAFFH8GAAIGAAIIlho5ZgCHAAAGAAIIlho5ZgCHAAAAAA==.风之宁静:BAAALAADCggICAAAAA==.风之迅捷:BAAALAAECgIIAgAAAA==.',['风信']='风信:BAAALAAFFAQIBAAAAA==.',['风骚']='风骚猎神:BAABLAAFFH8OAAMgAAMIXBvCAgCzAAAgAAIIhSDCAgCzAAAGAAMIaRmebACPAAAAAA==.',['馒头']='馒头哥:BAABLAAECn8jAAICAAcI7QoLVQAYAQACAAcI7QoLVQAYAQAAAA==.',['馨颜']='馨颜:BAAALAAECgEIAQAAAA==.',['马大']='马大碗:BAAALAAECgYIBgAAAA==.',['骑不']='骑不动马:BAABLAAFFH8HAAIFAAMIwBZKQgCSAAAFAAMIwBZKQgCSAAAAAA==.',['鬼鬼']='鬼鬼老头:BAAALAADCgQIBAAAAA==.',['魔法']='魔法模子:BAABLAAFFH8IAAIWAAIIjAvJVACMAAAWAAIIjAvJVACMAAAAAA==.',['魔鬼']='魔鬼丶终结者:BAAALAAECgMIAwAAAA==.',['鱼小']='鱼小橘:BAABLAAFFH8MAAIhAAMIaxUDCABuAAAhAAMIaxUDCABuAAAAAA==.',['鹤鸣']='鹤鸣九皋:BAAALAAECgYIBwAAAA==.',['麥仔']='麥仔茶:BAABLAAFFH8HAAMcAAMIJww5EQBoAAAcAAMIfQc5EQBoAAAGAAEIPxQxzQAAAAAAAA==.',['麥满']='麥满分:BAABLAAFFH8GAAIbAAII4QVoGwAyAAAbAAII4QVoGwAyAAAAAA==.',['麽哈']='麽哈:BAAALAAFFAIIAgAAAA==.麽哈麽哈:BAAALAAFFAIIBAAAAA==.',['黄艺']='黄艺博:BAAALAAECgYICwAAAA==.',['黑子']='黑子弹波波:BAAALAADCggICQAAAA==.',['黑暗']='黑暗神枪:BAAALAAECgQIBAAAAA==.',['鼓捣']='鼓捣以舞柠丶:BAAALAADCgEIAQAAAA==.',['齐射']='齐射落孤星:BAAALAADCgEIAQAAAA==.',['龙吟']='龙吟月:BAABLAAFFH8KAAIEAAMIoxmXPACeAAAEAAMIoxmXPACeAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end