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

local lookup = {'DeathKnight-Unholy','Mage-Frost','DeathKnight-Blood','Priest-Holy','Paladin-Retribution','Paladin-Holy','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Protection','Warrior-Arms','Monk-Brewmaster','Monk-Windwalker','Priest-Discipline','Unknown-Unknown','Priest-Shadow','Warlock-Destruction','Warlock-Demonology',}
local provider = {region='CN',realm='织亡者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Aris:BAAALgAECgcJDQAAAA==.',
Di='Dier:BAAALgADCgcJBwAAAA==.',
Dk='Dkill:BAACLgAFFH8QAAIBAAUJkSLFAgDgAQABAAUJkSLFAgDgAQAuAAQKfxkAAgEABwn/JAkeAMwCAAEABwn/JAkeAMwCAAAA.',
El='Elitaeca:BAAALgADCgYJBgAAAA==.',
Ke='Keen:BAAALgAECgYJBgAAAA==.',
Lu='Luckyxing:BAAALgAECgUJBQAAAA==.',
My='Myclown:BAAALgADCgEJAQAAAA==.',
Nu='Nut:BAAALgAFFAEJAQAAAA==.',
Vi='Vitaminb:BAAALgAECgQJAgAAAA==.',
['不可']='不可爱:BAAALgAECgcJEgAAAA==.',
['不要']='不要骂了:BAAALgAFFAQJBAAAAA==.',
['东方']='东方白:BAAALgADCgUJBQAAAA==.',
['丫米']='丫米丫米:BAAALgAFFAQJBAAAAA==.',
['丰氚']='丰氚箱子:BAAALgAECgEJAQAAAA==.',
['丿丶']='丿丶刂:BAACLgAFFH8HAAICAAQJmgvhHgBOAQACAAQJmgvhHgBOAQAuAAQKfyIAAgIACAk/GmFEAGsCAAIACAk/GmFEAGsCAAAA.',
['二婚']='二婚更懂爱情:BAAALgAFFAIJAgAAAA==.',
['云笈']='云笈:BAAALgAFFAEJAgAAAA==.',
['亚米']='亚米亚米:BAAALgAFFAQJBAABLgAFFAgJBgADAH8VAA==.',
['亲丫']='亲丫:BAAALgAECgQJAwAAAA==.',
['亲吖']='亲吖:BAAALgAECgUJAwAAAA==.',
['佚丶']='佚丶名:BAAALgADCgQJBAAAAA==.',
['佚名']='佚名伊:BAAALgADCgMJAwAAAA==.佚名翼:BAAALgAECgUJBQAAAA==.佚名逸:BAAALgAECgEJAQAAAA==.',
['光芒']='光芒萬丈:BAAALgAECgEJAgAAAA==.',
['兲堂']='兲堂向左丶:BAABLgAFFH8IAAIEAAQJLAxLBAD1AAAEAAQJLAxLBAD1AAAAAA==.',
['凛冬']='凛冬孤影:BAAALgAECgQJAwAAAA==.',
['凯特']='凯特琳丶黯月:BAAALgADCgUJBQAAAA==.',
['刃物']='刃物息无声:BAAALgAECgQJBgAAAA==.',
['别碰']='别碰大波浪:BAAALgAECgcJDAAAAA==.',
['力冠']='力冠三军:BAAALgADCgUJBQAAAA==.',
['十二']='十二月的猫猫:BAAALgAFFAEJAQAAAA==.',
['升空']='升空:BAAALgAECgMJAwAAAA==.',
['吖咪']='吖咪吖咪:BAAALgAECgcJBwAAAA==.',
['嗷呜']='嗷呜嗷呜嗷呜:BAAALgAFFAQJBAAAAA==.',
['嘟蕾']='嘟蕾丝:BAAALgADCgkJCgAAAA==.',
['嘿白']='嘿白:BAAALgADCggJDQAAAA==.',
['囧囧']='囧囧滴潴潴:BAABLgAECn8aAAMFAAgJiwqhsQAhAQAFAAYJNQuhsQAhAQAGAAUJ/QX2ZADoAAAAAA==.',
['圣光']='圣光精灵:BAAALgAECgYJEgAAAA==.',
['坤哥']='坤哥:BAAALgAECgQJBQAAAA==.',
['大白']='大白菜:BAAALgADCgYJBgAAAA==.',
['小侍']='小侍女桑桑:BAAALgAECgYJBgAAAA==.',
['小白']='小白丶:BAAALgAECgQJBAAAAA==.',
['小黄']='小黄兔:BAAALgAECgEJAQAAAA==.',
['巴洛']='巴洛斯:BAAALgAECgQJBAAAAA==.',
['床前']='床前眀月光:BAAALgAECgMJAgAAAA==.',
['当归']='当归不归:BAAALgAECgcJDwAAAA==.',
['往佑']='往佑走打怪兽:BAABLgAECn8aAAIBAAgJ1hBIWgDjAQABAAgJ1hBIWgDjAQAAAA==.',
['怵歪']='怵歪:BAAALgAECgcJCgAAAA==.',
['我是']='我是打饭的:BAAALgAECgYJCwAAAA==.',
['戒律']='戒律牧:BAAALgADCgEJAQAAAA==.',
['托兰']='托兰斯提安:BAAALgAFFAEJAQAAAA==.',
['拉普']='拉普兰德:BAAALgADCgMJAwAAAA==.',
['搞不']='搞不懂吧:BAAALgAECgcJCAAAAA==.',
['暗夜']='暗夜之麟:BAAALgADCgcJBwAAAA==.',
['暗影']='暗影黎明:BAABLgAECn8YAAMHAAgJNx1xDQDEAgAHAAgJNx1xDQDEAgAIAAQJFhZ4DwAaAQAAAA==.',
['最后']='最后的剧情:BAAALgAECgEJAQAAAA==.',
['月如']='月如歌:BAAALgAECgEJAQAAAA==.',
['月色']='月色难逃:BAAALgAECgEJAQAAAA==.',
['木子']='木子:BAAALgAECgQJBQAAAA==.',
['村里']='村里最靓:BAAALgAECgEJAwAAAA==.',
['枫叶']='枫叶:BAAALgADCgcJBwAAAA==.',
['某厶']='某厶某:BAAALgAECgEJAQAAAA==.',
['橘色']='橘色的猫:BAACLgAFFH8HAAMJAAQJQxHXCABGAQAJAAQJQxHXCABGAQAKAAEJsgHTGwBHAAAuAAQKfxsAAwoACAknFawhAO8BAAoACAknFawhAO8BAAkAAQl9G1y5AFMAAAAA.',
['水木']='水木微:BAAALgADCgEJAQAAAA==.',
['法誓']='法誓:BAABLgAFFH8FAAICAAIJVgQxKACXAAACAAIJVgQxKACXAAAAAA==.',
['泪泪']='泪泪酱:BAAALgAFFAEJAwAAAA==.',
['洣蕗']='洣蕗哋杺:BAAALgAECgEJAwAAAA==.',
['游荡']='游荡者小姨妹:BAAALgADCgYJBgAAAA==.',
['滴滴']='滴滴打人:BAAALgAFFAEJAQAAAA==.',
['火灬']='火灬雨:BAAALgAFFAIJAgAAAA==.',
['灬血']='灬血魔织影灬:BAAALgAECgMJAwAAAA==.',
['熊猫']='熊猫毛:BAAALgAECgIJAgAAAA==.',
['牛奶']='牛奶抽筋:BAAALgAECgYJBwAAAA==.',
['狗狗']='狗狗三号:BAAALgAFFAQJBAAAAA==.狗狗二号:BAAALgAECgYJBgAAAA==.',
['王灵']='王灵官:BAAALgAECgQJBgAAAA==.',
['痞子']='痞子锋:BAABLgAFFH8GAAIJAAIJLwYiEgB7AAAJAAIJLwYiEgB7AAAAAA==.',
['白日']='白日丶依山盡:BAAALgAECgMJBAAAAA==.',
['白菜']='白菜的驯兽思:BAABLgAECn8ZAAMLAAgJLhOuPwCwAQALAAcJBRWuPwCwAQAMAAYJsQgRUgAEAQAAAA==.',
['盾白']='盾白菜:BAABLgAECn8YAAMNAAgJxhHcFAC/AQANAAgJxhHcFAC/AQAOAAMJ2wlxKwCZAAAAAA==.',
['看又']='看又是飞碟:BAAALgAECgEJAQAAAA==.',
['真谛']='真谛:BAACLgAFFH8GAAIPAAIJrxhpGQCgAAAPAAIJrxhpGQCgAAAuAAQKfxwAAw8ABwm2Gp8jAOUBAA8ABwklGp8jAOUBABAABgmcEZkuAHABAAAA.',
['瞳孔']='瞳孔地震:BAAALgAECgQJBAAAAA==.',
['第九']='第九:BAAALgAECgEJAQAAAA==.',
['筱天']='筱天丶:BAAALgAECgUJBQAAAA==.',
['糖果']='糖果屋的幽灵:BAABLgAFFH8HAAIEAAIJoRPXDACXAAAEAAIJoRPXDACXAAABLgAFFAQJCAARALkfAA==.',
['索灬']='索灬隆:BAAALgAECgMJAQABLgAFFAIJAgASAAAAAA==.',
['紫花']='紫花凉生:BAAALgAECgQJBAAAAA==.',
['给你']='给你一瓶可乐:BAAALgAFFAIJAwABLgAFFAcJEgARAEEVAA==.给你一瓶芬达:BAAALgAECgcJCgAAAA==.给你一瓶零度:BAAALgAECgIJAwAAAA==.',
['美国']='美国电信公司:BAAALgADCgYJBgAAAA==.',
['美女']='美女疯子澄澄:BAAALgAFFAEJAQAAAA==.',
['老吴']='老吴之家:BAAALgADCgIJAwAAAA==.',
['胖胖']='胖胖小盼:BAAALgAECgEJAQAAAA==.',
['芽咪']='芽咪芽咪:BAAALgAFFAMJBAAAAA==.',
['芽米']='芽米芽米:BAAALgAFFAQJBAAAAA==.',
['药渣']='药渣儿:BAAALgADCgEJAQAAAA==.',
['西瓜']='西瓜子:BAACLgAFFH8IAAMEAAMJAhImDACgAAARAAMJoQQaEADLAAAEAAIJ0BgmDACgAAAuAAQKfyoABBEACAmrFkEcALMBABEACAkOEUEcALMBAAQACAnAEWstAJABABMABAmJCwpDAOIAAAAA.',
['达闻']='达闻稀:BAAALgAECgEJAQAAAA==.',
['里洱']='里洱:BAAALgAECgUJBwAAAA==.',
['错过']='错过的大雨:BAAALgADCgQJBAAAAA==.',
['长崎']='长崎丶爽世:BAABLgAFFH8JAAIUAAUJUAS5AwBcAQAUAAUJUAS5AwBcAQAAAA==.',
['阿达']='阿达尔之手:BAAALgADCgYJCAAAAA==.',
['隐忍']='隐忍低调杀戮:BAAALgAECgEJAQAAAA==.',
['雅耍']='雅耍迈:BAAALgAECgQJBAAAAA==.',
['雪晶']='雪晶灵圣骑:BAAALgAECgIJAgAAAA==.',
['雾切']='雾切响子:BAABLgAFFH8JAAIVAAUJ2Ba+CABNAQAVAAUJ2Ba+CABNAQAAAA==.',
['靓兮']='靓兮兮:BAAALgAECgEJAQAAAA==.',
['风之']='风之歩影:BAAALgAFFAEJAgAAAA==.',
['风继']='风继续吹:BAAALgAECgEJAQAAAA==.',
['饭饭']='饭饭猫:BAAALgAFFAEJAQAAAA==.',
['魑魅']='魑魅波:BAAALgAFFAQJBAAAAA==.',
['鸭米']='鸭米鸭米:BAAALgAFFAMJAwAAAA==.',
['黑色']='黑色的猫:BAABLgAECn8XAAMTAAkJ5g/bMwBJAQATAAcJ4wvbMwBJAQAEAAQJigFjaQCHAAAAAA==.',
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
