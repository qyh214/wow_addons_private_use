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

local lookup = {'DeathKnight-Unholy','Druid-Restoration','Warrior-Fury','Monk-Brewmaster','Monk-Windwalker','DemonHunter-Havoc','DemonHunter-Devourer','Mage-Frost','Paladin-Holy','Shaman-Elemental','Druid-Balance','DeathKnight-Blood','Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Evoker-Augmentation','Shaman-Restoration','Warrior-Protection','Priest-Shadow','Unknown-Unknown','Paladin-Protection','Paladin-Retribution','Evoker-Devastation',}
local provider = {region='CN',realm='菲米丝',name='CN',type='weekly',zone=46,date='2026-04-25',data={Da='Darcey:BAAALgAECgUJCAAAAA==.',
Dk='Dkdkdkd:BAACLgAFFH8MAAIBAAQJUyLQBwCSAQABAAQJUyLQBwCSAQAuAAQKfxwAAgEACQmMIXwOACcDAAEACQmMIXwOACcDAAAA.',
Ku='Kuro:BAAALgAECgUJBQABLgAFFAQJDQACAEYkAA==.Kuyoyo:BAAALgAECgMJAwABLgAFFAQJDQACAEYkAA==.',
Ra='Raywind:BAAALgAFFAIJBAAAAA==.',
Sa='Savior:BAAALgAECgIJAgAAAA==.',
Sc='Scarlet:BAAALgAECgEJAQAAAA==.',
Su='Sugerdaddy:BAAALgAFFAIJAwABLgAFFAQJCQADAB0gAA==.',
To='Tomboy:BAAALgAECgMJAwAAAA==.',
Ty='Ty:BAABLgAFFH8GAAMEAAIJ3iT1DADAAAAEAAIJ3iT1DADAAAAFAAIJDwgPDgCSAAAAAA==.',
Vi='Vivit:BAAALgADCgMJAwAAAA==.',
Zq='Zqlo:BAACLgAFFH8NAAMGAAQJYxXXAgBfAQAGAAQJYxXXAgBfAQAHAAEJ/QQHOgBDAAAuAAQKfx8AAwYACAmPG7gMAJYCAAYACAk0GbgMAJYCAAcABgl4GMFiAHkBAAAA.',
['Ãä']='Ãäãäãäox:BAAALgAECgEJAgAAAA==.',
['七濑']='七濑爱丽丝:BAAALgAECgUJAwAAAA==.',
['不讲']='不讲武德:BAAALgAFFAQJAgAAAA==.',
['丶冷']='丶冷骨头:BAAALgAECgYJCQAAAA==.',
['丹妮']='丹妮莉丝:BAAALgAFFAEJAQAAAA==.',
['二口']='二口之家:BAAALgADCgMJAwAAAA==.',
['五晨']='五晨寺憨憨:BAAALgAECgYJEQAAAA==.',
['仙人']='仙人摘桃:BAAALgAECgQJBwAAAA==.',
['仝泽']='仝泽:BAABLgAFFH8GAAIIAAIJ3xgwOgC2AAAIAAIJ3xgwOgC2AAAAAA==.',
['似丶']='似丶流水无心:BAAALgAECgEJAgAAAA==.',
['何其']='何其臭的脚:BAAALgAFFAYJAwAAAA==.何其臭的裤子:BAABLgAFFH8HAAIJAAYJigmtCwAlAQAJAAYJigmtCwAlAQAAAA==.何其臭的鞋:BAAALgAFFAQJBAAAAA==.',
['依然']='依然霜火:BAAALgAECgIJAgAAAA==.',
['傲天']='傲天狂少:BAABLgAECn8cAAIKAAgJXSB9CwDhAgAKAAgJXSB9CwDhAgAAAA==.',
['克拉']='克拉星光璀璨:BAAALgAECgEJAQAAAA==.克拉神行无忌:BAAALgAECgIJAgAAAA==.',
['六叔']='六叔跌摩托:BAABLgAECn8ZAAILAAgJxSIlBwAmAwALAAgJxSIlBwAmAwAAAA==.',
['兰德']='兰德鲁的礼盒:BAAALgAECgYJCQAAAA==.',
['冰淇']='冰淇淋红茶:BAAALgAECgEJAQAAAA==.',
['分开']='分开才说抱歉:BAAALgAECgMJBAABLgAFFAQJCQADAB0gAA==.',
['办震']='办震刻章:BAAALgAECgYJEgAAAA==.',
['南乡']='南乡子:BAAALgAECgYJBgAAAA==.',
['卧槽']='卧槽帅狗:BAACLgAFFH8KAAIKAAQJ9R7wBgBrAQAKAAQJ9R7wBgBrAQAuAAQKfxwAAgoACAlNIyEIABADAAoACAlNIyEIABADAAAA.卧槽罗根:BAAALgAECgQJAQAAAA==.卧槽萌猫:BAACLgAFFH8NAAMCAAQJRiR2BACXAQACAAQJRiR2BACXAQALAAEJhgO5HABDAAAuAAQKfx8AAwIACAnHI2wJAPsCAAIACAnHI2wJAPsCAAsABQl0Fww5AFMBAAAA.',
['只管']='只管丢技能:BAAALgADCgkJCQAAAA==.',
['可牛']='可牛了:BAAALgAECgcJCgAAAA==.',
['呆河']='呆河:BAACLgAFFH8NAAIMAAQJuRqGBABiAQAMAAQJuRqGBABiAQAuAAQKfx8AAgwACAn6G7oIAJYCAAwACAn6G7oIAJYCAAAA.',
['咆哮']='咆哮斩杀者:BAAALgAECgYJDgAAAA==.',
['哈儿']='哈儿宝宝:BAAALgAECgEJAQAAAA==.',
['喵飞']='喵飞鸿:BAAALgAECgYJCAAAAA==.',
['喷火']='喷火龙:BAAALgAFFAIJAgAAAA==.',
['嗜酒']='嗜酒丶:BAAALgAECgIJAgAAAA==.',
['囡哒']='囡哒哆:BAAALgAECgMJAwAAAA==.',
['堕落']='堕落的瓦斯琦:BAAALgADCgEJAQAAAA==.',
['塔尔']='塔尔雷蛮图腾:BAAALgADCgEJAQAAAA==.',
['夏沫']='夏沫浅浅:BAAALgAECgQJBAAAAA==.',
['大白']='大白兔灬奶糖:BAAALgAFFAEJAQAAAA==.',
['大被']='大被无眠:BAAALgAECgMJAwAAAA==.',
['套你']='套你小嘴吧:BAAALgAFFAEJAQAAAA==.',
['妙蛙']='妙蛙种子:BAACLgAFFH8MAAICAAQJphpGCgA1AQACAAQJphpGCgA1AQAuAAQKfx8AAwIACAmcIOcKAOsCAAIACAmcIOcKAOsCAAsAAQnEB9J+ADMAAAAA.',
['姑娘']='姑娘你别走:BAAALgAECgYJBgAAAA==.',
['威克']='威克斯卡尔:BAAALgADCgEJAQAAAA==.',
['学长']='学长:BAAALgAFFAEJAQAAAA==.',
['寒羽']='寒羽洋:BAAALgAECgMJAwAAAA==.',
['小浣']='小浣熊干吃面:BAAALgADCgcJBwAAAA==.',
['小玥']='小玥玥:BAAALgAECgQJBAAAAA==.',
['小阿']='小阿叁:BAAALgADCgEJAQAAAA==.小阿肆:BAAALgAFFAQJAgAAAA==.',
['尬聊']='尬聊之王:BAAALgADCgcJCgAAAA==.',
['巧克']='巧克力奶豆丶:BAAALgAECgcJBwAAAA==.',
['强灬']='强灬干丶:BAAALgAFFAEJAgAAAA==.',
['强萨']='强萨灬丶:BAAALgAECgcJDgAAAA==.',
['德一']='德一只:BAAALgAECgYJCQABLgAFFAQJCQADAB0gAA==.',
['德道']='德道多助嚒:BAAALgADCgEJAQAAAA==.',
['我不']='我不会奶:BAAALgAECgEJAQAAAA==.',
['我的']='我的二哈呢:BAACLgAFFH8NAAQNAAQJrhtrDABVAQANAAQJlxlrDABVAQAOAAMJ3Q7LAwAKAQAPAAEJdBjWIABfAAAuAAQKfx8AAw0ACAnqH8AQALMCAA0ACAnqH8AQALMCAA8ABAkgEJpxABMBAAAA.',
['抬手']='抬手打冲拳:BAACLgAFFH8IAAIPAAMJ6hNhCwAHAQAPAAMJ6hNhCwAHAQAuAAQKfx4AAg8ACAlOIMILAOQCAA8ACAlOIMILAOQCAAAA.',
['抽如']='抽如象:BAAALgAECgEJAQAAAA==.',
['抽锐']='抽锐克抽的:BAAALgAECgcJAQAAAA==.',
['摆王']='摆王:BAACLgAFFH8FAAIQAAIJdiMdKQDQAAAQAAIJdiMdKQDQAAAuAAQKfyEABBAACAmOJb8EAFoCABAACAmgJL8EAFoCABEABAnLJFkUAKgBABIAAQkAAJ8fAHQAAAAA.',
['擦擦']='擦擦二号:BAAALgAECgIJBAAAAA==.',
['新手']='新手拒绝碰瓷:BAAALgAECgEJAQAAAA==.',
['旧与']='旧与花飞:BAABLgAFFH8HAAIIAAQJkRTHGABnAQAIAAQJkRTHGABnAQAAAA==.',
['星星']='星星火焰:BAAALgADCgUJBQAAAA==.',
['晚十']='晚十一限网:BAACLgAFFH8EAAIQAAIJkyF6KQDNAAAQAAIJkyF6KQDNAAAuAAQKfyIAAxEACAnNIBYOAOUBABAABgkFIHpBAAkCABEABQnwIxYOAOUBAAAA.晚十一限罔:BAAALgAFFAEJAQABLgAFFAUJBwAIAMcZAA==.',
['普罗']='普罗德莫尔:BAAALgAECgMJBAAAAA==.',
['暴雪']='暴雪:BAAALgADCgEJAQAAAA==.',
['有猫']='有猫腻:BAAALgAECgYJBwAAAA==.',
['木多']='木多多:BAAALgADCgcJBwAAAA==.',
['术之']='术之高阁:BAAALgAECgEJAQAAAA==.',
['李火']='李火旺:BAAALgADCgEJAQAAAA==.',
['李鱼']='李鱼儿:BAAALgAECgMJBgAAAA==.',
['枫绝']='枫绝恋涙丶:BAAALgAFFAIJBAAAAA==.',
['枫舞']='枫舞漫天:BAAALgAECgIJAgAAAA==.',
['柠檬']='柠檬薄荷:BAAALgAECgcJDAABLgAFFAMJBgATAEEJAA==.',
['桑昕']='桑昕如言丶:BAAALgAECgMJBgAAAA==.',
['森多']='森多木:BAAALgAFFAMJAwAAAA==.',
['欣如']='欣如雪:BAABLgAECn8UAAMQAAgJjRoATQDiAQAQAAcJGxgATQDiAQARAAIJGSCZQgCqAAAAAA==.',
['氿酔']='氿酔:BAAALgAECgMJAwAAAA==.',
['江西']='江西待嫁公主:BAAALgAECgQJBAAAAA==.',
['汤包']='汤包嘟嘟糖:BAAALgADCgIJAgABLgAFFAMJBAAQAJMhAA==.',
['沙漠']='沙漠之狐:BAAALgAFFAIJBAAAAA==.',
['法力']='法力残渣龙:BAAALgAECgYJCgAAAA==.',
['洋马']='洋马驾驶员:BAAALgAECgEJAQABLgAFFAQJCQADAB0gAA==.',
['灭霸']='灭霸猎魂:BAAALgAECgEJAQAAAA==.',
['炫苦']='炫苦:BAAALgADCgEJAQAAAA==.',
['無忌']='無忌哥哥:BAABLgAFFH8LAAMQAAQJmCYpCgBBAQAQAAMJfiYpCgBBAQARAAEJ5SZtDwBzAAAAAA==.',
['熊猫']='熊猫酱丶:BAAALgAECgEJAQAAAA==.',
['爱蜜']='爱蜜莉雅:BAAALgAECgIJAgAAAA==.',
['牛气']='牛气十足:BAACLgAFFH8KAAIUAAQJTgoBDAAZAQAUAAQJTgoBDAAZAQAuAAQKfx0AAhQACAkgIfMIAOcCABQACAkgIfMIAOcCAAAA.牛气骁德:BAAALgAECgMJAwAAAA==.',
['牛頓']='牛頓:BAAALgAECgYJEwAAAA==.',
['牵手']='牵手丶:BAAALgAFFAIJAwAAAA==.',
['狂奔']='狂奔不回头:BAACLgAFFH8KAAIBAAQJyBP2FQBMAQABAAQJyBP2FQBMAQAuAAQKfx0AAgEACAnGIJ4eAMkCAAEACAnGIJ4eAMkCAAAA.',
['猎鹰']='猎鹰一今今:BAAALgADCgcJBwAAAA==.',
['王大']='王大锤:BAAALgAECgcJEAAAAA==.',
['王者']='王者叁号机:BAAALgADCgIJAgAAAA==.王者降临:BAACLgAFFH8NAAIVAAQJdCMeAgCgAQAVAAQJdCMeAgCgAQAuAAQKfx8AAhUACAkcJQICAFkDABUACAkcJQICAFkDAAAA.',
['疯癫']='疯癫到巅峰:BAAALgAECgYJCwAAAA==.',
['痰少']='痰少:BAACLgAFFH8OAAIWAAQJUhrmBQBrAQAWAAQJUhrmBQBrAQAuAAQKfxcAAhYABwlDHyETAFwCABYABwlDHyETAFwCAAAA.',
['瘋狂']='瘋狂的帽商:BAAALgADCgIJAgABLgAECgQJBAAXAAAAAA==.',
['直流']='直流电:BAABLgAFFH8QAAIKAAUJiRibCABSAQAKAAUJiRibCABSAQAAAA==.',
['真男']='真男人孙悟空:BAAALgADCgUJBQAAAA==.',
['睡会']='睡会儿:BAAALgAECgYJBgAAAA==.',
['破如']='破如防:BAAALgAECgYJDQAAAA==.',
['碎心']='碎心:BAAALgAECgEJAwABLgAFFAQJCQADAB0gAA==.',
['神经']='神经骑天下:BAAALgAECgcJBwAAAA==.',
['离谱']='离谱:BAAALgADCgMJAwAAAA==.',
['秀宇']='秀宇:BAAALgAECgQJBAAAAA==.',
['粉色']='粉色法拉利:BAAALgADCgYJCwAAAA==.',
['粉象']='粉象象:BAAALgAECgcJBwABLgAFFAYJBQABAEokAA==.',
['粉骑']='粉骑士:BAAALgAECgEJAQAAAA==.',
['累坏']='累坏了:BAAALgAECgYJCAABLgAFFAEJAQAXAAAAAA==.',
['红尘']='红尘笑:BAABLgAECn8gAAMYAAgJxBOdEgCgAQAYAAcJVBOdEgCgAQAZAAEJZhaTbwA8AAAAAA==.红尘醉:BAAALgADCgEJAgAAAA==.',
['红菏']='红菏菡萏:BAAALgAECgYJCwAAAA==.',
['纯情']='纯情小萌男:BAAALgAFFAEJAQAAAA==.',
['细嗅']='细嗅蔷薇:BAAALgAECgYJBgAAAA==.',
['老友']='老友粉:BAAALgAECgYJBgAAAA==.',
['肚子']='肚子丨:BAAALgAECgUJBgAAAA==.',
['肚肚']='肚肚丶:BAAALgADCgIJAgAAAA==.',
['艾蕾']='艾蕾茵:BAAALgAECgQJBAAAAA==.',
['芯茹']='芯茹雪:BAAALgADCgEJAQAAAA==.',
['花儿']='花儿少年:BAAALgAECgEJAQAAAA==.',
['萌丶']='萌丶米迦勒:BAAALgAECgIJAgAAAA==.',
['萌哒']='萌哒哒拉:BAAALgAECgEJAQABLgAFFAQJCQADAB0gAA==.',
['虎狐']='虎狐丶:BAAALgAECgMJAwAAAA==.',
['蜻蜓']='蜻蜓队长:BAAALgAFFAIJBAAAAA==.',
['蟹中']='蟹中蟹:BAABLgAECn8YAAIZAAcJaSTTFgDgAgAZAAcJaSTTFgDgAgAAAA==.',
['血之']='血之漫绒:BAAALgAECgQJBQAAAA==.',
['血灵']='血灵狂魔:BAAALgADCgcJBwAAAA==.',
['血起']='血起舞剑轻吟:BAAALgAECgEJAQAAAA==.',
['许尽']='许尽欢丶:BAAALgAECgMJAwAAAA==.',
['诠释']='诠释东锅锅:BAAALgAFFAEJAgAAAA==.',
['贝蒂']='贝蒂:BAAALgAECgcJBwABLgAECgkJCQAXAAAAAA==.',
['趙灬']='趙灬子灬龍:BAAALgAECgEJAwAAAA==.',
['路西']='路西法丶晨星:BAAALgAECgEJBAABLgAFFAQJCQADAB0gAA==.',
['软奶']='软奶酪甜心:BAAALgADCgMJAwAAAA==.',
['软脚']='软脚虾妮扣:BAAALgAECgYJDAAAAA==.',
['边境']='边境之刃:BAAALgADCgIJAgAAAA==.',
['迦罗']='迦罗娜:BAAALgAECgMJAwAAAA==.',
['那落']='那落伽:BAACLgAFFH8JAAIDAAQJHSAwBgCMAQADAAQJHSAwBgCMAQAuAAQKfxgAAgMACAnfH8ASALkCAAMACAnfH8ASALkCAAAA.',
['醉极']='醉极弹歌:BAAALgAFFAIJAgAAAA==.',
['锤神']='锤神之喵喵:BAAALgAECgUJBQAAAA==.',
['阳光']='阳光薄荷:BAACLgAFFH8GAAMTAAMJQQkZGwCUAAATAAIJyQwZGwCUAAAaAAEJLwKXCwBKAAAuAAQKfx0AAxMACAmGGXwSAFYCABMACAmkGHwSAFYCABoABAnlF48jAAsBAAAA.',
['雪影']='雪影影雪:BAAALgAECgEJAQAAAA==.',
['雪翼']='雪翼影魅:BAAALgAECgQJCQAAAA==.',
['雷加']='雷加尔:BAAALgAFFAIJAwAAAA==.',
['雷妮']='雷妮拉:BAAALgADCgQJBAAAAA==.',
['霸王']='霸王灬熊:BAAALgAECgEJAQAAAA==.霸王灬羽:BAAALgAECgEJAQAAAA==.',
['靈丿']='靈丿兒:BAAALgADCgEJAQAAAA==.',
['青衣']='青衣丶:BAAALgAECgYJCAAAAA==.',
['风丶']='风丶凛:BAAALgAECgQJBgAAAA==.',
['风入']='风入疏竹:BAABLgAECn8ZAAICAAcJMQxXXAA9AQACAAcJMQxXXAA9AQAAAA==.',
['风暴']='风暴恶灵:BAAALgAECgEJAgAAAA==.',
['飞翔']='飞翔的荷兰牛:BAAALgAFFAIJAgAAAA==.',
['香香']='香香公主:BAAALgAFFAEJAQAAAA==.',
['骑我']='骑我驾驾:BAAALgAECgYJBgAAAA==.',
['高科']='高科技:BAAALgAFFAIJBAAAAA==.',
['魔王']='魔王女神:BAAALgAECgQJBAAAAA==.',
['麽有']='麽有鱼丸:BAAALgADCgEJAQAAAA==.',
['龙丶']='龙丶米迦勒:BAAALgADCgUJBQAAAA==.',
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
