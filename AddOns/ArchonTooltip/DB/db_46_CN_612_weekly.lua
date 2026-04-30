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

local lookup = {'Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','Paladin-Retribution','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Evoker-Augmentation','Evoker-Preservation','Warrior-Fury','Warrior-Arms','Paladin-Holy','DemonHunter-Havoc','Mage-Frost','DemonHunter-Devourer','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Priest-Holy','Priest-Discipline','Priest-Shadow','Shaman-Enhancement','Evoker-Devastation','Mage-Arcane','DeathKnight-Blood','DeathKnight-Unholy','Druid-Restoration','Druid-Balance','Warrior-Protection',}
local provider = {region='CN',realm='图拉扬',name='CN',type='weekly',zone=46,date='2026-04-25',data={At='Athena:BAAALgAECgMJAwAAAA==.',
Az='Azzinothbaby:BAAALgAECgYJCQAAAA==.',
Ba='Bagandbag:BAACLgAFFH8TAAQBAAUJKB3rDABPAQABAAQJWRvrDABPAQACAAQJwgWYAwDuAAADAAIJ7h1GEADFAAAuAAQKfxcABAEACAnfGy4iABICAAEACAm0GC4iABICAAMAAgmSH/gqALQAAAIAAQmuGJQRAE8AAAAA.',
Be='Bebek:BAAALgAECggJCwAAAA==.',
Bu='Butterfly:BAAALgAECgYJBgAAAA==.',
Ch='Chainpact:BAAALgAFFAIJAgAAAA==.',
Cr='Cru:BAABLgAFFH8GAAIEAAMJLhUiCQADAQAEAAMJLhUiCQADAQAAAA==.',
Cy='Cyricmajere:BAAALgAECgEJAQAAAA==.',
Er='Ergrg:BAAALgAECgEJAQAAAA==.',
Iv='Ivanessa:BAAALgAECgUJBQAAAA==.',
Ji='Jimmygejm:BAAALgAECgEJAQAAAA==.',
Ke='Kellycha:BAAALgAECgMJAwAAAA==.Kellysha:BAAALgAECgMJAgAAAA==.',
Li='Lisam:BAAALgAECgEJAQABLgAECgkJAwAFAAAAAA==.Listentome:BAAALgAECgcJCAAAAA==.',
Ly='Lyrics:BAACLgAFFH8XAAQGAAYJdhl5AQAuAgAGAAYJdhl5AQAuAgAHAAIJ7RDGDACmAAAIAAEJAADeBABZAAAuAAQKfxsAAwYACAkpJLAPAPwCAAYACAnzIrAPAPwCAAcABQk+IeYSALQBAAAA.',
Ma='Mandriva:BAABLgAECn8qAAMDAAgJGSK1BwAUAwADAAgJGSK1BwAUAwABAAQJigiwZgCkAAAAAA==.',
Me='Memoryfan:BAAALgAFFAEJAQAAAA==.Mercy:BAAALgAECgYJDgAAAA==.',
Mi='Missinghigh:BAABLgAECn8VAAMJAAgJQg2yIQCxAQAJAAgJQg2yIQCxAQAKAAcJ7wniIwBaAQAAAA==.',
No='Nostalie:BAABLgAECn8lAAMLAAgJrx+jDQDpAgALAAgJrx+jDQDpAgAMAAEJhhvYOABMAAAAAA==.Notyourdope:BAAALgAECgIJAgAAAA==.',
Ol='Ollie:BAAALgAECgMJBAAAAA==.',
Pa='Palad:BAAALgAECgMJAwAAAA==.Pallas:BAAALgAFFAMJBAAAAA==.Partingg:BAAALgAECgkJDQAAAA==.',
Pe='Perhon:BAAALgAECgUJBQAAAA==.',
Py='Pyrrla:BAABLgAFFH8JAAMEAAQJiwjcCwDVAAAEAAMJ5gLcCwDVAAANAAMJnBdaFACeAAAAAA==.',
Ra='Rainbowg:BAAALgAECgUJBQAAAA==.',
Sa='Salgolagnia:BAACLgAFFH8DAAIGAAMJcBMsDgACAQAGAAMJcBMsDgACAQAuAAQKfw8AAwYABwkRFgJLAOgBAAYABwkRFgJLAOgBAAcAAQkAAM9zADEAAAAA.',
Sh='Shardows:BAACLgAFFH8KAAIGAAMJCg1iJADyAAAGAAMJCg1iJADyAAAuAAQKfxkAAwYACAmsG1MoAHACAAYACAmsG1MoAHACAAcAAQkAAE1sADsAAAAA.',
Sl='Slayerholy:BAAALgAECgYJCgAAAA==.',
So='Solaris:BAABLgAECn8ZAAIOAAcJIw9aJQCUAQAOAAcJIw9aJQCUAQAAAA==.',
Sr='Srcaad:BAAALgAECgMJAwAAAA==.Srcad:BAAALgADCgUJBQAAAA==.Srcar:BAAALgADCgEJAQAAAA==.',
St='Stellagosa:BAAALgAECgIJAgAAAA==.',
Sw='Sweety:BAAALgAECgUJBwAAAA==.',
Th='Thnewss:BAABLgAFFH8FAAMDAAQJnBDTDAD7AAADAAMJtBTTDAD7AAABAAEJUgQ6KgBHAAAAAA==.',
Vi='Viena:BAAALgAECgYJCQAAAA==.',
Wq='Wqhdkovo:BAAALgADCgYJBgAAAA==.',
Ya='Yatoro:BAAALgAECgMJAQAAAA==.',
Yr='Yreel:BAACLgAFFH8JAAIEAAQJzR8EBwB/AQAEAAQJzR8EBwB/AQAuAAQKfxgAAgQABwmSHpo9AC4CAAQABwmSHpo9AC4CAAAA.',
Zn='Znlx:BAAALgADCgcJBwAAAA==.',
['一朵']='一朵菊花台:BAAALgAECgEJAgAAAA==.',
['一根']='一根烧火棍:BAAALgAECgQJBAAAAA==.',
['七里']='七里香丶:BAAALgAFFAEJAQAAAA==.',
['上帝']='上帝之怒:BAAALgAECgEJAQAAAA==.',
['不知']='不知火舞舞:BAAALgADCgIJAgAAAA==.',
['不破']='不破爱花:BAAALgAECgYJCgAAAA==.',
['东尼']='东尼大木:BAAALgAECgUJBQAAAA==.',
['丶全']='丶全村的希望:BAAALgAECgQJBQAAAA==.',
['丶超']='丶超级小欧皇:BAACLgAFFH8GAAIPAAQJjAmgIQA6AQAPAAQJjAmgIQA6AQAuAAQKfxgAAg8ACAkRHJNFAGcCAA8ACAkRHJNFAGcCAAAA.',
['主角']='主角光环:BAABLgAFFH8KAAIPAAQJJSHGDwCYAQAPAAQJJSHGDwCYAQAAAA==.',
['乔乔']='乔乔:BAAALgAECgcJDgAAAA==.',
['九莲']='九莲宝灯丶:BAAALgAECgYJBgAAAA==.',
['乱舞']='乱舞春秋丶:BAAALgAECgYJDAAAAA==.',
['什么']='什么都敢混:BAAALgAFFAQJAQAAAA==.',
['从小']='从小就低调:BAAALgAECgQJBAAAAA==.',
['你叫']='你叫你马呢:BAAALgAFFAEJAQAAAA==.',
['你装']='你装你马呢:BAAALgAECgYJDAABLgAFFAIJBgALAHclAA==.',
['使不']='使不得:BAAALgADCgUJBQAAAA==.',
['依稀']='依稀你我:BAAALgADCgQJBAAAAA==.',
['俄式']='俄式三弦琴:BAAALgAECgYJCgAAAA==.',
['健康']='健康第一:BAAALgAECgcJDQAAAA==.',
['光辉']='光辉之月:BAAALgAECgEJAQAAAA==.',
['八云']='八云橙:BAAALgAECgYJBgAAAA==.八云紫:BAAALgADCgEJAQAAAA==.',
['冰丨']='冰丨伤:BAAALgAECgcJCwAAAA==.',
['冰露']='冰露:BAABLgAFFH8FAAIQAAIJkB26IgC5AAAQAAIJkB26IgC5AAAAAA==.',
['冷月']='冷月天使:BAAALgAECgYJBgAAAA==.',
['凝雪']='凝雪飞霜:BAAALgADCgEJAQAAAA==.',
['刚本']='刚本零点零一:BAAALgAECgcJBwAAAA==.',
['制裁']='制裁之锤:BAAALgAECgUJBQAAAA==.',
['包包']='包包沙:BAAALgADCgEJAQAAAA==.',
['化羽']='化羽湮灭万律:BAAALgAFFAEJAQAAAA==.',
['千鬼']='千鬼刃:BAAALgAFFAEJAQAAAA==.',
['卡布']='卡布其诺长云:BAAALgAECgEJAQAAAA==.',
['叁柒']='叁柒贰拾壹:BAAALgAECgQJBAAAAA==.',
['叶之']='叶之魂:BAAALgADCgUJBQAAAA==.',
['叶凡']='叶凡:BAAALgAECgkJBwAAAA==.',
['吃完']='吃完饭找你玩:BAAALgAECgYJCwAAAA==.',
['名字']='名字贼难取:BAAALgADCgEJAQAAAA==.',
['吖兄']='吖兄:BAAALgAECgIJAgAAAA==.',
['吖姐']='吖姐:BAAALgADCgMJAwAAAA==.',
['吖弟']='吖弟:BAAALgAECgcJBgABLgAFFAcJBAAFAAAAAA==.',
['味大']='味大无需多盐:BAAALgAECgcJCAAAAA==.',
['呵呵']='呵呵哈哈丶:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜噜冒泡泡:BAAALgAECgkJDwAAAA==.',
['哈姆']='哈姆尼克:BAAALgADCgEJAQAAAA==.',
['哎呀']='哎呀闪现撞墙:BAAALgAECgYJCgAAAA==.',
['哔哔']='哔哔啦吥:BAAALgAECgEJAQAAAA==.',
['唉丶']='唉丶怎么办:BAACLgAFFH8FAAMRAAMJCwdgDQDNAAARAAMJCwdgDQDNAAASAAIJoBetGgCVAAAuAAQKfxwABBEABwkGG1wbAN8BABEABglgG1wbAN8BABIABgn3FHQ6AF8BABMABQl2HIY0AE8BAAEuAAUUBQkTAAEAKB0A.',
['唐老']='唐老婆子:BAAALgADCgYJBgAAAA==.',
['喧哗']='喧哗世界:BAAALgAECgYJBgAAAA==.',
['国倾']='国倾倾:BAAALgAECgQJBAAAAA==.',
['圆肥']='圆肥的猫:BAAALgAECgYJBgAAAA==.',
['塞勒']='塞勒涅:BAAALgAECgUJBQAAAA==.',
['大一']='大一武一生:BAAALgAECgUJBgAAAA==.',
['大哥']='大哥要冰么:BAAALgAECgkJDQAAAA==.大哥要粉么:BAAALgAECgkJDgAAAA==.',
['大四']='大四喜丶:BAAALgAECgcJBwABLgAFFAYJEwAEAMggAA==.',
['大醉']='大醉侠:BAAALgAECgQJBAAAAA==.',
['天地']='天地无恒:BAAALgAECgIJAwAAAA==.',
['天者']='天者:BAAALgAECgEJAQAAAA==.',
['失忆']='失忆嘚猫:BAAALgAFFAEJAQAAAA==.失忆的貓:BAAALgAECgEJAQABLgAFFAEJAQAFAAAAAA==.',
['奈斩']='奈斩:BAAALgAFFAIJAgAAAA==.',
['奈斯']='奈斯兔米丘:BAAALgAECgQJBAAAAA==.',
['奥尔']='奥尔托莉亚:BAAALgAECgIJAgAAAA==.',
['如太']='如太阳般火热:BAAALgAFFAIJAgAAAA==.如太阳般耀眼:BAAALgAECgcJEAAAAA==.如太阳般闪耀:BAAALgAFFAIJAwAAAA==.',
['妮可']='妮可沃特森:BAAALgAECgcJCwAAAA==.',
['娱乐']='娱乐适情:BAAALgADCgMJAwAAAA==.',
['安奇']='安奇喇:BAACLgAFFH8QAAIKAAUJayZkAQAvAgAKAAUJayZkAQAvAgAuAAQKfyEAAgoACAlRI1oDAC0DAAoACAlRI1oDAC0DAAAA.安奇翋:BAABLgAECn8WAAMUAAcJRx5XEwBFAgAUAAcJRx5XEwBFAgAVAAUJZAykNAD+AAAAAA==.',
['安格']='安格斯:BAAALgAECgEJAQAAAA==.',
['宝你']='宝你苟命:BAAALgAECgEJAQAAAA==.',
['寒春']='寒春的澜珊:BAAALgAECgkJDgAAAA==.',
['小嘴']='小嘴抹了蜜:BAAALgAECgIJAgAAAA==.',
['小布']='小布尔乔亚丶:BAAALgAFFAIJBAAAAA==.',
['小德']='小德熠熠:BAAALgADCgQJBAAAAA==.',
['小心']='小心眼大魔王:BAAALgAECgEJAQAAAA==.',
['小手']='小手彤彤红:BAAALgAECgUJBwAAAA==.',
['小魚']='小魚尾巴:BAAALgAECgEJAQAAAA==.',
['尕崔']='尕崔:BAAALgAECgQJBAAAAA==.',
['就差']='就差一丢丢儿:BAAALgAFFAIJAgAAAA==.',
['归来']='归来的梦:BAAALgAECgEJAQAAAA==.',
['往事']='往事回忆:BAAALgADCgYJBgAAAA==.',
['徐则']='徐则林:BAAALgAECgUJCgAAAA==.',
['德鹿']='德鹿梦鱼:BAAALgAECgcJBwAAAA==.',
['忍者']='忍者丶:BAAALgAECgEJAQAAAA==.',
['思菲']='思菲雅:BAAALgAECgYJCwAAAA==.',
['急速']='急速蜗牛:BAAALgAECgEJAwAAAA==.',
['恰恰']='恰恰峰:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔熠熠:BAAALgAECgUJBQAAAA==.',
['悦色']='悦色:BAAALgAECgYJEgABLgAECggJFQAJAEINAA==.',
['我不']='我不会放手:BAAALgAECgQJBgAAAA==.',
['我本']='我本善良:BAAALgADCgYJBgAAAA==.我本有名:BAAALgAECgYJAwAAAA==.',
['战复']='战复牛排:BAAALgAECgIJAgAAAA==.',
['戮瞳']='戮瞳:BAAALgAFFAEJAQAAAA==.',
['托尼']='托尼灬斯塔克:BAAALgADCgkJCQAAAA==.',
['抓宝']='抓宝宝:BAAALgAECgEJAQAAAA==.',
['拉风']='拉风不拉怪:BAAALgAECgQJBAAAAA==.',
['招财']='招财之圣光:BAAALgAECgEJAQAAAA==.招财白雪雪:BAABLgAFFH8HAAIGAAUJ5BQaBwCyAQAGAAUJ5BQaBwCyAQAAAA==.',
['拥抱']='拥抱圣光:BAAALgAECgIJAgAAAA==.',
['捷妮']='捷妮丶:BAAALgAECgYJDgAAAA==.',
['擒兽']='擒兽达人:BAAALgADCgEJAQAAAA==.',
['数值']='数值的美:BAABLgAECn8YAAIPAAcJJhnmYAAZAgAPAAcJJhnmYAAZAgAAAA==.',
['料理']='料理仙姬:BAAALgAECgMJBAAAAA==.',
['无限']='无限剑质:BAAALgAECgUJBQAAAA==.',
['星天']='星天外:BAAALgAECgYJDAAAAA==.',
['星梦']='星梦无痕:BAAALgAFFAIJBAAAAA==.',
['星辰']='星辰熠熠:BAAALgAECgQJBAAAAA==.',
['昱洋']='昱洋:BAAALgAECgcJBwAAAA==.',
['晓月']='晓月的圆舞曲:BAAALgAECggJCAAAAA==.',
['晴天']='晴天丶:BAAALgAECgYJBgAAAA==.',
['暗影']='暗影小小琴:BAABLgAFFH8IAAIGAAQJ6BFQIwD3AAAGAAQJ6BFQIwD3AAAAAA==.',
['暗穹']='暗穹:BAAALgADCgEJAQAAAA==.',
['暗黑']='暗黑纪元:BAAALgAECgEJAQAAAA==.',
['暴走']='暴走冰美式:BAAALgADCgUJBQAAAA==.',
['月之']='月之海:BAAALgAFFAEJAgAAAA==.',
['月兰']='月兰馨:BAAALgAECgcJCAAAAA==.',
['月迁']='月迁丶:BAAALgAECgEJAQAAAA==.',
['有点']='有点儿小鸡冻:BAABLgAFFH8HAAIPAAIJEiLdMwDKAAAPAAIJEiLdMwDKAAAAAA==.',
['朱比']='朱比的红叶:BAAALgAECgYJDwAAAA==.',
['格瑞']='格瑞司华尔德:BAAALgAECgUJBQAAAA==.',
['梦里']='梦里花:BAACLgAFFH8FAAIUAAMJhhHQDACXAAAUAAMJhhHQDACXAAAuAAQKfxoAAxQACAmuEasgAN0BABQACAmuEasgAN0BABYABQkHFdU5ACIBAAAA.',
['橘雪']='橘雪莉:BAABLgAECn8fAAIEAAkJKSMwAwCiAwAEAAkJKSMwAwCiAwAAAA==.',
['欧尼']='欧尼坦:BAAALgAECgcJBgAAAA==.',
['欧梅']='欧梅嘉:BAAALgAECgkJCQAAAA==.',
['毒鬼']='毒鬼:BAABLgAECn8cAAMLAAcJSRsxKAAcAgALAAcJSRsxKAAcAgAMAAEJ5QJtSgAVAAAAAA==.',
['沃什']='沃什大拉基:BAEBLgAFFH8FAAIXAAIJrR4XBAC+AAAXAAIJrR4XBAC+AAABLgAFFAUJEQAYAGIaAA==.',
['沉香']='沉香露白:BAABLgAFFH8FAAIEAAUJQAhBCABwAQAEAAUJQAhBCABwAQAAAA==.',
['沙卡']='沙卡:BAAALgAECgEJAgAAAA==.',
['没了']='没了尾巴:BAAALgAECgkJDwAAAA==.',
['油漆']='油漆粉刷工:BAAALgADCgEJAQAAAA==.',
['波比']='波比娃娃:BAAALgADCgcJBQAAAA==.',
['洛克']='洛克玛尼:BAAALgADCgMJAwAAAA==.',
['海底']='海底捞月丶:BAAALgAECgEJAQAAAA==.',
['海深']='海深时浅:BAAALgAECgYJDQAAAA==.',
['淘米']='淘米鱼宝宝:BAAALgAECgQJBAAAAA==.',
['深水']='深水天蓝:BAAALgAECgMJAwAAAA==.',
['混一']='混一色丶:BAAALgAECgcJCQAAAA==.',
['混沌']='混沌之后:BAAALgAECgEJAQAAAA==.',
['淺倉']='淺倉南:BAAALgAECgkJDgAAAA==.',
['清一']='清一色丶:BAAALgAECgcJDQAAAA==.',
['清角']='清角吹寒:BAAALgAFFAIJAgAAAA==.',
['火力']='火力全开丶:BAAALgAECgQJBAAAAA==.',
['火爖']='火爖:BAAALgADCgQJBAAAAA==.',
['火锅']='火锅味勾巴:BAABLgAFFH8GAAILAAIJdyVBBwDiAAALAAIJdyVBBwDiAAAAAA==.',
['灬忆']='灬忆学时:BAAALgAECgYJAQAAAA==.',
['爽歪']='爽歪歪法:BAABLgAFFH8FAAIZAAUJkwJAAAA1AQAZAAUJkwJAAAA1AQAAAA==.',
['狂野']='狂野力量:BAAALgADCgEJAQAAAA==.',
['狐人']='狐人:BAAALgAECgUJCQAAAA==.',
['狗头']='狗头军狮:BAACLgAFFH8ZAAIaAAYJBiY/AACRAgAaAAYJBiY/AACRAgAuAAQKfyAAAxoACQnwIZECAEMDABoACQkxIZECAEMDABsAAQmeJPAGAWgAAAAA.',
['狮心']='狮心:BAAALgADCgUJBQAAAA==.',
['猎天']='猎天者:BAAALgAECgUJBQAAAA==.',
['猎灵']='猎灵:BAAALgADCgMJAwAAAA==.',
['猪八']='猪八戒踢皮球:BAAALgAECgYJCgAAAA==.',
['瓦伦']='瓦伦斯坦森:BAAALgADCgYJBgAAAA==.',
['生命']='生命有價:BAACLgAFFH8KAAMHAAQJuRcwDQCjAAAGAAIJ8SJ1KQDOAAAHAAIJgQwwDQCjAAAuAAQKfxQAAwYACAnBH1I2ADMCAAYABwnBH1I2ADMCAAcAAgnkEhBNAIYAAAAA.',
['白晶']='白晶半框眼镜:BAAALgADCgYJBgAAAA==.',
['白萱']='白萱歌:BAAALgAECgYJBwAAAA==.',
['百合']='百合折:BAAALgAECgUJBQAAAA==.',
['百花']='百花凌风:BAAALgAECgMJBAAAAA==.百花哲芷:BAAALgAECgcJEAAAAA==.百花妖月:BAAALgAECgEJAQAAAA==.',
['皓月']='皓月清风:BAAALgAECgYJBwAAAA==.',
['真水']='真水:BAAALgAECgYJCAAAAA==.',
['祈爱']='祈爱漫无天际:BAAALgAFFAQJAQAAAA==.',
['神思']='神思者:BAAALgAECgEJAQAAAA==.',
['笑一']='笑一:BAABLgAFFH8FAAIPAAIJkRPuPwCuAAAPAAIJkRPuPwCuAAAAAA==.',
['符文']='符文熠熠:BAAALgAECgEJAQAAAA==.',
['笨笨']='笨笨的:BAABLgAFFH8HAAIUAAQJ7QyTAgAdAQAUAAQJ7QyTAgAdAQAAAA==.',
['箜箜']='箜箜小喃:BAAALgAECgYJDQAAAA==.',
['篠之']='篠之之帚:BAAALgAECgUJAwAAAA==.',
['米诺']='米诺菲:BAAALgAECgYJBgABLgAECggJFgAEADkkAA==.',
['粉色']='粉色别点:BAACLgAFFH8PAAMbAAUJOBwpDAB0AQAbAAQJOBwpDAB0AQAaAAEJAACoEQBlAAAuAAQKfykAAhsACQnaI1IEAI8DABsACQnaI1IEAI8DAAAA.',
['糖豆']='糖豆穿肠:BAAALgADCgcJDAAAAA==.',
['纠结']='纠结无双:BAAALgADCgYJBgAAAA==.',
['羽蛇']='羽蛇神:BAAALgAECgcJCwAAAA==.',
['老鸹']='老鸹:BAAALgAECgEJAgAAAA==.',
['肥肥']='肥肥师兄:BAAALgAECgYJCQAAAA==.',
['肿么']='肿么肥寺:BAABLgAECn8VAAMcAAkJzBMWJgAgAgAcAAcJHxgWJgAgAgAdAAkJ2gt7IQDxAQAAAA==.',
['胡图']='胡图图丨翻滚:BAAALgAECgYJCwAAAA==.',
['能充']='能充:BAAALgAECgIJAgAAAA==.',
['腐草']='腐草为萤丶:BAABLgAECn8dAAQDAAgJ9h9UNQDZAQADAAUJySBUNQDZAQACAAYJ2hedDwDJAQABAAMJahhEXADRAAAAAA==.',
['艾米']='艾米莉娅:BAAALgAECgcJCwABLgAFFAMJCgAGAAoNAA==.',
['花中']='花中偏爱菊:BAAALgAECgIJAgAAAA==.',
['苏超']='苏超十三妹:BAAALgAECgUJBQAAAA==.',
['苟命']='苟命:BAAALgADCgEJAQAAAA==.',
['范迪']='范迪塞尔:BAAALgAFFAIJBAAAAA==.',
['荔枝']='荔枝桂圆:BAAALgAECgMJAwAAAA==.',
['莔丁']='莔丁乙:BAAALgAECgQJBAAAAA==.',
['葉無']='葉無風:BAABLgAECn8WAAIDAAcJjxHMGAA1AQADAAcJjxHMGAA1AQAAAA==.',
['葉雨']='葉雨阑珊:BAAALgADCgMJAwAAAA==.',
['薄雾']='薄雾黑白:BAAALgAECgEJAQAAAA==.',
['蝎子']='蝎子莱莱:BAAALgAFFAQJBAAAAA==.',
['謎夏']='謎夏:BAAALgADCgYJBgAAAA==.',
['谦卑']='谦卑的糖门滚:BAAALgAECgEJAgAAAA==.',
['豪运']='豪运:BAAALgADCgMJAwAAAA==.',
['贡拉']='贡拉德潘:BAAALgAECgIJAgAAAA==.',
['贵阳']='贵阳洋芋粑:BAAALgAECgQJCwAAAA==.贵阳谢霆锋:BAAALgAECgUJCAAAAA==.',
['轨迹']='轨迹丨:BAABLgAECn8gAAQLAAcJ5BsQLgD5AQALAAYJ3R0QLgD5AQAMAAQJmRFfHwDzAAAeAAEJ/RCQRQA2AAAAAA==.',
['辛弗']='辛弗尼尔:BAABLgAECn8oAAIWAAkJmA0cFwAtAgAWAAkJmA0cFwAtAgAAAA==.',
['迪丽']='迪丽休斯:BAAALgADCgEJAQAAAA==.',
['郁闷']='郁闷啊:BAAALgAECgYJCgAAAA==.',
['量子']='量子熊:BAAALgADCgEJAQAAAA==.',
['钛朴']='钛朴涂:BAABLgAECn8bAAIOAAcJHSEKDgCDAgAOAAcJHSEKDgCDAgAAAA==.',
['银影']='银影天仇:BAABLgAFFH8EAAICAAIJ1A8xBACyAAACAAIJ1A8xBACyAAAAAA==.',
['阿塔']='阿塔利亚:BAAALgAECgEJAQAAAA==.',
['阿维']='阿维娜丶绒爪:BAAALgAECgMJAwAAAA==.',
['阿莱']='阿莱克希亚:BAAALgAECgcJEAAAAA==.',
['隐者']='隐者嘉德丽雅:BAAALgAFFAEJAQAAAA==.',
['雅拉']='雅拉香布:BAAALgAECgcJCwAAAA==.',
['雨山']='雨山微:BAAALgAECgcJCwAAAA==.',
['雪之']='雪之浪子:BAAALgAECgMJAwAAAA==.',
['雪冰']='雪冰儿:BAAALgAFFAIJAgAAAA==.',
['雪落']='雪落花见:BAAALgAECgYJAwAAAA==.',
['雷滚']='雷滚滚:BAAALgADCgEJAQAAAA==.',
['雾岛']='雾岛董香:BAABLgAFFH8JAAISAAQJVyFFAgBqAQASAAQJVyFFAgBqAQAAAA==.',
['霜华']='霜华青丘行:BAAALgAFFAIJAwAAAA==.',
['青花']='青花瓷丶:BAAALgAECgkJEAAAAA==.',
['青青']='青青河边草:BAAALgADCgUJBQAAAA==.',
['风翼']='风翼:BAAALgAECgcJBwAAAA==.',
['风萨']='风萨:BAAALgAFFAEJAQAAAA==.',
['风行']='风行者莉亚:BAAALgAECgIJAgAAAA==.',
['风辰']='风辰:BAAALgAFFAIJBAAAAA==.',
['飞天']='飞天大蠊:BAAALgAECgYJDwAAAA==.',
['高手']='高手:BAAALgAECgYJDgAAAA==.',
['魅魔']='魅魔苏然:BAACLgAFFH8FAAIPAAIJhR53NADGAAAPAAIJhR53NADGAAAuAAQKfxwAAg8ABwlCIj42AJsCAA8ABwlCIj42AJsCAAAA.',
['鲜血']='鲜血光环:BAABLgAFFH8HAAIbAAQJNRVvBQBiAQAbAAQJNRVvBQBiAQAAAA==.',
['鸿鳍']='鸿鳍钕瓦斯亚:BAAALgADCgYJBgAAAA==.',
['龙菲']='龙菲雨:BAAALgADCgEJAQAAAA==.',
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
