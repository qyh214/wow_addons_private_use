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

local lookup = {'DemonHunter-Devourer','DemonHunter-Havoc','Unknown-Unknown','DeathKnight-Blood','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','Priest-Discipline','Priest-Holy','Rogue-Subtlety','DeathKnight-Unholy','Druid-Restoration',}
local provider = {region='CN',realm='纳沙塔尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bi='Bibo:BAAALgAECgEJAQAAAA==.',
Ki='Kiki:BAAALgAECgEJAQAAAA==.',
Mo='Moonbeam:BAAALgAECgYJDAAAAA==.',
Na='Nausicaa:BAAALgAECgYJBgAAAA==.',
Re='Recovery:BAAALgAFFAMJAwAAAA==.',
Ry='Ryokouu:BAAALgAFFAEJAQAAAA==.',
Sa='Sayuki:BAAALgAECgYJDAAAAA==.',
Sh='Shalom:BAAALgAECgcJCQAAAA==.',
Ts='Tsukuba:BAAALgADCgcJBwAAAA==.',
Yi='Yigedh:BAACLgAFFH8IAAMBAAIJFyCtFQC/AAABAAIJFyCtFQC/AAACAAEJXw+ADQBQAAAuAAQKfxsAAwIACAmgHSwNAJACAAIABwnZICwNAJACAAEACAmaF+E0ACUCAAEuAAUUBQkDAAMAAAAA.',
['三魂']='三魂之玉:BAAALgAFFAEJAQAAAA==.',
['丶影']='丶影帝:BAAALgAECgcJBwAAAA==.',
['丶路']='丶路遥:BAAALgAFFAQJAwAAAA==.',
['仙丨']='仙丨魔:BAAALgAECgMJAwAAAA==.',
['你顶']='你顶住我叫人:BAAALgADCgQJBAAAAA==.',
['依文']='依文:BAABLgAECn8UAAIEAAgJ7xjeDgAfAgAEAAgJ7xjeDgAfAgAAAA==.',
['倦鸟']='倦鸟余花:BAAALgAECgcJBwAAAA==.',
['偷塑']='偷塑料贼:BAACLgAFFH8WAAIFAAYJBCJUAQBqAgAFAAYJBCJUAQBqAgAuAAQKfyEABAYACAk3IooGAIoCAAYABwk+JYoGAIoCAAUABQkCIGgfAMcBAAcABAl5FJ4tAAUBAAAA.',
['剑门']='剑门横行霸道:BAAALgAECgYJCAAAAA==.',
['加尔']='加尔鲁什:BAABLgAFFH8GAAIIAAMJFBjWBADPAAAIAAMJFBjWBADPAAAAAA==.',
['勇者']='勇者无畏:BAAALgADCgYJBwAAAA==.',
['北斗']='北斗圣启:BAAALgADCgQJBAAAAA==.北斗翳恴:BAAALgAECgYJDgAAAA==.',
['半拉']='半拉柯基:BAACLgAFFH8OAAIBAAYJNRC0BADhAQABAAYJNRC0BADhAQAuAAQKfxsAAwEACAkfHQ0tAEkCAAEACAkfHQ0tAEkCAAIAAQmKAzh5ACsAAAAA.',
['卡卡']='卡卡西锣:BAAALgAECgMJBQAAAA==.',
['卡琳']='卡琳:BAABLgAECn8UAAMJAAgJ5xeEFQCLAgAJAAgJ5xeEFQCLAgAKAAEJXwalkAAqAAAAAA==.',
['四枫']='四枫院夜一:BAABLgAECn8UAAMLAAgJgxrgFgCTAQALAAUJqhrgFgCTAQAMAAQJKRbxogASAQAAAA==.',
['士兵']='士兵男孩:BAAALgADCgcJBwAAAA==.',
['大学']='大学生活好吗:BAAALgAECgEJAQAAAA==.',
['如玉']='如玉:BAAALgADCgIJAgAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8NAAMNAAUJDg/3CABNAQANAAQJwRH3CABNAQAOAAEJRASpEgBPAAAAAA==.',
['小猪']='小猪呼噜:BAAALgAECgkJBgAAAA==.',
['小额']='小额信用贷:BAAALgADCgUJBQAAAA==.',
['岚霆']='岚霆破:BAAALgAFFAIJAwAAAA==.',
['强军']='强军先锋:BAAALgADCgEJAQAAAA==.',
['彼岸']='彼岸此岸:BAAALgAECgUJDwAAAA==.',
['怨灵']='怨灵射手:BAAALgAECgQJBAAAAA==.怨灵骑矢:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔的杀戮:BAAALgAECgYJCwAAAA==.恶魔的鲜血:BAAALgAFFAIJAgAAAA==.',
['我很']='我很瘦丶:BAAALgAECgYJCwAAAA==.',
['我是']='我是胖子丶:BAAALgAECggJDQAAAA==.',
['掌门']='掌门驴:BAAALgAECgcJCQAAAA==.',
['敖蕾']='敖蕾莉亚:BAAALgADCgcJCQAAAA==.',
['无聊']='无聊的牛:BAAALgADCgIJAgAAAA==.',
['暗之']='暗之魔鬼修罗:BAAALgAECgYJEAAAAA==.',
['暗影']='暗影天使:BAAALgADCgQJBAAAAA==.',
['杀破']='杀破羊:BAABLgAECn8ZAAIPAAgJWBLlGQA0AgAPAAgJWBLlGQA0AgAAAA==.',
['柳如']='柳如烟:BAAALgAECgIJAgAAAA==.',
['永生']='永生的伯爵:BAAALgAECgEJAQAAAA==.',
['波涛']='波涛汹涌丶:BAAALgAECgIJAgAAAA==.',
['淡淡']='淡淡的龙井茶:BAAALgAECgIJAgAAAA==.',
['深红']='深红毒蛇:BAAALgAECgEJAQAAAA==.',
['潇雨']='潇雨唲:BAAALgAECgMJAwAAAA==.',
['炎耀']='炎耀天:BAAALgAECgYJDwAAAA==.',
['炸鸡']='炸鸡汉堡:BAABLgAFFH8IAAIQAAMJ6hmEEAAGAQAQAAMJ6hmEEAAGAQAAAA==.',
['猪柳']='猪柳蛋好吃:BAAALgADCgEJAQAAAA==.',
['瑟理']='瑟理亚德唧唧:BAAALgAECgEJAgAAAA==.',
['祝您']='祝您永不窜稀:BAAALgAECgEJAQAAAA==.',
['神不']='神不知鬼不觉:BAAALgAECgkJCQAAAA==.',
['禅意']='禅意人生:BAAALgAECgcJEAAAAA==.',
['織部']='織部猎:BAABLgAFFH8HAAIJAAMJ7x57DgDbAAAJAAMJ7x57DgDbAAAAAA==.',
['红舞']='红舞鞋钢琴弦:BAAALgAECgQJBAAAAA==.',
['自寻']='自寻死路丶:BAAALgAECgMJAwAAAA==.',
['艺德']='艺德芙奶:BAAALgADCgMJAwAAAA==.',
['花堪']='花堪折:BAAALgADCgYJBgAAAA==.',
['莫宁']='莫宁斯塔:BAAALgAECgYJCwAAAA==.',
['莫小']='莫小加:BAABLgAECn8UAAIRAAgJixXEKAARAgARAAgJixXEKAARAgAAAA==.',
['萨博']='萨博尼斯:BAAALgAECgUJBgAAAA==.',
['邪歪']='邪歪歪:BAAALgADCgEJAQAAAA==.',
['邪灬']='邪灬:BAAALgAECgUJBwAAAA==.',
['重生']='重生灰烬:BAAALgADCgUJBQAAAA==.',
['阿宝']='阿宝龙骑士:BAAALgAECgUJBQAAAA==.',
['非常']='非常法:BAAALgADCgYJBgAAAA==.',
['魔羽']='魔羽飞狼:BAAALgAECgYJCAAAAA==.',
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
