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

local lookup = {'DemonHunter-Havoc','DemonHunter-Devourer','Paladin-Retribution','Evoker-Augmentation','Mage-Frost','Shaman-Elemental','DeathKnight-Unholy','Unknown-Unknown','Druid-Guardian','Hunter-BeastMastery','Priest-Discipline','Warlock-Destruction','Warlock-Demonology','Mage-Fire','Monk-Windwalker','Warrior-Fury','Warrior-Protection','Warrior-Arms','Paladin-Holy','Priest-Holy','Hunter-Marksmanship','Shaman-Restoration','Hunter-Survival','Monk-Brewmaster','Rogue-Subtlety','DemonHunter-Vengeance','Druid-Restoration','DeathKnight-Blood','Rogue-Assassination',}
local provider = {region='CN',realm='阿尔萨斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aiolia:BAAALgAECgYJCwAAAA==.',
Al='Albert:BAAALgADCgcJBwAAAA==.Alicemo:BAAALgAECgMJBAAAAA==.Alleriaz:BAABLgAECn8VAAMBAAYJfx9MJACbAQACAAYJOh5ESwDHAQABAAYJwhpMJACbAQAAAA==.',
Am='Ambrosia:BAAALgAECgYJBwAAAA==.',
Ao='Aoy:BAAALgADCgQJBwAAAA==.',
Au='Automatac:BAAALgAECgQJBAAAAA==.',
Be='Bemyson:BAAALgADCgcJBwAAAA==.',
Bi='Biankar:BAAALgAECgkJCQAAAA==.',
Bl='Bloodypandas:BAAALgAECgEJAgAAAA==.',
Ch='Chandraha:BAAALgAECgYJCAAAAA==.',
Cr='Creelovo:BAAALgAFFAIJBAAAAA==.',
Cy='Cyrus:BAABLgAFFH8LAAIDAAQJAx7OAgB5AQADAAQJAx7OAgB5AQAAAA==.',
Da='Dav:BAAALgAECgYJDwAAAA==.',
De='Deviljojo:BAABLgAFFH8GAAICAAIJzhXaJQCoAAACAAIJzhXaJQCoAAAAAA==.',
Do='Dohast:BAAALgADCgcJBwABLgAFFAMJBgAEABAXAA==.',
Ed='Edwimy:BAAALgAECgEJAQAAAA==.',
En='Eneiei:BAABLgAFFH8GAAIFAAQJcRcfGgBiAQAFAAQJcRcfGgBiAQABLgAFFAUJDQAFAKgjAA==.',
Ev='Evenstar:BAAALgAECggJDwAAAA==.Evisusy:BAAALgAECgcJDQAAAA==.',
Fi='Firstshoot:BAAALgAECggJCAAAAA==.',
Fr='Frozen:BAAALgAECgcJCwAAAA==.',
Gr='Grangers:BAAALgADCgEJAgAAAA==.',
Ha='Hailmegatron:BAAALgADCgUJBQAAAA==.',
Ho='Hodeer:BAAALgADCgIJAwAAAA==.',
In='Invpaladin:BAABLgAFFH8HAAIDAAMJGxLZFQD8AAADAAMJGxLZFQD8AAAAAA==.',
Ke='Keyen:BAACLgAFFH8JAAICAAMJOSEoFAAxAQACAAMJOSEoFAAxAQAuAAQKfxUAAwIABwmMFhRfAIQBAAIABwl5FRRfAIQBAAEABAmdDmpIANEAAAAA.',
Ko='Konatsu:BAAALgAECgcJEQAAAA==.',
Kr='Kresma:BAAALgAECgkJCQAAAA==.',
Ku='Kumä:BAAALgADCgEJAQAAAA==.',
La='Laois:BAAALgAECgMJAwAAAA==.',
Li='Liomessi:BAAALgAECgMJAwAAAA==.',
Lu='Luckyred:BAAALgAFFAEJAQAAAA==.',
Lv='Lvxfvlminis:BAACLgAFFH8PAAIGAAQJGxxgBwBkAQAGAAQJGxxgBwBkAQAuAAQKfx8AAgYACAl8I2cGAC0DAAYACAl8I2cGAC0DAAAA.',
Ma='Marlcheil:BAAALgAECgYJBgAAAA==.Maximiana:BAAALgAECgEJAQAAAA==.',
Mi='Missje:BAAALgAECgQJBgAAAA==.',
Ml='Mluna:BAAALgAECgYJCAAAAA==.',
Mo='Mogeko:BAAALgAECgYJBgAAAA==.Morenight:BAAALgAECgEJAQAAAA==.',
Mu='Musee:BAAALgAECgYJCAAAAA==.',
Ne='Nescaff:BAAALgAECgEJAQAAAA==.',
Oh='Ohippyo:BAACLgAFFH8NAAICAAMJ4hc1EAD1AAACAAMJ4hc1EAD1AAAuAAQKfxkAAgIACAk8HogcAKcCAAIACAk8HogcAKcCAAAA.',
Ol='Oliveoyl:BAAALgAECgIJAwAAAA==.',
Pa='Palatin:BAAALgAECgcJCwAAAA==.',
Pi='Pigeonc:BAAALgAECgkJBAAAAA==.Pisika:BAAALgAECgYJCgAAAA==.',
Qi='Qiahi:BAAALgAECgQJBAAAAA==.',
Ra='Ravent:BAABLgAFFH8JAAIHAAQJXiDqAgCFAQAHAAQJXiDqAgCFAQAAAA==.',
Rh='Rhaegal:BAAALgAECgUJBgAAAA==.',
['Rë']='Rëvenant:BAAALgADCgcJDQAAAA==.',
Sa='Sadism:BAAALgAECgcJAgAAAA==.Sanctuary:BAAALgADCgYJBgABLgAECgYJBgAIAAAAAA==.',
Sh='Sheeta:BAAALgAECgEJAQAAAA==.',
Sk='Sky:BAAALgAECgEJAQAAAA==.',
Sn='Snorlax:BAAALgAECgYJDgABLgAFFAgJGAAJAFobAA==.',
Su='Sumetal:BAAALgAECgUJBQAAAA==.',
Sy='Symm:BAAALgAFFAMJAwAAAA==.',
Ta='Tabernacle:BAAALgAECgQJDAAAAA==.Tacoo:BAAALgADCgEJAQAAAA==.Tasaa:BAAALgAFFAEJAQABLgAFFAQJCwAHAJsLAA==.',
To='To:BAAALgAFFAIJBAAAAA==.Tokisama:BAAALgAECgYJCAAAAA==.',
Ui='Uitraman:BAAALgAECgEJAQAAAA==.',
Va='Vandalize:BAAALgAECgcJBwAAAA==.',
Ve='Veendetta:BAAALgAECgMJAwAAAA==.',
Vi='Violetgen:BAAALgAECgYJBgAAAA==.',
Wa='Waicy:BAAALgADCgIJAgAAAA==.',
We='Weeknd:BAAALgAECgEJAQAAAA==.',
Wi='Wiedergeburt:BAAALgAECgcJDAAAAA==.',
Wo='Wodeweiyi:BAAALgAFFAEJAQAAAA==.',
Xa='Xaryuh:BAAALgAECgIJAgAAAA==.',
Ze='Zedstar:BAAALgAFFAQJBAAAAA==.',
['一世']='一世浮屠:BAAALgAECgQJCAAAAA==.',
['一个']='一个小馒头:BAAALgAECgQJCAAAAA==.',
['一中']='一中易天一:BAAALgADCgUJBQAAAA==.',
['一品']='一品牛:BAAALgAECgcJEwAAAA==.',
['一啸']='一啸动千山:BAAALgAECgUJBQAAAA==.',
['一梦']='一梦:BAACLgAFFH8IAAIFAAMJVh9wIgAyAQAFAAMJVh9wIgAyAQAuAAQKfyAAAgUABwnPHcdUADoCAAUABwnPHcdUADoCAAAA.',
['一箭']='一箭毙命:BAAALgAECgYJBwAAAA==.',
['七夜']='七夜月华:BAAALgAECgUJCQAAAA==.',
['七海']='七海丶千秋:BAAALgAECgYJBgAAAA==.',
['万古']='万古丶皆空:BAAALgAECgEJAQAAAA==.',
['上官']='上官小皮裤:BAABLgAFFH8JAAIKAAQJLBKlBQBJAQAKAAQJLBKlBQBJAQAAAA==.',
['上海']='上海彭于晏:BAAALgAECgcJBwABLgAFFAUJBgAFAPQYAA==.',
['下班']='下班回家:BAAALgAECgQJAwAAAA==.',
['不叮']='不叮白不丁:BAAALgAECgYJDAAAAA==.',
['不科']='不科学电磁炮:BAAALgAECgMJAwAAAA==.',
['世一']='世一上:BAAALgAECgYJBgAAAA==.',
['丝想']='丝想家丶:BAAALgAECgIJAgAAAA==.',
['丢雷']='丢雷卤味嘿:BAAALgAECgQJBAAAAA==.',
['丧彪']='丧彪小公举:BAAALgAECgIJAgAAAA==.',
['丨小']='丨小鸠丨:BAAALgAFFAIJBAAAAA==.',
['丨苏']='丨苏慕辰丨:BAAALgAECgEJAQAAAA==.',
['丫鬟']='丫鬟:BAABLgAFFH8JAAILAAQJsB5LBQCUAQALAAQJsB5LBQCUAQAAAA==.',
['临夜']='临夜吹雪:BAAALgAECgcJDgAAAA==.',
['丶余']='丶余烬丶:BAAALgADCgIJAgAAAA==.',
['丶冰']='丶冰镇奶茶:BAAALgAFFAIJAgAAAA==.',
['丶周']='丶周杰伦灬:BAABLgAFFH8FAAIMAAIJECY9CADlAAAMAAIJECY9CADlAAAAAA==.',
['丶大']='丶大菠萝丶:BAAALgADCgYJBgAAAA==.',
['丶奈']='丶奈奈子:BAAALgAECgYJBgAAAA==.',
['丶念']='丶念无:BAAALgAFFAEJAQAAAA==.',
['举个']='举个栗子丶:BAAALgADCgUJBQAAAA==.',
['丿就']='丿就手:BAAALgAECgUJBgAAAA==.',
['丿爆']='丿爆炸灬奶糖:BAAALgADCgQJBAAAAA==.',
['乂大']='乂大牙乂:BAAALgAECgMJAwAAAA==.',
['乖陆']='乖陆雨萱:BAAALgADCgYJBgAAAA==.',
['乙醇']='乙醇超人:BAAALgAECgcJDwAAAA==.',
['九月']='九月丶:BAAALgAECgcJCAAAAA==.',
['亂红']='亂红莲:BAAALgAFFAIJAgAAAA==.',
['二蛋']='二蛋子:BAACLgAFFH8RAAMNAAUJphgZBQDNAQANAAUJphgZBQDNAQAMAAEJugAzGwA9AAAuAAQKfxsAAg0ACAngIcQOAAMDAA0ACAngIcQOAAMDAAAA.',
['云海']='云海有雾丿勿:BAAALgAFFAEJAQAAAA==.',
['五个']='五个红大汉:BAAALgAECgIJAwAAAA==.',
['五音']='五音不全:BAAALgAFFAEJAQAAAA==.',
['亡亥']='亡亥誓沭:BAABLgAFFH8FAAINAAMJ+wsRIwCdAAANAAMJ+wsRIwCdAAAAAA==.',
['人丶']='人丶狠话丶多:BAAALgAECgkJDgAAAA==.',
['人民']='人民勤务员:BAAALgAECgUJBQAAAA==.',
['什么']='什么是名字:BAABLgAECn8YAAMFAAcJ/BV9hADIAQAFAAcJ/BV9hADIAQAOAAIJgA9VDwA6AAAAAA==.',
['今震']='今震恩:BAAALgAFFAEJAQAAAA==.',
['从此']='从此回归:BAABLgAFFH8FAAIFAAIJnx0aNgC+AAAFAAIJnx0aNgC+AAAAAA==.',
['仲夏']='仲夏夜的星辰:BAAALgADCgEJAQAAAA==.',
['伊丽']='伊丽莎柏:BAAALgAECgEJAwAAAA==.',
['伊林']='伊林希丶嗜血:BAAALgAECgYJCAAAAA==.',
['众神']='众神怒:BAAALgAECgEJAQAAAA==.',
['传说']='传说哥:BAAALgAECgEJAgAAAA==.',
['住手']='住手不要打啦:BAAALgAECgMJAwAAAA==.',
['你个']='你个熊人丶:BAAALgAECgYJCQAAAA==.',
['你算']='你算吵了:BAAALgAECgUJCAAAAA==.',
['佯装']='佯装娇花:BAAALgAECgEJAQAAAA==.',
['倔强']='倔强的少晖:BAAALgAECgEJAgAAAA==.',
['假酒']='假酒害人:BAAALgAECgIJAgAAAA==.',
['僵尸']='僵尸太子:BAAALgADCgEJAgAAAA==.',
['僵硬']='僵硬的瀛风:BAAALgAECgUJBQABLgAFFAQJCwAPAGYaAA==.',
['元气']='元气小少女丶:BAABLgAECn8iAAMNAAkJkR2TAgCgAgANAAkJkR2TAgCgAgAMAAIJKA6eTwB/AAABLgAFFAQJBAAIAAAAAA==.元气胶囊:BAAALgADCgEJAQAAAA==.',
['克蕾']='克蕾儿:BAAALgAECgEJAQAAAA==.',
['兔兔']='兔兔猪:BAAALgAECgMJAwAAAA==.',
['兔子']='兔子上树:BAAALgAECgEJAQAAAA==.',
['八步']='八步街余文乐:BAABLgAECn8WAAMQAAYJ3hYwRACTAQAQAAYJyhYwRACTAQARAAEJxhhjQgBFAAAAAA==.',
['公鸡']='公鸡大鱼怪:BAAALgAECgEJAQAAAA==.',
['六十']='六十壹级:BAAALgADCgEJAQAAAA==.',
['兽奴']='兽奴永不为人:BAAALgAECgUJCQAAAA==.',
['兽的']='兽的一比:BAAALgADCgEJAQAAAA==.',
['冥王']='冥王窝牛:BAAALgAECgMJAwAAAA==.',
['冬之']='冬之物语:BAAALgAECgIJAwAAAA==.',
['冰火']='冰火久崇天:BAAALgAFFAEJAQAAAA==.冰火玖重天:BAAALgADCgcJCwAAAA==.冰火麒麟:BAAALgADCgMJAwAAAA==.',
['冰爽']='冰爽洁面乳:BAAALgADCgYJBgAAAA==.',
['冲锋']='冲锋撂倒斩杀:BAAALgADCgUJBQAAAA==.',
['凌霜']='凌霜傲雪:BAAALgAECgQJDQAAAA==.',
['凡落']='凡落尘:BAAALgAECgEJAQAAAA==.',
['凣凣']='凣凣:BAAALgAECgEJAQAAAA==.',
['刁德']='刁德三:BAAALgADCgEJAQAAAA==.',
['刁的']='刁的一比:BAAALgAECgEJAgAAAA==.',
['初音']='初音未來:BAAALgAECgkJDwAAAA==.',
['别处']='别处来的妖魔:BAABLgAFFH8HAAISAAQJrhq8AQBvAQASAAQJrhq8AQBvAQAAAA==.',
['别放']='别放黑胡椒:BAAALgAECgYJCQAAAA==.',
['北方']='北方的女王:BAAALgADCgQJBAAAAA==.',
['北极']='北极的帝企鹅:BAAALgAECgQJBAAAAA==.',
['千雪']='千雪孤鸣:BAAALgAECgUJCwAAAA==.',
['半妖']='半妖丶犬夜叉:BAAALgAECgQJBAAAAA==.',
['半月']='半月灬斩:BAAALgAFFAIJBAAAAA==.',
['华容']='华容道:BAAALgAECgQJBAAAAA==.',
['华师']='华师傅:BAAALgAFFAIJAgAAAA==.',
['卡卡']='卡卡罗特乄:BAAALgAECgYJBgAAAA==.',
['卿暮']='卿暮云灬:BAAALgAECgYJBgABLgAFFAUJDQAFAKgjAA==.',
['厉害']='厉害的名字:BAAALgAECgYJDQAAAA==.',
['古德']='古德猫宁:BAAALgAECgUJBwAAAA==.',
['右手']='右手不会动:BAAALgAECgIJAwAAAA==.',
['右男']='右男:BAAALgAECgIJAgAAAA==.',
['叶蓁']='叶蓁蓁丶:BAACLgAFFH8KAAITAAMJIiHHCQDCAAATAAMJIiHHCQDCAAAuAAQKfxoAAxMACQnYHmoGAAUDABMACQnYHmoGAAUDAAMAAwmXHty6ABABAAAA.',
['吃我']='吃我闪电箭:BAAALgAECgYJDgAAAA==.',
['吉择']='吉择明步:BAAALgAECgIJAgAAAA==.',
['听说']='听说法爷很牛:BAAALgAECgEJAQAAAA==.',
['吾好']='吾好娣:BAAALgAECgMJAwAAAA==.',
['呆王']='呆王毛:BAAALgAECgcJCAAAAA==.',
['咕咕']='咕咕嘎嘎丿:BAAALgAECgcJAQAAAA==.',
['咖啡']='咖啡丶沃克:BAAALgADCgEJAQAAAA==.咖啡内啡肽:BAAALgAECgYJCgAAAA==.咖啡普利斯:BAAALgADCgEJAQAAAA==.咖啡溶雪:BAAALgAECgYJDAAAAA==.',
['咩了']='咩了个咩:BAAALgADCgYJBwAAAA==.',
['哑巴']='哑巴湖韩天尊:BAAALgAECgEJAQAAAA==.',
['哥么']='哥么绝代:BAAALgADCgEJAQAAAA==.',
['哭泣']='哭泣之美:BAAALgAECgYJCQAAAA==.',
['唧唧']='唧唧复唧唧丨:BAAALgAECgIJAgAAAA==.',
['唯所']='唯所欲为:BAAALgAECgQJAQAAAA==.',
['商参']='商参丶:BAABLgAFFH8MAAIHAAQJERjoCQBBAQAHAAQJERjoCQBBAQAAAA==.',
['啵儿']='啵儿:BAAALgAECgEJAQAAAA==.',
['喜欢']='喜欢这个调调:BAAALgAECgYJBgAAAA==.',
['喝伊']='喝伊利的丹叔:BAAALgAECgQJBAAAAA==.',
['喵喵']='喵喵德:BAAALgAFFAEJAQAAAA==.',
['嗜血']='嗜血起灬:BAAALgAFFAIJAgAAAA==.',
['嘉兴']='嘉兴张德赞:BAAALgAECgUJBQABLgAECgYJBwAIAAAAAA==.嘉兴张战:BAAALgAECgUJBQAAAA==.嘉兴血迪凯:BAAALgAECgUJBgAAAA==.',
['嘟嘟']='嘟嘟噗臭:BAAALgAECgQJCAAAAA==.',
['国士']='国士双双:BAAALgAECgQJBgAAAA==.',
['圗騰']='圗騰:BAABLgAECn8aAAIGAAcJ5yDEEQCVAgAGAAcJ5yDEEQCVAgAAAA==.',
['土兵']='土兵:BAABLgAFFH8OAAIRAAQJERmHAgAzAQARAAQJERmHAgAzAQAAAA==.',
['土屋']='土屋安娜:BAAALgAECgcJEgAAAA==.',
['圣光']='圣光力量:BAAALgAECgcJCwAAAA==.圣光包菜:BAABLgAFFH8HAAITAAMJZiRPCQBAAQATAAMJZiRPCQBAAQAAAA==.圣光在忽悠:BAAALgAFFAIJAgAAAA==.圣光拯救:BAAALgAECgYJDgAAAA==.',
['地狱']='地狱二零零八:BAAALgAFFAIJAwAAAA==.',
['地狼']='地狼之魂:BAAALgADCgEJAQAAAA==.',
['塞娜']='塞娜:BAAALgAECgcJBwAAAA==.',
['复仇']='复仇之子:BAAALgAECgYJBgAAAA==.',
['多喝']='多喝乄开水:BAAALgAECgcJBwAAAA==.',
['夜的']='夜的第七獐:BAAALgADCgIJAgABLgAECgUJBQAIAAAAAA==.',
['夜见']='夜见:BAAALgAECgYJDAAAAA==.',
['夜里']='夜里挑灯看剑:BAAALgAECgMJAwAAAA==.',
['大咕']='大咕噜:BAAALgAECgkJEgAAAA==.',
['大啵']='大啵浪:BAAALgAECgYJCwAAAA==.',
['大神']='大神不轻松:BAAALgAFFAEJAQAAAA==.大神涼子:BAACLgAFFH8KAAIHAAQJhx8TCQCIAQAHAAQJhx8TCQCIAQAuAAQKfxQAAgcABgnTIvVCAC0CAAcABgnTIvVCAC0CAAAA.大神轻松:BAAALgAECgYJDAAAAA==.',
['大绿']='大绿总:BAAALgAECgYJBgAAAA==.',
['大野']='大野猪叔叔:BAAALgAFFAEJAQABLgAECgYJCQAIAAAAAA==.',
['大顺']='大顺火锅:BAAALgAECgYJBgAAAA==.',
['大马']='大马拉小车:BAAALgADCgMJAwAAAA==.',
['大黑']='大黑牛牛:BAAALgAECgMJAwAAAA==.',
['天凉']='天凉丶:BAAALgAECgQJBAAAAA==.',
['天才']='天才小白菜:BAAALgAFFAEJAQAAAA==.',
['天罚']='天罚之之:BAAALgAECgYJCQAAAA==.',
['天蝎']='天蝎小米罗:BAAALgAECgEJAQAAAA==.',
['天风']='天风冰羽:BAAALgAECgcJDAAAAA==.天风心羽:BAAALgAECgQJBgAAAA==.',
['太史']='太史慈:BAABLgAECn8YAAIUAAcJuR8aDQCEAgAUAAcJuR8aDQCEAgAAAA==.',
['夭夭']='夭夭丶:BAAALgADCgQJBAAAAA==.',
['失心']='失心者:BAAALgAFFAEJAQAAAA==.',
['夺命']='夺命核冰枪:BAAALgADCgYJBgAAAA==.',
['奇犽']='奇犽斩:BAAALgAECgQJBwAAAA==.',
['奥丶']='奥丶罗罗西:BAAALgADCgUJBQAAAA==.',
['奥立']='奥立奥:BAAALgAECgEJAQABLgAECgYJBgAIAAAAAA==.',
['奥黛']='奥黛丽赫来:BAAALgAECgMJBAAAAA==.',
['好色']='好色船长:BAAALgAECgUJBwAAAA==.',
['如果']='如果后会无期:BAAALgAECgYJCQAAAA==.',
['妙不']='妙不可言:BAAALgAECgkJDAAAAA==.',
['妞妞']='妞妞小囡囡:BAAALgAECgYJDAAAAA==.',
['姜汁']='姜汁撞奶:BAAALgAECgcJBwAAAA==.',
['嫂子']='嫂子你真棒:BAAALgAECgIJBAAAAA==.',
['嫩魔']='嫩魔猎手:BAAALgAECgMJAwAAAA==.',
['孤独']='孤独才是常态:BAAALgAECgQJBQAAAA==.',
['宁舟']='宁舟巷大队长:BAABLgAFFH8HAAIKAAQJFB83AQCIAQAKAAQJFB83AQCIAQAAAA==.宁舟巷大鸟哥:BAAALgAFFAEJAQAAAA==.',
['宁萌']='宁萌:BAAALgAECgIJAgAAAA==.',
['宁静']='宁静的异人:BAAALgADCgIJAgAAAA==.',
['宝贝']='宝贝莱拉丶:BAAALgAECgEJAgAAAA==.',
['寂寞']='寂寞一风行者:BAACLgAFFH8MAAMKAAQJzhmaCgAEAQAKAAMJYBiaCgAEAQAVAAIJehN4HwCYAAAuAAQKfxQAAhUACAn+HIUZAFsCABUACAn+HIUZAFsCAAAA.',
['寜静']='寜静的夏天:BAAALgAECgIJAwABLgAFFAQJBgAKAIAbAA==.',
['封印']='封印:BAAALgAECgQJBAAAAA==.',
['射到']='射到你高兴:BAAALgAECgEJAQAAAA==.',
['射雀']='射雀雀:BAAALgAECgYJDQAAAA==.',
['将臣']='将臣:BAAALgADCgIJAgAAAA==.',
['小东']='小东东:BAAALgADCgQJBAAAAA==.',
['小了']='小了白了兔:BAAALgAFFAUJAQAAAA==.',
['小以']='小以沫:BAAALgAECgkJCQAAAA==.',
['小兔']='小兔子呀:BAAALgAECgQJBAAAAA==.',
['小凡']='小凡不凡:BAABLgAFFH8FAAINAAMJlxUDEwD9AAANAAMJlxUDEwD9AAAAAA==.',
['小小']='小小光年:BAAALgAECgUJBQAAAA==.',
['小山']='小山绵羊:BAAALgAFFAIJAwABLgAFFAQJDQAFAK8hAA==.',
['小州']='小州州:BAAALgAECgQJBgAAAA==.',
['小忽']='小忽悠哈:BAAALgADCgQJBAAAAA==.',
['小怪']='小怪兽豪儿:BAAALgAECgYJBgAAAA==.',
['小方']='小方的秋天:BAAALgAECgQJBAAAAA==.小方的秋日:BAAALgAFFAIJAgAAAA==.',
['小橘']='小橘:BAAALgAFFAIJAgAAAA==.',
['小洲']='小洲洲:BAAALgAECgIJAwAAAA==.',
['小猪']='小猪丶有点忙:BAAALgAECgcJCwAAAA==.小猪会武功:BAAALgAECgEJAQAAAA==.小猪兔:BAAALgAECgEJAQAAAA==.',
['小米']='小米大麦粥:BAABLgAFFH8FAAIKAAIJhBMYEgCuAAAKAAIJhBMYEgCuAAAAAA==.',
['小脆']='小脆果:BAAALgAECgYJCwAAAA==.',
['小蛮']='小蛮:BAAALgAECgIJAgAAAA==.',
['小趴']='小趴菜:BAAALgADCgEJAQAAAA==.',
['小阿']='小阿鲁:BAAALgAECgQJBAAAAA==.',
['小雨']='小雨朵:BAAALgAECgEJAQAAAA==.',
['小鱼']='小鱼:BAAALgAFFAIJAwAAAA==.',
['小黑']='小黑子:BAAALgADCgEJAQAAAA==.',
['少吃']='少吃外卖好嘛:BAAALgAECgEJAQAAAA==.',
['尘忆']='尘忆:BAAALgAECgQJBAAAAA==.',
['尼古']='尼古拉斯坦森:BAAALgADCgQJBAAAAA==.',
['屁屁']='屁屁:BAAALgADCgQJBAAAAA==.',
['居仔']='居仔:BAAALgAECgYJBgAAAA==.',
['崛起']='崛起的小巨:BAAALgADCgIJAgAAAA==.',
['川哥']='川哥的逆袭:BAAALgAECgcJCwAAAA==.',
['工具']='工具牛牛:BAAALgAFFAIJAgABLgAFFAQJCwAPAGYaAA==.',
['巧克']='巧克力的味道:BAAALgAECgMJCAAAAA==.',
['巫婆']='巫婆王之怒:BAAALgADCgEJAQAAAA==.',
['帅气']='帅气万人迷:BAAALgAECgQJBwAAAA==.',
['帝艾']='帝艾娶:BAAALgAECgcJDAAAAA==.',
['年糕']='年糕番薯:BAAALgAECgEJAQABLgAFFAIJBwAFACwdAA==.',
['幻变']='幻变形小仓鼠:BAAALgAECgQJBgAAAA==.',
['幻彩']='幻彩法:BAAALgAECgYJCgAAAA==.',
['幻暗']='幻暗影小仓鼠:BAAALgAECgEJAgAAAA==.',
['幽冥']='幽冥狂德:BAAALgADCgYJBgAAAA==.',
['幽小']='幽小幽:BAAALgAECgEJAQAAAA==.',
['废话']='废话家:BAAALgAECgMJBwAAAA==.',
['康熙']='康熙爷:BAAALgAECgMJBgAAAA==.',
['弑乚']='弑乚神:BAAALgAECgcJCwAAAA==.',
['引魂']='引魂入夢:BAAALgADCgYJBgAAAA==.',
['张元']='张元英:BAAALgAECgYJDAAAAA==.',
['彡缺']='彡缺情丨灬:BAAALgAECgMJAwAAAA==.彡缺钱丨灬:BAAALgAECgUJBQAAAA==.',
['彦祖']='彦祖的头盖骨:BAAALgAECgQJCQAAAA==.',
['影子']='影子浪轩:BAAALgAECgYJBgAAAA==.',
['很急']='很急:BAAALgAECggJEwAAAA==.',
['御神']='御神乐丶:BAAALgAFFAMJAwAAAA==.',
['微风']='微风斜阳:BAAALgADCgEJAQAAAA==.',
['德撸']='德撸姨:BAAALgADCgEJAQAAAA==.',
['德艺']='德艺双馨骑:BAAALgAECgYJDgAAAA==.',
['心中']='心中只有你:BAAALgAECgEJAQAAAA==.',
['忧郁']='忧郁郁:BAAALgAECgMJAwAAAA==.',
['快踩']='快踩黑水回血:BAAALgAECgcJBwAAAA==.',
['念无']='念无声忆永存:BAAALgAECgQJBAAAAA==.',
['怜的']='怜的佪忆:BAABLgAFFH8IAAIFAAMJ/h9OEgAfAQAFAAMJ/h9OEgAfAQAAAA==.',
['急奔']='急奔的乌龟:BAAALgAECgQJBgAAAA==.',
['恴曐']='恴曐畠乤:BAAALgAECgEJAQAAAA==.',
['悟无']='悟无武雾:BAAALgAECgQJBAAAAA==.',
['惊雁']='惊雁落虚弦:BAAALgAECgkJCQAAAA==.',
['想去']='想去看星星:BAAALgAECgcJDwAAAA==.',
['愛意']='愛意隨風起:BAAALgAECgcJBwAAAA==.',
['戎卷']='戎卷风:BAABLgAFFH8HAAIFAAUJnRDUDABQAQAFAAUJnRDUDABQAQABLgAFFAYJCwAFAL0cAA==.',
['成都']='成都唯一的壹:BAAALgAECgcJCwAAAA==.',
['我丑']='我丑但我温柔:BAAALgAECgMJAwAAAA==.',
['我会']='我会卖萌:BAAALgAECgcJDQAAAA==.',
['我其']='我其实有斩炎:BAABLgAFFH8JAAICAAMJFhDlGwDzAAACAAMJFhDlGwDzAAAAAA==.',
['我是']='我是臭大熊:BAAALgAECgcJBwAAAA==.',
['我爱']='我爱吃鸡蛋:BAAALgAECgIJBAAAAA==.',
['我爹']='我爹兰博王:BAABLgAFFH8JAAIWAAQJvxQDBQA5AQAWAAQJvxQDBQA5AQAAAA==.',
['我的']='我的前女友:BAAALgAECgMJAwAAAA==.我的陈二狗:BAAALgAECgEJAQAAAA==.',
['我真']='我真的猎开:BAABLgAFFH8JAAQKAAQJIxBeEgCtAAAVAAIJPxYDGgC0AAAKAAIJIA9eEgCtAAAXAAIJvgnEBgClAAAAAA==.',
['战胜']='战胜之气:BAAALgADCgEJAQAAAA==.',
['戴维']='戴维斯凉茶:BAAALgAECgEJAgAAAA==.',
['技术']='技术好没烦恼:BAAALgAECgkJDgAAAA==.',
['抹茶']='抹茶丶棒棒冰:BAAALgAECgQJBQAAAA==.',
['拖拖']='拖拖米:BAAALgAECgEJAQAAAA==.',
['拖米']='拖米:BAAALgAECgIJBAAAAA==.',
['招财']='招财猫一号:BAABLgAFFH8LAAIPAAQJEhvHAACBAQAPAAQJEhvHAACBAQAAAA==.',
['拥抱']='拥抱燃烧军团:BAAALgAECgEJAQAAAA==.',
['指头']='指头告了消乏:BAAALgADCgEJAQAAAA==.',
['挽云']='挽云:BAAALgAECgYJEAAAAA==.挽云九:BAAALgAECgYJCAAAAA==.',
['摸鱼']='摸鱼的無名:BAABLgAFFH8LAAIHAAQJmwv6DAAlAQAHAAQJmwv6DAAlAQAAAA==.摸鱼糕手:BAACLgAFFH8KAAIYAAQJWB33BgBkAQAYAAQJWB33BgBkAQAuAAQKfxoAAhgACAluIJcJAO8CABgACAluIJcJAO8CAAAA.',
['敖闰']='敖闰:BAAALgADCgIJAgAAAA==.',
['断浮']='断浮生丶:BAAALgAECgQJBAAAAA==.',
['无内']='无内鬼:BAAALgAECgUJCQAAAA==.',
['无恒']='无恒的永眠:BAAALgAECgQJBgAAAA==.',
['无敌']='无敌搓炉石:BAACLgAFFH8KAAIDAAMJXBTbDAD+AAADAAMJXBTbDAD+AAAuAAQKfxYAAgMABwkSIl4cAMACAAMABwkSIl4cAMACAAAA.无敌烧冬瓜:BAAALgAECgQJBAAAAA==.',
['无痕']='无痕之伤:BAAALgAECgMJAwAAAA==.',
['星空']='星空:BAAALgAECgYJDAAAAA==.',
['星遇']='星遇:BAAALgAECgcJBwABLgAFFAQJBAAIAAAAAA==.',
['春分']='春分丶秋分:BAAALgAECgUJBQAAAA==.',
['春野']='春野:BAABLgAFFH8HAAIVAAIJ/BZCHAClAAAVAAIJ/BZCHAClAAAAAA==.',
['春风']='春风化丝雨:BAAALgADCgEJAQAAAA==.',
['是阿']='是阿迟呀:BAACLgAFFH8JAAIZAAMJBiNxBABEAQAZAAMJBiNxBABEAQAuAAQKfxkAAhkABgksH6IfAP0BABkABgksH6IfAP0BAAAA.是阿迟啊:BAAALgAECgMJAwABLgAFFAMJCQAZAAYjAA==.',
['晓雨']='晓雨:BAAALgAECgEJAgAAAA==.',
['晴天']='晴天小屁:BAAALgAECgYJDAAAAA==.',
['暗夜']='暗夜小花花:BAAALgADCgMJAwAAAA==.暗夜星海:BAAALgAECgEJAQAAAA==.暗夜猎魔丶:BAAALgAFFAUJAgAAAA==.',
['暗黑']='暗黑之傲:BAAALgADCgEJAQAAAA==.暗黑之刃:BAAALgADCgIJAgAAAA==.',
['暴力']='暴力没血:BAAALgADCgIJAgAAAA==.',
['曰后']='曰后你要想我:BAAALgAECgUJBgAAAA==.',
['最强']='最强灬:BAAALgAFFAIJBAAAAA==.',
['最长']='最长的电影灬:BAAALgAFFAIJAgAAAA==.',
['月中']='月中光光:BAAALgADCgYJCwAAAA==.',
['月孤']='月孤鹜:BAAALgAECgEJAQAAAA==.',
['月影']='月影之力:BAABLgAECn8eAAMBAAkJLBqXBgD9AgABAAkJLBqXBgD9AgAaAAQJfg22CACjAAAAAA==.月影佑汐:BAABLgAFFH8NAAIbAAQJJxTTCQA6AQAbAAQJJxTTCQA6AQAAAA==.月影清风:BAAALgAECgcJBwABLgAFFAQJDQAbACcUAA==.月影無雙:BAAALgAECgMJAwAAAA==.月影腐竹:BAAALgAECgEJAQABLgAFFAQJDQAbACcUAA==.',
['月野']='月野橘:BAAALgAECgUJBQAAAA==.',
['木有']='木有人:BAABLgAFFH8KAAIDAAUJZxKGBQCXAQADAAUJZxKGBQCXAQAAAA==.',
['来哥']='来哥一不小心:BAAALgAECgYJCAAAAA==.',
['杨小']='杨小邪:BAAALgAECgUJBQAAAA==.',
['杭州']='杭州第一深情:BAAALgAECgUJCgAAAA==.',
['林心']='林心如:BAAALgAECgEJAQAAAA==.',
['果奶']='果奶:BAAALgAECgEJAQAAAA==.',
['柒零']='柒零捌陆:BAABLgAFFH8KAAMPAAMJABf+AwAEAQAPAAMJBBb+AwAEAQAYAAIJvgrYHgB/AAAAAA==.柒零捌陆丶:BAAALgAECgYJCwAAAA==.',
['柯基']='柯基丶基基:BAAALgAECgYJBwAAAA==.',
['柳如']='柳如烟丨:BAAALgADCgYJBgAAAA==.',
['格赫']='格赫罗斯:BAAALgAECgUJCgAAAA==.',
['桐楻']='桐楻:BAABLgAFFH8GAAIPAAMJTBuBBgATAQAPAAMJTBuBBgATAQAAAA==.',
['梁家']='梁家辉丶:BAAALgAECgEJAgAAAA==.',
['梅琳']='梅琳娜:BAAALgADCgEJAQAAAA==.',
['梦如']='梦如人生:BAAALgADCgUJBQAAAA==.',
['森罗']='森罗万象:BAAALgAECgcJCQAAAA==.',
['椰汁']='椰汁丶西米露:BAAALgAECgEJAgAAAA==.',
['楞苗']='楞苗更更:BAAALgAECgYJBgAAAA==.',
['櫻丶']='櫻丶花:BAAALgAECgEJAgAAAA==.',
['欧尼']='欧尼酱不吃冰:BAAALgADCgEJAQABLgAECgYJFwACAJseAA==.',
['正二']='正二八经:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡丧钟:BAABLgAFFH8HAAIcAAUJpwbLBQDrAAAcAAUJpwbLBQDrAAAAAA==.',
['殇无']='殇无恨:BAAALgAECgEJAgAAAA==.',
['殇梦']='殇梦大爷:BAAALgAFFAIJAgAAAA==.',
['比格']='比格沃斯先生:BAAALgAECgQJBAAAAA==.',
['毛色']='毛色不纯:BAAALgADCgEJAgAAAA==.',
['毛风']='毛风剑:BAAALgAECgUJBwAAAA==.',
['气势']='气势:BAAALgAECgEJAQAAAA==.',
['永带']='永带妹:BAABLgAECn8PAAMNAAcJ9xoqRgD5AQANAAcJ9xoqRgD5AQAMAAEJCgHsfwAUAAAAAA==.',
['氺掰']='氺掰掰:BAAALgAFFAQJAwAAAA==.',
['汉格']='汉格卡:BAABLgAFFH8GAAIHAAIJBBSDIgCbAAAHAAIJBBSDIgCbAAAAAA==.',
['沃瑞']='沃瑞恩:BAAALgADCgYJCwAAAA==.',
['法爷']='法爷打十个:BAAALgAFFAQJAgAAAA==.',
['泠泠']='泠泠水挽月:BAAALgAECgYJBgAAAA==.',
['泰吉']='泰吉大利:BAABLgAFFH8IAAMdAAQJVgyeAABiAQAdAAQJVgyeAABiAQAZAAMJaQPQDwDkAAAAAA==.',
['泰式']='泰式一条龙:BAAALgAFFAMJBAAAAA==.',
['洛晴']='洛晴云:BAAALgAECgQJBAAAAA==.',
['派大']='派大星吹泡泡:BAAALgAECgYJCgAAAA==.',
['流星']='流星剑雨:BAAALgADCgEJAQAAAA==.',
['海之']='海之乐章:BAAALgAECgEJAQABLgAFFAQJAwAIAAAAAA==.',
['消失']='消失的光年:BAABLgAFFH8FAAIDAAIJRg9gJACjAAADAAIJRg9gJACjAAAAAA==.',
['深圳']='深圳尼哥:BAAALgAECgUJBQAAAA==.',
['清泫']='清泫幻玥:BAAALgAECgMJAwAAAA==.',
['渣丶']='渣丶渣:BAACLgAFFH8RAAQSAAUJpg++AgA1AQASAAQJAwu+AgA1AQAQAAMJhRJzEQD7AAARAAQJNQGwBQC8AAAuAAQKfxQABBAACAlLHuwZAHwCABAABwmpIuwZAHwCABIAAgkNHpspAKQAABEAAgnTAt8/AFIAAAAA.',
['游侠']='游侠野战:BAAALgAFFAEJAQAAAA==.',
['源计']='源计划末:BAAALgAECgYJBgAAAA==.',
['潇潇']='潇潇兮:BAAALgAECgYJBgAAAA==.',
['潘古']='潘古丹:BAAALgAECgYJBgAAAA==.',
['潘法']='潘法王:BAAALgAECgEJAgAAAA==.',
['澳洲']='澳洲翠鸟:BAAALgADCgYJBgAAAA==.',
['激萌']='激萌奶哈哈:BAAALgADCgcJBwAAAA==.',
['火炏']='火炏焱:BAAALgAECgQJBQAAAA==.',
['火焰']='火焰醉鹅:BAAALgAECgcJBwAAAA==.',
['灬尐']='灬尐尐萨:BAACLgAFFH8PAAIWAAUJGhr/AQCVAQAWAAUJGhr/AQCVAQAuAAQKfxgAAxYACAmLGugYAE8CABYACAmLGugYAE8CAAYAAQktIX54AGEAAAAA.',
['灬温']='灬温蕾萨灬:BAAALgADCgUJBQAAAA==.',
['灰毛']='灰毛大耗汁:BAAALgAECgUJBQAAAA==.',
['灵乌']='灵乌路空:BAAALgAECgEJAQAAAA==.',
['烟不']='烟不坏:BAAALgAECgQJBQAAAA==.',
['烟花']='烟花丨圣骑:BAAALgAECgEJAQAAAA==.烟花丨小德:BAAALgAECgEJAQAAAA==.烟花丨恶魔:BAAALgAECgEJAQAAAA==.烟花丨武僧:BAAALgAECgEJAQAAAA==.烟花丨雷战:BAAALgAECgEJAQAAAA==.',
['烬渊']='烬渊丨棘影:BAAALgAFFAQJAgAAAA==.',
['熊猫']='熊猫胖嘟嘟:BAAALgAFFAEJAQAAAA==.',
['燃烧']='燃烧大主教:BAAALgADCgQJBAAAAA==.',
['爆炒']='爆炒联盟:BAAALgAECgQJBgAAAA==.',
['爱你']='爱你骑士:BAAALgAECgUJBQAAAA==.',
['爱就']='爱就跟我走:BAAALgAECgMJAwAAAA==.',
['爱河']='爱河中的小草:BAAALgAFFAIJAgAAAA==.',
['牙签']='牙签扎人犯法:BAAALgAECgEJAgAAAA==.',
['牛奶']='牛奶喵喵:BAAALgAECgcJCwAAAA==.',
['牛志']='牛志刚:BAAALgAECgEJAQAAAA==.',
['牛而']='牛而逼之:BAAALgAECgEJAgAAAA==.',
['牧筱']='牧筱芸:BAAALgAECgcJBwAAAA==.',
['牵野']='牵野猪看世界:BAAALgAFFAEJAQAAAA==.',
['犽戎']='犽戎:BAAALgADCgEJAQAAAA==.',
['狂澜']='狂澜碎岳丶:BAAALgAECgEJAQAAAA==.',
['猎杀']='猎杀的欧尼酱:BAAALgAECgMJAwABLgAECgYJFwACAJseAA==.',
['猎神']='猎神者归来:BAAALgAECgEJAgAAAA==.',
['猫猫']='猫猫不呲牙:BAAALgAECgEJAQABLgAECgUJBQAIAAAAAA==.猫猫乱:BAAALgADCgcJCQAAAA==.猫猫塔塔开:BAAALgAECgUJBQAAAA==.猫猫小钢牙:BAAALgADCgEJAQAAAA==.猫猫神:BAAALgAECgEJAQAAAA==.',
['猴子']='猴子就是猴子:BAAALgAECgEJAQAAAA==.',
['玄鹤']='玄鹤舞清商:BAAALgAECgUJBQAAAA==.',
['王二']='王二麦闪闪哒:BAABLgAFFH8NAAITAAQJniEwAwB4AQATAAQJniEwAwB4AQAAAA==.',
['王以']='王以太:BAABLgAFFH8GAAIKAAQJgBtdAgB6AQAKAAQJgBtdAgB6AQAAAA==.',
['王爷']='王爷威武:BAAALgAECgUJCQAAAA==.',
['王牌']='王牌变色龙:BAACLgAFFH8OAAIGAAQJZB1OBgB2AQAGAAQJZB1OBgB2AQAuAAQKfx8AAgYACAnAIm8JAPsCAAYACAnAIm8JAPsCAAAA.',
['玖拾']='玖拾玖葉:BAAALgAECgIJAgAAAA==.',
['玛丽']='玛丽莲胖露:BAAALgAECgMJBwAAAA==.',
['玥霖']='玥霖啊丶:BAAALgAECgYJCwAAAA==.',
['玩到']='玩到痴晒线:BAABLgAECn8WAAIZAAcJIB4KEwCCAgAZAAcJIB4KEwCCAgAAAA==.',
['玩玩']='玩玩你了:BAAALgAECgEJAQAAAA==.玩玩你哦:BAAALgAECgIJAQAAAA==.玩玩你啊:BAAALgAECgEJAQAAAA==.',
['珍獣']='珍獣:BAAALgAFFAMJAwAAAA==.',
['琊璃']='琊璃:BAAALgADCgYJBgAAAA==.',
['瑟提']='瑟提:BAAALgAECgEJAQAAAA==.',
['瓷月']='瓷月亮:BAAALgAECgkJCAAAAA==.',
['留恋']='留恋好梦:BAAALgAECgEJAQAAAA==.',
['瘋狂']='瘋狂過後:BAAALgAECgEJAQABLgAFFAIJAwAIAAAAAA==.',
['白糖']='白糖裹粽子:BAAALgAFFAMJBAAAAA==.',
['白雪']='白雪又一冬:BAAALgAECgQJBAAAAA==.',
['皮三']='皮三妹:BAAALgADCgMJAwAAAA==.',
['直飛']='直飛上海:BAAALgADCgYJBgAAAA==.',
['看你']='看你窝怂样子:BAAALgADCgEJAQAAAA==.',
['看我']='看我牛哔不:BAAALgADCgcJBwAAAA==.',
['真妖']='真妖刀:BAAALgADCgYJBgAAAA==.',
['真德']='真德假德:BAAALgAECgQJBQAAAA==.',
['矢车']='矢车菊与丁香:BAABLgAFFH8NAAQXAAQJwBdvAQBqAQAXAAQJMRJvAQBqAQAVAAMJOxOPFQDvAAAKAAEJ+B3cHgBkAAAAAA==.',
['短腿']='短腿无尾熊:BAAALgAECgUJBQABLgAFFAIJBAAIAAAAAA==.',
['矮的']='矮的批爆:BAACLgAFFH8QAAIFAAQJShUFGgBiAQAFAAQJShUFGgBiAQAuAAQKfxoAAgUACAmZHTE5AJECAAUACAmZHTE5AJECAAAA.',
['神蛊']='神蛊温皇:BAAALgAECgMJBQAAAA==.',
['神风']='神风:BAAALgAECgkJDwAAAA==.',
['秋茗']='秋茗:BAAALgAFFAIJBAAAAA==.',
['移动']='移动电网:BAAALgAECgYJBgAAAA==.',
['稳舵']='稳舵定风波:BAAALgAECgQJBAAAAA==.',
['空条']='空条秋太郎:BAAALgAECgEJAQAAAA==.',
['窝牛']='窝牛:BAAALgAECgMJAwABLgAECgYJCQAIAAAAAA==.窝牛大哥:BAAALgAECgYJCQAAAA==.窝牛大神仙:BAAALgAECgIJAgAAAA==.窝牛奶奶:BAAALgAECgIJAgABLgAECgYJCQAIAAAAAA==.窝牛姥爷:BAAALgAECgIJAgAAAA==.窝牛小妹:BAAALgAECgUJCAABLgAECgYJCQAIAAAAAA==.窝牛小妹妹:BAAALgAECgUJBQAAAA==.窝牛祖师爷:BAAALgAECgEJAQABLgAECgYJCQAIAAAAAA==.',
['第三']='第三羊羔:BAAALgAECgMJAwAAAA==.第三羔羊:BAAALgADCgUJBQAAAA==.',
['箭倾']='箭倾城:BAAALgAECgQJCQAAAA==.',
['米勒']='米勒之佑:BAAALgAECgcJDgAAAA==.',
['米尔']='米尔豪斯:BAAALgADCgMJAwAAAA==.',
['糖仔']='糖仔哞哞:BAAALgAECgEJAgAAAA==.糖仔小馒头:BAAALgAECgMJBAAAAA==.',
['糖尿']='糖尿使她蛀牙:BAAALgADCgYJBAAAAA==.',
['糖果']='糖果果王子:BAAALgAECgIJAgAAAA==.',
['索拉']='索拉:BAAALgAECgYJCgAAAA==.',
['索迩']='索迩:BAAALgADCgIJAgAAAA==.',
['紫眸']='紫眸凝牧:BAABLgAECn8dAAIUAAgJEg/fIwDIAQAUAAgJEg/fIwDIAQAAAA==.',
['红专']='红专并进:BAAALgAFFAIJAwAAAA==.',
['红尘']='红尘:BAAALgAECgQJBwAAAA==.',
['红袖']='红袖丶:BAAALgADCgUJBQAAAA==.',
['纳什']='纳什男爵:BAAALgAECgcJBwAAAA==.',
['细东']='细东东:BAAALgAECgQJBAAAAA==.',
['终极']='终极魔兽:BAACLgAFFH8NAAIKAAUJ8yHrAAClAQAKAAUJ8yHrAAClAQAuAAQKfygABAoACAk7I1EGACgDAAoACAk7I1EGACgDABUAAwnPBW1yAHQAABcAAgldBE4rAE4AAAAA.',
['经贸']='经贸大菊花:BAAALgAFFAQJAwAAAA==.',
['给你']='给你魔法药水:BAAALgAECgEJAQAAAA==.',
['给您']='给您添麻花了:BAAALgAECgEJAQAAAA==.',
['绝对']='绝对奥凯:BAAALgADCgIJAQAAAA==.',
['绝影']='绝影:BAABLgAFFH8NAAICAAUJEwxTDAAZAQACAAUJEwxTDAAZAQAAAA==.',
['绝望']='绝望战神:BAAALgAECgQJBgAAAA==.',
['绝版']='绝版小三:BAAALgADCgUJBQAAAA==.',
['绿豆']='绿豆薄荷茶:BAAALgAECgEJAQAAAA==.',
['罐头']='罐头泡面:BAAALgAECgEJAQAAAA==.',
['罪恶']='罪恶之骨丶:BAAALgAECgIJAgAAAA==.',
['美酒']='美酒加咖啡:BAAALgAECgYJBwAAAA==.',
['老巫']='老巫婆:BAAALgAECgYJCAAAAA==.',
['老潍']='老潍县大韩:BAAALgADCgQJBAAAAA==.',
['老謝']='老謝:BAAALgAECgYJBwAAAA==.',
['聖光']='聖光無用:BAAALgAECgEJAQAAAA==.',
['肉的']='肉的一比:BAAALgAECgEJAQAAAA==.',
['肚子']='肚子叫咕咕:BAAALgADCgEJAQAAAA==.',
['肝将']='肝将痘:BAAALgAECgMJBAAAAA==.',
['肝炒']='肝炒牛河:BAAALgAECgIJAgAAAA==.',
['肥嘟']='肥嘟嘟丶:BAAALgAECgkJEAAAAA==.',
['肯恰']='肯恰那:BAAALgADCgYJBgAAAA==.',
['胡萝']='胡萝卜:BAAALgADCgQJBAAAAA==.',
['自然']='自然的向往:BAABLgAECn8VAAINAAYJyg8oOADSAAANAAYJyg8oOADSAAAAAA==.',
['致命']='致命的妖娆:BAAALgAECgUJCQAAAA==.',
['艾宾']='艾宾浩斯套餐:BAAALgAECgkJCQAAAA==.',
['节奏']='节奏泰:BAAALgAECgEJAQAAAA==.',
['芝士']='芝士芋泥啵啵:BAAALgAECgkJEgABLgAFFAYJAQAIAAAAAA==.芝士青年:BAAALgAECgYJBgAAAA==.',
['花之']='花之巫火:BAABLgAFFH8IAAIFAAQJmQD3MADtAAAFAAQJmQD3MADtAAAAAA==.',
['花心']='花心小帅哥:BAAALgAECgQJBAAAAA==.',
['花生']='花生东山:BAAALgAECgQJBQAAAA==.',
['花葬']='花葬:BAAALgAECgYJBgAAAA==.',
['花飞']='花飞为花碎:BAAALgAECgYJEQAAAA==.',
['苍火']='苍火坠:BAAALgAECgUJBQAAAA==.',
['苏小']='苏小贤:BAAALgAECgMJAwAAAA==.',
['苗小']='苗小莹:BAAALgADCgYJBgAAAA==.',
['若叶']='若叶姬色:BAAALgAFFAIJBAAAAA==.',
['苹果']='苹果飞饼丶:BAAALgAECgYJBgAAAA==.',
['莱欧']='莱欧斯:BAAALgAFFAEJAQAAAA==.',
['莱维']='莱维特:BAAALgADCgEJAQAAAA==.',
['萌萌']='萌萌哒妖刀:BAAALgADCgEJAQAAAA==.萌萌的妖刀哟:BAAALgAECgQJBAAAAA==.',
['萧瑟']='萧瑟丶:BAAALgAECgEJAQAAAA==.',
['萨里']='萨里萨去:BAAALgAFFAIJAgAAAA==.',
['萨非']='萨非贝壳:BAAALgADCgEJAQAAAA==.',
['落风']='落风之域:BAAALgAECgIJAgAAAA==.',
['蒜蓉']='蒜蓉小龙虾:BAAALgAECgQJBAAAAA==.',
['蓝天']='蓝天一凡爸爸:BAAALgADCgYJCgAAAA==.蓝天则鸣公主:BAAALgADCgYJBgAAAA==.蓝天则鸣公子:BAAALgADCgIJAgAAAA==.蓝天潘珂:BAAALgADCgEJAQAAAA==.',
['蕙质']='蕙质兰心:BAAALgADCgEJAQAAAA==.',
['薩鲁']='薩鲁法爾:BAAALgAECgYJBwAAAA==.',
['蘇察']='蘇察哈爾燦:BAAALgAECgMJAwAAAA==.',
['蛋挞']='蛋挞学长丶:BAAALgAECgYJBwAAAA==.',
['蛋片']='蛋片散射:BAAALgAECgIJBAAAAA==.',
['蛋疼']='蛋疼的傻馒:BAACLgAFFH8GAAIWAAMJtBHLDwDqAAAWAAMJtBHLDwDqAAAuAAQKfxUAAhYABwkRGOYqAOIBABYABwkRGOYqAOIBAAEuAAUUAwkIAAUAVh8A.',
['血之']='血之光刃:BAAALgAECgIJAgAAAA==.',
['血疯']='血疯颠:BAAALgAECgMJBAAAAA==.',
['血色']='血色凌空:BAAALgAECgQJBQAAAA==.',
['裤叉']='裤叉叉:BAAALgAECgcJEAAAAA==.',
['西门']='西门吹炮:BAAALgAFFAQJBAAAAA==.',
['訫随']='訫随舞动:BAAALgAFFAIJAgAAAA==.',
['诺贝']='诺贝尔根基奖:BAAALgAECgEJAQAAAA==.',
['谁动']='谁动了我的矛:BAAALgAECgEJAQAAAA==.',
['调调']='调调:BAAALgADCgYJCAAAAA==.',
['豆苗']='豆苗胖猫猫:BAAALgAFFAIJAgAAAA==.',
['赚钱']='赚钱养基友:BAAALgAECgEJAQAAAA==.',
['赫蕾']='赫蕾拉:BAAALgAECgIJAgAAAA==.',
['走你']='走你骑士:BAAALgADCgEJAQAAAA==.',
['走得']='走得慢:BAAALgADCgMJAwAAAA==.',
['赵美']='赵美延:BAAALgAFFAIJBAAAAA==.',
['超级']='超级无敌暴王:BAAALgAECgEJAQAAAA==.',
['转角']='转角遇见野猪:BAAALgAECgIJAgAAAA==.',
['轻舟']='轻舟:BAAALgAECgUJBwAAAA==.',
['辉哥']='辉哥:BAAALgAECggJCgAAAA==.',
['辣爆']='辣爆牛欢喜:BAAALgAECgQJCAAAAA==.',
['达拉']='达拉斯小法:BAABLgAFFH8KAAIFAAQJ5BM8HgBRAQAFAAQJ5BM8HgBRAQAAAA==.',
['达芬']='达芬骑:BAABLgAECn8UAAIDAAYJUBsEawCoAQADAAYJUBsEawCoAQAAAA==.',
['迷你']='迷你曼:BAAALgAECgUJBQAAAA==.',
['迷茫']='迷茫的小妖:BAAALgAECgYJCwAAAA==.',
['逆時']='逆時針灬魔戰:BAAALgAECgQJBAAAAA==.',
['逝去']='逝去的日子:BAAALgADCgYJBgAAAA==.',
['逸龙']='逸龙戏贰凤:BAAALgAFFAIJAwAAAA==.',
['邪能']='邪能欧尼酱:BAABLgAECn8XAAICAAYJmx68PgD5AQACAAYJmx68PgD5AQAAAA==.',
['邬贼']='邬贼贼:BAAALgAFFAUJAQAAAA==.',
['醉后']='醉后一箭:BAAALgAECgkJCgAAAA==.',
['重回']='重回十年:BAAALgAECgYJCwAAAA==.',
['金陵']='金陵二当家:BAAALgAECgMJBQAAAA==.',
['錯落']='錯落:BAAALgAECgIJAwAAAA==.',
['长夜']='长夜无眠:BAAALgAECgEJAQAAAA==.',
['阿令']='阿令酱:BAAALgAECgEJAgAAAA==.',
['阿克']='阿克萨斯萝:BAAALgAECgEJAgAAAA==.',
['阿古']='阿古茹丶:BAAALgAFFAQJAgAAAA==.',
['阿拉']='阿拉松:BAABLgAFFH8GAAIHAAMJlBOPKQD0AAAHAAMJlBOPKQD0AAAAAA==.',
['阿斯']='阿斯塔丶:BAAALgAECgEJAQAAAA==.',
['阿百']='阿百川川:BAAALgAECgIJAgAAAA==.',
['阿的']='阿的小小牛:BAAALgADCgIJAwAAAA==.',
['阿芙']='阿芙丶:BAAALgAECgEJAQAAAA==.',
['陈丨']='陈丨数码相机:BAAALgAECgYJBwAAAA==.',
['陈皮']='陈皮:BAAALgAECgQJBAAAAA==.',
['难啃']='难啃的馒头:BAAALgAECgQJBAAAAA==.',
['雨流']='雨流星:BAABLgAFFH8FAAIFAAMJcRNjKwAIAQAFAAMJcRNjKwAIAQAAAA==.',
['雨衣']='雨衣指虾:BAABLgAECn8UAAMNAAYJHSKMYwCfAQANAAUJ6hyMYwCfAQAMAAIJkRs2RwCZAAABLgAFFAIJAgAIAAAAAA==.',
['雪清']='雪清秋:BAAALgADCgYJBgAAAA==.',
['雪鸿']='雪鸿泥爪:BAAALgAECgQJAQAAAA==.',
['霒蚀']='霒蚀:BAAALgAFFAEJAQAAAA==.',
['霜焱']='霜焱:BAAALgAECgQJCQAAAA==.',
['霜狼']='霜狼丶术魔:BAAALgAECgYJDwAAAA==.',
['霸波']='霸波奔儿:BAACLgAFFH8JAAIYAAQJdhb7CgAvAQAYAAQJdhb7CgAvAQAuAAQKfx0AAhgACAmaFTgjAOkBABgACAmaFTgjAOkBAAAA.',
['青羽']='青羽凝:BAAALgAECgMJBAAAAA==.',
['青色']='青色火焰丶:BAAALgAECgYJDgAAAA==.',
['静流']='静流:BAAALgAECgEJAQAAAA==.',
['面多']='面多了加水:BAAALgAECgYJBwAAAA==.',
['风中']='风中的小草:BAAALgAECgQJBwAAAA==.风中的羽毛:BAAALgAECgMJAwAAAA==.风中飞鸿:BAAALgAECgUJCAAAAA==.',
['风剑']='风剑家小骷髅:BAAALgADCgEJAQAAAA==.风剑的小短腿:BAAALgADCgEJAQAAAA==.',
['饮以']='饮以为荣:BAAALgAECgEJAQAAAA==.',
['马桶']='马桶上的菊花:BAAALgAECgMJAwAAAA==.',
['骑天']='骑天灬大聖:BAAALgAECgcJDQAAAA==.',
['骑野']='骑野猪看世界:BAAALgAECgEJAQAAAA==.骑野猪走世界:BAAALgAECgIJBAAAAA==.',
['高俅']='高俅:BAAALgADCgYJBgABLgAFFAYJBQAHAEokAA==.',
['鬣丶']='鬣丶狗:BAAALgAECgYJDAAAAA==.',
['鬼面']='鬼面修罗:BAAALgAECgYJDAAAAA==.',
['魂兮']='魂兮乄小萨:BAAALgAECgYJBgAAAA==.魂兮乄疯爆:BAAALgAECgUJBQAAAA==.魂兮乄禁卫:BAAALgAECgEJAQAAAA==.',
['鮽焽']='鮽焽:BAAALgADCgEJAQAAAA==.',
['鸟德']='鸟德:BAAALgAECgIJAgABLgAFFAEJAQAIAAAAAA==.',
['鸟语']='鸟语花香:BAAALgAECgYJEQAAAA==.',
['鹅誓']='鹅誓洒满:BAAALgAFFAMJBAAAAA==.',
['麦克']='麦克飞刀:BAAALgAECgYJCgAAAA==.',
['麻辣']='麻辣丶:BAAALgAECgYJBgAAAA==.',
['黄埔']='黄埔炒蛋:BAAALgAECgcJBAAAAA==.',
['黄油']='黄油皮尔森:BAAALgAECgEJAQAAAA==.',
['黑咖']='黑咖啡的心情:BAAALgAFFAIJAwAAAA==.',
['黑夜']='黑夜战神:BAAALgAECgEJAgAAAA==.',
['黑潮']='黑潮地板哥:BAAALgAECgQJBQAAAA==.',
['黑石']='黑石之印:BAAALgADCgEJAQAAAA==.',
['鼓楼']='鼓楼吴彦祖:BAABLgAFFH8HAAIFAAIJuhgNIQCxAAAFAAIJuhgNIQCxAAAAAA==.',
['龙希']='龙希尔猎:BAAALgAECgcJDAAAAA==.',
['龚成']='龚成章:BAAALgAECgYJBwAAAA==.',
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
