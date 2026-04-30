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

local lookup = {'Druid-Restoration','Priest-Discipline','Warlock-Demonology','Warlock-Destruction','Druid-Balance','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Feral','Monk-Mistweaver','DeathKnight-Blood',}
local provider = {region='CN',realm='耐普图隆',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Analog:BAAALgAECgcJBwAAAA==.',
Ch='Ch:BAABLgAFFH8JAAIBAAUJkBHxAwBrAQABAAUJkBHxAwBrAQAAAA==.Chone:BAABLgAECn8YAAIBAAkJwhUyIgA1AgABAAkJwhUyIgA1AgABLgAFFAUJCQABAJARAA==.',
Er='Erinyes:BAAALgAFFAIJAwAAAA==.',
Fi='Fiona:BAAALgAFFAIJAgAAAA==.',
Ha='Harcar:BAAALgAECgYJCwAAAA==.Haru:BAAALgAECgQJBAAAAA==.',
Ki='Kissluna:BAAALgAECgEJAgAAAA==.',
Me='Memories:BAAALgAFFAEJAQAAAA==.',
Pi='Piag:BAAALgAFFAEJAgABLgAFFAgJHwACAHUVAA==.Pitii:BAEALgAFFAEJAQAAAA==.',
Sh='Shell:BAAALgAECgQJBAAAAA==.',
Ta='Talone:BAAALgAECgUJBQAAAA==.',
Va='Vanessar:BAAALgAECgQJBAAAAA==.',
Vi='Viwkzfl:BAAALgAECgYJBwAAAA==.',
Wa='Wantanything:BAAALgAFFAIJAgAAAA==.',
['一零']='一零八天下:BAAALgAFFAEJAQAAAA==.',
['不打']='不打了退了:BAAALgADCgcJBwAAAA==.',
['丨小']='丨小丶丫头丨:BAAALgAECgYJCQAAAA==.',
['丶御']='丶御弟哥哥:BAAALgAECgEJAgAAAA==.',
['丶珀']='丶珀亚拉枫影:BAAALgAECgcJDQAAAA==.',
['丶雨']='丶雨露:BAAALgADCgUJBQAAAA==.',
['丷小']='丷小布:BAAALgADCgEJAQAAAA==.',
['二毛']='二毛:BAAALgAECgYJCgAAAA==.',
['人球']='人球地是不我:BAAALgAECgYJBgAAAA==.',
['从容']='从容:BAAALgAECgUJCQAAAA==.',
['伊吹']='伊吹萃香:BAAALgAECgYJAQAAAA==.',
['传说']='传说中的小强:BAAALgAECgMJBQAAAA==.',
['信仰']='信仰之猎:BAAALgADCgYJBgAAAA==.',
['傲佳']='傲佳:BAAALgAECgQJBwAAAA==.',
['先祖']='先祖忽攸之你:BAAALgAECgIJAQAAAA==.',
['冬灵']='冬灵:BAAALgADCgYJBgAAAA==.',
['冰客']='冰客剑心:BAAALgAECgQJBQAAAA==.',
['冰躺']='冰躺血励猫哥:BAAALgAECgcJDAAAAA==.',
['午夜']='午夜猫哥:BAAALgAECgQJBQAAAA==.',
['可可']='可可大人:BAAALgAECgMJAQAAAA==.',
['吃口']='吃口饭哈哈:BAAALgAECggJCQAAAA==.',
['咖喱']='咖喱辣椒:BAAALgAECgEJAgAAAA==.',
['喵法']='喵法自然:BAAALgAECgEJAgAAAA==.',
['嘤国']='嘤国大理石:BAAALgADCgEJAQAAAA==.',
['嘿阿']='嘿阿门:BAAALgAECgEJAQAAAA==.',
['噬魂']='噬魂魅影:BAAALgAECgEJAQAAAA==.',
['四溅']='四溅:BAAALgADCgMJAwAAAA==.',
['国服']='国服第一惩戒:BAAALgAECgUJCAAAAA==.',
['圣光']='圣光图腾:BAAALgAECgYJBwAAAA==.',
['夜岚']='夜岚瑶:BAAALgAECgYJDgAAAA==.',
['大变']='大变子:BAAALgAECgMJAwAAAA==.',
['大帅']='大帅比丶:BAAALgAECgEJAQAAAA==.',
['大珠']='大珠儿:BAAALgADCgEJAQAAAA==.',
['大良']='大良民:BAAALgAECgEJAQAAAA==.',
['大驴']='大驴子:BAAALgAECgIJAgAAAA==.',
['大鱼']='大鱼:BAAALgAECgIJAgAAAA==.',
['天地']='天地有雪:BAABLgAFFH8CAAIDAAIJyQiWMQBSAAADAAIJyQiWMQBSAAAAAA==.',
['天道']='天道脆脆鲨丶:BAAALgAECgYJBgAAAA==.',
['失落']='失落国度:BAAALgAECgQJCAAAAA==.失落的骑士:BAAALgAECgYJCAAAAA==.',
['奈崩']='奈崩里奥:BAAALgADCgEJAQAAAA==.',
['妖姬']='妖姬:BAAALgADCgEJAQAAAA==.',
['小暗']='小暗:BAAALgAECgQJBAAAAA==.',
['小牛']='小牛叉叉:BAAALgADCgIJAQAAAA==.',
['小石']='小石头丶:BAAALgAECgYJCAAAAA==.',
['小翊']='小翊豪:BAAALgADCgUJBAAAAA==.',
['小鱼']='小鱼:BAAALgAECgIJAgAAAA==.',
['小黄']='小黄龙:BAABLgAFFH8GAAIDAAIJORDDNgCmAAADAAIJORDDNgCmAAAAAA==.',
['尼克']='尼克狐尼克:BAAALgAFFAEJAQAAAA==.',
['崩桑']='崩桑迪:BAAALgADCgEJAQAAAA==.',
['左岸']='左岸风海:BAAALgAECgEJAQAAAA==.',
['帅牙']='帅牙牙:BAAALgAECgYJCgAAAA==.',
['常山']='常山阴:BAACLgAFFH8OAAMDAAUJYBv2EABaAQADAAUJYBv2EABaAQAEAAIJUA4oDQCjAAAuAAQKfxoAAwQABwnuImIPANYBAAMABgl+IcBAAAsCAAQABQmnH2IPANYBAAAA.',
['幽明']='幽明大帝:BAAALgADCgQJBAAAAA==.',
['微笑']='微笑幽咽:BAAALgAECgEJAQAAAA==.',
['德高']='德高望重:BAABLgAFFH8FAAMFAAQJMiTcBQCJAQAFAAQJMiTcBQCJAQABAAEJBhVeFgBSAAAAAA==.',
['忆晨']='忆晨:BAECLgAFFH8JAAIGAAQJ2h9jBgCJAQAGAAQJ2h9jBgCJAQAuAAQKfyYAAgYACAmIJpQEAIMDAAYACAmIJpQEAIMDAAAA.',
['忘却']='忘却的怀念:BAAALgAECgIJAgAAAA==.',
['怀念']='怀念也疯狂:BAAALgAECgIJAgAAAA==.',
['急急']='急急如律令:BAAALgAECgEJAgAAAA==.',
['恶魔']='恶魔传奇:BAAALgAECgQJBgAAAA==.',
['情不']='情不了了之:BAAALgAECgEJAQAAAA==.',
['情依']='情依:BAAALgAECgYJEAAAAA==.',
['惊鸿']='惊鸿:BAABLgAFFH8LAAIGAAMJTCYUDQBDAQAGAAMJTCYUDQBDAQAAAA==.',
['憨憨']='憨憨的圣骑:BAAALgAECgMJBgAAAA==.',
['我是']='我是戦士:BAAALgAECggJEAAAAA==.',
['我要']='我要曰天:BAAALgAECgQJBAAAAA==.',
['战鱼']='战鱼:BAAALgAECgMJAwAAAA==.',
['手机']='手机质检员:BAAALgAFFAQJBAAAAA==.',
['抄底']='抄底大师:BAAALgADCgMJAwAAAA==.',
['明則']='明則:BAAALgADCgUJBQAAAA==.',
['星界']='星界法师:BAAALgAECgEJAgAAAA==.',
['晴朗']='晴朗:BAAALgAECgQJBAAAAA==.',
['暴力']='暴力战法:BAAALgAECgYJBwAAAA==.',
['暴揍']='暴揍落落:BAAALgADCgEJAQAAAA==.',
['枯彡']='枯彡巫:BAAALgAECgQJBAAAAA==.',
['欧德']='欧德沃福:BAAALgAECgIJAwAAAA==.',
['歌狂']='歌狂:BAAALgADCgIJAgAAAA==.',
['毛蛋']='毛蛋:BAAALgAFFAMJAwAAAA==.',
['沃德']='沃德亿负:BAAALgAECgEJAQAAAA==.',
['火箭']='火箭跳跳:BAAALgADCgIJAgAAAA==.',
['炒不']='炒不熟的排骨:BAAALgAECgkJBgAAAA==.',
['炖不']='炖不熟的排骨:BAAALgAFFAIJAQAAAA==.',
['烈焰']='烈焰叹息:BAAALgAECgQJBwAAAA==.',
['烧强']='烧强强:BAAALgAECgYJCAAAAA==.',
['牛小']='牛小红:BAAALgAFFAMJBAAAAA==.',
['牛肉']='牛肉老板:BAAALgAFFAIJBAAAAA==.',
['玖月']='玖月拾肆丶:BAAALgADCgQJBAAAAA==.',
['瑞文']='瑞文:BAACLgAFFH8LAAMHAAMJvyFEHQAsAQAHAAMJvyFEHQAsAQAIAAEJoRDjBABVAAAuAAQKfxQAAgcABgmUIL1LABACAAcABgmUIL1LABACAAAA.',
['甄姬']='甄姬扒菜丶:BAAALgAECgEJAQAAAA==.',
['痴人']='痴人嗦梦:BAAALgAECgkJCQAAAA==.',
['白云']='白云苍狗丶:BAAALgAECgcJBwAAAA==.',
['百分']='百分之四十牧:BAACLgAFFH8IAAIJAAQJkg4CCABHAQAJAAQJkg4CCABHAQAuAAQKfyUAAgkACQmjGtMJAOYCAAkACQmjGtMJAOYCAAAA.',
['皺著']='皺著眉頭的你:BAABLgAFFH8JAAIGAAMJTRYsDAADAQAGAAMJTRYsDAADAQAAAA==.',
['石頭']='石頭:BAAALgAECgMJAwAAAA==.',
['神圣']='神圣狩猎狂:BAAALgADCgcJBwAAAA==.',
['粉红']='粉红色玳:BAAALgADCgEJAQAAAA==.',
['红油']='红油辣子:BAABLgAFFH8JAAMKAAMJvRxLDgDIAAAKAAMJlBtLDgDIAAALAAEJcB0DJABYAAAAAA==.',
['纳兰']='纳兰丨若雪:BAAALgAECgEJAQAAAA==.',
['翊豪']='翊豪啊:BAAALgADCgYJBgAAAA==.',
['老王']='老王虾面好吃:BAEALgAECgYJBgABLgAFFAQJCQAGANofAA==.',
['肥嘟']='肥嘟嘟左卫门:BAAALgAFFAEJAQABLgAFFAQJEAAMAOsiAA==.',
['脸厚']='脸厚耐揍:BAAALgADCgUJBQAAAA==.',
['至尊']='至尊奶爸:BAABLgAFFH8HAAINAAMJjw5VDADfAAANAAMJjw5VDADfAAAAAA==.',
['芝士']='芝士卷边:BAAALgAFFAIJAwAAAA==.',
['花心']='花心的豬:BAAALgAECgcJBwAAAA==.',
['莫问']='莫问:BAAALgADCgEJAQAAAA==.',
['菜皮']='菜皮儿:BAAALgAFFAEJAQAAAA==.',
['葛噜']='葛噜姆:BAAALgAECgMJAwAAAA==.',
['被埋']='被埋没的天才:BAAALgADCggJCAAAAA==.',
['西月']='西月关山:BAAALgAECgIJAgAAAA==.',
['踏雪']='踏雪飞歌:BAAALgADCgEJAQAAAA==.',
['达芬']='达芬齐:BAAALgADCgMJAwAAAA==.',
['这妞']='这妞真帅:BAAALgAECgQJBAAAAA==.',
['逐鹿']='逐鹿梦鱼:BAAALgAECgEJAQAAAA==.',
['通灵']='通灵领主:BAACLgAFFH8JAAIHAAQJBSR+FwBHAQAHAAQJBSR+FwBHAQAuAAQKfyUAAwcACAkQJMENACwDAAcACAkQJMENACwDAA4ACAm0EKMcAGYBAAAA.',
['酷毙']='酷毙了:BAAALgADCgQJBAAAAA==.',
['酸萝']='酸萝卜肉末:BAAALgAECgEJAQAAAA==.',
['锦衣']='锦衣夜行:BAAALgAFFAEJAQAAAA==.',
['闪电']='闪电魔影:BAAALgAECgEJAQAAAA==.',
['阿华']='阿华田侑嘉:BAAALgAECgMJAwAAAA==.',
['随地']='随地大小变丶:BAAALgAECgYJCQAAAA==.',
['雾散']='雾散触人醒:BAAALgAECgQJBQAAAA==.',
['霍丶']='霍丶秀秀丿:BAAALgAFFAEJAQAAAA==.',
['霹雳']='霹雳不吃药:BAAALgAECgIJAgAAAA==.霹雳不打針:BAAALgAECgYJBwAAAA==.',
['風箏']='風箏舞紛飛:BAAALgAFFAQJAQAAAA==.',
['风中']='风中的驻足:BAAALgAECgYJDwAAAA==.',
['马里']='马里奥利奥:BAAALgAECgcJDQAAAA==.',
['魅影']='魅影小海鬼:BAAALgAECgEJAQAAAA==.',
['鱼泪']='鱼泪:BAAALgAECgUJCQAAAA==.',
['鴆羽']='鴆羽千夜:BAABLgAFFH8HAAICAAUJLhqVAwC/AQACAAUJLhqVAwC/AQAAAA==.',
['黑暗']='黑暗乄游侠:BAAALgAECgQJBAAAAA==.',
['龍渊']='龍渊:BAAALgAECgEJAQAAAA==.',
['龙跃']='龙跃:BAAALgADCgUJCgAAAA==.',
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
