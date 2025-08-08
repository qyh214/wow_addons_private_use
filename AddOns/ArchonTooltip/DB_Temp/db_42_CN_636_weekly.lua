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
 local lookup = {'DeathKnight-Unholy','Mage-Arcane','Mage-Fire','Mage-Frost','Unknown-Unknown','Hunter-Marksmanship','Warlock-Affliction','Warlock-Destruction','Druid-Restoration','Shaman-Restoration','Warlock-Demonology','Hunter-BeastMastery','Monk-Windwalker','Paladin-Retribution','Shaman-Elemental','Warrior-Arms','Paladin-Protection','Warrior-Fury','Monk-Mistweaver','DeathKnight-Blood','Priest-Discipline','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Monk-Brewmaster','Druid-Balance','Druid-Guardian','Evoker-Devastation',}; local provider = {region='CN',realm='奈法利安',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amber:BAABKgAFFH8GAAIBAAYI/RLwFABzAQABAAYI/RLwFABzAQAAAA==.',Ar='Archonsu:BAABKgAFFH8IAAQCAAYI8hqeHgDxAAACAAQI7BqeHgDxAAADAAIIghpGJADEAAAEAAIIYRVTFwB8AAABKgAFFAgIBAAFAAAAAA==.',Bt='Btsrh:BAAAKgADCgcIBwAAAA==.',De='Deepseek:BAAAKgADCgEIAQAAAA==.',Gr='Graves:BAABKgAFFH8MAAIGAAgIXxWZCADSAQAGAAgIXxWZCADSAQAAAA==.',In='Insane:BAAAKgAECgQIBgAAAA==.',Ir='Iris:BAABKgAFFH8FAAMHAAUIKhETBgDfAAAHAAMItA4TBgDfAAAIAAII3BSBGQC6AAAAAA==.',Ja='Jacklover:BAAAKgAECggIDwAAAA==.',Jo='Jojo:BAAAKgADCgQIBAAAAA==.',La='Lappe:BAAAKgADCgUIBQAAAA==.',Ma='Maga:BAAAKgADCggICAAAAA==.',Mm='Mmekii:BAAAKgAECgYIBgAAAA==.',My='Mysweet:BAAAKgAECggICAAAAA==.',Qs='Qs:BAAAKgADCggICAAAAA==.',Re='Repent:BAAAKgAFFAYIBAAAAA==.',Ru='Ruby:BAAAKgADCgQIBAAAAA==.',Sk='Skywalkers:BAAAKgAECgcIDQAAAA==.',So='Soulwolf:BAABKgAFFH8OAAIJAAYIbB4xBwCfAQAJAAYIbB4xBwCfAQAAAA==.',Wi='Wishtoday:BAAAKgAFFAQIBAAAAA==.',Wo='Woshishaman:BAABKgAFFH8FAAIKAAUIIBmMFQAuAQAKAAUIIBmMFQAuAQAAAA==.',['一支']='一支间羟胺:BAABKgAECn8ZAAIKAAgInxqvJQDrAQAKAAgInxqvJQDrAQAAAA==.',['一暴']='一暴力男一:BAAAKgAECgMIAwAAAA==.',['一杠']='一杠子头一:BAAAKgADCgIIAgAAAA==.',['一根']='一根充电线:BAAAKgADCgUIBQAAAA==.',['东方']='东方灬怒风:BAABKgAFFH8IAAQHAAQIAhWZEACeAAAHAAIIWBKZEACeAAAIAAIILhBWHwCVAAALAAIIlQu7HABAAAAAAA==.',['丨洛']='丨洛天依丨:BAAAKgADCgUIBQAAAA==.',['中嘓']='中嘓巭:BAAAKgADCgEIAQAAAA==.',['中流']='中流砥柱:BAAAKgAFFAMIAwAAAA==.',['丶天']='丶天宇:BAAAKgADCggICAAAAA==.',['丶白']='丶白水:BAABKgAECn8UAAIMAAgI4BBIWABRAQAMAAgI4BBIWABRAQAAAA==.',['乳酸']='乳酸套子:BAAAKgAECgIIAgAAAA==.',['了了']='了了:BAAAKgAFFAMIAwABKgAFFAgIBgANAJUSAA==.',['从头']='从头再来可否:BAAAKgAECgMIAwAAAA==.',['从未']='从未拥有:BAAAKgAECggICAAAAA==.',['伊斯']='伊斯瑞尔:BAAAKgAECggIEQAAAA==.',['倾城']='倾城歌衫:BAAAKgAECgcIDgAAAA==.',['光之']='光之凤舞:BAABKgAFFH8KAAIOAAYIpBXJIgBhAQAOAAYIpBXJIgBhAQAAAA==.',['兔纳']='兔纳厄运:BAAAKgAECgIIAgAAAA==.',['兽震']='兽震四方:BAAAKgAECgcICAAAAA==.',['冷夜']='冷夜雨:BAAAKgAECgcIBQAAAA==.',['冷血']='冷血图腾:BAABKgAECn8bAAIKAAgIFhM1QAB2AQAKAAgIFhM1QAB2AQAAAA==.',['包秃']='包秃:BAAAKgAECgYIBgAAAA==.',['北海']='北海丨夜:BAAAKgADCgEIAQAAAA==.',['千山']='千山墨雪:BAAAKgAFFAYIBAAAAA==.',['千幻']='千幻丶:BAACKgAFFH8rAAMKAAYI5x3CCwCLAQAKAAYI5x3CCwCLAQAPAAQI6iWhBAAWAQAqAAQKf1AAAg8ACAhpJXsCAPcCAA8ACAhpJXsCAPcCAAAA.',['卟離']='卟離卟棄:BAABKgAFFH8GAAIGAAYIqRzmCwCYAQAGAAYIqRzmCwCYAQAAAA==.',['卡瑟']='卡瑟娜冬灵:BAAAKgAECgQIBAAAAA==.',['合成']='合成负责人:BAAAKgAFFAQIBAAAAA==.',['咖啡']='咖啡味啾啾:BAAAKgAECgcICwAAAA==.',['哈士']='哈士狐:BAABKgAFFH8FAAMIAAUIJAakFQDZAAAIAAQIJAakFQDZAAALAAEIAAASHAAAAAAAAA==.',['喜欢']='喜欢露牛:BAAAKgAFFAQIBAAAAA==.',['国产']='国产区的荣光:BAAAKgADCggICAAAAA==.国产欧巴:BAAAKgAECgMIAwAAAA==.',['墓尸']='墓尸:BAAAKgAFFAIIBAAAAA==.',['壹玖']='壹玖玖贰:BAAAKgAFFAMIAwAAAA==.',['夜激']='夜激舞情:BAABKgAFFH8FAAIQAAMIggQXEACVAAAQAAMIggQXEACVAAAAAA==.',['夜瓣']='夜瓣无眠:BAABKgAFFH8IAAIGAAMIHAhbGwCRAAAGAAMIHAhbGwCRAAAAAA==.',['夜风']='夜风丶来袭:BAAAKgAECgcIBwAAAA==.',['大美']='大美小潇:BAAAKgAECgMIBAAAAA==.',['大花']='大花卷:BAAAKgADCggICAAAAA==.',['大虾']='大虾仁儿:BAAAKgADCgUIBQAAAA==.',['奈特']='奈特灵音:BAAAKgAFFAYIAwAAAA==.',['奥奥']='奥奥利给:BAAAKgAECgcIDgAAAA==.',['奥尔']='奥尔托斯:BAAAKgAECgQIBwAAAA==.',['奥莉']='奥莉薇娅丶:BAAAKgAECgIIAgAAAA==.',['奥黛']='奥黛丽丶艾希:BAAAKgAECgMIAwAAAA==.',['妖娆']='妖娆小晴:BAAAKgAECggIDwAAAA==.',['宁姚']='宁姚:BAAAKgAECggIDQAAAA==.',['安卓']='安卓工程师:BAAAKgADCggICAAAAA==.',['室静']='室静籣幽:BAAAKgAFFAQIBAAAAA==.室静蘭幽:BAAAKgAFFAQIBAAAAA==.',['小嘴']='小嘴真甜:BAABKgAECn8ZAAIEAAgIzRe8CQD0AQAEAAgIzRe8CQD0AQAAAA==.',['小巷']='小巷里的拓海:BAAAKgAECgMIAwAAAA==.',['尐刀']='尐刀:BAABKgAFFH8GAAIRAAYIuBdBBwBZAQARAAYIuBdBBwBZAQABKgAFFAgIDwAOADMfAA==.',['尐战']='尐战:BAABKgAFFH8GAAISAAYIFyB9CADRAQASAAYIFyB9CADRAQAAAA==.',['尐术']='尐术:BAAAKgAFFAgIAwAAAA==.',['尐武']='尐武僧:BAABKgAFFH8GAAITAAYIkw+hEAAnAQATAAYIkw+hEAAnAQAAAA==.',['尐死']='尐死骑:BAABKgAFFH8QAAMBAAgIzB2mAwCBAgABAAgIzB2mAwCBAgAUAAEIAADuNwAAAAAAAA==.',['尐毛']='尐毛贼:BAAAKgAFFAIIAgAAAA==.',['尐灬']='尐灬情话:BAAAKgAFFAUIAgAAAA==.',['尐牧']='尐牧:BAABKgAFFH8KAAIVAAYI6xucBgDDAQAVAAYI6xucBgDDAQAAAA==.',['尐精']='尐精灵:BAABKgAFFH8LAAMWAAUIlBvfAgCRAQAWAAUIlBvfAgCRAQAXAAMIwRRHBwD2AAAAAA==.',['尐闪']='尐闪电:BAAAKgAFFAMIAwAAAA==.',['尛丨']='尛丨坤坤:BAABKgAECn8bAAIOAAgIaxxcNgAmAgAOAAgIaxxcNgAmAgAAAA==.',['尤格']='尤格萨龍:BAAAKgADCgMIAwAAAA==.',['山海']='山海丨草東:BAAAKgAECgcIDwAAAA==.',['巧里']='巧里洼:BAAAKgAFFAQIBAAAAA==.',['布拉']='布拉德皮蛋:BAAAKgAECgUIBQAAAA==.',['幸福']='幸福的筱猫:BAAAKgADCggICQAAAA==.',['幻夜']='幻夜圣灵王:BAAAKgAFFAQIBAAAAA==.',['彪悍']='彪悍纯牛:BAAAKgADCgEIAQAAAA==.',['心一']='心一丶:BAABKgAFFH8GAAIOAAYIvhyeHACBAQAOAAYIvhyeHACBAQAAAA==.',['心梦']='心梦缘飞:BAABKgAFFH8IAAIVAAgIyBT2BAD0AQAVAAgIyBT2BAD0AQAAAA==.',['必兮']='必兮相语丶:BAABKgAFFH8GAAIYAAYIgwueGAA3AQAYAAYIgwueGAA3AQAAAA==.',['怪力']='怪力芭比:BAAAKgADCgUIBQAAAA==.',['恩地']='恩地:BAABKgAFFH8TAAMBAAgIix5PBQBTAQABAAQI2iVPBQBTAQAUAAQIEBkIDgA5AQAAAA==.',['惺火']='惺火燎源:BAAAKgAECgUIBQAAAA==.',['慕斯']='慕斯小奶糕:BAAAKgADCggICAAAAA==.',['懓语']='懓语:BAABKgAFFH8KAAITAAgIXxH3BgDNAQATAAgIXxH3BgDNAQAAAA==.',['我你']='我你本良人:BAABKgAECn8aAAMTAAgIzRJPIACIAQATAAgIzRJPIACIAQANAAEIPQm1fgAkAAAAAA==.',['我在']='我在恶魔岭:BAAAKgAECgYIDAAAAA==.',['我带']='我带地狱犬:BAABKgAFFH8FAAMGAAQIGxpPDADrAAAGAAQIGxpPDADrAAAMAAEIAADEVAAAAAAAAA==.',['我想']='我想打大米:BAAAKgADCgQIBAAAAA==.',['我是']='我是防骑:BAABKgAFFH8MAAIOAAQIECENDAAkAQAOAAQIECENDAAkAQAAAA==.',['戦神']='戦神阿怒:BAAAKgAECgcIBwAAAA==.',['拘灵']='拘灵遣将:BAAAKgADCggICAAAAA==.',['摩羯']='摩羯摩羯摩羯:BAAAKgADCgIIAgAAAA==.',['救赎']='救赎的瞬间:BAAAKgAFFAUIAQAAAA==.',['教父']='教父阿杰:BAAAKgAECgMIAwAAAA==.',['文质']='文质彬彬:BAAAKgAECggICAAAAA==.',['旦哥']='旦哥:BAAAKgAECgcIBwAAAA==.',['星河']='星河落雪:BAAAKgAECgUIBQAAAA==.',['春风']='春风沐宇:BAAAKgAECgUIBQAAAA==.',['是猫']='是猫不是熊:BAABKgAECn8bAAMTAAgIfBKkLACiAQATAAgIfBKkLACiAQAZAAIIaA5UIQBcAAAAAA==.',['暁静']='暁静同学:BAAAKgADCgYIBgAAAA==.',['暴米']='暴米花:BAAAKgAFFAYIBAAAAA==.',['暴龙']='暴龙小子:BAABKgAFFH8HAAISAAcI2RRaAwB9AQASAAcI2RRaAwB9AQAAAA==.',['曉静']='曉静同學:BAAAKgADCgUIBQAAAA==.',['木落']='木落兔猪:BAAAKgAFFAQIBAAAAA==.',['本人']='本人二八未婚:BAABKgAFFH8GAAIJAAYIOwu4EAAaAQAJAAYIOwu4EAAaAQAAAA==.',['李小']='李小歪:BAAAKgAECgcIDAAAAA==.',['杨小']='杨小萌:BAAAKgAECggIDwAAAA==.',['极地']='极地冰河:BAABKgAFFH8PAAIWAAYIrCSbCADYAQAWAAYIrCSbCADYAQAAAA==.',['果酱']='果酱盒:BAAAKgAECggICAAAAA==.',['柊出']='柊出萝莉灬:BAAAKgAFFAQIBAABKgAFFAgIDwAGAOMRAA==.',['柳贯']='柳贯一:BAAAKgAECgEIAQAAAA==.',['桀骜']='桀骜不驯:BAAAKgAFFAUIBAAAAA==.',['梅丽']='梅丽莎麦凯:BAAAKgADCgIIAgAAAA==.',['梦琪']='梦琪小可爱:BAAAKgAECgEIAQAAAA==.',['棉花']='棉花囡囡:BAAAKgAECggIDgAAAA==.',['椰孑']='椰孑丶:BAAAKgADCgYIBgAAAA==.',['楚楚']='楚楚小猪:BAAAKgADCggICAAAAA==.',['橙皮']='橙皮小普洱:BAAAKgADCgUIBQAAAA==.',['毗沙']='毗沙门天:BAABKgAFFH8KAAIYAAYITRUlFgBJAQAYAAYITRUlFgBJAQAAAA==.',['水上']='水上花:BAABKgAFFH8LAAIEAAMIfwbCDgCgAAAEAAMIfwbCDgCgAAAAAA==.',['泰兰']='泰兰不是德:BAABKgAFFH8GAAIaAAYIvA/ZDwBtAQAaAAYIvA/ZDwBtAQAAAA==.',['泽塔']='泽塔:BAAAKgADCgIIAgAAAA==.',['洛天']='洛天神:BAAAKgAECgYICAAAAA==.',['流风']='流风帅香:BAAAKgAECgQIBAAAAA==.',['涅冫']='涅冫槃:BAAAKgADCgcICQAAAA==.',['深海']='深海萝莉凤灬:BAABKgAFFH8IAAQIAAYI4RSnFQDOAAAIAAUIoA6nFQDOAAAHAAIISx0mGQBYAAALAAEIsRhbJwBKAAAAAA==.',['火妖']='火妖法:BAABKgAECn8pAAMEAAgIvxvPFgACAgAEAAgIvxvPFgACAgACAAYIeRQmHABFAQAAAA==.',['灬浅']='灬浅黛微妆灬:BAAAKgAFFAgIBAAAAA==.',['熊丨']='熊丨生之响往:BAAAKgADCgEIAQAAAA==.',['熟苹']='熟苹果大元帅:BAAAKgAECgYIEQAAAA==.',['爱苹']='爱苹果爱香橙:BAAAKgADCgQIBAAAAA==.',['牛濛']='牛濛濛:BAAAKgAFFAIIAgAAAA==.',['特别']='特别军事行动:BAAAKgADCgEIAQAAAA==.',['特里']='特里斯蒂娅:BAACKgAFFH8OAAIOAAgIkA4ODgD1AQAOAAgIkA4ODgD1AQAqAAQKfyIAAg4ACAhIGkcdANMBAA4ACAhIGkcdANMBAAAA.',['狂奔']='狂奔的小石头:BAAAKgADCgUIBQAAAA==.',['狂暴']='狂暴嘚战:BAAAKgADCggICAAAAA==.',['猛猛']='猛猛:BAAAKgADCggICAAAAA==.',['猫咪']='猫咪公主:BAABKgAFFH8IAAIVAAgIRhaqAwAhAgAVAAgIRhaqAwAhAgAAAA==.',['玄一']='玄一:BAABKgAECn8iAAMbAAgIuhevCgAxAQAbAAYIBxWvCgAxAQAJAAcIWREnMgApAQAAAA==.',['王大']='王大炮:BAAAKgAECggIEAAAAA==.',['玛卡']='玛卡吧卡:BAAAKgADCgUIBQAAAA==.',['甜橙']='甜橙很好吃:BAAAKgAFFAgIBAAAAA==.',['皮皮']='皮皮虾:BAAAKgAECgEIAQAAAA==.',['知栀']='知栀:BAAAKgAFFAQIBAAAAA==.',['碧落']='碧落:BAAAKgADCgEIAgAAAA==.',['神之']='神之舞者:BAAAKgAFFAQIAgAAAA==.',['神圣']='神圣照耀大地:BAAAKgAECggIEAAAAA==.神圣的圣骑:BAAAKgAFFAIIAgAAAA==.',['神明']='神明灵:BAABKgAECn8UAAIKAAgIURj6KwDMAQAKAAgIURj6KwDMAQAAAA==.',['第九']='第九刀:BAAAKgADCgcIBwAAAA==.',['简心']='简心记:BAAAKgAFFAUIBAAAAA==.',['索尼']='索尼灬克:BAAAKgAECggIDgAAAA==.',['紫仑']='紫仑:BAAAKgAECgYIBgAAAA==.',['紫韵']='紫韵梧桐:BAAAKgADCgcIBwAAAA==.',['红色']='红色维他命:BAAAKgADCggICAAAAA==.',['绵羊']='绵羊羊:BAABKgAECn8VAAMEAAYI/hc/LABdAQAEAAYI/hc/LABdAQADAAIIgwSTmwA4AAAAAA==.',['老雪']='老雪花丶冰蓝:BAAAKgAECgcIDQAAAA==.',['老龙']='老龙佛:BAAAKgAECgEIAQAAAA==.',['肖英']='肖英博:BAAAKgAECggIDgAAAA==.',['肾上']='肾上腺:BAAAKgADCggICAAAAA==.',['胧月']='胧月丶夜悠然:BAAAKgAFFAIIAgAAAA==.',['艾雅']='艾雅米诺:BAACKgAFFH8GAAIOAAUIExnGOgACAQAOAAUIExnGOgACAQAqAAQKfxoAAg4ACAgHIFJFACACAA4ACAgHIFJFACACAAAA.',['芋泥']='芋泥波波:BAAAKgAECgMIAwAAAA==.',['芒果']='芒果:BAAAKgAECgYIBgAAAA==.',['苏沐']='苏沐橙:BAABKgAECn8zAAIKAAgIyiGMFQBHAgAKAAgIyiGMFQBHAgAAAA==.',['苯妥']='苯妥英钠:BAAAKgAECggICAAAAA==.',['莫晚']='莫晚云:BAAAKgAECggIEwAAAA==.',['菜菜']='菜菜:BAAAKgAFFAYIAgAAAA==.',['萌妹']='萌妹子呀:BAAAKgAECgcIEgAAAA==.',['落泪']='落泪玫瑰:BAAAKgADCggICAAAAA==.',['蓝思']='蓝思郁灬:BAAAKgAFFAgIBAAAAA==.',['薄荷']='薄荷小奶酪:BAAAKgAECgIIAgAAAA==.',['血咒']='血咒战歌:BAAAKgAFFAgIAwAAAA==.',['血洗']='血洗天地:BAAAKgADCgUIBQAAAA==.',['血色']='血色英博:BAAAKgADCgMIAwAAAA==.',['行于']='行于流逝的岸:BAAAKgAECgQIBAAAAA==.',['观心']='观心:BAAAKgAECgEIAQAAAA==.',['譕心']='譕心:BAABKgAFFH8IAAIIAAgI+hjCBgAnAgAIAAgI+hjCBgAnAgAAAA==.',['请神']='请神儿啦:BAAAKgAFFAMIAwAAAA==.',['豆浆']='豆浆加冰:BAAAKgAFFAMIAwAAAA==.',['輪逥']='輪逥:BAABKgAFFH8KAAQDAAgIyBNuEQA2AQADAAQI4hJuEQA2AQACAAMI5RFqOwBzAAAEAAEIIxuwKgA/AAAAAA==.',['轩轩']='轩轩吾儿:BAABKgAECn8pAAIOAAgIvh64EgA7AgAOAAgIvh64EgA7AgAAAA==.',['迪西']='迪西唔西:BAAAKgAECgYIEAAAAA==.',['迷途']='迷途小姝童:BAAAKgAFFAQIBAAAAA==.',['逐风']='逐风之舞:BAAAKgAFFAYIAgAAAA==.',['邢捕']='邢捕头:BAAAKgAFFAYIBAAAAA==.',['酿酿']='酿酿尤酱酱:BAAAKgAFFAIIAgAAAA==.',['醉美']='醉美肖梦琪:BAAAKgAECgcIDAAAAA==.',['重庆']='重庆小面:BAAAKgAECggICAAAAA==.',['野蛮']='野蛮人:BAAAKgAECgcIBwAAAA==.',['錦木']='錦木千束:BAABKgAFFH8IAAIcAAQIFx3vCwDuAAAcAAQIFx3vCwDuAAAAAA==.',['鍩鍩']='鍩鍩:BAAAKgAECgYIBgAAAA==.',['钢蛋']='钢蛋:BAAAKgAFFAUIBAAAAA==.',['铁公']='铁公鸡:BAAAKgAECgYIEAAAAA==.',['银流']='银流:BAAAKgAECggIDwAAAA==.',['阴阳']='阴阳怪氣:BAAAKgAECgQIBAAAAA==.',['阿尔']='阿尔萨三:BAAAKgADCggICAAAAA==.',['阿格']='阿格娜洛斯:BAAAKgAECgcICwAAAA==.',['雲深']='雲深不知处:BAAAKgAECggIDQAAAA==.',['零度']='零度基因:BAAAKgADCggICAAAAA==.',['霸王']='霸王之子:BAAAKgADCgYIBgAAAA==.',['顶端']='顶端女人:BAAAKgAECgQIBQAAAA==.',['顽灬']='顽灬固:BAAAKgADCgcICwAAAA==.',['风暴']='风暴来袭:BAAAKgADCgEIAQAAAA==.',['风洛']='风洛:BAAAKgADCggICAAAAA==.',['风荇']='风荇者:BAABKgAFFH8JAAIMAAMIuhFsLwDMAAAMAAMIuhFsLwDMAAAAAA==.',['风雪']='风雪夜留香叶:BAAAKgAECgYICAAAAA==.',['饮魂']='饮魂者摩莉甘:BAAAKgAECgIIAgAAAA==.',['马车']='马车驾驶员:BAAAKgADCgUIBQAAAA==.',['驴小']='驴小懒:BAAAKgADCgUIBQAAAA==.',['鬼神']='鬼神柚:BAAAKgAECggICAAAAA==.',['鬼蜮']='鬼蜮筱丫丫:BAAAKgAFFAYIBAABKgAFFAgIJAAPAAIdAA==.',['魔王']='魔王丷牙德:BAAAKgAECggIEwAAAA==.',['鱼香']='鱼香炒肉丝:BAAAKgAECgUIBQAAAA==.',['鲜血']='鲜血女皇:BAABKgAECn8UAAMIAAgIlx8FDgBAAgAIAAgIlx8FDgBAAgALAAIIMhliXACPAAAAAA==.',['麦琳']='麦琳瑟拉:BAAAKgAECgUIBQAAAA==.',['麻老']='麻老李:BAAAKgADCggICAAAAA==.',['黯然']='黯然飘渺丶风:BAAAKgADCgEIAQAAAA==.',['黯熙']='黯熙徵伖:BAAAKgAECgYICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end