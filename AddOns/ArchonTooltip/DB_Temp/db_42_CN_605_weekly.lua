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
 local lookup = {'Druid-Restoration','Druid-Balance','Rogue-Assassination','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','Hunter-BeastMastery','Monk-Mistweaver','Rogue-Subtlety','Warlock-Destruction','Warlock-Demonology','Mage-Fire','Hunter-Marksmanship','Paladin-Retribution','Mage-Arcane','Priest-Discipline','Priest-Holy','Priest-Shadow','Druid-Feral','Shaman-Restoration','Shaman-Elemental',}; local provider = {region='CN',realm='古拉巴什',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ch='Chunter:BAAAKgADCgIIAgAAAA==.',Ge='Geekee:BAAAKgAFFAEIAgAAAA==.',Ha='Handcramp:BAAAKgAECgYICAAAAA==.Haruka:BAABKgAFFH8UAAMBAAgItxyTBwCWAQABAAgItxyTBwCWAQACAAUIHBMsFAAdAQAAAA==.',Me='Merth:BAAAKgAECgEIAQAAAA==.',Ms='Mscofield:BAAAKgAECgUIBgAAAA==.',Na='Nanna:BAAAKgADCggICAAAAA==.',Sh='Shadowalker:BAABKgAFFH8FAAIDAAUIEBvrDwBRAQADAAUIEBvrDwBRAQAAAA==.Shadowhealer:BAABKgAFFH8IAAMEAAYI7BDdKACXAAAEAAQIFAfdKACXAAAFAAMI8gWBCAByAAAAAA==.',Yu='Yui:BAABKgAFFH8GAAIBAAYI+SIfBAD1AQABAAYI+SIfBAD1AQAAAA==.',['不是']='不是死骑啊:BAABKgAFFH8IAAIGAAQIDh8mEAD5AAAGAAQIDh8mEAD5AAAAAA==.',['丧钟']='丧钟术丶:BAAAKgAECgMIAwAAAA==.',['丨隊']='丨隊長:BAABKgAECn8hAAIHAAgIsxM1QgCeAQAHAAgIsxM1QgCeAQAAAA==.',['为了']='为了部落哟:BAAAKgAECgYICgAAAA==.',['乌云']='乌云弥漫:BAAAKgAECgQICwAAAA==.',['乌拉']='乌拉巴拉:BAAAKgAECgMIAwAAAA==.',['云雾']='云雾随想:BAABKgAFFH8IAAIIAAgILxnZAwAxAgAIAAgILxnZAwAxAgAAAA==.',['五斤']='五斤二两:BAABKgAECn85AAMJAAgIZQ9KAwBuAQAJAAgI4g1KAwBuAQADAAgIlgwTIwBEAQAAAA==.',['千手']='千手大人:BAAAKgAECgEIAQAAAA==.',['发型']='发型要飘逸:BAAAKgADCggICAAAAA==.',['可口']='可口可乐:BAAAKgAECggICAAAAA==.',['吃肉']='吃肉:BAABKgAECn8UAAMCAAgIQRMDRACaAQACAAgIQRMDRACaAQABAAQIcw2WTQCsAAAAAA==.',['地狱']='地狱向右:BAAAKgADCggICAAAAA==.',['大地']='大地飞歌:BAAAKgAECggIDQAAAA==.',['大尾']='大尾巴兔子:BAAAKgADCggICAAAAA==.',['天上']='天上有牛:BAAAKgADCggICAAAAA==.',['天堂']='天堂向左:BAAAKgAECgYICQAAAA==.',['夭夜']='夭夜:BAAAKgAECggIDgAAAA==.',['奶不']='奶不自救丶:BAAAKgAECgEIAQAAAA==.',['宁宁']='宁宁:BAAAKgADCgYIBgAAAA==.',['射手']='射手座小欧皇:BAAAKgAECgQIBAAAAA==.',['小狗']='小狗砸:BAABKgAFFH8FAAMKAAUIbQG6OwCAAAAKAAIIlwK6OwCAAAALAAMIpwBwLQBAAAAAAA==.',['德国']='德国姥:BAAAKgAECggIDwAAAA==.',['星星']='星星的星星:BAAAKgADCggIDAAAAA==.',['来一']='来一打奶酪:BAABKgAFFH8KAAIMAAYI/x5hAwDaAQAMAAYI/x5hAwDaAQAAAA==.',['毒药']='毒药:BAAAKgADCgYICwAAAA==.',['灬潴']='灬潴潴俊灬:BAAAKgAECggICAAAAA==.',['狗蛋']='狗蛋丶:BAABKgAFFH8WAAMHAAYItCU9BwAOAgAHAAYIpSU9BwAOAgANAAYI0iL1CADKAQAAAA==.',['瑞文']='瑞文奈尔:BAAAKgADCgEIAQAAAA==.',['胖大']='胖大星:BAAAKgAECgUIAQAAAA==.',['胖毛']='胖毛丶:BAABKgAFFH8OAAIHAAYIjiChDgCKAQAHAAYIjiChDgCKAQAAAA==.',['胖胖']='胖胖永不落泪:BAAAKgADCgIIAgAAAA==.',['萨爹']='萨爹丶:BAAAKgAECgcICgAAAA==.',['藤源']='藤源杰伦:BAABKgAFFH8SAAIOAAgI8hPqCAAeAgAOAAgI8hPqCAAeAgAAAA==.',['蟹黄']='蟹黄味瓜子仁:BAAAKgADCgQIBAAAAA==.',['血刃']='血刃契约:BAABKgAFFH8GAAINAAYIvA/mFAA8AQANAAYIvA/mFAA8AQAAAA==.',['血色']='血色蔷薇丶:BAAAKgAECggICAAAAA==.',['裟椤']='裟椤嵐茵:BAAAKgAECgIIAgAAAA==.',['诅咒']='诅咒传说:BAABKgAFFH8VAAMMAAUIjyFfDwBNAQAMAAUIjyFfDwBNAQAPAAEIAACOSwAAAAABKgAFFAgIGAAQAOgeAA==.',['赵丽']='赵丽颖:BAAAKgAECgcIBwAAAA==.',['逆鳞']='逆鳞之殇:BAAAKgAECgcIBwAAAA==.',['酷兰']='酷兰:BAABKgAFFH8KAAMRAAYI2RaUEwCkAAARAAUIuBWUEwCkAAASAAIIiRgQIACLAAAAAA==.',['里美']='里美尤利娅:BAAAKgAECggIDwAAAA==.',['铁蛋']='铁蛋乄:BAAAKgAFFAMIAwAAAA==.',['阿庫']='阿庫諾諾基亞:BAAAKgADCgIIAgAAAA==.',['韩哥']='韩哥吃了么:BAAAKgADCggIEwAAAA==.韩哥吃了没:BAABKgAECn8oAAMCAAgIVRyKRgCRAQACAAgIoBqKRgCRAQATAAQIfxz/BwBVAQAAAA==.',['飞飞']='飞飞牛:BAABKgAECn8VAAMUAAgIUBxUKgDUAQAUAAgIUBxUKgDUAQAVAAEIFQ1pdQA3AAAAAA==.',['鬼射']='鬼射手:BAABKgAFFH8IAAIHAAgIWweLCgCpAQAHAAgIWweLCgCpAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end