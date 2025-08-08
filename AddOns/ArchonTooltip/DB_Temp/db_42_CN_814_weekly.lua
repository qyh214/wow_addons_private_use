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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Feral','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','Monk-Mistweaver','Mage-Arcane','Mage-Frost','Druid-Balance','Druid-Restoration','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Monk-Brewmaster','Warrior-Fury','Druid-Guardian','Hunter-Marksmanship','Priest-Discipline','Priest-Holy','Priest-Shadow','Monk-Windwalker','Rogue-Assassination','Paladin-Protection','Mage-Fire','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Hunter-BeastMastery','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Warrior-Protection','Rogue-Subtlety','Rogue-Outlaw','Warrior-Arms',}; local provider = {region='CN',realm='菲米丝',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Airhck:BAAAKgAECgQIBAAAAA==.',Am='Ambitions:BAABKgAFFH8GAAIBAAQIFCARDgAcAQABAAQIFCARDgAcAQABKgAFFAgIBAACAAAAAA==.',Bl='Bloodbless:BAAAKgAFFAQIBAAAAA==.',Br='Brutehunter:BAAAKgADCggICAAAAA==.',Da='Dababy:BAAAKgAFFAIIAgAAAA==.',De='Destroy:BAAAKgADCggICAAAAA==.',Do='Dogthing:BAAAKgAFFAgIAQAAAA==.',Fa='Fafa:BAAAKgADCgcIBwAAAA==.',Ki='Kiwi:BAAAKgAECgIIAgAAAA==.',Lu='Luckycrystal:BAAAKgAFFAgIAwAAAA==.',Me='Mediocre:BAAAKgAECggIDQAAAA==.Merciless:BAAAKgAECgYIBgAAAA==.',Mu='Much:BAAAKgAECgUIBgAAAA==.',Pe='Pearl:BAAAKgAECgIIAgAAAA==.',Ra='Raywind:BAABKgAFFH8IAAIDAAQIHBK2FgDnAAADAAQIHBK2FgDnAAAAAA==.',Wk='Wkyel:BAAAKgAECgQIBAAAAA==.',Zl='Zloveyg:BAAAKgAECggIEwAAAA==.',['一个']='一个狗两个末:BAAAKgAECgYICQAAAA==.一个这么帅:BAACKgAFFH8FAAMEAAMIrSC8CQAMAQAEAAMIayC8CQAMAQADAAEIriGmRQBlAAAqAAQKfxUAAwQACAiLI5UOADoCAAQACAiLI5UOADoCAAMAAgjJH1KDALQAAAAA.',['不愧']='不愧是我:BAAAKgAECggICAAAAA==.',['丶冷']='丶冷骨头:BAACKgAFFH8aAAIDAAgI8RyyBgA7AgADAAgI8RyyBgA7AgAqAAQKfxwAAwMACAhvI28OALMCAAMACAhvI28OALMCAAQAAQhBD+dvACUAAAAA.',['丶弄']='丶弄潮儿:BAAAKgAFFAIIAgAAAA==.',['丹妮']='丹妮莉丝:BAAAKgAECggICwAAAA==.',['为肚']='为肚为战:BAAAKgAECggICAABKgAECggIFQAFACgXAA==.',['九渊']='九渊寂无歌:BAAAKgAECggICAAAAA==.',['亂世']='亂世丶:BAAAKgAECgUIBQAAAA==.',['五晨']='五晨寺憨憨:BAAAKgAFFAMIAwAAAA==.',['五禅']='五禅烟无迹:BAAAKgADCggICAAAAA==.',['仙人']='仙人摘桃:BAAAKgAECggIDwAAAA==.',['以战']='以战死为戎:BAAAKgADCgQIBAAAAA==.',['伍叶']='伍叶丶:BAAAKgAECgMIBAAAAA==.',['低调']='低调的亲嘴:BAAAKgAECgMIBAAAAA==.',['你的']='你的名字:BAAAKgAFFAIIAgAAAA==.',['傲天']='傲天狂少:BAACKgAFFH8TAAQGAAQIzBuBCQAEAQAGAAMI1xmBCQAEAQAHAAQIdgZMPACVAAAIAAIIoxVxEgCQAAAqAAQKfy4AAwYACAjTIaMOAGMCAAYACAgyIaMOAGMCAAgABwh2HkQlAMgBAAAA.',['元让']='元让之手:BAAAKgADCgYIBgAAAA==.',['全部']='全部丢翻:BAAAKgAFFAQIBAABKgAFFAgIDgAJALAjAA==.',['六叔']='六叔开飞机:BAABKgAECn84AAMKAAgIiRk3DAATAgAKAAgIiRk3DAATAgALAAEIAACViQAAAAAAAA==.六叔跌摩托:BAACKgAFFH8PAAMMAAMIjR5JJAAHAQAMAAMIjR5JJAAHAQANAAMIyRdyCwDXAAAqAAQKfykAAwwACAgVIzMtAAoCAAwACAgVIzMtAAoCAA0AAQgME/aBAD4AAAAA.',['六眼']='六眼飞鱼:BAAAKgAECgYIDwAAAA==.',['内心']='内心的一首歌:BAAAKgAECgQIBAAAAA==.',['冷在']='冷在骨子里丶:BAAAKgAECgYICAAAAA==.',['凄灬']='凄灬丶:BAAAKgAECgUIBQAAAA==.',['几时']='几时能如愿:BAAAKgAECgYIBgAAAA==.',['凯特']='凯特骑士:BAABKgAECn8VAAIOAAcIshZDEQCUAQAOAAcIshZDEQCUAQAAAA==.',['刃舞']='刃舞清风:BAAAKgADCggICAAAAA==.',['十指']='十指问心弦:BAAAKgAECgMIAwAAAA==.',['单身']='单身勇着:BAABKgAECn8YAAMPAAcIZQo2PwDDAAAPAAcI+Qg2PwDDAAAQAAEIwBJGrwA5AAAAAA==.',['卡普']='卡普空:BAAAKgAECgYIBgAAAA==.',['卧槽']='卧槽帅狗:BAACKgAFFH8NAAIGAAUINhn9CwAMAQAGAAUINhn9CwAMAQAqAAQKfxkAAgYACAiIJf4DAN0CAAYACAiIJf4DAN0CAAEqAAUUCAgCAAIAAAAA.',['口才']='口才真有用:BAAAKgAECgQIBAAAAA==.',['只杀']='只杀不渡:BAABKgAFFH8GAAIBAAYI5xmzFwCfAQABAAYI5xmzFwCfAQAAAA==.',['召唤']='召唤光明之刃:BAAAKgAECgEIAQAAAA==.',['可以']='可以丶可以:BAACKgAFFH8vAAMJAAgI2BfrBAAJAgAJAAgI2BfrBAAJAgARAAYIaQm5AwDAAAAqAAQKfxkAAxEACAikDcARACIBABEACAikDcARACIBAAkAAghSIIRhALcAAAAA.',['可可']='可可西里里:BAAAKgAECgEIAQAAAA==.',['可牛']='可牛了:BAABKgAECn8XAAIMAAgIwR5UGgBmAgAMAAgIwR5UGgBmAgAAAA==.',['叶子']='叶子:BAAAKgAECgQIBAAAAA==.',['叶知']='叶知秋:BAABKgAFFH8RAAISAAgIORQgBQBMAgASAAgIORQgBQBMAgAAAA==.',['吕少']='吕少控球:BAAAKgAECgQIBAAAAA==.',['呆河']='呆河:BAACKgAFFH8ZAAMPAAUIqBjfCgDvAAAPAAQI+B7fCgDvAAAQAAEIuAVNIQBEAAAqAAQKfyIAAg8ACAitIQAKAIICAA8ACAitIQAKAIICAAAA.',['呜喵']='呜喵:BAACKgAFFH8eAAQTAAQInhyEAQDYAAATAAMI9ReEAQDYAAAMAAQIAhGuOgC6AAAFAAIIxhnZBACsAAAqAAQKfzEABAUACAg6IBEIAEYCAAUACAjXHxEIAEYCAAwABgh/HDZOAH4BAA0AAgjCDNNsAHAAAAAA.',['呲莮']='呲莮孓未緡:BAABKgAFFH8OAAIUAAYI7RXJCgD0AAAUAAYI7RXJCgD0AAAAAA==.',['咆哮']='咆哮斩杀者:BAAAKgAECgYIBwAAAA==.',['咔咔']='咔咔希:BAAAKgADCggICAAAAA==.',['哈利']='哈利啵特哒:BAABKgAFFH8QAAMKAAgISheOBQA7AgAKAAgISheOBQA7AgALAAQIHA5HFwC5AAAAAA==.',['哭回']='哭回童年:BAAAKgAECgQIBQAAAA==.',['喵喵']='喵喵小星:BAABKgAFFH8IAAIBAAgIbgNeEwBoAQABAAgIbgNeEwBoAQAAAA==.',['嘲渢']='嘲渢:BAAAKgAECgEIAQAAAA==.',['四时']='四时沐无心:BAACKgAFFH8VAAQVAAYIhCRqAAAvAgAVAAYIhCRqAAAvAgAWAAQIBBPEIwC1AAAXAAEIHwwlKABCAAAqAAQKfxkAAxcACAhSEi0jALwBABcACAhSEi0jALwBABYAAwgGE9hsAGsAAAAA.',['囡哒']='囡哒哆:BAAAKgAECgYICwAAAA==.',['国清']='国清寺方丈:BAAAKgAECgEIAgABKgAFFAEIAQACAAAAAA==.',['圆桌']='圆桌骑士:BAAAKgAFFAMIAwAAAA==.',['地雪']='地雪天痕之骸:BAABKgAFFH8KAAMXAAYIMiEbEADeAAAXAAII2CQbEADeAAAWAAUIpRWtLQCOAAAAAA==.',['坏小']='坏小骑:BAABKgAFFH8IAAIBAAQIgxwcSADeAAABAAQIgxwcSADeAAAAAA==.',['坐忘']='坐忘道丶:BAABKgAECn8hAAMJAAgIaRmkIwDWAQAJAAgIaRmkIwDWAQAYAAgIvheGIACaAQABKgAFFAgICAAZAMYWAA==.',['堕落']='堕落的瓦斯琦:BAAAKgAECggIDwAAAA==.',['壹个']='壹个人的天空:BAAAKgADCggICgAAAA==.',['夏沫']='夏沫浅浅:BAACKgAFFH8QAAINAAQIGxaMDwC3AAANAAQIGxaMDwC3AAAqAAQKfxYAAg0ACAg7FqYlAKABAA0ACAg7FqYlAKABAAAA.',['多恩']='多恩舞:BAAAKgAECgEIAQAAAA==.',['夜太']='夜太美:BAAAKgAECggICAAAAA==.',['大男']='大男孩:BAAAKgAECgUIBQAAAA==.',['大白']='大白兔灬奶糖:BAABKgAECn8vAAIHAAgIkBjZEADFAQAHAAgIkBjZEADFAQAAAA==.',['大耳']='大耳朵米迦勒:BAAAKgADCggICAAAAA==.',['天下']='天下我最靓:BAAAKgAECgYIBgAAAA==.',['天命']='天命:BAAAKgAFFAEIAQABKgAFFAgIBAACAAAAAA==.',['天賜']='天賜小炮:BAABKgAFFH8UAAIVAAQI/RAbGgDBAAAVAAQI/RAbGgDBAAAAAA==.',['天钧']='天钧丶:BAAAKgAECgUIBwAAAA==.',['奈何']='奈何花落去:BAABKgAFFH8IAAIHAAgIvBBuBwDSAQAHAAgIvBBuBwDSAQAAAA==.',['奥格']='奥格瑞瑪:BAAAKgAECgUIBQAAAA==.',['妥妥']='妥妥的小白牛:BAAAKgAECgUIBQAAAA==.',['孤勇']='孤勇者:BAAAKgADCggICgAAAA==.',['学长']='学长:BAACKgAFFH8aAAIaAAYIhQYXCwDaAAAaAAYIhQYXCwDaAAAqAAQKfx0AAxoACAgPC8MwANsAABoACAhrCsMwANsAAAEAAQjQFV59AEIAAAAA.学长不坏:BAABKgAFFH8XAAMMAAcImxXnEgCFAQAMAAcImxXnEgCFAQATAAQIhATjBgBfAAAAAA==.',['寒羽']='寒羽洋:BAACKgAFFH8TAAIbAAMIExlMFwDxAAAbAAMIExlMFwDxAAAqAAQKfx8AAxsACAjPHjgZAF0CABsACAjQHTgZAF0CAAsAAghHFp19AJYAAAAA.',['导演']='导演我躺哪:BAAAKgAECgUIBQAAAA==.',['射得']='射得给力:BAAAKgADCgUIBQAAAA==.',['小十']='小十:BAAAKgADCgYIBgAAAA==.',['小图']='小图腾:BAAAKgAECgMIAwAAAA==.',['小柔']='小柔柔:BAAAKgAECgcICgAAAA==.',['小法']='小法丝:BAAAKgADCgIIAgAAAA==.',['小淼']='小淼丶:BAABKgAFFH8IAAIZAAYIfA0tCwDrAAAZAAYIfA0tCwDrAAAAAA==.',['小红']='小红:BAAAKgAECgUIBQAAAA==.',['小草']='小草莓:BAAAKgAECgMIAwAAAA==.',['小魔']='小魔猩:BAAAKgAFFAMIAwAAAA==.',['小黑']='小黑嘿潶:BAACKgAFFH8hAAINAAUIWyHxBQAbAQANAAUIWyHxBQAbAQAqAAQKfy4AAg0ACAjgI2IEAMYCAA0ACAjgI2IEAMYCAAAA.',['山里']='山里山外:BAAAKgAECgQIBAAAAA==.',['岩七']='岩七七:BAACKgAFFH8WAAQcAAMIfRqfFgCTAAAdAAIIDRcXEgCVAAAcAAIIsBafFgCTAAAeAAIIYxd1IQCLAAAqAAQKfy8ABB4ACAhcIVQNAH8CAB4ACAjtIFQNAH8CAB0AAghwGWYtAJwAABwAAwiCFK9ZAIsAAAAA.',['希尔']='希尔瓦娜女王:BAABKgAFFH8YAAMUAAgIGRuXAADcAQAUAAYILSKXAADcAQAfAAYI3BM6GQAzAQAAAA==.',['希里']='希里雅:BAABKgAECn8WAAIVAAgIqSP1AwDHAgAVAAgIqSP1AwDHAgAAAA==.',['干不']='干不死的艾米:BAABKgAFFH8IAAIPAAQIPxnLGwDEAAAPAAQIPxnLGwDEAAAAAA==.',['干中']='干中学:BAAAKgAECgMIAwAAAA==.',['幺妹']='幺妹儿:BAAAKgAECgYIAQAAAA==.',['幽默']='幽默多拉贡:BAAAKgAECgIIAgAAAA==.',['开设']='开设东:BAAAKgADCggICAAAAA==.',['弹更']='弹更:BAAAKgAECgcIDwAAAA==.',['强灬']='强灬干丶:BAAAKgAECgUIBQAAAA==.',['御灵']='御灵:BAABKgAFFH8IAAIgAAQIiQtvCQDGAAAgAAQIiQtvCQDGAAAAAA==.',['德一']='德一只:BAAAKgAFFAEIAQAAAA==.',['德牛']='德牛天下:BAAAKgADCgEIAQAAAA==.',['情人']='情人街苑琼丹:BAABKgAFFH8HAAMNAAQIdgqkJgCLAAANAAIIrAukJgCLAAAMAAIICAd6TACCAAAAAA==.',['愤怒']='愤怒的小妖:BAAAKgAFFAIIAgAAAA==.',['我的']='我的二哈呢:BAACKgAFFH8iAAMUAAUIRhsJEAD6AAAUAAUIMBYJEAD6AAAfAAMIURixIgDMAAAqAAQKfzIAAxQACAgRImMRAEoCABQACAiEIWMRAEoCAB8ACAhBHgstAEACAAAA.',['手黑']='手黑:BAAAKgAECgEIAQAAAA==.',['打工']='打工人丶:BAAAKgAECggIEAAAAA==.',['抬手']='抬手打冲拳:BAABKgAFFH8IAAIfAAMIyyFGHAAhAQAfAAMIyyFGHAAhAQAAAA==.',['拔丝']='拔丝土豆:BAACKgAFFH8cAAMWAAQIaRjkEwChAAAWAAQIaRjkEwChAAAXAAEIEwQVHQApAAAqAAQKfy4AAxYACAi5I6wIAJkCABYACAi5I6wIAJkCABcABAh2DIpFAN4AAAAA.',['捅鸡']='捅鸡学博士:BAAAKgADCggICAAAAA==.',['提利']='提利昂:BAAAKgADCgMIAwAAAA==.',['擦擦']='擦擦二号:BAAAKgAECgcICQAAAA==.',['放开']='放开那娘们:BAAAKgAFFAQIBAAAAA==.放开那阿婆:BAAAKgAECgUIBQAAAA==.',['斯坦']='斯坦丶马什:BAAAKgAFFAYIBAAAAA==.',['新垣']='新垣结衣:BAABKgAFFH8GAAIQAAYImxyEDgCvAQAQAAYImxyEDgCvAQAAAA==.',['无方']='无方幻灭:BAAAKgAECgEIAQAAAA==.',['无面']='无面者:BAACKgAFFH8HAAIDAAQI+AxyNACvAAADAAQI+AxyNACvAAAqAAQKfxsAAgMACAjlE+JDAJgBAAMACAjlE+JDAJgBAAAA.',['春夏']='春夏丶秋冬:BAACKgAFFH8PAAIQAAQInCJVEwDsAAAQAAQInCJVEwDsAAAqAAQKfx4AAxAACAjkHvAnABkCABAACAjkHvAnABkCAA8AAgjpEwpPADoAAAAA.',['普莉']='普莉希拉:BAABKgAFFH8GAAIMAAYIKB6UDADNAQAMAAYIKB6UDADNAQABKgAFFAgIBAACAAAAAA==.',['景晨']='景晨:BAABKgAFFH8JAAIBAAMIixMZTQDVAAABAAMIixMZTQDVAAAAAA==.',['暗夜']='暗夜之歌:BAABKgAFFH8LAAMHAAgIKRO4BQD4AQAHAAgIKRO4BQD4AQAIAAMI9QLgEgB+AAAAAA==.暗夜紫煌:BAAAKgAFFAQIBAAAAA==.暗夜红枫:BAAAKgAECggICAAAAA==.',['月光']='月光宝盒:BAAAKgAECgcICQAAAA==.',['村绯']='村绯绯:BAAAKgAECgUICAAAAA==.',['林江']='林江仙丶:BAAAKgAFFAIIAgAAAA==.',['枫叶']='枫叶灬飘零:BAAAKgADCggICAAAAA==.',['柒月']='柒月:BAABKgAECn8UAAIDAAgIMRHwGwBwAQADAAgIMRHwGwBwAQAAAA==.',['柠檬']='柠檬薄荷:BAACKgAFFH8cAAIHAAQIUyIVBwAhAQAHAAQIUyIVBwAhAQAqAAQKfykAAwcACAisItoIAK8CAAcACAisItoIAK8CAAYAAgggAwVEAEYAAAAA.',['核桃']='核桃酥:BAAAKgAECgEIAQAAAA==.',['梧桐']='梧桐兼细雨:BAABKgAFFH8FAAIeAAQI+ROoEAAqAQAeAAQI+ROoEAAqAQABKgAECggIGgAPAO0fAA==.',['检查']='检查身体:BAAAKgAECgIIAgAAAA==.',['森木']='森木多:BAAAKgAFFAQIBAAAAA==.',['椰子']='椰子君:BAAAKgAECggIDwAAAA==.',['楓爵']='楓爵:BAAAKgAECgEIAQAAAA==.',['次级']='次级法力残渣:BAAAKgAECgcIDgAAAA==.',['欣怡']='欣怡:BAAAKgAECgcIAQAAAA==.',['歪比']='歪比芭布巴:BAAAKgADCgEIAQAAAA==.',['母牛']='母牛在哪:BAAAKgAECggICAAAAA==.',['毛茸']='毛茸茸:BAAAKgAECgQIBQAAAA==.',['气旋']='气旋魂破:BAAAKgAECgUICgAAAA==.',['沙德']='沙德沃克:BAABKgAFFH8IAAMMAAgI1xRWIAAeAQAMAAMI3x1WIAAeAQANAAUIaBOOCAD3AAAAAA==.',['法力']='法力残渣:BAABKgAFFH8FAAIKAAMI7Qo2GgCuAAAKAAMI7Qo2GgCuAAAAAA==.',['流氓']='流氓猪宝宝:BAAAKgAECggICAAAAA==.',['流浪']='流浪的王富贵:BAABKgAFFH8IAAMbAAYItBOaBwCKAQAbAAYI7RGaBwCKAQALAAIIXx5LEQCdAAAAAA==.',['流用']='流用:BAACKgAFFH8KAAMaAAUImRuICgC9AAABAAQImhpcTADWAAAaAAMIwhSICgC9AAAqAAQKfykAAxoACAgkGoAVAMcBABoACAiRFoAVAMcBAAEABwhYG9x6AKEBAAAA.',['浪子']='浪子:BAABKgAECn8UAAISAAgI8BKRJgCmAQASAAgI8BKRJgCmAQAAAA==.',['满满']='满满丶:BAABKgAFFH8KAAMMAAYIGRJKIQCzAAAMAAUIKA1KIQCzAAANAAEILRuJMQBSAAAAAA==.',['潇洒']='潇洒一回:BAAAKgADCggIEgAAAA==.',['潞過']='潞過傷人:BAAAKgAECggICQAAAA==.',['炎君']='炎君:BAAAKgAECgIIAgAAAA==.',['熊熊']='熊熊是医生:BAABKgAFFH8GAAMWAAYI5g81FACeAAAWAAMISQ81FACeAAAVAAMI0RCCEAB/AAAAAA==.熊熊死骑:BAAAKgAECgcIBwAAAA==.',['熊霸']='熊霸天下:BAAAKgADCgEIAQAAAA==.',['爱你']='爱你的猫:BAAAKgAFFAEIAQAAAA==.',['爱而']='爱而不得:BAAAKgAECggIDQAAAA==.',['牛大']='牛大嗝:BAAAKgAECgYIBQAAAA==.',['牛必']='牛必红洪:BAAAKgAECggICAAAAA==.',['牛气']='牛气十足:BAACKgAFFH8fAAIHAAUIThZMEgDbAAAHAAUIThZMEgDbAAAqAAQKfz0AAgcACAjbGosoAN0BAAcACAjbGosoAN0BAAAA.牛气骁德:BAAAKgAECgEIAQAAAA==.',['牛而']='牛而逼之:BAAAKgADCgQIBAAAAA==.',['牛頓']='牛頓:BAABKgAFFH8GAAITAAMI6QdFBgBsAAATAAMI6QdFBgBsAAAAAA==.',['牡丹']='牡丹丶:BAABKgAFFH8IAAIDAAQI8BkqEwDzAAADAAQI8BkqEwDzAAAAAA==.',['牵手']='牵手丶:BAAAKgAECggIEwAAAA==.',['狂奔']='狂奔不回头:BAACKgAFFH8eAAMQAAQIsiMzBgBCAQAQAAQIsiMzBgBCAQAOAAEIeAVuCgAxAAAqAAQKfzIAAxAACAi+IOEXAHECABAACAgFIOEXAHECAA4ACAhcHMANAL4BAAEqAAUUCAgSABkAYSAA.',['狂野']='狂野若枫:BAAAKgAFFAYIBAAAAA==.',['独丶']='独丶毒魔:BAAAKgAECgYIBgAAAA==.',['独版']='独版小贝:BAAAKgAECgcIDQAAAA==.',['猎之']='猎之舞:BAABKgAFFH8JAAIUAAMIiAtJNQCeAAAUAAMIiAtJNQCeAAAAAA==.',['猩红']='猩红王子:BAACKgAFFH8JAAMhAAMIQx0ZDADtAAAhAAMIQx0ZDADtAAAiAAIIiCAxBQC5AAAqAAQKfxsABCEACAjdHOIYAPkBACEACAjdHOIYAPkBACMAAwhAEX0GAG8AACIAAQgAAGQvAAAAAAAA.',['猫猫']='猫猫咪丫:BAAAKgAECgUIBAAAAA==.',['王者']='王者降临:BAACKgAFFH8iAAIkAAUIkSLaAgD/AAAkAAUIkSLaAgD/AAAqAAQKfzEAAiQACAguI4EDALQCACQACAguI4EDALQCAAAA.王者魔兽:BAAAKgAECgcIDQAAAA==.',['瓦娜']='瓦娜斯丶:BAAAKgAFFAQIBAAAAA==.',['甄能']='甄能电:BAAAKgAECgQIBAAAAA==.甄能砍:BAAAKgAECgQIBAAAAA==.',['由我']='由我来平衡丶:BAACKgAFFH8FAAIiAAMIyAzBBwB6AAAiAAMIyAzBBwB6AAAqAAQKfyEAAiIACAgNFbgHAKgBACIACAgNFbgHAKgBAAAA.',['疗愈']='疗愈之森丶:BAAAKgAECggICAAAAA==.',['疯癫']='疯癫到巅峰:BAAAKgAFFAMIAwAAAA==.',['痰少']='痰少:BAAAKgAFFAMIAwAAAA==.',['瘋狂']='瘋狂的帽商:BAACKgAFFH8fAAQdAAQIUiaaAgAlAQAdAAMIUiaaAgAlAQAeAAQIWx2PDgDvAAAcAAEIAAB2NAAAAAAqAAQKfyUABB4ACAhcJvkCAO0CAB4ACAgGJvkCAO0CAB0AAghvJaIkANEAABwAAQjjGO93AD0AAAAA.',['百思']='百思不得琪姐:BAAAKgADCggICAAAAA==.',['皮皮']='皮皮死神:BAAAKgAFFAQIBAAAAA==.',['相思']='相思何愁:BAAAKgAFFAIIBAAAAA==.',['真丶']='真丶云出无心:BAABKgAFFH8GAAIaAAYIoCGnIwBpAAAaAAYIoCGnIwBpAAAAAA==.',['着裙']='着裙灬舞尽生:BAAAKgAECgQIBAAAAA==.',['睿影']='睿影随行:BAAAKgAECgQIBAAAAA==.',['石原']='石原里美:BAAAKgAECggICAAAAA==.',['破如']='破如防:BAAAKgAECgYIBgAAAA==.',['神经']='神经骑天下:BAABKgAFFH8KAAMBAAgIWRe8DQDHAQABAAYIuhy8DQDHAQAaAAQIswrBFADTAAAAAA==.',['秀宇']='秀宇:BAAAKgAFFAQIBAAAAA==.',['米迦']='米迦勒的裁决:BAAAKgAECgQIBAAAAA==.',['粉骑']='粉骑士:BAAAKgAECgEIAQAAAA==.',['糊里']='糊里糊涂:BAAAKgADCggICwAAAA==.',['索斯']='索斯爵士:BAAAKgAFFAIIAgAAAA==.',['繁猩']='繁猩:BAAAKgAFFAYIAwAAAA==.',['纋樂']='纋樂美:BAAAKgADCgQIBAAAAA==.',['红将']='红将:BAAAKgAFFAEIAQAAAA==.',['红灬']='红灬莲:BAACKgAFFH8MAAMKAAYI4Q5fFgAxAQAKAAYI3w1fFgAxAQALAAMI0Q3sCwDEAAAqAAQKfxkAAgsACAj3GnwxAK0BAAsACAj3GnwxAK0BAAAA.',['纯爱']='纯爱丶米迦勒:BAAAKgADCggICgAAAA==.',['缘起']='缘起缘散:BAABKgAFFH8FAAIKAAMINBFbFwDBAAAKAAMINBFbFwDBAAAAAA==.',['老呆']='老呆河马:BAABKgAFFH8GAAIPAAMIIRFIEQC3AAAPAAMIIRFIEQC3AAAAAA==.',['耗死']='耗死丶龟哥:BAAAKgAECgUIBQAAAA==.',['肚子']='肚子丨:BAABKgAECn8VAAIFAAgIKBfWCQAhAgAFAAgIKBfWCQAhAgAAAA==.',['胭珈']='胭珈凌雪:BAACKgAFFH8FAAMbAAMIJgWEIwCdAAAbAAMIJgWEIwCdAAALAAEIKgLzJQAhAAAqAAQKfyMAAxsACAizFQQzAM4BABsACAizFQQzAM4BAAsAAgisFNKZAFkAAAAA.',['脆脆']='脆脆鲨:BAABKgAFFH8JAAIBAAMIhhEFUQDOAAABAAMIhhEFUQDOAAAAAA==.',['致命']='致命一箭:BAAAKgADCggICAAAAA==.',['舒绅']='舒绅:BAAAKgAECggIDgAAAA==.',['舞葉']='舞葉丶:BAAAKgAECgUIBQAAAA==.',['芳心']='芳心纵火犯:BAAAKgAECgUIBQAAAA==.',['苹果']='苹果贼:BAACKgAFFH8LAAQlAAMInhADBACvAAAlAAMIywgDBACvAAAZAAIIVBAGEwCaAAAmAAEIHhW7BwBJAAAqAAQKfyEABCYACAgQHnwIALkBACYACAi4F3wIALkBABkABQgYHDsaAJYBACUABgjRHWkDAGMBAAAA.',['荔枝']='荔枝荔枝:BAAAKgAECggIDQAAAA==.',['荣耀']='荣耀归来:BAAAKgADCgIIAgAAAA==.',['莉莉']='莉莉安:BAAAKgAECgUIDAAAAA==.',['菜奶']='菜奶:BAABKgAECn80AAMWAAgI+w8TOgAwAQAWAAgI+w8TOgAwAQAVAAEILAcVhgAhAAAAAA==.',['菲胡']='菲胡:BAAAKgAECgYIBwAAAA==.',['萌小']='萌小僧:BAAAKgAECgEIAQAAAA==.',['葬花']='葬花暧:BAAAKgADCggICAAAAA==.',['蓝颜']='蓝颜梦语丶:BAABKgAFFH8GAAMWAAYIcBXEDQDuAAAWAAUIqxLEDQDuAAAXAAEIRQucGQBHAAAAAA==.',['薇儿']='薇儿丶:BAABKgAFFH8GAAIWAAMIBwZ3LwCIAAAWAAMIBwZ3LwCIAAAAAA==.',['蘇丶']='蘇丶:BAABKgAECn8aAAMPAAgI7R+NCwBuAgAPAAgIyR+NCwBuAgAQAAgIrQ4sWwAPAQAAAA==.',['蜜丝']='蜜丝特拉:BAABKgAFFH8HAAIVAAcIfw1HDQBCAQAVAAcIfw1HDQBCAQAAAA==.',['蜻蜓']='蜻蜓队长:BAACKgAFFH8dAAMBAAUIYyVxBQBZAQABAAQIcSZxBQBZAQAaAAEIOSLgEQBmAAAqAAQKfywAAgEACAjqJigCAB4DAAEACAjqJigCAB4DAAAA.',['蟹中']='蟹中蟹:BAACKgAFFH8JAAMBAAMI7CNDMAAnAQABAAMI7CNDMAAnAQAaAAMI5BloCwDRAAAqAAQKfyoAAgEACAhhJhEhAJUCAAEACAhhJhEhAJUCAAAA.',['血灵']='血灵狂魔:BAAAKgAECggIEQAAAA==.',['血色']='血色永恒:BAAAKgAFFAMIAwAAAA==.',['行者']='行者:BAAAKgADCgUIBQAAAA==.',['让你']='让你三招:BAABKgAFFH8HAAIZAAcIXxMJAgCyAQAZAAcIXxMJAgCyAQAAAA==.',['诠释']='诠释东锅锅:BAABKgAECn8aAAMnAAgIVhvKEgD/AQAnAAgIVhvKEgD/AQAkAAEIhQldRgAlAAAAAA==.',['贫尼']='贫尼光天化日:BAABKgAFFH8GAAIaAAYI2QM6GgCnAAAaAAYI2QM6GgCnAAAAAA==.',['赞达']='赞达拉狂少:BAAAKgAECgYIBgAAAA==.',['赤座']='赤座灯里:BAAAKgAECgUIBgAAAA==.',['赫拉']='赫拉克斯:BAAAKgAECgEIAQAAAA==.',['越玩']='越玩越闹心:BAAAKgAFFAYIAgAAAA==.',['路西']='路西法晨星:BAAAKgAECgIIAgAAAA==.',['踮脚']='踮脚吃个个:BAACKgAFFH8wAAMaAAgIaBYYBgDJAQAaAAgIvBUYBgDJAQABAAUImhvmMgAeAQAqAAQKfyQAAhoACAhLG9QPABACABoACAhLG9QPABACAAAA.',['轩辕']='轩辕水狂风:BAABKgAFFH8JAAIHAAMIJRavKgDMAAAHAAMIJRavKgDMAAAAAA==.',['软奶']='软奶酪甜心:BAAAKgAFFAYIBAAAAA==.',['迷你']='迷你棒棒糖:BAAAKgAECgYIBgAAAA==.',['逐风']='逐风者之影:BAABKgAFFH8GAAIUAAMIDBpiJADcAAAUAAMIDBpiJADcAAAAAA==.',['通心']='通心灵的洞穴:BAAAKgAECgMIAwAAAA==.',['逝去']='逝去的岁月:BAAAKgADCgIIAgAAAA==.',['邂逅']='邂逅丶无聊:BAAAKgAECgYIBgAAAA==.',['邓不']='邓不利少:BAACKgAFFH8cAAMKAAUIOhCAAgDUAAAKAAUI+Q+AAgDUAAAbAAMI8wz9IADSAAAqAAQKfyYABAsACAiFGuwkAO4BAAsACAi9F+wkAO4BABsACAh6E+M6AKcBAAoAAwi7DKQhAIcAAAAA.',['邪念']='邪念:BAABKgAFFH8GAAIUAAYIiQ42FwAtAQAUAAYIiQ42FwAtAQAAAA==.',['都是']='都是批娃娃:BAAAKgAECggICAAAAA==.',['醒目']='醒目菠萝:BAAAKgAECgEIAQAAAA==.',['钢板']='钢板小炮:BAAAKgAECgYIBgAAAA==.',['闪电']='闪电风暴:BAAAKgAECgUICQAAAA==.',['阿本']='阿本:BAABKgAFFH8JAAQcAAMIFgnQHgBoAAAeAAMIFgliMwCiAAAcAAIIKwbQHgBoAAAdAAEIrwcbJQA6AAAAAA==.',['陆陆']='陆陆:BAABKgAECn8cAAIDAAgIFBH/OABwAQADAAgIFBH/OABwAQAAAA==.',['隐杀']='隐杀者乄风:BAAAKgAECgcICAAAAA==.',['雪影']='雪影影雪:BAAAKgAFFAIIAgAAAA==.',['雪月']='雪月风花:BAAAKgAECgYIBgAAAA==.',['雷加']='雷加尔:BAACKgAFFH8PAAQIAAMIRRYQEgDXAAAIAAMIRRYQEgDXAAAHAAII6xaSQQCBAAAGAAIITAo/GgB0AAAqAAQKfxwABAYACAgIF50cAG8BAAYABwhUFZ0cAG8BAAgABQjSGm4VADsBAAcABAhxG7ZWACcBAAEqAAUUCAgIAAgATBgA.',['霸王']='霸王灬熊:BAAAKgADCgQIBQAAAA==.霸王灬羽:BAAAKgADCgEIAQAAAA==.',['领灬']='领灬主:BAAAKgAECggICAAAAA==.',['風魇']='風魇灬丶:BAAAKgAECggICwAAAA==.',['风丶']='风丶影:BAAAKgAECgIIAgAAAA==.',['风入']='风入疏竹:BAACKgAFFH8LAAINAAMI4w5nIwCZAAANAAMI4w5nIwCZAAAqAAQKfyAAAw0ACAj1E+slAJ8BAA0ACAj1E+slAJ8BAAwABQiMCYqLAMIAAAAA.',['风如']='风如火:BAAAKgAECgIIAgAAAA==.',['风暴']='风暴恶灵:BAAAKgAECgcIAQAAAA==.风暴白酒丶岑:BAAAKgAECgEIAQAAAA==.',['风行']='风行长空:BAAAKgAECgMIAwAAAA==.',['饭桶']='饭桶:BAABKgAECn8uAAMQAAgIAh51BwAvAgAQAAgIjRx1BwAvAgAPAAgIWBpgDwD/AQAAAA==.',['香槟']='香槟薄荷:BAABKgAFFH8FAAIhAAQItgedEgDgAAAhAAQItgedEgDgAAABKgAFFAgIHAAHAFMiAA==.',['高科']='高科技:BAABKgAFFH8IAAISAAgIpxTlEABHAQASAAgIpxTlEABHAQAAAA==.',['黍离']='黍离丶:BAAAKgAFFAEIAQAAAA==.',['黑人']='黑人牙膏:BAAAKgAFFAMIAwAAAA==.',['黑得']='黑得出奇:BAABKgAFFH8FAAIDAAUI8xF9KACRAAADAAUI8xF9KACRAAAAAA==.',['黑暗']='黑暗遊侠:BAACKgAFFH8MAAIfAAMI9BO1LgDOAAAfAAMI9BO1LgDOAAAqAAQKf1gAAx8ACAhsHTMiADMCAB8ACAhsHTMiADMCABQAAQjfFXGdAEEAAAAA.',['黑色']='黑色油膜:BAAAKgADCgEIAwAAAA==.',['黑茶']='黑茶:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end