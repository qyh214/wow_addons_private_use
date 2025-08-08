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
 local lookup = {'Paladin-Protection','Evoker-Preservation','Evoker-Devastation','Mage-Fire','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Druid-Restoration','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Shaman-Restoration','Shaman-Elemental','DemonHunter-Vengeance','DemonHunter-Havoc','DeathKnight-Unholy','Paladin-Retribution','Monk-Mistweaver','Priest-Discipline','DeathKnight-Frost','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Warrior-Fury','Mage-Arcane','Mage-Frost','Monk-Brewmaster','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Monk-Windwalker','Unknown-Unknown','Warrior-Arms','Warrior-Protection','Paladin-Holy',}; local provider = {region='CN',realm='激流之傲',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Anubis:BAABKgAFFH8GAAIBAAYIvxJXDgAZAQABAAYIvxJXDgAZAQAAAA==.',As='Asunal:BAABKgAFFH8GAAMCAAYIiRE5BgCqAAACAAQI2hA5BgCqAAADAAII9AoWFQCmAAAAAA==.',Au='Aurielr:BAAAKgADCggIDwAAAA==.',Ba='Barrett:BAAAKgADCggICAAAAA==.',Cc='Cc:BAAAKgAECgUIBQAAAA==.',Da='Dawnhearth:BAAAKgAECggIEQAAAA==.',De='Demononback:BAAAKgAECgIIAgAAAA==.Dennism:BAAAKgAECgcIDQAAAA==.Despairer:BAAAKgAECgEIAQAAAA==.',El='Elohar:BAABKgAFFH8GAAIEAAYIDghnEgAtAQAEAAYIDghnEgAtAQAAAA==.',Er='Eroslon:BAABKgAFFH8FAAIFAAUIpBuUDQA+AQAFAAUIpBuUDQA+AQABKgAFFAgICAAFAL0eAA==.',Fl='Flicker:BAABKgAFFH8IAAMGAAgIpAb6DwC2AAAGAAYIPAH6DwC2AAAHAAIIqQDeIAAtAAAAAA==.',Fs='Fsycbombom:BAABKgAFFH8IAAIIAAgIzgnXCQBqAQAIAAgIzgnXCQBqAQAAAA==.',Jo='Joséphine:BAAAKgAECggIDAAAAA==.',Ko='Komorebi:BAABKgAFFH8EAAQJAAQImB0qKADPAAAJAAIIYSMqKADPAAAKAAEIBxIeIgBEAAALAAEIAACCNAAAAAAAAA==.',Kx='Kxin:BAAAKgAFFAgIAgAAAA==.',Li='Lisa:BAAAKgAFFAYIBAAAAA==.',Ma='Maste:BAAAKgAECgYIBgAAAA==.Maymay:BAAAKgAECgYIBgAAAA==.',Mc='Mcjackson:BAAAKgAFFAYIBAAAAA==.',Mo='Mo:BAABKgAFFH8GAAMMAAYIBgSVOACfAAAMAAQIBwOVOACfAAANAAIIOA8pJQBRAAAAAA==.Momota:BAAAKgAFFAQIBAAAAA==.',Ne='Newwhg:BAABKgAFFH8HAAIDAAQIoxfaIgC1AAADAAQIoxfaIgC1AAAAAA==.',Oc='October:BAABKgAFFH8IAAMOAAYIdxxdBABzAQAOAAYIsRldBABzAQAPAAIIexUyOgCWAAAAAA==.',Qw='Qwq:BAAAKgAECgYICwAAAA==.',Sk='Skymimi:BAABKgAFFH8GAAIFAAYIPyYtBAAUAgAFAAYIPyYtBAAUAgABKgAFFAgIGgAQAEwhAA==.Skytx:BAAAKgADCggICAAAAA==.',Sn='Snowmonster:BAAAKgADCggIDgAAAA==.',St='Starboy:BAABKgAFFH8IAAIQAAgI/hVFAgDIAQAQAAgI/hVFAgDIAQAAAA==.',Te='Tenderness:BAAAKgAECgUIBwAAAA==.',Th='Theleoric:BAAAKgAFFAQIBAAAAA==.',Un='Unaq:BAABKgAFFH8MAAMBAAYIRBbDDgATAQABAAYIRBbDDgATAQARAAEIAAC8YgAAAAAAAA==.',Vi='Vivitkara:BAABKgAFFH8IAAIRAAgItgYGEACgAQARAAgItgYGEACgAQAAAA==.',Wa='Wawoka:BAAAKgAECgQIBAAAAA==.',Xc='Xcao:BAAAKgAFFAgIBAAAAA==.',Yz='Yzhndk:BAABKgAFFH8KAAIFAAYIcQ8UBQBAAQAFAAYIcQ8UBQBAAQABKgAFFAgIQgABAGsmAA==.Yzhnqs:BAACKgAFFH9CAAIBAAgIayZoAAAxAgABAAgIayZoAAAxAgAqAAQKfxkAAgEACAhQJcsEAL0CAAEACAhQJcsEAL0CAAAA.',Zz='Zzdh:BAAAKgAECggICQAAAA==.',['一个']='一个林青霞:BAAAKgADCggICAAAAA==.',['一俺']='一俺不中叻一:BAAAKgAFFAIIAgAAAA==.',['一刘']='一刘小臭一:BAAAKgAFFAIIBAAAAA==.',['一懵']='一懵一:BAAAKgAECgUIBQAAAA==.',['一渡']='一渡魂灵人:BAAAKgADCgYIBgAAAA==.',['七夜']='七夜倾情:BAAAKgADCgUIBQAAAA==.',['七政']='七政:BAAAKgAFFAQIBAAAAA==.',['七浠']='七浠瓜籽:BAABKgAFFH8IAAMOAAQIqh+VBAD3AAAOAAQItRuVBAD3AAAPAAQIMRxnKQDRAAAAAA==.',['三沐']='三沐狮子王:BAAAKgAFFAQIAwAAAA==.',['不堪']='不堪重妇:BAAAKgAECgYIDAAAAA==.',['专业']='专业风骚:BAAAKgADCgQIBAAAAA==.',['丛林']='丛林小奶瓶:BAABKgAFFH8GAAIIAAYIaQrBEgAJAQAIAAYIaQrBEgAJAQAAAA==.',['丟了']='丟了快樂的潴:BAAAKgADCgEIAQAAAA==.',['丨聖']='丨聖光丶爹丨:BAAAKgADCggICAAAAA==.',['中年']='中年油腻大叔:BAAAKgAECgcIDAAAAA==.',['丶伊']='丶伊内斯:BAAAKgAECggICwAAAA==.',['丹丹']='丹丹:BAAAKgAECgEIAQAAAA==.',['乖乖']='乖乖坏脾气:BAAAKgAECgMIAwAAAA==.乖乖小熊猫:BAAAKgAECgQIBAAAAA==.',['乖喵']='乖喵喵乖:BAABKgAFFH8GAAISAAYIeQj8EwAIAQASAAYIeQj8EwAIAQAAAA==.',['九九']='九九归壹:BAABKgAFFH8JAAMTAAUIWhx5DgAzAQATAAUIWhx5DgAzAQAGAAEIswnWJQBIAAAAAA==.',['九月']='九月流萤:BAAAKgAECggICAAAAA==.',['乾丶']='乾丶:BAAAKgADCggICAAAAA==.',['二十']='二十七杯酒:BAAAKgAECgEIAQAAAA==.',['二弟']='二弟关云长:BAACKgAFFH8JAAMRAAYILQn/MQCnAAABAAYIKAQHGQCvAAARAAMIdBT/MQCnAAAqAAQKfxQAAhEACAiYJBEaALACABEACAiYJBEaALACAAAA.',['二懵']='二懵二:BAAAKgAFFAEIAQAAAA==.',['二领']='二领主:BAAAKgADCgMIAwAAAA==.',['五天']='五天十二夜:BAAAKgADCgYIBgAAAA==.',['京都']='京都丨念慈庵:BAAAKgAECggICAAAAA==.',['亵渎']='亵渎者小周:BAABKgAFFH8JAAQFAAQIbRKJHwCoAAAFAAQI/A6JHwCoAAAUAAEI0hJxEgBJAAAQAAIIfRTqIQA9AAAAAA==.',['人工']='人工智能一号:BAAAKgAFFAcIAwABKgAFFAgIFAABAEMfAA==.',['伊利']='伊利琼斯:BAAAKgADCgEIAgAAAA==.',['伐竹']='伐竹取道:BAABKgAECn8fAAQQAAgIVBvsKwAGAgAQAAgIuhrsKwAGAgAUAAgIABZxEACfAQAFAAcI1RSeIgB2AQAAAA==.',['优势']='优势在我:BAAAKgAECgYICQAAAA==.',['优质']='优质丷果冻:BAABKgAFFH8GAAIIAAYIqR76BgCkAQAIAAYIqR76BgCkAQAAAA==.',['传奇']='传奇耐砍王:BAABKgAFFH8MAAIRAAgIpR4/BACXAgARAAgIpR4/BACXAgAAAA==.',['伽言']='伽言:BAAAKgADCggIOgABKgAFFAMIBgAMAH0UAA==.',['佑佑']='佑佑不听话:BAAAKgADCgMIAwAAAA==.',['何弃']='何弃疗:BAAAKgAFFAYIBAAAAA==.',['佛寻']='佛寻欢:BAAAKgADCggIDQAAAA==.',['你哥']='你哥临死前:BAAAKgAECgYIBgAAAA==.',['你的']='你的盐我的醋:BAABKgAFFH8GAAIVAAYI5g65GgBEAQAVAAYI5g65GgBEAQABKgAFFAgIEAAWAGEaAA==.',['便便']='便便超人丶:BAAAKgAECggIBgAAAA==.',['倔强']='倔强的阿昆达:BAAAKgAFFAgIBAAAAA==.',['假的']='假的聖騎士:BAAAKgAECgUIBQABKgAECggIFQAQALcdAA==.',['元子']='元子:BAACKgAFFH8MAAMWAAMIqhocKwDZAAAWAAMIqhocKwDZAAAXAAII5hP3HQB/AAAqAAQKfywABBcACAieI50PAH4CABcACAgHH50PAH4CABYACAg6IS8ZAGoCABgAAQg7FbYfACkAAAEqAAUUCAgtABYAwx4A.',['兇兇']='兇兇乄彤彤:BAAAKgAECgQIBAAAAA==.兇兇的奶嘴:BAABKgAECn8VAAMMAAgIfhYgSQBlAQAMAAgIfhYgSQBlAQANAAEIAAADhwAAAAAAAA==.',['光影']='光影不離:BAAAKgAECggICAAAAA==.',['光暗']='光暗魔法使:BAAAKgADCgQIBAAAAA==.',['光铸']='光铸哥:BAAAKgADCggIEgAAAA==.',['兔你']='兔你一嘴:BAABKgAFFH8WAAIWAAYIQh96BQB1AQAWAAYIQh96BQB1AQABKgAFFAgIEAAWAGEaAA==.',['兔宝']='兔宝儿:BAABKgAFFH8KAAIZAAYI4xRlCQCoAQAZAAYI4xRlCQCoAQABKgAFFAgIQgABAGsmAA==.',['兜兜']='兜兜丢了糖:BAAAKgAECgIIAgAAAA==.',['六六']='六六村拉比克:BAAAKgAECgUIBQAAAA==.',['六磊']='六磊:BAAAKgAFFAIIAwAAAA==.',['兵丁']='兵丁甲:BAAAKgAECgcICAAAAA==.',['内拉']='内拉祖里:BAAAKgAECgEIAQAAAA==.',['冒险']='冒险者小周:BAAAKgAECgIIAgAAAA==.',['冷风']='冷风吹啊吹:BAAAKgAECgYIBgAAAA==.',['冷飲']='冷飲:BAACKgAFFH8WAAQaAAQIyiKSHwDsAAAaAAQIyiKSHwDsAAAEAAQIGxELHwDZAAAbAAMIhhVHFADFAAAqAAQKfzoAAhsACAg5IGUPAFICABsACAg5IGUPAFICAAAA.',['出家']='出家失败:BAAAKgAECgIIAgAAAA==.',['剩枪']='剩枪游侠尾巴:BAABKgAFFH8LAAMWAAYINBy4EQBqAQAWAAYINBy4EQBqAQAXAAII+gZESQBbAAABKgAFFAgIEAAWAGEaAA==.',['劳动']='劳动路一姐:BAABKgAFFH8GAAIRAAUIVhNLNAAYAQARAAUIVhNLNAAYAQAAAA==.',['勇太']='勇太:BAABKgAFFH8FAAIUAAUI1gc2BQArAQAUAAUI1gc2BQArAQAAAA==.',['包爆']='包爆的丶:BAAAKgADCgcIBwAAAA==.',['十一']='十一月的小德:BAAAKgAFFAYIAgAAAA==.十一月的萧邦:BAABKgAFFH8GAAIRAAYIYyBkHACCAQARAAYIYyBkHACCAQAAAA==.',['十破']='十破天:BAABKgAFFH8GAAIRAAYIDRpVIgBjAQARAAYIDRpVIgBjAQAAAA==.',['千反']='千反田琉璃:BAAAKgAECggICAAAAA==.',['午夜']='午夜前十分钟:BAAAKgAECgYICgAAAA==.',['半糖']='半糖:BAABKgAECn8VAAIRAAgIwxtrPQA3AgARAAgIwxtrPQA3AgAAAA==.',['卡扎']='卡扎库杉:BAABKgAFFH8GAAMJAAYIKhobHAAlAQAJAAQIAx0bHAAlAQALAAIIxg5/KQBHAAAAAA==.',['厉害']='厉害了我滴哥:BAABKgAFFH8PAAMSAAYIdBCBBABzAQASAAYIdBCBBABzAQAcAAIIHwdwCABZAAAAAA==.',['双手']='双手撸棍:BAAAKgADCgIIAgAAAA==.',['反手']='反手掏大铞:BAAAKgADCgYIBgAAAA==.',['叵世']='叵世奶温:BAAAKgADCggIBAAAAA==.',['叶青']='叶青云:BAAAKgAFFAgIBAAAAA==.',['叽叽']='叽叽棒:BAAAKgAFFAIIAgAAAA==.',['咸鱼']='咸鱼突刺专员:BAABKgAFFH8IAAIWAAQIrh0OEQAIAQAWAAQIrh0OEQAIAQAAAA==.',['哀伤']='哀伤的秋天:BAAAKgAECggIDgAAAA==.',['哈莉']='哈莉貝瑞:BAAAKgADCgYIBgAAAA==.',['喜多']='喜多郁代:BAAAKgAECgQIAQAAAA==.',['喵天']='喵天喵地:BAABKgAFFH8aAAMVAAYIAh7NDwCkAQAVAAYIAh7NDwCkAQAIAAYIohPHAQCaAQABKgAFFAgIQgABAGsmAA==.',['嗜血']='嗜血红蔷薇:BAAAKgAFFAQIBAAAAQ==.',['嗷唛']='嗷唛嘎德:BAAAKgADCgMIAwAAAA==.',['回家']='回家吃肉:BAAAKgADCgQIBAAAAA==.',['圈圈']='圈圈大元宝:BAABKgAFFH8GAAIaAAYI0ByLDQBpAQAaAAYI0ByLDQBpAQABKgAFFAgIBgAaALAdAA==.',['圣光']='圣光:BAAAKgAECgcICwAAAA==.圣光余烬:BAAAKgAECgEIAQAAAA==.圣光忽悠我:BAAAKgAECgUIBQAAAA==.',['圣耀']='圣耀星辉:BAAAKgAECgYIDAAAAA==.',['地狱']='地狱狂猪佩奇:BAABKgAFFH8IAAIQAAQIuCNsDAAKAQAQAAQIuCNsDAAKAQAAAA==.',['地蕾']='地蕾我最爱:BAAAKgAECggIDgAAAA==.',['坏孩']='坏孩:BAABKgAFFH8aAAIRAAQI3A2pKwC4AAARAAQI3A2pKwC4AAAAAA==.',['埃斯']='埃斯蒂尼安:BAABKgAFFH8PAAIBAAMI6xrHEgDmAAABAAMI6xrHEgDmAAAAAA==.',['塡下']='塡下忧樂:BAAAKgAECgcIDgAAAA==.',['墨尘']='墨尘:BAAAKgADCggICAAAAA==.',['壹支']='壹支毒秀:BAAAKgADCggIEAAAAA==.',['壹言']='壹言不合:BAAAKgAECggIAgAAAA==.',['多乐']='多乐是只渐层:BAABKgAFFH8VAAIRAAgI9h8KBgBrAgARAAgI9h8KBgBrAgAAAA==.',['多肉']='多肉葡萄冻:BAAAKgAFFAYIAgAAAA==.',['夜裳']='夜裳浓妆:BAABKgAFFH8GAAIBAAYIEBbkCgBLAQABAAYIEBbkCgBLAQAAAA==.',['大吉']='大吉吉萌妹:BAAAKgAECgIIAgAAAA==.',['大漂']='大漂亮:BAAAKgAFFAQIBAAAAA==.',['大白']='大白兔:BAAAKgAECggIEAAAAA==.',['大神']='大神带你们:BAABKgAFFH8MAAIdAAMI8RX2BAC6AAAdAAMI8RX2BAC6AAAAAA==.',['大锤']='大锤来了:BAAAKgAECggIDAAAAA==.',['大黑']='大黑妞妞丶:BAAAKgADCggICAAAAA==.',['天使']='天使之梦:BAAAKgAECgYIBgAAAA==.',['天天']='天天六三零:BAAAKgAECgYICgAAAA==.天天吃饱等死:BAAAKgAFFAYIBAAAAA==.',['天镶']='天镶劫火:BAAAKgAECgEIAQAAAA==.',['奥丹']='奥丹尼:BAAAKgADCggICAAAAA==.',['奶少']='奶少:BAAAKgAECgQIBAAAAA==.',['好人']='好人喵:BAAAKgADCggIDwAAAA==.',['妳在']='妳在教我做事:BAAAKgAFFAMIAwABKgAFFAgIBgAKAGobAA==.',['姗你']='姗你几嘴巴:BAAAKgAECgUIBQAAAA==.',['姬无']='姬无命:BAABKgAFFH8OAAMbAAgIkBmtAQBQAgAbAAgIkBmtAQBQAgAaAAIIlg1YMQCeAAAAAA==.',['子午']='子午丑:BAAAKgAECgQIBAAAAA==.',['安加']='安加萨之殇:BAAAKgAFFAMIAwAAAA==.',['宗师']='宗师小周:BAAAKgAFFAIIAgAAAA==.',['寒塘']='寒塘鹤影:BAAAKgADCgMIAQAAAA==.',['寒月']='寒月丿:BAABKgAFFH8GAAIHAAMIYBDhJwCiAAAHAAMIYBDhJwCiAAAAAA==.',['小七']='小七:BAACKgAFFH8FAAIQAAQInghMGQCcAAAQAAQInghMGQCcAAAqAAQKfygAAxAACAh0FblQAHcBABAACAh0FblQAHcBAAUACAiFCZ0rAO8AAAAA.',['小南']='小南:BAAAKgAECgIIAQAAAA==.',['小周']='小周爱玩奥法:BAAAKgAECgYICAAAAA==.',['小妖']='小妖:BAABKgAECn83AAQeAAgIOSDPAgCaAgAeAAgIOSDPAgCaAgAdAAgIwAaqGQBjAQAfAAYIfQ8yEAD+AAAAAA==.',['小小']='小小花花尝:BAAAKgAFFAQIAwAAAA==.',['小护']='小护士丶:BAAAKgAFFAgIAgAAAA==.',['小楼']='小楼又南风丶:BAAAKgAECgUIBgAAAA==.',['小漠']='小漠:BAABKgAFFH8GAAMSAAMIrhbdIgB8AAASAAIIfxPdIgB8AAAgAAEIXwRdIAA7AAAAAA==.',['小火']='小火车:BAAAKgAFFAQIBAAAAA==.',['小烦']='小烦烦:BAAAKgAFFAYIBAAAAA==.',['小煤']='小煤球快跑:BAABKgAFFH8GAAINAAYIag9JBwBSAQANAAYIag9JBwBSAQAAAA==.',['小牛']='小牛小白白:BAABKgAFFH8FAAIZAAMIvQtLIwDFAAAZAAMIvQtLIwDFAAAAAA==.',['小红']='小红手开心:BAABKgAFFH8KAAIWAAgITxVgDACpAQAWAAgITxVgDACpAQAAAA==.',['小芙']='小芙遥:BAACKgAFFH8FAAMTAAQIsQlIHgCEAAATAAMIhAxIHgCEAAAGAAEIxAPXKABAAAAqAAQKfxoAAxMACAhaFFAiALkBABMACAgPFFAiALkBAAcABghxCvtdAMcAAAAA.',['小葵']='小葵:BAABKgAFFH8IAAIRAAQIdCQrCAA8AQARAAQIdCQrCAA8AQABKgAFFAgIAgAhAAAAAA==.',['小蜜']='小蜜蜂:BAAAKgADCgYIBgAAAA==.',['小西']='小西:BAAAKgAFFAMIAwAAAA==.',['小酸']='小酸奶万事屋:BAAAKgAECgEIAQAAAA==.小酸奶守护者:BAAAKgAECgQIBAAAAA==.',['小风']='小风行:BAAAKgAFFAQIBAAAAA==.',['小鬼']='小鬼不忙:BAABKgAFFH8IAAITAAgIhBKOAwDbAQATAAgIhBKOAwDbAQAAAA==.',['小龙']='小龙吊:BAABKgAECn8XAAIDAAYIUA3JQgDTAAADAAYIUA3JQgDTAAABKgAFFAgIJQAZABMTAA==.',['少年']='少年拉满弓:BAAAKgADCgYIBgAAAA==.',['尕亱']='尕亱魅影:BAAAKgAECgQIBAAAAA==.',['尼尼']='尼尼:BAAAKgAFFAQIBAAAAA==.',['岁岁']='岁岁:BAAAKgADCgQIBAAAAA==.',['崽灬']='崽灬:BAABKgAECn8XAAIIAAgI4xV1GwDBAQAIAAgI4xV1GwDBAQAAAA==.',['巫小']='巫小乖:BAABKgAFFH8WAAQHAAgIAREDCwByAQAHAAcI2hADCwByAQAGAAYI7xAkBQBuAQATAAIIohD1IACfAAAAAA==.',['布丁']='布丁大魔王:BAABKgAFFH8IAAIMAAgIYQiiCQCrAQAMAAgIYQiiCQCrAQAAAA==.布丁酱:BAABKgAFFH8FAAIJAAQIRxtNDgDxAAAJAAQIRxtNDgDxAAABKgAFFAgIEAALAOAZAA==.',['师佛']='师佛號痛:BAAAKgAECgYIEwAAAA==.',['师影']='师影丶:BAAAKgADCgQIBAAAAA==.',['希尔']='希尔灬瓦娜斯:BAAAKgAFFAQIAgAAAA==.',['幻神']='幻神泡泡:BAABKgAFFH8IAAIDAAgI5xLZCADsAQADAAgI5xLZCADsAQAAAA==.',['幽殇']='幽殇:BAAAKgADCgMIAwAAAA==.',['庐山']='庐山百龙霸:BAAAKgADCgYIBgAAAA==.',['库洛']='库洛洛鲁西鲁:BAACKgAFFH8gAAQfAAYI2h6DAQAKAQAeAAYIMQ+KDQB2AQAfAAYI2h6DAQAKAQAdAAEIjBaSEABLAAAqAAQKfyMABB8ACAi7IkkDAHMCAB8ACAi8HUkDAHMCAB0ACAgjHagIAGACAB4ABgh7HAwbAKwBAAAA.',['庭前']='庭前柏子香:BAABKgAFFH8OAAMSAAYI1Bj1DABVAQASAAYI1Bj1DABVAQAcAAYIsQxOBAD2AAAAAA==.',['廿一']='廿一是只虎斑:BAAAKgAECggIBwAAAA==.',['开心']='开心小宝贝:BAABKgAFFH8RAAMQAAYI9B4vDADMAQAQAAYI9B4vDADMAQAFAAYIAQ6aCAANAQAAAA==.',['弓灵']='弓灵:BAAAKgADCggICAAAAA==.',['张小']='张小花邻居:BAAAKgAECgYIBgAAAA==.',['张根']='张根硕:BAABKgAFFH8FAAMZAAUICQ4rEgA3AQAZAAQIAhArEgA3AQAiAAEIJwa2GgBHAAAAAA==.',['弯弓']='弯弓似月牙:BAAAKgAECgMIBgAAAA==.',['归来']='归来去兮:BAAAKgAECggICAAAAA==.',['心跳']='心跳記憶:BAAAKgADCggICAAAAA==.',['怀特']='怀特迈恩丶:BAAAKgAECggICAAAAA==.',['恐龙']='恐龙抗狼抗浪:BAAAKgAECgUICAAAAA==.',['悠悠']='悠悠邪神:BAAAKgADCgMIAwAAAA==.',['情之']='情之亦心往:BAAAKgAFFAgIBAAAAA==.',['愤怒']='愤怒的小鸟:BAAAKgAECgUIBQAAAA==.',['我有']='我有牛奶:BAAAKgAECgcIDgAAAA==.',['战团']='战团冠军:BAAAKgADCgIIAgAAAA==.',['手冲']='手冲熊豪:BAAAKgAFFAMIAwAAAA==.',['拔剑']='拔剑向东去:BAAAKgAECgYICAAAAA==.',['拔箭']='拔箭四顾:BAABKgAFFH8QAAMWAAgIYRpPAgDFAQAWAAgIiBVPAgDFAQAXAAIILCKlEADWAAAAAA==.',['拳王']='拳王:BAAAKgAECggICAAAAA==.',['接著']='接著樂接着舞:BAAAKgADCgIIAgAAAA==.',['掼蛋']='掼蛋大师:BAABKgAFFH8KAAMCAAYIgxgHBADVAAACAAQIaREHBADVAAADAAUIRh7VEwCzAAABKgAFFAgIDQAXANEcAA==.',['揽月']='揽月细丶:BAAAKgAECgQIBAAAAA==.',['敲里']='敲里哇丶:BAAAKgADCgYIBgAAAA==.',['斌宝']='斌宝:BAAAKgAFFAQIBAAAAA==.',['斜月']='斜月垂光丶:BAABKgAFFH8UAAMiAAYIySFcAAAIAgAiAAYIGiFcAAAIAgAZAAQIyxkrHwDYAAABKgAFFAgICAAZAHYKAA==.',['斯洛']='斯洛特:BAAAKgADCgcICgAAAA==.',['施巴']='施巴拉古大师:BAABKgAFFH8OAAIMAAYIaBs6BwAfAQAMAAYIaBs6BwAfAQAAAA==.',['无所']='无所畏惧先生:BAAAKgAECgUIBgAAAA==.',['无聊']='无聊玩玩一号:BAABKgAECn89AAIXAAgIhxw2CQBFAgAXAAgIhxw2CQBFAgABKgAFFAgICAAWAHkgAA==.',['早餐']='早餐店劫匪:BAAAKgADCgMIAwAAAA==.',['星辰']='星辰:BAABKgAFFH8IAAIRAAgINQfVFQCtAQARAAgINQfVFQCtAQAAAA==.星辰丶:BAABKgAFFH8RAAMEAAcIjBpzDgBXAQAEAAYIXBlzDgBXAQAaAAMINhJXIADnAAAAAA==.',['映梅']='映梅来了:BAABKgAECn8VAAMIAAgIkhqLEwAHAgAIAAgIkhqLEwAHAgAVAAgICxIYSQCIAQAAAA==.',['是我']='是我惹不起:BAAAKgAECgYIBgAAAA==.',['晓封']='晓封:BAAAKgAFFAQIAgABKgAFFAgICAAMALsbAA==.',['暗影']='暗影夜归人:BAAAKgADCgMIAwAAAA==.暗影狩猎:BAAAKgAECgMIAwAAAA==.暗影追猎:BAAAKgADCgYIBgAAAA==.',['暗香']='暗香残留:BAAAKgAECgIIAgAAAA==.',['暗鸦']='暗鸦:BAAAKgAECgYIEAAAAA==.',['暴躁']='暴躁丶小静静:BAAAKgAFFAIIAgAAAA==.',['最终']='最终之战:BAAAKgAFFAIIAgAAAA==.',['月宝']='月宝儿:BAABKgAFFH8KAAIMAAYIeRQYDQAnAQAMAAYIeRQYDQAnAQAAAA==.',['月柒']='月柒妖梦:BAAAKgAECgEIAQAAAA==.',['李狗']='李狗蛋超级凶:BAACKgAFFH8KAAIQAAIIvCGnOwCuAAAQAAIIvCGnOwCuAAAqAAQKfykAAxQACAjiIoMFAHwCABQACAi5HoMFAHwCABAACAihIsUjAC4CAAAA.',['杨小']='杨小婲:BAABKgAECn8aAAMRAAgIXhvxEgA4AgARAAgIRxvxEgA4AgABAAgIwBGfHAB2AQAAAA==.',['枫叶']='枫叶下的猫:BAAAKgAECgIIAwAAAA==.枫叶下的白毛:BAAAKgAECgQIBAAAAA==.枫叶下的鱼:BAAAKgAECgYICgAAAA==.',['柯丶']='柯丶丶:BAAAKgADCggICAAAAA==.',['梅代']='梅代刀:BAAAKgAECgEIAQAAAA==.',['槑乄']='槑乄冷兮:BAAAKgAECgYIDgAAAA==.',['橙赤']='橙赤赤:BAAAKgADCggICAABKgAFFAgICAARAC8jAA==.',['欻霊']='欻霊:BAAAKgAECgMIBQAAAA==.',['正面']='正面男孩:BAAAKgAECgUIBQAAAA==.',['母草']='母草:BAAAKgAFFAgIBAAAAA==.',['毒龙']='毒龙:BAAAKgADCggICAAAAA==.',['毛腿']='毛腿菊花芯:BAAAKgAECgIIAgAAAA==.',['气的']='气的隆冬强:BAAAKgADCggICAAAAA==.',['氵崽']='氵崽灬:BAAAKgAECgQIBAAAAA==.',['永恒']='永恒之钕:BAAAKgAFFAgIBAAAAA==.永恒之钽:BAAAKgAFFAQIBAAAAA==.永恒之钿:BAAAKgAFFAQIBAABKgAFFAYIIQAGAIoQAA==.永恒之银:BAAAKgAFFAQIBAAAAA==.永恒之镅:BAAAKgAFFAUIBAABKgAFFAgIKwAZAC4VAA==.永恒之镓:BAABKgAFFH8JAAIDAAUIsRBDGQD5AAADAAUIsRBDGQD5AAABKgAFFAYIIQAGAIoQAA==.',['求求']='求求你别说了:BAAAKgAECgMIAwAAAA==.',['沉默']='沉默的真相:BAAAKgAECggICAAAAA==.',['没有']='没有恋爱天赋:BAAAKgADCgQIBAAAAA==.',['法号']='法号慕尸:BAABKgAFFH8GAAIHAAYITwnKEwAVAQAHAAYITwnKEwAVAQAAAA==.',['法魂']='法魂魔神:BAABKgAFFH8MAAIaAAYIbRS1EgBQAQAaAAYIbRS1EgBQAQAAAA==.',['泰式']='泰式打抛饭:BAAAKgAFFAgIAgAAAA==.',['泽成']='泽成美雪:BAAAKgAECggIDgAAAA==.',['洛其']='洛其飞:BAAAKgAECgQIBAAAAA==.',['浅草']='浅草日光:BAABKgAECn8VAAITAAgI7xhFGQD5AQATAAgI7xhFGQD5AQAAAA==.',['浴帝']='浴帝哥哥:BAAAKgAFFAQIBAAAAA==.',['海上']='海上升明月:BAAAKgADCggICAAAAA==.',['清歌']='清歌扶酒:BAAAKgAFFAIIAgAAAA==.',['渡海']='渡海的浮囊:BAAAKgAECggIEAAAAA==.渡海的萨满:BAAAKgAECgUIBQABKgAECggIEAAhAAAAAA==.',['漠御']='漠御师:BAABKgAFFH8FAAISAAII+RBnIACGAAASAAII+RBnIACGAAAAAA==.',['漠然']='漠然然:BAAAKgAFFAQIBAAAAA==.',['潇湘']='潇湘雨嫣:BAABKgAFFH8LAAIiAAgILApRBQDbAQAiAAgILApRBQDbAQAAAA==.',['火星']='火星味锅巴:BAAAKgAECgEIAQAAAA==.',['火玫']='火玫瑰:BAAAKgADCgMIAwAAAA==.',['灬晴']='灬晴天灬:BAACKgAFFH8EAAISAAQIvSKEEgAVAQASAAQIvSKEEgAVAQAqAAQKfxcAAyAACAgWC3M9AB0BACAACAgWC3M9AB0BABIABghGBalRAHYAAAAA.',['灰色']='灰色天堂:BAABKgAFFH8GAAIWAAYIQAvDBQBuAQAWAAYIQAvDBQBuAQABKgAFFAgICwAQADsUAA==.',['烟嗓']='烟嗓喵喵:BAAAKgAECggICAAAAA==.',['熊爸']='熊爸天下:BAABKgAFFH8GAAIVAAYIQQXlKADvAAAVAAYIQQXlKADvAAAAAA==.',['熊里']='熊里安乌瑞恩:BAAAKgAECgMIBwAAAA==.',['爱不']='爱不过时光:BAAAKgAECgUIBAAAAA==.',['牙齿']='牙齿也迷人:BAABKgAFFH8YAAMMAAgIHhg7AwBEAgAMAAgIHhg7AwBEAgANAAIIdxXzHQCJAAAAAA==.',['牛中']='牛中之牛:BAABKgAFFH8OAAMXAAYIxhuBCQDAAQAXAAYIxhuBCQDAAQAWAAQIPRVGNQC+AAAAAA==.',['牛牛']='牛牛玩狂野:BAAAKgAFFAQIBAAAAA==.',['牢哀']='牢哀牧山者:BAABKgAFFH8GAAIRAAQItg2oKQDLAAARAAQItg2oKQDLAAAAAA==.',['特洛']='特洛伊德:BAAAKgAECgYICgAAAA==.',['狗奶']='狗奶:BAAAKgADCgMIAwAAAA==.',['狗蛋']='狗蛋儿:BAAAKgAFFAQIBAAAAA==.',['猪肉']='猪肉蜜饯:BAABKgAFFH8GAAMGAAQIVQsrFQC6AAAGAAQIVQsrFQC6AAAHAAIIywFyPQBGAAAAAA==.',['猫咖']='猫咖啡:BAABKgAECn8YAAISAAgIFxHROABkAQASAAgIFxHROABkAQAAAA==.',['獠刹']='獠刹:BAAAKgAFFAUIAQAAAA==.',['玖五']='玖五二七:BAAAKgADCgIIAgAAAA==.',['玛力']='玛力亚:BAAAKgADCggICAAAAA==.',['玛德']='玛德:BAABKgAFFH8NAAIIAAMIwyC4BQAfAQAIAAMIwyC4BQAfAQAAAA==.',['玛雅']='玛雅达婕妮:BAAAKgAECggIDwAAAA==.',['玫瑰']='玫瑰:BAAAKgAECgcIDwAAAA==.',['玻璃']='玻璃门:BAABKgAFFH8KAAIRAAYIphjAEACUAQARAAYIphjAEACUAQAAAA==.',['瑶光']='瑶光:BAAAKgAECgcIEQAAAA==.',['生前']='生前是圣骑:BAACKgAFFH8XAAIQAAQIfxW+LgDVAAAQAAQIfxW+LgDVAAAqAAQKfx8AAhAACAjuIIwfAEUCABAACAjuIIwfAEUCAAAA.',['甩牛']='甩牛尾巴:BAAAKgAECgQIBAAAAA==.',['留頭']='留頭人法師:BAABKgAFFH8IAAMiAAYITR1NBwCcAQAiAAYITR1NBwCcAQAjAAIIghORBgCmAAAAAA==.',['白葡']='白葡萄汽水:BAAAKgAFFAIIAgAAAA==.',['皓月']='皓月苍穹:BAABKgAFFH8GAAMXAAQIMxE5EgDNAAAXAAQI/A45EgDNAAAWAAIIsxEvNwCJAAABKgAFFAgIEwAWAOUdAA==.',['盗火']='盗火贤者:BAAAKgADCgQIBAAAAA==.',['盲人']='盲人灬按摩:BAAAKgAECgMIAwAAAA==.',['相见']='相见不如怀念:BAAAKgAECgYIBgAAAA==.',['石盖']='石盖坞皮卡丘:BAABKgAFFH8FAAISAAUIhBO+EgATAQASAAUIhBO+EgATAQAAAA==.',['砚寒']='砚寒清:BAABKgAFFH8IAAIRAAMI0hh3IgDjAAARAAMI0hh3IgDjAAAAAA==.',['磁爆']='磁爆步兵:BAAAKgAECgIIAgAAAA==.',['社会']='社会硬茬子:BAAAKgAECgUIBQAAAA==.',['神圣']='神圣星星:BAAAKgAECggICwAAAA==.',['神棍']='神棍一头:BAAAKgAECgYIBgAAAA==.',['祥子']='祥子:BAAAKgAECgcICgAAAA==.',['秋天']='秋天以北:BAAAKgADCggICAAAAA==.',['紫啧']='紫啧:BAAAKgAECgEIAQAAAA==.',['紫雨']='紫雨夕颜:BAAAKgAFFAQIBAAAAA==.',['红手']='红手:BAACKgAFFH8eAAMkAAUI0CKiAgAqAQAkAAUI0CKiAgAqAQARAAEIdgUPUQBGAAAqAAQKfyUAAyQACAinI3kDALgCACQACAinI3kDALgCAAEABAiGByZRAFEAAAAA.',['约定']='约定之王:BAAAKgADCgcIBwAAAA==.',['纯菜']='纯菜刀:BAAAKgAECgYICAAAAA==.',['绿茶']='绿茶:BAAAKgAECgYIBgAAAA==.',['老痰']='老痰喷射专员:BAABKgAFFH8FAAIDAAUIgBXSFwAIAQADAAUIgBXSFwAIAQAAAA==.',['聖光']='聖光曉刹:BAAAKgAECgQIBAAAAA==.',['肆夕']='肆夕:BAAAKgADCgIIAgAAAA==.',['胖唬']='胖唬:BAABKgAFFH8GAAIiAAYIFgh3DQA5AQAiAAYIFgh3DQA5AQAAAA==.',['胡恩']='胡恩:BAAAKgAFFAQIBAABKgAFFAgIAgAhAAAAAA==.',['胸中']='胸中有温柔:BAAAKgADCgIIAgAAAA==.',['舞炫']='舞炫神迷:BAABKgAFFH8KAAISAAYIkxITCgAyAQASAAYIkxITCgAyAQAAAA==.',['艾丶']='艾丶虂恩:BAABKgAFFH8GAAIVAAYI0BRnAwCUAQAVAAYI0BRnAwCUAQAAAA==.',['艾欧']='艾欧塔丶追猎:BAAAKgAECgIIAgAAAA==.',['艾米']='艾米莉娅:BAAAKgAECggIEwAAAA==.',['艾雅']='艾雅白掌:BAAAKgAECgQIBQAAAA==.',['芒果']='芒果哥斯拉:BAAAKgADCgEIAQAAAA==.',['芷菀']='芷菀:BAAAKgAECggIBgAAAA==.',['范海']='范海辛:BAABKgAFFH8GAAIXAAYIqBaWCgBvAQAXAAYIqBaWCgBvAQAAAA==.',['草莓']='草莓舒芙蕾:BAABKgAFFH8GAAISAAYIRA/oDwAvAQASAAYIRA/oDwAvAQAAAA==.',['莉莉']='莉莉娅娜:BAAAKgAFFAQIBAAAAA==.',['菊纹']='菊纹解锁:BAAAKgADCgQIBAAAAA==.',['萨内']='萨内蒂:BAAAKgAFFAgIBAAAAA==.',['萨姆']='萨姆罗的奶瓶:BAAAKgAECgEIAQAAAA==.',['萬籁']='萬籁皆静:BAAAKgAECggICAAAAA==.',['落花']='落花无痕:BAAAKgADCgIIAgAAAA==.',['葵花']='葵花点泬掱:BAAAKgADCgEIAQAAAA==.',['蛤蟆']='蛤蟆汉堡:BAABKgAFFH8IAAIWAAgIVhldBABrAgAWAAgIVhldBABrAgAAAA==.',['蝴蝶']='蝴蝶吻花香:BAABKgAECn8ZAAMGAAgIrBSVEQCAAQAGAAgIrBSVEQCAAQAHAAUI8wvMUgDHAAAAAA==.',['血之']='血之霜殇:BAAAKgAECgIIAgAAAA==.',['行天']='行天之道:BAAAKgADCgEIAQAAAA==.',['袖手']='袖手野色丶:BAAAKgAECgYIBgAAAA==.',['被开']='被开罚单:BAAAKgADCgMIAwAAAA==.',['西西']='西西:BAAAKgAECggICAAAAA==.',['西门']='西门嫖:BAAAKgADCgUIBQAAAA==.',['訫煩']='訫煩譩亂:BAAAKgADCgEIAQAAAA==.',['谭鱼']='谭鱼头:BAAAKgADCgIIAgAAAA==.',['赞达']='赞达尔丶碎魂:BAAAKgAECggICAAAAA==.',['路过']='路过幸福:BAAAKgAECggIEgAAAA==.',['软云']='软云:BAABKgAECn8jAAQcAAgI9RPMEAAyAQAcAAgI9Q7MEAAyAQAgAAYIVRWdRAD1AAASAAYIQgqgWgDRAAAAAA==.',['轰轰']='轰轰最爱:BAAAKgAECgcIBwAAAA==.',['辉丶']='辉丶辉:BAAAKgAFFAYIBAAAAA==.',['迅捷']='迅捷的法事:BAAAKgADCgUICQAAAA==.',['还能']='还能喝点:BAAAKgAFFAgIAwAAAA==.',['这不']='这不河里:BAAAKgAFFAYIBAAAAA==.',['迪克']='迪克杰西:BAABKgAFFH8GAAIIAAYI+wvlEAAYAQAIAAYI+wvlEAAYAQAAAA==.',['追法']='追法者:BAAAKgADCgMIAwAAAA==.',['逗逗']='逗逗元:BAAAKgAFFAgIAQABKgAFFAgIBQATALEJAA==.',['逝去']='逝去的仲夏丶:BAAAKgAFFAQIBAAAAA==.',['邻居']='邻居:BAAAKgAFFAQIBAAAAA==.',['部落']='部落的天使:BAABKgAFFH8GAAIBAAYIYR/qBwCRAQABAAYIYR/qBwCRAQAAAA==.',['酒鬼']='酒鬼喵喵:BAAAKgAFFAIIAgAAAA==.',['重庆']='重庆肥牛王:BAAAKgAECggIDQAAAA==.重庆阿春家:BAAAKgAECggIDQAAAA==.重庆香辣虾:BAAAKgAECgMIBQAAAA==.重庆黄辣丁:BAAAKgAECggIDAAAAA==.',['重锤']='重锤:BAABKgAFFH8eAAMZAAgIFBz9AQCuAQAiAAgILBvCAwAYAgAZAAYICRP9AQCuAQAAAA==.',['野性']='野性咕咕:BAAAKgADCggICAAAAA==.',['鉺釘']='鉺釘:BAAAKgADCgEIAQAAAA==.',['铁锁']='铁锁楝:BAAAKgADCgEIAQAAAA==.',['销魂']='销魂置死:BAAAKgAECggICAAAAA==.',['锁甲']='锁甲费:BAAAKgADCggIDwAAAA==.',['长椿']='长椿街幼儿园:BAAAKgAFFAYIBAAAAA==.',['问剑']='问剑:BAAAKgAECggICAAAAA==.',['阳叶']='阳叶:BAAAKgADCggICAAAAA==.',['阿桑']='阿桑啊:BAAAKgAECgIIAgAAAA==.',['阿浚']='阿浚:BAAAKgAECgYIDAAAAA==.',['阿滚']='阿滚:BAAAKgAFFAgIAQABKgAFFAgIBQATALEJAA==.',['阿蕾']='阿蕾克斯塔萨:BAABKgAFFH8KAAIEAAYIPREnBwCSAQAEAAYIPREnBwCSAQAAAA==.',['陈念']='陈念秀:BAAAKgAFFAgIAgAAAA==.',['陳纸']='陳纸岛:BAAAKgADCgMIAwAAAA==.',['隐秘']='隐秘的角落:BAAAKgAECggICQAAAA==.',['雷起']='雷起千峰雨:BAAAKgADCggICAAAAA==.',['霜誓']='霜誓:BAAAKgAECgUICQAAAA==.',['青叶']='青叶摩卡:BAABKgAFFH8FAAMfAAUIMAx8BgCsAAAfAAQIbwt8BgCsAAAeAAEIdA43KABPAAAAAA==.',['青春']='青春你太痘:BAABKgAFFH8MAAIeAAMIvxIHGADnAAAeAAMIvxIHGADnAAAAAA==.',['青涩']='青涩的茴忆:BAAAKgADCggICAAAAA==.',['顺丰']='顺丰速孕:BAAAKgAFFAgIBAAAAA==.',['风亦']='风亦悠扬:BAAAKgADCgQIBAAAAA==.',['风洛']='风洛邪丶:BAAAKgAFFAMIAwAAAA==.',['飛刀']='飛刀:BAACKgAFFH8QAAQTAAMIXBNcGgDAAAATAAMIXBNcGgDAAAAHAAIIbwRxOwBRAAAGAAIISAimJwBDAAAqAAQKfxYABAYACAj2DkglAF0BAAYACAj2DkglAF0BABMABwg6D8o6AC4BAAcAAggfFt99AD0AAAAA.',['飞云']='飞云:BAAAKgAECgYIAgAAAA==.',['飞翔']='飞翔的砖头:BAABKgAFFH8IAAIeAAgIKRY0BwAGAgAeAAgIKRY0BwAGAgAAAA==.',['馨囡']='馨囡囡:BAAAKgAECggIEAAAAA==.',['骑老']='骑老奶过马路:BAACKgAFFH8mAAMCAAQIWB01BADxAAACAAMIWB01BADxAAADAAQI6hJXIQC8AAAqAAQKfywAAwMACAipHDcbANwBAAMACAipHDcbANwBAAIACAj3FSkJAIABAAAA.',['高兄']='高兄:BAAAKgAFFAgIBAAAAA==.',['鬼小']='鬼小棋:BAAAKgADCggIDAAAAA==.',['鬼尐']='鬼尐圣:BAAAKgADCggICAAAAA==.',['鬼镰']='鬼镰:BAABKgAECn8YAAIeAAgIWg8LHACjAQAeAAgIWg8LHACjAQAAAA==.',['鲤鱼']='鲤鱼打挺:BAAAKgADCgQIBAAAAA==.',['鵲依']='鵲依变啼角:BAAAKgAECgQIBAAAAA==.',['鸡安']='鸡安娜:BAAAKgADCgcIBwAAAA==.',['黄块']='黄块块:BAACKgAFFH8HAAIWAAQIJhjIHADjAAAWAAQIJhjIHADjAAAqAAQKfxUAAxgABwjdHpcLAFwBABgABwglGZcLAFwBABYABghZIqaOABABAAAA.',['黄花']='黄花风铃木:BAAAKgADCgEIAQAAAA==.',['黑傻']='黑傻:BAAAKgADCggICAAAAA==.',['黑手']='黑手审判军:BAAAKgADCgYIBgAAAA==.',['黑脸']='黑脸骑士:BAABKgAFFH8GAAIRAAYIix4kPgD3AAARAAYIix4kPgD3AAAAAA==.',['黑锋']='黑锋:BAABKgAFFH8OAAMQAAMIOwzyNgC+AAAQAAMIOwzyNgC+AAAUAAII6gXKEABtAAAAAA==.',['龙迦']='龙迦尔:BAAAKgAECgEIAQAAAA==.',['龙门']='龙门飞甲:BAABKgAECn8UAAIMAAgIXRMvOgCNAQAMAAgIXRMvOgCNAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end