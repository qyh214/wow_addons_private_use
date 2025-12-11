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
 local lookup = {'DeathKnight-Frost','Hunter-BeastMastery','Druid-Feral','Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Priest-Shadow','Mage-Arcane','Evoker-Devastation','Warlock-Affliction','Druid-Restoration','DemonHunter-Havoc','Warrior-Fury','Monk-Mistweaver','Monk-Windwalker','Priest-Discipline','Druid-Balance','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','Warrior-Protection','Monk-Brewmaster','Paladin-Holy',}; local provider = {region='CN',realm='冰川之拳',name='CN',type='weekly',zone=44,date='2025-12-06',data={Am='Ame:BAAALAADCgIIAgAAAA==.',Au='Auv:BAABLAAFFH8GAAIBAAIIYBBhgABFAAABAAIIYBBhgABFAAAAAA==.',Az='Azreal:BAABLAAFFH8eAAICAAYIiCAkGQDSAQACAAYIiCAkGQDSAQAAAA==.',Ba='Bayern:BAAALAADCgcIDQAAAA==.',Cc='Ccbt:BAAALAAECgUIBwAAAA==.',Da='Darkheaven:BAABLAAFFH8RAAIDAAUIxxNhBgAxAQADAAUIxxNhBgAxAQAAAA==.Darknessy:BAABLAAFFH8TAAMEAAYIUhTpBgC7AAAFAAUIdQ+VPAASAQAEAAMIOx3pBgC7AAAAAA==.Darkwish:BAABLAAFFH8TAAMGAAUIeQ7cDAA/AQAGAAUIeQ7cDAA/AQAHAAIIRQQwGAA0AAAAAA==.',Fo='Forzamilan:BAAALAAECggICAAAAA==.',Fy='Fydog:BAABLAAFFH8HAAMIAAMIYAoQMwCcAAAIAAMIYAoQMwCcAAAJAAIIMwg4KgBCAAAAAA==.',Gi='Gilenamagic:BAABLAAFFH8GAAIKAAII7wbcZAA2AAAKAAII7wbcZAA2AAAAAA==.',Li='Liuda:BAABLAAFFH8GAAICAAYICg0ORQA1AQACAAYICg0ORQA1AQAAAA==.',Lo='Longr:BAABLAAFFH8GAAILAAYIbAodFQCsAAALAAYIbAodFQCsAAAAAA==.',No='Noctilucence:BAAALAAFFAIIBAAAAA==.',Om='Oma:BAABLAAECn8VAAQEAAgIvhWUPQB2AQAEAAUIWh2UPQB2AQAMAAUIUAd4GwAiAQAFAAEIzxJRAQE8AAAAAA==.Omadz:BAAALAADCggICAAAAA==.',Ox='Oxo:BAAALAAECgYICgAAAA==.',Po='Poseidon:BAABLAAFFH8GAAINAAIIMgguQwBcAAANAAIIMgguQwBcAAAAAA==.',Ra='Ranran:BAAALAADCgEIAQAAAA==.',Sc='Scar:BAAALAADCgMIAwAAAA==.',Vu='Vulcano:BAAALAAFFAQIAgAAAA==.',Yu='Yuyuyuyuuyu:BAAALAAECgYIBgAAAA==.',['七天']='七天大圣:BAAALAAECgYICAAAAA==.',['上帝']='上帝的外套:BAAALAADCgcIBwAAAA==.',['上班']='上班打瞌睡:BAAALAAECgYIBgAAAA==.上班钓大鱼:BAAALAAECgYIDwAAAA==.',['丨深']='丨深雪丨:BAAALAAECgYICwAAAA==.',['丨雪']='丨雪枫丨:BAAALAAECgEIAQAAAA==.丨雪泉丨:BAAALAAECgQIBAAAAA==.丨雪風丨:BAAALAAECgMIAwAAAA==.丨雪风丨:BAAALAAECgYIBgAAAA==.',['中年']='中年狂暴战:BAAALAAECgIIAgAAAA==.',['丰川']='丰川祥子:BAAALAAFFAIIBAAAAA==.',['丶不']='丶不醉不会:BAAALAAECgMIAwAAAA==.',['丹妮']='丹妮莉斯:BAAALAAECgYIBwAAAA==.',['于她']='于她人间寻:BAAALAAFFAQIBAAAAA==.',['云泽']='云泽:BAAALAAECgYIBwAAAA==.',['令狐']='令狐冲:BAAALAADCgUIAgAAAA==.',['伊夫']='伊夫里特:BAAALAADCgcIBwAAAA==.',['依然']='依然灬断弦:BAABLAAECn8XAAIOAAYI/hiiRABNAQAOAAYI/hiiRABNAQAAAA==.',['冰弑']='冰弑丶凌霜:BAACLAAFFH8SAAIBAAUI7hmUPgBAAQABAAUI7hmUPgBAAQAsAAQKfxYAAgEABwimIG9JAGgCAAEABwimIG9JAGgCAAAA.冰弑丶绫霜:BAAALAAFFAMIAwAAAA==.',['初心']='初心未来:BAAALAAECgIIAgAAAA==.',['剑魔']='剑魔苍月:BAAALAAECgUIBQAAAA==.',['加菲']='加菲尔:BAAALAAECgYICgAAAA==.',['十三']='十三号飞象:BAAALAAECgYICQAAAA==.',['午夜']='午夜猴子球:BAAALAAECgYIBgAAAA==.',['半糖']='半糖蜡笔:BAAALAAECgYIDAAAAA==.',['单边']='单边的耳钉:BAAALAADCgEIAQAAAA==.',['卟德']='卟德嘹:BAAALAAFFAIIAgAAAA==.',['可燃']='可燃乌龙茶:BAABLAAFFH8QAAIPAAUI+BM/JQBFAQAPAAUI+BM/JQBFAQAAAA==.',['叶小']='叶小牛:BAABLAAFFH8KAAMQAAQImAvGDwDCAAAQAAQImAvGDwDCAAARAAEIdgbfGgA9AAAAAA==.',['咩咩']='咩咩王:BAAALAAECgYICwAAAA==.',['嗷呜']='嗷呜努:BAABLAAFFH8GAAIKAAYI3BbQCwALAgAKAAYI3BbQCwALAgAAAA==.',['大地']='大地之力:BAAALAAECgYIBgAAAA==.',['大钱']='大钱包:BAAALAAECgEIAQAAAA==.',['天地']='天地唯我独尊:BAAALAAECgIIAgAAAA==.',['天籁']='天籁梵音:BAABLAAFFH8PAAMIAAYIXgm2JQAMAQAIAAUI7we2JQAMAQASAAIIKQlGBgBTAAAAAA==.天籁风荷雨:BAABLAAFFH8SAAMNAAUIKAgdJQDwAAANAAUIKAgdJQDwAAATAAEIkwXxOQAzAAAAAA==.',['姬小']='姬小月:BAAALAAECgEIAQAAAA==.',['娃娃']='娃娃頭:BAABLAAFFH8FAAICAAIICRK7mQBBAAACAAIICRK7mQBBAAAAAA==.',['子言']='子言丶:BAAALAAFFAQIBAABLAAFFAgIAgAUAAAAAA==.',['宇宙']='宇宙无敌暴龙:BAAALAAECgYIDAAAAA==.',['寒木']='寒木春华:BAAALAAECgUICwAAAA==.',['小冬']='小冬瓜:BAABLAAFFH8HAAMVAAMIphWuTQBtAAAVAAIINhCuTQBtAAAWAAEI3QNHUQAxAAAAAA==.',['小小']='小小月:BAAALAAECgYIBwAAAA==.',['小熊']='小熊可可茶:BAAALAAECgUIBQAAAA==.',['小米']='小米:BAAALAAFFAIIAgAAAA==.',['崽崽']='崽崽哥:BAABLAAECn8VAAMNAAYIfA9OQAAYAQANAAYIfA9OQAAYAQATAAIISQLOrgAvAAAAAA==.',['希默']='希默:BAAALAAECgYICAAAAA==.',['弈秋']='弈秋丶:BAAALAAECgYICgAAAA==.',['微微']='微微泛晴:BAACLAAFFH8PAAIIAAMIjAG1OgB1AAAIAAMIjAG1OgB1AAAsAAQKfx0AAwgABwiGCKNCANQAAAgABwiGCKNCANQAABIABAhwAhU2AFIAAAAA.',['德德']='德德鰢:BAAALAAECgEIAQAAAA==.',['德艺']='德艺双馨:BAAALAADCggICAAAAA==.',['心之']='心之所往:BAAALAAECgIIAgAAAA==.',['志俊']='志俊小莎:BAAALAAECgEIAQAAAA==.',['念山']='念山丶:BAAALAAECgYIEgAAAA==.',['恩希']='恩希玛拌面:BAAALAAECggIDQAAAA==.',['惜默']='惜默:BAAALAADCgYIBgAAAA==.',['我就']='我就是你哥哥:BAAALAAECgYIBgABLAAFFAYIMQACAHwjAA==.',['我是']='我是小鱼:BAABLAAFFH8ZAAIVAAgIgBxcAwCcAgAVAAgIgBxcAwCcAgAAAA==.',['拉风']='拉风犀利:BAAALAAFFAIIAgAAAA==.',['拥抱']='拥抱开始:BAABLAAFFH8jAAQXAAYIbxiaAgCxAQAXAAYIQBiaAgCxAQABAAQISw32UQDQAAAYAAEIfgC4IAAGAAABLAAFFAgIMQAOAMcgAA==.',['拿铁']='拿铁蜡笔:BAAALAAECgYICgAAAA==.',['摩卡']='摩卡蜡笔:BAAALAAECgYIEQAAAA==.',['擒封']='擒封希于桑林:BAAALAAECgUIBgAAAA==.',['文一']='文一:BAABLAAFFH8GAAICAAYI2w7MQQBBAQACAAYI2w7MQQBBAQAAAA==.',['无双']='无双:BAAALAAECgYIBgAAAA==.',['无瑕']='无瑕:BAABLAAFFH8JAAIZAAII+CA2JwC7AAAZAAII+CA2JwC7AAAAAA==.',['明月']='明月:BAAALAADCgYIBgAAAA==.',['春干']='春干部:BAAALAAECgYIBgAAAA==.',['春风']='春风一度:BAABLAAFFH8RAAICAAUISyBLMwBtAQACAAUISyBLMwBtAQAAAA==.',['最后']='最后一杯:BAAALAAECgEIAQAAAA==.',['月照']='月照:BAAALAADCggICAAAAA==.月照故里丶:BAAALAAFFAIIAwAAAA==.',['木有']='木有小丁丁:BAAALAAECgYIBgAAAA==.',['梦五']='梦五爷:BAAALAAECgMIAwAAAA==.',['死亡']='死亡公爵:BAABLAAFFH8FAAIBAAMIWgRLbQBcAAABAAMIWgRLbQBcAAAAAA==.',['沃迪']='沃迪玛耶:BAAALAAFFAQIBAAAAA==.',['没事']='没事瞎溜达:BAABLAAECn8VAAICAAYIiRNg4wBSAQACAAYIiRNg4wBSAQAAAA==.',['沧樗']='沧樗:BAACLAAFFH8uAAIFAAYIJhsDIQCYAQAFAAYIJhsDIQCYAQAsAAQKfyAAAgUACAgVHmcTAEcCAAUACAgVHmcTAEcCAAAA.',['洛克']='洛克洛克:BAABLAAFFH8WAAIPAAYILBA5HgB4AQAPAAYILBA5HgB4AQAAAA==.',['浅语']='浅语:BAAALAAECgIIAgAAAA==.',['淺笑']='淺笑安然:BAAALAADCgIIAgAAAA==.',['清歌']='清歌唱响:BAAALAADCgQIBAAAAA==.',['烤披']='烤披萨:BAAALAADCgYIBgAAAA==.',['烤面']='烤面包:BAAALAADCgEIAQAAAA==.',['熬过']='熬过寒冬:BAAALAADCgEIAQAAAA==.',['爆一']='爆一下哦:BAAALAAFFAEIAQAAAA==.',['牛奶']='牛奶蜡笔:BAAALAAFFAMIAwAAAA==.',['牛牛']='牛牛冲天:BAAALAAFFAIIAwAAAA==.',['犇犇']='犇犇:BAAALAADCgYIBgAAAA==.',['狂岚']='狂岚:BAAALAAECgYICAAAAA==.',['猴子']='猴子精:BAAALAADCgcIBwAAAA==.',['玉龙']='玉龙:BAAALAAFFAMIAwAAAA==.',['王妃']='王妃:BAAALAAFFAIIBAAAAA==.',['王心']='王心凌:BAAALAAECgYIBgAAAA==.',['玩偶']='玩偶收割机:BAAALAAECgYICQAAAA==.玩偶瓦娜斯:BAAALAAFFAIIAgAAAA==.',['瘾大']='瘾大技术差:BAAALAAECgYIBgAAAA==.',['白澳']='白澳蜡笔:BAABLAAECn8UAAIaAAYIchmYGgBsAQAaAAYIchmYGgBsAQAAAA==.',['真夜']='真夜哥哥:BAABLAAFFH8HAAIZAAMI/Rq1OwCmAAAZAAMI/Rq1OwCmAAAAAA==.',['瞎子']='瞎子嗨:BAAALAAFFAIIAgAAAA==.',['破法']='破法者木木:BAAALAAECgIIAgAAAA==.',['碧空']='碧空尽:BAABLAAFFH8FAAIaAAMITwdEHACiAAAaAAMITwdEHACiAAAAAA==.',['神鹰']='神鹰黑手:BAABLAAFFH8KAAIPAAUIlQjkKwAEAQAPAAUIlQjkKwAEAQAAAA==.',['端狗']='端狗狗严父:BAAALAAECgIIAgAAAA==.',['糊涂']='糊涂涂:BAAALAAFFAIIAgAAAA==.',['缘灭']='缘灭魂散:BAAALAAFFAIIAgAAAA==.',['美式']='美式蜡笔:BAAALAAFFAIIAwAAAA==.',['羽天']='羽天休伊:BAAALAADCgQIAwAAAA==.',['老北']='老北京鸡肉卷:BAAALAAECgYIBgAAAA==.',['聚魂']='聚魂:BAAALAAECgYIDAAAAA==.',['聲路']='聲路莫問誰:BAAALAAECgcICAAAAA==.',['與君']='與君初相識:BAABLAAFFH8MAAIPAAIIahhNNQCZAAAPAAIIahhNNQCZAAABLAAFFAYIKAAFAIURAA==.',['良宵']='良宵无意游玩:BAAALAAECgYICAAAAA==.',['苍穹']='苍穹之力:BAAALAAECgUIBQAAAA==.',['苍羽']='苍羽飒飒:BAAALAADCgEIAQAAAA==.',['萨满']='萨满啊木:BAAALAAECgYIDAAAAA==.',['落泪']='落泪情绪零碎:BAAALAAECgUIBgAAAA==.',['蛀牙']='蛀牙很不爽:BAAALAAECggIAgAAAA==.蛀牙的萨满:BAAALAAECggICAAAAA==.',['蝴蝶']='蝴蝶的淺笑:BAAALAADCgcIBwAAAA==.',['血与']='血与酒:BAAALAAECgUIBQAAAA==.',['裘猫']='裘猫:BAACLAAFFH8RAAMBAAQIhxt5TAD7AAABAAQIhxt5TAD7AAAYAAEIWQBQIAAXAAAsAAQKfyYAAgEACAgRHV5AAIACAAEACAgRHV5AAIACAAAA.',['诸葛']='诸葛猪哥:BAAALAAFFAIIAgAAAA==.',['诺达']='诺达希尔丨:BAAALAAFFAMIAwAAAA==.',['超级']='超级猴子球:BAAALAAECggIEQAAAA==.',['超骨']='超骨干奶牛:BAAALAAECgYIBwAAAA==.',['跳起']='跳起来暴菊花:BAABLAAECn8WAAIPAAYI6RleZQDGAQAPAAYI6RleZQDGAQAAAA==.',['这里']='这里是哪里:BAAALAAECgcIBwAAAA==.',['连续']='连续剧:BAAALAAECgYIEAAAAA==.',['部落']='部落的小神僧:BAABLAAFFH8IAAIbAAYIah29CAC/AQAbAAYIah29CAC/AQAAAA==.部落的小神德:BAAALAAECgIIAgAAAA==.部落的小神战:BAAALAAECgUIBwAAAA==.部落的小神萨:BAAALAAFFAIIAgAAAA==.',['醉卧']='醉卧佳人笑丶:BAABLAAFFH8GAAIIAAYI3gb4HwBKAQAIAAYI3gb4HwBKAQAAAA==.',['针不']='针不错:BAAALAADCgYIBwAAAA==.',['阴川']='阴川蝴蝶君:BAABLAAFFH8FAAIOAAUIsASANADiAAAOAAUIsASANADiAAAAAA==.',['阿塔']='阿塔兰特:BAAALAAECgUIBQAAAA==.',['阿心']='阿心:BAAALAADCggIKQAAAA==.',['阿迪']='阿迪玉:BAABLAAFFH8YAAIPAAYIFRRcHACFAQAPAAYIFRRcHACFAQAAAA==.',['随风']='随风入心:BAAALAAECgEIAQAAAA==.',['雷希']='雷希拉姆:BAAALAAECgUIBQAAAA==.',['雷霆']='雷霆万钧:BAAALAAECgYICwAAAA==.',['青椒']='青椒:BAAALAAECgYICAAAAA==.',['风形']='风形:BAAALAADCgQIBAAAAA==.',['飘缈']='飘缈的传说:BAAALAAECgYICAAAAA==.',['饼干']='饼干:BAAALAAECgEIAQAAAA==.',['马来']='马来西亚之力:BAAALAAFFAIIBAAAAA==.',['骑鹦']='骑鹦鹉的小猪:BAAALAAFFAIIAgAAAA==.',['黄泉']='黄泉赎夜姬:BAAALAAFFAIIAgAAAA==.',['黑锅']='黑锅底:BAAALAAECgIIAgAAAA==.',['黛染']='黛染青曦:BAABLAAFFH8SAAMcAAYI7ghwHADFAAAcAAUIdwNwHADFAAAZAAQIUgjIOAC7AAAAAA==.',['龙恨']='龙恨:BAAALAAECgIIAgAAAA==.',['龙熙']='龙熙:BAAALAAECgYIDwAAAA==.',['龙祈']='龙祈:BAAALAAECgYICAAAAA==.',['龙缔']='龙缔:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end