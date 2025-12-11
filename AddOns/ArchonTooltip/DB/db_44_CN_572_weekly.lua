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
 local lookup = {'Priest-Discipline','Mage-Arcane','DeathKnight-Blood','Warrior-Protection','DeathKnight-Frost','Mage-Frost','Evoker-Preservation','Evoker-Devastation','Rogue-Assassination','Hunter-BeastMastery','DemonHunter-Havoc','Druid-Guardian','Priest-Holy','Monk-Brewmaster','Paladin-Retribution','Druid-Restoration','Shaman-Restoration','Druid-Balance','Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','Unknown-Unknown','Shaman-Elemental','Priest-Shadow','Warrior-Fury','Monk-Mistweaver','Monk-Windwalker',}; local provider = {region='CN',realm='伊莫塔尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ap='Applebaby:BAAALAAECgYICwAAAA==.',Ca='Cannelloni:BAAALAAECgYIDAAAAA==.',Ci='Citylights:BAABLAAFFH8GAAIBAAYI9AJ9BAB9AAABAAYI9AJ9BAB9AAAAAA==.',Ex='Exneko:BAABLAAFFH8MAAICAAYI8wKjOAAJAQACAAYI8wKjOAAJAQAAAA==.',Fb='Fbdeekay:BAABLAAFFH8KAAIDAAgIYSJ0AgBtAgADAAgIYSJ0AgBtAgAAAA==.Fbdeekey:BAABLAAFFH8IAAIDAAgIdB1FAwBCAgADAAgIdB1FAwBCAgAAAA==.',Go='Goldenj:BAAALAADCgIIAgAAAA==.',Gu='Guldanet:BAAALAAFFAIIAwAAAA==.',Ha='Haqmomback:BAABLAAFFH8GAAIEAAYI0wA2KgA8AAAEAAYI0wA2KgA8AAAAAA==.',Ho='Holyblood:BAAALAAFFAEIAQAAAA==.Holysmoke:BAAALAAECgUIBwAAAA==.',Hy='Hypoxia:BAAALAAFFAIIBAAAAA==.',Is='Iskander:BAAALAAFFAQIBAAAAA==.',Je='Jeremiah:BAABLAAFFH8FAAIFAAUIHwb0TAD3AAAFAAUIHwb0TAD3AAAAAA==.',Kp='Kpoves:BAABLAAFFH8IAAIGAAIIOhGsGAA+AAAGAAIIOhGsGAA+AAAAAA==.',Li='Linguine:BAAALAAECgYICAAAAA==.',Lo='Loong:BAACLAAFFH8OAAIHAAIINQ3oFQCCAAAHAAIINQ3oFQCCAAAsAAQKfxUAAwgABwhFFIs7AF0BAAgABgixEYs7AF0BAAcABggpDSEXANwAAAAA.',Ma='Maccheroni:BAAALAAECgYICQAAAA==.',Mo='Mobic:BAAALAADCggICAAAAA==.',Pl='Playerbbfron:BAAALAAECgQIBAAAAA==.',Sa='Sarotti:BAAALAAFFAIIAgAAAA==.',Se='Sephiroth:BAABLAAECn8gAAIJAAgIfxc1GQBMAgAJAAgIfxc1GQBMAgAAAA==.',Su='Summersky:BAABLAAFFH8GAAIKAAIIxRfilwBBAAAKAAIIxRfilwBBAAABLAAFFAYIFAALAGYkAA==.',Ta='Tals:BAAALAAECgYIDAAAAA==.',Xd='Xdasd:BAAALAADCgEIAQAAAA==.',Yi='Yii:BAAALAADCgQIBAAAAA==.',['一半']='一半邪恶:BAABLAAFFH8NAAIMAAMIRRI6CQBVAAAMAAMIRRI6CQBVAAAAAA==.',['一杯']='一杯勇闯:BAAALAADCgUIBQAAAA==.',['一箭']='一箭丨钟情灬:BAAALAAECgYICgAAAA==.',['一贱']='一贱丨终情灬:BAAALAAECgYIEQAAAA==.',['一路']='一路常宏:BAAALAADCgEIAQAAAA==.一路常红:BAAALAAFFAMIAwAAAA==.',['万神']='万神殿主:BAAALAAECgYIBgAAAA==.',['三圣']='三圣石:BAAALAAECgYIBgAAAA==.',['不说']='不说话装高手:BAABLAAFFH8HAAINAAUIjhJ0CwCZAQANAAUIjhJ0CwCZAQABLAAFFAYIHgAOABQXAA==.',['丨吾']='丨吾皇丨:BAABLAAFFH8KAAIPAAIIFyGPLACwAAAPAAIIFyGPLACwAAAAAA==.',['中二']='中二恶魔使:BAAALAAECgEIAQAAAA==.',['丶喵']='丶喵小九:BAABLAAFFH8GAAIEAAYI7wpIFgABAQAEAAYI7wpIFgABAQAAAA==.',['丶布']='丶布衣:BAAALAAECgYIBgAAAA==.',['人凄']='人凄灬有三好:BAAALAAFFAMIAwAAAA==.',['今宵']='今宵别梦寒:BAAALAAECgEIAQAAAA==.',['仙人']='仙人跳不跳:BAACLAAFFH8nAAIQAAYI1h0VBgDFAQAQAAYI1h0VBgDFAQAsAAQKfx8AAhAACAjoHUsiAGMCABAACAjoHUsiAGMCAAAA.',['以万']='以万变应不变:BAAALAAECgIIAgAAAA==.',['伊利']='伊利大磡祷:BAAALAAECgQICwAAAA==.',['伐伽']='伐伽:BAAALAAECggICAAAAA==.',['优雅']='优雅的小刺猬:BAAALAAECgcIBwAAAA==.',['余念']='余念安:BAAALAADCgUIBQAAAA==.',['佛说']='佛说你爱我:BAAALAADCgMIAwAAAA==.',['你很']='你很紧张女士:BAAALAAECgYIBgAAAA==.',['傲娇']='傲娇的小恶魔:BAAALAAFFAIIAgAAAA==.傲娇的小狐狸:BAABLAAFFH8lAAIFAAYImR7PHADDAQAFAAYImR7PHADDAQAAAA==.',['全全']='全全不是我:BAAALAAECgUIBQAAAA==.',['兵者']='兵者丶胸器也:BAAALAAECggICAAAAA==.',['再也']='再也不痒咯:BAAALAAECgYIBgAAAA==.',['凋零']='凋零之刃:BAAALAAECgYIBgAAAA==.',['凡人']='凡人皆需侍奉:BAABLAAFFH8GAAIRAAIIcQnhcABJAAARAAIIcQnhcABJAAAAAA==.',['分界']='分界线灬:BAABLAAFFH8GAAIKAAIIlRAqWgCPAAAKAAIIlRAqWgCPAAAAAA==.',['刘小']='刘小喵:BAAALAAECgMIAwAAAA==.',['别迷']='别迷恋我的脸:BAAALAADCgIIAgAAAA==.',['剁饼']='剁饼子:BAABLAAFFH8KAAIQAAUIFSNNBQDXAQAQAAUIFSNNBQDXAQAAAA==.',['剑心']='剑心犹在:BAABLAAFFH8GAAMQAAQIqhdFHACxAAAQAAIIhR9FHACxAAASAAIItg+aJACKAAAAAA==.',['加勒']='加勒比海豹丶:BAAALAADCgEIAQAAAA==.',['加血']='加血真累:BAAALAAECgYIBgAAAA==.',['勿念']='勿念丶:BAAALAAFFAIIAgAAAA==.',['十修']='十修歌:BAABLAAFFH8FAAMTAAIIAAlMGgAhAAATAAIIKgZMGgAhAAAUAAII6Aj5cgAhAAAAAA==.',['南市']='南市阿扎里:BAAALAAECgYICAAAAA==.',['南风']='南风知我意:BAAALAAFFAIIAgAAAA==.',['卡萨']='卡萨里斯:BAABLAAFFH8VAAIKAAYISRdoMQBzAQAKAAYISRdoMQBzAQAAAA==.',['卢卡']='卢卡朵:BAAALAAFFAEIAQAAAA==.',['友利']='友利奈绪:BAAALAAECgMIAwAAAA==.',['双层']='双层灬眼罩:BAAALAAECgYICAAAAA==.',['可可']='可可乐乐:BAAALAADCgYIBgAAAA==.',['可心']='可心王朝:BAAALAADCgMIAwAAAA==.',['可爱']='可爱的双马尾:BAAALAAECgUIBQAAAA==.',['吃炸']='吃炸鸡腿么:BAAALAAFFAIIBAAAAA==.',['呐叭']='呐叭叭:BAAALAAECgIIAgAAAA==.',['咕德']='咕德猫宁比尔:BAABLAAECn8aAAMSAAgITBINPQDBAQASAAgITBINPQDBAQAQAAcIlQ9LZQBkAQAAAA==.',['啊蕉']='啊蕉:BAABLAAECn8ZAAMVAAgI9xjYIQCoAQAVAAcIWBnYIQCoAQALAAQIAg7hHQGjAAAAAA==.',['啤梨']='啤梨贝贝:BAAALAADCgUIBQAAAA==.',['喜之']='喜之郎:BAABLAAFFH8KAAICAAYIUQ45IAAqAQACAAYIUQ45IAAqAQABLAAFFAgIAgAWAAAAAA==.',['嗷嗷']='嗷嗷咕:BAABLAAFFH8TAAMSAAYIPhi/CACsAQASAAYIPhi/CACsAQAQAAEI3wNTTgA9AAAAAA==.',['嘉玲']='嘉玲:BAAALAAECgMIAwAAAA==.',['嘿咻']='嘿咻嘿咻:BAABLAAFFH8GAAIFAAIIKCA9RQCrAAAFAAIIKCA9RQCrAAAAAA==.',['四队']='四队萨满:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光玫瑰:BAABLAAFFH8GAAINAAIIzgjyQgBlAAANAAIIzgjyQgBlAAAAAA==.',['壹戰']='壹戰成冥:BAABLAAECn8WAAIEAAYI/Q+UJwAQAQAEAAYI/Q+UJwAQAQAAAA==.',['多恩']='多恩保安队长:BAABLAAFFH8KAAIEAAIIfhlZHQCEAAAEAAIIfhlZHQCEAAAAAA==.',['夜玫']='夜玫瑰:BAABLAAFFH8GAAIFAAIIiQ2pgABFAAAFAAIIiQ2pgABFAAAAAA==.',['夜行']='夜行兽兽:BAAALAADCgEIAQAAAA==.',['大狸']='大狸子:BAAALAAECgYIBgAAAA==.',['大精']='大精同学:BAAALAAECgUICQAAAA==.',['天芷']='天芷丶若殇:BAAALAADCgYIBwAAAA==.',['天魂']='天魂玉:BAAALAAECgcIBwAAAA==.',['奥术']='奥术暴风雪:BAAALAAECgcIBwAAAA==.',['奶爸']='奶爸嘿黑嘿:BAABLAAFFH8FAAIRAAIIwRbkQQB+AAARAAIIwRbkQQB+AAAAAA==.奶爸快救我:BAAALAAFFAIIBAAAAA==.',['始源']='始源:BAAALAAECggIDAAAAA==.',['嫣然']='嫣然一笑:BAAALAADCgEIAQAAAA==.',['定风']='定风波:BAAALAAECgYIBgAAAA==.',['小小']='小小虎牙控:BAAALAAECgUIBQAAAA==.',['小鬼']='小鬼成群:BAABLAAFFH8WAAIUAAgIjR2PCgBWAgAUAAgIjR2PCgBWAgAAAA==.',['尤里']='尤里乌斯:BAAALAAECgYIBgAAAA==.',['就那']='就那样:BAAALAADCgMIBQAAAA==.',['帅既']='帅既是正义:BAAALAAECgUIBQAAAA==.',['幽谷']='幽谷云深:BAAALAAECgYIBgAAAA==.',['延吉']='延吉鹰左龙:BAAALAAFFAIIBAAAAA==.',['引弓']='引弓狩天狼:BAAALAAECgIIAgAAAA==.',['强运']='强运的回响:BAABLAAFFH8KAAIFAAMIiByFVgCuAAAFAAMIiByFVgCuAAAAAA==.',['徳意']='徳意忘形:BAAALAAECgQIBAAAAA==.',['心中']='心中有之牛:BAACLAAFFH8bAAIFAAYIfB/BHgC6AQAFAAYIfB/BHgC6AQAsAAQKfxwAAgUABwiSIvc2AJsCAAUABwiSIvc2AJsCAAAA.',['心梦']='心梦牧痕:BAABLAAFFH8IAAINAAII4Rp+MgCfAAANAAII4Rp+MgCfAAAAAA==.',['快乐']='快乐哈皮:BAAALAADCgMIAwAAAA==.',['悲剧']='悲剧的背后:BAABLAAFFH8GAAMSAAYIkBxxBgDiAQASAAUIhh5xBgDiAQAQAAEIShL4SwBIAAAAAA==.',['惠惠']='惠惠慧:BAABLAAFFH8TAAIDAAgI8CSmAADkAgADAAgI8CSmAADkAgAAAA==.',['意图']='意图锋刃:BAAALAAECgMIAwAAAA==.',['感觉']='感觉凶凶哒:BAAALAADCgYIBgAAAA==.',['愿你']='愿你貌美如花:BAAALAAECgYIDgAAAA==.',['我心']='我心向佛:BAAALAAECgcIEgAAAA==.',['我是']='我是小穆师:BAABLAAFFH8KAAINAAIIJA9cPABxAAANAAIIJA9cPABxAAAAAA==.',['戳锅']='戳锅漏:BAAALAAECgcIBwAAAA==.',['打枪']='打枪的不要:BAAALAAECgUIBQAAAA==.',['拉风']='拉风丶炫酷:BAAALAAECgQIBAAAAA==.',['提篮']='提篮桥老虎:BAAALAAFFAIIBAAAAA==.',['携秋']='携秋水揽星河:BAAALAAECgUICAAAAA==.',['摧神']='摧神毁志:BAABLAAFFH8FAAMRAAUI8hcBGADyAAARAAQI6hkBGADyAAAXAAEIygG9TwA1AAAAAA==.',['撒饵']='撒饵:BAAALAAECgYICAAAAA==.',['放开']='放开那个老太:BAAALAAECgYICQAAAA==.放开那只怪物:BAAALAAECggIEQAAAA==.',['文森']='文森特:BAAALAAECgYIBgAAAA==.',['断水']='断水流大湿兄:BAAALAAECgIIAgAAAA==.',['施华']='施华洛士琦:BAAALAAECgYIBgAAAA==.',['无邪']='无邪:BAABLAAFFH8HAAISAAYIzADCQQAOAAASAAYIzADCQQAOAAAAAA==.',['无雙']='无雙:BAAALAAECgYIBwAAAA==.',['日理']='日理万机:BAAALAAECgUIBQAAAA==.',['春去']='春去春又回:BAABLAAECn8XAAILAAYI5gJDlgBuAAALAAYI5gJDlgBuAAAAAA==.',['晨曦']='晨曦之刃:BAAALAAECgYIBgAAAA==.',['普罗']='普罗旺思:BAAALAADCgIIAgAAAA==.',['普莱']='普莱尔佛:BAAALAAECgYIDAAAAA==.普莱尔发:BAAALAADCgYIBgAAAA==.',['暗夜']='暗夜猎手韦恩:BAAALAAECgIIAgAAAA==.',['曼妥']='曼妥思:BAAALAAECgMIAwAAAA==.',['最璀']='最璀璨的奻奻:BAAALAAECgMIAwAAAA==.',['月亮']='月亮亮:BAAALAADCgcICAAAAA==.',['月光']='月光如冰:BAAALAADCgYICQAAAA==.月光如梅:BAAALAAECgYIDAAAAA==.月光如殇:BAAALAAECgYIBwAAAA==.月光如风:BAAALAAECgEIAQAAAA==.月光断水:BAAALAAECgQIBAAAAA==.',['枫缚']='枫缚:BAAALAAECgMIAwAAAA==.',['梯阙']='梯阙艾:BAABLAAECn8VAAMRAAgIZxHyMQCYAQARAAgIZxHyMQCYAQAXAAEIcAsqfQAtAAAAAA==.',['榆的']='榆的传说:BAAALAAECgUIBQAAAA==.',['次你']='次你把卵:BAAALAAECgYICQAAAA==.',['欢喜']='欢喜核桃娃:BAAALAADCgQIBAAAAA==.',['永恒']='永恒灬孤独:BAAALAAECggIBgAAAA==.',['法力']='法力风暴:BAAALAAECgYIDgAAAA==.',['流木']='流木:BAAALAADCgcIBwAAAA==.',['流沙']='流沙:BAAALAAECggICAAAAA==.',['淡淡']='淡淡秋色浓香:BAAALAAFFAIIAgAAAA==.',['湮灭']='湮灭暴风雪:BAAALAAECgYIBgAAAA==.',['潇洒']='潇洒走一麾:BAABLAAFFH8IAAIYAAIIURXgGwCaAAAYAAIIURXgGwCaAAAAAA==.',['潜龙']='潜龙在渊:BAAALAAECgYIBgABLAAFFAIIAgAWAAAAAA==.',['火野']='火野映司:BAAALAAFFAIIAwAAAA==.',['炮二']='炮二:BAAALAAECgYIDAAAAA==.',['点一']='点一支烟:BAACLAAFFH8KAAIZAAUIBAunKQAgAQAZAAUIBAunKQAgAQAsAAQKfxYAAhkABwinHQIaABQCABkABwinHQIaABQCAAAA.',['無雙']='無雙無法:BAAALAADCgcIBwAAAA==.無雙绿火:BAAALAADCgYIBgAAAA==.無雙萨满:BAAALAADCgMIAwAAAA==.',['熊猫']='熊猫猎:BAAALAAFFAIIBAAAAA==.',['爱帮']='爱帮忙的老王:BAAALAAECgYIBgAAAA==.',['爱音']='爱音暴风雪:BAAALAAECgYICQAAAA==.',['牛叉']='牛叉二哥:BAAALAAECgYIBwAAAA==.',['牧濑']='牧濑丶红莉栖:BAAALAAECgIIAgAAAA==.',['狂得']='狂得很:BAABLAAFFH8IAAIGAAIIPRb4DQCYAAAGAAIIPRb4DQCYAAAAAA==.',['狠灬']='狠灬牛灬叉:BAAALAAECgIIAgAAAA==.',['独苗']='独苗:BAABLAAFFH8JAAIRAAII0xwVNwCSAAARAAII0xwVNwCSAAAAAA==.',['猫粮']='猫粮冲锋:BAABLAAFFH8KAAIEAAIIcweKKgBoAAAEAAIIcweKKgBoAAAAAA==.',['琥珀']='琥珀汌:BAAALAAECgIIAgAAAA==.',['生光']='生光:BAABLAAFFH8GAAIQAAYIBQ60CACKAQAQAAYIBQ60CACKAQAAAA==.',['生椰']='生椰拿铁:BAAALAAFFAIIBAAAAA==.',['疯牛']='疯牛并:BAAALAAECgcIBwAAAA==.',['疾雷']='疾雷奶旋风:BAAALAAECgcIEgAAAA==.',['白夜']='白夜幽:BAAALAAECggIDQAAAA==.',['百兽']='百兽凯多:BAACLAAFFH8OAAIDAAYIXwMzEQDWAAADAAYIXwMzEQDWAAAsAAQKfx8AAgUACAg9HBZPAFsCAAUACAg9HBZPAFsCAAAA.',['皂屁']='皂屁该:BAABLAAFFH8KAAIQAAIILhJ5RABmAAAQAAIILhJ5RABmAAAAAA==.',['砍人']='砍人有点怕:BAAALAAECgYIDQAAAA==.',['窄窄']='窄窄的桥:BAAALAAECgIIAgAAAA==.',['红毛']='红毛怪物:BAAALAAECgcICgAAAA==.',['绿毛']='绿毛怪物:BAAALAADCgcIBwAAAA==.',['老牛']='老牛就是憨:BAAALAADCgMIAwAAAA==.老牛要飙车:BAAALAAFFAIIAgAAAA==.',['肠炎']='肠炎灵:BAAALAADCgEIAQAAAA==.',['脉脉']='脉脉不得語:BAAALAAECggICwAAAA==.',['芋泥']='芋泥:BAAALAADCgUIBQAAAA==.',['花开']='花开丶相依:BAABLAAFFH8GAAICAAIItAhJZQA2AAACAAIItAhJZQA2AAAAAA==.',['花狸']='花狸狐笑:BAACLAAFFH8KAAIaAAIIugu0FAB7AAAaAAIIugu0FAB7AAAsAAQKfxQAAxoACAhNF/sUACoCABoACAhNF/sUACoCABsAAgjxBYZpADsAAAAA.',['苏仑']='苏仑仑:BAAALAAECgIIAgAAAA==.',['苏芷']='苏芷:BAAALAAECgYIBgAAAA==.',['莫邪']='莫邪:BAAALAAECgIIAgAAAA==.',['萌新']='萌新求放过:BAAALAADCgEIAQAAAA==.',['蔚兰']='蔚兰:BAAALAAECgYIEwABLAAFFAIIBwAPAKASAA==.',['薄荷']='薄荷奶绿:BAAALAAECggICgAAAA==.',['藏愛']='藏愛:BAAALAAECgQIBAAAAA==.',['蘭陵']='蘭陵笑笑生:BAAALAAECgMIAwAAAA==.',['血色']='血色华尔茲:BAAALAADCgEIAQAAAA==.',['術女']='術女依旧窈窕:BAABLAAFFH8IAAIUAAIIcAkrVwBmAAAUAAIIcAkrVwBmAAAAAA==.',['術朲']='術朲獸士:BAAALAAECgUIBgAAAA==.',['表哥']='表哥黄油手:BAAALAAECgMIAwAAAA==.',['衮卟']='衮卟衮:BAAALAAECgYICAAAAA==.',['訫偌']='訫偌琅轩:BAAALAAECgYIBgAAAA==.',['诗一']='诗一一:BAAALAAFFAMIAwAAAA==.',['贺强']='贺强:BAAALAAECgcICAAAAA==.',['贾鲁']='贾鲁:BAAALAAECgcIDgAAAA==.',['赎魂']='赎魂圣使:BAAALAAFFAIIAgAAAA==.',['跟随']='跟随女王:BAAALAAECgYIDAAAAA==.',['迪子']='迪子丶:BAAALAADCgEIAQAAAA==.',['迷失']='迷失大帝:BAAALAADCgQIBAAAAA==.迷失幻月:BAAALAAFFAIIAgAAAA==.',['逢敌']='逢敌必亮剑:BAAALAADCgEIAgAAAA==.',['酱肘']='酱肘子:BAAALAAECgYIDgAAAA==.',['野生']='野生赛亚人丶:BAAALAAECgEIAQAAAA==.',['银月']='银月的伊拉:BAAALAADCgEIAQAAAA==.',['银玲']='银玲:BAABLAAFFH8HAAMNAAII2QqUNgCGAAANAAII2QqUNgCGAAAYAAEINgFeMAAsAAAAAA==.',['闹眼']='闹眼子:BAABLAAFFH8GAAIQAAQIeSCpGgBXAQAQAAQIeSCpGgBXAQAAAA==.',['阳光']='阳光丶男孩:BAAALAAECgUIBQAAAA==.',['阿瑞']='阿瑞斯洋葱头:BAABLAAFFH8KAAMTAAIIdR0kEQCiAAATAAIISRYkEQCiAAAUAAIItRmZOwCdAAAAAA==.',['隐居']='隐居青楼:BAAALAAECgYICgAAAA==.',['雪域']='雪域寒风:BAAALAADCgIIAgAAAA==.雪域聖騎:BAAALAADCgEIAQAAAA==.',['霖子']='霖子梅:BAAALAAECggIDgAAAA==.',['霸气']='霸气虚幻哥:BAAALAADCgEIAQAAAA==.',['霹雳']='霹雳贝贝:BAAALAAECgYIBgAAAA==.',['风中']='风中男子:BAAALAAECgYIBgAAAA==.',['风铃']='风铃晚:BAAALAAFFAIIBAAAAA==.',['飞龙']='飞龙之嬛:BAAALAADCgcIBwAAAA==.',['骑猪']='骑猪看风景:BAAALAADCgEIAQAAAA==.',['魔戒']='魔戒一嘟嘟:BAAALAAECgYIBgAAAA==.',['鱼乐']='鱼乐不乐:BAACLAAFFH8qAAIEAAUI2yCzCwCGAQAEAAUI2yCzCwCGAQAsAAQKfxsAAxkACAjnH7gmAKcCABkABwg+IbgmAKcCAAQAAQiAFv2SAEIAAAAA.',['鱼肆']='鱼肆:BAAALAAECgcICAAAAA==.',['鲜毛']='鲜毛肚丶:BAABLAAFFH8SAAIEAAYIXQ+BEwAmAQAEAAYIXQ+BEwAmAQAAAA==.',['麻辣']='麻辣菟头丶:BAAALAAFFAIIAgAAAA==.',['麻风']='麻风王鲍德温:BAAALAAECgUIBQAAAA==.',['黑皮']='黑皮萨满:BAAALAAECgYIBgAAAA==.',['龙莹']='龙莹龙:BAAALAADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end