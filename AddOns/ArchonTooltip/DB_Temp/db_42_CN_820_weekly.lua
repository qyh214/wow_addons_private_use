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
 local lookup = {'Priest-Holy','Priest-Discipline','Warrior-Fury','Mage-Frost','Shaman-Restoration','Warrior-Protection','Paladin-Retribution','DeathKnight-Unholy','Warlock-Destruction','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','Druid-Restoration','Rogue-Assassination','Druid-Balance','Evoker-Devastation','Shaman-Elemental','Monk-Windwalker','DemonHunter-Vengeance','Paladin-Holy','Shaman-Enhancement','Mage-Arcane','Mage-Fire','Monk-Mistweaver','Priest-Shadow','Unknown-Unknown','Rogue-Subtlety','Rogue-Outlaw','Warlock-Affliction','Druid-Guardian','Warrior-Arms','Warlock-Demonology','Evoker-Preservation',}; local provider = {region='CN',realm='藏宝海湾',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ae='Aex:BAAAKgADCggIDAAAAA==.',Bl='Bloodyfox:BAACKgAFFH8SAAIBAAMImwycGgB8AAABAAMImwycGgB8AAAqAAQKfysAAwEACAhOE402AGQBAAEACAhOE402AGQBAAIAAgiSBhh2AEIAAAAA.',Ch='Chaos:BAABKgAECn9CAAIDAAgI/CC7DwCIAgADAAgI/CC7DwCIAgAAAA==.',Co='Continue:BAAAKgAECggIBgAAAA==.',De='Deathfaith:BAAAKgADCgEIAQAAAA==.Deathuranus:BAAAKgADCgEIAQAAAA==.Delil:BAAAKgAECggICAAAAA==.Deng:BAAAKgAFFAIIBAAAAA==.',Gu='Guylian:BAABKgAECn8VAAIEAAgIjR+wGAA7AgAEAAgIjR+wGAA7AgAAAA==.',Ja='Jaychou:BAABKgAECn8VAAIFAAgIsxSJTwBQAQAFAAgIsxSJTwBQAQAAAA==.',La='Lambmiya:BAAAKgAECgIIAgAAAA==.',Ma='Marika:BAABKgAFFH8MAAMGAAQI2QlrCgCCAAADAAQImwVAGQCQAAAGAAQInwhrCgCCAAAAAA==.',Mi='Mi:BAAAKgAECgQIBAAAAA==.',Ol='Oliveiraw:BAAAKgADCgcIBwAAAA==.',Oo='Oolisa:BAAAKgAECggIEQAAAA==.',Ov='Ov:BAAAKgAECgEIAQAAAA==.',Pa='Paul:BAABKgAFFH8JAAIHAAYIKh5jEQDTAQAHAAYIKh5jEQDTAQAAAA==.',Pl='Playeriogonj:BAAAKgADCggICAAAAA==.',Ri='Richboy:BAAAKgADCgUICgAAAA==.Richchick:BAAAKgADCgQIBAAAAA==.Richerchick:BAAAKgADCgMIAwAAAA==.Richman:BAAAKgADCggICQAAAA==.',Ru='Runan:BAAAKgAFFAYIAgAAAA==.',Sc='Scarletty:BAAAKgAFFAgIAQAAAA==.',Sn='Snower:BAABKgAECn8/AAIIAAgIlhwoBgBVAgAIAAgIlhwoBgBVAgAAAA==.',Sp='Spartan:BAAAKgAFFAgIBAAAAA==.',St='Stephanie:BAABKgAFFH8GAAIJAAYI7RlGFgBRAQAJAAYI7RlGFgBRAQAAAA==.',Ti='Tingayo:BAAAKgAECgcIDQAAAA==.',Tr='Trnt:BAAAKgAECggICAAAAA==.',Va='Valkyrie:BAACKgAFFH8eAAIDAAYIohNODgBtAQADAAYIohNODgBtAQAqAAQKfx8AAgMACAhcG5QcAC4CAAMACAhcG5QcAC4CAAEqAAUUCAgVAAMAsRoA.',Vi='Villia:BAAAKgAECggICgAAAA==.',Zo='Zombie:BAAAKgAFFAQIBAAAAA==.',Zu='Zues:BAAAKgAFFAQIBAAAAA==.',['一之']='一之助:BAAAKgAECgEIAQAAAA==.',['一念']='一念成魔:BAABKgAECn8VAAIKAAgIxg+jQwA9AQAKAAgIxg+jQwA9AQAAAA==.',['一条']='一条恶龙:BAABKgAFFH8RAAMLAAYI3RkjBACWAQALAAYIOhQjBACWAQAMAAMI9hLzKgC+AAAAAA==.',['一狩']='一狩猎一:BAABKgAFFH8fAAMMAAUIZRloIgDoAAAMAAUIZRloIgDoAAALAAEIXgW3YwAqAAAAAA==.',['万贱']='万贱归综:BAAAKgAECgIIAgAAAA==.',['三笠']='三笠阿克曼:BAAAKgAFFAQIBAAAAA==.',['三色']='三色灰:BAAAKgAECggIDgAAAA==.',['不朽']='不朽:BAAAKgADCgMIAwAAAA==.',['乌拉']='乌拉阁木:BAAAKgADCgUIBQAAAA==.',['九曲']='九曲桥:BAABKgAFFH8FAAIKAAUIkyItGAA6AQAKAAUIkyItGAA6AQAAAA==.',['乡村']='乡村猎户:BAAAKgAECggIDgAAAA==.',['乱七']='乱七八糟的:BAAAKgAECggICAAAAA==.',['二丫']='二丫史塔克:BAAAKgADCgcIBwAAAA==.',['二十']='二十年:BAAAKgAECgcIDAAAAA==.',['二队']='二队小德:BAAAKgAFFAQIBAAAAA==.',['云朵']='云朵团团:BAACKgAFFH8lAAIBAAgI7SBEAwAoAgABAAgI7SBEAwAoAgAqAAQKfxoAAgEACAhSIRMRAEkCAAEACAhSIRMRAEkCAAAA.',['交通']='交通工具:BAAAKgAECgcICAAAAA==.',['人间']='人间一场梦:BAAAKgAFFAIIAgAAAA==.',['修修']='修修小小:BAAAKgAFFAgIBAAAAA==.',['假假']='假假:BAAAKgAECggICAAAAA==.',['傻右']='傻右右:BAAAKgAECgQIAwAAAA==.',['光头']='光头大人:BAABKgAFFH8MAAIDAAgI9wt0BgAZAgADAAgI9wt0BgAZAgAAAA==.',['克洛']='克洛诺斯:BAAAKgAECgEIAQAAAA==.',['八雲']='八雲蓝:BAABKgAECn8VAAIFAAgIyyH0DgB3AgAFAAgIyyH0DgB3AgAAAA==.',['公主']='公主保镖:BAABKgAFFH8GAAIMAAYIJwb/EADsAAAMAAYIJwb/EADsAAAAAA==.',['兰斯']='兰斯烙特:BAAAKgAFFAQIBAAAAA==.',['别聊']='别聊了奶我:BAAAKgAFFAQIBAAAAA==.',['制裁']='制裁:BAAAKgADCgcIBwAAAA==.',['功夫']='功夫大熊貓:BAAAKgAFFAQIBAAAAA==.',['千里']='千里同风:BAAAKgAFFAQIBAABKgAFFAgIEwANAA0TAA==.',['千重']='千重:BAABKgAECn8VAAMNAAcIyBRVIQBLAQANAAcIDhRVIQBLAQAHAAYIcg6QxwAOAQAAAA==.',['午后']='午后悠怡:BAAAKgAFFAQIBAAAAA==.',['卡厄']='卡厄斯:BAAAKgAECggICAAAAA==.',['卡咩']='卡咩咩:BAABKgAECn8XAAIOAAcIjw8oSwDgAAAOAAcIjw8oSwDgAAAAAA==.',['卡皮']='卡皮吧啦:BAABKgAFFH8HAAIHAAYIRAuRBAB3AQAHAAYIRAuRBAB3AQAAAA==.',['印第']='印第安老斑鸠:BAAAKgAECggIEQAAAA==.',['原神']='原神猿神高手:BAABKgAFFH8HAAIPAAcIJRqTBQA1AgAPAAcIJRqTBQA1AgAAAA==.',['古德']='古德奈特:BAAAKgAFFAQIBAAAAA==.',['另壶']='另壶葱:BAAAKgAECgQIBgAAAA==.',['叫我']='叫我女王陛下:BAAAKgADCggICAAAAA==.',['吊儿']='吊儿啷当紫静:BAAAKgAECggICAAAAA==.',['含丶']='含丶笑:BAAAKgAFFAIIAwABKgAFFAMIFgAKAM0dAA==.',['周浦']='周浦内马尔:BAAAKgAFFAYIBAABKgAFFAgIDgADADcaAA==.',['咕咕']='咕咕叽:BAAAKgAFFAIIAgAAAA==.',['咕德']='咕德猫咛:BAABKgAFFH8ZAAIQAAUILyAQIQAZAQAQAAUILyAQIQAZAQAAAA==.',['哆啦']='哆啦艾梦:BAAAKgAECggICAAAAA==.',['啊啦']='啊啦喂:BAAAKgADCgMIAwAAAA==.',['啾啾']='啾啾:BAABKgAFFH8HAAIRAAQIFg1CEQD3AAARAAQIFg1CEQD3AAAAAA==.',['喀秋']='喀秋莎丶:BAAAKgAFFAQIBAAAAA==.',['喜欢']='喜欢死亡丶:BAACKgAFFH8FAAMFAAMIygG7TQBUAAAFAAIIBwK7TQBUAAASAAEIaAoBGAA1AAAqAAQKfxwAAxIACAjaEvI4AC4BABIACAjaEvI4AC4BAAUABwg9Boh+ALYAAAAA.',['喵咩']='喵咩咩:BAABKgAECn9BAAITAAgI6BpeGAAcAgATAAgI6BpeGAAcAgAAAA==.',['因幡']='因幡月夜:BAAAKgAFFAEIAQAAAA==.',['地狱']='地狱公爵:BAAAKgAFFAgIBAAAAA==.',['塞奈']='塞奈斯风行者:BAABKgAFFH8HAAIJAAQIER9wJADlAAAJAAQIER9wJADlAAAAAA==.',['墨燊']='墨燊:BAACKgAFFH8WAAMKAAMIzR1hJQDjAAAKAAMIzR1hJQDjAAAUAAEIBwKwHAAkAAAqAAQKfxcAAxQACAjHFrdDAKEAAAoABQgXGyeBALoAABQABQhWFLdDAKEAAAAA.',['夜神']='夜神月:BAABKgAFFH8IAAIIAAMINxISMgDMAAAIAAMINxISMgDMAAABKgAFFAgICwAIADsUAA==.',['大漠']='大漠孤烟弯:BAAAKgAFFAQIBAABKgAFFAgILQALAMMeAA==.',['大米']='大米咪:BAAAKgADCggICAAAAA==.',['大苇']='大苇:BAAAKgAFFAYIBAAAAA==.',['天弦']='天弦呤:BAAAKgAECgcIDgAAAA==.',['天罗']='天罗地网丨骑:BAAAKgAFFAgIAgAAAA==.',['奶量']='奶量超低:BAACKgAFFH8GAAIHAAQIuiIwCAA8AQAHAAQIuiIwCAA8AQAqAAQKfzgABAcACAiAIM0vAEACAAcACAiAIM0vAEACABUABwhiCA0sAP4AAA0AAQjQByZoABUAAAAA.',['妖族']='妖族圣男:BAAAKgAECggICQAAAA==.',['妙妙']='妙妙:BAAAKgAECgQICQAAAA==.妙妙喵喵:BAAAKgAECgcICQAAAA==.',['娴熟']='娴熟虎:BAACKgAFFH8SAAMWAAYI0SFFAQDPAQAWAAYI0SFFAQDPAQASAAEIXAMJHwAxAAAqAAQKf0kAAxIACAjwHhgSAEICABIACAjwHhgSAEICAAUACAjoEadFAHIBAAAA.',['孤傲']='孤傲独狼:BAAAKgAECgEIAQAAAA==.',['守护']='守护者乌瑟尔:BAAAKgAECgUIBQABKgAECggIFwAJAE8bAA==.',['安德']='安德斯巴鲁:BAAAKgAECggIDgAAAA==.',['安静']='安静成思:BAAAKgAFFAIIBAAAAA==.',['寒月']='寒月蓝牙:BAABKgAECn8gAAMXAAgITgxkUgD1AAAXAAgIOwxkUgD1AAAEAAgIzAJkYgBtAAAAAA==.',['小云']='小云之痛苦:BAABKgAECn82AAMEAAgI7g51QABnAQAEAAgItA51QABnAQAYAAgIygujHwA3AQAAAA==.',['小仓']='小仓优子:BAABKgAFFH8RAAMNAAYIZha2CgBOAQANAAYINRW2CgBOAQAHAAQIHBa9IADnAAAAAA==.',['小力']='小力飞道:BAAAKgAFFAIIAgAAAA==.',['小呀']='小呀小么牛:BAABKgAFFH8JAAIFAAYIGRZ7CwBFAQAFAAYIGRZ7CwBFAQAAAA==.',['小唐']='小唐不糖:BAAAKgAECgUIBQAAAA==.',['小小']='小小修修:BAACKgAFFH8FAAIBAAII8AQ0JwA5AAABAAII8AQ0JwA5AAAqAAQKf1IAAwEACAjxFI4vAIUBAAEACAjxFI4vAIUBAAIAAwjoBI2PADQAAAAA.小小的法斯:BAAAKgAFFAQIBAAAAA==.小小的酒仙:BAABKgAFFH8MAAIZAAQI7xV+DgDEAAAZAAQI7xV+DgDEAAAAAA==.小小的骑士:BAAAKgAFFAQIBAAAAA==.',['小白']='小白妖妖:BAAAKgAECgQIBAAAAA==.',['小能']='小能猫:BAAAKgAECggIEAAAAA==.',['小艾']='小艾莉丝:BAAAKgADCggICwAAAA==.',['小财']='小财迷:BAAAKgADCggICgAAAA==.',['小陆']='小陆:BAAAKgAFFAQIBAAAAA==.',['小黄']='小黄油美式:BAAAKgAECgEIAQAAAA==.',['尖脸']='尖脸雷公嘴:BAABKgAECn8YAAIPAAgIXRRcFgC9AQAPAAgIXRRcFgC9AQAAAA==.',['尤涅']='尤涅若:BAAAKgAFFAEIAQAAAA==.',['尼克']='尼克斯:BAAAKgAECggIEwAAAA==.',['尼德']='尼德霍格:BAAAKgAECgIIAgAAAA==.',['左右']='左右互博术:BAAAKgAECggICAAAAA==.',['左岸']='左岸咖啡:BAABKgAFFH8OAAMVAAYI1hRkCQASAQAVAAUI5BBkCQASAQAHAAEIgAPEVQA/AAAAAA==.',['左手']='左手的左边:BAAAKgAECggICAAAAA==.',['布莱']='布莱斯的邪能:BAAAKgADCggICAAAAA==.',['帅就']='帅就完事:BAAAKgAECgEIAQAAAA==.',['希望']='希望隐居:BAAAKgAECgYIBgAAAA==.',['希瑟']='希瑟拉:BAAAKgAFFAQIBAAAAA==.',['幻海']='幻海梦蝶:BAABKgAECn8wAAIKAAgIXB23HQAVAgAKAAgIXB23HQAVAgAAAA==.',['幽兰']='幽兰黛尔:BAAAKgAECgEIAQAAAA==.',['幽幽']='幽幽小叮当:BAABKgAFFH8OAAIYAAgIeCDkAQDDAgAYAAgIeCDkAQDDAgAAAA==.',['弎幺']='弎幺柒:BAAAKgAECggICAAAAA==.',['当当']='当当小红手儿:BAAAKgAFFAgIBAAAAA==.当当很满意:BAAAKgAECgYIBgAAAA==.',['影遁']='影遁看风景:BAABKgAFFH8jAAMUAAUIwhZRCwD4AAAUAAUIwhZRCwD4AAAKAAEIAABtLAAAAAAAAA==.',['德之']='德之风行者:BAABKgAFFH8UAAMQAAgIzRYDDwCuAQAQAAcI6hUDDwCuAQAOAAcIUAwWCgBlAQAAAA==.',['德玛']='德玛西亚:BAAAKgAFFAMIAwAAAA==.',['思离']='思离谱:BAAAKgAECgMIAwAAAA==.',['慕容']='慕容灬姼姼:BAAAKgAFFAIIAgAAAA==.慕容馨児:BAACKgAFFH8IAAIYAAYIjxzBBwDTAQAYAAYIjxzBBwDTAQAqAAQKf1EAAhgACAhsIgQNAK0CABgACAhsIgQNAK0CAAAA.',['我很']='我很忙:BAAAKgAECggICAAAAA==.',['我有']='我有小跟班:BAAAKgAECggIEwAAAA==.',['我来']='我来疼你:BAAAKgAECggICAAAAA==.',['我要']='我要的安逸:BAAAKgADCgIIAgAAAA==.',['战挚']='战挚:BAAAKgAECgUIDwAAAA==.',['战魂']='战魂:BAACKgAFFH8FAAIFAAII5xW/LQBfAAAFAAII5xW/LQBfAAAqAAQKf0kAAgUACAhvHp0XAEYCAAUACAhvHp0XAEYCAAAA.',['扎西']='扎西德:BAAAKgAECgEIAQAAAA==.',['拉图']='拉图修斯:BAAAKgAECgIIAgAAAA==.',['拉里']='拉里拉塔:BAAAKgAECgYIBgAAAA==.',['指尖']='指尖:BAABKgAFFH8IAAIVAAgIFQVzDADlAAAVAAgIFQVzDADlAAAAAA==.',['插标']='插标卖首之徒:BAAAKgAFFAMIAgAAAA==.',['敬山']='敬山遥:BAACKgAFFH8KAAIaAAMITh0ZEgDwAAAaAAMITh0ZEgDwAAAqAAQKfxQABBoACAhZGikhAMwBABoACAhZGikhAMwBAAIAAQirDVV/AC8AAAEAAQgABIaYACoAAAEqAAUUCAgEABsAAAAA.',['方脸']='方脸雷公嘴:BAAAKgAECgEIAQAAAA==.',['无声']='无声仿有声丶:BAAAKgAFFAEIAQAAAA==.',['无问']='无问東西:BAAAKgAFFAYIBAAAAA==.',['时光']='时光徽章:BAAAKgAECgYICAAAAA==.',['旺旺']='旺旺牙牙:BAACKgAFFH8LAAMPAAYIvBkoAQDVAQAPAAYIvBkoAQDVAQAcAAIIExIBBwB2AAAqAAQKf1MAAxwACAi8Hq0HAHECABwACAhHHq0HAHECAB0ACAj4FVMHAN0BAAAA.',['明月']='明月思霜:BAAAKgAECgUIBQAAAA==.',['星空']='星空下的童话:BAABKgAFFH8KAAMXAAgITxEsEgBWAQAXAAYIARUsEgBWAQAYAAQIDAwUFAAaAQAAAA==.',['晓晓']='晓晓鹿:BAEBKgAFFH8LAAMJAAYIfhwSEgB4AQAJAAYIvBsSEgB4AQAeAAMI7R04FQCTAAAAAA==.',['晴丶']='晴丶天:BAAAKgAECggIEAAAAA==.',['暖阳']='暖阳小兜兜:BAAAKgAFFAQIBAAAAA==.',['暗之']='暗之狂奔:BAACKgAFFH8IAAIQAAIIzhGlKwCGAAAQAAIIzhGlKwCGAAAqAAQKfxsAAxAACAjkHO0rABACABAACAjkHO0rABACAB8AAQheBSNGAA4AAAAA.',['暗夜']='暗夜银湾:BAAAKgAECgcIEQAAAA==.',['暗影']='暗影之铠:BAAAKgADCgYIBgAAAA==.',['暴富']='暴富小杰:BAAAKgAECgUIBQAAAA==.',['最后']='最后的时光:BAAAKgAECgYIBgAAAA==.',['最豆']='最豆的时光:BAAAKgAECgQIBQAAAA==.',['有点']='有点猫饼:BAAAKgAECggICAAAAA==.',['朗尼']='朗尼先生:BAABKgAECn8XAAIHAAgI/BtiLABtAQAHAAgI/BtiLABtAQAAAA==.',['杀戮']='杀戮战神:BAAAKgADCggIAQAAAA==.',['来快']='来快点:BAAAKgAECgMIAwAAAA==.',['核恩']='核恩棠:BAAAKgADCggICAAAAA==.核恩糖:BAAAKgAECgQIBAAAAA==.',['欧贝']='欧贝利斯:BAABKgAECn89AAQGAAgI+h5JDQAKAgAGAAgILBxJDQAKAgADAAgIGRwHMQC/AQAgAAYIihKoPwDaAAAAAA==.',['死亡']='死亡:BAAAKgADCggICAAAAA==.死亡中复活:BAAAKgAECgYIBwAAAA==.死亡弹药:BAAAKgAECggIDQAAAA==.',['死噬']='死噬:BAABKgAECn8ZAAIIAAgIISLNDwCkAgAIAAgIISLNDwCkAgAAAA==.',['毒奶']='毒奶十八式:BAABKgAFFH8GAAMOAAYI1A8CFwDoAAAOAAUIgBECFwDoAAAQAAEImyRPVABlAAABKgAFFAgIDwACAM4XAA==.',['水月']='水月大师:BAACKgAFFH8ZAAIZAAQIyw5uIwCVAAAZAAQIyw5uIwCVAAAqAAQKfxcAAhkACAhSGz4YACcCABkACAhSGz4YACcCAAAA.',['永恒']='永恒抹杀:BAABKgAFFH8GAAIPAAQIyRMyDADgAAAPAAQIyRMyDADgAAABKgAFFAgIEQAMAPEhAA==.',['江湖']='江湖醉牛:BAABKgAECn8YAAMOAAgIwgAwfwAiAAAOAAgIwgAwfwAiAAAQAAEIDgNj5gAWAAAAAA==.',['沙扬']='沙扬娜拉:BAABKgAECn8vAAMPAAgIhSVxAgDnAgAPAAgIESVxAgDnAgAcAAgIHiPLAwC8AgAAAA==.',['沫絔']='沫絔:BAAAKgAECgIIAgAAAA==.',['法型']='法型师:BAAAKgADCggIGgAAAA==.',['浩骑']='浩骑南防:BAABKgAFFH8JAAINAAQIgBKrDAC0AAANAAQIgBKrDAC0AAAAAA==.',['淡墨']='淡墨:BAABKgAFFH8LAAQBAAYIxhHCHQDUAAABAAUIJwrCHQDUAAAaAAMI1xlBGwCoAAACAAIIlRW+GgCRAAAAAA==.',['淡淡']='淡淡的云:BAAAKgAECggICwAAAA==.淡淡稻花香:BAAAKgADCggICAAAAA==.',['清火']='清火小柚子:BAAAKgAECgQIBQAAAA==.',['溜溜']='溜溜:BAAAKgADCggICAAAAA==.',['烬烽']='烬烽寒:BAAAKgAECggICAAAAA==.',['爷的']='爷的第七章:BAAAKgAECgEIAQAAAA==.',['爸爸']='爸爸猪:BAABKgAECn8gAAIJAAgIPReIHADCAQAJAAgIPReIHADCAQAAAA==.',['牛啦']='牛啦仆:BAAAKgAECggIDwAAAA==.牛啦梦:BAACKgAFFH8FAAIOAAIIGxMJMABYAAAOAAIIGxMJMABYAAAqAAQKfzwAAg4ACAiAIPcOAFMCAA4ACAiAIPcOAFMCAAAA.',['牛德']='牛德德:BAAAKgAFFAMIAwAAAA==.',['狐假']='狐假虎哥威:BAABKgAFFH8OAAMMAAgIIhcbDACVAQAMAAgIARYbDACVAQALAAMImBQ7FwDzAAAAAA==.',['狗熊']='狗熊洗铁路:BAABKgAFFH8GAAIaAAYI6QtaDgAbAQAaAAYI6QtaDgAbAQAAAA==.',['猫小']='猫小美:BAAAKgADCgUIBQAAAA==.',['猷拉']='猷拉诺斯:BAAAKgAECgEIAQAAAA==.',['王朝']='王朝陨落:BAAAKgAFFAYIBAAAAA==.',['玩牛']='玩牛牛的高手:BAAAKgAFFAQIBAAAAA==.',['留点']='留点情喂狗:BAAAKgAECgMIAwAAAA==.',['看我']='看我眼神行事:BAAAKgAFFAIIBAAAAA==.',['眠熊']='眠熊狩:BAABKgAFFH8GAAILAAYINREYDQBmAQALAAYINREYDQBmAQAAAA==.',['短尾']='短尾巴:BAACKgAFFH8FAAMMAAIIZg4uKgA8AAAMAAEI0A0uKgA8AAALAAEI+w4TYAA2AAAqAAQKf0oAAwwACAi4H4gRAEkCAAwACAidH4gRAEkCAAsAAwhaFT/UAIMAAAAA.',['祖师']='祖师婆:BAACKgAFFH8FAAQeAAII/R2sFwBnAAAeAAEIsSKsFwBnAAAJAAIIDhusLgBKAAAhAAEI6Q2ZHABAAAAqAAQKf0UABAkACAiOJOsXADQCAAkABwiMIusXADQCACEABQiHJNQeAJMBAB4AAwjnIBoeAOgAAAAA.',['神兜']='神兜兜的猫:BAAAKgADCgQIBAAAAA==.',['神猎']='神猎手:BAAAKgADCgcIBwAAAA==.',['秀气']='秀气小犄角:BAAAKgAECgYIBgAAAA==.',['秋之']='秋之残云:BAAAKgAECgQIBAAAAA==.',['穷少']='穷少爷:BAABKgAFFH8IAAIDAAQIPhqzEAD3AAADAAQIPhqzEAD3AAAAAA==.',['空谷']='空谷传声:BAAAKgAECgUIBQAAAA==.',['米且']='米且人:BAABKgAECn8wAAMgAAgIgAgEPADJAAAgAAgIqAQEPADJAAADAAUIHgloUwC/AAAAAA==.',['红栾']='红栾炮:BAAAKgAFFAEIAQAAAA==.',['红红']='红红双囍:BAABKgAECn8+AAIZAAgI9w92KABOAQAZAAgI9w92KABOAQAAAA==.',['红顶']='红顶水仙:BAAAKgADCgEIAQAAAA==.',['组撒']='组撒噶扎台型:BAAAKgADCgEIAgAAAA==.',['统一']='统一冰激凌:BAABKgAFFH8MAAIEAAMIowsyGQCxAAAEAAMIowsyGQCxAAAAAA==.',['网友']='网友小周:BAAAKgAFFAIIAgAAAA==.',['翻滚']='翻滚的肉丸子:BAAAKgAFFAQIBAAAAA==.',['老史']='老史:BAAAKgAECgIIAgAAAA==.',['老陳']='老陳:BAACKgAFFH8pAAMeAAcIcyPpAQCYAQAeAAcI1SDpAQCYAQAJAAMIEiN5MACsAAAqAAQKfxYAAh4ACAhfIc8FAB4CAB4ACAhfIc8FAB4CAAEqAAUUCAgSAB4ALxwA.',['耗子']='耗子扛枪:BAAAKgAECgIIAgAAAA==.',['艾斯']='艾斯特拉:BAAAKgAECgQICQAAAA==.',['花葬']='花葬无暇:BAABKgAFFH8PAAQYAAQI2hQkHwDZAAAYAAQIOREkHwDZAAAEAAMIWQhtHgCSAAAXAAIItg4TOwB1AAAAAA==.',['苇大']='苇大丶:BAAAKgAFFAgIBAAAAA==.',['莉亚']='莉亚德琳:BAABKgAFFH8HAAIHAAYIFhivGwCGAQAHAAYIFhivGwCGAQAAAA==.',['菲尼']='菲尼克丝:BAABKgAECn8xAAMEAAgI9hkpKQDXAQAEAAgI9hkpKQDXAQAYAAgI7wnhIwATAQAAAA==.',['萨伊']='萨伊卡:BAABKgAFFH8JAAMLAAYIDRULDgBOAQALAAUIWRkLDgBOAQAMAAMIkQYbOQCSAAABKgAFFAgIFAALAK8jAA==.',['萬歲']='萬歲:BAAAKgAECgYICgAAAA==.',['落叶']='落叶残阳:BAAAKgAECgIIAgAAAA==.',['蒼月']='蒼月丿刻印:BAAAKgADCggICAAAAA==.',['蓝黑']='蓝黑色的忧伤:BAACKgAFFH8FAAIaAAIIMQZwKABPAAAaAAIIMQZwKABPAAAqAAQKfx4AAhoACAinGBcbAP4BABoACAinGBcbAP4BAAAA.',['蛋仔']='蛋仔派对:BAAAKgAECggICAAAAA==.',['蛋蛋']='蛋蛋有钱花:BAABKgAFFH8IAAIHAAgIhxqrBQB1AgAHAAgIhxqrBQB1AgAAAA==.',['蜜糖']='蜜糖有毒:BAAAKgAECgMIAwAAAA==.蜜糖橙:BAACKgAFFH8FAAIHAAIIfhXhdwB6AAAHAAIIfhXhdwB6AAAqAAQKf00AAwcACAg9IysXAKoCAAcACAg9IysXAKoCAA0AAQiMBOBnABYAAAAA.',['血翼']='血翼龍九:BAAAKgADCggICAAAAA==.',['術爷']='術爷:BAACKgAFFH8pAAMeAAYI9iSwAAAIAgAeAAYI8ySwAAAIAgAJAAYIUx6ZAQDaAQAqAAQKfxoABAkACAh0IFgkAOwBAAkACAibHFgkAOwBAB4ABQgpHHoeAPwAACEAAQiWEa51AEEAAAEqAAUUCAgSAB4ALxwA.',['西瓜']='西瓜德:BAAAKgAECgIIAgAAAA==.西瓜的皮:BAACKgAFFH8MAAMLAAMIShufRACOAAALAAII7xufRACOAAAMAAII+BcOQAB5AAAqAAQKfxwAAwsACAipIgAlAGACAAsACAjaHwAlAGACAAwABQhYHzIgANIBAAAA.西瓜籽:BAAAKgAECgMIAwAAAA==.',['言叶']='言叶之森:BAAAKgAECgQIAQAAAA==.',['诡秘']='诡秘:BAAAKgAFFAgIBAAAAA==.',['谈谈']='谈谈:BAAAKgAFFAgIBAAAAA==.',['貝恩']='貝恩血蹄:BAAAKgAECggIEAAAAA==.',['赛博']='赛博坦之牙:BAAAKgAECgUIBwAAAA==.',['赫卡']='赫卡特:BAAAKgAECggICAAAAA==.',['赫菲']='赫菲斯乇斯:BAAAKgAECggICAAAAA==.',['超级']='超级米饭:BAAAKgAECgUIBQAAAA==.',['跛豪']='跛豪:BAAAKgAECgQIBAAAAA==.',['踏雪']='踏雪風無痕:BAAAKgADCgcIBwAAAA==.',['这次']='这次射哪里:BAAAKgAFFAIIAgAAAA==.',['迷了']='迷了路的鹿:BAACKgAFFH8FAAIYAAIIPwwbKgByAAAYAAIIPwwbKgByAAAqAAQKf1MAAxgACAjuHMAKAC0CABgACAjuHMAKAC0CAAQABQiCEUZvALwAAAAA.',['追风']='追风小满:BAAAKgAECgMIAwAAAA==.',['邪念']='邪念丶天生:BAAAKgADCgIIAgAAAA==.',['邪能']='邪能侵蚀了我:BAAAKgAECgMIAwAAAA==.',['郁闷']='郁闷的牛牛:BAABKgAECn8WAAMGAAgIIBrVDwDjAQAGAAgIIBrVDwDjAQADAAIIKg4RNwBBAAAAAA==.郁闷的龙战:BAABKgAECn8dAAMGAAgIwxaIGwBZAQAGAAgInRGIGwBZAQADAAUI3RTIHQACAQAAAA==.',['醉牛']='醉牛:BAAAKgAECgEIAQAAAA==.',['醒来']='醒来见崖柏:BAAAKgAFFAIIAgAAAA==.',['长缨']='长缨:BAABKgAFFH8GAAIIAAYICQzQGABXAQAIAAYICQzQGABXAQAAAA==.',['门之']='门之匙:BAAAKgADCgYIBgAAAA==.',['阿佛']='阿佛洛荻忒:BAAAKgAFFAEIAQAAAA==.',['阿猪']='阿猪斩舰刀:BAABKgAFFH8OAAIDAAgINxpRAgCjAQADAAgINxpRAgCjAQAAAA==.',['雙肠']='雙肠捣蛋:BAABKgAFFH8KAAIJAAYI7B3HDwCTAQAJAAYI7B3HDwCTAQAAAA==.',['雪落']='雪落:BAAAKgAECgEIAQAAAA==.',['青螭']='青螭:BAABKgAFFH8GAAIiAAMIkg98BQCIAAAiAAMIkg98BQCIAAAAAA==.',['鞋子']='鞋子特大呺:BAAAKgAECgMIAwAAAA==.',['颓废']='颓废的史哥:BAAAKgAFFAIIAgAAAA==.',['风月']='风月无边:BAAAKgADCggICAAAAA==.',['风行']='风行邪骑:BAABKgAFFH8QAAIIAAgI/RrrBgAlAgAIAAgI/RrrBgAlAgAAAA==.',['风走']='风走过的天空:BAAAKgAFFAgIBAAAAA==.',['马向']='马向阳术记:BAAAKgAECgUIBQAAAA==.',['鲩鲤']='鲩鲤鲍鱼:BAAAKgADCgQIBAAAAA==.',['鸡博']='鸡博士:BAAAKgADCgMIAwAAAA==.',['麦崖']='麦崖:BAABKgAECn8iAAIHAAgIRx0ZQgApAgAHAAgIRx0ZQgApAgAAAA==.',['麦麦']='麦麦噱鳕:BAABKgAFFH8KAAIEAAMIkRTsFgC6AAAEAAMIkRTsFgC6AAAAAA==.麦麦嚼鳕:BAABKgAFFH8FAAMVAAMIsSFCEQC4AAAVAAIIph9CEQC4AAAHAAIITwQ8gABkAAAAAA==.',['默默']='默默的玥岚:BAACKgAFFH8FAAMZAAIIawwTLQBjAAAZAAIIawwTLQBjAAATAAEIfQdZIAA7AAAqAAQKfxYAAhkACAgKGFwoALkBABkACAgKGFwoALkBAAAA.默默的锦岚:BAAAKgAECggIBAAAAA==.',['黯丨']='黯丨岚:BAABKgAFFH8XAAMCAAYIuBnsCQB5AQACAAYIDRPsCQB5AQABAAYI2hdsCgAqAQAAAA==.',['龙魂']='龙魂之最:BAABKgAECn8pAAILAAgIEBr6KAANAgALAAgIEBr6KAANAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end