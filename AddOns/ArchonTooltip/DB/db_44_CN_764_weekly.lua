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
 local lookup = {'Warlock-Destruction','Warrior-Fury','Shaman-Restoration','Druid-Balance','Druid-Restoration','Hunter-Survival','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Blood','Paladin-Holy','Unknown-Unknown','Druid-Guardian','Warlock-Demonology','Priest-Holy',}; local provider = {region='CN',realm='瑟莱德丝',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acolytes:BAAALAAECgMIAwAAAA==.',Ai='Aimomo:BAAALAAFFAgIAgAAAA==.',Ca='Catherine:BAABLAAFFH8IAAIBAAIIdg/+PwCYAAABAAIIdg/+PwCYAAAAAA==.',Do='Dolana:BAABLAAFFH8GAAICAAQI9AaHPAB+AAACAAQI9AaHPAB+AAAAAA==.',Ep='Episcopos:BAAALAAECgUIBQAAAA==.',Gi='Gimlie:BAAALAAECgUIBQAAAA==.',Lo='Louis:BAAALAAECgYIDAAAAA==.',Ni='Niklaus:BAABLAAFFH8GAAIDAAYIVwCegAAgAAADAAYIVwCegAAgAAAAAA==.',Qs='Qsuperqwq:BAAALAAFFAIIBAAAAA==.',Sh='Shiniqua:BAABLAAFFH8NAAMEAAYIEgkIIAC/AAAEAAUIaQYIIAC/AAAFAAIIoR9wGwC0AAAAAA==.',Wh='Whnyy:BAAALAAECgEIAQAAAA==.',Yi='Yiyiyiyi:BAAALAADCggICAAAAA==.',['一口']='一口奶不加:BAAALAADCgcIBwAAAA==.',['七只']='七只:BAAALAADCgQIBAAAAA==.',['专干']='专干帅气:BAAALAAECgcIEgAAAA==.',['九老']='九老:BAAALAADCggIDAAAAA==.',['仔姜']='仔姜兔:BAAALAAECgUIBQAAAA==.',['代号']='代号猎手:BAACLAAFFH8KAAMGAAIIChp1BACdAAAGAAIIvBR1BACdAAAHAAIIChoXiQBJAAAsAAQKfxwAAwcABghgIKxAAMoBAAcABghgIKxAAMoBAAYAAwiDFb0bANQAAAAA.',['伊丽']='伊丽丹怒风:BAAALAADCgEIAQAAAA==.',['伊利']='伊利丶丹:BAAALAAECgQIBAAAAA==.',['俺是']='俺是帝皮埃斯:BAABLAAFFH8GAAIBAAIIzQlMZwA5AAABAAIIzQlMZwA5AAAAAA==.',['偶尔']='偶尔躲躲乌云:BAAALAAECgYIBgAAAA==.',['偷电']='偷电是态度:BAAALAAECgYIBgAAAA==.',['克拉']='克拉苏斯:BAAALAAECgcIDwAAAA==.',['克里']='克里斯塔皮爷:BAABLAAFFH8PAAIHAAQINR8yOgCvAAAHAAQINR8yOgCvAAAAAA==.',['八只']='八只:BAAALAAECgMIAwAAAA==.',['八月']='八月十一:BAAALAAFFAIIAgAAAA==.',['冰摇']='冰摇桃桃乌龙:BAAALAAECgUIBQAAAA==.',['冷云']='冷云逸:BAAALAADCgYIBgAAAA==.',['冷凝']='冷凝:BAABLAAECn8gAAIIAAYIGhCTegALAQAIAAYIGhCTegALAQAAAA==.',['凯旋']='凯旋之道:BAAALAADCgMIAwAAAA==.',['刀落']='刀落人抬走灬:BAAALAADCgUIBQAAAA==.',['北冥']='北冥有鱼:BAACLAAFFH8vAAMJAAYIHiWHDQAnAgAJAAYIHiWHDQAnAgAKAAEI9wCLGQAkAAAsAAQKfx8AAwkABwivIsAWADICAAkABghnJsAWADICAAoAAQhfDLtMADYAAAAA.',['哇大']='哇大恶魔:BAAALAAECgUIBQAAAA==.',['啊瑞']='啊瑞思:BAAALAADCgcIBwAAAA==.啊瑞斯:BAAALAAFFAIIBAAAAA==.',['嗣妖']='嗣妖姬:BAAALAAECgYIBgAAAA==.',['圣光']='圣光团子:BAABLAAFFH8FAAIIAAIIFAxUTgCUAAAIAAIIFAxUTgCUAAAAAA==.圣光闪现:BAACLAAFFH8vAAILAAYImQsVEwBZAQALAAYImQsVEwBZAQAsAAQKfzAAAgsACAgADXc3AIcBAAsACAgADXc3AIcBAAAA.',['圣影']='圣影丶風行者:BAABLAAECn8UAAIIAAYIeBykmgDAAQAIAAYIeBykmgDAAQAAAA==.',['天下']='天下行走:BAAALAAFFAIIAgAAAA==.',['天狼']='天狼之愿:BAAALAAFFAEIAQABLAAFFAYIHgABAHsYAA==.',['天降']='天降正義:BAAALAAECgMIBgAAAA==.',['奥莱']='奥莱恩丶冰蹄:BAACLAAFFH8NAAIIAAIIPA/eUACRAAAIAAIIPA/eUACRAAAsAAQKfyAAAggABwinFn6MANYBAAgABwinFn6MANYBAAEsAAUUCAgBAAwAAAAA.',['好看']='好看没用处:BAAALAADCggIDgAAAA==.',['寶坧']='寶坧哆哆:BAAALAADCgIIAgAAAA==.',['小小']='小小德丶:BAAALAADCggICAAAAA==.',['幻影']='幻影刀锋:BAAALAAECgYIDAAAAA==.',['幻樱']='幻樱:BAAALAAECgMIAwAAAA==.',['得加']='得加钱:BAAALAAECggIEwAAAA==.',['御前']='御前带宠侍卫:BAAALAAECgQIBAAAAA==.',['微笑']='微笑的力量丿:BAAALAADCgIIAgAAAA==.',['心中']='心中有猛虎丶:BAAALAADCgQIBAAAAA==.',['怒放']='怒放的呱呱牛:BAABLAAFFH8GAAIDAAIILwdfYgBeAAADAAIILwdfYgBeAAAAAA==.怒放的少卿:BAAALAAFFAIIAgAAAA==.怒放的波涛:BAABLAAFFH8IAAIIAAIIXQpwWACJAAAIAAIIXQpwWACJAAAAAA==.怒放的鲜血:BAABLAAFFH8HAAIDAAIIuBqjSACNAAADAAIIuBqjSACNAAAAAA==.',['悟禅']='悟禅心:BAABLAAFFH8QAAINAAMIohAcCABmAAANAAMIohAcCABmAAAAAA==.',['投降']='投降输一半:BAAALAAFFAIIBAAAAA==.',['掭柢']='掭柢芴亟:BAAALAAFFAIIAgAAAA==.',['旧日']='旧日重现:BAACLAAFFH8PAAMOAAUIthsTBwC2AAABAAQIZBi7PwD3AAAOAAMI1BwTBwC2AAAsAAQKfzsAAwEACAirIo0IALwCAAEACAg4Io0IALwCAA4ABggqIOU6AIABAAAA.',['明晚']='明晚出蓝波:BAAALAAFFAIIAgAAAA==.',['月雾']='月雾米拉:BAAALAAECgYICQAAAA==.',['术团']='术团子:BAABLAAFFH8JAAIBAAIIlA7PSACMAAABAAIIlA7PSACMAAAAAA==.',['沐风']='沐风清雨:BAABLAAFFH8NAAIFAAIIYgYIUQBSAAAFAAIIYgYIUQBSAAABLAAFFAYIGwACAGoeAA==.沐风空雨:BAABLAAFFH8bAAICAAYIah7oDQDqAQACAAYIah7oDQDqAQAAAA==.',['治疗']='治疗之雨:BAAALAAECgUIBgAAAA==.',['沽沽']='沽沽:BAAALAAECgQIBAAAAA==.',['泉塘']='泉塘吴彦祖:BAACLAAFFH8JAAIDAAIIgg7DUwBpAAADAAIIgg7DUwBpAAAsAAQKfx8AAgMABwj3ETaDAHoBAAMABwj3ETaDAHoBAAEsAAUUBggiAA8AwhQA.',['注意']='注意仇恨:BAABLAAFFH8HAAIIAAMI4Qv3RgB+AAAIAAMI4Qv3RgB+AAAAAA==.',['洒琪']='洒琪玛:BAABLAAECn8aAAIDAAgIeRpDLgBZAgADAAgIeRpDLgBZAgAAAA==.',['浮生']='浮生如梦灬:BAAALAAFFAIIBAAAAA==.',['火猴']='火猴:BAAALAAECgYIBgAAAA==.',['灬凌']='灬凌小小:BAABLAAFFH8sAAIIAAgIUx+4AgCFAgAIAAgIUx+4AgCFAgAAAA==.',['炫光']='炫光:BAAALAAECgYIBgAAAA==.',['烂狗']='烂狗:BAAALAAFFAIIAgAAAA==.',['熊喵']='熊喵舞生:BAAALAAECgUIBQAAAA==.',['燕子']='燕子十三:BAAALAAFFAIIBAAAAA==.',['爱小']='爱小翠:BAABLAAFFH8QAAIHAAYIvBcYKgCMAQAHAAYIvBcYKgCMAQAAAA==.',['狼小']='狼小灬灵:BAABLAAFFH8eAAMBAAYIexiBIQCWAQABAAYICReBIQCWAQAOAAEI0yPfIABmAAAAAA==.',['猎团']='猎团子:BAABLAAFFH8FAAIHAAIIJw24owA9AAAHAAIIJw24owA9AAAAAA==.',['电力']='电力巷弯鲨:BAAALAAECgUIBQAAAA==.',['痛苦']='痛苦无常:BAACLAAFFH8XAAIBAAUIVRQlJQD5AAABAAUIVRQlJQD5AAAsAAQKfxgAAgEABwiBH3o6AFACAAEABwiBH3o6AFACAAAA.',['盤古']='盤古開天:BAAALAAECgYIBgAAAA==.',['睡不']='睡不着丷:BAAALAAECgYIDAAAAA==.睡不醒丶:BAAALAAECgMIAwAAAA==.',['科学']='科学鉴定专家:BAAALAAECgQIBAAAAA==.',['绝命']='绝命:BAAALAAECgYICAAAAA==.',['续写']='续写:BAAALAAECgYIBgAAAA==.',['群主']='群主战一下:BAAALAAECggICAABLAAFFAgIOAACAHgjAA==.群主演一下:BAAALAAECggICAAAAA==.',['良晴']='良晴:BAACLAAFFH8kAAILAAYICAxOEgBlAQALAAYICAxOEgBlAQAsAAQKfxkAAgsACAgGCTE8AHABAAsACAgGCTE8AHABAAAA.',['艾克']='艾克斯贰零诶:BAAALAAFFAIIAgAAAA==.',['花妖']='花妖丶:BAAALAADCgcIBwAAAA==.',['芷逸']='芷逸花花:BAAALAAFFAEIAQAAAA==.',['莫方']='莫方有我:BAACLAAFFH8UAAILAAQI0wiyEwDBAAALAAQI0wiyEwDBAAAsAAQKfyEAAgsACAiKC2M7AHQBAAsACAiKC2M7AHQBAAAA.',['莱戈']='莱戈拉斯:BAAALAAECgYIBwAAAA==.',['萌德']='萌德:BAAALAAECgYIDgAAAA==.',['蓝夜']='蓝夜凊音:BAAALAAECgYIBwAAAA==.',['蓝调']='蓝调嘻哈:BAAALAAFFAQIAgAAAA==.',['薇诺']='薇诺娜瑞德:BAAALAAECgEIAQAAAA==.',['蛋壳']='蛋壳:BAAALAAFFAIIAgAAAA==.',['蜜三']='蜜三刀:BAABLAAFFH8JAAIDAAMI7BEvQwB8AAADAAMI7BEvQwB8AAAAAA==.',['術影']='術影丶風行者:BAAALAAECgYICQAAAA==.',['贞糙']='贞糙换真钞:BAAALAAECgIIAgAAAA==.',['贾罗']='贾罗娜:BAAALAADCgQIBAAAAA==.',['迪迪']='迪迪胃胃:BAABLAAFFH8HAAIDAAII/hA3TABvAAADAAII/hA3TABvAAAAAA==.',['達拉']='達拉然光輝:BAAALAAFFAIIAgAAAA==.',['那雾']='那雾萝守护者:BAAALAADCggICAAAAA==.',['邪血']='邪血:BAAALAAECgYICwAAAA==.',['郁闷']='郁闷之际:BAAALAADCgYIBgAAAA==.',['鐡血']='鐡血:BAACLAAFFH8GAAICAAII+AcpRACHAAACAAII+AcpRACHAAAsAAQKfxQAAgIABgjfEUdRACIBAAIABgjfEUdRACIBAAAA.',['长白']='长白山:BAAALAADCgMIAwAAAA==.',['长腿']='长腿和薯片:BAAALAAECgUIBQAAAA==.',['阿珥']='阿珥沙丝:BAABLAAECn8VAAIJAAcICArGGwEdAQAJAAcICArGGwEdAQAAAA==.',['阿零']='阿零:BAAALAAECggICAAAAA==.',['隔壁']='隔壁家的孩子:BAABLAAECn8hAAICAAgIhxTwLgCeAQACAAgIhxTwLgCeAQAAAA==.',['隨風']='隨風潛入夜:BAAALAAECgMIAwAAAA==.',['雪琳']='雪琳猎手:BAABLAAFFH8IAAIHAAYI7wK5cQB9AAAHAAYI7wK5cQB9AAAAAA==.',['风之']='风之旅人:BAAALAAECgYICAAAAA==.',['风行']='风行者丷星:BAAALAAECgYIDAAAAA==.',['鲜血']='鲜血与废土:BAAALAAECgUIBQAAAA==.',['黑渊']='黑渊白花:BAAALAAFFAIIAgAAAA==.',['龙族']='龙族丿猛少:BAAALAAFFAIIAwAAAA==.龙族丿秃少:BAABLAAFFH8GAAICAAIIChitLACiAAACAAIIChitLACiAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end