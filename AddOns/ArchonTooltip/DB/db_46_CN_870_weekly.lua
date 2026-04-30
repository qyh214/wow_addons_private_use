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

local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Mage-Frost','Rogue-Subtlety','Monk-Brewmaster','DemonHunter-Devourer','DemonHunter-Havoc','Druid-Balance','Shaman-Enhancement','Priest-Shadow','Paladin-Holy','Warlock-Demonology','Druid-Restoration','Warrior-Protection','Paladin-Retribution','DeathKnight-Unholy','Priest-Holy','Unknown-Unknown','Warlock-Destruction','DeathKnight-Blood','Shaman-Restoration','Hunter-Survival',}
local provider = {region='CN',realm='阿比迪斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Absolution:BAAALgAECgYJDQAAAA==.',
Al='Alexandre:BAAALgAECgEJAgAAAA==.',
An='Anoxia:BAABLgAFFH8IAAMBAAQJlRwAAgCBAQABAAQJlRwAAgCBAQACAAEJQQdGKwBEAAAAAA==.',
Co='Confiteor:BAAALgAECgkJCgABLgAFFAcJEgADAEEVAA==.',
Dg='Dgirl:BAAALgAECgQJCQAAAA==.',
Ma='Mahale:BAAALgADCgcJDgAAAA==.',
Ne='Neighorhood:BAAALgAECgEJAQAAAA==.Nelthariona:BAABLgAECn8hAAQEAAgJ+xLqGADKAQAEAAYJDBfqGADKAQAFAAcJUxH1EgCzAQAGAAgJ9xWzJgCHAQAAAA==.',
Qi='Qingsong:BAABLgAFFH8HAAIHAAIJMh/eHwC1AAAHAAIJMh/eHwC1AAAAAA==.',
Re='Reroll:BAAALgADCgIJAgAAAA==.',
So='Somaxx:BAAALgAECgYJCAAAAA==.',
Tr='Trippe:BAAALgAECgIJAgAAAA==.',
Ve='Vermmicelli:BAAALgAFFAQJBAAAAA==.',
Vi='Vigoss:BAAALgAECgcJAQAAAA==.',
Ws='Ws:BAAALgAECgkJCgAAAA==.',
Yy='Yyoorha:BAAALgADCgEJAQAAAA==.',
['一一']='一一丶丸:BAAALgAECgYJBgAAAA==.',
['一种']='一种回魂:BAAALgAECgYJDQAAAA==.',
['丁达']='丁达尔迅贤:BAAALgAECgkJDAAAAA==.',
['七喜']='七喜啵啵:BAAALgADCgEJAQAAAA==.',
['万物']='万物皆虚:BAACLgAFFH8JAAIIAAQJYxsgBgB+AQAIAAQJYxsgBgB+AQAuAAQKfxkAAggACAmeGogSAIgCAAgACAmeGogSAIgCAAAA.',
['三克']='三克拉丶恋语:BAAALgAECgcJBwAAAA==.',
['三横']='三横一竖的人:BAAALgADCgEJAQAAAA==.',
['不是']='不是唯一的柒:BAAALgAECgYJDgAAAA==.',
['不羁']='不羁叮叮猫:BAAALgADCgUJBQAAAA==.',
['专治']='专治没头苍蝇:BAABLgAECn8VAAIJAAcJWQzSPgBKAQAJAAcJWQzSPgBKAQAAAA==.',
['世间']='世间祥瑞:BAABLgAFFH8FAAICAAMJwyGGEAArAQACAAMJwyGGEAArAQAAAA==.',
['东北']='东北大仙:BAAALgAFFAMJAwAAAA==.',
['东山']='东山灬再起:BAAALgAFFAQJBAAAAA==.',
['东成']='东成西就:BAAALgADCgQJBAAAAA==.',
['丨奈']='丨奈依组特:BAAALgAECgcJEwAAAA==.',
['丨楚']='丨楚天帝:BAAALgAECgcJDQAAAA==.',
['丨火']='丨火鸡味锅巴:BAAALgAECgYJCwAAAA==.',
['丨随']='丨随风:BAAALgAECgQJBAAAAA==.',
['丶柴']='丶柴郡猫:BAAALgAECgYJDQAAAA==.',
['为了']='为了小鱼干:BAAALgAECgUJBwAAAA==.',
['久久']='久久射射:BAAALgAECgYJDAAAAA==.',
['九十']='九十九号:BAAALgAECgEJAgAAAA==.',
['二扣']='二扣三個八:BAAALgAFFAIJAgAAAA==.',
['云芝']='云芝:BAAALgAECgUJBQAAAA==.',
['今日']='今日说法:BAAALgAFFAIJAgAAAA==.',
['以撒']='以撒:BAACLgAFFH8SAAIKAAUJkBjbBgBOAQAKAAUJkBjbBgBOAQAuAAQKfy4AAwoACAn6I70DAH8CAAoACAmII70DAH8CAAsABwn5GakfAMEBAAAA.',
['传说']='传说中的逗逗:BAAALgADCgUJBQAAAA==.传说中的逗逼:BAAALgAECgQJBQAAAA==.',
['你被']='你被牛打过:BAABLgAFFH8GAAIMAAUJnBHLCQBLAQAMAAUJnBHLCQBLAQAAAA==.',
['來信']='來信电:BAABLgAFFH8IAAINAAIJUiAZBAC9AAANAAIJUiAZBAC9AAABLgAFFAQJDgAOAOcQAA==.',
['俺不']='俺不中嘞:BAAALgAECgQJBQAAAA==.',
['倒影']='倒影丶:BAAALgADCgEJAQAAAA==.',
['光明']='光明母牛:BAAALgADCgEJAQAAAA==.',
['光阴']='光阴荏苒:BAAALgADCgYJCwAAAA==.',
['冯依']='冯依甜:BAABLgAFFH8IAAIPAAQJ2ATBBgATAQAPAAQJ2ATBBgATAQAAAA==.',
['冯珊']='冯珊甜:BAAALgAFFAQJBAAAAA==.',
['冰凤']='冰凤:BAAALgAECgcJBwAAAA==.',
['冰枫']='冰枫:BAAALgADCgIJAgAAAA==.',
['冰路']='冰路:BAAALgAECgUJBwAAAA==.',
['冷血']='冷血崽崽:BAAALgAECgEJAgAAAA==.',
['凉小']='凉小戒:BAAALgAECgMJAwAAAA==.',
['凉戎']='凉戎戒丶:BAAALgAECgQJBQAAAA==.',
['初生']='初生的东汐:BAAALgADCgQJBAAAAA==.',
['别凶']='别凶我嘛:BAAALgADCgEJAQAAAA==.',
['别削']='别削弱我:BAABLgAFFH8GAAIQAAMJux/wGAApAQAQAAMJux/wGAApAQAAAA==.',
['加厼']='加厼鲁什:BAAALgAFFAIJAwAAAA==.',
['单车']='单车战神:BAAALgAFFAIJAgAAAA==.',
['厉害']='厉害吃货:BAAALgAECgYJCwAAAA==.',
['变个']='变个树人:BAAALgAFFAIJAwAAAA==.',
['只为']='只为一人唱:BAAALgAECgIJAgAAAA==.',
['吉赛']='吉赛尔的信仰:BAAALgAECgUJBwAAAA==.吉赛尔的决断:BAAALgADCgEJAQAAAA==.吉赛尔的守护:BAAALgAECgUJBQAAAA==.',
['吴江']='吴江法神:BAAALgAFFAIJBAAAAA==.',
['吾色']='吾色:BAAALgADCgIJAgAAAA==.',
['呦吼']='呦吼喂吼:BAAALgADCgUJBQAAAA==.',
['哇哦']='哇哦:BAAALgAECgYJBwAAAA==.',
['哈哈']='哈哈哥:BAAALgAECgQJBQAAAA==.',
['哥就']='哥就是李刚:BAABLgAFFH8KAAIPAAMJVhzTBwD2AAAPAAMJVhzTBwD2AAAAAA==.',
['啊啵']='啊啵:BAAALgAECgYJBgAAAA==.',
['嗯丨']='嗯丨忝吧:BAAALgAFFAIJAwAAAA==.',
['嗷呜']='嗷呜丶:BAAALgADCgEJAQAAAA==.嗷呜小猪:BAAALgADCgEJAQAAAA==.',
['嚏降']='嚏降尸王:BAAALgADCgUJBQAAAA==.',
['回春']='回春:BAABLgAFFH8FAAIRAAQJeQNTDwDzAAARAAQJeQNTDwDzAAAAAA==.',
['国民']='国民表率:BAAALgAECgQJBwAAAA==.',
['囿毐']='囿毐啲拉菲尔:BAACLgAFFH8FAAIQAAMJFAnCOQCgAAAQAAMJFAnCOQCgAAAuAAQKfxUAAhAACAmQFR5LAOgBABAACAmQFR5LAOgBAAAA.',
['土也']='土也米青凤姐:BAAALgADCgUJBQAAAA==.',
['圣光']='圣光假面骑士:BAAALgAECgEJAQAAAA==.圣光永不熄灭:BAAALgAECgEJAQAAAA==.',
['圣堂']='圣堂骑士亚瑟:BAAALgAECgQJBAAAAA==.',
['圣翼']='圣翼丶风暴:BAAALgAFFAEJAQAAAA==.',
['在下']='在下车不圆:BAAALgAECgcJBwAAAA==.',
['坚挺']='坚挺的狐狸:BAAALgAECgEJAQAAAA==.',
['埋尸']='埋尸人:BAAALgAECgYJBgAAAA==.',
['夏天']='夏天在飘雪:BAAALgAECgEJAQAAAA==.夏天小雪:BAAALgADCgMJAwAAAA==.',
['夜雨']='夜雨汀香:BAAALgADCgEJAQAAAA==.',
['大万']='大万:BAACLgAFFH8NAAISAAQJoQQZCADaAAASAAQJoQQZCADaAAAuAAQKfyEAAhIABwksEmoZAIYBABIABwksEmoZAIYBAAAA.',
['大棍']='大棍棍:BAAALgADCgMJAwAAAA==.',
['天降']='天降正义丶:BAABLgAFFH8JAAIKAAQJzh1cDABxAQAKAAQJzh1cDABxAQAAAA==.',
['天青']='天青色等烟雨:BAAALgAECgUJBQAAAA==.',
['太极']='太极熊猫:BAAALgAECgQJBQAAAA==.',
['奶思']='奶思:BAAALgADCgUJBQAAAA==.',
['如嫣']='如嫣丶幻雪:BAAALgAECgYJBgAAAA==.',
['妖気']='妖気丸丶:BAAALgAECgYJCwAAAA==.',
['宁静']='宁静:BAABLgAFFH8KAAIRAAUJNQPMCgAvAQARAAUJNQPMCgAvAQAAAA==.',
['安娜']='安娜伊芙琳:BAAALgAECgYJCQAAAA==.',
['寂野']='寂野:BAAALgAECgkJDwAAAA==.',
['小仓']='小仓丽娅:BAAALgAECgYJBgAAAA==.',
['小咯']='小咯咯大领主:BAAALgAECgcJBwAAAA==.',
['小时']='小时了了:BAAALgAECgYJDgAAAA==.',
['小脓']='小脓人:BAAALgAFFAEJAQAAAA==.',
['尛饅']='尛饅頭:BAAALgAFFAIJAQAAAA==.',
['山前']='山前风止:BAAALgAECgEJAQAAAA==.',
['屹立']='屹立蛋怒风:BAAALgAECgQJBAAAAA==.',
['岚岚']='岚岚丶:BAAALgADCgcJBwAAAA==.',
['巡山']='巡山丶小妖:BAAALgAECgQJBQAAAA==.巡山老妖:BAAALgAECgQJBAAAAA==.',
['希尔']='希尔瓦娜簛:BAACLgAFFH8FAAIBAAMJuRePDgDFAAABAAMJuRePDgDFAAAuAAQKfxQAAgEABwnFHeEgAEACAAEABwnFHeEgAEACAAAA.',
['弑魔']='弑魔诛神:BAAALgAECgEJAgAAAA==.',
['德育']='德育处总管:BAABLgAFFH8FAAITAAUJbgpCBwB8AQATAAUJbgpCBwB8AQAAAA==.',
['心动']='心动跳跳糖:BAAALgAFFAEJAQAAAA==.',
['怀旧']='怀旧骚年:BAAALgAECgYJBgAAAA==.',
['恩賜']='恩賜灬解脫:BAAALgAECgUJCQAAAA==.',
['恶意']='恶意:BAAALgADCgcJCwAAAA==.',
['惠惠']='惠惠:BAAALgAECgYJBgAAAA==.',
['愤怒']='愤怒的小苹果:BAAALgADCgEJAQAAAA==.愤怒的老头:BAAALgAECgYJBgAAAA==.愤怒的螺丝:BAAALgAECgQJBAAAAA==.',
['我的']='我的确萌新:BAAALgAECgYJDwAAAA==.',
['我还']='我还是太年轻:BAAALgADCgYJBgAAAA==.',
['手遮']='手遮黑森林:BAAALgAECgYJCQAAAA==.',
['托天']='托天魔功韩立:BAACLgAFFH8LAAITAAUJrRwfAwDGAQATAAUJrRwfAwDGAQAuAAQKfxsAAhMACAlKHEk+ACwCABMACAlKHEk+ACwCAAAA.',
['扛不']='扛不住了鸭:BAAALgAFFAEJAQAAAA==.',
['护学']='护学岗大叔:BAAALgAECgUJCAAAAA==.',
['拿什']='拿什么挽留你:BAABLgAECn8XAAIUAAYJsh3hUwD2AQAUAAYJsh3hUwD2AQAAAA==.',
['指压']='指压板:BAAALgADCgMJAwAAAA==.',
['掌心']='掌心:BAAALgAECgIJAwAAAA==.',
['揾阿']='揾阿笨:BAAALgAECgQJBQAAAA==.',
['斩杀']='斩杀者:BAAALgAECgYJCgAAAA==.',
['斯卡']='斯卡蒂:BAAALgAECgcJEAAAAA==.',
['新安']='新安洲:BAABLgAECn8VAAITAAgJJx0QPwApAgATAAgJJx0QPwApAgAAAA==.',
['无尽']='无尽的死亡:BAABLgAFFH8GAAIUAAIJRxMcPwChAAAUAAIJRhMcPwChAAAAAA==.无尽的誓言:BAAALgAECgEJAwAAAA==.',
['无敌']='无敌最俊美:BAAALgAFFAIJAwAAAA==.',
['时分']='时分:BAAALgADCgEJAQAAAA==.',
['明天']='明天星期六:BAAALgADCgIJAgAAAA==.',
['明心']='明心破瘴:BAAALgAECgcJCQAAAA==.',
['明月']='明月之心:BAACLgAFFH8HAAIHAAIJdxXFOwC0AAAHAAIJdxXFOwC0AAAuAAQKfxgAAgcABwnrGQZnAAkCAAcABwnrGQZnAAkCAAAA.',
['星际']='星际火狐:BAAALgAECgcJCAAAAA==.',
['晒太']='晒太阳的猫熊:BAAALgAECgcJAwAAAA==.',
['晚秋']='晚秋之舞:BAAALgAFFAQJBAAAAA==.',
['暗影']='暗影蔷薇:BAABLgAFFH8IAAMVAAMJzwrECQDKAAAVAAMJFAnECQDKAAADAAEJUQapDwBJAAAAAA==.',
['最牛']='最牛的冰法:BAAALgAECgEJAQAAAA==.',
['月下']='月下酒:BAAALgADCgUJBQAAAA==.',
['有个']='有个大师:BAAALgAECgQJBAAAAA==.',
['木木']='木木夕灬:BAAALgAECgkJCQAAAA==.',
['术大']='术大招风:BAAALgAECgcJBwAAAA==.',
['杉木']='杉木松:BAAALgAECgIJAwAAAA==.',
['杰克']='杰克达斯维达:BAAALgAECgYJDgAAAA==.杰克阿瑟:BAAALgAECgcJEQAAAA==.',
['枯楊']='枯楊之稊:BAAALgAECgQJBAAAAA==.',
['柠檬']='柠檬味的柑橘:BAACLgAFFH8HAAIMAAMJAgtKDwDsAAAMAAMJAgtKDwDsAAAuAAQKfxQAAgwABgknHbgsAJ0BAAwABgknHbgsAJ0BAAAA.',
['棉麻']='棉麻酱:BAAALgAECgYJCgAAAA==.',
['楊眉']='楊眉吐气:BAAALgAECgYJDQAAAA==.',
['橙色']='橙色加血小人:BAABLgAFFH8OAAIMAAQJKx0mAwBbAQAMAAQJKx0mAwBbAQAAAA==.',
['欢哥']='欢哥超牛:BAAALgAECgUJAgAAAA==.',
['歌灬']='歌灬妲妮:BAAALgAECgEJAQAAAA==.',
['死神']='死神饕餮:BAAALgAFFAIJAgAAAA==.死神饕餮德:BAAALgAFFAIJAgABLgAFFAIJAgAWAAAAAA==.死神饕餮萌:BAAALgAECgMJAwABLgAFFAIJAgAWAAAAAA==.',
['水深']='水深呼吸:BAAALgAECgEJAQAAAA==.',
['汐顔']='汐顔:BAACLgAFFH8FAAIHAAMJmRS6KgAKAQAHAAMJmRS6KgAKAQAuAAQKfxsAAgcACAmqG7c3AJYCAAcACAmqG7c3AJYCAAAA.',
['没头']='没头苍蝇:BAAALgAECgUJBgAAAA==.',
['法爆']='法爆一击:BAAALgAECgMJAwAAAA==.',
['波比']='波比锤子大:BAAALgAECgUJAQAAAA==.',
['泰瑞']='泰瑞亚灬辶:BAAALgAECgQJBgAAAA==.',
['洛壹']='洛壹乌:BAAALgAFFAQJBAAAAA==.洛壹伞:BAABLgAFFH8FAAICAAQJRxJ+DwA2AQACAAQJRxJ+DwA2AQAAAA==.洛壹尔:BAAALgAFFAQJBAAAAA==.洛壹异:BAAALgAFFAQJBAAAAA==.洛壹斯:BAABLgAFFH8HAAICAAQJ1xjFAQBeAQACAAQJ1xjFAQBeAQAAAA==.洛壹柳:BAAALgAFFAQJAQAAAA==.',
['涅磐']='涅磐丶启程:BAAALgAECgEJAgAAAA==.',
['混的']='混的起的人:BAAALgAECgUJBQAAAA==.',
['渡川']='渡川沉星:BAAALgAECgMJAwAAAA==.',
['滴尅']='滴尅诶:BAABLgAECn8hAAIUAAcJch7TOABTAgAUAAcJch7TOABTAgAAAA==.',
['滿是']='滿是纏綿:BAAALgAECgYJDAAAAA==.',
['漱漱']='漱漱口:BAAALgADCgMJAgAAAA==.',
['潶沐']='潶沐:BAAALgAECgUJCAAAAA==.',
['激活']='激活:BAABLgAFFH8GAAIRAAUJKwPnCgAuAQARAAUJKwPnCgAuAQAAAA==.',
['灵法']='灵法:BAAALgAECgEJAgAAAA==.',
['点我']='点我领取橙戒:BAAALgAFFAQJBAAAAA==.',
['烧死']='烧死那只狐狸:BAAALgAFFAEJAQAAAA==.',
['熊也']='熊也有抱负:BAAALgAECgEJAQAAAA==.',
['熬过']='熬过每个夜:BAAALgADCgcJBwAAAA==.',
['爆炒']='爆炒干巴菌:BAABLgAFFH8MAAIDAAYJsyHHAgCfAQADAAYJsyHHAgCfAQAAAA==.爆炒牛肝菌:BAABLgAFFH8IAAIDAAQJ5BszBwBpAQADAAQJ5BszBwBpAQAAAA==.',
['牛乃']='牛乃乃:BAAALgAECgcJEAAAAA==.',
['牛牛']='牛牛的骑士:BAAALgAFFAEJAQAAAA==.',
['猎魔']='猎魔铠甲:BAAALgAECgEJAQAAAA==.',
['王导']='王导:BAAALgAECgkJCQAAAA==.',
['珊珊']='珊珊小恶魔:BAAALgAECgYJDwAAAA==.',
['电子']='电子惩戒骑:BAAALgADCgEJAQAAAA==.',
['男模']='男模爱吃兔兔:BAABLgAFFH8FAAIUAAIJJApVJACVAAAUAAIJJApVJACVAAAAAA==.',
['疯小']='疯小墨:BAABLgAFFH8HAAMPAAMJCA9xCADnAAAPAAMJCA9xCADnAAATAAEJxwriMABTAAAAAA==.',
['白天']='白天没鸟事:BAAALgAECgYJBAAAAA==.',
['盲人']='盲人推拿师:BAAALgAECgYJBgAAAA==.',
['看海']='看海的狐狸:BAAALgAECggJCgAAAA==.',
['真爱']='真爱之骑:BAAALgAECgYJDAAAAA==.',
['真猪']='真猪儿虫:BAAALgADCgUJBwAAAA==.',
['瞎猫']='瞎猫丶:BAACLgAFFH8VAAMQAAYJUBZcBQDJAQAQAAUJjBVcBQDJAQAXAAIJLBJsDACpAAAuAAQKfyAAAxAACAm1IjgfAJwCABAACAleITgfAJwCABcAAwlQIa8rABEBAAAA.',
['秋逗']='秋逗嘛得:BAAALgAECgEJAQAAAA==.',
['秦岭']='秦岭云横:BAAALgADCgUJBQAAAA==.',
['素质']='素质流氓法哥:BAAALgAECgEJAQAAAA==.',
['绝对']='绝对不死王者:BAAALgAECgUJBgAAAA==.绝对杀戮:BAAALgADCgUJBgAAAA==.',
['绣冬']='绣冬:BAAALgAECgIJAgAAAA==.',
['绽放']='绽放:BAABLgAFFH8FAAIRAAUJLgJGDAAfAQARAAUJLgJGDAAfAQAAAA==.',
['绿里']='绿里奇迹:BAAALgAECgYJBwAAAA==.',
['羽翼']='羽翼丨镰刀:BAAALgAECgYJEwAAAA==.',
['老劉']='老劉盲:BAAALgAECgEJAgAAAA==.',
['肉球']='肉球:BAABLgAFFH8KAAMEAAQJPhccBwDsAAAEAAMJtRUcBwDsAAAGAAEJmwLSGAA+AAAAAA==.',
['胧月']='胧月猫:BAAALgAECgMJAgAAAA==.',
['脆皮']='脆皮小猪骑:BAABLgAFFH8JAAMYAAMJOgtdDwB1AAAYAAIJZA5dDwB1AAAUAAEJ6AQcWQBJAAAAAA==.脆皮鸡肉卷:BAAALgAECgQJBAAAAA==.',
['致命']='致命的手术刀:BAAALgAECgkJCQAAAA==.',
['花落']='花落莫吩离:BAAALgAECgQJBgAAAA==.',
['苏坡']='苏坡曼:BAACLgAFFH8GAAIRAAIJYAizEgB1AAARAAIJYAizEgB1AAAuAAQKfxUAAxEABgmFD1ZqABQBABEABgmFD1ZqABQBAAwAAgkICBx3AEcAAAAA.',
['草莓']='草莓汽水丶:BAAALgAECgkJEgAAAA==.',
['莫克']='莫克莱尼:BAAALgAECgcJDAAAAA==.',
['莫彩']='莫彩环:BAAALgAECgYJBgAAAA==.',
['莫逐']='莫逐燕:BAACLgAFFH8FAAIZAAIJfRb3DgCUAAAZAAIJfRb3DgCUAAAuAAQKfx4AAhkACAkMFLQPAHMBABkACAkMFLQPAHMBAAAA.',
['萌亮']='萌亮:BAAALgAFFAEJAQAAAA==.',
['萌小']='萌小神丶:BAAALgAFFAIJAgAAAA==.',
['萌萌']='萌萌哟:BAAALgAFFAQJBAAAAA==.',
['落单']='落单的骑士:BAAALgAECgEJAQAAAA==.',
['落瞳']='落瞳:BAAALgADCgcJBwAAAA==.',
['葑麤']='葑麤:BAAALgADCgIJAgAAAA==.',
['蒸汽']='蒸汽蘑菇:BAAALgAFFAIJAgAAAA==.',
['蓝啵']='蓝啵兔:BAABLgAFFH8GAAITAAMJHBxqEADJAAATAAMJHBxqEADJAAAAAA==.',
['蓝色']='蓝色妖女:BAAALgADCgEJAQAAAA==.',
['蛋淡']='蛋淡蛋:BAAALgAECgYJBwAAAA==.',
['蝌蚪']='蝌蚪:BAAALgAECgYJEgAAAA==.',
['褚小']='褚小小:BAAALgAECgcJCwAAAA==.',
['解释']='解释:BAAALgAECgEJAQAAAA==.',
['请叫']='请叫我酷狼:BAAALgAECgUJBQAAAA==.',
['谈笑']='谈笑红颜:BAAALgAECgEJAQAAAA==.',
['贼贱']='贼贱乂贼贱:BAABLgAECn8UAAIIAAcJYhmmGQA2AgAIAAcJYhmmGQA2AgAAAA==.',
['贾丶']='贾丶克丶斯:BAAALgAECgYJBgAAAA==.',
['赞妞']='赞妞丶:BAAALgAFFAEJAQAAAA==.',
['超级']='超级大红手:BAAALgAECgUJDAAAAA==.',
['轩辕']='轩辕老鬼:BAAALgAFFAEJAQAAAA==.',
['轻斟']='轻斟浅醉:BAAALgAECgIJAgAAAA==.',
['辣辣']='辣辣的保镖:BAAALgAECgEJAQAAAA==.',
['过往']='过往温柔:BAAALgADCgcJBwAAAA==.',
['这不']='这不是喵德:BAAALgADCgYJBgAAAA==.',
['这牛']='这牛给力:BAABLgAECn8VAAIUAAkJWhr5HQDNAgAUAAkJWhr5HQDNAgAAAA==.',
['逐风']='逐风者的丧钟:BAAALgAFFAMJAwAAAA==.',
['邪恶']='邪恶之神:BAAALgADCgUJBQAAAA==.邪恶小妖精:BAAALgAECgIJAgAAAA==.',
['部落']='部落英熊:BAAALgAECgUJCQAAAA==.',
['铁木']='铁木树皮:BAABLgAFFH8FAAIRAAUJQwITDAAhAQARAAUJQwITDAAhAQAAAA==.',
['银光']='银光之月:BAAALgAECgkJEQAAAA==.',
['阿咦']='阿咦妞妞:BAAALgAECgMJAgAAAA==.',
['阿迩']='阿迩忒彌斯:BAAALgADCgMJAwAAAA==.',
['陌路']='陌路晓猎:BAAALgAECgIJAgAAAA==.',
['随遇']='随遇而安:BAAALgAECgEJAQAAAA==.',
['離殇']='離殇:BAACLgAFFH8GAAITAAIJ9BeRFACqAAATAAIJ9BeRFACqAAAuAAQKfxgAAhMABwnFIAUwAGMCABMABwnFIAUwAGMCAAAA.',
['雪猎']='雪猎手:BAAALgAECgYJDAAAAA==.',
['雾殇']='雾殇雨:BAABLgAECn8XAAMTAAgJ9R9gFADxAgATAAgJ9R9gFADxAgAPAAYJ/BkGOACaAQAAAA==.',
['霜雪']='霜雪恶灵:BAAALgAECgEJAQAAAA==.',
['霸气']='霸气大魔王:BAAALgAECgEJAQAAAA==.',
['青浦']='青浦欢哥:BAAALgAECgYJCwAAAA==.',
['青衣']='青衣:BAACLgAFFH8FAAIHAAIJmB8mHgC/AAAHAAIJmB8mHgC/AAAuAAQKfxwAAgcABwksJUEhAO4CAAcABwksJUEhAO4CAAAA.',
['静下']='静下心学刁:BAAALgAECgEJAgAAAA==.',
['顾影']='顾影画眉:BAAALgAECgEJAQAAAA==.',
['领闲']='领闲主演:BAAALgAECgYJDQAAAA==.',
['风丿']='风丿瑶筝:BAAALgADCgIJAgAAAA==.',
['风过']='风过鸟无痕:BAAALgAECgMJAwAAAA==.',
['飘上']='飘上月球:BAAALgAECgQJBQAAAA==.',
['飞矢']='飞矢天涯:BAAALgAECgYJEAAAAA==.',
['飯爺']='飯爺:BAAALgAECgYJBwAAAA==.',
['饼乾']='饼乾:BAAALgADCgUJBQAAAA==.',
['鬓霜']='鬓霜何妨:BAAALgAECgEJAQAAAA==.',
['魂兮']='魂兮冥帝:BAAALgADCgEJAQAAAA==.魂兮圣雄:BAAALgADCgMJAwAAAA==.',
['魅魅']='魅魅丶:BAAALgAFFAEJAQAAAA==.',
['魔鬼']='魔鬼不疯狂:BAAALgAECgYJBgAAAA==.',
['鸟尽']='鸟尽弓藏:BAACLgAFFH8KAAIaAAQJ6RjUAQAoAQAaAAQJ6RjUAQAoAQAuAAQKfyEAAhoABwlRJM4DAOUCABoABwlRJM4DAOUCAAAA.',
['鹤唳']='鹤唳霜:BAAALgAFFAEJAQAAAA==.',
['麦卡']='麦卡农:BAAALgAECgQJBQAAAA==.',
['黯影']='黯影蔷薇:BAAALgAFFAIJAgAAAA==.',
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
