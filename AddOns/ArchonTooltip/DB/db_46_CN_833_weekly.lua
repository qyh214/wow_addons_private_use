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

local lookup = {'Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Mage-Frost','DeathKnight-Unholy','DemonHunter-Devourer','Monk-Mistweaver','Paladin-Holy','DeathKnight-Blood','Warrior-Protection','Warrior-Fury','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Mage-Arcane','Monk-Brewmaster','Priest-Discipline','Shaman-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Restoration','Shaman-Elemental','Druid-Guardian',}
local provider = {region='CN',realm='踏梦者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adfgdg:BAAALgAECgMJAwAAAA==.',
Be='Beforeafter:BAABLgAFFH8LAAIBAAUJeiILAwD/AQABAAUJeiILAwD/AQABLgAFFAcJFQABACIgAA==.',
Bi='Bittergourd:BAABLgAFFH8VAAIBAAcJIiAXAAByAgABAAcJIiAXAAByAgAAAA==.',
Bl='Blessing:BAABLgAECn8VAAQBAAkJzB51CQDgAgABAAgJyh11CQDgAgACAAUJbxkrIAAsAQADAAIJhxPBPACEAAABLgAFFAcJFQABACIgAA==.',
Br='Bro:BAACLgAFFH8HAAIEAAMJdBhjKAASAQAEAAMJdBhjKAASAQAuAAQKfxcAAgQACAm6HkktAL0CAAQACAm6HkktAL0CAAAA.',
Bs='Bsdklfjl:BAAALgAECgkJBwAAAA==.',
Df='Dfgdh:BAAALgAFFAQJBAAAAA==.Dflgkjdjlk:BAAALgADCgEJAQAAAA==.',
Dz='Dzklkljl:BAAALgAECgkJAgAAAA==.',
Fs='Fsdgdh:BAAALgAECgYJBgAAAA==.',
Gf='Gfhgh:BAACLgAFFH8GAAMCAAMJwRl+AQDDAAACAAIJKBp+AQDDAAABAAEJ8xhqHwBVAAAuAAQKfxoAAwIACAkHHZcLACECAAEACAlSGLsTAEYCAAIABgnrIJcLACECAAAA.',
Hg='Hgjghj:BAAALgAECgYJBgAAAA==.',
Hy='Hydedragon:BAAALgAFFAUJAgAAAA==.',
Ja='Jaina:BAABLgAFFH8IAAIFAAQJHSEiAwCBAQAFAAQJHSEiAwCBAQAAAA==.',
Jy='Jyy:BAAALgAFFAQJBAAAAA==.',
Kb='Kbwsixteen:BAAALgAECgcJBwAAAA==.',
Ls='Lsblood:BAAALgAECgYJCAAAAA==.',
Lu='Luckydemon:BAABLgAFFH8FAAIGAAMJlg8oHADxAAAGAAMJlg8oHADxAAAAAA==.Luckypaladin:BAAALgAECgUJBQAAAA==.',
Ma='Magaleta:BAAALgAECgcJAwAAAA==.',
Oa='Oay:BAAALgAECgYJEAAAAA==.',
Pr='Prada:BAAALgADCgUJBQAAAA==.',
Rt='Rtye:BAAALgAECgcJBgAAAA==.',
Sh='Sheepie:BAAALgAFFAIJBAAAAA==.',
Sy='Sylvanasscy:BAAALgAECgQJBAAAAA==.',
Ty='Tyu:BAAALgAECgYJCAAAAA==.',
Yh='Yhjgfhfgh:BAAALgAECgkJBQAAAA==.',
Yl='Yly:BAAALgAECgkJDgAAAA==.',
['一弯']='一弯孤月:BAAALgAECgcJCgAAAA==.',
['一德']='一德唬人:BAAALgAECgIJAgAAAA==.',
['一軍']='一軍一长一:BAAALgAECgEJAQAAAA==.',
['両丶']='両丶逸丶渃:BAAALgAECgQJBAAAAA==.',
['两逸']='两逸諾:BAAALgAECgEJAgAAAA==.',
['丨众']='丨众星丨:BAACLgAFFH8UAAIDAAYJxSUuAABuAgADAAYJxSUuAABuAgAuAAQKfyUAAgMACQlHIm0BAHEDAAMACQlHIm0BAHEDAAEuAAUUBQkPAAcAMiIA.',
['丨孑']='丨孑不语丨:BAAALgAECgYJCAAAAA==.',
['丨懒']='丨懒大王丨:BAAALgAECgYJBgAAAA==.丨懒羊羊丨:BAACLgAFFH8IAAIIAAMJaB9IDAAZAQAIAAMJaB9IDAAZAQAuAAQKfxkAAggABwkHJZ8IAOQCAAgABwkHJZ8IAOQCAAAA.',
['丨行']='丨行不晚丨:BAABLgAFFH8FAAIHAAIJzhxXDwClAAAHAAIJzhxXDwClAAAAAA==.',
['丰洳']='丰洳肥涒:BAAALgAECgEJAQAAAA==.',
['丷爱']='丷爱似水仙丷:BAAALgAFFAEJAQAAAA==.',
['丿彼']='丿彼时归:BAAALgAECgMJAwAAAA==.',
['乌尔']='乌尔扎戈:BAAALgAECgYJBgAAAA==.',
['乌拉']='乌拉萨奇:BAAALgAECgYJBwAAAA==.',
['乔伊']='乔伊斯:BAAALgAFFAQJBAAAAA==.',
['乘黄']='乘黄御风:BAAALgAECgcJEAAAAA==.',
['九十']='九十四个萨满:BAAALgAECgYJCwAAAA==.',
['事了']='事了拂衣:BAAALgAECgMJBgAAAA==.',
['云岿']='云岿山花火:BAAALgAECgIJBAAAAA==.',
['云泽']='云泽:BAAALgAECgMJAwAAAA==.',
['井芹']='井芹仁菜:BAAALgAFFAIJAwAAAA==.',
['亜菲']='亜菲利欧:BAACLgAFFH8VAAMCAAUJ5CTNAQCAAQACAAQJrhvNAQCAAQABAAUJfSQ4BwAvAQAuAAQKfyEAAwIACQlcJhcBAFkDAAIACAm4JRcBAFkDAAEACAnjIqIPAH0CAAAA.',
['人间']='人间失格:BAAALgAECgEJAQAAAA==.',
['众星']='众星:BAABLgAECn8jAAIDAAkJ7SGwAQBoAwADAAkJ7SGwAQBoAwABLgAFFAUJDwAHADIiAA==.',
['你要']='你要来一发吗:BAAALgAECgEJAgAAAA==.',
['佳佳']='佳佳奶糖:BAABLgAFFH8HAAMFAAUJrCAVAwCCAQAFAAQJrCAVAwCCAQAJAAEJAAALDgAAAAAAAA==.',
['佳文']='佳文四世:BAAALgAFFAQJBAAAAA==.',
['兩翼']='兩翼若:BAAALgAECgQJBAAAAA==.',
['兰斯']='兰斯丶布鲁特:BAAALgAECgMJAwAAAA==.',
['兽血']='兽血沸腾丶:BAAALgAECgkJEwAAAA==.',
['冰之']='冰之梦魇:BAAALgAECgYJCAAAAA==.',
['冰弦']='冰弦凝月:BAAALgAECgcJDQAAAA==.',
['冲锋']='冲锋接暴扣:BAAALgAECgkJDwAAAA==.',
['凉静']='凉静汐:BAAALgAECgUJCQAAAA==.',
['到处']='到处插棒子:BAAALgAECgYJAQAAAA==.',
['午后']='午后荭茶:BAAALgADCgEJAQAAAA==.',
['半刀']='半刀甜:BAAALgAECgYJBwAAAA==.',
['半步']='半步神游:BAAALgAECgUJBQAAAA==.',
['半糖']='半糖茉莉:BAAALgAECgYJCgAAAA==.',
['卡那']='卡那菲恩:BAAALgAECggJDgABLgAFFAQJDAADAGkcAA==.',
['去北']='去北極忘記你:BAAALgAECgEJAgAAAA==.',
['又初']='又初恋了:BAAALgAECgkJAwAAAA==.',
['又活']='又活一天:BAAALgAECgcJBwAAAA==.',
['古小']='古小乐:BAAALgAECgQJBQAAAA==.古小刃:BAAALgADCgEJAQAAAA==.',
['台词']='台词而义:BAAALgAFFAIJBAAAAA==.台词而已:BAABLgAFFH8HAAIKAAMJfxIeCADZAAAKAAMJfxIeCADZAAAAAA==.',
['吃货']='吃货怕饿梦:BAAALgAECgEJAQAAAA==.',
['听城']='听城:BAAALgAECgMJAwAAAA==.',
['命运']='命运之神:BAABLgAFFH8KAAILAAQJlQ2TCwBIAQALAAQJlQ2TCwBIAQAAAA==.',
['哦小']='哦小点点:BAAALgAECgcJEgAAAA==.',
['唧唧']='唧唧歪歪:BAAALgAECgcJDQAAAA==.',
['喝完']='喝完的啤酒:BAAALgAECgYJDAAAAA==.',
['囡囡']='囡囡丶低语:BAACLgAFFH8GAAIMAAMJDwfTGQDWAAAMAAMJDwfTGQDWAAAuAAQKfx0AAgwACAkNHvoYANMCAAwACAkNHvoYANMCAAAA.',
['圈养']='圈养野猪:BAAALgAECgcJDAAAAA==.',
['圣光']='圣光小鸭哥:BAAALgAECgYJAQAAAA==.',
['圣域']='圣域灬战神:BAAALgAECgkJCQAAAA==.圣域追风:BAAALgAECgYJCwAAAA==.',
['圣子']='圣子川:BAAALgAECgMJAwAAAA==.',
['地板']='地板好烫:BAAALgADCgcJBwAAAA==.',
['坏女']='坏女人:BAABLgAECn8XAAQDAAcJjQ0TIQB0AQADAAcJjQ0TIQB0AQABAAYJrQr7NgAcAQACAAUJ1wnsJgDqAAAAAA==.',
['夏花']='夏花之绚烂:BAAALgADCgIJAgAAAA==.',
['夜的']='夜的第三章:BAAALgAECgYJDAAAAA==.',
['大力']='大力出奇迹:BAAALgAECgIJAwAAAA==.',
['大郎']='大郎的药水:BAAALgAECgEJAQAAAA==.',
['大鹿']='大鹿天珠:BAAALgADCgEJAQAAAA==.',
['奶你']='奶你老牧:BAAALgAFFAIJAwAAAA==.',
['奶糖']='奶糖佳佳:BAAALgAFFAQJBAAAAA==.',
['嫩嫩']='嫩嫩炖蛋出炉:BAAALgADCgYJBgAAAA==.',
['安歌']='安歌丶:BAAALgAECgYJBgAAAA==.',
['安若']='安若清风:BAAALgAECgIJAwAAAA==.',
['宝贝']='宝贝:BAAALgAECgcJBwAAAA==.',
['客星']='客星辉煌之迹:BAABLgAECn8XAAMMAAgJvxY4NwBGAgAMAAgJvxY4NwBGAgANAAEJSgGfTwASAAAAAA==.',
['宦熊']='宦熊:BAAALgADCgEJAQAAAA==.',
['寒冰']='寒冰之墙丶:BAAALgAECgEJAQAAAA==.',
['寒香']='寒香凌霄:BAAALgAECgYJCQAAAA==.寒香雪月:BAAALgAECgYJEQAAAA==.',
['小兔']='小兔瑞贝德:BAAALgAECgQJBAAAAA==.',
['小冰']='小冰冰:BAAALgAECgMJAwAAAA==.',
['小咩']='小咩咩:BAAALgAFFAMJBAAAAA==.',
['小猎']='小猎刄:BAACLgAFFH8FAAMOAAMJfQ0iDQD4AAAOAAMJfQ0iDQD4AAAPAAEJ8wHhCQBMAAAuAAQKfxQAAw4ACAlPHbgdAFQCAA4ACAlPHbgdAFQCAA8ABQnBCbYNAOQAAAAA.',
['小飞']='小飞九:BAAALgAECgYJBgAAAA==.小飞二十:BAABLgAFFH8QAAQOAAUJdhY7BgA/AQAOAAQJNA87BgA/AQAPAAQJKxQrBAD9AAAQAAMJpw1NFwDeAAAAAA==.小飞八号:BAAALgAECgYJBgAAAA==.小飞六号:BAABLgAFFH8KAAIPAAUJfRozAQBtAQAPAAUJfRozAQBtAQAAAA==.小飞十九:BAAALgAFFAQJBAAAAA==.小飞十六:BAACLgAFFH8IAAMQAAQJQxmJAwANAQAQAAMJbBuJAwANAQAOAAEJyRJ+GQBeAAAuAAQKfxQAAxAACQkQIOMDAGQDABAACQkQIOMDAGQDAA8ABAmNBmIkAKgAAAAA.',
['山羊']='山羊角大魔王:BAAALgAECgEJAgAAAA==.',
['川大']='川大智胜:BAAALgAECgEJAgAAAA==.',
['帅气']='帅气的骨头:BAAALgAECgUJBQAAAA==.',
['帝国']='帝国之心:BAAALgAECgYJBgAAAA==.帝国之殇:BAAALgAECgYJBgABLgAFFAQJDwAGAJMUAA==.帝国之鹰:BAAALgAECgYJBgAAAA==.',
['幼稚']='幼稚園殺手:BAABLgAECn8dAAMFAAkJeRkRHwDHAgAFAAkJZhkRHwDHAgAJAAcJ6A7sJAAYAQAAAA==.',
['幽冥']='幽冥小鹅毛:BAAALgAECgIJAgAAAA==.',
['幽玦']='幽玦:BAABLgAECn8kAAQRAAgJDSCQMgBCAgARAAcJMB+QMgBCAgASAAUJBxtVGACIAQATAAEJAAAaJABhAAAAAA==.',
['开减']='开减伤丶:BAAALgAECgYJBgAAAA==.',
['张小']='张小肥:BAAALgAECgcJBwAAAA==.',
['彼岸']='彼岸花开:BAAALgAECgQJAwAAAA==.',
['很好']='很好很男人:BAAALgADCgMJAwAAAA==.',
['微笑']='微笑著哭泣:BAAALgAECgYJBgAAAA==.',
['德色']='德色:BAAALgAECgcJAQAAAA==.',
['德艺']='德艺双馨:BAAALgADCgIJAgAAAA==.',
['怠惰']='怠惰带司教:BAAALgADCgIJAgAAAA==.',
['恋色']='恋色空:BAAALgADCgEJAQAAAA==.',
['恭喜']='恭喜发财丷:BAABLgAFFH8JAAMEAAMJTx1wKgALAQAEAAMJIRRwKgALAQAUAAEJtCQVAQBvAAAAAA==.',
['恶魔']='恶魔术厉害:BAAALgAECgcJCAABLgAFFAQJCAARAAoUAA==.',
['我被']='我被妳宠坏:BAAALgADCgUJBQAAAA==.',
['打死']='打死一只兔:BAAALgAECgEJAQABLgAFFAIJBQAEAMMkAA==.打死一只猪:BAABLgAFFH8FAAIEAAIJwyQzMgDbAAAEAAIJwyQzMgDbAAAAAA==.',
['托遗']='托遗响于悲风:BAAALgADCgcJBwAAAA==.',
['承山']='承山:BAABLgAECn8YAAIIAAYJBBKHSwBKAQAIAAYJBBKHSwBKAQAAAA==.',
['抗揍']='抗揍小人一:BAABLgAFFH8PAAIVAAUJthNIBwBeAQAVAAUJthNIBwBeAQAAAA==.',
['抽完']='抽完的香烟:BAAALgAFFAIJBAAAAA==.',
['挚爱']='挚爱可乐:BAAALgAECgYJDgAAAA==.',
['挽昼']='挽昼:BAABLgAFFH8FAAIFAAUJ3xmgBAC3AQAFAAUJ3xmgBAC3AQAAAA==.',
['无非']='无非想快乐:BAABLgAFFH8NAAIBAAUJvRu/AwDgAQABAAUJvRu/AwDgAQABLgAFFAcJFQABACIgAA==.',
['时光']='时光之沙:BAAALgADCgcJBwAAAA==.时光之砂:BAAALgAECgQJBAAAAA==.',
['星衢']='星衢:BAABLgAFFH8IAAIWAAUJ7hZuBACnAQAWAAUJ7hZuBACnAQAAAA==.',
['晨峯']='晨峯:BAAALgADCgEJAQAAAA==.',
['最后']='最后一舞:BAAALgAECgYJBgAAAA==.',
['最好']='最好的未来:BAAALgADCgUJCAAAAA==.',
['未来']='未来福音:BAAALgAECgcJBwAAAA==.',
['李火']='李火旺:BAABLgAECn8UAAMCAAcJfxyADgDyAQACAAcJBByADgDyAQABAAYJ+Rh7IQCzAQAAAA==.',
['杠上']='杠上炮丶:BAAALgAECgEJAQAAAA==.',
['枫之']='枫之耀舞:BAAALgAECgkJEQABLgAFFAYJCgAXAHYKAA==.',
['椰果']='椰果奶绿:BAACLgAFFH8PAAIVAAQJGRW5CwAoAQAVAAQJGRW5CwAoAQAuAAQKfxUAAwcACQkVEwkaAOwBAAcACAnpEgkaAOwBABUACQlsDpknAMkBAAEuAAUUBQkFABUAWBAA.',
['椿龄']='椿龄无尽玄:BAAALgADCgcJBwAAAA==.',
['楓緋']='楓緋雨:BAAALgAECgkJCQAAAA==.',
['欣若']='欣若寒:BAAALgADCgEJAQAAAA==.',
['水蜜']='水蜜桃桃:BAAALgAECgMJAwAAAA==.',
['汐入']='汐入玖玖里:BAAALgAFFAIJAwABLgAFFAQJFQAGALAeAA==.',
['池鱼']='池鱼思故淵:BAABLgAFFH8FAAIDAAUJJAu6BgCFAQADAAUJJAu6BgCFAQABLgAFFAcJEAABAHgaAA==.',
['没有']='没有信仰的牛:BAAALgAECgEJAQAAAA==.',
['流风']='流风丶:BAAALgAECgMJAwAAAA==.',
['浪之']='浪之幻影:BAAALgAECgIJAwAAAA==.',
['漫漫']='漫漫山川雪:BAAALgAFFAEJAQAAAA==.',
['潇然']='潇然尘外:BAABLgAFFH8IAAIEAAMJYhfWFwD/AAAEAAMJYhfWFwD/AAAAAA==.',
['灬希']='灬希儿:BAAALgADCgYJBgABLgAFFAYJCgAXAHYKAA==.',
['烟花']='烟花粉黛:BAAALgAECgcJAwAAAA==.',
['熊幂']='熊幂:BAAALgAECgYJBgAAAA==.',
['爱弥']='爱弥斯:BAAALgAECgIJAwAAAA==.',
['特瓦']='特瓦林:BAAALgAECgYJDAAAAA==.',
['狐狸']='狐狸无心:BAAALgAECgMJAwAAAA==.',
['猪鼓']='猪鼓励:BAAALgAECgYJBgAAAA==.',
['猫南']='猫南北:BAAALgAECgEJAQAAAA==.',
['王力']='王力宏:BAABLgAFFH8GAAIYAAUJWR+MAADcAQAYAAUJWR+MAADcAQAAAA==.',
['真红']='真红眼黑龙:BAAALgAECgYJBgAAAA==.',
['知悉']='知悉:BAABLgAECn8eAAIXAAgJURjIBgALAgAXAAgJURjIBgALAgAAAA==.',
['神山']='神山识:BAACLgAFFH8VAAIGAAQJsB4JCABCAQAGAAQJsB4JCABCAQAuAAQKf0wABAYACQlFH4MKADADAAYACAn6IoMKADADABgAAgltF/xWAIsAABkAAwlXCwghAHwAAAAA.',
['箭神']='箭神大人:BAAALgAECgEJAgAAAA==.',
['经典']='经典一族:BAAALgAECgMJAwAAAA==.',
['绒球']='绒球儿:BAABLgAECn8aAAIaAAgJEgq9UwBYAQAaAAgJEgq9UwBYAQAAAA==.',
['给你']='给你一比斗:BAAALgADCgEJAQAAAA==.',
['绿皮']='绿皮瘦人:BAAALgADCgEJAgAAAA==.',
['群星']='群星:BAAALgAECgIJAgAAAA==.',
['聴風']='聴風的蝉:BAAALgAECgYJCwAAAA==.',
['肥罗']='肥罗一号:BAAALgADCgMJBAAAAA==.',
['芥末']='芥末贰号:BAAALgAFFAQJBAABLgAFFAUJCgACAEsgAA==.',
['花生']='花生花:BAACLgAFFH8FAAMDAAMJGxWWCAC0AAADAAIJpBeWCAC0AAABAAIJqwLzFwBHAAAuAAQKfxsAAwEACAn1EVwbAO4BAAEACAn1EVwbAO4BAAMABQkyF2ElAEwBAAAA.',
['苏星']='苏星河:BAAALgAECgYJBwAAAA==.',
['苾蓝']='苾蓝芬:BAAALgADCgIJAgAAAA==.',
['萨伊']='萨伊兰:BAAALgAECgMJAwAAAA==.',
['萨菲']='萨菲鼬:BAAALgAECgYJCwAAAA==.',
['螺号']='螺号:BAAALgAFFAIJAwAAAA==.',
['角色']='角色:BAAALgADCgUJBQAAAA==.',
['貝爾']='貝爾尼尼:BAAALgADCgEJAQAAAA==.',
['财源']='财源滚滚丷:BAAALgAFFAQJBAAAAA==.',
['赏侬']='赏侬十巴掌:BAAALgAECgkJBwABLgAFFAUJDQAVAL4aAA==.',
['超级']='超级冯:BAAALgAECggJCAAAAA==.超级小康纳:BAABLgAFFH8FAAMFAAUJXxjAEgBWAQAFAAQJXxjAEgBWAQAJAAEJAAB+DwB0AAAAAA==.',
['逐风']='逐风獵影:BAAALgADCgEJAQAAAA==.',
['郊外']='郊外野猪:BAAALgADCgcJBwAAAA==.',
['部分']='部分大小:BAAALgADCgYJBgAAAA==.',
['酷尔']='酷尔啼拉丝:BAAALgADCgUJBQAAAA==.',
['鎏灬']='鎏灬软软:BAAALgAECgYJBwAAAA==.',
['铿锵']='铿锵小龙:BAABLgAECn8XAAMDAAcJYwrlCAAQAQADAAcJYwrlCAAQAQABAAUJDQMSHwByAAAAAA==.',
['镉球']='镉球:BAAALgAECgUJCQAAAA==.',
['閃閃']='閃閃笨笨哒:BAAALgAECgcJCwAAAA==.',
['间桐']='间桐樱:BAAALgAECgYJBwAAAA==.',
['阿比']='阿比盖尓:BAAALgAECgIJAgAAAA==.',
['阿育']='阿育娅:BAAALgAECgEJAQAAAA==.',
['陈墙']='陈墙:BAAALgAECgkJDgAAAA==.',
['随便']='随便转转:BAAALgAECgMJAwAAAA==.',
['难民']='难民营营长:BAAALgAECgUJBQAAAA==.',
['雄霸']='雄霸:BAACLgAFFH8PAAMbAAUJ7hhdBACfAQAbAAUJ7hhdBACfAQAXAAEJAgIFJwA5AAAuAAQKfxwAAxcACAkEHfkRAIcCABcACAkEHfkRAIcCABsABwmYGk4cAC8CAAAA.',
['雷击']='雷击木:BAAALgAECgQJBAAAAA==.',
['青空']='青空玄鸟:BAABLgAFFH8GAAIcAAMJsxJwAwC2AAAcAAMJsxJwAwC2AAAAAA==.',
['非我']='非我莫属:BAAALgAECgEJAgAAAA==.',
['馬大']='馬大帅:BAAALgAECgQJBAAAAA==.',
['高你']='高你半个头:BAAALgAECgIJAgAAAA==.',
['高阶']='高阶领主:BAABLgAFFH8FAAIbAAMJlQ0vEADwAAAbAAMJlQ0vEADwAAAAAA==.',
['魅影']='魅影燃天:BAAALgAECgMJAwAAAA==.',
['魔窟']='魔窟邪巫王:BAAALgAECgEJAQAAAA==.',
['鲨匕']='鲨匕:BAAALgAECgcJBwAAAA==.',
['鹿颠']='鹿颠颠:BAAALgAECgEJAQAAAA==.',
['麦桐']='麦桐:BAAALgAECgYJCAAAAA==.',
['黄昏']='黄昏之歌:BAAALgAECgcJCQAAAA==.',
['黑翼']='黑翼之翔:BAAALgAECgMJCQAAAA==.',
['龙希']='龙希尔唤魔师:BAAALgAECgYJDAAAAA==.',
['龟龟']='龟龟之父:BAAALgAECgcJCAAAAA==.',
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
