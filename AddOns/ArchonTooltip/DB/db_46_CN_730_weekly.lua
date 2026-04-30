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

local lookup = {'Unknown-Unknown','Warlock-Demonology','Shaman-Elemental','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Restoration','Priest-Holy','Priest-Discipline','Priest-Shadow','Paladin-Protection','Rogue-Outlaw','Rogue-Subtlety','Warrior-Arms','Mage-Frost','Hunter-BeastMastery','Warrior-Protection','Paladin-Holy','DemonHunter-Devourer','Paladin-Retribution','Druid-Balance','Druid-Feral','Warlock-Destruction','Warlock-Affliction','DemonHunter-Vengeance','DemonHunter-Havoc','Hunter-Marksmanship','Monk-Brewmaster',}
local provider = {region='CN',realm='洛肯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Aloha:BAAALgAFFAIJAgAAAA==.',
An='Aniya:BAAALgADCgEJAQAAAA==.',
Ar='Araraki:BAAALgAECgEJAwABLgAECgYJCgABAAAAAA==.Ariescarlet:BAAALgAECgQJBAAAAA==.Ariesmoon:BAAALgAECgYJBwAAAA==.',
Ba='Baakuu:BAAALgAECgMJAwABLgAECgYJCgABAAAAAA==.Baby:BAAALgAECgYJBgAAAA==.Baiwuchang:BAECLgAFFH8FAAICAAIJaSEeKwDEAAACAAIJaSEeKwDEAAAuAAQKfxcAAgIACAn6JOcIADkDAAIACAn6JOcIADkDAAAA.',
Df='Dfdk:BAAALgAECgcJBwAAAA==.',
Ev='Evagreen:BAAALgADCgMJAwAAAA==.',
Fe='Fenlun:BAAALgAECgYJCwAAAA==.',
Fr='Francis:BAAALgADCgUJAgAAAA==.',
Gl='Glockieyan:BAAALgADCgcJBwAAAA==.',
Gr='Greattoast:BAABLgAFFH8HAAIDAAMJvAa6GQCIAAADAAMJvAa6GQCIAAAAAA==.Greatwind:BAAALgAECgUJBQAAAA==.',
He='Henry:BAAALgADCgUJBQAAAA==.',
Jl='Jlwxdlq:BAABLgAFFH8FAAIEAAQJaRPZCQA6AQAEAAQJaRPZCQA6AQAAAA==.',
Kt='Ktfuyudsb:BAAALgADCgMJAwAAAA==.',
Ku='Kuso:BAAALgAECgEJAQAAAA==.',
Li='Linkdon:BAAALgADCgUJBQAAAA==.Linxue:BAAALgAECgQJBwAAAA==.',
Lo='Lorethar:BAAALgADCgcJBwAAAA==.',
Lu='Luanwu:BAAALgAECgYJCAAAAA==.',
Ly='Lynn:BAAALgADCgcJBwAAAA==.',
Me='Mebeast:BAAALgAECgYJBgAAAA==.',
Ne='Neronaldo:BAAALgAECgcJDQAAAA==.Neronaldodr:BAAALgADCgcJDQAAAA==.Neverxbreath:BAAALgAECgYJBwAAAA==.',
Ni='Nightballad:BAAALgADCgUJBQAAAA==.Nighthymn:BAAALgADCgEJAQAAAA==.Nightmelody:BAAALgAECgUJCQAAAA==.Niuberber:BAAALgAFFAEJAQAAAA==.',
Nz='Nzoth:BAABLgAFFH8UAAMFAAUJRyIEAgCSAQAFAAQJRyIEAgCSAQAGAAEJAABTFABPAAAAAA==.',
Pa='Paladinarthu:BAAALgAECgMJAwAAAA==.',
Pl='Playerzusswd:BAAALgADCgEJAQAAAA==.',
Pr='Prettyloli:BAACLgAFFH8KAAIHAAQJABpkAwBIAQAHAAQJ/xlkAwBIAQAuAAQKfx0AAwMACAmyGM4XAFgCAAMACAmyGM4XAFgCAAcABwnFGWgpAOkBAAAA.',
Sd='Sdahgdf:BAAALgADCgIJAgAAAA==.',
Sh='Shees:BAAALgAFFAEJAQAAAA==.Sheespray:BAABLgAFFH8HAAQIAAQJbA2sCwCoAAAJAAMJfghGDwDaAAAIAAIJuBKsCwCoAAAKAAEJ1gHgFQBLAAAAAA==.Sheesse:BAAALgAFFAEJAwAAAA==.',
St='Stanomo:BAAALgAFFAMJBAAAAA==.Stanouo:BAABLgAFFH8KAAILAAQJkiZHAADPAQALAAQJkiZHAADPAQAAAA==.Stanowo:BAAALgAECgEJAgAAAA==.',
Sy='Syddretha:BAAALgAECgkJBgAAAA==.',
Ti='Tita:BAAALgADCgQJBAAAAA==.',
Tt='Ttstone:BAAALgAECgYJBgAAAA==.',
Tu='Tuleyon:BAAALgAFFAMJAwAAAA==.',
Wa='Wakoa:BAAALgADCgYJBgAAAA==.Wasdied:BAAALgAFFAIJAwAAAA==.',
Ym='Ymdh:BAAALgAECgMJAwAAAA==.',
Yn='Ynlaoda:BAAALgADCgcJDQAAAA==.Ynwer:BAAALgADCgEJAQAAAA==.',
Yo='Yosemite:BAAALgAECgEJAQAAAA==.',
Yr='Yr:BAACLgAFFH8IAAMMAAQJNRaNAABmAQAMAAQJqBSNAABmAQANAAIJ6QvQFQCfAAAuAAQKfxcAAw0ABglLIq0dABECAA0ABglrIa0dABECAAwABgm5IFkFAJABAAAA.',
Yu='Yunlmj:BAAALgADCgUJBQAAAA==.',
Zi='Zipper:BAAALgAECgQJBAAAAA==.',
['一匹']='一匹大英短:BAAALgAECgUJCAAAAA==.',
['一棒']='一棒子奶满:BAAALgAECgIJAgAAAA==.',
['一起']='一起蛤啤:BAAALgAECgYJBgAAAA==.',
['丁汀']='丁汀叮:BAAALgADCgMJAwAAAA==.',
['七海']='七海千秋:BAAALgAECgEJAgABLgAECgkJCgABAAAAAA==.',
['三千']='三千院峰:BAAALgADCgIJAgAAAA==.',
['三派']='三派丶:BAAALgAECgYJBgAAAA==.',
['上官']='上官三月:BAAALgAECgQJBwAAAA==.',
['两禅']='两禅寺李当心:BAAALgAECgYJDAAAAA==.',
['丨听']='丨听雨丶:BAAALgAECggJDQAAAA==.',
['丨子']='丨子木丨:BAAALgAECgcJBwAAAA==.',
['丨常']='丨常威丨:BAAALgAECgYJBgAAAA==.',
['丨怒']='丨怒灬风:BAAALgAECgEJAgAAAA==.',
['丨栀']='丨栀沫丨:BAAALgAECgcJBwAAAA==.',
['丨萌']='丨萌大丨:BAAALgAECgkJCAAAAA==.',
['丶七']='丶七曜:BAAALgAECgIJAgAAAA==.',
['丶小']='丶小李胖了吗:BAAALgAECgEJAQAAAA==.',
['丷呤']='丷呤舟忆梦:BAAALgAECgYJCgAAAA==.',
['丷酒']='丷酒酿园叽丷:BAAALgAECgQJBAAAAA==.',
['丹羽']='丹羽长秀:BAAALgAECgUJBQAAAA==.',
['之乎']='之乎者也:BAAALgADCgMJAwAAAA==.',
['乐百']='乐百花:BAACLgAFFH8FAAIHAAMJWRX6DQD8AAAHAAMJWRX6DQD8AAAuAAQKfxkAAgcABglrIzYZAE0CAAcABglrIzYZAE0CAAAA.',
['九凌']='九凌妖气:BAAALgAECgMJAwAAAA==.',
['书香']='书香砚池:BAAALgAECgEJAQABLgAECgcJHgAFAI4bAA==.',
['二三']='二三三神圣:BAAALgAECgQJBAAAAA==.',
['云中']='云中有鹤丶:BAAALgAECgYJCAAAAA==.',
['五二']='五二三八:BAAALgADCgEJAQAAAA==.',
['交还']='交还魂:BAAALgAECgYJDAAAAA==.',
['他在']='他在耍你啊:BAAALgAECgQJBAAAAA==.',
['伊達']='伊達尤狄:BAAALgAECgEJAgAAAA==.',
['你喜']='你喜欢的西瓜:BAAALgAECgEJAQAAAA==.',
['你的']='你的小兄弟:BAAALgAECgEJAQAAAA==.',
['你真']='你真的我哭死:BAAALgAECgcJAQABLgAFFAUJCQAIANcWAA==.',
['依然']='依然武器:BAAALgADCgEJAQAAAA==.依然狂暴:BAAALgADCgEJAQAAAA==.依然随风:BAAALgAECgEJAQAAAA==.',
['修罗']='修罗浮屠:BAAALgAECggJEAAAAA==.',
['俺不']='俺不中咧:BAABLgAECn8eAAIFAAcJjhvrCgDRAQAFAAcJjhvrCgDRAQAAAA==.',
['偏心']='偏心柱:BAAALgAECgYJBgAAAA==.',
['克克']='克克理斯汀:BAAALgAECgMJAwAAAA==.',
['兔兔']='兔兔车夫:BAAALgAECgEJAQAAAA==.',
['关龙']='关龙冥骑:BAACLgAFFH8GAAIFAAQJahDnFgBIAQAFAAQJahDnFgBIAQAuAAQKfyIAAgUACAmpGx8pAJUCAAUACAmpGx8pAJUCAAAA.关龙猎影:BAAALgAECgQJBAAAAA==.',
['典浴']='典浴长:BAAALgAECgEJAQAAAA==.',
['兽兽']='兽兽哒哒:BAAALgAECgQJBAAAAA==.',
['兽行']='兽行哒哒:BAAALgAECgMJAwAAAA==.兽行大发兽:BAAALgADCgUJBQAAAA==.',
['内向']='内向凡人:BAAALgAFFAIJAgAAAA==.',
['再生']='再生狼:BAAALgAECgUJAwAAAA==.',
['冰火']='冰火毒龍钻:BAAALgAECgcJCwAAAA==.',
['冷冬']='冷冬无霜:BAAALgAECgYJDQAAAA==.',
['凛冬']='凛冬寒風:BAAALgAFFAIJBAAAAA==.',
['凡人']='凡人祭司:BAAALgAECgMJAwAAAA==.',
['凡尘']='凡尘灬血舞:BAAALgAECgUJBQABLgAFFAYJCgAOAH4fAA==.',
['凪光']='凪光:BAAALgADCgEJAQAAAA==.',
['凯拉']='凯拉奈特莉:BAAALgAECgEJAQAAAA==.',
['凯隐']='凯隐:BAAALgAECgQJBAAAAA==.',
['凶残']='凶残:BAAALgAECgcJBwAAAA==.',
['凸丶']='凸丶丿凸:BAAALgAECgUJCgAAAA==.',
['凸丷']='凸丷丷凸:BAAALgAECgQJBgAAAA==.',
['出去']='出去玩玩:BAAALgAECgEJAQAAAA==.',
['刘壯']='刘壯壯:BAAALgAECgYJBwAAAA==.',
['別撕']='別撕了俺脫:BAAALgADCgEJAQAAAA==.',
['别骂']='别骂了马上改:BAACLgAFFH8IAAMKAAMJRAhlDADpAAAKAAMJRAhlDADpAAAIAAIJIwhnDwCDAAAuAAQKfxwAAwoABwkQGs8gANIBAAoABwkQGs8gANIBAAgABgl2CThIABgBAAAA.',
['剃快']='剃快换嘲:BAAALgAECgYJBgAAAA==.',
['剑刃']='剑刃暴雨:BAAALgAECgEJAQABLgAECgYJDAABAAAAAA==.',
['力克']='力克巧:BAAALgAECgIJAgAAAA==.',
['加朵']='加朵堡:BAAALgAECgkJCQAAAA==.',
['勇士']='勇士:BAAALgADCgEJAgAAAA==.',
['北落']='北落丨师门:BAAALgAECgYJBwAAAA==.北落师门丨帝:BAAALgAECgIJBAAAAA==.北落师门丨德:BAAALgAECgUJBgAAAA==.北落师门丨烈:BAAALgAECgUJBgAAAA==.北落师门丨風:BAAALgADCgEJAQAAAA==.',
['南方']='南方骑士:BAAALgAECgYJDAAAAA==.',
['卿夲']='卿夲佳人:BAAALgADCgQJBAAAAA==.',
['历劫']='历劫祓恶:BAAALgAECgUJBQAAAA==.',
['原生']='原生小奶狗:BAAALgAFFAMJAwAAAA==.',
['台州']='台州味道:BAAALgAECgEJAQAAAA==.',
['司徒']='司徒扯淡:BAAALgAECgcJBgAAAA==.',
['吃个']='吃个板栗:BAAALgAECgMJAwAAAA==.',
['合成']='合成感受器:BAAALgAECgYJCgAAAA==.',
['吉你']='吉你太美:BAABLgAFFH8HAAIPAAMJ3hDEKgAKAQAPAAMJ3hDEKgAKAQAAAA==.',
['吉祥']='吉祥村伊利蛋:BAAALgADCgUJBQAAAA==.吉祥村布莱恩:BAACLgAFFH8GAAIQAAMJnxkxCAAiAQAQAAMJnxkxCAAiAQAuAAQKfxUAAhAABgkWJTYaAGoCABAABgkWJTYaAGoCAAAA.',
['君不']='君不悔:BAAALgAECgQJBQAAAA==.',
['含蓄']='含蓄又洒脱:BAAALgAECgcJBQABLgAFFAUJFAAFAEciAA==.',
['呤舟']='呤舟亿梦:BAAALgAECgEJAQAAAA==.呤舟忆梦:BAAALgAECgYJBgAAAA==.',
['咖喱']='咖喱豆豆:BAAALgAECgEJAQAAAA==.',
['唐法']='唐法:BAAALgAECgQJBQAAAA==.',
['唱唱']='唱唱反调:BAAALgAECgUJBQAAAA==.',
['啪啦']='啪啦叮叮当:BAAALgADCgMJAwAAAA==.',
['善恶']='善恶一身:BAAALgADCgMJAwAAAA==.',
['喝下']='喝下午茶的猫:BAAALgAECgQJBAAAAA==.',
['喵酱']='喵酱的薛定谔:BAAALgAECgkJBwAAAA==.',
['喵魏']='喵魏翔:BAAALgAECgIJAgAAAA==.',
['嗜龙']='嗜龙之魂:BAAALgAECgIJAgAAAA==.',
['嘉兰']='嘉兰泰诺:BAAALgAECgYJCwAAAA==.',
['嘎吱']='嘎吱:BAAALgAECgYJBgAAAA==.',
['团契']='团契:BAAALgAECgkJCQAAAA==.',
['地狱']='地狱的剑来:BAAALgAECgEJAgAAAA==.',
['坎蒂']='坎蒂:BAABLgAFFH8FAAICAAIJrBOKMgCtAAACAAIJrBOKMgCtAAAAAA==.',
['坚定']='坚定理想信念:BAAALgAECgQJAQAAAA==.',
['塔玛']='塔玛德法克:BAAALgAECgIJAgAAAA==.',
['墨均']='墨均:BAABLgAFFH8HAAMOAAIJhSVIBQDAAAAOAAIJhSVIBQDAAAARAAEJkxy/DgBWAAAAAA==.',
['大力']='大力鳄海涅:BAAALgAFFAEJAQAAAA==.',
['大德']='大德鲁二:BAAALgAECgEJAQAAAA==.',
['大毛']='大毛丶:BAAALgADCgEJAQAAAA==.',
['大汐']='大汐儿:BAAALgAECgcJBwAAAA==.',
['大跳']='大跳接冲锋:BAAALgAFFAEJAQAAAA==.',
['大饼']='大饼炸串:BAAALgAECgEJAQAAAA==.',
['奥尔']='奥尔菲斯:BAAALgADCgEJAQAAAA==.',
['奶德']='奶德灬救我:BAAALgADCgUJBAAAAA==.',
['好想']='好想吃肉:BAAALgAECgYJEAAAAA==.',
['好白']='好白好大:BAAALgADCgQJBAAAAA==.',
['好看']='好看了:BAABLgAFFH8HAAIFAAIJhR0ZFQCzAAAFAAIJhR0ZFQCzAAAAAA==.',
['好运']='好运吶犄角:BAAALgAECgkJBwABLgAFFAcJBwASADwVAA==.好运呐犄角:BAAALgAECgcJAQAAAA==.好运啊犄角:BAAALgAECgkJCQAAAA==.',
['嫒莉']='嫒莉莎:BAAALgAECgQJBAAAAA==.',
['孞刧']='孞刧:BAAALgAFFAQJBAAAAA==.',
['孤独']='孤独的小蚂蚁:BAAALgADCgUJCgAAAA==.',
['学习']='学习使我快乐:BAAALgAECgYJBwAAAA==.',
['宇浩']='宇浩:BAAALgADCgEJAQAAAA==.',
['安魂']='安魂小夜曲:BAAALgAECgcJEAAAAA==.',
['客单']='客单价:BAAALgADCggJBwAAAA==.',
['寒芒']='寒芒:BAABLgAFFH8FAAIPAAUJIgXKFQByAQAPAAUJIgXKFQByAQAAAA==.',
['射月']='射月亮的喵:BAAALgADCgUJBQAAAA==.',
['小不']='小不忍丶云云:BAABLgAFFH8GAAISAAMJ/hQIBgD3AAASAAMJ/hQIBgD3AAAAAA==.',
['小丑']='小丑的面具:BAAALgAECgQJBAAAAA==.',
['小云']='小云:BAAALgAECgcJBgAAAA==.',
['小咪']='小咪仔仔:BAAALgAECgcJBwAAAA==.',
['小妖']='小妖不上天:BAAALgAECgcJDQAAAA==.',
['小小']='小小桃子:BAAALgAECgEJAQAAAA==.小小龙猫:BAAALgAECgEJAQAAAA==.',
['小弓']='小弓:BAAALgAFFAUJBAAAAA==.',
['小懂']='小懂丶光:BAAALgADCgMJAwAAAA==.小懂丶贝:BAAALgADCgcJCQAAAA==.',
['小暖']='小暖暖:BAAALgAECgUJBQAAAA==.',
['小栗']='小栗帽:BAAALgAECgkJCgAAAA==.',
['小椛']='小椛椛:BAAALgAFFAQJBAAAAA==.',
['小秋']='小秋林格瓦斯:BAAALgADCgMJBQAAAA==.',
['小花']='小花花:BAAALgAECgQJBQAAAA==.',
['小贝']='小贝:BAAALgAECgMJBQAAAA==.',
['小酷']='小酷:BAAALgAECgYJCQAAAA==.',
['小阿']='小阿娜:BAAALgAECgkJCQAAAA==.小阿尔卑斯:BAAALgADCgEJAQAAAA==.',
['小黑']='小黑炫芭蕾:BAAALgAFFAIJAwAAAA==.',
['少先']='少先队大队长:BAAALgAFFAMJAwAAAA==.',
['少年']='少年公孙策:BAAALgAECgEJAQAAAA==.',
['少有']='少有为:BAAALgAECgcJBwAAAA==.',
['尛犇']='尛犇孨丶:BAAALgAECgQJAwAAAA==.',
['尤物']='尤物辣一辣:BAAALgADCgIJAgAAAA==.',
['就是']='就是吃肉:BAAALgAECgQJBAAAAA==.就是哎汽水:BAAALgAECgYJDAAAAA==.',
['尼丶']='尼丶姑:BAAALgAECgYJBgAAAA==.',
['尼古']='尼古拉斯死骑:BAAALgADCgIJAgAAAA==.',
['屯子']='屯子里的兽医:BAAALgAECgEJAQAAAA==.',
['岐岐']='岐岐游囍:BAAALgADCgIJAgAAAA==.',
['岚星']='岚星缟辰:BAAALgAECgYJDAAAAA==.',
['左左']='左左丶:BAAALgAECgcJBwAAAA==.',
['左手']='左手:BAAALgAECgcJBwAAAA==.',
['巫术']='巫术学徒:BAAALgAFFAIJBAAAAA==.',
['希尔']='希尔:BAAALgADCgEJAQAAAA==.',
['帕拉']='帕拉丁丶:BAAALgAFFAEJAgAAAA==.',
['幻冥']='幻冥妖:BAAALgAECgYJCgAAAA==.',
['强的']='强的一笔:BAAALgAFFAEJAQAAAA==.',
['往后']='往后如是:BAAALgAFFAMJAwABLgAFFAgJGgAPAHwmAA==.',
['很大']='很大请忍下:BAAALgAECgYJDAAAAA==.',
['心灵']='心灵震撼丶:BAABLgAECn8gAAITAAgJjBx3LABMAgATAAgJjBx3LABMAgAAAA==.',
['必贵']='必贵园上将:BAAALgAFFAIJAwAAAA==.',
['快变']='快变鸟嘲讽:BAAALgAECgMJAwAAAA==.',
['快战']='快战复我:BAAALgAECgcJCAAAAA==.',
['快换']='快换嘲:BAAALgAECgkJCQAAAA==.',
['念念']='念念:BAAALgAFFAEJAQAAAA==.念念很想恋:BAAALgAECgUJBQAAAA==.',
['恶魔']='恶魔的掌握:BAAALgAECgYJDwAAAA==.',
['感觉']='感觉有点火热:BAAALgADCgUJBQAAAA==.',
['愤怒']='愤怒的猫:BAAALgAECgYJDwAAAA==.',
['我不']='我不是咕咕:BAAALgAECgEJAQAAAA==.',
['我们']='我们是德鲁:BAAALgAECgcJCwAAAA==.',
['我会']='我会给灌注:BAAALgAECgkJEAABLgAFFAYJCgAHAHYKAA==.',
['我怕']='我怕疼啊:BAAALgAECgYJCgABLgAFFAUJDAAFAPwjAA==.',
['我没']='我没有猫:BAAALgAECgMJAwAAAA==.',
['我要']='我要发期刊:BAAALgAFFAEJAQAAAA==.',
['戴投']='戴投代鸽:BAAALgAFFAEJAQABLgAFFAcJBAABAAAAAA==.',
['托马']='托马斯:BAAALgAECgEJAQAAAA==.',
['扛不']='扛不住奶不起:BAEBLgAFFH8IAAIUAAMJmBzyEAAeAQAUAAMJmBzyEAAeAQAAAA==.',
['执著']='执著:BAAALgAECgMJAwAAAA==.',
['把奶']='把奶踢了我来:BAAALgADCgUJBQAAAA==.',
['抓所']='抓所有宝宝:BAAALgAECgcJBQAAAA==.',
['折戟']='折戟沉沙:BAAALgAFFAEJAgAAAA==.',
['拉風']='拉風不拉怪:BAABLgAECn8UAAIUAAcJWBp5TwDzAQAUAAcJWBp5TwDzAQAAAA==.',
['拼嘻']='拼嘻嘻:BAAALgAECgcJBwAAAA==.',
['拾捌']='拾捌岁想早恋:BAAALgAFFAQJBAAAAA==.',
['挚刃']='挚刃掌生杀:BAAALgADCgcJBwAAAA==.',
['摩摩']='摩摩尔:BAACLgAFFH8MAAIDAAQJJxygBgBwAQADAAQJJxygBgBwAQAuAAQKfxgAAgMACAl3IFUKAO8CAAMACAl3IFUKAO8CAAAA.',
['摩诃']='摩诃:BAAALgAECgEJAQAAAA==.',
['支離']='支離滅裂:BAABLgAFFH8JAAINAAMJ5CXeCQBTAQANAAMJ5CXeCQBTAQAAAA==.',
['文韬']='文韬武略:BAAALgADCgYJBgAAAA==.',
['斉天']='斉天大圣:BAAALgAECgcJBwAAAA==.',
['断开']='断开连接了:BAAALgADCgEJAQAAAA==.',
['新手']='新手练奶:BAAALgAECgYJDgAAAA==.',
['施眠']='施眠:BAAALgAFFAMJAwAAAA==.',
['无僧']='无僧:BAAALgAFFAEJAQAAAA==.',
['无奶']='无奶:BAAALgAECgIJAwAAAA==.',
['无骑']='无骑骑:BAAALgAECgYJBgAAAA==.',
['旺仔']='旺仔小拳头:BAAALgAECgQJBAAAAA==.',
['易燃']='易燃易爆:BAAALgAECgYJDQAAAA==.',
['星晴']='星晴灬:BAAALgAECgIJAgAAAA==.',
['普通']='普通市民:BAAALgAFFAIJAgAAAA==.',
['晴天']='晴天灬小猪:BAAALgAECgcJBwAAAA==.',
['暗战']='暗战理综:BAAALgADCgEJAQAAAA==.',
['暝梦']='暝梦魂梦寂:BAAALgAECgQJCgAAAA==.',
['曉夜']='曉夜:BAAALgAECgUJBQAAAA==.',
['曼科']='曼科里克:BAAALgAECgEJAQAAAA==.',
['月夕']='月夕花晨丶:BAAALgAECgYJBgAAAA==.',
['月夜']='月夜晨曦:BAAALgAECgQJBQAAAA==.',
['月婉']='月婉点明心:BAAALgAECgYJBwAAAA==.',
['月景']='月景彡:BAAALgAECgIJAgAAAA==.',
['月耀']='月耀暴雨:BAAALgADCgMJAwABLgAECgYJDAABAAAAAA==.',
['有容']='有容灬乃大:BAAALgAFFAQJBAAAAA==.',
['朝朝']='朝朝辞暮:BAAALgAECgEJAQAAAA==.',
['木兰']='木兰:BAAALgAFFAEJAQAAAA==.',
['木子']='木子李:BAAALgAECgYJBwAAAA==.',
['术业']='术业有专攻:BAEBLgAFFH8FAAICAAIJIxepMACxAAACAAIJIxepMACxAAABLgAFFAMJCAAUAJgcAA==.',
['杀走']='杀走不信:BAAALgAECgQJBQAAAA==.',
['权倾']='权倾朝野:BAAALgADCgYJBgAAAA==.',
['李文']='李文推车:BAABLgAFFH8HAAISAAIJoCNVEQDGAAASAAIJoCNVEQDGAAAAAA==.',
['来瓶']='来瓶可乐:BAABLgAECn8UAAIDAAcJ1BQDKgDFAQADAAcJ1BQDKgDFAQAAAA==.',
['枫染']='枫染雨湘丶:BAAALgAECgMJAwABLgAECgMJAwABAAAAAA==.',
['柒星']='柒星:BAAALgADCgMJAwAAAA==.',
['柠檬']='柠檬麦麦:BAAALgAECgUJBQAAAA==.',
['树欲']='树欲静:BAAALgAECgUJBwAAAA==.',
['核弹']='核弹少女暴暴:BAAALgAECgcJBgAAAA==.',
['桂花']='桂花米酿:BAAALgAECgEJAwAAAA==.',
['桃李']='桃李果茶:BAAALgAECgMJAwAAAA==.',
['梦曦']='梦曦:BAAALgADCgYJBgAAAA==.',
['棕色']='棕色大角牛:BAAALgAECgEJAQAAAA==.',
['椰子']='椰子卷:BAAALgADCgYJBgAAAA==.',
['楸慕']='楸慕瑾:BAAALgAECgYJEwAAAA==.',
['楼岚']='楼岚:BAAALgAECgIJAgAAAA==.',
['模仿']='模仿者:BAAALgAECgYJBAABLgAFFAUJCQAIANcWAA==.',
['欧皇']='欧皇小一:BAACLgAFFH8JAAIVAAUJqhHWAgBPAQAVAAUJqhHWAgBPAQAuAAQKfxYAAhUACAmmEX0nAMIBABUACAmmEX0nAMIBAAEuAAUUBgkSABUAeBgA.欧皇小七:BAABLgAFFH8KAAIVAAUJxAwTBgCGAQAVAAUJxAwTBgCGAQAAAA==.欧皇小九:BAABLgAFFH8NAAIVAAUJ+SN6AQAQAgAVAAUJ+SN6AQAQAgAAAA==.欧皇小二:BAACLgAFFH8PAAIVAAUJGRXmBACdAQAVAAUJGRXmBACdAQAuAAQKfxgAAxUACQk+FNARAIsCABUACQk+FNARAIsCABYAAwnxC3IoAIoAAAEuAAUUBgkSABUAeBgA.欧皇小五:BAABLgAFFH8QAAIVAAUJYRcwBACqAQAVAAUJYRcwBACqAQAAAA==.欧皇小六:BAABLgAFFH8KAAIVAAQJIBfhCQBKAQAVAAQJIBfhCQBKAQAAAA==.欧皇小十:BAABLgAFFH8JAAIVAAQJLw36CgA8AQAVAAQJLw36CgA8AQAAAA==.欧皇小四:BAABLgAFFH8LAAIVAAUJxQ+bCgBBAQAVAAUJxQ+bCgBBAQAAAA==.',
['歐氣']='歐氣滿滿灬:BAACLgAFFH8LAAMCAAMJThvJHwAEAQACAAMJ8RfJHwAEAQAXAAEJMRiJEgBaAAAuAAQKfygABAIACAneIfsaALMCAAIACAneIfsaALMCABcABAntGx8pAB4BABgAAQkAAEAnAFQAAAEuAAUUBgkWAAIADyYA.',
['歐皇']='歐皇小三:BAABLgAFFH8HAAIVAAUJwBbZAgDNAQAVAAUJwBbZAgDNAQAAAA==.歐皇小八:BAABLgAFFH8GAAIVAAQJ9Q6yCgBAAQAVAAQJ9Q6yCgBAAQAAAA==.',
['止风']='止风之息:BAAALgAECgYJBgAAAA==.',
['武陵']='武陵蛮:BAAALgAECgQJCgAAAA==.',
['死生']='死生契阔:BAAALgAECgUJBQAAAA==.',
['死骑']='死骑开飞机:BAAALgAFFAEJAQAAAA==.',
['水流']='水流连打:BAAALgAECgkJBwAAAA==.',
['氿星']='氿星:BAAALgADCgUJBQAAAA==.',
['汤圆']='汤圆大魔王:BAAALgADCgIJAQAAAA==.',
['汽车']='汽车人出发:BAAALgAECgQJBAAAAA==.',
['沒想']='沒想好名字:BAAALgAECgMJBAAAAA==.',
['没想']='没想好叫啥:BAAALgAECgYJBwAAAA==.',
['法外']='法外狂爷:BAAALgAECgYJBgAAAA==.',
['泰兰']='泰兰没有徳:BAAALgADCgEJAQAAAA==.',
['流木']='流木牛马:BAAALgAECgEJAQAAAA==.',
['流水']='流水白云芳草:BAAALgAFFAEJAQAAAA==.',
['海心']='海心焰:BAAALgAECgYJDQAAAA==.',
['海狼']='海狼特:BAAALgAECggJCwAAAA==.',
['涌潮']='涌潮悲歌:BAAALgAECgMJAwAAAA==.',
['深仁']='深仁厚泽:BAABLgAECn8XAAISAAkJzQ9zIwAFAgASAAkJzQ9zIwAFAgAAAA==.',
['清欢']='清欢灬:BAAALgAECgYJBgAAAA==.',
['清水']='清水浅浅:BAABLgAFFH8HAAIIAAQJ8RtJAwBjAQAIAAQJ8RtJAwBjAQAAAA==.',
['游吟']='游吟风笛:BAABLgAFFH8IAAIKAAQJGRV0BgBfAQAKAAQJGRV0BgBfAQABLgAFFAUJCQAIANcWAA==.',
['湖畔']='湖畔曉月:BAAALgAECgMJAwAAAA==.',
['滴滴']='滴滴打德:BAAALgAECgcJBAAAAA==.',
['澈溪']='澈溪:BAAALgAECgUJBQAAAA==.',
['火烧']='火烧云:BAAALgAECgYJCAAAAA==.',
['灰原']='灰原哀:BAAALgAECgIJAgAAAA==.',
['灿若']='灿若夏花:BAAALgAECgYJCAAAAA==.',
['煞风']='煞风景后的竹:BAAALgAECgEJAQAAAA==.',
['煮酒']='煮酒会煮粥:BAAALgAFFAEJAQABLgAFFAEJAQABAAAAAA==.煮酒弹可达:BAAALgAFFAEJAQAAAA==.',
['熊猫']='熊猫不是猫吗:BAAALgAECgEJAQAAAA==.',
['燃烧']='燃烧是极好得:BAAALgAECgEJAgAAAA==.',
['爱喝']='爱喝可乐的:BAAALgAECgQJBQAAAA==.',
['爱跳']='爱跳蹦蹦床:BAAALgAECgUJBgAAAA==.',
['牛牛']='牛牛大聪明:BAAALgAECgYJEQAAAA==.牛牛奶:BAAALgADCgIJAgAAAA==.',
['牛角']='牛角公主:BAAALgAECgQJBwAAAA==.',
['牧灬']='牧灬牧:BAAALgAECgMJAwAAAA==.',
['狂夜']='狂夜缥缈:BAEALgAFFAEJAQABLgAFFAMJCAAUAJgcAA==.',
['狂歌']='狂歌空度日:BAAALgAECgMJBQAAAA==.',
['狐嫁']='狐嫁丶:BAAALgAECgQJBQAAAA==.',
['狗儿']='狗儿:BAAALgAECgQJBQAAAA==.',
['狙中']='狙中你的脑袋:BAAALgADCgEJAQAAAA==.',
['独舞']='独舞月下:BAAALgADCgYJCwAAAA==.',
['独行']='独行侠:BAAALgADCgUJBQAAAA==.',
['狮子']='狮子竹山:BAAALgAECgcJEQAAAA==.',
['猎无']='猎无:BAAALgAECgMJAwAAAA==.',
['獨舞']='獨舞月下:BAAALgADCgEJAQAAAA==.',
['王楚']='王楚然:BAAALgAECgEJAgAAAA==.',
['玛法']='玛法里德:BAAALgADCgQJBAAAAA==.',
['珍妮']='珍妮玛黛静:BAAALgAECgUJCQAAAA==.',
['珺璟']='珺璟如晔:BAAALgADCgMJAwAAAA==.',
['瑞塔']='瑞塔阿凡达:BAAALgADCgQJBAAAAA==.',
['瑟瑟']='瑟瑟大角龙:BAAALgAECgQJBAAAAA==.',
['瑷俪']='瑷俪萨:BAAALgAECgEJAQAAAA==.',
['璀璨']='璀璨剃刀:BAAALgAECgEJAQAAAA==.',
['璐宝']='璐宝儿:BAAALgAECgQJBgABLgAFFAYJBAABAAAAAA==.',
['男人']='男人:BAAALgAECgEJAQAAAA==.',
['留云']='留云借风:BAAALgAECgEJAQABLgAECgUJBQABAAAAAA==.',
['痞子']='痞子很忙:BAAALgADCgUJBQAAAA==.',
['白杨']='白杨的孤星:BAAALgAECgYJAgAAAA==.',
['百百']='百百天:BAAALgAECggJEQAAAA==.',
['皆是']='皆是欲望缠身:BAAALgAFFAIJBAAAAA==.',
['盘尼']='盘尼西林:BAAALgAECgMJBgAAAA==.',
['相思']='相思写满天:BAAALgAFFAEJAQAAAA==.',
['真是']='真是不可置信:BAAALgAECgYJCwAAAA==.',
['知兰']='知兰:BAAALgADCgMJAwAAAA==.',
['石头']='石头里蹦出来:BAAALgADCgEJAQAAAA==.',
['硕大']='硕大的球:BAAALgADCgcJBwAAAA==.',
['碎碎']='碎碎念念不忘:BAAALgAFFAEJAQAAAA==.',
['神丶']='神丶棍:BAAALgAECgQJBAAAAA==.',
['神兽']='神兽昆朋:BAAALgADCgMJAwAAAA==.',
['神圣']='神圣暴雨:BAAALgADCgUJBQABLgAECgYJDAABAAAAAA==.',
['神往']='神往术:BAAALgAECgQJAQAAAA==.',
['笛哩']='笛哩笛哩:BAAALgADCgYJBgAAAA==.',
['米奥']='米奥:BAAALgAECgQJBAAAAA==.',
['米缸']='米缸都空了:BAAALgAECgIJBAAAAA==.',
['糖萌']='糖萌萌:BAAALgAECgIJAwAAAA==.',
['糖门']='糖门丶不朽:BAAALgADCgYJBgAAAA==.',
['素三']='素三鲜饺子:BAAALgAECgUJBQAAAA==.',
['紫一']='紫一一:BAAALgAECgEJAQAAAA==.',
['紫暝']='紫暝:BAAALgAECgUJCAAAAA==.',
['繁花']='繁花似锦:BAAALgAFFAEJAQAAAA==.',
['红豆']='红豆绿冰沙:BAAALgAECgUJBwAAAA==.',
['纳格']='纳格兰的风:BAAALgAECgQJBQAAAA==.',
['纳菲']='纳菲酱:BAACLgAFFH8JAAIEAAMJVyJdDQARAQAEAAMJVyJdDQARAQAuAAQKfyEAAwQACAkPIRIQALgCAAQACAkPIRIQALgCABYAAwn2EDEjAL0AAAAA.',
['经验']='经验龙:BAAALgADCgIJAgAAAA==.',
['绫乃']='绫乃:BAAALgAECgQJBQAAAA==.',
['羅方']='羅方瑞泽:BAAALgAECgQJDwAAAA==.',
['羊桉']='羊桉桉发光版:BAAALgAECgYJDAAAAA==.',
['羽落']='羽落无声:BAABLgAFFH8KAAIFAAQJlA/1GABBAQAFAAQJlA/1GABBAQAAAA==.',
['翻滚']='翻滚吧熊猫人:BAAALgAECgYJBgAAAA==.',
['翼之']='翼之殤:BAAALgAFFAQJBAAAAA==.',
['耀肆']='耀肆:BAAALgAECgQJBwAAAA==.',
['老和']='老和尚:BAAALgAECgIJAwAAAA==.',
['老板']='老板来个豆浆:BAAALgAECgYJAgAAAA==.老板来杯豆浆:BAAALgAECgcJAQAAAA==.',
['老椰']='老椰子:BAAALgAECgYJBgAAAA==.',
['老法']='老法:BAAALgAECgEJAQAAAA==.',
['职业']='职业水萨:BAABLgAFFH8GAAIHAAIJERRhFgCkAAAHAAIJERRhFgCkAAAAAA==.',
['胖吨']='胖吨:BAAALgAECgYJCgAAAA==.',
['致暮']='致暮:BAAALgAECgMJAwAAAA==.',
['艳梅']='艳梅:BAAALgAECgEJAwAAAA==.',
['艾丽']='艾丽妮:BAAALgADCgkJCQAAAA==.',
['艾莉']='艾莉萨:BAAALgADCgcJCAAAAA==.',
['芋泥']='芋泥啵啵奶:BAAALgAFFAIJAwAAAA==.',
['芜湖']='芜湖小老板:BAAALgAECgUJCQAAAA==.',
['花圣']='花圣格:BAACLgAFFH8JAAISAAQJdSKiBQCBAQASAAQJdSKiBQCBAQAuAAQKfxkAAhIACAlcJPECAEcDABIACAlcJPECAEcDAAAA.',
['苏十']='苏十:BAAALgAECgIJAgAAAA==.',
['草莓']='草莓大欧皇:BAAALgAECgYJEwAAAA==.',
['菁丶']='菁丶挚爱:BAAALgAFFAIJBAABLgAFFAQJBgADAPoJAA==.',
['蓝光']='蓝光妹:BAAALgAECgQJBAAAAA==.',
['蓝沢']='蓝沢丶润:BAAALgAECgUJBQAAAA==.',
['蓝猫']='蓝猫圣使:BAAALgAECgEJAQAAAA==.',
['蓝绽']='蓝绽:BAAALgAECgMJAwAAAA==.',
['蓝色']='蓝色法衣:BAAALgAECgQJBAAAAA==.',
['蕉尼']='蕉尼座人:BAAALgAECgUJBQAAAA==.',
['蕉皮']='蕉皮哥布林:BAAALgAECgQJBAAAAA==.',
['蕤繠']='蕤繠蘂:BAAALgAECgkJDwAAAA==.',
['蜂蜜']='蜂蜜芥末:BAAALgAECgYJDAAAAA==.',
['被奶']='被奶死的小白:BAAALgAECgEJAQAAAA==.',
['让你']='让你去红叉儿:BAAALgAECgQJDAAAAA==.',
['许你']='许你安然:BAAALgAECgMJAwAAAA==.',
['谈枫']='谈枫:BAACLgAFFH8PAAIZAAQJpxftAAA2AQAZAAQJpxftAAA2AQAuAAQKfysAAxkACQmlIZkAAF4DABkACQmlIZkAAF4DABoABAl+EVxIANEAAAAA.',
['贝丝']='贝丝瑞娜:BAABLgAECn8eAAIFAAcJkhaNFgBdAQAFAAcJkhaNFgBdAQAAAA==.',
['贝鲁']='贝鲁奇奇:BAABLgAECn8VAAQCAAUJcSI6cwB4AQACAAQJcSI6cwB4AQAYAAEJAADZKABOAAAXAAEJGRYvZwBCAAAAAA==.',
['赛文']='赛文七:BAAALgAECgUJBQAAAA==.',
['超级']='超级小象:BAAALgAECgcJDQAAAA==.',
['路边']='路边一壶:BAAALgAECgEJAQAAAA==.',
['踏云']='踏云岚:BAAALgADCgUJBQAAAA==.',
['踏浪']='踏浪逐风:BAAALgAECgEJAQAAAA==.',
['躺下']='躺下叫宁哥:BAAALgAECgYJDQAAAA==.',
['轻易']='轻易小萨萨:BAAALgAECgEJAQAAAA==.',
['达瓦']='达瓦里氏萨:BAAALgAECgEJAQAAAA==.',
['进击']='进击德胖达:BAAALgADCgcJCwABLgAFFAQJEAARADAmAA==.进击的胖达:BAACLgAFFH8QAAIRAAQJMCaqAQDBAQARAAQJMCaqAQDBAQAuAAQKfycAAhEACAn5Ju4AAJYDABEACAn5Ju4AAJYDAAAA.',
['迟夏']='迟夏长信:BAACLgAFFH8IAAIQAAQJVxl/AgB2AQAQAAQJVxl/AgB2AQAuAAQKfxoAAxAABgkEIAI7AMIBABAABQkcIAI7AMIBABsABgmvF6Q+AGABAAAA.',
['道山']='道山靓仔丶:BAABLgAECn8YAAIcAAkJuhSPJwDJAQAcAAkJuhSPJwDJAQAAAA==.',
['邋遢']='邋遢大王:BAAALgAECgUJBQAAAA==.邋遢大王丶:BAAALgAECgEJAQAAAA==.',
['酷吧']='酷吧亚希:BAAALgADCgYJBgAAAA==.',
['醉卧']='醉卧硬床板:BAAALgADCgQJBwAAAA==.',
['醒松']='醒松:BAAALgAECgIJAgAAAA==.',
['重丿']='重丿生:BAAALgAECgEJAgAAAA==.',
['镇影']='镇影:BAAALgAECgUJBgAAAA==.',
['阳光']='阳光沙滩:BAAALgAECgEJAQAAAA==.',
['阿娅']='阿娅小吼:BAAALgAECgEJAQAAAA==.',
['阿拉']='阿拉丁神裆:BAAALgAECgEJAQABLgAECgQJCgABAAAAAA==.',
['陛下']='陛下何故谋反:BAAALgAECgYJCgABLgAECgcJHgAFAI4bAA==.',
['雨境']='雨境居客:BAAALgAECgYJCAAAAA==.',
['雨夜']='雨夜的季节:BAACLgAFFH8IAAITAAMJnQcIIADWAAATAAMJnQcIIADWAAAuAAQKfxgAAhMACQkoFLouAEECABMACQkoFLouAEECAAAA.',
['雨醉']='雨醉清风丶:BAAALgAECgMJAwAAAA==.',
['雪乃']='雪乃:BAAALgAECgEJAQABLgAECgQJBQABAAAAAA==.',
['雲知']='雲知:BAAALgAECgMJAwAAAA==.',
['雾与']='雾与葵:BAAALgAECgUJBQABLgAFFAUJEQAKAIwhAA==.',
['雾岛']='雾岛:BAAALgAECgkJAgAAAA==.',
['非常']='非常奶:BAAALgAECgYJBgAAAA==.',
['鞠婧']='鞠婧祎灬:BAAALgAECgYJBgAAAA==.',
['风之']='风之莎:BAAALgAFFAIJAgAAAA==.',
['风花']='风花丶雪月:BAAALgADCgEJAQAAAA==.',
['飞天']='飞天恶魔:BAAALgAFFAIJBAAAAA==.',
['食人']='食人馍馍法师:BAAALgAFFAIJAgAAAA==.',
['饿龙']='饿龙吃饭:BAAALgAECgMJAwAAAA==.',
['香烟']='香烟美酒:BAAALgADCgMJBAAAAA==.',
['香辣']='香辣鸡排:BAAALgAECgYJDQAAAA==.',
['马斯']='马斯克:BAAALgAECgIJAgAAAA==.',
['骑士']='骑士不会坦:BAAALgAECgIJAgAAAA==.',
['鬼道']='鬼道居士:BAAALgADCgUJBQAAAA==.',
['魂淡']='魂淡丶:BAAALgAECgcJDAABLgAFFAEJAgABAAAAAA==.',
['魔法']='魔法电量不足:BAAALgAECgUJCAAAAA==.',
['魔血']='魔血者塔尼斯:BAAALgAECgcJAgAAAA==.',
['魔鱼']='魔鱼宝宝:BAAALgAECgYJCwAAAA==.',
['鱼与']='鱼与魚与渔:BAAALgAECgcJEQAAAA==.',
['鸡蛋']='鸡蛋:BAAALgAECgEJAQAAAA==.',
['黑夜']='黑夜白帝:BAAALgAECgQJBAAAAA==.',
['黑皮']='黑皮小辣妹:BAAALgAECgMJBQAAAA==.',
['黑石']='黑石前锋:BAAALgAFFAEJAQAAAA==.',
['黑龍']='黑龍战神:BAAALgAECgQJBAAAAA==.',
['鼓雷']='鼓雷敕雨:BAAALgAECgEJAQAAAA==.',
['龙阳']='龙阳七夜:BAAALgAECgkJBQAAAA==.',
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
