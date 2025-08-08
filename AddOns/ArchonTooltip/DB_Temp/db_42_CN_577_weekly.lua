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
 local lookup = {'DeathKnight-Blood','DeathKnight-Unholy','Hunter-Marksmanship','Mage-Arcane','Warlock-Destruction','Warrior-Fury','Warlock-Affliction','Priest-Holy','Priest-Shadow','DemonHunter-Vengeance','DemonHunter-Havoc','Paladin-Retribution','Hunter-BeastMastery','Mage-Fire','Monk-Windwalker','Warrior-Protection','Shaman-Restoration','Evoker-Devastation','Evoker-Preservation','Shaman-Enhancement','DeathKnight-Frost','Warlock-Demonology','Rogue-Assassination','Paladin-Protection','Priest-Discipline','Warrior-Arms','Druid-Balance','Rogue-Subtlety','Druid-Guardian','Paladin-Holy','Mage-Frost','Evoker-Augmentation',}; local provider = {region='CN',realm='克苏恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Adios:BAABKgAECn8YAAMBAAgIWxhREQDnAQABAAgIWxhREQDnAQACAAgIUgBZ3QAOAAABKgAFFAgIEQADAPEhAA==.',Ak='Akm:BAABKgAFFH8IAAIEAAgIuQmQCQDSAQAEAAgIuQmQCQDSAQAAAA==.',Al='Alencon:BAAAKgAFFAYIAQAAAA==.Alksts:BAAAKgADCggICAABKgAFFAgIDgAFACobAA==.',An='Angelimy:BAAAKgAECgEIAgAAAA==.Antimage:BAAAKgAECgUIBQAAAA==.',Av='Avatar:BAAAKgADCgUIBQAAAA==.Avatart:BAABKgAFFH8GAAIGAAMIEwtLJwCvAAAGAAMIEwtLJwCvAAAAAA==.',Ba='Bamboos:BAAAKgAECggICgAAAA==.',Ca='Cakers:BAABKgAFFH8GAAIHAAYI8BzCAQCfAQAHAAYI8BzCAQCfAQAAAA==.Cakerx:BAABKgAFFH8GAAICAAYIAwNOEADwAAACAAYIAwNOEADwAAAAAA==.',Cl='Claire:BAABKgAFFH8MAAMIAAgIxQfaCQCFAQAIAAgIxQfaCQCFAQAJAAQI7gIiIwByAAAAAA==.',De='Deralanmao:BAABKgAECn8WAAMKAAgIDRtnEwAAAgAKAAgIIxlnEwAAAgALAAgIABpYMwDfAQAAAA==.',Dh='Dhmark:BAAAKgAECgUIBgAAAA==.',Dr='Drugdealer:BAAAKgAECgMIAwAAAA==.Druidmark:BAAAKgAECgIIAgABKgAFFAgIDgAMAL8dAA==.',Ha='Haken:BAAAKgAECggIEQAAAA==.',Hu='Huntermark:BAABKgAFFH8PAAINAAQIzB/AIAAJAQANAAQIzB/AIAAJAQABKgAFFAgIDgAMAL8dAA==.',Ju='Junzhuoll:BAABKgAFFH8KAAIOAAQIcRgKGADvAAAOAAQIcRgKGADvAAAAAA==.',Ko='Kont:BAAAKgAECgUIBQAAAA==.',Ma='Maox:BAAAKgAECgYIAgAAAA==.',Mi='Mihonobourbo:BAABKgAFFH8GAAIPAAYIyhnMBgCgAQAPAAYIyhnMBgCgAQAAAA==.',Mo='Mortis:BAAAKgAECgUIBgAAAA==.',Pe='Persephonet:BAABKgAFFH8HAAIIAAQIQAN2GgBsAAAIAAQIQAN2GgBsAAAAAA==.',Ri='Rider:BAAAKgADCggICAAAAA==.',Se='Semage:BAABKgAFFH8IAAIEAAgInyDUAQC9AgAEAAgInyDUAQC9AgAAAA==.Seul:BAAAKgADCgIIAgAAAA==.',So='Source:BAABKgAECn8lAAMQAAgIbRRwCwB7AQAQAAgIQhRwCwB7AQAGAAMI0Q3+JwClAAAAAA==.',St='Starmark:BAAAKgAFFAEIAQABKgAFFAgIDgAMAL8dAA==.',Ta='Tavins:BAABKgAFFH8IAAILAAQILRD5FwDkAAALAAQILRD5FwDkAAAAAA==.',['一万']='一万只蛆:BAAAKgAECggIEAAAAA==.',['一槍']='一槍送终:BAAAKgAECgcIDAAAAA==.',['三郎']='三郎永不低头:BAAAKgADCgMIAwAAAA==.',['上古']='上古法神:BAABKgAFFH8GAAIEAAYIoByQCgDCAQAEAAYIoByQCgDCAQAAAA==.上古领主:BAAAKgAECgMIAwAAAA==.',['丌月']='丌月柳溪:BAAAKgAFFAQIBAABKgAFFAgICAARAO0XAA==.',['不在']='不在狀態:BAAAKgADCggICAAAAA==.',['不忘']='不忘初心乄:BAACKgAFFH8FAAMNAAII6RbUMACXAAANAAIItRbUMACXAAADAAEISRamJwBEAAAqAAQKfx8AAg0ACAiIHQMxADACAA0ACAiIHQMxADACAAAA.',['不骑']='不骑马:BAAAKgAECgIIBAAAAA==.',['严查']='严查内鬼:BAACKgAFFH8ZAAMSAAgIASDfAQC4AQASAAgIASDfAQC4AQATAAII+RwiCgBMAAAqAAQKfyYAAhIACAixJVoCAPcCABIACAixJVoCAPcCAAAA.',['临时']='临时演员:BAAAKgAECggIDQAAAA==.',['丶像']='丶像星星:BAABKgAFFH8MAAIDAAgIdBYGDwBwAQADAAgIdBYGDwBwAQAAAA==.',['乙酰']='乙酰丙酮:BAAAKgAECgIIAgAAAA==.',['你先']='你先跑我殿后:BAAAKgAECgUIBQAAAA==.',['你往']='你往下瞅:BAAAKgAECgIIAgAAAA==.',['你的']='你的男神挑逗:BAABKgAFFH8GAAICAAQIeBwxCgAYAQACAAQIeBwxCgAYAQAAAA==.',['佩涅']='佩涅罗佩:BAABKgAFFH8FAAMTAAUI/BHOBgCbAAATAAQIewzOBgCbAAASAAEIYglmNABCAAAAAA==.',['侧漏']='侧漏:BAAAKgAFFAQIBAAAAA==.',['倾世']='倾世:BAABKgAECn8hAAMDAAgIcB3BGgAjAgANAAgIrRzBMgAqAgADAAgI1RrBGgAjAgAAAA==.',['光屁']='光屁灬股灬雷:BAABKgAECn8WAAIUAAgIihARCQCWAQAUAAgIihARCQCWAQAAAA==.',['八面']='八面威风:BAAAKgADCggICAAAAA==.',['再战']='再战:BAAAKgAECggIEAAAAA==.',['冰兮']='冰兮兮:BAAAKgAECggICAAAAA==.',['冰冷']='冰冷小心:BAAAKgAECggICAABKgAFFAgICAAGALMSAA==.',['冷蓝']='冷蓝溪若:BAAAKgAECgUIAgAAAA==.',['凄凉']='凄凉奶萨:BAAAKgAECgcIDgAAAA==.',['凛冬']='凛冬将至:BAAAKgADCgIIAgAAAA==.',['凯尔']='凯尔斯云:BAACKgAFFH8eAAINAAQIzxSjLwDMAAANAAQIzxSjLwDMAAAqAAQKfykAAg0ACAj2GYA5AL8BAA0ACAj2GYA5AL8BAAAA.',['剑扬']='剑扬:BAAAKgAECgUIBQAAAA==.',['剑气']='剑气:BAAAKgADCgEIAQAAAA==.',['动次']='动次打次:BAABKgAFFH8HAAIRAAMIZQncKAB8AAARAAMIZQncKAB8AAAAAA==.',['十一']='十一月:BAAAKgADCggICAAAAA==.',['卡尔']='卡尔萨斯:BAACKgAFFH8rAAIVAAQIwR33AgDxAAAVAAQIwR33AgDxAAAqAAQKfzwAAhUACAgTIcMEAJICABUACAgTIcMEAJICAAAA.',['发胶']='发胶:BAABKgAECn8YAAMFAAgIBAlTKQC/AAAFAAgIRwhTKQC/AAAWAAgIxQToTgC7AAAAAA==.',['变形']='变形者集群:BAABKgAECn8UAAIXAAgIxhy6EAAfAgAXAAgIxhy6EAAfAgAAAA==.',['可爱']='可爱的三姨太:BAACKgAFFH8hAAIRAAgIJSM1AQCvAQARAAgIJSM1AQCvAQAqAAQKfy4AAhEACAh4JIgFAMsCABEACAh4JIgFAMsCAAAA.',['史迪']='史迪崽:BAABKgAFFH8UAAINAAMInA7qNQC9AAANAAMInA7qNQC9AAAAAA==.',['听劝']='听劝打惩戒:BAAAKgAFFAQIBAAAAA==.',['呆天']='呆天丶:BAABKgAFFH8LAAMDAAQIoSSUGQAeAQADAAQIyyKUGQAeAQANAAQI2SIJJwDqAAAAAA==.',['呛怼']='呛怼飀:BAAAKgADCggICAAAAA==.',['咕徳']='咕徳猫恁:BAAAKgAECggIEAAAAA==.',['咖啡']='咖啡加:BAAAKgAFFAIIAgAAAA==.',['咪咪']='咪咪虾条:BAAAKgAECgQIBAAAAA==.',['咪老']='咪老师:BAAAKgAECgYIDAAAAA==.',['哈尔']='哈尔滨红香肠:BAAAKgAECgMIAwAAAA==.',['哎一']='哎一訥个猟人:BAAAKgAECgUIBgAAAA==.',['哑巴']='哑巴湖大水怪:BAAAKgAECgEIAQAAAA==.',['唔知']='唔知:BAAAKgADCggICAAAAA==.',['嗷嗷']='嗷嗷熊:BAAAKgADCgEIAQAAAA==.',['嘉玉']='嘉玉:BAAAKgAECgcIDwAAAA==.',['嘴炮']='嘴炮德:BAAAKgAECggIDwAAAA==.',['圣光']='圣光大胡子:BAABKgAFFH8OAAIMAAgIARdzCgD+AQAMAAgIARdzCgD+AQAAAA==.圣光就罩我:BAACKgAFFH8JAAMYAAYITBfHAQCKAQAYAAYITBfHAQCKAQAMAAMITA0zKADRAAAqAAQKfxcAAxgACAhqJHMDANcCABgACAhqJHMDANcCAAwABAheIQjBABkBAAAA.',['圣祈']='圣祈:BAABKgAFFH8LAAQZAAUIQR1mEAAfAQAZAAQI6iRmEAAfAQAIAAMIiiHODgDHAAAJAAIIqQ5XGACgAAAAAA==.',['地精']='地精朋友:BAAAKgADCgEIAQAAAA==.',['坠落']='坠落的苹果:BAAAKgAECgEIAQAAAA==.',['大一']='大一奶:BAAAKgAECgYIBwAAAA==.',['大四']='大四喜:BAAAKgADCggICQAAAA==.',['大官']='大官人:BAAAKgAECgYIDwAAAA==.',['大德']='大德大威天龙:BAAAKgAECggICAAAAA==.',['大肌']='大肌大利:BAAAKgAECgEIAQAAAA==.',['太寿']='太寿鸠茂:BAAAKgAECgQIBAAAAA==.',['奉天']='奉天枭雄:BAAAKgAECgQIBAAAAA==.',['奥蕾']='奥蕾莉亜:BAAAKgAFFAIIAgAAAA==.',['奶油']='奶油虾球:BAABKgAFFH8KAAIFAAgINBQeDgBcAQAFAAgINBQeDgBcAQAAAA==.',['她用']='她用下面:BAABKgAFFH8HAAICAAQIJg3bFQC4AAACAAQIJg3bFQC4AAAAAA==.',['好吔']='好吔:BAAAKgAECgIIBAAAAA==.',['好大']='好大的绿根儿:BAAAKgAECgcICQAAAA==.',['子忆']='子忆:BAAAKgAECgIIAgAAAA==.',['小七']='小七不理人:BAABKgAFFH8GAAIaAAYICRN2CgBlAQAaAAYICRN2CgBlAQAAAA==.',['小业']='小业主:BAAAKgAECgYICwAAAA==.',['小呆']='小呆呆丶:BAAAKgADCggICAAAAA==.',['小小']='小小三月七:BAAAKgADCgIIAgAAAA==.',['小尖']='小尖嘴:BAAAKgAECgcIDQAAAA==.',['小李']='小李飞女:BAAAKgAECggICAAAAA==.',['小鸡']='小鸡酱汁:BAAAKgADCgQIAwAAAA==.',['少林']='少林功夫好嘢:BAAAKgAFFAQIBAAAAA==.',['尘成']='尘成晨:BAABKgAFFH8VAAMaAAYIpCKqAADdAQAaAAYIgR6qAADdAQAGAAYIiRZbBQBDAQAAAA==.',['岁月']='岁月无恨:BAABKgAECn8+AAINAAgIzRlCEwDzAQANAAgIzRlCEwDzAQAAAA==.',['幽云']='幽云乄之悟:BAAAKgADCggICAAAAA==.',['康迪']='康迪隆:BAAAKgAECggIDwAAAA==.',['弑魂']='弑魂瑟瑟:BAAAKgAECgEIAgAAAA==.',['徳噜']='徳噜依:BAAAKgAECgUIBQAAAA==.',['德不']='德不劳动:BAAAKgAFFAQIBAAAAA==.',['德古']='德古拉:BAAAKgAECggICAAAAA==.',['德鲁']='德鲁圣伊:BAABKgAECn8gAAIbAAgIpA7YIwAwAQAbAAgIpA7YIwAwAQAAAA==.',['心欣']='心欣辛:BAABKgAFFH8OAAMDAAQI3hiCJgDRAAADAAMIZheCJgDRAAANAAEIRx3VVwBMAAAAAA==.',['忒妞']='忒妞毕啦:BAAAKgADCggICgAAAA==.',['忧郁']='忧郁小猫咪:BAABKgAFFH8KAAQWAAgIKBIhBgAXAQAWAAUIcBQhBgAXAQAFAAQIVA1UHwANAQAHAAEI2wFMJAA9AAAAAA==.',['快乐']='快乐牌刀片:BAAAKgADCgIIAgAAAA==.',['性感']='性感的水桶腰:BAAAKgAECggIDAAAAA==.',['情浅']='情浅缘浅:BAAAKgAECggICAAAAA==.',['惟獨']='惟獨愛你:BAAAKgAECgMIAwAAAA==.',['愿大']='愿大地忽悠你:BAAAKgAECggICgAAAA==.',['我不']='我不会召唤:BAAAKgAECgEIAQAAAA==.',['我猜']='我猜你蛋很圆:BAABKgAFFH8IAAIGAAQIjhfQDgD/AAAGAAQIjhfQDgD/AAAAAA==.',['折袖']='折袖:BAABKgAFFH8KAAMXAAgI2RMeBgAmAgAXAAgI2RMeBgAmAgAcAAII7h0LCwCrAAAAAA==.',['折香']='折香思故人:BAAAKgAECgYIBgAAAA==.',['掵犯']='掵犯灬桃椛:BAAAKgAECgcIEQAAAA==.',['攻殼']='攻殼機動隊:BAAAKgADCgEIAQAAAA==.',['敏感']='敏感的小姨子:BAAAKgAECggICAAAAA==.',['无敌']='无敌乄尐牧:BAAAKgAECgYIDgAAAA==.',['星痕']='星痕:BAABKgAFFH8OAAIMAAQIvx2WOwD/AAAMAAQIvx2WOwD/AAAAAA==.',['暗之']='暗之刀线:BAACKgAFFH8LAAIdAAMI1AcLBAB0AAAdAAMI1AcLBAB0AAAqAAQKfyEAAh0ACAg4DhMSACwBAB0ACAg4DhMSACwBAAAA.',['暴走']='暴走滴胖子:BAAAKgAECgUIBQAAAA==.',['月亮']='月亮之殇:BAAAKgADCgMIAwAAAA==.',['未尽']='未尽:BAAAKgAECggICAAAAA==.',['末丶']='末丶洛:BAABKgAFFH8JAAINAAMIHyPQDwArAQANAAMIHyPQDwArAQAAAA==.',['本地']='本地人:BAAAKgADCgUIBQAAAA==.',['板凳']='板凳:BAAAKgAFFAQIBAAAAA==.',['梓莹']='梓莹彼岸:BAAAKgADCggICQAAAA==.',['水盾']='水盾牌:BAAAKgAFFAgIBAAAAA==.',['永恒']='永恒的支点:BAAAKgADCggICAAAAA==.',['沐乄']='沐乄师:BAAAKgADCgYIBgAAAA==.',['没事']='没事改不掉:BAAAKgAFFAQIBAAAAA==.没事改过了:BAAAKgAFFAQIBAAAAA==.',['油炸']='油炸虾球:BAABKgAFFH8IAAIXAAgI2g2vBAAwAgAXAAgI2g2vBAAwAgAAAA==.',['流流']='流流又浪浪:BAAAKgADCggICAAAAA==.',['浮傷']='浮傷年華:BAAAKgADCgMIAwAAAA==.',['深山']='深山玩泥巴:BAAAKgAECgUIBQAAAA==.',['溜溜']='溜溜糖:BAABKgAECn8WAAINAAgIqSTUCADbAgANAAgIqSTUCADbAgAAAA==.',['潇洒']='潇洒壹哥:BAAAKgAECgIIAgAAAA==.',['灬大']='灬大腕儿灬:BAAAKgAECggIEwAAAA==.',['灬奶']='灬奶嘴儿灬:BAAAKgAECgYIDAAAAA==.',['灬憨']='灬憨豆儿灬:BAAAKgAECgIIAgAAAA==.',['灬烟']='灬烟圈儿灬:BAAAKgAECgYIEQAAAA==.',['灬老']='灬老头儿灬:BAAAKgAECgQIBgAAAA==.',['灬耳']='灬耳钉儿灬:BAAAKgAECggIDAAAAA==.',['灬胖']='灬胖墩儿灬:BAAAKgAECgUIBQAAAA==.',['灬麦']='灬麦兜儿灬:BAAAKgAECggIDQAAAA==.',['灵雾']='灵雾燥:BAAAKgAECgQICAAAAA==.',['灵魂']='灵魂行这:BAAAKgAFFAQIAgAAAA==.',['炎羽']='炎羽轩夕:BAAAKgAECggIEAAAAA==.',['爆炒']='爆炒熘肝尖:BAABKgAFFH8OAAIIAAgIIx5dAgBIAgAIAAgIIx5dAgBIAgAAAA==.',['猪九']='猪九婧:BAAAKgAECgQIBAAAAA==.',['猫老']='猫老师:BAAAKgAECgcICQAAAA==.',['玩具']='玩具茄子:BAABKgAFFH8JAAMDAAYIpBb/EgBLAQADAAYI2RT/EgBLAQANAAMIWRMASgB+AAAAAA==.',['琦柒']='琦柒:BAAAKgADCgMIAwAAAA==.',['甜心']='甜心兔兔:BAAAKgAFFAgIBAAAAA==.',['白酒']='白酒公主:BAABKgAFFH8MAAINAAMINhmPKADjAAANAAMINhmPKADjAAAAAA==.',['盗版']='盗版萨拉塔斯:BAAAKgAECgIIAgAAAA==.',['祝福']='祝福你全家:BAAAKgAFFAMIAwAAAA==.',['神拳']='神拳无敌:BAAAKgAECgUICgAAAA==.',['空城']='空城雨落:BAAAKgAECggIEAAAAA==.',['等待']='等待的风:BAAAKgADCgEIAQAAAA==.',['紫羽']='紫羽衡君:BAACKgAFFH8iAAIBAAYIJiRGBAARAgABAAYIJiRGBAARAgAqAAQKfyoAAwEACAhLJikBAAoDAAEACAhLJikBAAoDAAIAAgirEgOmAIEAAAAA.',['维达']='维达:BAAAKgAFFAQIBAAAAA==.',['绿眼']='绿眼睛:BAACKgAFFH8sAAIUAAYIqB82BABLAQAUAAYIqB82BABLAQAqAAQKfzYAAhQACAh/JYcCAPMCABQACAh/JYcCAPMCAAAA.',['老牛']='老牛不吃嫩草:BAAAKgAECggICAAAAA==.',['老白']='老白干:BAAAKgAECgYIDwAAAA==.',['肝帝']='肝帝:BAABKgAFFH8IAAIBAAQIiBoLCwDtAAABAAQIiBoLCwDtAAAAAA==.',['致命']='致命元素:BAAAKgAECgYICgAAAA==.',['花乃']='花乃玖叶月:BAAAKgAFFAEIAQAAAA==.',['莫天']='莫天:BAAAKgAFFAQIBAAAAA==.',['菇妖']='菇妖王:BAAAKgAFFAYIBAAAAA==.',['萫愺']='萫愺咖渁:BAAAKgAECgIIAgAAAA==.',['虎步']='虎步关右:BAAAKgAECgEIAQAAAA==.',['蛇年']='蛇年灬大发:BAAAKgADCgYIBwAAAA==.蛇年灬平安:BAAAKgADCgEIAQAAAA==.',['装糊']='装糊涂的高手:BAAAKgADCgcIBwAAAA==.',['见习']='见习圣光:BAABKgAFFH8HAAIYAAYI6hVgAgBqAQAYAAYI6hVgAgBqAQAAAA==.',['谢先']='谢先生:BAABKgAFFH8HAAIGAAcI4xkmBgAmAgAGAAcI4xkmBgAmAgABKgAFFAgIGAAZAOgeAA==.',['豚豚']='豚豚能吃爱睡:BAAAKgADCgYIBgAAAA==.',['追忆']='追忆灬遗忘:BAAAKgADCgIIAwAAAA==.',['道德']='道德天尊:BAABKgAFFH8GAAMMAAMIexwYLwCpAAAMAAMIexwYLwCpAAAeAAIInQTTGQBnAAAAAA==.',['释然']='释然:BAAAKgAECgEIAQAAAA==.',['铃木']='铃木瓶瓶奶:BAAAKgAFFAgIBAAAAA==.',['铮铮']='铮铮鈤殇:BAAAKgAFFAIIBAAAAA==.',['长期']='长期素食:BAAAKgAFFAEIAQAAAA==.',['问剑']='问剑:BAABKgAFFH8IAAIeAAQIBQajCgC1AAAeAAQIBQajCgC1AAAAAA==.',['阿撒']='阿撒托斯:BAABKgAFFH8FAAMEAAUIkA+tHQD5AAAEAAQIkA+tHQD5AAAfAAEIAACrMAAAAAAAAA==.',['陈不']='陈不灵:BAAAKgAECgYIBwAAAA==.',['随敌']='随敌大小变:BAAAKgAECggICAAAAA==.',['雷武']='雷武龙:BAAAKgAECgYIBgAAAA==.',['雾燥']='雾燥:BAACKgAFFH8xAAMSAAgIPCF2BABqAgASAAgIPCF2BABqAgAgAAQIyBW2AQDCAAAqAAQKfy4AAxIACAiZI/QOAFgCABIACAiZI/QOAFgCACAAAQgWIVsHAFgAAAAA.',['露亦']='露亦歪灯:BAABKgAFFH8QAAIMAAMIug2bVwDCAAAMAAMIug2bVwDCAAAAAA==.',['霸王']='霸王茶肌:BAAAKgAECggIDQAAAA==.霸王鱼肌:BAAAKgAECgUIBwAAAA==.',['飘渺']='飘渺佳宝:BAAAKgADCgUIBgAAAA==.飘渺小帅:BAAAKgADCggIGwAAAA==.飘渺小狂:BAAAKgAECgYICAAAAA==.',['香菇']='香菇无言:BAAAKgAECgIIAgAAAA==.',['骑我']='骑我吧骚年:BAABKgAFFH8GAAIbAAYIxBeMEwB/AQAbAAYIxBeMEwB/AQAAAA==.',['魂殇']='魂殇痕:BAAAKgAFFAQIBAAAAA==.',['魔王']='魔王白:BAABKgAFFH8IAAIMAAgIvRlyCQArAgAMAAgIvRlyCQArAgAAAA==.',['麦噶']='麦噶尼银须:BAABKgAFFH8IAAIUAAgI7QdBBADhAQAUAAgI7QdBBADhAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end