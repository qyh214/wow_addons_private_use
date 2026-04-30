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

local lookup = {'DemonHunter-Vengeance','Evoker-Preservation','Monk-Mistweaver','Shaman-Elemental','Warlock-Demonology','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Blood',}
local provider = {region='CN',realm='安纳塞隆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bo='Bo:BAAALgADCgEJAQAAAA==.',
Bu='Bunk:BAAALgAECgIJAgAAAA==.',
Ga='Garyz:BAAALgADCgUJBQAAAA==.',
Kp='Kpya:BAAALgAFFAUJAwAAAA==.',
Me='Mes:BAAALgADCgEJAQAAAA==.',
Re='Redwoods:BAAALgAECgQJBAAAAA==.',
['下雨']='下雨天打小孩:BAAALgADCgYJBgAAAA==.',
['不莣']='不莣初心:BAAALgADCgIJAgAAAA==.',
['不要']='不要嘻嘻哈哈:BAAALgADCgcJBwAAAA==.',
['丧彪']='丧彪:BAAALgAECgEJAQAAAA==.',
['丿璀']='丿璀璨彡:BAAALgADCgMJAwAAAA==.',
['乔克']='乔克:BAAALgADCgIJAgAAAA==.',
['云逸']='云逸:BAAALgAECggJCwAAAA==.',
['亢奋']='亢奋的小红花:BAAALgADCggJCgAAAA==.',
['任性']='任性的七月:BAAALgAECgQJBAAAAA==.',
['伊利']='伊利大雷:BAAALgAECgYJCwAAAA==.',
['伊斯']='伊斯坎达尔:BAAALgADCgEJAQAAAA==.',
['众乐']='众乐乐:BAAALgAECgUJBgAAAA==.',
['你听']='你听得到:BAAALgAECgUJCAAAAA==.',
['你妹']='你妹:BAAALgADCgEJAQAAAA==.',
['内个']='内个谁丶:BAAALgAECgMJAwAAAA==.',
['冒烟']='冒烟的小火柴:BAAALgAECgEJAQAAAA==.',
['冰封']='冰封正义:BAAALgAECgMJBAAAAA==.',
['冰激']='冰激淋:BAAALgAECgQJBAAAAA==.',
['别拿']='别拿浪当自由:BAAALgAECgkJBgAAAA==.',
['加死']='加死你:BAAALgAECgEJAQAAAA==.',
['包心']='包心菜:BAAALgADCgEJAQAAAA==.',
['原灬']='原灬罪:BAAALgADCgIJAgAAAA==.',
['叫我']='叫我卡叔:BAAALgAECgYJCQAAAA==.',
['吹泡']='吹泡泡的蜗牛:BAAALgADCgMJAwAAAA==.',
['和珅']='和珅的护甲:BAAALgAECgkJDAABLgAFFAUJBQABAFMlAA==.',
['哀木']='哀木骑:BAAALgAECgIJAgAAAA==.',
['哈利']='哈利撸呀:BAAALgAECgQJBgAAAA==.',
['哥斯']='哥斯拉:BAACLgAFFH8KAAICAAQJiBeSCwAxAQACAAQJiBeSCwAxAQAuAAQKfxwAAgIACQnUHQ0EABYDAAIACQnUHQ0EABYDAAAA.',
['唤魔']='唤魔师:BAABLgAECn8VAAIDAAgJExXzGAD3AQADAAgJExXzGAD3AQABLgAFFAQJCgACAIgXAA==.',
['嘻嘻']='嘻嘻路路:BAAALgAECgIJBAAAAA==.',
['嘿丶']='嘿丶牢头:BAAALgAECgIJAgAAAA==.',
['圣血']='圣血帝王:BAAALgADCgEJAQAAAA==.',
['圣魔']='圣魔狂:BAAALgAFFAQJBAABLgAFFAYJFgAEAMUZAA==.',
['大粗']='大粗牛:BAAALgADCgIJAgAAAA==.',
['天地']='天地有邪气:BAAALgADCgkJDwAAAA==.',
['子吟']='子吟:BAABLgAFFH8FAAIFAAUJwxflBADQAQAFAAUJwxflBADQAQAAAA==.',
['小卡']='小卡车:BAAALgAECgEJAQAAAA==.',
['小小']='小小玫瑰:BAAALgAECgMJAwAAAA==.',
['工友']='工友夸我够猛:BAAALgADCgMJAwAAAA==.工友夸我好强:BAAALgAECgEJAQAAAA==.工友夸我超强:BAAALgADCgQJBAAAAA==.',
['御前']='御前一品:BAAALgADCgUJBgAAAA==.',
['快乐']='快乐魔术师:BAAALgADCgEJAQAAAA==.',
['我家']='我家咕呢:BAAALgADCgUJBQAAAA==.',
['我是']='我是炮弹:BAAALgADCgEJAQAAAA==.',
['戕戮']='戕戮之魂:BAAALgAECgEJAQAAAA==.',
['战怒']='战怒:BAAALgAECgEJAQAAAA==.',
['戰丨']='戰丨钰:BAABLgAFFH8FAAIGAAMJXw0vEADWAAAGAAMJXw0vEADWAAAAAA==.',
['斯内']='斯内克:BAAALgAECgIJBAAAAA==.',
['无声']='无声笛:BAAALgAECgEJAQAAAA==.',
['晨雾']='晨雾起:BAAALgAECgYJCgAAAA==.',
['暗淡']='暗淡星辰:BAAALgAECgcJBwAAAA==.',
['月之']='月之千手葵:BAAALgADCgIJAgAAAA==.',
['有术']='有术:BAAALgAECgUJCQAAAA==.',
['木桶']='木桶牛:BAAALgADCgEJAQAAAA==.',
['枫北']='枫北彳来的晚:BAAALgAECgYJBgAAAA==.',
['梦幻']='梦幻丶华尔兹:BAAALgAECgEJAQAAAA==.',
['欧莉']='欧莉梅尔:BAAALgAECgEJAwAAAA==.',
['歹匕']='歹匕尸:BAAALgAECgYJDgAAAA==.',
['比克']='比克:BAAALgAECgMJBAAAAA==.',
['泼墨']='泼墨:BAAALgAECgYJEQAAAA==.',
['清平']='清平调:BAAALgAECgEJAQAAAA==.',
['湘澤']='湘澤雅:BAAALgADCgUJBQAAAA==.',
['灬七']='灬七喜灬:BAAALgADCgcJDQAAAA==.',
['灬回']='灬回笼觉主灬:BAAALgAECgEJAQAAAA==.',
['灬苏']='灬苏坡曼灬:BAAALgAECgYJCAAAAA==.灬苏某某灬:BAAALgAECgIJAgAAAA==.',
['灬风']='灬风中追风灬:BAAALgAECgcJCQAAAA==.',
['牛伟']='牛伟雄:BAAALgAECgYJBgAAAA==.',
['狮翼']='狮翼法神僧:BAAALgADCgMJAwAAAA==.',
['猎鲨']='猎鲨丶:BAAALgAECgIJAgAAAA==.',
['王者']='王者姿态:BAAALgADCgMJAwAAAA==.',
['痛苦']='痛苦机器:BAAALgAFFAEJAQAAAA==.',
['白魔']='白魔王灬丨:BAAALgAFFAQJBAAAAA==.',
['神恩']='神恩结界:BAAALgAECgcJDAAAAA==.',
['神机']='神机喵算:BAAALgAECgYJBQAAAA==.',
['空解']='空解:BAAALgAECgQJBAAAAA==.',
['笑你']='笑你个头:BAAALgADCgUJBQAAAA==.',
['紫色']='紫色枫糖:BAAALgAECgYJBwAAAA==.',
['纤纤']='纤纤:BAAALgADCgEJAQAAAA==.纤纤湘妞:BAACLgAFFH8FAAIDAAMJTgkNDQDUAAADAAMJTgkNDQDUAAAuAAQKfxUAAgMACQmVEEkfALsBAAMACQmVEEkfALsBAAAA.纤纤青丝:BAAALgAECgYJBgAAAA==.',
['纳兹']='纳兹多拉格尼:BAAALgAFFAQJAQAAAA==.',
['美拉']='美拉德:BAABLgAFFH8FAAIGAAUJYhgvAwC4AQAGAAUJYhgvAwC4AQAAAA==.',
['脆皮']='脆皮大天使:BAAALgAECgIJAwAAAA==.脆皮烤年糕:BAAALgAECgUJBQABLgAFFAQJCgACAIgXAA==.',
['自由']='自由自在:BAAALgAECgYJCAAAAA==.',
['艾希']='艾希米蕾雅:BAAALgAECgEJAQAAAA==.',
['艾德']='艾德蕾妮丶:BAAALgAECgEJAQAAAA==.',
['落花']='落花聼雨:BAAALgAECgEJAQAAAA==.',
['蓝羽']='蓝羽:BAACLgAFFH8OAAIHAAQJLx7VAgCCAQAHAAQJLx7VAgCCAQAuAAQKfxkAAgcACAkDJD0OACkDAAcACAkDJD0OACkDAAAA.',
['西门']='西门槑战:BAAALgAECgEJAQAAAA==.西门槑术:BAAALgAECgIJAwAAAA==.',
['请叫']='请叫我王昊霁:BAAALgAECgMJAwAAAA==.',
['辣味']='辣味小野马:BAAALgADCgcJBwAAAA==.',
['逆天']='逆天战神:BAAALgAFFAQJBAAAAA==.逆天死神:BAAALgAECgQJBAAAAA==.',
['逍遥']='逍遥一梦:BAAALgAFFAQJAwAAAA==.',
['醉往']='醉往青:BAAALgAECggJCQAAAA==.',
['钻石']='钻石巧克力:BAAALgAECgQJCAAAAA==.',
['锁魔']='锁魔血晓贱:BAAALgAFFAIJBAAAAA==.',
['随便']='随便瞎玩:BAAALgAECgYJBgAAAA==.',
['霹雳']='霹雳惊弦:BAAALgAECgUJCAAAAA==.',
['领航']='领航:BAAALgADCgQJBAAAAA==.',
['骑车']='骑车子也上树:BAAALgADCgYJBgAAAA==.',
['骨染']='骨染锈尘:BAAALgAECgEJAQAAAA==.',
['鲲鲲']='鲲鲲奇妙冒险:BAAALgAECgcJEgAAAA==.',
['麥尅']='麥尅小牛:BAAALgADCgMJAwAAAA==.',
['麻油']='麻油叶:BAABLgAECn8WAAMHAAgJ9SBWNgBdAgAHAAcJgiFWNgBdAgAIAAEJpx3DQQBEAAAAAA==.',
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
