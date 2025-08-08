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
 local lookup = {'Unknown-Unknown','DeathKnight-Blood','Mage-Arcane','Paladin-Protection','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Shaman-Restoration','Shaman-Enhancement','DemonHunter-Vengeance','DemonHunter-Havoc','Warlock-Demonology','DeathKnight-Unholy','Druid-Balance','Priest-Discipline','Priest-Holy','Druid-Guardian','Priest-Shadow','Mage-Frost','Hunter-Survival','Rogue-Assassination','Hunter-Marksmanship',}; local provider = {region='CN',realm='基尔罗格',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ax='Axe:BAAAKgADCgEIAQABKgADCggIDQABAAAAAA==.',Ca='Cassandra:BAAAKgADCgEIAQAAAA==.',Da='Dante:BAAAKgADCgEIAQAAAA==.',De='Decnov:BAAAKgAFFAQIBAAAAA==.',Ki='Kiko:BAAAKgAFFAQIBAAAAA==.',Le='Lee:BAAAKgADCggIDQAAAA==.',No='Noir:BAAAKgAFFAEIAQAAAA==.',Pa='Pasha:BAAAKgAFFAgIAQAAAA==.',Rx='Rxe:BAABKgAFFH8GAAICAAYIyQfbGQDTAAACAAYIyQfbGQDTAAAAAA==.',Ti='Tinypc:BAABKgAFFH8IAAIDAAgI5gv0CADkAQADAAgI5gv0CADkAQAAAA==.',Tu='Tupac:BAAAKgAECggICQAAAA==.',Ty='Tyrandan:BAAAKgAECgYIBgAAAA==.',['一笔']='一笔丢糟:BAABKgAFFH8GAAIEAAYI1w/3DwAFAQAEAAYI1w/3DwAFAQABKgAFFAgIDQAFAOEYAA==.',['丨死']='丨死神丨:BAAAKgAECggICAAAAA==.',['九萬']='九萬:BAAAKgAECgIIAgAAAA==.',['亡魂']='亡魂摆渡者:BAABKgAECn9MAAMGAAgIMiR5AQDmAgAGAAgIMiR5AQDmAgAHAAgI6RzuBQATAgAAAA==.',['京酱']='京酱肉丝:BAABKgAECn8UAAIIAAgIkhTCPACCAQAIAAgIkhTCPACCAQAAAA==.',['伊兰']='伊兰德:BAAAKgAECgMIAwAAAA==.',['你太']='你太火热:BAAAKgAECgUIBQAAAA==.',['依梦']='依梦:BAABKgAFFH8HAAIDAAcIgwovDwB3AQADAAcIgwovDwB3AQAAAA==.',['冻住']='冻住不洗澡:BAAAKgAFFAQIBAAAAA==.',['刀刀']='刀刀:BAABKgAFFH8GAAIJAAYIVg6HCQA9AQAJAAYIVg6HCQA9AQABKgAFFAgIBAABAAAAAA==.',['创圣']='创圣:BAAAKgADCggIDAAAAA==.',['华北']='华北吉祥管管:BAAAKgAECgQIBAAAAA==.',['华戈']='华戈:BAAAKgAECgIIAgAAAA==.',['可肥']='可肥肥:BAAAKgAECgIIAgAAAA==.',['哎呦']='哎呦我呸:BAAAKgAECgIIAQAAAA==.',['商务']='商务印书馆:BAAAKgAFFAgIAgAAAA==.',['回到']='回到过去俊:BAAAKgAECgIIAgAAAA==.',['大猪']='大猪:BAAAKgADCggICAAAAA==.',['太妃']='太妃糖:BAABKgAFFH8LAAMKAAYIkg4jDADtAAAKAAYIcAsjDADtAAALAAQIdwt4GwDXAAAAAA==.',['奶萨']='奶萨:BAAAKgAECgIIAgAAAA==.',['宇智']='宇智波尧:BAAAKgAECgMIAwAAAA==.',['小可']='小可乐大王:BAAAKgAFFAMIBAAAAA==.',['小红']='小红人:BAAAKgAECgcIEwAAAA==.',['尤为']='尤为亲年:BAAAKgAECgcIBgAAAA==.',['川页']='川页君:BAAAKgADCgIIAgAAAA==.',['幻觉']='幻觉纠结:BAAAKgAFFAQIBAAAAA==.',['强人']='强人唢男:BAAAKgAECgQIBAAAAA==.',['强力']='强力得瑟:BAAAKgAFFAQIBAAAAA==.',['快把']='快把怪聚好:BAAAKgAFFAIIAgABKgAFFAgIDwAGAJIcAA==.',['恶魔']='恶魔小旋风:BAABKgAFFH8eAAQMAAYIkx7fAABXAQAMAAUIZR3fAABXAQAGAAUIHhzLCQAUAQAHAAMI/hPoCQDbAAAAAA==.',['我是']='我是:BAAAKgAECgYIBgAAAA==.',['拍卖']='拍卖所等底:BAAAKgADCggICAAAAA==.',['无聊']='无聊的猪哥:BAABKgAFFH8MAAMNAAQIVhWvMADPAAANAAQIVhWvMADPAAACAAQI6Qd9KAB1AAABKgAFFAYICgAOAPMlAA==.',['时尚']='时尚女人:BAAAKgAECgcICAAAAA==.',['月光']='月光黑影:BAAAKgAECggICAAAAA==.',['术土']='术土亢:BAAAKgADCggICAAAAA==.',['术魔']='术魔:BAAAKgADCgYICwAAAA==.',['柒條']='柒條:BAACKgAFFH8HAAMPAAcIAxCqDgAxAQAPAAQI+hCqDgAxAQAQAAMIFQ7UNQBpAAAqAAQKfyUAAhAACAj6IvQFALkCABAACAj6IvQFALkCAAAA.',['梅兰']='梅兰竹菊:BAAAKgAECggICAAAAA==.',['椎名']='椎名真白:BAAAKgAECgEIAQAAAA==.',['渣德']='渣德:BAABKgAFFH8bAAMRAAYIwxaXAwD4AAAOAAYIvhDUIQAWAQARAAMIqR2XAwD4AAAAAA==.',['潘帕']='潘帕斯巨婴:BAAAKgAECggIEAAAAA==.',['猎灬']='猎灬袭:BAAAKgAECgYIBgAAAA==.',['瓦尔']='瓦尔基利:BAAAKgADCggIHQAAAA==.',['皇阿']='皇阿玛:BAAAKgAFFAQIBAAAAA==.',['破亡']='破亡之舞:BAAAKgADCggICAAAAA==.',['破曉']='破曉斩月:BAABKgAECn8gAAISAAgIIxXqGwCpAQASAAgIIxXqGwCpAQAAAA==.',['美瞳']='美瞳:BAAAKgAECgIIAgAAAA==.',['臂章']='臂章怪兽:BAAAKgAFFAIIAgAAAA==.',['血兽']='血兽牛魔亡:BAAAKgADCggIBwAAAA==.',['血妖']='血妖之后:BAABKgAECn8UAAMDAAgIWR35IwDYAQADAAgIxBn5IwDYAQATAAQImB+CQABnAQAAAA==.',['跑脱']='跑脱了是蚂虾:BAABKgAECn8bAAIUAAgIgQvcDAAUAQAUAAgIgQvcDAAUAQAAAA==.',['辛迪']='辛迪:BAAAKgAFFAgIAQAAAA==.',['进退']='进退两男:BAABKgAECn8dAAIVAAcIlBDTIQBPAQAVAAcIlBDTIQBPAQAAAA==.',['金壮']='金壮壮:BAAAKgAFFAQIBAAAAA==.',['阿拉']='阿拉是熊哥:BAAAKgADCgQIBAAAAA==.',['陆萬']='陆萬:BAABKgAECn8mAAIWAAgInSSNAgDZAgAWAAgInSSNAgDZAgAAAA==.',['难道']='难道我是神:BAAAKgAFFAUIAQAAAA==.',['雷加']='雷加坦格利安:BAAAKgAECggIEAAAAA==.',['飞天']='飞天土豆泥:BAAAKgAFFAQIBAAAAA==.',['骷髅']='骷髅手:BAACKgAFFH8IAAIGAAMIeQpBNACeAAAGAAMIeQpBNACeAAAqAAQKfxsAAgYACAhtGtUVAPgBAAYACAhtGtUVAPgBAAAA.',['麻头']='麻头花娘:BAAAKgAECgEIAQAAAA==.',['黄风']='黄风岭架大狙:BAAAKgAFFAYIAgAAAA==.',['黎明']='黎明挚爱:BAABKgAFFH8QAAMTAAYIKxYICgAlAQADAAYI+BIPEABrAQATAAYITw0ICgAlAQAAAA==.',['黜騚']='黜騚一叮:BAAAKgAECgIIAwAAAA==.',['齐静']='齐静春:BAABKgAFFH8GAAIFAAYIeRRKHQB+AQAFAAYIeRRKHQB+AQAAAA==.',['龙王']='龙王下崽儿:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end