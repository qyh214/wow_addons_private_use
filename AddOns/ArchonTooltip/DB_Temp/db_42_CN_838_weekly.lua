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
 local lookup = {'Druid-Balance','Mage-Fire','Mage-Frost','Priest-Discipline','Priest-Shadow','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','Priest-Holy','Mage-Arcane','Warlock-Destruction','Warlock-Affliction','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Enhancement','Shaman-Restoration','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Holy','Paladin-Retribution','Evoker-Devastation','Paladin-Protection','Warlock-Demonology','DeathKnight-Frost','Monk-Brewmaster','Shaman-Elemental','Warrior-Protection',}; local provider = {region='CN',realm='达文格尔',name='CN',type='weekly',zone=42,date='2025-08-02',data={As='Assistance:BAAAKgAECggICAABKgAFFAgIIgABAPkdAA==.',Av='Avrillavign:BAAAKgAFFAQIBAAAAA==.',Be='Becky:BAAAKgADCgIIAgAAAA==.',Bi='Bigfly:BAAAKgADCgIIAgAAAA==.Biubiubiubiu:BAACKgAFFH8HAAICAAMINAwAMQCHAAACAAMINAwAMQCHAAAqAAQKfygAAwIACAjDHikfADkCAAIACAiRHCkfADkCAAMABQgpG5ZIAEMBAAAA.',Ch='Christie:BAACKgAFFH8XAAMEAAYIuRWwBABKAQAEAAUIjRKwBABKAQAFAAMISBvyFADUAAAqAAQKfyUAAgUACAiwH9wQAFwCAAUACAiwH9wQAFwCAAEqAAUUCAgiAAEA+R0A.',Fe='Feelfreefly:BAAAKgAECgUIBQAAAA==.',Fi='Firepig:BAAAKgADCggICwAAAA==.',Fo='Foan:BAAAKgAFFAIIAgAAAA==.',Fr='Freedoms:BAAAKgAFFAYIAgAAAA==.',Ga='Garnetmoon:BAABKgAFFH8OAAIGAAgIKBdbIQD7AAAGAAgIKBdbIQD7AAAAAA==.',Gr='Greennestea:BAAAKgADCgQIBAAAAA==.',Ki='Kimtaehee:BAAAKgADCgUIBQAAAA==.',La='Labubu:BAACKgAFFH8eAAMHAAgIABatCQC1AQAHAAgIABatCQC1AQAIAAEIxRVBFABPAAAqAAQKfyQAAgcACAjnIGsUAGQCAAcACAjnIGsUAGQCAAAA.',Mi='Micheller:BAAAKgADCgMIAwAAAA==.',Pa='Page:BAAAKgADCggICAAAAA==.Pandawarrior:BAABKgAFFH8LAAMJAAcIMRsrBgDkAQAJAAcIMRsrBgDkAQAKAAEIXwEWJQA8AAABKgAFFAgIDwAJAO4LAA==.Parad:BAAAKgAECgYIBgAAAA==.Parado:BAABKgAFFH8GAAILAAMInQ5LKgCZAAALAAMInQ5LKgCZAAAAAA==.',Pl='Playerfamclw:BAABKgAECn8aAAMMAAgI8xhRIQDrAQAMAAgI8xhRIQDrAQADAAEI6xDweAAzAAAAAA==.',Pr='Provence:BAAAKgADCgIIAgAAAA==.',Ri='Richeese:BAAAKgAECgQIBAAAAA==.',Sa='Saki:BAACKgAFFH8WAAINAAUIdxcDHQAfAQANAAUIdxcDHQAfAQAqAAQKfzAAAw0ACAjTGx4eAA4CAA0ACAjTGx4eAA4CAA4ABgjQFtUWADsBAAAA.',Sh='Shenyu:BAAAKgAFFAQIBAAAAA==.',Si='Sixsir:BAAAKgADCgYICgAAAA==.',Xi='Xiangjia:BAAAKgAECggIDgAAAA==.',Xl='Xlm:BAACKgAFFH8iAAIBAAcI+R3bFgBiAQABAAcI+R3bFgBiAQAqAAQKfzAAAgEACAjRIyoOALQCAAEACAjRIyoOALQCAAAA.',Yo='Yomeko:BAAAKgADCgQIBAAAAA==.Yorugal:BAABKgAFFH8IAAIJAAgIbRq8AwA2AgAJAAgIbRq8AwA2AgAAAA==.',['一半']='一半死一半活:BAAAKgADCggICQAAAA==.',['一只']='一只野苍蝇:BAAAKgADCgIIAgAAAA==.',['一蹄']='一蹄子踢死你:BAAAKgAECgMIAwAAAA==.',['一颗']='一颗鳗鱼寿司:BAAAKgAECgMIBQAAAA==.',['三界']='三界仙:BAAAKgAECgQIBAAAAA==.',['三队']='三队队长:BAAAKgAECggICAAAAA==.',['不吃']='不吃人头:BAABKgAFFH8NAAMPAAMItAj9OACTAAAPAAMI2Qf9OACTAAAQAAIIkQo6UQBnAAAAAA==.',['不堪']='不堪一鸡:BAABKgAFFH8KAAMQAAYIJhdcEwBbAQAQAAYIAxVcEwBbAQAPAAEIOyAuSQBbAAAAAA==.',['不好']='不好惹:BAAAKgAECggIDAAAAA==.',['与人']='与人驻颜光:BAAAKgAECgMIAwAAAA==.',['专业']='专业修驴蹄:BAAAKgAECggIDQAAAA==.',['两千']='两千年后的你:BAAAKgAECggICAAAAA==.',['丨染']='丨染丶:BAAAKgAECggIEAAAAA==.',['中铁']='中铁四局徐总:BAAAKgAECgMIAwAAAA==.',['乌萨']='乌萨奇:BAAAKgAFFAQIBAAAAA==.',['五雷']='五雷正法:BAABKgAFFH8GAAMRAAYI4AZOEACqAAARAAIIeQpOEACqAAASAAQIygEsQwB5AAAAAA==.',['亚莎']='亚莎之泪:BAAAKgADCggICAAAAA==.',['亚鸡']='亚鸡米德:BAABKgAFFH8GAAMBAAYIkhYXLgDaAAABAAQImR8XLgDaAAATAAIIewYIKACFAAAAAA==.',['亲亲']='亲亲小嘴:BAAAKgAECggICAAAAA==.',['从不']='从不抱怨环境:BAAAKgAECgQIBAAAAA==.',['伊仰']='伊仰:BAAAKgAFFAQIBAAAAA==.',['伊央']='伊央:BAABKgAFFH8GAAMUAAYIsRCINgC/AAAUAAQIixGINgC/AAAVAAIIag/uJwB3AAAAAA==.',['伊洋']='伊洋:BAAAKgAECggIBwAAAA==.',['你力']='你力气真大:BAAAKgAECggICAAAAA==.',['你拿']='你拿个杯:BAABKgAFFH8KAAMWAAYI+QvjCgCxAAAWAAMIJgPjCgCxAAAXAAUIvA1FMwCkAAAAAA==.',['你胖']='你胖到我啦:BAABKgAFFH8GAAIMAAYIQgj7GAAcAQAMAAYIQgj7GAAcAQAAAA==.',['元素']='元素之神:BAAAKgAECggIEQAAAA==.',['光影']='光影之间:BAAAKgAECggIEgAAAA==.',['八鳷']='八鳷鵺:BAACKgAFFH8iAAIGAAgIdw1/FABWAQAGAAgIdw1/FABWAQAqAAQKfzEAAgYACAhCHI4kACoCAAYACAhCHI4kACoCAAAA.',['养猪']='养猪大户春桃:BAABKgAECn8WAAISAAgIwwsgVQA/AQASAAgIwwsgVQA/AQAAAA==.',['再眠']='再眠一小夏:BAABKgAFFH8GAAMBAAIIyCEfRwCTAAABAAIIyCEfRwCTAAATAAIIYgveGgBuAAAAAA==.',['冬王']='冬王:BAAAKgADCgQIBAAAAA==.',['冰与']='冰与光的龙诗:BAAAKgAFFAEIAQAAAA==.',['冰激']='冰激凌火锅:BAACKgAFFH8GAAMDAAMITRcOHgCVAAADAAMITRcOHgCVAAAMAAEIlw9yRABAAAAqAAQKfycAAgMACAiPIwQKAJQCAAMACAiPIwQKAJQCAAAA.',['冷光']='冷光迷霧:BAAAKgAFFAgIAwAAAA==.',['制动']='制动你好:BAAAKgAECgIIAgAAAA==.制动底板:BAAAKgAECgYIBAAAAA==.制动底板冲孔:BAAAKgAECgIIAwAAAA==.制动底板切边:BAAAKgAECgIIAwAAAA==.制动底板总承:BAAAKgAECgYIEAAAAA==.制动底板成形:BAAAKgAECgQIBgAAAA==.制动底板翻边:BAAAKgAECgYIDgAAAA==.制动汽修店:BAAAKgAECgcICwAAAA==.制动瑧好:BAAAKgAECgIIAgAAAA==.',['刺丶']='刺丶隐:BAAAKgAECgMIBAAAAA==.',['勇敢']='勇敢的芯:BAACKgAFFH8GAAMBAAMIoxG3OgC6AAABAAMIoxG3OgC6AAATAAEI/Qn4OQAxAAAqAAQKfxkAAgEACAjaH30WAH0CAAEACAjaH30WAH0CAAAA.',['千花']='千花影:BAABKgAFFH8JAAMLAAMIRgxIKgCZAAALAAMIRgxIKgCZAAAFAAII3wIOKwBGAAAAAA==.',['午夜']='午夜泣雪:BAAAKgAECgIIAgAAAA==.',['半夏']='半夏如烟:BAAAKgAECgIIAgAAAA==.',['半岛']='半岛铁盒丶:BAAAKgAFFAgIBAAAAA==.',['卡位']='卡位:BAAAKgADCgcIBgAAAA==.',['卡尔']='卡尔塔西亚:BAAAKgAFFAIIAgAAAA==.',['厅局']='厅局级:BAAAKgAFFAIIAQAAAA==.',['原神']='原神启动:BAABKgAFFH8FAAMQAAMI+CIvKwClAAAQAAMIZR8vKwClAAAPAAEIniVoRwBjAAAAAA==.',['吉伊']='吉伊:BAABKgAFFH8GAAISAAYIixlTDACEAQASAAYIixlTDACEAQAAAA==.',['周末']='周末:BAABKgAFFH8GAAIMAAYIIR1BBgAmAgAMAAYIIR1BBgAmAgAAAA==.',['哈七']='哈七搭八:BAABKgAFFH8PAAIYAAQICwspJQCrAAAYAAQICwspJQCrAAABKgAFFAUIKQASAFghAA==.',['哎哟']='哎哟喂伱妹:BAABKgAFFH8FAAIIAAUIyxMeDQA9AQAIAAUIyxMeDQA9AQAAAA==.',['哔哩']='哔哩波波浪:BAABKgAECn8WAAMXAAgIyxoJVgD0AQAXAAgIexkJVgD0AQAZAAgI9xFXGwCGAQAAAA==.',['哥布']='哥布林:BAAAKgADCgEIAQAAAA==.',['唐珊']='唐珊:BAAAKgADCggICgAAAA==.',['啊咕']='啊咕:BAAAKgAFFAgIBAAAAA==.',['啊菇']='啊菇:BAABKgAFFH8IAAMNAAgIOhpdNgCXAAANAAcIOhpdNgCXAAAaAAEIAABSNgAAAAAAAA==.',['啭身']='啭身説僾你:BAAAKgAECgIIAgAAAA==.',['噩梦']='噩梦土色战:BAAAKgADCgIIAgAAAA==.',['圣光']='圣光之怒:BAAAKgAFFAIIAgAAAA==.圣光照耀你妹:BAAAKgAECgcIDQAAAA==.',['塞牙']='塞牙缝:BAACKgAFFH8aAAIGAAcISRSeCgDFAQAGAAcISRSeCgDFAQAqAAQKfyQAAgYACAgRHuMbACMCAAYACAgRHuMbACMCAAAA.',['壹蛤']='壹蛤咦紦:BAAAKgAECgMIAwAAAA==.',['夏天']='夏天的西瓜皮:BAAAKgAECgUICwAAAA==.',['多财']='多财多亿:BAABKgAFFH8IAAIQAAIImxcdMQCXAAAQAAIImxcdMQCXAAAAAA==.',['夜的']='夜的下弦月:BAAAKgADCgIIAgAAAA==.',['大帝']='大帝之光:BAAAKgAECgIIAgAAAA==.',['天才']='天才老司机:BAABKgAFFH8JAAIPAAMISgh8OgCNAAAPAAMISgh8OgCNAAAAAA==.',['天边']='天边的申:BAAAKgAECgEIAgAAAA==.',['天遣']='天遣者:BAAAKgAECgUICQAAAA==.',['天霆']='天霆号:BAAAKgAFFAgIBAAAAA==.',['奔波']='奔波尔壩:BAAAKgADCgcIBwAAAA==.',['女王']='女王的骑士:BAAAKgAECgEIAQAAAA==.',['奶足']='奶足就是好牧:BAAAKgAECgQIBAAAAA==.',['妖彤']='妖彤彤:BAABKgAFFH8FAAINAAMIMglTNgCXAAANAAMIMglTNgCXAAAAAA==.',['孔雀']='孔雀东南飞:BAAAKgAECgEIAQAAAA==.',['安玻']='安玻:BAAAKgAFFAIIBAAAAA==.',['定乾']='定乾坤:BAABKgAFFH8IAAMUAAQIkgkxHgCsAAAUAAQIUgMxHgCsAAAVAAQIkgkqFwCXAAAAAA==.',['宝山']='宝山飞龙锅:BAAAKgAFFAIIAwAAAA==.',['寒山']='寒山一箭:BAABKgAECn8UAAMPAAgI4h1PGQAGAgAPAAgIpBpPGQAGAgAQAAII0xjHzQCNAAAAAA==.',['寓清']='寓清于浊:BAAAKgAECgEIAQAAAA==.',['寿司']='寿司的骆驼:BAAAKgAECggIEwAAAA==.',['射会']='射会摇:BAABKgAFFH8GAAIQAAMIgwshHQCxAAAQAAMIgwshHQCxAAAAAA==.',['小不']='小不点宝宝:BAAAKgAECgMIAwAAAA==.',['小学']='小学生乐无穷:BAABKgAFFH8GAAIXAAYIOxYSJgBRAQAXAAYIOxYSJgBRAQAAAA==.',['小小']='小小稣:BAAAKgAECgMIAwAAAA==.',['小希']='小希纳奈:BAAAKgADCggIIAAAAA==.',['小江']='小江:BAAAKgADCgUIBQAAAA==.',['小火']='小火狐:BAAAKgAECgIIAgABKgAECggIFQATAGMNAA==.',['尐稀']='尐稀有动物尐:BAAAKgAECgQIBgAAAA==.尐稀有美人尐:BAAAKgAECgEIAQAAAA==.',['山村']='山村猛妇:BAAAKgAECggICgAAAA==.',['山花']='山花泡泡:BAAAKgAECgUIBQAAAA==.',['工口']='工口工口腐:BAAAKgAECgMIAwAAAA==.',['工捡']='工捡法:BAABKgAFFH8MAAMMAAgI+hlOBABoAgAMAAgI+hlOBABoAgADAAQIgQn1HQCVAAAAAA==.',['左手']='左手一只鸡:BAAAKgAFFAMIAwABKgAFFAgIDgAUAEoXAA==.',['左零']='左零右火:BAABKgAFFH8LAAIUAAgIVBusJwDvAAAUAAgIVBusJwDvAAAAAA==.',['巧儿']='巧儿:BAACKgAFFH8TAAIbAAMIzhAiCgDFAAAbAAMIzhAiCgDFAAAqAAQKfxQAAhsACAiyHWwHAFACABsACAiyHWwHAFACAAAA.',['巨毋']='巨毋霸:BAAAKgAECgQIAwAAAA==.',['布吉']='布吉岛:BAABKgAFFH8GAAILAAYI7Qb0FgD+AAALAAYI7Qb0FgD+AAAAAA==.',['希儿']='希儿瓦纳斯:BAABKgAFFH8MAAIQAAYI4BZCEQBuAQAQAAYI4BZCEQBuAQAAAA==.',['希尔']='希尔瓦娜巳:BAAAKgADCggICAAAAA==.希尔瓦拉丝:BAACKgAFFH8NAAMEAAgIjRBsBwCyAQAEAAcItQxsBwCyAQALAAMIjhb6IgC4AAAqAAQKfyMAAgsACAggGskYAPoBAAsACAggGskYAPoBAAAA.',['平安']='平安幸福:BAAAKgAFFAcIAwAAAA==.',['幺零']='幺零二四:BAABKgAFFH8KAAMIAAYI7BCkCQBxAQAIAAYI7BCkCQBxAQAHAAQIqwbbKgCYAAAAAA==.',['开鲁']='开鲁厨神:BAABKgAFFH8GAAIMAAYIPh+8CwCtAQAMAAYIPh+8CwCtAQAAAA==.',['影昼']='影昼:BAAAKgADCggICAAAAA==.',['念瑶']='念瑶:BAAAKgAFFAQIBAABKgAFFAYIQQASABIaAA==.',['忽然']='忽然惊鸿:BAAAKgADCgcIBwAAAA==.',['我只']='我只会转:BAAAKgAECgQIBAAAAA==.',['打拳']='打拳的壮汉:BAAAKgADCgQIBQAAAA==.',['技高']='技高一锤:BAAAKgADCgEIAQAAAA==.',['拘灵']='拘灵遣将:BAABKgAFFH8FAAMQAAUI0RLjCgArAQAQAAQI0RLjCgArAQAPAAEIAAASLwAAAAAAAA==.',['摇摆']='摇摆:BAACKgAFFH8VAAIUAAUIhhb0GwA+AQAUAAUIhhb0GwA+AQAqAAQKfy8AAhQACAjFIaUQAKACABQACAjFIaUQAKACAAAA.',['撒爹']='撒爹的小弟:BAABKgAFFH8QAAINAAQIKgrVGgCnAAANAAQIKgrVGgCnAAAAAA==.',['施公']='施公子:BAAAKgAECggICAAAAA==.',['无敌']='无敌八六:BAAAKgAECggICAAAAA==.',['时间']='时间比较少:BAAAKgADCgIIAgAAAA==.',['明镜']='明镜湖丶炊烟:BAAAKgADCgcIBwAAAA==.明镜湖的千幻:BAAAKgAECgMIAwAAAA==.明镜湖的秋天:BAAAKgAECggIDgAAAA==.',['星悦']='星悦丨缘:BAAAKgADCgQIBAAAAA==.星悦丨耀:BAAAKgAECggICAAAAA==.星悦丨魂:BAAAKgADCgcICAAAAA==.',['春风']='春风灬暖阳:BAAAKgAFFAgICAAAAA==.',['普尼']='普尼丨格杰尔:BAAAKgAFFAIIAgAAAA==.',['曰後']='曰後再说:BAAAKgAECgYIBgAAAA==.',['最后']='最后一头毛象:BAAAKgAFFAQIAwAAAA==.',['月落']='月落霜天:BAAAKgADCgEIAQAAAA==.',['木槿']='木槿昔年:BAAAKgAECggIEAAAAA==.',['机械']='机械舒适:BAAAKgADCgEIAQAAAA==.',['杠上']='杠上开花:BAAAKgAECgMIAwAAAA==.',['来一']='来一记:BAABKgAFFH8UAAMJAAgI2hWNBgDaAQAJAAgI2hWNBgDaAQAcAAQI5AZKBgCFAAAAAA==.',['林深']='林深时雾起:BAABKgAFFH8MAAIPAAMIlRI9LQC2AAAPAAMIlRI9LQC2AAAAAA==.',['柳橙']='柳橙汁:BAAAKgADCgIIAgAAAA==.',['树先']='树先生:BAABKgAECn8WAAMPAAcI1RnDOAB1AQAPAAcIphbDOAB1AQAQAAQIjxSRmQD1AAAAAA==.',['格劳']='格劳克斯:BAAAKgAECgUIBgAAAA==.',['桉叶']='桉叶:BAAAKgAFFAIIAgAAAA==.',['梦仪']='梦仪:BAAAKgAECgIIAgAAAA==.',['梦妲']='梦妲己:BAAAKgAFFAEIAQAAAA==.',['梦泽']='梦泽:BAAAKgAECgEIAgAAAA==.',['梦迪']='梦迪壳:BAAAKgADCgQIBAAAAA==.',['楍峎']='楍峎丶凩戥:BAAAKgAECgYICwAAAA==.',['槿紫']='槿紫:BAAAKgADCgYIBgAAAA==.',['此往']='此往:BAAAKgAECgMIAwAAAA==.',['武吉']='武吉吉:BAAAKgAECgMIAwAAAA==.',['死人']='死人蘑:BAACKgAFFH8eAAMQAAYISBfmFgBBAQAQAAYISBfmFgBBAQAPAAEIMAX1VQArAAAqAAQKfycAAhAACAjjIIQeAH0CABAACAjjIIQeAH0CAAAA.',['毀烕']='毀烕:BAAAKgADCgIIAgAAAA==.',['比那']='比那名居天子:BAEBKgAECn8UAAMIAAgIlhx/EAA3AgAIAAgIlhx/EAA3AgAHAAEIXQ8+egA0AAAAAA==.',['汐月']='汐月:BAAAKgAECggIDAABKgAFFAUIGQAKAL4MAA==.',['沈七']='沈七七:BAAAKgAECgEIAQAAAA==.',['沧海']='沧海丶怒:BAACKgAFFH8RAAISAAQI7CGPBwAcAQASAAQI7CGPBwAcAQAqAAQKfyoAAhIACAjpIbUNAIoCABIACAjpIbUNAIoCAAAA.',['波波']='波波黑凤梨:BAAAKgAECggIDAAAAA==.',['泰岚']='泰岚德羽风:BAAAKgAECggICgAAAA==.',['海棠']='海棠花未眠:BAAAKgAECggIEAAAAA==.',['混沌']='混沌法神:BAAAKgADCggICAAAAA==.',['清水']='清水末末:BAABKgAFFH8KAAIXAAQIDh7ZDAAhAQAXAAQIDh7ZDAAhAQAAAA==.清水沫沫:BAABKgAFFH8GAAILAAQIXxqCBwD8AAALAAQIXxqCBwD8AAAAAA==.',['游隼']='游隼:BAAAKgAECgUIBwAAAA==.',['湛蓝']='湛蓝风华:BAAAKgAECgMIAwAAAA==.',['满江']='满江春水:BAAAKgADCggICAAAAA==.',['火激']='火激凌冰锅:BAABKgAFFH8GAAIBAAMIJw/RHQC/AAABAAMIJw/RHQC/AAAAAA==.',['烟灰']='烟灰散尽:BAAAKgADCgUIBQAAAA==.',['無声']='無声網亊:BAAAKgAECgUIBQAAAA==.',['熊心']='熊心豹胆丶:BAACKgAFFH8eAAIKAAcITxfhCQBHAQAKAAcITxfhCQBHAQAqAAQKfyYABAoACAg7HNkVADICAAoACAg7HNkVADICABwAAwjQDPoaAIUAAAkAAgi2AAqcABMAAAAA.',['燃月']='燃月灬伊:BAAAKgAECgQIBAAAAA==.燃月灬晴:BAAAKgAFFAMIAwAAAA==.燃月灬梓:BAABKgAFFH8FAAIQAAMIeBNsMgDFAAAQAAMIeBNsMgDFAAAAAA==.燃月灬静:BAABKgAFFH8GAAISAAMITw1BNQCoAAASAAMITw1BNQCoAAAAAA==.燃月灬黑骑:BAAAKgAECgMIAwAAAA==.',['牧色']='牧色:BAAAKgAECggIDAAAAA==.',['狼骑']='狼骑:BAAAKgAECgQIBAAAAA==.',['猛德']='猛德鸦匹:BAABKgAFFH8HAAIBAAQIIhG/OAC/AAABAAQIIhG/OAC/AAAAAA==.',['猫毛']='猫毛熊:BAAAKgAECgIIAgAAAA==.',['猫表']='猫表妹:BAAAKgADCggIFwABKgAECggIFQATAGMNAA==.',['玄奘']='玄奘:BAABKgAFFH8LAAIKAAUIrQjaDwDnAAAKAAUIrQjaDwDnAAAAAA==.',['珺应']='珺应有语:BAABKgAFFH8PAAINAAgINBmHBABaAgANAAgINBmHBABaAgAAAA==.',['璀璨']='璀璨梦境:BAAAKgAECgQIBAABKgAFFAgIIgASAFASAA==.',['瓦力']='瓦力旭旭:BAABKgAFFH8YAAMQAAgIKBAkFQBMAQAQAAcIYQ0kFQBMAQAPAAUI5xPpEgDPAAAAAA==.',['用晦']='用晦而明:BAAAKgAECgQICAAAAA==.',['甲乙']='甲乙丙丁:BAAAKgAECgEIAgAAAA==.',['疲惫']='疲惫肾:BAAAKgAFFAcIAwAAAA==.',['白到']='白到发光:BAAAKgAECggIDwABKgAECggIFQATAGMNAA==.',['盘儿']='盘儿靓:BAAAKgAFFAIIAgAAAA==.',['看我']='看我这个挫样:BAABKgAFFH8MAAIHAAQI8BEsIQDPAAAHAAQI8BEsIQDPAAABKgAFFAUIKQASAFghAA==.',['矮丑']='矮丑穷搓怂:BAAAKgADCggICAAAAA==.',['砰砰']='砰砰啪啪:BAABKgAFFH8OAAIPAAgI0BrZDACLAQAPAAgI0BrZDACLAQAAAA==.',['碎影']='碎影舞月:BAAAKgAFFAMIAwAAAA==.',['神之']='神之泣女:BAAAKgAECgUIBQAAAA==.',['神奇']='神奇小森森:BAAAKgAECggICAAAAA==.',['神话']='神话哥:BAAAKgADCgYIBgAAAA==.',['福尔']='福尔摩斯:BAAAKgAECgUIBQAAAA==.',['秋水']='秋水天长:BAAAKgAECggIAQAAAA==.',['移动']='移动点餐机:BAAAKgAECgEIAQAAAA==.',['空帆']='空帆船:BAABKgAECn8qAAIHAAgIbCBMDQB8AgAHAAgIbCBMDQB8AgAAAA==.',['童心']='童心未泯:BAAAKgADCggICAAAAA==.',['童话']='童话哥:BAABKgAECn8hAAMXAAgIVwqstADnAAAXAAgIVwqstADnAAAZAAMIagXXXAAxAAAAAA==.',['箂篰']='箂篰菈莅:BAAAKgADCgcIBwAAAA==.',['米奈']='米奈希爾:BAAAKgAFFAYIBAAAAA==.',['紫夜']='紫夜冰:BAAAKgADCgIIAgAAAA==.紫夜枫:BAAAKgADCggIDwAAAA==.紫夜雪月:BAAAKgAECgEIAQAAAA==.',['紫风']='紫风云泱:BAAAKgAECgIIAgAAAA==.',['絶对']='絶对零度:BAACKgAFFH8XAAIDAAMIICQyCQAwAQADAAMIICQyCQAwAQAqAAQKf9oAAwMACAidJdgDAOwCAAMACAidJdgDAOwCAAwACAirG9AWADsCAAAA.',['红嘴']='红嘴儿鲤鱼:BAABKgAFFH8JAAIdAAYI9gOgDwDpAAAdAAYI9gOgDwDpAAAAAA==.',['线芯']='线芯:BAAAKgAECgYIBgAAAA==.',['终不']='终不似少年游:BAAAKgADCgUIBQAAAA==.',['终极']='终极小蓝:BAABKgAFFH8dAAQLAAgIqxl0GwDhAAALAAUIkBp0GwDhAAAFAAQIIhWNFwC/AAAEAAIIzAJyLwBVAAAAAA==.',['给你']='给你个脑子:BAAAKgADCgUIBQAAAA==.',['绯村']='绯村:BAAAKgAECgYIBgAAAA==.',['网事']='网事如枫:BAABKgAFFH8GAAIDAAIILgwQIwB1AAADAAIILgwQIwB1AAAAAA==.',['胎神']='胎神:BAABKgAFFH8OAAIUAAgIKxTaCAAAAgAUAAgIKxTaCAAAAgAAAA==.',['至尊']='至尊大宗师:BAAAKgAECggIEQAAAA==.至尊猪儿虫:BAACKgAFFH86AAIHAAgIyxtVCADVAQAHAAgIyxtVCADVAQAqAAQKfy4AAgcACAhqI4YNAJoCAAcACAhqI4YNAJoCAAAA.',['至少']='至少一七五:BAACKgAFFH8oAAMXAAgIMBdRGACaAQAXAAgIMBdRGACaAQAWAAIIUQKXGgBbAAAqAAQKfykAAhcACAj/HP0+ADICABcACAj/HP0+ADICAAAA.',['花开']='花开坢夏丶:BAACKgAFFH8eAAIZAAgIWBaLAQCXAQAZAAgIWBaLAQCXAQAqAAQKfywAAxcACAjgI8IWAKwCABcACAjgI8IWAKwCABkACAiqFF0dAHABAAAA.',['苍穹']='苍穹嗷嗷:BAAAKgAECgUIBgAAAA==.',['荒野']='荒野大镖客:BAAAKgAECgIIAgAAAA==.',['荣耀']='荣耀依然黯淡:BAABKgAECn9HAAIXAAgIDx9GJgBnAgAXAAgIDx9GJgBnAgAAAA==.',['莎萝']='莎萝:BAABKgAFFH8KAAILAAYIcRtuEAAvAQALAAYIcRtuEAAvAQAAAA==.',['莫昭']='莫昭妍:BAAAKgAFFAIIAgAAAA==.',['菊花']='菊花又想开了:BAAAKgAFFAQIBAAAAA==.菊花想开了:BAAAKgAFFAQIBAAAAA==.',['菜坬']='菜坬:BAAAKgAECgMIAwAAAA==.',['菜鸡']='菜鸡只想躺:BAAAKgAECgQIBAAAAA==.',['萧黏']='萧黏黏:BAAAKgADCggICAAAAA==.',['萨哥']='萨哥:BAAAKgAECggIDQAAAA==.',['萬千']='萬千寵愛:BAAAKgAFFAIIAgAAAA==.',['落花']='落花人独笠:BAAAKgAECgUIDgAAAA==.',['落英']='落英神剑掌:BAAAKgADCgUIBQAAAA==.',['蔷薇']='蔷薇花开:BAAAKgAFFAcIAQAAAA==.',['虎哥']='虎哥:BAAAKgAECgUIBwAAAA==.',['虚空']='虚空乄影:BAABKgAFFH8FAAINAAQIBRpSEQDgAAANAAQIBRpSEQDgAAAAAA==.',['蝶咿']='蝶咿梦:BAABKgAFFH8GAAINAAYIZBdfFgBQAQANAAYIZBdfFgBQAQAAAA==.',['襄阳']='襄阳丶彭于晏:BAABKgAFFH8KAAMUAAYI5BJzEQDeAAAUAAUI9RRzEQDeAAAbAAIIVg2/DACZAAAAAA==.',['要猛']='要猛:BAAAKgAECggICQAAAA==.',['许乐']='许乐:BAABKgAFFH8GAAISAAYIzhNDCwBHAQASAAYIzhNDCwBHAQAAAA==.',['请叫']='请叫我撒爹:BAACKgAFFH8pAAISAAQIWCFbHwD9AAASAAQIWCFbHwD9AAAqAAQKfxUAAhIACAguFVBCAH4BABIACAguFVBCAH4BAAAA.',['诺妹']='诺妹妹:BAABKgAECn8VAAMTAAgIYw1SQQAKAQATAAcIKw1SQQAKAQABAAYInwwqdwD0AAAAAA==.',['诺表']='诺表妹:BAAAKgADCggIEgAAAA==.',['谠都']='谠都档不住:BAAAKgAFFAYIAQAAAA==.',['谢小']='谢小丸子:BAAAKgAECgIIAgAAAA==.',['谦谦']='谦谦不要太帅:BAACKgAFFH8MAAMIAAUIABL2CQDxAAAIAAMIlBL2CQDxAAAHAAQIjQwjJQC7AAAqAAQKfxwABAcACAhJGZYkAP8BAAcACAiSGJYkAP8BAB4ABghmEhYwAI8AAAgAAgjVCuJgAEkAAAAA.谦谦妈妈:BAAAKgAFFAEIAQAAAA==.谦谦妈妈诶:BAAAKgAECgQIAQAAAA==.',['豆汁']='豆汁:BAAAKgAECggICAAAAA==.',['豪艾']='豪艾朗尼克:BAAAKgADCggICAAAAA==.',['身材']='身材好:BAAAKgADCgQIBAAAAA==.',['这很']='这很奈斯:BAABKgAFFH8KAAISAAYILBx7CgAEAQASAAYILBx7CgAEAQABKgAFFAgICAASALsbAA==.',['迪菲']='迪菲亚顾问:BAACKgAFFH8HAAIWAAII3A55FwB6AAAWAAII3A55FwB6AAAqAAQKfx0AAxYACAj+FGIIAKkBABYACAj+FGIIAKkBABcABAgvFChRALwAAAAA.',['迷糊']='迷糊酱爷爷:BAABKgAFFH8GAAISAAQIYw1fFgDLAAASAAQIYw1fFgDLAAAAAA==.',['迷踪']='迷踪大师:BAAAKgAFFAMIAwAAAA==.',['醉花']='醉花間丶影子:BAAAKgADCgUIBQAAAA==.',['重生']='重生之牛牛:BAAAKgAECgcIBwAAAA==.',['钙琪']='钙琪叮丝:BAAAKgAECgEIAQAAAA==.',['门番']='门番红美铃:BAAAKgAFFAgIAgAAAA==.',['闪电']='闪电宝坦:BAAAKgAFFAgIBAAAAA==.闪电宝法:BAABKgAFFH8GAAIDAAYI7Rv/BQAAAQADAAYI7Rv/BQAAAQAAAA==.',['阿哦']='阿哦:BAAAKgAECggIBwAAAA==.',['阿森']='阿森西奥:BAACKgAFFH8sAAMSAAgI4BQwDACGAQASAAgI4BQwDACGAQARAAEIrwM6EAA1AAAqAAQKfzIAAhIACAiwG3UlAPoBABIACAiwG3UlAPoBAAAA.',['陌上']='陌上谁家年少:BAAAKgAECgYICwAAAA==.',['院锁']='院锁清秋:BAAAKgAECggICAAAAA==.',['随便']='随便捣捣:BAACKgAFFH8fAAIQAAQItiAtHwARAQAQAAQItiAtHwARAQAqAAQKfxcAAhAACAjhH3svADYCABAACAjhH3svADYCAAEqAAUUBQgpABIAWCEA.随便谈谈:BAABKgAFFH8IAAIIAAgIeQrLBQDHAQAIAAgIeQrLBQDHAQAAAA==.',['雨霏']='雨霏:BAAAKgADCgUIBQAAAA==.',['雪雨']='雪雨之泪:BAAAKgAECgYIBgAAAA==.',['雷米']='雷米尔:BAAAKgAECgEIAQAAAA==.',['雷霆']='雷霆惊梦:BAACKgAFFH8iAAISAAgIUBIAEwA+AQASAAgIUBIAEwA+AQAqAAQKfycAAhIACAj2ITcUAFsCABIACAj2ITcUAFsCAAAA.',['雾切']='雾切响子:BAABKgAECn8UAAIGAAcIIBhpOgDAAQAGAAcIIBhpOgDAAQAAAA==.',['青花']='青花瓷:BAABKgAFFH8PAAMEAAgIrBu6CgBqAQAEAAQIAx+6CgBqAQALAAUI5BSyFwD4AAAAAA==.',['风后']='风后奇门:BAABKgAFFH8MAAICAAQIFyB/FgD0AAACAAQIFyB/FgD0AAAAAA==.',['飞过']='飞过海枯:BAAAKgAECgcIBwAAAA==.',['马小']='马小槑:BAAAKgAECgcIBwAAAA==.',['麻将']='麻将女王乐乐:BAAAKgAECgUIBwAAAA==.',['黏黏']='黏黏虫:BAAAKgAECggICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end