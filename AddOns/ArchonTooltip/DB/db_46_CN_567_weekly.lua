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

local lookup = {'Priest-Holy','Unknown-Unknown','Priest-Shadow','Priest-Discipline','Rogue-Subtlety','Rogue-Assassination','Evoker-Preservation','Evoker-Augmentation','Paladin-Retribution','Paladin-Protection','Mage-Frost','Druid-Balance','Druid-Restoration','Druid-Guardian','Hunter-Marksmanship','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration',}
local provider = {region='CN',realm='伊兰尼库斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ax='Axten:BAAALgAECgEJAQAAAA==.',
Bl='Bliztwing:BAAALgAFFAEJAQAAAA==.',
De='Demonh:BAAALgAFFAEJAQAAAA==.',
Et='Ethericess:BAABLgAECn8WAAIBAAgJQh8RCQC6AgABAAgJQh8RCQC6AgAAAA==.',
Ev='Evelynn:BAAALgAECgIJAQABLgAECgcJDAACAAAAAA==.',
Ge='Gest:BAAALgADCgEJAQAAAA==.',
Vi='Vincecarter:BAAALgAECgEJAQAAAA==.',
['不要']='不要让哥迷恋:BAAALgAECgcJCwAAAA==.',
['丨糖']='丨糖门丨:BAAALgADCgcJBwAAAA==.',
['丶火']='丶火焱灬:BAAALgADCgQJBAAAAA==.',
['乔雯']='乔雯晴风:BAAALgAECggJAQAAAA==.乔雯月刃:BAAALgAECgcJDgAAAA==.',
['亦影']='亦影:BAAALgAECgEJAwAAAA==.',
['伊力']='伊力丹之怒:BAAALgAECgIJAgAAAA==.',
['元祖']='元祖:BAAALgADCgMJAwAAAA==.',
['先森']='先森乃俵酱紫:BAAALgAECgYJBgAAAA==.',
['光头']='光头丨术:BAAALgAECgQJBAAAAA==.',
['冷酸']='冷酸灵:BAAALgAECgcJBwAAAA==.',
['别当']='别当心孩子:BAAALgAECgIJAgAAAA==.',
['匆匆']='匆匆忙忙:BAAALgAECgMJAwAAAA==.',
['原切']='原切:BAAALgADCgUJBQAAAA==.',
['呆萌']='呆萌大侃侃丶:BAAALgAECgYJCAAAAA==.',
['哆啦']='哆啦默默:BAAALgAECgMJAwAAAA==.',
['哈斯']='哈斯乌拉:BAAALgAECgYJCAAAAA==.',
['喵子']='喵子:BAAALgAFFAEJAQAAAA==.',
['喷火']='喷火龙龙:BAAALgAFFAYJAgAAAA==.',
['噩灵']='噩灵游荡:BAAALgAECgEJAQABLgAFFAUJBAACAAAAAA==.',
['四海']='四海:BAAALgAECgEJAgAAAA==.',
['回来']='回来玩奶妈:BAAALgAECgMJAwAAAA==.',
['圣职']='圣职玛利亚:BAACLgAFFH8KAAIDAAMJUAxdDADpAAADAAMJUAxdDADpAAAuAAQKfxoABAMABglnHRseAOgBAAMABglnHRseAOgBAAQABgl+DvErADwBAAEAAwlDDfljAJ4AAAAA.',
['多吃']='多吃水果:BAAALgADCgQJBAAAAA==.',
['大亨']='大亨要减肥:BAAALgADCgMJAwAAAA==.',
['大块']='大块头大智慧:BAAALgAECgEJAQAAAA==.',
['天妒']='天妒灬风流:BAAALgAECgEJAQAAAA==.',
['奎尔']='奎尔托斯血蹄:BAAALgAECgMJAwAAAA==.',
['奶油']='奶油包:BAAALgAECgEJAQAAAA==.',
['奶茶']='奶茶刂呼吸:BAAALgAECgcJEAAAAA==.',
['好好']='好好奶人:BAAALgAECgMJAwAAAA==.',
['如初']='如初:BAAALgADCgUJBQAAAA==.',
['小乐']='小乐意:BAAALgAFFAIJAgAAAA==.',
['小懒']='小懒儿:BAAALgAECgEJAQAAAA==.',
['常凯']='常凯申:BAAALgAECgYJDgAAAA==.',
['幽默']='幽默小刀:BAACLgAFFH8KAAIFAAMJPRMjDQAVAQAFAAMJPRMjDQAVAQAuAAQKfxcAAwUABgmzHh4kANgBAAUABgmzHh4kANgBAAYAAQnXAVUiACMAAAAA.',
['弥弥']='弥弥丶:BAACLgAFFH8JAAIBAAMJ9hZMCADjAAABAAMJ9hZMCADjAAAuAAQKfxYAAgEABgnsHNEeAOkBAAEABgnsHNEeAOkBAAAA.',
['春水']='春水蜉蝣:BAAALgAECgcJBwAAAA==.',
['普西']='普西妮:BAAALgADCgYJBgAAAA==.',
['月海']='月海鱼鱼猫:BAABLgAECn8VAAMHAAgJVBwpBACLAQAHAAYJyCApBACLAQAIAAMJgxQ1SAC4AAAAAA==.',
['来如']='来如疯:BAAALgAECgEJAQAAAA==.',
['极限']='极限了:BAACLgAFFH8JAAIJAAMJdiPlDQA8AQAJAAMJdiPlDQA8AQAuAAQKfxYAAwkABgkcIsU8ADECAAkABgkcIsU8ADECAAoAAQm/C0ZGACgAAAAA.',
['格奈']='格奈森瑙:BAACLgAFFH8JAAMEAAQJxxWXDAAJAQAEAAQJxxWXDAAJAQABAAIJvQtrBgCEAAAuAAQKfxUABAQACAkRHU8JAKYCAAQACAkRHU8JAKYCAAMABAmSGXI2ADkBAAEAAwm8E8xfALMAAAAA.',
['梦落']='梦落叶璇:BAAALgAECgEJAQAAAA==.',
['汝力']='汝力微丶饭否:BAABLgAFFH8GAAILAAIJERU4OgC2AAALAAIJERU4OgC2AAAAAA==.',
['流沙']='流沙之光:BAAALgAECgIJAgAAAA==.',
['淡忘']='淡忘凡尘:BAABLgAECn8WAAQMAAcJHwonRQAaAQAMAAYJ5AsnRQAaAQANAAUJkga+jAC6AAAOAAEJgwN1OAAWAAAAAA==.',
['淡淡']='淡淡的歌:BAABLgAFFH8HAAIPAAMJaQ/WFQDsAAAPAAMJaQ/WFQDsAAAAAA==.',
['混沌']='混沌灬奎托斯:BAAALgAECgYJCQAAAA==.混沌灬怒风:BAAALgAECgcJDAAAAA==.',
['烧酒']='烧酒和尺八:BAAALgAECgUJCAAAAA==.',
['白胜']='白胜:BAAALgADCgUJBQAAAA==.',
['皮卡']='皮卡丘丘:BAAALgAFFAUJAQAAAA==.',
['神思']='神思者:BAAALgAECgUJAQAAAA==.',
['绯雪']='绯雪:BAACLgAFFH8KAAILAAMJXgllLwD4AAALAAMJXgllLwD4AAAuAAQKfxUAAgsABgkpF8KeAJkBAAsABgkpF8KeAJkBAAAA.',
['聪聪']='聪聪呆:BAAALgAECgIJAgABLgAECgcJDAACAAAAAA==.',
['肉丨']='肉丨土豆:BAACLgAFFH8IAAIQAAQJ3gRlBQAJAQAQAAQJ3gRlBQAJAQAuAAQKfxkABBAACAn4FGQ8AFoBABAACAn4FGQ8AFoBABEAAglnCugmAGsAABIAAgniARKUAEwAAAAA.',
['舒尔']='舒尔果:BAAALgAECgUJBgAAAA==.',
['蔚然']='蔚然橙烽:BAAALgAECgEJAgAAAA==.',
['血色']='血色月魂:BAAALgADCgUJBQAAAA==.',
['语風']='语風:BAAALgAECgEJAQABLgAECgEJAwACAAAAAA==.',
['辛夷']='辛夷:BAAALgAECgEJAgAAAA==.',
['邪恶']='邪恶的木偶:BAACLgAFFH8KAAMQAAMJvCF+CwAyAQAQAAMJvCF+CwAyAQASAAMJkhyrFAC1AAAuAAQKfxUAAhIABgnsJcsVAGcCABIABgnsJcsVAGcCAAAA.',
['醉卧']='醉卧星河:BAAALgAECgYJEAAAAA==.',
['钓鱼']='钓鱼爱好者:BAAALgAECgkJCQAAAA==.',
['阿寳']='阿寳:BAAALgAECgUJBQAAAA==.',
['零度']='零度疯狂:BAAALgAECgEJAQAAAA==.',
['霜之']='霜之裁决:BAAALgAECgEJAQAAAA==.',
['靚仔']='靚仔丨缺德否:BAAALgADCgYJBgAAAA==.',
['鞣蚌']='鞣蚌大:BAABLgAFFH8FAAIJAAMJmBSoCQD+AAAJAAMJmBSoCQD+AAAAAA==.',
['魂葬']='魂葬丶圣光灬:BAAALgAECgEJAQAAAA==.魂葬丶暮落灬:BAAALgAECgkJAQAAAA==.',
['黑黑']='黑黑的圣光:BAAALgAECgEJAQAAAA==.',
['默默']='默默宝宝:BAAALgAECgYJCAAAAA==.',
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
