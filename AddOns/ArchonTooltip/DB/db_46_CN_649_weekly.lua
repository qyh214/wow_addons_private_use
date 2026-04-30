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

local lookup = {'Shaman-Elemental','Priest-Holy','Rogue-Subtlety','Unknown-Unknown','DemonHunter-Devourer','Monk-Windwalker','Mage-Frost','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Unholy','Warrior-Fury','Druid-Balance','Druid-Restoration',}
local provider = {region='CN',realm='安加萨',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ch='Choose:BAACLgAFFH8KAAIBAAQJRBrMAQBsAQABAAQJRBrMAQBsAQAuAAQKf3IAAgEACQlAIeYQAJ8CAAEACQlAIeYQAJ8CAAAA.',
Cr='Creepyc:BAAALgAECgkJCQAAAA==.',
Do='Dokho:BAAALgAECgYJBgAAAA==.',
Ho='Holycow:BAAALgAECgEJAQAAAA==.',
Kl='Klitht:BAAALgADCgUJBQAAAA==.',
Mi='Minusqaq:BAAALgAECgUJCAAAAA==.',
Ms='Ms:BAABLgAFFH8FAAICAAIJ2xmgCwCoAAACAAIJ2xmgCwCoAAAAAA==.',
St='Starrysky:BAAALgAECgYJBgAAAA==.',
Ti='Tinyff:BAAALgAECgMJBQAAAA==.',
Vo='Voidzz:BAAALgAECgYJCgAAAA==.',
Xm='Xmgyoqzpyvff:BAACLgAFFH8KAAIDAAQJthffBgByAQADAAQJthffBgByAQAuAAQKfxUAAgMACQl5EqgYAEECAAMACQl5EqgYAEECAAAA.',
['一直']='一直很随便:BAAALgADCgEJAQAAAA==.',
['不落']='不落皇旗前:BAAALgAFFAEJAwAAAA==.',
['不蓝']='不蓝角:BAAALgAECgEJAQAAAA==.',
['不见']='不见岳:BAAALgAECgIJAgABLgAFFAIJAwAEAAAAAA==.',
['丨歐']='丨歐皇毛丨:BAAALgAFFAEJAQAAAA==.',
['他整']='他整晚在写信:BAAALgAECgIJAgAAAA==.',
['以曦']='以曦为贵:BAAALgAECgYJBgAAAA==.',
['伊利']='伊利蛋:BAABLgAECn8bAAIFAAcJ+BSNRgDZAQAFAAcJ+BSNRgDZAQAAAA==.',
['信得']='信得很:BAAALgAECgIJAgAAAA==.',
['倔强']='倔强的火柴:BAAALgADCgEJAQAAAA==.',
['倾城']='倾城丶圣契:BAAALgAFFAMJAwAAAA==.',
['兄弟']='兄弟让我砍:BAAALgAECgMJAwAAAA==.',
['光明']='光明中的黑暗:BAAALgADCgQJBAAAAA==.',
['八亿']='八亿少女的梦:BAAALgAECgQJBAAAAA==.',
['凌晨']='凌晨三点:BAABLgAFFH8FAAIGAAMJKg2CCQDTAAAGAAMJKg2CCQDTAAAAAA==.',
['刘亦']='刘亦飞:BAAALgADCgUJBgAAAA==.',
['刘诗']='刘诗诗:BAAALgAECgEJAQABLgAFFAUJAQAEAAAAAA==.',
['北欧']='北欧女人:BAAALgAECgYJBgAAAA==.',
['千里']='千里无峰:BAAALgAECgMJBAAAAA==.',
['发光']='发光胡子美女:BAAALgADCgEJAQAAAA==.',
['古驰']='古驰:BAAALgADCgkJCQAAAA==.',
['可乐']='可乐小熊软糖:BAABLgAECn8YAAICAAYJpB1xHQDzAQACAAYJpB1xHQDzAQAAAA==.',
['右拳']='右拳打开了天:BAAALgAFFAEJAQAAAA==.',
['哟啊']='哟啊表提佛:BAAALgAECgMJAwAAAA==.',
['哩哩']='哩哩是笨蛋:BAAALgADCgQJAgAAAA==.',
['坏狗']='坏狗:BAAALgAECgYJEQABLgAFFAUJBQAGAHUdAA==.',
['坚强']='坚强别离:BAAALgAECgcJDwAAAA==.',
['夜影']='夜影丶业业:BAAALgADCgEJAQAAAA==.',
['大碗']='大碗饺子:BAACLgAFFH8NAAIHAAQJBRSVCwA8AQAHAAQJBRSVCwA8AQAuAAQKfyAAAgcABwmVIEQ2AJsCAAcABwmVIEQ2AJsCAAAA.',
['大领']='大领主:BAAALgADCgEJAQAAAA==.',
['天授']='天授诗人:BAAALgAECgIJAgAAAA==.',
['太宰']='太宰治:BAAALgAECgIJAgABLgAFFAIJAwAEAAAAAA==.',
['奥法']='奥法猫:BAAALgADCgEJAQAAAA==.',
['妖咻']='妖咻丶鹌:BAAALgAECgIJAgAAAA==.',
['姐爱']='姐爱加血:BAAALgAECgIJAgAAAA==.',
['安德']='安德麦小萨:BAAALgAECgEJAQAAAA==.',
['宫胁']='宫胁咲良:BAAALgADCgMJAwAAAA==.',
['宮脇']='宮脇咲良:BAAALgAFFAEJAgAAAA==.',
['小别']='小别兔别又别:BAAALgAECgUJBQAAAA==.',
['小宽']='小宽野:BAAALgAECgYJCAAAAA==.',
['小新']='小新:BAAALgAECgYJBgAAAA==.',
['小朱']='小朱诺诺的:BAAALgAFFAIJAwAAAA==.',
['小楼']='小楼扛扛怪:BAAALgAFFAIJAgAAAA==.',
['小龙']='小龙龙人:BAACLgAFFH8MAAIIAAQJMB+HAgB0AQAIAAQJMB+HAgB0AQAuAAQKfyEAAggACAmVIsMDAB8DAAgACAmVIsMDAB8DAAAA.',
['尘埃']='尘埃晓法:BAABLgAFFH8FAAIHAAMJngMxSwCRAAAHAAMJngMxSwCRAAAAAA==.',
['尼诺']='尼诺滴咕咕:BAAALgAECgQJBAAAAA==.',
['岁月']='岁月墨染:BAAALgAFFAIJBAAAAA==.',
['崔斯']='崔斯塔娜:BAAALgAECgIJAgAAAA==.',
['年迈']='年迈的大领主:BAAALgAFFAEJAgAAAA==.',
['影山']='影山茂夫:BAAALgAECgUJBQAAAA==.',
['德才']='德才兼备:BAAALgAECgYJBgAAAA==.',
['心术']='心术不歪:BAAALgADCgYJBgAAAA==.',
['忠贞']='忠贞至臻丶:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁的小白:BAAALgAECgkJCQAAAA==.',
['悠悠']='悠悠如梦:BAAALgADCgQJBAAAAA==.',
['懒强']='懒强仔:BAAALgAECgIJAgAAAA==.',
['我是']='我是奶龙:BAACLgAFFH8XAAIIAAYJ8AwmAwDaAQAIAAYJ8AwmAwDaAQAuAAQKfyQABAgACQmnEtQOAEsCAAgACQmnEtQOAEsCAAkAAgneA09QAIsAAAoAAwllBeoyAH4AAAAA.',
['更木']='更木剣八:BAAALgADCgEJAQAAAA==.',
['曾经']='曾经丶:BAAALgAECgEJAQAAAA==.',
['李冰']='李冰冰:BAAALgAFFAIJAgABLgAFFAUJAQAEAAAAAA==.',
['李思']='李思思:BAAALgAFFAQJBAABLgAFFAUJAQAEAAAAAA==.',
['李慧']='李慧珍:BAAALgAECgEJAQAAAA==.',
['材料']='材料仓库一:BAAALgADCgEJAQAAAA==.',
['杰森']='杰森伯恩丶:BAAALgAECgcJCAAAAA==.',
['欢乐']='欢乐的小淇:BAAALgADCgEJAQAAAA==.',
['歧客']='歧客:BAABLgAFFH8KAAILAAMJyRuCJQAAAQALAAMJyRuCJQAAAQAAAA==.',
['沉默']='沉默狮子:BAAALgAECgYJBQAAAA==.',
['流年']='流年罒反:BAAALgAECgYJBgAAAA==.',
['淡之']='淡之:BAAALgAECgQJCAAAAA==.',
['清蒸']='清蒸羊肾丶:BAAALgAECgEJAQAAAA==.',
['灵魄']='灵魄守卫:BAAALgAECgYJCgAAAA==.',
['熊喵']='熊喵酒仙:BAAALgAFFAIJAgAAAA==.',
['牧濑']='牧濑红莉栖:BAAALgAECgYJBgAAAA==.',
['猗窝']='猗窝座:BAAALgAECgYJCgABLgAECgcJBwAEAAAAAA==.',
['王冰']='王冰冰:BAAALgAFFAIJAgABLgAFFAUJAQAEAAAAAA==.',
['王豆']='王豆豆:BAAALgAFFAIJAgABLgAFFAUJAQAEAAAAAA==.',
['玛恩']='玛恩纳:BAAALgAECgYJBwAAAA==.',
['玫瑰']='玫瑰酒:BAAALgADCgcJCgAAAA==.',
['白牛']='白牛丷:BAAALgAECgEJAQABLgAFFAUJEQAMAKEZAA==.',
['盛夏']='盛夏商店:BAAALgAECgcJBgAAAA==.',
['神兽']='神兽黑子:BAAALgAECgcJBwAAAA==.',
['空格']='空格躲冰环:BAABLgAECn8UAAIHAAcJAB+aSQBaAgAHAAcJAB+aSQBaAgAAAA==.',
['等等']='等等星期四:BAAALgAFFAIJBAAAAA==.',
['筑基']='筑基高手:BAAALgAECgIJAwAAAA==.',
['繁花']='繁花似蓉:BAAALgAECgEJAQAAAA==.',
['绝望']='绝望大咕咕:BAAALgAECgYJBgAAAA==.绝望的圣光:BAAALgAECgMJBAAAAA==.绝望的幻月:BAAALgAECgQJBwAAAA==.',
['肚肚']='肚肚子:BAAALgAECgUJCAAAAA==.',
['脚指']='脚指头:BAAALgAECgcJBwAAAA==.',
['脚趾']='脚趾头:BAAALgAECgEJAQAAAA==.',
['艾露']='艾露恩之喵:BAABLgAECn8XAAMNAAcJ4QjZQwAfAQANAAcJ4QjZQwAfAQAOAAYJqA3FZwAbAQAAAA==.',
['苦痛']='苦痛:BAAALgAECgQJBAAAAA==.',
['萨骑']='萨骑马:BAAALgAECgIJAgAAAA==.',
['蕾欧']='蕾欧娜:BAAALgAECgQJBgAAAA==.',
['虎皮']='虎皮尖椒:BAAALgADCgYJBgAAAA==.',
['行云']='行云之月:BAAALgAECgEJAQAAAA==.',
['观一']='观一叶而知秋:BAAALgAECgkJCQAAAA==.',
['赤古']='赤古:BAAALgAECgMJAwAAAA==.',
['迷惘']='迷惘与清透间:BAAALgADCgMJAwAAAA==.',
['逍遥']='逍遥丨二郎拳:BAAALgAFFAQJBAAAAA==.逍遥丨六星拳:BAAALgAFFAMJAwAAAA==.',
['逐暗']='逐暗者:BAAALgAECgYJBgAAAA==.',
['邪念']='邪念:BAACLgAFFH8OAAIFAAUJaiCyBQDLAQAFAAUJaiCyBQDLAQAuAAQKfxYAAgUACAlyIksWANECAAUACAlyIksWANECAAAA.',
['酱爆']='酱爆:BAAALgAECgEJAgAAAA==.',
['钦差']='钦差丶大臣:BAAALgADCgEJAQAAAA==.',
['长的']='长的和谐点嘛:BAAALgAECgYJDQABLgAECgkJDAAEAAAAAA==.',
['闪电']='闪电五连鞭:BAAALgAFFAIJAgAAAA==.闪电哈基米:BAAALgAFFAIJBAAAAA==.闪电连五鞭:BAAALgAFFAEJAQAAAA==.',
['阿娜']='阿娜之光:BAAALgADCgEJAQAAAA==.',
['阿花']='阿花:BAAALgAECgQJBAAAAA==.',
['雪莉']='雪莉酒:BAAALgAECgYJDAAAAA==.',
['青梅']='青梅酒:BAAALgADCgIJAgAAAA==.',
['题序']='题序等你回丶:BAAALgAFFAIJAwAAAA==.',
['风流']='风流牛奶糖:BAAALgAECgIJAgAAAA==.',
['风雨']='风雨涤尘:BAAALgAECgMJAwAAAA==.',
['高大']='高大威:BAAALgAECgEJAgAAAA==.',
['鬼舞']='鬼舞辻無惨:BAAALgAECgcJCwAAAA==.',
['魔法']='魔法里给力:BAABLgAFFH8IAAILAAQJcRR9FQBNAQALAAQJcRR9FQBNAQAAAA==.',
['魔神']='魔神释天:BAAALgADCgEJAQAAAA==.',
['魔鬼']='魔鬼小辣椒:BAACLgAFFH8RAAIDAAUJgiC0AQDvAQADAAUJgiC0AQDvAQAuAAQKfx4AAgMACQnPJAsBAMEDAAMACQnPJAsBAMEDAAAA.',
['龍族']='龍族丶法爷:BAAALgAECgMJAwAAAA==.',
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
