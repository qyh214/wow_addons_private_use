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

local lookup = {'Druid-Restoration','Druid-Balance','Shaman-Elemental','Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','Warrior-Protection','Paladin-Retribution','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Frost','Mage-Frost','Mage-Arcane','Priest-Discipline','Evoker-Preservation','Paladin-Protection',}
local provider = {region='CN',realm='古加尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alder:BAABLgAFFH8IAAMBAAQJkhImCgA2AQABAAQJkhImCgA2AQACAAIJ4AhxFgCQAAAAAA==.',
Ap='Apart:BAAALgAECgIJAgAAAA==.',
Do='Donmdunk:BAAALgADCgYJBgAAAA==.',
Ei='Eiwa:BAAALgAECgQJCwAAAA==.',
Fi='Fillipo:BAAALgADCgIJAgAAAA==.',
Li='Liver:BAAALgAECgcJBgAAAA==.',
Lv='Lvy:BAAALgAECgUJBQAAAA==.',
Mf='Mfs:BAAALgADCgcJBwAAAA==.',
Pl='Playerhvtutm:BAAALgAECgUJCAAAAA==.',
Ri='Rina:BAAALgADCgUJBQAAAA==.',
Th='Theshy:BAAALgAFFAIJBAAAAA==.',
Wa='Warxx:BAAALgAECgIJAgAAAA==.',
Xu='Xuk:BAAALgAECgkJCQAAAA==.',
['一剑']='一剑秋叶悲:BAAALgAECgEJAQAAAA==.',
['一吻']='一吻:BAAALgADCgUJCgAAAA==.',
['丶断']='丶断香:BAAALgAECgQJBAAAAA==.',
['丶法']='丶法灬殇:BAAALgAFFAEJAQAAAA==.',
['丶麻']='丶麻辣鸡丝:BAAALgAECgQJBAAAAA==.',
['丹尼']='丹尼威尔:BAAALgAFFAEJAQAAAA==.',
['丿苧']='丿苧顏:BAAALgAECgQJBgAAAA==.',
['仙气']='仙气灬飘飘:BAAALgADCgEJAQAAAA==.',
['伊莉']='伊莉疍:BAAALgAECgEJAQAAAA==.',
['传移']='传移模写:BAAALgAECgQJBwAAAA==.',
['低糖']='低糖冰红茶:BAAALgAECgQJBQAAAA==.',
['光明']='光明的灰灰:BAAALgADCgEJAQAAAA==.',
['克莱']='克莱因瓶:BAABLgAECn8VAAIDAAgJwh70CgDnAgADAAgJwh70CgDnAgAAAA==.',
['八八']='八八小白猫:BAAALgADCgYJBwAAAA==.',
['八百']='八百个心捻子:BAAALgAECgYJCgAAAA==.',
['冥冥']='冥冥的狐林:BAACLgAFFH8LAAIEAAQJvxvGCwBeAQAEAAQJvxvGCwBeAQAuAAQKfyAAAwQABwnIIYwSAJ8CAAQABwnIIYwSAJ8CAAUABgljDTUcABIBAAAA.冥冥的猫熊:BAAALgAECgYJBgAAAA==.',
['冰淇']='冰淇淋玫瑰:BAAALgAECgQJBAAAAA==.',
['凡妮']='凡妮莎:BAAALgAECgUJBQAAAA==.',
['加厼']='加厼鲁什:BAAALgAECgUJBQAAAA==.',
['勇度']='勇度:BAAALgAECgEJAQAAAA==.',
['卡莉']='卡莉法:BAAALgADCgUJCQAAAA==.',
['卩風']='卩風丨爺灬:BAAALgAFFAIJAwAAAA==.',
['又脆']='又脆嘴还硬:BAAALgAFFAEJAQAAAA==.',
['古加']='古加尔婴儿蓝:BAAALgAECgYJBwAAAA==.',
['君子']='君子的法丝:BAAALgAECgYJCwAAAA==.君子的骑士:BAAALgAECgQJAwAAAA==.',
['哈哈']='哈哈公爷:BAAALgAECgEJAQAAAA==.',
['唰咻']='唰咻嗖啊:BAAALgAECgcJDQAAAA==.',
['喷塔']='喷塔课药:BAAALgAECgEJAwAAAA==.',
['嘟嘟']='嘟嘟德:BAAALgAFFAIJAwAAAA==.',
['因崔']='因崔斯汀:BAAALgAECgcJDQAAAA==.',
['国民']='国民小三:BAAALgAECgYJDQAAAA==.',
['圣光']='圣光牛牛堡:BAAALgAECgcJDAAAAA==.圣光蟹丶:BAAALgAFFAMJBAAAAA==.',
['地狱']='地狱无别:BAAALgADCgQJBAAAAA==.',
['墨墨']='墨墨不吃辣:BAAALgAECgEJAQAAAA==.',
['墨染']='墨染倾城殇:BAACLgAFFH8HAAIGAAMJlhGPFwCpAAAGAAMJlhGPFwCpAAAuAAQKfyAAAgYABwmyHDwmACECAAYABwmyHDwmACECAAAA.',
['复仇']='复仇哀木梯:BAAALgAECgkJEAABLgAFFAcJDQAHAM4ZAA==.',
['夜武']='夜武:BAAALgAECgEJAQAAAA==.',
['大力']='大力出神迹:BAAALgAECgEJAQAAAA==.',
['天外']='天外飞仙:BAAALgAECgkJCQABLgAFFAcJDQAHAM4ZAA==.',
['头疼']='头疼的老蜗牛:BAAALgAECgcJBwAAAA==.',
['契卒']='契卒:BAAALgAECgYJCwAAAA==.',
['好大']='好大一块德芙:BAAALgAFFAIJBAAAAA==.',
['孔雀']='孔雀东南飞:BAAALgAECgEJAQABLgAFFAYJEwAIAMggAA==.',
['寒蝉']='寒蝉:BAAALgADCgEJAgAAAA==.',
['射人']='射人先射鸟:BAAALgADCgEJAQAAAA==.',
['射鬼']='射鬼:BAAALgAECgIJAgABLgAFFAYJBAAJAAAAAA==.',
['小乔']='小乔乔:BAAALgADCgQJBAAAAA==.',
['小吉']='小吉祥宝:BAABLgAFFH8MAAMKAAQJmRqGFABQAQAKAAQJfhWGFABQAQALAAMJrxrhAAAWAQAAAA==.',
['小战']='小战灬:BAAALgAECgYJBgAAAA==.',
['小破']='小破孩丶:BAAALgAECgIJAgAAAA==.',
['小纯']='小纯洁:BAAALgAECgYJBgAAAA==.',
['尤法']='尤法:BAAALgADCgEJAQAAAA==.',
['左边']='左边忧伤:BAAALgAECgQJCgAAAA==.',
['应物']='应物象形:BAAALgAECgIJAgAAAA==.',
['彦祖']='彦祖呀:BAAALgAECgcJCQAAAA==.',
['德灵']='德灵之怨:BAAALgADCgIJAgAAAA==.',
['思密']='思密达牛牛:BAABLgAECn8dAAIBAAgJgQ7dRQCKAQABAAgJgQ7dRQCKAQAAAA==.',
['我不']='我不管我最萌:BAAALgAECgIJAgABLgAFFAcJFQAKABEcAA==.',
['我叫']='我叫牛哥:BAAALgAECgMJAwAAAA==.',
['我是']='我是血迪凯:BAAALgAFFAEJAQAAAA==.',
['拒绝']='拒绝者:BAABLgAECn8jAAMMAAcJ/h9yFQCXAQAMAAcJXB9yFQCXAQANAAEJVCVeFgBoAAAAAA==.',
['文理']='文理双修:BAAALgAECgEJAQAAAA==.',
['断謧']='断謧:BAAALgAECgUJAwAAAA==.',
['新煜']='新煜孙亚龙:BAAALgAECgEJAQAAAA==.',
['晚风']='晚风忆青山:BAAALgAECgEJAQAAAA==.',
['暗月']='暗月玫瑰刀:BAAALgADCgYJBgAAAA==.',
['月影']='月影如歌:BAAALgAECgUJBwAAAA==.',
['果果']='果果子:BAAALgADCgUJBQAAAA==.',
['枪之']='枪之勇者:BAAALgAECgcJCAAAAA==.',
['校花']='校花贴身保镖:BAAALgAECgEJAQAAAA==.',
['根号']='根号伍:BAAALgAECgIJAgAAAA==.',
['楓丨']='楓丨忆霖:BAAALgAECgQJBAAAAA==.',
['橘子']='橘子哥哥:BAAALgAECgUJCAAAAA==.',
['死亡']='死亡猎狐犬长:BAAALgAECgEJAQAAAA==.',
['沟股']='沟股啶里:BAAALgAECgIJAgAAAA==.',
['没的']='没的事做:BAAALgAECgEJAQAAAA==.',
['法灵']='法灵怪怪:BAAALgAECgYJCAAAAA==.',
['清清']='清清小猎:BAAALgADCgEJAQAAAA==.',
['清风']='清风乱烟雨:BAAALgAECgEJAQAAAA==.清风暴烈酒:BAAALgAECgEJAQAAAA==.',
['满月']='满月见红:BAAALgADCgUJBQAAAA==.',
['灰来']='灰来灰气:BAAALgAECgUJBQAAAA==.',
['炽焰']='炽焰之魂:BAAALgAECgMJBQAAAA==.',
['炽魂']='炽魂寒魄:BAAALgAECgEJAgAAAA==.',
['烟花']='烟花:BAAALgAFFAEJAQABLgAFFAIJAwAJAAAAAA==.',
['熊不']='熊不乖:BAABLgAFFH8MAAIKAAQJvhVWFABRAQAKAAQJvhVWFABRAQAAAA==.',
['爷们']='爷们阿波罗:BAAALgADCgQJBAAAAA==.',
['牛小']='牛小西:BAAALgAECgUJBQAAAA==.',
['牛牛']='牛牛爱吃糖:BAAALgAECgkJCQAAAA==.',
['猪猪']='猪猪瞎:BAAALgAECgYJCQAAAA==.',
['猴大']='猴大侠:BAAALgAECgQJCAAAAA==.',
['王者']='王者归来:BAAALgADCgUJCAAAAA==.',
['百厮']='百厮不嘚骑姐:BAAALgAECgUJCQAAAA==.',
['真红']='真红奈奈娜:BAACLgAFFH8FAAIOAAMJzA25GABNAAAOAAMJzA25GABNAAAuAAQKfxoAAg4ACQm5FkoKAJQCAA4ACQm5FkoKAJQCAAAA.真红希尔娜:BAAALgAECgIJAgAAAA==.',
['祎块']='祎块饼:BAAALgAECgIJAgAAAA==.',
['神奇']='神奇九九:BAAALgAECgEJAgAAAA==.',
['穿衣']='穿衣默写:BAAALgADCgUJBQAAAA==.',
['第八']='第八街野猫:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门妖姬:BAAALgAECgMJAgAAAA==.',
['糯米']='糯米丸子:BAAALgADCgUJBQAAAA==.',
['紫罗']='紫罗兰丶:BAAALgAECgUJBQAAAA==.',
['绝版']='绝版的爱:BAAALgADCgYJBgAAAA==.',
['缚灵']='缚灵圣物:BAABLgAFFH8IAAIMAAQJzxdnGABoAQAMAAQJzxdnGABoAQAAAA==.',
['缺德']='缺德的找我:BAAALgAECgUJBQAAAA==.',
['美灬']='美灬飘飘:BAAALgADCgQJBAAAAA==.',
['老蜗']='老蜗牛:BAAALgAECgkJBwAAAA==.',
['艾萨']='艾萨克牛顿:BAAALgADCgEJAQABLgAFFAMJBQAPAGAjAA==.',
['花花']='花花子:BAAALgAECgEJAQAAAA==.',
['苏军']='苏军:BAAALgAECgYJBgAAAA==.',
['若瑄']='若瑄:BAAALgAECgEJAwAAAA==.',
['草药']='草药德:BAAALgAECgkJCQAAAA==.',
['螃蟹']='螃蟹丶:BAACLgAFFH8OAAIMAAUJ4BusBwBjAQAMAAUJ4BusBwBjAQAuAAQKfykAAgwACAlOI3UlANwCAAwACAlOI3UlANwCAAAA.',
['西门']='西门猎艳:BAAALgAECgQJBwAAAA==.',
['轩紫']='轩紫夜:BAAALgAFFAIJAwAAAA==.',
['還是']='還是會喵喵:BAAALgADCgEJAQAAAA==.',
['闪开']='闪开让我来:BAAALgAECgEJAgAAAA==.',
['限量']='限量鈑嘚嗳:BAAALgADCgIJAgAAAA==.',
['雨天']='雨天不打伞:BAAALgAECgQJCAAAAA==.',
['零糖']='零糖铃:BAAALgADCgIJAgAAAA==.',
['霍尼']='霍尼榭特:BAAALgADCgMJAwAAAA==.',
['青山']='青山忆晚风:BAAALgADCgYJBgAAAA==.',
['骑士']='骑士也疯狂:BAAALgADCgYJBgAAAA==.',
['骑神']='骑神传说:BAAALgAFFAIJAgAAAA==.',
['黄昏']='黄昏与黎明:BAABLgAECn8bAAIQAAgJ4gl4GQBGAQAQAAgJ4gl4GQBGAQAAAA==.',
['黑暗']='黑暗福音:BAAALgAECgEJAQAAAA==.',
['黑糖']='黑糖玛琪朵:BAAALgAECgQJBwAAAA==.',
['龙纹']='龙纹身:BAAALgAECgUJCAAAAA==.',
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
