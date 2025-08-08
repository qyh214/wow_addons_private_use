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
 local lookup = {'Shaman-Restoration','Shaman-Enhancement','Warlock-Destruction','Mage-Frost','Hunter-Marksmanship','Druid-Balance','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-BeastMastery','Paladin-Retribution','Warlock-Affliction','Unknown-Unknown','Paladin-Holy','Mage-Arcane',}; local provider = {region='CN',realm='夺灵者',name='CN',type='weekly',zone=42,date='2025-08-08',data={Gi='Gigabyte:BAACKgAFFH8FAAIBAAIIihPLJgCDAAABAAIIihPLJgCDAAAqAAQKfz8AAwEACAjzISwOAIYCAAEACAjzISwOAIYCAAIAAgjABOhFADsAAAAA.',Ic='Icebeauty:BAAAKgADCggIDgAAAA==.',Mo='Monologue:BAABKgAFFH8GAAIDAAUIaBSSDAD8AAADAAUIaBSSDAD8AAAAAA==.',Ni='Nia:BAAAKgAECgUIBwAAAA==.',['一指']='一指冰寒:BAABKgAFFH8GAAIEAAYIuREXCQAxAQAEAAYIuREXCQAxAQAAAA==.',['一陣']='一陣風:BAAAKgAFFAQIBAAAAA==.',['不德']='不德鸟:BAAAKgAECggIDgAAAA==.',['云清']='云清:BAAAKgAFFAYIBAAAAA==.',['五谷']='五谷丰登:BAAAKgAECgYIDAAAAA==.',['从小']='从小就很浪:BAABKgAFFH8GAAIFAAYIZRuLCwCdAQAFAAYIZRuLCwCdAQAAAA==.从小就很胖:BAABKgAFFH8IAAIGAAgIxQmZCwDLAQAGAAgIxQmZCwDLAQAAAA==.',['仙慰']='仙慰:BAAAKgAECggIDwAAAA==.',['伊尼']='伊尼达雷:BAABKgAECn8hAAIHAAgIHB5uFwBFAgAHAAgIHB5uFwBFAgAAAA==.',['众佳']='众佳吴惠刚:BAAAKgAECggICAAAAA==.',['传说']='传说没射到:BAAAKgAECgMIAwAAAA==.',['你们']='你们缺德么:BAAAKgAECgcIEAAAAA==.',['傲牛']='傲牛:BAAAKgAECgQIBAAAAA==.',['冰点']='冰点雨:BAAAKgAECgUIBQAAAA==.',['南瓜']='南瓜静:BAAAKgAECgIIAgAAAA==.',['叶灬']='叶灬傾云:BAAAKgAFFAMIAwAAAA==.',['司徒']='司徒玉棠:BAAAKgADCgIIAgAAAA==.',['吉萨']='吉萨轻浮:BAABKgAECn8WAAIIAAgIVgkKNQDpAAAIAAgIVgkKNQDpAAAAAA==.',['呆大']='呆大王:BAABKgAECn8oAAIFAAgIhB51CABVAgAFAAgIhB51CABVAgAAAA==.',['呦吼']='呦吼吼:BAAAKgADCgEIAQAAAA==.',['哎盆']='哎盆友:BAABKgAECn8gAAIJAAgIExtsDQA+AgAJAAgIExtsDQA+AgAAAA==.',['圣斗']='圣斗乳:BAAAKgADCgMIAwAAAA==.',['大跳']='大跳冲锋放魂:BAAAKgAECgQIBgAAAA==.',['天天']='天天吃跌停板:BAAAKgAECgcIDAAAAA==.',['嬉皮']='嬉皮笑脸:BAAAKgAECgcIDwAAAA==.',['安娜']='安娜奥莉:BAABKgAFFH8IAAIKAAQImRkRSgDaAAAKAAQImRkRSgDaAAAAAA==.',['射有']='射有止境:BAAAKgADCggICAAAAA==.',['巅峰']='巅峰绿瑁餕:BAAAKgADCgUIBQAAAA==.',['带个']='带个小狗玩:BAAAKgADCggICAAAAA==.',['幻暝']='幻暝:BAAAKgAECggICAAAAA==.',['幻瞑']='幻瞑:BAAAKgADCgUIBQAAAA==.',['往事']='往事随风:BAAAKgADCgIIAgAAAA==.',['忘卻']='忘卻的記憶:BAAAKgAECgcIDgAAAA==.',['快樂']='快樂:BAAAKgAECggIDwAAAA==.',['怪丶']='怪丶咖:BAAAKgAECggIDAAAAA==.',['恶魔']='恶魔的深渊:BAAAKgAECgQIBAAAAA==.',['我忘']='我忘却了:BAAAKgAECgQIBAAAAA==.',['战争']='战争画师:BAAAKgADCgUIBQAAAA==.',['戦瀟']='戦瀟颯:BAAAKgAECgUIBQAAAA==.',['拉粑']='拉粑粑小魔仙:BAAAKgADCgMIAwAAAA==.',['无念']='无念:BAAAKgADCggIAgAAAA==.',['无缺']='无缺:BAAAKgAECgYIBgAAAA==.',['星辰']='星辰的旋律:BAAAKgAECgMIAwAAAA==.',['暗灵']='暗灵之惩戒:BAAAKgAECggIDwAAAA==.暗灵之法爷:BAAAKgADCgQIBAAAAA==.',['果果']='果果小宝:BAABKgAECn8UAAMDAAgI9xEcVQAUAQADAAgI9xEcVQAUAQALAAEIAAAAAAAAAAAAAA==.',['沃利']='沃利贝尔:BAAAKgAECggIEgAAAA==.',['滴血']='滴血龙牙:BAAAKgAECgEIAQABKgAECgMIAwAMAAAAAA==.',['炫耀']='炫耀:BAAAKgAECgcIBwAAAA==.',['煤炭']='煤炭批发王哥:BAAAKgAECgYICgAAAA==.',['燃烧']='燃烧的大腿:BAAAKgAECgMIAwAAAA==.',['疑似']='疑似不会玩:BAAAKgAECgEIAQAAAA==.',['皇家']='皇家龍騎:BAAAKgAECgMIBQAAAA==.',['皮尔']='皮尔洛:BAAAKgADCggIDAAAAA==.',['给你']='给你一板蕨:BAAAKgAECgUIBQAAAA==.',['缘起']='缘起:BAAAKgAECgYICwAAAA==.',['美少']='美少女壮士丶:BAAAKgADCggICAAAAA==.',['羽歌']='羽歌:BAAAKgAECgMIBAAAAA==.',['羽裳']='羽裳:BAAAKgAECgIIAgAAAA==.',['老巫']='老巫:BAAAKgADCgYIAwAAAA==.',['至黑']='至黑之夜:BAAAKgAECgYIBgAAAA==.',['芙莉']='芙莉莲:BAAAKgAECgcIBwAAAA==.',['莉莉']='莉莉丝女王:BAAAKgAFFAEIAQAAAA==.',['蔡小']='蔡小酒窝:BAAAKgAECgEIAQAAAA==.',['血之']='血之哀伤:BAAAKgAECgIIAgAAAA==.',['谭三']='谭三爷:BAAAKgAECgYIBwAAAA==.',['贝才']='贝才:BAAAKgAECggICAABKgAECggIDwAMAAAAAA==.',['跑不']='跑不快:BAAAKgADCgQIBQAAAA==.',['车是']='车是一下:BAABKgAECn8VAAINAAcI8xE/KQAUAQANAAcI8xE/KQAUAQAAAA==.',['还是']='还是不会玩:BAAAKgAFFAYIBAAAAA==.',['都是']='都是小菜鸡啊:BAAAKgADCgQIBAAAAA==.',['醉酒']='醉酒饱德:BAAAKgAFFAEIAQAAAA==.',['闻疯']='闻疯丧胆:BAAAKgAECgUIBQAAAA==.',['陌念']='陌念念:BAACKgAFFH8kAAIHAAYIiRuMAgDFAQAHAAYIiRuMAgDFAQAqAAQKfy8AAgcACAgAIKQVAIQCAAcACAgAIKQVAIQCAAEqAAUUCAgDAAwAAAAA.',['雍正']='雍正:BAAAKgADCggICAAAAA==.',['飛天']='飛天龍:BAABKgAFFH8IAAIOAAgIdhP0BgAUAgAOAAgIdhP0BgAUAgAAAA==.',['飞天']='飞天丨燕子灬:BAAAKgAECgUIBQAAAA==.',['麼麼']='麼麼小苹果:BAABKgAFFH8IAAIKAAgIVAurDQDIAQAKAAgIVAurDQDIAQAAAA==.',['黄泉']='黄泉孟婆:BAAAKgAECgMIAwAAAA==.黄泉白无常:BAAAKgAECgQIBQAAAA==.黄泉黑无常:BAAAKgADCgQIBAAAAA==.',['黄瓜']='黄瓜超人:BAAAKgADCgMIAwAAAA==.',['黎明']='黎明的晨星:BAAAKgAECgIIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end