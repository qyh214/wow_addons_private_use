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

local lookup = {'Evoker-Preservation','Priest-Holy','Priest-Discipline','Priest-Shadow','Warlock-Demonology','Mage-Frost','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Devourer','Paladin-Retribution','Rogue-Subtlety','Rogue-Assassination','Warrior-Fury','DeathKnight-Unholy','Druid-Balance','Druid-Restoration','Unknown-Unknown','Warrior-Arms','Warlock-Destruction','Monk-Brewmaster','Monk-Mistweaver','Monk-Windwalker','Shaman-Restoration','Shaman-Elemental','Evoker-Augmentation','Druid-Guardian',}
local provider = {region='CN',realm='符文图腾',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Acelyy:BAABLgAFFH8IAAIBAAMJnw5IBwDmAAABAAMJnw5IBwDmAAAAAA==.Acelyydd:BAAALgAECggJDwAAAA==.',
Cg='Cgg:BAAALgAECgYJBgAAAA==.',
Do='Doctere:BAABLgAECn8YAAQCAAYJJiJiHgDsAQACAAYJ6B9iHgDsAQADAAYJlhkmGADcAQAEAAEJnQMtaQAmAAAAAA==.Doggie:BAACLgAFFH8FAAIFAAMJoQonIQClAAAFAAMJoQonIQClAAAuAAQKfxQAAgUACAnRGMwvAE4CAAUACAnRGMwvAE4CAAAA.Doraemo:BAAALgADCgMJAwAAAA==.',
Ei='Eiie:BAAALgAECgcJDAAAAA==.',
En='Encores:BAAALgADCgMJAwAAAA==.',
Fe='Fefefede:BAAALgAECgUJBQAAAA==.',
Fg='Fgdjghjh:BAABLgAFFH8HAAIGAAcJWxo7AABKAgAGAAcJWxo7AABKAgAAAA==.',
Ko='Komo:BAAALgADCgEJAQAAAA==.',
Ry='Ryzen:BAAALgAFFAEJAQAAAA==.',
Vi='Vip:BAAALgAECgEJAQAAAA==.',
Zz='Zzga:BAABLgAFFH8LAAIHAAQJoSXoAgDAAQAHAAQJoSXoAgDAAQAAAA==.',
['一内']='一内内可爱:BAAALgAECgQJBAAAAA==.',
['一只']='一只海龟成功:BAAALgAECgQJBAAAAA==.一只爪子:BAAALgAECgMJAwAAAA==.',
['一箭']='一箭一小朋友:BAAALgADCgYJCwAAAA==.',
['七趾']='七趾鬼厉:BAAALgAECgMJBAAAAA==.',
['三花']='三花聚顶:BAAALgADCgYJBgAAAA==.',
['上善']='上善如水:BAAALgAECgUJBgAAAA==.',
['下山']='下山抓绵羊:BAACLgAFFH8JAAIIAAMJZRYSCwAJAQAIAAMJZRYSCwAJAQAuAAQKfx0AAwgACAmuHugkACkCAAgABgndIOgkACkCAAkABgkmEws+AGMBAAAA.',
['不壹']='不壹零需检测:BAABLgAECn8WAAIKAAgJXBtwMQA1AgAKAAgJXBtwMQA1AgAAAA==.',
['不甜']='不甜不甜:BAABLgAFFH8GAAILAAMJyQ8JFgD7AAALAAMJyQ8JFgD7AAAAAA==.',
['丨妮']='丨妮児:BAAALgAECgEJAQAAAA==.',
['丨燈']='丨燈萢大叔丨:BAAALgAECgcJCAAAAA==.',
['临海']='临海:BAAALgAECgQJBQAAAA==.',
['丶龍']='丶龍崽:BAAALgAECgUJEAAAAA==.',
['乔治']='乔治基维斯:BAACLgAFFH8FAAIMAAMJmwssEwCzAAAMAAMJmwssEwCzAAAuAAQKfxwAAwwACAkcGjsQAKICAAwACAkcGjsQAKICAA0AAQmlCwAeAD0AAAAA.',
['云朝']='云朝暮雨:BAACLgAFFH8FAAIKAAMJmgufGwCRAAAKAAMJmgufGwCRAAAuAAQKfx4AAgoACAmYGjUqAFgCAAoACAmYGjUqAFgCAAAA.',
['云深']='云深不知处:BAAALgAECgUJBQAAAA==.',
['亦上']='亦上:BAAALgAECgcJBwAAAA==.',
['以徳']='以徳服人:BAAALgAECgEJAQAAAA==.',
['以歌']='以歌:BAAALgAECgIJAgAAAA==.',
['你是']='你是真的菜啊:BAAALgAECgYJCwAAAA==.',
['侏侏']='侏侏与儒儒:BAAALgAECgUJBQAAAA==.',
['俺是']='俺是白牛:BAAALgADCgIJAQAAAA==.',
['做一']='做一晚泥工:BAAALgAFFAEJAQAAAA==.',
['克里']='克里斯蒂娜:BAAALgAECggJCAAAAA==.',
['冰封']='冰封乱城:BAAALgAECgYJDwAAAA==.',
['冰箱']='冰箱软妹贴:BAAALgAECgEJAQAAAA==.',
['冰霜']='冰霜万里:BAAALgAECgQJBAAAAA==.',
['冴羽']='冴羽:BAAALgADCgcJBwAAAA==.',
['凑阿']='凑阿库娅:BAAALgAECgYJBgAAAA==.',
['凯珐']='凯珐囧咕:BAAALgADCgYJBgAAAA==.凯珐囧玖:BAAALgADCgIJAgAAAA==.',
['勥氼']='勥氼:BAACLgAFFH8JAAIOAAMJyBk5DwASAQAOAAMJyBk5DwASAQAuAAQKfxQAAg4ACAnxIe0HACsDAA4ACAnxIe0HACsDAAAA.',
['十步']='十步殺壹人:BAAALgAECgEJAQAAAA==.',
['千华']='千华闪丶:BAAALgADCgEJAQAAAA==.',
['千穗']='千穗:BAAALgAFFAMJBAAAAA==.',
['千金']='千金买邻:BAAALgAECgUJCgAAAA==.',
['半面']='半面痴狂:BAAALgAECgMJBAAAAA==.',
['单蓝']='单蓝色:BAABLgAECn8aAAMHAAgJOBrsGgA9AgAHAAgJOBrsGgA9AgALAAYJmQ4CkwBXAQAAAA==.',
['危岚']='危岚:BAAALgAECgEJAQAAAA==.',
['原野']='原野战狼:BAAALgAECgQJBgAAAA==.',
['古尓']='古尓丹:BAAALgAECgUJBQAAAA==.',
['叶师']='叶师兄:BAABLgAFFH8FAAIPAAMJzBjZJAACAQAPAAMJzBjZJAACAQAAAA==.',
['司羊']='司羊仙:BAAALgAFFAIJAgAAAA==.',
['司马']='司马仙:BAAALgAFFAQJAgAAAA==.',
['咕噜']='咕噜叽哩丶:BAAALgAECgYJBgAAAA==.',
['哆丶']='哆丶哆:BAAALgAECgQJBAAAAA==.',
['哈托']='哈托尔:BAAALgAECgYJCAAAAA==.',
['哈曼']='哈曼尼尔:BAAALgAFFAIJAgAAAA==.',
['唯我']='唯我忆风尘:BAAALgADCgYJBgAAAA==.',
['嗜血']='嗜血吕方平:BAAALgAECggJCAAAAA==.',
['嘚比']='嘚比嘚的德:BAACLgAFFH8JAAMQAAMJhiCOCwAyAQAQAAMJhiCOCwAyAQARAAIJeyBNDgCoAAAuAAQKfyMAAhAACAn/I6wNAMACABAACAn/I6wNAMACAAEuAAUUBQkEABIAAAAA.',
['嘟嘟']='嘟嘟是法爷:BAAALgAFFAIJAwAAAA==.',
['图牛']='图牛坦:BAAALgAECgUJBgAAAA==.',
['圣光']='圣光将:BAAALgAECgMJAwAAAA==.圣光的奶:BAAALgAECgIJAgAAAA==.',
['埃西']='埃西斯:BAAALgAECgEJAQABLgAECgYJCAASAAAAAA==.',
['埃辛']='埃辛诺斯刃:BAABLgAECn8WAAIKAAYJiRgAVgChAQAKAAYJiRgAVgChAQAAAA==.',
['壹丶']='壹丶壹:BAAALgAFFAIJAQAAAA==.',
['壹隊']='壹隊倵僧:BAAALgAECgEJAQAAAA==.',
['夕尧']='夕尧紫龙:BAAALgAECgQJBAAAAA==.',
['夙云']='夙云昭:BAAALgAECgkJAQAAAA==.',
['多吉']='多吉森格:BAAALgAECggJEgAAAA==.',
['多洛']='多洛洛:BAAALgAECgUJBAAAAA==.',
['夜之']='夜之璀璨:BAAALgAECgQJCgAAAA==.',
['夜思']='夜思苏虹:BAAALgAECgEJAQAAAA==.',
['夜路']='夜路好冷:BAAALgAECgQJBQAAAA==.',
['天下']='天下无双丶:BAAALgADCgUJBQAAAA==.',
['天光']='天光将:BAAALgAECgQJBQAAAA==.',
['天狼']='天狼异闪:BAAALgAFFAIJAwAAAA==.',
['天车']='天车上搞锤子:BAAALgAFFAEJAgAAAA==.',
['失落']='失落寒冬:BAAALgAECgYJBwAAAA==.',
['奈何']='奈何雪落无声:BAAALgAECgEJAQAAAA==.',
['奈芙']='奈芙蒂斯:BAAALgAECgQJBgABLgAECgYJCAASAAAAAA==.',
['奥格']='奥格带头大哥:BAAALgADCgEJAQAAAA==.',
['奥蕾']='奥蕾塞丝:BAAALgAECgQJCgAAAA==.',
['奶油']='奶油沼泽岛:BAAALgAECgMJAwABLgAFFAIJAwASAAAAAA==.',
['奶锤']='奶锤:BAAALgAFFAIJAwAAAA==.',
['好听']='好听:BAAALgAECgEJAQAAAA==.',
['好耍']='好耍第三:BAAALgAFFAEJAQAAAA==.',
['孤舟']='孤舟蓑笠翁:BAAALgAECgcJCAAAAA==.',
['孤身']='孤身走暗巷:BAAALgAECgUJBwAAAA==.',
['安和']='安和桥北:BAAALgADCgkJDQAAAA==.',
['安妮']='安妮:BAAALgAECgEJAQAAAA==.',
['安舍']='安舍:BAACLgAFFH8JAAILAAIJFiTcGQDVAAALAAIJFiTcGQDVAAAuAAQKfyIAAgsACQmrH9AJAEIDAAsACQmrH9AJAEIDAAAA.',
['宋老']='宋老师:BAABLgAFFH8FAAMTAAMJIwokBwCjAAATAAIJBwwkBwCjAAAOAAEJWQZoJABLAAAAAA==.',
['宠妃']='宠妃風末羽:BAAALgAECgMJAwAAAA==.',
['寒瞳']='寒瞳若影:BAAALgAECgEJAgAAAA==.',
['小小']='小小璀璨:BAAALgAECgQJBQAAAA==.',
['小路']='小路飛:BAAALgAECgYJCgAAAA==.',
['小鲍']='小鲍快跑:BAAALgADCgIJAgAAAA==.',
['尼大']='尼大叶:BAAALgADCgYJBgAAAA==.',
['山前']='山前:BAAALgAECggJDQAAAA==.',
['山哥']='山哥来啦:BAAALgAECgcJBwAAAA==.',
['山青']='山青:BAACLgAFFH8FAAIKAAMJTBVzFgC1AAAKAAMJTBVzFgC1AAAuAAQKfxUAAgoABwnTGy83ABkCAAoABwnTGy83ABkCAAAA.',
['幸福']='幸福陪伴你:BAABLgAFFH8JAAILAAMJahqBFgD4AAALAAMJahqBFgD4AAAAAA==.',
['廢黯']='廢黯:BAAALgAFFAQJBAAAAA==.',
['张沉']='张沉心丶:BAAALgAECgQJBgAAAA==.',
['很纯']='很纯很天真:BAAALgADCgEJAgAAAA==.',
['快驱']='快驱散:BAACLgAFFH8DAAIFAAIJaBZtHQCxAAAFAAIJaBZtHQCxAAAuAAQKfxsAAwUACAmlHucjAIQCAAUACAmlHucjAIQCABQABgkqHM0SALUBAAAA.',
['恶莱']='恶莱:BAAALgAECgUJBQAAAA==.',
['懒觉']='懒觉睡天天:BAAALgAECgUJCQAAAA==.',
['我不']='我不是绵花:BAAALgAFFAEJAQAAAA==.',
['我是']='我是潜入者:BAAALgAECgUJBgAAAA==.',
['我点']='我点火你扇风:BAAALgADCgYJBgAAAA==.',
['战神']='战神老白:BAAALgAECgEJAQAAAA==.',
['手法']='手法极其挑逗:BAAALgAECgEJAQAAAA==.',
['拣月']='拣月亮:BAAALgADCgMJAwAAAA==.',
['无一']='无一名:BAAALgAECgYJBwAAAA==.',
['无限']='无限绵延的心:BAAALgAECgUJBQAAAA==.',
['旺小']='旺小圣:BAAALgAFFAEJAQAAAA==.',
['旺财']='旺财不小吗:BAAALgAECgYJBgAAAA==.旺财小吗:BAACLgAFFH8FAAICAAMJMRhBDACeAAACAAMJMRhBDACeAAAuAAQKfxkAAwIACAkcGiAVADQCAAIACAlVGCAVADQCAAMAAwnVHKo0AP4AAAAA.',
['昆仑']='昆仑镜:BAABLgAFFH8GAAIHAAMJxA8eCADtAAAHAAMJxA8eCADtAAAAAA==.',
['昭月']='昭月炫星辰:BAAALgAECgIJAwAAAA==.',
['杀死']='杀死蛋蛋:BAAALgADCgUJBQAAAA==.',
['李绝']='李绝:BAAALgADCgYJBgAAAA==.',
['杜康']='杜康:BAAALgAECgMJAwAAAA==.',
['来不']='来不及解释:BAAALgAECgEJAgAAAA==.',
['柠檬']='柠檬奶油包:BAAALgAFFAIJAwAAAA==.',
['梦之']='梦之约定:BAAALgAECgIJAgAAAA==.',
['梦娴']='梦娴:BAAALgAECgkJEgAAAA==.梦娴一号:BAAALgAECgkJCQAAAA==.梦娴三号:BAAALgAECgIJAgAAAA==.梦娴二号:BAAALgAECgIJAgAAAA==.梦娴五号:BAAALgAECgIJAgAAAA==.梦娴四号:BAAALgAECgEJAQAAAA==.',
['梦灵']='梦灵画银潭:BAAALgAECgEJAwAAAA==.',
['梨天']='梨天行:BAAALgAECgUJCgAAAA==.',
['棕熊']='棕熊:BAAALgAECgEJAQAAAA==.',
['死聖']='死聖:BAACLgAFFH8GAAMLAAIJpRSdIgCnAAALAAIJpRSdIgCnAAAHAAEJBATrIAAzAAAuAAQKfxYAAwsABwlLGxxSAOsBAAsABwlLGxxSAOsBAAcABgltD8RSAC8BAAAA.',
['死鬼']='死鬼你好硬:BAAALgAECgEJAQAAAA==.',
['沧海']='沧海波澜:BAAALgAECgMJAwAAAA==.',
['油炸']='油炸花生米:BAAALgAFFAEJAQAAAA==.油炸薯条:BAAALgADCgEJAQAAAA==.',
['油莉']='油莉娜因八斯:BAAALgAECgIJAgAAAA==.',
['法湿']='法湿亲儿子:BAAALgADCgEJAQAAAA==.',
['泼墨']='泼墨画霓裳:BAAALgAECgMJAwAAAA==.',
['流浪']='流浪在远方:BAAALgAECgEJAQABLgAFFAUJEgAJAMYjAA==.',
['浪漫']='浪漫的莽子:BAAALgAFFAEJAQAAAA==.',
['海棠']='海棠熙兮:BAAALgAECgUJBQAAAA==.',
['淡看']='淡看江湖丶:BAAALgADCgYJBgAAAA==.',
['深蓝']='深蓝色滴梦灬:BAAALgAECgMJAwAAAA==.',
['淺凔']='淺凔北北:BAAALgADCgcJBwAAAA==.',
['清闲']='清闲布衣:BAAALgADCgQJBAAAAA==.',
['游翼']='游翼灵官:BAAALgADCgQJBwAAAA==.',
['漠烟']='漠烟烟:BAABLgAECn8cAAIGAAgJhhtQNgCbAgAGAAgJhhtQNgCbAgABLgAFFAYJBgAGABIBAA==.',
['潇雨']='潇雨潇:BAAALgAECgYJCAAAAA==.',
['火焚']='火焚城郭:BAAALgAECgEJAQAAAA==.',
['灵异']='灵异之血:BAAALgAECgYJDAAAAA==.',
['炽炎']='炽炎奥特曼:BAAALgAECggJCwAAAA==.',
['煤山']='煤山黑狐:BAAALgAECgEJAgAAAA==.',
['熊末']='熊末:BAAALgAECgIJAgAAAA==.',
['爆酱']='爆酱:BAAALgAFFAEJAQAAAA==.',
['牛油']='牛油果:BAAALgAECgEJAQAAAA==.',
['牧怿']='牧怿:BAAALgAECgMJAwAAAA==.',
['物理']='物理易伤:BAABLgAFFH8HAAQVAAQJ0w1EGgCYAAAVAAIJ0hNEGgCYAAAWAAMJxQVQCwCCAAAXAAEJ1gPJEwBDAAAAAA==.',
['狼兄']='狼兄:BAAALgAECgUJBQAAAA==.',
['玛丽']='玛丽斯图尔特:BAAALgAFFAMJAwAAAA==.',
['玛尔']='玛尔加尼斯:BAAALgAECgMJAwAAAA==.',
['珍妮']='珍妮玛丶士多:BAAALgAECgEJAQAAAA==.',
['琉炙']='琉炙:BAAALgAECgIJAgAAAA==.',
['瓜天']='瓜天蛆影:BAAALgAFFAIJAwAAAA==.',
['瓜田']='瓜田月影:BAAALgAECgQJBAAAAA==.',
['甩钢']='甩钢拌铁:BAAALgAECgEJAQAAAA==.',
['男神']='男神你山哥:BAAALgAECgMJAwAAAA==.',
['當歌']='當歌:BAAALgADCgEJAQAAAA==.',
['疯子']='疯子捅他:BAAALgAFFAMJBAAAAA==.',
['白细']='白细枸:BAAALgAECgUJAgAAAA==.',
['皓丶']='皓丶月:BAABLgAFFH8HAAMYAAQJoRAWBQA3AQAYAAQJoRAWBQA3AQAZAAEJFQQtHQBMAAAAAA==.',
['真牙']='真牙神幻十狼:BAAALgADCgUJBQAAAA==.',
['石原']='石原里美:BAABLgAFFH8HAAIFAAQJHhLGHwAEAQAFAAQJHhLGHwAEAQAAAA==.',
['硬汉']='硬汉不跳舞:BAAALgAECgYJDAAAAA==.',
['福生']='福生无量天尊:BAAALgAECgEJAQAAAA==.',
['突突']='突突斩:BAAALgAECgYJCgAAAA==.',
['筱筱']='筱筱灬法:BAAALgAECgUJCAAAAA==.',
['米奥']='米奥虾条:BAAALgAECgIJAgAAAA==.',
['米米']='米米娅:BAAALgAFFAEJAQAAAA==.',
['米菲']='米菲小麒:BAAALgAECgEJAQAAAA==.',
['素裕']='素裕:BAAALgADCgcJBwAAAA==.',
['胡子']='胡子拌豆腐:BAABLgAFFH8GAAIVAAMJYA1HEQCEAAAVAAMJYA1HEQCEAAAAAA==.',
['腿长']='腿长蛋高:BAAALgAECgEJAQAAAA==.',
['航母']='航母已经抵达:BAAALgAFFAEJAQAAAA==.',
['艾露']='艾露尼斯:BAAALgAECgYJCQAAAA==.',
['荷鲁']='荷鲁斯:BAAALgAECgYJBgABLgAECgYJCAASAAAAAA==.',
['荼啊']='荼啊:BAABLgAFFH8HAAMDAAQJGQfYBgAaAQADAAQJGQfYBgAaAQACAAEJZgv5FQA+AAAAAA==.',
['莉莉']='莉莉斯:BAAALgADCgIJAgAAAA==.',
['葡萄']='葡萄大帝:BAAALgADCgcJCQAAAA==.',
['蓝色']='蓝色滴天空灬:BAAALgAECgYJCAAAAA==.',
['蟠桃']='蟠桃:BAAALgAECgIJAwAAAA==.',
['血祭']='血祭苍天:BAAALgAECgYJBgAAAA==.',
['西格']='西格玛龙:BAABLgAFFH8IAAIaAAQJbQsyCAAcAQAaAAQJbQsyCAAcAQAAAA==.',
['西红']='西红柿炒饭:BAACLgAFFH8FAAIBAAMJTQMsCgCBAAABAAMJTQMsCgCBAAAuAAQKfxwAAwEACAnQEWEYANABAAEACAnQEWEYANABABoAAgmoCAlXAGUAAAAA.',
['豆包']='豆包:BAAALgADCgYJBwAAAA==.',
['贰丶']='贰丶贰:BAAALgAECgcJBwAAAA==.',
['辣丝']='辣丝美黛孜:BAAALgAECgMJBAAAAA==.',
['辰氵']='辰氵肤浅:BAAALgAECgQJBAAAAA==.',
['达文']='达文西丶战锁:BAAALgAECgIJAgAAAA==.',
['逆天']='逆天之自来也:BAAALgAECgEJAQAAAA==.',
['逍遥']='逍遥酒半仙:BAAALgADCgEJAQAAAA==.',
['遇术']='遇术琳疯:BAAALgAECgYJBgAAAA==.',
['邪百']='邪百万:BAABLgAFFH8FAAIPAAMJ5g48IgCcAAAPAAMJ5g48IgCcAAAAAA==.',
['部落']='部落英雄:BAAALgADCgEJAQAAAA==.',
['重庆']='重庆魅魔:BAAALgADCgEJAQAAAA==.',
['铁锅']='铁锅炖大鹅:BAAALgAECgcJEAAAAA==.',
['长夜']='长夜余火:BAAALgAECgEJAQAAAA==.',
['长脸']='长脸皮:BAAALgAECgMJAwAAAA==.',
['闯列']='闯列麻列鬼:BAAALgAECgEJAwAAAA==.',
['阿华']='阿华田:BAAALgAECgMJAwAAAA==.',
['陈厂']='陈厂长喝奶酒:BAAALgAECgEJAQAAAA==.陈厂长嗦一口:BAAALgAECgUJBgAAAA==.',
['随风']='随风战心:BAAALgAECgYJCQAAAA==.随风躲猫猫:BAABLgAECn8UAAQRAAYJUxOlHAAHAQARAAUJqxOlHAAHAQAQAAEJmALsjgAeAAAbAAEJiwTQOQATAAABLgAFFAIJAgASAAAAAA==.',
['雪山']='雪山之巅:BAAALgADCgIJAwAAAA==.',
['雷神']='雷神泪:BAAALgAECgYJBgAAAA==.',
['霜舞']='霜舞沐琉苏:BAAALgAECgEJAQAAAA==.',
['顺风']='顺风灬僧:BAABLgAECn8YAAIXAAgJ8hlWBgCoAQAXAAgJ8hlWBgCoAQAAAA==.',
['风中']='风中奇原:BAAALgAECgMJAwAAAA==.',
['风暴']='风暴龙王:BAABLgAFFH8KAAIBAAUJFRYABADBAQABAAUJFRYABADBAQABLgAFFAcJEAAaAHgaAA==.',
['风流']='风流先生:BAAALgAECgEJAQAAAA==.',
['飒飒']='飒飒里安:BAAALgAECgMJBAAAAA==.',
['骑马']='骑马笑红尘:BAAALgAECgIJAgAAAA==.',
['骨头']='骨头盾:BAAALgAECgMJAwAAAA==.',
['黎夏']='黎夏不冷:BAAALgAECgIJAgAAAA==.',
['龙之']='龙之歌行者:BAAALgADCgIJAgAAAA==.',
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
