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
 local lookup = {'Shaman-Elemental','DemonHunter-Havoc','Shaman-Restoration','Druid-Balance','Hunter-Marksmanship','DeathKnight-Blood','DeathKnight-Frost','Warlock-Destruction','Paladin-Retribution','Warlock-Demonology','Unknown-Unknown','Hunter-BeastMastery','Evoker-Devastation','Evoker-Preservation','Warlock-Affliction','Priest-Holy','Paladin-Holy','Paladin-Protection','Druid-Feral','Priest-Shadow','DeathKnight-Unholy',}; local provider = {region='CN',realm='黑暗之门',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ae='Aecx:BAAALAAECgYIBgAAAA==.',De='Deepsleep:BAAALAADCggIDwAAAA==.',Ge='Gehrman:BAAALAAECgYIBgAAAA==.',Li='Lidier:BAAALAAECgcICgAAAA==.',Mi='Miumiux:BAAALAAECgIIAgAAAA==.',Sh='Sherma:BAABLAAFFH82AAIBAAgI4iO+AQDqAgABAAgI4iO+AQDqAgAAAA==.',Wh='Wheelie:BAAALAAFFAIIBAAAAA==.',Zl='Zlz:BAAALAAECgYIBgAAAA==.',['一念']='一念地狱:BAAALAAECgIIAgAAAA==.',['一把']='一把钝刀:BAAALAAECgYIDAAAAA==.',['一支']='一支七匹狼:BAAALAAECgYICgAAAA==.',['一朵']='一朵娇花:BAAALAAECgMIAwAAAA==.',['一根']='一根大前门:BAAALAAECgYIBgAAAA==.',['一秒']='一秒钟带你走:BAAALAAECgYIBgAAAA==.',['七劈']='七劈狼:BAAALAADCgMIAwAAAA==.',['万能']='万能的耶耶:BAABLAAFFH8bAAICAAYIqyUWAgCSAgACAAYIqyUWAgCSAgAAAA==.',['丨古']='丨古尔蛋丨:BAABLAAFFH8+AAIBAAgI3yTqAAAGAwABAAgI3yTqAAAGAwAAAA==.',['丫丶']='丫丶滚蛋:BAAALAADCgcIBwAAAA==.',['丸子']='丸子汤:BAAALAADCgcIDgAAAA==.',['九零']='九零后:BAAALAAECgMIBQAAAA==.',['云淡']='云淡:BAAALAAECgIIAgAAAA==.',['亚灬']='亚灬当当:BAAALAAECgYIBgAAAA==.',['亲热']='亲热:BAAALAAECgIIAgAAAA==.',['何弃']='何弃疗:BAABLAAFFH8eAAMBAAgIxCHYBgBZAgABAAcIOyLYBgBZAgADAAQIDBhuLAALAQAAAA==.',['你买']='你买单我就来:BAABLAAFFH8GAAIEAAYIWAmyGgAHAQAEAAYIWAmyGgAHAQAAAA==.',['儛蹈']='儛蹈琾阝可飒:BAAALAADCggICAAAAA==.',['公无']='公无渡河:BAAALAAECgYIBgAAAA==.',['冰弑']='冰弑一图腾:BAAALAAECgYIBgAAAA==.冰弑一幻想:BAAALAAECgQIBAAAAA==.冰弑一悠闲:BAAALAAECgEIAQAAAA==.冰弑一飞雪:BAAALAAECgYICQAAAA==.',['凯子']='凯子哥哥:BAACLAAFFH8IAAIFAAII7BegHQCSAAAFAAII7BegHQCSAAAsAAQKfxcAAgUABgglG/U+ALsBAAUABgglG/U+ALsBAAAA.',['刺丶']='刺丶杀:BAAALAAECgEIAQAAAA==.',['千早']='千早爱音:BAABLAAFFH8cAAMGAAUIbSK3CQB/AQAGAAUIbSK3CQB/AQAHAAII7yFrNwDDAAAAAA==.',['原神']='原神:BAAALAAECgYIEQAAAA==.',['厦门']='厦门第一吊:BAAALAAECgYIEQAAAA==.',['发哥']='发哥哥:BAAALAAFFAIIAgAAAA==.',['可口']='可口灬可乐:BAACLAAFFH8TAAIIAAMI3gqoTwCAAAAIAAMI3gqoTwCAAAAsAAQKfxcAAggACAhGFwsuAJsBAAgACAhGFwsuAJsBAAAA.',['吴彦']='吴彦诅:BAAALAAECggICAAAAA==.',['圣丨']='圣丨战:BAAALAADCgYICAAAAA==.',['圣光']='圣光泯灭:BAAALAAECgYIDAAAAA==.',['圣托']='圣托里尼的风:BAAALAAECggIDAAAAA==.',['在留']='在留言后滴笙:BAAALAAECggICAAAAA==.',['垦荒']='垦荒的大熊:BAAALAAECgcICAAAAA==.',['墩儿']='墩儿的利剑:BAAALAAECgEIAQAAAA==.',['夜闻']='夜闻深秋:BAAALAAECgIIAgAAAA==.',['夜雨']='夜雨昏灯:BAAALAADCgYIEQAAAA==.',['大威']='大威天龙:BAAALAAECgIIAgAAAA==.',['天堂']='天堂晨歌:BAAALAADCgYIBgAAAA==.',['天天']='天天惩戒:BAABLAAFFH8HAAIJAAII0wbedwA6AAAJAAII0wbedwA6AAAAAA==.',['天空']='天空的红色:BAAALAAECgYIBgAAAA==.天空的绿色:BAAALAAECgUIBQAAAA==.天空的颜色:BAAALAAFFAIIAgAAAA==.天空的黑色:BAAALAADCgYIBgAAAA==.',['奔驰']='奔驰的小野马:BAAALAADCggICAAAAA==.',['妖妖']='妖妖霊:BAAALAAFFAIIAgAAAA==.',['孙涕']='孙涕涕丶:BAAALAAECgMIBAAAAA==.',['孙王']='孙王若兮:BAAALAAFFAIIAgAAAA==.孙王若潼:BAABLAAFFH8IAAMKAAIIshoWEQBLAAAKAAIIshoWEQBLAAAIAAEI7QikZwA6AAAAAA==.',['孙锤']='孙锤锤丶:BAAALAADCgUIBQAAAA==.',['宝可']='宝可梦大师:BAAALAAECgMIAwABLAAECgYIEQALAAAAAA==.',['客观']='客观里面请:BAAALAADCgEIAQAAAA==.',['小冰']='小冰依然爱你:BAACLAAFFH8IAAIMAAIIbxqslABEAAAMAAIIbxqslABEAAAsAAQKfxYAAgwABgjoF8ZwAGUBAAwABgjoF8ZwAGUBAAAA.',['小小']='小小大王:BAABLAAFFH8TAAMNAAYIYw1NDQBRAQANAAYIYw1NDQBRAQAOAAII4BHyEgCSAAAAAA==.',['小样']='小样把你:BAAALAAECgQIBAAAAA==.',['小楼']='小楼一夜听风:BAAALAADCgQIBAAAAA==.小楼一夜观星:BAAALAADCgYIBgAAAA==.',['小鸟']='小鸟医人:BAAALAAECgQIBQAAAA==.',['尛丶']='尛丶銘銘:BAABLAAECn8XAAIJAAgIvRvYHQAqAgAJAAgIvRvYHQAqAgAAAA==.',['尼尼']='尼尼薇丶月光:BAAALAADCgMIAwAAAA==.',['左冰']='左冰:BAAALAAECgYIDAAAAA==.',['常胜']='常胜将军:BAACLAAFFH8UAAIJAAMIrRRvHwDUAAAJAAMIrRRvHwDUAAAsAAQKfxsAAgkABwj4GyAvANgBAAkABwj4GyAvANgBAAAA.',['幽然']='幽然若梦:BAAALAAECgYIBgAAAA==.',['幽玥']='幽玥:BAAALAAFFAIIAgAAAA==.',['开心']='开心的天天:BAAALAAECgYICAAAAA==.',['张小']='张小信:BAAALAADCggIEAAAAA==.',['心灵']='心灵震撼:BAAALAAFFAIIAgAAAA==.',['心越']='心越:BAAALAADCggICAAAAA==.',['忆沉']='忆沉深冬:BAAALAAECgEIAQAAAA==.',['我有']='我有一个帽衫:BAAALAAECgQIBAAAAA==.',['打架']='打架輸喝酒吐:BAAALAADCgEIAQAAAA==.',['摸摸']='摸摸牛至:BAAALAADCgUIBQAAAA==.',['擎天']='擎天牛:BAAALAAFFAIIAgAAAA==.',['故土']='故土家乡:BAAALAADCgMIAwAAAA==.',['文韬']='文韬武略:BAAALAAECgYICgAAAA==.',['斯芬']='斯芬克斯:BAAALAAFFAIIAgAAAA==.',['无量']='无量小库:BAAALAADCgYIBgAAAA==.',['最爱']='最爱小拽拽:BAAALAAFFAIIAgAAAA==.',['有你']='有你妹啊:BAABLAAFFH8GAAIHAAYI2RdyLgCGAQAHAAYI2RdyLgCGAQAAAA==.',['朵丶']='朵丶朵:BAAALAAECgQIBAAAAA==.',['李成']='李成敏:BAAALAAECgcIBwAAAA==.',['杏仁']='杏仁露:BAAALAAECgcICAAAAA==.',['柠檬']='柠檬糖:BAACLAAFFH8yAAMIAAcIZCJkDABGAgAIAAcIZCJkDABGAgAKAAEIwBmQJgBSAAAsAAQKfyEABAgACAiRInsnAKcCAAgACAiNInsnAKcCAAoAAwiFEUNuAL0AAA8AAQi4FLw/ADsAAAAA.',['梦晓']='梦晓荷:BAAALAAFFAIIAgAAAA==.梦晓诃:BAAALAADCgIIAgAAAA==.',['楚涵']='楚涵:BAAALAAFFAIIAgAAAA==.',['歹毒']='歹毒丨遗忘:BAAALAAECgMIAwAAAA==.',['死亡']='死亡艺术:BAABLAAFFH8IAAIHAAUIHwnnTQD9AAAHAAUIHwnnTQD9AAAAAA==.',['永恩']='永恩:BAAALAADCgQIBAABLAAECgYIEQALAAAAAA==.',['没时']='没时间打篮球:BAAALAAECgYIBgAAAA==.',['溯源']='溯源逆流:BAABLAAFFH8GAAIQAAIIpAnfPQB6AAAQAAIIpAnfPQB6AAAAAA==.',['火炎']='火炎淼:BAAALAAECgIIAgAAAA==.',['爱慕']='爱慕剃:BAAALAAECgMIAwAAAA==.',['牧尸']='牧尸的骑士:BAACLAAFFH8VAAMRAAYIGhsRCACkAQARAAYIGhsRCACkAQASAAII1Q9KGQB0AAAsAAQKfxcAAxIACAhZHkEOAJsCABIACAhZHkEOAJsCABEABQjSCWdkAK8AAAAA.',['狗尾']='狗尾巴花:BAAALAAECgYICQAAAA==.',['猴子']='猴子偷桃:BAAALAADCgEIAQAAAA==.',['玖妖']='玖妖妖:BAAALAAECgIIAgAAAA==.',['玛德']='玛德绝了:BAAALAAFFAMIAwAAAA==.',['白日']='白日逃亡:BAAALAADCggICQAAAA==.',['白泽']='白泽:BAAALAAFFAIIAgAAAA==.',['看我']='看我新抓的蛆:BAAALAADCgMIAwAAAA==.',['神祈']='神祈灬雷霆:BAAALAAECgYIDwAAAA==.',['神隳']='神隳:BAAALAAECgYIDAAAAA==.',['第五']='第五个憨憨:BAAALAAFFAIIAgAAAA==.',['简直']='简直了:BAABLAAFFH8JAAIIAAIIpxlZXABEAAAIAAIIpxlZXABEAAAAAA==.',['细读']='细读刀锋:BAAALAADCgMIAwAAAA==.',['缱绻']='缱绻乡愁:BAAALAADCgQIBAAAAA==.',['翻翻']='翻翻鸽:BAAALAADCgEIAgAAAA==.',['老衲']='老衲法号随缘:BAAALAAECgYIBgAAAA==.',['苍茫']='苍茫大地:BAAALAADCgIIAgAAAA==.',['若叶']='若叶睦:BAAALAADCgEIAQAAAA==.',['莉亚']='莉亚徳琳:BAAALAADCgIIAgAAAA==.',['莫罗']='莫罗思:BAAALAAECgYICwAAAA==.',['菜的']='菜的有水平:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色闪电:BAACLAAFFH8RAAIDAAIIZCIeOgC+AAADAAIIZCIeOgC+AAAsAAQKfxQAAwMACAgoFtlWAOABAAMACAgoFtlWAOABAAEAAgjTC+S7AHAAAAAA.',['蔚奥']='蔚奥莱:BAABLAAECn8WAAIDAAYIcx3WVgDgAQADAAYIcx3WVgDgAQAAAA==.',['蛋蛋']='蛋蛋小迪迪:BAABLAAFFH8OAAIDAAII3BpjRACcAAADAAII3BpjRACcAAAAAA==.',['蜻蜓']='蜻蜓队长:BAAALAAECgIIBAAAAA==.',['血腥']='血腥马子:BAAALAAECggICAAAAA==.',['行政']='行政执法官:BAABLAAFFH8FAAIDAAMICwY0YwBZAAADAAMICwY0YwBZAAAAAA==.',['西北']='西北风在吹:BAAALAAECgYIBgAAAA==.',['西巴']='西巴小超人:BAAALAAFFAIIBAAAAA==.',['西斯']='西斯廷鬼祇:BAAALAAECgYIBwAAAA==.',['诸葛']='诸葛村夫:BAAALAADCgYIBgAAAA==.',['谁家']='谁家好人加班:BAAALAAECgYIBgAAAA==.',['超巨']='超巨大的高手:BAAALAAFFAIIAgAAAA==.',['轻歌']='轻歌曼妙:BAABLAAFFH8FAAICAAUIEQp7MQAVAQACAAUIEQp7MQAVAQAAAA==.',['辣个']='辣个帝剋:BAAALAAECgcICgAAAA==.辣个战丶:BAAALAAECgEIAQAAAA==.辣个贼:BAAALAAFFAIIAgAAAA==.',['追云']='追云逐电:BAAALAAECgYIDAAAAA==.',['追风']='追风迷茫:BAAALAAECgMIAwAAAA==.',['酋长']='酋长咆哮:BAAALAADCgUIBQAAAA==.',['醉仙']='醉仙丨一刀:BAAALAAECgIIAgAAAA==.',['野蠻']='野蠻執行者:BAABLAAFFH8VAAITAAYIHhpBAwCuAQATAAYIHhpBAwCuAQAAAA==.',['铭记']='铭记术先生:BAAALAAECgMIAwAAAA==.铭记萨:BAAALAAECgMIAwAAAA==.',['阐释']='阐释者:BAAALAAFFAIIAgAAAA==.',['阿喀']='阿喀琉嘶:BAAALAADCgEIAQAAAA==.',['阿苏']='阿苏斯:BAAALAAECgYIDAAAAA==.',['雪地']='雪地虎:BAAALAAFFAQIBAAAAA==.',['雪莉']='雪莉玫:BAAALAAFFAIIBAAAAA==.雪莉玫儿:BAAALAAECgUIBQAAAA==.',['霊妖']='霊妖霊:BAAALAAECgYIBgAAAA==.',['霜寒']='霜寒丶:BAAALAADCgMIAwAAAA==.',['霜满']='霜满天丶:BAABLAAFFH8gAAMUAAYIOxXmDQCEAQAUAAYIOxXmDQCEAQAQAAMIigaqOgB/AAAAAA==.',['青青']='青青子衿丶:BAAALAAECgQIBwAAAA==.',['风怒']='风怒:BAAALAAFFAIIAgAAAA==.',['风逍']='风逍:BAABLAAFFH8FAAIVAAII4AmQEwCLAAAVAAII4AmQEwCLAAAAAA==.',['飒岚']='飒岚:BAABLAAFFH8GAAIGAAIIzBIAEgB7AAAGAAIIzBIAEgB7AAAAAA==.',['魏国']='魏国灬貂蝉:BAAALAAECgYIBgAAAA==.',['魔瘾']='魔瘾:BAAALAADCgEIAQAAAA==.',['鹅城']='鹅城马邦德:BAABLAAFFH8VAAISAAYI/BQyBgARAQASAAYI/BQyBgARAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end