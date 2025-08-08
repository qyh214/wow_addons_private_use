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
 local lookup = {'Warlock-Destruction','DeathKnight-Unholy','Hunter-BeastMastery','Paladin-Retribution','DemonHunter-Havoc','Warrior-Protection','Monk-Windwalker','Monk-Mistweaver','Warrior-Fury','Druid-Balance','Druid-Guardian','Priest-Discipline','Mage-Frost','Mage-Arcane','Mage-Fire','Paladin-Protection','Shaman-Restoration','Hunter-Marksmanship','Druid-Restoration','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Paladin-Holy','Warlock-Demonology','Warlock-Affliction','Shaman-Elemental','Unknown-Unknown','Warrior-Arms','Rogue-Assassination','Shaman-Enhancement','Monk-Brewmaster','DeathKnight-Frost','Evoker-Preservation','Evoker-Devastation','Rogue-Subtlety',}; local provider = {region='CN',realm='外域',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ak='Akilwoew:BAAAKgADCgEIAQAAAA==.',Am='Ami:BAAAKgADCggIDAAAAA==.',Ar='Arthur:BAABKgAFFH8KAAIBAAgILyAUAgCxAgABAAgILyAUAgCxAgAAAA==.',Ch='Checkno:BAAAKgAFFAgIBAAAAA==.',Fa='Fallenarcher:BAAAKgAECgEIAgAAAA==.',Fe='February:BAAAKgADCgcIDgAAAA==.',Ha='Halfkoala:BAAAKgAFFAQIBAAAAA==.',In='Indulgence:BAAAKgAECgEIAQAAAA==.',Ja='Jannatturugi:BAABKgAFFH8GAAICAAYIyRwLEgCKAQACAAYIyRwLEgCKAQAAAA==.',Jo='Joy:BAABKgAFFH8bAAIDAAYIOxZTEgBkAQADAAYIOxZTEgBkAQAAAA==.Joyqs:BAAAKgAECggICgAAAA==.',Ju='July:BAAAKgAECggICAAAAA==.',Ka='Kathen:BAAAKgAECggIDgAAAA==.',Ki='Kissin:BAAAKgAFFAIIAgAAAA==.',Kk='Kkb:BAAAKgADCgMIAwAAAA==.',Li='Liadrin:BAABKgAFFH8RAAIEAAQI/CUiCQA2AQAEAAQI/CUiCQA2AQABKgAFFAgIFAAFAOMZAA==.',Ls='Lsabella:BAAAKgAECgUICAAAAA==.',Ly='Lycks:BAABKgAECn8WAAIGAAgI+QsRIAACAQAGAAgI+QsRIAACAQAAAA==.Lydls:BAAAKgAECgQICwAAAA==.Lyjxs:BAAAKgAECgcIEQAAAA==.Lysls:BAAAKgAECgQIBAAAAA==.Lyxls:BAAAKgAECgMIAwAAAA==.Lyyes:BAAAKgAECgUICAAAAA==.',Ma='Mail:BAAAKgADCgEIAQAAAA==.',Mo='Monsky:BAAAKgAFFAIIAwAAAA==.Moriartye:BAABKgAFFH8IAAIEAAgIjBDNCQALAgAEAAgIjBDNCQALAgAAAA==.Mowfhi:BAAAKgAFFAYIAgAAAA==.',Mu='Mudgad:BAAAKgADCgIIAgAAAA==.',Or='Oranges:BAAAKgAFFAgIBAAAAA==.',Pl='Playerhmsl:BAAAKgADCgEIAQAAAA==.Playernwwqnq:BAAAKgADCgQIBAAAAA==.Playerrjhfuk:BAAAKgAECggIAwAAAA==.',Qi='Qi:BAAAKgADCgEIAQAAAA==.',Ry='Ryasunpriest:BAAAKgAFFAQIBAAAAA==.',Te='Terminus:BAAAKgAECgQIBQAAAA==.',Th='Thanks:BAABKgAFFH8GAAIHAAYIrAxrBwBcAQAHAAYIrAxrBwBcAQAAAA==.Thursday:BAAAKgAECgYIBwAAAA==.',Va='Vanseeleia:BAAAKgADCgEIAQAAAA==.',Vd='Vdream:BAABKgAFFH8FAAIFAAUI7gjGEwDyAAAFAAUI7gjGEwDyAAAAAA==.',Wi='Windwhisper:BAAAKgAECgIIAgAAAA==.',Xa='Xanzus:BAABKgAECn8WAAIIAAgIYh5wBABLAgAIAAgIYh5wBABLAgAAAA==.',Zz='Zzkang:BAAAKgAECggICAAAAA==.',['一个']='一个字死:BAAAKgADCgMIAwAAAA==.',['一只']='一只海龟:BAAAKgADCggICAAAAA==.',['一粒']='一粒麦兜:BAAAKgAECgMIAwAAAA==.',['一颗']='一颗酸柠檬:BAAAKgAECgQIBQAAAA==.',['一麦']='一麦克阿瑟一:BAAAKgAFFAQIBAAAAA==.',['三门']='三门有冬:BAAAKgAECggIDgAAAA==.',['不听']='不听话就羊你:BAAAKgADCggICAAAAA==.',['不要']='不要追我:BAAAKgAECgUIDQAAAA==.',['世界']='世界第一骑士:BAAAKgAECgEIAQAAAA==.',['东海']='东海莽道人:BAAAKgAFFAIIAgAAAA==.',['丨史']='丨史泰龙丶:BAABKgAFFH8FAAIJAAMISgzzJQC3AAAJAAMISgzzJQC3AAAAAA==.',['丨周']='丨周二少丶:BAAAKgAFFAgIAgAAAA==.',['丨爆']='丨爆丶龖丨:BAAAKgAFFAQIBAAAAA==.',['丨阿']='丨阿尔薩斯丨:BAAAKgADCggIDAAAAA==.',['丶七']='丶七月:BAABKgAFFH8MAAIKAAUI5BXFHwAiAQAKAAUI5BXFHwAiAQAAAA==.',['丶丶']='丶丶暗色丶丶:BAAAKgAECgcICwAAAA==.',['丶怀']='丶怀瑾握瑜:BAAAKgAECgIIAgAAAA==.',['乱舞']='乱舞小咕咕:BAABKgAFFH8HAAMKAAUImRFdKQDuAAAKAAUIzgpdKQDuAAALAAIIYhOVCQB1AAAAAA==.',['二小']='二小牧:BAAAKgADCgUIBQAAAA==.',['二锅']='二锅头:BAACKgAFFH8GAAIKAAMIYg5zPAC1AAAKAAMIYg5zPAC1AAAqAAQKfxwAAgoABwh1IGkjAC0CAAoABwh1IGkjAC0CAAAA.',['五福']='五福狼爪:BAAAKgAECgUIBQAAAA==.',['京玉']='京玉:BAABKgAFFH8FAAIMAAUIdByZDgAyAQAMAAUIdByZDgAyAQAAAA==.',['亲切']='亲切的三亿:BAAAKgADCgMIAwAAAA==.',['人生']='人生贵淡泊:BAAAKgAFFAIIAgAAAA==.',['亿万']='亿万少女的梦:BAABKgAFFH8GAAINAAYIAwqWCgAcAQANAAYIAwqWCgAcAQAAAA==.',['仁德']='仁德会肉贩子:BAAAKgADCggICAAAAA==.',['今天']='今天没有糖:BAABKgAFFH8GAAMOAAII2AzrOgB2AAAOAAII2AzrOgB2AAAPAAIIYgRYNgBoAAAAAA==.',['从頭']='从頭开始:BAACKgAFFH8FAAICAAIIZwrSHAB4AAACAAIIZwrSHAB4AAAqAAQKfxYAAgIACAgrGog4AJIBAAIACAgrGog4AJIBAAAA.',['伊利']='伊利氮:BAAAKgAFFAIIAgAAAA==.',['你抓']='你抓不到我丶:BAAAKgADCgcIBwAAAA==.',['佩罗']='佩罗娜呀:BAABKgAFFH8IAAIOAAgI9QNODgBVAQAOAAgI9QNODgBVAQAAAA==.',['侃侃']='侃侃盖恩:BAAAKgAFFAMIAwAAAA==.侃侃莱恩:BAAAKgAECgUIAwAAAA==.侃侃菲恩:BAABKgAFFH8RAAMQAAYIVRsIAgB9AQAQAAYI8BYIAgB9AQAEAAQIsCIfPQD6AAAAAA==.',['依然']='依然丨怡然:BAAAKgADCggIDAAAAA==.依然烤香肠:BAACKgAFFH8hAAIRAAYIGB28AADcAQARAAYIGB28AADcAQAqAAQKfyIAAhEACAhYHG4lAPoBABEACAhYHG4lAPoBAAAA.',['侵蚀']='侵蚀污染:BAAAKgAFFAIIAgAAAA==.',['俏俏']='俏俏呀:BAAAKgADCggICgAAAA==.',['倒数']='倒数顺数第二:BAABKgAECn8dAAIRAAgIqBPYQABzAQARAAgIqBPYQABzAQAAAA==.',['偶迈']='偶迈噶得:BAAAKgADCggICAAAAA==.',['傲雪']='傲雪飞飘:BAAAKgAECggIEAAAAA==.',['光丶']='光丶:BAAAKgAECgIIAgAAAA==.',['光明']='光明奶茶:BAABKgAFFH8GAAIEAAYI6BcvIwBfAQAEAAYI6BcvIwBfAQAAAA==.',['光與']='光與影:BAAAKgADCgUIBQAAAA==.',['公主']='公主请上班丶:BAAAKgAFFAYIBAAAAA==.',['关晛']='关晛:BAABKgAECn8mAAISAAgIdhklIQDMAQASAAgIdhklIQDMAQAAAA==.',['养什']='养什么死什么:BAABKgAFFH8MAAMDAAYIzBWbEwBYAQADAAYIkhCbEwBYAQASAAYI6BKDEgBPAQAAAA==.',['再打']='再打我变熊:BAAAKgAFFAYIBAAAAA==.',['农场']='农场主老张:BAAAKgADCgEIAQAAAA==.',['冥焰']='冥焰小仔:BAABKgAFFH8IAAIDAAgIAA1GCQDfAQADAAgIAA1GCQDfAQAAAA==.冥焰小左:BAABKgAFFH8MAAIRAAgIzQ6hBgDiAQARAAgIzQ6hBgDiAQAAAA==.',['冰翼']='冰翼圣灵:BAABKgAFFH8IAAIEAAgIcQjXEgDFAQAEAAgIcQjXEgDFAQAAAA==.',['冷月']='冷月丶:BAAAKgAECgEIAQAAAA==.',['凛风']='凛风:BAAAKgADCggICAAAAA==.',['刘大']='刘大宝:BAACKgAFFH8QAAIJAAMIkhtZDwD8AAAJAAMIkhtZDwD8AAAqAAQKfxUAAgkACAhEHoEYAEcCAAkACAhEHoEYAEcCAAAA.',['剑聖']='剑聖:BAAAKgAECgMIAwAAAA==.',['功夫']='功夫哈士奇:BAAAKgADCggICAAAAA==.',['动情']='动情时最美:BAAAKgAECggIDgAAAA==.',['北极']='北极小兔:BAAAKgADCggICAAAAA==.',['北辰']='北辰南山:BAAAKgAECgQIBAAAAA==.',['千幻']='千幻流光:BAABKgAFFH8GAAIOAAYIMiMwBwAPAgAOAAYIMiMwBwAPAgAAAA==.',['半只']='半只鹌鹑:BAABKgAFFH8IAAMKAAQI0R0TMADUAAAKAAQI0R0TMADUAAATAAQI5hOYHAC/AAABKgAFFAgICgADAGkbAA==.',['卖炊']='卖炊饼的:BAABKgAECn8eAAMNAAgIXR7SEABBAgANAAgIXR7SEABBAgAPAAEIqQ3sSwAqAAAAAA==.',['卖萌']='卖萌怪丶嘤嘤:BAAAKgAFFAMIAwAAAA==.',['卡哇']='卡哇伊貝貝:BAAAKgAECgUIDQAAAA==.',['卡西']='卡西欧:BAAAKgADCgYIBgAAAA==.',['卡龙']='卡龙琪美特:BAABKgAFFH8IAAIUAAgIMAn+BQBoAQAUAAgIMAn+BQBoAQAAAA==.',['变异']='变异棒锤兽:BAABKgAFFH8IAAIOAAgIshIHBwATAgAOAAgIshIHBwATAgAAAA==.',['可乐']='可乐丶雪碧:BAABKgAFFH8GAAIKAAYIqhazFgBjAQAKAAYIqhazFgBjAQAAAA==.',['叽叽']='叽叽:BAABKgAFFH8SAAQVAAgI+RiTBQDfAQAVAAcIGxiTBQDfAQAWAAUITgy0EQC0AAAMAAEIFxRQJQBPAAAAAA==.',['后跳']='后跳欸滴滴:BAAAKgAFFAQIBAAAAA==.',['吴宫']='吴宫干戈:BAABKgAFFH8HAAIUAAMIEwKHLwBRAAAUAAMIEwKHLwBRAAAAAA==.',['呜喵']='呜喵王丶:BAAAKgAECgIIAgAAAA==.',['咕咚']='咕咚:BAAAKgADCggICAAAAA==.',['咪老']='咪老鼠:BAAAKgAFFAQIBAAAAA==.',['咸湿']='咸湿:BAABKgAECn8iAAIWAAgISCMsAwCoAgAWAAgISCMsAwCoAgAAAA==.',['哇唔']='哇唔噢吽:BAAAKgADCggICAAAAA==.',['哞哞']='哞哞僧:BAACKgAFFH8EAAIHAAQICAsJGQCiAAAHAAQICAsJGQCiAAAqAAQKfyEAAwgACAhtGZkGAAICAAgACAhtGZkGAAICAAcACAjeGbccALgBAAAA.哞哞小钻风:BAAAKgADCggICAAAAA==.',['啵推']='啵推:BAAAKgAECggICgAAAA==.',['噬淵']='噬淵行者:BAAAKgADCgUIBQAAAA==.',['四元']='四元钱凉皮:BAAAKgADCgMIAwAAAA==.',['四月']='四月物语:BAAAKgAFFAQIBAAAAA==.',['团团']='团团:BAAAKgADCgcIBwAAAA==.',['圣光']='圣光大酋长:BAAAKgAECgIIAgAAAA==.圣光宽恕:BAAAKgADCgQIBAAAAA==.',['在下']='在下丶小别离:BAAAKgADCggICQAAAA==.在下丶小天真:BAAAKgADCggICAAAAA==.在下丶暮如雪:BAAAKgAECgEIAQAAAA==.',['坠入']='坠入凡尘:BAAAKgAECgQIDwAAAA==.',['塔兰']='塔兰吉之女:BAAAKgAFFAMIAwAAAA==.',['墨染']='墨染梨衣:BAAAKgAFFAgIAgAAAA==.',['壹粒']='壹粒大雷:BAAAKgADCggIEAAAAA==.',['夏天']='夏天的太阳:BAAAKgAECgEIAQAAAA==.',['夜溪']='夜溪儿:BAACKgAFFH8aAAIXAAMIIR5BDADnAAAXAAMIIR5BDADnAAAqAAQKfz8AAhcACAiTHmgMACwCABcACAiTHmgMACwCAAAA.夜溪兒:BAACKgAFFH8lAAIXAAMIWBqzDQDXAAAXAAMIWBqzDQDXAAAqAAQKf0QAAxcACAhkH4MJAFUCABcACAhkH4MJAFUCAAQAAgjyBcwkAUMAAAAA.',['夜王']='夜王一寒冬城:BAABKgAFFH8GAAIUAAYIggpmFwDmAAAUAAYIggpmFwDmAAAAAA==.',['大司']='大司命:BAAAKgAECggICAAAAA==.',['大姨']='大姨媽:BAABKgAFFH8HAAMWAAcIMQhiHwDLAAAWAAMI1gtiHwDLAAAMAAQIjQQLJQCMAAAAAA==.',['大熊']='大熊硬糖:BAAAKgAFFAMIAwAAAA==.',['大脚']='大脚:BAAAKgAFFAQIBAAAAA==.',['大表']='大表姐丶:BAAAKgAECgMIAwAAAA==.',['大酋']='大酋长:BAAAKgADCgEIAQAAAA==.',['天元']='天元浮钓鲢鳙:BAABKgAFFH8IAAIRAAgI7SUyAAAAAwARAAgI7SUyAAAAAwAAAA==.',['天堂']='天堂信仰丶朮:BAABKgAFFH8QAAIBAAQIIwtnGgCsAAABAAQIIwtnGgCsAAAAAA==.',['女獣']='女獣人萨满:BAAAKgADCgYIBgAAAA==.',['威廉']='威廉姆斯:BAAAKgAECgUIBgAAAA==.',['媚惑']='媚惑者:BAABKgAECn8UAAMBAAgIzBVbNACeAQABAAgIzxFbNACeAQAYAAcIlxdrRADRAAAAAA==.',['孤独']='孤独天使:BAAAKgAECgEIAQAAAA==.',['宇文']='宇文術学:BAABKgAFFH8lAAQZAAcIvBv4AQCVAQAZAAYIOBr4AQCVAQABAAUIgRhuGQA5AQAYAAIIiwfIKwBDAAAAAA==.',['宙斯']='宙斯盾级:BAABKgAFFH8IAAIBAAgIlReXAwBbAgABAAgIlReXAwBbAgAAAA==.',['定西']='定西丶:BAAAKgADCggICAAAAA==.',['家有']='家有只熊:BAAAKgAECgMIAwAAAA==.',['寇往']='寇往吾亦可往:BAAAKgAFFAUIAQAAAA==.',['寒冰']='寒冰宝珠:BAAAKgAFFAYIBAAAAA==.',['射的']='射的就是我:BAAAKgAECgYIBgAAAA==.',['小兔']='小兔姬:BAABKgAFFH8FAAIWAAMIPgvzKgCXAAAWAAMIPgvzKgCXAAAAAA==.',['小八']='小八有神奇:BAAAKgAECgQICAAAAA==.',['小叶']='小叶:BAACKgAFFH8IAAIZAAMITASsCgCXAAAZAAMITASsCgCXAAAqAAQKfxcAAhkACAgGGZIDAOgBABkACAgGGZIDAOgBAAAA.',['小屁']='小屁龙:BAAAKgAECgEIAQAAAA==.',['小槑']='小槑:BAABKgAFFH8LAAQZAAYIaRJWDQC9AAABAAMIEhMQKwDBAAAZAAQI5AZWDQC9AAAYAAMIaxHBGACIAAAAAA==.',['小烨']='小烨:BAAAKgAECgcIDAAAAA==.',['小脸']='小脸靓呆呆:BAAAKgAECgMIAwAAAA==.',['小鞠']='小鞠知花:BAAAKgAECggIEwAAAA==.',['小鞭']='小鞭:BAAAKgADCgQIBAAAAA==.',['小黄']='小黄油拿铁:BAAAKgAFFAMIAwAAAA==.',['少年']='少年郎丶:BAABKgAFFH8FAAIPAAMI0h42KACtAAAPAAMI0h42KACtAAAAAA==.',['岛尘']='岛尘丶:BAAAKgADCgYIBgAAAA==.',['巫毒']='巫毒嘎嘎:BAABKgAECn8bAAINAAgIhRrhJADvAQANAAgIhRrhJADvAQAAAA==.',['巴拉']='巴拉芭拉:BAAAKgADCgEIAQAAAA==.',['布加']='布加迪:BAAAKgADCggICAAAAA==.',['布莱']='布莱恩恰鸡:BAAAKgAECgQIBAAAAA==.',['希斯']='希斯莱杰丶:BAAAKgAECgYIBgAAAA==.',['席琳']='席琳虛空牧:BAABKgAFFH8LAAIVAAYIxxuRCgBWAQAVAAYIxxuRCgBWAQAAAA==.',['干丶']='干丶不能怂:BAABKgAFFH8FAAICAAMIrAmuPACrAAACAAMIrAmuPACrAAAAAA==.',['平静']='平静之环:BAABKgAFFH8aAAIIAAgIWwxgBAB4AQAIAAgIWwxgBAB4AQAAAA==.',['幻风']='幻风沁:BAAAKgAFFAQIBAAAAA==.幻风灵:BAABKgAFFH8HAAMOAAUI+hXqGgAOAQAOAAUI+hXqGgAOAQANAAII+gGYJQAoAAAAAA==.幻风雪:BAABKgAFFH8FAAIWAAUIKAm+IADEAAAWAAUIKAm+IADEAAAAAA==.',['开嗜']='开嗜血的:BAAAKgAECgQIBAAAAA==.',['张华']='张华夫臭了:BAAAKgAFFAEIAQAAAA==.',['弹珠']='弹珠:BAAAKgAECgMIBwAAAA==.',['强效']='强效王者祝福:BAAAKgADCgMIAwAAAA==.',['很硬']='很硬的头哦:BAABKgAFFH8GAAIFAAYIdw1/DgBeAQAFAAYIdw1/DgBeAQAAAA==.',['微光']='微光:BAAAKgAFFAMIAwAAAA==.',['心情']='心情在变:BAABKgAFFH8NAAMOAAQIEwmHMAChAAAPAAMIsAa2IgCjAAAOAAQIEwmHMAChAAAAAA==.',['怀瑾']='怀瑾握瑜:BAAAKgAECgMIAwAAAA==.',['思丶']='思丶雨:BAAAKgAECgcICwAAAA==.',['恐嚎']='恐嚎:BAAAKgADCgMIAwAAAA==.',['恩丶']='恩丶我知道:BAABKgAFFH8QAAMaAAQIHRLaCgDYAAAaAAQIHRLaCgDYAAARAAQI+hjVEwDVAAABKgAFFAgIDgARABUPAA==.',['恶念']='恶念之花:BAAAKgAECgUIBQAAAA==.',['恶魔']='恶魔复仇者:BAAAKgAFFAIIBAAAAA==.',['情非']='情非得已:BAAAKgAECgQIAwAAAA==.',['想当']='想当当:BAAAKgADCggICAAAAA==.',['意浓']='意浓丶:BAACKgAFFH8OAAISAAYI3BnADQB/AQASAAYI3BnADQB/AQAqAAQKfyEAAxIACAimI9oUAFICABIACAhMItoUAFICAAMACAjvHG4xAC4CAAAA.',['意见']='意见欲:BAABKgAFFH8KAAIIAAYIXRLrDgA6AQAIAAYIXRLrDgA6AQAAAA==.',['憶如']='憶如往昔丶:BAAAKgADCgEIAQAAAA==.',['我是']='我是活老鬼:BAAAKgAECggIEQAAAA==.我是闪电:BAAAKgAECgYICgAAAA==.',['战丶']='战丶士:BAAAKgAECgcICAAAAA==.',['打肥']='打肥鸡:BAAAKgAECgYICQAAAA==.',['托尼']='托尼斯塔克:BAAAKgADCggICAAAAA==.',['找捶']='找捶:BAAAKgADCgIIAgAAAA==.',['握寒']='握寒:BAABKgAFFH8GAAIUAAYIyByLBwCoAQAUAAYIyByLBwCoAQAAAA==.',['摸骨']='摸骨天后丶:BAAAKgAECgUIAwAAAA==.',['放了']='放了那大婶:BAABKgAECn8rAAMJAAgIyRu5IQAQAgAJAAgIwhu5IQAQAgAGAAEIGxMiSAA4AAAAAA==.',['敢将']='敢将伤痛忘掉:BAAAKgADCggICAAAAA==.',['数数']='数数顺到第四:BAABKgAECn8cAAIWAAgIkxN/EACBAQAWAAgIkxN/EACBAQAAAA==.',['无心']='无心亦无情:BAAAKgADCggICAAAAA==.',['无敌']='无敌最寂寞丶:BAAAKgAECgUIBQAAAA==.',['星界']='星界德:BAAAKgAFFAQIBAAAAA==.',['星辰']='星辰魂:BAAAKgAECgEIAQAAAA==.',['春风']='春风不语:BAAAKgAECgcIBwAAAA==.',['是阿']='是阿豪诶:BAABKgAFFH8IAAIJAAMI/A9cJADAAAAJAAMI/A9cJADAAAAAAA==.',['暁野']='暁野妹子他哥:BAAAKgADCggIEwAAAA==.',['暖梦']='暖梦旧歌:BAAAKgADCggICAAAAA==.',['暗冥']='暗冥之手:BAAAKgAECggIEAAAAA==.',['暗影']='暗影冲撞:BAABKgAFFH8MAAMVAAYI9BlrAgC3AQAVAAYI9BlrAgC3AQAWAAUI/ByrEgAdAQABKgAFFAgIBAAbAAAAAA==.',['暴走']='暴走的国宝:BAAAKgAFFAIIAgAAAA==.',['暴食']='暴食强袭:BAAAKgAECggICAAAAA==.',['曰白']='曰白不要钱:BAAAKgAECgIIAgAAAA==.',['最绿']='最绿的绿皮:BAAAKgADCggICAAAAA==.',['月落']='月落云生:BAAAKgAFFAgIAwAAAA==.月落星晟:BAAAKgAFFAQIBAAAAA==.',['末日']='末日之觞:BAAAKgAECgYIBgAAAA==.',['朱雀']='朱雀之空:BAAAKgAECgYIBgAAAA==.',['朴益']='朴益生:BAAAKgAECggICwAAAA==.',['朴老']='朴老师:BAAAKgAFFAEIAQAAAA==.',['杀气']='杀气入指間:BAAAKgAECgIIAwAAAA==.',['李小']='李小磊同学:BAAAKgAECgcIBwAAAA==.',['杨某']='杨某人:BAAAKgAECggICQAAAA==.',['杰老']='杰老板:BAABKgAFFH8PAAIEAAgI8hBjCgD/AQAEAAgI8hBjCgD/AQAAAA==.',['果冻']='果冻奶茶:BAABKgAFFH8GAAMJAAYIgA4WKQCjAAAJAAIIexgWKQCjAAAcAAQI2QdXHwCTAAAAAA==.',['果壳']='果壳麋鹿:BAAAKgAECggIBQAAAA==.',['柒夜']='柒夜:BAAAKgADCggICAAAAA==.',['柠檬']='柠檬丨冰红茶:BAAAKgAECgYIDwAAAA==.',['格格']='格格雾:BAAAKgADCgIIAgAAAA==.',['棉花']='棉花糖小熊:BAAAKgAFFAIIAgAAAA==.',['榴火']='榴火:BAABKgAECn8UAAIDAAgIhg4PVQBcAQADAAgIhg4PVQBcAQAAAA==.',['槑圆']='槑圆润:BAABKgAFFH8GAAIdAAYIRRcvDQB7AQAdAAYIRRcvDQB7AQAAAA==.',['欢猪']='欢猪丶:BAAAKgAECgYIBwAAAA==.',['欢茄']='欢茄炒鸡蛋:BAAAKgADCggICAAAAA==.',['欧乐']='欧乐币:BAAAKgAFFAIIAgAAAA==.',['欧皇']='欧皇丨利哥哥:BAAAKgAFFAIIAgAAAA==.',['死之']='死之魂泪:BAAAKgAECggICAAAAA==.',['死亡']='死亡序曲:BAAAKgAFFAQIBAAAAA==.',['比你']='比你更猛:BAABKgAFFH8KAAITAAYIlBOTDAA/AQATAAYIlBOTDAA/AQAAAA==.',['比特']='比特牛:BAAAKgAECgUIBQAAAA==.',['沐子']='沐子:BAAAKgAECgcICgAAAA==.',['治疗']='治疗之涌:BAAAKgAFFAgIAgAAAA==.',['泡泡']='泡泡哒光:BAAAKgADCgEIAQAAAA==.',['波儿']='波儿霸奔丶:BAAAKgAECgcIBwAAAA==.',['泷夜']='泷夜叉姬:BAAAKgADCgMIAwAAAA==.',['洗心']='洗心革面流风:BAAAKgAFFAQIBAAAAA==.',['洛丽']='洛丽塔审查官:BAAAKgADCgQIBgAAAA==.',['洛柯']='洛柯:BAAAKgAECgEIAQAAAA==.',['流氓']='流氓帅哥:BAABKgAFFH8MAAMXAAMIRwRzFACXAAAXAAMIRwRzFACXAAAQAAEIkwH5FgAfAAAAAA==.',['浅巷']='浅巷墨漓:BAAAKgAECgEIAQAAAA==.',['浮生']='浮生半世丶:BAAAKgAECgIIAgAAAA==.浮生若梦丶:BAAAKgAFFAQIBAAAAA==.',['液魔']='液魔影瑝:BAAAKgAECgYIEgAAAA==.',['涴涴']='涴涴清风:BAAAKgAECggIDAAAAA==.',['淑女']='淑女打铁:BAAAKgAFFAMIAwAAAA==.',['淩波']='淩波麗:BAAAKgAECgQIAwAAAA==.',['深渊']='深渊意志:BAAAKgADCgEIAQAAAA==.',['温水']='温水佳树:BAAAKgAECgMIBQAAAA==.',['滚球']='滚球球:BAAAKgAECgcIDQAAAA==.',['灬公']='灬公主丶馨:BAAAKgAECgIIAgAAAA==.',['灭团']='灭团小萨:BAAAKgAECggICAAAAA==.',['灰太']='灰太朗:BAAAKgADCgUIBQAAAA==.',['灵行']='灵行天下麒麟:BAABKgAFFH8KAAMEAAQIbg3TYgCqAAAEAAQIbg3TYgCqAAAQAAMIgwKZFABeAAAAAA==.',['灵风']='灵风无痕:BAAAKgAECggICAAAAA==.',['灿烂']='灿烂妈宝男:BAAAKgAECggICQAAAA==.',['烛照']='烛照:BAAAKgADCgIIAgAAAA==.',['無敌']='無敌最寂寞:BAAAKgAFFAQIBAAAAA==.',['熊墩']='熊墩墩:BAAAKgAECgQIBwAAAA==.',['燭照']='燭照:BAAAKgAECgQIBAAAAA==.',['爱吃']='爱吃豆腐脑:BAAAKgADCgcIBwAAAA==.',['爲什']='爲什麽不:BAAAKgADCgEIAQAAAA==.',['牛丶']='牛丶奶:BAAAKgAFFAQIBAABKgAFFAgICgAEACQhAA==.',['牛之']='牛之刚健:BAABKgAFFH8HAAIRAAQInQE3RAB0AAARAAQInQE3RAB0AAAAAA==.',['牛二']='牛二:BAAAKgAECgQIBQAAAA==.',['牛牛']='牛牛光环:BAABKgAFFH8QAAIEAAMISiIsOQAHAQAEAAMISiIsOQAHAQAAAA==.',['牛锤']='牛锤:BAAAKgAECggIEAAAAA==.',['牜丶']='牜丶萨满:BAAAKgAECgQIBwAAAA==.',['牧玖']='牧玖:BAAAKgAECggICwAAAA==.',['牧莱']='牧莱克斯塔萨:BAABKgAFFH8IAAMWAAgI1BZ8EgAeAQAWAAcILRR8EgAeAQAVAAEIVyVqHwBsAAAAAA==.',['特仑']='特仑苏:BAABKgAFFH8GAAQYAAYInRr2DQBzAAAZAAQIcRSFEQCvAAAYAAEIWSb2DQBzAAABAAEIaCGMKQBmAAABKgAFFAgIDAAeAHAWAA==.',['狂傲']='狂傲天下:BAAAKgAECgIIAgAAAA==.',['狂扁']='狂扁小朋友:BAAAKgAECgQIBQAAAA==.',['狂暴']='狂暴小黑皮:BAAAKgAECgUIBQAAAA==.狂暴的鸽子:BAABKgAFFH8MAAIRAAYIOR29BwDNAQARAAYIOR29BwDNAQAAAA==.',['猎空']='猎空:BAABKgAFFH8GAAISAAYIWhikDwBqAQASAAYIWhikDwBqAQAAAA==.',['猎行']='猎行天下麒麟:BAAAKgAECgQIBAAAAA==.',['猫不']='猫不会微笑:BAAAKgAFFAQIBAAAAA==.猫不是我家滴:BAABKgAFFH8PAAQLAAUI6w3FBQC5AAALAAUI6w3FBQC5AAAKAAEIAAC/aQAAAAATAAEIAADJPQAAAAAAAA==.',['猫就']='猫就是我家滴:BAABKgAFFH8NAAMIAAYIkg7UDwAwAQAIAAYIkg7UDwAwAQAfAAQIIQMjCACMAAABKgAFFAgIGgACAEwhAA==.',['王丝']='王丝路:BAAAKgAFFAcIBAAAAA==.',['玛利']='玛利亚屁屁:BAAAKgADCggICAAAAA==.',['璃丶']='璃丶:BAAAKgAECgYIDQAAAA==.',['瓜瓜']='瓜瓜蛤:BAAAKgAECgYIEQAAAA==.',['生命']='生命终章:BAABKgAFFH8eAAQRAAYIhhGEDwBdAQARAAYIhhGEDwBdAQAeAAYIHx7kBAA3AQAaAAMIEBF4FQB4AAAAAA==.',['甩尾']='甩尾巴:BAAAKgAECgQIDwAAAA==.',['电动']='电动乀小马达:BAACKgAFFH8IAAICAAQIuxAkNADGAAACAAQIuxAkNADGAAAqAAQKfxgAAwIACAi9DG5XABwBAAIACAi9DG5XABwBACAAAQiJA3g6ACEAAAAA.',['电气']='电气精灵:BAAAKgADCggICAAAAA==.',['电驴']='电驴子:BAAAKgAECgEIAQAAAA==.',['疯狂']='疯狂的飞机丶:BAAAKgAECgUICAAAAA==.',['白洛']='白洛洛:BAAAKgAFFAQIBAABKgAFFAgIEgAQAIoWAA==.',['白芷']='白芷:BAAAKgAECgYIBAAAAA==.',['百发']='百发百中丶:BAAAKgAECggICAAAAA==.',['真好']='真好丸:BAAAKgAECggIAgAAAA==.',['眼见']='眼见喜:BAABKgAFFH8WAAMhAAYIOR1zAAB9AQAhAAUIABtzAAB9AQAiAAYI6wwlDgA6AQAAAA==.',['知易']='知易灬行难:BAAAKgAECgUIBQAAAA==.',['石川']='石川恩斯惠:BAAAKgAECggIEQAAAA==.',['石榴']='石榴妹:BAAAKgAECgEIAQAAAA==.',['硕言']='硕言:BAAAKgAECgQICAAAAA==.',['磨磨']='磨磨唧唧:BAABKgAFFH8NAAMWAAgIfhkOCACoAQAWAAYIbB4OCACoAQAMAAMIgBFKIQCeAAAAAA==.',['神聖']='神聖之舞:BAAAKgAECgYIBwAAAA==.',['移动']='移动荣誉丶:BAAAKgAECgMIAwAAAA==.',['穷胸']='穷胸饿急:BAAAKgADCgEIAQAAAA==.',['空欢']='空欢喜是:BAAAKgAECgMIAwAAAA==.',['空空']='空空子:BAAAKgAECgQIBQAAAA==.',['端坐']='端坐霜天:BAAAKgADCgEIAQAAAA==.',['笃定']='笃定:BAAAKgAECgcIBwAAAA==.',['等我']='等我升腾:BAABKgAFFH8OAAIRAAgI5RvVAADQAQARAAgI5RvVAADQAQAAAA==.',['等风']='等风起:BAABKgAECn8cAAIcAAgIRiJGBwCcAgAcAAgIRiJGBwCcAgAAAA==.',['简单']='简单的疯子:BAABKgAFFH8GAAIBAAYI8hEoFwBKAQABAAYI8hEoFwBKAQAAAA==.',['米唐']='米唐门:BAAAKgAECgIIAgAAAA==.',['粉牛']='粉牛:BAAAKgAECgQIBAAAAA==.',['糖门']='糖门佐道:BAAAKgAECgMIAwAAAA==.',['索拉']='索拉之緲:BAACKgAFFH8QAAMIAAMIsRRsDwDrAAAIAAMIsRRsDwDrAAAHAAIIhgWBGABuAAAqAAQKfxIAAggACAj1GxgWADcCAAgACAj1GxgWADcCAAAA.',['紫彤']='紫彤:BAABKgAFFH8GAAIWAAMIzwQgMQCBAAAWAAMIzwQgMQCBAAAAAA==.',['絳雪']='絳雪:BAAAKgAFFAgIBAAAAA==.',['纯害']='纯害人的:BAACKgAFFH8xAAMjAAgIJyPgAAC2AQAdAAgI3SCwAgCZAgAjAAUIjCTgAAC2AQAqAAQKfyIAAyMACAjPIfoGAHwCACMACAhOIfoGAHwCAB0AAgjGIFk0AK4AAAAA.',['练家']='练家子:BAAAKgAFFAIIAgAAAA==.',['给你']='给你一棒子:BAAAKgADCgMIAwAAAA==.',['给力']='给力就好:BAAAKgAECgEIAQAAAA==.',['绫丶']='绫丶:BAAAKgAECgYIAQAAAA==.',['编号']='编号:BAAAKgAECggICgAAAA==.',['罗姆']='罗姆:BAAAKgADCgMIAwAAAA==.',['羊超']='羊超越:BAAAKgADCggICAAAAA==.',['羽羽']='羽羽丰:BAABKgAFFH8PAAMIAAgIkAr0BwC1AQAIAAgIkAr0BwC1AQAfAAEIWQ4VCgA1AAAAAA==.',['翻滚']='翻滚蜜糖:BAAAKgADCgIIAgAAAA==.',['老子']='老子是天棒乄:BAAAKgAECgIIBAAAAA==.',['老铁']='老铁:BAABKgAECn8gAAIJAAgIjRRSKACcAQAJAAgIjRRSKACcAQAAAA==.',['耗爺']='耗爺:BAAAKgADCggICAAAAA==.',['耳聼']='耳聼怒:BAAAKgAFFAQIBAAAAA==.',['聆冰']='聆冰语:BAAAKgADCgMIAwAAAA==.',['肾虚']='肾虚骑士:BAAAKgAECgUIBQAAAA==.',['肾骑']='肾骑士:BAAAKgAFFAMIAwAAAA==.',['腊月']='腊月初柒:BAAAKgAECgUICAAAAA==.',['舌尝']='舌尝思:BAACKgAFFH8UAAMKAAYIQhhqFgBlAQAKAAYIQhhqFgBlAQATAAYIIxTWDwC1AAAqAAQKfxYAAxMACAiGGK0fAMoBABMACAiGGK0fAMoBAAoACAh+FAAAAAAAAAAA.',['艾斯']='艾斯卡诺:BAABKgAECn8YAAQEAAgItht0mQBkAQAEAAgIKRZ0mQBkAQAQAAQIZBH4MwDEAAAXAAMIkQlXSwBXAAAAAA==.',['花辰']='花辰月夕丶:BAAAKgADCggICAAAAA==.',['苏妲']='苏妲季:BAAAKgAECgYICAAAAA==.',['茉莉']='茉莉绝悬:BAAAKgAECgYIBAAAAA==.',['茶丶']='茶丶宝宝:BAAAKgAECgQIBwAAAA==.',['莫西']='莫西干男人:BAABKgAFFH8GAAIcAAYIlwwZDABMAQAcAAYIlwwZDABMAQAAAA==.',['莱戈']='莱戈拉斯乄:BAAAKgAFFAIIAgAAAA==.',['萌物']='萌物:BAAAKgADCgQIBwAAAA==.',['萌萌']='萌萌蒂法:BAAAKgADCgEIAQAAAA==.',['落月']='落月沉星:BAAAKgAFFAQIBAAAAA==.',['葉奈']='葉奈法:BAABKgAFFH8GAAIFAAYIbhFIEgBrAQAFAAYIbhFIEgBrAQAAAA==.',['葬爱']='葬爱十七:BAAAKgAECgIIAgAAAA==.葬爱家族:BAAAKgADCgcICgAAAA==.',['蒋劲']='蒋劲夫:BAABKgAFFH8IAAIJAAQIgRowDQAGAQAJAAQIgRowDQAGAQAAAA==.',['蔷薇']='蔷薇绅士:BAABKgAFFH8GAAIOAAYICBsIEQBhAQAOAAYICBsIEQBhAQAAAA==.',['薩醤']='薩醤:BAAAKgAECgMIAwAAAA==.',['虚空']='虚空:BAAAKgAFFAEIAQAAAA==.',['蜜雪']='蜜雪冰橙:BAABKgAFFH8GAAIFAAIIQBqWKgCKAAAFAAIIQBqWKgCKAAAAAA==.',['血色']='血色琉璃:BAAAKgAECgEIAQAAAA==.',['袁小']='袁小喵:BAAAKgAECgYICAAAAA==.',['裤子']='裤子先生丶:BAAAKgAECgEIAQAAAA==.',['言念']='言念君子:BAABKgAFFH8IAAIRAAQIcCICDQD0AAARAAQIcCICDQD0AAAAAA==.',['诗芳']='诗芳:BAABKgAFFH8GAAIIAAYIfgvIGQCvAAAIAAYIfgvIGQCvAAABKgAFFAgIAQAIALEJAA==.',['语过']='语过嫣然:BAAAKgADCgUIBQAAAA==.',['贫道']='贫道劫个色:BAAAKgAFFAgIBAAAAA==.',['贱仔']='贱仔:BAAAKgADCggICAAAAA==.',['践踏']='践踏战争:BAAAKgAECgcIBwAAAA==.',['踏天']='踏天之巅:BAAAKgADCgIIAgAAAA==.',['身本']='身本懮:BAABKgAFFH8QAAQMAAYIER/NAQC3AQAMAAYIGRnNAQC3AQAWAAQIEiPBAwAoAQAVAAII4Ql3HgB2AAAAAA==.',['辣辣']='辣辣娜娜:BAABKgAECn8eAAMRAAgIOh43FABPAgARAAgIOh43FABPAgAaAAcIPhDqNgA6AQAAAA==.',['迷你']='迷你烤鸡翅:BAABKgAFFH8NAAIIAAYIXBzUCQCOAQAIAAYIXBzUCQCOAQAAAA==.',['追忆']='追忆忘却回忆:BAAAKgAECgEIAQAAAA==.',['逆水']='逆水魔乳:BAAAKgAECggICQAAAA==.',['透明']='透明玻璃:BAAAKgAECgEIAQAAAA==.',['邪能']='邪能奶茶:BAABKgAFFH8GAAIFAAYI2htdDwCQAQAFAAYI2htdDwCQAQAAAA==.',['酒鬼']='酒鬼玉米:BAAAKgAECgIIAgAAAA==.',['醉月']='醉月丶觞:BAABKgAFFH8OAAMOAAYIRx1IDwB1AQAOAAYIXBxIDwB1AQAPAAQIUhy5EwABAQAAAA==.',['重返']='重返云贵川:BAAAKgADCgUIBQAAAA==.',['銅鑼']='銅鑼灣扛把子:BAAAKgAFFAEIAQAAAA==.',['钕神']='钕神矜嘚祈愿:BAABKgAFFH8GAAMWAAYI+w2SEQAlAQAWAAQIkhOSEQAlAQAMAAIIzQJUIwBlAAAAAA==.',['铺路']='铺路的:BAAAKgADCggICAAAAA==.',['锯末']='锯末慕师:BAAAKgADCgEIAwAAAA==.',['镰刀']='镰刀来了:BAAAKgAFFAQIBAAAAA==.',['闲渔']='闲渔:BAAAKgADCggIEQAAAA==.',['阿斯']='阿斯达玛吉:BAAAKgAECgMIAwAAAA==.',['阿水']='阿水的幻影:BAAAKgAECggIEQAAAA==.',['阿纳']='阿纳克洛斯:BAAAKgAECgQIBgAAAA==.',['阿罗']='阿罗跟:BAAAKgAECgQIBgAAAA==.',['阿豪']='阿豪诶:BAABKgAFFH8FAAIEAAMIxxLvNwCZAAAEAAMIxxLvNwCZAAAAAA==.',['陆佰']='陆佰壹拾柒:BAAAKgAECgEIAQAAAA==.',['隐秘']='隐秘通途:BAAAKgAFFAMIAwAAAA==.',['隔离']='隔离屋只牛:BAAAKgAECggICAAAAA==.',['雄性']='雄性激素:BAAAKgADCgEIAQAAAA==.',['霜火']='霜火圣光:BAABKgAFFH8LAAIEAAYIxhxcFwD9AAAEAAYIxhxcFwD9AAAAAA==.',['青椒']='青椒荷包蛋:BAAAKgAFFAIIAgAAAA==.',['面包']='面包夹黄瓜:BAAAKgADCgYIBgAAAA==.',['鞭鞭']='鞭鞭:BAAAKgAECgIIAgAAAA==.',['顺数']='顺数倒数第一:BAABKgAECn8xAAMTAAgI/xLSEQBSAQATAAgI/xLSEQBSAQAKAAcISQopngCYAAAAAA==.顺数倒数第七:BAAAKgAFFAIIAgAAAA==.',['风情']='风情微解:BAAAKgADCggIEAAAAA==.',['风流']='风流风流战神:BAAAKgAECgUICAAAAA==.',['风采']='风采依旧:BAABKgAECn8VAAMYAAgIiwl7NQAgAQAYAAgIXAl7NQAgAQABAAEINQyFlgAjAAAAAA==.',['魂牵']='魂牵梦绕丶:BAAAKgADCggICAAAAA==.',['魔法']='魔法披风:BAAAKgADCgEIAQAAAA==.',['鱼心']='鱼心丸子:BAAAKgAFFAIIAgAAAA==.',['鸡脖']='鸡脖断:BAAAKgAECgYIBgAAAA==.',['麦香']='麦香园:BAABKgAFFH8MAAIRAAYIthtoCQCvAQARAAYIthtoCQCvAQAAAA==.',['黄黄']='黄黄的圈圈:BAAAKgAECgEIAgAAAA==.黄黄的新圆圈:BAAAKgAECgcICQAAAA==.黄黄的月饼:BAAAKgADCgQIBgAAAA==.',['黎明']='黎明前的审判:BAABKgAFFH8JAAICAAMI1xSuLQDYAAACAAMI1xSuLQDYAAABKgAFFAgIFAAFAOMZAA==.黎明的光晕:BAAAKgAECggIEQAAAA==.',['黑夜']='黑夜灬沉沦:BAAAKgAECgYIBgAAAA==.黑夜灬绽放:BAAAKgAECgMIAwAAAA==.',['黑暗']='黑暗星云:BAAAKgAFFAUIAgAAAA==.',['黑毛']='黑毛鸡:BAABKgAFFH8MAAIPAAYI3hrOBQCoAQAPAAYI3hrOBQCoAQAAAA==.',['黑白']='黑白的光:BAABKgAFFH8GAAMWAAYIKRD/GwDeAAAWAAUIsRH/GwDeAAAMAAEIBgrQMABMAAAAAA==.',['黑豌']='黑豌豆:BAAAKgADCgEIAgAAAA==.',['鼻嗅']='鼻嗅爱:BAABKgAFFH8WAAMQAAgIRRp8AgBFAgAQAAgIRRp8AgBFAgAEAAQI4wW0MQCdAAAAAA==.',['龍少']='龍少爷:BAABKgAFFH8LAAIEAAgIIRp2BgBjAgAEAAgIIRp2BgBjAgAAAA==.',['龘龖']='龘龖龘:BAAAKgAECgUIBQABKgAFFAgIAgAbAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end