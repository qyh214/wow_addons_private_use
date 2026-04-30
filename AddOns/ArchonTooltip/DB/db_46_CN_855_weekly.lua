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

local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','Warrior-Arms','Warrior-Fury','Priest-Discipline','Priest-Shadow','Priest-Holy','DemonHunter-Vengeance','DeathKnight-Blood','Warrior-Protection','Monk-Mistweaver','Mage-Frost','DeathKnight-Unholy','Shaman-Elemental','Shaman-Restoration','Druid-Restoration','Druid-Balance','Paladin-Retribution','DemonHunter-Havoc','Rogue-Subtlety','Evoker-Augmentation','Evoker-Preservation','Monk-Brewmaster','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Paladin-Protection','Evoker-Devastation','Paladin-Holy','Hunter-Survival',}
local provider = {region='CN',realm='铜龙军团',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aiieria:BAAALgAECgkJBwAAAA==.',
Ba='Baby:BAAALgAECgYJBgAAAA==.',
Bb='Bbkkg:BAAALgAFFAEJAQAAAA==.',
Ce='Cery:BAAALgAECgEJAQAAAA==.',
Do='Dontcry:BAABLgAECn8XAAMBAAkJJRXcLwCzAQABAAgJIRDcLwCzAQACAAUJlxcbdwABAQAAAA==.',
Dr='Dragon:BAAALgADCgIJAgAAAA==.',
El='Ellalove:BAAALgAECgcJEAABLgAECgcJEQADAAAAAA==.',
En='Enter:BAAALgADCgYJBgAAAA==.',
Es='Estella:BAAALgAFFAEJAQAAAA==.',
Ex='Exiarepair:BAAALgAECgYJBwAAAA==.',
Fa='Fadetime:BAAALgAFFAEJAQAAAA==.',
Ga='Gafi:BAAALgADCgYJBgAAAA==.Gafii:BAAALgAECgYJBwAAAA==.',
Go='Gowithwind:BAAALgADCgUJCgAAAA==.',
Ha='Hachiware:BAAALgAECgEJAQAAAA==.',
Ic='Icymaple:BAAALgAECgEJAQAAAA==.',
Le='Leo:BAABLgAECn8bAAMEAAgJFCL7AwC4AgAEAAcJFCL7AwC4AgAFAAUJ7iPoOwC1AQAAAA==.',
Li='Liulili:BAAALgAECgkJCQAAAA==.',
Lu='Luckydream:BAAALgAECgEJAQAAAA==.',
Mh='Mhaoshuai:BAAALgAECgQJBQAAAA==.',
Mu='Muldermonk:BAAALgAECgEJAQAAAA==.',
Nu='Nuinui:BAACLgAFFH8PAAMGAAQJ+BBmBQBEAQAGAAQJ+BBmBQBEAQAHAAQJigtnCABAAQAuAAQKfx8ABAcACAlUGZATAFcCAAcABwl3HJATAFcCAAYACAkwEt8jAHQBAAgABQmYCGBRAPIAAAAA.',
On='Onetew:BAAALgAFFAEJAQAAAA==.',
Ou='Ouioui:BAABLgAECn8YAAQGAAgJcRfLFQD3AQAGAAcJzBrLFQD3AQAHAAgJVgbQPAAMAQAIAAEJKiFvHwBhAAABLgAFFAQJDwAGAPgQAA==.',
Pl='Playerpttgfb:BAAALgAFFAIJAQAAAA==.',
Pu='Puzzle:BAAALgAECgIJAgAAAA==.',
Ri='Ritaleung:BAAALgAECgkJCQAAAA==.',
Ru='Rua:BAABLgAECn8aAAIJAAgJYApHEABMAQAJAAgJYApHEABMAQAAAA==.',
Sa='Sanseng:BAAALgADCgIJAgAAAA==.',
Sn='Snoopdktt:BAABLgAECn8ZAAIKAAgJmBuHCwBbAgAKAAgJmBuHCwBbAgAAAA==.',
So='Soulchaos:BAABLgAECn8VAAILAAgJLhelDgAfAgALAAgJLhelDgAfAgAAAA==.',
Ta='Tamdk:BAAALgAECgEJBAAAAA==.',
Tb='Tbmt:BAABLgAECn8aAAIMAAgJdB5yCQC7AgAMAAgJdB5yCQC7AgAAAA==.',
Ve='Velshr:BAAALgAECgEJAgAAAA==.',
Vi='Vilkas:BAAALgAFFAIJAwAAAA==.',
Xy='Xyearnv:BAAALgAECgQJBQAAAA==.',
Xz='Xzvdsgfa:BAABLgAFFH8LAAINAAcJkxblAQDHAQANAAcJkxblAQDHAQAAAA==.',
['一切']='一切都还好:BAAALgAECgQJBAAAAA==.',
['三零']='三零三:BAAALgAECgQJBAAAAA==.',
['东风']='东风不惊尘:BAAALgAFFAIJAgAAAA==.',
['丰饶']='丰饶孤屿:BAAALgAECgcJDAAAAA==.',
['丶丫']='丶丫韵:BAAALgAECgcJBwAAAA==.',
['丶咕']='丶咕噜噜:BAAALgAFFAEJAQAAAA==.',
['丶左']='丶左手:BAAALgAECgMJAwAAAA==.',
['丶浴']='丶浴火凤凰灬:BAAALgAECgYJBgAAAA==.',
['丶潇']='丶潇湘夜雨:BAAALgAECgcJDQAAAA==.',
['乌鸦']='乌鸦丶:BAAALgAECgYJBgAAAA==.',
['九阳']='九阳神功:BAAALgAECgYJDgAAAA==.',
['二六']='二六的遗志:BAAALgAECgMJAwAAAA==.',
['五雷']='五雷法咒:BAAALgAFFAEJAgAAAA==.',
['井岛']='井岛藤野川:BAAALgAECgYJCQAAAA==.',
['人艰']='人艰不拆死骑:BAABLgAFFH8LAAIOAAQJ4iPqBgCaAQAOAAQJ4iPqBgCaAQAAAA==.',
['仅仅']='仅仅是拥抱吗:BAAALgAFFAIJAwAAAA==.',
['今晚']='今晚吃什么呢:BAACLgAFFH8XAAMPAAYJ+ybxAABCAgAPAAUJ/ybxAABCAgAQAAEJqgCbGQA4AAAuAAQKfyIAAg8ACQkiJnEAAOUDAA8ACQkiJnEAAOUDAAAA.',
['伊伊']='伊伊德伊:BAAALgAECgkJCQAAAA==.',
['伊芙']='伊芙利尔:BAABLgAFFH8GAAINAAIJHxinOAC5AAANAAIJHxinOAC5AAAAAA==.',
['佑逝']='佑逝:BAABLgAECn8bAAIIAAcJ1w1eOgBRAQAIAAcJ1w1eOgBRAQAAAA==.',
['何以']='何以报德:BAAALgAECgEJAQAAAA==.',
['余禾']='余禾:BAAALgAECgEJAgAAAA==.',
['你的']='你的男爵:BAABLgAFFH8FAAIQAAMJpxskBwASAQAQAAMJpxskBwASAQAAAA==.',
['做什']='做什么好呢:BAAALgAECgQJBAAAAA==.',
['傲慢']='傲慢的大姨妈:BAAALgADCgQJBAAAAA==.',
['充肉']='充肉的血棒:BAAALgAECgEJAQAAAA==.',
['兔缺']='兔缺缺:BAACLgAFFH8IAAIRAAQJcRpTBwBfAQARAAQJcRpTBwBfAQAuAAQKfxYAAxEACQlhGCAeAE0CABEACQlhGCAeAE0CABIAAQm7B1h+ADQAAAEuAAUUBQkSABAAphUA.',
['兔西']='兔西:BAAALgAECgYJCgAAAA==.',
['公子']='公子冥:BAAALgADCgcJCQAAAA==.',
['内心']='内心的声音:BAAALgAECgIJAgAAAA==.',
['冬天']='冬天不下雪:BAAALgADCgEJAQAAAA==.',
['冰川']='冰川纱夜:BAAALgAECgcJBwAAAA==.',
['冰摇']='冰摇桃桃乌龙:BAAALgAECgUJBQAAAA==.',
['冰火']='冰火羽翼:BAAALgADCgEJAQAAAA==.',
['冲锋']='冲锋闪到背:BAAALgADCgEJAQAAAA==.',
['凯瑟']='凯瑟琳之殇:BAAALgAFFAQJBAAAAA==.',
['凯莉']='凯莉根:BAAALgAECgIJAgAAAA==.',
['凶煞']='凶煞邪神:BAAALgADCgMJAwAAAA==.',
['别小']='别小楼:BAAALgAFFAEJAQAAAA==.',
['前尘']='前尘一梦:BAAALgAECgUJBQAAAA==.',
['加菲']='加菲猫贼可爱:BAAALgAECgQJBgAAAA==.',
['动物']='动物园:BAAALgAECgEJAQAAAA==.',
['千瞳']='千瞳:BAAALgAECgYJCwAAAA==.',
['华山']='华山岳:BAAALgAECgMJAwAAAA==.',
['南征']='南征的十字军:BAAALgAECgcJEgAAAA==.',
['占梦']='占梦一场:BAAALgAECgUJBQAAAA==.',
['口亨']='口亨禾刂:BAAALgAECgIJAgAAAA==.',
['古爸']='古爸爸二号:BAAALgAECgUJCQAAAA==.',
['叶湘']='叶湘伦:BAABLgAFFH8IAAMQAAQJrwsBEgDVAAAQAAMJ8AgBEgDVAAAPAAIJpwQuGgB+AAAAAA==.',
['吉豆']='吉豆豆:BAAALgAECgMJAwAAAA==.',
['吾既']='吾既永恒:BAAALgAECgYJBgAAAA==.',
['咕咕']='咕咕噜噜:BAAALgAECgIJAgAAAA==.',
['咕帕']='咕帕斯:BAAALgAECgEJAQAAAA==.',
['哈利']='哈利波特小:BAAALgAECgEJAgAAAA==.',
['哈吉']='哈吉峰:BAAALgAFFAIJAgAAAA==.',
['哒牛']='哒牛牛:BAAALgAECgQJCAAAAA==.',
['哲哲']='哲哲不可以:BAAALgAECgIJBAABLgAFFAUJEgAQAKYVAA==.',
['喝咖']='喝咖啡的年纪:BAAALgAECgYJBgAAAA==.',
['嘎达']='嘎达维恩:BAAALgAECgUJBQABLgAECggJGAATABMbAA==.',
['国仕']='国仕无双:BAAALgAECgUJCQAAAA==.',
['圆城']='圆城寺怜:BAAALgAECgEJAgAAAA==.',
['土司']='土司:BAACLgAFFH8PAAINAAQJQAhYIABEAQANAAQJQAhYIABEAQAuAAQKfxwAAg0ACAmGF55IAF0CAA0ACAmGF55IAF0CAAAA.',
['圣之']='圣之意羽:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光相随:BAAALgAECgYJBgAAAA==.',
['圣彼']='圣彼得:BAAALgAECgYJDwAAAA==.',
['地獄']='地獄丘比特:BAAALgAECgEJAQAAAA==.',
['坟头']='坟头种树:BAAALgAECgEJAgAAAA==.',
['埃塞']='埃塞拉丝特:BAAALgAECggJDgAAAA==.',
['埃忒']='埃忒拉忒丝:BAAALgAECgYJBAAAAA==.',
['墨倾']='墨倾池:BAABLgAFFH8FAAIUAAIJOBdBCACuAAAUAAIJOBdBCACuAAAAAA==.',
['墨白']='墨白:BAAALgADCgQJBAAAAA==.',
['壹玖']='壹玖捌捌陆陆:BAAALgADCgMJAwAAAA==.',
['处刑']='处刑者:BAAALgAECgQJAQAAAA==.',
['夏侯']='夏侯傲天:BAACLgAFFH8IAAIOAAQJSwlJFgDnAAAOAAQJSwlJFgDnAAAuAAQKfyIAAw4ACAlfFTBGACICAA4ACAlfFTBGACICAAoAAQneAB5OABoAAAAA.',
['夜墨']='夜墨:BAAALgAECgUJBQAAAA==.',
['夜雨']='夜雨江湖:BAAALgAECgUJBAAAAA==.',
['够够']='够够:BAAALgAECgEJBAAAAA==.',
['大婶']='大婶:BAAALgAECgYJCQAAAA==.',
['大梵']='大梵般若:BAAALgAECgcJCAAAAA==.',
['天之']='天之方程:BAAALgAECgcJDQAAAA==.',
['天台']='天台云水:BAAALgAECgcJBgAAAA==.',
['天塌']='天塌下来我顶:BAAALgADCgIJAgAAAA==.',
['天天']='天天红:BAAALgAECgIJAgAAAA==.',
['天宇']='天宇寒星:BAAALgAFFAEJAQAAAA==.',
['好叻']='好叻没丶哥:BAAALgAFFAEJAwAAAA==.',
['好阿']='好阿赛:BAAALgAECgIJAgAAAA==.',
['如龙']='如龙:BAAALgAECgYJBAAAAA==.',
['娇曼']='娇曼巴:BAAALgAECgEJAQAAAA==.',
['嫣姨']='嫣姨丶:BAAALgAECgYJBgAAAA==.',
['孪蛇']='孪蛇:BAAALgAECgYJCQAAAA==.',
['安妮']='安妮弗妮佩尔:BAAALgAECgkJCQABLgAFFAUJEAAVAC8lAA==.',
['安娜']='安娜猪:BAABLgAFFH8JAAMWAAQJoxZRCQBaAQAWAAQJoxZRCQBaAQAXAAMJeg7CEgCXAAAAAA==.',
['宝可']='宝可梦:BAAALgADCgIJAgAAAA==.',
['宝宝']='宝宝小牛奶:BAAALgAFFAQJBAAAAA==.',
['富态']='富态武僧:BAAALgAECgkJCAABLgAFFAUJCQAYAH0fAA==.',
['小井']='小井丿丹丹:BAACLgAFFH8KAAMZAAQJLxTNDACmAAAaAAIJsxiXHAC1AAAZAAIJqw/NDACmAAAuAAQKfyIABBoACAnRHWYgAJYCABoACAnuG2YgAJYCABkAAwmTHfkwAPYAABsAAQkAALQqAEoAAAAA.',
['小奕']='小奕辰:BAAALgAECgEJAgAAAA==.',
['小文']='小文文吃饱饱:BAAALgAFFAMJAwAAAA==.',
['小源']='小源子:BAAALgAECgcJDgABLgAECgcJEQADAAAAAA==.',
['小熊']='小熊猫儿:BAAALgADCgcJCAAAAA==.',
['小通']='小通神:BAAALgAECgUJBQAAAA==.',
['小鸡']='小鸡嚼:BAABLgAFFH8FAAIHAAUJVAGGCAA9AQAHAAUJVAGGCAA9AQAAAA==.',
['就是']='就是任性:BAABLgAECn8aAAITAAgJhRXJRAAVAgATAAgJhRXJRAAVAgAAAA==.',
['山鸡']='山鸡爷:BAAALgAFFAEJAQAAAA==.',
['左左']='左左魔:BAAALgADCgQJBAAAAA==.',
['布讲']='布讲栗猫:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔丶佳丽斯:BAACLgAFFH8PAAILAAQJmRkRBABCAQALAAQJmRkRBABCAQAuAAQKfyYAAwsACAktIFEFAOgCAAsACAktIFEFAOgCAAUAAQmcBkyyACYAAAAA.希尔格琳:BAABLgAECn8aAAINAAgJ0xRVYAAaAgANAAgJ0xRVYAAaAgAAAA==.',
['幸福']='幸福滴味道:BAAALgADCgcJBwAAAA==.',
['强韧']='强韧无敌最强:BAAALgAECgUJBQAAAA==.',
['彩虹']='彩虹匣子:BAAALgAECgQJBQAAAA==.',
['徐总']='徐总优雅:BAAALgAECgYJBgAAAA==.徐总无敌:BAAALgAECgcJDQAAAA==.徐总牛逼:BAABLgAECn8aAAIcAAgJ4hgvCQBBAgAcAAgJ4hgvCQBBAgAAAA==.',
['忆之']='忆之破魂:BAAALgAECgYJBwAAAA==.',
['快乐']='快乐之殇:BAAALgAECgEJAgAAAA==.',
['恋恋']='恋恋清纯:BAAALgAECgIJBQAAAA==.',
['恋生']='恋生花:BAAALgAECgkJCgABLgAFFAQJDgANAKcWAA==.',
['恶魔']='恶魔破晓:BAABLgAECn8UAAIUAAgJug1iBQCVAQAUAAgJug1iBQCVAQAAAA==.',
['悉如']='悉如空雨丶:BAAALgAECgYJDAAAAA==.',
['想吃']='想吃小米糕:BAAALgAECgkJCQAAAA==.',
['戈提']='戈提克:BAAALgAECgkJAwAAAA==.',
['我叫']='我叫张无忌:BAAALgAECgUJBQAAAA==.',
['我就']='我就是小红:BAACLgAFFH8OAAIOAAQJeRS6FwBGAQAOAAQJeRS6FwBGAQAuAAQKfxUAAg4ABwmkIYs3AFgCAA4ABwmkIYs3AFgCAAAA.',
['我曾']='我曾经灬:BAAALgADCgIJAgAAAA==.',
['我的']='我的偏爱是你:BAAALgAECgEJAQAAAA==.',
['我配']='我配啊:BAABLgAFFH8GAAIMAAUJVgKuBQAdAQAMAAUJVgKuBQAdAQAAAA==.',
['我非']='我非落花:BAACLgAFFH8RAAITAAUJpQvoBgBAAQATAAUJpQvoBgBAAQAuAAQKfxoAAxMACAlqG6I3AEQCABMABwngH6I3AEQCABwAAgnXCBRNABkAAAAA.',
['戒糖']='戒糖失败:BAABLgAECn8aAAMZAAgJpR2TEgC3AQAaAAcJJB1QMwA/AgAZAAUJ6x2TEgC3AQAAAA==.',
['户舒']='户舒宝:BAAALgAECgQJBQAAAA==.',
['拉奥']='拉奥:BAAALgAECgQJBAAAAA==.',
['挊他']='挊他:BAAALgAECgcJCgAAAA==.',
['掌控']='掌控未来力量:BAAALgAECgYJBwAAAA==.',
['搓搓']='搓搓球:BAAALgADCgUJBQAAAA==.',
['摇摇']='摇摇马:BAAALgAECgYJBgAAAA==.',
['撩人']='撩人的小恶魔:BAAALgAECgUJBgAAAA==.',
['攻击']='攻击强度:BAAALgAFFAEJAQAAAA==.',
['敌法']='敌法爱你呦:BAAALgAECgMJAwAAAA==.',
['文秋']='文秋晨:BAAALgAECgMJAwAAAA==.',
['旋影']='旋影:BAAALgAECgEJAQAAAA==.',
['无恶']='无恶不做丸:BAAALgAECgUJDQAAAA==.',
['无情']='无情的梅子:BAAALgAECgQJBAAAAA==.无情的梨子:BAACLgAFFH8NAAISAAQJ4x82BQCWAQASAAQJ4x82BQCWAQAuAAQKfxkAAhIABwmcJOsQAJcCABIABwmcJOsQAJcCAAAA.',
['明天']='明天就发货:BAAALgAECgcJBwAAAA==.',
['明月']='明月丶铸光者:BAAALgAECgYJCgAAAA==.',
['星叶']='星叶:BAAALgAECgYJBgAAAA==.',
['星宿']='星宿佬仙:BAABLgAECn8VAAMWAAcJaxyTFQAuAgAWAAcJXBuTFQAuAgAdAAYJfQ9/HgA6AQAAAA==.',
['暂停']='暂停一下大侠:BAAALgADCgIJAgAAAA==.',
['暖风']='暖风清新:BAAALgAECgMJBAAAAA==.',
['暗影']='暗影凌云:BAAALgAECgcJDwAAAA==.暗影艾莉亚:BAAALgAECgMJBQAAAA==.',
['曦月']='曦月情:BAAALgAECgYJCAABLgAFFAQJDAATAJEdAA==.',
['最后']='最后的追忆:BAAALgAECgEJAQAAAA==.',
['最爱']='最爱吃番茄:BAACLgAFFH8KAAIOAAQJ/hpEDgBpAQAOAAQJ/hpEDgBpAQAuAAQKfxcAAg4ACAkMIO4mAKACAA4ACAkMIO4mAKACAAAA.',
['月步']='月步:BAAALgAECgYJBgAAAA==.',
['杀神']='杀神白起:BAAALgAFFAEJAgAAAA==.',
['李柚']='李柚巴:BAABLgAECn8WAAIYAAgJ6hahGgAvAgAYAAgJ6hahGgAvAgAAAA==.',
['来都']='来都来了:BAAALgAECgEJAQAAAA==.',
['杨贵']='杨贵妃:BAAALgAECgQJBgAAAA==.',
['极度']='极度小红帽:BAAALgAECgMJBQAAAA==.极度砖砖:BAABLgAECn8VAAQEAAYJLhQ0EQCLAQAEAAYJkRI0EQCLAQAFAAMJGRDhhACrAAALAAEJLgxXRwAxAAAAAA==.',
['柔情']='柔情的大姨妈:BAAALgADCgcJBwAAAA==.',
['柠檬']='柠檬小葫芦:BAAALgAECgUJCAAAAA==.',
['柳北']='柳北奥沙利文:BAAALgAECgYJCgAAAA==.',
['树摇']='树摇红雨落:BAAALgAECgMJAwAAAA==.',
['格琳']='格琳希尔:BAAALgAECgYJCgAAAA==.',
['桐谷']='桐谷直叶:BAAALgAECgEJAQAAAA==.',
['桑德']='桑德兰:BAAALgAECgYJBgAAAA==.',
['梆梆']='梆梆就两拳:BAAALgAECgkJCQAAAA==.',
['梦醒']='梦醒黎明:BAAALgADCgEJAQAAAA==.',
['榴芒']='榴芒:BAAALgAFFAQJBAABLgAFFAUJCQASACUgAA==.',
['步云']='步云裳:BAAALgAECgMJBAAAAA==.',
['残桥']='残桥陈雪:BAABLgAFFH8FAAMIAAMJSxIlCADmAAAIAAMJphElCADmAAAGAAEJ0AU3GgBHAAAAAA==.',
['永恆']='永恆愛你:BAABLgAECn8VAAQcAAcJ4xXREgCdAQAcAAYJihfREgCdAQATAAcJRxBhgQB3AQAeAAQJXg+pIgCJAAAAAA==.',
['汤姆']='汤姆丶汉克斯:BAAALgAECgcJCAAAAA==.',
['決戀']='決戀:BAAALgAECgYJDAAAAA==.',
['沉默']='沉默乂分钟:BAAALgAECggJCQABLgAFFAQJDAAQAIkhAA==.沉默乂小时:BAACLgAFFH8MAAIQAAQJiSFmBACLAQAQAAQJiSFmBACLAQAuAAQKfxQAAhAACAnJHmQRAIwCABAACAnJHmQRAIwCAAAA.',
['没法']='没法捏脸啊:BAACLgAFFH8PAAIGAAQJ1BrMBwBfAQAGAAQJ1BrMBwBfAQAuAAQKfycABAYACAlZIDoKAJYCAAYACAnkHDoKAJYCAAcABgmwF+MjALgBAAgAAQneIcJ1AFIAAAAA.',
['法瑞']='法瑞拉恩:BAAALgAECggJEQAAAA==.',
['泽塔']='泽塔曼:BAAALgAECgQJBAAAAA==.',
['洛德']='洛德曼:BAAALgAECgEJAQAAAA==.',
['浅仓']='浅仓小南:BAAALgADCgcJBwAAAA==.',
['浩宇']='浩宇之影:BAAALgAECgEJAwAAAA==.',
['清歌']='清歌范尘:BAAALgAECgEJAQAAAA==.',
['源琳']='源琳:BAAALgAECgcJEQAAAA==.源琳儿:BAAALgAECgcJDQABLgAECgcJEQADAAAAAA==.',
['灬玉']='灬玉景丶天池:BAABLgAFFH8JAAIFAAQJvQzUCwBFAQAFAAQJvQzUCwBFAQAAAA==.',
['灰灰']='灰灰大人:BAAALgADCgUJBQAAAA==.',
['熊虎']='熊虎:BAAALgAFFAIJAgAAAA==.',
['爱笑']='爱笑的天天艺:BAAALgAECgYJBwAAAA==.',
['牧羊']='牧羊姑娘:BAAALgAECgYJBgAAAA==.',
['牧麟']='牧麟:BAAALgADCgUJBQAAAA==.',
['独影']='独影阑珊:BAAALgAECgEJAQAAAA==.',
['独自']='独自等待爱:BAAALgADCgIJAgAAAA==.',
['猎爸']='猎爸灬天下:BAAALgADCgIJAgAAAA==.',
['王楚']='王楚然:BAAALgAECgMJAwAAAA==.',
['玛尔']='玛尔斯:BAACLgAFFH8NAAITAAYJ2RleAADpAQATAAYJ2RleAADpAQAuAAQKfx4AAhMABwmtIq8cAL4CABMABwmtIq8cAL4CAAAA.',
['玥戰']='玥戰:BAAALgAFFAIJAQAAAA==.',
['玫瑰']='玫瑰豆沙粽:BAAALgAECgUJDQAAAA==.',
['珩珩']='珩珩:BAAALgADCggJCAABLgAFFAYJEwATAMggAA==.',
['琳奈']='琳奈:BAABLgAECn8VAAITAAgJwCJQDAArAwATAAgJwCJQDAArAwAAAA==.',
['瑞吉']='瑞吉蕾芙:BAAALgAECgEJBAAAAA==.',
['田里']='田里的呆小牛:BAAALgAECgEJAQAAAA==.',
['甲子']='甲子园的梦:BAAALgAECgYJAgAAAA==.',
['男人']='男人无泪:BAAALgAFFAEJAgAAAA==.',
['當归']='當归:BAAALgAECgYJCQAAAA==.',
['疯癫']='疯癫橘子:BAAALgADCgEJAQAAAA==.',
['白楼']='白楼独舞:BAAALgAECgcJBwAAAA==.',
['盧山']='盧山升龍霸:BAAALgADCgEJAQAAAA==.',
['省厅']='省厅祁同伟:BAAALgAECgYJCQAAAA==.',
['看守']='看守:BAAALgAECggJDQAAAA==.',
['真画']='真画之诗:BAAALgADCgEJAQAAAA==.',
['知识']='知识青年:BAAALgAECgYJDQAAAA==.',
['积化']='积化和差:BAAALgAECgYJBgAAAA==.',
['稳重']='稳重:BAAALgAECgQJBwAAAA==.',
['笃悠']='笃悠悠:BAAALgADCgEJAQAAAA==.',
['筱攸']='筱攸:BAAALgADCgYJBgAAAA==.',
['筱莜']='筱莜莜:BAAALgAECgMJAwAAAA==.',
['箭神']='箭神:BAAALgAECgYJBgAAAA==.',
['米帅']='米帅:BAAALgAECgYJBQAAAA==.',
['糖果']='糖果贩卖机:BAAALgAECgEJAQAAAA==.',
['紫妮']='紫妮:BAACLgAFFH8OAAIfAAQJFhoPAQB4AQAfAAQJFhoPAQB4AQAuAAQKfx0AAh8ABwnHIwUFAL8CAB8ABwnHIwUFAL8CAAAA.',
['绮云']='绮云:BAAALgAECgIJAgAAAA==.',
['绯红']='绯红夜:BAAALgAECgYJCQAAAA==.',
['维克']='维克尼拉斯:BAAALgAECgEJAQAAAA==.',
['绿冰']='绿冰冰:BAAALgADCgMJAwAAAA==.',
['美年']='美年达四块:BAAALgAECgYJCwAAAA==.',
['群青']='群青:BAEALgAFFAEJAQAAAA==.',
['老司']='老司机:BAAALgAFFAIJAwAAAA==.',
['老白']='老白丶:BAAALgAECgYJDAAAAA==.',
['肥泡']='肥泡泡:BAAALgAECgcJEAABLgAFFAUJEgAQAKYVAA==.',
['胡哥']='胡哥:BAAALgAECgQJBQAAAA==.',
['胭脂']='胭脂釦:BAAALgAFFAQJBAAAAA==.',
['能打']='能打能加能扛:BAACLgAFFH8FAAIeAAMJUwtCCQDQAAAeAAMJUwtCCQDQAAAuAAQKfxUAAh4ACAnuD6g3AJwBAB4ACAnuD6g3AJwBAAAA.',
['舍甫']='舍甫琴科丶:BAAALgAECgkJAgAAAA==.',
['花子']='花子虚丶:BAAALgAECgQJAQAAAA==.',
['花肚']='花肚兜儿:BAAALgAECgEJAQAAAA==.',
['芹泽']='芹泽千枝实:BAAALgAECgcJDgAAAA==.',
['苋菜']='苋菜:BAAALgAECgUJBQAAAA==.',
['苏暖']='苏暖暖:BAACLgAFFH8TAAIXAAQJ2CURAgCnAQAXAAQJ2CURAgCnAQAuAAQKfy4AAxcACAmiJhoBAIMDABcACAmiJhoBAIMDABYABQlTHjAUAOMAAAAA.',
['莉夏']='莉夏丶毛:BAAALgAECgcJCwAAAA==.',
['莓莓']='莓莓纸:BAAALgAECgQJBwABLgAFFAUJEgAQAKYVAA==.',
['莜月']='莜月雅兰:BAAALgAECgUJAwAAAA==.',
['莪杺']='莪杺畩舊:BAAALgAECgcJBwAAAA==.',
['莱戈']='莱戈拉斯绿叶:BAAALgAECgMJBgAAAA==.',
['萌倒']='萌倒一片:BAAALgADCgQJBAAAAA==.',
['萝莉']='萝莉骑士:BAAALgAECgEJAQAAAA==.',
['萨利']='萨利尔:BAAALgADCgIJAgAAAA==.',
['蓝皮']='蓝皮鼠鼠:BAAALgADCgMJAwAAAA==.',
['蔑视']='蔑视星辰:BAABLgAECn8YAAMTAAgJExv3LgBnAgATAAgJExv3LgBnAgAeAAEJPAD5pAAOAAAAAA==.',
['藤井']='藤井树:BAAALgAECgcJBwAAAA==.',
['蛋黄']='蛋黄咸肉粽:BAAALgAECgYJDQAAAA==.',
['蟲虫']='蟲虫:BAAALgAECgEJAgAAAA==.',
['血法']='血法:BAAALgAECgQJCAAAAA==.',
['血袍']='血袍:BAAALgAECgUJBQAAAA==.',
['衣衣']='衣衣:BAACLgAFFH8IAAICAAMJhxf2CQASAQACAAMJhxf2CQASAQAuAAQKfxQAAgIACAlfHuYRAKkCAAIACAlfHuYRAKkCAAAA.',
['西十']='西十里:BAAALgAECgUJDQABLgAFFAIJAgADAAAAAA==.',
['见悉']='见悉牡师:BAAALgAFFAEJAQAAAA==.',
['诺顿']='诺顿丨吕归尘:BAAALgAECgEJAQAAAA==.',
['谜聲']='谜聲:BAABLgAFFH8GAAIaAAMJgwy0FQDtAAAaAAMJgwy0FQDtAAAAAA==.',
['贤贤']='贤贤驴:BAAALgAECgYJDQAAAA==.',
['贰六']='贰六:BAAALgAECgEJAQAAAA==.',
['贱贱']='贱贱的蛋炒饭:BAAALgAECgcJBgAAAA==.',
['贵族']='贵族杀马特:BAAALgAECgQJBAABLgAECggJEQADAAAAAA==.',
['达克']='达克妮丝丶:BAAALgAECgcJCQAAAA==.',
['达米']='达米亚休斯:BAAALgADCgcJCwAAAA==.达米亚帝斯:BAAALgADCgcJDAAAAA==.',
['近战']='近战碾压机:BAAALgAECgIJAgAAAA==.',
['迷提']='迷提布莉姆:BAAALgAECgcJDgAAAA==.',
['醉竹']='醉竹:BAAALgADCgEJAQAAAA==.',
['铃依']='铃依大熊猫:BAAALgADCgEJAQAAAA==.',
['长门']='长门丶有希:BAACLgAFFH8FAAINAAQJsBG+GgBgAQANAAQJsBG+GgBgAQAuAAQKfxgAAg0ACAmlGPg7AIcCAA0ACAmlGPg7AIcCAAAA.',
['闪灵']='闪灵归来:BAAALgAECgYJEAAAAA==.',
['阿尔']='阿尔玛斯:BAABLgAECn8VAAIeAAYJrBDeTABFAQAeAAYJrBDeTABFAQAAAA==.',
['阿布']='阿布罗狄:BAACLgAFFH8FAAIOAAIJpx7PNgCuAAAOAAIJpx7PNgCuAAAuAAQKfxUAAg4ABwlQIB4wAHcCAA4ABwlQIB4wAHcCAAAA.',
['阿迩']='阿迩忒彌斯:BAAALgAECgEJAQAAAA==.',
['阿酷']='阿酷灬:BAABLgAFFH8HAAISAAQJlxyUDAAaAQASAAQJlxyUDAAaAQAAAA==.',
['陈丶']='陈丶风暴假酒:BAACLgAFFH8PAAIYAAQJ2xVzCQA/AQAYAAQJ2xVzCQA/AQAuAAQKfycAAhgACAkTI38HAA0DABgACAkTI38HAA0DAAAA.',
['陨石']='陨石:BAAALgAECgUJBQAAAA==.',
['雕上']='雕上有毛:BAAALgAECgEJAQAAAA==.',
['雷加']='雷加尔:BAAALgAFFAEJAQAAAA==.',
['青宝']='青宝宝:BAAALgAECgcJDgAAAA==.',
['非非']='非非:BAAALgAFFAMJBAAAAA==.',
['領主']='領主王大錘:BAAALgAECgMJAwAAAA==.',
['颯丶']='颯丶:BAAALgADCgMJAwAAAA==.',
['饕夔']='饕夔餮:BAAALgAECggJDAAAAA==.',
['馥杛']='馥杛:BAAALgAECgMJAwAAAA==.',
['骁瑪']='骁瑪:BAACLgAFFH8IAAIaAAQJmAwQFgDqAAAaAAQJmAwQFgDqAAAuAAQKfxoAAhoABwlKIFsXAHoBABoABwlKIFsXAHoBAAAA.',
['鬼秋']='鬼秋:BAAALgAECgYJCQAAAA==.',
['魅影']='魅影兽灵:BAAALgAECgMJAwAAAA==.魅影冰灵:BAAALgAECgEJAQAAAA==.魅影巫术:BAAALgAECgUJBAAAAA==.魅影影风:BAAALgAECgQJBAAAAA==.',
['鲨士']='鲨士比亚:BAAALgAECgEJAQAAAA==.',
['鲸湾']='鲸湾粉刷匠:BAAALgAECgIJAgAAAA==.',
['鸡屁']='鸡屁股的马仔:BAACLgAFFH8FAAIdAAMJOhi0AwAYAQAdAAMJOhi0AwAYAQAuAAQKfxMAAh0ABgnfI6YJAEUCAB0ABgnfI6YJAEUCAAAA.',
['鸢飞']='鸢飞唳天:BAABLgAECn8VAAMBAAgJJBvdGABhAgABAAgJJBvdGABhAgACAAEJEAyvUwBCAAAAAA==.',
['麦旋']='麦旋风九块:BAAALgAECgYJCQAAAA==.',
['黑乎']='黑乎乎的圣光:BAAALgAECgMJBAAAAA==.',
['黑悟']='黑悟空:BAAALgADCgEJAQAAAA==.',
['黑旋']='黑旋风八戒:BAAALgADCgYJBQAAAA==.',
['黑翼']='黑翼大魔:BAAALgADCgYJBgAAAA==.',
['默姐']='默姐:BAABLgAECn8VAAINAAcJNxysewDaAQANAAcJNxysewDaAQAAAA==.',
['默苍']='默苍离:BAABLgAFFH8JAAINAAMJgyE9EgAfAQANAAMJgyE9EgAfAQAAAA==.',
['黯影']='黯影之曈:BAAALgAECgYJBgAAAA==.',
['鼠鼠']='鼠鼠:BAAALgAECgEJAQAAAA==.',
['龙兄']='龙兄:BAEALgAECgUJBQAAAA==.',
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
