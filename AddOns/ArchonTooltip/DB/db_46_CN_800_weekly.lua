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

local lookup = {'DeathKnight-Unholy','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','DemonHunter-Devourer','Druid-Balance','Priest-Discipline','Monk-Brewmaster','Unknown-Unknown','Warlock-Demonology','Monk-Mistweaver','Warlock-Destruction','Warrior-Fury','Warrior-Protection','Priest-Holy',}
local provider = {region='CN',realm='艾维娜',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akari:BAAALgAECgYJEQAAAA==.',
Ca='Carrot:BAAALgAECgEJAQAAAA==.',
Dk='Dkfive:BAABLgAFFH8IAAIBAAQJNRnpFABPAQABAAQJNRnpFABPAQAAAA==.',
Fe='Feather:BAAALgAECgYJBgAAAA==.',
Fl='Flyfreedom:BAAALgADCgEJAQAAAA==.',
Ik='Ikelefe:BAAALgADCgEJAQAAAA==.',
Je='Jeanned:BAAALgAECgEJAQAAAA==.',
Ji='Jiaog:BAAALgAECgEJAQAAAA==.',
Lo='Lonlytraamps:BAAALgAECgYJBwAAAA==.',
Mo='Moi:BAAALgADCgYJBgAAAA==.',
No='Noex:BAAALgAECgQJBQAAAA==.',
Ph='Phr:BAAALgAECgEJAQAAAA==.',
Pi='Piosity:BAAALgAECgYJBwAAAA==.',
Ra='Rainbow:BAAALgAECgkJCQAAAA==.Raingra:BAAALgAECgYJBgAAAA==.',
Yi='Yinpala:BAAALgAECgcJBwAAAA==.Yiny:BAAALgAECgYJBgAAAA==.Yinzei:BAAALgAECgkJCQAAAA==.',
['一盏']='一盏相思:BAAALgAECgYJCgAAAA==.',
['丶浮']='丶浮生若梦:BAAALgAECgQJBwAAAA==.',
['二零']='二零二二世界:BAAALgAECgQJBQAAAA==.',
['云鬼']='云鬼心:BAAALgAECgYJBgAAAA==.',
['今汐']='今汐:BAACLgAFFH8RAAMCAAMJ3BIQDgD3AAACAAMJ3BIQDgD3AAADAAMJywM5DQDIAAAuAAQKfxgABAIACAkpF0sPAEQCAAIACAkpF0sPAEQCAAQAAglUGCIyAIUAAAMAAQnpGqlcAEgAAAAA.',
['伊默']='伊默:BAAALgAECgQJBAAAAA==.',
['你的']='你的样子:BAAALgADCgEJAQAAAA==.',
['倪佳']='倪佳马的王易:BAAALgAECgUJBQAAAA==.',
['傷心']='傷心丶:BAAALgAECgEJAwAAAA==.',
['八萬']='八萬:BAAALgAECgUJCgAAAA==.',
['冬日']='冬日可爱:BAAALgAECgYJDgAAAA==.',
['凛冬']='凛冬:BAAALgAECgUJCAAAAA==.',
['北沐']='北沐辰枫:BAAALgAECgYJCwAAAA==.',
['半盏']='半盏流年:BAAALgADCgIJAgAAAA==.',
['可爱']='可爱猫咪:BAAALgAFFAIJAgAAAA==.',
['叶律']='叶律云:BAABLgAFFH8GAAMFAAIJMBd5IQBdAAAFAAEJxR55IQBdAAAGAAEJnA+NCgBVAAAAAA==.',
['呼啦']='呼啦啦:BAAALgAECgEJAwAAAA==.',
['咕叽']='咕叽姜茶:BAAALgAECgUJCQAAAA==.',
['咕苏']='咕苏城外:BAAALgAECgIJAgAAAA==.',
['唐朝']='唐朝祭司:BAABLgAECn8aAAIHAAgJHRbgIwAIAgAHAAgJHRbgIwAIAgAAAA==.',
['回忆']='回忆真苦:BAAALgAECgQJBAAAAA==.',
['夢醒']='夢醒時芬:BAAALgAECgYJDwAAAA==.',
['天才']='天才靓仔萧萧:BAAALgAECgcJCgAAAA==.',
['安娜']='安娜斯塔希尔:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞妖娆:BAAALgAECgMJAgAAAA==.寂寞桃子:BAAALgAECgYJBgAAAA==.',
['小糸']='小糸侑:BAAALgAECgEJAQAAAA==.',
['尾随']='尾随伏击骑:BAAALgADCgUJBwAAAA==.',
['希欧']='希欧蕊:BAABLgAECn8ZAAIIAAgJQQurWwCOAQAIAAgJQQurWwCOAQAAAA==.',
['帘卷']='帘卷西风:BAAALgAECgIJAgAAAA==.',
['拉斐']='拉斐尔馨:BAAALgAECgYJEAAAAA==.',
['斯坦']='斯坦丁:BAAALgAECgIJAgAAAA==.',
['日邢']='日邢一善:BAAALgADCgUJBQAAAA==.',
['暗夜']='暗夜大婶:BAAALgAECgMJBgAAAA==.',
['月冷']='月冷风清:BAAALgADCgcJBwAAAA==.',
['月色']='月色蒲公英:BAAALgAECgYJBgAAAA==.',
['月落']='月落醉红尘:BAAALgAECgEJAQAAAA==.',
['朴姐']='朴姐姐:BAAALgADCgIJAgAAAA==.',
['格子']='格子:BAAALgAECgQJBAAAAA==.',
['梦境']='梦境逐星:BAAALgAECgkJDgABLgAFFAUJCwAJAAgHAA==.',
['梦醒']='梦醒花犹存:BAAALgADCgEJAQAAAA==.',
['死亡']='死亡小小酥:BAAALgAECgEJAQAAAA==.',
['毛胖']='毛胖球:BAAALgAFFAQJBAABLgAFFAUJKgAKAP8kAA==.',
['泥啦']='泥啦塞克:BAAALgADCgUJBQAAAA==.',
['泵接']='泵接断连:BAACLgAFFH8NAAILAAQJ1htsBgBtAQALAAQJ1htsBgBtAQAuAAQKfykAAgsACAkeIG8KAOICAAsACAkeIG8KAOICAAEuAAQKAQkBAAwAAAAA.',
['流年']='流年:BAAALgADCgIJAgAAAA==.',
['满天']='满天星斗:BAAALgAECgYJBgAAAA==.',
['点一']='点一下门:BAAALgAECgEJAQAAAA==.',
['烙印']='烙印:BAAALgADCgEJAQAAAA==.',
['燃风']='燃风之烬:BAABLgAECn8UAAINAAkJOB9uCAA+AwANAAkJOB9uCAA+AwAAAA==.',
['爆炸']='爆炸的圣光:BAAALgAECgYJBgAAAA==.',
['狼奔']='狼奔豕突:BAAALgADCgEJAQAAAA==.',
['珂朵']='珂朵莉:BAAALgAECgYJBgAAAA==.',
['禾木']='禾木:BAAALgAECgYJBwAAAA==.',
['秀宝']='秀宝:BAAALgAECgIJAwAAAA==.',
['窗外']='窗外的梦:BAACLgAFFH8GAAIOAAIJZiMtDQDRAAAOAAIJZiMtDQDRAAAuAAQKfxcAAg4ACAlAJMMEAB0DAA4ACAlAJMMEAB0DAAAA.',
['笑看']='笑看人生麒麟:BAAALgAECgYJBQAAAA==.',
['管仲']='管仲:BAAALgAECgMJBgAAAA==.',
['精灵']='精灵一族:BAAALgAECgIJAgAAAA==.',
['紫蘇']='紫蘇:BAAALgAECgEJAQAAAA==.',
['缥缈']='缥缈随风:BAAALgAECgYJCwAAAA==.',
['耀光']='耀光改二甲:BAACLgAFFH8KAAICAAQJSCDXBACrAQACAAQJSCDXBACrAQAuAAQKfyAAAwIACAkQIdUEAAEDAAIACAkQIdUEAAEDAAMABQkoHDMjAKQBAAAA.',
['舞天']='舞天飞琉:BAAALgADCgEJAQAAAA==.',
['艾尔']='艾尔琳:BAAALgAECgcJEwAAAA==.',
['花开']='花开未落:BAAALgAECgMJAwAAAA==.',
['花盾']='花盾:BAAALgAFFAIJAgAAAA==.',
['苏阙']='苏阙:BAAALgAECgIJAgAAAA==.',
['茹炏']='茹炏:BAAALgAECgYJDQAAAA==.',
['莓莓']='莓莓奶昔:BAAALgADCgMJAwAAAA==.',
['萨哈']='萨哈琳:BAAALgAFFAEJAQAAAA==.',
['虾仁']='虾仁土豆泥:BAAALgAECgkJCAABLgAFFAYJDQAPAOgiAA==.',
['裳月']='裳月:BAAALgAFFAIJAgAAAA==.',
['还是']='还是坏蛋:BAABLgAECn8UAAMQAAYJvxFkGQD0AAAQAAUJwg5kGQD0AAARAAUJ4Q2UKwDkAAABLgAFFAIJBgAFADAXAA==.',
['阿德']='阿德拉:BAAALgAECgQJBAAAAA==.',
['雪丶']='雪丶糕:BAAALgAECgQJBwAAAA==.',
['靓得']='靓得拖网速:BAABLgAFFH8GAAMKAAMJKwRaCQDOAAAKAAMJKwRaCQDOAAASAAIJaAIhEAB6AAAAAA==.',
['飘渺']='飘渺沉沦:BAAALgAECgMJAgAAAA==.',
['飞扬']='飞扬的元素:BAAALgAECggJEgAAAA==.',
['马蹄']='马蹄儿哒哒:BAAALgAECgYJCgAAAA==.',
['鱼儿']='鱼儿飞飞:BAAALgAECgMJAwAAAA==.',
['鱼塘']='鱼塘主波塞冬:BAAALgAECgMJAwAAAA==.',
['龙虾']='龙虾刺身:BAAALgAECgYJDAAAAA==.',
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
