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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','DeathKnight-Unholy','Rogue-Subtlety','Rogue-Assassination','Hunter-BeastMastery','DemonHunter-Havoc','Paladin-Holy','Paladin-Retribution','Unknown-Unknown','Mage-Frost','Warlock-Demonology','Warrior-Fury','Warrior-Arms','Hunter-Marksmanship','Warlock-Destruction','Druid-Balance','DeathKnight-Blood','DemonHunter-Devourer','Monk-Brewmaster','Monk-Windwalker','Evoker-Preservation','Shaman-Restoration','Shaman-Elemental','DeathKnight-Melee','Warlock-Affliction','Priest-Holy','Priest-Shadow','Rogue-Outlaw','Druid-Any','Druid-Restoration','Monk-Mistweaver','Shaman-Enhancement','Priest-Discipline','Warrior-Protection','DemonHunter-Vengeance','Paladin-Protection','DeathKnight-Frost','Druid-Guardian','Druid-Feral',}
local provider = {region='CN',realm='泰兰德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akerfive:BAAALgADCgIJAgAAAA==.Akzi:BAAALgAECgcJEQAAAA==.',
Al='Alloces:BAAALgAFFAIJBAAAAA==.Alooha:BAAALgAECgkJCQAAAA==.',
Ay='Ayudragon:BAACLgAFFH8HAAIBAAMJCBjzEQDwAAABAAMJCBjzEQDwAAAuAAQKfyUAAwIABwljIz0KADoCAAEABwn7IUwQAHQCAAIABgnQIj0KADoCAAEuAAUUBgkQAAMAxSYA.',
Az='Azael:BAAALgAECgIJAgAAAA==.Azaelms:BAAALgAECgYJEAAAAA==.',
Bi='Biglight:BAABLgAECn8ZAAMEAAcJqSKTDwCsAgAEAAcJ3SGTDwCsAgAFAAIJkx6fFACyAAAAAA==.',
Br='Broky:BAAALgAECgIJAgAAAA==.',
Bu='Burstrist:BAAALgADCgIJAgAAAA==.',
Co='Conthy:BAAALgADCgMJAwAAAA==.',
Cu='Cutenice:BAAALgAECggJDQAAAA==.',
Dr='Dragk:BAAALgAECgcJDwAAAA==.Druidss:BAAALgAECgYJEQAAAA==.Drvision:BAABLgAECn8YAAIGAAcJbgsRSACSAQAGAAcJbgsRSACSAQAAAA==.',
Ds='Dspace:BAAALgAECgEJAQAAAA==.',
Du='Duskelegy:BAABLgAFFH8MAAIDAAQJRiIrBgCiAQADAAQJRiIrBgCiAQAAAA==.',
Ev='Evàngelíon:BAAALgAFFAMJAwAAAA==.',
Fa='Fantasy:BAABLgAFFH8FAAIDAAIJGSE6MQDGAAADAAIJGSE6MQDGAAAAAA==.Fantasydh:BAAALgAFFAIJAwABLgAFFAIJBQADABkhAA==.',
Fe='Fewz:BAAALgAECgEJAQAAAA==.',
Fo='Foryldl:BAABLgAECn8fAAIHAAcJ6RyKAgDpAQAHAAcJ6RyKAgDpAQAAAA==.',
Fr='Freshoyster:BAAALgAECgIJAgAAAA==.Friend:BAAALgAECgYJBgAAAA==.',
Fu='Funnymud:BAAALgADCgEJAQAAAA==.',
Gi='Giotto:BAAALgAFFAQJBAAAAA==.',
Gr='Gremory:BAAALgAECggJCwAAAA==.',
Gu='Guccigiao:BAAALgAECgQJCgAAAA==.',
Ha='Hakunamatata:BAAALgAFFAEJAQAAAA==.',
Ho='Holydeath:BAABLgAECn8WAAMIAAYJZRkXOgCRAQAIAAYJZRkXOgCRAQAJAAQJtA7V5gDBAAAAAA==.',
Jr='Jrs:BAAALgAFFAIJBAABLgAFFAIJBQADABkhAA==.',
Ka='Kaoyan:BAAALgAECgMJBQAAAA==.Kasiyashiki:BAAALgAECgIJAgAAAA==.',
Ki='Killer:BAAALgAECgIJAwAAAA==.',
Kj='Kjkji:BAAALgAECgQJBAAAAA==.',
Kn='Knkk:BAAALgAFFAIJAgAAAA==.',
Ku='Kulolo:BAAALgAECgYJCAAAAA==.',
Li='Lie:BAAALgAFFAIJAgABLgAFFAIJBQADABkhAA==.',
Lu='Lucas:BAAALgAECgUJBwABLgAECgYJBgAKAAAAAA==.Luomei:BAAALgAFFAQJBAAAAA==.',
Ma='Macroyan:BAAALgADCgIJAgAAAA==.Madeinheaven:BAAALgADCgYJBgAAAA==.Mallory:BAAALgAECgkJCgAAAA==.Marbas:BAAALgAECggJEwAAAA==.Mareao:BAAALgADCgQJBAAAAA==.',
Mi='Mint:BAAALgAECgkJCQAAAA==.',
Mo='Momm:BAAALgAFFAEJAQAAAA==.',
Na='Nagasakisoyo:BAAALgAFFAIJAgAAAA==.',
Ne='Necroticus:BAAALgAECgYJDAAAAA==.',
No='Norn:BAAALgADCgYJBgAAAA==.',
Or='Orangemaru:BAAALgAECgEJAQAAAA==.',
Pi='Pipicc:BAAALgAFFAIJBAAAAA==.Pipinn:BAAALgAECgcJBwAAAA==.Pipixx:BAAALgAECgEJAgAAAA==.',
Po='Poipoirua:BAAALgAECgUJBQAAAA==.',
Pu='Pullwind:BAAALgAECgQJBAAAAA==.',
Qu='Qui:BAABLgAFFH8KAAILAAQJSBghJwAWAQALAAQJSBghJwAWAQAAAA==.',
Ra='Rainyxd:BAAALgAECgUJBgABLgAFFAYJEAADAMUmAA==.Rasfe:BAAALgAFFAEJAQAAAA==.',
Ri='Ripgd:BAABLgAECn8UAAIMAAgJRRUeNwAvAgAMAAgJRRUeNwAvAgAAAA==.',
Sb='Sbsm:BAAALgAFFAIJAgAAAA==.',
Se='Seahood:BAAALgAECgcJCAAAAA==.',
Sk='Skyfvcker:BAABLgAECn8ZAAMNAAcJHh/cHQBgAgANAAcJERzcHQBgAgAOAAQJYR3pEgB0AQABLgAFFAUJAQAKAAAAAA==.',
So='Somnium:BAAALgADCgcJBwAAAA==.Souldrinker:BAAALgAECgYJBgAAAA==.',
Su='Suntony:BAAALgAECgkJEAAAAA==.',
Tc='Tcsdwyjx:BAABLgAECn8YAAILAAcJIBsaRgBmAgALAAcJIBsaRgBmAgAAAA==.',
Tv='Tv:BAAALgADCgQJAQAAAA==.',
Vi='Vidar:BAAALgAECgcJDQAAAA==.Vikilyy:BAAALgADCgQJBAAAAA==.',
Wa='Wanrenonly:BAACLgAFFH8LAAIPAAUJYBmtBgCzAQAPAAUJYBmtBgCzAQAuAAQKfywAAw8ACAmpI70HAB8DAA8ACAmpI70HAB8DAAYABgm1IpAGAAQCAAAA.',
Wf='Wfdsf:BAAALgAECgQJBAAAAA==.',
Wi='Windss:BAAALgAECgYJCAAAAA==.Windws:BAAALgADCgIJAgAAAA==.',
Xg='Xgt:BAAALgAECgYJBwAAAA==.',
Ya='Yazael:BAAALgADCgMJAwAAAA==.',
Yh='Yhqxa:BAAALgAECgMJAwAAAA==.',
Yr='Yrjc:BAACLgAFFH8MAAIEAAUJ+SZ+AABBAgAEAAUJ+SZ+AABBAgAuAAQKfxYAAgQACAkuJsgCAHkDAAQACAkuJsgCAHkDAAAA.',
Yu='Yumir:BAAALgADCgcJBwAAAA==.',
Zi='Zieka:BAAALgAECgcJEAAAAA==.',
Zz='Zzpanda:BAAALgAECgkJEQAAAA==.',
['一十']='一十三:BAABLgAFFH8FAAMQAAQJvQ2XDACnAAAMAAIJ1wOvNACpAAAQAAIJrxKXDACnAAAAAA==.',
['一只']='一只椰子:BAAALgAECgIJBgAAAA==.',
['一坨']='一坨咕咕:BAAALgADCgEJAQAAAA==.',
['一枕']='一枕秋风:BAAALgAECgQJBgAAAA==.',
['一梦']='一梦屮夺魄:BAAALgADCgcJBwAAAA==.一梦屮星河:BAAALgAECgUJBQAAAA==.',
['一车']='一车面包人:BAAALgAECgEJAQAAAA==.',
['七彩']='七彩流星:BAAALgAECgYJCQABLgAFFAUJCQARABUDAA==.',
['三费']='三费成长:BAAALgAECggJCQAAAA==.',
['三途']='三途川渡鸦:BAABLgAFFH8IAAMDAAUJYQY6HQAtAQADAAQJYQY6HQAtAQASAAEJAAD9FwA7AAAAAA==.',
['上善']='上善若你:BAAALgAECgEJAgAAAA==.',
['上朝']='上朝之风:BAAALgADCgMJAwAAAA==.',
['下饭']='下饭王:BAABLgAFFH8FAAMHAAQJXxFgAwBRAQAHAAQJXxFgAwBRAQATAAEJmg6ENgBLAAAAAA==.',
['不灭']='不灭猎魂:BAAALgADCgcJBwAAAA==.',
['东洋']='东洋雨菲:BAAALgAECgMJAwAAAA==.',
['丨不']='丨不明其意丨:BAAALgADCgUJBQAAAA==.丨不见其首丨:BAAALgAECgEJAQAAAA==.',
['丨玩']='丨玩丨命丨:BAAALgAECgEJAgAAAA==.',
['丨舒']='丨舒墨白丨:BAAALgAECgQJBAAAAA==.',
['中专']='中专说唱尼哥:BAACLgAFFH8IAAILAAQJ6h33EQCGAQALAAQJ6h33EQCGAQAuAAQKfyYAAgsACAn3IzQDAJkCAAsACAn3IzQDAJkCAAAA.',
['丶七']='丶七月丶小德:BAAALgAFFAEJAQAAAA==.丶七月丶蛋糕:BAAALgADCgUJBQAAAA==.',
['丶丨']='丶丨逽曦灬:BAAALgAECgkJAgABLgAECgkJAgAKAAAAAA==.',
['丶墨']='丶墨白:BAAALgADCgcJCQAAAA==.',
['丶山']='丶山也聆風:BAAALgAECgMJCAAAAA==.',
['丶拾']='丶拾玖:BAAALgAECgEJAQAAAA==.',
['丶牧']='丶牧婉清:BAAALgAECgEJAQAAAA==.丶牧念辞:BAAALgAECgEJAgAAAA==.',
['丶那']='丶那咋办嘛:BAAALgAECgEJAQAAAA==.',
['丶雅']='丶雅飒:BAABLgAFFH8JAAIRAAUJFQOLBQAAAQARAAUJFQOLBQAAAQAAAA==.',
['丷南']='丷南鸢北筏:BAAALgAECgEJAQAAAA==.',
['丷老']='丷老呢:BAAALgAECgQJDAAAAA==.',
['为哔']='为哔哩哔哩来:BAAALgAECgMJAwAAAA==.',
['为所']='为所欲为小菜:BAAALgAECgUJBQAAAA==.',
['主子']='主子的铲史官:BAACLgAFFH8KAAIUAAQJFwq1DwAEAQAUAAQJFwq1DwAEAQAuAAQKfxoAAxQACAnyGC0fAAgCABQACAnyGC0fAAgCABUAAgk2D2FmAHMAAAAA.',
['丿丶']='丿丶小迷糊:BAAALgAECgkJBQAAAA==.',
['久远']='久远寺有珠:BAAALgAECgkJCQAAAA==.久远彼方:BAAALgAFFAYJBAABLgAFFAcJBQALANIGAA==.',
['九叶']='九叶子:BAAALgADCgEJAQAAAA==.',
['九天']='九天玄梦:BAAALgAECgkJAwAAAA==.',
['二十']='二十的翘宝贝:BAAALgAECgQJBAAAAA==.',
['二狗']='二狗文:BAAALgAECgUJBgABLgAECgcJGQAEAKkiAA==.',
['二阶']='二阶堂希罗:BAAALgAFFAQJBAAAAA==.',
['云乔']='云乔:BAAALgAECgIJAwAAAA==.',
['云汐']='云汐若:BAAALgADCgUJBQAAAA==.',
['云游']='云游者唐慕玄:BAAALgADCgEJAQAAAA==.',
['云谁']='云谁之思:BAAALgADCgEJAQAAAA==.',
['亚森']='亚森江铁拳:BAAALgAECgYJBgAAAA==.',
['人生']='人生逆旅:BAAALgAECgYJDAAAAA==.',
['人造']='人造人七号丶:BAAALgAECgEJAQAAAA==.',
['今年']='今年一月:BAAALgADCgEJAQAAAA==.',
['仚仚']='仚仚大魔王:BAAALgAECgEJAQAAAA==.',
['伊丹']='伊丹丶怒风:BAAALgADCgYJBgAAAA==.',
['伊南']='伊南娜:BAAALgADCgUJBQAAAA==.',
['伊格']='伊格尼斯丶:BAABLgAECn8UAAILAAcJAxoWWwApAgALAAcJAxoWWwApAgAAAA==.',
['众生']='众生离绝:BAACLgAFFH8GAAIBAAMJThGFEQD0AAABAAMJThGFEQD0AAAuAAQKfxQAAwEABwn2HeMPAHkCAAEABwn2HeMPAHkCAAIABgmiCnEgACkBAAAA.',
['低桥']='低桥凉介:BAAALgAECgEJAQAAAA==.',
['体育']='体育生放烟花:BAAALgAECgcJDAAAAA==.',
['何以']='何以为:BAAALgAECgYJBgAAAA==.',
['何必']='何必问更筹:BAAALgADCgMJAwAAAA==.',
['你们']='你们走慢点:BAAALgAFFAQJAQAAAA==.',
['你是']='你是龙也好:BAAALgAECgYJDwAAAA==.',
['你看']='你看我牛逼不:BAAALgAECgEJAQAAAA==.',
['佳瑶']='佳瑶:BAAALgAECgUJCwAAAA==.',
['信仰']='信仰咕噜神教:BAABLgAFFH8GAAIDAAQJZhJsGQBAAQADAAQJZhJsGQBAAQAAAA==.',
['修罗']='修罗丶女王:BAAALgAECgEJAgAAAA==.',
['倾世']='倾世无悔:BAAALgAECgYJDwAAAA==.',
['倾言']='倾言:BAAALgADCgMJAwAAAA==.',
['偌柳']='偌柳扶风:BAAALgAECgcJCQAAAA==.',
['做个']='做个屁作业:BAAALgAECgEJAgAAAA==.',
['光大']='光大锤:BAAALgAECgcJEQAAAA==.',
['八舞']='八舞夕矢:BAAALgAECgkJCQAAAA==.',
['公正']='公正法治:BAAALgAECgIJAgAAAA==.',
['六丿']='六丿喰:BAACLgAFFH8NAAIBAAQJgRi4CQBUAQABAAQJgRi4CQBUAQAuAAQKfxsABAEACAl8H58UADsCAAEACAl8H58UADsCAAIABQn5F88eADgBABYAAwmUB548AIUAAAAA.',
['兰兰']='兰兰一:BAABLgAFFH8PAAMXAAYJux2iAQDiAQAXAAUJAB6iAQDiAQAYAAEJcwFIIQA6AAAAAA==.兰兰三:BAABLgAFFH8FAAMXAAQJkRQADwDwAAAXAAMJphAADwDwAAAYAAEJUwDlIQAtAAAAAA==.兰兰二:BAABLgAFFH8PAAMXAAYJxx7MAQDbAQAXAAUJcx7MAQDbAQAYAAEJKAOQIAA/AAAAAA==.',
['再生']='再生青天:BAABLgAFFH8GAAIZAAYJWhkAAAAAAAADAAYJWhkAAAAAAAAAAA==.',
['再见']='再见光环:BAAALgAECgQJBQAAAA==.',
['农妇']='农妇老妈:BAABLgAECn8VAAMOAAYJ+Ra6EACSAQAOAAYJ2xC6EACSAQANAAUJnBciVgBTAQAAAA==.',
['农田']='农田上的矿工:BAABLgAECn8YAAISAAkJNxLoDwAOAgASAAkJNxLoDwAOAgAAAA==.',
['冥之']='冥之厄运:BAAALgAECgEJAQAAAA==.',
['冰冻']='冰冻大苍蝇:BAAALgAECgYJDgAAAA==.',
['冰封']='冰封丶夕阳:BAAALgAECgQJBQAAAA==.',
['冰月']='冰月十四:BAAALgAECggJDwABLgAFFAIJAgAKAAAAAA==.',
['冰泉']='冰泉:BAAALgAECgEJAgAAAA==.',
['冰魂']='冰魂寒影:BAAALgAECgEJAQAAAA==.',
['冷刃']='冷刃封喉:BAAALgAFFAIJAgAAAA==.',
['凉城']='凉城:BAAALgAECgIJAgAAAA==.',
['凝神']='凝神花:BAACLgAFFH8LAAITAAUJzA4DCwCAAQATAAUJzA4DCwCAAQAuAAQKfxQAAhMACAljH6IbAK0CABMACAljH6IbAK0CAAAA.',
['凯兽']='凯兽天朱雀:BAAALgADCgEJAQAAAA==.',
['凯尔']='凯尔贝洛斯:BAAALgAECgcJBwAAAA==.',
['凯珊']='凯珊卓:BAACLgAFFH8IAAMaAAMJzxBbBABbAAAMAAIJ/wxbOACjAAAaAAEJbhhbBABbAAAuAAQKfxoABAwACAkZGXM9ABcCAAwABwkZGXM9ABcCABAAAwl5DNA8AMEAABoAAQkAADQoAFAAAAAA.',
['分分']='分分钟射死:BAAALgAECgEJAQAAAA==.',
['切勿']='切勿水中捞月:BAAALgAFFAIJAgAAAA==.',
['刑天']='刑天女娲:BAAALgAECgEJAwAAAA==.',
['刚玉']='刚玉之心:BAAALgAECgMJAwAAAA==.',
['初代']='初代兔子:BAAALgADCgEJAgAAAA==.',
['初音']='初音现在:BAAALgAECgQJBwAAAA==.',
['别乱']='别乱动鸭:BAAALgAECgEJAQAAAA==.',
['别什']='别什灬:BAAALgAECgEJAQAAAA==.',
['别叫']='别叫了不会奶:BAAALgADCgUJBQAAAA==.',
['别吃']='别吃技能了:BAABLgAFFH8FAAMbAAMJVhhUBQCjAAAbAAIJfRNUBQCjAAAcAAEJYwZVDABGAAAAAA==.',
['别控']='别控制:BAAALgAECgYJEgAAAA==.',
['努力']='努力当个猎手:BAAALgAECgcJCgAAAA==.',
['勇敢']='勇敢李香烟:BAAALgAECgYJDwAAAA==.',
['北京']='北京招财猫:BAAALgAECggJCwAAAA==.',
['北冥']='北冥有鱼:BAACLgAFFH8IAAILAAQJ5gjqFwC4AAALAAQJ5gjqFwC4AAAuAAQKfxQAAgsACAlpHOA+AH0CAAsACAlpHOA+AH0CAAAA.',
['北山']='北山有只橘猫:BAAALgAFFAQJBAABLgAFFAYJCgAOAH4fAA==.',
['十里']='十里雾雾:BAAALgADCgYJBwAAAA==.',
['千千']='千千结:BAAALgAECgEJAwAAAA==.',
['午时']='午时已啊啊:BAAALgADCgYJBgAAAA==.',
['卓越']='卓越的法神:BAAALgAECgUJCgAAAA==.卓越的颜颜:BAAALgAECgYJDgAAAA==.',
['单刷']='单刷者:BAAALgAECgYJBgAAAA==.',
['南果']='南果:BAAALgADCgEJAQAAAA==.',
['博大']='博大:BAAALgAECgcJEAAAAA==.',
['卩灬']='卩灬小乔:BAAALgAECgMJAQAAAA==.',
['反派']='反派小饼干:BAAALgAECgYJBQAAAA==.',
['口曝']='口曝君:BAAALgAFFAIJAgAAAA==.',
['只是']='只是一场闹剧:BAAALgAECgMJAwABLgAFFAcJBAAKAAAAAA==.',
['叫我']='叫我鸽鸽:BAABLgAFFH8HAAIUAAMJjAgZFgDDAAAUAAMJjAgZFgDDAAAAAA==.',
['可丽']='可丽可心:BAAALgADCgUJBQAAAA==.',
['可乐']='可乐猪猪:BAAALgAECgEJAgAAAA==.',
['可二']='可二乐:BAAALgADCgIJAgAAAA==.',
['可爱']='可爱小冰冰:BAAALgAECgYJCAAAAA==.',
['史迪']='史迪奇:BAAALgAECgYJBgAAAA==.',
['吉亦']='吉亦安:BAAALgAECgcJAQAAAA==.',
['吉薇']='吉薇乄艾尔:BAABLgAECn8WAAQFAAcJjB3oCAC4AQAEAAcJixycHgAHAgAFAAUJEh/oCAC4AQAdAAMJ/hHPCgChAAAAAA==.吉薇乄艾尔丶:BAAALgAFFAEJAQAAAA==.',
['吉赛']='吉赛尔邦辰:BAAALgAECgYJDAAAAA==.',
['吓死']='吓死的:BAAALgADCgYJBgAAAA==.',
['君冀']='君冀:BAAALgAFFAIJAgAAAA==.',
['吞了']='吞了大象:BAAALgADCgcJBwAAAA==.',
['吴家']='吴家之宝:BAAALgAECgkJCQABLgAFFAQJBgAcAAcWAA==.',
['呀哈']='呀哈哈:BAAALgAECggJCAAAAA==.呀哈哈呀:BAABLgAFFH8MAAIJAAMJJSQ9DwAvAQAJAAMJJSQ9DwAvAQAAAA==.',
['呆呆']='呆呆村五把手:BAAALgAFFAIJBAAAAA==.呆呆村熊男:BAAALgAECgQJBAAAAA==.',
['呆汪']='呆汪蠢喵笨:BAACLgAFFH8FAAILAAIJPhgINwC8AAALAAIJPhgINwC8AAAuAAQKfxYAAgsABwlRHdFRAEICAAsABwlRHdFRAEICAAAA.',
['咕克']='咕克汉姆:BAAALgAECgUJDQAAAA==.',
['咕咕']='咕咕雷:BAAALgAECgQJBAAAAA==.',
['咖啡']='咖啡丶不加糖:BAABLgAFFH8KAAILAAQJcwwUDQAoAQALAAQJcwwUDQAoAQAAAA==.',
['咱王']='咱王爷爷:BAAALgADCgcJBwAAAA==.',
['哈吉']='哈吉斯恶:BAABLgAECn8UAAIJAAcJARRRcQCZAQAJAAcJARRRcQCZAQAAAA==.',
['哪里']='哪里去挖:BAAALgAECgEJAQAAAA==.',
['啾咪']='啾咪猫:BAAALgAECgQJBAAAAA==.',
['啾啾']='啾啾小揪揪:BAABLgAFFH8FAAIeAAUJEgIAAAAAAAARAAUJEgIAAAAAAAAAAA==.',
['喃喃']='喃喃一:BAABLgAFFH8OAAMXAAYJ5xkSDgD7AAAXAAUJqhcSDgD7AAAYAAEJmwTnIQAsAAAAAA==.喃喃七:BAABLgAFFH8IAAMXAAQJLBquDQABAQAXAAMJWhiuDQABAQAYAAEJ0wEKIQA8AAAAAA==.喃喃三:BAABLgAFFH8OAAMXAAYJsxmXAAAqAgAXAAYJsxmXAAAqAgAYAAEJaQpGHgBIAAAAAA==.喃喃九:BAABLgAFFH8LAAMXAAQJExkZDgD6AAAXAAMJBxUZDgD6AAAYAAEJ1gKlIAA/AAAAAA==.喃喃二:BAABLgAFFH8OAAMXAAYJ1xxlBQB2AQAXAAUJUxxlBQB2AQAYAAEJ3AEDIQA8AAAAAA==.喃喃五:BAABLgAFFH8IAAMXAAQJHxlDDwDuAAAXAAMJJBVDDwDuAAAYAAEJlAHSIQAxAAAAAA==.喃喃八:BAABLgAFFH8IAAMXAAQJMB6CCgAuAQAXAAMJYiCCCgAuAQAYAAEJ5wKgIAA/AAAAAA==.喃喃六:BAABLgAFFH8LAAMXAAQJWBjdDQD+AAAXAAMJ8RbdDQD+AAAYAAEJQgFdIQA5AAAAAA==.喃喃十:BAABLgAFFH8JAAMXAAUJNRurBQBxAQAXAAQJbxqrBQBxAQAYAAEJYAFOIQA5AAAAAA==.喃喃四:BAABLgAFFH8MAAMXAAUJtxnWBgBYAQAXAAQJ3RbWBgBYAQAYAAEJKgN/IABAAAAAAA==.',
['喉入']='喉入:BAAALgAECgMJAwAAAA==.',
['嘴硬']='嘴硬欠吻丶:BAAALgAECgkJCQAAAA==.',
['团灭']='团灭制作机:BAAALgAECgYJEAAAAA==.',
['圈哥']='圈哥:BAAALgAECgYJCAAAAA==.',
['土生']='土生蕊穗:BAAALgAECgYJDgAAAA==.',
['圣光']='圣光之宸:BAAALgAECgYJCwAAAA==.圣光呆呆兽:BAAALgADCgUJBQAAAA==.圣光污啊:BAABLgAECn8bAAMJAAgJ1hY/cQCZAQAJAAcJYxQ/cQCZAQAIAAIJgQK0hgBfAAAAAA==.圣光瓶:BAAALgADCgcJBwAAAA==.',
['圣的']='圣的光明:BAAALgAECgEJAQAAAA==.',
['在妮']='在妮头上爆寇:BAAALgAECgMJAwAAAA==.',
['坚强']='坚强的淀粉肠:BAAALgADCgUJBQAAAA==.',
['垂眼']='垂眼入星辰:BAAALgAECgcJBwAAAA==.',
['塔奇']='塔奇怪:BAAALgAECgYJBgAAAA==.',
['塔骑']='塔骑米:BAAALgAECgEJAQAAAA==.',
['塞拉']='塞拉:BAAALgAECgEJAQAAAA==.',
['墨隐']='墨隐丨清秋:BAABLgAFFH8LAAIbAAQJ/x5xAgCHAQAbAAQJ/x5xAgCHAQAAAA==.',
['夏日']='夏日青提:BAAALgAECgEJAQAAAA==.',
['夜航']='夜航船:BAAALgAECgMJAwAAAA==.',
['大宗']='大宗湿:BAAALgAECgEJAQAAAA==.',
['大懵']='大懵:BAAALgAFFAIJAwAAAA==.',
['大老']='大老牛:BAAALgAFFAIJAwAAAA==.',
['大耳']='大耳喵神:BAACLgAFFH8HAAIVAAQJ4QzmBQAiAQAVAAQJ4QzmBQAiAQAuAAQKfygAAhUACAlXIjoGAB0DABUACAlXIjoGAB0DAAAA.',
['大胡']='大胡子:BAAALgAFFAEJAQAAAA==.',
['天地']='天地阔且徜徉:BAAALgAFFAQJBAAAAA==.',
['天堂']='天堂岛:BAAALgADCgYJBgAAAA==.',
['太叔']='太叔绯:BAACLgAFFH8NAAILAAUJoBukCwDAAQALAAUJoBukCwDAAQAuAAQKfxsAAgsACAkWHmIrAMUCAAsACAkWHmIrAMUCAAAA.',
['太寿']='太寿究躺:BAAALgADCgIJAgAAAA==.',
['太阳']='太阳白子:BAABLgAFFH8MAAIBAAQJ3iFKBgCWAQABAAQJ3iFKBgCWAQAAAA==.',
['奈特']='奈特艾尔芙:BAAALgAECgEJAQAAAA==.',
['奥利']='奥利奥奶盖:BAAALgAECgcJDQAAAA==.',
['奶豆']='奶豆:BAAALgAECgYJBwAAAA==.',
['如小']='如小德:BAAALgAECgEJAQAAAA==.',
['妹妹']='妹妹的嘴真香:BAAALgAECggJCAAAAA==.',
['娟娟']='娟娟卷卷头:BAAALgAECgYJCwAAAA==.',
['婳帘']='婳帘:BAAALgADCgMJAwAAAA==.',
['安丶']='安丶排:BAAALgAFFAIJBAAAAA==.',
['安娜']='安娜斯塔斯娅:BAAALgADCgIJAgAAAA==.',
['安舍']='安舍之怒:BAAALgAECgMJAwAAAA==.',
['宏之']='宏之衍:BAACLgAFFH8LAAMMAAUJhybIAQAiAgAMAAUJdSbIAQAiAgAQAAEJ9SUvEABnAAAuAAQKfxsAAwwACAmvIvwGAFEDAAwACAmlIvwGAFEDABAABgnPI2EGAGkCAAEuAAMKAgkCAAoAAAAA.',
['小五']='小五:BAAALgAFFAIJBAAAAA==.小五五小五五:BAAALgAFFAIJAwAAAA==.小五小五小五:BAAALgAECgkJAwAAAA==.',
['小反']='小反射狐:BAAALgAECgYJCwAAAA==.',
['小塔']='小塔奇:BAAALgAFFAEJAQAAAA==.',
['小小']='小小怪大魔王:BAAALgAECgEJAQAAAA==.小小蓝:BAABLgAECn8VAAIGAAYJkw0HHwAIAQAGAAYJkw0HHwAIAQAAAA==.',
['小拽']='小拽娃娃:BAAALgAECgkJBwAAAA==.',
['小朱']='小朱诺诺的:BAABLgAECn8fAAMfAAkJZSEMDADfAgAfAAkJZSEMDADfAgARAAkJORyrDADNAgAAAA==.',
['小猫']='小猫一直响:BAAALgAFFAQJAwAAAA==.',
['小西']='小西:BAAALgAECgUJBQAAAA==.',
['小雪']='小雪冰冰:BAAALgAECgYJCwAAAA==.',
['小青']='小青柠:BAAALgAECgMJBgAAAA==.',
['小飞']='小飞机幢大楼:BAAALgAECgEJAQAAAA==.',
['小麦']='小麦果帜:BAAALgAECgMJAwAAAA==.',
['少女']='少女与梦:BAAALgAECgEJAgAAAA==.',
['尼尔']='尼尔迪兰狄:BAAALgAECgEJAQAAAA==.',
['岚岚']='岚岚库:BAABLgAFFH8PAAMXAAYJpRpiAgBvAQAXAAUJOxpiAgBvAQAYAAEJCAPrDwBBAAAAAA==.',
['巴巴']='巴巴托斯:BAACLgAFFH8LAAIUAAUJgQ4eCABQAQAUAAUJgQ4eCABQAQAuAAQKfxsAAhQACAndGfIVAFoCABQACAndGfIVAFoCAAAA.',
['希佩']='希佩托特克:BAAALgADCgIJAwAAAA==.',
['席尔']='席尔瓦那小狐:BAAALgAECgQJBwAAAA==.',
['帮我']='帮我想个名字:BAAALgAECggJCwAAAA==.',
['幻海']='幻海同游:BAAALgAECgYJBAAAAA==.',
['幽兰']='幽兰芬芳:BAAALgAECgEJAQAAAA==.',
['幽術']='幽術:BAAALgAFFAEJAQAAAA==.',
['库兰']='库兰德斯勋爵:BAAALgAECgYJCAAAAA==.',
['弑魔']='弑魔:BAAALgAECgQJBQAAAA==.',
['张某']='张某丙:BAAALgAECgcJDgABLgAECgkJCQAKAAAAAA==.',
['影武']='影武神:BAAALgAFFAIJAgAAAA==.',
['得伊']='得伊阿尼拉:BAAALgAECgEJAQAAAA==.',
['微笑']='微笑了五年:BAAALgAECgEJAgAAAA==.',
['徳高']='徳高德高望重:BAAALgAECgQJCQAAAA==.',
['德尔']='德尔森:BAAALgAECgEJAQAAAA==.',
['必须']='必须守护之人:BAABLgAFFH8GAAITAAQJcwyDFAAuAQATAAQJcwyDFAAuAQAAAA==.',
['怼死']='怼死算逑:BAAALgAFFAEJAQAAAA==.',
['恩情']='恩情曼巴:BAABLgAECn8VAAIMAAYJ9hBCgABaAQAMAAYJ9hBCgABaAQAAAA==.',
['恩赐']='恩赐丨解脱:BAAALgAECgUJBgAAAA==.',
['恶魔']='恶魔丶果实:BAAALgADCgQJBQAAAA==.',
['愤怒']='愤怒的火鸟:BAAALgAECgUJBAAAAA==.',
['慕拉']='慕拉丁铜须:BAAALgADCgEJAQAAAA==.',
['慕湮']='慕湮丨:BAAALgAFFAEJAQAAAA==.',
['我就']='我就来搞事:BAAALgAECgYJCQAAAA==.',
['我师']='我师父叫三藏:BAABLgAFFH8FAAIBAAMJ9ByLBgAdAQABAAMJ9ByLBgAdAQAAAA==.',
['我很']='我很丶抱歉:BAAALgAFFAEJAQAAAA==.',
['我有']='我有可能噬灭:BAABLgAFFH8GAAITAAQJYRVNIQDGAAATAAQJYRVNIQDGAAAAAA==.',
['我的']='我的我的溜了:BAAALgADCgUJAgAAAA==.',
['我血']='我血兽呢:BAAALgAFFAIJAgAAAA==.',
['我要']='我要睡觉了:BAAALgAFFAIJAwAAAA==.我要起床了:BAABLgAFFH8FAAMEAAMJ/RfpCwAlAQAEAAMJ/RfpCwAlAQAFAAEJRBGNBgBZAAAAAA==.',
['我超']='我超能喝:BAAALgAECgUJBQABLgAFFAEJAQAKAAAAAA==.',
['战复']='战复我呀:BAAALgADCgMJAwAAAA==.',
['战狠']='战狠昊京:BAAALgAECgEJAQAAAA==.',
['拜托']='拜托放過我:BAAALgADCgEJAQAAAA==.',
['指定']='指定不黑:BAABLgAECn8VAAMgAAYJAx3LGQDuAQAgAAYJAx3LGQDuAQAUAAIJ4AcaeABiAAAAAA==.',
['振鸿']='振鸿:BAAALgAECgYJDAAAAA==.',
['挼动']='挼动了:BAABLgAFFH8KAAMhAAUJTgZzAgAyAQAhAAQJ+QdzAgAyAQAYAAEJTAGbIQA2AAAAAA==.',
['揪揪']='揪揪酒酒:BAAALgADCgEJAQAAAA==.',
['撒野']='撒野米或:BAAALgAFFAMJBAAAAA==.',
['收手']='收手吧阿祖:BAAALgADCgUJBQAAAA==.',
['整日']='整日嘻嘻哈哈:BAABLgAECn8XAAQiAAcJmQxYJwBbAQAiAAcJQAtYJwBbAQAbAAQJUAcwXwC1AAAcAAIJXQhXVgBmAAAAAA==.',
['无奈']='无奈的豆豆:BAABLgAECn8ZAAMbAAgJIxffKwCYAQAbAAgJsBPfKwCYAQAiAAUJnw7qDwCuAAAAAA==.',
['无影']='无影刀锋:BAAALgADCgQJBAAAAA==.',
['无悔']='无悔丶圣:BAACLgAFFH8OAAIJAAUJOyW7AQAEAgAJAAUJOyW7AQAEAgAuAAQKfyAAAgkACAmKJk8EAIgDAAkACAmKJk8EAIgDAAAA.无悔丶战:BAAALgAFFAIJAgAAAA==.',
['无敌']='无敌最最俊朗:BAAALgADCggJCAAAAA==.',
['无耻']='无耻圣光:BAAALgAECggJCAAAAA==.',
['无赖']='无赖男:BAABLgAFFH8GAAIjAAMJyQBuDACDAAAjAAMJyQBuDACDAAAAAA==.',
['时刻']='时刻自我:BAAALgADCgMJAwAAAA==.',
['易水']='易水凌风:BAAALgAECgIJAwAAAA==.易水悠悠:BAAALgAECgMJBAAAAA==.',
['星之']='星之哀伤:BAAALgAECgYJCgAAAA==.',
['星极']='星极超流:BAAALgAECgYJBwAAAA==.',
['春天']='春天的枫:BAAALgADCgEJAQAAAA==.',
['昨夜']='昨夜书:BAAALgAFFAMJBAAAAA==.',
['是一']='是一只阿鱼鸭:BAAALgADCgUJBQAAAA==.',
['是不']='是不是来两炮:BAAALgAECgIJAwAAAA==.',
['晓角']='晓角:BAAALgAECgQJBQAAAA==.',
['晨风']='晨风夜月:BAAALgADCgYJBgAAAA==.',
['暗夜']='暗夜兽医:BAAALgAECgUJBQAAAA==.',
['暗影']='暗影之风暴猎:BAAALgADCgQJAQAAAA==.',
['暗物']='暗物质皇堡:BAAALgAECgEJAQAAAA==.',
['暗黑']='暗黑之不朽:BAAALgAECgEJAQAAAA==.暗黑睦头:BAACLgAFFH8IAAIcAAQJgR04BQB7AQAcAAQJgR04BQB7AQAuAAQKfx0AAxwACQnfJDABAMQDABwACQnfJDABAMQDACIAAgnbDfNKAGoAAAAA.',
['暴怒']='暴怒冲天火:BAAALgAECgEJAQAAAA==.',
['暴风']='暴风城卫兵:BAAALgADCgIJAgAAAA==.',
['曾經']='曾經的執著丶:BAAALgAECgUJBgAAAA==.',
['月之']='月之荧:BAAALgAECggJDgAAAA==.',
['月光']='月光吟游者:BAAALgAECgcJDwAAAA==.',
['月岛']='月岛希良梨:BAAALgAECgYJCwAAAA==.',
['月无']='月无缺:BAAALgADCgIJAgAAAA==.',
['月染']='月染星河:BAAALgAECgYJBgAAAA==.',
['月满']='月满轩尼诗:BAAALgAECgQJCQAAAA==.',
['未照']='未照耀的荣光:BAAALgAECgkJCwAAAA==.',
['朱柯']='朱柯颉:BAABLgAECn8WAAMVAAgJviD3EwBPAgAVAAYJxh/3EwBPAgAUAAIJLCO3XQDMAAAAAA==.',
['朵朵']='朵朵酱:BAAALgAECgYJAQAAAA==.',
['权雉']='权雉龙:BAAALgADCgQJBAAAAA==.',
['李砚']='李砚辰:BAAALgAECgIJAgAAAA==.',
['来了']='来了嗷嗨害:BAAALgADCgIJAgAAAA==.',
['来二']='来二两:BAAALgAECgEJAQAAAA==.',
['松玉']='松玉黯沉香:BAABLgAFFH8MAAITAAQJmhTpCAAnAQATAAQJmhTpCAAnAQAAAA==.',
['极昼']='极昼:BAAALgAFFAQJBAAAAA==.',
['林雨']='林雨枫:BAAALgADCgEJAQAAAA==.',
['枫暴']='枫暴之聲:BAAALgAFFAEJAgAAAA==.',
['柏崎']='柏崎加奈:BAAALgAECgYJBgAAAA==.',
['柒月']='柒月杌殇:BAAALgAFFAQJBAAAAA==.',
['柔情']='柔情信仰骑:BAABLgAFFH8GAAIJAAIJlSX3GADiAAAJAAIJlSX3GADiAAAAAA==.',
['柔琴']='柔琴:BAAALgADCgQJBAAAAA==.',
['柚子']='柚子宁宁:BAABLgAECn8iAAMTAAgJaRJeTQDAAQATAAgJuxFeTQDAAQAkAAYJkBFqFAAOAQAAAA==.',
['柯尼']='柯尼斯卷毛咕:BAAALgAECgUJBQAAAA==.',
['栖星']='栖星月:BAAALgAECgMJAwAAAA==.',
['栖枝']='栖枝故梦:BAAALgAFFAIJBAAAAA==.',
['格勒']='格勒白煤球:BAAALgAECgcJCwAAAA==.',
['桃语']='桃语浔川:BAAALgAECgkJDQAAAA==.',
['桐叶']='桐叶知秋:BAABLgAECn8UAAMGAAkJ/hD3QACsAQAGAAgJ8Q33QACsAQAPAAgJ1g1eNQCRAQAAAA==.',
['梦中']='梦中追魂:BAAALgAECgcJAQAAAA==.',
['梦回']='梦回虚空:BAAALgADCgUJBwAAAA==.',
['梳樓']='梳樓听雨:BAAALgADCgIJAgAAAA==.',
['森林']='森林暮谷:BAAALgAECgQJBgAAAA==.',
['楠楠']='楠楠一:BAABLgAFFH8JAAMXAAUJWRcFBwBVAQAXAAQJbhQFBwBVAQAYAAEJRAFiIQA5AAAAAA==.楠楠三:BAABLgAFFH8IAAMXAAQJERzSDAANAQAXAAMJPxvSDAANAQAYAAEJ9QKRIAA/AAAAAA==.楠楠二:BAABLgAFFH8HAAMXAAUJKhJBBwBRAQAXAAQJ0RJBBwBRAQAYAAEJNAFrIQA4AAAAAA==.楠楠五:BAAALgAFFAMJAQAAAA==.楠楠六:BAAALgAFFAIJAgAAAA==.楠楠四:BAABLgAFFH8FAAMXAAMJ8RbVFQCpAAAXAAIJlhbVFQCpAAAYAAEJvQEXIQA8AAAAAA==.',
['槑槑']='槑槑鸟:BAAALgAECgUJBQAAAA==.',
['欧瑞']='欧瑞费尔:BAABLgAECn8bAAIJAAYJ5BSTHwAxAQAJAAYJ5BSTHwAxAQAAAA==.',
['欧阳']='欧阳秋月:BAAALgAECgcJBgAAAA==.',
['武僧']='武僧僧:BAAALgADCgYJBgAAAA==.武僧阿泰:BAABLgAECn8ZAAIUAAcJFgyMPwBHAQAUAAcJFgyMPwBHAQAAAA==.',
['武见']='武见妙:BAABLgAFFH8IAAMlAAMJNRJzAwCyAAAJAAMJNRKkFwDxAAAlAAMJkwxzAwCyAAAAAA==.',
['死骑']='死骑之神:BAABLgAECn8wAAQSAAcJhRFEGQCLAQASAAcJhRFEGQCLAQADAAUJNAcz0wDbAAAmAAEJ5AOKGQAoAAAAAA==.',
['殤訫']='殤訫布布:BAAALgADCgEJAQAAAA==.',
['毒特']='毒特风行者:BAAALgAECgUJBgAAAA==.',
['毛絨']='毛絨絨:BAABLgAFFH8LAAILAAUJjBfwCgDGAQALAAUJjBfwCgDGAQAAAA==.',
['水空']='水空灵:BAAALgAECgEJAQAAAA==.',
['氵好']='氵好大鹅氵:BAAALgAECgcJBwAAAA==.',
['永久']='永久月焦謳:BAAALgADCgYJBgABLgAFFAMJCAAaAM8QAA==.',
['沃看']='沃看怎么个事:BAAALgADCgYJBgAAAA==.',
['沙耶']='沙耶米:BAAALgAECgcJCwAAAA==.',
['没天']='没天理:BAAALgAECgQJBAAAAA==.',
['没猫']='没猫饼:BAAALgAFFAIJAgAAAA==.',
['油焖']='油焖牛排:BAAALgAECggJDQAAAA==.',
['法克']='法克汉姆:BAAALgAFFAIJAgAAAA==.',
['法凤']='法凤鸩:BAAALgAECggJEQAAAA==.',
['波奇']='波奇酱:BAAALgADCgEJAQAAAA==.',
['波比']='波比灬:BAAALgAFFAEJAwAAAA==.波比灬丨:BAAALgADCgYJBgAAAA==.',
['洛星']='洛星繁:BAAALgAECgcJCAAAAA==.',
['洛琪']='洛琪:BAAALgAECgcJDQAAAA==.',
['洛迦']='洛迦丶鬼神:BAAALgAECgYJCwAAAA==.洛迦丶鬼鬼:BAABLgAECn8YAAILAAcJUBQdeQDfAQALAAcJUBQdeQDfAQAAAA==.',
['流刃']='流刃若芒:BAACLgAFFH8JAAIJAAMJ+CFtBQA6AQAJAAMJ+CFtBQA6AQAuAAQKfxQAAgkACAmkI7sPABEDAAkACAmkI7sPABEDAAAA.',
['流水']='流水线霸总:BAAALgAECgUJBQAAAA==.',
['涅磐']='涅磐新生:BAACLgAFFH8LAAIgAAUJHx3OAgDaAQAgAAUJHx3OAgDaAQAuAAQKfxsAAiAACAkiItgEABsDACAACAkiItgEABsDAAAA.',
['消失']='消失的祂:BAAALgAECgEJAwAAAA==.',
['消逝']='消逝丶:BAABLgAFFH8HAAIXAAMJ1Q+0EADjAAAXAAMJ1Q+0EADjAAAAAA==.',
['清蒸']='清蒸还是红烧:BAAALgAFFAIJAgABLgAFFAYJEgAXAG8iAA==.',
['清黎']='清黎:BAAALgAECgIJAQAAAA==.',
['湫湫']='湫湫:BAAALgAECgYJBgAAAA==.',
['湮灭']='湮灭龙:BAAALgAECgcJDgAAAA==.',
['漆黑']='漆黑的飞飞:BAAALgAECgcJDwAAAA==.',
['灬局']='灬局外人灬:BAAALgAECggJBgABLgAFFAYJFwAbANsRAA==.',
['灬银']='灬银灬翼灬:BAAALgAECgUJBQAAAA==.',
['灰烬']='灰烬觉醒:BAACLgAFFH8GAAIJAAIJORcjDwCrAAAJAAIJORcjDwCrAAAuAAQKfxYAAgkABwn4IvAYANMCAAkABwn4IvAYANMCAAAA.',
['灵魂']='灵魂果实:BAAALgAECgYJBgAAAA==.',
['炙热']='炙热的心殇:BAAALgAECgkJAwAAAA==.',
['烁影']='烁影浮光:BAAALgAECgkJCQAAAA==.',
['烈火']='烈火西风:BAAALgAECgEJAQAAAA==.',
['烈阳']='烈阳闪光:BAAALgAECgEJAQAAAA==.',
['热心']='热心橘子:BAAALgADCgUJBQAAAA==.',
['焚天']='焚天之炎:BAAALgADCggJCAAAAA==.焚天利爪:BAAALgAECgcJBwAAAA==.焚天烈焰:BAAALgAECgQJBAAAAA==.',
['焦糖']='焦糖蛋奶酥:BAEALgADCgYJBgAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAcAAcWAA==.',
['爱吃']='爱吃香菜:BAAALgAECgIJAgAAAA==.',
['爱喝']='爱喝特仑苏:BAAALgAECgkJCgAAAA==.',
['爱豆']='爱豆:BAAALgADCgUJBQAAAA==.',
['牙疼']='牙疼丶:BAAALgAECgEJAQAAAA==.',
['牛尼']='牛尼酱:BAAALgAFFAIJBAAAAA==.',
['牛油']='牛油火锅丨:BAAALgAECgEJAQAAAA==.',
['牛瘪']='牛瘪:BAAALgAECgYJCAAAAA==.',
['牛肉']='牛肉人没图腾:BAAALgAECgUJBQABLgAFFAMJBwAUAPoLAA==.',
['特朗']='特朗德尔:BAAALgAECgcJBwAAAA==.',
['狂丶']='狂丶三:BAAALgAECgMJAwAAAA==.',
['狂风']='狂风图腾:BAAALgAECgkJAgAAAA==.',
['猎魔']='猎魔阿呦:BAAALgADCgEJAQAAAA==.',
['猫熊']='猫熊战:BAAALgAECgcJDwAAAA==.',
['猫爪']='猫爪小山竹:BAAALgAECgkJCQAAAA==.',
['獭獭']='獭獭露:BAACLgAFFH8IAAIUAAMJBiG2CwAoAQAUAAMJBiG2CwAoAQAuAAQKfxgAAxQABgkwI9oVAFsCABQABgkwI9oVAFsCABUAAQmKCLuDAC0AAAAA.',
['玛力']='玛力露:BAAALgADCgUJBQAAAA==.',
['玩增']='玩增强玩的:BAECLgAFFH8GAAIOAAIJbhsVBQDGAAAOAAIJbhsVBQDGAAAuAAQKfxQAAw4ABgl1ImAOALYBAA4ABQkXIGAOALYBAA0ABQkMIS9TAF0BAAAA.',
['球球']='球球跑:BAAALgADCgcJBwAAAA==.',
['琦霖']='琦霖:BAACLgAFFH8KAAILAAUJwyEMBgAAAgALAAUJwyEMBgAAAgAuAAQKfxsAAgsACAmSIfEWACADAAsACAmSIfEWACADAAAA.',
['琴师']='琴师丶:BAAALgAECgUJCAAAAA==.',
['璐星']='璐星守护:BAAALgADCgMJAwAAAA==.',
['甘棠']='甘棠丶:BAAALgAECgYJBgAAAA==.',
['甘露']='甘露寺岁璃:BAAALgAECgIJAgABLgAECgYJDgAKAAAAAA==.',
['甜栗']='甜栗猫:BAECLgAFFH8LAAITAAUJ/hjXBwCnAQATAAUJ/hjXBwCnAQAuAAQKfx0AAxMACQn4IVUHAFMDABMACQn4IVUHAFMDAAcAAwkbFcpFAN4AAAEuAAUUBQkMABUAsiMA.',
['男妈']='男妈妈:BAACLgAFFH8GAAIVAAQJTgxaBQAzAQAVAAQJTgxaBQAzAQAuAAQKfycAAhUACAlGIuwGABADABUACAlGIuwGABADAAAA.',
['白白']='白白会出手:BAAALgAFFAIJBAAAAA==.',
['白色']='白色大魔:BAAALgAECgMJAwAAAA==.',
['白虎']='白虎糯又甜:BAAALgADCgEJAQAAAA==.',
['百分']='百分百禅师:BAAALgAECgYJBgAAAA==.',
['百炼']='百炼嘉维尔:BAAALgAFFAEJAgAAAA==.',
['皮德']='皮德仔:BAAALgAECgMJAwAAAA==.',
['皮怪']='皮怪丶:BAAALgADCgEJAQAAAA==.',
['皮没']='皮没那么痒:BAAALgAECgEJAQAAAA==.',
['看我']='看我脸色行事:BAAALgAECgcJAQABLgAFFAgJAQAKAAAAAA==.',
['眯露']='眯露:BAAALgADCgEJAQAAAA==.',
['眼冒']='眼冒圣光:BAAALgADCgIJAgAAAA==.',
['知君']='知君仙骨:BAAALgAECgcJDQAAAA==.',
['神佑']='神佑者:BAAALgAECgUJBQAAAA==.',
['神经']='神经少年:BAAALgAECgMJAwAAAA==.',
['离荼']='离荼丶:BAAALgAECgYJCwAAAA==.',
['秋哥']='秋哥:BAAALgADCgEJAQAAAA==.秋哥丿:BAAALgAECgEJAQAAAA==.',
['秋景']='秋景酱酱:BAAALgAECgYJBgAAAA==.',
['秋葉']='秋葉:BAAALgAFFAMJAwAAAA==.',
['科亚']='科亚:BAAALgAECgcJBwAAAA==.',
['稀奇']='稀奇古怪:BAAALgADCgIJAgAAAA==.',
['稚嫩']='稚嫩小白虎:BAAALgADCgUJBQAAAA==.',
['竹海']='竹海抄:BAAALgAECgEJAQAAAA==.',
['第四']='第四天灾丶:BAAALgAECgYJDwAAAA==.',
['米汀']='米汀:BAAALgAECgcJBgAAAA==.米汀的菠萝包:BAAALgADCgUJBQAAAA==.',
['米纳']='米纳斯伊希尔:BAAALgAECgYJBgAAAA==.',
['糕冷']='糕冷小喵:BAABLgAFFH8FAAIDAAIJIB91EgDOAAADAAIJIB91EgDOAAAAAA==.',
['糖果']='糖果派对:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门领主:BAAALgADCgYJBgAAAA==.',
['紫烟']='紫烟云:BAAALgAECgkJCQAAAA==.紫烟霜露:BAAALgAECgcJAwAAAA==.',
['红呆']='红呆毛:BAAALgAECgUJBQAAAA==.',
['红绯']='红绯鱼:BAAALgAECgYJEwAAAA==.',
['红薯']='红薯妹:BAAALgAECgEJAQAAAA==.',
['织田']='织田晨琳:BAAALgAECgQJBQAAAA==.',
['结局']='结局不该如此:BAABLgAFFH8IAAIHAAQJfRovAgBxAQAHAAQJfRovAgBxAQAAAA==.',
['绝年']='绝年:BAAALgAFFAIJAwAAAA==.',
['缺月']='缺月阕:BAAALgADCgIJAgAAAA==.',
['美咲']='美咲小天使:BAACLgAFFH8FAAISAAQJhgk6CQD0AAASAAQJhgk6CQD0AAAuAAQKfxgAAhIACAlLF3IDALgBABIACAlLF3IDALgBAAAA.',
['群雄']='群雄丶逐鹿灬:BAAALgAFFAEJAQAAAA==.群雄逐鹿灬:BAAALgAECgQJBAAAAA==.',
['羿射']='羿射九日:BAAALgAECgcJBgAAAA==.',
['老瞎']='老瞎眼儿:BAAALgAECgUJBwAAAA==.',
['老陈']='老陈醋可乐:BAAALgAECgYJBgAAAA==.',
['耳钉']='耳钉牧九:BAAALgAECgQJBAAAAA==.',
['聋洗']='聋洗耳:BAAALgAFFAIJAgAAAA==.',
['胖胖']='胖胖女武神:BAABLgAFFH8FAAIJAAMJdQxGJACjAAAJAAMJdQxGJACjAAAAAA==.',
['能源']='能源之神:BAABLgAECn8dAAQnAAcJkA6uFgAJAQAoAAYJxQ2OFwBFAQAnAAcJAAyuFgAJAQAfAAUJgAOtmwCUAAABLgAECgcJMAASAIURAA==.',
['自然']='自然之咕:BAAALgAECgMJAwAAAA==.',
['自由']='自由镇镇长:BAAALgAFFAEJAQAAAA==.',
['舞小']='舞小德:BAAALgAECgEJAQAAAA==.舞小萨:BAAALgAECgEJAQAAAA==.',
['舞玥']='舞玥:BAAALgAFFAIJAgAAAA==.',
['般若']='般若怒目:BAAALgAECgcJEgAAAA==.',
['色骑']='色骑满满:BAAALgAFFAQJBAAAAA==.',
['艾尔']='艾尔风:BAACLgAFFH8GAAILAAMJ7gurMADwAAALAAMJ7gurMADwAAAuAAQKfxQAAgsACAnRITEZABQDAAsACAnRITEZABQDAAAA.',
['艾琳']='艾琳莉娅:BAAALgAECgcJBwABLgAECgkJCQAKAAAAAA==.',
['艾莉']='艾莉娜银翼:BAAALgAECgYJDAAAAA==.',
['艾萨']='艾萨拉克:BAAALgADCggJAgAAAA==.',
['艾薾']='艾薾旎懵:BAAALgAECgEJAQAAAA==.',
['花颜']='花颜腐朽的心:BAAALgAECgUJBQAAAA==.',
['苍琦']='苍琦栗子:BAAALgAECgYJBgAAAA==.',
['苏焰']='苏焰焰:BAAALgAECgYJBgAAAA==.',
['若爱']='若爱:BAACLgAFFH8LAAIfAAUJ+wvRBgBpAQAfAAUJ+wvRBgBpAQAuAAQKfxsAAx8ACAnYDzVJAH0BAB8ACAnYDzVJAH0BABEABgkPFgAyAHoBAAAA.',
['荒芒']='荒芒灿烂:BAAALgAECgMJAwAAAA==.',
['莉爷']='莉爷酱丶:BAAALgADCgYJBgAAAA==.',
['莫丶']='莫丶夕:BAAALgAFFAEJAQABLgAFFAcJBQALANIGAA==.',
['莳蘿']='莳蘿:BAAALgAECgcJBgAAAA==.',
['菜菜']='菜菜豆:BAAALgADCgYJBgAAAA==.',
['菠萝']='菠萝汉堡:BAAALgAECgQJBAAAAA==.',
['萌熊']='萌熊新猫:BAACLgAFFH8HAAIUAAMJ+gtEFQDLAAAUAAMJ+gtEFQDLAAAuAAQKfxUAAxQABwlmFXswAJMBABQABwlmFXswAJMBACAAAwn+Dv4UAJcAAAAA.',
['萝卜']='萝卜饺子:BAAALgAECgkJAgAAAA==.',
['萨里']='萨里萨气:BAAALgAECgcJBwAAAA==.',
['落日']='落日骑士:BAAALgAECgkJDwAAAA==.',
['蒓色']='蒓色灬魅惑:BAAALgADCgcJBgAAAA==.',
['蒙牛']='蒙牛奶丶温婉:BAAALgADCgEJAQAAAA==.',
['蒸羊']='蒸羊羔:BAAALgAECgEJAQAAAA==.',
['蓝光']='蓝光无马:BAAALgADCgEJAQAAAA==.',
['蓝熊']='蓝熊精:BAAALgADCgEJAQABLgAFFAMJBwAUAPoLAA==.',
['蓝羽']='蓝羽浅葱:BAACLgAFFH8SAAILAAYJixZRBAAqAgALAAYJixZRBAAqAgAuAAQKfzEAAgsACQltJVgCANkDAAsACQltJVgCANkDAAAA.',
['蓝色']='蓝色艾尔:BAAALgAECgEJAQAAAA==.',
['蓝蓝']='蓝蓝三:BAABLgAFFH8NAAMXAAYJxhOoAQCRAQAXAAUJQxKoAQCRAQAYAAEJcAIKEAA/AAAAAA==.蓝蓝二:BAABLgAFFH8OAAMXAAYJexq0BgBaAQAXAAUJqBm0BgBaAQAYAAEJ6gIaIQA7AAAAAA==.蓝蓝光:BAAALgADCgcJDAAAAA==.蓝蓝噜:BAAALgAFFAIJAgAAAA==.蓝蓝四:BAABLgAFFH8LAAMXAAYJLxOqCQA3AQAXAAUJphOqCQA3AQAYAAEJYADJIQAyAAAAAA==.',
['藤原']='藤原千花丶:BAACLgAFFH8GAAILAAMJkRySJAAjAQALAAMJkRySJAAjAQAuAAQKfx4AAgsACAn+H/8jAOMCAAsACAn+H/8jAOMCAAAA.',
['虚空']='虚空泡面:BAAALgAECgMJAwAAAA==.',
['蛇精']='蛇精大师:BAAALgADCgUJBQAAAA==.',
['蛋蛋']='蛋蛋白月光:BAAALgAECgcJEwAAAA==.',
['蜜璃']='蜜璃:BAAALgAECgQJBQAAAA==.',
['血之']='血之领主:BAAALgAECgEJAQAAAA==.',
['血兽']='血兽回不来了:BAABLgAFFH8HAAIDAAMJZSONHQArAQADAAMJZSONHQArAQAAAA==.',
['袖箭']='袖箭风暴:BAEALgADCgYJBgABLgAFFAIJBgAOAG4bAA==.',
['被用']='被用过的黄瓜:BAAALgAECgcJBgAAAA==.',
['被迫']='被迫改名的猫:BAABLgAECn8VAAMXAAYJ7QIpbwDTAAAXAAYJ7QIpbwDTAAAhAAYJEAPqCQChAAABLgAFFAQJDAAYAH4TAA==.',
['西城']='西城抚琴:BAAALgAECgUJAwAAAA==.',
['解放']='解放重卡:BAABLgAFFH8NAAIJAAUJ2BoTBACxAQAJAAUJ2BoTBACxAQAAAA==.',
['让暧']='让暧昧肆虐:BAABLgAECn8UAAMGAAkJfCJcAAAeAwAGAAkJYCBcAAAeAwAPAAkJdBz2EwCSAgAAAA==.',
['豆花']='豆花儿:BAAALgAECgYJCwAAAA==.',
['豆荚']='豆荚猫:BAAALgAECgYJCgAAAA==.',
['豆豆']='豆豆啊啊:BAAALgADCgcJBwAAAA==.豆豆的小德:BAAALgAECgMJAwAAAA==.豆豆的豆豆的:BAAALgAECgcJCAAAAA==.',
['豫讓']='豫讓:BAAALgAECgEJAQAAAA==.',
['贝果']='贝果:BAAALgAECgYJCAAAAA==.',
['贝贝']='贝贝龙:BAABLgAECn8WAAMBAAcJChwDEgBbAgABAAcJChwDEgBbAgAWAAcJLgFURgA/AAABLgAFFAIJAgAKAAAAAA==.',
['赫刺']='赫刺克勒斯:BAAALgAECgEJAgAAAA==.',
['起名']='起名丨:BAAALgAFFAIJAwAAAA==.',
['蹈锋']='蹈锋饮血:BAAALgAECgEJAQAAAA==.',
['蹦沙']='蹦沙卡拉卡:BAAALgADCgEJAQAAAA==.',
['轻影']='轻影坠馨:BAAALgADCgcJCQAAAA==.',
['轻风']='轻风吹劲酒:BAAALgAECgQJCQAAAA==.',
['辉夜']='辉夜:BAAALgAFFAEJAQAAAA==.',
['还说']='还说早安吗:BAAALgAECgEJAQAAAA==.',
['这什']='这什么摸一下:BAACLgAFFH8WAAIUAAUJTBSeBQB6AQAUAAUJTBSeBQB6AQAuAAQKfyMAAhQACAn8HZASAH4CABQACAn8HZASAH4CAAAA.',
['逆潮']='逆潮:BAAALgAECgYJCQAAAA==.',
['逍遥']='逍遥灬战:BAAALgAECgQJBQAAAA==.',
['逐光']='逐光之狼:BAABLgAECn8UAAIJAAgJ0BgZKgB8AgAJAAgJ0BgZKgB8AgAAAA==.',
['逝去']='逝去的可丽:BAAALgADCgMJBgAAAA==.',
['避避']='避避阳暑热:BAAALgAECgYJBwAAAA==.',
['那个']='那个老六:BAACLgAFFH8JAAIPAAUJ/RsBBwCtAQAPAAUJ/RsBBwCtAQAuAAQKfxsAAw8ACAkuH4gLAO0CAA8ACAkuH4gLAO0CAAYAAQnZHkPNADkAAAAA.',
['邪恶']='邪恶马铃薯:BAAALgAECgQJBgABLgAFFAEJAQAKAAAAAA==.',
['酒和']='酒和酒桶:BAAALgAECgQJBgAAAA==.',
['醉清']='醉清风:BAAALgAECgcJBwAAAA==.',
['醉酒']='醉酒虐佳人:BAAALgAECgEJAQAAAA==.',
['野原']='野原助小新:BAAALgAECgYJCAAAAA==.',
['野性']='野性成长:BAAALgAECgQJCQAAAA==.',
['鑫哥']='鑫哥大宝贝:BAAALgAECgEJAQAAAA==.',
['钢板']='钢板碎胸口:BAAALgAECgYJBgAAAA==.',
['铁柱']='铁柱丨:BAAALgAECgMJAwAAAA==.',
['铃龙']='铃龙:BAAALgAECgUJAwAAAA==.',
['银龙']='银龙女:BAAALgADCgYJBgAAAA==.',
['長夜']='長夜:BAAALgAFFAQJBAAAAA==.',
['長崎']='長崎爽世:BAAALgAECgMJAwAAAA==.',
['问荆']='问荆:BAAALgADCgQJBAAAAA==.',
['间隙']='间隙仙者:BAAALgADCgUJBQAAAA==.',
['防战']='防战之神:BAABLgAECn8oAAIjAAcJdwtiCAAHAQAjAAcJdwtiCAAHAQABLgAECgcJMAASAIURAA==.',
['防骑']='防骑练习生:BAAALgAECgUJBwAAAA==.',
['阿利']='阿利不背锅:BAAALgADCgcJEgAAAA==.',
['阿努']='阿努比斯:BAAALgAECgYJCgAAAA==.',
['阿卡']='阿卡丶瓜队:BAAALgAECgQJCQAAAA==.阿卡莎:BAAALgAECgUJBwAAAA==.',
['阿奇']='阿奇巴德曙光:BAAALgADCgQJBAAAAA==.',
['阿宝']='阿宝:BAAALgAECgQJBAAAAA==.',
['阿拉']='阿拉斯库:BAAALgAECgUJBQAAAA==.',
['阿米']='阿米娅不是驴:BAAALgADCgYJBgAAAA==.',
['阿蕾']='阿蕾奇诺:BAAALgAECgEJAQAAAA==.',
['阿鲁']='阿鲁卡撒:BAAALgADCgEJAQAAAA==.',
['陀陀']='陀陀是只猫:BAAALgAECgUJBwAAAA==.',
['除了']='除了睡就是吃:BAAALgAECgMJBgAAAA==.',
['陷入']='陷入云层:BAAALgAECgYJBgAAAA==.',
['随轻']='随轻风起舞:BAACLgAFFH8IAAIPAAQJIhH9DwAxAQAPAAQJIhH9DwAxAQAuAAQKfx0AAg8ACAlkHWgBAPwBAA8ACAlkHWgBAPwBAAAA.',
['集美']='集美不被定义:BAAALgAFFAEJAQAAAA==.',
['雕系']='雕系里:BAAALgAECgIJAwAAAA==.',
['雨烟']='雨烟:BAAALgAECgYJAgAAAA==.',
['雪地']='雪地猫猫:BAAALgAECgIJAgAAAA==.',
['雷克']='雷克:BAACLgAFFH8JAAMWAAUJfgQ/CABmAQAWAAUJfgQ/CABmAQABAAEJMwFjJQA7AAAuAAQKfxsABBYACAk6DDEcAKUBABYACAk6DDEcAKUBAAEABwmEDxUmAIwBAAIAAQmqAGtGABgAAAAA.',
['雷咕']='雷咕咕:BAAALgAECgMJAwAAAA==.',
['雾远']='雾远:BAAALgAECgEJAQAAAA==.',
['雾雾']='雾雾子:BAABLgAFFH8GAAIMAAIJhhWqMgCtAAAMAAIJhhWqMgCtAAAAAA==.',
['霜影']='霜影玄玑:BAAALgAECgEJAQABLgAECgkJAwAKAAAAAA==.',
['霸波']='霸波波儿奔:BAAALgAECgEJAQAAAA==.',
['靈音']='靈音:BAAALgAECgEJAgAAAA==.',
['青山']='青山揽梦:BAAALgADCgEJAQAAAA==.',
['青春']='青春止步于此:BAAALgAFFAQJBAAAAA==.',
['青青']='青青草飞:BAAALgAECgYJDAAAAA==.',
['非扩']='非扩散型病毒:BAAALgAFFAMJAwAAAA==.',
['面团']='面团:BAAALgAECgEJAQAAAA==.',
['顽疾']='顽疾:BAAALgAFFAQJAwAAAA==.',
['顾晓']='顾晓晓:BAAALgAECgIJAgABLgAFFAEJAQAKAAAAAA==.',
['风中']='风中游鱼:BAAALgAECgUJBgAAAA==.',
['飒夜']='飒夜迷惑:BAAALgAFFAEJAQAAAA==.',
['飞将']='飞将军:BAAALgADCgYJBgAAAA==.',
['饺子']='饺子:BAACLgAFFH8TAAQDAAUJGhmVEABfAQADAAQJGhmVEABfAQAmAAEJTgxwBABOAAASAAEJAAAFGQA4AAAuAAQKfxUAAwMACQkiG2c8AEYCAAMABwkIIGc8AEYCABIABgnvFTEXAKQBAAAA.',
['香格']='香格里拉:BAAALgAECgYJEgAAAA==.',
['骇人']='骇人精:BAAALgAECgMJAwAAAA==.',
['骨小']='骨小头:BAAALgAECgMJAwAAAA==.',
['骨镰']='骨镰:BAAALgAECgEJAQAAAA==.',
['高原']='高原野牛:BAAALgAECgIJAgAAAA==.',
['魅战']='魅战:BAAALgAECgUJBQAAAA==.',
['魔力']='魔力残渣:BAAALgAFFAIJAgAAAA==.',
['魔法']='魔法旋律丶:BAACLgAFFH8QAAILAAUJHx06CQDWAQALAAUJHx06CQDWAQAuAAQKfysAAgsACAmTI8cDAIUCAAsACAmTI8cDAIUCAAAA.',
['鯊鱼']='鯊鱼拳击手:BAAALgAECgUJBQAAAA==.',
['鲜奶']='鲜奶:BAAALgAECgYJBgAAAA==.',
['鲷之']='鲷之耐心:BAAALgAECgUJCwAAAA==.',
['鸥鹭']='鸥鹭:BAAALgAECgMJAwAAAA==.',
['鸿渐']='鸿渐于陆:BAAALgAECgEJAgAAAA==.',
['黑锋']='黑锋利刃:BAAALgAECggJDwAAAA==.',
['鼠条']='鼠条承太郎:BAAALgAECgYJEQAAAA==.',
['鼻孔']='鼻孔:BAAALgAECgkJEgAAAA==.鼻孔回冒烟:BAAALgAECgEJAQAAAA==.鼻孔小馒头:BAAALgAECgkJCgAAAA==.',
['龙丘']='龙丘墨:BAAALgAECgMJAwAAAA==.',
['龙皇']='龙皇异次元:BAAALgAFFAEJAQAAAA==.',
['龙霸']='龙霸灬天下:BAAALgAECgUJBgAAAA==.',
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
