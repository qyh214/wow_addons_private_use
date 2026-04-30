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

local lookup = {'Mage-Frost','Evoker-Preservation','Shaman-Restoration','Paladin-Retribution','DeathKnight-Unholy','Hunter-BeastMastery','Paladin-Holy',}
local provider = {region='CN',realm='巴纳扎尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agoni:BAAALgADCgIJAgAAAA==.',
An='Anyilunye:BAAALgAECgMJAwAAAA==.',
At='Attlanta:BAAALgADCgIJAgAAAA==.',
Bc='Bcd:BAAALgADCgYJBgAAAA==.',
Fa='Fairy:BAAALgAECgYJBwAAAA==.Fallangle:BAAALgADCgEJAQAAAA==.',
Fr='Freakyfreaky:BAAALgADCgIJAgAAAA==.',
He='Hebe:BAAALgADCgQJBAAAAA==.',
Kk='Kkouww:BAAALgAECgUJBQAAAA==.',
Le='Lemon:BAAALgAECgUJBQAAAA==.',
Me='Messenger:BAAALgAECgQJBAAAAA==.',
Mi='Missing:BAABLgAFFH8GAAIBAAIJlgekSQCaAAABAAIJlgekSQCaAAAAAA==.',
Ne='Newway:BAAALgADCgEJAQAAAA==.',
Ni='Nicoavril:BAAALgAECgYJDQAAAA==.Nightraven:BAAALgAECgcJEQAAAA==.',
Re='Redeem:BAAALgADCgEJAQAAAA==.',
Sh='Shiryu:BAAALgAECgcJDAAAAA==.',
Ta='Talent:BAAALgAECgMJAwAAAA==.Tatain:BAAALgADCgUJBQAAAA==.',
Ti='Titain:BAAALgAECgEJAQAAAA==.',
Wi='Windcall:BAACLgAFFH8SAAICAAUJOCHgAADfAQACAAUJOCHgAADfAQAuAAQKfxgAAgIACQlYIHcDACkDAAIACQlYIHcDACkDAAEuAAUUBgkKAAMAdgoA.',
['一骑']='一骑当先:BAAALgAECgcJCAAAAA==.',
['三季']='三季稻:BAAALgAECgYJCgAAAA==.',
['不羁']='不羁的风:BAAALgAECgcJCQAAAA==.',
['丶烟']='丶烟雨:BAAALgADCgMJAwAAAA==.',
['丶猴']='丶猴子队长:BAAALgAECgIJAQAAAA==.',
['丶蜂']='丶蜂蜜柚子茶:BAAALgAECgcJDAAAAA==.',
['丸了']='丸了:BAAALgAECgMJBAAAAA==.',
['乙巳']='乙巳蛇年大吉:BAAALgAECgEJAQAAAA==.',
['乱世']='乱世骑士:BAAALgAECgQJBAAAAA==.',
['云尽']='云尽秋:BAAALgAECgcJCQAAAA==.',
['傲决']='傲决:BAAALgADCgcJBwAAAA==.',
['兜兜']='兜兜小四:BAAALgAECgQJBAAAAA==.',
['刀刀']='刀刀烈火:BAAALgAECgEJAQAAAA==.',
['划水']='划水冠军:BAAALgAECgEJAQAAAA==.',
['北岸']='北岸花园跪宾:BAAALgAECgkJDQABLgAFFAYJFwAEAN0fAA==.',
['十三']='十三:BAAALgAECgYJAwAAAA==.',
['十六']='十六:BAABLgAFFH8HAAIFAAMJSxY3SQCQAAAFAAMJSxY3SQCQAAAAAA==.',
['午夜']='午夜的狂欢:BAAALgAFFAIJAwAAAA==.',
['叔他']='叔他大爷:BAAALgAECgcJDwAAAA==.',
['口卡']='口卡口察:BAAALgAFFAEJAQAAAA==.',
['吉姆']='吉姆戈登:BAAALgAECggJEwAAAA==.',
['哥是']='哥是老中医:BAAALgAFFAIJAwAAAA==.',
['唯一']='唯一的选择:BAAALgAECgYJBgAAAA==.',
['唯艾']='唯艾琳:BAAALgAECgEJAQAAAA==.',
['国产']='国产专区:BAAALgAECgkJBwAAAA==.',
['坦提']='坦提沉思:BAAALgAECgUJBQAAAA==.',
['基罗']='基罗妮莎:BAAALgADCgYJCwAAAA==.',
['大佬']='大佬带带我:BAAALgAFFAEJAQAAAA==.',
['大怪']='大怪兽丶:BAAALgAECgMJAwAAAA==.',
['奇怪']='奇怪的小骑士:BAAALgAECgEJAgAAAA==.',
['奧格']='奧格瑞玛暗牧:BAAALgAECgQJBQAAAA==.',
['季末']='季末残阳:BAAALgAFFAIJBAAAAA==.',
['定西']='定西:BAAALgAECgEJAQAAAA==.',
['小兰']='小兰:BAAALgAECggJEwAAAA==.',
['小小']='小小世界:BAAALgAECgEJAQAAAA==.小小其:BAAALgAECgEJAQAAAA==.小小鹤島四号:BAAALgAECgYJDwAAAA==.',
['小帅']='小帅:BAAALgAFFAUJAgABLgAFFAYJEAAGAPgfAA==.',
['小老']='小老虎星冰乐:BAAALgAECgcJAgAAAA==.',
['小迪']='小迪:BAAALgAECgcJCAAAAA==.',
['小阿']='小阿焱丶:BAAALgAECgEJAQAAAA==.',
['小静']='小静儿:BAABLgAECn8aAAIBAAcJIRlOYAAaAgABAAcJIRlOYAAaAgAAAA==.',
['就一']='就一恶魔:BAAALgAECgQJBAAAAA==.',
['山顶']='山顶冻仁儿:BAAALgAECgYJBgAAAA==.',
['峰云']='峰云遮月:BAAALgAECgMJAwAAAA==.',
['弑神']='弑神是神:BAAALgAECgcJEQAAAA==.',
['张罗']='张罗人:BAAALgADCgMJAwAAAA==.张罗大:BAAALgAECgYJCwAAAA==.',
['很难']='很难拉得住:BAAALgAECgIJAgAAAA==.',
['御坂']='御坂美琴:BAAALgAECgEJAgAAAA==.',
['志夑']='志夑:BAAALgAECgQJBAAAAA==.',
['我以']='我以为丶:BAAALgAECgEJAQAAAA==.',
['我最']='我最桃燕灬你:BAAALgAECgYJBwAAAA==.',
['执剑']='执剑万古枯:BAACLgAFFH8JAAIFAAMJUg3dQwCbAAAFAAMJUg3dQwCbAAAuAAQKfx0AAgUACQmzFWM2AF0CAAUACQmzFWM2AF0CAAAA.',
['提莫']='提莫长大了:BAAALgAECgUJBgAAAA==.',
['春迹']='春迹问杜鹃:BAAALgAECgIJAgAAAA==.',
['晶光']='晶光仙子:BAAALgAECgYJBgAAAA==.',
['智慧']='智慧的小晨晨:BAAALgAECgcJCAAAAA==.',
['暴风']='暴风大聪明:BAAALgADCggJBgAAAA==.',
['曼陀']='曼陀罗华:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经是仓库:BAABLgAFFH8JAAIHAAIJFB1DEwCrAAAHAAIJFB1DEwCrAAAAAA==.',
['最最']='最最深的蓝:BAAALgAECgYJDAAAAA==.',
['月之']='月之怒:BAAALgAECgcJDAAAAA==.',
['杀意']='杀意已决:BAAALgAFFAQJBAAAAA==.',
['李铁']='李铁棍:BAAALgAECgMJBQAAAA==.',
['极寒']='极寒:BAAALgAECgYJBgAAAA==.',
['果涩']='果涩堂棠:BAAALgADCgUJBQAAAA==.',
['枫之']='枫之紫月:BAAALgAECgEJAQAAAA==.',
['森息']='森息:BAAALgADCgMJAwAAAA==.',
['残影']='残影幽灵:BAAALgAFFAIJAgAAAA==.',
['民以']='民以食为天:BAAALgADCgQJBAAAAA==.',
['求死']='求死:BAAALgAECgIJBAAAAA==.',
['没用']='没用的术:BAAALgAECgUJBQAAAA==.',
['浪漫']='浪漫舞步:BAAALgAECgQJAwAAAA==.',
['深森']='深森圣良:BAAALgAECgEJAQAAAA==.',
['烏鴉']='烏鴉先生:BAAALgAFFAIJAwAAAA==.',
['烟雨']='烟雨丶:BAAALgAFFAIJAgAAAA==.',
['焏五']='焏五行流转:BAAALgADCgUJBQAAAA==.',
['燃烧']='燃烧的圣光:BAAALgAECgIJAwAAAA==.',
['爱吃']='爱吃红烧肉:BAAALgAECgEJAQAAAA==.',
['牛的']='牛的不德了:BAAALgAECgYJDAAAAA==.',
['玖灬']='玖灬爷:BAAALgAECgMJAgAAAA==.',
['甜糖']='甜糖豆:BAAALgAECgYJBwAAAA==.',
['生气']='生气的阿昆达:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂八爪鱼:BAAALgAECgkJBwAAAA==.',
['皮卡']='皮卡丘:BAAALgAECgYJBAAAAA==.',
['相当']='相当大气:BAAALgAECgUJBgAAAA==.相当局气:BAAALgAECgYJBQAAAA==.',
['碧落']='碧落泠泠:BAAALgADCgEJAQAAAA==.',
['神圣']='神圣的牛:BAAALgAECgQJBAAAAA==.',
['神说']='神说小宇宙:BAAALgAECgMJAwAAAA==.',
['米店']='米店:BAAALgADCgEJAQAAAA==.',
['糊师']='糊师傅:BAAALgAFFAIJAgAAAA==.',
['红色']='红色的小晨晨:BAAALgAECgYJBgAAAA==.',
['纸醉']='纸醉亅迷:BAAALgAECgYJCQAAAA==.纸醉釒迷:BAAALgAECgQJBAAAAA==.',
['绝世']='绝世骄傲:BAAALgAFFAEJAQAAAA==.',
['缘一']='缘一无恋:BAAALgADCgMJAwAAAA==.',
['羽云']='羽云高歌:BAAALgAECgEJAQAAAA==.',
['羽涅']='羽涅:BAAALgAECgEJAQAAAA==.',
['老技']='老技师:BAAALgADCgUJBQAAAA==.',
['胖子']='胖子拿铁:BAAALgADCgYJBwAAAA==.',
['艾斯']='艾斯咪亚:BAAALgADCgEJAQAAAA==.艾斯德斯:BAAALgADCgEJAQAAAA==.',
['芥末']='芥末味鼻涕:BAAALgAECgUJBQAAAA==.',
['花花']='花花的荣耀:BAAALgADCgEJAQAAAA==.',
['草米']='草米奥罗拉:BAAALgAECgQJCgAAAA==.',
['萬伏']='萬伏高压灬電:BAAALgAECgYJBQAAAA==.',
['蓝泥']='蓝泥湾:BAABLgAFFH8HAAIBAAIJWhCgGgCtAAABAAIJWhCgGgCtAAAAAA==.',
['虎卫']='虎卫小宁:BAAALgAECgcJEAAAAA==.',
['血欲']='血欲残阳:BAAALgAECgEJAQAAAA==.',
['赛芙']='赛芙蓉:BAAALgAECgcJEgAAAA==.',
['那一']='那一抹深蓝丶:BAAALgAECgQJAwAAAA==.',
['那些']='那些往事:BAAALgAECgYJEAAAAA==.',
['阿兰']='阿兰:BAAALgAECgcJBwAAAA==.',
['雷惊']='雷惊:BAAALgADCgYJCgAAAA==.',
['韩立']='韩立:BAAALgAECgIJAgAAAA==.',
['风吟']='风吟客:BAAALgAFFAMJBAAAAA==.',
['风灵']='风灵月影:BAAALgADCgcJBwAAAA==.',
['鸦鸦']='鸦鸦爱你哟:BAABLgAECn8UAAIBAAcJ3B/DTwBIAgABAAcJ3B/DTwBIAgAAAA==.',
['黑色']='黑色的云:BAAALgAECgQJBAAAAA==.',
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
