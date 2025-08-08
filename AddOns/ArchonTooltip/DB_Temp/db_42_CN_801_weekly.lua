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
 local lookup = {'Mage-Fire','Monk-Windwalker','Paladin-Retribution','Warrior-Fury','Warrior-Arms','DemonHunter-Havoc','Mage-Frost','Mage-Arcane','Rogue-Assassination','Druid-Restoration','Monk-Mistweaver','Priest-Holy','Priest-Shadow','Hunter-Survival','Hunter-Marksmanship','Paladin-Protection','Hunter-BeastMastery','Priest-Discipline','DemonHunter-Vengeance','Warlock-Demonology','Warlock-Destruction','Shaman-Restoration','DeathKnight-Unholy','Warlock-Affliction','Unknown-Unknown','Druid-Balance','Druid-Guardian','Paladin-Holy','Shaman-Enhancement','DeathKnight-Blood','Shaman-Elemental','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='艾苏恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ag='Aggression:BAABKgAFFH8FAAIBAAUI8hkaCgBVAQABAAUI8hkaCgBVAQAAAA==.',Cl='Clinch:BAAAKgAECgYIBgABKgAFFAgIDgACANAQAA==.',Dr='Drakthar:BAAAKgAFFAQIBAAAAA==.',Eg='Egg:BAAAKgAECgEIAQAAAA==.',Ho='Holy:BAABKgAFFH8IAAIDAAgIExb8BwBEAgADAAgIExb8BwBEAgAAAA==.',In='Insert:BAABKgAFFH8MAAMEAAgIBxxMAwCPAgAEAAgIBxxMAwCPAgAFAAQIjAYAHACrAAAAAA==.',Je='Jessie:BAAAKgAECgUIBwAAAA==.',Ki='Kiko:BAABKgAFFH8KAAIGAAYI0g8cFwBCAQAGAAYI0g8cFwBCAQAAAA==.',Ko='Koler:BAABKgAECn8VAAMHAAgIyRj8IgD6AQAHAAgIyRj8IgD6AQAIAAYIEhLLTgADAQAAAA==.',Le='Lezard:BAEBKgAFFH8IAAIGAAQItRv+DQAKAQAGAAQItRv+DQAKAQAAAA==.',Li='Lition:BAAAKgAFFAMIBAAAAA==.',Mi='Mikeos:BAAAKgAECgYIDQAAAA==.',Na='Nathan:BAAAKgAECgYICwAAAA==.',On='Onlyfantasy:BAAAKgAECgYIBgAAAA==.',Qw='Qwqa:BAAAKgAFFAEIAQAAAA==.',Sc='Scale:BAABKgAFFH8IAAIJAAgIPhL6BwDsAQAJAAgIPhL6BwDsAQAAAA==.',Wi='Windcaster:BAAAKgAECgUICAAAAA==.',['一期']='一期一会:BAAAKgAFFAQIBAAAAA==.',['七叶']='七叶壹枝花:BAABKgAFFH8IAAIKAAgIUwY+BgBnAQAKAAgIUwY+BgBnAQAAAA==.',['七彩']='七彩云:BAAAKgAECgEIAQAAAA==.七彩雨:BAAAKgAECgYIBgAAAA==.',['丨一']='丨一龙丨:BAAAKgAECgQIBAAAAA==.',['丨璇']='丨璇灬木:BAAAKgAFFAEIAgAAAA==.',['九莲']='九莲宝灯:BAAAKgADCggIFAAAAA==.',['云汐']='云汐:BAAAKgAECgIIAgAAAA==.',['五帝']='五帝棋士:BAAAKgAECgMIAwAAAA==.',['五杀']='五杀:BAAAKgADCgIIAgAAAA==.',['亚麻']='亚麻得欧巴:BAAAKgAFFAIIAgAAAA==.',['人逢']='人逢喜事:BAABKgAFFH8IAAIGAAgIhwtiCQDpAQAGAAgIhwtiCQDpAQAAAA==.',['今宵']='今宵有美酒:BAACKgAFFH8GAAIEAAQIpxrNHADhAAAEAAQIpxrNHADhAAAqAAQKfxYAAgQACAgzIi8LAK4CAAQACAgzIi8LAK4CAAAA.',['伊脷']='伊脷丹丶怒风:BAAAKgAECgEIAQAAAA==.',['休利']='休利耶尔:BAAAKgAFFAQIBAAAAA==.',['你们']='你们很缺德么:BAABKgAFFH8GAAIKAAYIJxgkCACJAQAKAAYIJxgkCACJAQAAAA==.',['俊恒']='俊恒水:BAABKgAFFH8MAAMLAAgI0wqnBgCjAQALAAgI0wqnBgCjAQACAAEIdgeNIAA7AAAAAA==.',['元宝']='元宝大神官:BAAAKgAFFAIIAgAAAA==.',['其實']='其實我是戰士:BAAAKgADCgMIAwAAAA==.',['冥河']='冥河夜神:BAABKgAFFH8GAAMMAAYIBBJOGgDnAAAMAAUIxw9OGgDnAAANAAEIjiLtJgBZAAAAAA==.',['冰开']='冰开水:BAABKgAFFH8GAAIEAAYIQx0QCADbAQAEAAYIQx0QCADbAQAAAA==.',['华熊']='华熊猫:BAABKgAFFH8SAAMOAAgIVBFTAAAVAgAOAAgIdg9TAAAVAgAPAAYI4RJdEwBHAQAAAA==.',['卡娜']='卡娜娃丝:BAAAKgAECggICAAAAA==.',['原来']='原来是冒烟:BAAAKgADCgMIAwAAAA==.',['叁炮']='叁炮:BAAAKgAECgIIAwAAAA==.',['又酷']='又酷又飒:BAAAKgAECgYIBgAAAA==.',['双魂']='双魂瓦达莉亚:BAAAKgAECgQIBAAAAA==.',['受气']='受气包:BAAAKgADCgEIAQAAAA==.',['可乐']='可乐必加冰:BAABKgAFFH8IAAIDAAQIUhjJMQCoAAADAAQIUhjJMQCoAAABKgAFFAgIEgAGAJgVAA==.',['周一']='周一:BAAAKgAFFAQIBAAAAA==.',['咕迩']='咕迩丹:BAAAKgAECgMIAwAAAA==.',['咖啡']='咖啡潴:BAAAKgAECgMIBgAAAA==.',['哈色']='哈色:BAAAKgAFFAQIAgAAAA==.',['哞定']='哞定天下:BAAAKgAECggIEQAAAA==.',['唐古']='唐古拉波斯乐:BAABKgAFFH8IAAMDAAYIlB5AEQDUAQADAAYIlB5AEQDUAQAQAAII5gzGJQBeAAAAAA==.',['啊当']='啊当:BAAAKgAECgMIAwAAAA==.',['喜马']='喜马拉雅:BAAAKgAFFAcIAQAAAA==.',['嘿辣']='嘿辣:BAAAKgADCgYIBgAAAA==.',['噗啊']='噗啊噗噗:BAABKgAFFH8FAAIRAAMIEgdqQACdAAARAAMIEgdqQACdAAAAAA==.',['团团']='团团:BAAAKgAECgUICwAAAA==.',['圣之']='圣之星:BAAAKgADCgcIBwAAAA==.',['圣光']='圣光在心中:BAABKgAFFH8GAAIQAAYI0Aw/EQD4AAAQAAYI0Aw/EQD4AAAAAA==.圣光笼罩:BAABKgAFFH8GAAISAAYI7BKzCQB+AQASAAYI7BKzCQB+AQAAAA==.',['圣枪']='圣枪小修女:BAAAKgAFFAMIBAAAAA==.',['圣虚']='圣虚王子:BAABKgAFFH8bAAIGAAgIHAzrCQDYAQAGAAgIHAzrCQDYAQAAAA==.',['圣骑']='圣骑飞飞:BAABKgAECn8ZAAIQAAgIQxLJIgA/AQAQAAgIQxLJIgA/AQAAAA==.',['地獄']='地獄咆哮:BAAAKgAECgEIAQAAAA==.',['复仇']='复仇的魔女:BAACKgAFFH8QAAMGAAYIQwwaDwBOAQAGAAYIQwwaDwBOAQATAAMIXATPHQBtAAAqAAQKfx0AAwYACAhJFAY/AK0BAAYACAiQEwY/AK0BABMACAhcDH02AOEAAAAA.',['多艾']='多艾:BAAAKgADCgEIAQAAAA==.',['夜之']='夜之咏叹:BAAAKgAECgMIAwAAAA==.',['夜里']='夜里白桃:BAABKgAFFH8MAAIRAAYIxA1rFgBEAQARAAYIxA1rFgBEAQAAAA==.',['大叔']='大叔大度:BAACKgAFFH8FAAIUAAMItAiLFACgAAAUAAMItAiLFACgAAAqAAQKfyEAAxUACAjcGG0fAK8BABUABgjPGG0fAK8BABQABwhRE1UjAG4BAAEqAAUUCAgRAA0AsBwA.',['大壮']='大壮开飞机:BAAAKgAFFAgIAQAAAA==.',['大天']='大天狼星:BAABKgAECn8dAAMPAAgIHRW/QABPAQARAAcI7hEadwBPAQAPAAcI+BO/QABPAQAAAA==.',['大抽']='大抽象家:BAAAKgAFFAQIBAABKgAFFAgICQAIAFQeAA==.',['大自']='大自然滴爸爸:BAABKgAFFH8HAAICAAcIwAQQCQBZAQACAAcIwAQQCQBZAQAAAA==.',['大雷']='大雷子:BAACKgAFFH8JAAIWAAMIlQtIOQCdAAAWAAMIlQtIOQCdAAAqAAQKfx0AAhYACAjwFgU4AKYBABYACAjwFgU4AKYBAAAA.',['天启']='天启之光:BAAAKgAECgYICQAAAA==.',['天涯']='天涯冷血剑:BAAAKgADCggIFAAAAA==.',['太曦']='太曦神照:BAAAKgAFFAYIAgAAAA==.',['奥斯']='奥斯丁丶圣光:BAAAKgAECgQIBAAAAA==.',['威少']='威少:BAAAKgAECgQIBAAAAA==.',['守护']='守护者伊瑞尔:BAAAKgAFFAQIAgABKgAFFAgICAARAHMNAA==.守护者艾维娜:BAAAKgAFFAQIBAAAAA==.',['小小']='小小松:BAABKgAFFH8OAAIDAAgImxj4DwDhAQADAAgImxj4DwDhAQAAAA==.',['小满']='小满:BAABKgAFFH8HAAIXAAQI8A/TOAC4AAAXAAQI8A/TOAC4AAAAAA==.',['小猪']='小猪猪:BAAAKgAECgQIBAAAAA==.',['小猫']='小猫猫:BAAAKgAECgMIAwAAAA==.',['小蚂']='小蚂蚁吃啥:BAAAKgAFFAQIBAABKgAFFAgIBgAYAGobAA==.',['小追']='小追忆:BAAAKgADCgIIAgAAAA==.',['就是']='就是爱:BAAAKgAFFAYIBAABKgAFFAgIBAAZAAAAAA==.就是这样紫:BAAAKgAECggICAAAAA==.',['岚禅']='岚禅:BAAAKgADCgQIBAAAAA==.',['峰丿']='峰丿:BAAAKgAECgUIBgAAAA==.',['席尔']='席尔瓦娜斯:BAABKgAFFH8cAAMRAAQILR3wJwDmAAARAAMIAhvwJwDmAAAPAAIIKROyJQBKAAAAAA==.',['幸子']='幸子:BAAAKgAECgIIAgAAAA==.',['幻忧']='幻忧尘:BAAAKgADCggIGAAAAA==.',['幽兰']='幽兰黛尔:BAAAKgADCgQIBAAAAA==.',['异域']='异域熊熊:BAAAKgAECggIDwAAAA==.',['弑神']='弑神九重天:BAAAKgADCgEIAQAAAA==.',['很红']='很红:BAAAKgAFFAYIAgABKgAFFAgICAABAKggAA==.',['心碎']='心碎无言:BAAAKgADCggICAAAAA==.',['必须']='必须改名:BAAAKgADCggICAAAAA==.',['快乐']='快乐长生:BAAAKgAECgQIBAAAAA==.',['总要']='总要有污妖:BAAAKgAFFAQIAQAAAA==.',['悠悠']='悠悠花武:BAAAKgAFFAIIAgAAAA==.',['惡靈']='惡靈灬騎士:BAAAKgAECgUICwAAAA==.',['懒得']='懒得起床:BAAAKgADCggICAAAAA==.',['懵逼']='懵逼不伤脑:BAAAKgAFFAYIBAAAAA==.懵逼且伤脑:BAAAKgAFFAEIAQAAAA==.懵逼又伤脑:BAABKgAFFH8IAAIWAAQI3SPLBAA3AQAWAAQI3SPLBAA3AQAAAA==.',['我上']='我上了我没了:BAAAKgAECgIIBAABKgAFFAgIDgARAEIfAA==.',['我恨']='我恨月亮:BAAAKgADCgEIAQAAAA==.',['我是']='我是奶茶:BAABKgAECn8dAAQaAAcIRxrZNgDNAQAaAAcIRxrZNgDNAQAKAAUIQhI8TADcAAAbAAIIcw4zPwAmAAAAAA==.',['我龙']='我龙爷:BAAAKgAECggICAAAAA==.',['戚戚']='戚戚骑:BAAAKgADCggICAAAAA==.',['拉丁']='拉丁:BAAAKgAECggICAAAAA==.',['拿莫']='拿莫稳:BAACKgAFFH8eAAIWAAgIrhobBAAkAgAWAAgIrhobBAAkAgAqAAQKfzMAAhYACAiBICwOAHwCABYACAiBICwOAHwCAAAA.',['提拉']='提拉米夙夙:BAABKgAFFH8HAAMVAAcIWgliGQA5AQAVAAUIXgpiGQA5AQAYAAIISASeIgBCAAAAAA==.',['搁浅']='搁浅的云丶:BAAAKgAFFAIIAgAAAA==.',['新能']='新能之光:BAABKgAECn8WAAIDAAgIFiFoWADuAQADAAgIFiFoWADuAQABKgAFFAgIDwADAMkcAA==.新能麓崖:BAAAKgAECggICAAAAA==.',['明年']='明年的夏天:BAAAKgADCgcIBwAAAA==.',['星河']='星河旧梦:BAAAKgAFFAMIAwAAAA==.',['星辰']='星辰火炎:BAABKgAFFH8GAAIIAAMIRggFHACiAAAIAAMIRggFHACiAAAAAA==.',['春丨']='春丨麗:BAAAKgAFFAQIBAAAAA==.',['春风']='春风尽人意:BAAAKgAECgYICQAAAA==.',['晴空']='晴空之翼:BAAAKgADCgMIBAAAAA==.',['暖暖']='暖暖布丁:BAAAKgAFFAMIAwAAAA==.',['月神']='月神祝福:BAAAKgAECgUIBQAAAA==.',['木木']='木木灵儿:BAABKgAECn8jAAIWAAgIKQ0cXgAlAQAWAAgIKQ0cXgAlAQAAAA==.',['来者']='来者不拒:BAABKgAECn8eAAIEAAgI8RyjHQAnAgAEAAgI8RyjHQAnAgAAAA==.',['柳飞']='柳飞扬:BAABKgAECn8oAAQDAAgI4QVw1QCwAAADAAgIagVw1QCwAAAQAAYIrwRJSgBmAAAcAAEI0AHOWQAaAAAAAA==.',['桐桦']='桐桦:BAAAKgAECgUIBgAAAA==.',['桑榆']='桑榆为尚:BAAAKgAECgUICgAAAA==.',['桑酒']='桑酒:BAAAKgADCggICAAAAA==.',['桔子']='桔子不是橘子:BAAAKgAFFAgIBAAAAA==.',['榕城']='榕城大虾:BAABKgAFFH8IAAIVAAgIeR7GDQD0AAAVAAgIeR7GDQD0AAAAAA==.榕城小虾米:BAAAKgAFFAQIBAAAAA==.榕城小螃蟹:BAABKgAFFH8GAAIdAAYIGQy3EwC5AAAdAAYIGQy3EwC5AAAAAA==.',['每天']='每天一颗苹果:BAAAKgADCggICAAAAA==.',['永恒']='永恒信仰:BAAAKgAECggIDAAAAA==.永恒挥夜:BAAAKgAECgQIBAAAAA==.永恒霄月:BAAAKgADCggIEAAAAA==.',['求我']='求我呀:BAAAKgAECgUIBQAAAA==.',['沸开']='沸开水:BAABKgAFFH8GAAMRAAYIrREYGQDtAAARAAQIdxMYGQDtAAAPAAII/w7COACTAAAAAA==.',['法玛']='法玛里澳:BAABKgAECn8UAAMKAAcI5BKUTwDOAAAKAAcI5BKUTwDOAAAaAAEISgqIygAwAAAAAA==.',['泥是']='泥是条几:BAAAKgAECgIIAgAAAA==.',['洁白']='洁白的救赎:BAABKgAECn8cAAIWAAgICgxNXQATAQAWAAgICgxNXQATAQAAAA==.',['流光']='流光电:BAAAKgADCggICQAAAA==.',['流鼻']='流鼻涕:BAAAKgAFFAgIBAAAAA==.',['淡泊']='淡泊之力:BAAAKgAECgQIBAAAAA==.',['温开']='温开水:BAABKgAFFH8GAAIVAAYIvRPHAgCoAQAVAAYIvRPHAgCoAQABKgAFFAgIFgAVAOgSAA==.',['漆黑']='漆黑的审判:BAACKgAFFH8MAAQNAAcIYgnFFQDNAAANAAYIYgnFFQDNAAAMAAQIGhAwDgDLAAASAAIIkggCEwBdAAAqAAQKfxcAAgwACAhEDsNHABoBAAwACAhEDsNHABoBAAAA.',['灭拜']='灭拜士:BAAAKgAECggIDwAAAA==.',['炽天']='炽天使洛洛:BAAAKgAECggIDgAAAA==.',['热开']='热开水:BAAAKgAFFAYIBAABKgAFFAgIEwAMAP0gAA==.',['熊八']='熊八:BAAAKgAECgMIAwAAAA==.',['熙沄']='熙沄:BAAAKgADCgEIAQAAAA==.',['爆爆']='爆爆:BAAAKgAFFAQIBAAAAA==.',['爱上']='爱上刘群华:BAAAKgADCggIEAAAAA==.',['爱吃']='爱吃车厘子嘛:BAABKgAFFH8GAAIDAAYIxRL8HwBwAQADAAYIxRL8HwBwAQAAAA==.',['爱神']='爱神丶丘比特:BAAAKgAECgYIEwAAAA==.',['牛板']='牛板筋:BAABKgAECn8WAAIDAAgIfxvsOAAcAgADAAgIfxvsOAAcAgAAAA==.',['猎丶']='猎丶爹:BAABKgAFFH8MAAIPAAYIVx9XEQBZAQAPAAYIVx9XEQBZAQAAAA==.',['猎之']='猎之神:BAABKgAFFH8QAAMRAAYIXxDNFQBIAQARAAYIXxDNFQBIAQAPAAQIqAe9OQCQAAABKgAFFAgIBgALABUEAA==.',['猎魔']='猎魔者:BAAAKgAECgYICgAAAA==.',['王者']='王者之星:BAAAKgADCggIFQAAAA==.',['畾畾']='畾畾:BAAAKgAECggIBQAAAA==.',['白昼']='白昼月:BAAAKgADCggICAAAAA==.',['白色']='白色伤疤:BAAAKgAFFAgIBAAAAA==.',['白衣']='白衣丶:BAABKgAFFH8GAAMRAAMIchoRIgACAQARAAMI2xkRIgACAQAPAAEIyA0fUQA6AAAAAA==.',['皮卡']='皮卡球:BAAAKgAFFAEIAQAAAA==.',['看什']='看什么看:BAACKgAFFH8MAAIRAAQIzxoRFADuAAARAAQIzxoRFADuAAAqAAQKfxwAAhEACAhBISNCAPABABEACAhBISNCAPABAAAA.',['矮柯']='矮柯基:BAAAKgAECgMIAwAAAA==.',['祖龙']='祖龙:BAAAKgAFFAgIBAAAAA==.',['神开']='神开水:BAAAKgAFFAQIBAAAAA==.',['祭墨']='祭墨墨:BAABKgAFFH8GAAIeAAYIcSYYBAAWAgAeAAYIcSYYBAAWAgABKgAFFAgIGgAXAEwhAA==.',['秒杀']='秒杀之剑:BAAAKgADCgcIBwAAAA==.',['空中']='空中换凶罩:BAABKgAFFH8KAAIaAAYI7BsrDgC3AQAaAAYI7BsrDgC3AQAAAA==.',['算你']='算你厉害:BAABKgAFFH8GAAIXAAYIXyDQDgCrAQAXAAYIXyDQDgCrAQAAAA==.',['納尔']='納尔克:BAABKgAFFH8NAAMTAAYIwBQrCAAfAQATAAYIeBIrCAAfAQAGAAQI6RcnFADwAAAAAA==.',['納薾']='納薾克:BAABKgAFFH8GAAIPAAYIgBNMEwBIAQAPAAYIgBNMEwBIAQAAAA==.',['紫焰']='紫焰之雨:BAAAKgADCgQIBAAAAA==.',['红柚']='红柚:BAAAKgAFFAgIAgAAAA==.',['纳言']='纳言敏行:BAACKgAFFH8KAAMVAAQINRyoDgDvAAAVAAQIEByoDgDvAAAUAAEIUxgdKgBGAAAqAAQKfxIAAhUACAj/G8ssAMIBABUACAj/G8ssAMIBAAAA.',['美九']='美九:BAAAKgADCggICAAAAA==.',['老烟']='老烟枪:BAABKgAFFH8HAAMKAAYIExRYFQD2AAAKAAUIQRNYFQD2AAAaAAIIDgNcXwA6AAAAAA==.',['聽風']='聽風戀海:BAAAKgAECgcIBwAAAA==.',['芒果']='芒果酱酱:BAABKgAFFH8YAAIMAAgIJAriDABWAQAMAAgIJAriDABWAQAAAA==.',['苏打']='苏打尐熊:BAABKgAFFH8lAAQVAAgIlx9wBQBDAgAVAAgIDRxwBQBDAgAYAAUI2yEnAgB/AQAUAAIIoRhJCgCrAAAAAA==.',['若飞']='若飞于:BAAAKgAECgYIBgAAAA==.',['葬送']='葬送的芙莉莲:BAACKgAFFH8tAAQVAAgIWR4fDgCrAQAVAAYIPxofDgCrAQAYAAMIqB3pEQCsAAAUAAMIDCGPEwCmAAAqAAQKfz0ABBUACAiiJcsxAKoBABUABgiCJMsxAKoBABQABQhvJD8oAF0BABgABAhJGzweAP4AAAAA.',['被宽']='被宽恕的亵渎:BAAAKgADCggICAAAAA==.被宽恕的残暴:BAAAKgAECgIIAgAAAA==.',['西北']='西北女小狼:BAAAKgAECggICAAAAA==.',['西楼']='西楼老公:BAABKgAECn8WAAMFAAgIRRubHADOAQAFAAgIxxebHADOAQAEAAgIxBOyMwCyAQAAAA==.',['西虹']='西虹市猎魔人:BAABKgAECn8dAAIDAAgI6R4/LgBHAgADAAgI6R4/LgBHAgAAAA==.',['警长']='警长:BAAAKgADCgIIAgAAAA==.',['超强']='超强熊熊大人:BAAAKgADCgYIBgAAAA==.',['超级']='超级法:BAAAKgADCgQIBAAAAA==.超级爱妞妞:BAAAKgADCgMIAwAAAA==.',['转角']='转角遇甜瓜:BAABKgAECn8VAAIDAAgIih51YQDZAQADAAgIih51YQDZAQAAAA==.',['输出']='输出嘎嘎猛:BAAAKgAFFAMIAwAAAA==.',['过往']='过往:BAAAKgADCggICAAAAA==.',['逢尤']='逢尤:BAAAKgAECgQIBQAAAA==.',['道明']='道明不差钱:BAAAKgAECgUIBQAAAA==.道明就差钱:BAAAKgAECgMIAwAAAA==.道明怕被砍:BAAAKgADCggICAAAAA==.道明爱劳动:BAAAKgAECgEIAQAAAA==.道明爱女大:BAAAKgADCggIDAAAAA==.道明爱旅行:BAAAKgADCggIEQAAAA==.道明爱看书:BAAAKgADCggIEAAAAA==.道明爱自由:BAAAKgADCgcIBwAAAA==.',['那一']='那一眼而深陷:BAABKgAFFH8GAAIXAAYIDBJ9FwBhAQAXAAYIDBJ9FwBhAQAAAA==.',['那我']='那我没办法:BAABKgAFFH8GAAMcAAQIGRaLBQDxAAAcAAQIGRaLBQDxAAADAAIIohhENgCdAAAAAA==.',['邮差']='邮差布兰多:BAAAKgAECggICAAAAA==.邮差托马斯:BAABKgAFFH8LAAIDAAYIWB/fEADYAQADAAYIWB/fEADYAQAAAA==.',['邱淑']='邱淑贞:BAAAKgAFFAYIBAABKgAFFAgIBAAZAAAAAA==.',['酋长']='酋长加尔鲁什:BAAAKgAECgcICAAAAA==.',['阳菜']='阳菜:BAAAKgAECgMIAwAAAA==.',['阴影']='阴影背后:BAAAKgAECgcICwAAAA==.',['阿尔']='阿尔萨丝:BAAAKgAECgYIBwAAAA==.',['阿星']='阿星真洋呼:BAAAKgAECgIIAwAAAA==.',['阿真']='阿真:BAABKgAECn8aAAIRAAgIEhmuFADjAQARAAgIEhmuFADjAQAAAA==.',['阿福']='阿福满足:BAABKgAECn8XAAIWAAgIBBLqYwAUAQAWAAgIBBLqYwAUAQAAAA==.',['阿风']='阿风:BAAAKgADCggICwAAAA==.',['陈丶']='陈丶风暴烈酒:BAAAKgAECgQIBAAAAA==.',['雨落']='雨落尘封:BAAAKgAECgcIBwAAAA==.',['雷刃']='雷刃:BAACKgAFFH8UAAIHAAMIgCC6DAACAQAHAAMIgCC6DAACAQAqAAQKfxUAAgcACAjIILoOAFoCAAcACAjIILoOAFoCAAAA.',['霜狼']='霜狼族丶萨迩:BAAAKgAECgEIAQAAAA==.',['靛开']='靛开水:BAAAKgAFFAYIBAAAAA==.',['面包']='面包没了奶酪:BAABKgAFFH8KAAMRAAcIqRi8EgBhAQARAAYIvBi8EgBhAQAPAAQIphKWDgAQAQAAAA==.面包的奶萨:BAACKgAFFH8JAAIWAAYIphCPCgCeAQAWAAYIphCPCgCeAQAqAAQKfyYAAxYACAhvG1okAPIBABYACAhvG1okAPIBAB8ABQi+B/BjAG0AAAAA.',['饭依']='饭依然特稀:BAABKgAFFH8HAAIKAAYIaBJrDQA3AQAKAAYIaBJrDQA3AQAAAA==.',['马走']='马走日:BAAAKgAECgEIAQAAAA==.',['黑桃']='黑桃:BAAAKgADCgQIBAAAAA==.',['黛开']='黛开水:BAABKgAFFH8HAAMgAAYIWBPnAgCTAQAgAAYIWBPnAgCTAQAhAAEIAABmDQAAAAABKgAFFAgIBgAgANgjAA==.',['黛梵']='黛梵妲:BAAAKgAECgEIAQAAAA==.',['黯淡']='黯淡的锋刃:BAAAKgAFFAIIAgAAAA==.',['鼠鼠']='鼠鼠猫猫狗鸡:BAAAKgAFFAQIBAAAAA==.',['凉开']='凉开水:BAAAKgAFFAYIBAABKgAFFAgIEgAGAJgVAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end