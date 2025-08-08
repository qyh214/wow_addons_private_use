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
 local lookup = {'Druid-Restoration','Monk-Mistweaver','Paladin-Retribution','Monk-Windwalker','Druid-Balance','Warlock-Affliction','Shaman-Restoration','Rogue-Subtlety','DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','Evoker-Devastation','Warlock-Demonology','Warlock-Destruction','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Vengeance','Rogue-Assassination','Rogue-Outlaw','Priest-Shadow','Priest-Discipline','Monk-Brewmaster','Shaman-Elemental','Mage-Frost','Mage-Arcane','Mage-Fire','Paladin-Holy','Shaman-Enhancement','Warrior-Fury','Priest-Holy','Unknown-Unknown',}; local provider = {region='CN',realm='安威玛尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ci='Ciaomalfurio:BAABKgAFFH8IAAIBAAgI8xtUAgAuAgABAAgI8xtUAgAuAgAAAA==.Ciaomystery:BAABKgAFFH8GAAICAAYIawinEwALAQACAAYIawinEwALAQAAAA==.',Dr='Drago:BAAAKgAECgYIDwAAAA==.',Dy='Dyyi:BAAAKgAECgQIBAAAAA==.',El='Elam:BAAAKgADCgMIAwAAAA==.Ellenjoe:BAAAKgAECgMIBgAAAA==.',Ev='Evagreen:BAAAKgAECgIIBwAAAA==.',Fa='Faithdruid:BAAAKgAECggICAAAAA==.',Fb='Fb:BAABKgAFFH8wAAIDAAQIqRyaHwDqAAADAAQIqRyaHwDqAAAAAA==.',Ge='Geoffreyrush:BAAAKgAECgUIDAAAAA==.',Gz='Gzr:BAABKgAFFH8GAAIEAAYIwhJJCQBUAQAEAAYIwhJJCQBUAQAAAA==.',Ip='Iphone:BAAAKgAECgEIAQABKgAECggIFQAFAHIlAA==.',Ja='Javne:BAABKgAFFH8EAAIGAAQIhg7vCgDUAAAGAAQIhg7vCgDUAAAAAA==.',Ma='Maik:BAABKgAFFH8JAAIHAAYInBogDgDuAAAHAAYInBogDgDuAAAAAA==.',Ne='Nelg:BAAAKgAFFAgIBAAAAA==.',Ni='Nioline:BAEAKgAECggICAABKgAFFAgIBgAIAF8bAA==.',Oz='Ozma:BAABKgAFFH8fAAIJAAQI1CN+HgArAQAJAAQI1CN+HgArAQABKgAFFAQIIwAGAGsmAA==.',Ph='Phoebestar:BAAAKgADCgYIBgAAAA==.',Qi='Qingcai:BAAAKgAECgMIAwAAAA==.',St='Starrysky:BAAAKgAECggICQAAAA==.Staryy:BAABKgAECn85AAQKAAgI9R7CCAAwAgAKAAgI3xvCCAAwAgAJAAgIwhsVKQAUAgALAAcIfxtUEgDZAQAAAA==.',Su='Superyc:BAAAKgAECgUIBQAAAA==.',Th='Theshy:BAAAKgADCgQIBAAAAA==.',Ti='Tinko:BAAAKgAECgUIBQABKgAFFAYIGgAMAI0VAA==.',Yu='Yukn:BAABKgAFFH8GAAINAAMI0RcmCgDlAAANAAMI0RcmCgDlAAAAAA==.',Zi='Ziiki:BAABKgAFFH8LAAIBAAYIxBTLAgBiAQABAAYIxBTLAgBiAQAAAA==.Ziki:BAAAKgAFFAcIBAAAAA==.',['一把']='一把刀:BAAAKgADCgEIAQAAAA==.',['一言']='一言难尽额:BAAAKgAECgEIAQAAAA==.',['三个']='三个头一个大:BAAAKgAECggICgAAAA==.',['三克']='三克油:BAAAKgAECgYIBgAAAA==.',['三指']='三指弹天:BAAAKgAFFAIIAwAAAA==.',['中年']='中年起夜家:BAABKgAFFH8LAAIFAAMI6x1tJAAGAQAFAAMI6x1tJAAGAQAAAA==.',['中熊']='中熊猫:BAAAKgADCggICgAAAA==.',['丶听']='丶听悲伤的歌:BAAAKgAFFAgIBAAAAA==.',['九二']='九二四:BAAAKgAECgIIAgAAAA==.',['五花']='五花肉:BAAAKgAECgcIBwAAAA==.',['今晚']='今晚不睡:BAABKgAECn8VAAMNAAcIdg3jQADdAAANAAYIUgnjQADdAAAOAAYILQz6UwDDAAAAAA==.',['从小']='从小爱打滚丶:BAAAKgAFFAUIAQABKgAFFAgIGwALAFweAA==.',['以朕']='以朕之名:BAABKgAECn8hAAIPAAcIWREYJQAsAQAPAAcIWREYJQAsAQAAAA==.',['传说']='传说中的老大:BAAAKgADCggIBAAAAA==.',['余悦']='余悦:BAABKgAFFH8IAAIPAAQI6goTHwCEAAAPAAQI6goTHwCEAAAAAA==.',['余生']='余生长醉:BAACKgAFFH8GAAIQAAMItBDKGADNAAAQAAMItBDKGADNAAAqAAQKfxsAAhAACAieHFwNAD8CABAACAieHFwNAD8CAAAA.',['佟湘']='佟湘玉闯江湖:BAAAKgAECgIIAgAAAA==.',['你是']='你是猎物:BAABKgAECn8nAAIQAAgIchOeJABUAQAQAAgIchOeJABUAQAAAA==.',['保加']='保加利亚妖王:BAAAKgAECgMIAwAAAA==.',['光铸']='光铸德莱妮:BAAAKgAECgIIAgAAAA==.光铸霸气侧漏:BAAAKgAECgYIBgAAAA==.',['八月']='八月夜桂花:BAAAKgADCgIIAgAAAA==.',['内塔']='内塔尼亚胡:BAAAKgADCggICAAAAA==.',['冰极']='冰极似火:BAAAKgAECggICAAAAA==.',['冷面']='冷面杀手:BAABKgAFFH8GAAIRAAYIDxQ7EABkAQARAAYIDxQ7EABkAQAAAA==.',['凯撒']='凯撒:BAABKgAFFH8WAAISAAMInyFDDwAdAQASAAMInyFDDwAdAQABKgAFFAYIMgADANEkAA==.',['刀客']='刀客啦啦噜:BAABKgAECn8XAAMTAAgIHRvDMQDmAQATAAgI3hjDMQDmAQAUAAgIXBfBCgCbAQAAAA==.',['刃落']='刃落无声:BAACKgAFFH8KAAMIAAgIJR44AQDTAQAIAAYI9CE4AQDTAQAVAAQIXhKGEQA5AQAqAAQKfyoABBYABwhCIMQKAHwBAAgABggWHaYVAJsBABYABgjWH8QKAHwBABUAAgh8Dls8AIAAAAAA.',['刘玲']='刘玲珑:BAAAKgADCgEIAQAAAA==.',['初見']='初見:BAABKgAECn8WAAINAAgIcyF7BACbAgANAAgIcyF7BACbAgAAAA==.',['功夫']='功夫萨:BAAAKgAECgUIBQAAAA==.',['勺子']='勺子:BAAAKgADCgYIBgAAAA==.',['十分']='十分坏:BAAAKgAECgIIAgAAAA==.',['千年']='千年之梦:BAAAKgADCgMIAwAAAA==.',['午夜']='午夜歌声:BAAAKgAECgEIAQAAAA==.',['半夏']='半夏丨生梦:BAACKgAFFH8KAAMXAAYITxasCgBVAQAXAAYITxasCgBVAQAYAAQIWAx9GADOAAAqAAQKfxYAAxgACAi4ELM+AB0BABgACAi4ELM+AB0BABcAAQg2BBt8ACIAAAAA.',['南湾']='南湾:BAAAKgAECgcIDAAAAA==.',['卡瓦']='卡瓦一:BAAAKgAECggIEAAAAA==.',['卡索']='卡索弥亚:BAABKgAECn8mAAMDAAcIWxO9hQCMAQADAAcIWxO9hQCMAQAPAAcIEgV4RwBwAAAAAA==.',['厄鲁']='厄鲁特乌云:BAAAKgAECgYIBgAAAA==.',['古力']='古力娜扎:BAAAKgAECgcIBwAAAA==.',['只是']='只是开门的:BAAAKgADCgMIAwAAAA==.',['叮叮']='叮叮当当:BAABKgAECn8VAAMFAAgIciUrBQDzAgAFAAgIciUrBQDzAgABAAIIrQu0dwBVAAAAAA==.',['呆呆']='呆呆鸭:BAABKgAFFH8MAAMCAAgIDAtnCQCWAQACAAgIDAtnCQCWAQAZAAQInASjCQBuAAAAAA==.',['周三']='周三大决战:BAABKgAFFH8IAAMFAAgIiyEhAACTAgAFAAcImCMhAACTAgABAAEIMyUwGgBxAAAAAA==.',['咕咕']='咕咕牛牛:BAAAKgAECgQIBgABKgAFFAMIBwAaAGQZAA==.',['咕德']='咕德猫宁:BAAAKgAECgIIAgAAAA==.',['哦侯']='哦侯:BAAAKgAECggIDwAAAA==.',['喔抱']='喔抱歉:BAAAKgAECgcIBwAAAA==.',['喵喵']='喵喵女:BAAAKgAECggICAABKgAFFAgIHQAPAHkbAA==.',['喵里']='喵里喵气:BAAAKgADCgIIAgAAAA==.',['嘲风']='嘲风:BAABKgAECn8gAAIMAAgIpBlYGQDtAQAMAAgIpBlYGQDtAQAAAA==.',['图垃']='图垃扬:BAAAKgADCgIIAgAAAA==.',['圣剑']='圣剑翔:BAAAKgAFFAgIBAAAAA==.',['圣吉']='圣吉列斯:BAAAKgAECgMIAwAAAA==.',['圣斗']='圣斗士七曜:BAACKgAFFH8GAAIPAAYIkhQsAgB0AQAPAAYIkhQsAgB0AQAqAAQKfxYAAw8ACAjDG8kQAAMCAA8ACAjBGskQAAMCAAMACAh9E2OEAI4BAAEqAAUUCAgIAAMAdBYA.',['圣魔']='圣魔之血:BAAAKgAECgMIAwAAAA==.',['在那']='在那遥远地方:BAAAKgADCgEIAgAAAA==.',['夏莲']='夏莲:BAAAKgAECgcICgABKgAECggIHAAHAMsiAA==.',['夜露']='夜露法:BAAAKgADCgIIAgAAAA==.',['大桥']='大桥未久酱:BAAAKgADCgEIAQAAAA==.',['大流']='大流狼:BAAAKgAECgQIBAAAAA==.',['大颗']='大颗粒丶:BAABKgAFFH8FAAMbAAQIoBEUGQCxAAAbAAMIoBEUGQCxAAAcAAIIKQgAAAAAAAAAAA==.',['天使']='天使笑傻了:BAABKgAECn82AAQdAAcITSIUJQAXAgAdAAcI/h8UJQAXAgAcAAUIuSFtFQCNAQAbAAIIRxf/lgBfAAAAAA==.',['奈奈']='奈奈丶落:BAAAKgADCggIFgAAAA==.',['奶油']='奶油血滴子:BAAAKgAECggICAAAAA==.',['奶茶']='奶茶小怪兽:BAABKgAECn8XAAMNAAgIqxViFgDNAQANAAgIqxViFgDNAQAGAAQIuASRMgBmAAAAAA==.',['如月']='如月爱:BAAAKgAFFAQIBAAAAA==.',['孫晓']='孫晓羙:BAAAKgAFFAQIBAAAAA==.',['孫筱']='孫筱美:BAAAKgAECggICAAAAA==.',['宛若']='宛若新生:BAAAKgADCgMIAwAAAA==.',['寂寞']='寂寞时光:BAABKgAFFH8IAAIdAAgIowt0AwAJAgAdAAgIowt0AwAJAgAAAA==.',['射光']='射光了吗:BAAAKgAECgEIAQAAAA==.',['射天']='射天射地射人:BAABKgAECn8XAAMRAAgI+QkTPgAtAQAQAAgI1wh7fwA3AQARAAgItggTPgAtAQAAAA==.',['小宝']='小宝的宠物:BAAAKgAECggIDAAAAA==.',['小帕']='小帕米:BAAAKgAECgcIBwABKgAECggIHAAHAMsiAA==.',['小德']='小德永不为宠:BAAAKgADCggICAAAAA==.',['小心']='小心肝儿:BAAAKgADCggIDgAAAA==.',['小木']='小木勿爱:BAABKgAECn8XAAICAAgInCL4BAC0AgACAAgInCL4BAC0AgABKgAECggIHAAHAMsiAA==.',['小牛']='小牛牛:BAACKgAFFH8HAAIaAAMIZBm3EgDTAAAaAAMIZBm3EgDTAAAqAAQKfx0AAxoACAjiHJ0WADUCABoACAjiHJ0WADUCAAcACAgnH+0eABwCAAAA.',['布鲁']='布鲁斯塔:BAABKgAFFH8KAAMRAAMIKgegIABsAAARAAMIMgagIABsAAAQAAIIaQfdJwBqAAAAAA==.',['平淡']='平淡:BAAAKgADCgIIAgAAAA==.',['幻影']='幻影紫霞:BAABKgAECn8mAAIDAAcIkB7lSgARAgADAAcIkB7lSgARAgABKgAFFAgICgATAAIRAA==.',['幽魂']='幽魂:BAABKgAECn8VAAIQAAcIlRHzWgBJAQAQAAcIlRHzWgBJAQAAAA==.',['康康']='康康熊:BAABKgAFFH8KAAIFAAYIUBg0FgBnAQAFAAYIUBg0FgBnAQABKgAFFAgIEQABAD4jAA==.',['开心']='开心果丶黑铁:BAABKgAECn8WAAIeAAgI5Q1UHwBmAQAeAAgI5Q1UHwBmAQAAAA==.',['恩择']='恩择:BAABKgAECn8nAAIcAAgIsRg8CADkAQAcAAgIsRg8CADkAQAAAA==.',['恶魔']='恶魔恩择:BAABKgAECn8XAAITAAgI2Q3BVQDzAAATAAgI2Q3BVQDzAAAAAA==.',['情傷']='情傷:BAACKgAFFH8IAAMfAAQIQB6pDQDwAAAfAAQIQB6pDQDwAAAHAAQIIhCZMwCsAAAqAAQKfyIAAgcACAgpFF9FAHMBAAcACAgpFF9FAHMBAAAA.',['想想']='想想丨云曦:BAAAKgAECgQIBAAAAA==.',['愤怒']='愤怒的小菜菜:BAAAKgAECggICAAAAA==.',['我先']='我先拯救世界:BAAAKgAFFAIIAgAAAA==.',['我容']='我容易么:BAAAKgAECgYICAABKgAECggIKQAbAFYhAA==.',['拂面']='拂面那一刹那:BAAAKgAECgEIAQAAAA==.',['描边']='描边大师:BAABKgAECn8VAAMRAAgIchvVLQCrAQAQAAcIPRyuVQCwAQARAAYI/hjVLQCrAQAAAA==.',['提里']='提里奥拂丁:BAABKgAFFH8FAAIDAAUIkSEEJQBWAQADAAUIkSEEJQBWAQAAAA==.',['揺落']='揺落月:BAAAKgAECgcIBwAAAA==.',['撸自']='撸自身:BAAAKgAECggIEgAAAA==.',['救赎']='救赎流氓:BAAAKgAECgQIBAAAAA==.',['文咏']='文咏珊:BAAAKgADCggIDgAAAA==.',['斩怒']='斩怒风:BAAAKgAECgYIEwAAAA==.',['新远']='新远古枭兽:BAAAKgAECgUICgABKgAECgcIHQACANEMAA==.',['无声']='无声消逝:BAAAKgAECgEIAQAAAA==.',['无尘']='无尘:BAECKgAFFH8wAAIEAAYIwiKWBwCCAQAEAAYIwiKWBwCCAQAqAAQKf0gAAgQACAhlJYsIALUCAAQACAhlJYsIALUCAAEqAAUUBAgpABAA+SQA.',['无悬']='无悬无念:BAABKgAECn8bAAIBAAgIEiInBwCXAgABAAgIEiInBwCXAgABKgAECggIHAAHAMsiAA==.',['无敌']='无敌杨贝贝:BAAAKgADCggICAAAAA==.无敌的大象:BAAAKgADCggIDwAAAA==.',['无法']='无法无天如花:BAAAKgAECgcICgAAAA==.',['日久']='日久见人格:BAAAKgADCggICAAAAA==.',['旧梦']='旧梦:BAAAKgAECgUICwAAAA==.',['星云']='星云:BAAAKgAFFAYIAgAAAA==.',['星河']='星河:BAAAKgAECgMIAwAAAA==.',['春风']='春风花开:BAABKgAFFH8MAAMDAAgIYRyxBQB0AgADAAgIYRyxBQB0AgAeAAQIzB2BAwAUAQAAAA==.',['暗黑']='暗黑战舰:BAAAKgADCggICAAAAA==.',['暴力']='暴力释加牟尼:BAABKgAECn8vAAMgAAgIvhp+FwAYAgAgAAgIvhp+FwAYAgASAAcIJg8VKAB5AQAAAA==.',['曦月']='曦月红尘:BAAAKgAECgEIAQAAAA==.',['曲中']='曲中人:BAEBKgAFFH8uAAIaAAQImyLGCQAtAQAaAAQImyLGCQAtAQABKgAFFAQIKQAQAPkkAA==.',['最后']='最后那只蛙:BAAAKgAECgEIAQAAAA==.',['月影']='月影光辉:BAAAKgAECggICAAAAA==.',['月染']='月染青黛:BAAAKgAECgYIDAAAAA==.',['木头']='木头桩子:BAABKgAECn8ZAAIhAAgIxB7ODgBUAgAhAAgIxB7ODgBUAgABKgAECggIHAAHAMsiAA==.',['木蜀']='木蜀黍:BAAAKgAECggIEgABKgAECggIHAAHAMsiAA==.',['杀手']='杀手影子:BAAAKgADCgMIAwAAAA==.',['李一']='李一桐:BAAAKgAECgcIDQAAAA==.',['李依']='李依桐:BAAAKgAECgQIBwAAAA==.',['条形']='条形码:BAACKgAFFH8FAAIOAAUIBxEmFgBSAQAOAAUIBxEmFgBSAQAqAAQKfyAAAw4ABwi5F845AIUBAA4ABgi5F845AIUBAA0AAwhgF71ZAIoAAAAA.',['来吧']='来吧死鬼:BAABKgAFFH8JAAIUAAMI3hRFEQC5AAAUAAMI3hRFEQC5AAABKgAFFAYIGgAMAI0VAA==.',['来杯']='来杯冰可乐:BAABKgAFFH8QAAQbAAYIsRqfBACbAQAbAAYIsRqfBACbAQAdAAQIvxHrHwDWAAAcAAQIVA2MLwCmAAAAAA==.',['林雷']='林雷巴鲁克:BAAAKgADCggIFQAAAA==.',['柏林']='柏林:BAABKgAFFH8MAAMOAAYIcSKEDgCmAQAOAAYIdx6EDgCmAQAGAAMIHw8HCgDmAAAAAA==.',['染晓']='染晓轩:BAAAKgAECgQIBAAAAA==.',['树不']='树不高:BAAAKgAECggICQAAAA==.',['格拉']='格拉海德宗师:BAABKgAECn8dAAMCAAcI0Qz+RwAeAQACAAcI0Qz+RwAeAQAZAAIIqwnuIwBHAAAAAA==.',['桔叶']='桔叶:BAAAKgAECgYIDAAAAA==.',['梅歆']='梅歆芮:BAAAKgAECgYIBwAAAA==.',['梦想']='梦想的彼岸:BAAAKgADCgIIAgAAAA==.',['梦甜']='梦甜甜:BAAAKgAFFAQIAgAAAA==.',['樱桃']='樱桃小朋友:BAAAKgAECggIEwAAAA==.',['止战']='止战之殇:BAAAKgADCggICAAAAA==.',['永歲']='永歲飄零:BAAAKgADCggICAAAAA==.',['江南']='江南追忆:BAAAKgADCggIAwAAAA==.',['沐焱']='沐焱浴血:BAEBKgAFFH8UAAICAAgISBiUBADsAQACAAgISBiUBADsAQAAAA==.',['沐雪']='沐雪琳风:BAAAKgAECggIDgABKgAECggIHAAHAMsiAA==.',['法海']='法海你不懂爱:BAAAKgAECgUIBQAAAA==.',['泰蓝']='泰蓝德语风:BAABKgAFFH8VAAMBAAYIOBpSBgCzAQABAAYIOBpSBgCzAQAFAAQItBYIHQDLAAAAAA==.',['流动']='流动幻夜:BAAAKgAECggIDAAAAA==.',['流夜']='流夜:BAAAKgADCgUIBQAAAA==.',['流星']='流星红尘:BAAAKgAECgIIAwAAAA==.',['浮冰']='浮冰掠影:BAAAKgAECgMIAwAAAA==.',['浮萩']='浮萩:BAACKgAFFH8OAAIYAAMIzRvhCAD0AAAYAAMIzRvhCAD0AAAqAAQKfykAAhgACAgeIQ4IAJwCABgACAgeIQ4IAJwCAAEqAAUUBggaAAwAjRUA.',['海因']='海因里斯:BAABKgAFFH8GAAIDAAMI6x7vNwAMAQADAAMI6x7vNwAMAQAAAA==.',['深井']='深井冰:BAAAKgAECgQIBAAAAA==.',['清流']='清流:BAAAKgAECgIIAgAAAA==.',['温酒']='温酒醉人:BAAAKgAECgEIAQAAAA==.',['火焰']='火焰冰激凌:BAAAKgAFFAgIBAAAAA==.',['烎鈥']='烎鈥蟲:BAEAKgAECgYIBgABKgAFFAgIBgAIAF8bAA==.',['熊猫']='熊猫小妹:BAAAKgAECggICAAAAA==.熊猫炼奶:BAAAKgAECgYIEwAAAA==.',['熊的']='熊的力量:BAAAKgAECgMIAwAAAA==.',['爱在']='爱在西元前:BAABKgAFFH8GAAIVAAYIEwxcDwBcAQAVAAYIEwxcDwBcAQAAAA==.',['爱蹦']='爱蹦的半夏丶:BAABKgAFFH8KAAITAAYIwxoRDgCiAQATAAYIwxoRDgCiAQAAAA==.',['牧不']='牧不转睛:BAABKgAECn8VAAQYAAgIGhu3JwCWAQAYAAgIKBG3JwCWAQAhAAYIKBjlQAA2AQAXAAIImQwQdAAzAAAAAA==.',['牧人']='牧人:BAAAKgADCgEIAQAAAA==.',['狂熊']='狂熊:BAAAKgAECgcIBwAAAA==.',['狂鸟']='狂鸟:BAAAKgAECggICAAAAA==.',['狡黠']='狡黠的路亚西:BAABKgAFFH8MAAMGAAQIDyD5DADBAAAGAAQIDyD5DADBAAAOAAEIrByfLABVAAAAAA==.',['独享']='独享忧愁:BAAAKgAECggIDAAAAA==.',['甘邓']='甘邓梅:BAAAKgAECgcIBwAAAA==.',['白萌']='白萌萌:BAAAKgADCgcIBwAAAA==.',['百发']='百发百仲:BAAAKgAECgYIBgAAAA==.',['皖美']='皖美小萨:BAAAKgAECgYIBgAAAA==.',['盘古']='盘古:BAABKgAFFH8RAAMcAAQIiR/oHQD2AAAcAAMIIhroHQD2AAAdAAQI1RtQGQDeAAABKgAFFAQIIwAGAGsmAA==.',['相信']='相信你的龙:BAACKgAFFH8aAAIMAAYIjRUYCQDQAQAMAAYIjRUYCQDQAQAqAAQKfyAAAgwACAgXHrkFAF8CAAwACAgXHrkFAF8CAAAA.',['知命']='知命:BAAAKgAECgYIEAAAAA==.',['矮猎']='矮猎王:BAABKgAECn8XAAIRAAgIBxbHKADGAQARAAgIBxbHKADGAQAAAA==.',['石头']='石头姣姣:BAAAKgAECgQIBAAAAA==.',['神神']='神神秘秘:BAAAKgAECgMIAwAAAA==.',['秃头']='秃头爸爸:BAABKgAFFH8LAAIdAAYI/CFKCQCoAQAdAAYI/CFKCQCoAQAAAA==.',['竹汐']='竹汐:BAABKgAECn8cAAMHAAgIyyIJCwCVAgAHAAgIyyIJCwCVAgAaAAEIWgegfQAkAAAAAA==.',['第七']='第七次日落:BAACKgAFFH8GAAIQAAMIRiGfIQAEAQAQAAMIRiGfIQAEAQAqAAQKfycAAhAACAj+ITUGALECABAACAj+ITUGALECAAAA.',['索拉']='索拉卡:BAAAKgAECgQIBAAAAA==.',['紫云']='紫云风:BAAAKgADCgcIBwAAAA==.',['约翰']='约翰康斯坦丁:BAAAKgAECggICAAAAA==.',['绯红']='绯红女巫:BAAAKgAFFAIIAgAAAA==.',['肤如']='肤如凝脂:BAAAKgAECgIIAgAAAA==.',['艾丽']='艾丽西亚韩:BAAAKgAECgEIAQABKgAECgcIHQACANEMAA==.',['艾斯']='艾斯艾木:BAAAKgAECggIDgAAAA==.',['花园']='花园雪:BAABKgAFFH8IAAMHAAQICReJKADUAAAHAAQICReJKADUAAAaAAQI4QjbDADGAAAAAA==.',['花开']='花开富贵菇:BAAAKgAECggICAAAAA==.',['莫慌']='莫慌:BAAAKgAECgUIBQAAAA==.',['菲林']='菲林的御守:BAABKgAFFH8IAAIgAAgI5QoMBwACAgAgAAgI5QoMBwACAgAAAA==.',['菲玲']='菲玲丶珑翔:BAAAKgADCggICAAAAA==.',['萧炎']='萧炎:BAAAKgAECgIIAgAAAA==.',['萨贝']='萨贝宁萨乌鸡:BAABKgAECn8XAAIHAAgILRtEJgD2AQAHAAgILRtEJgD2AQAAAA==.',['蒙奇']='蒙奇利德:BAAAKgAFFAQIBAAAAA==.蒙奇淼淼:BAAAKgADCggICAAAAA==.',['蒶里']='蒶里尔:BAAAKgAECgEIAQAAAA==.',['蓝色']='蓝色的缘分:BAAAKgAECgYIBgAAAA==.',['薰风']='薰风南渐:BAAAKgAECgUIBQAAAA==.',['虚空']='虚空之力:BAAAKgAECgIIAgAAAA==.',['蛋蛋']='蛋蛋也忧伤:BAABKgAECn8kAAITAAgI3BpCDgAWAgATAAgI3BpCDgAWAgAAAA==.',['血洗']='血洗少林:BAABKgAECn8VAAICAAgIERYBKgCwAQACAAgIERYBKgCwAQAAAA==.',['言一']='言一一:BAEAKgADCgcIBwABKgAFFAgIBgAIAF8bAA==.',['言倩']='言倩:BAEAKgAFFAEIAQABKgAFFAgIBgAIAF8bAA==.',['言邱']='言邱:BAEAKgADCgYIBwABKgAFFAgIBgAIAF8bAA==.',['變形']='變形大師:BAABKgAECn8XAAMFAAgIjhEBVgBiAQAFAAgIjhEBVgBiAQABAAIIoA8IcQBmAAAAAA==.',['豆爹']='豆爹帝:BAAAKgAECgYIBgAAAA==.',['贝露']='贝露塞布布:BAABKgAFFH8IAAMBAAQIbBZuHADAAAABAAQIbBZuHADAAAAFAAQIawSyIgCqAAAAAA==.',['起名']='起名好累:BAAAKgADCgEIAQAAAA==.',['超神']='超神:BAAAKgAECgUIBQAAAA==.',['迪诺']='迪诺:BAAAKgADCggIDAAAAA==.',['迷路']='迷路的下野:BAABKgAECn9AAAIBAAgIhBtBCAD/AQABAAgIhBtBCAD/AQAAAA==.',['追求']='追求开心:BAAAKgAECgQIBgAAAA==.追求放假:BAABKgAECn8VAAIgAAcI0xkwKwCLAQAgAAcI0xkwKwCLAQAAAA==.',['逗逗']='逗逗毅吖:BAABKgAFFH8IAAITAAUICB7cGwAhAQATAAUICB7cGwAhAQAAAA==.',['酷儿']='酷儿啼拉丝:BAAAKgAECgUIBwAAAA==.',['酷酷']='酷酷冰:BAAAKgAECgYIBgAAAA==.酷酷骑:BAAAKgAFFAIIAgAAAA==.',['阿克']='阿克里德:BAAAKgADCgEIAQAAAA==.',['阿尼']='阿尼姆斯:BAAAKgAFFAQIAQAAAA==.',['阿斯']='阿斯卡拉亲王:BAAAKgAECgUIBQAAAA==.',['陪我']='陪我看无尽海:BAAAKgADCgEIAQAAAA==.',['雨夜']='雨夜语风:BAAAKgADCgEIAQAAAA==.',['霁月']='霁月爫:BAABKgAFFH8IAAIcAAgIdwgFCgDGAQAcAAgIdwgFCgDGAQAAAA==.',['霸氣']='霸氣側漏:BAAAKgAECgIIAgAAAA==.',['非洲']='非洲张学友:BAAAKgAECgEIAQAAAA==.',['顺手']='顺手牵杨:BAAAKgAECgcIBwAAAA==.',['风之']='风之丹丹:BAAAKgADCgMIAwAAAA==.风之无追:BAAAKgADCgIIAgAAAA==.风之猎神:BAAAKgADCgcICQAAAA==.',['风吻']='风吻滕飞:BAAAKgAECgQIBAAAAA==.',['风暴']='风暴卡卡:BAABKgAECn8dAAMRAAgI/Bj7OgBqAQAQAAgIixV2TgByAQARAAgIHxb7OgBqAQAAAA==.',['风雨']='风雨同舟:BAAAKgAECgQIBAAAAA==.风雨红尘:BAABKgAFFH8FAAMOAAIIswwoKABtAAAOAAIIpwgoKABtAAANAAEIWwuFHABBAAAAAA==.',['风鳞']='风鳞啸歌:BAEBKgAFFH8QAAIMAAMI5R2sFwAKAQAMAAMI5R2sFwAKAQABKgAFFAQIKQAQAPkkAA==.',['驭兽']='驭兽者孙晓美:BAABKgAFFH8IAAIQAAgI7BakBQBCAgAQAAgI7BakBQBCAgAAAA==.',['魑魅']='魑魅魍魉鬼怪:BAAAKgAFFAIIAgAAAA==.',['魔女']='魔女鹫鹫:BAAAKgADCggICAAAAA==.',['魔法']='魔法牛牛:BAABKgAFFH8GAAIbAAYIZhy4AwC4AQAbAAYIZhy4AwC4AQAAAA==.',['黄裁']='黄裁缝:BAAAKgAFFAYIAgAAAA==.',['黑夜']='黑夜小王子:BAAAKgADCgMIAwAAAA==.',['黑马']='黑马:BAAAKgADCggICQAAAA==.',['黑骑']='黑骑士七曜:BAABKgAECn8eAAILAAgIZBvkEwAHAgALAAgIZBvkEwAHAgABKgAFFAgIAgAiAAAAAA==.',['龍姬']='龍姬:BAAAKgAECggIEQAAAA==.',['龙之']='龙之骑:BAABKgAECn8YAAILAAgIwh7ICwBqAgALAAgIwh7ICwBqAgAAAA==.',['龙城']='龙城夜如花:BAABKgAECn8XAAIPAAgINwzrJgAcAQAPAAgINwzrJgAcAQAAAA==.龙城夜如雪:BAAAKgAECggIEQAAAA==.',['龙涵']='龙涵:BAAAKgAECggIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end