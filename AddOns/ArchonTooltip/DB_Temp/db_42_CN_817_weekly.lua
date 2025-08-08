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
 local lookup = {'Mage-Frost','Mage-Arcane','Warrior-Fury','DemonHunter-Havoc','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','Warrior-Arms','Warrior-Protection','Warlock-Affliction','Evoker-Devastation','DemonHunter-Vengeance','Monk-Mistweaver','Warlock-Destruction','Druid-Balance','Druid-Guardian','Warlock-Demonology','Priest-Holy','Druid-Restoration','Shaman-Restoration','Monk-Windwalker','DeathKnight-Blood','Shaman-Elemental','Priest-Discipline','Rogue-Assassination','Paladin-Protection','Unknown-Unknown','Rogue-Subtlety','Mage-Fire','Paladin-Holy','Evoker-Preservation','Shaman-Enhancement','Priest-Shadow','Rogue-Outlaw',}; local provider = {region='CN',realm='萨格拉斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Aloe:BAAAKgAFFAYIAgAAAA==.',An='Animalstt:BAAAKgAECgQIBQAAAA==.',Br='Breeze:BAAAKgAFFAYIAgAAAA==.',Ca='Calldeath:BAAAKgADCggIDwAAAA==.',Da='Dany:BAAAKgAECgIIAgAAAA==.',Fa='Fancy:BAAAKgAECgYICAAAAA==.',Fe='Fenlix:BAABKgAECn8ZAAMBAAgImB7HDgBZAgABAAgImB7HDgBZAgACAAII6giKkQBBAAAAAA==.',Fi='Fin:BAAAKgAFFAQIBAAAAA==.',Ha='Hardtosay:BAAAKgAECggICAAAAA==.',He='Hellward:BAABKgAFFH8IAAIDAAgIaguWBgAVAgADAAgIaguWBgAVAgAAAA==.',Ju='Juliet:BAABKgAFFH8IAAIEAAgItRB5CAADAgAEAAgItRB5CAADAgAAAA==.',Ki='Kilkin:BAAAKgAECgYIBwAAAA==.',Ku='Kukalon:BAABKgAFFH8GAAIDAAYI0RgPCwCZAQADAAYI0RgPCwCZAQAAAA==.',Li='Link:BAABKgAFFH8GAAMFAAYIyQ4zMQCqAAAFAAQIrRQzMQCqAAAGAAII8wWoTAB2AAAAAA==.',Na='Natsuki:BAAAKgADCggIDQAAAA==.',No='Noxnnox:BAAAKgAFFAQIBAAAAA==.',Re='Reddead:BAABKgAFFH8RAAMHAAMI8x8qBgAPAQAHAAMI8x8qBgAPAQAIAAIImRUQRACPAAAAAA==.Reilay:BAABKgAFFH8GAAIJAAMIXQ/VJgDMAAAJAAMIXQ/VJgDMAAAAAA==.',Ro='Romeo:BAABKgAFFH8JAAIKAAgIPg/wBADqAQAKAAgIPg/wBADqAQAAAA==.',Sk='Skak:BAAAKgADCgIIAgAAAA==.',So='Sorcerer:BAAAKgADCggIAwAAAA==.',Sp='Speechlessne:BAAAKgAECggIEgAAAA==.',Wa='Waremperor:BAABKgAFFH8LAAQDAAcIhg4sDwBiAQADAAQI+RcsDwBiAQALAAMI6wEyFABaAAAKAAEIzgIBLQAuAAAAAA==.',Wi='Windranger:BAAAKgADCggICAAAAA==.',Za='Zatanna:BAABKgAFFH8TAAIMAAUImCC9AgB4AQAMAAUImCC9AgB4AQAAAA==.',['一份']='一份好运:BAABKgAFFH8KAAIJAAgIHgwgEQDWAQAJAAgIHgwgEQDWAQAAAA==.',['一千']='一千念:BAAAKgAECgEIAQAAAA==.',['一只']='一只好狐:BAAAKgAFFAgIBAAAAA==.一只小青龙:BAABKgAFFH8FAAINAAQIOx8xEgDDAAANAAQIOx8xEgDDAAAAAA==.',['一心']='一心想嫁牛:BAAAKgAECgEIAQAAAA==.',['七殺']='七殺:BAAAKgAFFAQIBAAAAA==.',['七石']='七石头:BAABKgAFFH8KAAMGAAcIzxo7DwCDAQAGAAYIrRw7DwCDAQAFAAQIZxUCGAAoAQAAAA==.',['三万']='三万敌法秒躺:BAABKgAECn8YAAMEAAgI7yC2FQCEAgAEAAgI7yC2FQCEAgAOAAEI4xXNXgA8AAAAAA==.',['丶忧']='丶忧落:BAAAKgADCggICAAAAA==.',['丹玄']='丹玄子:BAABKgAFFH8SAAIPAAgIdx5EAwBJAgAPAAgIdx5EAwBJAgAAAA==.',['乱猛']='乱猛猛:BAAAKgAECgMIAwAAAA==.',['二趾']='二趾残:BAAAKgAFFAQIBAAAAA==.',['云篆']='云篆:BAABKgAFFH8IAAIQAAgIyBbBBAA0AgAQAAgIyBbBBAA0AgAAAA==.',['人间']='人间荒糖:BAAAKgADCggICAAAAA==.',['今晚']='今晚打老狐:BAAAKgAECggIDgAAAA==.今晚打老虎:BAAAKgADCgQIBAAAAA==.',['仰望']='仰望半夜星空:BAABKgAECn8kAAMRAAgI4BmBPgC8AQARAAgIGhmBPgC8AQASAAgIGgacGgDMAAAAAA==.',['伊利']='伊利尔丹:BAAAKgADCgMIAwAAAA==.',['伏都']='伏都:BAABKgAFFH8OAAQQAAgI+SMKAQDoAgAQAAgI+SMKAQDoAgAMAAMI2BvdBwDqAAATAAEIAAABIgAAAAAAAA==.',['你的']='你的蕾丝:BAAAKgAFFAQIBAABKgAFFAgIBgAUAKsLAA==.',['健忘']='健忘的圣光:BAAAKgAECggIDgAAAA==.',['傳説']='傳説中的聖騎:BAAAKgAFFAIIAgAAAA==.',['克勞']='克勞德:BAACKgAFFH8XAAMRAAcIMxHdBgA8AQARAAUIlRndBgA8AQAVAAYIiBQsBQAnAQAqAAQKfxkAAxUACAg2FA8nAJcBABUACAg2FA8nAJcBABEABwgHIbtJAJABAAAA.',['六七']='六七朵茉莉:BAABKgAFFH8JAAIPAAQIphSSEQDfAAAPAAQIphSSEQDfAAAAAA==.',['兽四']='兽四两:BAABKgAECn8aAAIWAAgI0w7NHgA5AQAWAAgI0w7NHgA5AQAAAA==.',['兽族']='兽族小法:BAAAKgADCgcIBwAAAA==.',['冷月']='冷月葬心魂:BAAAKgAECgUIBQAAAA==.',['几百']='几百个戰士:BAAAKgAECggICQAAAA==.',['凯东']='凯东:BAABKgAFFH8GAAIDAAYIoh1aCwCVAQADAAYIoh1aCwCVAQAAAA==.',['凯恩']='凯恩丶猎蹄:BAAAKgAECggIDAAAAA==.',['凯撒']='凯撒君:BAAAKgAECgYIDAAAAA==.',['凯萨']='凯萨:BAAAKgAECgIIAgAAAA==.',['凹凸']='凹凸魔:BAAAKgADCgIIAQAAAA==.',['刀锋']='刀锋之影:BAABKgAECn8VAAIEAAgIuBoGJADoAQAEAAgIuBoGJADoAQAAAA==.',['刚刃']='刚刃研磨:BAABKgAFFH8OAAIXAAgIvAw6BwCQAQAXAAgIvAw6BwCQAQAAAA==.',['加尔']='加尔鲁什酋长:BAAAKgAECgYIDgAAAA==.',['北宫']='北宫毛球:BAAAKgAECgEIAgAAAA==.',['北極']='北極星的夜:BAAAKgAFFAcIAwAAAA==.',['匹夫']='匹夫:BAAAKgAFFAgIBAAAAA==.',['千瓦']='千瓦家的福禄:BAAAKgAECggIDQAAAA==.',['南极']='南极的守护:BAAAKgAFFAQIBAABKgAFFAgIDAACACITAA==.',['博麗']='博麗霊夢:BAABKgAFFH8OAAIYAAYINBu0CQB6AQAYAAYINBu0CQB6AQAAAA==.',['卞包']='卞包包的壮壮:BAAAKgAFFAgIBAAAAA==.',['卡玛']='卡玛扎尔:BAABKgAFFH8hAAMQAAgIURvFBQA7AgAQAAgIURvFBQA7AgATAAEIjwhyMAA5AAAAAA==.',['卡皮']='卡皮巴拉:BAAAKgADCgUIBQAAAA==.',['叁伍']='叁伍柒:BAAAKgAECgYIBgAAAA==.',['变成']='变成土豆:BAABKgAFFH8GAAIEAAQIkxWcFADuAAAEAAQIkxWcFADuAAABKgAFFAgIDgAQAPkhAA==.',['叠加']='叠加力量:BAAAKgAFFAgIBAAAAA==.',['古丶']='古丶尔丶丹丶:BAABKgAFFH8GAAIQAAYItRh/EwBqAQAQAAYItRh/EwBqAQAAAA==.',['可恶']='可恶的尐弟弟:BAAAKgADCgEIAQAAAA==.',['可爱']='可爱囡囡:BAAAKgAECgYICwAAAA==.',['名侦']='名侦探阿狸:BAABKgAFFH8GAAIWAAIIdxyvIwCLAAAWAAIIdxyvIwCLAAAAAA==.',['咔皮']='咔皮巴啦:BAABKgAFFH8UAAMWAAQIXhxeIQDzAAAWAAQIXhxeIQDzAAAZAAQIRRRsCgDcAAAAAA==.咔皮巴拉:BAABKgAFFH8KAAIJAAYIxCN+EADcAQAJAAYIxCN+EADcAQAAAA==.',['咬乳']='咬乳师琻度:BAAAKgAFFAIIAgAAAA==.',['咸鱼']='咸鱼不想翻身:BAABKgAFFH8IAAMWAAYIaQu0FAAyAQAWAAYIaQu0FAAyAQAZAAIIzQ5nHAA9AAABKgAFFAgIEQAaADMcAA==.',['品质']='品质源于热爱:BAAAKgAECgYICAAAAA==.',['哈七']='哈七嗒八:BAAAKgAECgcIDAAAAA==.',['嘿喂']='嘿喂狗:BAABKgAFFH8LAAMHAAMIwwsHDQCZAAAHAAMIDgoHDQCZAAAIAAIIOAfOTABtAAAAAA==.',['圣光']='圣光征服者:BAAAKgADCgIIAgAAAA==.圣光捕快:BAAAKgAECgIIAgAAAA==.圣光闪闪:BAAAKgADCgcIBwAAAA==.',['垂直']='垂直面:BAACKgAFFH8JAAMHAAMIWgsiDACpAAAIAAMIPgtMOgCzAAAHAAMIlAYiDACpAAAqAAQKfyUAAwgACAhEHlAlAPMBAAgACAhEHlAlAPMBAAcAAQg0FzAnAEsAAAAA.',['堕落']='堕落抉择:BAABKgAFFH8IAAIbAAgI6gz1BgANAgAbAAgI6gz1BgANAgAAAA==.堕落炽天使:BAAAKgAECggICgAAAA==.',['塞勒']='塞勒涅丨晨星:BAABKgAFFH8KAAIGAAQIhSItGwAnAQAGAAQIhSItGwAnAQAAAA==.',['墨格']='墨格瑞拉:BAABKgAFFH8IAAIYAAgIoAwzBQCMAQAYAAgIoAwzBQCMAQAAAA==.',['壹兌']='壹兌羊:BAAAKgAECgUIBQAAAA==.',['壹壹']='壹壹:BAABKgAFFH8OAAMJAAMIkBaXJQDRAAAJAAMIkBaXJQDRAAAcAAII+QfYJgBXAAAAAA==.',['壹萌']='壹萌叁肆年:BAAAKgAFFAQIBAAAAA==.',['夜空']='夜空下的牛:BAABKgAFFH8PAAMVAAcIehHZCwBIAQAVAAcIehHZCwBIAQARAAQI+CE+DwD/AAAAAA==.',['大吉']='大吉熊:BAAAKgAECgEIAQAAAA==.',['大姜']='大姜鸭:BAABKgAECn8nAAMGAAgI0B8TDQBDAgAGAAgI0B8TDQBDAgAFAAgILwzhWwCwAAAAAA==.',['大白']='大白丿丶:BAABKgAFFH8GAAIDAAYIBxWhDQB3AQADAAYIBxWhDQB3AQABKgAFFAgIAgAdAAAAAA==.',['大耳']='大耳朵:BAAAKgADCggICAAAAA==.',['大腿']='大腿装饰:BAAAKgADCgcICAAAAA==.',['大辫']='大辫子:BAAAKgAFFAQIBAAAAA==.',['大风']='大风起心:BAAAKgAECgUICgAAAA==.',['天上']='天上天下无双:BAABKgAECn8YAAIJAAgIiyM8FAC5AgAJAAgIiyM8FAC5AgAAAA==.',['天天']='天天流浪汉:BAABKgAFFH8KAAMRAAYI6RJmHgDEAAARAAQIcB5mHgDEAAAVAAQIMQqzDgC9AAAAAA==.',['天煞']='天煞孤风:BAACKgAFFH8KAAMeAAMI6AraBQCeAAAeAAMICwbaBQCeAAAbAAIIVw7JIwCKAAAqAAQKfyQAAxsACAg5ErQcAH8BAB4ACAh0DwUXAIcBABsACAgzD7QcAH8BAAAA.天煞无畏:BAAAKgAECgYIBgAAAA==.',['天降']='天降圣人:BAAAKgAFFAIIAgAAAA==.',['奔雷']='奔雷手毛太來:BAAAKgAECggIDwAAAA==.',['套龙']='套龙的汉子:BAABKgAFFH8IAAIfAAgISCH6AwBdAgAfAAgISCH6AwBdAgAAAA==.',['奶到']='奶到空蓝:BAAAKgAECgEIAQAAAA==.',['奶德']='奶德不奶:BAAAKgAECgIIAgAAAA==.',['好一']='好一头小德:BAAAKgADCggICAAAAA==.',['如风']='如风随影:BAAAKgAECgQIDQAAAA==.',['姹紫']='姹紫嫣红:BAAAKgAECggICAAAAA==.',['子簇']='子簇:BAAAKgAECgIIAgAAAA==.',['安室']='安室透:BAAAKgADCgIIAgAAAA==.',['安德']='安德莉亚:BAAAKgAECgYIBwAAAA==.',['宝宝']='宝宝冲锋:BAAAKgAECgYIBgAAAA==.',['宵黄']='宵黄泉:BAAAKgAECggIEAAAAA==.',['小小']='小小波:BAAAKgAFFAQIBAAAAA==.小小蕊:BAAAKgAECgIIAgAAAA==.',['小抄']='小抄手:BAABKgAFFH8KAAMZAAYIlwvPCQAtAQAZAAYIlwvPCQAtAQAWAAQIGwhKGQC/AAABKgAFFAgIBAAdAAAAAA==.',['小波']='小波:BAABKgAFFH8KAAIcAAYI8g6mAwA8AQAcAAYI8g6mAwA8AQAAAA==.',['小米']='小米饭大米饭:BAABKgAFFH8KAAMfAAYIIBS0BQCqAQAfAAYITRG0BQCqAQABAAQIexkeBwD1AAAAAA==.',['小魄']='小魄罗:BAABKgAECn8VAAIIAAcIXRtWMwCoAQAIAAcIXRtWMwCoAQAAAA==.',['岳峙']='岳峙雷行:BAABKgAFFH8IAAIKAAgIRhimAgBQAgAKAAgIRhimAgBQAgAAAA==.',['左狼']='左狼右狈:BAACKgAFFH8VAAIUAAUI6B1nDABdAQAUAAUI6B1nDABdAQAqAAQKfyMAAhQACAjTIyUGALUCABQACAjTIyUGALUCAAAA.',['布劳']='布劳缪克丝:BAAAKgAFFAYIAwABKgAFFAgICAAYAL0eAA==.',['希望']='希望祷言:BAAAKgAFFAMIAwAAAA==.',['帕诺']='帕诺雷德:BAAAKgADCgcIBwAAAA==.',['干妈']='干妈:BAAAKgAECgMIAwAAAA==.',['幽蓝']='幽蓝冰滴:BAABKgAECn8YAAIYAAYIZxFDKwDxAAAYAAYIZxFDKwDxAAAAAA==.',['弃暗']='弃暗投明:BAAAKgAFFAMIAwAAAA==.',['弍利']='弍利丹:BAAAKgAFFAQIBAAAAA==.',['心神']='心神凝聚:BAAAKgAECgYIAgAAAA==.',['忘了']='忘了初心:BAAAKgADCgYIBgAAAA==.',['忧落']='忧落丶:BAAAKgADCggIEQAAAA==.忧落的小德:BAAAKgAFFAQIBAAAAA==.',['急奔']='急奔的蜗牛:BAAAKgADCgIIAgAAAA==.',['恐惧']='恐惧降临灬灬:BAAAKgAECggIEwAAAA==.',['情剑']='情剑山河:BAAAKgAFFAQIBAAAAA==.',['慕南']='慕南栀:BAABKgAFFH8GAAIFAAYIdSH+AgBKAQAFAAYIdSH+AgBKAQABKgAFFAQIAQAdAAAAAA==.',['我上']='我上了加好我:BAABKgAFFH8KAAIJAAYI9BUKJwBMAQAJAAYI9BUKJwBMAQAAAA==.',['我也']='我也不想的:BAAAKgAECggIBwAAAA==.',['我又']='我又岂能不笑:BAAAKgAFFAIIAgAAAA==.',['拉科']='拉科西丝:BAABKgAFFH8MAAIgAAQIcxeBCwDxAAAgAAQIcxeBCwDxAAAAAA==.',['搞柒']='搞柒搞捌:BAAAKgADCgIIAgAAAA==.',['携酒']='携酒寻芳去:BAAAKgADCggICQAAAA==.',['新月']='新月白天后:BAABKgAFFH8GAAIJAAYInBKUKQBBAQAJAAYInBKUKQBBAQAAAA==.',['方小']='方小猫猫:BAABKgAFFH8QAAIPAAQIICBJCQAdAQAPAAQIICBJCQAdAQAAAA==.',['无人']='无人在意:BAAAKgAECgYICgAAAA==.',['无证']='无证老司基:BAAAKgAECgQIBQAAAA==.',['易大']='易大師:BAAAKgAECggICAAAAA==.',['星辰']='星辰耀天:BAAAKgAFFAgIAgAAAA==.',['是也']='是也非耶:BAABKgAFFH8YAAMUAAYIsiJGCACkAQAUAAYIkR9GCACkAQAaAAQIDiEqBwAkAQABKgAFFAgIEgAaAGQaAA==.',['是耶']='是耶非也:BAABKgAFFH8GAAIIAAYIugJbEQDhAAAIAAYIugJbEQDhAAAAAA==.',['是谁']='是谁青春无悔:BAAAKgAFFAEIAQAAAA==.',['時廿']='時廿以後:BAABKgAFFH8dAAIDAAUI8RvqCwBPAQADAAUI8RvqCwBPAQAAAA==.',['晓寒']='晓寒意浓:BAAAKgAECgEIAQAAAA==.',['景之']='景之:BAABKgAFFH8IAAMhAAgIXAtEAwAZAQAhAAYIiAlEAwAZAQANAAIIVBQ8KQCVAAAAAA==.',['暗夜']='暗夜牛牛:BAABKgAECn8YAAIJAAgIhwsHzwACAQAJAAgIhwsHzwACAQAAAA==.暗夜闪闪:BAABKgAECn8VAAIIAAYIFRc3WQBcAQAIAAYIFRc3WQBcAQAAAA==.',['暮色']='暮色迷离:BAAAKgAECgYICAAAAA==.',['暴怒']='暴怒丨霜凌:BAAAKgAFFAEIAQAAAA==.暴怒的猕猴桃:BAABKgAFFH8IAAIYAAYIfRLjAwBSAQAYAAYIfRLjAwBSAQAAAA==.',['最後']='最後的希望:BAAAKgAECgYIBgAAAA==.',['月之']='月之哀伤:BAAAKgAECggIDwAAAA==.',['月明']='月明多被云妨:BAAAKgAECgQIBwAAAA==.',['朔阳']='朔阳:BAAAKgAFFAYIBAAAAA==.',['杂特']='杂特嘻嘻:BAAAKgADCgIIAgAAAA==.',['林落']='林落葵:BAAAKgAECgYIBQAAAA==.',['查理']='查理兹塞隆:BAAAKgAFFAEIAQAAAA==.',['桃丶']='桃丶:BAECKgAFFH8hAAMiAAYICBQcCwD4AAAiAAQIiBAcCwD4AAAWAAUIRxUYJQDiAAAqAAQKfzwAAyIACAjvH/MNAGoCACIACAjvH/MNAGoCABYABQgwGgRDAGsBAAEqAAUUCAgGACIArhMA.',['梓熙']='梓熙:BAAAKgAECgMIAwAAAA==.',['橙色']='橙色海豚:BAAAKgAECgIIAgAAAA==.',['欢乐']='欢乐送:BAAAKgAECgEIAQAAAA==.',['死尸']='死尸级玩家:BAAAKgADCgQIBAAAAA==.',['水光']='水光粼粼:BAAAKgAECgYIBgAAAA==.',['汪凌']='汪凌勇:BAAAKgAFFAQIBAAAAA==.',['法尔']='法尔肯:BAABKgAFFH8OAAQQAAYIjBIWFwBKAQAQAAYIPg8WFwBKAQAMAAMI5BLQCgDVAAATAAMIqxQvDQCMAAABKgAFFAgICAAQAPkUAA==.',['法爷']='法爷不想上班:BAAAKgAECggIDwAAAA==.',['泥头']='泥头车:BAAAKgADCggICAAAAA==.',['洛丹']='洛丹伦的回忆:BAAAKgAECgEIAgAAAA==.',['洛伽']='洛伽恩:BAABKgAFFH8NAAIJAAYI+RhQFwCiAQAJAAYI+RhQFwCiAQAAAA==.',['流苏']='流苏晚晴:BAAAKgAECgEIAQAAAA==.',['消失']='消失的她:BAABKgAFFH8GAAIbAAYI3h12CwCVAQAbAAYI3h12CwCVAQAAAA==.',['消逝']='消逝乄乄:BAAAKgAECgYIBgAAAA==.消逝亾:BAAAKgAFFAMIAwAAAA==.',['溜溜']='溜溜大顺:BAAAKgAECgQIBQAAAA==.',['灵圣']='灵圣:BAABKgAFFH8FAAMUAAQIjhXiLQCNAAAUAAMIhhjiLQCNAAAjAAIILATJIgBRAAAAAA==.',['烛九']='烛九阴:BAAAKgAECgcICgAAAA==.',['烤糊']='烤糊的羊:BAAAKgAECgYIBgAAAA==.',['無心']='無心:BAABKgAFFH8IAAMQAAQIeR82DwDsAAAQAAQIeR82DwDsAAATAAEIAADZJAAAAAABKgAFFAgIBgAfAOgaAA==.',['熔岩']='熔岩冰激凌:BAAAKgAECgIIAgAAAA==.',['牙疼']='牙疼:BAAAKgAECgIIAgAAAA==.',['牛啃']='牛啃菠萝:BAABKgAECn8fAAIWAAgIoRvOHQAVAgAWAAgIoRvOHQAVAgAAAA==.',['牛德']='牛德草:BAAAKgADCggICAAAAA==.',['狐妖']='狐妖鸡:BAAAKgAECgQIBwAAAA==.',['独倚']='独倚丨烟花笑:BAAAKgADCgYIBgAAAA==.',['狼铛']='狼铛:BAABKgAFFH8TAAIkAAQIdR8pAwAJAQAkAAQIdR8pAwAJAQAAAA==.',['猫扑']='猫扑:BAAAKgAFFAgIBAAAAA==.',['猫猫']='猫猫萨满:BAABKgAECn8eAAIWAAgIlRpUJAD/AQAWAAgIlRpUJAD/AQAAAA==.',['琅嬛']='琅嬛:BAAAKgADCggICAAAAA==.',['瓦里']='瓦里安烏瑞恩:BAAAKgAFFAgIAgAAAA==.',['疚瘋']='疚瘋:BAAAKgADCgQIBAAAAA==.',['白斯']='白斯月:BAABKgAFFH8MAAMBAAYIPxkIBACuAQABAAYIPxkIBACuAQAfAAQIjh2NGQDdAAAAAA==.',['眼神']='眼神充满智慧:BAABKgAFFH8FAAMiAAMIwAKkGgBwAAAiAAMIgQKkGgBwAAAZAAIImQFKJgBFAAAAAA==.',['空山']='空山凝云:BAAAKgAFFAgIBAAAAA==.',['童年']='童年:BAAAKgADCgQIBAAAAA==.',['精灵']='精灵萌可:BAAAKgAECgYICgAAAA==.',['缘起']='缘起缘灭:BAAAKgADCggICAAAAA==.',['罗兰']='罗兰之歌:BAABKgAFFH8FAAICAAMIKwozIwDWAAACAAMIKwozIwDWAAAAAA==.',['羅羅']='羅羅亞索隆:BAABKgAECn8dAAMDAAgINRluIADPAQADAAgINRluIADPAQAKAAEIAAACcwAAAAAAAA==.',['羞花']='羞花闭曰:BAABKgAECn8UAAIGAAgIGh1nNQDQAQAGAAgIGh1nNQDQAQAAAA==.',['老衲']='老衲说:BAAAKgAECgcICgAAAA==.',['聖使']='聖使:BAABKgAFFH8IAAIJAAgI5w24DgDuAQAJAAgI5w24DgDuAQAAAA==.',['至尊']='至尊无敌:BAAAKgADCggIGQAAAA==.至尊无敌大佬:BAAAKgADCgYIBgAAAA==.至尊无敌大哥:BAAAKgADCggIFgAAAA==.至尊无敌瑶妹:BAAAKgADCggICAAAAA==.至尊无敌瑶瑶:BAAAKgADCggIBAAAAA==.至尊无敌痞子:BAAAKgADCggICgAAAA==.至尊无敌财神:BAAAKgADCggIEAAAAA==.至尊猛哥:BAAAKgADCggICQAAAA==.',['般若']='般若波罗密:BAAAKgAECgYIBgAAAA==.',['艾斯']='艾斯德斯:BAABKgAECn8TAAMBAAgIAhilIQClAQABAAgIAhilIQClAQACAAEIigsXoQAkAAAAAA==.',['艾欧']='艾欧里亚:BAAAKgADCgcIBwAAAA==.',['芹菜']='芹菜根:BAAAKgADCggICQAAAA==.',['芽龙']='芽龙芽龙:BAAAKgAECgMIAwAAAA==.',['苍之']='苍之流星:BAABKgAFFH8JAAIcAAYIAhrJCQDGAAAcAAYIAhrJCQDGAAAAAA==.',['苍崎']='苍崎青子:BAAAKgAFFAIIAgAAAA==.',['苏独']='苏独龙龙:BAAAKgAECgMIBAAAAA==.',['荒野']='荒野大膘客:BAABKgAECn8aAAIIAAgIsRpmIwAwAgAIAAgIsRpmIwAwAgAAAA==.',['莉亚']='莉亚:BAAAKgAECgQIBQABKgAFFAgIEgAGADEfAA==.',['莉亞']='莉亞徳淋:BAABKgAFFH8PAAIJAAQI4COgCQAyAQAJAAQI4COgCQAyAQAAAA==.',['莫多']='莫多想:BAAAKgAECgQIBAAAAA==.',['莱维']='莱维:BAAAKgAFFAQIBAAAAA==.',['菲奥']='菲奥拉:BAABKgAFFH8QAAIGAAYIuCEfCQDiAQAGAAYIuCEfCQDiAQAAAA==.',['萌牛']='萌牛珍果粒:BAAAKgAECggICAAAAA==.',['蒂娅']='蒂娅多拉:BAAAKgAFFAYIAgAAAA==.',['蓬莱']='蓬莱山輝夜:BAABKgAFFH8OAAIQAAYIjyObDQCzAQAQAAYIjyObDQCzAQAAAA==.',['蔑绝']='蔑绝:BAAAKgAECgYICgAAAA==.',['藤原']='藤原萱:BAAAKgAFFAYIBAAAAA==.',['血池']='血池血池血池:BAAAKgAECgQIBAAAAA==.',['西园']='西园幽火:BAABKgAFFH8KAAIVAAQIbxFnDADMAAAVAAQIbxFnDADMAAABKgAFFAgIBAAdAAAAAA==.西园曲水:BAABKgAFFH8KAAMWAAQItxZ+FQDPAAAWAAQItxZ+FQDPAAAZAAIINBm3EQCVAAAAAA==.',['西西']='西西里沙滩:BAABKgAECn8cAAMcAAgIcRHwHgBgAQAcAAgIcRHwHgBgAQAJAAEIlRWHJwFAAAAAAA==.',['诶破']='诶破叛:BAAAKgADCggICAAAAA==.',['请叫']='请叫我劣人:BAAAKgAFFAQIBAABKgAFFAgICAAGABcdAA==.请叫我叹息丶:BAAAKgAECggICAAAAA==.请叫我天真丶:BAAAKgAECggIEAAAAA==.',['诺亚']='诺亚之子:BAAAKgAECgQICAAAAA==.诺亚风语者:BAAAKgAFFAQIBAABKgAFFAgIEQAFAPEhAA==.',['谁才']='谁才是冲击波:BAABKgAFFH8GAAIUAAYIMgjTEwAUAQAUAAYIMgjTEwAUAQAAAA==.',['谈情']='谈情跳舞:BAAAKgAECgcIDwAAAA==.',['贱剑']='贱剑:BAABKgAFFH8GAAIWAAMIMxuXIQDyAAAWAAMIMxuXIQDyAAAAAA==.',['超燃']='超燃真红毛熊:BAABKgAFFH8GAAMXAAMIjQ5wFwCuAAAXAAMIjQ5wFwCuAAAPAAEIJgElNgAiAAAAAA==.',['转码']='转码语者:BAAAKgADCggICAAAAA==.',['轻音']='轻音之弦:BAAAKgAECgEIAQAAAA==.',['迷人']='迷人的反派:BAAAKgAFFAQIBAAAAA==.',['迷雾']='迷雾天堂:BAAAKgAECgUIBQAAAA==.',['速八']='速八骑士乔治:BAABKgAFFH8GAAIJAAYIug3qigA/AAAJAAYIug3qigA/AAAAAA==.',['道法']='道法也是法:BAABKgAFFH8GAAIBAAYIvwjsCgAYAQABAAYIvwjsCgAYAQAAAA==.',['那咋']='那咋整啊:BAABKgAFFH8QAAIYAAYIlBmwBwAZAQAYAAYIlBmwBwAZAQAAAA==.',['邪恶']='邪恶的回忆:BAAAKgAECgIIAwAAAA==.',['邬晓']='邬晓玫:BAAAKgAFFAQIBAAAAA==.',['都拉']='都拉了一波融:BAAAKgAECgUIBQAAAA==.',['释道']='释道:BAAAKgADCgEIAQAAAA==.',['金大']='金大力:BAAAKgADCgcIBwAAAA==.',['钝角']='钝角:BAABKgAFFH8GAAIXAAQIrxPwCwDdAAAXAAQIrxPwCwDdAAAAAA==.',['销魂']='销魂柔式:BAABKgAFFH8JAAMPAAUIjSOLBwAxAQAPAAUIjSOLBwAxAQAXAAQIZAKFFQCJAAAAAA==.',['镇河']='镇河铁牛:BAAAKgADCggICAAAAA==.',['闪电']='闪电狂人:BAAAKgAECgIIAgAAAA==.',['阿作']='阿作化:BAAAKgADCgMIAwAAAA==.',['阿宇']='阿宇丶死骑:BAAAKgAECgYICgAAAA==.',['阿尔']='阿尔忒鉨斯:BAAAKgAECggICAAAAA==.',['陆陆']='陆陆捌捌:BAABKgAFFH8PAAQTAAMIeQ1WCQC2AAATAAMIUAxWCQC2AAAQAAMIZwoDGwCoAAAMAAEIMRAcIgBEAAAAAA==.',['陌上']='陌上吟归雪:BAABKgAFFH8KAAMYAAcIaQ/vFAD6AAAYAAQIrw/vFAD6AAAIAAMIDA+oMwDHAAAAAA==.',['降临']='降临丶:BAAAKgAFFAIIAgAAAA==.',['随风']='随风的萨满:BAAAKgAECgIIAwAAAA==.随风葬魂:BAAAKgAFFAUIAwAAAA==.',['雅克']='雅克西灬锈风:BAABKgAFFH8GAAMFAAQI2BGgEADWAAAFAAQI2BGgEADWAAAGAAIIXg00OwB+AAAAAA==.',['雷霆']='雷霆之心:BAAAKgAECggICAAAAA==.',['霓红']='霓红:BAAAKgAFFAYIAwAAAA==.',['霸霸']='霸霸特别强:BAAAKgAFFAMIAwAAAA==.',['青霞']='青霞楚红曼玉:BAAAKgAECgUIBQAAAA==.',['青青']='青青子吟:BAABKgAECn8YAAIJAAgIwxaeWQDrAQAJAAgIwxaeWQDrAQAAAA==.',['鞑靼']='鞑靼:BAAAKgAECgcIDAAAAA==.',['風之']='風之語:BAAAKgAFFAgIAwAAAA==.',['風見']='風見幽香:BAAAKgAECggICAAAAA==.',['风吹']='风吹雪如棉:BAAAKgAECgMIAwAAAA==.',['风怜']='风怜月:BAAAKgAECgIIAgAAAA==.',['风车']='风车我最快:BAAAKgAFFAEIAgAAAA==.',['香的']='香的马桶:BAAAKgAECgQIBAAAAA==.',['骨头']='骨头破坏者:BAAAKgAECgYICQAAAA==.',['高歌']='高歌振林木:BAAAKgADCgMIAwAAAA==.',['魅之']='魅之味:BAABKgAFFH8aAAMbAAcILh6vAAD2AQAbAAYITyCvAAD2AQAeAAUIcxe6AQBmAQABKgAFFAgICAAbAOoMAA==.',['魍魉']='魍魉一诺:BAAAKgADCgEIAgAAAA==.魍魉妖妖:BAAAKgADCgIIAgAAAA==.魍魉幽思:BAAAKgADCgYIBgAAAA==.魍魉憨憨:BAAAKgADCgEIAQAAAA==.',['魔法']='魔法占星:BAABKgAFFH8aAAMCAAgIfCBQAwCIAgACAAgIfCBQAwCIAgAfAAYIsQmsEgAqAQAAAA==.',['鱼塘']='鱼塘里的籽:BAAAKgAECgQIBQAAAA==.',['鸽以']='鸽以勇治:BAACKgAFFH8xAAMKAAgIMhx7AgBcAgAKAAcI8Rp7AgBcAgADAAYIMBBBFAAeAQAqAAQKfzYAAwoACAhgIQcPAEUCAAMACAjjHl0WAFUCAAoABwi1IAcPAEUCAAAA.',['鹦鹉']='鹦鹉铃:BAAAKgAECgIIAgAAAA==.',['黑店']='黑店小二:BAAAKgAFFAYIBAAAAA==.',['黑暗']='黑暗中的迷失:BAAAKgAECgMIAwAAAA==.',['黑比']='黑比尔:BAAAKgADCgEIAQAAAA==.',['黑炭']='黑炭头:BAAAKgADCgYIBgAAAA==.',['齐刘']='齐刘海灬:BAABKgAECn8XAAMZAAgIrhigHwDNAQAZAAgIrhigHwDNAQAWAAEItQPAyQAkAAAAAA==.',['齐天']='齐天晓圣:BAABKgAFFH8KAAMgAAYIbxvmBwAxAQAgAAUI5BnmBwAxAQAJAAMIZgWybgCNAAAAAA==.',['龙圣']='龙圣:BAABKgAFFH8MAAMNAAQI3BvvGAD8AAANAAQI3BvvGAD8AAAhAAMIAhQUBwCDAAAAAA==.',['龙小']='龙小葵:BAABKgAFFH8OAAIPAAYI2iARCACyAQAPAAYI2iARCACyAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end