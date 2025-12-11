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
 local lookup = {'Warrior-Protection','DeathKnight-Frost','Hunter-BeastMastery','Warlock-Destruction','Evoker-Augmentation','Evoker-Devastation','Druid-Balance','Druid-Guardian','Paladin-Retribution','Druid-Feral','Druid-Restoration','Rogue-Subtlety','Shaman-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Elemental','Rogue-Assassination','Monk-Brewmaster','Hunter-Marksmanship','Unknown-Unknown','Warrior-Arms','Warrior-Fury','Warlock-Demonology','Mage-Arcane','Mage-Frost','DeathKnight-Blood','Priest-Holy','Priest-Shadow',}; local provider = {region='CN',realm='日落沼泽',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aao:BAAALAAECgYIDgAAAA==.',Al='Alice:BAAALAAFFAIIBAAAAA==.',Bi='Biti:BAAALAADCggICAAAAA==.',Bl='Bloodymonday:BAABLAAFFH82AAIBAAcIoSWeAQCQAgABAAcIoSWeAQCQAgAAAA==.Bluei:BAAALAAECgQIBAAAAA==.',Da='Dammitita:BAAALAAECgQIBAAAAA==.Darkeye:BAAALAAECgYIDAAAAA==.Darkne:BAAALAAECgMIAwAAAA==.',Dk='Dkita:BAAALAAECgYIDgAAAA==.',Ge='Geraltstone:BAAALAAECgMIAwAAAA==.',Gw='Gwendolyn:BAAALAAECgYIBgAAAA==.',Ha='Haroin:BAAALAAECgUIBwAAAA==.',Hn='Hnhunter:BAAALAAECgYICQAAAA==.',Ii='Iilidan:BAAALAAECgIIAgAAAA==.',Jj='Jjdfw:BAAALAAECgcIBwAAAA==.',Kc='Kcsm:BAAALAAECgYIBgAAAA==.Kczs:BAAALAAECgYIBgAAAA==.',Ke='Kel:BAAALAAECgIIAgAAAA==.',Mo='Mokey:BAAALAADCgEIAQAAAA==.',Ne='Neoily:BAAALAAECgYIDAAAAA==.',Pa='Pandaa:BAAALAAECgYIBgAAAA==.',Sa='Saberalter:BAABLAAFFH8GAAICAAYIIBYsLgCBAQACAAYIIBYsLgCBAQAAAA==.Sasaa:BAAALAAECgEIAQAAAA==.',St='Stewen:BAAALAAECgYIEwAAAA==.Stormfjordfa:BAAALAAFFAIIAgAAAA==.',To='Toadoil:BAAALAADCgEIAQAAAA==.',Wo='Woochihmin:BAABLAAECn8YAAIDAAgIMiQhPAByAgADAAgIMiQhPAByAgAAAA==.',Xu='Xu:BAAALAAFFAMIAwAAAA==.',Zx='Zxa:BAABLAAFFH8KAAIEAAIIxyJQQgCVAAAEAAIIxyJQQgCVAAAAAA==.',['一只']='一只小萨:BAAALAADCgIIAgAAAA==.',['一百']='一百个萨满:BAAALAAFFAQIBAAAAA==.',['一纸']='一纸一墨:BAAALAAECgMIAwAAAA==.',['一花']='一花一草:BAAALAAFFAIIBAAAAA==.',['一见']='一见生财:BAAALAAECgYIBgAAAA==.',['七星']='七星龙渊:BAACLAAFFH80AAMFAAgIYBtOAgAyAgAFAAgICRpOAgAyAgAGAAMIFhsaDgD/AAAsAAQKfzUAAwYACAhgI68ZAFECAAYACAg+HK8ZAFECAAUACAjKIjwHACECAAAA.',['万法']='万法行者:BAAALAADCgYIBgAAAA==.',['三射']='三射定乾坤:BAAALAAECgYIBgAAAA==.',['三队']='三队的猎手:BAAALAAFFAIIBAAAAA==.',['上善']='上善若之水:BAAALAAECgYIBgAAAA==.',['不知']='不知道干嘛呀:BAAALAAECggICwAAAA==.',['两层']='两层铁钥匙:BAAALAAECgMIBwAAAA==.',['乔小']='乔小宅:BAABLAAFFH8GAAIDAAYI+xs3KQCPAQADAAYI+xs3KQCPAQAAAA==.',['乖巧']='乖巧:BAAALAAFFAIIBAAAAA==.',['五仁']='五仁月饼呀:BAAALAADCgIIAgAAAA==.',['五六']='五六年:BAAALAADCgMIAwAAAA==.',['仲夏']='仲夏夜之蜜:BAAALAADCgEIAQAAAA==.仲夏夜之风:BAAALAADCgYIBgAAAA==.',['伊俐']='伊俐丹女王:BAAALAADCgYIBgAAAA==.',['会飞']='会飞的萨满:BAAALAADCgMIAwAAAA==.',['伴您']='伴您成长:BAABLAAFFH8JAAMHAAMI5gpaKQBrAAAHAAMI5gpaKQBrAAAIAAIIlgU/EAAlAAAAAA==.',['似水']='似水流年:BAABLAAECn8YAAIJAAYIhhpGUgBoAQAJAAYIhhpGUgBoAQAAAA==.',['你不']='你不要過來啊:BAAALAAECgYIBwAAAA==.',['你杀']='你杀了大臭:BAAALAAECgUIBQABLAAFFAgIDgAKAIIMAA==.',['元丶']='元丶神:BAAALAAECgYIBgAAAA==.',['克拉']='克拉苏斯:BAAALAADCgEIAQAAAA==.',['决戦']='决戦时刻:BAAALAAECgIIAgAAAA==.',['冷無']='冷無情:BAABLAAECn8gAAICAAcImh0CYAA2AgACAAcImh0CYAA2AgAAAA==.',['凉龙']='凉龙虾:BAAALAADCgcICgAAAA==.',['包龙']='包龙星:BAAALAADCgIIAgAAAA==.',['千城']='千城陌兮:BAAALAADCgYIBgAAAA==.',['卩丶']='卩丶聖光灬誠:BAACLAAFFH8NAAMHAAUI9w7eHADpAAAHAAUI9w7eHADpAAALAAII4A4lRwBgAAAsAAQKfxgAAwcABgg4Hl4bAJQBAAcABgg4Hl4bAJQBAAsABgijE8tmAGABAAAA.',['古尒']='古尒丹:BAAALAADCgIIAgAAAA==.',['只会']='只会开无敌:BAABLAAFFH8GAAIJAAII1xjWLACwAAAJAAII1xjWLACwAAAAAA==.',['右亦']='右亦香:BAACLAAFFH8KAAIMAAIINR0PEQCXAAAMAAIINR0PEQCXAAAsAAQKfxsAAgwACAgrH+MEAAgCAAwACAgrH+MEAAgCAAAA.',['呆槑']='呆槑猎:BAAALAADCgEIAQAAAA==.',['咩咩']='咩咩子:BAAALAADCgMIAwAAAA==.咩咩子杀手:BAAALAAFFAIIAgAAAA==.',['哀伤']='哀伤灬之霜:BAAALAADCgYICQAAAA==.',['哈喽']='哈喽恶魔:BAAALAAECgYIDAAAAA==.',['唯唯']='唯唯豆奶:BAAALAADCgMIAwAAAA==.',['啥也']='啥也不是:BAAALAAECgYIDAAAAA==.',['喀秋']='喀秋莎:BAAALAAECgYIEwAAAA==.',['喋血']='喋血乱骑:BAAALAAECgIIAgAAAA==.',['嗜血']='嗜血的传说:BAAALAAECgQIBAAAAA==.',['嘟嘟']='嘟嘟冲呀:BAAALAAECgMIAwAAAA==.',['因为']='因为寂寞:BAAALAAECgYICAAAAA==.',['困兽']='困兽之伊利:BAAALAAFFAIIAgAAAA==.困兽之僧:BAAALAAFFAIIAgAAAA==.困兽之古尔:BAAALAAECgYIBgAAAA==.困兽之希瓦:BAAALAAECgUIBQAAAA==.困兽之德:BAAALAAFFAIIAgAAAA==.困兽之战:BAAALAAFFAIIAgAAAA==.困兽之斗:BAAALAAFFAIIAgAAAA==.困兽之术:BAAALAAECgYICQAAAA==.困兽之死骑:BAAALAAFFAIIAgAAAA==.困兽之法:BAAALAAECgYIBgAAAA==.困兽之牧:BAAALAAECgYICAAAAA==.困兽之猎:BAAALAAECgcIDwAAAA==.困兽之猎头:BAAALAAFFAIIAgAAAA==.困兽之猎手:BAAALAAECgQIBQAAAA==.困兽之萨:BAAALAAFFAIIAgAAAA==.困兽之马库斯:BAAALAAECgQIBQAAAA==.困兽之魔:BAAALAAECgMIAwAAAA==.困兽之龙:BAAALAAECgcIEwAAAA==.',['圣光']='圣光之魂:BAABLAAFFH8GAAIJAAIIKge2dwA5AAAJAAIIKge2dwA5AAAAAA==.',['在温']='在温尼伯看雪:BAAALAAECgEIAQAAAA==.',['墨玄']='墨玄歌:BAAALAADCgIIAgAAAA==.墨玄歌丶:BAAALAADCgQIBAAAAA==.',['壹丶']='壹丶壹:BAAALAAECgEIAQAAAA==.',['夏花']='夏花灿烂:BAAALAAECgYIDAAAAA==.',['夜羅']='夜羅刹:BAABLAAFFH8LAAINAAII4xN5QwB7AAANAAII4xN5QwB7AAAAAA==.',['夜雨']='夜雨难忘:BAAALAADCgcIBwAAAA==.',['大漂']='大漂亮:BAAALAAECgIIAgAAAA==.',['天哥']='天哥闹不住:BAABLAAFFH8aAAICAAUIIhr3PABHAQACAAUIIhr3PABHAQAAAA==.',['天堂']='天堂之宝儿:BAAALAADCgMIAwAAAA==.天堂小骑士:BAAALAADCgIIAgAAAA==.',['太乙']='太乙真人:BAAALAAECgYIBgAAAA==.',['头上']='头上有犄角丶:BAABLAAFFH8FAAMOAAIIwxM2XQB5AAAOAAII7Q42XQB5AAAPAAEI+AkaHQAsAAAAAA==.',['奥利']='奥利波斯丶滚:BAAALAAECggICAAAAA==.',['妞来']='妞来根香烟:BAAALAAECgUIBQAAAA==.',['孤戰']='孤戰天下:BAAALAAECgYIBgAAAA==.',['孤烟']='孤烟大漠:BAAALAAECgYICAAAAA==.',['孤盗']='孤盗西风:BAAALAAECgQIBAAAAA==.',['将军']='将军路:BAAALAADCgYIBgAAAA==.',['小三']='小三妹子:BAAALAADCgEIAQAAAA==.',['小仙']='小仙:BAAALAAECgIIAgAAAA==.',['小小']='小小何电电:BAABLAAECn8VAAIQAAgIXh/KFADvAgAQAAgIXh/KFADvAgAAAA==.',['小旭']='小旭旭:BAAALAADCgcIBwAAAA==.',['小欧']='小欧同学丶:BAAALAAECgYIBgABLAAFFAgIBgARAMcWAA==.',['小法']='小法:BAAALAAECgQIBQAAAA==.',['小泽']='小泽丶玛莉桑:BAAALAAECgYIEQAAAA==.',['小猫']='小猫無敌:BAAALAAECgYIDAAAAA==.',['小羿']='小羿小羿:BAAALAAECgYIBgAAAA==.',['小腿']='小腿毛:BAAALAADCgYIBgAAAA==.',['尐裤']='尐裤叉:BAAALAADCgYIBgAAAA==.',['山中']='山中小鱼:BAAALAADCgIIAgAAAA==.',['岑碧']='岑碧青:BAAALAAECgIIAgAAAA==.',['崔希']='崔希丝:BAABLAAFFH8LAAIDAAMInRiWIQD+AAADAAMInRiWIQD+AAABLAAFFAgIEgADAM0MAA==.',['巧之']='巧之灬风语:BAAALAADCgYIBgAAAA==.',['布莱']='布莱恩武僧:BAABLAAFFH8FAAISAAIISRW7HgA7AAASAAIISRW7HgA7AAAAAA==.',['希尒']='希尒瓦娜斯:BAAALAADCgMIAwAAAA==.',['希希']='希希酱紫:BAABLAAFFH8GAAIJAAIInw61WgCGAAAJAAIInw61WgCGAAAAAA==.',['带你']='带你飞:BAAALAADCgYIBgAAAA==.',['幻翎']='幻翎:BAACLAAFFH8YAAIDAAUIRxtlOgBYAQADAAUIRxtlOgBYAQAsAAQKfxYAAwMACAgZI8I0AO0BAAMACAgZI8I0AO0BABMABghoDU1rABoBAAAA.',['广元']='广元凉面:BAAALAAFFAIIAgAAAA==.',['張先']='張先生:BAAALAAECgEIAQAAAA==.',['德不']='德不得:BAAALAAECgYIEAAAAA==.',['德鲁']='德鲁丶伊德:BAAALAAECgcICAAAAA==.',['心橙']='心橙则灵:BAAALAAECgMIAwAAAA==.',['心流']='心流丶:BAAALAAECgYIBgAAAA==.',['念旧']='念旧乄:BAAALAADCgcIBwAAAA==.',['怕瓦']='怕瓦落地:BAAALAAECgIIAgAAAA==.',['恶魔']='恶魔灵魂骑士:BAAALAAECgMIAwAAAA==.',['情缘']='情缘丘比特:BAAALAAECgMIAwAAAA==.',['愣大']='愣大叔丶:BAAALAADCgQIBgAAAA==.',['成年']='成年雄性:BAAALAAECgYIDAABLAAFFAgIAgAUAAAAAA==.',['我为']='我为谁狂:BAAALAAECgYIBgABLAAFFAIIBAAUAAAAAA==.',['戒丨']='戒丨色:BAAALAAECgMIAwAAAA==.',['戒為']='戒為良藥:BAAALAADCgcIAQAAAA==.',['战牛']='战牛传奇:BAAALAADCgYIBgAAAA==.',['戮末']='戮末:BAABLAAFFH8NAAIDAAUIxRv5PgBKAQADAAUIxRv5PgBKAQABLAAFFAYIDgAJACAgAA==.',['抓满']='抓满所有宠:BAAALAADCgYIBgAAAA==.',['折旋']='折旋笑得君王:BAAALAAECgQIBAAAAA==.',['报应']='报应:BAAALAAECgUIBQAAAA==.',['拿铁']='拿铁:BAABLAAECn8bAAMVAAgIfhlrCQBQAgAVAAgIYhhrCQBQAgAWAAUIyha/UQAgAQAAAA==.',['斯琴']='斯琴丶高玩:BAAALAAFFAIIAgAAAA==.斯琴高狩:BAABLAAFFH8KAAIDAAIIgRY2jwBFAAADAAIIgRY2jwBFAAAAAA==.',['旭旭']='旭旭术丶:BAAALAAECgYIBgAAAA==.旭旭猎丶:BAAALAAECgYIBgAAAA==.',['暗之']='暗之觞:BAAALAADCgQIBAAAAA==.',['暗影']='暗影猫:BAABLAAFFH8IAAICAAIIhhjwTQCiAAACAAIIhhjwTQCiAAAAAA==.',['暮色']='暮色流雲:BAABLAAFFH8KAAMXAAIIDSHADACuAAAEAAIIHSDfMAC2AAAXAAII4B/ADACuAAABLAAFFAgIBgAGAKgaAA==.暮色铃瑛:BAAALAAFFAIIAgAAAA==.',['暴洌']='暴洌:BAAALAAECgYICQAAAA==.',['曓虐']='曓虐:BAABLAAECn8WAAIWAAYImh4bNgCAAQAWAAYImh4bNgCAAQAAAA==.',['曾经']='曾经无敌:BAABLAAFFH8GAAIYAAYIYRqXHwCYAQAYAAYIYRqXHwCYAQAAAA==.',['月全']='月全食:BAAALAAECgMIAwAAAA==.',['月是']='月是中秋:BAAALAAFFAIIAgAAAA==.',['有翅']='有翅膀是魅魔:BAAALAADCgUICQAAAA==.',['木吉']='木吉他的悲鸣:BAAALAADCgEIAQAAAA==.',['朱厌']='朱厌:BAABLAAECn8iAAICAAgIdx97KQDMAgACAAgIdx97KQDMAgAAAA==.',['朵丽']='朵丽:BAABLAAFFH8IAAINAAYIoCA5CgAmAgANAAYIoCA5CgAmAgAAAA==.',['杨枝']='杨枝甘露:BAAALAADCgMIAwAAAA==.',['松千']='松千绪花:BAABLAAFFH8GAAIYAAMIKBbkLwDNAAAYAAMIKBbkLwDNAAAAAA==.',['松谦']='松谦绪花:BAAALAAECgIIAgAAAA==.',['枫丶']='枫丶泷:BAABLAAFFH8QAAIOAAgIUR9JBQCMAgAOAAgIUR9JBQCMAgAAAA==.',['枫桥']='枫桥夜月:BAAALAADCgMIAwAAAA==.',['枫溪']='枫溪雾:BAABLAAECn8YAAIJAAYISh3JQACaAQAJAAYISh3JQACaAQAAAA==.',['柒柒']='柒柒:BAAALAAECgYIDAAAAA==.',['桐狗']='桐狗狗:BAAALAAECgYIDAAAAA==.',['梦梦']='梦梦:BAAALAAECgYIDAAAAA==.',['棍状']='棍状生物体:BAAALAAFFAMIAwAAAA==.',['橘子']='橘子:BAAALAADCgQIBQAAAA==.橘子糖:BAAALAAFFAIIAgAAAA==.',['欠帥']='欠帥:BAAALAADCggICAAAAA==.',['止戰']='止戰之殇:BAAALAADCgMIAwAAAA==.',['正拳']='正拳突:BAAALAAECgQIAgAAAA==.',['死亡']='死亡之刺:BAAALAADCggICAAAAA==.',['毁灭']='毁灭女神:BAAALAAFFAIIAgAAAA==.',['汪身']='汪身后有尾巴:BAAALAAFFAIIBAAAAA==.',['油猫']='油猫饼:BAABLAAECn8UAAIJAAYItRc7pACwAQAJAAYItRc7pACwAQAAAA==.',['海波']='海波东:BAAALAAFFAIIAgAAAA==.',['深夜']='深夜打小怪:BAAALAAECgUIBgAAAA==.',['混断']='混断木桥:BAAALAAECgYIBgAAAA==.',['清角']='清角吹寒:BAACLAAFFH8SAAIYAAIIPCV5LwDQAAAYAAIIPCV5LwDQAAAsAAQKfxQAAxgABgi/JW4tAJUCABgABgi/JW4tAJUCABkAAQgMBsOUADIAAAAA.',['火星']='火星刺客:BAAALAADCgUIBQAAAA==.',['灬幽']='灬幽暗丿练少:BAABLAAFFH8GAAIEAAIIAgn2agA1AAAEAAIIAgn2agA1AAAAAA==.',['灬灵']='灬灵魂献祭灬:BAAALAADCgIIAgAAAA==.',['灬米']='灬米霍克灬:BAAALAAFFAIIBAAAAA==.',['灬紫']='灬紫鲸鱼灬:BAABLAAFFH8QAAMCAAUILw+ANADMAAACAAIIiiSANADMAAAaAAUIzwGpCwC7AAAAAA==.',['灬肖']='灬肖战灬:BAABLAAFFH8NAAICAAMIaxYyXgCSAAACAAMIaxYyXgCSAAAAAA==.',['灵月']='灵月仙子:BAAALAAECgYIBgAAAA==.',['烈氵']='烈氵:BAAALAAFFAIIBAAAAA==.',['热血']='热血战神:BAAALAAECgYIBgAAAA==.',['燃烧']='燃烧的卡路里:BAABLAAFFH8SAAIOAAYI6x5hEwDHAQAOAAYI6x5hEwDHAQAAAA==.燃烧的毛毛虫:BAAALAADCgYIBgAAAA==.燃烧的胸毛:BAAALAAECgUIBQAAAA==.',['爆射']='爆射小昀子:BAAALAAFFAIIAgAAAA==.',['爱丽']='爱丽不可语:BAAALAAECgIIAgAAAA==.',['牧尸']='牧尸:BAAALAAECgMIAwAAAA==.',['狂暴']='狂暴的小孩:BAAALAAECgYIBgAAAA==.',['狗亮']='狗亮:BAAALAAFFAIIBAAAAA==.',['猎者']='猎者无名:BAAALAAECgMIAwAAAA==.',['玉玊']='玉玊:BAAALAAECgQIBAAAAA==.',['瑞文']='瑞文瑞文:BAAALAADCgYIBgAAAA==.',['瑞温']='瑞温黛儿:BAAALAADCgYICwAAAA==.',['生产']='生产队的磨:BAAALAADCgIIBAAAAA==.',['电动']='电动丶小马达:BAAALAAECgYIEAABLAAFFAgIEgADAM0MAA==.',['百濕']='百濕不得骑姊:BAAALAAECgUIBQAAAA==.',['盖亚']='盖亚嘉说:BAAALAAECgEIAQAAAA==.',['盖拉']='盖拉多:BAAALAAECggIEgAAAA==.',['眉毛']='眉毛会跳舞:BAAALAAECgUIBQAAAA==.',['看你']='看你妹丫:BAAALAAFFAIIAgAAAA==.',['看盡']='看盡世间繁華:BAAALAAECgYIBgAAAA==.',['眼棱']='眼棱瞎了眼丶:BAAALAAECgEIAQAAAA==.',['矛盾']='矛盾属实:BAAALAAECgIIAgAAAA==.',['神圣']='神圣大主教:BAAALAADCgUIBQAAAA==.',['禽家']='禽家兽:BAACLAAFFH8gAAIWAAUInxGuJQBCAQAWAAUInxGuJQBCAQAsAAQKfysAAxYABwhWF9U9AGIBABYABwhWF9U9AGIBABUABghKChMfAB0BAAAA.',['禽教']='禽教兽:BAACLAAFFH8dAAICAAYI4RDhLwB7AQACAAYI4RDhLwB7AQAsAAQKfyEAAgIACAhuHJAbABMCAAIACAhuHJAbABMCAAAA.',['窈窕']='窈窕术女:BAAALAADCgMIBAAAAA==.',['章台']='章台柳:BAAALAAFFAQIBAAAAA==.',['竹叶']='竹叶青青:BAAALAAECgUIBQAAAA==.',['筱苹']='筱苹果:BAAALAADCgEIAQAAAA==.',['篲兒']='篲兒:BAAALAAECgYICgAAAA==.',['米纳']='米纳思迪丽斯:BAAALAAFFAIIBAAAAA==.',['糖糖']='糖糖:BAAALAAECgUIBgAAAA==.',['紫夜']='紫夜流星:BAACLAAFFH8IAAMXAAYI/ARWBAAjAQAXAAYI/ARWBAAjAQAEAAIIJAObbwAuAAAsAAQKfygAAgQACAgUDyI7AFsBAAQACAgUDyI7AFsBAAAA.',['紫月']='紫月流光:BAACLAAFFH8GAAIQAAQIrgOJNgCCAAAQAAQIrgOJNgCCAAAsAAQKfykAAxAACAjREGYlAI0BABAACAjREGYlAI0BAA0ABgh9CSz+AKIAAAAA.',['紫罗']='紫罗兰:BAAALAAECgQIBAAAAA==.',['紫菜']='紫菜蛋花汤:BAACLAAFFH8kAAIYAAcIRhL/GAC5AQAYAAcIRhL/GAC5AQAsAAQKfyoAAxgACAjdIHIcAOACABgACAjdIHIcAOACABkAAQiwCEWcACAAAAAA.',['緋聞']='緋聞少女:BAAALAAECgUIBAAAAA==.',['繁华']='繁华末日:BAAALAAFFAIIBAAAAA==.',['红莲']='红莲怒斩:BAACLAAFFH8gAAIJAAYImhxkEgC1AQAJAAYImhxkEgC1AQAsAAQKfyEAAgkACAhaHMMyAMgBAAkACAhaHMMyAMgBAAAA.',['罗西']='罗西:BAAALAADCgcIBwAAAA==.',['羊过']='羊过小龍女:BAAALAAECggICAAAAA==.',['翠花']='翠花俺家牛呢:BAAALAAECgYIBgAAAA==.',['翻浆']='翻浆倒海丶:BAABLAAFFH8FAAISAAUI9wLTCwDvAAASAAUI9wLTCwDvAAAAAA==.',['老司']='老司机:BAABLAAFFH8NAAIJAAYIiBW8FwCUAQAJAAYIiBW8FwCUAQAAAA==.',['老酒']='老酒泸康:BAAALAAECgYICwAAAA==.',['聚丙']='聚丙烯:BAAALAAECgUIBgAAAA==.',['背后']='背后来一下:BAAALAAECgYIBgAAAA==.',['自由']='自由的风:BAAALAAECgQIBAAAAA==.',['臭蛋']='臭蛋蛋:BAAALAAECgQIBAAAAA==.',['至尊']='至尊寶:BAAALAADCgIIAgAAAA==.',['花泽']='花泽香采:BAAALAADCgQIBAAAAA==.',['莫丶']='莫丶挨:BAAALAAECggIEAABLAAFFAgIOgAEAPghAA==.',['莱西']='莱西:BAAALAADCgYIBgAAAA==.',['菊花']='菊花痒请轻抠:BAAALAAECgYIDAAAAA==.',['萌萌']='萌萌小战牛:BAAALAADCgIIAgAAAA==.',['萝卜']='萝卜特丶吼黛:BAAALAAFFAIIAgAAAA==.',['萧炎']='萧炎:BAABLAAFFH8IAAIJAAIILhzlUQBSAAAJAAIILhzlUQBSAAAAAA==.',['萬海']='萬海:BAAALAAFFAYIBAAAAA==.',['蔓珠']='蔓珠於莎華丶:BAAALAAFFAIIAgAAAA==.',['蛮子']='蛮子:BAAALAAECgYICwAAAA==.',['西格']='西格玛男人:BAAALAAECgQIBwAAAA==.',['要说']='要说什么:BAABLAAFFH8GAAIGAAIIqBqPFgCZAAAGAAIIqBqPFgCZAAAAAA==.',['观之']='观之若无:BAABLAAECn8YAAICAAgIyBBznQDLAQACAAgIyBBznQDLAQAAAA==.',['诺达']='诺达希尔:BAAALAADCggIDAAAAA==.',['负能']='负能量光环:BAAALAAECgYIDAAAAA==.',['贵族']='贵族逸飞:BAABLAAFFH8LAAIbAAUIPBENIABJAQAbAAUIPBENIABJAQAAAA==.',['踩啦']='踩啦踩啦嘿:BAAALAAECgYICAAAAA==.',['转就']='转就完事了:BAAALAAECgYIBgAAAA==.',['软妹']='软妹纸:BAAALAAECgIIAgAAAA==.',['过电']='过电:BAAALAAECggICAAAAA==.',['这招']='这招怎么样:BAAALAADCgUIBQAAAA==.',['进阶']='进阶钢铁兽:BAAALAAECgYICAAAAA==.',['追梦']='追梦的大叔:BAAALAAFFAEIAQAAAA==.',['邓超']='邓超:BAAALAAECggIEQAAAA==.',['邪鬼']='邪鬼皇族公主:BAABLAAFFH8OAAIEAAMIrBNuTACIAAAEAAMIrBNuTACIAAAAAA==.',['邶丬']='邶丬:BAAALAAECgYIBgAAAA==.',['酋长']='酋长:BAAALAAFFAQIBAAAAA==.',['酒吧']='酒吧长谈:BAAALAAFFAMIAwAAAA==.',['醉心']='醉心蛋蛋:BAAALAAECgYICAAAAA==.',['鐡枫']='鐡枫丶:BAAALAAECgYIBgAAAA==.',['钢筋']='钢筋锅:BAAALAAECgYIBgAAAA==.',['铁拳']='铁拳熊猫:BAAALAAFFAIIAgAAAA==.',['铅笔']='铅笔与橡皮:BAAALAADCgIIAgAAAA==.',['阿奴']='阿奴赛尔:BAAALAAFFAIIAgAAAA==.',['阿飞']='阿飞灬:BAAALAAECgYIDwAAAA==.',['陕西']='陕西凉皮:BAAALAAECgYIDAAAAA==.',['随地']='随地大小变:BAAALAAECgcIEgAAAA==.',['霜殇']='霜殇灬:BAAALAADCgMIAwAAAA==.',['霜的']='霜的哀伤:BAAALAADCgYIBgAAAA==.',['霰血']='霰血纷飞:BAAALAAFFAIIAgAAAA==.',['霰雪']='霰雪纷飞:BAACLAAFFH8MAAMbAAQINgOhLgCyAAAbAAQINgOhLgCyAAAcAAIIbQcYLQA8AAAsAAQKfyUAAxsACAgPDbIzACYBABsACAgPDbIzACYBABwABgivDCYwANMAAAAA.',['青山']='青山:BAAALAAECgUIBQAAAA==.',['顷雲']='顷雲:BAAALAAFFAIIAgABLAAFFAYIDgAJACAgAA==.',['风暴']='风暴与雷鸣:BAAALAAECgYIEQAAAA==.',['飞段']='飞段丨:BAAALAAECgMIAwAAAA==.',['魔兽']='魔兽地狱:BAAALAADCgUIBgAAAA==.魔兽好凉茶:BAABLAAFFH8GAAIWAAYIjBnQEADRAQAWAAYIjBnQEADRAQAAAA==.',['魔加']='魔加兽:BAAALAAECgYIBgAAAA==.',['魔血']='魔血麒麟:BAAALAAECgYIBgAAAA==.',['黄金']='黄金假面人:BAAALAADCggICAAAAA==.',['黑夜']='黑夜交响曲:BAAALAAECgEIAQAAAA==.',['黑暗']='黑暗伊贝:BAAALAADCgMIAwAAAA==.黑暗降临:BAAALAAECgMIAwAAAA==.',['黑色']='黑色云雾:BAAALAADCgQIBAAAAA==.',['黑铁']='黑铁啤酒:BAAALAAECgIIAgAAAA==.',['黒马']='黒马骑士:BAAALAADCgUIBQAAAA==.',['龙弦']='龙弦:BAABLAAFFH8LAAMYAAIIoRutPQCiAAAYAAIIoRutPQCiAAAZAAEIcBKZHwBFAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end