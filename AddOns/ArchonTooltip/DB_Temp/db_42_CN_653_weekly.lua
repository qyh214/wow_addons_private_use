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
 local lookup = {'Monk-Mistweaver','Priest-Holy','Priest-Discipline','Priest-Shadow','DemonHunter-Vengeance','DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','DeathKnight-Unholy','Hunter-Marksmanship','Shaman-Enhancement','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Unknown-Unknown','Paladin-Protection','Paladin-Holy','Druid-Feral',}; local provider = {region='CN',realm='安格博达',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alvin:BAABKgAFFH8FAAIBAAUIAggYGwDEAAABAAUIAggYGwDEAAAAAA==.',Am='Ammn:BAAAKgAECgYICQAAAA==.',Dy='Dyrachyo:BAAAKgAECgYIBgAAAA==.',In='Inzi:BAAAKgAECgQIBAAAAA==.',So='Solarpower:BAAAKgADCgEIAQAAAA==.',['一对']='一对三:BAAAKgADCgQIBAAAAA==.',['七星']='七星哥哥:BAABKgAFFH8QAAQCAAYIcRdqDgBDAQACAAYIthJqDgBDAQADAAQIaRr8EgABAQAEAAII/R5ZGAC5AAAAAA==.',['三月']='三月紫:BAAAKgAECggIEAAAAA==.',['东皇']='东皇丶太一:BAAAKgAECggIDwAAAA==.东皇丶新一:BAAAKgAFFAIIAgAAAA==.',['丨灵']='丨灵愈者丨:BAABKgAFFH8LAAQDAAgI1BT1AgD+AQADAAgI1BT1AgD+AQACAAIIww2wNwBhAAAEAAEIZhGGLQA/AAAAAA==.',['乌鸦']='乌鸦坐飞机丶:BAABKgAECn8fAAMFAAgIaxMQJABYAQAFAAgIqRIQJABYAQAGAAQIJw6wOwCPAAAAAA==.',['乔伊']='乔伊波伊:BAAAKgAECgQIBAAAAA==.',['乳鸽']='乳鸽王卢鑫:BAAAKgAECggICAAAAA==.',['云云']='云云:BAAAKgAFFAQIBAAAAA==.',['亡情']='亡情骷髅:BAAAKgADCgEIAQAAAA==.',['仁至']='仁至翼尽:BAAAKgAECgMIBAAAAA==.',['伏地']='伏地老色皮:BAABKgAFFH8HAAMHAAYIDxdyGQA5AQAHAAQILBZyGQA5AQAIAAMIyR4NFACkAAAAAA==.',['伤顽']='伤顽童:BAAAKgADCgcIBwAAAA==.',['倉立']='倉立刀:BAAAKgAECgIIAgAAAA==.',['傻满']='傻满:BAABKgAFFH8FAAMJAAQIXBL4CAA9AQAJAAQIXBL4CAA9AQAKAAEIoA+jLgBWAAAAAA==.',['光之']='光之印记:BAABKgAECn8cAAMIAAgI3hflKQBTAQAIAAYIQxjlKQBTAQAHAAQIthQnYgDnAAAAAA==.',['光辉']='光辉之翼:BAAAKgAECgcICAAAAA==.',['克里']='克里斯提娜:BAAAKgAECgcICAAAAA==.',['六神']='六神花露水丶:BAAAKgAECggICAAAAA==.',['兰州']='兰州吴彦祖丶:BAABKgAFFH8GAAILAAYI4SFzEQDSAQALAAYI4SFzEQDSAQABKgAFFAgIDgAMALIcAA==.',['兰特']='兰特瑞索火刃:BAAAKgAECgYIBgAAAA==.',['北极']='北极星灬:BAAAKgAECggIDQAAAA==.',['千杯']='千杯不倒丶:BAAAKgADCggICAAAAA==.',['千里']='千里奔袭:BAAAKgADCgIIAgAAAA==.',['叮咚']='叮咚咚:BAAAKgAFFAgIBAAAAA==.',['可怕']='可怕的咕咕:BAAAKgAFFAQIBAABKgAFFAgIBgACAOkXAA==.可怕的猎手:BAAAKgADCggIDwAAAA==.',['司空']='司空震:BAAAKgAECgEIAQAAAA==.',['哎呀']='哎呀灬嘛德:BAAAKgADCggIAgAAAA==.',['哲月']='哲月:BAABKgAECn8cAAINAAgIQSOoCQCXAgANAAgIQSOoCQCXAgAAAA==.',['埃尔']='埃尔拉希奥:BAACKgAFFH8FAAIGAAII+RPhJgCXAAAGAAII+RPhJgCXAAAqAAQKfyAAAgYACAifIR0MAKgCAAYACAifIR0MAKgCAAAA.',['墓师']='墓师:BAAAKgADCggIAQAAAA==.',['夜灬']='夜灬神罚:BAAAKgADCgQIBAAAAA==.',['夜雀']='夜雀:BAABKgAFFH8KAAQJAAYIThf9BQAEAQAJAAQIGB39BQAEAQAKAAUIkwLPHACrAAAOAAEI2xyEHABOAAAAAA==.',['大地']='大地之灵:BAAAKgAECgUIBwAAAA==.',['大青']='大青衣:BAAAKgAFFAMIAwAAAA==.',['大黄']='大黄蜂电台:BAABKgAFFH8KAAMPAAYIDw4pGwBBAQAPAAYIDw4pGwBBAQAQAAQIfRHPIACnAAAAAA==.',['天帝']='天帝猎神:BAAAKgAECgcIBwAAAA==.',['天月']='天月时:BAAAKgADCgYIBgAAAA==.',['奔跑']='奔跑的鱼:BAAAKgAECgcIBAAAAA==.',['奥德']='奥德西斯:BAABKgAECn8hAAIMAAgI2h+QHwAYAgAMAAgI2h+QHwAYAgAAAA==.',['奶奶']='奶奶儿丷:BAAAKgAECgUIBQAAAA==.',['她耳']='她耳朵不好:BAAAKgADCggIGAAAAA==.',['好好']='好好躺下休息:BAAAKgAECgcIAgAAAA==.',['娜娜']='娜娜安:BAAAKgAFFAQIBAAAAA==.',['守望']='守望寂寞:BAAAKgAECgQIBAAAAA==.',['小虎']='小虎牙真好看:BAAAKgAECggIEwAAAA==.',['小趴']='小趴菜:BAAAKgADCgMIAwAAAA==.',['尒噺']='尒噺:BAAAKgAECgEIAgAAAA==.',['尼姑']='尼姑:BAAAKgAECgYIBgAAAA==.尼姑贰:BAAAKgAECgQIBAAAAA==.',['布洛']='布洛芬:BAAAKgAECggICAAAAA==.',['幼稚']='幼稚园小霸王:BAACKgAFFH8GAAIBAAIImQ1oIgB+AAABAAIImQ1oIgB+AAAqAAQKfx8AAgEACAi0HGAVAD0CAAEACAi0HGAVAD0CAAAA.',['德布']='德布劳内:BAAAKgAFFAIIAgAAAA==.',['心眼']='心眼:BAAAKgAECgUIBQAAAA==.',['恋上']='恋上你的唇:BAAAKgAECgMIAwAAAA==.',['想生']='想生活过的去:BAAAKgAFFAMIAwAAAA==.',['慢慢']='慢慢:BAAAKgAECgMIBAAAAA==.',['憨憨']='憨憨得:BAAAKgADCggICAAAAA==.',['抚不']='抚不去的伤痛:BAAAKgAFFAYIBAAAAA==.',['拉鲁']='拉鲁拉丝:BAAAKgAECggICgAAAA==.',['故梦']='故梦换新装:BAAAKgADCggICAAAAA==.',['时尚']='时尚大硬毛:BAAAKgADCgEIAQAAAA==.',['時光']='時光如夢:BAAAKgAECgEIAQAAAA==.',['月光']='月光照大地:BAAAKgADCgYIBgAAAA==.',['月是']='月是故乡眀:BAAAKgADCgMIAwAAAA==.',['杀鱼']='杀鱼不是鱼:BAABKgAFFH8GAAIRAAQIjhW5FwDxAAARAAQIjhW5FwDxAAABKgAFFAgIAgASAAAAAA==.',['李思']='李思源:BAAAKgAECgEIAQAAAA==.',['李欢']='李欢喜:BAAAKgAECgMIAwAAAA==.',['林薇']='林薇薇:BAAAKgAECgcIBwAAAA==.',['树拾']='树拾忆:BAAAKgAECggICAAAAA==.',['梅川']='梅川库籽:BAABKgAECn8jAAILAAgInB/EIAB/AgALAAgInB/EIAB/AgAAAA==.',['植物']='植物大战僵尸:BAABKgAFFH8HAAIPAAcI2h6sBgBHAgAPAAcI2h6sBgBHAgAAAA==.',['楪祁']='楪祁:BAAAKgAECgYIBgAAAA==.',['橘子']='橘子味的柚子:BAAAKgADCggICAAAAA==.',['武丨']='武丨僧:BAAAKgADCgYIBgAAAA==.',['汽车']='汽车人撤退:BAAAKgAFFAYIBAAAAA==.',['泳儿']='泳儿:BAABKgAECn8eAAIDAAgI7QvmOgADAQADAAgI7QvmOgADAQAAAA==.',['活的']='活的很好:BAABKgAECn8kAAMPAAgIxyH6BAC1AgAPAAgIxyH6BAC1AgAQAAQIfhVWHwC8AAAAAA==.',['浪味']='浪味仙:BAAAKgAECgEIAQAAAA==.',['燚须']='燚须:BAAAKgAECggICAAAAA==.',['牛仔']='牛仔很忙丨:BAAAKgAECgYICQAAAA==.',['玩具']='玩具车头:BAAAKgADCgMIAwAAAA==.',['田烛']='田烛:BAAAKgAECgMIAwAAAA==.',['男足']='男足:BAAAKgAFFAQIAQAAAA==.',['碧落']='碧落黄泉:BAAAKgADCggICAAAAA==.',['神光']='神光闪耀:BAAAKgAECgUIBQAAAA==.',['秋月']='秋月风缪:BAABKgAFFH8IAAIRAAQIXhUUFwDXAAARAAQIXhUUFwDXAAABKgAFFAgICAARABcdAA==.',['红蜘']='红蜘蛛加速:BAABKgAFFH8GAAMCAAYIihPmDQDsAAACAAUInRLmDQDsAAAEAAEIBRANGQBMAAAAAA==.',['纯的']='纯的墨水:BAAAKgADCgEIAQAAAA==.',['脑细']='脑细胞阵亡:BAAAKgAECgUIBQAAAA==.',['节奏']='节奏:BAACKgAFFH8pAAMLAAgITBkhCAAvAgALAAgITBkhCAAvAgATAAQIHBOPHACVAAAqAAQKfywAAwsACAhuIz8fAJwCAAsACAhuIz8fAJwCABMACAirGM0WAK0BAAAA.',['芙莉']='芙莉莲:BAAAKgADCggICAAAAA==.',['范德']='范德尔:BAABKgAECn8dAAILAAgI3R6vQAAAAgALAAgI3R6vQAAAAgAAAA==.',['蓝丨']='蓝丨落:BAAAKgAFFAgIBAAAAA==.',['蓝夜']='蓝夜雨:BAAAKgAECggICwAAAA==.',['蓝筹']='蓝筹:BAABKgAFFH8HAAMRAAQIMSIWDQAcAQARAAQIMSIWDQAcAQANAAMI7BEeRABtAAAAAA==.',['薇笑']='薇笑余香:BAAAKgADCggIEAAAAA==.',['虎皮']='虎皮丶青椒:BAABKgAECn8bAAIJAAgIaBHXLQCTAQAJAAgIaBHXLQCTAQAAAA==.',['蛋碎']='蛋碎:BAAAKgADCggICgAAAA==.',['诺贝']='诺贝尔:BAABKgAFFH8GAAIKAAMIbgaOIACBAAAKAAMIbgaOIACBAAAAAA==.',['谜谜']='谜谜米:BAAAKgAECgcICQAAAA==.',['跑者']='跑者蓝调:BAABKgAFFH8MAAIUAAQIwh3TBAD9AAAUAAQIwh3TBAD9AAAAAA==.',['辣是']='辣是痛觉:BAAAKgAECgMIAwAAAA==.',['部落']='部落大酋长:BAAAKgADCggICAAAAA==.',['酸萝']='酸萝卜别吃:BAAAKgAECgYICQAAAA==.',['野德']='野德芯之助:BAAAKgAFFAgIBAAAAA==.',['银月']='银月无裳:BAABKgAFFH8KAAIVAAMISQQOBwCPAAAVAAMISQQOBwCPAAAAAA==.',['长夜']='长夜丶漫漫:BAAAKgADCggICAAAAA==.',['阿赖']='阿赖耶识:BAAAKgADCgQIBgAAAA==.',['阿释']='阿释密达:BAAAKgAFFAMIAwAAAA==.',['陆月']='陆月丿龙:BAAAKgAECgYICgAAAA==.',['雷军']='雷军:BAABKgAFFH8GAAILAAYIMSSgGQCSAQALAAYIMSSgGQCSAQAAAA==.',['霸叭']='霸叭丷:BAAAKgAECggICAAAAA==.',['青山']='青山寒枫:BAACKgAFFH8UAAIMAAYIhCBzDgCwAQAMAAYIhCBzDgCwAQAqAAQKfxYAAgwACAhDHqcUAGYCAAwACAhDHqcUAGYCAAAA.',['馨欣']='馨欣乡溪:BAAAKgAECgYIBgAAAA==.',['魔法']='魔法披风:BAAAKgAECgEIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end