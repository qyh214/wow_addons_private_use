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

local lookup = {'Paladin-Holy','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Druid-Balance','Warrior-Fury','Mage-Fire','Mage-Frost','Mage-Arcane','Unknown-Unknown','Warrior-Arms','Evoker-Preservation','Priest-Discipline','Priest-Holy','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','DemonHunter-Devourer','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Augmentation','Druid-Guardian','Rogue-Assassination','Monk-Brewmaster','Evoker-Devastation','Druid-Restoration','Priest-Shadow','DeathKnight-Blood','Druid-Feral','Monk-Windwalker','Warrior-Protection','Monk-Mistweaver','Warlock-Affliction','Paladin-Protection','DeathKnight-Frost','Rogue-Subtlety','DemonHunter-Vengeance',}
local provider = {region='CN',realm='雷霆之王',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alacrity:BAAALgAECgEJAQAAAA==.Altriasaber:BAAALgAECgIJAgAAAA==.',
Ar='Archean:BAABLgAECn8WAAIBAAgJzCD3CADhAgABAAgJzCD3CADhAgAAAA==.',
Ba='Banshee:BAAALgAECgcJBwAAAA==.',
Bm='Bmxmlg:BAAALgAECgcJBQAAAA==.',
Ca='Caleb:BAAALgAECgUJCQAAAA==.',
Ch='Choices:BAAALgAECgEJAQAAAA==.',
Co='Coldcat:BAABLgAFFH8IAAICAAMJbhqtDAAnAQACAAMJbhqtDAAnAQAAAA==.',
Cy='Cy:BAAALgADCgYJBgAAAA==.',
Dc='Dchenn:BAAALgADCgYJBgAAAA==.',
De='Deletejing:BAAALgAECgEJAQAAAA==.Devilrealrs:BAAALgADCgUJBQAAAA==.',
Em='Emox:BAAALgADCgIJAgAAAA==.',
Er='Erinyeserin:BAAALgADCgEJAQAAAA==.Erooslon:BAAALgAECgYJBgAAAA==.',
Fo='Foru:BAAALgAECgYJBgAAAA==.Forwindy:BAAALgAFFAEJAQAAAA==.',
Fu='Furyhunter:BAAALgAFFAEJAQAAAA==.',
Ga='Gal:BAAALgAECgQJBQAAAA==.',
Gi='Gilgamesh:BAAALgAECgYJCQAAAA==.',
Gl='Glaz:BAAALgAECgYJBwAAAA==.Glizi:BAAALgAECgYJBgAAAA==.',
Gu='Gulldan:BAABLgAECn8SAAMDAAgJVRYfVwDCAQADAAcJDhYfVwDCAQAEAAIJ8BCXTQCFAAAAAA==.',
Hy='Hylene:BAAALgAECgEJAQAAAA==.',
Ic='Iceice:BAAALgAFFAIJAwAAAA==.',
Ju='Jusee:BAAALgAECgIJAgABLgAFFAQJDgAFAAwYAA==.',
Ka='Kanna:BAAALgAECgYJBgAAAA==.',
Ki='Kisstome:BAAALgADCgUJBQAAAA==.',
Kl='Klio:BAAALgAECgcJEQAAAA==.',
Le='Leo:BAAALgADCgIJAgAAAA==.',
Li='Lifengzs:BAAALgAFFAQJBAAAAA==.Ligoat:BAAALgAECgEJAQABLgAFFAYJFwAGAMkfAA==.Lisin:BAAALgADCgYJBgAAAA==.',
Lo='Logos:BAABLgAECn8jAAQHAAgJfyC+AAABAwAHAAgJfyC+AAABAwAIAAQJgQocHwHCAAAJAAEJFhCTHQA3AAAAAA==.',
Ma='Magnificent:BAAALgADCgIJAgAAAA==.Makabaka:BAEALgAECgEJAQABLgAECgEJAQAKAAAAAA==.',
Me='Mezool:BAAALgAECgYJBwAAAA==.',
Mi='Misakia:BAAALgAECgQJCAAAAA==.Miss:BAAALgADCgEJAQAAAA==.',
Mo='Moodyguy:BAAALgADCgkJCQAAAA==.Moondk:BAAALgAECgEJAwAAAA==.',
Ni='Nihilus:BAAALgADCgIJAgABLgAFFAUJCAACAPIeAA==.Nirvanafans:BAAALgAECgYJDAAAAA==.',
Oo='Oolelouchoo:BAAALgAECgIJAwAAAA==.',
Pi='Pimage:BAABLgAFFH8PAAIIAAcJdR8aAAByAgAIAAcJdR8aAAByAgAAAA==.',
Pl='Playerdidefv:BAAALgAECgEJAgAAAA==.',
Qi='Qiank:BAAALgAECgUJBwAAAA==.Qinrzwarrior:BAACLgAFFH8SAAMGAAYJjBjKAQDkAQAGAAUJiR7KAQDkAQALAAEJlwDXDQBCAAAuAAQKfyIAAwYACAnkJdMDAG8DAAYACAnkJdMDAG8DAAsAAQkbGY1BADYAAAAA.',
Ri='Rivaille:BAAALgAFFAQJBAAAAA==.',
Sa='Saviori:BAAALgAECgEJAQAAAA==.',
Se='Selene:BAAALgADCgcJBwAAAA==.Sendmsg:BAAALgAECgYJBgAAAA==.Senelzz:BAAALgAECgQJBAAAAA==.Seven:BAAALgADCgYJBgAAAA==.',
Sh='Shanshan:BAAALgADCgYJAwAAAA==.',
Si='Silk:BAAALgAFFAIJAgAAAA==.Sillcute:BAAALgAECgMJAwAAAA==.Simplemoon:BAAALgAECgQJBAAAAA==.Simplez:BAAALgAECgUJBgAAAA==.',
Sp='Space:BAAALgAECgYJBgAAAA==.',
St='Starryy:BAACLgAFFH8IAAIIAAQJ9hpHHgC+AAAIAAQJ9hpHHgC+AAAuAAQKfxYAAggABwnHIW4/AHsCAAgABwnHIW4/AHsCAAAA.',
Te='Teach:BAAALgAECgkJCQAAAA==.',
Tg='Tgamz:BAAALgAFFAIJAgAAAA==.',
Ul='Ulver:BAAALgAECgMJBQAAAA==.',
Xa='Xarylol:BAAALgAECgUJBgAAAA==.',
Xi='Xiaopz:BAAALgAECgEJAQAAAA==.',
Za='Zarathustra:BAAALgAECgYJBwAAAA==.',
Zi='Zippo:BAAALgAECgMJAwAAAA==.',
Zz='Zzpsbshaman:BAAALgAFFAIJAgABLgAFFAQJAgAKAAAAAA==.',
['一傲']='一傲慢一:BAAALgAECgEJAQAAAA==.',
['一刀']='一刀涌死你:BAAALgAFFAEJAQAAAA==.',
['一听']='一听夜龙吟:BAABLgAECn8XAAIMAAcJHx41CgCSAgAMAAcJHx41CgCSAgAAAA==.',
['一念']='一念长空:BAAALgAECgEJAgAAAA==.',
['一折']='一折羽兮:BAAALgADCgEJAQAAAA==.',
['一星']='一星章:BAAALgAECgUJBwAAAA==.',
['一眼']='一眼风情:BAAALgADCgcJDQAAAA==.',
['一马']='一马当先:BAABLgAECn8YAAIIAAgJGRenVAA6AgAIAAgJGRenVAA6AgAAAA==.',
['七匹']='七匹狠:BAACLgAFFH8IAAIGAAMJNRFREQD9AAAGAAMJNRFREQD9AAAuAAQKfxwAAgYACAnpF0wlAC4CAAYACAnpF0wlAC4CAAAA.',
['万威']='万威:BAABLgAFFH8GAAMNAAMJvwl2DAB4AAANAAIJBgN2DAB4AAAOAAIJgwxXFABDAAAAAA==.',
['三千']='三千两觉:BAABLgAECn8dAAICAAgJmBZ3RwAeAgACAAgJmBZ3RwAeAgAAAA==.',
['三寸']='三寸吴彦祖:BAAALgADCgUJBQAAAA==.',
['三柒']='三柒:BAAALgAECgIJAgAAAA==.',
['三森']='三森玲子:BAABLgAFFH8IAAMPAAQJQh/3BACBAQAPAAQJQh/3BACBAQAQAAEJLiPRGgBgAAAAAA==.',
['下线']='下线玩原神:BAACLgAFFH8HAAIBAAIJ1BWjFACcAAABAAIJ1BWjFACcAAAuAAQKfxUAAgEABwloHxoeACYCAAEABwloHxoeACYCAAAA.',
['不朽']='不朽盾在手:BAAALgAECgQJBgAAAA==.',
['不言']='不言而遇:BAABLgAECn8WAAIRAAcJVh1SNgBJAgARAAcJVh1SNgBJAgAAAA==.',
['世相']='世相:BAABLgAECn8dAAIBAAYJ7iFvGgBBAgABAAYJ7iFvGgBBAgAAAA==.',
['丢娜']='丢娜猩:BAAALgAECgEJAQAAAA==.',
['丨陌']='丨陌水惊寒丨:BAAALgADCgEJAQAAAA==.',
['丶啊']='丶啊宇:BAACLgAFFH8KAAISAAUJzgqRDABuAQASAAUJzgqRDABuAQAuAAQKfxsAAxIACAlBG4EsAEwCABIACAlBG4EsAEwCABMABgl5E3A1ADIBAAAA.',
['丶情']='丶情殇:BAAALgAECgYJBgAAAA==.',
['丶执']='丶执笔:BAACLgAFFH8MAAIIAAQJnCC/EgCBAQAIAAQJnCC/EgCBAQAuAAQKfyUAAggACAkrIuoaAAsDAAgACAkrIuoaAAsDAAAA.',
['丶牛']='丶牛氓:BAAALgAECgEJAQAAAA==.',
['丶盖']='丶盖伦:BAAALgAECgEJAQAAAA==.',
['丶空']='丶空城:BAAALgAECgkJCgAAAA==.',
['为谁']='为谁而来:BAAALgAFFAEJAQAAAA==.为谁而眠:BAABLgAECn8YAAMDAAcJFhCfbgCDAQADAAcJFhCfbgCDAQAEAAIJjgovVgBsAAAAAA==.',
['丽丽']='丽丽:BAAALgADCgEJAQAAAA==.',
['乔纳']='乔纳森迈尔:BAAALgAECgQJBAAAAA==.',
['九十']='九十九夜:BAAALgAECgEJAwAAAA==.',
['二阶']='二阶堂真红:BAAALgAFFAQJBAAAAA==.',
['云梦']='云梦泽乄僧:BAAALgAFFAIJAgAAAA==.',
['亞里']='亞里莎:BAAALgAECgQJBAAAAA==.',
['亲爱']='亲爱的卡卡酱:BAAALgAECgYJBgAAAA==.亲爱的郭小贱:BAAALgAECgcJAgAAAA==.',
['今元']='今元宝:BAAALgAECgYJDAAAAA==.',
['令狐']='令狐不想冲:BAAALgAECgIJAgAAAA==.',
['伊你']='伊你纱白:BAAALgAECgUJBQAAAA==.',
['伊利']='伊利谷粒多:BAAALgAECgYJEQAAAA==.',
['伊莎']='伊莎玛拉:BAACLgAFFH8IAAIUAAMJ9gihDQDvAAAUAAMJ9gihDQDvAAAuAAQKfxYAAxQACAnbE+cpAA4CABQACAnbE+cpAA4CABUABAlbBmxnAKEAAAAA.',
['会加']='会加血的牛:BAAALgAECgcJBgAAAA==.',
['会飞']='会飞的战牛:BAAALgADCgYJBgAAAA==.',
['伱姑']='伱姑奶奶:BAAALgAECgIJBAAAAA==.',
['低调']='低调派:BAABLgAFFH8FAAIRAAMJTAytDgDsAAARAAMJTAytDgDsAAAAAA==.',
['何时']='何时缚苍龍:BAAALgAECgYJBwAAAA==.',
['佛光']='佛光普照:BAAALgAECgEJAgAAAA==.',
['佛罗']='佛罗伦萨的猫:BAAALgAECgYJAQAAAA==.',
['你拿']='你拿个杯:BAAALgAECgYJEQAAAA==.',
['你是']='你是矮人:BAAALgAECgYJDwAAAA==.',
['你胖']='你胖到我了:BAAALgAECgYJBgAAAA==.',
['你踩']='你踩我尾巴了:BAAALgAFFAMJAwAAAA==.',
['依然']='依然啊欣:BAABLgAECn8VAAINAAcJ5AotJgBkAQANAAcJ5AotJgBkAQAAAA==.依然海棠花:BAAALgAECgYJAQABLgAFFAQJBAAKAAAAAA==.依然灬葬爱咕:BAAALgAECgYJCwAAAA==.',
['信仰']='信仰聖光的牛:BAABLgAFFH8HAAIPAAUJNAsHBQB/AQAPAAUJNAsHBQB/AQABLgAFFAcJAgAKAAAAAA==.',
['俩王']='俩王四个二:BAAALgAECgQJBAAAAA==.',
['俺叫']='俺叫张全蛋:BAAALgAECgkJCAAAAA==.',
['偏瘫']='偏瘫法师:BAAALgAECgkJBQAAAA==.',
['偷你']='偷你外卖:BAAALgAECgYJDAAAAA==.',
['傲之']='傲之猎者遥望:BAAALgAECgMJAwAAAA==.',
['光铸']='光铸猫粮:BAAALgAECgYJBgAAAA==.',
['全聚']='全聚德:BAAALgAECgcJDAAAAA==.',
['六六']='六六咕了咕:BAABLgAECn8lAAMMAAgJJBumAgAHAgAMAAcJmBumAgAHAgAWAAEJDgWuYwAvAAABLgAFFAcJEAAWAHgaAA==.六六啦呀啦:BAAALgADCgMJAwAAAA==.',
['其实']='其实我是慕斯:BAAALgAECgQJBAAAAA==.',
['再世']='再世吕布:BAAALgAECgEJAQAAAA==.',
['军团']='军团一一:BAAALgADCgUJBQAAAA==.',
['冰雪']='冰雪果冻:BAAALgAECgQJAwAAAA==.',
['冰霜']='冰霜的心:BAAALgADCgEJAQAAAA==.',
['冷冷']='冷冷:BAABLgAFFH8FAAICAAMJFBQvSgCMAAACAAMJFBQvSgCMAAAAAA==.',
['凌煈']='凌煈:BAAALgAECgYJDAAAAA==.',
['凯旋']='凯旋天下:BAAALgAECgcJDQAAAA==.',
['别吃']='别吃:BAAALgAECgUJBQAAAA==.',
['别开']='别开火自己人:BAAALgAECgEJAgAAAA==.',
['别送']='别送:BAAALgAFFAQJBAAAAA==.',
['剖你']='剖你心肝:BAABLgAECn8YAAMFAAYJRCD1HgAIAgAFAAYJIR/1HgAIAgAXAAEJQyQpJwBkAAAAAA==.',
['剪云']='剪云丶:BAAALgAFFAIJAgABLgAFFAQJDAAIAJwgAA==.',
['劝你']='劝你自首:BAEALgAECgIJAwABLgAECgcJGgAYAMgjAA==.',
['加右']='加右在啊:BAABLgAECn8UAAIPAAcJ6RM8NQCuAQAPAAcJ6RM8NQCuAQAAAA==.',
['加里']='加里奥佛丁:BAAALgAFFAIJAgABLgAFFAMJCAACAG4aAA==.',
['包小']='包小屁:BAAALgAECgEJAgAAAA==.包小萌:BAAALgAECgQJBgAAAA==.',
['包筱']='包筱牧:BAAALgAECgEJAgAAAA==.',
['北冥']='北冥逍遥:BAAALgAECgEJAgABLgAFFAQJBAAKAAAAAA==.',
['十年']='十年饮冰:BAAALgADCgIJAgAAAA==.',
['十花']='十花凌雪:BAAALgAECgYJDQAAAA==.',
['千千']='千千:BAAALgAECgIJAgAAAA==.千千小咕:BAAALgAECgYJCAAAAA==.',
['千年']='千年妖姬:BAAALgAECgYJDAABLgAFFAYJBgAIABIBAA==.千年蛤:BAAALgADCgMJAwAAAA==.',
['半点']='半点心:BAABLgAFFH8GAAIZAAMJhw27FADQAAAZAAMJhw27FADQAAAAAA==.',
['华师']='华师大:BAAALgADCgMJAwAAAA==.',
['单刷']='单刷女厕:BAAALgAECgkJCQAAAA==.',
['卡啰']='卡啰尔:BAAALgAECgYJCwAAAA==.',
['卡莉']='卡莉斯塔:BAAALgADCgIJAgAAAA==.',
['叁仟']='叁仟珏罗:BAAALgAECgYJBwAAAA==.',
['取你']='取你小命:BAACLgAFFH8IAAMaAAMJoiVMAQDjAAAWAAMJsBm3DgAVAQAaAAIJOiZMAQDjAAAuAAQKfxcAAxoABgkxIosKADMCABoABgljH4sKADMCABYAAwl3H0E5AA8BAAAA.',
['口口']='口口一:BAAALgAECgEJBAAAAA==.',
['古尔']='古尔鸡蛋:BAEALgAECgMJAwAAAA==.',
['召祐']='召祐:BAACLgAFFH8NAAIMAAQJ8yXGAwDHAQAMAAQJ8yXGAwDHAQAuAAQKfxwAAwwACQk+IRIFAPsCAAwACAn4IRIFAPsCABYAAQntBL5jAC8AAAAA.',
['史尔']='史尔特尔:BAABLgAFFH8GAAIMAAMJKQ5BBwDoAAAMAAMJKQ5BBwDoAAAAAA==.',
['叶殇']='叶殇丶:BAACLgAFFH8KAAMDAAQJAxQmCQBKAQADAAQJAxQmCQBKAQAEAAEJ0gjiFwBPAAAuAAQKfyIAAwMACAluHHtSANABAAMABglFGntSANABAAQAAwmIGnQtAAcBAAAA.',
['向小']='向小园:BAAALgAECgQJBwAAAA==.',
['听讲']='听讲好犀利:BAAALgAECgYJCwAAAA==.',
['呆萌']='呆萌小虎虎:BAAALgAECgEJAQAAAA==.',
['咕咕']='咕咕皮五号机:BAAALgAECgkJEAAAAA==.',
['咕迩']='咕迩妲:BAAALgAECgEJAgAAAA==.',
['咖啡']='咖啡是豆浆:BAABLgAFFH8GAAIOAAMJOxbTBwDtAAAOAAMJOxbTBwDtAAAAAA==.',
['咖喱']='咖喱牛肉干:BAABLgAFFH8IAAIPAAMJiB79BgAVAQAPAAMJiB79BgAVAQAAAA==.咖喱钙钙:BAAALgADCgEJAQAAAA==.',
['咚冬']='咚冬冻:BAAALgAFFAEJAQAAAA==.',
['哆哆']='哆哆和啵啵:BAAALgAECgUJBQAAAA==.',
['哆啦']='哆啦咪嗦嘻:BAAALgAECgEJAQAAAA==.',
['哇你']='哇你好会:BAAALgAECgMJBAAAAA==.',
['哈嘛']='哈嘛的小鱼干:BAAALgAFFAIJAgAAAA==.',
['哈姆']='哈姆小太郎:BAAALgAECgMJAwAAAA==.',
['哈尼']='哈尼德:BAAALgAECgMJAwAAAA==.',
['哟哟']='哟哟灬子:BAAALgAECgYJBAAAAA==.',
['哼着']='哼着小曲儿:BAABLgAFFH8LAAIUAAQJhxtZAwBoAQAUAAQJhxtZAwBoAQAAAA==.',
['唐牛']='唐牛才是食神:BAAALgAECgcJBwAAAA==.',
['啊德']='啊德玛丽:BAAALgAECgYJCwAAAA==.',
['啪趴']='啪趴熊:BAAALgAECgYJBgAAAA==.',
['啻龙']='啻龙凶僧:BAAALgAECgIJAgAAAA==.啻龙小德:BAAALgAECgcJEgAAAA==.啻龙希利尔:BAAALgADCgYJBgAAAA==.啻龙黑骑:BAAALgAECgEJAQAAAA==.',
['喜庆']='喜庆的阿昆达:BAAALgAECgcJDgAAAA==.',
['喝老']='喝老醉咯:BAAALgAECgEJAQAAAA==.',
['喵呜']='喵呜喵呜喵:BAAALgAECgEJAQAAAA==.',
['嘻哈']='嘻哈哈宁樱:BAAALgAECgcJAwAAAA==.',
['嚣张']='嚣张的小妞:BAAALgAECgEJAQAAAA==.',
['回忆']='回忆流年:BAAALgADCgYJBgAAAA==.',
['因你']='因你团灭:BAACLgAFFH8FAAICAAMJhgIKGQDIAAACAAMJhgIKGQDIAAAuAAQKfyUAAgIACAkbF5sSAJgBAAIACAkbF5sSAJgBAAAA.',
['囧囧']='囧囧小菜刀:BAAALgADCgUJBQAAAA==.',
['国宝']='国宝大师兄:BAAALgAECgEJAQAAAA==.',
['土土']='土土士土土:BAAALgAECgYJDAAAAA==.',
['土木']='土木大领主:BAAALgAECgUJBwAAAA==.',
['圣之']='圣之悲伤:BAAALgAECgcJDAAAAA==.',
['圣光']='圣光之佑:BAAALgAECgYJBgAAAA==.圣光呆:BAAALgAECgEJAQAAAA==.圣光救赎丶:BAAALgAECgcJCwAAAA==.圣光漂移:BAAALgAECgEJAQAAAA==.圣光百变:BAAALgADCgYJBgAAAA==.',
['圣堂']='圣堂骑士团:BAAALgAECgIJAQAAAA==.',
['地狱']='地狱的宝宝:BAAALgAFFAEJAwAAAA==.',
['坂井']='坂井泉水:BAAALgAECgQJBQAAAA==.',
['坚强']='坚强的小克:BAAALgADCgYJBgAAAA==.',
['型英']='型英正帅靓:BAABLgAFFH8HAAIUAAMJ/BqwCQAUAQAUAAMJ/BqwCQAUAQAAAA==.',
['墨涟']='墨涟:BAAALgAECgYJEQABLgAFFAIJBAAKAAAAAA==.',
['复仇']='复仇的苍炎:BAAALgAECgQJCwAAAA==.',
['多拉']='多拉贡丹斯:BAABLgAFFH8HAAMWAAQJZRNNEACfAAAWAAMJWA9NEACfAAAMAAIJTBIoEgCdAAAAAA==.',
['夜魇']='夜魇契约:BAAALgAECgYJCAAAAA==.',
['大天']='大天使时雨丿:BAAALgAECgcJDQAAAA==.',
['大寳']='大寳贝:BAAALgADCgQJBAAAAA==.',
['大年']='大年年:BAABLgAFFH8IAAIIAAQJVBVQGgBhAQAIAAQJVBVQGgBhAQAAAA==.',
['大核']='大核桃:BAAALgADCgIJAgAAAA==.',
['大角']='大角鼠神选:BAAALgADCgcJBwAAAA==.',
['大跳']='大跳开怪:BAABLgAFFH8FAAIMAAUJaRnbAwDFAQAMAAUJaRnbAwDFAQAAAA==.',
['大骑']='大骑士:BAAALgAECgEJAQAAAA==.',
['大黄']='大黄丶疯子:BAAALgAECgYJBgAAAA==.',
['天使']='天使小妖:BAAALgAECgcJBwAAAA==.',
['天堂']='天堂战:BAAALgAECgEJAQAAAA==.',
['天气']='天气真潮:BAAALgADCgEJAQAAAA==.天气真采:BAABLgAFFH8GAAIbAAMJwxldDwDzAAAbAAMJwxldDwDzAAAAAA==.',
['天空']='天空的雲海:BAAALgADCgUJCgAAAA==.',
['天血']='天血遍身:BAAALgADCgUJBQAAAA==.',
['奇趣']='奇趣博士:BAAALgADCgQJBAAAAA==.',
['奔跑']='奔跑的八达:BAAALgADCgYJCAAAAA==.',
['奶哥']='奶哥哥:BAAALgADCgMJAwAAAA==.',
['奶油']='奶油蛋挞:BAAALgAECgUJBQAAAA==.',
['好丶']='好丶小伙:BAAALgAECgIJAgAAAA==.',
['好多']='好多呆毛:BAAALgAFFAMJAwAAAA==.',
['妖妖']='妖妖小巫:BAAALgAECgYJDwAAAA==.',
['威猛']='威猛先生:BAAALgAECgEJAQAAAA==.',
['孑凌']='孑凌:BAAALgADCgcJBwAAAA==.',
['孤羽']='孤羽幽梦:BAAALgADCgQJBAAAAA==.',
['学弟']='学弟:BAAALgAECgEJAQAAAA==.',
['宇韶']='宇韶容:BAAALgAFFAIJBAABLgAFFAQJDQAMAPMlAA==.',
['安吉']='安吉大法师:BAAALgAECgMJAwAAAA==.',
['安塞']='安塞波:BAAALgAECgUJBwAAAA==.',
['安菲']='安菲尔德:BAAALgAECgQJBQAAAA==.',
['宋大']='宋大官:BAAALgAECgcJBwAAAA==.',
['完达']='完达山一号:BAAALgAFFAEJAQAAAA==.',
['寂寞']='寂寞的粉龙皇:BAAALgAFFAEJAQAAAA==.',
['对你']='对你画叉叉:BAAALgADCgEJAQAAAA==.',
['射击']='射击裂:BAAALgAECgQJBwAAAA==.',
['射灬']='射灬:BAAALgAECgEJAQAAAA==.',
['小丶']='小丶莓:BAAALgAECgYJBgAAAA==.小丶蕊:BAAALgAECgMJAgAAAA==.小丶鑫:BAAALgAECgQJBAAAAA==.小丶雅:BAAALgAECgYJDAAAAA==.',
['小关']='小关系:BAAALgADCgEJAQAAAA==.',
['小圈']='小圈圈:BAAALgAECgMJAwAAAA==.',
['小埋']='小埋:BAABLgAECn8TAAIUAAcJdSGFFgCEAgAUAAcJdSGFFgCEAgAAAA==.',
['小尨']='小尨人:BAAALgADCgMJAwAAAA==.',
['小弟']='小弟也有传说:BAAALgADCgEJAQAAAA==.',
['小撒']='小撒:BAAALgAECgYJDAAAAA==.',
['小月']='小月虹子:BAAALgAECgYJDwAAAA==.小月虹虹:BAACLgAFFH8OAAIcAAQJ9B32AQBjAQAcAAQJ9B32AQBjAQAuAAQKfxwAAhwACQkOIvwEAEIDABwACQkOIvwEAEIDAAAA.',
['小泽']='小泽佑沐风:BAAALgAECgkJEgAAAA==.',
['小花']='小花蟹:BAAALgAECgYJDwAAAA==.',
['小麦']='小麦铛铛响:BAAALgAECgEJAQAAAA==.',
['小黒']='小黒:BAAALgAECgcJEwAAAA==.',
['尘浮']='尘浮:BAAALgAECgYJBgAAAA==.',
['尤米']='尤米莉亚:BAAALgAECgEJAwAAAA==.',
['就是']='就是你干的:BAACLgAFFH8IAAICAAQJ1xeQCABKAQACAAQJ1xeQCABKAQAuAAQKfysAAgIACAnJIygCALcCAAIACAnJIygCALcCAAAA.',
['就这']='就这就这:BAAALgAECgYJDQAAAA==.',
['居丽']='居丽:BAAALgADCgMJAwAAAA==.',
['屍體']='屍體在說话:BAAALgADCgYJBwAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8KAAIdAAUJiAf5BgAjAQAdAAUJiAf5BgAjAQAAAA==.',
['山姆']='山姆大叔:BAAALgAECgMJAwAAAA==.',
['山猫']='山猫大王:BAAALgADCgUJBQAAAA==.',
['岛主']='岛主大人:BAABLgAFFH8JAAIUAAMJqyPeBwAmAQAUAAMJqyPeBwAmAQAAAA==.',
['巫僧']='巫僧:BAAALgAECgQJAgAAAA==.',
['巴掌']='巴掌:BAABLgAFFH8KAAIbAAQJ1xQUCQBCAQAbAAQJ1xQUCQBCAQAAAA==.',
['帅气']='帅气的大咕咕:BAAALgAECgEJAQAAAA==.',
['希铄']='希铄:BAAALgADCgQJBgAAAA==.',
['帝皇']='帝皇的天使:BAAALgAECgMJAwAAAA==.',
['干锅']='干锅侠:BAAALgAECgIJAgAAAA==.',
['平淡']='平淡如白开水:BAAALgAECgUJCgAAAA==.',
['年年']='年年有拖拍:BAAALgAECgcJEAAAAA==.',
['幸福']='幸福满满:BAAALgAECgUJCQAAAA==.幸福的琪琪:BAAALgADCgEJAQAAAA==.',
['幻龙']='幻龙丶桃昔:BAAALgAECgIJAgAAAA==.',
['幽蓝']='幽蓝小巫:BAACLgAFFH8OAAIeAAUJQxmIAAB0AQAeAAUJQxmIAAB0AQAuAAQKfxoAAh4ACAnIIl0CACoDAB4ACAnIIl0CACoDAAAA.',
['开大']='开大智商归零:BAAALgAECgEJAgAAAA==.',
['张学']='张学友丶丶:BAAALgAECgYJBgAAAA==.',
['弦歌']='弦歌知雅意:BAAALgAECgMJBQAAAA==.',
['强袭']='强袭机甲:BAAALgAECgEJAQAAAA==.',
['徐绕']='徐绕德:BAAALgAECgIJAgAAAA==.',
['得得']='得得比丶慓慓:BAABLgAECn8XAAIIAAcJgh4XFQC5AQAIAAcJgh4XFQC5AQAAAA==.得得的德:BAAALgAFFAIJAgAAAA==.',
['御鸾']='御鸾莺丶:BAABLgAFFH8FAAIVAAQJ3RsmLgAyAAAVAAQJ3RsmLgAyAAAAAA==.',
['德意']='德意扬扬:BAAALgADCgUJBQAAAA==.',
['德芙']='德芙天下:BAAALgADCgcJBwAAAA==.德芙欧尼酱:BAAALgAECgEJAgAAAA==.',
['德鲁']='德鲁一牛牛:BAAALgAECgIJAwAAAA==.',
['心思']='心思:BAAALgAECgcJDwAAAA==.',
['心戎']='心戎:BAABLgAECn8qAAIcAAgJihk8BgDAAQAcAAgJihk8BgDAAQAAAA==.',
['心舞']='心舞随风:BAAALgADCgEJAgAAAA==.',
['快到']='快到碗里來:BAAALgAECgEJAQABLgAFFAcJFgAZAGsTAA==.',
['快活']='快活快活:BAAALgADCgEJAQAAAA==.',
['快要']='快要灬睡着了:BAAALgAECgIJAgAAAA==.',
['念夕']='念夕空:BAABLgAECn8UAAIBAAcJhRUsNQCoAQABAAcJhRUsNQCoAQAAAA==.',
['怀柔']='怀柔天下:BAAALgAECgEJAQAAAA==.',
['思网']='思网郎:BAAALgADCgcJCAAAAA==.',
['性别']='性别别卡太死:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔血神:BAAALgAFFAIJAgAAAA==.',
['悦小']='悦小美美:BAAALgAECgcJCQAAAA==.',
['悲酥']='悲酥清风风:BAAALgADCgIJAgAAAA==.',
['情義']='情義灬凌風:BAAALgAECgUJBQAAAA==.情義灬晨風:BAAALgAECgYJBgAAAA==.情義灬沐風:BAAALgAFFAQJBAAAAA==.',
['惜梦']='惜梦缘:BAAALgADCgEJAQAAAA==.',
['惠子']='惠子泛瞌睡:BAAALgAECgMJAwAAAA==.惠子爱瞌睡:BAAALgAECgYJCgAAAA==.惠子犯瞌睡:BAAALgAECgYJDQAAAA==.',
['想偷']='想偷懒:BAACLgAFFH8SAAIQAAUJhxnwAwCpAQAQAAUJhxnwAwCpAQAuAAQKfyAAAxAACQm3IYICAIcDABAACQm3IYICAIcDAA8AAgnUFPKIAHAAAAAA.',
['懵懵']='懵懵小驴:BAAALgADCgYJBgAAAA==.',
['我凌']='我凌乱了:BAAALgAECgYJCAAAAA==.',
['我家']='我家猫会颠勺:BAAALgAECgUJBQAAAA==.',
['我是']='我是东山啊:BAAALgAECgQJBAAAAA==.',
['我爱']='我爱一碌葛:BAAALgAECgUJBQAAAA==.',
['我锤']='我锤石你德玛:BAAALgAECgUJCgAAAA==.',
['戳戳']='戳戳你的:BAABLgAFFH8IAAMVAAMJHRYTFAD+AAAVAAMJ2hMTFAD+AAAUAAIJ1RIYEQCyAAAAAA==.',
['房山']='房山季鸟猴:BAAALgAECgEJAQAAAA==.',
['扎瓦']='扎瓦露多:BAAALgADCgEJAQAAAA==.',
['打你']='打你屁屁:BAAALgAECgEJAQAAAA==.',
['扛几']='扛几楼一袋米:BAAALgAECgEJAQAAAA==.',
['承诺']='承诺丶男人酒:BAAALgAECgkJCQAAAA==.',
['抓不']='抓不住的优伶:BAAALgAECgEJAQAAAA==.',
['抽抽']='抽抽王:BAAALgAECgYJBgAAAA==.',
['拑摱']='拑摱插抳挌拢:BAABLgAECn8YAAICAAcJBAziKAARAQACAAcJBAziKAARAQAAAA==.',
['拜你']='拜你为师:BAACLgAFFH8LAAIfAAQJgyCTAACQAQAfAAQJgyCTAACQAQAuAAQKfxcAAh8ACAkWImMIAPMCAB8ACAkWImMIAPMCAAAA.',
['拳拳']='拳拳打到脸:BAAALgAECgkJDwAAAA==.',
['拾丶']='拾丶玖:BAABLgAECn8WAAIRAAYJXSLeCwD2AQARAAYJXSLeCwD2AQAAAA==.',
['拿破']='拿破丶抡大锤:BAAALgAECgkJCQAAAA==.',
['捡你']='捡你肥皂:BAAALgAECgYJDgAAAA==.',
['提尔']='提尔比茨:BAAALgADCgEJAQAAAA==.',
['搓火']='搓火球甩冰枪:BAAALgAECgIJAgAAAA==.',
['擦头']='擦头斯基:BAAALgAFFAQJBAAAAA==.',
['救你']='救你咕命:BAAALgAECgEJAQAAAA==.',
['教你']='教你卖门:BAAALgADCgcJBwAAAA==.',
['教导']='教导主任:BAAALgAFFAEJAQAAAA==.',
['散装']='散装火山:BAACLgAFFH8IAAIIAAMJoxupFQAKAQAIAAMJoxupFQAKAQAuAAQKfxQAAggACAlVGjRXADMCAAgACAlVGjRXADMCAAAA.',
['文淇']='文淇:BAABLgAFFH8FAAIDAAMJSwZjFwDgAAADAAMJSwZjFwDgAAAAAA==.',
['新年']='新年快乐吖:BAAALgAECgEJAQAAAA==.',
['无可']='无可理喻:BAAALgAECgYJBQAAAA==.',
['无实']='无实物表演:BAAALgAECgQJBAAAAA==.',
['无敌']='无敌小贱贱:BAAALgADCgEJAQAAAA==.',
['无极']='无极:BAAALgAECgEJAQAAAA==.',
['无泪']='无泪鱼:BAAALgAECgEJAQAAAA==.',
['无限']='无限大德:BAAALgAFFAIJAwAAAA==.无限大萨:BAABLgAFFH8JAAIPAAIJwiOtCgDVAAAPAAIJwiOtCgDVAAAAAA==.',
['旧约']='旧约海棠:BAABLgAECn8kAAIBAAgJoRCyLQDNAQABAAgJoRCyLQDNAQAAAA==.',
['昊天']='昊天国王:BAAALgADCgUJCgAAAA==.',
['星之']='星之卡比猪:BAAALgADCgEJAQAAAA==.',
['星辰']='星辰陨落丨:BAAALgAECgUJBQAAAA==.',
['是秃']='是秃子就发光:BAAALgAECgYJCgAAAA==.',
['晚栀']='晚栀:BAAALgAECgEJAQAAAA==.',
['景丿']='景丿:BAAALgAECgYJDgAAAA==.',
['暑实']='暑实:BAAALgAECgYJBgAAAA==.',
['暗丶']='暗丶怒:BAABLgAFFH8DAAIDAAIJCg/lNwCkAAADAAIJCg/lNwCkAAABLgAFFAcJBwADANgSAA==.',
['暗夜']='暗夜蕉灵:BAAALgADCgUJBQAAAA==.',
['暗影']='暗影丶咆哮:BAAALgADCgkJCQAAAA==.暗影的貞子:BAAALgADCgYJBgAAAA==.',
['暴怒']='暴怒的猫老大:BAAALgAECgcJBgAAAA==.',
['暴躁']='暴躁的小雯:BAAALgAECgUJBwAAAA==.',
['曈曈']='曈曈麻麻:BAAALgAECgkJCQAAAA==.',
['曦月']='曦月丶:BAAALgAFFAEJAQAAAA==.',
['曲天']='曲天歌:BAAALgAECgYJDAAAAA==.',
['替你']='替你收尸:BAAALgAECgcJDQAAAA==.',
['月下']='月下小夜曲:BAAALgAECgYJDAABLgAECgkJAQAKAAAAAA==.',
['月华']='月华不度:BAABLgAFFH8GAAIMAAQJ0AP5BgDxAAAMAAQJ0AP5BgDxAAAAAA==.',
['月壴']='月壴彡月长:BAABLgAFFH8KAAIGAAQJcRTsCQBYAQAGAAQJcRTsCQBYAQAAAA==.',
['月舒']='月舒:BAABLgAFFH8GAAIbAAQJZhWiBwAYAQAbAAQJZhWiBwAYAQAAAA==.',
['月落']='月落灬星天:BAAALgAFFAEJAQAAAA==.',
['有你']='有你有我:BAAALgAFFAQJAgAAAA==.',
['有法']='有法必有尸:BAAALgAECgYJBwAAAA==.',
['有盾']='有盾就行:BAABLgAFFH8JAAIGAAMJtCCJDQAvAQAGAAMJtCCJDQAvAQAAAA==.',
['杀戮']='杀戮:BAAALgAECgUJBQABLgAFFAQJCwAVAFERAA==.',
['李胖']='李胖子在此:BAAALgADCgQJBAAAAA==.',
['来未']='来未:BAAALgAECgUJCAAAAA==.',
['板筋']='板筋:BAAALgAECgYJBQAAAA==.',
['柑蕉']='柑蕉橘梨萝柚:BAAALgAECgcJEQAAAA==.',
['柒尺']='柒尺寒:BAAALgADCgkJCQAAAA==.',
['查理']='查理卓别林:BAABLgAECn8XAAIDAAgJ5iPzCQAuAwADAAgJ5iPzCQAuAwAAAA==.',
['树下']='树下数光阴:BAAALgADCgYJBgAAAA==.',
['桂花']='桂花乌龙:BAABLgAFFH8NAAIRAAUJNyGCAgB+AQARAAUJNyGCAgB+AQAAAA==.',
['桃乃']='桃乃木乃术:BAAALgAECgYJCAAAAA==.',
['桃小']='桃小昔:BAAALgAECgcJEwAAAA==.',
['桥本']='桥本没菜:BAAALgAECgcJCQAAAA==.',
['梦境']='梦境之拥:BAAALgADCgEJAQAAAA==.',
['梦逝']='梦逝灬流水:BAAALgAECgEJAQAAAA==.',
['森嘀']='森嘀耶:BAAALgAECgMJAwAAAA==.',
['椒房']='椒房:BAACLgAFFH8FAAIDAAMJkQfoJQDpAAADAAMJkQfoJQDpAAAuAAQKfxgAAgMACAmIE7Q8ABoCAAMACAmIE7Q8ABoCAAAA.',
['楓的']='楓的故鄉:BAAALgAECgIJAgABLgAECggJEwAKAAAAAA==.',
['楚风']='楚风:BAAALgAECgYJEAAAAA==.',
['樱雨']='樱雨墨落:BAABLgAECn8bAAMOAAgJvR0rCgCrAgAOAAgJqR0rCgCrAgANAAcJrh+8CgCLAgAAAA==.',
['欣之']='欣之法老:BAAALgAECgcJCgAAAA==.',
['欧巴']='欧巴哈其玛:BAABLgAECn8bAAIgAAYJHgzXJQAQAQAgAAYJHgzXJQAQAQAAAA==.欧巴哈基嘛:BAACLgAFFH8GAAIhAAMJah+wCQAZAQAhAAMJah+wCQAZAQAuAAQKfxUAAyEABgkCHaQOACoBACEABgkCHaQOACoBABkABQnrAHxvAIQAAAAA.',
['欲行']='欲行呢:BAAALgADCgEJAQAAAA==.',
['歪果']='歪果仁:BAAALgAFFAEJAQAAAA==.',
['殇之']='殇之潋溟:BAAALgAECgUJBQAAAA==.',
['殺戮']='殺戮之心:BAAALgAECgYJBgAAAA==.',
['毁灭']='毁灭术:BAAALgAFFAMJAwAAAA==.',
['比你']='比你还菜:BAACLgAFFH8LAAIBAAQJ1iSbAwCsAQABAAQJ1iSbAwCsAQAuAAQKfxQAAgEABglnJroPAJYCAAEABglnJroPAJYCAAAA.',
['比卡']='比卡比卡恘:BAAALgAECgQJAQAAAA==.',
['水拳']='水拳:BAAALgADCgIJAgAAAA==.',
['水鱼']='水鱼:BAACLgAFFH8NAAMDAAQJHB70DAB0AQADAAQJsxz0DAB0AQAiAAEJARtMAQBhAAAuAAQKfysABAMABwngIr01ADUCAAMABgnJIr01ADUCAAQAAwmvFhAyAPAAACIAAQkaJFAHAG0AAAAA.',
['永不']='永不杀生:BAAALgAECgcJDAAAAA==.',
['永恒']='永恒死骑:BAAALgAECgQJBAAAAA==.',
['汤臣']='汤臣一品保安:BAAALgAFFAQJBAAAAA==.',
['河东']='河东湿红:BAAALgAECgYJBwAAAA==.',
['法力']='法力渣渣:BAAALgAECgYJCQAAAA==.',
['泡泡']='泡泡糖:BAAALgAECgYJBgABLgAFFAQJBAAKAAAAAA==.',
['洛月']='洛月:BAAALgADCgEJAQAAAA==.',
['活你']='活你鱼串:BAAALgAECgIJAgAAAA==.',
['流沙']='流沙之麟:BAAALgAECgYJCwAAAA==.',
['浪比']='浪比:BAAALgAECgYJBwAAAA==.',
['浪荡']='浪荡的小桃花:BAAALgAFFAEJAQAAAA==.',
['浪里']='浪里捉泥鳅:BAAALgADCgEJAQAAAA==.',
['浮世']='浮世:BAAALgAECgYJBgAAAA==.',
['浮尘']='浮尘随浪逝:BAAALgAECgMJBQAAAA==.',
['浮生']='浮生半世:BAAALgAECgQJBAAAAA==.',
['海南']='海南林三岁丶:BAABLgAECn8VAAIUAAcJZBbfLQD7AQAUAAcJZBbfLQD7AQAAAA==.',
['海瑟']='海瑟音:BAAALgAECgYJBQAAAA==.',
['润哥']='润哥:BAAALgAECgUJCQAAAA==.',
['淂又']='淂又菿涕嘞:BAAALgAECgYJAwAAAA==.',
['深爱']='深爱小弟:BAAALgAECgcJBwAAAA==.深爱滴胖胖:BAAALgAECgcJBwAAAA==.深爱熊猫:BAAALgAECgcJBwAAAA==.',
['混乱']='混乱的协奏:BAAALgAECgEJAQAAAA==.',
['清淡']='清淡狂猎:BAAALgAECgcJDQAAAA==.',
['清蒸']='清蒸大熊猫:BAABLgAFFH8GAAICAAMJuxOuJwD5AAACAAMJuxOuJwD5AAAAAA==.',
['渟澜']='渟澜:BAAALgAECgQJBwAAAA==.',
['温州']='温州村长大人:BAAALgAECgMJBwAAAA==.',
['溺豹']='溺豹悲歌:BAAALgADCgMJAwAAAA==.',
['满足']='满足丶什么:BAAALgAFFAEJAgAAAA==.满足什么鬼:BAAALgAFFAIJAgAAAA==.',
['潇丨']='潇丨筱筱灬:BAAALgAECgEJAQAAAA==.',
['潇丶']='潇丶梦濋:BAAALgAECgEJAwAAAA==.',
['火球']='火球教主:BAAALgADCgEJAQAAAA==.',
['火车']='火车王:BAAALgAECgEJAQAAAA==.',
['灬大']='灬大尸兄灬:BAAALgAFFAIJAgAAAA==.',
['灬武']='灬武僧灬:BAAALgADCgMJAwAAAA==.',
['灬花']='灬花落丶:BAAALgAECgYJEQAAAA==.',
['灬阿']='灬阿森:BAAALgADCgEJAQAAAA==.',
['灰化']='灰化:BAABLgAECn8VAAMFAAgJhxIXMACHAQAFAAcJdxEXMACHAQAbAAgJYA2XSQB8AQAAAA==.',
['灵砚']='灵砚绘虎:BAACLgAFFH8JAAMhAAQJTB3sBQBvAQAhAAQJTB3sBQBvAQAfAAEJcALpDAA8AAAuAAQKfxwAAyEACAkGImQGAPkCACEACAkGImQGAPkCAB8ABAmwEZ9LAOQAAAAA.',
['炙热']='炙热的圣光:BAAALgAECgUJBQAAAA==.',
['炮灰']='炮灰猎:BAAALgAECgUJBQAAAA==.',
['炽热']='炽热龙利鱼:BAAALgAECgcJDQAAAA==.',
['烟云']='烟云似雪:BAAALgAECgYJCQAAAA==.',
['烟雨']='烟雨琼琼:BAAALgAECgYJBgAAAA==.',
['烟鬼']='烟鬼:BAAALgADCgEJAQAAAA==.',
['烤全']='烤全牛:BAAALgAECgQJBAABLgAFFAMJAwAKAAAAAA==.',
['烦人']='烦人精念念:BAAALgAECgQJAgAAAA==.',
['烬丶']='烬丶:BAAALgAECgEJAQAAAA==.',
['無懈']='無懈:BAAALgAECgUJCQAAAA==.',
['焱燃']='焱燃:BAAALgAECgYJBgABLgAFFAIJAgAKAAAAAA==.',
['煌希']='煌希:BAAALgAECgEJAQAAAA==.',
['熊人']='熊人永不为奴:BAAALgAECgEJAgAAAA==.',
['熊猫']='熊猫:BAABLgAECn8VAAIIAAcJiRTndwDiAQAIAAcJiRTndwDiAQAAAA==.',
['燃烧']='燃烧你的梦:BAAALgAECgUJCwAAAA==.',
['燎原']='燎原火丶:BAAALgADCgYJBgAAAA==.',
['爆炒']='爆炒傻兔子:BAAALgAECgUJBAAAAA==.',
['牧苏']='牧苏德:BAAALgADCgEJAQAAAA==.牧苏鸣人:BAAALgAECgYJCgAAAA==.',
['特么']='特么悲剧:BAAALgAECgQJBAAAAA==.',
['狂斧']='狂斧烈锤:BAAALgAECgkJCQAAAA==.',
['狐人']='狐人女比较萌:BAAALgADCgEJAgAAAA==.',
['狗急']='狗急了:BAACLgAFFH8NAAIbAAUJGBQsBQCKAQAbAAUJGBQsBQCKAQAuAAQKfysAAxsACQlJGggRALACABsACQlJGggRALACAAUAAQmtBdWAADAAAAAA.',
['狗蛋']='狗蛋小凡哥:BAAALgAECgYJBwAAAA==.',
['猜码']='猜码王子:BAAALgAECgMJAQAAAA==.',
['猫猫']='猫猫拳:BAAALgAECgEJAQAAAA==.',
['玩了']='玩了也无聊:BAAALgAECgQJBwAAAA==.',
['现任']='现任:BAAALgAECgYJDAAAAA==.',
['玲珑']='玲珑魅影:BAAALgAECgcJDQAAAA==.',
['珑玲']='珑玲:BAAALgADCgYJBgAAAA==.',
['珠玑']='珠玑亨特:BAAALgADCgcJCwAAAA==.',
['班子']='班子大人:BAABLgAFFH8GAAIXAAIJbgaPBQBeAAAXAAIJbgaPBQBeAAAAAA==.',
['琦琦']='琦琦努琪:BAAALgAECgcJBgAAAA==.',
['瑟迪']='瑟迪玛里苟萨:BAAALgAECgYJBgAAAA==.',
['瓦莲']='瓦莲京娜:BAAALgAECgMJBwAAAA==.',
['瓦解']='瓦解:BAAALgAECgEJAQAAAA==.',
['生化']='生化煎饼:BAAALgAECgEJAQAAAA==.',
['生石']='生石:BAAALgAECgYJDAAAAA==.',
['电波']='电波美少女:BAAALgAECgYJBwAAAA==.',
['电闪']='电闪雷鸣:BAACLgAFFH8HAAIPAAQJARagBABCAQAPAAQJARagBABCAQAuAAQKfxwAAg8ACAlSG+4RAIcCAA8ACAlSG+4RAIcCAAAA.',
['疯子']='疯子玉:BAAALgAECgMJAwAAAA==.',
['皪皪']='皪皪酱丶:BAAALgAFFAQJBAAAAA==.',
['盒饭']='盒饭的故事:BAABLgAECn8UAAIGAAYJnBZ7FAAhAQAGAAYJnBZ7FAAhAQAAAA==.',
['睡觉']='睡觉去了:BAAALgADCgQJBQAAAA==.',
['矮个']='矮个子西瓦:BAAALgADCgMJAwAAAA==.',
['矮人']='矮人大妈:BAAALgAECgcJDgAAAA==.',
['石昊']='石昊:BAAALgAECgYJCgABLgAECgYJEAAKAAAAAA==.',
['研究']='研究员豆老师:BAAALgAECgYJBgAAAA==.',
['破音']='破音:BAAALgAECgMJAQAAAA==.',
['磊落']='磊落不羁:BAAALgAECgEJAQAAAA==.',
['神奇']='神奇萨满:BAABLgAECn8aAAMPAAgJlh4CFgBlAgAPAAgJlh4CFgBlAgAQAAEJOwBhmAAOAAAAAA==.',
['神秘']='神秘人丶:BAAALgAFFAEJAQABLgAFFAYJEgASAFkWAA==.',
['福漾']='福漾:BAAALgAFFAIJBAAAAA==.',
['秀芳']='秀芳:BAAALgAECgUJBQAAAA==.',
['秋之']='秋之枫叶:BAAALgAECggJEwAAAA==.',
['空芯']='空芯菜:BAAALgADCgIJAgAAAA==.',
['章鱼']='章鱼丿:BAAALgAECgYJCgAAAA==.',
['笙歌']='笙歌歌:BAEALgAECgUJBQABLgAECgYJFAABAKEYAA==.',
['符文']='符文图腾丶萨:BAAALgAECgMJAwAAAA==.',
['笼中']='笼中鸟鸟:BAAALgAECgUJCAAAAA==.',
['筛你']='筛你团子:BAAALgAFFAIJAgAAAA==.',
['米凯']='米凯拉的锋刃:BAAALgAECgIJAgAAAA==.',
['粢饭']='粢饭膏:BAAALgADCgcJDQAAAA==.',
['糖沫']='糖沫:BAABLgAFFH8IAAIRAAMJ4BjiCgANAQARAAMJ4BjiCgANAQAAAA==.',
['糖门']='糖门滾:BAAALgAECgEJAQAAAA==.',
['素月']='素月:BAAALgAFFAIJAgAAAA==.',
['素毒']='素毒咩:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色蝗虫:BAAALgAECgYJCAAAAA==.',
['繆哈']='繆哈符文图腾:BAAALgAECgQJBgAAAA==.',
['红烧']='红烧胖头驴:BAAALgAECgUJBgAAAA==.',
['红牛']='红牛很红:BAAALgADCgIJAgAAAA==.',
['纲手']='纲手的本子:BAAALgAFFAMJAwAAAA==.',
['纳格']='纳格兰的远山:BAAALgAFFAIJAgAAAA==.',
['给你']='给你个大碧抖:BAAALgAECgUJCAAAAA==.给你今晚:BAAALgADCgIJAgAAAA==.',
['绝色']='绝色牛牛:BAAALgAECgEJAQAAAA==.',
['罔亖']='罔亖罔:BAAALgAECgEJAgAAAA==.',
['罗兰']='罗兰圣裔:BAAALgAECgIJAgAAAA==.',
['罗盘']='罗盘玫瑰:BAAALgAECgEJAQAAAA==.',
['罗老']='罗老师会咋做:BAAALgAECgEJAQAAAA==.',
['美少']='美少女大橙子:BAAALgAECgYJDAAAAA==.',
['羞羞']='羞羞的哈籁:BAAALgAECgcJDwAAAA==.',
['羽翼']='羽翼灵动:BAAALgAECgEJAQAAAA==.',
['羽落']='羽落梦洲:BAAALgAECgQJBQAAAA==.',
['老灬']='老灬湿:BAAALgAECgQJCQAAAA==.',
['老王']='老王:BAAALgADCgMJAwAAAA==.',
['老虎']='老虎:BAAALgAECgYJBgAAAA==.',
['胤丨']='胤丨丨胤:BAAALgAECgIJAgAAAA==.',
['胸毛']='胸毛人之怒:BAAALgADCgcJBwAAAA==.',
['脆皮']='脆皮尐奶包:BAAALgAECgIJAgAAAA==.',
['脚涂']='脚涂辣椒油:BAAALgAECgYJBwAAAA==.',
['腹肌']='腹肌去哪了:BAABLgAECn8bAAIYAAcJCRQxBgAZAgAYAAcJCRQxBgAZAgAAAA==.',
['色艺']='色艺双絶:BAAALgAECgIJAgAAAA==.',
['艾琳']='艾琳:BAAALgAFFAQJBAAAAA==.',
['芝华']='芝华塔尼欧:BAABLgAFFH8FAAIDAAIJXw55IACnAAADAAIJXw55IACnAAAAAA==.',
['芯已']='芯已冻结:BAAALgAECgYJBgAAAA==.芯已凍结:BAAALgAECgIJAQAAAA==.',
['花似']='花似锦:BAAALgADCgUJBgAAAA==.',
['花开']='花开丶渃相依:BAAALgAECgMJAwAAAA==.花开伊吕波:BAAALgAFFAEJAQAAAA==.花开须相依:BAAALgAECgQJBAAAAA==.',
['花散']='花散响销:BAAALgADCgkJDgAAAA==.',
['花泽']='花泽空心菜:BAABLgAFFH8GAAIUAAIJIRt1FQCvAAAUAAIJIRt1FQCvAAAAAA==.',
['花落']='花落丶寞相弃:BAAALgAECgYJDQAAAA==.花落丿:BAAALgAECgUJBgAAAA==.',
['苍天']='苍天的救赎:BAAALgADCgEJAgAAAA==.',
['若你']='若你安好:BAAALgAECgYJDgAAAA==.',
['若梦']='若梦:BAAALgAECgIJAgAAAA==.',
['茗茗']='茗茗的荼荼:BAAALgAFFAIJAgAAAA==.茗茗祖宗:BAAALgAFFAEJAQAAAA==.',
['茯苓']='茯苓呀:BAAALgAFFAIJAwAAAA==.',
['茶茶']='茶茶荼:BAACLgAFFH8HAAIgAAMJHAH/BgCQAAAgAAMJHAH/BgCQAAAuAAQKfxgAAiAABgkhB0YPALIAACAABgkhB0YPALIAAAAA.',
['荼茶']='荼茶茗:BAABLgAECn8UAAIjAAYJpwoEIwDwAAAjAAYJpwoEIwDwAAAAAA==.',
['莫氏']='莫氏野驴:BAACLgAFFH8LAAMVAAQJURELDwA6AQAVAAQJnRALDwA6AQAUAAIJfQq8EwCmAAAuAAQKfyMAAxUACAknG3gVAIICABUACAmvGngVAIICABQAAgkWFso4AKIAAAAA.',
['莲池']='莲池染红袖丶:BAACLgAFFH8PAAMCAAUJhhr8FgBIAQACAAUJQRL8FgBIAQAkAAMJ5Ba/AQAOAQAuAAQKfyEAAgIACQmDHskJAE4DAAIACQmDHskJAE4DAAAA.',
['莽哥']='莽哥哥:BAAALgAECgUJBwAAAA==.',
['菅牧']='菅牧典:BAABLgAFFH8LAAMDAAQJzCGfCQCSAQADAAQJXx2fCQCSAQAEAAEJaRfCEgBZAAAAAA==.',
['萨气']='萨气腾腾:BAABLgAECn8cAAIPAAYJwRebDgCBAQAPAAYJwRebDgCBAQAAAA==.',
['落乄']='落乄晨:BAAALgADCgYJBgAAAA==.落乄諃:BAAALgADCgEJAQAAAA==.',
['落部']='落部铁钢:BAAALgADCgEJAQAAAA==.',
['葛格']='葛格:BAAALgAECgEJAgAAAA==.',
['蒙牛']='蒙牛寿司:BAAALgAECgYJBwAAAA==.',
['蒜头']='蒜头葱:BAAALgAECgEJAQAAAA==.',
['蓝月']='蓝月幽冰:BAAALgAECgEJAQAAAA==.',
['蓝烟']='蓝烟如梦:BAAALgAECgcJCAAAAA==.',
['薛定']='薛定谔熊猫:BAAALgAFFAIJAgAAAA==.',
['虚妄']='虚妄之光:BAAALgAECgEJAQAAAA==.',
['蜀山']='蜀山:BAAALgAECgEJAQAAAA==.蜀山传:BAAALgAFFAIJAwAAAA==.',
['蟛蜞']='蟛蜞:BAAALgAECgYJCAAAAA==.',
['血先']='血先生:BAAALgAECgcJEwAAAA==.',
['血杀']='血杀神殿:BAABLgAECn8bAAIlAAgJ/BNVBgCpAQAlAAgJ/BNVBgCpAQAAAA==.',
['血糕']='血糕:BAAALgAFFAIJAwAAAA==.',
['街溜']='街溜子:BAAALgAFFAIJAgAAAA==.',
['袜子']='袜子有毒:BAAALgAECgYJDAAAAA==.',
['裁决']='裁决神器:BAAALgAECgUJCAAAAA==.',
['西域']='西域大镖客:BAAALgADCgYJBgAAAA==.西域干尸:BAACLgAFFH8FAAIIAAIJPQ6yQACtAAAIAAIJPQ6yQACtAAAuAAQKfxkAAggABwl3EaGkAI8BAAgABwl3EaGkAI8BAAAA.',
['西行']='西行寺妖梦:BAAALgAFFAEJAgAAAA==.',
['要抱']='要抱抱要亲亲:BAAALgADCgYJBgAAAA==.',
['观星']='观星:BAAALgAECgEJAQAAAA==.',
['請勿']='請勿喂食:BAAALgAFFAIJAgABLgAFFAQJDQAMAPMlAA==.',
['诃诃']='诃诃:BAABLgAECn8dAAQNAAcJvxx9BAAAAgANAAcJvxx9BAAAAgAcAAIJ3A3WVABwAAAOAAIJ4BTTbgBrAAABLgAFFAIJAgAKAAAAAA==.',
['误导']='误导开怪:BAAALgAECgEJAQAAAA==.',
['请叫']='请叫我大饼:BAAALgAECgkJCAAAAA==.',
['请问']='请问交互部分:BAAALgAFFAIJBAAAAA==.',
['调频']='调频的喵:BAAALgAECgYJBgAAAA==.',
['豆角']='豆角后:BAAALgADCgEJAQAAAA==.',
['贰月']='贰月弎十:BAAALgAECgEJAQAAAA==.',
['贰柒']='贰柒十:BAAALgAECgcJDQAAAA==.',
['贽殿']='贽殿:BAAALgAFFAEJAQAAAA==.',
['赛博']='赛博义父:BAAALgAFFAIJAwAAAA==.',
['超薄']='超薄亦有距离:BAABLgAFFH8FAAIIAAMJkwjNMQDhAAAIAAMJkwjNMQDhAAAAAA==.',
['越玩']='越玩越无聊:BAAALgAECgQJBwAAAA==.',
['路西']='路西法丶但丁:BAABLgAFFH8FAAImAAMJOheNAQDzAAAmAAMJOheNAQDzAAAAAA==.路西法灬:BAAALgADCgIJAgAAAA==.',
['路边']='路边的落叶:BAAALgAFFAUJBAABLgAFFAYJFAACAJgcAA==.',
['跳起']='跳起来关灯:BAAALgAECgYJBAAAAA==.',
['轻风']='轻风物语:BAAALgAFFAIJAgAAAA==.',
['达尔']='达尔苏斯:BAAALgADCgMJAwAAAA==.',
['过眼']='过眼云烟灬:BAAALgADCgEJAQAAAA==.',
['进击']='进击的小六宝:BAAALgAFFAEJAQAAAA==.',
['连滚']='连滚鼠标流:BAAALgAECgEJAQAAAA==.',
['迟到']='迟到千年丶:BAACLgAFFH8GAAIlAAMJZSBnCwAvAQAlAAMJZSBnCwAvAQAuAAQKfykAAyUACAnCJGYEAFIDACUACAnCJGYEAFIDABgAAQkvBI8eADoAAAAA.',
['迪波']='迪波威:BAAALgAECgEJAQAAAA==.',
['迷你']='迷你咕噜:BAAALgAECgEJAQAAAA==.',
['迷失']='迷失在黑夜里:BAAALgAECgEJAQAAAA==.迷失的晨曦:BAABLgAECn8VAAIDAAYJHxTdawCKAQADAAYJHxTdawCKAQAAAA==.',
['迷惘']='迷惘的她:BAAALgADCgYJBgAAAA==.',
['追雪']='追雪的猫:BAAALgAFFAIJAgAAAA==.',
['适才']='适才相戏尔:BAAALgAECgUJCAAAAA==.',
['那一']='那一指温柔:BAAALgADCgEJAQAAAA==.',
['邪恶']='邪恶飞侠:BAAALgADCgIJAgAAAA==.',
['邪能']='邪能艾璐恩:BAAALgAECgEJAQAAAA==.',
['酷行']='酷行天下:BAAALgADCgEJAQAAAA==.',
['醉饮']='醉饮千殇:BAAALgAECgkJCwABLgAFFAYJBwARAKkQAA==.',
['重生']='重生之古尓丹:BAAALgADCgUJBQAAAA==.',
['釵釵']='釵釵:BAAALgAECgQJBAAAAA==.',
['钢门']='钢门:BAAALgAFFAIJAwAAAA==.钢门居中:BAAALgAECgEJAQAAAA==.',
['锁芯']='锁芯灬绝恋:BAABLgAECn8UAAICAAcJnRXtcACmAQACAAcJnRXtcACmAQAAAA==.',
['错了']='错了:BAAALgAECgQJCAAAAA==.',
['镇魂']='镇魂石:BAAALgAECgYJBwAAAA==.',
['长眉']='长眉呀:BAAALgAECgEJAQAAAA==.',
['闹啥']='闹啥子嘛闹:BAAALgADCgEJAQAAAA==.',
['阿扎']='阿扎西粑粑:BAEALgADCgcJBwABLgAECgMJAwAKAAAAAA==.阿扎里:BAAALgAECgEJAQAAAA==.',
['阿拉']='阿拉卷丶:BAABLgAECn8eAAIOAAcJ3BJYKgCgAQAOAAcJ3BJYKgCgAQAAAA==.',
['阿格']='阿格莱雅:BAAALgAFFAIJAgAAAA==.',
['阿牧']='阿牧的树洞:BAAALgAECgEJAQAAAA==.',
['阿芙']='阿芙特悠:BAABLgAECn8VAAIRAAcJSxleSQAHAgARAAcJSxleSQAHAgAAAA==.',
['阿赫']='阿赫贝奇:BAAALgAECgcJCQAAAA==.',
['阿里']='阿里欧珠鸭:BAAALgAECgEJAQAAAA==.',
['陈一']='陈一发:BAAALgAECgQJBAAAAA==.',
['随冈']='随冈缘丶:BAAALgAECgYJDQAAAA==.',
['随心']='随心所欲丶:BAAALgAFFAIJAgAAAA==.',
['雪夜']='雪夜晴空:BAAALgAECgYJBgAAAA==.',
['雪碧']='雪碧冰箱:BAAALgAECgkJEwAAAA==.',
['雷人']='雷人宝宝:BAABLgAFFH8KAAMFAAUJ/BA0BQCWAQAFAAUJ/BA0BQCWAQAbAAUJ0Q7PBQB8AQABLgAFFAYJEQAFADQeAA==.',
['雷古']='雷古:BAAALgAECgYJCAAAAA==.',
['雷霆']='雷霆暗夜之刃:BAAALgAECgEJAgAAAA==.雷霆神手:BAAALgAECgYJBgAAAA==.雷霆迷男:BAAALgAECgQJBAAAAA==.雷霆风暴图腾:BAAALgAECgMJBAAAAA==.',
['雷风']='雷风暴烈酒:BAABLgAFFH8FAAIhAAMJ5xRAEACaAAAhAAMJ5xRAEACaAAAAAA==.',
['雾隐']='雾隐丶:BAAALgAECgEJAQAAAA==.',
['霜火']='霜火咆哮:BAAALgAECgEJAQAAAA==.',
['霹雳']='霹雳珠:BAAALgAECgkJBAAAAA==.',
['非常']='非常疯:BAAALgAECgUJBgAAAA==.',
['面馆']='面馆:BAAALgAFFAMJAwAAAA==.',
['预防']='预防性查重:BAABLgAFFH8GAAICAAMJch7aDAAmAQACAAMJch7aDAAmAQAAAA==.',
['風夏']='風夏:BAACLgAFFH8IAAMDAAMJpA8EFgDqAAADAAMJ+A4EFgDqAAAEAAEJVQlRFwBQAAAuAAQKfyIAAwQACAk2H+YSALQBAAMABgnbGyxZALwBAAQABQk7HuYSALQBAAAA.',
['风尘']='风尘烈酒:BAAALgAECgkJCQAAAA==.',
['风的']='风的:BAAALgADCgMJAwAAAA==.',
['风紧']='风紧:BAAALgAECgEJAgAAAA==.',
['风行']='风行:BAABLgAECn8XAAMUAAkJYx2MBwAXAwAUAAkJsByMBwAXAwAVAAcJhxUlLwC4AQAAAA==.风行绝刃:BAAALgAECgQJBgAAAA==.',
['飘飘']='飘飘何所似:BAAALgAECgEJAQAAAA==.',
['飙马']='飙马野郎:BAAALgAECgEJAgAAAA==.',
['飞熊']='飞熊与你同在:BAAALgAECgcJEwAAAA==.',
['骑士']='骑士丶诗:BAABLgAECn8aAAIBAAcJ6RqOGwA4AgABAAcJ6RqOGwA4AgAAAA==.',
['骗你']='骗你干嘛:BAEBLgAECn8aAAMYAAcJyCO9AwCFAgAYAAcJBCC9AwCFAgAlAAYJ1SQpFgBcAgAAAA==.',
['骨感']='骨感奶爸:BAAALgAECgEJAQAAAA==.',
['高桥']='高桥李依:BAABLgAECn8fAAIIAAgJWhoqPQCDAgAIAAgJWhoqPQCDAgAAAA==.',
['高级']='高级双料特工:BAAALgADCgEJAQAAAA==.',
['高舒']='高舒:BAAALgADCgMJAwAAAA==.',
['鬼舞']='鬼舞辻怒风:BAAALgAFFAIJBAAAAA==.',
['魅魔']='魅魔尊上:BAAALgAECgYJDQAAAA==.',
['鱼丶']='鱼丶豆腐:BAAALgAECgEJAQAAAA==.',
['鱼香']='鱼香皮皮猪:BAAALgAECgEJAQAAAA==.',
['鲍师']='鲍师傅:BAAALgADCgEJAQAAAA==.',
['鲜血']='鲜血之锤:BAAALgAECgMJAwAAAA==.',
['鹤之']='鹤之影:BAAALgADCgEJAQAAAA==.',
['黄天']='黄天:BAACLgAFFH8MAAIQAAQJyhqXBwBgAQAQAAQJyhqXBwBgAQAuAAQKfxQAAxAACAnkH/wRAJMCABAACAnkH/wRAJMCAA8AAQlKAIysABQAAAAA.',
['黄昏']='黄昏之逝:BAAALgAFFAIJAwAAAA==.',
['黎幽']='黎幽:BAAALgAECgIJAgABLgAFFAQJDQAMAPMlAA==.',
['黑乌']='黑乌龙:BAAALgAFFAIJBAAAAA==.',
['黑夜']='黑夜中的魔:BAAALgAFFAIJAwAAAA==.黑夜伯爵:BAAALgAECgQJBAAAAA==.',
['黑弹']='黑弹之励:BAAALgAFFAEJAgAAAA==.',
['黑手']='黑手出红:BAAALgAECgMJBAAAAA==.',
['黑暗']='黑暗奶毒:BAAALgAECgYJBgAAAA==.黑暗苍穹書:BAAALgADCgUJBwAAAA==.',
['黑色']='黑色眼圈:BAEALgAECgEJAQAAAA==.',
['黯然']='黯然的小杏花:BAAALgAFFAIJAgAAAA==.',
['龍傲']='龍傲天:BAAALgADCgcJCAAAAA==.',
['龍释']='龍释天:BAAALgADCgUJBQAAAA==.',
['龟仙']='龟仙人武天:BAAALgAFFAIJAgAAAA==.',
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
