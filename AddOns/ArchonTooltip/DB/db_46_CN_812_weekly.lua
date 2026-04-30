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

local lookup = {'Mage-Frost','Evoker-Preservation','Evoker-Augmentation','DemonHunter-Devourer','DemonHunter-Havoc','Warlock-Demonology','Priest-Discipline','Priest-Holy','Priest-Shadow','Paladin-Holy','Evoker-Devastation','Shaman-Restoration','Paladin-Retribution','Druid-Restoration','Druid-Guardian','Shaman-Elemental','Monk-Brewmaster','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Warlock-Destruction','Warrior-Arms','Warrior-Fury','Warrior-Protection','DeathKnight-Unholy',}
local provider = {region='CN',realm='莱索恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aei:BAAALgAECgEJAQAAAA==.',
Co='Cortezfly:BAAALgAECgcJBwAAAA==.',
Dr='Dreamwalker:BAAALgAECgEJAgAAAA==.Druids:BAAALgADCgMJAwAAAA==.',
Fr='Freestyler:BAAALgADCgcJBgAAAA==.',
Hi='Hikaru:BAAALgAECgkJBgABLgAFFAYJBgABABIBAA==.',
Ji='Jijimaoa:BAAALgAFFAEJAgAAAA==.',
Ku='Kumo:BAAALgAFFAUJAwAAAA==.',
Li='Linsa:BAAALgAFFAEJAQAAAA==.Litmanner:BAAALgAECgIJAgAAAA==.',
Lv='Lvelve:BAAALgAECgYJBgAAAA==.',
Lz='Lzo:BAAALgAECgEJBAAAAA==.',
Ma='Mastablasta:BAAALgAFFAIJAgAAAA==.',
Mi='Minerval:BAAALgADCgIJAgAAAA==.',
Ok='Okur:BAAALgAFFAIJAgAAAA==.',
Pl='Playeropjowl:BAAALgAECgYJCgAAAA==.',
Rv='Rvca:BAACLgAFFH8VAAICAAYJUh90AQArAgACAAYJUh90AQArAgAuAAQKfxYAAwIACAmVG1YQADYCAAIABwk6HVYQADYCAAMABQlmGlIgAL4BAAAA.',
Tl='Tlee:BAACLgAFFH8GAAMEAAMJpgXTGwCQAAAEAAMJpgXTGwCQAAAFAAEJvgC2BwA2AAAuAAQKfxQAAwQABwm1EhZfAIQBAAQABwlhEhZfAIQBAAUABAmsDHlKAMcAAAAA.',
['一刀']='一刀杀:BAAALgAFFAEJAQAAAA==.',
['一曲']='一曲震魂:BAAALgAFFAIJBAABLgAFFAQJCAAGAFASAA==.',
['一神']='一神牧一:BAACLgAFFH8RAAIHAAUJfCTIAQAXAgAHAAUJfCTIAQAXAgAuAAQKfyMABAcACQlgJBQDAD8DAAcACAn3IxQDAD8DAAgABwmNJMwJALACAAkAAwnvIYE5ACQBAAAA.',
['七夜']='七夜魔君:BAAALgAECgYJBgAAAA==.',
['不朽']='不朽的圣光:BAACLgAFFH8HAAIKAAMJBRG4FACbAAAKAAMJBRG4FACbAAAuAAQKfxwAAgoABwnvFBYrANsBAAoABwnvFBYrANsBAAAA.',
['世界']='世界需要战神:BAAALgAECgcJCgAAAA==.',
['两个']='两个貂蝉一起:BAAALgAECgUJBQAAAA==.',
['丨大']='丨大花轿丨:BAAALgAECgkJBgAAAA==.',
['丨秋']='丨秋天丨:BAAALgAECgQJBwAAAA==.',
['中单']='中单不买鸡:BAAALgAECgUJBQAAAA==.',
['丶墨']='丶墨香:BAAALgAECgcJDQAAAA==.',
['丿灬']='丿灬龙少:BAAALgAECgEJAQAAAA==.',
['乂百']='乂百步穿杨:BAAALgADCgYJBgAAAA==.',
['乾源']='乾源噬灭:BAAALgAECgYJDwAAAA==.',
['二等']='二等饼干:BAAALgAECgIJAgAAAA==.',
['于是']='于是葛格:BAAALgADCgcJDQAAAA==.',
['亚托']='亚托克斯:BAAALgAECgUJCQAAAA==.',
['代表']='代表圣光:BAAALgAECgEJAQAAAA==.',
['以德']='以德扶你:BAAALgADCgYJBwAAAA==.',
['伊利']='伊利达雷之怒:BAAALgADCgEJAQAAAA==.',
['伊登']='伊登的苹果:BAACLgAFFH8IAAIKAAMJlRiTDgDtAAAKAAMJlRiTDgDtAAAuAAQKfxcAAgoACQkDFfcaAD0CAAoACQkDFfcaAD0CAAAA.',
['会梦']='会梦之圈:BAABLgAFFH8IAAMHAAQJ+QPACQC/AAAHAAQJ7wHACQC/AAAIAAIJ3gYfDwCFAAAAAA==.',
['促醉']='促醉:BAAALgAECgEJAwAAAA==.',
['俢囉']='俢囉戰魂:BAAALgAECgYJDAAAAA==.',
['俢羅']='俢羅戰噫:BAAALgADCgEJAQAAAA==.',
['修儸']='修儸栤:BAAALgAECgEJAQAAAA==.',
['俱利']='俱利伽罗天童:BAABLgAECn8bAAMDAAkJZhbdFAA3AgADAAgJmBfdFAA3AgALAAQJxQ+bJAABAQAAAA==.',
['光芒']='光芒纽扣:BAAALgAFFAEJAQABLgAFFAUJDwAIAEkZAA==.',
['关羽']='关羽:BAAALgAECgUJBwAAAA==.',
['冰洁']='冰洁雪儿:BAABLgAECn8aAAIHAAgJkBtuAgBfAgAHAAgJkBtuAgBfAgAAAA==.',
['冰飘']='冰飘雪:BAAALgAECgEJAgAAAA==.',
['凤丫']='凤丫头:BAABLgAECn8VAAIMAAcJLws8HADxAAAMAAcJLws8HADxAAAAAA==.',
['刀刀']='刀刀必暴:BAAALgAECgQJBAAAAA==.',
['刀疤']='刀疤贝里钱:BAAALgAECgEJAQAAAA==.',
['划水']='划水的劣人:BAAALgADCgYJCAAAAA==.',
['剛剛']='剛剛:BAAALgAECgcJBwAAAA==.',
['北饮']='北饮风:BAABLgAECn8VAAINAAcJbRbnVwDbAQANAAcJbRbnVwDbAQAAAA==.',
['十字']='十字軍咄咄:BAAALgAECgYJBgAAAA==.',
['千变']='千变之万化:BAABLgAECn8WAAMOAAcJcQgtbAAPAQAOAAcJcQgtbAAPAQAPAAEJTgEXOgASAAAAAA==.',
['单小']='单小龙:BAABLgAECn8XAAILAAgJhBdlCQBKAgALAAgJhBdlCQBKAgABLgAFFAUJBgACAFYWAA==.',
['南歌']='南歌:BAAALgAFFAEJAQAAAA==.',
['南琴']='南琴梨:BAAALgAECgUJBQABLgAFFAQJDgABAFUWAA==.',
['卝卝']='卝卝:BAAALgAECgIJAgAAAA==.',
['卡尔']='卡尔王:BAAALgAECgMJAwAAAA==.',
['叶丿']='叶丿无双:BAAALgAECgQJBwAAAA==.叶丿晓霜:BAAALgADCgYJBgAAAA==.',
['名誉']='名誉:BAAALgADCgIJAgAAAA==.',
['吾愛']='吾愛國:BAAALgAECgcJCwAAAA==.',
['咕哒']='咕哒子本咕:BAAALgAECgEJAQAAAA==.',
['哞哞']='哞哞哒:BAAALgAECgcJDwAAAA==.',
['哥布']='哥布林王子:BAABLgAFFH8IAAIGAAQJUBLsCABMAQAGAAQJUBLsCABMAQAAAA==.',
['嗦莱']='嗦莱恩:BAAALgAECgYJBgAAAA==.',
['嘿鎍']='嘿鎍:BAAALgAFFAUJBAABLgAFFAYJEwANAMggAA==.',
['嚓嚓']='嚓嚓攃:BAAALgADCgUJBQAAAA==.',
['团队']='团队灬领袖:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光之莉:BAAALgAECgEJAQABLgAFFAUJDwAIAEkZAA==.圣光演员:BAAALgAECgEJAQAAAA==.圣光猛牛:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落骑士:BAAALgAECgUJBwAAAA==.',
['夏野']='夏野与暗恋:BAAALgAECgQJBgAAAA==.',
['多尼']='多尼多尼:BAABLgAECn8VAAMQAAcJVh0jGgBCAgAQAAcJVh0jGgBCAgAMAAQJTBYXYAAMAQAAAA==.',
['夜之']='夜之森叁:BAAALgAFFAIJAgAAAA==.',
['夜入']='夜入深秋:BAAALgAECgEJAQAAAA==.',
['夜怨']='夜怨丶凌风:BAAALgAECgEJAQAAAA==.',
['夢幻']='夢幻泡影:BAAALgAECgEJAQAAAA==.',
['大郎']='大郎来玩吖:BAAALgAECgMJAwAAAA==.',
['天命']='天命仙羽:BAAALgAECgEJAQAAAA==.',
['夲夲']='夲夲丶圣骑:BAAALgAECgEJAQAAAA==.',
['奶不']='奶不住仁:BAAALgAECgcJBwAAAA==.',
['奶德']='奶德不能再奶:BAAALgAECgIJAgAAAA==.',
['好奇']='好奇害死猫丶:BAAALgAECgcJEwAAAA==.',
['好牛']='好牛哔:BAAALgAECgcJEQAAAA==.',
['如果']='如果有梦:BAAALgAECgQJBwAAAA==.',
['如花']='如花丶:BAAALgAECgIJAgAAAA==.',
['妖精']='妖精:BAAALgAECgEJAgAAAA==.',
['姚总']='姚总休闲:BAAALgAECgEJAQAAAA==.姚总摆摊:BAAALgAECgEJAQAAAA==.',
['小可']='小可怜兔子:BAAALgADCgYJBgAAAA==.',
['小柠']='小柠萌吖:BAAALgAFFAQJBAAAAA==.',
['小汤']='小汤圜:BAABLgAECn8jAAMIAAgJhxT/CACYAQAIAAcJ5Rb/CACYAQAHAAcJbgoHJwBdAQAAAA==.',
['小珑']='小珑女:BAAALgAECgcJBwAAAA==.',
['小龙']='小龙卷:BAAALgAECgEJAQABLgAFFAQJCAAGAFASAA==.',
['巧克']='巧克力布朗尼:BAACLgAFFH8JAAIEAAUJTQ9JCgCIAQAEAAUJTQ9JCgCIAQAuAAQKfxQAAwQACAm9E7lJAM0BAAQACAlsEblJAM0BAAUABgkqF7EwAEwBAAAA.',
['幽冥']='幽冥女帝:BAAALgAECgEJAQAAAA==.',
['开摆']='开摆:BAACLgAFFH8SAAIRAAUJ+hBHBgBvAQARAAUJ+hBHBgBvAQAuAAQKfyQAAhEACAm8IJ0LANMCABEACAm8IJ0LANMCAAAA.',
['思该']='思该:BAAALgAECgEJAQAAAA==.',
['恨沧']='恨沧海:BAAALgADCgUJBQAAAA==.',
['息影']='息影皇后:BAAALgADCgQJBAAAAA==.',
['恶魔']='恶魔铲屎官:BAAALgAECgUJBQAAAA==.',
['悠悠']='悠悠小法:BAABLgAECn8VAAIBAAcJng8smQCiAQABAAcJng8smQCiAQAAAA==.',
['惊爆']='惊爆旅行团:BAAALgAECgUJCgAAAA==.',
['想死']='想死你说话:BAAALgADCgIJAgAAAA==.',
['愿与']='愿与愁:BAAALgADCgEJAQAAAA==.',
['慧根']='慧根儿:BAAALgADCgEJAQAAAA==.',
['我的']='我的角很大:BAAALgAFFAIJBAAAAA==.',
['战神']='战神一小猎:BAAALgAECgEJAgAAAA==.',
['拳头']='拳头霸爸:BAAALgAECgQJBAAAAA==.',
['摩西']='摩西尐姐:BAAALgAECgYJBgAAAA==.',
['救世']='救世萨:BAAALgAECgYJBgAAAA==.',
['无妄']='无妄居士:BAAALgAECgQJBQAAAA==.',
['昊天']='昊天:BAAALgAECgYJBwAAAA==.',
['星碎']='星碎魔袭:BAAALgAECgEJAQAAAA==.',
['映橪']='映橪柒語:BAABLgAFFH8GAAISAAMJORJcDgD5AAASAAMJORJcDgD5AAAAAA==.',
['春满']='春满花城:BAAALgAECgUJBQAAAA==.',
['暖暖']='暖暖的翡冷翠:BAAALgAECgMJAwAAAA==.',
['暨鈅']='暨鈅:BAAALgAECgIJAQAAAA==.',
['暴躁']='暴躁小喵:BAABLgAECn8UAAITAAgJwiLXCAAFAwATAAgJwiLXCAAFAwABLgAFFAUJBQATAG0ZAA==.',
['最后']='最后一滴雪:BAAALgAECgEJAQAAAA==.',
['月丶']='月丶运转:BAAALgAFFAEJAQABLgAFFAUJBQAHANEPAA==.',
['月曦']='月曦神恩特使:BAAALgAECgIJBQAAAA==.',
['有一']='有一点淘气:BAABLgAECn8XAAINAAcJHARzrwAkAQANAAcJHARzrwAkAQAAAA==.',
['李胖']='李胖墩:BAAALgAECgcJAwABLgAFFAUJBQASANURAA==.',
['来伊']='来伊贝:BAAALgAECgEJAgAAAA==.',
['柠萌']='柠萌:BAAALgAFFAQJBAAAAA==.柠萌七分甜:BAAALgAECgcJCAAAAA==.柠萌冰激凌:BAAALgAECgkJDwAAAA==.柠萌嗷呜呜:BAAALgAFFAQJBAAAAA==.柠萌尐姐:BAACLgAFFH8IAAMTAAQJbRWGAwBlAQATAAQJbRWGAwBlAQAUAAEJtgkRLABCAAAuAAQKfx0AAxMACQnuGx4YAHgCABMACQkeGB4YAHgCABQABwnhGTEjAAoCAAAA.柠萌美琳娜:BAAALgAECgYJBgAAAA==.',
['梦丶']='梦丶点滴五世:BAAALgAFFAIJAwAAAA==.',
['楓葉']='楓葉幽靈:BAAALgAECgkJBwAAAA==.',
['楚兮']='楚兮:BAABLgAECn8VAAIRAAcJxw/EOABnAQARAAcJxw/EOABnAQAAAA==.',
['樱花']='樱花葬顺天:BAAALgAECgMJAwAAAA==.',
['檀裳']='檀裳:BAAALgAFFAMJBAAAAA==.',
['欢愉']='欢愉丶咖啡豆:BAAALgAECgYJCQAAAA==.',
['毁灭']='毁灭丶毁伤:BAAALgAECgYJCwAAAA==.',
['汩汩']='汩汩:BAAALgAECgcJBwAAAA==.',
['沉海']='沉海的歌:BAAALgAECgkJCQAAAA==.',
['油炸']='油炸灬花生米:BAAALgAECgMJAwAAAA==.',
['洛丹']='洛丹伦的秋叶:BAABLgAECn8VAAIVAAcJLwzPIwAiAQAVAAcJLwzPIwAiAQAAAA==.',
['淡烟']='淡烟流水:BAABLgAECn8XAAIMAAcJyB02FQBrAgAMAAcJyB02FQBrAgAAAA==.',
['清风']='清风:BAAALgAECgQJBAAAAA==.',
['溡緔']='溡緔瘋雪:BAAALgAECgIJAgAAAA==.',
['潜龙']='潜龙伏恶渊:BAAALgADCgcJBwAAAA==.',
['火火']='火火爱将:BAAALgAECgEJAQAAAA==.',
['灬熙']='灬熙:BAABLgAECn8WAAMEAAcJCxDuMADaAAAEAAcJCxDuMADaAAAFAAQJcwWQUQCkAAAAAA==.',
['灬菜']='灬菜饼丶丨斩:BAAALgADCgEJAQAAAA==.',
['灰灰']='灰灰牛:BAAALgAECgcJEAAAAA==.',
['炊事']='炊事班长:BAAALgAECgQJBAAAAA==.',
['炼狱']='炼狱之蛋锤:BAAALgAECgYJBwAAAA==.',
['焖鸡']='焖鸡兄:BAAALgADCgYJBgAAAA==.',
['牛牛']='牛牛妈:BAAALgAECgEJAwAAAA==.',
['猪小']='猪小熊:BAAALgAECgEJAQAAAA==.',
['猪猪']='猪猪打窦窦:BAAALgAECgIJAgAAAA==.',
['猫熊']='猫熊酒仙:BAAALgAFFAIJBAAAAA==.',
['班主']='班主任:BAABLgAECn8VAAIHAAcJPRPZHQCmAQAHAAcJPRPZHQCmAQAAAA==.',
['琴键']='琴键上的黑白:BAABLgAFFH8HAAINAAQJxBldAwBwAQANAAQJxBldAwBwAQABLgAFFAQJCAAGAFASAA==.',
['璀璨']='璀璨丨死骑:BAAALgAECgQJBgAAAA==.',
['疑是']='疑是银河:BAAALgADCgcJBwAAAA==.',
['百变']='百变星君:BAAALgAECgEJAQAAAA==.',
['真夜']='真夜灬随风:BAAALgAECgEJAQAAAA==.',
['知足']='知足:BAAALgADCgYJBgAAAA==.',
['破马']='破马张飞的:BAAALgAECgYJBgAAAA==.',
['神圣']='神圣风暴:BAAALgAECgIJAQAAAA==.',
['秋秋']='秋秋:BAAALgAECgkJCQAAAA==.',
['秦川']='秦川牛:BAAALgADCgEJAQAAAA==.',
['竹叶']='竹叶青:BAAALgAECgQJBQAAAA==.',
['精灵']='精灵帕拉丁:BAAALgAFFAEJAgAAAA==.',
['糖门']='糖门高手:BAABLgAECn8VAAIGAAcJoAuFLwD6AAAGAAcJoAuFLwD6AAAAAA==.',
['紫色']='紫色恋歌:BAAALgAECgEJAgAAAA==.',
['绘梦']='绘梦之全:BAAALgAECgMJBAAAAA==.绘梦之龙:BAAALgAFFAMJAwAAAA==.',
['美艳']='美艳如花:BAABLgAFFH8HAAIOAAMJrA36EwDIAAAOAAMJrA36EwDIAAAAAA==.',
['肥嘟']='肥嘟嘟:BAAALgAFFAQJBAAAAA==.',
['能源']='能源者:BAABLgAECn8VAAIBAAcJiRSnfwDRAQABAAcJiRSnfwDRAQAAAA==.',
['艾利']='艾利丶欧格:BAAALgAECgQJAwAAAA==.',
['艾露']='艾露蒽之光:BAAALgAECgYJDwAAAA==.',
['艾音']='艾音塞露:BAAALgAECgYJCgABLgAFFAQJBgAGAEoKAA==.',
['花招']='花招儿:BAAALgADCgcJBwAAAA==.',
['芳心']='芳心纵火犯:BAAALgAECgEJAwAAAA==.',
['萌猫']='萌猫灬猫:BAAALgAECgUJCAAAAA==.',
['萨爷']='萨爷教你做人:BAAALgAECgEJAQAAAA==.',
['蔡依']='蔡依林:BAAALgAECgMJBAAAAA==.',
['薄荷']='薄荷丶紅嗏:BAAALgAECgIJAwAAAA==.',
['藥到']='藥到命除:BAACLgAFFH8FAAIOAAMJXCImBgA0AQAOAAMJXCImBgA0AQAuAAQKfxoAAg4ACQnpGyUQALcCAA4ACQnpGyUQALcCAAAA.',
['西瓜']='西瓜太凉:BAAALgADCgIJAgAAAA==.',
['西鎍']='西鎍:BAAALgAECgEJAgAAAA==.',
['詩言']='詩言丶:BAAALgAECgkJDgAAAA==.',
['貓小']='貓小逗:BAAALgAECgIJAgAAAA==.',
['过河']='过河卒:BAAALgAECgEJAQAAAA==.',
['还不']='还不如喜羊羊:BAABLgAFFH8FAAIKAAMJSSN8BQA0AQAKAAMJSSN8BQA0AQAAAA==.',
['还是']='还是恶魔:BAAALgAECgcJAQAAAA==.',
['邪念']='邪念:BAACLgAFFH8NAAIGAAQJXhElFQBEAQAGAAQJXhElFQBEAQAuAAQKfx0AAwYACAmQHTceAKICAAYACAmQHTceAKICABYAAQkAAHV1AC8AAAAA.',
['部落']='部落上等兵:BAABLgAECn8VAAQXAAcJVBE6HgD9AAAXAAQJZRI6HgD9AAAYAAcJfwviHADTAAAZAAEJsQ0cRwAxAAAAAA==.',
['酥脆']='酥脆曲奇:BAABLgAECn8VAAIGAAcJRBYJSwDoAQAGAAcJRBYJSwDoAQAAAA==.',
['醉后']='醉后一螩喍:BAAALgAECgEJAQAAAA==.',
['醉落']='醉落沙场:BAAALgAFFAEJAwAAAA==.',
['醉风']='醉风行:BAAALgAECggJCQAAAA==.',
['鐵心']='鐵心:BAABLgAECn8VAAIaAAcJbBrMUQD8AQAaAAcJbBrMUQD8AQAAAA==.',
['锐雯']='锐雯:BAAALgAECgMJBQAAAA==.',
['锦江']='锦江渝:BAABLgAECn8VAAIYAAcJqxuDHABpAgAYAAcJqxuDHABpAgAAAA==.',
['锦添']='锦添:BAAALgADCgYJBgAAAA==.',
['阮秀']='阮秀爱吃甜食:BAAALgAFFAIJBAAAAA==.',
['阿帽']='阿帽:BAAALgAECgIJAgAAAA==.',
['阿芙']='阿芙罗狄蒂:BAAALgAECgYJCAAAAA==.',
['雨天']='雨天下的阳光:BAAALgAECgEJAQAAAA==.',
['霜吼']='霜吼:BAABLgAFFH8FAAMVAAIJtgJwDQAvAAAaAAEJ8gB1XABBAAAVAAIJtgJwDQAvAAAAAA==.',
['靈魂']='靈魂脫臼:BAAALgAECgYJDwAAAA==.',
['静静']='静静熙熙无心:BAAALgAECgkJCQAAAA==.',
['頂尖']='頂尖高手:BAAALgAECgEJAQAAAA==.',
['頹廢']='頹廢的过去:BAAALgAECgEJAQAAAA==.',
['风中']='风中的梵高:BAAALgAECgEJAQAAAA==.',
['风雷']='风雷之翼:BAAALgAECgYJBgAAAA==.',
['马乐']='马乐法克:BAAALgADCgUJBQAAAA==.',
['魔影']='魔影圣痕:BAAALgAECgYJEgAAAA==.',
['魔法']='魔法少女喵:BAAALgAECgYJBwAAAA==.',
['魔灬']='魔灬鬼:BAAALgAECgEJAgAAAA==.',
['魔異']='魔異貝貝:BAAALgAECgYJBgAAAA==.',
['鱼长']='鱼长大了:BAAALgAECggJEgAAAA==.',
['鳯小']='鳯小凰:BAAALgAECgkJCQAAAA==.',
['鳯钗']='鳯钗丨小娘惹:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗大主教:BAAALgAECgYJBgAAAA==.',
['龍丶']='龍丶熙熙:BAABLgAECn8UAAMIAAYJCQudGgCXAAAIAAYJCQudGgCXAAAHAAQJSAKxRACSAAAAAA==.',
['龍護']='龍護衞:BAAALgADCgcJCwAAAA==.',
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
