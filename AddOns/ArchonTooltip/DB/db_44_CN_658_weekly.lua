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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','DemonHunter-Havoc','Mage-Frost','Mage-Arcane','Warrior-Fury','Paladin-Protection','Paladin-Holy','Monk-Brewmaster','Priest-Holy','DemonHunter-Vengeance','Druid-Restoration','Druid-Guardian','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Hunter-Marksmanship','Unknown-Unknown','Warrior-Protection','Druid-Balance','Priest-Discipline','Priest-Shadow','Rogue-Assassination','Rogue-Subtlety','Warlock-Affliction','Monk-Mistweaver','DeathKnight-Blood','Mage-Fire','Shaman-Elemental','Evoker-Preservation','Rogue-Outlaw',}; local provider = {region='CN',realm='尘风峡谷',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akira:BAAALAAFFAIIAgAAAA==.',Al='Allroll:BAABLAAFFH8JAAIBAAMIGA6JYQCKAAABAAMIGA6JYQCKAAAAAA==.',Am='Amelia:BAABLAAFFH8NAAMBAAQIzRmjGwBGAQABAAQIzRmjGwBGAQACAAIIXQgfFQCDAAAAAA==.',An='Angelo:BAAALAADCgMIAwAAAA==.',Ar='Ares:BAAALAAECgUIBQAAAA==.',Bd='Bdk:BAACLAAFFH8IAAIDAAMIihASIADSAAADAAMIihASIADSAAAsAAQKfxoAAgMABwhGH6NJAGACAAMABwhGH6NJAGACAAAA.',Co='Cokee:BAABLAAFFH8KAAIBAAQIOg/lHgArAQABAAQIOg/lHgArAQAAAA==.Cokei:BAABLAAFFH8GAAIDAAMIThcuGgDzAAADAAMIThcuGgDzAAAAAA==.',Dd='Ddoododo:BAAALAAFFAIIAgABLAAFFAgIHgABAKscAA==.',Di='Discovery:BAAALAADCgQIBAAAAA==.',Ed='Edith:BAABLAAFFH8GAAIEAAII+h13SwBNAAAEAAII+h13SwBNAAAAAA==.',Ge='Geetiiann:BAABLAAFFH8MAAMFAAYIKhzCBACDAQAGAAYIdRglHACpAQAFAAYIHBjCBACDAQAAAA==.',He='Heracles:BAABLAAECn8fAAIHAAgIDx1LEgBUAgAHAAgIDx1LEgBUAgAAAA==.',Hu='Hungrybabe:BAAALAAECgcICwAAAA==.',Lo='Lovechampagn:BAAALAAECgMICQAAAA==.',Ma='Magealz:BAABLAAFFH8GAAIGAAYIlRyAHwCYAQAGAAYIlRyAHwCYAQAAAA==.',Ni='Niam:BAABLAAFFH8JAAMIAAQIZxGqCQDKAAAIAAQIZxGqCQDKAAAJAAIIRgnYIgCAAAAAAA==.',Ns='Ns:BAAALAAFFAIIAgAAAA==.',Os='Osiris:BAACLAAFFH8RAAIDAAMIUh9JHADmAAADAAMIUh9JHADmAAAsAAQKfxYAAgMABgiEI/9dAC8CAAMABgiEI/9dAC8CAAAA.',Ot='Otz:BAABLAAFFH8+AAIKAAcIByDwBAAWAgAKAAcIByDwBAAWAgAAAA==.',Sa='Sagittãrius:BAAALAAECgYIDAAAAA==.Saxon:BAAALAAECgYIBgABLAAFFAYIFwALAOcTAA==.',So='Soulkill:BAAALAADCgQIBAAAAA==.Soulost:BAAALAAECggICwAAAA==.',St='Striderl:BAABLAAFFH8IAAIFAAgIegPJFABFAAAFAAgIegPJFABFAAAAAA==.',Th='Theaik:BAAALAAFFAQIBAAAAA==.',Ty='Ty:BAAALAADCgEIAQAAAA==.',Zi='Zimomo:BAAALAAFFAIIBAAAAA==.',['一个']='一个圣骑:BAAALAAECgMIBQAAAA==.',['一片']='一片圣光:BAAALAAECgYIBgAAAA==.',['不想']='不想做好人:BAAALAAECgYICQAAAA==.',['不扰']='不扰清梦:BAABLAAFFH8MAAIMAAQI6An+CgCdAAAMAAQI6An+CgCdAAAAAA==.',['不来']='不来了:BAAALAADCgQIBgAAAA==.',['专业']='专业咬人:BAAALAADCgYIBgAAAA==.',['丶夕']='丶夕語繁花:BAAALAAFFAIIBAAAAA==.',['丶微']='丶微笑丿:BAAALAAECgUIBQAAAA==.',['主体']='主体思想战神:BAAALAAECgUIBQAAAA==.',['丿乘']='丿乘偑破蒗丶:BAAALAAFFAIIAgAAAA==.',['丿美']='丿美妙丶:BAAALAAECgYIDAAAAA==.',['丿茉']='丿茉莉:BAAALAAECgYIBgAAAA==.',['五行']='五行缺德:BAAALAAECgYIBgAAAA==.',['亚莉']='亚莉莎的熊:BAAALAAFFAIIAgABLAAFFAcILgANAA4kAA==.',['亚里']='亚里士多德:BAAALAADCgMIAwAAAA==.',['伊利']='伊利牛牛:BAAALAAFFAIIAgAAAA==.',['伊拉']='伊拉罐:BAAALAAECgYICQAAAA==.',['伊无']='伊无宁:BAAALAAECgYIBgAAAA==.',['休息']='休息一下:BAAALAAECgIIAgAAAA==.',['何老']='何老爷:BAABLAAFFH8KAAIIAAMIKghuFQBMAAAIAAMIKghuFQBMAAAAAA==.',['你慢']='你慢慢飞:BAAALAADCgYIBgAAAA==.',['俺村']='俺村俺最乖:BAABLAAFFH8aAAIOAAYIvxjAAgBYAQAOAAYIvxjAAgBYAQAAAA==.',['儒雅']='儒雅随和:BAABLAAFFH8NAAIPAAQI/wjxQAClAAAPAAQI/wjxQAClAAAAAA==.',['克里']='克里斯开下门:BAACLAAFFH8iAAMQAAYIxxheJwB8AQAQAAUIBBdeJwB8AQARAAEIkyGMJABVAAAsAAQKfzAAAxAACAgOHSAoAKQCABAACAgOHSAoAKQCABEAAQjMG2c+AAAAAAAA.',['兔叽']='兔叽不乖:BAAALAAECgYICgAAAA==.',['八宝']='八宝粥:BAAALAADCgEIAQAAAA==.',['冰魄']='冰魄云渺:BAAALAAECgYIBgABLAAFFAgICAAJAIYYAA==.',['凡梦']='凡梦盛尘:BAAALAADCggICAAAAA==.',['刑诉']='刑诉法年:BAAALAAECgYIBQAAAA==.',['北极']='北极兽:BAABLAAFFH8GAAIPAAMIzxE2aQCRAAAPAAMIzxE2aQCRAAAAAA==.北极灵:BAABLAAFFH8QAAMBAAYICQzfMwBsAQABAAYICQzfMwBsAQACAAIIngJ9FgB0AAAAAA==.北极龍:BAAALAAFFAQIBAABLAAFFAgIDAALAJsMAA==.',['卟壞']='卟壞:BAABLAAFFH8LAAIGAAMIcQcxMQDGAAAGAAMIcQcxMQDGAAAAAA==.',['双刀']='双刀阿贷:BAAALAADCgEIAQAAAA==.',['双杀']='双杀小王子:BAAALAADCgEIAQAAAA==.',['口喝']='口喝的小鱼儿:BAAALAAECgYIDQAAAA==.',['可乐']='可乐加冰:BAAALAAECgYIBgAAAA==.',['史蒂']='史蒂芬周:BAAALAAECgUIBQAAAA==.',['叶轻']='叶轻轻:BAAALAAECgYIDAAAAA==.',['司晨']='司晨:BAAALAAECgYICAAAAA==.',['咸鱼']='咸鱼突刺:BAABLAAFFH8KAAISAAIIlB6hOQCNAAASAAIIlB6hOQCNAAAAAA==.',['哔哔']='哔哔叨斯基:BAAALAAECgYIDAAAAA==.',['哦好']='哦好:BAAALAADCgIIAgAAAA==.',['噢嘜']='噢嘜雷滴嘎嘎:BAABLAAFFH8dAAIPAAYI4R/bFQDkAQAPAAYI4R/bFQDkAQAAAA==.',['回留']='回留:BAABLAAECn8ZAAMPAAcIAyNKKgCvAgAPAAcIAyNKKgCvAgATAAYI3R5+MAACAgABLAAFFAIIBAAUAAAAAA==.',['囧囧']='囧囧有神:BAAALAADCggICAAAAA==.',['坏蛋']='坏蛋小蚂蚁:BAABLAAECn8UAAMJAAYIegh0KwDnAAAJAAYIegh0KwDnAAADAAQIyg24VgGDAAAAAA==.',['埒人']='埒人:BAABLAAFFH8GAAIPAAMI6ggIewBkAAAPAAMI6ggIewBkAAAAAA==.',['复仇']='复仇乄新:BAAALAAFFAIIBAAAAA==.',['夏日']='夏日微醺:BAAALAAECgYICQAAAA==.',['夕花']='夕花朝拾:BAAALAADCgQIBAAAAA==.',['多多']='多多嘟嘟:BAAALAAFFAEIAQAAAA==.',['多尔']='多尔锋:BAAALAAECgIIAgAAAA==.',['大帅']='大帅哥:BAABLAAFFH8GAAIVAAMI0A20IABzAAAVAAMI0A20IABzAAAAAA==.',['大漠']='大漠沙如雪:BAABLAAFFH8JAAIBAAQI4RQfLwDeAAABAAQI4RQfLwDeAAAAAA==.',['大牛']='大牛饼干泡水:BAACLAAFFH8GAAIWAAIIkAvSJAB+AAAWAAIIkAvSJAB+AAAsAAQKfyIAAxYABgiEGthAALEBABYABgiEGthAALEBAA4AAQjKAaQ+ABwAAAAA.',['大疯']='大疯无形:BAAALAADCgIIAgAAAA==.',['天不']='天不孤:BAAALAAECggIEgAAAA==.天不弃:BAABLAAECn8YAAISAAgIbiWtAwBLAwASAAgIbiWtAwBLAwAAAA==.',['天雪']='天雪神傲月:BAAALAAECgYIBgAAAA==.',['奶盖']='奶盖:BAABLAAFFH8IAAIBAAMIZQs9ZACDAAABAAMIZQs9ZACDAAAAAA==.',['姨十']='姨十三:BAAALAAECgYIBgAAAA==.',['宁姚']='宁姚:BAAALAAECgUIBgAAAA==.',['安娜']='安娜贝尔的鹿:BAABLAAFFH8QAAISAAMIdCNCEgAoAQASAAMIdCNCEgAoAQABLAAFFAcILgANAA4kAA==.',['密斯']='密斯特丶魔月:BAABLAAECn8ZAAIEAAgILQiquwBgAQAEAAgILQiquwBgAQAAAA==.',['小妞']='小妞嘟嘟:BAACLAAFFH8fAAMXAAUIjCWHAAAkAgAXAAUIjCWHAAAkAgAYAAMIERe2EQD6AAAsAAQKfzkAAxcACAiaJBcBAD0DABcACAiaJBcBAD0DABgACAhcIhcKACUDAAEsAAUUBgghAAkAdR8A.',['小小']='小小吗喽:BAAALAAECgYICAABLAAFFAgIXgAJAGglAA==.小小满:BAAALAADCgYIBgAAAA==.',['小美']='小美:BAAALAAFFAIIAgAAAA==.',['小那']='小那星:BAAALAAECgcIDQAAAA==.',['岔风']='岔风:BAAALAAECggICAABLAAFFAgIAwAUAAAAAA==.',['巧乐']='巧乐兹:BAAALAAECgQIBAAAAA==.',['希拉']='希拉穆仁:BAAALAAECgYIDAAAAA==.',['希薇']='希薇娅的企鹅:BAAALAADCgIIAgABLAAFFAcILgANAA4kAA==.',['幽神']='幽神罗喉:BAAALAAECgYIBwABLAAFFAgICAAJAIYYAA==.',['影舞']='影舞小者:BAACLAAFFH8XAAITAAYIUxSDBQB/AQATAAYIUxSDBQB/AQAsAAQKfygAAhMABwjTHo4iAFYCABMABwjTHo4iAFYCAAAA.',['思念']='思念:BAAALAAECgMIAwAAAA==.',['思辰']='思辰:BAAALAAECgQIBAAAAA==.',['悔的']='悔的很冲动:BAAALAADCgEIAQAAAA==.',['悟灭']='悟灭:BAAALAAECgYIDwAAAA==.',['悟风']='悟风:BAAALAAECgUICAAAAA==.',['愤怒']='愤怒的乐高:BAAALAAECgYICwAAAA==.',['憨厚']='憨厚亡者:BAAALAAFFAIIAgAAAA==.',['懒洋']='懒洋洋:BAAALAADCgcIBwAAAA==.',['我叫']='我叫儍小蔓:BAAALAAECgYIDAAAAA==.我叫奶踢:BAAALAAECggICAABLAAFFAgINwAIABIkAA==.',['我就']='我就要狂战斧:BAAALAADCgIIAgAAAA==.',['我想']='我想捡垃圾:BAABLAAFFH8QAAMZAAUIeRGbDABEAQAZAAUIeRGbDABEAQAaAAEICgTrFwA3AAAAAA==.',['我抗']='我抗不住:BAABLAAFFH8UAAMCAAIIQSRYDACzAAACAAIIQSRYDACzAAABAAEInwpIoABBAAAAAA==.',['战死']='战死尸鬼:BAAALAAECgYIBgABLAAFFAgICAAJAIYYAA==.',['折木']='折木一茶:BAACLAAFFH81AAQQAAgIMB5gCQAqAgAQAAgI4hlgCQAqAgAbAAMIzx7XAgAVAQARAAMIvQ7mCADAAAAsAAQKfycABBAACAjPIk8cAOECABAACAhHIk8cAOECABsAAwgjF/UfAPEAABEAAwh8HX9iAO0AAAAA.',['拾玖']='拾玖:BAABLAAFFH8GAAIHAAIINwWVWgA7AAAHAAIINwWVWgA7AAABLAAFFAMIBwAEAKgNAA==.',['控叽']='控叽不住记叽:BAAALAAECgYICgAAAA==.',['撕裂']='撕裂灵魂:BAAALAAECggICAAAAA==.',['擦伊']='擦伊拉妈妈:BAAALAAECgMIBQAAAA==.',['断筋']='断筋断到手:BAAALAAECgEIAQAAAA==.',['斯尼']='斯尼奇:BAAALAADCggICAAAAA==.',['无情']='无情贱客:BAAALAAECgEIAQAAAA==.',['星橙']='星橙:BAAALAAECgYIBgAAAA==.',['春天']='春天的童话:BAAALAAECgYIBgAAAA==.',['晚来']='晚来天:BAAALAAFFAIIAgAAAA==.',['暖魅']='暖魅:BAAALAAECgMIAwAAAA==.',['月光']='月光小白兔:BAABLAAECn8aAAIGAAgIPxCAXwDmAQAGAAgIPxCAXwDmAQABLAAFFAYIIQAJAHUfAA==.月光小笼包:BAAALAAECggIDgAAAA==.',['月影']='月影凌霜:BAAALAAECggICAAAAA==.',['月猫']='月猫猫:BAABLAAFFH8GAAIcAAMITiPrBwAnAQAcAAMITiPrBwAnAQAAAA==.',['月野']='月野兔:BAAALAADCgEIAQAAAA==.',['朝鲁']='朝鲁李:BAAALAAFFAIIAgAAAA==.',['木木']='木木:BAABLAAFFH8SAAILAAYIXwu2HgBVAQALAAYIXwu2HgBVAQAAAA==.',['木瓜']='木瓜吃多了:BAAALAAFFAIIBAAAAA==.',['朱雀']='朱雀云丹:BAAALAAECgYIBgABLAAFFAgICAAJAIYYAA==.',['李朝']='李朝鲁:BAAALAAFFAIIAgAAAA==.',['杠上']='杠上开花:BAAALAAFFAIIBAAAAA==.',['桃乃']='桃乃木香萘:BAACLAAFFH8JAAIDAAQI8B1nDQCFAQADAAQI8B1nDQCFAQAsAAQKfxkAAgMACAg4JLsRAIACAAMACAg4JLsRAIACAAAA.',['梅莉']='梅莉莎的羊:BAACLAAFFH8eAAIBAAYImRm0GQBhAQABAAYImRm0GQBhAQAsAAQKfy4ABAEACAhRJBEQADIDAAEACAhRJBEQADIDAB0ABwjSE84hAHgBAAIAAQiYCOkkACwAAAEsAAUUBwguAA0ADiQA.',['梵啾']='梵啾啾:BAAALAAFFAYIBAAAAA==.',['欧师']='欧师傅:BAAALAAFFAIIAgAAAA==.',['死神']='死神的跟班:BAAALAAECgIIAgAAAA==.',['每月']='每月有几天:BAAALAADCgEIAQAAAA==.',['水無']='水無月流歌:BAAALAAFFAIIBAAAAA==.',['法十']='法十三:BAAALAAECgYIBgAAAA==.',['海之']='海之子:BAAALAAECgQIBwAAAA==.',['涅槃']='涅槃丨射手:BAAALAAECgYIBwAAAA==.涅槃丨霜:BAAALAAECgIIAgAAAA==.涅槃丨骑士:BAAALAAECgUICAAAAA==.',['混一']='混一色丶杠开:BAAALAAFFAYIAwAAAA==.',['混子']='混子骑:BAAALAAECgYIBgAAAA==.',['清单']='清单侠:BAAALAAECgYIBgAAAA==.',['温柔']='温柔一倒:BAAALAADCgQIBAAAAA==.',['温蕾']='温蕾萨:BAAALAAECggICAAAAA==.',['灬丨']='灬丨冲鋒丨灬:BAAALAAECgMIAwAAAA==.',['灰太']='灰太狼大王:BAAALAAECgYICAAAAA==.',['炽天']='炽天使:BAABLAAFFH8IAAILAAIIzgZtRQBgAAALAAIIzgZtRQBgAAAAAA==.',['烨星']='烨星:BAACLAAFFH8fAAMGAAYItRbTIwCGAQAGAAYItRbTIwCGAQAeAAEIXQD9DwAwAAAsAAQKfzUAAwYACAjUHp8lALcCAAYACAjUHp8lALcCAB4AAwigDVcVAKgAAAAA.',['然然']='然然:BAABLAAFFH8GAAIfAAYIBhJCHABeAQAfAAYIBhJCHABeAQABLAAFFAgIAQAUAAAAAA==.',['熊德']='熊德:BAABLAAFFH8HAAIBAAMIcRnOKQDyAAABAAMIcRnOKQDyAAAAAA==.',['爱哭']='爱哭的牛牛:BAABLAAFFH8dAAIOAAYI/B2NAQC7AQAOAAYI/B2NAQC7AQABLAAFFAgINwAIABIkAA==.',['牛肉']='牛肉嘟嘟肥:BAAALAAECgQIBAAAAA==.',['狂暴']='狂暴的巨牙:BAAALAAECgYICgAAAA==.',['狂野']='狂野小魔星:BAAALAAECggICQAAAA==.',['狐妖']='狐妖爱吃瓜:BAAALAAECgYICAAAAA==.',['猎龙']='猎龙者:BAABLAAFFH8JAAIPAAUIIhoHSgAjAQAPAAUIIhoHSgAjAQAAAA==.',['猛牛']='猛牛行天下:BAAALAAECgEIAQAAAA==.',['猪妹']='猪妹妹:BAAALAAECgYIBwAAAA==.',['猫十']='猫十三:BAABLAAECn8XAAIZAAgI9RsDEwCFAgAZAAgI9RsDEwCFAgAAAA==.',['王者']='王者叉叉:BAAALAAECgYIDAAAAA==.',['瞬狱']='瞬狱杀:BAAALAADCgIIAgAAAA==.',['知见']='知见立知:BAABLAAFFH8GAAIEAAYIrQCRZgA5AAAEAAYIrQCRZgA5AAAAAA==.',['硬粗']='硬粗弯长黑:BAABLAAECn8XAAINAAgIkhtIDgBvAgANAAgIkhtIDgBvAgAAAA==.',['神里']='神里绫华:BAAALAAFFAMIAwAAAA==.',['福乐']='福乐硬核:BAAALAAFFAIIBAAAAA==.',['秋刀']='秋刀鱼丶:BAABLAAFFH8HAAIGAAQIzwsJLgDYAAAGAAQIzwsJLgDYAAAAAA==.',['第八']='第八天的蝉:BAAALAADCgYIBgAAAA==.',['粉红']='粉红的嗠头:BAAALAAECgQIBAAAAA==.粉红的头龟:BAAALAAFFAIIAgAAAA==.',['纯粹']='纯粹菜鸟:BAABLAAFFH8SAAIPAAYIWBrKJgCXAQAPAAYIWBrKJgCXAQAAAA==.',['纽扣']='纽扣丢了:BAABLAAFFH8IAAILAAII1wStQAB0AAALAAII1wStQAB0AAAAAA==.',['绿豆']='绿豆粥:BAAALAAECgYIDAAAAA==.',['老衲']='老衲信佛:BAABLAAFFH8JAAISAAQIcA6yNQDOAAASAAQIcA6yNQDOAAAAAA==.',['聖阎']='聖阎王:BAABLAAFFH8JAAIDAAMIvxU2QwCLAAADAAMIvxU2QwCLAAAAAA==.',['背德']='背德者:BAABLAAFFH8JAAMQAAQIxBHWRADBAAAQAAQIxBHWRADBAAARAAEIyQlmLQBIAAAAAA==.',['胖仔']='胖仔:BAAALAAECgYIBgAAAA==.',['脾气']='脾气丶来了:BAAALAAECgYIBgAAAA==.',['艾米']='艾米莉娅:BAAALAAECgYIBgAAAA==.',['艾莉']='艾莉丝的仓鼠:BAACLAAFFH8SAAMEAAUILh2iJgBbAQAEAAUILh2iJgBbAQAMAAIITAbRFwBXAAAsAAQKfyAAAwwABggyG4kqAGMBAAQABghdFP6gAIoBAAwABgiXFYkqAGMBAAEsAAUUBwguAA0ADiQA.',['花小']='花小妖:BAAALAAECgYIBgAAAA==.',['莉莉']='莉莉丝的鱼:BAAALAADCgMIAwABLAAFFAcILgANAA4kAA==.',['莎琳']='莎琳娜的牛:BAACLAAFFH8uAAINAAcIDiQNAgDOAgANAAcIDiQNAgDOAgAsAAQKfy0AAw0ACAgfJA4RANMCAA0ACAgfJA4RANMCABYABgi+EZJZAFMBAAAA.莎琳娜的龙:BAABLAAFFH8hAAIgAAcIzR4DBgAkAgAgAAcIzR4DBgAkAgABLAAFFAcILgANAA4kAA==.',['莱斯']='莱斯亚:BAABLAAFFH8GAAMTAAIIABHhJgB6AAAPAAII6w84bgCBAAATAAIIYA7hJgB6AAAAAA==.',['菇凉']='菇凉爱吃鱼:BAAALAADCggICAAAAA==.',['菲克']='菲克纽斯:BAAALAAFFAIIBAAAAA==.',['萧楚']='萧楚:BAAALAAFFAIIAgAAAA==.',['落叶']='落叶新初:BAAALAAECgYIBgAAAA==.',['蓄意']='蓄意轰拳:BAAALAAECgYIAgAAAA==.',['薛迪']='薛迪凯是垃圾:BAACLAAFFH8KAAIDAAII3x4lKgC1AAADAAII3x4lKgC1AAAsAAQKfxUAAgMABwjhHxklAAICAAMABwjhHxklAAICAAAA.',['虚淮']='虚淮:BAAALAADCgEIAQAAAA==.',['行万']='行万理路:BAAALAAECgYICQAAAA==.',['西欧']='西欧灬之夏:BAAALAAECgYIBgAAAA==.',['要你']='要你命三代目:BAAALAAECgYIBgAAAA==.',['诗情']='诗情丶画意:BAAALAADCggICAAAAA==.',['谈情']='谈情:BAAALAAECgYIDAAAAA==.',['赫尔']='赫尔:BAACLAAFFH8OAAIBAAgIIApPWQCfAAABAAgIIApPWQCfAAAsAAQKfykAAgEACAh+HckRAFsCAAEACAh+HckRAFsCAAAA.',['起了']='起了毛球:BAAALAAFFAIIBAAAAA==.',['車路']='車路士:BAAALAAECgEIAQAAAA==.',['轩小']='轩小小新:BAAALAAFFAIIAwAAAA==.',['迦蓝']='迦蓝丶:BAABLAAFFH8HAAIEAAMIqA1ZQQCIAAAEAAMIqA1ZQQCIAAAAAA==.',['逆天']='逆天一粒丹:BAAALAAFFAIIAgAAAA==.',['遠坂']='遠坂丶凛:BAAALAAECgUIBQABLAAECggICQAUAAAAAA==.',['部落']='部落奸细:BAACLAAFFH8SAAMhAAUI/xQ3AgAzAQAhAAUICRE3AgAzAQAaAAMIpg65DQCdAAAsAAQKfxUAAiEABghNIskFAF4CACEABghNIskFAF4CAAAA.',['银联']='银联:BAAALAAECgQIBAAAAA==.',['锁甲']='锁甲已废:BAACLAAFFH8JAAISAAMIKgp1TgB/AAASAAMIKgp1TgB/AAAsAAQKfxsAAhIABggSD0ZWAAQBABIABggSD0ZWAAQBAAAA.',['阿凌']='阿凌:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔萨新:BAAALAAFFAIIBAAAAA==.',['阿斯']='阿斯尔:BAABLAAECn8WAAISAAYI2xtcWwDUAQASAAYI2xtcWwDUAQAAAA==.',['陆雪']='陆雪琪:BAAALAAECgIIAgAAAA==.',['隐藏']='隐藏姓名:BAAALAAECgMIAwAAAA==.',['雪乃']='雪乃缨叶:BAAALAAECgYIBgAAAA==.',['雲影']='雲影映晕:BAAALAAECgYIBgAAAA==.',['零宝']='零宝:BAACLAAFFH8hAAIJAAYIdR99BgArAgAJAAYIdR99BgArAgAsAAQKfzcAAwkACAirIggKANUCAAkACAirIggKANUCAAMACAhGFBAuANsBAAAA.',['零魂']='零魂乄惊雪:BAAALAAECggICAAAAA==.',['风中']='风中女王:BAAALAAECgMIAwAAAA==.',['风格']='风格和:BAAALAAECgYICQAAAA==.',['风茫']='风茫茫:BAAALAAECggICQAAAA==.',['风车']='风车骑士:BAAALAAECggICAAAAA==.',['马哥']='马哥你好:BAABLAAFFH8MAAIFAAQI/RrZCAD9AAAFAAQI/RrZCAD9AAAAAA==.',['骇人']='骇人恶兽:BAAALAAECgYIBgABLAAFFAgICAAJAIYYAA==.',['鹰眼']='鹰眼:BAAALAADCgQIBAAAAA==.鹰眼凯思卓:BAABLAAECn8dAAITAAgItBPsCgCkAQATAAgItBPsCgCkAQABLAAFFAYIIQAJAHUfAA==.',['黑悟']='黑悟空:BAAALAADCgYIBgAAAA==.',['黑暮']='黑暮:BAAALAAFFAMIAgAAAA==.',['龙之']='龙之召唤:BAAALAAFFAgIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end