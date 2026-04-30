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

local lookup = {'DeathKnight-Unholy','Mage-Frost','Priest-Holy','Shaman-Restoration','Shaman-Elemental','Evoker-Augmentation','Warrior-Protection','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','DeathKnight-Blood','Unknown-Unknown','DemonHunter-Devourer','Druid-Restoration',}
local provider = {region='CN',realm='阿曼尼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Advaa:BAAALgAFFAQJBAAAAA==.',
Al='Alexlovingcc:BAAALgAECgcJAgAAAA==.',
Ca='Cassielin:BAAALgAECgYJEwAAAA==.',
Gr='Gress:BAAALgAECgYJBgAAAA==.',
Ho='Honey:BAABLgAECn8XAAIBAAcJVxabZwC/AQABAAcJVxabZwC/AQAAAA==.',
Ki='Kill:BAAALgAECgcJBwABLgAFFAYJCwACAL0cAA==.',
Ko='Konosuba:BAAALgAECgkJBgAAAA==.',
La='Laalisa:BAAALgAECgYJCwAAAA==.',
Ma='Marius:BAAALgAECgIJAgAAAA==.',
Mi='Mizuu:BAAALgAECgIJAgAAAA==.',
Pa='Patspring:BAAALgADCgEJAQAAAA==.',
Pu='Punk:BAAALgADCgQJBAAAAA==.',
Si='Sixsixsix:BAAALgAECgUJBQAAAA==.',
Su='Sunlv:BAAALgAECgYJBgAAAA==.',
Ta='Taylorbear:BAAALgAFFAEJAQAAAA==.',
Yo='Yonna:BAAALgAFFAIJAgAAAA==.',
['一直']='一直:BAAALgAECgEJAQAAAA==.',
['一零']='一零一企划:BAAALgAECgcJAQAAAA==.',
['万灵']='万灵归一:BAAALgAECgUJBwAAAA==.',
['上白']='上白澤慧音:BAAALgADCgkJCQAAAA==.',
['不能']='不能說的秘密:BAAALgAECgIJAgAAAA==.',
['丨丶']='丨丶地狱男:BAAALgAFFAUJAwAAAA==.',
['丨残']='丨残美丶:BAAALgAECgMJBQAAAA==.',
['丨美']='丨美女与野兽:BAAALgADCgIJAgAAAA==.',
['丫够']='丫够燥的:BAAALgAECgEJAQAAAA==.',
['丶晚']='丶晚枫:BAABLgAFFH8FAAIDAAMJxgv7CADYAAADAAMJxgv7CADYAAAAAA==.',
['丿依']='丿依灬然丶:BAAALgAECgYJCwAAAA==.',
['丿卡']='丿卡露露:BAAALgAFFAEJAQAAAA==.',
['丿明']='丿明明如月:BAABLgAFFH8LAAMEAAQJawhmDgD2AAAEAAQJawhmDgD2AAAFAAMJbAGhCwCmAAAAAA==.',
['九千']='九千八:BAAALgAFFAIJAgAAAA==.',
['云梦']='云梦沉沙:BAAALgAECgQJBQAAAA==.',
['云端']='云端幽灵:BAAALgADCgYJBgAAAA==.',
['亚莲']='亚莲沃克:BAAALgAECgIJAwAAAA==.',
['亦生']='亦生灬飘泊:BAAALgAECgUJCAAAAA==.',
['亲儿']='亲儿子不虚:BAAALgAFFAEJAQAAAA==.',
['亲缺']='亲缺德么:BAAALgAECgYJCQAAAA==.',
['人贱']='人贱就是矫情:BAAALgAECgQJBwAAAA==.',
['人龙']='人龙小:BAAALgADCgYJBgAAAA==.',
['仁者']='仁者無敵:BAAALgAECgcJBwAAAA==.',
['伊利']='伊利但怒风:BAAALgAECgQJBwAAAA==.',
['伍仟']='伍仟酒:BAABLgAFFH8JAAIGAAYJ1xxSBQCtAQAGAAYJ1xxSBQCtAQAAAA==.',
['优昙']='优昙华院:BAAALgAECgkJCQAAAA==.',
['你在']='你在教我做事:BAAALgAECgEJAQAAAA==.',
['傲娇']='傲娇肥牛:BAAALgAECgEJAQAAAA==.',
['傲气']='傲气猎魂:BAAALgADCgEJAQAAAA==.',
['全面']='全面沦陷:BAAALgAECgUJBQAAAA==.',
['六仟']='六仟一:BAAALgAFFAUJBAAAAA==.',
['六六']='六六大魔王:BAAALgAECgYJBgAAAA==.',
['兽八']='兽八两:BAAALgAECgUJBgAAAA==.',
['冠宁']='冠宁超级无敌:BAAALgADCgIJAgAAAA==.',
['冰鳞']='冰鳞:BAAALgAECgYJBwAAAA==.',
['凉面']='凉面多放辣:BAAALgAFFAIJAwAAAA==.',
['凶神']='凶神:BAAALgADCgMJAwAAAA==.',
['剑来']='剑来丶阮秀:BAAALgAFFAEJAQAAAA==.',
['包包']='包包菜丶炒馕:BAAALgAECgIJAgAAAA==.',
['南站']='南站:BAABLgAFFH8GAAIHAAIJvQD4DgBQAAAHAAIJvQD4DgBQAAAAAA==.',
['叁柒']='叁柒贰拾壹:BAAALgAFFAEJAQAAAA==.',
['可怕']='可怕的大宗师:BAAALgAECgEJAQAAAA==.',
['后巷']='后巷乌龙茶:BAAALgAFFAEJAQAAAA==.后巷奶茶:BAAALgAECgQJBwAAAA==.后巷普洱茶:BAAALgADCgIJAgAAAA==.后巷茉莉茶:BAAALgAFFAQJBAAAAA==.',
['咆哮']='咆哮的小恶魔:BAAALgADCgIJAwAAAA==.',
['和而']='和而不同:BAAALgADCgYJBgAAAA==.',
['哈缪']='哈缪尔:BAAALgAECgIJBAAAAA==.',
['哪里']='哪里都是你灬:BAABLgAFFH8FAAIIAAUJQw+LAQCPAQAIAAUJQw+LAQCPAQAAAA==.',
['嘎嘎']='嘎嘎香:BAAALgAECgcJCAAAAA==.',
['圣光']='圣光战:BAAALgADCgIJAgAAAA==.圣光狐狸:BAAALgAECgUJBQAAAA==.圣光骑士:BAAALgADCgUJBQAAAA==.',
['在下']='在下牛华强:BAAALgAECgIJAgAAAA==.',
['坦克']='坦克手呗塔:BAAALgAECgkJCQAAAA==.',
['壹仟']='壹仟叁:BAAALgAFFAYJBAABLgAFFAcJCQAGANccAA==.',
['夏沫']='夏沫丶凉汐:BAAALgAECgEJAgAAAA==.',
['天君']='天君儿:BAAALgADCgIJAgAAAA==.',
['奶凶']='奶凶的比卡丘:BAAALgADCgMJAwAAAA==.',
['好一']='好一只大橘:BAAALgAECgEJAQAAAA==.',
['妖孽']='妖孽:BAAALgAECgkJCQAAAA==.',
['妙酱']='妙酱:BAAALgAFFAIJAgAAAA==.',
['娇贵']='娇贵窃香:BAAALgAECgUJBQAAAA==.',
['寂寞']='寂寞术控:BAAALgAECgYJEAAAAA==.',
['寥若']='寥若星辰:BAAALgAECgkJCgAAAA==.',
['小桃']='小桃儿:BAAALgAFFAEJAQAAAA==.',
['小眼']='小眼迷死你:BAAALgAECgEJAgAAAA==.',
['小老']='小老虎:BAAALgAECgEJAQAAAA==.',
['小虾']='小虾米:BAAALgAFFAIJAwAAAA==.',
['小西']='小西天:BAAALgAECgEJAgAAAA==.',
['小诺']='小诺:BAAALgAFFAMJAwAAAA==.',
['小贱']='小贱贱:BAAALgAECgYJDgAAAA==.',
['尘熙']='尘熙:BAAALgAECgYJBwAAAA==.',
['尛尛']='尛尛尾巴:BAAALgAECgQJBAAAAA==.',
['尛尾']='尛尾巴贔贔:BAAALgAECgQJCAAAAA==.',
['尾崎']='尾崎由香:BAAALgADCgMJAwABLgAFFAYJCgAEAHYKAA==.',
['崇拔']='崇拔:BAAALgAECgYJCAAAAA==.',
['布尔']='布尔乔亚:BAAALgAECgEJAgAAAA==.',
['帅鹏']='帅鹏鹏:BAAALgAECgkJCgAAAA==.',
['常常']='常常河边走:BAAALgADCgEJAQAAAA==.',
['平头']='平头哥:BAAALgAECgkJCQAAAA==.',
['当乐']='当乐:BAAALgAECgEJAQAAAA==.',
['彳亍']='彳亍小小风:BAABLgAFFH8IAAMJAAQJoRB9DAD/AAAJAAMJzBB9DAD/AAAKAAIJJQ/kHQCeAAAAAA==.彳亍小风:BAABLgAFFH8IAAMJAAQJbxLFFACxAAAJAAIJohLFFACxAAAKAAIJPBLDHACjAAAAAA==.',
['德国']='德国丶小妖:BAAALgAFFAUJAwAAAA==.',
['德德']='德德小顺子:BAAALgAECgYJDAAAAA==.',
['性感']='性感的牛蛙:BAAALgAECgEJAQAAAA==.',
['愚蠢']='愚蠢的狸猫:BAAALgAECgMJAwAAAA==.',
['我草']='我草莓招了:BAAALgAECgkJCQAAAA==.',
['打摆']='打摆子:BAAALgAECgEJAQAAAA==.',
['拒绝']='拒绝迪丽热巴:BAAALgADCgMJAwAAAA==.',
['挖土']='挖土的浪人:BAAALgAECgUJBwAAAA==.',
['无才']='无才有德:BAAALgAECgYJDAAAAA==.',
['晚上']='晚上逛马路:BAAALgAECgEJAQAAAA==.',
['晨曦']='晨曦亦如初见:BAABLgAFFH8KAAILAAQJlBVgBQBVAQALAAQJlBVgBQBVAQAAAA==.晨曦茳祉:BAAALgADCgMJAwAAAA==.',
['暗夜']='暗夜星河:BAAALgAECgQJBAAAAA==.',
['暗影']='暗影国度:BAAALgAECgMJBQAAAA==.',
['月野']='月野虎:BAAALgAECgEJAQAAAA==.',
['木头']='木头呐:BAAALgAECgkJBwAAAA==.',
['未来']='未来星力王:BAAALgAFFAQJBAAAAA==.',
['未知']='未知正确目标:BAAALgADCgUJBQAAAA==.',
['杯莫']='杯莫停丶:BAABLgAFFH8NAAMMAAQJvgl1BwCvAAABAAMJ+AdwLgDfAAAMAAQJkwV1BwCvAAAAAA==.',
['极品']='极品小喵喵:BAAALgAFFAQJBAAAAA==.',
['枫的']='枫的记忆:BAAALgAECgQJBgAAAA==.',
['柒柒']='柒柒大魔王:BAAALgAFFAQJBAAAAA==.',
['柠檬']='柠檬可乐:BAAALgAFFAEJAQAAAA==.',
['桃丶']='桃丶白白:BAAALgAECgQJBwAAAA==.',
['桃白']='桃白白丶:BAAALgAECgYJCgAAAA==.',
['楊耂']='楊耂爺:BAAALgAECgMJAwAAAA==.',
['樱木']='樱木花花:BAAALgAECgYJBwAAAA==.',
['欧皇']='欧皇肥宝宝:BAAALgAECgYJBgABLgAECgYJBgANAAAAAA==.',
['水牛']='水牛味果子:BAAALgAECgUJBQAAAA==.',
['污龟']='污龟的黑头:BAAALgAECgcJDAAAAA==.',
['波尔']='波尔多斯:BAAALgAECgcJCwAAAA==.',
['波比']='波比小佑:BAAALgAECgMJAwAAAA==.',
['注意']='注意这个帅哥:BAAALgADCgEJAQAAAA==.',
['洛薩']='洛薩:BAAALgAECgYJBgAAAA==.',
['浮世']='浮世清濛:BAACLgAFFH8LAAIOAAQJIggkFwAYAQAOAAQJIggkFwAYAQAuAAQKfxsAAw4ACAkvGdwvADwCAA4ACAkvGdwvADwCAAgABgkeGugrAGkBAAAA.',
['清风']='清风小武僧:BAAALgAECgEJAgAAAA==.',
['湮灬']='湮灬雨:BAAALgAECgcJCAAAAA==.',
['满地']='满地打滚:BAAALgAECgEJAQAAAA==.',
['潮泳']='潮泳:BAAALgAECgUJBQAAAA==.',
['濛濛']='濛濛哒:BAAALgAECgcJDQAAAA==.',
['火暴']='火暴猴:BAAALgAECgkJCAAAAA==.',
['灬楊']='灬楊灬:BAAALgAECgIJAgAAAA==.',
['灬浪']='灬浪裏媽灬:BAAALgAECgQJBwAAAA==.',
['灬诗']='灬诗怡灬:BAAALgAECgUJBQAAAA==.',
['烟花']='烟花落尽:BAAALgAECgQJBAAAAA==.',
['烟雨']='烟雨漫天:BAAALgAECgEJAQAAAA==.',
['爸爸']='爸爸:BAAALgAFFAQJBAABLgAFFAUJAQANAAAAAA==.',
['牛勾']='牛勾寨大当家:BAAALgADCgUJBQAAAA==.',
['牧瑶']='牧瑶:BAAALgAFFAIJBAAAAA==.',
['狐狸']='狐狸:BAAALgAECgUJBgAAAA==.',
['王之']='王之狩猎:BAAALgAECgUJCQAAAA==.',
['琳德']='琳德:BAAALgAECgkJDgAAAA==.',
['琴大']='琴大宝:BAAALgADCgEJAQAAAA==.',
['电话']='电话打给我:BAAALgADCgYJBgAAAA==.',
['男人']='男人不怕黑:BAAALgAFFAIJAgAAAA==.',
['疯神']='疯神再世:BAAALgAECgYJBwAAAA==.',
['百事']='百事可口可乐:BAAALgADCgIJAgAAAA==.',
['砂锅']='砂锅牛肉抄手:BAAALgAECgIJAwAAAA==.',
['硬汉']='硬汉:BAAALgAECgYJCAAAAA==.',
['神奇']='神奇的马鹿:BAAALgAECgQJBAAAAA==.',
['秃秃']='秃秃的骑士:BAAALgAECgUJBQAAAA==.',
['等我']='等我拉个瞄准:BAAALgADCgEJAQAAAA==.',
['米尔']='米尔豪斯:BAAALgAECgEJAQAAAA==.',
['练练']='练练一头肌:BAAALgADCgUJBQAAAA==.',
['绝世']='绝世天劫:BAAALgAECgQJBAAAAA==.',
['绫波']='绫波丽丶:BAABLgAFFH8FAAIBAAIJ8xCLIACgAAABAAIJ8xCLIACgAAAAAA==.',
['翡翠']='翡翠之心:BAAALgAECgEJAQAAAA==.',
['老猫']='老猫沃夫:BAAALgAECgYJCgAAAA==.',
['肉肉']='肉肉也疯狂:BAAALgAECgEJAQAAAA==.肉肉我爱吃:BAAALgAFFAIJAwAAAA==.',
['能豆']='能豆豆萌萌哒:BAAALgADCgYJCwAAAA==.',
['自然']='自然的力量:BAAALgAFFAEJAQAAAA==.',
['艾莎']='艾莎丶云歌:BAAALgADCgcJDwAAAA==.',
['萨囧']='萨囧囧:BAAALgAECgcJCAAAAA==.',
['落花']='落花雨无泪:BAAALgAECgYJCwAAAA==.',
['蒙太']='蒙太奇:BAAALgAECgEJAQAAAA==.',
['薄荷']='薄荷朱莉普:BAAALgAFFAIJAgAAAA==.',
['藤津']='藤津伪器:BAAALgAECgEJAQAAAA==.',
['被遗']='被遗忘的心弦:BAAALgADCgEJAgAAAA==.',
['西云']='西云子:BAAALgADCgQJBAAAAA==.',
['诸葛']='诸葛丶钢铁:BAAALgAECgQJCQAAAA==.',
['豆奶']='豆奶和小姜饼:BAAALgAECgEJAQAAAA==.',
['贾静']='贾静雯:BAABLgAFFH8FAAICAAMJOQ7bLQD/AAACAAMJOQ7bLQD/AAAAAA==.',
['起个']='起个门拉个糖:BAAALgAFFAQJBAAAAA==.',
['超级']='超级小思嘉:BAABLgAECn8YAAIEAAgJKxOJJwDzAQAEAAgJKxOJJwDzAQAAAA==.',
['踏莎']='踏莎行:BAAALgADCgcJBwAAAA==.',
['辰灬']='辰灬不二:BAAALgAECgcJBwAAAA==.',
['迟到']='迟到的唐僧:BAAALgAECgYJBgAAAA==.',
['邪恶']='邪恶梦魇:BAAALgADCgEJAQAAAA==.邪恶的阿昆达:BAAALgAFFAIJAwAAAA==.',
['酒仙']='酒仙丨龙傲天:BAAALgAECgUJDAAAAA==.',
['酒神']='酒神给你大药:BAAALgAECgMJBgAAAA==.',
['醉疯']='醉疯者:BAAALgAECgYJBgAAAA==.',
['醉风']='醉风者:BAAALgAECgEJAQAAAA==.',
['钙奶']='钙奶:BAAALgADCgUJAQAAAA==.',
['钱烈']='钱烈宪发言:BAAALgAFFAIJBAAAAA==.',
['長沙']='長沙满鍋:BAABLgAFFH8GAAIMAAQJyxJaCAAFAQAMAAQJyxJaCAAFAQABLgAFFAYJFgAMAMkdAA==.',
['长离']='长离:BAAALgAECgYJBwAAAA==.',
['阿呸']='阿呸:BAAALgAECgEJAQAAAA==.',
['阿萨']='阿萨:BAABLgAFFH8GAAIEAAIJ+xj6FgChAAAEAAIJ+xj6FgChAAAAAA==.',
['陈丶']='陈丶风爆烈酒:BAAALgAFFAEJBAAAAA==.',
['雷霆']='雷霆之怒小妖:BAAALgAECgkJCQAAAA==.',
['靈丶']='靈丶犇:BAABLgAFFH8FAAIPAAMJfwSeFQC2AAAPAAMJfwSeFQC2AAAAAA==.',
['靈魂']='靈魂链結:BAAALgAECgEJAQAAAA==.',
['静听']='静听松风:BAAALgAECgYJCQAAAA==.',
['面壁']='面壁者:BAAALgAECgYJBgAAAA==.',
['面朝']='面朝灬大海:BAAALgAFFAEJAgAAAA==.',
['风的']='风的微笑:BAAALgAECgUJBQAAAA==.',
['飛翔']='飛翔的荷蘭人:BAAALgAECgIJAQABLgAFFAUJAgANAAAAAA==.',
['饮血']='饮血者玛鲁斯:BAAALgAECgUJBwAAAA==.',
['饿丨']='饿丨魔:BAAALgAECgQJBAAAAA==.',
['马什']='马什么梅:BAAALgAECgQJCwAAAA==.',
['驱逐']='驱逐者鬼猎:BAAALgAECgIJAgAAAA==.',
['骨汤']='骨汤牛肉面:BAAALgAECgYJBgAAAA==.',
['高崔']='高崔克:BAAALgAECgcJBgAAAA==.',
['魔法']='魔法披风:BAAALgAECgMJAwAAAA==.',
['鲸鱼']='鲸鱼丶不会飞:BAAALgAECgMJAwAAAA==.',
['麦肯']='麦肯娜格瑞丝:BAAALgAECgQJBAAAAA==.',
['黑痒']='黑痒痒:BAAALgAECgQJBAAAAA==.',
['黑直']='黑直长:BAAALgAECgUJCAAAAA==.',
['黑锋']='黑锋摸鱼王:BAAALgAECgIJAgAAAA==.',
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
