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
 local lookup = {'Hunter-Marksmanship','DemonHunter-Vengeance','DemonHunter-Havoc','Paladin-Retribution','Mage-Frost','Warlock-Demonology','Paladin-Holy','Paladin-Protection','Warrior-Arms','Warrior-Fury','Warrior-Protection','Warlock-Destruction','Warlock-Affliction','Priest-Discipline','Priest-Holy','Priest-Shadow','Druid-Balance','Shaman-Restoration','DeathKnight-Unholy','Hunter-BeastMastery','Monk-Windwalker','Unknown-Unknown','Druid-Restoration','DeathKnight-Blood','DeathKnight-Frost','Monk-Mistweaver','Shaman-Enhancement','Shaman-Elemental','Rogue-Outlaw','Rogue-Assassination',}; local provider = {region='CN',realm='杜隆坦',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amanrade:BAAAKgAECgcIBwAAAA==.',Co='Coolcat:BAAAKgADCgIIAgAAAA==.',Cr='Crazyant:BAAAKgADCgIIAgAAAA==.',Ct='Ctrlx:BAAAKgAECgYIBgAAAA==.',Da='Darkhunter:BAAAKgAECgUIBQAAAA==.',Dk='Dkkw:BAAAKgAECgEIAQAAAA==.',Ds='Dsknight:BAAAKgADCggICAAAAA==.',Hu='Hunterp:BAABKgAFFH8NAAIBAAQIYxknEgDNAAABAAQIYxknEgDNAAAAAA==.',Ik='Ikun:BAABKgAECn8UAAMCAAgI1hnVGAC3AQACAAcIaBnVGAC3AQADAAUIshWDUQAEAQAAAA==.',Ir='Iries:BAAAKgAECggIEAAAAA==.',La='Lancome:BAABKgAFFH8IAAIEAAMI7wfuYwCnAAAEAAMI7wfuYwCnAAAAAA==.',Lo='Lookinmyeyes:BAAAKgADCgcIBwAAAA==.',Ni='Ning:BAAAKgAECgYIBgAAAA==.',On='Oneanother:BAAAKgAECgIIAgAAAA==.Onyxía:BAAAKgAECggIEwAAAA==.',Po='Poem:BAABKgAFFH8GAAIFAAYIrBSFLgAtAAAFAAYIrBSFLgAtAAAAAA==.',Su='Superjoker:BAAAKgADCgEIAQAAAA==.',['Sà']='Sàurfang:BAAAKgAECgcICAAAAA==.',['Sí']='Síf:BAAAKgAECgQIBAAAAA==.',Ta='Taimo:BAAAKgAFFAgIBAAAAA==.',Ut='Utopia:BAABKgAECn8hAAIGAAcIJBeAHQCbAQAGAAcIJBeAHQCbAQAAAA==.',['Yù']='Yùyc:BAABKgAECn8zAAMHAAgIEhtGDgATAgAHAAgIEhtGDgATAgAEAAYINBRmkgAoAQAAAA==.',['一击']='一击即中:BAAAKgAECgYIBgAAAA==.',['一念']='一念一天堂:BAAAKgADCggICAAAAA==.',['一盏']='一盏风月:BAABKgAECn8XAAMDAAgIDR5XLgD4AQADAAcIpR5XLgD4AQACAAgIGw8oLgAZAQABKgAFFAgIEgADAJgVAA==.',['万神']='万神一典狱长:BAAAKgADCgMIBQAAAA==.',['不明']='不明的人物:BAAAKgADCggICAAAAA==.',['世界']='世界中的我:BAAAKgAECgQIBwAAAA==.',['丶咕']='丶咕噜噜:BAAAKgAECgYIBgAAAA==.',['九尾']='九尾雪狐:BAABKgAFFH8IAAMEAAQIGhFiJgDYAAAEAAQIWQxiJgDYAAAIAAQIGhEVDACpAAAAAA==.',['乞力']='乞力马扎罗嶨:BAAAKgADCgUIBQAAAA==.',['二斤']='二斤酒:BAAAKgADCgEIAQAAAA==.',['五更']='五更琉漓:BAAAKgADCgcIBwAAAA==.',['亲爱']='亲爱德丶木兰:BAAAKgAECgQIBAAAAA==.',['人族']='人族先锋:BAACKgAFFH8RAAQJAAYIvw5qCwBXAQAKAAYIKwulCgB5AQAJAAYIYQxqCwBXAQALAAQIswT+EQBsAAAqAAQKfxQAAwkACAh1FTQeAMIBAAkACAgJETQeAMIBAAoABAhKFrYbABgBAAAA.',['伊利']='伊利蛋语风:BAAAKgAECgQICAAAAA==.',['佑圣']='佑圣元君:BAAAKgAECgMIAwAAAA==.',['作怪']='作怪飞飞:BAABKgAECn8UAAIBAAgI3RgpJgCrAQABAAgI3RgpJgCrAQAAAA==.',['你和']='你和我玩崩铁:BAACKgAFFH8RAAMKAAQIiA11IQDNAAAKAAQIiA11IQDNAAALAAQIaAiODwCCAAAqAAQKfxUAAwoACAgKDkNEAAYBAAoABwidDUNEAAYBAAsACAiCB8AqANoAAAAA.',['你女']='你女未白勺:BAAAKgAECgQIBAAAAA==.',['使徒']='使徒行者:BAAAKgAECgIIAgAAAA==.',['偷偷']='偷偷地走向你:BAAAKgAECgUIBQAAAA==.',['僷梓']='僷梓:BAAAKgAFFAIIBAAAAA==.',['克洛']='克洛薇:BAAAKgAFFAQIBAAAAA==.',['兔击']='兔击哼唧:BAAAKgAFFAMIAwAAAA==.',['冰晶']='冰晶:BAAAKgAFFAIIBAAAAA==.',['冰火']='冰火两重天:BAAAKgAECggICAAAAA==.',['列克']='列克星敦:BAABKgAFFH8SAAQMAAQIOBwkHACqAAAMAAQIEhQkHACqAAAGAAEIByEYIQBcAAANAAEIeggPJQA6AAAAAA==.',['刚刚']='刚刚一米八:BAAAKgAECgUIBQAAAA==.',['利托']='利托里奥:BAABKgAFFH8TAAIKAAUIuhUFDwD+AAAKAAUIuhUFDwD+AAAAAA==.',['北宅']='北宅:BAAAKgAECgcICwAAAA==.',['去年']='去年三丈:BAAAKgAECgUIBQAAAA==.',['叁拾']='叁拾丶:BAAAKgADCgEIAQAAAA==.',['只炎']='只炎片雨:BAABKgAFFH8IAAQOAAQISh9TFAC8AAAPAAQIQhkHEQDBAAAOAAMI8B5TFAC8AAAQAAEIlRuBIQBXAAAAAA==.',['和聲']='和聲細語:BAABKgAFFH8IAAIRAAQIcBLNGQDYAAARAAQIcBLNGQDYAAAAAA==.',['哎呀']='哎呀豚豚:BAAAKgAECgQIBAAAAA==.',['囄火']='囄火灬:BAAAKgAECggICAAAAA==.',['四川']='四川王大锤:BAAAKgAECgYIAwAAAA==.',['土佬']='土佬肥:BAABKgAFFH8FAAISAAIIVBfPQACFAAASAAIIVBfPQACFAAAAAA==.',['圣光']='圣光之名:BAAAKgAFFAYIBAAAAA==.',['堕落']='堕落的花纹:BAAAKgADCgEIAQAAAA==.',['墮落']='墮落啲數學:BAAAKgADCgIIAgAAAA==.',['夏日']='夏日的颂歌:BAAAKgAECgEIAQAAAA==.',['夜清']='夜清醒:BAABKgAFFH8XAAISAAMI0RtcEgDnAAASAAMI0RtcEgDnAAAAAA==.',['大侠']='大侠阿宝:BAAAKgAECgIIAgAAAA==.',['大笨']='大笨象扎支枪:BAAAKgADCggICQAAAA==.',['天命']='天命在吾:BAABKgAFFH8RAAIIAAUIow21FADTAAAIAAUIow21FADTAAABKgAFFAgIDgATAEoXAA==.',['天棒']='天棒:BAABKgAFFH8KAAIEAAgItx3QCAA2AgAEAAgItx3QCAA2AgAAAA==.',['天水']='天水一色:BAAAKgAECgMIAwAAAA==.',['天炎']='天炎迷雨:BAAAKgAFFAQIBAAAAA==.',['天穹']='天穹骑士:BAAAKgADCgIIAgAAAA==.',['夫人']='夫人你也不想:BAAAKgADCggIDwAAAA==.',['奶思']='奶思兔米兔油:BAAAKgAECgcIBwAAAA==.',['奶爸']='奶爸典范:BAAAKgAFFAQIBAABKgAFFAYIDAAPACAVAA==.',['好梦']='好梦易醒:BAAAKgAECgMIAwAAAA==.',['妹妹']='妹妹我还要:BAAAKgAECgYIEwAAAA==.',['子夏']='子夏:BAAAKgADCgQIBAAAAA==.',['寂寞']='寂寞追月:BAAAKgAECgUIBQAAAA==.寂寞追风:BAAAKgADCggICQAAAA==.',['射勒']='射勒:BAAAKgAECgIIAwAAAA==.',['小乱']='小乱:BAAAKgAECgYIBwAAAA==.',['小咕']='小咕炖蘑菇:BAAAKgAECgcIBwAAAA==.',['小嘿']='小嘿:BAAAKgADCgEIAQAAAA==.',['小寒']='小寒号鸟:BAABKgAECn8qAAIUAAgIiBmrMwDZAQAUAAgIiBmrMwDZAQAAAA==.',['小年']='小年哦丶:BAAAKgAFFAQIBAAAAA==.',['小時']='小時候可強啦:BAAAKgAECgQIBAAAAA==.',['小水']='小水凝:BAAAKgAFFAgIBAAAAA==.',['小熊']='小熊呼噜噜:BAAAKgAFFAgIBAAAAA==.',['小牛']='小牛排:BAAAKgAECggICAAAAA==.',['小白']='小白剑:BAAAKgAECgIIAgAAAA==.',['小盟']='小盟:BAAAKgAECgYICQAAAA==.',['小美']='小美好:BAAAKgAECggIDQAAAA==.',['山兜']='山兜口兜山:BAAAKgADCgIIAgAAAA==.',['山城']='山城棒棒军:BAAAKgAECgcICwAAAA==.',['左辰']='左辰右米:BAABKgAFFH8KAAIEAAYIxhz2JwBIAQAEAAYIxhz2JwBIAQAAAA==.',['希尔']='希尔瓦娜丝:BAAAKgADCggICAAAAA==.',['幽色']='幽色玫瑰:BAAAKgAFFAMIBAAAAA==.',['彩笔']='彩笔痴横爱吊:BAABKgAECn8VAAIVAAgI1hv/BQBHAgAVAAgI1hv/BQBHAgAAAA==.',['影轩']='影轩:BAAAKgAFFAIIBAAAAA==.',['徐达']='徐达:BAAAKgADCgIIAwAAAA==.',['恶魔']='恶魔追击:BAAAKgAFFAYIBAAAAA==.',['惜别']='惜别:BAAAKgADCgMIAwAAAA==.',['感觉']='感觉一般般:BAABKgAFFH8KAAIDAAQIQBS4GQDeAAADAAQIQBS4GQDeAAABKgAFFAgIAgAWAAAAAA==.',['慕容']='慕容云雪:BAAAKgADCggICAAAAA==.慕容千叶:BAAAKgAECgYIBgAAAA==.',['撒旦']='撒旦法则:BAAAKgAECggICAAAAA==.',['斯图']='斯图卡:BAAAKgAFFAQIBAAAAA==.',['无尾']='无尾狼:BAAAKgAECgIIAgAAAA==.',['无情']='无情岁月:BAAAKgADCgUIBQAAAA==.',['无法']='无法定义:BAAAKgAFFAQIBAAAAA==.',['无锡']='无锡彭于晏丶:BAAAKgAFFAQIBAAAAA==.',['昊乁']='昊乁:BAAAKgAECgMIAwAAAA==.',['春风']='春风惊雷化雨:BAAAKgAFFAIIAgAAAA==.',['晴炎']='晴炎汐雨:BAABKgAFFH8IAAISAAQIsyKYDQAfAQASAAQIsyKYDQAfAQAAAA==.',['暗女']='暗女精灵:BAAAKgAECgcIEAAAAA==.',['暗心']='暗心天堂:BAAAKgAECgEIAQAAAA==.',['望月']='望月呆呆兽:BAAAKgAECggIDwABKgAFFAQIHAAXADMbAA==.',['期盼']='期盼丶丶:BAAAKgAECgMIAwAAAA==.',['李下']='李下小德:BAAAKgAECgcICAAAAA==.李下小法:BAAAKgAECgYIBgAAAA==.李下小牧:BAABKgAFFH8IAAIPAAgIxBC3BQC4AQAPAAgIxBC3BQC4AQAAAA==.李下小猎:BAAAKgAFFAQIBAAAAA==.李下小骑:BAAAKgADCggICAAAAA==.',['条条']='条条:BAABKgAFFH8SAAQQAAYIWBQRCgBgAQAQAAYIWBQRCgBgAQAOAAQIWBsGDAD1AAAPAAEIoSJrHwBgAAABKgAFFAgICgAPANkWAA==.',['林依']='林依依:BAAAKgADCggICAAAAA==.',['枫花']='枫花恋:BAAAKgAFFAIIAgAAAA==.',['柒伤']='柒伤轩辕:BAAAKgAECgMIAwAAAA==.',['柒筱']='柒筱柒:BAABKgAECn8kAAQNAAcI0yHgEQBTAQANAAUIAB/gEQBTAQAMAAcIRhWnTwAqAQAGAAMIlBk/TwCrAAAAAA==.',['桩桩']='桩桩多:BAAAKgAECgMIAwAAAA==.',['梅花']='梅花十三:BAAAKgAECgMIBAAAAA==.',['歌丶']='歌丶暮:BAAAKgAECggICAAAAA==.歌丶翎:BAAAKgAECggICAAAAA==.',['死胖']='死胖子:BAABKgAECn8ZAAMTAAgIXBvdJgAeAgATAAgIXBvdJgAeAgAYAAMI6wfBUgAtAAAAAA==.',['毁凌']='毁凌:BAAAKgAECgEIAQAAAA==.',['毁崚']='毁崚:BAAAKgAECgYIBgAAAA==.',['毁爺']='毁爺:BAAAKgAECgMIAwAAAA==.',['毁绫']='毁绫:BAAAKgAECgIIAgAAAA==.',['比奇']='比奇堡派大星:BAAAKgAECgYICQAAAA==.',['毛毛']='毛毛虫美女:BAAAKgAECgQIAwAAAA==.',['沐璃']='沐璃晴:BAACKgAFFH8MAAIRAAMIcwfyQgChAAARAAMIcwfyQgChAAAqAAQKfxUAAhEACAhiE1hNAIIBABEACAhiE1hNAIIBAAAA.',['没研']='没研究过:BAAAKgAECgYIBgAAAA==.',['沫小']='沫小滥:BAAAKgAFFAYIAgAAAA==.',['法力']='法力无双:BAAAKgAECggIDQAAAA==.',['洛濏']='洛濏玛:BAAAKgAECgUIBQAAAA==.',['流星']='流星刹那:BAAAKgAECggIEAAAAA==.',['浴竖']='浴竖凌峰:BAAAKgADCggICAAAAA==.',['潇洒']='潇洒依然:BAAAKgAECgQIBAAAAA==.',['澟冬']='澟冬將至:BAAAKgAFFAQIBAAAAA==.',['澳门']='澳门首家:BAAAKgAFFAQIBAAAAA==.',['灬糖']='灬糖喵喵:BAACKgAFFH8MAAIPAAMIEhTuEgCrAAAPAAMIEhTuEgCrAAAqAAQKfxoAAw8ACAhvE+I0AGwBAA8ACAhvE+I0AGwBAA4AAgjuCGh3AEAAAAAA.',['灯火']='灯火阑珊:BAAAKgAECgYIEAAAAA==.',['灵娲']='灵娲:BAAAKgAFFAMIAgAAAA==.',['灵异']='灵异楼兰:BAAAKgAECgUIBgAAAA==.',['点亮']='点亮世界:BAAAKgAECgQIBgAAAA==.',['熊熊']='熊熊猫猫鹌鹑:BAAAKgAECgYIBgAAAA==.',['熬夜']='熬夜:BAAAKgADCggICAAAAA==.',['狂野']='狂野之刃:BAACKgAFFH8FAAIJAAMIawwWGQDBAAAJAAMIawwWGQDBAAAqAAQKfxkAAgkABgiOGJAnAH4BAAkABgiOGJAnAH4BAAAA.狂野的猫:BAAAKgADCgQIBAAAAA==.',['狼王']='狼王归来:BAAAKgADCggICAAAAA==.',['玛琺']='玛琺里奥:BAAAKgAFFAEIAgAAAA==.',['玩转']='玩转地球:BAAAKgADCggIDwAAAA==.',['琪琪']='琪琪:BAAAKgAFFAEIAQAAAA==.',['璍皣']='璍皣:BAABKgAFFH8OAAMZAAYIMSJwAgC8AQAZAAYIMSJwAgC8AQAYAAQI5wRDLABjAAABKgAFFAgIAwAWAAAAAA==.',['璟璘']='璟璘:BAABKgAECn8WAAMaAAgI/A+pEAAdAQAaAAgI/A+pEAAdAQAVAAcIFA2tMwAXAQAAAA==.',['璟霖']='璟霖:BAAAKgADCggICAAAAA==.',['甜刃']='甜刃:BAAAKgAECggICAAAAA==.',['甜炎']='甜炎蜜雨:BAABKgAFFH8QAAMEAAYIQg+1KgA8AQAEAAYIQg+1KgA8AQAHAAQI7xTOBgDjAAABKgAFFAgIEAAQAFsKAA==.',['甜甜']='甜甜起司喵:BAABKgAFFH8LAAIPAAMI5AVAMACFAAAPAAMI5AVAMACFAAAAAA==.',['疯子']='疯子是我:BAAAKgADCggICAAAAA==.',['白斩']='白斩鸭:BAABKgAFFH8OAAIUAAYIDhcAFgBHAQAUAAYIDhcAFgBHAQAAAA==.',['白河']='白河仇:BAAAKgADCgIIAgAAAA==.',['白胡']='白胡子老爷爷:BAAAKgADCgUIBQAAAA==.',['盲夜']='盲夜:BAAAKgADCgEIAQAAAA==.',['真的']='真的随便睡:BAAAKgAECgEIAQAAAA==.',['神圣']='神圣愤怒:BAAAKgAECgQICAAAAA==.',['秀炎']='秀炎秀雨:BAABKgAFFH8IAAMXAAQIOQ+PDwCcAAAXAAQIOQ+PDwCcAAARAAMIohYVJwCXAAAAAA==.',['秋冬']='秋冬夜未凉:BAAAKgAECgEIAQAAAA==.',['秦兰']='秦兰德丶语风:BAAAKgAECgYIBgAAAA==.',['笑笑']='笑笑潘帅:BAAAKgADCgEIAQAAAA==.',['索拉']='索拉亇:BAAAKgAECgEIAQAAAA==.',['红泥']='红泥小火炉:BAAAKgADCgYIBgAAAA==.',['红莲']='红莲玄玄:BAAAKgAFFAIIAgAAAA==.',['罒尛']='罒尛喪翼:BAAAKgAFFAQIBAAAAA==.罒尛喪黑:BAACKgAFFH8XAAIEAAQIcBtpQwDoAAAEAAQIcBtpQwDoAAAqAAQKfxQAAwQABwhpFL27ACIBAAQABwhpFL27ACIBAAgABgi8BMFBAHgAAAAA.',['羊咩']='羊咩咩灬:BAAAKgAECgMIAwAAAA==.',['老刘']='老刘:BAAAKgADCgEIAQAAAA==.',['老子']='老子逢刷必有:BAABKgAFFH8GAAIEAAYItx1CFAC6AQAEAAYItx1CFAC6AQAAAA==.',['老木']='老木增春:BAAAKgAECgEIAQAAAA==.',['耐萨']='耐萨里嗷:BAAAKgAECgIIAgAAAA==.',['职业']='职业基友:BAAAKgAECgIIAgAAAA==.',['聖光']='聖光天堂:BAAAKgAECgMIAQAAAA==.',['肥嘟']='肥嘟嘟:BAAAKgAECgcICQAAAA==.',['舞的']='舞的神话:BAAAKgAECggIDQAAAA==.',['花簇']='花簇满楼:BAAAKgAECggICAAAAA==.',['若水']='若水丨时沙:BAAAKgAECgQIBAAAAA==.',['苦海']='苦海孤雏:BAAAKgAECgMIAwAAAA==.',['范德']='范德彪丶:BAAAKgADCggICgAAAA==.',['菲的']='菲的神话:BAABKgAECn8hAAIDAAgIaBiIEAD0AQADAAgIaBiIEAD0AQAAAA==.',['萌娜']='萌娜俪莎:BAABKgAECn8rAAMbAAgIuRm4BAAyAgAbAAgIuRm4BAAyAgAcAAYItApITQDKAAAAAA==.',['萨拉']='萨拉托加:BAAAKgAFFAIIAgAAAA==.',['董董']='董董盼盼:BAAAKgAFFAIIAwAAAA==.',['葬爱']='葬爱丶妖孽:BAAAKgADCgEIAQAAAA==.',['蒜小']='蒜小叶:BAACKgAFFH8YAAIXAAQI4RGEDwC3AAAXAAQI4RGEDwC3AAAqAAQKfxYAAxcACAgcDQ8+ABkBABcACAgcDQ8+ABkBABEAAwhZDpKnAIMAAAAA.',['虎哥']='虎哥就是传说:BAAAKgAECgMIBQAAAA==.虎哥是个传说:BAABKgAECn8dAAMZAAgIdRsPBgAyAgAZAAgIbhkPBgAyAgATAAgILhD7TAA/AQAAAA==.',['蛋蛋']='蛋蛋色:BAAAKgAECgUIBwAAAA==.',['血染']='血染风采:BAABKgAECn8YAAIEAAgIFRJEawCCAQAEAAgIFRJEawCCAQAAAA==.',['西奥']='西奥:BAAAKgAECgEIAQAAAA==.',['西风']='西风烈:BAAAKgAECgMIAwAAAA==.',['要了']='要了老命:BAACKgAFFH8KAAMZAAMIqxGqCwC/AAAZAAMIqxGqCwC/AAATAAEIfA6ULwBKAAAqAAQKfyMAAxkACAi8HA8KAAsCABkACAi8HA8KAAsCABMAAwjmE1upAHoAAAAA.',['诸葛']='诸葛武侯:BAAAKgAECggICAAAAA==.诸葛钢钉:BAABKgAFFH8IAAISAAgIXgfkCQCnAQASAAgIXgfkCQCnAQAAAA==.诸葛钢铁:BAAAKgAECgMIAwAAAA==.',['谦大']='谦大叔:BAAAKgAFFAEIAQAAAA==.',['豚豚']='豚豚必定欧:BAABKgAFFH8IAAMRAAgIJBYVCgDzAQARAAcItRgVCgDzAQAXAAEIfAMnNwA/AAAAAA==.',['超究']='超究武神霸斩:BAAAKgADCgIIAgAAAA==.',['超超']='超超冰柠茶:BAAAKgAFFAYIBAAAAA==.超超可爱多:BAAAKgAFFAQIBAAAAA==.超超大魔王:BAAAKgAFFAgIBAAAAA==.超超宠哲哲:BAAAKgAECggICAAAAA==.超超爱做梦:BAAAKgADCggICAAAAA==.超超爱滑雪:BAAAKgAECggICAAAAA==.超超爱睡觉:BAAAKgAECggICAAAAA==.超超秋风萧瑟:BAAAKgAFFAgIBAAAAA==.',['跟老']='跟老黑有肉吃:BAAAKgAECgMIAwAAAA==.',['辰晞']='辰晞:BAABKgAECn8bAAMPAAgIRRlYJQChAQAPAAgIRRlYJQChAQAQAAQI1xBdJgCdAAAAAA==.',['迪恺']='迪恺娜:BAABKgAFFH8IAAIOAAgIBBv9AgA9AgAOAAgIBBv9AgA9AgAAAA==.',['邪歌']='邪歌:BAAAKgAFFAIIAgAAAA==.',['酷哦']='酷哦:BAAAKgADCgcIBwAAAA==.',['阿姨']='阿姨洗鐵路:BAAAKgADCgEIAQAAAA==.',['阿猛']='阿猛小朋友:BAABKgAECn8fAAIdAAgI8hmrBQAYAgAdAAgI8hmrBQAYAgAAAA==.',['隽炎']='隽炎妙雨:BAAAKgAECggICAAAAA==.',['集火']='集火那个萨满:BAAAKgADCggICAAAAA==.',['雨打']='雨打浮萍:BAAAKgAECgIIAgAAAA==.',['颜尹']='颜尹尘:BAAAKgAFFAEIAQAAAA==.',['风吹']='风吹悠悠:BAAAKgAECgUIBQAAAA==.风吹拂兰:BAAAKgAECgcIAwAAAA==.',['风见']='风见唯花:BAAAKgADCgQIBAAAAA==.风见小香:BAAAKgADCggICAAAAA==.',['风雨']='风雨潇潇:BAAAKgAFFAYIAQAAAA==.',['飒飒']='飒飒如歌:BAAAKgAECgcICgAAAA==.',['香莲']='香莲:BAABKgAFFH8FAAIVAAUIPAaMFADBAAAVAAUIPAaMFADBAAAAAA==.',['骑在']='骑在她身上:BAAAKgAECgQIBQAAAA==.',['高山']='高山堂之拥戴:BAAAKgADCgIIAgAAAA==.',['鬼舞']='鬼舞日鸡:BAABKgAFFH8TAAIeAAYIAB0kBABSAQAeAAYIAB0kBABSAQAAAA==.',['魑魅']='魑魅魍魉妖魔:BAABKgAFFH8MAAMRAAYI1hKjDwByAQARAAYI1hKjDwByAQAXAAYI2BKeCQBtAQAAAA==.',['黄闪']='黄闪闪:BAAAKgAECggICAAAAA==.',['默然']='默然冷对:BAAAKgAECgUICAAAAA==.',['龙之']='龙之奥:BAAAKgAECgMIAwAAAA==.',['龙晶']='龙晶:BAABKgAFFH8IAAIYAAgI4gL5EgAKAQAYAAgI4gL5EgAKAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end