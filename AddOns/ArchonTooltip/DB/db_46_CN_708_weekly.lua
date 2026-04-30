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

local lookup = {'Unknown-Unknown','DeathKnight-Blood','Warrior-Protection','Druid-Balance','Monk-Brewmaster','Druid-Restoration','Priest-Discipline','Priest-Holy','Paladin-Holy','Hunter-Marksmanship','Warrior-Fury','Monk-Windwalker','Monk-Mistweaver','Mage-Frost','Shaman-Elemental','Paladin-Protection','Paladin-Retribution','Hunter-BeastMastery','DeathKnight-Unholy','DemonHunter-Devourer','Warlock-Demonology','Warlock-Destruction','Druid-Guardian','Warrior-Arms','Rogue-Outlaw','Rogue-Assassination','Hunter-Survival','DemonHunter-Vengeance','Evoker-Augmentation','Priest-Shadow','Evoker-Devastation','DemonHunter-Havoc','Evoker-Preservation',}
local provider = {region='CN',realm='月神殿',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Airsupply:BAAALgAECgQJBAAAAA==.',
Ba='Banamaster:BAAALgAECgQJBAABLgAECgUJBQABAAAAAA==.',
Bo='Borlar:BAAALgAECgQJCwAAAA==.',
Cc='Ccwarlock:BAAALgAECggJDQAAAA==.',
Cl='Clarins:BAAALgAECgEJAgAAAA==.',
En='Enchant:BAAALgAECgUJBwAAAA==.',
Fa='Falin:BAAALgAECgkJCQAAAA==.Fantasyning:BAAALgAECgcJCAAAAA==.',
Go='Gosunny:BAAALgAECgUJCgAAAA==.',
Ha='Havocc:BAABLgAFFH8TAAICAAYJjgpFBgAzAQACAAYJjgpFBgAzAQAAAA==.',
Ko='Komiki:BAAALgADCgYJCwAAAA==.',
Lg='Lgdamefans:BAAALgAECgcJBwAAAA==.',
Ma='Mamokoi:BAAALgAECgYJDQAAAA==.',
Me='Metrogoose:BAAALgADCgUJBQAAAA==.',
Mi='Minotaudryad:BAAALgAECgEJAQAAAA==.',
Mo='Moonii:BAAALgAFFAEJAgAAAA==.Moonkk:BAAALgAECgQJBAAAAA==.',
Nu='Numberfive:BAAALgADCgIJAgAAAA==.',
Ol='Olythera:BAABLgAFFH8KAAIDAAQJHg7lBQANAQADAAQJHg7lBQANAQAAAA==.',
Pe='Peace:BAAALgADCgMJAwAAAA==.',
Ph='Phanpuy:BAAALgAFFAIJAgAAAA==.Pharah:BAAALgAFFAMJBAAAAA==.',
Pi='Pitohui:BAAALgAECgQJBAAAAA==.',
Qa='Qadira:BAAALgAECgUJBgAAAA==.',
Qi='Qihuctx:BAAALgAECgUJCAAAAA==.',
Ri='Rixiu:BAAALgAECgQJBAAAAA==.',
Se='Sevenstars:BAAALgAECgQJBAAAAA==.',
Sk='Skydive:BAAALgAECgEJAQAAAA==.',
Sy='Sylvanaz:BAAALgAECgUJBQAAAA==.',
Yw='Ywwuyi:BAABLgAECn8lAAIEAAgJvR7uAwDsAQAEAAgJvR7uAwDsAQAAAA==.',
['一介']='一介布衣:BAAALgAECgYJCgAAAA==.',
['一只']='一只橘喵:BAAALgAFFAEJAQABLgAFFAMJCAAFAI4iAA==.',
['上山']='上山去修道:BAAALgAECgkJCQAAAA==.',
['下五']='下五洋捉鼈:BAAALgAECgMJAwAAAA==.',
['不学']='不学吾术:BAAALgAECgcJDQAAAA==.',
['不用']='不用幻化:BAABLgAFFH8HAAIGAAQJ+wr0CwCUAAAGAAQJ+wr0CwCUAAAAAA==.',
['两串']='两串羊肉串:BAAALgAFFAEJAgAAAA==.',
['丨赫']='丨赫灬夕丨:BAAALgAECgUJBwAAAA==.',
['丷欣']='丷欣然:BAAALgADCgUJBQAAAA==.',
['乌布']='乌布里克:BAAALgAECgYJBwAAAA==.',
['乖乖']='乖乖站好丶:BAACLgAFFH8bAAIHAAcJtBuqAACHAgAHAAcJtBuqAACHAgAuAAQKfxYAAwcACAnrIZUFAPYCAAcACAnrIZUFAPYCAAgAAQmFEht7ADwAAAAA.',
['九成']='九成九:BAAALgAFFAEJAgAAAA==.',
['云中']='云中逸:BAAALgAECgYJBgAAAA==.',
['云消']='云消雾散:BAAALgAECgIJAgAAAA==.',
['亚斯']='亚斯格特:BAAALgADCgYJBgAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgkJCQAAAA==.',
['介真']='介真是毕业的:BAAALgAFFAMJAwAAAA==.',
['令羽']='令羽支羽:BAAALgADCgcJBwAAAA==.',
['以紫']='以紫乱朱:BAAALgAECgYJCwAAAA==.',
['优秀']='优秀的萨满:BAAALgAECgEJAQABLgAFFAIJAwABAAAAAA==.优秀的迪克:BAAALgAFFAIJAwAAAA==.',
['伴枝']='伴枝烟:BAAALgAECgEJAQAAAA==.',
['你也']='你也想起舞吗:BAAALgAFFAQJBAAAAA==.你也要起舞吗:BAAALgAFFAIJAgAAAA==.',
['你是']='你是最棒的咕:BAACLgAFFH8NAAIJAAQJlxv1BgBmAQAJAAQJlxv1BgBmAQAuAAQKfyEAAgkABwm3I1oKAM8CAAkABwm3I1oKAM8CAAAA.',
['依依']='依依小雪:BAAALgAECgEJAQAAAA==.',
['修特']='修特罗海姆:BAAALgAECgcJDQAAAA==.',
['偷偷']='偷偷加餐:BAAALgAFFAEJAQABLgAFFAcJGwAHALQbAA==.',
['光之']='光之使者:BAAALgAFFAEJAQAAAA==.',
['光辣']='光辣逼:BAAALgAECgUJCAAAAA==.',
['克里']='克里格:BAAALgAECgcJBwAAAA==.',
['入梦']='入梦叶:BAABLgAFFH8IAAMEAAUJQBtbCgBEAQAEAAMJuiNbCgBEAQAGAAUJaRMzBQAtAQAAAA==.',
['全场']='全场两分钱:BAACLgAFFH8KAAIKAAUJkxOaBgC1AQAKAAUJkxOaBgC1AQAuAAQKfxYAAgoACAlpI8EOAMkCAAoACAlpI8EOAMkCAAAA.',
['八千']='八千里寻日月:BAAALgAFFAMJBAAAAA==.',
['八百']='八百汉墓:BAAALgAFFAIJBAAAAA==.',
['八秒']='八秒真男人:BAAALgAECgUJBQAAAA==.',
['六道']='六道之修罗:BAAALgADCgEJAQAAAA==.六道天堂:BAAALgADCgEJAQAAAA==.',
['冈仁']='冈仁波齐:BAABLgAECn8lAAILAAgJCxhpHQBjAgALAAgJCxhpHQBjAgAAAA==.',
['军团']='军团瑞密克斯:BAAALgAECgUJBwAAAA==.军团璐:BAAALgAECgEJAgAAAA==.',
['冷锋']='冷锋破晓之刃:BAAALgAECgkJCgAAAA==.',
['凛冬']='凛冬之吻:BAACLgAFFH8NAAQFAAQJFCAfBQCDAQAFAAQJFCAfBQCDAQAMAAIJVQehDgCJAAANAAEJMRgBFgBKAAAuAAQKfyIABAUACAnkJPIIAPgCAAUABwnNJfIIAPgCAA0ABwnqHn8PAGECAAwABAmuIzEoAJgBAAEuAAUUBgkIAAQAQBsA.',
['凝眉']='凝眉笑想思:BAAALgAECgQJBgAAAA==.',
['划水']='划水专业:BAAALgAECgYJCwAAAA==.划水圣光:BAAALgAECgYJBgAAAA==.',
['刘鹏']='刘鹏啊:BAAALgAECgEJAQAAAA==.刘鹏来了:BAAALgAECgMJBAAAAA==.',
['剑神']='剑神一笑:BAAALgAECgcJEwAAAA==.',
['化神']='化神后期:BAAALgAECgIJAQAAAA==.',
['北落']='北落丿:BAACLgAFFH8GAAIOAAMJzQ1tLAAFAQAOAAMJzQ1tLAAFAQAuAAQKfxUAAg4ABwlgHKipAIcBAA4ABwlgHKipAIcBAAAA.',
['匚丶']='匚丶东方树叶:BAAALgADCgcJBwAAAA==.匚丶元气森林:BAAALgAECgcJDAAAAA==.匚丶大窑橙诺:BAAALgAFFAMJAwABLgAFFAMJDAAEAMUVAA==.匚丶山楂树下:BAACLgAFFH8PAAIDAAQJkwtLBgAEAQADAAQJkwtLBgAEAQAuAAQKfxgAAwMACAmUEHYgADwBAAMABQk2EnYgADwBAAsABwnwCBliACkBAAAA.匚丶崂山可乐:BAABLgAECn8WAAIPAAgJkQLLTgALAQAPAAgJkQLLTgALAQAAAA==.匚丶果粒橙:BAACLgAFFH8FAAMQAAMJBwTBBACCAAAQAAMJBwTBBACCAAARAAEJXQDiOwA1AAAuAAQKfx4AAxAABwk0CscfAAkBABAABgljC8cfAAkBABEABgnWAh3UAOIAAAAA.匚丶水晶葡萄:BAABLgAECn8ZAAISAAgJcQSOUQB0AQASAAgJcQSOUQB0AQAAAA==.匚丶阿萨姆:BAAALgAECgcJEQAAAA==.',
['十一']='十一哈哈:BAAALgADCgUJBQAAAA==.',
['十二']='十二宫之巨蟹:BAAALgAECgYJCAAAAA==.',
['半粒']='半粒丹:BAACLgAFFH8IAAITAAMJNCXRCAA4AQATAAMJNCXRCAA4AQAuAAQKfx0AAhMACAlvIt4MADMDABMACAlvIt4MADMDAAAA.',
['卖客']='卖客接客迅:BAAALgAECgEJAQAAAA==.',
['叁两']='叁两叁:BAAALgADCgEJAQAAAA==.',
['又菜']='又菜又嘴硬:BAABLgAFFH8LAAIDAAYJPhODAQDPAQADAAYJPhODAQDPAQAAAA==.',
['变色']='变色的小菊花:BAAALgAECgcJBwAAAA==.',
['古尓']='古尓丹:BAAALgAFFAEJAQAAAA==.',
['叩玉']='叩玉京:BAAALgAECgcJDQAAAA==.',
['叶无']='叶无枫:BAAALgAECgMJBAAAAA==.',
['吃一']='吃一口:BAAALgAFFAQJBAAAAA==.',
['吃三']='吃三口:BAAALgAECgcJBwAAAA==.',
['吃五']='吃五口:BAAALgAFFAQJBAAAAA==.',
['吃菠']='吃菠萝的奶牛:BAABLgAECn8ZAAIUAAgJCAxZGgAuAQAUAAgJCAxZGgAuAQAAAA==.',
['名姝']='名姝:BAAALgAECgEJAQAAAA==.',
['后羿']='后羿之子:BAABLgAFFH8GAAIKAAMJ3wvDFgDjAAAKAAMJ3wvDFgDjAAAAAA==.',
['咕咕']='咕咕大王:BAABLgAFFH8HAAMGAAQJExB/HgCCAAAGAAIJDwd/HgCCAAAEAAMJHw/zGgBLAAAAAA==.',
['咖啡']='咖啡:BAABLgAFFH8QAAIGAAUJuBvaAwClAQAGAAUJuBvaAwClAQAAAA==.',
['哔哔']='哔哔拉布:BAAALgAECgcJBwAAAA==.',
['啦乄']='啦乄啦:BAACLgAFFH8SAAMVAAUJFSXPCQAqAQAVAAQJuiTPCQAqAQAWAAEJKCYwAwBlAAAuAAQKfyEAAxUACAl0InI7AB4CABUABgmeIHI7AB4CABYAAwm6IxYlADMBAAAA.啦乄锯:BAAALgADCgQJAQABLgAFFAUJEgAVABUlAA==.啦乄黑:BAABLgAFFH8HAAIUAAQJKAzhFQAiAQAUAAQJKAzhFQAiAQABLgAFFAUJEgAVABUlAA==.',
['喜欢']='喜欢牛肉饭:BAAALgAFFAQJBAABLgAFFAYJCwAWANEVAA==.',
['喵喵']='喵喵多狸:BAAALgAECgcJEwAAAA==.喵喵大德:BAAALgADCgUJBQAAAA==.',
['嗜杀']='嗜杀者丨枯骨:BAAALgAFFAEJAQAAAA==.',
['嘘丶']='嘘丶别哭:BAAALgAECgIJAgAAAA==.',
['四季']='四季映姫:BAAALgAECgUJBQAAAA==.',
['四系']='四系沸物:BAABLgAECn8bAAIXAAkJ/Q8CCwDjAQAXAAkJ/Q8CCwDjAQAAAA==.',
['回忆']='回忆精灵:BAAALgAECgIJAgAAAA==.',
['团长']='团长缺德:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光永驻:BAAALgAECgQJBgAAAA==.',
['圣武']='圣武堂帕拉丁:BAAALgAECgYJCQAAAA==.',
['在冰']='在冰与火之间:BAAALgADCgYJBgAAAA==.',
['地狱']='地狱勾魂使者:BAAALgAECgYJBgAAAA==.',
['坏事']='坏事大王:BAAALgAFFAEJAQAAAA==.',
['塔纳']='塔纳托斯:BAAALgAECgYJBwAAAA==.',
['塞勒']='塞勒斯汀:BAAALgAECgkJBwAAAA==.',
['墓后']='墓后丿大少:BAAALgAFFAEJAQAAAA==.',
['壬生']='壬生菊千代:BAAALgAECgYJDwABLgAECggJJQAEAL0eAA==.',
['夜丶']='夜丶墓:BAAALgAFFAEJAQABLgAFFAQJCwATAK0TAA==.',
['夜想']='夜想曲:BAAALgADCgEJAQAAAA==.',
['大器']='大器晚成:BAAALgAECgEJAQAAAA==.',
['大地']='大地忽悠你:BAAALgAECgcJCwAAAA==.',
['大辉']='大辉狼:BAAALgAECgEJAQAAAA==.',
['天下']='天下睿行:BAABLgAECn8jAAMLAAgJ+RiiHgBbAgALAAgJ+RiiHgBbAgADAAIJ7wuBOgB3AAAAAA==.',
['天天']='天天中彩票:BAAALgAECgYJEwAAAA==.天天戰晚班:BAAALgAECgYJBgAAAA==.',
['天添']='天添:BAAALgAECgcJDQAAAA==.',
['天霜']='天霜蓝雨:BAAALgAECgEJAQAAAA==.',
['太猛']='太猛了太猛了:BAABLgAFFH8IAAMLAAUJaRaXBACsAQALAAUJaRaXBACsAQAYAAEJbRbsCQBbAAAAAA==.',
['奈奈']='奈奈:BAABLgAECn8aAAMZAAgJjBPyAwDtAQAZAAcJdhXyAwDtAQAaAAYJ2BB8CwB0AQABLgAFFAQJDwAHAIEmAA==.',
['奥利']='奥利奥:BAAALgAECgEJAQAAAA==.',
['奥空']='奥空心白:BAAALgAECgQJCwABLgAECggJJQAEAL0eAA==.',
['奥贝']='奥贝尔多芙:BAABLgAFFH8FAAITAAIJthUVOACrAAATAAIJthUVOACrAAAAAA==.',
['如见']='如见青山:BAAALgADCgEJAQAAAA==.',
['妙林']='妙林:BAAALgAECgEJAQABLgAFFAYJBAABAAAAAA==.',
['季竹']='季竹儿:BAAALgAECggJDwAAAA==.',
['宛乡']='宛乡城主:BAAALgADCgEJAQAAAA==.',
['宝宝']='宝宝:BAAALgAECgYJCAAAAA==.',
['家具']='家具城之王:BAAALgAECgUJBgAAAA==.',
['寂寞']='寂寞心:BAAALgAECgYJCQAAAA==.',
['寒冬']='寒冬将至:BAAALgADCgIJAgAAAA==.',
['封神']='封神的小菊花:BAAALgAECgQJBAAAAA==.',
['小伙']='小伙子跳跳蹦:BAAALgAECgUJBQAAAA==.',
['小半']='小半半:BAABLgAFFH8FAAIMAAQJaA3WCADoAAAMAAQJaA3WCADoAAAAAA==.',
['小嘀']='小嘀咕:BAACLgAFFH8KAAIOAAMJQwrjFADmAAAOAAMJQwrjFADmAAAuAAQKfxgAAg4ABwmTGAppAAQCAA4ABwmTGAppAAQCAAAA.',
['小尾']='小尾巴萌萌哒:BAABLgAFFH8SAAIRAAQJUA2lDQA9AQARAAQJUA2lDQA9AQAAAA==.',
['小师']='小师妹:BAAALgADCgEJAQAAAA==.',
['小幻']='小幻熊:BAABLgAFFH8IAAIFAAMJjiJICgA2AQAFAAMJjiJICgA2AQAAAA==.',
['小烧']='小烧烤:BAABLgAECn8YAAQKAAcJ6hjjLwCzAQAKAAcJ3hPjLwCzAQASAAIJrxuAngCTAAAbAAEJpg16LwA1AAAAAA==.',
['小玐']='小玐蛋:BAAALgAECgcJBwAAAA==.',
['小落']='小落:BAAALgADCgEJAQAAAA==.',
['小虫']='小虫虫萌萌哒:BAABLgAFFH8IAAISAAQJfRBiBgA8AQASAAQJfRBiBgA8AQAAAA==.',
['小飞']='小飞棍萌萌哒:BAAALgAECgEJAQAAAA==.',
['尐萌']='尐萌柚丶:BAAALgAECgYJBgAAAA==.',
['就是']='就是当兵:BAAALgAECgcJEAAAAA==.',
['山阴']='山阴路的夏天:BAAALgAFFAIJAwAAAA==.',
['巧克']='巧克力糖:BAAALgADCgIJAgAAAA==.',
['巨型']='巨型橘猫:BAAALgADCgcJBwAAAA==.',
['巨象']='巨象纵横:BAAALgAECgIJBQAAAA==.',
['布瑞']='布瑞克铁炉:BAACLgAFFH8FAAMYAAMJExLSAwAFAQAYAAMJExLSAwAFAQALAAIJ+wEFHQCLAAAuAAQKfxkAAxgABwlzG+EGAFYCABgABwnbGuEGAFYCAAsABwkUFIc1ANIBAAAA.',
['帝灬']='帝灬骑士:BAAALgAECgEJAgAAAA==.',
['幻丶']='幻丶格拉墨:BAABLgAFFH8FAAICAAIJqRrvDACiAAACAAIJqRrvDACiAAAAAA==.',
['康斯']='康斯:BAAALgAECgYJBgAAAA==.',
['归真']='归真:BAAALgADCgUJBQAAAA==.',
['得鹿']='得鹿梦鱼:BAAALgAECgEJAQAAAA==.',
['心丶']='心丶跳:BAAALgAECgEJAQAAAA==.',
['心怀']='心怀圣光:BAAALgAECgYJBwAAAA==.',
['心情']='心情午后:BAAALgAECgQJBwAAAA==.',
['心跳']='心跳:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁航少:BAAALgAECgUJBQAAAA==.',
['思乡']='思乡的浪子:BAAALgAECgYJBgAAAA==.',
['恶魔']='恶魔十三:BAAALgADCgYJBgAAAA==.',
['悠悠']='悠悠侏侏:BAABLgAECn8UAAMLAAcJPBS/CwBkAQALAAcJPBS/CwBkAQADAAEJfgswFAA0AAAAAA==.',
['悲剧']='悲剧的奥洛夫:BAAALgADCgEJAQAAAA==.',
['想吃']='想吃木薯汤:BAAALgAECgkJBAABLgAFFAYJCwAWANEVAA==.',
['惺惺']='惺惺相吸:BAAALgADCggJCAAAAA==.',
['我爱']='我爱长发飘飘:BAAALgAECgYJCwAAAA==.',
['打嗰']='打嗰锤吇:BAAALgAECgQJBwAAAA==.',
['折耳']='折耳根味酸奶:BAAALgAECgcJBwAAAA==.',
['拉布']='拉布拉龙:BAAALgADCgIJAgABLgAFFAYJCAAEAEAbAA==.',
['拉蜜']='拉蜜亚:BAAALgAECgYJDgAAAA==.',
['拉顿']='拉顿:BAAALgAECgEJAQAAAA==.',
['拔丝']='拔丝香菜:BAAALgAECgYJBgAAAA==.',
['捡乐']='捡乐子大王:BAAALgAFFAUJAwAAAA==.',
['提丰']='提丰:BAAALgADCgUJBAAAAA==.',
['提里']='提里奧弗丁:BAAALgAECgMJBAAAAA==.',
['摩拉']='摩拉克斯:BAAALgADCgMJAwAAAA==.',
['放逐']='放逐星星:BAAALgAECgMJAwAAAA==.',
['敖广']='敖广:BAAALgAECgIJAgAAAA==.',
['新海']='新海天:BAABLgAECn8eAAQSAAkJpyBTDwDBAgASAAgJoCBTDwDBAgAKAAYJVR7OKwDMAQAbAAMJmw3vJAChAAAAAA==.',
['无野']='无野:BAAALgAECgcJCAAAAA==.',
['明月']='明月醉雪颜:BAAALgADCgQJBAAAAA==.',
['星痕']='星痕醉月:BAABLgAFFH8GAAIRAAUJDBlTBACtAQARAAUJDBlTBACtAQAAAA==.',
['晕晕']='晕晕小公主:BAAALgAFFAIJBAAAAA==.晕晕小法:BAAALgAECgYJBgAAAA==.',
['暴走']='暴走的棉花糖:BAAALgAECgYJBgABLgAFFAUJBQAcAFMlAA==.',
['暴躁']='暴躁土拨鼠:BAAALgAECgYJCQAAAA==.',
['最后']='最后的圣骑:BAAALgADCgEJAQAAAA==.',
['月冷']='月冷千山:BAAALgAECgcJEgAAAA==.',
['月卡']='月卡玩瞎眼:BAAALgAECgQJBAAAAA==.',
['月夜']='月夜战神:BAAALgAECgUJBwAAAA==.',
['月有']='月有阴晴圆缺:BAAALgADCgMJAwAAAA==.',
['月色']='月色如初:BAAALgAECgMJBwAAAA==.',
['望月']='望月独酌:BAAALgAECgkJBwABLgAFFAYJCAAdAAkTAA==.',
['李狗']='李狗剩:BAAALgAECgkJDwAAAA==.',
['李耄']='李耄耋:BAABLgAECn8dAAIFAAkJuxFqGwAoAgAFAAkJuxFqGwAoAgAAAA==.',
['李铁']='李铁柱:BAABLgAECn8YAAIDAAkJ1AzyEAD5AQADAAkJ1AzyEAD5AQAAAA==.',
['枯葉']='枯葉丶開花:BAAALgAECgYJBgAAAA==.',
['桃花']='桃花面:BAAALgAECgMJAwAAAA==.',
['梦乔']='梦乔西:BAAALgAECgUJCQAAAA==.',
['梦见']='梦见月瑞希:BAAALgAECgYJDQAAAA==.',
['梵幻']='梵幻:BAAALgAECgYJBgAAAA==.',
['梶玲']='梶玲子:BAAALgADCgYJBgAAAA==.',
['棉棉']='棉棉包:BAAALgAFFAIJAgAAAA==.',
['棠梨']='棠梨煎雪:BAAALgAFFAIJAgAAAA==.',
['樱桃']='樱桃小团子:BAAALgAECgUJBQAAAA==.',
['樱羽']='樱羽艾玛:BAAALgAECgQJBwAAAA==.',
['欣仔']='欣仔:BAAALgAFFAUJAwAAAA==.',
['欣欣']='欣欣心心:BAAALgAECgIJAgAAAA==.',
['正在']='正在墨迹中:BAAALgAECgEJAQAAAA==.正在祈祷中:BAAALgAECgUJCAAAAA==.',
['死亡']='死亡星辰:BAABLgAFFH8OAAICAAUJShC5BQBAAQACAAUJShC5BQBAAQAAAA==.',
['死怨']='死怨:BAACLgAFFH8FAAITAAMJJw4VKwDuAAATAAMJJw4VKwDuAAAuAAQKfxYAAhMACAmIG6AmAKECABMACAmIG6AmAKECAAAA.',
['氨酚']='氨酚守己:BAABLgAECn8XAAMVAAcJvBdMUwDNAQAVAAcJvBdMUwDNAQAWAAQJGwePPADCAAAAAA==.',
['水小']='水小水:BAAALgAECgMJBAAAAA==.',
['求你']='求你了别查了:BAAALgAECgkJAQAAAA==.',
['池本']='池本莉莉娅:BAAALgAECgUJBQAAAA==.',
['流蓮']='流蓮丶:BAAALgAECgQJBQAAAA==.',
['流风']='流风回雪:BAABLgAFFH8NAAIRAAQJCw3gDQA8AQARAAQJCw3gDQA8AQAAAA==.',
['浪子']='浪子白头骑:BAABLgAFFH8OAAIRAAQJfx17BwB5AQARAAQJfx17BwB5AQAAAA==.',
['浮萍']='浮萍:BAABLgAECn8UAAIOAAYJsRT/oACVAQAOAAYJsRT/oACVAQAAAA==.',
['混打']='混打魔王:BAAALgAECgUJBQAAAA==.',
['溷囿']='溷囿:BAAALgAFFAQJBAAAAA==.',
['潇洒']='潇洒神鹰:BAAALgAECgMJAQAAAA==.',
['潘達']='潘達饅:BAAALgAECgIJAgAAAA==.',
['灬巨']='灬巨疯灬:BAAALgAECgYJCgAAAA==.',
['灬逆']='灬逆时针灬:BAAALgAECgcJCwAAAA==.',
['灰原']='灰原同学:BAAALgAFFAIJAgAAAA==.',
['灶门']='灶门祢豆子:BAAALgADCgEJAQAAAA==.',
['炽丶']='炽丶格拉墨:BAAALgAECgYJBgABLgAFFAIJBQACAKkaAA==.',
['烬焰']='烬焰哈麦尔:BAAALgAECgYJCwAAAA==.',
['然然']='然然:BAABLgAFFH8MAAIeAAQJURMhAwAzAQAeAAQJURMhAwAzAQABLgAFFAQJBgAeAAcWAA==.',
['煦寅']='煦寅生晖:BAAALgAECgYJBgAAAA==.',
['爆炒']='爆炒香菜:BAAALgAECgYJCAAAAA==.',
['牛栏']='牛栏山:BAAALgAECgYJDAAAAA==.',
['牛爷']='牛爷不怕:BAAALgAFFAUJAwAAAA==.',
['牧荑']='牧荑:BAAALgADCgEJAQABLgAFFAMJCAAFAI4iAA==.',
['狂干']='狂干:BAACLgAFFH8LAAISAAQJciLNDQDqAAASAAQJciLNDQDqAAAuAAQKfyAAAxIABwmOJpUHABYDABIABwmOJpUHABYDABsABglsJNwRAKUBAAAA.',
['狂戦']='狂戦:BAAALgAECgQJBgAAAA==.',
['狩猎']='狩猎宝宝:BAAALgAECgMJAwAAAA==.',
['猎刹']='猎刹者:BAAALgAECgEJAQAAAA==.',
['猎神']='猎神王:BAAALgADCgUJBQAAAA==.',
['猪猪']='猪猪光铸侠:BAAALgAECgEJAQAAAA==.',
['獭耳']='獭耳獭洛斯:BAABLgAECn8jAAMfAAgJKxdPDgD1AQAfAAgJKxdPDgD1AQAdAAUJlg4HOQARAQAAAA==.',
['玉断']='玉断魂:BAAALgAECgMJAwAAAA==.',
['班婕']='班婕妤:BAABLgAFFH8HAAIVAAIJfQeYPACYAAAVAAIJfQeYPACYAAAAAA==.',
['瓜皮']='瓜皮牧:BAAALgAECgUJCQABLgAFFAIJBAABAAAAAA==.',
['瓦尔']='瓦尔加辣:BAAALgAECgYJDQAAAA==.',
['电疗']='电疗:BAAALgAECgEJAwAAAA==.',
['白毛']='白毛控:BAAALgAECgkJCgAAAA==.',
['破茧']='破茧:BAABLgAECn8UAAICAAkJ9QpaFQC9AQACAAkJ9QpaFQC9AQAAAA==.',
['碇真']='碇真嗣:BAAALgADCgEJAQAAAA==.',
['神武']='神武帝高欢:BAAALgAFFAIJAgAAAA==.',
['空车']='空车老司机:BAAALgAECgEJAQAAAA==.',
['笑尘']='笑尘决:BAABLgAFFH8GAAIFAAMJRxqbEAD7AAAFAAMJRxqbEAD7AAAAAA==.',
['精灵']='精灵依依:BAAALgAECgkJCQAAAA==.',
['糖门']='糖门棍:BAAALgAECgIJAgAAAA==.',
['紫色']='紫色小猪:BAACLgAFFH8TAAIUAAUJgB9zBQDRAQAUAAUJgB9zBQDRAQAuAAQKfycAAhQACQl4IwcDAJ4DABQACQl4IwcDAJ4DAAAA.紫色马尾:BAAALgAECgcJBwABLgAECgkJFwADAMAcAA==.',
['约伯']='约伯:BAAALgAECgEJAgAAAA==.',
['纵享']='纵享湿滑:BAAALgAECgIJAgAAAA==.',
['结伴']='结伴猫:BAAALgADCgMJAQAAAA==.',
['给我']='给我弄死他:BAAALgAECgIJAgAAAA==.给我擦皮鞋:BAAALgAECgkJCwAAAA==.',
['给给']='给给:BAAALgADCgcJBwAAAA==.',
['绝命']='绝命毒师:BAAALgAFFAIJAwAAAA==.',
['罗兰']='罗兰乌瑞恩:BAAALgAECgIJAgAAAA==.',
['罗莉']='罗莉安娜:BAAALgAFFAEJAgAAAA==.',
['耀嘉']='耀嘉音:BAACLgAFFH8IAAIPAAQJ0AVGDQAaAQAPAAQJ0AVGDQAaAQAuAAQKfxcAAg8ACAllGD4eAB0CAA8ACAllGD4eAB0CAAAA.',
['老腊']='老腊肉:BAAALgAECgUJBwAAAA==.',
['耶梦']='耶梦加德:BAAALgAFFAEJAQAAAA==.',
['聊天']='聊天一字六毛:BAAALgADCgUJBQAAAA==.',
['聖光']='聖光之願:BAAALgAECgQJBwAAAA==.',
['肉肉']='肉肉小卷秏:BAAALgAECgIJAQAAAA==.',
['艾瑟']='艾瑟尔:BAAALgADCgEJAQAAAA==.',
['艾莉']='艾莉亚斯:BAAALgADCgcJBwAAAA==.',
['花开']='花开彼岸:BAAALgAECgkJAwAAAA==.',
['花间']='花间酒:BAAALgAECgMJAwAAAA==.',
['若雪']='若雪无痕:BAAALgAECgEJAgAAAA==.',
['苦苦']='苦苦咖啡:BAAALgAECgIJAgAAAA==.',
['范尼']='范尼斯特鲁伊:BAAALgAECgMJAwAAAA==.',
['荒野']='荒野小猎:BAAALgAECgEJAgAAAA==.',
['莎娜']='莎娜:BAABLgAECn8WAAIXAAkJthKICQAIAgAXAAkJthKICQAIAgAAAA==.',
['莫淇']='莫淇洛:BAACLgAFFH8IAAIGAAUJKBPpAwBUAQAGAAUJKBPpAwBUAQAuAAQKfx4AAwYACAkSHGQgAD8CAAYACAkSHGQgAD8CAAQABgl6CpdDACEBAAAA.',
['莺歌']='莺歌丽斯:BAAALgADCgYJBwAAAA==.',
['萌萌']='萌萌哒球球:BAAALgADCgUJBAAAAA==.',
['萨帝']='萨帝利:BAAALgAECgUJBQAAAA==.',
['葡萄']='葡萄:BAACLgAFFH8FAAIVAAMJoQ6ONgCmAAAVAAMJoQ6ONgCmAAAuAAQKfyIAAhUACAngFSc5ACcCABUACAngFSc5ACcCAAAA.葡萄软糖:BAAALgAECgEJAQAAAA==.',
['藤原']='藤原妹紅:BAAALgADCgEJAQAAAA==.',
['虚灵']='虚灵之刃丶:BAAALgAECgMJBQAAAA==.',
['虚空']='虚空难民:BAABLgAFFH8EAAIVAAMJcyOwFwAzAQAVAAMJcyOwFwAzAQABLgAFFAQJCwASAHIiAA==.',
['蜂蜜']='蜂蜜柠檬茶:BAAALgAECgEJAQAAAA==.',
['蝶儿']='蝶儿:BAAALgAECgEJBAAAAA==.',
['血飒']='血飒长空:BAAALgADCgIJAgAAAA==.',
['装逼']='装逼的小女孩:BAAALgAECgYJCwAAAA==.',
['讨厌']='讨厌红楼梦:BAAALgADCgEJAQAAAA==.',
['诺尔']='诺尔妮:BAAALgADCgQJBQAAAA==.',
['谁是']='谁是我的眼:BAAALgAECgQJBAAAAA==.',
['谛丶']='谛丶格拉墨:BAAALgAFFAIJAwABLgAFFAIJBQACAKkaAA==.',
['豌豆']='豌豆芽:BAAALgAECgYJCwABLgAECgkJDwABAAAAAA==.',
['贝希']='贝希摩斯:BAAALgAECgEJAQAAAA==.',
['贡丸']='贡丸:BAAALgADCgYJBgAAAA==.',
['贰零']='贰零伍陆:BAAALgAECgMJBAAAAA==.',
['贾大']='贾大猛丶怒风:BAACLgAFFH8MAAIUAAQJNgwIFQAqAQAUAAQJNgwIFQAqAQAuAAQKfxgABBQACAnGEgZQALYBABQABwmOFAZQALYBACAAAQn2B5l0ADAAABwAAQkVCDksADAAAAAA.',
['超甜']='超甜火鸡面:BAABLgAFFH8FAAIVAAMJJgKuKQDMAAAVAAMJJgKuKQDMAAAAAA==.',
['路过']='路过天堂的风:BAAALgAFFAEJAgAAAA==.',
['轻歌']='轻歌月神:BAAALgAECggJCgAAAA==.',
['轻程']='轻程:BAAALgAECgUJBQAAAA==.',
['远航']='远航星:BAACLgAFFH8OAAMLAAQJbxR2AgBbAQALAAQJbxR2AgBbAQAYAAEJ+QMfDQBLAAAuAAQKfx4AAxgACAlSG+UMANEBAAsACAmjFZokADICABgABgmPGuUMANEBAAAA.',
['退后']='退后:BAAALgADCgcJCAAAAA==.',
['逍遥']='逍遥江湖:BAAALgAECgMJAwAAAA==.',
['释情']='释情:BAAALgAECgMJAwAAAA==.',
['铁北']='铁北十三太保:BAAALgAECgYJDwAAAA==.',
['阿卡']='阿卡回归了:BAAALgAECgEJAQAAAA==.',
['陈的']='陈的陈的陈:BAAALgAECgYJBgAAAA==.',
['陌上']='陌上桑丶:BAAALgAECgMJAwAAAA==.',
['雨落']='雨落竹林:BAAALgAECgEJAQAAAA==.',
['雪域']='雪域晴空:BAAALgAECgkJDwAAAA==.',
['雪残']='雪残梅:BAAALgAECgYJBgAAAA==.',
['雷霆']='雷霆噶巴:BAAALgADCgUJBQAAAA==.',
['霏奥']='霏奥娜:BAAALgAECgYJCAAAAA==.',
['霜之']='霜之哀伤:BAABLgAFFH8GAAMTAAUJ8AbOHgAiAQATAAQJ8AbOHgAiAQACAAEJAADbEwBUAAAAAA==.',
['音羽']='音羽雷恩丶:BAAALgAECgcJDgAAAA==.',
['须弥']='须弥:BAACLgAFFH8HAAIEAAMJNgw2BgDyAAAEAAMJNgw2BgDyAAAuAAQKfxUAAgQABwlNG7kgAPcBAAQABwlNG7kgAPcBAAAA.',
['風丶']='風丶:BAACLgAFFH8JAAITAAQJLSDMDABwAQATAAQJLSDMDABwAQAuAAQKfxQAAhMABwleI+80AGMCABMABwleI+80AGMCAAAA.',
['风霜']='风霜水月:BAAALgADCgEJAQAAAA==.风霜花月:BAAALgAECgQJBAAAAA==.风霜雪月:BAAALgAECgYJCQAAAA==.',
['飞丶']='飞丶杨:BAAALgADCgIJAgAAAA==.',
['飞翔']='飞翔的蜘蛛:BAAALgAECgcJBAAAAA==.',
['飞雪']='飞雪行者:BAAALgAECgYJBwAAAA==.',
['首席']='首席牛马官:BAAALgADCgMJAwAAAA==.',
['香软']='香软小蛋糕:BAAALgAECgkJDQAAAA==.',
['馨雨']='馨雨蝶:BAAALgAECgEJAgAAAA==.',
['骄纵']='骄纵轻狂:BAAALgAECgEJAQAAAA==.',
['高繑']='高繑圣子:BAAALgADCgIJAgAAAA==.',
['鬽魅']='鬽魅魍魉:BAAALgAFFAIJBAAAAA==.',
['魇梦']='魇梦隳光:BAAALgAECggJBgAAAA==.',
['鱼果']='鱼果果:BAAALgAECgIJAgAAAA==.',
['黄焖']='黄焖鸡米花:BAAALgAFFAEJAQAAAA==.',
['黑客']='黑客:BAABLgAFFH8JAAIhAAMJLSOIBAAaAQAhAAMJLSOIBAAaAQABLgAFFAQJDwAHAIEmAA==.',
['黑银']='黑银之手:BAAALgAECgcJCAAAAA==.',
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
