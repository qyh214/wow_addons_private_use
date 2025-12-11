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
 local lookup = {'DeathKnight-Frost','Mage-Frost','Mage-Arcane','Priest-Holy','Mage-Fire','Warlock-Demonology','DeathKnight-Blood','Shaman-Restoration','Warrior-Fury','DemonHunter-Vengeance','Hunter-Survival','Hunter-Marksmanship','Evoker-Devastation','Hunter-BeastMastery','Druid-Restoration','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','Monk-Brewmaster','Warrior-Protection','Monk-Windwalker','Warlock-Destruction','Druid-Balance','Priest-Shadow',}; local provider = {region='CN',realm='达基萨斯',name='CN',type='weekly',zone=44,date='2025-12-08',data={Ap='Apitsme:BAAALAAECgUIBgAAAA==.',Ay='Aylwynl:BAAALAADCgYIBgAAAA==.',Bl='Blueman:BAAALAAECgYIBgAAAA==.',Ca='Cae:BAAALAADCgMIAwAAAA==.',Co='Coolmal:BAAALAAFFAIIBAABLAAFFAUICgABAD4YAA==.',De='Dearseohyun:BAAALAADCgYIBgAAAA==.',Dr='Dreamkiss:BAAALAAECgQICAAAAA==.',Ev='Evaivy:BAAALAAECgYIEAAAAA==.',Iv='Ivan:BAAALAAECgYIBgAAAA==.',Jo='Jony:BAAALAAECgQIBAAAAA==.',La='Laofan:BAAALAAFFAIIAgAAAA==.',Lo='Lonelygeorge:BAAALAAECgcICQAAAA==.',Lp='Lpanyy:BAAALAAECggICAAAAA==.',Ne='Neverwas:BAAALAAECgYIBgAAAA==.',Po='Poison:BAAALAAFFAIIAgAAAA==.',Pr='Prometheus:BAABLAAECn8XAAMCAAcIvxkkJQD6AQACAAcIvxkkJQD6AQADAAIIPASz9wBOAAABLAAFFAMIBQABAMgFAA==.',Sa='Saberl:BAABLAAFFH8GAAIEAAIIggwPNwCFAAAEAAIIggwPNwCFAAAAAA==.',Sw='Swsh:BAAALAADCgYIBgAAAA==.',Th='Thegreateg:BAABLAAFFH8IAAIBAAIIeQlSfgCIAAABAAIIeQlSfgCIAAAAAA==.',Tu='Turn:BAAALAAECgIIAgAAAA==.',Zo='Zoltraak:BAACLAAFFH82AAMDAAcIYyL+DAAAAgADAAYIMyP+DAAAAgAFAAIIQR9WBACqAAAsAAQKfyIAAwUACAj9IhQEAHoCAAMACAiDIiwxAIUCAAUABwhwIRQEAHoCAAAA.',['一切']='一切看心情:BAABLAAECn8UAAIGAAYI2xTHFAA4AQAGAAYI2xTHFAA4AQAAAA==.',['一周']='一周七日:BAAALAAFFAEIAQAAAA==.',['一起']='一起嬉戏玩耍:BAAALAAFFAEIAQAAAA==.',['下载']='下载人生:BAAALAAECgYIBgAAAA==.',['不学']='不学无术:BAAALAADCgEIAQAAAA==.',['不帅']='不帅用砖头拍:BAAALAAECgYIDgAAAA==.',['东山']='东山再骑:BAAALAADCggICAAAAA==.',['丷缱']='丷缱绻丷:BAACLAAFFH8nAAIBAAcIkRbiFgDiAQABAAcIkRbiFgDiAQAsAAQKf0IAAwEACAjKIBkXADECAAEACAjKIBkXADECAAcAAQhvAYZVABAAAAAA.',['久久']='久久回味:BAAALAAFFAIIAgAAAA==.',['书瑶']='书瑶要开心:BAAALAADCgYIBgAAAA==.',['以杀']='以杀止戈熊:BAAALAAECgYIBgAAAA==.',['优雅']='优雅的尾巴:BAAALAADCgEIAQAAAA==.',['会丶']='会丶长:BAAALAAECgMIBQAAAA==.',['你别']='你别皱眉:BAAALAAFFAIIAgAAAA==.',['保安']='保安:BAAALAAFFAIIAgAAAA==.',['修心']='修心:BAAALAAECgQIBAAAAA==.',['俺德']='俺德斯坦德:BAAALAADCgYICAAAAA==.',['光头']='光头:BAABLAAFFH8GAAIIAAIIDAzdYwBYAAAIAAIIDAzdYwBYAAABLAAFFAIICAAJAI0ZAA==.',['光理']='光理子:BAAALAAECgMIAwAAAA==.',['克鲁']='克鲁苏:BAAALAAECgUIBQAAAA==.',['养乐']='养乐多哆:BAAALAADCgYIBgAAAA==.',['冻果']='冻果冻:BAAALAADCgYIBgAAAA==.',['出门']='出门不带刀:BAAALAAECgMIBgAAAA==.',['北之']='北之风:BAAALAAECgIIAgAAAA==.',['十步']='十步杀亿人:BAAALAAECgIIAgAAAA==.',['千年']='千年小白狐:BAAALAAECgQIBAAAAA==.',['单手']='单手插兜:BAAALAADCgQIBAAAAA==.',['卡特']='卡特琳娜丶:BAAALAAECgMIAwAAAA==.',['发财']='发财:BAABLAAFFH8SAAIIAAUI1hDfLgD4AAAIAAUI1hDfLgD4AAAAAA==.',['古之']='古之恶来:BAABLAAFFH8KAAIKAAIIOQzbFgAoAAAKAAIIOQzbFgAoAAAAAA==.',['可乐']='可乐大叔:BAAALAAECgYIEQAAAA==.',['右键']='右键:BAAALAAECgYIBgAAAA==.',['后来']='后来的夏天:BAAALAAECgcIAQABLAAFFAgICwADAJQfAA==.',['咆哮']='咆哮:BAAALAAECgYIBwAAAA==.',['哈比']='哈比:BAABLAAFFH8HAAMLAAIIUxuNAwCmAAALAAIIUxuNAwCmAAAMAAEIuxEFFwA8AAAAAA==.',['哞哥']='哞哥:BAAALAADCgIIAgAAAA==.',['哥布']='哥布林酋长:BAAALAAECgMIAwAAAA==.',['回不']='回不去的曾经:BAAALAADCgcIBwAAAA==.',['圣剑']='圣剑修罗:BAAALAAECgQIBAAAAA==.',['圣拉']='圣拉戈奇:BAAALAAECgEIAQAAAA==.',['地板']='地板战神:BAAALAAECgYIBwAAAA==.',['埃辛']='埃辛诺之谜:BAAALAAECgQIBAAAAA==.',['天上']='天上一头牛:BAABLAAECn8gAAIIAAcIYBEWgQB+AQAIAAcIYBEWgQB+AQAAAA==.',['奔放']='奔放:BAAALAAFFAIIAgAAAA==.',['奶牛']='奶牛不是牛:BAAALAAECggIAgAAAA==.',['妮可']='妮可罗宾:BAAALAAECgYIBgAAAA==.',['姑蘇']='姑蘇圣:BAAALAAFFAIIAgAAAA==.',['娅特']='娅特拉绯雪:BAAALAAECgIIAgAAAA==.',['宇智']='宇智波牢大:BAAALAAECgEIAQAAAA==.',['宋玉']='宋玉:BAAALAADCgEIAQAAAA==.',['对的']='对的感绝:BAAALAAECgYIDwAAAA==.',['小丶']='小丶葡萄:BAAALAAECggIEQAAAA==.',['小宝']='小宝雨萌:BAAALAAECgcIBwAAAA==.',['小布']='小布丁儿:BAAALAAFFAIIBAAAAA==.',['小红']='小红手:BAABLAAFFH8IAAIJAAIIjRkJRABQAAAJAAIIjRkJRABQAAAAAA==.',['小萨']='小萨:BAAALAAFFAIIBAAAAA==.小萨酋长:BAAALAADCgYIBwAAAA==.',['小马']='小马宝莉:BAAALAAECggICAAAAA==.',['小魚']='小魚冻干:BAAALAAECgYIDwAAAA==.',['小龙']='小龙人佰木:BAACLAAFFH8GAAINAAMIAwzpEgC/AAANAAMIAwzpEgC/AAAsAAQKfxYAAg0ACAizG9wgABICAA0ACAizG9wgABICAAAA.',['少拉']='少拉点我怕:BAAALAADCgYIBgAAAA==.',['岁月']='岁月:BAAALAADCggICAAAAA==.',['峰岭']='峰岭一桃木盾:BAAALAADCgIIAgAAAA==.',['川锅']='川锅油菜花:BAAALAAECgMIAwAAAA==.',['左手']='左手拔刀:BAABLAAECn8eAAMOAAYIWR1+WQCRAQAOAAYIWR1+WQCRAQALAAEI5wtXJQA8AAAAAA==.',['布德']='布德鳥:BAABLAAFFH8IAAIPAAIITyDkGQC6AAAPAAIITyDkGQC6AAAAAA==.',['幸运']='幸运星丶:BAAALAADCgEIAQAAAA==.',['幻小']='幻小信:BAAALAADCgYIBgAAAA==.幻小龙:BAAALAAECgQIBAAAAA==.',['幼儿']='幼儿园杠把子:BAAALAAFFAIIBAAAAA==.',['幽梦']='幽梦魅姬:BAAALAAECgIIAgAAAA==.',['床底']='床底下的老王:BAAALAAFFAYIAgAAAA==.',['异想']='异想:BAAALAADCgIIAgAAAA==.异想的铁牛:BAAALAAECgIIAgAAAA==.',['很酷']='很酷又爱笑:BAABLAAFFH8GAAIQAAIIsB3iLwCsAAAQAAIIsB3iLwCsAAAAAA==.',['御弟']='御弟哥哥:BAAALAAECgYIEgAAAA==.',['心生']='心生六乂:BAABLAAFFH8LAAMQAAQIrRCBNQDbAAAQAAQIrRCBNQDbAAARAAIIIAUnIgAnAAAAAA==.心生六爻:BAABLAAFFH8NAAIOAAQIrA7xaQCSAAAOAAQIrA7xaQCSAAAAAA==.',['性感']='性感的大橙子:BAABLAAFFH8NAAIPAAQIGBFwJgDoAAAPAAQIGBFwJgDoAAAAAA==.',['怼子']='怼子:BAAALAADCgQIBAAAAA==.',['怼怼']='怼怼:BAABLAAFFH8IAAIQAAUIrRsmIQBkAQAQAAUIrRsmIQBkAQAAAA==.怼怼丶:BAAALAAECgMIAwAAAA==.怼怼丶丶:BAAALAAECgYIEQAAAA==.',['成就']='成就你的梦想:BAABLAAFFH8LAAISAAYIohLxHgCIAQASAAYIohLxHgCIAQAAAA==.',['我世']='我世界你不懂:BAAALAADCgEIAQAAAA==.',['我是']='我是贼我骄傲:BAAALAAFFAQIAgAAAA==.',['打小']='打小穿背背佳:BAAALAAECgYIDAABLAAECggIKwATAF4XAA==.',['拉风']='拉风归来骑士:BAAALAAFFAIIAgAAAA==.拉风骑士归来:BAAALAAECgMIAwAAAA==.',['拿破']='拿破剑:BAACLAAFFH8uAAIJAAYI3x1yDgDmAQAJAAYI3x1yDgDmAQAsAAQKfy0AAgkABwjBIikkALQCAAkABwjBIikkALQCAAAA.',['摆烂']='摆烂小羊丶:BAAALAAECgYIDAAAAA==.',['放啥']='放啥假:BAAALAAFFAEIAQAAAA==.',['放在']='放在左手心:BAAALAAECgQIBAAAAA==.',['故乡']='故乡星尘:BAAALAADCgYIBgAAAA==.',['敞亮']='敞亮的套子:BAABLAAFFH8IAAIGAAIIWB+eDQBWAAAGAAIIWB+eDQBWAAABLAAFFAIICAAJAI0ZAA==.',['新年']='新年快乐菇:BAAALAAFFAIIAgAAAA==.',['无法']='无法无天:BAAALAADCggICAAAAA==.',['星空']='星空暗闪耀:BAAALAADCgMIAwAAAA==.',['是尴']='是尴尬的:BAAALAAECgYIDwAAAA==.',['是怼']='是怼怼呀丶:BAAALAAECgUIBQAAAA==.',['暗战']='暗战:BAAALAAECgMIAwAAAA==.',['曾途']='曾途苏畅:BAAALAAECgEIAQAAAA==.',['最爱']='最爱老白干:BAAALAAECgYIDQAAAA==.',['有机']='有机酸奶:BAAALAAFFAIIAgAAAA==.',['杀入']='杀入世鸡蛋糕:BAAALAAECgYIBwAAAA==.',['杨咩']='杨咩咩丶:BAAALAAECgIIAwAAAA==.',['根本']='根本气宇轩昂:BAAALAAECgcIDgAAAA==.',['格兰']='格兰芬多:BAABLAAFFH8FAAIBAAIICAy6igBBAAABAAIICAy6igBBAAAAAA==.',['森罗']='森罗小象:BAAALAAECgYICQAAAA==.',['正中']='正中爸心:BAAALAADCgEIAQAAAA==.',['汉尼']='汉尼拔:BAAALAADCgYIBgAAAA==.',['污瑟']='污瑟尔:BAABLAAFFH8KAAIJAAIIDhf5OwCSAAAJAAIIDhf5OwCSAAAAAA==.',['沐弦']='沐弦:BAAALAAFFAIIAgAAAA==.',['法丝']='法丝:BAAALAAECgUIBQAAAA==.',['法海']='法海十月怀胎:BAAALAADCgQIBAAAAA==.',['洛啊']='洛啊神灵圣光:BAAALAADCgYIBgAAAA==.',['洛篱']='洛篱落锁:BAAALAAECgYIBgAAAA==.',['浅浅']='浅浅的浅浅:BAAALAAECgEIAQAAAA==.',['浩克']='浩克:BAAALAAECgQIBAAAAA==.',['深海']='深海的蔚蓝:BAAALAAFFAIIAgAAAA==.',['淺丶']='淺丶淺:BAAALAAECgEIAQAAAA==.',['清夜']='清夜:BAAALAAECgYIBgAAAA==.',['漂泊']='漂泊大合肥:BAAALAADCgcIBwAAAA==.',['火车']='火车头:BAAALAADCgQIBAAAAA==.',['火锅']='火锅搭奶茶丶:BAAALAADCgUIBQAAAA==.',['灬純']='灬純爺們灬:BAAALAADCgcIBwAAAA==.',['灬钕']='灬钕皇灬:BAAALAAFFAIIAwAAAA==.',['炸鸡']='炸鸡送啤酒:BAAALAAECgQIBAAAAA==.',['烟圈']='烟圈:BAAALAADCgcIBwAAAA==.',['牛二']='牛二:BAABLAAFFH8SAAIPAAUIXxskFACaAQAPAAUIXxskFACaAQAAAA==.',['牛奶']='牛奶猪猪:BAAALAAECgYIBwAAAA==.',['独径']='独径行云:BAAALAAECgYIDAAAAA==.',['独经']='独经新云:BAAALAAECgcICwAAAA==.',['玩过']='玩过小龙女:BAAALAAECgQIBgAAAA==.',['琴月']='琴月阴:BAABLAAFFH8KAAIUAAIIHgzKJgBwAAAUAAIIHgzKJgBwAAAAAA==.',['瑟夫']='瑟夫的权杖:BAAALAADCgcIBwAAAA==.',['白月']='白月光:BAAALAAECgYIDAAAAA==.',['瞎子']='瞎子:BAAALAAECgIIAgAAAA==.',['石川']='石川澪:BAABLAAFFH8FAAIPAAIIfRdHOQCIAAAPAAIIfRdHOQCIAAAAAA==.',['砮皂']='砮皂退休外包:BAABLAAECn8rAAMTAAgIXhc3FAAfAgATAAgIIRc3FAAfAgAVAAYImhTAMgB/AQAAAA==.',['神之']='神之右手:BAAALAAECgMIAwAAAA==.',['祭一']='祭一一四一三:BAAALAAECgYIBgAAAA==.',['稳德']='稳德一匹:BAAALAAECgIIAgAAAA==.',['筱德']='筱德:BAAALAAECgUIBwAAAA==.',['箭有']='箭有所指:BAAALAAECgMIAwAAAA==.',['精神']='精神点别丢份:BAAALAADCgMIAwAAAA==.',['红葉']='红葉晚萧萧:BAAALAAECgEIAQAAAA==.',['红颜']='红颜祸水:BAAALAAECgUIBQAAAA==.',['纪幕']='纪幕:BAAALAAECgYIEgAAAA==.',['纯爱']='纯爱:BAAALAAECgcIEAAAAA==.',['绣虎']='绣虎:BAAALAADCgMIAwAAAA==.',['绵绵']='绵绵冰小羊:BAAALAAECgYIBgAAAA==.',['绿裳']='绿裳红箭尾:BAAALAAECgYICgAAAA==.',['羊藿']='羊藿:BAAALAAFFAEIAQAAAA==.',['老品']='老品种婆娘丶:BAABLAAFFH8oAAISAAYIdyS0BgAxAgASAAYIdyS0BgAxAgAAAA==.',['老头']='老头子:BAAALAAECgMIAwAAAA==.',['老子']='老子就是神化:BAAALAAECgQIBAAAAA==.',['老徳']='老徳:BAAALAAECgYIBgAAAA==.',['肆壹']='肆壹:BAAALAAECgUIBQAAAA==.',['肉夹']='肉夹子:BAAALAAECgIIAgAAAA==.',['肉身']='肉身加持:BAAALAAECgYIBwAAAA==.',['肉麦']='肉麦饼:BAAALAAECgYICgAAAA==.',['腐朽']='腐朽者:BAAALAAFFAIIAgAAAA==.',['自由']='自由心乁杰:BAAALAAECgMIAwAAAA==.',['艾拉']='艾拉瑞丽:BAACLAAFFH8fAAIKAAUIsho5BQDxAAAKAAUIsho5BQDxAAAsAAQKfx0AAwoABgjuHnYaAOwBAAoABgg6HXYaAOwBABIABgiHF4+kAIQBAAAA.',['花火']='花火灬灬:BAAALAAFFAIIAgAAAA==.',['英雄']='英雄:BAABLAAECn8iAAISAAgIhiE2GQADAwASAAgIhiE2GQADAwAAAA==.',['范范']='范范:BAAALAAFFAIIBAAAAA==.',['莫奈']='莫奈安:BAAALAAFFAIIAgAAAA==.',['菅野']='菅野洋子:BAABLAAFFH8LAAMHAAUIpww2EQDbAAAHAAUIWAk2EQDbAAABAAIIYRQuWgCbAAABLAAFFAUIHwAKALIaAA==.',['落叶']='落叶是欧皇:BAAALAAECgYIEAAAAA==.',['血冰']='血冰凌:BAAALAAFFAIIBAAAAA==.',['行雷']='行雷闪电:BAAALAAECgQIBAAAAA==.',['读经']='读经新云:BAABLAAECn8XAAMWAAgIDgtPYwDXAAAWAAYIlghPYwDXAAAGAAcIOAk/JwCaAAAAAA==.',['贾柱']='贾柱睾:BAACLAAFFH8KAAIIAAII1xpfRACaAAAIAAII1xpfRACaAAAsAAQKfxsAAggABghfFzl3AJMBAAgABghfFzl3AJMBAAAA.',['路西']='路西法的俘虏:BAAALAAECgUIBQAAAA==.路西法的信仰:BAAALAADCgYIBgAAAA==.',['跳跳']='跳跳舞迷迷人:BAABLAAECn8dAAIMAAgIvyBdDQD4AgAMAAgIvyBdDQD4AgABLAAFFAgIHAAXAOIkAA==.',['踏风']='踏风岚:BAAALAAECgYICgAAAA==.',['踩女']='踩女孩的蘑菇:BAAALAAECgYIDAAAAA==.',['轉身']='轉身華麗傾城:BAAALAAECgUIBwAAAA==.',['辰之']='辰之风:BAAALAAECgYICAAAAA==.',['过期']='过期奶:BAAALAAECgYICQAAAA==.',['迪拉']='迪拉戈剋:BAAALAAECgEIAQAAAA==.',['郑老']='郑老屁:BAAALAAECggICAAAAA==.',['重案']='重案组之虎:BAAALAAECgYIBgAAAA==.',['阳光']='阳光一兜兜:BAAALAAECgYIBgAAAA==.',['阿古']='阿古斯星魂:BAACLAAFFH8PAAISAAIIbRpRNQCiAAASAAIIbRpRNQCiAAAsAAQKfxQAAhIACAiRGxU/AGUCABIACAiRGxU/AGUCAAAA.',['阿尔']='阿尔萨鐁:BAAALAAFFAIIAgAAAA==.',['霸盗']='霸盗笼罩:BAAALAAECgEIAQAAAA==.',['青楼']='青楼名颜:BAAALAAFFAIIAgAAAA==.',['青瓷']='青瓷:BAABLAAFFH8KAAIYAAIIrgh7LAA+AAAYAAIIrgh7LAA+AAAAAA==.',['青絲']='青絲如雪:BAAALAAECgQIBAAAAA==.',['頭发']='頭发乱了:BAABLAAFFH8PAAIQAAMIYRwmJwC7AAAQAAMIYRwmJwC7AAAAAA==.',['風間']='風間丶火月:BAAALAAECgYIBgAAAA==.',['风大']='风大屁屁凉:BAAALAAFFAIIAwAAAA==.',['风浅']='风浅:BAAALAADCgIIAgAAAA==.',['风行']='风行者迷弟:BAAALAAECgYIEgAAAA==.',['风骚']='风骚不偿命:BAAALAADCggICAAAAA==.',['骑士']='骑士牛:BAAALAAECgYIBwAAAA==.',['黑星']='黑星:BAAALAAECgYIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end