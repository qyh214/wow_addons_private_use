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

local lookup = {'Paladin-Retribution','Mage-Frost','Evoker-Preservation','Monk-Brewmaster','Evoker-Devastation','Evoker-Augmentation','Rogue-Subtlety','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','Unknown-Unknown','Warlock-Affliction','DemonHunter-Devourer','Priest-Discipline',}
local provider = {region='CN',realm='奥杜尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alin:BAAALgADCgYJBgAAAA==.',
Ce='Cesare:BAAALgADCgUJBQAAAA==.',
Ka='Kasugano:BAAALgAECgYJDAAAAA==.',
Pl='Pluto:BAAALgADCgYJBgAAAA==.',
Re='Redarrow:BAAALgAFFAIJAgAAAA==.',
Rv='Rvp:BAAALgAECgEJAQAAAA==.',
Sa='Satori:BAAALgAECgUJBQAAAA==.',
['不如']='不如跳舞丶:BAAALgAECgMJAwAAAA==.',
['丶巴']='丶巴哈姆特:BAAALgADCgYJBgAAAA==.',
['乐享']='乐享网咖:BAAALgAECgEJAQAAAA==.',
['二哈']='二哈:BAAALgADCgEJAQAAAA==.',
['云雾']='云雾踏风:BAAALgAECgYJBgAAAA==.',
['信之']='信之所向:BAAALgAECgIJAgAAAA==.',
['修马']='修马呀修马:BAACLgAFFH8GAAIBAAIJLwsfJwCbAAABAAIJLwsfJwCbAAAuAAQKfxcAAgEABwmvHgc3AEcCAAEABwmvHgc3AEcCAAAA.',
['克尔']='克尔苏缺德:BAAALgADCgYJBgAAAA==.',
['再逝']='再逝传奇:BAABLgAFFH8HAAICAAQJpBuCBwBwAQACAAQJpBuCBwBwAQAAAA==.',
['冬日']='冬日可爱:BAABLgAFFH8IAAIDAAQJUBwPCwA5AQADAAQJUBwPCwA5AQABLgAFFAYJDwADAF4VAA==.冬日暖阳:BAACLgAFFH8FAAIBAAIJtQ4IIwCmAAABAAIJtQ4IIwCmAAAuAAQKfxkAAgEABwkyFjlUAOUBAAEABwkyFjlUAOUBAAAA.',
['凯恩']='凯恩死蹄:BAAALgADCgMJAwAAAA==.',
['南宫']='南宫灬逸轩:BAAALgAECgYJBgAAAA==.',
['古德']='古德埃迪尔:BAAALgAECgUJBQAAAA==.',
['吃奶']='吃奶:BAAALgADCgEJAQAAAA==.',
['吱吱']='吱吱:BAAALgAFFAQJBAABLgAFFAYJDwADAF4VAA==.',
['啊璐']='啊璐璐:BAAALgAECgcJCQAAAA==.',
['啤酒']='啤酒人:BAABLgAFFH8LAAIEAAQJdA6lBgAoAQAEAAQJdA6lBgAoAQAAAA==.',
['土豆']='土豆炖牛肉:BAAALgADCgYJBgAAAA==.',
['圣光']='圣光帮帮忙:BAAALgADCgEJAgAAAA==.圣光狡诈者:BAAALgAECgEJAQAAAA==.',
['地板']='地板先粘的我:BAAALgAFFAEJAQAAAA==.',
['夏日']='夏日可畏:BAABLgAFFH8MAAQDAAQJhRppAwBtAQADAAQJhRppAwBtAQAFAAEJSh1OCABdAAAGAAEJ4BXKIABPAAABLgAFFAYJDwADAF4VAA==.',
['夏洛']='夏洛特丶玲玲:BAAALgAECgEJAQAAAA==.',
['大声']='大声发:BAAALgADCgIJAgAAAA==.',
['大锤']='大锤仈十:BAAALgAECgYJBgAAAA==.',
['妹妹']='妹妹有魅魔:BAAALgAECgIJAgAAAA==.',
['寂静']='寂静无声:BAAALgAFFAEJAQAAAA==.',
['寒洋']='寒洋:BAAALgAECgUJCQAAAA==.',
['小可']='小可欣:BAAALgAECgIJAgAAAA==.',
['小贱']='小贱客:BAAALgADCgEJAQAAAA==.',
['小越']='小越越:BAACLgAFFH8GAAICAAMJUQNLHADXAAACAAMJUQNLHADXAAAuAAQKfxQAAgIACAnBD0NwAPMBAAIACAnBD0NwAPMBAAAA.',
['小锤']='小锤四什:BAAALgAECgYJCAAAAA==.',
['少月']='少月:BAAALgAECgkJBwAAAA==.',
['尖尸']='尖尸器:BAABLgAECn8UAAIHAAYJHA2BEAD3AAAHAAYJHA2BEAD3AAAAAA==.',
['巴伊']='巴伊大老爷:BAABLgAECn8WAAICAAYJrxMeowCRAQACAAYJrxMeowCRAQAAAA==.',
['帕雷']='帕雷德斯:BAAALgAECgcJDgAAAA==.',
['开局']='开局一个碗:BAAALgAECgQJAwAAAA==.',
['归来']='归来:BAAALgADCgEJAQAAAA==.',
['影山']='影山飞雄:BAAALgAECgEJAQAAAA==.',
['心之']='心之所想:BAAALgAECgUJCAAAAA==.',
['快龙']='快龙侠:BAECLgAFFH8TAAMIAAYJEh6wAQCrAQAJAAUJgBiyAQDFAQAIAAUJEyOwAQCrAQAuAAQKfxoAAwgACAlSJEAUANwCAAgABwntJEAUANwCAAkABAlYIvwXAIoBAAAA.',
['恶魔']='恶魔小妹妹:BAAALgADCgEJAQAAAA==.',
['愤怒']='愤怒德驴:BAAALgAECgEJAQAAAA==.',
['我不']='我不是宠物:BAABLgAFFH8TAAIKAAUJoyPQAAAEAgAKAAUJoyPQAAAEAgAAAA==.',
['我是']='我是奶龙:BAAALgAECgMJAwABLgAFFAUJEwAKAKMjAA==.',
['我曾']='我曾信仰圣光:BAAALgAECgYJBgABLgAFFAIJAgALAAAAAA==.',
['扎心']='扎心:BAAALgADCgEJAQAAAA==.',
['放空']='放空灬去旅行:BAAALgAECgYJBgAAAA==.',
['日之']='日之艾拉:BAAALgAECgYJCwAAAA==.',
['昨夜']='昨夜辰星:BAAALgAECgYJEQAAAA==.',
['暗影']='暗影之心:BAAALgADCgYJCQAAAA==.暗影镰接:BAAALgAFFAIJBAAAAA==.',
['朴信']='朴信女:BAAALgAECgkJCQAAAA==.',
['枝枝']='枝枝:BAAALgAFFAIJAgABLgAFFAYJDwADAF4VAA==.',
['橙黏']='橙黏人:BAABLgAECn8UAAMIAAYJLCEnZgCZAQAIAAUJMR4nZgCZAQAMAAMJpBmpEwD0AAAAAA==.',
['死亡']='死亡如影随行:BAAALgAECgEJAgAAAA==.',
['比朱']='比朱古亮还亮:BAAALgAFFAEJAQAAAA==.',
['河马']='河马电竞:BAAALgADCgEJAQAAAA==.',
['洛日']='洛日:BAAALgAECgIJAgAAAA==.',
['浑天']='浑天象:BAACLgAFFH8MAAINAAUJrBn+BgC0AQANAAUJrBn+BgC0AQAuAAQKfxsAAg0ACQmwHUEPAAUDAA0ACQmwHUEPAAUDAAEuAAUUBgkSAAYAoCAA.',
['消费']='消费:BAAALgADCgUJBQAAAA==.',
['灬颜']='灬颜唯柒灬:BAAALgAECgEJAQAAAA==.',
['灵衣']='灵衣兮被被:BAAALgAECgMJBgAAAA==.',
['熊猫']='熊猫仔:BAAALgAECgYJDAAAAA==.',
['牛牛']='牛牛很屁牛:BAAALgAECgkJCQAAAA==.',
['狗尔']='狗尔丹:BAAALgADCgYJBgAAAA==.',
['玄鸟']='玄鸟灬惊春风:BAAALgAFFAQJAwAAAA==.',
['玛雅']='玛雅丶妲婕妮:BAAALgAECgEJAQAAAA==.',
['硕大']='硕大哥哥:BAAALgAECgEJAQAAAA==.',
['神话']='神话嗜血法爺:BAAALgAECgIJAgAAAA==.',
['科比']='科比布莱恩特:BAAALgAECgIJAQAAAA==.',
['穿过']='穿过人山人海:BAAALgAECgQJBwAAAA==.',
['紫陌']='紫陌:BAAALgAECgEJAQAAAA==.',
['絕版']='絕版尐強:BAAALgAECgEJAgAAAA==.',
['纳瑞']='纳瑞安丶银风:BAAALgAECggJDQAAAA==.',
['老衲']='老衲老洗头:BAAALgAECgEJAgAAAA==.',
['耍娃']='耍娃儿噜哒哒:BAAALgAECgMJAwAAAA==.',
['肉蛋']='肉蛋充饥:BAAALgAECgMJAwAAAA==.',
['肥肠']='肥肠可乐:BAAALgAECgMJBAAAAA==.',
['脑子']='脑子离家出走:BAAALgAFFAEJAQAAAA==.',
['艾莉']='艾莉丝:BAAALgAFFAEJAQAAAA==.',
['花开']='花开丶季节:BAAALgAECgIJAgAAAA==.',
['苏八']='苏八吃肉:BAAALgAFFAIJAwAAAA==.',
['荷畔']='荷畔:BAAALgAECgEJAQAAAA==.',
['蒲公']='蒲公英的旅行:BAAALgAECgYJBwAAAA==.',
['蜡笔']='蜡笔小心眼子:BAAALgAECgMJAwAAAA==.',
['西江']='西江雪:BAAALgADCgMJAwAAAA==.',
['诗悠']='诗悠洛:BAAALgAECgEJAQAAAA==.',
['谷尔']='谷尔德:BAAALgAECgYJDgABLgAECgYJFAAIACwhAA==.',
['迷丶']='迷丶离:BAAALgADCgYJBgAAAA==.',
['那个']='那个输出:BAAALgAFFAEJAQAAAA==.',
['邪能']='邪能路由器:BAAALgAECgYJCQAAAA==.',
['野荷']='野荷丶:BAAALgAECgYJBgAAAA==.',
['阿瓜']='阿瓜哥哥:BAAALgAECgIJAgAAAA==.',
['雷丶']='雷丶德:BAAALgADCgEJAQAAAA==.',
['风尘']='风尘丶钕孓:BAAALgADCgMJAwAAAA==.',
['骑士']='骑士我最怂:BAAALgAFFAMJAwAAAA==.',
['骑迹']='骑迹:BAAALgAECgEJAQAAAA==.',
['鬼烧']='鬼烧丶暴风:BAAALgAECgcJCQAAAA==.',
['鹿小']='鹿小然:BAABLgAFFH8NAAIOAAQJZwv3CgAvAQAOAAQJZwv3CgAvAQAAAA==.',
['黑胡']='黑胡椒肋排:BAAALgAFFAIJBAAAAA==.',
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
