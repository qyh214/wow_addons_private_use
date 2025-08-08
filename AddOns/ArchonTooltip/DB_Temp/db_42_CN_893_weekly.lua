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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Druid-Balance','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Monk-Mistweaver','DeathKnight-Unholy','DeathKnight-Frost','Mage-Fire','Mage-Arcane','Druid-Restoration','Druid-Guardian','Mage-Frost','Shaman-Restoration','DeathKnight-Blood','Warlock-Destruction','Unknown-Unknown','Priest-Discipline','Priest-Holy','Warrior-Fury','Shaman-Elemental','Warlock-Demonology','DemonHunter-Vengeance','DemonHunter-Havoc','Hunter-Survival','Monk-Windwalker','Evoker-Devastation','Warlock-Affliction','Warrior-Protection',}; local provider = {region='CN',realm='黄金之路',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ai='Aina:BAAAKgAFFAIIAgAAAA==.',Al='Alcax:BAAAKgAECgQIBwAAAA==.Allepassant:BAAAKgAECgMIAwAAAA==.',As='Ashfur:BAABKgAECn8aAAMBAAcIjyAmHQATAgABAAcIjyAmHQATAgACAAEIaBex+QBDAAABKgAFFAgIDAADAHMZAA==.',Bi='Bingo:BAAAKgAECgYIBgAAAA==.',Bl='Blackbull:BAAAKgAFFAIIAgAAAA==.',Bt='Btwang:BAABKgAECn8wAAQEAAgImCIfIQCVAgAEAAgImCIfIQCVAgAFAAYI+w/PJAA7AQAGAAEIKhlFVABJAAAAAA==.',Bu='Buddylove:BAAAKgADCggIKQAAAA==.Buddylovei:BAAAKgAECgUIBQAAAA==.Buddyloveix:BAAAKgADCgQIBAAAAA==.Buddylovevi:BAAAKgADCggIEAAAAA==.Buddylovevii:BAAAKgADCggICAAAAA==.',Ca='Casilla:BAAAKgADCgYIBgAAAA==.',Ch='Cheem:BAABKgAFFH8GAAIHAAYIbRdvDABeAQAHAAYIbRdvDABeAQAAAA==.',Dr='Dragonsky:BAABKgAFFH8TAAIEAAgIzx+3CQAnAgAEAAgIzx+3CQAnAgAAAA==.',Ec='Eclecticism:BAAAKgAECgIIAgAAAA==.',Ho='Horeki:BAAAKgAECgQICAAAAA==.',Ib='Ibanez:BAACKgAFFH8IAAIIAAcIFxSjCwDTAQAIAAcIFxSjCwDTAQAqAAQKfxgAAwgACAhbJAMHAOMCAAgACAhbJAMHAOMCAAkABwg6HdoQAIcBAAAA.',Le='Leahdizoni:BAAAKgAECgUIBwAAAA==.Leahdizonii:BAAAKgAECgIIAgAAAA==.Leahdizoniv:BAAAKgADCggIGAAAAA==.Leahdizony:BAAAKgADCggIEwAAAA==.',Lw='Lwrcsabrd:BAAAKgADCggICAAAAA==.',Ma='Marigold:BAAAKgAECgEIAQAAAA==.',Na='Najasna:BAAAKgADCggIDQAAAA==.',Qd='Qdk:BAAAKgAFFAMIAwAAAA==.',Ql='Qlr:BAAAKgAECgEIAQAAAA==.',Qq='Qqy:BAAAKgAECgIIAgAAAA==.',Sc='Schwarzejes:BAAAKgAECgEIAQAAAA==.',Sd='Sdgwer:BAAAKgAECgYIBgAAAA==.',Sl='Slifeng:BAAAKgADCgcIBwAAAA==.',Tb='Tb:BAABKgAFFH8IAAMKAAgIhSGdBwDXAQAKAAYImiCdBwDXAQALAAII0iP5JADOAAAAAA==.',Ty='Tyrandes:BAAAKgAECgcIDQAAAA==.',Xi='Xiaoluob:BAACKgAFFH8GAAMDAAQIzRIeFwDhAAADAAQIzRIeFwDhAAAMAAEIjgv4IQA+AAAqAAQKfxkAAw0ACAgfIwYEAHwCAA0ACAgfIwYEAHwCAAMAAQg9BT/hACEAAAAA.',['一点']='一点点:BAAAKgAFFAIIBAAAAA==.',['一粒']='一粒丹:BAAAKgAFFAEIAQAAAA==.',['一脚']='一脚踢爆狗蛋:BAAAKgADCgIIAgAAAA==.',['下辈']='下辈子我请:BAAAKgADCgIIAgAAAA==.',['不二']='不二丶骑仕:BAAAKgADCgQIBAAAAA==.',['不爱']='不爱晒太阳:BAAAKgAECggIBwAAAA==.',['世界']='世界与你同在:BAAAKgAECgYIBgAAAA==.',['丿墨']='丿墨丶:BAAAKgAFFAEIAQAAAA==.',['九尾']='九尾猫:BAAAKgAECggICAAAAA==.',['云常']='云常曦:BAAAKgADCgUIBQAAAA==.',['伯起']='伯起:BAABKgAFFH8HAAMKAAYIZglDEQA4AQAKAAYIvwhDEQA4AQAOAAEIkwbwLAA2AAAAAA==.',['你好']='你好呀丶起灵:BAABKgAFFH8IAAIBAAgIPxRGCQDDAQABAAgIPxRGCQDDAQAAAA==.',['你的']='你的小洣洣:BAABKgAFFH8GAAIMAAMI4AfiJwCGAAAMAAMI4AfiJwCGAAAAAA==.',['信仰']='信仰之殇:BAACKgAFFH8GAAMGAAYIfgdWEwBqAAAEAAQI/AlgZwCfAAAGAAIIwQNWEwBqAAAqAAQKfxgABAUACAhUHK0PAAUCAAUABwjIH60PAAUCAAQABwiWGsCNAHsBAAYAAQjaAllqABAAAAAA.',['傲天']='傲天战:BAAAKgAECgEIAQAAAA==.',['像风']='像风不问归期:BAAAKgADCgIIAgAAAA==.',['光之']='光之子:BAAAKgAFFAIIAgAAAA==.',['光铸']='光铸死骑:BAACKgAFFH8LAAIIAAgIrAkJDQAtAQAIAAgIrAkJDQAtAQAqAAQKfxsAAggACAhbIF8OAJgCAAgACAhbIF8OAJgCAAAA.',['克丽']='克丽丝娜光翼:BAABKgAFFH8MAAMEAAMIFg5lKQDBAAAEAAMIFg5lKQDBAAAFAAMItAgxDACVAAAAAA==.',['克里']='克里斯蒂娜:BAABKgAFFH8GAAIEAAYINgfJLwApAQAEAAYINgfJLwApAQAAAA==.',['八级']='八级大狂蜂:BAACKgAFFH8eAAMDAAUIDRobGwBBAQADAAUIDRobGwBBAQAMAAIIVguEGgBwAAAqAAQKfzoABAMACAjCIcQXAHgCAAMACAjCIcQXAHgCAAwABgjkFaRLAN8AAA0AAQhJFc4uADkAAAAA.八级大狂風:BAABKgAFFH8GAAIIAAMI9QhdFwCrAAAIAAMI9QhdFwCrAAAAAA==.',['兰州']='兰州拉面:BAAAKgAECgQIBAAAAA==.',['其实']='其实是麻痹了:BAABKgAFFH8IAAIDAAgI+hAeCQALAgADAAgI+hAeCQALAgAAAA==.',['其徐']='其徐如风:BAAAKgADCgQIBAAAAA==.',['凤凰']='凤凰小兔:BAAAKgADCgQIBAAAAA==.凤凰涅盘:BAAAKgAECgYIBgAAAA==.',['劉教']='劉教授:BAAAKgAFFAgIBAAAAA==.',['加血']='加血螺旋桨:BAAAKgAFFAgIBAAAAA==.',['北师']='北师大:BAAAKgAECggICQAAAA==.',['午夜']='午夜的微醺:BAAAKgAECgUIBQAAAA==.',['华夫']='华夫人:BAAAKgAECgEIAQAAAA==.',['南屿']='南屿清辞:BAACKgAFFH88AAIEAAgIrB/PAwCiAgAEAAgIrB/PAwCiAgAqAAQKfxUAAgQACAjpGMxYAO0BAAQACAjpGMxYAO0BAAAA.',['卡卡']='卡卡骑士再临:BAAAKgADCgMIBQAAAA==.',['卧龙']='卧龙大花熊:BAABKgAECn8VAAIHAAgIqw5qKgBBAQAHAAgIqw5qKgBBAQAAAA==.',['卷毛']='卷毛胡:BAAAKgADCgEIAQAAAA==.',['厉害']='厉害的奶:BAACKgAFFH8SAAIPAAMIeRZ0LgC9AAAPAAMIeRZ0LgC9AAAqAAQKfyQAAg8ACAjLFDgbAFYBAA8ACAjLFDgbAFYBAAAA.',['又是']='又是小湖人:BAABKgAFFH8GAAIDAAYIEA15EQBLAQADAAYIEA15EQBLAQAAAA==.',['叫什']='叫什么名字吖:BAAAKgADCggICAAAAA==.',['叶凡']='叶凡:BAAAKgAECgIIAgAAAA==.',['吃到']='吃到破产:BAAAKgADCgcIBwAAAA==.',['吉宝']='吉宝:BAAAKgADCgMIAwAAAA==.',['后羿']='后羿射月:BAABKgAFFH8GAAIBAAMItA6HMwCjAAABAAMItA6HMwCjAAAAAA==.',['咕丶']='咕丶牛顿:BAAAKgAFFAQIBAAAAA==.',['哲学']='哲学的淡季:BAAAKgAECgYIBgAAAA==.',['喵之']='喵之哀伤:BAAAKgAECgYIBgAAAA==.',['喵了']='喵了个喵:BAABKgAFFH8IAAIKAAgIVxAOAwAmAgAKAAgIVxAOAwAmAgAAAA==.',['喷火']='喷火的小钢炮:BAAAKgAECgMIAwAAAA==.',['圣光']='圣光在忽悠你:BAABKgAECn8jAAIQAAgImBcNGgDGAQAQAAgImBcNGgDGAQAAAA==.',['地宝']='地宝:BAAAKgAFFAIIAgAAAA==.',['坚硬']='坚硬的稀饭:BAAAKgAFFAMIAwAAAA==.',['墨狄']='墨狄斯丶菲比:BAAAKgAECgMIAwAAAA==.',['夏美']='夏美哩哩:BAABKgAECn8ZAAIRAAcI+hBSOAArAQARAAcI+hBSOAArAQAAAA==.',['多蒙']='多蒙卡欣:BAAAKgAECgMIBgAAAA==.',['大头']='大头带哥:BAAAKgAECggICAABKgAFFAgICAAIABcUAA==.大头怪啊:BAAAKgAECggICAAAAA==.',['大将']='大将女骑士:BAAAKgADCggIEQAAAA==.',['大粽']='大粽子:BAAAKgAECgEIAQAAAA==.',['天下']='天下:BAACKgAFFH8XAAIEAAcIbxxGBgBPAQAEAAcIbxxGBgBPAQAqAAQKfyMAAwQACAhfJYcGAAMDAAQACAhfJYcGAAMDAAUAAQhhDnQjADIAAAEqAAUUCAgEABIAAAAA.',['天意']='天意:BAAAKgAECgQIBwABKgAFFAgIBAASAAAAAA==.',['天空']='天空之翠玉:BAAAKgAECggICAAAAA==.',['天道']='天道:BAAAKgAECgQICAABKgAFFAgIBAASAAAAAA==.',['太阳']='太阳的人骑:BAAAKgAFFAEIAQAAAA==.',['奇葩']='奇葩小德:BAAAKgADCgIIAgAAAA==.',['奥德']='奥德彪变蕉树:BAAAKgAECgIIAgAAAA==.',['如我']='如我垂怜:BAAAKgAFFAMIAwAAAA==.',['娇嫣']='娇嫣的紫水晶:BAABKgAFFH8HAAIRAAcIHx4FBgA2AgARAAcIHx4FBgA2AgABKgAFFAgIFgARAGsbAA==.',['嫪毐']='嫪毐:BAAAKgADCgIIAgAAAA==.',['安么']='安么么:BAAAKgAECggICAAAAA==.',['宝宝']='宝宝爱吃菜:BAAAKgAECgQIBgAAAA==.',['小小']='小小的冰:BAAAKgADCggICAAAAA==.',['小毯']='小毯:BAAAKgAECggIDwAAAA==.',['小法']='小法泪儿灬:BAABKgAFFH8IAAMOAAQIORdCCQDkAAAOAAQISxRCCQDkAAAKAAQI8BRDHQDFAAABKgAFFAgICAAKAIUhAA==.',['小米']='小米虫子:BAAAKgAFFAMIAwAAAA==.',['小闲']='小闲云云:BAAAKgAECgQIBAAAAA==.',['小飞']='小飞棍来喽:BAAAKgADCgEIAQAAAA==.',['尼古']='尼古拉斯安德:BAAAKgAECggICQAAAA==.',['币艳']='币艳咚谑:BAAAKgADCgQIBAAAAA==.',['布洛']='布洛芬疼:BAAAKgADCggICAAAAA==.',['年迈']='年迈的林宏伟:BAAAKgAECgEIAQAAAA==.',['库库']='库库尔坎:BAAAKgADCggICAAAAA==.',['张若']='张若衡:BAABKgAFFH8IAAMTAAQIMiCXCAAUAQATAAQIGR2XCAAUAQAUAAQITxXXJACwAAAAAA==.',['弯的']='弯的我们:BAABKgAECn8YAAIVAAgIsxMDKQDoAQAVAAgIsxMDKQDoAQAAAA==.',['往生']='往生咒:BAAAKgAECgMIAwAAAA==.',['心猿']='心猿:BAAAKgADCgEIAQAAAA==.',['忘川']='忘川秋裤:BAAAKgAECgIIAgAAAA==.',['怪盗']='怪盗呦西:BAAAKgAFFAQIBAABKgAFFAgICAAPALsbAA==.',['我可']='我可能爱上你:BAAAKgADCgcIDgAAAA==.',['战斗']='战斗术:BAAAKgAECggICAAAAA==.',['战火']='战火:BAAAKgADCggICgAAAA==.',['扯毛']='扯毛线:BAABKgAECn8fAAMPAAgIWiJ3CQCqAgAPAAgIWiJ3CQCqAgAWAAYIZQgIWAC5AAAAAA==.',['拉雯']='拉雯妲:BAABKgAFFH8OAAIPAAgIghDDBwCcAQAPAAgIghDDBwCcAQAAAA==.',['撒娇']='撒娇小满:BAABKgAECn83AAIPAAgIcSJ+CwCaAgAPAAgIcSJ+CwCaAgAAAA==.',['无畏']='无畏骑士:BAAAKgAECggICgAAAA==.',['无聊']='无聊萨满:BAAAKgAECgMIAwABKgAFFAMICAACAGkXAA==.',['时光']='时光之心:BAAAKgAECggICAAAAA==.',['易碎']='易碎品:BAAAKgADCgMIAwABKgAECgEIAQASAAAAAA==.',['星之']='星之卡比:BAAAKgAECgUIBQAAAA==.',['星明']='星明:BAAAKgAECgMIAwAAAA==.',['星见']='星见草:BAAAKgAECgIIAgAAAA==.',['普罗']='普罗米修斯:BAABKgAECn8bAAIVAAcIYBkGDgDAAQAVAAcIYBkGDgDAAQAAAA==.',['智狗']='智狗:BAABKgAFFH8IAAILAAgIAg4QCAD+AQALAAgIAg4QCAD+AQAAAA==.',['月小']='月小九:BAAAKgADCgMIAwAAAA==.',['月玖']='月玖歌:BAAAKgAECgMIAwAAAA==.',['有我']='有我一人足矣:BAAAKgAECgIIAgAAAA==.',['期盼']='期盼未来:BAAAKgAECgUIBgAAAA==.',['术离']='术离殇:BAABKgAFFH8KAAMXAAYIaRz3AQAsAQARAAUIvxlsBABtAQAXAAQIIyL3AQAsAQAAAA==.',['松针']='松针听雨:BAAAKgAECgMIAwAAAA==.',['林宏']='林宏伟:BAAAKgAECgcIEAAAAA==.',['枫飞']='枫飞梦舞:BAABKgAFFH8JAAIOAAMILxYGEwDNAAAOAAMILxYGEwDNAAAAAA==.',['樱桃']='樱桃姐姐:BAAAKgAECgQIBwAAAA==.',['欧气']='欧气喵喵:BAACKgAFFH8GAAIRAAYIMg+2FwBGAQARAAYIMg+2FwBGAQAqAAQKfzEAAxcACAhgGl4NABsCABcACAhgGl4NABsCABEABwiPEOFJAEEBAAAA.欧气柴柴:BAABKgAFFH8GAAIEAAYIsRP9GwCEAQAEAAYIsRP9GwCEAQAAAA==.',['死亡']='死亡木偶:BAAAKgAECgQIBAAAAA==.',['比巴']='比巴卜:BAAAKgAFFAIIAgAAAA==.',['氤氲']='氤氲混沌:BAABKgAFFH8GAAIYAAMI6hQLEwCrAAAYAAMI6hQLEwCrAAAAAA==.',['氵榴']='氵榴莲软糖丶:BAABKgAFFH8GAAIKAAYITw56DwBMAQAKAAYITw56DwBMAQAAAA==.',['沐雨']='沐雨宸绯:BAABKgAFFH8IAAIZAAgIpg1WCQDoAQAZAAgIpg1WCQDoAQAAAA==.',['沧海']='沧海丶扬尘:BAACKgAFFH8UAAIPAAUIOBO/EAD3AAAPAAUIOBO/EAD3AAAqAAQKfxcAAg8ACAgLHXAbACICAA8ACAgLHXAbACICAAAA.',['河北']='河北彩伽:BAAAKgAFFAMIAwAAAA==.',['泥岩']='泥岩:BAAAKgAECggIDgAAAA==.',['流年']='流年依依:BAABKgAFFH8GAAIEAAYIcSHJHgB2AQAEAAYIcSHJHgB2AQAAAA==.',['流水']='流水之透辉石:BAAAKgADCgMIAwAAAA==.',['淄博']='淄博井柏然:BAABKgAFFH8HAAILAAMIAwnuHQCTAAALAAMIAwnuHQCTAAAAAA==.淄博吴彦祖:BAAAKgAECgcICwAAAA==.',['深入']='深入潜出:BAAAKgAECgQIBgAAAA==.',['深渊']='深渊之玛瑙玉:BAAAKgAECggICAAAAA==.',['深蓝']='深蓝魅影:BAAAKgAECggICAAAAA==.',['混江']='混江龍:BAAAKgADCggICAAAAA==.',['清源']='清源丫:BAABKgAFFH8IAAMMAAQIEQvvDwC0AAAMAAMIEQvvDwC0AAADAAQIcwtGPwCtAAAAAA==.',['清虚']='清虚道德真君:BAACKgAFFH8FAAIEAAQIJiN7CQAzAQAEAAQIJiN7CQAzAQAqAAQKfxkAAgQACAgoJJAVAMECAAQACAgoJJAVAMECAAAA.',['点丽']='点丽卡卡:BAAAKgADCggICgAAAA==.点丽斑斑:BAAAKgADCgIIAgAAAA==.',['点娜']='点娜卡丝:BAAAKgAECgMIAwAAAA==.点娜娜:BAAAKgADCgMIAwAAAA==.',['点思']='点思思:BAAAKgADCggICQAAAA==.',['点斑']='点斑斑牛:BAAAKgAECgcICQAAAA==.',['点点']='点点少:BAAAKgADCgQIBAAAAA==.',['点美']='点美女:BAAAKgADCgMIAwAAAA==.',['炽焰']='炽焰圣卫莱恩:BAAAKgAECgEIAQAAAA==.',['热心']='热心网友:BAAAKgAECgEIAQAAAA==.',['熊猫']='熊猫一号:BAAAKgADCggICAAAAA==.',['爱你']='爱你的鹿:BAAAKgAFFAIIAgAAAA==.',['特弥']='特弥斯丶:BAAAKgAECggIDgAAAA==.',['狐假']='狐假狐威:BAAAKgADCgEIAgAAAA==.',['猫宁']='猫宁:BAABKgAECn8iAAMMAAgIPhu3FwAHAgAMAAgIPhu3FwAHAgANAAIILwccPQAwAAAAAA==.',['猫戏']='猫戏:BAAAKgAFFAIIAgAAAA==.',['獄門']='獄門:BAAAKgAFFAQIAwAAAA==.',['王否']='王否留行:BAACKgAFFH8QAAICAAMIpxZPLgDPAAACAAMIpxZPLgDPAAAqAAQKfx4AAwIACAhYHGVIANsBAAIACAhYHGVIANsBAAEAAwiaB4h3AGAAAAAA.',['玛修']='玛修:BAABKgAFFH8IAAMBAAMI9RQ5QwBwAAABAAII7RM5QwBwAAACAAII/xSVQwBRAAAAAA==.',['玛卡']='玛卡巴卡:BAAAKgADCggICAAAAA==.',['瑾年']='瑾年丨福狂牛:BAAAKgAECgcIBwAAAA==.',['甘死']='甘死佳琪:BAAAKgADCgEIAQAAAA==.',['白夜']='白夜行:BAAAKgAECgEIAQAAAA==.',['益达']='益达口香糖:BAAAKgAECgMIAwAAAA==.',['目目']='目目:BAAAKgAECggICAAAAA==.',['石屹']='石屹节丶托尼:BAAAKgAFFAYIAgAAAA==.',['碎雪']='碎雪:BAAAKgAECgYICgAAAA==.',['神一']='神一般的男人:BAAAKgAFFAEIAQAAAA==.',['神之']='神之信仰:BAABKgAECn8VAAMCAAgIig+BWgChAQACAAgIig+BWgChAQAaAAQIeAbRGQBgAAAAAA==.',['私人']='私人时间:BAAAKgAECgMIAwAAAA==.',['筱月']='筱月若水:BAABKgAFFH8HAAIEAAMIaRkLQADxAAAEAAMIaRkLQADxAAAAAA==.',['筷楽']='筷楽至上:BAAAKgADCgEIAQAAAA==.',['米西']='米西米西:BAAAKgADCgIIAgAAAA==.',['精钢']='精钢芭比:BAABKgAECn8VAAIFAAgI9hMJCgCBAQAFAAgI9hMJCgCBAQAAAA==.',['結城']='結城昨日奈:BAACKgAFFH8WAAIVAAYIHB6YCwCSAQAVAAYIHB6YCwCSAQAqAAQKfyIAAhUACAiTIKwLAI0CABUACAiTIKwLAI0CAAAA.',['纵横']='纵横四海:BAAAKgAECgEIAQAAAA==.',['练锋']='练锋号帮主:BAAAKgAECgEIAQAAAA==.',['给我']='给我一个么么:BAAAKgAECggICAAAAA==.',['绫晄']='绫晄:BAAAKgADCgcIBwAAAA==.',['美少']='美少女不睡狸:BAAAKgAECgUIBQAAAA==.',['翁美']='翁美玲丶:BAAAKgAFFAQIBAAAAA==.',['老贼']='老贼:BAAAKgAECgYIAQAAAA==.',['肾骑']='肾骑:BAABKgAFFH8KAAIEAAQIsxTSRgDgAAAEAAQIsxTSRgDgAAAAAA==.',['胖不']='胖不死:BAAAKgAECgYIEAAAAA==.',['胖大']='胖大仁:BAABKgAECn8xAAMbAAgI+B18EwBGAgAbAAgI+B18EwBGAgAHAAcIKw/nRAArAQAAAA==.',['自然']='自然睡到醒:BAABKgAECn8jAAMBAAgI3iU5AQAIAwABAAgI3iU5AQAIAwACAAYIhiMsUwC3AQAAAA==.',['舞动']='舞动之灵:BAABKgAFFH8MAAIZAAgI7BTACgDdAQAZAAgI7BTACgDdAQAAAA==.',['舟月']='舟月栩墨:BAAAKgAFFAgIBAAAAA==.舟月龙龙:BAAAKgAFFAYIBAAAAA==.',['舟柒']='舟柒词:BAAAKgAFFAQIBAAAAA==.',['良民']='良民张三:BAAAKgAFFAEIAQAAAA==.',['艾瑞']='艾瑞乄莉娅:BAAAKgAFFAgIBAAAAA==.',['芙蕾']='芙蕾雅丶:BAAAKgAECgUIBQAAAA==.',['苍天']='苍天之青玉:BAAAKgAECggICAAAAA==.',['苏苏']='苏苏小妹:BAACKgAFFH8TAAICAAMIkBlOGwDnAAACAAMIkBlOGwDnAAAqAAQKfxgAAgIACAiEG9RJAIIBAAIACAiEG9RJAIIBAAAA.',['草莓']='草莓啵乐乐:BAAAKgAFFAQIBAABKgAFFAgIEwAHAE0iAA==.',['莉莉']='莉莉:BAAAKgADCggIEgAAAA==.',['莫小']='莫小小:BAAAKgAFFAMIAwAAAA==.',['莱因']='莱因哈特:BAABKgAFFH8NAAIFAAMIHxuKCADYAAAFAAMIHxuKCADYAAAAAA==.',['菟菟']='菟菟格蕾丝:BAABKgAECn8vAAITAAgIVghzRQD/AAATAAgIVghzRQD/AAAAAA==.',['菠萝']='菠萝本萝:BAAAKgADCgQIBAAAAA==.',['萧何']='萧何为情仇:BAABKgAECn8gAAIEAAgIvBmiTQAJAgAEAAgIvBmiTQAJAgAAAA==.',['落雨']='落雨归尘:BAAAKgAFFAMIAwAAAA==.',['落雪']='落雪无痕:BAAAKgAECgcIBwAAAA==.',['虚空']='虚空大君:BAAAKgAFFAEIAQAAAA==.',['蟬時']='蟬時雨:BAACKgAFFH8GAAIPAAYI9xCeAgBjAQAPAAYI9xCeAgBjAQAqAAQKfxgAAxYACAg3HRYtAJcBABYABQgLHRYtAJcBAA8ABwg5D3ByAOsAAAAA.',['血与']='血与暗的挣扎:BAAAKgAFFAYIAgAAAA==.',['西瓜']='西瓜牛奶冰:BAAAKgAECgUIBQAAAA==.',['记得']='记得打给我:BAABKgAFFH8GAAICAAYIMAoEHgAXAQACAAYIMAoEHgAXAQAAAA==.',['豆雨']='豆雨眠沙:BAABKgAFFH8GAAIcAAYIKyIXDwBuAQAcAAYIKyIXDwBuAQAAAA==.',['豹子']='豹子头猛冲:BAAAKgAFFAYIBAAAAA==.',['起门']='起门专用:BAABKgAECn8iAAMXAAgIlBjEEQD5AQAXAAgIlBjEEQD5AQAdAAMIpQwBNQByAAAAAA==.',['轰炸']='轰炸鸡:BAAAKgAECgEIAQAAAA==.',['达布']='达布拉:BAAAKgAECgYICAAAAA==.',['逢坂']='逢坂大河:BAAAKgADCggICAAAAA==.',['那个']='那个矮:BAABKgAECn8XAAIGAAgIJh6HCwBNAgAGAAgIJh6HCwBNAgAAAA==.',['醉红']='醉红尘:BAAAKgAECgIIAgAAAA==.',['钢筋']='钢筋混泥土:BAAAKgAECggIEAAAAA==.',['钢达']='钢达姆机器人:BAABKgAFFH8GAAIFAAYI7QsqCAArAQAFAAYI7QsqCAArAQAAAA==.',['铁墟']='铁墟:BAAAKgAFFAQIBAAAAA==.',['铁甲']='铁甲黑大米:BAABKgAECn8iAAIBAAgINxaWJgCpAQABAAgINxaWJgCpAQAAAA==.',['银之']='银之流星:BAABKgAECn8kAAMOAAgIXyRhBgDaAgAOAAgIXyRhBgDaAgAKAAIIfBERiQBqAAAAAA==.',['闪光']='闪光黑豆:BAABKgAFFH8KAAIEAAgIWQcLDwCwAQAEAAgIWQcLDwCwAQAAAA==.',['闲云']='闲云云:BAABKgAECn8kAAMCAAgIlRvXNQDOAQACAAgIexrXNQDOAQABAAQIHhuLIwD6AAAAAA==.',['阡陌']='阡陌丶嫣:BAAAKgADCgEIAQAAAA==.阡陌花开:BAABKgAFFH8IAAMDAAgImB58JwD3AAADAAMI6hZ8JwD3AAAMAAUIlQ6AFgDtAAAAAA==.',['阿呦']='阿呦痛阿:BAAAKgAECgMIAwAAAA==.',['阿比']='阿比迪斯:BAABKgAECn8wAAIJAAgIRR4VBwBUAgAJAAgIRR4VBwBUAgAAAA==.',['阿米']='阿米陀夫:BAABKgAFFH8LAAMQAAYIchD9EQASAQAQAAYI5Q79EQASAQAIAAUIVQyXJAABAQABKgAFFAgIDgAIAEoXAA==.',['陈乔']='陈乔恩:BAAAKgAFFAIIBAAAAA==.',['雪茄']='雪茄:BAAAKgAECgYIBgAAAA==.',['雲岸']='雲岸無霜:BAABKgAFFH8KAAIUAAMImA3cFQCOAAAUAAMImA3cFQCOAAAAAA==.',['雷欧']='雷欧娜:BAAAKgAECggIEQAAAA==.',['雷震']='雷震仔:BAAAKgADCgEIAQAAAA==.',['青木']='青木爭羽:BAABKgAECn8iAAQGAAgI8hq9GACjAQAGAAgI8hq9GACjAQAFAAcIsw4dIgBPAQAEAAIIvAWRYAFIAAAAAA==.',['面条']='面条:BAAAKgAFFAQIBAAAAA==.',['风灵']='风灵月影:BAAAKgADCgIIAgAAAA==.',['飞嗯']='飞嗯嗯:BAAAKgADCgEIAQAAAA==.',['高大']='高大威猛噢:BAABKgAECn8dAAIRAAgIMhd1HADDAQARAAgIMhd1HADDAQAAAA==.',['魂天']='魂天帝丶:BAABKgAFFH8IAAIeAAgI7QxqAwCCAQAeAAgI7QxqAwCCAQAAAA==.',['魑魅']='魑魅之灵:BAABKgAFFH8GAAIYAAMI0QzeFwCMAAAYAAMI0QzeFwCMAAAAAA==.魑魅魍魉:BAAAKgADCgEIAgAAAA==.',['麒麟']='麒麟小猪:BAAAKgAECggICAAAAA==.',['黑灯']='黑灯泡:BAAAKgAECgIIAgAAAA==.',['默子']='默子陌:BAAAKgAFFAIIBAAAAA==.',['龙乡']='龙乡之星:BAAAKgADCgEIAQAAAA==.',['龙猫']='龙猫猫:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end