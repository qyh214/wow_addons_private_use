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

local lookup = {'Hunter-BeastMastery','Monk-Brewmaster','DeathKnight-Unholy','Unknown-Unknown','Priest-Discipline','Mage-Frost','Priest-Holy','Shaman-Restoration','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Warlock-Demonology','Evoker-Preservation','Evoker-Augmentation','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Warlock-Destruction','Rogue-Subtlety','Paladin-Holy','Paladin-Retribution','DeathKnight-Blood','Shaman-Elemental',}
local provider = {region='CN',realm='达尔坎',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Ach:BAAALgAECgEJAQAAAA==.',
Al='Alr:BAABLgAFFH8FAAIBAAMJWAfODADnAAABAAMJWAfODADnAAAAAA==.',
Ar='Ariaofuy:BAAALgAFFAIJAgAAAA==.',
At='Atropos:BAAALgAECgEJAQAAAA==.',
Ba='Barbiel:BAAALgADCgcJBwAAAA==.',
Cu='Cult:BAAALgAECgEJAQAAAA==.',
Da='Darkdruid:BAAALgADCgUJBQAAAA==.',
Ga='Gazastrip:BAAALgAECgEJAQAAAA==.',
Ge='Genius:BAAALgAECgQJBAAAAA==.',
Go='Goodbyexixi:BAAALgAECgQJBAAAAA==.',
He='Henrys:BAAALgAECgIJAgAAAA==.',
Hy='Hyzmage:BAAALgAECgcJEAAAAA==.',
Ka='Kaede:BAAALgAFFAEJAQAAAA==.',
Ki='Killbill:BAAALgAECgEJAQAAAA==.',
Ku='Kumashi:BAAALgAECgIJAgAAAA==.',
Lo='Lono:BAAALgADCgUJCQAAAA==.',
Lr='Lrida:BAAALgAECgIJAQABLgAFFAQJCwACAMMmAA==.',
Lu='Luyangws:BAAALgAECgYJBgAAAA==.',
Mo='Mottled:BAAALgADCgUJBQAAAA==.',
Or='Oraclen:BAAALgAECgEJAQAAAA==.Oryndoll:BAAALgAECgQJBAAAAA==.',
Pl='Playerjzhykn:BAAALgAECgEJAQAAAA==.',
Qs='Qsmm:BAAALgAECgQJAwAAAA==.',
Qu='Quxxa:BAAALgAECgEJAQAAAA==.Quxxe:BAAALgAECgYJBgAAAA==.Quxxq:BAAALgAECgYJBAAAAA==.Quxxs:BAAALgAECgYJBgAAAA==.Quxxz:BAAALgAECgIJAgAAAA==.',
Ra='Ragingbull:BAAALgADCgEJAQAAAA==.',
Ro='Rockandroll:BAAALgADCgEJAQAAAA==.',
Tj='Tjsm:BAAALgAECgUJBQAAAA==.',
Ye='Yedda:BAAALgAECgUJBwAAAA==.',
['一杆']='一杆鱼叉猎:BAAALgAECgcJAQAAAA==.',
['一队']='一队奶骑:BAAALgAECgcJCAAAAA==.',
['一页']='一页书:BAAALgAECgEJAwAAAA==.',
['丁大']='丁大官人:BAAALgAFFAEJAQAAAA==.',
['七月']='七月在野:BAACLgAFFH8HAAIDAAMJ4BbCEgD6AAADAAMJ4BbCEgD6AAAuAAQKfxQAAgMACAm1HEUxAHMCAAMACAm1HEUxAHMCAAAA.',
['万事']='万事皆相宜:BAAALgADCgcJBwAAAA==.',
['三荒']='三荒烬灭:BAAALgAECgQJBwAAAA==.',
['上杉']='上杉夏襄:BAAALgAECgMJAwAAAA==.',
['东方']='东方:BAAALgAECgYJBgAAAA==.',
['两只']='两只傻阳阳:BAAALgAECgMJAwAAAA==.',
['丨天']='丨天罚丨:BAAALgAECgEJAQABLgAECgQJBAAEAAAAAA==.',
['丶丶']='丶丶嚜丶丶:BAAALgAECgUJBQAAAA==.',
['丶菜']='丶菜菜丶:BAAALgAECgQJCgAAAA==.',
['丿祭']='丿祭灬血:BAAALgADCgEJAQABLgAECgEJAgAEAAAAAA==.',
['乔伊']='乔伊波依:BAAALgAECgEJAQAAAA==.',
['二狗']='二狗子三精:BAAALgAECgMJAwABLgAFFAcJEgAFAEEVAA==.',
['云从']='云从龙:BAAALgAECgQJBAAAAA==.',
['亲闺']='亲闺女:BAABLgAECn8WAAIGAAcJGwrTyQBVAQAGAAcJGwrTyQBVAQAAAA==.',
['低调']='低调的风雨:BAAALgAECgIJAgAAAA==.',
['余醉']='余醉:BAAALgAECgQJBAAAAA==.',
['佛朗']='佛朗明戈舞步:BAAALgAECgQJBwAAAA==.',
['佹得']='佹得复失:BAAALgAECgEJAQAAAA==.',
['倾城']='倾城小龙牧:BAABLgAECn8eAAIHAAcJwxtUFgAqAgAHAAcJwxtUFgAqAgABLgAFFAUJEQAIAH0iAA==.',
['兜兜']='兜兜有大锤:BAAALgAECgUJCAAAAA==.',
['冬天']='冬天穿短裤儿:BAAALgAECgYJCQAAAA==.',
['冰火']='冰火穿裆:BAABLgAECn8WAAIGAAYJ9R3GgADPAQAGAAYJ9R3GgADPAQAAAA==.',
['凝渊']='凝渊:BAAALgADCgIJAgAAAA==.',
['剑一']='剑一:BAAALgAECgcJBwAAAA==.',
['加特']='加特:BAAALgAECgYJDAAAAA==.',
['午夜']='午夜叫叫:BAAALgAECgUJBgAAAA==.午夜教教:BAABLgAFFH8JAAIHAAQJtwyrBQAoAQAHAAQJtwyrBQAoAQAAAA==.',
['卩死']='卩死丶灵丨:BAAALgAECgcJBQAAAA==.',
['叆月']='叆月:BAAALgAECgcJDgAAAA==.',
['双眼']='双眼皮:BAAALgAECgYJDwAAAA==.',
['叫我']='叫我小浪就好:BAAALgADCgEJAQAAAA==.',
['右誓']='右誓:BAAALgAECgEJAQAAAA==.',
['司马']='司马暴雪:BAAALgAFFAEJAQAAAA==.',
['吃过']='吃过饭了:BAAALgADCgEJAQAAAA==.吃过饭了不:BAAALgADCgMJAwAAAA==.',
['吉安']='吉安忒尼斯:BAAALgAECgEJAQAAAA==.',
['吖噗']='吖噗丷吖噗:BAAALgADCgMJAwAAAA==.',
['吴剑']='吴剑琴心:BAAALgAFFAIJAgAAAA==.',
['吾叉']='吾叉叉:BAAALgAECgQJBAAAAA==.',
['呱呱']='呱呱狐狐:BAAALgAECgQJBAAAAA==.',
['味大']='味大无需多盐:BAAALgAFFAQJBAAAAA==.',
['咆哮']='咆哮:BAAALgAECgYJEQAAAA==.',
['咕咕']='咕咕不咕咕:BAACLgAFFH8LAAIJAAQJ2R48BQCIAQAJAAQJ2R48BQCIAQAuAAQKfxcAAwkACAm7JPUBANYCAAkACAm7JPUBANYCAAoAAQkbByF+ADQAAAAA.',
['咩咩']='咩咩子:BAAALgAECgEJAgAAAA==.',
['唸风']='唸风语者:BAAALgAECgIJAgAAAA==.',
['啤哩']='啤哩吧啦:BAAALgADCgcJBQABLgAFFAIJAwAEAAAAAA==.',
['嗜血']='嗜血之灵:BAAALgAECgUJBQAAAA==.',
['嗡嗡']='嗡嗡:BAAALgADCgQJBAAAAA==.',
['四妹']='四妹灵丹:BAAALgADCgQJBAABLgAFFAQJCwACAMMmAA==.',
['四月']='四月:BAAALgAECgEJAgAAAA==.',
['囧瑟']='囧瑟夫:BAAALgAECgEJAQAAAA==.',
['国丨']='国丨宝萧笼刃:BAAALgADCgEJAQAAAA==.',
['城墙']='城墙倒拐:BAAALgAFFAEJAgAAAA==.',
['墨梦']='墨梦璃:BAAALgAECgQJBAAAAA==.',
['夏宓']='夏宓:BAAALgAECgYJBgAAAA==.',
['夏小']='夏小茶:BAAALgAFFAEJAQAAAA==.',
['夏纠']='夏纠结:BAAALgAECgQJBAAAAA==.',
['夜小']='夜小瞳:BAAALgAECgkJCQAAAA==.',
['大地']='大地护佑:BAAALgAECgcJDQAAAA==.',
['大宗']='大宗西:BAAALgAFFAIJAwAAAA==.',
['大驹']='大驹驹:BAABLgAFFH8JAAIBAAMJBCNjBQBFAQABAAMJBCNjBQBFAQAAAA==.',
['大魚']='大魚海苔丶:BAAALgAECgEJAQAAAA==.',
['大鼻']='大鼻子王源:BAAALgAFFAYJAwAAAA==.',
['天宇']='天宇之心:BAAALgAFFAEJAQAAAA==.',
['天灾']='天灾骨钟:BAAALgAECgYJBgAAAA==.',
['天琴']='天琴雨:BAAALgAECgcJBwAAAA==.',
['天神']='天神下瀿:BAAALgAECgEJAQAAAA==.',
['夯驴']='夯驴子:BAAALgAFFAIJAwAAAA==.',
['夹急']='夹急夹急嘟喂:BAABLgAFFH8MAAILAAUJlBLzDQBEAQALAAUJlBLzDQBEAQAAAA==.',
['奈欧']='奈欧天:BAAALgAECgEJAQAAAA==.',
['女骑']='女骑士:BAAALgAFFAIJBAAAAA==.',
['奶一']='奶一口没:BAAALgAECgcJBwAAAA==.',
['奶茶']='奶茶射手:BAAALgAECgQJBQAAAA==.',
['孤独']='孤独摇滚:BAAALgAECgMJAwAAAA==.',
['宇宙']='宇宙骑士利橙:BAAALgAFFAEJAQAAAA==.宇宙骑士利炮:BAAALgADCgYJBgAAAA==.宇宙龙骑士:BAAALgAECgYJBgAAAA==.',
['宿命']='宿命丶之环:BAAALgAECgMJBQAAAA==.',
['小嘴']='小嘴蘸了蜜:BAAALgAFFAEJAQAAAA==.',
['小白']='小白专坑大神:BAAALgAECgYJBgAAAA==.',
['小能']='小能猫:BAAALgAECgYJCgAAAA==.',
['小舟']='小舟夜航船:BAAALgAECgMJAwAAAA==.',
['尤古']='尤古朵拉:BAAALgADCggJCAAAAA==.',
['山鬼']='山鬼:BAAALgAECgcJDgAAAA==.山鬼不识字:BAAALgAECgUJBgAAAA==.',
['岁夜']='岁夜:BAAALgADCgMJAwAAAA==.',
['布拉']='布拉迪奥斯:BAAALgAECgQJEAAAAA==.',
['希巴']='希巴伯拉德:BAAALgAECgYJCAAAAA==.',
['张狂']='张狂完美:BAAALgAECgUJBgAAAA==.',
['彩彩']='彩彩豆豆:BAACLgAFFH8LAAICAAQJwyZ8AgDHAQACAAQJwyZ8AgDHAQAuAAQKfyoAAgIACAkQJtcCAGoDAAIACAkQJtcCAGoDAAAA.',
['心如']='心如冰碎:BAABLgAECn8WAAIGAAYJCR9paAAGAgAGAAYJCR9paAAGAgAAAA==.',
['思贤']='思贤:BAAALgAECgMJBAAAAA==.',
['愛吃']='愛吃漢堡包:BAABLgAFFH8HAAIDAAMJXyBVHQAsAQADAAMJXyBVHQAsAQAAAA==.',
['愤怒']='愤怒:BAAALgAECgQJBAAAAA==.',
['慈玉']='慈玉典誓:BAAALgAFFAIJAgAAAA==.',
['成昆']='成昆:BAAALgAFFAMJAwAAAA==.',
['我其']='我其实是奶骑:BAAALgADCgEJAQAAAA==.',
['我爱']='我爱潇洒哥:BAAALgAECgIJBAAAAA==.',
['扎克']='扎克斯:BAAALgADCgEJAQAAAA==.',
['抗曰']='抗曰奇侠:BAAALgAECgYJCwAAAA==.',
['拖鞋']='拖鞋没牙齿:BAAALgAECgIJAwABLgAECgUJCgAEAAAAAA==.',
['捏捏']='捏捏小猪包:BAAALgAECgcJBwAAAA==.',
['提莫']='提莫老恶魔:BAABLgAFFH8EAAIMAAMJ+AsTFQDxAAAMAAMJ+AsTFQDxAAAAAA==.',
['收手']='收手吧阿祖:BAAALgAECgYJBwAAAA==.',
['放肆']='放肆丶那纠结:BAAALgAFFAIJAgAAAA==.',
['整蛊']='整蛊专家:BAAALgAFFAIJAwAAAA==.',
['斯语']='斯语味儿:BAAALgAECgYJCAAAAA==.',
['无敌']='无敌王:BAAALgAFFAIJAwAAAA==.',
['无聊']='无聊的法爷:BAAALgAFFAQJBAAAAA==.',
['星潋']='星潋:BAAALgAECgUJBgAAAA==.',
['晟战']='晟战:BAAALgAECgQJBgAAAA==.',
['暴富']='暴富灬回响:BAAALgAECgQJCAAAAA==.暴富灬解忧:BAAALgAFFAEJAgAAAA==.',
['暴走']='暴走的香蕉:BAAALgADCgcJCgAAAA==.',
['曾经']='曾经我野清纯:BAAALgAECgEJAQAAAA==.',
['月泣']='月泣:BAAALgAECgUJCgAAAA==.',
['有点']='有点傻的脱:BAAALgAFFAEJAQAAAA==.',
['望雨']='望雨雾:BAAALgAECgcJBQAAAA==.',
['术学']='术学博士:BAAALgAECgMJAwAAAA==.',
['术手']='术手就擒丶:BAAALgAECgYJBwAAAA==.',
['机器']='机器:BAAALgAECgYJBgAAAA==.',
['杀死']='杀死温柔:BAAALgAECgMJAwAAAA==.',
['村花']='村花小娟娟:BAAALgAECgEJAQAAAA==.',
['柠檬']='柠檬萌不萌:BAABLgAECn8UAAIJAAcJzhN8TQBuAQAJAAcJzhN8TQBuAQAAAA==.',
['柴宝']='柴宝:BAAALgADCgYJBgAAAA==.',
['梅莉']='梅莉凯:BAAALgAECgIJAgAAAA==.',
['梦丶']='梦丶魇:BAAALgAECggJCAAAAA==.',
['榴莲']='榴莲牛蛙:BAAALgAECgEJAQAAAA==.',
['欢乐']='欢乐小胖胖:BAAALgAECgYJDAAAAA==.',
['死得']='死得骑所:BAABLgAFFH8JAAIDAAMJthugJAADAQADAAMJthugJAADAQAAAA==.',
['沧桑']='沧桑的脚毛:BAAALgAFFAIJAgAAAA==.',
['法力']='法力洪流:BAAALgAECgEJAQAAAA==.',
['法大']='法大力:BAAALgAECgYJBgAAAA==.',
['泡泡']='泡泡聋:BAAALgAFFAIJAwAAAA==.',
['波尔']='波尔布特:BAAALgAECgkJBQAAAA==.',
['洋灬']='洋灬芋:BAAALgAECgUJBwAAAA==.',
['洛笙']='洛笙:BAAALgAECgUJBQAAAA==.',
['浅蓝']='浅蓝怪草:BAACLgAFFH8HAAINAAQJ5QwfDQAPAQANAAQJ5QwfDQAPAQAuAAQKfxUAAw0ACAmYE/YSABICAA0ACAmYE/YSABICAA4ABwmsCI8yADUBAAAA.',
['漂靓']='漂靓叔叔:BAAALgAECgYJCgAAAA==.',
['漩涡']='漩涡萌妹:BAAALgAECgQJBQAAAA==.',
['漫漫']='漫漫人生路:BAAALgAECgYJCAAAAA==.',
['潇潇']='潇潇沐晨:BAAALgAECgUJAQAAAA==.',
['灬小']='灬小小强灬:BAAALgADCgIJAgAAAA==.',
['灬芫']='灬芫茜冰萃:BAAALgADCgMJAwAAAA==.',
['灬风']='灬风语风筝灬:BAAALgAECgQJBAAAAA==.',
['灰灰']='灰灰丨:BAACLgAFFH8FAAIGAAIJcyNJHADXAAAGAAIJcyNJHADXAAAuAAQKfyYAAgYACQmYIsEHAIwDAAYACQmYIsEHAIwDAAAA.灰灰的小雨天:BAACLgAFFH8GAAIDAAMJIx/cHgAiAQADAAMJIx/cHgAiAQAuAAQKfxYAAgMABwnAI+8lAKQCAAMABwnAI+8lAKQCAAAA.',
['灵丶']='灵丶灵:BAAALgAECgIJAwAAAA==.',
['無法']='無法無天:BAAALgAECgEJAQAAAA==.',
['熊童']='熊童子:BAAALgAECgEJAQAAAA==.',
['爱玩']='爱玩小鸟:BAAALgAECgYJBgAAAA==.',
['爸爸']='爸爸爱你:BAAALgAECgYJBgAAAA==.',
['牛少']='牛少丶石蹄:BAAALgADCgYJBgAAAA==.',
['狂牛']='狂牛犇犇:BAAALgAECgcJBwAAAA==.',
['狂野']='狂野银江:BAAALgAECgQJBgAAAA==.',
['猎手']='猎手丶卢米安:BAAALgADCgQJBAAAAA==.',
['猪二']='猪二丶:BAAALgAECgcJDQAAAA==.',
['猴了']='猴了猴:BAABLgAFFH8FAAIPAAMJsR36AQAkAQAPAAMJsR36AQAkAQAAAA==.',
['猴急']='猴急急:BAABLgAECn8bAAMBAAcJkx1iGQBwAgABAAcJkx1iGQBwAgALAAEJdgzujAAuAAAAAA==.',
['王司']='王司徒:BAAALgAECgUJCwAAAA==.',
['甄志']='甄志丙:BAAALgAECgQJBAAAAA==.',
['甜蜜']='甜蜜兒:BAAALgADCgcJBwAAAA==.',
['生来']='生来就倔强:BAAALgAECgIJBAAAAA==.',
['略懂']='略懂一点拳脚:BAABLgAFFH8GAAMQAAQJCRhvAgBpAQAQAAQJ6RdvAgBpAQARAAIJUBXYBQC1AAAAAA==.',
['疏楼']='疏楼龙宿:BAAALgADCgUJBQAAAA==.',
['疯狂']='疯狂琰影:BAAALgADCgEJAQAAAA==.疯狂的麦芽糖:BAAALgAECgQJCAAAAA==.',
['皮丶']='皮丶点点:BAAALgADCgEJAQAAAA==.',
['目黑']='目黑将司:BAAALgAECgUJBgAAAA==.',
['盲人']='盲人看相:BAAALgAECgIJAgAAAA==.',
['眼子']='眼子寒:BAAALgAECgEJAwAAAA==.',
['石页']='石页:BAAALgAFFAIJAgAAAA==.',
['祈灵']='祈灵术:BAABLgAFFH8IAAMMAAQJcxMVIQD/AAAMAAMJSRQVIQD/AAASAAEJ8hC/FABVAAAAAA==.',
['空空']='空空格格:BAABLgAECn8UAAITAAgJ3B3vFwBJAgATAAgJ3B3vFwBJAgAAAA==.',
['穿着']='穿着熊:BAAALgAECgUJBQAAAA==.',
['第二']='第二滴雨:BAAALgAECgIJAgAAAA==.',
['糗兜']='糗兜玛德:BAAALgADCgMJAwAAAA==.',
['素还']='素还真:BAAALgAECgEJAgAAAA==.',
['索隆']='索隆:BAACLgAFFH8IAAINAAMJZBTLDgDpAAANAAMJZBTLDgDpAAAuAAQKfyMAAg0ACAkJHRYDAOsBAA0ACAkJHRYDAOsBAAAA.',
['纯情']='纯情丶小正太:BAAALgADCgYJBgAAAA==.纯情丶小翅膀:BAAALgAECgYJBgAAAA==.',
['细嗅']='细嗅蔷薇:BAAALgADCgYJBgAAAA==.',
['终极']='终极霸王龙:BAAALgAFFAIJBAAAAA==.',
['绯红']='绯红云:BAAALgAECgYJBwAAAA==.',
['绽雷']='绽雷裂地:BAAALgAECgQJBAAAAA==.',
['绿玩']='绿玩头子:BAAALgAECgcJAwABLgAFFAQJCgACAFgdAA==.',
['缺口']='缺口的下巴:BAAALgAECgEJAQAAAA==.',
['罗静']='罗静涟:BAAALgAECgYJDQAAAA==.',
['美式']='美式满冰灬:BAAALgADCgMJAwAAAA==.',
['羽皇']='羽皇龘帝:BAAALgADCgMJAwAAAA==.',
['老韭']='老韭菜:BAAALgADCgEJAgAAAA==.',
['老鼠']='老鼠偷奶酪:BAAALgAFFAIJAgAAAA==.',
['耂王']='耂王的女人:BAAALgAECgEJAQAAAA==.',
['聖銧']='聖銧:BAAALgADCgIJAgAAAA==.',
['肥汉']='肥汉林:BAAALgADCgEJAQAAAA==.',
['胖的']='胖的悲伤:BAAALgAECgIJAgAAAA==.',
['胡大']='胡大富:BAAALgADCgEJAgAAAA==.',
['自然']='自然之瞳:BAAALgADCgcJBwAAAA==.',
['艾泽']='艾泽贝贝:BAAALgADCgYJBgAAAA==.',
['艾艾']='艾艾爱尔莎:BAABLgAFFH8FAAIUAAMJuB4pDQAKAQAUAAMJuB4pDQAKAQAAAA==.',
['苏格']='苏格兰丨调情:BAAALgADCgcJBwAAAA==.',
['苞皮']='苞皮裹蛆蘸痰:BAAALgAECgEJAQAAAA==.',
['荷尔']='荷尔蒙公主:BAAALgAECgYJBgAAAA==.荷尔蒙烎士:BAAALgAECgYJCgAAAA==.',
['莉艾']='莉艾拉:BAAALgADCgEJAQAAAA==.',
['菜丨']='菜丨菜:BAAALgAECgMJAgAAAA==.',
['萨子']='萨子丶:BAAALgADCgMJAwAAAA==.',
['萨拉']='萨拉斯挽歌:BAAALgAECgMJBgAAAA==.',
['蒋小']='蒋小花:BAAALgAECgQJAQAAAA==.',
['蒙奇']='蒙奇骑:BAAALgAECgEJAgAAAA==.',
['蓝原']='蓝原柚子:BAAALgAECgYJBgAAAA==.',
['蓝蝴']='蓝蝴蝶蓝:BAAALgAECgEJAQAAAA==.',
['薄脆']='薄脆饼干:BAAALgAECgEJAQAAAA==.',
['薛敌']='薛敌忾:BAAALgAFFAIJAgAAAA==.',
['虚空']='虚空鲶鱼:BAAALgAECgcJCwAAAA==.',
['蛮子']='蛮子丶:BAAALgAECgUJDQAAAA==.',
['蝴颜']='蝴颜鸾語:BAAALgAECgEJAQAAAA==.',
['血锤']='血锤狂砸头:BAAALgAFFAIJAgAAAA==.',
['西冷']='西冷丶血蹄:BAACLgAFFH8KAAIDAAMJlhueEQAAAQADAAMJlhueEQAAAQAuAAQKfycAAgMACAlzJb8HAGIDAAMACAlzJb8HAGIDAAAA.',
['諾亜']='諾亜灬雪儿:BAAALgAECgYJDgAAAA==.',
['諾亞']='諾亞灬奶嘴:BAAALgAECgYJCQABLgAECgYJDgAEAAAAAA==.諾亞灬雪儿:BAAALgAECgQJBAABLgAECgYJDgAEAAAAAA==.諾亞灬雪兒:BAAALgAECgUJBQABLgAECgYJDgAEAAAAAA==.',
['让我']='让我想想:BAAALgADCgUJBQAAAA==.',
['诗诗']='诗诗丝黛拉:BAAALgAFFAIJAgAAAA==.',
['贪吃']='贪吃猪猪:BAAALgADCgIJAgAAAA==.',
['赞达']='赞达拉非酋:BAABLgAFFH8GAAMVAAQJEAltHAC9AAAVAAMJKgZtHAC9AAAUAAIJrQABGgBhAAAAAA==.',
['超級']='超級瑪麗薛:BAAALgAECgUJCgAAAA==.',
['轻似']='轻似梦:BAAALgAECgcJAwAAAA==.',
['辰睿']='辰睿:BAAALgAECgEJAQAAAA==.',
['这个']='这个能用吗:BAAALgAECgcJDwAAAA==.',
['逍遥']='逍遥星河:BAAALgAECgQJBQAAAA==.',
['醉光']='醉光阴:BAAALgAECgEJAQAAAA==.',
['钗头']='钗头凤:BAAALgAECgQJBQAAAA==.',
['铁板']='铁板:BAAALgADCgEJAQAAAA==.',
['银灰']='银灰:BAAALgAECgQJBQAAAA==.',
['长崎']='长崎术士:BAAALgAFFAEJAQAAAA==.',
['雨滴']='雨滴先生:BAABLgAECn8hAAMDAAkJcQoYXgDYAQADAAkJaAoYXgDYAQAWAAYJgARnEACgAAAAAA==.',
['雪山']='雪山飞侠:BAABLgAFFH8KAAMBAAMJnh8CDwDSAAABAAIJryECDwDSAAALAAIJWREoHgCdAAABLgAFFAYJBAAEAAAAAA==.',
['零度']='零度久战:BAAALgAECgUJBgAAAA==.',
['零柒']='零柒隆咚呛:BAAALgAECgEJAQAAAA==.',
['雾霭']='雾霭流岚:BAAALgAECgEJAgAAAA==.',
['靈魂']='靈魂冷心:BAAALgADCgYJBwAAAA==.',
['鞠我']='鞠我芽儿嘛:BAAALgAECgMJAwAAAA==.',
['韩小']='韩小雪:BAAALgADCgEJAQAAAA==.',
['风息']='风息:BAAALgAECgYJCQABLgAECgcJDgAEAAAAAA==.',
['风暴']='风暴女子:BAAALgADCgIJAgAAAA==.',
['风雅']='风雅颂:BAAALgAECgEJAQAAAA==.',
['鬼影']='鬼影萧萧:BAAALgAECgEJAQAAAA==.',
['魏武']='魏武遺风:BAAALgAECgQJBgAAAA==.',
['魔法']='魔法打败魔法:BAAALgAECgkJEAABLgAFFAUJBQAJAJkcAA==.',
['魔驴']='魔驴子:BAAALgAECgEJAQAAAA==.',
['鱼利']='鱼利丹:BAAALgADCgIJAgAAAA==.',
['鲁班']='鲁班七号:BAABLgAFFH8IAAIGAAQJcBMrGQBlAQAGAAQJcBMrGQBlAQAAAA==.',
['麦芽']='麦芽糖吖:BAAALgAFFAMJBAABLgAFFAYJFgAXAMUZAA==.',
['黑石']='黑石后街:BAAALgAECgUJBgAAAA==.',
['黑莓']='黑莓糯糍:BAAALgAECgYJBgAAAA==.',
['龍筱']='龍筱月:BAAALgAECgQJBQAAAA==.',
['龍飛']='龍飛鳳舞丶:BAAALgAECgIJAgAAAA==.',
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
