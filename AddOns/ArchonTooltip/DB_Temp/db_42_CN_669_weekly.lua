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
 local lookup = {'Priest-Holy','DeathKnight-Unholy','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','Druid-Balance','Druid-Restoration','Unknown-Unknown','Warrior-Arms','Warrior-Protection','Paladin-Protection','Paladin-Holy','DeathKnight-Blood','Warlock-Demonology','Warlock-Destruction','Priest-Discipline','Mage-Frost','Mage-Arcane','Warrior-Fury','DemonHunter-Havoc','Druid-Guardian','Warlock-Affliction','Rogue-Assassination','Hunter-Marksmanship','Evoker-Devastation','Druid-Feral','Hunter-BeastMastery','Hunter-Survival','Mage-Fire','Evoker-Preservation','DemonHunter-Vengeance',}; local provider = {region='CN',realm='布鲁塔卢斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Afterglow:BAABKgAFFH8TAAIBAAMICSLZBwD4AAABAAMICSLZBwD4AAAAAA==.',Ai='Aimdk:BAAAKgAECgEIAQABKgAFFAgICAACAIkfAA==.',Al='Alanpriest:BAABKgAFFH8LAAMDAAYIvA1NAgB4AQADAAYIvA1NAgB4AQAEAAQI/ST6AwAfAQAAAA==.Alexander:BAABKgAFFH8IAAIFAAgI6g3UCwDmAQAFAAgI6g3UCwDmAQAAAA==.',Bi='Bigsprite:BAAAKgAECgcICgAAAA==.',Bl='Blackcow:BAABKgAFFH8KAAMGAAQIPBj7NwDAAAAGAAQIPBj7NwDAAAAHAAQI9xJ8HwCuAAABKgAFFAgIBAAIAAAAAA==.',Da='Darkanglell:BAAAKgADCggICAAAAA==.',De='Determine:BAABKgAFFH8HAAIDAAMIuSDTHAAKAQADAAMIuSDTHAAKAQABKgAFFAMIEwABAAkiAA==.',Dr='Drunk:BAAAKgADCgcICQAAAA==.',Fe='Featmellow:BAAAKgAECgMIAwAAAA==.',Ha='Halfgiant:BAAAKgAFFAQIBAAAAA==.Harbinger:BAAAKgAECggIDAABKgAFFAMIEwABAAkiAA==.',Hu='Hushnow:BAAAKgADCggIEgAAAA==.',Im='Immature:BAAAKgADCggICAAAAA==.',Le='Legendary:BAABKgAFFH8OAAIDAAYI9B6tAQCTAQADAAYI9B6tAQCTAQABKgAFFAgIBgADADwFAA==.',Lz='Lzlzjlove:BAAAKgAECggICAAAAA==.',Ma='Maxholloway:BAABKgAFFH8MAAMJAAMIFxGRFgDRAAAJAAMIkA+RFgDRAAAKAAMIpgouCgCFAAAAAA==.',Me='Melody:BAAAKgAFFAIIAgAAAA==.',Ox='Oxox:BAAAKgADCgcIBwAAAA==.',Pa='Paladinelf:BAAAKgAECggICAAAAA==.',Pu='Puggf:BAAAKgAECgMIAwAAAA==.',Re='Reaxys:BAAAKgAECgEIAQAAAA==.',Ss='Ssr:BAAAKgAECggICAAAAA==.',Vo='Volkanovski:BAABKgAFFH8OAAIDAAMI3xYyGAC0AAADAAMI3xYyGAC0AAAAAA==.',['一乌']='一乌拉诺斯一:BAAAKgADCgIIAgAAAA==.',['一剑']='一剑血:BAABKgAECn8WAAMFAAgITBbpUwDBAQAFAAgITBbpUwDBAQALAAEI7AP2YAAKAAAAAA==.',['一夏']='一夏夜幽梦丶:BAAAKgADCgQIBAAAAA==.',['一无']='一无:BAAAKgAFFAIIAgAAAA==.',['一牧']='一牧了燃:BAAAKgAECgUIBQAAAA==.',['一瞬']='一瞬永恒:BAAAKgADCgUIBQAAAA==.',['一筒']='一筒:BAAAKgADCggIDAAAAA==.',['一苇']='一苇之所如:BAABKgAFFH8MAAIMAAQIlBeUBQDxAAAMAAQIlBeUBQDxAAAAAA==.',['一颗']='一颗老树:BAABKgAFFH8GAAIGAAYInhCLGgBFAQAGAAYInhCLGgBFAQAAAA==.',['万倾']='万倾之茫然:BAABKgAFFH8MAAMNAAQI5AwuJQCDAAANAAQI5AwuJQCDAAACAAII0wJrLABhAAAAAA==.',['三条']='三条緋路:BAAAKgAFFAgIAgAAAA==.',['不唸']='不唸過往:BAAAKgAECgIIAwAAAA==.',['不染']='不染凡尘:BAAAKgAFFAQIBAAAAA==.',['不死']='不死不休:BAAAKgAECgcICQAAAA==.',['不灭']='不灭饕餮:BAABKgAFFH8FAAIOAAMI+BWUDADRAAAOAAMI+BWUDADRAAAAAA==.',['不空']='不空小柒:BAAAKgAECgcICgAAAA==.不空小猎:BAAAKgAECgcIBwAAAA==.不空小玛:BAABKgAECn8aAAMPAAYIPxv0FgBNAQAPAAYIPxv0FgBNAQAOAAEILgm8gAArAAAAAA==.',['丨楼']='丨楼兰丨:BAABKgAFFH8KAAIQAAYIqRxLBgAwAQAQAAYIqRxLBgAwAQABKgAFFAgIEwABAP0gAA==.',['丨碌']='丨碌碌无为:BAAAKgADCgYIBgAAAA==.',['丨葡']='丨葡萄蜀黍:BAAAKgAECgcIBwAAAA==.',['丶旧']='丶旧年的惆怅:BAAAKgADCgEIAQAAAA==.',['丷萌']='丷萌胖胖:BAAAKgAECggIEQAAAA==.',['九月']='九月的榴莲:BAAAKgAECgIIAgAAAA==.九月的玫瑰:BAAAKgADCggICAAAAA==.',['九条']='九条:BAAAKgAECgUICAAAAA==.',['二舅']='二舅妈:BAAAKgAFFAIIAgAAAA==.',['五门']='五门茜:BAACKgAFFH8JAAMRAAMIbQkZHQCbAAASAAMIbQmGLQCuAAARAAMIMgcZHQCbAAAqAAQKfxoAAxEACAiSHYIgAAkCABEABwi1HYIgAAkCABIABwinGyYiAOUBAAAA.',['产卵']='产卵机器:BAAAKgAFFAIIAQAAAA==.',['传奇']='传奇耐揍王:BAAAKgADCgIIAgAAAA==.',['你也']='你也令人着迷:BAAAKgAECggICQAAAA==.',['信仰']='信仰图腾:BAAAKgAFFAIIAgAAAA==.',['元素']='元素之怒火:BAAAKgADCgQIBAAAAA==.',['克里']='克里斯之刃:BAAAKgAECgQIBAAAAA==.',['八条']='八条:BAAAKgADCggICwAAAA==.',['冈萨']='冈萨雷斯:BAAAKgAECgUIBQAAAA==.',['冬天']='冬天:BAAAKgAECgYICwAAAA==.',['冰与']='冰与火芝歌:BAAAKgADCgIIAgAAAA==.',['冰凌']='冰凌:BAAAKgADCgMIAwAAAA==.',['冰檒']='冰檒戦神:BAACKgAFFH8OAAMTAAQIeAOsGACWAAATAAQIeAOsGACWAAAKAAMIGQJ7DABIAAAqAAQKfxYAAgoACAh2CpchAPUAAAoACAh2CpchAPUAAAAA.冰檒玥影:BAABKgAFFH8HAAIFAAMIJgn5aACaAAAFAAMIJgn5aACaAAAAAA==.',['冰豆']='冰豆花:BAAAKgAECgIIAwAAAA==.',['分行']='分行长:BAAAKgADCggIDwAAAA==.',['初一']='初一:BAAAKgAECggICwAAAA==.',['初音']='初音:BAABKgAFFH8QAAMEAAYIGSFuBQCnAQAEAAYIGSFuBQCnAQADAAQIAx95GwARAQAAAA==.',['勇彤']='勇彤:BAAAKgADCggICQAAAA==.',['匿名']='匿名丶昊:BAABKgAFFH8NAAIBAAQI6RUIIwC4AAABAAQI6RUIIwC4AAAAAA==.',['十三']='十三:BAAAKgADCgMIAwAAAA==.',['十九']='十九:BAAAKgADCggICAAAAA==.',['午夜']='午夜屠猪郎:BAABKgAECn8ZAAIJAAcIfhxGHwC6AQAJAAcIfhxGHwC6AQAAAA==.',['卩厶']='卩厶侽灬紸角:BAAAKgAECggIEAAAAA==.',['厲囸']='厲囸:BAAAKgAECgEIAQAAAA==.',['发财']='发财:BAAAKgADCggICQAAAA==.',['叫我']='叫我帅哥就好:BAAAKgAECggIEAAAAA==.叫我法爷:BAAAKgAECgMIAwAAAA==.',['叮当']='叮当猫:BAAAKgAECggIEQAAAA==.',['吉普']='吉普赛囡囡:BAAAKgAECgYIBgAAAA==.',['咕德']='咕德猫柠:BAABKgAFFH8KAAIGAAYI0COlDgCxAQAGAAYI0COlDgCxAQAAAA==.',['咖喱']='咖喱鸡腿堡:BAAAKgAECgUIBQAAAA==.',['哈密']='哈密瓜王:BAAAKgAFFAYIAgAAAA==.',['啥瞒']='啥瞒:BAAAKgAFFAIIAgAAAA==.',['回眸']='回眸谁浅笑丶:BAABKgAFFH8GAAIMAAQIFhFFCADfAAAMAAQIFhFFCADfAAAAAA==.',['团灭']='团灭制招者:BAAAKgADCgQIBAAAAA==.',['圆圆']='圆圆老巫婆:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光嗷呜:BAAAKgAECggICAAAAA==.',['圣殿']='圣殿骑士和道:BAAAKgAFFAcIBAAAAA==.',['圣电']='圣电神风:BAAAKgAECgcICwAAAA==.',['夏雨']='夏雨点滴:BAAAKgAECgYIBwAAAA==.',['大咕']='大咕咕:BAAAKgADCggICAAAAA==.',['天堂']='天堂任鸟飞丶:BAAAKgAFFAgIBAAAAA==.',['天灾']='天灾丶怒风:BAABKgAFFH8GAAIUAAYIOhJIGwDYAAAUAAYIOhJIGwDYAAAAAA==.',['奄鸟']='奄鸟亨鸟:BAABKgAFFH8HAAIVAAMI/RYYBQDLAAAVAAMI/RYYBQDLAAAAAA==.',['奈何']='奈何一身傲骨:BAAAKgADCgYIBgAAAA==.',['奔跑']='奔跑的油条灬:BAAAKgAECgUIBAAAAA==.',['好痛']='好痛好苦:BAABKgAFFH8FAAIWAAUIXR11BABDAQAWAAUIXR11BABDAQAAAA==.',['小发']='小发雷霆:BAABKgAFFH8IAAITAAQIaiBfCwAOAQATAAQIaiBfCwAOAQAAAA==.',['小太']='小太子乃:BAABKgAECn8UAAIFAAgISA/wMwA/AQAFAAgISA/wMwA/AQAAAA==.',['小宝']='小宝格丽:BAAAKgAFFAEIAQAAAA==.',['小开']='小开的血圣:BAAAKgAFFAMIAwAAAA==.',['小酋']='小酋长:BAAAKgAECggICQAAAA==.',['岁月']='岁月灬静好:BAABKgAFFH8IAAICAAgI8RL/BgAkAgACAAgI8RL/BgAkAgAAAA==.',['左手']='左手牵龍:BAAAKgAECgMIAwAAAA==.',['巴洛']='巴洛菲:BAAAKgADCgIIAgAAAA==.',['帝如']='帝如來:BAAAKgAFFAgIBAAAAA==.',['幕夜']='幕夜舞稚:BAAAKgAECggICgAAAA==.',['幻化']='幻化成香蕉:BAAAKgADCgcIBwAAAA==.',['康斯']='康斯坦丁:BAABKgAFFH8LAAIXAAYI4xBEDQB6AQAXAAYI4xBEDQB6AQAAAA==.',['廿三']='廿三:BAAAKgADCggICAAAAA==.',['弑血']='弑血冰夜:BAABKgAFFH8GAAMPAAYIjBeKHQAbAQAPAAUIORaKHQAbAQAOAAEI2BzoIwBSAAABKgAFFAgIDgAPAPkhAA==.',['弗雷']='弗雷尔络寺:BAAAKgAFFAIIAgAAAA==.',['彡生']='彡生别这様:BAAAKgAECgIIAgAAAA==.',['思念']='思念丶昊:BAAAKgAFFAIIAgAAAA==.',['情根']='情根:BAAAKgAECgIIAgAAAA==.',['慕夜']='慕夜舞雉:BAAAKgAECgYICAAAAA==.',['我会']='我会为祢心醉:BAAAKgAECggICgAAAA==.',['战刃']='战刃透心凉:BAAAKgAFFAIIAgAAAA==.',['战神']='战神子龙:BAAAKgADCgEIAQAAAA==.',['指尖']='指尖的旋律:BAABKgAFFH8IAAIQAAgIaw6FBACnAQAQAAgIaw6FBACnAQAAAA==.',['摇摆']='摇摆的风铃:BAAAKgAFFAMIAwAAAA==.',['文雅']='文雅适合我:BAAAKgAFFAQIBAAAAA==.',['新角']='新角色重复:BAAAKgAFFAgIBAAAAA==.',['方块']='方块黑色:BAABKgAFFH8FAAIYAAMI3wf6GQCXAAAYAAMI3wf6GQCXAAAAAA==.',['旋风']='旋风冰雨:BAABKgAFFH8GAAMRAAQIxg6oCwDIAAARAAQIxg6oCwDIAAASAAEIJQ/KJwBAAAAAAA==.',['无敌']='无敌的屁屁:BAAAKgADCgQICAAAAA==.',['无邪']='无邪:BAAAKgAECgEIAQAAAA==.',['春马']='春马和祂:BAAAKgAECgIIAgAAAA==.',['暴力']='暴力鲨鱼:BAAAKgADCgUIBQAAAA==.',['最爱']='最爱小猪:BAAAKgAFFAYIAgAAAA==.',['有钱']='有钱就是爷:BAAAKgAECgcICQAAAA==.',['村口']='村口一蹲:BAAAKgAECgYIDgAAAA==.',['果冻']='果冻快感妹:BAAAKgAECgIIAgAAAA==.',['枫棠']='枫棠映夜:BAAAKgADCggICQAAAA==.',['桃花']='桃花叶落:BAAAKgAECggICAAAAA==.',['死马']='死马小怪兽:BAAAKgADCgYIBgAAAA==.',['流风']='流风回雪:BAABKgAFFH8IAAIZAAgItA9kCgDKAQAZAAgItA9kCgDKAQAAAA==.',['浪人']='浪人无敌:BAABKgAFFH8GAAITAAYI4wddEABQAQATAAYI4wddEABQAQAAAA==.',['温蕾']='温蕾丶萨:BAAAKgADCggICAAAAA==.',['溫柔']='溫柔一刀:BAAAKgAFFAQIBAAAAA==.',['滅烟']='滅烟:BAAAKgAECgMIAwAAAA==.',['滚球']='滚球:BAAAKgAECgUIBQAAAA==.',['灬莫']='灬莫扎特:BAABKgAECn8VAAMGAAgItxsCJwAZAgAGAAgItxsCJwAZAgAaAAEIfxLVLAA4AAAAAA==.',['灬頁']='灬頁書:BAAAKgAFFAQIAQAAAA==.',['灵魂']='灵魂掌控者:BAAAKgADCgUIBgAAAA==.',['烟酒']='烟酒生哥哥:BAAAKgAFFAYIBAAAAA==.',['烟雨']='烟雨荷花影:BAAAKgAECgMIAwAAAA==.',['烧一']='烧一下很开心:BAAAKgADCggICAAAAA==.',['热爱']='热爱原始社会:BAAAKgADCgQIBAAAAA==.',['狂野']='狂野辣妹:BAAAKgAFFAIIAwAAAA==.',['独自']='独自旅行:BAAAKgADCgYIBgAAAA==.',['狮心']='狮心:BAABKgAFFH8fAAITAAgIFRYZCgCrAQATAAgIFRYZCgCrAQAAAA==.',['獠牙']='獠牙很大:BAAAKgADCggICAAAAA==.',['王大']='王大福:BAAAKgAECgUIBQAAAA==.',['玖丶']='玖丶箭:BAAAKgAECgYIBgAAAA==.',['玖玥']='玖玥丨圣:BAAAKgADCggICAAAAA==.',['神都']='神都:BAAAKgAECgQIBAAAAA==.神都萨:BAAAKgAFFAgIBAAAAA==.',['秦人']='秦人老赵:BAAAKgAECgYIBwAAAA==.',['稼轩']='稼轩:BAABKgAFFH8IAAQbAAUI/xW8IACeAAAbAAMIRBa8IACeAAAYAAMIkRVuQgByAAAcAAEIWBI7BABOAAAAAA==.',['第二']='第二圣:BAABKgAFFH8GAAMFAAQIphRNJADeAAAFAAMIphRNJADeAAAMAAEIAADhFwAAAAAAAA==.',['等我']='等我抽根烟:BAAAKgADCggIEAAAAA==.',['系软']='系软绵绵君:BAABKgAFFH8IAAIQAAgI3RaAAwAoAgAQAAgI3RaAAwAoAgAAAA==.',['索马']='索马里牛肉:BAAAKgAECggIEQAAAA==.',['繁花']='繁花:BAACKgAFFH8ZAAISAAQIcQ0ZGwCoAAASAAQIcQ0ZGwCoAAAqAAQKfxoAAxIACAg8F8kkANMBABIACAg8F8kkANMBABEABQgQDv1OALAAAAAA.',['红爺']='红爺的蜜蜜:BAAAKgAECgMIAwAAAA==.',['缕缕']='缕缕:BAAAKgADCgEIAQAAAA==.',['缺心']='缺心眼子:BAAAKgADCgQIBAAAAA==.',['联盟']='联盟滚过来:BAAAKgAECgMIAwAAAA==.',['肥肥']='肥肥的熊缺:BAAAKgAECgIIAwAAAA==.',['舞亦']='舞亦香滿衣:BAABKgAFFH8GAAIFAAYI5xZLHgB4AQAFAAYI5xZLHgB4AQAAAA==.',['艾丽']='艾丽娅史塔克:BAAAKgADCgEIAQAAAA==.艾丽法:BAAAKgAECgEIAQAAAA==.',['花石']='花石头:BAABKgAFFH8HAAMRAAUIeg6qBQBOAQARAAUIeg6qBQBOAQAdAAEIBAckPwA7AAAAAA==.',['花花']='花花与三猫:BAABKgAECn8WAAMVAAgIQA3kHAAHAQAVAAgIQA3kHAAHAQAaAAUI1QPWJQB3AAAAAA==.',['花落']='花落雨末湮:BAAAKgADCgEIAQAAAA==.',['茉香']='茉香绿茶:BAABKgAFFH8HAAMQAAUIoBGuHQCGAAAQAAIIZw+uHQCGAAABAAUIewxkMwB2AAAAAA==.',['莫大']='莫大叔:BAAAKgAFFAIIAgAAAA==.',['萌牛']='萌牛集团:BAAAKgADCgIIAgAAAA==.',['落婲']='落婲丶无痕:BAABKgAFFH8OAAMCAAgI2hVzBgAuAgACAAgIiRVzBgAuAgANAAYI7ROIDgA0AQAAAA==.',['葉落']='葉落知秋:BAAAKgAFFAEIAQAAAA==.',['蓝伯']='蓝伯基尼昆:BAAAKgADCgUIBQAAAA==.',['蔚蓝']='蔚蓝之拥:BAAAKgAECgEIAQAAAA==.',['蛋蛋']='蛋蛋小滴滴:BAAAKgADCggICAAAAA==.',['血之']='血之挽丶歌:BAAAKgADCgIIAgAAAA==.',['血性']='血性男儿:BAACKgAFFH8NAAMbAAMIYxkPKwDZAAAbAAMIYxkPKwDZAAAYAAIIZwOsIQBnAAAqAAQKfxkAAhsACAjQHE0zACgCABsACAjQHE0zACgCAAAA.',['血燕']='血燕:BAABKgAFFH8QAAMZAAYISRnvDwBhAQAZAAYISRnvDwBhAQAeAAII+xtMBgCXAAAAAA==.',['超雄']='超雄汉堡包:BAAAKgADCggICAAAAA==.',['路子']='路子野:BAAAKgAECgcIDQAAAA==.',['踏云']='踏云无痕:BAABKgAFFH8MAAMfAAQIhxE4FQCcAAAUAAQIHhAvMAC9AAAfAAQIUxE4FQCcAAABKgAFFAgIFwAUAC8iAA==.',['踏玉']='踏玉:BAABKgAFFH8HAAIRAAUIshXuFgC6AAARAAUIshXuFgC6AAAAAA==.',['踏花']='踏花有痕:BAABKgAFFH8QAAIDAAYISBhPDACEAQADAAYISBhPDACEAQAAAA==.',['达克']='达克尼斯:BAAAKgAECgQIBAAAAA==.',['远东']='远东鸟:BAAAKgADCgYIBgAAAA==.',['逆风']='逆风燎千里:BAACKgAFFH8JAAITAAYI2RHTDwD2AAATAAYI2RHTDwD2AAAqAAQKfxYAAhMACAg5HQkbAPkBABMACAg5HQkbAPkBAAAA.',['金牛']='金牛座小海:BAAAKgAECgYIDQAAAA==.',['钢之']='钢之心:BAAAKgAFFAQIBAAAAA==.',['铭魂']='铭魂:BAAAKgAECggICAABKgAFFAgIDwAPAJIcAA==.',['防护']='防护员:BAAAKgADCggICAAAAA==.',['阿斯']='阿斯大前锋:BAAAKgAECgcIDAAAAA==.阿斯好同学:BAAAKgAECgcIDAAAAA==.',['隆隆']='隆隆:BAAAKgADCggICAAAAA==.',['雷古']='雷古鲁斯:BAABKgAFFH8QAAMCAAYIGxxnEwB/AQACAAYIGxxnEwB/AQANAAYIlRFuDgA1AQABKgAFFAgIDgACAEoXAA==.',['顏佬']='顏佬闆:BAAAKgADCgcICgAAAA==.',['顶风']='顶风射八丈:BAAAKgADCgcIBwAAAA==.',['领丿']='领丿袖:BAABKgAECn8jAAMEAAgICRf8HADgAQAEAAgICRf8HADgAQADAAgIIxcrQAB2AQAAAA==.',['风小']='风小狐:BAAAKgADCgUIBQAAAA==.',['香草']='香草味猕猴桃:BAABKgAFFH8HAAIFAAcIHAi8EwBjAQAFAAcIHAi8EwBjAQAAAA==.',['马尼']='马尼哥特:BAAAKgAECgMIAwABKgAFFAgICwAXAOMQAA==.',['骑猪']='骑猪追乌龟:BAAAKgAECgIIAgAAAA==.',['鲨鱼']='鲨鱼辣椒:BAABKgAFFH8IAAIZAAgIjgZ1CwCIAQAZAAgIjgZ1CwCIAQAAAA==.',['麻瓜']='麻瓜:BAAAKgADCgIIAgAAAA==.',['黄瓜']='黄瓜丶乃几:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end