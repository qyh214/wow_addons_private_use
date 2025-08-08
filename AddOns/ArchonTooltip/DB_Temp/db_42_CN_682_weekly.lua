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
 local lookup = {'Paladin-Retribution','Hunter-BeastMastery','Warrior-Fury','Paladin-Protection','Paladin-Holy','Druid-Restoration','DemonHunter-Havoc','DeathKnight-Unholy','DeathKnight-Frost','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Warrior-Arms','Monk-Mistweaver','Unknown-Unknown','Mage-Frost','Druid-Balance','Mage-Fire','Mage-Arcane','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','DeathKnight-Blood','Priest-Shadow','Shaman-Restoration','Monk-Brewmaster','Monk-Windwalker','Warrior-Protection','Evoker-Devastation','Shaman-Enhancement','Shaman-Elemental',}; local provider = {region='CN',realm='戈古纳斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Argo:BAAAKgAFFAYIAwAAAA==.',Ca='Canyii:BAAAKgAECggICAAAAA==.',De='Deris:BAAAKgAECgYIDwAAAA==.',Di='Dirge:BAAAKgAFFAgIAwAAAA==.',Ik='Ikun:BAAAKgAECgUIBQAAAA==.',Ki='Kito:BAAAKgAFFAMIAwAAAA==.',Ko='Kongmencang:BAAAKgAECgMIAwAAAA==.',Mt='Mthgh:BAABKgAECn8ZAAIBAAgIIwnJrQD0AAABAAgIIwnJrQD0AAAAAA==.',Na='Namee:BAAAKgADCgMIAwAAAA==.',Se='Sekiro:BAAAKgAECggICAAAAA==.',Xe='Xenon:BAAAKgAFFAQIBAAAAA==.',['一滴']='一滴都不剩了:BAAAKgAECgMIAwAAAA==.',['一起']='一起去爬山:BAAAKgAECggICAAAAA==.',['七个']='七个小霪徒:BAAAKgAFFAQIBAABKgAFFAgIKgACACMgAA==.',['三大']='三大妈:BAAAKgADCgQIBQAAAA==.',['不会']='不会取名字:BAAAKgADCgQIBAAAAA==.',['不器']='不器:BAAAKgAECgYICAAAAA==.',['不必']='不必害怕:BAAAKgAECgIIAwAAAA==.不必烦恼:BAAAKgAECgEIAQAAAA==.不必计较:BAAAKgAECggIEQAAAA==.',['不明']='不明眞相群众:BAABKgAFFH8KAAIDAAYIwxUyDQB8AQADAAYIwxUyDQB8AQAAAA==.',['为了']='为了联盟:BAABKgAFFH8MAAMEAAQIkxWjCQDIAAAEAAQIkxWjCQDIAAAFAAQIZw/SCQDAAAABKgAFFAgIGgAEADESAA==.',['乜囧']='乜囧囧:BAAAKgAECggICAAAAA==.',['二牛']='二牛又来了:BAAAKgAFFAQIAgAAAA==.',['似血']='似血残阳:BAAAKgAECggICAAAAA==.',['你是']='你是极好的:BAAAKgADCgIIAgAAAA==.',['你真']='你真特么高:BAAAKgAECgUIBQAAAA==.',['你瞅']='你瞅瞅你:BAABKgAFFH8IAAIGAAII/QxmLgBfAAAGAAII/QxmLgBfAAAAAA==.',['偶系']='偶系丶阿冰哥:BAABKgAFFH8MAAIHAAQIPRUoFgDaAAAHAAQIPRUoFgDaAAAAAA==.',['傲娇']='傲娇的天聋人:BAAAKgADCggICAAAAA==.',['元华']='元华:BAABKgAECn8dAAMIAAgIZSK1EACfAgAIAAgIZSK1EACfAgAJAAMIThPfJwCBAAAAAA==.',['兔丶']='兔丶尐术:BAABKgAFFH8YAAQKAAYIcCHFAgCoAQAKAAYIcCHFAgCoAQALAAMIJBxzBgD2AAAMAAIIGxCFFABVAAAAAA==.',['兜兜']='兜兜豆豆:BAAAKgAFFAgIBAAAAA==.',['八级']='八级大狂疯:BAACKgAFFH8HAAIBAAQIvA+OVwDCAAABAAQIvA+OVwDCAAAqAAQKfzEAAgEACAhjIVkhAHwCAAEACAhjIVkhAHwCAAAA.',['典狱']='典狱短:BAAAKgAECggIDgAAAA==.',['再起']='再起誓言:BAABKgAECn8YAAMDAAgIJxuwHwAbAgADAAgI8hewHwAbAgANAAMIchksTACbAAAAAA==.',['初音']='初音未来:BAABKgAECn8qAAIOAAgIgCDPEgBSAgAOAAgIgCDPEgBSAgAAAA==.',['利维']='利维坦:BAAAKgAFFAYIAQABKgAFFAgIAgAPAAAAAA==.',['南北']='南北:BAAAKgAFFAgIAgAAAA==.',['卡珊']='卡珊德拉:BAAAKgAECgUIBgAAAA==.',['原神']='原神高手:BAAAKgAECgYICwAAAA==.',['可乐']='可乐排骨:BAAAKgAECgcICAAAAA==.',['呆萌']='呆萌:BAABKgAFFH8HAAIQAAYIWAZsBwAPAQAQAAYIWAZsBwAPAQAAAA==.',['咕咕']='咕咕枫丶:BAABKgAECn8VAAMRAAgIfRrqNQDiAQARAAgIfRrqNQDiAQAGAAIICw3RcQBkAAAAAA==.',['咕喵']='咕喵王:BAAAKgAECgYIDAAAAA==.',['哲惑']='哲惑:BAAAKgAECgYIBgAAAA==.',['嘎玛']='嘎玛朵昂:BAAAKgAFFAYIBAAAAA==.',['囍刚']='囍刚刚:BAABKgAECn8XAAIBAAgI+xziKwBQAgABAAgI+xziKwBQAgAAAA==.',['圣光']='圣光豌豆黄儿:BAAAKgADCggIDwAAAA==.',['在乎']='在乎的人:BAAAKgAECgcIDQAAAA==.',['大不']='大不一样:BAABKgAFFH8GAAIBAAYIwBQaIABwAQABAAYIwBQaIABwAQAAAA==.',['大占']='大占卜师:BAACKgAFFH8sAAMSAAYIgRzpCQCZAQASAAYIgRzpCQCZAQAQAAEIWwH9JAAtAAAqAAQKf1sABBIACAiiIUQFAKECABIACAiiIUQFAKECABAABwgOEVpQACQBABMAAgjhE/l3AHwAAAAA.',['大笨']='大笨猪哟:BAABKgAECn8eAAMDAAgIvB0lIQATAgADAAgIbB0lIQATAgANAAYIfholIwBtAQAAAA==.',['大锤']='大锤巴适:BAAAKgADCgcIBwAAAA==.',['天下']='天下大乱:BAAAKgAECgEIAQAAAA==.',['奥力']='奥力给:BAAAKgAECgEIAQAAAA==.',['姬安']='姬安娜:BAABKgAFFH8KAAIUAAMIfAYaLwCJAAAUAAMIfAYaLwCJAAAAAA==.',['婴儿']='婴儿蓝:BAAAKgAECgUIBQAAAA==.',['孙立']='孙立人:BAAAKgAFFAIIAgAAAA==.',['宁心']='宁心勿语:BAAAKgADCggICgAAAA==.',['宝兔']='宝兔兔:BAABKgAFFH8TAAMUAAYI2A+cCwDZAAAUAAYICA+cCwDZAAAVAAQIdBGFGwC4AAAAAA==.',['家有']='家有两只喵:BAAAKgADCggICAAAAA==.',['寂静']='寂静狩猎者:BAABKgAFFH8gAAMWAAYIXRYPDADsAAAWAAYIGBUPDADsAAACAAQIYxUdMADLAAABKgAFFAgIEwACAOUdAA==.',['小小']='小小笨猪:BAABKgAECn8dAAMBAAcIuCAOTAANAgABAAcIuCAOTAANAgAEAAEIHAO+bQAJAAABKgAFFAgIBAAPAAAAAA==.',['小爪']='小爪挠人:BAAAKgAFFAIIAgAAAA==.',['小镇']='小镇丶花夕娢:BAAAKgAECgEIAQAAAA==.',['屮囗']='屮囗屮:BAAAKgAECggICAAAAA==.',['左边']='左边的萝卜:BAAAKgADCggICAAAAA==.',['巴图']='巴图鲁:BAAAKgAECgQIBAAAAA==.',['幻梦']='幻梦时空:BAABKgAFFH8IAAIBAAgIOQxYDADdAQABAAgIOQxYDADdAQAAAA==.',['庄子']='庄子:BAAAKgADCggICAAAAA==.',['廖耀']='廖耀湘:BAABKgAFFH8FAAIXAAUIJwm2HQC1AAAXAAUIJwm2HQC1AAAAAA==.',['弗莱']='弗莱德怒火:BAAAKgAECgYIBgAAAA==.',['彩色']='彩色的猫:BAAAKgAECgEIAQAAAA==.',['彩虹']='彩虹我的爱:BAAAKgAECgcIDAAAAA==.',['往生']='往生缘丶沉迷:BAAAKgAECgcICAAAAA==.',['德德']='德德地:BAAAKgADCggIEAAAAA==.',['心中']='心中的日月:BAABKgAFFH8iAAIRAAQIyRauMgDNAAARAAQIyRauMgDNAAAAAA==.',['懒羊']='懒羊之剑:BAAAKgAFFAgIAwAAAA==.',['提里']='提里奥丷弗丁:BAABKgAFFH8JAAIBAAMI4wgNYQCuAAABAAMI4wgNYQCuAAABKgAFFAgIEAAYAFsKAA==.提里奥费丁:BAACKgAFFH8RAAIBAAYI5RYUHQD8AAABAAYI5RYUHQD8AAAqAAQKfzQAAgEACAhiJKALAOQCAAEACAhiJKALAOQCAAAA.',['断箭']='断箭追魂:BAAAKgAECgMIAwAAAA==.',['日月']='日月星辰:BAAAKgAECggICgAAAA==.',['晚上']='晚上吃什么:BAAAKgADCggICQAAAA==.',['曦尔']='曦尔瓦娜斯:BAAAKgAECggICAAAAA==.',['月影']='月影梵天:BAABKgAECn8YAAICAAgIiiABFwB3AgACAAgIiiABFwB3AgAAAA==.',['李牙']='李牙牙:BAAAKgADCgEIAQAAAA==.',['杜晓']='杜晓牧:BAAAKgADCgEIAQAAAA==.',['杜筱']='杜筱术:BAAAKgADCggICQAAAA==.',['极光']='极光掠影:BAAAKgADCgIIAgAAAA==.',['林允']='林允儿:BAAAKgAFFAEIAQAAAA==.',['枫红']='枫红叶:BAABKgAFFH8KAAIKAAIIiBLuJwBuAAAKAAIIiBLuJwBuAAABKgAFFAgIDgAKAEEbAA==.',['格尼']='格尼薇儿:BAABKgAFFH8PAAIBAAYIzBzeDQDFAQABAAYIzBzeDQDFAQABKgAFFAgIBgABAOkKAA==.',['梅琳']='梅琳娜:BAABKgAFFH8IAAIIAAQIjB0AKwDhAAAIAAQIjB0AKwDhAAAAAA==.',['森林']='森林小贩:BAAAKgAECgMIAwABKgAFFAIIAgAPAAAAAA==.',['樱桃']='樱桃小犊子:BAAAKgADCgMIAwAAAA==.',['死不']='死不了:BAABKgAFFH8IAAIBAAgITQQYFgA/AQABAAgITQQYFgA/AQAAAA==.',['比格']='比格呆瓜:BAAAKgAECggICAAAAA==.',['永恒']='永恒烈焰:BAAAKgADCgIIAgAAAA==.',['江南']='江南烟雨路:BAABKgAFFH8OAAMUAAYI2BatBwD6AAAUAAYI2BatBwD6AAAVAAEIAACcNwAAAAAAAA==.',['洛丹']='洛丹伦圣光:BAAAKgAECgIIAgAAAA==.洛丹伦恶魔:BAABKgAFFH8LAAQMAAQIzxACFACkAAAMAAQIHgwCFACkAAAKAAQIEQ42IACQAAALAAEIAABkKQAAAAAAAA==.',['流浪']='流浪法神:BAAAKgAECgMIAwAAAA==.',['浴血']='浴血:BAAAKgADCgMIAwAAAA==.',['海盗']='海盗丶:BAABKgAFFH8OAAIHAAYI6R9SDADAAQAHAAYI6R9SDADAAQABKgAFFAgIDAAHADUhAA==.',['温柔']='温柔一刀秒:BAAAKgAECggIDwAAAA==.',['溜迖']='溜迖:BAAAKgAECggICAABKgAECggIEQAPAAAAAA==.',['潜龙']='潜龙务用:BAAAKgAECggICAAAAA==.',['灬红']='灬红皮灬:BAAAKgAECgYIBgAAAA==.',['灵狐']='灵狐公子:BAAAKgAECggIEAAAAA==.',['点丶']='点丶丶燃:BAAAKgAFFAgIBAAAAA==.',['烈酒']='烈酒断愁肠:BAABKgAFFH8IAAINAAgIhh0YAgB3AgANAAgIhh0YAgB3AgAAAA==.',['烬雪']='烬雪千川:BAABKgAFFH8MAAIBAAYIqBCSEwBlAQABAAYIqBCSEwBlAQAAAA==.',['爱墨']='爱墨奥维斯:BAAAKgAECggIEQAAAA==.',['爱神']='爱神的眷顾:BAAAKgAECgMIAwABKgAFFAEIAQAPAAAAAA==.',['爱织']='爱织雾的熊猫:BAAAKgADCggICAAAAA==.',['牛霸']='牛霸:BAAAKgAECgQIBAAAAA==.',['狂战']='狂战易嘉逸:BAAAKgAECggIEAAAAA==.',['玉灵']='玉灵子:BAABKgAFFH8IAAIZAAgIKQ1LCACRAQAZAAgIKQ1LCACRAQAAAA==.',['玫瑰']='玫瑰丶瓦莉菈:BAAAKgAECgMIAwAAAA==.玫瑰丶解语花:BAAAKgAFFAIIAgAAAA==.',['琅琊']='琅琊玥:BAACKgAFFH8HAAIIAAQInxSjEgDSAAAIAAQInxSjEgDSAAAqAAQKfxUAAwgACAj9GZYgABECAAgACAj9GZYgABECABcAAQgAAP9dAAAAAAAA.',['生前']='生前是大帅哥:BAABKgAFFH8IAAIIAAgIvBZ5BABBAgAIAAgIvBZ5BABBAgAAAA==.',['畅快']='畅快的老龙虾:BAABKgAECn8eAAIHAAYInxVnIQA8AQAHAAYInxVnIQA8AQAAAA==.',['瘾丶']='瘾丶:BAAAKgAECggICAAAAA==.',['盘羊']='盘羊小角:BAAAKgADCgMIAwAAAA==.',['硬黝']='硬黝黑:BAAAKgAECgYIDAAAAA==.',['神之']='神之一法:BAAAKgADCgEIAQAAAA==.',['神圣']='神圣之力:BAABKgAFFH8QAAMEAAYInyG/CgBNAQAEAAYI9hq/CgBNAQABAAQIiyBAGgD2AAAAAA==.',['神战']='神战:BAAAKgAFFAgIAgAAAA==.',['秋冷']='秋冷了月光:BAACKgAFFH8nAAMDAAMIMiG0FAAYAQADAAMIMiG0FAAYAQANAAEIIhk3GQBOAAAqAAQKfy4AAwMACAhYIqQaADkCAAMABwhfIaQaADkCAA0AAwjAI6I5APwAAAAA.秋冷了玥光:BAAAKgAECgIIAgABKgAFFAMIJwADADIhAA==.',['秩序']='秩序始源:BAACKgAFFH8WAAIaAAMIBxh7BQDNAAAaAAMIBxh7BQDNAAAqAAQKfyAAAxoACAgBDIQTAO0AABoABAgBFYQTAO0AABsACAgrAAAAAAAAAAEqAAUUCAgwABwA2iQA.',['紫龍']='紫龍:BAABKgAFFH8IAAIdAAgIMRdSBQBOAgAdAAgIMRdSBQBOAgAAAA==.',['绛玥']='绛玥璃瑕:BAAAKgAECgIIAgAAAA==.',['脸滚']='脸滚键盘:BAAAKgADCgIIAgAAAA==.',['芝麻']='芝麻丸:BAAAKgADCgYIBgAAAA==.',['花泽']='花泽香菜:BAAAKgAECgYICAAAAA==.',['苏虞']='苏虞莫:BAAAKgAECgMIAwAAAA==.',['菊一']='菊一文字:BAAAKgAFFAEIAQAAAA==.',['落尘']='落尘灬:BAABKgAFFH8UAAIRAAgIQh30AwCWAgARAAgIQh30AwCWAgAAAA==.',['落灬']='落灬尘:BAAAKgADCggICAAAAA==.',['蘭蔸']='蘭蔸篼:BAABKgAECn8eAAIBAAgI5SKiIACAAgABAAgI5SKiIACAAgAAAA==.',['蟹堡']='蟹堡王:BAAAKgAECgUICAAAAA==.',['蟹皇']='蟹皇堡:BAAAKgADCgcICgAAAA==.',['血与']='血与冰之舞:BAAAKgADCgQIBAAAAA==.',['詹姆']='詹姆斯丷哈登:BAABKgAFFH8JAAICAAMIiA6yHAC1AAACAAMIiA6yHAC1AAAAAA==.',['诛歌']='诛歌:BAAAKgAFFAcIAgABKgAFFAgIBQABAB8MAA==.',['賽纳']='賽纳留斯:BAAAKgAECgIIAgAAAA==.',['财神']='财神:BAAAKgAECgQIBgAAAA==.',['贼狼']='贼狼冷刀:BAAAKgAECgIIAgAAAA==.',['赱紅']='赱紅丶:BAABKgAFFH8KAAIXAAYIQyWlBAAFAgAXAAYIQyWlBAAFAgABKgAFFAgIGgAIAEwhAA==.',['超级']='超级马塞克:BAABKgAECn8YAAIIAAgIGhxhGQBDAgAIAAgIGhxhGQBDAgAAAA==.超级马赛克:BAAAKgAECgUIEwAAAA==.',['蹓跶']='蹓跶:BAAAKgAECggIEQAAAA==.',['轻声']='轻声语:BAAAKgAECgEIAQAAAA==.',['辉煌']='辉煌之剑:BAAAKgAECggIEwAAAA==.',['这个']='这个求贼狠:BAAAKgAECgQICQAAAA==.',['造化']='造化钟神秀:BAABKgAFFH8WAAIBAAQIFCM3GAAnAQABAAQIFCM3GAAnAQAAAA==.',['遛跶']='遛跶:BAAAKgAECgcIBwABKgAECggIEQAPAAAAAA==.',['遛迏']='遛迏:BAAAKgAECggIDwABKgAECggIEQAPAAAAAA==.',['闪耀']='闪耀的猫:BAACKgAFFH8FAAIeAAUIgwcLCAD2AAAeAAUIgwcLCAD2AAAqAAQKfxkAAx4ACAiSESEKAH0BAB4ACAilECEKAH0BAB8ABAiLDIQnAIMAAAAA.',['闲人']='闲人米米呀:BAAAKgAECgEIAQAAAA==.',['阿苗']='阿苗:BAACKgAFFH8JAAICAAQIaBUzKwDZAAACAAQIaBUzKwDZAAAqAAQKfxUAAwIACAi5FVlIAIcBAAIACAgeFVlIAIcBABYAAgivC+GvACQAAAAA.',['阿莎']='阿莎娜拉:BAAAKgAECgQIBAAAAA==.',['随风']='随风潜入夜:BAABKgAFFH8GAAITAAQIhRZCIwDWAAATAAQIhRZCIwDWAAAAAA==.',['露早']='露早够够:BAAAKgAECggIDAAAAA==.',['颜值']='颜值国王:BAAAKgAFFAYIAgAAAA==.',['风剑']='风剑侠:BAACKgAFFH8qAAIIAAYIFyMKCQD+AQAIAAYIFyMKCQD+AQAqAAQKfx0AAggACAiIIDQSAJUCAAgACAiIIDQSAJUCAAAA.',['香菇']='香菇排猪肉:BAAAKgAECgQIBAAAAA==.',['骑德']='骑德龍东墙:BAAAKgADCggICAAAAA==.',['骑车']='骑车去跳海:BAACKgAFFH8NAAMNAAMIfhfuEACXAAANAAMIfhfuEACXAAAcAAMI2wp+DwCDAAAqAAQKfx0AAhwACAgqFzIIAMwBABwACAgqFzIIAMwBAAAA.',['魅兰']='魅兰明月:BAAAKgADCggIEQAAAA==.',['鱿鱼']='鱿鱼干什么:BAAAKgADCggICAAAAA==.',['黯然']='黯然的鱼:BAAAKgADCgIIAgAAAA==.',['龙女']='龙女丶希瓦娜:BAAAKgAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end