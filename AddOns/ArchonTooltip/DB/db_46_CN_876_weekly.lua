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

local lookup = {'Unknown-Unknown','Warlock-Demonology','DemonHunter-Devourer','Druid-Balance','Warlock-Destruction','Warlock-Affliction','Monk-Brewmaster','Paladin-Retribution','Paladin-Holy','Hunter-BeastMastery','DeathKnight-Unholy','Monk-Windwalker','Hunter-Marksmanship','Mage-Frost','DeathKnight-Blood','DemonHunter-Vengeance','Warrior-Protection','Warrior-Arms','Warrior-Fury','Shaman-Elemental',}
local provider = {region='CN',realm='雷霆之怒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Ares:BAAALgADCgUJBQAAAA==.',
Co='Coldice:BAAALgADCgcJCAAAAA==.',
Fa='Fallenange:BAAALgAFFAEJAQAAAA==.',
Gl='Glitch:BAAALgAECgEJAQABLgAFFAIJBAABAAAAAA==.',
Li='Linainverse:BAAALgADCgUJBQAAAA==.',
Lo='Lovemotto:BAAALgAECgUJBAAAAA==.',
Mi='Midnight:BAAALgAFFAUJBAAAAA==.',
Ne='Neonx:BAAALgAFFAEJAQAAAA==.',
Ph='Phrolova:BAAALgAFFAIJBAAAAA==.',
Re='Reaperde:BAAALgAFFAIJAgAAAA==.',
Ve='Vermouth:BAAALgAECgEJAQAAAA==.',
Xb='Xbd:BAAALgADCgUJBgAAAA==.',
['一只']='一只猫:BAAALgADCgUJBQAAAA==.',
['与子']='与子彤鉴:BAAALgAFFAIJBAAAAA==.',
['丨坦']='丨坦途:BAAALgADCgYJBgAAAA==.',
['丨天']='丨天羊:BAAALgAECggJCAABLgAFFAMJBgACAAYmAA==.',
['丨捌']='丨捌灵体育生:BAAALgAECgQJBAAAAA==.',
['丶常']='丶常伴吾身:BAAALgAECgUJBQAAAA==.',
['丶梧']='丶梧桐古语:BAAALgAECgIJAgAAAA==.',
['丷夜']='丷夜火琉萤丷:BAAALgAFFAEJAQAAAA==.',
['丸子']='丸子没了樱桃:BAAALgAECggJEwAAAA==.',
['乄壹']='乄壹生灬:BAAALgADCgMJAwAAAA==.',
['乐融']='乐融融的梦:BAAALgAECgMJAwAAAA==.',
['乳酪']='乳酪戯芢:BAAALgAFFAIJAgAAAA==.',
['二到']='二到家:BAAALgAECgQJBAAAAA==.',
['你就']='你就是只爬爬:BAAALgAECgMJAwABLgAFFAMJBgADAIwHAA==.',
['傲意']='傲意:BAAALgAECgYJBgAAAA==.',
['克莱']='克莱因:BAAALgAECgUJCAAAAA==.',
['兜里']='兜里有熊:BAACLgAFFH8PAAIEAAUJURCVBACiAQAEAAUJURCVBACiAQAuAAQKfxQAAgQACAm/Gu4ZADYCAAQACAm/Gu4ZADYCAAAA.',
['八卦']='八卦海:BAAALgAECgMJAwAAAA==.',
['八戒']='八戒弟弟:BAAALgAECgQJAwAAAA==.',
['八雲']='八雲紫:BAACLgAFFH8GAAICAAMJBiaTEQBXAQACAAMJBiaTEQBXAQAuAAQKfxUABAUACAmjJFEQAM0BAAIABglVJForAGICAAUABQl5IVEQAM0BAAYAAQkAAOElAFoAAAAA.',
['冰落']='冰落无心:BAAALgADCgYJBgAAAA==.',
['减肥']='减肥成功:BAAALgAECggJCgAAAA==.',
['凯尔']='凯尔雷诺:BAAALgADCgMJAwAAAA==.',
['到哪']='到哪都是大哥:BAAALgADCgMJAwAAAA==.',
['功夫']='功夫脆脆:BAAALgAECgMJAgAAAA==.',
['化劲']='化劲马保国:BAABLgAFFH8FAAICAAMJ3CFvGADVAAACAAMJ3CFvGADVAAAAAA==.',
['化粪']='化粪池爆破手:BAAALgAECgMJAwAAAA==.',
['千灵']='千灵灵:BAAALgADCgEJAQAAAA==.',
['千穗']='千穗千珐:BAAALgAECgEJAQAAAA==.',
['变成']='变成剪影:BAAALgAECgEJAQAAAA==.',
['吉贝']='吉贝克之劍:BAAALgAECgQJBgAAAA==.',
['哈丸']='哈丸儿:BAAALgAECgUJCAAAAA==.',
['喜欢']='喜欢谧静:BAAALgAECgcJDwAAAA==.',
['四顾']='四顾庆帝剑:BAAALgADCgEJAQABLgAFFAcJFgAHAGsTAA==.',
['团灭']='团灭剩骑士:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱靓仔:BAAALgADCgEJAQAAAA==.',
['塞勒']='塞勒涅:BAAALgAECgMJAwAAAA==.',
['壮壮']='壮壮:BAAALgAECgIJAwAAAA==.',
['壹丄']='壹丄生:BAAALgAECgYJCgAAAA==.',
['复仇']='复仇者联盟:BAAALgAECgEJAQAAAA==.',
['大人']='大人小样:BAAALgADCgQJBAAAAA==.',
['大地']='大地母亲:BAAALgAECgEJAQAAAA==.',
['大表']='大表哥来了:BAAALgAECgIJAgAAAA==.',
['天使']='天使丶审判:BAAALgAECgEJAQAAAA==.',
['天生']='天生诗人:BAAALgAECgEJAQAAAA==.',
['天界']='天界自由:BAAALgAECgYJDQAAAA==.',
['天降']='天降胖贼:BAAALgAECgYJBgAAAA==.',
['太特']='太特么好:BAAALgAECgIJAwAAAA==.',
['女高']='女高往事:BAAALgAECgcJDgAAAA==.',
['奶思']='奶思丶:BAAALgAECgEJAQAAAA==.',
['寒歌']='寒歌傲雪:BAAALgAECgQJBgAAAA==.',
['對酒']='對酒當歌:BAAALgADCgEJAQAAAA==.',
['小尾']='小尾巴丶球球:BAAALgAECgEJAwAAAA==.',
['小心']='小心口气:BAAALgADCgEJAQAAAA==.小心追云鬼:BAAALgAECgEJAQAAAA==.',
['小顽']='小顽皮:BAAALgAECgEJAgAAAA==.',
['尐了']='尐了辣了椒:BAABLgAFFH8JAAMIAAQJiACWGgDLAAAIAAQJiACWGgDLAAAJAAIJvx/UEgCxAAAAAA==.',
['尐歘']='尐歘灬歘:BAAALgADCgYJBgAAAA==.',
['尕小']='尕小雅:BAAALgAECgcJDQAAAA==.',
['尬德']='尬德:BAAALgAFFAIJAwAAAA==.',
['巧克']='巧克力甜甜圈:BAAALgAECgUJCAAAAA==.',
['差不']='差不多女生灬:BAAALgAECgEJAQAAAA==.',
['巴黎']='巴黎倍儿甜:BAAALgAECgEJAQAAAA==.',
['廖嘚']='廖嘚高:BAAALgAECgIJAgAAAA==.',
['很勇']='很勇猛:BAAALgAECgQJAQAAAA==.',
['很御']='很御姐:BAAALgAECgMJAwAAAA==.',
['很犀']='很犀利:BAABLgAFFH8FAAIKAAIJLBNWFgCsAAAKAAIJLBNWFgCsAAAAAA==.',
['德能']='德能:BAAALgAECgQJBAAAAA==.',
['愣头']='愣头青:BAAALgAECgEJAQAAAA==.',
['愤努']='愤努的影魔:BAABLgAFFH8GAAILAAIJXBoQIAChAAALAAIJXBoQIAChAAAAAA==.',
['愤怒']='愤怒的鲨鱼:BAAALgAFFAIJAwAAAA==.',
['懂感']='懂感恩:BAAALgAECgEJAwABLgAFFAEJAQABAAAAAA==.',
['战神']='战神归来:BAAALgADCgYJDQAAAA==.',
['抓住']='抓住鸡喙:BAAALgADCgQJBAAAAA==.',
['抓只']='抓只大老虎:BAAALgAECggJBgAAAA==.',
['抱抱']='抱抱小妹妹:BAAALgAECgEJAQAAAA==.',
['无夜']='无夜:BAACLgAFFH8TAAMMAAUJkh9HAwBuAQAMAAQJlh1HAwBuAQAHAAMJAyCjFwCyAAAuAAQKfyYAAwwACQmYJGYFAC4DAAwACAmsI2YFAC4DAAcACAkiI7UHAAoDAAAA.',
['旧事']='旧事随风去:BAAALgADCggJEQAAAA==.',
['星爺']='星爺:BAAALgAECgYJDAAAAA==.',
['晓小']='晓小僧:BAAALgAECgYJBwAAAA==.',
['晚安']='晚安:BAAALgAECgEJAQABLgAECgkJFAAIAGQbAA==.',
['暗影']='暗影之翼:BAAALgAECgQJCAAAAA==.',
['月亮']='月亮骑士:BAAALgAECgQJBAAAAA==.',
['月半']='月半小月半:BAAALgAECgQJBgAAAA==.',
['未名']='未名:BAAALgAECgEJAQAAAA==.',
['术师']='术师不太冷:BAAALgADCgcJBwAAAA==.',
['林夕']='林夕灬梦:BAABLgAFFH8HAAMCAAQJugmkEwD6AAACAAQJ/wWkEwD6AAAFAAEJHg8vFQBUAAAAAA==.',
['枫絮']='枫絮:BAAALgAECgEJAgAAAA==.',
['楚丶']='楚丶风暴烈酒:BAABLgAFFH8GAAIHAAMJ5Aj1FQDFAAAHAAMJ5Aj1FQDFAAAAAA==.',
['此处']='此处略一万字:BAAALgADCgYJDAAAAA==.',
['步入']='步入黑暗之中:BAAALgADCgEJAQAAAA==.',
['残风']='残风墨月:BAAALgAFFAIJAgAAAA==.',
['毅枚']='毅枚窝窝:BAAALgAECgEJAQAAAA==.',
['毛毛']='毛毛大网红:BAAALgAECgYJCAAAAA==.',
['氷高']='氷高小夜:BAAALgAECgkJDwAAAA==.',
['永生']='永生光头哥:BAAALgAECgEJAQAAAA==.',
['油炸']='油炸糖糕:BAAALgAECgYJBgAAAA==.',
['法神']='法神丶墨梦璃:BAAALgAECgIJAgAAAA==.',
['波澜']='波澜不惊:BAAALgAECgIJAgAAAA==.',
['泪繖']='泪繖星辰:BAAALgAECgEJAQAAAA==.',
['潇洒']='潇洒大少:BAAALgAECgMJAwAAAA==.',
['灬烈']='灬烈焰涂鸦灬:BAAALgAECgQJBAAAAA==.',
['灬獨']='灬獨舞灬:BAAALgAECgYJCgAAAA==.',
['灰烬']='灰烬帝皇:BAAALgADCgcJCAAAAA==.',
['照幽']='照幽:BAAALgAFFAIJAgAAAA==.',
['爱吃']='爱吃鸡蛋饼:BAAALgAECgYJAgAAAA==.',
['爱涵']='爱涵涵最好了:BAAALgADCgMJAwAAAA==.',
['牙膏']='牙膏丶:BAAALgADCgEJAQAAAA==.',
['狂满']='狂满:BAAALgAECgcJBwAAAA==.',
['独孤']='独孤九剑:BAAALgAECgUJBQAAAA==.',
['独翔']='独翔鸟光铸法:BAAALgAECgcJCAAAAA==.',
['王小']='王小美:BAAALgAFFAIJAgAAAA==.',
['瓜牛']='瓜牛:BAAALgAECgUJBQAAAA==.',
['瓦娜']='瓦娜沙:BAAALgAFFAIJAgAAAA==.',
['畸形']='畸形突变体:BAAALgAECgEJAgAAAA==.',
['瞎眼']='瞎眼女孩:BAABLgAFFH8GAAIDAAQJcA6gCQAzAQADAAQJcA6gCQAzAQAAAA==.',
['矮人']='矮人必须死:BAAALgADCgUJAQAAAA==.',
['砍不']='砍不死的怪:BAAALgADCgMJAwAAAA==.',
['祈之']='祈之助:BAAALgAECgcJDQAAAA==.',
['神明']='神明:BAAALgAECgQJBAAAAA==.',
['程橙']='程橙橙丶:BAAALgAECgEJAQAAAA==.',
['糖糖']='糖糖懵懵:BAAALgAECgIJAgAAAA==.',
['絶伦']='絶伦逸羣:BAAALgAECgEJAQAAAA==.',
['红尘']='红尘小宝贝儿:BAAALgAECgQJBgAAAA==.',
['纣虎']='纣虎:BAAALgAECgEJAQAAAA==.',
['绝二']='绝二十一:BAACLgAFFH8PAAMNAAYJCR1PAgBCAgANAAYJCR1PAgBCAgAKAAIJ9BsDEQDBAAAuAAQKfyIAAw0ACQlCIS4DAHUDAA0ACQlCIS4DAHUDAAoAAQkbGQfAAEQAAAAA.',
['绯红']='绯红艾露莎:BAAALgAECgIJAgABLgAFFAYJAQABAAAAAA==.',
['群聚']='群聚:BAAALgAFFAIJAwAAAA==.',
['耐法']='耐法兰圣辉:BAAALgAECgMJAwAAAA==.耐法兰拂尘:BAAALgAECgIJAgAAAA==.耐法兰星陨:BAAALgAFFAIJAgAAAA==.',
['胖彤']='胖彤彤:BAAALgAECgUJBQAAAA==.',
['脆皮']='脆皮蛋卷:BAAALgADCgQJBAAAAA==.',
['腰间']='腰间盘突出:BAABLgAECn8WAAIOAAcJXQ3SoQCUAQAOAAcJXQ3SoQCUAQAAAA==.',
['芒狗']='芒狗:BAAALgAECgYJCgAAAA==.',
['芜菁']='芜菁沙袋:BAAALgAECgEJAQAAAA==.',
['芭比']='芭比柯尤:BAAALgAECgIJAwAAAA==.',
['花与']='花与剑:BAAALgAECgEJAQAAAA==.',
['花落']='花落:BAAALgADCgUJBQAAAA==.',
['苏美']='苏美秋子:BAAALgAECgYJBwAAAA==.',
['若曦']='若曦大坏蛋:BAAALgAECgQJBAAAAA==.',
['英特']='英特纳雄耐尔:BAAALgAECgYJBgAAAA==.',
['草莓']='草莓甜甜圈:BAAALgAECgQJBAAAAA==.',
['落日']='落日余晖:BAAALgAECgIJAgAAAA==.',
['董大']='董大憨:BAAALgAFFAIJAwAAAA==.',
['蓝麟']='蓝麟林林麟:BAAALgAECgEJAgAAAA==.',
['血夜']='血夜:BAACLgAFFH8QAAMLAAUJPiM2AgCVAQALAAUJPiM2AgCVAQAPAAEJAADNEQBkAAAuAAQKfykAAwsACQmsJigAAAIEAAsACQmsJigAAAIEAA8ABwkOIf8PAAwCAAAA.',
['解牛']='解牛斯基:BAAALgAECgYJBgAAAA==.',
['訷話']='訷話丶凹凸曼:BAACLgAFFH8RAAIIAAUJQxdpBQCZAQAIAAUJQxdpBQCZAQAuAAQKfxQAAggACAnYFkJLAAECAAgACAnYFkJLAAECAAAA.訷話丶龙小龙:BAAALgAFFAMJAwAAAA==.',
['请忍']='请忍耐一下:BAAALgAECgUJBgAAAA==.',
['贰丄']='贰丄蛋:BAAALgADCgcJEwAAAA==.',
['贰丅']='贰丅丫:BAAALgAECgIJAgAAAA==.',
['贱骨']='贱骨头:BAAALgAECgUJBQAAAA==.',
['赫利']='赫利俄斯:BAAALgAFFAEJAQAAAA==.',
['赫拉']='赫拉克罗斯:BAAALgADCgUJBQAAAA==.',
['达尔']='达尔文:BAAALgAECgkJBgAAAA==.',
['还是']='还是帕拉丁:BAAALgAECgQJBAAAAA==.',
['逐风']='逐风打尐香:BAAALgAECgQJBQAAAA==.',
['邦桑']='邦桑迪之息:BAAALgAFFAIJAgAAAA==.',
['邪修']='邪修:BAABLgAFFH8GAAMQAAIJtQIxAwA1AAADAAEJOAIJOwA/AAAQAAEJMgMxAwA1AAAAAA==.',
['邪能']='邪能丨马保国:BAAALgAECgYJBwAAAA==.',
['酥糖']='酥糖小蝶:BAAALgAFFAIJAgAAAA==.酥糖蝶姬:BAAALgADCgEJAQAAAA==.',
['银时']='银时:BAAALgAECgUJCQAAAA==.',
['长孙']='长孙忘情:BAABLgAECn8dAAIIAAcJuBfOHABoAQAIAAcJuBfOHABoAQAAAA==.',
['闪电']='闪电咆哮:BAABLgAECn8VAAIRAAYJ2QliKAD8AAARAAYJ2QliKAD8AAAAAA==.',
['阳光']='阳光普照:BAAALgADCgQJBAAAAA==.',
['阿靓']='阿靓妹:BAAALgAECgYJBwAAAA==.',
['雪诺']='雪诺丶:BAAALgAECgQJBQAAAA==.',
['零的']='零的開端:BAAALgAECgEJAQAAAA==.',
['露娜']='露娜:BAAALgAFFAEJAgAAAA==.',
['霸王']='霸王灬霸王:BAAALgAECgYJDQAAAA==.',
['青春']='青春肆意挥洒:BAAALgADCgcJBwAAAA==.',
['颅献']='颅献颅座:BAAALgAFFAIJAwAAAA==.',
['风间']='风间滄月:BAAALgAECgEJAQAAAA==.',
['首席']='首席杏学家:BAACLgAFFH8JAAQSAAMJvA0hBAD5AAASAAMJ8AwhBAD5AAARAAIJNAsuBwCLAAATAAEJHQ8ZIgBQAAAuAAQKfxcAAxIACAmwHEcKAAMCABMABgnzH6YrAAcCABIABwlsGUcKAAMCAAAA.',
['香煙']='香煙燒靈魂:BAAALgAECgYJDAAAAA==.',
['马房']='马房山李现:BAAALgAECgkJCQAAAA==.',
['骨感']='骨感少年:BAAALgAECgUJBQAAAA==.',
['骷髅']='骷髅猎手:BAAALgAECgEJAQAAAA==.',
['魔兽']='魔兽大表哥:BAAALgADCgEJAQAAAA==.',
['鸭梨']='鸭梨山达:BAAALgADCgUJBAAAAA==.',
['黎明']='黎明死星:BAAALgAECgUJBgABLgAFFAQJDQAUAEsLAA==.',
['黑芝']='黑芝麻薯:BAAALgAECgcJDAAAAA==.',
['鼠鼠']='鼠鼠大运营:BAAALgAFFAIJAgAAAA==.',
['龙傲']='龙傲橙:BAAALgAECgQJBAAAAA==.',
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
