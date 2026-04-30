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

local lookup = {'Evoker-Preservation','Evoker-Devastation','DeathKnight-Unholy','DemonHunter-Havoc','Paladin-Retribution','Paladin-Holy','Warlock-Demonology','Druid-Feral','DeathKnight-Blood','DeathKnight-Frost','Warrior-Protection','Druid-Balance','Shaman-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Restoration','Warrior-Fury','Monk-Mistweaver','Warrior-Arms','Paladin-Protection','Unknown-Unknown','Priest-Shadow',}
local provider = {region='CN',realm='艾森娜',name='CN',type='weekly',zone=46,date='2026-04-25',data={Au='Augustrain:BAACLgAFFH8KAAMBAAQJLxwIBwB/AQABAAQJLxwIBwB/AQACAAEJpQhvCgBRAAAuAAQKfxYAAgEACAkjImUEAA0DAAEACAkjImUEAA0DAAAA.',
De='Deathpoppy:BAAALgAECgEJAQAAAA==.Desdemona:BAAALgAECgQJAgAAAA==.',
Fr='Freeloop:BAAALgAFFAEJAQAAAA==.',
Ri='Richardson:BAAALgAECgEJAQAAAA==.',
['一碗']='一碗面条:BAAALgAECgYJCAAAAA==.',
['一茗']='一茗茗一:BAAALgADCgIJAgAAAA==.',
['一路']='一路向西:BAAALgAECgEJAQAAAA==.',
['万卷']='万卷云:BAAALgAECgYJCQAAAA==.',
['不可']='不可宽恕:BAAALgAECgkJEAABLgAFFAYJBwADAEUUAA==.',
['不着']='不着四六:BAAALgAECgEJAQAAAA==.',
['两粒']='两粒小蛋:BAABLgAFFH8MAAIEAAQJ7xMzAQBZAQAEAAQJ7xMzAQBZAQAAAA==.',
['丨夜']='丨夜幕丨:BAAALgADCgUJBQAAAA==.',
['丨妖']='丨妖妖丨:BAAALgAECgMJBQAAAA==.',
['丨岂']='丨岂曰无衣丨:BAEALgAFFAEJBAABLgAECgcJFAADAHcSAA==.',
['乐子']='乐子:BAACLgAFFH8FAAMFAAIJUgcHKQCUAAAFAAIJUgcHKQCUAAAGAAEJtwLkEQBGAAAuAAQKfxgAAwUACAlCF7hKAAICAAUACAlCF7hKAAICAAYACAlnBa1FAGEBAAAA.',
['乐死']='乐死你:BAAALgAECgkJEAAAAA==.',
['云峰']='云峰子:BAAALgAFFAQJBAAAAA==.',
['云栖']='云栖松子糖:BAABLgAFFH8HAAIHAAMJCRitHQAOAQAHAAMJCRitHQAOAQAAAA==.',
['伊斯']='伊斯米尔:BAAALgAECgcJDgAAAA==.',
['伊达']='伊达航:BAABLgAECn8dAAIFAAkJwSEzAQDwAgAFAAkJwSEzAQDwAgABLgAFFAYJFQAIAI4mAA==.',
['休闲']='休闲玩家随意:BAAALgADCgkJCAAAAA==.',
['佩玉']='佩玉将将:BAAALgAECgIJAwAAAA==.',
['俺叫']='俺叫不紧张:BAAALgAECgkJAgAAAA==.',
['元曦']='元曦:BAAALgAECgQJBQAAAA==.',
['兔子']='兔子与老虎:BAAALgAECgEJAQAAAA==.',
['冬熊']='冬熊夏猫:BAAALgAECgQJBAAAAA==.',
['冰水']='冰水谣:BAAALgAECgEJAQAAAA==.',
['冰淼']='冰淼:BAAALgAECgIJAgAAAA==.',
['冷酷']='冷酷心灵:BAAALgAECgYJBwAAAA==.',
['凄凉']='凄凉的乌米:BAAALgAECgMJAwAAAA==.',
['别躲']='别躲应景的雨:BAAALgAECgEJAQAAAA==.',
['劍心']='劍心犹在:BAAALgAECgYJBgAAAA==.',
['北极']='北极之魔:BAAALgADCgEJAQAAAA==.北极极:BAABLgAECn8iAAMJAAkJ8h/PAgA5AwAJAAkJ8h/PAgA5AwAKAAEJAAAAAAAAAAABLgAFFAQJCwALAEcPAA==.',
['千语']='千语话禅:BAAALgAECgcJBwAAAA==.',
['午夜']='午夜小奶嘴:BAAALgAECgYJCwAAAA==.',
['博丽']='博丽灵梦:BAAALgAECgQJBAAAAA==.',
['反复']='反复攻击小明:BAAALgADCgYJBgABLgAFFAQJDQAMAGQOAA==.',
['叶凯']='叶凯:BAAALgAECgMJAwAAAA==.',
['吉田']='吉田步美:BAACLgAFFH8VAAIIAAYJjiYHAACeAgAIAAYJjiYHAACeAgAuAAQKfyQAAggACQl7JjUAAO8DAAgACQl7JjUAAO8DAAAA.',
['吕布']='吕布:BAAALgAFFAEJAgAAAA==.',
['呢喃']='呢喃:BAAALgAFFAEJAQABLgAFFAQJCwANAD0dAA==.',
['和气']='和气勿喷:BAAALgAECgYJBgAAAA==.',
['咕嘟']='咕嘟:BAAALgAECgcJEwABLgAFFAQJCwANAD0dAA==.',
['唯为']='唯为君倾:BAAALgAECgEJAQAAAA==.',
['噩梦']='噩梦大领主:BAAALgAECgQJAgAAAA==.',
['图电']='图电控阀:BAAALgAECgQJBQAAAA==.',
['圣神']='圣神意念:BAAALgAECgYJCgAAAA==.',
['塔娜']='塔娜亚:BAAALgADCgcJDQAAAA==.',
['壮士']='壮士且慢:BAEBLgAECn8UAAIDAAcJdxLuawCzAQADAAcJdxLuawCzAQAAAA==.',
['大表']='大表哥:BAAALgAECgYJAgAAAA==.',
['天天']='天天加:BAAALgAFFAEJAQAAAA==.',
['天威']='天威星:BAAALgAECgYJCAAAAA==.',
['奈娅']='奈娅:BAAALgAECgQJBQAAAA==.',
['奥利']='奥利维尔:BAAALgAECgYJCwAAAA==.',
['奥莱']='奥莱利亚:BAABLgAFFH8GAAMOAAQJfR3fCgBqAQAOAAQJfR3fCgBqAQAPAAIJJxZHFQCvAAAAAA==.奥莱萨满:BAAALgAECgQJBQAAAA==.',
['妖妖']='妖妖:BAAALgAECgYJBQAAAA==.',
['子如']='子如云:BAEALgAECgUJCAABLgAECgcJFAADAHcSAA==.',
['孤独']='孤独圆舞曲:BAAALgAECgQJBAAAAA==.',
['守护']='守护艾森娜:BAACLgAFFH8RAAIMAAUJex0/AwDAAQAMAAUJex0/AwDAAQAuAAQKfxsAAgwACAmtHpILAN0CAAwACAmtHpILAN0CAAAA.',
['寄予']='寄予不辞:BAAALgAECgYJCQAAAA==.',
['寒冰']='寒冰企鹅:BAAALgAFFAIJBAAAAA==.',
['寒夜']='寒夜涟漪:BAAALgAFFAEJAQAAAA==.寒夜青风:BAABLgAFFH8IAAMQAAMJZwjkFAC+AAAQAAMJZwjkFAC+AAAMAAMJDRFxFACgAAAAAA==.',
['封印']='封印堕落:BAABLgAFFH8FAAIFAAIJ6B8oHQC4AAAFAAIJ6B8oHQC4AAAAAA==.',
['小浪']='小浪黑:BAAALgADCgUJBQAAAA==.',
['小漫']='小漫漫:BAAALgAECgEJAgAAAA==.',
['小潘']='小潘兄台:BAABLgAFFH8FAAIRAAIJbB30FADCAAARAAIJbB30FADCAAAAAA==.',
['小饭']='小饭团:BAAALgAECgkJEgAAAA==.',
['小馒']='小馒头:BAAALgAECggJDAAAAA==.',
['就是']='就是清新:BAAALgAECgQJBwAAAA==.',
['布莱']='布莱恩钢须:BAAALgAECgEJAgAAAA==.布莱恩铁须:BAAALgAECgEJAgAAAA==.',
['布鲁']='布鲁斯邢:BAACLgAFFH8GAAISAAMJESSGBABBAQASAAMJESSGBABBAQAuAAQKfyEAAhIACAlpIk8FAA8DABIACAlpIk8FAA8DAAAA.',
['平凡']='平凡的平凡:BAAALgAECgkJCQAAAA==.',
['幽眀']='幽眀孤神:BAAALgAFFAMJBAAAAA==.',
['异度']='异度装甲:BAAALgAECgUJAgAAAA==.',
['影月']='影月晴空:BAAALgAECgIJBAAAAA==.',
['微微']='微微辣:BAAALgADCgQJBAAAAA==.',
['微雨']='微雨流光:BAAALgAFFAEJAQAAAA==.',
['德勒']='德勒克斯汀:BAAALgAFFAEJAQAAAA==.',
['愤怒']='愤怒橘子:BAABLgAFFH8HAAMTAAMJJRz/BQCzAAARAAIJdxoFFgC0AAATAAIJ3Br/BQCzAAAAAA==.',
['扎肥']='扎肥四:BAAALgAECgEJAQAAAA==.',
['执政']='执政官:BAAALgAECgEJAQAAAA==.',
['披萨']='披萨心肠:BAABLgAECn8bAAIUAAkJOhrFAwDXAgAUAAkJOhrFAwDXAgABLgAFFAQJCwALAEcPAA==.',
['拉的']='拉的牛:BAAALgAECgEJAQAAAA==.',
['控心']='控心:BAAALgADCgcJBwAAAA==.',
['斯卡']='斯卡哈丶:BAAALgAECgcJBwAAAA==.',
['时光']='时光她寂寞:BAAALgADCgYJBgAAAA==.',
['星空']='星空下的旋律:BAAALgAECgQJBgAAAA==.',
['映秋']='映秋:BAAALgAECgYJBwAAAA==.',
['昵称']='昵称都是浮云:BAAALgAECgEJAQAAAA==.',
['晨风']='晨风者:BAAALgAECgcJBwAAAA==.',
['暗夜']='暗夜医者:BAAALgADCgEJAQAAAA==.',
['暗影']='暗影怒火者:BAAALgADCgcJAQAAAA==.',
['月下']='月下长安:BAAALgADCgMJAwAAAA==.',
['本当']='本当上手:BAAALgAECgQJBwAAAA==.',
['桑塔']='桑塔纳:BAAALgAECgcJDgAAAA==.',
['梅丽']='梅丽塔丶:BAAALgAFFAIJBAABLgAFFAMJBwAHAAkYAA==.',
['梅赛']='梅赛德斯:BAAALgADCgUJAwAAAA==.',
['梦想']='梦想之光:BAAALgAECgIJAwAAAA==.',
['楚天']='楚天秋:BAAALgADCgUJBQAAAA==.',
['極樂']='極樂丨主宰:BAAALgADCgcJBwABLgAECgYJBgAVAAAAAA==.極樂仙貝:BAAALgAECgQJBAABLgAECgYJBgAVAAAAAA==.',
['橘子']='橘子呀:BAAALgAFFAIJAwABLgAFFAMJBwATACUcAA==.',
['欧不']='欧不胜欧:BAAALgADCgUJBQAAAA==.',
['歌姬']='歌姬初音未来:BAAALgAECgEJAQAAAA==.',
['毛利']='毛利小五郎:BAAALgAECgQJBAABLgAFFAYJFQAIAI4mAA==.',
['永恒']='永恒的终结:BAAALgAECgYJAgAAAA==.',
['沉睡']='沉睡的小猫:BAAALgAECgUJBQABLgAFFAUJBAAVAAAAAA==.',
['沉鱼']='沉鱼:BAAALgAFFAEJAQAAAA==.',
['沐浴']='沐浴圣光中:BAAALgAECgEJAQAAAA==.',
['法爷']='法爷爱吃土豆:BAAALgAECgIJAgAAAA==.',
['法神']='法神小雅:BAAALgAECgcJCQAAAA==.',
['法落']='法落梵尘:BAAALgAECgkJCQAAAA==.',
['浮萍']='浮萍寄圣辉:BAAALgAECgEJAgAAAA==.',
['淡定']='淡定的糖豆儿:BAAALgAECggJAQAAAA==.',
['漠雪']='漠雪:BAAALgAECgkJCQAAAA==.',
['炖虾']='炖虾大王:BAAALgAECgcJDQABLgAFFAYJBAAVAAAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAWAAcWAA==.',
['牛头']='牛头哥:BAAALgADCgMJBAAAAA==.',
['狂傲']='狂傲不羁:BAAALgAECgYJBgAAAA==.',
['狼人']='狼人小杖:BAAALgAECgIJAwAAAA==.',
['玄玄']='玄玄子:BAAALgAECgMJBQABLgAECgYJBgAVAAAAAA==.',
['珈菲']='珈菲猫:BAAALgAECgEJAgAAAA==.',
['琴瑟']='琴瑟:BAACLgAFFH8LAAINAAQJPR0tBgBlAQANAAQJPR0tBgBlAQAuAAQKfxYAAg0ACQnBHecFABQDAA0ACQnBHecFABQDAAAA.',
['瓦洛']='瓦洛伽:BAAALgADCgEJAQAAAA==.',
['瓦罗']='瓦罗嘉:BAAALgAECgUJBQAAAA==.',
['番石']='番石榴:BAAALgAECgIJAgAAAA==.',
['瘟疫']='瘟疫:BAAALgAECgYJBgAAAA==.',
['白煞']='白煞浩杰:BAAALgADCgEJAQAAAA==.',
['百兽']='百兽精灵王:BAAALgAECgcJEwAAAA==.',
['真画']='真画之月:BAAALgAECgYJBgAAAA==.',
['知我']='知我:BAAALgAFFAEJAQAAAA==.',
['石三']='石三牙:BAAALgADCgYJBgAAAA==.',
['禅丶']='禅丶叶:BAAALgAECgMJBAAAAA==.',
['米罗']='米罗丹银歌:BAAALgADCgUJBgAAAA==.',
['红帽']='红帽狼狼:BAAALgAFFAEJAQAAAA==.',
['纸上']='纸上画魅:BAAALgADCgEJAQAAAA==.',
['绝地']='绝地游侠:BAAALgAECgcJBwAAAA==.',
['罗门']='罗门达特:BAAALgADCgcJBwAAAA==.',
['肉雯']='肉雯雯:BAAALgAFFAEJAQAAAA==.',
['艾森']='艾森娜的门:BAAALgAECgUJBAAAAA==.艾森娜的风:BAAALgAECgYJBwAAAA==.',
['艾瑞']='艾瑞贝丝:BAAALgAECgYJCwAAAA==.',
['艾蕾']='艾蕾西娅:BAAALgAECgcJDgAAAA==.',
['艾薾']='艾薾旎莔莔:BAAALgADCgEJAQAAAA==.',
['芒莉']='芒莉莉:BAAALgAECgYJDQAAAA==.',
['苍云']='苍云间:BAAALgAECgIJAgABLgAFFAQJCgABAC8cAA==.',
['苏图']='苏图:BAAALgAECgYJCgAAAA==.',
['苦信']='苦信大师:BAAALgAECgEJAQAAAA==.',
['菡萏']='菡萏:BAAALgAECggJCAAAAA==.',
['蝎子']='蝎子莱莱:BAAALgAECgYJCAAAAA==.',
['血饮']='血饮刀锋:BAAALgADCgEJAQAAAA==.',
['贱笑']='贱笑:BAAALgAECgEJAQAAAA==.',
['赤菁']='赤菁风铃:BAAALgAECgYJCAABLgAFFAYJFQAIAI4mAA==.',
['赫绮']='赫绮:BAAALgAECgYJDQAAAA==.',
['轩辕']='轩辕欣雨:BAAALgADCgUJBQAAAA==.',
['辛龙']='辛龙:BAEALgAECgUJBwABLgAECgcJFAADAHcSAA==.',
['迈耶']='迈耶蒂丽娜:BAAALgADCgEJAQAAAA==.',
['迪丽']='迪丽热嘛:BAAALgAFFAIJBAAAAA==.',
['逆血']='逆血博杀:BAABLgAECn8YAAMPAAkJoBmnFACRAgAPAAgJORmnFACRAgAOAAYJGhUiOACCAQAAAA==.',
['鄂伦']='鄂伦春:BAAALgADCgYJBgAAAA==.',
['银河']='银河之星:BAAALgAECgEJAQAAAA==.银河之汐:BAAALgAECgIJAwAAAA==.银河之舞:BAAALgAECgYJBgAAAA==.银河之锋:BAAALgAECgYJCgAAAA==.银河之风:BAAALgAECgMJAwAAAA==.',
['防火']='防火龙:BAAALgAECgIJAgAAAA==.',
['阿拉']='阿拉丁:BAAALgAECggJDQAAAA==.',
['降龙']='降龙十八掌:BAAALgAECgMJAwAAAA==.',
['雨熊']='雨熊:BAAALgADCgQJBAAAAA==.',
['雨蝶']='雨蝶儿:BAAALgAECgYJCgAAAA==.',
['雪落']='雪落无迹:BAAALgAECgcJDgAAAA==.',
['雪飞']='雪飞:BAAALgAECgcJDQAAAA==.',
['颤栗']='颤栗:BAAALgAECgYJBwAAAA==.',
['風林']='風林火山:BAAALgADCgQJBgAAAA==.',
['风暴']='风暴小雪:BAAALgAECgEJAQAAAA==.',
['魂魄']='魂魄妖梦:BAAALgADCgIJAgAAAA==.',
['魏柔']='魏柔:BAAALgAFFAIJAgAAAA==.',
['鳯行']='鳯行者:BAAALgAECgEJAgAAAA==.',
['黑煞']='黑煞余庆:BAAALgADCgEJAQAAAA==.',
['黒喵']='黒喵桑:BAAALgAECgYJCQAAAA==.',
['龙龙']='龙龙丽丽:BAAALgAECgEJAQAAAA==.',
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
