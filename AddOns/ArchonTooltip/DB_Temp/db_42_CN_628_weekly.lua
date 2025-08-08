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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Retribution','Mage-Arcane','Mage-Fire','Druid-Balance','DemonHunter-Havoc','Shaman-Enhancement','Shaman-Restoration','Monk-Mistweaver','Evoker-Devastation','DeathKnight-Blood','Mage-Frost','Warrior-Fury','Monk-Windwalker','Priest-Shadow','Priest-Holy','Priest-Discipline','Druid-Restoration','Druid-Feral','Warlock-Destruction','Warlock-Demonology','Rogue-Assassination','DeathKnight-Unholy','Rogue-Outlaw','Druid-Guardian','DemonHunter-Vengeance','Evoker-Preservation','DeathKnight-Frost','Warlock-Affliction','Paladin-Holy','Shaman-Elemental','Warrior-Arms','Paladin-Protection','Unknown-Unknown',}; local provider = {region='CN',realm='壁炉谷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Aloy:BAACKgAFFH8LAAIBAAMIriF/BAArAQABAAMIriF/BAArAQAqAAQKfycAAwEACAhWJaoCAO8CAAEACAhWJaoCAO8CAAIABQi4IfZdAJcBAAAA.',Ap='Apussycat:BAAAKgAECgMIAwAAAA==.',As='Asce:BAAAKgADCgQIBAAAAA==.',Ba='Balala:BAAAKgAECgcIDwAAAA==.',Bl='Bloodxmoon:BAAAKgAECgMIAwAAAA==.',Bo='Bosslingg:BAAAKgAECgQICQAAAA==.',Ce='Ceya:BAAAKgAECggIEQAAAA==.',Co='Convincing:BAAAKgAFFAQIBAAAAA==.',Cr='Crystalclaw:BAAAKgAFFAYIBAAAAA==.',Da='Dandi:BAAAKgAECggICAAAAA==.',Dg='Dgn:BAABKgAFFH8MAAIDAAYIwySjFQCuAQADAAYIwySjFQCuAQAAAA==.',Do='Doomcryer:BAAAKgAFFAEIAQAAAA==.',Dy='Dylanotto:BAAAKgAFFAEIAQABKgAFFAgITQADABIjAA==.',Ev='Evev:BAABKgAFFH8GAAMCAAYI5BtvFABSAQACAAUITBtvFABSAQABAAEIRh7XSQBZAAAAAA==.',Fe='Felinaemagic:BAABKgAFFH8FAAMEAAUIcxVHAQACAQAEAAQIdxhHAQACAQAFAAEIagzZNwBXAAAAAA==.',Fl='Flamingoo:BAAAKgADCgIIAgAAAA==.',Gq='Gq:BAAAKgADCgEIAQAAAA==.',Ho='Hopebringer:BAACKgAFFH8aAAIDAAUIjSOsCAA5AQADAAUIjSOsCAA5AQAqAAQKfxQAAgMACAg2I08oAHsCAAMACAg2I08oAHsCAAEqAAUUCAhRAAYAGiYA.',Il='Ilidans:BAABKgAFFH8oAAIHAAgI6xvrBABnAgAHAAgI6xvrBABnAgAAAA==.',It='Itonmisaki:BAAAKgADCggICAAAAA==.',Ja='Jawen:BAAAKgADCgEIAQAAAA==.',Ka='Kawayinei:BAAAKgAECgMIAwAAAA==.',Kp='Kposeidon:BAAAKgAECgQIBAAAAA==.',Kr='Kratos:BAAAKgADCggICAAAAA==.',Lu='Lucifall:BAAAKgAECgUIBQAAAA==.Lunamoonfan:BAAAKgAFFAQIBAAAAA==.Luser:BAAAKgADCgQIBAAAAA==.',Ma='Macmillan:BAAAKgAECgUICAABKgAECggIHwABAKQYAA==.',Mu='Mupiapia:BAAAKgAFFAQIBAAAAA==.',My='Mycloudslong:BAAAKgAECgMIBgAAAA==.',Na='Nabunaduo:BAABKgAFFH8GAAIIAAYIGBgLBwB5AQAIAAYIGBgLBwB5AQAAAA==.',Ny='Nyctophile:BAAAKgAECgcIBwAAAA==.',Pl='Playerekqzta:BAACKgAFFH8UAAIJAAQIgxY7MQC0AAAJAAQIgxY7MQC0AAAqAAQKfx4AAgkACAgZHpEIAEICAAkACAgZHpEIAEICAAAA.',Ro='Rochelle:BAABKgAFFH8IAAIKAAQIRgd3EwCDAAAKAAQIRgd3EwCDAAAAAA==.',Si='Singularity:BAACKgAFFH8yAAILAAcIUCTNBwAIAgALAAcIUCTNBwAIAgAqAAQKfyYAAgsACAhRJjkBAAkDAAsACAhRJjkBAAkDAAEqAAUUCAhRAAYAGiYA.',Su='Sunray:BAAAKgADCggICAAAAA==.',Th='Theanngle:BAAAKgAECgYIBgAAAA==.',Ti='Timme:BAAAKgADCgEIAQAAAA==.',Tr='Trafalgar:BAAAKgAECgYIBgAAAA==.',Ud='Ud:BAAAKgAFFAYIAwAAAA==.',Ue='Ueamark:BAAAKgAFFAQIBAAAAA==.',Ur='Ursula:BAAAKgADCggICAAAAA==.',Vi='Virtue:BAAAKgAFFAQIBAAAAA==.',Wi='Wineoneone:BAAAKgAFFAEIAQAAAA==.',Wo='Wolovizt:BAAAKgAECggICAAAAA==.',Xl='Xlubao:BAAAKgAECgMIAwAAAA==.',Yo='Younieer:BAABKgAFFH8KAAIMAAQIoxLhDwDAAAAMAAQIoxLhDwDAAAAAAA==.',Yu='Yuqi:BAAAKgAFFAIIAgAAAA==.',['Äv']='Äventyr:BAABKgAFFH8PAAIBAAQIMiTzGQAdAQABAAQIMiTzGQAdAQABKgAFFAgIUQAGABomAA==.',['一个']='一个大壁兜:BAAAKgAECggICAAAAA==.',['一书']='一书术:BAAAKgAECgcICgAAAA==.',['一只']='一只喵喵:BAAAKgADCgIIAgAAAA==.一只小奶龙:BAAAKgADCggICAAAAA==.一只小白羊:BAAAKgADCggICAAAAA==.',['一嗜']='一嗜血颓废一:BAAAKgAECgcIBwAAAA==.',['一股']='一股蛋蛋伤:BAABKgAFFH8JAAMEAAUIDw+8KwC0AAAEAAQI1xC8KwC0AAANAAEIuQldFQBEAAAAAA==.',['一荔']='一荔蛋:BAAAKgAFFAEIAQAAAA==.',['一见']='一见发财:BAAAKgAECgEIAQAAAA==.',['一速']='一速度灭了一:BAAAKgAECgEIAQAAAA==.',['七月']='七月在宇:BAACKgAFFH8TAAINAAMIXR4RDQD+AAANAAMIXR4RDQD+AAAqAAQKfzgAAg0ACAjqI+YGAL4CAA0ACAjqI+YGAL4CAAAA.',['万事']='万事兴:BAAAKgAECgIIAgAAAA==.',['万箭']='万箭穿心:BAAAKgAECgUIBAAAAA==.',['三个']='三个小称呼:BAAAKgAECgEIAgAAAA==.',['三九']='三九小技师:BAAAKgAECgUIBQAAAA==.',['三月']='三月轻歌:BAABKgAFFH8FAAIHAAMIjAYSHgCiAAAHAAMIjAYSHgCiAAAAAA==.',['不再']='不再流浪:BAABKgAFFH8HAAIOAAMIGxUEGgCyAAAOAAMIGxUEGgCyAAAAAA==.',['不喝']='不喝酒的猫鱼:BAAAKgAECgEIAQAAAA==.',['不渡']='不渡:BAAAKgAFFAIIAgAAAA==.',['东拉']='东拉灬西扯:BAAAKgAFFAQIBAAAAA==.',['东方']='东方翠花:BAAAKgAECggICAAAAA==.',['丝般']='丝般顺滑:BAAAKgAECgYIBgAAAA==.',['丨丶']='丨丶笑灬菇冫:BAAAKgAECgIIAwAAAA==.丨丶迈朦嘚儿:BAAAKgAECggICwAAAA==.',['丨月']='丨月黑之时丨:BAAAKgAFFAYIAgAAAA==.丨月黑風高丨:BAAAKgADCggICAAAAA==.',['丨水']='丨水火丨:BAAAKgADCgEIAQAAAA==.',['丨無']='丨無鋒丨:BAABKgAFFH8GAAIOAAYIZxfXDQB1AQAOAAYIZxfXDQB1AQAAAA==.',['丨骑']='丨骑马过海丨:BAAAKgAFFAQIAwAAAA==.',['丰收']='丰收的旋律:BAAAKgAECgYIBQAAAA==.',['丶兰']='丶兰斯洛特:BAABKgAFFH8KAAIDAAYItRs0FQCyAQADAAYItRs0FQCyAQAAAA==.',['丶恩']='丶恩静:BAAAKgAECgIIAgAAAA==.',['丶榷']='丶榷丶:BAAAKgAFFAEIAQAAAA==.',['举长']='举长矢射天狼:BAAAKgAECgYIDwAAAA==.',['丿夜']='丿夜丶激光:BAAAKgAECgUIBQAAAA==.',['乀吪']='乀吪蠱聾:BAABKgAFFH8SAAIHAAMIQwqEMwCyAAAHAAMIQwqEMwCyAAAAAA==.',['乌瑞']='乌瑞恩之剑:BAAAKgAECgYIBwAAAA==.',['乐乐']='乐乐茶:BAABKgAFFH8IAAIDAAgI0QR1EQCIAQADAAgI0QR1EQCIAQAAAA==.',['九个']='九个半:BAAAKgAECgEIAQAAAA==.',['九如']='九如:BAAAKgAECggICAAAAA==.',['乡秀']='乡秀树:BAABKgAFFH8LAAIGAAQIswr7PQCxAAAGAAQIswr7PQCxAAAAAA==.',['买保']='买保险:BAAAKgAECgYIBgAAAA==.',['乾坤']='乾坤冰法:BAAAKgAECgMIAwAAAA==.',['二宝']='二宝丫:BAAAKgADCggICAAAAA==.',['云也']='云也闲闲:BAAAKgAECgQIAQAAAA==.',['亓暃']='亓暃:BAABKgAFFH8GAAIDAAYIBBkBHQB/AQADAAYIBBkBHQB/AQABKgAFFAgIDAADABAkAA==.',['五晨']='五晨寺碎奶掌:BAACKgAFFH8KAAMPAAUIrRFADQAHAQAPAAQIrRFADQAHAQAKAAEIAABINwAAAAAqAAQKfyMAAg8ACAi9IPILAG8CAA8ACAi9IPILAG8CAAAA.',['今天']='今天不知道:BAAAKgAECgYIDQAAAA==.',['以先']='以先无:BAABKgAECn8gAAICAAgI1hbyRgDgAQACAAgI1hbyRgDgAQAAAA==.',['伊利']='伊利瑞达:BAAAKgADCgMIAwAAAA==.',['伊唎']='伊唎丹丶怒风:BAAAKgADCggICAAAAA==.',['伊泽']='伊泽贝尔:BAAAKgADCgEIAQAAAA==.',['伊璞']='伊璞哒啦:BAABKgAFFH8IAAMBAAQIuBBREQDSAAABAAQIuBBREQDSAAACAAIIewqRPQB1AAAAAA==.',['伊魅']='伊魅儿:BAAAKgADCgcIBwAAAA==.',['传说']='传说中的凤梨:BAAAKgAFFAQIBAAAAA==.',['低保']='低保克星:BAAAKgADCggICAAAAA==.',['你条']='你条粉肠:BAABKgAFFH8RAAICAAMITgy0NwC4AAACAAMITgy0NwC4AAAAAA==.',['佰晓']='佰晓生:BAAAKgAFFAYIAgABKgAFFAgILgAQAO0iAA==.',['保卫']='保卫萝卜二:BAAAKgADCgYIBgAAAA==.',['偷月']='偷月亮的猫:BAAAKgAFFAIIAgAAAA==.',['八意']='八意永琳:BAACKgAFFH8tAAQRAAgIcRq2CwBpAQARAAgIcRq2CwBpAQAQAAMIdw1ZDgDPAAASAAQI3hXiJACNAAAqAAQKfyYAAxEACAipIf8NAGQCABEACAipIf8NAGQCABIABgi6FowwAGIBAAAA.',['兽中']='兽中之龙:BAAAKgADCgYIBgAAAA==.',['农大']='农大老兽医:BAACKgAFFH8JAAMGAAMI2gPJTACBAAAGAAMI2gPJTACBAAATAAII1gYFHABoAAAqAAQKfx0AAwYACAjoEWlAALQBAAYACAjoEWlAALQBABMAAwgeBwxsAHIAAAAA.',['冬天']='冬天冷水脸:BAAAKgAECgQIBAAAAA==.',['冰月']='冰月大祭司:BAAAKgAECgUIBQAAAA==.冰月小牧:BAAAKgAECgUIBAAAAA==.',['冰火']='冰火香槟:BAAAKgADCgQIBAAAAA==.',['冷猫']='冷猫:BAABKgAFFH8HAAMUAAQIIQT+CQCKAAAUAAQIEQT+CQCKAAAGAAMIhwKaTwB3AAAAAA==.',['冷语']='冷语晨:BAAAKgADCgMIAwAAAA==.',['冷酷']='冷酷霸道总裁:BAABKgAFFH8GAAMNAAMItRf4FADDAAANAAMItRf4FADDAAAEAAEIRQUdSAAxAAAAAA==.',['凌度']='凌度丶心寒:BAACKgAFFH8ZAAIJAAUIVRi5IgDtAAAJAAUIVRi5IgDtAAAqAAQKfxYAAgkACAglFXVAAIQBAAkACAglFXVAAIQBAAAA.',['凌风']='凌风踏月:BAABKgAFFH8GAAMVAAYItQgBPQB7AAAVAAUIcQgBPQB7AAAWAAEIyAkyLABCAAAAAA==.',['凍結']='凍結乂伈:BAAAKgAECgIIAgAAAA==.',['凨舞']='凨舞九天:BAAAKgAFFAYIAgAAAA==.',['凭神']='凭神史凯斯:BAABKgAFFH8GAAIXAAYIRh7pAADlAQAXAAYIRh7pAADlAQAAAA==.',['出门']='出门不带油:BAAAKgAFFAgIBAAAAA==.',['刑天']='刑天之萨:BAAAKgAFFAgIAQAAAA==.',['划破']='划破黑暗:BAAAKgAECgcICwAAAA==.',['利物']='利物浦是冠军:BAAAKgAECggICAAAAA==.',['削肾']='削肾客的舅叔:BAABKgAFFH8GAAIYAAYIiRA9GABbAQAYAAYIiRA9GABbAQAAAA==.',['剑刃']='剑刃华尔兹:BAABKgAFFH8IAAIZAAIIIBKMCACBAAAZAAIIIBKMCACBAAAAAA==.',['剥开']='剥开插入:BAAAKgAECgIIAgAAAA==.',['加减']='加减法:BAAAKgADCggICAAAAA==.',['加勒']='加勒比海茸:BAAAKgAECggIDAAAAA==.',['劳资']='劳资蜀道山:BAAAKgAFFAQIBAAAAA==.',['勉强']='勉强算强力:BAABKgAFFH8GAAIGAAYI7BOIGQBNAQAGAAYI7BOIGQBNAQAAAA==.',['十丶']='十丶月:BAAAKgADCgQIAgAAAA==.',['十二']='十二章纹:BAABKgAFFH8IAAISAAgISAQBBwAtAQASAAgISAQBBwAtAQAAAA==.',['十八']='十八降龙:BAAAKgAECgcIBQAAAA==.',['十月']='十月悲鸣:BAAAKgADCgUIBgAAAA==.',['十灵']='十灵猎十:BAAAKgADCgMIAwAAAA==.',['十里']='十里春风朝歌:BAAAKgAECgIIAgAAAA==.',['午夜']='午夜圣光:BAAAKgAFFAgIBAAAAA==.',['半点']='半点点儿:BAAAKgADCgYIBgAAAA==.',['半路']='半路的信仰:BAAAKgAECgEIAQAAAA==.',['华笙']='华笙:BAACKgAFFH8YAAMBAAYIARqGEQBYAQABAAYIgxmGEQBYAQACAAQInRg0GgDqAAAqAAQKf0kAAwIACAjHI+wFALYCAAIACAjlIewFALYCAAEACAjnIg4LAKUCAAAA.',['卖面']='卖面包:BAAAKgADCggIDwAAAA==.',['南北']='南北:BAACKgAFFH8GAAIGAAYIZgzJPwCsAAAGAAYIZgzJPwCsAAAqAAQKfxQAAgYABwhAEpVXAFUBAAYABwhAEpVXAFUBAAAA.',['南宫']='南宫魅:BAABKgAFFH8IAAIOAAYIJBfDCwCPAQAOAAYIJBfDCwCPAQAAAA==.',['卡皮']='卡皮巴拉:BAABKgAECn8VAAIJAAgIrQV3fADPAAAJAAgIrQV3fADPAAAAAA==.',['厄运']='厄运不死鸟:BAAAKgAECgUICAAAAA==.',['去河']='去河边:BAAAKgADCggICAAAAA==.',['友情']='友情爱神:BAAAKgAECggIEQAAAA==.',['双狙']='双狙人:BAAAKgAECgUIBQAAAA==.',['变异']='变异零零漆:BAAAKgAECggIDAAAAA==.',['只会']='只会这个:BAAAKgAECgEIAQAAAA==.',['只喝']='只喝绿茶:BAAAKgADCgEIAQAAAA==.',['只是']='只是当下:BAAAKgAECggICAAAAA==.',['叫卬']='叫卬叩吧:BAAAKgAECgMIAwAAAA==.',['吉普']='吉普赛梅梅:BAAAKgAECgMIAwAAAA==.',['名人']='名人熊:BAABKgAECn87AAIaAAgIlBuwCQAWAgAaAAgIlBuwCQAWAgAAAA==.名人虾:BAABKgAECn9FAAIbAAgIGBv3EAANAgAbAAgIGBv3EAANAgAAAA==.',['君当']='君当如兰:BAAAKgAECgMIAgAAAA==.',['君王']='君王死社稷:BAAAKgAECgEIAQAAAA==.',['吾小']='吾小娘:BAAAKgAFFAgIBAAAAA==.',['呆那']='呆那盖杯:BAAAKgAECgcIBwAAAA==.',['呜喵']='呜喵王怕不怕:BAAAKgAECgIIAgAAAA==.',['周圣']='周圣盟:BAABKgAFFH8GAAIGAAYILxkgDQCoAQAGAAYILxkgDQCoAQABKgAFFAgIDAAGAHMZAA==.',['咖喱']='咖喱鱼蛋:BAAAKgAFFAMIBAAAAA==.',['咸柠']='咸柠七:BAAAKgADCgUIBQAAAA==.',['哇卡']='哇卡哇卡:BAAAKgAFFAQIAgAAAA==.',['哇哇']='哇哇叫丶:BAAAKgADCgYIBgAAAA==.',['哈斯']='哈斯卡西:BAAAKgADCggICAAAAA==.',['唉呀']='唉呀哑吖:BAAAKgAECggICAAAAA==.',['啁芯']='啁芯潍爰:BAAAKgAECgQIBAAAAA==.',['啊哇']='啊哇哇:BAAAKgADCggICAAAAA==.',['啥子']='啥子鸡龟鸟人:BAABKgAFFH8GAAIGAAYI6xknFAB6AQAGAAYI6xknFAB6AQAAAA==.',['啸天']='啸天虎:BAAAKgAECgEIAQAAAA==.',['喝奶']='喝奶茶高手:BAABKgAFFH8GAAIEAAMIlwM1IQB6AAAEAAMIlwM1IQB6AAAAAA==.',['喵尛']='喵尛檬丶:BAABKgAFFH8FAAIDAAUImhtlMAAnAQADAAUImhtlMAAnAQAAAA==.',['嗨呀']='嗨呀好气啊:BAAAKgADCgYIBgAAAA==.',['噬神']='噬神者丶:BAABKgAECn8VAAIDAAgIBiPGLABMAgADAAgIBiPGLABMAgAAAA==.',['嚣张']='嚣张的傻笑:BAAAKgAECgUIBQAAAA==.',['回家']='回家写作业:BAAAKgADCgUIBQAAAA==.',['回眸']='回眸乂笑:BAAAKgADCggICAAAAA==.',['困境']='困境中存善念:BAAAKgAECggICwAAAA==.',['圣丶']='圣丶光:BAAAKgADCgEIAQAAAA==.',['圣光']='圣光之誓:BAAAKgAECggICAAAAA==.圣光喵:BAAAKgADCgYIBgAAAA==.',['圣骑']='圣骑静静:BAAAKgAECggICAAAAA==.',['地心']='地心之战:BAABKgAFFH8MAAIOAAMIDAG7MwBWAAAOAAMIDAG7MwBWAAAAAA==.',['坊屋']='坊屋春道丶:BAABKgAFFH8OAAMMAAgIsB4gBQD0AQAMAAgILBogBQD0AQAYAAQIbRw/DQAGAQAAAA==.',['坏菠']='坏菠萝:BAAAKgAECgEIAQAAAA==.',['基督']='基督山女爵:BAAAKgAECggICgAAAA==.',['堕落']='堕落人煌:BAAAKgAECgYIBgAAAA==.堕落的鬼王:BAAAKgAECgEIAQAAAA==.',['堤里']='堤里奥丶佛丁:BAAAKgAECgMIBgAAAA==.',['墨香']='墨香淡韵:BAAAKgAFFAIIAwAAAA==.',['夏一']='夏一可的黄瓜:BAAAKgAFFAQIBAAAAA==.',['夜影']='夜影怒风:BAAAKgAFFAgIAQAAAA==.',['大哀']='大哀木涕:BAAAKgADCggICAAAAA==.',['大圣']='大圣光:BAAAKgAFFAMIAwAAAA==.',['大孝']='大孝子:BAAAKgAFFAgIBAAAAA==.',['大山']='大山羊小山羊:BAAAKgAECggIEQAAAA==.',['大扑']='大扑棱蛾子:BAABKgAFFH8JAAIHAAMIJRtgJgDeAAAHAAMIJRtgJgDeAAAAAA==.',['大耳']='大耳狂徒贼:BAABKgAFFH8OAAIXAAYIwhn8CgCcAQAXAAYIwhn8CgCcAQAAAA==.',['天堂']='天堂烤鸭:BAAAKgAFFAIIAgAAAA==.',['奥蕾']='奥蕾萨风行者:BAAAKgADCgEIAQAAAA==.',['女巫']='女巫梅丽珊:BAABKgAECn8jAAIGAAgIUhrZMwDbAQAGAAgIUhrZMwDbAQAAAA==.',['女王']='女王圣斗士:BAAAKgAFFAQIAgABKgAFFAgICAADAEIaAA==.',['奶油']='奶油白杏仁:BAAAKgADCggICAAAAA==.',['如萊']='如萊佛:BAAAKgAFFAQIBAABKgAFFAcIBwAPANoVAA==.',['妃孓']='妃孓:BAAAKgADCgYIBgAAAA==.',['妖艳']='妖艳的不羁:BAAAKgAFFAYIBAAAAA==.',['嫟洺']='嫟洺哋寶赑:BAAAKgAECgQICAAAAA==.',['孝死']='孝死我了:BAABKgAFFH8IAAMcAAgI1QaRAwALAQAcAAQIcAaRAwALAQALAAQI9x7RGwDhAAAAAA==.',['宝宝']='宝宝瀦:BAAAKgAFFAIIAwABKgAFFAgICAAEALoSAA==.',['宫子']='宫子煜:BAAAKgADCgEIAQAAAA==.',['家属']='家属谢礼奶:BAACKgAFFH8HAAMIAAQIXQznEgC/AAAIAAQIXQznEgC/AAAJAAEIDAZHNwA3AAAqAAQKfxoAAwgACAjPF+IZAPsBAAgACAjPF+IZAPsBAAkABAiKFJhzAOgAAAAA.',['家有']='家有一包:BAABKgAFFH8OAAQYAAYIXhOtCAAlAQAYAAYIpQutCAAlAQAdAAQIVRdpAgABAQAMAAQIPwaDKwBnAAAAAA==.',['寂寞']='寂寞冷:BAAAKgADCgQIBAAAAA==.',['寂静']='寂静安然:BAAAKgAECgMIAwAAAA==.',['寅丸']='寅丸星:BAABKgAFFH8IAAMGAAYIXBWEEgCIAQAGAAYIXBWEEgCIAQATAAIIehHgIwCWAAAAAA==.',['寒山']='寒山破碎:BAABKgAFFH8GAAIYAAYIByD1DgCqAQAYAAYIByD1DgCqAQAAAA==.',['寳貝']='寳貝爱夢夢:BAAAKgAFFAgIBAAAAA==.',['寶赑']='寶赑囡囡:BAABKgAFFH8UAAQVAAYIpB6LDQC0AQAVAAYIpB6LDQC0AQAWAAMIDRJuFgCUAAAeAAQI7wXtIgBCAAAAAA==.',['小七']='小七的痛:BAAAKgAFFAgIAgAAAA==.',['小人']='小人物:BAAAKgAECgcIDQAAAA==.',['小夜']='小夜风雨:BAAAKgAECgEIAQAAAA==.',['小天']='小天使的宠物:BAAAKgAECggICAAAAA==.',['小小']='小小咪德:BAAAKgAECgMIAwAAAA==.',['小尛']='小尛僧:BAAAKgAECgIIAgAAAA==.',['小扶']='小扶兮:BAABKgAFFH8FAAIJAAUItQ5JHQAIAQAJAAUItQ5JHQAIAQAAAA==.',['小泽']='小泽乂沫宇:BAAAKgADCgQIBAAAAA==.',['小灬']='小灬猎:BAAAKgADCggICAAAAA==.小灬萨:BAAAKgADCggICAAAAA==.',['小灰']='小灰狼:BAAAKgADCggICAAAAA==.',['小牛']='小牛咯:BAAAKgADCgEIAQAAAA==.小牛行者:BAAAKgAECgMIAwAAAA==.小牛额:BAAAKgADCgQIBAAAAA==.',['小红']='小红巾冒:BAAAKgAFFAEIAQAAAA==.',['小菲']='小菲雪儿:BAAAKgAFFAQIBAAAAA==.',['小蓝']='小蓝瓶:BAAAKgAECggICQAAAA==.',['小角']='小角色灬勥:BAAAKgAECgQIBwAAAA==.',['小资']='小资朝花夕拾:BAABKgAFFH8IAAMCAAYI1hdQEwBbAQACAAYI1hdQEwBbAQABAAIIDxQnOgCPAAAAAA==.小资风驰电掣:BAAAKgAECgcIBwAAAA==.',['小软']='小软害你呦:BAAAKgAFFAEIAgAAAA==.小软爱你忧:BAAAKgADCgcIBwAAAA==.',['小辣']='小辣椒:BAAAKgAECgYIBgAAAA==.',['小野']='小野人鱼控:BAAAKgAFFAIIAgAAAA==.',['小鱼']='小鱼干:BAABKgAECn8XAAIfAAYIYhnFHgBqAQAfAAYIYhnFHgBqAQAAAA==.',['尘之']='尘之念一:BAACKgAFFH8TAAIRAAQI7h8fBgAKAQARAAQI7h8fBgAKAQAqAAQKfyEAAhEACAh5ICAYABMCABEACAh5ICAYABMCAAAA.',['岩焚']='岩焚雷殛:BAAAKgAFFAEIAQAAAA==.',['布兜']='布兜里有馒头:BAACKgAFFH8SAAIRAAQIVBy1HQDUAAARAAQIVBy1HQDUAAAqAAQKfx8AAxEACAiMInwbAPsBABEACAiMInwbAPsBABIAAwiKBzB8AFwAAAAA.',['布拉']='布拉格的皮特:BAAAKgADCgIIAgAAAA==.',['帅哥']='帅哥不烂:BAAAKgAFFAEIAQAAAA==.',['希崎']='希崎杰西卡:BAAAKgADCggICgAAAA==.',['幻彩']='幻彩新生:BAAAKgADCgQIBAAAAA==.',['幻想']='幻想玄天:BAAAKgAFFAEIAgAAAA==.幻想玄舞:BAAAKgAECgMICAAAAA==.幻想玄黄:BAAAKgAECgIIAgAAAA==.',['幻觉']='幻觉:BAAAKgAECgEIAQAAAA==.',['庄生']='庄生夢蝶:BAAAKgAECgcIBwAAAA==.',['康桑']='康桑阿密达:BAAAKgAECggIBgAAAA==.',['廣崬']='廣崬什苦:BAABKgAFFH8KAAIDAAMIaQeqYwCoAAADAAMIaQeqYwCoAAAAAA==.',['弃剑']='弃剑封刀:BAABKgAECn8UAAMCAAgI2w1KJQBPAQACAAgItQ1KJQBPAQABAAYI/wY0fQCEAAAAAA==.',['弇山']='弇山胡髯郎:BAABKgAFFH8OAAIPAAgIHxrVAAAHAgAPAAgIHxrVAAAHAgAAAA==.',['御寒']='御寒:BAAAKgAECgUIBwAAAA==.',['御用']='御用萝莉:BAAAKgAECgYICgAAAA==.',['微风']='微风的呢喃:BAAAKgAECgIIAgAAAA==.',['德高']='德高望中:BAAAKgAECgcIEQAAAA==.',['心城']='心城:BAAAKgAECgMIAwAAAA==.',['必须']='必须休闲:BAAAKgAECgEIAQAAAA==.必须小萨:BAABKgAECn8WAAMJAAgIYhL0WAAgAQAJAAgIYhL0WAAgAQAgAAEItgrsewAoAAAAAA==.必须爆:BAABKgAFFH8MAAIOAAgIFxksAwCGAgAOAAgIFxksAwCGAgAAAA==.必须爆的影子:BAAAKgAFFAMIAwAAAA==.必须的必:BAABKgAECn8VAAMCAAgI+hhkOgC7AQACAAgIRRZkOgC7AQABAAcIjxEDRQAMAQAAAA==.必须的必须:BAABKgAECn8WAAIHAAgIMxvZIAD+AQAHAAgIMxvZIAD+AQAAAA==.必须知道:BAACKgAFFH8KAAIDAAMITA81JwDKAAADAAMITA81JwDKAAAqAAQKfxUAAgMACAj4HaMnAGECAAMACAj4HaMnAGECAAAA.',['忧忧']='忧忧郁郁:BAAAKgAECgEIAQAAAA==.',['忧郁']='忧郁滴柚子:BAAAKgADCgYIBgAAAA==.忧郁滴萝卜:BAAAKgADCgcIBwAAAA==.',['快出']='快出火箭十九:BAAAKgAFFAIIAgAAAA==.',['念宝']='念宝睡不醒:BAAAKgAECggICAAAAA==.',['怀念']='怀念丶而已:BAAAKgADCggICAAAAA==.',['怒怒']='怒怒海马獭人:BAAAKgAECgYIEwAAAA==.',['怒海']='怒海狂花:BAAAKgAECgQIBAAAAA==.',['性感']='性感尐嘢豹:BAAAKgAECgEIAQAAAA==.',['总监']='总监:BAAAKgADCgMIAwAAAA==.',['恶魔']='恶魔夜想曲:BAAAKgAECgQICAAAAA==.',['愤怒']='愤怒的小学生:BAABKgAFFH8KAAIGAAYIfhwmFQBwAQAGAAYIfhwmFQBwAQAAAA==.愤怒的黑煤球:BAAAKgAECgIIAgAAAA==.',['愤愤']='愤愤的咖喱:BAACKgAFFH8GAAIBAAMIUQxONQCeAAABAAMIUQxONQCeAAAqAAQKfxgAAgEACAhyGwQjAOsBAAEACAhyGwQjAOsBAAAA.',['慕瞳']='慕瞳:BAAAKgAECggICAAAAA==.',['我不']='我不会复活:BAAAKgAECggIDgAAAA==.',['我会']='我会乖乖的:BAAAKgAECgQICQAAAA==.',['我是']='我是个尸体:BAAAKgADCggICAAAAA==.',['我的']='我的最好的:BAAAKgADCgEIAQAAAA==.',['我瞎']='我瞎砍:BAAAKgAECgMIBgAAAA==.',['我舞']='我舞零乱:BAAAKgADCgcIDwAAAA==.',['戒灬']='戒灬链:BAAAKgAECgEIAQAAAA==.',['戦武']='戦武:BAAAKgADCgUIBQAAAA==.',['戰灬']='戰灬无极:BAAAKgAECgUIBQAAAA==.',['手抖']='手抖的木木:BAAAKgADCggICAAAAA==.',['打不']='打不过就跪:BAABKgAECn8YAAIOAAgIsg/yNwBEAQAOAAgIsg/yNwBEAQAAAA==.',['打得']='打得你作猪叫:BAABKgAFFH8QAAIBAAMIYB2AIwDhAAABAAMIYB2AIwDhAAAAAA==.',['打酱']='打酱油的白牛:BAAAKgAECgMIAwAAAA==.',['扳手']='扳手斯蒂夫:BAAAKgAECgUIBQAAAA==.',['抠脚']='抠脚脚:BAABKgAFFH8IAAIGAAgIuwyOCgDnAQAGAAgIuwyOCgDnAQAAAA==.',['拉臭']='拉臭臭:BAAAKgAFFAQIBAAAAA==.',['拖拉']='拖拉机简史:BAAAKgAECgYICgAAAA==.',['指尖']='指尖丨熏韵:BAAAKgAECgMIAwAAAA==.',['挖煤']='挖煤工:BAAAKgADCgIIAgAAAA==.',['掉下']='掉下个林妹妹:BAAAKgAECgEIAQAAAA==.',['排除']='排除寂寞游戏:BAAAKgADCggICAAAAA==.',['推荐']='推荐一日游:BAAAKgAFFAMIAwAAAA==.',['提神']='提神姐姐:BAAAKgAECggIEAAAAA==.',['搞个']='搞个毛新闻:BAAAKgADCggICAAAAA==.',['搞完']='搞完疼:BAAAKgAECggICwAAAA==.',['撸你']='撸你没商量:BAAAKgAECgUIBQAAAA==.',['教你']='教你做人:BAABKgAFFH8FAAIMAAUI/g5EFAD/AAAMAAUI/g5EFAD/AAAAAA==.',['文明']='文明治疗:BAAAKgAFFAEIAQAAAA==.',['文青']='文青翘楚丶:BAAAKgAECgcIBwAAAA==.',['斗转']='斗转星移:BAAAKgAECgcIBgAAAA==.',['新巴']='新巴唧:BAABKgAFFH8MAAMCAAQIxxLbHADiAAACAAQIxxLbHADiAAABAAQI/gtJEgDMAAAAAA==.',['旅行']='旅行精灵:BAABKgAFFH8SAAMCAAQIWiDoIQADAQACAAQIWiDoIQADAQABAAEIvhh4JABPAAAAAA==.',['无双']='无双贼:BAAAKgAECgMIAwAAAA==.',['无名']='无名流浪者:BAAAKgAECgYIBgAAAA==.',['无知']='无知跳下水:BAAAKgAECgcICAAAAA==.',['无聊']='无聊的盘龙:BAAAKgADCgIIAgAAAA==.',['星星']='星星河:BAAAKgAECgQIBAAAAA==.',['星露']='星露谷大王:BAABKgAFFH8MAAIVAAgIQxlYBQBEAgAVAAgIQxlYBQBEAgAAAA==.',['春之']='春之祭:BAAAKgAECgEIAQAAAA==.',['是小']='是小狸花:BAAAKgAFFAUIBAAAAA==.',['昵称']='昵称无法复制:BAAAKgAECgUIBQAAAA==.',['显卡']='显卡炸裂:BAAAKgAECgMIAwAAAA==.',['晓晓']='晓晓德:BAAAKgAFFAIIAgAAAA==.',['普莱']='普莱尔:BAAAKgADCgMIAwAAAA==.',['暖夏']='暖夏微凉丷:BAAAKgADCgIIAgAAAA==.',['暗夜']='暗夜之击:BAAAKgAECgcIDAAAAA==.',['暮酒']='暮酒:BAAAKgADCggICAAAAA==.',['有毒']='有毒:BAAAKgADCggIEAAAAA==.',['朕蛊']='朕蛊暗魔:BAABKgAECn8gAAMWAAgIsxNpCQCrAQAWAAgINBNpCQCrAQAVAAEIEA6tRwAsAAAAAA==.',['木子']='木子小小:BAABKgAFFH8OAAMGAAMILQkXHgDFAAAGAAMILQkXHgDFAAATAAMIEgkAJwCJAAAAAA==.',['木法']='木法沙大魔王:BAAAKgADCgMIAwAAAA==.',['术爷']='术爷:BAAAKgAECgMIAwAAAA==.',['杀十']='杀十分大:BAAAKgAECggICgAAAA==.',['权法']='权法:BAAAKgADCgMIAwAAAA==.',['李德']='李德屏:BAAAKgAECggIDgAAAA==.',['李扯']='李扯火:BAABKgAFFH8MAAICAAYIwyFNCgDKAQACAAYIwyFNCgDKAQAAAA==.',['李湿']='李湿湿:BAAAKgAECggICgAAAA==.',['李老']='李老八:BAABKgAFFH8HAAIhAAcI4ARhBgBkAQAhAAcI4ARhBgBkAQAAAA==.',['某人']='某人的圣光:BAAAKgAFFAEIAQAAAA==.',['柳如']='柳如烟:BAABKgAFFH8FAAILAAQIQCB4GAABAQALAAQIQCB4GAABAQAAAA==.',['桂花']='桂花栗子酥:BAAAKgADCgEIAQAAAA==.',['桃花']='桃花变狐狸:BAAAKgAECggICAAAAA==.',['梅陇']='梅陇法:BAAAKgAFFAEIAQAAAA==.',['梦娘']='梦娘:BAAAKgADCgcIBwAAAA==.',['森下']='森下:BAAAKgAFFAEIAQAAAA==.',['椰子']='椰子爸爸:BAABKgAFFH8GAAIJAAYIsB6NCAC+AQAJAAYIsB6NCAC+AQAAAA==.',['楚雨']='楚雨荨:BAAAKgAECggICwAAAA==.',['榆落']='榆落黄昏:BAAAKgADCgQIBAAAAA==.',['槟榔']='槟榔配酒:BAAAKgAECgUIBQAAAA==.',['樊薏']='樊薏璇:BAABKgAFFH8IAAIPAAgIHRA6BAAUAgAPAAgIHRA6BAAUAgAAAA==.',['樱桃']='樱桃老丸子:BAAAKgAECgUIBQAAAA==.',['欢欢']='欢欢的烩面:BAAAKgAECgMIAwAAAA==.欢欢老师:BAAAKgAECgYIDQAAAA==.',['欧豆']='欧豆豆:BAAAKgADCggICAAAAA==.',['歌舞']='歌舞伎町女王:BAABKgAFFH8FAAIVAAUIACLVDgChAQAVAAUIACLVDgChAQAAAA==.',['正宫']='正宫南宫婉:BAAAKgAECgQICgAAAA==.',['正式']='正式老方:BAAAKgAECgEIAQAAAA==.',['死温']='死温商丶:BAAAKgADCgQIBAAAAA==.',['死灵']='死灵圣法:BAAAKgAFFAQIAgAAAA==.',['毛托']='毛托:BAAAKgADCgEIAwAAAA==.',['水萨']='水萨:BAAAKgADCgUIBQAAAA==.',['水蓝']='水蓝姬:BAAAKgAECgIIAgAAAA==.水蓝姬韵:BAAAKgAFFAMIAwAAAA==.',['水谷']='水谷雫:BAAAKgAECgMIAwAAAA==.',['水路']='水路十八弯:BAABKgAFFH8GAAIDAAMIrh3bNwAMAQADAAMIrh3bNwAMAQAAAA==.',['水骑']='水骑:BAAAKgAECgYIBgAAAA==.',['永远']='永远的久远:BAABKgAFFH8SAAMEAAQIhxQaJwDGAAAEAAQIhxQaJwDGAAANAAEIgwHfJQAjAAAAAA==.',['汝来']='汝来佛:BAABKgAFFH8HAAIPAAcI2hXzBADvAQAPAAcI2hXzBADvAQAAAA==.',['汝知']='汝知安利否:BAAAKgAECggIDwAAAA==.',['沙罗']='沙罗:BAABKgAFFH8IAAIQAAgIRgFLDgDQAAAQAAgIRgFLDgDQAAAAAA==.',['没医']='没医保你先上:BAAAKgAECgQIBQAAAA==.',['没奶']='没奶吃汤圆丶:BAAAKgAECgUIBQAAAA==.',['河坝']='河坝边:BAAAKgAECgYIBgAAAA==.',['法力']='法力值已耗尽:BAABKgAFFH8KAAMSAAYILBf3DwDaAAASAAYIRRT3DwDaAAARAAQIpApNEQC3AAAAAA==.',['法神']='法神天才:BAAAKgAECgUIBQAAAA==.',['泥鸽']='泥鸽歧视:BAAAKgAECgIIAgABKgAFFAgICwANAFkYAA==.',['泰兰']='泰兰徳丶语風:BAAAKgADCgIIAgAAAA==.',['泰熊']='泰熊眼罩妹:BAAAKgAECggIEAAAAA==.',['洋芋']='洋芋泡泡:BAAAKgADCgUIBQAAAA==.',['洛兒']='洛兒:BAAAKgADCggIDwAAAA==.',['洛拿']='洛拿特谢兰冰:BAAAKgAFFAQIBAAAAA==.',['流星']='流星乱坠:BAAAKgAECgQIBAAAAA==.',['浮生']='浮生若梦:BAAAKgADCgcIBwAAAA==.',['海芋']='海芋:BAAAKgADCggICAAAAA==.',['涡阳']='涡阳彭于晏:BAAAKgAECgcIEQAAAA==.',['淡寞']='淡寞如煙:BAAAKgAECgQIBAAAAA==.',['深度']='深度套牢牛:BAABKgAECn8XAAMJAAgIuRlFMQCzAQAJAAcI9BlFMQCzAQAgAAEIqQMHgQAaAAAAAA==.',['清香']='清香芝步:BAAAKgADCgQIBAAAAA==.',['渊鸿']='渊鸿:BAAAKgADCggICAAAAA==.',['滑翔']='滑翔机:BAAAKgAFFAIIBAAAAA==.',['漠漠']='漠漠烟如织:BAAAKgADCgEIAQAAAA==.',['潇洒']='潇洒乂戈:BAAAKgAFFAEIAQAAAA==.',['潇湘']='潇湘风雨情:BAAAKgADCgEIAQAAAA==.',['潋滟']='潋滟沧行:BAABKgAFFH8GAAMDAAUIURtYDAAjAQADAAQIRCJYDAAjAQAiAAIIeQYZKwA2AAABKgAFFAgIDAAOACQaAA==.',['瀚海']='瀚海万丈冰:BAAAKgAECgQIBAAAAA==.',['瀟灑']='瀟灑鄒蘙獩:BAAAKgAFFAEIAgAAAA==.',['灬亓']='灬亓柒柒:BAAAKgAECgEIAQAAAA==.',['灬十']='灬十方俱生灬:BAABKgAFFH8GAAIOAAYIlwygEABLAQAOAAYIlwygEABLAQAAAA==.',['灬淋']='灬淋灬:BAABKgAFFH8FAAMBAAMIEgUxSgBXAAABAAIIvAMxSgBXAAACAAEIvQdpYAA1AAAAAA==.',['灬黑']='灬黑黫灬:BAAAKgAECgYIBgAAAA==.',['灵梦']='灵梦的裹胸布:BAAAKgAECgMIAwAAAA==.',['灵魂']='灵魂裁决者:BAABKgAFFH8GAAIDAAYI4xZjHwBzAQADAAYI4xZjHwBzAQAAAA==.',['烬松']='烬松十人众:BAAAKgADCgIIAgAAAA==.',['無心']='無心之妄:BAAAKgAECgUIBQAAAA==.',['焰烙']='焰烙漫天:BAABKgAFFH8GAAMWAAYIDBShBQAeAQAWAAUIvRehBQAeAQAVAAEISAVlTAA9AAAAAA==.',['熏鸡']='熏鸡图腾:BAAAKgADCgMIAwAAAA==.',['爱护']='爱护花草:BAAAKgADCggICAAAAA==.',['爷得']='爷得狂猫病:BAAAKgAECgUIBQAAAA==.',['爸迪']='爸迪的小果果:BAAAKgAFFAEIAQAAAA==.',['牙医']='牙医:BAAAKgAECggIAgAAAA==.',['牛十']='牛十三:BAABKgAFFH8IAAIJAAQIIhRaGgClAAAJAAQIIhRaGgClAAAAAA==.',['牛奔']='牛奔奔:BAAAKgAECgYICgAAAA==.',['特高']='特高压:BAAAKgAECgMIAwAAAA==.',['犭一']='犭一拳超人丶:BAAAKgAFFAYIBAABKgAFFAgIBAAjAAAAAA==.',['狂奔']='狂奔的蛋卷:BAACKgAFFH8eAAMWAAcIVxBbBQAiAQAWAAUI7xRbBQAiAQAVAAUIUg4aIQD/AAAqAAQKfysAAxUACAhyH4kPAG4CABUACAigHokPAG4CABYAAwilFqZcAIIAAAAA.',['狂徒']='狂徒賊:BAAAKgAFFAgIBAAAAA==.',['独孤']='独孤流浪:BAAAKgAECgYICAAAAA==.',['猎艳']='猎艳骑士:BAAAKgADCggICAAAAA==.',['猎龙']='猎龙牧雷奥:BAAAKgADCgEIAQAAAA==.',['猪猪']='猪猪妹:BAAAKgAFFAgIBAAAAA==.',['猪脚']='猪脚饭大王:BAAAKgADCgMIAwAAAA==.',['玉无']='玉无双:BAAAKgAECggIEgAAAA==.',['玉树']='玉树临峰:BAAAKgADCgUIBQAAAA==.',['玉面']='玉面骷髅王:BAAAKgAFFAQIBAAAAA==.',['琪琪']='琪琪大魔王:BAAAKgAFFAQIBAAAAA==.',['瓜皮']='瓜皮果:BAAAKgAFFAIIAgAAAA==.',['疾风']='疾风之刃丶:BAAAKgAECgQIBAAAAA==.',['白宝']='白宝:BAAAKgAFFAQIBAAAAA==.',['白小']='白小雲:BAAAKgAFFAEIAQAAAA==.',['白开']='白开水灬不甜:BAAAKgADCgYIBgAAAA==.',['白熊']='白熊猫人:BAAAKgAECgUIBQAAAA==.',['百味']='百味:BAAAKgAECgYIDwAAAA==.',['盗将']='盗将行:BAAAKgAECgQIBAAAAA==.',['盾牌']='盾牌下的夕阳:BAAAKgAECgQIBAAAAA==.',['真野']='真野菜:BAAAKgADCgQIBAAAAA==.',['眠河']='眠河:BAAAKgAECgcICwAAAA==.',['瞎子']='瞎子也疯狂:BAAAKgAECgMIAwAAAA==.',['矫情']='矫情丶祥子:BAAAKgAECggICQAAAA==.',['破天']='破天一拳:BAAAKgADCgMIAwAAAA==.',['碎锵']='碎锵丶蛮锤:BAAAKgAFFAIIAgAAAA==.',['礼德']='礼德宾:BAAAKgADCggIEAAAAA==.',['祖儿']='祖儿丶:BAAAKgAECgYIBgAAAA==.',['神之']='神之圣骑:BAAAKgADCgEIAQAAAA==.神之弃子:BAAAKgAECgEIAQAAAA==.',['神的']='神的力量阿:BAAAKgAECgQIBAAAAA==.',['神龙']='神龙灬大侠:BAAAKgAECgcIBwAAAA==.',['祤丶']='祤丶翼:BAAAKgAECgEIAQAAAA==.',['祭血']='祭血之魂:BAABKgAFFH8LAAIYAAMIPw1aOQC3AAAYAAMIPw1aOQC3AAAAAA==.',['离析']='离析天空丶:BAAAKgAFFAQIBAAAAA==.',['秀得']='秀得水乱流:BAAAKgADCgYIBgAAAA==.',['秋丨']='秋丨秋:BAABKgAFFH8JAAMgAAYIKxgwDwDtAAAgAAQISSIwDwDtAAAJAAUIixJ3IwCMAAAAAA==.',['种花']='种花菜灬:BAABKgAFFH8OAAMbAAYITQ17CADHAAAbAAYI6gR7CADHAAAHAAQILhSoLgDCAAAAAA==.',['秘密']='秘密反三俗:BAAAKgAECgQIBQAAAA==.',['程兮']='程兮鸣:BAAAKgADCgUIBQAAAA==.',['程旭']='程旭:BAAAKgAECgIIAgAAAA==.',['穿心']='穿心一箭耶:BAAAKgAECgIIAgAAAA==.',['窈窕']='窈窕宗红:BAAAKgAFFAIIAgAAAA==.',['第一']='第一美人:BAABKgAFFH8MAAMVAAgIKw8VBwD4AQAVAAgIKw8VBwD4AQAeAAEIAAAtJAAAAAAAAA==.',['第五']='第五个火槍手:BAAAKgAECggIDgAAAA==.',['米奇']='米奇战神:BAAAKgAECgQIBQAAAA==.',['糖纸']='糖纸:BAABKgAFFH8FAAIiAAUI9Q0lGAC2AAAiAAUI9Q0lGAC2AAAAAA==.',['糖豆']='糖豆儿:BAABKgAFFH8HAAMWAAYIsxdbDADSAAAWAAUINA5bDADSAAAVAAIIRx8GMQCqAAAAAA==.',['紫电']='紫电青霜:BAAAKgAECggICAAAAA==.',['紫色']='紫色很有孕味:BAAAKgAECgMIAwAAAA==.紫色的香蕉:BAAAKgAECgMIAwAAAA==.',['絢爛']='絢爛:BAAAKgAECgQIBAAAAA==.',['維忆']='維忆德:BAAAKgAECgYIBgAAAA==.',['红烧']='红烧大馒头:BAAAKgAECgUIBQAAAA==.',['红色']='红色火龙果:BAAAKgAECgQIBAAAAA==.',['纳兰']='纳兰筱德:BAAAKgAECgEIAQAAAA==.纳兰筱猎:BAAAKgAECgQIBwAAAA==.纳兰筱贼:BAAAKgAFFAgIAwAAAA==.',['经典']='经典一玖伍六:BAAAKgADCggIFwAAAA==.',['给你']='给你举高高:BAAAKgADCgYIBgAAAA==.',['绝望']='绝望怒风:BAAAKgADCgIIAgAAAA==.',['缅怀']='缅怀灬怒风:BAAAKgAECgQIBAAAAA==.',['缓冬']='缓冬:BAAAKgAECgEIAQAAAA==.',['美丽']='美丽的女僧:BAAAKgAECgYICwAAAA==.',['美味']='美味多汁:BAAAKgAECggIDwAAAA==.',['羽簌']='羽簌:BAAAKgADCgEIAgAAAA==.',['耳朵']='耳朵萌萌嘀:BAABKgAFFH8TAAIiAAMI1AbEEAB1AAAiAAMI1AbEEAB1AAAAAA==.耳朵萌萌德:BAACKgAFFH8ZAAIaAAQIghLzBgCgAAAaAAQIghLzBgCgAAAqAAQKfxkAAhoACAgqFB8MAJgBABoACAgqFB8MAJgBAAAA.',['聆丶']='聆丶夜子:BAAAKgAECgYIBgAAAA==.',['职业']='职业试玩丶:BAAAKgADCgEIAQAAAA==.',['联盟']='联盟夫人四:BAAAKgADCgEIAgAAAA==.',['肉丸']='肉丸:BAAAKgADCgUIBQAAAA==.',['肝不']='肝不动的洛兒:BAAAKgAECgcICgAAAA==.',['肠虫']='肠虫清:BAAAKgAECggICAAAAA==.',['胸多']='胸多挤少:BAAAKgAECggIEQAAAA==.',['自然']='自然亲和:BAAAKgAFFAEIAQAAAA==.',['至北']='至北灬还是你:BAAAKgAECgUIBQAAAA==.',['舞肆']='舞肆:BAAAKgAECggICAAAAA==.',['舟山']='舟山陈伟霆:BAABKgAFFH8LAAICAAMIZR6UEgD/AAACAAMIZR6UEgD/AAAAAA==.',['艾斯']='艾斯比:BAAAKgAECgEIAQAAAA==.',['艾瑞']='艾瑞德:BAACKgAFFH8IAAIDAAIIshYEbACTAAADAAIIshYEbACTAAAqAAQKfxUAAgMABwgnHaJeAKMBAAMABwgnHaJeAKMBAAEqAAUUBggIABgAOw4A.',['艾辛']='艾辛诺斯战刃:BAACKgAFFH8MAAIHAAMIkBHPGwDWAAAHAAMIkBHPGwDWAAAqAAQKfxUAAgcACAgCFq5AAKYBAAcACAgCFq5AAKYBAAAA.',['花兔']='花兔:BAAAKgAECgEIAQAAAA==.',['花村']='花村村长华强:BAAAKgAECgYIBgAAAA==.',['花落']='花落执何手:BAABKgAFFH8KAAMIAAYIhBdWAQDMAQAIAAYIhBdWAQDMAQAJAAQItgSYGwCyAAAAAA==.',['花飞']='花飞飞:BAAAKgAECgUIAgAAAA==.',['苏格']='苏格兰冰淇淋:BAAAKgADCgQIBAAAAA==.苏格兰校办韦:BAABKgAFFH8KAAINAAYI7xrPAgAnAQANAAYI7xrPAgAnAQAAAA==.苏格兰通识韦:BAAAKgAECgUIBQAAAA==.',['苦痛']='苦痛与哀难:BAAAKgAECgIIAgAAAA==.',['苦苦']='苦苦林白夜:BAABKgAFFH8GAAIMAAYIpwx1FQD2AAAMAAYIpwx1FQD2AAAAAA==.',['英雄']='英雄城冬冬:BAAAKgADCggICAAAAA==.',['茅山']='茅山道士:BAAAKgAECgQIBAAAAA==.',['茅崎']='茅崎夕樱:BAACKgAFFH9QAAIEAAgIBSUGAQDpAgAEAAgIBSUGAQDpAgAqAAQKfyIAAgQACAgMI2EEAE4CAAQACAgMI2EEAE4CAAEqAAUUCAhRAAYAGiYA.',['茶茶']='茶茶这么可爱:BAABKgAECn8VAAIRAAgIUxuACQACAgARAAgIUxuACQACAgAAAA==.',['草原']='草原明猪:BAAAKgADCgUIBQAAAA==.',['荒废']='荒废流年:BAAAKgAECgYIBgAAAA==.',['荣华']='荣华一指流砂:BAABKgAFFH8QAAIHAAUIqhh6EgAJAQAHAAUIqhh6EgAJAQAAAA==.',['荼荼']='荼荼那么可爱:BAAAKgAECggICAAAAA==.',['莉莉']='莉莉丝丝:BAAAKgAFFAYIAgAAAA==.',['莪看']='莪看世界韵味:BAAAKgAFFAIIAwAAAA==.',['菇艿']='菇艿艿:BAAAKgADCgYIBgAAAA==.',['菜小']='菜小菓:BAAAKgAECgQIBAAAAA==.',['萌宠']='萌宠大作战:BAAAKgAECggIDAAAAA==.',['萧瑟']='萧瑟:BAAAKgAFFAYIBAAAAA==.',['萨满']='萨满移动荣誉:BAAAKgAECgUIBwAAAA==.',['落羽']='落羽无痕:BAAAKgAECgMIAwAAAA==.',['葑芯']='葑芯絕戀:BAABKgAFFH8IAAIDAAgIYRoABgBsAgADAAgIYRoABgBsAgAAAA==.',['董冬']='董冬瓜:BAAAKgAECgEIAQAAAA==.',['蓝七']='蓝七匹狼:BAAAKgAECgQIBAAAAA==.',['虚空']='虚空丶无偿:BAAAKgAECgQIBAAAAA==.',['虞歆']='虞歆:BAAAKgAECgEIAQAAAA==.',['蜜汁']='蜜汁自信:BAAAKgAFFAMIAwAAAA==.',['蠢璐']='蠢璐璐:BAAAKgAECggICwAAAA==.',['血族']='血族丶龙羽安:BAABKgAFFH8OAAMDAAQIhhYWSADeAAADAAQIhhYWSADeAAAiAAEIuQYUFgAsAAAAAA==.',['被遗']='被遗忘的种族:BAAAKgAFFAIIBAAAAA==.',['西瓜']='西瓜码头:BAAAKgAECgYIBgAAAA==.',['西门']='西门飘雪:BAAAKgAECgUICAAAAA==.',['请你']='请你非你我:BAAAKgADCgMIAwAAAA==.',['豫章']='豫章:BAAAKgAFFAQIBAAAAA==.',['贴阁']='贴阁碧:BAAAKgADCggICAABKgAECgQIBAAjAAAAAA==.',['赞达']='赞达拉之星:BAAAKgAECggICAAAAA==.',['赫奎']='赫奎酱的眉毛:BAAAKgAECgEIAQAAAA==.',['超凡']='超凡之盟丶:BAABKgAFFH8NAAIGAAgIKh4ABQB3AgAGAAgIKh4ABQB3AgAAAA==.',['路德']='路德维希:BAAAKgAECgQIBAABKgAFFAgIDgAVAA4jAA==.',['路易']='路易斯卡琳娜:BAAAKgADCgIIAgAAAA==.',['路边']='路边的小草:BAAAKgAECgQIBQAAAA==.',['跳起']='跳起来打你哦:BAAAKgAFFAQIBAAAAA==.',['踏风']='踏风武僧:BAAAKgADCggICgAAAA==.',['躺三']='躺三打:BAAAKgAECgYIBwAAAA==.',['輪胎']='輪胎:BAAAKgAECgYIBgAAAA==.',['达可']='达可萨达达:BAAAKgAECggICAAAAA==.',['过五']='过五关斩六将:BAABKgAFFH8LAAMGAAQIoQfwIgCgAAAGAAQIoQfwIgCgAAATAAII9gu3LQBjAAAAAA==.',['迎風']='迎風聖光灬斬:BAAAKgAECgIIAgAAAA==.',['进击']='进击的暴风:BAAAKgADCggICAAAAA==.',['远方']='远方的王:BAAAKgADCgQIBAAAAA==.',['逃之']='逃之新新:BAAAKgADCgYIBgAAAA==.',['遇雨']='遇雨欲语:BAACKgAFFH8SAAIDAAMIrBWDLgC0AAADAAMIrBWDLgC0AAAqAAQKfxUAAgMACAh2ITA0AC4CAAMACAh2ITA0AC4CAAAA.',['道格']='道格拉苏:BAAAKgADCgUIBQAAAA==.',['遮天']='遮天蔽云:BAAAKgADCgIIAgAAAA==.',['那个']='那个骑士:BAAAKgAFFAIIAgAAAA==.',['那萨']='那萨:BAAAKgAFFAYIAgAAAA==.',['酒酿']='酒酿切糕:BAAAKgADCggICAAAAA==.',['醉酒']='醉酒清牛:BAABKgAECn8UAAIDAAgIZRAojQB8AQADAAgIZRAojQB8AQAAAA==.',['里徳']='里徳宾:BAABKgAECn8bAAMHAAgIcxa7MgCRAQAHAAgIaRS7MgCRAQAbAAgI6RE9IQBvAQAAAA==.',['里的']='里的丙:BAAAKgAECggIDAAAAA==.里的彬:BAAAKgAECggIEwAAAA==.里的斌:BAABKgAECn8WAAIiAAgItg3qDgAqAQAiAAgItg3qDgAqAQAAAA==.里的病:BAAAKgAFFAIIAgAAAA==.',['里锝']='里锝并:BAAAKgAECggIEwAAAA==.',['野猪']='野猪魁:BAABKgAFFH8OAAMTAAYIVhUoCgDvAAATAAQITBMoCgDvAAAGAAQI1gOaMABlAAAAAA==.',['釒罓']='釒罓犭良:BAABKgAECn8WAAIaAAcIPgfWHAC2AAAaAAcIPgfWHAC2AAAAAA==.',['锁心']='锁心锁爱:BAAAKgADCggICAAAAA==.',['锤比']='锤比乃大:BAAAKgAECggIDQAAAA==.',['闪电']='闪电十连鞭:BAABKgAECn8VAAIgAAgIWgzgOAAvAQAgAAgIWgzgOAAvAQAAAA==.',['阿梅']='阿梅丽娅:BAAAKgADCggIEAAAAA==.',['阿灬']='阿灬庆灬嫂:BAAAKgADCgQIBAAAAA==.',['阿珍']='阿珍爱上啊强:BAAAKgAECgYIBgAAAA==.',['隔壁']='隔壁小王哥哥:BAAAKgAECgcIBwAAAA==.隔壁村大飞:BAAAKgADCgEIAQAAAA==.',['雨燕']='雨燕:BAAAKgAECgUIBQAAAA==.',['雨詩']='雨詩:BAAAKgAFFAYIBAAAAA==.',['雨雪']='雨雪阴晴:BAAAKgAFFAgIBAAAAA==.',['雨风']='雨风灵:BAAAKgADCgcIBwAAAA==.',['雪嘚']='雪嘚儿:BAAAKgAECgQIBQAAAA==.',['雪奶']='雪奶的白子:BAAAKgAECgQIBAAAAA==.',['霁雪']='霁雪时晴:BAAAKgAECgYIBgAAAA==.',['霜灬']='霜灬痕:BAAAKgAECgEIAQAAAA==.',['霹雳']='霹雳娇娲:BAABKgAFFH8FAAIXAAUINB4LDQB9AQAXAAUINB4LDQB9AQAAAA==.霹雳火:BAABKgAFFH8GAAIJAAYI1An7FwAiAQAJAAYI1An7FwAiAQAAAA==.',['青丶']='青丶山:BAABKgAFFH8RAAIDAAMIdRquPQD4AAADAAMIdRquPQD4AAAAAA==.',['顾念']='顾念丶:BAAAKgADCggICAAAAA==.',['风之']='风之梦幻:BAAAKgAECgQIBAAAAA==.',['风吟']='风吟木:BAABKgAECn8ZAAIBAAgI1AxwHwAeAQABAAgI1AxwHwAeAQAAAA==.',['风希']='风希:BAAAKgADCgIIAgAAAA==.',['飘逸']='飘逸的汉子:BAAAKgAECggIBAAAAA==.',['飞天']='飞天大草:BAAAKgADCggICAAAAA==.',['飞火']='飞火流云:BAAAKgAECgQICwAAAA==.',['飞鹰']='飞鹰:BAAAKgAECgcIEwAAAA==.',['食鱼']='食鱼专家:BAAAKgADCgYIBgAAAA==.',['饕餮']='饕餮姬:BAAAKgAECggICAAAAA==.',['饿萌']='饿萌猎手:BAABKgAECn8UAAMbAAgIoBDiLwAIAQAbAAgIoBDiLwAIAQAHAAIIMgOHvQA2AAAAAA==.',['香勃']='香勃勃:BAAAKgAECgcIBAAAAA==.',['馨喵']='馨喵喵:BAABKgAFFH8LAAMRAAgI1BbVCABTAQARAAcIxBfVCABTAQASAAEIMxEoMABRAAAAAA==.',['马保']='马保国大弟子:BAAAKgADCgIIAgAAAA==.',['驺虞']='驺虞:BAAAKgAECgMIAwAAAA==.',['骑兵']='骑兵乐马:BAAAKgAFFAIIAgAAAA==.',['高梁']='高梁河车神:BAAAKgAFFAgIAwAAAA==.',['魔贯']='魔贯光杀炮:BAACKgAFFH8GAAIHAAMIuw5ZGgDcAAAHAAMIuw5ZGgDcAAAqAAQKfxoAAgcACAhfGYEqAAwCAAcACAhfGYEqAAwCAAAA.',['鸕鷀']='鸕鷀:BAAAKgAECgcIBgAAAA==.',['鸡你']='鸡你美不美:BAABKgAFFH8IAAIGAAgIdQrBCwDIAQAGAAgIdQrBCwDIAQAAAA==.',['鸡兔']='鸡兔同笼:BAABKgAFFH8FAAINAAUIEhIHDQD/AAANAAUIEhIHDQD/AAAAAA==.',['鸡哥']='鸡哥可彪悍:BAAAKgADCggICAAAAA==.',['鸡窝']='鸡窝窝:BAABKgAFFH8dAAIBAAcIRh4cEABmAQABAAcIRh4cEABmAQAAAA==.',['鸣上']='鸣上悠:BAAAKgAFFAQIBAAAAA==.',['麦格']='麦格伦:BAACKgAFFH8PAAMNAAMIhhkDEADiAAANAAMIhhkDEADiAAAEAAEIgwd8RgA4AAAqAAQKfx0AAg0ACAhxHdYGAEQCAA0ACAhxHdYGAEQCAAAA.',['麦梳']='麦梳梳:BAAAKgAECgYIBwAAAA==.',['黄胡']='黄胡子:BAAAKgAECgEIAQAAAA==.',['黄花']='黄花大牦牛:BAAAKgAFFAQIBAAAAA==.',['黑命']='黑命贵:BAABKgAFFH8OAAMQAAYIyh7PDgAWAQAQAAMIbiPPDgAWAQASAAUIYxt6CQALAQAAAA==.',['黑夜']='黑夜之风:BAACKgAFFH8WAAIBAAMIYg/qFgCuAAABAAMIYg/qFgCuAAAqAAQKfxUAAgEACAgCGj07ADwBAAEACAgCGj07ADwBAAAA.',['黑山']='黑山老妖二娘:BAAAKgAECgMIAwAAAA==.',['黑白']='黑白人生:BAAAKgADCggIFgAAAA==.',['黑翼']='黑翼大摩:BAAAKgAECggICAAAAA==.',['默默']='默默茶:BAACKgAFFH8IAAIDAAQI3SLeDwAVAQADAAQI3SLeDwAVAQAqAAQKfxcAAgMACAh6JQALAO4CAAMACAh6JQALAO4CAAAA.',['黯炎']='黯炎瑟米欧斯:BAAAKgAECgYIBgAAAA==.',['鼠兔']='鼠兔:BAAAKgAECgYIBwAAAA==.',['龙囍']='龙囍儿:BAAAKgAECggIEAAAAA==.',['龙腾']='龙腾骑士:BAAAKgAECggICAAAAA==.',['龚怡']='龚怡佳:BAABKgAECn8vAAMNAAgI4R8yDAB6AgANAAgI4R8yDAB6AgAEAAMIcxdvNACPAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end