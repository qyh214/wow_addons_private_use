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
 local lookup = {'Paladin-Holy','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Mistweaver','Warrior-Fury','Warrior-Arms','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Druid-Guardian','Warrior-Protection','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Hunter-Marksmanship','Monk-Windwalker','Hunter-BeastMastery','Priest-Holy','Mage-Frost','Mage-Arcane','Mage-Fire',}; local provider = {region='CN',realm='萨洛拉丝',name='CN',type='weekly',zone=42,date='2025-08-08',data={Db='Dbb:BAACKgAFFH8GAAIBAAYIQxMRBgBpAQABAAYIQxMRBgBpAQAqAAQKfxQABAEACAiEDE0yANMAAAEABggUDU0yANMAAAIAAwiYB2n9AHMAAAMAAQj3ApFiAAYAAAAA.',De='Demonfiend:BAABKgAFFH8nAAMEAAgIcxT9BwAQAgAEAAgIcxT9BwAQAgAFAAYIOw5ECgAFAQAAAA==.',Gq='Gqq:BAAAKgAECgIIAgAAAA==.',Ha='Haoee:BAAAKgAECgEIAQAAAA==.',Ho='Holycow:BAAAKgADCggICAAAAA==.',Sh='Shadowsong:BAAAKgADCgEIAQAAAA==.',Ty='Tydrande:BAAAKgAECggIEgAAAA==.',Wt='Wtkiler:BAAAKgADCgQIBAAAAA==.',Ye='Yepat:BAAAKgADCggICAAAAA==.',Yu='Yukicool:BAAAKgAECgMIAwAAAA==.',['一个']='一个圈圈:BAABKgAFFH8GAAICAAYIdh1tFgCoAQACAAYIdh1tFgCoAQAAAA==.',['一叶']='一叶飘萍:BAAAKgAECgEIAQAAAA==.',['一直']='一直未命中丶:BAAAKgAFFAIIAgAAAA==.',['七星']='七星冷月:BAABKgAFFH8LAAIGAAMIRBWaGgDIAAAGAAMIRBWaGgDIAAAAAA==.',['世界']='世界小怪兽:BAAAKgADCgMIAwAAAA==.',['丢不']='丢不掉的回忆:BAAAKgADCggICAAAAA==.',['丨打']='丨打獵的灬:BAAAKgAECgcIBwAAAA==.',['丨水']='丨水银之毒丨:BAAAKgADCgQIBAAAAA==.',['丨雷']='丨雷戰丶龍:BAABKgAECn8UAAMHAAcIWxgkKQCXAQAHAAcIWxgkKQCXAQAIAAII+xMcJQBEAAAAAA==.',['丶叁']='丶叁叁:BAAAKgAECgYIBwAAAA==.',['丶小']='丶小姨妈:BAABKgAFFH8uAAMJAAgI1BbLBQD2AQAJAAgI1BbLBQD2AQAKAAQIPg4CDADPAAAAAA==.',['丶雨']='丶雨雾晴晨:BAACKgAFFH8IAAILAAQI/QsAJQCfAAALAAQI/QsAJQCfAAAqAAQKfxQAAwsACAi5GpNAALQBAAsABwj7HZNAALQBAAwAAQgpB1U6ABIAAAAA.',['代号']='代号零:BAAAKgAECgEIAQAAAA==.',['以受']='以受为攻:BAAAKgAFFAgIAQABKgAFFAYIDAANAKwSAA==.',['你三']='你三叔的表哥:BAABKgAFFH8XAAQOAAgIZCQgAQDkAgAOAAgIXCMgAQDkAgAPAAQIpiEeAQBKAQAQAAUIUBOWBgAQAQAAAA==.',['信我']='信我永生:BAAAKgAECgYIBgAAAA==.',['修修']='修修婉儿:BAAAKgAECgUIBQAAAA==.',['倚楼']='倚楼聼雨櫊:BAAAKgADCgEIAQAAAA==.',['元素']='元素增强:BAAAKgADCgUIBQAAAA==.',['卖萌']='卖萌的默默:BAAAKgAECgcIBwAAAA==.',['卟黛']='卟黛凶兆:BAAAKgADCgUICQAAAA==.',['召命']='召命:BAABKgAECn8nAAIRAAgItx/1GAAJAgARAAgItx/1GAAJAgAAAA==.',['哆哆']='哆哆护卫:BAAAKgAFFAIIAgAAAA==.',['喂你']='喂你绿粑:BAAAKgAFFAQIBAAAAA==.',['嘟嘟']='嘟嘟桐桐:BAAAKgAFFAIIAgAAAA==.',['噌一']='噌一风暴啤酒:BAAAKgADCgMIAwAAAA==.',['回收']='回收旧家电:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光来也:BAAAKgAECggIDgAAAA==.',['坐拥']='坐拥天下:BAAAKgAECggIEAAAAA==.',['壮壮']='壮壮芭比:BAAAKgADCgEIAQAAAA==.',['夏乄']='夏乄樱络灬:BAAAKgAECggIEAAAAA==.',['夏洛']='夏洛儿:BAAAKgAECgYIDgAAAA==.',['多多']='多多:BAAAKgAECgIIAgAAAA==.',['夜礼']='夜礼服:BAAAKgADCggICAAAAA==.',['大牛']='大牛蹄子:BAAAKgAECggICAAAAA==.',['奔波']='奔波儿灞波儿:BAAAKgAECgIIAgAAAA==.',['妖妖']='妖妖灵灬:BAAAKgADCgcIBwAAAA==.',['宋泽']='宋泽:BAAAKgADCgEIAQAAAA==.',['容我']='容我三思:BAABKgAFFH8GAAICAAYI+CDqEwC8AQACAAYI+CDqEwC8AQAAAA==.',['对越']='对越之鬼:BAAAKgAFFAEIAQAAAA==.',['小帕']='小帕米拉:BAABKgAFFH8HAAICAAMI7hlpTADWAAACAAMI7hlpTADWAAAAAA==.',['小样']='小样丨你别秀:BAABKgAECn8VAAISAAgI8xNvHwCjAQASAAgI8xNvHwCjAQAAAA==.小样丨你来秀:BAABKgAECn8ZAAMRAAgIfRHJSAAtAQARAAcI2xDJSAAtAQATAAQIKwy/mwCPAAAAAA==.小样丨秀一秀:BAAAKgAFFAMIAwAAAA==.小样丨跟着:BAAAKgAFFAIIAgAAAA==.',['小肆']='小肆肆:BAAAKgADCgIIAgAAAA==.',['小腊']='小腊肉:BAAAKgADCggICAAAAA==.',['巴山']='巴山夜雨:BAAAKgAECggICwAAAA==.',['帅气']='帅气的哆哆:BAABKgAFFH8GAAIRAAYIHR6UCgCtAQARAAYIHR6UCgCtAQAAAA==.',['幽影']='幽影:BAAAKgADCgQIBAAAAA==.',['开心']='开心去:BAAAKgAECgUIBQAAAA==.',['彼岸']='彼岸天空:BAAAKgAECggIEAAAAA==.',['恰柠']='恰柠檬:BAAAKgADCgEIAQAAAA==.',['情怀']='情怀萨丶:BAAAKgAECgUIBQAAAA==.',['惑星']='惑星小闪电:BAAAKgAECgYIDAAAAA==.',['戊雙']='戊雙乄无双:BAAAKgADCgUIBQAAAA==.',['我大']='我大雄:BAAAKgAECgUIBQAAAA==.',['托星']='托星小恐龙:BAAAKgAECgEIAQAAAA==.',['提里']='提里奥枣花:BAAAKgAECgUIBQAAAA==.',['放弃']='放弃丶速度灭:BAAAKgAECgIIAwAAAA==.',['无处']='无处安放:BAAAKgADCgQIBAAAAA==.',['无米']='无米丶硬吹:BAABKgAFFH8LAAIGAAYIHBNBDgBDAQAGAAYIHBNBDgBDAQAAAA==.',['晓布']='晓布丶:BAAAKgADCgEIAQAAAA==.',['术爷']='术爷灬有专攻:BAAAKgADCgEIAQAAAA==.',['李师']='李师傅:BAAAKgADCgEIAgAAAA==.',['柠檬']='柠檬甜橙:BAAAKgAECgQIBAAAAA==.',['梦迪']='梦迪卡:BAAAKgAFFAYIAgABKgAFFAgIEwAUAP0gAA==.',['樱噬']='樱噬妖空:BAAAKgAECgYIBgAAAA==.',['橘子']='橘子的橘:BAAAKgADCgEIAQAAAA==.',['欧皇']='欧皇:BAAAKgADCgIIAgAAAA==.',['汉考']='汉考克:BAAAKgAECggICAAAAA==.',['满月']='满月:BAAAKgAECgUIBQAAAA==.',['灰原']='灰原哀:BAAAKgAECgUIBQAAAA==.',['灵魂']='灵魂工程师:BAAAKgAFFAQIBAAAAA==.',['烟酒']='烟酒砖家:BAAAKgADCgcIBwAAAA==.',['爆炸']='爆炸小裤衩:BAAAKgAECggIBwAAAA==.',['牛希']='牛希希:BAAAKgAECgEIAQAAAA==.',['犬夜']='犬夜叉:BAAAKgAFFAIIAgAAAA==.',['猛牛']='猛牛酸酸乳:BAAAKgAECgIIAgAAAA==.',['甘允']='甘允桐:BAAAKgAECggICgAAAA==.',['田二']='田二妞:BAAAKgAECgIIAgAAAA==.',['电萨']='电萨马宝果:BAAAKgAECgYICgAAAA==.',['番茄']='番茄爸爸:BAAAKgADCgEIAgAAAA==.',['病毒']='病毒:BAAAKgADCgEIAQAAAA==.',['知喃']='知喃:BAAAKgADCggICAAAAA==.',['秋意']='秋意如婵:BAABKgAFFH8FAAIFAAQIqB8rAwAYAQAFAAQIqB8rAwAYAQAAAA==.',['秋水']='秋水共长天:BAAAKgAECgYIBgAAAA==.',['等会']='等会儿:BAAAKgAECgQIBAAAAA==.',['缨噬']='缨噬樱噬:BAAAKgAECgUIBgAAAA==.',['胖虎']='胖虎的妹妹:BAAAKgAECgEIAQAAAA==.',['芒果']='芒果沐橙:BAABKgAFFH8IAAIIAAgI4hXLAgBGAgAIAAgI4hXLAgBGAgAAAA==.',['萌牛']='萌牛奶:BAAAKgAECgMIBAAAAA==.',['萌獣']='萌獣獸:BAABKgAFFH8NAAIVAAQI8BTkEwDIAAAVAAQI8BTkEwDIAAAAAA==.',['萌醒']='萌醒不如初:BAAAKgADCgEIAQAAAA==.',['萨洛']='萨洛天下:BAAAKgADCgQIBAAAAA==.',['落水']='落水:BAAAKgADCggICAAAAA==.',['蒙哥']='蒙哥马利:BAAAKgAECgEIAQAAAA==.',['藿香']='藿香正气:BAAAKgADCgEIAQAAAA==.',['訷凨']='訷凨:BAAAKgAECgEIAQAAAA==.',['诗意']='诗意的风:BAAAKgAFFAQIBAAAAA==.',['豆瓣']='豆瓣魚:BAAAKgAFFAMIAwAAAA==.',['走起']='走起撒:BAAAKgAECgIIBQAAAA==.',['转圈']='转圈圈:BAAAKgAECgEIAQAAAA==.',['迷星']='迷星小月亮:BAAAKgAECgIIAgAAAA==.',['重生']='重生的战神:BAAAKgAECgYIBgAAAA==.',['錒鑫']='錒鑫丶:BAAAKgADCgMIAwAAAA==.',['铁柱']='铁柱八号:BAAAKgAECgQIBQAAAA==.铁柱哥:BAAAKgADCgQIBAAAAA==.',['铭记']='铭记氵冬戀:BAAAKgADCggICAAAAA==.',['雷电']='雷电将军:BAAAKgAECgQIBAAAAA==.',['青山']='青山忆:BAABKgAFFH8FAAMWAAMIuBWzIQDfAAAWAAMIuBWzIQDfAAAXAAIIJQBeQwAZAAAAAA==.',['面包']='面包有毒:BAAAKgAECgEIAQAAAA==.',['韭菜']='韭菜丶:BAAAKgADCggIEAAAAA==.',['饿龙']='饿龙咆哮:BAAAKgADCggICAAAAA==.',['骑马']='骑马多多:BAAAKgAECgEIAQAAAA==.',['骑驴']='骑驴追圣光:BAAAKgAECgcIDQAAAA==.',['黑心']='黑心德:BAAAKgAECgIIAgAAAA==.',['黯然']='黯然:BAAAKgADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end