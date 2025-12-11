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
 local lookup = {'DeathKnight-Frost','Hunter-BeastMastery','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Druid-Balance','Evoker-Preservation','Evoker-Devastation','Paladin-Retribution','Warrior-Protection','Paladin-Protection','Paladin-Holy','Mage-Arcane','Mage-Frost','Warlock-Destruction','Warrior-Fury','Druid-Guardian','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','DeathKnight-Blood','DemonHunter-Vengeance','Hunter-Marksmanship','Mage-Fire','Unknown-Unknown','Warlock-Demonology',}; local provider = {region='CN',realm='埃苏雷格',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akiraovo:BAACLAAFFH8RAAIBAAYIwxGGHAA9AQABAAYIwxGGHAA9AQAsAAQKfx4AAgEACAiVIrIHAMQCAAEACAiVIrIHAMQCAAAA.',Ar='Artemisia:BAAALAAECggIDwAAAA==.',At='Atreter:BAAALAAECgYIBgAAAA==.',Au='Aurona:BAAALAAECgIIAgABLAAFFAYIEQABAMMRAA==.',Cz='Czar:BAAALAADCgYIBgAAAA==.',Du='Dumbledore:BAAALAAECggICQAAAA==.',En='Enzo:BAABLAAFFH8GAAICAAYIxBZBCgDrAQACAAYIxBZBCgDrAQAAAA==.',Ho='Hoka:BAACLAAFFH8JAAIDAAMIMxiSMwDZAAADAAMIMxiSMwDZAAAsAAQKfxcAAwMABgjxDfFaAPUAAAMABgjxDfFaAPUAAAQAAwihCmJhAI4AAAAA.',La='Lai:BAAALAAECgQIBAAAAA==.',Li='Ling:BAACLAAFFH8nAAMFAAYIew+7GQBgAQAFAAYIew+7GQBgAQAGAAEIbQRfPQAtAAAsAAQKfyYAAwUACAiuGgIkAFkCAAUACAiuGgIkAFkCAAYABQg7BgpLAIoAAAAA.Lissther:BAAALAAECgYICQAAAA==.',Mi='Milkisgy:BAAALAAECgQIBwAAAA==.',Re='Recordare:BAAALAADCggIEAAAAA==.',Ro='Ronard:BAAALAADCgMIAwAAAA==.',Te='Tearra:BAAALAADCgEIAQABLAAFFAYIEQABAMMRAA==.',Ve='Venu:BAAALAAECgUIBQAAAA==.',['一个']='一个小坏蛋:BAAALAAECgQIBAAAAA==.',['一切']='一切随缘:BAAALAADCgUIBgAAAA==.',['一念']='一念起一念灭:BAAALAAECgYIDQAAAA==.',['一支']='一支穿雲箭:BAAALAAECgYIDQAAAA==.',['不讲']='不讲武德:BAAALAADCgMIAwAAAA==.',['丢个']='丢个锤子:BAAALAADCgIIAgAAAA==.',['丨傻']='丨傻馒丨:BAAALAAECgYIBwAAAA==.',['丶然']='丶然然:BAAALAAECgcIBwAAAA==.',['丶珏']='丶珏珏:BAAALAAECgcIBwAAAA==.',['丶茹']='丶茹果:BAAALAAECgQIBAAAAA==.',['丹顶']='丹顶龟凤草杨:BAAALAAECgQIBgAAAA==.',['乱夜']='乱夜月:BAAALAAECgYIBgAAAA==.',['仙气']='仙气飘飘:BAAALAADCggIFgAAAA==.',['以南']='以南:BAACLAAFFH8OAAMHAAUIsRSMEAAhAQAHAAQILBeMEAAhAQAIAAIIDwVGGAB7AAAsAAQKfxQAAwcABwiYHvUEAGgCAAcABwiYHvUEAGgCAAgABQh6FvIaABwBAAEsAAUUBggKAAUAGw4A.',['依旧']='依旧随风:BAABLAAFFH8LAAIJAAIIxh7dPgCfAAAJAAIIxh7dPgCfAAAAAA==.',['光明']='光明之锤:BAAALAAECgYIBgAAAA==.',['八尺']='八尺:BAAALAAECgYICQAAAA==.',['六不']='六不溜:BAABLAAECn8YAAIBAAgIfhFsMwCqAQABAAgIfhFsMwCqAQAAAA==.',['兵之']='兵之幻:BAABLAAECn8fAAIJAAYIKBHkcgAcAQAJAAYIKBHkcgAcAQAAAA==.',['冬蔻']='冬蔻:BAAALAAECgUIBQAAAA==.',['冷月']='冷月淘气猫:BAAALAAECgYICwAAAA==.',['凡灵']='凡灵若柍:BAAALAAECgIIAgAAAA==.凡灵若柟:BAAALAADCggICAAAAA==.凡灵若槿:BAAALAAECgUIBQAAAA==.',['凯文']='凯文灬路易斯:BAAALAADCgMIAwAAAA==.',['切防']='切防战带你啊:BAACLAAFFH8oAAIKAAYI9BU/DgBjAQAKAAYI9BU/DgBjAQAsAAQKfxYAAgoABggtHgwUAKkBAAoABggtHgwUAKkBAAAA.',['别掰']='别掰我大牙:BAABLAAFFH8JAAILAAMIcQ4+EwBbAAALAAMIcQ4+EwBbAAAAAA==.',['北冥']='北冥羽鹤:BAAALAADCgIIAgAAAA==.',['卖报']='卖报小郎君:BAABLAAFFH8KAAICAAYIGg0PPgBNAQACAAYIGg0PPgBNAQAAAA==.',['卡德']='卡德珈:BAAALAAFFAIIBAAAAA==.',['叫我']='叫我法爷:BAAALAAECgYICAAAAA==.',['吃的']='吃的好睡的香:BAAALAADCgMIAwAAAA==.',['合法']='合法萝莉:BAABLAAFFH8IAAIJAAgI+ADvhAAXAAAJAAgI+ADvhAAXAAAAAA==.',['君莫']='君莫笑:BAAALAAECgYIBgAAAA==.',['吾法']='吾法無天:BAAALAAECgUIBgAAAA==.',['呼呼']='呼呼砍起来:BAAALAAECgUICQAAAA==.',['啥也']='啥也不做:BAAALAADCgcIBwAAAA==.',['啦啦']='啦啦咯咯:BAAALAAECgMIAwAAAA==.',['喜欢']='喜欢阴天:BAAALAADCgYIBgAAAA==.',['回忆']='回忆雪静:BAACLAAFFH8IAAIJAAQIoxd/NwDEAAAJAAQIoxd/NwDEAAAsAAQKfxsAAgkABwgPIllLAFwCAAkABwgPIllLAFwCAAAA.',['圣丶']='圣丶光丨:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光在佑:BAACLAAFFH8aAAMMAAYIsQ2OEQBvAQAMAAYIsQ2OEQBvAQAJAAUITQcdMQD7AAAsAAQKfxYAAwwABwj4Fg8YAJIBAAwABwj4Fg8YAJIBAAkAAQi3ArCSAScAAAAA.',['堕落']='堕落的风行者:BAAALAADCgEIAQAAAA==.',['墨陌']='墨陌默默:BAACLAAFFH8qAAINAAcIKiLvCwAnAgANAAcIKiLvCwAnAgAsAAQKfxoAAw0ACAhPHaU5AGMCAA0ACAhPHaU5AGMCAA4AAgg3F5J+AHAAAAAA.',['夏天']='夏天的风:BAABLAAFFH8GAAIPAAIIUxSMRgCPAAAPAAIIUxSMRgCPAAAAAA==.',['夜晚']='夜晚杀手:BAAALAAFFAIIAgAAAA==.',['大棒']='大棒:BAAALAADCgEIAQAAAA==.',['大理']='大理:BAAALAAECgYIDQAAAA==.',['大苏']='大苏打啊实:BAABLAAFFH8JAAIDAAIIdA3gZQBVAAADAAIIdA3gZQBVAAAAAA==.',['大香']='大香长叔叔:BAAALAADCgEIAQAAAA==.',['天之']='天之妖狐:BAAALAAECgYIDwAAAA==.',['天堂']='天堂光彩:BAAALAADCgcICAAAAA==.',['天天']='天天丶痴:BAAALAADCgYIBgAAAA==.天天吃土:BAAALAADCgMIAwAAAA==.',['天煞']='天煞龙威:BAAALAAECgUIBQAAAA==.',['天驱']='天驱一光喀:BAAALAAECgcIBwAAAA==.',['妖精']='妖精:BAAALAAECgUIBQAAAA==.',['姓生']='姓生生活贼好:BAAALAAECgYIBgAAAA==.',['婷不']='婷不下来继续:BAAALAAECgEIAQAAAA==.',['孤舟']='孤舟灬蓑笠翁:BAAALAADCgQIBAAAAA==.',['安达']='安达莉尔:BAAALAADCgIIAgAAAA==.',['小妖']='小妖蜜三锤:BAAALAAECgEIAQAAAA==.',['小时']='小时候很丑:BAABLAAFFH8IAAIQAAYI4w1ECgDwAQAQAAYI4w1ECgDwAQAAAA==.',['小桃']='小桃红:BAAALAAECgQIBAAAAA==.',['小董']='小董丶不懂:BAAALAAECgMIAwAAAA==.',['少吃']='少吃点糖丶:BAAALAADCgQIBAAAAA==.',['巧云']='巧云:BAAALAAECgYIBgAAAA==.',['布兰']='布兰琪:BAAALAAECgcIBwAAAA==.',['帕梅']='帕梅罗汉堂:BAAALAADCgYIBgAAAA==.',['常闇']='常闇:BAAALAADCgcIBwAAAA==.',['床前']='床前明月光:BAAALAADCgYIBgAAAA==.',['开心']='开心每一天:BAAALAAECgYIBgAAAA==.',['弗拉']='弗拉迪諾:BAAALAAECgYICQAAAA==.',['彩虹']='彩虹幻熊:BAABLAAFFH8MAAIJAAMIJBShQwCJAAAJAAMIJBShQwCJAAAAAA==.',['德宠']='德宠:BAAALAADCgMIAwAAAA==.',['心儿']='心儿:BAAALAADCggICgAAAA==.',['忘却']='忘却怀念:BAAALAADCggICQAAAA==.',['忙碌']='忙碌的肖宇:BAABLAAFFH8IAAIBAAIIkgzTggBEAAABAAIIkgzTggBEAAAAAA==.',['怀特']='怀特迈恩:BAAALAAECgcICwAAAA==.',['恶魔']='恶魔火焰:BAAALAAECgQIBAAAAA==.',['悲情']='悲情英雄:BAAALAADCgQICAAAAA==.',['愈慢']='愈慢愈美丽:BAABLAAFFH8FAAIJAAIIPgzYUgCPAAAJAAIIPgzYUgCPAAAAAA==.',['我不']='我不会奶:BAABLAAFFH8eAAMDAAYInhi6EwDEAQADAAYInhi6EwDEAQAEAAEIDQU3TwA2AAAAAA==.',['我就']='我就是演员:BAAALAAECggICAAAAA==.',['我是']='我是豆子:BAAALAADCgEIAQAAAA==.',['我说']='我说你还追啊:BAAALAADCgIIAgAAAA==.',['我跑']='我跑滴滴呢:BAABLAAFFH8TAAIPAAQIug4iIgANAQAPAAQIug4iIgANAQAAAA==.',['战丶']='战丶天下:BAAALAADCgYIBgAAAA==.',['手拉']='手拉手:BAAALAAECgMIAwAAAA==.',['打不']='打不死就説:BAAALAAECggICAAAAA==.',['抬腿']='抬腿就是一掌:BAAALAADCgIIAgAAAA==.',['摩凡']='摩凡陀:BAAALAAECgYIBgAAAA==.',['无聊']='无聊的夏宇:BAABLAAFFH8GAAIRAAIIigiGEAAkAAARAAIIigiGEAAkAAAAAA==.',['既要']='既要又要还要:BAABLAAFFH8FAAIFAAMIkQpdNgCQAAAFAAMIkQpdNgCQAAAAAA==.',['旺旺']='旺旺掀被:BAAALAAECgEIAQAAAA==.',['星璇']='星璇:BAAALAAFFAMIAwAAAA==.',['暗影']='暗影螃蟹:BAAALAADCgYIBgAAAA==.',['暗黑']='暗黑狼王:BAABLAAFFH8WAAIRAAYIxw1EBAAFAQARAAYIxw1EBAAFAQAAAA==.',['暴力']='暴力的葡萄:BAAALAAECgUIBQAAAA==.',['月半']='月半小夜曲:BAAALAAFFAIIAgAAAA==.',['杀戮']='杀戮主角:BAAALAADCgQIBAAAAA==.杀戮狂暴:BAAALAAECgUICAAAAA==.',['来自']='来自非酋的你:BAAALAAECgIIAgAAAA==.',['染指']='染指浮生梦:BAAALAAECgYIEgAAAA==.',['格兰']='格兰瑞尔:BAAALAAECgcIBwAAAA==.',['桑尼']='桑尼哥:BAAALAADCgEIAQAAAA==.',['梦流']='梦流沙:BAAALAAFFAIIAgAAAA==.',['梦若']='梦若兰:BAAALAAFFAEIAQAAAA==.',['橡皮']='橡皮树:BAAALAAECggICAAAAA==.',['法瑞']='法瑞婭:BAAALAAECggICAAAAA==.',['泰岚']='泰岚德:BAAALAADCggICAAAAA==.',['洛漓']='洛漓丶雨道:BAAALAAECggIDgAAAA==.',['浊世']='浊世清欢:BAABLAAECn8WAAMSAAYIoA46GwAcAQASAAYIiw06GwAcAQATAAYILwenRwC8AAAAAA==.',['浮生']='浮生欢愉少:BAAALAAECgUIBQAAAA==.',['浮花']='浮花浪蕊:BAABLAAFFH8IAAIUAAIIYSEPSABWAAAUAAIIYSEPSABWAAAAAA==.',['海释']='海释靈:BAAALAAECgcIBwAAAA==.',['涼宫']='涼宫遙:BAAALAADCgIIAgAAAA==.',['游侠']='游侠火羽:BAAALAAECgcIBwAAAA==.',['潇洒']='潇洒叔:BAAALAADCggICAAAAA==.',['潘达']='潘达奈蔻:BAAALAAECgYIBgAAAA==.',['潶咻']='潶咻潶咻:BAAALAADCgIIAgAAAA==.',['火热']='火热的肚兜:BAAALAADCgQIBAAAAA==.',['狂奔']='狂奔的花生:BAABLAAFFH8GAAIFAAIIowcGTwBVAAAFAAIIowcGTwBVAAAAAA==.',['狐涂']='狐涂涂:BAAALAAECgYICQAAAA==.',['珍珠']='珍珠:BAACLAAFFH86AAIUAAcIMiUnAwByAgAUAAcIMiUnAwByAgAsAAQKfz0AAhQACAi9Jl8BAJADABQACAi9Jl8BAJADAAAA.',['生死']='生死去来:BAABLAAFFH8NAAITAAQIbRbHJAAWAQATAAQIbRbHJAAWAQAAAA==.',['白玉']='白玉:BAAALAAECggIDQABLAAFFAcIOgAUADIlAA==.',['真硬']='真硬:BAAALAADCgEIAQAAAA==.',['瞅见']='瞅见你辣眼睛:BAABLAAFFH8LAAMBAAgIBhN5IAAgAQAVAAgI2QtbBwC3AQABAAMIWhx5IAAgAQAAAA==.',['石英']='石英:BAACLAAFFH8FAAIBAAQIpw2wTwDhAAABAAQIpw2wTwDhAAAsAAQKfxUAAgEACAidHy0PAHQCAAEACAidHy0PAHQCAAEsAAUUBwg6ABQAMiUA.',['私藏']='私藏和弦:BAACLAAFFH8JAAIQAAMIBwyoPAB9AAAQAAMIBwyoPAB9AAAsAAQKfxwAAwoACAh9GPAaAGkBABAABgisGcY7AGoBAAoABwgkFPAaAGkBAAAA.',['空青']='空青:BAABLAAECn8nAAMUAAgISCXQAwD2AgAUAAgISCXQAwD2AgAWAAMIaAuMVgB0AAAAAA==.',['素娅']='素娅:BAAALAAECgYIBgAAAA==.',['索菲']='索菲亚的图腾:BAAALAADCgMIAgAAAA==.',['紫月']='紫月雪:BAAALAAFFAEIAQAAAA==.',['红烧']='红烧排骨盖饭:BAAALAADCgMIAwAAAA==.',['罐头']='罐头盒:BAAALAAECgcIBwAAAA==.',['美杜']='美杜莎的泪痕:BAABLAAFFH8LAAIFAAMIRxUrKwDCAAAFAAMIRxUrKwDCAAAAAA==.',['老麵']='老麵:BAAALAAECgIIAgAAAA==.',['而今']='而今是老头:BAAALAADCgEIAQAAAA==.',['聆听']='聆听雨眠:BAABLAAFFH8ZAAMJAAUIWhLbKQAvAQAJAAUIWhLbKQAvAQALAAUIawhYDADLAAAAAA==.',['胡须']='胡须人:BAAALAAECgYICgAAAA==.',['荒野']='荒野之召唤:BAAALAAFFAEIAQAAAA==.',['菠菜']='菠菜二零零五:BAAALAADCgQIBAAAAA==.',['萍茜']='萍茜:BAAALAAFFAIIAgAAAA==.',['萨莉']='萨莉亚丶和平:BAAALAAECgMIAwAAAA==.',['落落']='落落磊磊:BAABLAAFFH8gAAMEAAYIjRv+EwCcAQAEAAYIjRv+EwCcAQADAAIIaw1DUgBqAAAAAA==.',['蓝玉']='蓝玉:BAACLAAFFH8WAAIUAAQIDiRyFgArAQAUAAQIDiRyFgArAQAsAAQKfy0AAxQACAi/JUgPADQDABQACAi/JUgPADQDABYAAQgyC9ppACsAAAEsAAUUBwg6ABQAMiUA.',['蓬头']='蓬头傀儡:BAAALAAECggIBgAAAA==.',['血色']='血色十字军:BAAALAADCggICAAAAA==.血色守卫者:BAAALAAECgUIBQAAAA==.',['裂石']='裂石丶:BAAALAAFFAgIAgAAAA==.',['豆沙']='豆沙包包:BAAALAAFFAEIAQAAAA==.',['邀玥']='邀玥:BAAALAAECgYIDgAAAA==.',['邓不']='邓不力小多:BAAALAAFFAIIAgAAAA==.',['那些']='那些年的弯路:BAAALAADCggICwAAAA==.',['酒醉']='酒醉為紅顏:BAAALAAECgYIBwAAAA==.',['酷酷']='酷酷洋仔:BAAALAAECgQIBAAAAA==.',['醉幻']='醉幻熊:BAABLAAECn8qAAMCAAcIhBwlQADLAQACAAYI0x8lQADLAQAXAAcIzxE8TgB9AQAAAA==.',['醉月']='醉月聆雪:BAAALAAECgYIBgAAAA==.',['醉酒']='醉酒為紅顏:BAAALAAECgIIAgAAAA==.',['重生']='重生之我是猪:BAACLAAFFH8KAAMHAAIIAg5oFACKAAAHAAIIAg5oFACKAAAIAAII6Q2CGwCGAAAsAAQKfycAAwcABwgpEqYcAJABAAcABwgpEqYcAJABAAgABgg9GS03AHgBAAAA.',['金色']='金色指环:BAACLAAFFH8MAAIJAAIIvwiWbABAAAAJAAIIvwiWbABAAAAsAAQKfzEAAgkACAhdFbVIAIIBAAkACAhdFbVIAIIBAAAA.',['鑫鱻']='鑫鱻:BAAALAAECgQIBAAAAA==.',['键盘']='键盘斗士:BAACLAAFFH83AAQNAAcI0CP3BABXAgANAAcI0CP3BABXAgAYAAMIOhdDBwCWAAAOAAIIbxIhDQCHAAAsAAQKfykABA0ACAi7I8YcAN8CAA0ACAhCIsYcAN8CAA4ABQgnJJEgABgCABgAAQgIIdAaAGMAAAAA.',['长风']='长风吹雪:BAAALAADCgYIBgAAAA==.',['阳光']='阳光玫瑰:BAAALAAECggICAAAAA==.',['阿斯']='阿斯特鲁:BAAALAAECgMIAwAAAA==.',['随风']='随风而去了:BAAALAADCgEIAQAAAA==.',['霜之']='霜之刃:BAAALAAECgEIAQAAAA==.',['霜舞']='霜舞:BAAALAAECgYIBgAAAA==.',['青争']='青争王木木:BAAALAADCgYIBgAAAA==.',['青柠']='青柠丶枂笙:BAAALAAECgUIBQAAAA==.',['非洲']='非洲使者:BAAALAAECgEIAQAAAA==.',['风中']='风中的火焰:BAAALAAECggIDgAAAA==.',['风过']='风过留痕:BAABLAAECn8YAAMCAAYI0x+sdgDwAQACAAYI0x+sdgDwAQAXAAMIJRC9mACMAAAAAA==.',['风追']='风追雨随:BAABLAAFFH8FAAIOAAIIPhaJDwCRAAAOAAIIPhaJDwCRAAAAAA==.',['风铃']='风铃花:BAABLAAECn8YAAIXAAYISBY5TQCAAQAXAAYISBY5TQCAAQAAAA==.',['飞天']='飞天遇见刘:BAAALAAECgcIDQAAAA==.',['食魂']='食魂者阿莱利:BAAALAAECgcIBwABLAAECgcICwAZAAAAAA==.',['高巢']='高巢:BAAALAAFFAIIAgAAAA==.',['高罺']='高罺:BAABLAAFFH8GAAICAAIIVw8SkABFAAACAAIIVw8SkABFAAAAAA==.',['鬼少']='鬼少:BAABLAAECn8mAAIUAAcI3R/2FgAiAgAUAAcI3R/2FgAiAgAAAA==.',['魂魄']='魂魄之怨:BAABLAAFFH8HAAMaAAIIIxsaHQCCAAAPAAIIzRKERgCQAAAaAAIIzwsaHQCCAAAAAA==.',['魏老']='魏老师:BAAALAADCgEIAQAAAA==.',['黃昏']='黃昏的邂逅:BAACLAAFFH8FAAIQAAIIWRpCJwCqAAAQAAIIWRpCJwCqAAAsAAQKfxsAAhAABgj5JKQyAGsCABAABgj5JKQyAGsCAAAA.',['默默']='默默的祈祷:BAACLAAFFH8ZAAIDAAYI3R93CQAwAgADAAYI3R93CQAwAgAsAAQKfx0AAwMACAgYF9k3AH0BAAMACAgYF9k3AH0BAAQABQgmFWp5AFQBAAAA.',['龙柏']='龙柏虎宝:BAAALAAECggIDQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end