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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Paladin-Holy','Priest-Shadow','Mage-Fire','Mage-Frost','Monk-Mistweaver','Priest-Discipline','Shaman-Enhancement','Shaman-Restoration','Priest-Holy','Druid-Feral','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Fury','Warlock-Destruction','Druid-Balance','Evoker-Preservation','Evoker-Devastation','Unknown-Unknown','Hunter-BeastMastery','Rogue-Outlaw','Rogue-Assassination','Mage-Arcane','DeathKnight-Frost','Druid-Restoration','Hunter-Marksmanship','Warlock-Affliction','Monk-Windwalker','Monk-Brewmaster','Rogue-Subtlety','DemonHunter-Vengeance','DemonHunter-Havoc','Shaman-Elemental','Warrior-Protection','Warrior-Arms','Warlock-Demonology','Druid-Guardian',}; local provider = {region='CN',realm='凯尔萨斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acane:BAACKgAFFH8QAAQBAAcI6A6AFAAFAQABAAMI7hiAFAAFAQACAAQIZAcOFwC/AAADAAEI9hfKFABCAAAqAAQKfxgABAEACAjVIOEyAFcCAAEACAjVIOEyAFcCAAIAAwg5Enw6AKYAAAMAAQj9HbtLAEkAAAAA.',An='Angelcat:BAAAKgAECgQIBwAAAA==.',Ar='Archangel:BAABKgAFFH8IAAIEAAMIOhjOGgCqAAAEAAMIOhjOGgCqAAAAAA==.',Ba='Bazingahaha:BAAAKgAFFAgIAgAAAA==.',Be='Besiege:BAACKgAFFH8gAAIFAAUIHRwYEgAwAQAFAAUIHRwYEgAwAQAqAAQKfx0AAwUACAg4IrAGAIICAAUACAg4IrAGAIICAAYAAQgUAey8AAgAAAAA.',Bl='Blois:BAACKgAFFH8OAAIHAAMI1xkgGQDVAAAHAAMI1xkgGQDVAAAqAAQKfxsAAgcACAgqIZUUAEMCAAcACAgqIZUUAEMCAAAA.',Ch='Christianus:BAABKgAFFH8GAAIIAAYIowjBCQAIAQAIAAYIowjBCQAIAQAAAA==.',Da='Darkkratos:BAAAKgAECgcIDQAAAA==.',Di='Divinecomedy:BAABKgAFFH8OAAIBAAYIyR+MEQDRAQABAAYIyR+MEQDRAQABKgAFFAgICAACAHcUAA==.',Do='Doufu:BAABKgAECn8WAAMJAAgIaReIJgCTAQAJAAcILBeIJgCTAQAKAAIINwPdxwAmAAAAAA==.',Ec='Eczar:BAAAKgAFFAQIBAAAAA==.',Ed='Eden:BAACKgAFFH8vAAQLAAYIkBWEEQAmAQALAAYIkBWEEQAmAQAIAAMIUAi6JACOAAAEAAEIOQYXMAA2AAAqAAQKfzsAAwsACAi1H2UZAAoCAAsACAi1H2UZAAoCAAgABAhECSB2AGkAAAAA.',Et='Eternalfire:BAAAKgAECgcICwAAAA==.Eternalstar:BAAAKgAECggICgAAAA==.',Fl='Flamekratos:BAAAKgADCgUIBQAAAA==.',Go='Gotnatural:BAABKgAECn8gAAIMAAgIpREfDwCNAQAMAAgIpREfDwCNAQAAAA==.',Ju='Jupiter:BAAAKgADCggICAAAAA==.',Ka='Kakaru:BAAAKgAECgMIAwAAAA==.Kar:BAAAKgADCggICAAAAA==.Karkin:BAABKgAFFH8MAAIBAAYISyCIEwC/AQABAAYISyCIEwC/AQAAAA==.',Kh='Khaleesi:BAAAKgAECgQIBAAAAA==.',Li='Lightcow:BAABKgAECn8ZAAMBAAgIARhMbQB9AQABAAgIARhMbQB9AQADAAEIzgc5JgAgAAAAAA==.',Lo='Locker:BAAAKgADCgEIAQAAAA==.',Lu='Lusentovo:BAABKgAECn8eAAMNAAgIRRozEAD0AQANAAgIRRozEAD0AQAOAAYIYAUvmgCcAAABKgAFFAgICAAPALMSAA==.',Ma='Man:BAAAKgADCgQIBAAAAA==.',Mi='Mistar:BAAAKgADCggICAAAAA==.',Mo='Monicacmm:BAAAKgAECgIIAgAAAA==.Moomin:BAAAKgADCgEIAQAAAA==.',Ne='Neon:BAAAKgADCggIEAAAAA==.',No='Northgay:BAAAKgAECgcIDgABKgAFFAcIDwAQAOQkAA==.',Pa='Palatinus:BAABKgAFFH8QAAMBAAYIjhtHEAATAQACAAYIPBtYCACFAQABAAQIUSFHEAATAQAAAA==.Pazhani:BAAAKgAECgEIAQAAAA==.',Po='Pokypokey:BAAAKgAECgEIAQAAAA==.',Pu='Purple:BAAAKgAECgcIBwAAAA==.',Se='Sebastian:BAABKgAFFH8GAAIBAAQI4yO1BwBAAQABAAQI4yO1BwBAAQAAAA==.',Sk='Skyla:BAACKgAFFH81AAIKAAYIARsYDgBuAQAKAAYIARsYDgBuAQAqAAQKfzsAAgoACAh+IVEQAHYCAAoACAh+IVEQAHYCAAAA.',So='Solomid:BAACKgAFFH8QAAIOAAMIww/CMwDHAAAOAAMIww/CMwDHAAAqAAQKfysAAg4ACAgdG6kjAC8CAA4ACAgdG6kjAC8CAAAA.',St='Stiferz:BAAAKgAECgcICAAAAA==.',Th='Thunderstorm:BAAAKgADCgQIBAAAAA==.',To='Toosober:BAAAKgAFFAQIBAAAAA==.',Wh='Whispered:BAAAKgAECgYIBgAAAA==.',Wi='Wilburuncle:BAACKgAFFH8OAAIGAAQIVw5cGQCvAAAGAAQIVw5cGQCvAAAqAAQKf1EAAgYACAgNH64EAIgCAAYACAgNH64EAIgCAAAA.Wilburunlce:BAACKgAFFH8XAAIGAAQILRfOEQDUAAAGAAQILRfOEQDUAAAqAAQKf3MAAgYACAjTICAKAJMCAAYACAjTICAKAJMCAAAA.',Zi='Zip:BAABKgAFFH8fAAIBAAcITyEOCwAWAgABAAcITyEOCwAWAgAAAA==.',Zx='Zxcxv:BAABKgAFFH8QAAIBAAQI4RyJHAAAAQABAAQI4RyJHAAAAQAAAA==.',['一二']='一二三木头人:BAABKgAFFH8SAAICAAMI5wVSIwBrAAACAAMI5wVSIwBrAAAAAA==.',['一剑']='一剑倾橙:BAAAKgAECggIDgAAAA==.',['一袖']='一袖两青蛇:BAAAKgAECgMIAwAAAA==.',['三千']='三千:BAABKgAFFH8IAAIQAAgI5htZBQBEAgAQAAgI5htZBQBEAgAAAA==.三千圣焰:BAAAKgAECggICAAAAA==.',['三点']='三点三啦喂:BAAAKgAECgcIBwAAAA==.',['不羁']='不羁灬清春:BAAAKgAECgQIBAAAAA==.',['丨不']='丨不丶闹丨:BAABKgAFFH8FAAIRAAUILQbiGQDZAAARAAUILQbiGQDZAAAAAA==.',['丨微']='丨微醺丨:BAAAKgAECgcIDwAAAA==.',['临风']='临风载兮:BAAAKgAECggIDwAAAA==.',['丶夜']='丶夜尽天明丶:BAAAKgAECgQIBAAAAA==.',['丶碧']='丶碧月:BAABKgAECn8ZAAMLAAgI/AbsIQC/AAALAAgI/AbsIQC/AAAIAAQIDgF0oAAZAAAAAA==.',['九阴']='九阴埋:BAABKgAFFH8gAAMOAAcIayAmAgDKAQAOAAcIayAmAgDKAQANAAMIlBUbEAC+AAAAAA==.',['二水']='二水:BAAAKgAECgcIDwAAAA==.',['亦正']='亦正亦邪的人:BAAAKgADCggICAAAAA==.',['亨德']='亨德列克:BAAAKgAFFAQIBAAAAA==.',['亲亲']='亲亲怪:BAABKgAFFH8GAAMSAAYIPxXYAwDZAAASAAQIdBDYAwDZAAATAAIIUgo2FwCVAAABKgAFFAgIBAAUAAAAAA==.',['人来']='人来鸟不惊:BAABKgAFFH8IAAIRAAQI6CNPHAA5AQARAAQI6CNPHAA5AQAAAA==.',['人靓']='人靓条儿顺:BAABKgAFFH8IAAIBAAgIvR56BACSAgABAAgIvR56BACSAgAAAA==.',['以狼']='以狼之名:BAAAKgAECgYICgAAAA==.',['伊利']='伊利奥斯:BAAAKgAECgMIAwAAAA==.伊利蛋丶怒疯:BAAAKgAECgYIDAAAAA==.',['伊瑟']='伊瑟呱:BAAAKgAECgcIBwAAAA==.',['伊鲁']='伊鲁鲁德:BAAAKgAECggIDAAAAA==.',['低调']='低调羊肉串:BAABKgAFFH8HAAIVAAQICyVNFgBFAQAVAAQICyVNFgBFAQAAAA==.',['何物']='何物为真:BAACKgAFFH8IAAIWAAQIrg/RBQC6AAAWAAQIrg/RBQC6AAAqAAQKfzwAAxYACAjyIJwFABQCABYACAjyIJwFABQCABcABAiQF18vAOIAAAAA.',['何静']='何静恩:BAABKgAFFH8GAAICAAYIKBNPAgBuAQACAAYIKBNPAgBuAQAAAA==.',['佩特']='佩特罗丶:BAAAKgAECgMIAwAAAA==.',['保留']='保留至今:BAABKgAFFH8IAAMNAAQIYSC/CwDlAAAOAAQIOx6vIwAGAQANAAQIzBi/CwDlAAAAAA==.',['信仰']='信仰大书:BAAAKgADCgYIBgAAAA==.',['假高']='假高兴:BAABKgAFFH8GAAIRAAYITx0qDAC/AQARAAYITx0qDAC/AQAAAA==.',['傲娇']='傲娇的海胆:BAAAKgAFFAQIAgAAAA==.',['光天']='光天化日:BAABKgAFFH8IAAIIAAgI4CCnAAAGAgAIAAgI4CCnAAAGAgAAAA==.',['其疾']='其疾如风:BAAAKgAECgYIDgAAAA==.',['冥界']='冥界猎魂:BAABKgAFFH8IAAIVAAQIZxHZNwC4AAAVAAQIZxHZNwC4AAAAAA==.',['冰冰']='冰冰丶神圣:BAAAKgAECggIDgAAAA==.',['冰鋒']='冰鋒:BAAAKgAFFAgIAwAAAA==.',['冲帝']='冲帝逆臣:BAAAKgADCgEIAQAAAA==.',['冷妍']='冷妍冰霜:BAABKgAECn8tAAIKAAgInh4ICwAaAgAKAAgInh4ICwAaAgAAAA==.',['冷瞳']='冷瞳雨轩:BAABKgAECn8aAAIVAAgIoRmqNgDKAQAVAAgIoRmqNgDKAQAAAA==.',['凶残']='凶残的大白兔:BAABKgAFFH8SAAIBAAUInhjhFwArAQABAAUInhjhFwArAQAAAA==.',['列王']='列王壁垒:BAAAKgAECgYIBgAAAA==.',['别贪']='别贪吃饱了:BAABKgAFFH8LAAMGAAYIoxm7BQB6AQAGAAYIoxm7BQB6AQAFAAQIQBhQFAD+AAAAAA==.',['刮痧']='刮痧小能手:BAABKgAFFH8IAAIYAAgIwwj+CQDHAQAYAAgIwwj+CQDHAQAAAA==.',['剑仙']='剑仙:BAAAKgAECgIIAwAAAA==.',['加藤']='加藤丶惠:BAAAKgAECgYICgAAAA==.',['勾栏']='勾栏丶听曲:BAAAKgAFFAQIBAAAAA==.',['北斗']='北斗神犬:BAABKgAECn8YAAIHAAgIoSPLFwApAgAHAAgIoSPLFwApAgAAAA==.',['千叶']='千叶浅草:BAAAKgAECgYICQAAAA==.',['千早']='千早爱音:BAAAKgAECggIDQAAAA==.',['午言']='午言双玉:BAAAKgADCggICAAAAA==.',['南城']='南城忆潇湘丶:BAAAKgAECgUIBQAAAA==.',['南鸢']='南鸢北笙:BAACKgAFFH8oAAMZAAUI1xz7BQAUAQAZAAUI1xz7BQAUAQAOAAEI5wsnMQBEAAAqAAQKfyUAAw4ACAgHG6cyAOcBAA4ACAj8FacyAOcBABkACAgQFS8UAGwBAAAA.',['原来']='原来都是夢:BAAAKgAECgYIBgAAAA==.',['口歹']='口歹匕礻申口:BAAAKgADCgYIBgAAAA==.',['叫我']='叫我挘人:BAAAKgAFFAEIAQAAAA==.',['可乐']='可乐加片柠檬:BAAAKgAECgcIDQAAAA==.',['叶小']='叶小凡:BAAAKgAECggICAAAAA==.',['叶良']='叶良辰丶:BAAAKgADCgQIBAAAAA==.',['叶落']='叶落清风丶:BAAAKgAFFAIIAgAAAA==.',['吉侒']='吉侒娜:BAACKgAFFH8LAAIGAAMItRIFGgCsAAAGAAMItRIFGgCsAAAqAAQKfzUAAgYACAhBHT8VABICAAYACAhBHT8VABICAAAA.',['吉安']='吉安妠:BAAAKgADCggICQAAAA==.吉安訤:BAAAKgAECgYIBgAAAA==.吉安雫:BAAAKgAECgEIAQAAAA==.',['吗喽']='吗喽:BAAAKgAECgYIBgABKgAFFAgIBQAIALEJAA==.',['呆萌']='呆萌小骑士:BAAAKgADCgQIBAAAAA==.',['哟呵']='哟呵:BAAAKgAECggIDAAAAA==.',['唯我']='唯我独魔:BAAAKgAECggICAAAAA==.',['唯爱']='唯爱遥遥:BAAAKgAFFAQIBAAAAA==.',['唯闻']='唯闻玉磬依旧:BAAAKgAFFAQIBAABKgAFFAYIKgAHAJQaAA==.',['嗷呜']='嗷呜咆哮:BAACKgAFFH8HAAITAAMIygeTGACfAAATAAMIygeTGACfAAAqAAQKfyEAAxMACAhbFSgNAKgBABMACAhbFSgNAKgBABIACAivBXQSALwAAAAA.',['四季']='四季青:BAAAKgADCgEIAgAAAA==.',['圣光']='圣光奶糖:BAAAKgADCgQIBAAAAA==.',['圣剑']='圣剑:BAABKgAFFH8QAAIBAAQIix2yOwD/AAABAAQIix2yOwD/AAAAAA==.',['在我']='在我身后输出:BAAAKgAECgEIAQAAAA==.',['壮的']='壮的一比:BAAAKgAFFAYIBAAAAA==.',['夏饭']='夏饭团:BAAAKgAFFAYIAwAAAA==.',['大橘']='大橘为重:BAAAKgADCgYIBgAAAA==.',['大领']='大领主:BAAAKgAECggICAAAAA==.',['天之']='天之流浪:BAAAKgAFFAIIAgAAAA==.',['天赐']='天赐飞尸:BAAAKgAFFAMIAgAAAA==.',['天颤']='天颤闪灵:BAAAKgAECgYIBgAAAA==.',['天魂']='天魂葬爱:BAAAKgAECggICwAAAA==.',['奈落']='奈落之栀:BAABKgAFFH8FAAIaAAUILxLkEQAPAQAaAAUILxLkEQAPAQABKgAFFAgIBAAHAAcHAA==.',['好多']='好多胡子:BAABKgAFFH8LAAMbAAMI1QxVGACkAAAbAAMI1QxVGACkAAAVAAEIywP1YwApAAABKgAFFAgIOQAXAI8cAA==.',['婷不']='婷不下来:BAAAKgAECgcICwAAAA==.',['子彈']='子彈:BAAAKgAECggICAAAAA==.',['孤月']='孤月映细雪:BAAAKgAECgcICwAAAA==.',['安娜']='安娜的玫瑰:BAACKgAFFH8GAAILAAYIShTOCQA4AQALAAYIShTOCQA4AQAqAAQKfzYAAggACAg1IZoEAD0CAAgACAg1IZoEAD0CAAAA.',['宝贝']='宝贝天使:BAAAKgADCggICAAAAA==.',['寒冰']='寒冰护体:BAABKgAFFH8IAAIFAAQIfBB7HgDbAAAFAAQIfBB7HgDbAAAAAA==.',['封火']='封火沙包:BAABKgAFFH8TAAMGAAQIDRmOCQDgAAAGAAMIJBeOCQDgAAAYAAQIkQ4dLwCnAAABKgAFFAgIOQAXAI8cAA==.',['射的']='射的一手好箭:BAAAKgAECggICAAAAA==.',['小熊']='小熊喵丶:BAAAKgADCgIIAgAAAA==.',['小猎']='小猎的圣骑:BAABKgAECn8dAAIBAAgIVx/JNgAkAgABAAgIVx/JNgAkAgAAAA==.',['小红']='小红手飞飞:BAAAKgADCgEIAQAAAA==.',['小龙']='小龙女:BAAAKgAFFAIIAgAAAA==.',['尛肨']='尛肨孒:BAAAKgADCgQIBAAAAA==.',['就是']='就是橘子:BAAAKgAECgEIAQAAAA==.',['巴列']='巴列:BAAAKgAECgIIAQAAAA==.',['布莱']='布莱迩:BAAAKgAECggIDwAAAA==.',['帝尘']='帝尘:BAAAKgAECgQIBQAAAA==.',['帝慕']='帝慕:BAAAKgAECggIDgAAAA==.',['帝璐']='帝璐:BAAAKgAECgQICgAAAA==.',['帝苍']='帝苍:BAAAKgAECgYICAAAAA==.',['帝辰']='帝辰:BAAAKgAECgEIAQAAAA==.',['干中']='干中学:BAAAKgAFFAgIBAAAAA==.',['干巴']='干巴菌儿:BAAAKgADCggICAABKgAFFAgIBgAHABUEAA==.',['幸运']='幸运鹅:BAAAKgAECggIEQAAAA==.',['幼儿']='幼儿园没毕业:BAAAKgAECggICAAAAA==.',['幽夜']='幽夜冥冥:BAAAKgAECggICAAAAA==.',['弄玉']='弄玉呢喃:BAAAKgADCgIIAgAAAA==.',['微波']='微波炉:BAAAKgAFFAIIAgAAAA==.',['德中']='德中蜘蛛侠:BAAAKgAECgMIBgAAAA==.',['德行']='德行合一:BAAAKgADCgQIBAAAAA==.',['心前']='心前輩:BAABKgAECn8UAAIPAAgIfRcKHgDjAQAPAAgIfRcKHgDjAQAAAA==.',['忍刺']='忍刺:BAAAKgAECgMIAwAAAA==.',['性感']='性感小脚丫:BAAAKgAECgEIAQAAAA==.',['想来']='想来一发么:BAACKgAFFH8IAAMbAAMImQx0IABtAAAbAAIIaQ10IABtAAAVAAEI9wqKLwA9AAAqAAQKfxwAAxsACAgNG6cKACoCABsACAgNG6cKACoCABUACAigCEraAHkAAAAA.',['成分']='成分复杂:BAABKgAFFH8WAAMQAAgI5xtpAQDjAQAQAAgI5xtpAQDjAQAcAAEIAAAyKQAAAAAAAA==.',['我有']='我有无敌:BAABKgAECn8YAAIBAAcI5hW6hQCMAQABAAcI5hW6hQCMAQAAAA==.',['所谓']='所谓伊人:BAABKgAFFH8FAAINAAUIPCDgCgBkAQANAAUIPCDgCgBkAQAAAA==.',['承诺']='承诺等于守护:BAAAKgADCgYIBgAAAA==.',['拓跋']='拓跋玉兒:BAAAKgAECgEIAQAAAA==.',['拯救']='拯救发际线:BAAAKgADCgQIBQAAAA==.',['收心']='收心不再浪:BAAAKgADCgIIAgAAAA==.',['斯吉']='斯吉亚娜:BAACKgAFFH8FAAMVAAMItw7gTQByAAAVAAMItw7gTQByAAAbAAEI2wgAVQAuAAAqAAQKfxkAAxUACAh6FydNAMsBABUACAhvFidNAMsBABsAAwhkDuZ9AFAAAAAA.',['无聊']='无聊的薯条:BAAAKgAFFAYIBAAAAA==.',['旮旯']='旮旯给木:BAAAKgAECgYIBgAAAA==.',['星宿']='星宿老仙:BAAAKgAECgQIBAAAAA==.',['星术']='星术埃兰:BAAAKgAECgQIBAAAAA==.',['星羽']='星羽瞳:BAAAKgAECgUIBQAAAA==.',['春牯']='春牯咕:BAAAKgAECgUIDgAAAA==.',['是夏']='是夏夏呀:BAABKgAFFH8GAAIYAAYIeBB2FABBAQAYAAYIeBB2FABBAQAAAA==.',['晓小']='晓小球:BAAAKgAECgQIBAAAAA==.',['普琳']='普琳:BAAAKgAECgYICAAAAA==.',['暗影']='暗影延展:BAAAKgAECgEIAQAAAA==.',['最有']='最有德样的德:BAAAKgADCggICAAAAA==.',['月夜']='月夜七辰:BAAAKgAECgcIBwAAAA==.',['月思']='月思如伤:BAAAKgAECgMIAwAAAA==.',['月熙']='月熙他哥:BAAAKgAECgIIAgAAAA==.',['月眉']='月眉与瞳:BAABKgAFFH8IAAIVAAQI7QhXHwCmAAAVAAQI7QhXHwCmAAAAAA==.',['有志']='有志青年:BAAAKgADCgQIBAAAAA==.',['望月']='望月寻梦:BAAAKgAECgQICAAAAA==.',['朦胧']='朦胧鸟:BAAAKgAECggICAAAAA==.',['末丶']='末丶洛:BAABKgAFFH8MAAIOAAMIGhyrDwD8AAAOAAMIGhyrDwD8AAAAAA==.',['朵洛']='朵洛希海娅特:BAABKgAFFH8WAAMRAAgIIiNOAgDLAgARAAgIIiNOAgDLAgAaAAQIFRPSAwBBAQAAAA==.',['李春']='李春宇:BAAAKgAECgUIBgAAAA==.',['李有']='李有药药:BAAAKgADCgYIBgAAAA==.',['杭州']='杭州小伙:BAAAKgAECggIDQAAAA==.',['杰杰']='杰杰哥:BAAAKgAFFAQIBAAAAA==.',['极度']='极度风骚:BAAAKgAECgIIAwAAAA==.',['林北']='林北:BAABKgAFFH8UAAMIAAgIoxW2AgBJAgAIAAgIDxS2AgBJAgALAAYIbxeBCQCMAQAAAA==.',['林有']='林有德:BAAAKgAECggICAAAAA==.',['枪炮']='枪炮玫瑰:BAAAKgAECgQIBAAAAA==.',['柯蕾']='柯蕾莉亚:BAAAKgAECggICAAAAA==.',['格温']='格温德林:BAABKgAECn8fAAICAAgIehVqGQCbAQACAAgIehVqGQCbAQAAAA==.',['梦回']='梦回吹角连营:BAAAKgAECgMIAwAAAA==.',['梦断']='梦断幽影:BAAAKgAFFAQIBAAAAA==.',['樱井']='樱井葙:BAAAKgADCgEIAQAAAA==.',['樱桃']='樱桃奶卷:BAABKgAFFH8JAAMYAAYIIBU/IQDiAAAYAAYIIBU/IQDiAAAGAAEIYxgxKgBBAAABKgAFFAgIFAAYADQjAA==.',['橘长']='橘长:BAAAKgAFFAIIAgAAAA==.',['欧鲁']='欧鲁森:BAAAKgAECgcIDAAAAA==.',['死亡']='死亡蔓延:BAAAKgAECgUIBQAAAA==.',['氹亻']='氹亻卩氹:BAAAKgADCgEIAgAAAA==.',['没事']='没事喝两口:BAABKgAFFH8QAAIXAAgIMAVxBgDOAQAXAAgIMAVxBgDOAQAAAA==.',['河乌']='河乌宝宝:BAAAKgAFFAYIBAABKgAECggIIAAPAJseAA==.',['法你']='法你老味:BAABKgAECn8WAAIFAAgIABFlOwCkAQAFAAgIABFlOwCkAQAAAA==.',['泡椒']='泡椒煮茶:BAAAKgAECgUIBQAAAA==.',['泡泡']='泡泡杂酱面:BAAAKgAECgYIBgAAAA==.',['洋贝']='洋贝溪:BAAAKgAECgQIBwAAAA==.',['浅若']='浅若夏陌:BAAAKgAECgEIAQAAAA==.',['浠荋']='浠荋屲娜思:BAAAKgADCgcIBwAAAA==.',['浪漫']='浪漫丶柔情:BAAAKgADCggIDAAAAA==.浪漫幽情:BAAAKgADCgQICAAAAA==.浪漫灬幽情:BAAAKgADCgYIBgAAAA==.浪漫灬曼舞:BAAAKgADCggIDAAAAA==.浪漫灬柔情:BAAAKgADCgYIBgAAAA==.',['浮夸']='浮夸小斗士:BAAAKgAECgMIAwAAAA==.',['清月']='清月如默笙:BAACKgAFFH8qAAQHAAYIlBq9EAAmAQAHAAYIlBq9EAAmAQAdAAQI4xsgDwDvAAAeAAQIHxCTBADlAAAqAAQKfxsABB0ACAgnE2oqAJMBAB0ACAibEmoqAJMBAAcABQhpF8xZANQAAB4ABggWCGUZALUAAAAA.',['清洪']='清洪尊素影:BAAAKgAECgQIBAAAAA==.',['澳洲']='澳洲谷饲肥牛:BAABKgAFFH8OAAMLAAgIohcXAwAxAgALAAgIohcXAwAxAgAEAAYIZQ6fDAA1AQAAAA==.',['灑颟']='灑颟:BAAAKgADCggICAAAAA==.',['火炎']='火炎焱魂:BAAAKgADCgIIAgAAAA==.',['火焰']='火焰魔月:BAAAKgADCgIIAgAAAA==.',['灬园']='灬园园:BAAAKgADCggICAAAAA==.',['灵羽']='灵羽:BAAAKgAFFAQIBAAAAA==.',['灵逸']='灵逸:BAABKgAFFH8YAAMYAAYIkB9sCQDaAQAYAAYIfB9sCQDaAQAGAAQI2yKIBwDyAAAAAA==.',['灵魂']='灵魂小猎鹰:BAAAKgADCgMIAwAAAA==.',['炒鸡']='炒鸡法斯:BAAAKgADCgMIBAAAAA==.',['無雙']='無雙:BAAAKgADCggICAAAAA==.',['燃烧']='燃烧二零二零:BAAAKgAFFAIIAgAAAA==.',['燕云']='燕云一骑:BAAAKgAECgcIBwAAAA==.',['爱丘']='爱丘雷儿:BAAAKgAECgQIBQAAAA==.',['爱喝']='爱喝无糖可乐:BAABKgAFFH8QAAMBAAYIYhKtAwCWAQABAAYI6w+tAwCWAQACAAYImw97AwBAAQAAAA==.',['爱的']='爱的猪头:BAACKgAFFH8XAAMXAAgIFgV0EgArAQAXAAcIsQV0EgArAQAfAAIIdwE/BgAtAAAqAAQKfy0AAxcACAhMGrYSAAkCABcACAhMGrYSAAkCAB8ABgjpBO8lAM4AAAAA.',['狂战']='狂战寒:BAAAKgAFFAEIAQAAAA==.',['狂猎']='狂猎:BAABKgAFFH8UAAIVAAMIpSCsJgDrAAAVAAMIpSCsJgDrAAAAAA==.',['狼铛']='狼铛:BAACKgAFFH8nAAIWAAgISBohAQDMAQAWAAgISBohAQDMAQAqAAQKfyQAAhYACAi+IkoCAKMCABYACAi+IkoCAKMCAAAA.',['猪都']='猪都被吓死:BAAAKgAECgMIAwAAAA==.',['猫鱼']='猫鱼:BAAAKgAECgYIBgAAAA==.',['珂儿']='珂儿:BAABKgAECn8WAAIVAAgIYRa/OgAMAgAVAAgIYRa/OgAMAgAAAA==.',['珏影']='珏影:BAABKgAECn8uAAIgAAgI5gavPADBAAAgAAgI5gavPADBAAAAAA==.',['琢光']='琢光:BAAAKgAECggICgAAAA==.',['琼恩']='琼恩丶雪诺:BAAAKgAECgcIEQAAAA==.',['癃嫈']='癃嫈龘龘:BAAAKgADCgQIBAAAAA==.',['白露']='白露为晞:BAABKgAFFH8OAAIHAAYIVhiuAgClAQAHAAYIVhiuAgClAQAAAA==.',['看热']='看热闹的小伙:BAAAKgAFFAIIAgAAAA==.',['真爱']='真爱你的猪:BAAAKgADCgEIAQAAAA==.',['砍砍']='砍砍更健康:BAAAKgADCgEIAgAAAA==.',['神明']='神明不负我丶:BAAAKgAECgUICAAAAA==.',['神灵']='神灵之怒:BAACKgAFFH8ZAAMGAAMIfB6WDAAEAQAGAAMIfB6WDAAEAQAYAAIIuBQnOACCAAAqAAQKfxoAAwYACAguG747AH0BAAYACAhFGL47AH0BABgABAgsHmk7AFgBAAAA.',['窗外']='窗外的小西瓜:BAAAKgAFFAEIAQABKgAFFAYIKgAHAJQaAA==.',['箭在']='箭在弦上:BAAAKgAFFAIIBAAAAA==.',['米里']='米里亚:BAAAKgAFFAMIAwAAAA==.',['红月']='红月的幽影:BAAAKgAECggICAAAAA==.红月的霜叶:BAAAKgAECggICAAAAA==.',['红浪']='红浪漫:BAAAKgAECgQIBAAAAA==.',['红色']='红色小萌龙:BAACKgAFFH8MAAISAAQIoCFoAwARAQASAAQIoCFoAwARAQAqAAQKfxsAAhIACAiPHuwDAHMCABIACAiPHuwDAHMCAAAA.',['纳米']='纳米激素:BAAAKgAECgYICgAAAA==.',['绿色']='绿色唯美:BAAAKgADCgEIAQAAAA==.',['羊过']='羊过牛叉斯基:BAABKgAFFH8GAAIFAAYIywtDEQA4AQAFAAYIywtDEQA4AQAAAA==.',['美国']='美国叫兽:BAAAKgAECgIIAgAAAA==.',['老撕']='老撕鸡大忽悠:BAAAKgAECgYIBgABKgAFFAYICAAHAEcMAA==.老撕鸡带带我:BAABKgAFFH8IAAIHAAQIRwweJACSAAAHAAQIRwweJACSAAAAAA==.',['肥嘟']='肥嘟嘟佐卫门:BAAAKgAECgIIAgAAAA==.',['肥鸡']='肥鸡:BAAAKgAFFAgIAgAAAA==.',['胆小']='胆小的猪儿虫:BAAAKgAECgUIBQAAAA==.',['胤祁']='胤祁:BAAAKgAECggIEgAAAA==.',['自燃']='自燃之力:BAAAKgADCggICAAAAA==.',['芋圆']='芋圆仙草冻:BAAAKgADCgQIBAAAAA==.',['花花']='花花天下:BAABKgAECn8hAAIhAAgI9R/XFACJAgAhAAgI9R/XFACJAgAAAA==.',['芳華']='芳華絕代:BAAAKgAECgQIBwAAAA==.',['药师']='药师丶:BAABKgAFFH8SAAIhAAgI6Bz5BQBRAgAhAAgI6Bz5BQBRAgAAAA==.',['莉妲']='莉妲:BAAAKgAECgQIBAAAAA==.',['莎琪']='莎琪玛:BAAAKgAFFAIIAgAAAA==.',['菊花']='菊花一朵朵:BAAAKgAECggIDQAAAA==.',['萌萌']='萌萌小甜甜:BAAAKgADCgEIAQAAAA==.',['萝莉']='萝莉蕾姐:BAAAKgAECgYICwAAAA==.',['落清']='落清虚:BAAAKgADCgcIBwAAAA==.',['落雪']='落雪圣剑:BAAAKgADCggICAAAAA==.',['葫芦']='葫芦神殿:BAAAKgADCgYIBgAAAA==.',['蒂朵']='蒂朵:BAAAKgAECgQIEAAAAA==.',['蒙查']='蒙查查:BAAAKgAECgYICgAAAA==.',['蒹葭']='蒹葭萋萋:BAAAKgAFFAYIBAABKgAFFAgIDgABACocAA==.蒹葭采采:BAABKgAFFH8GAAIhAAYIXAiKIAAAAQAhAAYIXAiKIAAAAQAAAA==.',['蓝猫']='蓝猫猫:BAAAKgADCggIGAAAAA==.',['蓝色']='蓝色幽深:BAAAKgAECggIDQAAAA==.',['蕾雅']='蕾雅索斯:BAAAKgAECgUIBwAAAA==.',['薇塔']='薇塔克洛提德:BAABKgAFFH8PAAQDAAgIYBtMAADvAQADAAYIah1MAADvAQABAAMI5xbvWgC7AAACAAMIgAzvDACvAAAAAA==.',['螃蟹']='螃蟹圣斗士:BAAAKgAECgIIAgAAAA==.',['血舞']='血舞半雲天:BAAAKgAECgQIBAAAAA==.血舞燚燚:BAAAKgAECggICAAAAA==.',['街角']='街角丨死骑:BAAAKgAFFAQIBAAAAA==.',['裕东']='裕东:BAAAKgAECgYICgAAAA==.',['要你']='要你命九千型:BAAAKgADCgQIBAAAAA==.',['豐川']='豐川祥子:BAABKgAFFH8FAAIGAAQIjSVDAgAwAQAGAAQIjSVDAgAwAQAAAA==.',['起落']='起落人生:BAAAKgAFFAQIBAAAAA==.',['超级']='超级小三:BAAAKgAECggIEAAAAA==.',['轩辕']='轩辕娃娃:BAAAKgAECgMIAwAAAA==.',['达康']='达康:BAAAKgADCgMIAwAAAA==.',['迁亿']='迁亿:BAABKgAECn8dAAIQAAgIvQhYTgAvAQAQAAgIvQhYTgAvAQAAAA==.',['逆鳞']='逆鳞:BAAAKgAECgYIBgAAAA==.',['進寶']='進寶丶:BAACKgAFFH8bAAMKAAQIpBn0GADAAAAKAAQIpBn0GADAAAAiAAMI3wScIwBjAAAqAAQKfzcAAwoACAiREU4+AI0BAAoACAiREU4+AI0BACIACAhiDlg0AGwBAAAA.',['那么']='那么迷人:BAAAKgADCgQIBAAAAA==.',['那就']='那就他了吧:BAAAKgAECgUIBQAAAA==.',['那年']='那年明月:BAABKgAFFH8cAAMLAAYI0CS8AwAWAgALAAYI0CS8AwAWAgAEAAEIthgzKgBJAAAAAA==.',['部落']='部落最靓的仔:BAAAKgAECgUIBAAAAA==.',['都是']='都是混子:BAAAKgAECgcICwAAAA==.',['酒醉']='酒醉仙:BAAAKgADCgEIAQAAAA==.',['醉裡']='醉裡挑燈看劍:BAAAKgAFFAEIAQAAAA==.',['野性']='野性奶糖:BAAAKgAECggICAAAAA==.',['铁憨']='铁憨憨:BAAAKgAECggICAAAAA==.',['银河']='银河之力:BAAAKgAECgEIAgAAAA==.',['锈迹']='锈迹斑斑:BAAAKgADCgQIBAAAAA==.',['长期']='长期素食:BAABKgAFFH8GAAIjAAMI1w2gDgCLAAAjAAMI1w2gDgCLAAAAAA==.',['长风']='长风破刃:BAAAKgADCgIIAgAAAA==.',['问就']='问就是子刊:BAABKgAFFH8IAAIBAAQI1RQPIQDmAAABAAQI1RQPIQDmAAAAAA==.',['阇妮']='阇妮:BAAAKgAECgYIBgAAAA==.',['阎罗']='阎罗王:BAAAKgADCgIIAgAAAA==.',['阡陌']='阡陌芊芊:BAABKgAFFH8SAAMCAAgIix6MBAAoAQACAAYIpxWMBAAoAQABAAgIix72FAAEAQAAAA==.',['阿古']='阿古茹:BAAAKgAECgMIAwAAAA==.',['阿楠']='阿楠德隆:BAAAKgADCggICAAAAA==.',['陈渔']='陈渔:BAABKgAECn8VAAILAAgI5RV1JQCgAQALAAgI5RV1JQCgAQAAAA==.',['随风']='随风之悠:BAABKgAFFH8IAAIBAAgIjhNCDQD8AQABAAgIjhNCDQD8AQAAAA==.',['雁翎']='雁翎坛主:BAAAKgADCgEIAQAAAA==.',['雪白']='雪白白:BAAAKgAECgIIAgAAAA==.',['雲帆']='雲帆:BAABKgAFFH8GAAIkAAYIDSJyBgC0AQAkAAYIDSJyBgC0AQAAAA==.',['雷妮']='雷妮拉:BAAAKgAECgQIBAAAAA==.',['雷泽']='雷泽基尔:BAAAKgAECgUICQAAAA==.',['霄妮']='霄妮:BAAAKgAECgMIAwAAAA==.',['霸气']='霸气独狼:BAAAKgAECgUIBQAAAA==.',['青山']='青山七海:BAACKgAFFH8MAAIKAAQIAw0IIQD1AAAKAAQIAw0IIQD1AAAqAAQKfyYAAgoACAjlCXJaADABAAoACAjlCXJaADABAAAA.',['青春']='青春染指悲殇:BAAAKgAECgYIBgAAAA==.',['青柠']='青柠养乐多:BAAAKgAFFAIIAgAAAA==.',['青灯']='青灯古城:BAABKgAFFH8FAAQlAAQIkgVeGAA6AAAcAAEIxweTEwA8AAAlAAIIVwdeGAA6AAAQAAEImAFoLQATAAAAAA==.',['青狱']='青狱公子:BAAAKgAECggIDwAAAA==.',['青鸿']='青鸿公子:BAABKgAECn8YAAImAAgIGRCnEQAyAQAmAAgIGRCnEQAyAQAAAA==.',['面团']='面团猎手:BAAAKgAECgEIAQAAAA==.面团零零二:BAAAKgAECggICAAAAA==.',['风声']='风声:BAAAKgAFFAIIAwAAAA==.',['风月']='风月大欧皇:BAACKgAFFH8lAAMTAAUIRxIgEQD6AAATAAUIRxIgEQD6AAASAAIIaCKlBQCpAAAqAAQKfy4AAhMACAhwHtENAGUCABMACAhwHtENAGUCAAAA.风月的拂晓:BAAAKgAECgcIBwABKgAFFAYIKgAHAJQaAA==.',['风雷']='风雷阁:BAABKgAFFH8KAAIPAAYIJQ+vDgBpAQAPAAYIJQ+vDgBpAQAAAA==.',['飛天']='飛天熊喵:BAAAKgAECgUIBQAAAA==.',['飞天']='飞天女賊:BAAAKgADCgQIBgAAAA==.',['马肠']='马肠子纳仁:BAAAKgAECgEIAQAAAA==.',['骑你']='骑你老味:BAAAKgADCggICAAAAA==.',['鬼冢']='鬼冢英吉:BAAAKgAECggIDwAAAA==.',['魔法']='魔法少女乔杉:BAAAKgAFFAQIBAAAAA==.',['鲜血']='鲜血圣骑:BAAAKgAECgMIAwAAAA==.',['麦满']='麦满分:BAAAKgADCggICAAAAA==.',['麦芽']='麦芽儿糖糖:BAAAKgADCgEIAQAAAA==.',['黄泉']='黄泉永坠:BAABKgAFFH8GAAMiAAYI1BH1CQDfAAAiAAQIYRH1CQDfAAAKAAIIARFfPACVAAAAAA==.黄泉葬:BAACKgAFFH8RAAIBAAUIsR8yIQDmAAABAAUIsR8yIQDmAAAqAAQKfxQAAgEACAj7I3cYALYCAAEACAj7I3cYALYCAAEqAAUUCAgBABQAAAAA.',['黑曜']='黑曜丨面包包:BAAAKgADCgYIBgAAAA==.黑曜石小熊猫:BAACKgAFFH8OAAIHAAQI9hmMEgDaAAAHAAQI9hmMEgDaAAAqAAQKfxYAAgcACAgCG0IQABkCAAcACAgCG0IQABkCAAAA.黑曜石小萌法:BAAAKgAECgUIBQAAAA==.黑曜石小萌骑:BAAAKgAECggICAAAAA==.',['黑白']='黑白羽翼:BAABKgAECn8YAAQOAAgIxAzMWAAXAQAOAAcI2Q3MWAAXAQAZAAcIEQNlKAB9AAANAAEI4gP2WAAXAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end