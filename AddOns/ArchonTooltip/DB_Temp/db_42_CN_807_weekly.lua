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
 local lookup = {'Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Paladin-Retribution','Mage-Arcane','Mage-Frost','Druid-Balance','Unknown-Unknown','Priest-Discipline','Mage-Fire','Warrior-Fury','Paladin-Protection','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Shaman-Enhancement','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','Monk-Windwalker','Druid-Restoration',}; local provider = {region='CN',realm='范克里夫',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aixleft:BAAAKgAFFAMIAwABKgAFFAMICwABAPIWAA==.',Ch='Chloe:BAAAKgAECggIDwAAAA==.',Cr='Creep:BAABKgAFFH8LAAMCAAMIXxuRMQCpAAACAAII8RmRMQCpAAADAAIItR05PgClAAAAAA==.',Fr='Frigga:BAABKgAFFH8LAAIBAAMI8hZLIADGAAABAAMI8hZLIADGAAAAAA==.',Gn='Gnosklis:BAABKgAFFH8GAAMEAAYIMwsMCwD4AAAEAAUI5wYMCwD4AAAFAAEIUQYzjgA1AAAAAA==.',Id='Idol:BAAAKgAFFAMIAwABKgAFFAMICwABAPIWAA==.',Lo='Loki:BAABKgAFFH8EAAMGAAIIZxvALwClAAAGAAIIYxvALwClAAAHAAEI6BidKQBFAAABKgAFFAMICwABAPIWAA==.Lokii:BAAAKgAECgQIBAABKgAFFAMICwABAPIWAA==.',Tw='Twinmirror:BAAAKgAECgMIAwAAAA==.',Wa='Wahaha:BAAAKgAECgYICQAAAA==.',Zh='Zhima:BAAAKgAECgYIBgAAAA==.',['下鸭']='下鸭矢二郎:BAAAKgAECgMIAwAAAA==.',['丶橙']='丶橙子:BAAAKgADCgEIAQAAAA==.',['丷曾']='丷曾经回忆丷:BAABKgAFFH8IAAIIAAgIbBZCBwAwAgAIAAgIbBZCBwAwAgAAAA==.',['九宝']='九宝茶:BAAAKgADCgIIAgAAAA==.',['以战']='以战为名:BAAAKgAFFAQIBAABKgAFFAgIAgAJAAAAAA==.',['元气']='元气小姨妈:BAABKgAFFH8IAAIKAAgIlxMdBAAPAgAKAAgIlxMdBAAPAgAAAA==.',['公务']='公务牛:BAAAKgAECgQIBAAAAA==.',['卡卡']='卡卡赞:BAAAKgAECgIIAwAAAA==.',['卡迪']='卡迪娜:BAABKgAFFH8KAAMHAAcIzBJOBwDzAAAHAAQI8RtOBwDzAAALAAMIpwltGgDVAAAAAA==.',['叟嗖']='叟嗖嗖:BAAAKgAFFAgIAwAAAA==.',['哥哥']='哥哥很安逸:BAAAKgAFFAQIBAAAAA==.哥哥很按全:BAAAKgAECgUICwAAAA==.',['唐晓']='唐晓莲:BAAAKgAECggICAAAAA==.',['嘿哈']='嘿哈:BAAAKgADCgYIBgAAAA==.',['圆角']='圆角:BAAAKgADCgcIBwAAAA==.',['地精']='地精难民:BAAAKgADCgIIAgAAAA==.',['大少']='大少:BAAAKgAECggIDgAAAA==.',['天空']='天空:BAAAKgAECggIDwAAAA==.',['奈菏']='奈菏桥:BAABKgAFFH8GAAIMAAYIEhPfDgBmAQAMAAYIEhPfDgBmAQAAAA==.',['奎尔']='奎尔丹尼:BAAAKgAECgUIBQAAAA==.',['女朋']='女朋友:BAAAKgADCggICAAAAA==.',['奶嘴']='奶嘴:BAAAKgAECgcICAAAAA==.',['完美']='完美射击:BAAAKgADCggICAAAAA==.',['寒影']='寒影:BAAAKgAECgYIBwAAAA==.',['小皮']='小皮雁子:BAAAKgADCggICAAAAA==.',['小豆']='小豆豆:BAAAKgADCgcIBwAAAA==.',['尹道']='尹道锦丶:BAAAKgAFFAYIAgAAAA==.',['山下']='山下白鬼:BAACKgAFFH8ZAAMCAAQIERwGIgDqAAACAAQIERwGIgDqAAADAAIIRwgfUAA2AAAqAAQKfx0AAwIACAjuIg0QAHoCAAIACAjuIg0QAHoCAAMABQh1DreiAOEAAAAA.',['左仙']='左仙童:BAAAKgADCgYIBgAAAA==.',['希望']='希望:BAABKgAECn8UAAQFAAgI4hFxjAB+AQAFAAcIthNxjAB+AQANAAcI7g/aKAAPAQAEAAEI2gbtVwAjAAAAAA==.',['帕尔']='帕尔费年科:BAAAKgADCggICAAAAA==.',['幽梦']='幽梦:BAAAKgAECggICQAAAA==.',['悠悠']='悠悠公主驾到:BAAAKgADCgIIAgAAAA==.',['惊鸿']='惊鸿:BAABKgAECn8dAAMKAAgI/BenDgBWAQABAAgIGxJNLgCLAQAKAAcI2xanDgBWAQAAAA==.',['我比']='我比暗影面具:BAAAKgAECgEIAQAAAA==.',['我要']='我要拉臭粑:BAAAKgAECgMIAwAAAA==.',['手馋']='手馋:BAAAKgADCgUIBQAAAA==.',['提里']='提里奥浩丁:BAABKgAECn8fAAMFAAgITx60MwAwAgAFAAgITx60MwAwAgANAAEIZgNWYgAGAAAAAA==.',['擾我']='擾我清:BAABKgAFFH8GAAIDAAYIfhBNFQBLAQADAAYIfhBNFQBLAQAAAA==.',['无双']='无双圣骑:BAAAKgAFFAIIAgAAAA==.',['时光']='时光:BAABKgAECn8aAAMOAAgIBRvMHgAcAgAOAAgIBRvMHgAcAgAPAAUIswwsUAC8AAAAAA==.',['旺财']='旺财神喵:BAABKgAFFH8GAAIQAAQIhwdzPwCgAAAQAAQIhwdzPwCgAAAAAA==.',['晓法']='晓法丝:BAABKgAFFH8GAAMGAAYIQglgMwCWAAAGAAQI4gdgMwCWAAALAAIIUAtQJwCEAAAAAA==.',['晓萨']='晓萨蛮:BAABKgAFFH8HAAIRAAQIGwmyFACvAAARAAQIGwmyFACvAAAAAA==.',['机佬']='机佬黄:BAAAKgAFFAMIAwAAAA==.',['杀戮']='杀戮大少:BAAAKgAECgYIBgAAAA==.杀戮小妖:BAAAKgAECgYIBwAAAA==.',['残酷']='残酷天使:BAAAKgADCggICAAAAA==.',['浮光']='浮光旧年:BAAAKgAFFAgIBAAAAA==.',['温蕾']='温蕾萨:BAAAKgAFFAUIAQAAAA==.',['游鱼']='游鱼丿:BAAAKgAECggIEQAAAA==.',['滅魂']='滅魂潇:BAAAKgAFFAMIAwAAAA==.',['熹微']='熹微:BAAAKgADCgEIAQAAAA==.',['片皮']='片皮辊花:BAAAKgAFFAQIBAAAAA==.',['牛大']='牛大至:BAAAKgAECgYICAAAAA==.',['琪亚']='琪亚娜:BAAAKgAECggICAAAAA==.',['相信']='相信:BAAAKgAFFAgIBAAAAA==.',['秃头']='秃头披风侠:BAAAKgAECggIDwAAAA==.',['第一']='第一种人:BAAAKgAECgIIAgAAAA==.',['第三']='第三种人:BAAAKgAECgIIAgAAAA==.',['粉刺']='粉刺玛修:BAACKgAFFH8PAAISAAMIXhrbEwDfAAASAAMIXhrbEwDfAAAqAAQKfyIAAhIACAiGGaEaAAICABIACAiGGaEaAAICAAAA.',['紫禁']='紫禁城:BAAAKgADCggICAAAAA==.',['絮川']='絮川:BAAAKgAECgMIAwAAAA==.',['絮烟']='絮烟:BAAAKgAECgIIAgAAAA==.',['胡不']='胡不吝:BAAAKgAECgcICQAAAA==.',['臭臭']='臭臭的:BAAAKgADCggICAAAAA==.',['艾妮']='艾妮的芭比:BAAAKgAECgIIAgAAAA==.',['英勇']='英勇:BAAAKgAECgEIAQAAAA==.',['莱戈']='莱戈拉斯丶:BAABKgAFFH8JAAICAAgIgiAEAgCmAgACAAgIgiAEAgCmAgAAAA==.',['藏起']='藏起来的猫:BAABKgAFFH8MAAMTAAgInBP+AgChAQATAAgIiRP+AgChAQAUAAIIDxKzFACFAAAAAA==.',['蛋卤']='蛋卤有兜兜我:BAAAKgAECgMIBAAAAA==.',['蜂蜜']='蜂蜜柚子茶:BAAAKgAECgQIBAAAAA==.',['赞达']='赞达拉吴彦祖:BAAAKgADCggICAAAAA==.',['边缘']='边缘猎宠:BAAAKgADCgYIBgAAAA==.',['邪云']='邪云:BAAAKgAECgcIDQAAAA==.',['醉里']='醉里梦回:BAAAKgAFFAgIBAAAAA==.',['闪雷']='闪雷:BAACKgAFFH8LAAMCAAYI2xRDFQA5AQACAAUIARlDFQA5AQADAAMIdw5bPQCnAAAqAAQKfxUAAwIACAjeHeYTADICAAIACAj8HOYTADICAAMABQhvGfV0AFUBAAAA.',['静卫']='静卫杰:BAABKgAECn8bAAMVAAgILR4+EQBfAgAVAAgILR4+EQBfAgAWAAMIVwv8UgB1AAAAAA==.',['香橙']='香橙星冰乐:BAABKgAECn8UAAMXAAgIahS4HwCfAQAXAAgIahS4HwCfAQAIAAUIkRTmewDqAAAAAA==.',['魔玲']='魔玲珑:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end