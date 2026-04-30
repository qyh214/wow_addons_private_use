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

local lookup = {'Paladin-Retribution','Priest-Discipline','Paladin-Holy','DeathKnight-Unholy','Priest-Holy','Priest-Shadow','Monk-Windwalker','Monk-Mistweaver','Mage-Frost','DeathKnight-Blood','DemonHunter-Devourer','Hunter-Marksmanship',}
local provider = {region='CN',realm='冬寒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Dr='Dreams:BAAALgAECgYJDwAAAA==.',
Ge='Genji:BAAALgAECgYJCgAAAA==.',
Kh='Khoun:BAAALgAECgIJAgAAAA==.',
Lu='Luna:BAAALgAECgUJCAAAAA==.',
Ma='Masochism:BAAALgADCgEJAQAAAA==.',
Mo='Moz:BAAALgAECgIJAwAAAA==.',
Ph='Phamonster:BAABLgAECn8XAAIBAAcJ6yMLFgDlAgABAAcJ6yMLFgDlAgAAAA==.',
Ta='Tarotaros:BAAALgAFFAIJBAAAAA==.',
Th='Thor:BAAALgADCgEJAQAAAA==.',
['一抹']='一抹:BAAALgAECgkJAgAAAA==.',
['不兮']='不兮君:BAAALgAECgMJAwABLgAECgYJFwACAOUeAA==.',
['两把']='两把刀混江湖:BAAALgAECgIJAwAAAA==.',
['丨若']='丨若叶睦丨:BAAALgADCgEJAQAAAA==.',
['丶若']='丶若叶睦丶:BAAALgADCgUJBwAAAA==.',
['丽莎']='丽莎:BAAALgAFFAQJBAAAAA==.',
['云朵']='云朵施法:BAAALgAECgEJAQAAAA==.',
['仔宝']='仔宝:BAAALgAECgQJBQAAAA==.',
['修亚']='修亚特:BAABLgAFFH8FAAIDAAMJ7RBlCADoAAADAAMJ7RBlCADoAAABLgAFFAcJCwABAEEbAA==.',
['兔朱']='兔朱迪:BAAALgAECgMJAwAAAA==.',
['兰溪']='兰溪路:BAAALgADCgcJBwAAAA==.',
['凤凰']='凤凰湾:BAAALgAECgYJEAAAAA==.',
['南城']='南城四旬:BAACLgAFFH8KAAIEAAUJyw7/CwB1AQAEAAUJyw7/CwB1AQAuAAQKfxQAAgQABwngGhBxAKYBAAQABwngGhBxAKYBAAAA.',
['叨叨']='叨叨死骑:BAAALgAECgQJBwAAAA==.',
['只要']='只要功夫深:BAAALgAECgYJEgAAAA==.',
['可樂']='可樂:BAAALgAECgMJBAAAAA==.',
['君不']='君不兮兮:BAABLgAECn8XAAMCAAYJ5R6sFQD5AQACAAYJ5R6sFQD5AQAFAAUJNxGMSgAOAQAAAA==.',
['啾啾']='啾啾:BAAALgAECgEJAQAAAA==.',
['嘚吧']='嘚吧嘚吧嘚:BAAALgADCgUJAwAAAA==.',
['夏奇']='夏奇羊:BAAALgAECgIJAgAAAA==.',
['大漩']='大漩涡作业员:BAAALgAECgEJAQAAAA==.',
['大矛']='大矛:BAAALgADCgYJBwAAAA==.',
['大魔']='大魔法师:BAAALgAECgYJBgAAAA==.',
['姜珮']='姜珮瑶:BAAALgAECgUJBwAAAA==.',
['安洁']='安洁莉娅:BAACLgAFFH8OAAQGAAQJXxgrBgBlAQAGAAQJXxgrBgBlAQACAAMJZgiRCwCUAAAFAAEJJw8CCwBNAAAuAAQKfyEABAIACAmPGO0XAN4BAAIABwn/Fu0XAN4BAAYABgmpI0gIAJMBAAUAAglBHrVlAJYAAAAA.',
['小可']='小可爱棉花糖:BAAALgAFFAIJBAAAAA==.',
['工程']='工程作业员:BAACLgAFFH8NAAMHAAQJYhEdAgBDAQAHAAQJYhEdAgBDAQAIAAIJIQWaEQCOAAAuAAQKfx8AAwcACAnUGtQQAHQCAAcACAnUGtQQAHQCAAgABAlIFAMSAPoAAAAA.',
['巴萨']='巴萨泽:BAAALgAFFAQJBAAAAA==.',
['徐州']='徐州牧陶:BAAALgADCgcJBwAAAA==.',
['快乐']='快乐亚索:BAAALgAECgkJCQAAAA==.',
['思念']='思念说给枫听:BAAALgAECgYJBwAAAA==.',
['感受']='感受辶:BAAALgAECggJDAAAAA==.',
['我真']='我真的很忙:BAAALgAECgIJAgAAAA==.',
['战火']='战火青春:BAAALgAECgYJAwAAAA==.',
['抽颗']='抽颗华子:BAAALgAECgQJBgAAAA==.',
['新村']='新村大黑子:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌湮灭大王:BAAALgAECgQJBAAAAA==.',
['昀丶']='昀丶:BAAALgAECgQJBAAAAA==.',
['昀灬']='昀灬:BAAALgADCgcJBwAAAA==.',
['春芒']='春芒野火:BAAALgAECgQJBAAAAA==.',
['晚风']='晚风:BAACLgAFFH8SAAIJAAUJJCJIBgD7AQAJAAUJJCJIBgD7AQAuAAQKfxwAAgkACAlGIwsXACADAAkACAlGIwsXACADAAAA.',
['暴走']='暴走的情绪丶:BAAALgAECgEJAQAAAA==.',
['梦于']='梦于彼岸深红:BAAALgAECgEJAQAAAA==.',
['梭边']='梭边边大王:BAAALgADCgMJAwAAAA==.',
['泽坦']='泽坦:BAABLgAFFH8FAAIKAAUJORVfAQCGAQAKAAUJORVfAQCGAQAAAA==.',
['浅吻']='浅吻:BAACLgAFFH8JAAIBAAMJuBgyEgATAQABAAMJuBgyEgATAQAuAAQKfxoAAgEACAlcHoo5AD0CAAEACAlcHoo5AD0CAAAA.',
['浮度']='浮度众生:BAAALgAECgYJEAAAAA==.',
['溺亡']='溺亡怨魂:BAAALgAECgYJBgAAAA==.',
['火鸡']='火鸡味锅巴:BAAALgAECgYJDgAAAA==.',
['灿幻']='灿幻开花:BAAALgAECgMJAwAAAA==.',
['烈牙']='烈牙仇瀑:BAACLgAFFH8JAAIKAAMJABxECQDzAAAKAAMJABxECQDzAAAuAAQKfxkAAwoACAlzFncPABQCAAoACAmhFHcPABQCAAQAAwkfEoTeAMMAAAAA.',
['爱上']='爱上擎天:BAACLgAFFH8IAAILAAUJ5AISEgA/AQALAAUJ5AISEgA/AQAuAAQKfx0AAgsACQkwFSMvAD8CAAsACQkwFSMvAD8CAAAA.',
['王淑']='王淑芬:BAAALgAECgUJBQAAAA==.',
['瘟疫']='瘟疫:BAABLgAFFH8KAAIKAAQJbR1VBABoAQAKAAQJbR1VBABoAQAAAA==.',
['盛怒']='盛怒:BAABLgAFFH8FAAIKAAUJBhlRAgBUAQAKAAUJBhlRAgBUAQAAAA==.',
['睦子']='睦子米:BAAALgAFFAEJAQAAAA==.',
['秋水']='秋水依仁:BAAALgAECgQJBAAAAA==.',
['第一']='第一公主殿下:BAAALgAECgMJAgAAAA==.',
['紫菜']='紫菜菜:BAAALgAFFAQJBAABLgAFFAYJBgAMAHEMAA==.',
['给你']='给你两棒槌:BAAALgAECgUJCAAAAA==.',
['绝活']='绝活三板斧:BAAALgAECgQJBAAAAA==.',
['若叶']='若叶睦:BAAALgAECgEJAQAAAA==.若叶睦丶:BAAALgADCgQJBAAAAA==.若叶问:BAAALgADCgEJAQAAAA==.若叶问丶:BAAALgAECgMJAwAAAA==.',
['落樱']='落樱:BAAALgAECgUJBQAAAA==.',
['诸葛']='诸葛连撸:BAAALgAECgcJEwAAAA==.',
['谁是']='谁是恶魔术:BAAALgAECgEJAQAAAA==.',
['赤霄']='赤霄:BAAALgAFFAMJAgAAAA==.',
['躬耕']='躬耕于南阳:BAAALgAECgUJBQAAAA==.',
['迪克']='迪克打爆猪头:BAAALgAECgUJBQAAAA==.',
['遗忘']='遗忘灬追忆:BAAALgAECgYJBgAAAA==.',
['醉巴']='醉巴龙:BAAALgAECgYJAgAAAA==.',
['铃鹿']='铃鹿御前:BAAALgAFFAEJAgAAAA==.',
['阿伯']='阿伯顿:BAAALgAFFAUJAQAAAA==.',
['阿拉']='阿拉莫斯:BAAALgADCgEJAQAAAA==.',
['飘影']='飘影:BAAALgAECgEJAwAAAA==.',
['饥荒']='饥荒:BAAALgAFFAQJAgAAAA==.',
['龍丫']='龍丫:BAAALgAECgYJBwAAAA==.',
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
