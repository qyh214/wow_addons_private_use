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

local lookup = {'Unknown-Unknown','Paladin-Retribution','DemonHunter-Devourer','Rogue-Subtlety','Mage-Frost','Paladin-Holy','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood','Druid-Restoration','Warlock-Demonology','Warlock-Destruction','DemonHunter-Havoc','Warrior-Fury','Monk-Mistweaver','Warrior-Arms','Warrior-Protection','Shaman-Restoration','Priest-Shadow','Hunter-BeastMastery','Druid-Balance','Druid-Guardian','Evoker-Augmentation','Evoker-Devastation','Priest-Holy','Paladin-Protection','Hunter-Marksmanship','Hunter-Survival','Monk-Brewmaster','Monk-Windwalker','Evoker-Preservation',}
local provider = {region='CN',realm='希尔瓦娜斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Barasuisho:BAAALgADCgYJBgAAAA==.',
Bo='Boneprime:BAAALgAECgcJBwABLgAECgkJCgABAAAAAA==.',
Br='Bromineqaq:BAAALgAECgcJEQAAAA==.',
Bs='Bsxc:BAAALgADCgEJAQAAAA==.Bsxcc:BAABLgAECn8UAAICAAYJ9RSGnwBAAQACAAYJ9RSGnwBAAQAAAA==.',
Bu='Buttoner:BAAALgAECgYJCQAAAA==.',
Ch='Chip:BAAALgAECgEJAQAAAA==.',
De='Dearkdog:BAAALgAECgEJAQAAAA==.',
Di='Divann:BAACLgAFFH8IAAIDAAMJTCQgEQBGAQADAAMJTCQgEQBGAQAuAAQKfxcAAgMABgloJLEnAGUCAAMABgloJLEnAGUCAAAA.',
Do='Dolor:BAABLgAFFH8FAAIEAAIJ7RvbEwCwAAAEAAIJ7RvbEwCwAAAAAA==.',
Dr='Dragongirl:BAAALgAFFAEJAQAAAA==.',
Ee='Eemaster:BAAALgAECgkJDwAAAA==.',
El='Else:BAAALgAFFAMJBAAAAA==.',
Fi='Fireiv:BAABLgAECn8TAAIFAAYJ7SSRTABRAgAFAAYJ7SSRTABRAgABLgAFFAMJBAABAAAAAA==.',
Fu='Fullbeat:BAAALgAECgYJBgABLgAFFAMJBAABAAAAAA==.',
Ga='Gauss:BAAALgAECgQJBQAAAA==.',
Ge='Gespenst:BAABLgAFFH8FAAMGAAIJnBBxFQCVAAAGAAIJnBBxFQCVAAACAAEJQQe/NgBLAAAAAA==.',
Gg='Ggek:BAAALgAECgcJEwAAAA==.',
Gs='Gsm:BAAALgAECgQJBAAAAA==.',
Gu='Guardhero:BAAALgADCgYJBgAAAA==.',
Ha='Halfsummer:BAAALgAECgUJCgAAAA==.',
Ho='Hoax:BAAALgADCgMJAwAAAA==.How:BAAALgADCgYJBgAAAA==.',
Id='Idolrex:BAAALgAECgIJAwAAAA==.',
In='Insight:BAAALgAECgYJCwABLgAECggJEgABAAAAAA==.',
Is='Iskra:BAAALgAECgMJBQAAAA==.',
Ju='Justfairy:BAAALgADCgYJBwAAAA==.',
Ko='Kowalski:BAAALgAECgEJAQAAAA==.',
Kr='Kristina:BAAALgAECgcJBgAAAA==.',
Ku='Kurumiqaq:BAAALgAFFAEJAQAAAA==.',
Ma='Marsa:BAAALgAECgIJAgAAAA==.Masaka:BAAALgAECgEJAgABLgAFFAMJBAABAAAAAA==.',
Mo='Morningstars:BAAALgAECgcJEgAAAA==.Morningsttar:BAAALgADCgYJCgAAAA==.',
Mu='Muggle:BAAALgAECgEJAQAAAA==.',
Na='Namo:BAAALgAECgYJDQAAAA==.Nanu:BAABLgAFFH8FAAIHAAIJfSE8EADJAAAHAAIJfSE8EADJAAABLgAFFAMJBAABAAAAAA==.Naru:BAAALgAECgYJBgAAAA==.',
Ni='Niko:BAAALgAECgEJAQAAAA==.',
Nu='Nunsuran:BAAALgAECgcJCgAAAA==.',
Od='Odliabeverly:BAAALgADCgUJBgAAAA==.',
Or='Orio:BAAALgAECgQJBgAAAA==.',
Pr='Pride:BAAALgADCgEJAQAAAA==.',
Pu='Pupu:BAAALgADCgEJAQAAAA==.',
Ra='Rabbitsoup:BAAALgAECgMJAwAAAA==.Rainyblue:BAAALgADCgEJAQAAAA==.',
Re='Reisen:BAAALgAECgQJCAAAAA==.',
Se='Serpent:BAABLgAFFH8RAAMIAAYJXiM1AAAhAgAIAAYJXiM1AAAhAgAJAAEJ2hX4FwA7AAAAAA==.',
Sh='Shiyvzz:BAAALgAECgYJCAAAAA==.',
Si='Silithushero:BAAALgAFFAEJAQAAAA==.',
Sk='Skyarlet:BAABLgAECn8VAAIKAAgJ/xeeCgCuAQAKAAgJ/xeeCgCuAQAAAA==.',
Sn='Snowshadow:BAACLgAFFH8FAAILAAMJ8g8HIgD8AAALAAMJ8g8HIgD8AAAuAAQKfykAAwsACAnNIZ4PAP0CAAsACAnNIZ4PAP0CAAwABAlTFYUvAP0AAAAA.',
So='Soulhand:BAAALgAECgEJAQAAAA==.',
To='Toadflax:BAAALgAECgUJCAAAAA==.',
Un='Unakabeverly:BAAALgADCgYJCAAAAA==.Unionberlin:BAAALgAECgEJAQAAAA==.',
We='Westham:BAAALgAECgEJAQAAAA==.',
Yu='Yunll:BAAALgADCgIJAgAAAA==.',
Yz='Yzs:BAAALgADCgcJBwAAAA==.',
['一个']='一个猎手:BAACLgAFFH8FAAINAAMJjwVzAgDRAAANAAMJjwVzAgDRAAAuAAQKfxQAAw0ABwkFG4YUACwCAA0ABwkFG4YUACwCAAMAAwlxC8RQADEAAAAA.',
['一二']='一二年的劣人:BAAALgADCgEJAQAAAA==.',
['一叶']='一叶荣秋:BAAALgAECgEJAgAAAA==.',
['一壳']='一壳转:BAAALgAECgEJAQAAAA==.',
['一把']='一把匕首:BAAALgAECgUJBgAAAA==.',
['一重']='一重加害:BAAALgAFFAYJBAAAAA==.',
['万华']='万华镜:BAAALgAECgEJAQAAAA==.',
['万词']='万词王:BAABLgAFFH8FAAIOAAIJQwogGgCgAAAOAAIJQwogGgCgAAAAAA==.',
['三分']='三分糖吖嘿:BAAALgADCgEJAQAAAA==.',
['三花']='三花聚顶:BAAALgADCgEJAQAAAA==.',
['三重']='三重爱恋:BAAALgAFFAUJBAAAAA==.',
['不可']='不可说:BAAALgAFFAEJAwAAAA==.',
['不奶']='不奶:BAAALgAECgUJBQAAAA==.',
['不忘']='不忘:BAAALgADCgQJBAAAAA==.',
['东城']='东城亿潇湘:BAAALgAECgcJEwAAAA==.',
['中单']='中单美羊羊:BAAALgADCgIJAgAAAA==.',
['中心']='中心脚回旋踢:BAAALgADCgIJAgAAAA==.',
['中郎']='中郎将丶:BAAALgAECgQJAgAAAA==.',
['丶依']='丶依旧:BAAALgAFFAIJAgAAAA==.',
['丶海']='丶海山了丶:BAAALgADCgcJCQAAAA==.',
['丶飘']='丶飘:BAAALgAECgIJAwAAAA==.',
['丷冰']='丷冰冰牛:BAAALgAECgYJBgAAAA==.',
['丷花']='丷花開富貴丷:BAABLgAECn8WAAIGAAkJLhAgNACtAQAGAAkJLhAgNACtAQAAAA==.',
['九妖']='九妖恶魔:BAAALgAECgQJBAAAAA==.',
['二十']='二十纯情人夫:BAAALgAFFAQJAwAAAA==.',
['二号']='二号蛋:BAABLgAFFH8GAAIMAAMJgxyzBQAVAQAMAAMJgxyzBQAVAQAAAA==.',
['二重']='二重变革:BAAALgAFFAYJAgABLgAFFAYJBQAHAHYbAA==.',
['五月']='五月三:BAAALgAECgYJCAAAAA==.',
['井九']='井九:BAAALgADCgQJBAAAAA==.',
['亢奋']='亢奋的劳资:BAAALgADCgUJBQAAAA==.',
['伊芙']='伊芙琳:BAAALgAECgQJBQAAAA==.',
['低调']='低调德奢华:BAAALgAECgEJAQAAAA==.低调的阿凯:BAAALgAECgcJBwAAAA==.',
['佐佴']='佐佴:BAAALgAECgYJBgAAAA==.',
['你不']='你不要哇哇叫:BAAALgAECgQJBgAAAA==.',
['你丑']='你丑丶我瞎:BAAALgAECgEJAQAAAA==.',
['你叫']='你叫我小王吧:BAAALgAECgcJDQAAAA==.',
['你看']='你看咩啊:BAAALgAECgYJCgAAAA==.',
['你踏']='你踏么风了:BAAALgAECgQJDAAAAA==.',
['依然']='依然湛蓝:BAAALgAECgYJBgAAAA==.',
['假面']='假面具:BAAALgAFFAIJAgAAAA==.',
['偌灬']='偌灬舞清風:BAAALgAECgEJAQAAAA==.',
['偶然']='偶然威震天:BAABLgAFFH8FAAMGAAIJUAngCQCIAAAGAAIJUAngCQCIAAACAAEJmQG+OgBBAAAAAA==.偶然惊破天:BAABLgAFFH8HAAIPAAMJ4APwBwCpAAAPAAMJ4APwBwCpAAAAAA==.偶然熊抱:BAAALgADCgUJBQAAAA==.偶然解臾:BAAALgAFFAIJAgAAAA==.',
['克鲁']='克鲁:BAAALgAECgcJCAAAAA==.',
['八载']='八载鱿鱼:BAAALgAECgcJBwAAAA==.',
['六一']='六一:BAABLgAECn8VAAIFAAYJjxoHhgDFAQAFAAYJjxoHhgDFAQAAAA==.',
['六根']='六根不静:BAAALgAECgYJDAAAAA==.',
['六载']='六载鱿鱼:BAAALgAECgkJCgAAAA==.',
['六重']='六重不忠:BAAALgAFFAUJBAAAAA==.',
['兰陵']='兰陵撩乱:BAAALgADCgUJBQAAAA==.',
['兵长']='兵长砍猴:BAAALgADCgMJAwAAAA==.',
['其实']='其实我不懒:BAAALgAECgEJAQAAAA==.',
['典狱']='典狱长的缰绳:BAAALgAECgkJCQAAAA==.',
['冥月']='冥月情殇:BAAALgADCgYJBgAAAA==.',
['冰火']='冰火双重天:BAAALgAECgYJCgAAAA==.',
['冷门']='冷门歌手:BAAALgAECgcJBgAAAA==.',
['凌丶']='凌丶晨:BAAALgAECgMJAwAAAA==.',
['凌晨']='凌晨三点的牛:BAABLgAECn8cAAMQAAgJ7ha8CgD5AQAQAAgJ7ha8CgD5AQARAAEJdAYpFgAlAAAAAA==.',
['初号']='初号蛋:BAABLgAFFH8GAAMMAAMJSBPhBgADAQAMAAMJSBPhBgADAQALAAEJcwQQTABOAAAAAA==.',
['初音']='初音未来:BAAALgAECgYJBgAAAA==.',
['别把']='别把仓鼠惹毛:BAAALgAECgYJCgAAAA==.',
['加速']='加速同调:BAAALgAECgEJAQAAAA==.',
['匿名']='匿名小晗:BAABLgAECn8ZAAMIAAgJUBc7TgAIAgAIAAgJNhc7TgAIAgAJAAQJxxEQLADeAAAAAA==.',
['十五']='十五号蛋:BAAALgAFFAQJBAAAAA==.',
['十児']='十児丶晓:BAAALgAECgMJBAAAAA==.',
['十六']='十六号蛋:BAAALgAFFAQJAwAAAA==.',
['千颂']='千颂伊:BAAALgADCgMJAwAAAA==.',
['升级']='升级王:BAAALgAECgIJAgAAAA==.',
['半夏']='半夏丶:BAABLgAECn8UAAICAAcJTBY4WQDXAQACAAcJTBY4WQDXAQAAAA==.',
['卓尔']='卓尔卡德:BAAALgAECgMJAwABLgAFFAIJAgABAAAAAA==.',
['卖核']='卖核弹丨女孩:BAAALgAECgcJCgAAAA==.',
['南天']='南天群星:BAAALgAECgEJAQAAAA==.',
['南宮']='南宮恨:BAAALgAFFAIJAgAAAA==.',
['南山']='南山忆:BAAALgAECgQJBAAAAA==.',
['卡农']='卡农丶:BAAALgAECgcJCAAAAA==.',
['卡辛']='卡辛:BAAALgADCgQJBAAAAA==.',
['卡门']='卡门:BAAALgAFFAEJAQAAAA==.',
['却又']='却又无法:BAAALgAFFAMJAgAAAA==.',
['卷卷']='卷卷:BAAALgAECgEJAQAAAA==.',
['双剑']='双剑滑铲:BAABLgAFFH8HAAIIAAMJyBuRIAAXAQAIAAMJyBuRIAAXAQAAAA==.',
['古尔']='古尔单:BAAALgADCgMJAwAAAA==.',
['叫我']='叫我胖爷:BAAALgAFFAMJBAAAAA==.',
['可乐']='可乐咧丶:BAABLgAFFH8FAAMOAAMJYQ0DGQClAAAOAAIJKw0DGQClAAAQAAEJyw0AAAAAAAAAAA==.',
['可口']='可口岩真好吃:BAABLgAFFH8HAAISAAMJlRqPFgCjAAASAAMJlRqPFgCjAAAAAA==.',
['叶尔']='叶尔:BAAALgAECgYJDwAAAA==.',
['吃我']='吃我一刀:BAAALgAECgYJBwAAAA==.',
['君忘']='君忘歌:BAAALgAECgMJAwAAAA==.',
['君问']='君问何:BAAALgADCgEJAQAAAA==.',
['含蛋']='含蛋超人:BAAALgAECgYJDAAAAA==.',
['吾即']='吾即天命喵:BAAALgAECgUJBgAAAA==.',
['吾愿']='吾愿已达:BAAALgAECgUJCAAAAA==.',
['呀呀']='呀呀鸭梨:BAAALgAECgIJAgAAAA==.',
['呀哈']='呀哈哈:BAAALgADCgEJAQAAAA==.',
['咸鱼']='咸鱼的滋味:BAAALgAECgQJBAAAAA==.',
['哆啦']='哆啦批梦:BAABLgAFFH8IAAMQAAQJwRb6AQBjAQAQAAQJwBb6AQBjAQAOAAEJyQGBJQBIAAAAAA==.',
['哇丶']='哇丶咔咔:BAAALgAECgQJCAAAAA==.',
['哈基']='哈基骨:BAAALgAECgcJDgAAAA==.',
['哒拉']='哒拉嘣吧:BAAALgAFFAIJAwAAAA==.',
['哪个']='哪个小的:BAAALgADCgQJBQAAAA==.哪个武僧:BAAALgADCgEJAQAAAA==.',
['哼唱']='哼唱的真波希:BAAALgAECgEJAQAAAA==.',
['唐门']='唐门暗影狐:BAAALgADCgcJBwAAAA==.',
['唯灬']='唯灬美:BAAALgAECgcJCgAAAA==.',
['啊丶']='啊丶多茤:BAAALgAECgUJBQAAAA==.',
['單戀']='單戀一支花:BAAALgAECgcJBwAAAA==.',
['喵了']='喵了个喵:BAAALgAECgEJAQAAAA==.',
['喵哥']='喵哥:BAAALgADCgUJBQAAAA==.喵哥丨起飞:BAAALgAECgUJBQAAAA==.',
['喵头']='喵头夏咕咕:BAAALgAECgQJBAAAAA==.',
['四重']='四重罪孽:BAAALgAFFAYJBAAAAA==.',
['图腾']='图腾丶建筑师:BAAALgAECgcJBgAAAA==.',
['圣光']='圣光永存:BAAALgAECgMJAwAAAA==.',
['圣言']='圣言庇护:BAABLgAECn8UAAITAAcJWhugFgAyAgATAAcJWhugFgAyAgAAAA==.',
['坏蛋']='坏蛋小妩媚:BAAALgAECgMJAwAAAA==.',
['基尔']='基尔加蛋:BAAALgAECgMJAwAAAA==.',
['塔萨']='塔萨里奥斯:BAAALgAECgcJEQAAAA==.',
['塞勒']='塞勒妮:BAAALgAECgYJBgAAAA==.塞勒斯汀:BAAALgAECgYJCQAAAA==.',
['夜丶']='夜丶天秀:BAAALgAECgMJAwAAAA==.夜丶血杀:BAABLgAFFH8IAAIJAAMJ/QveBQCwAAAJAAMJ/QveBQCwAAAAAA==.',
['夜污']='夜污蛋:BAAALgAECgIJAgABLgAFFAMJCAAJAP0LAA==.',
['夜顾']='夜顾丨赞堂:BAAALgAECgQJBAAAAA==.',
['夜鸦']='夜鸦:BAABLgAFFH8LAAIEAAQJByLBBAChAQAEAAQJByLBBAChAQAAAA==.',
['夢丶']='夢丶埖开埖谢:BAAALgAECgQJBAAAAA==.',
['大熊']='大熊貓麻婆:BAAALgADCgEJAQAAAA==.',
['大禹']='大禹治水:BAAALgAECgQJBAAAAA==.',
['大陈']='大陈皮丶:BAAALgAECgcJBwAAAA==.',
['天下']='天下無賊:BAABLgAFFH8HAAIUAAMJJBGpDAD9AAAUAAMJJBGpDAD9AAAAAA==.',
['天堂']='天堂丿在左:BAAALgADCgYJBwAAAA==.',
['天竺']='天竺葵烟雨:BAAALgADCgYJBgAAAA==.',
['太白']='太白醉月:BAAALgAECgEJAQAAAA==.',
['奀猪']='奀猪:BAAALgAECgUJBgAAAA==.',
['奇兰']='奇兰苹果杏:BAAALgAFFAEJAQAAAA==.',
['奔放']='奔放的沫沫:BAAALgAECgEJAQAAAA==.',
['奔雷']='奔雷手文泰莱:BAAALgADCgQJBAAAAA==.',
['女子']='女子又隹:BAAALgAECgcJEQAAAA==.女子米唐:BAAALgAECgUJCAAAAA==.',
['女德']='女德:BAAALgADCgUJBQAAAA==.',
['女王']='女王丶希尔瓦:BAAALgAFFAEJAQAAAA==.女王大人呀:BAAALgAECggJEgAAAA==.女王大人哟:BAAALgAECgQJBAABLgAECggJEgABAAAAAA==.',
['奶爆']='奶爆你的肺:BAAALgADCgEJAQAAAA==.',
['如如']='如如不動:BAACLgAFFH8KAAIRAAQJ7wTdBwDgAAARAAQJ7wTdBwDgAAAuAAQKfyAAAhEACAleDI4ZAIQBABEACAleDI4ZAIQBAAAA.',
['姐夫']='姐夫我好热:BAABLgAECn8jAAIFAAcJbh1mQAB4AgAFAAcJbh1mQAB4AgAAAA==.',
['媳妇']='媳妇养的猫:BAAALgAFFAEJAQAAAA==.',
['宅之']='宅之北:BAAALgAFFAMJAwAAAA==.',
['寂小']='寂小酌丶地坤:BAAALgADCgYJBgAAAA==.',
['寂滅']='寂滅红尘:BAAALgAECgEJAgAAAA==.',
['寒曦']='寒曦:BAAALgAFFAQJAQAAAA==.',
['小喇']='小喇丶叭:BAAALgAECgEJAQABLgAECgQJBAABAAAAAA==.',
['小奶']='小奶咪:BAAALgAECgYJDgAAAA==.',
['小小']='小小咲:BAAALgAECgcJEAAAAA==.小小贴纸:BAAALgADCgMJAwAAAA==.',
['小恶']='小恶魔的德:BAABLgAECn8WAAQKAAYJDyGGLwDuAQAKAAYJDyGGLwDuAQAVAAQJfwRvawByAAAWAAMJ0wSEKQBUAAAAAA==.',
['小晚']='小晚星:BAAALgAECgYJBgAAAA==.',
['小橡']='小橡皮:BAAALgAECgYJCwAAAA==.',
['小灰']='小灰类类:BAAALgAFFAEJAgAAAA==.',
['小点']='小点心:BAAALgAECgMJBQAAAA==.',
['小熊']='小熊馋:BAAALgAECgkJCQAAAA==.',
['小短']='小短腿:BAAALgAECgEJAQAAAA==.',
['小肉']='小肉圆:BAAALgAECgYJBgAAAA==.',
['小贴']='小贴纸:BAAALgADCgEJAQAAAA==.',
['小龙']='小龙人的秘密:BAAALgAECgYJBgAAAA==.小龙囡囡:BAAALgAECgYJCwABLgAFFAMJCAADAEwkAA==.',
['少年']='少年派:BAAALgAECgEJAgAAAA==.',
['尤格']='尤格薩龍:BAAALgAECgYJDAAAAA==.',
['就叫']='就叫你跳跳虎:BAAALgAECgYJBgAAAA==.',
['屠神']='屠神灬:BAAALgAFFAUJAQAAAA==.',
['岱宗']='岱宗夫如何:BAAALgAECgEJAQAAAA==.',
['崶漾']='崶漾:BAAALgAFFAEJAQAAAA==.',
['左青']='左青龙右白虎:BAAALgADCgIJAgAAAA==.',
['巨熊']='巨熊馋:BAAALgAECgEJAQAAAA==.',
['巨锤']='巨锤:BAABLgAECn8gAAMXAAcJfRMkJgCMAQAXAAcJfRMkJgCMAQAYAAYJTQt2IAApAQAAAA==.',
['巭匚']='巭匚呆:BAAALgAECgYJCgAAAA==.',
['巭呆']='巭呆呆:BAAALgAECgEJAgAAAA==.',
['巭水']='巭水手:BAAALgAECgEJAQAAAA==.',
['幕丶']='幕丶姬:BAAALgAECgIJBAAAAA==.',
['幻之']='幻之轨迹:BAABLgAECn8VAAICAAYJ2iTHCAD+AQACAAYJ2iTHCAD+AQAAAA==.',
['床边']='床边的叫声:BAAALgAECgUJAQAAAA==.',
['康辰']='康辰灬:BAAALgAECgEJAQAAAA==.',
['开心']='开心牛牛:BAAALgAECgUJBQAAAA==.',
['开膛']='开膛手比利洪:BAAALgAECgMJAwAAAA==.',
['影之']='影之实力者:BAAALgAFFAEJAQAAAA==.',
['征服']='征服者茵塔尔:BAAALgADCgEJAQAAAA==.',
['很萌']='很萌很温柔:BAAALgAECgEJAQAAAA==.',
['微光']='微光一刀炼狱:BAABLgAECn8bAAIIAAgJByPjEAAXAwAIAAgJByPjEAAXAwAAAA==.',
['快到']='快到碗里去:BAAALgADCgEJAQAAAA==.',
['性质']='性质特别恶劣:BAAALgAECgEJAQAAAA==.',
['恐怖']='恐怖血狼:BAAALgAECgcJDAAAAA==.',
['恐龙']='恐龙有点发愁:BAAALgAECgYJCwAAAA==.',
['慕容']='慕容溪:BAAALgADCgEJAQAAAA==.',
['我不']='我不是惩戒骑:BAAALgAECgUJBgAAAQ==.',
['我对']='我对你唔住:BAAALgAECgQJBQAAAA==.',
['我是']='我是萌新:BAAALgADCgEJAQAAAA==.',
['我智']='我智力很正常:BAAALgAFFAEJAQAAAA==.我智力没问题:BAACLgAFFH8FAAIPAAQJBxuVBgBcAQAPAAQJBxuVBgBcAQAuAAQKf3cAAg8ACQnGJCQBAJ0DAA8ACQnGJCQBAJ0DAAAA.',
['战神']='战神柒:BAABLgAFFH8FAAIGAAMJphXFEgCyAAAGAAMJphXFEgCyAAAAAA==.战神肆:BAAALgAECgkJCgAAAA==.',
['战胜']='战胜风云:BAAALgAECgYJCwAAAA==.',
['手持']='手持太古杨弓:BAAALgAECgYJDQAAAA==.',
['才徐']='才徐坤:BAAALgAECgMJBAAAAA==.',
['扮咕']='扮咕吃老虎:BAAALgAECgIJAgAAAA==.',
['抹茶']='抹茶奶昔:BAAALgADCgUJBgAAAA==.',
['拉爾']='拉爾娅:BAAALgAECgYJCQAAAA==.',
['拔了']='拔了毛的鹌鹑:BAAALgAECgIJAgAAAA==.',
['拜拜']='拜拜你条尾:BAAALgAECgIJAgAAAA==.',
['拾四']='拾四赴春约:BAAALgAECgIJAgAAAA==.',
['捻芯']='捻芯:BAAALgAECgQJBQAAAA==.',
['提里']='提里奥佛丁:BAAALgAECgcJDAAAAA==.',
['搁浅']='搁浅灬:BAAALgAFFAIJAgAAAA==.',
['文咏']='文咏珊:BAAALgAECgEJAQAAAA==.',
['文森']='文森拉罗:BAABLgAFFH8GAAICAAMJFh3SEQAXAQACAAMJFh3SEQAXAQABLgAFFAMJBQAZAAAjAA==.',
['斯科']='斯科拉:BAAALgAECgEJAQAAAA==.',
['方大']='方大毛:BAAALgAECgkJCQAAAA==.',
['无垠']='无垠星空:BAAALgAFFAQJBAAAAA==.',
['无处']='无处话凄凉:BAAALgAECggJDwAAAA==.',
['无尽']='无尽夏:BAAALgADCgUJBQAAAA==.',
['无敌']='无敌模式:BAAALgAECgQJBAAAAA==.',
['无聊']='无聊的小弓:BAAALgAECgEJAQAAAA==.',
['日落']='日落:BAABLgAFFH8IAAICAAMJbA1pCwDlAAACAAMJbA1pCwDlAAAAAA==.',
['昂立']='昂立一号:BAAALgAFFAEJAQAAAA==.昂立十号:BAAALgAECgIJAgAAAA==.',
['明日']='明日香:BAAALgAECgEJAQAAAA==.',
['昕匀']='昕匀:BAABLgAECn8dAAIKAAcJ4AvFZAAjAQAKAAcJ4AvFZAAjAQAAAA==.',
['春花']='春花秋月:BAAALgAECgYJCQAAAA==.',
['春雨']='春雨不解忧:BAAALgADCgQJBwAAAA==.',
['春风']='春风吹酒醒:BAAALgAFFAIJAgAAAA==.',
['晚星']='晚星:BAAALgAECgQJBQAAAA==.',
['普莉']='普莉梅拉:BAAALgADCgEJAQAAAA==.',
['晴诗']='晴诗:BAAALgAECgcJBwAAAA==.',
['暴走']='暴走丶初号机:BAABLgAFFH8FAAIRAAUJWQvIAwBMAQARAAUJWQvIAwBMAQAAAA==.暴走丶初號機:BAABLgAFFH8KAAIRAAUJJwraBAAqAQARAAUJJwraBAAqAQAAAA==.暴走初號機:BAAALgAECgEJAQAAAA==.暴走大龙:BAAALgAECgYJCwAAAA==.暴走狂龙:BAAALgAECgIJAgAAAA==.暴走的牛肉丸:BAAALgAECgEJAQAAAA==.',
['暴风']='暴风箭雨:BAAALgAECgIJBAAAAA==.',
['曈丶']='曈丶:BAAALgAECgkJCQAAAA==.',
['月光']='月光影子:BAAALgAECgcJEAAAAA==.',
['月影']='月影之殇:BAAALgAECgEJAQAAAA==.',
['有吃']='有吃有喝有玩:BAAALgAECgEJAQAAAA==.',
['有时']='有时花开丶:BAAALgAECgYJCQAAAA==.',
['朕不']='朕不给不能抢:BAAALgAECgkJCQAAAA==.',
['期待']='期待经典:BAAALgAECgMJAwAAAA==.',
['未来']='未来重启:BAAALgAECgEJAQAAAA==.',
['本源']='本源:BAAALgADCgcJBwAAAA==.',
['术爷']='术爷讲武德:BAAALgAECgcJBwAAAA==.',
['杀手']='杀手皇后:BAAALgAECgYJBgAAAA==.',
['李雅']='李雅雅酱:BAAALgADCgcJBwAAAA==.',
['杰哈']='杰哈德:BAAALgADCgEJAQAAAA==.',
['杰森']='杰森斯坦僧:BAAALgAFFAIJBAAAAA==.',
['松本']='松本乱菊:BAAALgADCgEJAQAAAA==.',
['枯叶']='枯叶纷飞:BAAALgAECgkJCQAAAA==.',
['柒大']='柒大宝:BAAALgAECgQJBgAAAA==.',
['柚柚']='柚柚:BAAALgAECgEJAQAAAA==.',
['标丶']='标丶杆:BAAALgAECgIJAwAAAA==.',
['校书']='校书郎丨:BAAALgAECgYJBgAAAA==.',
['栤鈥']='栤鈥天:BAAALgADCgYJBwAAAA==.',
['核弹']='核弹丨超人:BAAALgAECgQJBAAAAA==.',
['桂林']='桂林好奇宝宝:BAAALgAFFAEJAgAAAA==.',
['梨涡']='梨涡浅浅:BAABLgAFFH8IAAMKAAQJwgVmFQC4AAAKAAMJLQZmFQC4AAAVAAIJ3w51FACgAAAAAA==.',
['梨笙']='梨笙笙:BAAALgAECgYJCgAAAA==.',
['梵炎']='梵炎:BAAALgAECgcJEwAAAA==.',
['椒盐']='椒盐皮皮熊:BAAALgADCgMJAwAAAA==.',
['椰香']='椰香棉花糖:BAAALgADCgcJCAAAAA==.',
['楠风']='楠风吐月:BAAALgADCgEJAQAAAA==.',
['樂逍']='樂逍遙:BAAALgAECgMJAwAAAA==.',
['橘橘']='橘橘仔:BAAALgAECgMJAwAAAA==.橘橘只:BAAALgADCgUJBQAAAA==.',
['橙心']='橙心橙意苹果:BAAALgADCgcJCgAAAA==.',
['檀香']='檀香依旧:BAAALgAECgEJAQAAAA==.',
['欧皇']='欧皇:BAAALgAECgQJBQAAAA==.',
['正趣']='正趣果上果:BAAALgAECgMJBAAAAA==.',
['武臻']='武臻:BAAALgAECgYJEAAAAA==.',
['死亡']='死亡再临:BAAALgAFFAEJAQAAAA==.死亡叹息:BAACLgAFFH8GAAIIAAMJqha8MADKAAAIAAMJqha8MADKAAAuAAQKfxsAAggABgnFIwYzAGsCAAgABgnFIwYzAGsCAAEuAAUUBAkGAAgASiAA.',
['死大']='死大个子:BAABLgAFFH8OAAIEAAQJHSVrAACwAQAEAAQJHSVrAACwAQAAAA==.死大个子哟:BAACLgAFFH8FAAINAAIJ8SVyBgDkAAANAAIJ8SVyBgDkAAAuAAQKfxYAAg0ABwlbJVsJAMwCAA0ABwlbJVsJAMwCAAAA.',
['毁灭']='毁灭箭:BAAALgADCgcJBwAAAA==.',
['毒敌']='毒敌大王:BAAALgAFFAIJAwAAAA==.',
['水原']='水原希子:BAAALgAECgEJAQAAAA==.',
['汉尼']='汉尼拔:BAAALgAECgYJBwAAAA==.',
['汤姆']='汤姆哈迪:BAAALgAECgMJAwAAAA==.',
['沉沦']='沉沦的记忆:BAAALgAECgQJBQAAAA==.',
['沙尘']='沙尘暗云海:BAAALgAECgYJBgAAAA==.',
['油泼']='油泼辣子忄:BAAALgAECgEJAQAAAA==.',
['法神']='法神索托斯:BAAALgADCgMJAwAAAA==.',
['泪汪']='泪汪汪:BAABLgAFFH8HAAIDAAQJ3hLtCAAnAQADAAQJ3hLtCAAnAQAAAA==.',
['洗浴']='洗浴上二楼:BAAALgAECgMJAwAAAA==.',
['流光']='流光掠逝:BAABLgAECn8bAAIaAAgJ3yAKBgCMAgAaAAgJ3yAKBgCMAgAAAA==.',
['浑元']='浑元大咕咕:BAAALgADCgIJAgAAAA==.',
['混元']='混元一气:BAAALgADCgYJCAAAAA==.',
['清良']='清良:BAAALgAFFAIJAgAAAA==.',
['清莲']='清莲:BAAALgAECgYJBwAAAA==.',
['温顺']='温顺的牛肉人:BAAALgAECgkJDwAAAA==.',
['滥竽']='滥竽充术:BAAALgAECgMJAwABLgAFFAYJEQAIACEbAA==.',
['滴滴']='滴滴答答:BAAALgAECgUJCAAAAA==.',
['漫宿']='漫宿无墙:BAAALgADCgQJBAAAAA==.',
['潘达']='潘达兮:BAAALgAECgMJBQAAAA==.',
['火冰']='火冰奥三修:BAAALgAECgYJDQAAAA==.',
['灵感']='灵感大王:BAABLgAECn8XAAQbAAcJnRvANQCPAQAbAAYJpBbANQCPAQAUAAYJbhxIuwBMAAAcAAEJHQQAAAAAAAAAAA==.',
['灵砂']='灵砂:BAAALgAECgEJAQAAAA==.',
['烈火']='烈火飞舞:BAAALgAECgcJEAAAAA==.',
['烟雨']='烟雨任平生:BAAALgAFFAIJAgAAAA==.烟雨彩蝶:BAAALgAECgQJBAAAAA==.',
['烬魂']='烬魂:BAAALgAFFAQJBAAAAA==.',
['無名']='無名:BAAALgAECgEJAgAAAA==.',
['煎饺']='煎饺:BAAALgAECgcJDgAAAA==.',
['熊猫']='熊猫人:BAAALgAECgYJBgAAAA==.熊猫打醉拳:BAAALgADCgQJBAAAAA==.',
['爆炒']='爆炒丸子丶:BAAALgAECgQJCAAAAA==.',
['爱洛']='爱洛:BAAALgAECgEJAgAAAA==.',
['牛牛']='牛牛爱眼泪:BAAALgAECgYJBgAAAA==.',
['牧云']='牧云:BAAALgAECgQJBAAAAA==.',
['牧市']='牧市:BAAALgAECgQJBQAAAA==.',
['牧面']='牧面具:BAAALgAECgYJCQAAAA==.',
['特级']='特级花茶丶:BAAALgADCgIJAgAAAA==.',
['狂奔']='狂奔的萨满:BAAALgAECgMJBAAAAA==.',
['狂徒']='狂徒夜磨刀:BAAALgAECgIJAQAAAA==.',
['狂野']='狂野的老母牛:BAAALgAECgkJDwAAAA==.',
['狗二']='狗二蛋彦祖:BAAALgADCgEJAQAAAA==.',
['独自']='独自去兜风:BAABLgAFFH8HAAIcAAIJKBj5AwC2AAAcAAIJKBj5AwC2AAAAAA==.',
['猪突']='猪突猛进:BAAALgAECgEJAQAAAA==.',
['王三']='王三:BAAALgAECgkJEAAAAA==.',
['王楚']='王楚然:BAAALgAECgUJBAAAAA==.',
['甲乙']='甲乙木:BAAALgADCgMJAwAAAA==.',
['电视']='电视机:BAAALgAFFAEJAQABLgAFFAMJCAAJAP0LAA==.',
['电面']='电面具:BAABLgAFFH8FAAISAAIJyhRYFwCfAAASAAIJyhRYFwCfAAAAAA==.',
['番茄']='番茄鱼丸汤:BAABLgAFFH8LAAMDAAQJxxQKEwA5AQADAAQJxxQKEwA5AQANAAEJdQKPDwBFAAAAAA==.',
['白羽']='白羽丶翎:BAAALgAECgIJAgAAAA==.',
['白薪']='白薪焰火:BAAALgAECgcJEwAAAA==.',
['白银']='白银诺艾尔丶:BAABLgAECn8XAAICAAcJTxj2PAAwAgACAAcJTxj2PAAwAgAAAA==.',
['白雾']='白雾:BAAALgAFFAIJAgAAAA==.',
['盛世']='盛世牛马:BAAALgAECgIJAgAAAA==.',
['盲人']='盲人按摩技师:BAAALgAECgIJAgAAAA==.',
['真的']='真的很无敌:BAAALgAECgEJAQAAAA==.',
['砮皂']='砮皂寺酒仙:BAABLgAECn8VAAQdAAYJCRxIKwCyAQAdAAYJCRxIKwCyAQAeAAEJ6Ab4fQAyAAAPAAEJNgdgcQAjAAAAAA==.',
['祖祖']='祖祖不会奶:BAAALgADCgIJAgAAAA==.祖祖大魔王:BAAALgADCgcJBwAAAA==.',
['神圣']='神圣干涉:BAAALgAECgUJBQAAAA==.',
['神煌']='神煌冰璃:BAAALgAECgUJBwAAAA==.',
['秋歌']='秋歌夜带刀:BAAALgAECgcJDgAAAA==.',
['窝窝']='窝窝三一:BAAALgAFFAYJBAAAAA==.窝窝三三:BAABLgAFFH8GAAIHAAYJyA/vAAD3AQAHAAYJyA/vAAD3AQAAAA==.窝窝三九:BAAALgAFFAQJBAAAAA==.窝窝三二:BAAALgAFFAYJBAAAAA==.窝窝三五:BAAALgAFFAYJAgAAAA==.窝窝三六:BAAALgAFFAYJAQAAAA==.窝窝三四:BAABLgAFFH8GAAIHAAYJYRQIAgCpAQAHAAYJYRQIAgCpAQAAAA==.',
['竹筏']='竹筏猫:BAAALgAECgEJAQAAAA==.',
['第十']='第十区拉温妮:BAAALgAECgEJAQAAAA==.',
['粉皮']='粉皮玩红豹:BAAALgAECgQJBAAAAA==.',
['粉粉']='粉粉的白猫:BAAALgADCgcJBwAAAA==.',
['粪叉']='粪叉:BAAALgAECgYJCQAAAA==.',
['糖朵']='糖朵朵:BAAALgAECgYJCAAAAA==.',
['糖醋']='糖醋排骨丶:BAABLgAECn8ZAAILAAYJrxz4XgCsAQALAAYJrxz4XgCsAQAAAA==.',
['糖门']='糖门滚:BAAALgAECgQJCAAAAA==.',
['糯叽']='糯叽叽丷:BAAALgAECgMJAwAAAA==.',
['素星']='素星:BAAALgAECgUJBQAAAA==.',
['索尔']='索尔格林:BAAALgAFFAIJAgAAAA==.',
['紫轩']='紫轩炎:BAAALgAECgcJBwAAAA==.',
['繼國']='繼國缘一:BAABLgAFFH8SAAIIAAYJpySfAABnAgAIAAYJpySfAABnAgAAAA==.',
['纯妹']='纯妹妹:BAAALgADCgYJBgAAAA==.',
['纯白']='纯白给:BAABLgAFFH8QAAICAAUJTRWJCwBPAQACAAUJTRWJCwBPAQAAAA==.',
['纳格']='纳格兰雪珞:BAAALgAECgEJAQAAAA==.',
['细路']='细路囡丶:BAAALgAECgEJAQAAAA==.',
['缺德']='缺德请找我:BAABLgAECn8WAAIWAAgJIAghGwDRAAAWAAgJIAghGwDRAAAAAA==.',
['罪与']='罪与爱同歌:BAABLgAFFH8FAAIHAAUJdhuNAwDAAQAHAAUJdhuNAwDAAQAAAA==.',
['羊达']='羊达内:BAAALgAECgQJBgAAAA==.',
['翻师']='翻师傅:BAAALgAECgIJAgAAAA==.',
['老子']='老子就不上班:BAAALgAECgQJBQAAAA==.',
['老衲']='老衲信耶酥:BAAALgAECgYJBgAAAA==.',
['耶熊']='耶熊:BAAALgAECgEJAQAAAA==.',
['肘小']='肘小肘:BAACLgAFFH8MAAIRAAQJ8STKAQC4AQARAAQJ8STKAQC4AQAuAAQKfxkAAhEACAlXJVsCAEgDABEACAlXJVsCAEgDAAAA.',
['胡巨']='胡巨炮:BAAALgAECgMJAwAAAA==.',
['胧月']='胧月夜:BAAALgAECgYJBgAAAA==.',
['能扛']='能扛能打能加:BAAALgADCgIJAgAAAA==.',
['臭臭']='臭臭狼大人:BAAALgAECgQJBAAAAA==.',
['舞小']='舞小风:BAAALgAECgEJAQAAAA==.',
['舞风']='舞风:BAAALgAECgEJAQAAAA==.',
['花与']='花与爱丽丝:BAAALgAECgkJEAAAAA==.',
['花丶']='花丶忆白:BAAALgAECgUJBgAAAA==.',
['花京']='花京院:BAABLgAFFH8FAAICAAMJjRRjCQABAQACAAMJjRRjCQABAQAAAA==.',
['苍穹']='苍穹之泪:BAAALgAFFAEJAQAAAA==.',
['苏超']='苏超老曹:BAAALgAECgQJCAAAAA==.',
['若曦']='若曦丶莫相離:BAAALgAECgYJEgAAAA==.',
['苹果']='苹果熊:BAAALgADCgUJBQAAAA==.',
['茅台']='茅台酒中仙:BAABLgAFFH8FAAIdAAIJxQNLDQB8AAAdAAIJxQNLDQB8AAABLgAFFAMJCAAJAP0LAA==.',
['荒木']='荒木:BAABLgAFFH8FAAIZAAMJACPuBAA3AQAZAAMJACPuBAA3AQAAAA==.',
['荒野']='荒野庇护:BAABLgAECn8bAAMUAAcJFh9vCADiAQAbAAcJwhpwHgAvAgAUAAYJ1B9vCADiAQAAAA==.',
['荔夏']='荔夏:BAABLgAECn8XAAIPAAcJPBUwCgBLAQAPAAcJPBUwCgBLAQAAAA==.荔夏灬:BAAALgAECgcJBwAAAA==.荔夏的小鸭梨:BAABLgAECn8iAAMdAAgJEB3bFABlAgAdAAgJEB3bFABlAgAPAAQJ/xQbPAD3AAAAAA==.',
['荔小']='荔小夏:BAAALgAECgUJBQAAAA==.',
['莫听']='莫听穿林打叶:BAAALgAECgYJBgAAAA==.',
['莫提']='莫提斯:BAAALgAECgYJBgAAAA==.',
['莱阁']='莱阁拉斯:BAABLgAFFH8RAAIUAAUJfCM7AQCWAQAUAAUJfCM7AQCWAQAAAA==.',
['萌萌']='萌萌龘婋牝锅:BAAALgAECgEJAQAAAA==.',
['萨萨']='萨萨小白:BAAALgAECgEJAQAAAA==.',
['萱萱']='萱萱姐姐的狗:BAAALgAFFAIJAwAAAA==.',
['落日']='落日与晚风:BAAALgAECgUJBwAAAA==.',
['葡萄']='葡萄要甜丶:BAABLgAFFH8GAAILAAQJlxIOEgBVAQALAAQJlxIOEgBVAQAAAA==.',
['虚度']='虚度丿耀阳:BAAALgADCgEJAgAAAA==.',
['虚无']='虚无鲩:BAAALgAECgIJAwAAAA==.',
['虚空']='虚空精灵壹号:BAAALgAFFAUJBAAAAA==.',
['虫草']='虫草滑鸡周丶:BAABLgAECn8UAAICAAcJqx3eJQCPAgACAAcJqx3eJQCPAgABLgAFFAQJCwAIAIsfAA==.',
['蚂蚁']='蚂蚁鸭吼:BAAALgAFFAEJAQAAAA==.蚂蚁鸭哈:BAAALgAECgMJAwAAAA==.蚂蚁鸭哈哈:BAABLgAECn8jAAIPAAkJ6SSYAADBAwAPAAkJ6SSYAADBAwAAAA==.蚂蚁鸭嘿:BAAALgAFFAIJAgAAAA==.',
['被咬']='被咬的苹果:BAAALgAFFAEJAQAAAA==.',
['被怪']='被怪追着跑:BAAALgAECgYJCwAAAA==.',
['西腔']='西腔样子:BAAALgADCgMJAwAAAA==.',
['諾斯']='諾斯:BAABLgAECn8XAAMDAAgJZxT6VgCdAQADAAcJSRf6VgCdAQANAAYJfRPiLQBcAQAAAA==.',
['譚雅']='譚雅:BAAALgADCgcJBwAAAA==.',
['让三']='让三招:BAAALgAECgUJBQAAAA==.',
['该隐']='该隐:BAAALgADCgkJDwAAAA==.',
['诸葛']='诸葛龙一:BAAALgAECgUJBQAAAA==.',
['读书']='读书破万卷:BAACLgAFFH8JAAIeAAQJlRmeBgAQAQAeAAQJlRmeBgAQAQAuAAQKfxkAAh4ACAkyHQIOAJwCAB4ACAkyHQIOAJwCAAAA.',
['貓叔']='貓叔:BAAALgAECgcJBwAAAA==.',
['贫尼']='贫尼不还俗:BAAALgAECgQJBAAAAA==.',
['贼王']='贼王杀匕:BAAALgAECgMJAwAAAA==.',
['趁年']='趁年华丶:BAAALgAECgMJAwAAAA==.',
['超带']='超带感的大枪:BAAALgAECgEJAQAAAA==.',
['这个']='这个入是桂:BAAALgADCgUJBQAAAA==.',
['这是']='这是幻象:BAAALgAECgMJAwAAAA==.',
['迪奥']='迪奥球球:BAAALgAECgEJAQAAAA==.',
['逍遙']='逍遙之城:BAAALgAECgMJAwAAAA==.',
['遗忘']='遗忘末日:BAAALgADCgEJAQAAAA==.遗忘毁灭:BAAALgADCgcJBwAAAA==.',
['郑大']='郑大风:BAAALgAECgYJCQAAAA==.',
['酷酷']='酷酷冠希:BAACLgAFFH8PAAISAAUJDySzAAAaAgASAAUJDySzAAAaAgAuAAQKfxQAAhIACQnbH3UGAAsDABIACQnbH3UGAAsDAAEuAAUUBwkcAB8ARh4A.酷酷王的男人:BAABLgAFFH8QAAIFAAUJwxhQFwBsAQAFAAUJwxhQFwBsAQABLgAFFAcJHAAfAEYeAA==.酷酷百事可乐:BAACLgAFFH8cAAIfAAcJRh6BAACIAgAfAAcJRh6BAACIAgAuAAQKfyAAAx8ACQkeIxkBAIMDAB8ACQkeIxkBAIMDABcABAknIFMsAF4BAAAA.',
['醉卧']='醉卧夜聴雪:BAAALgAECgEJAQAAAA==.醉卧寰宇:BAABLgAFFH8KAAIdAAQJaw2JDQAZAQAdAAQJaw2JDQAZAQAAAA==.',
['醉酒']='醉酒之怒:BAAALgAECgQJBAAAAA==.',
['野元']='野元灬新之助:BAAALgAECgUJCAAAAA==.',
['野蛮']='野蛮小壳钻:BAAALgAECgMJAwAAAA==.',
['鉄牛']='鉄牛牛:BAAALgAECgcJBQAAAA==.',
['鍾愛']='鍾愛小北:BAAALgADCgUJBQAAAA==.',
['银月']='银月咏叹调:BAAALgADCgEJAQAAAA==.',
['锦绫']='锦绫:BAACLgAFFH8IAAMUAAMJcRLuCwADAQAUAAMJcRLuCwADAQAbAAEJZAmgKgBGAAAuAAQKfyUABBsACAl8IPYeACsCABsABwkQHvYeACsCABQABwmAHXgyAOYBABwABwncC4kFAHoBAAAA.',
['阿丶']='阿丶哆哆:BAAALgAFFAEJAQAAAA==.',
['阿凡']='阿凡提:BAAALgAECgMJAwAAAA==.',
['阿爾']='阿爾托利亞:BAAALgAECgEJAQAAAA==.',
['阿莱']='阿莱克西亚丶:BAAALgAECgEJAQAAAA==.',
['集合']='集合石牢头:BAAALgAECgcJBwAAAA==.',
['雨夜']='雨夜亲吻:BAAALgADCgIJAgAAAA==.',
['雪丶']='雪丶百合:BAAALgADCgIJAgAAAA==.',
['零号']='零号蛋:BAAALgAFFAQJBAAAAA==.',
['零度']='零度凛冬:BAAALgAECgYJBgAAAA==.',
['電擊']='電擊姬:BAAALgAECgMJBQAAAA==.',
['霜语']='霜语之歌:BAAALgAECgEJAQAAAA==.',
['霜风']='霜风些许:BAAALgADCgUJBQAAAA==.',
['靈厶']='靈厶封灵:BAAALgAECgYJDwAAAA==.',
['青丘']='青丘九尾:BAAALgAECgEJAQAAAA==.',
['青丶']='青丶蓝:BAACLgAFFH8FAAILAAIJrRSwMgCtAAALAAIJrRSwMgCtAAAuAAQKfxYAAgsABwlpHm8uAFMCAAsABwlpHm8uAFMCAAAA.',
['面具']='面具真:BAAALgAECgYJDQAAAA==.',
['颜值']='颜值界扛把子:BAAALgADCgEJAQAAAA==.',
['風蕭']='風蕭蕭易水寒:BAAALgADCgIJAgAAAA==.',
['风吹']='风吹屁皮冷:BAAALgAECgQJBAAAAA==.',
['风羽']='风羽子:BAAALgAECgIJAgAAAA==.',
['风骨']='风骨霸刀:BAAALgAECgEJAQAAAA==.',
['饮者']='饮者丶:BAAALgAECgYJBgAAAA==.',
['馒头']='馒头突围:BAAALgAECgMJBQAAAA==.',
['香甜']='香甜兽太香蕉:BAAALgAECgQJBQAAAA==.香甜函朔摆挖:BAAALgAECgYJBgAAAA==.',
['香酥']='香酥烤鸭丶:BAAALgADCgIJAQAAAA==.',
['骑大']='骑大爷:BAABLgAFFH8FAAICAAUJ1Rd7AwC8AQACAAUJ1Rd7AwC8AQAAAA==.',
['骑马']='骑马的牛:BAAALgADCgUJBQAAAA==.',
['骨骨']='骨骨股股骨头:BAAALgAECgkJCgAAAA==.',
['高槻']='高槻全羊:BAAALgAECgEJAQAAAA==.',
['鬼速']='鬼速:BAABLgAFFH8IAAIOAAQJ5xeICABmAQAOAAQJ5xeICABmAQABLgAFFAUJBwAQADEdAA==.',
['鬼道']='鬼道先生:BAAALgAECgYJBgAAAA==.',
['魔兽']='魔兽小助手:BAAALgADCgEJAQAAAA==.',
['魔法']='魔法无敌:BAAALgAECgMJCQAAAA==.',
['鲜嫩']='鲜嫩滑鸡周:BAABLgAFFH8LAAIIAAQJix9pHwAeAQAIAAQJix9pHwAeAQAAAA==.',
['鸭鸭']='鸭鸭瞎:BAAALgADCgMJAwAAAA==.',
['鹅毛']='鹅毛大雪:BAAALgAFFAIJAgAAAA==.',
['麦克']='麦克佐德:BAAALgAECgYJBgAAAA==.',
['麽麽']='麽麽茶:BAAALgAECgcJDQAAAA==.',
['黄昏']='黄昏的丧钟:BAAALgADCgUJBQAAAA==.',
['黄發']='黄發財:BAAALgAECgQJBAABLgAFFAMJBwACANsJAA==.',
['黄霄']='黄霄雲:BAAALgAECgEJAQAAAA==.',
['黑白']='黑白旧歌谣:BAACLgAFFH8KAAMIAAQJohM8DwD+AAAIAAMJVxQ8DwD+AAAJAAEJgBFTFQBFAAAuAAQKfxUAAwgACAlRGNI3AFcCAAgACAlBGNI3AFcCAAkAAgkLE404AH8AAAAA.',
['黒夜']='黒夜:BAABLgAFFH8GAAIIAAIJzRfcFQCwAAAIAAIJzRfcFQCwAAAAAA==.',
['龘风']='龘风暴烈酒:BAAALgAFFAEJAQAAAA==.',
['龙咩']='龙咩咩:BAAALgAECgYJEAAAAA==.',
['龙座']='龙座:BAAALgAECgkJCQAAAA==.',
['龙眼']='龙眼同学:BAAALgAECgEJAQAAAA==.',
['龙骑']='龙骑着龙:BAAALgAECgEJAQAAAA==.',
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
