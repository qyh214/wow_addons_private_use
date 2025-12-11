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
 local lookup = {'Warrior-Fury','Warrior-Arms','DeathKnight-Frost','Paladin-Retribution','Mage-Frost','Priest-Holy','Priest-Shadow','Druid-Restoration','Warlock-Demonology','DemonHunter-Havoc','Druid-Balance','Warlock-Destruction','Hunter-BeastMastery','DeathKnight-Unholy','Paladin-Protection','Rogue-Assassination','Rogue-Subtlety','Druid-Guardian','Shaman-Restoration','Unknown-Unknown','DemonHunter-Vengeance','Druid-Feral','Priest-Discipline','Mage-Arcane','Mage-Fire','Paladin-Holy','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Evoker-Preservation','DeathKnight-Blood',}; local provider = {region='CN',realm='库德兰',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Andrewzh:BAAALAAECgQIBAAAAA==.',At='Atlantis:BAABLAAFFH8TAAMBAAUI0x0yIgBcAQABAAUI0x0yIgBcAQACAAEIThCoCABJAAAAAA==.',Ba='Babyonic:BAACLAAFFH8ZAAIDAAYIlxEONABrAQADAAYIlxEONABrAQAsAAQKfxYAAgMACAjZHDMsAMQBAAMACAjZHDMsAMQBAAAA.',Be='Beforetime:BAABLAAFFH8KAAIEAAIIsxqLVQBMAAAEAAIIsxqLVQBMAAAAAA==.',Ch='Chaons:BAAALAADCgYIBgAAAA==.',Do='Dowant:BAAALAAFFAIIBAAAAA==.',Fs='Fskings:BAAALAADCgUIBQABLAAFFAIIDAACAGodAA==.',Ja='Jamesjw:BAABLAAFFH8QAAIFAAUIkQeVCQDiAAAFAAUIkQeVCQDiAAAAAA==.',Ji='Jixiegeming:BAAALAAECgcICAAAAA==.',Mi='Miquella:BAACLAAFFH8pAAIGAAYISSI5CgAlAgAGAAYISSI5CgAlAgAsAAQKf0MAAgYACAjeJWsFAEUDAAYACAjeJWsFAEUDAAAA.',Na='Nausicca:BAACLAAFFH8gAAMHAAUImBaAFAAuAQAHAAUImBaAFAAuAQAGAAEIIA9QUAA2AAAsAAQKfzAAAwcACAikHiMLACkCAAcACAikHiMLACkCAAYAAQiTEOi+ADMAAAAA.',Pl='Playermvmcyg:BAAALAADCgcIBwAAAA==.',Po='Popo:BAAALAAECgYIBgAAAA==.',Ry='Rykard:BAACLAAFFH8KAAIIAAQIcxOBJAD2AAAIAAQIcxOBJAD2AAAsAAQKfxYAAggABgiSHnw3AAECAAgABgiSHnw3AAECAAEsAAUUBggpAAYASSIA.',['不会']='不会奶的鹌鹑:BAAALAADCggICAAAAA==.',['不吃']='不吃香菜:BAAALAADCgYIBgAAAA==.不吃鱼的懒猫:BAAALAAECgYIBgAAAA==.',['东尼']='东尼乔巴:BAABLAAECn8WAAIJAAYIsBgyEABpAQAJAAYIsBgyEABpAQAAAA==.',['丫喜']='丫喜留香:BAAALAAECgYIDAAAAA==.',['中神']='中神父:BAAALAAECgcICwAAAA==.中神爸:BAAALAAECgMIBAAAAA==.',['主任']='主任大盗:BAAALAAECgYIBgAAAA==.',['九幽']='九幽狱蝶:BAACLAAFFH8TAAIBAAUIMRU7KAAuAQABAAUIMRU7KAAuAQAsAAQKfyEAAgEACAgfHbkSAE8CAAEACAgfHbkSAE8CAAAA.',['今夜']='今夜难眠:BAAALAAECgUIBQAAAA==.',['伊利']='伊利娜丽:BAAALAADCggICAAAAA==.',['会笑']='会笑的狼:BAABLAAFFH8FAAICAAMI0QW1AwBjAAACAAMI0QW1AwBjAAAAAA==.',['伯爵']='伯爵:BAABLAAFFH8FAAIKAAMIRhzVOQClAAAKAAMIRhzVOQClAAAAAA==.',['伶俐']='伶俐鬼:BAABLAAFFH8LAAILAAUI4wVoIwCUAAALAAUI4wVoIwCUAAAAAA==.',['倾心']='倾心玉雪:BAAALAAECgEIAQAAAA==.',['元素']='元素应我召唤:BAAALAAFFAIIAgAAAA==.',['光头']='光头兄:BAAALAAECggICAAAAA==.',['克里']='克里斯汀碧:BAAALAAECggICAABLAAFFAgIBwAJAMwgAA==.',['八千']='八千星:BAAALAADCgIIAgAAAA==.',['冷月']='冷月酆神:BAAALAAECgcIEwAAAA==.',['初来']='初来之三:BAAALAAECgQIAgAAAA==.',['别离']='别离我太远:BAAALAADCggIDgAAAA==.',['加百']='加百列:BAAALAAECgMIAwAAAA==.',['双双']='双双:BAAALAAECgcIBwAAAA==.',['变成']='变成小野猪:BAAALAADCgUIBgAAAA==.',['古灵']='古灵精怪:BAAALAAFFAIIAgAAAA==.',['叮叮']='叮叮铛铛:BAACLAAFFH8SAAIKAAIIJRVeUgBHAAAKAAIIJRVeUgBHAAAsAAQKfyAAAgoABgjAGox3ANYBAAoABgjAGox3ANYBAAAA.',['叮铛']='叮铛叮铛:BAACLAAFFH8KAAIDAAIIwQeOkwA9AAADAAIIwQeOkwA9AAAsAAQKfxYAAgMABgjmEjhcADgBAAMABgjmEjhcADgBAAAA.叮铛钉:BAAALAAFFAIIBAAAAA==.叮铛铛:BAABLAAFFH8KAAMJAAIIkwzlFgA9AAAJAAIIkwzlFgA9AAAMAAIINgTubAAzAAAAAA==.叮铛铛叮:BAABLAAFFH8KAAINAAIIVhQQjgBGAAANAAIIVhQQjgBGAAAAAA==.',['吉尔']='吉尔尼斯狼德:BAABLAAECn8bAAMIAAcIvgxzeQAuAQAIAAcIvgxzeQAuAQALAAMITgWrmgBiAAAAAA==.',['咕咕']='咕咕胖咕咕胖:BAABLAAFFH8GAAIIAAIIywoKOwBlAAAIAAIIywoKOwBlAAAAAA==.',['哈娜']='哈娜:BAABLAAECn8jAAMDAAgIqhn6WgBAAgADAAgImBn6WgBAAgAOAAYI+hMXLgBUAQAAAA==.',['唬咧']='唬咧咧:BAAALAAFFAIIBAAAAA==.',['喵帕']='喵帕丝:BAABLAAFFH8GAAILAAYIBxrkDQCGAQALAAYIBxrkDQCGAQAAAA==.',['嗰柒']='嗰柒头又发瘟:BAAALAADCgQIBgAAAA==.',['土老']='土老冒:BAABLAAFFH8GAAIBAAYIkQGWOACQAAABAAYIkQGWOACQAAAAAA==.土老帽:BAAALAADCgQIBAAAAA==.',['圣域']='圣域油菜:BAACLAAFFH8aAAIEAAQICxmlMgDuAAAEAAQICxmlMgDuAAAsAAQKfzgAAwQACAiUIR8VAGUCAAQACAiUIR8VAGUCAA8AAwh7BoZtAFUAAAAA.',['地狱']='地狱:BAABLAAFFH8IAAIMAAII7he9NwCiAAAMAAII7he9NwCiAAAAAA==.',['坤和']='坤和散人:BAAALAADCgUIBQAAAA==.',['天下']='天下有个贼:BAAALAAECgMICAAAAA==.',['天从']='天从云:BAAALAAECggIEQAAAA==.',['天天']='天天萧萧:BAAALAADCgMIAwAAAA==.',['太玄']='太玄:BAAALAADCgQIBAAAAA==.太玄萨:BAAALAAECgIIAwAAAA==.',['太阳']='太阳啊太阳:BAAALAAECgYIDwAAAA==.',['奶个']='奶个锤锤:BAAALAAECgMIAwAAAA==.',['宝宝']='宝宝鱼:BAABLAAECn8YAAINAAYInBCwvwDuAAANAAYInBCwvwDuAAAAAA==.',['寂寞']='寂寞蛋疼:BAAALAADCggICAAAAA==.',['小刀']='小刀片:BAAALAAECgYICAAAAA==.',['小小']='小小文:BAACLAAFFH8UAAIQAAUIxwyFDQA1AQAQAAUIxwyFDQA1AQAsAAQKfxUAAxAABwhNFYkMAJoBABAABwhNFYkMAJoBABEABAgsDwMXAKgAAAAA.小小箭:BAABLAAFFH8OAAINAAMIMBnCZgCbAAANAAMIMBnCZgCbAAABLAAFFAYIJgASAGkeAA==.',['小浪']='小浪浪:BAAALAAECgYIBgAAAA==.',['小猪']='小猪:BAABLAAFFH8mAAISAAYIaR6sAQC1AQASAAYIaR6sAQC1AQAAAA==.',['小钻']='小钻风:BAABLAAFFH8SAAIMAAYIkAImQgDcAAAMAAYIkAImQgDcAAAAAA==.',['就在']='就在今天:BAAALAAECgYIBgAAAA==.',['山楂']='山楂味的阳光:BAAALAAFFAEIAQAAAA==.',['山猫']='山猫:BAAALAAFFAIIAgAAAA==.',['岸芷']='岸芷汀兰:BAAALAADCgUIBQAAAA==.',['峨眉']='峨眉峰:BAAALAAECggIDwAAAA==.',['当空']='当空皓月:BAAALAAECgQIBAAAAA==.',['德之']='德之王:BAAALAAECgMIAwAAAA==.',['德甜']='德甜毒厚:BAAALAAECgYICgAAAA==.',['怪我']='怪我不够渣男:BAAALAAFFAMIAwAAAA==.',['怪物']='怪物千层饼:BAABLAAFFH8FAAITAAUIggm0NwDEAAATAAUIggm0NwDEAAAAAA==.',['悉尼']='悉尼劳斯莱斯:BAAALAAECggICAAAAA==.',['憔悴']='憔悴的大伯:BAAALAAFFAIIBAAAAA==.',['懒之']='懒之鱼鱼:BAACLAAFFH8ZAAIQAAUIZRXZDAA/AQAQAAUIZRXZDAA/AQAsAAQKfyUAAhAACAiwHf0UAHICABAACAiwHf0UAHICAAEsAAUUCAgCABQAAAAA.',['我是']='我是小妖怪:BAAALAADCggIDAAAAA==.',['把我']='把我搁八队:BAABLAAFFH8LAAIMAAMIhhepSACZAAAMAAMIhhepSACZAAAAAA==.',['握咪']='握咪脱服:BAAALAAECgYICwAAAA==.',['攻击']='攻击之爪:BAABLAAFFH8cAAIVAAYIEByzAwCHAQAVAAYIEByzAwCHAQABLAAFFAYIJgASAGkeAA==.',['敖闰']='敖闰:BAAALAADCggIEAAAAA==.',['文小']='文小小:BAAALAAFFAIIAgAAAA==.',['断丿']='断丿情丶:BAABLAAFFH8LAAIKAAYI1Q8SJQBlAQAKAAYI1Q8SJQBlAQABLAAFFAYIGQADAJcRAA==.',['斷丿']='斷丿情:BAABLAAFFH8RAAINAAYI7BcsKwCIAQANAAYI7BcsKwCIAQABLAAFFAYIGQADAJcRAA==.',['星霜']='星霜:BAACLAAFFH8OAAIEAAQIFxonEABEAQAEAAQIFxonEABEAQAsAAQKfygAAgQACAgoJQASAH4CAAQACAgoJQASAH4CAAAA.',['暗夜']='暗夜之剑:BAAALAADCgYIBgAAAA==.',['暗河']='暗河大家长:BAAALAADCgcIBgAAAA==.',['暗湧']='暗湧:BAAALAADCgUIBQAAAA==.',['暗黑']='暗黑圣堂:BAAALAAECggIBgAAAA==.',['最爱']='最爱耙耙柑:BAAALAADCgMIAwAAAA==.',['月夜']='月夜轻舞:BAACLAAFFH8cAAISAAUIyRqlAwAlAQASAAUIyRqlAwAlAQAsAAQKfzgAAxIACAh0H64FALwCABIACAh0H64FALwCABYAAwiaCe8dAIAAAAAA.',['月神']='月神之殇:BAAALAAECgcIBwAAAA==.月神之翼:BAAALAAECgEIAQAAAA==.月神之风:BAAALAAECgEIAQAAAA==.月神之黛:BAAALAAECgYIBgAAAA==.',['有丶']='有丶毒:BAABLAAFFH8HAAITAAMIyAqhTQCBAAATAAMIyAqhTQCBAAAAAA==.',['朕要']='朕要睡中间:BAABLAAFFH8OAAQGAAYIRwauPQBuAAAGAAIIehGuPQBuAAAHAAYI2wGZIwBfAAAXAAIIOQI/CAA2AAAAAA==.',['木子']='木子彤:BAAALAAFFAMIAwAAAA==.',['来自']='来自地狱的我:BAAALAAECgYIDQAAAA==.',['杰克']='杰克马:BAAALAAECgcICgAAAA==.',['极乐']='极乐老人:BAAALAAECgQIBAAAAA==.',['果果']='果果奶优:BAABLAAFFH8OAAINAAUINw0OUgAHAQANAAUINw0OUgAHAQAAAA==.',['树总']='树总:BAABLAAECn8UAAIBAAgIDxK1KQC4AQABAAgIDxK1KQC4AQAAAA==.',['格罗']='格罗地狱惨叫:BAAALAAECgUICAAAAA==.',['樹总']='樹总:BAAALAAECgQIAwAAAA==.',['此乃']='此乃神牧:BAAALAAECgEIAQAAAA==.',['死亡']='死亡如风:BAABLAAECn8cAAIKAAgIEB7dDwBkAgAKAAgIEB7dDwBkAgAAAA==.',['死要']='死要命不要钱:BAAALAAECgMIBQAAAA==.',['毕加']='毕加索:BAAALAAECgYIEQAAAA==.',['水煮']='水煮小鸟:BAABLAAFFH8IAAIYAAgIRAF2RACRAAAYAAgIRAF2RACRAAAAAA==.',['沐圈']='沐圈圈:BAAALAADCgEIBQAAAA==.',['沫上']='沫上月泱丶:BAAALAAECgEIAQAAAA==.',['法号']='法号一介武夫:BAAALAAECgYIBgAAAA==.',['法掰']='法掰掰:BAABLAAECn8TAAMZAAgIMSOkAwCNAgAYAAgITSE3JwCwAgAZAAgIfSGkAwCNAgABLAAFFAYIDQAaAJoVAA==.',['法玄']='法玄:BAAALAAECgYIEAAAAA==.',['洛姗']='洛姗:BAAALAADCgYIBgAAAA==.',['流年']='流年堇色丶:BAAALAAECgIIAgAAAA==.',['浪里']='浪里个波:BAAALAAECgQIAwAAAA==.',['淘气']='淘气潇:BAAALAAFFAIIAgAAAA==.',['淡蓝']='淡蓝色的心情:BAAALAADCgYICgAAAA==.',['深渊']='深渊凝视:BAAALAAECgEIAQAAAA==.',['渡丶']='渡丶:BAAALAADCggIDgAAAA==.',['渺小']='渺小而强大:BAAALAAECgYIBgAAAA==.',['湛蓝']='湛蓝天使:BAABLAAFFH8HAAINAAcIZAUONwBiAQANAAcIZAUONwBiAQAAAA==.',['溙兰']='溙兰德丶羽枫:BAABLAAFFH8bAAIKAAgIwxqxBgBtAgAKAAgIwxqxBgBtAgAAAA==.',['满满']='满满飒:BAAALAAECgMIBAAAAA==.',['火舞']='火舞凌雪:BAAALAAECgIIBAAAAA==.',['灬猫']='灬猫猫甜心灬:BAAALAAECggICAAAAA==.',['点点']='点点的:BAAALAADCgQIBAAAAA==.',['热烈']='热烈的吻:BAAALAADCgEIAQAAAA==.',['無作']='無作:BAAALAAECgYIBwAAAA==.',['熊猫']='熊猫胖墩圆:BAAALAAECgMIAwAAAA==.',['熙年']='熙年丶:BAACLAAFFH8MAAMCAAIIah22AwCiAAABAAIIah1FJwCqAAACAAIIiRe2AwCiAAAsAAQKfyEAAwEACAipI8QZAO4CAAEACAgVI8QZAO4CAAIABAh/IRAXAHYBAAAA.',['爱妃']='爱妃睡左边:BAAALAAFFAIIBAAAAA==.',['狮子']='狮子座小比利:BAAALAADCggIDgAAAA==.狮子座小田田:BAAALAADCggICAABLAADCggIDgAUAAAAAA==.',['猎影']='猎影风行:BAAALAAECgEIAQAAAA==.',['猛哥']='猛哥哥:BAAALAADCggICAAAAA==.',['猫饼']='猫饼干:BAAALAAECgMIAwAAAA==.',['玄战']='玄战:BAAALAAECgYIBgAAAA==.',['玖拾']='玖拾:BAACLAAFFH8rAAMNAAYI1RyyJQCbAQANAAYI1RyyJQCbAQAbAAIIJA5nKQB1AAAsAAQKfywAAw0ACAhsIrAvAJoCAA0ACAhsIrAvAJoCABsAAgjYHHCTAJ0AAAAA.',['玛德']='玛德儿航特:BAAALAAECgYIBgAAAA==.',['田缘']='田缘里的蝈蝈:BAAALAAECgIIAgAAAA==.',['电动']='电动皮卡丘:BAABLAAFFH8GAAIYAAYIiAAgbAAaAAAYAAYIiAAgbAAaAAAAAA==.',['白色']='白色大锤:BAAALAAECgYIDQABLAAECgYIFgABABIdAA==.白色棉花糖:BAAALAAECgYIBQAAAA==.',['神圣']='神圣一锤:BAABLAAECn8jAAIEAAcIuxj/NwC2AQAEAAcIuxj/NwC2AQAAAA==.',['精神']='精神小妹:BAAALAAFFAQIBAAAAA==.',['紫妍']='紫妍:BAABLAAECn8bAAIBAAYIUgtVXgD6AAABAAYIUgtVXgD6AAAAAA==.',['紫焱']='紫焱:BAAALAAFFAIIBAAAAA==.',['绑上']='绑上帝:BAAALAADCgMIAwAAAA==.',['美丽']='美丽的小燕子:BAABLAAFFH8HAAINAAIINgjhqwA5AAANAAIINgjhqwA5AAAAAA==.',['老树']='老树盘根:BAAALAAECgcIBwAAAA==.',['联盟']='联盟保卫者:BAAALAAECgQIBgAAAA==.',['聖光']='聖光冇扼你嘎:BAAALAADCgUIBQAAAA==.',['肥仔']='肥仔好恶:BAACLAAFFH8aAAMcAAUIcQtuDAAHAQAcAAUIcQtuDAAHAQAdAAEIAAGlHAAhAAAsAAQKfzAAAhwACAhHGkkYAEoCABwACAhHGkkYAEoCAAAA.肥仔有料:BAAALAADCggICAAAAA==.',['肥皂']='肥皂:BAAALAAFFAMIAwAAAA==.',['肯德']='肯德基骑士:BAAALAAECgcIEwAAAA==.',['艾丽']='艾丽丝:BAAALAAFFAIIAgAAAA==.',['花见']='花见花开:BAAALAAECgMIAwAAAA==.',['苏格']='苏格兰高鸟蛋:BAACLAAFFH83AAMaAAYI3iR9AwCAAgAaAAYI3iR9AwCAAgAEAAMISQ48RACHAAAsAAQKfzEAAhoABwjIIMsHAH4CABoABwjIIMsHAH4CAAAA.',['莉雅']='莉雅拉:BAACLAAFFH8GAAIDAAMIIwnHiwBAAAADAAMIIwnHiwBAAAAsAAQKfy0AAgMACAgSHjIkAOcBAAMACAgSHjIkAOcBAAAA.',['菲施']='菲施莉亚:BAAALAAFFAIIAwAAAA==.',['萨之']='萨之神:BAAALAAECgYICQAAAA==.',['落叶']='落叶归乡:BAAALAAECgIIAgAAAA==.',['虎烈']='虎烈:BAACLAAFFH8eAAICAAQI/BMQAgDtAAACAAQI/BMQAgDtAAAsAAQKfzgAAgIACAioIYYDAP8CAAIACAioIYYDAP8CAAAA.',['西山']='西山秋鱼:BAAALAAECgUIBQAAAA==.',['西瓜']='西瓜草莓爸爸:BAAALAAECgQIBAAAAA==.',['西红']='西红柿炒番茄:BAAALAAFFAgIBAAAAA==.',['諾森']='諾森德的雪:BAAALAADCgIIAgAAAA==.',['豆沙']='豆沙酪:BAAALAAECgYIBgAAAA==.',['豆烟']='豆烟血蛤:BAABLAAECn8UAAMIAAYILBuKIADOAQAIAAYILBuKIADOAQALAAMI1xNRUQBtAAAAAA==.',['贫道']='贫道通幽:BAAALAADCgYIBgAAAA==.',['赛博']='赛博胖客:BAAALAAECggIEQAAAA==.',['超级']='超级女孩:BAABLAAFFH8GAAIIAAIITw6+RgBhAAAIAAIITw6+RgBhAAAAAA==.超级骑士:BAABLAAFFH8GAAIDAAIIJwX8nAA3AAADAAIIJwX8nAA3AAAAAA==.',['那个']='那个飒满:BAAALAAECgYICgABLAAFFAYIBgAeAL4IAA==.',['邮电']='邮电部诗人:BAABLAAFFH8IAAIKAAII0BzcLQCuAAAKAAII0BzcLQCuAAAAAA==.',['都是']='都是胖子的锅:BAAALAAECgYIBgAAAA==.',['酷怕']='酷怕:BAAALAAECgYIBgAAAA==.',['閗將']='閗將:BAAALAADCgQICAAAAA==.',['阿丝']='阿丝娜:BAAALAAECgIIAgAAAA==.',['阿斌']='阿斌:BAABLAAECn8aAAIEAAcIGhQDiQDcAQAEAAcIGhQDiQDcAQAAAA==.',['陳老']='陳老师:BAAALAAECgQIBAAAAA==.',['雨猫']='雨猫:BAAALAADCgEIAQAAAA==.',['静水']='静水散人:BAAALAADCgcIBwAAAA==.',['风的']='风的怒语:BAAALAAECgYIBgAAAA==.',['风起']='风起云裳:BAABLAAFFH8cAAIPAAYI7huwBACeAQAPAAYI7huwBACeAQABLAAFFAYIJgASAGkeAA==.',['风顺']='风顺:BAAALAAECgYICQAAAA==.',['骑士']='骑士深渊:BAAALAAECgYICQAAAA==.',['骑掰']='骑掰掰:BAAALAADCgQIBAABLAAFFAYIDQAaAJoVAA==.',['魂之']='魂之挽歌:BAACLAAFFH8JAAIDAAMIfQ7WZQB/AAADAAMIfQ7WZQB/AAAsAAQKfxcAAgMACAiUGrccAAwCAAMACAiUGrccAAwCAAEsAAUUCAgbAB8A8hwA.',['魅影']='魅影裳:BAAALAADCgEIAQAAAA==.',['鱼崽']='鱼崽子:BAABLAAFFH8KAAIEAAgIfQXLOAC6AAAEAAgIfQXLOAC6AAAAAA==.',['麦田']='麦田里的蝈蝈:BAAALAADCgQIBAAAAA==.',['麻球']='麻球:BAAALAADCgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end