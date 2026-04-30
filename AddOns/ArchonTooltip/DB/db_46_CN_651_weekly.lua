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

local lookup = {'Priest-Shadow','Paladin-Holy','Unknown-Unknown','Monk-Windwalker','Mage-Frost','Monk-Brewmaster','Monk-Mistweaver','Paladin-Protection','Warrior-Protection','Warrior-Fury','Paladin-Retribution','Evoker-Augmentation','Evoker-Preservation','DemonHunter-Devourer','DemonHunter-Vengeance','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Shaman-Elemental','Warlock-Affliction','Warrior-Arms','DeathKnight-Unholy','Shaman-Enhancement','Hunter-BeastMastery','Priest-Discipline','Druid-Restoration','Hunter-Marksmanship','Hunter-Survival',}
local provider = {region='CN',realm='安威玛尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ct='Ct:BAAALgAFFAMJBAABLgAFFAMJBwABAJ4bAA==.',
Dy='Dyyi:BAAALgAECgEJAQAAAA==.',
Ed='Edwiin:BAAALgAECgIJAgAAAA==.',
Fb='Fb:BAAALgAECgIJAgAAAA==.',
Gz='Gzr:BAAALgADCgEJAQAAAA==.',
Ho='Hosm:BAAALgAECgkJEAAAAA==.',
Hp='Hp:BAAALgAFFAEJAQAAAA==.',
Ic='Icecream:BAAALgADCgkJCQAAAA==.',
Ja='Javne:BAAALgAFFAQJBAAAAA==.',
La='Labubu:BAAALgAFFAEJAQAAAA==.',
Li='Lightin:BAAALgADCgIJAgAAAA==.',
Ly='Lynette:BAABLgAFFH8JAAICAAMJzSVSCABMAQACAAMJzSVSCABMAQABLgAFFAMJBwABAJ4bAA==.',
Ma='Maik:BAAALgAECgEJAgAAAA==.',
Mf='Mf:BAAALgAECgEJAgAAAA==.',
Mi='Minotaur:BAAALgAFFAIJBAAAAA==.',
Pg='Pg:BAAALgAECgcJDAAAAA==.',
Sc='Scv:BAAALgAECgYJBQABLgAFFAIJAgADAAAAAA==.',
St='Staryy:BAAALgAECggJDgAAAA==.',
Ve='Velmonk:BAABLgAECn8YAAIEAAgJ8xaJGAAeAgAEAAgJ8xaJGAAeAgAAAA==.',
Xy='Xylia:BAAALgAECgEJAQAAAA==.',
['一刹']='一刹了无痕:BAAALgADCgYJBgABLgAECggJHQAFABMiAA==.',
['一日']='一日一善:BAAALgADCgcJBwAAAA==.',
['东方']='东方逍遥仔:BAAALgAECgMJAwAAAA==.',
['丨牴']='丨牴調丨:BAAALgAECgQJBgAAAA==.',
['丶听']='丶听悲伤的歌:BAAALgAFFAEJAQAAAA==.',
['五月']='五月:BAABLgAECn8UAAQEAAgJDBskFgA4AgAEAAcJrx4kFgA4AgAGAAUJ6RBRRwAlAQAHAAYJUgqBPQDxAAAAAA==.',
['什么']='什么冬梅:BAAALgAECgQJCAAAAA==.',
['以朕']='以朕之名:BAABLgAECn8dAAMIAAgJvRcdDQD2AQAIAAgJvRcdDQD2AQACAAIJpgGJkAA+AAAAAA==.',
['佟湘']='佟湘玉闯江湖:BAAALgADCgYJCAAAAA==.',
['你是']='你是猎物:BAAALgAECgcJBwAAAA==.',
['你的']='你的老情人:BAACLgAFFH8KAAIJAAQJSAqmBgD8AAAJAAQJSAqmBgD8AAAuAAQKfxQAAwkACQmOGEwSAOMBAAkACAmPFEwSAOMBAAoAAgk6IYd+AMMAAAAA.',
['先祖']='先祖忽悠着你:BAAALgAECgIJAgAAAA==.',
['光铸']='光铸霸气侧漏:BAAALgAECgYJBgAAAA==.',
['凤凰']='凤凰烈波:BAAALgAECgYJCwAAAA==.',
['刃落']='刃落无声:BAAALgADCgYJBgABLgAFFAcJDQAJAM4ZAA==.',
['初見']='初見:BAAALgAFFAEJAQAAAA==.',
['别被']='别被游戏玩:BAAALgAECgMJAwAAAA==.',
['别问']='别问有天赋:BAAALgAECgYJEAAAAA==.',
['半夏']='半夏丨生梦:BAAALgAFFAEJAQAAAA==.',
['卡索']='卡索弥亚:BAABLgAECn8dAAILAAgJVhNqYQDAAQALAAgJVhNqYQDAAQAAAA==.',
['原告']='原告五人:BAABLgAECn8eAAMMAAgJ7AYQEgDRAAAMAAgJ7AYQEgDRAAANAAUJ2AIhOQChAAAAAA==.',
['又又']='又又鱼儿:BAAALgAECgUJBQAAAA==.',
['反方']='反方向的钟:BAAALgADCgYJBgAAAA==.',
['受难']='受难胡子:BAAALgAFFAIJAwAAAA==.',
['古力']='古力娜扎:BAAALgAECgEJAQAAAA==.',
['叮叮']='叮叮当当:BAAALgAFFAEJAQAAAA==.',
['呼之']='呼之欲出肉肉:BAAALgAECgUJBQAAAA==.',
['哈基']='哈基米捏诺:BAAALgAECgcJEAAAAA==.',
['哎呦']='哎呦喂妞妞:BAAALgADCgEJAQAAAA==.',
['噬灭']='噬灭:BAABLgAFFH8IAAIOAAMJwgu6HQDnAAAOAAMJwgu6HQDnAAAAAA==.',
['噬魂']='噬魂血:BAAALgAECgMJAwAAAA==.',
['土耳']='土耳其冰淇淋:BAAALgAECgEJAgAAAA==.',
['圣斗']='圣斗士七曜:BAAALgADCgEJAQABLgAFFAQJBAADAAAAAA==.',
['圣灵']='圣灵灵:BAAALgADCgUJBwAAAA==.',
['基尔']='基尔简单:BAAALgAECgcJDwAAAA==.',
['大颗']='大颗粒丶:BAABLgAECn8UAAIFAAcJRhbOdQDmAQAFAAcJRhbOdQDmAQAAAA==.',
['天丛']='天丛云:BAAALgAECgEJAgAAAA==.',
['天使']='天使笑傻了:BAABLgAECn8dAAIFAAgJEyLqCwDyAQAFAAgJEyLqCwDyAQAAAA==.',
['天堂']='天堂地狱之间:BAAALgADCgEJAQAAAA==.',
['奥瑟']='奥瑟雅:BAAALgADCgYJBgAAAA==.',
['奶茶']='奶茶小怪兽:BAAALgADCgUJBQAAAA==.',
['孤星']='孤星望月:BAAALgADCgcJBwAAAA==.',
['安以']='安以燕:BAAALgADCgYJBgAAAA==.',
['安威']='安威玛耳:BAAALgAFFAMJAwAAAA==.',
['宛若']='宛若新生:BAAALgADCgEJAQAAAA==.',
['小乐']='小乐乐:BAAALgADCgUJBQAAAA==.',
['小宝']='小宝的宠物:BAAALgADCgMJAwAAAA==.',
['小朱']='小朱静:BAAALgAECgMJAwAAAA==.',
['小猫']='小猫不乖:BAAALgADCgEJAQAAAA==.',
['小红']='小红手周润发:BAAALgADCgMJAwAAAA==.',
['小纤']='小纤纤:BAAALgADCgQJBAAAAA==.',
['尤型']='尤型拆卸者:BAAALgAECgcJAgABLgAFFAcJDQAJAM4ZAA==.',
['就是']='就是硬:BAAALgAECgcJBwAAAA==.',
['尼古']='尼古顶针:BAAALgAECgMJAQAAAA==.',
['山石']='山石岩:BAAALgAECgQJBAAAAA==.',
['年轻']='年轻的法海:BAAALgAECgUJCgAAAA==.年轻的许仙:BAAALgAECgYJDQAAAA==.',
['幸福']='幸福的棍子:BAAALgAECgYJDwAAAA==.',
['幻影']='幻影紫霞:BAABLgAECn8aAAILAAgJHBryPwAmAgALAAgJHBryPwAmAgABLgAFFAUJBQAPAFMlAA==.',
['幽儿']='幽儿希卡丶:BAAALgAECgEJAQAAAA==.',
['廸丽']='廸丽热巴:BAAALgAECgEJAgAAAA==.',
['开心']='开心小翅膀:BAAALgAECgQJBAABLgAECgYJCgADAAAAAA==.',
['恩择']='恩择:BAAALgADCgYJBgAAAA==.',
['恶魔']='恶魔夂翼:BAAALgAECgEJAQAAAA==.',
['恶龙']='恶龙血铠:BAAALgADCgIJAgAAAA==.',
['情傷']='情傷:BAACLgAFFH8LAAIQAAUJYg7ABACEAQAQAAUJYg7ABACEAQAuAAQKfyEAAhAACQkHIUIGAA4DABAACQkHIUIGAA4DAAAA.',
['慕怜']='慕怜:BAAALgAFFAEJAQAAAA==.',
['戏言']='戏言人间:BAAALgAECgYJBgAAAA==.',
['成成']='成成丶:BAABLgAFFH8NAAMRAAQJORnmBwBEAQARAAQJORnmBwBEAQASAAEJ2QHDGgBDAAAAAA==.',
['我先']='我先拯救世界:BAAALgAECgQJBQABLgAECgYJCgADAAAAAA==.',
['我容']='我容易么:BAAALgAECgQJBAAAAA==.',
['我想']='我想睡觉:BAAALgADCgIJAgAAAA==.',
['我是']='我是德德:BAAALgADCgcJBwAAAA==.',
['搓面']='搓面包解千愁:BAEALgAFFAEJAQABLgAFFAIJAgADAAAAAA==.',
['文藝']='文藝青年:BAAALgAECgEJAgAAAA==.',
['斩怒']='斩怒风:BAAALgAECgIJAgAAAA==.',
['旋转']='旋转滴马尾辫:BAAALgAECgMJAwAAAA==.',
['无尘']='无尘:BAEALgAFFAEJAgABLgAFFAIJAgADAAAAAA==.',
['无悬']='无悬无念:BAAALgADCgUJBQAAAA==.',
['无敌']='无敌的大象:BAAALgAECgEJAQAAAA==.',
['无法']='无法无天如花:BAAALgAECgEJAQAAAA==.',
['日久']='日久见人格:BAABLgAFFH8GAAIIAAMJ1RQUBACaAAAIAAMJ1RQUBACaAAAAAA==.',
['旧梦']='旧梦:BAAALgAECgQJBAAAAA==.',
['昊焱']='昊焱:BAAALgAECgEJAQAAAA==.',
['星星']='星星糖丶:BAAALgAECgEJAgAAAA==.',
['星月']='星月喵:BAAALgAECgIJAwAAAA==.',
['星河']='星河:BAAALgAECgcJDAAAAA==.',
['星辰']='星辰之息:BAAALgAECgkJBAAAAA==.星辰梦影:BAAALgAECgQJCAAAAA==.',
['星陨']='星陨之痕:BAAALgAECgcJBwAAAA==.',
['晦涩']='晦涩的小安妮:BAAALgAECgQJBAAAAA==.',
['暗夜']='暗夜小巴:BAAALgAECggJDwAAAA==.',
['暗黑']='暗黑战舰:BAAALgAECgEJAQAAAA==.',
['暴力']='暴力释加牟尼:BAABLgAECn8UAAMKAAcJeRfhLAAAAgAKAAcJeRfhLAAAAgAJAAEJgBN3RAA7AAAAAA==.',
['暴躁']='暴躁的安安:BAABLgAECn8aAAITAAgJ0RvlGwAzAgATAAgJ0RvlGwAzAgAAAA==.',
['曦月']='曦月红尘:BAAALgAECgMJBAAAAA==.',
['月不']='月不圆:BAAALgAFFAEJAQAAAA==.',
['月泯']='月泯灭:BAAALgADCgIJAgAAAA==.',
['条形']='条形码:BAABLgAECn8ZAAMRAAgJ+BaNSQDtAQARAAgJ+BaNSQDtAQAUAAEJAAAoKwBIAAAAAA==.',
['来吧']='来吧死鬼:BAACLgAFFH8QAAIOAAQJvhtfDQBlAQAOAAQJvhtfDQBlAQAuAAQKfysAAg4ACAmSJeUEAHgDAA4ACAmSJeUEAHgDAAAA.',
['杰克']='杰克丹尼:BAAALgAECgcJCAAAAA==.',
['柏林']='柏林:BAAALgAECgkJEwAAAA==.',
['桔叶']='桔叶:BAAALgADCgEJAQAAAA==.',
['橙王']='橙王败寇:BAAALgAECgcJEgAAAA==.',
['欣爷']='欣爷万万岁:BAABLgAECn8XAAQJAAkJXhn0BwCmAgAJAAgJEhv0BwCmAgAKAAUJEQ3FXQA4AQAVAAYJ8xAOCADxAAAAAA==.',
['正义']='正义的榔头:BAAALgADCgMJAwAAAA==.',
['死亡']='死亡低语:BAACLgAFFH8GAAIWAAMJfQ5OKwDuAAAWAAMJfQ5OKwDuAAAuAAQKfxUAAhYACAkJFUdbAOABABYACAkJFUdbAOABAAAA.死亡领主阿克:BAAALgADCgEJAQAAAA==.',
['污总']='污总的愤怒:BAAALgADCgIJAgAAAA==.',
['沐水']='沐水寒:BAAALgADCgEJAQAAAA==.沐水菡:BAAALgAECgYJBgAAAA==.',
['法里']='法里奥:BAAALgAECgEJAQAAAA==.',
['泥墙']='泥墙圈一枝花:BAAALgADCggJCAAAAA==.',
['流星']='流星红尘:BAAALgADCgYJCQAAAA==.',
['浮冰']='浮冰掠影:BAAALgAECgEJAQAAAA==.',
['海苔']='海苔酱:BAAALgAECgYJBgAAAA==.',
['海阔']='海阔的天空:BAAALgADCgYJBgAAAA==.',
['淘气']='淘气:BAAALgAECgQJBAAAAA==.',
['清流']='清流:BAAALgAECgIJAgAAAA==.',
['清辉']='清辉夜凝:BAAALgAECgQJBAAAAA==.',
['温暖']='温暖:BAAALgADCggJDgAAAA==.',
['湮汐']='湮汐溟:BAAALgAECgIJAgAAAA==.',
['潇啸']='潇啸:BAAALgAFFAEJAQAAAA==.',
['澳洲']='澳洲大龙虾:BAAALgAECgUJBQAAAA==.',
['火焰']='火焰纹章:BAAALgADCgMJBAABLgAECggJHgAMAOwGAA==.',
['灰常']='灰常抱歉:BAAALgAECgYJBgAAAA==.',
['灼眼']='灼眼霞娜:BAAALgAECgkJCQAAAA==.',
['炽天']='炽天之翼:BAAALgAECgYJBgAAAA==.',
['炽翼']='炽翼:BAAALgAECgYJBgAAAA==.',
['然然']='然然:BAABLgAFFH8GAAITAAQJCwscBAAtAQATAAQJCwscBAAtAQABLgAFFAQJBgABAAcWAA==.',
['熊的']='熊的力量:BAAALgADCgIJAgAAAA==.',
['爆弹']='爆弹:BAAALgAECgMJBAABLgAECgYJHQAXAKslAA==.',
['爱上']='爱上沉醉疯狂:BAAALgAECgEJAQAAAA==.',
['爻坤']='爻坤:BAAALgAECgIJAgAAAA==.',
['片警']='片警:BAAALgAECgcJDAAAAA==.',
['牧欲']='牧欲乳:BAAALgAECgUJBQAAAA==.',
['独享']='独享忧愁:BAAALgAFFAEJAQAAAA==.',
['猫猫']='猫猫咪呀:BAAALgAECgIJAgAAAA==.',
['琉璃']='琉璃丶:BAAALgAECgEJAQAAAA==.',
['瓶了']='瓶了个邪:BAAALgAECgUJBQAAAA==.',
['白萌']='白萌萌:BAAALgAECgQJBAAAAA==.',
['百发']='百发百仲:BAAALgAECgYJBwAAAA==.',
['盘古']='盘古:BAABLgAFFH8FAAIFAAMJbwrkWgBMAAAFAAMJbwrkWgBMAAABLgAFFAMJBwABAJ4bAA==.',
['真鸡']='真鸡煲可耐:BAAALgAECgIJBQAAAA==.',
['眼色']='眼色:BAAALgADCgIJAgAAAA==.',
['瞅你']='瞅你咋地:BAAALgAECgIJAgAAAA==.',
['知命']='知命:BAAALgAECgEJAQAAAA==.',
['离谱']='离谱:BAAALgAECggJAQAAAA==.',
['秃头']='秃头爸爸:BAAALgAECgEJAQABLgAFFAUJBwAFAMcZAA==.',
['稻格']='稻格星:BAAALgAECgEJAQAAAA==.',
['竹汐']='竹汐:BAAALgADCgMJAwABLgADCgUJBQADAAAAAA==.',
['第七']='第七次日落:BAABLgAECn8UAAIYAAcJfxBwOADMAQAYAAcJfxBwOADMAQAAAA==.',
['羞羞']='羞羞小丸子:BAAALgADCgcJBwAAAA==.羞羞的小粉:BAAALgADCgUJBQAAAA==.',
['耀夜']='耀夜:BAAALgAECgUJBQAAAA==.',
['老奶']='老奶奶冲天辫:BAAALgAECgIJAgAAAA==.',
['能戈']='能戈善武:BAAALgAECgEJAQAAAA==.',
['艾希']='艾希娜尔:BAAALgAECgEJAgAAAA==.',
['荣耀']='荣耀战舰:BAAALgAECgUJBQAAAA==.',
['萌萌']='萌萌的半夏丶:BAABLgAFFH8IAAIGAAQJjg9wDgAQAQAGAAQJjg9wDgAQAQAAAA==.萌萌的小晨星:BAAALgAFFAIJAgAAAA==.',
['萤焰']='萤焰:BAAALgAECgQJBAAAAA==.',
['萨晶']='萨晶晶:BAAALgAECgEJAQAAAA==.',
['萨满']='萨满三号丿:BAAALgAFFAQJBAAAAA==.萨满二号丿:BAAALgAFFAQJBAAAAA==.萨满五号丿:BAAALgAFFAQJBAAAAA==.萨满六号丿:BAAALgAFFAQJBAAAAA==.',
['蒙奇']='蒙奇利德:BAAALgAECgcJCgAAAA==.',
['薰风']='薰风南渐:BAAALgAECgQJBAAAAA==.',
['蛋蛋']='蛋蛋也忧伤:BAAALgAFFAEJAQAAAA==.',
['言益']='言益:BAEALgAECgUJBgABLgAFFAUJEQAZAGMjAA==.',
['赛博']='赛博:BAAALgAFFAEJAQAAAA==.',
['超级']='超级变変变:BAAALgAFFAEJAQAAAA==.',
['迪克']='迪克牛仔:BAACLgAFFH8JAAIWAAQJSRG0LQDkAAAWAAQJSRG0LQDkAAAuAAQKfyIAAhYACAm5G1EGACACABYACAm5G1EGACACAAAA.',
['迪诺']='迪诺:BAAALgAECgYJCwAAAA==.',
['迷路']='迷路的下野:BAABLgAECn8eAAIaAAgJFRHNVQBSAQAaAAgJFRHNVQBSAQAAAA==.',
['追求']='追求放假:BAAALgAECgMJBQAAAA==.',
['遥远']='遥远的回忆:BAAALgAECgIJAwAAAA==.',
['邓淑']='邓淑娴:BAAALgAECgkJDwAAAA==.',
['酒仙']='酒仙阿哒哒:BAABLgAECn8ZAAIGAAcJ/hUOLgChAQAGAAcJ/hUOLgChAQAAAA==.',
['铁掌']='铁掌猫:BAAALgAECgIJAwAAAA==.',
['银色']='银色侍从:BAAALgAECgkJDQAAAA==.',
['阿斯']='阿斯卡拉亲王:BAAALgAECgIJAgAAAA==.',
['雅典']='雅典:BAAALgAFFAEJAQAAAA==.',
['雷加']='雷加尔:BAAALgAECgYJBgAAAA==.',
['雷布']='雷布朗多:BAAALgADCgcJBgAAAA==.',
['霸氣']='霸氣側漏:BAAALgAECgQJBQAAAA==.',
['风之']='风之无追:BAAALgAECgIJAgAAAA==.',
['风伤']='风伤雾影:BAABLgAECn8UAAQYAAcJkxPSbwAYAQAYAAcJkxPSbwAYAQAbAAYJTAdfUgACAQAcAAMJ3QSvJgCIAAAAAA==.',
['风暴']='风暴勇士:BAAALgADCgIJAwAAAA==.',
['风雨']='风雨之白狼:BAAALgAECgUJBQAAAA==.风雨同舟:BAAALgADCgYJCwAAAA==.风雨红尘:BAAALgAECgUJCAAAAA==.',
['马克']='马克西米利安:BAAALgAECgYJDAAAAA==.',
['驭兽']='驭兽者孙晓美:BAAALgADCgcJBwAAAA==.',
['鱼不']='鱼不游:BAAALgAECgEJAQABLgAFFAEJAQADAAAAAA==.',
['鳯凰']='鳯凰:BAAALgADCgEJAQAAAA==.',
['鸿韵']='鸿韵:BAAALgAECgEJAgAAAA==.',
['龙之']='龙之骑:BAAALgAFFAEJAQAAAA==.',
['龙城']='龙城夜如花:BAAALgAFFAEJAQAAAA==.龙城夜如雪:BAAALgAFFAEJAQAAAA==.',
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
