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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Priest-Holy','Priest-Discipline','DeathKnight-Frost','DeathKnight-Blood','Warrior-Fury','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Arcane','Warrior-Arms','DeathKnight-Unholy','Warlock-Destruction','Mage-Fire','Mage-Frost','Shaman-Restoration','Monk-Mistweaver','Evoker-Devastation','Warlock-Demonology','Priest-Shadow','Warlock-Affliction','Rogue-Assassination','Unknown-Unknown','Shaman-Elemental','Shaman-Enhancement','Druid-Balance',}; local provider = {region='CN',realm='瓦拉斯塔兹',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amberss:BAAAKgAFFAQIBAAAAA==.',Bi='Bielle:BAAAKgAECggIDQAAAA==.',Ch='Chinamobile:BAACKgAFFH8NAAIBAAIIEiZPSgDaAAABAAIIEiZPSgDaAAAqAAQKf0YAAgEACAihJiYCABwDAAEACAihJiYCABwDAAAA.',Ed='Edan:BAAAKgAFFAQIBAAAAA==.',Ha='Hazydido:BAAAKgAECggICAAAAA==.',Ir='Irisy:BAAAKgAFFAIIAgAAAA==.',La='Laknight:BAABKgAFFH8KAAICAAYImyUWBAAbAgACAAYImyUWBAAbAgAAAA==.Laphy:BAABKgAFFH8GAAMDAAQIfQw6LACTAAADAAQI6Qo6LACTAAAEAAII5AzIJQBLAAAAAA==.',Mo='Momo:BAAAKgADCgMIBAAAAA==.',Ps='Psionic:BAAAKgADCggICAAAAA==.',So='Soul:BAABKgAFFH8LAAMFAAYI2g/ZCADaAAAFAAYI2g/ZCADaAAAGAAQIfQX6KwBkAAABKgAFFAgIFQAHALEaAA==.',Su='Sunshine:BAAAKgAFFAIIAgAAAA==.',Ti='Tiesto:BAAAKgADCgMIAwAAAA==.',Ty='Tylookeyso:BAAAKgAECggICAAAAA==.',Wo='Wooli:BAAAKgAECgIIAgAAAA==.',['一发']='一发奶穿你:BAAAKgAECgMIAwAAAA==.',['一砖']='一砖闹倒:BAAAKgAECggIDgAAAA==.',['万碧']='万碧瑶:BAABKgAFFH8JAAMIAAQIjwGVKwBQAAAIAAMITgGVKwBQAAAJAAQIaQHeJQBIAAAAAA==.',['三等']='三等奖法拉利:BAAAKgAECgQIBAAAAA==.',['三葉']='三葉丶泷:BAAAKgAECggICAAAAA==.',['东隅']='东隅:BAABKgAFFH8MAAIKAAgIZAhRCgC/AQAKAAgIZAhRCgC/AQAAAA==.',['丶袅']='丶袅袅秋风:BAABKgAFFH8GAAIHAAYIVgtrDwBeAQAHAAYIVgtrDwBeAQAAAA==.',['丷垚']='丷垚淼丷:BAAAKgAECggIBgAAAA==.',['丷重']='丷重返巅峰丷:BAABKgAFFH8MAAILAAYI2BqwAQCuAQALAAYI2BqwAQCuAQAAAA==.',['丿橙']='丿橙子丶:BAABKgAFFH8IAAIJAAYIdxb5DQB9AQAJAAYIdxb5DQB9AQAAAA==.',['二手']='二手發师:BAAAKgAECgEIAQAAAA==.',['云飞']='云飞:BAAAKgAFFAQIBAABKgAFFAgIDwAMALYgAA==.',['伊利']='伊利哒雷:BAAAKgAFFAQIBAAAAA==.',['伊珞']='伊珞恩:BAAAKgAFFAUIBAAAAA==.',['信仰']='信仰孤狼:BAABKgAECn8VAAIHAAgIGQ4iOQA9AQAHAAgIGQ4iOQA9AQAAAA==.',['俺是']='俺是法盲:BAAAKgAECgYIBgAAAA==.',['傲世']='傲世灬绝色:BAAAKgAECgQICAAAAA==.',['兔骑']='兔骑士:BAAAKgAECgYIEQAAAA==.',['冷情']='冷情调:BAAAKgADCggICAAAAA==.',['凝视']='凝视深渊:BAABKgAFFH8GAAINAAYI/QqJDwBAAQANAAYI/QqJDwBAAQAAAA==.',['勿入']='勿入天堂:BAACKgAFFH8HAAIOAAIIXSFOHwC6AAAOAAIIXSFOHwC6AAAqAAQKf0MABA4ACAi2JKMDAMUCAA4ACAgyJKMDAMUCAAoACAhwIg4LAKYCAA8ABAg1GAOCAIwAAAAA.',['南家']='南家丨夏奈:BAACKgAFFH8sAAQPAAgI1xvtAwAWAQAKAAYIqR0LDQCVAQAPAAcIORjtAwAWAQAOAAQI+hHdHwDWAAAqAAQKfy8ABA8ACAg0JdEFAOACAA8ACAg0JdEFAOACAA4ABQgZGWZfAPUAAAoAAQhdHPWMAEoAAAAA.',['占戈']='占戈士向右:BAAAKgAECgIIAgAAAA==.',['原来']='原来乳刺:BAAAKgAECggICgAAAA==.',['叮裆']='叮裆猫:BAAAKgAECgEIAQAAAA==.',['吖土']='吖土豆丶:BAAAKgADCggICAAAAA==.',['咕咕']='咕咕伊雯:BAAAKgAECgcICgAAAA==.',['嗜血']='嗜血天启领主:BAAAKgAFFAQIBAAAAA==.嗜血总裁:BAAAKgAFFAQIBAAAAA==.',['嘿小']='嘿小猩猩:BAABKgAECn8ZAAIQAAgIVw8NTgBVAQAQAAgIVw8NTgBVAQAAAA==.',['土丢']='土丢丢:BAAAKgAFFAIIAgAAAA==.',['大家']='大家说累不累:BAAAKgAECgYIBgAAAA==.',['大橙']='大橙崽汁:BAAAKgADCgMIAwAAAA==.',['大老']='大老白:BAAAKgAFFAEIAQAAAA==.',['天后']='天后:BAAAKgAECgYICAAAAA==.',['天桥']='天桥大呲花:BAAAKgADCgQIBAAAAA==.',['天雷']='天雷滚滚:BAAAKgADCgEIAQAAAA==.',['威震']='威震天大王:BAAAKgADCgEIAQAAAA==.',['孤獨']='孤獨聖臦:BAAAKgAFFAgIAgAAAA==.',['客串']='客串女配角:BAAAKgADCgYIBgAAAA==.',['害羞']='害羞的裤兜:BAABKgAFFH8FAAMDAAUIkBP1CwDXAAADAAQIcxL1CwDXAAAEAAEI5ha4LwBTAAABKgAFFAgIFAARAMYaAA==.',['将离']='将离:BAAAKgADCgQIBAAAAA==.',['小小']='小小瑞鸡:BAAAKgAECggIDwAAAA==.小小的德鲁:BAAAKgAECggIEAAAAA==.小小钢琴手:BAABKgAFFH8IAAISAAgInAUMDAB0AQASAAgInAUMDAB0AQAAAA==.',['小牙']='小牙牙妹:BAAAKgADCggIDQAAAA==.',['小瑞']='小瑞鸡:BAAAKgADCggIEAAAAA==.',['小白']='小白兔骑士:BAAAKgAECggIDwAAAA==.',['小黑']='小黑胖子:BAAAKgAECgUIBQAAAA==.',['尐桔']='尐桔猫:BAAAKgAFFAIIAgAAAA==.',['尐灬']='尐灬骑师:BAAAKgAFFAMIAwAAAA==.',['少喝']='少喝酒多吃肉:BAABKgAFFH8SAAMJAAYILB29BAAoAQAIAAYIoxzACQDAAQAJAAQINyC9BAAoAQAAAA==.',['尛曦']='尛曦:BAABKgAFFH8QAAIHAAYIchxDCwCWAQAHAAYIchxDCwCWAQAAAA==.',['开门']='开门拉人:BAACKgAFFH8IAAINAAQIBSLPHAAhAQANAAQIBSLPHAAhAQAqAAQKfxkAAw0ACAjrHXUgAAICAA0ACAhmHHUgAAICABMABQg8HIMxADEBAAAA.',['愤怒']='愤怒的大虾:BAAAKgAFFAQIBAAAAA==.',['托莱']='托莱多:BAABKgAECn8XAAIUAAgIHAMxUQBoAAAUAAgIHAMxUQBoAAAAAA==.',['放肆']='放肆的龙城:BAAAKgAECgUIBQAAAA==.',['无影']='无影腿妹妹:BAAAKgADCggICAAAAA==.',['无脑']='无脑审判:BAAAKgAECgMIAwAAAA==.',['无言']='无言:BAAAKgAECggICAAAAA==.',['星願']='星願丿天堂:BAAAKgAECgUIBwAAAA==.',['暗之']='暗之轨迹:BAABKgAFFH8KAAMNAAYIoxxPEQCAAQANAAYIoxxPEQCAAQAVAAQImwwoEgCrAAAAAA==.',['暴力']='暴力解決:BAAAKgAECggICAAAAA==.',['暴怒']='暴怒丨天使:BAAAKgAECgcIBwAAAA==.',['未来']='未来:BAAAKgAECggICAAAAA==.',['本多']='本多忠胜:BAAAKgAECgMIAwAAAA==.',['枫皓']='枫皓:BAAAKgAECgEIAQAAAA==.',['桐桐']='桐桐丶含含:BAAAKgAECgQIBAAAAA==.',['毛麦']='毛麦坑坑:BAABKgAFFH8LAAMMAAYI7R36BwDGAQAMAAYI7R36BwDGAQAGAAQI7hFJEQC3AAABKgAFFAgIFgAHANkUAA==.毛麦狮驼史:BAABKgAFFH8GAAMKAAYI1A0JEgAEAQAKAAUIpg0JEgAEAQAPAAEIjA7fFABIAAABKgAFFAgICgABAK0lAA==.毛麦绝绝子:BAABKgAFFH8GAAIWAAYIHwmsCABaAQAWAAYIHwmsCABaAQAAAA==.毛麦菜鸡:BAABKgAFFH8GAAIRAAYIix44BgCyAQARAAYIix44BgCyAQAAAA==.毛麦非狗:BAAAKgAFFAQIBAAAAA==.',['永远']='永远的永远:BAAAKgAECgUIBQAAAA==.',['汉德']='汉德汗死:BAAAKgAECggICAAAAA==.',['沉香']='沉香:BAAAKgAECgQIBgAAAA==.',['浪子']='浪子无脚鸟:BAABKgAFFH8LAAIQAAQIGiCMGgAVAQAQAAQIGiCMGgAVAQAAAA==.',['深攻']='深攻鲍:BAAAKgAECgIIAgAAAA==.',['清秀']='清秀才子:BAAAKgAECgQIBAAAAA==.',['渴饮']='渴饮风霜:BAABKgAECn8VAAQPAAgI4xkZOACNAQAPAAUIySEZOACNAQAOAAQINA6AeQCXAAAKAAQIbQ51cgCLAAAAAA==.',['湘南']='湘南海鸥:BAABKgAFFH8IAAMEAAYI3xIyAgChAQAEAAYIvBEyAgChAQADAAIIChVtGgB9AAAAAA==.',['满满']='满满回忆:BAAAKgADCggICAAAAA==.',['火鸡']='火鸡味锅巴:BAAAKgAECgEIAQAAAA==.',['灵狐']='灵狐仙:BAAAKgAECgMIAwAAAA==.',['灵魂']='灵魂鸡公煲:BAAAKgAECgcIBwAAAA==.',['热情']='热情的芬芳:BAAAKgAECgUIBQAAAA==.',['牛氣']='牛氣冲天:BAAAKgADCgEIAQAAAA==.',['犀利']='犀利的满满:BAAAKgAFFAQIBAAAAA==.',['狄菲']='狄菲尔:BAAAKgAFFAQIBAAAAA==.',['猫之']='猫之轨迹:BAABKgAFFH8LAAIRAAQIZhqtGADaAAARAAQIZhqtGADaAAAAAA==.',['疾风']='疾风之刃云雾:BAAAKgADCggICAAAAA==.',['瞄人']='瞄人奉:BAABKgAECn8VAAIBAAgIgRJFfgBTAQABAAgIgRJFfgBTAQAAAA==.',['秋深']='秋深渐入冬:BAABKgAECn8YAAIPAAgIdhEVMQA/AQAPAAgIdhEVMQA/AQAAAA==.',['等下']='等下个季节:BAAAKgAFFAQIBAAAAA==.',['粉色']='粉色回忆:BAACKgAFFH8IAAIBAAMI+h+nNAAXAQABAAMI+h+nNAAXAQAqAAQKfxkAAgEACAjPJFQPANECAAEACAjPJFQPANECAAAA.',['糖豆']='糖豆不甜:BAAAKgADCggICQAAAA==.',['绝版']='绝版东东:BAAAKgAECggICAABKgAFFAgIEwANADQUAA==.',['美女']='美女如画:BAAAKgADCgIIAgAAAA==.',['耐瑟']='耐瑟瑞尔:BAAAKgAFFAQIBAABKgAFFAgIBAAXAAAAAA==.',['联盟']='联盟招牌:BAABKgAFFH8QAAQYAAgIUhRCCgDdAAAZAAYIlhAXCgAAAQAQAAUIlAKMEADiAAAYAAQIlQ9CCgDdAAAAAA==.',['脱了']='脱了缰的脂肪:BAAAKgADCgEIAQAAAA==.',['菝菝']='菝菝:BAAAKgADCgUIBQAAAA==.',['菩提']='菩提小牧:BAAAKgAECgMIBAAAAA==.',['融化']='融化的召唤:BAAAKgAECggICQAAAA==.',['融雪']='融雪:BAAAKgAECgQIBAAAAA==.',['蟹子']='蟹子莱莱:BAAAKgAECgUIBgAAAA==.',['血夜']='血夜圣光:BAACKgAFFH8ZAAMBAAQIPQn2LACyAAABAAQIPQn2LACyAAACAAQINwH2KABIAAAqAAQKfxYAAwEABwilCnfYAPMAAAEABgiODHfYAPMAAAIAAwiQA75YAD0AAAAA.',['血祖']='血祖大师:BAAAKgAECgQIBAAAAA==.',['诡异']='诡异墨水:BAAAKgAECgEIAQAAAA==.诡异的猎:BAAAKgAECggICAAAAA==.诡异魔劫:BAAAKgAECgQIAgAAAA==.',['诺香']='诺香皇一号:BAAAKgAECgcIEAAAAA==.诺香皇十一号:BAAAKgAECgEIAQAAAA==.诺香皇十二号:BAAAKgAECgcIEQAAAA==.',['过去']='过去也是人:BAAAKgAECgQIBAAAAA==.',['还不']='还不错:BAAAKgAECgYICgAAAA==.',['那一']='那一秒丶後灬:BAAAKgAECgcIDwAAAA==.',['邪恶']='邪恶摇粒绒:BAABKgAFFH8GAAMMAAYIUhr1EwDpAAAMAAQIVBb1EwDpAAAGAAIITyDlHAC7AAABKgAFFAgICAAGAL0eAA==.',['郑映']='郑映宇:BAAAKgAECgMIAwAAAA==.郑映熹:BAABKgAECn8YAAIQAAgIRA6yIQAiAQAQAAgIRA6yIQAiAQAAAA==.',['酌月']='酌月琴曲:BAAAKgADCggICAAAAA==.',['锁甲']='锁甲三废:BAAAKgAFFAIIBAAAAA==.',['阿修']='阿修罗:BAAAKgAECgEIAQAAAA==.',['非人']='非人不如狗:BAABKgAFFH8GAAIaAAYINQ5CEQBSAQAaAAYINQ5CEQBSAQAAAA==.',['风云']='风云之晖:BAAAKgADCgYIBgAAAA==.',['驱风']='驱风者:BAAAKgAECgIIAgAAAA==.',['鬼脸']='鬼脸落堕:BAAAKgAECgIIAwAAAA==.',['鬼蜮']='鬼蜮先驱:BAABKgAFFH8KAAIQAAIIChCeJACJAAAQAAIIChCeJACJAAAAAA==.鬼蜮神箭手:BAAAKgAFFAIIAwAAAA==.',['魇梦']='魇梦:BAABKgAFFH8SAAMCAAYI8yWcAQCUAQABAAYI8yUQCwAWAgACAAYIWhmcAQCUAQAAAA==.',['魔羯']='魔羯:BAAAKgADCgEIAQAAAA==.',['鵰花']='鵰花酒:BAAAKgAECgQIBQAAAA==.',['麦兜']='麦兜炎爆贼溜:BAAAKgADCgEIAQAAAA==.麦兜的凩虱:BAAAKgAFFAQIBAAAAA==.麦兜的敵氪:BAABKgAECn8YAAIGAAgIvgT4OACeAAAGAAgIvgT4OACeAAABKgAFFAgIDwARAMcVAA==.麦兜的朮爹:BAAAKgADCggICAAAAA==.',['麻绳']='麻绳上网:BAAAKgAECgcIDAAAAA==.',['黎明']='黎明前的挽歌:BAAAKgADCggICAAAAA==.',['黑暗']='黑暗拥抱:BAABKgAFFH8GAAIEAAYIvxzZCQB6AQAEAAYIvxzZCQB6AQAAAA==.',['龘翼']='龘翼:BAAAKgAECgYIBgAAAA==.',['龙城']='龙城少帅:BAAAKgADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end