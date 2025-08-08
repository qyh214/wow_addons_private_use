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
 local lookup = {'Mage-Fire','Mage-Arcane','Warlock-Destruction','Priest-Discipline','Warrior-Arms','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Monk-Mistweaver','Unknown-Unknown','Druid-Restoration','Druid-Balance','DeathKnight-Blood','Paladin-Holy','DeathKnight-Unholy','Paladin-Retribution','Shaman-Restoration','Mage-Frost','Shaman-Elemental','Evoker-Preservation','Evoker-Devastation','Paladin-Protection','Warrior-Fury','DemonHunter-Havoc','Warlock-Affliction','Priest-Shadow','Priest-Holy','Warrior-Protection','Shaman-Enhancement','Druid-Guardian',}; local provider = {region='CN',realm='埃克索图斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acer:BAAAKgAFFAIIAgAAAA==.',Ae='Aegon:BAAAKgADCgIIAgAAAA==.Aeraely:BAAAKgAECggICAAAAA==.',At='Atenza:BAAAKgAECgQIBAAAAA==.Atmat:BAAAKgAECgEIAQAAAA==.',Ce='Cello:BAACKgAFFH8QAAMBAAII/SWlIADUAAABAAIIXSOlIADUAAACAAIIhCUgKQC+AAAqAAQKfzkAAwEACAgqJoMEAPECAAEACAioJYMEAPECAAIACAi/JOMJALICAAAA.',Da='Damonshadow:BAAAKgAECgIIAgAAAA==.',De='Demonkid:BAABKgAECn8eAAIDAAgIZxjiHwAFAgADAAgIZxjiHwAFAgAAAA==.Devela:BAAAKgAECggIDwAAAA==.',Di='Dih:BAAAKgAECggICAAAAA==.Dik:BAAAKgAFFAMIAwAAAA==.Dika:BAAAKgAECgEIAQAAAA==.Dinozzotong:BAAAKgADCggICQAAAA==.',Dr='Druggift:BAAAKgAECgcIDQAAAA==.',Fo='Foreverfox:BAABKgAFFH8QAAIEAAQIYSNIDgA1AQAEAAQIYSNIDgA1AQAAAA==.',Hu='Huulk:BAABKgAFFH8GAAIFAAYIphDdCQBtAQAFAAYIphDdCQBtAQAAAA==.',Jj='Jjyuy:BAAAKgAECgcIBwAAAA==.',Ko='Koomo:BAAAKgAFFAEIAQAAAA==.',Le='Leehyori:BAAAKgAFFAEIAQAAAA==.',Me='Melonassasin:BAAAKgAECggICAAAAA==.',Mi='Missnel:BAAAKgAECgYIBgAAAA==.',Ne='Nelthario:BAACKgAFFH8bAAMGAAQIESRADQAsAQAGAAMIESRADQAsAQAHAAIIaB/OVABaAAAqAAQKfy4AAwYACAhzIwgQAFYCAAYABwhzIwgQAFYCAAcABQiuGG2LABgBAAAA.',Ni='Nicolasiss:BAAAKgADCgIIAwAAAA==.',Oh='Ohho:BAAAKgAECggICAAAAA==.',Or='Orangebones:BAABKgAFFH8IAAIIAAgIMQ0GBQAgAgAIAAgIMQ0GBQAgAgAAAA==.',Pa='Palapala:BAAAKgAFFAIIBAAAAA==.',Qr='Qredeemer:BAAAKgAECggICAAAAA==.',Re='Regrets:BAAAKgADCgIIAgAAAA==.',Ro='Robbergirl:BAACKgAFFH8PAAMJAAMIAgynCQDVAAAJAAMIAgynCQDVAAAIAAEIjgY8KgA3AAAqAAQKfyYAAwkACAiFGCUNABQCAAkACAiFGCUNABQCAAgABAjFECEuAOEAAAAA.',So='Sour:BAAAKgAFFAQIBAAAAA==.',Sw='Swandsky:BAAAKgAFFAgIBAAAAA==.',To='Tongtheway:BAAAKgADCggICAAAAA==.Tonytong:BAAAKgADCggIEAAAAA==.',Va='Vara:BAAAKgAECgMIAwAAAA==.',Xk='Xkingt:BAAAKgAFFAYIBAABKgAFFAgIEwAHAOUdAA==.',Yo='Yoyo:BAAAKgADCggICAAAAA==.',['一个']='一个人的曾经:BAABKgAFFH8MAAIKAAYIwhlrAQDjAQAKAAYIwhlrAQDjAQAAAA==.',['一夜']='一夜一追寻:BAAAKgADCggICAAAAA==.',['一枪']='一枪一爆头:BAABKgAFFH8XAAMHAAYIdhkgDAAjAQAHAAYIvRcgDAAjAQAGAAQI4SRXGgAaAQABKgAFFAgIAgALAAAAAA==.',['一树']='一树梨花:BAAAKgAECgIIAgAAAA==.',['万人']='万人迷:BAAAKgAECgEIAQAAAA==.',['三瑞']='三瑞咕咕:BAAAKgAFFAIIAgAAAA==.',['三笠']='三笠乄:BAAAKgAECgcIBwAAAA==.',['下午']='下午茶:BAAAKgAFFAQIBAABKgAFFAgICAACALoSAA==.',['不敢']='不敢吹牛了:BAAAKgAECgQIBAAAAA==.',['不知']='不知稻:BAAAKgADCggICAAAAA==.',['不能']='不能怎么做:BAAAKgAFFAYIBAAAAA==.不能这么做:BAAAKgAFFAcIAQAAAA==.',['丛林']='丛林小霸王:BAABKgAFFH8KAAMMAAYIDh2gBgCsAQAMAAYIDh2gBgCsAQANAAQIEAdNTQB/AAAAAA==.丛林狩猎:BAAAKgADCggICAAAAA==.',['东东']='东东同学:BAABKgAFFH8IAAIOAAgIkAgjBgBjAQAOAAgIkAgjBgBjAQAAAA==.',['东方']='东方丶馆长:BAABKgAFFH8IAAIPAAQIkRshBwDfAAAPAAQIkRshBwDfAAAAAA==.',['丨夜']='丨夜雨声烦:BAAAKgAECggICwAAAA==.',['丶庸']='丶庸医药丸:BAAAKgADCggICAAAAA==.',['丿丶']='丿丶青花瓷:BAAAKgAECgYIBwAAAA==.',['乳刺']='乳刺丸美小鸟:BAABKgAFFH8GAAICAAYI1BvmCgC9AQACAAYI1BvmCgC9AQAAAA==.',['二号']='二号首长丶:BAABKgAFFH8IAAMMAAYI/AaaBwACAQAMAAQIGwiaBwACAQANAAQIhhorDwD/AAABKgAFFAgIEAANANUeAA==.',['二界']='二界:BAABKgAFFH8KAAIFAAYIYxauAQCuAQAFAAYIYxauAQCuAQAAAA==.',['云淡']='云淡天高:BAAAKgAECgcIBwAAAA==.',['京观']='京观:BAABKgAFFH8IAAIPAAIIgRQeGAB1AAAPAAIIgRQeGAB1AAAAAA==.',['他他']='他他丶塔子哥:BAABKgAECn8ZAAIQAAgIVRtpJAD4AQAQAAgIVRtpJAD4AQAAAA==.',['佑缇']='佑缇艾沫:BAAAKgAECgUICwAAAA==.',['何包']='何包菜:BAAAKgADCggICAAAAA==.',['你吃']='你吃了吗:BAAAKgAECgQIBgAAAA==.',['使劲']='使劲打用力抽:BAABKgAECn8XAAIRAAcI9xqXjAB+AQARAAcI9xqXjAB+AQAAAA==.',['侏丶']='侏丶儒好朋友:BAAAKgAECgMIAwAAAA==.',['便宜']='便宜一点:BAACKgAFFH8HAAISAAIIIhoAOgCbAAASAAIIIhoAOgCbAAAqAAQKfxQAAhIACAghGO0sAMgBABIACAghGO0sAMgBAAAA.',['倒霉']='倒霉的小胖牛:BAAAKgAFFAIIAgAAAA==.',['傻漫']='傻漫:BAAAKgADCgQIBAAAAA==.',['元素']='元素丶地球:BAABKgAFFH8IAAISAAgITQwNCQC2AQASAAgITQwNCQC2AQAAAA==.',['光能']='光能趴瓦:BAAAKgAFFAgIBAAAAA==.',['克丨']='克丨劳丨德:BAABKgAFFH8PAAMNAAgIXR6HEQCSAQANAAYI3iGHEQCSAQAMAAYICBWKCwBNAQAAAA==.',['再来']='再来一发:BAAAKgADCggICAAAAA==.',['冰丶']='冰丶媛:BAABKgAFFH8QAAMTAAQISR8tDAAIAQATAAMISR8tDAAIAQACAAMIYRIGOACCAAABKgAFFAQIGQAUAIgfAA==.',['凡尘']='凡尘忆梦:BAAAKgAFFAIIAgABKgAFFAgICgAMAO0VAA==.',['刀下']='刀下牛人:BAAAKgAECggIDAAAAA==.',['刁骑']='刁骑:BAABKgAFFH8GAAMPAAYIhQkwEAB/AAAPAAIIJAswEAB/AAARAAQIcwuSTABQAAAAAA==.',['勒勒']='勒勒布:BAABKgAFFH8GAAIRAAQI3iW2KABFAQARAAQI3iW2KABFAQAAAA==.',['千寻']='千寻瀑:BAAAKgADCggICAABKgAFFAgIXwABAPsmAA==.',['千里']='千里走单骑:BAAAKgADCgUIBQAAAA==.',['卡赞']='卡赞丶艾叶:BAAAKgAECgcIBwAAAA==.',['厚礼']='厚礼蟹:BAABKgAFFH8IAAIRAAgIChYECABDAgARAAgIChYECABDAgAAAA==.',['古尼']='古尼基哇:BAAAKgADCgEIAQAAAA==.',['吃饱']='吃饱皮:BAAAKgAFFAQIBAAAAA==.',['呼噜']='呼噜:BAABKgAFFH8IAAMVAAMI4wMeCgBMAAAVAAMI4wMeCgBMAAAWAAIIDwE/NwAsAAAAAA==.',['呼小']='呼小胖:BAAAKgAFFAIIBAAAAA==.',['哈基']='哈基米德:BAAAKgAECgIIAgAAAA==.',['哈库']='哈库拉玛塔塔:BAABKgAFFH8UAAMNAAYISh8VAgC8AQANAAYISh8VAgC8AQAMAAQIPRzZBQAdAQAAAA==.',['哈酷']='哈酷啦玛塔塔:BAAAKgAECgMIAwAAAA==.',['团捡']='团捡开:BAAAKgADCggICAAAAA==.',['圣光']='圣光丶地球:BAABKgAFFH8HAAMXAAYIaw0xEgDsAAAXAAYIaw0xEgDsAAARAAEINRCnVwA8AAAAAA==.',['地狱']='地狱战歌咆哮:BAAAKgADCggICAAAAA==.',['地震']='地震加速度:BAAAKgAFFAQIBAAAAA==.',['壹叶']='壹叶知秋:BAAAKgAECggICAAAAA==.',['壹贰']='壹贰贰零:BAABKgAFFH8KAAMHAAYINBlZDgCOAQAHAAYINBlZDgCOAQAGAAQIiRZWMACtAAAAAA==.',['夜之']='夜之子有纹身:BAAAKgAECgcIBwAAAA==.',['夜幕']='夜幕灬旋律:BAAAKgAECgEIAQAAAA==.',['夜颜']='夜颜星辰:BAAAKgAECgYIBgAAAA==.',['夢幻']='夢幻球球:BAAAKgAECgUIBwAAAA==.',['大不']='大不净者印光:BAAAKgADCgQIBAAAAA==.',['大牛']='大牛小牛:BAAAKgAECgcIBwAAAA==.',['大长']='大长老:BAAAKgAFFAcIAwAAAA==.',['天堂']='天堂的刑具:BAABKgAFFH8GAAIYAAYIOBMIAgCsAQAYAAYIOBMIAgCsAQABKgAFFAgIAgALAAAAAA==.',['天山']='天山雪大红枣:BAAAKgADCggICAAAAA==.',['天年']='天年:BAACKgAFFH8NAAIKAAQI/xCKEACiAAAKAAQI/xCKEACiAAAqAAQKfykAAgoACAjzF+UjANQBAAoACAjzF+UjANQBAAAA.',['天降']='天降正义丶:BAABKgAFFH8LAAIKAAYIsRCaAwCLAQAKAAYIsRCaAwCLAQAAAA==.',['奶壹']='奶壹口:BAAAKgAECggICQAAAA==.',['娜可']='娜可露露丶:BAAAKgAFFAQIBAAAAA==.',['子墨']='子墨丶战:BAAAKgAECgIIAgAAAA==.',['孙达']='孙达浪:BAAAKgAECgYIBgAAAA==.',['孟锜']='孟锜呀:BAAAKgAFFAQIBAAAAA==.',['守望']='守望猎手:BAABKgAFFH8NAAIZAAQIFRZVJwDZAAAZAAQIFRZVJwDZAAABKgAFFAQIGQAUAIgfAA==.',['宝贝']='宝贝的帮凶:BAABKgAFFH8IAAIRAAgIuBsEBwBYAgARAAgIuBsEBwBYAgAAAA==.',['寇达']='寇达娜丶魔刃:BAAAKgADCggICgAAAA==.',['小何']='小何超勇的:BAAAKgAECgYIBgAAAA==.',['小小']='小小芒:BAAAKgAFFAIIAgAAAA==.',['小欢']='小欢乐:BAABKgAFFH8HAAIaAAMIogYTDQBuAAAaAAMIogYTDQBuAAAAAA==.',['小浣']='小浣熊詹姆斯:BAAAKgAECgYIDgAAAA==.',['小甜']='小甜心:BAAAKgAECgYIBgAAAA==.',['小确']='小确幸丶:BAAAKgAECgMIAwAAAA==.',['小米']='小米丶酥妻:BAAAKgAECggIEAAAAA==.',['小鬼']='小鬼带我飞:BAAAKgAECgUIBwAAAA==.',['小鸟']='小鸟伏特加:BAABKgAECn8ZAAIYAAgIfCRmEgBzAgAYAAgIfCRmEgBzAgABKgAFFAgIBgAYABcZAA==.',['小黄']='小黄瓜:BAAAKgAECgIIAgAAAA==.',['尘默']='尘默:BAAAKgAFFAQIBAAAAA==.',['尛乖']='尛乖:BAAAKgAECggIEgAAAA==.',['巨龙']='巨龙撞击:BAAAKgADCggICAAAAA==.',['布莱']='布莱斯:BAAAKgAFFAQIBAAAAA==.',['布萊']='布萊克:BAABKgAECn8eAAIYAAgIHiC/EgBxAgAYAAgIHiC/EgBxAgAAAA==.',['帝天']='帝天丶月亮湾:BAAAKgAECggIDwAAAA==.',['平淡']='平淡生活的刺:BAAAKgADCggICAAAAA==.',['年年']='年年知為誰生:BAAAKgAECgcIDQAAAA==.',['影舞']='影舞姬:BAAAKgADCgEIAQAAAA==.',['彼此']='彼此的牵绊:BAAAKgAECggIDwAAAA==.',['德国']='德国马牌:BAAAKgAECgMIAwAAAA==.',['念小']='念小妞:BAABKgAECn8hAAMbAAgIMBiwHQDoAQAbAAgIMBiwHQDoAQAcAAYIJBlsMwBRAQAAAA==.',['怎么']='怎么都在打我:BAABKgAFFH8MAAIXAAgIWB6aAgA7AgAXAAgIWB6aAgA7AgAAAA==.',['怒魂']='怒魂:BAAAKgADCgEIAgAAAA==.',['急冻']='急冻河童:BAAAKgAECgUIDQAAAA==.',['恶魔']='恶魔球球:BAACKgAFFH8bAAIZAAQIoyAtHgARAQAZAAQIoyAtHgARAQAqAAQKfzgAAhkACAhQIFUVAFYCABkACAhQIFUVAFYCAAAA.恶魔的左耳:BAAAKgAECggICAAAAA==.',['悲伤']='悲伤向侑:BAAAKgAECgIIAgAAAA==.悲伤涅槃:BAAAKgADCggICAAAAA==.',['悲傷']='悲傷项佑:BAABKgAFFH8KAAIdAAgIkwupAwB0AQAdAAgIkwupAwB0AQAAAA==.',['想戈']='想戈名字好难:BAAAKgADCgYIBgAAAA==.',['愤怒']='愤怒的小细软:BAAAKgAECgYICAAAAA==.',['慧香']='慧香:BAAAKgAECgEIAQAAAA==.',['我只']='我只是个演员:BAAAKgAECgUIBQAAAA==.',['我很']='我很好那你呢:BAAAKgAECgYIDwAAAA==.',['指尖']='指尖灬漫步:BAAAKgAECgMIBQAAAA==.',['斑帝']='斑帝:BAACKgAFFH8HAAIOAAQIqwxdJACHAAAOAAQIqwxdJACHAAAqAAQKfxYAAg4ACAi8CCU3AOsAAA4ACAi8CCU3AOsAAAAA.',['斩相']='斩相思:BAAAKgAECgQIBgAAAA==.',['是壮']='是壮不是胖:BAAAKgAECgUIBQAAAA==.',['最后']='最后的怒吼:BAABKgAFFH8GAAIQAAYIXxMsFwBjAQAQAAYIXxMsFwBjAQAAAA==.',['月影']='月影沐枫:BAAAKgAECgQIBAAAAA==.',['月隐']='月隐丶:BAAAKgAECgEIAQAAAA==.',['有点']='有点酷爽:BAAAKgAECggICAAAAA==.',['有言']='有言悦于耳边:BAABKgAECn8UAAIcAAgIjCG4DgBVAgAcAAgIjCG4DgBVAgAAAA==.',['未来']='未来终结者:BAAAKgAECgQIBAAAAA==.',['杖平']='杖平天下:BAAAKgADCgQIBAAAAA==.',['来口']='来口冰阔落:BAABKgAECn8qAAIRAAgIESN6FwC5AgARAAgIESN6FwC5AgAAAA==.',['杨教']='杨教授的愛:BAABKgAFFH8IAAISAAgIrRIhBgDJAQASAAgIrRIhBgDJAQAAAA==.',['杰哥']='杰哥丶:BAAAKgADCgQIBAAAAA==.',['東北']='東北一米九丶:BAAAKgAECgcIDAAAAA==.',['枭姬']='枭姬:BAAAKgADCgEIAQAAAA==.',['染指']='染指悲伤:BAAAKgAECgYIBgAAAA==.',['桜流']='桜流:BAACKgAFFH8UAAIRAAQIwx6VOwD/AAARAAQIwx6VOwD/AAAqAAQKfywAAhEACAhaJKQSAMACABEACAhaJKQSAMACAAAA.',['楠楠']='楠楠:BAAAKgAECgMIAwAAAA==.',['横空']='横空的末世:BAAAKgAECgIIAgAAAA==.',['樱茔']='樱茔:BAAAKgAFFAYIAgAAAA==.',['橙色']='橙色预警:BAAAKgAECggIBgAAAA==.',['歡喜']='歡喜:BAABKgAFFH8MAAIRAAYIISGgEQDRAQARAAYIISGgEQDRAQAAAA==.',['死亡']='死亡丶地球:BAABKgAFFH8IAAIOAAYIiw7dEwADAQAOAAYIiw7dEwADAQAAAA==.',['殤之']='殤之殺戮:BAABKgAECn8XAAIRAAgIaxWChgCKAQARAAgIaxWChgCKAQAAAA==.',['水月']='水月小术:BAAAKgADCggICAAAAA==.',['永冻']='永冻乄黎明:BAAAKgAECgEIAQAAAA==.',['沁泉']='沁泉摘晨露丶:BAABKgAFFH8FAAMUAAUImhpAEwDQAAAUAAQInhtAEwDQAAASAAEIxCKjTABaAAAAAA==.',['沃尼']='沃尼犸:BAABKgAECn8dAAIRAAgINCPhKQB2AgARAAgINCPhKQB2AgAAAA==.',['沸魂']='沸魂:BAAAKgADCgEIAQAAAA==.',['法可']='法可鱿里:BAAAKgADCgQIBAAAAA==.',['泰兰']='泰兰物语:BAAAKgADCggIEgAAAA==.',['泷谷']='泷谷源治:BAABKgAECn8ZAAIYAAgICiEgDwCNAgAYAAgICiEgDwCNAgAAAA==.',['浅伤']='浅伤丶眠:BAABKgAFFH8ZAAIUAAQIiB8NDQADAQAUAAQIiB8NDQADAQAAAA==.',['浅析']='浅析:BAAAKgAECgIIAgAAAA==.',['浅郄']='浅郄:BAAAKgAECgUIBQAAAA==.',['浮世']='浮世記夢:BAAAKgAECgcICAABKgAFFAgIDwAeAC4bAA==.',['海棠']='海棠落梨花开:BAAAKgAECgMIAwAAAA==.',['涅圣']='涅圣:BAAAKgAECgEIAQAAAA==.',['涅槃']='涅槃重生:BAAAKgAFFAQIBAAAAA==.',['淡漠']='淡漠的悲伤:BAABKgAFFH8HAAINAAYI1BVdFAB4AQANAAYI1BVdFAB4AQAAAA==.',['潇尹']='潇尹璟柃艿:BAAAKgAFFAgIAgAAAA==.',['灬骑']='灬骑士灬:BAAAKgAECgEIAQAAAA==.',['灭杀']='灭杀姬:BAAAKgADCgEIAQAAAA==.',['灰色']='灰色丶预言:BAAAKgADCggIEAAAAA==.灰色预言:BAAAKgADCgQIBAAAAA==.',['灵踪']='灵踪:BAAAKgAFFAgIBAAAAA==.',['灼眼']='灼眼的夏侯惇:BAABKgAFFH8GAAIRAAYIvxq4FgCmAQARAAYIvxq4FgCmAQAAAA==.',['炙魂']='炙魂:BAAAKgADCgEIAQAAAA==.',['為誰']='為誰戰天涯:BAAAKgAECgYIDQAAAA==.',['烈焰']='烈焰丶冰訫:BAAAKgAECgcIEgAAAA==.',['烟雨']='烟雨戏江南:BAAAKgAFFAIIAgAAAA==.烟雨满江南:BAAAKgAECgMIBQAAAA==.',['焦喘']='焦喘的邦桑迪:BAAAKgAECggIEAAAAA==.',['照此']='照此莲花:BAAAKgAECgYIEgAAAA==.',['熊哥']='熊哥你好吗:BAABKgAFFH8IAAICAAgINQihCgC2AQACAAgINQihCgC2AQAAAA==.',['牛德']='牛德狠丶:BAACKgAFFH8RAAQMAAQICxvJFQDzAAAMAAMICxvJFQDzAAAfAAQIMwRhBwBUAAANAAEIPA9nXABCAAAqAAQKfyoABAwACAgbIAwQACoCAAwACAgbIAwQACoCAA0ACAihGQ41AOYBAB8ABwjZDRIgAOgAAAAA.',['犀利']='犀利犀利:BAAAKgAECgIIAgAAAA==.',['狂舞']='狂舞手术刀:BAABKgAFFH8GAAIRAAYIdRudIQBnAQARAAYIdRudIQBnAQAAAA==.',['狼之']='狼之心迹:BAAAKgADCgYIBgAAAA==.',['狼女']='狼女:BAAAKgADCggICQAAAA==.',['玩偶']='玩偶好萌啊:BAABKgAFFH8KAAMGAAYIkBKxFAA9AQAGAAYIPRGxFAA9AQAHAAQIMBVmNwC5AAAAAA==.',['珍妮']='珍妮弗:BAAAKgAFFAQIBAAAAA==.',['琦梦']='琦梦:BAABKgAFFH8JAAIXAAMI/gW6IgBuAAAXAAMI/gW6IgBuAAAAAA==.',['琪安']='琪安娜丶月影:BAAAKgAFFAMIBAAAAA==.',['甄姬']='甄姬丶:BAAAKgAECgEIAQAAAA==.',['甘霖']='甘霖嬢:BAAAKgAECgQIBAAAAA==.',['电动']='电动小野野:BAABKgAFFH8GAAITAAYI6RnHBACXAQATAAYI6RnHBACXAQAAAA==.',['男女']='男女人:BAAAKgADCgEIAQAAAA==.',['画地']='画地为牢:BAAAKgAECgUIBQAAAA==.',['矮搓']='矮搓穷:BAAAKgAECgUIBwAAAA==.',['神圣']='神圣的光辉:BAAAKgADCggICAAAAA==.',['程导']='程导:BAAAKgAECgMIBAAAAA==.',['突然']='突然的怀念:BAAAKgADCgEIAQAAAA==.',['第一']='第一熊:BAAAKgAECgQIBAAAAA==.',['粗鄙']='粗鄙之人:BAAAKgAECgcIBgAAAA==.',['粥阿']='粥阿粥:BAABKgAFFH8KAAIcAAQIRySXCQDoAAAcAAQIRySXCQDoAAABKgAFFAgIFAAcACcUAA==.',['糸肀']='糸肀:BAABKgAFFH8GAAIcAAYIAgapFgAAAQAcAAYIAgapFgAAAQAAAA==.',['紫日']='紫日:BAABKgAFFH8SAAIHAAMIMxUWLgDQAAAHAAMIMxUWLgDQAAAAAA==.',['紫水']='紫水晶丶:BAAAKgAECggICwAAAA==.',['紫罗']='紫罗幻灵:BAABKgAECn8UAAIHAAgIwxlLRwDfAQAHAAgIwxlLRwDfAQAAAA==.',['纪念']='纪念逝去的你:BAABKgAECn8WAAMTAAgIox/+FgBIAgATAAgIRx7+FgBIAgACAAgIcB2rFQBFAgAAAA==.',['绯梦']='绯梦:BAAAKgADCgIIAgAAAA==.',['缭雪']='缭雪姬:BAAAKgADCgEIAQAAAA==.',['网瘾']='网瘾少女:BAAAKgAFFAgIAgAAAA==.',['网络']='网络鸟人:BAAAKgADCggICAAAAA==.',['老子']='老子是斯文人:BAAAKgAECgEIAQAAAA==.',['老张']='老张爱洗澡:BAABKgAFFH8HAAIRAAQIshGgHwDqAAARAAQIshGgHwDqAAAAAA==.',['老约']='老约翰:BAABKgAFFH8GAAIRAAYIHxXtiABEAAARAAYIHxXtiABEAAAAAA==.',['老练']='老练的假冲动:BAACKgAFFH8IAAIMAAIIkgvZLgBdAAAMAAIIkgvZLgBdAAAqAAQKfxoAAgwACAjyFoIbAMEBAAwACAjyFoIbAMEBAAAA.',['肉球']='肉球:BAABKgAFFH8LAAISAAMI0wRCPwCLAAASAAMI0wRCPwCLAAAAAA==.',['股二']='股二蛋:BAAAKgAECgMIBAAAAA==.',['臨淵']='臨淵:BAAAKgAECgYIBgAAAA==.',['芜罗']='芜罗亭魔梨威:BAACKgAFFH8MAAMcAAQIawvBEQC0AAAcAAMIawvBEQC0AAAbAAMI4gMoIABkAAAqAAQKfyoABBwACAipG2EVACcCABwACAipG2EVACcCAAQAAQiRB4WUACsAABsAAQihDFNlACkAAAAA.',['芜薇']='芜薇小草芯:BAAAKgADCgQIBgAAAA==.',['芥末']='芥末糖芯:BAAAKgADCggICgAAAA==.',['花无']='花无缺:BAAAKgAFFAgIBAAAAA==.',['苍穹']='苍穹之歌:BAAAKgAECgQIBAAAAA==.',['荒野']='荒野丶地球:BAAAKgAECgQIBAAAAA==.荒野之息:BAAAKgAECgIIBAAAAA==.',['莫想']='莫想:BAAAKgAECggIEQAAAA==.',['莱雅']='莱雅娜:BAAAKgADCggIEAAAAA==.',['菊之']='菊之爆:BAAAKgAFFAQIAgAAAA==.',['萌总']='萌总:BAAAKgADCgQIBgAAAA==.',['萝莉']='萝莉丶牛:BAAAKgAECgEIAQAAAA==.',['萨满']='萨满技师:BAAAKgAECgIIAgAAAA==.',['蔚蓝']='蔚蓝海魂:BAAAKgAECggICAAAAA==.',['薩菈']='薩菈塔斯:BAAAKgAECgEIAQAAAA==.',['虚空']='虚空之遗:BAAAKgAECgUIBQAAAA==.虚空辉光:BAAAKgAECggIDgAAAA==.',['虬魂']='虬魂:BAAAKgADCgEIAQAAAA==.',['蛋蛋']='蛋蛋都碎咯:BAAAKgADCggICAAAAA==.',['蜀道']='蜀道山丶:BAABKgAFFH8FAAIKAAUIhA0UCAAqAQAKAAUIhA0UCAAqAQAAAA==.',['血蹄']='血蹄踏花开:BAAAKgAECggICgAAAA==.',['被抢']='被抢了:BAABKgAFFH8GAAIIAAYIyg5ODQB6AQAIAAYIyg5ODQB6AQAAAA==.',['西门']='西门富贵:BAAAKgAFFAIIAgAAAA==.',['角落']='角落玩泥巴:BAABKgAFFH8JAAIZAAUIhhrHBwA/AQAZAAUIhhrHBwA/AQAAAA==.',['许哆']='许哆哆:BAABKgAECn8UAAIZAAYI3wv1aAAGAQAZAAYI3wv1aAAGAQAAAA==.',['豌梪']='豌梪射手:BAAAKgADCggICAAAAA==.',['费七']='费七万:BAAAKgAFFAIIAgABKgAFFAgIBAALAAAAAA==.',['费主']='费主任:BAAAKgAECgYIBgAAAA==.',['赤氺']='赤氺断:BAACKgAFFH8FAAIYAAUI3hLfEQA6AQAYAAUI3hLfEQA6AQAqAAQKfxcAAwUACAiEF8s3AOMAABgABQgzE+pVAAMBAAUABQgWF8s3AOMAAAAA.',['超甜']='超甜猪猪奶茶:BAAAKgAECgcICgAAAA==.',['超级']='超级牛牛:BAAAKgADCggICAAAAA==.',['跑跑']='跑跑侠:BAAAKgAECgMIBQAAAA==.',['转瞬']='转瞬即逝:BAAAKgADCggICAAAAA==.',['转评']='转评赞:BAAAKgAECgYIDAAAAA==.',['达雯']='达雯西:BAAAKgAFFAIIAgAAAA==.',['还我']='还我初液:BAAAKgAFFAcIAQAAAA==.',['进击']='进击的牛牛:BAABKgAFFH8GAAIOAAYIRRChEwAEAQAOAAYIRRChEwAEAQAAAA==.',['迪西']='迪西:BAAAKgADCgMIAwAAAA==.',['追求']='追求完美:BAABKgAECn8oAAMFAAgIpg8hLABaAQAFAAgISQ4hLABaAQAYAAYIsw6MTQAsAQAAAA==.',['遗魂']='遗魂:BAAAKgADCgEIAQAAAA==.',['郁闷']='郁闷中:BAAAKgADCggIEAAAAA==.',['银狐']='银狐孤雀:BAAAKgAECggIDwAAAA==.',['锅巴']='锅巴熊猫:BAABKgAFFH8FAAIKAAMINQMmKQB6AAAKAAMINQMmKQB6AAAAAA==.',['锋锋']='锋锋:BAAAKgADCgcIBwAAAA==.',['阿克']='阿克萌德:BAAAKgADCgEIAQAAAA==.',['阿梅']='阿梅达物语:BAAAKgAFFAEIAQAAAA==.',['随便']='随便拽拽:BAAAKgAECgQIBQAAAA==.随便玩的老杨:BAABKgAECn8YAAISAAgICRkgMAC4AQASAAgICRkgMAC4AQAAAA==.随便盖姚明:BAAAKgAFFAQIBAAAAA==.',['隔壁']='隔壁寂寞老王:BAAAKgAECgMIAwAAAA==.',['雪莉']='雪莉露诺姆:BAAAKgADCgUIBgAAAA==.',['雷弗']='雷弗斯:BAAAKgADCgIIAgAAAA==.',['雷雨']='雷雨岚牙:BAAAKgAFFAEIAQAAAA==.',['雷霆']='雷霆嘎巴:BAAAKgADCgYIBgAAAA==.雷霆索尔:BAAAKgAECgUIBQAAAA==.',['霜小']='霜小猪:BAAAKgAFFAQIBAAAAA==.',['青春']='青春翻涌成她:BAACKgAFFH8FAAMBAAIIEh8tIwCfAAABAAIIEh8tIwCfAAATAAEIXiBPGwBTAAAqAAQKfyMAAwEACAjMI3cOAKMCAAEACAiXI3cOAKMCABMAAghBJctIAMkAAAAA.',['青雀']='青雀衔落花:BAAAKgADCgMIAwAAAA==.',['静音']='静音丶:BAAAKgAECggICAAAAA==.',['非常']='非常小虾米:BAAAKgAFFAQIAwAAAA==.',['鞠婧']='鞠婧祎:BAAAKgAECgQIBQAAAA==.',['風丶']='風丶怒:BAAAKgAECggIDgAAAA==.',['风的']='风的记忆:BAABKgAFFH8RAAMMAAYIyAhuEwAEAQAMAAYIyAhuEwAEAQANAAQIRxCaHADMAAAAAA==.',['风起']='风起叶落:BAAAKgAFFAYIBAAAAA==.',['飓风']='飓风之牛:BAAAKgAECgYICAAAAA==.',['飞驰']='飞驰:BAAAKgAFFAIIBAAAAA==.',['香蕉']='香蕉芭喇:BAAAKgADCgMIAwAAAA==.',['鱼子']='鱼子酱:BAAAKgAECgMIAwAAAA==.',['鱼摆']='鱼摆摆了不起:BAABKgAFFH8MAAMNAAYI6Rc5FwBfAQANAAYI6Rc5FwBfAQAMAAYIQAclEwAGAQABKgAFFAgIBAALAAAAAA==.',['鹿鹿']='鹿鹿:BAAAKgAECgYIBgAAAA==.',['麒丨']='麒丨麟:BAAAKgADCgIIAgAAAA==.',['黑皮']='黑皮体育生:BAABKgAECn8dAAIQAAgIsRxEIAATAgAQAAgIsRxEIAATAgAAAA==.',['鼓小']='鼓小浅:BAABKgAFFH8GAAIRAAQIxxEvHgDtAAARAAQIxxEvHgDtAAAAAA==.',['龙敖']='龙敖天赢麻辣:BAAAKgAECgcICgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end