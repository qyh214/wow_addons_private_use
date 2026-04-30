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

local lookup = {'Mage-Frost','DemonHunter-Devourer','Unknown-Unknown','Evoker-Augmentation','Evoker-Preservation','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Survival','Shaman-Restoration','Paladin-Retribution','Monk-Brewmaster','Warlock-Demonology','Warlock-Destruction',}
local provider = {region='CN',realm='达隆米尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aj='Aj:BAAALgAECgYJCwAAAA==.',
Cx='Cxssd:BAAALgAECggJDgAAAA==.',
Da='Darkmamba:BAAALgAECgEJAQAAAA==.',
El='Elysia:BAAALgADCgEJAQAAAA==.',
Ev='Ever:BAAALgADCgMJAwAAAA==.',
Fu='Fusietwo:BAAALgAECgEJAQAAAA==.',
Gy='Gyoku:BAAALgAECgcJCQAAAA==.',
Ic='Icee:BAABLgAFFH8HAAIBAAUJlRHUDQCsAQABAAUJlRHUDQCsAQAAAA==.',
Ii='Iice:BAAALgAECgIJAwAAAA==.Iicee:BAAALgAECgIJAgABLgAFFAYJBgACABsdAA==.',
Im='Imàgo:BAAALgAFFAUJBAABLgAFFAcJAQADAAAAAA==.',
Je='Jeannelapuce:BAAALgAECgEJAQAAAA==.',
Le='Leiyiwei:BAAALgADCgEJAQAAAA==.',
My='Mylove:BAAALgAECgEJAQAAAA==.',
Pi='Pill:BAACLgAFFH8LAAIEAAQJURZ3CwBCAQAEAAQJURZ3CwBCAQAuAAQKfyAAAwQACQnoHKQMAKsCAAQACQnoHKQMAKsCAAUAAQlVEFBIADMAAAAA.',
Rh='Rhythmic:BAAALgAFFAEJAQABLgAFFAUJBQABAA0cAA==.',
So='Sorcererfs:BAAALgAECgEJAQAAAA==.',
Sr='Sraahwayne:BAAALgAECgUJBQAAAA==.',
['一只']='一只宠物猫:BAAALgAECgMJAwAAAA==.',
['一碗']='一碗四百:BAAALgAECgYJBwAAAA==.',
['下一']='下一战巨星:BAAALgAECgQJBAAAAA==.',
['不会']='不会插棍棍:BAAALgAECgYJCwAAAA==.',
['丨月']='丨月夜丨:BAAALgAECgEJAQAAAA==.',
['丨沛']='丨沛艾丨:BAAALgAECgcJDgAAAA==.',
['中单']='中单地缚灵丶:BAAALgAECgEJAQAAAA==.',
['主力']='主力队员:BAAALgAECgQJBAAAAA==.',
['丿钱']='丿钱多多灬:BAAALgAECgUJCAAAAA==.',
['乖乖']='乖乖小公主:BAAALgAECgEJAQAAAA==.',
['伊利']='伊利亚坎:BAAALgAECgcJCQAAAA==.',
['伊西']='伊西斯:BAAALgAECgcJBAAAAA==.',
['估算']='估算师:BAABLgAECn8cAAIBAAgJBxUQFwCtAQABAAgJBxUQFwCtAQAAAA==.',
['你们']='你们冲我掩护:BAAALgAECgQJBAAAAA==.',
['元述']='元述:BAAALgAECgcJDwAAAA==.',
['兎笓']='兎笓:BAAALgAECgcJDwAAAA==.',
['冲锋']='冲锋果实:BAAALgAECgYJDAAAAA==.',
['刘瑾']='刘瑾优:BAAALgAECgcJCAAAAA==.',
['到处']='到处插:BAAALgAECgEJAQAAAA==.',
['北挽']='北挽:BAABLgAFFH8KAAIGAAQJ9hrRDgBnAQAGAAQJ9hrRDgBnAQAAAA==.',
['北欧']='北欧王座:BAAALgAECgEJAQAAAA==.',
['十個']='十個人上悠亚:BAAALgADCgYJBQAAAA==.',
['十步']='十步插一人:BAAALgAECgYJCAAAAA==.十步杀壹人:BAAALgAECgUJDwAAAA==.',
['千寒']='千寒:BAAALgAECgcJDwAAAA==.',
['单车']='单车:BAAALgAECgEJAgAAAA==.',
['南瓜']='南瓜豆豆:BAAALgAECgcJCgAAAA==.',
['变心']='变心:BAAALgAECgMJAwAAAA==.',
['只会']='只会追着怪揍:BAAALgAECggJDgAAAA==.',
['叶问']='叶问:BAAALgAECgEJAQABLgAECgEJAgADAAAAAA==.',
['吃糖']='吃糖吃红嘛:BAAALgAFFAQJBAAAAA==.',
['合波']='合波:BAAALgAECgMJAwAAAA==.',
['吟游']='吟游诗四驴:BAAALgADCgUJBQAAAA==.',
['听风']='听风吹雨落:BAAALgAECggJEQAAAA==.',
['告死']='告死鸟:BAAALgADCgEJAQAAAA==.',
['咖啡']='咖啡苦酒:BAAALgADCgEJAQAAAA==.',
['咸恩']='咸恩静:BAAALgAFFAEJAQAAAA==.',
['哭孑']='哭孑誰疼:BAAALgAECgMJAwAAAA==.',
['喵勒']='喵勒个萌:BAAALgAECgMJBgAAAA==.',
['嘉士']='嘉士伯爵:BAAALgADCgIJAgAAAA==.',
['噬心']='噬心隐为者:BAACLgAFFH8IAAMHAAMJJBezCgAMAQAHAAMJkBazCgAMAQAIAAEJohI5BgBZAAAuAAQKfxoAAwcACAkAIYwbAGECAAcACAn2IIwbAGECAAgABgnAGqYQALgBAAAA.',
['噬魂']='噬魂果实:BAAALgAECgYJBwAAAA==.',
['国法']='国法:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光之羽:BAAALgAECgQJAwAAAA==.圣光之雨:BAAALgAECgMJAwAAAA==.',
['圣灬']='圣灬言:BAAALgAECgMJBQAAAA==.',
['大威']='大威天龙:BAAALgADCgcJDAAAAA==.',
['天锁']='天锁斩月丶:BAAALgAECgYJBwAAAA==.',
['天黑']='天黑不点灯:BAAALgAECgEJAQAAAA==.',
['头铁']='头铁的法爷:BAAALgAECgIJAgAAAA==.',
['奶王']='奶王:BAACLgAFFH8GAAIJAAMJ8w1XCwDLAAAJAAMJ8w1XCwDLAAAuAAQKfxQAAgkABwmWFhg6AJkBAAkABwmWFhg6AJkBAAAA.',
['好无']='好无才:BAAALgADCgYJBgAAAA==.',
['娜舞']='娜舞丝嘉:BAABLgAECn8aAAIKAAgJzhuhJQCQAgAKAAgJzhuhJQCQAgAAAA==.',
['娶灬']='娶灬紅太狼:BAAALgAECgEJAwAAAA==.',
['孤独']='孤独狼狼:BAAALgAECgEJAQAAAA==.',
['学长']='学长不凶:BAAALgAFFAIJAgAAAA==.',
['安眸']='安眸:BAAALgAECgYJBgAAAA==.',
['射到']='射到你腿软:BAAALgAECgMJAwAAAA==.',
['小光']='小光明:BAAALgADCgEJAgAAAA==.',
['小满']='小满胜万全:BAAALgAECgQJBgAAAA==.',
['小激']='小激凌:BAAALgADCgEJAQAAAA==.',
['小狐']='小狐天:BAAALgADCgEJAQAAAA==.',
['小狼']='小狼天丶:BAAALgADCgEJAQAAAA==.',
['小白']='小白快跑:BAAALgAECgEJAQAAAA==.',
['尛鰕']='尛鰕:BAAALgAECgIJAwAAAA==.',
['尤迪']='尤迪安:BAAALgAECgkJCQAAAA==.',
['幻月']='幻月惜风:BAAALgADCgkJDgAAAA==.',
['往昔']='往昔之夕:BAAALgAECgkJCwAAAA==.',
['德神']='德神:BAAALgAFFAIJBAAAAA==.',
['心宽']='心宽体更胖:BAABLgAFFH8HAAILAAQJwgk2DwAJAQALAAQJwgk2DwAJAQAAAA==.',
['忧郁']='忧郁的小白:BAAALgADCgcJDgAAAA==.',
['惑世']='惑世巫民:BAAALgADCgEJAQAAAA==.',
['我听']='我听风之语:BAAALgAECgMJBQAAAA==.',
['我是']='我是一头牛:BAAALgADCgEJAQABLgADCgEJAQADAAAAAA==.',
['拉布']='拉布布嘟嘟:BAABLgAECn8UAAIBAAgJlh4sMACyAgABAAgJlh4sMACyAgAAAA==.',
['拼命']='拼命装傻:BAAALgADCgEJAQAAAA==.',
['摩尔']='摩尔迦娜:BAAALgAECgEJAQAAAA==.',
['文秀']='文秀:BAAALgAECgEJAQAAAA==.',
['斋藤']='斋藤千和:BAAALgAECgcJBQAAAA==.',
['施丹']='施丹:BAAALgAECgUJBQAAAA==.',
['无所']='无所谓去:BAAALgAECgQJBAAAAA==.',
['星蓝']='星蓝石:BAAALgADCgMJAwAAAA==.',
['星雨']='星雨森林:BAAALgAECgYJBgAAAA==.',
['景中']='景中水月:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜一舞:BAAALgAECgEJAQAAAA==.',
['月夜']='月夜猎刃:BAAALgAECgEJAQAAAA==.',
['李居']='李居丽:BAAALgAFFAEJAQAAAA==.',
['林夕']='林夕魅儿:BAAALgAFFAEJAQAAAA==.林夕龙二:BAAALgAECgYJBgAAAA==.',
['柚子']='柚子好吃吗:BAABLgAFFH8PAAIJAAUJFiAPAQABAgAJAAUJFiAPAQABAgAAAA==.',
['森林']='森林中的美女:BAAALgAECgcJDAAAAA==.',
['椰子']='椰子芒果冰:BAAALgAECgYJCQAAAA==.',
['橡果']='橡果果:BAAALgAECgYJBAAAAA==.',
['正方']='正方形铁板:BAAALgAECgcJDQAAAA==.',
['武艺']='武艺:BAAALgAECgMJAwAAAA==.',
['死而']='死而复生:BAAALgAECgYJDQAAAA==.',
['油炸']='油炸酒鬼花生:BAAALgAECgcJDgAAAA==.',
['流浪']='流浪的汉子:BAAALgAECgYJCQAAAA==.',
['浙大']='浙大毕业忒香:BAAALgAECgIJAgAAAA==.',
['浪浪']='浪浪碗:BAAALgAECgEJAQAAAA==.',
['浮华']='浮华落尽似梦:BAAALgAECgYJBgAAAA==.',
['深夜']='深夜的狂欢:BAAALgAECgQJBwAAAA==.',
['滴尅']='滴尅很强吗:BAACLgAFFH8HAAIGAAMJVA6qKwDsAAAGAAMJVA6qKwDsAAAuAAQKfyUAAgYACAlGJJoBANgCAAYACAlGJJoBANgCAAAA.',
['潄石']='潄石:BAAALgAFFAEJAQAAAA==.',
['火烷']='火烷:BAAALgAFFAQJBAAAAA==.',
['灬囵']='灬囵:BAAALgAECgEJAQAAAA==.',
['灭炎']='灭炎:BAAALgAECgcJDgAAAA==.',
['灵韵']='灵韵之风:BAAALgAECgcJCQAAAA==.',
['炽热']='炽热的骨头:BAAALgAECgEJAQAAAA==.',
['爆打']='爆打红烧肉:BAAALgAECgcJDgAAAA==.',
['爱我']='爱我家小月了:BAAALgAECgYJCwAAAA==.',
['狄塞']='狄塞拉:BAAALgAFFAEJAQAAAA==.',
['王语']='王语嫣:BAAALgAECgEJAgAAAA==.',
['玩不']='玩不了一点:BAAALgAECgcJBgABLgAFFAUJBQACAN8aAA==.',
['瓦转']='瓦转魔兽丶:BAAALgADCgcJBwABLgAFFAMJBwAGAFQOAA==.',
['皇后']='皇后杀手:BAAALgADCgYJBgAAAA==.',
['直视']='直视我的眼睛:BAAALgAECgMJBwAAAA==.',
['看你']='看你妹的人:BAAALgADCgQJBQAAAA==.',
['眼看']='眼看喜:BAAALgAFFAIJAwAAAA==.',
['矮佬']='矮佬明:BAAALgAECgYJBgAAAA==.',
['神王']='神王德:BAAALgADCgYJBgAAAA==.神王萨:BAAALgAFFAMJAwAAAA==.',
['福心']='福心杰:BAAALgADCgIJAgAAAA==.',
['科妮']='科妮:BAAALgAFFAIJAwAAAA==.',
['空空']='空空如也:BAAALgAECggJDgAAAA==.',
['米玛']='米玛扎西西:BAAALgADCgIJAgAAAA==.',
['米饭']='米饭夹馍:BAAALgADCgMJAwAAAA==.',
['素笺']='素笺流年:BAAALgAFFAQJAQAAAA==.',
['紫灵']='紫灵:BAAALgAECgEJAQABLgAECgEJAgADAAAAAA==.',
['红浪']='红浪漫:BAAALgAECgIJAgAAAA==.',
['绝对']='绝对碎裂:BAACLgAFFH8LAAIMAAQJ+xCiCwA0AQAMAAQJ+xCiCwA0AQAuAAQKfxgAAwwACQnaFjYbALECAAwACQlEFTYbALECAA0AAwmaC9hRAHgAAAAA.',
['维斯']='维斯珀丶夜陨:BAAALgADCgEJAQAAAA==.',
['美女']='美女一抬腿就:BAAALgAECgYJCAAAAA==.美女姐姐:BAAALgAECgEJAQAAAA==.',
['美如']='美如的德:BAAALgAECgMJAwAAAA==.',
['老友']='老友鬼鬼:BAAALgAECgQJBAAAAA==.',
['耶萌']='耶萌迦徳:BAAALgADCgYJBgAAAA==.',
['苍穹']='苍穹一刀丶:BAAALgAFFAEJAQAAAA==.',
['莫辛']='莫辛纳甘:BAAALgADCgUJBQAAAA==.',
['萨拉']='萨拉塔小跟班:BAAALgAECgYJCAAAAA==.',
['萨满']='萨满德猎:BAAALgAECgcJBAAAAA==.',
['萨爹']='萨爹:BAAALgAECgEJAQABLgAECgEJAgADAAAAAA==.',
['血舞']='血舞者:BAAALgAECgcJBgAAAA==.',
['衲鲁']='衲鲁之赐:BAAALgAECgcJBwAAAA==.',
['诺基']='诺基亚:BAAALgAECgEJAQAAAA==.',
['赖着']='赖着不死:BAAALgAECgQJBwAAAA==.',
['赤焰']='赤焰:BAAALgAFFAEJAQAAAA==.',
['远征']='远征的将军:BAAALgAECggJCAAAAA==.',
['通哔']='通哔归来了:BAAALgADCgEJAQAAAA==.',
['逸笑']='逸笑奈何:BAAALgAECgUJBwAAAA==.',
['醉里']='醉里贪欢笑:BAAALgAFFAEJAQAAAA==.',
['钱丶']='钱丶多多:BAAALgAECgQJBAAAAA==.',
['锵锵']='锵锵将:BAAALgADCgcJBwAAAA==.',
['长桑']='长桑玉阳子:BAAALgAECgQJBAAAAA==.',
['阿吉']='阿吉:BAAALgAFFAEJAQAAAA==.',
['阿赞']='阿赞:BAAALgAFFAIJAwAAAA==.',
['随风']='随风漂流:BAAALgAECgQJBwAAAA==.',
['隐秘']='隐秘果实:BAAALgADCgIJAgAAAA==.',
['雨落']='雨落凡尘:BAAALgADCgMJAwAAAA==.',
['雨霁']='雨霁:BAABLgAFFH8IAAIEAAUJEA1CBgBAAQAEAAUJEA1CBgBAAQAAAA==.',
['霏绪']='霏绪:BAAALgAECgkJDAAAAA==.',
['靈魂']='靈魂歸宿:BAAALgADCgUJBQAAAA==.',
['非常']='非常迷幻:BAAALgAECgEJAQAAAA==.',
['颛顼']='颛顼:BAAALgAECgYJBwAAAA==.',
['风之']='风之利刃:BAAALgADCgQJBAAAAA==.',
['风神']='风神摇曳灬:BAAALgAECgEJAQAAAA==.',
['风般']='风般的美男子:BAAALgAECgUJBQAAAA==.',
['风语']='风语燕归来:BAAALgAFFAIJAwAAAA==.',
['风阁']='风阁:BAAALgADCgEJAQAAAA==.',
['首席']='首席法渣:BAAALgAECgkJCwAAAA==.',
['骑了']='骑了个怪:BAAALgAECgEJAQAAAA==.',
['骑士']='骑士可乐:BAAALgAECgMJAwAAAA==.',
['骑空']='骑空士:BAAALgADCgQJBAAAAA==.',
['鲲鹏']='鲲鹏:BAAALgAECgQJBAAAAA==.',
['鳞韵']='鳞韵之风:BAAALgAECgYJBgABLgAECgcJCQADAAAAAA==.',
['鵺雨']='鵺雨潇湘:BAAALgAECgYJBgAAAA==.',
['龙枯']='龙枯冥:BAAALgADCgEJAQAAAA==.',
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
