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
 local lookup = {'Mage-Arcane','Paladin-Retribution','Paladin-Protection','Priest-Shadow','DeathKnight-Frost','Shaman-Elemental','DemonHunter-Havoc','DemonHunter-Vengeance','Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Druid-Restoration','Druid-Feral','Druid-Balance','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','DeathKnight-Blood','Monk-Brewmaster','Monk-Windwalker','Shaman-Restoration','Priest-Holy','Warrior-Protection','Evoker-Augmentation',}; local provider = {region='CN',realm='塔伦米尔',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ea='Easy:BAABLAAFFH8FAAIBAAUI5wkAHABnAQABAAUI5wkAHABnAQAAAA==.',Li='Lilis:BAAALAAECgYIDgAAAA==.Liny:BAACLAAFFH8bAAICAAUIeBzQIABmAQACAAUIeBzQIABmAQAsAAQKfyQAAwIACAjRGyRJAGECAAIACAjRGyRJAGECAAMAAQj6DhFFAC8AAAAA.',Mu='Muririnzz:BAABLAAFFH8PAAIEAAYIFSCUCADJAQAEAAYIFSCUCADJAQAAAA==.',Na='Nanako:BAAALAAFFAgIAwAAAA==.',Pl='Playeretzkej:BAAALAAECgcIBwAAAA==.',Sa='Sai:BAAALAAECgYIDAAAAA==.',So='Solodance:BAAALAAECgUIBQAAAA==.',['一剑']='一剑七杀:BAABLAAFFH8FAAIFAAMIxQY7OwC7AAAFAAMIxQY7OwC7AAAAAA==.',['一勇']='一勇敢牛牛一:BAAALAADCgIIAgAAAA==.',['一支']='一支穿云箭:BAAALAAFFAIIAgAAAA==.',['佛度']='佛度有缘人:BAAALAADCgQIBAAAAA==.',['你干']='你干嘛哈哈哟:BAAALAAECgQIBQABLAAECgcIHwACABAaAA==.',['俏丽']='俏丽哇:BAABLAAFFH8IAAIGAAYI5Q0EHgBUAQAGAAYI5Q0EHgBUAQAAAA==.',['公子']='公子丿世无双:BAABLAAFFH8RAAMHAAYIQRWrHwCFAQAHAAYIQRWrHwCFAQAIAAEIBwvOFgAoAAAAAA==.',['六六']='六六大魔王:BAAALAAECgQIBwAAAA==.',['兽之']='兽之战魂:BAAALAADCgUIBQAAAA==.',['加多']='加多寳:BAAALAADCgYIBgAAAA==.',['半颗']='半颗糖丨回忆:BAAALAAECgYICAAAAA==.',['双刀']='双刀斩魂:BAAALAAECgUIBgAAAA==.',['叶伊']='叶伊莎:BAACLAAFFH8GAAMJAAIIrQzmFQBAAAAJAAIIrQzmFQBAAAAKAAII8gpWZQA7AAAsAAQKfxQAAwkABggiGyIbAP4AAAkABggiGyIbAP4AAAoABgi4D9hXAPkAAAAA.',['呼你']='呼你大熊脸:BAABLAAFFH8UAAILAAYIlhLOBwCgAQALAAYIlhLOBwCgAQAAAA==.',['哭泣']='哭泣猫猫头:BAABLAAFFH8mAAQMAAYIjxm+EQC0AQAMAAYIjxm+EQC0AQANAAUIyxZ0BQBTAQAOAAUIdA3gGgABAQAAAA==.',['嘉嘉']='嘉嘉小公主:BAACLAAFFH8PAAMPAAMIzQ2DGAB6AAAPAAMIzQ2DGAB6AAAQAAIIlgvoGgBpAAAsAAQKfxcAAxAACAizEwAWAN0BABAACAizEwAWAN0BAA8ABggkFRBEAC0BAAAA.',['嘉澍']='嘉澍:BAABLAAFFH8GAAIBAAII7hQzQACfAAABAAII7hQzQACfAAAAAA==.',['四阿']='四阿哥:BAACLAAFFH8GAAIRAAII8hP5lABDAAARAAII8hP5lABDAAAsAAQKfxQAAxEABgjJG8lsAGsBABEABghKG8lsAGsBABIABgiuDDkZAA0BAAAA.',['图图']='图图不吃鱼:BAAALAADCggICAAAAA==.',['夜色']='夜色轻浮:BAAALAAFFAIIAgAAAA==.',['夜迷']='夜迷离:BAAALAADCgIIAgAAAA==.',['大角']='大角牛:BAAALAADCgIIAgAAAA==.',['奈萨']='奈萨里奥之殇:BAACLAAFFH8LAAIRAAYIxAUYagCSAAARAAYIxAUYagCSAAAsAAQKfyUAAhEABwi9Fft0AFwBABEABwi9Fft0AFwBAAAA.',['奶德']='奶德丶:BAABLAAFFH8IAAIKAAYI+AeROgAiAQAKAAYI+AeROgAiAQAAAA==.',['妄一']='妄一:BAAALAAECgEIAQAAAA==.',['完美']='完美自在极意:BAAALAAFFAIIAgAAAA==.完美自在牛:BAACLAAFFH8OAAMRAAQIfxB3RQCeAAARAAQIfxB3RQCeAAATAAEIOgf9NwA3AAAsAAQKfyMAAxEABgiyHRWdALABABEABghyGxWdALABABMABgjDFApZAFUBAAAA.',['寒玉']='寒玉无心:BAAALAAECgYICAAAAA==.',['小希']='小希姐姐呀:BAAALAAFFAIIAgAAAA==.',['小果']='小果汁:BAAALAAECgQIBAAAAA==.',['小河']='小河啊向溪流:BAACLAAFFH8QAAMUAAUImBITEAD6AAAUAAUIAw0TEAD6AAAFAAIIFRlTYgCXAAAsAAQKfyYAAwUACAgDHBtfADgCAAUABgiaIBtfADgCABQAAghBDioqAGIAAAEsAAUUBggpABUAOBsA.',['尼克']='尼克儿:BAAALAADCgcICgAAAA==.',['川渝']='川渝打桩机:BAAALAAECgQIBQAAAA==.',['弹一']='弹一闪:BAACLAAFFH8pAAIVAAYIOBvBCwCKAQAVAAYIOBvBCwCKAQAsAAQKfyoAAxUABgh7HuMUABcCABUABgh7HuMUABcCABYABggMFVg0AHYBAAAA.',['彷徨']='彷徨的洛丹伦:BAAALAAFFAIIAgAAAA==.',['怨念']='怨念:BAAALAAECgQIAgAAAA==.',['我不']='我不是榴莲:BAAALAAECgYIDAAAAA==.',['打败']='打败军团:BAAALAADCgEIAQAAAA==.',['扣脚']='扣脚烧妇:BAAALAAECgYIEQAAAA==.',['抠脚']='抠脚烧妇:BAAALAADCggICAAAAA==.',['日星']='日星人:BAAALAAECgYIDAAAAA==.',['时雨']='时雨:BAACLAAFFH8QAAIBAAYISwyTNAAsAQABAAYISwyTNAAsAQAsAAQKfxsAAgEABgg+HlEoAHwBAAEABgg+HlEoAHwBAAAA.',['明天']='明天星期一:BAAALAAECgMIAwAAAA==.明天星期二:BAAALAAECgQIBAAAAA==.',['术之']='术之战魂:BAAALAADCgIIAgAAAA==.',['棉布']='棉布先生:BAAALAAECgEIAQAAAA==.',['死亡']='死亡沉醉:BAAALAAFFAIIAgAAAA==.',['汪汪']='汪汪队上大分:BAABLAAFFH8TAAMGAAYIaR6zDwDGAQAGAAYIaR6zDwDGAQAXAAIInRQwWQBpAAAAAA==.',['沈幼']='沈幼楚:BAABLAAFFH8WAAMYAAYItwsqIwArAQAYAAUIugwqIwArAQAEAAYIfgKxGwDCAAAAAA==.',['火花']='火花骑士:BAABLAAECn8fAAICAAcIEBpDLgDbAQACAAcIEBpDLgDbAQAAAA==.',['火辣']='火辣俏老头:BAAALAAFFAIIBAAAAA==.',['灭灭']='灭灭赶紧灭:BAABLAAFFH8bAAIRAAYIdRnMKQCPAQARAAYIdRnMKQCPAQABLAAFFAYIJgAFABAgAA==.',['炽炎']='炽炎冰魔:BAAALAADCggICgAAAA==.',['牛之']='牛之战魂:BAAALAADCgQIBAAAAA==.',['牛肉']='牛肉拉面:BAABLAAECn8aAAIRAAYIvxfDlAAqAQARAAYIvxfDlAAqAQABLAAFFAYIKQAVADgbAA==.',['狂放']='狂放骚年:BAAALAADCgMIAwAAAA==.',['狂野']='狂野大猛狼:BAABLAAFFH8mAAIFAAYIECD3FgDhAQAFAAYIECD3FgDhAQAAAA==.',['独钓']='独钓寒江雪:BAAALAAFFAIIBAABLAAFFAYIOQAIAMUDAA==.',['琴吹']='琴吹紬:BAABLAAFFH8GAAIBAAYIDyKKHgCfAQABAAYIDyKKHgCfAQABLAAFFAgIQQABAF0kAA==.',['米血']='米血尔:BAAALAAECgQIBAAAAA==.',['粉爪']='粉爪布偶猫:BAABLAAFFH8cAAMCAAYI5yGgBwAQAgACAAYIsCCgBwAQAgADAAUI9xaoCAAyAQABLAAFFAYIJgAFABAgAA==.',['紫菜']='紫菜苔丶:BAAALAAECgYIBgAAAA==.',['纯白']='纯白之恋:BAAALAADCgEIAQAAAA==.',['肉钩']='肉钩:BAAALAAECgYIEQAAAA==.',['英雄']='英雄哥丶:BAAALAAECgMIBgAAAA==.',['萨厶']='萨厶给:BAAALAAECgcIBwAAAA==.',['薯条']='薯条:BAAALAAECgQIBAAAAA==.',['角豆']='角豆士:BAAALAAFFAIIAgAAAA==.',['诡一']='诡一:BAAALAAFFAIIAgAAAA==.',['说你']='说你个子小呢:BAABLAAFFH8IAAIGAAYI0QHHLQDOAAAGAAYI0QHHLQDOAAAAAA==.',['谢老']='谢老佛爷赐刀:BAAALAAECgYIDgABLAAFFAYIKQAVADgbAA==.',['超级']='超级猪猪侠:BAABLAAFFH8cAAIZAAYIkh+MBwDPAQAZAAYIkh+MBwDPAQABLAAFFAYIJgAFABAgAA==.',['辣妹']='辣妹:BAABLAAFFH8OAAIFAAYIQhj/HwC3AQAFAAYIQhj/HwC3AQAAAA==.',['重度']='重度失眠患者:BAAALAADCgQIBAAAAA==.',['销魂']='销魂颯:BAAALAAECgcIBwAAAA==.',['镜流']='镜流灬:BAAALAAFFAYIAgAAAA==.',['阿格']='阿格娜:BAAALAAECgYIEwABLAAFFAYIKQAVADgbAA==.',['飞沙']='飞沙风中转:BAAALAADCgIIAgAAAA==.',['鹿奈']='鹿奈:BAAALAAECgMIAwAAAA==.',['龙了']='龙了:BAABLAAFFH8HAAIaAAUIwgWVCQDkAAAaAAUIwgWVCQDkAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end