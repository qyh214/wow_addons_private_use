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
 local lookup = {'Evoker-Devastation','Priest-Discipline','Rogue-Assassination','Paladin-Retribution','Warrior-Fury','Mage-Frost','Mage-Arcane','Mage-Fire','Shaman-Restoration','DeathKnight-Unholy','DemonHunter-Havoc','Warrior-Arms','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Priest-Holy','Priest-Shadow','Rogue-Subtlety','Monk-Mistweaver','Shaman-Elemental','Paladin-Protection','DemonHunter-Vengeance','DeathKnight-Frost','DeathKnight-Blood','Paladin-Holy','Monk-Windwalker','Druid-Guardian','Shaman-Enhancement','Evoker-Preservation','Monk-Brewmaster',}; local provider = {region='CN',realm='石锤',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abeth:BAAAKgADCgIIAgAAAA==.',Al='Alicent:BAACKgAFFH8bAAIBAAYI+xgpDgB+AQABAAYI+xgpDgB+AQAqAAQKfx8AAgEACAjyI1EHALECAAEACAjyI1EHALECAAEqAAUUCAhCAAIAaCIA.',As='Ash:BAAAKgADCggICAAAAA==.Astraios:BAAAKgAECgIIAgAAAA==.',Au='Aurror:BAACKgAFFH8RAAIDAAMIxRRXDADdAAADAAMIxRRXDADdAAAqAAQKf0oAAgMACAjnGA8SAO8BAAMACAjnGA8SAO8BAAAA.',Bm='Bmozad:BAAAKgAECggICAAAAA==.',Bo='Bower:BAAAKgAECgcIBwAAAA==.',Ce='Celeste:BAAAKgAECggICAAAAA==.',Cr='Crazylara:BAABKgAFFH8GAAIEAAYIpyBrEQDTAQAEAAYIpyBrEQDTAQAAAA==.',Dl='Dlc:BAAAKgADCgUIBQAAAA==.',En='Envision:BAABKgAECn8VAAIFAAYIdg+NQQAUAQAFAAYIdg+NQQAUAQAAAA==.',Fa='Fannys:BAAAKgAECgcIDgAAAA==.',Fe='Fehuahua:BAAAKgAECgIIAgAAAA==.',He='Helios:BAAAKgAECgMIAwAAAA==.',In='Indiansumme:BAABKgAFFH8IAAIGAAgIRAwXAwDhAQAGAAgIRAwXAwDhAQAAAA==.',Kl='Klklkl:BAACKgAFFH8UAAQGAAgIsR+AAAC4AgAGAAgIsR+AAAC4AgAHAAMIcg9JKgC6AAAIAAEIBARvMAA9AAAqAAQKfzEABAcACAiBG1AcAA4CAAcACAiBG1AcAA4CAAYABAj7CJ14AKIAAAgABAh5CBt8AI8AAAAA.Klo:BAAAKgADCgMIAwAAAA==.',Kr='Krisodl:BAAAKgAFFAEIAQAAAA==.',Le='Lettle:BAAAKgAECggICQAAAA==.',Ly='Lyaphets:BAAAKgAECgcIBwAAAA==.',Me='Mecry:BAAAKgAECggICAAAAA==.Meo:BAABKgAFFH8GAAIJAAQICRAzMwCtAAAJAAQICRAzMwCtAAAAAA==.',Mh='Mhjah:BAAAKgAECgcIBwAAAA==.',Mi='Mino:BAAAKgAFFAYIAwABKgAFFAgICAAKAKgRAA==.',Mm='Mmei:BAAAKgAFFAQIBAAAAA==.',Mo='Mooncake:BAAAKgAFFAgIBAAAAA==.',Ni='Nioh:BAAAKgAECgYIBgAAAA==.',Pl='Playerwbkovs:BAAAKgAECgMIAwAAAA==.',Po='Pogback:BAACKgAFFH8uAAILAAUIiRmdEAArAQALAAUIiRmdEAArAQAqAAQKfxQAAgsABwgiFrxeACsBAAsABwgiFrxeACsBAAEqAAUUBghBAAkAEhoA.',Sa='Sailing:BAAAKgADCgEIAQAAAA==.',Se='Seoyoon:BAAAKgAECgcIBwAAAA==.',Sh='Shadowman:BAAAKgAECgcIBwAAAA==.',Te='Teackertony:BAAAKgAECgMIAwAAAA==.',Va='Vasily:BAAAKgAFFAIIBAAAAA==.',Vi='Violence:BAAAKgAECggICAAAAA==.Vivir:BAABKgAECn8ZAAMMAAgI8hUWHACkAQAMAAgIGhUWHACkAQAFAAQItxOwbQCjAAAAAA==.',Wo='Wonalicuole:BAAAKgAECgcIBwAAAA==.',Xi='Xidian:BAABKgAECn8sAAMNAAgIzxkELQCvAQAOAAgIXhiONwDHAQANAAgI/hUELQCvAQAAAA==.',['一之']='一之濑帆波:BAAAKgAECgMIAwAAAA==.',['一只']='一只小小从:BAACKgAFFH8IAAIPAAQIug06HgC+AAAPAAQIug06HgC+AAAqAAQKfx8AAw8ACAjrGCc1ANUBAA8ACAjrGCc1ANUBABAAAQiQA1iVABwAAAAA.',['一叶']='一叶孤城:BAAAKgAECgEIAQAAAA==.',['一枝']='一枝穿云箭:BAAAKgAECgIIAgAAAA==.',['一泓']='一泓秋水:BAAAKgADCgEIAQAAAA==.',['一霸']='一霸霸一:BAAAKgADCgEIAQAAAA==.',['万兆']='万兆亿:BAAAKgAECgUICAAAAA==.',['三个']='三个球砸死你:BAAAKgAECgMIAwAAAA==.',['上汽']='上汽大众:BAACKgAFFH8SAAMRAAYIgxW5BABiAQARAAQINRi5BABiAQASAAIIuwoQFQBTAAAqAAQKf0MAAxEACAjoIcgHAI4CABEACAjoIcgHAI4CABIABgh7EiQxACIBAAAA.',['不善']='不善言辞:BAABKgAFFH8LAAQTAAQIOBkiCwDcAAATAAQIOBkiCwDcAAAUAAIIcyJfIABhAAACAAEIAACDNwAAAAABKgAFFAgIBgATAKsLAA==.',['丑咪']='丑咪:BAAAKgADCgMIAwAAAA==.',['丧钟']='丧钟村长:BAABKgAECn8ZAAMCAAcIBAiUVwC8AAACAAcIzAWUVwC8AAATAAUIkwfMZgCAAAAAAA==.',['丨小']='丨小石头丨:BAAAKgAECgYIBwAAAA==.',['中年']='中年丶奶爸:BAAAKgADCgIIAgAAAA==.',['丶小']='丶小萌:BAABKgAFFH8JAAIQAAQIDR0jBgAZAQAQAAQIDR0jBgAZAQAAAA==.',['丶柠']='丶柠檬奶昔:BAAAKgAECgQIBgAAAA==.',['丶蕾']='丶蕾蒂湯湯:BAABKgAECn8gAAMCAAgI6BZhGQDPAQACAAgI6BZhGQDPAQAUAAQI0BEGNwDoAAAAAA==.',['丶阿']='丶阿獠:BAAAKgAECgMIAwAAAA==.',['乌拉']='乌拉乌拉萨满:BAAAKgAFFAQIAQAAAA==.',['乌瑞']='乌瑞恩之风:BAAAKgAECggIDgAAAA==.',['乌瑟']='乌瑟厼:BAAAKgAECgEIAQAAAA==.乌瑟尔:BAAAKgAFFAQIBAAAAA==.',['云水']='云水瑶:BAAAKgAECgEIAQAAAA==.',['人生']='人生似水:BAAAKgAECggICAAAAA==.',['仙人']='仙人板板:BAAAKgAECggICAAAAA==.',['以此']='以此证明:BAAAKgAECggICAAAAA==.',['仲夏']='仲夏夜之锋:BAAAKgADCgIIAgAAAA==.',['伊利']='伊利逗乳:BAAAKgAECggICgAAAA==.',['伊雷']='伊雷啵娃:BAAAKgAECgYIBgAAAA==.',['但丁']='但丁:BAAAKgAFFAgIBAAAAA==.',['何以']='何以顾流光:BAAAKgAECgEIAQAAAA==.',['余烬']='余烬佳酿:BAAAKgAFFAQIBAAAAA==.',['你小']='你小妈:BAAAKgAFFAIIAgABKgAFFAQICgAPAPwhAA==.',['你看']='你看到我咋子:BAAAKgAECgEIAQAAAA==.你看开了吗:BAAAKgAECggICAAAAA==.',['倾城']='倾城丶梦之恋:BAAAKgAECgEIAQAAAA==.',['偸鈊']='偸鈊賊丶剴:BAAAKgAECgYIBgAAAA==.',['傀儡']='傀儡魅影:BAAAKgADCgIIAgAAAA==.',['傅蓉']='傅蓉:BAAAKgAECggICAAAAA==.',['傲龙']='傲龙天:BAAAKgAECgYIBgAAAA==.',['冥莫']='冥莫一米五:BAAAKgAECgIIAgAAAA==.',['冬马']='冬马和纱:BAAAKgADCgQIBAAAAA==.',['冰拿']='冰拿铁不加冰:BAABKgAECn8WAAIKAAgI3BMwPACCAQAKAAgI3BMwPACCAQAAAA==.冰拿铁大欧皇:BAABKgAFFH8FAAIKAAUItSEzEgCIAQAKAAUItSEzEgCIAQAAAA==.',['冰火']='冰火奥秘:BAAAKgAECgIIAgAAAA==.',['冲锋']='冲锋者:BAABKgAFFH8GAAIFAAYIEQ6TDgBqAQAFAAYIEQ6TDgBqAQAAAA==.',['凉虾']='凉虾:BAAAKgADCgEIAQAAAA==.',['几亿']='几亿光年:BAABKgAECn8tAAMNAAgIzhb5MgCRAQANAAgIrhX5MgCRAQAOAAcIOAp+oQDjAAAAAA==.',['切茜']='切茜娅之手:BAAAKgAECgYIBgAAAA==.切茜娅之祈:BAAAKgAFFAgIBAAAAA==.',['划水']='划水小奶撒:BAAAKgADCggICAAAAA==.',['初木']='初木清寒:BAAAKgAECgIIAgAAAA==.',['别骂']='别骂我小白:BAABKgAECn8VAAMGAAYIsgbhVwCQAAAGAAYIsgbhVwCQAAAHAAMIpQUiRQBCAAAAAA==.',['剑破']='剑破虚空:BAABKgAFFH8GAAIKAAYIGhrYCACrAQAKAAYIGhrYCACrAQAAAA==.',['加拉']='加拉哈德:BAAAKgAECgIIAgAAAA==.',['动狗']='动狗汪汪:BAAAKgADCggICAAAAA==.',['北极']='北极冻麦粉:BAAAKgAECgcICgAAAA==.',['十月']='十月雪:BAAAKgAECgYIBgAAAA==.',['千寻']='千寻:BAAAKgAFFAQIBAAAAA==.',['半条']='半条咸鱼丶:BAACKgAFFH8UAAMVAAYIBREPAgBCAQAVAAYI0A4PAgBCAQADAAQIgRfOGADhAAAqAAQKfy4AAxUACAjnHzkMACMCABUACAhQGDkMACMCAAMACAj9HWsRAPYBAAAA.',['华丽']='华丽的一刀:BAABKgAFFH8KAAMRAAMI4w1pMwCiAAARAAMI4w1pMwCiAAASAAEIqQMIMgAzAAAAAA==.',['卡尔']='卡尔维诺:BAAAKgADCggICAAAAA==.',['卧龙']='卧龙:BAAAKgADCgEIAQAAAA==.',['卷王']='卷王:BAAAKgAECgYIBQAAAA==.',['原神']='原神:BAAAKgAFFAgIAwAAAA==.',['只为']='只为保护你:BAAAKgAECgQIBAAAAA==.',['叫我']='叫我曹阿满:BAAAKgADCggICAAAAA==.',['可乐']='可乐:BAABKgAECn8jAAIEAAgIGSBOHgCJAgAEAAgIGSBOHgCJAgAAAA==.',['后街']='后街阿良:BAAAKgAECgYIBgAAAA==.',['吖灬']='吖灬頭:BAAAKgAECggICAAAAA==.',['吹牛']='吹牛逼:BAAAKgAECgQIBAAAAA==.',['吻住']='吻住别动:BAAAKgAECgcICAAAAA==.',['呼拉']='呼拉小子:BAABKgAFFH8XAAIEAAYIUyUuCwAUAgAEAAYIUyUuCwAUAgAAAA==.',['命若']='命若琴弦:BAABKgAECn8TAAIOAAcI8xASYwAvAQAOAAcI8xASYwAvAQAAAA==.',['咕咕']='咕咕鸡:BAAAKgAFFAEIAQAAAA==.',['哇塞']='哇塞哇塞:BAAAKgADCggICQAAAA==.',['哒哒']='哒哒是冠军:BAABKgAFFH8JAAMUAAUIeRJUEQD4AAAUAAUIeRJUEQD4AAACAAQIoAwAAAAAAAAAAA==.',['哔哩']='哔哩哔哔:BAABKgAECn8XAAMSAAgINx8oBwBtAgASAAgINx8oBwBtAgARAAUI9BocVgARAQAAAA==.',['哥本']='哥本哈根拳师:BAABKgAECn8YAAIWAAcIIRhqOgBbAQAWAAcIIRhqOgBbAQAAAA==.',['唐纳']='唐纳德李:BAAAKgAECggIDgAAAA==.',['唯唯']='唯唯诺诺:BAAAKgAFFAYIAgAAAA==.',['唯我']='唯我獨尊:BAAAKgAECgUIBQAAAA==.',['啊啊']='啊啊哈:BAAAKgAECgMIAwAAAA==.',['喵神']='喵神无敌:BAABKgAFFH8PAAIEAAQIahOsJADVAAAEAAQIahOsJADVAAAAAA==.',['嗜血']='嗜血的叛逆:BAAAKgAECggIDQAAAA==.',['嘿我']='嘿我来了哦:BAABKgAECn8ZAAIGAAgIghACEQBnAQAGAAgIghACEQBnAQAAAA==.',['四月']='四月的猎手:BAAAKgAECggICAAAAA==.四月种田:BAAAKgAECgQIBwAAAA==.',['团团']='团团转圈圈:BAAAKgADCggICAAAAA==.',['图图']='图图真好玩:BAABKgAFFH8KAAMJAAQIhROsEQDdAAAJAAQIhROsEQDdAAAXAAEITgHMHgAzAAAAAA==.',['土地']='土地公:BAAAKgAECgcICwAAAA==.',['圣光']='圣光护佑着你:BAAAKgAFFAIIAgAAAA==.圣光无罪:BAAAKgADCgIIAgAAAA==.圣光闪耀:BAABKgAFFH8HAAIEAAMIAhC/VgDDAAAEAAMIAhC/VgDDAAAAAA==.',['圣小']='圣小狐:BAABKgAFFH8GAAIYAAYI8R1lBwCeAQAYAAYI8R1lBwCeAQABKgAFFAgIDgAZALELAA==.',['坏蛋']='坏蛋:BAABKgAFFH8GAAMTAAQIahr9GgDjAAATAAQIahr9GgDjAAAUAAIIkwRGIABiAAAAAA==.',['墨屿']='墨屿嬜懿:BAAAKgAECgQIBAAAAA==.',['壁虎']='壁虎漫步:BAAAKgAECgMIBAAAAA==.',['壹箭']='壹箭灬风情:BAAAKgAECgYICQAAAA==.',['壹霸']='壹霸就跪:BAAAKgADCggIEAAAAA==.',['夏天']='夏天飘的雪:BAACKgAFFH9BAAMJAAYIEhrYCwCKAQAJAAYIEhrYCwCKAQAXAAUI1x/CBAAUAQAqAAQKfzMAAxcACAgAH0oTADYCABcACAgAH0oTADYCAAkACAh0HbAbAC8CAAAA.',['夜丶']='夜丶假面:BAAAKgAFFAMIAwAAAA==.',['夜叁']='夜叁霖:BAABKgAFFH8YAAMaAAQIJg8ECgDLAAAaAAQIJg8ECgDLAAAKAAQI9AonNwC+AAAAAA==.夜叁霖的圣光:BAACKgAFFH8GAAIEAAQI/gxhKgC+AAAEAAQI/gxhKgC+AAAqAAQKfzMAAgQACAgkI7gSAMACAAQACAgkI7gSAMACAAAA.',['夜喵']='夜喵喵:BAAAKgAECgEIAQABKgAFFAMIFAATAOcHAA==.',['夜色']='夜色黎明:BAABKgAFFH8FAAILAAUIIBMmEQAgAQALAAUIIBMmEQAgAQAAAA==.',['大山']='大山勇仕:BAABKgAFFH8IAAIJAAQIMSUdFgArAQAJAAQIMSUdFgArAQAAAA==.大山勇士:BAAAKgAFFAgIBAAAAA==.大山勇士啊:BAABKgAFFH8IAAMPAAQI6xFMVgBcAAAPAAIIRAhMVgBcAAAQAAIIdAvnGAA3AAAAAA==.大山师长:BAABKgAFFH8IAAMbAAQIVRUVHADCAAAbAAQIVRUVHADCAAAKAAQIagk/OQC3AAAAAA==.大山队长:BAACKgAFFH8IAAIEAAQIEx7zDgAYAQAEAAQIEx7zDgAYAQAqAAQKfxUAAxwACAgxHAILAD8CABwACAgxHAILAD8CAAQABwi4IBVbAOgBAAAA.',['大斧']='大斧典韦:BAAAKgAECggIDwAAAA==.',['大江']='大江山悉皆杀:BAAAKgAECgMIAwAAAA==.',['大红']='大红帽小灰狼:BAAAKgADCgMIAwAAAA==.',['大锤']='大锤虎痴:BAAAKgAECgYICwAAAA==.',['天蠍']='天蠍座:BAAAKgAECgQIBAAAAA==.',['天陨']='天陨烬山河:BAABKgAFFH8IAAIFAAQIRQwIFADnAAAFAAQIRQwIFADnAAAAAA==.',['太秦']='太秦彻了:BAABKgAFFH8GAAIOAAYI7hG/FgBCAQAOAAYI7hG/FgBCAQAAAA==.',['失梦']='失梦:BAABKgAFFH8GAAIbAAYIrgr3FwDhAAAbAAYIrgr3FwDhAAAAAA==.',['奇佐']='奇佐:BAACKgAFFH8UAAMEAAMIVRghIQDkAAAEAAMIVRghIQDkAAAcAAIIXhjHEwCfAAAqAAQKfz0AAxwACAieIZ4FAJQCABwACAieIZ4FAJQCAAQACAhhIBdMAA0CAAAA.',['套盾']='套盾大天使:BAABKgAECn8XAAITAAYIwBPdSQARAQATAAYIwBPdSQARAQAAAA==.',['女乃']='女乃女马:BAABKgAFFH8IAAICAAgIoBDtAwDGAQACAAgIoBDtAwDGAQAAAA==.',['奶奶']='奶奶熊的奶茶:BAABKgAECn8VAAMNAAgI8yB6CgCOAgANAAgI8yB6CgCOAgAOAAEI9xw+8ABTAAAAAA==.',['如你']='如你所愿:BAAAKgAECgEIAQAAAA==.',['妙斯']='妙斯曼舞:BAAAKgAECgMIAwAAAA==.',['娇妹']='娇妹:BAAAKgAECggICAAAAA==.',['娶了']='娶了疯婆娘:BAAAKgAECgYIBgAAAA==.',['宇智']='宇智波牧:BAACKgAFFH8VAAIUAAMIayL0DgAUAQAUAAMIayL0DgAUAQAqAAQKf08AAhQACAhFJfAFAL0CABQACAhFJfAFAL0CAAAA.',['宗成']='宗成风:BAABKgAECn9BAAMJAAgI8g6eTgBTAQAJAAgI8g6eTgBTAQAXAAQIaQ3eJwB/AAAAAA==.',['客官']='客官不要跑:BAAAKgAECgIIAgAAAA==.',['寂落']='寂落:BAAAKgAECggIDwAAAA==.',['寻花']='寻花小蜜蜂:BAAAKgAECggIEwAAAA==.',['將丶']='將丶:BAACKgAFFH8HAAMEAAMIORUNUQDNAAAEAAMIORUNUQDNAAAcAAEI8QOWHQA1AAAqAAQKfyIAAwQACAj9I5gZAJ8CAAQACAj9I5gZAJ8CABwAAgj5EYNGAG0AAAAA.',['對吥']='對吥起爷错了:BAAAKgAECggICAAAAA==.',['小丶']='小丶粉:BAAAKgAECggIEAAAAA==.',['小啄']='小啄木鸟:BAAAKgAECggICAABKgAFFAgIDgAHACQgAA==.',['小木']='小木头的怒火:BAAAKgAECgEIAQAAAA==.',['小桐']='小桐邪:BAAAKgAECgcIDgAAAA==.',['小比']='小比熊:BAABKgAFFH8GAAIEAAYIERAKLgAvAQAEAAYIERAKLgAvAQAAAA==.',['小灬']='小灬曼:BAAAKgAFFAEIAgAAAA==.小灬涵:BAAAKgAECgEIAQABKgAFFAgIFQAFALEaAA==.',['小猎']='小猎手:BAAAKgAECgYIDQAAAA==.',['小珊']='小珊瑚:BAAAKgAECgEIAQAAAA==.',['小百']='小百灵鸟:BAAAKgAECggICAAAAA==.',['小豆']='小豆梓:BAACKgAFFH9CAAICAAgIaCLFAACdAgACAAgIaCLFAACdAgAqAAQKf1MAAgIACAgGJxsAACcDAAIACAgGJxsAACcDAAAA.',['小豚']='小豚:BAAAKgAFFAIIAgAAAA==.',['小马']='小马快走:BAAAKgAECggICAAAAA==.',['少林']='少林功夫好:BAACKgAFFH8WAAIdAAYIGCIwAQDkAQAdAAYIGCIwAQDkAQAqAAQKfyMAAh0ACAhnIqISAE4CAB0ACAhnIqISAE4CAAAA.',['尘封']='尘封忆:BAAAKgAECgYIBgAAAA==.',['尛尛']='尛尛飝魚:BAABKgAECn8rAAIEAAgI1xwtHwDDAQAEAAgI1xwtHwDDAQAAAA==.',['尤瑟']='尤瑟夫卡:BAAAKgAECgcIDAAAAA==.',['就是']='就是辣么帅:BAABKgAECn8kAAIJAAgIYyPYAwCnAgAJAAgIYyPYAwCnAgABKgAFFAQIIQAWACIkAA==.',['尹瑟']='尹瑟拉灬腥夜:BAABKgAECn8bAAIYAAgIWAqiLQDtAAAYAAgIWAqiLQDtAAAAAA==.',['尼塔']='尼塔玛个彼得:BAAAKgAECgYIDAAAAA==.尼塔玛格彼得:BAABKgAFFH8SAAMaAAMI7xF3CgDMAAAaAAMI7xF3CgDMAAAKAAIIBgVuTgBjAAAAAA==.尼塔马格彼得:BAAAKgAECgIIAgAAAA==.',['巴麻']='巴麻美:BAAAKgADCgQIBAAAAA==.',['帅是']='帅是一辈子的:BAABKgAECn8cAAMTAAgI4w+2PQBDAQATAAgInw+2PQBDAQACAAYIaAn4VADFAAAAAA==.',['师太']='师太周芷若:BAAAKgAECgIIAgAAAA==.',['常世']='常世万法仙君:BAABKgAFFH8GAAIEAAYICB+oEADaAQAEAAYICB+oEADaAQABKgAFFAgICAAEAEseAA==.',['常威']='常威:BAAAKgAECgcIBwAAAA==.',['幻觉']='幻觉而已:BAAAKgAFFAgIAgAAAA==.',['延迟']='延迟一百秒:BAAAKgAECgcIBwAAAA==.',['弑冰']='弑冰:BAAAKgAECgMIAwAAAA==.',['弗拉']='弗拉蒂斯:BAACKgAFFH8HAAIGAAMIQgnCDQCuAAAGAAMIQgnCDQCuAAAqAAQKfyAAAgYACAjjG2coAHYBAAYACAjjG2coAHYBAAAA.',['张诺']='张诺妍:BAAAKgAECgQIBQAAAA==.',['彦祖']='彦祖玩龙喷:BAACKgAFFH8MAAMKAAQI2g4gPACtAAAKAAQI0g4gPACtAAAaAAEIsBdCEgBLAAAqAAQKfxwAAwoACAjWEsBRAHQBAAoACAhKEMBRAHQBABoABgjwCzMnAIYAAAAA.',['影踪']='影踪斗佛:BAAAKgAFFAIIAgAAAA==.',['影魂']='影魂无痕:BAAAKgAECgUIBQAAAA==.',['徘徊']='徘徊在星空:BAAAKgAECgYIBwAAAA==.',['心语']='心语芯愿:BAACKgAFFH8TAAIGAAMIqhgkEQDZAAAGAAMIqhgkEQDZAAAqAAQKf0YAAgYACAjKHRASADQCAAYACAjKHRASADQCAAAA.',['心魅']='心魅魔:BAAAKgAECgQIBQAAAA==.',['念念']='念念很拉风:BAAAKgAECgMIAwAAAA==.',['怒风']='怒风之哀伤:BAAAKgAECgQIBAAAAA==.',['恶仆']='恶仆:BAAAKgADCgYIBgAAAA==.',['恶魔']='恶魔之眼:BAAAKgADCgUIBQAAAA==.',['情受']='情受丶:BAAAKgAECgEIAQAAAA==.',['惊岚']='惊岚:BAAAKgADCggICAAAAA==.',['成都']='成都刘玄德:BAACKgAFFH8KAAIPAAMILBSeMgDNAAAPAAMILBSeMgDNAAAqAAQKfygAAw8ACAhTHN0iADECAA8ACAhTHN0iADECAB4AAwiVDFIwAG8AAAAA.',['戰爭']='戰爭意志:BAABKgAFFH8FAAIJAAUItxhoEgBCAQAJAAUItxhoEgBCAQAAAA==.',['托尔']='托尔:BAAAKgAECggICAABKgAFFAgIDgAKAEoXAA==.',['把我']='把我气笑了:BAAAKgAECgQIBAAAAA==.',['拜月']='拜月:BAAAKgAFFAIIAgAAAA==.',['捣之']='捣之棒棒糖:BAAAKgAECgEIAQAAAA==.',['掉脑']='掉脑袋切切:BAAAKgAECggICAAAAA==.',['掱丷']='掱丷箐灬:BAAAKgAECgIIAgAAAA==.',['摩根']='摩根丶圣斗士:BAAAKgAECgYIBgAAAA==.摩根丶猎魔人:BAAAKgAECggICQAAAA==.',['摩诃']='摩诃孽:BAAAKgADCggICAAAAA==.',['摸着']='摸着天杜迁:BAAAKgAECgYIBgAAAA==.',['文子']='文子一样:BAAAKgAECgIIAgAAAA==.',['斩妖']='斩妖丶泣血:BAACKgAFFH8MAAMXAAMIrg3EDQC5AAAXAAMIrg3EDQC5AAAJAAIIaAX/SwBcAAAqAAQKfxcAAwkACAjnEKU/AHgBAAkACAjnEKU/AHgBABcACAhYDQkzAFEBAAAA.',['断桥']='断桥烟雨:BAABKgAECn8bAAMGAAgIGxRrJQCJAQAGAAgIGxRrJQCJAQAIAAEImAXQTAAnAAAAAA==.',['新人']='新人旧酒:BAABKgAFFH8IAAIWAAQIPR94CQAbAQAWAAQIPR94CQAbAQAAAA==.',['新兵']='新兵克林:BAABKgAFFH8IAAIcAAQIkR7wBAD6AAAcAAQIkR7wBAD6AAAAAA==.',['方沧']='方沧兰:BAAAKgAECgQICAAAAA==.',['无敌']='无敌在哪里:BAAAKgAECgUICwAAAA==.',['无赖']='无赖无赖:BAAAKgAECgUIBQAAAA==.',['早饭']='早饭吃什么呢:BAABKgAFFH8QAAIOAAgIkRrbBQA1AgAOAAgIkRrbBQA1AgAAAA==.',['时尚']='时尚潮流大妈:BAAAKgAECgYIBgAAAA==.',['旺仔']='旺仔牛逼糖:BAABKgAFFH8LAAIEAAgIjQ5fDwDnAQAEAAgIjQ5fDwDnAQAAAA==.',['易山']='易山:BAAAKgAFFAgIBAAAAA==.',['星空']='星空夜殇:BAABKgAFFH8GAAIDAAYIsB1DCgCrAQADAAYIsB1DCgCrAQAAAA==.',['春天']='春天故事:BAAAKgAECgcIBwAAAA==.',['是似']='是似而非:BAAAKgADCgEIAgAAAA==.',['晓雪']='晓雪球:BAAAKgAECgMIBAAAAA==.',['智媛']='智媛:BAABKgAFFH8KAAIEAAMIWQjwYACuAAAEAAMIWQjwYACuAAAAAA==.',['暖暖']='暖暖的风:BAAAKgAECgQIBAAAAA==.',['暖雾']='暖雾:BAAAKgAFFAYIBAAAAA==.',['暗影']='暗影心灵:BAAAKgADCgIIAgAAAA==.',['暴一']='暴一下:BAABKgAFFH8GAAIQAAYISgY3FQD3AAAQAAYISgY3FQD3AAAAAA==.',['暴走']='暴走老司机:BAAAKgAECggICAAAAA==.',['暴风']='暴风之眼:BAAAKgAECggIAgAAAA==.',['有个']='有个骑士:BAAAKgAFFAEIAQABKgAFFAgICQAJACcfAA==.',['朝暮']='朝暮年崋:BAAAKgADCgIIAgAAAA==.',['木木']='木木枭:BAAAKgAECgIIAgAAAA==.',['木棉']='木棉花:BAAAKgAECgYICAAAAA==.',['村头']='村头狗瘦子:BAAAKgAECgQICAAAAA==.',['枕枫']='枕枫丶:BAABKgAFFH8OAAMbAAgIgxEtBwCyAQAbAAgIgxEtBwCyAQAKAAYIZgcIHAA9AQAAAA==.',['枕砚']='枕砚:BAAAKgAFFAMIAwAAAA==.',['枫叶']='枫叶果果:BAAAKgADCggICAAAAA==.',['梦箐']='梦箐瑶:BAAAKgAECgMIAwAAAA==.',['棒呆']='棒呆的一棵松:BAAAKgAECgcICAAAAA==.',['樱井']='樱井丶莉亞:BAAAKgAECgMIAwAAAA==.',['樱络']='樱络:BAABKgAFFH8KAAMOAAQI3x7xDQAXAQAOAAQIBR7xDQAXAQANAAQIhhdpLQC2AAAAAA==.',['樱菁']='樱菁:BAABKgAFFH8IAAMJAAQIKx7cJQDfAAAJAAQIKx7cJQDfAAAfAAQIFgWPDQDTAAAAAA==.',['檬混']='檬混其蛋:BAAAKgAECgIIAwAAAA==.',['歌楚']='歌楚狂人:BAAAKgAECgQIBQAAAA==.',['正義']='正義審判:BAAAKgADCggIDwAAAA==.',['殇迪']='殇迪:BAAAKgAECgcIDQAAAA==.',['残丨']='残丨狼:BAAAKgAECgcICgAAAA==.',['毒瘤']='毒瘤萨:BAAAKgAECgEIAQAAAA==.',['毛概']='毛概要学好:BAAAKgAFFAIIAgABKgAFFAgIFAAGALEfAA==.',['毛点']='毛点点:BAABKgAFFH8IAAILAAgIoQ00CQDvAQALAAgIoQ00CQDvAQAAAA==.',['水晶']='水晶唇膏:BAAAKgAFFAIIAgAAAA==.',['汐涵']='汐涵:BAAAKgAFFAQIBAAAAA==.',['沉睡']='沉睡的森林灬:BAAAKgAECgQIBAAAAA==.',['沐叁']='沐叁槍:BAACKgAFFH8VAAIOAAQI5x+GHwAQAQAOAAQI5x+GHwAQAQAqAAQKfzYAAg4ACAiRI2AMAL8CAA4ACAiRI2AMAL8CAAAA.',['沙漠']='沙漠一只雕:BAAAKgAECgMIAwAAAA==.',['没学']='没学开门:BAAAKgAECgYIBgAAAA==.',['沧灬']='沧灬桑:BAAAKgAECggICAAAAA==.',['沸腾']='沸腾的咖啡:BAACKgAFFH8GAAIQAAMIugXLKQB8AAAQAAMIugXLKQB8AAAqAAQKfxkABBAACAiGE98pAFoBABAACAiGE98pAFoBAB4AAgj8Chk6AD0AAA8AAQjiDvnXAC4AAAAA.',['沾花']='沾花:BAAAKgAECgcIEwAAAA==.',['法式']='法式小面包:BAAAKgADCggICAAAAA==.',['泰达']='泰达希尔之殇:BAABKgAFFH8GAAMSAAYIORaUBQAfAQASAAUIMhmUBQAfAQARAAEIVwqkSwA/AAAAAA==.',['浓情']='浓情水煎包:BAAAKgAFFAQIBAAAAA==.',['浪漫']='浪漫剑芯丶:BAABKgAFFH8GAAIEAAYIcA4tKgA/AQAEAAYIcA4tKgA/AQAAAA==.',['海牙']='海牙猎手:BAAAKgAECgIIAgAAAA==.',['混沌']='混沌岁月:BAACKgAFFH8JAAMJAAQImRabDwAFAQAJAAQImRabDwAFAQAXAAEINwLtGAAqAAAqAAQKfzMAAgkACAgVHj4YADYCAAkACAgVHj4YADYCAAAA.',['淸緢']='淸緢淡冩:BAAAKgAFFAQIBAAAAA==.',['清月']='清月無夢:BAAAKgAFFAEIAQAAAA==.',['渡劫']='渡劫武僧:BAAAKgAFFAgIBAAAAA==.',['渴口']='渴口可乐:BAAAKgADCgIIAgAAAA==.',['游夜']='游夜的魅:BAACKgAFFH8FAAMQAAMIThDhKgB1AAAQAAIIuRThKgB1AAAPAAEIkQFyZAAoAAAqAAQKfxYAAxAACAi8EncpAIgBABAACAi8EncpAIgBAA8AAQh0B2rcACgAAAAA.',['溜溜']='溜溜猎:BAAAKgADCgMIAwAAAA==.',['灌县']='灌县刘玄德:BAABKgAECn8VAAICAAcIDwgPUQDSAAACAAcIDwgPUQDSAAAAAA==.',['火根']='火根哩:BAAAKgADCgEIAQAAAA==.',['灬水']='灬水源:BAAAKgAECgYIDwAAAA==.',['灬甲']='灬甲乙丙丁:BAAAKgAECgQIBgAAAA==.',['灭霸']='灭霸:BAAAKgADCgMIAwAAAA==.',['灰流']='灰流丽:BAAAKgAECgQIBgAAAA==.',['炙热']='炙热双刃:BAAAKgAECgcIBwAAAA==.',['烟头']='烟头里的秘密:BAAAKgADCggICAAAAA==.',['烨雨']='烨雨星:BAAAKgADCgcICgAAAA==.',['無铭']='無铭:BAAAKgAECgIIAgAAAA==.',['無雙']='無雙一璇玑:BAAAKgAECgEIAQAAAA==.',['熊威']='熊威浩荡:BAAAKgAECgIIAgAAAA==.',['熊猫']='熊猫提提米:BAABKgAECn8WAAIdAAgImBhoGwADAgAdAAgImBhoGwADAgAAAA==.熊猫潘达:BAAAKgAECggICAAAAA==.',['爱你']='爱你的阿昆达:BAAAKgAECgQIBAABKgAFFAMIFQAUAGsiAA==.',['爱是']='爱是一道光:BAAAKgADCgIIAgAAAA==.',['牛奶']='牛奶泡芙:BAAAKgAECggICQAAAA==.',['牛爷']='牛爷爷打小孩:BAAAKgAECgcIBwAAAA==.',['牛牛']='牛牛的梦想:BAABKgAFFH8SAAIJAAMIMh2KHgABAQAJAAMIMh2KHgABAQAAAA==.',['牛角']='牛角:BAABKgAECn8VAAIXAAYINxKcPgATAQAXAAYINxKcPgATAQAAAA==.',['牛马']='牛马:BAABKgAFFH8IAAIPAAQImQoGPwCuAAAPAAQImQoGPwCuAAAAAA==.',['牜萨']='牜萨:BAAAKgAECgEIAQAAAA==.',['牧小']='牧小影:BAAAKgAECgUIBQAAAA==.',['物尽']='物尽天择:BAACKgAFFH8OAAIJAAMIxhHSKQDPAAAJAAMIxhHSKQDPAAAqAAQKfyQAAgkACAjsGl0OAOcBAAkACAjsGl0OAOcBAAAA.',['牵着']='牵着灰太狼:BAAAKgADCgIIAgAAAA==.',['猪苒']='猪苒:BAAAKgADCggICAAAAA==.',['獨家']='獨家的記憶:BAAAKgAFFAQIBAAAAA==.',['珀西']='珀西丶天尊:BAAAKgADCgEIAQAAAA==.',['珊瑚']='珊瑚宫心宝:BAAAKgAFFAQIBAAAAA==.',['珞神']='珞神:BAAAKgAECgMIAwAAAA==.',['甜甜']='甜甜的忧伤:BAABKgAFFH8KAAIOAAMI9SArDwARAQAOAAMI9SArDwARAQAAAA==.',['病娇']='病娇的夜囡囡:BAAAKgAECgUIBQAAAA==.',['瘦瘦']='瘦瘦猫:BAAAKgAECgQIBAAAAA==.',['白发']='白发加纹身:BAAAKgAECggICAAAAA==.',['百日']='百日衣衫浸:BAAAKgAECgYIBgAAAA==.',['百炼']='百炼钢:BAAAKgAECgYIBgAAAA==.',['目标']='目标隐身:BAAAKgAECgUIBQAAAA==.',['看不']='看不到我哦:BAAAKgADCgEIAQAAAA==.',['看渝']='看渝可:BAAAKgAFFAQIBAAAAA==.',['真的']='真的很黑:BAAAKgADCggICAAAAA==.',['真龙']='真龙:BAAAKgAECgcICgAAAA==.',['督军']='督军的戒指:BAABKgAFFH8cAAMOAAgINhyMBABhAgAOAAgIpRqMBABhAgANAAYI5h/BCADOAQAAAA==.',['神奇']='神奇女侠:BAAAKgADCggICAAAAA==.',['神封']='神封:BAABKgAECn8UAAIWAAgIXwzPNAABAQAWAAgIXwzPNAABAQAAAA==.',['祟拜']='祟拜你的:BAAAKgAECgEIAQAAAA==.',['秋月']='秋月:BAAAKgADCgQIBAAAAA==.',['秋水']='秋水仙:BAABKgAFFH8GAAINAAYIMBokCwCkAQANAAYIMBokCwCkAQAAAA==.',['科不']='科不科学:BAAAKgAECgEIAQAAAA==.',['稍微']='稍微的稍:BAAAKgAECgYIBgAAAA==.',['稳住']='稳住别动:BAAAKgAFFAIIBAAAAA==.',['稻草']='稻草小溪:BAABKgAFFH8JAAMQAAgIrRESDQA6AQAQAAUIAAoSDQA6AQAPAAQIARIgFADqAAAAAA==.',['端梦']='端梦云:BAABKgAFFH8KAAIYAAYI8gztEAD7AAAYAAYI8gztEAD7AAAAAA==.',['第二']='第二序列:BAAAKgAECgYIBgAAAA==.',['粉小']='粉小朵:BAAAKgADCggICAAAAA==.粉小满:BAABKgAECn8UAAIJAAgI3w4HVgApAQAJAAgI3w4HVgApAQAAAA==.',['粉色']='粉色忧郁:BAAAKgAECgUIBQAAAA==.',['糖哆']='糖哆哆:BAABKgAFFH8GAAIRAAYIxhO6FwBGAQARAAYIxhO6FwBGAQAAAA==.',['红枣']='红枣汤面:BAAAKgAECggICAAAAA==.',['纯情']='纯情的小火球:BAAAKgAECgYIBgAAAA==.',['终于']='终于有美短拉:BAAAKgAECgYIBgAAAA==.',['绯血']='绯血玉沙:BAAAKgAECgQIBgAAAA==.',['缝氏']='缝氏之术:BAAAKgADCggICAAAAA==.缝氏之猎:BAAAKgADCggIDgAAAA==.',['罗东']='罗东:BAAAKgAFFAEIAQAAAA==.',['罗德']='罗德里格兹:BAAAKgAFFAMIAwAAAA==.',['翠花']='翠花的男人:BAAAKgADCgMIAwAAAA==.',['老兵']='老兵克林:BAAAKgAFFAIIAgAAAA==.',['老灬']='老灬萨满:BAAAKgADCgEIAQAAAA==.',['老蔡']='老蔡一碟:BAAAKgAFFAgIBAAAAA==.',['聖丨']='聖丨灬臨:BAAAKgAECgQIBAAAAA==.',['肚腩']='肚腩超人:BAAAKgAECgYIBgAAAA==.',['胡德']='胡德禄:BAABKgAFFH8IAAIPAAgI9Q2HCgDoAQAPAAgI9Q2HCgDoAQAAAA==.',['胧夜']='胧夜:BAACKgAFFH8UAAITAAMI5wfwLgCKAAATAAMI5wfwLgCKAAAqAAQKf0MAAhMACAhvFh8vAGkBABMACAhvFh8vAGkBAAAA.',['艳无']='艳无忧:BAAAKgAECgEIAQAAAA==.',['艾琳']='艾琳娜:BAAAKgADCggICAAAAA==.',['芊摩']='芊摩:BAAAKgAFFAQIBAAAAA==.',['芊沫']='芊沫:BAABKgAFFH8IAAIPAAQIDibUBgA8AQAPAAQIDibUBgA8AQAAAA==.',['芒果']='芒果星冰乐:BAACKgAFFH8IAAMQAAMILwZAKgB6AAAQAAMILwZAKgB6AAAeAAIIWQwtDABUAAAqAAQKfxsAAx4ACAjXG5wHAAgCAB4ACAjXG5wHAAgCABAAAwiXEz5iAI4AAAAA.',['苏妲']='苏妲己:BAAAKgAECgQIBAAAAA==.',['茪茪']='茪茪:BAAAKgADCggICAAAAA==.',['草莓']='草莓奶昔:BAAAKgADCgEIAgAAAA==.',['萌羽']='萌羽然:BAAAKgAFFAYIBAAAAA==.',['萌萌']='萌萌的天宫德:BAAAKgAECgIIAgAAAA==.',['萤流']='萤流夏夜月:BAAAKgADCgcIBwAAAA==.',['蓝灵']='蓝灵落:BAAAKgAECgQIBAAAAA==.',['蓝调']='蓝调咖啡:BAAAKgAECgQIBAAAAA==.',['蕶丶']='蕶丶薍:BAAAKgAECgEIAQAAAA==.',['蕾依']='蕾依莎:BAAAKgAECggICAAAAA==.',['藤尤']='藤尤立香:BAAAKgAECggICAAAAA==.',['蘑菇']='蘑菇姐姐:BAABKgAFFH8LAAMPAAQIgx68IwAKAQAPAAQIgx68IwAKAQAQAAQIjRGMJACTAAAAAA==.',['蛋只']='蛋只有一粒:BAAAKgAECggICgAAAA==.',['蜡笔']='蜡笔猪小呆:BAABKgAFFH8SAAIFAAYI+BxJCADWAQAFAAYI+BxJCADWAQABKgAFFAgIDgAFAK4iAA==.',['见死']='见死不救啊:BAABKgAECn8bAAIgAAgIuxznAwA0AgAgAAgIuxznAwA0AgAAAA==.',['誮訫']='誮訫囖啵:BAAAKgAECgIIBAAAAA==.',['諸葛']='諸葛流雲:BAAAKgAECgEIAQAAAA==.諸葛雲天:BAAAKgAECgYIBgAAAA==.諸葛鴻鈞:BAABKgAECn8VAAITAAgInRn9GgDqAQATAAgInRn9GgDqAQAAAA==.',['诸葛']='诸葛天涯:BAABKgAECn8nAAIGAAgIkRtjFQAQAgAGAAgIkRtjFQAQAgAAAA==.',['谁的']='谁的眼泪:BAABKgAFFH8cAAMKAAUISR14CwBbAQAKAAUISR14CwBbAQAbAAQIZRLwHgCsAAABKgAFFAYIQQAJABIaAA==.',['谪仙']='谪仙:BAACKgAFFH8dAAMNAAQIegy9NgCaAAANAAQIRwq9NgCaAAAOAAMI9AjVNwCIAAAqAAQKfxgAAw0ACAiIF9csALABAA0ACAg1FtcsALABAA4ABwg9E+OIAMEAAAAA.',['贰零']='贰零零:BAAAKgAECgIIAgAAAA==.',['赎罪']='赎罪者卢克:BAAAKgAFFAEIAQAAAA==.',['赵乐']='赵乐意:BAAAKgADCggIDwAAAA==.',['赵欢']='赵欢乐:BAAAKgADCgEIAQAAAA==.',['赵精']='赵精神:BAAAKgAECgYICwAAAA==.',['踏岚']='踏岚风:BAABKgAECn8ZAAMWAAgIFRqAIQDkAQAWAAgIFRqAIQDkAQAdAAYIgw/ZPwAPAQAAAA==.',['身体']='身体被掏空:BAAAKgADCgIIAgAAAA==.',['轰雷']='轰雷赤帝冲:BAAAKgAECgEIAQAAAA==.',['酒丶']='酒丶妹:BAAAKgAFFAIIAgAAAA==.',['酒神']='酒神咖啡:BAAAKgAECgQIBAAAAA==.',['醪糟']='醪糟蛋:BAAAKgADCgQIBAAAAA==.',['重生']='重生的守护:BAAAKgAFFAQIBAAAAA==.',['重装']='重装南瓜:BAAAKgAECgcIDQAAAA==.',['錒尔']='錒尔萨斯:BAAAKgAFFAQIBAAAAA==.',['锤子']='锤子:BAAAKgADCggICAAAAA==.',['长岛']='长岛冰茶:BAAAKgADCgYIBgAAAA==.',['闲庭']='闲庭信步:BAABKgAFFH8ZAAMJAAgICxdGBQDhAQAJAAgICxdGBQDhAQAXAAYIgxTHBgBqAQAAAA==.',['阚疃']='阚疃:BAAAKgAECgQIBAAAAA==.',['阿贫']='阿贫:BAACKgAFFH8XAAQGAAQILiFaCwATAQAGAAMILiFaCwATAQAHAAMIQxRRNgCJAAAIAAIITg6QOgBIAAAqAAQKfx4ABAgACAhSIm0zAMwBAAgABwjgHG0zAMwBAAYABwjpGRM4AI0BAAcAAwgvITNQAP4AAAAA.',['陈程']='陈程:BAAAKgAECgQIBAAAAA==.',['随便']='随便起个名子:BAAAKgAECgUIBQAAAA==.',['雨兮']='雨兮:BAAAKgAECgMIAwAAAA==.',['雪莉']='雪莉娅:BAAAKgAECgIIAgAAAA==.',['雪落']='雪落吟:BAAAKgAECgMIAwAAAA==.',['雷霆']='雷霆丶暴怒:BAAAKgAECgYIBgAAAA==.',['霞之']='霞之丘诗雨:BAACKgAFFH8RAAMNAAMI+xWOHACJAAANAAIIRBmOHACJAAAOAAIIYAmUUQBmAAAqAAQKfzcAAw0ACAgjHL4fANUBAA0ACAjKG74fANUBAA4ACAiCF7E5AL4BAAAA.',['露小']='露小缝:BAAAKgAFFAIIAgAAAA==.',['霸道']='霸道天子:BAAAKgAECgEIAQAAAA==.',['青岚']='青岚丶:BAAAKgAECgUIBgAAAA==.',['青椒']='青椒炒肉:BAAAKgAECgMIBAAAAA==.',['韩小']='韩小樱:BAAAKgAFFAEIAQAAAA==.',['风吹']='风吹日晒:BAAAKgAECggICAAAAA==.',['风精']='风精之贼:BAAAKgADCgcIBwAAAA==.风精僧:BAAAKgAECgYIBgAAAA==.',['香橙']='香橙布丁:BAAAKgADCgEIAgAAAA==.',['鬼火']='鬼火绿资得很:BAAAKgADCgEIAQAAAA==.',['鬼神']='鬼神刻瑞斯:BAAAKgAECgIIAgAAAA==.',['魔灬']='魔灬由心生:BAABKgAFFH8KAAMNAAYI5xR0FgAxAQANAAYIiRJ0FgAxAQAOAAQIqBtEIgABAQAAAA==.',['鸳鸳']='鸳鸳相抱:BAACKgAFFH8VAAIhAAMIwQVJCQB1AAAhAAMIwQVJCQB1AAAqAAQKf0sAAiEACAhrEB0PADwBACEACAhrEB0PADwBAAAA.',['黄易']='黄易老头:BAAAKgAECgEIAQAAAA==.',['龙龙']='龙龙饿够:BAABKgAFFH8MAAIBAAgIWhcSDwBvAQABAAgIWhcSDwBvAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end