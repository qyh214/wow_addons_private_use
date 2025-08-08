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
 local lookup = {'Hunter-Marksmanship','Rogue-Outlaw','Rogue-Assassination','Warlock-Destruction','Paladin-Retribution','DeathKnight-Unholy','Shaman-Restoration','Monk-Windwalker','Monk-Brewmaster','Monk-Mistweaver','Hunter-BeastMastery','Shaman-Elemental','Warlock-Demonology','Druid-Balance','Druid-Guardian','Mage-Frost','Mage-Arcane','Mage-Fire','Priest-Holy','Druid-Restoration','Priest-Discipline','Priest-Shadow','Hunter-Survival','Warlock-Affliction',}; local provider = {region='CN',realm='沃金',name='CN',type='weekly',zone=42,date='2025-08-08',data={Fe='Fendi:BAACKgAFFH8MAAIBAAMILQ5hMgCnAAABAAMILQ5hMgCnAAAqAAQKfxYAAgEACAiNGjA/ACgBAAEACAiNGjA/ACgBAAAA.',Ho='Holyhoof:BAAAKgAFFAQIBAAAAA==.',Hu='Huruka:BAAAKgAFFAIIAgAAAA==.',In='Inabakazuki:BAAAKgAECggICgAAAA==.',Lo='Loganc:BAAAKgAECgcIEAAAAA==.',Sa='Sasuke:BAAAKgAECggICQAAAA==.',['一个']='一个老干葱:BAAAKgAFFAQIBAAAAA==.',['下班']='下班健将:BAAAKgAECgQICAAAAA==.',['两手']='两手揣兜:BAABKgAFFH8QAAMCAAYI1ghCAwDxAAADAAUIPgXqCgD9AAACAAQIzAlCAwDxAAAAAA==.',['丨单']='丨单手射箭:BAAAKgAECggICwAAAA==.',['丨武']='丨武丶胜丨:BAAAKgADCggICAAAAA==.',['丶幽']='丶幽灵怒:BAABKgAFFH8IAAIEAAgIfw8uBwD3AQAEAAgIfw8uBwD3AQAAAA==.',['主是']='主是硬:BAABKgAECn8cAAIFAAgI1Bw6LgBHAgAFAAgI1Bw6LgBHAgAAAA==.',['优库']='优库里伍德:BAABKgAECn8UAAIGAAgIpBfWJAD2AQAGAAgIpBfWJAD2AQAAAA==.',['你为']='你为何要追我:BAAAKgAECgcIBwAAAA==.',['你的']='你的盐我的醋:BAAAKgAECgEIAQAAAA==.',['倩宝']='倩宝儿:BAAAKgAECgEIAQAAAA==.',['凯恩']='凯恩丶血啼:BAAAKgAECgEIAQAAAA==.',['到不']='到不了八十:BAACKgAFFH8nAAIHAAYIVhfhCQBrAQAHAAYIVhfhCQBrAQAqAAQKfz4AAgcACAheIZYTAF8CAAcACAheIZYTAF8CAAAA.',['剑梦']='剑梦残阳:BAABKgAECn8oAAQIAAgIWxzcFwDnAQAIAAgItBncFwDnAQAJAAgIORWXCQC0AQAKAAEItQF7bwARAAAAAA==.',['包谷']='包谷地蒙面人:BAAAKgAFFAYIBAAAAA==.',['哥出']='哥出门不带钱:BAAAKgAECggICAAAAA==.',['嘟嘟']='嘟嘟不哭:BAAAKgAECgQIBAAAAA==.',['圣白']='圣白莲:BAABKgAFFH8GAAIKAAYI0RS5DgA9AQAKAAYI0RS5DgA9AQAAAA==.',['地狱']='地狱弑魂:BAAAKgAFFAMIAwAAAA==.',['墨攻']='墨攻:BAAAKgADCgUIBQAAAA==.',['墨白']='墨白:BAABKgAFFH8IAAIFAAMIRhVFSwDYAAAFAAMIRhVFSwDYAAAAAA==.',['大贝']='大贝勒:BAAAKgAFFAMIAwAAAA==.',['天琊']='天琊徐馨:BAAAKgADCgcIBwAAAA==.',['奶的']='奶的奶的:BAAAKgAECgUIBQAAAA==.',['奶里']='奶里下了毒:BAABKgAECn8UAAIHAAgIDRwCJADzAQAHAAgIDRwCJADzAQAAAA==.',['宇宙']='宇宙飞床:BAAAKgAFFAgIBAAAAA==.',['屈黑']='屈黑:BAABKgAFFH8HAAILAAMIABMTMADLAAALAAMIABMTMADLAAAAAA==.',['帅的']='帅的被人砍:BAAAKgAECgMIAwAAAA==.',['彂彂']='彂彂发:BAAAKgAECgQIBAAAAA==.',['彤彤']='彤彤大宝:BAAAKgAECgIIAgAAAA==.',['御坂']='御坂美零:BAABKgAECn8VAAMMAAgIcBY0HwDQAQAMAAgIcBY0HwDQAQAHAAYIkhwFOQCRAQAAAA==.',['德奶']='德奶尼大姐:BAAAKgADCgMIAwAAAA==.',['忧郁']='忧郁迷妹眼神:BAAAKgAFFAQIBAAAAA==.',['成长']='成长生命幸福:BAAAKgAECgcIDAAAAA==.',['戴佳']='戴佳伟菜比:BAACKgAFFH8bAAMNAAcIqxB0BgDdAAANAAQIqBV0BgDdAAAEAAUIWA3/KgDBAAAqAAQKfxoAAw0ACAiyGoQUAN8BAA0ACAhCGYQUAN8BAAQAAQg+H0x6AFkAAAAA.',['房奇']='房奇:BAAAKgAECgIIAgAAAA==.',['挨打']='挨打就还手:BAAAKgADCgIIAgAAAA==.',['撸啊']='撸啊撸的撸:BAAAKgAECgYIBgAAAA==.',['日不']='日不落:BAABKgAECn8hAAMOAAgInx3rOADUAQAOAAcIOSHrOADUAQAPAAEIBwjRNQAeAAAAAA==.',['时木']='时木之枯:BAAAKgAECgMIBAAAAA==.',['星伽']='星伽白雪:BAABKgAECn8gAAQQAAgIex+5DgBaAgAQAAgI5R65DgBaAgARAAgIixeSIwDbAQASAAEIAQUfTQAmAAAAAA==.',['暗电']='暗电:BAAAKgADCggICAAAAA==.',['最近']='最近肉涨了:BAAAKgADCgYIBgAAAA==.',['東丶']='東丶方:BAAAKgADCggICAAAAA==.',['枫晓']='枫晓枫华:BAAAKgADCggIDAAAAA==.',['欷寒']='欷寒:BAABKgAECn8fAAITAAgICCU7DABvAgATAAgICCU7DABvAgABKgAECggIGwALANsjAA==.',['泽村']='泽村:BAAAKgAECggIAwAAAA==.',['灵魂']='灵魂行者灵角:BAAAKgADCggIEAAAAA==.',['炼天']='炼天魔尊:BAAAKgAECgYIBwAAAA==.',['烈龙']='烈龙咯:BAAAKgADCggICAAAAA==.',['爬上']='爬上奶德:BAAAKgADCggICAAAAA==.',['牛掰']='牛掰:BAABKgAFFH8KAAMOAAMIUQcjQgCkAAAOAAMIUQcjQgCkAAAUAAMI3Q6wIwCXAAAAAA==.',['独孤']='独孤龍:BAAAKgAECgEIAQAAAA==.独孤龙:BAAAKgAECgMIAwAAAA==.',['猫瓜']='猫瓜皮:BAAAKgAECggICQAAAA==.',['电击']='电击杨永信:BAAAKgADCgMIAwAAAA==.',['百灵']='百灵:BAAAKgAFFAMIBAAAAA==.',['秋月']='秋月爱莉:BAACKgAFFH8JAAMTAAYILx7fEwAUAQAVAAQIixZhEAAfAQATAAUIFR3fEwAUAQAqAAQKfxsABBYACAi+EWEjALoBABYACAi+EWEjALoBABUABggNFU5LAOcAABMABAhnCy+GAFMAAAAA.秋月真理奈:BAAAKgAECggIDQAAAA==.',['苞谷']='苞谷地蒙面人:BAAAKgADCgIIAgAAAA==.',['豆豆']='豆豆:BAABKgAFFH8MAAMEAAgI6gfbCQC6AQAEAAgI6gfbCQC6AQANAAQI6wG3HQBsAAAAAA==.',['贝勒']='贝勒法爷:BAAAKgADCgYIBgAAAA==.',['赣爆']='赣爆:BAAAKgADCggICAAAAA==.',['这货']='这货真丑:BAAAKgADCgMIAwAAAA==.',['邪恶']='邪恶马铃薯:BAAAKgAECgIIAgAAAA==.',['野马']='野马不羁:BAACKgAFFH8oAAQBAAUI/RKbEQDjAAABAAUI5hGbEQDjAAAXAAII2xNhAgCeAAALAAII8ANgYQAzAAAqAAQKfysABBcACAgvHJMFABYCABcACAieGpMFABYCAAEACAh4GTIiAPABAAsABAgOD3+DAM8AAAAA.',['闫臭']='闫臭臭:BAAAKgAFFAIIAgAAAA==.',['阿丶']='阿丶树:BAAAKgADCggICQAAAA==.',['雪之']='雪之下雪乃:BAACKgAFFH8GAAIEAAYIThlvFgBQAQAEAAYIThlvFgBQAQAqAAQKfxQABA0ACAhCHY4LAEACAA0ACAgMHI4LAEACAAQABAgtHdRDAPwAABgAAghmD101AFoAAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end