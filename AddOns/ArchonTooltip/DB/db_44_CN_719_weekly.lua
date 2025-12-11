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
 local lookup = {'DeathKnight-Frost','Monk-Mistweaver','Hunter-BeastMastery','Paladin-Retribution','Paladin-Holy','Mage-Arcane','Warrior-Fury','Warrior-Protection','Priest-Holy','Druid-Restoration','Shaman-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Destruction','Shaman-Elemental','Mage-Frost','Druid-Guardian','Unknown-Unknown','Warlock-Demonology','Monk-Brewmaster','Monk-Windwalker','Rogue-Outlaw','Druid-Balance','Warrior-Arms','Mage-Fire','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='森金',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bl='Blanny:BAAALAAECgYICAAAAA==.',Ch='Chromium:BAABLAAFFH8KAAIBAAgIjhpnCwBEAgABAAgIjhpnCwBEAgAAAA==.',Cl='Clarence:BAABLAAFFH8IAAICAAIIjxsFEgCZAAACAAIIjxsFEgCZAAAAAA==.',Co='Coco:BAAALAAECgYIDAABLAAFFAgIEwADAMYeAA==.',Ev='Evga:BAAALAAECgQIBAAAAA==.',Hi='Hillvanas:BAAALAADCgEIAQAAAA==.',Ka='Katharineann:BAAALAAECgYICQAAAA==.',Li='Liadrin:BAAALAADCgQIBAAAAA==.',Lo='Loveishurt:BAABLAAECn8YAAMEAAYIEgyOhQD1AAAEAAYIEgyOhQD1AAAFAAYIKAVQXwDNAAAAAA==.',Lu='Luca:BAAALAAECgEIAQAAAA==.',Ma='Masaa:BAAALAAECgEIAQAAAA==.',Ni='Nichol:BAACLAAFFH8YAAIGAAYI8hDrJgB5AQAGAAYI8hDrJgB5AQAsAAQKfxQAAgYACAjiGnk5AGQCAAYACAjiGnk5AGQCAAAA.',No='Nolof:BAAALAADCgIIAgAAAA==.',Pa='Pacifier:BAAALAAECgYIDAAAAA==.',Pl='Playervhstoa:BAAALAAECgEIAQAAAA==.',Re='Reviveh:BAAALAAECgYICgAAAA==.',Se='Self:BAAALAAECggICAAAAA==.',Si='Silvanus:BAAALAAFFAIIBAAAAA==.',So='Sofast:BAAALAAECgYIBgAAAA==.',Su='Subiedk:BAAALAAFFAIIBAAAAA==.',Vi='Violenceper:BAAALAAECgIIAgAAAA==.',Wl='Wlk:BAAALAADCgQIBAAAAA==.',Ya='Yanglao:BAAALAADCgYIBgAAAA==.',Za='Zangelia:BAAALAAFFAIIAgAAAA==.Zangxixi:BAABLAAFFH8IAAMHAAYIowWVPAB9AAAHAAYIQQKVPAB9AAAIAAIIFw6KNgAqAAABLAAFFAgICwAHACohAA==.',['一只']='一只树奈奈:BAAALAADCgYICQAAAA==.',['一霓']='一霓烟火:BAAALAAFFAQIBAAAAA==.',['一香']='一香蕉一:BAABLAAFFH8FAAIBAAMIvAn/ZQB+AAABAAMIvAn/ZQB+AAAAAA==.',['万丷']='万丷疆:BAABLAAFFH8GAAIIAAIIdwo9JgBxAAAIAAIIdwo9JgBxAAAAAA==.',['上原']='上原亜衣:BAAALAADCgYIBwAAAA==.',['上头']='上头有人:BAAALAAECgEIAQAAAA==.',['不黑']='不黑:BAAALAAFFAIIBAAAAA==.',['专业']='专业大舔狗:BAAALAAFFAIIAwAAAA==.',['专砍']='专砍不动的:BAABLAAECn8VAAMHAAYItQdaZQDlAAAHAAYItQdaZQDlAAAIAAII6gVvkQBHAAAAAA==.',['世仁']='世仁林飞:BAABLAAFFH8GAAIJAAII3QrGNgCFAAAJAAII3QrGNgCFAAABLAAFFAMIEgAHALsYAA==.',['丨小']='丨小花丨:BAAALAADCgUIBQAAAA==.',['丨李']='丨李小花丨:BAAALAADCggICQAAAA==.',['丨狗']='丨狗带丨:BAAALAADCgQIBAAAAA==.',['丨鲜']='丨鲜血圣歌丨:BAAALAAECgIIAgAAAA==.',['丶巨']='丶巨蟹座:BAABLAAFFH8MAAIKAAgIZgUDOwCCAAAKAAgIZgUDOwCCAAAAAA==.',['丶狮']='丶狮子座:BAAALAAECgYIBgAAAA==.',['丶猎']='丶猎户座:BAABLAAFFH8GAAILAAII9RZsVQBwAAALAAII9RZsVQBwAAAAAA==.',['丶矫']='丶矫情:BAAALAAECgQIBAAAAA==.',['丿璐']='丿璐璐丿:BAABLAAFFH8MAAIHAAMI5hoJMwCrAAAHAAMI5hoJMwCrAAAAAA==.',['丿霸']='丿霸丷霸丿:BAABLAAFFH8NAAILAAUI4RTrIwBAAQALAAUI4RTrIwBAAQAAAA==.',['丿香']='丿香蕉丿:BAAALAAFFAMIAwAAAA==.',['丿黯']='丿黯灬痕:BAAALAADCggICAAAAA==.',['久念']='久念丶:BAEBLAAFFH8QAAIHAAYIfReWIwBRAQAHAAYIfReWIwBRAQABLAAFFAYIFAADAJYdAA==.',['乌鸡']='乌鸡:BAAALAAECggICAAAAA==.',['乔汉']='乔汉娜:BAAALAAECgYIBgAAAA==.',['九焱']='九焱:BAAALAAECgYIDwAAAA==.',['乱杀']='乱杀:BAAALAADCgYIBgAAAA==.',['二仙']='二仙桥走成华:BAAALAAECgYICwAAAA==.',['二零']='二零三六:BAAALAADCgQIBAAAAA==.',['云落']='云落箭歌:BAAALAAECgQIBAAAAA==.云落风尘:BAAALAAFFAIIAgAAAA==.',['五月']='五月天爱雨:BAAALAAECgYIDQAAAA==.五月奔雷无双:BAAALAAECgYIEAAAAA==.五月恐怖利刃:BAAALAAECggICwAAAA==.五月死亡风暴:BAAALAAECgUIBQAAAA==.',['五枂']='五枂:BAAALAADCgYIBgAAAA==.',['人皆']='人皆寻梦:BAAALAAECggIDAAAAA==.',['以魂']='以魂续命:BAAALAAECggICAAAAA==.',['伊丷']='伊丷利丷丹:BAAALAAFFAMIAwAAAA==.',['伊丽']='伊丽绍尔:BAAALAAFFAIIAgABLAAFFAgICAADAE4UAA==.',['伊利']='伊利丶牛:BAAALAADCggIDwAAAA==.',['伊祁']='伊祁:BAAALAADCgIIAgAAAA==.',['佩奇']='佩奇肉丸子:BAAALAAECggIEQAAAA==.',['倩丶']='倩丶影:BAEBLAAFFH8IAAIKAAIIkh6/LgCwAAAKAAIIkh6/LgCwAAABLAAFFAYIFAADAJYdAA==.',['做他']='做他心上月:BAAALAAECggICAAAAA==.',['傻鳗']='傻鳗:BAAALAAECgMIBQAAAA==.',['元素']='元素旋律:BAAALAAECgUIBQAAAA==.',['光中']='光中追光:BAAALAAECgYIBgAAAA==.',['光速']='光速星痕:BAAALAADCgYIBgAAAA==.',['光锭']='光锭喝七喜:BAABLAAECn8ZAAIEAAYIAh3mTgBxAQAEAAYIAh3mTgBxAQAAAA==.',['兔子']='兔子大哥:BAAALAAECgUIBQAAAA==.',['兙勥']='兙勥:BAABLAAFFH8PAAIBAAMIxx9yRgCqAAABAAMIxx9yRgCqAAAAAA==.',['兜里']='兜里有糖:BAAALAAFFAIIAgAAAA==.',['六磅']='六磅海鲜:BAABLAAFFH8KAAIBAAIIGRitfgBGAAABAAIIGRitfgBGAAAAAA==.',['兽血']='兽血沸腾:BAAALAAFFAIIAgAAAA==.',['冥殇']='冥殇:BAAALAAECgYIBgAAAA==.',['冥羽']='冥羽百合:BAAALAAECgIIAgAAAA==.',['冰火']='冰火纷飞:BAAALAADCgMIAwAAAA==.',['冲锋']='冲锋扯了蛋:BAAALAAFFAIIAgAAAA==.',['冷瞳']='冷瞳丶:BAEALAAECgYIBgABLAAFFAYIFAADAJYdAA==.',['冷静']='冷静:BAAALAAECgEIAQAAAA==.',['凉拌']='凉拌腰肝:BAAALAAECgYICgAAAA==.',['凤玉']='凤玉罗:BAABLAAFFH8PAAMMAAQIDB7iBAAoAQAMAAQIDB7iBAAoAQANAAMIYwNeFwBOAAAAAA==.',['刘斩']='刘斩仙:BAAALAAECgEIAQAAAA==.',['初吻']='初吻給勒煙:BAAALAAFFAYIAgAAAA==.',['别叫']='别叫我战复:BAABLAAFFH8GAAIBAAYILRCfMQB0AQABAAYILRCfMQB0AQAAAA==.',['勺十']='勺十六:BAAALAAECgUIBQAAAA==.',['十亿']='十亿少女的梦:BAAALAADCgYICwAAAA==.',['千紫']='千紫夏:BAABLAAECn8YAAIOAAYItAgtZQDPAAAOAAYItAgtZQDPAAAAAA==.',['南天']='南天门:BAAALAAECgYIEQABLAAFFAgICAAKADMeAA==.',['叁仟']='叁仟亿伏特:BAAALAAECgQIBAAAAA==.',['口遍']='口遍艾泽拉:BAAALAADCgIIAgAAAA==.',['古河']='古河秋生:BAAALAAECgYICAAAAA==.',['只玩']='只玩火法:BAAALAAECgYIBgAAAA==.',['吃个']='吃个大的:BAAALAAECgEIAQAAAA==.',['吉德']='吉德:BAAALAAECgUIBQAAAA==.',['吮指']='吮指原味咕:BAAALAAECgIIAgAAAA==.',['吱吱']='吱吱:BAAALAAFFAIIAgAAAA==.',['哇哈']='哇哈哈:BAAALAAFFAIIBAAAAA==.',['哈妮']='哈妮露牙:BAACLAAFFH8JAAIPAAIIegasNAB/AAAPAAIIegasNAB/AAAsAAQKfyAAAg8ABwiFFKROAM8BAA8ABwiFFKROAM8BAAAA.',['哥特']='哥特:BAAALAADCgYICgAAAA==.',['喵大']='喵大宝:BAAALAAECggICAAAAA==.',['嗜血']='嗜血奥术:BAABLAAECn8UAAMGAAYIFwgrUADEAAAGAAYIcAYrUADEAAAQAAIIlQtxQQBRAAAAAA==.',['四代']='四代目:BAAALAAECgEIAQAAAA==.',['土豆']='土豆乖乖:BAAALAAECgYIEAAAAA==.',['圣光']='圣光小花牛:BAABLAAFFH8RAAIEAAUI5BMIKQA0AQAEAAUI5BMIKQA0AQAAAA==.圣光旋律:BAAALAAECgYIDAAAAA==.圣光爆裂:BAABLAAECn8XAAMFAAYIIxWjPQBpAQAFAAYIIxWjPQBpAQAEAAEIhghlhwE1AAAAAA==.',['圣辉']='圣辉黎明:BAAALAAECgYIEgAAAA==.',['在下']='在下尽逍遥:BAABLAAFFH8IAAILAAIIOgwOYwBYAAALAAIIOgwOYwBYAAAAAA==.',['坎帕']='坎帕斯:BAAALAAFFAIIAgABLAAFFAgICAADAE4UAA==.',['堂前']='堂前飞燕:BAAALAADCgEIAQAAAA==.',['堕落']='堕落炙魔王:BAAALAAECgMIBAAAAA==.堕落的圣人:BAAALAAECggICAAAAA==.',['复仇']='复仇芭比:BAAALAAECgYIBgAAAA==.',['夜夜']='夜夜笙歌:BAAALAAFFAIIAgAAAA==.',['夜封']='夜封钰:BAAALAAFFAIIAgAAAA==.',['夜幕']='夜幕丶花未央:BAAALAADCggICAAAAA==.',['大劈']='大劈叉:BAAALAADCggICAAAAA==.',['大宝']='大宝来了:BAABLAAFFH8SAAIGAAgIjB4SBwB1AgAGAAgIjB4SBwB1AgAAAA==.',['大神']='大神:BAABLAAFFH8FAAIBAAIIoQkNnwA2AAABAAIIoQkNnwA2AAAAAA==.',['大米']='大米虫:BAAALAAECgYICQAAAA==.',['大耐']='大耐:BAACLAAFFH8bAAIEAAUIXhr6EgAhAQAEAAUIXhr6EgAhAQAsAAQKfx0AAgQABghvJC9GAGoCAAQABghvJC9GAGoCAAAA.',['大胡']='大胡子:BAAALAAECgYIDAAAAA==.',['天际']='天际无痕:BAAALAADCgEIAQAAAA==.',['天风']='天风永佑:BAAALAAECgQIBAAAAA==.',['天骏']='天骏者:BAAALAADCgQIBAAAAA==.',['奶白']='奶白色雪子:BAAALAAECgYIBgAAAA==.',['好看']='好看:BAABLAAFFH8GAAMKAAIIawVBUgBQAAAKAAIIawVBUgBQAAARAAIIYQIhEgAcAAAAAA==.',['妖妖']='妖妖铃:BAAALAAECgIIAgAAAA==.',['娃哈']='娃哈哈:BAAALAADCgIIAgAAAA==.',['娇羞']='娇羞:BAAALAADCgEIAQAAAA==.',['子曾']='子曾经曰过哦:BAAALAADCgYIBwAAAA==.',['孤高']='孤高的梦:BAAALAAECgUIBQAAAA==.',['孬头']='孬头吧唧白泽:BAAALAADCgMIAwAAAA==.',['安兹']='安兹:BAAALAAECgMIBQAAAA==.',['安静']='安静小法:BAAALAAECgYIBgAAAA==.',['宜春']='宜春:BAAALAAECgYICAABLAAFFAgICAAQAGwEAA==.',['宝总']='宝总小助理:BAAALAADCgIIAgAAAA==.宝总小护士:BAAALAAFFAIIAgAAAA==.',['寒江']='寒江独钓:BAAALAAECgQIBwAAAA==.',['寸芒']='寸芒天虹:BAAALAAECgMIAwAAAA==.',['射到']='射到你会痛:BAABLAAFFH8GAAIDAAYIMRYJNQBoAQADAAYIMRYJNQBoAQAAAA==.',['射箭']='射箭老崔:BAABLAAFFH8PAAIDAAYIWBPnQQBAAQADAAYIWBPnQQBAAQABLAAFFAgIAQASAAAAAA==.',['小予']='小予巴巴:BAABLAAFFH8FAAIOAAMIowFpVwBKAAAOAAMIowFpVwBKAAAAAA==.',['小城']='小城浪子:BAACLAAFFH8iAAIHAAYInReLFwCjAQAHAAYInReLFwCjAQAsAAQKfx4AAgcACAigG2ISAFMCAAcACAigG2ISAFMCAAAA.',['小思']='小思緒:BAAALAAECggIAgAAAA==.',['小满']='小满乀:BAAALAAECgEIAQAAAA==.',['小猪']='小猪在树上:BAAALAAECgQIBQAAAA==.小猪奔月:BAAALAAECgYIBgAAAA==.',['小猫']='小猫馋鱼:BAAALAAFFAEIAQAAAA==.',['小麦']='小麦仁:BAAALAAFFAIIAgAAAA==.',['尔尔']='尔尔丶:BAECLAAFFH8eAAMOAAYIMhnNHwCdAQAOAAYIMhnNHwCdAQATAAEIjAVPLwBEAAAsAAQKfxQAAg4ACAhsIx0GANoCAA4ACAhsIx0GANoCAAEsAAUUBggUAAMAlh0A.',['巛幻']='巛幻想:BAAALAAECgIIAgAAAA==.',['巫喵']='巫喵王再怒:BAAALAAECgMIAwAAAA==.',['布洛']='布洛克斯希加:BAABLAAECn8UAAMIAAYImBTWVwAkAQAIAAYI+A3WVwAkAQAHAAYIdBGLrwAjAQAAAA==.',['常小']='常小雯:BAAALAAECgUIBQAAAA==.',['平平']='平平无奇丶丶:BAAALAAECgMIAwAAAA==.',['幹中']='幹中学:BAABLAAFFH8RAAQUAAYIHRI3DwBUAQAUAAYIHRI3DwBUAQAVAAIIIwyOEACQAAACAAIIcwKSGQBSAAAAAA==.',['幻羽']='幻羽苍龙:BAAALAAECgIIAgAAAA==.',['床单']='床单卫士:BAAALAAECgYIBgAAAA==.',['开嗜']='开嗜血灬:BAAALAAECgYIDAAAAA==.',['弑灬']='弑灬殇:BAAALAAECgEIAQAAAA==.',['弥赛']='弥赛斯杜:BAAALAAFFAgIAgAAAA==.',['彼得']='彼得七世:BAAALAAECgYIBgAAAA==.',['心之']='心之歌奶水:BAAALAAFFAEIAQAAAA==.',['怀念']='怀念凯恩:BAAALAAECgYICgAAAA==.',['怂的']='怂的一匹:BAAALAAECgYIBgAAAA==.',['怜悯']='怜悯丶:BAECLAAFFH8YAAIJAAYInh6cCgAfAgAJAAYInh6cCgAfAgAsAAQKfxsAAgkACAglIPIGAOACAAkACAglIPIGAOACAAEsAAUUBggUAAMAlh0A.',['恐怖']='恐怖的小法:BAAALAAECgYIBgAAAA==.',['悠緈']='悠緈天空:BAAALAAECgYIDAAAAA==.',['惩罚']='惩罚队友:BAABLAAFFH8IAAIWAAII7RhfBACdAAAWAAII7RhfBACdAAAAAA==.',['愤怒']='愤怒的小霍霍:BAABLAAECn8VAAILAAcI2hckYADIAQALAAcI2hckYADIAQAAAA==.',['慑魂']='慑魂的随便果:BAAALAAECgIIAwAAAA==.',['憾天']='憾天:BAAALAAFFAIIAgAAAA==.',['我甜']='我甜甜圈呢:BAAALAAECgUIBQAAAA==.',['我的']='我的圣光啊哈:BAAALAAFFAIIAgAAAA==.我的天啊:BAAALAADCgUIBQAAAA==.',['我要']='我要反三俗:BAAALAAECgYIEwAAAA==.',['戰丨']='戰丨将:BAAALAAECgYIEgAAAA==.',['戴绮']='戴绮斯:BAAALAAECgYIBwAAAA==.',['所有']='所有的人希望:BAAALAAECggICAAAAA==.',['扬帆']='扬帆起航:BAAALAAFFAMIAwAAAA==.',['折戟']='折戟沉沙:BAABLAAFFH8RAAIBAAYIvRdwJgCbAQABAAYIvRdwJgCbAQAAAA==.',['搔劈']='搔劈:BAABLAAFFH8IAAIOAAII3xEdPQCbAAAOAAII3xEdPQCbAAAAAA==.',['救赎']='救赎肀审判:BAABLAAECn8jAAIEAAYIah0KSQCBAQAEAAYIah0KSQCBAQAAAA==.',['无尽']='无尽审判:BAAALAADCgIIAgAAAA==.无尽幻影:BAAALAADCgYICQAAAA==.无尽月色:BAAALAADCgQIBAAAAA==.',['时光']='时光嘞:BAAALAADCgIIAgAAAA==.',['晓可']='晓可乐:BAAALAAFFAUIAgAAAA==.',['晨钟']='晨钟暮鼓:BAAALAAECgMIBQAAAA==.',['智者']='智者晓彻:BAAALAAECgYIBwABLAAFFAgIIQACAFYbAA==.',['暴走']='暴走小鸡蛋:BAAALAAECggICAAAAA==.',['暴金']='暴金之妖孽:BAABLAAFFH8nAAIJAAYIqRGbEQAqAQAJAAYIqRGbEQAqAQAAAA==.',['最后']='最后的希望丶:BAAALAAECgYICAAAAA==.',['月下']='月下曙光:BAAALAAFFAIIAgAAAA==.',['月光']='月光星晨:BAAALAAFFAIIAgAAAA==.',['月嫂']='月嫂:BAAALAADCgQIBAAAAA==.',['月莓']='月莓:BAAALAAFFAMIAgAAAA==.',['有头']='有头的刑天:BAAALAAECgUIAgAAAA==.',['有容']='有容:BAAALAAECgQIBAAAAA==.',['朗姆']='朗姆酒:BAAALAAECgYIBwAAAA==.',['术三']='术三绝:BAAALAAECgIIAgAAAA==.',['朵依']='朵依:BAABLAAFFH8GAAIBAAIIEBjTVQCyAAABAAIIEBjTVQCyAAABLAAFFAgICAADAE4UAA==.',['杀了']='杀了我就缺德:BAABLAAECn8XAAMXAAYInw2ENQDqAAAXAAYInw2ENQDqAAAKAAYI+wZDpQDKAAAAAA==.',['杜龍']='杜龍坦:BAAALAAFFAEIAQAAAA==.',['林秋']='林秋:BAAALAADCgMIAwAAAA==.',['枫花']='枫花恋:BAAALAADCgIIAgAAAA==.',['柠檬']='柠檬心:BAABLAAFFH8KAAIOAAIIRQumTQCFAAAOAAIIRQumTQCFAAAAAA==.',['柳贯']='柳贯一:BAAALAAECgYIBgAAAA==.',['栋哥']='栋哥霸天下:BAAALAAFFAIIBAAAAA==.',['梨花']='梨花白:BAABLAAFFH8FAAIDAAIIYQgLqgA6AAADAAIIYQgLqgA6AAAAAA==.',['楚门']='楚门的世界:BAABLAAECn8YAAIQAAYI3BlLFQCBAQAQAAYI3BlLFQCBAQAAAA==.',['楸木']='楸木浸清寒:BAAALAAECggIBwAAAA==.',['樂佰']='樂佰氏:BAAALAAFFAIIAgAAAA==.',['欣丶']='欣丶:BAEALAAFFAIIAgABLAAFFAYIFAADAJYdAA==.',['欣辛']='欣辛:BAAALAADCggICAAAAA==.',['止战']='止战之傷:BAAALAAECgYIBwAAAA==.',['正经']='正经人:BAAALAAFFAIIBAAAAA==.',['死丨']='死丨騎:BAAALAAECggICAAAAA==.',['殺戮']='殺戮艺朮:BAAALAAECgMIAwAAAA==.',['气鼓']='气鼓鼓小面包:BAAALAAFFAEIAQAAAA==.',['沃特']='沃特伐:BAAALAAECggICAAAAA==.',['沐沐']='沐沐阳阳:BAAALAAFFAIIBAAAAA==.',['沐阳']='沐阳先生:BAAALAAFFAIIAgAAAA==.',['没事']='没事吐泡泡:BAAALAADCgEIAQAAAA==.',['沾花']='沾花惹草奶爹:BAABLAAECn8YAAMFAAcI+gSMLwDJAAAFAAcI+gSMLwDJAAAEAAQI3gMjzABjAAAAAA==.',['法号']='法号给力:BAABLAAECn8ZAAIQAAgISBtKDAD3AQAQAAgISBtKDAD3AQAAAA==.',['泷囍']='泷囍:BAACLAAFFH8IAAIBAAIIAxYdfgBGAAABAAIIAxYdfgBGAAAsAAQKfyEAAgEABgitIaN2AAoCAAEABgitIaN2AAoCAAAA.',['泽西']='泽西:BAAALAAECgcIDAAAAA==.',['流行']='流行风无敌:BAAALAAECgYIBwAAAA==.',['浅雾']='浅雾丶:BAECLAAFFH8OAAILAAIICBoCSACOAAALAAIICBoCSACOAAAsAAQKfxYAAwsABgj5ItIUAEsCAAsABgj5ItIUAEsCAA8ABghyFwwuAFwBAAEsAAUUBggUAAMAlh0A.',['浪德']='浪德虚:BAABLAAFFH8GAAIXAAIIZxGuMgA+AAAXAAIIZxGuMgA+AAAAAA==.',['海螺']='海螺:BAABLAAFFH8OAAIQAAUIQQzcCAD9AAAQAAUIQQzcCAD9AAAAAA==.',['润氧']='润氧博士:BAABLAAECn8WAAIEAAYIaxn9TAB2AQAEAAYIaxn9TAB2AQAAAA==.',['淋秋']='淋秋:BAAALAAECgYIBgAAAA==.',['深藏']='深藏身与名:BAAALAAECgMIAwAAAA==.',['清允']='清允丶:BAECLAAFFH8UAAIDAAYIlh3aHAC/AQADAAYIlh3aHAC/AQAsAAQKfxQAAgMABghPISpMAK0BAAMABghPISpMAK0BAAAA.',['清风']='清风借我酒:BAAALAADCgYIBgAAAA==.清风明月:BAAALAAFFAIIBAAAAA==.',['瀚海']='瀚海阑丈冰:BAACLAAFFH8fAAIBAAYI6w8tMgDTAAABAAYI6w8tMgDTAAAsAAQKfyQAAgEABwgMGohwABUCAAEABwgMGohwABUCAAAA.',['火多']='火多重:BAAALAAECgUIBQAAAA==.',['火正']='火正重黎:BAAALAAECgEIAQAAAA==.火正鸣霜:BAAALAAECgEIAQAAAA==.',['灬小']='灬小玖灬:BAAALAAFFAMIBAAAAA==.',['灬蒗']='灬蒗菋蘚灬:BAAALAAECgYIBgAAAA==.',['灰太']='灰太狼:BAAALAAECgYIBgAAAA==.',['烈焰']='烈焰之靈:BAAALAAECgYIDAAAAA==.',['熊猫']='熊猫罐头:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃烤五花:BAAALAAECgUICAAAAA==.',['爱沫']='爱沫德:BAAALAAECgEIAQAAAA==.',['牛叁']='牛叁哥:BAAALAAFFAIIAgAAAA==.',['物十']='物十三:BAABLAAFFH8GAAIEAAIIthAuRACbAAAEAAIIthAuRACbAAAAAA==.物十二:BAABLAAFFH8FAAIBAAIITxBTfQCJAAABAAIITxBTfQCJAAAAAA==.',['狂野']='狂野元素:BAAALAAFFAIIBAAAAA==.',['狐说']='狐说:BAAALAADCgYIBgAAAA==.',['狗二']='狗二蛋:BAAALAAECgMIAwAAAA==.',['猎魔']='猎魔者迪迦:BAAALAAECgYICAAAAA==.',['猩红']='猩红丶:BAECLAAFFH8hAAIBAAYI7xuzHADDAQABAAYI7xuzHADDAQAsAAQKfxYAAgEABggGIr5FAHEBAAEABggGIr5FAHEBAAEsAAUUBggUAAMAlh0A.',['猫缠']='猫缠小:BAAALAAECgYIBgAAAA==.',['獵丨']='獵丨人:BAABLAAFFH8GAAIDAAYIexAjUwACAQADAAYIexAjUwACAQAAAA==.',['瑞美']='瑞美千色:BAAALAAECgEIAQAAAA==.',['留连']='留连往返:BAAALAAECggICAAAAA==.',['疯狂']='疯狂小剑:BAAALAADCgIIAgAAAA==.',['皇啊']='皇啊玛:BAABLAAECn8XAAIBAAYIsRiiqwC1AQABAAYIsRiiqwC1AQAAAA==.',['盐不']='盐不咸:BAAALAADCgcICQAAAA==.',['盐加']='盐加一勺:BAAALAADCgEIAQAAAA==.',['盖世']='盖世英牛:BAAALAADCgIIAgAAAA==.',['相熊']='相熊熊:BAAALAAFFAIIAgAAAA==.',['瞅你']='瞅你咋哋:BAABLAAECn8YAAIKAAYIwxaxKwCFAQAKAAYIwxaxKwCFAQAAAA==.',['瞅妳']='瞅妳咋地:BAAALAAECgYIBgAAAA==.',['瞅誰']='瞅誰誰懐孕:BAAALAAECgUIBQAAAA==.',['短腿']='短腿的反击:BAAALAAFFAIIAgAAAA==.',['碧水']='碧水玄冰:BAAALAAECgYIBgAAAA==.',['神丶']='神丶棍:BAAALAAECgQIBAAAAA==.',['神说']='神说喓有光:BAAALAAECgYIDAAAAA==.',['私欲']='私欲:BAACLAAFFH8iAAIHAAgIMCTOGgCPAQAHAAgIMCTOGgCPAQAsAAQKfx4AAwcABwgwJPsTAEMCAAcABwgwJPsTAEMCABgAAghECUM3AEkAAAAA.',['秋水']='秋水丶怡人:BAEBLAAFFH8JAAIJAAMI4xzHJgD/AAAJAAMI4xzHJgD/AAABLAAFFAYIFAADAJYdAA==.',['稍安']='稍安勿躁:BAAALAADCgEIAQAAAA==.',['空橙']='空橙记:BAAALAAECgYIEQAAAA==.',['筱筱']='筱筱酥:BAAALAAECggIAwAAAA==.',['筱蘑']='筱蘑菇:BAAALAAECgYIBgAAAA==.',['简约']='简约而不简单:BAACLAAFFH8wAAMPAAcIOhTREwAkAQAPAAUI7xPREwAkAQALAAcIjgatGgDfAAAsAAQKfzoAAwsACAg1GrlGAAoCAAsACAg1GrlGAAoCAA8ABwjkGjk/AAgCAAAA.简约而且简单:BAAALAAFFAIIAgAAAA==.',['箭无']='箭无虚发:BAAALAADCgEIAQAAAA==.',['米拉']='米拉尔:BAAALAAECgUIBQAAAA==.',['红的']='红的发黑:BAAALAAECgYIEgAAAA==.',['红色']='红色体育生:BAAALAAFFAIIBAAAAA==.',['维尔']='维尔海姆:BAAALAAECgEIAQAAAA==.',['美女']='美女与野兽:BAABLAAFFH8MAAIDAAUIDwqfVgDyAAADAAUIDwqfVgDyAAAAAA==.',['羙丶']='羙丶兮兮:BAAALAAECgYIDQAAAA==.',['聖丨']='聖丨騎:BAABLAAFFH8GAAIEAAYI4gzMIwBRAQAEAAYI4gzMIwBRAQAAAA==.',['肥猫']='肥猫:BAAALAAECgQIBAAAAA==.',['胖青']='胖青:BAAALAAECgIIAgAAAA==.',['艾丽']='艾丽丶:BAECLAAFFH8XAAQZAAYIAhNjAwB0AQAZAAYIoxBjAwB0AQAQAAII4R+zEABaAAAGAAIIVhLvUABMAAAsAAQKfx8ABBkACAgAItEAAL8CABkACAgAItEAAL8CAAYABwhSGSFsAMQBABAABAhIGwMzAKQAAAEsAAUUBggUAAMAlh0A.',['苍天']='苍天冰:BAAALAAECgYIBwAAAA==.',['苍岚']='苍岚之刃:BAAALAAFFAIIAgAAAA==.',['苍月']='苍月残:BAACLAAFFH8wAAIaAAgIYhzYBgBpAgAaAAgIYhzYBgBpAgAsAAQKfygAAhoACAhSISkeAOsCABoACAhSISkeAOsCAAAA.',['若夕']='若夕:BAAALAADCgQIBAAAAA==.',['英特']='英特尔:BAABLAAFFH8IAAITAAgIyQJyGgAdAAATAAgIyQJyGgAdAAAAAA==.',['荒野']='荒野大刀哥:BAABLAAFFH8FAAIDAAII0AnCuAAxAAADAAII0AnCuAAxAAAAAA==.',['莫德']='莫德里奇:BAAALAAFFAIIAgAAAA==.',['莫笑']='莫笑丶不笑:BAAALAAECgYIBgAAAA==.',['莱杰']='莱杰罗:BAAALAAECgYIBgAAAA==.',['菊痛']='菊痛:BAAALAADCgIIAgAAAA==.',['菠菜']='菠菜焖红蹄:BAAALAAECggIEgAAAA==.',['萨不']='萨不满:BAAALAAECgcICAAAAA==.',['蓉城']='蓉城晓喵:BAAALAAECgMIBgAAAA==.',['蕾妮']='蕾妮拉:BAAALAADCgYICAAAAA==.',['蕾姆']='蕾姆:BAAALAADCgEIAQAAAA==.',['蛋皇']='蛋皇派:BAABLAAFFH8FAAIFAAIIdwueIACGAAAFAAIIdwueIACGAAAAAA==.',['蝎子']='蝎子灬:BAAALAAECgYIDQAAAA==.',['血染']='血染小强:BAAALAADCgMIAwAAAA==.',['血羽']='血羽:BAABLAAFFH8YAAIGAAYIfCJxDwAAAgAGAAYIfCJxDwAAAgAAAA==.',['血色']='血色模特:BAAALAAECgYIBwAAAA==.血色神圣:BAAALAAECgYIBgAAAA==.',['裴柒']='裴柒柒丶:BAAALAAECggICQAAAA==.',['西西']='西西不嘻嘻:BAAALAAECgYIDAAAAA==.',['译雷']='译雷:BAABLAAFFH8GAAIDAAIIbxkdlABDAAADAAIIbxkdlABDAAAAAA==.',['谢沧']='谢沧行:BAACLAAFFH8SAAIHAAMIuxiNNQCcAAAHAAMIuxiNNQCcAAAsAAQKfxgAAgcABwiLG5tKABECAAcABwiLG5tKABECAAAA.',['贝多']='贝多芬:BAAALAAECggIDgAAAA==.',['超级']='超级大福:BAAALAADCgIIAgAAAA==.',['趴趴']='趴趴老崔:BAABLAAFFH8FAAIKAAMIaAkpOACKAAAKAAMIaAkpOACKAAAAAA==.',['跛豪']='跛豪:BAAALAADCgIIAgAAAA==.',['踏雪']='踏雪飘痕:BAAALAADCgQIBAAAAA==.',['蹦迪']='蹦迪治大病:BAAALAAECgYIDQAAAA==.',['辛十']='辛十四娘:BAAALAAECgUIBQAAAA==.',['辰辰']='辰辰奶爸:BAAALAAECgIIAgAAAA==.',['边城']='边城浪子:BAAALAAECgYIBgAAAA==.',['迈豆']='迈豆:BAAALAADCggICAAAAA==.',['连锁']='连锁闪电:BAAALAAECgIIAgAAAA==.',['追逐']='追逐白月光:BAAALAAFFAIIAgAAAA==.',['逍遥']='逍遥魔侠:BAABLAAECn8ZAAMTAAYIcRVjGQALAQATAAYICRNjGQALAQAOAAQIpQ8ndgCbAAAAAA==.',['逐静']='逐静丶:BAECLAAFFH8jAAIaAAYIMR0yEwDIAQAaAAYIMR0yEwDIAQAsAAQKfxoAAhoACAhNJU8EAO8CABoACAhNJU8EAO8CAAEsAAUUBggUAAMAlh0A.',['逸宸']='逸宸昊天:BAAALAAECgIIAgAAAA==.',['遁地']='遁地老崔:BAAALAAFFAQIBAABLAAFFAQIBQAKAGgJAA==.',['遗忘']='遗忘海角:BAABLAAFFH8IAAMbAAIIZxwOGwBKAAAbAAEIpR8OGwBKAAAcAAEIKhlDHABFAAAAAA==.遗忘角落:BAAALAAFFAIIAgAAAA==.',['那一']='那一点妖娆:BAABLAAFFH8GAAIWAAIISQlxBQBDAAAWAAIISQlxBQBDAAAAAA==.那一点忧伤:BAABLAAFFH8GAAMQAAIIYQSfHwAvAAAGAAII2QPfZwAxAAAQAAII8wOfHwAvAAAAAA==.那一点霸道:BAABLAAFFH8GAAIaAAIIxgeCYwA8AAAaAAIIxgeCYwA8AAAAAA==.',['邪恶']='邪恶地瓜:BAABLAAFFH8MAAIaAAIIYgc9XwA/AAAaAAIIYgc9XwA/AAAAAA==.',['部落']='部落猎殺者:BAABLAAFFH8SAAIDAAgIeiFHAwDGAgADAAgIeiFHAwDGAgAAAA==.部落的游民:BAABLAAFFH8IAAIPAAgIiBfQBgBQAgAPAAgIiBfQBgBQAgAAAA==.',['野百']='野百合的春天:BAAALAAECgYIEwAAAA==.',['钉子']='钉子戳小强:BAAALAAFFAIIAgAAAA==.',['铁板']='铁板钢筋:BAAALAAECgEIAQAAAA==.',['长空']='长空无迹:BAABLAAFFH8GAAIDAAIIOCUjfgBbAAADAAIIOCUjfgBbAAAAAA==.',['闪电']='闪电五连鞭:BAAALAAECgYIDgAAAA==.',['闪闪']='闪闪的闪:BAAALAAECggICAAAAA==.',['闪電']='闪電:BAAALAADCgQIBAAAAA==.',['阿一']='阿一西:BAAALAAECgUIBQAAAA==.',['难凉']='难凉热血:BAABLAAFFH8GAAINAAYI3BtECACfAQANAAYI3BtECACfAQAAAA==.',['零缺']='零缺点:BAAALAAECgMIBQAAAA==.',['雾中']='雾中遗忘:BAACLAAFFH8KAAQcAAIIeBpMGgBLAAAcAAIIeBpMGgBLAAAbAAEIYQtlHgA9AAAWAAEI6wERCAA6AAAsAAQKfxQABBwACAgzGzcYAPgAABwABwhHGzcYAPgAABYAAwh/FbcVANsAABsAAghHFFofAEYAAAAA.',['霜灬']='霜灬与魔镜:BAAALAADCgEIAQAAAA==.',['青岛']='青岛吴彦祖:BAAALAAECgYICgAAAA==.',['青花']='青花丶:BAEBLAAFFH8bAAMKAAYIWxdTFACWAQAKAAYIWxdTFACWAQAXAAIIAhc1LQBJAAABLAAFFAYIFAADAJYdAA==.',['靛蓝']='靛蓝色:BAAALAAECgYIBwAAAA==.',['非士']='非士无与虑国:BAABLAAFFH8JAAILAAQIYRTvLgD1AAALAAQIYRTvLgD1AAAAAA==.',['顾廷']='顾廷炜:BAAALAAECgYICQAAAA==.',['风中']='风中纸灰机:BAAALAAFFAIIAwAAAA==.',['风之']='风之逆襲:BAAALAAECggICAAAAA==.',['风清']='风清扬:BAABLAAECn8YAAMCAAYIWwz+HADoAAACAAYIWwz+HADoAAAVAAEIHwO7bwAoAAAAAA==.',['马尐']='马尐萌:BAAALAAFFAEIAQAAAA==.',['骑士']='骑士难搏万:BAAALAAECgYIEAAAAA==.',['骑着']='骑着牛私奔:BAAALAAFFAIIAgAAAA==.',['骑马']='骑马游街看戏:BAAALAADCgcIBwAAAA==.',['鬼瞳']='鬼瞳丨枫:BAAALAAECgYICwAAAA==.',['魂灬']='魂灬墨瞳:BAAALAAECgYIBgAAAA==.',['鸢一']='鸢一折纸:BAAALAADCgQIBgAAAA==.',['麒麟']='麒麟:BAAALAAFFAgIAQAAAA==.',['麥格']='麥格尼銅須:BAAALAADCgIIAgAAAA==.',['麦琳']='麦琳火力大:BAABLAAFFH8GAAIBAAYI9RHQMwBsAQABAAYI9RHQMwBsAQAAAA==.',['麦迪']='麦迪伦牤子:BAAALAAECgIIAwAAAA==.',['麦香']='麦香面包:BAAALAAFFAEIAQAAAA==.',['黑暗']='黑暗骑士:BAAALAAECgYIEgAAAA==.',['龙卷']='龙卷风:BAAALAADCgYIBgAAAA==.',['龙的']='龙的旋律:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end