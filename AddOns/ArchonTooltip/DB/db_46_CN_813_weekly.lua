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

local lookup = {'Warlock-Demonology','Priest-Shadow','Priest-Discipline','Mage-Frost','Monk-Windwalker','Shaman-Elemental','Shaman-Restoration','Warrior-Protection','Paladin-Holy','DeathKnight-Unholy','Warlock-Destruction','Warlock-Affliction','DemonHunter-Devourer','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','Rogue-Subtlety','Evoker-Augmentation','Priest-Holy','Warrior-Fury','Paladin-Retribution','Druid-Balance','Druid-Restoration','Warrior-Arms','Monk-Brewmaster','Paladin-Protection','DemonHunter-Havoc','Monk-Mistweaver',}
local provider = {region='CN',realm='菲拉斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anime:BAAALgAECgkJEAAAAA==.',
As='Asuka:BAAALgAFFAMJAwAAAA==.Asuna:BAABLgAFFH8KAAIBAAQJih6HCwB/AQABAAQJih6HCwB/AQAAAA==.',
Au='Aureole:BAABLgAECn8YAAMCAAkJsiTTAADVAwACAAkJsiTTAADVAwADAAMJ5xKbQACrAAABLgAFFAYJBQACAN0dAA==.Aureolea:BAAALgAECgcJDgABLgAFFAYJBQACAN0dAA==.Aureoleb:BAAALgAFFAMJBAABLgAFFAYJBQACAN0dAA==.Aureolec:BAAALgAECgYJBwAAAA==.Aureoled:BAAALgAFFAQJBAAAAA==.Aureolee:BAAALgAFFAQJBAAAAA==.Aureolef:BAAALgAFFAQJBAAAAA==.',
Av='Avaritia:BAAALgAECgEJAQAAAA==.',
Ba='Badandboujee:BAAALgAECgYJBgAAAA==.Balenciaga:BAAALgAFFAQJBAAAAA==.',
Cl='Clarence:BAAALgADCgYJBgAAAA==.',
Da='Darksign:BAAALgAFFAEJAQAAAA==.',
Dr='Dreamworld:BAAALgAFFAIJAgAAAA==.',
El='Ellen:BAABLgAFFH8IAAIEAAMJWyTnIABAAQAEAAMJWyTnIABAAQAAAA==.',
Er='Eros:BAAALgADCgQJBAAAAA==.',
Fh='Fhajkdwqi:BAAALgAECgQJBAAAAA==.',
Fl='Flyhehe:BAAALgADCgQJBAAAAA==.',
Fu='Fume:BAAALgAECgMJBQAAAA==.',
Ga='Gaara:BAAALgAECgQJBAAAAA==.',
Ha='Hap:BAAALgAECgEJAwAAAA==.',
He='Heh:BAAALgAFFAEJAQAAAA==.',
Hu='Huh:BAABLgAFFH8IAAIEAAQJaw2OLAAEAQAEAAQJaw2OLAAEAQAAAA==.',
Hy='Hypeboy:BAAALgAECgcJBwAAAA==.',
Ia='Iamzheswarm:BAAALgAFFAEJAgAAAA==.',
Li='Lind:BAAALgAECgQJBAAAAA==.Listenheart:BAABLgAFFH8IAAIFAAQJowVeAwAWAQAFAAQJowVeAwAWAQAAAA==.',
Ln='Lnsdru:BAAALgAECgUJBQABLgAFFAQJBgAGAGYSAA==.',
Ls='Lsm:BAACLgAFFH8GAAIGAAQJZhIbCgBBAQAGAAQJZhIbCgBBAQAuAAQKfxkAAwYACQkuHhEQAKkCAAYACAl+HxEQAKkCAAcAAwk4FjJuANYAAAAA.',
Me='Megatrons:BAABLgAFFH8FAAIIAAMJDRR3BADmAAAIAAMJDRR3BADmAAAAAA==.',
Ne='Negan:BAAALgAECgQJBAAAAA==.',
Ni='Niebelungen:BAAALgAECgcJBwABLgAFFAMJBwAJAB4OAA==.',
No='Nothingtosay:BAAALgADCgUJBQAAAA==.',
Ph='Phantom:BAAALgAECgIJAwAAAA==.',
Pi='Pitt:BAABLgAFFH8FAAIKAAMJZxt4DgAWAQAKAAMJZxt4DgAWAQAAAA==.Pittpal:BAAALgAECgUJBQAAAA==.',
Po='Poolcooker:BAAALgAECgcJDAAAAA==.',
Re='Reale:BAABLgAFFH8GAAIBAAYJZhKnAQAnAgABAAYJZhKnAQAnAgAAAA==.',
Ro='Rockurbed:BAAALgAECgYJCAAAAA==.',
Sh='Shadowking:BAAALgAECgQJBQAAAA==.',
Sn='Snavs:BAAALgAECgUJBgAAAA==.',
So='Soberdeity:BAAALgAECgYJBwAAAA==.',
St='Starbright:BAAALgADCgUJBQAAAA==.',
Su='Sunmanlyl:BAAALgAECgUJBQAAAA==.',
Sw='Sweetdaddy:BAAALgAECgEJAQAAAA==.',
Sy='Sylvana:BAAALgAECgEJAQAAAA==.',
Te='Tethys:BAAALgAFFAEJAQAAAA==.',
Tw='Twoth:BAAALgAECggJBgAAAA==.',
Tx='Txait:BAACLgAFFH8GAAMBAAMJ9Q7/IQCiAAABAAIJSQn/IQCiAAALAAEJTRrQEQBbAAAuAAQKfx4ABAsABwmTHWAGAGkCAAsABwlJHWAGAGkCAAEAAwkeFkjEANAAAAwAAQlHIaQlAFsAAAAA.',
Ul='Ulir:BAAALgAECgUJCgAAAA==.',
Zu='Zubba:BAAALgAECgQJCAAAAA==.',
['一万']='一万个熊熊:BAAALgAECgYJBwAAAA==.一万个眼棱:BAABLgAFFH8FAAINAAUJLgbUDQBhAQANAAUJLgbUDQBhAQAAAA==.',
['一个']='一个人的信仰:BAAALgADCgEJAQAAAA==.一个字丶硬:BAABLgAFFH8IAAIKAAMJfQYdFwDgAAAKAAMJfQYdFwDgAAAAAA==.',
['一半']='一半梦醒:BAAALgAECgcJDgAAAA==.',
['一古']='一古又:BAAALgAECgEJAQAAAA==.',
['一小']='一小可爱一:BAAALgAFFAIJAgAAAA==.',
['一帘']='一帘风月闲:BAAALgAFFAEJAQAAAA==.',
['一束']='一束阳光丶:BAAALgAECgEJAQAAAA==.',
['七姑']='七姑妈:BAABLgAFFH8GAAIHAAQJCxjzBgBWAQAHAAQJCxjzBgBWAQAAAA==.',
['万一']='万一一:BAAALgAECgYJBgABLgAFFAUJEAAKAEgRAA==.',
['上帝']='上帝保佑丶:BAAALgADCgQJBAAAAA==.',
['不会']='不会喵的猫:BAAALgAECgcJDgAAAA==.',
['不物']='不物于物:BAACLgAFFH8OAAMOAAUJohvkCQB6AQAOAAUJXxHkCQB6AQAPAAMJHRyZDQDTAAAuAAQKfyIAAw4ACQlbISwFAEsDAA4ACQldICwFAEsDAA8ABQlSIcURAJIBAAAA.',
['不甩']='不甩糖丶:BAAALgAECgUJBQAAAA==.',
['丨丶']='丨丶冲丶丨:BAAALgAECgYJBgAAAA==.',
['丨卿']='丨卿本佳人丨:BAAALgAECgIJAgABLgADCgQJBAAQAAAAAA==.',
['丨沐']='丨沐瞳:BAAALgAECgEJAgABLgAECgUJBwAQAAAAAA==.',
['丨筱']='丨筱崤丨:BAAALgAFFAIJAQAAAA==.',
['丶糖']='丶糖不甩:BAAALgADCgEJAQAAAA==.',
['丶莫']='丶莫非:BAAALgAECgYJDAAAAA==.',
['么么']='么么啪丶:BAAALgAECgcJEwAAAA==.么么喜羊羊:BAAALgADCgUJBQAAAA==.',
['乐多']='乐多丶:BAAALgAECgIJAgAAAA==.',
['乐旖']='乐旖:BAAALgADCgcJDgAAAA==.',
['乖乖']='乖乖小熊熊:BAAALgADCgEJAQAAAA==.',
['二吖']='二吖:BAAALgADCgEJAQAAAA==.',
['云小']='云小白:BAAALgADCgEJAQAAAA==.',
['云海']='云海漫步:BAAALgAECgQJBgAAAA==.',
['云深']='云深缘浅:BAAALgAECgQJCAAAAA==.',
['云锁']='云锁雾:BAAALgADCgYJBQAAAA==.',
['亘古']='亘古剑舞:BAACLgAFFH8LAAIRAAQJWBPMCABgAQARAAQJWBPMCABgAQAuAAQKfxwAAhEACAkiHSwRAJgCABEACAkiHSwRAJgCAAAA.',
['亚巴']='亚巴顿:BAAALgAECgQJBAAAAA==.',
['人为']='人为财死:BAAALgAECgEJAgAAAA==.',
['亽纚']='亽纚鬗亽:BAAALgADCgUJBQAAAA==.',
['他化']='他化自在:BAAALgAECgYJEAAAAA==.',
['以荡']='以荡之名:BAAALgADCgEJAQAAAA==.',
['伊碧']='伊碧嘉思妮:BAAALgAFFAEJAQAAAA==.',
['伊秒']='伊秒:BAAALgAECgIJAwAAAA==.',
['伊色']='伊色啦:BAABLgAFFH8FAAISAAMJ0gvLFADLAAASAAMJ0gvLFADLAAAAAA==.',
['伍仟']='伍仟个达拉念:BAAALgADCgUJBQAAAA==.',
['你好']='你好粗卢先生:BAAALgAECgEJAQAAAA==.你好紧张女士:BAAALgAECgYJBgAAAA==.',
['倪莫']='倪莫管:BAAALgAECgUJBQAAAA==.',
['假装']='假装雅丫:BAAALgAECgYJBgAAAA==.',
['傲娇']='傲娇丶双马尾:BAAALgAECgYJCwAAAA==.',
['僧丶']='僧丶:BAAALgAECgQJBAAAAA==.',
['入訫']='入訫丶:BAAALgADCgEJAQAAAA==.',
['八级']='八级丨小狂风:BAAALgAECgUJBgAAAA==.',
['兰提']='兰提雅西:BAAALgAFFAEJAQAAAA==.',
['兰瑟']='兰瑟:BAAALgAECgEJAQAAAA==.',
['其死']='其死若休:BAAALgADCgEJAQAAAA==.',
['再爱']='再爱丶还是伤:BAABLgAFFH8FAAMTAAMJhAldCACDAAATAAIJGw5dCACDAAACAAEJUgDtFwA1AAAAAA==.',
['冥月']='冥月恶魔:BAAALgAFFAIJAgAAAA==.',
['冬枣']='冬枣的巴黎:BAAALgAECgcJDgAAAA==.',
['冰封']='冰封的渊神:BAAALgAECgYJDwAAAA==.',
['冰糖']='冰糖雪梨蛋糕:BAAALgAECgYJDQAAAA==.',
['冰镇']='冰镇萌牛奶:BAAALgAECgEJAQAAAA==.',
['冷暖']='冷暖偶自知:BAAALgAECgMJAwAAAA==.',
['冷风']='冷风凋零:BAAALgAECgQJBAAAAA==.',
['凌雲']='凌雲:BAAALgAFFAIJBAAAAA==.',
['凤凰']='凤凰火雨:BAAALgAECgQJBAAAAA==.',
['别愁']='别愁眉苦脸:BAAALgADCgEJAQAAAA==.',
['刮骨']='刮骨刀夏禾:BAAALgAECgQJBAAAAA==.',
['刺骨']='刺骨贼:BAABLgAFFH8FAAIRAAMJZBcVEQDAAAARAAMJZBcVEQDAAAABLgAFFAQJCgAPALYhAA==.',
['剑指']='剑指苍兲:BAAALgAFFAIJAwAAAA==.',
['加油']='加油快跑呀:BAAALgAECgYJCgAAAA==.',
['勺木']='勺木头:BAAALgADCgEJAQAAAA==.',
['北地']='北地之灾:BAAALgAECgQJBAAAAA==.',
['十三']='十三燃:BAAALgAECgUJBQAAAA==.',
['十四']='十四的猫:BAAALgADCgYJBgAAAA==.',
['千本']='千本樱丶:BAAALgAECgYJCAAAAA==.',
['单吊']='单吊:BAABLgAFFH8IAAMIAAMJ/xhCBADtAAAIAAMJ/xhCBADtAAAUAAEJoAWFJABLAAAAAA==.',
['占戈']='占戈丶:BAAALgAECgYJBgAAAA==.',
['卡得']='卡得家:BAABLgAECn8VAAIEAAYJyiBRZAAQAgAEAAYJyiBRZAAQAgAAAA==.',
['卡格']='卡格拉茲:BAAALgAFFAIJAgAAAA==.',
['卡面']='卡面来打:BAAALgADCgcJDQAAAA==.',
['卷之']='卷之德:BAAALgAECgYJBgAAAA==.',
['厄丶']='厄丶长苏:BAAALgAECgMJBQAAAA==.',
['双魂']='双魂直男:BAAALgAECgYJBwAAAA==.',
['发疯']='发疯:BAAALgAECgMJAwAAAA==.',
['受够']='受够了等待:BAAALgADCgEJAQAAAA==.',
['口踏']='口踏蒜:BAAALgAECgQJCAAAAA==.',
['古木']='古木逢春丶:BAAALgADCgMJAwAAAA==.',
['可樂']='可樂加點冰:BAAALgADCgYJBgAAAA==.',
['可爱']='可爱小僧:BAAALgADCgcJBwAAAA==.',
['向后']='向后跳:BAAALgAFFAQJAwAAAA==.',
['听法']='听法叁:BAAALgADCgcJBwAAAA==.听法壹:BAAALgAECgYJBgAAAA==.听法肆:BAAALgAECgYJBgAAAA==.听法贰:BAAALgAECgYJBgAAAA==.',
['吾好']='吾好梦中鲨人:BAAALgAECgQJBAAAAA==.',
['咕咕']='咕咕酱:BAAALgAECgQJBAAAAA==.',
['咕德']='咕德猫柠:BAABLgAECn8gAAIKAAkJCxzDDwAfAwAKAAkJCxzDDwAfAwAAAA==.',
['咪咕']='咪咕笨笨:BAAALgAECgUJBQAAAA==.',
['咿呀']='咿呀咿呀哟:BAAALgAECgcJAgAAAA==.',
['哀木']='哀木啼波波:BAAALgAECgIJAgAAAA==.',
['哈基']='哈基羊咩咩:BAAALgAECgYJBgAAAA==.',
['哈库']='哈库邋玛塔塔:BAAALgAECgUJBQAAAA==.',
['哟不']='哟不错哦:BAAALgAECgEJAQAAAA==.',
['哪吒']='哪吒闹海:BAABLgAFFH8FAAIKAAMJEAuSIACgAAAKAAMJEAuSIACgAAAAAA==.',
['哪都']='哪都通冯宝宝:BAAALgADCgYJBgAAAA==.',
['喲豁']='喲豁灬:BAAALgAECgYJBgAAAA==.',
['喵喵']='喵喵小猫子:BAAALgAECgEJAQAAAA==.',
['嗚喵']='嗚喵王之怒:BAAALgAECgUJBQAAAA==.',
['嗜睡']='嗜睡流年:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血灵魂:BAAALgAECgUJCgAAAA==.嗜血的导演:BAAALgAFFAQJAgAAAA==.',
['嘎里']='嘎里给给:BAAALgAECgUJCQAAAA==.',
['嘿丶']='嘿丶小浣熊:BAAALgAECgYJCwAAAA==.',
['四喜']='四喜小丸子:BAAALgADCgMJAwAAAA==.',
['四妹']='四妹:BAAALgAECgUJBQAAAA==.',
['国一']='国一坦:BAAALgAECgEJAQAAAA==.',
['圆滚']='圆滚滚:BAAALgADCgEJAQAAAA==.',
['坤派']='坤派卡皮巴拉:BAAALgAECgkJAQAAAA==.坤派掌教:BAAALgAECgkJAQAAAA==.',
['埃可']='埃可肆:BAAALgAECgUJCAAAAA==.',
['埃吉']='埃吉尔:BAAALgADCgQJBAAAAA==.',
['堕落']='堕落红烧牛排:BAAALgAECgUJCgAAAA==.',
['墩墩']='墩墩:BAAALgAECgIJAgAAAA==.',
['夜幕']='夜幕的疯狂:BAAALgAECgQJBQAAAA==.',
['夢幻']='夢幻丶萱萱:BAAALgADCgYJBgAAAA==.',
['大哥']='大哥非常快:BAAALgAFFAQJAwAAAA==.',
['大猫']='大猫头:BAAALgADCgEJAQAAAA==.',
['大萌']='大萌德思密达:BAAALgAECgEJAQAAAA==.',
['天命']='天命人:BAAALgAECgEJAQAAAA==.',
['天涯']='天涯路远:BAAALgAECgEJAgAAAA==.',
['失去']='失去平衡的德:BAAALgAECgYJBwAAAA==.',
['夺晶']='夺晶霹雳雷瑟:BAAALgAECgIJAgABLgAECgYJBAAQAAAAAA==.',
['奈奈']='奈奈德:BAAALgAECgUJBgAAAA==.',
['奔跑']='奔跑的鸡骨头:BAAALgAECgUJCQAAAA==.',
['奶油']='奶油红豆泥:BAAALgAECgYJDAAAAA==.',
['奶茶']='奶茶可以续命:BAAALgAECgQJBAAAAA==.',
['奶萨']='奶萨:BAABLgAFFH8FAAMCAAMJkhQUDgC2AAACAAIJUhkUDgC2AAADAAEJ9xFcDgBTAAAAAA==.',
['妖孽']='妖孽看锤:BAAALgAECgIJAgAAAA==.',
['妖精']='妖精的祝福:BAAALgAECgUJBQAAAA==.',
['娜拉']='娜拉贝尔:BAAALgAECgYJBgAAAA==.',
['宅叔']='宅叔:BAAALgAECgQJBAAAAA==.',
['安娜']='安娜波利斯:BAAALgAECgYJCAAAAA==.',
['宝哥']='宝哥的右手:BAAALgAECgEJAQAAAA==.',
['家有']='家有肥猫:BAAALgADCgUJBQAAAA==.',
['对面']='对面辣个鹌鹑:BAAALgAECgIJAgAAAA==.',
['尊者']='尊者:BAAALgADCgEJAQAAAA==.',
['小妹']='小妹妹留步:BAAALgADCgEJAQAAAA==.',
['小娘']='小娘子别走:BAAALgADCgUJCQAAAA==.',
['小明']='小明老是痒:BAAALgADCgYJBgAAAA==.',
['小猪']='小猪在饿:BAAALgADCgEJAQAAAA==.',
['小脑']='小脑虎:BAAALgAECgQJCwAAAA==.',
['小芡']='小芡:BAAALgAECgcJDAAAAA==.',
['小醉']='小醉猫猫:BAAALgAECgYJCwAAAA==.',
['小锅']='小锅饵丝:BAAALgAECgkJCQAAAA==.',
['岑胖']='岑胖胖:BAAALgAFFAIJAgAAAA==.',
['岛田']='岛田丶源氏:BAAALgADCgYJBgAAAA==.',
['崔希']='崔希丝风行者:BAAALgAECgQJBwAAAA==.',
['希瓦']='希瓦尔娜斯:BAAALgADCgQJBAAAAA==.',
['年迈']='年迈的老射手:BAABLgAFFH8MAAIOAAYJHBrVAgAoAgAOAAYJHBrVAgAoAgAAAA==.',
['幸运']='幸运的小软:BAAALgAFFAIJBAAAAA==.',
['幻想']='幻想随风:BAAALgAECgQJBAAAAA==.',
['幼稚']='幼稚丶武装:BAAALgAECgQJBwAAAA==.',
['康奎']='康奎斯特:BAABLgAECn8WAAIUAAgJdhdLIABPAgAUAAgJdhdLIABPAgAAAA==.',
['往事']='往事不可追:BAAALgADCgcJBwAAAA==.',
['德伊']='德伊忘形:BAAALgAECgEJAgAAAA==.',
['德彪']='德彪丶:BAAALgADCgUJBQAAAA==.',
['德锅']='德锅锅:BAAALgADCgUJBQAAAA==.',
['德飯']='德飯飯:BAAALgAECgQJDAAAAA==.',
['心灵']='心灵岁:BAAALgAECgIJAQAAAA==.心灵往:BAAALgAECgYJBgAAAA==.心灵昔:BAAALgAECgcJAQAAAA==.心灵秋:BAAALgAECgEJAQAAAA==.',
['忘川']='忘川:BAAALgAECgQJBAAAAA==.',
['念夕']='念夕空:BAAALgADCgUJBQAAAA==.',
['念念']='念念不忘:BAAALgAECgcJCwAAAA==.',
['忻忻']='忻忻:BAAALgAECgEJAQAAAA==.',
['悲鸣']='悲鸣屿行冥丶:BAABLgAFFH8HAAINAAMJAgpxHwDcAAANAAMJAgpxHwDcAAAAAA==.',
['情丝']='情丝吐尽:BAAALgAECgUJCwAAAA==.',
['愛火']='愛火飛揚:BAAALgAFFAEJAQAAAA==.',
['愤怒']='愤怒的橙子:BAABLgAFFH8GAAIBAAMJ+wcaKADYAAABAAMJ+wcaKADYAAAAAA==.',
['我叫']='我叫走走:BAAALgAECgYJDgAAAA==.',
['我可']='我可以需求吗:BAACLgAFFH8fAAIVAAkJ3yIQAABDAwAVAAkJ3yIQAABDAwAuAAQKfxsAAhUACQksJv4AAN0DABUACQksJv4AAN0DAAAA.',
['我回']='我回来看下:BAAALgADCgEJAQAAAA==.',
['我妻']='我妻善逸丶:BAABLgAFFH8FAAIEAAMJux+pIgAwAQAEAAMJux+pIgAwAQAAAA==.',
['我是']='我是你的奶妈:BAAALgAECgUJBQAAAA==.我是元郎龟哥:BAAALgADCgEJAQAAAA==.我是文臣:BAABLgAECn8cAAIKAAgJQhczSAAbAgAKAAgJQhczSAAbAgAAAA==.',
['我有']='我有我的滋味:BAAALgAECggJEgAAAA==.',
['戴维']='戴维斯:BAAALgAECgEJAgAAAA==.',
['扎西']='扎西德勒:BAAALgAECgYJDQAAAA==.',
['托尼']='托尼带水丶:BAAALgAECgMJAwAAAA==.',
['拜仁']='拜仁:BAAALgAECgkJBgABLgAFFAcJHAAEAKwbAA==.',
['掐指']='掐指算命:BAAALgADCgQJBAAAAA==.掐指算病:BAAALgADCgUJBQABLgADCgYJBgAQAAAAAA==.',
['摇摇']='摇摇虎丶:BAAALgAFFAMJBAAAAA==.',
['敌法']='敌法爱你哟:BAAALgAECgEJAQAAAA==.',
['敏锐']='敏锐的导演:BAAALgADCgYJBwAAAA==.',
['斧头']='斧头二十连斩:BAAALgADCgIJAgAAAA==.',
['无敌']='无敌胖熊猫:BAAALgAECgYJCgAAAA==.无敌胖胖德:BAABLgAECn8XAAMWAAcJ3xfTIQDuAQAWAAcJ3xfTIQDuAQAXAAEJVwNo5AAhAAAAAA==.',
['无虑']='无虑:BAABLgAFFH8IAAMUAAMJJhtsBQAlAQAUAAMJJhtsBQAlAQAYAAEJZBswCQBgAAAAAA==.',
['无限']='无限幻想:BAAALgADCgEJAQAAAA==.',
['明月']='明月霜霜:BAABLgAFFH8FAAIZAAMJ9RL3EQDsAAAZAAMJ9RL3EQDsAAAAAA==.',
['晓彟']='晓彟彟:BAAALgAECgYJBwAAAA==.',
['晚风']='晚风微雨丶:BAAALgAECgkJDQABLgAFFAUJCQATAHomAA==.',
['暗夜']='暗夜的枫:BAAALgAECgcJDgAAAA==.',
['暗影']='暗影仁慈:BAAALgAECgQJBAAAAA==.',
['暗月']='暗月光:BAAALgADCgEJAQAAAA==.暗月光牧:BAAALgADCgYJBgAAAA==.暗月籁:BAAALgADCgEJAQAAAA==.暗月萨:BAAALgADCgYJBgAAAA==.',
['暗穴']='暗穴烂很:BAAALgAECgUJBQAAAA==.',
['暗雪']='暗雪蓝痕:BAAALgAECgMJAwAAAA==.',
['曾经']='曾经的辉煌:BAAALgAECgYJEAAAAA==.',
['月坠']='月坠圣泉:BAAALgAECgYJDAAAAA==.',
['有点']='有点丿猛:BAAALgAECgQJBAAAAA==.',
['未旦']='未旦:BAACLgAFFH8IAAIFAAMJPg6VCADtAAAFAAMJPg6VCADtAAAuAAQKfx0AAgUACAkuGY4QAHgCAAUACAkuGY4QAHgCAAAA.',
['术大']='术大招疯:BAAALgAECgQJCAAAAA==.',
['机智']='机智小小德:BAAALgADCgcJDgAAAA==.',
['杠上']='杠上花:BAAALgADCgQJBAAAAA==.',
['来一']='来一杯吧:BAAALgADCgIJAgAAAA==.',
['枉凝']='枉凝眉丶:BAAALgADCgcJBwAAAA==.',
['林克']='林克乄:BAAALgAFFAIJAwAAAA==.',
['林间']='林间小鹿:BAAALgAECgUJCAAAAA==.',
['枪炮']='枪炮灬玫瑰:BAAALgAECgMJAwAAAA==.',
['柳如']='柳如烟灬:BAAALgADCgIJAgAAAA==.',
['桐人']='桐人:BAAALgAFFAEJAQAAAA==.',
['梆球']='梆球硬:BAAALgAFFAMJAgAAAA==.',
['梦回']='梦回头:BAAALgAECgEJAQAAAA==.',
['梦魇']='梦魇乄:BAAALgAECgIJAgAAAA==.',
['棒棒']='棒棒虎:BAAALgAFFAEJAQAAAA==.',
['橙橙']='橙橙:BAAALgAFFAIJAgAAAA==.',
['欧洲']='欧洲划水之父:BAAALgAECgkJAgAAAA==.',
['死不']='死不了就发疯:BAAALgAECgYJBgAAAA==.',
['氢氦']='氢氦锂铍硼:BAAALgAECgcJBwAAAA==.',
['水幕']='水幕轻划:BAAALgAECgcJCAAAAA==.',
['水杨']='水杨酸:BAAALgAECgYJBwAAAA==.',
['水镜']='水镜先生:BAAALgAECgcJDgAAAA==.',
['永恒']='永恒丶痛苦:BAABLgAFFH8DAAIBAAIJ5yR8FwDfAAABAAIJ5yR8FwDfAAAAAA==.',
['江宝']='江宝我的儿:BAAALgAECgEJAQAAAA==.',
['污吆']='污吆王:BAAALgAECgQJBAAAAA==.',
['汪汪']='汪汪队:BAAALgAFFAIJAgAAAA==.',
['沐瞳']='沐瞳丶追风:BAAALgAECgUJBwAAAA==.',
['治宝']='治宝治宝丶:BAABLgAFFH8GAAIEAAMJDxZPNQDBAAAEAAMJDxZPNQDBAAAAAA==.',
['法力']='法力残渣:BAAALgADCgEJAQAAAA==.',
['泰山']='泰山儒风:BAAALgAECgQJBAAAAA==.',
['流光']='流光丶主:BAAALgADCgEJAQAAAA==.',
['流年']='流年留念:BAAALgAECgYJCwAAAA==.',
['浅冬']='浅冬十月:BAAALgAECgMJBQAAAA==.',
['浪蹄']='浪蹄子:BAAALgAECgIJAQAAAA==.',
['海啸']='海啸杀戮:BAAALgADCgEJAQAAAA==.',
['海绵']='海绵宝宝:BAAALgAFFAIJAgAAAA==.',
['润霖']='润霖:BAAALgAECgYJBgAAAA==.',
['淬光']='淬光剑:BAABLgAECn8eAAMVAAgJrhokTAD+AQAVAAcJoRwkTAD+AQAaAAgJ+AzvFAB/AQAAAA==.',
['深蓝']='深蓝忧伤:BAAALgAECgcJDAAAAA==.',
['清酒']='清酒微凉:BAAALgAECgQJBAAAAA==.',
['清风']='清风兰雪:BAABLgAFFH8FAAIRAAMJrRb0DAAXAQARAAMJrRb0DAAXAQAAAA==.',
['滚滚']='滚滚爱吃:BAACLgAFFH8HAAIHAAMJ1Ba7CADvAAAHAAMJ1Ba7CADvAAAuAAQKfx0AAgcACAmzF+QmAPcBAAcACAmzF+QmAPcBAAAA.',
['满月']='满月茅台:BAABLgAECn8eAAMFAAgJlBpPFABLAgAFAAgJghdPFABLAgAZAAEJbBf6gABGAAAAAA==.满月詠衡:BAACLgAFFH8SAAIBAAUJeh1XBQDJAQABAAUJeh1XBQDJAQAuAAQKfx4AAwEACQlMImgFAGUDAAEACQlMImgFAGUDAAsAAQkAAHBnAEEAAAEuAAUUBwkHAAsATR4A.满月飘雪:BAACLgAFFH8IAAIEAAMJUxd8JwAVAQAEAAMJUxd8JwAVAQAuAAQKfxcAAgQABwkUHm9RAEMCAAQABwkUHm9RAEMCAAAA.',
['火力']='火力朝我来:BAAALgADCgcJBwAAAA==.',
['灬阿']='灬阿败灬:BAAALgAECgkJCQAAAA==.',
['灵血']='灵血魔术:BAAALgAECgEJAQAAAA==.',
['炫舞']='炫舞妖姬:BAAALgAECgIJAgAAAA==.',
['烟雨']='烟雨故人归:BAABLgAECn8YAAMPAAcJMh8pGwBkAgAPAAYJRyApGwBkAgAOAAUJxgrvVgDsAAAAAA==.',
['焕月']='焕月:BAAALgADCgEJAQAAAA==.',
['熊出']='熊出没丶小心:BAAALgAECgUJBQAAAA==.',
['熊大']='熊大丶:BAAALgADCgYJBgAAAA==.',
['熋丷']='熋丷天下:BAAALgADCgcJBwAAAA==.',
['燃烧']='燃烧的板筋丶:BAAALgAECgEJAQAAAA==.',
['爆米']='爆米花:BAABLgAECn8eAAIVAAgJVB37IQCiAgAVAAgJVB37IQCiAgAAAA==.',
['爻卟']='爻卟苛击:BAAALgADCgUJBQAAAA==.',
['牛奶']='牛奶骑士:BAAALgAECgQJBwAAAA==.',
['牛德']='牛德一批:BAAALgAFFAEJAQAAAA==.',
['牛毛']='牛毛:BAAALgAECgMJBAAAAA==.',
['牛脑']='牛脑壳丶拱:BAAALgAECgIJAgAAAA==.',
['犟牛']='犟牛:BAAALgADCgIJBAAAAA==.',
['犬来']='犬来八荒:BAAALgAECgcJBwAAAA==.',
['狂野']='狂野特工:BAAALgAECgEJAQAAAA==.',
['狩猎']='狩猎丶杀戮:BAAALgAECgQJAQAAAA==.',
['玉米']='玉米卷儿:BAAALgAECgcJCAAAAA==.',
['王丶']='王丶昭君:BAAALgADCgYJBgAAAA==.',
['王先']='王先生丶:BAAALgAECgYJBgAAAA==.',
['玛法']='玛法里嗷:BAAALgAECgQJBAAAAA==.',
['瑞士']='瑞士卷:BAABLgAFFH8FAAIPAAIJyQ+8FQCuAAAPAAIJyQ+8FQCuAAAAAA==.',
['番薯']='番薯大王:BAAALgAFFAEJAQAAAA==.',
['疯狂']='疯狂星期五:BAAALgAECgEJAQAAAA==.',
['白日']='白日一夏:BAABLgAECn8UAAQJAAgJNyLVJgDzAQAJAAYJGyPVJgDzAQAVAAIJ5REs/gCYAAAaAAEJFwx2RwAkAAAAAA==.',
['白狼']='白狼猎魔人:BAAALgAECgUJBQAAAA==.',
['白百']='白百合:BAAALgAECgYJBwAAAA==.',
['皮尔']='皮尔丶卡颂:BAAALgAECgIJAwAAAA==.',
['瞬间']='瞬间丶冰封:BAAALgAECgUJCAAAAA==.',
['知名']='知名不具:BAABLgAFFH8GAAIEAAYJ8x+vAAALAgAEAAYJ8x+vAAALAgAAAA==.',
['破坏']='破坏之王阿乐:BAABLgAECn8bAAIKAAgJYBNaVgDuAQAKAAgJYBNaVgDuAQAAAA==.',
['祖尔']='祖尔克里夫多:BAAALgAECgQJBAAAAA==.',
['神圣']='神圣之影:BAAALgAECgYJDwAAAA==.神圣的叉烧:BAAALgAECgQJBQAAAA==.',
['秦兰']='秦兰德丶血蹄:BAAALgAECgEJAQAAAA==.',
['笑看']='笑看风耘:BAAALgAECgYJBgAAAA==.',
['笨蛋']='笨蛋奶妈:BAAALgAECgcJDgAAAA==.',
['算嘞']='算嘞吧:BAAALgAECgYJCAAAAA==.',
['粉罗']='粉罗刹:BAAALgADCgQJBAAAAA==.',
['糊涂']='糊涂老黑:BAAALgAECgUJBQAAAA==.',
['索蘭']='索蘭:BAAALgAFFAEJAQAAAA==.',
['紫萱']='紫萱膤见:BAAALgAECgEJAQAAAA==.',
['緣訜']='緣訜兲鉒顁:BAAALgAECgkJCQAAAA==.',
['终末']='终末之冬:BAAALgAECgEJAQAAAA==.',
['绛砂']='绛砂:BAAALgAECgEJAgAAAA==.',
['绝望']='绝望的丈夫:BAAALgAECgMJAwAAAA==.',
['维迦']='维迦:BAAALgAECgEJAQAAAA==.',
['罗伯']='罗伯特基里曼:BAAALgAECggJCgAAAA==.',
['老乱']='老乱的冬枣:BAAALgAECgEJAQAAAA==.',
['老子']='老子很寂寞:BAAALgAECgcJCAAAAA==.',
['老灬']='老灬逗:BAAALgADCgkJCgAAAA==.',
['耶路']='耶路撒冷:BAAALgAECgIJAgAAAA==.',
['聆听']='聆听丿守护:BAAALgAECgYJBgAAAA==.聆听丿疾风:BAAALgAECgUJBQABLgAFFAYJBAAQAAAAAA==.',
['联盟']='联盟第二骑士:BAAALgAECgcJDwAAAA==.',
['聖灮']='聖灮忽悠着你:BAAALgAECgcJCwAAAA==.',
['肉松']='肉松甜奶吐司:BAAALgAECgUJBQAAAA==.',
['自然']='自然丶沙拉曼:BAAALgADCgEJAQAAAA==.自然的召唤:BAAALgADCgQJBAAAAA==.',
['般丶']='般丶若:BAAALgADCgYJBgAAAA==.',
['艺江']='艺江南:BAAALgAECgIJAgAAAA==.',
['芒果']='芒果啵啵:BAACLgAFFH8RAAIEAAYJjxO4BgDzAQAEAAYJjxO4BgDzAQAuAAQKfx0AAgQACQmjIM0IAIADAAQACQmjIM0IAIADAAAA.',
['芦荟']='芦荟膏:BAAALgAECgEJAQAAAA==.',
['花想']='花想容:BAAALgAECgQJBAABLgAFFAEJAQAQAAAAAA==.',
['花椒']='花椒辣椒:BAAALgADCgYJBgAAAA==.',
['花落']='花落丶叶相随:BAAALgAECgIJAgAAAA==.',
['英勇']='英勇的导演:BAAALgAECgQJBgAAAA==.',
['茉莉']='茉莉烏龍:BAAALgAECgcJBwAAAA==.',
['荷兰']='荷兰豆炒猪嗨:BAAALgAECgUJCQAAAA==.',
['莉娅']='莉娅德琳:BAAALgAECgEJAQAAAA==.',
['莫格']='莫格莱妮:BAAALgAECgQJBQAAAA==.',
['莱万']='莱万多夫斯基:BAAALgAECgkJDwAAAA==.',
['菊又']='菊又惊:BAAALgAECgIJAgAAAA==.',
['菜鸟']='菜鸟飞:BAAALgADCgEJAQAAAA==.',
['菲姬']='菲姬:BAAALgAFFAEJAQAAAA==.',
['萌萌']='萌萌哒巨人:BAAALgAECgEJAgAAAA==.萌萌哒波比:BAAALgAFFAEJAQAAAA==.',
['萨爷']='萨爷:BAAALgAFFAIJAgAAAA==.',
['萨莱']='萨莱因:BAAALgAECgEJAgAAAA==.',
['董萱']='董萱儿:BAAALgAECgMJAwAAAA==.',
['蒂誒']='蒂誒哧主理人:BAAALgAECgIJAgAAAA==.',
['蓝梅']='蓝梅甜奶起司:BAAALgAECgUJBQAAAA==.',
['蠡百']='蠡百万:BAAALgAECgEJAQAAAA==.',
['血色']='血色龙骑:BAAALgAECggJDQAAAA==.',
['血花']='血花霸霸:BAAALgAECgMJAgAAAA==.',
['诚实']='诚实的阿凡达:BAAALgAECgEJAQAAAA==.',
['诺兰']='诺兰:BAAALgAECgMJAwAAAA==.',
['谁丶']='谁丶乱了流年:BAAALgAECgEJAQAAAA==.',
['贝尔']='贝尔哈多:BAAALgAFFAIJAwAAAA==.',
['足浴']='足浴技师:BAAALgAECgQJBAAAAA==.',
['蹦沙']='蹦沙卡啦卡:BAAALgAECgQJBgAAAA==.',
['蹦蹦']='蹦蹦大红手:BAAALgADCgMJAwAAAA==.蹦蹦本蹦:BAAALgADCgMJAwAAAA==.蹦蹦的熊布朗:BAAALgADCgcJAQAAAA==.蹦蹦的铁盾:BAAALgAECgYJCQAAAA==.',
['辛达']='辛达苟萨之息:BAAALgAECgEJAQAAAA==.',
['还是']='还是要发疯:BAAALgAECgMJBQAAAA==.',
['逐火']='逐火之蛾:BAABLgAECn8dAAIOAAgJKxO8KADhAQAOAAgJKxO8KADhAQAAAA==.',
['邪能']='邪能热带鱼:BAABLgAECn8WAAIbAAYJyRkBIAC9AQAbAAYJyRkBIAC9AQAAAA==.',
['酱瓜']='酱瓜沙拉:BAAALgAECgIJAgAAAA==.',
['酸甜']='酸甜柠檬:BAAALgAECgEJAQAAAA==.酸甜柠檬茶:BAAALgAECgEJAQAAAA==.',
['醉陌']='醉陌红尘:BAAALgADCgEJAQAAAA==.',
['采花']='采花丶蜀黍:BAAALgADCgYJBgAAAA==.',
['释雪']='释雪:BAAALgAECgEJAQAAAA==.',
['钢板']='钢板的小弟:BAAALgAECgQJBAAAAA==.',
['锰酸']='锰酸钾:BAAALgADCgEJAQAAAA==.',
['阴暗']='阴暗之牧:BAAALgAECgQJBQAAAA==.',
['阿弥']='阿弥诺斯:BAAALgAECgcJEQAAAA==.',
['阿荼']='阿荼骑士:BAAALgAECgcJBwAAAA==.',
['雅尓']='雅尓貝徳:BAAALgAECgUJBQAAAA==.',
['集合']='集合石:BAABLgAFFH8FAAIBAAUJEAgqCgCMAQABAAUJEAgqCgCMAQAAAA==.',
['雪灬']='雪灬圣光:BAAALgAFFAEJAQAAAA==.',
['雲何']='雲何:BAABLgAFFH8HAAIJAAMJHg7tDwDaAAAJAAMJHg7tDwDaAAAAAA==.',
['雲端']='雲端蘰步:BAAALgAECgEJAgAAAA==.',
['雷霆']='雷霆战将:BAAALgADCgEJAQAAAA==.',
['風止']='風止丶:BAAALgAFFAIJAwAAAA==.',
['风君']='风君侯:BAAALgADCgYJBgAAAA==.',
['风景']='风景圆子:BAAALgAECgcJCwAAAA==.',
['风神']='风神腿:BAAALgAECgQJCAAAAA==.',
['风禾']='风禾尽起:BAAALgAECgkJCQAAAA==.',
['风语']='风语:BAAALgAECgYJBAAAAA==.',
['风零']='风零明溪:BAAALgAECgcJDgAAAA==.',
['飒浪']='飒浪嘿哟:BAAALgAFFAQJBAAAAA==.',
['飒飒']='飒飒萨:BAAALgADCgcJBwAAAA==.',
['飛雪']='飛雪香蓮:BAAALgAECgkJDwABLgAFFAYJBgAIALcGAA==.',
['飯团']='飯团丶:BAAALgAECgMJAwAAAA==.',
['饼干']='饼干妹:BAAALgAECgIJAwAAAA==.',
['馋我']='馋我宁静:BAAALgAFFAEJAQAAAA==.',
['香肠']='香肠饭加香肠:BAAALgAFFAEJAQAAAA==.',
['马上']='马上甲鸟:BAACLgAFFH8UAAIcAAYJqyZPAAC8AgAcAAYJqyZPAAC8AgAuAAQKfxwAAxwACQnKJhMAAAQEABwACQnKJhMAAAQEAAUAAQmaG0hvAFQAAAAA.',
['马司']='马司鹑:BAAALgAFFAEJAQAAAA==.',
['马玲']='马玲:BAAALgAECgMJAwAAAA==.',
['骑个']='骑个锤子士:BAAALgAECgQJBQAAAA==.',
['魂兮']='魂兮來歸:BAAALgAECgUJBQABLgAFFAMJBwAJAB4OAA==.',
['魅渊']='魅渊丶:BAAALgADCgUJBQAAAA==.',
['魅烬']='魅烬丶:BAAALgADCgIJAgAAAA==.',
['魔法']='魔法披風:BAAALgAECgEJAQAAAA==.',
['魚幼']='魚幼薇:BAAALgAECgYJBwAAAA==.',
['鳏寡']='鳏寡孤独:BAAALgAECgEJAwAAAA==.',
['鸡二']='鸡二夹蛋:BAAALgADCgUJBwAAAA==.',
['鹅山']='鹅山丶赵子龙:BAAALgAFFAIJBAAAAA==.',
['黄诗']='黄诗扶:BAABLgAFFH8GAAIBAAMJ2g22IgD5AAABAAMJ2g22IgD5AAAAAA==.',
['黑暗']='黑暗淘淘:BAAALgAECgEJAQAAAA==.',
['黑白']='黑白丶黎明石:BAAALgAECgUJBQAAAA==.',
['默默']='默默无言:BAAALgAECgcJBwAAAA==.',
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
