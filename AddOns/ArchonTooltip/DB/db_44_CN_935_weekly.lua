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
 local lookup = {'Unknown-Unknown','Druid-Guardian','Druid-Restoration','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Evoker-Preservation','Hunter-BeastMastery','Evoker-Augmentation','Paladin-Holy','DemonHunter-Havoc','Mage-Arcane','DeathKnight-Frost','Warrior-Protection','Paladin-Retribution','Priest-Shadow','DeathKnight-Blood','Priest-Holy','Mage-Frost','Monk-Brewmaster','Rogue-Assassination','DeathKnight-Unholy','Druid-Feral','Rogue-Subtlety','Warrior-Fury','Warlock-Demonology','Monk-Mistweaver','Warlock-Destruction','Hunter-Marksmanship',}; local provider = {region='CN',realm='辛达苟萨',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ae='Aewintero:BAAALAAECgEIAQABLAAFFAIIAgABAAAAAA==.',Ca='Cafeprincess:BAAALAADCgYIBgAAAA==.',Ga='Garroshh:BAAALAAECgQIBAAAAA==.',Ic='Icbkcnbj:BAAALAAECggICAAAAA==.',Is='Is:BAABLAAFFH8GAAICAAII1xeLBwB3AAACAAII1xeLBwB3AAAAAA==.',Jo='Jojo:BAABLAAECn8aAAMDAAcInRrFNQAIAgADAAcInRrFNQAIAgAEAAYICRw9TwB4AQAAAA==.',Ma='Maqnilie:BAACLAAFFH8WAAIFAAYItxjdFgCIAQAFAAYItxjdFgCIAQAsAAQKfxYAAgUACAj+EH9IAOQBAAUACAj+EH9IAOQBAAAA.',Me='Memoryfan:BAABLAAECn8VAAIGAAYIHyVHEgBiAgAGAAYIHyVHEgBiAgABLAAFFAYIKAAHACMlAA==.',Mi='Miku:BAAALAAECgUIBQABLAAFFAgIEgAIAM0MAA==.',My='Myrathon:BAAALAADCgEIAQAAAA==.',Na='Nanako:BAABLAAFFH8FAAIJAAII5SWaCQDjAAAJAAII5SWaCQDjAAAAAA==.',Ni='Ningg:BAAALAAFFAIIBAAAAA==.Niseko:BAAALAAECggICwABLAAFFAcIKQAIADghAA==.',No='Nomercy:BAAALAAECgYICQABLAAFFAIIAgABAAAAAA==.',Oc='Ocgg:BAABLAAFFH8LAAIKAAgIgh8/AQACAwAKAAgIgh8/AQACAwAAAA==.',Pa='Palaopo:BAACLAAFFH8bAAILAAYIHyCdFwCvAQALAAYIHyCdFwCvAQAsAAQKfxUAAgsABgjyJFgdAPkBAAsABgjyJFgdAPkBAAAA.',Re='Renegadec:BAAALAAECgEIAQAAAA==.',Sa='Sacredlight:BAAALAAECgYIDgAAAA==.',Su='Sunmiz:BAABLAAFFH8IAAIMAAgIkwDYXgA9AAAMAAgIkwDYXgA9AAAAAA==.',Te='Tender:BAABLAAFFH8NAAIIAAYIhhmPIwDxAAAIAAYIhhmPIwDxAAAAAA==.Tenderr:BAAALAAECgQIBAAAAA==.',To='Tomori:BAABLAAFFH8JAAINAAMINx2+QwCtAAANAAMINx2+QwCtAAAAAA==.',Va='Vanellope:BAAALAAFFAIIAgAAAA==.',Vi='Vincentia:BAABLAAFFH8aAAIKAAgIJR/BAQDcAgAKAAgIJR/BAQDcAgAAAA==.',Yo='Yoya:BAABLAAFFH8KAAIOAAMIhQ7QEQC/AAAOAAMIhQ7QEQC/AAAAAA==.',['一位']='一位奶萨:BAABLAAECn8XAAIFAAgIxyVqDAArAwAFAAgIxyVqDAArAwAAAA==.',['一妖']='一妖妖:BAABLAAFFH8JAAIPAAIIMCBlJADCAAAPAAIIMCBlJADCAAAAAA==.',['七七']='七七丶打怪兽:BAAALAAECgYIBgAAAA==.',['不朽']='不朽威仪:BAAALAAFFAIIAgAAAA==.',['不给']='不给糖就捣蛋:BAAALAAECgYIBgAAAA==.',['世界']='世界需要我:BAAALAAECgUIBQABLAAFFAYIFAAGAMAMAA==.',['丰川']='丰川祥紫:BAABLAAFFH8MAAIQAAYIjRb5DACMAQAQAAYIjRb5DACMAQAAAA==.',['人生']='人生就是拌面:BAAALAAECgYIBwABLAAFFAcIGAALAHQgAA==.',['代号']='代号大本钟:BAAALAADCggICQAAAA==.',['你也']='你也想起舞吗:BAAALAAFFAIIBAABLAAFFAgIGQAEAOoQAA==.',['你眼']='你眼中的泪:BAABLAAFFH8IAAIDAAIIGAr5SwBaAAADAAIIGAr5SwBaAAAAAA==.',['倔强']='倔强的驴丶:BAABLAAFFH8FAAIHAAUIPRgADACQAQAHAAUIPRgADACQAQAAAA==.',['假装']='假装没死:BAAALAAECgQIBAAAAA==.',['傲娇']='傲娇的小公举:BAAALAAECggICAAAAA==.',['兜兜']='兜兜有糖:BAAALAAECgYIBgAAAA==.',['兰德']='兰德索尔火刃:BAABLAAFFH8FAAIRAAUIEgP4BwAgAQARAAUIEgP4BwAgAQAAAA==.',['冒险']='冒险的猫:BAABLAAFFH8GAAISAAYIyh0jDgD0AQASAAYIyh0jDgD0AQAAAA==.',['冲冲']='冲冲钅:BAAALAAECgYIBgAAAA==.',['冷月']='冷月丶雪飘:BAAALAADCgQIBAAAAA==.',['冷籁']='冷籁:BAAALAAECgYICQAAAA==.',['剑心']='剑心犹在:BAABLAAFFH8JAAIOAAIITAnMLQBfAAAOAAIITAnMLQBfAAAAAA==.',['剑斩']='剑斩长生:BAABLAAFFH8IAAILAAIIlRjjLwCqAAALAAIIlRjjLwCqAAAAAA==.',['十阶']='十阶浮屠:BAAALAAECgYICAAAAA==.',['半边']='半边魔:BAAALAADCgQIBgAAAA==.',['双魚']='双魚理:BAABLAAFFH8oAAMMAAgI7CF0BACrAgAMAAgIjyB0BACrAgATAAIIHyPyDwBjAAAAAA==.',['古户']='古户艾莉卡:BAAALAAECgYIBgAAAA==.',['可爱']='可爱没脑袋:BAAALAAFFAQIBAAAAA==.',['可璐']='可璐希尔:BAABLAAFFH8SAAIQAAYI9BVQDQCIAQAQAAYI9BVQDQCIAQAAAA==.',['可露']='可露儿:BAABLAAFFH8kAAMQAAYIiBpLCgCmAQAQAAYIiBpLCgCmAQASAAIIHQjOTQBDAAAAAA==.',['吃多']='吃多了:BAABLAAECn8fAAIMAAgIaQ41LQBkAQAMAAgIaQ41LQBkAQAAAA==.',['各有']='各有锦时:BAAALAAECgMIBAAAAA==.',['喵皇']='喵皇后:BAAALAADCgcIBwAAAA==.',['国庆']='国庆快乐菇:BAABLAAFFH8MAAIGAAYIbh5+DAAOAgAGAAYIbh5+DAAOAgAAAA==.',['圆滚']='圆滚滚飞起来:BAACLAAFFH8JAAIUAAMIMgk/EQCdAAAUAAMIMgk/EQCdAAAsAAQKfxcAAhQACAjyGHUQAFMCABQACAjyGHUQAFMCAAAA.',['圆灬']='圆灬:BAABLAAFFH8QAAILAAYIggv8JQBiAQALAAYIggv8JQBiAQAAAA==.',['圣光']='圣光三里:BAAALAAECggIAQAAAA==.圣光小女孩:BAAALAAECgIIAgAAAA==.圣光萨尓:BAABLAAFFH8YAAIPAAYIORT8DACQAQAPAAYIORT8DACQAQAAAA==.',['基定']='基定尤拉:BAAALAAFFAIIAgAAAA==.',['基尔']='基尔酒丶:BAABLAAFFH8IAAIVAAgIDBieAgBcAgAVAAgIDBieAgBcAgAAAA==.',['墨圣']='墨圣仁:BAAALAAECgYIDwAAAA==.',['墨墨']='墨墨猫:BAAALAAECgYIDQAAAA==.',['夜神']='夜神月丨思语:BAAALAAFFAIIBAAAAA==.',['夜雨']='夜雨楼:BAABLAAFFH8SAAIKAAcIDBLMCQDsAQAKAAcIDBLMCQDsAQABLAAFFAgIHQAKAEIVAA==.',['夜露']='夜露:BAABLAAFFH8JAAMQAAYInQ4vEwDpAAAQAAUIoQ8vEwDpAAASAAMIXwjMMQCkAAAAAA==.',['大地']='大地飞鸽:BAAALAAECgUIBwAAAA==.',['大师']='大师我懂了:BAABLAAFFH8GAAINAAIIURGpgQBFAAANAAIIURGpgQBFAAAAAA==.',['天之']='天之苍苍:BAAALAAECgUIBwAAAA==.天之钢:BAAALAAECgYIBgAAAA==.',['奥莉']='奥莉薇风行者:BAAALAAECgYICAAAAA==.',['奥蕾']='奥蕾利亚:BAAALAAECgMIAwAAAA==.',['女王']='女王:BAAALAAFFAIIAgAAAA==.',['她说']='她说累让我推:BAAALAAECggICQAAAA==.',['好运']='好运纷纷而来:BAAALAAECgQICQAAAA==.',['如潮']='如潮领吾归乡:BAAALAAECgYIBgAAAA==.',['娜娜']='娜娜谟:BAABLAAFFH8UAAMQAAYI0xXmBwDZAQAQAAYI0xXmBwDZAQASAAEIsgQkUAA5AAAAAA==.',['安魂']='安魂骑士:BAAALAAFFAIIBAAAAA==.',['封真']='封真:BAAALAADCgIIAgABLAAFFAUICAARAPsTAA==.',['小悦']='小悦己:BAAALAAECgYIBgAAAA==.',['小美']='小美丶:BAABLAAFFH8GAAMNAAMIIhnORwCoAAANAAIIEB3ORwCoAAAWAAEIRxH0EABRAAABLAAFFAYIDQAMAAEYAA==.',['小脑']='小脑斧大冒险:BAAALAAFFAIIAgAAAA==.',['小野']='小野猪一号:BAAALAAECgYICwAAAA==.',['崔斯']='崔斯特杜垩登:BAAALAAECgUICAAAAA==.',['巛光']='巛光之翼丯灬:BAAALAAECgMIAwAAAA==.',['巫爺']='巫爺:BAAALAAECgIIAgAAAA==.',['已经']='已经在奶啦:BAAALAAFFAIIAgAAAA==.',['帅气']='帅气丫丫:BAAALAAECgcICAAAAA==.',['平头']='平头哥:BAAALAAFFAIIBAAAAA==.',['彭于']='彭于晏:BAABLAAFFH8GAAIQAAYIRhGvDwBsAQAQAAYIRhGvDwBsAQAAAA==.',['影随']='影随行:BAAALAADCgUIBQAAAA==.',['怂泡']='怂泡泡:BAAALAAECgYIDAAAAA==.',['恨别']='恨别鸟惊心:BAAALAAECgEIAQAAAA==.',['我们']='我们压迫众生:BAABLAAFFH8XAAINAAYI+xK3LgCBAQANAAYI+xK3LgCBAQAAAA==.',['我心']='我心鹤锦:BAAALAAFFAIIBAAAAA==.',['抹布']='抹布:BAAALAADCggICAAAAA==.',['搞东']='搞东搞西:BAABLAAFFH8IAAINAAIIDAXCiQB/AAANAAIIDAXCiQB/AAAAAA==.',['撩人']='撩人乀尐姐姐:BAACLAAFFH8IAAIXAAIInRNdDQBHAAAXAAIInRNdDQBHAAAsAAQKfygAAhcABgjNGpELAIcBABcABgjNGpELAIcBAAEsAAUUCAgPAA0A4CIA.',['斯卡']='斯卡蒂:BAABLAAFFH8GAAIQAAYIYxGRDwBtAQAQAAYIYxGRDwBtAQAAAA==.',['新生']='新生:BAAALAAECgIIAgAAAA==.',['无奈']='无奈修仙:BAAALAADCgMIAwAAAA==.',['日向']='日向空蓝:BAAALAAECgIIAgAAAA==.',['昙花']='昙花壹现:BAAALAADCggICAAAAA==.',['春之']='春之玲:BAAALAAECgYIBgAAAA==.',['更深']='更深的蓝:BAABLAAFFH8GAAIIAAII8AywqgA6AAAIAAII8AywqgA6AAAAAA==.',['月下']='月下独酌:BAAALAADCgcIDgAAAA==.',['末日']='末日戰歌:BAAALAAECgUIBQAAAA==.',['李狗']='李狗蛋儿:BAAALAAECgYIDQAAAA==.',['杨永']='杨永信:BAAALAAFFAIIBAAAAA==.',['柳玉']='柳玉:BAABLAAFFH8LAAIOAAYIxQNwGgDGAAAOAAYIxQNwGgDGAAAAAA==.',['格罗']='格罗咆哮:BAAALAAECgcIDQAAAA==.',['梅琳']='梅琳娜:BAAALAADCgYIBgAAAA==.',['死翼']='死翼千歌:BAACLAAFFH8NAAMNAAUIIRdZJgAAAQANAAMIhxhZJgAAAQAWAAIICBVnCwC6AAAsAAQKfy4AAxYACAi2JA4ZAPUBABYABgiWGw4ZAPUBAA0ABQioI+WHAOwBAAAA.',['残血']='残血:BAAALAADCgcIBwAAAA==.',['毁灭']='毁灭咕:BAAALAADCggICAAAAA==.',['永夜']='永夜:BAABLAAFFH8NAAIPAAYICyJMEADFAQAPAAYICyJMEADFAQAAAA==.',['江心']='江心秋月白:BAAALAAECgYIBgAAAA==.',['海月']='海月:BAABLAAFFH8hAAMYAAYIUh0gBQCuAQAYAAYIRhwgBQCuAQAVAAUImB86CQCFAQAAAA==.',['温酒']='温酒:BAAALAAFFAEIAQAAAA==.',['源灬']='源灬:BAAALAADCgUIBQAAAA==.',['灵魂']='灵魂的兽:BAAALAAECggIDAAAAA==.',['炫彩']='炫彩皮卡吼:BAABLAAFFH8IAAIZAAIIBhafOACVAAAZAAIIBhafOACVAAAAAA==.',['烛火']='烛火:BAAALAAFFAIIAgAAAA==.',['烟火']='烟火易冷:BAAALAAECgYIDAAAAA==.',['烬语']='烬语:BAABLAAFFH8OAAIaAAIIPiU+BwDMAAAaAAIIPiU+BwDMAAAAAA==.',['熊火']='熊火火:BAAALAAFFAIIAgAAAA==.',['牧已']='牧已成舟:BAAALAAECgYICwAAAA==.',['狂风']='狂风:BAABLAAFFH8NAAIbAAIIsSNYCwDVAAAbAAIIsSNYCwDVAAAAAA==.',['獠牙']='獠牙王牌:BAABLAAFFH8GAAILAAYIKRnOBgAwAgALAAYIKRnOBgAwAgAAAA==.',['白飞']='白飞飞:BAABLAAFFH8KAAMTAAUILQtaCQDtAAATAAUILQtaCQDtAAAMAAEIZAMiaAAyAAAAAA==.',['百事']='百事小仙:BAABLAAECn8UAAIKAAYIsw2CJAAgAQAKAAYIsw2CJAAgAQAAAA==.',['皮一']='皮一糖:BAACLAAFFH8OAAIGAAQILhCAFgD/AAAGAAQILhCAFgD/AAAsAAQKfyEAAgYACAimD5F7AIoBAAYACAimD5F7AIoBAAAA.',['皮卡']='皮卡皮卡猛:BAAALAAECgYIBgAAAA==.',['皮怪']='皮怪:BAABLAAECn8XAAMcAAgIFCDkFQAyAgAcAAcIUBzkFQAyAgAaAAIIEyDNLwBeAAAAAA==.',['矮子']='矮子不矮:BAAALAAFFAEIAQAAAA==.',['碧油']='碧油鸡:BAAALAAECgQIBAAAAA==.',['神棍']='神棍芬:BAACLAAFFH8IAAISAAIIqw5tPQBwAAASAAIIqw5tPQBwAAAsAAQKfxcAAhIABgiREdAxADQBABIABgiREdAxADQBAAEsAAUUBwgMAA0AoAUA.',['空城']='空城丨旧亿:BAAALAAECgYIBgABLAAFFAgIEgAIAM0MAA==.',['空境']='空境式:BAAALAADCgEIAQAAAA==.',['第二']='第二十个小号:BAAALAAFFAIIAgAAAA==.',['绕后']='绕后紫色巴蒂:BAAALAAECgYIDQABLAAFFAIIAgABAAAAAA==.',['绫濑']='绫濑桃:BAABLAAECn8XAAIEAAgIIx92FQC5AgAEAAgIIx92FQC5AgABLAAECggIjwAdAPomAA==.',['绵扬']='绵扬:BAAALAADCgYIBgAAAA==.',['绵羊']='绵羊:BAAALAADCgMIAwAAAA==.',['缇坦']='缇坦妮雅:BAABLAAFFH8cAAMQAAYI8xw4BgACAgAQAAYI8xw4BgACAgASAAEIKw10TgBAAAAAAA==.',['缪尔']='缪尔塞斯:BAABLAAFFH8WAAIQAAYIdRcSDQCLAQAQAAYIdRcSDQCLAQAAAA==.',['罪牛']='罪牛:BAAALAAFFAIIBAAAAA==.',['羊奶']='羊奶一品钙奶:BAAALAAECggICAAAAA==.',['羽生']='羽生萌萌香:BAABLAAFFH8PAAIQAAYIeg6lEQBUAQAQAAYIeg6lEQBUAQAAAA==.',['肥红']='肥红:BAAALAAECggICAAAAA==.',['至高']='至高天:BAAALAAECgUIBQAAAA==.',['艾雅']='艾雅法柆:BAABLAAFFH8YAAIQAAYIEBX8DQCBAQAQAAYIEBX8DQCBAQAAAA==.',['芡实']='芡实:BAABLAAECn8aAAINAAYINBpEogDDAQANAAYINBpEogDDAQAAAA==.',['苏晓']='苏晓猎:BAAALAAFFAIIBAAAAA==.',['荒年']='荒年:BAAALAAFFAIIAgABLAAFFAgIFAAGAPQdAA==.',['菈尼']='菈尼:BAABLAAFFH8IAAIQAAYIwBHXDQBLAQAQAAYIwBHXDQBLAQAAAA==.',['菲亚']='菲亚梅塔:BAABLAAFFH8HAAMQAAYIjRMTFAA2AQAQAAUIFRUTFAA2AQASAAEIiQXcTwA6AAAAAA==.',['萌萌']='萌萌哒的汉堡:BAAALAAECgYIBgAAAA==.萌萌哒的菠萝:BAAALAADCggICAAAAA==.',['萝蓓']='萝蓓莉蕥:BAABLAAFFH8JAAIcAAIIhwmiTwCBAAAcAAIIhwmiTwCBAAAAAA==.萝蓓莉雅:BAAALAAECgMIAwAAAA==.',['萨勒']='萨勒芬妮:BAAALAADCgEIAQAAAA==.',['落丨']='落丨幕:BAACLAAFFH8IAAILAAIIxCBnKwC0AAALAAIIxCBnKwC0AAAsAAQKfxUAAgsABggzJUA2AIQCAAsABggzJUA2AIQCAAAA.',['薇尔']='薇尔莉特丶:BAACLAAFFH8ZAAIOAAYIegw0FQAUAQAOAAYIegw0FQAUAQAsAAQKfxoAAg4ABgj6Go0bAGUBAA4ABgj6Go0bAGUBAAEsAAUUBwgjAAgA9RYA.',['薇薇']='薇薇安娜:BAABLAAFFH8JAAIQAAYIpw0HEgBPAQAQAAYIpw0HEgBPAQAAAA==.',['薩滿']='薩滿:BAAALAADCgcIBwAAAA==.',['藤原']='藤原豆腐店:BAAALAAECgQIBgAAAA==.',['诗怀']='诗怀雅:BAABLAAFFH8YAAMQAAYI4RJCDwBxAQAQAAYI4RJCDwBxAQASAAMI7hixKgDXAAAAAA==.',['豆芽']='豆芽児:BAAALAAECgYIBgAAAA==.',['贤者']='贤者:BAAALAADCgEIAQAAAA==.',['赵日']='赵日天:BAAALAADCgUIBgAAAA==.',['轻念']='轻念:BAAALAAECggICAAAAA==.',['逃丶']='逃丶:BAAALAAECgIIAgAAAA==.',['那个']='那个萨满丶:BAABLAAFFH8nAAIKAAgIVh2fAgCqAgAKAAgIVh2fAgCqAgAAAA==.',['醉人']='醉人梦绕沁逝:BAAALAADCggICAAAAA==.',['银月']='银月:BAAALAAFFAYIBAAAAA==.',['阿威']='阿威:BAABLAAFFH8GAAIFAAII3gwfLgCNAAAFAAII3gwfLgCNAAAAAA==.',['陶矢']='陶矢:BAABLAAFFH86AAMFAAgIRSZJAAAjAwAFAAgIRSZJAAAjAwAGAAYI0R1bAgBEAgABLAAFFAgIRAAQAHgkAA==.',['隆德']='隆德贝尔:BAAALAAFFAIIAgAAAA==.',['雪夜']='雪夜长歌:BAAALAAFFAIIBAAAAA==.',['雾海']='雾海:BAAALAAECgYIBgAAAA==.',['霜华']='霜华:BAAALAAECgYIBgAAAA==.',['青珑']='青珑:BAAALAADCgcIBwAAAA==.',['飞机']='飞机:BAABLAAFFH8OAAISAAII7h6/LwCuAAASAAII7h6/LwCuAAAAAA==.',['饼丶']='饼丶焰心:BAAALAAECgYICgAAAA==.',['高压']='高压电:BAAALAAFFAIIAgAAAA==.',['魔鬼']='魔鬼肌肉德:BAAALAAECgYICgAAAA==.',['鱼骨']='鱼骨工造:BAAALAAECgUIBQAAAA==.',['麦爸']='麦爸:BAAALAAECgQICAAAAA==.',['麦辣']='麦辣鸡:BAABLAAFFH8LAAIIAAMIvhWffQBgAAAIAAMIvhWffQBgAAAAAA==.',['麻秋']='麻秋秋:BAAALAAFFAEIAQAAAA==.',['龙戦']='龙戦于野:BAABLAAFFH8IAAMWAAUIcA0hCQDgAAAWAAMIfAwhCQDgAAANAAQInQ58VADCAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end