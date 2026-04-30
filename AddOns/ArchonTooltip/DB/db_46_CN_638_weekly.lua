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

local lookup = {'Unknown-Unknown','Hunter-BeastMastery','Evoker-Augmentation','Shaman-Restoration','Evoker-Preservation','Hunter-Marksmanship','Paladin-Retribution','Druid-Balance','Druid-Restoration','DemonHunter-Devourer',}
local provider = {region='CN',realm='奎尔丹纳斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aitx:BAAALgAECgMJAwAAAA==.',
Fa='Faye:BAAALgAECgEJAQAAAA==.',
Ki='Kimchi:BAAALgAECgQJBAAAAA==.',
Li='Lilasikuta:BAAALgAECgEJAgAAAA==.',
Pp='Ppaladiner:BAAALgAECgIJAgAAAA==.',
Ro='Rose:BAAALgADCgEJAQAAAA==.',
Sh='Sheeptwoice:BAAALgAECgYJCwAAAA==.',
Sy='Sylverster:BAAALgADCgcJBwAAAA==.',
Xn='Xnmm:BAAALgAECgMJAwAAAA==.',
['不识']='不识字:BAAALgAECgYJCQAAAA==.',
['丨紫']='丨紫夜:BAAALgAECgUJBQAAAA==.',
['丶多']='丶多弗朗明哥:BAAALgAECgMJAwAAAA==.',
['丶暖']='丶暖洋洋羊丶:BAAALgAECgQJBQAAAA==.',
['丶水']='丶水冰冰冷丶:BAAALgAECgQJBAAAAA==.',
['丶盗']='丶盗版毛毛丶:BAAALgAECgYJDQAAAA==.',
['优雅']='优雅丶阿萨特:BAAALgAECgQJBAAAAA==.',
['低头']='低头等你吻:BAAALgADCgEJAQABLgAFFAIJBAABAAAAAA==.',
['佐山']='佐山爱酱:BAAALgAECgQJBAAAAA==.',
['刃乱']='刃乱之吻:BAABLgAFFH8FAAICAAIJQh5PEADFAAACAAIJQh5PEADFAAAAAA==.',
['剑月']='剑月琴星:BAAALgAECgYJCgAAAA==.',
['北京']='北京宣言:BAAALgAFFAEJAQAAAA==.',
['医保']='医保卡欠费:BAAALgAECgEJAQAAAA==.',
['卡比']='卡比勒:BAAALgADCgEJAQAAAA==.',
['卡莉']='卡莉歐斯托蘿:BAAALgAECgQJBAAAAA==.',
['句芒']='句芒:BAAALgAFFAEJAQAAAA==.',
['哈弄']='哈弄弄:BAAALgAECgYJDgAAAA==.',
['嘞嘞']='嘞嘞:BAAALgAECggJCgAAAA==.',
['回忆']='回忆那一刻:BAAALgAFFAIJAgAAAA==.',
['圣光']='圣光止殇:BAAALgAECgQJBQAAAA==.圣光的泯灭:BAAALgAECgYJCgAAAA==.圣光龙骑士:BAAALgADCgUJBQAAAA==.',
['埋藏']='埋藏圣海:BAAALgAFFAIJAwAAAA==.',
['大叔']='大叔巨棒:BAAALgAECgEJAQAAAA==.',
['大瓶']='大瓶可乐:BAAALgADCgEJAQAAAA==.',
['大聋']='大聋人:BAABLgAFFH8GAAIDAAYJqxwFBADUAQADAAYJqxwFBADUAQABLgAFFAcJBwADADkJAA==.',
['大鼻']='大鼻子丶若风:BAAALgAECggJCQAAAA==.',
['天雷']='天雷棍棍:BAABLgAFFH8FAAIEAAIJYhX0FgChAAAEAAIJYhX0FgChAAAAAA==.',
['契约']='契约圣殿:BAAALgAECgEJAQAAAA==.',
['奥利']='奥利奥乄千层:BAAALgAECgEJAQAAAA==.',
['奶龙']='奶龙:BAABLgAECn8WAAIFAAcJtB/jCwB3AgAFAAcJtB/jCwB3AgAAAA==.',
['婀弗']='婀弗詻狄忒:BAAALgAECgYJBwAAAA==.',
['婲開']='婲開怑嗄:BAAALgAECgcJBgABLgAFFAcJBgAGAG4FAA==.',
['孤独']='孤独丶旅行者:BAAALgAECgEJAQAAAA==.',
['小时']='小时候可逗了:BAAALgAECgYJCgAAAA==.',
['小虎']='小虎:BAAALgAECgkJCgAAAA==.',
['巫山']='巫山祝:BAAALgADCgUJBQAAAA==.',
['干戈']='干戈寥落:BAAALgAECgMJAwAAAA==.',
['并不']='并不讨喜:BAACLgAFFH8HAAIHAAQJRhaRCQBhAQAHAAQJRhaRCQBhAQAuAAQKfxgAAgcACAkGJa0OABkDAAcACAkGJa0OABkDAAAA.',
['幽灵']='幽灵骑士:BAAALgADCgIJAgAAAA==.',
['慕容']='慕容萨满:BAAALgADCgYJBgAAAA==.',
['放棄']='放棄之福:BAAALgAECgQJBAAAAA==.',
['新城']='新城同学:BAAALgAFFAEJAQAAAA==.',
['暴力']='暴力橘子:BAAALgAECgQJBAAAAA==.',
['最后']='最后的恶魔:BAAALgAECgYJBgAAAA==.最后的鸟德:BAABLgAFFH8FAAIIAAUJyhBbBQCUAQAIAAUJyhBbBQCUAQAAAA==.',
['最爱']='最爱小拉达:BAAALgAECgEJAgAAAA==.',
['月色']='月色微凉:BAAALgAECgUJBQAAAA==.',
['木下']='木下丨秀吉:BAAALgADCgYJBgAAAA==.',
['术法']='术法无敌:BAAALgADCgcJEAAAAA==.',
['杀生']='杀生灭众生:BAAALgAECgUJCAAAAA==.',
['来一']='来一包七匹狼:BAAALgADCgQJBAABLgAECgEJAQABAAAAAA==.',
['柒宝']='柒宝霸霸:BAACLgAFFH8KAAIJAAQJuQ8HCgC/AAAJAAQJuQ8HCgC/AAAuAAQKfyAAAgkABwmQHMQoABECAAkABwmQHMQoABECAAAA.',
['椎名']='椎名空:BAAALgAFFAQJBAABLgAFFAYJCwAHAA8LAA==.',
['欧皇']='欧皇小十七:BAAALgAFFAQJBAAAAA==.欧皇小十三:BAABLgAFFH8KAAIIAAUJ1RFKBQCVAQAIAAUJ1RFKBQCVAQAAAA==.欧皇小十五:BAAALgAFFAQJBAAAAA==.欧皇小十八:BAABLgAFFH8FAAIIAAUJyAlWBwBtAQAIAAUJyAlWBwBtAQAAAA==.欧皇小十六:BAAALgAFFAQJBAAAAA==.欧皇小十四:BAAALgAFFAMJBAAAAA==.',
['歌舞']='歌舞:BAAALgAECgUJBQAAAA==.',
['歐皇']='歐皇小十一:BAABLgAFFH8MAAIIAAQJmxJHCgBFAQAIAAQJmxJHCgBFAQAAAA==.歐皇小十九:BAAALgAFFAQJBAAAAA==.歐皇小十二:BAABLgAFFH8KAAIIAAQJjBrWBgB2AQAIAAQJjBrWBgB2AQAAAA==.',
['潜德']='潜德秘行:BAAALgAECgYJCgAAAA==.',
['灬独']='灬独家记忆灬:BAAALgAECgEJAQAAAA==.',
['焦糖']='焦糖:BAAALgAECgIJAgAAAA==.',
['狐悠']='狐悠人:BAAALgADCgQJBAAAAA==.',
['猫猫']='猫猫:BAACLgAFFH8GAAIEAAMJexojDQAIAQAEAAMJexojDQAIAQAuAAQKfxoAAgQABwlBIMsYAFACAAQABwlBIMsYAFACAAAA.',
['环保']='环保春哥:BAAALgAECgIJAwAAAA==.',
['白豌']='白豌豆:BAAALgAFFAIJAgAAAA==.',
['真有']='真有你的:BAAALgADCgYJBgAAAA==.',
['筱羙']='筱羙:BAAALgAECgYJCQAAAA==.',
['糖果']='糖果人:BAAALgAECgYJDQAAAA==.',
['紫色']='紫色的圈圈:BAAALgAFFAEJAQAAAA==.',
['缇宝']='缇宝:BAAALgAECgEJAQABLgAECgIJAgABAAAAAA==.',
['羽川']='羽川翼:BAAALgADCgcJCAAAAA==.',
['舞夜']='舞夜悠靈彡:BAAALgAFFAEJAQAAAA==.',
['艾伦']='艾伦:BAAALgAECgcJCAAAAA==.',
['艾米']='艾米莉亚:BAAALgADCgYJDAAAAA==.',
['芙蓉']='芙蓉丨强上树:BAAALgAECgUJAQAAAA==.',
['苍穹']='苍穹丶无垠:BAAALgAECgIJAwAAAA==.苍穹之兵火:BAAALgAECgEJAQAAAA==.',
['葬我']='葬我以風:BAAALgADCgUJBQAAAA==.',
['藤歌']='藤歌小德:BAAALgAECgYJCQAAAA==.',
['表叔']='表叔:BAAALgAECgYJCwAAAA==.',
['觉非']='觉非:BAAALgAECgYJCgAAAA==.',
['诚实']='诚实的小菠萝:BAAALgADCgEJAQAAAA==.',
['辉仔']='辉仔:BAAALgADCgUJBQAAAA==.',
['辛多']='辛多雷女技司:BAAALgAECgUJBgAAAA==.辛多雷血骑士:BAAALgAECgQJBAAAAA==.',
['遐蝶']='遐蝶:BAAALgAECgIJAgAAAA==.',
['邪能']='邪能空虚公主:BAAALgAECgUJBQAAAA==.',
['郭源']='郭源潮:BAAALgAECgMJBAAAAA==.',
['野牛']='野牛一头:BAAALgAECgQJBAAAAA==.',
['锝镥']='锝镥铱:BAAALgAFFAEJAQAAAA==.',
['阿纳']='阿纳拉克:BAAALgADCgEJAQAAAA==.',
['陈一']='陈一:BAAALgADCgcJDQAAAA==.',
['陈書']='陈書:BAAALgAFFAEJAQAAAA==.',
['非洲']='非洲帝凯:BAAALgAECgQJBQAAAA==.',
['风儿']='风儿吹屁屁凉:BAAALgAECgEJAQAAAA==.',
['风烟']='风烟俱尽:BAAALgAECgQJBAAAAA==.',
['黑是']='黑是黑健康色:BAAALgAECgYJCgAAAA==.',
['龍貓']='龍貓饿魔:BAABLgAFFH8FAAIKAAMJ0CKwEgA8AQAKAAMJ0CKwEgA8AQABLgAFFAYJEwAKACggAA==.',
['龙形']='龙形小德:BAAALgAECgYJCgAAAA==.',
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
