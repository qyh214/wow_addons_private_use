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

local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Mage-Frost','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Evoker-Preservation','Hunter-Survival','Warlock-Demonology','Warlock-Destruction','Priest-Shadow','Priest-Discipline','Paladin-Retribution','Priest-Holy','Rogue-Outlaw','Druid-Balance','Druid-Restoration','Shaman-Restoration','Shaman-Elemental',}
local provider = {region='CN',realm='能源舰',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Andruid:BAAALgAECgUJCwAAAA==.',
Bi='Biubiulikeme:BAACLgAFFH8VAAMBAAYJYCIVBAD8AQABAAYJRxgVBAD8AQACAAQJ1SQ9BQBHAQAuAAQKfx0AAwIACQmGJKQVAIsCAAIABgmRJqQVAIsCAAEABgkoHsExAKcBAAAA.',
Co='Coopycat:BAAALgADCgYJBgAAAA==.Copycatt:BAAALgAECgcJDAAAAA==.',
De='Deepha:BAACLgAFFH8GAAIDAAMJchR4BQAFAQADAAMJchR4BQAFAQAuAAQKfxYAAgMABwlaILkPAGkCAAMABwlaILkPAGkCAAAA.',
Fr='Fractal:BAAALgAECgQJBQAAAA==.',
Ki='Kissxiao:BAAALgAECgYJBwAAAA==.',
Ku='Kukishow:BAAALgAECgEJAQAAAA==.',
Me='Measter:BAAALgADCgUJBQAAAA==.',
Mo='Mokoko:BAAALgADCgUJBQAAAA==.Movvf:BAAALgAFFAEJAQAAAA==.',
Na='Narro:BAACLgAFFH8SAAIEAAYJqB1zAwBAAgAEAAYJqB1zAwBAAgAuAAQKfyIAAgQACAnUI+wOAFADAAQACAnUI+wOAFADAAAA.',
Ne='Nephale:BAAALgAECgYJDAAAAA==.',
Sa='Sammael:BAAALgAECgkJCQAAAA==.',
Si='Six:BAAALgADCgUJBQAAAA==.',
St='Stanphs:BAAALgAECgYJDgAAAA==.',
Tv='Tv:BAAALgAECgkJDwAAAA==.',
Vi='Vivodefather:BAAALgAECgYJCAAAAA==.',
Wi='Wintercoming:BAAALgAECgcJCQAAAA==.',
['一只']='一只大老鼠:BAAALgAECgEJAQAAAA==.',
['一坨']='一坨黄:BAAALgAECgQJBgAAAA==.',
['七七']='七七猫猫宝:BAAALgAFFAQJBAAAAA==.',
['三只']='三只小熊:BAAALgAECgUJBQAAAA==.',
['三月']='三月七:BAAALgAECgEJAQABLgAECgYJCAAFAAAAAA==.',
['三队']='三队那个小德:BAAALgAECgYJEgABLgAFFAYJEgAEAKgdAA==.',
['不包']='不包吃不包住:BAAALgAECgYJEAAAAA==.',
['不想']='不想当死骑:BAAALgADCgMJAwAAAA==.',
['专业']='专业捅马蜂:BAAALgAECgcJBgAAAA==.',
['世界']='世界之灾:BAAALgADCgEJAQAAAA==.',
['临西']='临西插棍:BAAALgADCgUJBQAAAA==.',
['丸子']='丸子烧饼:BAAALgAECgUJBQABLgAECggJCAAFAAAAAA==.',
['之子']='之子狗:BAAALgAECgYJCAAAAA==.',
['乌璐']='乌璐鲁丶:BAAALgAECgEJAQAAAA==.',
['五匹']='五匹马:BAAALgAECgkJBwAAAA==.',
['五行']='五行还缺水:BAAALgADCgcJCwAAAA==.',
['今朝']='今朝切夜点心:BAAALgAECgcJBAAAAA==.',
['介是']='介是瞎胡闹:BAAALgADCgcJBwAAAA==.',
['伊德']='伊德利菈:BAAALgAFFAEJAgAAAA==.',
['你亲']='你亲大爷丶:BAAALgAECgUJBQAAAA==.',
['你意']='你意外的:BAAALgAECgIJAgAAAA==.',
['你的']='你的宽容:BAAALgADCgUJCAAAAA==.',
['你等']='你等着寿司吧:BAAALgAECgcJCQAAAA==.',
['優若']='優若曦:BAAALgAFFAEJAQAAAA==.',
['光影']='光影行者艾琳:BAAALgAECgMJAwAAAA==.',
['兜兜']='兜兜都有:BAAALgAECgYJBgAAAA==.',
['六眼']='六眼飞鱼:BAABLgAFFH8NAAMGAAUJYBNXFgBKAQAGAAQJYBNXFgBKAQAHAAEJAAAcGQA4AAAAAA==.',
['六道']='六道狂德:BAAALgADCgIJAgAAAA==.',
['冰风']='冰风猎:BAAALgAFFAQJBAAAAA==.',
['冻住']='冻住丶不许跑:BAAALgAFFAEJAgAAAA==.',
['凌乱']='凌乱:BAAALgADCgEJAQAAAA==.',
['划开']='划开御姐扇贝:BAAALgAECgEJAQAAAA==.',
['刘宇']='刘宇星:BAAALgAECgMJBQAAAA==.',
['区万']='区万贵:BAAALgAFFAEJAgAAAA==.',
['十三']='十三嗜:BAAALgADCgcJAQAAAA==.十三姨:BAAALgADCgcJDAAAAA==.',
['半朋']='半朋克:BAAALgAECgEJAQAAAA==.',
['卖火']='卖火孩的柴:BAAALgADCgUJBQAAAA==.',
['卢森']='卢森特丨邪焰:BAAALgAECgIJAgAAAA==.',
['只要']='只要三五:BAAALgADCgEJAQAAAA==.',
['叮叮']='叮叮烟凝:BAAALgAECgYJDAAAAA==.',
['哇偶']='哇偶打得不错:BAAALgAFFAEJAQAAAA==.',
['善良']='善良的伊利聃:BAAALgADCgEJAQAAAA==.善良的哈基:BAAALgAECgIJBAAAAA==.善良的阿萨:BAAALgAECgEJAgAAAA==.',
['喵莫']='喵莫斯喵:BAAALgAECgYJCQAAAA==.',
['嚣聋']='嚣聋人:BAAALgAECgIJAgAAAA==.',
['夏日']='夏日的微风:BAAALgAECgIJAgAAAA==.',
['多恩']='多恩诺德:BAAALgAECgEJAQAAAA==.',
['夜灬']='夜灬微眠:BAAALgADCgEJAQAAAA==.',
['大丨']='大丨丶圣:BAAALgAECgQJBAAAAA==.',
['大橘']='大橘喵:BAAALgAECgUJBQAAAA==.',
['大神']='大神萨:BAAALgAFFAEJAQAAAA==.',
['大蛇']='大蛇无双:BAAALgAECgIJAgAAAA==.',
['天冬']='天冬:BAAALgAFFAEJAQAAAA==.',
['天可']='天可汗:BAAALgAECgEJAQAAAA==.',
['好多']='好多鱼好多余:BAAALgAECgYJBgAAAA==.',
['孤独']='孤独与背叛:BAAALgAECgYJBgABLgAFFAUJAQAFAAAAAA==.',
['寂静']='寂静修女:BAAALgADCgcJDQAAAA==.寂静岭:BAAALgADCgYJBgAAAA==.寂静的拖鞋:BAAALgADCgIJAgAAAA==.',
['寒芒']='寒芒点点:BAAALgAECgEJAQAAAA==.',
['小兔']='小兔的五妞子:BAAALgAECgEJAgAAAA==.',
['小圆']='小圆:BAAALgADCgEJAQAAAA==.',
['小小']='小小猫猫宝:BAAALgAECgkJBQAAAA==.',
['小林']='小林立奇:BAAALgAECgEJAQAAAA==.',
['小血']='小血僧:BAAALgAECgUJBwAAAA==.',
['小豆']='小豆包儿:BAABLgAFFH8FAAIIAAIJlRUUEgCeAAAIAAIJlRUUEgCeAAAAAA==.',
['小铭']='小铭铭:BAAALgADCgEJAQAAAA==.',
['尔玉']='尔玉:BAAALgAECgYJBwAAAA==.',
['尖牙']='尖牙:BAAALgAECgMJBAAAAA==.',
['尚能']='尚能饭否:BAAALgAECgUJBQAAAA==.',
['屍匄']='屍匄騏仕:BAAALgAECgEJAQAAAA==.',
['左丶']='左丶左:BAAALgAECgcJDgAAAA==.',
['巨德']='巨德:BAAALgAECgIJAgAAAA==.',
['巫喵']='巫喵王丶:BAAALgAECgEJAQAAAA==.',
['帅帅']='帅帅劣:BAAALgAECgcJDAABLgAFFAUJBQACAJkBAA==.',
['幽冥']='幽冥狂刹:BAAALgADCgMJBAAAAA==.',
['彼克']='彼克大魔王:BAAALgAECgEJAgAAAA==.',
['得瑟']='得瑟怪叔叔:BAAALgAFFAEJAQAAAA==.',
['忆仙']='忆仙姿:BAAALgADCgYJBgAAAA==.',
['忘西']='忘西:BAAALgADCgEJAQAAAA==.',
['性感']='性感萬筒条:BAAALgAECgQJBAAAAA==.',
['悠悠']='悠悠凌波:BAAALgAECgIJAgAAAA==.',
['情绪']='情绪不稳定:BAAALgAECgYJDAAAAA==.',
['懒涩']='懒涩妖精:BAAALgAECgcJAQAAAA==.',
['成功']='成功变胖子:BAAALgADCgYJDAAAAA==.',
['我刘']='我刘德华却:BAABLgAFFH8RAAMGAAUJBRkvEwBVAQAGAAQJBRkvEwBVAQAHAAEJAADYGQA1AAAAAA==.',
['扎师']='扎师父:BAAALgAFFAEJAgAAAA==.',
['打麻']='打麻将从不输:BAAALgADCgMJAwAAAA==.',
['扯淡']='扯淡淡丶:BAAALgAECgUJBQAAAA==.',
['抓个']='抓个德做宠物:BAAALgAECgcJBwAAAA==.',
['挺有']='挺有牌面:BAAALgAECggJBwAAAA==.',
['挽歌']='挽歌:BAABLgAECn8cAAIGAAgJ6CQYCgBLAwAGAAgJ6CQYCgBLAwAAAA==.',
['挽风']='挽风:BAAALgAECgYJBgAAAA==.',
['挽魂']='挽魂歌:BAAALgAECgUJBQABLgAECggJHAAGAOgkAA==.',
['撒一']='撒一狗:BAAALgADCgQJBAAAAA==.',
['无泪']='无泪:BAAALgAECgEJAQAAAA==.',
['无矢']='无矢:BAABLgAECn8lAAQBAAgJASBQCwDwAgABAAgJ0x9QCwDwAgAJAAcJXRerAwDgAQACAAEJtCGCRQBiAAAAAA==.',
['无聊']='无聊的鸡蛋:BAAALgAECgEJAQAAAA==.',
['星宮']='星宮一花:BAAALgAECgkJCQAAAA==.',
['春去']='春去花还在:BAAALgADCgEJAQAAAA==.',
['是只']='是只大肉兔哦:BAAALgADCgcJBwAAAA==.是只大肉兔阿:BAAALgAECgUJBQAAAA==.是只小野猪哦:BAAALgAECgMJAwAAAA==.',
['是觉']='是觉觉呀:BAAALgAFFAMJAwAAAA==.',
['暴躁']='暴躁路人甲:BAAALgAECgIJAgAAAA==.',
['最后']='最后乃我一口:BAAALgAECgMJBAAAAA==.',
['月白']='月白知有意:BAAALgAECgEJAQAAAA==.',
['机甲']='机甲锅包肉:BAAALgAECgQJBAAAAA==.',
['杀手']='杀手王钢蛋:BAAALgAECgUJBQAAAA==.',
['束缚']='束缚你的灵魂:BAAALgAECgEJAQAAAA==.',
['柱子']='柱子能奶你吗:BAAALgAFFAEJAQAAAA==.',
['核桃']='核桃核桃:BAAALgAECgEJAQAAAA==.',
['梦玲']='梦玲珑:BAAALgAECgIJAgAAAA==.',
['梦魇']='梦魇丶躺尸侠:BAABLgAFFH8RAAMKAAQJgBKDEABdAQAKAAQJgBKDEABdAQALAAEJwhCCFQBTAAAAAA==.梦魇艾希:BAAALgADCgUJBQAAAA==.',
['梧桐']='梧桐:BAABLgAFFH8GAAIMAAQJ6Q6zBwBMAQAMAAQJ6Q6zBwBMAQAAAA==.',
['欧鸡']='欧鸡饱:BAAALgAECgcJBwAAAA==.',
['欲望']='欲望满身:BAAALgADCgUJBQAAAA==.',
['武神']='武神唐三葬:BAAALgAECgIJAQAAAA==.',
['死大']='死大师:BAAALgAECgEJAQAAAA==.',
['死骑']='死骑友友:BAAALgAFFAIJBAAAAA==.死骑士:BAAALgAECgEJAQAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8IAAINAAQJ+SC3BQCJAQANAAQJ+SC3BQCJAQABLgAFFAUJKgANAP8kAA==.',
['水煮']='水煮乌鱼片:BAABLgAFFH8IAAIIAAQJ+hVjCQBTAQAIAAQJ+hVjCQBTAQAAAA==.',
['永恒']='永恒嗲鸡哥:BAAALgAECgQJBAAAAA==.',
['江洋']='江洋小盗:BAAALgAECgEJAQAAAA==.',
['没有']='没有说:BAABLgAFFH8YAAMGAAYJwBVrAQCuAQAGAAYJwBVrAQCuAQAHAAEJAAA1GwAvAAAAAA==.没有黑眼圈:BAAALgAECgEJAgAAAA==.',
['油泼']='油泼辣子:BAAALgADCgEJAQAAAA==.',
['浅浅']='浅浅初荷嵐:BAAALgAECgUJCwAAAA==.',
['清欢']='清欢:BAAALgAFFAQJBAAAAA==.',
['火球']='火球火球:BAAALgAECgYJDQAAAA==.火球的圣骑:BAAALgAECgQJBQAAAA==.',
['灬丫']='灬丫丫灬:BAAALgAECgUJBQAAAA==.',
['灬娜']='灬娜娜酱灬:BAABLgAECn8kAAIOAAgJGB49JACXAgAOAAgJGB49JACXAgAAAA==.',
['灬我']='灬我是传奇:BAAALgAECgMJBAAAAA==.',
['熊堡']='熊堡包:BAAALgAECgQJBAAAAA==.',
['熊小']='熊小炳:BAAALgAECgYJCAAAAA==.',
['熊抓']='熊抓鱼么:BAAALgAECgEJAwABLgAFFAYJBAAFAAAAAA==.',
['熊灬']='熊灬爸:BAAALgAECgYJBwAAAA==.',
['爽脆']='爽脆牛肉丝:BAAALgAFFAIJAwAAAA==.',
['牛皮']='牛皮糖:BAAALgAECgkJCQAAAA==.',
['牧古']='牧古尘终:BAAALgADCgQJBAAAAA==.',
['特色']='特色吊肝肉:BAAALgAFFAUJAQAAAA==.',
['狂奔']='狂奔的戰牛:BAAALgAFFAEJAQAAAA==.',
['玖丶']='玖丶伍:BAAALgADCgEJAQAAAA==.',
['瑶一']='瑶一丶:BAABLgAFFH8IAAIEAAUJGhDDHgBOAQAEAAUJGhDDHgBOAQAAAA==.',
['男人']='男人猫:BAAALgAECgMJCQAAAA==.',
['疫刃']='疫刃碎罪枷:BAAALgADCgMJAwAAAA==.',
['白桃']='白桃酸奶:BAABLgAECn8pAAMPAAkJTyLAAAD8AgAPAAkJTyLAAAD8AgANAAQJxhLeNQD2AAAAAA==.',
['白牛']='白牛猎魂:BAAALgAECgMJBAAAAA==.白牛裂魂:BAAALgAFFAEJAQAAAA==.',
['百变']='百变星君:BAAALgAECgYJCgAAAA==.百变熊孩子:BAAALgAECgEJAQAAAA==.',
['百田']='百田光希:BAAALgAECgMJAwAAAA==.',
['皓月']='皓月下的玫瑰:BAAALgAFFAEJAQAAAA==.',
['目标']='目标未选中:BAAALgADCgMJAwAAAA==.',
['石头']='石头人萨满:BAAALgADCgMJAwAAAA==.',
['砍人']='砍人的人:BAAALgAECgYJCQAAAA==.',
['神偷']='神偷小颂可:BAACLgAFFH8JAAIQAAMJCh25AAAaAQAQAAMJCh25AAAaAQAuAAQKfx0AAhAACAl/IpcBALkCABAACAl/IpcBALkCAAAA.',
['神帝']='神帝:BAAALgAFFAEJAQABLgAFFAYJBAAFAAAAAA==.',
['神龙']='神龙:BAAALgAFFAIJAgAAAA==.神龙术:BAAALgAFFAEJAgAAAA==.',
['秋天']='秋天色糖果:BAAALgAECgYJBwAAAA==.',
['穹顶']='穹顶的色彩:BAAALgAECgkJCQAAAA==.',
['箭走']='箭走偏疯:BAAALgAECgMJBAAAAA==.',
['米开']='米开朗基罗:BAAALgAECgEJAQAAAA==.',
['米斯']='米斯塔奎恩:BAAALgAFFAEJAQAAAA==.',
['粉粉']='粉粉的烧饼:BAAALgAECggJCAAAAA==.',
['粉红']='粉红吹风机:BAAALgAFFAMJBAAAAA==.',
['精彩']='精彩必将继续:BAAALgAFFAEJAgAAAA==.',
['索大']='索大师:BAAALgAFFAIJBAAAAA==.',
['索西']='索西娅红莲:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色記憶:BAAALgAFFAIJAwAAAA==.',
['繁华']='繁华落尽:BAAALgAECgEJAQAAAA==.',
['细雨']='细雨:BAAALgADCgIJAgAAAA==.',
['给个']='给个盾就上:BAAALgAECgYJBgAAAA==.',
['罗小']='罗小圣:BAAALgAECggJDgAAAA==.',
['股伊']='股伊耳:BAAALgAECgYJBgAAAA==.',
['肥肠']='肥肠侠:BAAALgAFFAIJBAAAAA==.',
['胡飞']='胡飞非:BAAALgAFFAEJAQAAAA==.',
['胸小']='胸小别哔哔:BAAALgAECgYJCQAAAA==.',
['舒逸']='舒逸:BAAALgAECgQJBAAAAA==.',
['花事']='花事了丶:BAAALgAECgYJDQAAAA==.',
['花瓶']='花瓶与荣:BAAALgADCgYJBgAAAA==.',
['花鸡']='花鸡:BAAALgAECgEJAQAAAA==.',
['芸豆']='芸豆豆:BAAALgAECgYJBgAAAA==.',
['苍色']='苍色咖啡:BAAALgAECgQJBAAAAA==.',
['苦菜']='苦菜干巴炒饭:BAAALgAFFAQJBAAAAA==.',
['茶白']='茶白:BAAALgAECgEJAQAAAA==.',
['草莓']='草莓圣代:BAAALgAECgcJBwAAAA==.',
['荒岛']='荒岛遗尸:BAAALgAECgIJAwAAAA==.',
['莳绱']='莳绱的調調:BAAALgAECgUJBQAAAA==.',
['菀菀']='菀菀类卿:BAABLgAECn8bAAMRAAkJISC8BABWAwARAAkJISC8BABWAwASAAYJkxlkPACyAQAAAA==.',
['萌乄']='萌乄哒哒的牛:BAAALgAECgYJBgAAAA==.',
['萧丙']='萧丙熙:BAAALgADCgQJBgAAAA==.',
['落日']='落日:BAAALgAFFAIJBAAAAA==.',
['蓝调']='蓝调沙锤:BAAALgAECgYJCgAAAA==.',
['蕾蕾']='蕾蕾是太阳:BAABLgAFFH8HAAIEAAQJbgwuDwA9AQAEAAQJbgwuDwA9AQAAAA==.',
['薛之']='薛之谦:BAAALgAECgEJAQABLgAECgcJCQAFAAAAAA==.',
['薛怀']='薛怀义:BAAALgAECgIJAgAAAA==.',
['蛮扎']='蛮扎实:BAAALgAECgEJAQAAAA==.',
['蜜桃']='蜜桃果酱丶:BAAALgAECgUJBQAAAA==.',
['血之']='血之梦梦:BAAALgAECgEJAQAAAA==.',
['血戦']='血戦非我愿:BAAALgADCgcJDAAAAA==.',
['血翼']='血翼魅影:BAAALgAECgYJBwAAAA==.',
['褪色']='褪色者:BAAALgAECggJEAAAAA==.',
['西宫']='西宫雪儿丶:BAAALgAFFAEJAQAAAA==.',
['请叫']='请叫高植物:BAAALgAECgMJBgAAAA==.',
['貂蝉']='貂蝉在我腰上:BAAALgAFFAIJBAAAAA==.',
['贪狼']='贪狼廉贞:BAAALgADCgEJAQAAAA==.',
['走慢']='走慢点:BAABLgAFFH8FAAIEAAIJ3BtgNQDBAAAEAAIJ3BtgNQDBAAAAAA==.',
['转角']='转角遇见眷:BAAALgAECgEJAwAAAA==.',
['辛德']='辛德维拉:BAAALgAECgYJBgAAAA==.',
['辣条']='辣条配红酒:BAAALgAECgcJCAAAAA==.',
['过来']='过来叔叔抱抱:BAAALgADCgIJAgAAAA==.',
['迪凯']='迪凯:BAAALgAECgYJBAAAAA==.',
['迷途']='迷途小浣熊:BAAALgAECgYJBgAAAA==.',
['逸泽']='逸泽:BAAALgAECgYJDQAAAA==.',
['遗忘']='遗忘的忧伤:BAAALgAFFAEJAQABLgAFFAMJBwATAC8PAA==.遗忘的悲伤:BAABLgAECn8WAAMGAAYJ4xZOfwCEAQAGAAYJ4xZOfwCEAQAHAAUJqQm4LgDKAAABLgAFFAMJBwATAC8PAA==.遗忘的童年:BAABLgAFFH8HAAMTAAMJLw9hDgCaAAATAAMJLw9hDgCaAAAUAAEJSwPCEwBBAAAAAA==.',
['邪恶']='邪恶精哥:BAAALgAECgUJBQAAAA==.',
['酷酷']='酷酷的小骑士:BAAALgAECgEJAQAAAA==.',
['里尔']='里尔哦:BAAALgAFFAEJAgAAAA==.',
['鉄甲']='鉄甲依然在:BAAALgAECgQJBgAAAA==.',
['销锋']='销锋镝:BAAALgAECgIJAgABLgAECgYJCAAFAAAAAA==.',
['闪电']='闪电帕丁熊:BAAALgAFFAQJBAAAAA==.',
['阿克']='阿克斯通:BAAALgAFFAIJAgAAAA==.',
['陌路']='陌路丿相逢丶:BAAALgAECgcJDgAAAA==.',
['隆恩']='隆恩丶血蹄:BAAALgAECgUJCQAAAA==.',
['雨瞳']='雨瞳:BAAALgAECgMJAQAAAA==.',
['雪莲']='雪莲:BAAALgAECgQJBAAAAA==.',
['雷电']='雷电法皇永信:BAACLgAFFH8VAAITAAYJgyUQAACcAgATAAYJgyUQAACcAgAuAAQKfyMAAhMACQl7Ji8AAN8DABMACQl7Ji8AAN8DAAAA.',
['青桔']='青桔柠檬:BAAALgADCgMJAwAAAA==.',
['青莲']='青莲:BAAALgAECgYJBgAAAA==.',
['静静']='静静说的对:BAABLgAFFH8JAAIGAAUJpwueCgB9AQAGAAUJpwueCgB9AQAAAA==.',
['颂可']='颂可武道家:BAAALgAECgYJBgAAAA==.',
['风筝']='风筝:BAAALgAECgkJBQAAAA==.',
['风雨']='风雨行者:BAAALgAECgQJBQAAAA==.',
['飘零']='飘零灬落叶:BAAALgAECgEJAQAAAA==.',
['骄阳']='骄阳下的玫瑰:BAAALgAECgIJAgAAAA==.',
['高端']='高端洗碗工:BAAALgAECgQJBAAAAA==.',
['鱼肠']='鱼肠法:BAAALgAECgQJBAAAAA==.',
['麦子']='麦子不死:BAAALgADCgEJAQAAAA==.',
['麻辣']='麻辣牛肉米线:BAAALgAECgcJBwAAAA==.麻辣鸡斯:BAAALgAECgUJBQAAAA==.',
['黑厄']='黑厄:BAAALgAECggJAgAAAA==.',
['黯嘚']='黯嘚识邓:BAAALgAECgEJAQAAAA==.',
['龍七']='龍七:BAAALgADCgYJBgAAAA==.',
['龙御']='龙御风行者:BAAALgAECgEJAQAAAA==.',
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
