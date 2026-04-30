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

local lookup = {'DemonHunter-Devourer','DemonHunter-Havoc','DeathKnight-Unholy','Unknown-Unknown','Warrior-Protection','Priest-Discipline','Hunter-Marksmanship','DeathKnight-Melee','DeathKnight-Blood','Mage-Frost','Shaman-Restoration','Priest-Holy','Paladin-Retribution','Paladin-Holy','Shaman-Elemental','Warrior-Arms','Warrior-Fury','Druid-Balance','Druid-Restoration','Warlock-Demonology','Warlock-Destruction','Paladin-Protection','Hunter-BeastMastery','Monk-Brewmaster','DeathKnight-Frost','Rogue-Subtlety','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Monk-Mistweaver','DemonHunter-Vengeance','Monk-Windwalker','Priest-Shadow','Hunter-Survival','Shaman-Enhancement','Druid-Guardian','Druid-Feral',}
local provider = {region='CN',realm='亡语者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agares:BAABLgAECn8UAAMBAAcJdxE5YQB9AQABAAcJdxE5YQB9AQACAAEJAACteQAqAAAAAA==.',
Ar='Arianagrande:BAAALgAECgIJBAAAAA==.',
As='Ashbringer:BAAALgAECgYJAwAAAA==.',
Bl='Bloodypurity:BAACLgAFFH8LAAIDAAQJpg4kHQAtAQADAAQJpg4kHQAtAQAuAAQKfx4AAgMABgllGkxvAKoBAAMABgllGkxvAKoBAAAA.',
Ch='Cheneys:BAAALgAECgYJDgAAAA==.Chromie:BAAALgAECgIJAgABLgAFFAEJAQAEAAAAAA==.',
Co='Cokes:BAAALgAECggJCAAAAA==.',
En='Enzoo:BAAALgAECgUJBwAAAA==.',
Eu='Eurydice:BAAALgAFFAMJBAAAAA==.',
Fa='Fakeit:BAAALgADCgEJAQAAAA==.',
Fl='Flansias:BAAALgAECgQJBAAAAA==.',
Fo='Forwhat:BAAALgAECgUJBwAAAA==.',
Ga='Galen:BAABLgAFFH8FAAIBAAMJuB7aMABxAAABAAMJuB7aMABxAAAAAA==.',
Go='Gotrek:BAACLgAFFH8HAAIFAAIJXQ8QDQB6AAAFAAIJXQ8QDQB6AAAuAAQKfxQAAgUABwn6FC8XAJ8BAAUABwn6FC8XAJ8BAAAA.',
Ha='Hashashin:BAAALgAECgEJAQAAAA==.',
He='Heimi:BAAALgAECgYJBgABLgAFFAUJEwAGAFsTAA==.Heimiw:BAAALgAECgEJAQABLgAFFAUJEwAGAFsTAA==.Herrington:BAAALgAFFAIJAwABLgAFFAMJAwAEAAAAAA==.Heymia:BAAALgADCgMJAwAAAA==.',
Ho='Honourless:BAAALgADCgEJAQAAAA==.Hoodwink:BAACLgAFFH8FAAIHAAMJBiF1EAAsAQAHAAMJBiF1EAAsAQAuAAQKfxUAAgcACQmiG+0RAKYCAAcACQmiG+0RAKYCAAAA.',
Ic='Icarus:BAAALgAECgEJAgAAAA==.',
Jy='Jyfortz:BAAALgAFFAMJAwAAAA==.',
Kr='Kronos:BAAALgAECgUJBQAAAA==.',
La='Laladracthyr:BAAALgAFFAEJAQAAAA==.',
Li='Lightnai:BAAALgAECgUJBQAAAA==.',
Lx='Lxack:BAAALgAFFAEJAgAAAA==.',
Ma='Mario:BAABLgAFFH8FAAIDAAUJnAWrEwBTAQADAAUJnAWrEwBTAQAAAA==.',
Mi='Miyagiryota:BAAALgAECgIJAwAAAA==.',
Mo='Moon:BAAALgAECgMJAwAAAA==.',
Mu='Muerta:BAAALgAFFAQJBAAAAA==.',
My='Mybo:BAAALgAECgQJBwAAAA==.',
Na='Nartina:BAAALgAECgUJBQAAAA==.',
Ne='Nearl:BAAALgAECgEJAwAAAA==.',
No='Noegg:BAACLgAFFH8FAAIIAAUJ2RwAAAAAAAAJAAUJ2RwAAAAAAAAuAAQKfxwAAgMACQntHnENAC4DAAMACQntHnENAC4DAAAA.',
Ob='Oblivionis:BAAALgADCgYJDAAAAA==.',
Ro='Rockroy:BAAALgAECgUJBQAAAA==.',
Sh='Shuangcaide:BAAALgAFFAEJAQAAAA==.',
Sk='Skadi:BAAALgAECgEJAQAAAA==.',
So='Someone:BAAALgAECgcJBgAAAA==.',
Su='Susana:BAAALgADCgcJBwAAAA==.',
Sw='Sweneytodd:BAAALgAECgYJBgAAAA==.',
Th='Thewound:BAAALgAECgYJBgAAAA==.',
Tr='Trickykiller:BAABLgAFFH8GAAIKAAMJshuvJAAiAQAKAAMJshuvJAAiAQAAAA==.',
Ud='Udaddy:BAAALgAECgEJAQAAAA==.',
Uu='Uu:BAAALgAFFAIJAgAAAA==.',
Wa='Waijieli:BAAALgADCgMJAwAAAA==.',
Wo='Wonyoung:BAAALgAECgcJBgAAAA==.',
Xy='Xyshaman:BAAALgAFFAQJAgABLgAFFAUJCQALAI4TAA==.Xyshamana:BAAALgAFFAQJBAAAAA==.Xyshamand:BAABLgAFFH8HAAILAAQJERnSBgBYAQALAAQJERnSBgBYAQABLgAFFAUJCQALAI4TAA==.Xyshamane:BAABLgAFFH8JAAILAAUJjhMCAgCBAQALAAUJjhMCAgCBAQAAAA==.Xyshamanf:BAAALgAFFAQJAwAAAA==.Xyshamani:BAAALgAFFAUJAwAAAA==.',
Ya='Yahamatalegn:BAAALgAECggJCAAAAA==.',
Yi='Yihao:BAAALgAECgYJDQAAAA==.',
Zh='Zhuruicong:BAAALgAECgIJAgAAAA==.',
['一切']='一切无视:BAAALgAFFAIJAgAAAA==.',
['一只']='一只小汤姆:BAAALgAECgEJAQAAAA==.',
['一季']='一季的天光:BAACLgAFFH8MAAMMAAQJ1QITBwABAQAGAAQJGgLCDAAEAQAMAAQJngITBwABAQAuAAQKfxcAAwwABgkiHSEcAPwBAAwABgkiHSEcAPwBAAYABAmfB7RHAIAAAAAA.',
['一根']='一根葱:BAAALgAECgEJAQAAAA==.',
['万化']='万化由心:BAAALgAFFAIJAgAAAA==.',
['万物']='万物尽焚:BAAALgAECgEJAQAAAA==.',
['上帝']='上帝伯爵:BAAALgAECgYJCgAAAA==.',
['不存']='不存在的:BAAALgAECgEJAQAAAA==.',
['不是']='不是猫图芽:BAAALgAFFAEJAgAAAA==.',
['不洗']='不洗都吃:BAAALgAECgcJCwAAAA==.',
['不玩']='不玩基:BAAALgAECgEJAQAAAA==.',
['东一']='东一哈西一哈:BAAALgAECgMJAwAAAA==.',
['中野']='中野一花:BAAALgAFFAIJAgAAAA==.',
['丶萌']='丶萌萌骑灬:BAAALgAECgkJDwAAAA==.',
['丸强']='丸强拼勃:BAAALgAFFAIJAwAAAA==.',
['为什']='为什么让我抗:BAAALgADCgYJBgAAAA==.',
['丽贝']='丽贝卡:BAAALgAFFAEJAQAAAA==.',
['丿丿']='丿丿丶丶丿:BAAALgAECgkJDwAAAA==.',
['丿炫']='丿炫月丶筱静:BAABLgAFFH8OAAINAAQJuxmbCABsAQANAAQJuxmbCABsAQAAAA==.',
['二二']='二二三四:BAAALgAFFAIJBAAAAA==.',
['云的']='云的彼端:BAACLgAFFH8FAAIMAAIJryA0CgDDAAAMAAIJryA0CgDDAAAuAAQKfxsAAgwABwlzIkQUADwCAAwABwlzIkQUADwCAAAA.',
['井到']='井到叫唤丶:BAAALgAECgYJDQAAAA==.',
['人在']='人在烟霞外丶:BAAALgAECgUJBQAAAA==.',
['伊凝']='伊凝檬:BAAALgAFFAIJBAAAAA==.',
['伊芙']='伊芙:BAABLgAECn8aAAIBAAkJLhdWHQCiAgABAAkJLhdWHQCiAgAAAA==.',
['伍十']='伍十个圣柒:BAAALgAECgkJCwAAAA==.',
['但偏']='但偏偏雨渐渐:BAAALgAFFAQJAgAAAA==.',
['余生']='余生:BAAALgADCgYJBgAAAA==.',
['你又']='你又掉线了:BAAALgAECgcJDgABLgAECgkJFwAFAMAcAA==.',
['你在']='你在狗叫什么:BAAALgAECgEJAQAAAA==.',
['你没']='你没吃饭吗:BAAALgADCgEJAgAAAA==.',
['信仰']='信仰的黑暗:BAABLgAFFH8PAAIKAAQJRB5LEwB+AQAKAAQJRB5LEwB+AQAAAA==.',
['偌一']='偌一:BAAALgAECgEJAgAAAA==.',
['做我']='做我旳猫:BAAALgAECgQJBAAAAA==.',
['做鬼']='做鬼也風流:BAAALgADCgUJBQAAAA==.',
['免费']='免费月光:BAAALgAECgUJBwAAAA==.',
['六瓣']='六瓣霜花:BAABLgAECn8ZAAMOAAcJqRTvNACpAQAOAAcJqRTvNACpAQANAAMJkRc12ADbAAAAAA==.',
['农比']='农比:BAAALgAECgQJBAAAAA==.',
['冰零']='冰零呈下:BAAALgAECgYJBgAAAA==.',
['冲钅']='冲钅丶:BAAALgAFFAIJAwAAAA==.',
['冷月']='冷月丶赤斧:BAAALgAECgYJCwAAAA==.冷月丶青眸:BAACLgAFFH8HAAINAAMJaRm1EwAJAQANAAMJaRm1EwAJAQAuAAQKfyEAAg0ACQnmHR8OAB0DAA0ACQnmHR8OAB0DAAAA.冷月丶黑角:BAAALgAECgYJDQAAAA==.',
['凌舞']='凌舞丶:BAAALgAECgUJBQAAAA==.',
['利群']='利群之力:BAAALgAECgEJAQAAAA==.',
['别吃']='别吃头前:BAAALgAFFAQJAQAAAA==.',
['前程']='前程若梦:BAAALgAECgQJBAAAAA==.',
['加尔']='加尔撸你:BAAALgAECgEJAQAAAA==.',
['勇敢']='勇敢小龙:BAAALgAECgcJBwABLgAFFAIJAgAEAAAAAA==.',
['北林']='北林孔工:BAABLgAFFH8MAAIPAAQJsgNEEgDQAAAPAAQJsgNEEgDQAAAAAA==.',
['十丿']='十丿夜:BAAALgAECgYJCAAAAA==.',
['千斤']='千斤:BAAALgADCgMJAwAAAA==.',
['千早']='千早愛音:BAAALgADCgEJAQAAAA==.',
['南人']='南人当北行:BAAALgAECgMJAwAAAA==.',
['南柯']='南柯壹夢:BAAALgAECgcJBwAAAA==.',
['压力']='压力小子:BAAALgAECgEJAQAAAA==.',
['叫兽']='叫兽喜欢雯雯:BAAALgAFFAIJAwAAAA==.',
['叮丶']='叮丶铛:BAAALgADCgcJBwAAAA==.',
['可爱']='可爱的米法:BAACLgAFFH8PAAMQAAQJeiN0AACSAQARAAQJeiM/BACxAQAQAAQJnxx0AACSAQAuAAQKfxwABBEABwn3I1EdAGMCABEABgnRJFEdAGMCABAAAwmdH8IKALUAAAUAAgkqF5o3AIwAAAAA.',
['史前']='史前第一男模:BAAALgADCgQJBgAAAA==.',
['叶丶']='叶丶子:BAAALgAECgEJAwABLgAECgQJBAAEAAAAAA==.',
['吃我']='吃我灵打:BAAALgAFFAIJAgAAAA==.',
['吃过']='吃过螃蟹:BAAALgAFFAIJBAAAAA==.',
['吉吉']='吉吉羊羊德:BAAALgAECgEJAQAAAA==.',
['吉妮']='吉妮薇儿:BAAALgAFFAIJBAAAAA==.',
['名刀']='名刀月隐:BAAALgAECgYJCwAAAA==.',
['名剑']='名剑小猪:BAAALgAECgUJCAAAAA==.',
['听风']='听风者:BAAALgADCgMJAwAAAA==.听风雨醉红尘:BAAALgAECgMJBAAAAA==.',
['吾四']='吾四一霸霸:BAAALgADCgUJBQAAAA==.',
['吾食']='吾食五个哈斗:BAAALgAFFAIJBAAAAA==.',
['呆呆']='呆呆家的童话:BAABLgAFFH8FAAIMAAMJUB+/EABrAAAMAAMJUB+/EABrAAAAAA==.',
['呜啦']='呜啦喵丶:BAAALgADCgIJAQAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgAECgcJBwAAAA==.',
['咕哒']='咕哒哒:BAACLgAFFH8QAAISAAUJVyNMAgDjAQASAAUJVyNMAgDjAQAuAAQKfxUAAxIACQkoF04RAJICABIACQkoF04RAJICABMABwn3D19XAEwBAAAA.',
['咕涌']='咕涌:BAAALgAECgIJAwABLgAECgkJEAAEAAAAAA==.',
['哈压']='哈压库奶龙:BAAALgADCgQJBAAAAA==.',
['哥特']='哥特爱费沁源:BAAALgAECgcJBAAAAA==.',
['唇线']='唇线的无奈:BAAALgAECgUJBwAAAA==.',
['唤血']='唤血者:BAAALgAECgEJAQAAAA==.',
['喝一']='喝一两:BAACLgAFFH8GAAIDAAMJBBgsJAAFAQADAAMJBBgsJAAFAQAuAAQKfx4AAgMABwlXHZMRAIcBAAMABwlXHZMRAIcBAAAA.',
['喝嘿']='喝嘿:BAAALgAFFAIJAgAAAA==.',
['嘟嘟']='嘟嘟酱:BAAALgAFFAEJAQAAAA==.',
['回嫌']='回嫌休正直:BAAALgAECgUJBQAAAA==.回嫌体正值:BAAALgAECgIJAgABLgAFFAMJAwAEAAAAAA==.回嫌体正直:BAAALgAFFAEJAQAAAA==.',
['圆蕉']='圆蕉少女凯西:BAAALgAECgkJAwAAAA==.',
['圣光']='圣光奶奶:BAAALgAECgEJAQAAAA==.圣光老公牛:BAAALgADCgEJAQAAAA==.',
['地爆']='地爆天星:BAACLgAFFH8IAAMUAAQJnxiCGAAsAQAUAAMJkx6CGAAsAQAVAAEJwQYAAAAAAAAuAAQKfxUAAxQACAldI4IiAIsCABQABwlOJIIiAIsCABUAAgm6HR9HAJoAAAAA.',
['基友']='基友路人五:BAAALgAFFAMJBAAAAA==.',
['堀京']='堀京子:BAACLgAFFH8KAAIBAAUJdRuwBwCpAQABAAUJdRuwBwCpAQAuAAQKfxYAAgEACAlQHkgdAKICAAEACAlQHkgdAKICAAAA.',
['墓穴']='墓穴里的猫:BAAALgAECgIJAgAAAA==.',
['墩儿']='墩儿:BAAALgAECgkJCQAAAA==.',
['夜泊']='夜泊夜泊荒唐:BAAALgAECgQJBQAAAA==.',
['夜灬']='夜灬虾米苏:BAAALgAECgUJCAAAAA==.',
['够钟']='够钟就遁人:BAAALgADCgYJCwAAAA==.',
['大汼']='大汼汼:BAAALgAECgQJBAAAAA==.',
['天堂']='天堂之门:BAAALgAECgIJBAAAAA==.天堂的另一边:BAABLgAFFH8FAAIWAAMJ2xoaAgD2AAAWAAMJ2xoaAgD2AAABLgAFFAQJDwAJADkWAA==.',
['天海']='天海翼:BAAALgADCgEJAgAAAA==.',
['天苍']='天苍苍也茫茫:BAAALgAECgQJBAAAAA==.',
['失联']='失联的雪豹:BAAALgAFFAMJAwAAAA==.',
['头上']='头上没犄角:BAAALgAECgEJAQAAAA==.',
['奥博']='奥博洛斯:BAAALgAECgQJBAAAAA==.',
['奥古']='奥古特:BAAALgAECgQJBAAAAA==.',
['好想']='好想告诉妳:BAACLgAFFH8JAAIKAAQJvxhqFgBwAQAKAAQJvxhqFgBwAQAuAAQKfxoAAgoABwmAIAtDAG8CAAoABwmAIAtDAG8CAAAA.',
['妖灬']='妖灬媚:BAAALgADCgIJAwAAAA==.',
['姚晓']='姚晓棠:BAAALgAFFAEJAQAAAA==.',
['姜葱']='姜葱白切鸡:BAAALgAECgMJAwAAAA==.',
['孤寂']='孤寂如烟灬:BAAALgAECgkJCQAAAA==.',
['安度']='安度因乌瑞恩:BAABLgAFFH8KAAINAAUJxgIxDQBCAQANAAUJxgIxDQBCAQAAAA==.',
['宋太']='宋太祖丶:BAAALgADCgUJBQAAAA==.',
['宝宝']='宝宝才是本体:BAACLgAFFH8GAAMUAAQJARpREQBYAQAUAAQJARpREQBYAQAVAAEJGw2JFgBSAAAuAAQKfxQAAxQACAmVIAUqAGgCABQABwnIHwUqAGgCABUAAgnGIYE8AMIAAAAA.',
['寒夜']='寒夜悲鸣:BAAALgAECgkJAgAAAA==.',
['寒烟']='寒烟如织:BAABLgAECn8TAAIXAAYJKh5CKAAXAgAXAAYJKh5CKAAXAgAAAA==.',
['射射']='射射滴害虫:BAAALgAECgcJBwAAAA==.',
['小初']='小初:BAAALgAECgMJAwAAAA==.',
['小喵']='小喵叽会钓鱼:BAAALgAECgYJBgAAAA==.',
['小怪']='小怪兽陈陈:BAAALgAECgkJCQAAAA==.',
['小橙']='小橙:BAABLgAFFH8JAAIYAAMJWhqHEwDcAAAYAAMJWhqHEwDcAAAAAA==.',
['小汤']='小汤勺儿:BAAALgAECgUJBQAAAA==.',
['小潮']='小潮是猪:BAAALgAFFAQJBAAAAA==.',
['小白']='小白倒立:BAAALgAECgUJBgAAAA==.小白酱酱:BAAALgADCgEJAQAAAA==.',
['小虾']='小虾米灬夜:BAAALgADCgQJBAAAAA==.',
['小远']='小远远:BAACLgAFFH8FAAIYAAIJpA78HACIAAAYAAIJpA78HACIAAAuAAQKfxoAAhgACAmXFvQcABsCABgACAmXFvQcABsCAAAA.',
['尐白']='尐白:BAAALgAECggJDwAAAA==.',
['少帅']='少帅丶:BAAALgAECgIJAgAAAA==.',
['尘封']='尘封恋影:BAAALgAFFAIJAgABLgAFFAIJBAAUAG4XAA==.尘封旧事:BAABLgAFFH8EAAIUAAIJbhdELwC0AAAUAAIJbhdELwC0AAAAAA==.',
['就叫']='就叫老沈吧:BAABLgAECn8WAAISAAgJtgRRTgDvAAASAAgJtgRRTgDvAAAAAA==.',
['屋顶']='屋顶黑猫:BAAALgAECgUJBQAAAA==.',
['山川']='山川神冢丶:BAACLgAFFH8GAAINAAIJHRdhIwClAAANAAIJHRdhIwClAAAuAAQKfxkAAw0ABwk5HM1EABUCAA0ABwk5HM1EABUCABYABgnyDkEgAAYBAAAA.',
['岚之']='岚之山:BAAALgAECgkJDgAAAA==.',
['巴适']='巴适得板丶:BAAALgAECgYJDwAAAA==.',
['康小']='康小樂:BAABLgAECn8ZAAILAAgJOBgTJQABAgALAAgJOBgTJQABAgAAAA==.',
['弑光']='弑光黯灵:BAABLgAECn8UAAINAAYJICKkOABBAgANAAYJICKkOABBAgAAAA==.',
['归期']='归期未有期:BAAALgAECgYJBgAAAA==.',
['彩虹']='彩虹哒:BAAALgADCgEJAQAAAA==.彩虹哒哒:BAAALgADCgEJAQAAAA==.',
['影后']='影后:BAAALgADCgYJBgAAAA==.',
['影月']='影月丶骑:BAAALgAECgYJBgAAAA==.',
['微雨']='微雨悠悠:BAAALgAECgQJDgAAAA==.',
['德心']='德心应手:BAAALgAECgEJAgAAAA==.',
['心流']='心流:BAAALgAECgEJAQAAAA==.',
['忙里']='忙里偷着闲:BAAALgAFFAEJAQAAAA==.',
['快乐']='快乐去:BAAALgAECgYJBwAAAA==.快乐的老司机:BAAALgADCgUJCgAAAA==.快乐糖:BAAALgADCgMJAwAAAA==.',
['急典']='急典孝乐:BAAALgAECgUJBQAAAA==.',
['怪阿']='怪阿姨不缺德:BAAALgAECgUJBAAAAA==.',
['恐怖']='恐怖的小锅巴:BAABLgAFFH8FAAMFAAMJIxu2DwBGAAARAAIJHyGwIQBSAAAFAAEJKw+2DwBGAAAAAA==.',
['情商']='情商压制智商:BAAALgAECgMJBQAAAA==.',
['惜言']='惜言:BAAALgAFFAQJBAAAAA==.',
['想出']='想出了办法:BAACLgAFFH8QAAQDAAUJux1vCgB+AQADAAQJsBlvCgB+AQAJAAEJAADMEwBUAAAZAAEJvxwAAAAAAAAuAAQKfxQAAgMACQnAHEkrAIwCAAMACQnAHEkrAIwCAAEuAAUUBwkeABoA1SQA.',
['慕往']='慕往长离丶:BAAALgAECgUJBQAAAA==.',
['我不']='我不吃猪肉:BAAALgAECgQJBAAAAA==.',
['我好']='我好怕怕:BAAALgAFFAIJAgAAAA==.',
['我就']='我就是军团:BAAALgADCgEJAQAAAA==.',
['手标']='手标拿铁:BAABLgAECn8bAAQbAAkJdRSgHADiAQAbAAcJ+RagHADiAQAcAAcJ1A9FHwCFAQAdAAEJ1gJARQAhAAAAAA==.',
['手残']='手残按不动:BAAALgADCgEJAQAAAA==.',
['折笙']='折笙:BAAALgAECgQJBwAAAA==.',
['支付']='支付寶:BAAALgAECgUJBQABLgAFFAEJAQAEAAAAAA==.',
['斩蛇']='斩蛇穿屋:BAAALgAFFAEJAgAAAA==.',
['无名']='无名是也:BAAALgAECgYJCwAAAA==.',
['无敌']='无敌大黑牛:BAAALgADCgEJAQAAAA==.无敌小堂弟:BAAALgADCgMJAwAAAA==.',
['无解']='无解丶熊孩子:BAAALgAFFAEJAQAAAA==.',
['旭旭']='旭旭宝宝:BAAALgAECgYJCwABLgAFFAMJAwAEAAAAAA==.',
['明天']='明天会放晴:BAAALgAECgUJBQAAAA==.',
['易易']='易易:BAABLgAFFH8BAAIUAAEJ2hXHIABdAAAUAAEJ2hXHIABdAAAAAA==.',
['星不']='星不了情:BAAALgAECgYJCQAAAA==.',
['星之']='星之守护者:BAAALgAFFAEJAQAAAA==.',
['星武']='星武仔:BAAALgAECgUJBwAAAA==.',
['星痕']='星痕丶烁影:BAAALgAECgQJAwAAAA==.',
['暗号']='暗号:BAAALgAFFAIJAgAAAA==.',
['暮雨']='暮雨今昔:BAAALgAECgEJAQAAAA==.',
['暴风']='暴风雪:BAAALgAECgEJAQAAAA==.',
['月夜']='月夜未寝:BAAALgADCgEJAQAAAA==.',
['有点']='有点意思哈:BAAALgADCgMJAwABLgAECgQJBAAEAAAAAA==.',
['朝九']='朝九晚五:BAAALgAECgEJAQAAAA==.',
['李瑾']='李瑾萱:BAAALgADCgEJAQAAAA==.',
['村口']='村口抢米饭:BAAALgAECgUJBgAAAA==.',
['来势']='来势:BAAALgAECgUJBgAAAA==.',
['枯竭']='枯竭王:BAAALgAFFAIJAgAAAA==.',
['柯妮']='柯妮:BAAALgAECgcJBwAAAA==.',
['栩栩']='栩栩如生:BAAALgAECgEJAQAAAA==.',
['桂花']='桂花八宝饭:BAAALgAFFAEJAQAAAA==.',
['梓童']='梓童:BAAALgAECgUJBQAAAA==.',
['梨花']='梨花浅酒:BAAALgAECgYJDwAAAA==.',
['棍棍']='棍棍僧:BAACLgAFFH8VAAIeAAYJkiIwAQA+AgAeAAYJkiIwAQA+AgAuAAQKfxQAAh4ACAmnHlMOAHICAB4ACAmnHlMOAHICAAAA.',
['棒棒']='棒棒妞妞:BAAALgAFFAIJAgAAAA==.',
['森林']='森林星如海:BAACLgAFFH8PAAILAAcJkhN5AwCfAQALAAcJkhN5AwCfAQAuAAQKfxsAAgsACQmoIWYCAF0DAAsACQmoIWYCAF0DAAAA.',
['武则']='武则天丶:BAAALgAFFAIJAgAAAA==.',
['死丶']='死丶魅:BAAALgAECgUJBQABLgAFFAIJBAAEAAAAAA==.',
['死亡']='死亡右手:BAAALgAECgIJAgAAAA==.死亡四号:BAAALgAECgUJBQAAAA==.死亡裂隙:BAAALgAECgUJBQAAAA==.',
['毁灭']='毁灭之萨:BAAALgAECgMJBQAAAA==.',
['毛之']='毛之防爆战:BAAALgAECgUJEAAAAA==.',
['永远']='永远滴神神:BAAALgAECgQJBAAAAA==.',
['污啦']='污啦喵丶:BAAALgADCgMJAwAAAA==.',
['沐月']='沐月晨风:BAAALgAECgEJAQAAAA==.',
['法乄']='法乄爷:BAAALgAECgUJBgAAAA==.',
['法外']='法外丶狂徒:BAAALgADCgIJAgAAAA==.',
['洙妮']='洙妮美:BAABLgAECn8bAAIKAAcJHB/MPQCAAgAKAAcJHB/MPQCAAgAAAA==.',
['洛丨']='洛丨馨:BAAALgADCgMJAwAAAA==.',
['洛瑟']='洛瑟玛塞隆:BAAALgAFFAQJBAAAAA==.',
['浅蓝']='浅蓝之殇:BAABLgAECn8pAAINAAgJGyLbDAAnAwANAAgJGyLbDAAnAwABLgAECgcJGQAOAKkUAA==.',
['浅默']='浅默悲殇:BAAALgAECgEJAQAAAA==.',
['浮岚']='浮岚瑞螭丶:BAAALgAECgYJDgAAAA==.',
['淡蛋']='淡蛋:BAAALgAECgEJAQAAAA==.',
['混沌']='混沌神选:BAAALgAECgEJAQAAAA==.',
['清新']='清新脱俗:BAAALgAECgEJAQAAAA==.',
['清澄']='清澄:BAAALgAECggJBgAAAA==.',
['清酌']='清酌:BAAALgAFFAUJBAAAAA==.',
['温禾']='温禾:BAAALgAFFAYJAQAAAA==.',
['渴望']='渴望未来:BAAALgAECgQJCAAAAA==.',
['湘北']='湘北塔茶社:BAAALgAECgMJAwAAAA==.',
['湛蓝']='湛蓝星空:BAAALgADCgMJAwABLgAECgcJGQAOAKkUAA==.',
['满舒']='满舒克:BAAALgADCgYJBgAAAA==.',
['澹台']='澹台梦龙:BAAALgADCggJCAAAAA==.',
['火云']='火云雷:BAAALgAFFAEJAQAAAA==.',
['灬小']='灬小鱼儿:BAAALgADCgMJAwAAAA==.',
['灬房']='灬房总:BAAALgADCgYJBgAAAA==.',
['炎丶']='炎丶帝:BAAALgAECgcJDgAAAA==.',
['煜小']='煜小兰:BAAALgAECgMJAwAAAA==.',
['爪牙']='爪牙牙:BAACLgAFFH8aAAIKAAgJOyEWAAB3AwAKAAgJOyEWAAB3AwAuAAQKfxgAAgoACAnLJkALAGkDAAoACAnLJkALAGkDAAAA.',
['爱喝']='爱喝茶的闲人:BAAALgADCgcJBwAAAA==.',
['爱玩']='爱玩的咕咕:BAAALgADCgcJBwAAAA==.爱玩的魏宝宝:BAAALgAECgMJAwAAAA==.',
['爱闻']='爱闻大屁骨:BAAALgAECgEJAQAAAA==.',
['狂徒']='狂徒乔治:BAAALgADCgIJAgAAAA==.',
['狂风']='狂风怒号:BAACLgAFFH8HAAITAAIJfSFuFADEAAATAAIJfSFuFADEAAAuAAQKfxsAAhMABglkJccWAIACABMABglkJccWAIACAAAA.',
['狐尼']='狐尼克:BAAALgAECgEJAQAAAA==.',
['王建']='王建國:BAAALgAFFAMJAwAAAA==.',
['玛丽']='玛丽苏丶:BAAALgAECgYJCAAAAA==.',
['玛埃']='玛埃尔:BAAALgAFFAEJAQAAAA==.',
['瓦伦']='瓦伦西亚万岁:BAAALgAECgMJAwAAAA==.',
['甜橙']='甜橙脆脆条丶:BAACLgAFFH8HAAITAAQJIwssBgAVAQATAAQJIwssBgAVAQAuAAQKfxUAAxMABglBGFU7ALcBABMABglBGFU7ALcBABIAAwleBkVrAHMAAAAA.',
['畅饮']='畅饮联盟血:BAAALgAECgIJAwAAAA==.',
['疯狂']='疯狂企鹅:BAAALgAECgYJBgAAAA==.疯狂的卡:BAAALgAECgEJAQAAAA==.疯狂的哎:BAACLgAFFH8FAAIKAAMJ9gTsMADuAAAKAAMJ9gTsMADuAAAuAAQKfxwAAgoABwloFl6AANABAAoABwloFl6AANABAAAA.疯狂的莉香丶:BAABLgAECn8dAAMCAAgJLw7CKgBwAQACAAcJNRDCKgBwAQAfAAYJYQVlGADbAAAAAA==.疯狂钻石:BAAALgAECgYJBwAAAA==.',
['白糖']='白糖火锅:BAEALgAECgMJAwABLgAFFAUJCgAGALoJAA==.',
['白鹿']='白鹿:BAACLgAFFH8fAAIeAAcJjQ/GAQAWAgAeAAcJjQ/GAQAWAgAuAAQKfxUAAh4ACQmCFagSADsCAB4ACQmCFagSADsCAAAA.',
['皮成']='皮成仙:BAAALgADCgQJBAAAAA==.',
['益达']='益达不是绿箭:BAAALgAECgMJAwAAAA==.',
['相思']='相思算什么:BAAALgADCgMJAwAAAA==.',
['看好']='看好窗户:BAAALgAECgYJBgAAAA==.',
['真言']='真言术嘎:BAAALgAECgYJDAAAAA==.',
['知难']='知难:BAAALgAECggJCgAAAA==.',
['石大']='石大锤:BAAALgAECgcJCgAAAA==.',
['石晓']='石晓胖:BAAALgAECgQJBgAAAA==.',
['破天']='破天魔龙:BAABLgAFFH8PAAIJAAQJORYPBgA4AQAJAAQJORYPBgA4AQAAAA==.',
['破晓']='破晓之翼:BAAALgAECgcJAwAAAA==.',
['碎嘴']='碎嘴子熊:BAAALgADCgEJAQAAAA==.',
['秀宝']='秀宝真可爱:BAABLgAECn8bAAQYAAgJ6BxxIAD+AQAYAAgJ6BxxIAD+AQAeAAUJ5iKfIACwAQAgAAUJXQ1gRgD8AAAAAA==.',
['秋曰']='秋曰:BAAALgAECgEJAQAAAA==.',
['科比']='科比布莱恩特:BAAALgAFFAMJAwAAAA==.',
['秒躺']='秒躺尾王:BAAALgAFFAIJBAAAAA==.',
['稀里']='稀里糊涂:BAAALgADCgcJCAAAAA==.',
['穆西']='穆西亚拉:BAAALgAFFAIJAgABLgAFFAQJDwAQAHojAA==.',
['立立']='立立安:BAAALgADCgUJBQAAAA==.',
['立華']='立華奏:BAACLgAFFH8TAAIGAAUJWxMgAgCkAQAGAAUJWxMgAgCkAQAuAAQKfzMABCEACAlhICkKAOACACEACAlhICkKAOACAAYABwm2I+YAAMwCAAwABAl5FkJMAAcBAAAA.',
['竹海']='竹海听涛:BAAALgADCgMJAwAAAA==.',
['笑靥']='笑靥丶:BAAALgAFFAEJAQAAAA==.',
['米莉']='米莉姆:BAAALgAECgYJDAAAAA==.',
['粤走']='粤走佬王廿四:BAAALgAECgYJBgAAAA==.',
['繁华']='繁华血景:BAAALgAECgQJBAAAAA==.',
['约翰']='约翰维克:BAAALgADCgEJAQAAAA==.',
['纪律']='纪律严明:BAAALgAECgQJBgAAAA==.',
['纷飞']='纷飞雪灬:BAAALgAECgUJCQAAAA==.',
['绯渊']='绯渊:BAAALgAECgUJBAAAAA==.',
['罒全']='罒全能骑士:BAAALgAFFAIJAgAAAA==.',
['美羊']='美羊羊桑:BAAALgAFFAEJAQAAAA==.',
['翘边']='翘边模子:BAAALgAECgEJAQAAAA==.',
['老娘']='老娘风韵犹存:BAACLgAFFH8GAAIiAAMJwxcuAgAXAQAiAAMJwxcuAgAXAQAuAAQKfxwAAyIACAltHoEFALMCACIABwlxIoEFALMCABcAAgkaBaCoAHQAAAAA.',
['老板']='老板偷梁换柱:BAAALgAFFAEJAQAAAA==.老板的大嫂:BAAALgADCgMJAwAAAA==.',
['老王']='老王:BAABLgAFFH8IAAIYAAMJsRqjDgAOAQAYAAMJsRqjDgAOAQAAAA==.',
['耗总']='耗总好帅喔:BAAALgAECgcJDAAAAA==.',
['肮脏']='肮脏的粑粑棍:BAACLgAFFH8FAAILAAIJuRNIGgCSAAALAAIJuRNIGgCSAAAuAAQKfxsAAw8ABwmwFH4rALsBAA8ABwmwFH4rALsBAAsABAnEDmV2ALcAAAAA.',
['胡桃']='胡桃:BAABLgAFFH8HAAMVAAQJYRBIDACpAAAVAAIJkBJIDACpAAAUAAIJMQ6HNgCmAAAAAA==.胡桃古古蛋:BAAALgAFFAQJBAAAAA==.胡桃古壹:BAAALgAFFAQJBAAAAA==.胡桃古弎:BAAALgAFFAIJAgAAAA==.胡桃古怪蛋:BAAALgAFFAIJAgAAAA==.胡桃古肆蛋:BAAALgAFFAQJBAAAAA==.胡桃古贰:BAAALgAFFAMJAwAAAA==.胡桃呱呱蛋:BAABLgAFFH8DAAIVAAIJ0gnGDQCfAAAVAAIJ0gnGDQCfAAAAAA==.胡桃咕咕蛋:BAAALgAFFAIJAgAAAA==.胡桃咕姑蛋:BAAALgAECgkJDgAAAA==.胡桃咕弎蛋:BAABLgAFFH8CAAMVAAIJyw0kEwBYAAAVAAEJ3RMkEwBYAAAUAAEJuQdjSgBRAAAAAA==.胡桃咕贰蛋:BAABLgAFFH8EAAMVAAMJZQ4PDgCcAAAUAAIJmxKvMwCrAAAVAAIJSAcPDgCcAAAAAA==.胡桃壹号:BAAALgAECgIJAgAAAA==.胡桃姑姑蛋:BAAALgAFFAQJBAAAAA==.胡桃拾壹:BAAALgAECgIJAgAAAA==.胡桃拾贰:BAAALgAECgIJAgAAAA==.胡桃菇贰蛋:BAACLgAFFH8DAAIVAAIJcA60DACnAAAVAAIJcA60DACnAAAuAAQKfxIAAxUACQmIFVoWAJcBABUABgnIGFoWAJcBABQABglkCymNAD4BAAAA.胡桃贰号:BAAALgAECgIJAgAAAA==.',
['舞丶']='舞丶漩律:BAAALgAECgEJAQAAAA==.',
['芝士']='芝士酒仙:BAABLgAECn8UAAMYAAYJrhzbIwDjAQAYAAYJkRzbIwDjAQAgAAYJyhbLMABjAQAAAA==.',
['花城']='花城折磨王:BAAALgAFFAQJAwAAAA==.',
['花开']='花开朝露:BAABLgAFFH8FAAIYAAQJUhCsDAAfAQAYAAQJUhCsDAAfAQABLgAFFAQJDwAJADkWAA==.',
['苍泠']='苍泠:BAECLgAFFH8KAAIGAAUJugmNBQCNAQAGAAUJugmNBQCNAQAuAAQKfxoAAwYACQlVGWAMAHICAAYACQmFF2AMAHICAAwABQmZGVE6AFIBAAAA.',
['苜巳']='苜巳:BAAALgAECgYJCwAAAA==.',
['苦寻']='苦寻成都富婆:BAAALgAFFAIJAQAAAA==.',
['荒古']='荒古圣体:BAAALgAECgMJAwAAAA==.',
['荒漠']='荒漠迷城高手:BAAALgAFFAMJAwAAAA==.',
['莉莉']='莉莉丝丶雪晨:BAAALgAECgEJAwAAAA==.',
['莫弃']='莫弃少年穷:BAAALgAECgMJAwAAAA==.',
['莫辛']='莫辛小纳甘:BAAALgAECgcJDgAAAA==.',
['莫道']='莫道:BAAALgAECgYJCAABLgAFFAMJBQANAAwGAA==.莫道凉凉:BAAALgAECgYJBgABLgAFFAQJBAAEAAAAAA==.',
['莫高']='莫高窟二五七:BAACLgAFFH8FAAINAAMJDAb1GADiAAANAAMJDAb1GADiAAAuAAQKfxgAAg0ABgkXGu91AI8BAA0ABgkXGu91AI8BAAAA.莫高窟四二八:BAABLgAECn8UAAMLAAcJdQ9nRgBoAQALAAcJdQ9nRgBoAQAPAAQJ9QvDZwCkAAABLgAFFAMJBQANAAwGAA==.',
['菲莉']='菲莉亚丶星光:BAAALgAECgEJAQABLgAECgQJBAAEAAAAAA==.',
['萌新']='萌新不是萌新:BAACLgAFFH8TAAITAAUJoiSlAAABAgATAAUJoiSlAAABAgAuAAQKfxYAAhMACAn5JDkFADoDABMACAn5JDkFADoDAAAA.萌新妙脆角:BAAALgAECgYJDAAAAA==.',
['萌牛']='萌牛酸酸乳丶:BAAALgAECgUJCAAAAA==.',
['萨瓦']='萨瓦迪卡:BAACLgAFFH8KAAMCAAQJciGjAwBLAQACAAMJXiSjAwBLAQABAAMJUxRVGwD3AAAuAAQKfyQAAwIACAkxJrUCAGEDAAIACAkNJrUCAGEDAAEACAkWIOoWAM0CAAAA.',
['蒂皮']='蒂皮艾思丶:BAAALgAECgQJBAABLgAFFAMJCwALAAMdAA==.',
['蒙少']='蒙少丶:BAAALgAFFAIJAgAAAA==.',
['蓝心']='蓝心来使:BAAALgAFFAIJAwAAAA==.',
['蓝湛']='蓝湛:BAAALgAECgUJDwAAAA==.',
['虎一']='虎一下:BAAALgADCgEJAQAAAA==.',
['虫子']='虫子吖:BAAALgAECgEJAQAAAA==.',
['蜂窝']='蜂窝煤发电机:BAABLgAFFH8HAAIPAAQJcxfpCABPAQAPAAQJcxfpCABPAQAAAA==.',
['蜂蜜']='蜂蜜吃着甛:BAAALgAFFAEJAQABLgAFFAIJBAAUAG4XAA==.',
['西毒']='西毒欧阳秀:BAAALgAECgQJBAAAAA==.',
['西爸']='西爸辣八:BAABLgAFFH8GAAISAAMJVgjYBgDfAAASAAMJVgjYBgDfAAAAAA==.',
['识之']='识之律者:BAAALgAECgYJBgAAAA==.',
['调理']='调理劳务系:BAAALgAECgYJCwAAAA==.',
['豆呀']='豆呀么豆:BAAALgAECgQJBAAAAA==.',
['豆豆']='豆豆十二岁了:BAAALgAECgcJEQAAAA==.',
['费莲']='费莲诺尔:BAAALgAECgUJDAAAAA==.',
['起飞']='起飞:BAAALgAECgEJAQAAAA==.',
['超危']='超危險飛踢:BAAALgAECgEJAQAAAA==.',
['跑起']='跑起来真快:BAAALgAECgMJBQAAAA==.',
['转就']='转就完事了:BAABLgAFFH8MAAINAAQJVBV2AwBhAQANAAQJVBV2AwBhAQAAAA==.',
['轻笙']='轻笙空杯:BAAALgAFFAEJAQAAAA==.',
['辣年']='辣年糕要放糖:BAAALgADCgMJAwAAAA==.',
['辣椒']='辣椒少一点:BAAALgAECgEJAQAAAA==.',
['邂逅']='邂逅:BAABLgAFFH8NAAIDAAQJqiN4BQCrAQADAAQJqiN4BQCrAQABLgAFFAYJBAAEAAAAAA==.',
['邪丨']='邪丨舞:BAABLgAECn8YAAINAAgJGBmbNgBIAgANAAgJGBmbNgBIAgAAAA==.',
['邪恶']='邪恶克星:BAAALgAFFAEJAQAAAA==.',
['邮电']='邮电部诗人:BAABLgAFFH8GAAIBAAMJUxSrJgClAAABAAMJUxSrJgClAAAAAA==.',
['郝合']='郝合偕:BAAALgAECgkJCgABLgAFFAEJAgAEAAAAAA==.',
['酒贰']='酒贰拾柒:BAACLgAFFH8IAAIjAAMJhxgHAwALAQAjAAMJhxgHAwALAQAuAAQKfxoAAiMABwkwIGMFALECACMABwkwIGMFALECAAAA.',
['酢乙']='酢乙女爱:BAAALgAECgMJAwAAAA==.',
['酱油']='酱油在哪里:BAAALgAFFAIJBAAAAA==.',
['释魂']='释魂红玉:BAACLgAFFH8PAAIUAAUJLSKGAgAIAgAUAAUJLSKGAgAIAgAuAAQKfyYAAxQACAlVI1YIAD8DABQACAlVI1YIAD8DABUAAwm1FHU8AMIAAAAA.',
['钴咕']='钴咕熊:BAAALgAECgQJBAAAAA==.',
['铁铸']='铁铸的佣兵:BAAALgAECgYJDwAAAA==.',
['镁镁']='镁镁:BAAALgAFFAEJAgAAAA==.',
['问酒']='问酒雾居:BAAALgADCgYJBgAAAA==.',
['阿丶']='阿丶钦:BAAALgAECgIJAgAAAA==.',
['阿克']='阿克琉斯:BAABLgAFFH8FAAIRAAIJyBxfFQC8AAARAAIJyBxfFQC8AAAAAA==.',
['阿城']='阿城大表哥:BAAALgAECgIJAgAAAA==.',
['阿尔']='阿尔托莉娅:BAAALgAECgUJBQAAAA==.',
['阿瑞']='阿瑞斯熊皮:BAAALgAECgUJBgAAAA==.',
['附马']='附马的等待:BAAALgAECgQJBQAAAA==.',
['附魔']='附魔珠宝加工:BAAALgAECgEJAQAAAA==.',
['陈丶']='陈丶风暴烧酒:BAAALgAECggJEQAAAA==.',
['随语']='随语者:BAAALgAECgEJAQAAAA==.',
['随风']='随风流逝:BAAALgAECgYJBgAAAA==.',
['雪月']='雪月之兰特:BAAALgAFFAYJAgAAAA==.',
['雲烟']='雲烟:BAAALgAECgIJAQABLgAFFAYJBwAHAIMYAA==.',
['雷电']='雷电之光:BAAALgADCgUJBQAAAA==.',
['雷雷']='雷雷鸡:BAAALgAFFAQJBAAAAA==.',
['雷霆']='雷霆击碎黑暗:BAAALgADCgYJBgAAAA==.',
['霜晨']='霜晨月:BAAALgAECgIJAwAAAA==.',
['霸气']='霸气牛批:BAAALgAECgMJAwAAAA==.',
['霸霸']='霸霸丶:BAAALgADCgIJAgAAAA==.',
['青山']='青山红叶飘:BAAALgAECgIJAwAAAA==.',
['青白']='青白江混江龙:BAAALgADCgEJAQAAAA==.',
['靓仔']='靓仔很忙丶:BAAALgAFFAIJBAAAAA==.',
['风吹']='风吹鼻毛爽:BAAALgAECgEJAQAAAA==.',
['风行']='风行者丶希尔:BAAALgADCgcJBwAAAA==.',
['风起']='风起清澜:BAAALgAECgMJAwAAAA==.',
['风香']='风香智乃:BAAALgAECgYJCAAAAA==.',
['香烟']='香烟只抽利群:BAAALgAECgcJCQAAAA==.香烟只抽芙蓉:BAAALgAECgcJDQAAAA==.',
['香蕉']='香蕉:BAAALgADCgMJAwAAAA==.',
['骄阳']='骄阳之魂:BAAALgAFFAIJAgAAAA==.',
['鱼玄']='鱼玄机灬:BAABLgAECn8UAAMMAAcJNh1OIwDLAQAMAAYJfBxOIwDLAQAGAAcJXxVxGwC7AQAAAA==.',
['麦小']='麦小久:BAAALgAECgQJBAAAAA==.',
['黄灿']='黄灿灿:BAAALgAECgkJDQAAAA==.',
['黄皮']='黄皮耗子:BAAALgADCgIJAgAAAA==.',
['黄色']='黄色闪光:BAAALgAFFAQJBAAAAA==.',
['黑天']='黑天与白夜:BAABLgAECn8aAAMkAAgJ1wnmFQAUAQAkAAgJ1wnmFQAUAQAlAAEJUwI+OAAnAAAAAA==.',
['黑石']='黑石铸造厂長:BAAALgAECgYJDQAAAA==.',
['黑骑']='黑骑牛:BAAALgAECgYJBgAAAA==.',
['黛安']='黛安娜:BAABLgAFFH8GAAIPAAYJWxOyAACsAQAPAAYJWxOyAACsAQAAAA==.',
['齊天']='齊天大圣:BAAALgAECgYJBgAAAA==.',
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
