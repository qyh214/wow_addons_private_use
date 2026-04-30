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

local lookup = {'Mage-Frost','DemonHunter-Devourer','Paladin-Holy','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Restoration','Warlock-Demonology','Hunter-BeastMastery','Druid-Balance','Shaman-Elemental','Monk-Brewmaster','Warrior-Fury','Warrior-Arms','Priest-Holy','Hunter-Marksmanship','Warrior-Protection',}
local provider = {region='CN',realm='瓦拉纳',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Aspirantx:BAAALgADCgYJBQAAAA==.',
Fa='Faker:BAAALgAECgEJAQAAAA==.',
Ho='Honeje:BAAALgAFFAEJAQAAAA==.Hooib:BAAALgAECgIJAgAAAA==.',
Hu='Husky:BAAALgADCgQJBAAAAA==.',
Is='Isabella:BAAALgAECgEJAQABLgAFFAMJBwABAEEcAA==.Isbella:BAABLgAFFH8HAAIBAAMJQRz7IwAnAQABAAMJQRz7IwAnAQAAAA==.',
Ju='Juny:BAAALgAECgkJAQAAAA==.',
Mo='Monondy:BAAALgAECgEJAQAAAA==.',
Ob='Oblivionis:BAAALgAFFAQJBAAAAA==.',
Ti='Timgmcgraw:BAAALgAECgYJBgAAAA==.',
To='Tocci:BAAALgAFFAQJBAAAAA==.',
Ve='Vermiccelli:BAAALgAFFAIJBAAAAA==.Vermicellii:BAABLgAFFH8HAAICAAQJKAOaGQADAQACAAQJKAOaGQADAQAAAA==.Vermiicelli:BAABLgAFFH8FAAICAAMJfwReIQDGAAACAAMJfwReIQDGAAAAAA==.',
We='Wearhgw:BAAALgAECgIJAgAAAA==.',
Ym='Ymwdh:BAAALgAFFAIJAgAAAA==.',
Zo='Zoro:BAABLgAECn8UAAMDAAcJaxhvJQD6AQADAAcJaxhvJQD6AQAEAAEJIBrOZABQAAAAAA==.',
['一只']='一只小肉丸丸:BAABLgAFFH8LAAMFAAUJLRt5BQBiAQAFAAQJLRt5BQBiAQAGAAEJAAAwDgAAAAAAAA==.',
['一号']='一号萨满:BAABLgAFFH8QAAIHAAYJFB0ZAQC+AQAHAAYJFB0ZAQC+AQAAAA==.',
['不玩']='不玩瞎子:BAAALgAECgYJBgAAAA==.',
['东北']='东北一枝花:BAAALgAECgYJCwAAAA==.',
['丶澄']='丶澄:BAAALgAECgQJCAAAAA==.',
['乂乜']='乂乜乜:BAAALgAECgcJBwAAAA==.',
['么喵']='么喵老紫:BAAALgAFFAIJBAAAAA==.',
['二号']='二号萨满:BAABLgAFFH8HAAIHAAUJ2A1+BACKAQAHAAUJ2A1+BACKAQAAAA==.',
['二相']='二相控阵:BAAALgAECgkJEwAAAA==.',
['伢伢']='伢伢:BAAALgAFFAQJBAAAAA==.',
['你后']='你后面有东西:BAAALgAFFAEJAQAAAA==.',
['優子']='優子快樂醬:BAAALgAECgYJBgAAAA==.',
['冻冻']='冻冻回魂夜:BAAALgAECgIJAgAAAA==.',
['千翻']='千翻万翻:BAAALgAECgUJCAAAAA==.',
['博学']='博学者爆爆:BAAALgADCggJCAAAAA==.',
['叁相']='叁相控阵:BAAALgAFFAQJBAAAAA==.',
['又一']='又一菜鸟:BAAALgAECgMJAwAAAA==.',
['可楽']='可楽壹号:BAAALgADCgUJBQAAAA==.',
['君为']='君为谁狂:BAAALgAECgEJAQAAAA==.',
['啊睿']='啊睿嘎嘣脆:BAAALgAECggJCQAAAA==.',
['喜乐']='喜乐星:BAAALgAECgkJCQAAAA==.',
['喝杯']='喝杯娃哈哈:BAABLgAFFH8KAAIIAAMJkCG9DgAZAQAIAAMJkCG9DgAZAQAAAA==.',
['嘣嘣']='嘣嘣脆啊睿:BAAALgAECgQJBQAAAA==.',
['圣兮']='圣兮:BAAALgAECgkJBQAAAA==.',
['壹杖']='壹杖叁:BAAALgAECgUJBwAAAA==.',
['夜战']='夜战八芳:BAABLgAFFH8GAAIJAAMJHRitCAAUAQAJAAMJHRitCAAUAQAAAA==.',
['夜莺']='夜莺咏叹:BAAALgAECgEJAQAAAA==.',
['夜雨']='夜雨漲秋池:BAAALgAECgcJBwAAAA==.',
['妖之']='妖之林:BAAALgAECgYJEwABLgAECgcJGAAKAD0cAA==.',
['射手']='射手粘不粘:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊点水:BAAALgAFFAIJAgAAAA==.',
['小龙']='小龙女丶:BAAALgAECgYJBgAAAA==.',
['就是']='就是嘉泽:BAAALgAECgEJAgAAAA==.',
['幼儿']='幼儿园徐老师:BAAALgAECgMJAwAAAA==.',
['幽灵']='幽灵虎:BAAALgAFFAQJBAAAAA==.',
['弦千']='弦千钧:BAAALgAECgYJDQAAAA==.',
['强哥']='强哥好爽:BAAALgAECgIJAgAAAA==.',
['德国']='德国张曼玉:BAABLgAFFH8IAAILAAQJLQvuCwAtAQALAAQJLQvuCwAtAQAAAA==.',
['总之']='总之很可爱:BAABLgAFFH8GAAIBAAIJEBKyPQCxAAABAAIJEBKyPQCxAAAAAA==.',
['我只']='我只负责萌丶:BAAALgADCgcJBwAAAA==.',
['打过']='打过来了:BAAALgADCgEJAQAAAA==.',
['抗刀']='抗刀小丸丸:BAABLgAFFH8IAAIFAAQJCBJoFgBKAQAFAAQJCBJoFgBKAQAAAA==.抗刀小仙女:BAABLgAFFH8HAAIFAAQJ+haKEQBbAQAFAAQJ+haKEQBbAQAAAA==.抗刀小小仙女:BAACLgAFFH8HAAIFAAQJgBNCFgBLAQAFAAQJgBNCFgBLAQAuAAQKfxoAAgUACQknHvERABADAAUACQknHvERABADAAAA.',
['拂晓']='拂晓八月:BAAALgAECgcJCQAAAA==.',
['拉丝']='拉丝芝士棒:BAAALgAFFAIJBAAAAA==.',
['敖悠']='敖悠莱:BAAALgADCgMJAgAAAA==.',
['断角']='断角大师:BAAALgADCgMJAwAAAA==.',
['日暮']='日暮死骑:BAAALgAFFAIJAgAAAA==.',
['是你']='是你依然:BAAALgAECgkJAQAAAA==.',
['杨大']='杨大力:BAAALgAECgYJEAAAAA==.',
['柚子']='柚子苗:BAAALgAECgYJBgAAAA==.',
['格罗']='格罗玛什飒尔:BAABLgAFFH8FAAILAAMJtAxiCQDeAAALAAMJtAxiCQDeAAABLgAFFAQJCQAMAEIMAA==.',
['椭奇']='椭奇:BAAALgAFFAQJBAAAAA==.',
['汝汝']='汝汝:BAAALgAECgEJAQAAAA==.',
['汤加']='汤加:BAAALgAECggJDAAAAA==.',
['沈幼']='沈幼楚:BAAALgAECgEJAQAAAA==.',
['海角']='海角九十九号:BAAALgADCgEJAQAAAA==.',
['淡云']='淡云丶流水:BAAALgAECgQJCQAAAA==.',
['清辉']='清辉夜凝丶:BAAALgADCgEJAQAAAA==.',
['溧阳']='溧阳人民广场:BAAALgAFFAIJAgAAAA==.',
['烈风']='烈风语者:BAAALgAECgYJCAAAAA==.',
['烟蝶']='烟蝶:BAAALgAECgQJBAAAAA==.',
['焚曜']='焚曜千星:BAACLgAFFH8HAAMNAAMJIxrUFQC2AAANAAIJuxzUFQC2AAAOAAEJ8hS6CQBcAAAuAAQKfxkAAw0ABgnTIugnAB4CAA0ABQmbJegnAB4CAA4AAwk4G7kgAOcAAAAA.',
['爱丽']='爱丽丝:BAAALgAECgkJEgAAAA==.',
['爱摸']='爱摸鱼的老乡:BAAALgAECgEJAQAAAA==.',
['牛柚']='牛柚丸丸:BAABLgAFFH8FAAIFAAQJYQk3GwA3AQAFAAQJYQk3GwA3AQAAAA==.',
['牛计']='牛计吧:BAAALgAECgYJDAAAAA==.',
['狐丶']='狐丶浅浅:BAAALgADCgYJBgAAAA==.',
['王雷']='王雷的懒趴:BAAALgAFFAIJAgAAAA==.',
['甜甜']='甜甜豆腐脑:BAAALgAECgIJAgAAAA==.',
['疏年']='疏年:BAABLgAFFH8LAAIMAAQJjQ+1DAAfAQAMAAQJjQ+1DAAfAQAAAA==.',
['白彡']='白彡夜:BAAALgAFFAQJBAAAAA==.',
['白露']='白露澈明:BAAALgAFFAEJAQABLgAFFAMJBwANACMaAA==.',
['百翻']='百翻日翻:BAAALgAECgEJAQAAAA==.',
['看不']='看不出来:BAAALgAECgEJAgAAAA==.',
['短毛']='短毛毛妹:BAAALgAECgIJAgAAAA==.',
['破阵']='破阵铁骑:BAAALgAFFAQJBAAAAA==.',
['祖卡']='祖卡麻拉:BAAALgAFFAIJAgAAAA==.',
['秋風']='秋風知我意:BAAALgAECgkJCwAAAA==.',
['称胸']='称胸到蒂:BAAALgAECgYJAQAAAA==.',
['紫丨']='紫丨颜:BAAALgAFFAQJBAAAAA==.',
['紫罗']='紫罗兰学徒:BAAALgAECgkJDgABLgAFFAUJBwABAMcZAA==.',
['织雾']='织雾:BAAALgAECgcJDgAAAA==.',
['继续']='继续千翻:BAAALgAECgIJAgAAAA==.',
['脆脆']='脆脆鲨:BAABLgAFFH8HAAIEAAMJ1SASDwAwAQAEAAMJ1SASDwAwAQABLgAFFAYJCAAPAA4aAA==.',
['萨满']='萨满十一号:BAABLgAFFH8IAAIHAAQJhBWbBwBMAQAHAAQJhBWbBwBMAQAAAA==.',
['葱油']='葱油饼:BAAALgAECgcJBwAAAA==.',
['西游']='西游没文化:BAAALgAECgIJAgAAAA==.',
['谢宝']='谢宝树:BAAALgAECgQJCgAAAA==.',
['贰相']='贰相控阵:BAAALgAFFAQJBAAAAA==.',
['超龄']='超龄老木:BAAALgADCgEJAQAAAA==.',
['迦尔']='迦尔拉:BAAALgAECgEJAQAAAA==.',
['迷失']='迷失的烈:BAAALgAECgkJCQAAAA==.',
['酒伍']='酒伍:BAAALgAECgEJAQAAAA==.',
['酒壹']='酒壹:BAAALgAECgYJBgAAAA==.',
['酒拾']='酒拾:BAAALgAFFAIJAgAAAA==.',
['酒柒']='酒柒:BAAALgAECgYJBgAAAA==.',
['酒玖']='酒玖:BAAALgAECgIJAgAAAA==.',
['酒肆']='酒肆:BAAALgAFFAIJAgAAAA==.',
['酒贰']='酒贰:BAAALgAFFAQJBAABLgAFFAQJBgAMAFUbAA==.',
['酒陆']='酒陆:BAABLgAFFH8IAAIMAAQJAAbMCAAIAQAMAAQJAAbMCAAIAQAAAA==.',
['酱焖']='酱焖牛至:BAABLgAFFH8IAAMJAAQJZBxfCQAOAQAJAAMJJxZfCQAOAQAQAAMJXhoAEwAMAQAAAA==.',
['闪转']='闪转腾挪:BAAALgADCgIJAgAAAA==.',
['问剑']='问剑白玉京:BAAALgAECgYJCwAAAA==.',
['阿卡']='阿卡琉斯:BAAALgAECgIJAgAAAA==.',
['阿喵']='阿喵小武僧:BAAALgAFFAQJBAAAAA==.',
['陈都']='陈都灵:BAAALgAECgMJBAAAAA==.',
['雅丽']='雅丽马斯内:BAAALgADCgEJAQAAAA==.',
['雷二']='雷二喵:BAACLgAFFH8FAAIGAAIJ/QoaEABwAAAGAAIJ/QoaEABwAAAuAAQKfyoAAgYACQnsGVYCABkCAAYACQnsGVYCABkCAAAA.',
['飞机']='飞机虎虎:BAAALgAECgMJBgABLgAFFAUJEwARAL8dAA==.',
['饭特']='饭特稀:BAAALgAECgcJCAAAAA==.',
['香菜']='香菜猫饼:BAAALgAFFAQJBAAAAA==.',
['黑杯']='黑杯:BAAALgADCgIJAgABLgAFFAQJCQAFAH4gAA==.',
['龙鳞']='龙鳞马:BAAALgAECgYJBgAAAA==.',
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
