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

local lookup = {'Paladin-Retribution','Priest-Holy','Priest-Discipline','Mage-Frost','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Rogue-Outlaw','Druid-Balance','Paladin-Holy','DeathKnight-Unholy','Druid-Restoration','DemonHunter-Devourer','DemonHunter-Havoc','Hunter-Survival','Hunter-Marksmanship','Hunter-BeastMastery','Evoker-Devastation','Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood',}
local provider = {region='CN',realm='凯尔萨斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Battlemage:BAAALgADCgIJAgAAAA==.',
Bo='Booty:BAAALgADCgUJBQAAAA==.',
Di='Divinecomedy:BAAALgAECgcJAwABLgAFFAQJBQABAHoEAA==.',
Ed='Eden:BAABLgAECn8UAAMCAAcJRxvNGQANAgACAAcJRxvNGQANAgADAAQJJgtMWAAxAAAAAA==.',
Ev='Everest:BAAALgAECgcJCAAAAA==.',
Ho='Hozumi:BAAALgAECgcJCgAAAA==.',
Ii='Iiluthian:BAABLgAFFH8GAAIEAAQJehKaGQBkAQAEAAQJehKaGQBkAQAAAA==.',
Ka='Kakaru:BAAALgAFFAEJAQAAAA==.Kakkin:BAAALgAECgkJBwAAAA==.Karkin:BAAALgAECgkJCQAAAA==.',
Kh='Khaleesi:BAAALgAECgEJAwAAAA==.',
Li='Liang:BAAALgAECgEJAgAAAA==.Lightcow:BAAALgAECgQJBAAAAA==.',
Ma='Makko:BAAALgADCgEJAQAAAA==.Maxto:BAAALgAECgEJAQAAAA==.',
Me='Mengde:BAAALgAECgMJAwABLgAECgkJBgAFAAAAAA==.',
Pa='Pazhani:BAACLgAFFH8QAAMGAAUJGh+9AQDeAQAGAAUJGh+9AQDeAQAHAAEJzxHiHABOAAAuAAQKfywAAwYACQlLImwGAAwDAAYACQlLImwGAAwDAAcABQl9E3JVAO8AAAAA.',
Sk='Skyla:BAAALgADCgYJBgAAAA==.',
Th='Thunderstorm:BAABLgAFFH8HAAIHAAQJEhGhCgA7AQAHAAQJEhGhCgA7AQAAAA==.',
Tt='Ttyreal:BAAALgAECgUJCAAAAA==.',
Wi='Wilburuncle:BAAALgAFFAEJAQAAAA==.Wilburunlce:BAAALgADCgEJAQABLgAFFAEJAQAFAAAAAA==.',
Wz='Wzq:BAAALgADCgQJBAAAAA==.',
Zi='Zip:BAAALgAECgEJAQAAAA==.',
['一剑']='一剑倾橙:BAAALgAFFAQJBAAAAA==.',
['一淡']='一淡泊一:BAAALgADCgEJAQAAAA==.',
['一相']='一相随一:BAAALgADCgYJDgAAAA==.',
['一箭']='一箭绝尘:BAAALgADCgUJBQAAAA==.',
['上九']='上九天捉鳖:BAAALgAECggJCAAAAA==.',
['不忘']='不忘初心丶:BAAALgADCgUJBQAAAA==.',
['丰川']='丰川祥子:BAAALgAECgQJBgAAAA==.',
['乖乖']='乖乖站好:BAAALgAECgEJAQAAAA==.',
['乖猫']='乖猫儿:BAAALgAECgYJBgAAAA==.',
['亡流']='亡流星:BAAALgAECgQJBAABLgAECggJGAABABMbAA==.',
['伊鲁']='伊鲁鲁德:BAAALgAFFAUJAgAAAA==.',
['低调']='低调羊肉串:BAAALgAECgcJAQAAAA==.',
['何物']='何物为真:BAABLgAECn8dAAIIAAgJ2xyKAQDDAgAIAAgJ2xyKAQDDAgAAAA==.',
['佛前']='佛前莲花开:BAAALgAECgEJAQAAAA==.',
['修利']='修利阿多雷德:BAAALgAECgkJCAABLgAFFAQJDAAGAAYlAA==.',
['傻傻']='傻傻德:BAABLgAECn8WAAIJAAYJ+RexKwCkAQAJAAYJ+RexKwCkAQAAAA==.',
['光光']='光光:BAAALgAFFAIJAwAAAA==.',
['光天']='光天化日:BAAALgAECgkJCQAAAA==.',
['兵疯']='兵疯王座:BAAALgAECgMJAwAAAA==.',
['冥界']='冥界猎魂:BAAALgAECgYJBgAAAA==.',
['冯爷']='冯爷爷玩粑粑:BAAALgAECgQJBgAAAA==.',
['冰冰']='冰冰丶神圣:BAAALgAECgEJAQAAAA==.',
['凤飘']='凤飘飘:BAAALgADCgMJAwAAAA==.',
['别送']='别送:BAAALgAFFAEJAQAAAA==.',
['北斗']='北斗神犬:BAAALgAECgYJEwAAAA==.',
['千年']='千年老妖:BAAALgAECgIJAgAAAA==.',
['南鸢']='南鸢北笙:BAAALgAECgYJCQAAAA==.',
['又湿']='又湿手了:BAAALgAFFAEJAQAAAA==.',
['叶良']='叶良辰丶:BAAALgAECgUJBwAAAA==.',
['叶落']='叶落清风丶:BAABLgAFFH8FAAIEAAMJEhtsFwC8AAAEAAMJEhtsFwC8AAAAAA==.',
['吉侒']='吉侒娜:BAAALgAECgYJEQAAAA==.',
['君子']='君子之怒:BAAALgAECgMJAwAAAA==.',
['咖啡']='咖啡加奶:BAAALgAECgIJAQAAAA==.',
['喷火']='喷火器:BAAALgADCgIJAgAAAA==.',
['嗷呜']='嗷呜咆哮:BAAALgAECgYJBgAAAA==.',
['四千']='四千分神牛:BAAALgAECgMJAwAAAA==.',
['土土']='土土僧:BAAALgADCgEJAQAAAA==.',
['圣三']='圣三娘:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光之风:BAAALgAECgYJCwAAAA==.',
['夜空']='夜空星尘:BAAALgAECgcJCQAAAA==.',
['大肥']='大肥龙猫:BAAALgADCgcJBwAAAA==.',
['大道']='大道无痕:BAAALgAFFAMJBAAAAA==.',
['天之']='天之流浪:BAABLgAECn8UAAMKAAgJQRYbHAA0AgAKAAgJQRYbHAA0AgABAAMJ4AJuJwFRAAAAAA==.',
['夫风']='夫风者:BAAALgAECgMJAwAAAA==.',
['奥罗']='奥罗萨拉塔斯:BAAALgAECgIJAQAAAA==.',
['女的']='女的叫織女:BAAALgAECgEJAQAAAA==.',
['奶满']='奶满人间:BAAALgAECgYJDwAAAA==.',
['奶萨']='奶萨组吗:BAABLgAFFH8FAAIGAAUJ7yFEAAAPAgAGAAUJ7yFEAAAPAgAAAA==.',
['好多']='好多熊猫:BAAALgAECgEJAQAAAA==.',
['如梦']='如梦飞雪:BAABLgAECn8UAAIGAAgJewsKVwArAQAGAAgJewsKVwArAQAAAA==.',
['婷不']='婷不下来:BAAALgAFFAIJAgAAAA==.',
['嫂子']='嫂子你好香:BAAALgAECgMJAwAAAA==.',
['孔明']='孔明:BAAALgAECgIJAwAAAA==.',
['宁寂']='宁寂的春梦:BAAALgAECgMJBAAAAA==.',
['宇宙']='宇宙大帝:BAAALgAECgcJCAAAAA==.',
['安娜']='安娜的玫瑰:BAAALgAECgQJBAAAAA==.安娜的蓉儿:BAAALgAECgEJAgAAAA==.',
['封火']='封火沙包:BAACLgAFFH8FAAIEAAMJqBRCKQAPAQAEAAMJqBRCKQAPAQAuAAQKfxsAAgQABwkxHe5HAF8CAAQABwkxHe5HAF8CAAAA.',
['就是']='就是橘子:BAAALgAECgcJEQAAAA==.',
['希夏']='希夏邦马:BAAALgAECgYJCAAAAA==.',
['帝慕']='帝慕:BAAALgADCgIJAgAAAA==.',
['帝璐']='帝璐:BAABLgAFFH8FAAILAAMJWRVaKAD3AAALAAMJWRVaKAD3AAAAAA==.',
['帝辰']='帝辰:BAAALgADCgEJAQAAAA==.',
['幼又']='幼又柚:BAABLgAFFH8HAAIMAAMJHQlOEwDOAAAMAAMJHQlOEwDOAAAAAA==.',
['当心']='当心我拦截你:BAAALgADCgIJAgAAAA==.当心我诅咒你:BAAALgADCgUJBQAAAA==.',
['彦啊']='彦啊:BAAALgAECgQJAQAAAA==.',
['微波']='微波炉:BAAALgADCgYJBgAAAA==.',
['念头']='念头通达:BAAALgAECgEJAQAAAA==.',
['思吟']='思吟:BAAALgAFFAIJAwAAAA==.',
['怼怼']='怼怼:BAAALgADCgYJBgAAAA==.',
['想来']='想来一发么:BAAALgAECgcJBwAAAA==.',
['我又']='我又不瞎:BAAALgAFFAQJBAABLgAFFAYJAgAFAAAAAA==.',
['我有']='我有小目标:BAABLgAFFH8IAAIEAAMJQg2/LgD8AAAEAAMJQg2/LgD8AAAAAA==.',
['持愿']='持愿追梦:BAAALgAECgcJCQAAAA==.',
['指上']='指上谈冰:BAAALgAECgUJAwAAAA==.',
['提里']='提里奥马丁:BAAALgAECgYJDgAAAA==.',
['新梅']='新梅煮酒:BAAALgAECgQJBAAAAA==.',
['无偿']='无偿献血:BAAALgAECgMJAwAAAA==.',
['无情']='无情剑客:BAAALgAECgEJAQAAAA==.',
['时尚']='时尚双马尾:BAAALgAECgYJAQAAAA==.',
['星术']='星术埃兰:BAAALgAFFAEJAQAAAA==.',
['星炎']='星炎羊肉串:BAAALgAECgcJEAAAAA==.',
['春雪']='春雪:BAAALgAECgEJAQAAAA==.',
['是夏']='是夏夏呀:BAAALgAECgYJBwAAAA==.',
['晚安']='晚安:BAAALgAECgYJCAAAAA==.',
['普琳']='普琳:BAABLgAECn8bAAIBAAgJtBprRwANAgABAAgJtBprRwANAgAAAA==.',
['暗歌']='暗歌追影:BAABLgAECn8cAAMNAAcJ/hceQAD0AQANAAcJ0hceQAD0AQAOAAYJ6wxnNwAoAQAAAA==.',
['暗羽']='暗羽点点:BAABLgAFFH8GAAIEAAIJwAcmRACnAAAEAAIJwAcmRACnAAAAAA==.',
['暴走']='暴走的幸运鹅:BAAALgAECgYJCQAAAA==.',
['月眉']='月眉与瞳:BAAALgAECgUJBQAAAA==.',
['朗朗']='朗朗乾坤:BAAALgAECgkJCQAAAA==.',
['朦胧']='朦胧鸟:BAAALgADCgYJCwAAAA==.',
['末丶']='末丶洛:BAAALgAECggJEgABLgAFFAUJDgABAE4mAA==.',
['李有']='李有药药:BAAALgAECgIJAgAAAA==.',
['李李']='李李有病:BAAALgADCgcJBwAAAA==.',
['杨萌']='杨萌彤橙:BAAALgAECgYJCgAAAA==.',
['杭州']='杭州小伙:BAAALgAECgYJBgAAAA==.',
['栗子']='栗子馒头:BAAALgAECgYJBwAAAA==.',
['梅琳']='梅琳娜的锋刃:BAACLgAFFH8KAAQPAAQJbxNJAQBlAQAPAAQJDhJJAQBlAQAQAAMJTANrGADMAAARAAEJWxEuJQBWAAAuAAQKfycAAw8ACAkzHcEDAOYCAA8ACAkzHcEDAOYCABAABwl5FWMuALwBAAAA.',
['梦幻']='梦幻紫精灵:BAAALgADCgMJAwAAAA==.',
['梦恴']='梦恴:BAAALgAECgkJBgAAAA==.',
['此人']='此人绝非扇贝:BAAALgAFFAEJAQAAAA==.',
['死亡']='死亡猫猫:BAAALgAECgQJBAAAAA==.',
['殇之']='殇之幻灭:BAAALgAECgcJEwAAAA==.',
['没事']='没事喝两口:BAAALgAECgkJCQAAAA==.',
['没有']='没有尾巴了:BAAALgAECgEJAQAAAA==.',
['河乌']='河乌宝宝:BAAALgAECgkJAQABLgAECggJHQASADgZAA==.',
['法你']='法你老味:BAAALgAFFAEJAQAAAA==.',
['泡椒']='泡椒煮茶:BAAALgAECgYJCQAAAA==.',
['泰格']='泰格尔:BAAALgAECgEJAQAAAA==.',
['浪子']='浪子变酷了:BAAALgAECgUJBQAAAA==.',
['浪羽']='浪羽暗:BAAALgADCgMJAgAAAA==.',
['浮夸']='浮夸小斗士:BAAALgAECgEJAQAAAA==.',
['清月']='清月如默笙:BAAALgAFFAIJBAAAAA==.',
['清源']='清源:BAAALgAECgEJAQAAAA==.',
['渡边']='渡边曜:BAAALgAECgkJCQAAAA==.',
['潘甜']='潘甜妞:BAAALgAECgIJAgAAAA==.',
['炒鸡']='炒鸡蛋:BAAALgAECgEJAQAAAA==.',
['烽火']='烽火三月:BAAALgAECgYJEwAAAA==.',
['爱我']='爱我非你莫属:BAAALgAECgUJBQAAAA==.',
['牛少']='牛少雄起:BAAALgAECgYJCQAAAA==.',
['狂奔']='狂奔的青竹标:BAAALgAECgUJCQAAAA==.',
['狂野']='狂野的西瓜:BAAALgAECgcJCgAAAA==.',
['狂霸']='狂霸拽酷炫:BAAALgAECgIJAgAAAA==.',
['猪儿']='猪儿飘飘:BAAALgAECgQJCAAAAA==.',
['猫咪']='猫咪雅玛:BAAALgADCgIJAgAAAA==.',
['猫鱼']='猫鱼:BAAALgAFFAIJBAAAAA==.',
['玛丹']='玛丹特:BAAALgAFFAEJAQABLgAFFAQJDAAGAAYlAA==.',
['珏影']='珏影:BAAALgAECgYJEwAAAA==.',
['瓦尔']='瓦尔瑟拉:BAAALgADCgEJAQAAAA==.',
['疯暴']='疯暴烈酒:BAAALgAECgQJBAAAAA==.',
['百鬼']='百鬼飚:BAAALgADCgEJAQAAAA==.',
['皇家']='皇家炼油厂:BAAALgAECgEJAQAAAA==.',
['皮卡']='皮卡丘:BAAALgADCgEJAQAAAA==.',
['盘古']='盘古之斧:BAAALgAECgQJBAAAAA==.',
['相随']='相随丶:BAAALgAECgIJAgAAAA==.',
['盾妞']='盾妞:BAAALgAECgEJAQAAAA==.',
['瞎看']='瞎看神马:BAAALgAECgYJEQAAAA==.',
['矮木']='矮木瓜:BAAALgADCgQJBAAAAA==.',
['石头']='石头姣姣:BAAALgAECgYJBgAAAA==.',
['社长']='社长丿:BAAALgAECgcJBwAAAA==.',
['神速']='神速杜巴莉:BAAALgAECgYJBwAAAA==.',
['窗外']='窗外的小西瓜:BAAALgAECgcJBwABLgAFFAIJBAAFAAAAAA==.',
['立棍']='立棍单打:BAAALgAECgQJBAAAAA==.',
['筱幽']='筱幽幽:BAAALgADCgEJAQAAAA==.',
['箭在']='箭在弦上:BAAALgAECgIJBAAAAA==.',
['米奈']='米奈希尔之光:BAAALgADCgEJAQAAAA==.',
['米里']='米里亚:BAAALgADCgQJBAAAAA==.',
['紫默']='紫默凡尘:BAAALgAECgEJAgAAAA==.',
['红心']='红心番石榴:BAAALgAECgkJCQAAAA==.',
['红月']='红月的幽影:BAABLgAECn8VAAMQAAcJAhL7MwCZAQAQAAcJQhH7MwCZAQARAAYJDgpdeQD7AAAAAA==.',
['红色']='红色小萌龙:BAAALgAECgcJBQAAAA==.',
['给力']='给力不呀哈哈:BAABLgAECn8WAAIPAAcJ4iFlCABkAgAPAAcJ4iFlCABkAgAAAA==.',
['翻新']='翻新老爷车:BAAALgAECgEJAQAAAA==.',
['老老']='老老萌新:BAAALgAECgEJAgAAAA==.',
['胆小']='胆小的猪儿虫:BAAALgAECgcJCwAAAA==.',
['胸悍']='胸悍湿三妹:BAAALgAFFAIJAgAAAA==.',
['致丶']='致丶往昔:BAAALgAECgEJAQAAAA==.',
['艾米']='艾米绿亚:BAAALgAECgYJCAAAAA==.',
['莉丝']='莉丝亚尔珍特:BAACLgAFFH8MAAIGAAQJBiXYAgCxAQAGAAQJBiXYAgCxAQAuAAQKfx0AAgYACAlyJqoBAHcDAAYACAlyJqoBAHcDAAAA.',
['落清']='落清虚:BAAALgAECgMJBgAAAA==.',
['蒹葭']='蒹葭苍苍:BAAALgAECgkJCQAAAA==.蒹葭萋萋:BAAALgAECgMJAwAAAA==.',
['薇塔']='薇塔克洛提德:BAAALgADCgcJBwABLgAFFAQJDAAGAAYlAA==.',
['街角']='街角丨死骑:BAABLgAFFH8IAAILAAMJ2BoSIgAPAQALAAMJ2BoSIgAPAQAAAA==.',
['贪玩']='贪玩的瓦娜斯:BAAALgAECgQJBQAAAA==.',
['赤王']='赤王:BAAALgADCgcJAQAAAA==.',
['迁亿']='迁亿:BAABLgAECn8UAAMTAAcJaQ1ieQBpAQATAAcJUwxieQBpAQAUAAIJrAvoWABkAAAAAA==.',
['迟早']='迟早腱鞘炎:BAACLgAFFH8GAAMVAAMJoBq3AgAIAQAWAAMJoBq8DAAaAQAVAAMJUg63AgAIAQAuAAQKfxsABBUACAk2HW0EAGYCABUABwmeG20EAGYCABYABglxHF4jAN4BAAgABQl2ILMGAEwBAAAA.',
['迷失']='迷失孤寂:BAAALgAECgEJAQAAAA==.',
['道可']='道可名:BAABLgAECn8XAAIBAAcJug8yewCEAQABAAcJug8yewCEAQAAAA==.',
['邪恶']='邪恶小熊丶:BAAALgAECgYJBwAAAA==.',
['都是']='都是我的错咯:BAABLgAECn8UAAIBAAcJAxLlbgCfAQABAAcJAxLlbgCfAQAAAA==.',
['酷盖']='酷盖儿:BAAALgADCgIJAgAAAA==.',
['醉裡']='醉裡挑燈看劍:BAAALgAFFAIJBAAAAA==.',
['野性']='野性奶糖:BAAALgAECgcJCQAAAA==.',
['錵錵']='錵錵的春天:BAAALgADCgUJBQAAAA==.',
['鎏灬']='鎏灬薇薇:BAAALgAECgEJAQAAAA==.',
['锈迹']='锈迹斑斑:BAAALgAECgQJAQAAAA==.',
['长泽']='长泽雅美:BAAALgADCgEJAQAAAA==.',
['长风']='长风破刃:BAAALgADCgEJAQAAAA==.',
['阿克']='阿克曼丶:BAAALgAECgQJBAAAAA==.',
['陈渔']='陈渔:BAAALgAECgYJCgAAAA==.',
['院长']='院长:BAAALgAECgYJEQAAAA==.',
['雲帆']='雲帆:BAAALgADCgIJAgAAAA==.',
['面团']='面团零零九:BAAALgAECgEJAQAAAA==.面团零零二:BAABLgAFFH8GAAMCAAMJ4B6zBgANAQACAAMJuh2zBgANAQADAAIJ1Rj0EQCnAAAAAA==.',
['韦伯']='韦伯大叔:BAAALgAECggJCwABLgAFFAEJAQAFAAAAAA==.',
['风城']='风城雪月:BAAALgADCgMJAwAAAA==.',
['风声']='风声:BAAALgADCgcJBwAAAA==.',
['风月']='风月的拂晓:BAAALgAECgQJBAABLgAFFAIJBAAFAAAAAA==.风月的薄暮:BAABLgAECn8cAAMLAAcJzRqMZADGAQALAAYJ6BmMZADGAQAXAAcJ8Q20HgBRAQAAAA==.',
['风花']='风花雪:BAAALgAECgUJCQAAAA==.',
['风语']='风语月牙:BAAALgAECgMJBAAAAA==.',
['风韵']='风韵犹存:BAAALgADCgkJCgAAAA==.',
['骑你']='骑你老味:BAAALgAECgMJAwAAAA==.',
['骑士']='骑士的黄昏:BAAALgAFFAIJAgAAAA==.',
['鬼冢']='鬼冢英吉:BAAALgAECgIJAgAAAA==.',
['魏武']='魏武流觞:BAAALgAECgYJBgAAAA==.',
['魔伊']='魔伊:BAAALgAFFAMJBAAAAA==.',
['魔艺']='魔艺:BAAALgAECgIJAgAAAA==.',
['鹿贺']='鹿贺凛:BAAALgAECgYJBgAAAA==.',
['黑暗']='黑暗魔尊:BAAALgAECgUJBQAAAA==.',
['黑曜']='黑曜石小萌德:BAAALgADCgcJBwAAAA==.',
['龙川']='龙川小宇:BAAALgADCgQJBAAAAA==.',
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
