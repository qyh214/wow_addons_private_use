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

local lookup = {'DeathKnight-Blood','Mage-Frost','Unknown-Unknown','Warrior-Fury','Shaman-Restoration','DeathKnight-Unholy','Rogue-Subtlety','DemonHunter-Devourer','Priest-Discipline','Priest-Holy','Monk-Brewmaster','Evoker-Preservation','Evoker-Augmentation','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Demonology','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Shaman-Elemental','Hunter-Survival','Priest-Shadow','Paladin-Retribution','Paladin-Holy','Rogue-Outlaw','Rogue-Assassination','Warlock-Affliction','Warrior-Arms','Warrior-Protection','DemonHunter-Vengeance',}
local provider = {region='CN',realm='朵丹尼尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ah='Ahsldhif:BAAALgAECgYJBwAAAA==.',
Au='Augenstern:BAAALgAECgYJBgAAAA==.',
Av='Avania:BAAALgAECgYJEQAAAA==.',
Bu='Bucciarati:BAAALgAFFAIJBAAAAA==.',
Ch='Chickenw:BAAALgAFFAUJAwAAAA==.',
Cl='Clearlove:BAAALgAFFAMJAwAAAA==.',
Co='Coldsdkt:BAABLgAECn8iAAIBAAgJ0hSHEAADAgABAAgJ0hSHEAADAgAAAA==.',
De='Dean:BAAALgAECgYJBgAAAA==.',
Du='Ducka:BAAALgAFFAQJBAAAAA==.Duckb:BAAALgAFFAQJBAAAAA==.Duckh:BAAALgAFFAQJBAAAAA==.',
El='Elliotli:BAAALgAECgYJBgAAAA==.',
Em='Emtiyy:BAAALgAECgUJBwAAAA==.',
Gi='Givenchy:BAAALgAECgEJAQAAAA==.',
Gr='Grace:BAABLgAECn8dAAICAAgJLCJEHgD8AgACAAgJLCJEHgD8AgAAAA==.Greedy:BAAALgAECgEJAQABLgAECgQJBAADAAAAAA==.',
Ha='Harrysyc:BAAALgADCgEJAQAAAA==.',
Ju='Justzs:BAABLgAFFH8FAAIEAAMJTAblEwDdAAAEAAMJTAblEwDdAAAAAA==.',
Le='Leoki:BAAALgAFFAUJAwAAAA==.',
Lu='Luvletter:BAAALgAECgUJBwAAAA==.',
Me='Meltykiss:BAABLgAFFH8FAAICAAUJcB3EBgDzAQACAAUJcB3EBgDzAQABLgAFFAYJCwACAL0cAA==.',
Pl='Playerdthoox:BAAALgAECgYJDQAAAA==.Playerdvypzb:BAAALgAECgMJBQAAAA==.Playerhgcpll:BAAALgAECgQJBAAAAA==.Playertlrzbd:BAAALgAECgYJCgAAAA==.Plzc:BAAALgAFFAQJAgAAAA==.',
Ra='Randyf:BAAALgAECgEJAQAAAA==.',
Ry='Ryna:BAABLgAFFH8HAAICAAIJxBQFOwC1AAACAAIJxBQFOwC1AAAAAA==.',
Sh='Shamanxiong:BAAALgAECgkJCQAAAA==.Shasixiaog:BAABLgAFFH8HAAIFAAMJCh0cBQAaAQAFAAMJCh0cBQAaAQAAAA==.Shasixiaogg:BAAALgAECgEJAQAAAA==.',
So='Solamonster:BAAALgAECgYJCAAAAA==.',
St='Starpaladin:BAAALgAECgEJAQAAAA==.Starsuy:BAAALgADCgEJAQAAAA==.Stonefree:BAAALgAECgcJBwAAAA==.',
Su='Supxarthas:BAAALgAECgIJAgAAAA==.',
Ve='Vengespirit:BAABLgAECn8XAAIGAAgJ/RxIJgCjAgAGAAgJ/RxIJgCjAgAAAA==.',
Yo='Yootee:BAAALgAECgMJAwAAAA==.',
Zi='Zigeroni:BAAALgAECgIJAgABLgAECgUJBgADAAAAAA==.',
['一个']='一个人四个腾:BAAALgADCgYJBgAAAA==.',
['一只']='一只萌咕咕:BAAALgAECgEJAQAAAA==.',
['一枕']='一枕黃粱:BAAALgADCgcJBwAAAA==.',
['一颗']='一颗大火球:BAAALgAECgMJAwAAAA==.',
['三只']='三只松鼠:BAAALgADCgUJBQAAAA==.',
['三生']='三生之石:BAAALgAECgIJAgAAAA==.',
['上单']='上单小油条:BAAALgAFFAIJAgAAAA==.',
['上去']='上去就是一脚:BAAALgAECgYJCgAAAA==.',
['下山']='下山打松鼠:BAAALgAECggJEgAAAA==.',
['下班']='下班上班都堵:BAAALgAECgUJBQAAAA==.',
['不務']='不務專業:BAAALgAFFAEJAQAAAA==.',
['不奇']='不奇怪:BAAALgAECgcJCwABLgAFFAUJBAADAAAAAA==.',
['不如']='不如:BAAALgAECgcJCgAAAA==.',
['丢炎']='丢炎爆蹦起跳:BAAALgAECgYJEAAAAA==.',
['丨丶']='丨丶尛叁:BAAALgAECgUJCgAAAA==.',
['丨戒']='丨戒指丨:BAAALgADCgUJBQAAAA==.',
['丨战']='丨战神灬:BAAALgAECgUJCQAAAA==.',
['丨舍']='丨舍甫琴科丨:BAAALgAECgQJAgAAAA==.',
['丶倥']='丶倥白记忆:BAAALgAECgEJAgAAAA==.',
['丶嘤']='丶嘤嘤樱:BAAALgADCgYJBgAAAA==.',
['丶投']='丶投降输一半:BAAALgAECgQJBAAAAA==.',
['乔兮']='乔兮丶:BAAALgAECgEJAQAAAA==.',
['乱世']='乱世熊猫:BAAALgAECgYJBgAAAA==.',
['二见']='二见原莉莉子:BAAALgAECgUJCAABLgAFFAQJDAAHABsbAA==.',
['云水']='云水泱泱:BAAALgAECgcJBwAAAA==.',
['亚斯']='亚斯塔洛雪:BAAALgAECgEJAQAAAA==.',
['人雁']='人雁南飛:BAAALgADCgEJAQAAAA==.',
['今晚']='今晚打老虎:BAABLgAFFH8HAAIIAAQJsAzdHADtAAAIAAQJsAzdHADtAAAAAA==.',
['他乡']='他乡之客:BAAALgAECgMJBwAAAA==.',
['伊芙']='伊芙莉特:BAAALgAECgEJAQAAAA==.',
['优昙']='优昙:BAABLgAECn8YAAMJAAgJ2xFHFwDlAQAJAAgJ2xFHFwDlAQAKAAQJgQeeXwCzAAAAAA==.',
['伤心']='伤心丶哲别:BAAALgAECgYJCgAAAA==.',
['佩罗']='佩罗娜:BAAALgAFFAEJAQAAAA==.',
['侑德']='侑德哔有尸:BAAALgADCgcJBwABLgAECggJGwALAE8fAA==.',
['依墙']='依墙待冬雪:BAAALgAECgIJAgAAAA==.依墙待红杏:BAAALgAECgQJCAAAAA==.',
['倾心']='倾心若水:BAAALgADCgEJAQAAAA==.',
['偷东']='偷东西的猪:BAAALgAECgEJAwAAAA==.',
['傲慢']='傲慢糖糖:BAAALgAECgEJAQAAAA==.',
['光明']='光明天堂:BAAALgAECgQJBwAAAA==.',
['光牧']='光牧:BAAALgADCgQJBAAAAA==.',
['克兰']='克兰呐:BAAALgAECgYJBgAAAA==.克兰深深:BAAALgAECgcJBwAAAA==.',
['克拉']='克拉伏特:BAAALgAECgEJAwABLgAECgMJBAADAAAAAA==.',
['兔小']='兔小琦:BAAALgAECgYJBgAAAA==.',
['兰陵']='兰陵王入阵曲:BAAALgAECgkJAQAAAA==.',
['冋冏']='冋冏囧冏冋:BAAALgAFFAQJBAAAAA==.',
['冰冻']='冰冻的豆子:BAAALgAECgUJCQAAAA==.',
['冰凝']='冰凝之夏丶:BAAALgAECgIJBAAAAA==.',
['凝丨']='凝丨霜:BAAALgAFFAQJBAAAAA==.',
['凯宾']='凯宾斯基:BAAALgAECgEJAgAAAA==.',
['匆匆']='匆匆那年:BAAALgAECgYJCgAAAA==.',
['十三']='十三茜茜:BAAALgAECgcJDgAAAA==.',
['十二']='十二:BAAALgAECgYJCAAAAA==.十二小祖:BAAALgAECgMJAwAAAA==.',
['千早']='千早爱音:BAACLgAFFH8JAAIMAAMJuSJTCwA1AQAMAAMJuSJTCwA1AQAuAAQKfxgAAwwACAmAIEgFAPcCAAwACAmAIEgFAPcCAA0ABAkxF8A1ACMBAAEuAAUUBQkVAA4AoiEA.',
['卡布']='卡布奇喏:BAAALgAECgQJBAAAAA==.',
['又高']='又高又硬:BAAALgAECgUJCAAAAA==.',
['古轩']='古轩一梦:BAAALgAECgQJBAAAAA==.',
['叶慕']='叶慕:BAAALgAECgYJBgAAAA==.',
['吼咧']='吼咧泻特:BAAALgAECgYJBgABLgAFFAUJCQAFAHoNAA==.',
['咋玩']='咋玩都好玩:BAAALgADCgEJAQAAAA==.',
['哈利']='哈利波特别大:BAAALgADCgYJBgAAAA==.',
['哈哈']='哈哈伊笑:BAABLgAECn8XAAIPAAcJNhgULgD6AQAPAAcJNhgULgD6AQAAAA==.',
['哈尼']='哈尼江:BAAALgAECgQJBQAAAA==.',
['哒菠']='哒菠萝:BAAALgAECgEJAQAAAA==.',
['唯美']='唯美古典:BAAALgAECgkJCQAAAA==.',
['啊莱']='啊莱克斯塔萨:BAAALgAECgUJCAAAAA==.',
['啦啦']='啦啦拉啦啦:BAAALgADCgIJAgAAAA==.',
['喵灬']='喵灬少爺:BAABLgAFFH8HAAIKAAIJNR+9CgC4AAAKAAIJNR+9CgC4AAAAAA==.',
['嘿嘿']='嘿嘿黑嘿嘿:BAAALgAECgQJCQABLgAFFAYJDwAQALsgAA==.',
['噶蛋']='噶蛋高手:BAAALgAECgcJCgAAAA==.',
['四月']='四月与安安:BAAALgAECgUJBwAAAA==.',
['四边']='四边形:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光之正义:BAAALgADCgUJBQAAAA==.圣光闪瞎的眼:BAAALgAECgIJAwAAAA==.',
['坍缩']='坍缩之星:BAAALgAECgMJAwAAAA==.',
['堕落']='堕落审判:BAAALgAFFAEJAQAAAA==.',
['塔拉']='塔拉夏的判决:BAAALgAECgUJBAAAAA==.',
['夜风']='夜风凌月:BAAALgAECgYJCAABLgAFFAEJAQADAAAAAA==.',
['大浪']='大浪花儿丶:BAAALgAECgEJAQAAAA==.',
['大狗']='大狗副警官:BAAALgAECgMJAwAAAA==.大狗副警长:BAAALgAECgUJBwAAAA==.',
['大瑞']='大瑞:BAAALgADCgEJAQAAAA==.',
['大肥']='大肥鱼:BAAALgAECgEJAQABLgAECgYJBwADAAAAAA==.',
['天使']='天使的余温:BAAALgAFFAEJAQAAAA==.天使的降临:BAAALgAECgYJBwAAAA==.',
['天堂']='天堂的轨迹:BAAALgAECgUJBQAAAA==.',
['太阳']='太阳之王丶焱:BAAALgAECgYJBwAAAA==.',
['奉天']='奉天承运:BAABLgAECn8WAAIGAAYJeRZSdQCbAQAGAAYJeRZSdQCbAQAAAA==.',
['奥斯']='奥斯汀彪哥:BAAALgAECgQJBAAAAA==.',
['奥雷']='奥雷莉亞:BAAALgADCgkJCQAAAA==.',
['奶香']='奶香一刀:BAAALgAFFAIJAwAAAA==.',
['妄想']='妄想心音:BAAALgADCgUJBQAAAA==.',
['妙秋']='妙秋:BAAALgAECgQJBgAAAA==.',
['妹陀']='妹陀很猛:BAAALgAECgEJAQAAAA==.',
['威尔']='威尔塔利斯:BAAALgAECgYJBgAAAA==.',
['孤月']='孤月影冷寂寞:BAAALgAECgEJAQAAAA==.',
['安萨']='安萨璐晨霜:BAAALgAECgYJCwAAAA==.',
['完结']='完结撒花:BAAALgADCgEJAQAAAA==.',
['宝宝']='宝宝肚肚打雷:BAABLgAFFH8GAAIPAAIJpBubFwCoAAAPAAIJpBubFwCoAAAAAA==.',
['宝猫']='宝猫:BAAALgADCgEJAQAAAA==.',
['寄明']='寄明月与相思:BAAALgAECgIJAgAAAA==.',
['寒蝉']='寒蝉凄切丶:BAAALgAECggJDwAAAA==.',
['射不']='射不易空:BAAALgAECgYJCAAAAA==.',
['小万']='小万叶:BAABLgAECn8VAAIGAAcJUQ4MfgCHAQAGAAcJUQ4MfgCHAQAAAA==.',
['小光']='小光:BAACLgAFFH8PAAIRAAQJYCR4BACdAQARAAQJYCR4BACdAQAuAAQKfxwAAxEABwmmJYkGAPYCABEABwmmJYkGAPYCABIABAlNFzJKAOoAAAEuAAUUBQkPAAkAaSEA.',
['小叮']='小叮当当:BAAALgAECgUJBwAAAA==.',
['小呆']='小呆猎:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊不乖:BAAALgAECgQJBAAAAA==.小熊向前冲:BAACLgAFFH8FAAMTAAIJeBJOEwCpAAATAAIJeBJOEwCpAAAUAAEJvCBwDwBiAAAuAAQKfxoAAxMACAkqIbMNAMACABMACAkqIbMNAMACABQABAmGIKsNAHoBAAAA.',
['小牧']='小牧森:BAABLgAECn8aAAMKAAcJJBqEHwDlAQAKAAcJ8BmEHwDlAQAJAAEJFBrjFQBMAAAAAA==.',
['小缈']='小缈:BAAALgAECgYJBwAAAA==.',
['小能']='小能豆:BAAALgAECgYJDAAAAA==.',
['小赤']='小赤佬:BAAALgAECgUJBQABLgAFFAIJBQALAMoNAA==.',
['小鹿']='小鹿宝莉:BAAALgAFFAIJAgAAAA==.',
['小麦']='小麦鼠:BAAALgAECgYJBgAAAA==.',
['尚霖']='尚霖子:BAAALgAECgcJBwAAAA==.',
['就差']='就差一丢丢儿:BAAALgAECgkJDwAAAA==.',
['就怕']='就怕贼惦记:BAAALgAECgEJAQAAAA==.',
['就是']='就是没橙:BAAALgAECgYJBgAAAA==.',
['川上']='川上富江:BAAALgAECgcJDwAAAA==.',
['希希']='希希丽丝:BAAALgAFFAIJAwAAAA==.',
['帝啼']='帝啼:BAAALgADCgUJBQAAAA==.',
['帝惑']='帝惑:BAAALgADCgYJBgAAAA==.',
['年轻']='年轻:BAAALgAECgQJBAAAAA==.',
['幻城']='幻城新月:BAAALgAFFAEJAQAAAA==.',
['幻月']='幻月灬星辰:BAAALgAFFAIJBAAAAA==.',
['幻杀']='幻杀灬银牙:BAAALgADCgMJAwAAAA==.',
['广谋']='广谋:BAAALgAECgEJAQAAAA==.',
['庚优']='庚优子:BAAALgADCgEJAQAAAA==.',
['征战']='征战丶灰烬:BAAALgAECgIJAgAAAA==.',
['徐大']='徐大萌丶同学:BAAALgAECgUJBAAAAA==.',
['徐霞']='徐霞客:BAAALgAECgQJBAAAAA==.',
['德国']='德国人有欧气:BAAALgAECgYJCAAAAA==.',
['德徳']='德徳得:BAAALgAECgMJBQAAAA==.',
['心飛']='心飛揚:BAAALgAECgcJCAAAAA==.',
['快乐']='快乐恬恬圈:BAAALgADCgUJBQAAAA==.',
['念慈']='念慈:BAAALgADCgYJBgAAAA==.',
['怨念']='怨念把信仰黑:BAAALgAECgMJAwABLgAECgQJBAADAAAAAA==.',
['总之']='总之就是壹刀:BAAALgAECgEJAgAAAA==.',
['恶魔']='恶魔旋风斩:BAAALgAECgIJAgAAAA==.',
['悟坤']='悟坤:BAAALgAECgYJBgAAAA==.',
['惩姐']='惩姐骑:BAAALgAFFAIJAgAAAA==.',
['戎马']='戎马倥偬:BAABLgAECn8YAAMVAAYJAhq7IwCfAQAVAAYJAhq7IwCfAQAIAAYJVAzpgwAgAQAAAA==.',
['我不']='我不守止攻:BAAALgAECgcJDgAAAA==.',
['我心']='我心永恒十二:BAAALgAECgQJBAAAAA==.',
['我恨']='我恨卡伊涩:BAAALgAECgkJCQAAAA==.',
['扁娃']='扁娃炒饭:BAAALgADCgIJAgAAAA==.',
['打完']='打完救你:BAAALgAFFAQJBAAAAA==.',
['扳机']='扳机丶:BAAALgAFFAQJBAAAAA==.',
['提米']='提米拉:BAAALgADCgcJBwAAAA==.',
['斟爵']='斟爵丶淬刖:BAABLgAECn8bAAMUAAgJ1hoSJAAqAgAUAAgJ1hoSJAAqAgATAAYJmxxXMACFAQABLgAFFAEJAQADAAAAAA==.',
['断水']='断水流大师兄:BAAALgAFFAEJAQAAAA==.',
['施巴']='施巴拉谷大师:BAAALgADCgkJCQAAAA==.',
['无将']='无将:BAAALgAECgcJDwAAAA==.',
['无敌']='无敌圣光:BAAALgAECgUJBgAAAA==.',
['无灬']='无灬情:BAAALgAECgYJCwAAAA==.',
['无糖']='无糖没门不滚:BAAALgAECgEJAgAAAA==.',
['无聊']='无聊只谈:BAAALgAECgEJAQAAAA==.',
['明月']='明月栞那:BAAALgAECgUJBwABLgAFFAUJFQAOAKIhAA==.明月清风我:BAAALgAECgQJBAAAAA==.',
['易榕']='易榕冰:BAAALgAECgMJAwAAAA==.',
['春丶']='春丶秋:BAAALgAFFAMJBAAAAA==.',
['暗影']='暗影柯基:BAAALgADCgIJAgAAAA==.',
['暴奶']='暴奶还是我:BAAALgAECgMJBAAAAA==.',
['暴菊']='暴菊型男:BAAALgAECgMJAwAAAA==.',
['暴雨']='暴雨梨花针:BAAALgADCgMJAwAAAA==.',
['曙光']='曙光灬:BAEALgAFFAIJAgAAAA==.',
['曦雨']='曦雨:BAAALgAECgMJAwAAAA==.',
['替罪']='替罪的羊:BAAALgAECgcJBwAAAA==.',
['本来']='本来很霸道:BAAALgAECgYJDAABLgAECggJFAAOAH0eAA==.',
['术丶']='术丶爷:BAAALgAECgEJAQAAAA==.',
['朱七']='朱七七:BAAALgAECgYJCQAAAA==.',
['权志']='权志凤:BAAALgAECgEJAQAAAA==.',
['李亞']='李亞军:BAAALgAECgQJBQAAAA==.',
['李班']='李班长:BAAALgAECgEJAQAAAA==.',
['来斯']='来斯不打折:BAAALgAECgEJAQAAAA==.',
['杨十']='杨十二:BAAALgAECgIJAgAAAA==.',
['果汁']='果汁阳台:BAAALgAECgEJAQAAAA==.',
['枫林']='枫林唱晚:BAABLgAFFH8KAAICAAQJVSLSDgAYAQACAAQJVSLSDgAYAQAAAA==.',
['柠檬']='柠檬的萌:BAAALgAECgEJAQAAAA==.',
['柳儿']='柳儿:BAAALgAECgYJDAAAAA==.',
['格朗']='格朗特冰胡子:BAAALgAECgEJAQAAAA==.',
['桃乃']='桃乃木香奈:BAAALgAECgEJAQAAAA==.',
['梦幻']='梦幻宝贝:BAAALgADCgEJAQAAAA==.',
['梦里']='梦里什么都有:BAAALgAECgQJBAAAAA==.',
['梧桐']='梧桐丶细雨:BAAALgADCgkJCQAAAA==.',
['森律']='森律障:BAAALgAECgcJDQABLgAECgcJGgAKACQaAA==.',
['椒盐']='椒盐蛋白:BAAALgAECgYJDgAAAA==.',
['椰子']='椰子酥:BAAALgAECgIJAwAAAA==.',
['横塘']='横塘疏影:BAAALgAECgMJBwAAAA==.',
['橙乂']='橙乂乂:BAAALgADCgIJAgAAAA==.',
['橙仟']='橙仟上萬:BAAALgAECgQJCQAAAA==.',
['橙橙']='橙橙饭:BAAALgAECgIJAgAAAA==.',
['欧洲']='欧洲雷电法王:BAAALgAECgEJAQAAAA==.',
['欧蕾']='欧蕾哈娜:BAAALgAECgQJBwAAAA==.',
['死神']='死神凵怒风:BAAALgAFFAEJAQAAAA==.',
['殇丶']='殇丶千羽:BAAALgAECgUJBQAAAA==.',
['残星']='残星噬梦:BAAALgAECgcJBgAAAA==.',
['毒行']='毒行的呜呜:BAAALgADCgEJAQAAAA==.',
['永夜']='永夜小图牛:BAAALgADCgUJCAAAAA==.',
['沉默']='沉默之伤:BAAALgAECgkJCQAAAA==.',
['河粉']='河粉:BAAALgAFFAIJBAAAAA==.',
['法兰']='法兰琳卡乄風:BAAALgAECgEJAgAAAA==.',
['法師']='法師:BAAALgAFFAQJBAAAAA==.',
['泡芙']='泡芙丫头:BAAALgADCgIJAQAAAA==.',
['泪宇']='泪宇:BAACLgAFFH8LAAIWAAQJcRTECQBFAQAWAAQJcRTECQBFAQAuAAQKfyAAAxYACAmzHt0NAMQCABYACAmzHt0NAMQCAAUABQm1B6JtANgAAAAA.',
['泰岚']='泰岚徳:BAAALgAECgQJCAAAAA==.',
['泰莉']='泰莉亚:BAAALgAECgIJAgAAAA==.',
['洛丶']='洛丶浠:BAAALgAECgUJBQAAAA==.',
['洛水']='洛水天琊:BAAALgAECgcJDQAAAA==.',
['浅丨']='浅丨深:BAAALgADCgEJAQAAAA==.',
['海利']='海利号:BAAALgADCgEJAQAAAA==.',
['涧芯']='涧芯:BAAALgAECgYJDgAAAA==.',
['混沌']='混沌游戏:BAABLgAECn8hAAIFAAgJahj2HgAmAgAFAAgJahj2HgAmAgAAAA==.',
['清风']='清风笑烟雨:BAAALgAECgIJAgABLgAFFAYJBwAIAGYTAA==.',
['温莎']='温莎十二:BAAALgAECgEJAQAAAA==.',
['游灵']='游灵:BAAALgAECgEJAQAAAA==.',
['湘菇']='湘菇:BAAALgAFFAQJBAABLgAFFAQJBAADAAAAAA==.',
['濑户']='濑户环奈:BAAALgAECgEJAgAAAA==.',
['火焰']='火焰獠牙:BAAALgADCgYJBwAAAA==.',
['灬小']='灬小恶魔灬:BAAALgAECgMJAwAAAA==.',
['灬神']='灬神话灬:BAABLgAFFH8FAAIIAAUJExnDBgC3AQAIAAUJExnDBgC3AQAAAA==.',
['灬骑']='灬骑灬:BAAALgADCgIJAgAAAA==.',
['灵感']='灵感咕哩咕哩:BAAALgAECgEJAQAAAA==.',
['炒牛']='炒牛河:BAAALgAECgYJDQABLgAFFAIJBAADAAAAAA==.',
['烟苒']='烟苒魅:BAABLgAECn8cAAIQAAgJtxH+SgDoAQAQAAgJtxH+SgDoAQAAAA==.',
['無林']='無林:BAAALgAECgQJBwAAAA==.',
['無眠']='無眠练习生:BAAALgAFFAQJBAAAAA==.',
['無空']='無空:BAAALgAECgEJAQAAAA==.',
['煜明']='煜明:BAAALgAECgUJBQAAAA==.',
['燃燒']='燃燒軍團奸細:BAAALgAECgYJDAAAAA==.',
['爆奶']='爆奶就是我:BAAALgAECgMJAwAAAA==.',
['爱莎']='爱莎啦:BAAALgAECgQJCgAAAA==.',
['爲你']='爲你变乖:BAAALgAECgMJAwAAAA==.',
['特蕾']='特蕾西娅:BAACLgAFFH8VAAMOAAUJoiFWBADzAQAOAAUJoiFWBADzAQAXAAMJVg9LAwAEAQAuAAQKfy0AAw4ACAk1JGwGADMDAA4ACAm1I2wGADMDABcABwkkHcIBACUCAAAA.',
['犟种']='犟种:BAAALgAECgEJAQAAAA==.',
['狐力']='狐力大仙:BAAALgAECgMJAwAAAA==.',
['狩猎']='狩猎暗影:BAAALgAECgEJAQAAAA==.',
['狮诗']='狮诗施师:BAAALgAECgEJAgAAAA==.',
['狼之']='狼之子雨与雪:BAAALgADCgYJBgAAAA==.',
['猎非']='猎非烟:BAAALgAECgEJAQAAAA==.',
['玛卡']='玛卡巴卡:BAAALgAFFAIJAgAAAA==.',
['珠光']='珠光护手:BAACLgAFFH8IAAICAAQJLRKzEQAFAQACAAQJLRKzEQAFAQAuAAQKfx8AAgIACQkIF901AJwCAAIACQkIF901AJwCAAAA.',
['田曦']='田曦薇丶:BAACLgAFFH8KAAILAAQJoAmYBgALAQALAAQJoAmYBgALAQAuAAQKfx8AAgsABwmXG0gcACACAAsABwmXG0gcACACAAAA.',
['画个']='画个圈上诅咒:BAAALgADCgYJBgAAAA==.',
['瘦哥']='瘦哥往前冲:BAAALgAFFAQJBAAAAA==.',
['白萨']='白萨满:BAAALgAECgQJBQAAAA==.',
['真的']='真的老实:BAAALgAECgYJBgAAAA==.',
['瞬息']='瞬息万变:BAAALgAECgEJAgAAAA==.',
['砍我']='砍我一刀试试:BAAALgAECgYJBgAAAA==.',
['砍旗']='砍旗刊期:BAAALgAECgIJAgAAAA==.',
['破魔']='破魔的红蔷薇:BAAALgAECgQJAwAAAA==.',
['碧琪']='碧琪:BAAALgAECgUJBwAAAA==.',
['神圣']='神圣炖鸡:BAAALgAECgYJBgAAAA==.',
['神月']='神月流枫:BAABLgAFFH8HAAIYAAcJJBoOAAAnAgAYAAcJJBoOAAAnAgAAAA==.',
['神灬']='神灬話:BAAALgAFFAcJAgAAAA==.',
['神秘']='神秘射手:BAAALgAECgEJAQAAAA==.',
['神话']='神话一:BAAALgAECgYJBgAAAA==.神话七:BAAALgAFFAQJBAAAAA==.',
['离我']='离我远点:BAAALgAECgcJEAAAAA==.',
['稻草']='稻草芭比:BAAALgAECgYJCwAAAA==.',
['穿拖']='穿拖鞋的上帝:BAAALgAECgUJBQAAAA==.',
['站住']='站住灬查水表:BAAALgADCgYJBgAAAA==.',
['笼罩']='笼罩圣光:BAABLgAFFH8FAAIZAAIJ2RMkJACkAAAZAAIJ2RMkJACkAAAAAA==.',
['粉色']='粉色大苍蝇:BAACLgAFFH8FAAIMAAIJ8woUEwCTAAAMAAIJ8woUEwCTAAAuAAQKfx0AAwwACQnAFNQNAFkCAAwACAnyFtQNAFkCAA0AAwkjC/lPAI0AAAAA.',
['红色']='红色帽衫:BAAALgAECgIJAwAAAA==.',
['绿绿']='绿绿悠悠:BAAALgAECgEJAQABLgAECgYJBwADAAAAAA==.',
['罗斯']='罗斯伊德茜:BAAALgADCgcJDQAAAA==.',
['翩然']='翩然倩兮:BAAALgADCgMJAwAAAA==.',
['老六']='老六机甲:BAAALgADCgUJBQAAAA==.',
['老奶']='老奶霸:BAAALgADCgIJAgAAAA==.',
['老米']='老米丨武僧:BAAALgAECgEJAgAAAA==.老米丨紫色:BAAALgADCgUJBQAAAA==.老米丨骑士:BAAALgAECgYJCQAAAA==.',
['肥仔']='肥仔伯伯:BAAALgAECgEJAQAAAA==.',
['胭脂']='胭脂:BAAALgAFFAQJBAAAAA==.',
['脑斧']='脑斧不一喵:BAABLgAFFH8HAAIGAAIJ8wuXQwCbAAAGAAIJ8wuXQwCbAAAAAA==.脑斧不八喵:BAAALgAECgcJBwAAAA==.',
['艾沐']='艾沐媞:BAAALgAECgYJDAAAAA==.',
['艾睿']='艾睿达人:BAAALgAECgYJDAAAAA==.',
['艾米']='艾米梨:BAAALgADCgYJCwAAAA==.',
['花弄']='花弄影:BAABLgAECn8UAAIaAAcJmxCjPgB+AQAaAAcJmxCjPgB+AQAAAA==.',
['花月']='花月夜:BAAALgAECgYJCAAAAA==.',
['花田']='花田德:BAAALgAECgcJEAAAAA==.',
['花落']='花落却未谢:BAAALgAECgkJDAAAAA==.',
['花钱']='花钱秀腿:BAABLgAECn8bAAILAAgJTx9xDADIAgALAAgJTx9xDADIAgAAAA==.',
['苏苏']='苏苏不熊:BAAALgAECgYJEgAAAA==.苏苏不苏:BAAALgAECgUJCAAAAA==.苏苏不鲁:BAAALgAECgQJBQAAAA==.',
['若余']='若余:BAAALgAECgEJAQAAAA==.',
['茶餐']='茶餐厅:BAABLgAFFH8QAAIRAAYJHx9jAAArAgARAAYJHx9jAAArAgAAAA==.',
['草莓']='草莓小公主:BAAALgAECgMJBQAAAA==.',
['莉欧']='莉欧娜:BAAALgAECgMJAwAAAA==.',
['莉玛']='莉玛儿:BAAALgAECgcJEwAAAA==.',
['莫失']='莫失莫忘曾经:BAAALgAECgEJAQAAAA==.',
['菈妮']='菈妮:BAAALgAECgYJDgAAAA==.',
['菈海']='菈海尔:BAAALgAECgMJAwAAAA==.',
['萌凝']='萌凝:BAAALgAECgEJAQAAAA==.',
['萨蛮']='萨蛮有趣:BAAALgAECgUJCAAAAA==.',
['落羽']='落羽:BAAALgAECgEJAQAAAA==.',
['落英']='落英听谁细数:BAAALgAECgYJBgAAAA==.',
['蓝冰']='蓝冰:BAAALgAECgUJBgAAAA==.',
['虎妞']='虎妞丶:BAAALgAFFAIJAgAAAA==.',
['虚空']='虚空游侠:BAAALgADCgEJAQAAAA==.',
['蜡笔']='蜡笔晓芯:BAAALgAECgEJAQAAAA==.',
['血剑']='血剑封喉:BAAALgADCgUJBQAAAA==.',
['血雨']='血雨残夜:BAAALgAECgYJCgAAAA==.',
['衣阿']='衣阿华:BAAALgAECgcJCwAAAA==.',
['詹妮']='詹妮弗:BAAALgAECgYJEAAAAA==.',
['讲个']='讲个故事你听:BAAALgAECgEJAQABLgAECggJGwALAE8fAA==.',
['诗婧']='诗婧益源:BAAALgAECgQJBAAAAA==.',
['请叫']='请叫我二哈:BAAALgAECgEJAQAAAA==.',
['诸界']='诸界丨毁灭:BAAALgADCgEJAQAAAA==.',
['谷风']='谷风天音:BAACLgAFFH8MAAIHAAQJGxtrBgB5AQAHAAQJGxtrBgB5AQAuAAQKfx4ABAcACAmeIvIHABEDAAcACAk0IvIHABEDABsABwngF1QFAJABABwAAgl3IyMTANAAAAAA.',
['豆豆']='豆豆贰佰伍:BAAALgAECgEJAQAAAA==.',
['贱不']='贱不虚发:BAAALgAECgQJBAAAAA==.',
['贵人']='贵人:BAAALgADCgUJBQAAAA==.',
['辣番']='辣番茄丶:BAAALgADCgIJAgAAAA==.',
['辣辣']='辣辣的跟班:BAAALgADCgIJAgAAAA==.',
['迪莉']='迪莉莎:BAAALgAECgEJAgAAAA==.',
['迷失']='迷失的纯真:BAAALgAECgEJAQAAAA==.',
['迹奇']='迹奇出力大:BAAALgAECgUJCwAAAA==.',
['适才']='适才相戏耳:BAAALgADCgIJAgAAAA==.',
['速帕']='速帕赛牙尽:BAAALgADCgUJBQAAAA==.',
['逢泽']='逢泽美优:BAAALgAECgEJAgAAAA==.',
['那你']='那你囊大多:BAAALgAECgEJAgAAAA==.',
['那夜']='那夜快哉:BAAALgAECgMJAwAAAA==.',
['那年']='那年冬天:BAAALgAFFAIJAwABLgAFFAIJBAADAAAAAA==.那年夏天:BAAALgAFFAIJAwABLgAFFAIJBAADAAAAAA==.那年秋天:BAAALgAFFAEJAQABLgAFFAIJBAADAAAAAA==.',
['邪魂']='邪魂纛胤:BAABLgAFFH8FAAIFAAIJIhFWGACaAAAFAAIJIhFWGACaAAAAAA==.',
['郎教']='郎教授:BAAALgAECgcJCgAAAA==.',
['部落']='部落人称死骑:BAAALgADCgEJAQAAAA==.部落训练假人:BAAALgAECgQJBwAAAA==.',
['醉酒']='醉酒太行:BAAALgAECgIJAgAAAA==.',
['野生']='野生月亮:BAAALgAECgIJAgAAAA==.',
['钚会']='钚会绯的渔:BAAALgADCgEJAQAAAA==.',
['钵丨']='钵丨钵鸡:BAAALgAECgYJDwAAAA==.',
['铃村']='铃村爱里:BAAALgADCgUJBQAAAA==.',
['银鳞']='银鳞:BAAALgAECgQJBQAAAA==.',
['锉刀']='锉刀怪:BAABLgAECn8aAAMSAAcJ/xQuJwCfAQASAAYJgRcuJwCfAQALAAEJdAjTjAArAAAAAA==.',
['闇冥']='闇冥:BAAALgADCgUJBQAAAA==.',
['闲人']='闲人:BAAALgAFFAIJAwAAAA==.',
['阿尔']='阿尔斯文:BAAALgADCgYJBgAAAA==.',
['阿比']='阿比斯深渊:BAAALgADCgQJBAAAAA==.',
['阿玛']='阿玛塔拉斯:BAAALgADCgMJAwAAAA==.',
['阿閁']='阿閁忒拉斯:BAAALgAECgUJBQAAAA==.',
['陆吾']='陆吾:BAAALgADCgYJBgAAAA==.',
['雨中']='雨中彩虹:BAAALgADCggJCAAAAA==.',
['雪白']='雪白的咪米:BAAALgADCgUJDAAAAA==.',
['雷诺']='雷诺萨斯:BAAALgAECgQJBQAAAA==.',
['雷霆']='雷霆囡囡:BAAALgAECgEJAQAAAA==.',
['電雲']='電雲:BAAALgAECgUJBQAAAA==.',
['霜什']='霜什:BAAALgAFFAMJAwAAAA==.',
['露露']='露露卡洛斯:BAABLgAFFH8FAAIUAAUJuxbpAwCkAQAUAAUJuxbpAwCkAQAAAA==.',
['霸刀']='霸刀无敌:BAAALgAECgQJBAAAAA==.',
['青梅']='青梅煮酒丶:BAAALgAECgIJAwAAAA==.',
['青椒']='青椒肉丝拌饭:BAAALgAECgIJAwAAAA==.',
['青涩']='青涩柠檬:BAAALgAECgUJDAAAAA==.',
['靓丽']='靓丽不打折:BAAALgAFFAIJBAAAAA==.',
['静听']='静听风呤:BAABLgAFFH8FAAIGAAQJYxBhGgA7AQAGAAQJYxBhGgA7AQAAAA==.',
['風之']='風之优雅:BAAALgAECgEJAQAAAA==.',
['风间']='风间沧月:BAAALgADCgEJAQAAAA==.',
['风雷']='风雷益:BAAALgADCgEJAQAAAA==.',
['飘渺']='飘渺若水:BAAALgAECgQJBQAAAA==.',
['飘零']='飘零酒:BAABLgAECn8VAAIRAAYJ9hihKQBqAQARAAYJ9hihKQBqAQAAAA==.',
['饿龙']='饿龙康娜:BAAALgAFFAEJAQAAAA==.',
['馋馋']='馋馋:BAAALgADCgYJBgAAAA==.',
['香甜']='香甜橙:BAAALgAECgEJAQABLgAECgMJBAADAAAAAA==.',
['魅之']='魅之影:BAABLgAECn8XAAMdAAcJ/hOCCQCrAQAdAAYJmRaCCQCrAQAQAAYJ8A1vhQBPAQAAAA==.',
['魔女']='魔女小晗:BAAALgAECgEJAQAAAA==.',
['鱼及']='鱼及:BAAALgAECgYJCAAAAA==.',
['黑夜']='黑夜千只眼:BAABLgAECn8dAAQeAAcJ0hsNEQCNAQAEAAYJDhxpMwDdAQAeAAUJHB8NEQCNAQAfAAIJGBXWPABmAAAAAA==.黑夜奶奥祖:BAABLgAFFH8HAAIFAAMJxBuvDQABAQAFAAMJxBuvDQABAQAAAA==.',
['黑奥']='黑奥瑞克:BAAALgAECgQJBgAAAA==.',
['黑暗']='黑暗执行官:BAAALgAECgQJBAAAAA==.',
['黑枫']='黑枫:BAAALgADCgYJBgAAAA==.',
['黑色']='黑色幸福:BAABLgAECn8bAAQIAAYJCx26PwD1AQAIAAYJCx26PwD1AQAVAAIJow8DXwBlAAAgAAEJwREAAAAAAAAAAA==.',
['黑袜']='黑袜粗腿小熊:BAAALgAECgUJCQAAAA==.',
['黑风']='黑风闪电:BAAALgADCgEJAQAAAA==.',
['默等']='默等:BAAALgADCgYJBgAAAA==.',
['龙城']='龙城斑长:BAAALgAECgYJEwAAAA==.',
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
