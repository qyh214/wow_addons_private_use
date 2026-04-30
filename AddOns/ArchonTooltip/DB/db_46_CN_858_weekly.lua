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

local lookup = {'Paladin-Retribution','Evoker-Augmentation','Unknown-Unknown','Warlock-Demonology','Druid-Balance','DeathKnight-Unholy','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','DeathKnight-Blood','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Monk-Brewmaster','Shaman-Restoration','Shaman-Elemental','Warrior-Fury','Warrior-Arms','Warrior-Protection','Evoker-Devastation','Shaman-Enhancement','Druid-Restoration','Paladin-Holy','Warlock-Destruction','Evoker-Preservation','Monk-Windwalker','DeathKnight-Frost','Priest-Holy','DemonHunter-Devourer',}
local provider = {region='CN',realm='闪电之刃',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alucard:BAAALgAECgYJCAAAAA==.',
Am='Amithras:BAAALgAECgcJBwAAAA==.',
Au='Authorty:BAAALgAECgQJBAAAAA==.',
Bo='Boogieness:BAAALgAECgEJAQAAAA==.',
Br='Brewster:BAAALgAECgYJBgAAAA==.',
Ch='Chimaev:BAABLgAFFH8FAAIBAAIJPA3IJQCfAAABAAIJPA3IJQCfAAAAAA==.',
Cu='Cummingman:BAAALgAECgEJAQAAAA==.',
De='Deepsea:BAAALgAECgEJAgAAAA==.',
Dr='Dragonbee:BAAALgAFFAEJAQAAAA==.Dragonmaster:BAABLgAECn8aAAICAAgJLAyxCQBsAQACAAgJLAyxCQBsAQAAAA==.',
Fn='Fnds:BAAALgAECgEJAQAAAA==.',
Ga='Gang:BAAALgAECgMJAwAAAA==.',
Gh='Ghostrider:BAAALgAECgIJAgAAAA==.',
Gi='Ginger:BAAALgADCgMJAwAAAA==.',
Ha='Hadess:BAAALgADCgUJBwAAAA==.Hathaway:BAAALgAECgIJAwAAAA==.',
Ic='Iceblood:BAAALgAFFAIJAwAAAA==.',
Ki='Kirisame:BAAALgADCgEJAQAAAA==.',
Le='Lechero:BAAALgAECgEJAQAAAA==.',
Lu='Lugia:BAAALgAECgUJCAAAAA==.',
Ma='Mamamia:BAAALgADCgUJBQAAAA==.Maus:BAAALgADCgEJAgAAAA==.',
Mi='Mikadono:BAAALgAECgIJAwAAAA==.',
Mu='Mukai:BAAALgAECgkJCQABLgAFFAMJAwADAAAAAA==.',
Ni='Nicoleteshae:BAAALgAFFAMJBAAAAA==.Nicoleteshai:BAAALgAECgQJBQAAAA==.Nicoleteshia:BAAALgAECgIJAQAAAA==.',
Nu='Nus:BAAALgAECgMJAwAAAA==.',
Pi='Pisces:BAAALgADCgIJAgAAAA==.',
Ra='Rachelcook:BAAALgAECgQJBQAAAA==.Razorer:BAAALgAECgcJBwAAAA==.',
Sa='Sait:BAAALgAECgIJAgAAAA==.',
Sm='Smallplant:BAAALgAECgEJAQAAAA==.',
St='Stormwarlock:BAAALgAECgEJAQAAAA==.Strongest:BAAALgAECgcJBgABLgAFFAUJBwAEAL4gAA==.',
Ta='Tailring:BAABLgAFFH8HAAIFAAIJchwCEgC1AAAFAAIJchwCEgC1AAAAAA==.',
Th='Think:BAAALgADCgEJAQAAAA==.',
Vv='Vvic:BAAALgAECgEJAwAAAA==.Vviclol:BAAALgAECgEJAgAAAA==.',
Xi='Xiaomi:BAAALgADCgEJAQAAAA==.',
Yo='Yogsothoth:BAAALgAECgEJAQAAAA==.',
['一丧']='一丧钟一:BAAALgAECgMJAwAAAA==.',
['一切']='一切随缘吧:BAAALgADCgUJBQAAAA==.',
['一只']='一只大鹌鹑:BAAALgAECgYJBgAAAA==.',
['一帆']='一帆风顺:BAAALgAECgEJAQAAAA==.',
['一根']='一根火腿肠:BAAALgADCgIJAwAAAA==.',
['一步']='一步两步走:BAABLgAFFH8JAAIGAAMJshHPJwD4AAAGAAMJshHPJwD4AAAAAA==.',
['一烙']='一烙脉一:BAAALgAECgIJAgAAAA==.',
['一百']='一百人:BAAALgADCgEJAQAAAA==.',
['一葉']='一葉之秋:BAAALgAECgQJBAAAAA==.',
['万事']='万事如意:BAAALgAECgQJBAAAAA==.',
['三二']='三二一冲钅:BAAALgADCgcJBwAAAA==.',
['三折']='三折德:BAAALgAECgIJAgAAAA==.',
['三生']='三生石的刻痕:BAAALgAECgIJAwAAAA==.',
['上高']='上高速骑蜗牛:BAAALgAECgEJAQAAAA==.',
['下下']='下下次我请:BAAALgAECgUJBgAAAA==.',
['不怕']='不怕死的牛:BAAALgAECgYJBgAAAA==.',
['不急']='不急漫漫玩:BAAALgADCgEJAQAAAA==.',
['且行']='且行且随风:BAAALgAECgYJBgABLgAECgYJEwADAAAAAA==.',
['世博']='世博园射手王:BAAALgAECgEJAQAAAA==.',
['世园']='世园会保安:BAAALgAECgMJBQAAAA==.',
['世界']='世界花式抖腿:BAAALgAECgQJBQAAAA==.',
['丨倩']='丨倩妮迪丨:BAABLgAFFH8GAAIHAAIJCwUNFgCCAAAHAAIJCwUNFgCCAAAAAA==.',
['丶二']='丶二月破晓:BAAALgAECgYJBwAAAA==.',
['丶北']='丶北北丶:BAAALgAECgUJBAAAAA==.',
['丶哈']='丶哈基米:BAAALgAECgkJEwAAAA==.',
['丶奶']='丶奶你妹:BAAALgAECgQJCQAAAA==.',
['丶潘']='丶潘多拉:BAAALgAECgUJBQAAAA==.',
['丶科']='丶科拉克休灬:BAAALgAECgQJBQAAAA==.',
['丶筱']='丶筱:BAAALgAECgMJBAAAAA==.',
['丶艾']='丶艾尔忒弥斯:BAABLgAECn8XAAMIAAcJcRUwDQC/AQAIAAcJcRUwDQC/AQAJAAMJygJydQBoAAAAAA==.',
['丶贪']='丶贪狼:BAAALgAECgYJBgAAAA==.',
['丸子']='丸子糖:BAAALgAECgYJDgAAAA==.',
['乄小']='乄小新:BAAALgADCgMJAwAAAA==.',
['乄灬']='乄灬猫小乐:BAAALgADCgYJBgAAAA==.乄灬猫小冰:BAAALgAECgkJEQAAAA==.乄灬猫小啵:BAAALgAECgYJCAAAAA==.乄灬猫小琪:BAAALgAFFAQJBAAAAA==.',
['义博']='义博重天:BAAALgADCgkJDwAAAA==.',
['乌干']='乌干达巴扎嘿:BAAALgAECgYJBgAAAA==.',
['乘风']='乘风蹈海:BAAALgADCgUJBQAAAA==.',
['九命']='九命悬鴉:BAAALgAECgMJAwAAAA==.',
['九貓']='九貓王妃:BAAALgAECgYJCQABLgAFFAIJAwADAAAAAA==.',
['乾坤']='乾坤自照:BAAALgAECgUJBgABLgAECgYJEwADAAAAAA==.',
['事事']='事事顺意:BAAALgADCgYJCAAAAA==.',
['二锅']='二锅头加汽水:BAAALgADCgEJAQAAAA==.',
['二龍']='二龍腾飞:BAAALgADCgYJCgAAAA==.',
['五福']='五福临门:BAAALgAECgUJDAAAAA==.',
['伽蓝']='伽蓝寺灬沙弥:BAAALgADCgEJAQAAAA==.',
['你不']='你不配我拔剑:BAAALgAECgEJAQAAAA==.',
['你们']='你们一起上:BAAALgAECgMJAwAAAA==.',
['你坏']='你坏:BAAALgAECgIJAgAAAA==.',
['佩可']='佩可莉姆:BAAALgADCgEJAQAAAA==.',
['依旧']='依旧丶:BAAALgAECgYJAQABLgAFFAIJAgADAAAAAA==.',
['依然']='依然很帅气:BAAALgAECgQJBAAAAA==.',
['修罗']='修罗丶双拳:BAAALgAECgEJAQAAAA==.',
['偶尔']='偶尔客串:BAAALgAECgQJBAABLgAECgYJEwADAAAAAA==.',
['光明']='光明酸酸乳:BAAALgADCgIJAgAAAA==.',
['光韵']='光韵:BAAALgAECgcJBwAAAA==.',
['兜里']='兜里全是棍:BAAALgADCgEJAQAAAA==.',
['八十']='八十八万八:BAAALgAECgQJBQAAAA==.',
['六六']='六六大顺丶:BAAALgAECgYJBwAAAA==.',
['六零']='六零六孤独:BAAALgAECgMJAwAAAA==.六零六星火:BAAALgADCgUJBQAAAA==.',
['共融']='共融:BAAALgAECgUJCgAAAA==.',
['关山']='关山难越:BAABLgAFFH8MAAICAAUJXxA9CABrAQACAAUJXxA9CABrAQAAAA==.',
['其實']='其實丨哦很壞:BAAALgAECgYJBwAAAA==.',
['冀冰']='冀冰奶:BAAALgAECgkJBwAAAA==.',
['军哥']='军哥无比风騒:BAAALgAECgIJBAAAAA==.军哥无比风骚:BAAALgAECgEJAQAAAA==.',
['冢家']='冢家灬幂幂:BAABLgAFFH8IAAIBAAIJWxhOFACrAAABAAIJWxhOFACrAAAAAA==.',
['冰心']='冰心柚子:BAAALgADCgEJAQAAAA==.',
['冰火']='冰火两重天:BAAALgAECgYJDAAAAA==.',
['冰落']='冰落星陨:BAAALgADCgYJBgAAAA==.',
['冷对']='冷对万夫:BAAALgAECgYJBwAAAA==.',
['冷菱']='冷菱凝槐:BAAALgADCgMJAwAAAA==.',
['别叫']='别叫我特仑苏:BAAALgAECgcJBwAAAA==.',
['别开']='别开嗜血:BAAALgAECgUJBgAAAA==.',
['剑哮']='剑哮苍穹:BAAALgAECgcJBgAAAA==.',
['剑心']='剑心犹在:BAAALgAECgYJCAAAAA==.',
['剑舞']='剑舞轻歌:BAAALgAECgUJBgAAAA==.',
['劈威']='劈威劈:BAAALgAECgIJAgAAAA==.',
['势不']='势不可挡骑士:BAAALgAECgQJBAAAAA==.',
['北芳']='北芳秀:BAAALgAECgEJAwAAAA==.',
['医生']='医生姐姐来了:BAAALgAECgEJAwAAAA==.',
['十七']='十七阝:BAAALgAECgEJAgAAAA==.',
['十三']='十三何事:BAAALgAECgkJEAABLgAFFAQJBgAGAL0YAA==.',
['十五']='十五厘米:BAAALgADCgcJBQABLgAFFAYJBgAKABIBAA==.',
['午夜']='午夜狂爆:BAAALgADCgYJBgAAAA==.',
['半晗']='半晗:BAAALgADCgYJBgAAAA==.',
['卜啵']='卜啵丶灰烬:BAAALgAECgQJBAAAAA==.卜啵丶牧神:BAAALgAECgEJAgAAAA==.卜啵丶邪焰:BAAALgAECgEJAQAAAA==.',
['卢俊']='卢俊义:BAAALgAECgYJDwAAAA==.',
['卧槽']='卧槽无情丶:BAAALgAECgEJAQAAAA==.',
['双手']='双手举蚂蚱:BAAALgAECgYJBAAAAA==.',
['双麻']='双麻火烧:BAAALgADCgYJBgAAAA==.',
['受伤']='受伤的大爷:BAAALgAFFAIJBAAAAA==.',
['口苗']='口苗了个口米:BAAALgAECgMJAwAAAA==.',
['叫兽']='叫兽走了:BAAALgAECgQJBAABLgAECgUJBQADAAAAAA==.',
['叮的']='叮的一声:BAAALgAECgEJAQAAAA==.',
['可怜']='可怜弱小无助:BAAALgADCgEJAQAAAA==.可怜的晓盆友:BAAALgAECgMJAwAAAA==.',
['史掰']='史掰的慢:BAAALgAECgYJBwAAAA==.',
['右二']='右二姨:BAAALgAECgEJAQAAAA==.',
['吃我']='吃我一大锤:BAAALgAECgEJAgAAAA==.',
['吉格']='吉格:BAAALgADCgMJAwAAAA==.',
['含泪']='含泪送交少:BAAALgADCgEJAQAAAA==.',
['周公']='周公谨:BAAALgAFFAIJAwAAAA==.',
['唯小']='唯小:BAAALgAFFAEJAQAAAA==.',
['喜欢']='喜欢吃辣:BAAALgAFFAIJAgAAAA==.',
['喵咪']='喵咪喵咪哄:BAAALgAECgUJBQAAAA==.',
['喵喵']='喵喵拯救世界:BAAALgAECgEJAQAAAA==.',
['嗷嗷']='嗷嗷芋头:BAAALgAECgkJBwAAAA==.',
['嘚嘚']='嘚嘚瑟瑟灬:BAAALgADCgMJAwAAAA==.',
['嚣张']='嚣张丶柠檬:BAAALgAECgQJBQAAAA==.',
['囧囧']='囧囧有神灬:BAAALgAECgYJBgAAAA==.',
['国足']='国足之影:BAAALgAECgUJCgAAAA==.',
['圣光']='圣光丶血蹄:BAAALgAFFAIJAgAAAA==.圣光忽你:BAAALgADCgcJEAAAAA==.圣光魅魔:BAAALgAECgEJAQAAAA==.',
['在下']='在下头很硬:BAABLgAFFH8GAAMLAAIJShghCQB7AAAGAAIJDQynQQCeAAALAAIJShghCQB7AAAAAA==.',
['地灵']='地灵灵:BAAALgAECgIJAgAAAA==.',
['地狱']='地狱怒风:BAAALgADCgUJBQAAAA==.地狱鬼猎:BAAALgAECgMJAwAAAA==.',
['坞鸦']='坞鸦:BAAALgAECgEJAgAAAA==.',
['埋名']='埋名:BAAALgAECgEJAQABLgAECgYJDgADAAAAAA==.',
['壶把']='壶把伤心鸟:BAAALgAECgcJBwAAAA==.',
['夏大']='夏大调:BAAALgADCgIJAgAAAA==.',
['夜氵']='夜氵未央:BAAALgAFFAEJAwAAAA==.',
['夜闯']='夜闯女澡堂:BAAALgAECgIJAgAAAA==.',
['大大']='大大吉利:BAAALgAFFAEJAQAAAA==.',
['大威']='大威德天龙:BAAALgAECgYJBwAAAA==.',
['大守']='大守宫:BAAALgAECgMJAwAAAA==.',
['大宝']='大宝宝来了:BAAALgAECgIJAgAAAA==.',
['大鳄']='大鳄山东圣奥:BAAALgAECgQJBAAAAA==.',
['天空']='天空至蓝:BAAALgAECgMJAwAAAA==.',
['奶味']='奶味蓝:BAAALgAECgIJAwAAAA==.',
['奸奇']='奸奇大魔:BAABLgAFFH8LAAIMAAUJhgVdAgANAQAMAAUJhgVdAgANAQAAAA==.',
['好像']='好像回到过去:BAAALgAECgEJAQAAAA==.',
['好喝']='好喝么:BAAALgAFFAQJBAAAAA==.',
['始作']='始作勇者:BAAALgAECgQJAwAAAA==.',
['宁静']='宁静:BAAALgAECgYJCwAAAA==.',
['宝哥']='宝哥哥:BAAALgADCgIJAgAAAA==.宝哥来了:BAABLgAFFH8GAAIMAAMJRRLmAwCyAAAMAAMJRRLmAwCyAAAAAA==.',
['寂静']='寂静海岸:BAAALgAECgYJCgAAAA==.',
['寒来']='寒来术往:BAAALgAECgEJAQAAAA==.',
['寻找']='寻找李小晚:BAAALgADCgEJAgAAAA==.',
['寻爱']='寻爱似浪淘沙:BAAALgADCgQJBAAAAA==.',
['将就']='将就将就:BAAALgADCgQJBAAAAA==.',
['小也']='小也猫:BAAALgAECgUJBQAAAA==.',
['小公']='小公猪:BAABLgAECn8lAAMNAAgJGxyzAgAjAgANAAgJGxyzAgAjAgAOAAEJ0gUGIAAzAAAAAA==.',
['小动']='小动物乱猛的:BAAALgADCgcJEAAAAA==.',
['小唯']='小唯:BAAALgADCgcJBwAAAA==.',
['小子']='小子烨:BAAALgAECgMJBAAAAA==.',
['小恶']='小恶魔僧:BAAALgAECgIJAgABLgAECgUJBQADAAAAAA==.',
['小植']='小植物:BAAALgADCgEJAQAAAA==.',
['小胖']='小胖丿:BAAALgAECgMJAwAAAA==.',
['小菊']='小菊:BAAALgAECgIJAgAAAA==.',
['小钢']='小钢炮儿:BAAALgAECgEJAQAAAA==.',
['小阿']='小阿达梅尔:BAAALgAFFAEJAQAAAA==.',
['小龙']='小龙法神:BAAALgAECgEJAQAAAA==.',
['尛灬']='尛灬咩咩:BAAALgAECgEJAQAAAA==.',
['尛龙']='尛龙女丶:BAAALgAFFAIJAwAAAA==.',
['就是']='就是奶不住啊:BAAALgAECgEJAQAAAA==.',
['崇武']='崇武:BAAALgADCgQJBAAAAA==.',
['巧乐']='巧乐兹加冰:BAAALgADCgEJAQAAAA==.',
['巳经']='巳经被停用:BAAALgADCgEJAQAAAA==.',
['巴布']='巴布豆:BAABLgAFFH8JAAIKAAUJSQD7MADtAAAKAAUJSQD7MADtAAAAAA==.',
['希格']='希格拉之耀:BAAALgAECgEJAgAAAA==.',
['幕后']='幕后人员:BAAALgADCgYJBgAAAA==.',
['平气']='平气静心:BAABLgAFFH8GAAIPAAMJZhXiCQD1AAAPAAMJZhXiCQD1AAAAAA==.',
['幸福']='幸福来敲门:BAAALgAECgUJCgAAAA==.',
['幻冰']='幻冰激凌:BAACLgAFFH8FAAIFAAMJ7RjXDAAUAQAFAAMJ7RjXDAAUAQAuAAQKfxUAAgUABwl/JG4VAGUCAAUABwl/JG4VAGUCAAAA.',
['幻影']='幻影缥缈:BAAALgAECgYJBgAAAA==.',
['幻月']='幻月泣血:BAAALgAECgMJAgAAAA==.',
['幽若']='幽若清风:BAAALgAECgEJAQAAAA==.',
['弑血']='弑血逍遥:BAAALgAFFAIJAwAAAA==.',
['弦玥']='弦玥:BAAALgAECgkJCAAAAA==.',
['影踪']='影踪大师姐:BAAALgADCgUJBQAAAA==.',
['很萌']='很萌:BAABLgAECn8VAAMQAAYJlhdcPACQAQAQAAYJlhdcPACQAQARAAEJNBQxLQA/AAAAAA==.',
['忆昔']='忆昔丶醉红颜:BAAALgAECgEJAQAAAA==.',
['恩哼']='恩哼丶小牛:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔术神:BAAALgAECgYJEgAAAA==.',
['悠悠']='悠悠尘埃:BAAALgAECgUJBQAAAA==.',
['情深']='情深缘浅:BAAALgAECgYJBgAAAA==.',
['情绪']='情绪化角斗士:BAABLgAECn8WAAQSAAcJ3Q7LDwBQAQASAAcJqA3LDwBQAQATAAUJfQwBHAAQAQAUAAEJmgYKSgApAAAAAA==.',
['惠大']='惠大王:BAAALgAECgcJAQAAAA==.',
['慕斯']='慕斯灬蛋糕:BAAALgAECgYJBgAAAA==.',
['憾天']='憾天奴:BAAALgAECgUJBQAAAA==.',
['懒惰']='懒惰的肥熊:BAAALgAECgEJAgAAAA==.',
['戈尔']='戈尔洛斯:BAAALgAECgQJBAAAAA==.',
['我不']='我不是肥猪:BAAALgADCgEJAgAAAA==.',
['我是']='我是肥猪:BAAALgADCgIJAwAAAA==.',
['执子']='执子之芷:BAAALgAFFAIJAgAAAA==.',
['扭屁']='扭屁屁哦耶:BAAALgAECgQJBQAAAA==.',
['抓绵']='抓绵羊的猴子:BAAALgAECgYJCgAAAA==.',
['披萨']='披萨鞋:BAAALgAECgYJBgAAAA==.',
['挑水']='挑水哥:BAAALgAECgYJCgAAAA==.',
['挚念']='挚念:BAAALgAECgYJBgAAAA==.',
['挥毫']='挥毫泼墨饮酒:BAABLgAFFH8FAAIQAAIJGhoWDQCsAAAQAAIJGhoWDQCsAAAAAA==.',
['摇滚']='摇滚诗人:BAAALgAECgEJAQAAAA==.',
['敌对']='敌对:BAAALgAECgkJDwAAAA==.',
['敖隐']='敖隐:BAABLgAFFH8FAAMVAAMJYh2qBQC3AAAVAAIJLBuqBQC3AAACAAIJ2xYzEwBnAAAAAA==.',
['教教']='教教基拉玩游:BAAALgAFFAUJAgABLgAFFAcJAgADAAAAAA==.',
['斧者']='斧者乱人心:BAAALgAECgcJDgAAAA==.',
['斯卡']='斯卡蒂:BAAALgAECgEJAQAAAA==.',
['斯文']='斯文扫地:BAAALgAFFAIJAgAAAA==.',
['方糕']='方糕:BAAALgAECgUJAgABLgAECgkJFgAIAB4mAA==.',
['无敌']='无敌橙装霸霸:BAAALgADCgEJAQAAAA==.',
['无束']='无束的天空:BAAALgAECgEJAQAAAA==.',
['春丽']='春丽他哥:BAAALgADCgMJAwAAAA==.',
['春江']='春江水暖:BAAALgAECgMJAwAAAA==.',
['是小']='是小傻纸涅:BAAALgAECgkJCQAAAA==.',
['晚吖']='晚吖吖:BAAALgAECgQJBAAAAA==.',
['暖冰']='暖冰丶:BAAALgAECgEJAgAAAA==.',
['暗之']='暗之阿呆彩虹:BAAALgAECgQJBAAAAA==.',
['暗夜']='暗夜闪电:BAAALgAECgUJBQAAAA==.',
['暗贱']='暗贱灬难防:BAAALgAECgQJBQAAAA==.',
['暗魔']='暗魔導士:BAAALgAECgYJDAAAAA==.',
['暴走']='暴走八神庵:BAAALgAECgQJBgAAAA==.',
['暴风']='暴风雪丶啊糗:BAAALgAECgYJBgABLgAFFAMJBgAKAI0dAA==.暴风雪丶希尔:BAAALgAECgEJAQAAAA==.',
['最爱']='最爱红名:BAAALgAECgEJAQABLgAECgYJEwADAAAAAA==.',
['月下']='月下蔓舞:BAAALgADCgMJAwAAAA==.',
['月晓']='月晓丶塘荷:BAAALgADCgIJAgAAAA==.',
['有奶']='有奶就是娘丫:BAAALgAECgMJAwAAAA==.',
['有德']='有德必尸:BAAALgAFFAEJAQAAAA==.有德灬有湿:BAAALgADCgYJBgAAAA==.',
['有钱']='有钱光环:BAAALgADCgMJAwAAAA==.',
['术之']='术之影:BAAALgAECgIJAgAAAA==.',
['朱棣']='朱棣:BAAALgAECgUJBQAAAA==.',
['杀不']='杀不死:BAAALgAECgEJAgABLgAFFAUJDwABAGYhAA==.',
['杀戳']='杀戳盛宴:BAAALgAECgUJBQAAAA==.',
['李知']='李知嗯:BAAALgAECgYJBwAAAA==.',
['李逵']='李逵:BAAALgAECgQJBQAAAA==.',
['条嘢']='条嘢太狼:BAAALgADCgIJAgAAAA==.',
['来啊']='来啊弄啊:BAAALgADCgUJBgAAAA==.',
['枕雪']='枕雪听风:BAAALgADCgEJAQAAAA==.',
['林一']='林一吖:BAAALgAECgUJCgABLgAECgcJCAADAAAAAA==.',
['林小']='林小咦:BAAALgAECgcJCAAAAA==.',
['林晓']='林晓一:BAAALgAECgYJBwABLgAFFAQJCAAHALkfAA==.',
['染血']='染血得柒月:BAAALgAECgMJAwAAAA==.',
['标记']='标记目标:BAAALgAECgcJCAAAAA==.',
['桜井']='桜井梨花:BAABLgAFFH8MAAIWAAQJyBtuAAB5AQAWAAQJyBtuAAB5AQAAAA==.',
['桥豆']='桥豆麻呆:BAAALgAECgEJAQAAAA==.',
['橙小']='橙小喵丶:BAAALgAECgYJEgAAAA==.',
['欧姆']='欧姆弥赛文:BAABLgAFFH8GAAIQAAMJUREACgDcAAAQAAMJUREACgDcAAAAAA==.欧姆弥赛武:BAAALgAECgQJBAAAAA==.',
['欧贝']='欧贝利克斯:BAAALgAFFAIJAgAAAA==.',
['死灬']='死灬鬼:BAAALgADCgEJAQAAAA==.',
['比巴']='比巴卟:BAAALgADCgIJAgABLgADCgYJBgADAAAAAA==.',
['毛团']='毛团:BAAALgAFFAIJAwAAAA==.',
['毛线']='毛线舅姥爷:BAABLgAFFH8FAAIQAAMJLw1nDwCQAAAQAAMJLw1nDwCQAAAAAA==.',
['水卜']='水卜櫻:BAAALgAECgQJBAAAAA==.',
['水坑']='水坑:BAAALgAECgEJAgAAAA==.',
['氺溪']='氺溪涵:BAAALgAECgYJDgAAAA==.',
['汐宫']='汐宫栞:BAAALgAECgYJBwABLgAECgYJDAADAAAAAA==.',
['沐歆']='沐歆:BAAALgAECgEJAQAAAA==.',
['沐葉']='沐葉:BAACLgAFFH8GAAIXAAMJgRWHEADlAAAXAAMJgRWHEADlAAAuAAQKfyAAAhcACAnPG9AZAGoCABcACAnPG9AZAGoCAAAA.',
['沐雨']='沐雨:BAAALgAECgMJAwAAAA==.',
['河北']='河北周杰伦:BAACLgAFFH8OAAISAAUJyxrVAQB0AQASAAUJyxrVAQB0AQAuAAQKfyYAAxIACQkuImsEAGQDABIACQmHIWsEAGQDABMAAQkbIp40AF4AAAAA.',
['油纸']='油纸伞:BAAALgAECgYJDAAAAA==.',
['法不']='法不责众:BAAALgADCgEJAQAAAA==.',
['泡泡']='泡泡小乖:BAAALgAECgYJCQAAAA==.',
['注电']='注电气工程师:BAAALgAECgEJAQAAAA==.',
['洛泽']='洛泽:BAAALgAECgMJAwAAAA==.',
['流光']='流光苏流年:BAAALgADCgYJBgAAAA==.',
['流年']='流年夏希:BAAALgAECgQJBQAAAA==.',
['流星']='流星火雨:BAAALgAECgQJBAAAAA==.',
['浅井']='浅井花音:BAAALgAECgYJDAAAAA==.',
['浇给']='浇给丶:BAAALgAECgcJBwAAAA==.',
['济南']='济南之星星呀:BAAALgADCgMJAwAAAA==.',
['海苔']='海苔味鱼果:BAABLgAFFH8JAAIYAAQJORT+CQA5AQAYAAQJORT+CQA5AQAAAA==.',
['深陷']='深陷苍穹:BAACLgAFFH8RAAMEAAQJwh0fBQBuAQAEAAQJcR0fBQBuAQAZAAQJhhFUBABLAQAuAAQKfxwAAxkABgmaIRELAA4CAAQABglXISkvAFACABkABgm2HRELAA4CAAAA.',
['淸风']='淸风:BAAALgADCgIJAgAAAA==.',
['渲灬']='渲灬染:BAAALgAECgIJBAAAAA==.',
['湮沄']='湮沄:BAABLgAFFH8MAAIaAAQJJhj9CQBJAQAaAAQJJhj9CQBJAQAAAA==.',
['滅世']='滅世圣骑:BAABLgAFFH8OAAIYAAUJ5g9xAgCSAQAYAAUJ5g9xAgCSAQAAAA==.',
['漫漫']='漫漫飞雪:BAAALgADCgMJAwAAAA==.',
['火球']='火球水法:BAAALgAECgEJAQAAAA==.',
['灬万']='灬万丈红尘灬:BAAALgAFFAIJBAAAAA==.',
['灬吾']='灬吾皇万歳灬:BAAALgAECgIJAgAAAA==.',
['灬银']='灬银白姬灬:BAAALgAECgEJAQAAAA==.',
['灰猪']='灰猪:BAACLgAFFH8JAAIBAAMJhRwxCQAeAQABAAMJhRwxCQAeAQAuAAQKfxcAAgEABwlCIjoHAD0CAAEABwlCIjoHAD0CAAAA.',
['烦人']='烦人精小金灵:BAAALgADCgEJAQAAAA==.',
['燚火']='燚火舞灵:BAAALgADCgIJAgAAAA==.',
['燱想']='燱想天开:BAAALgAFFAEJAQAAAA==.燱想添开:BAAALgADCgEJAQAAAA==.',
['爱喝']='爱喝脉动:BAAALgADCgIJAgAAAA==.',
['爱新']='爱新螺蛳:BAAALgADCgUJBQAAAA==.',
['爷如']='爷如此傲:BAAALgAECgcJEAAAAA==.',
['爸爸']='爸爸不要打我:BAAALgADCgYJBgAAAA==.',
['牤实']='牤实:BAAALgAECgEJAQAAAA==.',
['牧歌']='牧歌:BAAALgAECgEJAQAAAA==.',
['特咦']='特咦安田:BAAALgAECgMJBQAAAA==.',
['犀衍']='犀衍:BAAALgAECgMJAwAAAA==.',
['狙睾']='狙睾睾:BAAALgAECgIJAgAAAA==.',
['猪猪']='猪猪小野:BAAALgAFFAEJAQAAAA==.',
['猫嘴']='猫嘴里的鱼:BAAALgADCgIJAgAAAA==.',
['玖丨']='玖丨皇丨帝:BAAALgADCgIJAgAAAA==.',
['玛儿']='玛儿斯:BAAALgAECgMJAwAAAA==.',
['玛尔']='玛尔斯:BAABLgAECn8VAAMTAAYJKQsoCAAZAQATAAYJ0wooCAAZAQAUAAEJpQbsSQAqAAAAAA==.',
['玥妃']='玥妃泪:BAAALgAECgcJBwAAAA==.',
['珍珠']='珍珠小丸子:BAAALgAECgQJBAAAAA==.',
['疯狂']='疯狂就是疯狂:BAAALgAECgEJAQAAAA==.',
['瘟疫']='瘟疫碎片:BAAALgAECgUJCAAAAA==.',
['瘦皮']='瘦皮猴:BAAALgADCgEJAQAAAA==.',
['白夜']='白夜协奏:BAAALgAECgQJBAAAAA==.',
['白牧']='白牧:BAAALgADCgEJAQAAAA==.',
['盛开']='盛开的波波:BAAALgAECgEJAQAAAA==.',
['真圣']='真圣魔之血:BAABLgAFFH8HAAIQAAQJLxeYCgAtAQAQAAQJLxeYCgAtAQAAAA==.',
['真特']='真特么肉:BAAALgAECgUJBQAAAA==.',
['知秋']='知秋一葉:BAAALgAECgQJBwAAAA==.',
['破阵']='破阵之风:BAAALgADCgIJAgAAAA==.',
['神之']='神之王道:BAABLgAFFH8HAAISAAMJ+A+kEQD5AAASAAMJ+A+kEQD5AAAAAA==.',
['神秘']='神秘的肉:BAAALgAECgEJAQAAAA==.',
['福满']='福满多:BAAALgAECgMJAwAAAA==.',
['秋水']='秋水不染尘:BAAALgAECgUJBgAAAA==.',
['秋爽']='秋爽小贺贺:BAAALgAECgYJCAAAAA==.',
['秽恶']='秽恶之力:BAAALgAECgEJAQAAAA==.',
['程子']='程子啵啵:BAAALgAFFAIJAgAAAA==.',
['穆冄']='穆冄:BAAALgAECgEJAwAAAA==.',
['突出']='突出一朴素:BAAALgAECgIJAgAAAA==.',
['笙歌']='笙歌系舟:BAABLgAFFH8FAAIbAAIJ2xXqCwCkAAAbAAIJ2xXqCwCkAAAAAA==.',
['等你']='等你出现:BAAALgAECgIJAwAAAA==.',
['米兰']='米兰兰:BAAALgAECgEJAQAAAA==.',
['米呆']='米呆呆:BAAALgAECgEJAQAAAA==.',
['米诺']='米诺斯的公牛:BAAALgAECgIJBAAAAA==.',
['米酒']='米酒酒:BAAALgAECgIJAgAAAA==.',
['索拉']='索拉灬达尔:BAAALgAECgEJAQAAAA==.',
['紫夜']='紫夜灬未央:BAAALgAECgYJBgAAAA==.',
['紫甘']='紫甘蓝:BAAALgAECgEJAgAAAA==.',
['紫陌']='紫陌流觞:BAAALgAECgEJAgAAAA==.',
['红手']='红手小扬:BAAALgADCgEJAQAAAA==.',
['红色']='红色的草丛:BAAALgADCgkJCQAAAA==.',
['绺冰']='绺冰:BAAALgAECgQJBAAAAA==.',
['缺德']='缺德麼:BAAALgAECgMJAwAAAA==.',
['罗杰']='罗杰费德勒:BAAALgAECgQJBQAAAA==.',
['罗罗']='罗罗亚星辰:BAAALgAECgIJAwAAAA==.',
['罪魂']='罪魂之地:BAAALgADCgMJAwAAAA==.',
['羽菲']='羽菲:BAAALgAECgEJAQAAAA==.',
['老年']='老年枪手:BAAALgAECgEJAQAAAA==.',
['老衲']='老衲法号呐呐:BAAALgAECgcJBwAAAA==.',
['肉肉']='肉肉是只喵:BAAALgAECgEJAQAAAA==.',
['肖冲']='肖冲冲:BAAALgAECgYJBgAAAA==.',
['背剑']='背剑抚琴:BAAALgAECgEJAQAAAA==.',
['胖胖']='胖胖熊:BAAALgAECgEJAQAAAA==.',
['胖达']='胖达就是萌:BAAALgADCgIJAgAAAA==.',
['胡八']='胡八:BAAALgAECgYJBwAAAA==.',
['能美']='能美库特:BAAALgADCgEJAQAAAA==.',
['脑弯']='脑弯急转筋:BAAALgAECgEJAgAAAA==.',
['自由']='自由骑士:BAAALgAFFAMJBAAAAA==.',
['艾沫']='艾沫澈:BAAALgAECgcJDgAAAA==.',
['花天']='花天彩蝶:BAAALgAECgIJAgAAAA==.',
['花样']='花样作死评委:BAAALgAECgUJBgAAAA==.',
['花毛']='花毛:BAAALgAECgIJAQAAAA==.',
['苏沐']='苏沐橙:BAAALgAECgcJAQAAAA==.',
['苛芮']='苛芮德:BAAALgAECgQJBAAAAA==.',
['英俊']='英俊潇洒帅:BAAALgAECgMJAwAAAA==.',
['茜慕']='茜慕:BAABLgAFFH8HAAMGAAMJSB0VIAAaAQAGAAMJSB0VIAAaAQAcAAEJGRAhBQBSAAAAAA==.',
['草莓']='草莓可颂:BAAALgAECgEJAQAAAA==.',
['荣曜']='荣曜:BAAALgAFFAEJAQAAAA==.',
['莉亚']='莉亚:BAAALgAECgQJBQAAAA==.',
['莱昂']='莱昂哈特:BAAALgAECgcJEQAAAA==.',
['萌修']='萌修儿:BAAALgAECgEJAQAAAA==.',
['萌木']='萌木儿:BAAALgAECgEJAQAAAA==.',
['萌灬']='萌灬萝莉:BAAALgAECgEJAQAAAA==.',
['萌量']='萌量不足:BAAALgAECgYJCAAAAA==.',
['萨克']='萨克摩罗:BAAALgADCgUJBQAAAA==.',
['萨诺']='萨诺凋零图腾:BAAALgAECgIJAgAAAA==.',
['萱萱']='萱萱:BAAALgAECgkJCQABLgAFFAcJDgARAA8kAA==.',
['落无']='落无归:BAAALgAECgUJCAAAAA==.',
['蓓蓓']='蓓蓓:BAAALgADCgIJAgAAAA==.',
['蓝月']='蓝月夜雨:BAAALgAECgQJBgAAAA==.',
['蔓小']='蔓小漫:BAAALgAECgYJEwAAAA==.',
['藕粉']='藕粉桂花糖糕:BAAALgADCgIJAgAAAA==.',
['虾皮']='虾皮:BAAALgAECgUJBQAAAA==.',
['蛮锤']='蛮锤弟弟:BAAALgADCgEJAQAAAA==.',
['蝶殇']='蝶殇随云:BAAALgAECgUJBQAAAA==.',
['血科']='血科夫斯基:BAAALgAECgYJBgAAAA==.',
['西迪']='西迪:BAAALgADCgEJAQAAAA==.',
['言念']='言念:BAABLgAECn8ZAAMdAAcJLBk5GAAaAgAdAAcJLBk5GAAaAgAHAAYJygujDQAaAQAAAA==.',
['请叫']='请叫我渲染:BAAALgAECgEJAgAAAA==.',
['谁不']='谁不会二段跳:BAABLgAECn8UAAMMAAYJxCHgEgBBAgAMAAYJxCHgEgBBAgAeAAEJkAWF6QApAAAAAA==.',
['谁家']='谁家的那小谁:BAAALgAECgQJBAAAAA==.',
['貓火']='貓火火:BAAALgADCgEJAQAAAA==.',
['贼鼠']='贼鼠:BAAALgAECgcJBgAAAA==.',
['軍哥']='軍哥务必风骚:BAAALgADCgQJBAAAAA==.軍哥无比风骚:BAAALgAECgEJAQAAAA==.軍哥無比風騷:BAAALgAECgYJBQAAAA==.',
['辻一']='辻一:BAAALgAFFAIJBAAAAA==.',
['达达']='达达的拿拿:BAAALgAECgYJBgAAAA==.',
['这不']='这不是偶然:BAAALgAECgIJAgABLgAECgYJEwADAAAAAA==.',
['追命']='追命嗜杀:BAAALgAECgEJAQAAAA==.',
['追马']='追马:BAAALgAECgYJCgAAAA==.',
['逆风']='逆风飞行:BAAALgAECgQJBAAAAA==.',
['遗失']='遗失的青春:BAAALgAECgYJCAAAAA==.',
['邓丶']='邓丶风暴烈酒:BAAALgADCgQJBAAAAA==.',
['那一']='那一抹深蓝色:BAAALgAECgYJDgABLgAFFAIJAgADAAAAAA==.',
['邪魅']='邪魅一笑:BAAALgAECgEJAgAAAA==.',
['部落']='部落之刺:BAAALgAECgkJCQAAAA==.',
['酒池']='酒池红温了:BAAALgAFFAQJBAAAAA==.',
['醉揽']='醉揽星河:BAAALgADCgQJBAAAAA==.',
['重温']='重温二十:BAAALgAECgMJAwAAAA==.',
['鐡血']='鐡血茁爺:BAAALgADCgUJBQAAAA==.',
['铁血']='铁血炽炎:BAAALgAECgkJDgABLgAFFAUJDAAEAK0mAA==.',
['铃娜']='铃娜贝儿:BAAALgADCgEJAQAAAA==.',
['铛了']='铛了滴个锒:BAAALgAECgcJDQAAAA==.',
['長風']='長風:BAAALgAECgYJEwAAAA==.',
['长安']='长安雾意浓:BAAALgAECgQJCAAAAA==.',
['閃耀']='閃耀丶:BAAALgAECgMJBQAAAA==.',
['闪闪']='闪闪惹人爱:BAABLgAFFH8NAAIXAAUJ1Bk8AwCAAQAXAAUJ1Bk8AwCAAQAAAA==.',
['闲过']='闲过信陵饮:BAAALgAECgYJBwAAAA==.',
['阿修']='阿修罗王之怒:BAAALgAECgUJBQAAAA==.',
['阿可']='阿可可:BAAALgADCgcJEAAAAA==.',
['阿斯']='阿斯特莱娅:BAAALgAECgIJAwABLgAECgQJBAADAAAAAA==.',
['阿鲁']='阿鲁狄芭:BAAALgAECgcJEwAAAA==.',
['陈疯']='陈疯暴烈酒:BAAALgAECgEJAQABLgAECgYJDAADAAAAAA==.',
['陈老']='陈老板:BAAALgADCgcJBwAAAA==.',
['随风']='随风小猪德儿:BAEALgAFFAIJAwABLgAFFAMJBQAUAGMEAA==.随风小猪武僧:BAEBLgAFFH8JAAIPAAIJwBRzGwCRAAAPAAIJwBRzGwCRAAABLgAFFAMJBQAUAGMEAA==.随风小猪贰:BAEBLgAFFH8FAAIUAAMJYwQzBgCoAAAUAAMJYwQzBgCoAAAAAA==.随风流逝的心:BAAALgAECgQJBAAAAA==.随风流逝的爱:BAAALgAFFAEJAQAAAA==.',
['雨下']='雨下那冷:BAAALgAECgYJBgAAAA==.',
['雪大']='雪大海:BAAALgAECgUJCwAAAA==.',
['雷斯']='雷斯凯:BAAALgAECgYJDQAAAA==.',
['霜誓']='霜誓醉梦:BAAALgAECgEJAQAAAA==.',
['霜骨']='霜骨逝炎:BAAALgAECgEJAQAAAA==.',
['青春']='青春永不毕业:BAAALgAECgYJBgAAAA==.',
['青眼']='青眼亚白龙:BAAALgAECgEJAQAAAA==.',
['风武']='风武魂:BAAALgAECgUJBQAAAA==.',
['飒卡']='飒卡巴卡:BAAALgADCgIJAgAAAA==.',
['飘逸']='飘逸的菲菲:BAAALgAECgcJCAAAAA==.',
['飞天']='飞天遁地:BAAALgAECgYJCwAAAA==.',
['飞舞']='飞舞得雪蛇:BAAALgAECgMJAwAAAA==.',
['飞越']='飞越天空的砖:BAAALgADCgYJBgAAAA==.',
['饺子']='饺子不要醋:BAAALgAECgcJCgAAAA==.',
['驼背']='驼背行者:BAAALgAECgEJAQAAAA==.',
['骇人']='骇人恶兽丶:BAAALgAECgkJBwAAAA==.',
['鲨鱼']='鲨鱼丶辣椒:BAABLgAECn8XAAMGAAYJOR2PdgCYAQAGAAYJOR2PdgCYAQALAAEJAADTRgAtAAABLgAFFAIJAgADAAAAAA==.',
['鸡你']='鸡你太煤:BAAALgAECgcJCgAAAA==.',
['麻辣']='麻辣澳洲龙虾:BAAALgAECgQJBAAAAA==.',
['黑子']='黑子舞想:BAAALgAECgEJAQAAAA==.',
['黑色']='黑色末日骑士:BAAALgAECgIJBAAAAA==.黑色铁刃:BAAALgAECgEJAgAAAA==.',
['黑铁']='黑铁爱人:BAAALgAECgIJAgABLgAECgUJBQADAAAAAA==.',
['鼇廣']='鼇廣:BAAALgADCgQJBAAAAA==.',
['龙城']='龙城狂霸冷少:BAAALgADCgUJBQAAAA==.',
['龙骑']='龙骑士:BAAALgAFFAIJAgAAAA==.',
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
