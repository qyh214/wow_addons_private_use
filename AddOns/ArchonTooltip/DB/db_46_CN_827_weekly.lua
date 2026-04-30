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

local lookup = {'Shaman-Restoration','Shaman-Elemental','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Arms','Warrior-Fury','Mage-Frost','Mage-Arcane','Mage-Fire','Paladin-Holy','Priest-Discipline','Rogue-Subtlety','Rogue-Assassination','Monk-Mistweaver','Monk-Windwalker','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Unknown-Unknown','DemonHunter-Havoc','Hunter-BeastMastery','Priest-Holy','Druid-Restoration','Priest-Shadow','Paladin-Protection','Paladin-Retribution',}
local provider = {region='CN',realm='血顶',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Asddsf:BAAALgAECgYJCgAAAA==.',
Bl='Blueboy:BAAALgAECgUJBgAAAA==.',
Ca='Catherine:BAAALgAECgIJAgAAAA==.',
Da='Darkgabriel:BAAALgAECgYJBgAAAA==.',
De='Desolationz:BAAALgAECgYJCAAAAA==.',
Fa='Fadnexus:BAAALgAECgQJBwAAAA==.',
Ga='Gakki:BAAALgAECgcJCAAAAA==.',
Pa='Panicc:BAAALgAFFAEJAgAAAA==.Panicn:BAAALgAECgEJAQAAAA==.',
Pl='Playerdgcwvx:BAAALgAFFAMJAwAAAA==.',
Re='Realhjs:BAABLgAFFH8FAAMBAAQJCxZmIQBLAAABAAEJKhZmIQBLAAACAAQJwgEAAAAAAAAAAA==.Redmi:BAAALgAECgYJBwAAAA==.',
Sc='Scorching:BAABLgAECn8YAAMDAAYJqxjeIgCnAQADAAYJqxjeIgCnAQAEAAYJzg85HgA9AQAAAA==.',
So='Solitaire:BAAALgAECgUJBgAAAA==.',
Sq='Sqs:BAAALgAECgEJAQAAAA==.',
Xi='Xingyugege:BAAALgAECgUJBQAAAA==.',
['一个']='一个也不能少:BAAALgADCgcJBwAAAA==.',
['一介']='一介行李:BAAALgAECgYJCwAAAA==.',
['一猫']='一猫一狗:BAAALgAFFAIJAgAAAA==.',
['七月']='七月诞:BAAALgADCgEJAQAAAA==.',
['三个']='三个调料罐:BAAALgAECgYJCgAAAA==.',
['不是']='不是很熟:BAAALgADCgIJAgAAAA==.',
['不睡']='不睡觉的人:BAAALgAECgEJAwAAAA==.',
['丨芙']='丨芙宁娜丨:BAAALgAECgQJBgAAAA==.',
['中级']='中级经济尸:BAABLgAECn8ZAAMFAAkJXRzsFQD4AgAFAAkJXRzsFQD4AgAGAAkJIhdcDABLAgABLgAFFAUJCQAFAGomAA==.',
['丰少']='丰少:BAAALgADCgIJAgAAAA==.',
['丶冷']='丶冷落的小羊:BAABLgAFFH8PAAMHAAYJQxhWAADJAQAHAAYJQBVWAADJAQAIAAQJGxXFCQBZAQAAAA==.',
['丶憨']='丶憨森森:BAAALgAFFAEJAQAAAA==.',
['丶时']='丶时之砂:BAACLgAFFH8LAAIJAAQJiiBpEAAxAQAJAAQJiiBpEAAxAQAuAAQKfyEABAkACQleHFMaAA4DAAkACQleHFMaAA4DAAoAAQluICwXAGEAAAsAAQm0EKAOAEAAAAAA.丶时之砂丶:BAAALgAECgEJAQABLgAFFAQJCwAJAIogAA==.',
['云想']='云想衣裳:BAAALgAECggJEAAAAA==.',
['什么']='什么:BAAALgAECgEJAQAAAA==.',
['众爱']='众爱卿平身:BAAALgAECgYJCgAAAA==.',
['低矮']='低矮星吞噬者:BAAALgADCgUJBQAAAA==.',
['你缺']='你缺不缺德:BAAALgAECgEJAgAAAA==.',
['依托']='依托考昔:BAAALgAECgIJAgAAAA==.',
['依旧']='依旧法神:BAAALgAECgIJAgAAAA==.',
['修一']='修一:BAAALgAECgcJEgAAAA==.',
['修三']='修三:BAAALgAECgkJEwAAAA==.',
['修二']='修二:BAABLgAECn8XAAIMAAkJfSJCAQB3AwAMAAkJfSJCAQB3AwAAAA==.',
['修五']='修五:BAAALgAFFAQJBAAAAA==.',
['修六']='修六:BAAALgAECgcJBwAAAA==.',
['修十']='修十四:BAAALgAECgcJBwAAAA==.',
['修四']='修四:BAAALgAECgYJDAAAAA==.',
['傻蔓']='傻蔓:BAAALgAECgEJAQAAAA==.',
['全天']='全天光光:BAAALgADCgEJAQAAAA==.',
['冄霜']='冄霜:BAAALgAECgEJAQAAAA==.',
['冥十']='冥十三:BAAALgAFFAEJAQABLgAECgkJGAANAFUfAA==.',
['冷凝']='冷凝馨月:BAABLgAECn8UAAIGAAkJax1/BAACAwAGAAkJax1/BAACAwAAAA==.',
['冻柠']='冻柠茶少糖:BAAALgAECgQJBQAAAA==.',
['凯尔']='凯尔赛斯:BAAALgAECgUJBQAAAA==.',
['划水']='划水的烤鸭:BAAALgAECgYJCwAAAA==.',
['别问']='别问问就是稳:BAAALgADCgEJAQAAAA==.',
['勇敢']='勇敢牛牛:BAAALgADCgYJBgAAAA==.',
['勒古']='勒古拉斯:BAAALgADCgEJAQAAAA==.',
['十三']='十三阔少:BAAALgAECgYJCAABLgAECgkJGAANAFUfAA==.',
['千夜']='千夜丶:BAABLgAECn8bAAMOAAkJzBveCwDYAgAOAAgJWBzeCwDYAgAPAAEJ+RfrGwBIAAAAAA==.',
['原教']='原教学楼:BAAALgAECgYJBAAAAA==.',
['只是']='只是杀你:BAAALgAECgUJBQAAAA==.',
['叶问']='叶问风中转:BAAALgADCgkJCQAAAA==.',
['吃醋']='吃醋的胡萝卜:BAAALgAECgkJCAAAAA==.',
['名字']='名字就是嘲讽:BAAALgADCgIJAgAAAA==.',
['听雪']='听雪吟风:BAAALgAFFAIJAwAAAA==.',
['喵十']='喵十七:BAAALgAECgMJAwAAAA==.',
['喷射']='喷射式飞机:BAAALgADCgMJAwAAAA==.',
['回首']='回首已漠然:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光之辉:BAABLgAFFH8MAAIMAAQJVBW8BABHAQAMAAQJVBW8BABHAQAAAA==.圣光的烤鸭:BAAALgAECgYJBgAAAA==.',
['圣钥']='圣钥:BAAALgAECgYJBgAAAA==.',
['夕丶']='夕丶四夫人:BAAALgAECgcJCwAAAA==.',
['夕夕']='夕夕四:BAAALgAECgEJAQAAAA==.',
['夜丶']='夜丶以烽:BAABLgAECn8cAAMQAAkJPB8wBAAtAwAQAAkJPB8wBAAtAwARAAEJUBd0dABDAAABLgAECgkJGAANAFUfAA==.',
['夜袭']='夜袭尼姑庵:BAAALgADCgEJAQAAAA==.',
['大蛋']='大蛋豪:BAAALgAECgYJBgAAAA==.',
['天命']='天命丶之资:BAAALgAECgIJAwAAAA==.',
['天堂']='天堂:BAAALgAECgYJDwAAAA==.',
['奶茶']='奶茶表:BAAALgAECgEJAQAAAA==.',
['婉儿']='婉儿丶:BAAALgAECgUJCAABLgAECgkJGAANAFUfAA==.',
['嫣飞']='嫣飞凤舞:BAAALgAECgQJBQAAAA==.',
['安静']='安静的跳跳僧:BAAALgAFFAEJAgAAAA==.',
['寂寞']='寂寞的我们:BAAALgAECgUJBwAAAA==.',
['小僧']='小僧了僧:BAAALgAECgQJBAAAAA==.',
['小叮']='小叮松比:BAABLgAECn8bAAQSAAkJURcnXgCuAQASAAYJwRYnXgCuAQATAAMJWxUtOQDQAAAUAAEJAADKJgBWAAAAAA==.',
['小德']='小德了德:BAAALgAECgcJCAAAAA==.',
['小猎']='小猎了猎:BAAALgAECgQJBAAAAA==.',
['小萨']='小萨了萨:BAAALgAECgUJBgAAAA==.',
['小蝌']='小蝌蚪长大了:BAAALgAECgcJDAAAAA==.',
['小魔']='小魔了魔:BAAALgAECgcJDQAAAA==.',
['尛猎']='尛猎:BAAALgAECgQJBQAAAA==.',
['尛骑']='尛骑:BAAALgAECgIJAgAAAA==.',
['就是']='就是拉不住:BAAALgAECgYJDQAAAA==.',
['岁寒']='岁寒:BAABLgAECn8ZAAIJAAcJOBeQMQAsAQAJAAcJOBeQMQAsAQAAAA==.',
['帅德']='帅德一皮:BAAALgAECgUJBwAAAA==.',
['帝王']='帝王神话:BAAALgAECgEJAQAAAA==.',
['应许']='应许之祈:BAAALgAECgUJBQAAAA==.',
['式波']='式波飛鳥:BAAALgADCgMJAwAAAA==.',
['彼岸']='彼岸幽茗:BAAALgAECgkJBgABLgAFFAYJEwATAGMRAA==.',
['心成']='心成雪:BAAALgAECgUJBQAAAA==.',
['愛丨']='愛丨流逝:BAAALgADCgIJAgAAAA==.',
['懂哥']='懂哥儿:BAAALgAECggJCQAAAA==.',
['我家']='我家小熊:BAAALgAECgkJCQABLgAFFAIJAgAVAAAAAA==.',
['战无']='战无天:BAAALgADCgUJBQAAAA==.',
['抱抱']='抱抱小恶魔:BAAALgAFFAEJAgAAAA==.',
['抹了']='抹了油的猪:BAAALgAECgcJBwAAAA==.',
['拉钩']='拉钩不说谎:BAAALgAECgEJAQAAAA==.',
['拔勺']='拔勺吧:BAABLgAFFH8HAAIWAAQJUiF1BAAsAQAWAAQJUiF1BAAsAQAAAA==.',
['拔铲']='拔铲吧:BAAALgAFFAIJAgAAAA==.',
['拨云']='拨云吧:BAAALgAFFAMJAwAAAA==.',
['指間']='指間的徘徊:BAAALgAECgEJAQAAAA==.',
['搁浅']='搁浅丶:BAAALgAFFAUJAQAAAA==.搁浅丶七:BAAALgAFFAQJAQAAAA==.搁浅丶三:BAAALgAFFAQJAgAAAA==.搁浅丶二:BAAALgAFFAQJAgAAAA==.搁浅丶十:BAABLgAFFH8GAAICAAQJxR3pAQB4AQACAAQJxR3pAQB4AQAAAA==.搁浅丶四:BAAALgAFFAQJAgAAAA==.搁浅丶雷:BAAALgAFFAUJAwAAAA==.',
['旋转']='旋转虾:BAABLgAECn8bAAMBAAkJfxWcEwB4AgABAAkJfxWcEwB4AgACAAQJWQsvZgCrAAAAAA==.',
['无情']='无情豆豆:BAAALgADCgIJAwAAAA==.',
['无敌']='无敌纯爱贼神:BAABLgAFFH8FAAIOAAMJHwg+DwD8AAAOAAMJHwg+DwD8AAAAAA==.',
['是正']='是正经骑士:BAAALgAECgcJBwAAAA==.',
['暗夜']='暗夜牧奶伊:BAAALgAECgEJAQABLgAFFAUJBQANANEPAA==.',
['暗影']='暗影梦魇:BAAALgAECgYJBwAAAA==.',
['最后']='最后一口乃:BAAALgAECgEJAQAAAA==.',
['月光']='月光灵曦丶:BAAALgAECgQJBQAAAA==.',
['有丨']='有丨容:BAAALgAECgYJCQAAAA==.',
['杯雪']='杯雪飘零:BAAALgAECgYJBgAAAA==.',
['柑蕉']='柑蕉桔梨籮柚:BAAALgAECgkJCQABLgAFFAYJDAAXAJ8SAA==.',
['核动']='核动力驴:BAAALgAECgUJBQAAAA==.',
['格兰']='格兰蒂捏:BAAALgADCgkJCgAAAA==.',
['梓诺']='梓诺:BAAALgAFFAEJAgAAAA==.',
['楚悬']='楚悬黎:BAABLgAFFH8FAAIYAAMJcx+4BgAMAQAYAAMJcx+4BgAMAQAAAA==.',
['此去']='此去江湖远:BAAALgAFFAIJBAAAAA==.',
['武之']='武之禅:BAAALgAECgYJBAAAAA==.',
['毕姥']='毕姥爷:BAAALgAECgQJBwAAAA==.',
['氯沙']='氯沙坦钾:BAAALgAECgEJAgAAAA==.',
['水能']='水能载牛:BAAALgADCgUJBAAAAA==.',
['池无']='池无:BAAALgAECgMJAwAAAA==.',
['洛汉']='洛汉:BAAALgAECgYJBwAAAA==.',
['派小']='派小派:BAABLgAECn8XAAIYAAkJgAyAIADeAQAYAAkJgAyAIADeAQAAAA==.派小满:BAAALgAECggJEwAAAA==.',
['浩淼']='浩淼:BAAALgAFFAEJAQAAAA==.',
['浪漫']='浪漫德:BAAALgAECgEJAQAAAA==.浪漫法:BAAALgAECgEJAgAAAA==.',
['湛蓝']='湛蓝:BAAALgAECgYJDAAAAA==.',
['潸然']='潸然淚下:BAAALgAECgkJCQAAAA==.',
['灬无']='灬无灬聊灬:BAAALgAECgYJBgAAAA==.',
['烈女']='烈女不怕死:BAAALgAFFAIJAgAAAA==.',
['燕三']='燕三少:BAAALgAECgcJDQABLgAECgkJGAANAFUfAA==.',
['爱在']='爱在两块钱:BAAALgAECgcJBwAAAA==.爱在六块钱:BAAALgADCgEJAQAAAA==.',
['狂舞']='狂舞曲:BAABLgAFFH8FAAIOAAIJQBr3CQC4AAAOAAIJQBr3CQC4AAAAAA==.',
['狐狐']='狐狐:BAAALgAFFAQJBAAAAA==.',
['皇家']='皇家恐怖卫仕:BAAALgAECgUJBAAAAA==.',
['皮丶']='皮丶小雪:BAAALgADCgEJAQAAAA==.',
['盐酸']='盐酸司美那非:BAAALgAECgEJAQAAAA==.',
['真闪']='真闪:BAAALgAECgEJAQAAAA==.',
['眼睛']='眼睛瞎了:BAAALgAECgYJBQAAAA==.',
['神密']='神密嘉嘉:BAAALgAFFAIJAwAAAA==.',
['秀水']='秀水无痕:BAACLgAFFH8MAAIZAAQJ1BUUCAAPAQAZAAQJ1BUUCAAPAQAuAAQKfyYAAhkACQmVHs0HABADABkACQmVHs0HABADAAAA.秀水无痕六世:BAABLgAECn8fAAIZAAcJQSGMFgCCAgAZAAcJQSGMFgCCAgABLgAFFAQJDAAZANQVAA==.',
['秋名']='秋名山车神丶:BAAALgAECgEJAQAAAA==.',
['秋水']='秋水映桃花:BAAALgAECgEJAQAAAA==.',
['穿靴']='穿靴子的猫:BAAALgAECgEJAQAAAA==.',
['笃行']='笃行致远:BAAALgADCgYJBgAAAA==.',
['笑丶']='笑丶笑:BAAALgAECgMJAwAAAA==.',
['粗壮']='粗壮壮:BAAALgAFFAEJAQAAAA==.',
['素还']='素还真丶:BAAALgAECgQJBQAAAA==.',
['绝世']='绝世狂战:BAAALgAECgkJCAAAAA==.',
['绿肤']='绿肤兜兜:BAACLgAFFH8JAAIBAAQJsyGsAwCaAQABAAQJsyGsAwCaAQAuAAQKfxsAAgEACAmmIhYGABEDAAEACAmmIhYGABEDAAAA.',
['美味']='美味生蚝:BAAALgAECgYJDAAAAA==.',
['羽少']='羽少真跑了:BAAALgAFFAEJAQAAAA==.',
['翘豚']='翘豚波比:BAABLgAFFH8IAAMYAAMJbRg+BwD8AAAYAAMJbRg+BwD8AAANAAIJuQRWDACAAAAAAA==.',
['老哥']='老哥别冰我:BAAALgAFFAQJAgAAAA==.老哥别锤我:BAAALgAFFAEJAQAAAA==.',
['胃卜']='胃卜鲜汁:BAAALgAECgQJCAAAAA==.',
['良辰']='良辰丶好景:BAAALgAECgYJBgAAAA==.',
['艾瑞']='艾瑞达新有菜:BAAALgADCgEJAQAAAA==.',
['芬达']='芬达罒氵罒:BAAALgAFFAEJAwAAAA==.',
['花儿']='花儿丶飘飘:BAABLgAFFH8LAAIaAAQJZxTxBgBXAQAaAAQJZxTxBgBXAQAAAA==.',
['花花']='花花想困醒:BAAALgAECgcJBwAAAA==.',
['苹果']='苹果大灰烬:BAAALgAECgIJAgAAAA==.苹果战神:BAAALgADCgIJAgAAAA==.',
['莜默']='莜默:BAAALgAECgEJAQAAAA==.',
['蓝色']='蓝色天空丶:BAAALgAECgUJBgAAAA==.',
['蜂梢']='蜂梢绫:BAAALgADCgUJBQAAAA==.',
['血色']='血色黄昏:BAAALgAECgYJAgABLgAFFAUJBQAMALIVAA==.',
['街边']='街边一炮手:BAAALgAECgQJBQAAAA==.',
['西瓜']='西瓜西瓜:BAABLgAECn8VAAMJAAgJ4RbIawD+AQAJAAgJKRTIawD+AQAKAAQJEQ63DwDHAAAAAA==.',
['观云']='观云丶端:BAAALgAECgYJBwAAAA==.',
['试玩']='试玩近战:BAAALgADCgYJBgAAAA==.',
['谦谦']='谦谦:BAAALgAECgIJAgAAAA==.',
['赤炼']='赤炼魄:BAAALgADCgEJAQAAAA==.',
['超级']='超级圈圈:BAAALgADCgMJAwAAAA==.超级婉婉:BAAALgAECgcJCQABLgAECgkJGAANAFUfAA==.',
['超自']='超自信五胖:BAAALgAECgEJAQAAAA==.',
['辰青']='辰青丶:BAABLgAFFH8LAAMIAAYJ+BXOCABiAQAIAAQJGxrOCABiAQAHAAQJig+tAgAKAQAAAA==.',
['过去']='过去的那些年:BAACLgAFFH8IAAIYAAMJehAXBQDYAAAYAAMJehAXBQDYAAAuAAQKfyUAAxgACAkSFKgIAJ8BABgACAkSFKgIAJ8BAA0AAwn+CX5DAJkAAAAA.',
['还有']='还有亡法吗:BAAALgAECgUJCAAAAA==.',
['这是']='这是小德:BAAALgAECgMJAwAAAA==.',
['迷失']='迷失之泪:BAAALgAECgQJCQAAAA==.',
['酒馆']='酒馆第一深情:BAAALgAECgUJEAAAAA==.',
['醉醉']='醉醉虾:BAAALgADCgcJCAAAAA==.',
['闪光']='闪光的黑炭:BAAALgAECgYJBgAAAA==.',
['阿丶']='阿丶拉蕾:BAAALgAECgcJBwAAAA==.',
['阿米']='阿米子:BAAALgAECgcJBwAAAA==.',
['陳冠']='陳冠鷄:BAAALgAECgYJBgAAAA==.',
['随風']='随風飄荡:BAAALgAECgcJBwAAAA==.',
['隔世']='隔世的眷戀:BAAALgAECgYJBgAAAA==.',
['露比']='露比莉亚丝:BAAALgAFFAEJAQAAAA==.',
['露露']='露露牙儿:BAAALgAECgIJAgAAAA==.',
['霸都']='霸都才子:BAAALgAECgUJCQAAAA==.霸都财子:BAAALgAECgUJAwAAAA==.',
['骑土']='骑土:BAAALgAECgUJBwAAAA==.',
['魔都']='魔都小树苗:BAAALgADCgYJBgAAAA==.',
['鱼么']='鱼么么:BAAALgAECgQJBQAAAA==.',
['鱿鱼']='鱿鱼丝不好呲:BAAALgAECgYJCwAAAA==.',
['鲜肉']='鲜肉小笼宝:BAABLgAECn8YAAQbAAkJFxTWDgDXAQAbAAgJSxLWDgDXAQAMAAUJXgyoXAAKAQAcAAQJrQZG9QCnAAAAAA==.',
['黎麻']='黎麻卖:BAAALgAECgYJCgAAAA==.',
['龙人']='龙人小小:BAAALgADCgcJBwAAAA==.',
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
