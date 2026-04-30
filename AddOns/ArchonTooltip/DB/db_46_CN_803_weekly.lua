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

local lookup = {'Unknown-Unknown','Paladin-Holy','Paladin-Protection','DeathKnight-Unholy','Mage-Frost','Mage-Arcane','DemonHunter-Vengeance','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Paladin-Retribution','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Warrior-Fury','Warrior-Protection','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Priest-Holy','Druid-Balance','DemonHunter-Devourer','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Druid-Feral','Druid-Restoration','Warrior-Arms','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Hunter-Marksmanship','Hunter-Survival','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood',}
local provider = {region='CN',realm='艾萨拉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alisoramio:BAAALgAFFAIJBAABLgAFFAMJAwABAAAAAA==.',
Ar='Archmagefan:BAAALgADCgEJAQAAAA==.',
Be='Becky:BAAALgADCgMJAwAAAA==.',
Da='Dark:BAAALgAECgQJBAAAAA==.',
Dk='Dk:BAAALgAECgMJAwAAAA==.',
Et='Ethen:BAAALgAECgYJBgAAAA==.',
Ev='Evilwhisper:BAAALgAECgUJBQAAAA==.',
Ex='Explosion:BAAALgAFFAEJAQAAAA==.',
Fa='Fabulous:BAAALgAECgYJEQAAAA==.Fangjii:BAAALgAECggJDQAAAA==.',
Fe='Fe:BAAALgADCgEJAQAAAA==.',
Fi='Fishbean:BAAALgADCgMJAwAAAA==.',
Gr='Grannie:BAACLgAFFH8LAAICAAQJ5B4KCABQAQACAAQJ5B4KCABQAQAuAAQKfxYAAwMACAlBHZ0PAMsBAAMABgnzGZ0PAMsBAAIABwkLGHg7AIsBAAAA.Grasia:BAABLgAFFH8GAAIEAAMJTh7mHgAhAQAEAAMJTh7mHgAhAQAAAA==.',
Ha='Halolich:BAAALgAECgYJAQABLgAFFAUJAgABAAAAAA==.',
Je='Jerome:BAAALgAECgEJAQAAAA==.',
Le='Leslies:BAAALgAECgUJBgAAAA==.',
Li='Lisccenylin:BAAALgAFFAMJAwAAAA==.',
Lu='Luckyrabbit:BAAALgAECgEJAQAAAA==.',
Me='Merci:BAAALgADCgEJAQAAAA==.',
Mi='Mikosnow:BAAALgAECgIJAwAAAA==.',
Mo='Monday:BAAALgADCgYJBgAAAA==.',
Ne='Nexus:BAAALgAECgQJBAAAAA==.',
Or='Orzmage:BAAALgADCgEJAQAAAA==.Orzwarlock:BAAALgADCgIJAgAAAA==.',
Ot='Otherpaladin:BAAALgAECgEJAgAAAA==.',
Po='Po:BAAALgAECgUJBQAAAA==.',
Re='Regina:BAAALgADCgcJBwAAAA==.Reopenlolz:BAACLgAFFH8PAAMFAAQJNxj3FAB2AQAFAAQJohf3FAB2AQAGAAEJZhV+AQBVAAAuAAQKfxgAAwUACAkMIrskAOACAAUACAkMIrskAOACAAYAAQlDIKsZAEoAAAAA.Rexxodh:BAABLgAFFH8FAAIHAAMJRQxjAQC9AAAHAAMJRQxjAQC9AAABLgAFFAQJCwACAOQeAA==.Rexxooxx:BAACLgAFFH8IAAIIAAQJUAtaDwAIAQAIAAQJUAtaDwAIAQAuAAQKfxUABAgABwl8HPcyAIUBAAgABgkOHPcyAIUBAAkAAwlHGh1OANkAAAoAAglGB01iAEcAAAEuAAUUBAkLAAIA5B4A.',
Ro='Rosenkreutz:BAAALgADCgEJAQAAAA==.',
Ss='Sseu:BAAALgAECgEJAQAAAA==.',
St='Stultiferana:BAAALgAECgcJBAAAAA==.',
Su='Sunny:BAAALgAECgQJBgAAAA==.',
Ta='Tamika:BAAALgAECgUJBQAAAA==.',
Ve='Vetee:BAAALgAFFAUJBAAAAA==.',
Yo='Yontinued:BAAALgAFFAIJAgAAAA==.',
['一一']='一一防骑一一:BAAALgAECgMJAwAAAA==.',
['一喜']='一喜洋洋一:BAAALgAECgYJDAAAAA==.',
['一树']='一树梨花:BAAALgAECgYJCAAAAA==.',
['一步']='一步捣胃:BAAALgAECgUJBgAAAA==.',
['一脸']='一脸美人痣:BAAALgAECgQJBAAAAA==.',
['不叫']='不叫的牛:BAAALgAECgUJBwAAAA==.',
['不堕']='不堕黄泉:BAAALgAECgMJAwAAAA==.',
['不学']='不学无术:BAAALgAECgUJBQAAAA==.',
['不惑']='不惑者:BAAALgADCgEJAQAAAA==.',
['世壹']='世壹僧:BAAALgAFFAUJBAAAAA==.',
['世才']='世才:BAAALgAECgEJAQAAAA==.',
['世纪']='世纪之星:BAAALgAECgcJCgAAAA==.',
['丨曉']='丨曉丶銧丿:BAAALgAECgMJAQAAAA==.',
['丨瘟']='丨瘟丨疫丨:BAABLgAFFH8MAAIEAAQJqxf6BgBVAQAEAAQJqxf6BgBVAQAAAA==.',
['丶夕']='丶夕芮丶:BAAALgAECgYJDQAAAA==.',
['丸丸']='丸丸:BAAALgAECgUJBQAAAA==.',
['久还']='久还:BAAALgAECgUJAwAAAA==.',
['二丁']='二丁目:BAAALgAECgEJAQAAAA==.',
['云中']='云中影:BAAALgAECgYJBgAAAA==.',
['云焕']='云焕月光:BAAALgAECgQJBAAAAA==.云焕荣耀:BAAALgAFFAIJAgAAAA==.',
['云端']='云端的轨迹:BAAALgAFFAUJAgAAAA==.',
['亮仔']='亮仔亮仔:BAAALgAECgYJBgAAAA==.亮仔别假死:BAAALgADCgYJBgAAAA==.亮仔别闪:BAAALgADCgEJAQAAAA==.亮仔无敌:BAABLgAECn8UAAILAAYJ0htbYwC7AQALAAYJ0htbYwC7AQAAAA==.',
['人生']='人生须尽欢:BAAALgAECgUJBQAAAA==.',
['今夕']='今夕何夕:BAAALgAECgcJDQAAAA==.',
['以德']='以德服仁:BAAALgAECgcJBwAAAA==.',
['伊扎']='伊扎克斯:BAACLgAFFH8HAAIMAAMJDCBjGQAmAQAMAAMJDCBjGQAmAQAuAAQKfxQABA0ACAmlIBsLAIoBAA0ABQl1IRsLAIoBAA4ABAkNHOUjADoBAAwABAlQGfGcAB8BAAAA.',
['伊犁']='伊犁丹:BAAALgAECgMJAwAAAA==.',
['伴读']='伴读小书童:BAAALgAECgEJAgAAAA==.',
['光头']='光头强:BAAALgAECgEJAQAAAA==.',
['光年']='光年丶夏:BAAALgADCgEJAQAAAA==.',
['兔兔']='兔兔吃蘑菇:BAAALgAECgYJDQAAAA==.',
['八剑']='八剑初晴:BAAALgAECgYJDwAAAA==.',
['六辣']='六辣子夹馍:BAAALgAECgUJCgAAAA==.',
['兽血']='兽血沸腾:BAAALgADCgYJCAAAAA==.',
['冥姬']='冥姬:BAAALgAECgEJAQAAAA==.',
['冥王']='冥王丶雷利:BAAALgAECgEJAQAAAA==.',
['冰镇']='冰镇的芒果:BAAALgAECgUJDQAAAA==.',
['冰雕']='冰雕猫:BAACLgAFFH8JAAIKAAQJUiEeBwBPAQAKAAQJUiEeBwBPAQAuAAQKfxgAAgoABwlaHl0XAAcCAAoABwlaHl0XAAcCAAAA.',
['冰餜']='冰餜:BAAALgAFFAIJBAAAAA==.',
['冷夜']='冷夜寒风:BAAALgAECgEJAQAAAA==.',
['切勿']='切勿喷向眼睛:BAAALgAFFAIJAwABLgAFFAQJCwACAOQeAA==.',
['利拉']='利拉鲁肽:BAAALgAECgMJAwAAAA==.',
['制裁']='制裁者瞎混:BAAALgAECgUJCAAAAA==.',
['加多']='加多寳:BAAALgADCgQJBAAAAA==.',
['北方']='北方青青:BAAALgAECgEJAQAAAA==.',
['医见']='医见倾情:BAAALgADCgkJGAAAAA==.',
['卡尔']='卡尔丶血蹄:BAABLgAFFH8FAAMPAAIJswOGDgCPAAAPAAIJ6wKGDgCPAAAQAAEJsgNoEQA4AAAAAA==.',
['卤煮']='卤煮老湿:BAAALgAECgEJAQAAAA==.',
['变形']='变形德纲:BAAALgADCgYJBgAAAA==.',
['可爱']='可爱的炮炮:BAACLgAFFH8GAAIFAAIJ8RC2PQCxAAAFAAIJ8RC2PQCxAAAuAAQKfxUAAgUABwlnG21aACoCAAUABwlnG21aACoCAAAA.',
['叶奈']='叶奈法:BAAALgAECgIJAgAAAA==.',
['叶曼']='叶曼妮:BAAALgAECgYJCQAAAA==.',
['叹息']='叹息的笙箫:BAACLgAFFH8IAAIRAAMJmw1iCgDYAAARAAMJmw1iCgDYAAAuAAQKfyAAAxEACAkICyJAAIABABEACAkICyJAAIABABIAAgn1A3+AAEUAAAAA.',
['吳彦']='吳彦祖:BAAALgAECgEJAQAAAA==.',
['哈咭']='哈咭咪:BAACLgAFFH8GAAILAAMJIBaNEgARAQALAAMJIBaNEgARAQAuAAQKfxcAAgsABwnKHqwmAIsCAAsABwnKHqwmAIsCAAAA.',
['哈基']='哈基米:BAAALgAECgIJAgAAAA==.哈基米小甲:BAAALgAFFAIJBAAAAA==.',
['唐家']='唐家三藏:BAAALgAECgEJAQAAAA==.',
['嗷嗷']='嗷嗷就是炫:BAAALgAECgQJCAAAAA==.嗷嗷流氓一代:BAAALgAFFAIJBAABLgAFFAMJCAAFALAMAA==.',
['四季']='四季夏目丷:BAAALgAECgYJBgABLgAECgkJEQABAAAAAA==.',
['坤坤']='坤坤:BAAALgAECgQJBAAAAA==.',
['坦荡']='坦荡:BAAALgADCgYJCQAAAA==.',
['墓偶']='墓偶者:BAAALgADCgUJBQAAAA==.',
['夏丨']='夏丨端:BAAALgADCgUJBQAAAA==.',
['夏洛']='夏洛特没用:BAAALgAECgEJAQAAAA==.',
['多娇']='多娇:BAABLgAFFH8FAAITAAIJEA35GgCYAAATAAIJEA35GgCYAAAAAA==.',
['夜之']='夜之絮语:BAABLgAFFH8FAAIUAAMJ3hKMCQDOAAAUAAMJ3hKMCQDOAAAAAA==.',
['夜月']='夜月陨:BAABLgAECn8VAAIVAAYJIBl1KAC7AQAVAAYJIBl1KAC7AQAAAA==.夜月飘逸:BAAALgAECgMJAwAAAA==.',
['大祭']='大祭司瞎混:BAAALgAECgYJBgAAAA==.',
['大腰']='大腰子哥哥:BAAALgAECgYJBgAAAA==.',
['天使']='天使也掉毛:BAAALgADCgMJAwAAAA==.天使星座:BAAALgADCgMJAwAAAA==.',
['天涯']='天涯共银辉:BAAALgAFFAIJAgAAAA==.',
['天赋']='天赋:BAAALgAECgYJBgAAAA==.',
['太妃']='太妃榛果:BAAALgAECgEJAwAAAA==.',
['太胖']='太胖卡潜行:BAAALgAECgMJAwAAAA==.',
['太阳']='太阳:BAAALgADCgEJAQAAAA==.',
['夺命']='夺命者:BAAALgAECgEJAQAAAA==.',
['夺魂']='夺魂:BAAALgAECgYJCgAAAA==.',
['女娲']='女娲:BAAALgADCgEJAQAAAA==.',
['妖怪']='妖怪般杀戮:BAABLgAFFH8HAAIFAAMJKwK0HADPAAAFAAMJKwK0HADPAAAAAA==.',
['娜鲁']='娜鲁:BAAALgAECgYJCgAAAA==.',
['孤单']='孤单猎鹰:BAAALgAECgEJAgAAAA==.',
['守岸']='守岸:BAAALgAECgQJBgAAAA==.',
['安娜']='安娜罗曼诺娃:BAAALgAECgUJDwAAAA==.',
['安惜']='安惜:BAAALgAECgIJAgAAAA==.',
['安洁']='安洁妮法奈儿:BAAALgAECgYJBgAAAA==.',
['宫乄']='宫乄琉璃:BAAALgAFFAIJAwAAAA==.',
['寒蝉']='寒蝉鸣泣之时:BAAALgAECgIJBAAAAA==.',
['小兰']='小兰如玉:BAAALgAECgEJAQAAAA==.',
['小家']='小家碧玉:BAAALgAECgQJBAAAAA==.',
['小小']='小小叮铛:BAAALgAECgcJCAAAAA==.小小昕:BAAALgADCgUJBQAAAA==.小小若水:BAAALgADCgcJBwAAAA==.',
['小星']='小星闪闪:BAACLgAFFH8PAAIWAAQJox+3BQBcAQAWAAQJox+3BQBcAQAuAAQKfxgABBYACAnyHk8pAF0CABYACAkTHk8pAF0CAAcABQk0IqALAKMBABcAAQm/AZpuADcAAAAA.',
['小月']='小月落:BAACLgAFFH8JAAMYAAMJfiGCCwAlAQAYAAMJfiGCCwAlAQAZAAIJEBd+DgCyAAAuAAQKfxUABBgABwlIIkkOAFYCABgABwnSIUkOAFYCABkABQlKIqIeAOMBABQAAQk4HmR4AEgAAAAA.小月落变猫啦:BAABLgAFFH8QAAIaAAQJhyYSAADCAQAaAAQJhyYSAADCAQAAAA==.',
['小瓶']='小瓶盖:BAAALgAECgUJBQAAAA==.',
['小芒']='小芒果:BAAALgAECggJBQAAAA==.',
['岳美']='岳美美:BAAALgAECgQJBgAAAA==.',
['巅峰']='巅峰灬圣女:BAAALgAECgEJAQAAAA==.',
['常庆']='常庆:BAAALgADCgEJAQAAAA==.',
['并非']='并非小甲:BAAALgAECgEJAQAAAA==.',
['幻狱']='幻狱行者:BAAALgAECgYJCwAAAA==.',
['康斯']='康斯坦丁乄许:BAABLgAFFH8KAAILAAMJ6hp3CgARAQALAAMJ6hp3CgARAQAAAA==.',
['建行']='建行董事长:BAAALgADCgUJBQAAAA==.',
['开心']='开心的圣光:BAAALgADCgUJBQAAAA==.',
['影风']='影风丶轻月:BAAALgADCgIJAgAAAA==.',
['彼岸']='彼岸灬羽:BAAALgAECgYJBwAAAA==.',
['微凉']='微凉:BAAALgADCgEJAQAAAA==.',
['德芙']='德芙:BAAALgAECgYJCwAAAA==.',
['德菜']='德菜兼备:BAABLgAFFH8IAAIbAAMJlhBJEADnAAAbAAMJlhBJEADnAAAAAA==.',
['德醉']='德醉:BAAALgAECgkJEQABLgAFFAUJCQAVACUgAA==.',
['忘川']='忘川:BAAALgAFFAIJAgAAAA==.',
['快乐']='快乐小仙:BAAALgADCgcJBwAAAA==.',
['怒疯']='怒疯:BAAALgAECgkJEwAAAA==.',
['恰恰']='恰恰普洱茶:BAAALgADCgEJAQAAAA==.',
['愛如']='愛如潮水:BAAALgADCgQJBAAAAA==.',
['我真']='我真是哈士奇:BAAALgADCgIJAwAAAA==.',
['我要']='我要开始闹了:BAAALgAECgYJEQAAAA==.',
['抠脚']='抠脚彪哥:BAAALgADCgQJBAAAAA==.抠脚彪汉:BAAALgADCgQJBAAAAA==.',
['拦截']='拦截:BAAALgAECgQJBQAAAA==.',
['拿瞎']='拿瞎混换糖糖:BAAALgAECgYJBgAAAA==.',
['授予']='授予力量:BAAALgADCgYJBgAAAA==.',
['断誓']='断誓之剑:BAAALgAECgkJCQAAAA==.',
['旋转']='旋转的狂想:BAAALgADCgEJAQAAAA==.',
['无名']='无名火:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌奥特曼:BAAALgAECgYJCgAAAA==.',
['明前']='明前奶绿:BAAALgAFFAQJAQAAAA==.',
['明明']='明明有怪兽:BAAALgAECgkJCQAAAA==.',
['明月']='明月玉才:BAAALgAECgIJAwAAAA==.',
['星祈']='星祈:BAAALgAECgUJBwAAAA==.星祈骑士:BAAALgAECgEJAQAAAA==.',
['晓仙']='晓仙:BAAALgAECgYJBAAAAA==.',
['晚上']='晚上:BAAALgADCgYJBgAAAA==.',
['晩晴']='晩晴:BAAALgAECgUJBwAAAA==.',
['晾坤']='晾坤:BAAALgAECgYJCAAAAA==.',
['暗界']='暗界霜血之镰:BAAALgAECgEJAQAAAA==.',
['暗香']='暗香盈袖:BAAALgADCgEJAQAAAA==.',
['暮春']='暮春:BAAALgAECgIJAgAAAA==.',
['暮鍦']='暮鍦:BAAALgAECgEJAQAAAA==.',
['暴怒']='暴怒火花:BAAALgAECgMJAwAAAA==.',
['最终']='最终理想:BAAALgAECgUJCQAAAA==.',
['月之']='月之信仰:BAAALgAECgQJBAAAAA==.',
['月神']='月神爱露恩:BAAALgAECgYJBgAAAA==.',
['月芽']='月芽村村长:BAAALgAFFAIJAgAAAA==.',
['有点']='有点秀逗:BAAALgAECgIJAwAAAA==.',
['朝孔']='朝孔雀:BAAALgAECgcJBwAAAA==.',
['朮士']='朮士:BAAALgADCgIJAQAAAA==.',
['李哥']='李哥哥:BAAALgAECgUJCQAAAA==.',
['李春']='李春生:BAAALgAECgQJBAAAAA==.',
['板丶']='板丶砖:BAAALgAECgYJDQAAAA==.',
['枕星']='枕星而眠:BAAALgAFFAQJBAAAAA==.',
['柏翘']='柏翘丶:BAAALgAECgQJBAAAAA==.',
['柒诗']='柒诗:BAABLgAECn8XAAIEAAcJ8CPXKgCOAgAEAAcJ8CPXKgCOAgAAAA==.',
['桑榆']='桑榆睡不醒:BAAALgADCggJEgAAAA==.',
['桥豆']='桥豆麻袋:BAAALgAECgMJAwAAAA==.',
['梅川']='梅川丨酷子:BAAALgAFFAEJAQAAAA==.',
['梦吥']='梦吥忧伤:BAAALgAFFAMJBAAAAA==.',
['梦境']='梦境:BAAALgAECgEJAQAAAA==.',
['橘子']='橘子汽水丶:BAACLgAFFH8HAAMcAAMJUR/4AQAuAQAcAAMJUR/4AQAuAQAPAAIJUxTwFwCpAAAuAAQKfyEAAxwACAn9IvMJAAsCAA8ABwlSHn8bAHACABwABQk4I/MJAAsCAAAA.',
['欧皇']='欧皇丶猎:BAAALgAECgcJDQAAAA==.',
['正在']='正在杀出冥界:BAABLgAFFH8FAAIEAAIJOBewPgCiAAAEAAIJOBewPgCiAAAAAA==.',
['此夜']='此夜:BAACLgAFFH8HAAQdAAMJNAmSGwCSAAAdAAIJNAmSGwCSAAAeAAEJQgYjDABNAAAfAAEJAABMCwBMAAAuAAQKfxsAAx0ACAnfHfQMAKYCAB0ACAnfHfQMAKYCAB8ABgnoA+8lAPQAAAAA.',
['步惊']='步惊雲:BAAALgAECgIJAgAAAA==.',
['武流']='武流风:BAABLgAECn8aAAIQAAgJ8xXsDgAaAgAQAAgJ8xXsDgAaAgAAAA==.',
['毛毛']='毛毛虫:BAAALgAECgMJAwAAAA==.',
['水水']='水水睡不醒:BAAALgADCgQJBAAAAA==.',
['水灵']='水灵韵:BAAALgAECgEJAgAAAA==.',
['氵咕']='氵咕咕渔:BAAALgAECgUJBQAAAA==.',
['氵诸']='氵诸葛蛋蛋:BAAALgADCgIJBAAAAA==.',
['沐雪']='沐雪迎:BAAALgAECgEJAQAAAA==.',
['没事']='没事德:BAAALgAECgYJBwAAAA==.',
['法术']='法术胖猫:BAAALgADCgIJAgAAAA==.',
['泥头']='泥头车撞大运:BAACLgAFFH8QAAQTAAUJpx6PAgB1AQATAAQJfB6PAgB1AQAgAAQJhhNJDwA4AQAhAAIJThrwAwC2AAAuAAQKfyAABCEACAlqIx0IAGkCACEABwkoIR0IAGkCACAABAneH3Q/AFsBABMAAwlUI2FkADoBAAAA.',
['浮生']='浮生梦归:BAAALgAECgcJBQAAAA==.',
['海王']='海王星:BAAALgADCgEJAQAAAA==.',
['淡忘']='淡忘迷失:BAAALgADCgMJAwAAAA==.',
['淡梦']='淡梦如烟:BAAALgAECgEJAQAAAA==.',
['深院']='深院锁清秋:BAAALgAECgYJCwAAAA==.',
['清晨']='清晨的光:BAAALgAECgcJBgAAAA==.',
['清月']='清月无名:BAAALgADCgEJAQAAAA==.',
['清风']='清风之影:BAAALgAECgIJAgAAAA==.清风徐来:BAAALgAECgUJBgAAAA==.',
['渊冰']='渊冰:BAAALgAECgYJBgAAAA==.',
['滑稽']='滑稽树滑稽果:BAACLgAFFH8VAAMiAAYJIRWpAQBkAQAiAAQJRBKpAQBkAQAjAAQJ5BPRCABfAQAuAAQKfyUAAyIACQneHKAFAC8CACMABwnIHuITAHcCACIABwkjFqAFAC8CAAAA.',
['滚滚']='滚滚:BAAALgADCgUJBQAAAA==.',
['漫漫']='漫漫苏:BAABLgAECn8WAAMYAAcJngu4DAArAQAYAAcJvge4DAArAQAUAAYJQA1dRAAnAQABLgAFFAcJBwAYAJAaAA==.',
['潇洒']='潇洒骑:BAAALgAECgYJBgAAAA==.',
['灬安']='灬安静角落灬:BAAALgAECgYJBwAAAA==.',
['灬角']='灬角落安静灬:BAAALgAECgYJCAAAAA==.',
['炤煋']='炤煋:BAAALgAECgMJAwAAAA==.',
['点一']='点一份血之哀:BAAALgADCgIJAwAAAA==.',
['焦溜']='焦溜小肉丸:BAABLgAECn8VAAIFAAcJJQ2YnwCXAQAFAAcJJQ2YnwCXAQAAAA==.',
['熊德']='熊德华:BAAALgAFFAEJAQAAAA==.',
['燕京']='燕京小法:BAAALgAECgYJBgAAAA==.',
['牧忠']='牧忠無人:BAAALgAECgQJBQAAAA==.',
['猫扑']='猫扑的小螃蟹:BAAALgAECgQJBQAAAA==.',
['猫翊']='猫翊杯:BAAALgAFFAIJAgAAAA==.',
['瑾轩']='瑾轩与瑕:BAAALgAECgMJAwAAAA==.',
['瓦立']='瓦立安:BAAALgAECgMJBgAAAA==.',
['甜不']='甜不辣:BAAALgAECgEJAQABLgAFFAUJDQAIAL4aAA==.',
['生死']='生死不急:BAAALgAECgUJBQAAAA==.',
['相见']='相见狠晚:BAAALgAECgIJAgAAAA==.',
['瞅啥']='瞅啥逗你玩:BAAALgADCgcJBwAAAA==.',
['瞎混']='瞎混歸來:BAAALgADCgQJBAAAAA==.瞎混歸唻:BAAALgAECgUJBwAAAA==.瞎混歸来:BAAALgAECgMJAwAAAA==.瞎混歸萊:BAAALgAECgUJBQAAAA==.',
['碧海']='碧海光粼:BAAALgAECggJCQAAAA==.',
['祈祷']='祈祷落幕:BAAALgAFFAIJAwAAAA==.',
['祝踏']='祝踏风:BAAALgAECgYJCQABLgAFFAEJAgABAAAAAA==.',
['秋高']='秋高气爽:BAAALgAECgMJBQAAAA==.',
['稻五']='稻五米:BAABLgAFFH8IAAIEAAMJnxejEgD6AAAEAAMJnxejEgD6AAAAAA==.',
['稻無']='稻無德:BAAALgAECgEJAQAAAA==.',
['穆斯']='穆斯塔法:BAAALgAECgMJAwAAAA==.',
['穆雪']='穆雪莹:BAAALgAECgEJAQAAAA==.',
['笑看']='笑看魔界:BAAALgADCgQJBAAAAA==.',
['笨笨']='笨笨的小白:BAAALgAECgUJBQAAAA==.',
['第十']='第十三:BAAALgAECgEJAgAAAA==.',
['粪插']='粪插:BAAALgAFFAEJAgAAAA==.',
['糕糕']='糕糕:BAAALgAECgcJBwAAAA==.',
['紫妖']='紫妖艳:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色的梦幻:BAAALgAFFAIJAgABLgAFFAMJCAAFALAMAA==.',
['红绿']='红绿红黄白:BAAALgAECgcJCQAAAA==.',
['红莲']='红莲铠骑:BAAALgAECgMJAQAAAA==.',
['约克']='约克十六世:BAAALgAECgYJBgAAAA==.约克十四世:BAAALgAECgEJAQABLgAECgYJBgABAAAAAA==.',
['绝界']='绝界行:BAAALgAECgcJCQAAAA==.',
['罐子']='罐子里的蘑菇:BAAALgAECgQJCAAAAA==.',
['羽化']='羽化十:BAAALgAECgQJBQAAAA==.',
['职业']='职业抄啥股:BAAALgAECgEJAQAAAA==.',
['聽说']='聽说:BAAALgADCgIJAgAAAA==.',
['肥美']='肥美幻象:BAAALgAECgUJBgAAAA==.',
['胖刘']='胖刘海:BAAALgAECgEJAQABLgAECgUJBgABAAAAAA==.',
['腹黑']='腹黑天气娘:BAAALgAECgMJBQAAAA==.',
['芙兰']='芙兰朵:BAAALgAECgQJBgAAAA==.',
['若水']='若水:BAAALgAECgMJAwAAAA==.',
['英雄']='英雄咸鱼王:BAAALgAFFAEJAQAAAA==.',
['莓普']='莓普露:BAAALgAECgIJAwAAAA==.',
['萶药']='萶药:BAAALgAECgQJAgAAAA==.',
['虾头']='虾头德:BAAALgAECgYJDwAAAA==.',
['蜜桃']='蜜桃汽水丶:BAAALgADCgMJAwAAAA==.',
['血色']='血色残月:BAAALgADCgEJAQAAAA==.',
['裳之']='裳之魅男:BAAALgAECgUJBQABLgAFFAMJCAAFALAMAA==.',
['角斗']='角斗士炎龙龙:BAAALgAECgcJDQAAAA==.',
['谁家']='谁家的鸟:BAAALgADCgIJAgAAAA==.',
['豆汁']='豆汁儿伏虎僧:BAAALgADCgEJAQAAAA==.',
['贝克']='贝克勒尔滨:BAAALgADCgMJAQAAAA==.',
['贞德']='贞德心愿:BAAALgAECgEJAQAAAA==.',
['败血']='败血刃伤:BAAALgAECgQJBAAAAA==.',
['贪睡']='贪睡的文猪:BAAALgAECgYJBgAAAA==.',
['贼星']='贼星高照:BAACLgAFFH8IAAIjAAMJYR0NBQAuAQAjAAMJYR0NBQAuAQAuAAQKfx0AAyMACAlKHO8NAL8CACMACAlKHO8NAL8CACIAAQmrFMscAEQAAAAA.',
['贼男']='贼男的死骑:BAAALgAECgEJAQAAAA==.',
['跟你']='跟你丫死磕:BAAALgADCgIJAgAAAA==.',
['还想']='还想再睡会:BAAALgADCgUJBQAAAA==.',
['远古']='远古大茄子:BAAALgAECgkJBgAAAA==.远古大鸡:BAAALgAECgkJBwAAAA==.',
['追忆']='追忆年华逝水:BAAALgAECgUJBQAAAA==.',
['邦柔']='邦柔哒:BAAALgAECgcJBwAAAA==.',
['邦邦']='邦邦的:BAAALgAFFAEJAgAAAA==.',
['酸味']='酸味西瓜灬:BAAALgAFFAEJAQAAAA==.',
['酸奶']='酸奶麻花:BAAALgAECgIJAgAAAA==.',
['醉意']='醉意波尔多:BAAALgAECgcJBgAAAA==.',
['野望']='野望:BAAALgAECgQJBAAAAA==.',
['野蛮']='野蛮孩子:BAAALgADCgcJAgAAAA==.',
['铭铭']='铭铭:BAAALgADCgEJAQAAAA==.',
['锦衣']='锦衣卫丶玄武:BAAALgAECgEJAQAAAA==.',
['阳虚']='阳虚:BAABLgAFFH8HAAMEAAMJFw1HFwDeAAAEAAMJugxHFwDeAAAkAAEJqQaiGgAyAAAAAA==.',
['阿克']='阿克的眼泪:BAABLgAECn8VAAMOAAgJCRrhJAA1AQAMAAUJDRhKbgCEAQAOAAQJOBnhJAA1AQAAAA==.',
['阿波']='阿波克烈:BAAALgAECgEJAQAAAA==.',
['阿萨']='阿萨:BAAALgAECgkJEgAAAA==.',
['陈米']='陈米大米:BAAALgAECgYJBwAAAA==.',
['随风']='随风而舞:BAABLgAFFH8GAAISAAIJABeIFACpAAASAAIJABeIFACpAAABLgAFFAMJCAAFALAMAA==.',
['隐形']='隐形丶冲锋:BAAALgAECgYJBgAAAA==.隐形人:BAAALgAECgQJBAAAAA==.',
['雅典']='雅典学堂老饕:BAAALgAECgEJAQAAAA==.',
['雪无']='雪无双:BAAALgAECgYJCQAAAA==.',
['雪色']='雪色飘舞:BAAALgAFFAEJAgAAAA==.',
['零之']='零之殇:BAAALgAECgYJBgAAAA==.',
['雷霆']='雷霆与烈焰:BAACLgAFFH8GAAISAAMJ6AQGEgDWAAASAAMJ6AQGEgDWAAAuAAQKfxgAAhIACAnYE9EgAAkCABIACAnYE9EgAAkCAAAA.',
['霜之']='霜之明语:BAACLgAFFH8IAAIFAAMJsAzqLQD/AAAFAAMJsAzqLQD/AAAuAAQKfyEAAgUACAn4HRExAK4CAAUACAn4HRExAK4CAAAA.',
['霸道']='霸道女总裁:BAAALgADCgUJBQAAAA==.',
['靓锟']='靓锟:BAAALgAFFAIJAgAAAA==.',
['面包']='面包师傅阿浪:BAAALgAFFAEJAgAAAA==.',
['韦小']='韦小宝:BAAALgAECgQJBAAAAA==.',
['顶天']='顶天立地:BAAALgAECgUJBQAAAA==.',
['风堇']='风堇:BAAALgADCgUJBQAAAA==.',
['饺子']='饺子哥哥:BAAALgAECgcJBwAAAA==.',
['骑士']='骑士无双:BAAALgAECgQJBAAAAA==.',
['高級']='高級動物:BAAALgAFFAEJAQAAAA==.',
['魔契']='魔契祿存:BAABLgAFFH8UAAMMAAYJdRrIAQAiAgAMAAYJdRrIAQAiAgAOAAEJABQwFABWAAAAAA==.',
['鱼香']='鱼香茄子哥哥:BAAALgAECgcJDQAAAA==.',
['鲜血']='鲜血阿加萨:BAAALgAECgEJAgAAAA==.',
['鸟毛']='鸟毛乱霏:BAAALgAECgEJAQAAAA==.',
['黄昏']='黄昏:BAAALgAECgMJAwAAAA==.',
['黑光']='黑光圣骑:BAAALgAECgEJAgAAAA==.',
['黑暗']='黑暗的第二世:BAABLgAFFH8FAAIEAAIJoiKRMADLAAAEAAIJoiKRMADLAAAAAA==.',
['黑龙']='黑龙苍穹:BAAALgAFFAIJBAABLgAFFAMJCAAFALAMAA==.',
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
