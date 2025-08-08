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
 local lookup = {'Priest-Shadow','Priest-Discipline','Warrior-Fury','DeathKnight-Unholy','Druid-Guardian','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Paladin-Retribution','DeathKnight-Frost','DemonHunter-Havoc','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','Warrior-Arms','Druid-Balance','Druid-Restoration','Rogue-Outlaw','Paladin-Protection','Paladin-Holy','Mage-Fire','Monk-Windwalker','Monk-Mistweaver','DemonHunter-Vengeance','Rogue-Subtlety','Mage-Frost','Shaman-Enhancement','Unknown-Unknown','Mage-Arcane','Warlock-Affliction','Priest-Holy','Evoker-Preservation','Evoker-Devastation','Monk-Brewmaster','Druid-Feral',}; local provider = {region='CN',realm='霍格',name='CN',type='weekly',zone=42,date='2025-08-04',data={As='Ash:BAAAKgAFFAEIAgAAAA==.',Bi='Bigrain:BAABKgAFFH8HAAMBAAMINSEeCAAnAQABAAMINSEeCAAnAQACAAIIWBpbGgCTAAAAAA==.',Ca='Caffein:BAAAKgADCgEIAQAAAA==.',Ch='Christer:BAABKgAFFH8UAAIDAAYI3BN5AQDBAQADAAYI3BN5AQDBAQAAAA==.',Di='Dioe:BAABKgAFFH8KAAIEAAYIIB9VEgCHAQAEAAYIIB9VEgCHAQAAAA==.',Ed='Edmundcz:BAAAKgAECgEIAQAAAA==.',El='Elisha:BAAAKgADCggICAAAAA==.',Em='Emilye:BAABKgAFFH8aAAIFAAMIphijBADXAAAFAAMIphijBADXAAAAAA==.Emnm:BAACKgAFFH8TAAMGAAYIJBdxDACDAQAGAAYIJBdxDACDAQAHAAIIRBB4JQBNAAAqAAQKfxkAAwYACAgXFiw2AJ0BAAYABwi6GCw2AJ0BAAcABwh1FiAyAHoBAAEqAAUUCAgQAAYAIhUA.',En='Envymalice:BAAAKgADCgQIBQAAAA==.',Fi='Firmament:BAAAKgADCggICAAAAA==.',Fl='Flowmytears:BAAAKgAFFAQIAgAAAA==.',He='Hecate:BAAAKgAECgQIBAAAAA==.',Ho='Holysnake:BAAAKgAECgcICgAAAA==.',Ia='Iamguldan:BAAAKgADCgMIAwAAAA==.',Kh='Khrushchev:BAABKgAFFH8HAAIIAAYIVxP3DAB9AQAIAAYIVxP3DAB9AQAAAA==.',Ki='Kioe:BAAAKgAFFAYIAQAAAA==.',Li='Lioe:BAAAKgAFFAQIBAAAAA==.',Mi='Miss:BAAAKgAECgEIAQAAAA==.',Na='Na:BAAAKgAFFAQIBAAAAA==.Naga:BAAAKgAECgEIAQAAAA==.',Ni='Nioe:BAAAKgAECgYIDgAAAA==.',Ok='Okario:BAAAKgADCggICAAAAA==.',Pa='Padre:BAABKgAFFH8IAAIJAAQIVxYqIQDmAAAJAAQIVxYqIQDmAAAAAA==.Papay:BAAAKgAFFAgIAQAAAA==.',Pd='Pdl:BAAAKgAECggICAAAAA==.',Po='Poisonllvy:BAABKgAFFH8PAAIKAAgIOBiaAQByAgAKAAgIOBiaAQByAgAAAA==.Ponyoo:BAAAKgAECgUIBQAAAA==.',Pr='Presumptuous:BAAAKgAECgQIBAAAAA==.',Qi='Qioe:BAAAKgAECgIIAgAAAA==.',Ri='Rioe:BAAAKgADCgMIAwAAAA==.',Ro='Rolling:BAABKgAFFH8JAAILAAUIwQ78EQAPAQALAAUIwQ78EQAPAQAAAA==.',Sm='Smallrain:BAAAKgAFFAgIBAAAAA==.',Sp='Spoolerr:BAAAKgAECgQIBAAAAA==.',St='Stelvis:BAAAKgAECgMIAwAAAA==.',To='Totlongren:BAAAKgAECgYIBQAAAA==.',Tr='Trial:BAAAKgAECgUIDQAAAA==.',Va='Vampirecain:BAABKgAFFH8IAAIMAAQIvQ9vEgCwAAAMAAQIvQ9vEgCwAAAAAA==.Vanhelsing:BAABKgAFFH8OAAIDAAYIaR9/CgCkAQADAAYIaR9/CgCkAQAAAA==.',Wa='Warframelz:BAAAKgAECgIIBAAAAA==.',['一宸']='一宸:BAABKgAFFH8LAAMNAAQIbhwfGADwAAANAAQIoxgfGADwAAAOAAQIcBjQJABNAAAAAA==.',['一枪']='一枪穿心:BAAAKgADCgEIAQAAAA==.',['一眼']='一眼顶真:BAAAKgAECggIBwAAAA==.',['一磅']='一磅小麦:BAAAKgADCggICAAAAA==.',['一笑']='一笑一尘缘:BAAAKgAECgQIBgAAAA==.',['一缕']='一缕银丝:BAAAKgAECgcIBwAAAA==.',['一花']='一花一天堂:BAAAKgAECgQIBAAAAA==.',['一雨']='一雨纵横:BAABKgAFFH8FAAILAAQIGwXjIgB9AAALAAQIGwXjIgB9AAAAAA==.',['七海']='七海千秋丶:BAAAKgAECgUIBQAAAA==.',['三岁']='三岁学杀鸡:BAAAKgAFFAQIAwAAAA==.',['三木']='三木曰一先生:BAACKgAFFH8KAAIPAAgI/BLNCgDfAQAPAAgI/BLNCgDfAQAqAAQKfxYAAw8ACAjGIywJAKQCAA8ACAj8IiwJAKQCABAABAj7HL49AOkAAAAA.',['三硝']='三硝基甲本:BAAAKgAECgEIAQAAAA==.',['三聚']='三聚氰胺:BAAAKgADCgQIBAAAAA==.',['三色']='三色喵:BAAAKgAFFAMIAwAAAA==.',['上将']='上将杨旭东:BAAAKgADCgcIBwAAAA==.',['下次']='下次一定:BAAAKgADCgYICwAAAA==.',['不会']='不会玩魔兽哦:BAAAKgADCgIIAgAAAA==.',['丑的']='丑的伤心:BAAAKgAFFAMIAwAAAA==.',['个子']='个子不算高:BAAAKgAFFAQIBAAAAA==.',['丰胸']='丰胸圣手:BAABKgAFFH8IAAMOAAMIBQ7rLgCxAAAOAAMIBQ7rLgCxAAANAAIIrwSjVgBRAAAAAA==.',['丶无']='丶无辜朋友:BAAAKgAFFAQIBAAAAA==.',['丷韩']='丷韩红丷:BAAAKgADCggICAAAAA==.',['乄逐']='乄逐风丶:BAAAKgAECgIIAgAAAA==.',['乌龙']='乌龙茶丶:BAAAKgADCggICAAAAA==.',['九成']='九成新:BAABKgAFFH8IAAIJAAgIsRNrKQBCAQAJAAgIsRNrKQBCAQAAAA==.',['二弟']='二弟长压弯背:BAABKgAFFH8SAAMDAAYIsxhGBgA2AQADAAYIyhdGBgA2AQARAAQIYyKVFADfAAAAAA==.',['云晴']='云晴:BAAAKgADCggICAAAAA==.',['云深']='云深无迹:BAABKgAFFH8IAAIJAAgIhQ22CwDmAQAJAAgIhQ22CwDmAQAAAA==.',['亦檬']='亦檬:BAAAKgADCgEIAQAAAA==.',['今天']='今天你喝了么:BAAAKgADCgMIAwAAAA==.',['从小']='从小就很黑丶:BAAAKgAECgYICQAAAA==.',['以德']='以德服狼:BAAAKgADCgEIAQAAAA==.',['伊莲']='伊莲娜丶岚星:BAABKgAFFH8OAAIDAAYI8B1OCwCWAQADAAYI8B1OCwCWAQAAAA==.',['优势']='优势在我:BAAAKgAFFAQIBAAAAA==.',['传奇']='传奇耐摔王:BAABKgAFFH8GAAINAAYIAxHwBACDAQANAAYIAxHwBACDAQAAAA==.',['伤心']='伤心猪大肠:BAAAKgAFFAQIAgABKgAFFAgIUAASABcmAA==.伤心羊腰子:BAAAKgAFFAYIBAAAAA==.',['何田']='何田田:BAAAKgAECggICQAAAA==.',['你说']='你说法爷开门:BAAAKgAECgYICAAAAA==.',['俏莉']='俏莉娜:BAAAKgAECgUIBQAAAA==.',['俺翼']='俺翼:BAAAKgAECgEIAQAAAA==.',['假装']='假装很猛:BAAAKgAFFAQIBAAAAA==.',['八雲']='八雲:BAABKgAFFH8MAAIJAAYIzhWEIgBiAQAJAAYIzhWEIgBiAQAAAA==.',['公子']='公子丨世无双:BAABKgAECn8VAAMEAAgIEhvzMwDiAQAEAAgIEhvzMwDiAQAKAAEIAABgPQAAAAABKgAFFAgICAADALMSAA==.',['兵主']='兵主:BAABKgAFFH8GAAIEAAYI5RU1FgBrAQAEAAYI5RU1FgBrAQAAAA==.',['兽授']='兽授:BAAAKgAECggICAAAAA==.',['冬青']='冬青子:BAABKgAFFH8GAAIOAAYIAxTkFQA1AQAOAAYIAxTkFQA1AQAAAA==.',['冰冻']='冰冻榴莲:BAABKgAFFH8GAAIEAAYIWR91DQC6AQAEAAYIWR91DQC6AQABKgAFFAgIBgAEAB0dAA==.',['冰可']='冰可乐治心伤:BAAAKgADCgIIAgAAAA==.',['冲锋']='冲锋无悔:BAABKgAFFH8OAAIDAAMIXwqJIwDEAAADAAMIXwqJIwDEAAAAAA==.',['冷水']='冷水鱼:BAAAKgAECgcICQAAAA==.',['冻水']='冻水鱼:BAAAKgADCgEIAQAAAA==.',['凉风']='凉风知我意:BAABKgAFFH8KAAMNAAYIQRzjAgCzAQANAAYI7xvjAgCzAQAOAAIIRR1xHACKAAABKgAFFAgICAANABcdAA==.凉风起:BAABKgAECn8gAAMNAAgIQxeaPwCoAQANAAgI9xaaPwCoAQAOAAgImRAIPgBcAQAAAA==.',['刘哒']='刘哒哒:BAAAKgAFFAIIAgAAAA==.',['加肥']='加肥糖:BAABKgAFFH8MAAIEAAYIWxsXCADAAQAEAAYIWxsXCADAAQABKgAFFAgIEQAOAPEXAA==.',['勇敢']='勇敢犇:BAACKgAFFH8MAAIEAAQIDA7zMwDGAAAEAAQIDA7zMwDGAAAqAAQKfxwAAgQACAiqG24sAAQCAAQACAiqG24sAAQCAAAA.',['包租']='包租公呆萌怂:BAAAKgAECgIIBAAAAA==.',['叛逆']='叛逆的鲁智深:BAAAKgAECgYIAwAAAA==.',['口合']='口合口合:BAAAKgADCggICAAAAA==.',['口嗨']='口嗨可不行:BAAAKgAFFAIIAwAAAA==.',['叱咤']='叱咤魔海喵喵:BAAAKgADCgQIBAAAAA==.',['和肥']='和肥奥力给:BAAAKgAFFAIIAgAAAA==.',['咕咕']='咕咕哒哒:BAABKgAFFH8IAAIFAAQIdw0MCQB9AAAFAAQIdw0MCQB9AAAAAA==.',['咕噜']='咕噜丨敏:BAAAKgAFFAQIBAAAAA==.',['哈撒']='哈撒姆:BAAAKgADCgYIBwAAAA==.',['哔叨']='哔叨哔哔叨:BAAAKgADCggICAAAAA==.',['唐伯']='唐伯虎点秋香:BAAAKgADCgMIAwAAAA==.',['喵乌']='喵乌:BAABKgAFFH8GAAMSAAYIABBcPgCwAAASAAQIRhBcPgCwAAATAAII1wx6JQCPAAAAAA==.',['噢耶']='噢耶:BAAAKgADCgQIBAAAAA==.',['嚸嚸']='嚸嚸:BAAAKgAFFAMIAwAAAA==.',['四妹']='四妹:BAABKgAFFH8MAAIUAAgIaAUqAgBRAQAUAAgIaAUqAgBRAQAAAA==.',['回城']='回城干涉:BAAAKgADCgQIBQAAAA==.',['困了']='困了就睡丶:BAAAKgAECgcICgAAAA==.',['困困']='困困的风车车:BAAAKgAFFAEIAQAAAA==.',['图四']='图四爷:BAAAKgAECgQIBAAAAA==.',['圣光']='圣光忽悠着我:BAAAKgAECgYIBwAAAA==.圣光鸡腿:BAABKgAFFH8IAAIJAAgI6xCjDAADAgAJAAgI6xCjDAADAgAAAA==.',['圣辉']='圣辉耀光:BAAAKgAFFAYIAwAAAA==.',['地上']='地上的月影:BAAAKgAECgYIDAAAAA==.',['坐忘']='坐忘道:BAAAKgAFFAEIAQAAAA==.',['坐牢']='坐牢:BAACKgAFFH8TAAMJAAcIBSH4DwCfAQAJAAcIBSH4DwCfAQAVAAIIkhu7DgCRAAAqAAQKfxYAAwkACAgHJkQFAAoDAAkACAgHJkQFAAoDABUAAwi9JOwiAD0BAAAA.',['墨影']='墨影狂徒:BAAAKgAFFAQIBAAAAA==.',['墨染']='墨染秋枫:BAAAKgAECgIIAgAAAA==.',['墨溪']='墨溪:BAAAKgADCgEIAgAAAA==.',['墩墩']='墩墩杯:BAAAKgADCggICAAAAA==.',['壶兄']='壶兄无敌顶:BAAAKgAECgcIDAAAAA==.',['夏树']='夏树的飞花:BAAAKgAECgUIBQAAAA==.',['夏洛']='夏洛特凯尔:BAABKgAFFH8PAAMVAAQIOQxGHwCCAAAVAAQIOQxGHwCCAAAWAAIIrQ9CEAB/AAAAAA==.',['夏芷']='夏芷岸:BAAAKgADCgEIAQAAAA==.',['夜阑']='夜阑谣:BAAAKgAECggICAAAAA==.',['夜露']='夜露死苦:BAAAKgAECgIIBAAAAA==.',['够你']='够你喝一壶的:BAAAKgAECgMIAwAAAA==.',['大力']='大力坤:BAAAKgAFFAgIBAABKgAFFAgICgAXAPsVAA==.',['大号']='大号奶牛:BAAAKgADCgEIAQAAAA==.',['大耐']='大耐妞:BAAAKgADCgIIAgAAAA==.',['大苏']='大苏打阿斯顿:BAABKgAFFH8FAAIJAAMIqgPgNwCAAAAJAAMIqgPgNwCAAAAAAA==.',['奔跑']='奔跑吧牛牛:BAAAKgAECggICQAAAA==.',['女尤']='女尤:BAACKgAFFH8HAAMPAAYIgxrLEgBwAQAPAAYISxnLEgBwAQAQAAEItByuIgBWAAAqAAQKfx8AAg8ACAi5H28JAHcCAA8ACAi5H28JAHcCAAAA.',['奶不']='奶不动就跑:BAAAKgAFFAIIAgAAAA==.',['奶量']='奶量充足:BAAAKgADCgIIAgAAAA==.',['妔猫']='妔猫猎手:BAAAKgADCgYICAAAAA==.',['妖月']='妖月丶:BAAAKgADCggICAAAAA==.',['妙不']='妙不可言:BAAAKgAECgcIBwAAAA==.',['姑姑']='姑姑:BAAAKgAECggIDAAAAA==.',['姬丿']='姬丿太美:BAAAKgAECgUIBQAAAA==.',['姬若']='姬若瀞:BAAAKgAECgcIBwAAAA==.',['媳妇']='媳妇儿大貔貅:BAABKgAFFH8IAAMEAAgIJBBLHAA8AQAEAAUICRBLHAA8AQAKAAMISBAwCgDPAAAAAA==.',['嬲嬲']='嬲嬲:BAAAKgAECgYIBgAAAA==.',['孕吐']='孕吐哥:BAAAKgAECgIIAgAAAA==.',['孩子']='孩子银义:BAAAKgADCgUIBQAAAA==.',['安雅']='安雅:BAAAKgADCggICAAAAA==.',['宝宝']='宝宝追她:BAAAKgADCgEIAQAAAA==.',['宸星']='宸星:BAABKgAFFH8IAAIGAAMIShgBKADWAAAGAAMIShgBKADWAAAAAA==.',['宸龍']='宸龍:BAAAKgAFFAYIBAAAAA==.',['寒暄']='寒暄兮语:BAAAKgAECggIEgAAAA==.寒暄汹焽僧:BAABKgAECn8ZAAIYAAgIXRVAGgDPAQAYAAgIXRVAGgDPAQAAAA==.寒暄焽訩貓:BAABKgAECn8YAAMOAAgIyA5fRABAAQAOAAgIeA5fRABAAQANAAEIqgpbyAA0AAAAAA==.寒暄莫萨曼:BAAAKgAECgYICwAAAA==.寒暄莫言:BAABKgAECn8aAAILAAgIzBVPKADLAQALAAgIzBVPKADLAQAAAA==.',['寻梦']='寻梦仙人:BAAAKgADCggICAAAAA==.',['小可']='小可爱灬菲菲:BAAAKgAECgIIAgAAAA==.',['小夜']='小夜夜:BAABKgAFFH8GAAILAAQIwQ0KGwDZAAALAAQIwQ0KGwDZAAAAAA==.',['小小']='小小德灬:BAAAKgAECgcICQAAAA==.小小熊雄:BAAAKgAECgQIBAAAAA==.',['小忮']='小忮:BAAAKgADCgEIAQAAAA==.',['小悟']='小悟漪漪:BAAAKgADCgEIAQAAAA==.',['小焸']='小焸焸:BAAAKgADCgIIAgAAAA==.',['小猪']='小猪呼噜噜:BAABKgAFFH8IAAIZAAYIdSMbHgCwAAAZAAYIdSMbHgCwAAAAAA==.小猪宝宝:BAABKgAFFH8UAAMGAAYIqxXcDgBkAQAGAAYIqxXcDgBkAQAHAAEIPAKiHQA4AAABKgAFFAgICgAGACITAA==.',['小管']='小管同学术:BAAAKgADCgMIAwAAAA==.小管同学魔:BAAAKgADCggIEwAAAA==.',['小菜']='小菜丶咕:BAAAKgAECgcIDAAAAA==.',['小落']='小落落走丢了:BAACKgAFFH8KAAIGAAQIkhiWFwC3AAAGAAQIkhiWFwC3AAAqAAQKfxkAAwYACAjuEcVKAE8BAAYACAjuEcVKAE8BAAcABgicEmJLAPAAAAAA.',['小虎']='小虎歌:BAABKgAFFH8HAAMaAAQIxRQ2EQC5AAAaAAMIxRQ2EQC5AAALAAEIAABLUAAAAAAAAA==.',['小跳']='小跳蛙:BAAAKgAECgYIBgAAAA==.',['小软']='小软害你哟:BAAAKgAECgIIAgAAAA==.',['小黄']='小黄瓜好用:BAAAKgADCgcIBwAAAA==.',['小黑']='小黑竹:BAAAKgAFFAQIBAAAAA==.',['小龙']='小龙虾:BAAAKgAECgIIAgAAAA==.小龙龙:BAAAKgADCgEIAQAAAA==.',['尼大']='尼大锤老娘:BAAAKgADCgUIBQAAAA==.',['山的']='山的那边:BAAAKgAECgQIBQAAAA==.',['布莱']='布莱克肖:BAAAKgADCgUIBQAAAA==.布莱德利:BAAAKgAECgQIBAAAAA==.布莱德梨:BAAAKgAECgQIBQAAAA==.',['希瓦']='希瓦女王乂:BAABKgAFFH8IAAIOAAMI0wbFHACGAAAOAAMI0wbFHACGAAAAAA==.',['帝皇']='帝皇:BAACKgAFFH8IAAIJAAYI4hfnHwBwAQAJAAYI4hfnHwBwAQAqAAQKfxgAAgkABgigGK51AGgBAAkABgigGK51AGgBAAAA.',['幻想']='幻想:BAAAKgADCgQIBAAAAA==.',['幽灵']='幽灵灬壁垒:BAABKgAFFH8KAAINAAQIbx7KKADiAAANAAQIbx7KKADiAAAAAA==.',['弑君']='弑君丶:BAAAKgAECgYIBwAAAA==.',['弑神']='弑神:BAABKgAFFH8FAAIZAAUIGwvSDQDQAAAZAAUIGwvSDQDQAAAAAA==.',['弹簧']='弹簧钢:BAABKgAFFH8JAAMOAAQIwha1IwDgAAAOAAQIwha1IwDgAAANAAIIigetQABjAAABKgAFFAgIBgAZABUEAA==.',['彭忒']='彭忒西勒亚:BAAAKgADCggICAAAAA==.',['很脆']='很脆哒:BAAAKgAFFAgIAgAAAA==.',['微震']='微震天:BAAAKgADCgEIAQAAAA==.',['忽必']='忽必劣:BAABKgAFFH8UAAINAAMI+xZcJwDoAAANAAMI+xZcJwDoAAAAAA==.',['恐怖']='恐怖的奴隶主:BAABKgAFFH8KAAMbAAYIDx76AgAsAQAbAAQInCH6AgAsAQAIAAYIZRWvCwDmAAABKgAFFAgIBQAIAEkOAA==.恐怖老奶:BAACKgAFFH8KAAMXAAYI+xVXCwCCAQAXAAYIhhRXCwCCAQAcAAQItxqWCADoAAAqAAQKfxUAAhwACAgAHf8XAEACABwACAgAHf8XAEACAAAA.',['恐龙']='恐龙扛狼扛:BAAAKgADCgYIBgAAAA==.',['恰逢']='恰逢:BAABKgAFFH8IAAIEAAQI+gNfHAB8AAAEAAQI+gNfHAB8AAAAAA==.',['恶魔']='恶魔再身边:BAAAKgADCgIIAgAAAA==.',['恶龙']='恶龙咆哮丨呀:BAAAKgAFFAQIBAAAAA==.',['悦清']='悦清柠:BAAAKgAECgQIBAAAAA==.',['慒丶']='慒丶懆:BAABKgAECn8cAAIKAAgI5yP5BQBzAgAKAAgI5yP5BQBzAgAAAA==.',['懒的']='懒的变形:BAAAKgAFFAIIAgAAAA==.',['我叫']='我叫小謹:BAAAKgAFFAQIBAAAAA==.',['我就']='我就奶一口:BAAAKgADCggICAAAAA==.我就是依人:BAAAKgADCgUIBQAAAA==.',['我想']='我想我会孤单:BAAAKgADCggICQAAAA==.',['我感']='我感觉很难瘦:BAABKgAFFH8GAAIdAAYI7Bo9AQDRAQAdAAYI7Bo9AQDRAQABKgAFFAgIBAAeAAAAAA==.',['我有']='我有以巴:BAAAKgADCggICAAAAA==.',['我超']='我超飒哦:BAABKgAFFH8NAAMfAAgIZBtxBQA+AgAfAAgI0RhxBQA+AgAcAAUIPxmIBQBRAQAAAA==.',['战爵']='战爵:BAABKgAFFH8OAAIJAAgIHiE+BgBoAgAJAAgIHiE+BgBoAgAAAA==.',['扛几']='扛几楼:BAAAKgAECgUIBQAAAA==.',['执政']='执政官:BAAAKgAECggICAAAAA==.',['找姐']='找姐骑:BAACKgAFFH8hAAMJAAcIZRGhGgAPAQAJAAUIDhWhGgAPAQAVAAMIVQ4ADADAAAAqAAQKfxsAAwkACAj7HSs9AA0CAAkACAj7HSs9AA0CABUAAQgKBEhqABAAAAEqAAUUCAgOAAQAShcA.',['拿我']='拿我耙子来:BAACKgAFFH8LAAIcAAMIUA1QDAC/AAAcAAMIUA1QDAC/AAAqAAQKfyMAAhwACAjnGQ4WAAkCABwACAjnGQ4WAAkCAAAA.',['指尖']='指尖丶旋律:BAABKgAFFH8HAAMbAAUIyxi0CwCjAAAbAAIIBR+0CwCjAAAIAAMIkRKFIQCcAAAAAA==.',['掉色']='掉色人:BAAAKgAECgMIBgAAAA==.',['握日']='握日摘星:BAAAKgADCgEIAQAAAA==.',['摩诃']='摩诃伽罗:BAAAKgAECgcIBgAAAA==.',['敌法']='敌法上线了:BAABKgAFFH8GAAILAAYImhAvHQAYAQALAAYImhAvHQAYAQAAAA==.',['敖公']='敖公子:BAAAKgADCgEIAQAAAA==.',['敖小']='敖小弟:BAAAKgADCgEIAQAAAA==.',['断片']='断片:BAAAKgAECgUIBQAAAA==.',['新年']='新年果子:BAABKgAFFH8KAAMCAAgIxxLdCQB6AQACAAYIjxLdCQB6AQABAAMIYxTzFgDEAAAAAA==.',['旗鱼']='旗鱼:BAAAKgAECggIEwAAAA==.',['无敌']='无敌小东东:BAAAKgAECgIIAgAAAA==.',['无限']='无限迷惑:BAACKgAFFH8KAAIJAAMI0w0bVgDEAAAJAAMI0w0bVgDEAAAqAAQKfygAAgkACAhWITYoAF8CAAkACAhWITYoAF8CAAAA.',['早饭']='早饭想吃啥:BAACKgAFFH8UAAINAAQICCPmGQAvAQANAAQICCPmGQAvAQAqAAQKfx4AAg0ABwgAIB0rAAMCAA0ABwgAIB0rAAMCAAAA.',['明月']='明月:BAABKgAFFH8OAAQgAAgINh2BCgDhAAAPAAQIcBmeGAA/AQAgAAMIPiKBCgDhAAAQAAQIEBPODwC9AAAAAA==.',['易宸']='易宸:BAAAKgAECggIBQAAAA==.',['星愿']='星愿:BAABKgAFFH8HAAIZAAcI3wkuDQBSAQAZAAcI3wkuDQBSAQAAAA==.',['星期']='星期十:BAAAKgADCgEIAQAAAA==.',['春哥']='春哥儿:BAAAKgAFFAEIAQAAAA==.',['春宵']='春宵苦短:BAAAKgAFFAQIBAAAAA==.',['晚晚']='晚晚:BAABKgAECn8xAAIhAAgIESPzDABuAgAhAAgIESPzDABuAgAAAA==.',['晚里']='晚里:BAABKgAECn8eAAIhAAgIDyGdDwBNAgAhAAgIDyGdDwBNAgABKgAFFAgICAACAPoIAA==.晚里二:BAAAKgAECggIEgAAAA==.晚里六:BAABKgAECn8dAAIhAAgIdyGPCACXAgAhAAgIdyGPCACXAgAAAA==.',['暗影']='暗影向我歌唱:BAAAKgAECgcIBwAAAA==.',['暮色']='暮色幽灵:BAAAKgAECgQIBAAAAA==.',['暴风']='暴风雨城:BAAAKgAECgUICgAAAA==.',['暴食']='暴食:BAABKgAFFH8KAAMTAAYI7xKgGQDTAAATAAUILg6gGQDTAAASAAIIMgdeUQBxAAAAAA==.',['月渎']='月渎:BAAAKgAECgQIAQAAAA==.',['朝霞']='朝霞:BAAAKgAFFAQIAQAAAA==.',['木乃']='木乃姨:BAAAKgADCgcIBwAAAA==.',['机器']='机器猫:BAAAKgADCgYIBgAAAA==.',['杀马']='杀马特淑芬:BAABKgAFFH8GAAIMAAYIUBOqAwBWAQAMAAYIUBOqAwBWAQAAAA==.杀马特秀芬:BAAAKgAECggIBgAAAA==.',['李小']='李小龍:BAAAKgAECgYIBwAAAA==.',['李骁']='李骁龙:BAAAKgAECgcIBwAAAA==.',['杜磊']='杜磊斯:BAAAKgAECgUICAAAAA==.',['林明']='林明美:BAAAKgAECgcIEQAAAA==.',['林深']='林深时见鹿:BAAAKgAECgQIBAAAAA==.',['果子']='果子:BAAAKgAECgEIAQAAAA==.果子果子:BAABKgAFFH8MAAMEAAgIghV4GwBCAQAEAAQIbBh4GwBCAQAMAAQInxGUEQC1AAAAAA==.',['柒戚']='柒戚:BAAAKgAECgIIAgAAAA==.',['栖药']='栖药:BAAAKgAECgEIAQAAAA==.',['核心']='核心价值观:BAAAKgAECgQIBAAAAA==.',['桃妖']='桃妖刀:BAAAKgAECgEIAQAAAA==.',['梁章']='梁章:BAABKgAFFH8GAAIDAAYIeAQFDQArAQADAAYIeAQFDQArAQAAAA==.',['梅鶸']='梅鶸华:BAABKgAFFH8NAAMYAAMIzxN7EgCbAAAYAAMIzxN7EgCbAAAZAAEI8gDaMAAqAAAAAA==.',['椎名']='椎名真昼:BAABKgAFFH8QAAMCAAYItRgJAQDjAQACAAYItRgJAQDjAQABAAYIKBQlDAA8AQAAAA==.',['樱木']='樱木花道:BAAAKgAECgQIBAAAAA==.',['橙柚']='橙柚柚:BAAAKgAFFAQIBAAAAA==.',['正义']='正义飞盘:BAAAKgAECgMIAwAAAA==.',['死亡']='死亡领主:BAABKgAFFH8SAAIEAAgIkCVjAAAPAwAEAAgIkCVjAAAPAwAAAA==.',['毛头']='毛头毛毛:BAAAKgAECgEIAQAAAA==.',['水煮']='水煮牛鞭丶:BAABKgAFFH8JAAIXAAYIpQvaDgAgAQAXAAYIpQvaDgAgAQAAAA==.',['汉子']='汉子:BAAAKgADCggIDwAAAA==.',['江東']='江東丶:BAAAKgAECggICAAAAA==.',['沃特']='沃特法:BAAAKgADCggICAAAAA==.',['沃顿']='沃顿皮卡丘:BAAAKgAECgMIAwAAAA==.',['没门']='没门:BAAAKgAECgYICAAAAA==.',['沧海']='沧海灬人无情:BAABKgAECn8aAAMLAAgI3BWZNwDMAQALAAgI3BWZNwDMAQAaAAYIrwhMRACuAAAAAA==.',['法尸']='法尸:BAAAKgADCgMIAwAAAA==.',['法湿']='法湿:BAAAKgADCgQIBAAAAA==.',['泡椒']='泡椒板面:BAAAKgADCggIEAAAAA==.',['泷泽']='泷泽萝莉丶:BAABKgAFFH8GAAMhAAYI3RPBHADaAAAhAAMIHBzBHADaAAACAAMIfgfkIwCSAAAAAA==.',['洗碗']='洗碗君:BAAAKgADCgIIAgAAAA==.',['流光']='流光:BAAAKgAECgQIBQAAAA==.流光异彩:BAAAKgAECgYICQAAAA==.',['流莺']='流莺毒:BAAAKgAFFAgIBAAAAA==.',['浩劫']='浩劫猎:BAAAKgAECgMIAwABKgAFFAUIAgAeAAAAAA==.',['浪总']='浪总:BAABKgAFFH8HAAMNAAQIrg4mBwBSAQANAAQI9QgmBwBSAQAOAAEIISOyIQBnAAAAAA==.',['海绵']='海绵丶宝宝:BAAAKgAECgEIAQAAAA==.',['消散']='消散:BAAAKgAECggICAAAAA==.',['涛笙']='涛笙皆浪灬:BAABKgAFFH8GAAMOAAUIqxUEFgA0AQAOAAQIKRcEFgA0AQANAAEItA+HSQBEAAABKgAFFAgIFAADABseAA==.',['深爱']='深爱大地母亲:BAAAKgAECggICAAAAA==.',['混子']='混子请自重:BAAAKgAFFAIIAgAAAA==.',['混水']='混水鱼:BAAAKgAECgUIBwAAAA==.',['清源']='清源妙道真君:BAAAKgAECggICgAAAA==.',['清规']='清规:BAAAKgAECgUIBgAAAA==.',['清风']='清风圣:BAABKgAFFH8MAAIJAAgIFiIbAwCtAgAJAAgIFiIbAwCtAgAAAA==.',['溶溶']='溶溶月:BAAAKgAECggIAQAAAA==.',['漫漫']='漫漫茄:BAAAKgAECgIIBAAAAA==.',['潮汐']='潮汐锁定:BAACKgAFFH8RAAMGAAQIcxmgJADkAAAGAAQIcxmgJADkAAAHAAIIOQKCJQBMAAAqAAQKfxQAAwYABwi8FGxFAHIBAAYABwi8FGxFAHIBAAcAAgjWBkV8AEIAAAAA.',['火炕']='火炕鞋:BAAAKgAFFAQIBAAAAA==.',['灵活']='灵活的胖纸:BAACKgAFFH8PAAIZAAMI6gsyEgCOAAAZAAMI6gsyEgCOAAAqAAQKfyEAAhkACAhQDWBDADIBABkACAhQDWBDADIBAAAA.',['灵羽']='灵羽幻梦:BAABKgAFFH8IAAMNAAQIKxVvOAC2AAANAAQIKRBvOAC2AAAOAAQIVRPiMgCmAAAAAA==.',['爱冲']='爱冲可可:BAAAKgADCgMIAwAAAA==.',['爱吃']='爱吃香菜:BAAAKgAFFAIIAgABKgAFFAYIBgAEAIUdAA==.',['爷爷']='爷爷:BAAAKgAECgUIBQAAAA==.',['爺爺']='爺爺:BAAAKgAECgYIBgAAAA==.',['牛嘟']='牛嘟嘟:BAABKgAFFH8SAAMMAAQIdR/rFAD7AAAMAAQIdR/rFAD7AAAEAAEI1gLTIgArAAAAAA==.',['牛年']='牛年你最牛:BAAAKgAECggIDQAAAA==.',['独行']='独行:BAAAKgAFFAIIAgAAAA==.',['猫猫']='猫猫叫:BAAAKgADCgQIBAAAAA==.',['玉帝']='玉帝重返天庭:BAAAKgAECggIEQAAAA==.',['王多']='王多浴:BAAAKgAFFAYIBAABKgAECggIFwATAAkbAA==.',['玖玖']='玖玖忄:BAABKgAECn82AAIZAAgI2g34LQArAQAZAAgI2g34LQArAQAAAA==.',['玛格']='玛格雷斯:BAAAKgAECgQIBAAAAA==.',['玩个']='玩个雀雀:BAAAKgADCggICAAAAA==.',['玩具']='玩具刀:BAAAKgAECgMIAgAAAA==.',['珈小']='珈小珈:BAABKgAFFH8GAAMiAAYIHhlUAACPAQAiAAUI7h5UAACPAQAjAAEIdxZZHQBcAAAAAA==.',['珊珊']='珊珊來迟:BAABKgAFFH8OAAMGAAgIQxJzBgC9AQAGAAgIQxJzBgC9AQAdAAYIWw3XBQBtAQAAAA==.',['甄霓']='甄霓瑪黛静:BAABKgAFFH8IAAIVAAgI5hiZAwA2AgAVAAgI5hiZAwA2AgAAAA==.',['留恋']='留恋星空:BAAAKgAECgEIAQAAAA==.',['疯一']='疯一样地男人:BAAAKgADCggIDQAAAA==.',['白汁']='白汁牧:BAABKgAFFH8IAAMhAAgIqBdOBgDNAQAhAAcI3xhOBgDNAQABAAEIciG+JgBbAAAAAA==.',['白芷']='白芷动芳馨丶:BAACKgAFFH8fAAMSAAQI5RiwKQDsAAASAAMIihuwKQDsAAATAAQInRCsCwDRAAAqAAQKfxsAAxIACAiGIN5AAKUBABIABggUH95AAKUBABMACAgwG2YMAKMBAAAA.',['白衣']='白衣天师:BAABKgAFFH8JAAIfAAUIsBDuEwDlAAAfAAUIsBDuEwDlAAAAAA==.',['盘丝']='盘丝大仙:BAACKgAFFH8cAAMBAAQIaxvUCgAfAQABAAQIaxvUCgAfAQACAAIIIgt3KQBwAAAqAAQKfx4AAwEACAjSGoITAAACAAEACAjSGoITAAACAAIABQgiEZNTAKAAAAAA.',['看德']='看德七十二变:BAAAKgADCgEIAQAAAA==.',['真的']='真的是白给:BAACKgAFFH8QAAMRAAMIHx0iGgC6AAARAAMIHx0iGgC6AAADAAIIZQ+4KgBHAAAqAAQKfy0AAwMACAh2JIANAJoCAAMACAgfI4ANAJoCABEABwhsIiwZAOkBAAAA.',['睡觉']='睡觉中队长:BAAAKgAECggIAgAAAA==.睡觉吧小德:BAAAKgADCgUIBQAAAA==.',['矮刃']='矮刃:BAAAKgAECgMIBgAAAA==.',['砂锅']='砂锅丨滚刀肉:BAABKgAFFH8IAAMhAAQIMhoECAD3AAAhAAQIMhoECAD3AAABAAII2wWxHQB8AAAAAA==.',['硬控']='硬控拜灯五秒:BAAAKgAFFAIIAgAAAA==.',['示申']='示申丱殺:BAABKgAECn8UAAIDAAgIlA/oMQBlAQADAAgIlA/oMQBlAQAAAA==.示申茉莉:BAACKgAFFH8MAAIJAAMI/BIkJwDKAAAJAAMI/BIkJwDKAAAqAAQKfyoAAgkACAgYHV4tAEoCAAkACAgYHV4tAEoCAAAA.',['神威']='神威:BAAAKgAFFAYIAgAAAA==.',['神经']='神经小哥:BAAAKgAECgYICAAAAA==.',['神谕']='神谕:BAAAKgADCggICQAAAA==.',['福贵']='福贵:BAAAKgAECgUICwAAAA==.',['离人']='离人影:BAAAKgAECggICAABKgAFFAQICAAMAJcQAA==.',['秋水']='秋水长天:BAABKgAECn8XAAIJAAgI0xjwbQC9AQAJAAgI0xjwbQC9AQAAAA==.',['秒伤']='秒伤及格线:BAAAKgAECgMIAwAAAA==.',['空条']='空条承太狼:BAAAKgAECgYIBgAAAA==.',['站神']='站神之后:BAAAKgADCgYICwAAAA==.',['笑语']='笑语风橙:BAACKgAFFH8iAAMOAAcIGxqcBQAaAgAOAAcIGxqcBQAaAgANAAEILCA+VABdAAAqAAQKfxoAAg4ACAh6I8sDAL4CAA4ACAh6I8sDAL4CAAAA.',['第一']='第一排:BAAAKgADCgEIAQAAAA==.',['米宥']='米宥:BAAAKgAECgYICgAAAA==.',['精灵']='精灵宝钻:BAAAKgAFFAIIAgAAAA==.',['红色']='红色皇后:BAAAKgAECgQIBAAAAA==.',['红鲤']='红鲤鱼:BAABKgAFFH8MAAIJAAgIiRINLQAzAQAJAAgIiRINLQAzAQAAAA==.',['纯净']='纯净的眼神:BAAAKgAECgYICQAAAA==.',['纯棉']='纯棉的兔子猫:BAABKgAFFH8sAAQcAAYIJSUKBQCPAQAfAAYIbyHJCgC9AQAcAAYI2yIKBQCPAQAXAAYIPR2ICwBCAQAAAA==.',['绘羽']='绘羽:BAAAKgAFFAQIBAABKgAFFAgIEwAhAP0gAA==.',['网瘾']='网瘾少女:BAABKgAECn8kAAIGAAgI3SCVDwByAgAGAAgI3SCVDwByAgAAAA==.',['罪恶']='罪恶:BAAAKgAECgIIAgAAAA==.',['羊头']='羊头人女祭司:BAAAKgAECgQIBAAAAA==.',['老蔡']='老蔡:BAAAKgAECgcICAAAAA==.',['考零']='考零分:BAABKgAFFH8FAAINAAUITxJFIgABAQANAAUITxJFIgABAQAAAA==.',['聖帝']='聖帝:BAAAKgAECgIIAgAAAA==.',['聖皇']='聖皇:BAABKgAFFH8IAAIDAAgIkhEaBQAwAgADAAgIkhEaBQAwAgAAAA==.',['胖胖']='胖胖的咕咕:BAABKgAFFH8MAAMSAAgIZB06GgBIAQASAAUIPyE6GgBIAQATAAMITR/dEgAIAQAAAA==.',['胡桃']='胡桃夹子:BAAAKgAFFAEIAQAAAA==.',['脆皮']='脆皮没仇恨:BAAAKgAFFAQIBAAAAA==.',['腼腆']='腼腆:BAAAKgAFFAMIAwAAAA==.',['艾仑']='艾仑:BAAAKgAECgMIAwAAAA==.',['艾德']='艾德里安:BAAAKgAFFAMIAwAAAA==.',['艾玛']='艾玛格兰杰:BAAAKgADCggICAAAAA==.',['芙莉']='芙莉蓮:BAABKgAFFH8GAAIXAAYIugitEQA0AQAXAAYIugitEQA0AQAAAA==.',['花开']='花开若相依:BAABKgAFFH8OAAMCAAgI/gt3BgDHAQACAAgI/gt3BgDHAQABAAYIbg10BQBjAQAAAA==.',['花式']='花式呢:BAAAKgAFFAQIBAAAAA==.花式啊:BAAAKgAECgYIDwAAAA==.',['荣归']='荣归:BAAAKgADCggIEAAAAA==.',['荷尔']='荷尔蒙丶:BAAAKgAECgYIBgAAAA==.',['莎莎']='莎莎奥力给:BAAAKgAFFAEIAQAAAA==.',['莫夫']='莫夫:BAABKgAFFH8JAAIJAAYIdxofGQD5AAAJAAYIdxofGQD5AAABKgAFFAgIFQAJAAIfAA==.',['菲律']='菲律宾铁猴子:BAAAKgAECgYIBgAAAA==.',['萌牛']='萌牛人:BAAAKgAECgUIBQAAAA==.',['萌萌']='萌萌哒丨牧:BAABKgAFFH8hAAQCAAYI4yKJAAAbAgACAAYI4yKJAAAbAgABAAUIXQkRCwADAQAhAAQIOBO1JgCnAAAAAA==.萌萌心:BAAAKgADCgYICAAAAA==.',['萌虎']='萌虎掌:BAABKgAECn8UAAMYAAgIUhyMEwBGAgAYAAcI3yCMEwBGAgAkAAgIoAE6IABmAAABKgAFFAgIDwAZAO4LAA==.',['蓝妮']='蓝妮:BAABKgAFFH8GAAMGAAYI/xQaHwD/AAAGAAUIqhAaHwD/AAAHAAEIUgGlKgAsAAAAAA==.',['蓝岚']='蓝岚丶坠:BAACKgAFFH8NAAIdAAMIRht8CAAMAQAdAAMIRht8CAAMAQAqAAQKfzEAAh0ACAiyI18FAM0CAB0ACAiyI18FAM0CAAAA.',['薛定']='薛定谔的猫:BAABKgAFFH8LAAILAAQI+QvCGgC5AAALAAQI+QvCGgC5AAAAAA==.',['薯片']='薯片丶:BAAAKgADCgEIAQAAAA==.',['蛇年']='蛇年大吉:BAAAKgADCggICAAAAA==.',['蜗牛']='蜗牛观光客:BAABKgAFFH8NAAQhAAYI3g6mDgBBAQAhAAYI3g6mDgBBAQACAAMI8Q6HHwB+AAABAAEIagDaLAAuAAAAAA==.',['蜜汁']='蜜汁琼浆:BAAAKgAECgEIAQAAAA==.',['表白']='表白:BAABKgAECn8VAAIYAAgIAhQnKACiAQAYAAgIAhQnKACiAQAAAA==.',['许坚']='许坚猪猪:BAAAKgADCggICAAAAA==.',['请先']='请先杀我队友:BAAAKgAFFAIIAgAAAA==.',['请叫']='请叫我平头哥:BAAAKgAECgIIAgAAAA==.',['谁人']='谁人能挡:BAAAKgAFFAMIAwAAAA==.',['谁是']='谁是木头人:BAAAKgAECgYIAgAAAA==.',['谢哥']='谢哥哥:BAACKgAFFH9GAAMJAAgIVRhbGwCIAQAJAAgIVRhbGwCIAQAVAAQIKQ2XHQCNAAAqAAQKf0UAAgkACAjNJIwQANUCAAkACAjNJIwQANUCAAAA.',['赞达']='赞达拉魔王:BAAAKgADCgEIAQAAAA==.',['起风']='起风:BAABKgAFFH8GAAMMAAYI9wmmGwDFAAAMAAUIYgumGwDFAAAEAAEITQQNUwBEAAAAAA==.',['超级']='超级玛丽:BAABKgAFFH8IAAIcAAQIBR8MBQAJAQAcAAQIBR8MBQAJAQAAAA==.',['跌跤']='跌跤的熊仔:BAAAKgADCggIDwAAAA==.',['路过']='路过的查拉图:BAAAKgAFFAQIBAAAAA==.',['蹦蹦']='蹦蹦熊:BAAAKgAECgYIBAAAAA==.',['软绵']='软绵绵的:BAABKgAFFH8GAAIjAAYIpxE/EQBOAQAjAAYIpxE/EQBOAQAAAA==.',['辛夷']='辛夷炖桔梗:BAAAKgAECgQIBAAAAA==.',['逆天']='逆天而行:BAAAKgAECgYIBgAAAA==.',['逍遥']='逍遥墨士:BAAAKgAECgEIAQAAAA==.',['那个']='那个法丝:BAAAKgADCggICAAAAA==.',['那我']='那我问你:BAAAKgAFFAEIAQAAAA==.',['那风']='那风灬慢点:BAABKgAFFH8GAAIJAAYIXR/PFgClAQAJAAYIXR/PFgClAQAAAA==.',['邪皇']='邪皇丶:BAAAKgADCgMIAwAAAA==.',['邪能']='邪能电风扇:BAACKgAFFH8UAAMaAAUIiRvYBwDJAAAaAAQI2xfYBwDJAAALAAMIkhvcIQCvAAAqAAQKfxsAAxoACAjnH0sMAFsCABoACAjnH0sMAFsCAAsAAQgoGRiyAEsAAAAA.',['郎君']='郎君:BAAAKgAECgEIAQAAAA==.',['野人']='野人谷的狼:BAAAKgAFFAQIBAAAAA==.',['鉴心']='鉴心:BAAAKgADCgEIAQAAAA==.',['银克']='银克拉:BAAAKgAECgMIAwAAAA==.',['银兰']='银兰水月:BAABKgAFFH8cAAMcAAYI7CQ7AwAhAQAXAAYIRyJNCAB8AQAcAAQIvSM7AwAhAQAAAA==.',['长大']='长大不得了丶:BAABKgAECn8XAAMOAAgI8yQhBwC0AgANAAgI/yIHEgC2AgAOAAgILSQhBwC0AgAAAA==.',['长崎']='长崎素世:BAAAKgAECgYIBgAAAA==.',['门房']='门房秦大爷:BAABKgAFFH8GAAIMAAYIOgz5EwACAQAMAAYIOgz5EwACAQAAAA==.',['阿哲']='阿哲学长:BAABKgAECn8YAAIJAAgIvyTLEwC7AgAJAAgIvyTLEwC7AgAAAA==.',['阿莎']='阿莎曼:BAABKgAECn8gAAQFAAgITweuKwCQAAAFAAgIoQWuKwCQAAASAAQI9gZWuQBgAAAlAAEIKAkJMAAnAAAAAA==.',['阿龙']='阿龙:BAABKgAFFH8HAAMFAAIIBhazAwB/AAAlAAII+glNBgCSAAAFAAIIBhazAwB/AAAAAA==.',['陈丽']='陈丽君:BAABKgAFFH8MAAMCAAYIYhSYBgA8AQACAAYIwRKYBgA8AQAhAAYIsQq1FwCCAAAAAA==.',['陌上']='陌上浅歌幕:BAABKgAFFH8FAAIZAAUIUBb/EgARAQAZAAUIUBb/EgARAQAAAA==.',['隆里']='隆里蒂斯:BAAAKgAFFAUIBAAAAA==.',['随萨']='随萨:BAAAKgAECgIIAwAAAA==.',['随风']='随风飘流:BAAAKgAFFAEIAQAAAA==.',['雄熊']='雄熊:BAAAKgAECgcICAAAAA==.',['雪月']='雪月剑仙:BAABKgAECn8aAAIJAAgIUiWtGwCpAgAJAAgIUiWtGwCpAgAAAA==.',['雷布']='雷布朗多星人:BAAAKgAECgEIAQAAAA==.',['霜降']='霜降:BAAAKgAECgIIAgAAAA==.',['青柑']='青柑丨普洱:BAAAKgAECggICAABKgAFFAgIFQADALEaAA==.',['青楚']='青楚:BAABKgAECn8VAAICAAcINhEEMAA5AQACAAcINhEEMAA5AQAAAA==.',['青浦']='青浦小次佬:BAAAKgAFFAIIAgAAAA==.',['青笙']='青笙挽歌:BAAAKgAECggICQAAAA==.',['青阳']='青阳行半:BAAAKgAECgIIAgAAAA==.',['风绾']='风绾暮晴雪:BAABKgAFFH8LAAIjAAcIwiBtBQBKAgAjAAcIwiBtBQBKAgAAAA==.',['风落']='风落残月:BAAAKgAFFAgIBAAAAA==.',['风语']='风语萨:BAABKgAFFH8PAAIaAAMInQp8GACJAAAaAAMInQp8GACJAAAAAA==.',['飘渺']='飘渺行:BAAAKgAECggIDAAAAA==.',['飞翼']='飞翼鱼:BAAAKgADCggICAAAAA==.',['食人']='食人鱼:BAAAKgAECgYICwAAAA==.',['饭哆']='饭哆哆:BAABKgAFFH8UAAQJAAYISCGzAAALAgAJAAYISCGzAAALAgAVAAQINBsEBwDyAAAWAAQIXxOdCADQAAAAAA==.',['马杀']='马杀鸡杀鸡玛:BAAAKgAECgYIBwAAAA==.',['魔法']='魔法披风:BAAAKgADCgMIAwAAAA==.魔法桃桃:BAAAKgADCgIIAgAAAA==.',['麻匪']='麻匪马邦德:BAAAKgAECggICQAAAA==.',['黄花']='黄花鱼:BAAAKgAFFAgIBAAAAA==.',['黑之']='黑之剑士:BAAAKgADCggICAAAAA==.',['黑色']='黑色新娘:BAAAKgAECgEIAQAAAA==.',['黑芯']='黑芯棉:BAAAKgAECggIDQAAAA==.',['黑锋']='黑锋骑士:BAAAKgAECgQIBAAAAA==.',['黑龙']='黑龙风语萨:BAABKgAFFH8bAAMHAAMIAB8kDgD3AAAHAAMIAB8kDgD3AAAdAAMI/xJrDwDdAAAAAA==.',['黒妹']='黒妹儿:BAABKgAFFH8MAAIhAAYIuiEvBgDPAQAhAAYIuiEvBgDPAQAAAA==.',['龙鱼']='龙鱼:BAAAKgAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end