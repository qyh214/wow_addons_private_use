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
 local lookup = {'Priest-Holy','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','Warlock-Affliction','Mage-Fire','Hunter-Survival','Druid-Balance','Druid-Restoration','Paladin-Protection','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Arms','Warrior-Fury','Shaman-Enhancement','Mage-Arcane','Mage-Frost','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Devastation','Evoker-Preservation','Paladin-Holy','Warlock-Destruction','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Warrior-Protection','DemonHunter-Vengeance','Warlock-Demonology','Rogue-Assassination',}; local provider = {region='CN',realm='黑暗之矛',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ai='Aimeemo:BAAAKgADCggICQAAAA==.',Am='Amyyo:BAABKgAFFH8RAAIBAAMIKx5UDQD0AAABAAMIKx5UDQD0AAAAAA==.',An='Anaamari:BAAAKgADCgIIAgAAAA==.',Ce='Celecoxib:BAABKgAECn8VAAMCAAgIUxlDNABtAQACAAcIcBxDNABtAQADAAgIEhwuVgAoAQAAAA==.',Ci='Circleofmoon:BAAAKgAECgQIBAAAAA==.',Cl='Clarmre:BAABKgAFFH8YAAIEAAYI/yIlDQD9AQAEAAYI/yIlDQD9AQAAAA==.',Co='Competencies:BAABKgAFFH8ZAAIEAAQI/RRhIwDZAAAEAAQI/RRhIwDZAAAAAA==.',Cr='Cristiano:BAABKgAFFH8FAAIFAAIIzwWVGwBmAAAFAAIIzwWVGwBmAAAAAA==.',Do='Dormj:BAABKgAFFH8GAAIGAAYItQo0EQA5AQAGAAYItQo0EQA5AQAAAA==.Dorsdl:BAAAKgAFFAcIAQAAAA==.',Dr='Draker:BAAAKgADCggICAAAAA==.',Ev='Evilwings:BAAAKgAFFAMIAwAAAA==.',Ez='Ezio:BAAAKgAECgcIBwAAAA==.',Fr='Frommym:BAABKgAECn8VAAIHAAgI7xLWBwCbAQAHAAgI7xLWBwCbAQAAAA==.',Ji='Jijiguownag:BAABKgAECn8bAAIEAAgIVxoGFQAgAgAEAAgIVxoGFQAgAgAAAA==.',Kd='Kdi:BAAAKgADCggICAAAAA==.',Lu='Lune:BAABKgAFFH8IAAMIAAgIQAxYEACeAQAIAAcIAA5YEACeAQAJAAEIvQKaNwA9AAAAAA==.',Mj='Mjsdl:BAAAKgAECgEIAQAAAA==.',Na='Nazgual:BAAAKgAECggIBQAAAA==.',Ov='Ovod:BAAAKgAECgYIDAAAAA==.Ovof:BAAAKgAECgYIAQAAAA==.Ovol:BAAAKgAECgUIBQAAAA==.Ovop:BAABKgAECn8UAAMEAAgIMhtYLgBeAQAEAAgIMhtYLgBeAQAKAAII1x87NwCwAAAAAA==.Ovoqq:BAAAKgAECgIIAgAAAA==.Ovot:BAABKgAECn8bAAMLAAgISR8bCQBnAgALAAgIIh8bCQBnAgAMAAgI7hfJPQB8AQAAAA==.',Sc='Scorpio:BAAAKgAECgIIAgAAAA==.',Sl='Slithice:BAAAKgAECgIIAgAAAA==.',Sr='Sry:BAAAKgAECgUICgAAAA==.',Sw='Sweetbun:BAAAKgAECgYIDwAAAA==.',Te='Temari:BAABKgAECn8VAAIIAAgIyiFCMQD3AQAIAAgIyiFCMQD3AQAAAA==.',To='Touchsky:BAAAKgAECgYIDAAAAA==.',['一品']='一品大白兔:BAAAKgAECgIIAgAAAA==.',['一头']='一头猛牛:BAACKgAFFH8KAAMNAAMIfB5cEQAAAQANAAMIfB5cEQAAAQAOAAMIthL0HADgAAAqAAQKfxQAAw4ACAgsHAMbAPkBAA4ACAgsHAMbAPkBAA0AAQhIGR5gAEwAAAAA.',['一射']='一射一曰一:BAAAKgADCggICAAAAA==.',['一小']='一小籽:BAAAKgADCggICAAAAA==.',['一抹']='一抹夏凉:BAAAKgAFFAgIBAAAAA==.',['一捅']='一捅浆糊:BAABKgAECn8hAAQCAAgI9RmrJADNAQACAAcIuByrJADNAQADAAcIjA+ATgBTAQAPAAEIeAQxYwAXAAAAAA==.',['一法']='一法一师一:BAAAKgADCgMIAwAAAA==.',['一直']='一直加班:BAAAKgAECgYICQAAAA==.',['一路']='一路繁华:BAAAKgAECggIDwAAAA==.',['一阳']='一阳指丶:BAAAKgAECgYIBgAAAA==.',['不会']='不会加血:BAAAKgAECgIIAgAAAA==.',['不落']='不落的荣燿:BAABKgAECn8mAAQQAAgI2iCDDwDZAQAGAAcIrRtJLQDsAQAQAAYIMiKDDwDZAQARAAUIvQuNcQC1AAAAAA==.',['专踹']='专踹瘸子好腿:BAAAKgAECgQIBAAAAA==.',['丨丶']='丨丶名人社团:BAAAKgAECgEIAQAAAA==.丨丶名人风骚:BAAAKgAECgEIAQAAAA==.',['丶一']='丶一个贼:BAAAKgAECggIEgAAAA==.',['丶莉']='丶莉莉丝:BAABKgAECn8XAAQQAAcIXhzeMACOAQAQAAcIExjeMACOAQAGAAYILxspQgCCAQARAAUIyRd4ZwDUAAAAAA==.',['丶醉']='丶醉千行:BAAAKgADCgYIBgAAAA==.',['丶鑫']='丶鑫:BAAAKgAECggICAAAAA==.',['乄时']='乄时肆初冬:BAABKgAFFH8GAAIEAAYIvx9lHACCAQAEAAYIvx9lHACCAQAAAA==.',['乄滨']='乄滨边美波:BAAAKgAECggICAAAAA==.',['乐享']='乐享晚年:BAABKgAFFH8GAAIIAAYIhhn+EACXAQAIAAYIhhn+EACXAQAAAA==.',['乱丶']='乱丶玛:BAAAKgADCggICAAAAA==.',['乱箭']='乱箭射死:BAAAKgADCgIIAgAAAA==.',['乾倒']='乾倒一片:BAAAKgAECgEIAQAAAA==.',['二踢']='二踢脚:BAACKgAFFH8iAAMSAAUIgwqVEQCiAAASAAQIgAqVEQCiAAATAAQIbwXiEACdAAAqAAQKf0QABBMACAg5GMQUAOoBABMACAg5GMQUAOoBABIACAgUE0glALYBABQAAQj0AZgrAAgAAAAA.',['五月']='五月鸣蝉:BAAAKgADCgMIAwAAAA==.',['亚瑟']='亚瑟王:BAABKgAFFH8HAAIEAAcI5wokEQCLAQAEAAcI5wokEQCLAQABKgAFFAgIBAAVAAAAAA==.',['人在']='人在高原:BAAAKgAECgIIAgAAAA==.',['代天']='代天寻狩:BAAAKgAECgcIEQAAAA==.',['伊斯']='伊斯塔战灵:BAACKgAFFH8YAAMGAAYIcSU2BwDlAQAGAAYIZSU2BwDlAQARAAQIayTICQAoAQAqAAQKfxcAAhEACAgzI7gLAKYCABEACAgzI7gLAKYCAAAA.',['伊莉']='伊莉安斯菲尔:BAAAKgAECgQIBAAAAA==.',['伏特']='伏特加姐姐:BAAAKgAFFAIIAgAAAA==.伏特加爱喝酒:BAAAKgAECgUIBQAAAA==.',['传说']='传说的老实人:BAACKgAFFH8KAAQRAAYIARp9EgDPAAARAAQImht9EgDPAAAQAAQIeQ16GAC4AAAGAAIInBdkJACWAAAqAAQKfxcABAYACAhSJYEnAAoCAAYACAgTIIEnAAoCABEABwj6IAQrAM0BABAABgi4GIE9AE4BAAAA.',['佐仓']='佐仓杏子:BAABKgAECn8VAAIMAAcI7CDEMADvAQAMAAcI7CDEMADvAQAAAA==.',['你个']='你个批丧丧:BAAAKgAECgIIAgAAAA==.',['你是']='你是我宠物:BAAAKgADCggICwAAAA==.',['你真']='你真高:BAAAKgADCggICAAAAA==.',['你说']='你说溜不溜:BAABKgAECn8WAAIEAAgIQyQYJQCGAgAEAAgIQyQYJQCGAgABKgAFFAgICAAWAHMNAA==.',['做生']='做生意的:BAABKgAECn8bAAINAAgI5BdLHADRAQANAAgI5BdLHADRAQAAAA==.',['停业']='停业要霆锋:BAABKgAECn8rAAMWAAgIbSKeDwCoAgAWAAgIbSKeDwCoAgAXAAII7wyilgBNAAAAAA==.',['偷冷']='偷冷锤儿:BAAAKgAECggICQAAAA==.',['兜兜']='兜兜里有叶子:BAAAKgAECggICAAAAA==.',['八叉']='八叉胡:BAAAKgADCgIIAgAAAA==.',['再来']='再来壹瓶:BAAAKgAECgUICwAAAA==.',['冬月']='冬月:BAABKgAFFH8IAAMYAAQIhRcmIgC4AAAYAAQIhRcmIgC4AAAZAAIIVRPWBwB5AAAAAA==.',['冰媛']='冰媛:BAABKgAFFH8KAAIYAAgIVwwuCQDLAQAYAAgIVwwuCQDLAQAAAA==.',['冰糕']='冰糕块块:BAAAKgADCggICAAAAA==.',['冰蓝']='冰蓝的誓约:BAAAKgADCgMIAwAAAA==.',['冷面']='冷面郎君:BAABKgAECn8hAAMWAAgIYBsGQAD4AQAWAAgIXxsGQAD4AQAXAAYIMRbuFACMAQAAAA==.',['凡星']='凡星之怒:BAAAKgAFFAgIAgAAAA==.',['刀巴']='刀巴刀巴:BAABKgAECn8sAAMZAAgIkRdbCAD7AQAZAAgIkRdbCAD7AQAYAAUIjRVCOwDtAAAAAA==.',['判官']='判官:BAAAKgAECgEIAQAAAA==.',['刺桐']='刺桐:BAAAKgAECgYIBgAAAA==.',['剑刃']='剑刃不朽:BAACKgAFFH8hAAIEAAYI5CVUCgAfAgAEAAYI5CVUCgAfAgAqAAQKfyUAAwQACAiMJMIOAN0CAAQACAiMJMIOAN0CABoAAQjqAdpYAAgAAAAA.',['加乐']='加乐比海盗:BAAAKgADCggIEgAAAA==.',['加农']='加农多夫:BAAAKgAECggICAAAAA==.',['十点']='十点好好睡:BAAAKgADCggICAAAAA==.',['半口']='半口仙气:BAAAKgAECggICAAAAA==.',['半夏']='半夏时光灬:BAABKgAFFH8UAAIQAAgIARb6CQDPAQAQAAgIARb6CQDPAQAAAA==.',['华茂']='华茂春松:BAAAKgADCgEIAQAAAA==.',['华里']='华里六六:BAAAKgAECgQIBwAAAA==.华里六月:BAABKgAECn8kAAIWAAgI6xT1GgCiAQAWAAgI6xT1GgCiAQAAAA==.华里六魔:BAAAKgAECgcICwAAAA==.华里十七:BAAAKgAECgcICwAAAA==.华里十二:BAAAKgAECggIEwAAAA==.华里十六:BAAAKgAECgcIDAAAAA==.华里大德:BAAAKgAECggIDgAAAA==.华里威武:BAAAKgAECggICAAAAA==.华里怒怒:BAAAKgAECgcIDAAAAA==.华里鹭鹭:BAAAKgAECggIEwAAAA==.',['单线']='单线程:BAACKgAFFH8IAAMFAAQITRmpCADkAAAFAAQIJxmpCADkAAAbAAQIdRK3FgDJAAAqAAQKfxUAAhsABwigEY83AC4BABsABwigEY83AC4BAAAA.',['南方']='南方大叔:BAAAKgADCggICAAAAA==.',['卡塔']='卡塔库栗:BAAAKgADCggIDwAAAA==.',['卷王']='卷王:BAAAKgAFFAQIBAAAAA==.',['发型']='发型必乱:BAABKgAECn8YAAIEAAgI/h+wIQB7AgAEAAgI/h+wIQB7AgAAAA==.',['叙利']='叙利亚悍妇:BAAAKgADCgcIBwAAAA==.',['吖尔']='吖尔萨撕:BAAAKgAFFAQIBAAAAA==.',['呆到']='呆到自然萌:BAABKgAECn8kAAMXAAgI3RyFFgAcAgAXAAgIhRqFFgAcAgAWAAgIdhjnLgDwAQAAAA==.',['呆萌']='呆萌恶魔:BAABKgAFFH8FAAIcAAMIDxIvLQDGAAAcAAMIDxIvLQDGAAAAAA==.',['周六']='周六晚八点:BAAAKgADCggICAAAAA==.',['咆哮']='咆哮的大肉包:BAABKgAFFH8GAAIXAAYIyhO9EQBVAQAXAAYIyhO9EQBVAQAAAA==.',['咖喱']='咖喱小猫猫:BAAAKgAFFAgIAgAAAA==.',['咦你']='咦你蛋:BAACKgAFFH8SAAIcAAMIxxt6IwDtAAAcAAMIxxt6IwDtAAAqAAQKfxsAAhwACAhBIFkSAG8CABwACAhBIFkSAG8CAAAA.',['咸蛋']='咸蛋黄茄子:BAABKgAFFH8GAAIXAAYIiwn7DgAKAQAXAAYIiwn7DgAKAQAAAA==.',['喜悦']='喜悦发生:BAABKgAECn8YAAIZAAgImQIOHQBEAAAZAAgImQIOHQBEAAAAAA==.',['喵的']='喵的喵的:BAAAKgADCggICAAAAA==.',['嗜血']='嗜血警魂:BAAAKgADCggICgAAAA==.',['嗨到']='嗨到疯:BAAAKgADCggICAAAAA==.',['噩梦']='噩梦中的舞者:BAAAKgAFFAQIBAAAAA==.',['噩耗']='噩耗乌鸦:BAABKgAECn8eAAIGAAgIWxHHFgCKAQAGAAgIWxHHFgCKAQAAAA==.',['噻丶']='噻丶:BAABKgAFFH8GAAIXAAYITAz+FgAuAQAXAAYITAz+FgAuAQAAAA==.',['回忆']='回忆丿那么美:BAABKgAFFH8GAAQBAAMIpwCgOwBQAAABAAMIYQCgOwBQAAAdAAEILAGjNgAjAAAeAAEIUAB7NAAUAAAAAA==.回忆的海风:BAAAKgAECgcIDAAAAA==.',['国足']='国足纪念日:BAAAKgADCgYIBgAAAA==.',['圣光']='圣光将熄丶:BAABKgAFFH8HAAIMAAUIHxF9DQAjAQAMAAUIHxF9DQAjAQAAAA==.圣光小美:BAABKgAFFH8GAAIEAAYIxATfBgBJAQAEAAYIxATfBgBJAQAAAA==.',['圣火']='圣火徽章:BAAAKgAECggICAAAAA==.',['地狱']='地狱镇魂歌丶:BAABKgAFFH8GAAINAAYIuAtdDQA6AQANAAYIuAtdDQA6AQAAAA==.',['多宝']='多宝无敌:BAAAKgAFFAMIBAAAAA==.',['夜丨']='夜丨影:BAAAKgADCgEIAQAAAA==.',['夜阑']='夜阑谣:BAABKgAFFH8NAAIcAAYIQRVJAwCxAQAcAAYIQRVJAwCxAQAAAA==.',['夜风']='夜风琪士:BAAAKgAECgYIBgAAAA==.',['大兴']='大兴西北:BAAAKgAFFAEIAQAAAA==.',['大华']='大华子:BAAAKgAECgEIAQAAAA==.',['大油']='大油子:BAAAKgAECgEIAQAAAA==.',['大马']='大马子:BAAAKgAECgQIBAAAAA==.',['天启']='天启追风:BAABKgAECn8eAAIMAAgIcxtIGwAzAgAMAAgIcxtIGwAzAgAAAA==.',['天堂']='天堂福娃:BAAAKgAFFAgIBAAAAA==.天堂福满多:BAAAKgAECgYIBgAAAA==.',['太极']='太极冰莫寒:BAABKgAFFH8JAAIDAAYIgBgxDACGAQADAAYIgBgxDACGAQAAAA==.太极蓝冰焰:BAAAKgAECgYIBQAAAA==.',['失去']='失去的回忆:BAAAKgADCggICAAAAA==.',['奈何']='奈何志:BAAAKgADCgcIBwAAAA==.',['奔雷']='奔雷手文泰:BAAAKgAECgUICwAAAA==.',['奥黛']='奥黛丽娅:BAAAKgAECgQIBAAAAA==.',['女兽']='女兽神:BAAAKgAECgUIBQAAAA==.',['女馁']='女馁:BAABKgAECn8XAAMRAAgI7BV9HwC1AQARAAgI7BV9HwC1AQAQAAIIGQ8XnAAuAAAAAA==.',['奶不']='奶不起来:BAAAKgAFFAQIBAAAAA==.',['奶油']='奶油流沙包:BAACKgAFFH8uAAIJAAgIfxOFBADoAQAJAAgIfxOFBADoAQAqAAQKfzAAAwkACAj2HpQPAE4CAAkACAj2HpQPAE4CAAgAAwhDCMKqAG4AAAAA.',['姆姆']='姆姆好吃:BAAAKgAFFAQIBAAAAA==.',['姐你']='姐你的腰蛮好:BAAAKgAECgYICQAAAA==.',['婷婷']='婷婷妹:BAAAKgAFFAQIBAAAAA==.',['媚祸']='媚祸无穷:BAAAKgAECgEIAQAAAA==.',['子墨']='子墨抒画:BAAAKgAECgEIAQAAAA==.',['宇梦']='宇梦璇中藏:BAABKgAFFH8JAAIEAAYIyxJ5EgB0AQAEAAYIyxJ5EgB0AQAAAA==.',['守山']='守山哥:BAAAKgAECgcICQAAAA==.',['客串']='客串的:BAAAKgAECgcIDgAAAA==.',['寻找']='寻找圣光:BAAAKgADCgEIAgAAAA==.',['專業']='專業打臉:BAACKgAFFH8FAAIWAAIIoBTEMwCRAAAWAAIIoBTEMwCRAAAqAAQKfxgAAhYACAiiFuBNAMkBABYACAiiFuBNAMkBAAAA.',['小小']='小小奶妈:BAAAKgAECgQIBAAAAA==.小小青丶:BAAAKgAECggICAAAAA==.',['小熊']='小熊猫不上班:BAAAKgADCggIDgAAAA==.',['小酒']='小酒仙:BAAAKgAECggICwABKgAECggIFQACAFMZAA==.',['尖妮']='尖妮儿盘蚊香:BAABKgAFFH8IAAIEAAQIABt+FAAFAQAEAAQIABt+FAAFAQAAAA==.',['尘曦']='尘曦:BAAAKgAECggIDwAAAA==.',['尘緣']='尘緣淺:BAABKgAFFH8NAAMbAAcI/xV5HAAjAQAbAAUIORJ5HAAjAQAFAAIIiR0vDQC/AAAAAA==.',['尘缘']='尘缘:BAAAKgADCgEIAQAAAA==.',['山水']='山水:BAAAKgAECgcIDAAAAA==.',['山涧']='山涧的雨:BAABKgAFFH8GAAIRAAYIpA5gBQBZAQARAAYIpA5gBQBZAQAAAA==.',['巅峰']='巅峰的希女王:BAAAKgAFFAQIBAAAAA==.',['川北']='川北神棍:BAAAKgADCgcICQAAAA==.',['巴尔']='巴尔:BAACKgAFFH8PAAQNAAYIYx/XAwAuAQANAAYIYx/XAwAuAQAOAAIIqQxqIQCKAAAfAAMI/QL7EgBkAAAqAAQKfxgAAw4ACAjEGXwkAAACAA4ACAjEGXwkAAACAA0ABAhFGCk/AN0AAAAA.巴尔之殇:BAACKgAFFH8MAAIcAAYIhRIRFQBSAQAcAAYIhRIRFQBSAQAqAAQKfxUAAyAACAjKD9sxAPwAABwACAh/CzdlABMBACAACAgzCtsxAPwAAAAA.巴尔之魂:BAABKgAFFH8QAAIMAAQIuCKaDQAEAQAMAAQIuCKaDQAEAQAAAA==.',['布狄']='布狄卡:BAAAKgAECgUIBQAAAA==.',['幻灵']='幻灵月光之吻:BAAAKgAFFAQIBAAAAA==.',['幽维']='幽维灵安娜:BAAAKgAECggIEAAAAA==.',['康斯']='康斯坦丁丶:BAABKgAFFH8GAAIEAAYIJAOgagCWAAAEAAYIJAOgagCWAAAAAA==.',['弋丶']='弋丶:BAAAKgAFFAgIAwAAAA==.',['强风']='强风吹拂:BAAAKgADCgEIAQAAAA==.',['御霸']='御霸残音:BAABKgAECn8eAAQFAAgIehjpDQCXAQAFAAcIORjpDQCXAQAhAAQIxBJ1RwDGAAAbAAIIXwzrmQBWAAAAAA==.',['怒风']='怒风咆哮:BAAAKgAFFAEIAQAAAA==.',['思媛']='思媛妹妹:BAABKgAFFH8OAAQKAAYIRRomCACKAQAKAAYIRRomCACKAQAEAAIImhIMPACQAAAaAAIIkgXJEQBwAAABKgAFFAgIJgABAIYmAA==.',['恶灵']='恶灵决者:BAAAKgAECgcICgAAAA==.恶灵猎者:BAABKgAECn8aAAIcAAgIGRm8DQAcAgAcAAgIGRm8DQAcAgAAAA==.恶灵骑者:BAABKgAECn8XAAIEAAcIpRcdXACqAQAEAAcIpRcdXACqAQAAAA==.',['恶魔']='恶魔召唤者丶:BAABKgAFFH8OAAQhAAgI1gixBgAPAQAbAAgIvQZlCgCsAQAhAAUIJA2xBgAPAQAFAAEIwQBIJgA2AAAAAA==.',['悠洛']='悠洛丶:BAAAKgAECggICAAAAA==.',['悠然']='悠然南山:BAABKgAFFH8GAAIOAAYI2CR7BgAGAgAOAAYI2CR7BgAGAgAAAA==.',['情两']='情两难:BAABKgAFFH8JAAIcAAMI7hJaFwDQAAAcAAMI7hJaFwDQAAAAAA==.',['惆怅']='惆怅的痞子蔡:BAAAKgAECgcICAAAAA==.',['惜花']='惜花怜之月:BAAAKgAECgcIAQAAAA==.',['意大']='意大利炮:BAAAKgAFFAUIAwAAAA==.',['懂得']='懂得自然懂:BAABKgAFFH8IAAMEAAQIdhJnLwCxAAAEAAQINxFnLwCxAAAKAAIIlRWUKwAyAAAAAA==.',['我一']='我一不小心:BAAAKgADCggICAAAAA==.',['我信']='我信了你的斜:BAAAKgADCggICAAAAA==.',['我去']='我去丢个垃圾:BAAAKgAECgYICgAAAA==.',['我我']='我我爱一条柴:BAABKgAFFH8NAAQQAAYIsR9HJwDFAAAQAAUI9yFHJwDFAAAGAAQIBBeGJADDAAARAAEIAAC9JgAAAAABKgAFFAgIBAAVAAAAAA==.',['戴斯']='戴斯艾克神:BAABKgAFFH8IAAIbAAgIuBU6BgAyAgAbAAgIuBU6BgAyAgAAAA==.',['打不']='打不赢就滚:BAABKgAFFH8MAAMSAAMIGxR0EgDOAAASAAMIGxR0EgDOAAATAAIIXwF1MgBDAAAAAA==.',['扶摇']='扶摇:BAABKgAFFH8GAAMBAAQIwxHVJQCrAAABAAQIwxHVJQCrAAAdAAIItgilIwBhAAAAAA==.',['抠鼻']='抠鼻:BAABKgAFFH8FAAMXAAIIoyESPgCAAAAXAAIIoyESPgCAAAAWAAEIdRVVXQA8AAAAAA==.',['插腾']='插腾腾:BAABKgAFFH8FAAIDAAUIIhveEABOAQADAAUIIhveEABOAQAAAA==.',['搥溯']='搥溯摤嗳嗳:BAAAKgADCgEIAgAAAA==.',['放开']='放开让我来:BAAAKgAECgMIAwAAAA==.',['无敌']='无敌佳佳:BAABKgAFFH8fAAMWAAUI4xvtFQBHAQAWAAUI4xvtFQBHAQAXAAQIrgnWGQCZAAAAAA==.无敌多宝:BAAAKgAFFAMIBAAAAA==.',['时尚']='时尚丶超:BAAAKgAECgEIAQAAAA==.',['明月']='明月照大江:BAAAKgAECggIEgAAAA==.',['星小']='星小狐:BAACKgAFFH9LAAILAAgIlSCqAQCgAgALAAgIlSCqAQCgAgAqAAQKf0AAAwsACAgcIaENAFQCAAsACAgcIaENAFQCAAwAAQirG7mjAE4AAAAA.',['春风']='春风入夜眠:BAAAKgAECgQIBAAAAA==.',['暗夜']='暗夜劣:BAAAKgAECgMIAgAAAA==.暗夜术:BAAAKgADCggIFwAAAA==.',['暗影']='暗影大叔:BAACKgAFFH8qAAQFAAgIyiFWAABnAgAFAAgIyiFWAABnAgAhAAQIvxauCQDqAAAbAAEI+CHfKQBkAAAqAAQKfysABAUACAhTJKgBAKACAAUACAhTJKgBAKACABsABQieGspjAOEAACEAAgg+IRtXAJIAAAAA.暗影肖恩:BAAAKgADCggICAAAAA==.',['暴力']='暴力养猪妹:BAAAKgAFFAYIBAAAAA==.',['暴菊']='暴菊怒闻手:BAAAKgADCgIIAgAAAA==.',['暴躁']='暴躁:BAABKgAFFH8QAAMKAAYImh0OCgBbAQAKAAYIsRoOCgBbAQAEAAMIQRiTRQDjAAAAAA==.',['月下']='月下独影:BAAAKgADCgQIBAAAAA==.',['月丨']='月丨影:BAAAKgADCgEIAQAAAA==.',['月影']='月影依枪:BAABKgAFFH8GAAIiAAYI6R2fCwCSAQAiAAYI6R2fCwCSAQAAAA==.月影蒙蒙:BAAAKgADCgEIAQAAAA==.',['月曦']='月曦言:BAABKgAECn8XAAIEAAgIqRpePwAFAgAEAAgIqRpePwAFAgAAAA==.',['月球']='月球兔宝宝:BAAAKgAECgIIBAAAAA==.',['木森']='木森林:BAAAKgAECgYIBwAAAA==.',['李青']='李青玄:BAABKgAECn8VAAMGAAgIhxcxLwDiAQAGAAgIKhcxLwDiAQARAAgIaAXKdwCkAAAAAA==.',['松石']='松石:BAABKgAFFH8NAAMKAAYI5BK/AgBYAQAKAAYIxBG/AgBYAQAEAAQIVxTiHwDpAAAAAA==.',['极冰']='极冰之舞:BAAAKgADCgEIAQAAAA==.',['枫樾']='枫樾岚:BAAAKgADCggICAAAAA==.',['树欲']='树欲静:BAAAKgADCggIEAAAAA==.',['格蕾']='格蕾丝:BAAAKgAECggICAAAAA==.',['格調']='格調乀:BAAAKgAFFAQIBAAAAA==.',['梅莉']='梅莉:BAAAKgAECgEIAQAAAA==.',['梦回']='梦回吹角连营:BAABKgAFFH8OAAMbAAgI5B7YBgAlAgAbAAgI5B7YBgAlAgAhAAEIUwRpLwA7AAAAAA==.',['楚乔']='楚乔:BAABKgAFFH8FAAMWAAMIgBagQQCZAAAWAAIIkxqgQQCZAAAXAAEIWw5RUQA5AAAAAA==.',['橙丶']='橙丶孓:BAAAKgAFFAgIAQAAAA==.',['櫻埖']='櫻埖漈:BAAAKgAECggICAAAAA==.',['歌丨']='歌丨曲:BAABKgAFFH8GAAIKAAYIHRy5CQBjAQAKAAYIHRy5CQBjAQAAAA==.',['此号']='此号有人:BAABKgAFFH8IAAIWAAgI3x0MAwCaAgAWAAgI3x0MAwCaAgAAAA==.',['武心']='武心妍:BAABKgAFFH8HAAIKAAcInwMxFQDPAAAKAAcInwMxFQDPAAAAAA==.',['死亡']='死亡的圆舞曲:BAAAKgAECggICAAAAA==.死亡的舞曲:BAAAKgAECggICwAAAA==.',['死神']='死神的斩月:BAABKgAECn8UAAIRAAgIJh+GBACMAgARAAgIJh+GBACMAgAAAA==.',['每天']='每天高乐高:BAAAKgAFFAQIBAAAAA==.',['毛团']='毛团子:BAABKgAFFH8KAAMNAAgIvxqPCwBUAQANAAQIuhyPCwBUAQAOAAQIGxjuDQADAQAAAA==.',['沫小']='沫小妞:BAABKgAFFH8KAAIRAAUICxtiBwBPAQARAAUICxtiBwBPAQAAAA==.',['泡粑']='泡粑是布偶:BAAAKgAFFAgIBAAAAA==.',['泪痕']='泪痕:BAAAKgADCgMIAwAAAA==.',['泰瑞']='泰瑞昂黎明:BAABKgAFFH8MAAIMAAgIaRi3BgApAgAMAAgIaRi3BgApAgAAAA==.',['涵涵']='涵涵妹:BAABKgAFFH8GAAIcAAYI6BRkGgArAQAcAAYI6BRkGgArAQAAAA==.',['淡漠']='淡漠丶赐:BAAAKgAECgUICAAAAA==.',['深藏']='深藏功与名:BAABKgAFFH8MAAIiAAgIsAlSBQAOAgAiAAgIsAlSBQAOAgAAAA==.',['温热']='温热的尾巴:BAAAKgAFFAMIAwAAAA==.',['满仓']='满仓加杠杆:BAAAKgADCgQIBAAAAA==.',['漆彩']='漆彩阳光:BAAAKgAFFAgIBAAAAA==.',['潇潇']='潇潇灬:BAAAKgAFFAYIBAAAAA==.',['濑户']='濑户灿:BAAAKgAECgcIBwAAAA==.',['灬乂']='灬乂灬:BAAAKgADCgEIAQAAAA==.',['灬唸']='灬唸:BAAAKgAECggICAAAAA==.',['灬夜']='灬夜影灬:BAAAKgADCgEIAgAAAA==.',['灬瑾']='灬瑾:BAAAKgADCgEIAQAAAA==.',['灬荼']='灬荼靡丶:BAAAKgAECgMIAwAAAA==.',['灭团']='灭团发动机:BAACKgAFFH8YAAMNAAgIPRhGAwAsAgANAAcIPRhGAwAsAgAOAAIIvgIdOgA0AAAqAAQKfzAABA0ACAh9G0YRADACAA0ACAh9G0YRADACAB8AAgjaFOo5AHkAAA4AAwjbCvR7AHUAAAAA.',['灭绝']='灭绝师太:BAABKgAFFH8TAAMbAAcIKBo1EwBsAQAbAAcIKBo1EwBsAQAhAAIIKQxDDACKAAAAAA==.',['灵灵']='灵灵七:BAAAKgAFFAQIBAAAAA==.',['灵魂']='灵魂抉择:BAAAKgAECggIEgAAAA==.',['烂丶']='烂丶人:BAAAKgADCgYIBgAAAA==.',['烈焰']='烈焰魔剑:BAABKgAFFH8MAAIGAAYIKwupEQA0AQAGAAYIKwupEQA0AQAAAA==.',['烛影']='烛影乱:BAAAKgADCgEIAQAAAA==.',['热苏']='热苏斯:BAABKgAFFH8TAAIEAAgIyx9ZBQB6AgAEAAgIyx9ZBQB6AgAAAA==.',['烽火']='烽火寒冰:BAAAKgADCgEIAQAAAA==.',['無心']='無心恋戰:BAAAKgAECgYIBwAAAA==.',['熊变']='熊变泥鳅:BAAAKgADCggIDAAAAA==.',['爱吃']='爱吃土豆:BAAAKgAECgYIBgAAAA==.',['爱情']='爱情从未降临:BAAAKgAECgEIAQAAAA==.',['爱芷']='爱芷灵儿:BAABKgAFFH8HAAIEAAMIKguTZgCgAAAEAAMIKguTZgCgAAAAAA==.',['牛得']='牛得不像人:BAACKgAFFH8SAAMDAAQIzBalKwDIAAADAAQIzBalKwDIAAACAAEITw7EJwA9AAAqAAQKf0EAAwMACAguIukIAKkCAAMACAguIukIAKkCAAIABwgCFtgxAFgBAAAA.',['牛牛']='牛牛不怕:BAAAKgADCgIIAgAAAA==.牛牛天下行:BAAAKgAFFAYIAgABKgAFFAgIEAAWACYbAA==.',['牧小']='牧小凡:BAAAKgAECgIIAwAAAA==.',['物竞']='物竞天择:BAABKgAFFH8KAAMhAAYI7hA8AQBIAQAhAAUI6hM8AQBIAQAbAAUIixB0MACsAAAAAA==.',['特基']='特基拉日落:BAABKgAECn8eAAIXAAgIixwAGQAJAgAXAAgIixwAGQAJAgAAAA==.',['狂风']='狂风闪电:BAACKgAFFH8PAAICAAMIWR3mDgDvAAACAAMIWR3mDgDvAAAqAAQKfxUAAwIACAiKGsUgAMQBAAIABwh4GsUgAMQBAAMAAQgSBonAACYAAAAA.',['狄修']='狄修斯:BAABKgAFFH8IAAIBAAQIlhHxEgCqAAABAAQIlhHxEgCqAAAAAA==.',['狐言']='狐言:BAAAKgAECgEIAQAAAA==.',['狒学']='狒学弟:BAAAKgAFFAYIBAAAAA==.',['狠彪']='狠彪悍:BAAAKgAFFAcIAQAAAA==.',['猎影']='猎影疾风:BAAAKgAECgUIDgAAAA==.',['猛牛']='猛牛哥:BAAAKgADCggICAAAAA==.',['猫猫']='猫猫的小牙虫:BAAAKgAFFAQIBAAAAA==.',['猫老']='猫老喵:BAAAKgAFFAQIBAABKgAFFAYIIQAeAIoQAA==.',['王上']='王上加白:BAAAKgAFFAYIBAAAAA==.',['王临']='王临天下:BAAAKgAECgEIAQAAAA==.',['王得']='王得发:BAABKgAFFH8MAAIMAAQIOyJ2CQAeAQAMAAQIOyJ2CQAeAQABKgAFFAgIDAAIAEklAA==.',['王牛']='王牛牛快跑:BAABKgAFFH8IAAIEAAQI2gw4WgC9AAAEAAQI2gw4WgC9AAAAAA==.',['珩宝']='珩宝丶:BAAAKgAECgUIBQAAAA==.',['瑟兰']='瑟兰蒂斯:BAAAKgADCgIIAgAAAA==.',['瑶乐']='瑶乐乐:BAACKgAFFH8SAAMWAAMINCLkCgArAQAWAAMI1iHkCgArAQAXAAEIYCYdIQBrAAAqAAQKfzAAAxYACAiFJXwNAM8CABYACAj8JHwNAM8CABcACAiVH30VACUCAAAA.',['璇影']='璇影落星宇:BAABKgAFFH8GAAIXAAYILBBzDAA7AQAXAAYILBBzDAA7AQAAAA==.',['电城']='电城猪肠粉:BAAAKgAECgcIDAAAAA==.电城鱼炸:BAAAKgAECgIIAgAAAA==.',['男孩']='男孩本色:BAACKgAFFH8JAAIRAAMIFw1NGQCwAAARAAMIFw1NGQCwAAAqAAQKfyQAAhEACAhzFrUoAHQBABEACAhzFrUoAHQBAAAA.',['癌变']='癌变:BAAAKgAECggICAAAAA==.',['眼镜']='眼镜落了灰:BAAAKgAECgEIAQAAAA==.',['睾贵']='睾贵的阿苏斯:BAAAKgAECggICAAAAA==.',['碧痰']='碧痰飘血:BAAAKgAECgEIAQAAAA==.',['神牛']='神牛飞蹄:BAAAKgAECgUIBwAAAA==.',['神说']='神说我在这:BAAAKgADCgIIAwAAAA==.神说我最美:BAAAKgADCgEIAgAAAA==.神说有光:BAAAKgADCgQIBwAAAA==.',['秋月']='秋月:BAABKgAFFH8IAAIEAAgI3h0wFwD+AAAEAAgI3h0wFwD+AAAAAA==.秋月丶战:BAAAKgAFFAQIBAABKgAFFAgIGAAdAOgeAA==.秋月丶迪凯:BAAAKgAECggIEAAAAA==.秋月爱莉:BAAAKgAFFAMIAwAAAA==.',['秋豆']='秋豆子:BAAAKgAECgYICQAAAA==.',['科洛']='科洛亦:BAABKgAFFH8IAAMWAAUIRxzcHAAdAQAWAAUIRxzcHAAdAQAXAAEInQLLLQApAAAAAA==.',['秦岭']='秦岭:BAAAKgAECgMIAwAAAA==.',['穆拉']='穆拉撒一咕咕:BAABKgAFFH8JAAMJAAIIsA5sHABlAAAJAAIIsA5sHABlAAAIAAIIMQWLVQBfAAAAAA==.',['笛卡']='笛卡尔式恶嬷:BAAAKgADCgQIBAAAAA==.',['米牛']='米牛:BAAAKgAECgIIAgAAAA==.',['糖果']='糖果儿:BAAAKgAECgEIAQAAAA==.',['索伦']='索伦:BAABKgAECn8fAAIDAAgIWh/hFwA5AgADAAgIWh/hFwA5AgABKgAFFAgIFQAIALURAA==.',['索菲']='索菲亚诺兰:BAAAKgAECgcIBwAAAA==.',['紫夜']='紫夜熊:BAAAKgAECgUIBQAAAA==.',['紫色']='紫色初雪:BAAAKgAFFAYIBAAAAA==.紫色星空:BAAAKgAFFAMIAwAAAA==.',['给我']='给我依个吻:BAAAKgAECgUIBQAAAA==.',['绿茶']='绿茶薄荷:BAAAKgAFFAIIAgABKgAECggIGgAMABQkAA==.',['美好']='美好保留:BAAAKgADCgIIAgAAAA==.',['老子']='老子蜀道山:BAAAKgAECgEIAQAAAA==.',['老德']='老德益壮:BAAAKgADCggICAAAAA==.',['老牛']='老牛不累:BAAAKgADCgIIAgAAAA==.',['能不']='能不能玩:BAACKgAFFH8UAAIMAAQIIyZECAApAQAMAAQIIyZECAApAQAqAAQKfxkAAgwACAi9Ij4eAEwCAAwACAi9Ij4eAEwCAAAA.',['脏狗']='脏狗:BAAAKgADCgMIAwAAAA==.',['脚趾']='脚趾野草味:BAABKgAECn8XAAIiAAgITxj0DQBAAQAiAAgITxj0DQBAAQAAAA==.',['自由']='自由自在:BAAAKgADCggICAAAAA==.',['舍不']='舍不得开升腾:BAABKgAFFH8KAAIDAAYIpRzGAADVAQADAAYIpRzGAADVAQAAAA==.',['艳灬']='艳灬枫:BAAAKgADCgMIAwAAAA==.',['艾斯']='艾斯黛施耐特:BAAAKgADCggICAAAAA==.',['芈之']='芈之后裔丶:BAAAKgAECgMIAwAAAA==.',['花狩']='花狩:BAAAKgAFFAQIBAABKgAFFAgICAAWABcdAA==.',['花落']='花落:BAABKgAFFH8GAAIGAAYIURPTDgBTAQAGAAYIURPTDgBTAQAAAA==.',['芹菜']='芹菜:BAABKgAFFH8IAAIcAAgIIRBwCQD4AQAcAAgIIRBwCQD4AQAAAA==.',['茆苧']='茆苧:BAABKgAECn8aAAMBAAgIkB2jFwAEAgABAAgIkB2jFwAEAgAdAAMIuA0yYgCcAAABKgAFFAgICgABAJMQAA==.',['荭葱']='荭葱头:BAAAKgAECggICAAAAA==.',['萌不']='萌不起来:BAABKgAFFH8KAAMMAAYInhnsCAAiAQALAAYIyxXoDABGAQAMAAQIgR/sCAAiAQAAAA==.',['萨小']='萨小凡:BAAAKgAECgQIBAAAAA==.',['萨拉']='萨拉曼:BAACKgAFFH8jAAIDAAQInCBxDwAHAQADAAQInCBxDwAHAQAqAAQKfxQAAgMABwiQGRhNAEYBAAMABwiQGRhNAEYBAAAA.',['落叶']='落叶也会有风:BAAAKgAECggICAAAAA==.',['落雪']='落雪印梅:BAAAKgAECgYIBwAAAA==.',['虚空']='虚空花生:BAABKgAECn8mAAMdAAgI0RFGKwCBAQAdAAgI0RFGKwCBAQABAAEIKQX2ngAfAAAAAA==.',['蛋蛋']='蛋蛋妹:BAABKgAFFH8IAAMGAAYISgrHEgAoAQAGAAYIjwjHEgAoAQARAAIIXw/eHQBEAAAAAA==.蛋蛋的忧桑丶:BAABKgAECn8jAAIEAAgIYxXIbAC/AQAEAAgIYxXIbAC/AQAAAA==.蛋蛋被迫玩奶:BAAAKgADCggICAAAAA==.',['血兽']='血兽:BAAAKgAECggIBQAAAA==.',['血舞']='血舞残月:BAABKgAFFH8IAAILAAgI0wxXCQCBAQALAAgI0wxXCQCBAQAAAA==.',['西园']='西园的猫:BAAAKgADCgYIBgAAAA==.',['见闻']='见闻色:BAABKgAFFH8IAAIEAAgIFiEYAwCtAgAEAAgIFiEYAwCtAgAAAA==.',['言不']='言不欲:BAAAKgAFFAIIAwAAAA==.',['记得']='记得吃饭:BAAAKgAECgIIAgAAAA==.',['许流']='许流星:BAAAKgADCgYIBgAAAA==.',['豆浆']='豆浆烩面:BAAAKgAFFAgIBAAAAA==.',['豆豆']='豆豆嗒:BAAAKgAECggIEAAAAA==.',['豌豆']='豌豆丶:BAABKgAFFH8IAAIMAAgINhr1BABWAgAMAAgINhr1BABWAgAAAA==.',['贫僧']='贫僧戒逼:BAAAKgAECggICAAAAA==.',['超级']='超级大猎魔:BAAAKgAECgYIEQAAAA==.超级大黑牛:BAABKgAECn8ZAAMNAAgIkhrwBwDpAQANAAcIThrwBwDpAQAOAAcIjxTeFQBWAQAAAA==.',['越烨']='越烨越冷漠:BAAAKgADCgEIAQAAAA==.',['踏风']='踏风武僧:BAAAKgAFFAQIBAAAAA==.',['输出']='输出犹如电梯:BAAAKgAECgIIAgAAAA==.',['辫子']='辫子妹妹:BAABKgAFFH8HAAIOAAYI6wtJEQBCAQAOAAYI6wtJEQBCAQAAAA==.',['迦兰']='迦兰伽叶:BAAAKgADCgIIAQAAAA==.',['迷兮']='迷兮兮:BAABKgAECn8VAAMSAAcI8gd1RQC1AAASAAYIpQh1RQC1AAATAAcIcwWCTACNAAABKgAFFAQIBwAiADsMAA==.',['逆袭']='逆袭的夙命:BAABKgAECn8WAAMOAAgIZiClDQCZAgAOAAgIZiClDQCZAgAfAAEIAAAlTQAAAAAAAA==.',['逐影']='逐影玥:BAAAKgAECggICQAAAA==.',['遺忘']='遺忘好久:BAAAKgAECggICgAAAA==.',['邪神']='邪神的大功德:BAAAKgAECgUIBQAAAA==.',['重庆']='重庆夏季:BAAAKgAFFAEIAQAAAA==.重庆夏德:BAAAKgAECgUIBgAAAA==.重庆夏曰:BAAAKgAECgcIDQAAAA==.重庆夏末:BAAAKgAFFAQIBAAAAA==.重庆夏牧:BAABKgAECn8dAAIBAAgIIBvTGgDrAQABAAgIIBvTGgDrAQAAAA==.重庆夏骑:BAAAKgAECgYICwAAAA==.',['钟大']='钟大哥:BAAAKgAFFAQIAgAAAA==.',['闪电']='闪电虎:BAACKgAFFH8GAAIXAAIImwsAIABvAAAXAAIImwsAIABvAAAqAAQKfz0AAxcACAjJGDIQAMgBABcACAjJGDIQAMgBABYABgiSCqukAN0AAAAA.',['闪耀']='闪耀之辉:BAAAKgAECgcIBwAAAA==.',['阴影']='阴影的逆袭:BAAAKgAECggICgAAAA==.',['阿喵']='阿喵:BAAAKgAECggICAAAAA==.',['阿库']='阿库娅:BAAAKgAECgYIBgAAAA==.',['阿西']='阿西果果:BAABKgAFFH8GAAIGAAQISBm8GADsAAAGAAQISBm8GADsAAABKgAFFAgIQAAGAL4iAA==.',['陌生']='陌生丶:BAAAKgAECgQIBAAAAA==.',['降临']='降临哀木涕:BAAAKgADCgYIBgAAAA==.降临烈仁:BAAAKgADCgcIBwAAAA==.',['雨后']='雨后初晴:BAABKgAFFH8KAAIXAAYIbhUFGAAoAQAXAAYIbhUFGAAoAQABKgAFFAgIEwAWAOUdAA==.',['雨珊']='雨珊:BAACKgAFFH8JAAMMAAYI6hxCEQCRAQAMAAUI7SNCEQCRAQALAAIIbgG/IwBAAAAqAAQKfyQAAgsACAhjCBk1APYAAAsACAhjCBk1APYAAAAA.',['雲烟']='雲烟丨:BAAAKgAECgQIBAAAAA==.',['青青']='青青丶子菁:BAABKgAECn8VAAIdAAgICgxNNQAeAQAdAAgICgxNNQAeAQAAAA==.',['顶风']='顶风洞洞批:BAAAKgAECgMIAwAAAA==.',['风云']='风云无忌:BAAAKgAECgIIBQAAAA==.',['风影']='风影月:BAAAKgAECgMIAwAAAA==.',['风暴']='风暴佣兵:BAAAKgAECgUIBQAAAA==.',['飞将']='飞将:BAAAKgAFFAIIAgAAAA==.',['飞虎']='飞虎子:BAAAKgAECgIIAgAAAA==.',['食野']='食野之苹:BAAAKgAECggIDQAAAA==.',['骑咕']='骑咕咕:BAABKgAECn85AAIdAAgIuB5BBABIAgAdAAgIuB5BBABIAgAAAA==.',['骑猪']='骑猪撞树上:BAAAKgAFFAcIAwAAAA==.',['鬼魅']='鬼魅刺客:BAAAKgADCgcIBwAAAA==.',['魄星']='魄星:BAAAKgAECgUICAAAAA==.',['魅丶']='魅丶色:BAAAKgAECgcIDgAAAA==.',['魅族']='魅族小生:BAAAKgAFFAQIBAAAAA==.',['鲜血']='鲜血与荣耀:BAAAKgAECgEIAQAAAA==.鲜血雷鸣:BAAAKgAFFAEIAQAAAA==.',['鸭梨']='鸭梨:BAAAKgAECgMIAwAAAA==.',['黑锋']='黑锋老仙:BAAAKgAECgIIAgAAAA==.',['黔虞']='黔虞:BAAAKgAFFAgIBAAAAA==.',['龙枪']='龙枪传奇:BAAAKgAFFAIIAgAAAA==.',['龙魂']='龙魂兽神:BAAAKgADCggICAAAAA==.龙魂圣光:BAAAKgAECgYICQAAAA==.龙魂法神:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end