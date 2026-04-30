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

local lookup = {'Evoker-Preservation','Shaman-Restoration','Shaman-Elemental','Evoker-Augmentation','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Hunter-Survival','Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Monk-Brewmaster','Hunter-BeastMastery','DemonHunter-Devourer','Monk-Windwalker','Monk-Mistweaver','Druid-Restoration','DeathKnight-Blood','Priest-Discipline','Priest-Shadow','DemonHunter-Havoc','Priest-Holy','Mage-Arcane','Warrior-Fury','Paladin-Holy','Hunter-Marksmanship','Evoker-Devastation','DemonHunter-Vengeance',}
local provider = {region='CN',realm='晴日峰（江苏）',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adelefans:BAAALgAECgMJAwAAAA==.',
As='Asam:BAACLgAFFH8FAAIBAAIJjRtzEgCaAAABAAIJjRtzEgCaAAAuAAQKfyEAAgEABwk4IzwHAMsCAAEABwk4IzwHAMsCAAAA.',
Be='Bevelo:BAAALgAECgYJDwAAAA==.',
Ci='Cinnamongirl:BAAALgAECgcJBQAAAA==.',
Co='Coffeewater:BAABLgAFFH8IAAICAAQJaxkWBABOAQACAAQJaxkWBABOAQAAAA==.',
Dh='Dhunter:BAAALgAECgEJAQAAAA==.',
Dk='Dk:BAAALgAECgEJAQAAAA==.',
Do='Donquijote:BAAALgADCgUJBQAAAA==.',
Et='Eteraveller:BAAALgAECgUJBQAAAA==.Etherealrhea:BAABLgAECn8YAAMCAAcJABzJIQAUAgACAAcJABzJIQAUAgADAAEJEQQijgAqAAAAAA==.',
Gr='Grape:BAAALgAECgIJBAAAAA==.',
Io='Iosm:BAAALgAECgkJEAAAAA==.',
Ko='Kodiak:BAAALgAECgQJBAAAAA==.Kolve:BAAALgAECgEJAQAAAA==.',
Mn='Mnemosyne:BAAALgADCgUJBQAAAA==.',
Ne='Nemoy:BAAALgADCggJCgAAAA==.',
Nt='Ntsd:BAAALgAECgUJBQAAAA==.',
Pe='Pewpew:BAAALgAECgUJCwAAAA==.',
Po='Pojun:BAAALgAECgkJEgAAAA==.',
Pu='Purpurrea:BAAALgAECgEJAQAAAA==.',
Re='Redclover:BAAALgADCgEJAQAAAA==.',
Sq='Sqere:BAAALgAECgUJBQAAAA==.Sque:BAAALgAECgEJAQAAAA==.',
Ta='Talulah:BAACLgAFFH8LAAIBAAQJtRwNCABqAQABAAQJtRwNCABqAQAuAAQKfyAAAwEACAleIA0GAOQCAAEACAleIA0GAOQCAAQAAwnvGE5CANkAAAAA.',
Vl='Vladilena:BAAALgAECgYJEwABLgAFFAQJDQAFANsjAA==.',
Wa='Warricc:BAAALgADCgYJBgAAAA==.',
Wh='Whiteyes:BAAALgAECgYJBgAAAA==.',
Wi='Wide:BAABLgAFFH8JAAMDAAQJuRAeCwA3AQADAAQJuRAeCwA3AQACAAEJDxCLIwBGAAAAAA==.',
Xt='Xtksixxaggpl:BAAALgAFFAQJBAAAAA==.',
Ya='Yamagata:BAAALgAECgQJCAAAAA==.',
Yt='Ytwqs:BAAALgAFFAIJBAAAAA==.',
['一刀']='一刀萌哒哒:BAAALgAECgQJCQAAAA==.',
['一到']='一到晚上就馋:BAAALgAECgIJAgAAAA==.',
['一只']='一只大松狮:BAAALgAECgEJAgAAAA==.一只巨熊:BAAALgAECgUJBwAAAA==.',
['一囡']='一囡囡一:BAAALgAECgcJEQAAAA==.',
['一梦']='一梦解千愁:BAAALgAECgIJAgAAAA==.',
['一点']='一点点晚风:BAAALgAECgEJAgAAAA==.',
['一笑']='一笑春风暖:BAAALgADCgMJAwAAAA==.',
['一萨']='一萨拉塔斯一:BAAALgAECgEJAQAAAA==.一萨鲁法尔一:BAAALgAFFAIJAwAAAA==.',
['一跃']='一跃跳上屋顶:BAAALgAFFAEJAQAAAA==.',
['一辆']='一辆小肥猫:BAABLgAFFH8NAAMGAAQJ1B3NBQBnAQAGAAQJ1B3NBQBnAQAHAAEJpwaMGABNAAAAAA==.一辆小龙猫:BAAALgAECgMJAwAAAA==.',
['万物']='万物一心:BAACLgAFFH8MAAIIAAQJIxM5AQBrAQAIAAQJIxM5AQBrAQAuAAQKfxQAAggABwncGqoLABcCAAgABwncGqoLABcCAAAA.',
['三倍']='三倍厚薯片:BAAALgAFFAEJAQAAAA==.',
['三合']='三合大师:BAAALgAECgIJAgAAAA==.',
['不共']='不共享充电宝:BAAALgAECgUJCAAAAA==.',
['不可']='不可能奶的:BAAALgAECgIJAgAAAA==.',
['不想']='不想回家:BAAALgAECgYJDwAAAA==.',
['不朽']='不朽冥魂大帝:BAAALgAECgEJAQAAAA==.',
['专干']='专干天尊:BAAALgAFFAEJAQAAAA==.',
['东方']='东方神韵:BAAALgAECgcJCgAAAA==.',
['两斤']='两斤羊肉:BAAALgAECgMJBAAAAA==.',
['丨貓']='丨貓爺灬:BAAALgAECgEJAQAAAA==.',
['中核']='中核:BAAALgADCgIJAQAAAA==.',
['中门']='中门对狙:BAAALgAECgYJCwAAAA==.',
['丶魅']='丶魅影丶:BAAALgADCgUJBQAAAA==.',
['丷乐']='丷乐多:BAAALgAECgkJAgAAAA==.',
['为啥']='为啥是个球啊:BAAALgADCgcJBwAAAA==.',
['久幺']='久幺九:BAAALgADCgEJAQAAAA==.',
['乌云']='乌云蛮蛮:BAAALgAECgQJBAABLgAECgUJBgAJAAAAAA==.',
['九转']='九转魔地藏:BAAALgADCgcJCAAAAA==.',
['乱锤']='乱锤:BAAALgAECgMJBgAAAA==.',
['云曦']='云曦:BAAALgAECgQJBQAAAA==.',
['亚人']='亚人人:BAAALgAECgEJAQAAAA==.',
['亲力']='亲力亲为:BAAALgADCgEJAQAAAA==.',
['亲爱']='亲爱的八大爷:BAAALgAECgcJDQAAAA==.',
['任平']='任平生丶:BAAALgAFFAEJAQAAAA==.',
['伐木']='伐木工:BAAALgADCgcJDgAAAA==.',
['优湖']='优湖骁:BAAALgAECgcJBwAAAA==.',
['何事']='何事二:BAABLgAECn8dAAIKAAkJKhzhFQD5AgAKAAkJKhzhFQD5AgABLgAFFAQJBgAKAL0YAA==.',
['余生']='余生的依赖:BAAALgAECgkJDgAAAA==.',
['你的']='你的骑士:BAABLgAECn8XAAILAAcJaA2LKAAsAQALAAcJaA2LKAAsAQAAAA==.',
['你老']='你老婆会漏气:BAAALgADCgIJAQABLgAFFAQJCAAKAHsUAA==.',
['你还']='你还好:BAAALgADCgcJCgAAAA==.',
['光合']='光合作用:BAAALgAECgYJCgAAAA==.',
['克己']='克己慎独:BAAALgADCggJCAAAAA==.',
['兜兜']='兜兜里没糖喔:BAAALgAECgcJCgAAAA==.',
['全身']='全身柔式油压:BAAALgAECgUJBwAAAA==.',
['兴杰']='兴杰建材:BAAALgADCggJCAAAAA==.',
['冫中']='冫中钅:BAAALgAECgQJBwAAAA==.',
['冰噹']='冰噹噹:BAAALgADCgEJAQAAAA==.',
['冰镇']='冰镇可乐:BAAALgAECgEJAQAAAA==.',
['冲丨']='冲丨锋:BAAALgAECgQJBQAAAA==.',
['凛风']='凛风儿:BAABLgAFFH8JAAIMAAUJZhUdCQBmAQAMAAUJZhUdCQBmAQAAAA==.',
['凤舞']='凤舞芷若:BAAALgAECgQJBQAAAA==.',
['凶吗']='凶吗:BAAALgAFFAIJAwAAAA==.',
['刃杀']='刃杀:BAAALgAECgYJCwAAAA==.',
['别跟']='别跟我玩眼神:BAAALgAECgEJAQAAAA==.',
['剑心']='剑心犹在:BAAALgAECgYJDAAAAA==.',
['加个']='加个钟:BAABLgAFFH8IAAINAAMJVw8dEACRAAANAAMJVw8dEACRAAAAAA==.',
['千万']='千万别喝假酒:BAAALgAECgQJCAAAAA==.',
['半城']='半城残雪:BAAALgADCgYJBgAAAA==.',
['单刀']='单刀张大爷:BAABLgAFFH8LAAIGAAcJrQQFAgCfAQAGAAcJrQQFAgCfAQAAAA==.',
['单涣']='单涣:BAAALgAECgUJBQAAAA==.',
['单豢']='单豢:BAAALgAFFAEJAQAAAA==.',
['南通']='南通保镖:BAAALgADCgEJAQAAAA==.',
['卷卷']='卷卷啊卷:BAABLgAFFH8GAAIOAAMJpBaYCgANAQAOAAMJpBaYCgANAQAAAA==.',
['厕所']='厕所里唱歌:BAAALgADCgQJBQAAAA==.',
['去吧']='去吧丶小火龙:BAAALgAECgQJBAAAAA==.',
['双枪']='双枪李奶奶:BAAALgAECgYJDAAAAA==.',
['反重']='反重力苹果:BAAALgAECgQJBAAAAA==.',
['发糖']='发糖的炒饭:BAAALgAECgYJCQAAAA==.',
['叔叔']='叔叔给你糖:BAAALgAECgYJBwAAAA==.',
['古明']='古明地空:BAAALgAECgYJDQAAAA==.',
['古灵']='古灵精怪:BAAALgAECgQJAwAAAA==.',
['叫我']='叫我史亦凡:BAAALgAECgQJAQAAAA==.',
['吃肉']='吃肉:BAAALgAECgcJEQAAAA==.',
['吃薯']='吃薯条不蘸酱:BAAALgAECgYJCgAAAA==.',
['吃饭']='吃饭别出声:BAAALgAFFAMJBAAAAA==.',
['各路']='各路吗什:BAAALgAECgkJBAAAAA==.',
['吕清']='吕清玄:BAAALgAECgIJAwAAAA==.',
['吞噬']='吞噬:BAAALgAFFAIJAgABLgAFFAMJBAAJAAAAAA==.',
['咣当']='咣当:BAABLgAFFH8GAAILAAMJVhbeEwAIAQALAAMJVhbeEwAIAQAAAA==.',
['哈基']='哈基尼:BAAALgADCgIJAgAAAA==.哈基牛我们上:BAAALgAECgYJDAAAAA==.',
['哒哒']='哒哒嘿:BAAALgADCgEJAQAAAA==.',
['哟灬']='哟灬一库:BAAALgAECgEJAQAAAA==.',
['哼叽']='哼叽叽:BAAALgAECgcJDQAAAA==.',
['善喜']='善喜:BAAALgAECgEJAQAAAA==.',
['喜欢']='喜欢寂寞:BAAALgAECgYJEgAAAA==.',
['喝酒']='喝酒纹身打架:BAAALgAECgYJBgABLgAECgYJCgAJAAAAAA==.',
['喵苗']='喵苗儿:BAAALgAECgIJAgAAAA==.',
['噹奶']='噹奶:BAAALgAECgQJBgAAAA==.',
['国宝']='国宝弥勒:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光柯基:BAAALgAECgEJAQAAAA==.圣光炸了:BAAALgAECgUJBgAAAA==.圣光疯狂:BAAALgAECgUJBQAAAA==.',
['圣洁']='圣洁光辉:BAACLgAFFH8NAAILAAUJmwmpCABrAQALAAUJmwmpCABrAQAuAAQKfxgAAgsACAkOHcQ3AEQCAAsACAkOHcQ3AEQCAAAA.',
['坏杨']='坏杨梅:BAABLgAFFH8GAAIMAAIJDBOOOgC1AAAMAAIJDBOOOgC1AAAAAA==.',
['埃林']='埃林洛斯:BAAALgADCgEJAQAAAA==.',
['塔斯']='塔斯听购:BAAALgAFFAIJBAAAAA==.',
['墨曦']='墨曦:BAAALgAECgQJBAAAAA==.',
['壹訫']='壹訫:BAAALgAECgMJAgAAAA==.',
['夏日']='夏日袅袅:BAAALgAECgYJBwAAAA==.',
['夜舞']='夜舞飘飘:BAAALgAECgEJAQAAAA==.',
['夜行']='夜行小脆饼:BAAALgADCgEJAQAAAA==.',
['大嘴']='大嘴鱼:BAAALgAECgEJAQAAAA==.',
['大宝']='大宝贝贝:BAAALgAFFAEJAQAAAA==.',
['大薯']='大薯片:BAAALgAFFAIJBAAAAA==.',
['大黑']='大黑黑二号:BAAALgAECgYJDQAAAA==.',
['天使']='天使的仆人:BAAALgAECgQJCAAAAA==.',
['奥尔']='奥尔加玛丽:BAABLgAFFH8IAAIPAAQJBANvGgD9AAAPAAQJBANvGgD9AAAAAA==.奥尔斯帝徳:BAAALgAECgQJBQAAAA==.',
['奶不']='奶不了一点:BAAALgAFFAIJAwAAAA==.奶不死人:BAABLgAFFH8FAAMNAAEJ5hREFgBMAAANAAEJ5hREFgBMAAAQAAEJZAACFQA0AAAAAA==.',
['奶粉']='奶粉:BAAALgAECgYJBgAAAA==.',
['好名']='好名给狗叫了:BAAALgADCgEJAQAAAA==.',
['妹子']='妹子憋这样:BAAALgADCgYJBgAAAA==.',
['姚老']='姚老师的守护:BAABLgAECn8UAAIRAAYJPSIBEwA3AgARAAYJPSIBEwA3AgAAAA==.',
['娇娇']='娇娇大德:BAAALgAECgQJBAAAAA==.娇娇拟贞大:BAAALgAECgMJAwAAAA==.',
['嫂子']='嫂子开菛:BAABLgAFFH8MAAIPAAUJWQybDQBjAQAPAAUJWQybDQBjAQAAAA==.',
['子小']='子小氵告:BAAALgAECgYJDAAAAA==.',
['宁德']='宁德時代:BAABLgAFFH8GAAISAAMJxBjqDwCQAAASAAMJxBjqDwCQAAAAAA==.',
['安迪']='安迪艾瑞蒙特:BAAALgAECgEJAQAAAA==.',
['寒冰']='寒冰箭:BAAALgAECgMJAwAAAA==.',
['寒露']='寒露:BAAALgAFFAEJAQAAAA==.',
['小号']='小号法:BAAALgADCgEJAQAAAA==.',
['小小']='小小毒药:BAAALgADCgYJBgAAAA==.',
['小柠']='小柠柠:BAAALgADCgEJAQAAAA==.',
['小梦']='小梦魇:BAABLgAFFH8GAAITAAMJvAr9CwC4AAATAAMJvAr9CwC4AAAAAA==.',
['小熊']='小熊进魔兽啦:BAAALgAECgMJAwAAAA==.',
['小牛']='小牛花花:BAAALgAECgEJAQAAAA==.',
['小猪']='小猪佩骑:BAAALgAECgUJBQAAAA==.',
['小璃']='小璃:BAAALgAECgcJBwAAAA==.',
['小甜']='小甜同学:BAAALgADCgEJAQAAAA==.',
['小竿']='小竿子飞飞:BAAALgADCgUJBQAAAA==.',
['小闪']='小闪电:BAAALgAECgcJBwAAAA==.',
['小阿']='小阿草:BAAALgAECgEJAQAAAA==.',
['小马']='小马的术爷:BAABLgAFFH8KAAIGAAUJKQoHDQAoAQAGAAUJKQoHDQAoAQAAAA==.小马的死骑:BAABLgAFFH8KAAIKAAQJ/xikFABQAQAKAAQJ/xikFABQAQAAAA==.小马的法爷:BAABLgAFFH8GAAIMAAQJPAmEIQA7AQAMAAQJPAmEIQA7AQAAAA==.',
['小鸟']='小鸟扎西:BAAALgAECgIJAgAAAA==.',
['少年']='少年聂:BAAALgAECgUJDQAAAA==.',
['尼古']='尼古拉哥白尼:BAAALgAECgYJBgABLgAFFAMJBQABAGAjAA==.',
['山河']='山河永寂:BAAALgAECgUJBQAAAA==.',
['岩忌']='岩忌:BAAALgAFFAEJAQAAAA==.',
['岳绮']='岳绮萝:BAAALgAECgEJAQAAAA==.',
['布莱']='布莱恩铁锤:BAAALgAECgYJCgAAAA==.',
['帕德']='帕德耀斯:BAAALgAECgEJBAAAAA==.',
['干么']='干么四:BAAALgAECgEJBAAAAA==.',
['幻化']='幻化:BAAALgAECgEJAQAAAA==.',
['张可']='张可怜:BAAALgAECgYJDgAAAA==.',
['归途']='归途的风:BAAALgAECgEJAQAAAA==.',
['当麻']='当麻丶:BAAALgADCgcJCwABLgADCgkJCQAJAAAAAA==.',
['彩虹']='彩虹飞舷:BAAALgAECgEJAQAAAA==.',
['影月']='影月风:BAAALgAFFAEJAQAAAA==.',
['德了']='德了个德:BAAALgADCgEJAQAAAA==.',
['德努']='德努依一:BAAALgADCgIJAgAAAA==.',
['快吸']='快吸熊猫奶:BAABLgAECn8aAAIMAAcJfQx5pwCKAQAMAAcJfQx5pwCKAQAAAA==.',
['怒潮']='怒潮:BAAALgAECgcJDQABLgAFFAUJBAAJAAAAAA==.',
['思念']='思念像影随行:BAAALgAFFAIJAgAAAA==.',
['想上']='想上小学:BAAALgAECgIJAgAAAA==.',
['愔愔']='愔愔:BAAALgAECgEJAQAAAA==.',
['憶無']='憶無心:BAABLgAFFH8FAAMUAAQJNwhoCwAmAQAUAAQJNwhoCwAmAQAVAAEJVwDKFwA7AAAAAA==.',
['我系']='我系瘦人:BAAALgADCgQJBAAAAA==.',
['战神']='战神典韦:BAAALgAECgUJCAAAAA==.战神飞飞:BAAALgAECgQJBQAAAA==.',
['戰戰']='戰戰:BAAALgAECgEJAQAAAA==.',
['手法']='手法也是法:BAAALgADCgEJAQAAAA==.',
['扒开']='扒开:BAAALgAECgYJBgAAAA==.',
['扶摇']='扶摇奕奕:BAAALgAECgUJBQAAAA==.',
['抱脸']='抱脸虫:BAAALgAFFAEJAQAAAA==.',
['指掀']='指掀涛澜:BAAALgAECgQJBAAAAA==.',
['挽魂']='挽魂:BAAALgAECgIJAgABLgAECgUJBgAJAAAAAA==.',
['接头']='接头盒:BAAALgAECgEJAgAAAA==.',
['撒死']='撒死给丶:BAABLgAFFH8HAAIEAAQJmgd9EAD+AAAEAAQJmgd9EAD+AAAAAA==.',
['救人']='救人骑士:BAABLgAFFH8GAAIKAAIJtyCxGQDBAAAKAAIJtyCxGQDBAAAAAA==.',
['敖璃']='敖璃:BAAALgAECgYJCQAAAA==.',
['散化']='散化:BAAALgAECgQJBAAAAA==.',
['无丶']='无丶我:BAAALgAECgIJAgABLgAECgMJAwAJAAAAAA==.',
['无我']='无我丶:BAAALgADCgUJBQABLgAECgMJAwAJAAAAAA==.',
['无敌']='无敌龟龟:BAAALgADCgUJAgAAAA==.',
['无辣']='无辣不欢:BAAALgAFFAIJAwAAAA==.',
['无锡']='无锡第一懒猪:BAABLgAFFH8IAAIEAAQJxQY8CAAbAQAEAAQJxQY8CAAbAQAAAA==.',
['旧梦']='旧梦思心凉:BAAALgAFFAEJAQAAAA==.',
['旺仔']='旺仔牛奶糖:BAAALgAECgEJAQAAAA==.',
['易鬼']='易鬼:BAAALgAECgIJAgAAAA==.',
['星界']='星界穿行者:BAAALgAECgYJCQAAAA==.',
['星空']='星空之龙:BAAALgADCgMJAwAAAA==.',
['昱子']='昱子:BAAALgADCgcJDwAAAA==.',
['昱玄']='昱玄:BAAALgADCgMJAwAAAA==.',
['暗夜']='暗夜女魔王:BAAALgADCgcJAwAAAA==.暗夜的传说:BAAALgAECgEJAQAAAA==.',
['暗影']='暗影主宰:BAABLgAFFH8GAAMPAAMJHwebFQC/AAAPAAMJOwWbFQC/AAAWAAIJOwhrCgCZAAAAAA==.',
['暗牧']='暗牧大王:BAABLgAFFH8FAAIXAAUJYBPFBADiAAAXAAUJYBPFBADiAAAAAA==.',
['暗秋']='暗秋:BAAALgAECgUJBgAAAA==.',
['暴力']='暴力毛栗子:BAAALgAECgYJBwAAAA==.暴力毛毛:BAAALgADCgQJBAAAAA==.',
['暴走']='暴走权权:BAACLgAFFH8KAAIPAAMJQR7uDwD3AAAPAAMJQR7uDwD3AAAuAAQKfxwAAg8ABwnZIcscAKUCAA8ABwnZIcscAKUCAAAA.',
['暹罗']='暹罗喵王:BAAALgADCgMJAwAAAA==.',
['曾经']='曾经何时:BAAALgADCgMJBAAAAA==.',
['朝九']='朝九晚舞:BAAALgAFFAEJAQAAAA==.',
['未来']='未来一小梦:BAAALgAFFAEJAQAAAA==.',
['未知']='未知姓名:BAAALgAECgIJAQAAAA==.',
['本服']='本服第一男人:BAAALgAFFAcJAgAAAA==.',
['术不']='术不远送:BAAALgADCgkJDgAAAA==.',
['权权']='权权丶:BAAALgAECggJDQAAAA==.',
['李太']='李太白:BAAALgAECgMJBAAAAA==.',
['李果']='李果果:BAAALgAECgQJBAAAAA==.',
['李铁']='李铁柱:BAAALgAECgEJAQAAAA==.',
['来什']='来什么要什么:BAAALgAFFAIJAgAAAA==.',
['来发']='来发灵界:BAABLgAFFH8GAAIKAAMJmCDLHQApAQAKAAMJmCDLHQApAQAAAA==.',
['板凳']='板凳掠人:BAAALgAECgMJAwAAAA==.',
['枕雪']='枕雪丷眠:BAAALgAECgQJBAAAAA==.',
['柒号']='柒号公园:BAAALgAECgIJAgAAAA==.',
['梦龍']='梦龍:BAACLgAFFH8HAAIMAAMJGxgJEwAaAQAMAAMJGxgJEwAaAQAuAAQKfyEAAwwABwncIggNAAUCAAwABwncIggNAAUCABgAAQkGIcIZAEoAAAAA.',
['楚暮']='楚暮影:BAAALgAFFAMJBAAAAA==.',
['楚穆']='楚穆歌:BAAALgAFFAQJBAAAAA==.',
['武术']='武术波比:BAAALgADCgEJAQAAAA==.',
['殢无']='殢无伤:BAAALgADCgQJBAAAAA==.',
['殷梦']='殷梦石爷爷:BAAALgAECgEJAQAAAA==.',
['毛茸']='毛茸茸的壮壮:BAAALgAECgYJCwAAAA==.',
['气球']='气球不爆炸:BAABLgAFFH8GAAIPAAYJoxMuAgCfAQAPAAYJoxMuAgCfAQAAAA==.',
['江陵']='江陵:BAAALgAECgcJBwAAAA==.',
['河豚']='河豚寿司:BAAALgADCgEJAQAAAA==.',
['法小']='法小噹:BAAALgADCgUJBQAAAA==.',
['洛凡']='洛凡尘:BAAALgAECgEJAgAAAA==.',
['流浪']='流浪绅士:BAAALgAFFAIJBAAAAA==.',
['测赫']='测赫玛塌:BAAALgAECgMJAwAAAA==.',
['海盐']='海盐风信子:BAAALgAECgIJAwAAAA==.',
['海蓝']='海蓝不见鲸:BAAALgAECgQJBAAAAA==.',
['海贼']='海贼灬山治:BAAALgAECgMJAwAAAA==.',
['涉爆']='涉爆:BAAALgAECgMJAwAAAA==.',
['深情']='深情祖师爷:BAAALgAECgcJBgAAAA==.',
['演子']='演子嘴子丶:BAAALgAECgYJEQAAAA==.',
['灏瀚']='灏瀚沧溟:BAAALgAECgQJBAAAAA==.',
['火舞']='火舞小甜:BAAALgAECgUJBQAAAA==.',
['灬人']='灬人菜瘾大灬:BAAALgAECgYJBgABLgAFFAUJEAAMAIQaAA==.',
['灶门']='灶门贪吃郎:BAAALgADCgcJBwAAAA==.',
['炊牛']='炊牛碧:BAAALgADCgYJBgAAAA==.',
['炼魂']='炼魂:BAABLgAFFH8EAAMGAAQJdBQyFAD3AAAGAAMJohEyFAD3AAAHAAEJ6ByPBQBcAAAAAA==.',
['热情']='热情玫瑰:BAAALgADCgcJBwAAAA==.',
['烽火']='烽火连赢:BAAALgADCgcJBwAAAA==.',
['焦糖']='焦糖小薄脆:BAAALgAECgQJBAAAAA==.',
['熱愛']='熱愛和平:BAAALgAECgYJBwAAAA==.',
['燃尽']='燃尽斐冉:BAAALgAECgQJBAAAAA==.',
['燃烧']='燃烧的星辰:BAAALgAECgEJAgAAAA==.',
['爱与']='爱与美:BAABLgAFFH8JAAIZAAQJlQrADAA7AQAZAAQJlQrADAA7AQAAAA==.',
['爱惜']='爱惜这个世界:BAAALgADCgIJAgAAAA==.',
['爱颖']='爱颖颖:BAAALgAECgMJBQAAAA==.',
['牛噹']='牛噹噹:BAAALgAECgQJCAAAAA==.',
['牛肉']='牛肉丝炒饭:BAAALgAECgYJBwAAAA==.',
['牛马']='牛马牌割草机:BAAALgADCgEJAQAAAA==.',
['犄角']='犄角炸了:BAAALgADCgUJBQAAAA==.',
['狐中']='狐中劳模:BAAALgAFFAIJAgAAAA==.',
['狠角']='狠角色丶四侠:BAAALgAECgQJBAAAAA==.',
['独大']='独大狗:BAAALgAFFAIJAgAAAA==.',
['猛滴']='猛滴一碧:BAAALgADCgIJAgAAAA==.',
['猪青']='猪青:BAAALgAECgEJAQABLgAFFAcJBgAEADUaAA==.',
['王斜']='王斜斜:BAAALgAFFAMJBAAAAA==.',
['玛萨']='玛萨卡:BAAALgADCgYJCQABLgAECgYJCgAJAAAAAA==.',
['瓦陶']='瓦陶陶吃邪祟:BAAALgAECgIJAgAAAA==.',
['电竞']='电竞教父:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂星期二:BAAALgAECgUJBQAAAA==.疯狂的小仙:BAAALgAECgQJBQAAAA==.',
['療殤']='療殤:BAAALgADCgUJBQAAAA==.',
['白砂']='白砂冰糖:BAAALgADCgYJBgAAAA==.',
['白菜']='白菜帮:BAAALgAECgEJAQAAAA==.',
['白雪']='白雪牛牛:BAAALgAECgMJAwAAAA==.',
['皮卡']='皮卡乒:BAAALgAECgEJAQAAAA==.',
['盗刀']='盗刀切玉:BAAALgAECgEJAwAAAA==.',
['相公']='相公你先脱:BAAALgAECgUJBQAAAA==.',
['真紅']='真紅:BAAALgAECgQJBAAAAA==.',
['真红']='真红贝黑莱特:BAAALgAECgkJCQAAAA==.',
['石头']='石头仔:BAAALgAECgYJBgAAAA==.',
['石小']='石小空萨满:BAAALgAECgUJBQAAAA==.',
['破军']='破军术:BAAALgAECgkJEAAAAA==.',
['神奈']='神奈川:BAAALgAECgEJAQAAAA==.',
['神棍']='神棍老师:BAAALgADCgUJBQAAAA==.',
['神罗']='神罗:BAAALgADCgEJAQAAAA==.',
['神话']='神话烙印白浅:BAAALgAECgEJAQAAAA==.',
['福开']='福开心:BAAALgAECgYJCQAAAA==.',
['秦嘉']='秦嘉倪:BAAALgAECgMJAwAAAA==.',
['究极']='究极大芒果:BAACLgAFFH8JAAIKAAQJxBOcFwBGAQAKAAQJxBOcFwBGAQAuAAQKfyIAAgoACAmgH4ADAIcCAAoACAmgH4ADAIcCAAAA.',
['穿云']='穿云踏浪:BAAALgAECgcJBgABLgAFFAUJAQAJAAAAAA==.',
['第二']='第二正常:BAAALgAECgMJAwAAAA==.',
['筒絮']='筒絮:BAAALgADCgUJBQAAAA==.',
['簪花']='簪花格:BAAALgADCgEJAQAAAA==.',
['米娜']='米娜娜让半球:BAAALgAFFAIJAwAAAA==.',
['米拉']='米拉丶露娜:BAAALgAECgQJBAAAAA==.',
['粗链']='粗链:BAAALgAECgYJCAAAAA==.',
['精灵']='精灵法:BAAALgAECgEJAgAAAA==.',
['素鈊']='素鈊:BAAALgAECgkJEgAAAA==.',
['繁星']='繁星點點:BAAALgADCgIJAgAAAA==.',
['红烧']='红烧惩戒骑:BAAALgAECgIJAgAAAA==.',
['红豆']='红豆:BAAALgAECgYJCQAAAA==.',
['终于']='终于天亮了:BAAALgAECgEJAQAAAA==.',
['给我']='给我合波:BAAALgADCgEJAQAAAA==.给我塔塔开:BAAALgAECgQJAwAAAA==.给我杯橙汁:BAABLgAFFH8FAAIUAAMJJAO8EAC9AAAUAAMJJAO8EAC9AAAAAA==.',
['绝世']='绝世小牛:BAAALgAECgEJAQAAAA==.',
['绿茉']='绿茉莉:BAAALgAECgEJAQAAAA==.',
['缥缈']='缥缈情情:BAAALgAECgYJCwAAAA==.',
['罐头']='罐头好吃:BAAALgAECgEJAQAAAA==.',
['罗素']='罗素红邪:BAAALgAFFAIJBAAAAA==.',
['美国']='美国派:BAAALgAECgEJAwAAAA==.',
['羽毛']='羽毛心渊:BAAALgAECgYJBwABLgAECgYJCAAJAAAAAA==.羽毛心雨:BAAALgAECgYJCAAAAA==.',
['羽生']='羽生:BAAALgAECgEJAQAAAA==.',
['老婆']='老婆很亮:BAAALgAECgQJBQAAAA==.',
['老默']='老默不吃鱼:BAAALgAECgEJAgAAAA==.',
['肥肉']='肥肉为何而长:BAAALgAECgcJBgAAAA==.',
['胖虎']='胖虎胡:BAAALgAFFAQJBAAAAA==.',
['舔狗']='舔狗:BAAALgAFFAIJAwAAAA==.',
['艾丝']='艾丝的眷族:BAAALgAECgMJAgAAAA==.',
['艾欧']='艾欧星:BAAALgAECgcJBwAAAA==.',
['芙蓉']='芙蓉王忠王:BAACLgAFFH8IAAIKAAQJexTrFQBMAQAKAAQJexTrFQBMAQAuAAQKfxsAAgoABwnnI6YfAMQCAAoABwnnI6YfAMQCAAAA.',
['花鸟']='花鸟风月光:BAAALgADCgUJBQAAAA==.',
['苏哇']='苏哇卡:BAAALgAECgEJAQAAAA==.',
['茉莉']='茉莉小宝:BAAALgAECgIJAgAAAA==.',
['茶饼']='茶饼荼饼:BAAALgAECgMJAwAAAA==.',
['荒野']='荒野逐猎者:BAAALgADCgUJCAAAAA==.',
['莫名']='莫名微笑:BAABLgAECn8bAAMKAAgJYAypfwCEAQAKAAgJYAypfwCEAQATAAEJZAYTSgAjAAAAAA==.',
['菜月']='菜月昴:BAAALgAECgYJEAAAAA==.',
['菜鸟']='菜鸟扎西:BAAALgAECgUJCgAAAA==.',
['萌新']='萌新小白:BAAALgAFFAEJAQAAAA==.',
['萌萌']='萌萌丶:BAAALgAECgUJBQAAAA==.萌萌的牛牛:BAAALgAECgkJBgABLgAFFAcJBgAEADUaAA==.',
['落花']='落花又逢君:BAAALgAECgcJCAABLgAFFAQJEwASADEgAA==.',
['蒂德']='蒂德莉特:BAAALgAECgYJCwAAAA==.',
['蒜泥']='蒜泥灬拽:BAAALgAECgMJAwAAAA==.',
['蓝蓝']='蓝蓝的牧:BAAALgAECgEJAQAAAA==.',
['薏米']='薏米氿丶:BAAALgAECgEJAgAAAA==.薏米琉丶:BAAALgAECgQJBAAAAA==.',
['薯条']='薯条加大:BAAALgAECgQJBAAAAA==.',
['蚀魂']='蚀魂二号:BAAALgAFFAQJBAAAAA==.',
['蚀魄']='蚀魄一号:BAABLgAFFH8FAAMGAAQJ6hJ9SQBSAAAGAAMJnxR9SQBSAAAHAAEJyw0AAAAAAAAAAA==.蚀魄七号:BAAALgAECgkJCQAAAA==.蚀魄三号:BAAALgAECgcJDQAAAA==.蚀魄五号:BAAALgAECgcJBwAAAA==.蚀魄四号:BAAALgAECgcJBwAAAA==.',
['蜂鸟']='蜂鸟:BAAALgAECgYJCAAAAA==.',
['蝎子']='蝎子赖赖:BAAALgAECgYJBQAAAA==.',
['袭灭']='袭灭天来:BAAALgAECgEJAgAAAA==.',
['装备']='装备都是我的:BAAALgAECgYJBgAAAA==.',
['西瓜']='西瓜泡饼:BAAALgADCgcJBwAAAA==.',
['观心']='观心:BAAALgAFFAEJAgAAAA==.',
['说走']='说走就不走:BAAALgADCgEJAQAAAA==.',
['谢美']='谢美梦:BAAALgAECgYJCAAAAA==.',
['貔貅']='貔貅吐不吐:BAAALgAECgMJAwAAAA==.',
['贝尔']='贝尔摩德丶:BAAALgADCgUJBQABLgADCgkJCQAJAAAAAA==.',
['费蒙']='费蒙特的野望:BAAALgAECgcJBwAAAA==.',
['贾奶']='贾奶量:BAAALgAECgYJEAAAAA==.',
['超级']='超级大牛牛:BAAALgAECgEJAQAAAA==.超级无敌西瓜:BAAALgAECgQJBAAAAA==.',
['跳跳']='跳跳的圣骑:BAAALgADCgcJBwAAAA==.跳跳的夜术:BAAALgADCgEJAQAAAA==.跳跳的小蘑菇:BAAALgADCgcJBwAAAA==.跳跳的魔女:BAAALgADCgQJBAAAAA==.',
['踏岚']='踏岚:BAAALgADCgEJAQAAAA==.',
['辛巴']='辛巴克:BAABLgAFFH8IAAIKAAQJChstDgBqAQAKAAQJChstDgBqAQAAAA==.',
['这个']='这个是什么鬼:BAAALgAECgUJCQAAAA==.',
['连翘']='连翘:BAAALgAECgcJEgABLgAFFAYJDwAaAF0hAA==.',
['迷雾']='迷雾冰川:BAACLgAFFH8HAAMOAAQJdBK5AwBbAQAOAAQJdBK5AwBbAQAbAAEJ7gEALQA+AAAuAAQKfxcAAw4ABwkgIBALANoBAA4ABwntHhALANoBABsABAlSHhlMACEBAAEuAAUUBQkNAAsAmwkA.',
['追风']='追风之箭:BAAALgAECgEJAQAAAA==.追风噹噹:BAABLgAECn8UAAIOAAcJexwMBwAZAgAOAAcJexwMBwAZAgAAAA==.',
['逆天']='逆天而行:BAAALgAECgYJCwAAAA==.',
['逆行']='逆行:BAAALgADCgUJBQAAAA==.',
['逍遥']='逍遥重塑:BAAALgAECgYJDAAAAA==.',
['通缉']='通缉南:BAAALgAFFAEJAQAAAA==.',
['逮住']='逮住那只蜗牛:BAAALgADCgEJAQAAAA==.',
['那一']='那一片绿荫:BAAALgADCgEJAQAAAA==.',
['那时']='那时紫色:BAAALgADCgEJAQAAAA==.',
['邦桑']='邦桑迪的微笑:BAAALgAECgMJCQAAAA==.',
['邪不']='邪不柔:BAAALgAFFAEJAQAAAA==.',
['酸汤']='酸汤肥牛:BAAALgAECgUJBQAAAA==.',
['钕孒']='钕孒:BAAALgAECgYJBgAAAA==.',
['钟无']='钟无艳:BAAALgAFFAIJBAAAAA==.',
['钟的']='钟的向方反:BAAALgAECgYJCQAAAA==.',
['长安']='长安归故里:BAAALgAECgMJAwAAAA==.',
['闪光']='闪光少女:BAAALgAECgYJCgAAAA==.',
['阿烮']='阿烮:BAAALgADCgkJCQAAAA==.',
['阿玛']='阿玛迪斯:BAAALgADCgIJAgAAAA==.',
['陆小']='陆小柯:BAAALgAECgEJAQAAAA==.',
['雅舍']='雅舍:BAAALgAECgEJAgAAAA==.',
['雪色']='雪色晨光:BAAALgADCgEJAQAAAA==.',
['雷伊']='雷伊丨天行者:BAAALgAECgMJAwAAAA==.',
['霁月']='霁月空舞:BAAALgADCgYJBwAAAA==.',
['霜阎']='霜阎之忆:BAAALgAECgcJDgAAAA==.',
['青铜']='青铜龙:BAACLgAFFH8FAAIEAAMJbwpVEwDjAAAEAAMJbwpVEwDjAAAuAAQKfxkAAwQACAknIBwLAMQCAAQACAlQHRwLAMQCABwABglGH1wRAMkBAAAA.',
['靛沧']='靛沧海:BAAALgAECgEJAQABLgAFFAQJCAAGABsdAA==.',
['风行']='风行大师:BAAALgAFFAEJAQAAAA==.',
['飞翔']='飞翔汉堡:BAAALgAECgMJAwAAAA==.',
['饭盒']='饭盒里的盒饭:BAACLgAFFH8FAAIWAAMJuxC3BQD9AAAWAAMJuxC3BQD9AAAuAAQKfxQAAxYABgl1IEwWABkCABYABgl1IEwWABkCAB0ABQkWD0QYAN0AAAAA.',
['饼薄']='饼薄:BAAALgAECgMJAwAAAA==.',
['高超']='高超的偷袭者:BAABLgAFFH8IAAIQAAMJthxdBgAWAQAQAAMJthxdBgAWAQAAAA==.',
['魔幻']='魔幻:BAAALgAFFAYJAwAAAA==.',
['魔法']='魔法战街女:BAAALgAECgYJBQAAAA==.',
['鲨鱼']='鲨鱼滚滚:BAAALgADCgEJAQAAAA==.',
['鳯凰']='鳯凰泪:BAAALgADCgUJBQAAAA==.',
['鸭梨']='鸭梨汕大:BAAALgAECgUJBQAAAA==.鸭梨老二:BAAALgAECgEJAQAAAA==.',
['默认']='默认关系:BAAALgADCgEJAQAAAA==.',
['默默']='默默落落:BAAALgAECgEJAQAAAA==.',
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
