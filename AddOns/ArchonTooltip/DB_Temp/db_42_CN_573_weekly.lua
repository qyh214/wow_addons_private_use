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
 local lookup = {'Mage-Arcane','Warlock-Affliction','Warlock-Demonology','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','Priest-Discipline','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection','Warrior-Fury','Warlock-Destruction','Warrior-Arms','Priest-Holy','Druid-Restoration','Druid-Balance','Mage-Frost','Hunter-Marksmanship','Druid-Feral','Rogue-Assassination','Druid-Guardian','Paladin-Protection','Monk-Mistweaver','Monk-Windwalker','Rogue-Subtlety','Mage-Fire','Evoker-Devastation','Monk-Brewmaster','Paladin-Holy','DeathKnight-Frost','Evoker-Preservation',}; local provider = {region='CN',realm='伊萨里奥斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aalexsusan:BAABKgAFFH8GAAIBAAYI6Q2+DAB+AQABAAYI6Q2+DAB+AQAAAA==.',Al='Alexsusan:BAABKgAFFH8GAAMCAAYI3RdvAAB9AQACAAQIAR1vAAB9AQADAAIISgPBGABKAAABKgAFFAgIAgAEAAAAAA==.Alxx:BAAAKgAECgcICAAAAA==.',Au='Aubameyang:BAAAKgAFFAQIBAAAAA==.',Be='Bertys:BAAAKgAFFAQIAwAAAA==.',Cl='Clairebarbie:BAAAKgAFFAQIBAAAAA==.',Cu='Cuboi:BAAAKgAECgEIAQAAAA==.',Da='Dantsty:BAABKgAFFH8LAAMFAAYInwjKFwAiAQAFAAYInwjKFwAiAQAGAAQIeh0QEwDRAAABKgAFFAgIDwAHAC4bAA==.',De='Deathknight:BAAAKgAECgMIBAAAAA==.Decembers:BAAAKgADCgQIBAAAAA==.',Dr='Drya:BAAAKgAFFAIIAgAAAA==.',Du='Dusturballs:BAAAKgADCggIDAAAAA==.',Em='Emls:BAAAKgAECgIIAgAAAA==.',Fo='Fofo:BAAAKgAFFAYIBAAAAA==.Follownature:BAAAKgAECggICAAAAA==.',Ga='Galaxy:BAABKgAFFH8GAAMIAAYIfA2XDQDuAAAIAAMIFxGXDQDuAAAJAAMIMhMPFwCoAAAAAA==.',He='Hellomrcxy:BAABKgAFFH8FAAMKAAIIuAWoRABrAAAKAAIIuAWoRABrAAALAAEIZQDXJwAaAAAAAA==.',Ho='Houstar:BAAAKgAFFAEIAQAAAA==.',Ic='Ichliebejing:BAAAKgAFFAEIAQABKgAFFAYIIgAMACsaAA==.',Ja='Jayden:BAAAKgADCggICAAAAA==.',Jo='Joycc:BAAAKgAECggICAAAAA==.',Me='Melissa:BAAAKgAFFAIIAgAAAA==.',Mi='Mikihuli:BAAAKgAECgIIAgAAAA==.',My='Mydes:BAABKgAECn8eAAINAAgI4h8KIgCRAgANAAgI4h8KIgCRAgAAAA==.',Pa='Pale:BAAAKgAECgcIBwAAAA==.',Pl='Playermtwvog:BAABKgAFFH8GAAINAAYIOBxvGgCNAQANAAYIOBxvGgCNAQAAAA==.',Re='Rearso:BAAAKgAFFAgIBAAAAA==.',Ro='Roamer:BAAAKgAECgQIBAAAAA==.',Sa='Savina:BAABKgAFFH8GAAIOAAYI1BiCEwB+AQAOAAYI1BiCEwB+AQAAAA==.',Se='Seaofatlas:BAAAKgADCgQIBAAAAA==.',Sh='Shinomia:BAAAKgAECgIIAgAAAA==.',Sq='Squid:BAABKgAFFH8IAAIOAAgI0RH1CgDfAQAOAAgI0RH1CgDfAQAAAA==.',Ss='Ssriverns:BAAAKgAFFAQIBAABKgAFFAgIDgAFABUPAA==.',Th='Theone:BAAAKgAECgYIBgAAAA==.',Ti='Tig:BAAAKgAECggIEAAAAA==.Timetodie:BAACKgAFFH8XAAIPAAYIBQpYGADeAAAPAAYIBQpYGADeAAAqAAQKfxQAAw8ACAj9CQEzAAIBAA8ACAj9CQEzAAIBAA4AAQjrAMPdAAwAAAAA.Timetogo:BAABKgAFFH8KAAIQAAcIkASCDACgAAAQAAcIkASCDACgAAAAAA==.Timetogongfu:BAAAKgAECgIIAgAAAA==.Timetohunt:BAABKgAFFH8HAAILAAMIogQJHQBxAAALAAMIogQJHQBxAAAAAA==.Timetolight:BAAAKgAECgUIBQAAAA==.Timetoshot:BAAAKgADCgMIAwAAAA==.Timetotreat:BAAAKgAECgEIAQAAAA==.Timetowild:BAAAKgAECgIIAgAAAA==.',To='Tomo:BAABKgAFFH8RAAINAAgI7BWjCQApAgANAAgI7BWjCQApAgAAAA==.Tomoa:BAABKgAFFH8YAAIRAAgIxhfABQA3AgARAAgIxhfABQA3AgAAAA==.',Wh='Whiteablum:BAABKgAFFH8GAAISAAYInw3dGAA9AQASAAYInw3dGAA9AQAAAA==.',Ye='Yeoh:BAAAKgAFFAQIBAAAAA==.',Yu='Yukirito:BAACKgAFFH8UAAQRAAYILRnhCQCxAQARAAYILRnhCQCxAQATAAEI0gyQGgBIAAAQAAII0gtdDwAwAAAqAAQKfzgAAxEACAjGHowWAFQCABEACAjGHowWAFQCABAACAiuFT8UAKkBAAAA.',['一副']='一副小熊样:BAAAKgAFFAgIBAAAAA==.一副筱熊样:BAABKgAECn8ZAAMUAAgI5hl0HAD1AQAUAAgI5hl0HAD1AQAJAAIIeQ4gfgBYAAAAAA==.一副魈熊样:BAABKgAFFH8HAAMVAAYIYhrFBQDBAQAVAAYIYhrFBQDBAQAWAAEIAAAhQgAAAAAAAA==.',['一夜']='一夜乄七次狼:BAAAKgADCgMIAwAAAA==.',['一轻']='一轻狂一:BAAAKgAECgMIAwAAAA==.',['一锤']='一锤子交易:BAACKgAFFH8HAAINAAMIgBJUUADPAAANAAMIgBJUUADPAAAqAAQKfzMAAg0ACAi6IIQmAGYCAA0ACAi6IIQmAGYCAAAA.',['七相']='七相大宗师:BAAAKgAECggICgAAAA==.',['万雪']='万雪孤城:BAACKgAFFH8fAAMXAAgIsw+WBgBjAQAXAAgIaw+WBgBjAQABAAQIgRVQFQDUAAAqAAQKfyoAAxcACAjaInMPAIUCABcACAiGInMPAIUCAAEABQgsIFk4AGcBAAAA.',['三分']='三分斋院:BAABKgAFFH8KAAMYAAYIrBNTAwBBAQAYAAUIVhVTAwBBAQAMAAUI6RR+CQA3AQABKgAFFAgIEwAMAOUdAA==.',['三十']='三十五第:BAAAKgAECggIEgAAAA==.',['不安']='不安的虫虫:BAAAKgADCgcIBwAAAA==.',['不小']='不小破:BAAAKgAECggICgAAAA==.',['不知']='不知强不强力:BAACKgAFFH8tAAMFAAgIIyLCAwAwAgAFAAgIIyLCAwAwAgAGAAEI9AP+KQAwAAAqAAQKf0YAAwUACAiBJs0BAPYCAAUACAiBJs0BAPYCAAYABQjRF8NGAAcBAAAA.',['不祥']='不祥之兆:BAAAKgAECgMIAwAAAA==.',['不良']='不良丶复仇:BAAAKgAFFAQIBAAAAA==.不良丶懵智:BAACKgAFFH8MAAIQAAMIFhKHCACEAAAQAAMIFhKHCACEAAAqAAQKfzkAAhAACAgpIBIGAHgCABAACAgpIBIGAHgCAAAA.不良教父:BAABKgAFFH8SAAIQAAQIfReQCQDLAAAQAAQIfReQCQDLAAAAAA==.不良灬教父:BAAAKgAFFAMIAwAAAA==.',['不要']='不要战猎萨啦:BAABKgAFFH8QAAIFAAYIDBdZEQBKAQAFAAYIDBdZEQBKAQAAAA==.',['不鸣']='不鸣鸦山:BAAAKgAFFAIIAgAAAA==.',['且听']='且听烟雨过半:BAAAKgAFFAQIBAAAAA==.',['东岳']='东岳大帝:BAACKgAFFH8VAAIOAAYIXSCdDADGAQAOAAYIXSCdDADGAQAqAAQKfxkAAg4ACAgmHwYtAAECAA4ACAgmHwYtAAECAAAA.',['东方']='东方红推土机:BAAAKgAECgYIBwAAAA==.',['东煌']='东煌太一:BAABKgAFFH8FAAIZAAMIFBDYBgDPAAAZAAMIFBDYBgDPAAAAAA==.',['丨汞']='丨汞丨:BAACKgAFFH8SAAIaAAUImB6cDwBXAQAaAAUImB6cDwBXAQAqAAQKfxoAAhoACAgNH18PADACABoACAgNH18PADACAAAA.',['丨铁']='丨铁丨:BAAAKgAECgUICgAAAA==.',['丨闹']='丨闹灬闹丨:BAAAKgAFFAEIAQAAAA==.',['丶小']='丶小聋人:BAAAKgAECgEIAQAAAA==.',['丶柳']='丶柳如烟:BAAAKgADCgcIBwAAAA==.',['丶洁']='丶洁:BAAAKgAECgYICAAAAA==.',['丶空']='丶空:BAABKgAFFH8IAAINAAMI1AsUWQC/AAANAAMI1AsUWQC/AAAAAA==.',['丶舞']='丶舞:BAAAKgADCgMIAwAAAA==.',['丶风']='丶风舞:BAABKgAECn8WAAMMAAgISRKlSgB/AQAMAAgISRKlSgB/AQAYAAIIgAU+hABCAAAAAA==.',['丶黑']='丶黑:BAABKgAFFH8MAAMMAAMISxNiMQDHAAAMAAMISxNiMQDHAAAYAAIIoArJQwBuAAAAAA==.',['丸子']='丸子跳跳:BAACKgAFFH8LAAINAAUIUxXyOQAFAQANAAUIUxXyOQAFAQAqAAQKfyUAAg0ACAhQHbwbAOIBAA0ACAhQHbwbAOIBAAAA.',['乄潇']='乄潇潇:BAABKgAECn8gAAIbAAgIRA0JFgD7AAAbAAgIRA0JFgD7AAAAAA==.',['么么']='么么奶:BAAAKgAECgEIAQAAAA==.',['乔峰']='乔峰:BAAAKgADCgIIAgAAAA==.',['九大']='九大王:BAABKgAFFH8HAAIPAAMI9AHWMABIAAAPAAMI9AHWMABIAAAAAA==.',['九领']='九领主:BAAAKgAECgIIAgAAAA==.',['云雨']='云雨巫山断肠:BAAAKgAFFAQIBAAAAA==.',['今晚']='今晚沦陷:BAAAKgAECgQIBAAAAA==.',['代号']='代号零四七:BAABKgAFFH8GAAIaAAYIYBogDACLAQAaAAYIYBogDACLAQAAAA==.',['伊卡']='伊卡洛斯:BAAAKgAECggICAAAAA==.',['伯言']='伯言先生:BAAAKgADCggICwAAAA==.',['何类']='何类类:BAAAKgAFFAIIAgAAAA==.',['佚之']='佚之小熊:BAAAKgAECggIEQAAAA==.',['你个']='你个逗神:BAAAKgAFFAgIBAAAAA==.',['做賊']='做賊心虛:BAAAKgAECgEIAQAAAA==.',['停止']='停止吃药:BAACKgAFFH8eAAMCAAgIxw3ZAwBQAQACAAgIxw3ZAwBQAQASAAIIVQTxJgBzAAAqAAQKfxQAAwIACAiIGrMdAAIBAAIABAgGG7MdAAIBABIABQjWF21aAAIBAAAA.',['健美']='健美家克里斯:BAAAKgAECgMIBAABKgAFFAUIJgAaAFseAA==.',['傻女']='傻女人:BAAAKgADCgIIAgAAAA==.',['光铸']='光铸蛋壳:BAABKgAFFH8OAAMcAAYIzRKqBwDmAAANAAYIchGiKwA5AQAcAAQIfB2qBwDmAAAAAA==.',['克里']='克里斯提法:BAABKgAFFH8GAAIPAAYIRBDVEQAUAQAPAAYIRBDVEQAUAQAAAA==.',['八倍']='八倍镜:BAACKgAFFH8fAAINAAQI5iGwMgAeAQANAAQI5iGwMgAeAQAqAAQKfygAAg0ACAgMJa8TAMgCAA0ACAgMJa8TAMgCAAAA.',['八分']='八分之一巨人:BAABKgAFFH8GAAIKAAYIwxRPEQB3AQAKAAYIwxRPEQB3AQAAAA==.',['公子']='公子素:BAABKgAECn8WAAINAAgI+BiVRQDwAQANAAgI+BiVRQDwAQAAAA==.',['兮夜']='兮夜心凉:BAAAKgAECgcIEwAAAA==.',['关服']='关服纪念:BAAAKgAFFAgIAgAAAA==.',['养宠']='养宠物的棒子:BAAAKgAECgQIBAAAAA==.',['冥界']='冥界看门人:BAAAKgAECggIDQAAAA==.',['冰河']='冰河水寒:BAACKgAFFH8OAAIdAAgIWxByBgCrAQAdAAgIWxByBgCrAQAqAAQKfxYAAx4ABwgbGV0KAMcBAB4ABwgbGV0KAMcBAB0ABwi0BudJAJgAAAAA.',['冰雨']='冰雨时代:BAAAKgADCggICAAAAA==.',['冰麒']='冰麒麟奶茶:BAAAKgAECgIIAgAAAA==.',['减伤']='减伤要开阿:BAABKgAFFH8UAAQUAAYI0xfZDQDNAAAJAAQIGw6NEwD8AAAUAAQIIBbZDQDNAAAIAAEIVwu6JQBIAAABKgAFFAgIHwAIAAoWAA==.',['凯而']='凯而:BAAAKgAECgEIAQAAAA==.',['初秋']='初秋夏末:BAAAKgAFFAQIBAAAAA==.',['刪除']='刪除丶鴉:BAAAKgAECgYICgAAAA==.',['刹那']='刹那丶奥义:BAAAKgAECgcICQAAAA==.刹那丶梦:BAAAKgAECgIIAgAAAA==.',['副将']='副将马国成:BAAAKgAECgQIBAAAAA==.',['加雷']='加雷斯:BAAAKgAECgIIAgAAAA==.',['努力']='努力堆力量:BAAAKgAECgUIBQAAAA==.',['勇闯']='勇闯女生宿舍:BAAAKgAECgIIAgAAAA==.',['北风']='北风暖春:BAAAKgAECggIDwAAAA==.',['医学']='医学家陈二迅:BAABKgAFFH8mAAMaAAUIWx5uDACFAQAaAAUIWx5uDACFAQAfAAIIrBAIDQCVAAAAAA==.',['十一']='十一名:BAAAKgAECgIIAwAAAA==.',['十月']='十月的肖邦:BAACKgAFFH8NAAMgAAQIDCAwFQD6AAAgAAQI+hYwFQD6AAAXAAMIChw+CAD5AAAqAAQKfx8AAhcACAj3IhERAD4CABcACAj3IhERAD4CAAAA.',['千月']='千月之辉:BAAAKgAECgEIAQAAAA==.',['千纸']='千纸樱:BAAAKgAFFAQIBAAAAA==.',['半血']='半血:BAAAKgAFFAIIAgAAAA==.',['卓文']='卓文飘丶:BAAAKgAECgUIBgAAAA==.',['厂长']='厂长:BAAAKgAFFAQIBAAAAA==.',['厉倾']='厉倾城:BAAAKgAECggICwAAAA==.',['叫我']='叫我烧卖:BAABKgAFFH8JAAIOAAUIERj8GwA+AQAOAAUIERj8GwA+AQAAAA==.',['史蒂']='史蒂芬丶:BAAAKgAECggICwAAAA==.',['后知']='后知后觉六:BAAAKgADCggICwAAAA==.',['吴佩']='吴佩慈:BAAAKgADCgEIAQAAAA==.',['告辞']='告辞:BAAAKgAFFAYIAgABKgAFFAgIBQACAI8dAA==.',['和风']='和风之弦:BAAAKgAECggIEwAAAA==.',['咏妤']='咏妤:BAABKgAFFH8IAAIWAAgIvg0mDQDEAQAWAAgIvg0mDQDEAQAAAA==.',['咔嚓']='咔嚓咔嚓库库:BAAAKgAECgYICAAAAA==.',['哈死']='哈死你个碎松:BAAAKgAECgYICQAAAA==.',['哎择']='哎择邋蟖:BAABKgAECn8YAAIhAAgIdhlkGQDtAQAhAAgIdhlkGQDtAQAAAA==.',['唤潮']='唤潮者阿达:BAAAKgAFFAQIBAAAAA==.',['唸尧']='唸尧之淚仭:BAAAKgADCgcIBwAAAA==.',['唸希']='唸希之淚仭:BAAAKgAECgQIBAAAAA==.',['唸芷']='唸芷之淚仭:BAAAKgADCggICAAAAA==.',['唸雨']='唸雨之淚仭:BAAAKgADCgMIAwAAAA==.',['善解']='善解:BAAAKgAECgMIAwAAAA==.',['囍龘']='囍龘龘:BAAAKgAECgQIBAAAAA==.',['回头']='回头無岸:BAACKgAFFH8IAAIMAAQI4wr4PQCmAAAMAAQI4wr4PQCmAAAqAAQKfykAAwwACAghHkAzACgCAAwACAg8HUAzACgCABgABAhgEx9sALEAAAAA.',['囡丶']='囡丶囡:BAAAKgAECggICgAAAA==.',['图图']='图图大耳朵:BAAAKgAECgIIAgAAAA==.',['圈圈']='圈圈丿:BAACKgAFFH8PAAIXAAMICBQqFADGAAAXAAMICBQqFADGAAAqAAQKfxYAAxcACAhGHHATACQCABcACAj7G3ATACQCAAEABQgbEGwfACcBAAAA.',['圣光']='圣光哥哥:BAAAKgAECgMIAwAAAA==.',['圣多']='圣多明我:BAABKgAFFH8GAAIMAAYIcRARFgBGAQAMAAYIcRARFgBGAQAAAA==.',['圣歌']='圣歌:BAAAKgAFFAQIBAAAAA==.',['坚强']='坚强的小虾米:BAAAKgAECgUIAwAAAA==.',['坚持']='坚持练满级:BAAAKgADCgIIAgAAAA==.',['塞纳']='塞纳瘤斯哇咔:BAAAKgAFFAQIBAABKgAFFAgIEQAVAD4jAA==.',['墙外']='墙外闻花香:BAACKgAFFH8ZAAIYAAQIRhzHEwDIAAAYAAQIRhzHEwDIAAAqAAQKfy4AAxgACAirI5oJALQCABgACAirI5oJALQCAAwAAggsFDeiAH8AAAAA.',['壹副']='壹副小熊样:BAABKgAFFH8IAAIYAAgIIBahBQAHAgAYAAgIIBahBQAHAgAAAA==.',['夏天']='夏天的魔法:BAAAKgAECgIIAgAAAA==.',['夜丶']='夜丶朦胧:BAABKgAECn8UAAIWAAgIbQ9wKgADAQAWAAgIbQ9wKgADAQAAAA==.',['夜德']='夜德潘:BAABKgAFFH8OAAIWAAYI9xvKDwCkAQAWAAYI9xvKDwCkAQAAAA==.',['夜溟']='夜溟:BAAAKgADCgYIBgAAAA==.',['夜猎']='夜猎潘:BAACKgAFFH8SAAIYAAgIKB+pCgCsAQAYAAgIKB+pCgCsAQAqAAQKfxYAAhgACAgRIp0OAGQCABgACAgRIp0OAGQCAAAA.',['夜色']='夜色不黑:BAAAKgAFFAEIAQAAAA==.',['夜轶']='夜轶:BAAAKgAECgUICQAAAA==.',['大丶']='大丶猫:BAABKgAFFH8MAAINAAYI6yDBFwCeAQANAAYI6yDBFwCeAQAAAA==.',['大妈']='大妈也很厉害:BAAAKgAECggICAABKgAFFAgIEwAMAOUdAA==.大妈后是大叔:BAABKgAFFH8GAAITAAYIJBi3BwCTAQATAAYIJBi3BwCTAQAAAA==.',['大宇']='大宇宙:BAAAKgAFFAQIBAAAAA==.',['大福']='大福娃子:BAABKgAFFH8KAAMDAAYIQg9HDwDAAAADAAQIhxNHDwDAAAASAAII2ggdPAB/AAAAAA==.',['大锤']='大锤八十八:BAABKgAFFH8GAAIVAAYIuwhqEwAEAQAVAAYIuwhqEwAEAQAAAA==.',['大领']='大领主棒子:BAACKgAFFH8QAAINAAgIRg+0GAAjAQANAAgIRg+0GAAjAQAqAAQKfyoAAw0ACAi9I74dAIwCAA0ACAi9I74dAIwCABwAAQhkAAAAAAAAAAAA.',['奕德']='奕德:BAACKgAFFH8XAAIdAAMIHRJZEAClAAAdAAMIHRJZEAClAAAqAAQKfzwAAh0ACAgwFDYfAJABAB0ACAgwFDYfAJABAAAA.',['奥利']='奥利弗黑角:BAAAKgAECgYICwAAAA==.',['妖艳']='妖艳异常:BAACKgAFFH8PAAQRAAMIiwgMFgCyAAARAAMINwcMFgCyAAAQAAMIBgQdEgBsAAATAAMIPAYAJQBqAAAqAAQKfxYABBEACAhuEw1XAP4AABEABwggDQ1XAP4AABMABgjBElhAALIAABAAAwiUBaBHADoAAAAA.',['妙僧']='妙僧无花:BAACKgAFFH8GAAITAAYIcwyfDABEAQATAAYIcwyfDABEAQAqAAQKfxoAAhMACAh7EJQgAIABABMACAh7EJQgAIABAAAA.',['安妮']='安妮鲍利:BAAAKgADCgIIAgAAAA==.',['安娜']='安娜与狼:BAAAKgAECggICAAAAA==.',['安安']='安安不摸低保:BAABKgAFFH8MAAMYAAYILxx+EABiAQAYAAYILxx+EABiAQAMAAYInAviGgApAQAAAA==.',['宿醉']='宿醉女皇:BAACKgAFFH8IAAIGAAMINA4dGAC3AAAGAAMINA4dGAC3AAAqAAQKfxoABAYACAiqFno+ADIBAAYABwj3GXo+ADIBAAUAAghYD+6nAGgAAAcAAQhDD6leADAAAAAA.',['寒灯']='寒灯独夜人:BAAAKgAECggICAAAAA==.',['寒风']='寒风重生:BAAAKgAECgEIAQAAAA==.',['射射']='射射死你:BAACKgAFFH8gAAIMAAYIWxhCEwBcAQAMAAYIWxhCEwBcAQAqAAQKfzMAAgwACAg/I5gUAIcCAAwACAg/I5gUAIcCAAAA.',['射的']='射的漂亮:BAABKgAFFH8HAAIMAAMIBCCZHgAUAQAMAAMIBCCZHgAUAQAAAA==.',['小元']='小元素:BAAAKgAECgIIAgAAAA==.',['小册']='小册佬:BAAAKgAECggICAAAAA==.',['小北']='小北:BAABKgAFFH8KAAMOAAYINSKDDQC6AQAOAAYINSKDDQC6AQAPAAQIEAhAKQBxAAAAAA==.',['小法']='小法尸:BAAAKgAFFAIIAgAAAA==.',['小米']='小米丿风:BAAAKgAECgYIAQAAAA==.',['小面']='小面包丶:BAAAKgADCgMIAwAAAA==.',['尛尛']='尛尛园:BAAAKgAECggIDwAAAA==.',['尤蒂']='尤蒂安:BAABKgAFFH8GAAIKAAMIWgmTNQCqAAAKAAMIWgmTNQCqAAAAAA==.',['尹娜']='尹娜:BAABKgAECn8bAAMiAAgIswtjEgABAQAiAAgIKAtjEgABAQAeAAcIZQTqSwDRAAAAAA==.',['尾巴']='尾巴比较帅:BAAAKgADCggIDgAAAA==.',['左肩']='左肩有你:BAAAKgAECgYICwAAAA==.',['布鲁']='布鲁斯壳:BAABKgAFFH8GAAIdAAYIBBW0DgA9AQAdAAYIBBW0DgA9AQAAAA==.',['帅哥']='帅哥做保健吗:BAABKgAFFH8JAAQWAAgIAhOlEQCRAQAWAAYIgRqlEQCRAQAVAAIIfxYkIgCfAAAZAAEIDBBPCABRAAAAAA==.',['帅气']='帅气唐哒哒:BAABKgAFFH8QAAQXAAYIFyJwAgDzAQAXAAYIFyJwAgDzAQAgAAYImxaLBAC/AQABAAIIpwPlOwBxAAAAAA==.',['帅熊']='帅熊猫:BAABKgAECn8aAAIdAAgI8A9dPgBJAQAdAAgI8A9dPgBJAQAAAA==.',['师太']='师太从了老衲:BAABKgAECn8bAAIRAAgIjBoTFwAcAgARAAgIjBoTFwAcAgAAAA==.',['希尔']='希尔瓦萨斯:BAAAKgAECgYICgAAAA==.',['希澈']='希澈二岚:BAAAKgADCgQIBwAAAA==.',['帕斯']='帕斯皮拉:BAAAKgAECggICQAAAA==.',['帕秋']='帕秋莉:BAAAKgAFFAMIBAAAAA==.',['幽灵']='幽灵公主:BAACKgAFFH8NAAIKAAQI3RGhHACtAAAKAAQI3RGhHACtAAAqAAQKfyUAAgoACAhvGCE4AHQBAAoACAhvGCE4AHQBAAAA.',['弗塔']='弗塔根:BAAAKgAECgEIAQAAAA==.',['彡幽']='彡幽影彡:BAAAKgADCggICAAAAA==.',['彦祖']='彦祖没我一半:BAABKgAFFH8WAAIRAAUI9xROEgA1AQARAAUI9xROEgA1AQAAAA==.',['彼方']='彼方归来:BAAAKgADCgIIAgAAAA==.',['微笑']='微笑的狄丽莎:BAABKgAFFH8GAAIBAAYIMRQ4EwBLAQABAAYIMRQ4EwBLAQABKgAFFAgIEAAgAKcaAA==.',['德拉']='德拉古:BAABKgAFFH8HAAMNAAQIGB5+DgAaAQANAAMIGB5+DgAaAQAjAAQIGxdSBwDdAAAAAA==.',['德逼']='德逼闪放光芒:BAABKgAFFH8GAAINAAYIzBlqFgCoAQANAAYIzBlqFgCoAQAAAA==.',['快乐']='快乐的小钢炮:BAAAKgADCgEIAQAAAA==.',['忽闪']='忽闪:BAAAKgADCgQIBAAAAA==.',['怒从']='怒从心头起:BAAAKgAECgYIBgAAAA==.',['恋一']='恋一世:BAAAKgAECgQIBAAAAA==.',['恋之']='恋之龙:BAABKgAFFH8GAAIUAAMIiAYrGQB3AAAUAAMIiAYrGQB3AAAAAA==.',['恶魔']='恶魔王邪神:BAABKgAFFH8KAAMDAAcIFBLvCADyAAADAAYIyBTvCADyAAACAAEIkgR3IgBDAAAAAA==.',['愤怒']='愤怒的杏鲍菇:BAABKgAFFH8IAAIXAAgI9BZoAQA2AgAXAAgI9BZoAQA2AgAAAA==.',['慕丨']='慕丨涂涂:BAAAKgAECgQIBAAAAA==.',['我是']='我是个卧底:BAABKgAFFH8GAAIaAAYI2w5LDwBdAQAaAAYI2w5LDwBdAQAAAA==.',['我没']='我没有疯:BAABKgAFFH8SAAMVAAgIyBR/DgAtAQAVAAgIyBR/DgAtAQAWAAQIUiHzEwDrAAAAAA==.',['战渣']='战渣:BAABKgAFFH8GAAMRAAMIdBMyLACQAAARAAIIuhEyLACQAAATAAEI6Ba1FwBVAAAAAA==.',['战狼']='战狼中队长:BAABKgAECn8XAAINAAgI2h/UKwBvAgANAAgI2h/UKwBvAgAAAA==.',['戴娜']='戴娜碧桑:BAABKgAECn8aAAIXAAgIshWMIQCmAQAXAAgIshWMIQCmAQAAAA==.',['手拿']='手拿把掐:BAAAKgADCggICQAAAA==.',['扑棱']='扑棱蛾子:BAABKgAFFH8XAAIhAAQIMhToEgDcAAAhAAQIMhToEgDcAAABKgAFFAYIGwANAGYcAA==.',['折翼']='折翼灬天使:BAACKgAFFH8OAAMMAAMIQhNwKQCqAAAMAAIImxpwKQCqAAAYAAMIwAh3QQB1AAAqAAQKfz0AAwwACAhzIv0dAH8CAAwACAhzIv0dAH8CABgABwgaGIU8ADUBAAAA.',['折耳']='折耳猫:BAABKgAFFH8GAAIQAAYIzQ20BgADAQAQAAYIzQ20BgADAQAAAA==.',['拓跋']='拓跋衅:BAAAKgAFFAQIBAAAAA==.',['捂脸']='捂脸小跑:BAAAKgAECgcICgAAAA==.',['提里']='提里奥佛丁:BAAAKgAFFAQIBAAAAA==.',['援護']='援護你的忧傷:BAAAKgAECgMIAwAAAA==.',['放弃']='放弃治疗:BAACKgAFFH8vAAMUAAgIniW4AgBCAgAUAAcIZCW4AgBCAgAJAAQI+SU/BABUAQAqAAQKfx8AAwkACAgzJmICAOwCAAkACAgRJWICAOwCABQACAhRJXQzAHMBAAAA.',['放肆']='放肆枫轩:BAAAKgADCgMIAwAAAA==.',['救世']='救世主老贼:BAABKgAECn8VAAINAAgIGxbcWQCwAQANAAgIGxbcWQCwAQAAAA==.',['敖闰']='敖闰:BAAAKgADCgQIBAAAAA==.',['敷衍']='敷衍堕落的伢:BAAAKgAECgYIBgAAAA==.敷衍堕落的心:BAAAKgAECgMIAwAAAA==.敷衍堕落的邪:BAAAKgAECggICAAAAA==.',['斐济']='斐济:BAACKgAFFH8ZAAINAAgIORxvDwDmAQANAAgIORxvDwDmAQAqAAQKfzIAAw0ACAgHJZoVALICAA0ACAgHJZoVALICABwABAgcB+hKAFIAAAAA.',['斯文']='斯文姐:BAAAKgAECggIDAAAAA==.',['旋转']='旋转跳跃:BAABKgAECn8UAAMVAAgIARB/LQBxAQAVAAgIARB/LQBxAQAWAAYI2RAsaQAhAQAAAA==.',['无事']='无事不从容:BAAAKgADCggIEAAAAA==.',['无意']='无意义:BAAAKgAECgIIAgAAAA==.无意外:BAAAKgAECgIIAQAAAA==.',['无术']='无术无皇:BAAAKgAFFAQIAQAAAA==.',['旧情']='旧情余温:BAAAKgAFFAQIBAAAAA==.',['时之']='时之主雷斯林:BAAAKgAECgIIAgAAAA==.',['昆山']='昆山夜光:BAABKgAECn8ZAAMdAAgIixDSOQBeAQAdAAgIixDSOQBeAQAeAAgI9QZZPQAeAQAAAA==.',['昊天']='昊天大帝:BAABKgAFFH8SAAMTAAYIbhtDBwCeAQATAAYIbhtDBwCeAQARAAIIzxAiHwCYAAAAAA==.昊天帝君:BAAAKgADCgcIBwAAAA==.',['明小']='明小明:BAAAKgAECgMIAwAAAA==.',['星痕']='星痕伊利蛋:BAAAKgAECggICAAAAA==.星痕翼:BAABKgAFFH8RAAIcAAQIoRGmHACVAAAcAAQIoRGmHACVAAAAAA==.',['星空']='星空无宸:BAAAKgAECgMIAwAAAA==.',['星衍']='星衍:BAAAKgADCgQIBAAAAA==.',['星辰']='星辰灬怒:BAABKgAECn8WAAMMAAgIOxmANQDPAQAMAAcIAxmANQDPAQAYAAYI0A0tUwDQAAAAAA==.星辰灬泪:BAAAKgAFFAEIAQAAAA==.',['春日']='春日阳光:BAAAKgAECgYICgAAAA==.',['晓晨']='晓晨:BAAAKgAECgEIAQAAAA==.',['普渡']='普渡众牲:BAACKgAFFH8dAAINAAUIoB+/GQCRAQANAAUIoB+/GQCRAQAqAAQKfyQAAg0ACAgtJMgcAKUCAA0ACAgtJMgcAKUCAAAA.普渡終生:BAAAKgAFFAIIAgAAAA==.',['普罗']='普罗德奶爸:BAAAKgAECgEIAQAAAA==.普罗德安杜因:BAAAKgAECgUIBQAAAA==.普罗德郭少:BAAAKgAECgMIBgAAAA==.普罗德郭总:BAAAKgAECgUIBgAAAA==.普罗德郭老板:BAAAKgAECgQIBgAAAA==.普罗德龙少:BAAAKgAECgUIBQAAAA==.',['晴空']='晴空灬晓鑫:BAAAKgADCggICAAAAA==.',['暗伈']='暗伈:BAAAKgAECgYIBwAAAA==.',['暗夜']='暗夜沙:BAAAKgADCgMIBAAAAA==.暗夜航仔仔:BAAAKgAFFAUIBAAAAA==.',['暗桑']='暗桑:BAAAKgAECgYICQAAAA==.',['暴法']='暴法:BAAAKgAFFAMIAwAAAA==.',['曦升']='曦升暮落:BAACKgAFFH8VAAQbAAQI1gvLBABhAAAWAAQIRgeIJwCWAAAbAAQI1gvLBABhAAAVAAIIOgOyOgAtAAAqAAQKfyIABBsACAikEswZANMAABsACAhyEswZANMAABYABwhrC7OEAMoAABUABwg0BJhXALEAAAAA.',['最终']='最终幻想彡:BAAAKgAECgMIBwAAAA==.',['月之']='月之灵泣:BAABKgAECn8hAAINAAgItxdIGwDmAQANAAgItxdIGwDmAQAAAA==.',['月影']='月影迷踪:BAAAKgAECgUIBQAAAA==.',['月满']='月满拦江:BAAAKgAECgIIAgAAAA==.',['月野']='月野兔丶:BAAAKgAFFAQIAwAAAA==.',['有尾']='有尾巴的人:BAAAKgAECggICgAAAA==.',['有德']='有德必有失:BAAAKgAFFAQIBAAAAA==.',['未知']='未知:BAAAKgAECgIIAgAAAA==.',['本条']='本条二亚:BAAAKgAECgcIBwAAAA==.',['杀戮']='杀戮之中盛开:BAAAKgAFFAQIBAAAAA==.',['枯叶']='枯叶随疯:BAABKgAFFH8IAAINAAMIfiDaMgAeAQANAAMIfiDaMgAeAQAAAA==.',['枯枼']='枯枼随風:BAACKgAFFH8FAAMBAAMI7gfwHQCUAAABAAMINAfwHQCUAAAgAAII/wlXMgCCAAAqAAQKfxUAAiAACAipFMsuAOQBACAACAipFMsuAOQBAAAA.',['柠檬']='柠檬优格:BAABKgAFFH8IAAIVAAgIhg7NBACqAQAVAAgIhg7NBACqAQAAAA==.',['格格']='格格牧:BAAAKgAECgUIBQAAAA==.',['桀骜']='桀骜斯达瑞:BAAAKgAECgUIBQABKgAFFAgIXwARAMMlAA==.',['桃丶']='桃丶破晓:BAABKgAFFH8GAAIcAAYIDx/PBgCxAQAcAAYIDx/PBgCxAQAAAA==.',['桃羞']='桃羞杏让:BAABKgAFFH8KAAINAAQIexskFwD+AAANAAQIexskFwD+AAAAAA==.',['桜吹']='桜吹雪:BAACKgAFFH8HAAMBAAUIRhPQGQAWAQABAAQIfxLQGQAWAQAgAAIIqw94LwBCAAAqAAQKfzQABCAACAgVHioLACYCACAACAh5HCoLACYCAAEABQguG89EAC0BABcABQh6FWxsAMUAAAAA.',['桶木']='桶木饭叮叮一:BAAAKgAECgcICQAAAA==.桶木饭吃猪排:BAACKgAFFH8HAAMBAAMICBLjJgDHAAABAAMICBLjJgDHAAAXAAIIOAbqHwA/AAAqAAQKfxsABBcACAhpGfM1AJcBABcABwhTGfM1AJcBAAEAAgiAGpRsAJwAACAAAwi7DPOLAGIAAAAA.',['梅塞']='梅塞赫尔斯:BAAAKgAFFAQIAwAAAA==.',['梅林']='梅林:BAAAKgAECgUIBQAAAA==.',['梦歌']='梦歌萨满:BAAAKgAECggICAAAAA==.',['梦里']='梦里回魂:BAAAKgAECgQIBAAAAA==.',['森德']='森德:BAABKgAFFH8GAAIWAAYI8ggDEwAxAQAWAAYI8ggDEwAxAQAAAA==.',['椎名']='椎名真由里:BAABKgAFFH8GAAQJAAYI4A/cDADuAAAJAAQI6RPcDADuAAAUAAEIeQeAPgA/AAAIAAEIqAJYLwA5AAABKgAFFAgICAAUAJoYAA==.',['楼外']='楼外青楼:BAACKgAFFH8WAAIcAAUIqBg5EAADAQAcAAUIqBg5EAADAQAqAAQKfxUAAhwACAirD8UgAE8BABwACAirD8UgAE8BAAAA.',['槑梦']='槑梦烟:BAAAKgAECgIIAwAAAA==.',['橙子']='橙子不是橘子:BAAAKgAFFAQIBAAAAA==.橙子是橘子丶:BAABKgAFFH8GAAIYAAYIYxpaEQBZAQAYAAYIYxpaEQBZAQAAAA==.',['欧皇']='欧皇的不朽:BAABKgAFFH8IAAIOAAgIGwz9BgDmAQAOAAgIGwz9BgDmAQAAAA==.',['欲术']='欲术临鳯:BAAAKgADCggIEgAAAA==.',['此名']='此名已被拉黑:BAAAKgAFFAIIAgAAAA==.',['死丶']='死丶无关血统:BAAAKgAECgQIBAAAAA==.',['死神']='死神灬魑魅:BAABKgAFFH8GAAISAAYIVRXhCwCMAQASAAYIVRXhCwCMAQAAAA==.死神赎罪:BAABKgAFFH8NAAINAAUIkgzpYACuAAANAAUIkgzpYACuAAAAAA==.',['殇法']='殇法:BAAAKgAECgMIAwAAAA==.',['残阳']='残阳破碎:BAAAKgADCgIIAgAAAA==.',['殘陽']='殘陽戀雨:BAAAKgAECgcICwAAAA==.',['毒刃']='毒刃:BAAAKgAECgEIAgAAAA==.',['毒鸦']='毒鸦叁焚:BAABKgAFFH8UAAIOAAgI7BzxAAD7AQAOAAgI7BzxAAD7AQAAAA==.',['毛人']='毛人男贾:BAAAKgADCggIEgAAAA==.',['江城']='江城绝恋:BAACKgAFFH8JAAMDAAMIAAdMHQBuAAASAAMIXgOiPQB3AAADAAIIXQhMHQBuAAAqAAQKfxcAAwMACAieFSgUAAwBAAMABgiaESgUAAwBABIACAghD1BDAP4AAAAA.',['汢杜']='汢杜:BAABKgAFFH8nAAIdAAUIFRWQFwDkAAAdAAUIFRWQFwDkAAAAAA==.',['沉寂']='沉寂的醉熊:BAAAKgADCggICgAAAA==.',['沐沐']='沐沐爸爸:BAAAKgAFFAIIAgAAAA==.',['没得']='没得意思:BAABKgAFFH8iAAQXAAcIliAZAwDVAQAgAAcI6BycBABAAgAXAAYIwSEZAwDVAQABAAQI9iSWFABAAQABKgAFFAgIGgAgAGEfAA==.',['没有']='没有密码猎手:BAACKgAFFH8aAAILAAMIawFGEQBPAAALAAMIawFGEQBPAAAqAAQKfxUAAwoACAj8CRksAOwAAAoACAj8CRksAOwAAAsABQiZAzwlAEAAAAAA.',['泛泛']='泛泛:BAAAKgAECggICwAAAA==.',['泪眼']='泪眼朦胧:BAAAKgAECgYIEAAAAA==.',['泰兰']='泰兰风语者:BAAAKgAECgcIDAAAAA==.',['泰神']='泰神二:BAAAKgADCgMIAwAAAA==.',['流氓']='流氓会污术:BAAAKgADCgQIBAAAAA==.',['流浪']='流浪的帅蜗牛:BAAAKgAFFAMIAwABKgAFFAYIIQAIAIoQAA==.',['流街']='流街浪途:BAAAKgADCgIIAgAAAA==.',['浅夏']='浅夏深兰:BAAAKgAFFAIIAgAAAA==.',['浪漫']='浪漫的枷锁:BAACKgAFFH8FAAIMAAMI/RTfOQCzAAAMAAMI/RTfOQCzAAAqAAQKfxsAAwwACAhtF4UfAH0BAAwABwhgGIUfAH0BABgABghfE7pJACkBAAAA.',['海公']='海公牛:BAABKgAFFH8GAAINAAYIKhbTIwBcAQANAAYIKhbTIwBcAQAAAA==.',['海军']='海军萨满:BAACKgAFFH8NAAIFAAQIsxUMMgCxAAAFAAQIsxUMMgCxAAAqAAQKfyYABAUACAhxHfUgABICAAUACAhxHfUgABICAAYAAwhKBRt6AEkAAAcAAQhaBvxcADcAAAAA.',['海格']='海格里斯:BAAAKgAFFAIIAgAAAA==.',['海燕']='海燕啊:BAAAKgAECggIDQAAAA==.',['深深']='深深巫神:BAAAKgAECgUICQAAAA==.',['深藍']='深藍:BAAAKgAECggICAAAAA==.',['清蒸']='清蒸十一:BAAAKgAECgYIBgAAAA==.',['火令']='火令卫炎丸:BAAAKgAECgYICgAAAA==.',['火力']='火力翻车王:BAABKgAFFH8OAAIhAAYIERxCEABdAQAhAAYIERxCEABdAQAAAA==.',['灰烬']='灰烬之蒼鬼:BAAAKgAECgUIBQAAAA==.',['灰色']='灰色星域:BAABKgAECn8YAAIdAAgI5gwqRAAuAQAdAAgI5gwqRAAuAQAAAA==.',['炸毛']='炸毛的土拨鼠:BAABKgAFFH8GAAIWAAQIewsJPQC0AAAWAAQIewsJPQC0AAAAAA==.',['烈虎']='烈虎長船:BAAAKgAECgcIDgAAAA==.',['無盡']='無盡的华尔兹:BAABKgAFFH8OAAIFAAYIaR88BwDVAQAFAAYIaR88BwDVAQAAAA==.',['熹微']='熹微腓骨:BAAAKgAECgIIBAAAAA==.',['爱美']='爱美的啊:BAAAKgADCgMIBgAAAA==.',['爱蓝']='爱蓝莓酱辰辰:BAABKgAFFH8iAAIMAAYIKxpyDgCNAQAMAAYIKxpyDgCNAQAAAA==.',['牛叉']='牛叉死了:BAAAKgAECgEIAQAAAA==.',['牧云']='牧云兮:BAAAKgAFFAEIAQAAAA==.',['狂乂']='狂乂乂:BAAAKgAFFAIIAgAAAA==.',['猎阳']='猎阳帝君:BAABKgAFFH8gAAMMAAcIvR0BCgDRAQAMAAcIvR0BCgDRAQAYAAQI2xtVDADrAAABKgAFFAgIBgAUAKsLAA==.',['猎魔']='猎魔者星:BAAAKgAECgMIAwAAAA==.',['猛牛']='猛牛佐伊:BAAAKgAECgMIAwAAAA==.',['猜娜']='猜娜:BAAAKgADCgMIAwAAAA==.',['猫南']='猫南北丨:BAAAKgAFFAQIBAAAAA==.',['玄米']='玄米:BAABKgAECn8VAAIFAAgIkyHJDwBwAgAFAAgIkyHJDwBwAgAAAA==.',['玉爪']='玉爪:BAAAKgAFFAQIBAAAAA==.',['王大']='王大花:BAAAKgAECgUIBgAAAA==.',['王缇']='王缇:BAABKgAFFH8MAAMIAAQIyRqvEQDVAAAIAAQIyRqvEQDVAAAUAAIICCZhHQBvAAAAAA==.',['珍珠']='珍珠百香果:BAAAKgAECggICAAAAA==.',['琞光']='琞光舞步:BAABKgAFFH8GAAINAAYIlwTgNAAWAQANAAYIlwTgNAAWAQAAAA==.',['瑶琴']='瑶琴一曲:BAACKgAFFH8JAAINAAMIRxfHIwDZAAANAAMIRxfHIwDZAAAqAAQKfzQAAg0ACAgtIFIrAFICAA0ACAgtIFIrAFICAAAA.',['瓦斯']='瓦斯琪风语:BAAAKgADCgQIBAAAAA==.',['甘露']='甘露润万物:BAACKgAFFH8FAAMDAAMIFAXxFgCRAAADAAMIFAXxFgCRAAASAAEI5wETOgAsAAAqAAQKfxcAAwMACAihEBEkAHUBAAMACAihEBEkAHUBABIABAg1CfCWAF0AAAAA.',['甜皮']='甜皮鸭:BAABKgAECn8ZAAIdAAgIygw9PgBJAQAdAAgIygw9PgBJAQAAAA==.',['生生']='生生:BAAAKgAECgUICQAAAA==.',['用来']='用来凑成就的:BAAAKgAFFAgIAwAAAA==.',['疯狂']='疯狂圣骑:BAABKgAFFH8HAAINAAMILwlnYwCoAAANAAMILwlnYwCoAAAAAA==.疯狂日:BAAAKgAECgMIAwAAAA==.',['白日']='白日出没:BAACKgAFFH8RAAIQAAQIng/7BQCvAAAQAAQIng/7BQCvAAAqAAQKfysABBAACAirHoQKABoCABAACAirHoQKABoCABEAAgjsCBx1AEEAABMAAwihBNpcADcAAAAA.',['皮斯']='皮斯帕拉:BAAAKgAECggICAAAAA==.',['皮皮']='皮皮圣光盾:BAAAKgAECgQIBAAAAA==.皮皮御风箭:BAABKgAECn8aAAIMAAgIPRdkTwDDAQAMAAgIPRdkTwDDAQAAAA==.',['盾妞']='盾妞:BAABKgAFFH8KAAMTAAgIiA4bDABMAQATAAQIEhYbDABMAQARAAQIegQTLACRAAAAAA==.',['看花']='看花花不语:BAAAKgADCggIDAAAAA==.',['真真']='真真胖真:BAAAKgAECggICAAAAA==.',['睿德']='睿德:BAAAKgAFFAIIAgAAAA==.',['矮油']='矮油殴剋:BAAAKgADCgEIAgAAAA==.',['矮骑']='矮骑潘:BAAAKgAFFAIIAgAAAA==.',['破壁']='破壁榨汁机:BAACKgAFFH8RAAINAAYI4CFMEgDKAQANAAYI4CFMEgDKAQAqAAQKfyEAAg0ACAibHHQ+AAgCAA0ACAibHHQ+AAgCAAAA.',['神圣']='神圣新星:BAAAKgAECgYIDgAAAA==.',['程界']='程界琪:BAAAKgAECgQIBgAAAA==.',['等待']='等待黎明:BAAAKgAECgQIBAAAAA==.',['糖小']='糖小汐:BAAAKgAECggICAAAAA==.',['糖果']='糖果爸爸:BAACKgAFFH8TAAIHAAYIsRbzBgB7AQAHAAYIsRbzBgB7AQAqAAQKfxQAAgcACAhHGqQZAPwBAAcACAhHGqQZAPwBAAAA.',['红玉']='红玉:BAAAKgADCggICAAAAA==.',['织雾']='织雾者肖:BAACKgAFFH8VAAIdAAYIaR4bCACxAQAdAAYIaR4bCACxAQAqAAQKfxUAAh0ACAgWHVgWANsBAB0ACAgWHVgWANsBAAAA.',['终极']='终极噬杀:BAABKgAFFH8GAAIYAAYI7BVuDQCDAQAYAAYI7BVuDQCDAQAAAA==.',['绝对']='绝对牛马:BAABKgAFFH8IAAIaAAgIKgYsBgDhAQAaAAgIKgYsBgDhAQAAAA==.',['继续']='继续鬣:BAAAKgAECggICAAAAA==.',['绵绵']='绵绵:BAAAKgAECgYIDwAAAA==.',['罗伊']='罗伊德卡姆:BAAAKgADCgEIAQAAAA==.',['羁绊']='羁绊半伴:BAAAKgAECgQICAAAAA==.',['美狄']='美狄亚:BAAAKgAECgcIBwAAAA==.',['美食']='美食家史蒂芬:BAABKgAFFH8FAAIOAAMIGg+gFADBAAAOAAMIGg+gFADBAAAAAA==.',['羽依']='羽依:BAABKgAFFH8IAAIWAAQIHCTRIQAWAQAWAAQIHCTRIQAWAQAAAA==.',['羽沐']='羽沐:BAABKgAECn8nAAIXAAgIZBviBwAlAgAXAAgIZBviBwAlAgAAAA==.',['羽衣']='羽衣:BAAAKgAFFAQIBAABKgAFFAgIEgAJAGQaAA==.',['羿丶']='羿丶星辰:BAAAKgAECgYICgAAAA==.',['翔之']='翔之天空:BAABKgAFFH8IAAIaAAQI8h8uDQDUAAAaAAQI8h8uDQDUAAAAAA==.',['老兵']='老兵归来:BAAAKgAECgMIAwAAAA==.老兵羽殇:BAAAKgAECggIAQAAAA==.老兵鹰眼:BAABKgAFFH8FAAIYAAQILyR3IADzAAAYAAQILyR3IADzAAAAAA==.',['老衲']='老衲用沙宣:BAABKgAECn8VAAIkAAgICBlWBgApAgAkAAgICBlWBgApAgAAAA==.',['考拉']='考拉:BAABKgAFFH8IAAIWAAQIBRopNADJAAAWAAQIBRopNADJAAABKgAFFAgIEAAXABciAA==.',['而亲']='而亲仁:BAAAKgAECgEIAQAAAA==.',['耳听']='耳听怒:BAABKgAFFH8GAAIBAAYImhnSEABiAQABAAYImhnSEABiAQAAAA==.',['肥猫']='肥猫转世:BAAAKgAECgIIAgAAAA==.',['肥美']='肥美肉块:BAAAKgAFFAEIAQAAAA==.',['背着']='背着故乡:BAAAKgAECgYIBgAAAA==.',['胖胖']='胖胖熊熊:BAAAKgAFFAIIAgAAAA==.',['脸盆']='脸盆大的火球:BAAAKgADCggICAAAAA==.',['艾格']='艾格希尔:BAABKgAFFH8SAAMPAAYIeR5IBABNAQAOAAYIDx5XDADKAQAPAAYIpRBIBABNAQAAAA==.',['艾薇']='艾薇莉娅:BAAAKgAFFAYIAQABKgAFFAgIDgASAPkhAA==.',['芯艺']='芯艺楠忘:BAAAKgAECgYICAAAAA==.',['花信']='花信:BAAAKgAECggIBgAAAA==.',['花时']='花时酒醉:BAABKgAFFH8KAAMWAAYIdBRvIwAMAQAWAAUIERNvIwAMAQAVAAIILB4vHwCwAAAAAA==.',['花月']='花月正春风:BAACKgAFFH8mAAQOAAgIhB35CQDuAQAOAAgIzhz5CQDuAQAkAAQIlRv7CADcAAAPAAEIOALGJwAmAAAqAAQKfxsAAw4ACAirHYgqAAwCAA4ACAjtHIgqAAwCACQABggBGUoXACcBAAAA.',['花未']='花未败人先衰:BAAAKgADCgEIAQAAAA==.',['苏无']='苏无名:BAAAKgAFFAIIAQAAAA==.',['英崽']='英崽子:BAAAKgAFFAYIAgAAAA==.',['范达']='范达尔熊皮:BAAAKgAECgIIAgAAAA==.',['范迪']='范迪塞尔:BAAAKgAECggIEAAAAA==.',['草么']='草么:BAAAKgADCgYIBgAAAA==.',['草儿']='草儿啊:BAAAKgAECgcICAAAAA==.',['草莓']='草莓二:BAAAKgAECgIIAgAAAA==.草莓僧:BAAAKgADCgEIAQAAAA==.草莓战:BAAAKgADCgEIAQAAAA==.草莓术:BAAAKgAFFAMIAwAAAA==.草莓黑锋:BAAAKgADCggIEAAAAA==.',['莎娜']='莎娜希斯:BAAAKgADCgMIAwAAAA==.',['菜丫']='菜丫:BAABKgAFFH8UAAQUAAgIJxRnBAAAAgAUAAgIJxRnBAAAAgAIAAMI4A3sGQCVAAAJAAIINxBFHACLAAAAAA==.',['菠萝']='菠萝:BAAAKgADCggICAAAAA==.',['華山']='華山令狐冲:BAAAKgAECgEIAQAAAA==.',['萌萌']='萌萌歌:BAAAKgAECgMIAwAAAA==.',['落叶']='落叶有泪:BAAAKgAECgYIDAAAAA==.落叶飘扬:BAAAKgAECgcIBAAAAA==.落叶飞扬:BAAAKgAECggICAAAAA==.',['落花']='落花随风而去:BAACKgAFFH8IAAINAAII2BoibQCRAAANAAII2BoibQCRAAAqAAQKfysAAg0ACAi8G6tWAPIBAA0ACAi8G6tWAPIBAAAA.',['蒂安']='蒂安娜丶星瞳:BAAAKgAECggICwAAAA==.',['蕾丝']='蕾丝灬花边:BAAAKgAECgEIAQAAAA==.',['薛丁']='薛丁格的猫:BAABKgAFFH8YAAQWAAcI6A3bGwA7AQAWAAcI6wrbGwA7AQAbAAUI+Ar6BQC0AAAVAAEI6AFeOQA0AAAAAA==.',['藿香']='藿香正气:BAAAKgADCgIIAgAAAA==.',['血色']='血色训犬师:BAAAKgAFFAQIBAAAAA==.',['術葉']='術葉:BAAAKgAECgMIAwAAAA==.',['西方']='西方小白:BAAAKgADCgYIBgAAAA==.',['西柚']='西柚汁:BAAAKgAECgcIBwAAAA==.',['貓貓']='貓貓不是喵:BAAAKgAFFAQIBAABKgAFFAgIDAASAMocAA==.',['走头']='走头陆怪:BAAAKgAECgQIBAAAAA==.',['超级']='超级九头龙:BAAAKgAECgIIAgAAAA==.',['跳刀']='跳刀敌法:BAAAKgAFFAMIAwAAAA==.',['蹄子']='蹄子的圣光:BAAAKgAECgEIAQAAAA==.',['蹲茅']='蹲茅坑逗蛐蛐:BAAAKgAECgIIAgAAAA==.',['转角']='转角:BAAAKgAECggICQAAAA==.',['辉煌']='辉煌骑士:BAAAKgAECgcIAwABKgAFFAgIDwAOALYgAA==.',['达摩']='达摩院玄悲:BAABKgAFFH8TAAQeAAYIbxgpAgCtAQAeAAUIbxgpAgCtAQAiAAYI9Qm5AQAUAQAdAAMI/AX2KgBuAAAAAA==.',['还是']='还是那个女票:BAAAKgADCgYIBgAAAA==.还是那个棍子:BAABKgAECn8ZAAMFAAgInxzzJQDpAQAFAAgInxzzJQDpAQAGAAEIAADtkgAAAAAAAA==.还是那个棒子:BAAAKgAFFAgIAwAAAA==.',['这是']='这是小德:BAAAKgADCggICAAAAA==.',['道友']='道友聊聊缘:BAABKgAFFH8NAAMcAAYIlBHlAwA2AQAcAAYIJg/lAwA2AQANAAMIpBWnbQCPAAAAAA==.',['那个']='那个战室:BAAAKgAFFAIIAgAAAA==.那个盗賊:BAABKgAFFH8GAAIcAAYILQluFADVAAAcAAYILQluFADVAAAAAA==.',['酒酿']='酒酿小元宵:BAABKgAFFH8JAAIFAAQIxRmdJgDcAAAFAAQIxRmdJgDcAAABKgAFFAYIIgAMACsaAA==.',['酷呆']='酷呆之翼:BAAAKgADCggICAAAAA==.酷呆福福:BAAAKgADCggICAAAAA==.',['釩丶']='釩丶釩:BAACKgAFFH84AAIPAAgIxA7JDABIAQAPAAgIxA7JDABIAQAqAAQKf0EAAg8ACAjfHccQACsCAA8ACAjfHccQACsCAAAA.',['鏃雨']='鏃雨:BAAAKgAECgUIDgAAAA==.',['铁胆']='铁胆翻车侠:BAABKgAFFH8UAAMFAAYIViE7BgDsAQAFAAYIViE7BgDsAQAGAAIIcx5WGQCvAAAAAA==.',['销魂']='销魂嘚眼神:BAAAKgAFFAYIAwAAAA==.',['键山']='键山雏:BAAAKgAECgEIAQAAAA==.',['镇三']='镇三广:BAAAKgADCgIIAgAAAA==.',['闻人']='闻人尭月:BAAAKgAECgcICQAAAA==.闻人槑槑:BAAAKgAECggIDAAAAA==.闻人灬牧月:BAAAKgAECgUIBQAAAA==.',['队丨']='队丨长:BAAAKgAECggIDQAAAA==.',['队丶']='队丶长:BAAAKgAECggIEQAAAA==.',['阿妹']='阿妹啊:BAAAKgADCgYIBgAAAA==.',['阿尔']='阿尔萨拉斯:BAAAKgADCggICAAAAA==.',['阿来']='阿来克斯:BAABKgAFFH8MAAIhAAYIzROmEABXAQAhAAYIzROmEABXAQAAAA==.',['阿沐']='阿沐丶剑来:BAAAKgADCgYIBgAAAA==.',['阿西']='阿西古:BAAAKgAECgQIBAAAAA==.',['阿诗']='阿诗法拉诺:BAABKgAFFH8eAAMLAAcIHAmLCwD1AAALAAcIHAmLCwD1AAAKAAEIvwNNOQA5AAAAAA==.',['陪你']='陪你闲看落花:BAAAKgADCgUIBQAAAA==.',['隊长']='隊长:BAAAKgAECgcIDwAAAA==.',['随心']='随心弄影:BAAAKgADCgMIAwAAAA==.',['雅菲']='雅菲斯尼莫:BAAAKgAECgcICgAAAA==.',['雙雙']='雙雙:BAACKgAFFH8ZAAIUAAgI/BYZBAD2AQAUAAgI/BYZBAD2AQAqAAQKfzcAAxQACAj/Dl9GAPkAABQACAj/Dl9GAPkAAAkABQjPArWMADoAAAAA.',['雨淋']='雨淋夏末:BAAAKgAECgYIBQAAAA==.',['零度']='零度冰峰:BAAAKgAECggIEQAAAA==.',['霁月']='霁月难逢:BAACKgAFFH8TAAIFAAQIpCDkCwD7AAAFAAQIpCDkCwD7AAAqAAQKfxgAAgUACAgoIB8PAH8CAAUACAgoIB8PAH8CAAEqAAUUCAgUAAUA6CIA.',['霜降']='霜降雪飘:BAAAKgADCggIBAAAAA==.',['霸气']='霸气雄图:BAACKgAFFH8RAAIXAAQIYhaxEgDOAAAXAAQIYhaxEgDOAAAqAAQKfx0AAxcACAjSGrEjAJYBABcACAg+FrEjAJYBAAEABgioE8BFACkBAAAA.',['静默']='静默火花:BAAAKgAFFAgIBAAAAA==.',['风之']='风之灵泣:BAABKgAECn8gAAINAAgI7xi3GQD2AQANAAgI7xi3GQD2AQAAAA==.',['风云']='风云艾瑞克:BAAAKgAECgcIEAAAAA==.',['风雅']='风雅:BAAAKgAECgIIAgAAAA==.',['风雷']='风雷法王:BAAAKgAFFAYIAgAAAA==.',['飘逸']='飘逸敌法:BAAAKgAECgMIAwAAAA==.',['飞将']='飞将军:BAAAKgAECgUIBQAAAA==.',['飞翔']='飞翔:BAAAKgADCggICAAAAA==.',['饭木']='饭木桶打喷嚏:BAACKgAFFH8MAAMlAAQI+B/YAwAAAQAlAAQI+B/YAwAAAQAhAAQIJAaYLACAAAAqAAQKfxsAAyUACAgyIvEBALUCACUACAgyIvEBALUCACEAAgjRFYNSAIEAAAEqAAUUCAgvABQAniUA.',['香喷']='香喷喷的粽子:BAAAKgAECgEIAQAAAA==.',['马克']='马克的恩:BAAAKgAFFAMIAwAAAA==.',['骑盗']='骑盗恶法武:BAAAKgADCgIIAgAAAA==.',['魅影']='魅影灬靈珑:BAAAKgADCggICAAAAA==.',['魔丸']='魔丸凶兆:BAAAKgADCgQIBAAAAA==.',['魔侯']='魔侯罗珈:BAABKgAFFH8MAAMUAAgI9Qq+EwAVAQAUAAYIVQu+EwAVAQAIAAIIqw2aHwCNAAAAAA==.',['魔鬼']='魔鬼小师妹:BAAAKgADCgQIBgAAAA==.',['鲁小']='鲁小小:BAAAKgADCgYIBgAAAA==.',['鸡黑']='鸡黑头子:BAABKgAFFH8IAAIPAAgIFxYOAgBMAgAPAAgIFxYOAgBMAgAAAA==.',['麦子']='麦子:BAAAKgAECgcIBwAAAA==.',['黑之']='黑之月:BAAAKgAFFAgIBAAAAA==.',['黑暗']='黑暗献祭:BAAAKgADCgEIAQAAAA==.',['黑铁']='黑铁狼之:BAABKgAECn8cAAIFAAgIbiAPEgBpAgAFAAgIbiAPEgBpAgAAAA==.',['默默']='默默俊:BAAAKgAECgQIBAAAAA==.',['鼻嗅']='鼻嗅爱:BAABKgAFFH8GAAIFAAYIuAzLEwA4AQAFAAYIuAzLEwA4AQAAAA==.',['龍錡']='龍錡士:BAAAKgADCgQIBAAAAA==.',['龙之']='龙之吐息:BAAAKgAFFAQIBAAAAA==.',['龙葵']='龙葵:BAABKgAFFH8SAAIBAAgIiBpTBABjAgABAAgIiBpTBABjAgAAAA==.',['龙行']='龙行天下武:BAAAKgAECgcIEAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end