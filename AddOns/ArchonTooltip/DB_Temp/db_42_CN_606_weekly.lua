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
 local lookup = {'Mage-Frost','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','Druid-Restoration','Druid-Guardian','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','Mage-Arcane','Warlock-Destruction','Warlock-Demonology','Priest-Discipline','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance',}; local provider = {region='CN',realm='古达克',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alecto:BAAAKgAECgQIBAAAAA==.',Ci='Cibo:BAAAKgAECgYIBgAAAA==.Ciri:BAAAKgAECgcIBwAAAA==.',Eu='Eunomia:BAABKgAECn8XAAIBAAcISxa4KgBoAQABAAcISxa4KgBoAQAAAA==.',Go='Goosh:BAAAKgAFFAYIAwAAAA==.',Ir='Irene:BAAAKgAECggIEgAAAA==.',Ji='Jinx:BAAAKgAECgcICAAAAA==.',Ke='Keiran:BAAAKgAFFAQIBAAAAA==.Kevinsu:BAAAKgADCgMIAwAAAA==.',Kl='Klaw:BAABKgAECn8YAAMCAAgIHRm9DQDKAQACAAcIaxq9DQDKAQADAAgIyRHsOgCIAQAAAA==.',Yl='Ylz:BAAAKgAECgUIBQAAAA==.Ylzsm:BAAAKgAECggIDwAAAA==.',['一头']='一头脏辫:BAAAKgADCgYIBgAAAA==.',['不明']='不明死亡:BAAAKgADCggIBgAAAA==.',['丨锄']='丨锄骑不义丨:BAABKgAFFH8GAAIEAAYINR4yEgDLAQAEAAYINR4yEgDLAQAAAA==.',['丶泪']='丶泪残:BAAAKgAECgQIBAAAAA==.',['乐成']='乐成:BAACKgAFFH8OAAMFAAMImiISGwDJAAAFAAII1iMSGwDJAAAGAAEI1Q2KCAAnAAAqAAQKfyAAAwUACAhJHsYNAGACAAUACAhJHsYNAGACAAYAAQhkAAAAAAAAAAAA.',['付付']='付付:BAAAKgAFFAgIBAAAAA==.',['傲娇']='傲娇的憨憨:BAAAKgADCgIIAgAAAA==.',['克丽']='克丽丝叮:BAAAKgAECggICAAAAA==.克丽丝奵:BAAAKgADCgIIAgAAAA==.',['克罗']='克罗玛什:BAACKgAFFH8IAAIHAAQIASL3GAAdAQAHAAQIASL3GAAdAQAqAAQKfy8ABAgACAj3IugJAJwCAAgACAj3IugJAJwCAAcAAgiaHWGJAJsAAAkAAwgtGTAYAIMAAAAA.',['兜率']='兜率陀天:BAAAKgAECgIIAgAAAA==.',['冰冻']='冰冻的邪恶:BAAAKgADCgIIAgAAAA==.',['冰糖']='冰糖雪梨:BAAAKgADCgMIAwAAAA==.',['列斯']='列斯尼奶奶:BAAAKgAFFAQIBAAAAA==.',['厄运']='厄运之君:BAAAKgAECgcIDAAAAA==.',['变形']='变形小迪:BAAAKgAECgIIAgAAAA==.',['可乐']='可乐:BAABKgAFFH8XAAIKAAYIQxyEDACeAQAKAAYIQxyEDACeAQAAAA==.',['可可']='可可小牛牛:BAAAKgADCggICAAAAA==.可可脂:BAAAKgADCggICAAAAA==.',['哈哈']='哈哈淡定:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光照照宝藏:BAAAKgAECgYIDQAAAA==.',['在下']='在下毛毛雨:BAAAKgAECgUIBQAAAA==.',['堕落']='堕落暗影:BAACKgAFFH8gAAILAAgIphvkAwBtAgALAAgIphvkAwBtAgAqAAQKfyoAAwsACAj7IsMLAI0CAAsACAhyIcMLAI0CAAwAAgj+HkVQAKgAAAAA.',['夜之']='夜之女:BAAAKgAECgYIBgAAAA==.',['大橙']='大橙子:BAAAKgADCgYICQAAAA==.',['大鑫']='大鑫丶:BAAAKgAECgcIBwAAAA==.',['天神']='天神飞侠:BAAAKgADCgUIBQAAAA==.',['天魔']='天魔灬天魔:BAAAKgAECgcICwAAAA==.',['奈文']='奈文摩尔:BAAAKgAECgYIDQAAAA==.',['奶潮']='奶潮汹涌:BAAAKgAECgIIAgAAAA==.',['审判']='审判之眼:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞如歌:BAABKgAFFH8GAAIEAAYI/g15IwBeAQAEAAYI/g15IwBeAQAAAA==.',['富贵']='富贵小火锅:BAAAKgAECgMIAgAAAA==.',['小宝']='小宝灬牛宝:BAAAKgAFFAIIAwAAAA==.',['小小']='小小丶法:BAAAKgADCgEIAQAAAA==.',['小恐']='小恐龙:BAAAKgAECgEIAQAAAA==.',['小手']='小手菇凉:BAABKgAECn8YAAMNAAgISRhZGwDqAQANAAgISRhZGwDqAQAOAAYIsAiPXgCcAAAAAA==.',['尜尜']='尜尜泷:BAAAKgAFFAMIAwAAAA==.',['幸福']='幸福笑笑:BAAAKgAECgYIBwAAAA==.',['引英']='引英雄尽折腰:BAAAKgAECgIIAgAAAA==.',['彡卖']='彡卖萌小熊熊:BAAAKgADCgIIAgAAAA==.',['彦斌']='彦斌:BAABKgAFFH8NAAMPAAMIUBdWLADVAAAPAAMIUBdWLADVAAAQAAEI7QmpVAAvAAAAAA==.',['微辣']='微辣:BAAAKgADCggICAAAAA==.',['忘了']='忘了眉间笑:BAAAKgAECgIIAgAAAA==.',['念去']='念去去:BAAAKgAFFAQIBAAAAA==.',['惩戒']='惩戒神罚众生:BAAAKgAECgYIBwAAAA==.',['愤怒']='愤怒的鱼人:BAAAKgADCgMIAwAAAA==.',['摯热']='摯热的月亮:BAAAKgAECgYICwAAAA==.',['晴雨']='晴雨天:BAAAKgAECggIDAAAAA==.',['暴躁']='暴躁的野牛:BAAAKgAECggICQAAAA==.',['暴雨']='暴雨天:BAAAKgAFFAMIAwAAAA==.',['月光']='月光德:BAABKgAFFH8GAAIQAAQI+BIoEADZAAAQAAQI+BIoEADZAAAAAA==.',['朕无']='朕无罪:BAABKgAFFH8GAAIPAAYIYgTdKADiAAAPAAYIYgTdKADiAAAAAA==.',['材料']='材料仓库二:BAAAKgAECgcIDQAAAA==.',['杰骜']='杰骜不驯:BAAAKgADCggICAAAAA==.',['松下']='松下裤带子:BAABKgAECn8YAAIMAAgIXQ2SKABbAQAMAAgIXQ2SKABbAQAAAA==.',['柳丶']='柳丶岩:BAAAKgAECgIIAgAAAA==.',['樱木']='樱木:BAAAKgAECgYIBgAAAA==.',['死神']='死神华华:BAAAKgAECgMIBQAAAA==.',['氵丿']='氵丿米丨:BAAAKgAECggICAAAAA==.',['沙丶']='沙丶宝:BAAAKgAECgYIBgAAAA==.',['流年']='流年似水:BAAAKgADCgIIAgAAAA==.',['渐渐']='渐渐:BAAAKgADCgEIAQAAAA==.',['渐溅']='渐溅:BAAAKgAECgEIAQAAAA==.',['燎原']='燎原之悍:BAAAKgAECggICAAAAA==.燎原之殇:BAAAKgAECggICAAAAA==.燎原之牧:BAAAKgAECggICAAAAA==.燎原之萨:BAAAKgAECggICQAAAA==.燎原之骑:BAAAKgAECgIIAgAAAA==.燎原之魔:BAAAKgAECgUIBQAAAA==.',['爱守']='爱守护天使:BAABKgAECn8cAAIBAAgImB0NCQAGAgABAAgImB0NCQAGAgAAAA==.',['牛气']='牛气乂十足:BAACKgAFFH8OAAIHAAMIIRl8JwDYAAAHAAMIIRl8JwDYAAAqAAQKfz4AAgcACAj8G7sgAAYCAAcACAj8G7sgAAYCAAAA.',['猎影']='猎影逐风:BAAAKgAECggIDgAAAA==.',['猴哥']='猴哥猴哥:BAAAKgAECgcIEwAAAA==.',['白老']='白老板拔火罐:BAAAKgADCggICAAAAA==.',['真龍']='真龍小公主:BAABKgAECn8UAAIEAAgIgxnpHgDFAQAEAAgIgxnpHgDFAQAAAA==.',['真龙']='真龙小天子:BAAAKgAECgMIBAAAAA==.',['秋澤']='秋澤晉:BAAAKgAECgIIAwAAAA==.',['秋菊']='秋菊:BAAAKgAECgIIAQAAAA==.',['脸上']='脸上的小人物:BAAAKgAECgcIBwAAAA==.',['舒子']='舒子一往无前:BAAAKgAECgQIBAAAAA==.',['艾因']='艾因湿毯:BAAAKgAFFAQIBAAAAA==.',['花狸']='花狸屮狐少:BAAAKgADCggICAAAAA==.',['西瓜']='西瓜:BAAAKgADCgIIAgAAAA==.',['让哥']='让哥摸一下:BAAAKgAECggIDAAAAA==.',['迁移']='迁移:BAAAKgADCgEIAQAAAA==.',['部落']='部落丨牛马:BAAAKgADCgIIAgAAAA==.',['都不']='都不能缺德:BAABKgAECn8rAAMFAAgI0xlVGgDLAQAFAAgI0xlVGgDLAQARAAMIOhACugBfAAAAAA==.',['钺战']='钺战天:BAAAKgADCgIIAgAAAA==.',['阿尔']='阿尔忒弥斯:BAAAKgADCggIEwAAAA==.',['阿狸']='阿狸哈佘莜:BAAAKgAECgIIAgAAAA==.',['陆奥']='陆奥八云:BAAAKgADCgEIAQAAAA==.',['陪你']='陪你漫长岁月:BAAAKgAECggIEAAAAA==.',['随便']='随便揉随便捏:BAAAKgAECgIIAgAAAA==.',['随风']='随风落叶:BAAAKgAECggIDAAAAA==.',['韭菜']='韭菜拌生蚝:BAAAKgAECgMIAwAAAA==.',['风冰']='风冰火花:BAAAKgADCgEIAQAAAA==.',['鬼哭']='鬼哭狼嚎:BAAAKgAFFAgIAgAAAA==.',['鸭鸭']='鸭鸭樂:BAACKgAFFH9BAAMPAAgI6yFvAgC0AgAPAAgI6yFvAgC0AgAQAAIIaRWyOgCNAAAqAAQKfzEAAw8ACAirITMmAFsCAA8ACAjwIDMmAFsCABAACAg5HuMcAOsBAAAA.',['黑暗']='黑暗破坏神:BAAAKgAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end