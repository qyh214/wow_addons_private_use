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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Fury','Unknown-Unknown','Warrior-Arms','Druid-Balance','DeathKnight-Frost','Priest-Discipline','Priest-Shadow','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','Shaman-Restoration','Mage-Frost','Paladin-Retribution','Monk-Mistweaver','Monk-Windwalker','Druid-Restoration','Mage-Fire','Warrior-Protection','Paladin-Protection','DemonHunter-Vengeance','DeathKnight-Unholy','Evoker-Devastation','Paladin-Holy','Rogue-Subtlety','Druid-Feral','Priest-Holy','Shaman-Elemental','Shaman-Enhancement','Monk-Brewmaster','Druid-Guardian','Mage-Arcane','Hunter-Survival','Rogue-Assassination','Evoker-Preservation',}; local provider = {region='CN',realm='远古海滩',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ac='Achiilles:BAAAKgAECgQICAAAAA==.Actionbo:BAAAKgADCgIIAQAAAA==.',Ae='Aelis:BAAAKgAECgcIDQAAAA==.',Al='Albis:BAAAKgAECgcIDAAAAA==.',Ar='Armaiti:BAABKgAECn8XAAQBAAgIqBmVJACSAQABAAUIHxuVJACSAQACAAUI2BKaHwCYAAADAAQIMQ08MwBjAAAAAA==.',Ba='Balotr:BAAAKgAECggICwAAAA==.',Bl='Bleachar:BAAAKgAECggICAAAAA==.',Ch='Chosenson:BAACKgAFFH8WAAIEAAQI0xZxGgDsAAAEAAQI0xZxGgDsAAAqAAQKfxQAAgQACAj2G8oPAKABAAQACAj2G8oPAKABAAAA.',Cp='Cpy:BAAAKgAFFAIIAgAAAA==.',Dc='Dc:BAAAKgADCgUIBQAAAA==.',De='Deathwm:BAAAKgAECgIIAgAAAA==.Deidi:BAAAKgAFFAMIAwAAAA==.',Do='Doleni:BAAAKgAFFAQIBAABKgAFFAgIBAAFAAAAAA==.',Em='Emooll:BAAAKgAECggIEAAAAA==.',Ev='Evar:BAAAKgAECggIEAAAAA==.',Fi='Fireball:BAAAKgAFFAIIAgAAAA==.',Fl='Flyangle:BAAAKgAFFAQIBAAAAA==.',Fr='Freedom:BAAAKgAFFAEIAQAAAA==.',Gr='Grilfrend:BAAAKgAECgcICAAAAA==.',Ha='Hamtrio:BAABKgAFFH8GAAIGAAYIBhNjAQC5AQAGAAYIBhNjAQC5AQABKgAFFAgIFAAHAFUiAA==.',Id='Idrive:BAAAKgADCgIIAgAAAA==.',Il='Iliidan:BAAAKgAECggIDQAAAA==.',Ku='Kurenai:BAABKgAFFH8FAAIIAAQIGAM7DwBkAAAIAAQIGAM7DwBkAAAAAA==.',La='Lastac:BAABKgAECn8fAAMJAAgIkSDwCQBwAgAJAAgIkSDwCQBwAgAKAAUIJBRkOQDbAAAAAA==.Lazzy:BAABKgAFFH8IAAILAAQI2BNdDwDEAAALAAQI2BNdDwDEAAAAAA==.',Li='Liliith:BAABKgAECn8UAAIMAAgIHR2nIQA2AgAMAAgIHR2nIQA2AgAAAA==.',Lr='Lrool:BAABKgAFFH8IAAINAAgIbhjFBgD6AQANAAgIbhjFBgD6AQAAAA==.',Lu='Lussi:BAAAKgAECgQICwAAAA==.',Lx='Lxxnh:BAAAKgADCgIIAgAAAA==.',Ma='Mami:BAABKgAFFH8LAAIIAAMISx20BgACAQAIAAMISx20BgACAQAAAA==.Marttina:BAAAKgADCgEIAQAAAA==.',Mo='Moo:BAAAKgAECgYICgAAAA==.',Na='Nani:BAACKgAFFH8FAAIOAAMI2A2bNQCqAAAOAAMI2A2bNQCqAAAqAAQKfxoAAg4ACAiwHwcdAFYCAA4ACAiwHwcdAFYCAAAA.',Pl='Playerbhmnmh:BAABKgAECn8jAAIPAAgIuRl4JwDiAQAPAAgIuRl4JwDiAQAAAA==.',Ps='Psalm:BAAAKgAECgEIAQAAAA==.',Sh='Shifts:BAAAKgADCgMIAwAAAA==.',So='Solomon:BAABKgAECn8hAAIQAAgI5SLABwCyAgAQAAgI5SLABwCyAgAAAA==.',Tk='Tkatt:BAAAKgAFFAMIAwAAAA==.',Tt='Ttakkt:BAAAKgAFFAEIAQAAAA==.',Vo='Von:BAAAKgADCgIIAgAAAA==.',Wd='Wdeathgo:BAABKgAECn8UAAIRAAgIJCOHMQBcAgARAAgIJCOHMQBcAgAAAA==.',Ye='Yeugo:BAAAKgAFFAQIBAAAAA==.',Yo='Yoo:BAAAKgAECgEIAQAAAA==.',['一份']='一份麻辣烫灬:BAAAKgAECggICAAAAA==.',['一只']='一只鸡腿:BAABKgAFFH8GAAIKAAYILh25BwCYAQAKAAYILh25BwCYAQAAAA==.',['一头']='一头胖胖:BAAAKgAECgQIBAAAAA==.',['一根']='一根榨菜:BAAAKgAECgYICAAAAA==.',['一沫']='一沫夏凉:BAAAKgADCgEIAQAAAA==.',['一法']='一法:BAAAKgAECgYIBgAAAA==.',['一风']='一风之伤焰一:BAACKgAFFH8RAAMSAAUIkw/bDgC7AAASAAQIBhPbDgC7AAATAAEIvgGcFgA1AAAqAAQKfxQAAhIACAgIDQc/AEYBABIACAgIDQc/AEYBAAAA.',['七弦']='七弦歌:BAAAKgAECgEIAQAAAA==.',['三刀']='三刀:BAAAKgADCgQIBQAAAA==.',['上原']='上原瑞穗:BAAAKgAECgEIAQAAAA==.',['上帝']='上帝也流氓:BAAAKgAECgMIAwAAAA==.上帝沚手丶:BAACKgAFFH8WAAILAAYIJgHgJwB3AAALAAYIJgHgJwB3AAAqAAQKfyoAAgsACAiUAm9JAJcAAAsACAiUAm9JAJcAAAEqAAUUCAgPABIAxxUA.',['不喝']='不喝热水:BAAAKgAECgQIBwAAAA==.',['不良']='不良灬少女:BAACKgAFFH8dAAMUAAYIsR1OBgAWAQAUAAYIsR1OBgAWAQAHAAEIwAG7XwA5AAAqAAQKfxYAAxQACAjFJMICAN8CABQACAjFJMICAN8CAAcABgj+DyZ8AOQAAAAA.',['专属']='专属伱丨小雄:BAAAKgAECgMIBQAAAA==.',['两袖']='两袖清风:BAAAKgAFFAQIBAAAAA==.',['两颗']='两颗蛋:BAABKgAECn8dAAIOAAgIBxe+DwD3AQAOAAgIBxe+DwD3AQAAAA==.',['丨半']='丨半月式:BAAAKgAECggICgAAAA==.',['丨擎']='丨擎剑术:BAAAKgAECgEIAgAAAA==.',['丫头']='丫头小菇凉:BAAAKgADCggICAAAAA==.',['中里']='中里毅:BAAAKgAECgYIBgAAAA==.',['中野']='中野二乃:BAACKgAFFH8PAAMNAAYIXCTuBwDhAQANAAYITCTuBwDhAQAMAAMI5h0IDAAkAQAqAAQKfxQAAgwACAitHGI0ACQCAAwACAitHGI0ACQCAAAA.',['丶火']='丶火火:BAAAKgAECgEIAQAAAA==.',['丶神']='丶神菜美舞:BAABKgAFFH8HAAIHAAQIhxVXNwDCAAAHAAQIhxVXNwDCAAABKgAFFAgIAgAFAAAAAA==.',['丶秋']='丶秋原野丶:BAABKgAFFH8MAAIVAAQIKhYAHADMAAAVAAQIKhYAHADMAAAAAA==.',['丶馬']='丶馬王爷:BAACKgAFFH8MAAMGAAYItxEbCgBqAQAGAAYItxEbCgBqAQAEAAMIeAuGJAC/AAAqAAQKfxQAAxYACAgbFhYSAJ0BABYACAgbFhYSAJ0BAAYABggDCYQ7APEAAAAA.',['乄凋']='乄凋零灬记忆:BAAAKgAECgIIAgAAAA==.',['久久']='久久知:BAAAKgADCgQIBAAAAA==.',['乐夏']='乐夏:BAAAKgAECgMIAwAAAA==.',['乐黠']='乐黠:BAAAKgAECgUICQAAAA==.',['九星']='九星变:BAAAKgAECggIDgAAAA==.',['乱噬']='乱噬戦魂:BAAAKgADCggIDAAAAA==.',['五元']='五元帮拿快递:BAAAKgADCgQICAAAAA==.',['五杀']='五杀:BAAAKgADCggICAAAAA==.',['亡城']='亡城旧人:BAABKgAFFH8WAAMRAAYIPR3YDAAhAQARAAUI2SLYDAAhAQAXAAEIyQa3FAA7AAAAAA==.',['人间']='人间小蝴蝶:BAAAKgAFFAYIAgABKgAFFAgIBAAFAAAAAA==.',['今晚']='今晚不熬夜:BAAAKgAECgMIAwAAAA==.',['从小']='从小丑到大:BAAAKgAECgIIAgAAAA==.',['他叫']='他叫养乐多:BAAAKgAECgMIAQAAAA==.',['以德']='以德服人的牛:BAAAKgAECgcICwAAAA==.',['件件']='件件:BAAAKgADCgEIAQAAAA==.',['伊力']='伊力丹丶怒云:BAABKgAECn8WAAIYAAgIkRLVHgCDAQAYAAgIkRLVHgCDAQAAAA==.',['伊博']='伊博喇:BAABKgAFFH8IAAIZAAgIewdcCQCVAQAZAAgIewdcCQCVAQAAAA==.',['伊卡']='伊卡鲁斯:BAAAKgAECgYICAAAAA==.',['伊纳']='伊纳瑞斯:BAABKgAECn9BAAMBAAgIvCJvCQChAgABAAgIvCJvCQChAgACAAIImx8VbwBaAAAAAA==.',['伊莉']='伊莉斯丶逐星:BAAAKgAECgcICQAAAA==.',['会变']='会变身的猫:BAAAKgAECgEIAQAAAA==.',['传说']='传说女神:BAAAKgAECgQIBAAAAA==.',['伸缩']='伸缩自如的愛:BAAAKgAECggICAAAAA==.',['似梦']='似梦:BAABKgAFFH8QAAMCAAQISx5GCQDuAAABAAQI3Bq3IgDyAAACAAQI4B1GCQDuAAAAAA==.',['体温']='体温叁拾八:BAAAKgAFFAQIBAAAAA==.',['何是']='何是归处:BAAAKgAECgYIBgAAAA==.',['你们']='你们真缺德:BAAAKgAECggICAAAAA==.',['保质']='保质期残酷:BAAAKgADCggICAAAAA==.',['倍力']='倍力丸:BAAAKgADCgMIAwAAAA==.',['倒吊']='倒吊:BAAAKgAECggICQAAAA==.',['傻慢']='傻慢呦:BAAAKgAECgYIBwAAAA==.',['克洛']='克洛泽:BAAAKgAFFAQIBAAAAA==.',['兽兽']='兽兽不坏:BAABKgAFFH8FAAINAAUI+xfYDAAxAQANAAUI+xfYDAAxAQAAAA==.兽兽不闹:BAABKgAFFH8FAAIaAAUI1hmzDABhAQAaAAUI1hmzDABhAQAAAA==.',['冬雪']='冬雪落浅浅:BAAAKgAFFAQIBAAAAA==.',['冰殇']='冰殇丨大伯:BAAAKgAFFAYIBAAAAA==.',['冰霜']='冰霜打鸡:BAAAKgAFFAQIBAAAAA==.',['冲锋']='冲锋小野兔:BAAAKgAECggICAAAAA==.',['冷月']='冷月葬花魂:BAAAKgAECggICAABKgAFFAgIDQAMAPMhAA==.',['冷面']='冷面刀手:BAAAKgAECgQICgAAAA==.',['冷香']='冷香知人意:BAAAKgAFFAQIAQAAAA==.',['冷魅']='冷魅:BAABKgAFFH8fAAINAAQIMx8rHQAIAQANAAQIMx8rHQAIAQAAAA==.',['凌花']='凌花落:BAAAKgADCgEIAgAAAA==.',['切尔']='切尔奇无:BAAAKgAECgYICQAAAA==.',['刘海']='刘海遮了眼:BAABKgAFFH8IAAIOAAQIJCAVKgDPAAAOAAQIJCAVKgDPAAAAAA==.',['初若']='初若有奶:BAACKgAFFH8UAAMKAAQITR0+DAD5AAAKAAQITR0+DAD5AAAJAAIIhwxuEgBiAAAqAAQKfxYAAwoACAipHq8VAOcBAAoACAipHq8VAOcBAAkAAgiNC1t+ADAAAAAA.',['剑胆']='剑胆琴心:BAAAKgADCgIIAgAAAA==.',['加肉']='加肉煎饼丶:BAAAKgAECggIEgAAAA==.',['十文']='十文字未来:BAABKgAFFH8IAAISAAUIKhfUBQBPAQASAAUIKhfUBQBPAQAAAA==.',['十板']='十板九胖:BAAAKgAECgYICgAAAA==.',['十灬']='十灬月:BAAAKgADCgEIAQAAAA==.',['半世']='半世晨曦:BAABKgAFFH8HAAIRAAcISwYeFABaAQARAAcISwYeFABaAQAAAA==.',['半支']='半支云烟:BAAAKgADCgMIAwAAAA==.',['华文']='华文:BAACKgAFFH8kAAMNAAUIDSHXGAAjAQANAAUIDSHXGAAjAQAMAAQI4RW3MwDCAAAqAAQKfz4AAg0ACAi4JB0IAMICAA0ACAi4JB0IAMICAAAA.',['卖萌']='卖萌德丶:BAAAKgAECgQIBAAAAA==.卖萌的小骑士:BAABKgAFFH8IAAMbAAQITiJQAwAaAQAbAAQITiJQAwAaAQARAAEIAhnzUgBDAAAAAA==.',['南极']='南极树袋熊:BAAAKgAECgcICwAAAA==.',['南风']='南风一路南吹:BAAAKgADCgMIAwAAAA==.',['卡匹']='卡匹巴拉:BAAAKgAECggIDwAAAA==.',['卡皮']='卡皮扒拉:BAABKgAECn8iAAISAAgI2xiREwD3AQASAAgI2xiREwD3AQAAAA==.',['双椒']='双椒鱼:BAAAKgAFFAYIBAAAAA==.',['发狂']='发狂的小泰迪:BAAAKgAECgQIBAAAAA==.',['变身']='变身看心情:BAAAKgAECggIDAAAAA==.',['古娜']='古娜拉黑暗神:BAABKgAFFH8XAAMQAAYIWRjVAABSAQAQAAQIfybVAABSAQAVAAIIIQNxKwCaAAAAAA==.',['只为']='只为装逼:BAAAKgAECgYIBwAAAA==.',['可爱']='可爱小宝宝:BAAAKgAECgYICAAAAA==.',['叶心']='叶心安:BAABKgAFFH8FAAMLAAQImgleIACiAAALAAQIzAVeIACiAAAZAAEIIhH8UABRAAAAAA==.叶心安前女友:BAABKgAFFH8GAAIVAAYIFB3wCwB3AQAVAAYIFB3wCwB3AQAAAA==.叶心安的妹妹:BAAAKgAFFAYIAwAAAA==.',['叶落']='叶落风情:BAAAKgAECgQIBAAAAA==.',['后羿']='后羿他哥:BAABKgAECn8iAAIMAAgIHBneMQDhAQAMAAgIHBneMQDhAQAAAA==.',['含笑']='含笑半步癲丶:BAAAKgAECgUIBQAAAA==.',['呀冴']='呀冴:BAAAKgAECgEIAQAAAA==.',['呦灬']='呦灬熙:BAAAKgAFFAIIAgAAAA==.',['咔皮']='咔皮巴拉:BAABKgAECn8eAAIcAAgIwSJNAQCpAgAcAAgIwSJNAQCpAgAAAA==.',['咕咕']='咕咕不咕噜咕:BAABKgAFFH8GAAQUAAMIagh1FABjAAAUAAMIagh1FABjAAAdAAEIQg/1CABKAAAHAAEIigizXwA6AAAAAA==.',['咕噜']='咕噜米:BAAAKgADCgEIAQAAAA==.',['咲咲']='咲咲大魔王:BAAAKgAFFAQIBAAAAA==.',['哇喔']='哇喔打得不错:BAAAKgAECggICAAAAA==.',['唐小']='唐小婉:BAAAKgAECgMIAwAAAA==.',['啊噜']='啊噜咔哆:BAAAKgAECgQIBAAAAA==.',['啾也']='啾也:BAAAKgADCgEIAQAAAA==.',['喵猫']='喵猫貓:BAAAKgAECgIIAgAAAA==.',['嗨骨']='嗨骨:BAABKgAFFH8IAAIaAAgIFgp9CQDDAQAaAAgIFgp9CQDDAQAAAA==.',['噬神']='噬神者圈圈:BAAAKgAECgcICQAAAA==.',['四川']='四川彭于晏:BAABKgAECn8hAAIRAAgIARhnSgDgAQARAAgIARhnSgDgAQAAAA==.',['回忆']='回忆只是谣言:BAAAKgAECgYIBgAAAA==.',['圌猫']='圌猫:BAAAKgADCggIDAAAAA==.',['圣光']='圣光弥漫:BAAAKgAECgcIBwAAAA==.圣光探照灯:BAAAKgADCggICAAAAA==.圣光胴胴:BAABKgAFFH8IAAIbAAQIFBMgCgCxAAAbAAQIFBMgCgCxAAAAAA==.',['在下']='在下头很硬:BAACKgAFFH8SAAILAAUI2BViDQDVAAALAAUI2BViDQDVAAAqAAQKfxQAAgsACAgSHyQOAE0CAAsACAgSHyQOAE0CAAAA.',['墨魂']='墨魂丿:BAABKgAFFH8IAAIeAAgIeBv9AgAjAgAeAAgIeBv9AgAjAgAAAA==.',['壹贰']='壹贰叁:BAAAKgAECgIIAgAAAA==.',['夜卜']='夜卜:BAAAKgAECgUIBQAAAA==.',['夜魅']='夜魅影:BAACKgAFFH8jAAMNAAYIdxdTDQCFAQANAAYIdxdTDQCFAQAMAAIIdg4kNQCOAAAqAAQKfz4AAw0ACAikIXkLAIQCAA0ACAikIXkLAIQCAAwACAjDGuY6AAsCAAAA.',['夢丷']='夢丷魇:BAAAKgADCggIEAAAAA==.',['大小']='大小桃子:BAAAKgAFFAQIBAAAAA==.',['大憨']='大憨憨:BAAAKgAECggICAAAAA==.',['大斩']='大斩宏屠:BAAAKgAECgIIAgAAAA==.',['大漠']='大漠以北:BAAAKgADCggICAAAAA==.',['大牛']='大牛有点懒:BAAAKgAECgUIBQAAAA==.',['大龅']='大龅牙:BAAAKgAECggICAAAAA==.',['天亮']='天亮休息七:BAAAKgAECgUICgABKgAFFAYIEwAHAFgYAA==.',['天兵']='天兵玩偶:BAAAKgAECgQIBAAAAA==.',['天智']='天智:BAACKgAFFH8bAAIQAAYIgBCIDAAEAQAQAAYIgBCIDAAEAQAqAAQKfxQAAhAACAjPG9EiAPsBABAACAjPG9EiAPsBAAAA.',['失眠']='失眠的睡美人:BAAAKgAECgQIBAAAAA==.',['奎尔']='奎尔扎拉姆:BAABKgAFFH8FAAMEAAQIvBVvGAD3AAAEAAMIEhxvGAD3AAAWAAIImwlLFQBOAAAAAA==.',['奕战']='奕战:BAAAKgADCggICAAAAA==.',['女见']='女见愁:BAAAKgAECgUIBwAAAA==.',['好黑']='好黑的白丶:BAAAKgAECgQIBAAAAA==.',['媚不']='媚不媚:BAABKgAFFH8KAAIGAAYIixfgBgD6AAAGAAYIixfgBgD6AAAAAA==.',['孤踴']='孤踴者:BAABKgAFFH8JAAIPAAYIPByiCgCdAQAPAAYIPByiCgCdAQAAAA==.',['安克']='安克雷奇:BAAAKgADCgEIAQAAAA==.',['安波']='安波莎:BAAAKgADCgEIAQAAAA==.',['宝小']='宝小格:BAAAKgAECggICwAAAA==.',['寒塘']='寒塘渡鹤影:BAAAKgAECgEIAQABKgAFFAgIDQAMAPMhAA==.',['專養']='專養小白臉:BAAAKgAECgMIAwAAAA==.',['小三']='小三暮雪:BAAAKgAECgYIDAAAAA==.',['小丸']='小丸子的男人:BAAAKgADCgIIAgAAAA==.',['小义']='小义:BAAAKgADCggICQAAAA==.',['小单']='小单纯:BAAAKgAFFAgIBAAAAA==.',['小娃']='小娃娲:BAAAKgAECggICwAAAA==.',['小小']='小小予:BAAAKgAFFAYIBAAAAA==.小小欧:BAABKgAFFH8GAAMNAAYITxYuIgDpAAANAAQIUx8uIgDpAAAMAAIIyQh4SgB8AAABKgAFFAgICAAMABcdAA==.小小王菀之:BAAAKgAFFAEIAQAAAA==.',['小弘']='小弘喵:BAABKgAECn8WAAIUAAgI+BTJNQBCAQAUAAgI+BTJNQBCAQAAAA==.',['小德']='小德疯狂:BAAAKgAFFAgIBAAAAA==.',['小新']='小新心信:BAAAKgADCggICAAAAA==.',['小晴']='小晴甜甜:BAAAKgADCgcIBwAAAA==.',['小灰']='小灰人:BAAAKgAECgMIAwAAAA==.',['小肥']='小肥崽:BAAAKgADCgMIAwAAAA==.',['小萫']='小萫儿:BAAAKgAECggICQAAAA==.',['小釢']='小釢牛:BAAAKgADCgEIAQAAAA==.',['小鬼']='小鬼本鬼:BAAAKgAECgQIBAAAAA==.',['小黑']='小黑洞:BAAAKgADCgEIAQAAAA==.',['屠城']='屠城英雄:BAABKgAFFH8IAAIRAAMI/yJkDAAjAQARAAMI/yJkDAAjAQAAAA==.',['山中']='山中有:BAAAKgAECgMIAwAAAA==.',['岚煌']='岚煌:BAAAKgADCggICAAAAA==.',['岳烚']='岳烚:BAAAKgAECgQIBAAAAA==.',['岳狭']='岳狭:BAAAKgAECgUIDAAAAA==.',['岳珨']='岳珨:BAAAKgAECggIEQAAAA==.',['崇唐']='崇唐:BAABKgAFFH8MAAIRAAQIph9tDQAfAQARAAQIph9tDQAfAQAAAA==.',['布叮']='布叮:BAAAKgADCgMIAwAAAA==.',['带种']='带种:BAAAKgAECgcIBwAAAA==.',['干完']='干完才准玩:BAAAKgAFFAQIBAABKgAFFAgIBAASAAcHAA==.',['幻沫']='幻沫:BAABKgAFFH8OAAIPAAQIzSEgFwAmAQAPAAQIzSEgFwAmAQAAAA==.',['幽桐']='幽桐:BAABKgAFFH8GAAIGAAYIRRgDCgBrAQAGAAYIRRgDCgBrAQAAAA==.',['弑神']='弑神之箭:BAABKgAECn8XAAMNAAgIshgPJwDRAQANAAgIshgPJwDRAQAMAAEIEwNpEAEhAAAAAA==.',['强撸']='强撸得永生:BAAAKgAECggICAAAAA==.',['彩虹']='彩虹爸爸:BAAAKgAECggIDQAAAA==.',['影子']='影子:BAAAKgADCggICAAAAA==.',['影月']='影月无殇:BAAAKgAECgcIDQAAAA==.',['往汐']='往汐青尺:BAAAKgAFFAgIAgAAAA==.',['忆如']='忆如寄往:BAAAKgAECgEIAQAAAA==.',['忆雪']='忆雪:BAAAKgAFFAYIBAAAAA==.',['忧伤']='忧伤的即即:BAAAKgADCgEIAQAAAA==.',['思念']='思念:BAAAKgAECggICwAAAA==.',['恶龘']='恶龘鋝灬悍:BAAAKgAECgQIBAAAAA==.',['悦厦']='悦厦:BAAAKgAECggIEgAAAA==.',['悦夏']='悦夏:BAAAKgAECgIIAgAAAA==.',['悦珨']='悦珨:BAAAKgAECggIEwAAAA==.',['情殒']='情殒殇悲:BAABKgAFFH8HAAIQAAMIMgduHQCZAAAQAAMIMgduHQCZAAAAAA==.',['我就']='我就不:BAACKgAFFH81AAIRAAgIxyRfAgDRAgARAAgIxyRfAgDRAgAqAAQKfyEAAhEACAiAI24lAIUCABEACAiAI24lAIUCAAAA.',['我愛']='我愛一根柴:BAAAKgAECgYIBgAAAA==.',['我是']='我是信仰猎:BAABKgAFFH8LAAMMAAQIyxEkLgCdAAAMAAMIUBQkLgCdAAANAAMIbgkaHwB7AAAAAA==.',['我超']='我超级厉害:BAAAKgAFFAQIBAAAAA==.',['打宝']='打宝贝酱油:BAAAKgAECggICwAAAA==.',['承受']='承受寂寞:BAAAKgADCgEIAQAAAA==.',['收割']='收割:BAEBKgAFFH8GAAIfAAQI4BZ5EQDbAAAfAAQI4BZ5EQDbAAABKgAFFAgIBgAgAK4TAA==.',['攻强']='攻强卷轴:BAABKgAFFH8MAAMGAAgInRotAgBxAgAGAAgInRotAgBxAgAWAAQIGxeJCgC7AAAAAA==.',['放逐']='放逐:BAAAKgAFFAIIAgAAAA==.',['故事']='故事平淡丶:BAACKgAFFH8aAAMhAAQIwgO6CQBsAAAhAAQIwgO6CQBsAAASAAEIDgDVNgAEAAAqAAQKfx0AAiEACAglBacXAMsAACEACAglBacXAMsAAAEqAAUUCAgPABIAxxUA.',['新地']='新地方:BAAAKgAECgMIAwAAAA==.',['无心']='无心的北宅酱:BAAAKgADCggIGAAAAA==.',['无支']='无支祁:BAAAKgAECgIIAgAAAA==.',['无敌']='无敌神鹿:BAAAKgAECgEIAQAAAA==.无敌长颈鹿:BAAAKgAECgEIAQAAAA==.',['无糖']='无糖养乐多:BAAAKgAFFAEIAQAAAA==.',['无聊']='无聊的海包豹:BAAAKgADCggICAAAAA==.',['无邪']='无邪:BAAAKgADCggIEAAAAA==.',['时崎']='时崎丿狂三:BAAAKgAECgQIBAAAAA==.',['星怒']='星怒:BAABKgAFFH8KAAIUAAYIyAx2EgALAQAUAAYIyAx2EgALAQABKgAFFAgIBAAFAAAAAA==.',['晓术']='晓术:BAAAKgADCggICAAAAA==.',['暂时']='暂时没想好:BAAAKgAECggIBwAAAA==.',['暗夜']='暗夜无笙:BAAAKgAECggIDwAAAA==.',['暗木']='暗木:BAAAKgAECgIIAgAAAA==.',['月亮']='月亮饶过谁:BAABKgAFFH8FAAIHAAUI2QhuFwDsAAAHAAUI2QhuFwDsAAAAAA==.',['月光']='月光下的小德:BAAAKgADCggICQAAAA==.',['月夜']='月夜高歌:BAAAKgAECgQIBAAAAA==.',['有德']='有德自远方来:BAAAKgADCgYIBgAAAA==.',['本姑']='本姑娘贝熙儿:BAAAKgAECggIDwAAAA==.',['术师']='术师:BAAAKgAECgQIBgAAAA==.',['术沭']='术沭术:BAABKgAFFH8GAAIBAAYIIBDSGQA2AQABAAYIIBDSGQA2AQAAAA==.',['机智']='机智的大桐哥:BAACKgAFFH8ZAAIGAAYI9RSACADiAAAGAAYI9RSACADiAAAqAAQKfxQAAgYACAjxGhoXAPwBAAYACAjxGhoXAPwBAAAA.',['杏花']='杏花春雨江南:BAABKgAFFH8LAAIOAAYIIAkLHADUAAAOAAYIIAkLHADUAAAAAA==.',['松岛']='松岛菜菜子:BAABKgAFFH8IAAIRAAgIChpQDQD7AQARAAgIChpQDQD7AQAAAA==.',['果粒']='果粒橙艾萌:BAABKgAECn8XAAMdAAcIChDqFAAuAQAdAAcIChDqFAAuAQAHAAYIYATYlgCaAAAAAA==.',['枫月']='枫月舞影:BAAAKgAECgQIBAAAAA==.',['柒玖']='柒玖玖:BAAAKgAECgMIAwAAAA==.',['柒贰']='柒贰玖:BAAAKgAECgQIBAAAAA==.',['柒里']='柒里香:BAAAKgAECgYIDQAAAA==.',['柒颜']='柒颜:BAABKgAFFH8IAAISAAQIThwGFgDzAAASAAQIThwGFgDzAAAAAA==.',['柳如']='柳如烟丶:BAAAKgAECgIIAgAAAA==.',['格小']='格小宝:BAABKgAECn8aAAMbAAgI8xQmIQBXAQAbAAgI8xQmIQBXAQARAAQItAT8MgF6AAAAAA==.',['格温']='格温:BAAAKgAFFAIIAgAAAA==.',['桥雨']='桥雨:BAABKgAFFH8dAAIbAAQIwyQtBwBDAQAbAAQIwyQtBwBDAQAAAA==.',['梦梦']='梦梦:BAAAKgAECggICAAAAA==.',['梦魇']='梦魇来袭:BAAAKgADCggICAAAAA==.',['欧阳']='欧阳丁:BAAAKgAECgYICgAAAA==.',['此昵']='此昵称太帅:BAAAKgAECgIIAgAAAA==.',['武毅']='武毅:BAAAKgAECggICgAAAA==.',['残月']='残月丶汪:BAABKgAFFH8FAAIQAAMIwRFYEwDLAAAQAAMIwRFYEwDLAAAAAA==.',['永恒']='永恒的恩惠:BAAAKgADCgQIBAAAAA==.',['沉沦']='沉沦老狼:BAAAKgAECgMIAwAAAA==.',['沐光']='沐光:BAABKgAFFH8HAAIRAAMIphgRRQDkAAARAAMIphgRRQDkAAAAAA==.',['沐夏']='沐夏丶:BAAAKgAECgYIBwAAAA==.',['沐沐']='沐沐妮妮:BAACKgAFFH8QAAMJAAYI1RxNCQAMAQAJAAQIyR9NCQAMAQAeAAUIRhmkGQDsAAAqAAQKfxYAAh4ACAhnGE8mALgBAB4ACAhnGE8mALgBAAAA.',['治疗']='治疗:BAAAKgAECgIIAQAAAA==.',['法外']='法外丨狂徒:BAAAKgAECggIEQAAAA==.',['泡菜']='泡菜鱼:BAAAKgADCggICAAAAA==.',['浅霜']='浅霜:BAACKgAFFH8wAAIeAAgI6yX1AQBIAQAeAAgI6yX1AQBIAQAqAAQKfzYAAh4ACAgwJkwDANkCAB4ACAgwJkwDANkCAAAA.',['浮生']='浮生流年:BAABKgAFFH8IAAIOAAgIUgqqGgApAQAOAAgIUgqqGgApAQAAAA==.',['消失']='消失的猫:BAAAKgAECgcIDwAAAA==.',['深夜']='深夜的猫子:BAAAKgAECgMIAwAAAA==.',['清澈']='清澈如初:BAAAKgAECgQIBAAAAA==.',['温西']='温西尔太阳王:BAAAKgADCgQIBAAAAA==.',['源默']='源默:BAABKgAFFH8FAAIiAAMIjwGDDQBEAAAiAAMIjwGDDQBEAAAAAA==.',['滚错']='滚错的床单:BAAAKgAECgUIBQAAAA==.',['灬太']='灬太乙真人灬:BAAAKgADCgcIBwAAAA==.',['灬马']='灬马东锡灬:BAAAKgADCgMIAwAAAA==.',['烟雨']='烟雨潇湘:BAAAKgAECgYIEAAAAA==.',['烧饼']='烧饼:BAAAKgADCggICAAAAA==.',['燃情']='燃情小赵:BAACKgAFFH8TAAMQAAMIfx3CDADHAAAjAAMIARWcJgDIAAAQAAMIfx3CDADHAAAqAAQKfygABBAACAjQIkIOAJACABAACAjQIkIOAJACABUABQhWB7F7AJAAACMAAwg1FSJ5AHgAAAAA.',['燃烧']='燃烧之灭:BAACKgAFFH8mAAQBAAYIRSFTEADlAAABAAQIVhpTEADlAAACAAMIUyAdEwCpAAADAAIIMSFFHABgAAAqAAQKf04ABAEACAhgJoEcABcCAAEABwgOJoEcABcCAAMABAh4Hr8SAGABAAIABQh8I6UsAEcBAAAA.燃烧军团丶:BAAAKgAECgcIBwAAAA==.',['爆头']='爆头属串:BAABKgAFFH8PAAMNAAYInx+iAADaAQANAAYIURyiAADaAQAMAAUI0BfaFQD3AAABKgAFFAgIEwAMAOUdAA==.',['牙齿']='牙齿遮了脸:BAABKgAFFH8IAAIUAAgIIAs3BQCSAQAUAAgIIAs3BQCSAQAAAA==.',['牛啸']='牛啸天:BAABKgAFFH8IAAIHAAgI+xuJFwBcAQAHAAgI+xuJFwBcAQAAAA==.',['牧牛']='牧牛:BAAAKgADCgEIAQAAAA==.',['特洛']='特洛伊:BAAAKgADCgEIAQAAAA==.',['犯罪']='犯罪丶刺客:BAAAKgADCggICAAAAA==.',['狂热']='狂热:BAAAKgAECgQIBAAAAA==.',['猎刄']='猎刄:BAAAKgADCgYIBgAAAA==.',['猪猪']='猪猪小:BAABKgAFFH8FAAIJAAMIrhhODQCeAAAJAAMIrhhODQCeAAAAAA==.',['猫手']='猫手猫脚:BAABKgAFFH8HAAIhAAQINBkmAwDQAAAhAAQINBkmAwDQAAABKgAFFAgIBAAFAAAAAA==.',['玉米']='玉米打窝:BAAAKgAECgIIAgAAAA==.',['玖弦']='玖弦:BAABKgAFFH8TAAIUAAQIvx0SFAD/AAAUAAQIvx0SFAD/AAAAAA==.',['玥夏']='玥夏:BAAAKgADCggIDAAAAA==.',['玥黠']='玥黠:BAAAKgADCgEIAQAAAA==.',['球球']='球球大王:BAACKgAFFH8GAAMMAAQIIwxaRACOAAAMAAQIIwxaRACOAAANAAIIHAUBTABPAAAqAAQKfyYAAyQACAioGnoEABgCACQACAioGnoEABgCAAwABAjVDFy2ALcAAAEqAAUUCAgTAAwA5R0A.',['畩嘫']='畩嘫豪氣冲天:BAAAKgAFFAYIBAABKgAFFAgICAAPALsbAA==.',['畫氵']='畫氵眉:BAAAKgAECgMIAwAAAA==.',['白夜']='白夜灬言兒:BAAAKgAFFAMIBAAAAA==.',['白小']='白小花:BAAAKgADCgYIBgAAAA==.',['白芷']='白芷沅夜:BAABKgAFFH8gAAIPAAYIahmaCQCsAQAPAAYIahmaCQCsAQAAAA==.',['皇家']='皇家天狼:BAAAKgAECggIDwAAAA==.',['真红']='真红伊藤:BAAAKgAECgIIAgAAAA==.',['硬又']='硬又嘿:BAAAKgAECggIEwAAAA==.',['磬风']='磬风:BAABKgAFFH8UAAIQAAQI8BlgDgDxAAAQAAQI8BlgDgDxAAAAAA==.',['神仙']='神仙大姐姐:BAAAKgAECgMIBQAAAA==.',['神羽']='神羽军:BAAAKgAECgMIAwAAAA==.',['禄存']='禄存:BAAAKgAFFAIIAgAAAA==.',['秋风']='秋风爱上落叶:BAABKgAFFH8OAAISAAQIhAkSJQCPAAASAAQIhAkSJQCPAAAAAA==.',['积雪']='积雪琴音:BAAAKgAFFAQIBAAAAA==.',['穆拉']='穆拉啶:BAABKgAFFH8FAAILAAUIDR/jCgBjAQALAAUIDR/jCgBjAQAAAA==.',['笨笨']='笨笨小玛:BAAAKgAECggIEAAAAA==.笨笨小馬:BAABKgAECn8UAAMEAAgIYRjeGwDzAQAEAAgIYRjeGwDzAQAWAAEIBRF5SQAyAAAAAA==.笨笨玛:BAABKgAECn8fAAMHAAgIsRfQLwDtAQAHAAgIsRfQLwDtAQAiAAEIUgg6QgAbAAAAAA==.笨笨馬:BAAAKgAFFAgIAQAAAA==.',['第七']='第七季冰河:BAAAKgAECgMIAwAAAA==.',['简居']='简居:BAAAKgAECgcICQAAAA==.',['箭破']='箭破苍穹猎:BAAAKgADCggIDgAAAA==.',['米线']='米线会飞:BAAAKgAECgQIBAAAAA==.',['粉蒸']='粉蒸鱼:BAAAKgADCgcIBwAAAA==.',['精灵']='精灵之火:BAACKgAFFH8JAAMUAAQIsQsBJQCRAAAUAAMIsQsBJQCRAAAHAAQIawNPSwCFAAAqAAQKfxsAAxQACAh+ETUtAEcBABQACAh+ETUtAEcBACIAAQiVBfw7AA0AAAAA.',['糖醋']='糖醋小姑姑:BAAAKgAECgQICAAAAA==.',['繁凌']='繁凌丶:BAAAKgAECgYIBgAAAA==.',['维爷']='维爷:BAABKgAFFH8SAAIRAAQIXxKVJADUAAARAAQIXxKVJADUAAAAAA==.',['绿茶']='绿茶加心机:BAABKgAFFH8MAAMMAAgIkhcWBQBQAgAMAAgISxcWBQBQAgANAAQIABqxCwDuAAAAAA==.',['翊富']='翊富:BAACKgAFFH8JAAIUAAMIBwLuFABdAAAUAAMIBwLuFABdAAAqAAQKfxsAAhQABwivB+EkAIYAABQABwivB+EkAIYAAAAA.',['老三']='老三这个人:BAABKgAFFH8GAAIdAAYI7w8yAgB4AQAdAAYI7w8yAgB4AQAAAA==.',['老道']='老道長:BAAAKgADCggICAAAAA==.',['联盟']='联盟丶法神:BAAAKgADCgEIAQAAAA==.',['聖銧']='聖銧襑塗:BAAAKgAECgUIBQAAAA==.',['肆一']='肆一:BAAAKgADCgEIAQAAAA==.',['肥志']='肥志:BAAAKgADCgEIAQAAAA==.',['肱菌']='肱菌灬太狡猾:BAAAKgAECgQIBwAAAA==.',['背带']='背带裤:BAABKgAFFH8NAAIZAAYIDRnqEgCDAQAZAAYIDRnqEgCDAQAAAA==.',['胖八']='胖八爷:BAABKgAFFH8LAAIPAAMI4Qw7OQCeAAAPAAMI4Qw7OQCeAAAAAA==.',['胸肌']='胸肌好看不:BAAAKgAECgIIAgAAAA==.',['脚卡']='脚卡巴有泥:BAAAKgAECggIAQAAAA==.',['自然']='自然卷饼:BAABKgAFFH8NAAIRAAQIUiJiKQDMAAARAAQIUiJiKQDMAAAAAA==.',['舒中']='舒中芬:BAABKgAFFH8GAAMUAAYIDgg5HADBAAAUAAUIIgc5HADBAAAHAAEIuAHyYQAzAAABKgAFFAgIBAAFAAAAAA==.',['芊叶']='芊叶孤尘:BAAAKgAECgIIAgAAAA==.',['苏格']='苏格儿:BAACKgAFFH8UAAMjAAYI3hXXFQA1AQAjAAYIlRXXFQA1AQAVAAQIihYvFQD6AAAqAAQKfxQAAxUACAilH2ocAEkCABUACAilH2ocAEkCABAABAiJEsCCAIsAAAAA.',['茉莉']='茉莉丶香香:BAAAKgAFFAQIBAAAAA==.',['莞娘']='莞娘:BAAAKgAECggICAAAAA==.',['菲菲']='菲菲雨雪:BAABKgAECn8cAAIRAAgIhBixUgDFAQARAAgIhBixUgDFAQAAAA==.菲菲雪儿:BAAAKgAECgIIAgAAAA==.',['萌丶']='萌丶小萨:BAAAKgADCgYIBgAAAA==.',['萌萌']='萌萌哒:BAAAKgAFFAgIBAAAAA==.',['萨总']='萨总来打工:BAAAKgAFFAYIBAAAAA==.',['萨柯']='萨柯尔:BAAAKgAECgQIBAAAAA==.',['葱茏']='葱茏弥漫:BAABKgAFFH8HAAMHAAUIAAsuOgC7AAAHAAQIaA0uOgC7AAAUAAMIrAMtKwB0AAAAAA==.',['蒂德']='蒂德丽特:BAAAKgAECggICAAAAA==.',['蓄意']='蓄意欧拉:BAAAKgAECgIIAgAAAA==.',['蓝山']='蓝山四世:BAAAKgADCgMIAwAAAA==.',['薛定']='薛定谔的喵:BAAAKgAECgQIBQAAAA==.',['虎哥']='虎哥的叉奴:BAAAKgAECgEIAQAAAA==.',['虚空']='虚空弥漫:BAAAKgAFFAIIAgAAAA==.',['蛤蜊']='蛤蜊炒蛋:BAAAKgAECgIIAgAAAA==.',['血族']='血族丶小宝儿:BAAAKgADCggICAAAAA==.血族丶巅峰:BAAAKgADCggICAAAAA==.',['装纯']='装纯卖可爱:BAABKgAFFH8GAAIEAAYIlRL1DQBzAQAEAAYIlRL1DQBzAQAAAA==.',['西北']='西北老汉:BAABKgAFFH8KAAIPAAYIbx7vBwDJAQAPAAYIbx7vBwDJAQAAAA==.',['要德']='要德要德:BAABKgAFFH8LAAQiAAQIFwvmCgBlAAAiAAQIFwvmCgBlAAAUAAIIUAENOAA7AAAHAAIIPAK4YwAsAAAAAA==.',['语盈']='语盈:BAAAKgAECgIIAgAAAA==.',['贝熙']='贝熙儿丶橙多:BAAAKgAFFAQIAQAAAA==.',['超小']='超小棉花糖:BAAAKgADCgcIBwAAAA==.',['超级']='超级战神剑剑:BAAAKgADCgMIAwAAAA==.',['跟上']='跟上跟上:BAAAKgAECgQIBAAAAA==.',['边城']='边城钢:BAAAKgAECgcICQAAAA==.',['这是']='这是什么邪法:BAACKgAFFH8bAAIOAAYIvhuDCAA0AQAOAAYIvhuDCAA0AQAqAAQKfxQAAg4ACAjBIyEPAK4CAA4ACAjBIyEPAK4CAAAA.',['那个']='那个目什么空:BAAAKgAFFAQIBAAAAA==.',['邪天']='邪天宫三脚蟾:BAAAKgAECggICAAAAA==.邪天騎:BAAAKgAFFAQIBAAAAA==.',['郁闷']='郁闷的阿偪:BAAAKgADCggICAAAAA==.',['酷胡']='酷胡萝卜:BAABKgAFFH8LAAIEAAYIoR1QCwCWAQAEAAYIoR1QCwCWAQAAAA==.',['醉梦']='醉梦如酒:BAAAKgADCgQIBAAAAA==.',['银瞳']='银瞳:BAAAKgAECggIEAAAAA==.',['阿呀']='阿呀呀:BAAAKgAECgUICAAAAA==.',['阿斯']='阿斯顿马飞:BAABKgAFFH8RAAMGAAcIoB4+AwAuAgAGAAcI6xw+AwAuAgAEAAYI9B9hCADUAQAAAA==.',['阿鲁']='阿鲁迪巴:BAAAKgAECgYIBgAAAA==.',['陌陌']='陌陌的馒头:BAAAKgAFFAIIBAAAAA==.',['雅典']='雅典没有娜:BAABKgAFFH8MAAILAAgIbga5DQA9AQALAAgIbga5DQA9AQAAAA==.',['雅琪']='雅琪萝贝:BAAAKgAFFAIIAgAAAA==.',['雨生']='雨生丶:BAAAKgADCgUIBQAAAA==.',['雪落']='雪落轻叹:BAAAKgAECgcIBwABKgAFFAQIBAAFAAAAAA==.',['雲丶']='雲丶墨:BAAAKgAECgYIBgAAAA==.',['雷雨']='雷雨时若:BAAAKgAECgYIBQAAAA==.',['霹雳']='霹雳手胡琛:BAABKgAFFH8FAAMSAAMIngssIACkAAASAAMIngssIACkAAATAAIIiwuREQCDAAAAAA==.',['顾尔']='顾尔丹:BAAAKgADCgEIAQAAAA==.',['顾清']='顾清涵:BAAAKgAECgIIAgAAAA==.',['风中']='风中的哀嚎:BAAAKgAFFAMIAwAAAA==.',['风影']='风影:BAABKgAFFH8GAAIRAAYIDhOXJABYAQARAAYIDhOXJABYAQAAAA==.',['风是']='风是无色河流:BAAAKgAFFAIIAgAAAA==.',['飕鰰']='飕鰰貔:BAACKgAFFH8FAAISAAIItQ+UKwBqAAASAAIItQ+UKwBqAAAqAAQKfx4AAxIACAj5F10aALYBABIACAj5F10aALYBABMABQhaBXBfAIEAAAAA.',['飞飞']='飞飞翔名将:BAABKgAFFH8HAAIEAAMI8RC6IwDDAAAEAAMI8RC6IwDDAAAAAA==.',['饺子']='饺子:BAAAKgAFFAQIBAAAAA==.',['魔兽']='魔兽之路神奇:BAACKgAFFH8cAAIlAAYIDSFKBwAMAQAlAAYIDSFKBwAMAQAqAAQKfyYAAiUACAhXJLoFAK8CACUACAhXJLoFAK8CAAAA.',['魔爪']='魔爪莫小莫:BAAAKgAECgcIBwAAAA==.',['黑眼']='黑眼圈照彩照:BAAAKgADCgIIAgAAAA==.',['黯稚']='黯稚:BAAAKgADCgYIBgAAAA==.',['龍啸']='龍啸丶邪骑:BAAAKgAECggICgAAAA==.',['龙煜']='龙煜:BAABKgAFFH8MAAMmAAYImR9XAACNAQAmAAUI/yBXAACNAQAaAAYICxJ0CAASAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end