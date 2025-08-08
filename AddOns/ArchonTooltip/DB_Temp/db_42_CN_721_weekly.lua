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
 local lookup = {'Mage-Frost','Mage-Arcane','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','Paladin-Retribution','Priest-Discipline','Rogue-Assassination','Druid-Balance','DeathKnight-Blood','DeathKnight-Unholy','Warlock-Destruction','Monk-Mistweaver','Monk-Windwalker','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Fury','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','Mage-Fire','Priest-Shadow','Priest-Holy','Warlock-Demonology','Warlock-Affliction','Paladin-Holy','Monk-Brewmaster','Warrior-Arms','Warrior-Protection','DeathKnight-Frost','Unknown-Unknown','Druid-Restoration','Druid-Guardian',}; local provider = {region='CN',realm='死亡熔炉',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Anongrey:BAAAKgADCggICgAAAA==.',Bi='Bierhoff:BAAAKgAECgQIBAAAAA==.',Ch='Charlemagne:BAAAKgAFFAgIBAAAAA==.',Co='Cocoanuts:BAABKgAFFH8RAAMBAAMILyLoDAAAAQABAAMIeh7oDAAAAQACAAMIoxR9LACyAAAAAA==.',Es='Escanor:BAAAKgAFFAQIBAAAAA==.',Fa='Falcon:BAAAKgAFFAIIAgAAAA==.',Fi='Fiona:BAAAKgAECgQICAAAAA==.',Fl='Flyingdevil:BAAAKgADCgUIBQAAAA==.',Fo='Fordmengdiou:BAAAKgADCgEIAQAAAA==.',Iv='Ivever:BAABKgAECn8iAAIBAAcIwR4FFgAKAgABAAcIwR4FFgAKAgAAAA==.',Lm='Lmaylr:BAABKgAFFH8TAAMDAAYIgSNTBwALAgADAAYIgSNTBwALAgAEAAQInBhFLgCzAAAAAA==.',Mo='Mortis:BAAAKgADCgUIBQAAAA==.',Na='Naremdul:BAABKgAFFH8JAAMFAAYIcxNXBgD/AAAFAAUIxA5XBgD/AAAGAAQIKBW3FwD8AAAAAA==.',Ro='Rockwang:BAAAKgAFFAYIBAABKgAFFAgIGAAHAOgeAA==.',Sa='Saltria:BAAAKgAECgIIAgAAAA==.',Sc='Schizophrene:BAAAKgAECgYICgAAAA==.',So='Soyorin:BAAAKgADCgQIBAAAAA==.',Te='Tentaclegirl:BAABKgAFFH8WAAIEAAUIehX2IQDqAAAEAAUIehX2IQDqAAAAAA==.',To='Tom:BAABKgAFFH8KAAIIAAYIHSPUCADRAQAIAAYIHSPUCADRAQAAAA==.',Tr='Trtr:BAAAKgADCgEIAQAAAA==.',Wi='Withoutme:BAAAKgADCgUIBQAAAA==.',Zh='Zhaybabtu:BAAAKgAECgEIAQAAAA==.',Zs='Zsdevil:BAAAKgAECggICQAAAA==.',['一心']='一心:BAABKgAFFH8GAAIJAAYIrQ2nGQBMAQAJAAYIrQ2nGQBMAQAAAA==.',['一首']='一首战歌:BAAAKgAECgEIAQAAAA==.一首离歌:BAAAKgADCggICAAAAA==.',['七名']='七名:BAAAKgAFFAQIAwAAAA==.',['七月']='七月十六号:BAABKgAFFH8FAAIKAAUI/AVLDAC2AAAKAAUI/AVLDAC2AAAAAA==.',['三九']='三九的術士:BAAAKgAECgIIAgAAAA==.',['三分']='三分钟饿肚:BAAAKgAECgMIBAAAAA==.',['上青']='上青天揽明月:BAAAKgAFFAQIBAAAAA==.',['不二']='不二心:BAAAKgADCgcIBwAAAA==.',['不会']='不会放电:BAAAKgAFFAYIBAAAAA==.',['不死']='不死千姿:BAAAKgADCggICgAAAA==.',['不舍']='不舍:BAAAKgAECgYICwAAAA==.',['不萌']='不萌你打我:BAAAKgADCgEIAQAAAA==.',['东方']='东方维也纳:BAAAKgADCggICAAAAA==.',['东珍']='东珍格格:BAAAKgADCgYIBgAAAA==.',['两胯']='两胯插刀:BAAAKgADCgQIBAAAAA==.',['丨一']='丨一箭飙血丨:BAAAKgADCgUIBQAAAA==.',['丨小']='丨小黄花丨:BAAAKgAFFAIIAgAAAA==.',['丶夏']='丶夏末:BAABKgAFFH8OAAMKAAQIFRRxHQC3AAAKAAQI/BNxHQC3AAALAAMIgAjFFwCpAAAAAA==.丶夏茉:BAAAKgAECgEIAQAAAA==.',['丶小']='丶小刘:BAABKgAFFH8KAAIMAAMI4BAPGAC/AAAMAAMI4BAPGAC/AAAAAA==.丶小狠儿:BAAAKgAFFAMIAwAAAA==.',['丶破']='丶破晓:BAABKgAFFH8MAAMGAAMInBLPJQDQAAAGAAMInBLPJQDQAAAFAAMIEQR3EQBsAAAAAA==.',['丶蛋']='丶蛋挞:BAAAKgADCgcIBwAAAA==.',['丶风']='丶风淡:BAABKgAECn8ZAAMEAAgIUiP6BgDNAgAEAAgIUiP6BgDNAgADAAUIRARE1ACDAAAAAA==.',['丿大']='丿大威天龍:BAABKgAFFH8WAAMNAAQI7BlSHQC1AAANAAQI7BlSHQC1AAAOAAMIzwY8GgCYAAAAAA==.',['二大']='二大爷是酋长:BAAAKgADCggICAAAAA==.',['二尐']='二尐姐:BAAAKgADCggICAAAAA==.',['亚托']='亚托克斯:BAAAKgAECggIEwAAAA==.',['伊戾']='伊戾丹邪风:BAABKgAECn8XAAMPAAgI3gqORwCiAAAQAAYIxQUfgAC9AAAPAAYI+wuORwCiAAAAAA==.',['你石']='你石哥:BAAAKgAFFAEIAQAAAA==.',['佳木']='佳木斯大拐:BAAAKgAFFAYIAwAAAA==.',['依然']='依然下雪:BAAAKgADCgEIAQAAAA==.依然丶雪:BAAAKgADCggICAAAAA==.',['侠之']='侠之幻影:BAABKgAFFH8SAAMEAAgIshkTCwClAQADAAgI6hOIBgAlAgAEAAYIbxwTCwClAQAAAA==.',['信仰']='信仰圣光吧丶:BAABKgAFFH8TAAIQAAMI3iAjHwAKAQAQAAMI3iAjHwAKAQAAAA==.',['修罗']='修罗:BAAAKgAECgQIBgAAAA==.',['养猪']='养猪丨丨大户:BAABKgAFFH8GAAIRAAQIVRpoDwD9AAARAAQIVRpoDwD9AAAAAA==.',['内蒙']='内蒙小纪:BAAAKgADCggICAAAAA==.',['冥狱']='冥狱女王:BAAAKgAECgEIAQAAAA==.',['冰焰']='冰焰幻成魔:BAAAKgAECgYIBgAAAA==.',['凛冬']='凛冬之骑:BAABKgAFFH8IAAMLAAQIABjUMgDJAAALAAQI3xbUMgDJAAAKAAQIHg5tJACHAAAAAA==.',['凤山']='凤山渐巽为风:BAAAKgAECgYICwAAAA==.',['划过']='划过天的烈焰:BAAAKgAECgEIAQAAAA==.',['刚铎']='刚铎的菊花怪:BAAAKgAECgIIAgAAAA==.',['创世']='创世:BAAAKgAFFAgIBAAAAA==.',['十三']='十三幺:BAAAKgAFFAQIBAAAAA==.',['单曲']='单曲:BAAAKgAFFAgIAgAAAA==.单曲灬循环:BAAAKgAFFAQIBAAAAA==.',['卧龙']='卧龙:BAAAKgAECgIIAgAAAA==.',['原罪']='原罪之魔:BAAAKgADCgUIBQAAAA==.',['去茶']='去茶三分冰:BAAAKgAECgcIBwAAAA==.',['又酷']='又酷又幽默:BAAAKgADCggICAAAAA==.',['双鱼']='双鱼座小牛:BAAAKgAECggIAwAAAA==.',['反抗']='反抗的牛马:BAAAKgADCggICAAAAA==.',['叛逆']='叛逆之吻:BAAAKgADCggICQAAAA==.',['古之']='古之恶来丶:BAAAKgADCgIIAgAAAA==.',['古明']='古明地作:BAAAKgAECgUIBgAAAA==.',['叫峰']='叫峰哥:BAABKgAECn8dAAISAAgIKBxLGQA8AgASAAgIKBxLGQA8AgAAAA==.',['可以']='可以更矮:BAAAKgADCgEIAQAAAA==.',['可爱']='可爱的蓝精灵:BAABKgAFFH8TAAITAAMIfRkLEQDeAAATAAMIfRkLEQDeAAAAAA==.',['右将']='右将军:BAAAKgAECgEIAgAAAA==.',['叶落']='叶落无声:BAAAKgAECgYIBgAAAA==.',['吱炙']='吱炙脂:BAABKgAFFH8KAAINAAYIFRe/EAAmAQANAAYIFRe/EAAmAQABKgAFFAgICAAGAC8jAA==.',['吻你']='吻你半小时:BAAAKgADCgIIAgAAAA==.',['周杰']='周杰伦:BAAAKgAECgQIBAAAAA==.',['咸鱼']='咸鱼光环:BAAAKgAECgIIAgAAAA==.',['哈哈']='哈哈也美丽:BAAAKgAECggIDwAAAA==.',['哈士']='哈士骑:BAABKgAFFH8GAAIGAAYIQR/3FgCkAQAGAAYIQR/3FgCkAQAAAA==.',['哪个']='哪个名字能用:BAABKgAECn8aAAIDAAgILBblFgDLAQADAAgILBblFgDLAQAAAA==.',['唉末']='唉末替:BAAAKgAECgUIBwAAAA==.',['啊啊']='啊啊噢哦阿:BAABKgAECn8gAAMUAAgIzxzFGAAEAgAUAAgIzxzFGAAEAgASAAQIog3uiQCtAAAAAA==.',['啥也']='啥也不会:BAAAKgADCggIDQAAAA==.',['喵喵']='喵喵法:BAACKgAFFH8UAAICAAQICAyqKwC1AAACAAQICAyqKwC1AAAqAAQKfxkAAwIACAgtFWQxAIsBAAIABwhRF2QxAIsBABUACAhVBU5rAMYAAAAA.',['土豆']='土豆豆:BAABKgAECn8kAAIGAAgIJBkaHwDEAQAGAAgIJBkaHwDEAQAAAA==.',['圣光']='圣光好好:BAABKgAFFH8IAAIGAAQIRg00KgC+AAAGAAQIRg00KgC+AAAAAA==.圣光灬骑士:BAABKgAFFH8IAAIGAAgIsQctDwCwAQAGAAgIsQctDwCwAQAAAA==.',['地狱']='地狱烬苦:BAAAKgAECgcICwAAAA==.',['堕落']='堕落灬东方:BAAAKgAECgYIBgAAAA==.堕落的小爱:BAABKgAECn8cAAMWAAgI4Rn+GQC7AQAWAAcIaBr+GQC7AQAXAAIIvxCcgABiAAAAAA==.',['增强']='增强理理:BAAAKgAECgEIAQABKgAFFAQICAALAAAYAA==.',['夜之']='夜之幽影:BAAAKgADCggICAAAAA==.',['大仙']='大仙儿:BAAAKgAECgMIAwAAAA==.',['大威']='大威天龍:BAAAKgAECgYICQAAAA==.',['头上']='头上丶长犄角:BAAAKgADCgQIBAAAAA==.',['奈格']='奈格大坝:BAACKgAFFH8KAAMXAAcITRn1CwBkAQAXAAYIpxT1CwBkAQAHAAQIQRxgCQDlAAAqAAQKfxcAAwcACAiWIBgTAC0CAAcACAiWIBgTAC0CABYAAgjhG1YlAKUAAAAA.',['奉天']='奉天制躁:BAAAKgADCgEIAQAAAA==.',['奶油']='奶油麻花:BAAAKgADCgMIAwAAAA==.',['奶牛']='奶牛后勤兵:BAAAKgAECgYIBgAAAA==.',['如此']='如此肆意妄为:BAABKgAFFH8VAAQYAAYIEB0RBAA3AQAMAAYInxxaEgB1AQAYAAUIwBgRBAA3AQAZAAQIbw8XCwDTAAABKgAFFAgICgAMAD4WAA==.',['姜撞']='姜撞奶:BAAAKgADCgUIBQAAAA==.',['孔雀']='孔雀之转一:BAAAKgAECggICgAAAA==.',['宇智']='宇智波佩恩:BAAAKgAECgQIBAAAAA==.',['寂寞']='寂寞狩猎者:BAAAKgAECggIEAAAAA==.',['寡人']='寡人之怒:BAACKgAFFH8aAAMGAAQIBiDfOwD+AAAGAAQIBiDfOwD+AAAaAAMIjwZgGQBrAAAqAAQKfxoAAwYACAh8Hc5vALkBAAYACAh8Hc5vALkBABoABAgTDFhDAHMAAAAA.',['小丶']='小丶楼:BAABKgAFFH8FAAIDAAUIshEsGQAzAQADAAUIshEsGQAzAQAAAA==.',['小故']='小故事里的人:BAAAKgADCggICAAAAA==.',['小猪']='小猪爱丶馒头:BAABKgAFFH8GAAIGAAYIThB7JQBTAQAGAAYIThB7JQBTAQAAAA==.',['小红']='小红枣桂圆:BAAAKgAFFAQIAQAAAA==.',['小纪']='小纪:BAAAKgAECgEIAQAAAA==.',['小聋']='小聋人丿:BAAAKgAFFAgIAQAAAA==.',['小蕊']='小蕊丶:BAAAKgAECgUIBQAAAA==.',['小贰']='小贰黑:BAAAKgADCgMIAwAAAA==.',['小饼']='小饼干:BAAAKgADCggICAAAAA==.',['小黑']='小黑脸:BAABKgAFFH8HAAIRAAQIogiAJQC5AAARAAQIogiAJQC5AAAAAA==.',['尐样']='尐样儿:BAAAKgAECgcIEAAAAA==.',['少年']='少年派:BAAAKgAECgcIEQAAAA==.',['尔滨']='尔滨吴彦祖:BAAAKgAFFAMIAwAAAA==.',['尼姑']='尼姑妹妹:BAACKgAFFH8qAAIOAAgITRY3BAAPAgAOAAgITRY3BAAPAgAqAAQKfyoAAw4ACAh1HRkVADcCAA4ACAh1HRkVADcCAA0ABQiXB1ZdAMcAAAAA.',['峰丶']='峰丶:BAAAKgAECggICAAAAA==.',['布洛']='布洛灬克斯:BAAAKgAECgEIAQAAAA==.',['帅伟']='帅伟:BAACKgAFFH8KAAINAAYIkSArAQDwAQANAAYIkSArAQDwAQAqAAQKfxQAAhsACAiaFMYPAEMBABsACAiaFMYPAEMBAAAA.帅伟三花聚顶:BAAAKgAFFAQIBAAAAA==.',['帮你']='帮你钱包瘦身:BAAAKgADCgEIBAAAAA==.',['幽之']='幽之夜:BAAAKgADCgEIAQAAAA==.',['开车']='开车不保养:BAAAKgAECggIBQAAAA==.',['彪宝']='彪宝宝:BAAAKgADCgEIAgAAAA==.',['往事']='往事随風:BAAAKgADCgQICAAAAA==.',['怀特']='怀特迈恩:BAAAKgADCgIIAgAAAA==.',['怎么']='怎么梳都倦:BAACKgAFFH8RAAMFAAcIawy4CgBOAQAFAAcIawy4CgBOAQAGAAIInwUbPABmAAAqAAQKfxgAAwUACAiVCwUvAOYAAAUACAiOCwUvAOYAAAYAAQhIDJk2ATAAAAAA.怎么梳都卷:BAACKgAFFH8XAAQRAAYIvh3KCQCyAQARAAYIEx3KCQCyAQAcAAYIgRfoCQBtAQAdAAIIgQtADwAuAAAqAAQKfzEABBEACAhsGhMaAAECABEACAjEGRMaAAECAB0ABQiPC8EqALEAABwAAQhkFLBaAD4AAAAA.怎么梳都圈:BAAAKgADCgcICAAAAA==.怎么梳都弮:BAABKgAFFH8PAAMCAAYIRyVHBgAmAgACAAYIRyVHBgAmAgAVAAYIZQ5KDwBPAQABKgAFFAgIFAACADQjAA==.',['怒风']='怒风丨修罗:BAAAKgAECgIIAgAAAA==.',['恬静']='恬静怀古:BAAAKgAECgYIBgAAAA==.',['恶魔']='恶魔戒灵:BAABKgAFFH8MAAIMAAgIlRADBwD6AQAMAAgIlRADBwD6AQAAAA==.',['愛的']='愛的承諾:BAAAKgAECgMIAwAAAA==.',['懓鏕']='懓鏕:BAAAKgAECggIEAAAAA==.',['我是']='我是小小牛灬:BAAAKgAFFAYIBAAAAA==.',['我牛']='我牛我怕谁:BAAAKgAFFAQIBAAAAA==.',['我的']='我的奶有毒:BAAAKgAECgUIBQAAAA==.',['指甲']='指甲刀:BAAAKgADCggICQAAAA==.',['放着']='放着俺来:BAAAKgAECgIIAgAAAA==.放着我来了:BAAAKgAECgUIBQAAAA==.',['斑鸠']='斑鸠:BAAAKgAECgUIDQAAAA==.',['无名']='无名王女:BAAAKgADCggICQAAAA==.',['无妄']='无妄之火:BAAAKgAFFAYIAgAAAA==.',['无敌']='无敌电灯泡:BAAAKgADCggICAAAAA==.',['无畏']='无畏骑士:BAAAKgADCggIDgAAAA==.',['无聊']='无聊的小孩:BAAAKgADCgQIBAAAAA==.无聊的萨满:BAAAKgAFFAgIAgAAAA==.',['明镜']='明镜止水之心:BAAAKgAECgYIBgAAAA==.',['星星']='星星会变羊:BAABKgAECn8ZAAMRAAgI+RgeKgDiAQARAAgIfBgeKgDiAQAcAAgI6xGWHwC4AQAAAA==.',['星期']='星期仈:BAAAKgAECgUICgAAAA==.星期八:BAAAKgAECgEIAQAAAA==.',['春回']='春回天下:BAAAKgADCggICAAAAA==.',['是狐']='是狐狸呢:BAAAKgAECgEIAQAAAA==.',['智爷']='智爷:BAAAKgAECgUIBgAAAA==.',['智高']='智高无上:BAAAKgAFFAMIAwAAAA==.',['暗号']='暗号:BAAAKgAECggIDgAAAA==.',['暗牧']='暗牧小纪:BAAAKgADCggICAAAAA==.',['最后']='最后的柔情:BAAAKgADCggICAAAAA==.',['月下']='月下丶:BAABKgAECn8gAAMMAAgI3BpcGwDLAQAMAAgI3BpcGwDLAQAYAAIIdBUVdgBAAAAAAA==.',['月夜']='月夜清风:BAAAKgAECgQICAAAAA==.',['有为']='有为青年:BAAAKgADCgUIBQAAAA==.',['有事']='有事偷着乐:BAAAKgAECggIDAAAAA==.有事偷着笑:BAACKgAFFH8NAAMDAAcIEBNUCQDNAQADAAcIEBNUCQDNAQAEAAEIIhd3JgBEAAAqAAQKfxcAAwQACAjoIG0VAE0CAAQACAhoH20VAE0CAAMABghaIghKANYBAAAA.',['有趣']='有趣的小孩:BAAAKgADCggIBgAAAA==.',['未未']='未未:BAAAKgADCgMIAwAAAA==.',['术了']='术了个士:BAAAKgAECggICAAAAA==.',['来帮']='来帮助忘尘的:BAAAKgADCgMIAwAAAA==.',['桑吉']='桑吉尔夫:BAAAKgADCgYICAAAAA==.',['梦的']='梦的预见:BAAAKgADCggICAAAAA==.',['梦飛']='梦飛雪雁:BAAAKgADCgIIAwAAAA==.',['欧皇']='欧皇泡泡:BAAAKgADCgEIAQAAAA==.',['步兵']='步兵:BAAAKgADCgYIBgAAAA==.',['武僧']='武僧小纪:BAAAKgAECgcIBwAAAA==.',['武断']='武断乾坤:BAABKgAFFH8NAAINAAMIrglgJACRAAANAAMIrglgJACRAAAAAA==.',['武老']='武老贰:BAAAKgADCgIIAgAAAA==.',['死不']='死不了一点:BAABKgAFFH8RAAIeAAMIMRfxBwDrAAAeAAMIMRfxBwDrAAAAAA==.',['死亡']='死亡之握:BAABKgAFFH8OAAILAAMIeA5HNwC9AAALAAMIeA5HNwC9AAAAAA==.死亡冲钅:BAAAKgADCggICAABKgAFFAcIDQAGAO8ZAA==.死亡凋零灬:BAABKgAFFH8IAAIMAAgIuxm2EgBxAQAMAAgIuxm2EgBxAQAAAA==.',['殺戮']='殺戮天使:BAAAKgAECgQIBAAAAA==.',['水墨']='水墨丹青:BAAAKgAECgQIBAAAAA==.',['水鬼']='水鬼:BAAAKgAECgIIAgAAAA==.',['永真']='永真:BAAAKgAECgMIBQAAAA==.',['沃尔']='沃尔科娃:BAAAKgAECgQIBgAAAA==.',['没事']='没事就下线:BAAAKgAECggICAAAAA==.',['没烟']='没烟拉:BAAAKgAECgMIAwAAAA==.',['油她']='油她:BAABKgAFFH8HAAIKAAUISgyxCQD9AAAKAAUISgyxCQD9AAAAAA==.',['津门']='津门川哥:BAAAKgAECgYIBwAAAA==.',['流云']='流云开一朵丶:BAABKgAFFH8HAAIJAAYIghmtFQBsAQAJAAYIghmtFQBsAQAAAA==.',['流雲']='流雲:BAABKgAFFH8GAAICAAYIVSPSCQDSAQACAAYIVSPSCQDSAQAAAA==.',['浪子']='浪子回头:BAAAKgADCgIIBAAAAA==.',['浪荡']='浪荡骑士:BAAAKgADCggICAAAAA==.',['海坑']='海坑真是坑:BAAAKgADCggICAAAAA==.',['海蓝']='海蓝窗帘:BAABKgAFFH8FAAIGAAUI7hwmIABvAQAGAAUI7hwmIABvAQAAAA==.',['深海']='深海鳕鱼堡:BAAAKgAECgUIBwAAAA==.',['満滿']='満滿的恛憶:BAAAKgAECgYIBwAAAA==.',['源烨']='源烨:BAACKgAFFH8jAAMeAAYITRW3BAA6AQAeAAYITRW3BAA6AQALAAIIOgixKACCAAAqAAQKfzYAAx4ACAiKHPIMAMwBAB4ACAikG/IMAMwBAAsACAigD1VMAIYBAAAA.',['滴滴']='滴滴的弟弟:BAACKgAFFH8gAAQeAAUICxMFBgAxAQAeAAUICxMFBgAxAQALAAMIHAZtPwCgAAAKAAIIJAFTJAA8AAAqAAQKfy4ABB4ACAjZHecDAH0CAB4ACAjZHecDAH0CAAsACAjzDqtNAIIBAAoABwhUBUg6AJcAAAAA.',['火狐']='火狐狸皮草:BAAAKgADCggICAAAAA==.',['灬零']='灬零点灬:BAAAKgAECgQIBAAAAA==.',['灰狐']='灰狐:BAAAKgAECgUIBQAAAA==.',['灵魂']='灵魂死神:BAAAKgADCggIDQAAAA==.',['烟雨']='烟雨石:BAAAKgADCgUIBQAAAA==.',['無潇']='無潇潇:BAABKgAFFH8KAAMYAAYICB90AAB3AQAYAAUIvxp0AAB3AQAMAAUIHByJBABpAQAAAA==.',['煻綶']='煻綶:BAAAKgADCgIIAgAAAA==.',['熊猫']='熊猫不吃竹:BAAAKgAECgcIDgAAAA==.',['牛大']='牛大胆丶:BAABKgAFFH8IAAMNAAYITibzAwAtAgANAAYITibzAwAtAgAOAAEIAACgJAAAAAABKgAFFAgIBAAfAAAAAA==.',['狂妃']='狂妃紫月:BAACKgAFFH8iAAIGAAYISAfqQQDsAAAGAAYISAfqQQDsAAAqAAQKf0YAAgYACAiRFo9pAMYBAAYACAiRFo9pAMYBAAAA.',['狂月']='狂月少爷:BAAAKgAECgEIAgAAAA==.',['狐狸']='狐狸宝贝:BAAAKgADCgEIAQAAAA==.',['独狼']='独狼:BAAAKgAECgMIBAAAAA==.',['狼牙']='狼牙壮汉:BAAAKgAECgYICAAAAA==.',['猎手']='猎手小纪:BAAAKgAECgcIBwAAAA==.',['玛卡']='玛卡巴卡丶:BAAAKgAECgUIDQAAAA==.',['玥夜']='玥夜清风:BAAAKgAECgYIBwAAAA==.',['玩耍']='玩耍:BAABKgAECn8VAAITAAgI6RjjGAADAgATAAgI6RjjGAADAgAAAA==.',['珊蛮']='珊蛮:BAAAKgAECgUIBQAAAA==.',['球迷']='球迷杏眼:BAAAKgADCggICAAAAA==.',['琺外']='琺外狂徒:BAAAKgAFFAIIAgAAAA==.',['甜甜']='甜甜的幸福:BAAAKgAECgMIAwAAAA==.',['疯出']='疯出气质:BAABKgAFFH8IAAIDAAYIuRsOEgBmAQADAAYIuRsOEgBmAQAAAA==.',['疯狂']='疯狂小马:BAABKgAFFH8IAAIKAAgI4AnPBQBwAQAKAAgI4AnPBQBwAQAAAA==.疯狂的洋葱:BAAAKgAECgEIAQAAAA==.',['癫破']='癫破天:BAAAKgAFFAIIAgAAAA==.',['百变']='百变小樱:BAAAKgAECgcIBwAAAA==.',['皇家']='皇家时尚顾问:BAABKgAFFH8FAAIRAAQICguXFQDbAAARAAQICguXFQDbAAABKgAFFAgICAARAHYKAA==.',['睚眦']='睚眦必报:BAAAKgADCgQIBQAAAA==.',['石破']='石破天吉:BAAAKgAECgEIAQAAAA==.石破天惊:BAAAKgADCgIIAgAAAA==.',['碎蛋']='碎蛋小王子:BAABKgAFFH8IAAIVAAgIpBBMBgADAgAVAAgIpBBMBgADAgAAAA==.',['磨你']='磨你的血:BAAAKgADCgUIBQAAAA==.',['神官']='神官:BAAAKgAFFAQIBAAAAA==.',['秋雨']='秋雨丶:BAAAKgADCgEIAQAAAA==.',['章鱼']='章鱼触手:BAAAKgAECgEIAQAAAA==.',['索云']='索云心:BAAAKgADCgQIBAAAAA==.',['纪总']='纪总:BAAAKgAECgEIAQAAAA==.',['罗斯']='罗斯特:BAAAKgAFFAIIAgAAAA==.',['老白']='老白干:BAAAKgADCgIIAgAAAA==.',['考拉']='考拉牛牛:BAAAKgADCgcIBwAAAA==.',['耳廓']='耳廓狐:BAAAKgADCgEIAQAAAA==.',['能抗']='能抗能打:BAAAKgADCgYIBgAAAA==.',['艾莎']='艾莎范克里夫:BAAAKgADCggICAAAAA==.',['芃芃']='芃芃灬其麦:BAACKgAFFH8MAAINAAMIkxiJGQDRAAANAAMIkxiJGQDRAAAqAAQKfywAAw0ACAiXG/YPABwCAA0ACAiXG/YPABwCAA4ABAjhC/BSAHUAAAEqAAUUBAgVACAA5iMA.',['苦的']='苦的哇哇哭:BAACKgAFFH8FAAIZAAMI6QfhEwCfAAAZAAMI6QfhEwCfAAAqAAQKfyoAAhkACAgxH/MCAHQCABkACAgxH/MCAHQCAAAA.',['草履']='草履虫:BAABKgAFFH8LAAIGAAYIPyF0AAAeAgAGAAYIPyF0AAAeAgAAAA==.',['莫念']='莫念:BAAAKgADCgMIAwAAAA==.',['萌滚']='萌滚滚:BAAAKgADCgEIBAAAAA==.',['虽然']='虽然但是:BAABKgAFFH8IAAIEAAgIMwwPCAC5AQAEAAgIMwwPCAC5AQAAAA==.',['蜘蛛']='蜘蛛侦探:BAACKgAFFH8oAAMEAAUItCAWDADsAAADAAQIXCETIQAHAQAEAAQI5R8WDADsAAAqAAQKfzEAAwQACAidJEoHALICAAQABwisI0oHALICAAMABAghJOdeADwBAAAA.',['蝎子']='蝎子萊萊:BAACKgAFFH8XAAMLAAQITSPjCQAbAQALAAQITSPjCQAbAQAKAAQIWhhnDADeAAAqAAQKfx0AAgsACAjwIGYfAEYCAAsACAjwIGYfAEYCAAAA.',['蟑螂']='蟑螂惡霸:BAAAKgAECggICAABKgAFFAgIBgASADwFAA==.',['西冷']='西冷七分熟:BAABKgAFFH8KAAIIAAgIPxnlBABIAgAIAAgIPxnlBABIAgAAAA==.',['要命']='要命的灵魂:BAAAKgAECgYICAAAAA==.',['见死']='见死不救德:BAABKgAFFH8VAAMgAAQI5iPPDQAzAQAgAAQI5iPPDQAzAQAJAAEIUwSDYgAxAAAAAA==.',['訫無']='訫無雜鲶:BAAAKgAECggIDwAAAA==.',['诡计']='诡计:BAAAKgAECggICAAAAA==.',['请叫']='请叫我小甜甜:BAAAKgAECgUIBQAAAA==.请叫我詹姆斯:BAABKgAFFH8IAAIGAAQIvh98EAASAQAGAAQIvh98EAASAQAAAA==.',['贝尔']='贝尔小纪:BAACKgAFFH8MAAIgAAMI5A9OIgCeAAAgAAMI5A9OIgCeAAAqAAQKfyMABCAACAixE0oiAIsBACAACAixE0oiAIsBAAkAAQgTAm7lABgAACEAAQidA3gdABYAAAAA.',['贼的']='贼的荣耀:BAAAKgAECgEIAQAAAA==.',['超级']='超级大白牛:BAAAKgAECgYICwAAAA==.',['超超']='超超级赛亞人:BAABKgAECn8YAAMEAAcIvxi8SAAtAQAEAAYI/Ri8SAAtAQADAAYIeBFHxgCaAAAAAA==.',['踏我']='踏我的风:BAAAKgAECggICAABKgAFFAgIGgALAEwhAA==.',['这么']='这么近那么美:BAAAKgADCgEIAQABKgAFFAQIFQAgAOYjAA==.',['逝水']='逝水流年如梦:BAAAKgADCgEIAQAAAA==.',['那仁']='那仁满督拉:BAAAKgAFFAgIBAAAAA==.',['部落']='部落小帅哥:BAAAKgADCgEIAwAAAA==.',['酒星']='酒星君:BAAAKgAECgYICgAAAA==.',['醉丶']='醉丶千愁:BAAAKgADCgIIAgAAAA==.',['重装']='重装小狐:BAABKgAFFH8IAAICAAgIvg4jCQDhAQACAAgIvg4jCQDhAQAAAA==.',['野生']='野生火球鼠:BAAAKgAECgQIBgAAAA==.野生的死骑:BAAAKgAECgQIBwAAAA==.',['钡腿']='钡腿:BAAAKgAECgQIBAAAAA==.',['银狼']='银狼:BAAAKgADCgIIAgAAAA==.',['镇山']='镇山:BAAAKgADCgYIBgAAAA==.',['长春']='长春丶何广智:BAAAKgAECgIIAgABKgAFFAcIDQAGAO8ZAA==.长春丶吴彦祖:BAACKgAFFH8NAAIRAAMIcBZVGwDnAAARAAMIcBZVGwDnAAAqAAQKfxcAAxEABwi4EQxGAFIBABEABggvFQxGAFIBAB0AAQhkAAAAAAAAAAAA.长春丶徐志胜:BAAAKgAFFAIIAgAAAA==.',['阿兹']='阿兹大魔王丶:BAAAKgAECggIEwAAAA==.',['阿姨']='阿姨摸摸:BAAAKgAECgQIBAAAAA==.',['阿莱']='阿莱氪斯塔萨:BAAAKgADCgQIBwAAAA==.',['陆观']='陆观仙人:BAAAKgAECgcICgAAAA==.',['除非']='除非包吃包住:BAAAKgADCggIDQAAAA==.',['隨風']='隨風:BAACKgAFFH8HAAMVAAMI8xCqHwDXAAAVAAMI8xCqHwDXAAABAAEICAowJAAxAAAqAAQKfykABBUACAj8GwsoAAgCABUACAiMGQsoAAgCAAEABwjSGo49AHUBAAIAAwggHzQhABcBAAAA.',['雪域']='雪域飞花:BAAAKgADCgEIAQAAAA==.',['靑青']='靑青:BAABKgAFFH8IAAISAAgIRwzjBwCaAQASAAgIRwzjBwCaAQAAAA==.',['青柠']='青柠红柚派:BAAAKgADCggICAAAAA==.',['青涩']='青涩后妈:BAAAKgAECgYICQAAAA==.',['青玄']='青玄:BAAAKgADCgMIAwAAAA==.',['风实']='风实花:BAAAKgADCggICAAAAA==.',['风暴']='风暴降生:BAAAKgADCgEIAgAAAA==.',['飞不']='飞不了一点:BAABKgAFFH8FAAMQAAMIewaDIACQAAAQAAMIkgSDIACQAAAPAAIILAhDIABgAAAAAA==.',['香蕉']='香蕉芒果派:BAAAKgAECgIIAgAAAA==.香蕉苹果派:BAAAKgAECgEIAQAAAA==.',['香辣']='香辣海鲜锅:BAAAKgAFFAYIAgAAAA==.',['马哥']='马哥回来:BAAAKgAECgUIAwAAAA==.',['马大']='马大脚儿:BAAAKgADCggICAAAAA==.',['骇人']='骇人鲸:BAABKgAFFH8TAAIRAAgI5hLmBwDfAQARAAgI5hLmBwDfAQAAAA==.',['骑个']='骑个龙咚锵:BAAAKgADCggICAAAAA==.',['骑兵']='骑兵:BAACKgAFFH8NAAIGAAMI7xkBPwD0AAAGAAMI7xkBPwD0AAAqAAQKfyEAAgYACAjnF09SAP0BAAYACAjnF09SAP0BAAAA.',['高贵']='高贵的冰迪克:BAAAKgAECggIDwAAAA==.',['鬟髻']='鬟髻青衣:BAAAKgAECggIEAABKgAFFAgIBAAfAAAAAA==.',['魂幡']='魂幡渡忘川:BAAAKgADCgYICQAAAA==.',['鳳凰']='鳳凰涅槃:BAAAKgADCgQIBAAAAA==.',['麦当']='麦当当:BAAAKgAECgIIAgAAAA==.',['黑的']='黑的臭的:BAAAKgADCggIDwAAAA==.',['默默']='默默不语:BAACKgAFFH8qAAIMAAYIxB3MEQB7AQAMAAYIxB3MEQB7AQAqAAQKfxYAAgwACAi5G6sYAC8CAAwACAi5G6sYAC8CAAAA.',['齐宣']='齐宣王田辟疆:BAAAKgAECgYICgAAAA==.',['龍大']='龍大号:BAABKgAFFH8HAAIGAAIILBZLMACtAAAGAAIILBZLMACtAAAAAA==.',['龍小']='龍小号:BAAAKgAFFAIIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end