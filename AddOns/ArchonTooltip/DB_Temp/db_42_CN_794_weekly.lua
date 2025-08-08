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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Havoc','Warrior-Fury','Mage-Frost','Shaman-Enhancement','Shaman-Restoration','Druid-Balance','Druid-Restoration','Warrior-Arms','Hunter-Marksmanship','Rogue-Assassination','Priest-Holy','Priest-Discipline','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Shaman-Elemental','Mage-Arcane','Mage-Fire','Warlock-Destruction','Paladin-Holy','Paladin-Protection','Druid-Guardian','Druid-Feral','Hunter-BeastMastery','Evoker-Devastation','Warlock-Affliction','DeathKnight-Frost','Priest-Shadow','Unknown-Unknown','Warrior-Protection',}; local provider = {region='CN',realm='耐普图隆',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Afatinib:BAABKgAFFH8MAAMBAAYIQR1TEACaAQABAAYIQR1TEACaAQACAAQIPQsYFgCdAAAAAA==.',Er='Erinyes:BAAAKgAECgcIBwAAAA==.',Ev='Evatrice:BAABKgAFFH8TAAIDAAgI3xpOCwDTAQADAAgI3xpOCwDTAQAAAA==.',Fa='Fawdw:BAABKgAFFH8GAAIEAAYIwgRHEwApAQAEAAYIwgRHEwApAQAAAA==.',Fi='Firefox:BAABKgAFFH8JAAIFAAMISQx+DAC+AAAFAAMISQx+DAC+AAAAAA==.',Go='Good:BAAAKgAECgIIAgAAAA==.',Ha='Haohei:BAACKgAFFH8MAAMGAAYI8hiIBgCKAQAGAAYI8hiIBgCKAQAHAAMICxXyGQCnAAAqAAQKfxwAAwYACAhSEZcbAHkBAAYACAhSEZcbAHkBAAcAAwiLBnpDAF4AAAAA.Harcar:BAABKgAFFH8GAAMIAAMIswx+KgBoAAAIAAII9AZ+KgBoAAAJAAMIsALDFABiAAAAAA==.',He='Hez:BAAAKgAFFAEIAQAAAA==.',Hi='Higher:BAABKgAFFH8MAAMKAAYIXR0YCACKAQAKAAYIXR0YCACKAQAEAAMIaAViFgCuAAAAAA==.',Im='Iminter:BAABKgAFFH8GAAILAAYIMRPtEwBDAQALAAYIMRPtEwBDAQAAAA==.',Ja='Jack:BAAAKgAECgEIAQAAAA==.',Ko='Kokooe:BAAAKgAFFAIIAgAAAA==.Kotka:BAABKgAFFH8HAAIMAAQIcheoFQD8AAAMAAQIcheoFQD8AAAAAA==.',Ma='Mare:BAAAKgAECgQIBAAAAA==.',Me='Meide:BAAAKgAECggIDgAAAA==.Memories:BAAAKgAECgYIEAAAAA==.',Pi='Piag:BAABKgAFFH8vAAMNAAgIQSJkAQCEAgANAAgI5iFkAQCEAgAOAAgI1xzOAgBFAgAAAA==.',Rd='Rdss:BAAAKgAECggIDwAAAA==.',Sh='Shell:BAAAKgAECgUIBQAAAA==.',Su='Survivk:BAAAKgAECgYIBgAAAA==.',Ta='Talona:BAABKgAFFH8FAAINAAMIwgVdGQB2AAANAAMIwgVdGQB2AAAAAA==.Talone:BAABKgAFFH8FAAIDAAMINwXOHwCVAAADAAMINwXOHwCVAAAAAA==.',Tr='Triassicus:BAABKgAFFH8KAAIPAAYIWx0bIQBqAQAPAAYIWx0bIQBqAQAAAA==.',Xa='Xavier:BAAAKgADCggICAAAAA==.',Ya='Yazdruid:BAABKgAFFH8KAAIIAAYIrxLdFwBZAQAIAAYIrxLdFwBZAQAAAA==.',['Âã']='Âãäåæ:BAAAKgADCgMIAwAAAA==.',['一卡']='一卡:BAAAKgAECgMIAwAAAA==.',['一米']='一米六八征婚:BAAAKgAECggICAAAAA==.',['一零']='一零八天下:BAABKgAFFH8GAAIPAAIIaBEAdACCAAAPAAIIaBEAdACCAAAAAA==.',['七上']='七上八下:BAAAKgADCggICAAAAA==.',['三开']='三开战猎萨:BAABKgAFFH8GAAILAAYIYRa7AQCRAQALAAYIYRa7AQCRAQAAAA==.',['不三']='不三不四:BAAAKgAECgMIAwAAAA==.',['不充']='不充值咋变强:BAAAKgAECgEIAQAAAA==.',['不落']='不落的骄傲:BAAAKgADCgIIAgAAAA==.',['业火']='业火弥生:BAAAKgAFFAQIBAAAAA==.',['丨小']='丨小丶丫头丨:BAAAKgAECggIDgAAAA==.丨小可爱:BAAAKgAECgIIAgAAAA==.',['丨我']='丨我不是贼:BAAAKgADCggICQAAAA==.',['丨百']='丨百变怪丨:BAABKgAECn8XAAMQAAgIJBPHKACeAQAQAAgIJBPHKACeAQARAAYItxnMNQByAQAAAA==.',['丶雨']='丶雨露:BAAAKgAECgQIBAAAAA==.',['丷小']='丷小布:BAAAKgAECgQIBAAAAA==.',['乌鸦']='乌鸦坐飞滴:BAAAKgAECgIIAgAAAA==.',['五花']='五花丶小烤肉:BAAAKgAECggICAAAAA==.',['五香']='五香牛肉干:BAACKgAFFH8IAAIKAAgIPhJlAwAnAgAKAAgIPhJlAwAnAgAqAAQKfxYAAwQACAiDFQ80ALEBAAQACAjLEg80ALEBAAoABgjQF4M0AB4BAAAA.',['伊吹']='伊吹萃香:BAAAKgAFFAYIAgAAAA==.',['伊涅']='伊涅斯塔:BAAAKgAECgMIAwAAAA==.',['你来']='你来追我呀丶:BAAAKgAFFAIIAgAAAA==.',['倚泪']='倚泪潇湘:BAAAKgAFFAQIBAAAAA==.',['做我']='做我的宝宝:BAAAKgAFFAgIBAAAAA==.',['全部']='全部木大:BAABKgAFFH8IAAMQAAYI7Q4GDwDAAAAQAAUIIBAGDwDAAAASAAEIHQr5CwAwAAAAAA==.',['兩個']='兩個人的世界:BAAAKgADCggIEAAAAA==.',['冰舞']='冰舞苍穹:BAAAKgADCgIIAgAAAA==.',['冰魂']='冰魂雪魄:BAABKgAFFH8GAAIBAAYI1xisEgCFAQABAAYI1xisEgCFAQAAAA==.',['冷先']='冷先生丶:BAAAKgADCgEIAQAAAA==.',['冷若']='冷若秋:BAAAKgAECggIDQAAAA==.',['凛冬']='凛冬未雪:BAAAKgADCggICAAAAA==.',['凯贝']='凯贝德维尔:BAAAKgADCgEIAQAAAA==.',['别叫']='别叫我烦:BAAAKgADCggICgAAAA==.',['剧摸']='剧摸:BAABKgAFFH8RAAMHAAMIcxTjMAC1AAAHAAMIcxTjMAC1AAATAAEIlwQfHgA2AAAAAA==.',['十迪']='十迪亚波罗十:BAAAKgADCgMIAwAAAA==.',['千灬']='千灬年:BAABKgAFFH8GAAICAAYILhTeDQA7AQACAAYILhTeDQA7AQAAAA==.',['午夜']='午夜倩魂:BAAAKgADCgQIBAAAAA==.午夜猫哥:BAABKgAECn8bAAIQAAgI1RhKBwAdAgAQAAgI1RhKBwAdAgAAAA==.',['南南']='南南希:BAABKgAFFH8SAAMUAAYIfiJGCAD0AQAUAAYIBiJGCAD0AQAFAAQIHCOkDQD4AAABKgAFFAgIRwAVADUlAA==.',['南萧']='南萧萧:BAAAKgAECgUIBQAAAA==.',['卡西']='卡西法:BAAAKgAECgQIBQAAAA==.',['双马']='双马尾唤起爱:BAAAKgAECgEIAQAAAA==.',['叫我']='叫我大伯伯:BAABKgAFFH8QAAIPAAUI7wQ1SgDaAAAPAAUI7wQ1SgDaAAAAAA==.',['可可']='可可大人:BAABKgAFFH8PAAIPAAQI9R71SADcAAAPAAQI9R71SADcAAAAAA==.',['可愛']='可愛人偶:BAAAKgAFFAIIAgAAAA==.',['吹牛']='吹牛毕的胡恩:BAAAKgADCgYIBgAAAA==.',['咏春']='咏春叶问:BAAAKgAFFAQIBAAAAA==.',['喵法']='喵法自然:BAAAKgADCgIIAgAAAA==.',['噗噗']='噗噗砍呲呲电:BAABKgAFFH8GAAIHAAYI/wp9FgApAQAHAAYI/wp9FgApAQAAAA==.',['囧瑟']='囧瑟夫:BAABKgAFFH8IAAIUAAgIZhvdAwB4AgAUAAgIZhvdAwB4AgAAAA==.',['国宝']='国宝蓝猫:BAAAKgAECgcIDAAAAA==.',['地狱']='地狱公爵:BAABKgAFFH8HAAIDAAcIxQepDQCpAQADAAcIxQepDQCpAQAAAA==.',['墨迹']='墨迹墨:BAABKgAFFH8GAAINAAYIAhlYCgB8AQANAAYIAhlYCgB8AQAAAA==.',['壮壮']='壮壮队长:BAAAKgADCgYIBgAAAA==.',['壹鬼']='壹鬼吹灯:BAAAKgADCggICAAAAA==.壹鬼拖刀:BAAAKgADCgUIBQAAAA==.壹鬼火炮:BAAAKgADCggIDAAAAA==.',['夏天']='夏天的风:BAAAKgAFFAQIBAAAAA==.',['多情']='多情贱客:BAAAKgAECgEIAwAAAA==.',['夜烟']='夜烟:BAAAKgADCgYIBgAAAA==.',['夜空']='夜空下的小妖:BAAAKgAECgQICAAAAA==.',['大变']='大变子:BAAAKgADCgcIAQAAAA==.',['大牙']='大牙哥哥:BAAAKgAFFAQIBAAAAA==.',['大驴']='大驴子:BAAAKgADCgQIBAAAAA==.',['大骑']='大骑士:BAAAKgAECggICAAAAA==.',['天使']='天使之剑:BAAAKgADCggICAAAAA==.天使的吻:BAAAKgADCgQIBAAAAA==.',['天顶']='天顶星狐狸:BAABKgAFFH8IAAIWAAMI5AmKNwCSAAAWAAMI5AmKNwCSAAAAAA==.天顶魔:BAAAKgADCgMIAwAAAA==.',['失真']='失真夕阳:BAAAKgAFFAgIAwAAAA==.',['失落']='失落国度:BAAAKgAECgIIBAAAAA==.',['奇东']='奇东呛:BAABKgAFFH8KAAMHAAQILwUgIQB9AAAHAAMILwUgIQB9AAATAAQIYAKsEwBwAAAAAA==.',['如你']='如你所愿:BAAAKgAECggIDwAAAA==.',['妙手']='妙手小华佗:BAABKgAFFH8GAAIOAAQIQB/nCQB5AQAOAAQIQB/nCQB5AQAAAA==.',['姥姥']='姥姥由龙:BAAAKgADCgIIAgAAAA==.',['守望']='守望丨魂:BAABKgAECn8aAAIDAAcIRCIBGABBAgADAAcIRCIBGABBAgAAAA==.',['将军']='将军的恩情:BAABKgAFFH8IAAIPAAgIoRIGCQAaAgAPAAgIoRIGCQAaAgAAAA==.',['小卟']='小卟叽:BAABKgAFFH8FAAILAAUIIhQTIAD1AAALAAUIIhQTIAD1AAAAAA==.',['小翊']='小翊豪:BAAAKgADCgMIAwAAAA==.',['小超']='小超人:BAAAKgAECgIIAgAAAA==.',['小黄']='小黄龙:BAAAKgAECggIEQAAAA==.',['尔等']='尔等皆为猎物:BAAAKgAECgIIAgAAAA==.',['岛田']='岛田侑嘉:BAACKgAFFH8GAAIPAAMIVwy+WwC6AAAPAAMIVwy+WwC6AAAqAAQKfxcAAg8ACAjcFyeJAIUBAA8ACAjcFyeJAIUBAAAA.',['左岸']='左岸风海:BAAAKgAECgMIBAAAAA==.',['帽子']='帽子叔叔:BAAAKgADCgQIBAAAAA==.',['幽明']='幽明大帝:BAAAKgAECgcIBwAAAA==.',['幽灵']='幽灵伪装:BAACKgAFFH8HAAIWAAQIlAQXIACEAAAWAAQIlAQXIACEAAAqAAQKfxQAAhYACAh2D1c7AB4BABYACAh2D1c7AB4BAAAA.',['异质']='异质结:BAAAKgADCggICAAAAA==.',['归来']='归来梓灬:BAAAKgAFFAgIAgAAAA==.',['很久']='很久以前:BAAAKgAFFAcIBAAAAA==.',['心态']='心态要放松:BAABKgAFFH8MAAIBAAYIPhIcFgBrAQABAAYIPhIcFgBrAQAAAA==.',['忆晨']='忆晨:BAACKgAFFH8rAAIPAAgITCYtAQD+AgAPAAgITCYtAQD+AgAqAAQKfx4AAg8ACAiMJnQhAJQCAA8ACAiMJnQhAJQCAAAA.',['忘川']='忘川苦茶:BAAAKgADCggICAAAAA==.',['快去']='快去找奈非天:BAABKgAECn8VAAIDAAgIhRiwIAD/AQADAAgIhRiwIAD/AQAAAA==.',['恒心']='恒心:BAABKgAECn8VAAIPAAgIyhZfYQCcAQAPAAgIyhZfYQCcAQAAAA==.',['惊鸿']='惊鸿:BAACKgAFFH8MAAIPAAQIWCT8DgAYAQAPAAQIWCT8DgAYAQAqAAQKfyMAAw8ACAhpJlkCABoDAA8ACAhpJlkCABoDABcAAggMGWUgAEwAAAAA.',['我是']='我是戦士:BAAAKgAECggIEQAAAA==.',['战神']='战神白起:BAAAKgAECgUIBQAAAA==.',['扁扁']='扁扁:BAABKgAFFH8MAAMPAAQIZRyFIQDlAAAPAAQIaBOFIQDlAAAYAAQIhhlrFgDFAAAAAA==.',['挠你']='挠你后背:BAABKgAFFH8GAAIIAAYIeRU7AwCaAQAIAAYIeRU7AwCaAQAAAA==.',['撕夹']='撕夹粒:BAAAKgAECgYIBgAAAA==.',['敖夜']='敖夜:BAAAKgAECggIDgAAAA==.',['斬魂']='斬魂灬死騎:BAAAKgADCgUIBQAAAA==.',['日暮']='日暮天寒:BAABKgAECn8ZAAMIAAgIOheQMgDhAQAIAAgIOheQMgDhAQAJAAcItxOFSwDfAAAAAA==.',['明則']='明則:BAAAKgAECgUICQAAAA==.',['易天']='易天绝卦:BAAAKgADCgYIBgAAAA==.',['星妖']='星妖:BAAAKgADCgQIBQAAAA==.',['星月']='星月引云追:BAAAKgAECgYIDwAAAA==.',['晓圣']='晓圣:BAAAKgADCggIDwAAAA==.',['晓雪']='晓雪江烟:BAACKgAFFH8WAAQIAAYIWA5cIACwAAAIAAIIiRdcIACwAAAJAAQINgr7EACPAAAZAAEIFwXmCAAjAAAqAAQKfxsABBkACAhQDPQSAB4BABkACAhQDPQSAB4BAAkABwgEDxlRAMkAABoAAQh7C7UWADEAAAAA.',['晴城']='晴城月:BAAAKgAFFAgIAwAAAA==.晴城陌:BAABKgAFFH8GAAINAAYIggVpDwDVAAANAAYIggVpDwDVAAAAAA==.',['晴天']='晴天:BAABKgAECn8WAAIGAAgIZhgfHgDXAQAGAAgIZhgfHgDXAQAAAA==.',['晴朗']='晴朗:BAABKgAFFH8LAAIbAAMIhBCKNADAAAAbAAMIhBCKNADAAAAAAA==.',['晶莹']='晶莹水玲珑:BAAAKgAECgYIBgAAAA==.',['暗影']='暗影追猎者:BAABKgAECn8aAAIbAAgIOhuhJwAVAgAbAAgIOhuhJwAVAgAAAA==.',['暮色']='暮色回忆:BAAAKgADCgYICAAAAA==.',['暴力']='暴力战牛:BAAAKgADCggICAAAAA==.暴力肌肉牛:BAAAKgADCgUIBQAAAA==.',['曦悦']='曦悦小棉袄:BAAAKgAECgIIAgAAAA==.',['来瓶']='来瓶红牛:BAAAKgADCgUIBQAAAA==.来瓶绿茶:BAAAKgADCgIIAgAAAA==.',['果冻']='果冻的拥抱:BAAAKgADCggICAAAAA==.',['枭申']='枭申克:BAAAKgAFFAIIAgAAAA==.',['柠檬']='柠檬奶茶:BAAAKgAFFAIIAgAAAA==.',['柴柴']='柴柴微儿:BAABKgAFFH8IAAIBAAQIFh96KADrAAABAAQIFh96KADrAAAAAA==.',['梅川']='梅川苦茶:BAAAKgAECggICAAAAA==.',['梅穿']='梅穿苦茶:BAAAKgAECggIEAAAAA==.',['橙色']='橙色木马:BAABKgAFFH8SAAMbAAYIPR+7DACkAQAbAAYIPR+7DACkAQALAAQI4AeLFAC8AAAAAA==.',['欧德']='欧德沃福:BAAAKgAECgUIBQAAAA==.',['欺负']='欺负人的大王:BAAAKgAFFAEIAQAAAA==.',['歌狂']='歌狂:BAAAKgAECgIIAgAAAA==.',['永神']='永神夜:BAAAKgAECgIIAgAAAA==.',['沃德']='沃德亿负:BAABKgAFFH8XAAIBAAgIFBcwDADMAQABAAgIFBcwDADMAQAAAA==.',['油腻']='油腻御姐:BAAAKgADCgcICwAAAA==.',['泰妮']='泰妮布里雅:BAABKgAFFH8OAAIUAAgIVw8HCAABAgAUAAgIVw8HCAABAgAAAA==.',['洛十']='洛十方:BAAAKgAECgYICwAAAA==.',['浩浩']='浩浩丶戦:BAABKgAFFH8GAAIKAAYI2gJUCwDcAAAKAAYI2gJUCwDcAAAAAA==.',['深蓝']='深蓝审判:BAABKgAFFH8GAAIWAAYI4wqLHwALAQAWAAYI4wqLHwALAQABKgAFFAgIDgAWAEEbAA==.',['温柔']='温柔手:BAAAKgAECgUIBQAAAA==.',['灬热']='灬热可可:BAAAKgAECgUICAAAAA==.',['灾厄']='灾厄林克:BAAAKgADCgcICgAAAA==.',['炒不']='炒不熟的排骨:BAABKgAFFH8PAAIBAAcIDhggBgAGAgABAAcIDhggBgAGAgAAAA==.',['炫之']='炫之图腾萨:BAABKgAFFH8LAAIHAAgIYRAUCQC2AQAHAAgIYRAUCQC2AQAAAA==.炫之践踏牛:BAAAKgAFFAgIAgAAAA==.',['烈焰']='烈焰叹息:BAAAKgADCgIIAgAAAA==.',['焖不']='焖不熟的排骨:BAACKgAFFH8SAAMYAAgI6BgmAwAZAgAYAAgI6BgmAwAZAgAPAAIIMBI2TABRAAAqAAQKfxgAAg8ACAgfJAUTAMsCAA8ACAgfJAUTAMsCAAAA.',['焖得']='焖得熟的排骨:BAABKgAFFH8MAAIcAAgI4h22AwCGAgAcAAgI4h22AwCGAgAAAA==.',['煎不']='煎不熟的排骨:BAABKgAFFH8PAAMdAAgI/yIbAADkAgAdAAgI/yIbAADkAgAWAAcI6QovFADsAAAAAA==.',['煮不']='煮不熟的排骨:BAAAKgAFFAgIAQAAAA==.',['熊德']='熊德:BAABKgAFFH8GAAIIAAMISQqwPwCsAAAIAAMISQqwPwCsAAAAAA==.',['牛肉']='牛肉老板:BAAAKgAECggIDwAAAA==.',['狂战']='狂战天下:BAABKgAFFH8GAAIKAAYImhPECQBvAQAKAAYImhPECQBvAQABKgAFFAgIDAAPAJIXAA==.',['狮子']='狮子头:BAAAKgAECgIIAgAAAA==.',['玩到']='玩到养老:BAAAKgAECgUIBwAAAA==.',['理查']='理查震撼刘:BAABKgAFFH8GAAIbAAYIRA8OGwAoAQAbAAYIRA8OGwAoAQABKgAFFAgICAAbAHkgAA==.',['琪露']='琪露诺:BAAAKgAECggICAAAAA==.',['瑞雯']='瑞雯:BAACKgAFFH8JAAIIAAQIrRv3JACfAAAIAAQIrRv3JACfAAAqAAQKfyUAAggACAgwIiEVAIgCAAgACAgwIiEVAIgCAAAA.瑞雯丶:BAAAKgAECgMIAwAAAA==.',['瑾歆']='瑾歆:BAAAKgAFFAYIBAAAAA==.',['电你']='电你菊花:BAAAKgADCggIAwAAAA==.',['疯爆']='疯爆打击:BAAAKgAFFAIIBAAAAA==.',['百变']='百变大牛牛:BAAAKgADCggICAAAAA==.',['皮卡']='皮卡崩:BAAAKgAECgQIBAAAAA==.',['皺著']='皺著眉頭的你:BAABKgAFFH8dAAMPAAgI4h8DBQCDAgAPAAgI4h8DBQCDAgAYAAQIgQyFDgCSAAAAAA==.皺著眉頭看雨:BAABKgAFFH8MAAIeAAMIPyDjBgD+AAAeAAMIPyDjBgD+AAABKgAFFAgICwABADsUAA==.皺著眉頭看雲:BAABKgAFFH8KAAMfAAYIUxL0CgBPAQAfAAYIUxL0CgBPAQAOAAIIiRldEwBZAAAAAA==.',['知无']='知无言:BAAAKgAFFAEIAQAAAA==.',['祖尔']='祖尔德纲:BAACKgAFFH8LAAIPAAMITRIvJQDTAAAPAAMITRIvJQDTAAAqAAQKfxgAAg8ACAh1HE05ABsCAA8ACAh1HE05ABsCAAAA.',['神丷']='神丷曲:BAAAKgAECggIDQAAAA==.',['祡丿']='祡丿祡:BAABKgAFFH8GAAIBAAYIRxXXFQBtAQABAAYIRxXXFQBtAQAAAA==.',['祡祡']='祡祡:BAAAKgAFFAYIBAAAAA==.',['筱気']='筱気騩:BAAAKgAECgQIDAAAAA==.',['粉红']='粉红色玳:BAAAKgAECgUIBgAAAA==.',['粉霞']='粉霞天女:BAABKgAFFH8GAAIWAAYIXA4KGQA8AQAWAAYIXA4KGQA8AQAAAA==.',['納蘭']='納蘭飄風:BAAAKgADCgEIAQAAAA==.',['红油']='红油辣子:BAABKgAFFH8GAAIbAAQIdRUWFgD2AAAbAAQIdRUWFgD2AAAAAA==.',['给你']='给你一脚:BAAAKgADCggICAAAAA==.',['肥嘟']='肥嘟嘟左卫门:BAAAKgAFFAQIBAABKgAFFAgIAgAgAAAAAA==.',['能个']='能个儿:BAAAKgAECgUIBQAAAA==.',['脚穿']='脚穿拖鞋:BAAAKgAECgMIBAAAAA==.',['艾丶']='艾丶斯:BAAAKgADCggICAAAAA==.',['花不']='花不会在开:BAAAKgADCgcIBwAAAA==.',['苏麻']='苏麻喇叔:BAAAKgAECgcIEAAAAA==.',['茶余']='茶余饭后:BAAAKgAECgcICAAAAA==.',['葡萄']='葡萄物语:BAABKgAFFH8GAAIRAAYIvRR+AwCNAQARAAYIvRR+AwCNAQAAAA==.',['血色']='血色彼岸:BAAAKgAECggICAAAAA==.',['诚实']='诚实一口:BAAAKgAFFAQIBAAAAA==.',['资乄']='资乄本:BAAAKgAECgYIBgAAAA==.',['赫傲']='赫傲伯兴:BAAAKgAECgEIAQAAAA==.',['赵小']='赵小帅:BAABKgAFFH8JAAMKAAcI1gfwCAALAQAKAAQI8APwCAALAQAEAAMIBw0kIgDKAAAAAA==.赵小狗:BAAAKgAECgUIBwAAAA==.',['跕丶']='跕丶飞扬:BAAAKgAECgEIAQAAAA==.',['踏雪']='踏雪寻欢:BAAAKgADCggICgAAAA==.踏雪飞扬:BAAAKgADCgEIAQAAAA==.踏雪飞歌:BAAAKgAECggICwAAAA==.',['达芬']='达芬齐:BAAAKgADCgIIAgAAAA==.',['追火']='追火车:BAAAKgAFFAYIBAAAAA==.',['逍遥']='逍遥小法:BAAAKgAECgIIAgAAAA==.逍遥雪天:BAABKgAFFH8ZAAINAAQI6QuIFgCKAAANAAQI6QuIFgCKAAAAAA==.',['通灵']='通灵领主:BAACKgAFFH8gAAMBAAgI3xvBCAADAgABAAgI3xvBCAADAgAeAAIIRw2CDwCBAAAqAAQKfxYAAgEACAgvISQtAAACAAEACAgvISQtAAACAAAA.',['邪恶']='邪恶小洢:BAAAKgAECgYICQAAAA==.',['邪灵']='邪灵怒吼:BAABKgAFFH8HAAMEAAQIKgYIFwCnAAAEAAQI3AUIFwCnAAAhAAMIoQF4FABXAAAAAA==.',['郝善']='郝善良:BAAAKgAFFAQIBAAAAA==.',['鄭囯']='鄭囯才:BAAAKgAECggICAAAAA==.',['酷毙']='酷毙了:BAAAKgAFFAMIAwAAAA==.',['铁血']='铁血审判:BAAAKgAECggIEAAAAA==.',['银月']='银月城的光丨:BAAAKgAFFAIIAgAAAA==.',['闪电']='闪电柠檬:BAAAKgAECgIIAgAAAA==.闪电魔影:BAAAKgAECggIDwAAAA==.',['阿七']='阿七:BAABKgAECn8WAAIHAAgIrBM9JQAHAQAHAAgIrBM9JQAHAQAAAA==.',['阿华']='阿华田侑嘉:BAAAKgAFFAIIBAAAAA==.',['阿楠']='阿楠哥:BAAAKgAECgEIAQAAAA==.阿楠喜欢养猫:BAAAKgAFFAYIAgAAAA==.',['随风']='随风飘飘:BAAAKgAFFAYIBAAAAA==.',['零落']='零落尘香:BAABKgAFFH8FAAIFAAUIaBLaDgDsAAAFAAUIaBLaDgDsAAABKgAFFAgIRwAVADUlAA==.零落沉香:BAABKgAFFH8GAAIbAAYIeA+eFwA9AQAbAAYIeA+eFwA9AQAAAA==.',['霹雳']='霹雳双刀小吼:BAABKgAECn8UAAIEAAgIFhTsJACwAQAEAAgIFhTsJACwAQAAAA==.',['風箏']='風箏舞紛飛:BAABKgAFFH8HAAMUAAQIrw0LMQCfAAAUAAQIEAkLMQCfAAAFAAEISBbkKQBDAAAAAA==.',['风之']='风之雅:BAAAKgAECgYICwAAAA==.',['魅影']='魅影小海鬼:BAAAKgADCgcIBwAAAA==.魅影小萨满:BAAAKgAECgUIBQAAAA==.',['魔了']='魔了个兽:BAAAKgADCgYIBgAAAA==.',['鴆羽']='鴆羽千夜:BAABKgAFFH8MAAIOAAgIOxcpBAAOAgAOAAgIOxcpBAAOAgAAAA==.',['麻婆']='麻婆豆腐:BAAAKgAECgUICgAAAA==.',['黯月']='黯月焚星:BAABKgAFFH8IAAIUAAgIXwcGCwCsAQAUAAgIXwcGCwCsAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end