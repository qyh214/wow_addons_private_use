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

local lookup = {'Hunter-Marksmanship','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Mage-Frost','Druid-Balance','Warlock-Demonology','Warlock-Destruction','Evoker-Devastation','Unknown-Unknown','Hunter-BeastMastery','Paladin-Holy','Paladin-Retribution','Warrior-Protection','DeathKnight-Blood','Shaman-Restoration','DemonHunter-Devourer','DemonHunter-Havoc','DeathKnight-Frost','Hunter-Survival','Monk-Brewmaster','Warrior-Fury','Druid-Guardian','Druid-Restoration','Monk-Windwalker',}
local provider = {region='CN',realm='壁炉谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexandrite:BAAALgAECgUJBQAAAA==.Aloy:BAACLgAFFH8MAAIBAAQJKhmJCwBhAQABAAQJKhmJCwBhAQAuAAQKfyUAAgEACAkJJI4GADEDAAEACAkJJI4GADEDAAAA.',
Ar='Artemiis:BAAALgAECgYJDAAAAA==.',
Br='Bread:BAAALgADCgIJAwAAAA==.',
Da='Darkside:BAAALgAECgEJAgAAAA==.Daszz:BAAALgADCgEJAQAAAA==.Daydayss:BAACLgAFFH8FAAICAAIJoRayDQCQAAACAAIJoRayDQCQAAAuAAQKfx4AAwIABwkqIlcLAJoCAAIABwkqIlcLAJoCAAMAAgmwB4hNAFwAAAAA.',
De='Dejong:BAAALgAECgYJCgAAAA==.Derek:BAAALgAECgEJBAAAAA==.',
Dy='Dylanmage:BAAALgAFFAMJAwABLgAFFAYJFgAEAAkiAA==.',
Fo='Foxess:BAAALgADCgIJAgAAAA==.',
He='Hemage:BAABLgAFFH8IAAIFAAYJIRLlDQCrAQAFAAYJIRLlDQCrAQAAAA==.',
Ho='Hopebringer:BAAALgAECgQJBAABLgAFFAYJEQAGAJYhAA==.',
Hu='Huntershier:BAAALgAECgYJBgAAAA==.Huntershisi:BAAALgAFFAQJBAAAAA==.Huntershiyi:BAAALgAECgIJAQAAAA==.',
Ig='Ignotus:BAAALgAECgcJDwAAAA==.',
Jo='Johnwick:BAAALgAECgEJAQAAAA==.',
Kp='Kposeidon:BAAALgAECgIJAgAAAA==.',
Ku='Kumo:BAABLgAFFH8FAAIEAAUJPBpzBAC5AQAEAAUJPBpzBAC5AQAAAA==.Kuutar:BAABLgAECn8XAAMHAAYJKRg2ZQCcAQAHAAYJKRg2ZQCcAQAIAAMJxgJYVwBoAAAAAA==.',
Ky='Kythrra:BAAALgADCgYJBgAAAA==.',
La='Lavieenrose:BAAALgAECgEJAQAAAA==.',
Li='Lizi:BAAALgADCgEJAQAAAA==.',
Lo='Lovemybaby:BAAALgAECgQJBAAAAA==.',
Lu='Lunamoonfan:BAABLgAECn8ZAAIEAAkJEhnVHgDIAgAEAAkJEhnVHgDIAgABLgAFFAUJCQAIANghAA==.',
Ma='Macmillan:BAAALgAECgYJCQABLgAECgcJFQABAFkYAA==.',
Sa='Sammi:BAAALgADCgYJBgAAAA==.',
Sh='Sheenaringo:BAAALgAECgUJAwAAAA==.',
Si='Singularity:BAABLgAFFH8KAAIJAAUJIyBkAADvAQAJAAUJIyBkAADvAQABLgAFFAYJEQAGAJYhAA==.',
Sm='Smiled:BAAALgADCgUJBgAAAA==.',
Su='Sunray:BAAALgADCgYJBgAAAA==.',
Ti='Timme:BAAALgAECgMJBAAAAA==.Titanx:BAABLgAECn8YAAIEAAcJihGnagC2AQAEAAcJihGnagC2AQAAAA==.',
Ya='Yapher:BAAALgAECgcJCAAAAA==.',
Yo='Yourws:BAAALgAECgQJBQAAAA==.',
Yu='Yunbabya:BAAALgAECgUJBgAAAA==.',
['一手']='一手之数:BAAALgAECgEJAQAAAA==.',
['一滴']='一滴不剩:BAAALgADCgQJBAAAAA==.',
['一缕']='一缕冰蓝:BAAALgAECgUJBQAAAA==.',
['一闪']='一闪:BAAALgAECgQJBQAAAA==.',
['七月']='七月在宇:BAABLgAECn8dAAIFAAgJhB5AUwA+AgAFAAgJhB5AUwA+AgAAAA==.',
['三九']='三九宝宝巴士:BAAALgAECgEJAgABLgAECgYJCQAKAAAAAA==.三九小技师:BAAALgAECgYJCQAAAA==.三九扛大狙:BAAALgAECgEJAQABLgAECgYJCQAKAAAAAA==.',
['三砍']='三砍刀:BAAALgAECgkJCQAAAA==.',
['上上']='上上色:BAAALgAECgIJAgAAAA==.',
['不渡']='不渡:BAAALgADCgcJBwAAAA==.',
['不结']='不结冰的水:BAAALgADCgUJBQAAAA==.',
['不给']='不给糖果:BAAALgAECgMJBAAAAA==.',
['东拉']='东拉灬西扯:BAAALgAECgEJAQAAAA==.',
['东风']='东风无力百花:BAAALgAFFAUJAgAAAA==.',
['丝黛']='丝黛拉苟萨:BAAALgADCgUJBQAAAA==.',
['丨蝶']='丨蝶丨舞丨:BAAALgADCgEJAQAAAA==.',
['丶兰']='丶兰斯洛特:BAAALgAFFAMJAwAAAA==.',
['丿白']='丿白星丿:BAAALgAECgQJBQAAAA==.',
['二太']='二太二:BAAALgAECgQJCAAAAA==.',
['二零']='二零一三一四:BAAALgAECgEJAQAAAA==.',
['亚历']='亚历山大大帝:BAAALgAECgcJCAAAAA==.',
['今天']='今天不知道:BAAALgADCgYJCQAAAA==.',
['以太']='以太丶:BAAALgADCgcJBwAAAA==.',
['伍狗']='伍狗哥:BAAALgADCggJCAAAAA==.',
['会功']='会功夫的小卡:BAAALgAECgEJAQAAAA==.',
['佑灬']='佑灬你的美:BAAALgAECgEJAQAAAA==.',
['你条']='你条粉肠:BAAALgAECgQJBgAAAA==.',
['依尔']='依尔瓦娜斯:BAABLgAECn8bAAILAAgJixYFGwBlAgALAAgJixYFGwBlAgAAAA==.',
['倔犟']='倔犟灬小马哥:BAAALgAFFAMJBAAAAA==.',
['偷月']='偷月亮的猫:BAAALgAFFAEJAQAAAA==.',
['傲世']='傲世晓喻:BAAALgAECgEJAwAAAA==.',
['光膀']='光膀子忽悠:BAAALgAECgMJBgAAAA==.',
['光铸']='光铸超人:BAAALgAECgYJDwAAAA==.光铸银渐层:BAAALgAECgcJBgAAAA==.',
['八仟']='八仟:BAAALgAECgEJAQAAAA==.',
['兵主']='兵主之拳:BAAALgAECgEJAgAAAA==.',
['冰天']='冰天狐:BAAALgAECggJAgAAAA==.',
['冰金']='冰金:BAAALgAECgMJAwAAAA==.',
['冷月']='冷月葬清秋:BAAALgAECgEJAQAAAA==.冷月葬红颜:BAAALgAECgYJDAAAAA==.',
['凍結']='凍結乂伈:BAAALgAECgYJDgAAAA==.',
['凭神']='凭神史凯斯:BAAALgAFFAIJAwAAAA==.',
['划过']='划过天空:BAAALgAFFAEJAgAAAA==.',
['刘艾']='刘艾泽:BAAALgAECgEJAQAAAA==.',
['利维']='利维亚兽:BAAALgAECgcJBwAAAA==.',
['别打']='别打德:BAAALgADCgEJAQAAAA==.',
['削肾']='削肾客的舅叔:BAAALgAECgYJBgAAAA==.',
['加点']='加点花椒:BAAALgADCgEJAgAAAA==.',
['勉强']='勉强算强力:BAAALgAECgYJBgAAAA==.',
['十易']='十易:BAAALgADCgYJBgAAAA==.',
['卡不']='卡不达:BAAALgAECgYJDgAAAA==.',
['双刀']='双刀老太:BAAALgAECgYJCwAAAA==.',
['古迩']='古迩丹丶:BAAALgAECgUJBQAAAA==.',
['吃外']='吃外卖啦:BAAALgAECgEJAgAAAA==.',
['吃过']='吃过人:BAAALgAECgEJAQAAAA==.',
['吉恩']='吉恩的绝活:BAAALgAECgEJAQAAAA==.',
['名人']='名人熊:BAAALgAECgcJDAAAAA==.',
['听阴']='听阴天说什么:BAABLgAFFH8IAAIHAAQJkxpfDwBkAQAHAAQJkxpfDwBkAQAAAA==.',
['吾愿']='吾愿:BAAALgADCgQJBAAAAA==.',
['呆呆']='呆呆的小虾:BAAALgADCgcJBwAAAA==.',
['咖喱']='咖喱鱼蛋:BAABLgAECn8YAAMMAAcJQhLQNwCbAQAMAAcJQhLQNwCbAQANAAYJyBHtiQBnAQAAAA==.',
['哈吉']='哈吉米:BAAALgADCgEJAQAAAA==.',
['啸天']='啸天虎:BAAALgAECgEJAQAAAA==.',
['喝奶']='喝奶茶高手:BAAALgAECgQJCAAAAA==.',
['單純']='單純灬旺仔:BAAALgAECgMJBQAAAA==.',
['嘉丶']='嘉丶懿:BAAALgAECgEJAQAAAA==.',
['噼嘞']='噼嘞扑腾:BAAALgAECgYJCAAAAA==.',
['四何']='四何事:BAABLgAECn8kAAIEAAkJFyQyFQD8AgAEAAkJFyQyFQD8AgABLgAFFAQJBgAEAL0YAA==.',
['四皈']='四皈依:BAAALgADCgIJAgAAAA==.',
['囡囡']='囡囡侠:BAAALgAECgQJBAAAAA==.',
['图拉']='图拉阳:BAAALgAECgYJBwAAAA==.',
['土爷']='土爷爷:BAAALgAFFAIJAgAAAA==.',
['坊屋']='坊屋春道丶:BAABLgAECn8ZAAIEAAcJDCB+KACYAgAEAAcJDCB+KACYAgAAAA==.',
['坑啊']='坑啊坑:BAAALgAECgEJAQAAAA==.',
['基督']='基督山女爵:BAAALgAECgEJAQAAAA==.',
['墨香']='墨香淡韵:BAAALgAECgcJCwAAAA==.',
['壁炉']='壁炉谷一战:BAABLgAFFH8LAAIOAAQJ8g8CBgAKAQAOAAQJ8g8CBgAKAQAAAA==.',
['处处']='处处吻:BAABLgAECn8UAAIHAAgJMR3QIgCKAgAHAAgJMR3QIgCKAgAAAA==.',
['复仇']='复仇者马不为:BAABLgAFFH8OAAIEAAQJnBwIDgBqAQAEAAQJnBwIDgBqAQAAAA==.',
['多找']='多找自己问题:BAAALgAECggJDAABLgAFFAQJCAANAJEaAA==.',
['夜听']='夜听雨夜阑珊:BAAALgADCgEJAQAAAA==.',
['夜幕']='夜幕侵襲:BAAALgAECgEJAQAAAA==.',
['夜盗']='夜盗:BAAALgAFFAEJAgAAAA==.',
['夜魅']='夜魅牛牛:BAAALgAECgEJAQAAAA==.',
['大可']='大可:BAAALgAECgQJCQAAAA==.',
['大喵']='大喵咪:BAAALgAECgIJAgAAAA==.',
['大头']='大头格格巫:BAAALgAFFAIJBAAAAA==.',
['大孝']='大孝子:BAAALgAECgkJBgABLgAFFAUJAgAKAAAAAA==.',
['大执']='大执夷:BAAALgAFFAEJAQABLgAFFAIJBQAEAAogAA==.',
['大爷']='大爷请放手:BAABLgAFFH8GAAIEAAIJIhbFPwChAAAEAAIJIhbFPwChAAAAAA==.',
['大犽']='大犽:BAAALgAECgYJBgAAAA==.',
['大跳']='大跳追富婆:BAAALgAECgYJBgAAAA==.',
['大飞']='大飞哥哥:BAAALgAECgEJAQAAAA==.大飞家人:BAAALgAECgEJAgAAAA==.',
['天天']='天天的愤怒:BAAALgADCgEJAQAAAA==.',
['天有']='天有四时:BAAALgAFFAQJAwAAAA==.',
['天线']='天线魔宝:BAAALgAECgYJCgAAAA==.',
['天选']='天选小馒头:BAAALgAFFAEJAQAAAA==.',
['妮芙']='妮芙:BAABLgAFFH8LAAMPAAQJvhnNBQA+AQAEAAQJCROKFwBGAQAPAAQJuxfNBQA+AQABLgAFFAcJEwAPAJMVAA==.',
['宇光']='宇光圣骑:BAAALgADCgEJAgAAAA==.',
['守备']='守备官伊琳:BAAALgAECgEJAgAAAA==.',
['安心']='安心乌鸦:BAAALgAECgEJAQAAAA==.',
['寒山']='寒山破碎:BAABLgAECn8VAAMEAAcJ+BHlhAB4AQAEAAcJ+BHlhAB4AQAPAAQJRQk8MwCnAAAAAA==.',
['射手']='射手座大白熊:BAAALgADCgIJAgAAAA==.',
['小呢']='小呢喃:BAAALgAFFAQJBAAAAA==.',
['小媚']='小媚眼:BAAALgAFFAEJAQAAAA==.',
['小小']='小小的眼睛:BAAALgADCgUJBQAAAA==.',
['小扶']='小扶兮:BAAALgAECgEJAQAAAA==.',
['小朱']='小朱诺诺:BAAALgAECgcJBwAAAA==.',
['小树']='小树熊软糖:BAAALgADCgUJBQAAAA==.',
['小残']='小残忍:BAAALgAECgcJDgAAAA==.',
['小法']='小法饼:BAAALgAECggJDQAAAA==.',
['小灬']='小灬森:BAAALgAECgEJAgAAAA==.小灬萨:BAAALgADCgUJBQAAAA==.',
['小瑞']='小瑞宝:BAAALgAFFAQJBAABLgAFFAUJCwAFAMAhAA==.',
['小软']='小软害你呦:BAAALgAECgQJBAAAAA==.',
['小钓']='小钓:BAAALgAECgEJAQAAAA==.',
['小阳']='小阳:BAAALgAECgUJBwAAAA==.',
['小龙']='小龙人煊:BAAALgAECgEJAQAAAA==.',
['尘埃']='尘埃之刃:BAAALgAECgEJAQAAAA==.',
['就打']='就打那个萨满:BAAALgAECgYJCgAAAA==.',
['山色']='山色有无中:BAAALgAECgMJAwAAAA==.',
['山路']='山路十八弯:BAABLgAFFH8LAAIOAAQJsxpJBQAdAQAOAAQJsxpJBQAdAQAAAA==.',
['岂曰']='岂曰:BAAALgADCgYJAwAAAA==.',
['巨人']='巨人丶浩克:BAAALgAECgEJAQAAAA==.',
['布莱']='布莱克拽根:BAAALgAECgMJAwAAAA==.',
['幻彩']='幻彩新生:BAAALgADCgUJBQAAAA==.幻彩法丝:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影杀戮者:BAAALgAECgEJAwAAAA==.幻影血刺:BAAALgAECgUJBQAAAA==.',
['幽冥']='幽冥射手:BAAALgAECgIJAgAAAA==.',
['康师']='康师傅鲜橙多:BAAALgAECgMJAwAAAA==.',
['廣崬']='廣崬什苦:BAAALgAECgEJAQAAAA==.',
['弑神']='弑神航哥:BAAALgADCgEJAQAAAA==.',
['引星']='引星棘刺:BAAALgAFFAQJAwAAAA==.',
['张小']='张小凡:BAAALgAECgYJBgAAAA==.',
['当当']='当当珰铛铛:BAAALgAECgcJCAAAAA==.',
['彩狸']='彩狸花生:BAACLgAFFH8LAAIEAAQJMx0lBQBmAQAEAAQJMx0lBQBmAQAuAAQKfxoAAgQACAmQHUQjALICAAQACAmQHUQjALICAAAA.',
['御丶']='御丶影:BAABLgAFFH8KAAIQAAMJqSPCCAA/AQAQAAMJqSPCCAA/AQAAAA==.',
['心荒']='心荒:BAAALgAECgcJCgAAAA==.',
['忧忧']='忧忧郁郁:BAAALgAECgIJAgAAAA==.',
['怪盗']='怪盗僧:BAAALgAECgEJAQAAAA==.',
['恶魔']='恶魔卡比:BAAALgADCgUJBAAAAA==.恶魔夜想曲:BAAALgAECgMJBQAAAA==.',
['悠哉']='悠哉的行走:BAAALgADCgcJBwAAAA==.',
['情卜']='情卜由姬:BAAALgAFFAIJAgAAAA==.',
['愁渔']='愁渔:BAAALgAECgEJAgAAAA==.',
['愤愤']='愤愤的咖喱:BAAALgAECgUJCQAAAA==.',
['我是']='我是自己人:BAAALgAECgcJDwAAAA==.',
['我的']='我的一个朋友:BAAALgAECgUJBQAAAA==.',
['我瞎']='我瞎砍:BAAALgADCgUJBwAAAA==.',
['我舞']='我舞零乱:BAACLgAFFH8FAAINAAMJdxTrFAACAQANAAMJdxTrFAACAQAuAAQKfxUAAg0ACAneHc8kAJQCAA0ACAneHc8kAJQCAAAA.',
['我要']='我要风筝锟子:BAACLgAFFH8IAAIGAAQJ3hI4AwBHAQAGAAQJ3hI4AwBHAQAuAAQKfxQAAgYACAn8D8ErAKQBAAYACAn8D8ErAKQBAAAA.',
['打不']='打不过就跪:BAAALgAECgUJCgAAAA==.',
['抓抓']='抓抓背:BAAALgAECgkJCQAAAA==.',
['抓着']='抓着你作猪打:BAAALgAECgQJBgAAAA==.',
['抠脚']='抠脚脚:BAAALgAFFAIJBAAAAA==.',
['拉菲']='拉菲毛胡子:BAAALgAECgEJAQAAAA==.',
['拴不']='拴不住的狗子:BAAALgADCgUJBQAAAA==.',
['拾玖']='拾玖陸:BAAALgADCgEJAQAAAA==.',
['挠挠']='挠挠背:BAAALgADCgYJBgAAAA==.',
['掼蛋']='掼蛋:BAAALgAECgcJBwAAAA==.',
['搔头']='搔头不寐时:BAAALgADCgMJAwAAAA==.',
['支部']='支部联络员:BAAALgADCgEJAQAAAA==.',
['旅行']='旅行精灵:BAAALgAECgYJDQAAAA==.',
['无尽']='无尽的黑暗:BAAALgAECgYJBgAAAA==.',
['无心']='无心丶尛脑斧:BAABLgAFFH8GAAIFAAMJBQ6xPQCxAAAFAAMJBQ6xPQCxAAAAAA==.',
['无敌']='无敌尕西:BAAALgAECgQJBAAAAA==.',
['无聊']='无聊的牛小牛:BAAALgAECgUJBQAAAA==.',
['明月']='明月照西厢:BAAALgADCgYJBgAAAA==.明月镜湖影:BAAALgAECgcJDgAAAA==.',
['易天']='易天宇:BAAALgAECgIJAgAAAA==.',
['星星']='星星与鹿:BAAALgAFFAMJBAAAAA==.',
['春之']='春之祭:BAAALgAECgEJAQAAAA==.',
['是大']='是大叉喔:BAAALgAECgYJCgAAAA==.',
['晓阳']='晓阳:BAAALgAECgUJBQAAAA==.',
['暴走']='暴走的窝窝:BAAALgAECgEJAgAAAA==.',
['最后']='最后的华丽:BAAALgAECgEJAQAAAA==.',
['月夏']='月夏丶流殇:BAAALgAECgYJDAAAAA==.',
['月明']='月明松:BAAALgAECgUJCgAAAA==.',
['月黑']='月黑林影踪:BAAALgAECgQJBAAAAA==.',
['有爱']='有爱就重来:BAAALgADCgEJAQAAAA==.',
['术爷']='术爷有一手:BAAALgAECgEJAQAAAA==.',
['李四']='李四:BAABLgAFFH8FAAMRAAIJ/BTrJQCoAAARAAIJ/BTrJQCoAAASAAEJGwK3DwBEAAAAAA==.',
['李德']='李德屏:BAAALgAECgIJAgAAAA==.',
['杨小']='杨小咪:BAAALgADCgEJAQAAAA==.',
['极恶']='极恶贝贝:BAAALgAECgIJAgAAAA==.',
['梟熊']='梟熊:BAAALgAECgEJAgAAAA==.',
['梦里']='梦里有钱:BAAALgADCgYJCAAAAA==.',
['梧桐']='梧桐细雨:BAAALgAECgQJBAAAAA==.',
['橙橙']='橙橙灬:BAAALgAECgYJDgAAAA==.',
['檸檬']='檸檬芝士:BAAALgAECgUJCQAAAA==.',
['死亡']='死亡鱼旦:BAAALgAECgYJBwAAAA==.',
['死灵']='死灵圣法:BAAALgAECgQJBAAAAA==.',
['死鬼']='死鬼吹灯:BAAALgAECgcJCwAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8JAAIDAAQJyyBsBgB6AQADAAQJyyBsBgB6AQABLgAFFAUJKgADAP8kAA==.',
['水库']='水库浪子:BAAALgAECgYJDQAAAA==.',
['水德']='水德:BAAALgADCgEJAQAAAA==.',
['水路']='水路十八弯:BAAALgAFFAEJAQAAAA==.',
['水骑']='水骑:BAAALgAECgQJBAAAAA==.',
['永远']='永远的久远:BAAALgADCgEJAQAAAA==.',
['污妖']='污妖:BAABLgAECn8VAAMEAAcJWx1uOABVAgAEAAcJWx1uOABVAgATAAIJ6xKYEgBnAAAAAA==.',
['没医']='没医保你先上:BAACLgAFFH8FAAIOAAMJJBMHCADbAAAOAAMJJBMHCADbAAAuAAQKfx4AAg4ACAm1GxUHALoCAA4ACAm1GxUHALoCAAAA.',
['没见']='没见过暴击:BAAALgAECgQJBQAAAA==.',
['法丝']='法丝超人:BAAALgADCgMJAwAAAA==.',
['泡泡']='泡泡茶壶丶:BAAALgAECgUJCQAAAA==.',
['泰岚']='泰岚德圣风:BAAALgAECgIJAQAAAA==.',
['泰熊']='泰熊眼罩妹:BAAALgAECgQJBQAAAA==.',
['浊心']='浊心斯卡蒂:BAAALgAFFAQJAwAAAA==.',
['浪淘']='浪淘淘:BAAALgAECgkJCQAAAA==.',
['浮华']='浮华苍珄:BAAALgAECgIJAwAAAA==.浮华苍生:BAAALgAECgEJAQAAAA==.',
['海蓝']='海蓝不见鲸:BAAALgADCgkJCQAAAA==.',
['海阳']='海阳:BAACLgAFFH8EAAIHAAIJmw3BOACiAAAHAAIJmw3BOACiAAAuAAQKfxAAAgcABQk7HCdiAKMBAAcABQk7HCdiAKMBAAAA.',
['涤火']='涤火杰西卡:BAAALgAFFAUJBAAAAA==.',
['淡蓝']='淡蓝:BAAALgADCgMJBQAAAA==.',
['深度']='深度套牢牛:BAAALgAECgMJAwAAAA==.',
['清纯']='清纯小美眉:BAAALgAECgEJAwAAAA==.',
['滚呀']='滚呀滚:BAAALgAFFAEJAQAAAA==.',
['潋滟']='潋滟沧行:BAAALgAFFAIJAwAAAA==.',
['灬天']='灬天堂在佐灬:BAAALgADCgEJAQAAAA==.',
['灬皮']='灬皮皮鲁:BAAALgAECgIJBgAAAA==.',
['灬聖']='灬聖光灬:BAAALgAECgUJBQAAAA==.',
['灬遇']='灬遇术临疯灬:BAAALgAECgYJCQAAAA==.',
['灬黑']='灬黑黫灬:BAAALgAECgYJBgAAAA==.',
['灭日']='灭日之皇:BAAALgAECgUJCQAAAA==.',
['炎焱']='炎焱尐火燚:BAAALgAECgEJAQAAAA==.',
['炎龙']='炎龙骑士:BAAALgAECgcJCAAAAA==.',
['炫彩']='炫彩快龙:BAAALgAFFAIJAgAAAA==.',
['烛岚']='烛岚风:BAACLgAFFH8MAAQLAAQJgBkVCAAjAQALAAMJ4B0VCAAjAQAUAAEJORQYBgBaAAABAAEJOwudKwBEAAAuAAQKfx8ABAsACQkjG/kUAI8CAAsACAkPG/kUAI8CAAEABwk8FUMxAKoBABQAAQnZHZcsAEEAAAAA.',
['無夢']='無夢不成双:BAAALgAECgQJBgAAAA==.',
['無枫']='無枫不起浪:BAAALgAECgEJAQAAAA==.',
['無瘋']='無瘋不起浪:BAAALgAECgYJBwAAAA==.',
['無須']='無須囘憶:BAAALgAECgUJBQAAAA==.',
['熊吉']='熊吉酱丶:BAAALgAECgYJBgAAAA==.',
['爆头']='爆头超人:BAAALgAECgIJAgAAAA==.',
['爱吃']='爱吃泡芙:BAAALgAECgcJCwAAAA==.',
['爱欧']='爱欧尼亚狂热:BAAALgAECgYJCwAAAA==.',
['爱花']='爱花酱:BAAALgADCgcJBwABLgAECgUJBQAKAAAAAA==.',
['爸迪']='爸迪的小果果:BAAALgADCgEJAQAAAA==.',
['牛牛']='牛牛小强贰:BAAALgAECgEJAQAAAA==.',
['犭一']='犭一拳超人丶:BAABLgAFFH8HAAIVAAIJByFyFgC/AAAVAAIJByFyFgC/AAAAAA==.',
['犹如']='犹如盛夏:BAAALgAECgYJBwAAAA==.',
['狂奔']='狂奔的蛋卷:BAAALgAFFAIJBAAAAA==.',
['狂躁']='狂躁丶:BAAALgADCgUJBQAAAA==.',
['猪杂']='猪杂喵喵拳:BAAALgAECgEJAQAAAA==.',
['猪猪']='猪猪妹:BAAALgAECgcJBwAAAA==.',
['玉无']='玉无双:BAAALgAFFAIJAgAAAA==.',
['玉树']='玉树临峰:BAAALgADCgUJBQAAAA==.',
['玉格']='玉格格:BAAALgAECgEJAQAAAA==.',
['王大']='王大陆:BAAALgADCgcJCAAAAA==.',
['玛猴']='玛猴烧酒:BAAALgAECgYJCgAAAA==.',
['玛雅']='玛雅圣骑:BAAALgAECgEJAQAAAA==.',
['球衣']='球衣啵:BAAALgAECgUJDAAAAA==.',
['琢磨']='琢磨老师:BAAALgAECgYJBwAAAA==.',
['琪琪']='琪琪大魔王:BAAALgAFFAIJAgAAAA==.',
['瓜小']='瓜小丫:BAAALgADCgEJAQAAAA==.',
['甲骨']='甲骨妖妖:BAAALgAECgEJAQAAAA==.',
['略懂']='略懂拳脚:BAAALgAECgYJBgAAAA==.',
['白小']='白小雲:BAABLgAFFH8FAAINAAIJqhdiIQCqAAANAAIJqhdiIQCqAAAAAA==.',
['白雾']='白雾红尘:BAAALgADCgYJCwAAAA==.',
['百分']='百分百白衣:BAAALgAECgcJBwAAAA==.',
['百战']='百战沙场:BAAALgADCgUJCAAAAA==.',
['盐汽']='盐汽水:BAAALgADCgEJAQAAAA==.',
['盛灬']='盛灬夏光年:BAAALgAFFAEJAwAAAA==.',
['眠河']='眠河:BAAALgAECgcJCwAAAA==.',
['矫健']='矫健的猎手:BAAALgADCgYJBgAAAA==.',
['矫情']='矫情丶祥子:BAAALgAECgYJBwAAAA==.',
['矮挫']='矮挫挫:BAAALgAECgEJAQAAAA==.',
['碎碎']='碎碎冰:BAACLgAFFH8FAAIFAAIJXB2oNwC7AAAFAAIJXB2oNwC7AAAuAAQKfxkAAgUACQkhIEsbAAkDAAUACQkhIEsbAAkDAAAA.',
['碰碰']='碰碰车:BAAALgAFFAEJAQAAAA==.',
['神马']='神马牧:BAAALgAECgEJAQAAAA==.',
['祭血']='祭血之魂:BAAALgAECgUJEAAAAA==.',
['秋风']='秋风乱叶疏:BAAALgAECgEJAQAAAA==.',
['秦王']='秦王请绕柱:BAAALgADCgEJAQAAAA==.',
['穆青']='穆青:BAAALgAECgYJEAAAAA==.',
['窗台']='窗台的小猫:BAAALgAFFAEJAgAAAA==.',
['筱寅']='筱寅寅:BAAALgAECgIJAwAAAA==.',
['米奇']='米奇战神:BAAALgAECgYJDAAAAA==.',
['米奈']='米奈希尔公爵:BAAALgADCgcJBwAAAA==.',
['糊帆']='糊帆帆三脸:BAAALgAECgIJAgAAAA==.',
['红烧']='红烧大馒头:BAAALgADCgMJAwAAAA==.',
['约尔']='约尔:BAAALgAECgYJBgAAAA==.',
['纳兰']='纳兰怒风:BAAALgAECgQJBQAAAA==.纳兰死骑:BAAALgAFFAIJAgAAAA==.',
['终生']='终生回忆妳:BAAALgADCgIJAgABLgAECgYJCAAKAAAAAA==.',
['给你']='给你我的心:BAAALgAFFAIJAwAAAA==.',
['维什']='维什戴尔:BAAALgAECgIJAwAAAA==.',
['罪犯']='罪犯杀来:BAAALgAECgMJBQAAAA==.',
['美丽']='美丽的甜水:BAAALgAECgUJBQAAAA==.',
['羞羞']='羞羞咻:BAAALgAECgEJAQAAAA==.',
['翔龍']='翔龍之怒:BAAALgAECgkJEgAAAA==.',
['翻车']='翻车魚:BAAALgAFFAIJAgABLgAFFAYJGgAWAG4hAA==.',
['老艺']='老艺术家:BAAALgADCgUJBQABLgAFFAUJCAAIAO0UAA==.',
['耗儿']='耗儿药微甜:BAAALgAECgYJBgAAAA==.',
['耳朵']='耳朵萌萌德:BAABLgAFFH8GAAIXAAIJVBG/BAB4AAAXAAIJVBG/BAB4AAAAAA==.耳朵萌萌战:BAAALgAFFAIJAwAAAA==.耳朵萌萌拳:BAACLgAFFH8GAAIVAAMJZxDMCwCXAAAVAAMJZxDMCwCXAAAuAAQKfxgAAhUACAmaFYoaADACABUACAmaFYoaADACAAAA.',
['耶米']='耶米兔:BAAALgADCgcJBwAAAA==.',
['职业']='职业试玩丶:BAAALgADCgUJBQAAAA==.',
['聖光']='聖光笼罩:BAAALgAECgMJBQAAAA==.',
['肉丸']='肉丸:BAAALgAECgkJDAAAAA==.',
['胡汉']='胡汉山的打手:BAAALgAFFAIJAgAAAA==.',
['胤悦']='胤悦:BAAALgAECgUJBQAAAA==.',
['胤跃']='胤跃:BAAALgAECgUJBgAAAA==.',
['脚骨']='脚骨碎渣渣:BAAALgAECgkJAQAAAA==.',
['自来']='自来也:BAABLgAFFH8GAAIFAAMJdxFFLAAFAQAFAAMJdxFFLAAFAQAAAA==.',
['臭妞']='臭妞妞:BAAALgADCgYJBgAAAA==.',
['舞彩']='舞彩:BAAALgAECgkJCQAAAA==.',
['舞灬']='舞灬影零乱:BAAALgAECgUJBQAAAA==.',
['舟山']='舟山陈伟霆:BAAALgAECgcJEAAAAA==.',
['艾琳']='艾琳瑟拉:BAAALgAECgEJAQAAAA==.',
['艾瑞']='艾瑞德:BAAALgAECgYJCAAAAA==.',
['艾辛']='艾辛诺斯战刃:BAAALgAECgUJBgAAAA==.',
['花漾']='花漾恬心:BAAALgADCgEJAQAAAA==.',
['苏东']='苏东坡:BAACLgAFFH8OAAIYAAUJLRj2AgC8AQAYAAUJLRj2AgC8AQAuAAQKfxQAAhgACQk5ITsFADoDABgACQk5ITsFADoDAAAA.',
['若姬']='若姬:BAAALgADCgQJBAAAAA==.',
['苦逼']='苦逼丶有木有:BAAALgADCgEJAQAAAA==.',
['茅崎']='茅崎夕樱:BAACLgAFFH8LAAIFAAUJdiDBBwDmAQAFAAUJdiDBBwDmAQAuAAQKfxYAAgUACAlpIHokAOECAAUACAlpIHokAOECAAEuAAUUBgkRAAYAliEA.',
['莫忆']='莫忆莫惜:BAAALgAECggJCAAAAA==.',
['菊花']='菊花很邪恶:BAAALgAECgEJAwAAAA==.',
['葑芯']='葑芯絕戀:BAAALgADCgUJAQAAAA==.',
['蒼血']='蒼血之牙:BAAALgAECgQJBAAAAA==.',
['蓝七']='蓝七匹狼:BAABLgAECn8VAAMGAAcJkQYmQwAjAQAGAAcJkQYmQwAjAQAYAAMJ4QGsugBQAAAAAA==.',
['蓝瞳']='蓝瞳魔法妹:BAAALgADCgYJBgAAAA==.',
['薇薇']='薇薇:BAAALgADCgMJAwAAAA==.',
['藤原']='藤原纪香:BAAALgAFFAEJAQAAAA==.',
['虚妄']='虚妄郁魅:BAAALgAECgQJBAAAAA==.',
['蝰蛇']='蝰蛇一号:BAAALgAFFAQJBAAAAA==.蝰蛇二号:BAACLgAFFH8GAAIEAAUJeAdBIgAOAQAEAAUJeAdBIgAOAQAuAAQKfxQAAgQACAncFVdAADcCAAQACAncFVdAADcCAAAA.',
['螃蟹']='螃蟹精灵:BAAALgADCgEJAQAAAA==.',
['蟹堡']='蟹堡王公主:BAAALgADCgEJAgAAAA==.',
['血色']='血色乌鸦:BAAALgADCgUJBQAAAA==.',
['被淹']='被淹死的鲸鱼:BAAALgAECgMJAwAAAA==.',
['被遗']='被遗忘的种族:BAAALgADCgcJBwAAAA==.',
['西沉']='西沉月影:BAAALgAECgkJCwAAAA==.',
['要吃']='要吃糖:BAAALgADCgEJAQAAAA==.',
['语不']='语不惊人:BAAALgADCgIJAgAAAA==.',
['诸葛']='诸葛钢蛋:BAAALgAECgEJAQAAAA==.',
['诺拉']='诺拉:BAAALgADCgUJBQAAAA==.',
['读条']='读条要流畅:BAAALgAECgIJAgAAAA==.',
['调琴']='调琴:BAAALgAECgIJAgAAAA==.',
['豫章']='豫章:BAAALgAECgcJDAAAAA==.',
['貓桃']='貓桃:BAAALgAECgIJAgAAAA==.',
['貓販']='貓販:BAAALgAECgEJAwAAAA==.',
['貓飯']='貓飯:BAABLgAFFH8HAAMVAAMJdR8yDwAKAQAVAAMJdR8yDwAKAQAZAAEJlxQHCABVAAAAAA==.',
['贰万']='贰万元:BAAALgADCgYJAQAAAA==.',
['贴阁']='贴阁碧:BAAALgAECgQJBAAAAA==.',
['超级']='超级老外:BAAALgAECgEJAQAAAA==.',
['越野']='越野乙族:BAAALgAECgkJCQAAAA==.越野异族:BAAALgAECgYJBgAAAA==.',
['躺三']='躺三打:BAAALgAECgEJAgAAAA==.',
['过五']='过五关斩六将:BAAALgAECgMJAwAAAA==.',
['追着']='追着尾巴转圈:BAAALgAECgEJAQAAAA==.',
['逃之']='逃之新新:BAAALgAECgEJAQAAAA==.',
['逗号']='逗号:BAAALgADCgQJBAAAAA==.',
['郭美']='郭美镁:BAAALgAECgQJBAAAAA==.',
['酱香']='酱香大骨头:BAAALgAFFAEJAQAAAA==.',
['醉酒']='醉酒清牛:BAAALgAECgcJCgAAAA==.',
['里地']='里地病:BAAALgAECgYJAQAAAA==.',
['里徳']='里徳宾:BAAALgAECgYJBgAAAA==.',
['里锝']='里锝并:BAAALgAECgcJCAAAAA==.',
['野猪']='野猪魁:BAACLgAFFH8GAAMYAAMJrBa2HACJAAAYAAIJbRK2HACJAAAGAAEJsgIBHQBBAAAuAAQKfyIAAhgACAklFI0MAIsBABgACAklFI0MAIsBAAAA.',
['銮天']='銮天:BAAALgADCgEJAQAAAA==.',
['钟情']='钟情于兵:BAAALgADCgEJAQAAAA==.',
['钱瑶']='钱瑶瑶:BAAALgADCgEJAQAAAA==.',
['锟子']='锟子会怎么做:BAABLgAFFH8IAAIGAAQJEhHFAwA2AQAGAAQJEhHFAwA2AQAAAA==.锟子意闪:BAABLgAFFH8GAAIGAAUJKRhzBAClAQAGAAUJKRhzBAClAQAAAA==.',
['锤子']='锤子妹:BAAALgAECgMJBAAAAA==.',
['锤比']='锤比艿大:BAAALgADCgEJAQAAAA==.',
['闷不']='闷不做声:BAAALgAECgEJAQAAAA==.',
['阳光']='阳光被偷走啦:BAAALgAECgEJAwAAAA==.',
['阴影']='阴影之夕:BAAALgAECgIJAgAAAA==.',
['阿朗']='阿朗斯給:BAAALgAECgEJAQAAAA==.',
['阿華']='阿華田熱可可:BAAALgAECgYJBgAAAA==.',
['雨天']='雨天彩虹:BAAALgAECgEJAQAAAA==.',
['雷巴']='雷巴顿伯爵:BAAALgAECgEJAQAAAA==.',
['霜雪']='霜雪皆过往:BAAALgAECggJDQAAAA==.',
['靈乂']='靈乂傲慢:BAAALgAECgkJDwAAAA==.',
['非常']='非常德:BAAALgAECgMJAwAAAA==.',
['飘香']='飘香鸡腿堡:BAAALgADCgYJBgAAAA==.',
['飞天']='飞天二草:BAAALgADCgIJAgAAAA==.',
['飞火']='飞火流云:BAAALgADCgIJAgAAAA==.',
['飞鹰']='飞鹰:BAAALgADCgcJCwAAAA==.',
['香无']='香无损:BAAALgAECgUJCgAAAA==.',
['马尾']='马尾:BAAALgADCgEJAQAAAA==.',
['马西']='马西:BAAALgADCgMJAwAAAA==.',
['鬼魁']='鬼魁:BAAALgADCgUJBQABLgAECgQJBAAKAAAAAA==.',
['魔法']='魔法喷喷龙:BAAALgAECgEJAQAAAA==.',
['魔贯']='魔贯光杀炮:BAABLgAECn8ZAAISAAgJYhj5FAAoAgASAAgJYhj5FAAoAgAAAA==.',
['麦格']='麦格伦:BAAALgAECgYJEAAAAA==.',
['麦梳']='麦梳梳:BAAALgADCgQJBAAAAA==.',
['黑夜']='黑夜之风:BAAALgAFFAEJAgAAAA==.',
['黑色']='黑色的眼线:BAAALgAECgkJCQAAAA==.',
['黯炎']='黯炎瑟米欧斯:BAAALgAECgYJBwAAAA==.',
['龍城']='龍城飛将:BAAALgAECgcJEAAAAA==.',
['龙嚒']='龙嚒嚒:BAAALgAECgQJBAAAAA==.',
['龚怡']='龚怡佳:BAAALgAFFAIJBAAAAA==.',
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
