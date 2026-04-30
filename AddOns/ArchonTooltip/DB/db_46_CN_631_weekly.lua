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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Mage-Frost','Priest-Holy','Unknown-Unknown','Paladin-Retribution','DemonHunter-Devourer','Priest-Shadow','DeathKnight-Unholy','Rogue-Subtlety','Paladin-Protection','Priest-Discipline','Druid-Feral','Druid-Guardian','Warrior-Fury','Paladin-Holy','Monk-Brewmaster','Warrior-Arms','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Demonology','Monk-Windwalker','Monk-Mistweaver','Rogue-Outlaw','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Rogue-Assassination',}
local provider = {region='CN',realm='大地之怒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Au='Aurorius:BAAALgAECgcJDAAAAA==.',
Ca='Carllic:BAABLgAFFH8FAAIBAAMJzQZhMQDpAAABAAMJzQZhMQDpAAABLgAFFAQJCAACAB4QAA==.',
Do='Domspace:BAAALgAECgEJAgAAAA==.Doname:BAAALgAECgUJBgAAAA==.',
Dr='Dramon:BAAALgADCgYJBgAAAA==.Drenched:BAAALgADCgQJBAAAAA==.',
Ds='Dsname:BAAALgADCgYJBgABLgAECgUJBgADAAAAAA==.',
Fa='Farmerbob:BAAALgAECgYJBgAAAA==.',
['Gò']='Gòdlikes:BAAALgAECgEJAgAAAA==.',
He='Helluin:BAABLgAFFH8IAAIBAAQJMCaOCgDKAQABAAQJMCaOCgDKAQAAAA==.',
Ja='Jaychen:BAACLgAFFH8IAAICAAQJHhCmBQApAQACAAQJHhCmBQApAQAuAAQKfxUAAgIABwkGG7kTAEECAAIABwkGG7kTAEECAAAA.',
Li='Linksp:BAAALgAECgEJAQAAAA==.',
Lo='Lonelycance:BAAALgAECgEJAQAAAA==.',
Ma='Macchiatoo:BAAALgAFFAEJAgAAAA==.Magus:BAABLgAFFH8OAAIBAAUJrhlEBQB3AQABAAUJrhlEBQB3AQAAAA==.',
Mo='Moonchild:BAAALgAECgYJCQAAAA==.',
Re='Redpaladin:BAABLgAFFH8FAAIEAAIJPhkSIQCrAAAEAAIJPhkSIQCrAAAAAA==.Reislin:BAAALgADCgUJBQAAAA==.',
Ry='Rylynn:BAAALgAECgQJBAAAAA==.',
Sc='Scrooged:BAAALgAECgQJBAAAAA==.',
Si='Simondemon:BAAALgAECgQJBQAAAA==.Simonmonk:BAAALgAECgIJAwAAAA==.Simonpally:BAAALgAECgQJBgAAAA==.Simonwarlock:BAAALgAECgIJAwAAAA==.',
Sl='Slaughtermen:BAAALgAECgcJBwAAAA==.',
Sp='Spacex:BAAALgADCgYJCgAAAA==.',
Ti='Tifa:BAAALgADCgQJBAAAAA==.',
Ub='Ubear:BAAALgAECgMJBAAAAA==.',
Va='Vavan:BAAALgAECgEJAQABLgAFFAUJBQAFAN8aAA==.',
Yi='Yilidan:BAAALgAECgEJAQAAAA==.',
Zo='Zolpidem:BAAALgAFFAIJBAAAAA==.',
['一只']='一只小奶牛:BAAALgAFFAEJAQAAAA==.',
['三鹿']='三鹿老總:BAAALgAECggJCwABLgAFFAIJAwADAAAAAA==.',
['上白']='上白沢慧音:BAAALgADCgcJBwAAAA==.',
['下关']='下关码头:BAAALgAECgEJAgAAAA==.',
['不減']='不減的守衡:BAAALgAECgQJBwAAAA==.',
['不能']='不能忘却纪念:BAAALgADCgYJBgAAAA==.',
['且听']='且听風吟:BAAALgADCgcJCAAAAA==.',
['东京']='东京爱情故事:BAAALgAFFAIJAwAAAA==.',
['两只']='两只老绵杨:BAAALgAECgkJCQAAAA==.',
['丶亚']='丶亚托克斯丶:BAAALgAECgYJCgAAAA==.',
['丶北']='丶北归:BAAALgAECgMJAwAAAA==.',
['丶打']='丶打酱油丶:BAAALgAECgUJBQAAAA==.',
['丶蕾']='丶蕾娜丝丶:BAAALgAECggJDwAAAA==.',
['乌喜']='乌喜空:BAAALgADCggJCAAAAA==.',
['乌喵']='乌喵喵王:BAAALgAECgIJBAAAAA==.',
['九岚']='九岚丶:BAAALgAECgEJAQAAAA==.',
['五指']='五指拳心剑:BAAALgADCgkJCQAAAA==.',
['仙女']='仙女:BAAALgAECgEJAQAAAA==.',
['伊俐']='伊俐丹丶魅影:BAAALgAECgcJEQAAAA==.',
['优势']='优势宰我:BAAALgAECgcJDAAAAA==.',
['伤殇']='伤殇:BAAALgAECgYJCQAAAA==.',
['低调']='低调的小白:BAACLgAFFH8FAAIGAAMJ4BSrCgAJAQAGAAMJ4BSrCgAJAQAuAAQKfxkAAgYACAk6H+YHAAcDAAYACAk6H+YHAAcDAAAA.',
['你看']='你看看人家丶:BAAALgAECgcJAwAAAA==.',
['修修']='修修大卡车:BAAALgAECgYJBgAAAA==.',
['允许']='允许一切牛走:BAAALgADCgEJAQAAAA==.',
['克鲁']='克鲁索尔刃拳:BAABLgAFFH8HAAIHAAIJRCNpQgCdAAAHAAIJRCNpQgCdAAAAAA==.',
['冰点']='冰点酷儿:BAACLgAFFH8HAAIIAAMJUR3ACwAoAQAIAAMJUR3ACwAoAQAuAAQKfxoAAggACAnzHlMLAOACAAgACAnzHlMLAOACAAAA.',
['冷锋']='冷锋:BAAALgADCgEJAQAAAA==.',
['凝莫']='凝莫:BAAALgAECgIJBAAAAA==.',
['凯凯']='凯凯丶:BAAALgAECgQJCQAAAA==.',
['功夫']='功夫:BAAALgAECgEJAQAAAA==.',
['动感']='动感蜗牛:BAAALgADCgIJAgAAAA==.',
['动物']='动物变形记:BAAALgADCgEJAQAAAA==.',
['劳资']='劳资又没蓝了:BAABLgAFFH8FAAIJAAIJNhcvBACWAAAJAAIJNhcvBACWAAAAAA==.劳资蜀道山:BAAALgAECgEJAQAAAA==.',
['包疲']='包疲垢:BAAALgAFFAIJAgAAAA==.',
['北极']='北极:BAAALgAFFAIJAwAAAA==.',
['午后']='午后的喵小乌:BAAALgAECgQJBwAAAA==.',
['南风']='南风如故丶:BAAALgAECggJEAAAAA==.',
['历历']='历历万乡:BAAALgADCgEJAQAAAA==.',
['叔叔']='叔叔帮你回春:BAAALgAECgUJBQAAAA==.叔叔软呼呼:BAAALgAECgIJAgAAAA==.',
['变态']='变态佬:BAAALgAECgEJAQAAAA==.',
['古尔']='古尔丹丶:BAAALgAECgUJBQAAAA==.',
['史莱']='史莱姆丶丶:BAAALgAECgUJBQAAAA==.',
['右手']='右手拿刀:BAAALgAFFAEJAQAAAA==.',
['听讲']='听讲你叫我:BAABLgAFFH8HAAIEAAIJCB0hGwDGAAAEAAIJCB0hGwDGAAAAAA==.',
['听雨']='听雨漫步:BAAALgAECgEJAQAAAA==.',
['呆萌']='呆萌丶古尔愧:BAAALgAECgcJBwAAAA==.',
['哈廖']='哈廖尔雷蹄:BAAALgAECgEJAQAAAA==.',
['哎呦']='哎呦不错:BAAALgAFFAEJAQAAAA==.',
['唰丶']='唰丶妖気丶:BAACLgAFFH8IAAIBAAQJxhIdHwBNAQABAAQJxhIdHwBNAQAuAAQKfyYAAgEACQleJRMDAM4DAAEACQleJRMDAM4DAAAA.',
['唱歌']='唱歌的女侠:BAAALgAECgUJBgAAAA==.',
['唱诗']='唱诗:BAAALgAECgYJCwAAAA==.',
['啊水']='啊水:BAAALgAECgYJDAAAAA==.',
['喂呜']='喂呜喂呜:BAACLgAFFH8FAAMCAAMJZBD0BwDqAAACAAMJZBD0BwDqAAAKAAEJ7wAPDQA0AAAuAAQKfxoAAwIACAlcGwgRAFsCAAIACAlcGwgRAFsCAAYAAQm5BPNmACsAAAAA.',
['嗖丶']='嗖丶妖気:BAAALgAECgYJDAAAAA==.',
['嗷灬']='嗷灬:BAAALgAECgIJAgAAAA==.',
['嚒嚒']='嚒嚒牛:BAABLgAECn8WAAMLAAgJQhABDAD8AQALAAgJQhABDAD8AQAMAAIJ4wNrMQAwAAAAAA==.',
['嚣张']='嚣张的很:BAAALgAECgcJBQAAAA==.',
['团灭']='团灭小旗手:BAAALgAECgEJAQAAAA==.',
['图腾']='图腾肥牛:BAAALgAECggJDQAAAA==.',
['圣光']='圣光落樱:BAAALgAECgEJAQAAAA==.',
['圣婴']='圣婴厄尔尼诺:BAAALgAECgQJBgAAAA==.',
['堕落']='堕落竞技场:BAAALgAECgcJBgAAAA==.',
['塞班']='塞班:BAAALgAECgcJCAAAAA==.',
['大吧']='大吧唧:BAAALgAECgQJBwAAAA==.',
['大巴']='大巴肌:BAABLgAFFH8GAAINAAMJ9hgOBgACAQANAAMJ9hgOBgACAQAAAA==.',
['大門']='大門五郎:BAAALgADCgEJAQAAAA==.',
['天天']='天天使:BAACLgAFFH8GAAIBAAMJdRwPJAAmAQABAAMJdRwPJAAmAQAuAAQKfxoAAgEACAnMI08QAEYDAAEACAnMI08QAEYDAAAA.',
['天赐']='天赐良鸡:BAAALgAECgEJAwAAAA==.',
['太阳']='太阳之子:BAAALgAECgEJAQAAAA==.',
['奶茶']='奶茶君:BAAALgAECgYJDAAAAA==.',
['好牛']='好牛:BAAALgAECggJEwAAAA==.',
['如此']='如此妖娆:BAAALgAECgUJBQAAAA==.',
['安若']='安若丶浮生:BAAALgAECgkJAQAAAA==.',
['將夜']='將夜:BAAALgAFFAEJAQABLgAFFAYJCwABAL0cAA==.',
['小啵']='小啵啵叽:BAAALgAECgMJAwAAAA==.',
['小奶']='小奶萨:BAAALgAECgIJAwAAAA==.',
['小小']='小小鬼:BAABLgAECn8YAAMGAAgJVhjkFABGAgAGAAgJVhjkFABGAgACAAIJKwXgdQBSAAAAAA==.',
['小排']='小排球:BAAALgAECgYJDwAAAA==.',
['小新']='小新没蜡笔:BAABLgAECn8WAAIOAAkJqQsdOQCWAQAOAAkJqQsdOQCWAQAAAA==.',
['小星']='小星星:BAAALgAECgcJBwAAAA==.',
['小林']='小林家的托尔:BAAALgAECgkJCQAAAA==.',
['小炮']='小炮:BAAALgAECgEJAQAAAA==.',
['小狄']='小狄包包:BAAALgAECgIJAgAAAA==.',
['小苏']='小苏苏:BAAALgAECgYJDQAAAA==.',
['小鑫']='小鑫鑫有梦想:BAAALgADCgYJBgAAAA==.',
['尘大']='尘大师:BAAALgAECgcJCwAAAA==.',
['山有']='山有牧:BAAALgADCgQJBAAAAA==.',
['巨龙']='巨龙黎明:BAAALgAECgQJBAABLgAECgkJBQADAAAAAA==.',
['巴别']='巴别塔饿灵:BAAALgAECgEJAgAAAA==.',
['师兄']='师兄归来:BAAALgAECgEJAQAAAA==.',
['帕拉']='帕拉梅拉煤:BAAALgADCgIJAgAAAA==.',
['幺鸡']='幺鸡:BAACLgAFFH8FAAIPAAQJ8RnxCABFAQAPAAQJ8RnxCABFAQAuAAQKfxgAAg8ACAl6IioHABIDAA8ACAl6IioHABIDAAAA.',
['库特']='库特莉亚芙卡:BAABLgAFFH8NAAMQAAYJFhZnAAAEAgAQAAYJFhZnAAAEAgANAAEJAADxHgBYAAAAAA==.',
['应地']='应地无疆:BAAALgAECgcJCgAAAA==.',
['建南']='建南春春:BAAALgAECgcJCAAAAA==.',
['弃世']='弃世裁决:BAAALgAECgIJAgAAAA==.',
['彩虹']='彩虹马:BAAALgADCgIJAgAAAA==.',
['影丢']='影丢丢:BAABLgAECn8gAAMRAAgJrxvXIgANAgARAAcJARnXIgANAgASAAYJ0h8qGAA6AQAAAA==.',
['快乐']='快乐的小鑫鑫:BAAALgAECgEJAQAAAA==.',
['怪兽']='怪兽哪里跑:BAAALgAECgYJBgAAAA==.',
['怿怿']='怿怿酥术:BAAALgAFFAEJAQAAAA==.',
['恶堕']='恶堕不如善堕:BAAALgAECgYJBwAAAA==.',
['惊异']='惊异天蜜娜:BAAALgAECgEJAQAAAA==.惊异巴斯塔:BAAALgAECgYJDAAAAA==.',
['憨憨']='憨憨小魔:BAAALgAECggJDgAAAA==.憨憨小龙:BAAALgAECgYJDQABLgAECggJDgADAAAAAA==.',
['我想']='我想抓个熊:BAABLgAECn8XAAMSAAcJ4xTqKwAEAgASAAcJ4xTqKwAEAgARAAIJRgfsfABRAAAAAA==.',
['我是']='我是萌德:BAAALgAECgkJEgAAAA==.',
['我脆']='我脆:BAAALgAECgYJCgAAAA==.',
['战神']='战神啤酒:BAACLgAFFH8GAAINAAQJyhH1CgBNAQANAAQJyhH1CgBNAQAuAAQKfxYAAg0ACAnPHasQAMwCAA0ACAnPHasQAMwCAAAA.',
['所念']='所念皆如愿:BAAALgAECgYJBgAAAA==.',
['所蓝']='所蓝:BAACLgAFFH8PAAICAAQJoRmFAwBZAQACAAQJoRmFAwBZAQAuAAQKfxkAAwIACAnDEw4bAAQCAAIACAnDEw4bAAQCAAoAAQleAV5fACAAAAAA.',
['托柒']='托柒唔识转驳:BAABLgAFFH8MAAITAAQJbiIXAwCBAQATAAQJbiIXAwCBAQAAAA==.',
['批鸨']='批鸨鸨:BAABLgAECn8jAAICAAgJDiFFBQD8AgACAAgJDiFFBQD8AgAAAA==.',
['挺胸']='挺胸左放胯:BAAALgAFFAMJBAAAAA==.',
['排骨']='排骨炖萝卜:BAAALgAECgEJBAAAAA==.',
['援护']='援护闪了腰:BAAALgAECgEJAQAAAA==.',
['早上']='早上坏:BAABLgAECn8dAAMUAAgJ0hKGIQDKAQAUAAcJ+xSGIQDKAQAVAAgJOwihLwBAAQAAAA==.',
['时光']='时光会骗人:BAAALgAECgYJCQAAAA==.',
['昭明']='昭明灵觉处:BAAALgAECgcJBgAAAA==.',
['是你']='是你的白牛:BAAALgAECgcJAQAAAA==.',
['晓蘇']='晓蘇:BAAALgAECgUJCQAAAA==.',
['暗夜']='暗夜之萌德:BAAALgAECgIJAgAAAA==.',
['暗幕']='暗幕:BAAALgAECgcJBwAAAA==.',
['暴力']='暴力树枝:BAAALgAECgEJAQAAAA==.',
['暴风']='暴风劣酒:BAAALgADCgIJAgABLgAECgEJAQADAAAAAA==.',
['月光']='月光傳說:BAAALgAECgEJAgAAAA==.',
['月色']='月色黎明:BAAALgAFFAIJAgAAAA==.',
['月落']='月落风萦:BAABLgAECn8UAAMNAAcJ3RRANwDKAQANAAcJ3RRANwDKAQAQAAIJkg42MQBvAAAAAA==.',
['有医']='有医保的先上:BAAALgAECgQJBQAAAA==.',
['李呀']='李呀李嘉图:BAAALgAECgMJBAAAAA==.',
['来期']='来期:BAABLgAECn8aAAIBAAgJmgyxJAA9AQABAAgJmgyxJAA9AQAAAA==.',
['柚子']='柚子与猫丶:BAAALgAECgYJBgAAAA==.',
['柠檬']='柠檬味口香糖:BAAALgAECgIJAgAAAA==.',
['梅尔']='梅尔加斯:BAAALgAECgEJAgAAAA==.',
['梅是']='梅是远山黛:BAAALgAECgcJBwAAAA==.',
['欧皇']='欧皇骑士:BAAALgAFFAEJAQAAAA==.',
['步川']='步川帝库:BAACLgAFFH8FAAIHAAMJcBJ9KAD2AAAHAAMJcBJ9KAD2AAAuAAQKfxcAAgcACAnAHm8oAJkCAAcACAnAHm8oAJkCAAAA.',
['江南']='江南壹朵花:BAAALgAECgkJCQAAAA==.',
['池寒']='池寒枫:BAAALgAECgQJBAAAAA==.',
['沐春']='沐春风:BAAALgADCgEJAQAAAA==.',
['没有']='没有游戏玩:BAAALgAECgEJAgABLgAFFAQJCAACAB4QAA==.',
['油豆']='油豆腐:BAAALgADCgUJBQAAAA==.',
['法爷']='法爷:BAABLgAFFH8GAAIOAAIJ3g4SFgCSAAAOAAIJ3g4SFgCSAAABLgAFFAQJCAACAB4QAA==.',
['泥头']='泥头车创创子:BAAALgAECgMJBgAAAA==.',
['泰瑞']='泰瑞纳斯:BAACLgAFFH8HAAIEAAMJ7CJRDgA4AQAEAAMJ7CJRDgA4AQAuAAQKfx0AAgQABwnEIycVAOsCAAQABwnEIycVAOsCAAEuAAUUBAkNABYA6hkA.',
['洛玉']='洛玉衡:BAAALgAECgcJAQABLgAFFAYJAgADAAAAAA==.',
['洛神']='洛神打灰机:BAAALgAECgYJDwAAAA==.',
['浪哩']='浪哩个浪:BAAALgAECgUJBQAAAA==.',
['淡淡']='淡淡的清风:BAAALgAECgQJBAAAAA==.',
['深海']='深海海绵怪:BAAALgAECgEJAgAAAA==.',
['混沌']='混沌野狼:BAAALgAFFAEJAQAAAA==.',
['清风']='清风欲南栀:BAABLgAFFH8IAAIXAAQJfgLhBQD5AAAXAAQJfgLhBQD5AAAAAA==.',
['游学']='游学者七味:BAAALgADCgYJBgABLgADCgYJBgADAAAAAA==.',
['滚滚']='滚滚大做饭:BAAALgADCgEJAQAAAA==.',
['灞气']='灞气厕漏:BAAALgADCgIJAgAAAA==.',
['火因']='火因木仓:BAACLgAFFH8JAAIBAAMJnhgSKgAMAQABAAMJnhgSKgAMAQAuAAQKfxwAAgEACAncHGs0AKECAAEACAncHGs0AKECAAAA.',
['火旺']='火旺:BAAALgAECgcJCgAAAA==.',
['烈日']='烈日行者:BAAALgAECgIJAgAAAA==.',
['烦恼']='烦恼丶游戏:BAAALgAECgUJBwAAAA==.',
['爱咋']='爱咋咋的:BAAALgAECgMJBAAAAA==.',
['牛牛']='牛牛猛拉大电:BAABLgAFFH8LAAIYAAQJlRTICQBEAQAYAAQJlRTICQBEAQAAAA==.',
['犬貓']='犬貓店長丶:BAABLgAFFH8IAAIGAAMJuRFKBgDUAAAGAAMJuRFKBgDUAAAAAA==.',
['独看']='独看夕阳丶:BAAALgAECgEJAQAAAA==.',
['猎意']='猎意:BAAALgAECgQJBAAAAA==.',
['猎空']='猎空空:BAAALgAECgQJBAAAAA==.',
['猪零']='猪零:BAAALgAECgcJCwAAAA==.',
['猫猫']='猫猫女侠:BAAALgAECgEJAQAAAA==.',
['玛尔']='玛尔迦的祝福:BAAALgADCgYJBgAAAA==.',
['玛里']='玛里奥特:BAAALgAFFAIJBAAAAA==.',
['玩宫']='玩宫射大鸟:BAAALgAECgEJAgAAAA==.',
['理发']='理发师:BAAALgADCgIJAgAAAA==.',
['甜之']='甜之源儿:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂小书生:BAAALgAECgYJCAABLgAFFAQJBAADAAAAAA==.',
['疾风']='疾风大魔王:BAAALgAECgIJBQAAAA==.',
['白日']='白日依衫尽:BAAALgAECgUJDwAAAA==.',
['百万']='百万伏特:BAAALgAECgIJAgABLgAECgUJCQADAAAAAA==.',
['盼盼']='盼盼:BAAALgADCgIJAgAAAA==.',
['祖传']='祖传老军医:BAAALgADCgIJAgAAAA==.',
['祖国']='祖国老花朵:BAAALgAECgQJAwAAAA==.',
['神佑']='神佑圣光:BAAALgAECgEJAQAAAA==.',
['离晒']='离晒大谱:BAABLgAFFH8HAAIYAAIJySSXBwDfAAAYAAIJySSXBwDfAAAAAA==.',
['积积']='积积养养德:BAABLgAFFH8GAAILAAQJUQy8AgAHAQALAAQJUQy8AgAHAQAAAA==.',
['程小']='程小斯:BAAALgAECgcJDwAAAA==.',
['紫郢']='紫郢:BAAALgAECgQJBwABLgAECgUJCQADAAAAAA==.',
['紫龙']='紫龙:BAAALgADCgQJBAAAAA==.',
['維叁']='維叁:BAABLgAFFH8HAAITAAYJEhw7DwBlAQATAAYJEhw7DwBlAQAAAA==.',
['維壹']='維壹:BAABLgAFFH8LAAITAAYJ7hecBwCsAQATAAYJ7hecBwCsAQAAAA==.',
['維肆']='維肆:BAAALgAFFAQJBAAAAA==.',
['維貳']='維貳:BAABLgAFFH8IAAITAAQJqRhMEQBZAQATAAQJqRhMEQBZAQAAAA==.',
['缘来']='缘来梦醒:BAAALgAECgYJBgABLgAECgkJBQADAAAAAA==.',
['缺爱']='缺爱不缺钙:BAAALgAECgEJAQAAAA==.',
['罪夜']='罪夜听刀:BAAALgAECggJCwAAAA==.',
['职业']='职业劣人:BAAALgADCgEJAQAAAA==.',
['自成']='自成风月丶:BAAALgAFFAEJAwAAAA==.',
['臭弟']='臭弟波比:BAAALgAECgkJCQAAAA==.',
['至尊']='至尊天神棍:BAAALgAECgcJBwAAAA==.',
['芝士']='芝士奶糖:BAAALgAFFAEJAgAAAA==.',
['花生']='花生殼殼:BAABLgAFFH8BAAITAAEJYhPQSABTAAATAAEJYRPQSABTAAAAAA==.',
['草莓']='草莓圣代:BAAALgAECgQJBgAAAA==.',
['萌果']='萌果牛:BAAALgAECgEJAQAAAA==.',
['萌物']='萌物君萌萌哒:BAAALgAECgUJBwAAAA==.',
['萌萌']='萌萌猛牛:BAAALgAECgEJAQAAAA==.',
['萝卜']='萝卜叔叔:BAAALgAECgYJCwAAAA==.',
['萨拉']='萨拉撒斯莱特:BAAALgAECgYJBgAAAA==.',
['萨鲁']='萨鲁加尔雷霆:BAAALgAFFAIJAgAAAA==.',
['虾子']='虾子:BAAALgAECgUJCQAAAA==.虾子儿:BAAALgAECgMJAwAAAA==.',
['蟲兒']='蟲兒飛:BAAALgAECgEJAQAAAA==.',
['行旅']='行旅离落:BAAALgAECggJCQAAAA==.',
['请叫']='请叫我牛萌萌:BAAALgAECgIJAgAAAA==.',
['路西']='路西法咻:BAAALgADCgUJBQAAAA==.路西法牛牛:BAAALgAECgEJAQAAAA==.',
['路飛']='路飛:BAACLgAFFH8JAAIBAAMJKBhGOwC0AAABAAMJKBhGOwC0AAAuAAQKfx8AAgEABwnoIKIRALUBAAEABwnoIKIRALUBAAAA.',
['蹄子']='蹄子姐说:BAABLgAFFH8KAAIZAAMJDiQyCQA8AQAZAAMJDiQyCQA8AQAAAA==.',
['辣记']='辣记逆光:BAAALgAECgEJAQAAAA==.',
['达凌']='达凌:BAAALgADCgcJBwAAAA==.',
['过筱']='过筱筱:BAABLgAECn8fAAIFAAgJWBvLJgBqAgAFAAgJWBvLJgBqAgAAAA==.',
['这货']='这货不是真的:BAAALgAECgUJBgAAAA==.',
['迷城']='迷城:BAAALgAECgEJAQAAAA==.',
['逃离']='逃离:BAAALgAFFAQJAgABLgAFFAcJBwAVACIHAA==.',
['道德']='道德与法治:BAAALgAECgUJBQAAAA==.',
['那什']='那什么什么了:BAACLgAFFH8UAAMRAAYJvB3XAgAnAgARAAYJvB3XAgAnAgASAAMJKxnHBwAIAQAuAAQKfyIAAxEACQnzIVUHACUDABEACQnzIVUHACUDABIAAgmpFy02AGYAAAAA.',
['里丶']='里丶贝留斯:BAAALgAECgYJBgAAAA==.',
['野猪']='野猪乔治:BAAALgAECgEJAQAAAA==.',
['銀色']='銀色的永生:BAACLgAFFH8NAAMWAAQJ6hlCAABwAQAWAAQJ6hlCAABwAQAIAAEJtAKfGwBPAAAuAAQKfxYABBYACQkeITUAAJIDABYACQkeITUAAJIDAAgAAQlvIYRYAGQAABoAAQm3AXciACEAAAAA.',
['铠牙']='铠牙猪:BAAALgAECgcJDwAAAA==.',
['银月']='银月露娜:BAABLgAFFH8FAAIOAAIJHR39EgCvAAAOAAIJHR39EgCvAAAAAA==.',
['闪电']='闪电小南:BAAALgAECgMJAwAAAA==.',
['阿姆']='阿姆捏:BAAALgAECgEJAQAAAA==.',
['阿布']='阿布兜:BAAALgAECgEJAQAAAA==.',
['阿排']='阿排:BAAALgAECgUJBQABLgAECggJIwACAA4hAA==.',
['阿松']='阿松大为:BAAALgAECgkJAQAAAA==.',
['青青']='青青子矜:BAAALgAECgYJBgAAAA==.',
['风声']='风声鹤唳:BAAALgAECgkJBQAAAA==.',
['风暴']='风暴元素:BAAALgAECgEJAQAAAA==.',
['飞翔']='飞翔的西瓜:BAAALgAECgEJAQAAAA==.',
['验牌']='验牌:BAAALgADCgUJBQAAAA==.',
['骑牛']='骑牛去兜风:BAAALgAECgcJEAAAAA==.',
['鬼灭']='鬼灭大魔王:BAAALgAECgEJAQAAAA==.',
['魇灬']='魇灬:BAAALgAECgMJAwAAAA==.',
['鲜肉']='鲜肉大包:BAAALgAECgYJBwAAAA==.',
['麻婆']='麻婆豆腐拉面:BAAALgAECgIJAgAAAA==.',
['黎明']='黎明破晓前:BAAALgADCgcJDwAAAA==.',
['黑毛']='黑毛牛:BAAALgAECgkJDAAAAA==.',
['龍先']='龍先生:BAAALgAECgEJAgAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
