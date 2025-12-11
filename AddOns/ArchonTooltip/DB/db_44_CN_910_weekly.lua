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
 local lookup = {'DeathKnight-Frost','Paladin-Retribution','Shaman-Elemental','Monk-Brewmaster','Warrior-Fury','Paladin-Holy','Mage-Frost','Mage-Arcane','Warrior-Protection','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood',}; local provider = {region='CN',realm='沃金',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bi='Bigbadwolf:BAABLAAFFH8WAAIBAAUIRQY4TgDvAAABAAUIRQY4TgDvAAAAAA==.',Cl='Clearbliss:BAAALAAECgUIAwAAAA==.',Fi='Firstsonw:BAAALAAECgYIBgAAAA==.',Ho='Holyhoof:BAACLAAFFH8IAAICAAIIbxYcPAChAAACAAIIbxYcPAChAAAsAAQKfxsAAgIABwixHJBtAA4CAAIABwixHJBtAA4CAAAA.',Lv='Lvcheng:BAAALAAECgEIAQAAAA==.',Sa='Sam:BAAALAAECgEIAQAAAA==.',['七宗']='七宗:BAAALAAECgUIBQAAAA==.',['不想']='不想起名:BAAALAAFFAEIAQAAAA==.',['丨笑']='丨笑熬浆糊丶:BAAALAADCgUIBQAAAA==.',['主是']='主是硬:BAAALAAECgcIBwAAAA==.',['你的']='你的盐我的醋:BAAALAADCgcIBwAAAA==.',['元素']='元素小黑:BAABLAAFFH8GAAIDAAIIRBm7IwChAAADAAIIRBm7IwChAAAAAA==.',['克尔']='克尔苏减德:BAAALAADCgYIBgAAAA==.',['八二']='八二年的冰糖:BAAALAAECgIIAgAAAA==.八二年的拉沸:BAAALAAECgYIBgAAAA==.八二年的牛奶:BAAALAAECgQIBAAAAA==.八二年的老抽:BAAALAAECgYIBgAAAA==.八二年的陈酿:BAAALAADCgMIAwAAAA==.八二年萝卜:BAAALAAFFAIIAgAAAA==.八二年黄瓜:BAAALAAFFAIIAgAAAA==.',['兰爱']='兰爱而不得:BAAALAADCgYIBgAAAA==.',['剑梦']='剑梦残阳:BAACLAAFFH8LAAIEAAMI+RKjGQB7AAAEAAMI+RKjGQB7AAAsAAQKfx0AAgQACAgYHQkFAEUCAAQACAgYHQkFAEUCAAEsAAUUBggSAAIAdxwA.',['勇不']='勇不为怒:BAAALAADCgEIAQAAAA==.',['古尔']='古尔蛋:BAAALAADCgMIAwAAAA==.',['叽里']='叽里咕噜:BAAALAADCgQIBAAAAA==.',['咫尺']='咫尺毒奶:BAAALAAECggICwAAAA==.',['地狱']='地狱弑魂:BAABLAAFFH8KAAICAAMIihwkPQCgAAACAAMIihwkPQCgAAAAAA==.',['地稔']='地稔根:BAABLAAFFH8GAAIFAAYILBRVBwAfAgAFAAYILBRVBwAfAgAAAA==.',['墨攻']='墨攻:BAAALAAECggIAgAAAA==.',['墨白']='墨白:BAABLAAFFH8JAAIGAAYIYRlMCgDiAQAGAAYIYRlMCgDiAQAAAA==.',['大贝']='大贝勒:BAAALAAFFAIIAgAAAA==.',['大飘']='大飘飘亮:BAAALAAECgMIAwAAAA==.',['奶的']='奶的奶的:BAAALAAECgMIAwAAAA==.',['季爱']='季爱莎趴过嚰:BAAALAADCggICAAAAA==.',['小天']='小天狼星:BAABLAAFFH8HAAMHAAMIZAgXDwBuAAAHAAMIZAgXDwBuAAAIAAII9AaYZABsAAAAAA==.',['屈黑']='屈黑:BAAALAAFFAYIAgAAAA==.',['帅得']='帅得想自刎:BAAALAAECgQIBAAAAA==.',['帅的']='帅的被人砍:BAABLAAFFH8RAAIIAAMIUxVqRgCJAAAIAAMIUxVqRgCJAAAAAA==.',['希希']='希希:BAAALAADCgIIAgAAAA==.',['悖瑞']='悖瑞安:BAAALAAECgIIAgAAAA==.',['戴佳']='戴佳伟菜比:BAAALAAECgYIBgAAAA==.',['松下']='松下纱栄子:BAAALAAECggIBgAAAA==.',['橙兮']='橙兮美式:BAABLAAFFH8GAAIIAAYIAxYyDgD2AQAIAAYIAxYyDgD2AQAAAA==.',['比达']='比达尔的尊严:BAAALAAECgEIAQAAAA==.',['水心']='水心云影:BAAALAAECgYIDAAAAA==.',['沙苑']='沙苑子:BAABLAAFFH8GAAIFAAYIoQ+RCQD6AQAFAAYIoQ+RCQD6AQAAAA==.',['泽泽']='泽泽本泽:BAAALAADCgYIBgAAAA==.',['洛神']='洛神丶:BAABLAAFFH8NAAIIAAcIlB37DgAFAgAIAAcIlB37DgAFAgAAAA==.',['灬朦']='灬朦朦拳:BAAALAAFFAIIBAAAAA==.',['灵武']='灵武:BAABLAAFFH8GAAIBAAYIAA+dMwBuAQABAAYIAA+dMwBuAQAAAA==.',['炼天']='炼天魔尊:BAAALAADCgIIAgAAAA==.',['烈龙']='烈龙咯:BAAALAADCggICwAAAA==.',['牛掰']='牛掰:BAAALAAFFAIIAgAAAA==.',['独孤']='独孤龍:BAAALAAECgYIBgAAAA==.',['猛牛']='猛牛丨乳液:BAABLAAECn8dAAIGAAgISh6WCwDDAgAGAAgISh6WCwDDAgAAAA==.',['玩玩']='玩玩:BAAALAAECgYICAAAAA==.',['瓜皮']='瓜皮龙:BAAALAAFFAgIAQAAAA==.',['电击']='电击杨永信:BAABLAAFFH8GAAIDAAIIvRFKQwBGAAADAAIIvRFKQwBGAAAAAA==.',['皮皮']='皮皮猪:BAAALAAECgYIBgAAAA==.',['瞬恒']='瞬恒二:BAABLAAFFH8MAAIBAAYIIxB/NQBnAQABAAYIIxB/NQBnAQAAAA==.',['神圣']='神圣木木:BAAALAAECgIIAgAAAA==.',['神秘']='神秘的橘子:BAAALAADCggICAAAAA==.',['福利']='福利来一波:BAAALAAECgQIBQAAAA==.',['究极']='究极阿鱼:BAAALAAECgQIBAAAAA==.',['紫苏']='紫苏叶:BAABLAAFFH8IAAIFAAYI5RLcHgB0AQAFAAYI5RLcHgB0AQAAAA==.',['老狗']='老狗战壹:BAABLAAFFH8YAAIFAAgItR6sBACWAgAFAAgItR6sBACWAgAAAA==.',['肝硬']='肝硬化:BAABLAAFFH8GAAIJAAYIrBb8DwBPAQAJAAYIrBb8DwBPAQAAAA==.',['胧月']='胧月:BAAALAADCgUIBgAAAA==.',['自由']='自由的鱼鱼儿:BAAALAAECggICQAAAA==.',['艾尔']='艾尔的战神:BAABLAAFFH8FAAIFAAIImw6GNwCXAAAFAAIImw6GNwCXAAAAAA==.艾尔的牧杖:BAAALAADCgMIAwAAAA==.',['莫高']='莫高雷贾宝玉:BAAALAADCgIIAgAAAA==.',['蓝色']='蓝色星空:BAABLAAECn8XAAIBAAgIsBqJSQBoAgABAAgIsBqJSQBoAgAAAA==.',['觅长']='觅长生:BAAALAAECgIIAgAAAA==.',['豆豆']='豆豆:BAAALAAECgIIAgAAAA==.',['豌豆']='豌豆射手:BAAALAAECgYIDgAAAA==.',['贝勒']='贝勒哥:BAAALAAECgMIAwAAAA==.',['遥遥']='遥遥领先:BAAALAAECgYIDgAAAA==.',['醉美']='醉美亭城:BAAALAAFFAIIAgAAAA==.',['野马']='野马不羁:BAACLAAFFH8uAAMKAAYI5RpVJwCWAQAKAAYI5RpVJwCWAQALAAQIbw7oDQANAQAsAAQKf0IAAwsACAj0IFgUAMECAAsACAgpH1gUAMECAAoACAgMG0FWADECAAAA.',['阿帝']='阿帝阳:BAAALAAECggIBgAAAA==.',['阿比']='阿比迪斯:BAABLAAFFH8SAAMBAAYIrBzbHwC2AQABAAYIrBzbHwC2AQAMAAIICwr6GgA1AAAAAA==.',['雪雪']='雪雪盈:BAAALAAECgMIBAAAAA==.',['马克']='马克吐瘟:BAAALAAECgYIBgAAAA==.',['马可']='马可:BAABLAAFFH8FAAIBAAIInxm/SgClAAABAAIInxm/SgClAAAAAA==.',['骡子']='骡子车:BAAALAAECgYIDAAAAA==.',['高冷']='高冷美少女:BAAALAAECgcIBwAAAA==.',['麦克']='麦克:BAAALAAFFAIIAgAAAA==.',['龙骨']='龙骨复仇者:BAAALAADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end