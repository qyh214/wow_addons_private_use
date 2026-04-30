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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Priest-Shadow','Mage-Frost','Paladin-Retribution','Paladin-Holy','Warrior-Protection','Evoker-Preservation','Evoker-Augmentation','Warrior-Arms','Hunter-Marksmanship','Hunter-Survival','Monk-Brewmaster','Druid-Restoration','Druid-Balance','Warrior-Fury','Priest-Discipline','Unknown-Unknown','Shaman-Elemental','Shaman-Enhancement','DemonHunter-Devourer','DeathKnight-Unholy','Hunter-BeastMastery','Priest-Holy','Shaman-Restoration','Evoker-Devastation','Druid-Guardian','Druid-Feral','Monk-Mistweaver','DeathKnight-Blood','DeathKnight-Frost','Monk-Windwalker','DemonHunter-Havoc','DemonHunter-Vengeance',}
local provider = {region='CN',realm='银月',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Aken:BAAALgAECgYJCQAAAA==.',
Al='Alize:BAAALgAECgIJAgAAAA==.',
Ar='Arcueid:BAABLgAECn8eAAQBAAgJzxtDQQAJAgABAAYJ+h5DQQAJAgACAAQJRRUtKgAZAQADAAIJehmLGwCYAAAAAA==.',
Au='Aughity:BAAALgAECgcJCQABLgAFFAMJCAAEAKEfAA==.',
Ca='Cameliia:BAAALgAECgQJBAAAAA==.Carolyn:BAAALgAECgEJAQAAAA==.Catelionk:BAACLgAFFH8OAAIFAAQJdxNXCwBZAQAFAAQJdxNXCwBZAQAuAAQKfxgAAgUACAneIHAiAOkCAAUACAneIHAiAOkCAAAA.',
Cp='Cpcianes:BAAALgAFFAEJAgAAAA==.',
Cr='Crisytina:BAAALgAFFAEJAQAAAA==.',
Dr='Drizzle:BAACLgAFFH8HAAIGAAMJZAv1DQD1AAAGAAMJZAv1DQD1AAAuAAQKfx4AAgYACAlxGxQxAF8CAAYACAlxGxQxAF8CAAAA.',
Ev='Evildora:BAAALgAECgYJBgAAAA==.',
Fa='Fal:BAAALgAFFAQJBAABLgAFFAYJEAAFAC4XAA==.Fawzia:BAAALgAECgQJBAAAAA==.',
Fr='Freelancer:BAAALgADCgYJAQAAAA==.',
Fs='Fsugarc:BAAALgAECgcJBwAAAA==.Fsugard:BAAALgAECgkJAgAAAA==.Fsugare:BAAALgAECgkJBgAAAA==.Fsugarj:BAAALgAECgkJCwAAAA==.Fsugarm:BAAALgAECgkJCQAAAA==.Fsugarn:BAAALgAFFAIJAgAAAA==.',
Gq='Gqin:BAAALgAFFAEJAQAAAA==.',
Im='Imbabbq:BAAALgAECgUJBQAAAA==.',
In='Inna:BAACLgAFFH8RAAMHAAQJrx0BBABbAQAHAAQJrx0BBABbAQAGAAIJXQNpKgCIAAAuAAQKfx0AAwcACAnjH3YKAM4CAAcACAnjH3YKAM4CAAYAAQmOJikTAXAAAAAA.',
Ir='Irrelevant:BAAALgAECgYJCgAAAA==.',
Ja='Jasonkim:BAABLgAECn8bAAIIAAcJgxFOGwBwAQAIAAcJgxFOGwBwAQAAAA==.',
Ki='Kiryca:BAAALgADCgIJAgAAAA==.',
Kk='Kkllv:BAABLgAFFH8FAAIEAAUJ/iG6AQABAgAEAAUJ/iG6AQABAgAAAA==.',
Kl='Klluvv:BAAALgAFFAYJAwAAAA==.',
Li='Lianwa:BAAALgAECgIJAgAAAA==.Lightsworn:BAAALgAECgkJCQAAAA==.',
Lo='Lovngd:BAAALgADCgEJAQAAAA==.',
Ma='Makinami:BAAALgAECgYJBgAAAA==.',
Me='Memorecool:BAAALgAECgQJBAAAAA==.',
Mi='Miakhalifa:BAAALgAECgQJBAAAAA==.',
Mo='Mousse:BAAALgAECgUJBQAAAA==.',
Mu='Muens:BAAALgAECgYJBwAAAA==.',
Pl='Plague:BAAALgADCgUJBQAAAA==.',
Po='Powas:BAAALgAECgYJBgAAAA==.',
Qo='Qoqosfn:BAACLgAFFH8FAAIJAAIJ2hrPEAC2AAAJAAIJ2hrPEAC2AAAuAAQKfxQAAwkABwkGI0YIALYCAAkABwkGI0YIALYCAAoABglgGEMjAKMBAAAA.',
Ra='Radint:BAABLgAFFH8FAAILAAMJFhs/AgAeAQALAAMJFhs/AgAeAQAAAA==.',
Rp='Rpoon:BAABLgAECn8WAAMMAAcJMyTJDADfAgAMAAcJMyTJDADfAgANAAEJHw4wLgA5AAAAAA==.Rpwarrior:BAAALgAECgIJAgAAAA==.',
Sa='Samu:BAAALgADCgYJBgAAAA==.',
Sc='Schneeh:BAAALgADCgEJAQAAAA==.',
Sh='Shzh:BAAALgAECgYJBQAAAA==.',
Sy='Sycshark:BAABLgAFFH8IAAIOAAIJ6h7dDQCwAAAOAAIJ6h7dDQCwAAAAAA==.',
Ta='Taren:BAAALgADCgcJBwABLgAFFAUJEQAEAIwhAA==.',
Te='Teafa:BAAALgADCggJCAAAAA==.',
Vl='Vl:BAAALgAECgIJAgAAAA==.',
Zl='Zlatan:BAABLgAFFH8GAAIKAAYJhxdGAQDHAQAKAAYJhxdGAQDHAQAAAA==.',
['一只']='一只小树熊:BAAALgADCgcJBwAAAA==.',
['一梦']='一梦幽兰池:BAAALgAECgMJBQAAAA==.',
['一片']='一片乌云:BAAALgAECgYJBwAAAA==.',
['七月']='七月的疯狂:BAAALgAECgcJBwAAAA==.',
['三修']='三修:BAAALgAECgYJEAAAAA==.',
['三分']='三分恶气:BAAALgAECgcJBwAAAA==.',
['三十']='三十六蹄:BAAALgAECgMJAwAAAA==.',
['上帝']='上帝守护者:BAAALgAFFAIJAwAAAA==.',
['下班']='下班了:BAAALgAFFAYJBAAAAA==.',
['不似']='不似少年游:BAAALgAECgIJAwAAAA==.',
['不想']='不想玩:BAAALgAFFAYJAgAAAA==.',
['不要']='不要点我名:BAACLgAFFH8JAAIPAAMJBSVbBQBHAQAPAAMJBSVbBQBHAQAuAAQKfx8AAw8ABwnZJb0BAOUCAA8ABwnZJb0BAOUCABAAAQnGG6t7ADoAAAAA.',
['丛林']='丛林之魂:BAAALgADCgcJBwAAAA==.',
['东方']='东方丶树叶:BAABLgAFFH8FAAIRAAIJ/BztFgCuAAARAAIJ/BztFgCuAAAAAA==.',
['丨灵']='丨灵狐丨:BAAALgAFFAIJAwAAAA==.',
['中月']='中月:BAAALgADCgIJAgAAAA==.',
['临临']='临临的小骑士:BAAALgADCgYJBgAAAA==.',
['丶融']='丶融化:BAABLgAFFH8IAAIFAAQJNQ1HHQBWAQAFAAQJNQ1HHQBWAQAAAA==.',
['乌丨']='乌丨鸦:BAAALgAECgYJCQAAAA==.',
['乖乖']='乖乖的小猪:BAAALgADCgIJAgABLgAFFAQJEAASADciAA==.',
['九星']='九星毒奶:BAAALgAECgcJBwABLgAFFAcJBAATAAAAAA==.',
['云出']='云出无心:BAAALgAFFAQJBAAAAA==.',
['云梦']='云梦之南:BAAALgADCgMJAwAAAA==.',
['亚当']='亚当简森:BAAALgAECgYJBgAAAA==.',
['亲一']='亲一口上床:BAAALgAECgEJAQAAAA==.',
['人一']='人一大:BAAALgAFFAIJAgAAAA==.',
['人间']='人间一两风:BAAALgADCgYJBgAAAA==.',
['今夜']='今夜月色甚美:BAAALgADCgYJBgAAAA==.今夜月色真美:BAAALgADCgcJBwAAAA==.',
['以德']='以德服伊:BAAALgADCgIJAgAAAA==.',
['伊蕾']='伊蕾娜:BAAALgAECgYJAwAAAA==.',
['伊路']='伊路米:BAAALgADCgEJAQAAAA==.',
['伍岚']='伍岚正:BAAALgADCgYJBgAAAA==.',
['休得']='休得胡言:BAAALgAECgIJAgAAAA==.',
['何意']='何意味:BAABLgAFFH8QAAIFAAUJXheWHABZAQAFAAUJXheWHABZAQABLgAFFAYJEAAFAC4XAA==.',
['你在']='你在教我做事:BAAALgAECgEJAQAAAA==.',
['你才']='你才是奶龙丶:BAAALgAECgYJDgAAAA==.',
['你放']='你放老子一马:BAAALgAECgEJAgAAAA==.',
['你条']='你条捻样:BAAALgAECgUJBQAAAA==.',
['你若']='你若盛开:BAAALgADCgMJAwAAAA==.',
['你还']='你还没准备好:BAAALgAECgcJBwAAAA==.',
['俺也']='俺也惊铃:BAAALgAECgcJBwAAAA==.',
['傲雨']='傲雨:BAAALgAECgUJBQAAAA==.',
['僑風']='僑風:BAABLgAECn8kAAQCAAcJYSRbEADMAQABAAYJUyDnRgD2AQACAAUJiyJbEADMAQADAAIJMQUvLQBEAAAAAA==.',
['元丶']='元丶神:BAACLgAFFH8OAAIUAAQJMxi9AwBGAQAUAAQJMxi9AwBGAQAuAAQKfxgAAxQACQlYHXwNAMkCABQACQlYHXwNAMkCABUAAwlGBXAkAJEAAAAA.',
['元素']='元素葱击:BAAALgAECgcJAQAAAA==.',
['光铸']='光铸伊瑞尔:BAABLgAECn8cAAIGAAgJcw+KXADNAQAGAAgJcw+KXADNAQAAAA==.',
['兔抱']='兔抱鼠:BAAALgADCggJCgAAAA==.',
['六分']='六分文艺范:BAABLgAECn8cAAIWAAgJhBMKQQDwAQAWAAgJhBMKQQDwAQAAAA==.',
['六神']='六神风油精:BAAALgAECgIJAwAAAA==.',
['六翼']='六翼:BAAALgAECgUJCAAAAA==.',
['兰黎']='兰黎:BAACLgAFFH8IAAMQAAMJwBIpDgD9AAAQAAMJwBIpDgD9AAAPAAIJNAeFHgCCAAAuAAQKfxwAAxAABwmjHncVAGQCABAABwmjHncVAGQCAA8AAQlsFOfYACgAAAAA.',
['其实']='其实一兮:BAAALgAECgYJEAAAAA==.',
['冉懒']='冉懒:BAAALgAECgYJBwAAAA==.',
['冰柠']='冰柠:BAAALgADCgEJAgAAAA==.',
['冰霜']='冰霜灾祸:BAAALgAECgYJCgAAAA==.',
['冷月']='冷月弯弯:BAACLgAFFH8QAAIOAAQJQh8kBQCDAQAOAAQJQh8kBQCDAQAuAAQKfxYAAg4ABwlQIMofAAQCAA4ABwlQIMofAAQCAAAA.冷月雪夜:BAAALgADCgEJAQAAAA==.',
['几点']='几点下班:BAABLgAFFH8FAAIBAAUJkhgqBQDMAQABAAUJkhgqBQDMAQAAAA==.',
['刘二']='刘二:BAAALgADCgYJBwAAAA==.',
['判官']='判官:BAAALgAECgcJDQAAAA==.',
['創造']='創造與毀滅:BAAALgAECgIJAgAAAA==.',
['北天']='北天:BAAALgADCgYJBwAAAA==.',
['千魂']='千魂之唤:BAAALgADCgMJAwAAAA==.',
['半醒']='半醒半梦之间:BAAALgAECgcJCQAAAA==.',
['单曲']='单曲循环:BAAALgADCgYJBgAAAA==.',
['单眼']='单眼皮家秋:BAAALgAECgUJBgAAAA==.',
['南瓜']='南瓜焖番薯:BAAALgAFFAEJAQAAAA==.南瓜瓜:BAAALgAECgcJBwAAAA==.',
['卧槽']='卧槽你好:BAAALgADCgUJBQAAAA==.',
['卿卿']='卿卿丶:BAABLgAFFH8HAAIWAAUJwgBaGAAMAQAWAAUJwgBaGAAMAQAAAA==.卿卿丷:BAAALgAFFAMJAwAAAA==.',
['厄尔']='厄尔庇斯:BAAALgAECgYJBgAAAA==.',
['双之']='双之哀伤:BAAALgAECgEJAwAAAA==.',
['双魚']='双魚理:BAAALgAFFAQJAgABLgAFFAYJCwAFAMUbAA==.',
['叮起']='叮起来的圣光:BAAALgAECgEJAQAAAA==.',
['叶瞬']='叶瞬光:BAABLgAECn8gAAIXAAkJXx7UCwA8AwAXAAkJXx7UCwA8AwAAAA==.',
['叶问']='叶问贰:BAAALgAECgQJBAAAAA==.',
['叼叶']='叼叶子当烟抽:BAAALgAECgIJAgAAAA==.',
['吹了']='吹了一夜风:BAAALgAECgYJBgAAAA==.',
['呆呆']='呆呆鸟:BAAALgAFFAIJBAAAAA==.',
['和丶']='和丶大人:BAAALgAECgQJAwAAAA==.',
['咕喵']='咕喵熊:BAAALgADCgcJDAAAAA==.',
['咕小']='咕小啵:BAABLgAECn8UAAIBAAcJkR+xJQB8AgABAAcJkR+xJQB8AgAAAA==.',
['哈啾']='哈啾:BAAALgAECgQJCgAAAA==.',
['哈黎']='哈黎露雅:BAAALgAECgcJBwAAAA==.',
['哎呦']='哎呦呦:BAAALgAECgQJBQAAAA==.',
['哼哼']='哼哼大魔王:BAAALgAECgMJAwAAAA==.',
['啊牛']='啊牛:BAAALgAECgYJBwAAAA==.',
['喝好']='喝好就行:BAAALgAECgYJBgAAAA==.',
['嗜血']='嗜血丨追影:BAAALgAECgYJDgAAAA==.',
['嗯哼']='嗯哼丶:BAAALgAECgMJAwAAAA==.',
['四大']='四大威慑:BAAALgAECgYJBgAAAA==.',
['四季']='四季奶青:BAAALgAECgQJBQAAAA==.',
['圣光']='圣光之皿:BAAALgAECgEJAwAAAA==.圣光银灰:BAAALgAECgcJCgAAAA==.',
['埃辛']='埃辛烈焰:BAAALgAECgEJAgAAAA==.',
['堕落']='堕落训兽者:BAABLgAECn8iAAIYAAgJjiFODADeAgAYAAgJjiFODADeAgAAAA==.',
['塞伦']='塞伦涅丶银月:BAAALgAECgQJBAAAAA==.',
['增强']='增强萨:BAAALgAECggJEQAAAA==.',
['墨娅']='墨娅德琳:BAAALgAECgYJBwAAAA==.',
['墨石']='墨石翁:BAAALgAFFAIJAwAAAA==.',
['夏乌']='夏乌拉:BAABLgAECn8VAAIZAAcJlCI1CgCqAgAZAAcJlCI1CgCqAgAAAA==.',
['大愛']='大愛無悔:BAAALgAECgcJCgAAAA==.',
['天堂']='天堂之拳:BAAALgAECgYJBgAAAA==.',
['头铁']='头铁:BAAALgAECggJCAAAAA==.',
['奶妈']='奶妈心跳加速:BAAALgAECgEJAQAAAA==.',
['妈咪']='妈咪爱:BAAALgAECgcJBwAAAA==.',
['妙龄']='妙龄尼姑:BAAALgAECgcJBwAAAA==.妙龄师太:BAAALgAECgIJAgAAAA==.',
['妥妥']='妥妥:BAAALgADCgEJAQAAAA==.',
['姬天']='姬天晴:BAAALgAECgUJBQAAAA==.',
['孤独']='孤独的旅行者:BAAALgAECgIJAwAAAA==.',
['宁汐']='宁汐:BAAALgAFFAIJBAAAAA==.',
['安格']='安格莉絲塔:BAAALgAECgEJAQAAAA==.',
['完美']='完美身形丶:BAAALgADCgYJBgAAAA==.',
['宜刺']='宜刺猹:BAAALgAFFAIJAwAAAA==.',
['容颜']='容颜易老:BAABLgAECn8VAAMGAAgJix9VHQC7AgAGAAgJix9VHQC7AgAHAAYJBQx0VQAlAQAAAA==.',
['小妞']='小妞妞婷:BAAALgADCgEJAQAAAA==.',
['小懒']='小懒虫:BAABLgAFFH8NAAISAAUJpBUwBACtAQASAAUJpBUwBACtAQAAAA==.',
['小泡']='小泡沫:BAAALgAECgYJBwAAAA==.',
['小疯']='小疯残月丶:BAAALgAECgEJAQAAAA==.',
['小芽']='小芽狐:BAAALgAECgMJAwAAAA==.',
['小西']='小西米呀:BAAALgAECgMJAwAAAA==.',
['小超']='小超灬:BAACLgAFFH8HAAIUAAQJBAudDAAkAQAUAAQJBAudDAAkAQAuAAQKfxQAAxQABwlJFrUrALoBABQABwlJFrUrALoBABoABglTFWxMAFEBAAAA.',
['小龙']='小龙女:BAAALgADCgcJCAAAAA==.',
['工具']='工具人古二蛋:BAAALgAECgUJBQAAAA==.',
['巨蟹']='巨蟹阳阳哈:BAAALgADCgIJAgAAAA==.',
['希爾']='希爾瓦娜澌:BAABLgAECn8ZAAIEAAgJ3hTeCQB1AQAEAAgJ3hTeCQB1AQAAAA==.',
['幻影']='幻影无名:BAAALgAECgEJAQAAAA==.幻影烟火:BAAALgAECgEJAQAAAA==.幻影神奇:BAAALgAECgEJAQAAAA==.',
['异达']='异达:BAAALgAECgUJBQAAAA==.',
['张宗']='张宗轩:BAABLgAFFH8FAAMHAAIJRhUWCwCgAAAHAAIJRhUWCwCgAAAGAAIJXg1IKACXAAAAAA==.',
['张罗']='张罗地:BAACLgAFFH8JAAQJAAMJwQvuEgCVAAAJAAIJhQ3uEgCVAAAKAAMJ/wbMEQCPAAAbAAIJPwWWAwBKAAAuAAQKfxQABBsABwmYHVcMABUCABsABwnSHFcMABUCAAkABQkxE2knADkBAAoAAgkNEiNQAIwAAAAA.',
['张馨']='张馨宇:BAAALgAECgYJCwAAAA==.',
['强大']='强大的圣骑:BAABLgAFFH8IAAIGAAMJNiLmDgAyAQAGAAMJNiLmDgAyAQAAAA==.',
['御天']='御天霜:BAAALgADCgMJAwAAAA==.',
['德得']='德得哋:BAAALgAECgIJAgAAAA==.',
['心爱']='心爱的小摩托:BAAALgAECgUJBQAAAA==.',
['忧郁']='忧郁咖啡色:BAAALgAECgYJEAAAAA==.',
['恰合']='恰合味:BAAALgADCgEJAQAAAA==.',
['恶灵']='恶灵退散:BAAALgAECgEJAQAAAA==.',
['悟心']='悟心:BAAALgAECgcJCwAAAA==.',
['惩戒']='惩戒汤姆:BAAALgAECgUJBgABLgAECgYJBgATAAAAAA==.',
['想流']='想流浪的猫:BAAALgAFFAQJBAAAAA==.',
['想睡']='想睡觉:BAAALgAFFAYJBAAAAA==.',
['想要']='想要皮肤:BAAALgAECgEJAQAAAA==.',
['愛冰']='愛冰:BAAALgAECgUJBQAAAA==.',
['慢热']='慢热:BAAALgAFFAIJAwAAAA==.',
['我要']='我要打五个:BAAALgAECgEJAQAAAA==.',
['我还']='我还没睡饱:BAAALgAECgEJAQAAAA==.',
['战歌']='战歌:BAAALgAECgYJBgAAAA==.',
['打不']='打不过即加入:BAAALgAECgQJBAAAAA==.打不过就加入:BAAALgAECgYJBgAAAA==.',
['托莉']='托莉那:BAAALgAECgEJAQAAAA==.',
['执夷']='执夷丶:BAAALgAECgIJAgAAAA==.',
['扶她']='扶她大姐姐:BAAALgAFFAEJAQABLgAFFAIJAwATAAAAAA==.',
['拂晓']='拂晓之前:BAAALgAECgYJDAAAAA==.',
['拉斐']='拉斐尔:BAAALgAECgYJDQAAAA==.',
['敕魔']='敕魔諦聽:BAAALgAECgkJEAAAAA==.',
['文艺']='文艺复兴:BAAALgADCgUJBQAAAA==.',
['文野']='文野亚弥:BAAALgAECgYJBgABLgAFFAIJBAATAAAAAA==.',
['斑木']='斑木芙兰:BAAALgAECgYJCAAAAA==.',
['斩之']='斩之煞:BAAALgADCgEJAQAAAA==.',
['新塘']='新塘吊那星:BAABLgAFFH8LAAIFAAQJtxsdEwB/AQAFAAQJtxsdEwB/AQAAAA==.',
['施巴']='施巴拉古大师:BAAALgAECgEJAQAAAA==.',
['早安']='早安晚安:BAAALgAFFAQJAgAAAA==.',
['时丶']='时丶雨:BAAALgAECgQJBQAAAA==.',
['时间']='时间停滞的鱼:BAAALgADCgEJAQAAAA==.',
['明朝']='明朝别离:BAAALgAECgEJAQAAAA==.',
['星期']='星期七七:BAAALgAECgQJBQAAAA==.',
['星灵']='星灵移位:BAAALgAFFAIJAgAAAA==.',
['星见']='星见雅:BAABLgAECn8VAAIXAAkJrRVKHgBFAQAXAAkJrRVKHgBFAQAAAA==.',
['普罗']='普罗修斯卡:BAAALgAECgYJCAAAAA==.',
['暗夜']='暗夜无影箭:BAAALgADCgEJAQAAAA==.暗夜黎明:BAAALgADCgcJBwAAAA==.',
['暗影']='暗影邪典:BAAALgADCgYJCwAAAA==.',
['曼妥']='曼妥斯:BAABLgAECn8ZAAMcAAcJ4x6eCQAGAgAdAAYJ5B8ZCgArAgAcAAcJ+RueCQAGAgAAAA==.',
['最美']='最美德:BAAALgAECgIJAwAAAA==.',
['月下']='月下小萌:BAAALgAECgQJBAAAAA==.',
['月灵']='月灵银羽:BAABLgAECn8cAAMYAAkJyhT8EQCoAgAYAAkJyhT8EQCoAgAMAAcJPAa7TAAeAQAAAA==.',
['月落']='月落乌啼:BAAALgAFFAEJAQAAAA==.',
['有了']='有了:BAAALgAFFAQJBAABLgAFFAYJEAAFAC4XAA==.',
['有人']='有人悄咪咪的:BAAALgADCgMJAwAAAA==.',
['有德']='有德医:BAAALgAECgQJBAAAAA==.',
['有意']='有意见你就说:BAAALgAECgEJAgAAAA==.',
['朔夜']='朔夜:BAAALgAECgIJAgAAAA==.',
['木文']='木文:BAAALgAFFAEJAQAAAA==.',
['木易']='木易战:BAABLgAFFH8IAAIIAAMJQg5aCADSAAAIAAMJQg5aCADSAAAAAA==.',
['术丨']='术丨卡多雷:BAAALgAECgMJAwAAAA==.',
['朴智']='朴智炫:BAAALgAECgcJCgABLgAECggJDwATAAAAAA==.',
['杀心']='杀心成焚:BAAALgAECgYJBgAAAA==.',
['李政']='李政宰:BAAALgAECggJDwAAAA==.',
['李法']='李法拉:BAAALgADCgUJBwAAAA==.',
['杰佛']='杰佛里斯:BAAALgAECgcJDQAAAA==.',
['松松']='松松充电宝:BAAALgAECgcJBwAAAA==.',
['枪爷']='枪爷:BAAALgAECgEJAQAAAA==.',
['柒七']='柒七灬:BAAALgAECgEJAQAAAA==.',
['柒丶']='柒丶:BAAALgAECgQJBAAAAA==.',
['柒哥']='柒哥:BAAALgAECgUJBQAAAA==.',
['柚柚']='柚柚冰美式:BAAALgAECgcJBwAAAA==.',
['桑尼']='桑尼丶:BAABLgAECn8uAAIXAAkJ7SG1AAAmAwAXAAkJ7SG1AAAmAwAAAA==.',
['梅蒂']='梅蒂恩:BAAALgAECgcJDAAAAA==.',
['梵圣']='梵圣真魔功:BAAALgAECgYJAQAAAA==.',
['槍丶']='槍丶菽:BAAALgAECgUJBQAAAA==.',
['樟脑']='樟脑:BAAALgAECgcJBwAAAA==.',
['橘生']='橘生淮南:BAAALgAECgEJAQABLgAFFAQJBAATAAAAAA==.',
['橙佩']='橙佩斯:BAAALgAECgYJBgAAAA==.',
['橙子']='橙子不咕:BAAALgAFFAIJAgABLgAFFAMJBgAeAJIMAA==.',
['橙某']='橙某有些拳脚:BAABLgAFFH8GAAIeAAMJkgyiDADaAAAeAAMJkgyiDADaAAAAAA==.',
['歌兰']='歌兰蒂斯:BAAALgAECgYJCQAAAA==.',
['死亡']='死亡贱圣:BAABLgAECn8VAAMXAAcJ9wcVswAcAQAXAAYJvQgVswAcAQAfAAEJGAQhSwAgAAAAAA==.',
['殷红']='殷红丶迷雾:BAAALgAECgEJAgAAAA==.',
['毛胖']='毛胖球:BAAALgAFFAQJBAABLgAFFAUJKgASAP8kAA==.',
['水平']='水平如镜:BAAALgADCgYJBgAAAA==.',
['水甚']='水甚:BAAALgAECgQJBQAAAA==.',
['永恒']='永恒长夜:BAAALgAECgQJBAAAAA==.',
['汪丶']='汪丶汪汪:BAAALgAECgYJAQAAAA==.',
['汪欢']='汪欢欢:BAAALgADCgEJAQAAAA==.',
['没了']='没了:BAAALgAFFAQJBAAAAA==.',
['沧然']='沧然回眸:BAABLgAECn8cAAIHAAgJbyGgBwDzAgAHAAgJbyGgBwDzAgAAAA==.',
['法尔']='法尔窃:BAAALgAECgQJBwAAAA==.',
['泛羽']='泛羽眠风:BAAALgAECgEJAQAAAA==.',
['洛颉']='洛颉:BAABLgAECn8cAAIFAAgJjCAVCwAbAgAFAAgJjCAVCwAbAgAAAA==.',
['津島']='津島善子:BAAALgAECgEJAQAAAA==.',
['流风']='流风漫步:BAAALgAECgcJBwAAAA==.',
['涩刁']='涩刁馋:BAAALgAECgMJBAAAAA==.',
['混沌']='混沌出羊刀:BAAALgAECgQJBQAAAA==.',
['清风']='清风扶柳:BAAALgAECgYJDQAAAA==.',
['温柔']='温柔性感小妈:BAAALgAECgMJBgAAAA==.',
['满满']='满满元气:BAACLgAFFH8JAAIXAAQJFRstDAB0AQAXAAQJFRstDAB0AQAuAAQKfxYAAhcACAkOHM4uAH0CABcACAkOHM4uAH0CAAAA.',
['滴匹']='滴匹诶丝:BAAALgAECgYJBgAAAA==.',
['漂泊']='漂泊沉沦:BAAALgAFFAQJBAAAAA==.漂泊雷尔:BAAALgAFFAQJAgAAAA==.',
['演帝']='演帝威叔:BAAALgAECgMJAgAAAA==.',
['火力']='火力发电机:BAAALgAECgEJAQAAAA==.',
['火花']='火花骑士可莉:BAAALgAECgYJBgAAAA==.',
['灬小']='灬小超:BAAALgAECgYJBgAAAA==.',
['灭境']='灭境邪晶灵:BAAALgAECgcJEgAAAA==.',
['灰灰']='灰灰:BAABLgAFFH8FAAIWAAIJ0xaAJQCpAAAWAAIJ0xaAJQCpAAAAAA==.',
['灶门']='灶门祢豆子:BAAALgAECgMJAwAAAA==.',
['炖咸']='炖咸鱼:BAABLgAECn8ZAAQdAAgJFhy5AQABAgAdAAgJFhy5AQABAgAPAAQJDw0djwCzAAAcAAEJwgduNgAcAAAAAA==.',
['烏一']='烏一鴉:BAAALgAECgIJAQAAAA==.',
['烛照']='烛照:BAAALgAFFAQJBAAAAA==.',
['烛阴']='烛阴:BAAALgAFFAIJAgAAAA==.',
['热热']='热热丶:BAAALgAFFAYJAgAAAA==.',
['焦糖']='焦糖奶昔:BAAALgAECgEJAQAAAA==.',
['熊掌']='熊掌蹲土豆:BAAALgAFFAEJAQAAAA==.',
['爆了']='爆了:BAAALgAECgYJBwAAAA==.',
['爱吃']='爱吃青苹果:BAAALgAECgEJAQAAAA==.',
['爱灬']='爱灬珍惜的我:BAAALgAECgEJAQAAAA==.',
['牙擦']='牙擦擦滴一枪:BAAALgAECgYJBgABLgAFFAcJHAAFAKwbAA==.',
['犯困']='犯困嫌疑人:BAABLgAFFH8QAAIFAAYJLhfcGQBjAQAFAAYJLhfcGQBjAQAAAA==.',
['狼牙']='狼牙三五壮士:BAAALgADCgYJCAAAAA==.',
['猎杀']='猎杀潜行:BAAALgADCgYJBgAAAA==.',
['猎焱']='猎焱:BAAALgAECgMJAwAAAA==.',
['猫小']='猫小胖:BAABLgAFFH8IAAISAAQJZyTgAwC2AQASAAQJZyTgAwC2AQAAAA==.',
['猫过']='猫过喵声丶:BAABLgAFFH8FAAIGAAIJfgwoJgCeAAAGAAIJfgwoJgCeAAAAAA==.',
['王家']='王家秋:BAAALgAECgYJDAAAAA==.',
['玖柒']='玖柒:BAACLgAFFH8HAAIHAAIJPRsmEwCsAAAHAAIJPRsmEwCsAAAuAAQKfxQAAwcABwnRErFBAHEBAAcABwnRErFBAHEBAAYAAwk9DIgHAYgAAAAA.',
['玛圣']='玛圣:BAAALgAECgQJBAAAAA==.',
['珠珠']='珠珠:BAAALgAECgMJBAAAAA==.珠珠小可爱:BAAALgAECgIJAgAAAA==.',
['璎錵']='璎錵:BAABLgAECn8bAAIRAAgJEh+IBAAOAgARAAgJEh+IBAAOAgAAAA==.',
['璐鸣']='璐鸣:BAACLgAFFH8IAAMKAAMJthJhCwDwAAAKAAMJthJhCwDwAAAbAAEJ2gWqCgBPAAAuAAQKfxgABAoABgk5HModANcBAAoABgk5HModANcBABsABgnNDlEfADMBAAkAAQk3BmlJADAAAAAA.',
['生煎']='生煎包:BAAALgAECgUJBwAAAA==.',
['番薯']='番薯仔:BAAALgAECgIJAgAAAA==.',
['疯丫']='疯丫頭:BAAALgADCgYJBgAAAA==.',
['瘦益']='瘦益:BAAALgAFFAEJAQAAAA==.',
['看我']='看我干嘛上啊:BAAALgAECgEJAQAAAA==.',
['睡觉']='睡觉:BAAALgAFFAYJAQAAAA==.睡觉了:BAAALgAFFAYJBAAAAA==.',
['礼拜']='礼拜三:BAAALgADCgQJBAAAAA==.',
['神圣']='神圣帕拉丁:BAAALgAECgQJBQAAAA==.',
['神神']='神神化化:BAAALgAECgMJAwAAAA==.',
['神龙']='神龙女:BAABLgAECn8UAAIFAAYJvhTfpwCKAQAFAAYJvhTfpwCKAQAAAA==.',
['祸斗']='祸斗:BAAALgAECgkJCQAAAA==.',
['禁神']='禁神:BAAALgAFFAEJAQAAAA==.',
['私享']='私享品德:BAAALgAECgUJBgAAAA==.',
['科迈']='科迈罗:BAAALgADCgEJAQAAAA==.',
['程艾']='程艾影:BAAALgAECgEJAQAAAA==.',
['穆德']='穆德里克:BAAALgADCgUJBQAAAA==.',
['穷奇']='穷奇:BAAALgAECgkJAwAAAA==.',
['穿阵']='穿阵:BAAALgAECgYJCgAAAA==.',
['窝腰']='窝腰燕排:BAAALgAECgYJCQAAAA==.',
['第一']='第一聪明可爱:BAAALgAECgYJBgAAAA==.',
['粉肜']='粉肜嘬嘬:BAAALgAECgcJBwAAAA==.',
['粉色']='粉色体育生:BAAALgAECgIJBQAAAA==.',
['素前']='素前小鬼:BAABLgAFFH8KAAIBAAQJqCKVCQCSAQABAAQJqCKVCQCSAQAAAA==.',
['紫叶']='紫叶歌:BAABLgAECn8WAAIYAAgJ6gW2QwChAQAYAAgJ6gW2QwChAQAAAA==.',
['紫电']='紫电青霜:BAAALgAECgYJDAAAAA==.',
['紫藤']='紫藤花雨:BAAALgAECgMJAwAAAA==.',
['絮云']='絮云:BAAALgAECgUJAwAAAA==.',
['絶鈑']='絶鈑籹孖:BAAALgAECgYJCgAAAA==.',
['繁星']='繁星丶点:BAAALgAECgEJAQAAAA==.',
['繁花']='繁花落尽時丨:BAAALgAECgcJDwAAAA==.',
['红丝']='红丝手:BAAALgAECgEJAQAAAA==.',
['红墙']='红墙白雪:BAAALgAECgYJBgAAAA==.',
['红手']='红手督军:BAAALgAECggJEwABLgAFFAYJEwAIAOMJAA==.',
['绀羽']='绀羽:BAAALgAECgYJBwAAAA==.',
['给大']='给大家整个活:BAAALgAECgQJBAAAAA==.',
['维纳']='维纳尔光血:BAAALgAECgEJAQABLgAFFAQJCgAFAHQMAA==.',
['绿豆']='绿豆芽:BAAALgAECgEJAQABLgAECgkJEAATAAAAAA==.',
['缇坦']='缇坦妮雅:BAAALgAECgEJAQAAAA==.',
['罗斯']='罗斯柴尔德:BAAALgADCgMJAwAAAA==.',
['罗薇']='罗薇娜:BAAALgAECgYJBwAAAA==.',
['老衲']='老衲法号不奶:BAAALgAECgEJAQAAAA==.',
['耶律']='耶律辽哥:BAAALgAFFAIJBAAAAA==.',
['耶梦']='耶梦加德:BAAALgADCgEJAQAAAA==.',
['聖骑']='聖骑士:BAAALgAECgQJBgAAAA==.',
['肆德']='肆德:BAABLgAECn8aAAMcAAgJJQZMCgChAAAcAAgJJQZMCgChAAAPAAEJGAWo1gAqAAAAAA==.',
['肥益']='肥益:BAABLgAFFH8JAAIaAAQJ6w6tCQA3AQAaAAQJ6w6tCQA3AQAAAA==.',
['胡大']='胡大贰:BAABLgAECn8dAAIGAAcJAhEXcwCVAQAGAAcJAhEXcwCVAQAAAA==.',
['脆脆']='脆脆的猫耳朵:BAAALgAECgQJBAAAAA==.',
['膜片']='膜片钳:BAAALgAECgQJAQAAAA==.',
['色遍']='色遍天下:BAAALgAECgUJCgAAAA==.',
['艾莎']='艾莎美如画:BAABLgAECn8lAAMbAAkJFRzOBgCEAgAKAAkJrRWADACtAgAbAAkJORrOBgCEAgAAAA==.',
['芒果']='芒果巧乐兹:BAAALgAECgYJBgAAAA==.',
['苍炎']='苍炎的轨迹:BAAALgAECgkJCQAAAA==.',
['苏东']='苏东坡:BAABLgAFFH8HAAIBAAMJ1ga1PACYAAABAAMJ1ga1PACYAAAAAA==.',
['苏锦']='苏锦浅清颜:BAAALgAECgcJEQAAAA==.',
['英勇']='英勇灵魂连接:BAAALgADCgYJBgAAAA==.',
['茅台']='茅台:BAAALgAECgQJBAAAAA==.',
['茶兀']='茶兀:BAAALgAECgEJAwAAAA==.',
['莓果']='莓果巧乐兹:BAAALgADCgIJAgAAAA==.',
['菲奥']='菲奥拉:BAACLgAFFH8JAAIGAAQJexe1CgBWAQAGAAQJexe1CgBWAQAuAAQKfxUAAgYABwkyHEtMAP4BAAYABwkyHEtMAP4BAAAA.',
['萌妞']='萌妞:BAAALgAECgQJBgAAAA==.',
['萝冠']='萝冠灵狐:BAAALgAECgEJAQAAAA==.',
['落然']='落然霜痕:BAAALgAECgEJAQAAAA==.',
['落闸']='落闸:BAAALgAECgQJBQAAAA==.',
['董公']='董公寺:BAAALgAECgEJAQAAAA==.',
['蒂兰']='蒂兰:BAAALgADCgEJAQAAAA==.',
['蓝德']='蓝德:BAABLgAFFH8HAAIXAAIJviKnNgCuAAAXAAIJviKnNgCuAAAAAA==.',
['蓝色']='蓝色鸟:BAAALgAECgYJBgAAAA==.',
['蓬尾']='蓬尾狐:BAAALgAECgEJAQAAAA==.',
['蓬莱']='蓬莱山辉夜:BAAALgAECgEJAgAAAA==.',
['蔯肆']='蔯肆肆:BAACLgAFFH8IAAMXAAIJtSAIMgDBAAAXAAIJtSAIMgDBAAAgAAIJAw98AwClAAAuAAQKfxgAAhcABwkFJYcbANgCABcABwkFJYcbANgCAAAA.',
['蔯酒']='蔯酒酒:BAAALgADCgcJBwAAAA==.',
['藏丶']='藏丶马:BAAALgADCgcJBwAAAA==.',
['蛋卷']='蛋卷大人:BAAALgAECgMJAwAAAA==.',
['血炎']='血炎丨冰瞳:BAAALgAECgYJBwAAAA==.',
['被月']='被月亮偷走啦:BAAALgADCgUJBQAAAA==.',
['袭人']='袭人:BAAALgAECgEJAQAAAA==.',
['裂您']='裂您:BAAALgAFFAEJAQAAAA==.',
['西小']='西小米呀:BAAALgADCgUJBQAAAA==.西小米哟:BAAALgAECgQJBAAAAA==.',
['西瓜']='西瓜瓜呀:BAAALgAECgUJBwAAAA==.',
['要来']='要来一杯么:BAAALgADCgcJAgABLgAECgEJAQATAAAAAA==.',
['要死']='要死的鱼:BAAALgADCgEJAQAAAA==.',
['訫韵']='訫韵:BAAALgAECgEJAQAAAA==.',
['諦听']='諦听:BAABLgAFFH8GAAIGAAQJ4QyYDgA1AQAGAAQJ4QyYDgA1AQAAAA==.',
['豆奶']='豆奶:BAAALgADCgMJAwAAAA==.',
['豌豆']='豌豆芽:BAAALgAECgMJAgABLgAECgkJEAATAAAAAA==.',
['走医']='走医保吗壮士:BAAALgAECgcJBwAAAA==.',
['车厘']='车厘子喲:BAABLgAECn8dAAMXAAYJlBmvKAASAQAXAAUJBR6vKAASAQAfAAEJ0AexSQAkAAAAAA==.',
['转生']='转生真龙:BAAALgADCgEJAQAAAA==.',
['辉光']='辉光波影:BAAALgAECgEJAQAAAA==.',
['输出']='输出不如卖萌:BAAALgAECgMJBAAAAA==.',
['辛多']='辛多泪:BAAALgAECgEJAQAAAA==.',
['辛瑞']='辛瑞舞:BAAALgADCgIJAgAAAA==.',
['追魂']='追魂夺命刀盾:BAAALgAECgEJAQAAAA==.追魂夺命术士:BAAALgAECgYJBgABLgAFFAQJCgAFAHQMAA==.追魂夺命法师:BAABLgAFFH8KAAIFAAQJdAywHwBJAQAFAAQJdAywHwBJAQAAAA==.',
['逆白']='逆白:BAAALgAECgQJBAAAAA==.',
['逸朗']='逸朗丶:BAAALgAECgEJAwAAAA==.',
['那个']='那个法师:BAAALgADCgEJAQAAAA==.那个萨满丶:BAAALgAFFAUJAgAAAA==.',
['那格']='那格气势:BAAALgAECgQJBQAAAA==.',
['邪恶']='邪恶汤姆:BAAALgAECgYJBgAAAA==.',
['郭瑞']='郭瑞:BAAALgAECgkJDAAAAA==.',
['酒杯']='酒杯干碧婷:BAAALgAECgcJDgAAAA==.',
['酱牛']='酱牛肉:BAAALgAECgYJDQAAAA==.',
['醇香']='醇香坊万人迷:BAAALgAECgUJBQAAAA==.',
['醉拳']='醉拳啊苏:BAAALgADCgYJBgAAAA==.',
['野花']='野花的微香:BAABLgAECn8XAAIaAAYJahi8MwC1AQAaAAYJahi8MwC1AQAAAA==.',
['钟离']='钟离:BAAALgAECgkJCQAAAA==.',
['钢蛋']='钢蛋丶索瑞森:BAAALgAECgYJBwAAAA==.',
['铭仪']='铭仪:BAAALgAECgEJAQAAAA==.',
['银牛']='银牛娇娇:BAAALgADCgUJBQAAAA==.',
['锤子']='锤子剪刀布:BAAALgAECggJCQAAAA==.',
['长夜']='长夜难明:BAAALgAECgkJCwAAAA==.',
['长崎']='长崎术世:BAAALgAECgcJEAAAAA==.',
['闪电']='闪电流星:BAAALgAECgUJBQAAAA==.',
['队友']='队友真强:BAAALgAECggJEQAAAA==.',
['阴乘']='阴乘凌阳:BAABLgAECn8VAAMfAAgJIBXoEwDRAQAfAAcJ4xboEwDRAQAXAAEJkQqrHgE4AAAAAA==.',
['阿法']='阿法新灵:BAAALgAECgYJBwAAAA==.',
['阿离']='阿离一直调皮:BAAALgAECgEJAQAAAA==.',
['阿舟']='阿舟小武:BAAALgAECgYJCQABLgAFFAMJBwAJAFUXAA==.阿舟小龙:BAACLgAFFH8HAAIJAAMJVRdcDQAIAQAJAAMJVRdcDQAIAQAuAAQKfyEAAgkACQkxGjYIALgCAAkACQkxGjYIALgCAAAA.阿舟撒满:BAAALgAECgYJDAABLgAFFAMJBwAJAFUXAA==.',
['阿諾']='阿諾丶:BAACLgAFFH8IAAIJAAQJWiNMBQCjAQAJAAQJWiNMBQCjAQAuAAQKfxUAAgkACAkdJDkIALcCAAkACAkdJDkIALcCAAAA.',
['陈时']='陈时初:BAAALgAECgQJBQAAAA==.',
['隔壁']='隔壁师兄:BAAALgAECgEJAQAAAA==.',
['離譜']='離譜:BAAALgAECgQJCwAAAA==.',
['雷电']='雷电奶萨:BAAALgAECgIJAwAAAA==.',
['雷神']='雷神千裂破:BAAALgAECgkJCQAAAA==.',
['震荡']='震荡电磁波:BAAALgAECgYJBwAAAA==.',
['风为']='风为:BAAALgAECgYJBgABLgAECgkJCQATAAAAAA==.',
['风恒']='风恒:BAAALgADCgEJAQAAAA==.',
['风语']='风语烟岚:BAAALgAECgcJBgAAAA==.',
['飞翔']='飞翔小丘丘:BAAALgAECgMJAwAAAA==.飞翔小糖糖:BAAALgAFFAMJAwAAAA==.',
['香肩']='香肩微露:BAAALgADCgEJAQAAAA==.',
['骂我']='骂我的是给:BAAALgAECgcJDAAAAA==.',
['骑士']='骑士七:BAAALgAECgQJBAAAAA==.',
['高佬']='高佬:BAAALgAECgYJBgAAAA==.',
['魔兽']='魔兽之犬:BAAALgADCgUJBgAAAA==.',
['魔朵']='魔朵儿:BAAALgAECgUJBwAAAA==.',
['魔法']='魔法七:BAAALgAECgMJAwAAAA==.',
['魔礼']='魔礼海:BAAALgAECgcJCQAAAA==.',
['鲜果']='鲜果芋圆:BAAALgAECgYJBgAAAA==.',
['鲨手']='鲨手企鹅:BAAALgAFFAMJAwAAAA==.',
['鹿丶']='鹿丶:BAACLgAFFH8ZAAIWAAYJ4Ca2AACyAgAWAAYJ4Ca2AACyAgAuAAQKfyUAAhYACAnBJuYCAKEDABYACAnBJuYCAKEDAAAA.',
['麦幽']='麦幽幽:BAAALgADCgUJBQAAAA==.',
['黄飞']='黄飞鸿:BAABLgAECn8cAAIhAAgJsRxsBADhAQAhAAgJsRxsBADhAQAAAA==.',
['黎厉']='黎厉害:BAABLgAFFH8PAAQWAAQJkxTrEQDoAAAWAAQJshLrEQDoAAAiAAIJaQ2vCQChAAAjAAIJmxBMAwCEAAAAAA==.',
['黎明']='黎明之风笛手:BAAALgAECgQJBAAAAA==.',
['黑火']='黑火流星:BAAALgAECgYJBgAAAA==.',
['黑羽']='黑羽快斗:BAAALgAECgEJAQAAAA==.',
['黑龙']='黑龙白浊吐息:BAAALgADCgcJCgAAAA==.',
['黯汐']='黯汐:BAABLgAFFH8GAAIFAAMJoBE1KwAIAQAFAAMJoBE1KwAIAQAAAA==.',
['龙共']='龙共哇哇叫:BAAALgADCgYJBgAAAA==.',
['龙颖']='龙颖圆:BAAALgAECgcJDQAAAA==.',
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
