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
 local lookup = {'Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Mage-Frost','Monk-Mistweaver','Unknown-Unknown','Warlock-Affliction','Druid-Restoration','Evoker-Preservation','Evoker-Devastation','Paladin-Protection','Priest-Shadow','Warlock-Destruction','Warrior-Fury','Mage-Fire','DemonHunter-Havoc','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Warrior-Protection','Warrior-Arms','Rogue-Assassination','Paladin-Holy','Monk-Windwalker','Druid-Guardian','Shaman-Enhancement','Mage-Arcane','Warlock-Demonology','DemonHunter-Vengeance','Rogue-Subtlety','DeathKnight-Frost',}; local provider = {region='CN',realm='阿曼尼',name='CN',type='weekly',zone=42,date='2025-08-03',data={Am='Amuro:BAAAKgAECggICAAAAA==.',Ap='Applebull:BAAAKgAECggICwAAAA==.',Ar='Aryastark:BAAAKgADCgYIBgAAAA==.',At='Ataraxia:BAAAKgAECggIEgAAAA==.',Ba='Back:BAAAKgAFFAQIBAAAAA==.',Bl='Blablaa:BAAAKgAECgUIBQAAAA==.Bloodeun:BAAAKgADCggICAABKgAFFAgIDwABAM4XAA==.',Ca='Cadenza:BAAAKgAECgYIDAAAAA==.',Eg='Eggz:BAAAKgADCgEIAQAAAA==.',Em='Emo:BAAAKgAECggICAAAAA==.',Fe='Fez:BAAAKgAECgcIEQAAAA==.',Ge='Genz:BAAAKgAECggICAAAAA==.',Gl='Glorious:BAABKgAFFH8HAAMCAAUICAUMLADdAAACAAUI3gQMLADdAAADAAII6gfrNAAnAAAAAA==.',Gr='Grazia:BAAAKgAECgIIAgAAAA==.',Gu='Gulden:BAAAKgAECgUIBQAAAA==.',Ke='Keiko:BAAAKgAFFAIIBAAAAA==.',Ky='Kyouxm:BAAAKgADCggICAAAAA==.',La='Lalalanda:BAAAKgADCgIIAgAAAA==.',Ma='Mable:BAAAKgAECggICwAAAA==.Madeinchina:BAABKgAFFH8GAAIEAAYIoCD+EwC8AQAEAAYIoCD+EwC8AQAAAA==.',Mi='Mizuu:BAAAKgAECgIIAgAAAA==.',Ni='Ninety:BAAAKgAFFAQIBAAAAA==.',Pa='Patspring:BAAAKgAFFAYIBAAAAA==.',Ph='Phoebe:BAABKgAFFH8KAAIFAAQISCL6CgAqAQAFAAQISCL6CgAqAQAAAA==.',Qi='Qiyi:BAABKgAFFH8FAAIGAAMIhg0AGAClAAAGAAMIhg0AGAClAAAAAA==.',Ru='Rubydd:BAAAKgAECggICAAAAA==.',Ry='Ryann:BAAAKgAECggICAABKgAFFAgIEwAHAHMfAA==.',Se='Serenata:BAABKgAECn8jAAIIAAgIORoCJwDiAQAIAAgIORoCJwDiAQAAAA==.',Si='Sickcarrot:BAAAKgADCggICAAAAA==.',Su='Sunlv:BAAAKgAECggIEAAAAA==.',Ti='Titansange:BAABKgAFFH8GAAICAAYI/RykDwCiAQACAAYI/RykDwCiAQAAAA==.',Ty='Typhoonn:BAAAKgADCgQIBAAAAA==.',Xi='Xinuser:BAAAKgAECggIDwAAAA==.',Zi='Ziel:BAAAKgADCggICAAAAA==.',['一只']='一只中脉动:BAAAKgADCgEIAQAAAA==.一只大脉动:BAAAKgAECgYICQAAAA==.一只老脉动:BAAAKgAECgYICQAAAA==.',['一射']='一射到底:BAAAKgAECgYIBgAAAA==.',['一抹']='一抹丿涟漪:BAAAKgAECgcICQAAAA==.',['一支']='一支箭丶:BAAAKgAECgcICAAAAA==.',['七妹']='七妹:BAAAKgAECgEIAQAAAA==.',['万恶']='万恶的骑士:BAABKgAFFH8GAAICAAYIYgruDAAuAQACAAYIYgruDAAuAQAAAA==.',['三文']='三文鱼:BAABKgAFFH8GAAIDAAYIewiiGADcAAADAAYIewiiGADcAAAAAA==.',['三英']='三英战貂禅:BAAAKgAECggIEAAAAA==.',['不会']='不会无敌:BAAAKgAECggIEAAAAA==.',['不动']='不动脑的老白:BAAAKgAECgYICAAAAA==.',['不坦']='不坦不奶不打:BAAAKgAECgUIBgAAAA==.',['不能']='不能說的秘密:BAAAKgAECggIDgAAAA==.',['丨残']='丨残美丶:BAAAKgAECgIIAgAAAA==.',['丶年']='丶年几何:BAABKgAFFH8GAAIEAAYIaBmQGACYAQAEAAYIaBmQGACYAQAAAA==.',['丶晚']='丶晚枫:BAAAKgAECgUIBgAAAA==.',['丶欧']='丶欧气重重丶:BAABKgAFFH8TAAICAAgIhBK4CAADAgACAAgIhBK4CAADAgAAAA==.',['丶洛']='丶洛神賦:BAAAKgAECggIEAAAAA==.',['丶紫']='丶紫气东来:BAABKgAFFH8IAAMCAAQIaxSzHQAxAQACAAQINxGzHQAxAQADAAQIswyqFQD0AAAAAA==.',['丶纠']='丶纠结丶:BAAAKgAFFAMIAgAAAA==.',['丶芙']='丶芙蓉王:BAABKgAFFH8HAAMCAAcIjA2eKADrAAACAAMIiBWeKADrAAADAAQIkAUVLABkAAAAAA==.',['丶阿']='丶阿丿寳丶:BAABKgAFFH8KAAIJAAMIKB6cFAACAQAJAAMIKB6cFAACAQAAAA==.',['丿依']='丿依橪尘路灬:BAAAKgADCggICwAAAA==.',['丿尘']='丿尘路灬:BAAAKgADCgMIAwABKgADCggICwAKAAAAAA==.',['丿蜂']='丿蜂蜜柠檬茶:BAAAKgAECgMIAwAAAA==.',['么么']='么么大王:BAAAKgAFFAQIBAABKgAFFAgIRQALAEclAA==.',['九尾']='九尾:BAAAKgAECgEIAQAAAA==.',['买不']='买不起牛奶:BAAAKgAECgMIAwAAAA==.',['五鬼']='五鬼天魔:BAABKgAFFH8GAAMCAAQIARJfFwDYAAACAAQI3hFfFwDYAAADAAEIBQiUJgAvAAAAAA==.',['亲缺']='亲缺德么:BAACKgAFFH8nAAIMAAUIjxv7BgBFAQAMAAUIjxv7BgBFAQAqAAQKfywAAgwACAjwIFoQACcCAAwACAjwIFoQACcCAAAA.',['人形']='人形决战兵器:BAAAKgADCggICAAAAA==.',['人龙']='人龙小:BAABKgAECn8YAAMNAAgIQBgHBwC+AQANAAgIQBgHBwC+AQAOAAYI/gd8TACfAAAAAA==.',['仁者']='仁者無敵:BAABKgAFFH8IAAMEAAgIfR1MEQDTAQAEAAYIBh1MEQDTAQAPAAIIph7gHACTAAAAAA==.',['今晚']='今晚去打猎:BAAAKgAECggICgAAAA==.',['从零']='从零开始射击:BAAAKgADCgMIAwAAAA==.',['以圣']='以圣光之名丶:BAABKgAFFH8GAAIQAAYIeAXzEAD8AAAQAAYIeAXzEAD8AAABKgAFFAgIDgARAPkhAA==.',['伊利']='伊利丶丹:BAAAKgADCggIAgAAAA==.',['伊苏']='伊苏史迪奇:BAAAKgADCgUIBQAAAA==.伊苏苏的起源:BAAAKgAECgUIBQAAAA==.',['伍号']='伍号推土机:BAAAKgAFFAMIAwAAAA==.',['佛系']='佛系丨劣人:BAAAKgAECggICAAAAA==.',['你先']='你先听我说:BAAAKgADCgMIAwAAAA==.',['佩佩']='佩佩妮妮:BAAAKgAECgIIAgAAAA==.',['信仰']='信仰:BAAAKgADCgEIAgAAAA==.',['倾城']='倾城偶赏马:BAABKgAECn8WAAIEAAgIwB6wLgBFAgAEAAgIwB6wLgBFAgAAAA==.',['傲气']='傲气刺魂:BAAAKgAFFAgIBAAAAA==.傲气猎魂:BAAAKgAFFAQIBAAAAA==.',['傻僈']='傻僈:BAAAKgADCgIIAgAAAA==.',['先锋']='先锋丶盾:BAAAKgAFFAgIBAAAAA==.',['六爷']='六爷张:BAABKgAFFH8LAAISAAQIeQ/GIwDDAAASAAQIeQ/GIwDDAAAAAA==.',['冰糖']='冰糖葫璐娃娃:BAAAKgAECggIEQAAAA==.',['冰羿']='冰羿:BAAAKgADCggICAAAAA==.',['冰翎']='冰翎:BAAAKgAECgUIBgAAAA==.',['冰鳞']='冰鳞:BAAAKgAECgUIBQAAAA==.',['凌浩']='凌浩:BAAAKgADCgYIBgAAAA==.',['凯恩']='凯恩的呼唤:BAAAKgAFFAIIAgAAAA==.',['初霁']='初霁亦微暖丶:BAABKgAFFH8LAAMCAAgI5xCxBgDtAQACAAgIyQ+xBgDtAQADAAMIkQUYIQBXAAAAAA==.',['别摧']='别摧毁物品:BAAAKgADCgMIBgAAAA==.',['前世']='前世情人丶:BAAAKgAFFAEIAQAAAA==.',['剑来']='剑来丶阮秀:BAABKgAECn8XAAMIAAgIyRZ0MACyAQAIAAgIyRZ0MACyAQATAAEIrAQJpwAhAAAAAA==.',['加可']='加可能:BAABKgAFFH8FAAIUAAUIJB8EGwAnAQAUAAUIJB8EGwAnAQAAAA==.',['十三']='十三香奶黄包:BAABKgAFFH8FAAIUAAUIpyWzIQD5AAAUAAUIpyWzIQD5AAAAAA==.',['半个']='半个句号:BAABKgAFFH8OAAIGAAgIPR6MAgCKAgAGAAgIPR6MAgCKAgAAAA==.',['卓凛']='卓凛昭:BAABKgAFFH8GAAIJAAIItRpYIgCZAAAJAAIItRpYIgCZAAAAAA==.',['南方']='南方的雪:BAABKgAECn8VAAMRAAgIPSJDFgA+AgARAAgIPSJDFgA+AgALAAEIbRXkQQA/AAAAAA==.',['印第']='印第安老斑鳩:BAAAKgAECggIEQAAAA==.',['压迫']='压迫灬众生:BAAAKgAFFAIIAgAAAA==.',['又又']='又又的小龙人:BAABKgAFFH8rAAMOAAgIChXBDgB0AQAOAAgIChXBDgB0AQANAAEIAAB9CAAAAAAAAA==.又又的戒指:BAABKgAFFH8OAAMVAAMIpRoMKADWAAAVAAMIpRoMKADWAAAWAAMI3w8GFwC8AAAAAA==.又又的花瓶:BAABKgAFFH8MAAMXAAMIcxIvFACcAAAXAAMIEQ8vFACcAAABAAEI4wpgFgAzAAAAAA==.又又的钱袋:BAACKgAFFH8HAAIYAAMI0wMCEgBsAAAYAAMI0wMCEgBsAAAqAAQKfxQABBgACAhLEqomAM0AABgACAirC6omAM0AABkAAwgeEjJPAI4AABIAAQhMFt80AEgAAAAA.',['叉叉']='叉叉兽:BAAAKgADCgEIAQAAAA==.叉叉牛:BAAAKgADCgYIBwAAAA==.叉叉零:BAAAKgADCgEIAQAAAA==.',['变身']='变身吧妞:BAAAKgAECgMIAwAAAA==.',['右脸']='右脸:BAAAKgADCgYIBgAAAA==.',['后巷']='后巷奶茶:BAAAKgAECgYIBwAAAA==.后巷茉莉茶:BAABKgAECn8UAAIEAAgIySFpHQCjAgAEAAgIySFpHQCjAgAAAA==.',['向日']='向日葵:BAAAKgAECgUICgAAAA==.',['君笙']='君笙拂兮:BAAAKgAECggIEgABKgAFFAgICgAFAEgiAA==.',['吸橙']='吸橙器:BAAAKgAECgcIBQAAAA==.',['吾道']='吾道随心:BAAAKgAFFAgIBAAAAA==.',['咆哮']='咆哮的小恶魔:BAAAKgAECggIDwAAAA==.',['唧歪']='唧歪:BAAAKgAECgMIAwAAAA==.',['啥活']='啥活能干:BAAAKgAECgIIAgAAAA==.',['啵啵']='啵啵咪:BAAAKgAECggICAAAAA==.',['善良']='善良的大白牛:BAABKgAFFH8KAAMZAAYIwhZhCgBmAQAZAAUIsBZhCgBmAQASAAQIdhKqIgDIAAAAAA==.',['嗜血']='嗜血开一下:BAAAKgADCggIDAAAAA==.',['嗜酒']='嗜酒小虾米:BAABKgAFFH8GAAIMAAMIWwfwEQCEAAAMAAMIWwfwEQCEAAAAAA==.嗜酒虾米:BAACKgAFFH8FAAIIAAMISQcGDgCqAAAIAAMISQcGDgCqAAAqAAQKfxQAAggACAgDEhQpAHIBAAgACAgDEhQpAHIBAAAA.',['噜啦']='噜啦啦憨哟:BAABKgAFFH8GAAIPAAYIDQm5EwDcAAAPAAYIDQm5EwDcAAAAAA==.',['囍糖']='囍糖:BAAAKgADCgMIAwAAAA==.',['土肥']='土肥:BAAAKgADCggICAAAAA==.',['圣光']='圣光战:BAABKgAECn8bAAIaAAgINxB3CwB5AQAaAAgINxB3CwB5AQAAAA==.圣光武者:BAAAKgAFFAQIAgAAAA==.圣光眷顾牛:BAABKgAFFH8nAAIEAAgI3iSzAgDFAgAEAAgI3iSzAgDFAgAAAA==.圣光骑士:BAABKgAECn8gAAIbAAgIbxmDBgDgAQAbAAgIbxmDBgDgAQAAAA==.',['在那']='在那遇到的人:BAAAKgAECgcIEAAAAA==.',['地狱']='地狱囧咆哮:BAAAKgADCgEIAQAAAA==.地狱狂怒丶:BAABKgAFFH8GAAISAAYIGg/MDQB1AQASAAYIGg/MDQB1AQAAAA==.',['坦克']='坦克手呗塔:BAABKgAFFH8GAAIEAAYINRhzIABuAQAEAAYINRhzIABuAQAAAA==.',['埃辛']='埃辛诺斯乄:BAAAKgAFFAQIBAAAAA==.',['壹号']='壹号推土机:BAABKgAECn8aAAMJAAgItgjqRQAnAQAJAAgItgjqRQAnAQAcAAQIWgnjRgCtAAAAAA==.',['复仇']='复仇化身:BAAAKgAECgEIAQAAAA==.',['夏天']='夏天丶:BAAAKgAFFAQIAwAAAA==.',['夏姐']='夏姐姐:BAAAKgAECgQIBAAAAA==.',['夜航']='夜航船:BAABKgAFFH8MAAMHAAgIMQ+RDACyAQAHAAcIEhCRDACyAQAMAAUIiwaAKQB+AAAAAA==.',['夜雨']='夜雨聽風:BAAAKgADCggICAAAAA==.',['大德']='大德鲁:BAABKgAECn8cAAIVAAgIXhnxIQD/AQAVAAgIXhnxIQD/AQAAAA==.',['大米']='大米饭:BAAAKgADCgIIAgAAAA==.',['大董']='大董来了:BAACKgAFFH8TAAISAAYIJBnbCwCNAQASAAYIJBnbCwCNAQAqAAQKfxwAAxIABgixHQsuAHsBABIABgixHQsuAHsBABkAAwgaEMxHAK8AAAAA.',['大超']='大超老师:BAAAKgAECgQIBAAAAA==.',['大領']='大領主:BAAAKgADCggICAAAAA==.',['天命']='天命:BAAAKgAECgQIBAAAAA==.',['天行']='天行九歌:BAAAKgAECggICAAAAA==.',['天道']='天道即王道:BAABKgAFFH8FAAIIAAMIOgvFDAC8AAAIAAMIOgvFDAC8AAAAAA==.',['头上']='头上有双角:BAAAKgAFFAgIBAAAAA==.',['奈白']='奈白雪子:BAAAKgAECggIDQAAAA==.',['奥格']='奥格外卖仔:BAAAKgAECggIDgAAAA==.',['妖牛']='妖牛儿:BAAAKgAECgUIBQAAAA==.',['妹在']='妹在不在:BAABKgAECn8aAAMEAAgIFxqoSADmAQAEAAgIFxqoSADmAQAPAAEIewZBaAAVAAAAAA==.',['姿势']='姿势很帅:BAAAKgAFFAgIBAAAAA==.',['嫐嫐']='嫐嫐丶:BAAAKgAFFAYIBAAAAA==.',['孙子']='孙子冰法:BAAAKgADCggIGAAAAA==.',['孙策']='孙策:BAAAKgAFFAQIBAAAAA==.',['客官']='客官丶冷静:BAAAKgAECgMIAwAAAA==.',['宽心']='宽心:BAABKgAECn8VAAICAAgI9xdbCQD8AQACAAgI9xdbCQD8AQAAAA==.',['寂寞']='寂寞术控:BAAAKgAECgcIEAAAAA==.',['寥若']='寥若星辰:BAABKgAFFH8GAAIFAAYIWSStDAClAQAFAAYIWSStDAClAQABKgAFFAgIBAAKAAAAAA==.',['小丑']='小丑皇:BAABKgAFFH8GAAIMAAYIIAK+GADaAAAMAAYIIAK+GADaAAAAAA==.',['小哼']='小哼哼:BAAAKgAECgEIAQAAAA==.',['小头']='小头爸爸:BAABKgAECn8YAAIFAAgI0hMaHACVAQAFAAgI0hMaHACVAQAAAA==.',['小小']='小小木头人:BAAAKgAECgYIBgAAAA==.小小治疗师:BAAAKgADCgQIBAAAAA==.',['小尾']='小尾巴惢惢:BAAAKgAECgUIBgAAAA==.',['小时']='小时候可白了:BAAAKgADCggIuAAAAA==.',['小桃']='小桃儿:BAAAKgAECgYICwAAAA==.',['小梅']='小梅小梅梅:BAAAKgAECgYIBgAAAA==.',['小熊']='小熊饼干:BAABKgAFFH8KAAMXAAYIxBecFQAIAQAXAAUIwxacFQAIAQAQAAEI4RYZKgBJAAAAAA==.',['小绿']='小绿人:BAAAKgAECgQIBAAAAA==.',['小虾']='小虾米:BAABKgAECn8lAAMPAAgItBLFKAAQAQAPAAgIcA/FKAAQAQAEAAgI9g1jrgDzAAAAAA==.',['小诺']='小诺:BAABKgAECn8XAAIXAAgIMhJqOgBSAQAXAAgIMhJqOgBSAQAAAA==.',['小贱']='小贱贱:BAAAKgADCggICAAAAA==.',['小阿']='小阿姨:BAABKgAFFH8GAAIEAAYIfx1QIABuAQAEAAYIfx1QIABuAQAAAA==.',['尛尾']='尛尾巴贔贔:BAAAKgAECgcIBwAAAA==.',['尾崎']='尾崎由香:BAAAKgADCgYIBgABKgAFFAgIEwAXAP0gAA==.',['峡谷']='峡谷奥德莉:BAAAKgADCgEIAQAAAA==.',['左手']='左手勾右手圈:BAABKgAECn8WAAIcAAgIhRAcJQB3AQAcAAgIhRAcJQB3AQAAAA==.',['巨物']='巨物鬼打墙:BAAAKgAECgUIBQAAAA==.',['巨狼']='巨狼芬里厄:BAAAKgAECgUIBQAAAA==.',['帕拉']='帕拉塞尔苏斯:BAAAKgAFFAYIAgAAAA==.',['常威']='常威在打来福:BAAAKgAECgcIBwAAAA==.',['平头']='平头哥:BAABKgAFFH8IAAMHAAYIGRHQHgAoAQAHAAYIMg3QHgAoAQAdAAIIbQ6FBABmAAAAAA==.',['幻紫']='幻紫轩:BAAAKgAECgIIAgABKgAFFAYICAAEAKoTAA==.',['张伯']='张伯谦:BAAAKgAECgIIAwAAAA==.',['彩虹']='彩虹的瞬间:BAABKgAFFH8MAAIEAAYIyxRTHwBzAQAEAAYIyxRTHwBzAQAAAA==.',['彻夜']='彻夜未眠:BAAAKgADCggICAAAAA==.彻夜睡眠:BAAAKgADCggICAAAAA==.',['徘徊']='徘徊于战神:BAAAKgAFFAQIBAAAAA==.徘徊于街角:BAAAKgAFFAQIBAAAAA==.',['御天']='御天使:BAABKgAFFH8FAAIEAAQIPg9xOgCUAAAEAAQIPg9xOgCUAAAAAA==.',['德儿']='德儿隆冬强:BAAAKgAECgUIBQAAAA==.',['德神']='德神姜葱蒜:BAAAKgADCggIEAAAAA==.',['心如']='心如止水:BAAAKgAFFAMIAwAAAA==.',['怀旧']='怀旧牛萨满:BAAAKgAECgQIBQAAAA==.',['性感']='性感的牛蛙:BAAAKgADCgEIAQAAAA==.',['愛寫']='愛寫在西元前:BAAAKgAECggIDAAAAA==.',['我以']='我以为:BAAAKgAFFAEIAQAAAA==.',['我要']='我要变成熊:BAAAKgAECgUIBQAAAA==.',['战无']='战无邪:BAAAKgADCgcICAAAAA==.',['战神']='战神暴暴兔:BAABKgAFFH8TAAQWAAYILCFMBQCrAQAWAAYI7B9MBQCrAQAeAAYImhBECgAsAQAVAAQIaRUZHgCjAAAAAA==.',['扉丶']='扉丶頁:BAABKgAFFH8OAAMRAAYIsxg1EQCBAQARAAYIsxg1EQCBAQALAAQIAxL3DwC4AAAAAA==.',['执念']='执念:BAAAKgAECgUIBQAAAA==.',['拖后']='拖后腿的法師:BAAAKgADCgQIBAAAAA==.',['捌号']='捌号推土机:BAABKgAFFH8GAAIIAAMIRQmODQCxAAAIAAMIRQmODQCxAAAAAA==.',['新七']='新七:BAACKgAFFH8hAAIEAAcIlSKnCAA4AgAEAAcIlSKnCAA4AgAqAAQKfxcAAgQACAguIT1LABACAAQACAguIT1LABACAAAA.',['无上']='无上自然:BAAAKgADCggICAAAAA==.',['无冕']='无冕者:BAAAKgAECgcIEAABKgAFFAYIEQAEAOwXAA==.',['无冠']='无冠者:BAACKgAFFH8RAAIEAAMI7BeUQgDqAAAEAAMI7BeUQgDqAAAqAAQKfyAAAgQACAhtGw1QAAMCAAQACAhtGw1QAAMCAAAA.',['无才']='无才有德:BAABKgAFFH8HAAIMAAMI6AxoJQCQAAAMAAMI6AxoJQCQAAAAAA==.',['明芝']='明芝月:BAAAKgADCgMIAwAAAA==.',['晓刚']='晓刚学姐:BAAAKgADCgUIBQAAAA==.',['晨曦']='晨曦亦如初见:BAABKgAECn8kAAIEAAgIESEqHgCKAgAEAAgIESEqHgCKAgAAAA==.晨曦茳祉:BAABKgAFFH8GAAIDAAYIPROFDwAqAQADAAYIPROFDwAqAQAAAA==.',['暮色']='暮色灬村萨:BAAAKgADCggICAAAAA==.暮色灬法:BAABKgAECn8aAAIIAAgIzBtMEQA8AgAIAAgIzBtMEQA8AgAAAA==.',['月亮']='月亮集合:BAAAKgAECgcIBwAAAA==.',['未来']='未来小萨萨:BAAAKgAECgcICgAAAA==.',['术神']='术神姜葱蒜:BAAAKgADCggICAAAAA==.',['朱小']='朱小滢:BAAAKgAFFAQIBAABKgAFFAgIBwAHAGwSAA==.',['机械']='机械风暴:BAAAKgAECgMIAwAAAA==.',['枪响']='枪响怪倒:BAAAKgAECggIEAAAAA==.',['柒丶']='柒丶玥灬:BAAAKgADCgEIAQAAAA==.',['柒号']='柒号推土机:BAAAKgAFFAMIAwAAAA==.',['柒柒']='柒柒大魔王:BAABKgAFFH8QAAMTAAgIqxy2BQAYAgATAAgI5hi2BQAYAgAfAAYINR9UDgCBAQAAAA==.',['柒里']='柒里香:BAAAKgAECgYIBgAAAA==.',['柠檬']='柠檬可乐:BAAAKgAECggICAAAAA==.',['格格']='格格乌:BAAAKgAECgcIBwAAAA==.格格舞:BAAAKgAECgUICAAAAA==.',['桃核']='桃核儿:BAAAKgAECgcIEAAAAA==.',['梁慕']='梁慕唐:BAAAKgADCgQIBAAAAA==.',['梦境']='梦境飘零:BAAAKgADCgEIAQAAAA==.',['楊耂']='楊耂蒒:BAAAKgAFFAQIBAAAAA==.',['樱木']='樱木花花:BAAAKgAECgcIDAAAAA==.',['樱桃']='樱桃小瘸子:BAAAKgADCgIIAgAAAA==.',['橙吟']='橙吟不语:BAAAKgAFFAIIAgAAAA==.',['橙大']='橙大牛:BAAAKgAECggICAAAAA==.',['橡皮']='橡皮尺子擦丶:BAABKgAFFH8FAAITAAUIihJGFAAYAQATAAUIihJGFAAYAQAAAA==.',['欧皇']='欧皇丶七七:BAAAKgAECgYIBgAAAA==.',['正义']='正义王冠:BAAAKgADCggICAAAAA==.',['死骑']='死骑呢:BAACKgAFFH8FAAIRAAUI1AIfHACfAAARAAUI1AIfHACfAAAqAAQKfxcAAhEACAgCFAMPAKkBABEACAgCFAMPAKkBAAAA.',['比卡']='比卡丘的愤怒:BAAAKgAECgQIBAAAAA==.',['水晶']='水晶室女:BAAAKgAFFAIIAgAAAA==.',['水鬼']='水鬼头:BAACKgAFFH8FAAISAAMIUAeiKACmAAASAAMIUAeiKACmAAAqAAQKfxQAAhIACAj+DswxAGYBABIACAj+DswxAGYBAAAA.',['江海']='江海:BAABKgAFFH8MAAIEAAYI2CFXFgCpAQAEAAYI2CFXFgCpAQAAAA==.',['污喵']='污喵王:BAAAKgAECgMIBAAAAA==.',['沙梦']='沙梦:BAABKgAFFH8GAAIIAAYIdQW2DAACAQAIAAYIdQW2DAACAQAAAA==.',['没事']='没事就玩:BAAAKgADCggICAAAAA==.',['没有']='没有智齿:BAAAKgAECgYICgAAAA==.',['油油']='油油圈:BAAAKgAECgIIAgAAAA==.',['沽酒']='沽酒问卿:BAAAKgADCggICAAAAA==.',['波尔']='波尔多斯:BAAAKgAECgUIBgAAAA==.',['波比']='波比小佑:BAAAKgAFFAEIAQAAAA==.',['洛薩']='洛薩:BAABKgAFFH8XAAMZAAYItSHHAADVAQAZAAYItSHHAADVAQASAAQIygtYFQDeAAAAAA==.',['洲舟']='洲舟:BAAAKgAECgQIBAAAAA==.',['淘小']='淘小淘:BAAAKgADCgYIBgAAAA==.',['淮南']='淮南牛肉汤:BAAAKgADCggICAAAAA==.',['清晨']='清晨睡马路:BAAAKgAECgIIAgAAAA==.',['清风']='清风挽心:BAAAKgADCgMIAwAAAA==.',['滄影']='滄影焚曦:BAAAKgAECgcIBwAAAA==.',['灬圣']='灬圣光审判灬:BAAAKgAECggIEgAAAA==.',['灬妮']='灬妮妹灬:BAAAKgAFFAQIAQAAAA==.',['灬影']='灬影灬:BAAAKgAFFAIIBAAAAA==.',['灬楊']='灬楊灬:BAAAKgAECgQICAAAAA==.',['灬楚']='灬楚歌灬:BAAAKgADCgcICgAAAA==.',['灯泡']='灯泡个灯:BAABKgAFFH8MAAIEAAgIWQlKDgC8AQAEAAgIWQlKDgC8AQAAAA==.',['烟雨']='烟雨漫天:BAABKgAECn8lAAIIAAgIshsjCQD/AQAIAAgIshsjCQD/AQAAAA==.',['烦死']='烦死个仙人:BAAAKgAECgQIBAAAAA==.',['烬绽']='烬绽霆守:BAAAKgAFFAQIBAABKgAFFAYIEQAEAOwXAA==.',['無丶']='無丶悠:BAAAKgAECgUICQAAAA==.',['煜文']='煜文宝宝:BAAAKgAECgYIBgAAAA==.',['熊貓']='熊貓時代:BAAAKgAECgQIBAAAAA==.',['燃烧']='燃烧灬大業火:BAAAKgADCggICAAAAA==.',['牡丹']='牡丹:BAAAKgAECggICAAAAA==.',['牧马']='牧马人小右:BAAAKgADCggIDQAAAA==.',['狂暴']='狂暴法爷:BAAAKgADCgMIAwAAAA==.狂暴的涌动:BAAAKgADCgMIAwAAAA==.狂暴的猩猩:BAAAKgAECgQIBAAAAA==.狂暴铁头娃:BAABKgAFFH8GAAIEAAYI1BqdGgCMAQAEAAYI1BqdGgCMAQAAAA==.',['狼丨']='狼丨魂:BAAAKgAECgEIAQAAAA==.',['猎了']='猎了个鸽:BAAAKgAECgYIBgAAAA==.',['猩猩']='猩猩的守护神:BAAAKgADCgcIBwAAAA==.',['玖号']='玖号推土机:BAACKgAFFH8KAAMXAAMIKQnNFwCBAAAXAAMI2gjNFwCBAAABAAIIYwfJFgAvAAAqAAQKfyAAAwEACAi2EL42AEEBAAEACAhxDr42AEEBABcABgj8DZBXANwAAAAA.',['玛咖']='玛咖巴咔:BAAAKgAECggICQAAAA==.',['瓜哥']='瓜哥止痛丸:BAAAKgAFFAIIAgAAAA==.',['电动']='电动小牛:BAAAKgAECgMIAwAAAA==.',['男人']='男人不怕黑:BAAAKgAFFAIIAgAAAA==.男人不怕黑嘛:BAAAKgAFFAMIBAAAAA==.',['疯狂']='疯狂的豆奶:BAABKgAECn8YAAQRAAgIFxsfFwDuAQARAAgIFxsfFwDuAQALAAYINBITGgAfAQAgAAIINwR5MwAcAAAAAA==.',['疯神']='疯神再世:BAAAKgAECggIEwAAAA==.',['發呆']='發呆看蝸牛:BAAAKgAECgYIDAAAAA==.',['白家']='白家老七:BAABKgAFFH8UAAMEAAYIuR96GACZAQAEAAYIuR96GACZAQAbAAQIFAuvCQDCAAAAAA==.',['看我']='看我牛逼不:BAAAKgAECggIDQAAAA==.',['真彻']='真彻夜未眠:BAAAKgADCgIIAgAAAA==.',['睿智']='睿智的阿昆达:BAAAKgAECgQIBAAAAA==.',['瞬间']='瞬间:BAAAKgAFFAQIBAAAAA==.',['破碎']='破碎流年:BAAAKgAECgEIAQAAAA==.',['碳烤']='碳烤牛排:BAAAKgADCgQIBAAAAA==.',['神嘛']='神嘛都是浮云:BAAAKgAECgEIAQAAAA==.',['神的']='神的孩子:BAABKgAECn8WAAIfAAgIzB6CBABKAgAfAAgIzB6CBABKAgAAAA==.',['秋葵']='秋葵:BAAAKgAECgcICQAAAA==.',['秋高']='秋高气爽:BAAAKgADCgUIBQAAAA==.',['种花']='种花兔:BAAAKgADCggIEAAAAA==.',['程奕']='程奕博:BAAAKgAECgYICgAAAA==.',['稻香']='稻香:BAAAKgAECgYIBgAAAA==.',['穿林']='穿林北腿:BAAAKgAFFAgIAwAAAA==.',['站住']='站住等我奶你:BAAAKgAECgEIAQAAAA==.',['等我']='等我拉个瞄准:BAAAKgAFFAgIBAABKgAFFAgICgAFAEgiAA==.',['糖糖']='糖糖正正:BAAAKgADCgQIBAAAAA==.',['紫眼']='紫眼邪神:BAAAKgADCggICAAAAA==.',['红牛']='红牛:BAAAKgADCgEIAQAAAA==.',['纯情']='纯情男大:BAABKgAFFH8GAAICAAYIhwwUGgBMAQACAAYIhwwUGgBMAQAAAA==.',['终究']='终究想通了:BAAAKgAFFAgIBAAAAA==.',['绵北']='绵北腰子:BAAAKgAFFAQIBAABKgAFFAgICAASALMSAA==.',['老年']='老年绝活选手:BAAAKgAFFAQIAgAAAA==.',['老猫']='老猫沃夫:BAABKgAFFH8OAAMLAAQInhmnDQDIAAALAAQInhmnDQDIAAAgAAMIkwXRFACeAAAAAA==.',['老衲']='老衲法号叫兽:BAAAKgAECgIIAgAAAA==.',['聂哥']='聂哥虎背熊腰:BAAAKgAECggICAAAAA==.',['肆号']='肆号推土机:BAABKgAFFH8LAAMRAAMISAb5NwCRAAARAAMISAb5NwCRAAALAAEI8QFsKAAlAAAAAA==.',['肉来']='肉来佛:BAAAKgAECgUICgAAAA==.',['肉肉']='肉肉我爱吃:BAAAKgAECgMICAAAAA==.',['肌肉']='肌肉娘娘腔丶:BAABKgAECn8WAAIYAAgI5xRUCwB4AQAYAAgI5xRUCwB4AQAAAA==.',['胖乎']='胖乎乎的瞬间:BAABKgAFFH8MAAIJAAYIZQ2BEQAeAQAJAAYIZQ2BEQAeAQABKgAFFAgIEQAGAPEhAA==.',['胖胖']='胖胖哈力:BAABKgAFFH8IAAIHAAQI/xYwEwDuAAAHAAQI/xYwEwDuAAAAAA==.',['與絳']='與絳唇的故事:BAABKgAFFH8LAAIEAAYIxRwwAgDEAQAEAAYIxRwwAgDEAQAAAA==.',['艾莎']='艾莎丶云歌:BAAAKgAECgYIBgAAAA==.',['艾露']='艾露鸽:BAABKgAFFH8PAAIEAAYIiCJSGwCIAQAEAAYIiCJSGwCIAQAAAA==.',['花样']='花样美男:BAABKgAFFH8IAAIEAAQIkh9YQwDoAAAEAAQIkh9YQwDoAAAAAA==.',['花椒']='花椒油:BAAAKgAFFAEIAQAAAA==.',['花盗']='花盗二号:BAACKgAFFH8NAAMVAAMIpxeVLgC9AAAVAAMIpxeVLgC9AAAWAAMICgGOIwBjAAAqAAQKfzIAAxUACAhdHhEKACYCABUACAhdHhEKACYCABYABwjmD6UXABwBAAAA.',['苏富']='苏富贵:BAABKgAFFH8GAAICAAYIqRXbFAB0AQACAAYIqRXbFAB0AQABKgAFFAgICAASALMSAA==.',['苏小']='苏小七:BAAAKgAECgcIDQAAAA==.',['苏海']='苏海伦:BAAAKgAECgMIBwAAAA==.',['苏花']='苏花子:BAAAKgADCgMIAwAAAA==.',['英短']='英短蓝猫:BAAAKgADCgcIBwAAAA==.',['莫言']='莫言:BAAAKgAECggIDwAAAA==.',['萌牛']='萌牛真果粒:BAAAKgADCggICAAAAA==.',['萝卜']='萝卜的那些事:BAAAKgAECgQIBAAAAA==.',['萨囧']='萨囧囧:BAABKgAFFH8OAAIVAAYIFw4gFgArAQAVAAYIFw4gFgArAQAAAA==.',['蒋欣']='蒋欣:BAAAKgADCgUIBQAAAA==.',['蒜鸟']='蒜鸟算鸟:BAAAKgAFFAQIBAABKgAFFAgICAAGALMfAA==.',['蒽蒽']='蒽蒽丶:BAAAKgADCgUIBQAAAA==.',['蓝天']='蓝天野:BAAAKgAECggIDgAAAA==.',['蓝格']='蓝格格:BAAAKgAECgIIAgAAAA==.',['薄荷']='薄荷朱莉普:BAAAKgADCgYIBgAAAA==.',['蘇尒']='蘇尒喬:BAAAKgAECgIIAwAAAA==.',['蘭格']='蘭格格:BAAAKgAECgYIBwAAAA==.',['虚灵']='虚灵咒术师:BAAAKgAECgEIAQAAAA==.',['蜜桃']='蜜桃乌龙茶:BAAAKgADCggICQAAAA==.',['血妖']='血妖月:BAAAKgADCgEIAQAAAA==.',['血漫']='血漫银山:BAAAKgAECggIDAAAAA==.',['被遗']='被遗忘的心弦:BAAAKgADCggICAAAAA==.被遗忘的王者:BAAAKgADCgEIAQAAAA==.',['見獵']='見獵心囍:BAAAKgADCgIIAgAAAA==.',['詹尼']='詹尼:BAAAKgAECggICAAAAA==.',['诸葛']='诸葛钢铁丶:BAABKgAFFH8OAAIFAAgIrBbtBgAVAgAFAAgIrBbtBgAVAgAAAA==.',['贰号']='贰号推土机:BAABKgAFFH8GAAIEAAMI1QcNMACjAAAEAAMI1QcNMACjAAAAAA==.',['贰拾']='贰拾贰:BAABKgAFFH8SAAIUAAYIexgtDACZAQAUAAYIexgtDACZAQAAAA==.',['费尔']='费尔岛拿铁:BAABKgAFFH8FAAMCAAMIwhWlPgCjAAACAAIIwhWlPgCjAAADAAMIKgJYLwBSAAAAAA==.',['起个']='起个门拉个糖:BAABKgAECn8YAAIgAAgIAh0vDgAgAgAgAAgIAh0vDgAgAgAAAA==.',['超级']='超级小思嘉:BAACKgAFFH8GAAIVAAIIIhSaIgCOAAAVAAIIIhSaIgCOAAAqAAQKfx8AAhUACAjpGncgABQCABUACAjpGncgABQCAAAA.超级打井机:BAABKgAFFH8HAAMNAAMITgtpBQCHAAANAAMITgtpBQCHAAAOAAEIlwHTIQAhAAAAAA==.',['辰灬']='辰灬不二:BAAAKgAECggICwAAAA==.',['这是']='这是什么鬼:BAACKgAFFH8FAAMUAAQItgohNgCoAAAUAAQItgohNgCoAAAhAAEIzAynGQA3AAAqAAQKfxkAAiEACAhKFxoXAMkBACEACAhKFxoXAMkBAAAA.',['迷茫']='迷茫的小骑:BAAAKgAFFAQIBAAAAA==.',['逆风']='逆风行:BAAAKgADCggICgAAAA==.',['遐蝶']='遐蝶:BAAAKgAECggICQAAAA==.',['那个']='那个小德:BAAAKgADCggICQAAAA==.',['邪恶']='邪恶梦魇:BAAAKgAECgYICgAAAA==.',['郑小']='郑小卷:BAAAKgADCggICAAAAA==.',['酒城']='酒城彭于晏:BAAAKgAECgcICAAAAA==.',['酱油']='酱油一壶:BAAAKgAECggICAAAAA==.',['酸奶']='酸奶:BAABKgAFFH8KAAIUAAYIDQmUGgAqAQAUAAYIDQmUGgAqAQAAAA==.',['酸辣']='酸辣粉儿:BAABKgAECn8WAAIEAAgI2x4wMAA/AgAEAAgI2x4wMAA/AgAAAA==.',['野原']='野原灬新之助:BAAAKgADCggICAAAAA==.',['钓鱼']='钓鱼佬:BAAAKgADCgQIBAAAAA==.',['钙奶']='钙奶:BAAAKgAECgcIDgAAAA==.',['钟楼']='钟楼小米糕:BAAAKgAFFAYIBAAAAA==.',['長沙']='長沙满鍋:BAABKgAFFH8pAAMDAAgISCMXAQDVAgADAAgISCMXAQDVAgACAAQInAeCGACiAAAAAA==.',['门口']='门口热流:BAAAKgAECggICgABKgAFFAgIEwAHAHMfAA==.',['阿布']='阿布的右腿:BAAAKgAECgcIEAAAAA==.阿布的左腿:BAABKgAECn8eAAIEAAcI7A6JlgAgAQAEAAcI7A6JlgAgAQAAAA==.',['阿牛']='阿牛哥:BAAAKgAECggIDwAAAA==.',['阿萨']='阿萨:BAAAKgAECgIIAgAAAA==.',['陨石']='陨石拿铁:BAAAKgAFFAQIBAAAAA==.',['雨下']='雨下一整晚:BAABKgAFFH8KAAIOAAQI7BvpGAD8AAAOAAQI7BvpGAD8AAAAAA==.',['雪月']='雪月丶风华:BAACKgAFFH8FAAIEAAIIoQjjfQBrAAAEAAIIoQjjfQBrAAAqAAQKfyUAAgQACAjeF7daAOkBAAQACAjeF7daAOkBAAAA.',['雯雯']='雯雯李:BAAAKgAECgYIBgAAAA==.',['震撼']='震撼帝:BAACKgAFFH8KAAIDAAMIsRvPCgDvAAADAAMIsRvPCgDvAAAqAAQKfxUAAgMACAhWFt8eAJcBAAMACAhWFt8eAJcBAAEqAAUUCAhGAAMAsiEA.',['霜狼']='霜狼丨杜龙坦:BAAAKgADCgQIBAAAAA==.',['青城']='青城我上马:BAAAKgADCggICAAAAA==.',['面朝']='面朝灬大海:BAABKgAFFH8JAAIJAAMIkAMSKgB0AAAJAAMIkAMSKgB0AAAAAA==.',['顽劣']='顽劣不堪:BAAAKgAECgEIAQAAAA==.',['風雨']='風雨夜無笙:BAAAKgAFFAQIAwAAAA==.',['风从']='风从东方来:BAAAKgAFFAQIBgAAAA==.',['风的']='风的声音:BAAAKgADCggICQAAAA==.',['风骚']='风骚杰总:BAABKgAFFH8FAAIIAAMIVxBPFgC9AAAIAAMIVxBPFgC9AAAAAA==.',['飞翔']='飞翔的猫猫:BAAAKgADCgMIAwAAAA==.',['飞行']='飞行员舒克:BAABKgAFFH8JAAMfAAgI7xTMBwAAAgAfAAgI7xTMBwAAAgAIAAEICQquKgA/AAAAAA==.',['饮血']='饮血者玛鲁斯:BAABKgAFFH8HAAMaAAYI8BCZBAA/AQAaAAUIhQqZBAA/AQAiAAII+hk7DACdAAABKgAFFAgICAAaAP8VAA==.',['饺子']='饺子嫂子:BAAAKgADCggICAAAAA==.饺子转圈圈:BAAAKgAECgcIBwAAAA==.',['马什']='马什么梅:BAAAKgAECgQIBgAAAA==.',['马达']='马达嚒嘛哒:BAAAKgAECgIIAwAAAA==.',['骆冰']='骆冰丶:BAAAKgAFFAYIBAABKgAFFAgIJQALACEcAA==.',['骨汤']='骨汤牛肉面:BAAAKgADCggIDQAAAA==.',['魅力']='魅力乱射:BAABKgAFFH8MAAQSAAQIxh3LGAD1AAASAAQIxh3LGAD1AAAYAAEIkxB9DQA9AAAZAAEIIQTIFQA2AAAAAA==.',['魔法']='魔法披风:BAAAKgAECggIEwAAAA==.',['鸡肉']='鸡肉味嘎嘣脆:BAAAKgAFFAQIBAABKgAFFAgIAgAKAAAAAA==.',['黄昏']='黄昏的爸爸:BAAAKgADCggICAAAAA==.',['黑痒']='黑痒痒:BAABKgAFFH8GAAIdAAMIAA5HCACIAAAdAAMIAA5HCACIAAABKgAFFAgIKQAHAGQbAA==.',['黑白']='黑白红:BAAAKgAECgUIAwAAAA==.',['黑蕾']='黑蕾丝:BAAAKgAECggICAAAAA==.',['齊格']='齊格佛理德:BAAAKgAECgMIAwAAAA==.',['龘齌']='龘齌矲:BAAAKgAECggIEgAAAA==.',['龙喷']='龙喷工具人:BAABKgAFFH8GAAIjAAYIXQycAgCsAQAjAAYIXQycAgCsAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end