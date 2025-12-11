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
 local lookup = {'DemonHunter-Vengeance','Hunter-BeastMastery','DeathKnight-Frost','Warlock-Destruction','Druid-Restoration','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Paladin-Retribution','Hunter-Marksmanship','Mage-Frost','Warlock-Demonology','Paladin-Protection','Mage-Arcane','Priest-Shadow',}; local provider = {region='CN',realm='拉贾克斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akjiaoj:BAAALAAECgQIBQAAAA==.',At='Athenachris:BAAALAAECgQIBAAAAA==.',Co='Cosima:BAABLAAFFH8GAAIBAAIIfgoYGAAlAAABAAIIfgoYGAAlAAAAAA==.',Dk='Dkdk:BAAALAADCgQIBAAAAA==.',Ne='Nesingwary:BAACLAAFFH8FAAICAAMICgdCeABsAAACAAMICgdCeABsAAAsAAQKfxoAAgIABwiBGMp3AO0BAAIABwiBGMp3AO0BAAAA.',['Oó']='Oóoó:BAABLAAFFH8KAAIDAAIINCUOagBsAAADAAIINCUOagBsAAAAAA==.',Sa='Satori:BAAALAADCgcIBwAAAA==.',Sk='Skycity:BAAALAADCggICAAAAA==.',Sy='Sylvanassulu:BAAALAAFFAIIBAABLAAFFAgITgAEACMjAA==.',Wa='Wallacesulu:BAABLAAFFH8GAAIFAAYIcgBMYQAeAAAFAAYIcgBMYQAeAAAAAA==.',['不厌']='不厌:BAAALAAFFAIIAgAAAA==.',['丛林']='丛林的夜曲:BAACLAAFFH8YAAICAAUIdhnMPgBKAQACAAUIdhnMPgBKAQAsAAQKfxYAAgIABwjrHy0yAPUBAAIABwjrHy0yAPUBAAAA.',['乀岁']='乀岁岁知春丶:BAABLAAECn8XAAICAAYIHhH9kAAuAQACAAYIHhH9kAAuAQAAAA==.',['二傻']='二傻之:BAAALAADCgUIBQAAAA==.',['二蛤']='二蛤:BAAALAAFFAIIAgAAAA==.',['云中']='云中君:BAACLAAFFH8bAAIGAAUIYxoJHgBQAQAGAAUIYxoJHgBQAQAsAAQKfxYAAwYACAiOG74aANUBAAYACAiOG74aANUBAAcAAwg3GakiAKoAAAAA.',['井你']='井你铐铐拷:BAAALAAECgYIBgAAAA==.',['亚历']='亚历山大:BAAALAADCgEIAQAAAA==.',['会跳']='会跳舞鱼:BAAALAADCgIIAgAAAA==.',['兄弟']='兄弟你听我说:BAAALAAECgQIBAAAAA==.',['冰冰']='冰冰爱蛋黄:BAABLAAFFH8QAAIIAAUIEwvDMQDkAAAIAAUIEwvDMQDkAAAAAA==.冰冰的蛋黄:BAAALAADCgIIAgAAAA==.冰冰的骑士:BAABLAAFFH8fAAIDAAYI6hhxJACjAQADAAYI6hhxJACjAQAAAA==.',['冰封']='冰封的风:BAABLAAFFH8XAAIDAAYIXhToJgCaAQADAAYIXhToJgCaAQAAAA==.',['几十']='几十个萨满:BAAALAAECgYIBgAAAA==.',['凨行']='凨行独舞:BAAALAAECgYIDAAAAA==.凨行獨儛:BAAALAAFFAEIAQAAAA==.凨行獨躌:BAABLAAECn8VAAIDAAgI8Ap+VQBHAQADAAgI8Ap+VQBHAQAAAA==.',['十八']='十八岁萌萌:BAAALAAECgIIAgAAAA==.',['十六']='十六岁萌萌:BAAALAADCgMIAwAAAA==.',['千变']='千变万化:BAAALAADCgcIBwAAAA==.',['南明']='南明:BAABLAAFFH8GAAICAAIIhxoUPgCpAAACAAIIhxoUPgCpAAAAAA==.',['印象']='印象:BAABLAAFFH8GAAIJAAMI9xaeOgCiAAAJAAMI9xaeOgCiAAAAAA==.印象雲烟:BAAALAAECgEIAQAAAA==.',['变变']='变变乐:BAAALAAECgYIBwAAAA==.',['叶流']='叶流云:BAAALAAECgYIBgAAAA==.',['吴屁']='吴屁屁:BAAALAADCgIIAgAAAA==.',['吴米']='吴米粒:BAAALAAECgYICAAAAA==.',['吴臭']='吴臭臭:BAAALAAECgUIBgAAAA==.',['圣光']='圣光白:BAAALAAECgIIAgAAAA==.',['夜深']='夜深嗷嗷叫:BAAALAAECgQIBAAAAA==.',['夜魅']='夜魅:BAABLAAFFH8fAAIEAAYIyhK/KgBwAQAEAAYIyhK/KgBwAQAAAA==.',['奇迹']='奇迹行者:BAAALAAFFAIIBAABLAAFFAcIKQAIAFUlAA==.',['妞妞']='妞妞丨法爷:BAAALAAECgQIBAAAAA==.',['审之']='审之判:BAAALAAECgYIBgAAAA==.',['小夏']='小夏的:BAAALAAECgYIBgAAAA==.',['小巴']='小巴特儿:BAAALAADCgUIBQAAAA==.',['小熊']='小熊猫:BAAALAAFFAIIBAAAAA==.小熊软糖:BAAALAAECgYIBgAAAA==.',['小鸽']='小鸽:BAAALAAECgYIBgAAAA==.',['影风']='影风灬殤:BAAALAAECgEIAQAAAA==.',['御风']='御风追梦:BAAALAADCgMIAwAAAA==.',['心绪']='心绪:BAABLAAFFH8KAAMCAAMIoRgANgC4AAACAAMIoRgANgC4AAAKAAIIXArPMABcAAAAAA==.',['惹噜']='惹噜啾咪厚:BAACLAAFFH8pAAMIAAcIVSXFAgC2AgAIAAcIVSXFAgC2AgAGAAQI2B3oKAD9AAAsAAQKfzIAAwYACAjmIRoSAAIDAAYACAjmIRoSAAIDAAgACAh1IyARAOMCAAAA.',['我僧']='我僧慈悲:BAAALAADCgUIBQAAAA==.',['我爱']='我爱暖暖:BAAALAAECgYIBgAAAA==.',['扑棱']='扑棱扑棱丶:BAAALAAECgYIBgAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8kAAIIAAYI2BvaEQDVAQAIAAYI2BvaEQDVAQAAAA==.',['护肝']='护肝片:BAAALAADCgQIBAAAAA==.',['插插']='插插乐:BAAALAAECgUIBQAAAA==.',['撒克']='撒克鲁斯:BAAALAAECggICAAAAA==.',['斩杀']='斩杀:BAABLAAFFH8IAAIDAAUImRDbPgA/AQADAAUImRDbPgA/AQAAAA==.',['无敌']='无敌大结实:BAAALAAECgYIBgAAAA==.无敌小希:BAAALAAECgEIAQAAAA==.',['星云']='星云:BAABLAAFFH8GAAIJAAIImgYUWwCFAAAJAAIImgYUWwCFAAAAAA==.',['星光']='星光永烁:BAAALAAECgYIBgAAAA==.',['晓雅']='晓雅:BAAALAAFFAIIBAAAAA==.',['暴力']='暴力拆除:BAAALAAECgEIAQAAAA==.',['月夜']='月夜丶飘雪:BAAALAAECgYICAAAAA==.',['月神']='月神玥:BAABLAAFFH8HAAILAAIIhxF5EwCHAAALAAIIhxF5EwCHAAAAAA==.月神琳:BAAALAAECgYIBwAAAA==.',['李阿']='李阿不:BAAALAAECgYICAAAAA==.',['来了']='来了老弟:BAAALAADCggICAAAAA==.',['此生']='此生不换:BAAALAAFFAIIAgAAAA==.',['毁灭']='毁灭术:BAAALAAECggIDAAAAA==.',['汐溪']='汐溪:BAABLAAECn8UAAICAAYIoBLYqAANAQACAAYIoBLYqAANAQAAAA==.',['泡芙']='泡芙:BAABLAAFFH8IAAMMAAIIDA/LGgCMAAAMAAIIDA/LGgCMAAAEAAEIJQKjYwAxAAAAAA==.',['流年']='流年:BAABLAAFFH8KAAINAAIIjRV7EwCGAAANAAIIjRV7EwCGAAAAAA==.',['浩子']='浩子超无敌:BAABLAAFFH8IAAIJAAIIoxePMACrAAAJAAIIoxePMACrAAAAAA==.',['浮光']='浮光:BAAALAAECgcICwAAAA==.',['淑薇']='淑薇:BAAALAAECgYIDAAAAA==.',['清晨']='清晨的寒冬:BAABLAAFFH8UAAIOAAUI6gsVOwDtAAAOAAUI6gsVOwDtAAAAAA==.',['清风']='清风揽月:BAAALAADCgYIBgAAAA==.',['漢升']='漢升后羿:BAAALAAECgYIEgAAAA==.',['牛奶']='牛奶蛋糕:BAAALAAECgQIAwAAAA==.',['牧牧']='牧牧乐:BAAALAAECgIIAgAAAA==.',['睏龙']='睏龙:BAAALAAECgMIAwAAAA==.',['砍砍']='砍砍乐:BAAALAADCgUICAAAAA==.',['窗外']='窗外的怪叔:BAAALAADCgYIBgAAAA==.',['紅雲']='紅雲軟珍:BAAALAADCggIEAAAAA==.',['紫威']='紫威:BAAALAADCgcICQAAAA==.',['红塔']='红塔山:BAAALAAECgYIBgAAAA==.',['红袖']='红袖招:BAAALAAFFAIIAwAAAA==.',['聖骑']='聖骑士:BAACLAAFFH8RAAMEAAUIQxM5OwAbAQAEAAQI5BA5OwAbAQAMAAEIwRzZIwBWAAAsAAQKfycAAwwACAj5IggMAKwCAAwABwhKIggMAKwCAAQABwifHQwzAG8CAAAA.',['艾丽']='艾丽丝丶杨:BAACLAAFFH82AAIPAAYIMiIFBgACAgAPAAYIMiIFBgACAgAsAAQKfyUAAg8ACAi5IrMFAJkCAA8ACAi5IrMFAJkCAAAA.',['艾西']='艾西莉亚:BAAALAADCggICAAAAA==.',['花之']='花之优雅:BAABLAAECn8bAAMGAAYIEyHzoQDRAAAGAAMIkhzzoQDRAAAIAAYIig8McgCuAAAAAA==.',['茶叶']='茶叶丨:BAABLAAFFH8HAAIIAAII7w2KYwBXAAAIAAII7w2KYwBXAAAAAA==.',['荒天']='荒天帝:BAAALAAECgEIAQAAAA==.',['蝌蚪']='蝌蚪绣蛤蟆:BAAALAAECgMIAwAAAA==.',['血手']='血手魔心:BAAALAAECgIIAgAAAA==.',['血色']='血色嫚舞:BAAALAAECgYIDgAAAA==.',['费叨']='费叨叨:BAAALAAECgYICAAAAA==.',['踢踢']='踢踢乐:BAAALAAECgUIBQAAAA==.',['身心']='身心皆亡:BAAALAADCgMIAwAAAA==.',['轩辕']='轩辕奇奇:BAAALAAECgYIBwAAAA==.轩辕小猎:BAAALAAECgQIBAAAAA==.',['透心']='透心凉:BAAALAAECgYIBgAAAA==.',['郎才']='郎才女貌:BAAALAAECgYIBwAAAA==.',['野兽']='野兽光环:BAABLAAFFH8ZAAIFAAYI4xPTEwCbAQAFAAYI4xPTEwCbAQAAAA==.',['闪电']='闪电博尔特:BAAALAADCgcIBwAAAA==.',['阿克']='阿克都都:BAAALAAECgEIAQAAAA==.',['阿兰']='阿兰娜之仁慈:BAAALAAFFAIIAwAAAA==.阿兰娜之狡黠:BAACLAAFFH8rAAIKAAYI6w8uBwBYAQAKAAYI6w8uBwBYAQAsAAQKfxsAAgoACAglGDMKALUBAAoACAglGDMKALUBAAAA.阿兰娜之精髓:BAAALAAECgQIBAAAAA==.',['陆号']='陆号术:BAAALAAFFAMIAwAAAA==.',['随风']='随风凌云:BAAALAAECgQIBAAAAA==.',['風行']='風行獨儛:BAAALAADCgcIBwAAAA==.',['风流']='风流小青年:BAABLAAFFH8SAAIOAAYIVBI7IgCNAQAOAAYIVBI7IgCNAQABLAAFFAYINgAPADIiAA==.',['飞非']='飞非非:BAAALAAECgQIBwAAAA==.',['馍馍']='馍馍夹花:BAAALAADCgIIAgAAAA==.',['高级']='高级动物:BAAALAAECgUIBgAAAA==.',['魔裔']='魔裔一电锯男:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end