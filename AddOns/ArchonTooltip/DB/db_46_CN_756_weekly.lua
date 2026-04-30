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

local lookup = {'Hunter-BeastMastery','DemonHunter-Havoc','DemonHunter-Devourer','Shaman-Restoration','Druid-Balance','Druid-Restoration','Druid-Guardian','Hunter-Marksmanship','Monk-Brewmaster','Monk-Mistweaver','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Mage-Frost','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Blood','Paladin-Retribution','Priest-Shadow','Unknown-Unknown','Priest-Holy','Priest-Discipline','Warrior-Fury',}
local provider = {region='CN',realm='玛多兰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aaiai:BAAALgADCgUJBQAAAA==.',
Al='Albus:BAAALgAECgMJAwAAAA==.Alexchow:BAAALgAECgcJBwAAAA==.',
Ar='Arale:BAABLgAECn8cAAIBAAgJ2RmYCgDAAQABAAgJ2RmYCgDAAQAAAA==.',
Au='August:BAAALgADCgMJAwAAAA==.',
Ba='Bansheeoi:BAACLgAFFH8QAAMCAAUJ4iFmAADyAQACAAUJ4iFmAADyAQADAAIJlQQYLwCJAAAuAAQKfyQAAwIACAnUHvcOAHQCAAIACAnAHvcOAHQCAAMACAmBGd80ACUCAAAA.Bansheeoo:BAAALgAECgIJAgAAAA==.',
Bi='Bigsmock:BAAALgADCgUJBQAAAA==.',
Ch='Chatty:BAAALgAECgUJBQAAAA==.',
Cx='Cx:BAABLgAECn8gAAIEAAgJJx9iCwDIAgAEAAgJJx9iCwDIAgAAAA==.',
Fu='Fusing:BAAALgAECgUJCQAAAA==.',
Lu='Lunacy:BAABLgAFFH8GAAMFAAMJcQoCFACjAAAFAAMJcQoCFACjAAAGAAEJ1RTnEABSAAAAAA==.',
Ma='Man:BAAALgAECgcJEQAAAA==.',
Ne='Nero:BAAALgAECgQJBAAAAA==.',
Re='Redmeow:BAAALgAECgcJBwAAAA==.Rejoice:BAAALgAECgEJAQAAAA==.',
Se='Sevenmangos:BAAALgAFFAEJAQAAAA==.',
Si='Silverman:BAAALgAECgUJCgAAAA==.',
To='Toge:BAABLgAECn8fAAIHAAgJyxySBgBeAgAHAAgJyxySBgBeAgAAAA==.',
Ve='Verlassen:BAAALgAECgYJBgAAAA==.',
Vi='Victorian:BAAALgAECgYJCAAAAA==.',
Vo='Volbird:BAAALgADCgYJBgAAAA==.',
Wa='Warlocksoul:BAAALgAECgkJEgAAAA==.',
Wo='Woho:BAAALgADCgYJBgAAAA==.',
Yo='Yoho:BAAALgAECgYJBgAAAA==.',
['一夙']='一夙愿一:BAAALgAECgEJAQAAAA==.',
['一支']='一支烟:BAAALgAECgEJAQAAAA==.',
['万古']='万古流芳:BAAALgADCgYJBgAAAA==.',
['不只']='不只是玩玩:BAAALgADCgUJBQAAAA==.',
['丘八']='丘八比目泪牛:BAAALgAECgcJDAAAAA==.',
['中美']='中美:BAABLgAFFH8FAAIIAAMJUxzWBACuAAAIAAMJUxzWBACuAAAAAA==.',
['为爱']='为爱嗜魔:BAAALgAECgEJAwAAAA==.为爱屠戮:BAAALgAECgUJCwAAAA==.',
['久久']='久久哥:BAABLgAECn8fAAIBAAgJxxw/DgDKAgABAAgJxxw/DgDKAgAAAA==.',
['乌爾']='乌爾奇奥拉:BAAALgAECgEJAQAAAA==.',
['乖乖']='乖乖德:BAAALgAECgYJCQAAAA==.乖乖猎手:BAAALgAECgEJAQAAAA==.',
['亚瑟']='亚瑟王:BAABLgAFFH8FAAIDAAMJ7A6pKgCaAAADAAMJ7A6pKgCaAAAAAA==.',
['他化']='他化自在天:BAAALgAECgUJBQAAAA==.',
['伊德']='伊德海拉:BAAALgAECgMJAwAAAA==.',
['休息']='休息站神:BAAALgAECgYJDAAAAA==.',
['传说']='传说中的菠菜:BAACLgAFFH8GAAIJAAMJoRq1HQCFAAAJAAMJoRq1HQCFAAAuAAQKfxYAAwkABwkfIYYOAK0CAAkABwkfIYYOAK0CAAoABglgD001AB0BAAAA.',
['你是']='你是炮我是灰:BAAALgADCgYJBgAAAA==.',
['你讲']='你讲话大点声:BAAALgADCgcJBwAAAA==.',
['兰色']='兰色忧郁:BAAALgADCgcJBwAAAA==.',
['冥月']='冥月:BAAALgAECgYJCQAAAA==.',
['冬山']='冬山如睡:BAABLgAFFH8GAAILAAMJ3RGrRgCXAAALAAMJ3RGrRgCXAAAAAA==.',
['刘震']='刘震撼:BAAALgAECgEJAQAAAA==.',
['十无']='十无畏十:BAAALgAECgMJBAAAAA==.',
['半颗']='半颗糖:BAAALgADCgMJAwAAAA==.',
['卖油']='卖油翁:BAAALgAECgYJBwAAAA==.',
['卖碳']='卖碳翁:BAACLgAFFH8FAAIFAAMJhRkXDQAOAQAFAAMJhRkXDQAOAQAuAAQKfxoAAgUACAkBIsQBAFgCAAUACAkBIsQBAFgCAAAA.',
['卖糖']='卖糖术神:BAABLgAECn8aAAMMAAgJbyHhEADzAgAMAAgJaCHhEADzAgANAAIJACTePQC9AAABLgAFFAYJFQAOABwlAA==.',
['卷烟']='卷烟:BAAALgAECgQJBAAAAA==.',
['又白']='又白又胖:BAAALgAECggJCQAAAA==.',
['吕布']='吕布曰貂蝉丶:BAAALgAECgIJAgAAAA==.',
['咔咔']='咔咔一顿:BAABLgAECn8WAAMBAAcJNR5eEwCcAgABAAcJNR5eEwCcAgAIAAYJZg1zTQAbAQABLgAFFAMJBQAPAHQbAA==.咔咔二顿:BAACLgAFFH8FAAIPAAMJdBugDwAHAQAPAAMJdBugDwAHAQAuAAQKfyQAAw8ACQnvHpoKAMwCAA8ACAl5HpoKAMwCABAABgnpHZwPAOEBAAAA.',
['哦嘿']='哦嘿呦:BAAALgAFFAEJAgAAAA==.',
['啊多']='啊多给:BAAALgAECgcJCAAAAA==.',
['喵之']='喵之哀熵:BAAALgAFFAUJBAAAAA==.',
['噬阳']='噬阳:BAAALgAECgYJDAAAAA==.',
['四大']='四大名柱:BAAALgAECgEJAQAAAA==.',
['团队']='团队混子:BAAALgAECgYJCwAAAA==.',
['土人']='土人很厚道:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光在上:BAAALgAECgYJBwAAAA==.圣光永动机:BAAALgAECgYJBgAAAA==.',
['地狱']='地狱小不点:BAAALgAFFAEJAQABLgAFFAMJBQADAOwOAA==.',
['夏末']='夏末丶将至:BAAALgAECgcJDQABLgAFFAYJFQARADIaAA==.',
['夜光']='夜光丶:BAAALgAECgcJBAAAAA==.',
['夜的']='夜的第柒章:BAAALgAFFAEJAQAAAA==.',
['大卫']='大卫高栢飞:BAAALgAECgQJCAAAAA==.',
['大罗']='大罗法咒:BAAALgAECgkJCgAAAA==.',
['天灰']='天灰:BAAALgAECgcJDQAAAA==.',
['女皇']='女皇陛下丶:BAAALgADCgYJAwAAAA==.',
['小新']='小新喷火:BAAALgAFFAIJAwAAAA==.小新青涩:BAAALgAFFAEJAQAAAA==.',
['小毛']='小毛笔:BAABLgAECn8WAAISAAgJBx/lEwD0AgASAAgJBx/lEwD0AgABLgAFFAMJBQAPAHQbAA==.',
['小陌']='小陌:BAAALgAECgQJBAAAAA==.',
['小飘']='小飘飘:BAAALgAECgQJBwAAAA==.',
['小鱼']='小鱼哥啊:BAAALgAECgEJAQAAAA==.',
['就不']='就不告诉你:BAAALgAECgQJBAAAAA==.',
['峨眉']='峨眉派:BAAALgAECgYJDwAAAA==.',
['帆稀']='帆稀:BAABLgAECn8UAAIPAAcJ7CHBDwB7AgAPAAcJ7CHBDwB7AgAAAA==.',
['希瑞']='希瑞拉:BAAALgAECgQJBQAAAA==.',
['幻灭']='幻灭彩蝶:BAABLgAFFH8GAAIGAAMJpx+pFQC2AAAGAAMJpx+pFQC2AAAAAA==.',
['快勒']='快勒:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔少女:BAAALgADCgUJBQAAAA==.',
['惊艳']='惊艳如初:BAAALgAECgYJBgAAAA==.',
['我来']='我来自地狱:BAABLgAECn8WAAILAAcJTxkLSAAbAgALAAcJTxkLSAAbAgAAAA==.',
['我爱']='我爱一根柴柴:BAAALgADCgIJAgAAAA==.',
['抓个']='抓个小德养着:BAAALgAECgcJBwAAAA==.',
['掂过']='掂过碌蔗:BAAALgAECgYJDQAAAA==.',
['无光']='无光月:BAAALgADCgcJBwAAAA==.',
['无影']='无影:BAAALgADCgEJAQAAAA==.',
['昔我']='昔我往矣:BAAALgAFFAQJBAAAAA==.',
['星玲']='星玲珑:BAAALgAECgYJBgAAAA==.',
['暗影']='暗影血魔:BAAALgAECgcJBwAAAA==.',
['暗黑']='暗黑华莱士:BAAALgADCgkJCQAAAA==.',
['暮光']='暮光救赎:BAAALgAECgEJAQAAAA==.',
['曦霜']='曦霜:BAAALgAECgYJCQAAAA==.',
['木易']='木易石:BAAALgADCgMJAwAAAA==.',
['朱淑']='朱淑虹:BAAALgAECgIJAgAAAA==.',
['栀灵']='栀灵月露:BAAALgAECgIJAgAAAA==.',
['栗山']='栗山酱未来:BAAALgAECgEJAQAAAA==.',
['樱雨']='樱雨绵绵:BAAALgAECgcJCAAAAA==.',
['水晶']='水晶晶:BAAALgAFFAEJAQAAAA==.',
['沐夏']='沐夏丶丶:BAAALgAECgEJAQAAAA==.',
['没世']='没世不忘:BAAALgAECgEJAQAAAA==.',
['河流']='河流午后:BAAALgAECgYJBgABLgAFFAMJBQAPAFoLAA==.',
['泰华']='泰华英雄:BAAALgADCgEJAQAAAA==.',
['温蕾']='温蕾萨风行者:BAABLgAFFH8FAAIBAAIJlAbYGgCZAAABAAIJlAbYGgCZAAAAAA==.',
['溪亭']='溪亭:BAAALgAECgYJBgAAAA==.',
['漫漫']='漫漫亦灿灿:BAAALgAECgkJCgAAAA==.',
['火龙']='火龙果:BAAALgADCgYJCAAAAA==.',
['灼灼']='灼灼其华丶:BAACLgAFFH8JAAIJAAMJHBEkDACSAAAJAAMJHBEkDACSAAAuAAQKfxkAAgkABwljGdkjAOMBAAkABwljGdkjAOMBAAAA.',
['炙热']='炙热圣光:BAAALgAECgEJAQAAAA==.',
['炜少']='炜少在此:BAAALgAECgcJDAAAAA==.',
['然然']='然然:BAABLgAFFH8JAAITAAQJSw0nCABEAQATAAQJSw0nCABEAQABLgAFFAQJBgATAAcWAA==.',
['爱之']='爱之煞:BAAALgAECgcJDQAAAA==.',
['王爷']='王爷萨:BAAALgADCgYJBgAAAA==.',
['看看']='看看我的大龙:BAABLgAECn8VAAMPAAkJ5hlYCwDAAgAPAAkJ5hlYCwDAAgAQAAYJowapIwAKAQAAAA==.',
['睡眠']='睡眠图腾:BAAALgAECgcJBwAAAA==.',
['神之']='神之悲鸣:BAAALgAECgIJAgAAAA==.',
['空谷']='空谷悠然:BAAALgAECgMJAwAAAA==.',
['空酒']='空酒杯:BAAALgAECgQJBAAAAA==.',
['突突']='突突:BAABLgAFFH8FAAIPAAMJWgsnGQCeAAAPAAMJWgsnGQCeAAAAAA==.',
['第一']='第一次射:BAAALgADCgUJDQAAAA==.',
['筱星']='筱星尘:BAAALgADCgcJBwAAAA==.',
['紫色']='紫色信念:BAAALgAECgIJAgAAAA==.紫色堕落:BAAALgAECgQJBQAAAA==.紫色复仇:BAAALgAECgYJDAAAAA==.紫色逍遙:BAAALgAECgUJBgAAAA==.',
['约尔']='约尔灬媞西婭:BAAALgAECgYJCwAAAA==.',
['维娅']='维娅:BAAALgAECgUJBQAAAA==.',
['美甲']='美甲丶控:BAAALgADCgcJDQAAAA==.',
['老王']='老王哥哥:BAAALgAECgYJBgABLgAECggJCQAUAAAAAA==.',
['胡须']='胡须圣光妹:BAAALgADCgYJDAAAAA==.',
['艾尔']='艾尔达拉:BAAALgAECgYJBgAAAA==.',
['艾露']='艾露莎丶月歌:BAAALgAECgcJDAAAAA==.',
['花惹']='花惹尘:BAAALgAECgYJBgAAAA==.',
['英诺']='英诺森三世:BAAALgAECgEJAQAAAA==.',
['英雄']='英雄归来:BAAALgAFFAIJAwAAAA==.',
['萨琪']='萨琪玛:BAAALgAECgkJCQAAAA==.',
['薄荷']='薄荷薄荷薄荷:BAAALgADCgUJBQAAAA==.',
['薯条']='薯条:BAACLgAFFH8FAAISAAIJ9xOLIwClAAASAAIJ9xOLIwClAAAuAAQKfxUAAhIABglBIr9BACACABIABglBIr9BACACAAAA.',
['蚊香']='蚊香:BAAALgAECgYJBgAAAA==.',
['西神']='西神西神西神:BAACLgAFFH8VAAIOAAYJHCUWAgB0AgAOAAYJHCUWAgB0AgAuAAQKfx4AAg4ACQltJcMCANMDAA4ACQltJcMCANMDAAAA.',
['豆豆']='豆豆好運氣:BAAALgAECgYJDAAAAA==.',
['贝丝']='贝丝特拉:BAAALgAECgYJBgAAAA==.',
['轰二']='轰二零:BAAALgAECgIJAgAAAA==.',
['迷路']='迷路的枸杞茶:BAAALgADCgEJAQAAAA==.',
['退相']='退相干:BAAALgAECgQJBAAAAA==.',
['遇见']='遇见狐狸:BAABLgAECn8kAAMVAAgJvxPHBgClAQAVAAgJvxPHBgClAQAWAAMJiAQrSAB8AAAAAA==.',
['铁手']='铁手:BAAALgAECgYJBwAAAA==.',
['铃木']='铃木霍普:BAAALgADCgQJBAAAAA==.',
['银雁']='银雁神狼:BAAALgADCgEJAQAAAA==.',
['阿尔']='阿尔尤拉诺斯:BAAALgAFFAEJAgAAAA==.',
['随贝']='随贝尔去冒险:BAAALgAECgUJBAAAAA==.',
['雷霆']='雷霆战机:BAAALgAECgUJCAAAAA==.',
['风云']='风云:BAAALgAECgEJAQAAAA==.',
['风火']='风火:BAAALgAECgQJBAAAAA==.',
['风继']='风继续吹:BAAALgAECgEJAQAAAA==.',
['飛舞']='飛舞的花猪:BAAALgAECgYJBgAAAA==.',
['饭鱼']='饭鱼蛋:BAAALgAFFAQJBAAAAA==.',
['香辣']='香辣蓝莓皮:BAABLgAFFH8IAAIOAAMJMxHAPgCvAAAOAAMJMxHAPgCvAAAAAA==.香辣西瓜皮:BAAALgAECgUJBwAAAA==.',
['鬼语']='鬼语者:BAAALgAECgUJBwAAAA==.',
['魔术']='魔术大帝:BAAALgAECgEJAQAAAA==.',
['鱼老']='鱼老师黑的本:BAAALgAFFAEJAQABLgAFFAYJFQAOABwlAA==.',
['鹤仙']='鹤仙人:BAABLgAFFH8HAAIXAAIJVQ0oGgCgAAAXAAIJVQ0oGgCgAAAAAA==.',
['麽麽']='麽麽香:BAAALgAECgYJDgAAAA==.',
['黄河']='黄河之水:BAAALgAECgUJBwAAAA==.黄河法:BAAALgAECgEJAQAAAA==.',
['黎华']='黎华英雄:BAAALgADCgIJAgAAAA==.',
['默数']='默数繁华:BAAALgAECggJCwAAAA==.',
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
