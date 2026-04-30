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

local lookup = {'Mage-Frost','DemonHunter-Havoc','DemonHunter-Devourer','DeathKnight-Unholy','Monk-Mistweaver','Druid-Guardian','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Shaman-Restoration','Monk-Brewmaster','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Priest-Shadow','Monk-Windwalker','Evoker-Devastation','Paladin-Retribution','Shaman-Elemental','Priest-Holy','Evoker-Augmentation','Evoker-Preservation','Mage-Arcane','Mage-Fire','Warrior-Arms','Warrior-Fury','Druid-Balance','Unknown-Unknown','Druid-Restoration','Druid-Feral','Rogue-Subtlety','Warrior-Protection','Shaman-Enhancement',}
local provider = {region='CN',realm='斯克提斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agodofwar:BAAALgAECgcJEgAAAA==.',
Am='Amonetard:BAAALgAECgUJCQABLgAFFAQJCQABADoJAA==.',
Ba='Babaloveu:BAAALgADCgMJAwAAAA==.',
Be='Bellatrix:BAAALgAECgIJAgAAAA==.',
By='Byz:BAAALgAECgQJBAAAAA==.',
Cl='Clio:BAAALgADCgYJBgAAAA==.',
Cr='Cris:BAACLgAFFH8QAAICAAUJ5B69AADJAQACAAUJ5B69AADJAQAuAAQKfxwAAwIACQnVIAkGAAkDAAIACQnVIAkGAAkDAAMAAgm9BJ9kAC8AAAAA.',
Da='Dabizhuaizhu:BAAALgADCgEJAQAAAA==.Darkrepulser:BAAALgAECgYJCAAAAA==.',
De='Death:BAAALgAECgQJBAAAAA==.Deatheffect:BAAALgADCgUJBgAAAA==.Deisenhowe:BAAALgAECgEJAQAAAA==.',
Dr='Drakedoger:BAAALgADCgYJBgAAAA==.',
Ei='Eindhoven:BAAALgAECgQJBAAAAA==.',
El='Elly:BAAALgAECgYJBgAAAA==.',
Fa='Faithyangsun:BAAALgAECgYJBgAAAA==.Fanke:BAAALgAECgEJAQAAAA==.Fayndevourer:BAABLgAFFH8MAAIDAAQJpBRNCQA2AQADAAQJpBRNCQA2AQAAAA==.',
Fr='Framly:BAABLgAFFH8IAAIEAAIJkBtCIAChAAAEAAIJkBtCIAChAAAAAA==.',
Gu='Guuyuu:BAAALgAECgcJBwAAAA==.Guuyuudk:BAABLgAECn8XAAIEAAkJ0xjgBABeAgAEAAkJ0xjgBABeAgAAAA==.Guuyuuec:BAAALgAECgcJDgAAAA==.',
Hi='Hisdid:BAAALgADCgEJAQAAAA==.',
Ho='Hotmilk:BAAALgADCgMJAwAAAA==.Hotwater:BAAALgAECgEJAQAAAA==.',
Ix='Ixiaomantou:BAAALgAECgEJAQAAAA==.',
Jv='Jvxz:BAAALgAECgYJDQAAAA==.',
La='Lamorte:BAAALgAECgYJEAAAAA==.Laozhou:BAAALgAFFAQJAQAAAA==.',
Li='Lightbringe:BAAALgAECgQJAgAAAA==.',
Ma='Magnusz:BAAALgAECgYJBgAAAA==.Mandysweet:BAAALgADCgMJAwAAAA==.',
Mi='Miracles:BAAALgADCgEJAQAAAA==.',
Na='Nartex:BAAALgAFFAIJAgAAAA==.',
Od='Odin:BAAALgAECgkJCQAAAA==.',
Pe='Perfectpitch:BAAALgAECgYJBwAAAA==.',
Pl='Playerkpaoip:BAAALgAECgEJAQAAAA==.',
Re='Relx:BAAALgAECgYJCgAAAA==.',
Sa='Sagitarm:BAAALgAECgUJBQAAAA==.',
Sh='Shuriick:BAAALgAECgYJCwAAAA==.',
Sk='Skylines:BAAALgAECgUJCAAAAA==.',
Tw='Twelve:BAACLgAFFH8JAAIFAAQJOCYpAwDJAQAFAAQJOCYpAwDJAQAuAAQKfywAAgUACAnbJk0BAJUDAAUACAnbJk0BAJUDAAAA.Twelved:BAAALgAFFAIJAgAAAA==.',
Un='Un:BAAALgAECgIJAgAAAA==.Unstoppable:BAABLgAFFH8KAAIGAAMJsx8VAgAaAQAGAAMJsx8VAgAaAQAAAA==.',
Za='Zaphkiel:BAAALgAFFAEJAgAAAA==.',
Zz='Zzrgg:BAAALgAECgkJBwAAAA==.',
['一抹']='一抹丶夕阳:BAAALgAECgMJAwAAAA==.一抹丶清晨:BAAALgAECgEJAQAAAA==.',
['一梦']='一梦醒一:BAAALgAECgQJBAAAAA==.',
['一箭']='一箭穿俩:BAACLgAFFH8JAAMHAAQJZBGTEAArAQAHAAQJ3AyTEAArAQAIAAEJbhaJIABfAAAuAAQKfywABAkACAnQIBUBAIACAAcACAliHqwQALQCAAkACAkuHRUBAIACAAgAAQl5Jc+qAG8AAAAA.',
['一起']='一起学喵叫:BAAALgAECgYJBgAAAA==.',
['丄蟕']='丄蟕唇:BAAALgADCgQJBAAAAA==.',
['三坑']='三坑不二:BAACLgAFFH8VAAIBAAUJVhGFDQCvAQABAAUJVhGFDQCvAQAuAAQKfyUAAgEACAnAIDI2AJsCAAEACAnAIDI2AJsCAAAA.',
['三等']='三等待:BAAALgAFFAQJBAAAAA==.',
['三鳮']='三鳮:BAAALgAECgEJAQAAAA==.',
['不知']='不知道什么法:BAACLgAFFH8JAAIBAAQJOgkZIABGAQABAAQJOgkZIABGAQAuAAQKfyYAAgEACAkUHXMQAOEBAAEACAkUHXMQAOEBAAAA.',
['不要']='不要滴那里:BAAALgADCgcJBwAAAA==.',
['不觉']='不觉:BAAALgAECgYJCgAAAA==.',
['专打']='专打老司机:BAAALgADCgEJAQAAAA==.',
['严重']='严重肾亏:BAAALgADCgcJBwAAAA==.',
['丧化']='丧化萝莉:BAAALgADCgYJCAAAAA==.',
['丨宇']='丨宇宙法丨:BAABLgAECn8YAAIBAAgJxiUaCgBzAwABAAgJxiUaCgBzAwAAAA==.',
['丨宛']='丨宛若游龙丨:BAABLgAFFH8KAAIKAAUJaxHTAwCXAQAKAAUJaxHTAwCXAQAAAA==.',
['丨翩']='丨翩若惊鸿丨:BAABLgAFFH8LAAIKAAcJew1hAAD+AQAKAAcJew1hAAD+AQAAAA==.',
['中板']='中板牙之怒:BAAALgADCgUJBQAAAA==.',
['丶一']='丶一月:BAAALgAECgkJCQAAAA==.',
['丶帝']='丶帝灬:BAAALgADCgMJAwAAAA==.',
['丶弗']='丶弗拉迪米尔:BAAALgAFFAEJAgAAAA==.',
['丶断']='丶断开连接:BAAALgAECgIJBAAAAA==.',
['丶月']='丶月夜:BAAALgAECgIJAgAAAA==.',
['丶猫']='丶猫僧:BAAALgADCgEJAQAAAA==.',
['丶空']='丶空山鸟语:BAAALgADCgUJBQAAAA==.',
['丶蕾']='丶蕾塞:BAABLgAFFH8JAAILAAQJtiALBQCEAQALAAQJtiALBQCEAQAAAA==.',
['丶谷']='丶谷雨灬:BAAALgAECgcJBgAAAA==.',
['丸辣']='丸辣:BAAALgAECgYJDAAAAA==.',
['主灬']='主灬旋律:BAABLgAECn8UAAIKAAcJlhvfHgAmAgAKAAcJlhvfHgAmAgAAAA==.',
['丿挑']='丿挑剔丶姐:BAAALgAECgEJAQAAAA==.',
['乀柠']='乀柠檬乀:BAAALgAECgMJAQAAAA==.',
['乂小']='乂小黑:BAAALgAECgUJBQAAAA==.',
['乐事']='乐事青柠味:BAAALgAFFAIJAwAAAA==.',
['乖妹']='乖妹妹:BAAALgAFFAEJAQAAAA==.',
['九九']='九九林:BAAALgAFFAIJBAAAAA==.',
['二等']='二等待:BAAALgAFFAQJBAAAAA==.',
['亚瑟']='亚瑟的圣光:BAAALgAECgcJBwAAAA==.',
['人如']='人如风中絮:BAAALgAFFAIJAgAAAA==.人如风中絮丶:BAAALgADCgEJAQAAAA==.人如风丶中絮:BAACLgAFFH8JAAILAAQJhSN3AwCpAQALAAQJhSN3AwCpAQAuAAQKfyMAAgsACAn6JIwEAEMDAAsACAn6JIwEAEMDAAAA.',
['伊代']='伊代宗师:BAAALgAFFAIJAgAAAA==.',
['伊利']='伊利达雷丶杀:BAAALgAECgEJAQAAAA==.',
['伊莱']='伊莱克斯:BAAALgADCgEJAQAAAA==.',
['伍等']='伍等待:BAAALgAFFAMJAwAAAA==.',
['众神']='众神灬皓:BAAALgAECgUJBgAAAA==.',
['伟大']='伟大的鲁鲁修:BAAALgAECgEJAQAAAA==.',
['伽蓝']='伽蓝听雨:BAAALgAECggJEwAAAA==.',
['佐右']='佐右:BAAALgAECgYJDgAAAA==.',
['你微']='你微笑丶好美:BAAALgAECgYJDgAAAA==.你微笑时好逗:BAABLgAFFH8IAAMMAAMJnhpVHgAKAQAMAAMJHBpVHgAKAQANAAEJaxXlBQBbAAAAAA==.',
['來自']='來自星星的牛:BAAALgADCgUJCAAAAA==.',
['侍奉']='侍奉灬黑暗:BAAALgAECgYJDAAAAA==.',
['侣晓']='侣晓咘:BAAALgAECgEJAQAAAA==.',
['俏罗']='俏罗刹:BAAALgAECgEJAQAAAA==.',
['俞四']='俞四爷:BAAALgAECgcJBwAAAA==.',
['修电']='修电脑得过夜:BAAALgAECgkJCQABLgAFFAYJFQAOADIaAA==.',
['俺是']='俺是个大老粗:BAAALgAECgcJDQAAAA==.',
['做彼']='做彼此的宝搞:BAAALgAECgEJAQAAAA==.',
['做我']='做我的猫:BAAALgAECgQJBAAAAA==.',
['做牛']='做牛要有梦想:BAAALgAECgEJAQAAAA==.',
['先锋']='先锋剃刀改:BAABLgAFFH8JAAIOAAQJhBGWBwAVAQAOAAQJhBGWBwAVAQAAAA==.',
['八级']='八级大狂蜂:BAAALgADCgcJCwAAAA==.八级大狂风丶:BAAALgADCgYJBgAAAA==.',
['六圆']='六圆炸酱面:BAAALgAECgEJAQAAAA==.',
['六月']='六月听雪:BAAALgAECggJCAAAAA==.',
['兰亭']='兰亭序:BAAALgAECgYJCwAAAA==.',
['关胖']='关胖喵:BAABLgAFFH8JAAIPAAQJYhvjBACGAQAPAAQJYhvjBACGAQAAAA==.',
['关键']='关键词:BAACLgAFFH8HAAMQAAQJrRCXBQAsAQAQAAQJAgqXBQAsAQALAAEJSh9UIgBfAAAuAAQKfyoAAxAACAm5Hy0NAKgCABAACAm+HC0NAKgCAAsABgklHnQHAKgBAAAA.',
['军团']='军团之光:BAAALgAECgUJBQAAAA==.',
['冥神']='冥神之德:BAAALgAECgIJAgAAAA==.冥神之绊:BAAALgAECgMJAwAAAA==.',
['冰冰']='冰冰凉丶:BAACLgAFFH8IAAIEAAMJlRkJEQADAQAEAAMJlRkJEQADAQAuAAQKfxQAAgQABwkXHtE7AEgCAAQABwkXHtE7AEgCAAAA.',
['凉凉']='凉凉心亦凉情:BAAALgAECgEJAQAAAA==.',
['凉小']='凉小凄:BAAALgAECgQJBAAAAA==.凉小凄丶:BAAALgAECgEJAQAAAA==.',
['凉情']='凉情凉心:BAAALgAFFAIJAgAAAA==.',
['凯大']='凯大哥:BAAALgAECgQJBQAAAA==.',
['凱大']='凱大爺:BAAALgAECgQJBAAAAA==.',
['刃之']='刃之哀伤:BAAALgAECggJEAAAAA==.',
['创作']='创作小哥:BAAALgAECgMJBQAAAA==.',
['刮骨']='刮骨刀:BAAALgAECgYJBgAAAA==.',
['加利']='加利苏斯:BAAALgADCgEJAQAAAA==.',
['加加']='加加哈佛儿:BAAALgAECgYJCgAAAA==.',
['勿西']='勿西打白台:BAAALgAECgEJAQAAAA==.',
['北斗']='北斗七星拳:BAAALgAFFAEJAQAAAA==.',
['十三']='十三在赞达拉:BAAALgADCgUJBQAAAA==.',
['十年']='十年丨春秋:BAAALgAFFAIJBAAAAA==.',
['午夜']='午夜插画师丶:BAAALgAECgcJDgAAAA==.',
['卡格']='卡格瓦:BAAALgAECgMJAwAAAA==.',
['叁生']='叁生叁世丶:BAABLgAFFH8IAAIEAAQJlxxmDwBkAQAEAAQJlxxmDwBkAQAAAA==.',
['反派']='反派死于话多:BAAALgAECgYJDgAAAA==.',
['古二']='古二蛋:BAAALgADCgQJBAAAAA==.',
['古风']='古风歌:BAAALgAECgMJAwAAAA==.',
['只抽']='只抽黄鹤楼:BAAALgADCgEJAQAAAA==.',
['召唤']='召唤卡尔:BAAALgAECgYJDgAAAA==.',
['可可']='可可豆浆:BAABLgAFFH8GAAMHAAMJ+g0RIgCDAAAHAAIJlwIRIgCDAAAIAAIJABPxJgBTAAABLgAFFAUJCAARAAgZAA==.',
['可爱']='可爱术术:BAABLgAFFH8FAAIMAAMJYAywFQDtAAAMAAMJYAywFQDtAAAAAA==.',
['叶从']='叶从天上落下:BAAALgADCgYJBgAAAA==.',
['叶星']='叶星辰:BAAALgAECgEJAQAAAA==.',
['后起']='后起之秀:BAAALgAECgMJAwAAAA==.',
['吖頭']='吖頭丶:BAAALgADCgUJBQAAAA==.',
['君妹']='君妹:BAAALgAECgYJDAAAAA==.',
['吾皇']='吾皇:BAAALgAECgUJBwAAAA==.',
['周老']='周老師:BAAALgAFFAIJAgAAAA==.',
['周菲']='周菲戈:BAAALgAECgYJCwAAAA==.',
['命运']='命运的考研:BAAALgAECgIJAwAAAA==.',
['咒焰']='咒焰焚昔誓:BAAALgADCgMJAwAAAA==.',
['咕咕']='咕咕妹:BAAALgADCgQJBAAAAA==.',
['咬鹅']='咬鹅丶啊:BAAALgAFFAEJAQAAAA==.',
['咸饼']='咸饼干:BAAALgADCgEJAQAAAA==.',
['哈基']='哈基米呀丶:BAAALgADCgcJCAAAAA==.',
['哶言']='哶言:BAAALgAECgkJEgAAAA==.',
['唔控']='唔控:BAAALgAECgEJAQAAAA==.',
['唯懿']='唯懿嗳伱:BAAALgAECgQJBgAAAA==.',
['喝醉']='喝醉的潘达:BAAALgAECgYJBwAAAA==.',
['喵丶']='喵丶风暴烈酒:BAAALgAECgIJAgAAAA==.',
['噩梦']='噩梦:BAAALgAECgIJAgAAAA==.',
['嚣张']='嚣张太子:BAAALgAECgQJBwAAAA==.',
['回忆']='回忆丶冰封:BAAALgAECgUJBwAAAA==.',
['地狱']='地狱之衔:BAAALgAFFAIJAgAAAA==.',
['多氟']='多氟朗明哥:BAACLgAFFH8HAAISAAQJWgsPDgA6AQASAAQJWgsPDgA6AQAuAAQKfyEAAhIACAkdHugfAKwCABIACAkdHugfAKwCAAAA.',
['夜之']='夜之子丶:BAAALgAECgEJAQAAAA==.',
['夜夜']='夜夜新欢:BAAALgADCgYJBgAAAA==.',
['大咸']='大咸鱼德:BAAALgAECgEJAQAAAA==.',
['大哞']='大哞:BAAALgAECggJDwAAAA==.',
['大小']='大小大小:BAAALgAFFAIJAgAAAA==.',
['大灬']='大灬不丶点:BAAALgADCgMJAwAAAA==.',
['大瞎']='大瞎子:BAAALgAECgQJBwAAAA==.大瞎饶命:BAAALgAECgQJCQAAAA==.',
['大老']='大老猫:BAAALgADCgQJBAAAAA==.',
['天泣']='天泣圣神:BAAALgAFFAIJAgAAAA==.',
['天玑']='天玑:BAACLgAFFH8ZAAMKAAYJ1CFnAABDAgAKAAYJ1CFnAABDAgATAAUJXxtYAgBoAQAuAAQKfxcAAgoACQmuHYERAIsCAAoACQmuHYERAIsCAAAA.',
['天璇']='天璇:BAABLgAFFH8IAAMKAAQJ8xWACABCAQAKAAQJ8xWACABCAQATAAQJhgI0DwD7AAAAAA==.',
['天空']='天空蓝:BAAALgAECgEJAQAAAA==.',
['失忆']='失忆的烟圈:BAAALgADCgcJBwAAAA==.',
['姜明']='姜明明:BAAALgAECgIJAwAAAA==.',
['威少']='威少:BAAALgAECgkJCQAAAA==.',
['娱乐']='娱乐万能天使:BAACLgAFFH8GAAMPAAMJGA+4CwD5AAAPAAMJGA+4CwD5AAAUAAEJkAE5GAAyAAAuAAQKfysAAxQACAnrFWgIAKUBABQACAnrFWgIAKUBAA8AAglLC7dWAGUAAAAA.',
['嫂夫']='嫂夫人:BAAALgADCgEJAQAAAA==.',
['嫑啊']='嫑啊嫑啊:BAAALgAECgEJAQAAAA==.',
['季老']='季老六丶:BAACLgAFFH8FAAIFAAIJFiG9CADDAAAFAAIJFiG9CADDAAAuAAQKfxUAAgUABgk1I8cQAFICAAUABgk1I8cQAFICAAAA.',
['孤雏']='孤雏:BAAALgAECgEJAQAAAA==.',
['安洁']='安洁莉卡:BAAALgAECgYJBwAAAA==.',
['宥仔']='宥仔快跑:BAABLgAFFH8JAAIEAAQJfhjQEQBaAQAEAAQJfhjQEQBaAQAAAA==.',
['小七']='小七妹丶:BAAALgAECgIJAgAAAA==.',
['小原']='小原纱央莉:BAAALgAECgkJCQAAAA==.',
['小哥']='小哥你的快递:BAAALgADCgcJBwAAAA==.',
['小楼']='小楼又风雨:BAAALgAECgIJAgABLgAFFAQJDAAIAOwZAA==.',
['小沫']='小沫子:BAAALgAECgEJAQAAAA==.',
['小海']='小海草:BAABLgAFFH8FAAIVAAUJdRmrBwAlAQAVAAUJdRmrBwAlAQAAAA==.小海蛏:BAAALgADCgcJBwAAAA==.',
['小爖']='小爖人:BAAALgAECgUJBQAAAA==.',
['小玥']='小玥残风:BAAALgADCgIJAgAAAA==.',
['小美']='小美:BAAALgAECgMJAwAAAA==.',
['小魔']='小魔灬:BAAALgAECgYJCAAAAA==.',
['小龙']='小龙猫:BAAALgAFFAQJBAAAAA==.',
['少个']='少个三:BAAALgAECgMJBAAAAA==.',
['尘世']='尘世凡间:BAACLgAFFH8JAAIMAAQJ2hoGDQBzAQAMAAQJ2hoGDQBzAQAuAAQKfyEAAwwACAmRJAcQAPkCAAwABwnvJAcQAPkCAA0AAwlEII0tAAcBAAAA.尘世闲游:BAAALgAECgcJEwAAAA==.',
['尤格']='尤格索托斯:BAAALgAECggJCQAAAA==.',
['就爱']='就爱臭美:BAAALgAFFAEJAQABLgAFFAQJDAAIAOwZAA==.',
['尼古']='尼古拉斯灬叶:BAAALgAECgIJAgAAAA==.尼古拉斯灬圣:BAAALgAECgUJBwAAAA==.尼古拉斯灬牧:BAAALgAECgYJBwAAAA==.',
['居死']='居死你:BAAALgAFFAIJAgAAAA==.',
['岁宁']='岁宁念安:BAAALgAECgEJAQAAAA==.',
['巨蟹']='巨蟹座:BAAALgAECgMJAwAAAA==.',
['巫风']='巫风语:BAAALgAECgMJAwAAAA==.',
['已有']='已有五百年:BAAALgAECgYJCwABLgAFFAQJDAAIAOwZAA==.',
['希尔']='希尔瓦不撕丶:BAAALgAECgQJBgAAAA==.',
['异乡']='异乡旅者:BAAALgADCgQJBAAAAA==.',
['弓箭']='弓箭手:BAAALgADCgYJBgAAAA==.',
['归途']='归途灬:BAABLgAECn8eAAMKAAgJ5RZdHQAwAgAKAAgJ5RZdHQAwAgATAAUJIhDMTAAUAQAAAA==.',
['当年']='当年:BAAALgAFFAIJBAAAAA==.',
['德莱']='德莱格:BAABLgAECn8VAAMWAAYJwBlCGQDFAQAWAAYJwBlCGQDFAQAVAAUJABA3NwAbAQAAAA==.德莱联萌妹:BAAALgADCgkJCQAAAA==.',
['心兕']='心兕月:BAAALgAECgYJBgAAAA==.',
['忘却']='忘却之尘:BAAALgAECgEJAQAAAA==.',
['念槐']='念槐:BAAALgAECgUJBQAAAA==.',
['念经']='念经吉吉:BAABLgAFFH8GAAILAAIJ6Rd9GgCWAAALAAIJ6Rd9GgCWAAAAAA==.',
['怕插']='怕插秧:BAAALgAECgYJCgAAAA==.',
['怣忈']='怣忈厶忄:BAAALgADCgUJBQAAAA==.',
['恢复']='恢复记忆:BAAALgADCgYJCwAAAA==.',
['愿与']='愿与愁:BAACLgAFFH8FAAIBAAMJvQ5WLQABAQABAAMJvQ5WLQABAQAuAAQKfyEABAEACAn4HYQ2AJoCAAEACAn4HYQ2AJoCABcAAQl4HuEXAFoAABgAAQlUE58OAEAAAAAA.',
['憂鬱']='憂鬱的聖鬥士:BAAALgAECgcJCQAAAA==.',
['戊财']='戊财财:BAAALgADCgcJBwAAAA==.',
['成乾']='成乾丶:BAAALgAECgcJEwAAAA==.',
['我不']='我不丨守尸:BAAALgADCgEJAQAAAA==.',
['我叫']='我叫小猪:BAAALgAECgEJAQAAAA==.',
['战斗']='战斗大师:BAACLgAFFH8HAAMZAAQJrx0JBQDIAAAZAAIJSh4JBQDIAAAaAAIJFB0hFQC/AAAuAAQKfyUAAxkACAn/I1gBAEADABkACAn/I1gBAEADABoABwllHTkoABwCAAAA.',
['战风']='战风:BAABLgAFFH8GAAIEAAQJURWqEwD1AAAEAAQJURWqEwD1AAAAAA==.',
['戰丶']='戰丶风语者:BAAALgAECgUJBQAAAA==.',
['打不']='打不过就跑啊:BAAALgADCgUJBQAAAA==.',
['打个']='打个大西瓜:BAABLgAFFH8GAAIIAAMJiAuRDQDwAAAIAAMJiAuRDQDwAAAAAA==.',
['扫达']='扫达斯奈:BAAALgAECgMJAwAAAA==.',
['抹了']='抹了油的周浩:BAAALgAECgYJCgAAAA==.',
['拉俺']='拉俺老孙一炕:BAAALgAECgYJCgAAAA==.',
['拉粑']='拉粑粑小魔仙:BAAALgADCgEJAQAAAA==.',
['拥抱']='拥抱星海的鲸:BAAALgAECgcJDgAAAA==.',
['指环']='指环王归来:BAABLgAECn8lAAMZAAgJjAgyBQBkAQAZAAgJjAgyBQBkAQAaAAcJMQS6ZAAgAQAAAA==.',
['推车']='推车那年:BAAALgAECgIJAgAAAA==.',
['提里']='提里奥佛甲:BAAALgAECgQJBwAAAA==.',
['擎天']='擎天小飞牛:BAABLgAECn8ZAAIbAAYJ0SHqCQBvAQAbAAYJ0SHqCQBvAQAAAA==.',
['故事']='故事的小黄花:BAAALgAECgUJBwAAAA==.',
['敖广']='敖广:BAAALgAFFAIJAgAAAA==.',
['散作']='散作满河星:BAAALgAECgQJBAAAAA==.',
['料峭']='料峭:BAAALgAECgYJCwAAAA==.',
['断剑']='断剑安天涯:BAAALgAECgEJAQAAAA==.',
['斯塔']='斯塔文老师:BAAALgAECgYJCgAAAA==.',
['日龙']='日龙宝嗦你:BAAALgAECgIJAgAAAA==.',
['早来']='早来晚走:BAACLgAFFH8IAAIDAAQJpxaBDwBSAQADAAQJpxaBDwBSAQAuAAQKfyMAAgMACAmnHmIVANYCAAMACAmnHmIVANYCAAAA.',
['时间']='时间的碎片:BAAALgAECgUJBQAAAA==.',
['时雨']='时雨:BAAALgAFFAEJAQAAAA==.',
['春风']='春风不解:BAAALgAECgUJBgAAAA==.',
['是腻']='是腻害:BAACLgAFFH8IAAIEAAQJyROuFQBNAQAEAAQJyROuFQBNAQAuAAQKfx0AAgQACAmQIVwXAO8CAAQACAmQIVwXAO8CAAAA.',
['晒太']='晒太阳的猫:BAAALgAECgMJAwAAAA==.',
['晓小']='晓小乖:BAAALgAECgEJAQAAAA==.',
['晨曦']='晨曦炫目:BAAALgAECgcJEwAAAA==.',
['暗影']='暗影幽焱:BAAALgADCgEJAQAAAA==.',
['暗月']='暗月无双:BAAALgAFFAIJAwAAAA==.',
['暗淡']='暗淡丶星光:BAABLgAFFH8JAAMMAAQJThyOCwB/AQAMAAQJThyOCwB/AQANAAEJThDiFABVAAAAAA==.',
['暮涩']='暮涩的圣光:BAAALgAECgEJAQABLgAECgMJBAAcAAAAAA==.',
['暴脾']='暴脾气大白兔:BAAALgAECgMJBAAAAA==.',
['月亮']='月亮家的小鬼:BAAALgAECgMJAwAAAA==.月亮邮递员:BAAALgAFFAIJBAAAAA==.',
['木凡']='木凡:BAACLgAFFH8MAAIIAAQJ7Bk0AwBqAQAIAAQJ7Bk0AwBqAQAuAAQKfx8ABAgACAl/HUETAJ0CAAgACAl/HUETAJ0CAAkAAQneGOAtADsAAAcAAQnGAZeXACAAAAAA.',
['木头']='木头就爱动:BAAALgAECgYJBwAAAA==.木头既是艺术:BAAALgAECgcJBwAAAA==.',
['本质']='本质是小狗:BAAALgADCgMJAwAAAA==.',
['机哥']='机哥背后偷袭:BAAALgADCgEJAQAAAA==.',
['杀手']='杀手归西:BAAALgAECgYJBgAAAA==.',
['東風']='東風谷早苗:BAAALgAFFAIJBAAAAA==.',
['板老']='板老卢:BAAALgADCgEJAQAAAA==.',
['果果']='果果爹:BAABLgAFFH8GAAITAAIJOhMSFQCmAAATAAIJOhMSFQCmAAAAAA==.',
['格兰']='格兰帝列:BAACLgAFFH8IAAMWAAQJEwpUDAAiAQAWAAQJEwpUDAAiAQAVAAIJ4QMnHQCHAAAuAAQKfysAAxUACAl5FkcGALoBABUACAl5FkcGALoBABYAAwm4GLoxAOIAAAAA.',
['桃花']='桃花朵朵霏:BAAALgAECgMJAwAAAA==.',
['梦回']='梦回吹角联姻:BAAALgAECgIJBAAAAA==.',
['梦幻']='梦幻剪影:BAAALgAECgMJBAAAAA==.',
['楊小']='楊小邪:BAAALgAECgEJAQAAAA==.',
['楼阁']='楼阁灬五角星:BAAALgAFFAEJAQAAAA==.',
['檸檬']='檸檬灬尐漩:BAAALgAECgUJCAAAAA==.',
['櫻絡']='櫻絡:BAAALgAECgIJAgAAAA==.',
['欧太']='欧太上皇:BAAALgAECgQJBQAAAA==.',
['欧拉']='欧拉欧拉:BAAALgAECgEJAgAAAA==.',
['正太']='正太之心:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡囡囡:BAAALgAECgYJDQAAAA==.死亡将遂:BAAALgAECgcJEAAAAA==.',
['毁灭']='毁灭之种:BAAALgAFFAIJAgAAAA==.',
['毒龙']='毒龙灬麦哲伦:BAAALgAECgQJBAAAAA==.',
['比奇']='比奇堡牛师傅:BAAALgADCgUJBQAAAA==.',
['汐柠']='汐柠:BAAALgAECgYJBQAAAA==.',
['沁爽']='沁爽青柠味:BAAALgAECgYJBgAAAA==.',
['沃踏']='沃踏马莱啦:BAAALgAECgUJBQAAAA==.',
['沉默']='沉默的桔子:BAAALgADCgQJBAAAAA==.',
['沙鲁']='沙鲁:BAAALgADCgQJAwAAAA==.',
['洗洗']='洗洗:BAAALgAECgUJBQAAAA==.',
['浮躁']='浮躁的世界:BAAALgAECgYJCQAAAA==.',
['海顿']='海顿:BAAALgAECgMJAwAAAA==.',
['涛杀']='涛杀在此:BAAALgAECgYJBwAAAA==.',
['淡淡']='淡淡女人香丶:BAABLgAFFH8FAAIKAAMJhBMaDwDvAAAKAAMJhBMaDwDvAAAAAA==.',
['混沌']='混沌武士:BAAALgAECgEJAgAAAA==.',
['清歌']='清歌丶扶酒:BAABLgAFFH8MAAILAAQJggxqDwAHAQALAAQJggxqDwAHAQAAAA==.',
['清水']='清水健:BAAALgAFFAQJBAAAAA==.清水大师:BAAALgADCgkJCQAAAA==.',
['清蒸']='清蒸哒哒虾:BAAALgAECgQJBAABLgAFFAUJFQABAFYRAA==.',
['渊虹']='渊虹:BAAALgAECgYJBwAAAA==.',
['温润']='温润清风:BAAALgAECgMJBQAAAA==.',
['湛蓝']='湛蓝彦白:BAAALgAECgMJBAAAAA==.',
['滅絕']='滅絕:BAAALgAFFAEJAQAAAA==.',
['潇秋']='潇秋雨:BAAALgAECggJEAAAAA==.',
['灬且']='灬且听风吟灬:BAAALgAECgEJAQAAAA==.',
['灬柳']='灬柳梦璃灬:BAAALgADCgMJAwAAAA==.',
['灬橙']='灬橙心橙意灬:BAAALgAFFAIJBAAAAA==.',
['灬門']='灬門徒灬:BAAALgADCgMJAwAAAA==.',
['灬鬼']='灬鬼離灬:BAAALgADCgUJBQAAAA==.',
['灭绝']='灭绝坐莲:BAABLgAECn8VAAIEAAYJXx/uSwAPAgAEAAYJXx/uSwAPAgAAAA==.',
['烈火']='烈火牛牛:BAAALgAECgcJEAAAAA==.',
['無義']='無義:BAACLgAFFH8GAAIEAAIJTgPESQCOAAAEAAIJTgPESQCOAAAuAAQKfx8AAgQACAkyG44JAAACAAQACAkyG44JAAACAAAA.',
['熏悟']='熏悟空的熏:BAAALgAECggJCAAAAA==.',
['熙沫']='熙沫沫丶:BAACLgAFFH8HAAIEAAMJHh0FEQADAQAEAAMJHh0FEQADAQAuAAQKfxoAAgQABwlmIXkVAIEBAAQABwlmIXkVAIEBAAAA.',
['犄角']='犄角野德:BAAALgADCgEJAQAAAA==.',
['狐太']='狐太郎:BAAALgADCgcJBwAAAA==.',
['猛抽']='猛抽红塔山:BAAALgAECgEJAQAAAA==.',
['玉生']='玉生香:BAAALgAECgMJAwAAAA==.',
['琉璃']='琉璃清华:BAAALgAFFAQJBAAAAA==.',
['琉箫']='琉箫:BAAALgAECgMJAwAAAA==.',
['瑞雅']='瑞雅怒心:BAAALgAECgYJCQAAAA==.',
['璃菱']='璃菱洛:BAAALgAECggJDwAAAA==.',
['甜心']='甜心小瓜瓜:BAAALgAECgQJBwAAAA==.',
['甜豆']='甜豆腐脑:BAAALgAECgcJBwAAAA==.',
['生后']='生后繁华:BAAALgAFFAIJAwAAAA==.',
['生椰']='生椰拿铁:BAABLgAECn8dAAIBAAkJCRo0JQDeAgABAAkJCRo0JQDeAgAAAA==.',
['电眼']='电眼福人:BAAALgAECgEJAQAAAA==.',
['番茄']='番茄丶炒蛋:BAABLgAFFH8GAAISAAMJvyPEBwAzAQASAAMJvyPEBwAzAQAAAA==.番茄魚丶:BAAALgAECgYJDAAAAA==.',
['白夜']='白夜暗影:BAAALgAECgEJAQAAAA==.',
['白梦']='白梦妍:BAAALgAECgIJBQAAAA==.',
['白菜']='白菜先生:BAAALgAECgUJCAAAAA==.',
['白葵']='白葵:BAAALgAECgcJCwAAAA==.',
['百里']='百里成霜:BAAALgAECgQJCAAAAA==.',
['皮皮']='皮皮的三角龙:BAAALgADCgYJBgAAAA==.',
['皮裤']='皮裤少女:BAAALgAECgcJEAAAAA==.',
['眼中']='眼中朝暮:BAAALgADCgUJBQAAAA==.',
['睡古']='睡古大人:BAAALgAECgIJAgAAAA==.',
['石川']='石川澪:BAAALgAECgcJDAABLgAFFAQJBAAcAAAAAA==.',
['离群']='离群之刺丶:BAAALgAECgYJBgAAAA==.',
['秀得']='秀得水乱流:BAAALgAECgkJBgAAAA==.',
['空想']='空想之咕:BAAALgADCgMJAwAAAA==.',
['穿梭']='穿梭时间:BAAALgADCgYJBgAAAA==.',
['窃镜']='窃镜子的贼:BAAALgADCgUJBQAAAA==.',
['等待']='等待一:BAABLgAFFH8LAAICAAQJahMeAQBdAQACAAQJahMeAQBdAQAAAA==.等待的涟漪:BAAALgAFFAQJBAAAAA==.',
['筱艿']='筱艿琪:BAAALgADCgYJBwAAAA==.',
['粗粗']='粗粗子:BAAALgAFFAQJAgABLgAFFAUJAgAcAAAAAA==.',
['精蹦']='精蹦的鲫壳儿:BAAALgADCgMJAwAAAA==.',
['素年']='素年锦时:BAAALgAECgQJBAAAAA==.',
['紫色']='紫色职业:BAAALgAFFAIJBAAAAA==.',
['纹龍']='纹龍:BAAALgAECgEJAQAAAA==.',
['细节']='细节术:BAAALgAFFAIJBAABLgAFFAQJCQABADoJAA==.',
['绥帝']='绥帝韃枭变:BAAALgADCgYJBgAAAA==.',
['罗伯']='罗伯格鲁特:BAAALgAECgEJAQAAAA==.',
['美图']='美图:BAABLgAECn8UAAIdAAgJXRNCDAC9AQAdAAgJXRNCDAC9AQAAAA==.',
['羡慕']='羡慕风和雨:BAAALgAFFAIJBAAAAA==.',
['聋人']='聋人:BAAALgAECgcJDgAAAA==.',
['肆等']='肆等待:BAAALgAECgcJBwAAAA==.',
['肥牛']='肥牛牛:BAAALgAECgQJCQABLgAFFAIJAgAcAAAAAA==.',
['背影']='背影很风骚:BAAALgADCgYJBgAAAA==.',
['胖丁']='胖丁:BAAALgAECgQJBAAAAA==.',
['腐化']='腐化的小益:BAACLgAFFH8KAAIdAAMJ2xzECAABAQAdAAMJ2xzECAABAQAuAAQKfyEAAh0ACAkfH0EQALYCAB0ACAkfH0EQALYCAAAA.',
['舞太']='舞太极:BAAALgAECgIJAgAAAA==.',
['花解']='花解语:BAAALgAECgYJBgAAAA==.',
['芸依']='芸依:BAABLgAFFH8LAAIeAAQJ/wz2AQA0AQAeAAQJ/wz2AQA0AQAAAA==.',
['苍术']='苍术:BAAALgAFFAIJAwAAAA==.',
['苍葵']='苍葵:BAAALgAECgQJCAAAAA==.',
['英雄']='英雄战火:BAAALgAECgYJBgAAAA==.',
['范马']='范马刃牙丶:BAABLgAFFH8HAAMaAAQJJhP0EAD/AAAaAAMJyRP0EAD/AAAZAAEJPhF4CgBZAAAAAA==.',
['茜茜']='茜茜梨藏美丽:BAAALgAECgcJBwAAAA==.',
['草鹿']='草鹿八千流:BAABLgAFFH8JAAIMAAUJXx7IBQBnAQAMAAUJXx7IBQBnAQAAAA==.',
['莎莉']='莎莉萨:BAABLgAFFH8JAAIHAAUJNBzkBgCvAQAHAAUJNBzkBgCvAQAAAA==.',
['莫羊']='莫羊拉模样打:BAAALgAECgQJBAAAAA==.',
['莫脾']='莫脾气:BAAALgAFFAMJAwAAAA==.',
['菜鸡']='菜鸡鲲:BAAALgAECgYJBwAAAA==.',
['萝卜']='萝卜和青菜:BAAALgAECgYJBwAAAA==.',
['萨菲']='萨菲隆斯:BAABLgAFFH8GAAMOAAIJdRF6EABtAAAOAAIJ1gl6EABtAAAEAAEJ1RyJTQBYAAAAAA==.',
['蓝四']='蓝四六:BAABLgAFFH8GAAIOAAYJCQ8aAgBiAQAOAAYJCQ8aAgBiAQAAAA==.',
['蓝莓']='蓝莓拌苦瓜:BAAALgAECgMJAwAAAA==.',
['蓝葵']='蓝葵:BAAALgAECgUJCQAAAA==.',
['蛋蛋']='蛋蛋不墨迹:BAAALgADCgUJBQAAAA==.',
['蜡笔']='蜡笔小熊猫:BAAALgAECgEJAQAAAA==.',
['蠕蠕']='蠕蠕丶:BAAALgAECgcJCQAAAA==.',
['血狼']='血狼重坦:BAAALgAFFAIJAwAAAA==.',
['血色']='血色枫红丶:BAABLgAECn8gAAMPAAgJDB4NDADCAgAPAAgJDB4NDADCAgAUAAUJlwNvWwDGAAAAAA==.',
['西湖']='西湖梧桐:BAAALgAECgEJAgAAAA==.',
['认识']='认识您的美:BAAALgAFFAIJBAAAAA==.',
['该死']='该死不得活:BAAALgAECgIJAQAAAA==.',
['请叫']='请叫我贝爷:BAAALgAECgIJAgAAAA==.',
['谷雨']='谷雨丶:BAAALgAECgcJBwAAAA==.谷雨灬:BAABLgAECn8UAAMZAAcJER0bCwDxAQAaAAcJ1xmoKgAOAgAZAAcJrhYbCwDxAQAAAA==.',
['豆腐']='豆腐脑冥哥:BAAALgAECgYJBgAAAA==.',
['豆豆']='豆豆宝宝:BAAALgAECgcJBgAAAA==.',
['贝优']='贝优妮塔雪莉:BAAALgADCgYJBgAAAA==.',
['跩根']='跩根:BAAALgAECgQJBQAAAA==.',
['路人']='路人甲:BAAALgAECgEJAQAAAA==.',
['路依']='路依依:BAAALgAECgYJBgAAAA==.',
['辉之']='辉之血吻:BAAALgAECgUJBQAAAA==.',
['过儿']='过儿爱龙儿:BAAALgAECgQJDwAAAA==.',
['这是']='这是谁啊:BAAALgAECgEJAQAAAA==.',
['进口']='进口黑牛:BAAALgAECgQJBwAAAA==.',
['迟早']='迟早回部落哈:BAAALgADCgcJBwAAAA==.',
['逆我']='逆我必杀:BAAALgAECgEJAQAAAA==.',
['逐隐']='逐隐:BAABLgAFFH8LAAIfAAYJjCA7AAB6AgAfAAYJjCA7AAB6AgAAAA==.',
['逗逼']='逗逼的阿昆达:BAAALgAECgQJBQAAAA==.',
['那一']='那一抹天空蓝:BAAALgAECgEJAgAAAA==.',
['邦邦']='邦邦应:BAAALgADCgEJAQAAAA==.',
['醉无']='醉无情:BAAALgADCgcJBwAAAA==.',
['醉雲']='醉雲梦:BAAALgAECggJEgAAAA==.',
['里中']='里中镜流:BAAALgADCgEJAQAAAA==.',
['野外']='野外小游侠:BAAALgAECgIJAgAAAA==.',
['野生']='野生圈圈熊:BAAALgAECgMJBQAAAA==.',
['铁杉']='铁杉树丛:BAAALgAFFAIJBAAAAA==.',
['锤锤']='锤锤小:BAABLgAFFH8HAAMaAAIJWArkDACnAAAaAAIJWArkDACnAAAgAAIJnQcUDQB6AAAAAA==.',
['镜瞳']='镜瞳映时隙:BAAALgAFFAIJBAAAAA==.',
['闭眼']='闭眼盎然:BAAALgAECgMJAwAAAA==.',
['阿土']='阿土:BAAALgAECgEJAQAAAA==.',
['阿森']='阿森纳迪欧:BAAALgAECgUJCQAAAA==.',
['阿祖']='阿祖收手吧:BAAALgAECgEJAgAAAA==.阿祖真帅丶:BAAALgAECgMJAwAAAA==.',
['陆等']='陆等待:BAAALgAFFAQJBAAAAA==.',
['陌小']='陌小漓:BAAALgAFFAEJAQAAAA==.',
['陨落']='陨落丶旋律:BAAALgAFFAMJBAAAAA==.',
['随风']='随风逐鹿:BAABLgAECn8jAAMIAAgJqx7HBQA1AgAIAAgJKR7HBQA1AgAHAAUJnx12MwCcAQAAAA==.',
['雑毛']='雑毛小鸡:BAAALgAFFAIJBAAAAA==.',
['雨淋']='雨淋湿了天空:BAAALgAECgIJAgAAAA==.',
['雨落']='雨落六天:BAAALgAECgMJAwAAAA==.',
['雪匕']='雪匕透心:BAAALgAFFAIJAgAAAA==.',
['雪纳']='雪纳瑞尔:BAAALgAECgUJCQAAAA==.',
['雷姆']='雷姆丶:BAAALgAECgQJBAABLgAFFAMJBgAIAHoWAA==.',
['面包']='面包小小:BAAALgAECgEJAQAAAA==.',
['顭鎏']='顭鎏蓉城:BAAALgADCgUJBQAAAA==.',
['项羽']='项羽:BAABLgAECn8jAAIaAAgJPhgiFgCcAgAaAAgJPhgiFgCcAgAAAA==.',
['顺隐']='顺隐:BAAALgAECgEJAQABLgAECgcJBwAcAAAAAA==.',
['须臾']='须臾:BAAALgAFFAQJBAAAAA==.',
['顾曲']='顾曲周郎:BAAALgADCgEJAQAAAA==.',
['顿顿']='顿顿吃肉:BAAALgADCgYJBgAAAA==.',
['风丨']='风丨月:BAAALgAECgEJAQAAAA==.',
['风先']='风先空落:BAAALgAECgIJAwAAAA==.',
['风暴']='风暴前:BAAALgAECgMJAQAAAA==.风暴烈酒灬:BAABLgAFFH8KAAILAAUJmhLXBgBlAQALAAUJmhLXBgBlAQAAAA==.',
['风魇']='风魇星光:BAACLgAFFH8JAAIhAAQJOxLsAQBdAQAhAAQJOxLsAQBdAQAuAAQKfywAAiEACAlyI6kAAIsCACEACAlyI6kAAIsCAAAA.',
['飞雪']='飞雪飘叙:BAAALgADCgIJAgAAAA==.',
['饮一']='饮一壶:BAAALgAECgcJBwAAAA==.',
['饼干']='饼干君:BAAALgADCgEJAQAAAA==.',
['首席']='首席乌瑟尔:BAABLgAFFH8FAAISAAUJEg+iBgCFAQASAAUJEg+iBgCFAQAAAA==.',
['马丿']='马丿菊长:BAAALgAECgMJBAAAAA==.',
['马仔']='马仔:BAAALgAECgYJCQAAAA==.',
['麌儿']='麌儿:BAAALgADCgIJAgAAAA==.',
['黄英']='黄英:BAAALgAFFAIJAwAAAA==.',
['黑暗']='黑暗法神:BAAALgAECgMJAwAAAA==.',
['黑羽']='黑羽基德:BAAALgAECgUJBQAAAA==.',
['黑衣']='黑衣剑士桐人:BAAALgADCgUJBQAAAA==.',
['龑拳']='龑拳:BAAALgAECgEJAQAAAA==.',
['龙戰']='龙戰:BAAALgAECgEJAwAAAA==.',
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
