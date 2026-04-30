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

local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Mage-Frost','Warrior-Protection','DemonHunter-Devourer','Monk-Brewmaster','Warlock-Demonology','Evoker-Augmentation','Evoker-Devastation','DemonHunter-Havoc','Shaman-Elemental','Evoker-Preservation','Priest-Holy','Rogue-Subtlety','Warlock-Destruction','Warrior-Arms','Warrior-Fury','Priest-Shadow','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','Shaman-Restoration','Monk-Windwalker','Monk-Mistweaver',}
local provider = {region='CN',realm='黑石尖塔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alert:BAAALgAECgcJBwAAAA==.',
An='Anastasiaf:BAAALgAECgEJAQAAAA==.',
Ar='Aramari:BAAALgAECgYJBgAAAA==.',
Br='Brightcat:BAABLgAECn8YAAMBAAcJ4hLFdgCYAQABAAcJ4hLFdgCYAQACAAEJqQ3HCgA+AAAAAA==.',
Ca='Camora:BAAALgAECgcJCgAAAA==.',
Da='Daster:BAAALgAECggJEwAAAA==.',
Dh='Dh:BAAALgAECgEJAQAAAA==.',
Dr='Drextar:BAAALgAECgcJBwAAAA==.',
Hk='Hklasu:BAAALgAECgEJAQAAAA==.',
Ja='Janmy:BAAALgAECgkJBwABLgAFFAcJBQADANIGAA==.',
Jo='Jokerlin:BAAALgAECgEJAQAAAA==.',
Li='Lifengzs:BAABLgAFFH8FAAIEAAUJ+BqCAQBrAQAEAAUJ+BqCAQBrAQAAAA==.Linabell:BAAALgAECgcJBwAAAA==.',
Ma='Magicelf:BAAALgAECgYJEQAAAA==.',
Pa='Palyboy:BAAALgADCgcJBwAAAA==.',
Pe='Penny:BAAALgAECgYJCAAAAA==.',
Re='Revengelevex:BAAALgAFFAEJAQAAAA==.',
Ro='Rosel:BAAALgAECgYJBwAAAA==.',
Ru='Rundstedtt:BAAALgAECgYJBwAAAA==.',
Si='Silenty:BAAALgAECgQJBAAAAA==.',
So='Soultearer:BAAALgAECgEJAQAAAA==.',
St='Stgerrard:BAAALgADCgEJAQAAAA==.',
Su='Sukhavati:BAABLgAECn8XAAIFAAYJfx3nOAARAgAFAAYJfx3nOAARAgAAAA==.',
Ta='Tabata:BAAALgAECgQJBwABLgAFFAMJCAAGABkMAA==.',
Wi='Williamselby:BAAALgAECgEJAQAAAA==.',
Yi='Yiyiicee:BAAALgAECgIJAwAAAA==.Yiyiiceq:BAAALgAECgEJAQAAAA==.Yiyiicews:BAAALgAECgEJAQAAAA==.',
Ze='Zene:BAAALgAECgYJDgAAAA==.',
['一剑']='一剑霜寒:BAAALgAECgIJAwAAAA==.',
['一大']='一大新手:BAAALgAECgYJDgAAAA==.',
['一篮']='一篮头:BAABLgAECn8VAAIHAAYJYAymlAAvAQAHAAYJYAymlAAvAQAAAA==.',
['一背']='一背叛一:BAAALgAECgYJCAAAAA==.',
['不会']='不会翻跟斗:BAAALgAECgYJCAAAAA==.',
['不服']='不服你夯我:BAAALgAECgQJCAAAAA==.',
['丨铁']='丨铁头娃丨:BAABLgAFFH8IAAIGAAMJSRvoCQD1AAAGAAMJSRvoCQD1AAAAAA==.',
['丶梦']='丶梦鲤:BAABLgAECn8aAAMIAAgJnRFoGgD3AQAIAAgJnRFoGgD3AQAJAAYJbgo5IgAYAQAAAA==.',
['丿羽']='丿羽星皇:BAAALgAECgMJAwAAAA==.',
['九爷']='九爷的小德:BAAALgADCgEJAQAAAA==.',
['二妹']='二妹妹:BAAALgAECgEJAQAAAA==.',
['五更']='五更丶丶琉璃:BAAALgAECgcJBwAAAA==.',
['井九']='井九久:BAAALgADCgYJBgAAAA==.井九酒:BAAALgAECgUJBQAAAA==.',
['从阴']='从阴影中降临:BAACLgAFFH8IAAIKAAQJIiDaAQB+AQAKAAQJIiDaAQB+AQAuAAQKfxwAAgoACQnsH4oCAGcDAAoACQnsH4oCAGcDAAAA.',
['仙儿']='仙儿:BAACLgAFFH8PAAILAAQJSyQiBAClAQALAAQJSyQiBAClAQAuAAQKfxwAAgsACAkVI3MGACwDAAsACAkVI3MGACwDAAAA.',
['伊卡']='伊卡洛斯:BAAALgADCgkJDwAAAA==.',
['伐老']='伐老率:BAAALgAECgEJAgAAAA==.',
['依糯']='依糯:BAAALgADCgEJAQAAAA==.',
['依缘']='依缘:BAAALgADCgEJAQAAAA==.',
['依诺']='依诺:BAAALgAECgQJBQAAAA==.',
['傲灵']='傲灵爵:BAAALgAECgEJAQAAAA==.',
['傻虎']='傻虎吹牛王:BAAALgAECgIJBAAAAA==.',
['冰摇']='冰摇咖啡:BAAALgAECgEJAQAAAA==.冰摇绿茶:BAAALgAECgYJDQAAAA==.',
['冽冽']='冽冽风:BAAALgAECgQJBAAAAA==.',
['凤雏']='凤雏丶:BAAALgAECgYJBwAAAA==.',
['凰琊']='凰琊冰瞳:BAAALgAECgEJAQAAAA==.',
['别叫']='别叫我猪头:BAAALgAECgYJBwAAAA==.',
['勿负']='勿负时光:BAAALgAECgQJBAAAAA==.',
['十恶']='十恶灬不赦:BAAALgADCgYJDAAAAA==.',
['半步']='半步丨幽冥:BAAALgAFFAEJAQAAAA==.半步丨幽魂:BAAALgAECgMJAwAAAA==.半步丶天堂:BAAALgAFFAIJAwAAAA==.',
['南柯']='南柯丶一梦:BAAALgAECgMJBAAAAA==.',
['卡齐']='卡齐诺果冻:BAAALgAECgIJAgAAAA==.',
['双采']='双采增辉:BAABLgAECn8XAAIMAAcJlhHDGgC0AQAMAAcJlhHDGgC0AQAAAA==.',
['可爱']='可爱的小涩郎:BAABLgAECn8ZAAINAAcJnBhbIADfAQANAAcJnBhbIADfAQAAAA==.',
['右手']='右手的战释:BAAALgAECgEJAQAAAA==.',
['向异']='向异翅:BAAALgADCgYJBgAAAA==.',
['吼个']='吼个攻强:BAAALgAECgEJAgAAAA==.',
['呆弟']='呆弟弟:BAACLgAFFH8FAAIOAAIJ2RS7CQC6AAAOAAIJ2RS7CQC6AAAuAAQKfxsAAg4ACAn9HcULANoCAA4ACAn9HcULANoCAAAA.',
['呼呼']='呼呼是呼呼:BAAALgAECgkJEgABLgAFFAYJCwADAL0cAA==.',
['和中']='和中堂:BAAALgAECgUJDAAAAA==.',
['咩咩']='咩咩兔丶:BAAALgAECgcJBwAAAA==.',
['咸鱼']='咸鱼领袖:BAAALgAECgUJBQAAAA==.',
['哆咪']='哆咪:BAABLgAFFH8HAAIBAAMJexwEIAAaAQABAAMJexwEIAAaAQAAAA==.',
['喵也']='喵也喵不准:BAAALgAECggJBgAAAA==.',
['囝囡']='囝囡囡囝:BAAALgAECgIJAgAAAA==.',
['回灬']='回灬憶:BAAALgAECgQJBwAAAA==.',
['圣牧']='圣牧大仙:BAAALgAECgQJBAAAAA==.',
['圣龙']='圣龙大仙:BAAALgADCgUJBQAAAA==.',
['堕落']='堕落之焮:BAABLgAFFH8MAAMPAAQJjBvrAQDAAAAHAAMJcBmPGwAYAQAPAAMJrBLrAQDAAAAAAA==.',
['夜雨']='夜雨霖铃:BAAALgAECgIJAgAAAA==.',
['大偉']='大偉爺:BAAALgADCgcJBwAAAA==.',
['大鼻']='大鼻子奶牛:BAAALgAECgEJAQAAAA==.',
['奥格']='奥格之斧:BAAALgAECgcJBwAAAA==.',
['奶油']='奶油烩饭粒:BAABLgAFFH8HAAMQAAQJKSTEAAC/AQAQAAQJKSTEAAC/AQARAAIJFxPDCwCxAAAAAA==.',
['好身']='好身材看得见:BAAALgAECgIJAgAAAA==.',
['妖狐']='妖狐:BAAALgAECgEJAQAAAA==.',
['婺桐']='婺桐:BAAALgAECgMJAwAAAA==.',
['嫒之']='嫒之矢影歌:BAAALgADCgUJCAAAAA==.',
['宇之']='宇之守护者:BAAALgAECgIJBAAAAA==.',
['宇间']='宇间星痕:BAAALgADCgUJBQAAAA==.',
['寂寞']='寂寞为谁:BAAALgADCgcJBwAAAA==.',
['小小']='小小酱油瓶:BAAALgADCgEJAQAAAA==.',
['小德']='小德奶奶:BAAALgADCgUJBQAAAA==.',
['小熊']='小熊欧妮酱:BAAALgAECgkJCgAAAA==.',
['小篮']='小篮头:BAAALgAECgYJBgAAAA==.',
['小马']='小马佩德罗:BAAALgADCgQJBAAAAA==.',
['尘嚣']='尘嚣:BAAALgAECgYJCAAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8RAAIGAAUJrxKbBwAaAQAGAAUJrxKbBwAaAQAAAA==.',
['山碧']='山碧空:BAAALgAECgEJAQAAAA==.',
['帅气']='帅气的小涩郎:BAAALgAECgEJAQAAAA==.',
['希贝']='希贝尔:BAAALgADCgcJCQAAAA==.',
['幺妹']='幺妹来一发吧:BAAALgAECgkJCQAAAA==.',
['幻兽']='幻兽钠鲁:BAACLgAFFH8RAAMSAAUJpCARAgDtAQASAAUJpCARAgDtAQANAAMJGgPTCgC3AAAuAAQKfyAAAxIACQmwIcEMALcCABIABwk5IsEMALcCAA0ACQmBFIEUADoCAAAA.',
['幽灵']='幽灵黑骑:BAAALgAECgQJCgAAAA==.',
['德不']='德不尝尸米:BAAALgAECgEJAgAAAA==.',
['忧伤']='忧伤灬堕落:BAAALgAECgEJAQAAAA==.',
['忧落']='忧落:BAAALgAECgEJAQAAAA==.',
['恋静']='恋静曦:BAABLgAECn8UAAIDAAcJrB2idgDlAQADAAcJrB2idgDlAQAAAA==.',
['我加']='我加了洋葱:BAAALgAECgUJBgAAAA==.',
['战争']='战争雷霆:BAAALgAECgkJCQAAAA==.',
['拓丫']='拓丫霸丫硬:BAAALgAECgcJBwAAAA==.',
['搏命']='搏命叁少:BAAALgADCgUJBQAAAA==.',
['摇晃']='摇晃的红酒杯:BAAALgAECgYJEAAAAA==.',
['放学']='放学别走:BAAALgAECgYJDwAAAA==.',
['斩地']='斩地乄:BAAALgAECgMJAwAAAA==.',
['断水']='断水流阿哥:BAAALgAECgEJAgAAAA==.',
['晴川']='晴川夏:BAAALgAECgIJAgAAAA==.',
['暗香']='暗香无痕:BAAALgADCgEJAQAAAA==.',
['曰理']='曰理万基:BAAALgAECgEJAQAAAA==.',
['替补']='替补选手:BAAALgAECgEJAgAAAA==.',
['杀手']='杀手皇后:BAAALgAECgUJBQAAAA==.',
['杏仁']='杏仁核桃饼:BAAALgAECgEJAQAAAA==.',
['桃夭']='桃夭:BAAALgAECgMJAgAAAA==.',
['水之']='水之继承者:BAAALgAECgUJCgAAAA==.',
['永不']='永不落幕:BAAALgAFFAEJAQAAAA==.',
['永恒']='永恒炽阳:BAAALgAECgQJBAAAAA==.',
['沙丁']='沙丁鱼寿司:BAAALgAECgEJAQAAAA==.',
['沧海']='沧海日:BAAALgADCgcJCAAAAA==.',
['沧蝶']='沧蝶:BAABLgAECn8bAAMTAAcJnxgXKQDfAQATAAcJqBYXKQDfAQAUAAQJqRedOACjAAAAAA==.',
['法杖']='法杖弟弟:BAAALgAECgEJAQAAAA==.',
['流水']='流水无弦:BAAALgAECgYJBgAAAA==.',
['淡紫']='淡紫柔情:BAAALgAECgUJBQAAAA==.',
['清风']='清风青峰:BAACLgAFFH8OAAIDAAQJtRcDGABqAQADAAQJtRcDGABqAQAuAAQKfx0AAgMACQkmIQwKAHQDAAMACQkmIQwKAHQDAAAA.',
['温雷']='温雷萨:BAAALgAECgYJBgAAAA==.',
['灵摆']='灵摆精灵:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂得叹息:BAACLgAFFH8WAAMQAAYJyRxTAAAXAgAQAAYJyRxTAAAXAgARAAUJ6hEMBQCiAQAuAAQKfyIAAxEACAknIoAVAKICABEABwn8IoAVAKICABAABgmBH9oLAOQBAAAA.',
['烬翼']='烬翼龙吟:BAAALgADCgcJDgAAAA==.',
['燃烧']='燃烧吧少年:BAAALgAECgIJBAAAAA==.',
['牛牛']='牛牛不洗澡:BAAALgAECgcJCwABLgAFFAQJDwALAEskAA==.',
['牛的']='牛的草:BAAALgADCgUJBQAAAA==.',
['狂风']='狂风小小猎:BAAALgAECgEJAQAAAA==.',
['狐尔']='狐尔:BAAALgADCgEJAQAAAA==.',
['猫宁']='猫宁雪诺:BAAALgADCgcJCAAAAA==.',
['珊丷']='珊丷:BAAALgAFFAQJBAAAAA==.',
['瑪格']='瑪格丽特:BAAALgAECgEJAgAAAA==.',
['甄邪']='甄邪:BAAALgAECgcJCAAAAA==.',
['甜甜']='甜甜圈的甜:BAAALgAECgYJBwAAAA==.',
['白云']='白云边边:BAABLgAFFH8IAAIGAAQJwxEEDQAdAQAGAAQJwxEEDQAdAQAAAA==.',
['白小']='白小葵:BAAALgAECgIJBAAAAA==.',
['白糖']='白糖小飞牛:BAAALgAECgEJAQAAAA==.白糖还是甜:BAAALgADCgYJBQAAAA==.',
['白色']='白色的糖:BAAALgAECgQJBAAAAA==.',
['百变']='百变神君:BAAALgADCgQJBAAAAA==.',
['皇家']='皇家蕾手:BAAALgAECgYJBwAAAA==.',
['祥团']='祥团团:BAAALgAFFAQJBAAAAA==.',
['祭奠']='祭奠丶秋:BAAALgAFFAQJBAAAAA==.',
['秋意']='秋意中等你:BAAALgAECgYJBQAAAA==.',
['简丶']='简丶單:BAAALgADCgIJAgAAAA==.',
['简简']='简简单单:BAAALgADCgQJBAAAAA==.',
['粉红']='粉红骑士:BAAALgAECgEJAQAAAA==.',
['紫雨']='紫雨绯云:BAAALgAFFAIJAgAAAA==.',
['红烧']='红烧哈基米:BAAALgAECgYJDAAAAA==.',
['纳阿']='纳阿鲁之力:BAAALgAECgYJBwAAAA==.',
['缇娅']='缇娅莫:BAAALgADCgIJAgAAAA==.',
['美企']='美企鹅骑士:BAABLgAECn8ZAAMVAAcJfg9ldwCLAQAVAAcJfg9ldwCLAQAWAAEJNgHtGQAfAAAAAA==.',
['羲泽']='羲泽:BAAALgADCgEJAQAAAA==.',
['胡豆']='胡豆小甜甜:BAAALgAECgUJBQAAAA==.',
['苏西']='苏西玛丽苏:BAAALgAFFAIJAgAAAA==.',
['若邪']='若邪:BAAALgADCgYJBgAAAA==.',
['荡世']='荡世游僧:BAAALgADCgEJAQAAAA==.',
['萌萌']='萌萌德开水:BAAALgAECgEJAwAAAA==.',
['蒂法']='蒂法尼亞:BAAALgAECgQJCgAAAA==.',
['蓝色']='蓝色沃斯特:BAAALgAECgYJCAAAAA==.',
['蛮蛮']='蛮蛮哒:BAAALgAFFAIJBAAAAA==.',
['被盗']='被盗号了:BAAALgAECgEJAwAAAA==.',
['西门']='西门吹雪:BAABLgAECn8bAAIBAAcJPx3ZRAAmAgABAAcJPx3ZRAAmAgAAAA==.',
['豹子']='豹子头丶林冲:BAAALgAECgQJBAAAAA==.',
['贰月']='贰月丶流年:BAABLgAECn8bAAIBAAcJCx6vSwAQAgABAAcJCx6vSwAQAgAAAA==.',
['超级']='超级开胃萝卜:BAAALgADCgUJBQAAAA==.',
['辣眼']='辣眼:BAAALgADCgEJAQAAAA==.',
['迦叶']='迦叶:BAAALgADCgYJBgAAAA==.',
['邪伯']='邪伯伯:BAAALgAECgQJBAAAAA==.',
['酒酿']='酒酿萝卜皮:BAAALgAECgUJBQAAAA==.',
['酸檸']='酸檸檬:BAAALgAFFAIJAwAAAA==.',
['释槐']='释槐:BAABLgAFFH8IAAIXAAQJviLTAQCcAQAXAAQJvSLTAQCcAQAAAA==.',
['野性']='野性的咆哮:BAAALgAECgEJAgAAAA==.',
['铭血']='铭血:BAAALgAECgIJAgAAAA==.',
['阿卡']='阿卡贝拉:BAAALgADCgQJBAAAAA==.',
['阿斯']='阿斯忒瑞亚:BAAALgAECgYJBgAAAA==.',
['陆柒']='陆柒夜:BAAALgAECgEJAgAAAA==.',
['随风']='随风而逝丶:BAAALgADCgEJAQAAAA==.',
['雷碧']='雷碧城:BAAALgAECgMJAwAAAA==.',
['霸气']='霸气冲冠:BAAALgAFFAEJAgAAAA==.',
['霸道']='霸道的懿哥:BAAALgAECgQJBAAAAA==.',
['静幽']='静幽暗魔丶:BAAALgAECgQJBgAAAA==.静幽菠忒丶:BAAALgAECgEJAQAAAA==.',
['风语']='风语之魂:BAAALgADCgUJBwAAAA==.',
['风骚']='风骚猎神:BAAALgAECgEJAQAAAA==.',
['飘零']='飘零叶:BAAALgAECgMJAwAAAA==.',
['馒头']='馒头哥:BAAALgAECgYJCQAAAA==.',
['骑不']='骑不动马:BAAALgAECgUJBQAAAA==.',
['骨感']='骨感美人:BAABLgAFFH8GAAIVAAMJTRc4FAAGAQAVAAMJTRc4FAAGAQAAAA==.',
['魔法']='魔法模子:BAAALgAFFAIJAwAAAA==.',
['鸽子']='鸽子没了:BAAALgAECgEJAQAAAA==.',
['麥满']='麥满分:BAABLgAECn8aAAMYAAcJhRKIJgCjAQAYAAcJhRKIJgCjAQAZAAUJ8QIQUACUAAAAAA==.',
['麽哈']='麽哈:BAAALgAECgYJBgAAAA==.',
['黑暗']='黑暗神枪:BAAALgAECgMJAwAAAA==.',
['黑驴']='黑驴蹄子:BAAALgADCgQJBAAAAA==.',
['默默']='默默唔名:BAAALgAECgYJBwAAAA==.',
['龙吟']='龙吟月:BAAALgAFFAIJAwAAAA==.',
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
