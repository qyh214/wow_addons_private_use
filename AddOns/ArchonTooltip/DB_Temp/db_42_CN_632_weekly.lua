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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Warrior-Fury','Warrior-Arms','Mage-Frost','Mage-Fire','Mage-Arcane','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','DemonHunter-Havoc','Shaman-Restoration','DeathKnight-Blood','Hunter-Survival','Druid-Restoration','Rogue-Assassination',}; local provider = {region='CN',realm='大漩涡',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Anhe:BAAAKgADCggICAAAAA==.',Ba='Baby:BAAAKgAECgcIDwAAAA==.Babys:BAAAKgADCgIIAgAAAA==.',Ce='Ceres:BAAAKgAFFAIIAwAAAA==.',Cr='Crius:BAABKgAFFH8MAAMBAAMImRZmRQDkAAABAAMImRZmRQDkAAACAAMIngjqDwCCAAAAAA==.',Da='Darkwater:BAAAKgAECgcIBwAAAA==.',Fa='Fanker:BAAAKgADCgYIBgAAAA==.',Ic='Icedruid:BAAAKgAFFAIIAgAAAA==.Icemist:BAAAKgAECgQIBQAAAA==.',Jj='Jjohsonl:BAAAKgADCgcIBwAAAA==.',Jo='Josonh:BAAAKgADCggICAAAAA==.',Ju='Juriueno:BAAAKgAFFAQIBAAAAA==.',Ni='Niubility:BAAAKgADCgcIBwAAAA==.',Oo='Oov:BAACKgAFFH8VAAMDAAMIlw24BwDAAAADAAMIlw24BwDAAAAEAAEIbAn8HQA7AAAqAAQKfxcABAQACAjgFL8cAKABAAQACAgOFL8cAKABAAMAAgiUCQ43AFUAAAUAAQjfE+CJADsAAAAA.',Pl='Playervunodj:BAABKgAFFH8GAAMGAAYIgxKYDQAFAQAGAAQIFRqYDQAFAQAHAAIIKQeTDgCnAAAAAA==.',Sg='Sgalvatron:BAAAKgAFFAQIBAAAAA==.',Ti='Tiamo:BAABKgAFFH8bAAQIAAYIexrQBAALAQAJAAYIRA7LBQBcAQAKAAYInRAHFABFAQAIAAYIexrQBAALAQABKgAFFAgIHAALADYlAA==.',Wa='Wallsay:BAABKgAFFH8MAAMBAAQIxRtBPAD9AAABAAQIxRtBPAD9AAACAAEIOABkMAAOAAAAAA==.',Wh='Whitejack:BAABKgAFFH8GAAMMAAQIqh+kOQCDAAAMAAII3RKkOQCDAAANAAQIqh8AAAAAAAAAAA==.',Xl='Xl:BAAAKgADCgEIAQAAAA==.',['一包']='一包薯条:BAAAKgAFFAQIBAAAAA==.',['不会']='不会游泳鸭子:BAACKgAFFH8GAAIMAAMINQj2IQCXAAAMAAMINQj2IQCXAAAqAAQKfxYAAgwACAgaFTMWANIBAAwACAgaFTMWANIBAAAA.',['不悔']='不悔梦归处:BAABKgAFFH8fAAMBAAgISiPWAwCiAgABAAgISiPWAwCiAgACAAgIXAeuBwBIAQAAAA==.',['丑时']='丑时:BAAAKgAFFAQIBAABKgAFFAgIGgACADESAA==.',['丶小']='丶小小潘:BAAAKgAFFAQIBAAAAA==.',['之呜']='之呜昂波一:BAABKgAFFH8IAAIOAAgIVQ63CQDxAQAOAAgIVQ63CQDxAQAAAA==.',['乌琵']='乌琵尔:BAAAKgAECgEIAQAAAA==.',['争分']='争分夺秒:BAAAKgAECgMIAwAAAA==.',['二階']='二階堂:BAAAKgAFFAYIAgAAAA==.',['休闲']='休闲老饕:BAAAKgAECgEIAQAAAA==.',['伯爵']='伯爵:BAAAKgADCgEIAQAAAA==.',['伺机']='伺机待发硬币:BAAAKgAFFAMIBAAAAA==.',['似水']='似水泠洛:BAAAKgAECgUIBQAAAA==.',['你丫']='你丫没蛋:BAAAKgADCgMIAwAAAA==.',['你写']='你写吸佳佳吗:BAABKgAFFH8QAAMMAAMIRBOBMACYAAAMAAIIUxuBMACYAAANAAMIlgkqOACVAAAAAA==.',['再硬']='再硬:BAAAKgADCgUIBQAAAA==.',['再进']='再进去一点点:BAAAKgADCgcIBwAAAA==.',['凤梨']='凤梨柠檬:BAAAKgADCggICwAAAA==.',['凯哈']='凯哈弗茨:BAAAKgAFFAYIBAAAAA==.',['出招']='出招怪伤害快:BAAAKgAECggIDQAAAA==.',['别装']='别装感叹:BAAAKgAECgMIAwAAAA==.',['勇敢']='勇敢牛牛:BAAAKgADCgQIBAAAAA==.',['午夜']='午夜教授张:BAAAKgAECgIIAgAAAA==.',['卖咸']='卖咸鱼的老谭:BAACKgAFFH8KAAMCAAcIKBVXDQAlAQACAAUIMRNXDQAlAQABAAIIEhpEcQCIAAAqAAQKfygAAwEACAgCGexbAKsBAAEABwjyG+xbAKsBAAIAAQhlB2xoABQAAAAA.',['南瓜']='南瓜甜汤:BAAAKgAECgQIBAAAAA==.',['博闻']='博闻爸爸:BAABKgAFFH8KAAIPAAgI0BjpBABoAgAPAAgI0BjpBABoAgAAAA==.',['卢云']='卢云云:BAAAKgAECgMIBAAAAA==.',['可儿']='可儿的波克比:BAABKgAFFH8YAAIBAAgIgCFABACXAgABAAgIgCFABACXAgAAAA==.',['吃饱']='吃饱了睡:BAAAKgAFFAgIAwAAAA==.',['吾的']='吾的蕾蕾:BAABKgAFFH8GAAIBAAIIzxkGbACTAAABAAIIzxkGbACTAAAAAA==.',['咕噜']='咕噜咕噜:BAAAKgAFFAEIAQAAAA==.',['哇咔']='哇咔吧咔:BAAAKgAFFAIIAgAAAA==.',['哎嗨']='哎嗨唷:BAABKgAECn8ZAAIQAAcIhwZIgQDDAAAQAAcIhwZIgQDDAAAAAA==.',['唯美']='唯美式丶恋:BAAAKgAECggIBwAAAA==.',['喵星']='喵星人皇:BAAAKgADCggICQAAAA==.',['嗜血']='嗜血斩:BAAAKgADCgcIBwAAAA==.',['嗨哟']='嗨哟喂:BAAAKgAECgEIAQAAAA==.',['嘎嘣']='嘎嘣脆:BAABKgAFFH8GAAIPAAYIwBC4FQBMAQAPAAYIwBC4FQBMAQAAAA==.',['四费']='四费硬币山岭:BAAAKgADCgYIBgAAAA==.',['塔隆']='塔隆尼库斯:BAAAKgAECgYIBgAAAA==.',['大头']='大头菇:BAAAKgADCggICAAAAA==.',['大宗']='大宗师灬悟:BAAAKgAECggICAAAAA==.',['大郎']='大郎不喝药:BAAAKgAECgUIDwAAAA==.',['天堂']='天堂星辰:BAABKgAFFH8MAAIFAAgI2hh1BAA9AgAFAAgI2hh1BAA9AgAAAA==.',['子爵']='子爵:BAAAKgADCgEIAQAAAA==.',['孤独']='孤独的美食家:BAABKgAFFH8MAAMOAAYIniGACwDVAQAOAAYI/CCACwDVAQARAAYIRRvDCQB5AQAAAA==.',['寒冰']='寒冰火焰:BAAAKgADCgQIBAAAAA==.',['小小']='小小枫叶:BAABKgAFFH8KAAINAAYIgBmwDQCAAQANAAYIgBmwDQCAAQAAAA==.',['小牛']='小牛圣三一:BAAAKgAECgYIBwAAAA==.',['屍臭']='屍臭河馬:BAAAKgAECggICAAAAA==.',['山野']='山野小熊:BAAAKgADCgMIAwAAAA==.',['幻雪']='幻雪冰风:BAABKgAFFH8GAAIMAAYIshueDAAfAQAMAAYIshueDAAfAQAAAA==.',['張教']='張教授:BAAAKgAFFAQIAQAAAA==.',['思無']='思無邪:BAABKgAFFH8KAAIRAAYIziWIBAAIAgARAAYIziWIBAAIAgAAAA==.',['恺凯']='恺凯楷:BAABKgAFFH8GAAIOAAYINwd3DQAlAQAOAAYINwd3DQAlAQAAAA==.',['悲葛']='悲葛易水:BAAAKgADCggICAAAAA==.',['我勒']='我勒个逗:BAABKgAFFH8GAAIMAAYIqx2kDwB+AQAMAAYIqx2kDwB+AQAAAA==.',['我有']='我有两个帽衫:BAAAKgADCgEIAQAAAA==.',['我的']='我的大肚腩:BAAAKgAECgIIAgAAAA==.',['战于']='战于野:BAAAKgAECgIIAgAAAA==.',['拜蒙']='拜蒙:BAAAKgAFFAYIAgAAAA==.',['摄氏']='摄氏度:BAAAKgAECgUIBwAAAA==.',['无妄']='无妄之徒:BAAAKgAECgUICAAAAA==.',['时光']='时光背面的我:BAAAKgAECgQIBAAAAA==.',['星星']='星星点月:BAABKgAECn8ZAAMNAAgIwRGZOQBxAQANAAgIwRGZOQBxAQASAAUI8QWkDwDUAAAAAA==.星星点点:BAABKgAECn8aAAIGAAgI4gvDNwBFAQAGAAgI4gvDNwBFAQAAAA==.',['星魂']='星魂猎:BAABKgAFFH8JAAIMAAMIPRoDJgDuAAAMAAMIPRoDJgDuAAAAAA==.',['晓梦']='晓梦:BAAAKgAFFAQIBAAAAA==.',['月亮']='月亮与六便士:BAAAKgAECgEIAQAAAA==.',['月魔']='月魔:BAAAKgADCgQIBAAAAA==.月魔法:BAAAKgADCgMIAwAAAA==.',['枫叶']='枫叶爱熙:BAAAKgAECgQIBAAAAA==.枫叶爱琦:BAABKgAFFH8JAAMIAAQIhxeEDgC0AAAIAAQIhxeEDgC0AAAJAAEIAAAORAAAAAAAAA==.',['梵尘']='梵尘丨小小猎:BAAAKgAECgEIAQAAAA==.',['汝可']='汝可识得此阵:BAAAKgAECgMIAwAAAA==.',['沉着']='沉着的魔尼尼:BAAAKgADCgEIAQAAAA==.',['沐羽']='沐羽:BAAAKgAFFAEIAQAAAA==.',['法力']='法力殘渣:BAABKgAFFH8GAAIJAAYIdBWtCgCMAQAJAAYIdBWtCgCMAQAAAA==.',['法蒂']='法蒂玛:BAAAKgAFFAIIAgAAAA==.',['派大']='派大吐沫沫:BAABKgAFFH8IAAMNAAQI2CHUBgARAQANAAQI2CHUBgARAQAMAAQIBhclQgBXAAAAAA==.',['浮生']='浮生醉清风:BAAAKgAECgYIBwAAAA==.',['淘气']='淘气的唐丫丫:BAAAKgAECggIDgAAAA==.淘气的小妍妍:BAAAKgAECgcIAwAAAA==.淘气的笨丫头:BAAAKgADCgUIBQAAAA==.淘气的翔大叔:BAAAKgAECggIDgAAAA==.淘气的老翔翔:BAAAKgAECggIDwAAAA==.淘气的老顽童:BAAAKgAECgcIBwAAAA==.',['灯塔']='灯塔:BAABKgAECn8jAAMIAAcIASUqDQBtAgAIAAcIASUqDQBtAgAKAAEITwliogAiAAAAAA==.',['炸梦']='炸梦这是我去:BAAAKgAECgMIAwAAAA==.',['版本']='版本之纸:BAAAKgADCggICAAAAA==.',['牛牛']='牛牛刀:BAAAKgADCgIIAgAAAA==.',['狂怒']='狂怒封印:BAAAKgAFFAgIBAAAAA==.',['猛仔']='猛仔:BAACKgAFFH8JAAIMAAMIthqGFQDiAAAMAAMIthqGFQDiAAAqAAQKfyIAAgwACAikHfNLAM8BAAwACAikHfNLAM8BAAAA.',['男爵']='男爵:BAAAKgADCgEIAQAAAA==.',['的嘚']='的嘚德:BAABKgAECn8XAAMTAAgIbQ34LwA2AQATAAgIbQ34LwA2AQALAAUIdBn2ZgAlAQAAAA==.',['瞌睡']='瞌睡狮子:BAAAKgADCgUIBQAAAA==.',['神奇']='神奇的滄寒:BAABKgAECn8xAAMEAAgI4RXpFgDIAQAEAAgI0RTpFgDIAQAFAAgIkwkeUgDIAAAAAA==.',['神棍']='神棍牛:BAAAKgADCgMIAwAAAA==.',['神欲']='神欲之殇:BAAAKgAFFAQIBAAAAA==.',['米奈']='米奈希儿:BAAAKgADCggICAAAAA==.',['累不']='累不死的牛:BAABKgAFFH8IAAMHAAQIdg7XCwDSAAAHAAQIdg7XCwDSAAAGAAEIAACiIgAAAAAAAA==.',['綨喏']='綨喏婍:BAABKgAFFH8GAAIBAAYIph7jEADYAQABAAYIph7jEADYAQAAAA==.',['红烧']='红烧咸鱼:BAAAKgADCggICAAAAA==.',['红花']='红花郞:BAAAKgADCggICwAAAA==.',['绿茶']='绿茶豆腐:BAAAKgAECgEIAQAAAA==.',['老璐']='老璐:BAABKgAFFH8FAAIGAAUIlSAjCQDBAQAGAAUIlSAjCQDBAQAAAA==.',['老赵']='老赵二:BAAAKgAFFAIIAgAAAA==.',['胖胖']='胖胖的阿尾:BAABKgAFFH8QAAIUAAgI2xmsAwByAgAUAAgI2xmsAwByAgAAAA==.',['色还']='色还是那个色:BAAAKgAFFAQIBAAAAA==.',['萌萌']='萌萌的筱紫瞳:BAACKgAFFH8MAAIFAAYIHR+1BABiAQAFAAYIHR+1BABiAQAqAAQKfxkAAwUACAjeIsELAI0CAAUACAjeIsELAI0CAAQAAQj4H0xuAFAAAAAA.',['蓝田']='蓝田玉暖:BAAAKgAECgUICgAAAA==.',['蕾蕾']='蕾蕾澳克塞:BAAAKgAECggIDAAAAA==.',['藤原']='藤原浩:BAAAKgAFFAgIBAAAAA==.',['血腥']='血腥玛麗:BAAAKgAECgQIBAAAAA==.',['谭二']='谭二胖:BAAAKgAECgUIBQAAAA==.',['費蒙']='費蒙特:BAAAKgAFFAQIBAAAAA==.',['踏风']='踏风的泽拉图:BAAAKgADCgIIAgAAAA==.',['近战']='近战第一:BAAAKgADCgMIAwAAAA==.',['这木']='这木大的力量:BAAAKgADCggICAAAAA==.',['追踪']='追踪狩猎者:BAAAKgAECgEIAQAAAA==.',['逆水']='逆水寒冰:BAAAKgAECgYIEgAAAA==.逆水寒箭:BAAAKgAECgUICAAAAA==.',['過眼']='過眼云烟:BAABKgAFFH8MAAMJAAgI6xrZEAAQAQAKAAQIgRjjEgBOAQAJAAQIIx7ZEAAQAQAAAA==.',['邪能']='邪能的泽拉图:BAAAKgADCggICwAAAA==.',['酒鬼']='酒鬼花生:BAAAKgAFFAgIBAAAAA==.',['铁骨']='铁骨傲苍穹:BAAAKgAECgYIBwAAAA==.',['长期']='长期素食:BAAAKgAECgEIAQAAAA==.',['阿卟']='阿卟:BAAAKgADCgEIAQAAAA==.',['雅琳']='雅琳柯德:BAAAKgAFFAMIAwAAAA==.',['集中']='集中火力:BAAAKgADCgUIBQAAAA==.',['雨丶']='雨丶:BAAAKgAFFAQIBAAAAA==.',['雨露']='雨露丶:BAAAKgAECggIEwAAAA==.',['青木']='青木直樹:BAABKgAECn8YAAIFAAgIbxYsMACxAQAFAAgIbxYsMACxAQAAAA==.',['默莫']='默莫:BAABKgAFFH8GAAIBAAYI0hqOHACBAQABAAYI0hqOHACBAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end