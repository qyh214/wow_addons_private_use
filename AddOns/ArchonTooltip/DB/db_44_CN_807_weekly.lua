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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Rogue-Assassination','Rogue-Subtlety','Priest-Shadow','Shaman-Restoration','Paladin-Retribution','Warrior-Protection','DemonHunter-Havoc','Evoker-Preservation','Evoker-Devastation','Paladin-Holy','Warrior-Fury','DeathKnight-Frost','Shaman-Elemental','DeathKnight-Unholy','Mage-Frost','Mage-Arcane','DemonHunter-Vengeance','Paladin-Protection',}; local provider = {region='CN',realm='范克里夫',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Animus:BAACLAAFFH8ZAAIBAAUIDRpKPwBKAQABAAUIDRpKPwBKAQAsAAQKfzAAAwEACAhTI6cQAJ8CAAEACAhTI6cQAJ8CAAIAAQgjFVC5AD0AAAAA.',Ch='Chloe:BAABLAAFFH8HAAIDAAIICBJtQABpAAADAAIICBJtQABpAAAAAA==.',Dm='Dmango:BAABLAAFFH8YAAMEAAYIgxslCACZAQAEAAYI3xglCACZAQAFAAIIsB9xEQBVAAAAAA==.',Do='Do:BAAALAAECgQIBAAAAA==.Dod:BAAALAAECgQIBAAAAA==.',Du='Durdun:BAAALAAECgYICAAAAA==.',Fo='Forestzz:BAAALAAECgUIBwAAAA==.',Fr='Frigga:BAABLAAECn8cAAMDAAYISxItYgBWAQADAAYISxItYgBWAQAGAAYISgSydgDTAAAAAA==.',Ki='Killersoap:BAAALAAFFAIIBAABLAAFFAIICwAHAHoaAA==.',Mo='Moonaurora:BAABLAAFFH8HAAIIAAMIUhEyRACJAAAIAAMIUhEyRACJAAAAAA==.',Sk='Skeleton:BAABLAAFFH8KAAIJAAIImhnEFwCbAAAJAAIImhnEFwCbAAAAAA==.',Vm='Vmango:BAABLAAFFH8QAAIKAAUIWRd5KwA7AQAKAAUIWRd5KwA7AQAAAA==.',['一色']='一色彩羽丶:BAAALAAECgIIAgAAAA==.',['下鸭']='下鸭总一郎:BAAALAADCgYIBgAAAA==.下鸭矢二郎:BAAALAAECgcIEgAAAA==.',['不知']='不知意:BAAALAAFFAIIAgAAAA==.',['专抓']='专抓小动物:BAAALAAECgYIBgAAAA==.',['丰川']='丰川祥子:BAAALAAECgQIBAAAAA==.',['丶噬']='丶噬心:BAAALAAFFAEIAQAAAA==.',['丶术']='丶术丶:BAAALAAECgYIBgAAAA==.',['丶水']='丶水无灯里:BAABLAAFFH8aAAMLAAgInhnGAwB3AgALAAcItxzGAwB3AgAMAAEIdB2uGgBYAAAAAA==.',['乄风']='乄风行者:BAABLAAFFH8GAAMCAAYItiJNBADxAQACAAUIPSRNBADxAQABAAEIEBvlgwBRAAAAAA==.',['九宝']='九宝茶:BAAALAAECgEIAQAAAA==.',['九歌']='九歌丶:BAABLAAFFH8PAAINAAgIMiAyAQAEAwANAAgIMiAyAQAEAwAAAA==.',['予秋']='予秋:BAAALAAFFAIIAgAAAA==.',['以战']='以战为名:BAAALAAECgYICwABLAAFFAgICwAOACohAA==.',['俺屯']='俺屯俺最傻:BAAALAAFFAIIBAAAAA==.',['公务']='公务牛:BAAALAADCgEIAQAAAA==.',['冬瓜']='冬瓜汆丸子:BAAALAAECgEIAQAAAA==.',['凉橙']='凉橙少年:BAAALAADCgEIAQAAAA==.',['凋零']='凋零的樱花:BAAALAAECgcIBwAAAA==.',['双星']='双星灬:BAAALAAFFAIIAgAAAA==.',['右手']='右手爱上酒:BAAALAAECgEIAQAAAA==.',['呀咿']='呀咿呀咿哟:BAAALAAECgUIBQAAAA==.',['呼噜']='呼噜猪:BAAALAADCggICQAAAA==.',['哥哥']='哥哥很按全:BAAALAAFFAIIBAAAAA==.哥哥狠安全:BAAALAAECgMIAwAAAA==.',['回归']='回归小恶魔:BAAALAAFFAIIBAAAAA==.',['圣花']='圣花卷:BAAALAAECgMIBgAAAA==.',['夏至']='夏至:BAAALAAECgUIBwAAAA==.',['天斩']='天斩:BAABLAAFFH8QAAINAAYIBSKlBQA/AgANAAYIBSKlBQA/AgAAAA==.',['天月']='天月将白:BAAALAAECgYICAAAAA==.',['奥术']='奥术爆炸萝卜:BAAALAADCgUIBQAAAA==.',['女朋']='女朋友:BAAALAAECgYIBgAAAA==.',['奶嘴']='奶嘴:BAAALAAECgMIAwAAAA==.',['如夢']='如夢令:BAAALAAECgUIBQAAAA==.',['姬柏']='姬柏昶丶:BAABLAAECn8YAAIPAAYISR4DOACbAQAPAAYISR4DOACbAQAAAA==.',['孙毓']='孙毓博:BAAALAAECgYIDgAAAA==.',['季柏']='季柏常丶:BAAALAAECgYIEQAAAA==.',['季的']='季的终章:BAABLAAFFH8GAAIQAAYI6RXCGgBqAQAQAAYI6RXCGgBqAQAAAA==.',['小小']='小小骑士团:BAAALAAECgYIBwAAAA==.',['小水']='小水珠:BAAALAAFFAQIBAAAAA==.',['小皮']='小皮艳子:BAAALAAFFAIIAgAAAA==.',['小苹']='小苹果:BAAALAAECgYICgAAAA==.',['小豆']='小豆豆:BAAALAADCgcIBwAAAA==.',['小錦']='小錦鯉丶:BAAALAAECgYIDAAAAA==.',['尹道']='尹道锦丶:BAABLAAECn8YAAIIAAYIPyFQMwDGAQAIAAYIPyFQMwDGAQAAAA==.',['山下']='山下白鬼:BAACLAAFFH8nAAMBAAYIQCL7HQC8AQABAAYImCH7HQC8AQACAAMIwyDxGQCjAAAsAAQKfyUAAwIACAgzIz4LAAoDAAIACAhiIj4LAAoDAAEABghFJd8qAA0CAAAA.',['希望']='希望:BAAALAAFFAIIAgAAAA==.',['年少']='年少不识英招:BAABLAAFFH8GAAIQAAYIohjDFgCHAQAQAAYIohjDFgCHAQAAAA==.',['廿一']='廿一响礼炮:BAAALAADCgIIAgAAAA==.',['弁天']='弁天:BAAALAADCgYIBgAAAA==.',['快活']='快活的两撇胡:BAABLAAFFH8LAAIHAAIIehpcNwCSAAAHAAIIehpcNwCSAAAAAA==.',['念旧']='念旧:BAAALAAECgYIBgAAAA==.',['情绪']='情绪:BAABLAAFFH8FAAIQAAUIkhpsIwAqAQAQAAUIkhpsIwAqAQAAAA==.',['懂哥']='懂哥来了:BAAALAADCggICgAAAA==.',['我也']='我也想学外语:BAAALAAECgYICQAAAA==.',['我变']='我变大狗熊:BAAALAADCgEIAQAAAA==.',['手捧']='手捧玫瑰:BAAALAAECgcIBwAAAA==.',['放声']='放声尖叫:BAAALAAFFAIIAgAAAA==.',['时光']='时光:BAABLAAFFH8IAAIHAAIIxQx4YgBZAAAHAAIIxQx4YgBZAAAAAA==.',['旺财']='旺财神喵:BAABLAAECn8XAAIPAAYIhiG/iQDpAQAPAAYIhiG/iQDpAQAAAA==.',['星星']='星星飞天撞:BAAALAAECgEIAQAAAA==.',['是冬']='是冬:BAABLAAFFH8HAAIQAAYI6BOwGwBjAQAQAAYI6BOwGwBjAQAAAA==.',['是湫']='是湫:BAAALAAFFAIIAgAAAA==.',['晓风']='晓风残月:BAAALAAECgYIBgAAAA==.',['最佳']='最佳毛皮:BAAALAADCgQIBAAAAA==.',['月亮']='月亮之井:BAACLAAFFH8MAAIIAAIIiRlKXwBHAAAIAAIIiRlKXwBHAAAsAAQKfxYAAggACAiNGU46AK8BAAgACAiNGU46AK8BAAAA.',['月舞']='月舞丨清枫:BAAALAAFFAIIAgAAAA==.',['机佬']='机佬黄:BAACLAAFFH8QAAIKAAUIGBsTJwBZAQAKAAUIGBsTJwBZAQAsAAQKfyIAAgoABgjYIf5JAEQCAAoABgjYIf5JAEQCAAAA.',['杀戮']='杀戮小妖:BAABLAAFFH8KAAIPAAIIDhEfdABNAAAPAAIIDhEfdABNAAAAAA==.',['欢喜']='欢喜丶:BAABLAAFFH8QAAIDAAUIWAqbJAAZAQADAAUIWAqbJAAZAQAAAA==.',['水冰']='水冰月张:BAAALAAECgIIAgAAAA==.',['沈小']='沈小倩:BAAALAAFFAIIAgAAAA==.',['没事']='没事我等你:BAAALAADCgQIBAAAAA==.',['温蕾']='温蕾萨:BAABLAAFFH8KAAMPAAYIkhPQJwCYAQAPAAYIkhPQJwCYAQARAAQI5gIrCgCzAAABLAAFFAgIBwAOAEIWAA==.',['游鱼']='游鱼丿:BAAALAAECgMIAwAAAA==.',['滅魂']='滅魂潇:BAABLAAFFH8KAAMSAAMIjhOlFQBEAAATAAMIDA5WTABfAAASAAII5QylFQBEAAAAAA==.',['满心']='满心丶:BAACLAAFFH8TAAIJAAUIbBNAFQASAQAJAAUIbBNAFQASAQAsAAQKfyEAAwkABwgmGwwmAAwCAAkABwgmGwwmAAwCAA4ABgg6DRadAEoBAAAA.',['滨江']='滨江:BAAALAAFFAQIBAAAAA==.',['灬李']='灬李子灬:BAAALAAFFAEIAQAAAA==.',['烈日']='烈日行者:BAAALAAECggICAAAAA==.',['牵着']='牵着别人跑:BAAALAAFFAQIBAAAAA==.',['狂暴']='狂暴大杀器丶:BAAALAADCgIIAgAAAA==.',['狂燥']='狂燥苏大强:BAACLAAFFH8TAAMEAAMI0RNFFQCXAAAEAAMI0RNFFQCXAAAFAAIIjA2hFQCEAAAsAAQKfyEAAwUABgjHH24XAOIBAAUABgi/HW4XAOIBAAQABQhWHtUOAHgBAAAA.',['狐人']='狐人肝肝:BAAALAAECgEIAQAAAA==.',['甜滋']='甜滋滋的桃子:BAABLAAFFH8FAAIHAAUIPQJnUAB7AAAHAAUIPQJnUAB7AAAAAA==.',['电梯']='电梯血:BAAALAADCgYIBgAAAA==.',['白鸽']='白鸽:BAAALAAFFAMIAwAAAA==.',['第三']='第三种人:BAAALAAECgQIBAAAAA==.',['粉刺']='粉刺玛修:BAABLAAFFH8GAAIGAAIIwA8VIQCMAAAGAAIIwA8VIQCMAAAAAA==.',['绝刃']='绝刃苍雄:BAAALAAECgUIBQAAAA==.',['老人']='老人与海:BAABLAAFFH8GAAIQAAYI1RQPGgBwAQAQAAYI1RQPGgBwAQAAAA==.',['老李']='老李头:BAABLAAFFH8GAAISAAII2RMDGQA+AAASAAII2RMDGQA+AAAAAA==.',['胡不']='胡不吝:BAAALAAECggICAAAAA==.',['至高']='至高岭肝肝:BAACLAAFFH8HAAMHAAMIMxnzGADpAAAHAAMIMxnzGADpAAAQAAIIjQx/LQCOAAAsAAQKfxwAAwcACAhUH5EWAMUCAAcACAhUH5EWAMUCABAACAhKGAEwAEwCAAAA.',['舞刃']='舞刃:BAABLAAFFH8LAAIUAAYIRwSOCQC9AAAUAAYIRwSOCQC9AAAAAA==.',['芝士']='芝士面条:BAAALAADCgYIBgAAAA==.',['莎拉']='莎拉凯瑞甘:BAAALAAFFAIIAgAAAA==.',['萨鲁']='萨鲁法牛:BAABLAAFFH8GAAMPAAIIzBMDbwCRAAAPAAIIkw4DbwCRAAARAAEIyhXpGgBXAAAAAA==.',['藏起']='藏起来的猫:BAAALAAECgYICQAAAA==.',['虚空']='虚空寻觅者:BAABLAAFFH8KAAMBAAIIzAyUmgBBAAACAAII2wVfLgBnAAABAAIIzAyUmgBBAAAAAA==.',['西欧']='西欧:BAAALAADCgIIAgAAAA==.',['諾查']='諾查丹瑪斯:BAAALAAFFAIIAgAAAA==.',['诀别']='诀别:BAAALAAFFAMIAwAAAA==.',['诗和']='诗和远方:BAAALAAECgUIBwAAAA==.',['蹦极']='蹦极不用绳:BAAALAAECgcIBwAAAA==.',['迦叶']='迦叶之荣耀:BAABLAAFFH8UAAIIAAUIJBekKAA4AQAIAAUIJBekKAA4AQABLAAFFAYIFQAPALIRAA==.迦叶之魇魅:BAABLAAFFH8VAAIPAAYIshGVLQCEAQAPAAYIshGVLQCEAQAAAA==.',['那我']='那我问你:BAAALAAECgMIAwAAAA==.',['醉青']='醉青楼:BAAALAAECgYIDAAAAA==.',['金属']='金属恐慌:BAAALAAECggICAAAAA==.',['闪光']='闪光的骑士:BAABLAAECn8aAAMVAAYInRjfFgBhAQAVAAYInRjfFgBhAQAIAAQIMwiOywBlAAAAAA==.',['闪雷']='闪雷:BAABLAAFFH8GAAIBAAYIKBubNQBnAQABAAYIKBubNQBnAQAAAA==.',['闷骚']='闷骚的单:BAABLAAFFH8GAAIHAAIIFgOxdABDAAAHAAIIFgOxdABDAAAAAA==.',['阿尔']='阿尔特留斯:BAAALAAECgYICAAAAA==.',['阿硕']='阿硕吖:BAAALAAFFAIIBAAAAA==.阿硕呀:BAAALAAECgMIAwAAAA==.',['阿迷']='阿迷:BAAALAAECggIEQAAAA==.',['领主']='领主日联盟:BAAALAAECgYICgAAAA==.',['香橙']='香橙星冰乐:BAAALAAECgUIBQAAAA==.',['马拉']='马拉個币:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end