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
 local lookup = {'Warrior-Protection','Warrior-Fury','Rogue-Subtlety','Rogue-Outlaw','Rogue-Assassination','Shaman-Restoration','Shaman-Elemental','Priest-Shadow','Priest-Holy','Priest-Discipline','Paladin-Retribution','Paladin-Protection','Mage-Frost','Evoker-Preservation','Evoker-Devastation','DemonHunter-Havoc','Unknown-Unknown','Hunter-BeastMastery','Monk-Brewmaster','Druid-Balance','Druid-Restoration','Warlock-Destruction','Paladin-Holy','Hunter-Marksmanship','Mage-Arcane','Warlock-Affliction','Monk-Windwalker','DeathKnight-Frost','Warrior-Arms',}; local provider = {region='CN',realm='巴纳扎尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Anyilunye:BAAALAAECgYIEgAAAA==.',At='Attlanta:BAAALAAECgYICQAAAA==.',Bi='Biuabiu:BAAALAAECgYIBgAAAA==.',Br='Brbazinga:BAAALAAECgYICAAAAA==.',Co='Cosraven:BAAALAAECgMIAwAAAA==.',Fa='Fairy:BAAALAAFFAIIAwAAAA==.Fallangle:BAAALAAECggIBgAAAA==.',Fr='Freaksoldier:BAABLAAECn8dAAMBAAYIRCDPMADPAQABAAUI9CDPMADPAQACAAYI3xy5NQCCAQAAAA==.Freakwarlock:BAAALAAECgEIAQAAAA==.Freaky:BAAALAAECgYIBgAAAA==.Freakydoom:BAAALAAECggIEwAAAA==.Freakydragon:BAAALAAECgUICQAAAA==.Freakyfreaky:BAAALAAECggIDAAAAA==.Freakyfriday:BAAALAAECgQIBAAAAA==.Freakyhunter:BAAALAAECgYIDAAAAA==.Freakymonday:BAABLAAECn8aAAQDAAgIuhmPBAAUAgADAAgIURmPBAAUAgAEAAQInxTAEwALAQAFAAMIKxMoVADRAAAAAA==.Freakymoon:BAABLAAECn8ZAAMGAAgIaBMwNwCAAQAGAAgIaBMwNwCAAQAHAAUIUxyNLABkAQAAAA==.Freakypastor:BAABLAAECn8VAAQIAAgIbBfUFwCPAQAIAAcIyhbUFwCPAQAJAAYIzReWewALAQAKAAEI9BKpHQA5AAAAAA==.Freakytoday:BAAALAAECgcICAAAAA==.Freakyweek:BAABLAAECn8gAAMLAAgIDCE3IADxAgALAAgI4SA3IADxAgAMAAYIAhxpEQCaAQAAAA==.',Go='Gourdboy:BAAALAAECgYICwAAAA==.',Ki='Killbom:BAAALAAFFAIIAgAAAA==.',Ko='Kooiki:BAAALAADCgYIBgAAAA==.',La='Lacusmt:BAAALAAECgMIAwAAAA==.',Le='Leeo:BAAALAAECgYIBgAAAA==.',Lp='Lpq:BAAALAAECgYIAQAAAA==.',Me='Messenger:BAAALAAECggIDAAAAA==.',Mi='Missdeanerys:BAAALAAECgMIAwAAAA==.Missing:BAABLAAFFH8KAAINAAIIWxliFQBEAAANAAIIWxliFQBEAAAAAA==.Missmisty:BAABLAAFFH8GAAIIAAYI6gKhGwC/AAAIAAYI6gKhGwC/AAAAAA==.',Ni='Nicoavril:BAAALAAFFAIIAgAAAA==.Nightraven:BAAALAAECgQIBAAAAA==.',No='Nosense:BAAALAADCgYIBgAAAA==.',Sh='Showfreely:BAAALAAECgYIEgAAAA==.',St='Starrysky:BAAALAAECgYIBgAAAA==.Statico:BAAALAAECgYICAAAAA==.',Sx='Sxby:BAAALAADCgIIAgAAAA==.',Ti='Tietong:BAAALAADCgIIAgAAAA==.',Wi='Windcall:BAACLAAFFH8wAAIOAAcIghrgBADDAQAOAAcIghrgBADDAQAsAAQKfxsAAg4ACAjeIWAQACoCAA4ACAjeIWAQACoCAAEsAAUUCAgkAA8ABhwA.',['一九']='一九九一:BAAALAAECgEIAQAAAA==.',['一圣']='一圣光守护一:BAAALAAECgcIBwAAAA==.',['一缕']='一缕晨曦:BAABLAAFFH8FAAIQAAUI/AWJNQDWAAAQAAUI/AWJNQDWAAAAAA==.',['一骑']='一骑当先:BAAALAAFFAIIAwAAAA==.',['万古']='万古长存:BAAALAAECgUIBQABLAAECgYIEwARAAAAAA==.',['不戒']='不戒灬德:BAAALAAECgQIBAAAAA==.不戒灬猎:BAAALAADCgYIBgAAAA==.',['丷十']='丷十三丷:BAAALAAFFAEIAQAAAA==.',['么么']='么么氵:BAAALAAECgIIAwAAAA==.',['乌勒']='乌勒尔:BAAALAADCgIIAgAAAA==.',['乌鸦']='乌鸦坐飞鸡:BAABLAAFFH8FAAILAAIIuxRZcwA8AAALAAIIuxRZcwA8AAAAAA==.',['乱世']='乱世骑士:BAAALAAECgEIAQAAAA==.',['二埋']='二埋汰:BAAALAADCggICAAAAA==.',['云尽']='云尽秋:BAAALAAECgYIBgAAAA==.',['今天']='今天大雪:BAAALAAECgYIEgAAAA==.',['会洗']='会洗衣服的鸡:BAAALAAECgIIAgAAAA==.',['伤魄']='伤魄:BAABLAAFFH8JAAISAAUIqhYCMwC+AAASAAUIqhYCMwC+AAAAAA==.',['你好']='你好紧张女士:BAABLAAFFH8GAAITAAYItB04AgBDAgATAAYItB04AgBDAgAAAA==.',['你的']='你的完美男人:BAAALAAECgYIEgAAAA==.',['佤莉']='佤莉拉:BAAALAAECgMIAwAAAA==.',['偑儛']='偑儛灬妖娆:BAAALAADCgIIAgAAAA==.',['做梦']='做梦尿一床:BAABLAAFFH8GAAMUAAYIMxdoFwAgAQAUAAUIvxdoFwAgAQAVAAEIbAoRWwA4AAAAAA==.',['傲决']='傲决:BAABLAAFFH8fAAISAAYIUxvPJgCXAQASAAYIUxvPJgCXAQAAAA==.',['傲娇']='傲娇:BAABLAAFFH8HAAIWAAII8Q3DRACSAAAWAAII8Q3DRACSAAAAAA==.',['傲武']='傲武:BAAALAAECgYIBgAAAA==.',['全能']='全能保安:BAAALAAFFAMIBAAAAA==.',['公爵']='公爵罗刹:BAAALAADCgIIAgAAAA==.',['冥邪']='冥邪公爵:BAAALAADCggIDwAAAA==.',['冰渊']='冰渊凌御者:BAAALAADCgYIBgAAAA==.',['刀刀']='刀刀烈火:BAACLAAFFH8HAAILAAIIlhLbXgBHAAALAAIIlhLbXgBHAAAsAAQKfxwAAwsACAgAGp58APIBAAsABwhYGZ58APIBABcABwg6BVFdANcAAAAA.',['划水']='划水冠军:BAAALAAECgYIBwAAAA==.',['利托']='利托里奥:BAAALAAECgYIBgAAAA==.',['别碰']='别碰我丸子头:BAABLAAECn8mAAINAAYIrBmXFQB+AQANAAYIrBmXFQB+AQAAAA==.',['十三']='十三:BAAALAAECgYIEAAAAA==.十三鸽鸽:BAAALAAFFAIIBAAAAA==.',['十二']='十二种蓝色:BAAALAAFFAMIAwAAAA==.',['十六']='十六夜:BAAALAAECgMIAwAAAA==.',['千升']='千升烈百木:BAAALAAECgYIDgAAAA==.',['午夜']='午夜的狂欢:BAAALAAECgYICQAAAA==.',['卸了']='卸了你的腿:BAAALAAECgQICQAAAA==.',['口卡']='口卡口察:BAACLAAFFH8LAAICAAMIdAxgOwCEAAACAAMIdAxgOwCEAAAsAAQKfxsAAgIACAhGGmMZABkCAAIACAhGGmMZABkCAAAA.',['口味']='口味:BAAALAAFFAMIAwAAAA==.口味丶:BAAALAADCgYIBwAAAA==.',['古一']='古一:BAAALAAECgYICwAAAA==.',['只杀']='只杀生不超度:BAAALAADCgYIBgAAAA==.',['合格']='合格:BAAALAAECgYIBgAAAA==.',['吉姆']='吉姆戈登:BAAALAAFFAIIAgAAAA==.',['向我']='向我开炮:BAAALAAECgIIAgAAAA==.',['呆毛']='呆毛儿憨憨:BAAALAADCgMIAwAAAA==.',['咕咕']='咕咕小萌德:BAAALAAECgYIEwAAAA==.',['哀辛']='哀辛诺斯:BAAALAADCgEIAQAAAA==.',['哒刃']='哒刃:BAABLAAECn8VAAMYAAYIKhDZcQAGAQASAAYIiQ6V7wBDAQAYAAYIlwvZcQAGAQAAAA==.',['哞哞']='哞哞向前冲:BAAALAADCgcIBwAAAA==.',['哥是']='哥是老中医:BAACLAAFFH8aAAIPAAYIUxVhDAAtAQAPAAYIUxVhDAAtAQAsAAQKfyMAAg8ACAhGHQ8NANgCAA8ACAhGHQ8NANgCAAAA.',['唯一']='唯一的选择:BAAALAAECgYICgAAAA==.',['嗳加']='嗳加吥加:BAAALAADCgYIBgAAAA==.',['国产']='国产专区:BAABLAAECn8cAAISAAgIER9YIQA1AgASAAgIER9YIQA1AgAAAA==.',['地瓜']='地瓜糖:BAAALAAECgUIBQAAAA==.',['坐牢']='坐牢角斗士:BAAALAADCgYIBgAAAA==.',['堕落']='堕落复仇者:BAAALAAECgYIDAAAAA==.',['夙兮']='夙兮:BAAALAAECgEIAQAAAA==.',['夙素']='夙素的小书包:BAAALAAECgcIBwAAAA==.',['夜夜']='夜夜笙歌:BAABLAAFFH8GAAIZAAYIKhGoDgDyAQAZAAYIKhGoDgDyAQAAAA==.',['夜里']='夜里欢:BAAALAAECgYIEQAAAA==.',['大佬']='大佬带带我呀:BAAALAAECggICwAAAA==.',['大爆']='大爆桶:BAAALAAECgUICQAAAA==.',['大魔']='大魔王小宇君:BAAALAAECgYICwAAAA==.',['天丨']='天丨涯:BAABLAAECn8XAAISAAcI1BQAbgBnAQASAAcI1BQAbgBnAQAAAA==.',['天勇']='天勇星宁宁:BAAALAAFFAYIBAAAAA==.',['天涯']='天涯:BAAALAAECgEIAQAAAA==.',['头上']='头上长了个牛:BAAALAADCgYIDAAAAA==.',['奔跑']='奔跑的扑老师:BAAALAAECgcIDQAAAA==.',['奥司']='奥司他韦:BAAALAAFFAIIAgAAAA==.',['奥莉']='奥莉給:BAAALAAECgYIDwAAAA==.',['妙影']='妙影:BAAALAAFFAIIAgAAAA==.',['婼夙']='婼夙:BAAALAAECgMIAwAAAA==.',['婼婼']='婼婼:BAAALAAECgYIBgAAAA==.',['孟菲']='孟菲斯灰熊:BAAALAADCggIGAAAAA==.',['守護']='守護之光:BAAALAAECgQIBAAAAA==.',['寒江']='寒江雪:BAAALAAFFAIIAgAAAA==.',['射手']='射手有点粘:BAAALAAFFAIIAgAAAA==.',['小乔']='小乔初嫁了了:BAAALAADCggICAAAAA==.',['小兰']='小兰:BAABLAAECn+nAAISAAgIPCYLDQA2AwASAAgIPCYLDQA2AwAAAA==.',['小子']='小子贼帥:BAAALAADCgIIAgAAAA==.',['小小']='小小世界:BAAALAADCgUIBQAAAA==.',['小帅']='小帅:BAAALAAFFAIIAgABLAAFFAgIEAASAMoXAA==.',['小李']='小李牛羊肉:BAAALAAECgYICwAAAA==.',['小梅']='小梅头:BAABLAAECn8XAAILAAYICBCB9AA8AQALAAYICBCB9AA8AQAAAA==.',['小老']='小老虎星冰乐:BAAALAAFFAYIAwAAAA==.小老虎麦旋风:BAAALAAECgYIBgAAAA==.',['小葉']='小葉子:BAAALAADCgQIBAAAAA==.',['小静']='小静儿:BAABLAAECn8YAAMNAAYI5xufEwCUAQANAAYI5xufEwCUAQAZAAYITwWYUQC9AAAAAA==.',['尘埃']='尘埃丨小犇犇:BAAALAAFFAIIAgAAAA==.',['就一']='就一恶魔:BAAALAAECgYIDAAAAA==.',['尼德']='尼德霍格:BAAALAADCgYIBgAAAA==.',['山河']='山河皆有美景:BAAALAAECgQIBAAAAA==.',['巫术']='巫术:BAAALAADCgIIAgAAAA==.',['张罗']='张罗人:BAABLAAFFH8WAAMJAAYIjxZqGQCFAQAJAAUIiRpqGQCFAQAIAAYIHgtmEgBHAQAAAA==.张罗大:BAAALAAECgYIDgAAAA==.张罗杰:BAAALAAFFAIIAgAAAA==.',['强壮']='强壮的小熊:BAAALAAECgYIBgAAAA==.',['很难']='很难拉得住:BAAALAAECgIIAgAAAA==.',['忧郁']='忧郁的天蓝色:BAAALAAECgYICQAAAA==.',['快乐']='快乐相伴:BAAALAAECgQIBAAAAA==.',['恋恋']='恋恋小奇:BAAALAAECgYIBgAAAA==.',['恶蝇']='恶蝇:BAAALAAECgYIEwAAAA==.',['恶魔']='恶魔丶吻:BAABLAAFFH8OAAICAAYI7xNyGwCLAQACAAYI7xNyGwCLAQAAAA==.恶魔天使:BAAALAAECgEIAQAAAA==.',['悟圣']='悟圣:BAAALAADCgEIAQAAAA==.',['愤怒']='愤怒的奶牛:BAAALAAFFAIIAgAAAA==.愤怒的约书亚:BAAALAAECgMIAwAAAA==.',['我以']='我以为丶:BAABLAAFFH8IAAILAAIISgpOcgA9AAALAAIISgpOcgA9AAAAAA==.',['我将']='我将无我:BAAALAAECgYICQAAAA==.',['我最']='我最桃燕灬你:BAAALAAECgYIDwAAAA==.',['我爱']='我爱你笑笑:BAAALAAECgEIAQAAAA==.',['战神']='战神不要爱:BAAALAADCgEIAQAAAA==.',['战骑']='战骑:BAAALAAECgYIDwAAAA==.',['戴安']='戴安娜:BAABLAAFFH8GAAIZAAYIzw36LwBHAQAZAAYIzw36LwBHAQAAAA==.',['手可']='手可摘星辰:BAABLAAECn8VAAMLAAgI5xcbWwA2AgALAAgI5xcbWwA2AgAMAAEI1ANafwAeAAABLAAFFAgIBgALAMsRAA==.',['扯机']='扯机吧蛋:BAAALAADCgIIAgAAAA==.',['拥抱']='拥抱虚空:BAAALAADCgMIAwAAAA==.',['掉进']='掉进水里的猫:BAAALAAECgYIBgABLAAFFAgIHQAWAPoXAA==.',['撒拉']='撒拉嘿:BAABLAAFFH8GAAIGAAYIVQ/8IgBGAQAGAAYIVQ/8IgBGAQAAAA==.',['无敌']='无敌的滋味:BAAALAAECgcIDQAAAA==.',['无畏']='无畏牛牛:BAAALAADCggICAAAAA==.',['春丽']='春丽来喽:BAAALAADCgEIAQAAAA==.',['春风']='春风十里:BAAALAAECggICAAAAA==.',['普罗']='普罗米西斯:BAAALAADCgEIAQAAAA==.',['晴天']='晴天雨天:BAAALAAECgIIAgAAAA==.',['暗天']='暗天雪:BAABLAAFFH8GAAILAAIIJAqYcAA+AAALAAIIJAqYcAA+AAAAAA==.',['暗影']='暗影圣龙:BAAALAADCgIIAgAAAA==.',['暗靈']='暗靈:BAABLAAECn+WAAMaAAgIbR4KDADyAQAWAAgIUhuFNgBgAgAaAAcIKxkKDADyAQAAAA==.',['暴打']='暴打小怪兽:BAAALAADCgIIAgAAAA==.',['暴走']='暴走妞妞:BAAALAAECgQIBAAAAA==.',['暴躁']='暴躁的小晨晨:BAAALAAECgMIAwAAAA==.',['暴风']='暴风大聪明:BAAALAAECgYIBgAAAA==.',['曾经']='曾经是仓库:BAAALAAECgUIBQAAAA==.',['月之']='月之怒:BAABLAAFFH8MAAIGAAYIuBpHFwCkAQAGAAYIuBpHFwCkAQAAAA==.',['月浅']='月浅歌:BAAALAADCggICwAAAA==.',['术小']='术小野:BAABLAAFFH8GAAIWAAYIUgKCQwDPAAAWAAYIUgKCQwDPAAAAAA==.',['极寒']='极寒:BAAALAAECgUIBQAAAA==.',['果涩']='果涩棠棠:BAAALAAECgMIAwAAAA==.',['枫之']='枫之紫月:BAAALAAECgEIAQAAAA==.',['柒月']='柒月流火丶:BAAALAAECgQIBAAAAA==.',['柠檬']='柠檬香:BAAALAAECgUIBQAAAA==.',['根本']='根本吃不饱:BAAALAADCgIIBAAAAA==.',['格格']='格格纳兰:BAAALAAFFAMIAwAAAA==.',['梦栀']='梦栀:BAAALAAECgYIBgAAAA==.',['樱桃']='樱桃小完犊子:BAAALAAECgUIBQAAAA==.',['欧冠']='欧冠皇马:BAABLAAFFH8OAAIbAAYIqQdtDgDFAAAbAAYIqQdtDgDFAAAAAA==.',['欺花']='欺花:BAAALAADCgMIAwAAAA==.',['正直']='正直的小晨晨:BAAALAAFFAEIAQAAAA==.',['此间']='此间的少年:BAAALAADCgQIBAAAAA==.',['武器']='武器戰:BAAALAAECgYIEgAAAA==.',['武装']='武装冰幻:BAAALAAECgUIBQAAAA==.',['残影']='残影幽灵:BAAALAAECgYIDgAAAA==.',['水水']='水水:BAAALAAECgUICQAAAA==.',['沙暴']='沙暴之旅:BAAALAAECgYIDAAAAA==.',['没事']='没事少说话:BAABLAAFFH8GAAIcAAIIFQjlgACGAAAcAAIIFQjlgACGAAAAAA==.',['洛阿']='洛阿:BAAALAADCggICAAAAA==.',['津门']='津门宇少爺:BAAALAAECgMIAwAAAA==.',['浪花']='浪花里面浪:BAAALAAECgIIAgAAAA==.',['浪里']='浪里跟儿浪:BAAALAAECggIDAAAAA==.',['海贼']='海贼王南絮:BAAALAAFFAIIAwAAAA==.海贼王雷神:BAABLAAFFH8GAAIGAAYI1g2QDAB2AQAGAAYI1g2QDAB2AQAAAA==.',['淡墨']='淡墨无殇:BAABLAAFFH8GAAIWAAYIWRGdMABWAQAWAAYIWRGdMABWAQAAAA==.',['港岛']='港岛妹妹:BAAALAADCggICAAAAA==.',['火腿']='火腿肠:BAAALAAECgIIAgAAAA==.',['火舞']='火舞斩月:BAAALAAECgQIBAAAAA==.',['然然']='然然:BAABLAAFFH8SAAIHAAYIUB2dCAD1AQAHAAYIUB2dCAD1AQABLAAFFAgIAQARAAAAAA==.',['熊猫']='熊猫宁宁:BAAALAAECgYIBgAAAA==.',['燃烧']='燃烧的梦星辰:BAAALAADCgEIAQAAAA==.',['爱上']='爱上流星雨:BAABLAAFFH8GAAISAAYIYwJqbQCHAAASAAYIYwJqbQCHAAAAAA==.',['爱慕']='爱慕吥慕:BAAALAADCgcIBwAAAA==.',['爸气']='爸气外漏:BAAALAADCgMIAwAAAA==.',['牛德']='牛德狠:BAAALAAFFAIIAgAAAA==.',['牛魔']='牛魔亡:BAAALAAECgYIBwAAAA==.',['狅暴']='狅暴战:BAAALAAECgMIAwAAAA==.',['狩不']='狩不首心:BAAALAAECgYIBgAAAA==.',['独此']='独此灬塟礼:BAAALAADCgEIAQAAAA==.',['猖狂']='猖狂的菟子:BAAALAADCgIIAgAAAA==.',['现在']='现在莴苣:BAAALAAECgQIBAAAAA==.',['甜糖']='甜糖豆:BAAALAAECgMIAwAAAA==.',['生命']='生命的滋味:BAAALAAECgYIDgAAAA==.',['田宇']='田宇潼:BAABLAAECn8WAAICAAYIcxAsTwAoAQACAAYIcxAsTwAoAQAAAA==.',['田里']='田里的香草:BAAALAAFFAIIAgAAAA==.',['疯狂']='疯狂八爪鱼:BAABLAAECn8YAAISAAgIoyKgDgCtAgASAAgIoyKgDgCtAgAAAA==.',['白水']='白水:BAAALAADCgYIBgAAAA==.',['百变']='百变鸟德:BAAALAAECgYIBgAAAA==.',['皮姆']='皮姆:BAAALAAECgQIBAAAAA==.',['皮爷']='皮爷:BAAALAAFFAQIBAAAAA==.',['皮蛋']='皮蛋丶:BAACLAAFFH8LAAIHAAMIyRlKFgABAQAHAAMIyRlKFgABAQAsAAQKfw4AAgcABwgHI6IjAJACAAcABwgHI6IjAJACAAAA.',['相当']='相当大气:BAAALAAECgEIAgAAAA==.',['盼秋']='盼秋来:BAAALAADCggICAAAAA==.',['碎空']='碎空:BAABLAAFFH8FAAIMAAMIGwgkFABVAAAMAAMIGwgkFABVAAAAAA==.',['祈福']='祈福圣尊:BAAALAAECgYICgAAAA==.',['神奇']='神奇动物:BAAALAAECgEIAQAAAA==.',['米丨']='米丨帅:BAAALAADCgQIAgAAAA==.',['米丶']='米丶露恩:BAAALAAECgYICAAAAA==.',['米迦']='米迦勒艾丝儿:BAAALAAECgQIBgAAAA==.',['素夙']='素夙:BAAALAAECgcIDAAAAA==.',['紫色']='紫色回来了:BAAALAADCgUIBQAAAA==.紫色职业第一:BAAALAAECgEIAQAAAA==.',['紫雾']='紫雾清晨:BAAALAAECgYIBwAAAA==.紫雾清羽:BAAALAAECgIIAgAAAA==.',['纯蓝']='纯蓝色:BAAALAAECggICAABLAAFFAgIHAAUAOIkAA==.',['给我']='给我啃它:BAAALAAECgYIBgAAAA==.',['绝世']='绝世骄傲:BAABLAAFFH8mAAILAAYIdBuLFACnAQALAAYIdBuLFACnAQAAAA==.',['绝情']='绝情咒:BAAALAAECgYIBgAAAA==.',['维她']='维她柠檬茶:BAAALAAFFAIIBAAAAA==.',['缘一']='缘一无恋:BAAALAAECgQIBAAAAA==.',['缚冰']='缚冰星术师:BAAALAAECgMIAwAAAA==.',['缚灵']='缚灵星术师:BAAALAAECgQIBAAAAA==.',['缺德']='缺德你就喊:BAAALAAECgYIDQAAAA==.',['罪亦']='罪亦罚:BAAALAADCggICAAAAA==.',['羊叫']='羊叫兽:BAAALAADCgYICAAAAA==.',['美味']='美味蟹黄堡:BAAALAAECggICAAAAA==.',['羽云']='羽云高歌:BAAALAAECgYIBgAAAA==.',['老技']='老技师:BAAALAAECgEIAQAAAA==.',['胖就']='胖就胖:BAAALAADCgQIBQAAAA==.',['舞虎']='舞虎:BAABLAAECn8bAAIcAAcIDxwyIgDwAQAcAAcIDxwyIgDwAQAAAA==.',['芥末']='芥末味鼻涕:BAAALAAECgQIDgAAAA==.',['苏歌']='苏歌:BAAALAAECgQIBAAAAA==.',['若离']='若离梦魇:BAAALAAECgQIBAAAAA==.',['萧雨']='萧雨圣斗士:BAAALAAECgUIBQAAAA==.',['萬伏']='萬伏高压灬電:BAAALAAECgQIBAAAAA==.',['蓝色']='蓝色蔓陀罗:BAAALAAECgYIDQAAAA==.',['蔷薇']='蔷薇之殇:BAAALAAFFAQIBAAAAA==.',['谁的']='谁的心忘带了:BAAALAAECgUIBgAAAA==.',['贤鱼']='贤鱼:BAABLAAFFH8PAAMFAAMIUBTnEwCmAAAFAAMITRDnEwCmAAADAAII1gmRGABsAAAAAA==.',['贫僧']='贫僧不戒:BAABLAAFFH8GAAITAAYIFwMOFgDTAAATAAYIFwMOFgDTAAAAAA==.',['贫战']='贫战不戒:BAAALAADCgYIBgAAAA==.',['贫萨']='贫萨不戒:BAAALAAECgEIAQAAAA==.',['赛芙']='赛芙蓉:BAACLAAFFH8PAAIBAAII6QyNLQA2AAABAAII6QyNLQA2AAAsAAQKfxUAAgEACAgXD61BAHwBAAEACAgXD61BAHwBAAAA.',['起舞']='起舞赤牛:BAABLAAFFH8OAAITAAgIUiAoAQDEAgATAAgIUiAoAQDEAgAAAA==.',['超级']='超级大混子:BAAALAAECgYIBQAAAA==.',['趴趴']='趴趴熊大哥:BAAALAAFFAIIAgABLAAFFAgIBgAcALoRAA==.',['转射']='转射屁屁:BAAALAAECgEIAQAAAA==.',['还有']='还有谁:BAAALAAECgYIEAAAAA==.',['途径']='途径你的盛放:BAAALAAECgYIDAAAAA==.',['遗忘']='遗忘后的哀伤:BAAALAAECgMIBgAAAA==.',['那些']='那些往事:BAABLAAFFH8HAAIdAAII/giLBgBzAAAdAAII/giLBgBzAAAAAA==.',['那大']='那大:BAAALAADCgQIBAAAAA==.',['郎来']='郎来拉:BAAALAADCgEIAQAAAA==.',['酱牛']='酱牛肉好吃:BAAALAADCggICAAAAA==.',['钱是']='钱是媳妇的:BAAALAADCgMIAwAAAA==.',['铁水']='铁水:BAAALAADCgMIAwAAAA==.',['银槍']='银槍小霸王:BAAALAAFFAQIBAAAAA==.',['閗戰']='閗戰聖佛:BAAALAAFFAIIAgAAAA==.',['闻所']='闻所未闻:BAABLAAECn8YAAICAAgIJR6YDgB6AgACAAgIJR6YDgB6AgAAAA==.',['阿兰']='阿兰:BAAALAAECgYICwAAAA==.',['阿狄']='阿狄琉斯:BAAALAAECgYIDgAAAA==.',['阿鲁']='阿鲁阿卓:BAAALAAECgIIAgAAAA==.',['陰陽']='陰陽師:BAAALAAECgYICgAAAA==.',['隂陽']='隂陽:BAAALAAFFAIIAgAAAA==.',['随便']='随便的随:BAABLAAFFH8GAAMJAAYInw7REgAaAQAJAAQImAnREgAaAQAIAAIITwZiHQCWAAAAAA==.',['难得']='难得糊涂:BAAALAAFFAIIAwAAAA==.',['零圈']='零圈窟窿洞:BAAALAADCgQIBAAAAA==.',['雷加']='雷加尔:BAAALAAECgYIBgAAAA==.',['風暴']='風暴壁垒:BAAALAADCgQIBAAAAA==.',['飞翔']='飞翔的兔子雨:BAAALAAECgQIBAAAAA==.',['首席']='首席恶魔:BAAALAADCgUIBQAAAA==.',['鸦鸦']='鸦鸦公主:BAABLAAFFH8RAAMJAAUIJRB2IABFAQAJAAUIJRB2IABFAQAIAAQI0RVdGQDnAAAAAA==.',['麦克']='麦克白:BAAALAADCgIIBAAAAA==.',['黑色']='黑色的云:BAAALAADCgEIAQAAAA==.',['黑锋']='黑锋:BAABLAAECn81AAIcAAgIlyLQBgDOAgAcAAgIlyLQBgDOAgAAAA==.',['黑靈']='黑靈:BAABLAAECn8mAAIEAAgI9CU1AAABAwAEAAgI9CU1AAABAwAAAA==.',['黑鱼']='黑鱼丸子丶:BAAALAAFFAYIAgAAAA==.',['龍小']='龍小寶:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end