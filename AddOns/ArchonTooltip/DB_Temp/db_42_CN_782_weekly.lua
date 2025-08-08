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
 local lookup = {'Shaman-Restoration','Druid-Balance','Druid-Feral','Druid-Restoration','Mage-Frost','Shaman-Enhancement','Shaman-Elemental','Priest-Shadow','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Mage-Arcane','Mage-Fire','Warlock-Affliction','Paladin-Retribution','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Druid-Guardian','Paladin-Protection','Warrior-Fury','DemonHunter-Havoc','Priest-Holy','Unknown-Unknown','Monk-Brewmaster','Warrior-Protection','DeathKnight-Unholy','Priest-Discipline','DemonHunter-Vengeance','Warrior-Arms','DeathKnight-Blood','Paladin-Holy','Evoker-Devastation','Rogue-Assassination',}; local provider = {region='CN',realm='索拉丁',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Anthea:BAAAKgAECggIAgAAAA==.',As='Asleeda:BAAAKgAFFAYIBAAAAA==.',Bi='Bingoyi:BAAAKgAFFAYIBAAAAA==.',Bl='Blibli:BAAAKgAFFAQIBAAAAA==.',Bo='Bobo:BAABKgAFFH8PAAIBAAgIYBNUBgDpAQABAAgIYBNUBgDpAQAAAA==.',Ca='Captain:BAAAKgAFFAEIAQAAAA==.',Ch='Chronnos:BAAAKgAECggICAAAAA==.',Ef='Efrosini:BAACKgAFFH8UAAICAAQINRfbLQDbAAACAAQINRfbLQDbAAAqAAQKfykABAIACAiLH9gVAIECAAIACAiLH9gVAIECAAMABgj0E64IAEEBAAQAAghLBqhwAD8AAAAA.',Ji='Jimo:BAABKgAECn8jAAIFAAgICxLCDQCeAQAFAAgICxLCDQCeAQAAAA==.',Le='Leedaehae:BAACKgAFFH8GAAIGAAYIKBlKBwBxAQAGAAYIKBlKBwBxAQAqAAQKfxQAAwcACAjZEtkyAHUBAAYACAiLDggmAJcBAAcABwgnE9kyAHUBAAAA.',Lu='Lucifersatan:BAAAKgAECggICwAAAA==.Luckytree:BAAAKgADCggICAAAAA==.',Ma='Masami:BAACKgAFFH8sAAIIAAgIChpuBgC/AQAIAAgIChpuBgC/AQAqAAQKfzAAAggACAg5Ij8MAIoCAAgACAg5Ij8MAIoCAAAA.',Mi='Mighost:BAAAKgAECgUIBwAAAA==.',Mx='Mxj:BAAAKgADCgEIAQAAAA==.',Mz='Mzghost:BAAAKgAECgYICQAAAA==.',Na='Nachtbult:BAAAKgAECggICAAAAA==.Narcisse:BAABKgAFFH8GAAIJAAQIpCIoEgAEAQAJAAQIpCIoEgAEAQABKgAFFAgICgAJAMERAA==.',No='Noble:BAAAKgAECggICAAAAA==.',Oe='Oenneo:BAAAKgAECgQIBAAAAA==.',Ov='Overloard:BAAAKgAECggICwAAAA==.',Pr='Proazrael:BAABKgAFFH8HAAIKAAQIthWaFQDOAAAKAAQIthWaFQDOAAAAAA==.Prodigall:BAAAKgAECgEIAQAAAA==.Prodk:BAAAKgAFFAQIBAAAAA==.Prominent:BAABKgAFFH8IAAMCAAQI9BReOADAAAACAAQI9BReOADAAAAEAAQIFwXxKQB8AAABKgAFFAgIDgAKAPkhAA==.Promising:BAAAKgAFFAgIBAAAAA==.Prosperity:BAAAKgADCggICAAAAA==.Prowarlock:BAABKgAFFH8IAAMKAAQINCIwCgAQAQAKAAQINCIwCgAQAQALAAEIAAD6IwAAAAAAAA==.',Sa='Salxzz:BAABKgAFFH8HAAMMAAMI9xV7JADRAAAMAAMIrRJ7JADRAAANAAIIaBj5KgCdAAAAAA==.',Se='Selena:BAACKgAFFH8JAAIBAAMIHgrNHgCKAAABAAMIHgrNHgCKAAAqAAQKfyEAAgEACAhQE6BDAGkBAAEACAhQE6BDAGkBAAAA.Serah:BAABKgAFFH8GAAIKAAQIbgqIGQC6AAAKAAQIbgqIGQC6AAABKgAFFAgIDAAOAMkiAA==.',Ta='Taric:BAAAKgADCgYIBgAAAA==.',Th='Thalia:BAAAKgAECggICAAAAA==.',Ti='Tianm:BAABKgAFFH8FAAIPAAUIAAc0SQDcAAAPAAUIAAc0SQDcAAAAAA==.',Wo='Wonderlandkk:BAAAKgAFFAEIAQAAAA==.Woshiniutou:BAAAKgAECggICQAAAA==.',['一个']='一个时代:BAABKgAFFH8LAAMCAAgIpQy3FAB1AQACAAcIygu3FAB1AQAEAAEIbAcMNgBDAAAAAA==.',['一八']='一八八四:BAAAKgAECgYIDgAAAA==.',['一套']='一套又一套:BAAAKgAECgIIAgAAAA==.',['一拳']='一拳穿天:BAAAKgAECggICAAAAA==.',['一箭']='一箭穿心:BAABKgAFFH8GAAIJAAMILhDRGQDHAAAJAAMILhDRGQDHAAAAAA==.',['七夜']='七夜晓晓圣君:BAABKgAFFH8GAAIQAAYIxxtGEQBaAQAQAAYIxxtGEQBaAQAAAA==.',['七岁']='七岁柠檬:BAACKgAFFH8WAAIJAAQITAwyNwC6AAAJAAQITAwyNwC6AAAqAAQKfyUAAgkACAhbF5QzANkBAAkACAhbF5QzANkBAAAA.',['万城']='万城时光:BAAAKgADCggICAAAAA==.',['三千']='三千阿堵:BAACKgAFFH8GAAIRAAMI/Ao2DgDJAAARAAMI/Ao2DgDJAAAqAAQKfx0AAxIACAgWGN0mAMIBABIACAgWGN0mAMIBABEABQg5EItJAN0AAAAA.',['不坏']='不坏:BAAAKgAFFAEIAQAAAA==.',['不知']='不知道叫啥名:BAAAKgAECgEIAQAAAA==.',['不行']='不行:BAAAKgAECgIIAgAAAA==.',['乐在']='乐在奇中:BAABKgAECn8lAAMJAAgIfhh2EwDwAQAJAAgIURh2EwDwAQAQAAYIcA1PZQDGAAAAAA==.乐在琦中:BAABKgAECn8rAAMCAAgIMBWCPgCuAQACAAgIQBSCPgCuAQATAAgI+Av/EgAdAQAAAA==.',['九月']='九月:BAAAKgADCgMIAwAAAA==.',['二十']='二十一克拉:BAABKgAECn8YAAMPAAgI/BdMZADSAQAPAAgI/BdMZADSAQAUAAEIwQKVYgAGAAAAAA==.',['二班']='二班同学:BAAAKgAECgYIDQAAAA==.',['亿人']='亿人斩:BAABKgAFFH8GAAIVAAMIuQMaKQCjAAAVAAMIuQMaKQCjAAAAAA==.',['亿刀']='亿刀久玖氿:BAAAKgADCgIIAgAAAA==.',['仙海']='仙海玉弓:BAAAKgAECgcIBwAAAA==.',['伊瑞']='伊瑞妲:BAABKgAFFH8IAAIWAAgI2RSJBwAkAgAWAAgI2RSJBwAkAgAAAA==.',['伊笑']='伊笑泯恩仇:BAABKgAECn8oAAMPAAgIzBiZTgDSAQAPAAgIzBiZTgDSAQAUAAgIcQYPMwDNAAAAAA==.',['休息']='休息一下:BAAAKgAECgcIDwAAAA==.',['低调']='低调地华丽:BAAAKgADCggICQAAAA==.',['余生']='余生难渡:BAABKgAECn8YAAIPAAgIqRoWSADoAQAPAAgIqRoWSADoAQAAAA==.',['佛法']='佛法无边无级:BAABKgAFFH8HAAIFAAQI1CAqCgAjAQAFAAQI1CAqCgAjAQABKgAFFAYIBgAXAEkIAA==.',['你愁']='你愁啥:BAAAKgADCgMIAwAAAA==.',['依然']='依然丶冷墨:BAAAKgADCgIIAgAAAA==.',['信仰']='信仰战:BAAAKgAFFAYIAgABKgAFFAgIBAAYAAAAAA==.',['傾聽']='傾聽輕唱:BAAAKgAECgIIAgAAAA==.',['光阴']='光阴之外:BAAAKgADCggIDwAAAA==.',['全镇']='全镇的希望:BAAAKgAECggICAAAAA==.',['其实']='其实我是死骑:BAAAKgAFFAgIBAAAAA==.',['兽头']='兽头骨气:BAABKgAECn8UAAMKAAgIDBuBGgDRAQAKAAgIDxqBGgDRAQALAAII9B3VbwBZAAAAAA==.',['兽眼']='兽眼通天:BAAAKgAECggIDAAAAA==.',['冥皇']='冥皇:BAABKgAFFH8HAAIPAAcIRhGeDgC4AQAPAAcIRhGeDgC4AQAAAA==.',['冰美']='冰美式一喵喵:BAABKgAFFH8MAAMKAAQIASGlCgAMAQAKAAQI4h6lCgAMAQALAAQI2hZbEAC6AAAAAA==.',['冻米']='冻米糖:BAABKgAECn8+AAMRAAgIYxI8LQBAAQARAAgIYxI8LQBAAQAZAAEIAgKEKwAIAAAAAA==.',['凌晴']='凌晴傲雪:BAABKgAFFH8OAAITAAQIbw0oCQB7AAATAAQIbw0oCQB7AAAAAA==.',['凭栏']='凭栏倚吞云烟:BAAAKgAECgIIAwAAAA==.',['凯莉']='凯莉洛克哈特:BAAAKgAECgUIBQAAAA==.',['凿一']='凿一安:BAAAKgAECgMIBAAAAA==.',['刀斩']='刀斩长腿:BAAAKgAECgQIBAAAAA==.',['刀板']='刀板香:BAABKgAECn8eAAMaAAgIFxF1HwAHAQAaAAgINQl1HwAHAQAVAAQIJRXvHQABAQAAAA==.',['别打']='别打了要碎了:BAAAKgAFFAIIAgAAAA==.',['别逼']='别逼我:BAAAKgAECgEIAQAAAA==.',['剩骑']='剩骑士:BAAAKgAFFAMIAwAAAA==.',['加谁']='加谁谁倒:BAAAKgAFFAQIBAAAAA==.',['化了']='化了劲了:BAAAKgAECgYIDgAAAA==.',['半吨']='半吨:BAAAKgAECgYICwAAAA==.',['卜耀']='卜耀霆:BAABKgAFFH8GAAIJAAYIKxyMCgCpAQAJAAYIKxyMCgCpAQAAAA==.',['反方']='反方向的钟:BAABKgAFFH8GAAIUAAYI3AiOFADUAAAUAAYI3AiOFADUAAAAAA==.',['叮铃']='叮铃铛狼:BAABKgAFFH8IAAIbAAgI7hbBBQBAAgAbAAgI7hbBBQBAAgAAAA==.',['叹半']='叹半世浮华:BAAAKgAFFAMIAwAAAA==.',['吃了']='吃了莓:BAABKgAFFH8MAAIWAAYI2BThEAB8AQAWAAYI2BThEAB8AQAAAA==.',['名字']='名字并不重要:BAAAKgAECggIEAAAAA==.',['后弦']='后弦:BAAAKgAECgUIBgAAAA==.',['吴一']='吴一凡:BAAAKgAFFAIIAgAAAA==.',['呜狐']='呜狐呜狐:BAAAKgADCggICAAAAA==.',['咕噜']='咕噜牙牙:BAAAKgAECgIIAgAAAA==.',['咖啡']='咖啡加牛奶:BAAAKgAECgUIBQAAAA==.',['咖喱']='咖喱给给:BAAAKgAECgIIAgAAAA==.',['嗜杀']='嗜杀冥皇:BAAAKgAFFAgIBAAAAA==.',['嗜血']='嗜血狂骑:BAAAKgAECgEIAQAAAA==.嗜血雷神:BAAAKgAECgQIBAAAAA==.嗜血龍:BAAAKgAECgEIAQAAAA==.',['四维']='四维三三丶:BAABKgAFFH8GAAIBAAYIWhJyEQBJAQABAAYIWhJyEQBJAQAAAA==.',['回忆']='回忆从前:BAAAKgAECgIIAwAAAA==.回忆思念瘦:BAAAKgAECgYIBgAAAA==.',['国宝']='国宝壹号:BAACKgAFFH8IAAISAAMIrxFsHAC7AAASAAMIrxFsHAC7AAAqAAQKfxYAAhIACAiTEnofAI0BABIACAiTEnofAI0BAAAA.',['圣光']='圣光璀璨:BAAAKgAECgQIBAAAAA==.圣光的魔女:BAAAKgADCgYIBgAAAA==.圣光送葬者:BAABKgAFFH8KAAIPAAUIGAd8IQDiAAAPAAUIGAd8IQDiAAAAAA==.',['坚石']='坚石萨:BAABKgAFFH8IAAIBAAQITxvDCAARAQABAAQITxvDCAARAQAAAA==.',['塔奇']='塔奇克码:BAAAKgAFFAEIAgAAAA==.塔奇克马:BAACKgAFFH8VAAIIAAUIwg53EQD3AAAIAAUIwg53EQD3AAAqAAQKfxcAAxwACAgEFDwoAJMBABwACAgEFDwoAJMBAAgABAgqDkFRAKcAAAAA.',['塔玛']='塔玛西亚:BAAAKgAECgMIAwAAAA==.',['夏咯']='夏咯蒂:BAABKgAFFH8MAAIWAAQIfRUeFQDsAAAWAAQIfRUeFQDsAAABKgAFFAgILQAJAMMeAA==.',['夏末']='夏末梧桐:BAABKgAECn8cAAMEAAgIfhouFgATAgAEAAgIfhouFgATAgACAAgIOB0nPgC+AQAAAA==.',['夜天']='夜天子:BAAAKgAECgYIBgAAAA==.',['夜聆']='夜聆枫:BAAAKgADCggICAAAAA==.',['大明']='大明一狂人:BAAAKgAECgUICQAAAA==.',['大米']='大米锅巴:BAAAKgAECgIIAwAAAA==.',['天启']='天启印:BAAAKgAECgYIBwAAAA==.',['天天']='天天锤:BAAAKgAECggIDgAAAA==.天天锤胖子:BAAAKgAFFAQIBAAAAA==.天天锤胖胖:BAABKgAFFH8GAAIJAAYIShUgFQBMAQAJAAYIShUgFQBMAQAAAA==.天天锤贴贴:BAABKgAFFH8GAAMRAAQIPgjjGABpAAARAAMIPgjjGABpAAASAAMIgg83LABnAAAAAA==.',['天暗']='天暗星:BAABKgAFFH8IAAIdAAQIhgoMDACiAAAdAAQIhgoMDACiAAAAAA==.',['天降']='天降之物:BAAAKgAECgYIBgAAAA==.',['天魔']='天魔隼:BAAAKgAECgQIBAAAAA==.',['失心']='失心:BAAAKgAECgYIBgAAAA==.',['奈乐']='奈乐缇香:BAAAKgAECgMIAwAAAA==.',['奥丁']='奥丁:BAAAKgAFFAYIAgAAAA==.',['奶色']='奶色的鹏:BAAAKgADCgcICAAAAA==.',['好运']='好运的小熊:BAACKgAFFH8gAAIJAAQIORpJGQDtAAAJAAQIORpJGQDtAAAqAAQKfzgAAgkACAh3ImMgAHUCAAkACAh3ImMgAHUCAAAA.',['妖妖']='妖妖凛:BAABKgAFFH8FAAIHAAQIQQ56GQCuAAAHAAQIQQ56GQCuAAAAAA==.',['妞灬']='妞灬美的单纯:BAAAKgAECggICAAAAA==.',['姜子']='姜子牙疼:BAAAKgAECgcIEAAAAA==.',['娅非']='娅非拉:BAAAKgAECggIDAAAAA==.',['婉清']='婉清:BAABKgAFFH8JAAIXAAMIrBmKDwDTAAAXAAMIrBmKDwDTAAAAAA==.',['孤独']='孤独的树:BAAAKgAECgUICQAAAA==.',['安娜']='安娜丝塔西雅:BAAAKgAFFAYIAgABKgAFFAgIBAAYAAAAAA==.',['将心']='将心比心:BAAAKgAECgYIBgAAAA==.',['小丨']='小丨猎丨人丨:BAAAKgAFFAMIAwAAAA==.',['小小']='小小倬雅:BAABKgAFFH8GAAIBAAYI1gTmHQAEAQABAAYI1gTmHQAEAQAAAA==.小小萨满:BAAAKgAECgIIAgAAAA==.',['小尒']='小尒:BAAAKgADCggICAAAAA==.',['小沙']='小沙弥:BAAAKgADCgYIBgAAAA==.',['小涵']='小涵:BAABKgAFFH8JAAMXAAgImBdbCACiAQAXAAYIoRtbCACiAQAcAAMIIQoRGQDJAAAAAA==.',['小瓶']='小瓶阔落:BAAAKgAECggICAAAAA==.',['小米']='小米锅巴:BAAAKgAECgQIBAAAAA==.',['小红']='小红手:BAAAKgAFFAQIAwAAAA==.',['小菜']='小菜依蝶:BAABKgAFFH8IAAIQAAQI7Rw6EABkAQAQAAQI7Rw6EABkAQAAAA==.',['小龙']='小龙人四维:BAAAKgAFFAQIBAAAAA==.',['尐超']='尐超:BAAAKgAECggIEgAAAA==.',['尒吖']='尒吖:BAAAKgADCgYICQAAAA==.',['尝新']='尝新鲜:BAAAKgADCgUIBQAAAA==.',['尼古']='尼古拉斯肇事:BAAAKgADCggIDAAAAA==.',['岁阳']='岁阳:BAAAKgAECgUIBQAAAA==.',['巴鲁']='巴鲁鲁:BAAAKgAECggICAAAAA==.',['布丁']='布丁可可:BAAAKgADCgQIAgAAAA==.',['幻想']='幻想的猎手:BAAAKgAECgUICQAAAA==.',['幻缘']='幻缘:BAABKgAFFH8jAAIaAAYIBQxfCADiAAAaAAYIBQxfCADiAAAAAA==.',['幽冥']='幽冥猫:BAAAKgADCgQIBAAAAA==.',['弑魔']='弑魔者之殇:BAAAKgAECgUIBQAAAA==.',['弗洛']='弗洛伦斯:BAABKgAECn8eAAIXAAgI2R2IEQBFAgAXAAgI2R2IEQBFAgAAAA==.',['张大']='张大仙:BAAAKgAFFAEIAQAAAA==.',['往者']='往者已矣:BAAAKgAECgMIAwAAAA==.',['徳古']='徳古拉:BAACKgAFFH8sAAIPAAgIvhexFwCfAQAPAAgIvhexFwCfAQAqAAQKfy8AAg8ACAjxJG8kAIkCAA8ACAjxJG8kAIkCAAAA.',['德萨']='德萨司:BAAAKgAECgQIBwAAAA==.',['怪战']='怪战阿男:BAAAKgADCgIIAgAAAA==.',['怪戰']='怪戰阿男:BAAAKgADCgQIBQAAAA==.',['悠然']='悠然自德:BAAAKgAECgYIDQAAAA==.',['愤怒']='愤怒的辣椒:BAAAKgADCgUIBQAAAA==.',['懵圈']='懵圈界的千语:BAAAKgAFFAIIAgABKgAFFAgIAgAYAAAAAA==.',['我叫']='我叫一百六:BAACKgAFFH8bAAIBAAYI8SU5AAAsAgABAAYI8SU5AAAsAgAqAAQKfx4AAgEACAgxIPMcACcCAAEACAgxIPMcACcCAAAA.',['我是']='我是老六:BAAAKgADCgMIAwAAAA==.',['我来']='我来组成臀部:BAABKgAFFH8QAAMEAAYIgBuUBwCWAQAEAAYIgBuUBwCWAQACAAYIARKEGgBGAQABKgAFFAgIEAANAKcaAA==.',['拉贵']='拉贵尔昔拉:BAABKgAFFH8OAAIPAAYIviPFDAABAgAPAAYIviPFDAABAgAAAA==.',['掏粪']='掏粪男孩:BAAAKgAFFAQIBAAAAA==.',['搜狐']='搜狐:BAACKgAFFH8NAAMHAAQIEh3rCQDzAAAHAAMIEh3rCQDzAAABAAQIZAwvGwC1AAAqAAQKfx4AAwcACAhDHlcWABkCAAcACAhDHlcWABkCAAEAAghcCKWtAFsAAAAA.',['搞七']='搞七捻三:BAABKgAECn9NAAIFAAgIrh4bDwBVAgAFAAgIrh4bDwBVAgAAAA==.',['搞桼']='搞桼捻彡:BAABKgAFFH8QAAMeAAgIEiABAQC2AgAeAAgIEiABAQC2AgAVAAgIhBIKBQBPAgAAAA==.',['断悦']='断悦愁:BAAAKgAFFAQIBAAAAA==.',['断情']='断情绝爱霄:BAAAKgAECggICAAAAA==.',['断罪']='断罪之翼:BAABKgAFFH8GAAIXAAYISQgoFQALAQAXAAYISQgoFQALAQAAAA==.',['斯高']='斯高易的坝坝:BAAAKgAECgEIAQAAAA==.',['新天']='新天地酒吧:BAAAKgAECgQIBAAAAA==.',['无心']='无心骑士:BAABKgAFFH8IAAIfAAgI6QQ2BwA5AQAfAAgI6QQ2BwA5AQAAAA==.',['无敌']='无敌暴龙兽:BAABKgAFFH8GAAMgAAMI8RFzDgDPAAAgAAMI8RFzDgDPAAAPAAMIOQheYgCrAAAAAA==.',['星坠']='星坠苍穹:BAAAKgAECggIEAAAAA==.',['星岚']='星岚幽梦:BAABKgAFFH8WAAMJAAQIDgp7HgCqAAAJAAQIDgp7HgCqAAAQAAIISwB7WAAUAAAAAA==.',['星恋']='星恋尘:BAAAKgADCgMIAwAAAA==.',['暮光']='暮光之莐:BAAAKgAECgEIAQAAAA==.',['暮诗']='暮诗:BAABKgAFFH8QAAIXAAYIjhRPEADJAAAXAAYIjhRPEADJAAABKgAFFAgICgAXAJMQAA==.',['暴躁']='暴躁的演员:BAABKgAFFH8KAAMCAAgIgh9oCwDeAQACAAcIgCFoCwDeAQAEAAEI3xTJMwBKAAAAAA==.',['書心']='書心墨韵:BAACKgAFFH8mAAIUAAYI9AnvFADRAAAUAAYI9AnvFADRAAAqAAQKfxwAAxQACAh5EHQzAMsAABQACAh5EHQzAMsAAA8ABQiZAlU/AW0AAAAA.',['曼哈']='曼哈頓博士:BAAAKgADCgIIAgAAAA==.',['最佳']='最佳拍档:BAAAKgAECgMIAwAAAA==.',['月影']='月影無雙:BAABKgAFFH8LAAIZAAMIIgY6CQB2AAAZAAMIIgY6CQB2AAAAAA==.',['木野']='木野真琴:BAAAKgADCggIEAAAAA==.',['朵娜']='朵娜贝拉:BAAAKgAFFAYIAgAAAA==.',['机智']='机智的沐丝:BAAAKgAFFAQIBAAAAA==.',['机电']='机电实物:BAAAKgAECgcIDAAAAA==.',['李小']='李小龙:BAAAKgADCggICAAAAA==.',['极品']='极品狼王:BAACKgAFFH8OAAIJAAMIKxFjMQDHAAAJAAMIKxFjMQDHAAAqAAQKfzEAAwkACAjCHh0JAIACAAkACAjCHh0JAIACABAAAQjDDS9MACwAAAAA.',['梦里']='梦里浅笑:BAAAKgAECggICAAAAA==.',['楚天']='楚天歌:BAAAKgAECggIEAAAAA==.',['樱满']='樱满集:BAAAKgAECggIBgAAAA==.',['橙色']='橙色脆皮鸡:BAAAKgAFFAIIAgAAAA==.',['歐萊']='歐萊雅:BAAAKgADCgYIBgAAAA==.',['死亡']='死亡即是新生:BAABKgAFFH8NAAMfAAUI0AgjDAC5AAAfAAUI0AgjDAC5AAAbAAEI+ABtIwAXAAAAAA==.',['毛毛']='毛毛虫的情:BAAAKgAECgUIBQAAAA==.',['水翦']='水翦影:BAAAKgADCgQIBAAAAA==.',['永恒']='永恒的哀伤:BAAAKgAECgQIBAAAAA==.',['江城']='江城子:BAAAKgADCgYIBgAAAA==.',['没名']='没名气:BAAAKgADCgQIBAAAAA==.',['没有']='没有过的曾经:BAAAKgADCgIIAgAAAA==.',['法丝']='法丝真来斯:BAAAKgAECgIIAgAAAA==.',['法无']='法无垢:BAAAKgADCgMIAwAAAA==.',['法湿']='法湿:BAAAKgAECgQIBAAAAA==.',['法神']='法神天使:BAABKgAFFH8FAAMMAAMIrwetHQCWAAAMAAMITgetHQCWAAAFAAEIxwexLQAyAAAAAA==.',['泯魂']='泯魂:BAAAKgAECgUIBwAAAA==.',['派大']='派大狗:BAAAKgADCggICAAAAA==.',['流星']='流星之缘:BAABKgAFFH8LAAIfAAQIPAJqLgBXAAAfAAQIPAJqLgBXAAAAAA==.',['淘浆']='淘浆糊:BAAAKgAECgYICQAAAA==.',['清晨']='清晨丶夜太魅:BAABKgAFFH8KAAIUAAgINgdjDAAxAQAUAAgINgdjDAAxAQAAAA==.',['清音']='清音雅月:BAAAKgADCgUIBQAAAA==.',['湿透']='湿透的小猫咪:BAAAKgADCggICAAAAA==.',['火神']='火神:BAABKgAFFH8FAAIMAAUIRhQlGAAjAQAMAAUIRhQlGAAjAQAAAA==.',['灭团']='灭团灬星:BAABKgAFFH8GAAIWAAYI2wjGGQAvAQAWAAYI2wjGGQAvAQAAAA==.',['灰影']='灰影:BAAAKgADCgMIAwAAAA==.',['炒冰']='炒冰:BAAAKgADCggICAAAAA==.',['焱霜']='焱霜:BAAAKgAECgQIBAAAAA==.',['熔岩']='熔岩爆裂:BAAAKgAECggICAAAAA==.',['爱情']='爱情海的港湾:BAABKgAFFH8MAAICAAQIaxC/OAC/AAACAAQIaxC/OAC/AAAAAA==.',['狮心']='狮心王:BAAAKgAFFAQIBAAAAA==.',['玉米']='玉米:BAAAKgAECgEIAQAAAA==.',['玉见']='玉见津弥:BAAAKgAFFAEIAQAAAA==.',['现役']='现役熬夜冠军:BAAAKgAFFAEIAQAAAA==.',['琴啡']='琴啡嘚已:BAAAKgAECgUIBQAAAA==.',['由月']='由月与地:BAAAKgAECggICAAAAA==.',['电梯']='电梯征服者:BAABKgAECn8VAAIeAAgIZBejEgAjAgAeAAgIZBejEgAjAgAAAA==.',['白日']='白日梦:BAAAKgAFFAMIAwAAAA==.',['看我']='看我眼里有光:BAABKgAFFH8KAAIWAAYIoBG/FABUAQAWAAYIoBG/FABUAQABKgAFFAgIBgAWAOsJAA==.',['瞑丶']='瞑丶:BAAAKgAECgQIBgAAAA==.',['神圣']='神圣的小熊:BAAAKgADCgMIAwAAAA==.',['离子']='离子通道:BAAAKgADCgIIAgAAAA==.',['秋水']='秋水落霞:BAABKgAECn8UAAIPAAgIbyYnAwAWAwAPAAgIbyYnAwAWAwAAAA==.',['秦无']='秦无衣:BAABKgAFFH8MAAIPAAYI5x9LEgDKAQAPAAYI5x9LEgDKAQAAAA==.',['突灬']='突灬突突:BAABKgAFFH8GAAIJAAYINRfBEgBhAQAJAAYINRfBEgBhAQAAAA==.',['粉蒸']='粉蒸肉:BAABKgAECn8eAAIhAAYIYgpNJAB6AAAhAAYIYgpNJAB6AAAAAA==.',['糟老']='糟老头子:BAAAKgAECgcIDwAAAA==.',['紫玉']='紫玉玲珑:BAABKgAFFH8YAAIdAAQInQ2PCwCZAAAdAAQInQ2PCwCZAAAAAA==.',['紫陌']='紫陌琴韵:BAAAKgAFFAMIAwAAAA==.',['緣語']='緣語軒:BAABKgAFFH8NAAIcAAMImADxMgA7AAAcAAMImADxMgA7AAAAAA==.',['红色']='红色大姨夫:BAAAKgAFFAMIAwAAAA==.',['给我']='给我奶住:BAABKgAECn8bAAMaAAgI1gweIwATAQAaAAgI1gweIwATAQAVAAYIQwMpYACIAAAAAA==.',['缺啥']='缺啥:BAABKgAFFH8IAAMCAAQIBhXOGADbAAACAAQIBhXOGADbAAAEAAEIFgYlJQA1AAAAAA==.',['羊肉']='羊肉藏在书里:BAAAKgAECggICQAAAA==.',['翱翱']='翱翱:BAAAKgADCgIIAgAAAA==.',['耂王']='耂王:BAAAKgAECgUIBQAAAA==.耂王爱你哦:BAAAKgAECgMIAwAAAA==.',['聚散']='聚散如沙:BAAAKgADCggICAAAAA==.',['肉烧']='肉烧饼:BAACKgAFFH8JAAIPAAMIxxNeTADWAAAPAAMIxxNeTADWAAAqAAQKfzcAAg8ACAhHIts0AFECAA8ACAhHIts0AFECAAAA.',['肥牛']='肥牛牛:BAAAKgAECgcICwAAAA==.',['能力']='能力小责任小:BAABKgAFFH8IAAQXAAYICxcqHwDMAAAXAAQI6BwqHwDMAAAIAAMIeA2sIgBRAAAcAAEIXgk4MQBJAAABKgAFFAgICgAXANkWAA==.',['臭桂']='臭桂鱼:BAABKgAECn8nAAIJAAgIpR8hCACRAgAJAAgIpR8hCACRAgAAAA==.',['至始']='至始至终:BAAAKgAFFAYIBAAAAA==.',['舒丶']='舒丶淇:BAAAKgAECgIIAgAAAA==.',['舟舟']='舟舟:BAAAKgADCgUIBQAAAA==.',['色丨']='色丨色:BAAAKgAECgUIBQAAAA==.',['芒果']='芒果海苔:BAAAKgAECgQIBgAAAA==.',['芝麻']='芝麻狐:BAAAKgAFFAQIBAAAAA==.',['花开']='花开浅陌丶:BAAAKgAECgEIAQAAAA==.',['苞芦']='苞芦馃:BAABKgAECn8jAAQLAAgInxDlMQAvAQALAAgInxDlMQAvAQAKAAMI+QaSkABqAAAOAAEIAACRUAAAAAAAAA==.',['苹果']='苹果橘子橙:BAAAKgAECgEIAQAAAA==.',['莉莉']='莉莉斯:BAAAKgADCgMIAwAAAA==.',['菊花']='菊花毁灭者:BAAAKgAECgIIBgAAAA==.',['萨幔']='萨幔:BAAAKgAFFAMIAwAAAA==.',['萨神']='萨神:BAABKgAFFH8HAAIGAAYIVg5VDgDpAAAGAAYIVg5VDgDpAAAAAA==.',['萨耳']='萨耳:BAABKgAECn8fAAIHAAgIOgq3OgBHAQAHAAgIOgq3OgBHAQAAAA==.',['葛粉']='葛粉丸:BAABKgAECn8pAAIIAAgIbhG4LwAWAQAIAAgIbhG4LwAWAQAAAA==.',['蓝凤']='蓝凤凰吉祥:BAAAKgADCgMIAwAAAA==.',['蓝色']='蓝色体育生:BAAAKgAECgIIAgAAAA==.',['薄荷']='薄荷芋头:BAABKgAFFH8IAAISAAgIOxICBQDcAQASAAgIOxICBQDcAQAAAA==.',['蘑咕']='蘑咕力:BAABKgAFFH8LAAQEAAgIDQjVCAAQAQAEAAYIwATVCAAQAQACAAMIzw4cHwC4AAATAAII6wVHCABCAAAAAA==.',['被風']='被風熄滅:BAAAKgAECgcICwABKgAECggICwAYAAAAAA==.',['詩与']='詩与逺方:BAAAKgAECgcIBwAAAA==.',['识濑']='识濑就濑條界:BAAAKgAFFAMIAwAAAA==.',['诗菡']='诗菡:BAAAKgAECgUIBQAAAA==.',['谢拉']='谢拉丶卡珊娜:BAAAKgAFFAQIBAAAAA==.',['赚杯']='赚杯咖啡钱:BAAAKgAECgEIAQAAAA==.',['赵无']='赵无眠:BAAAKgAECgIIAgABKgAECgMIAwAYAAAAAA==.',['踩踩']='踩踩:BAAAKgAFFAEIAgAAAA==.',['身后']='身后有尾巴捏:BAAAKgADCgYIBgAAAA==.',['辞镜']='辞镜:BAABKgAFFH8GAAIMAAYIORd3EwBJAQAMAAYIORd3EwBJAQAAAA==.',['迟到']='迟到的幸福:BAAAKgAECggIBwAAAA==.',['迪皮']='迪皮诶斯:BAAAKgAFFAMIBAAAAA==.',['邊渡']='邊渡友次子:BAAAKgAFFAMIAwAAAA==.',['钟觉']='钟觉浅:BAAAKgAECgMIAwAAAA==.',['锁甲']='锁甲三废:BAAAKgAECgMIBQAAAA==.',['锦鲤']='锦鲤杨超越:BAAAKgAECgQIBAAAAA==.',['阴影']='阴影之刺:BAABKgAECn8jAAIhAAgIwQzREwA9AQAhAAgIwQzREwA9AQAAAA==.',['阿咔']='阿咔莎:BAACKgAFFH8dAAIXAAQIsR7TFwD3AAAXAAQIsR7TFwD3AAAqAAQKfyUAAhcACAhxIxQIAJ4CABcACAhxIxQIAJ4CAAAA.',['阿塔']='阿塔蘭忒:BAAAKgAFFAMIAwAAAA==.',['阿尓']='阿尓托莉雅:BAABKgAFFH8FAAIPAAMIcwSHbgCOAAAPAAMIcwSHbgCOAAAAAA==.',['阿释']='阿释密达:BAABKgAFFH8GAAIPAAYIJBIaHwB0AQAPAAYIJBIaHwB0AQAAAA==.',['陆小']='陆小添:BAABKgAFFH8GAAIPAAYInh88AQDsAQAPAAYInh88AQDsAQAAAA==.',['雨风']='雨风:BAAAKgAECgIIAgAAAA==.',['雪桐']='雪桐:BAAAKgADCgQIBAAAAA==.',['雪河']='雪河:BAAAKgAFFAYIBAAAAA==.',['雪猪']='雪猪猪:BAAAKgAFFAMIAQAAAA==.',['零度']='零度:BAAAKgAECgIIAgAAAA==.',['雷鸣']='雷鸣八卦:BAAAKgAECggICwAAAA==.',['霜冷']='霜冷九洲:BAABKgAECn8dAAQXAAgI7xWjJgC2AQAXAAgIshSjJgC2AQAIAAgIGBWeJQCpAQAcAAIIpwu7eQBiAAAAAA==.',['露露']='露露姆:BAAAKgAECgIIAgAAAA==.',['霸王']='霸王茶姬:BAAAKgAECgcIBwAAAA==.',['韭菜']='韭菜馃:BAABKgAECn8gAAQTAAgIWBfEDACKAQATAAgI0RLEDACKAQACAAQIWBRseAD0AAADAAEIWgaNLgA2AAAAAA==.',['顶市']='顶市酥:BAABKgAECn8jAAMWAAgIIxbZEgDSAQAWAAgIIxbZEgDSAQAdAAEIpQhIbwAmAAAAAA==.',['飄渺']='飄渺無踪:BAABKgAFFH8QAAMBAAMIrgIYSwBgAAABAAMIrgIYSwBgAAAHAAIIjgCnKAA4AAAAAA==.',['风中']='风中烛影:BAAAKgAECgYIBwAAAA==.',['风的']='风的追逐:BAAAKgAECgUIBQAAAA==.',['风雨']='风雨同舟:BAAAKgAECgQIBAAAAA==.',['飞翔']='飞翔的小麻雀:BAAAKgAFFAEIAQAAAA==.',['高振']='高振钊:BAABKgAFFH8FAAIeAAMIyAh1GwCvAAAeAAMIyAh1GwCvAAAAAA==.',['魂之']='魂之明:BAACKgAFFH8HAAIVAAQIuA7SEgDtAAAVAAQIuA7SEgDtAAAqAAQKfygAAhUACAiRGwskAAMCABUACAiRGwskAAMCAAAA.',['魔兽']='魔兽世界:BAAAKgAFFAgIAgAAAA==.',['魔鬼']='魔鬼咬巫婆:BAACKgAFFH8LAAIXAAMIlBjZHQDTAAAXAAMIlBjZHQDTAAAqAAQKfzMAAxcACAhMHuAnAK8BABcACAhMHuAnAK8BABwAAQgqBJ6fABsAAAAA.',['鸭梨']='鸭梨球:BAAAKgAECgQIBgAAAA==.',['麦唛']='麦唛的武僧:BAAAKgADCggICAAAAA==.',['麻辣']='麻辣汤:BAABKgAFFH8PAAIcAAMIZw/xDQCYAAAcAAMIZw/xDQCYAAAAAA==.',['麻酥']='麻酥糖:BAABKgAECn8tAAIiAAgIqg/5HQCQAQAiAAgIqg/5HQCQAQAAAA==.',['黑暗']='黑暗之光:BAAAKgADCggICAAAAA==.',['黑米']='黑米糕:BAABKgAECn8fAAIbAAgI3xWFLADJAQAbAAgI3xWFLADJAQAAAA==.',['黑豆']='黑豆腐:BAAAKgAECggIDAAAAA==.',['龙裔']='龙裔:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end