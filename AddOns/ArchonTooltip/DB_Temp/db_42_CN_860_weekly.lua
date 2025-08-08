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
 local lookup = {'DeathKnight-Blood','Druid-Restoration','Druid-Balance','Druid-Guardian','Mage-Arcane','Mage-Frost','Shaman-Restoration','Shaman-Elemental','DemonHunter-Vengeance','Paladin-Retribution','Warlock-Destruction','DemonHunter-Havoc','Paladin-Protection','DeathKnight-Unholy','Monk-Windwalker','Warrior-Fury','Warrior-Arms','Monk-Mistweaver',}; local provider = {region='CN',realm='阿努巴拉克',name='CN',type='weekly',zone=42,date='2025-08-03',data={De='Deletedelete:BAABKgAFFH8IAAIBAAgIORcJBQD4AQABAAgIORcJBQD4AQAAAA==.',Dk='Dka:BAAAKgAECgYIBgAAAA==.',Et='Eternallove:BAACKgAFFH8gAAQCAAUI6wlzCgDoAAACAAUI6wlzCgDoAAADAAMIrBNpGwDOAAAEAAMIugbbCgBmAAAqAAQKfyoAAwQACAg4GZwVAAABAAMABwiVGbFYAFgBAAQACAg+D5wVAAABAAAA.',['一初']='一初音未来一:BAAAKgAECgIIAgAAAA==.',['一盆']='一盆大米饭:BAABKgAFFH8IAAMFAAgIohRqEwBJAQAFAAQIERVqEwBJAQAGAAQIDhQeGAC1AAAAAA==.',['不高']='不高兴:BAABKgAECn8YAAMHAAgI0xFyTQBXAQAHAAYIEBFyTQBXAQAIAAUIMw/9UgDNAAAAAA==.',['专属']='专属牧牧:BAAAKgAECgEIAQAAAA==.专属猎手:BAAAKgAECgYICgAAAA==.专属骑士:BAAAKgADCggICAAAAA==.',['云韵']='云韵:BAAAKgAECgMIAwAAAA==.',['伊利']='伊利蛋丶怒风:BAABKgAFFH8JAAIJAAQIjQb7GwB2AAAJAAQIjQb7GwB2AAAAAA==.',['伤心']='伤心小背包:BAABKgAFFH8IAAIKAAQIvBaoFQACAQAKAAQIvBaoFQACAQAAAA==.',['依然']='依然月光:BAAAKgAECgQIBAABKgAFFAgIFQALAGkiAA==.',['冷静']='冷静的猎手:BAAAKgADCgQIBAAAAA==.',['加油']='加油小欧:BAAAKgADCggICAAAAA==.',['勇敢']='勇敢的心巅峰:BAAAKgADCgEIAgAAAA==.',['南希']='南希:BAACKgAFFH8QAAIKAAQIghW9NgCcAAAKAAQIghW9NgCcAAAqAAQKfxcAAgoACAhbIKo5AEICAAoACAhbIKo5AEICAAAA.',['变身']='变身狂魔:BAAAKgADCgcIBwAAAA==.',['只爱']='只爱暷説:BAAAKgAECgQIBgAAAA==.',['君临']='君临:BAAAKgAECgMIBgAAAA==.',['命定']='命定幽影:BAACKgAFFH8VAAILAAgIaSJcAgCkAgALAAgIaSJcAgCkAgAqAAQKfysAAgsACAh6IUYJAKMCAAsACAh6IUYJAKMCAAAA.',['回归']='回归欧阳:BAAAKgADCgQIBAAAAA==.',['圣光']='圣光之正义:BAAAKgADCgUIBgAAAA==.圣光忽悠着你:BAAAKgAECgYIBwAAAA==.',['埃辛']='埃辛诺斯战刃:BAABKgAFFH8IAAMMAAYIXRqrCwCnAQAMAAYIXRqrCwCnAQAJAAIIiAzrHQBsAAABKgAFFAgIDAAFAFcXAA==.',['堕落']='堕落信仰:BAAAKgAECgEIAQAAAA==.',['天际']='天际孤星:BAAAKgAFFAEIAQAAAA==.',['奶不']='奶不住怎么办:BAAAKgAECgIIAgAAAA==.',['安全']='安全裤:BAAAKgAECgQIBwAAAA==.',['小才']='小才子:BAABKgAFFH8GAAINAAYI8Ao0EwDhAAANAAYI8Ao0EwDhAAAAAA==.',['小法']='小法:BAAAKgAECgUIBwAAAA==.',['小的']='小的死骑:BAABKgAFFH8IAAIOAAgIvxqLAwBhAgAOAAgIvxqLAwBhAgAAAA==.',['小莎']='小莎曼:BAAAKgAFFAMIAwAAAA==.',['巴掌']='巴掌依旧:BAACKgAFFH8dAAIPAAMI6CD+DAALAQAPAAMI6CD+DAALAQAqAAQKfzoAAg8ACAgVI1YGAL8CAA8ACAgVI1YGAL8CAAAA.',['怪脸']='怪脸灵姝:BAAAKgAECgcIEQABKgAFFAgIFQALAGkiAA==.',['我叫']='我叫吕春鹏:BAAAKgAFFAgIBAAAAA==.',['我听']='我听说很简单:BAAAKgADCggICAAAAA==.',['明日']='明日花:BAABKgAECn8gAAIGAAgIKhYwKADcAQAGAAgIKhYwKADcAQAAAA==.',['星河']='星河:BAAAKgAECggICAAAAA==.',['朔一']='朔一朔:BAAAKgAECgcICgAAAA==.',['枫花']='枫花恋:BAAAKgAFFAQIBAAAAA==.',['柒月']='柒月予你:BAAAKgADCgcIBwAAAA==.',['树法']='树法:BAAAKgAECgYIBgABKgAFFAgIFQAGAK4kAA==.',['桥本']='桥本忧菜:BAAAKgAECgcICgAAAA==.',['河北']='河北菜花:BAABKgAFFH8XAAMQAAYIDBN1DQB5AQAQAAYIDBN1DQB5AQARAAEIDAnZGwBBAAAAAA==.',['浅忆']='浅忆丶微微凉:BAAAKgADCgEIAQAAAA==.浅忆灬微凉:BAAAKgADCgEIAQAAAA==.',['浇花']='浇花:BAAAKgAECggIEgAAAA==.',['清玖']='清玖:BAABKgAFFH8KAAIKAAYI1RtyGQCTAQAKAAYI1RtyGQCTAQAAAA==.',['潇灑']='潇灑灬牛坏坏:BAAAKgAECggIDwAAAA==.',['烟花']='烟花丶已凉:BAAAKgAECgEIAQAAAA==.',['狂暴']='狂暴趴趴熊:BAABKgAFFH8FAAICAAIIeQwgGQB2AAACAAIIeQwgGQB2AAAAAA==.',['白洲']='白洲梓:BAABKgAFFH8HAAIMAAQIzA4OMwC0AAAMAAQIzA4OMwC0AAABKgAFFAgIWAABANkmAA==.',['相泽']='相泽南:BAAAKgAECgYICgAAAA==.',['瞧你']='瞧你那儿:BAAAKgADCgQIBAAAAA==.',['神棍']='神棍徳:BAAAKgAECggIEwAAAA==.',['稀有']='稀有术术:BAAAKgAECgQIBQAAAA==.',['米苏']='米苏:BAAAKgAFFAQIBAAAAA==.',['红辣']='红辣椒公主:BAAAKgADCggIEAAAAA==.',['绯夜']='绯夜丶:BAABKgAFFH8FAAMSAAQIYBfbHACXAAASAAMIIBnbHACXAAAPAAEIbgaqHgBBAAAAAA==.',['缄默']='缄默:BAAAKgADCgYIBgAAAA==.',['群正']='群正的骑士:BAABKgAFFH8pAAMKAAgI3SCDAgDCAgAKAAgI7B+DAgDCAgANAAgIAxqdAgA3AgAAAA==.',['胖子']='胖子小卷毛:BAAAKgAFFAEIAQAAAA==.',['落花']='落花伊人:BAAAKgADCgEIAQAAAA==.',['虹丕']='虹丕兽:BAAAKgAECggIEAAAAA==.',['裸宾']='裸宾汉:BAAAKgADCgQIBAAAAA==.',['西红']='西红柿炒番茄:BAAAKgAFFAQIBAAAAA==.',['贁傢']='贁傢尐娘孒:BAAAKgAFFAMIAwAAAA==.',['踹你']='踹你裆:BAAAKgAECgQIBAAAAA==.',['这是']='这是个啥:BAAAKgAECgcICAAAAA==.',['那啥']='那啥遭雷劈:BAABKgAECn8UAAIGAAgIRhMeLADIAQAGAAgIRhMeLADIAQAAAA==.',['野德']='野德:BAAAKgAECgUIBgAAAA==.',['陈丶']='陈丶风暴烈酒:BAAAKgAFFAQIBAAAAA==.',['限量']='限量法神:BAAAKgAECggIDgAAAA==.',['霜之']='霜之颾伤:BAABKgAFFH8GAAIOAAMIehN+LwDSAAAOAAMIehN+LwDSAAAAAA==.',['风骚']='风骚的小燕子:BAABKgAECn8aAAIQAAgIshtgEwA+AgAQAAgIshtgEwA+AgAAAA==.',['麦卡']='麦卡车间主任:BAAAKgAFFAgIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end