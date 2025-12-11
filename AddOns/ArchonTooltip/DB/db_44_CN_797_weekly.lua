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
 local lookup = {'Warlock-Destruction','Paladin-Retribution','Mage-Frost','Priest-Shadow','DemonHunter-Vengeance','Warlock-Demonology','Hunter-BeastMastery','Rogue-Assassination','Druid-Restoration','DemonHunter-Havoc','DeathKnight-Frost','Shaman-Elemental','Shaman-Restoration','Priest-Holy','Warrior-Protection','Mage-Arcane','Unknown-Unknown','Hunter-Marksmanship','Paladin-Protection','Druid-Balance','Warrior-Fury','Evoker-Preservation','Evoker-Devastation','DeathKnight-Unholy','DeathKnight-Blood','Evoker-Augmentation','Rogue-Outlaw','Monk-Windwalker','Monk-Brewmaster','Druid-Guardian','Druid-Feral','Paladin-Holy','Monk-Mistweaver','Hunter-Survival',}; local provider = {region='CN',realm='自由之风',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abysstoller:BAABLAAFFH8GAAIBAAMImhq7RwCgAAABAAMImhq7RwCgAAAAAA==.',Af='Affogato:BAAALAAECggIEQAAAA==.',Al='Alcopath:BAABLAAFFH8HAAICAAIIVCafHQDfAAACAAIIVCafHQDfAAAAAA==.',An='Angrybug:BAAALAAECgUIBQAAAA==.',Be='Beststyle:BAAALAAECgYIBgAAAA==.',Bl='Blackshadow:BAAALAAFFAEIAQAAAA==.',Ca='Cababa:BAABLAAFFH8FAAIDAAMIIh0yCwCuAAADAAMIIh0yCwCuAAABLAAFFAUIKQAEAAIfAA==.',Ch='Cheburashka:BAAALAAECgYIDAABLAAECgYIOAAFAMwbAA==.',Cj='Cjuice:BAAALAAECgEIAQAAAA==.',De='Detwinsy:BAAALAAECgYIBgAAAA==.',Di='Disdor:BAAALAADCgMIAwAAAA==.',Ea='Earlybird:BAAALAADCgEIAQAAAA==.',Em='Emno:BAACLAAFFH8eAAIBAAUIGRo2MwBIAQABAAUIGRo2MwBIAQAsAAQKfx4AAwEABwiRHpgiANcBAAYABwgsGjYjAPABAAEABwjpHJgiANcBAAAA.',Es='Essementhol:BAAALAAFFAIIBAAAAA==.',Fa='Faceless:BAAALAAECgYIBgAAAA==.Fallenarcher:BAACLAAFFH8NAAIHAAMIIRTxbgCEAAAHAAMIIRTxbgCEAAAsAAQKfy0AAgcACAh2H1oiADACAAcACAh2H1oiADACAAAA.',Ga='Galatea:BAAALAADCgUIBQAAAA==.',Ha='Hardyge:BAAALAADCgYIBgAAAA==.',Hy='Hypersomnia:BAAALAAECgMIAwAAAA==.Hysteria:BAAALAAFFAIIAgAAAA==.',Je='Jearo:BAABLAAFFH8KAAIHAAYIdQ7gPwBHAQAHAAYIdQ7gPwBHAQAAAA==.',Jo='Josephlee:BAAALAAFFAIIAwAAAA==.',Ko='Kokohekmaty:BAAALAAECgMIBAAAAA==.',Ky='Kylins:BAABLAAECn8cAAIIAAYIMAtkGQDpAAAIAAYIMAtkGQDpAAAAAA==.',Li='Life:BAAALAAECggICAAAAA==.Littlely:BAABLAAFFH8GAAIJAAYIDQDUUwARAAAJAAYIDQDUUwARAAAAAA==.',Lo='Lovelybaby:BAAALAAECgYIBgAAAA==.',Lr='Lronmandh:BAABLAAFFH8NAAIKAAMIqhSQHAD5AAAKAAMIqhSQHAD5AAABLAAFFAUIGgABAH8aAA==.',Me='Merceddes:BAAALAAECgcIDQAAAA==.',Ni='Niudehen:BAAALAAECgYIBgAAAA==.',Op='Oppugno:BAACLAAFFH8IAAIHAAIIRCP/MQDAAAAHAAIIRCP/MQDAAAAsAAQKfxYAAgcACAjMIUYgANgCAAcACAjMIUYgANgCAAAA.',Ra='Rangot:BAAALAADCgcIBwAAAA==.',Sh='Shepherd:BAAALAADCgEIAQAAAA==.Shing:BAAALAAFFAIIBAAAAA==.Shysisr:BAABLAAFFH8KAAILAAMIoRH2ZgB7AAALAAMIoRH2ZgB7AAAAAA==.',Sn='Sniper:BAAALAAFFAIIAgAAAA==.',To='Toot:BAACLAAFFH8QAAMMAAYIfgdqKAABAQAMAAYIfgdqKAABAQANAAQIEgcbQACmAAAsAAQKfxQAAg0ABwiqDQnEAP4AAA0ABwiqDQnEAP4AAAAA.',Tu='Turndk:BAAALAAECgEIAQAAAA==.Turnss:BAAALAAECgYIBgAAAA==.',Yu='Yuesying:BAABLAAFFH8HAAIOAAII8RTPNACIAAAOAAII8RTPNACIAAAAAA==.',Za='Zakisaxon:BAABLAAFFH8VAAIPAAUIJBbyFQAHAQAPAAUIJBbyFQAHAQAAAA==.',Zo='Zoe:BAAALAAECgYICAAAAA==.',['一半']='一半醒:BAACLAAFFH8RAAIQAAMIEhZVRQCNAAAQAAMIEhZVRQCNAAAsAAQKfy8AAxAACAhiG6cvAIwCABAACAhiG6cvAIwCAAMAAwjhFQB1AJgAAAAA.',['一点']='一点八二米:BAAALAADCgMIAwAAAA==.',['一璐']='一璐有你:BAAALAADCgEIAQAAAA==.',['一苇']='一苇渡江湖:BAAALAADCgYIBgAAAA==.',['一路']='一路向北:BAAALAAECgYIBwABLAAFFAIIAgARAAAAAA==.',['七猫']='七猫:BAAALAAFFAIIAgAAAA==.',['万兽']='万兽无疆丶:BAAALAAECgEIAQAAAA==.',['万径']='万径人踪灭:BAAALAAECgYIDAAAAA==.',['三妖']='三妖五四:BAAALAAECgYIBgAAAA==.',['不惭']='不惭世上英:BAAALAAECgYICQAAAA==.',['不抱']='不抱怨:BAAALAAECgQICAAAAA==.',['不知']='不知火:BAABLAAFFH8IAAIKAAIIaR42TABNAAAKAAIIaR42TABNAAABLAAFFAUIDwACANYgAA==.',['不见']='不见花海:BAABLAAFFH8YAAMSAAYIXiETBgDGAQAHAAYIXiHgFQDkAQASAAYI6BcTBgDGAQAAAA==.',['专杀']='专杀泪:BAAALAADCgIIAgAAAA==.',['且听']='且听風吟:BAABLAAFFH8GAAMQAAUIpCFGOAANAQAQAAQIEyJGOAANAQADAAEI5h/HGwBgAAAAAA==.',['且聽']='且聽風吟:BAAALAAFFAYIAwABLAAFFAgIEgATAJkLAA==.',['东海']='东海边的夏夏:BAABLAAECn8cAAINAAYIkRXXhgByAQANAAYIkRXXhgByAQAAAA==.东海边的夏天:BAAALAAECgQICAAAAA==.东海边的小君:BAABLAAECn82AAMJAAYIiiTnFQAhAgAJAAYIiiTnFQAhAgAUAAII2QVjqQA4AAAAAA==.东海边的小夏:BAABLAAECn8aAAIBAAYI2w+XVgD8AAABAAYI2w+XVgD8AAAAAA==.东海边的龙娃:BAAALAAECgYIEgAAAA==.',['东邪']='东邪孙尚香:BAAALAAECgYIBgAAAA==.',['东风']='东风四一:BAABLAAFFH8HAAIBAAUIFROhOgAeAQABAAUIFROhOgAeAQAAAA==.',['丧彪']='丧彪:BAAALAAFFAIIAgAAAA==.',['丶溜']='丶溜溜:BAACLAAFFH8pAAIEAAUIAh9IDwBvAQAEAAUIAh9IDwBvAQAsAAQKfx4AAgQABwjUHichAGoCAAQABwjUHichAGoCAAAA.',['丶生']='丶生悻哆懿:BAABLAAFFH8GAAIIAAYIhhkpAQA4AgAIAAYIhhkpAQA4AgAAAA==.',['乌瑞']='乌瑞亚:BAABLAAECn8YAAIHAAYI3yPcXgAeAgAHAAYI3yPcXgAeAgABLAAFFAgIPgAHAJcaAA==.',['九霄']='九霄丶:BAABLAAFFH8GAAIPAAYIOgDIOwALAAAPAAYIOgDIOwALAAAAAA==.',['买橙']='买橙子的熊猫:BAAALAADCgcIBwAAAA==.',['了无']='了无风行:BAAALAAFFAIIAgAAAA==.',['予安']='予安:BAAALAAECgYICQAAAA==.',['二木']='二木佳奈多:BAABLAAFFH8MAAMOAAYIhBGPGQCEAQAOAAYIhBGPGQCEAQAEAAUIHBXlEwA2AQAAAA==.',['云里']='云里雾:BAAALAAFFAIIAgAAAA==.',['五岳']='五岳倒为轻:BAAALAAECgYICAAAAA==.',['五更']='五更琉璃:BAAALAAECgQICgAAAA==.',['亦飞']='亦飞雪:BAAALAAECgYIBwAAAA==.',['亮锤']='亮锤:BAAALAADCggICAAAAA==.',['亽氼']='亽氼太美:BAAALAADCgYIBgAAAA==.',['今世']='今世緣:BAAALAAFFAIIAgAAAA==.',['仔仔']='仔仔小情人:BAAALAAECgEIAQAAAA==.',['伊万']='伊万卡:BAAALAAECgMIAwAAAA==.',['伊卡']='伊卡洛澌:BAABLAAECn8WAAINAAgIvBbzHAAOAgANAAgIvBbzHAAOAgAAAA==.',['伊撒']='伊撒尔:BAAALAADCgYIBgAAAA==.',['伤心']='伤心的精灵:BAAALAAFFAIIBAAAAA==.',['佟大']='佟大为:BAAALAAECgYIBgAAAA==.',['依德']='依德服人:BAAALAAFFAIIAgAAAA==.',['依飞']='依飞雪儿:BAAALAAECgQIBAAAAA==.',['信仰']='信仰向右:BAAALAADCgEIAQAAAA==.',['光头']='光头:BAABLAAFFH8FAAIVAAUIPhwxIABqAQAVAAUIPhwxIABqAQABLAAFFAYIDQAHABIiAA==.',['光明']='光明佟大为:BAAALAAFFAYIAwABLAAFFAgIBQAJAJgMAA==.',['光辉']='光辉菜菜:BAAALAAECgYIBAAAAA==.',['兜儿']='兜儿里有糖:BAAALAAECgYICQAAAA==.',['八神']='八神真白:BAAALAADCgMIAwAAAA==.',['八雲']='八雲紫:BAABLAAFFH8FAAIBAAUINB8lDwDvAQABAAUINB8lDwDvAQABLAAFFAgIDgAGAMkdAA==.',['八零']='八零九零:BAAALAAFFAIIBAAAAA==.',['六月']='六月花开:BAAALAAECgUIBgAAAA==.',['六溜']='六溜溜:BAAALAAECgIIAgAAAA==.',['养一']='养一只死一只:BAAALAAECgUIBQAAAA==.',['冈仁']='冈仁波齐:BAAALAAECgMIAwAAAA==.',['冥灯']='冥灯龙:BAABLAAFFH8GAAIOAAIIqQuANQCHAAAOAAIIqQuANQCHAAAAAA==.',['冬天']='冬天:BAAALAAECgYICQAAAA==.',['冰大']='冰大苗:BAABLAAFFH8HAAILAAIInxfmUQCgAAALAAIInxfmUQCgAAAAAA==.',['冰清']='冰清玉洁:BAAALAAECgYIDwAAAA==.',['凉凉']='凉凉倾寒:BAAALAAECgIIAgAAAA==.',['凉宫']='凉宫春日:BAAALAAECggIBgAAAA==.',['凋零']='凋零之吻:BAAALAADCgIIAgAAAA==.',['凯尔']='凯尔特:BAAALAAECgQIBAAAAA==.',['刀马']='刀马:BAABLAAFFH8GAAITAAIIGxrXDwCaAAATAAIIGxrXDwCaAAAAAA==.',['剑无']='剑无民丨灬:BAAALAAECggICQAAAA==.',['劍雪']='劍雪飄零:BAAALAAECgQIBAAAAA==.',['加尔']='加尔弗雷德:BAABLAAECn8vAAMGAAYILh4qHQAUAgAGAAYILh4qHQAUAgABAAEIuw9Y/gBCAAAAAA==.',['北夜']='北夜辰:BAAALAAFFAIIAwAAAA==.',['十万']='十万伏特:BAABLAAFFH8JAAMNAAIIqxBiXQBgAAANAAIIqxBiXQBgAAAMAAIINBS9PwBLAAAAAA==.',['卖火']='卖火箭:BAABLAAFFH8KAAILAAMIdRlsJgAAAQALAAMIdRlsJgAAAQAAAA==.卖火箭的女孩:BAABLAAFFH8GAAIKAAIIBhbPUwBHAAAKAAIIBhbPUwBHAAAAAA==.',['南阳']='南阳:BAAALAAECgYIBgAAAA==.',['卷发']='卷发大波浪:BAAALAAECgEIAQAAAA==.',['去年']='去年夏天:BAAALAAECgEIAQAAAA==.',['古尔']='古尔卩:BAAALAADCgEIAQAAAA==.',['只奶']='只奶自己:BAABLAAFFH8RAAIJAAQIRhIbIgAMAQAJAAQIRhIbIgAMAQAAAA==.',['只敲']='只敲亿锤子:BAAALAAFFAEIAgAAAA==.',['叮叮']='叮叮铛丶:BAAALAAECgcICgAAAA==.',['可乐']='可乐新之柱:BAAALAAECgcIBwAAAA==.',['可爱']='可爱的魔魔:BAABLAAECn8kAAMHAAYI4SCGYgAWAgAHAAYI4SCGYgAWAgASAAQI3RRoewDqAAABLAAECgYIOAAFAMwbAA==.',['吃人']='吃人刀丶:BAABLAAFFH8QAAIMAAMI6Ru+MgCUAAAMAAMI6Ru+MgCUAAAAAA==.',['吉吉']='吉吉丨安娜:BAAALAAECgUIBgAAAA==.',['吉照']='吉照句汝妹:BAABLAAFFH8GAAINAAIILwZPbwBLAAANAAIILwZPbwBLAAAAAA==.',['吉祥']='吉祥如意天:BAAALAAECgIIAgAAAA==.',['吐息']='吐息小龟:BAACLAAFFH8GAAIWAAMIcxBBDQDSAAAWAAMIcxBBDQDSAAAsAAQKfxQAAhYABwhFH9gKAIICABYABwhFH9gKAIICAAAA.',['君子']='君子:BAAALAADCgEIAQAAAA==.',['听凭']='听凭风引:BAAALAAECgQIBAAAAA==.',['吵来']='吵来吵去:BAAALAAECgYICAAAAA==.',['呜啦']='呜啦啦小十六:BAABLAAECn8kAAINAAYIyhgcLwCmAQANAAYIyhgcLwCmAQAAAA==.',['呜喵']='呜喵王丶:BAAALAAFFAIIAgAAAA==.呜喵王丷:BAABLAAFFH8GAAIUAAYIcgK8KABwAAAUAAYIcgK8KABwAAAAAA==.',['呼死']='呼死一个逗比:BAAALAAECgYICQAAAA==.',['咏春']='咏春拳:BAAALAAECgYIBgAAAA==.',['咕德']='咕德华:BAACLAAFFH8iAAIJAAcIRRoICAAsAgAJAAcIRRoICAAsAgAsAAQKfxcAAgkACAgDFcs4APwBAAkACAgDFcs4APwBAAAA.',['咸鱼']='咸鱼哥:BAAALAAFFAIIAgAAAA==.',['哎别']='哎别动:BAAALAADCgYIBgAAAA==.',['哎呀']='哎呀你真坏啊:BAAALAADCgUIBQAAAA==.',['啊乌']='啊乌亂先生:BAAALAAECgYIBgAAAA==.',['啊臭']='啊臭臭:BAAALAAECgYIBgAAAA==.',['啸狮']='啸狮王:BAAALAAECgQIBAAAAA==.',['善恶']='善恶有报:BAACLAAFFH8HAAILAAYI+hcQKgCPAQALAAYI+hcQKgCPAQAsAAQKfxkAAgsABgi2IichAPUBAAsABgi2IichAPUBAAAA.',['喜時']='喜時:BAAALAAECgYIBgAAAA==.',['嘟噜']='嘟噜嘟噜噜丶:BAABLAAFFH8GAAIMAAIIVAkbMgCFAAAMAAIIVAkbMgCFAAAAAA==.',['固拉']='固拉多:BAAALAAECgUIBgAAAA==.',['圆润']='圆润的大胖:BAAALAADCgEIAQAAAA==.',['土猪']='土猪:BAABLAAFFH8KAAITAAYI1AgREACYAAATAAYI1AgREACYAAAAAA==.',['圣光']='圣光小奶骑:BAAALAAECgUIBQAAAA==.',['圣狱']='圣狱酋长:BAAALAAECgcIEAAAAA==.',['基本']='基本死亡法则:BAAALAAECgMIAwAAAA==.',['堕落']='堕落人生:BAAALAAECgUIBgAAAA==.',['墨尔']='墨尔多:BAAALAAECgQIBAAAAA==.',['墨香']='墨香哭乱冢:BAAALAAECgYIDQAAAA==.',['壹笑']='壹笑悯恩仇:BAAALAAECgYIAgAAAA==.',['夏春']='夏春:BAAALAAECgUIBQAAAA==.',['夏风']='夏风:BAAALAAECgEIAQAAAA==.',['夕一']='夕一惡:BAABLAAECn8jAAMPAAYIPRZTJQAeAQAPAAYILxRTJQAeAQAVAAYIwhFnUwAbAQAAAA==.',['夕岚']='夕岚:BAAALAAECgIIAgAAAA==.',['多多']='多多柠檬:BAAALAAFFAEIAQABLAAFFAYIDQAHABIiAA==.',['多毛']='多毛芳香腿:BAAALAAECgQIBAAAAA==.',['夜揽']='夜揽星月:BAABLAAECn8UAAIHAAYIlBqtgQDbAQAHAAYIlBqtgQDbAQAAAA==.',['夜晚']='夜晚的星空:BAAALAAECgIIAgAAAA==.',['夜枫']='夜枫丶:BAAALAAECgYIBQAAAA==.',['夜间']='夜间飞行:BAAALAAECgYIBgAAAA==.',['夜鸮']='夜鸮杜尔柯:BAAALAAECgYIBgAAAA==.',['大哥']='大哥推背么:BAAALAAFFAIIAgAAAA==.',['大头']='大头东:BAABLAAFFH8NAAILAAUIYCNAKgCOAQALAAUIYCNAKgCOAQABLAAFFAYIDQAHABIiAA==.大头东东:BAABLAAECn8TAAILAAgIEyb2CQBRAwALAAgIEyb2CQBRAwABLAAFFAYIDQAHABIiAA==.大头东已:BAAALAAECggICAABLAAFFAYIDQAHABIiAA==.',['大猪']='大猪蹄子丶:BAAALAAECgMIAwAAAA==.',['大虫']='大虫灬挪得慢:BAAALAAFFAIIAgAAAA==.',['天使']='天使爱墩:BAAALAADCgIIAgAAAA==.',['天然']='天然逗比娃:BAABLAAFFH8IAAIDAAIIQw1XFQCCAAADAAIIQw1XFQCCAAAAAA==.',['天聋']='天聋人:BAAALAAECgYIBgAAAA==.',['天道']='天道萌叔叔:BAAALAAECgMIAwAAAA==.',['天龙']='天龙集团:BAAALAAECgMIAwAAAA==.',['太娰']='太娰:BAAALAAECgYICgAAAA==.',['失落']='失落于风:BAAALAAECgUIBQAAAA==.',['头光']='头光:BAAALAADCgMIAwAAAA==.',['头酱']='头酱心腹大患:BAAALAAECgYICAAAAA==.',['夸神']='夸神大号:BAAALAAECgYICAAAAA==.',['奇迹']='奇迹泡丁:BAAALAAECgMIAwAAAA==.',['奈德']='奈德丽:BAAALAAECgIIAgAAAA==.',['奔跑']='奔跑小膀光:BAAALAAECgEIAQAAAA==.',['奥库']='奥库尼的雨:BAAALAAFFAMIAwAAAA==.',['奥德']='奥德彪的爷爷:BAAALAAECgYIDwAAAA==.',['奶丶']='奶丶慕:BAAALAAFFAYIAwAAAA==.',['奶量']='奶量惊仁:BAAALAAECgYIBgAAAA==.',['好用']='好用:BAAALAAFFAIIAgAAAA==.',['如臻']='如臻至极:BAAALAAECgYIDAAAAA==.',['妙妙']='妙妙屋:BAAALAADCggICgAAAA==.',['姐姐']='姐姐是杀手:BAAALAAECgEIAQAAAA==.',['孙先']='孙先生:BAAALAADCgcIBwAAAA==.',['孤单']='孤单的大胖:BAAALAAECgYICAAAAA==.',['寒夜']='寒夜:BAAALAAFFAIIAwAAAA==.',['将冰']='将冰山劈开:BAAALAADCggICAAAAA==.将冰山融化:BAABLAAFFH8FAAINAAIIhwLRdQBAAAANAAIIhwLRdQBAAAAAAA==.',['小头']='小头东:BAABLAAFFH8HAAILAAUIhB/vNABoAQALAAUIhB/vNABoAQABLAAFFAYIDQAHABIiAA==.小头东东:BAABLAAFFH8HAAILAAUIzh49MwBuAQALAAUIzh49MwBuAQABLAAFFAYIDQAHABIiAA==.',['小家']='小家伙:BAAALAAECgYIDAAAAA==.',['小小']='小小圆:BAABLAAFFH8NAAINAAMILBi3MQDkAAANAAMILBi3MQDkAAAAAA==.',['小尛']='小尛紫:BAACLAAFFH8oAAIDAAcIzR6kAQD+AQADAAcIzR6kAQD+AQAsAAQKfyoAAgMACAgYJlwCAGoDAAMACAgYJlwCAGoDAAAA.',['小峫']='小峫鄂:BAAALAADCgEIAQAAAA==.',['小杀']='小杀:BAAALAAECgYIBgAAAA==.',['小柳']='小柳:BAAALAADCgUIBQAAAA==.',['小檽']='小檽:BAAALAADCgMIAwAAAA==.',['小牛']='小牛未来:BAAALAADCgEIAQAAAA==.',['小百']='小百合:BAABLAAFFH8PAAICAAMI1iBuHQDgAAACAAMI1iBuHQDgAAAAAA==.',['小萨']='小萨满:BAAALAAECgUIBwAAAA==.',['小蓝']='小蓝施:BAAALAAECgYIDAAAAA==.',['小钻']='小钻风:BAAALAAECgUIBQAAAA==.',['小铭']='小铭同学丶:BAABLAAFFH8FAAIFAAIIYA4FEgBrAAAFAAIIYA4FEgBrAAAAAA==.',['小魚']='小魚:BAAALAAFFAIIAgAAAA==.',['尐尐']='尐尐牧:BAAALAAECgYIBgAAAA==.',['就拉']='就拉你啦:BAAALAAECgYICQAAAA==.',['就是']='就是能变:BAAALAAECgYIBgAAAA==.就是能萨:BAAALAAECgMIAwAAAA==.',['山丘']='山丘山丘:BAAALAAFFAIIBAAAAA==.',['巅峰']='巅峰猎首:BAAALAADCgQIBAAAAA==.',['巍巍']='巍巍晓风:BAABLAAFFH8FAAIHAAMIsAUreABsAAAHAAMIsAUreABsAAAAAA==.',['巛炫']='巛炫靓彡:BAABLAAFFH8HAAIHAAQIQwwUYwCtAAAHAAQIQwwUYwCtAAAAAA==.',['左右']='左右采之:BAABLAAFFH8GAAIMAAYI6BikFgCHAQAMAAYI6BikFgCHAQAAAA==.',['巨龙']='巨龙末法:BAAALAAECgIIAgAAAA==.',['巫耀']='巫耀王:BAABLAAFFH8GAAILAAIIJQ1mjQB7AAALAAIIJQ1mjQB7AAAAAA==.',['巴卫']='巴卫:BAAALAAECgYIDwAAAA==.',['巴哈']='巴哈姆特:BAAALAAFFAIIAgAAAA==.',['巴林']='巴林:BAAALAAECgYIBgAAAA==.',['巴烈']='巴烈斯:BAAALAAFFAgIBAAAAA==.',['巴诺']='巴诺克:BAABLAAFFH8HAAIKAAMIpRwhJQDMAAAKAAMIpRwhJQDMAAAAAA==.',['巴陵']='巴陵名捕一战:BAABLAAFFH8HAAIPAAMIUwQMJQBVAAAPAAMIUwQMJQBVAAAAAA==.',['师太']='师太来阅经:BAAALAADCgMIAwAAAA==.',['希尔']='希尔瓦纳缌:BAABLAAFFH8NAAIHAAIIMxjOkgBEAAAHAAIIMxjOkgBEAAAAAA==.',['帕拉']='帕拉丁:BAAALAAECgYICgAAAA==.',['并泥']='并泥法:BAAALAAECgYIBgAAAA==.',['幻影']='幻影长矛手:BAAALAADCgQIBAAAAA==.',['幽幽']='幽幽紫藤泪:BAAALAAECggICAAAAA==.',['幽骑']='幽骑:BAAALAAECgYIBgAAAA==.',['张富']='张富贵:BAAALAAECgYICAAAAA==.',['当我']='当我不存在:BAAALAAECgMIAwAAAA==.',['影团']='影团团:BAAALAAFFAIIAgAAAA==.',['影小']='影小白:BAAALAADCgIIAwAAAA==.',['影陽']='影陽:BAAALAAFFAIIAgAAAA==.',['彼时']='彼时的月光:BAABLAAFFH8NAAIJAAII7x8IHACyAAAJAAII7x8IHACyAAAAAA==.',['微风']='微风细语:BAABLAAFFH8FAAIOAAIIDAdaPAB9AAAOAAIIDAdaPAB9AAAAAA==.',['德小']='德小猫:BAAALAAECgYIDAAAAA==.',['德过']='德过且过:BAAALAAFFAIIAgAAAA==.',['心姬']='心姬:BAAALAAECgYIBgAAAA==.',['心悦']='心悦:BAAALAAECgMIAwAAAA==.',['心的']='心的冬眠:BAABLAAFFH8GAAIDAAQIEwtqDACQAAADAAQIEwtqDACQAAAAAA==.',['心若']='心若曦:BAAALAAECgEIAQAAAA==.',['忌霞']='忌霞伤:BAACLAAFFH8gAAMHAAYIJiDtMQByAQAHAAUI6RvtMQByAQASAAMIPxzYDAC0AAAsAAQKfxUAAwcABgjbHvVUAJoBAAcABghrHfVUAJoBABIABghTHYxQAHQBAAAA.',['忒西']='忒西:BAAALAAECgQIBAAAAA==.',['快滚']='快滚:BAAALAAECgMIBAAAAA==.',['快跑']='快跑啊死腿:BAABLAAFFH8aAAILAAgINyEnBAC/AgALAAgINyEnBAC/AgAAAA==.',['性感']='性感小蛮腰:BAAALAAECgUIBgAAAA==.',['悦悦']='悦悦妹妹:BAAALAADCgEIAQAAAA==.',['惘沉']='惘沉妖:BAABLAAFFH8ZAAIDAAYIWxomBACUAQADAAYIWxomBACUAQAAAA==.',['愚十']='愚十九:BAAALAAECgYIBgAAAA==.',['我代']='我代表联盟:BAAALAAECgcIBwAAAA==.',['我妻']='我妻由乃:BAAALAAECgcIBwAAAA==.',['我打']='我打江南走过:BAAALAAFFAIIAgAAAA==.',['我的']='我的圣光阿:BAAALAAFFAEIAwAAAA==.我的月亮:BAAALAAECgEIAQAAAA==.',['我超']='我超漂亮的:BAABLAAFFH8FAAMOAAIIFwRqSABZAAAOAAIIFwRqSABZAAAEAAIIEAPZMAAwAAAAAA==.',['战嗷']='战嗷嗷:BAAALAAECgEIAQAAAA==.',['拾捌']='拾捌度半:BAAALAAECgYIEAAAAA==.',['推胸']='推胸治妇:BAAALAADCgQIBAAAAA==.',['提尔']='提尔比茨:BAAALAADCgQIBAAAAA==.',['摸腿']='摸腿骑:BAAALAAFFAIIAgABLAAFFAUIKQAEAAIfAA==.',['斯图']='斯图卡:BAAALAADCgQIBAAAAA==.',['方开']='方开我得儿箭:BAAALAADCgEIAQAAAA==.',['旋转']='旋转跳跃:BAAALAAECgEIAQAAAA==.',['无敌']='无敌小小刀:BAAALAAFFAYIAwAAAA==.无敌的猪猪:BAAALAAECgUIBwAAAA==.',['无极']='无极仙道:BAACLAAFFH8JAAILAAII2hxjTQCjAAALAAII2hxjTQCjAAAsAAQKfyIAAgsACAhNHlcyAKoCAAsACAhNHlcyAKoCAAAA.无极论仙道:BAAALAADCggICAAAAA==.',['无辜']='无辜袭击安娜:BAAALAAECgMIAwAAAA==.',['无限']='无限荣耀:BAAALAADCgcIBwAAAA==.',['旧识']='旧识:BAAALAAECggICAAAAA==.',['星光']='星光鱼文波:BAAALAAECggICAAAAA==.',['星空']='星空咆哮:BAAALAAFFAMIBAAAAA==.',['是带']='是带不动德:BAAALAAECgYIBgAAAA==.',['晏秋']='晏秋:BAAALAAFFAIIBAAAAA==.',['晓好']='晓好比:BAAALAADCggICAAAAA==.',['晓风']='晓风夜神:BAAALAAECgMIAwAAAA==.',['晚晚']='晚晚是头猪:BAAALAAECgIIAgAAAA==.',['普利']='普利西亚:BAABLAAFFH8HAAICAAYI0hEQDACkAQACAAYI0hEQDACkAQAAAA==.',['暗瞳']='暗瞳若曦:BAAALAAFFAQIBAAAAA==.',['曾经']='曾经初吻:BAAALAAECgYIBgAAAA==.',['最后']='最后一只猫:BAACLAAFFH8kAAIXAAYITxQ8DQBMAQAXAAYITxQ8DQBMAQAsAAQKfyIAAhcACAjdHsYSAJsCABcACAjdHsYSAJsCAAAA.',['最嗨']='最嗨切糕男:BAAALAAECgYIEAAAAA==.',['月卫']='月卫:BAAALAAECgMIAwAAAA==.',['月影']='月影织渊:BAAALAAFFAIIAgAAAA==.',['月色']='月色如银:BAAALAADCgMIAwAAAA==.',['朔风']='朔风:BAAALAADCgcICQAAAA==.',['朗阿']='朗阿瑟:BAAALAAECgEIAQAAAA==.',['木有']='木有粗面:BAABLAAFFH8IAAIHAAII5yMNfQBeAAAHAAII5yMNfQBeAAAAAA==.',['未来']='未来那么远:BAAALAADCgQIBAAAAA==.',['末曰']='末曰沧雨:BAAALAAECgYICgAAAA==.',['杀手']='杀手黑夜:BAAALAAECgUIBwAAAA==.',['杀神']='杀神的猪猪:BAAALAAECgYIBgAAAA==.',['李二']='李二丫:BAAALAAECgQIBAAAAA==.',['李墨']='李墨笑潇:BAAALAAECgQIAgAAAA==.',['李青']='李青渊丶:BAACLAAFFH8hAAMEAAYI/BkcBgAEAgAEAAYI/BkcBgAEAgAOAAUI3h+nCwCWAQAsAAQKfyAAAw4ACAiNH7AWALYCAA4ABwgdIrAWALYCAAQABwgDHy4pADQCAAAA.',['村里']='村里最甜橙子:BAAALAAECgYICwAAAA==.',['来支']='来支烟:BAAALAAFFAEIAQAAAA==.',['查理']='查理帕菊花:BAAALAADCgYIBgAAAA==.',['桑德']='桑德兰:BAAALAAECgYIBgAAAA==.',['樱桃']='樱桃肥肥子:BAAALAADCggICAAAAA==.',['欠债']='欠债叁仟婉:BAAALAAECgMIAwAAAA==.',['此子']='此子斷不可留:BAABLAAECn8WAAQYAAYInhCeNAAsAQAYAAYIFgieNAAsAQAZAAYIagyqLwAAAQALAAMIzxOZkwDAAAAAAA==.',['死因']='死因不明:BAAALAAECgcIBwAAAA==.',['死神']='死神永生:BAABLAAECn8eAAILAAYIHSQUQwB4AgALAAYIHSQUQwB4AgAAAA==.死神的学徒:BAAALAAECggICAAAAA==.',['殇丨']='殇丨煽情:BAABLAAFFH8aAAICAAUI0x7aHwBpAQACAAUI0x7aHwBpAQAAAA==.',['段誉']='段誉:BAABLAAFFH8KAAIBAAYILBciLQBmAQABAAYILBciLQBmAQAAAA==.',['水草']='水草:BAAALAAECgYIEAABLAAECgYIOAAFAMwbAA==.',['江听']='江听潮:BAACLAAFFH8pAAMWAAcI5hx4BABZAgAWAAcI5hx4BABZAgAaAAEIXwDoEAA2AAAsAAQKfyUAAxYACAiDFjAVAOkBABYACAiDFjAVAOkBABoABwjNGaADALsBAAAA.',['河南']='河南保安:BAACLAAFFH8gAAMbAAYIuRwnAQCvAQAbAAYIDxwnAQCvAQAIAAUIexDdDQAvAQAsAAQKfxoAAxsACAjAIiICAAoDABsACAhCISICAAoDAAgAAggEHboeAKkAAAEsAAUUBwgLAAgAHBgA.',['泰罗']='泰罗:BAAALAAECgYIDAAAAA==.',['泼猴']='泼猴:BAAALAAECggICAAAAA==.',['洋哥']='洋哥:BAABLAAFFH8KAAMcAAYIbQnjDAD4AAAcAAYIIgbjDAD4AAAdAAMIRAx0GgBqAAAAAA==.',['活力']='活力鱼串:BAAALAADCgEIAQAAAA==.',['浅夏']='浅夏凉末:BAAALAAECgYIDgAAAA==.',['深兰']='深兰妹妹:BAAALAAFFAIIBAAAAA==.深兰姐姐:BAAALAAFFAIIAgAAAA==.',['清水']='清水谷龙华:BAAALAADCgQIBAAAAA==.',['游泳']='游泳的蝌蚪:BAABLAAFFH8NAAILAAYI9whYPwA9AQALAAYI9whYPwA9AQABLAAFFAYIEAAMAH4HAA==.',['湖水']='湖水清浅:BAAALAAECggICAAAAA==.',['湖露']='湖露华:BAAALAAECgMIAwABLAAECggICAARAAAAAA==.',['漠北']='漠北:BAAALAAECgQIBAAAAA==.',['漪梦']='漪梦:BAAALAAECgUIBQAAAA==.',['潘泽']='潘泽尔:BAAALAADCgIIAgAAAA==.',['火盛']='火盛红:BAAALAAECgYICQAAAA==.',['灬尾']='灬尾巴:BAAALAAFFAEIAQAAAA==.',['灬达']='灬达达里奥灬:BAAALAAECgEIAQAAAA==.',['炮姐']='炮姐的逆袭:BAAALAAECgQIBAAAAA==.',['炽荧']='炽荧:BAAALAAECgUIBAAAAA==.',['烜赫']='烜赫大梁城:BAAALAAECgYIDAAAAA==.',['烟丶']='烟丶:BAABLAAFFH8TAAMVAAYItgBUZgARAAAVAAYItgBUZgARAAAPAAYIMgBsPAAEAAAAAA==.',['無間']='無間之鐘:BAABLAAFFH8HAAMUAAcIrA6+GAATAQAUAAUIuBC+GAATAQAJAAIIJBFCOQCHAAAAAA==.',['焦买']='焦买奇:BAAALAAECgIIAgAAAA==.',['然然']='然然:BAABLAAFFH8HAAIMAAYI9BZ9IwAoAQAMAAYI9BZ9IwAoAQABLAAFFAgIAQARAAAAAA==.',['熊喵']='熊喵先生:BAAALAADCgcIDAAAAA==.',['熊悟']='熊悟空旳焽:BAAALAAECgYICwAAAA==.',['爱上']='爱上天使:BAABLAAECn8WAAIeAAYIQAngGwClAAAeAAYIQAngGwClAAAAAA==.',['爱吃']='爱吃冰淇淋:BAABLAAFFH8GAAIGAAIIPxrUDQBUAAAGAAIIPxrUDQBUAAABLAAFFAUIKQAEAAIfAA==.',['特昂']='特昂糖:BAAALAAECgYIBgAAAA==.',['狂犬']='狂犬艾莉丝:BAAALAAFFAIIBAAAAA==.',['狐假']='狐假狐威:BAAALAADCgIIAgAAAA==.',['独狼']='独狼猎手:BAAALAAFFAIIBAAAAA==.',['独钓']='独钓韩江:BAAALAAECgQIAgAAAA==.',['狸狸']='狸狸我呀:BAABLAAFFH8WAAICAAUIRB9tEgAnAQACAAUIRB9tEgAnAQAAAA==.',['猛爪']='猛爪:BAACLAAFFH8LAAIfAAUIUxJ3BgAuAQAfAAUIUxJ3BgAuAQAsAAQKfx0AAh8ABwibFeYOAEMBAB8ABwibFeYOAEMBAAAA.',['猪猪']='猪猪在飞天:BAAALAAECgYIDgAAAA==.猪猪小侠:BAAALAAECgYIEAAAAA==.猪猪的法神:BAAALAAECgYICwAAAA==.',['猫咪']='猫咪只微笑:BAAALAAECgcIEQAAAA==.',['猫猫']='猫猫强尼:BAABLAAFFH8GAAINAAII9iONIQDIAAANAAII9iONIQDIAAAAAA==.',['獦狚']='獦狚:BAAALAAECgcIDQAAAA==.',['王走']='王走:BAABLAAFFH8FAAICAAUIlyDJFwCUAQACAAUIlyDJFwCUAQABLAAFFAYIDQAHABIiAA==.',['玛嘉']='玛嘉烈临光:BAABLAAFFH8IAAICAAUImQu+LgAQAQACAAUImQu+LgAQAQAAAA==.',['玫瑰']='玫瑰蔷薇:BAAALAAECgUIBQAAAA==.',['琉风']='琉风:BAABLAAECn8WAAINAAgIzxvOGwAVAgANAAgIzxvOGwAVAgAAAA==.',['生活']='生活大爆炸:BAAALAAFFAIIAgAAAA==.',['电与']='电与火之歌:BAAALAAECgcIBwAAAA==.',['电动']='电动锤子:BAAALAAECgIIAgAAAA==.',['电眼']='电眼妹妹:BAAALAAFFAIIAgAAAA==.电眼姐姐:BAAALAAECgUIBwAAAA==.',['界临']='界临:BAAALAAFFAYIBAAAAA==.',['疯狂']='疯狂小萝莉:BAAALAADCgMIAwAAAA==.疯狂的豆沙包:BAABLAAECn89AAMNAAYIphsNKQDGAQANAAYIphsNKQDGAQAMAAUIygrYVwCyAAAAAA==.',['白云']='白云苍狗:BAAALAADCgIIAgAAAA==.',['白水']='白水煮一切:BAAALAAECgYIBwAAAA==.',['盛夏']='盛夏的天空:BAAALAADCgMIAwAAAA==.',['看不']='看不到我:BAAALAADCggICAAAAA==.',['瞌睡']='瞌睡的朵仔:BAAALAAFFAIIBAAAAA==.',['短发']='短发梁咏琪:BAAALAADCgYIBgAAAA==.',['矮个']='矮个子骑士:BAAALAAFFAIIBAAAAA==.',['砥砺']='砥砺前行:BAAALAADCgIIAgAAAA==.',['破阵']='破阵斩将:BAAALAADCgUIBQAAAA==.',['碎魂']='碎魂夺心:BAAALAAECgIIAgAAAA==.',['祉丨']='祉丨龍:BAAALAADCgcIBwAAAA==.',['祖吼']='祖吼:BAAALAAFFAIIAgAAAA==.',['神奇']='神奇小正正:BAAALAADCggIDgAAAA==.',['神码']='神码骑势:BAACLAAFFH8TAAICAAUIgg7+QwCIAAACAAUIgg7+QwCIAAAsAAQKfxoAAwIABgg+HPg5ALABAAIABgg+HPg5ALABACAABggmAZBxAGIAAAAA.',['福克']='福克:BAAALAADCgUIBQAAAA==.',['福杯']='福杯滿溢:BAAALAAECgMIAwAAAA==.',['科洛']='科洛:BAAALAAECgMIAwAAAA==.',['秦艽']='秦艽三钱:BAABLAAECn8XAAMMAAgIZAvdaQB9AQAMAAcIvQzdaQB9AQANAAgIUwlivAALAQAAAA==.',['立华']='立华奏:BAABLAAFFH8IAAIOAAIIiCSZKgDUAAAOAAIIiCSZKgDUAAABLAAFFAYIIwAWAOkcAA==.',['笨笨']='笨笨跳跳:BAAALAADCgIIAgAAAA==.',['紫葳']='紫葳:BAAALAAECgYIBgAAAA==.',['红绳']='红绳为谁系:BAAALAAECgQIBAAAAA==.',['红颜']='红颜玫瑰:BAAALAAECgYIBwAAAA==.',['纳兰']='纳兰风:BAABLAAFFH8QAAINAAUIhAsdMQDnAAANAAUIhAsdMQDnAAAAAA==.',['绚辉']='绚辉龙:BAAALAAFFAIIAgAAAA==.',['绝境']='绝境之光:BAABLAAFFH8OAAICAAII0B+5MgCoAAACAAII0B+5MgCoAAAAAA==.',['维拉']='维拉:BAABLAAFFH8IAAIKAAIIEBNoTQCPAAAKAAIIEBNoTQCPAAAAAA==.',['缘妙']='缘妙不可言:BAACLAAFFH8NAAICAAIIThebSQCXAAACAAIIThebSQCXAAAsAAQKfxkAAgIABwieHOpXAD0CAAIABwieHOpXAD0CAAAA.',['罴人']='罴人:BAAALAAECgIIAgAAAA==.',['老娘']='老娘跟你姘了:BAAALAAFFAIIAgAAAA==.',['老顽']='老顽固:BAAALAAECgMIAwAAAA==.',['聖丨']='聖丨焱:BAAALAADCgIIAgAAAA==.',['聖箭']='聖箭丶:BAAALAAFFAEIAQAAAA==.',['背叛']='背叛了:BAAALAAECgYIBgAAAA==.',['自摸']='自摸二饼:BAAALAADCgYIBwAAAA==.',['自然']='自然小龟:BAAALAAECgYICAAAAA==.',['自由']='自由之徳:BAAALAAECgUICQAAAA==.',['航空']='航空报国:BAAALAAECgYICwAAAA==.',['艾力']='艾力克斯:BAAALAAECggICAAAAA==.',['艾格']='艾格玟:BAABLAAFFH8OAAIDAAMIDhRODwBpAAADAAMIDhRODwBpAAAAAA==.',['芋儿']='芋儿丶排骨:BAAALAAECggICAAAAA==.',['芙琳']='芙琳吉拉:BAAALAAFFAIIAgAAAA==.',['花椒']='花椒:BAAALAAFFAIIAgAAAA==.花椒丶伊利蛋:BAABLAAFFH8GAAIKAAYIqxMQIQB8AQAKAAYIqxMQIQB8AQAAAA==.',['花肚']='花肚兜:BAAALAADCgMIAwAAAA==.',['芷殇']='芷殇:BAAALAADCgYIBgAAAA==.',['苏毅']='苏毅:BAAALAADCgIIAgAAAA==.',['苏神']='苏神:BAAALAAFFAQIBAAAAA==.',['茹清']='茹清风:BAAALAAFFAIIAgAAAA==.',['草莓']='草莓大馒头:BAABLAAFFH8TAAIHAAYIOiI/EQAAAgAHAAYIOiI/EQAAAgAAAA==.',['荧荧']='荧荧:BAAALAAFFAQIAwAAAA==.荧荧小满:BAAALAAECgYIBgAAAA==.',['荷妹']='荷妹七号:BAABLAAFFH8HAAINAAII0R3SQwCaAAANAAII0R3SQwCaAAABLAAFFAIICAAEAK8IAA==.荷妹二号:BAAALAAFFAIIAgABLAAFFAIICAAEAK8IAA==.荷妹五号:BAACLAAFFH8IAAIEAAIIrwiLKABqAAAEAAIIrwiLKABqAAAsAAQKfxwAAgQABghiFTsfAEwBAAQABghiFTsfAEwBAAAA.',['莉亚']='莉亚影歌:BAAALAAECgMICAAAAA==.',['莉莉']='莉莉玛莲:BAAALAADCgIIBAAAAA==.',['莫斯']='莫斯提马:BAABLAAFFH8GAAIQAAYIGh6qBABbAgAQAAYIGh6qBABbAgAAAA==.',['萌新']='萌新小奥法:BAABLAAFFH8KAAIQAAUImx9fKgBoAQAQAAUImx9fKgBoAQAAAA==.',['萨丨']='萨丨满:BAABLAAECn8pAAMfAAYIihnXCwB/AQAfAAYIThnXCwB/AQAeAAYInRJQEgAUAQAAAA==.',['萨莱']='萨莱因:BAAALAADCgEIAQAAAA==.',['蒂丶']='蒂丶珐:BAAALAAECgYIEgAAAA==.',['薄情']='薄情于痴:BAAALAAECgQIBgAAAA==.',['蚍蜉']='蚍蜉星君:BAAALAAECgYIDAAAAA==.',['蛋白']='蛋白质的忧伤:BAAALAAECgYIBwAAAA==.',['蛋蛋']='蛋蛋滴忧伤:BAAALAAECgMIAwAAAA==.',['血之']='血之审判:BAAALAAECgYIBgAAAA==.',['血色']='血色的逆袭:BAAALAAECgUIBQAAAA==.',['裙子']='裙子又丟了:BAAALAAECgQIBQAAAA==.',['西西']='西西妹:BAABLAAFFH8SAAINAAYI6gt/KAAfAQANAAYI6gt/KAAfAQAAAA==.',['言午']='言午枫:BAABLAAECn8ZAAICAAYIrxWqVQBfAQACAAYIrxWqVQBfAQAAAA==.',['謎鸦']='謎鸦:BAAALAAECgYICgAAAA==.',['许愿']='许愿池的岛:BAAALAAECgYIBgAAAA==.',['诺飞']='诺飞雪:BAAALAAECgMIBAAAAA==.',['谷德']='谷德茂宁:BAAALAAFFAYIAwAAAA==.',['豬豬']='豬豬在飛天:BAAALAAECgMIAwAAAA==.',['賀導']='賀導演:BAAALAAFFAIIAgAAAA==.',['赫敏']='赫敏:BAAALAAECgMIAwAAAA==.',['越过']='越过那山丘:BAAALAAECgQIBAAAAA==.',['跟我']='跟我走:BAAALAAECgIIAgAAAA==.',['路以']='路以南:BAAALAAECgEIAQAAAA==.',['路易']='路易威登:BAAALAAECgYICAAAAA==.',['轩哥']='轩哥武僧一:BAAALAAFFAgIAgAAAA==.',['转身']='转身碰到頭:BAAALAAECgcIBwAAAA==.',['进去']='进去没:BAAALAAECgEIAQAAAA==.',['追忆']='追忆旧梦丶:BAAALAAECgYIEAAAAA==.',['逆风']='逆风的流云:BAAALAAFFAIIBAAAAA==.',['這有']='這有个法爷:BAAALAADCgQIBAAAAA==.',['酱油']='酱油嚓:BAABLAAECn8hAAMcAAYIQhf0LgCWAQAcAAYIQhf0LgCWAQAhAAEI0AbMVgAmAAAAAA==.',['金巨']='金巨星:BAAALAAECgQIBAAAAA==.',['钕大']='钕大十八变:BAAALAAECgYIDAAAAA==.',['钟鼓']='钟鼓乐之:BAABLAAFFH8JAAIJAAYIRQ7PGwBLAQAJAAYIRQ7PGwBLAQAAAA==.',['银月']='银月城保安:BAABLAAFFH8LAAIIAAcIHBjoAwAGAgAIAAcIHBjoAwAGAgAAAA==.',['长门']='长门有希:BAACLAAFFH8OAAIQAAMIzRXEKADwAAAQAAMIzRXEKADwAAAsAAQKfxYAAhAABggAI2xAAEoCABAABggAI2xAAEoCAAEsAAUUBQgPAAIA1iAA.',['闖禍']='闖禍的阿淼:BAAALAAECggIDAAAAA==.',['闪烁']='闪烁:BAAALAAECgcICwAAAA==.',['阳光']='阳光玫瑰:BAAALAAECgUIBQAAAA==.',['阿克']='阿克玛:BAAALAAECgUIBQAAAA==.阿克苏曲沃:BAAALAAECgQIAgAAAA==.',['陆沉']='陆沉的小兔子:BAAALAAECgQIBAAAAA==.',['陈沦']='陈沦:BAABLAAFFH8JAAIcAAYIjAatDgC9AAAcAAYIjAatDgC9AAAAAA==.陈沦丶:BAABLAAFFH8RAAILAAgI3xCoNABpAQALAAgI3xCoNABpAQAAAA==.',['随便']='随便逛逛把:BAAALAAECgUIBQAAAA==.',['雙子']='雙子座娃娃:BAAALAAECgYIBgAAAA==.',['雪碧']='雪碧真酷:BAABLAAFFH8GAAIHAAYINg8sPQBPAQAHAAYINg8sPQBPAQAAAA==.',['雪花']='雪花飘扬:BAAALAAECgIIAgAAAA==.',['零度']='零度萌萌哒:BAABLAAFFH8fAAIQAAcI7RmTEQDsAQAQAAcI7RmTEQDsAQAAAA==.',['雷大']='雷大腰不停:BAAALAAECgUIBQAAAA==.',['霍格']='霍格沃兹:BAAALAADCgYIBgAAAA==.',['霜之']='霜之艾伤:BAAALAAECgQICAAAAA==.',['青丝']='青丝雪墨丶:BAAALAAECgIIAgAAAA==.',['青衫']='青衫故人:BAAALAAECgEIAQAAAA==.',['颤栗']='颤栗龙卷:BAAALAAFFAIIBAAAAA==.',['风之']='风之行者:BAABLAAECn8xAAMSAAYIqCWIGwCIAgASAAYIqCWIGwCIAgAHAAQIVR+j1wBhAQAAAA==.',['风伤']='风伤雨:BAAALAAFFAIIAgAAAA==.',['风影']='风影之舞:BAAALAAECgIIAgAAAA==.',['风情']='风情万种:BAAALAADCgIIAgAAAA==.',['风暴']='风暴的岚鬃:BAAALAAECgYIAgAAAA==.',['风羽']='风羽月:BAAALAADCgIIAgAAAA==.',['风行']='风行影风:BAAALAAECgYICQAAAA==.风行殇云:BAABLAAECn8fAAILAAYIxB0OdQANAgALAAYIxB0OdQANAgAAAA==.',['风雪']='风雪之神:BAAALAADCgEIAQAAAA==.风雪来过:BAAALAAECgMIAwAAAA==.',['飓嘿']='飓嘿丶丶:BAAALAAECggICAAAAA==.',['饭丸']='饭丸:BAAALAAECgUIBQAAAA==.',['饭团']='饭团:BAAALAAECgYICAAAAA==.',['饭盒']='饭盒:BAAALAAFFAIIAwAAAA==.',['饭碗']='饭碗:BAAALAAFFAIIAgAAAA==.',['饭粒']='饭粒:BAAALAAFFAIIBAAAAA==.',['饭萌']='饭萌萌:BAAALAAECgIIAgABLAAECgYIBwARAAAAAA==.',['饭饭']='饭饭吃抱抱:BAAALAAECggICAABLAAFFAYIDQAHABIiAA==.',['馒头']='馒头有毒:BAAALAAFFAMIAwABLAAFFAUIKQAEAAIfAA==.',['香菇']='香菇无盐:BAAALAAECgYICAAAAA==.',['马论']='马论:BAABLAAFFH8SAAIJAAgI6RuhAwCIAgAJAAgI6RuhAwCIAgAAAA==.',['骑你']='骑你头上:BAAALAAFFAEIAQAAAA==.',['鬼迷']='鬼迷星窍:BAACLAAFFH8aAAMBAAUIfxrlIAAbAQABAAUIfxrlIAAbAQAGAAEIUiAAJABWAAAsAAQKfyMAAwEACAgBIVEuAIUCAAEABwidIVEuAIUCAAYAAQi+HJOLAFYAAAAA.',['魂断']='魂断残阳:BAABLAAFFH8KAAIKAAIIkRzEPQCbAAAKAAIIkRzEPQCbAAAAAA==.',['魂烬']='魂烬:BAAALAAECgYIBgAAAA==.',['魑魅']='魑魅罔两:BAAALAAECgYIEQAAAA==.魑魅迷惘:BAABLAAECn8UAAIHAAYIrxUEywBxAQAHAAYIrxUEywBxAQAAAA==.',['魔兽']='魔兽世界:BAAALAAECgYIDAAAAA==.',['魔法']='魔法大苗:BAABLAAFFH8GAAMDAAIIthcoDwCSAAADAAIIthcoDwCSAAAQAAIINgluVwCJAAAAAA==.',['魔魔']='魔魔:BAAALAAECgQIBAABLAAECgYIOAAFAMwbAA==.魔魔的小帽子:BAAALAAECgMIAwABLAAECgYIOAAFAMwbAA==.魔魔的小眉毛:BAABLAAECn84AAIFAAYIzBtEHADbAQAFAAYIzBtEHADbAQAAAA==.魔魔的小酒窝:BAAALAAECgYIBgABLAAECgYIOAAFAMwbAA==.魔魔的骑士:BAAALAAECgYIBgABLAAECgYIOAAFAMwbAA==.',['麒麟']='麒麟臀:BAABLAAFFH8RAAILAAYIMx5KIQCvAQALAAYIMx5KIQCvAQAAAA==.',['麟小']='麟小枫:BAAALAAECgUIBQAAAA==.',['麦克']='麦克奎恩:BAABLAAFFH8KAAQHAAIIsRviXgCMAAAHAAIIyw7iXgCMAAAiAAEIPCIuBwBeAAASAAEIDxE1NQBAAAAAAA==.',['麻三']='麻三豆:BAABLAAECn8+AAIZAAYI4hMnFwAbAQAZAAYI4hMnFwAbAQAAAA==.',['麻花']='麻花丶:BAAALAAFFAQIBAAAAA==.',['黄桃']='黄桃安慕希:BAAALAAECgMIAwAAAA==.',['黑色']='黑色帕拉丁:BAABLAAFFH8LAAICAAUIBQzZMAD+AAACAAUIBQzZMAD+AAAAAA==.',['黑莓']='黑莓糖糖:BAAALAAECgYIBwAAAA==.',['黑鸟']='黑鸟:BAAALAAECgYIDAAAAA==.',['默默']='默默然:BAAALAAFFAIIAgAAAA==.',['龍霄']='龍霄九淵:BAAALAAECgYIBwAAAA==.',['龙之']='龙之翼:BAAALAAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end