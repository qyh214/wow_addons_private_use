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
 local lookup = {'Priest-Holy','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Mage-Frost','Mage-Fire','Paladin-Retribution','Mage-Arcane','Evoker-Preservation','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Druid-Balance','Druid-Restoration','Warrior-Protection','Warrior-Fury','DemonHunter-Havoc','Paladin-Protection','Warrior-Arms','DeathKnight-Blood','Priest-Discipline','Unknown-Unknown','Hunter-Survival','Monk-Mistweaver','Monk-Windwalker','Rogue-Assassination','Rogue-Subtlety','Shaman-Enhancement','Paladin-Holy','Warlock-Demonology','DeathKnight-Frost',}; local provider = {region='CN',realm='奈萨里奥',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Angelcat:BAAAKgAECgYIBgAAAA==.',Ar='Arion:BAAAKgAECgYIBgAAAA==.',Be='Because:BAABKgAFFH8GAAMBAAYIChN0GgDmAAABAAUIKBB0GgDmAAACAAEI7wCEMQAxAAABKgAFFAgICgABANkWAA==.',Bl='Bloodwarlock:BAABKgAECn82AAMDAAgILCHSAgCtAgADAAgILCHSAgCtAgAEAAIIexxoOABQAAAAAA==.',Cc='Ccmilk:BAAAKgAECgMIBAAAAA==.',Da='Darkknight:BAABKgAECn8VAAIFAAgI+g0+SABRAQAFAAgI+g0+SABRAQAAAA==.Darkleaf:BAAAKgAECggIDQAAAA==.Darknight:BAAAKgAECggIDAAAAA==.Darkprayer:BAAAKgAECgcIEgAAAA==.Darkshadow:BAAAKgAECggIDwAAAA==.Darksouler:BAAAKgAECggIDwAAAA==.Darkvalkyrie:BAABKgAECn8tAAIGAAgI6CGaCACmAgAGAAgI6CGaCACmAgAAAA==.',Dc='Dcsakura:BAABKgAFFH8MAAMHAAYIGBeFDQBhAQAHAAYIFReFDQBhAQAGAAQIbBZnCQDiAAAAAA==.',De='Degeneracy:BAAAKgADCgEIAQAAAA==.',Ev='Even:BAAAKgADCgcIBwAAAA==.Evenaddicted:BAAAKgAECgUIBwAAAA==.Evenblossom:BAAAKgAECgEIAQAAAA==.Evilsmile:BAAAKgAECgYIDAAAAA==.',Fa='Fatalviolet:BAAAKgADCgEIAQAAAA==.',Gr='Grimrak:BAABKgAECn8eAAIFAAgIKw4IRwBVAQAFAAgIKw4IRwBVAQAAAA==.',Hu='Hugme:BAAAKgADCgEIAQAAAA==.',Ik='Ikuzo:BAABKgAFFH8IAAIIAAQIHyHxDgAYAQAIAAQIHyHxDgAYAQAAAA==.',In='Injoker:BAAAKgADCggICAAAAA==.',La='Lancelots:BAABKgAECn8VAAIIAAgICx12NQBPAgAIAAgICx12NQBPAgAAAA==.',Li='Linda:BAAAKgAECggICAAAAA==.',Lo='Lovja:BAAAKgAECgYIBgAAAA==.',Ma='Mana:BAABKgAFFH8eAAQJAAgIKxSLBwAHAgAJAAgIrhOLBwAHAgAHAAgIqQcFBADhAQAGAAYIdQqCCwARAQAAAA==.Marigolld:BAAAKgAFFAYIBAAAAA==.Marquez:BAACKgAFFH8IAAIKAAIInBkpBgCaAAAKAAIInBkpBgCaAAAqAAQKfyMAAwoACAg4HFIFAEUCAAoACAg4HFIFAEUCAAsAAgjxCMZcAFMAAAAA.',Mi='Mill:BAAAKgAECggIBwAAAA==.',Ne='Nessaj:BAAAKgAECgMIBQAAAA==.',Ol='Oldgun:BAABKgAFFH8IAAMMAAYI1BbOAwCeAQAMAAYITRbOAwCeAQANAAIIVxURFwCpAAAAAA==.',Pe='Pense:BAAAKgADCggICAAAAA==.',Pr='Prayrain:BAABKgAECn8XAAIOAAgIZRC8WgAvAQAOAAgIZRC8WgAvAQAAAA==.',Ra='Rayfs:BAAAKgAECggICAAAAA==.',Ro='Roue:BAAAKgAECgQIBAAAAA==.Royle:BAABKgAFFH8IAAIDAAYI4xoBAwCgAQADAAYI4xoBAwCgAQAAAA==.',Se='Selene:BAAAKgAECgQIBwAAAA==.',So='Soloshow:BAAAKgAFFAQIBAABKgAFFAYIGAAPALkkAA==.',Ti='Tiefang:BAAAKgAFFAEIAQABKgAFFAgIHgAOABseAA==.Tiibei:BAAAKgAFFAIIAgAAAA==.',Va='Vacation:BAAAKgAECgYIBgAAAA==.Vaxiya:BAAAKgAECgQIAgAAAA==.',We='Welen:BAAAKgAECgUIBwAAAA==.Wen:BAAAKgAECggICAAAAA==.',Zh='Zhouziqi:BAAAKgADCggICAAAAA==.',['一之']='一之黑亚梨子:BAABKgAFFH8OAAIOAAgIFyDLAwAUAgAOAAgIFyDLAwAUAgAAAA==.',['一川']='一川尧:BAAAKgADCgEIAQAAAA==.',['一心']='一心一教:BAAAKgAECgcIDQAAAA==.',['一次']='一次插四根:BAAAKgAECgYICwAAAA==.',['七擒']='七擒萌货:BAACKgAFFH8eAAIPAAUIihnOJgD6AAAPAAUIihnOJgD6AAAqAAQKfygAAw8ACAhLH/8jACoCAA8ACAhLH/8jACoCABAACAiaDYg1AEMBAAAA.',['上海']='上海地板王:BAAAKgAFFAMIBAAAAA==.',['不与']='不与小人斗利:BAAAKgADCggICAAAAA==.',['不落']='不落小莱妹:BAAAKgAFFAIIBAAAAA==.',['丑也']='丑也是小师妹:BAAAKgAFFAIIAgAAAA==.',['丽萨']='丽萨丶岩心:BAABKgAFFH8IAAMRAAYIuwgaAgAgAQARAAYIlgcaAgAgAQASAAIIWw5BIACRAAAAAA==.',['丽蒂']='丽蒂丶墨菲斯:BAABKgAFFH8KAAINAAgIPh56BAA+AgANAAgIPh56BAA+AgAAAA==.',['丿血']='丿血月灬:BAAAKgAFFAQIBAAAAA==.',['九喵']='九喵:BAABKgAFFH8JAAITAAgI3AvKCgDcAQATAAgI3AvKCgDcAQAAAA==.',['九幽']='九幽除名:BAAAKgAECgQIAwAAAA==.',['九音']='九音小心前面:BAABKgAFFH8GAAIUAAYIWBEWDQAoAQAUAAYIWBEWDQAoAQAAAA==.',['亚尔']='亚尔赛德:BAAAKgADCgEIAQAAAA==.',['亦窈']='亦窈:BAAAKgAECggICAAAAA==.',['人间']='人间指南:BAABKgAFFH8GAAIVAAYIngYyDgAuAQAVAAYIngYyDgAuAQAAAA==.',['休伯']='休伯立亚:BAAAKgAECgIIAgAAAA==.休伯立安:BAAAKgAECgIIAgAAAA==.',['你黑']='你黑劳资:BAAAKgAECgMIAwAAAA==.',['修羅']='修羅之刻:BAAAKgAECgcIDgAAAA==.',['俺村']='俺村俺最强:BAAAKgAECgEIAQAAAA==.',['元素']='元素祝福:BAABKgAFFH8IAAIIAAgINB1uBQBwAgAIAAgINB1uBQBwAgAAAA==.',['克伦']='克伦薇尔:BAABKgAFFH8HAAIUAAQIWA4rDgCcAAAUAAQIWA4rDgCcAAAAAA==.',['八十']='八十八号伎师:BAAAKgAFFAQIBAAAAA==.',['公鸭']='公鸭骑士:BAABKgAFFH8GAAIWAAYIQgZJGgDQAAAWAAYIQgZJGgDQAAAAAA==.公鸭龙:BAAAKgAFFAQIBAAAAA==.',['六环']='六环至圣斩:BAABKgAFFH8GAAIWAAYI6wGYDQChAAAWAAYI6wGYDQChAAABKgAFFAgIEQANAPEXAA==.',['冷月']='冷月飘零丶:BAAAKgAECgQIBAAAAA==.',['凌梦']='凌梦露:BAAAKgAECgcIBwAAAA==.',['凑凑']='凑凑来留:BAAAKgAECgYIBgAAAA==.',['凰之']='凰之游侠潇洒:BAABKgAFFH8KAAIHAAYIWxVlDwBNAQAHAAYIWxVlDwBNAQAAAA==.',['初音']='初音镜:BAAAKgAFFAgIBAAAAA==.',['力巴']='力巴伊赫:BAABKgAECn8VAAMXAAgIoxVfIADGAQAXAAgIoxVfIADGAQABAAQIWwJIhQBWAAAAAA==.',['十目']='十目:BAAAKgAFFAgIAgAAAA==.',['卡西']='卡西亚托马斯:BAABKgAFFH8OAAIVAAgI+h3FAADVAQAVAAgI+h3FAADVAQAAAA==.',['可樂']='可樂加牛奶:BAABKgAFFH8QAAMPAAYI2BxvAQDWAQAPAAYI2BxvAQDWAQAQAAYIMxM3AgB+AQABKgAFFAgIBAAYAAAAAA==.',['叶枫']='叶枫哥:BAACKgAFFH8KAAMMAAMIpx3dEQAFAQAMAAMIpx3dEQAFAQANAAEIgwm9JwBEAAAqAAQKf0EABAwACAhHJU8LANoCAAwACAhHJU8LANoCAA0ABgjWGZgvAHcBABkAAggQGpgXAHsAAAAA.',['命途']='命途为茧:BAAAKgADCggICQAAAA==.',['咸鱼']='咸鱼抽脸:BAAAKgAECgYIBgAAAA==.',['咻咻']='咻咻棉糀餹:BAAAKgAFFAgIBAAAAA==.',['哎哟']='哎哟呵:BAAAKgAECgQIBAAAAA==.',['唐牛']='唐牛才是食神:BAAAKgAFFAUIAQAAAA==.',['嗜血']='嗜血丨师妹:BAAAKgAECgYIBgAAAA==.',['圆圆']='圆圆老师:BAABKgAFFH8IAAMaAAgIjAryFgDrAAAaAAQIuQHyFgDrAAAbAAQItQU1HACGAAAAAA==.',['埃波']='埃波利耶塔:BAACKgAFFH8HAAIHAAMIsgjkJQC8AAAHAAMIsgjkJQC8AAAqAAQKfxQAAgcABwjKGIw4ALIBAAcABwjKGIw4ALIBAAAA.',['堕天']='堕天使一魅魔:BAAAKgAFFAQIBAAAAA==.',['墨云']='墨云子:BAAAKgAECgQIBAAAAA==.',['墨守']='墨守:BAAAKgADCgEIAQAAAA==.',['墨染']='墨染樱飞:BAAAKgADCggIAgAAAA==.',['多毛']='多毛体制:BAAAKgADCgEIAQAAAA==.',['夜之']='夜之愿:BAAAKgAECgcIDAAAAA==.',['夢幻']='夢幻鯨靈:BAABKgAFFH8HAAIXAAYIbBa2AQC+AQAXAAYIbBa2AQC+AQAAAA==.',['大块']='大块强光碎片:BAABKgAFFH8FAAIIAAQIYB0oNAAZAQAIAAQIYB0oNAAZAQAAAA==.',['大米']='大米包租婆:BAAAKgAECgUIBQAAAA==.大米打工头:BAAAKgAECgQIBQAAAA==.大米打工萨:BAAAKgAECgMIBAAAAA==.大米蟹老板:BAAAKgAECgQIBgAAAA==.大米驴得水:BAABKgAFFH8IAAIWAAQI0hE9IQCcAAAWAAQI0hE9IQCcAAAAAA==.',['大贤']='大贤良师:BAABKgAFFH8GAAMNAAYIshcmFwAtAQANAAUIBRomFwAtAQAMAAEIZQ6EXQA8AAAAAA==.',['天之']='天之藍:BAABKgAFFH8FAAIGAAMIFwgpEgBvAAAGAAMIFwgpEgBvAAAAAA==.',['天地']='天地一宝颖:BAAAKgAECggICAAAAA==.天地一颖宝:BAAAKgAECgYICwAAAA==.',['天宫']='天宫丨蓝:BAAAKgAECgUICQAAAA==.',['天诡']='天诡:BAAAKgAECggICwAAAA==.',['奇葩']='奇葩球:BAAAKgAECgQIBAAAAA==.',['奥瑞']='奥瑞西亚:BAAAKgAFFAQIAwAAAA==.',['奶萨']='奶萨:BAAAKgAECgQIAwAAAA==.',['好后']='好后生:BAAAKgAECgEIAQAAAA==.',['如约']='如约而至:BAAAKgADCggICAAAAA==.',['妖冶']='妖冶的猫咪:BAAAKgAECgUIBQAAAA==.',['子木']='子木:BAAAKgAECgIIAgAAAA==.',['孤独']='孤独的旅者:BAABKgAECn8UAAMcAAgIaBf5EAAcAgAcAAgIaBf5EAAcAgAdAAEIDhE+EwA4AAAAAA==.',['孻月']='孻月飘零:BAAAKgAECgYIBgAAAA==.',['宇智']='宇智波丶斑:BAAAKgAECgYIBgAAAA==.',['宋你']='宋你一颗芽芽:BAAAKgAECgYIBgAAAA==.',['寂寞']='寂寞繁多:BAAAKgADCggICAAAAA==.',['寂静']='寂静之雨:BAAAKgADCgIIAgAAAA==.',['射你']='射你屁屁:BAAAKgAFFAIIAgAAAA==.',['小周']='小周老师:BAABKgAFFH8KAAIMAAYIyRJTFQBLAQAMAAYIyRJTFQBLAQAAAA==.',['小喷']='小喷嚏:BAABKgAFFH8SAAIUAAcI6hz2BAD1AQAUAAcI6hz2BAD1AQAAAA==.',['小槑']='小槑:BAAAKgAECgMIAwAAAA==.',['小浦']='小浦老师:BAABKgAFFH8NAAMFAAgIxgt5BwDXAQAFAAgI0Al5BwDXAQAWAAUIQA4ZGgDRAAAAAA==.',['小焦']='小焦:BAAAKgADCgYIBgAAAA==.',['小红']='小红手:BAAAKgAECgMIAwAAAA==.',['小萌']='小萌兜:BAAAKgAECgcICwAAAA==.',['小贝']='小贝:BAAAKgAECggIBQAAAA==.',['小门']='小门童:BAABKgAFFH8QAAIJAAgILx90BABeAgAJAAgILx90BABeAgAAAA==.',['就是']='就是菜:BAAAKgAECgMIAwAAAA==.',['山岚']='山岚之梦:BAAAKgAECgIIAgAAAA==.',['崔瀺']='崔瀺:BAAAKgAECgYIBwAAAA==.',['工藤']='工藤峰子:BAAAKgAFFAEIAQAAAA==.工藤疯子:BAABKgAFFH8FAAIMAAUIKRTIIAAJAQAMAAUIKRTIIAAJAQAAAA==.工藤锋子:BAAAKgAECggICwAAAA==.工藤风姿:BAAAKgAECgEIAQAAAA==.',['幻灭']='幻灭梦想:BAAAKgAFFAQIBAAAAA==.',['影天']='影天使一刀客:BAAAKgAECgEIAQAAAA==.',['往后']='往后余生:BAABKgAECn8SAAIMAAgIiyAKKABTAgAMAAgIiyAKKABTAgAAAA==.',['很深']='很深:BAAAKgAECggICAABKgAFFAgIAgAYAAAAAA==.',['忘了']='忘了离开:BAAAKgADCgUIBQAAAA==.',['怪叔']='怪叔叔的逆袭:BAACKgAFFH8TAAIIAAQIAg7+LACyAAAIAAQIAg7+LACyAAAqAAQKfyEAAggACAhPGNJdAOEBAAgACAhPGNJdAOEBAAAA.',['恐龙']='恐龙突刺:BAAAKgAECgUIBQAAAA==.',['恶蛋']='恶蛋猎手:BAABKgAFFH8GAAITAAYIYwq5DwA/AQATAAYIYwq5DwA/AQAAAA==.',['悠悠']='悠悠丶:BAAAKgADCggICAAAAA==.',['我若']='我若成风:BAAAKgADCggICAAAAA==.',['扛靶']='扛靶子:BAAAKgAECgYIBgAAAA==.',['挨打']='挨打全能:BAAAKgAECggICwAAAA==.',['敬业']='敬业狐:BAAAKgAECgEIAQAAAA==.',['斯克']='斯克玛:BAAAKgAECgQIBgAAAA==.',['旺旺']='旺旺仙贝:BAACKgAFFH8NAAMUAAYIZhptCACCAQAUAAYIZhptCACCAQAIAAEIsyPSSwBSAAAqAAQKfx4AAggACAj7JecIAPcCAAgACAj7JecIAPcCAAEqAAUUCAgIAAgAdBYA.',['旻旻']='旻旻老师:BAABKgAFFH8SAAQXAAgI2Qo6EAAhAQAXAAQIcgc6EAAhAQABAAYI3AscFwD8AAACAAIIBhUzEQCpAAAAAA==.',['春欲']='春欲尽日迟迟:BAAAKgAECggIDwAAAA==.',['晚风']='晚风停不住:BAAAKgAFFAQIBAAAAA==.',['晶月']='晶月莹华:BAAAKgAECgQIBwAAAA==.',['暖夕']='暖夕:BAABKgAFFH8MAAIMAAYIRhgxDwA1AQAMAAYIRhgxDwA1AQAAAA==.',['暮色']='暮色渐浓:BAAAKgAECggIEQAAAA==.',['曾经']='曾经的少年:BAAAKgAECgMIBQAAAA==.',['最上']='最上川:BAABKgAFFH8KAAMOAAQISguBFgDLAAAOAAQISguBFgDLAAAeAAIIWhaSFwCNAAAAAA==.',['最下']='最下流:BAABKgAFFH8GAAIIAAYIMiD2EADXAQAIAAYIMiD2EADXAQAAAA==.',['月神']='月神湖浮尸:BAAAKgAECggICAAAAA==.',['未日']='未日联盟:BAAAKgAFFAQIBAAAAA==.',['杀戮']='杀戮机器:BAAAKgADCgQIBgAAAA==.',['杨家']='杨家坪动物园:BAAAKgAFFAYIBAAAAA==.',['柊祈']='柊祈:BAABKgAFFH8ZAAIUAAgI4xNCBgDCAQAUAAgI4xNCBgDCAQAAAA==.',['柊镜']='柊镜:BAABKgAFFH8PAAMHAAgIAhSMDAA3AQAHAAYIdhOMDAA3AQAJAAQIxxICFwAsAQAAAA==.',['柏拉']='柏拉图的灵魂:BAABKgAFFH8cAAMWAAgIVBgJBwC2AQAFAAgIiBODBQAaAgAWAAgICRIJBwC2AQAAAA==.',['栩意']='栩意阑珊:BAABKgAECn82AAICAAgIyxT7GwCpAQACAAgIyxT7GwCpAQAAAA==.',['格罗']='格罗小什:BAAAKgAFFAMIAwAAAA==.',['桀天']='桀天使一图腾:BAAAKgAECgYICgAAAA==.',['梦萍']='梦萍涵香:BAAAKgAECgUIAQAAAA==.',['樱吹']='樱吹雪:BAAAKgAFFAEIAQAAAA==.',['橋本']='橋本环奈:BAAAKgADCggICgAAAA==.',['比猪']='比猪低一等:BAAAKgADCgIIAgAAAA==.',['毘沙']='毘沙门天:BAAAKgAECgMIBAAAAA==.',['水哇']='水哇哇:BAAAKgAECgQIBAAAAA==.',['永生']='永生信仰:BAAAKgAECgEIAQAAAA==.',['永远']='永远铭记:BAABKgAFFH8OAAMPAAgIuRYwEwCCAQAPAAYIHhYwEwCCAQAQAAIIsgVtEgCAAAAAAA==.',['永铭']='永铭于心:BAAAKgAFFAQIBAAAAA==.',['没事']='没事逗你玩:BAAAKgADCgQIBAAAAA==.',['法力']='法力残渣:BAAAKgAECgIIAgAAAA==.',['洒洒']='洒洒水了:BAAAKgAECgcICAAAAA==.',['派斯']='派斯一棵树:BAAAKgAECgcIEgAAAA==.',['浩南']='浩南哥:BAAAKgAECgEIAQAAAA==.',['海之']='海之狸:BAABKgAFFH8UAAMIAAYIYyGMAQDcAQAIAAYIYyGMAQDcAQAfAAQI+goVCADVAAAAAA==.',['海绵']='海绵宝宝很胖:BAAAKgAFFAgIAgAAAA==.',['消失']='消失的时空:BAAAKgAFFAgIBAAAAA==.',['消逝']='消逝的雪:BAAAKgAFFAgIBAAAAA==.',['深蓝']='深蓝幽梦:BAAAKgAECggIEwAAAA==.深蓝风语:BAABKgAECn8UAAIMAAgI4hVVOgC8AQAMAAgI4hVVOgC8AQAAAA==.',['清风']='清风徐徐:BAACKgAFFH8MAAMSAAYIUCC1AADxAQASAAYI4hu1AADxAQAVAAEIKBjcFQBhAAAqAAQKfxUAAxIACAgJIyIYAEkCABIACAgJIyIYAEkCABEAAggqDwdBAFYAAAAA.',['温柔']='温柔的刺客:BAABKgAFFH8FAAIPAAMIhAHVVABiAAAPAAMIhAHVVABiAAAAAA==.',['湮灭']='湮灭龙:BAAAKgAECggIEAAAAA==.',['滅天']='滅天使一焚天:BAAAKgAECgEIAQAAAA==.',['滚不']='滚不莱:BAAAKgAECgMIAwAAAA==.',['灵妖']='灵妖妖:BAABKgAFFH8LAAMDAAYIkx9mAQDkAQADAAYIRB9mAQDkAQAgAAMIcRv/BQDmAAAAAA==.',['灵岩']='灵岩大师:BAAAKgAECgUICQAAAA==.',['灵魂']='灵魂行者黑角:BAAAKgADCggICAAAAA==.',['炭烤']='炭烤五花肉:BAAAKgADCgQIBAAAAA==.',['燃烧']='燃烧的诛妖:BAAAKgAFFAIIAgAAAA==.',['牛奶']='牛奶加咖啡:BAABKgAFFH8SAAMGAAgIRRWyAwAaAQAHAAgI1w0iCQCsAQAGAAQI8h2yAwAaAQAAAA==.',['牛肉']='牛肉面三元:BAAAKgAFFAIIAgAAAA==.',['牧有']='牧有小咪:BAAAKgAECgUIBQAAAA==.',['牧枫']='牧枫尘:BAAAKgAFFAYIBAAAAA==.',['狂野']='狂野不死鸟:BAAAKgAECgYIBgAAAA==.',['狸呜']='狸呜嗷:BAAAKgAECgYIBgAAAA==.',['狸子']='狸子:BAAAKgADCgQIBAAAAA==.',['狼盟']='狼盟雨:BAAAKgAECgIIAgAAAA==.',['猫猫']='猫猫熊宝:BAAAKgADCgIIAgAAAA==.',['玛丽']='玛丽亚贝尔:BAAAKgAECggICAAAAA==.',['珊珊']='珊珊宝贝:BAAAKgAECgEIAQAAAA==.',['瓦德']='瓦德拉肯盾卫:BAABKgAECn8VAAIRAAgISQVjJgDPAAARAAgISQVjJgDPAAAAAA==.',['生命']='生命赋誓者:BAAAKgAECgIIAgAAAA==.',['痞子']='痞子乐手:BAAAKgADCgYIBgAAAA==.',['痞颜']='痞颜帅哥:BAAAKgAFFAIIBAAAAA==.',['盖亚']='盖亚的愤怒:BAAAKgAECggIEAAAAA==.',['祈月']='祈月之雨:BAAAKgAECgQIBAAAAA==.',['祖达']='祖达萨圣眷者:BAAAKgAECgQIBAAAAA==.',['神丶']='神丶狐:BAAAKgAECgMIAwAAAA==.',['神珍']='神珍草:BAAAKgAECgQIDAAAAA==.',['神裂']='神裂火织:BAABKgAFFH8JAAMFAAQITxY2FADFAAAFAAQI0BE2FADFAAAWAAQIJhVjHwCpAAAAAA==.',['究极']='究极大美女:BAAAKgAECggICAAAAA==.究极小美女:BAAAKgAECggICQAAAA==.',['窜稀']='窜稀:BAAAKgADCgYIBgAAAA==.',['筱恒']='筱恒恒丶:BAAAKgAECgQIBQAAAA==.',['箭秀']='箭秀凌云:BAAAKgAFFAQIBAAAAA==.',['粗长']='粗长:BAAAKgAECgEIAQAAAA==.',['糖门']='糖门滚:BAAAKgAECgUIBQAAAA==.',['紫月']='紫月緋雪:BAAAKgAFFAgIBAAAAA==.',['红牌']='红牌伎师:BAACKgAFFH8XAAMFAAQIRyJAEAD4AAAFAAQIRyJAEAD4AAAhAAIICx2pDACvAAAqAAQKfx4AAwUACAjfIzEPAKkCAAUACAgnIzEPAKkCACEABwgUIkAJACUCAAAA.',['绫之']='绫之回忆:BAAAKgAECgMIBQAAAA==.',['绯红']='绯红的亚里亚:BAAAKgAECgYIBwAAAA==.',['缈若']='缈若烟芸:BAAAKgAECgIIAgAAAA==.',['缘来']='缘来是小强:BAAAKgAFFAgIAgAAAA==.',['罗姗']='罗姗娜:BAAAKgADCgcIBwAAAA==.',['翡翠']='翡翠熊:BAAAKgAECgYIBgAAAA==.',['老公']='老公鸭:BAABKgAFFH8GAAINAAYIORRrEABjAQANAAYIORRrEABjAQAAAA==.',['胖虎']='胖虎的跟风骑:BAAAKgADCgMIAwAAAA==.',['胖面']='胖面包:BAAAKgAFFAgIBAAAAA==.',['艾比']='艾比西安:BAAAKgAFFAQIBAAAAA==.',['艿白']='艿白的雪子:BAAAKgAFFAMIAwAAAA==.',['芙蓉']='芙蓉王原:BAAAKgAECgIIAgAAAA==.',['苍穹']='苍穹发丝:BAAAKgAFFAgIBAAAAA==.',['范尼']='范尼是徳鲁伊:BAABKgAECn8eAAIPAAgINxfVPADDAQAPAAgINxfVPADDAQAAAA==.',['莫辛']='莫辛納甘:BAAAKgAECggICQAAAA==.',['莺歌']='莺歌燕舞:BAAAKgAECgIIAgAAAA==.',['萌萌']='萌萌小小龙:BAAAKgAECgUIBQAAAA==.',['萨拉']='萨拉丶晨星:BAAAKgAFFAIIBAABKgAFFAgIRwAHADUlAA==.萨拉他死:BAAAKgAECgYIBgAAAA==.',['葉糖']='葉糖糖丶:BAAAKgAECgIIAgAAAA==.',['蓝月']='蓝月之吟:BAAAKgAECgYIBgAAAA==.',['血染']='血染樱飞:BAAAKgAECgYIBwAAAA==.',['血瑟']='血瑟:BAAAKgAECgQIBAAAAA==.',['要么']='要么准要么狠:BAAAKgAECgQIBgAAAA==.',['言叶']='言叶之庭:BAAAKgAECgMIAwAAAA==.',['谢谢']='谢谢丶:BAABKgAECn8VAAINAAYItBo7PgBbAQANAAYItBo7PgBbAQAAAA==.',['赛博']='赛博精神病:BAAAKgAECgYIDAAAAA==.',['赫伊']='赫伊巴力:BAAAKgADCggIEAAAAA==.',['越夜']='越夜越堕落:BAAAKgADCgYIAgAAAA==.',['趴趴']='趴趴艾露猫:BAAAKgAECgcIBQAAAA==.',['路西']='路西法:BAAAKgADCgIIAgAAAA==.',['轩哥']='轩哥不新轩:BAAAKgAECggICAAAAA==.',['软耳']='软耳朵:BAAAKgAECgUIBQAAAA==.',['迁本']='迁本夏实:BAABKgAFFH8GAAIcAAYI0hTfDAB/AQAcAAYI0hTfDAB/AQAAAA==.',['迷惘']='迷惘者:BAAAKgADCggICAAAAA==.',['逆天']='逆天獨舞:BAABKgAECn8XAAIQAAgIFhZ5LQBxAQAQAAgIFhZ5LQBxAQAAAA==.',['逗笔']='逗笔小阿明:BAAAKgAECgYIBgAAAA==.',['邪天']='邪天使一若兰:BAAAKgADCggICAAAAA==.',['邪月']='邪月之靈:BAAAKgAECgQIBAAAAA==.',['酒后']='酒后少女的梦:BAAAKgADCgEIAQAAAA==.',['醉天']='醉天使一莫笑:BAAAKgAFFAQIBAAAAA==.',['醉生']='醉生夢死:BAABKgAFFH8hAAIWAAYIyQLPJgB7AAAWAAYIyQLPJgB7AAAAAA==.',['野性']='野性的守护:BAACKgAFFH8lAAMQAAYIRhItFQD3AAAQAAUICxItFQD3AAAPAAUInQxWPQCzAAAqAAQKfxoAAhAACAiMFQwhAJUBABAACAiMFQwhAJUBAAAA.',['野蔷']='野蔷薇:BAAAKgADCggICgAAAA==.',['铁房']='铁房:BAAAKgAFFAMIAwAAAA==.',['长得']='长得困难:BAAAKgAECgIIAgAAAA==.',['阿咧']='阿咧咧:BAAAKgAECgMIAwAAAA==.',['阿秋']='阿秋:BAAAKgAECggIDQAAAA==.',['阿莱']='阿莱娜米兰达:BAAAKgAFFAMIAwAAAA==.',['隔壁']='隔壁小王子:BAAAKgAECggICwAAAA==.',['隨風']='隨風澹淡:BAAAKgAECgYICgAAAA==.',['隼蛇']='隼蛇:BAABKgAFFH8IAAIDAAgI2hrZBQA5AgADAAgI2hrZBQA5AgAAAA==.',['雪月']='雪月之狼:BAAAKgAECgUICAAAAA==.',['雪白']='雪白的时空:BAABKgAFFH8GAAIGAAYIRwfgCwAMAQAGAAYIRwfgCwAMAQAAAA==.',['雷霆']='雷霆法師:BAAAKgAECggICAAAAA==.',['霜天']='霜天使一领主:BAAAKgAECgQIBgAAAA==.',['霞之']='霞之丘诗羽:BAABKgAFFH8UAAQJAAYIDhGPHgDyAAAJAAUI1g+PHgDyAAAHAAQIKBOMGwDkAAAGAAEIYgX7KwA6AAAAAA==.',['风行']='风行者丶痴念:BAABKgAECn8UAAMMAAgIHCFYFACJAgAMAAgIHCFYFACJAgANAAIIOhGJiwBiAAAAAA==.',['饭饭']='饭饭崽:BAAAKgAFFAQIBAAAAA==.',['香辛']='香辛料:BAABKgAFFH8KAAIIAAYIhhTUJABWAQAIAAYIhhTUJABWAQABKgAFFAgIEAAUAMANAA==.',['魔天']='魔天使一星夜:BAAAKgAECgYIBgAAAA==.',['鲸福']='鲸福克斯:BAAAKgAFFAYIBAAAAA==.',['黑天']='黑天使:BAAAKgADCggICgAAAA==.',['龖鍅']='龖鍅師:BAAAKgAECgEIAQAAAA==.',['龙天']='龙天使一御魔:BAABKgAFFH8IAAILAAgIAAOQDQBLAQALAAgIAAOQDQBLAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end