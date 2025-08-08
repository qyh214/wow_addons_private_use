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
 local lookup = {'Priest-Discipline','Priest-Holy','Priest-Shadow','Paladin-Retribution','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Warrior-Protection','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','Warlock-Destruction','Mage-Frost','Mage-Arcane','Mage-Fire','Warlock-Affliction','Warrior-Arms','Warlock-Demonology','DeathKnight-Frost','DeathKnight-Blood','Unknown-Unknown','Paladin-Holy',}; local provider = {region='CN',realm='布莱克摩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ah='Ahnqirajlr:BAAAKgAECggICAAAAA==.',Al='Aldyalr:BAAAKgAECgUIBwAAAA==.Alydia:BAAAKgAECggIDwAAAA==.',An='Ang:BAABKgAFFH8GAAQBAAIIVga+FwAbAAABAAEImAG+FwAbAAACAAEIRwA9RAAXAAADAAEI6QDaHQATAAAAAA==.',Av='Avrill:BAAAKgAECgQIBgAAAA==.',Bl='Blackink:BAAAKgADCgQIAQAAAA==.',Ca='Castlee:BAAAKgAECgIIAgAAAA==.',Co='Conia:BAABKgAFFH8IAAIEAAgI7RhYBgBXAgAEAAgI7RhYBgBXAgAAAA==.',Ge='Geiniyichui:BAAAKgADCggICAAAAA==.',Il='Ilo:BAAAKgAECgMIBAAAAA==.',Ka='Kasieyo:BAAAKgADCgEIAQAAAA==.Kayanon:BAABKgAFFH8GAAMFAAYI4R7pIQAVAQAFAAQIdiTpIQAVAQAGAAIIhB3PHgCyAAAAAA==.',Ke='Kee:BAABKgAFFH8OAAMBAAQI0RYFDQDtAAABAAQI0RYFDQDtAAADAAQIKhutEADbAAABKgAFFAgIBgACAKsLAA==.',Lo='Loki:BAAAKgAECggICQAAAA==.',Ma='Magicmoon:BAAAKgAFFAQIBAAAAA==.',Me='Mercurys:BAAAKgAECggICwAAAA==.',Mi='Minhao:BAAAKgAECggIAQAAAA==.',Nt='Ntingale:BAAAKgAECgQIBAAAAA==.',Pl='Playerasdfgh:BAABKgAECn8aAAIHAAgI3x6KFABnAgAHAAgI3x6KFABnAgAAAA==.',Ro='Romeoe:BAAAKgAECgYIBgAAAA==.',Sl='Slina:BAAAKgAECgQIBAAAAA==.',Ti='Tio:BAAAKgAECggICAAAAA==.',Wa='Warspite:BAABKgAFFH8GAAIEAAYI0xwNGQCVAQAEAAYI0xwNGQCVAQAAAA==.',Wo='Wolfback:BAAAKgAECgEIAQAAAA==.',Ze='Zern:BAABKgAFFH8LAAMIAAYIIR6DAQDmAQAIAAYIhxyDAQDmAQAJAAEI6x+xTABMAAABKgAFFAgICAAIABcdAA==.',['一地']='一地树影:BAAAKgAECgcIBwAAAA==.',['一笑']='一笑百媚:BAAAKgAECggIEQAAAA==.',['一色']='一色三节高:BAAAKgADCgQICAAAAA==.',['一路']='一路向西牛啊:BAAAKgAFFAIIAgAAAA==.',['七枷']='七枷社:BAABKgAFFH8GAAIKAAYIBQ4OEgDbAAAKAAYIBQ4OEgDbAAAAAA==.',['三千']='三千越甲吞吴:BAAAKgAECgcIDwAAAA==.',['三暗']='三暗刻:BAAAKgAECggIDgAAAA==.',['三色']='三色双龙会:BAAAKgAECgcIBwAAAA==.',['三顾']='三顾周郎赤臂:BAAAKgADCgMIAwAAAA==.',['不再']='不再蓝的深蓝:BAAAKgAFFAgIBAAAAA==.',['不碎']='不碎之靈:BAACKgAFFH8SAAMKAAMIRR30GwAPAQAKAAMIRR30GwAPAQALAAIIwQX9JwA7AAAqAAQKfxgAAgoACAh2HWkKACQCAAoACAh2HWkKACQCAAAA.',['不要']='不要打我的脸:BAAAKgAECgYIDwAAAA==.',['丨黯']='丨黯灬斩焱丶:BAABKgAECn8WAAMMAAgINh0PHgBQAgAMAAgINh0PHgBQAgANAAEIABo0YgBLAAAAAA==.',['丶乱']='丶乱世妖姬:BAAAKgAECgYIBgAAAA==.',['丶椛']='丶椛晓霜:BAABKgAFFH8VAAMOAAgIIxrSAwBlAgAOAAgI+BjSAwBlAgAPAAYIWRfDBAA5AQAAAA==.',['丶海']='丶海拉:BAAAKgADCggICQAAAA==.',['丶舞']='丶舞幽影:BAABKgAFFH8IAAIMAAUIkhHMFwDkAAAMAAUIkhHMFwDkAAAAAA==.丶舞幽炫:BAACKgAFFH8NAAMQAAgIcQ8zBQBeAQAQAAgIcQ8zBQBeAQARAAQIRxaJAwDFAAAqAAQKfy4ABBAACAjXDfE5AF0BABAACAjXDfE5AF0BABEACAi4D2QPADcBABIABQhBETw7AOoAAAAA.丶舞幽静:BAAAKgAECggICAAAAA==.丶舞钢管:BAAAKgAFFAgIAgAAAA==.',['乌云']='乌云遇皎月:BAAAKgADCgQIBAAAAA==.',['乌瑟']='乌瑟尔:BAAAKgAECgQIBAAAAA==.',['乖筱']='乖筱筱:BAAAKgAECggIEgAAAA==.',['乡下']='乡下老土:BAAAKgAFFAQIBAAAAA==.',['乱成']='乱成一片:BAAAKgAECgEIAQAAAA==.',['云云']='云云:BAABKgAFFH8WAAMIAAgIthxwBACPAQAJAAYIvx0BCAC6AQAIAAgIShlwBACPAQAAAA==.',['云兄']='云兄:BAAAKgAECgIIAwAAAA==.',['什么']='什么都好:BAABKgAFFH8GAAITAAYIuQ2nEQDyAAATAAYIuQ2nEQDyAAABKgAFFAgIDQAEAOEYAA==.',['任真']='任真:BAAAKgADCggICAAAAA==.',['任飘']='任飘渺:BAAAKgADCggICAAAAA==.',['优菈']='优菈:BAAAKgAECggIDwAAAA==.',['伤心']='伤心难过痛苦:BAAAKgADCgQICAAAAA==.',['倒数']='倒数从零开始:BAAAKgAFFAIIAgAAAA==.',['偶踏']='偶踏凡间:BAAAKgADCggICAAAAA==.',['傻满']='傻满满:BAAAKgAECggIDwAAAA==.',['光丶']='光丶陨:BAABKgAFFH8ZAAIEAAQInSO7KgA8AQAEAAQInSO7KgA8AQAAAA==.',['光晕']='光晕丶:BAAAKgAFFAIIBAAAAA==.',['克剌']='克剌斯:BAAAKgAECgEIAgAAAA==.',['兔妖']='兔妖妖:BAABKgAFFH8SAAMBAAMIzgx7HwClAAABAAMIzgx7HwClAAADAAMIOAPvFQBwAAAAAA==.',['八百']='八百米大长腿:BAAAKgADCgQIBAAAAA==.',['再动']='再动灬开枪了:BAABKgAECn8WAAIEAAYIIQvj3ADsAAAEAAYIIQvj3ADsAAAAAA==.',['冰火']='冰火之殇:BAAAKgAECgIIAgAAAA==.',['冷刺']='冷刺:BAAAKgADCggICAAAAA==.',['凤舞']='凤舞者:BAAAKgADCgUIBQAAAA==.',['动物']='动物王国:BAAAKgAECgcIDQAAAA==.',['千雨']='千雨千傲:BAAAKgAECgEIAQAAAA==.',['半仙']='半仙:BAAAKgAECgYIBgAAAA==.',['卑微']='卑微的凡人:BAAAKgAECggIDAAAAA==.',['南星']='南星:BAABKgAFFH8IAAIUAAgIkSE3AQDDAgAUAAgIkSE3AQDDAgAAAA==.',['南梦']='南梦芽:BAAAKgAECgUIBQAAAA==.',['卡九']='卡九万:BAAAKgAECgUIBQAAAA==.',['卡拉']='卡拉赞之夜:BAAAKgADCggICgAAAA==.',['去事']='去事宛如梦幻:BAAAKgADCgEIAQAAAA==.',['古尓']='古尓単:BAAAKgADCggIDQAAAA==.',['吃丨']='吃丨货:BAAAKgAECgYIBgAAAA==.',['吉祥']='吉祥兔兔:BAABKgAFFH8GAAMVAAIIdAEyLQA1AAAVAAIIdAEyLQA1AAAWAAEIWQAJSwALAAAAAA==.',['名字']='名字太短:BAABKgAECn8hAAIXAAgIxhvTAgD/AQAXAAgIxhvTAgD/AQABKgAFFAgIAgAWAAIWAA==.',['吔傷']='吔傷悲:BAAAKgADCgEIAQAAAA==.',['吴二']='吴二蛋:BAABKgAFFH8FAAIUAAUIvBD2IQD4AAAUAAUIvBD2IQD4AAAAAA==.',['咖啡']='咖啡嘤:BAACKgAFFH8/AAICAAgIqB+vAQCEAgACAAgIqB+vAQCEAgAqAAQKfx4AAgIACAjyI0YGALMCAAIACAjyI0YGALMCAAAA.',['哈缪']='哈缪尔:BAAAKgADCgcIBwAAAA==.',['哈都']='哈都跟:BAAAKgAECggIDAAAAA==.',['哓丶']='哓丶枫叶:BAAAKgAFFAMIAwAAAA==.',['喧嚣']='喧嚣尘世间:BAAAKgAECgYICQAAAA==.',['喵大']='喵大大人:BAACKgAFFH9EAAMCAAgIxx2LBAD7AQACAAgIxx2LBAD7AQABAAMIAwuIHQCHAAAqAAQKfz0AAwIACAhXJSIEANMCAAIACAhXJSIEANMCAAEACAgrDnQzAFIBAAAA.',['四暗']='四暗刻:BAAAKgADCggICQAAAA==.',['团团']='团团:BAAAKgADCggICAAAAA==.',['圣光']='圣光会怜悯你:BAAAKgADCggICwAAAA==.圣光痞子:BAAAKgADCgUIBQAAAA==.',['地狱']='地狱血契:BAABKgAFFH8KAAMUAAYITRWNAgCwAQAUAAYITRWNAgCwAQAYAAQITws7DADJAAAAAA==.',['堕落']='堕落是我大号:BAAAKgADCggICAAAAA==.',['增幅']='增幅器:BAAAKgAFFAMIAwAAAA==.',['多米']='多米尼克:BAAAKgADCggIEgAAAA==.',['夜之']='夜之辉煌:BAAAKgAFFAQIBAAAAA==.',['夜幕']='夜幕舞者:BAAAKgAECgUIBQAAAA==.',['大可']='大可猫:BAABKgAECn8gAAMJAAgI/RXDLQCrAQAJAAgI/RXDLQCrAQAIAAEIRARdCgEqAAAAAA==.',['大胡']='大胡子老头:BAAAKgAECggIEAAAAA==.',['天命']='天命人:BAACKgAFFH9FAAIRAAgIrxb4AQCBAQARAAgIrxb4AQCBAQAqAAQKfy8AAxEACAjhJFwEAAsCABEACAjhJFwEAAsCABAABwicEF0bAI8AAAAA.',['天天']='天天和奶茶:BAAAKgAECgMIAwAAAA==.',['天涯']='天涯客:BAAAKgAFFAYIBAAAAA==.',['天王']='天王盖地虎:BAAAKgAECgMIAwAAAA==.',['天翼']='天翼翔羽:BAAAKgADCggIDAAAAA==.',['天驱']='天驱魔刀:BAAAKgAFFAYIBAABKgAFFAgIFgAOANkUAA==.',['奥法']='奥法之尘:BAABKgAFFH8IAAIZAAQIbSKpCADgAAAZAAQIbSKpCADgAAAAAA==.',['妖五']='妖五妖六:BAAAKgADCggIAQAAAA==.',['媞娜']='媞娜:BAAAKgAECgUIBAAAAA==.',['孙柔']='孙柔心:BAAAKgAFFAIIBAAAAA==.',['守四']='守四方:BAAAKgAECgcIDwAAAA==.',['安妮']='安妮女王大人:BAACKgAFFH8IAAIUAAYIwRkSFABlAQAUAAYIwRkSFABlAQAqAAQKfxoAAxQACAjhGfUqAMoBABQACAh5F/UqAMoBABoABwgTExQmAGgBAAAA.',['小乔']='小乔爱流水:BAAAKgADCgIIAgAAAA==.',['小侏']='小侏夜行:BAAAKgAECgQIBAAAAA==.',['小兔']='小兔叽丶:BAACKgAFFH8OAAIQAAMIWCbYBQBPAQAQAAMIWCbYBQBPAQAqAAQKfyQAAhAACAi2JIMDAOECABAACAi2JIMDAOECAAAA.',['小土']='小土夜行:BAACKgAFFH8KAAIKAAMI/SHSFwAiAQAKAAMI/SHSFwAiAQAqAAQKfygAAgoACAicIYkNAIICAAoACAicIYkNAIICAAAA.',['小娥']='小娥:BAAAKgAECgYIDgAAAA==.',['小小']='小小石头姐:BAAAKgAECgUIBwAAAA==.',['小所']='小所长:BAAAKgADCggICAAAAA==.',['小榄']='小榄懂王:BAAAKgADCgEIAQAAAA==.',['小熊']='小熊夜行:BAACKgAFFH8FAAISAAMIZgvjFgCyAAASAAMIZgvjFgCyAAAqAAQKfxkAAxIACAjRFaImAKwBABIACAjRFaImAKwBABEAAQj0AQAAAAAAAAAA.',['小牛']='小牛夜行:BAACKgAFFH8WAAIEAAMIJRoHQQDuAAAEAAMIJRoHQQDuAAAqAAQKfz4AAgQACAhzI70IALMCAAQACAhzI70IALMCAAAA.',['小狐']='小狐夜行:BAAAKgAECggIDwAAAA==.',['小狗']='小狗夜行:BAAAKgAECggIEAAAAA==.',['小舵']='小舵:BAAAKgAECgQIBAAAAA==.',['小船']='小船:BAACKgAFFH8RAAICAAMIkgmyLQCOAAACAAMIkgmyLQCOAAAqAAQKfxwAAgIACAgTFpIqAIABAAIACAgTFpIqAIABAAAA.',['小芳']='小芳足浴:BAAAKgAECggICAAAAA==.',['小菜']='小菜一碟:BAAAKgADCgcIBwAAAA==.',['小锋']='小锋:BAAAKgAECggICQAAAA==.',['小飞']='小飞象:BAAAKgAFFAYIBAAAAA==.',['小鬼']='小鬼夜巡:BAACKgAFFH8KAAIIAAMIZBRfGADPAAAIAAMIZBRfGADPAAAqAAQKfzAAAggACAhGIOodAEwCAAgACAhGIOodAEwCAAAA.小鬼夜息:BAAAKgAECgIIAgAAAA==.小鬼夜游:BAACKgAFFH8SAAIHAAYI9xmyEQCNAQAHAAYI9xmyEQCNAQAqAAQKfzUAAwcACAjGIKoEAIYCAAcACAjGIKoEAIYCABsABQgpEIcgAL4AAAAA.小鬼夜行:BAACKgAFFH8KAAMaAAUI/RphCADBAAAUAAUI/RrRHQAZAQAaAAMI+hFhCADBAAAqAAQKf00AAxoACAipIoEGAIoCABoACAiiIYEGAIoCABQACAiAGoEgAAICAAAA.小鬼夜袭:BAACKgAFFH8GAAIMAAMIfgnlMgC0AAAMAAMIfgnlMgC0AAAqAAQKfzkAAwwACAicG9oiAPABAAwACAicG9oiAPABAA0AAQjjBL5tAA4AAAAA.小鬼尾行:BAABKgAECn8eAAMOAAgIXRRUNgClAQAOAAcI5xFUNgClAQAZAAQIqhDENQAWAQAAAA==.',['少年']='少年时:BAAAKgADCggICQAAAA==.',['尛菜']='尛菜一碟:BAAAKgAFFAIIAgAAAA==.',['尼古']='尼古拉斯丶晋:BAAAKgAECgMIAwAAAA==.',['巨石']='巨石强森:BAAAKgADCggICAAAAA==.',['帅求']='帅求的很:BAABKgAFFH8IAAIEAAgIawrYEgDFAQAEAAgIawrYEgDFAQAAAA==.',['帕里']='帕里斯汀:BAAAKgADCggIFAAAAA==.',['幻云']='幻云采风:BAAAKgAECgYIEAAAAA==.',['幽客']='幽客:BAAAKgAFFAQIAwAAAA==.',['幽月']='幽月黯魅影:BAAAKgADCggICAAAAA==.',['库阿']='库阿萨:BAAAKgAECggIEgAAAA==.',['建材']='建材王哥:BAAAKgAECgUIBQAAAA==.',['弥婭']='弥婭:BAAAKgAECgUICQAAAA==.',['影光']='影光月蝕:BAACKgAFFH8GAAIOAAYIZRHhHgDZAAAOAAYIZRHhHgDZAAAqAAQKfyAAAw4ACAjCFiIsANcBAA4ACAjCFiIsANcBABkABQjjDtw6APUAAAAA.',['彼岸']='彼岸錀回:BAAAKgADCggICAAAAA==.',['御前']='御前一品猫:BAAAKgADCggIDwAAAA==.',['微风']='微风艾儿:BAABKgAECn8UAAIIAAgILhZiVQCxAQAIAAgILhZiVQCxAQAAAA==.',['德智']='德智体美:BAAAKgAECgYIBwAAAA==.',['心航']='心航何处:BAAAKgAFFAQIBAAAAA==.',['念你']='念你如故:BAAAKgAECgMIBQAAAA==.',['恶魔']='恶魔步伐:BAAAKgAECgUIBQAAAA==.',['愤怒']='愤怒的张园园:BAAAKgAECgMIAwAAAA==.',['憨豆']='憨豆豆:BAACKgAFFH8dAAIGAAYIswsbDQDHAAAGAAYIswsbDQDHAAAqAAQKfxsAAgYACAhIEagsAHUBAAYACAhIEagsAHUBAAAA.',['我要']='我要暴走:BAAAKgAECgcIBwAAAA==.我要烧香:BAABKgAECn9IAAIQAAgIKhjaCQCjAQAQAAgIKhjaCQCjAQABKgAFFAcIMQAKAKoZAA==.',['扣达']='扣达布妞:BAABKgAFFH8IAAIcAAgIHBYpAwD5AQAcAAgIHBYpAwD5AQAAAA==.',['拉面']='拉面阿宝:BAABKgAECn8hAAILAAgInhtKHgD6AQALAAgInhtKHgD6AQAAAA==.',['拉风']='拉风老爷车:BAAAKgAECgMIAwAAAA==.',['挖鼻']='挖鼻大婶:BAAAKgADCggICAAAAA==.',['文尨']='文尨:BAAAKgAECggICAAAAA==.',['断尾']='断尾熊:BAAAKgAECgUIBQAAAA==.',['星丶']='星丶湮:BAABKgAFFH8OAAMBAAQINxDODQCZAAABAAMIsQ/ODQCZAAACAAQIOAi3LgCLAAAAAA==.星丶痕:BAABKgAFFH8lAAMFAAgI5RCyFQBsAQAFAAcIjhGyFQBsAQAGAAQIjgpdGgDOAAAAAA==.星丶陨:BAABKgAFFH8bAAMIAAMIpx29FAD7AAAIAAMIGxy9FAD7AAAJAAMIpBsTIwDkAAABKgAFFAgIAwAdAAAAAA==.',['星星']='星星妹妹:BAAAKgAECgUIBgAAAA==.',['星澜']='星澜:BAAAKgAECgIIAgAAAA==.',['星空']='星空下的傳奇:BAAAKgADCggICAAAAA==.',['晓丶']='晓丶枫叶:BAABKgAFFH8GAAIPAAMITAOOEwBgAAAPAAMITAOOEwBgAAAAAA==.',['晓白']='晓白:BAAAKgAECggIEQAAAA==.晓白浮生梨:BAAAKgAECgQIBAAAAA==.',['普通']='普通和尚:BAAAKgAECggIEQAAAA==.',['暗影']='暗影天驰:BAAAKgAECgUIBQAAAA==.',['暮丶']='暮丶汐:BAAAKgAFFAQIBAAAAA==.',['暮汐']='暮汐:BAABKgAFFH8UAAQUAAYIsSEUAQD0AQAUAAYI8h4UAQD0AQAYAAUI8BlZCADmAAAaAAIIhRslFwCQAAAAAA==.',['有些']='有些不对劲:BAABKgAFFH8GAAIQAAYI2RlKCgCFAQAQAAYI2RlKCgCFAQAAAA==.',['有天']='有天:BAAAKgAECgEIAQAAAA==.',['末日']='末日审判者:BAAAKgAECgYIBgAAAA==.',['李华']='李华梅:BAAAKgAECggIEQAAAA==.',['柠檬']='柠檬灬米粒:BAAAKgADCgMIAwAAAA==.',['树影']='树影一地:BAAAKgADCggICAAAAA==.',['根浴']='根浴圣手:BAABKgAFFH8HAAIQAAYIZREZDgBFAQAQAAYIZREZDgBFAQAAAA==.',['梦幻']='梦幻天涯:BAABKgAFFH8IAAIGAAgIeRPXBADdAQAGAAgIeRPXBADdAQAAAA==.',['森淼']='森淼:BAAAKgAECgYIBgAAAA==.',['森琳']='森琳:BAAAKgADCggICAAAAA==.',['欧洛']='欧洛尼斯:BAAAKgAECgIIAgAAAA==.',['欲為']='欲為诸佛龍象:BAABKgAFFH8VAAIHAAQIDBGYNADEAAAHAAQIDBGYNADEAAAAAA==.',['欲爲']='欲爲诸佛龍象:BAABKgAFFH8JAAIEAAMI+haCRgDhAAAEAAMI+haCRgDhAAAAAA==.',['歪歪']='歪歪妞妞:BAAAKgADCgQIBAAAAA==.',['死亡']='死亡猎灵人:BAAAKgAECgYIBgAAAA==.',['水元']='水元子:BAABKgAFFH8IAAMWAAYIQSLmCADmAQAWAAYIQSLmCADmAQAVAAII7AUXIQA7AAAAAA==.',['求生']='求生之路:BAABKgAFFH8GAAIMAAMI7x1MIgD1AAAMAAMI7x1MIgD1AAAAAA==.',['汐汐']='汐汐洋洋:BAAAKgADCgEIAQAAAA==.',['沿途']='沿途有弦:BAAAKgAECgIIAgAAAA==.',['注意']='注意看我细节:BAABKgAECn8VAAMJAAgI/RkJNABhAQAIAAcIyhb5ZwB6AQAJAAcI8hIJNABhAQAAAA==.',['洛依']='洛依:BAAAKgAECgIIAgAAAA==.',['浮殇']='浮殇年华:BAABKgAFFH8UAAIHAAgIGBxfBwAcAgAHAAgIGBxfBwAcAgAAAA==.',['海拉']='海拉:BAAAKgAECgcICgAAAA==.',['深度']='深度徘徊:BAAAKgAECgcIBwAAAA==.',['混沌']='混沌灭世:BAAAKgAECgQIBgAAAA==.',['清水']='清水无香:BAAAKgAFFAIIAgAAAA==.',['清爽']='清爽一夏:BAAAKgAECgcIDAAAAA==.',['满江']='满江红:BAAAKgAECgEIAQAAAA==.',['火焰']='火焰之舞:BAABKgAFFH8MAAMCAAYIGxzHCACaAQACAAYIGxzHCACaAQADAAYIchQ7CgBdAQAAAA==.',['灵之']='灵之影:BAAAKgAECgMIBAAAAA==.',['烈烈']='烈烈西风摧人:BAAAKgAECgYICAAAAA==.',['無聊']='無聊的寶寶:BAABKgAFFH8NAAMVAAYIGx+IAwDCAQAVAAYIGx+IAwDCAQAXAAUIhRD3FQAEAQAAAA==.',['無関']='無関風月:BAABKgAFFH8HAAIMAAcISAZhDgBhAQAMAAcISAZhDgBhAQAAAA==.',['熊掌']='熊掌来一发:BAAAKgADCgMIAwAAAA==.',['爱浪']='爱浪漫球球:BAAAKgAECggICAAAAA==.爱浪漫甜甜:BAAAKgAECgIIAgAAAA==.',['爱莉']='爱莉希雅:BAAAKgAECgQIBQAAAA==.',['狗子']='狗子:BAAAKgADCggICAAAAA==.',['狡猾']='狡猾的张圆圆:BAAAKgAECgQICAAAAA==.',['狼德']='狼德虚名:BAAAKgAECggICAAAAA==.',['狼牙']='狼牙峰峰拳:BAAAKgADCgYIBgAAAA==.',['猩红']='猩红女王:BAAAKgADCgEIAQAAAA==.',['献身']='献身于神:BAACKgAFFH9CAAIOAAgI7iAQBABcAgAOAAgI7iAQBABcAgAqAAQKfxoAAg4ACAjQJQYEAO8CAA4ACAjQJQYEAO8CAAAA.',['王总']='王总说换一批:BAAAKgAFFAQIBAABKgAFFAgIDwABAM4XAA==.',['玲珑']='玲珑:BAAAKgAECgIIAgAAAA==.',['瑞奇']='瑞奇:BAAAKgAECgYIBgAAAA==.',['白月']='白月光:BAAAKgADCggICAAAAA==.',['皓月']='皓月云天:BAABKgAFFH8IAAIEAAgI/BlfDAAGAgAEAAgI/BlfDAAGAgAAAA==.',['皮圣']='皮圣:BAABKgAFFH8KAAIOAAYI1xNdDgBtAQAOAAYI1xNdDgBtAQAAAA==.',['神蛊']='神蛊温皇:BAAAKgADCggIDQAAAA==.',['秋月']='秋月无双:BAABKgAFFH8IAAIMAAgIdxjZBQBWAgAMAAgIdxjZBQBWAgAAAA==.',['米勒']='米勒:BAAAKgADCgQIBAAAAA==.',['粉马']='粉马尾蝙蝠猫:BAABKgAECn8aAAIMAAgI9BsPLAC1AQAMAAgI9BsPLAC1AQAAAA==.',['素手']='素手芳華:BAACKgAFFH9BAAMJAAgIrB6MBgAAAgAJAAgIhxyMBgAAAgAIAAYIXR9bCwC5AQAqAAQKfxoAAwgACAjDHwE3ABkCAAgACAizHQE3ABkCAAkABghFHG0+ACsBAAAA.',['紫燕']='紫燕:BAAAKgADCgEIAQAAAA==.',['红点']='红点波:BAAAKgADCggICAAAAA==.',['红玉']='红玉:BAAAKgAECgQIBAAAAA==.',['红魔']='红魔经典:BAAAKgADCggICAAAAA==.',['纳兰']='纳兰祺:BAAAKgAECgcIEgAAAA==.',['给我']='给我看看:BAABKgAFFH8IAAIMAAgIpgyaCQDiAQAMAAgIpgyaCQDiAQAAAA==.',['绿玥']='绿玥儿:BAABKgAECn8lAAIMAAgI2RlXKwAHAgAMAAgI2RlXKwAHAgAAAA==.',['群殴']='群殴小朋友:BAABKgAECn8cAAIVAAgIfST7BgC9AgAVAAgIfST7BgC9AgAAAA==.',['翠烟']='翠烟莉:BAAAKgADCgYIBgAAAA==.',['翡翠']='翡翠幻境:BAAAKgAFFAIIBAAAAA==.',['翱翔']='翱翔孤浪:BAAAKgAECggICQAAAA==.',['职业']='职业输出:BAAAKgAECgIIAgAAAA==.',['胡椒']='胡椒蛮馋:BAAAKgADCggICQAAAA==.',['胡胡']='胡胡涂涂:BAABKgAECn8cAAIEAAgI8B+DPgAzAgAEAAgI8B+DPgAzAgAAAA==.',['脆皮']='脆皮打工人:BAAAKgAFFAIIAgAAAA==.',['艾丽']='艾丽卡:BAAAKgAECggICwAAAA==.',['苍狼']='苍狼与白鹿:BAAAKgAFFAMIAwAAAA==.',['苍白']='苍白的正义:BAABKgAFFH8GAAIHAAYIWhLKFwBfAQAHAAYIWhLKFwBfAQAAAA==.',['茉酱']='茉酱紫:BAABKgAFFH8FAAIEAAMI3x0OTgDTAAAEAAMI3x0OTgDTAAAAAA==.',['茜茜']='茜茜子:BAAAKgAECggICAAAAA==.',['草药']='草药君别杀我:BAAAKgAFFAIIAgAAAA==.',['莉亚']='莉亚徳琳:BAAAKgADCgEIAQAAAA==.',['莎总']='莎总:BAACKgAFFH8JAAISAAYIYRiECABlAQASAAYIYRiECABlAQAqAAQKfywAAxIACAhlJdQBAOACABIACAhlJdQBAOACABEAAginGk0eAHsAAAAA.',['莫丶']='莫丶甘丶娜:BAAAKgAECgUICgAAAA==.',['菩萨']='菩萨蛮:BAAAKgADCgcICAAAAA==.',['萨摩']='萨摩开英勇:BAAAKgAECgUIBQAAAA==.',['萨维']='萨维:BAAAKgAECgcICwAAAA==.',['蓝卡']='蓝卡:BAAAKgAECgYICAAAAA==.',['蝶舞']='蝶舞飘麟:BAAAKgAECgMIAwAAAA==.',['蠢豆']='蠢豆豆:BAAAKgAECgYIBgAAAA==.',['西江']='西江月:BAAAKgAECgMIBgAAAA==.',['西瓜']='西瓜勒个太狼:BAAAKgAECgMIBQAAAA==.',['认真']='认真的人:BAAAKgAFFAIIAgAAAA==.认真的矮子:BAAAKgADCggICAAAAA==.认真的美德:BAAAKgAFFAQIBAAAAA==.',['诸神']='诸神无念:BAAAKgAFFAQIBAAAAA==.',['豪鬼']='豪鬼:BAABKgAFFH8JAAMOAAgI8xsrCADYAQAOAAcIRBsrCADYAQAZAAEIESBbJwBUAAAAAA==.',['豬豬']='豬豬點點:BAABKgAFFH8IAAMTAAYIjCRNBQDnAQATAAYIjCRNBQDnAQAEAAIIeAuJRgBzAAAAAA==.',['赛利']='赛利卡:BAACKgAFFH8eAAIVAAgIVyG0AABXAQAVAAgIVyG0AABXAQAqAAQKfzIAAxUACAjqJtcCAAADABUACAjqJtcCAAADABYACAjbIpgRAGsCAAAA.',['赤色']='赤色灬龙骑:BAAAKgADCggIEAAAAA==.',['超绝']='超绝萨满:BAAAKgAECgEIAQAAAA==.',['跟屁']='跟屁虫虫:BAABKgAECn8nAAIKAAgItQ9zUAA7AQAKAAgItQ9zUAA7AQAAAA==.',['蹄围']='蹄围三尺三:BAAAKgAECggIEgAAAA==.',['轩辕']='轩辕箭:BAABKgAFFH8KAAMJAAIIBg8GHwB8AAAJAAIIBg8GHwB8AAAIAAEI0wZ8UQAyAAAAAA==.',['辣条']='辣条小妹:BAAAKgAECgYIBgAAAA==.',['边城']='边城导游:BAAAKgAECgcICwAAAA==.边城游侠:BAAAKgADCggIDwAAAA==.',['达比']='达比:BAAAKgAECgUIBQAAAA==.',['过敏']='过敏世界:BAABKgAFFH8HAAIeAAQIVBOHCADQAAAeAAQIVBOHCADQAAABKgAFFAgIFwATAAYfAA==.',['迷人']='迷人的烟圈:BAABKgAECn8YAAMaAAgIhQzOKgBPAQAaAAgIhQzOKgBPAQAUAAEIZQf0mAAeAAAAAA==.',['遮眼']='遮眼司机:BAACKgAFFH8yAAIMAAgIuxY7CwDVAQAMAAgIuxY7CwDVAQAqAAQKfyUAAgwACAjxIEUUAF8CAAwACAjxIEUUAF8CAAAA.',['邂逅']='邂逅:BAAAKgADCgYIBgAAAA==.',['采蘑']='采蘑菇的小熊:BAABKgAECn8WAAISAAgI0xrAHQDvAQASAAgI0xrAHQDvAQAAAA==.',['金剛']='金剛:BAAAKgAECgUIBQAAAA==.',['銀月']='銀月黯羽:BAAAKgADCggICwAAAA==.',['鐵觀']='鐵觀音:BAAAKgAFFAIIAQAAAA==.',['钟丽']='钟丽婉:BAACKgAFFH8NAAQTAAgICxZnAgBoAQATAAYIbBhnAgBoAQAeAAIIyhAxDACWAAAEAAEIvBf6hgBKAAAqAAQKfxYAAgQACAgHH7RAAC0CAAQACAgHH7RAAC0CAAAA.钟丽宛:BAAAKgAFFAIIAgAAAA==.',['银河']='银河野性:BAAAKgAECgUIBQAAAA==.',['閃耀']='閃耀貓貓:BAAAKgAECgIIAgAAAA==.',['阿亚']='阿亚索:BAAAKgADCggIEAAAAA==.',['阿诗']='阿诗蕶:BAAAKgAECggIEQAAAA==.',['雨妙']='雨妙妙:BAAAKgADCggICAAAAA==.',['雨文']='雨文宝儿:BAAAKgAECgYIBgAAAA==.',['雷吉']='雷吉:BAAAKgADCggICAAAAA==.',['霜之']='霜之高兴:BAABKgAFFH8GAAIHAAYIjAUHHgAuAQAHAAYIjAUHHgAuAQAAAA==.',['須烬']='須烬歡:BAAAKgADCggIDQAAAA==.',['顾村']='顾村小峥峥:BAAAKgAFFAQIBAAAAA==.',['风之']='风之天下:BAAAKgADCgcICwAAAA==.风之狩猎:BAAAKgADCgUIBQAAAA==.风之风之幻想:BAAAKgADCgYIBgAAAA==.',['风清']='风清揚:BAAAKgAECggIDgAAAA==.',['风过']='风过云端:BAABKgAFFH8HAAIEAAIIMBGVbwCLAAAEAAIIMBGVbwCLAAAAAA==.',['飛起']='飛起壹脚尖:BAAAKgAFFAMIAwAAAA==.',['駑鳯']='駑鳯:BAAAKgADCggICAAAAA==.',['马维']='马维拉一山丘:BAAAKgADCgMIAwAAAA==.',['高级']='高级活动假人:BAAAKgAECgEIAgAAAA==.',['魔幻']='魔幻星辰:BAAAKgADCgMIAwAAAA==.',['魔灵']='魔灵:BAAAKgADCgIIAgAAAA==.',['魔纹']='魔纹:BAAAKgAECgMIBQAAAA==.',['魔鬼']='魔鬼克星:BAABKgAFFH8KAAMZAAYI3BXmBAAWAQAZAAYI3BXmBAAWAQAOAAQIiwhRFwDLAAAAAA==.',['鳕鱼']='鳕鱼堡:BAABKgAFFH8IAAMUAAQIOBf+EADiAAAUAAQIOBf+EADiAAAYAAEIAAABJAAAAAAAAA==.',['麦乐']='麦乐迪:BAAAKgADCgQIBAAAAA==.',['黎明']='黎明的勇气:BAAAKgAECggIEAAAAA==.',['黑叔']='黑叔叔:BAAAKgADCggICAAAAA==.',['黑白']='黑白洛:BAAAKgADCgEIAQAAAA==.黑白玄月:BAABKgAECn8UAAIHAAgI7BWJYABEAQAHAAgI7BWJYABEAQAAAA==.',['黯萌']='黯萌老爷:BAAAKgAECggICAAAAA==.',['龙渊']='龙渊:BAABKgAFFH8IAAIOAAgIVwxDBgAhAgAOAAgIVwxDBgAhAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end