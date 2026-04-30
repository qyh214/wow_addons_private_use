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

local lookup = {'Unknown-Unknown','DeathKnight-Unholy','Mage-Frost','Priest-Holy','Priest-Discipline','Evoker-Augmentation','Hunter-BeastMastery','Evoker-Preservation','Warrior-Arms','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Warlock-Destruction','Rogue-Subtlety','Evoker-Devastation','Monk-Brewmaster','Monk-Mistweaver','Priest-Shadow','Paladin-Holy','Shaman-Elemental','Monk-Windwalker','Druid-Balance','Hunter-Survival','DemonHunter-Havoc','DemonHunter-Devourer','Paladin-Retribution',}
local provider = {region='CN',realm='埃加洛尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adwen:BAAALgAECgIJAwAAAA==.',
Ba='Baojojo:BAAALgAECgYJBgAAAA==.',
Be='Berberber:BAAALgADCgUJBQAAAA==.',
Bl='Bleachz:BAAALgAECgcJCwAAAA==.',
Cl='Clime:BAAALgAECgUJCwAAAA==.',
Co='Connie:BAAALgADCgEJAQAAAA==.',
De='Demonx:BAAALgAECgYJBwAAAA==.',
Hu='Humanb:BAAALgADCgQJBAAAAA==.Hunterbleach:BAAALgAECgYJBwAAAA==.',
Jw='Jwq:BAAALgAECgUJBQABLgAFFAIJAwABAAAAAA==.',
Lr='Lrzhkb:BAAALgAECgMJAwAAAA==.',
Mo='Moouse:BAAALgAECgEJAQAAAA==.',
Ne='Nevailsun:BAAALgAECgYJEwAAAA==.',
Om='Omnigalaxy:BAAALgAFFAQJBAAAAA==.',
Ru='Ruohan:BAAALgAECgYJDAAAAA==.',
Sn='Snake:BAAALgAECgEJAQAAAA==.',
So='So:BAAALgAFFAEJAQAAAA==.',
Sz='Szh:BAAALgAECgQJBAAAAA==.',
Vi='Vincent:BAAALgAECgcJAQABLgAFFAUJCAACAPIeAA==.Vitaminc:BAAALgAECgYJBgAAAA==.',
Ze='Zerodal:BAABLgAFFH8FAAIDAAIJCxRoOgC2AAADAAIJCxRoOgC2AAAAAA==.Zeronine:BAAALgAECgQJBQAAAA==.',
['一口']='一口就一口:BAAALgAECgYJDAABLgAFFAQJBgADACMEAA==.',
['一派']='一派狐言:BAAALgAECgYJBwAAAA==.',
['不吉']='不吉的黑白:BAAALgADCgEJAQAAAA==.',
['不爱']='不爱刷牙:BAAALgAECgcJDAAAAA==.',
['且行']='且行且惜:BAAALgAECgQJAwAAAA==.',
['丢失']='丢失的翅膀:BAAALgAECgYJCgAAAA==.',
['丨丶']='丨丶半颗心:BAAALgAECgYJEgAAAA==.',
['丨喵']='丨喵乄喵丨:BAAALgAECgYJBgAAAA==.',
['丶丶']='丶丶低小调:BAAALgAECgUJBgAAAA==.',
['丶妖']='丶妖小妖:BAABLgAFFH8MAAMEAAQJFBP9BwDqAAAEAAQJFBP9BwDqAAAFAAEJGQsjGgBHAAAAAA==.丶妖零妖:BAAALgAECgUJBgAAAA==.',
['乌鸡']='乌鸡:BAAALgAECgEJAQAAAA==.',
['二零']='二零二六加油:BAAALgAECgQJBAAAAA==.',
['亚历']='亚历山大:BAAALgAFFAMJAwAAAA==.',
['亚妮']='亚妮拉丝:BAAALgADCgEJAQAAAA==.',
['今天']='今天吃饭了吗:BAAALgAECgQJBAAAAA==.',
['从不']='从不缺德:BAAALgADCgIJAgAAAA==.',
['从小']='从小喝到大:BAAALgAECggJDAAAAA==.',
['代王']='代王里天神:BAAALgAECgQJBgAAAA==.',
['代眼']='代眼睛的流氓:BAAALgADCgYJBgAAAA==.',
['伯劳']='伯劳:BAAALgADCgIJAgAAAA==.',
['低调']='低调的教主:BAAALgAECgEJAgAAAA==.',
['假死']='假死威慑跑尸:BAAALgAECgcJDQAAAA==.',
['傲世']='傲世:BAACLgAFFH8GAAIGAAMJuw+JFgCtAAAGAAMJuw+JFgCtAAAuAAQKfxwAAgYACAkIHMsBAFACAAYACAkIHMsBAFACAAAA.',
['八英']='八英里丶:BAAALgAECgkJBgAAAA==.',
['兰涩']='兰涩月光:BAAALgADCgYJCQAAAA==.',
['军火']='军火女王:BAAALgAECgQJBAAAAA==.',
['冥绫']='冥绫:BAAALgAECgEJAQAAAA==.',
['冬也']='冬也迟迟:BAAALgAECgEJAQAAAA==.',
['冰凉']='冰凉咖啡:BAAALgAECgQJBAAAAA==.',
['凶凶']='凶凶的熊猫:BAAALgADCgEJAQAAAA==.',
['加塞']='加塞拉:BAAALgAFFAEJAQAAAA==.',
['千丶']='千丶秋:BAAALgADCgUJBQAAAA==.',
['千华']='千华留:BAACLgAFFH8FAAIHAAMJiSC6BgA2AQAHAAMJiSC6BgA2AQAuAAQKfyAAAgcACAnxI2IEAEkDAAcACAnxI2IEAEkDAAAA.',
['参天']='参天大刘欢:BAAALgAECgEJAgAAAA==.',
['只用']='只用左眼瞄:BAAALgAECgEJAQAAAA==.',
['可乐']='可乐大鸡腿:BAAALgADCgEJAQAAAA==.',
['司徒']='司徒:BAAALgADCgUJBQAAAA==.',
['哎呦']='哎呦喂呦呵:BAAALgAFFAIJAgAAAA==.',
['哮坏']='哮坏:BAAALgAECgEJAQAAAA==.',
['啾啾']='啾啾飛崽:BAAALgAECgYJBgAAAA==.',
['喃喃']='喃喃自语:BAABLgAFFH8FAAIIAAIJHgsdCACBAAAIAAIJHgsdCACBAAAAAA==.',
['嘉贝']='嘉贝丽娜:BAAALgAECgYJBgAAAA==.',
['嘎嘎']='嘎嘎学徒:BAABLgAFFH8GAAIDAAQJIwRJJAAlAQADAAQJIwRJJAAlAQAAAA==.',
['四十']='四十不得已:BAAALgAECgcJDAAAAA==.',
['国术']='国术:BAAALgAFFAQJBAAAAA==.',
['土特']='土特维德:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光丿罗兰:BAAALgAFFAEJAQAAAA==.圣光之吻:BAAALgADCgcJBwAAAA==.',
['圣殿']='圣殿之主:BAAALgADCgMJAwAAAA==.',
['地亩']='地亩:BAAALgAECgEJAQAAAA==.',
['地尅']='地尅提:BAAALgAECgUJCQAAAA==.',
['复活']='复活魔王:BAAALgAECgkJBwAAAA==.',
['夕立']='夕立加油:BAAALgAECgYJDAAAAA==.',
['外圆']='外圆复合循环:BAAALgAECgEJAQAAAA==.',
['大筒']='大筒木羽衣:BAAALgAECgMJBQAAAA==.',
['大脚']='大脚怪:BAACLgAFFH8GAAMJAAMJqg4qBAD4AAAJAAMJqg4qBAD4AAAKAAEJSgY5JABMAAAuAAQKfx0ABAoABwlvHe4fAFICAAoABwnCG+4fAFICAAkABglVFOUPAJ4BAAsAAQn+FlVFADcAAAAA.',
['天煞']='天煞:BAAALgAECgQJAwAAAA==.',
['天霆']='天霆号阿宙斯:BAAALgAECgEJAQABLgAECgcJHwADAOUlAA==.',
['天馳']='天馳哥哥:BAAALgAECgUJBwAAAA==.天馳妹妹丶:BAABLgAECn8VAAMGAAYJcQyLNwAZAQAGAAYJcQyLNwAZAQAIAAYJcQSlLgD9AAAAAA==.',
['天魂']='天魂无双:BAAALgAECgEJAQAAAA==.',
['太妍']='太妍:BAAALgAECgUJBwAAAA==.',
['奶有']='奶有三聚氢氨:BAAALgAECgQJBAAAAA==.',
['妖石']='妖石:BAAALgADCgUJBQAAAA==.',
['妞萌']='妞萌萌:BAAALgAECgYJDQAAAA==.',
['妩媚']='妩媚的小黄花:BAAALgAECgYJBgAAAA==.',
['妹妹']='妹妹门别锁:BAAALgAECgQJBgAAAA==.',
['子夜']='子夜惊鸿:BAAALgAECgEJAQAAAA==.子夜晨曦:BAAALgAECgcJDQAAAA==.子夜清风:BAAALgAECgYJBgAAAA==.子夜葳蕤:BAAALgAECgMJAwAAAA==.',
['孤烟']='孤烟:BAAALgAECgYJCwAAAA==.',
['宝宝']='宝宝丨咬死他:BAAALgAECgMJAwAAAA==.',
['宝贝']='宝贝儿:BAAALgAFFAEJAQAAAA==.',
['寒宵']='寒宵:BAAALgAFFAIJAgAAAA==.',
['小偷']='小偷:BAAALgADCgYJCQAAAA==.',
['小小']='小小白一只:BAAALgADCgEJAQAAAA==.小小的白白:BAAALgAECgEJAQAAAA==.',
['小白']='小白的老大:BAAALgAECgUJBgAAAA==.',
['小鱼']='小鱼儿:BAAALgAECgcJCgAAAA==.',
['尛尛']='尛尛熊丶:BAAALgAECgcJEAAAAA==.',
['左为']='左为门:BAACLgAFFH8MAAMMAAUJNx5EEgBUAQAMAAUJNRlEEgBUAQANAAEJ6x0tEQBdAAAuAAQKfxgAAw0ABwmGIh0JAC8CAA0ABgk9Ih0JAC8CAAwABQlqGo+AAFkBAAAA.',
['左未']='左未门:BAAALgAECgMJAwABLgAFFAUJDAAMADceAA==.',
['市芄']='市芄银:BAAALgADCgEJAQAAAA==.',
['帅少']='帅少丶:BAAALgAECgcJCAAAAA==.',
['带眼']='带眼镜小流氓:BAAALgAECgcJCAAAAA==.带眼镜的流氓:BAAALgAECgYJCwAAAA==.',
['帧数']='帧数:BAAALgAECgkJDgAAAA==.',
['年少']='年少有爲:BAAALgAECgMJAwAAAA==.',
['德里']='德里克斯安娜:BAAALgAECgcJBwAAAA==.',
['心曲']='心曲且悠悠:BAAALgADCgUJBQAAAA==.',
['忧傷']='忧傷调:BAACLgAFFH8MAAMMAAQJ6xZ/EgBTAQAMAAQJ6xZ/EgBTAQANAAEJvhMrFABWAAAuAAQKfx4AAwwACAk0I2ojAIYCAAwABwkKI2ojAIYCAA0AAwm/IIoqABcBAAAA.',
['快变']='快变石头:BAAALgAECgYJBgAAAA==.',
['恶魔']='恶魔之击:BAABLgAECn8XAAIOAAcJCRBaJwC9AQAOAAcJCRBaJwC9AQAAAA==.',
['悄悄']='悄悄慕斯猫:BAAALgAECgEJAQAAAA==.',
['惠惠']='惠惠子丶:BAAALgAECgcJBwAAAA==.惠惠子醬:BAAALgAECgYJBgAAAA==.',
['憨牛']='憨牛骑士:BAAALgAECgkJEAABLgAFFAQJBgADACMEAA==.',
['懒虫']='懒虫灬混沌:BAAALgAECgEJAQAAAA==.',
['我的']='我的假死呢:BAAALgAECgkJBwAAAA==.我的放逐呢:BAAALgAECgkJBwAAAA==.',
['戴眼']='戴眼镜小流氓:BAAALgAECgYJBAAAAA==.',
['找夕']='找夕夕:BAAALgADCgEJAQAAAA==.',
['找大']='找大头:BAAALgADCgUJBQAAAA==.找大妈:BAAALgADCgYJBgAAAA==.找大桃:BAACLgAFFH8UAAMGAAUJNxvgCgBHAQAGAAQJNxvgCgBHAQAPAAEJAADBCwBIAAAuAAQKfxoAAwYACAnCG1gNAKACAAYACAnCG1gNAKACAA8AAwm5BjswAJUAAAAA.找大瓜:BAABLgAFFH8GAAMMAAQJYga2JwDcAAAMAAMJNAa2JwDcAAANAAEJ7wZzGABNAAAAAA==.找大蛙:BAAALgAECgEJAQAAAA==.',
['抖动']='抖动的双波:BAACLgAFFH8VAAIQAAUJQBhfBQB+AQAQAAUJQBhfBQB+AQAuAAQKfxUAAxAACQl0E9QlANUBABAABwm2GdQlANUBABEAAgmRAj1jAEQAAAAA.',
['撒拉']='撒拉弗:BAACLgAFFH8GAAIEAAIJmyWdCADeAAAEAAIJmyWdCADeAAAuAAQKfxcABAQABwkWISkSAE8CAAQABwlaHSkSAE8CAAUAAgn9HANBAKkAABIAAgkIEExXAGEAAAAA.',
['数师']='数师:BAAALgAFFAQJAgABLgAFFAcJBwAMADocAA==.',
['斩崩']='斩崩刀:BAAALgADCgYJBgAAAA==.',
['无敌']='无敌小猎:BAAALgAECgcJCAAAAA==.',
['旺旺']='旺旺砕氷氷丶:BAAALgAECgEJAgAAAA==.',
['春寒']='春寒料峭冫:BAAALgAECgMJAwAAAA==.',
['春风']='春风十里:BAAALgADCgYJBgAAAA==.',
['晓舞']='晓舞:BAAALgAECgYJDAAAAA==.',
['晚睡']='晚睡的兔兔:BAAALgAFFAEJAQABLgAFFAMJAwABAAAAAA==.晚睡的猫猫:BAAALgAFFAIJAgABLgAFFAMJAwABAAAAAA==.',
['暗黑']='暗黑破壞神:BAACLgAFFH8FAAIDAAMJ3AfLHACjAAADAAMJ3AfLHACjAAAuAAQKfxkAAgMABwmBGX1kAA8CAAMABwmBGX1kAA8CAAAA.',
['月亮']='月亮祭司:BAAALgAECgcJDgAAAA==.',
['月光']='月光阴影:BAAALgAECgkJCQAAAA==.',
['月夜']='月夜王者:BAAALgAECgMJAwAAAA==.',
['月海']='月海亭甘雨:BAAALgAECgYJEAAAAA==.',
['有点']='有点小嚣张丶:BAAALgAECgEJAQAAAA==.',
['朝汐']='朝汐汐:BAAALgAECgMJAwAAAA==.',
['朴昊']='朴昊龙:BAAALgAECgUJCQABLgAFFAUJDAAMADceAA==.',
['杏子']='杏子林:BAAALgAECgcJDgAAAA==.',
['杰宝']='杰宝宝:BAAALgAECgMJAwAAAA==.',
['极地']='极地狼神:BAAALgADCgUJBQAAAA==.',
['果蓖']='果蓖儿:BAAALgAECgYJBgABLgAECgkJDAABAAAAAA==.',
['柠檬']='柠檬好萌:BAAALgAECgMJAwAAAA==.柠檬特萌:BAAALgAECgEJAQAAAA==.',
['格桑']='格桑卓玛:BAAALgADCgEJAQAAAA==.',
['案钟']='案钟观茶:BAAALgADCgUJBQAAAA==.',
['梦想']='梦想天空:BAAALgAFFAQJBAAAAA==.',
['極楽']='極楽浄土:BAABLgAECn8YAAIKAAcJgg3DSACBAQAKAAcJgg3DSACBAQAAAA==.',
['水星']='水星上的萌货:BAAALgAECgYJBgAAAA==.',
['沐月']='沐月星河:BAAALgAECgEJAQAAAA==.',
['混乱']='混乱见:BAAALgAFFAQJBAAAAA==.',
['灭天']='灭天一箭:BAAALgAECgQJBAAAAA==.',
['灵魂']='灵魂碎片贩子:BAAALgAECgMJAwAAAA==.',
['炎菲']='炎菲:BAAALgAECgIJAgAAAA==.',
['炮仔']='炮仔:BAAALgADCgYJBgAAAA==.',
['炸药']='炸药:BAAALgAECgkJBgAAAA==.',
['熊日']='熊日天:BAAALgAECgMJBAAAAA==.',
['燃烧']='燃烧丶残阳:BAAALgAECgcJCgAAAA==.',
['爱丽']='爱丽丝威震天:BAAALgAECgYJDAAAAA==.',
['爺恐']='爺恐怖人物:BAAALgAFFAEJAQAAAA==.',
['片子']='片子大姐:BAAALgAECgcJDAABLgAFFAcJBwATADwVAA==.',
['牛呣']='牛呣呣:BAAALgAECgEJAQAAAA==.',
['牛萨']='牛萨:BAAALgAECgYJDgAAAA==.',
['狂暴']='狂暴冥神:BAAALgAECgEJAQAAAA==.',
['狂闻']='狂闻老头菊花:BAAALgAECgEJAQAAAA==.',
['狂风']='狂风怒号:BAAALgADCgcJDAAAAA==.',
['猫小']='猫小萌:BAAALgADCgIJAQAAAA==.',
['猫猫']='猫猫个个:BAAALgAECgEJAgAAAA==.',
['獃丶']='獃丶某德:BAAALgADCgEJAQAAAA==.',
['玉帝']='玉帝哥哥:BAAALgAECgYJDwAAAA==.',
['甜小']='甜小甜:BAABLgAECn8aAAIMAAcJ5BnAOwAdAgAMAAcJ5BnAOwAdAgAAAA==.',
['番茄']='番茄蛋:BAACLgAFFH8FAAIUAAMJxRJADwD7AAAUAAMJxRJADwD7AAAuAAQKfyAAAhQACAlNHSIPALUCABQACAlNHSIPALUCAAAA.',
['疯狂']='疯狂小萨:BAAALgAECgIJAQAAAA==.',
['矮丑']='矮丑法王:BAAALgAFFAEJAQAAAA==.',
['破碎']='破碎精灵:BAAALgAFFAEJAQAAAA==.',
['秋已']='秋已陌:BAAALgAECgYJBgAAAA==.',
['秘密']='秘密教学啊:BAAALgADCgUJBQAAAA==.',
['突然']='突然挂机:BAAALgAECgUJBgAAAA==.',
['竹影']='竹影熊熊:BAAALgAECgIJAgAAAA==.',
['箭箭']='箭箭开心:BAAALgAECgIJAgAAAA==.',
['米奈']='米奈希尔:BAAALgAECgEJAQAAAA==.',
['糕手']='糕手蛋花汤:BAAALgAFFAYJAQAAAA==.',
['素酒']='素酒:BAAALgAFFAQJBAAAAA==.',
['给我']='给我擦皮鞋:BAAALgAECgEJAQAAAA==.',
['续真']='续真水无香:BAAALgAECgkJBwAAAA==.',
['美少']='美少女小惠:BAAALgAECgYJBgAAAA==.',
['美术']='美术式:BAAALgAECgcJDAAAAA==.',
['翻滾']='翻滾吧牛寶寶:BAAALgADCgYJBgAAAA==.',
['老巫']='老巫婆:BAAALgAECgEJAQAAAA==.',
['老衲']='老衲被逼出家:BAAALgAECgcJDQAAAA==.',
['考拉']='考拉是一只熊:BAAALgAECgcJDwAAAA==.',
['聼琳']='聼琳語:BAAALgAECgEJAQAAAA==.',
['肆绫']='肆绫灵舞:BAAALgAECgIJAwABLgAFFAMJCwASAGIjAA==.',
['自奏']='自奏圣乐:BAABLgAECn8fAAIDAAcJ5SWKCAAfAgADAAcJ5SWKCAAfAgAAAA==.',
['花子']='花子:BAACLgAFFH8HAAIDAAMJVRZnEwD5AAADAAMJVRZnEwD5AAAuAAQKfxoAAgMABwlIH8c+AH0CAAMABwlIH8c+AH0CAAAA.',
['苏醒']='苏醒的兽灵:BAAALgAECgYJBwAAAA==.苏醒的背叛:BAAALgAECgIJAgAAAA==.',
['苟术']='苟术:BAAALgAECgkJDwAAAA==.',
['茴香']='茴香饺子:BAAALgADCgUJBQAAAA==.',
['莱恩']='莱恩曼妮:BAABLgAECn8dAAMMAAYJLBeIhQBPAQAMAAYJLBeIhQBPAQANAAIJgQ7yVgBpAAAAAA==.',
['菩提']='菩提非树:BAAALgADCgEJAQAAAA==.',
['萌萌']='萌萌丨熊:BAAALgAECgMJAwAAAA==.',
['落叶']='落叶丶:BAAALgADCgMJAwAAAA==.',
['蓝风']='蓝风的向日葵:BAAALgAECgUJBgAAAA==.',
['蘆台']='蘆台春:BAAALgAECgIJAgAAAA==.',
['血中']='血中悍刀行:BAAALgADCgEJAQAAAA==.',
['西海']='西海岸丶:BAABLgAFFH8HAAIGAAUJGCPGAQCTAQAGAAUJGCPGAQCTAQAAAA==.',
['诅咒']='诅咒:BAAALgAECgEJAQAAAA==.',
['话术']='话术:BAAALgAECgkJBwAAAA==.',
['语雨']='语雨者:BAAALgAECgYJBgAAAA==.',
['请叫']='请叫我盲僧:BAAALgAECgYJDAAAAA==.',
['谁是']='谁是谁菲:BAAALgAECgUJCAAAAA==.',
['贼有']='贼有劲丶:BAAALgAECgEJAQAAAA==.',
['赵曰']='赵曰天大魔王:BAAALgAECgcJBwAAAA==.',
['达克']='达克宁:BAABLgAFFH8HAAICAAQJbwI8IQATAQACAAQJbwI8IQATAQAAAA==.',
['速度']='速度灭啊:BAAALgAECgYJCwAAAA==.',
['那个']='那个惩戒骑:BAAALgAECgkJBwAAAA==.',
['邪王']='邪王真眼:BAAALgAECgYJCgAAAA==.',
['邪能']='邪能道尊:BAAALgAECgEJAQAAAA==.',
['酒精']='酒精过敏:BAABLgAECn8WAAMVAAYJ7BR+MABlAQAVAAYJ7BR+MABlAQARAAUJXgadEwCqAAAAAA==.',
['酒酿']='酒酿小丸子:BAAALgAECgkJAwABLgAFFAUJDwAWAHsmAA==.',
['鑫森']='鑫森淼焱垚燚:BAAALgAECgMJAwAAAA==.',
['青梅']='青梅嗅:BAAALgAFFAIJAgAAAA==.',
['非常']='非常牛:BAAALgADCgEJAQAAAA==.',
['非牛']='非牛类:BAACLgAFFH8LAAIHAAQJLBI+DAAAAQAHAAQJLBI+DAAAAQAuAAQKfxkAAwcACAnfHNMRAKoCAAcACAnfHNMRAKoCABcAAwmQB2APAHMAAAAA.',
['颜柏']='颜柏:BAAALgAECgYJBwAAAA==.',
['飛法']='飛法待哺:BAAALgAECgYJBgABLgAECgYJBgABAAAAAA==.',
['鬼麟']='鬼麟丨小乐:BAAALgAECgcJCQAAAA==.',
['魔王']='魔王复活:BAAALgAECgcJBwAAAA==.',
['魔神']='魔神:BAAALgAECgEJAgAAAA==.',
['鱼片']='鱼片儿:BAACLgAFFH8FAAIYAAMJXw/9BQD0AAAYAAMJXw/9BQD0AAAuAAQKfxcAAxgABwmAFfIYAP8BABgABwmAFfIYAP8BABkABAkrCwi1AJ4AAAAA.',
['鱼鲤']='鱼鲤:BAAALgADCgEJAQAAAA==.',
['鲜红']='鲜红的幼月:BAAALgAECgMJAwAAAA==.',
['黄昏']='黄昏之挽歌:BAAALgAECgYJBAAAAA==.',
['黯月']='黯月织法:BAAALgAECgUJBQAAAA==.',
['龙逸']='龙逸轩:BAACLgAFFH8GAAIaAAMJ7hvhEAAeAQAaAAMJ7hvhEAAeAQAuAAQKfyEAAhoACAkWISEWAOQCABoACAkWISEWAOQCAAAA.',
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
