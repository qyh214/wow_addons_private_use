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
 local lookup = {'DeathKnight-Frost','DemonHunter-Havoc','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','DeathKnight-Blood','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Mage-Arcane','Mage-Frost','DemonHunter-Vengeance','Rogue-Outlaw','Rogue-Assassination','Priest-Holy','Shaman-Restoration','Paladin-Protection','Paladin-Retribution','Warrior-Protection','Monk-Brewmaster','Shaman-Elemental','Warlock-Affliction','Hunter-Marksmanship','Warrior-Fury','Druid-Feral','Monk-Mistweaver','Paladin-Holy','Druid-Guardian','Warrior-Arms','Priest-Shadow','Priest-Discipline',}; local provider = {region='CN',realm='瓦里玛萨斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Allylmy:BAAALAAECgQIBwAAAA==.',As='Asetulip:BAABLAAFFH8bAAIBAAUI5Bt6LADnAAABAAUI5Bt6LADnAAAAAA==.',De='Derson:BAAALAAECgIIAwAAAA==.Dersonemo:BAAALAAFFAEIAQAAAA==.',Dh='Dht:BAAALAAECggICAAAAA==.',Do='Doha:BAAALAADCgMIAwAAAA==.Dotk:BAABLAAFFH8GAAIBAAII5gyWhwBCAAABAAII5gyWhwBCAAAAAA==.',Dr='Drlzl:BAAALAAECgYIBwAAAA==.',Fi='Filianore:BAAALAADCgIIAgAAAA==.',Fq='Fq:BAAALAAECggICAAAAA==.',Ha='Hana:BAAALAADCgUIBwAAAA==.',Hu='Hunterlane:BAAALAADCgUIBQAAAA==.',Jo='Jomi:BAAALAAFFAIIAgAAAA==.',Ke='Keyker:BAAALAADCgYIBgAAAA==.',Lu='Luciddream:BAAALAAECgYIBgAAAA==.',Lz='Lzhl:BAAALAAECgYIDgAAAA==.',Ma='Many:BAAALAAECgYIBgAAAA==.',Me='Melisandra:BAAALAAFFAEIAQAAAA==.',Qi='Qiuninga:BAAALAADCgIIAgAAAA==.',Sh='Shalltear:BAAALAAECggICAAAAA==.',Su='Summel:BAACLAAFFH8LAAIBAAUIHhQlRAAqAQABAAUIHhQlRAAqAQAsAAQKfxYAAgEABghpHY49AIkBAAEABghpHY49AIkBAAAA.Summor:BAAALAAECgUIBQABLAAFFAUICwABAB4UAA==.',Ta='Taste:BAAALAADCgQIBAAAAA==.',Ti='Timmy:BAABLAAFFH8VAAICAAYIAx6fCAAVAgACAAYIAx6fCAAVAgAAAA==.',Zo='Zotk:BAABLAAFFH8GAAIDAAIIfAuqaACFAAADAAIIfAuqaACFAAAAAA==.',Zy='Zyzlzhl:BAAALAAECgQIBAAAAA==.',['一人']='一人之下:BAAALAAECgUIBQAAAA==.',['一库']='一库:BAAALAAECgUIBQAAAA==.',['一森']='一森林一:BAACLAAFFH9FAAMEAAgIWCLcAQDCAgAEAAgIWCLcAQDCAgAFAAEIwBJmWABAAAAsAAQKfzQAAwQACAjmJTsEAGQDAAQACAjmJTsEAGQDAAUABQhxEYKIAAoBAAAA.',['一点']='一点点高:BAAALAAECgYIDgAAAA==.',['上官']='上官凌:BAAALAAECgYIBgABLAAFFAMIGwADAB8SAA==.上官淡雅:BAAALAAECggICAAAAA==.',['不曾']='不曾离去:BAAALAADCgQIBAAAAA==.',['且听']='且听风之吟:BAABLAAFFH8PAAQBAAIIFhm1cQBPAAAGAAIIVwpkEwBxAAABAAIIFhm1cQBPAAAHAAEIHwZaHwBIAAAAAA==.',['且末']='且末:BAACLAAFFH8LAAIIAAIICRMQRACTAAAIAAIICRMQRACTAAAsAAQKfykAAwgACAgTGkUvAIECAAgACAgTGkUvAIECAAkABAj5EKVjAOkAAAAA.',['丛林']='丛林是我家:BAAALAADCgYIBgAAAA==.',['丝路']='丝路花雨:BAABLAAFFH8GAAIKAAYIwBxcHwCZAQAKAAYIwBxcHwCZAQAAAA==.',['丨夢']='丨夢遂丶灵:BAAALAAECgUIBQAAAA==.',['丨我']='丨我宝宝呢:BAAALAAFFAIIAwAAAA==.',['丨遗']='丨遗忘丶夢:BAAALAAECgYIEQAAAA==.',['丨魔']='丨魔丶芯:BAACLAAFFH8GAAICAAIIHhc/PACcAAACAAIIHhc/PACcAAAsAAQKfyMAAgIACAgWIpEYAAUDAAIACAgWIpEYAAUDAAAA.',['乘风']='乘风子:BAAALAADCgMIAwAAAA==.',['九战']='九战而死:BAABLAAFFH8FAAIBAAUIeyUVLgCBAQABAAUIeyUVLgCBAQAAAA==.',['九羅']='九羅:BAAALAADCgcICAAAAA==.',['二月']='二月红:BAAALAADCggICAAAAA==.',['仗剑']='仗剑而行:BAABLAAFFH8GAAICAAIIXRiXOgCdAAACAAIIXRiXOgCdAAAAAA==.',['仟丶']='仟丶沨:BAABLAAFFH8KAAMKAAMI/ghYNAC3AAAKAAMI/ghYNAC3AAALAAEInQfqIQA7AAAAAA==.仟丶锋:BAABLAAECn8ZAAMCAAYIoB28MQCRAQACAAYIpBy8MQCRAQAMAAEIShspYABMAAAAAA==.',['休屠']='休屠:BAAALAADCggICAAAAA==.',['传说']='传说之傲皇:BAAALAAECgYIBgAAAA==.',['你瞅']='你瞅啥:BAAALAAECgYIDQAAAA==.',['倾城']='倾城月:BAABLAAFFH8HAAIFAAIIYAsvSgBcAAAFAAIIYAsvSgBcAAAAAA==.',['六岁']='六岁逃课接怪:BAAALAAECgMIBAAAAA==.',['冯万']='冯万宁别整我:BAAALAAFFAIIBAAAAA==.',['冰血']='冰血邪魂:BAABLAAFFH8MAAIGAAIIwgk9HAAwAAAGAAIIwgk9HAAwAAAAAA==.',['冰镇']='冰镇血樱桃:BAAALAAFFAIIBAAAAA==.',['冲锋']='冲锋来咯:BAAALAAECgEIAQAAAA==.',['凝馨']='凝馨:BAABLAAFFH8IAAMNAAIIaxpXBACdAAANAAII9BdXBACdAAAOAAEIaBa/IQBSAAAAAA==.',['别感']='别感冒了:BAAALAADCgcIBwAAAA==.',['功夫']='功夫小麦迪:BAAALAADCgMIAwAAAA==.',['加勒']='加勒比幽兰:BAAALAAECgYICgAAAA==.',['劳诗']='劳诗丹顿:BAAALAADCgIIAgAAAA==.',['勒恩']='勒恩:BAAALAAECgYIBgAAAA==.',['北派']='北派德爷:BAAALAAECggICAAAAA==.',['十亿']='十亿少女的梦:BAAALAAECggIBgAAAA==.',['千棱']='千棱幻玉:BAABLAAFFH8RAAIPAAMI3h+gIgCvAAAPAAMI3h+gIgCvAAAAAA==.',['千煌']='千煌雷烈:BAABLAAFFH8IAAIQAAII5B2IRgCSAAAQAAII5B2IRgCSAAAAAA==.',['反者']='反者道之动:BAABLAAFFH8GAAIDAAII3iTmNQC4AAADAAII3iTmNQC4AAAAAA==.',['发光']='发光的蹄妹:BAACLAAFFH8KAAMRAAMIohHbEQBmAAASAAIIERa2OQCjAAARAAMI4gzbEQBmAAAsAAQKfxQAAxEABghuHuMqALEBABIABgiLHbuTAMsBABEABghZGOMqALEBAAAA.',['取名']='取名废:BAAALAAECgcIEwAAAA==.',['吃苹']='吃苹果:BAAALAADCgQIBAAAAA==.',['后盾']='后盾:BAABLAAFFH8GAAIDAAIIOA9CowA9AAADAAIIOA9CowA9AAAAAA==.',['哈楸']='哈楸楸:BAAALAAFFAYIAwAAAA==.',['啤酒']='啤酒杯:BAAALAADCgIIAgAAAA==.',['噶懒']='噶懒哒:BAABLAAFFH8WAAIDAAYIfR/7GQDNAQADAAYIfR/7GQDNAQAAAA==.',['四点']='四点水:BAAALAADCgQIBAAAAA==.',['四糸']='四糸乃:BAAALAAECgYIBgAAAA==.',['困死']='困死了:BAAALAADCgQIBAAAAA==.',['圣光']='圣光小熊:BAAALAAFFAEIAQAAAA==.',['圣菲']='圣菲尔璐丝:BAAALAADCgcIBwAAAA==.',['地狱']='地狱恶魔:BAABLAAFFH8FAAICAAUIsRY1KgBCAQACAAUIsRY1KgBCAQAAAA==.地狱龙战:BAABLAAFFH8GAAITAAYI8hKwEABGAQATAAYI8hKwEABGAQAAAA==.地狱龙术:BAABLAAFFH8GAAIIAAYIyxtaJACJAQAIAAYIyxtaJACJAQAAAA==.地狱龙骑:BAABLAAFFH8MAAMSAAYIGRgFGACSAQASAAYIGRgFGACSAQARAAEIdwEbJAAfAAAAAA==.',['埃蒙']='埃蒙之刃:BAAALAAECgQIBAAAAA==.',['塔兰']='塔兰吉祥:BAAALAADCgEIAQAAAA==.',['壮哉']='壮哉我大圣堂:BAABLAAFFH8HAAIUAAIIbhCJHgA8AAAUAAIIbhCJHgA8AAABLAAFFAIIDwABABYZAA==.',['夢魇']='夢魇峥:BAAALAADCgQIBAAAAA==.',['大乖']='大乖乖想做猫:BAABLAAFFH8GAAIKAAYIrAEJRACTAAAKAAYIrAEJRACTAAAAAA==.',['大杰']='大杰森:BAABLAAFFH8LAAMQAAMI9RjUGgDfAAAQAAMI9RjUGgDfAAAVAAIIcQOcNQB8AAAAAA==.',['大秦']='大秦帝主:BAAALAADCgYIDwAAAA==.',['大羿']='大羿:BAAALAADCgYIBgAAAA==.',['大耳']='大耳朵图图:BAAALAAFFAIIBAAAAA==.',['大菊']='大菊已定:BAAALAAECgYIBgAAAA==.',['天地']='天地灰烬:BAACLAAFFH8HAAICAAMIkR0qMACpAAACAAMIkR0qMACpAAAsAAQKfxUAAgIABgiPJCMeAPIBAAIABgiPJCMeAPIBAAAA.',['天天']='天天蓝天天:BAAALAAFFAEIAQABLAAFFAIIDwABABYZAA==.天天要吃糖:BAAALAAECgMIAwAAAA==.',['夸父']='夸父捉日:BAAALAADCgYIBgAAAA==.',['奥利']='奥利维亚:BAABLAAFFH8KAAIUAAII/wg4HQBSAAAUAAII/wg4HQBSAAAAAA==.',['奶白']='奶白滴雪子:BAAALAAECggIBgAAAA==.',['奶香']='奶香小熊酱:BAAALAAFFAIIAgAAAA==.',['妖铃']='妖铃铃捌陆:BAAALAAECgYICAAAAA==.',['妞妞']='妞妞拧牛牛:BAAALAADCgQIBAAAAA==.',['妹妹']='妹妹去哪了:BAAALAAECgcIEwAAAA==.',['娅蓝']='娅蓝:BAABLAAFFH8FAAISAAMIewXDSQByAAASAAMIewXDSQByAAAAAA==.',['子夜']='子夜祭魂:BAAALAAFFAIIAgAAAA==.',['孝庄']='孝庄太后:BAAALAAFFAIIBAAAAA==.',['孤灯']='孤灯守夜人:BAAALAAFFAIIBAAAAA==.',['安东']='安东尼雷克斯:BAABLAAFFH8VAAMIAAUIvRa3NABAAQAIAAQISRS3NABAAQAJAAIITBgLFABEAAAAAA==.',['完美']='完美净化:BAABLAAFFH8GAAISAAIItxNYRgCaAAASAAIItxNYRgCaAAAAAA==.',['富贵']='富贵满堂:BAABLAAECn8UAAIDAAYIrByQYQB/AQADAAYIrByQYQB/AQAAAA==.',['射月']='射月战将:BAAALAADCgQIBAAAAA==.',['小乔']='小乔刘水人家:BAABLAAFFH8FAAIQAAIItwl5ZwBTAAAQAAIItwl5ZwBTAAAAAA==.',['小小']='小小阿宝:BAAALAADCgUICQAAAA==.',['小德']='小德玛利亚:BAAALAAECgYIBwAAAA==.',['小恶']='小恶魔在哪:BAABLAAFFH8pAAMIAAcInhWFFwDOAQAIAAcIjBSFFwDOAQAWAAIIzw8uBACqAAAAAA==.',['小莫']='小莫加:BAAALAAECgYIDAAAAA==.',['小虫']='小虫贝贝:BAAALAAECgIIAgAAAA==.',['小魚']='小魚:BAAALAAFFAIIAgAAAA==.',['小鱼']='小鱼人:BAABLAAECn8XAAILAAcINBMvGQBZAQALAAcINBMvGQBZAQAAAA==.',['巧克']='巧克力甜甜圈:BAABLAAFFH8LAAITAAYIlRh5BgClAQATAAYIlRh5BgClAQAAAA==.',['市南']='市南吴彦祖:BAAALAAFFAEIAQAAAA==.',['常德']='常德东哥:BAABLAAFFH8HAAMFAAIIRAdoQQBeAAAFAAIIRAdoQQBeAAAEAAIIxwFIKwBUAAAAAA==.常德射击猎:BAABLAAFFH8KAAIDAAUIDxhbTQAYAQADAAUIDxhbTQAYAQAAAA==.常德雷神:BAAALAAFFAIIAwAAAA==.',['平凡']='平凡的爷们:BAAALAAECgYIBwAAAA==.',['幻风']='幻风化雨:BAAALAADCgUIBwAAAA==.',['幽幽']='幽幽天狼:BAABLAAFFH8hAAMDAAYIDR2hQQBBAQADAAUIBB6hQQBBAQAXAAQI2xs8CgACAQAAAA==.幽幽天瞎:BAABLAAFFH8GAAICAAIIswrcVACHAAACAAIIswrcVACHAAAAAA==.幽幽天行:BAAALAAECgYIBgAAAA==.',['库斯']='库斯卡雷:BAAALAAFFAIIAgAAAA==.',['弹指']='弹指托油塔:BAAALAAECgYIBgAAAA==.',['影刃']='影刃:BAAALAAECggICAAAAA==.',['彼岸']='彼岸繁花:BAABLAAFFH8KAAIQAAII4xF7UQBqAAAQAAII4xF7UQBqAAAAAA==.',['德妃']='德妃魅儀:BAAALAADCgEIAQAAAA==.',['德意']='德意雄鹰:BAAALAAECgYIDQAAAA==.',['怒海']='怒海孤鸿:BAAALAAECgIIAwAAAA==.',['思想']='思想在奔跑:BAAALAADCgIIAgAAAA==.',['恒毅']='恒毅:BAAALAAECgYIBgAAAA==.',['悠茗']='悠茗:BAABLAAFFH8QAAIDAAUIpA82VAD+AAADAAUIpA82VAD+AAAAAA==.',['想个']='想个名字先:BAACLAAFFH8WAAISAAMIrSVZIADQAAASAAMIrSVZIADQAAAsAAQKfxcAAhIACAiNJKYKAFYDABIACAiNJKYKAFYDAAAA.',['愤怒']='愤怒孤鸿:BAAALAAFFAIIAwAAAA==.',['慈溪']='慈溪太后:BAAALAAFFAIIAgAAAA==.',['战小']='战小战:BAABLAAECn8fAAIYAAYImAi1ZADnAAAYAAYImAi1ZADnAAAAAA==.',['挽歌']='挽歌独唱:BAAALAAECgYICwAAAA==.',['救世']='救世者:BAAALAADCggICAAAAA==.',['断罪']='断罪之箭:BAAALAAECgMIAwAAAA==.',['无愧']='无愧于心:BAAALAADCgYIBgAAAA==.',['无梦']='无梦之眠:BAABLAAFFH8PAAMFAAUI5gyJIgAIAQAFAAUI5gyJIgAIAQAZAAIIOwQNEQAzAAAAAA==.',['无雨']='无雨之鱼:BAAALAADCggICAAAAA==.',['时光']='时光:BAAALAAECgYIBgAAAA==.',['星街']='星街彗星:BAAALAAECgYIDAAAAA==.',['星雪']='星雪火:BAAALAADCgQIBAAAAA==.',['晓開']='晓開心:BAAALAAECggICAAAAA==.',['暗夜']='暗夜魅姬:BAABLAAFFH8GAAIMAAIIrAeTGAAkAAAMAAIIrAeTGAAkAAAAAA==.',['暗影']='暗影屠魔:BAAALAAECgYICAAAAA==.',['曾相']='曾相识再相逢:BAAALAAECgYICQAAAA==.',['月光']='月光晨泪:BAABLAAFFH8IAAIFAAUIlxQ1GgBbAQAFAAUIlxQ1GgBbAQAAAA==.',['月舞']='月舞:BAAALAAECgYIBgAAAA==.',['朝青']='朝青暮雪:BAAALAADCggICAAAAA==.',['木雅']='木雅贡嘎:BAAALAAECggICAAAAA==.',['来了']='来了老弟:BAAALAAECgYICwAAAA==.',['杯中']='杯中喵:BAAALAAECggICgAAAA==.',['林灵']='林灵灵:BAAALAADCgQIBAAAAA==.',['桐人']='桐人君:BAAALAADCgYIBgAAAA==.',['欧阳']='欧阳翠竹:BAAALAAECgcIDQAAAA==.',['永夜']='永夜星澜:BAAALAADCgMIAwAAAA==.',['派大']='派大星:BAAALAAECgYIDwAAAA==.',['济世']='济世清风:BAAALAADCgQIBAAAAA==.',['浮光']='浮光掠影:BAACLAAFFH8IAAIaAAIIeAV7FgBxAAAaAAIIeAV7FgBxAAAsAAQKfxUAAxoABwgwEysnAGoBABoABwgwEysnAGoBABQABgiYFoAPAEoBAAAA.',['海绵']='海绵宝宝:BAAALAAECgIIAgAAAA==.',['淡蛋']='淡蛋的忧伤:BAACLAAFFH8QAAIbAAYIDyPsBQDWAQAbAAYIDyPsBQDWAQAsAAQKfyMAAxIACAgTJIU8AIUCABIABgg6JYU8AIUCABsACAgKHHsZAEICAAAA.',['清风']='清风朗月:BAABLAAFFH8GAAILAAII0hH1EwCFAAALAAII0hH1EwCFAAAAAA==.清风清风:BAABLAAFFH8IAAIcAAIInA/yCABrAAAcAAIInA/yCABrAAAAAA==.清风萨萨:BAAALAAFFAIIAgAAAA==.',['温柔']='温柔丑丑:BAABLAAECn8rAAMYAAcIUQ3uhgB4AQAYAAcIGw3uhgB4AQATAAcI3AcBYQAEAQAAAA==.',['湮灭']='湮灭审判:BAAALAADCgEIAQAAAA==.',['火法']='火法麦迪:BAAALAADCgYIBgAAAA==.',['灭世']='灭世战狂:BAAALAAECgEIAQAAAA==.',['灵仙']='灵仙:BAAALAAECgYICQAAAA==.',['热乎']='热乎的烧饼:BAAALAAECgEIAQAAAA==.',['熊壹']='熊壹:BAAALAADCgYIBgAAAA==.',['爱摸']='爱摸高压线:BAAALAADCgYIBgAAAA==.',['牙香']='牙香菜缝:BAAALAAECggICAABLAAFFAgIBgAbAOIhAA==.',['牛牛']='牛牛就是牛:BAAALAADCgMIAwAAAA==.牛牛纽妞妞:BAAALAADCgYICAAAAA==.',['特利']='特利丝杰娜:BAAALAAECgEIAQAAAA==.',['特立']='特立独行的猪:BAAALAAECgYIBgAAAA==.',['狐人']='狐人小麦迪:BAAALAADCgMIAwAAAA==.',['猎杀']='猎杀新手:BAAALAAECgMIAwAAAA==.',['猎魔']='猎魔者:BAAALAAECgMIAwAAAA==.',['玉照']='玉照夜:BAAALAAECgUIBgAAAA==.',['王大']='王大锤丶:BAAALAAECgUIBQAAAA==.',['琉璃']='琉璃:BAAALAAECgQIBAAAAA==.',['琻色']='琻色暗影:BAAALAAECgYIBgAAAA==.',['甜梦']='甜梦:BAAALAADCggICAAAAA==.',['甜狗']='甜狗:BAAALAADCggICAAAAA==.',['画月']='画月为牢:BAACLAAFFH8OAAIDAAYIQR7UGwDEAQADAAYIQR7UGwDEAQAsAAQKfzMAAgMACAh5IKcYAGgCAAMACAh5IKcYAGgCAAAA.',['番茄']='番茄电竞老李:BAABLAAFFH8IAAIVAAMItAsaOQB0AAAVAAMItAsaOQB0AAAAAA==.',['疯牛']='疯牛:BAAALAAECgQIBAAAAA==.',['白太']='白太子奶:BAAALAAECgEIAQAAAA==.',['白狼']='白狼王:BAAALAAECgYIBwAAAA==.',['白银']='白银之灵:BAAALAADCgYICgAAAA==.',['白露']='白露凝霜:BAAALAAECgYIDAAAAA==.',['相思']='相思重相忆:BAAALAAECggICAAAAA==.',['神偷']='神偷何家庆:BAAALAAECgYIBAAAAA==.',['神秘']='神秘百合:BAAALAAECgYIBgAAAA==.',['章鱼']='章鱼哥:BAAALAAECgYIBgAAAA==.',['符文']='符文斩杀者:BAABLAAFFH8NAAITAAIIXRQ1HQCEAAATAAIIXRQ1HQCEAAABLAAFFAIIDwABABYZAA==.',['筱纯']='筱纯甄:BAAALAAECgQIBgAAAA==.',['算命']='算命的:BAAALAADCgUIBgAAAA==.',['索尔']='索尔雷神:BAABLAAFFH8FAAIVAAMIfArsOgBjAAAVAAMIfArsOgBjAAAAAA==.',['紫之']='紫之上:BAAALAAECgYIDAAAAA==.',['维纳']='维纳斯:BAAALAAECgYIBgAAAA==.',['罪之']='罪之辛德蕾拉:BAAALAADCgcIBwAAAA==.',['翠色']='翠色芳菲:BAABLAAFFH8OAAIMAAIIvBE3EAB0AAAMAAIIvBE3EAB0AAABLAAFFAIIDwABABYZAA==.',['老鼠']='老鼠夹子:BAAALAADCgEIAQAAAA==.',['脏弹']='脏弹:BAAALAAECgYIBgAAAA==.',['脱战']='脱战了才假死:BAAALAAECgYIEwAAAA==.',['花果']='花果山:BAABLAAECn8YAAISAAYI/SOILADhAQASAAYI/SOILADhAQAAAA==.',['花花']='花花下的太阳:BAAALAAECgEIAQAAAA==.花花下的月亮:BAAALAAECgMIAwAAAA==.花花有喜了:BAAALAAECgYIBgAAAA==.花花生西西:BAAALAAECgYIEgAAAA==.',['苏达']='苏达姬:BAABLAAECn8WAAIPAAcIxwLjSgCsAAAPAAcIxwLjSgCsAAAAAA==.',['荷鲁']='荷鲁斯:BAAALAAECgEIAQAAAA==.',['莉卡']='莉卡茜娜:BAACLAAFFH8bAAMDAAMIHxKLbACJAAADAAMIHxKLbACJAAAXAAIIcw5tJQB9AAAsAAQKfzUAAxcACAjnF6AyAPcBABcACAiKFaAyAPcBAAMABgh4Go1fAIMBAAAA.',['菲尔']='菲尔加斯:BAABLAAECn8WAAICAAYIdQ90xQBQAQACAAYIdQ90xQBQAQABLAAFFAMIGwADAB8SAA==.',['萨普']='萨普:BAAALAAECggICAAAAA==.',['蓝色']='蓝色法神:BAABLAAFFH8GAAILAAIIUw7mHAA3AAALAAIIUw7mHAA3AAAAAA==.蓝色游魂:BAABLAAFFH8IAAMDAAII6g9/mwBAAAADAAII6g9/mwBAAAAXAAEIqQuwNgA7AAABLAAFFAYIHgAXAA4gAA==.蓝色萨满:BAABLAAFFH8LAAMQAAII8AVDawBUAAAQAAII8AVDawBUAAAVAAIIZA4fSAA/AAAAAA==.',['蜡笔']='蜡笔不二熊:BAACLAAFFH8KAAIEAAIIjwvBNQA6AAAEAAIIjwvBNQA6AAAsAAQKf0IAAwUABghQGMcvAG0BAAUABghQGMcvAG0BAAQABghYFeUkAEoBAAAA.',['蟹老']='蟹老板:BAAALAAECgYIBgAAAA==.',['血色']='血色七公主:BAAALAADCgYIBwAAAA==.血色九公主:BAAALAAECgYIDAAAAA==.血色九殿下:BAAALAAECgUIBQAAAA==.血色公主:BAAALAAECgQIBAAAAA==.血色六公主:BAAALAADCgEIAQAAAA==.血色大公主:BAAALAAECgYIEgAAAA==.血色大帝:BAAALAAECgMIAwAAAA==.血色天帝:BAAALAADCgUIBQAAAA==.血色长公主:BAAALAAECgIIAgAAAA==.',['血酬']='血酬定律:BAAALAADCgYIBgAAAA==.',['袴田']='袴田日向:BAACLAAFFH8zAAISAAcI+CBTBABGAgASAAcI+CBTBABGAgAsAAQKfy8AAhIACAh6JTIJAF4DABIACAh6JTIJAF4DAAAA.',['贝塔']='贝塔:BAAALAAECgcIDQAAAA==.',['赫里']='赫里妮亚:BAAALAAECggICAAAAA==.',['踢一']='踢一摁一踢:BAAALAADCgYICAAAAA==.',['蹦迪']='蹦迪的蚕:BAABLAAFFH8IAAIbAAII3RtIFwCkAAAbAAII3RtIFwCkAAAAAA==.',['轻风']='轻风之呢喃:BAABLAAFFH8MAAISAAII8BqtLwCsAAASAAII8BqtLwCsAAABLAAFFAIIDwABABYZAA==.',['辛奇']='辛奇帕克:BAAALAAECgEIAQAAAA==.',['这把']='这把梭吗:BAAALAADCggICAAAAA==.',['迷人']='迷人的小姨子:BAAALAAECggICAAAAA==.',['追星']='追星逐月:BAABLAAFFH8FAAIBAAIIeRpIUAChAAABAAIIeRpIUAChAAAAAA==.',['遗忘']='遗忘者之歌:BAAALAAECgYIBgAAAA==.',['遛弯']='遛弯的蟑螂:BAAALAADCgIIAgAAAA==.',['酒不']='酒不过半盏:BAAALAAFFAIIAgAAAA==.',['醉美']='醉美是相遇:BAAALAAECgYICQAAAA==.',['闇闇']='闇闇糖瓜:BAAALAAFFAMIAwAAAA==.',['闪电']='闪电奔涌:BAABLAAECn8mAAIVAAgI3yFYBwCuAgAVAAgI3yFYBwCuAgAAAA==.',['闪耀']='闪耀的席瑞丝:BAAALAADCgMIAwAAAA==.',['问题']='问题不大:BAAALAAECgYIBgAAAA==.',['防骑']='防骑:BAAALAAECggICAAAAA==.',['阿斯']='阿斯图利亚斯:BAACLAAFFH8kAAIYAAYIShhIFAC4AQAYAAYIShhIFAC4AQAsAAQKfz0ABBgACAhUHC8sAIsCABgACAhUHC8sAIsCABMAAwhnA9CNAFIAAB0AAQilAfVDAAoAAAAA.',['雨霁']='雨霁:BAAALAAECgYICAAAAA==.',['雪花']='雪花菈米:BAACLAAFFH8FAAIKAAMIdAbWSgBuAAAKAAMIdAbWSgBuAAAsAAQKfx0AAgoABgizGwdaAPYBAAoABgizGwdaAPYBAAAA.',['靓仔']='靓仔麦迪:BAAALAADCgQIBwAAAA==.',['面呢']='面呢:BAAALAAECgcIDQAAAA==.',['风之']='风之彩:BAABLAAFFH8GAAICAAYIvyAqFgC1AQACAAYIvyAqFgC1AQAAAA==.',['风云']='风云猎天下:BAAALAAECgMIAwAAAA==.',['马戏']='马戏团出来的:BAAALAAECgYIEAAAAA==.',['骄矜']='骄矜必败:BAABLAAECn8kAAIIAAYIKSK9IgDWAQAIAAYIKSK9IgDWAQAAAA==.',['骆神']='骆神:BAAALAAECgMIBAAAAA==.',['骑士']='骑士奈特:BAAALAADCgYIBgAAAA==.',['骑小']='骑小骑:BAACLAAFFH8YAAISAAMIZhV2QACTAAASAAMIZhV2QACTAAAsAAQKfyIAAhIACAhCGShPAFICABIACAhCGShPAFICAAAA.',['骨龙']='骨龙牙:BAAALAAECgQIBgAAAA==.',['高子']='高子小是天生:BAABLAAFFH8RAAIDAAMIKQ4RcgB9AAADAAMIKQ4RcgB9AAAAAA==.',['高玩']='高玩花花:BAAALAAECgQIBAAAAA==.',['鬼之']='鬼之仙子:BAABLAAFFH8KAAIQAAYIUg/NIgBIAQAQAAYIUg/NIgBIAQAAAA==.',['魅颜']='魅颜火舞:BAAALAADCgEIAQAAAA==.',['魔尊']='魔尊重樓:BAAALAADCgYIBgAAAA==.',['鲜血']='鲜血鸡尾酒:BAABLAAFFH8KAAIQAAII1hFYTwBsAAAQAAII1hFYTwBsAAAAAA==.',['麦当']='麦当劳帮主:BAAALAAECgYIEgAAAA==.',['麦迪']='麦迪小小:BAAALAADCgIIAwAAAA==.',['黑咖']='黑咖啡:BAAALAADCgYIBgAAAA==.',['黑帝']='黑帝斯:BAAALAAECgQIBAAAAA==.',['黑暗']='黑暗安琪:BAAALAAECgYIBgAAAA==.',['黑麦']='黑麦别士忌:BAACLAAFFH8tAAIIAAgI6BpMDQAwAgAIAAgI6BpMDQAwAgAsAAQKfzgAAggACAiCJtMBAIsDAAgACAiCJtMBAIsDAAAA.',['龙吟']='龙吟瑶瑶:BAACLAAFFH8dAAMPAAMIZhh1LADCAAAPAAMIZhh1LADCAAAeAAEIlgNxLwA4AAAsAAQKfzwABA8ACAj7HeoeAH8CAA8ACAiZHeoeAH8CAB8ABAgOGrYZACwBAB4ABghdCUB1ANsAAAAA.龙吟耀耀:BAAALAAECgYIEgAAAA==.',['龙无']='龙无瑕:BAAALAADCgYIDAABLAAFFAMIGwADAB8SAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end