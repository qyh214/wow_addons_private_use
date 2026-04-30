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

local lookup = {'Unknown-Unknown','Rogue-Subtlety','Monk-Brewmaster','Hunter-Marksmanship','Druid-Guardian','Warlock-Demonology','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Monk-Mistweaver','Monk-Windwalker','Hunter-BeastMastery','Evoker-Preservation','Paladin-Protection','Priest-Holy','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Frost',}
local provider = {region='CN',realm='尘风峡谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aamon:BAAALgAECgQJBAAAAA==.',
Bd='Bdk:BAAALgAFFAIJBAAAAA==.',
Br='Brucelec:BAAALgADCgYJBgAAAA==.',
Ce='Cerulean:BAAALgADCgMJAwAAAA==.',
Df='Dfs:BAAALgAECgYJBgAAAA==.',
Di='Discovery:BAAALgAECgEJAwAAAA==.',
Ev='Evilmagic:BAAALgAECgEJAQAAAA==.',
Ha='Haya:BAAALgAECgMJAwABLgAECgQJBQABAAAAAA==.',
In='Interesting:BAAALgAECgQJBAAAAA==.',
Ko='Kozilek:BAAALgAECgkJEQABLgAFFAUJEAACAC8lAA==.',
Mi='Mimo:BAAALgAECgMJAgAAAA==.',
Ni='Niam:BAAALgAECgEJAQAAAA==.',
Ok='Okay:BAAALgAECgEJAQAAAA==.',
Ot='Otz:BAABLgAFFH8QAAIDAAQJrCLmAACpAQADAAQJrCLmAACpAQAAAA==.',
St='Starmoom:BAAALgAECgYJDAAAAA==.Started:BAAALgAECgYJCwAAAA==.',
Th='Theaik:BAAALgAFFAEJAQABLgAFFAMJBQAEAPcWAA==.',
['不扰']='不扰清梦:BAAALgAECgQJBAAAAA==.',
['不来']='不来了:BAAALgAECgYJBgAAAA==.',
['丸丸']='丸丸辣:BAAALgAECgkJAgAAAA==.',
['予地']='予地百花:BAAALgAECgYJCAAAAA==.',
['予天']='予天繁星:BAAALgAECgUJDgAAAA==.',
['五方']='五方:BAAALgAECgYJBgAAAA==.',
['何老']='何老爷:BAAALgAECgEJAQAAAA==.',
['你干']='你干甚去了:BAAALgAECgEJAQAAAA==.',
['俺村']='俺村俺最乖:BAABLgAFFH8GAAIFAAMJTAgsBACRAAAFAAMJTAgsBACRAAAAAA==.',
['傻墁']='傻墁:BAAALgAECgIJAgAAAA==.',
['克里']='克里斯开下门:BAABLgAFFH8GAAIGAAMJiRy6HgAJAQAGAAMJiRy6HgAJAQAAAA==.',
['典隰']='典隰:BAAALgAECgIJAgAAAA==.',
['凉拌']='凉拌见手青:BAAALgAECgIJAgAAAA==.',
['凡梦']='凡梦盛尘:BAAALgAECgYJDwAAAA==.',
['刮骨']='刮骨刀:BAABLgAFFH8FAAIHAAUJaBdrBQCsAQAHAAUJaBdrBQCsAQAAAA==.',
['北极']='北极兽:BAAALgAECgQJBQAAAA==.北极灵:BAAALgAECgQJBwAAAA==.北极龍:BAAALgAECgQJBAABLgAFFAUJBAABAAAAAA==.',
['北风']='北风江上寒:BAAALgAECgEJAQAAAA==.',
['南户']='南户唯:BAAALgAECgYJBgAAAA==.',
['口渴']='口渴的鱼儿:BAAALgAECgIJAgAAAA==.',
['台词']='台词过半:BAAALgAECgEJAQAAAA==.',
['叶花']='叶花:BAACLgAFFH8LAAIIAAQJNhMACQAEAQAIAAQJNhMACQAEAQAuAAQKfxcAAggACAkbHZ8rAHUCAAgACAkbHZ8rAHUCAAAA.',
['叽里']='叽里咕噜:BAAALgADCgQJBAAAAA==.',
['呆帝']='呆帝:BAAALgAECgQJBAAAAA==.',
['咕十']='咕十三:BAAALgAECgMJAwAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgADCgYJBgAAAA==.',
['咸鱼']='咸鱼突刺:BAAALgAECgMJAwAAAA==.',
['四葉']='四葉真夜:BAAALgAECgYJCQAAAA==.',
['回留']='回留:BAAALgADCgcJBwABLgAECgcJFwAJAAkmAA==.',
['圣光']='圣光降临:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落的小恶魔:BAAALgADCgUJBQAAAA==.',
['大毛']='大毛:BAABLgAECn8XAAMKAAcJYBFsLgBIAQAKAAcJYBFsLgBIAQALAAYJIAebQgANAQAAAA==.',
['奶天']='奶天高一尺:BAAALgADCgQJBAAAAA==.',
['姨十']='姨十三:BAAALgADCgYJBwAAAA==.',
['对影']='对影三人:BAAALgADCgUJBQAAAA==.',
['小呆']='小呆:BAAALgAECgYJCAAAAA==.',
['小夕']='小夕颜:BAAALgAECgcJBwAAAA==.',
['小妞']='小妞嘟嘟:BAAALgAFFAEJAQAAAA==.',
['小楼']='小楼夜歌声:BAAALgAECgMJBAAAAA==.小楼宅情歌:BAAALgAECgcJBwAAAA==.',
['小猪']='小猪:BAAALgAECgEJAQAAAA==.',
['当时']='当时我就火了:BAAALgADCgEJAQAAAA==.',
['影舞']='影舞小者:BAACLgAFFH8FAAIEAAMJ9xZjBAC+AAAEAAMJ9xZjBAC+AAAuAAQKfyIAAwQABwn3HA0cAEQCAAQABwnGHA0cAEQCAAwABAlkGgAAAAAAAAAA.',
['快乐']='快乐的士兵:BAAALgADCgEJAQAAAA==.',
['悔的']='悔的很冲动:BAAALgADCgEJAQAAAA==.',
['悟灭']='悟灭:BAAALgADCgMJAwAAAA==.',
['憨厚']='憨厚亡者:BAAALgAFFAEJAgAAAA==.',
['撕裂']='撕裂灵魂:BAAALgAECgEJAQAAAA==.',
['文心']='文心一言:BAAALgAECgMJAwAAAA==.',
['方清']='方清雪:BAAALgAFFAMJBAAAAA==.',
['晚来']='晚来天:BAAALgAECgMJAwAAAA==.',
['月光']='月光小白兔:BAAALgADCgkJEAABLgAFFAEJAQABAAAAAA==.',
['木瓜']='木瓜吃多了:BAAALgADCgMJAwAAAA==.',
['李朝']='李朝鲁:BAABLgAECn8bAAMKAAcJvRzjEABQAgAKAAcJvRzjEABQAgALAAQJCxKvRwD2AAAAAA==.',
['杠上']='杠上开花:BAAALgAECgIJAgAAAA==.',
['栗子']='栗子馒头:BAAALgAECgYJBgAAAA==.',
['梅莉']='梅莉莎的羊:BAAALgADCgMJAwABLgAFFAMJBQANAFslAA==.',
['水無']='水無月流歌:BAAALgAFFAMJAwAAAA==.',
['潇洒']='潇洒公子:BAAALgADCgcJBwABLgAFFAgJGgAJAHwmAA==.',
['潘辰']='潘辰小风:BAAALgAECgcJBwAAAA==.',
['灰浊']='灰浊:BAAALgAECgQJBQAAAA==.',
['烨星']='烨星:BAACLgAFFH8GAAIJAAQJlwkdEwD8AAAJAAQJlwkdEwD8AAAuAAQKfxsAAgkABwkUGjRaACsCAAkABwkUGjRaACsCAAAA.',
['爱哭']='爱哭的牛牛:BAAALgAFFAEJAQABLgAFFAQJEwAOAOgiAA==.',
['牛牛']='牛牛勇士:BAAALgADCgYJBgAAAA==.',
['狂暴']='狂暴的巨牙:BAAALgAECgIJAwAAAA==.狂暴神鬼:BAAALgADCgYJBwAAAA==.',
['狂野']='狂野小魔星:BAAALgADCgIJAQAAAA==.',
['猎龙']='猎龙者:BAAALgAFFAQJBAAAAA==.',
['猫十']='猫十三:BAAALgAFFAIJAwAAAA==.',
['甲亢']='甲亢哥李继伟:BAAALgAECgQJBAAAAA==.',
['盾挡']='盾挡千军:BAAALgAECgEJAQAAAA==.',
['硬粗']='硬粗弯长黑:BAABLgAECn8UAAIFAAYJMhJqFAAqAQAFAAYJMhJqFAAqAQAAAA==.',
['神圣']='神圣星星:BAAALgAECgYJCQAAAA==.',
['科尔']='科尔沁:BAAALgADCgEJAQAAAA==.',
['稻香']='稻香丶:BAAALgADCgcJCAAAAA==.',
['精味']='精味填海丶:BAAALgAECgMJAwAAAA==.',
['糕手']='糕手饱饱:BAAALgAECgEJAQAAAA==.',
['索莉']='索莉娅的咕:BAAALgAECgYJBgABLgAFFAMJBQANAFslAA==.',
['纯粹']='纯粹菜鸟:BAACLgAFFH8NAAIMAAQJiBz5AACKAQAMAAQJiBz5AACKAQAuAAQKfxgAAwwACAnNIE8QALgCAAwACAnNIE8QALgCAAQAAQnXASiXACEAAAAA.',
['纽扣']='纽扣丢了:BAABLgAECn8bAAIPAAcJDRnuGAAUAgAPAAcJDRnuGAAUAgAAAA==.',
['羊毛']='羊毛基里曼:BAAALgAFFAIJAgAAAA==.',
['老登']='老登:BAAALgAECgMJAwAAAA==.',
['聖阎']='聖阎王:BAAALgADCgMJAwAAAA==.',
['艾莉']='艾莉丝的仓鼠:BAAALgAECgcJDwABLgAFFAMJBQANAFslAA==.',
['艾萨']='艾萨拉阿娇:BAAALgADCgMJCgAAAA==.',
['苏牧']='苏牧:BAAALgAECgEJAwAAAA==.',
['莉莉']='莉莉丝的鱼:BAAALgAECgYJBgABLgAFFAMJBQANAFslAA==.',
['莎琳']='莎琳娜的龙:BAACLgAFFH8FAAINAAMJWyWwCQBOAQANAAMJWyWwCQBOAQAuAAQKfx4ABA0ABwndHrMNAFsCAA0ABwndHrMNAFsCABAABAlWHssuAEwBABEAAQkCG3g5AE4AAAAA.',
['菲克']='菲克纽斯:BAABLgAECn8aAAIHAAcJxRjCTwADAgAHAAcJxRjCTwADAgAAAA==.',
['落日']='落日满秋山:BAABLgAFFH8GAAMSAAIJ4w3EAgCnAAASAAIJqgjEAgCnAAAHAAIJhww6QQCfAAAAAA==.',
['蛋灬']='蛋灬蛋:BAAALgAECgYJCQAAAA==.',
['血之']='血之忧伤:BAAALgAECgYJCAAAAA==.',
['行万']='行万理路:BAAALgAECgEJAQAAAA==.',
['西欧']='西欧灬之夏:BAAALgADCgUJBQAAAA==.',
['要你']='要你命三千:BAAALgAECgEJAwAAAA==.要你命十万:BAAALgAECgEJAQAAAA==.',
['豆豆']='豆豆德:BAAALgAECgkJCQAAAA==.',
['走芯']='走芯:BAAALgAECgEJAQAAAA==.',
['起了']='起了毛球:BAABLgAECn8XAAIJAAcJCSYwHwD4AgAJAAcJCSYwHwD4AgAAAA==.',
['阿凌']='阿凌:BAAALgAECgYJCgAAAA==.',
['陆雪']='陆雪琪:BAAALgAFFAIJBAAAAA==.',
['隐藏']='隐藏姓名:BAAALgAECgQJBgAAAA==.',
['集火']='集火那只鹌鹑:BAAALgAECgYJBgAAAA==.',
['零宝']='零宝:BAAALgAECgcJDgABLgAFFAEJAQABAAAAAA==.',
['飞行']='飞行雪绒:BAAALgAECgQJBAABLgAECgcJFgAEAHMcAA==.',
['香风']='香风智乃:BAAALgAFFAIJAgAAAA==.',
['马哥']='马哥你好:BAAALgAECgQJCQAAAA==.',
['马雷']='马雷基斯:BAAALgAECgEJAQAAAA==.',
['鬼妈']='鬼妈妈:BAAALgADCgIJAgAAAA==.',
['龙一']='龙一冉:BAAALgAECgEJAQAAAA==.',
['龙希']='龙希尔:BAAALgADCgUJBQABLgAFFAYJGAAQACkgAA==.',
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
