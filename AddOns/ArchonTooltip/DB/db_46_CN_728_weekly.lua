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

local lookup = {'Mage-Frost','Priest-Holy','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Evoker-Augmentation','Evoker-Preservation','Paladin-Retribution','Paladin-Holy','Evoker-Devastation','Warrior-Protection','Unknown-Unknown','DemonHunter-Devourer','DemonHunter-Vengeance','Shaman-Restoration','Druid-Restoration',}
local provider = {region='CN',realm='泰拉尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Fa='Fantast:BAAALgAECgQJBAAAAA==.',
Fi='Finger:BAAALgADCgIJAgAAAA==.',
Ha='Harris:BAAALgADCgcJBwAAAA==.',
He='Herp:BAAALgADCgYJBgAAAA==.',
Le='Legcnd:BAAALgAECgYJDAAAAA==.',
No='Nopeace:BAAALgAFFAIJAwAAAA==.',
Or='Orion:BAAALgAECgcJBwAAAA==.',
Qi='Qing:BAAALgAECgEJAQAAAA==.',
Vi='Victim:BAACLgAFFH8FAAIBAAIJPRADGwCrAAABAAIJPRADGwCrAAAuAAQKfx8AAgEABwk6H+pIAFwCAAEABwk6H+pIAFwCAAAA.',
['三井']='三井血受:BAAALgADCgYJBgAAAA==.',
['上河']='上河图:BAAALgAECgEJAQAAAA==.',
['丝丝']='丝丝暧昧丶:BAAALgAFFAIJBAAAAA==.',
['丹丹']='丹丹熊:BAAALgAECgUJBQAAAA==.',
['井荷']='井荷花:BAACLgAFFH8MAAIBAAQJoh2aJwAVAQABAAQJoh2aJwAVAQAuAAQKfxoAAgEACQkqIFASADoDAAEACQkqIFASADoDAAAA.',
['传说']='传说的恶魔:BAAALgADCgIJAgAAAA==.',
['佐佐']='佐佐木绯世:BAAALgAECggJCwAAAA==.',
['佑崽']='佑崽:BAAALgAFFAIJAgAAAA==.',
['你可']='你可真高:BAAALgAECgcJDgAAAA==.',
['你就']='你就是块木头:BAACLgAFFH8MAAMCAAQJWBYpBwD+AAACAAMJ+BwpBwD+AAADAAMJjw5qDgDnAAAuAAQKfyIABAMACAn3G0YTABYCAAMABwmSGkYTABYCAAIABwm/E2knALMBAAQAAgmRCuUgADcAAAAA.',
['傲娇']='傲娇娇:BAAALgAFFAEJAQAAAA==.',
['冥灵']='冥灵居士:BAAALgAECgEJAQAAAA==.',
['千分']='千分之二的天:BAAALgAECgkJEwABLgAFFAQJBQAFAIMMAA==.',
['南风']='南风北至:BAAALgAECgEJAwAAAA==.',
['可可']='可可冰激凌:BAABLgAFFH8GAAIBAAMJdgQ7MQDqAAABAAMJdgQ7MQDqAAAAAA==.',
['可爱']='可爱的熊熊:BAAALgAFFAEJAQAAAA==.',
['史凯']='史凯利杰的风:BAAALgAFFAEJAQAAAA==.',
['哥们']='哥们儿给根烟:BAAALgAECgUJCAAAAA==.',
['哥微']='哥微微一笑:BAAALgADCgcJDAAAAA==.',
['围攻']='围攻伯拉勒斯:BAABLgAECn8XAAMGAAYJwh38QQAHAgAGAAYJwh38QQAHAgAHAAMJAw1PQgCrAAAAAA==.',
['增强']='增强辉:BAABLgAFFH8TAAMIAAQJdwzoDQAhAQAIAAQJdwzoDQAhAQAJAAIJRAHJFAB2AAAAAA==.',
['多鸠']='多鸠鱼:BAAALgAFFAIJAwAAAA==.',
['夜丶']='夜丶风:BAAALgAECgQJBgAAAA==.',
['夜空']='夜空声:BAAALgAECgUJBQAAAA==.',
['夜舞']='夜舞飞扬:BAAALgAECgYJCgAAAA==.',
['大丰']='大丰徐欠:BAAALgAECgEJAQAAAA==.',
['天一']='天一胤:BAAALgAECgMJAwAAAA==.',
['天热']='天热开冰箱:BAAALgAECgQJBQAAAA==.',
['太阳']='太阳的后裔:BAAALgAECgcJEQAAAA==.',
['奈莉']='奈莉莎:BAAALgADCgEJAQAAAA==.',
['奥林']='奥林花园:BAAALgADCgEJAQAAAA==.',
['如烟']='如烟:BAAALgAECgEJAQAAAA==.',
['安娜']='安娜贝尔:BAAALgADCgYJBgAAAA==.',
['安度']='安度因:BAACLgAFFH8HAAIKAAIJtSaaGADoAAAKAAIJtSaaGADoAAAuAAQKfxsAAgoACAmkJhwFAHoDAAoACAmkJhwFAHoDAAAA.',
['小爷']='小爷爆脾气:BAABLgAECn8cAAILAAcJ4BtlKQDlAQALAAcJ4BtlKQDlAQAAAA==.',
['小白']='小白猫猫:BAAALgADCgUJBQAAAA==.',
['尤子']='尤子:BAAALgAFFAEJAQAAAA==.',
['币古']='币古非常养:BAAALgAECgYJBgAAAA==.',
['帅逼']='帅逼:BAAALgADCgYJBgAAAA==.',
['幻蝶']='幻蝶:BAAALgADCgEJAQAAAA==.',
['幻雪']='幻雪蓝冰:BAABLgAFFH8HAAIKAAMJ0hP4EwAHAQAKAAMJ0hP4EwAHAQAAAA==.',
['弋弌']='弋弌弍弎丶:BAAALgAFFAIJAgAAAA==.',
['弥撒']='弥撒之音:BAAALgAECgcJBwAAAA==.',
['影之']='影之潮汐:BAAALgAFFAIJAgAAAA==.',
['很给']='很给力:BAAALgADCgEJAQAAAA==.',
['德吉']='德吉:BAAALgAECgQJBAAAAA==.',
['恐虐']='恐虐神选:BAAALgADCgEJAQAAAA==.',
['想想']='想想大魔王:BAACLgAFFH8OAAIJAAUJWxrGCABcAQAJAAUJWxrGCABcAQAuAAQKfxwABAkABwn3H48KAIwCAAkABwn3H48KAIwCAAgABgnKEZ4nAIABAAwABQl+E7sfADABAAAA.',
['戦魂']='戦魂柒殺:BAAALgADCgYJBgAAAA==.戦魂飝刄:BAAALgADCgMJAwAAAA==.',
['打不']='打不赢就假死:BAAALgAECgQJBAAAAA==.',
['插棍']='插棍王子:BAAALgAECgIJAgAAAA==.',
['撕皮']='撕皮儿剥壳:BAAALgAECgEJAgAAAA==.',
['旋风']='旋风之刃:BAAALgAFFAEJAQABLgAFFAcJDQANAM4ZAA==.',
['无望']='无望:BAAALgAECgUJBQAAAA==.',
['暗杀']='暗杀星:BAAALgAECgMJAwAAAA==.',
['核弹']='核弹:BAAALgAECgIJAwAAAA==.',
['楚恋']='楚恋流云:BAAALgAECgYJBgABLgAFFAUJAQAOAAAAAA==.',
['欢喜']='欢喜兔:BAAALgADCgUJBQAAAA==.',
['正义']='正义市民小马:BAAALgAECgUJCAAAAA==.',
['沐光']='沐光而行:BAAALgAFFAEJAQAAAA==.',
['洒洒']='洒洒水喽:BAAALgAECgEJAQAAAA==.',
['浓眉']='浓眉旺旺:BAAALgADCgcJBwAAAA==.',
['消失']='消失的空白:BAABLgAECn8cAAQJAAcJoxC2HQCVAQAJAAcJoxC2HQCVAQAIAAUJ0wfzRADKAAAMAAEJzwtNPwAyAAAAAA==.',
['火舞']='火舞凌风:BAACLgAFFH8GAAIBAAMJZgibFQDZAAABAAMJZgibFQDZAAAuAAQKfyIAAgEACAlEHWU0AKECAAEACAlEHWU0AKECAAAA.',
['灬遇']='灬遇术临疯灬:BAAALgAECgcJDQAAAA==.',
['熟人']='熟人勿扰:BAAALgAECgEJAgAAAA==.',
['爪爪']='爪爪丫:BAAALgAECgYJBgAAAA==.',
['独月']='独月无云:BAAALgAECgMJAwAAAA==.',
['猫仔']='猫仔熊:BAAALgAECgQJBgAAAA==.',
['玟文']='玟文:BAAALgAECgUJCgAAAA==.',
['瓣糖']='瓣糖:BAAALgAECgYJDgAAAA==.',
['白不']='白不爪:BAAALgAECgIJAgAAAA==.',
['皮克']='皮克斯:BAAALgAECgYJCgAAAA==.',
['皮固']='皮固非常养:BAAALgAECgYJAQAAAA==.',
['盾入']='盾入空门:BAAALgAFFAQJBAAAAA==.',
['瞬间']='瞬间即逝:BAAALgAECgYJDAABLgAFFAUJDgAJAFsaAA==.',
['竹子']='竹子:BAAALgAECgQJBQAAAA==.',
['紫媚']='紫媚儿:BAAALgADCgMJAwAAAA==.',
['给老']='给老子死:BAACLgAFFH8PAAIPAAUJsxrIDQBhAQAPAAUJsxrIDQBhAQAuAAQKfyEAAw8ABwlcItYiAIECAA8ABwlcItYiAIECABAABgm3BpgXAOUAAAAA.',
['美不']='美不美:BAAALgADCgMJAwAAAA==.',
['英雄']='英雄就站光里:BAAALgAECgQJBwAAAA==.',
['萌新']='萌新瑟瑟发抖:BAAALgAECgYJBgAAAA==.',
['萨比']='萨比:BAACLgAFFH8MAAIRAAQJARcNBwBUAQARAAQJARcNBwBUAQAuAAQKfx8AAhEACAmgI8sFABUDABEACAmgI8sFABUDAAAA.',
['蔷薇']='蔷薇童话:BAAALgAECgMJBQAAAA==.',
['薄荷']='薄荷雪梨膏:BAAALgAECgcJBwAAAA==.',
['装备']='装备评分:BAACLgAFFH8JAAISAAQJ3gaNDQAOAQASAAQJ3gaNDQAOAQAuAAQKfxwAAhIACAlAFRgrAAQCABIACAlAFRgrAAQCAAAA.',
['西球']='西球起丶:BAAALgAECgQJBAAAAA==.',
['誓约']='誓约之翼:BAAALgAFFAIJAwAAAA==.',
['请叫']='请叫我法爷:BAAALgAECgYJDAAAAA==.',
['轾轩']='轾轩:BAAALgAECgQJBwAAAA==.',
['辟故']='辟故非常养:BAACLgAFFH8LAAMJAAQJVBg+BQD7AAAJAAQJVBg+BQD7AAAIAAEJ9QMaJABDAAAuAAQKfxcABAkABwnoHPcTAAYCAAkABwnoHPcTAAYCAAgAAgmYEYhVAG0AAAwAAQl+B+1AAC4AAAAA.',
['达娃']='达娃:BAAALgAECgYJCAAAAA==.',
['遂源']='遂源风起:BAAALgAECgEJAQAAAA==.',
['邢亥']='邢亥:BAAALgAECgYJDAAAAA==.',
['醉打']='醉打尛怪兽:BAAALgAECgYJDgAAAA==.',
['阿叶']='阿叶:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔撒斯之心:BAAALgAFFAEJAQAAAA==.',
['雁飞']='雁飞残月天:BAAALgADCgcJBwAAAA==.',
['雅秘']='雅秘海:BAAALgAECgIJAgAAAA==.',
['雨夜']='雨夜孤魂:BAAALgAECgQJBQAAAA==.',
['雪梅']='雪梅初绽:BAABLgAECn8YAAIKAAgJJhiZPAAyAgAKAAgJJhiZPAAyAgAAAA==.',
['雪舞']='雪舞霜天:BAAALgAECgQJBAAAAA==.',
['雾轨']='雾轨银芒:BAAALgAECgcJDQAAAA==.',
['青哈']='青哈大魔王:BAAALgAECgcJBwAAAA==.',
['龙之']='龙之传人:BAAALgAECgcJBwAAAA==.',
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
