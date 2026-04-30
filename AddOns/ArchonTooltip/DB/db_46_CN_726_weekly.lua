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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','Priest-Shadow','Mage-Frost','DeathKnight-Blood','Warlock-Affliction','Unknown-Unknown','Druid-Restoration','Shaman-Restoration','Paladin-Retribution','Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','DeathKnight-Unholy','Warrior-Protection','Evoker-Augmentation','Shaman-Elemental','DemonHunter-Devourer','Monk-Brewmaster','Warrior-Arms','Warrior-Fury','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Frost',}
local provider = {region='CN',realm='法拉希姆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amina:BAAALgAECgEJAQAAAA==.',
Ba='Babinou:BAAALgAECgEJAgAAAA==.Babyss:BAACLgAFFH8LAAMBAAUJkxmaCACfAQABAAUJ1ROaCACfAQACAAMJNBeVDACnAAAuAAQKfyEAAwEACQmeI58LAB0DAAEACAliI58LAB0DAAIABQn7HYcOAOEBAAAA.Babyssa:BAABLgAFFH8IAAMBAAQJjxZDFwCtAAABAAMJoBVDFwCtAAACAAEJXBkAAAAAAAABLgAFFAUJCwABAJMZAA==.Babyssb:BAABLgAECn8WAAMCAAkJoBwtBwBXAgACAAcJgx0tBwBXAgABAAgJLBoWMwBAAgABLgAFFAUJCwABAJMZAA==.Babyssc:BAABLgAECn8cAAMCAAkJxBafCQAmAgACAAcJ+xifCQAmAgABAAgJ9RQ4PgAUAgABLgAFFAUJCwABAJMZAA==.Babyssd:BAABLgAECn8UAAMCAAcJpSAuCgAbAgACAAcJkxouCgAbAgABAAUJOyNHdQBzAQABLgAFFAUJCwABAJMZAA==.Babysse:BAAALgAECgcJDAABLgAFFAUJCwABAJMZAA==.Babyssf:BAAALgAECgcJDQABLgAFFAUJCwABAJMZAA==.Babyssg:BAAALgAECgcJDQABLgAFFAUJCwABAJMZAA==.Babyssh:BAAALgAECgYJBgABLgAFFAUJCwABAJMZAA==.Babyssj:BAAALgAECgYJBgABLgAFFAUJCwABAJMZAA==.',
Be='Beethove:BAAALgADCgEJAQAAAA==.',
Ce='Celeste:BAAALgAECgEJAQAAAA==.',
Co='Copilot:BAAALgADCgEJAQAAAA==.',
Da='Dajia:BAAALgADCgMJAwAAAA==.',
De='Devils:BAAALgADCgEJAQAAAA==.',
Do='Donut:BAACLgAFFH8MAAMDAAQJxx5nAgAXAQADAAMJ6xRnAgAXAQAEAAMJkSQ9EQC/AAAuAAQKfxoAAwQABwnWIwYLAOMCAAQABwnWIwYLAOMCAAMAAQkpHCEbAE4AAAAA.',
Dr='Drytron:BAAALgAECgEJAQAAAA==.',
Du='Duang:BAAALgAFFAEJAgAAAA==.',
Ea='Earey:BAAALgAFFAEJAQAAAA==.',
Em='Empcavalry:BAAALgAECgEJAQAAAA==.',
Et='Eternityy:BAABLgAFFH8IAAIFAAQJNg7nAgA6AQAFAAQJNg7nAgA6AQAAAA==.',
Fi='Fire:BAAALgAECgUJBwAAAA==.',
Ge='Gekkouka:BAAALgAECgMJAwAAAA==.',
Gu='Gua:BAAALgAECgEJAQAAAA==.Guai:BAAALgAECgEJAgAAAA==.Gual:BAAALgAECgQJBAAAAA==.',
Ha='Harrine:BAAALgAECgUJBwAAAA==.',
Kb='Kbz:BAAALgAECgEJAQAAAA==.',
Ma='Madeline:BAAALgAECgIJAgAAAA==.',
Me='Mercial:BAAALgADCgcJBwAAAA==.',
Mo='Mograiny:BAAALgAECgEJAgAAAA==.Monketernity:BAAALgAECgYJBgAAAA==.Moodyblues:BAAALgAECgcJBgABLgAFFAUJBgAGABoKAA==.',
Pe='Peanutslab:BAAALgADCgMJBAAAAA==.',
Ph='Phony:BAAALgAECgcJEAAAAA==.',
Pu='Pulordmorl:BAAALgAECgIJBAAAAA==.',
Ri='Rico:BAACLgAFFH8MAAIHAAQJyybHAQDRAQAHAAQJyybHAQDRAQAuAAQKfxYAAgcABwk/JtMEAPkCAAcABwk/JtMEAPkCAAAA.',
Sh='Shadowheart:BAAALgAECgYJCwAAAA==.',
So='Soichiro:BAABLgAECn8gAAQBAAgJIR7uKwBfAgABAAcJ7B7uKwBfAgACAAQJwxjIIwA7AQAIAAEJAABBKwBIAAAAAA==.',
Sp='Spectre:BAABLgAFFH8FAAIFAAQJPw+XBwBOAQAFAAQJPw+XBwBOAQAAAA==.',
St='Strawberry:BAAALgAECgIJAgAAAA==.',
Ta='Tasty:BAAALgAECgQJBQAAAA==.',
To='Topson:BAAALgADCgEJAgAAAA==.Toumatou:BAAALgAECgMJBQAAAA==.',
Tr='Travisscott:BAAALgAFFAEJAQABLgAFFAUJDAABALIdAA==.',
Vi='Vid:BAAALgAECgcJBwAAAA==.Vitktord:BAAALgAECgYJBgAAAA==.',
Vv='Vvtanknewbie:BAAALgAFFAIJAgAAAA==.',
Wa='Waitingalone:BAAALgADCgYJBgAAAA==.',
Wq='Wqeww:BAAALgADCgYJBgAAAA==.',
Wu='Wung:BAAALgAECgEJAQABLgAECgUJBQAJAAAAAA==.',
['Xé']='Xérwo:BAAALgAECgUJBQAAAA==.',
Ya='Yasuo:BAAALgAECgMJAwAAAA==.',
Ye='Yellowstar:BAABLgAECn8UAAIKAAcJwBEoRgCJAQAKAAcJwBEoRgCJAQAAAA==.',
['一叶']='一叶梧桐:BAAALgAECgEJAwAAAA==.',
['一殇']='一殇:BAAALgAECgYJBgAAAA==.',
['一狴']='一狴犴一:BAAALgAECgUJBgAAAA==.',
['一芊']='一芊芊一:BAAALgADCgQJBAAAAA==.',
['一颗']='一颗糖:BAAALgADCgEJAQAAAA==.',
['下校']='下校鸡块:BAAALgAECgEJAQAAAA==.',
['丨凯']='丨凯子丶:BAAALgAFFAIJBAAAAA==.',
['丨小']='丨小熊软糖丨:BAAALgAECgcJEAAAAA==.',
['丨法']='丨法神丶:BAAALgAECgcJCQAAAA==.',
['丶為']='丶為愛奮戦:BAAALgAECgIJAgAAAA==.',
['丶莉']='丶莉芳:BAABLgAECn8VAAIFAAgJ/xqdEAB+AgAFAAgJ/xqdEAB+AgAAAA==.',
['乌拉']='乌拉那拉宜修:BAAALgAECgcJCwAAAA==.',
['乐千']='乐千花:BAAALgAECgQJCgABLgAFFAMJBQALAFkVAA==.',
['了春']='了春红丶:BAABLgAFFH8KAAIFAAQJuxSsBgBbAQAFAAQJuxSsBgBbAQAAAA==.',
['二爷']='二爷:BAABLgAFFH8LAAIMAAQJvRv5AQB8AQAMAAQJvRv5AQB8AQAAAA==.',
['云淡']='云淡丶:BAABLgAFFH8NAAMFAAQJQRqCBQBzAQAFAAQJQRqCBQBzAQANAAEJZABmFgA8AAAAAA==.',
['五条']='五条悟:BAAALgAECgcJCgAAAA==.',
['亚麻']='亚麻德德:BAAALgADCgUJBQAAAA==.',
['伊梦']='伊梦幽忧:BAAALgAECgcJDAAAAA==.',
['伊涅']='伊涅芙:BAAALgAECgMJAwAAAA==.',
['伊邪']='伊邪那美命:BAAALgAECgcJDwAAAA==.',
['依姐']='依姐:BAAALgAECgUJBQAAAA==.',
['修仙']='修仙小蛮幺:BAAALgAFFAEJAQAAAA==.',
['假面']='假面战魂:BAAALgAECgEJAQAAAA==.假面麦田骑士:BAAALgAECgQJBAABLgAFFAUJCwABAIoiAA==.',
['傲视']='傲视鱼儿:BAAALgAECgEJAgAAAA==.',
['光之']='光之霍因海姆:BAAALgAECgQJBAAAAA==.',
['光溜']='光溜溜:BAAALgADCgUJBQAAAA==.',
['关怀']='关怀小猪:BAAALgAECgYJBgAAAA==.',
['军体']='军体拳皇:BAAALgAECgEJAQAAAA==.',
['出音']='出音味来:BAAALgAECgUJBgAAAA==.',
['刘先']='刘先生:BAAALgAECgMJAwAAAA==.',
['制裁']='制裁:BAAALgAECgQJBAAAAA==.',
['刹那']='刹那年华:BAACLgAFFH8NAAQOAAQJ2hwJCwBnAQAOAAQJ2hwJCwBnAQAPAAEJJRXoIABfAAAQAAMJkQwAAAAAAAAuAAQKfxUABA4ACAntHZAWAHgCAA4ACAntHZAWAHgCABAAAgnKD9UmAIYAAA8AAQnpG0C7AEwAAAAA.',
['勃艮']='勃艮第红:BAACLgAFFH8IAAIRAAQJbRRCKQD0AAARAAQJbRRCKQD0AAAuAAQKfxYAAhEABwkhHbRWAO0BABEABwkhHbRWAO0BAAAA.',
['卡利']='卡利亚的锋刃:BAAALgAECgUJBwAAAA==.',
['卡琳']='卡琳丶:BAACLgAFFH8HAAIGAAMJDRWmLAAEAQAGAAMJDRWmLAAEAQAuAAQKfxcAAgYACAn5Hw8uALkCAAYACAn5Hw8uALkCAAAA.',
['叮铃']='叮铃桄榔:BAAALgAECgcJDQAAAA==.',
['可可']='可可波斯:BAAALgADCgEJAQAAAA==.',
['吃貓']='吃貓的老鼠:BAAALgAECgYJBAAAAA==.',
['吉羽']='吉羽令羽:BAAALgAECgEJAQAAAA==.',
['名字']='名字长就能苟:BAAALgAECgEJAQAAAA==.',
['君特']='君特:BAAALgAFFAYJAQAAAA==.',
['咕咕']='咕咕鹧鹧宝:BAAALgAECgYJBgAAAA==.',
['哐哧']='哐哧哐哧:BAAALgAECgYJAQABLgAFFAUJCwABAJMZAA==.',
['哒咩']='哒咩术:BAAALgADCgUJBQAAAA==.',
['唔爱']='唔爱:BAAALgAECgYJBgAAAA==.',
['喜欢']='喜欢打天:BAAALgAECgMJAwAAAA==.',
['喽尐']='喽尐喽:BAAALgAECgEJAQAAAA==.',
['噱微']='噱微璀璨:BAAALgADCgEJAQAAAA==.',
['囧囧']='囧囧丷:BAABLgAECn8eAAIGAAgJOBflVAA6AgAGAAgJOBflVAA6AgABLgAFFAUJCgAGAOYkAA==.',
['囿团']='囿团囡囝:BAABLgAECn8VAAIGAAcJyByDUABGAgAGAAcJyByDUABGAgAAAA==.',
['圣光']='圣光的永恒:BAAALgAECgIJAgAAAA==.',
['埃莉']='埃莉娅:BAAALgAECgEJAgAAAA==.',
['塔兰']='塔兰克斯:BAABLgAECn8bAAIEAAgJ1RQsGABHAgAEAAgJ1RQsGABHAgAAAA==.',
['壬生']='壬生菊千代:BAABLgAECn8cAAISAAcJ+BnnBAB0AQASAAcJ+BnnBAB0AQAAAA==.',
['夏夕']='夏夕烟:BAAALgAFFAEJAQAAAA==.',
['夏末']='夏末呀:BAAALgAFFAIJAwAAAA==.夏末啊:BAAALgAFFAIJAwAAAA==.夏末阿:BAAALgAFFAIJAwAAAA==.',
['夏芽']='夏芽:BAAALgADCgEJAQAAAA==.',
['夜行']='夜行舞者:BAABLgAECn8aAAIEAAgJpwtMIgDmAQAEAAgJpwtMIgDmAQAAAA==.',
['太匆']='太匆匆丶:BAABLgAFFH8LAAIFAAQJRBixBQBvAQAFAAQJRBixBQBvAQAAAA==.',
['失心']='失心疯:BAAALgADCgEJAQAAAA==.',
['好牙']='好牙好胃口:BAABLgAFFH8KAAIGAAQJSRKCCwA9AQAGAAQJSRKCCwA9AQAAAA==.',
['婉若']='婉若游龙丶:BAABLgAFFH8NAAIFAAQJuBOCAgBEAQAFAAQJuBOCAgBEAQAAAA==.',
['婶气']='婶气死:BAAALgAECgUJBQAAAA==.',
['宇智']='宇智波泡泡:BAAALgAECgQJBAAAAA==.',
['安分']='安分守己灬法:BAAALgAECgYJDAAAAA==.安分守己灬猫:BAAALgAECgYJDwAAAA==.',
['安迪']='安迪斯丶血魔:BAAALgAECgUJBQAAAA==.',
['寂寞']='寂寞也狂欢:BAAALgAFFAIJBAAAAA==.',
['寥落']='寥落星辰:BAAALgAECgMJAwAAAA==.',
['小哔']='小哔哔:BAABLgAECn8VAAIEAAgJtxmoEQCTAgAEAAgJtxmoEQCTAgAAAA==.',
['小思']='小思绪:BAAALgADCgcJBwAAAA==.',
['小水']='小水母:BAAALgAECgUJBQAAAA==.',
['小玉']='小玉:BAAALgADCgUJDAAAAA==.',
['小绿']='小绿瓶:BAAALgAECgEJAQAAAA==.',
['小羊']='小羊苏西:BAAALgADCgUJCgAAAA==.',
['小黑']='小黑命贵:BAAALgAECgcJBwAAAA==.',
['尐乳']='尐乳豬:BAAALgAFFAIJAQAAAA==.',
['就差']='就差一丢丢儿:BAAALgAFFAMJAwAAAA==.',
['尽西']='尽西风:BAAALgAECgIJAgAAAA==.',
['帕拉']='帕拉丁的星火:BAAALgADCgQJBAAAAA==.',
['幽幽']='幽幽我芯:BAAALgAECgEJAgAAAA==.',
['幽西']='幽西:BAAALgADCgIJAgAAAA==.',
['开不']='开不了口:BAABLgAFFH8GAAMOAAIJjholGwCrAAAOAAIJjholGwCrAAAPAAEJkg8AAAAAAAABLgAFFAcJHgATAE0iAA==.',
['当年']='当年那瓶津威:BAAALgADCgEJAQAAAA==.',
['御坂']='御坂灬天使:BAACLgAFFH8PAAIUAAQJXyJ9BACcAQAUAAQJXyJ9BACcAQAuAAQKfxUAAhQACAkcI5oIAAgDABQACAkcI5oIAAgDAAAA.',
['德德']='德德派瑞瑞:BAAALgAECgMJAwAAAA==.',
['快带']='快带冯老师走:BAAALgAECgIJAgAAAA==.',
['怒涛']='怒涛卷霜雪:BAAALgADCgcJDQAAAA==.',
['思愁']='思愁小包:BAAALgAECgEJAQAAAA==.',
['怮傲']='怮傲孤訫:BAAALgAECgEJAQAAAA==.',
['惊现']='惊现麦田怪圈:BAAALgAECgYJBgABLgAFFAUJCwABAIoiAA==.',
['愚蠢']='愚蠢的狐狸:BAAALgAECggJEwAAAA==.',
['慕云']='慕云:BAAALgAECgQJBAAAAA==.',
['慕思']='慕思蛋糕:BAAALgAECgQJBwAAAA==.',
['慧宝']='慧宝宝:BAAALgADCgEJAQAAAA==.',
['懒得']='懒得起名:BAAALgAECgEJAgAAAA==.',
['我不']='我不当奶了:BAAALgAECgkJAgAAAA==.',
['我叫']='我叫为难:BAABLgAECn8gAAIHAAgJThsfCwBjAgAHAAgJThsfCwBjAgAAAA==.我叫牙套姐:BAAALgAFFAEJAQAAAA==.',
['我来']='我来背锅:BAAALgADCgYJBgAAAA==.',
['我菊']='我菊花有毒啊:BAAALgAECgYJDAAAAA==.',
['战殇']='战殇奥特曼:BAAALgAECgYJBgAAAA==.',
['托爾']='托爾斯泰:BAAALgAECgUJCAAAAA==.',
['执着']='执着丶为那爱:BAAALgAECgEJAQAAAA==.',
['扬幂']='扬幂:BAAALgAECgEJAQABLgAECgEJAgAJAAAAAA==.',
['抱着']='抱着你的树懒:BAAALgAFFAEJAQAAAA==.',
['拽拽']='拽拽的小肖:BAAALgAECgYJDQAAAA==.',
['拾分']='拾分熟:BAACLgAFFH8KAAIKAAMJ+xgxEQDgAAAKAAMJ+xgxEQDgAAAuAAQKfzAAAgoACAkTJLULAOICAAoACAkTJLULAOICAAAA.',
['断桥']='断桥雪:BAAALgAECgkJCQAAAA==.',
['无敌']='无敌和炉石:BAAALgADCgMJAwAAAA==.无敌狗狗酱:BAAALgAECgcJCAAAAA==.',
['旧城']='旧城以西:BAAALgAECgQJBQAAAA==.',
['星光']='星光下的流星:BAAALgAECgYJBwAAAA==.',
['星空']='星空下的麦田:BAACLgAFFH8LAAMBAAUJiiIsAwDzAQABAAUJiiIsAwDzAQACAAEJSRw4EwBYAAAuAAQKfx8AAwEACAl9IycaALgCAAEABwl9IycaALgCAAIAAgl2IcE+ALkAAAAA.',
['星辰']='星辰麦芽:BAAALgAECgUJBQAAAA==.',
['晚睡']='晚睡猫咪:BAAALgAECgYJCgAAAA==.',
['普罗']='普罗比斯:BAAALgAFFAEJAQAAAA==.',
['暗影']='暗影之主:BAAALgAECgEJBAAAAA==.',
['暗月']='暗月魔狼:BAAALgAECgYJCQAAAA==.',
['暗淡']='暗淡荧光:BAAALgADCgYJBgAAAA==.',
['暴走']='暴走皮皮虾:BAAALgAECgUJAQAAAA==.',
['月亮']='月亮代表我心:BAABLgAFFH8FAAIGAAIJcBR+GQCxAAAGAAIJcBR+GQCxAAAAAA==.月亮的死骑:BAABLgAFFH8GAAIRAAIJLhVAOACrAAARAAIJLhVAOACrAAAAAA==.',
['月白']='月白:BAAALgAECgEJAQAAAA==.',
['木丨']='木丨頭:BAAALgAECgcJEwAAAA==.',
['术术']='术术得氵正:BAAALgAECgEJAQAAAA==.',
['李刚']='李刚之女:BAAALgAECgYJBgAAAA==.',
['李小']='李小茗:BAAALgAECgYJBgAAAA==.',
['杰伦']='杰伦半岛铁盒:BAABLgAFFH8FAAIVAAUJ5gWfDQBjAQAVAAUJ5gWfDQBjAQAAAA==.',
['极光']='极光:BAAALgAECgEJAQAAAA==.',
['林花']='林花谢丶:BAABLgAFFH8GAAIFAAQJyBWNBgBdAQAFAAQJyBWNBgBdAQAAAA==.',
['桃花']='桃花糕:BAAALgAECgEJAgAAAA==.',
['桑尼']='桑尼小宝贝:BAAALgAECgIJAgAAAA==.',
['梅利']='梅利奥达斯:BAAALgADCgUJBQAAAA==.',
['梦辞']='梦辞:BAAALgAECgUJCQAAAA==.',
['橘子']='橘子汽水丷:BAAALgAFFAEJAQAAAA==.',
['此物']='此物与我有缘:BAAALgADCgYJBgAAAA==.',
['武器']='武器狂暴战:BAAALgAECgYJDAAAAA==.',
['武小']='武小妞:BAAALgAECgcJCAAAAA==.',
['毁灭']='毁灭祭奠:BAAALgAECgMJAwAAAA==.',
['水桶']='水桶小敏:BAAALgAECgEJAQAAAA==.',
['沐沐']='沐沐丶蔷:BAAALgAECgEJAQAAAA==.',
['没断']='没断嘚弦:BAAALgAECgcJEAAAAA==.',
['没有']='没有人:BAAALgAFFAEJAQAAAA==.',
['沧古']='沧古烟:BAAALgAECgIJAgAAAA==.',
['油猫']='油猫饼:BAAALgAFFAEJAQAAAA==.',
['法丶']='法丶殇:BAAALgAFFAEJAQAAAA==.',
['泽伊']='泽伊:BAAALgAFFAIJAwABLgAFFAIJBAAJAAAAAA==.',
['流风']='流风回雪丶:BAABLgAFFH8IAAIFAAQJBRP5BgBXAQAFAAQJBRP5BgBXAQAAAA==.流风幻葬:BAACLgAFFH8FAAIBAAIJ2w5iNgCmAAABAAIJ2w5iNgCmAAAuAAQKfx4ABAEACAmLFAJ/AF0BAAEABQkNGAJ/AF0BAAIAAwnFC507AMYAAAgAAQkAAF4qAEoAAAAA.',
['浩瀚']='浩瀚星宸:BAAALgAECgMJAwAAAA==.',
['浮云']='浮云若逝:BAAALgAFFAEJAQAAAA==.',
['满愿']='满愿:BAAALgAECgUJDgAAAA==.',
['漂亮']='漂亮牛仔裤:BAAALgAECgEJAgAAAA==.',
['火华']='火华:BAAALgAECgMJAwAAAA==.',
['熊丨']='熊丨猫灬抱抱:BAAALgAECgYJBgABLgAFFAQJDwAUAF8iAA==.',
['熊婷']='熊婷婷:BAAALgAECgQJBwAAAA==.',
['熹旧']='熹旧:BAAALgAECgYJBgAAAA==.',
['爱吃']='爱吃麻辣烫:BAAALgAECgYJBgAAAA==.',
['狂丶']='狂丶战:BAAALgAFFAEJAQAAAA==.',
['猎影']='猎影无痕:BAAALgAECgQJBwAAAA==.',
['猫污']='猫污污:BAAALgAECgMJAwABLgAFFAUJFgAMAGIbAA==.',
['猫猫']='猫猫战:BAAALgAECgQJBAAAAA==.',
['猫肉']='猫肉丸:BAAALgAFFAMJAwAAAA==.',
['猫贼']='猫贼:BAAALgAECgMJBAAAAA==.',
['玖玖']='玖玖捌拾肆:BAAALgADCgEJAQAAAA==.',
['玙卿']='玙卿的傲兲:BAABLgAFFH8JAAISAAMJIxzdBgD3AAASAAMJIxzdBgD3AAAAAA==.玙卿的恶僧:BAACLgAFFH8GAAIWAAMJgRYREgDrAAAWAAMJgRYREgDrAAAuAAQKfxYAAhYABwmhH5UWAFQCABYABwmhH5UWAFQCAAAA.玙卿的枭獣:BAAALgAECgIJAgAAAA==.玙卿的锤儿:BAAALgAECgIJAwAAAA==.',
['玛戈']='玛戈火热:BAACLgAFFH8IAAIGAAMJ9wsiLgD+AAAGAAMJ9wsiLgD+AAAuAAQKfxoAAgYABglcIShnAAkCAAYABglcIShnAAkCAAAA.玛戈雅利:BAABLgAFFH8FAAIBAAIJTQ2vGgCbAAABAAIJTQ2vGgCbAAAAAA==.',
['瓦丶']='瓦丶就打五个:BAABLgAECn8WAAQXAAgJWhDBCADfAAAYAAcJkQ/RTAByAQAXAAQJLRLBCADfAAASAAIJjAH1EwA2AAAAAA==.',
['生死']='生死一刹那:BAAALgAFFAIJAgAAAA==.',
['登峰']='登峰造极:BAAALgADCgEJAQAAAA==.',
['白玉']='白玉京三掌教:BAAALgAFFAEJAQAAAA==.',
['白鹤']='白鹤亮翅:BAABLgAECn8fAAMZAAgJdBSUHQDLAQAZAAgJdBSUHQDLAQAaAAUJBhBPRAAFAQAAAA==.',
['百丶']='百丶事:BAAALgAECgEJAgAAAA==.',
['盔盔']='盔盔:BAAALgAFFAIJBAAAAA==.',
['相学']='相学:BAAALgAECgYJEwAAAA==.',
['看眯']='看眯咪:BAACLgAFFH8MAAINAAQJYxuJAwBZAQANAAQJYxuJAwBZAQAuAAQKfxwAAg0ACAlFI+0DABgDAA0ACAlFI+0DABgDAAAA.',
['真龙']='真龙氵傲天:BAAALgAECgEJAQAAAA==.',
['眼神']='眼神很犀利:BAAALgAECgUJBQAAAA==.',
['矢泽']='矢泽妮可:BAAALgAECgEJAQAAAA==.',
['石山']='石山典:BAAALgADCgIJAgAAAA==.',
['碧雨']='碧雨小紫柳:BAAALgAECggJEQAAAA==.',
['秋珏']='秋珏枫:BAAALgADCgYJBgAAAA==.',
['种田']='种田梨沙:BAAALgAECgQJBAAAAA==.',
['稀饭']='稀饭灬:BAAALgAECgEJAgAAAA==.',
['空空']='空空感觉:BAAALgAECgkJCQAAAA==.',
['签签']='签签最好命:BAAALgAECgEJAQAAAA==.',
['管亥']='管亥苍天:BAAALgAECgcJCgAAAA==.',
['累了']='累了累了:BAAALgAECgYJCAAAAA==.',
['纹身']='纹身坏女孩:BAAALgAECgcJCAAAAA==.',
['绣虎']='绣虎:BAABLgAFFH8FAAMRAAUJTBpzEgBYAQARAAQJTBpzEgBYAQAHAAEJAACHEQBmAAAAAA==.',
['绯雪']='绯雪丨箴言:BAAALgADCgEJAQAAAA==.',
['缚魂']='缚魂:BAAALgAECgYJEAAAAA==.',
['美伊']='美伊阁诗人:BAAALgAECgEJAQAAAA==.',
['美梦']='美梦似路长:BAAALgAECgEJAQAAAA==.',
['翩丶']='翩丶跹:BAAALgAECgEJAgAAAA==.',
['翩若']='翩若惊鸿丶:BAABLgAFFH8FAAIGAAQJOQsmVABWAAAGAAQJOQsmVABWAAAAAA==.',
['老歪']='老歪:BAAALgADCgMJAwAAAA==.',
['耗子']='耗子欺负喵:BAAALgAFFAMJAwAAAA==.',
['致命']='致命的安静:BAABLgAECn8XAAMEAAgJtAf1JgDBAQAEAAgJfQf1JgDBAQADAAEJEwbmHwAzAAAAAA==.',
['航向']='航向月光:BAAALgAECgYJBwAAAA==.',
['艾瑞']='艾瑞利娅:BAAALgAECgcJDAABLgAFFAcJDQASAM4ZAA==.',
['艾菲']='艾菲尔丶织影:BAAALgAECgQJBQABLgAFFAQJDgAKAIYmAA==.',
['艾蕾']='艾蕾什基伽尔:BAAALgADCgUJBQAAAA==.',
['芒果']='芒果干:BAAALgAFFAEJAQAAAA==.',
['花想']='花想容丶:BAABLgAFFH8HAAIFAAQJsRdXBgBiAQAFAAQJsRdXBgBiAQAAAA==.',
['苍穹']='苍穹下的麦田:BAAALgAECgYJCwABLgAFFAUJCwABAIoiAA==.',
['莉丽']='莉丽安:BAAALgAECgMJBAAAAA==.',
['萨维']='萨维利亚:BAAALgADCgEJAQAAAA==.',
['落羽']='落羽成霜:BAAALgAECggJDAABLgAFFAUJCwABAJMZAA==.',
['蒙古']='蒙古上单:BAAALgAECgEJAQAAAA==.',
['蓝色']='蓝色小丑:BAABLgAECn8dAAIGAAgJhiM0EgA6AwAGAAgJhiM0EgA6AwAAAA==.蓝色的梦:BAAALgAECgEJAQAAAA==.',
['薛坤']='薛坤:BAAALgADCgUJBQAAAA==.',
['蘸血']='蘸血大黄瓜:BAAALgAECgEJAgAAAA==.',
['虚空']='虚空纟灵:BAAALgADCgUJBQAAAA==.',
['蚀墨']='蚀墨:BAAALgADCgcJDAAAAA==.',
['蛋定']='蛋定的蛋蛋:BAAALgADCgEJAQAAAA==.',
['蜜铃']='蜜铃兰丨梅蒂:BAACLgAFFH8OAAIKAAQJhiZ2AgDOAQAKAAQJhiZ2AgDOAQAuAAQKfxwAAgoACAnmJNwEAEADAAoACAnmJNwEAEADAAAA.',
['西瓜']='西瓜沙拉:BAAALgAECgEJAgAAAA==.',
['贪玩']='贪玩岚越:BAAALgAECgYJBgAAAA==.',
['超绝']='超绝大蟑螂:BAABLgAFFH8GAAIGAAIJtAv3QACsAAAGAAIJtAv3QACsAAAAAA==.',
['达瓦']='达瓦里氏:BAAALgAECgEJAwAAAA==.',
['迟钝']='迟钝酱:BAAALgAECgQJBAAAAA==.',
['追忆']='追忆赤信号:BAACLgAFFH8GAAIPAAMJVh0DCAAkAQAPAAMJVh0DCAAkAQAuAAQKfxYAAg8ACAmyIFkUAJQCAA8ACAmyIFkUAJQCAAAA.',
['逍遥']='逍遥仙:BAAALgADCgEJAgAAAA==.',
['邀玥']='邀玥:BAAALgAFFAIJAgAAAA==.',
['邓呆']='邓呆呆:BAAALgAECgYJCwAAAA==.',
['邪恶']='邪恶传承:BAAALgADCgUJBQAAAA==.',
['醉影']='醉影:BAAALgAECgYJAgAAAA==.',
['铁皮']='铁皮卡:BAAALgAFFAQJBAAAAA==.',
['闪光']='闪光的嘉特琳:BAAALgAECgEJAQAAAA==.',
['阿沙']='阿沙:BAACLgAFFH8JAAMRAAMJHhBjKgDxAAARAAMJHhBjKgDxAAAbAAIJWANbBABQAAAuAAQKfxkAAxEACAmiGWFFACUCABEACAlPGGFFACUCABsABAmaFj8NANoAAAAA.',
['阿砂']='阿砂:BAAALgAFFAEJAQAAAA==.',
['雪過']='雪過無痕:BAAALgAECgYJBwAAAA==.',
['雲中']='雲中歌灬:BAAALgADCgMJAwAAAA==.',
['雷迪']='雷迪波尔:BAAALgAECgEJAQAAAA==.',
['霍克']='霍克:BAAALgAECgMJBAAAAA==.',
['霜印']='霜印:BAABLgAECn8gAAIGAAgJ+RNabwD1AQAGAAgJ+RNabwD1AQAAAA==.',
['靓崽']='靓崽:BAAALgAECgYJCQAAAA==.',
['須佐']='須佐能乎:BAAALgAECgYJBwAAAA==.',
['風丨']='風丨舞:BAAALgAECgUJCAAAAA==.',
['风后']='风后奇门:BAAALgAECgYJBgAAAA==.',
['飛鳥']='飛鳥和游魚:BAAALgAECgUJCAAAAA==.',
['马尔']='马尔斯:BAAALgADCgEJAgAAAA==.',
['骑蜗']='骑蜗牛追母牛:BAAALgAECgUJBQAAAA==.',
['魔之']='魔之战九:BAAALgAECgUJBQAAAA==.',
['麦格']='麦格丶风行者:BAAALgAECgEJAQAAAA==.',
['麻薯']='麻薯墩砸:BAAALgAECgQJBAAAAA==.',
['黑山']='黑山羊:BAAALgAECgYJBgAAAA==.',
['黑鍋']='黑鍋丨我来背:BAAALgAECgYJDAAAAA==.',
['龙傲']='龙傲天:BAAALgAECgcJBgABLgAFFAYJDQAVAAAcAA==.',
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
