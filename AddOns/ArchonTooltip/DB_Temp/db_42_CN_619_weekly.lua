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
 local lookup = {'Paladin-Retribution','Priest-Shadow','Paladin-Protection','Warrior-Arms','Warrior-Fury','Hunter-Marksmanship','Monk-Mistweaver','Mage-Arcane','Paladin-Holy','Hunter-BeastMastery','Warrior-Protection','Mage-Fire','Mage-Frost','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DemonHunter-Havoc','Shaman-Restoration','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Shaman-Enhancement','Priest-Holy','Priest-Discipline','Druid-Guardian','Rogue-Assassination','DemonHunter-Vengeance','Druid-Balance','Druid-Restoration',}; local provider = {region='CN',realm='埃苏雷格',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aaliyah:BAABKgAFFH8LAAIBAAQIchW+HQDuAAABAAQIchW+HQDuAAAAAA==.',Ak='Akiraovo:BAAAKgAECggICAAAAA==.',Ar='Artemisia:BAAAKgAECgcIBwAAAA==.',At='Atreter:BAAAKgAECgYICwAAAA==.',Au='Aurona:BAAAKgAECggICgAAAA==.',Bl='Blueeyess:BAABKgAECn8pAAICAAgImhNqHgCSAQACAAgImhNqHgCSAQAAAA==.',Bo='Boxer:BAAAKgAFFAEIAQAAAA==.',Du='Dumbledore:BAAAKgAECggIEAAAAA==.',Fl='Floraovo:BAAAKgAECggICAAAAA==.',Fo='Fouocokoeor:BAAAKgAECggIDAAAAA==.',Ha='Hastalavista:BAAAKgAFFAIIAwAAAA==.',Ho='Hoka:BAAAKgAECgEIAQAAAA==.Howsmile:BAAAKgADCgQIBAAAAA==.',La='Lai:BAAAKgADCgQIBAAAAA==.',Lu='Luckywu:BAAAKgAECgIIAwAAAA==.',Mi='Milkisgy:BAAAKgADCgMIAwAAAA==.',Na='Narmaya:BAAAKgADCgYIBgAAAA==.',Po='Polymorph:BAAAKgADCggICAAAAA==.',Ra='Razuvious:BAAAKgAECggICQAAAA==.',Re='Recordare:BAACKgAFFH8OAAIDAAQI/BEvCwC0AAADAAQI/BEvCwC0AAAqAAQKfysAAgMACAiCGYwXALABAAMACAiCGYwXALABAAAA.',Si='Sissipapa:BAABKgAFFH8PAAMEAAgIdA7ECwBRAQAEAAQIdBPECwBRAQAFAAYIgQZKEgA1AQAAAA==.',So='Sorcerer:BAAAKgADCgYIBgAAAA==.',St='Staratlas:BAABKgAFFH8FAAIGAAUIXRHWGgAXAQAGAAUIXRHWGgAXAQAAAA==.',Te='Teardrop:BAAAKgAECgIIAgAAAA==.Tearra:BAAAKgADCgUIBQAAAA==.',['一支']='一支穿雲箭:BAAAKgAECgEIAQAAAA==.',['七月']='七月的秋刀鱼:BAABKgAFFH8LAAIHAAMI1hvOFgDsAAAHAAMI1hvOFgDsAAAAAA==.',['不够']='不够成熟啊:BAAAKgADCggICAAAAA==.',['世界']='世界飒:BAAAKgAECggICAAAAA==.',['丨银']='丨银翼丨:BAAAKgAECgUIBQAAAA==.',['乱夜']='乱夜月:BAAAKgAFFAQIBAAAAA==.',['二人']='二人游:BAABKgAFFH8GAAIIAAYIFxXoGAAdAQAIAAYIFxXoGAAdAQAAAA==.',['亥克']='亥克:BAAAKgADCggICAAAAA==.',['亲爱']='亲爱的明天:BAAAKgAECgYIBwAAAA==.',['仙气']='仙气飘飘:BAABKgAECn8dAAIGAAgIzBPIMwCNAQAGAAgIzBPIMwCNAQAAAA==.',['会飞']='会飞的蜗牛:BAAAKgAECgUIBQAAAA==.',['依旧']='依旧随风:BAAAKgADCggICAAAAA==.',['侠骨']='侠骨仁心:BAAAKgAECggICAAAAA==.',['倔强']='倔强的山峰:BAABKgAFFH8GAAIFAAQIXgngFQDZAAAFAAQIXgngFQDZAAAAAA==.',['光之']='光之暗影:BAABKgAFFH8QAAQBAAYIRxgKCwAqAQABAAQIBh8KCwAqAQADAAYIkxH2DgARAQAJAAQINxj6BAD6AAAAAA==.',['光明']='光明之锤:BAAAKgAECgQIBAAAAA==.光明裂痕:BAACKgAFFH8IAAIKAAgI6RZ5BQBDAgAKAAgI6RZ5BQBDAgAqAAQKfy0AAgoACAhvFjc5AMABAAoACAhvFjc5AMABAAAA.',['冖大']='冖大哥洋冖:BAAAKgADCggIDAAAAA==.',['冰镇']='冰镇西瓜:BAAAKgADCggICAAAAA==.',['凡灵']='凡灵若槿:BAAAKgAECgcICwAAAA==.',['别拔']='别拔我图腾:BAAAKgAECgQICAAAAA==.',['别掰']='别掰我大牙:BAABKgAECn8eAAIDAAgIMhYICADGAQADAAgIMhYICADGAQAAAA==.',['卡拉']='卡拉肖克德:BAAAKgADCggICAAAAA==.',['史帝']='史帝芬席格:BAAAKgAFFAgIBAAAAA==.',['吃的']='吃的好睡的香:BAABKgAECn8YAAMLAAgIPQwwJgD6AAALAAgIkwswJgD6AAAFAAgI7QW8LAB9AAAAAA==.',['吾法']='吾法無天:BAAAKgADCgYIBgAAAA==.',['呀咩']='呀咩嗲:BAABKgAFFH8PAAMMAAYIjReVDABtAQAMAAYIjReVDABtAQAIAAYImg68DgBLAQABKgAFFAgIEAAMAKcaAA==.',['喝多']='喝多了也吐:BAAAKgADCgYIBgAAAA==.',['圣丶']='圣丶光丨:BAABKgAECn8iAAIBAAgIDCIlLABPAgABAAgIDCIlLABPAgAAAA==.',['墨陌']='墨陌默默:BAACKgAFFH8dAAQMAAQIhiCiDwAZAQAMAAQIhiCiDwAZAQAIAAMIGAtOPgBjAAANAAEIABs2IQA7AAAqAAQKfyYAAwwACAg4JIoIAM0CAAwACAg4JIoIAM0CAA0ABAjwFk93AKYAAAAA.',['夏天']='夏天的风:BAABKgAECn8sAAQOAAgIeCJYFABQAQAOAAcIgh9YFABQAQAPAAMIoSRZNwAvAQAQAAIIGiEZbwBaAAAAAA==.',['夜舞']='夜舞清风:BAABKgAFFH8FAAIRAAQI2xr1JwDWAAARAAQI2xr1JwDWAAAAAA==.',['大丁']='大丁怪:BAAAKgADCgcIBwAAAA==.',['大二']='大二红八:BAAAKgADCgEIAQAAAA==.',['大棒']='大棒:BAAAKgAECgUICQAAAA==.',['大苏']='大苏打啊实:BAABKgAFFH8OAAISAAQIXgdhIACCAAASAAQIXgdhIACCAAAAAA==.',['大角']='大角牛屠夫:BAAAKgAFFAMIAwAAAA==.',['天堂']='天堂光彩:BAABKgAECn8ZAAISAAgIgRRqRgBfAQASAAgIgRRqRgBfAQAAAA==.',['天风']='天风咲夜:BAACKgAFFH8ZAAQTAAMITCDPBgAAAQATAAMITCDPBgAAAQAUAAMIGw4FJQCEAAAVAAIIrBAZSACAAAAqAAQKfy4AAxQACAguEeIpAD0BABQACAgEEeIpAD0BABUAAQgkHeC5AFcAAAAA.',['太平']='太平洋的鱼:BAABKgAECn8jAAINAAcI9RJmLgBQAQANAAcI9RJmLgBQAQAAAA==.',['宇宙']='宇宙飒:BAABKgAECn8VAAMGAAgIJRVDMACeAQAGAAgIVRRDMACeAQAKAAMIphJvVwBGAAAAAA==.',['寂静']='寂静的归途:BAAAKgADCggICAAAAA==.',['小宋']='小宋贼好看:BAAAKgAECgYIBgAAAA==.',['小张']='小张真丑:BAAAKgAECgEIAQAAAA==.',['小花']='小花:BAEBKgAFFH8IAAIWAAQIoSOdBAA9AQAWAAQIoSOdBAA9AQABKgAFFAgIBgAWAK4TAA==.',['尘缘']='尘缘萌:BAAAKgAECgYIBgAAAA==.',['尼卡']='尼卡:BAAAKgAFFAQIBAAAAA==.',['布兰']='布兰琪:BAABKgAECn8oAAQXAAgIbR/vFwACAgAXAAgIbR/vFwACAgACAAYI9hO0QgDsAAAYAAEI4RIXegA6AAAAAA==.',['常闇']='常闇:BAABKgAFFH8FAAIIAAUIaRMCEQAVAQAIAAUIaRMCEQAVAQAAAA==.',['幽灵']='幽灵狼图腾:BAAAKgAFFAgIBAAAAA==.',['开心']='开心每一天:BAAAKgAECggIDQAAAA==.',['御术']='御术临风丶:BAAAKgAECgYIBwAAAA==.',['德薇']='德薇希安:BAAAKgAECgYICwAAAA==.',['心灵']='心灵羽翼:BAAAKgAECgEIAQAAAA==.',['忠爱']='忠爱螺蛳粉:BAAAKgADCgQIBAAAAA==.',['我不']='我不会奶:BAAAKgAECgQIBAAAAA==.我不会玩:BAAAKgAFFAQIBAAAAA==.',['才子']='才子:BAAAKgAFFAQIBAAAAA==.',['扛霸']='扛霸仔:BAAAKgAECgYICwAAAA==.',['斗玉']='斗玉戒指:BAAAKgADCggIDAAAAA==.',['斩丶']='斩丶灬:BAAAKgAFFAEIAQAAAA==.',['无知']='无知小僧:BAAAKgADCggICAAAAA==.',['无聊']='无聊的夏宇:BAABKgAFFH8IAAIZAAQIRwWjBgBlAAAZAAQIRwWjBgBlAAAAAA==.',['既要']='既要又要还要:BAAAKgAECgcIBwAAAA==.',['旺旺']='旺旺掀被:BAABKgAFFH8KAAMGAAYIqRRpFAA/AQAGAAYIQBJpFAA/AQAKAAQIxhcFMQDIAAAAAA==.',['暗黑']='暗黑狼王:BAAAKgAFFAYIAgAAAA==.',['月半']='月半小夜曲:BAAAKgAECgEIAwAAAA==.',['月夜']='月夜灬疾风:BAAAKgAECggIDwAAAA==.',['月逝']='月逝星落:BAABKgAFFH8UAAIHAAYIrxvOAgCiAQAHAAYIrxvOAgCiAQAAAA==.',['格兰']='格兰瑞尔:BAAAKgAECgYIBgAAAA==.',['梦回']='梦回长安夜:BAAAKgADCggICAAAAA==.',['棘骨']='棘骨:BAAAKgAECggICAAAAA==.',['洛漓']='洛漓丶雨道:BAABKgAECn8mAAISAAgI+hQ1OgCNAQASAAgI+hQ1OgCNAQAAAA==.',['海释']='海释靈:BAABKgAECn8WAAIBAAgIyiD4SQATAgABAAgIyiD4SQATAgAAAA==.',['渡厄']='渡厄:BAAAKgAECgUIBQAAAA==.',['潇洒']='潇洒叔:BAAAKgADCgIIAgAAAA==.',['潶咻']='潶咻潶咻:BAAAKgADCgUIBQAAAA==.',['灵梦']='灵梦:BAAAKgADCgQIBAABKgAECggIKQAGAF8fAA==.',['燃烧']='燃烧的冰:BAABKgAECn8pAAIaAAgIyiD0BwCMAgAaAAgIyiD0BwCMAgAAAA==.',['爱吃']='爱吃大西瓜:BAAAKgAECggIEwAAAA==.',['爱诺']='爱诺丶良月:BAAAKgAECgUICAAAAA==.',['牙灬']='牙灬丶:BAAAKgAECgUIBQAAAA==.',['牛犇']='牛犇犇:BAAAKgADCgMIAwAAAA==.',['玉郎']='玉郎卿丶:BAAAKgAECgQIBAAAAA==.',['珍珠']='珍珠:BAACKgAFFH8hAAMbAAYINhg/CgAFAQARAAUI3BxpGwAkAQAbAAUIVxM/CgAFAQAqAAQKf0QAAxEACAi0Ip8EAMUCABEACAjYIZ8EAMUCABsACAirIE8KAGgCAAAA.',['痛风']='痛风患者:BAAAKgAECggICAAAAA==.',['白玉']='白玉:BAACKgAFFH8RAAIBAAMIqyCPIADoAAABAAMIqyCPIADoAAAqAAQKfxYAAgEACAi1IgspAHgCAAEACAi1IgspAHgCAAEqAAUUBgghABsANhgA.',['盾灬']='盾灬丶:BAAAKgAFFAIIAgAAAA==.',['真硬']='真硬:BAAAKgAECgMIAwAAAA==.',['瞅见']='瞅见你辣眼睛:BAABKgAFFH8KAAIUAAYIMBGoCwDmAAAUAAYIMBGoCwDmAAAAAA==.',['石英']='石英:BAACKgAFFH8QAAMTAAQI2h6oBQAcAQATAAQI2h6oBQAcAQAUAAIIDwSJFAAtAAAqAAQKfxwABBMACAjrHHQHAE8CABMACAjhHHQHAE8CABUABwj0FVc6AIoBABQABgiWEgwoAAoBAAEqAAUUBgghABsANhgA.',['神秘']='神秘的菊花:BAAAKgADCggICAAAAA==.',['粉色']='粉色樱花醉:BAABKgAFFH8GAAIGAAYIYA1RFwAsAQAGAAYIYA1RFwAsAQAAAA==.',['罐头']='罐头盒:BAABKgAECn8YAAMUAAgIOhW2IgAzAQAUAAYIMha2IgAzAQAVAAUI5gxAjwC4AAAAAA==.',['聆听']='聆听雨眠:BAAAKgAFFAEIAQAAAA==.',['胖嘟']='胖嘟嘟的舒克:BAAAKgADCgcIDgAAAA==.',['菠菜']='菠菜二零零五:BAAAKgAECgMICgAAAA==.',['萨拉']='萨拉塔斯:BAAAKgAECgcIDwAAAA==.',['落落']='落落磊磊:BAAAKgAFFAgIBAAAAA==.',['蕙手']='蕙手:BAAAKgAECggIDQAAAA==.',['蛋蛋']='蛋蛋疼的一天:BAAAKgAECgQIBAAAAA==.',['血色']='血色灬死骑:BAAAKgAECgUIBQAAAA==.血色灬猎手:BAABKgAFFH8IAAIKAAgIcA87CQDfAQAKAAgIcA87CQDfAQAAAA==.',['装逼']='装逼就杀你:BAAAKgADCgUIBQAAAA==.',['西尼']='西尼的老鹿:BAAAKgAECgIIAgAAAA==.',['訫砕']='訫砕乌托:BAAAKgAFFAgIBAAAAA==.',['詠奏']='詠奏妖華:BAAAKgADCgEIAQAAAA==.',['豪横']='豪横:BAAAKgAECggICAAAAA==.',['贝优']='贝优妮塔:BAABKgAECn8pAAMGAAgIXx8PGQAvAgAGAAgIQh8PGQAvAgAKAAQIQxgnswC+AAAAAA==.',['赛勒']='赛勒斯:BAAAKgAECgMIAwAAAA==.',['超级']='超级玛莉:BAAAKgAECgcICwAAAA==.',['酒醉']='酒醉為紅顏:BAAAKgADCgMIAwAAAA==.',['金色']='金色指环:BAABKgAECn8eAAMBAAgIBhc8HgDLAQABAAgIBhc8HgDLAQADAAYIMgvxLwDdAAAAAA==.',['鑫鱻']='鑫鱻:BAABKgAFFH8HAAINAAQIxSInEQDZAAANAAQIxSInEQDZAAAAAA==.',['键盘']='键盘斗士:BAACKgAFFH8uAAQIAAgIhh/IBQA0AgAIAAgIhh/IBQA0AgAMAAQIWQ8AIAC2AAANAAEIFCDXGgBYAAAqAAQKf0IABAwACAgKJAAWAHACAAwACAjeIAAWAHACAAgABgjtI7kdAAQCAA0ABQi3Hk1iAOQAAAAA.',['锻造']='锻造闪电:BAAAKgAECgYICQAAAA==.',['阳光']='阳光玫瑰:BAAAKgAFFAIIAgAAAA==.',['阿吉']='阿吉利斯:BAAAKgAECggICAAAAA==.',['隔壁']='隔壁你庆哥:BAAAKgAFFAEIAQAAAA==.',['青柠']='青柠丶枂笙:BAAAKgADCggIDQAAAA==.',['非洲']='非洲使者:BAAAKgADCgEIAQAAAA==.',['风中']='风中的火焰:BAABKgAECn8uAAINAAgI0xBbKQBwAQANAAgI0xBbKQBwAQAAAA==.',['风语']='风语呢喃:BAAAKgADCggICAAAAA==.',['风铃']='风铃花:BAAAKgADCggICAAAAA==.',['飞天']='飞天遇见刘:BAABKgAECn8WAAIIAAgIIhmcHgD+AQAIAAgIIhmcHgD+AQAAAA==.',['食魂']='食魂者阿莱利:BAAAKgAECggIDwAAAA==.',['高巢']='高巢:BAAAKgAFFAIIAgAAAA==.',['高罺']='高罺:BAAAKgAECgcICwAAAA==.',['鬼少']='鬼少:BAABKgAECn8wAAIRAAgIVhxaHgARAgARAAgIVhxaHgARAgAAAA==.',['魂魄']='魂魄之怨:BAAAKgADCggICAAAAA==.魂魄之殇:BAAAKgADCgMIAwAAAA==.',['魔法']='魔法易伤:BAABKgAFFH8GAAIRAAYImQZfHgAQAQARAAYImQZfHgAQAQAAAA==.',['鲜于']='鲜于修:BAAAKgADCggICAAAAA==.',['鹏蓬']='鹏蓬:BAAAKgADCggICAAAAA==.',['黃昏']='黃昏的邂逅:BAACKgAFFH8PAAMEAAMI7h9MCwDAAAAFAAMI8Rj6EADrAAAEAAIIICBMCwDAAAAqAAQKfxYAAwUABwjxIpUeAN4BAAUABgi8I5UeAN4BAAQABgjYIIkgAIABAAAA.',['黑山']='黑山老牛:BAAAKgAECgIIAgAAAA==.',['黑色']='黑色的沉默:BAAAKgAECgUIBQAAAA==.',['龙少']='龙少:BAAAKgADCgMIAwAAAA==.',['龙柏']='龙柏虎宝:BAABKgAFFH8OAAMcAAgI2hlzCwDeAQAcAAcIjhlzCwDeAQAdAAMI9hOkGQB0AAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end