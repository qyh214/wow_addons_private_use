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
 local lookup = {'Paladin-Retribution','Mage-Frost','Priest-Holy','Priest-Shadow','DeathKnight-Blood','Mage-Arcane','Mage-Fire','DeathKnight-Unholy','Shaman-Restoration','Warrior-Fury','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','DemonHunter-Havoc','Hunter-Ranged','DeathKnight-Frost','Monk-Mistweaver','Rogue-Outlaw','Warrior-Protection','Druid-Balance','DemonHunter-Vengeance','Evoker-Preservation','Warlock-Demonology',}; local provider = {region='CN',realm='达基萨斯',name='CN',type='weekly',zone=42,date='2025-08-02',data={Am='Amykill:BAAAKgAFFAQIAwAAAA==.',Ch='Christie:BAAAKgAFFAEIAgAAAA==.',De='Dearseohyun:BAAAKgADCggICAAAAA==.Dekker:BAAAKgAECgIIAgAAAA==.',Ev='Evaivy:BAABKgAECn8aAAIBAAgIghwRdwCpAQABAAgIghwRdwCpAQAAAA==.',Iv='Ivanq:BAAAKgAFFAQIBAAAAA==.',Le='Leeno:BAAAKgAECgQIBAAAAA==.',Lp='Lpanyy:BAAAKgAFFAQIBAAAAA==.',Pe='Petervick:BAAAKgAECgEIAQAAAA==.',Pr='Prometheus:BAABKgAECn8UAAICAAgIShQyLADHAQACAAgIShQyLADHAQAAAA==.',Pu='Pupa:BAAAKgADCggICAAAAA==.',Sa='Saberl:BAACKgAFFH8MAAIDAAMIExGBFgCOAAADAAMIExGBFgCOAAAqAAQKfyMAAwMACAgNGIYkAKYBAAMACAgNGIYkAKYBAAQABwinCWE4ACcBAAAA.Saning:BAAAKgADCggICAAAAA==.',Sc='Scraletammo:BAACKgAFFH8LAAIBAAMIEhMTNgCdAAABAAMIEhMTNgCdAAAqAAQKfxsAAgEACAgSHWNEACICAAEACAgSHWNEACICAAAA.',Sh='Shadow:BAAAKgAFFAUIAQAAAA==.',Th='Thegreateg:BAABKgAFFH8FAAIFAAUIKRpbAwBdAQAFAAUIKRpbAwBdAQAAAA==.',Tu='Turn:BAAAKgAECggIBAAAAA==.',Zo='Zoltraak:BAACKgAFFH9bAAMGAAgIJyOEBQBEAgAGAAcITSGEBQBEAgAHAAYIfCEPCgBWAQAqAAQKfzAAAwcACAjFJbIEAO8CAAcACAjFJbIEAO8CAAIAAwh7G0N9AJcAAAAA.',['一切']='一切看心情:BAAAKgAECgEIAQAAAA==.',['一起']='一起嬉戏玩耍:BAAAKgAECgEIAQAAAA==.',['七宗']='七宗罪丶欲:BAAAKgAECgYIDgAAAA==.',['不准']='不准禁言表情:BAABKgAFFH8GAAIEAAMI/w4uEACyAAAEAAMI/w4uEACyAAAAAA==.',['不帅']='不帅用砖头拍:BAAAKgAECgEIAQAAAA==.',['久久']='久久回味:BAAAKgAFFAEIAQAAAA==.',['乔汉']='乔汉娜的辩护:BAABKgAFFH8GAAIBAAYIsCIAFQC0AQABAAYIsCIAFQC0AQAAAA==.',['书瑶']='书瑶要开心:BAAAKgADCgUIBQAAAA==.',['乱屍']='乱屍佳人:BAAAKgADCgEIAQAAAA==.',['你不']='你不能这么做:BAAAKgAECgIIAgAAAA==.',['修心']='修心:BAAAKgAECggICAAAAA==.',['六羽']='六羽莉:BAAAKgADCgEIAQAAAA==.',['冰农']='冰农吐息:BAACKgAFFH8eAAIFAAYIjhlcCQCAAQAFAAYIjhlcCQCAAQAqAAQKfxkAAgUACAi4H9IRAB8CAAUACAi4H9IRAB8CAAAA.',['冻果']='冻果冻:BAAAKgADCgMIAwAAAA==.',['出门']='出门不带刀:BAAAKgAECgcICQAAAA==.',['列拉']='列拉戈刃:BAAAKgAFFAQIBAAAAA==.',['单调']='单调的夜道:BAAAKgAECggICAAAAA==.',['卡扎']='卡扎斐:BAAAKgAFFAQIBAAAAA==.',['卡特']='卡特琳娜丶:BAAAKgAFFAIIBAAAAA==.',['卿本']='卿本佳人:BAABKgAFFH8IAAIFAAQI4wfWKABzAAAFAAQI4wfWKABzAAABKgAFFAgIDgAIAEoXAA==.',['古之']='古之恶来:BAAAKgAFFAIIBAAAAA==.',['可乐']='可乐大叔:BAAAKgAECggIEAAAAA==.',['咆哮']='咆哮:BAAAKgAFFAQIBAAAAA==.',['哈斯']='哈斯拉伯:BAABKgAFFH8JAAIJAAYIrhelDQB0AQAJAAYIrhelDQB0AQAAAA==.',['喵神']='喵神:BAAAKgAECggIDgAAAA==.',['圣剑']='圣剑修罗:BAAAKgAECgQIBAAAAA==.',['地狱']='地狱男爵:BAAAKgAECgQIBAAAAA==.',['地瓜']='地瓜烤红薯:BAABKgAFFH8GAAIKAAYIeg/QDgBnAQAKAAYIeg/QDgBnAQAAAA==.',['埃辛']='埃辛诺之谜:BAAAKgAFFAQIBAAAAA==.',['壊壊']='壊壊亦墲畏:BAAAKgADCggIDQAAAA==.',['壮哉']='壮哉西恩刀塔:BAAAKgAFFAQIBAAAAA==.',['壹剣']='壹剣飙血:BAAAKgADCgEIAQAAAA==.',['夕夕']='夕夕朝朝:BAAAKgAFFAQIBAAAAA==.',['多多']='多多休息:BAAAKgAFFAEIAQAAAA==.',['大扑']='大扑棱蛾子:BAAAKgAECgIIAgAAAA==.',['天上']='天上一头牛:BAABKgAECn8oAAIJAAgIpBJ1SgBQAQAJAAgIpBJ1SgBQAQAAAA==.',['天下']='天下无双:BAAAKgAECgcIDAAAAA==.',['奔放']='奔放:BAAAKgAECgYIBgAAAA==.',['奥秘']='奥秘:BAAAKgAFFAQIBAAAAA==.',['奶你']='奶你一口:BAAAKgADCgYIBgAAAA==.',['妮可']='妮可罗宾:BAAAKgAFFAMIAwAAAA==.',['娅特']='娅特拉绯雪:BAABKgAFFH8GAAMDAAMIlROTKACgAAADAAMIlROTKACgAAALAAIISgJiLAAzAAAAAA==.',['宇智']='宇智波牢大:BAAAKgAECgMIAwAAAA==.',['安妮']='安妮海瑟薇:BAAAKgADCgEIAgAAAA==.',['小娘']='小娘逼:BAAAKgAECggICAAAAA==.',['小布']='小布丁儿:BAAAKgAFFAMIAwAAAA==.',['小烟']='小烟飘阿飘:BAAAKgAECgEIAQAAAA==.',['小萨']='小萨:BAAAKgAECggICgAAAA==.小萨酋长:BAAAKgAECgcIBwAAAA==.',['小魚']='小魚冻干:BAAAKgADCggICAAAAA==.',['尘埃']='尘埃落定:BAAAKgAECgEIAgAAAA==.',['尼禄']='尼禄:BAAAKgAFFAYIBAAAAA==.',['左手']='左手拔刀:BAABKgAECn8iAAMMAAgItBuRPwD6AQAMAAgIoBqRPwD6AQANAAMIVBnrUADZAAAAAA==.',['巴拉']='巴拉啦小魔仙:BAAAKgAECgUIBQAAAA==.',['异想']='异想:BAAAKgADCgMIAwAAAA==.',['很酷']='很酷又爱笑:BAABKgAFFH8JAAIBAAQIHB1KMwCkAAABAAQIHB1KMwCkAAAAAA==.',['御弟']='御弟哥哥:BAAAKgAECgEIAQAAAA==.',['心生']='心生六乂:BAABKgAFFH8TAAMBAAMI4g7AKADDAAABAAMI4g7AKADDAAAOAAMIpQM0JQBhAAAAAA==.',['思尔']='思尔:BAAAKgADCgQIBQAAAA==.',['性感']='性感的大橙子:BAAAKgAECggICAAAAA==.',['怼怼']='怼怼:BAAAKgAFFAgIAwAAAA==.怼怼丶:BAAAKgAECgcIDQAAAA==.',['愉悦']='愉悦的纸鹤:BAAAKgAECggICAAAAA==.',['懵猛']='懵猛:BAAAKgAECgYICwAAAA==.',['成就']='成就你的梦想:BAABKgAFFH8OAAIPAAMIGhL3LADHAAAPAAMIGhL3LADHAAAAAA==.',['我世']='我世界你不懂:BAABKgAFFH8GAAIPAAMIGAJcJQBfAAAPAAMIGAJcJQBfAAAAAA==.',['我怕']='我怕牛奶:BAAAKgADCgYIBgAAAA==.',['扛不']='扛不住鹫装死:BAAAKgADCgYIBgAAAA==.',['拉风']='拉风归来骑士:BAAAKgAFFAEIAwAAAA==.拉风骑士归来:BAAAKgAECgMIAwAAAA==.',['拿破']='拿破剑:BAACKgAFFH8WAAIKAAMI0R08FQATAQAKAAMI0R08FQATAQAqAAQKfxwAAgoACAglIccdACYCAAoACAglIccdACYCAAAA.',['无聊']='无聊骨头:BAAAKgADCgIIAgAAAA==.',['星期']='星期八:BAABKgAFFH8IAAIQAAgIXw8AAAAAAAAMAAgIXw8AAAAAAAAAAA==.',['星空']='星空暗闪耀:BAAAKgAECggICAAAAA==.',['春風']='春風蕩漾:BAAAKgAECgEIAQAAAA==.',['是尴']='是尴尬的:BAAAKgAECgEIAQAAAA==.',['是怼']='是怼怼呀丶:BAAAKgADCggICAAAAA==.',['朝如']='朝如青丝:BAAAKgAFFAQIBAAAAA==.',['朮士']='朮士:BAAAKgAECgYIBgAAAA==.',['术神']='术神喵:BAAAKgAECggICgAAAA==.',['格兰']='格兰芬多:BAAAKgAECgQIBAAAAA==.',['梦清']='梦清幽:BAAAKgAECggICgAAAA==.',['檬梦']='檬梦檬么:BAAAKgADCgIIAgAAAA==.',['污瑟']='污瑟尔:BAAAKgAFFAIIAgAAAA==.',['沧海']='沧海与白鸟:BAABKgAFFH8YAAMCAAYICBuABQCCAQACAAYICBuABQCCAQAGAAYIoAleGAAhAQAAAA==.',['法海']='法海十月怀胎:BAABKgAECn8ZAAMRAAYIYxCIHQD8AAARAAYIYxCIHQD8AAAIAAIIKAfBrgA6AAAAAA==.',['浩克']='浩克:BAAAKgAECgUIBgAAAA==.',['海盐']='海盐小虾米:BAAAKgADCgEIAQAAAA==.',['淡泊']='淡泊明志:BAAAKgAECgQIBgAAAA==.',['淺丶']='淺丶淺:BAAAKgADCgEIAQAAAA==.',['火锅']='火锅小肥羊:BAAAKgAECgUIBQAAAA==.火锅搭奶茶丶:BAAAKgAECgYIDQAAAA==.',['灬少']='灬少林毒奶灬:BAAAKgADCgMIAwAAAA==.',['灬純']='灬純爺們灬:BAAAKgAECgIIBAAAAA==.',['炼心']='炼心行者:BAABKgAFFH8OAAIMAAYIuRkmEAB5AQAMAAYIuRkmEAB5AQAAAA==.',['牛吉']='牛吉把:BAABKgAECn8xAAISAAgIYxmPGADHAQASAAgIYxmPGADHAQAAAA==.',['牵着']='牵着你左手:BAAAKgAECgYIBgAAAA==.',['特邀']='特邀嘉宾:BAAAKgADCgcICAAAAA==.',['独径']='独径行云:BAAAKgAECgEIAQAAAA==.',['独经']='独经新云:BAABKgAECn8eAAIBAAcIzxJOLgBZAQABAAcIzxJOLgBZAQAAAA==.',['狼铛']='狼铛:BAABKgAFFH8WAAITAAMIUSAvAwAIAQATAAMIUSAvAwAIAQAAAA==.',['琴月']='琴月阴:BAABKgAFFH8MAAMKAAMILwX4LQCHAAAKAAMIQwL4LQCHAAAUAAIIBQdTFQBOAAAAAA==.',['疯狂']='疯狂木头:BAAAKgAECgIIAgAAAA==.疯狂木牛:BAABKgAFFH8JAAIBAAMIJAWtRQB3AAABAAMIJAWtRQB3AAAAAA==.疯狂牛奶:BAAAKgAECgYIDAAAAA==.',['白衣']='白衣流云:BAAAKgAECggIEAAAAA==.',['百变']='百变星君:BAAAKgAECgUIBgAAAA==.',['石头']='石头贼:BAAAKgAECgUIBQAAAA==.',['破晓']='破晓:BAAAKgAECgIIAgAAAA==.',['神仙']='神仙也枉然:BAAAKgADCggICAAAAA==.',['稳德']='稳德一匹:BAAAKgAECgYIBgAAAA==.',['精神']='精神点别丢份:BAABKgAFFH8LAAIMAAQIwB5LIQAGAQAMAAQIwB5LIQAGAQAAAA==.',['糸色']='糸色命:BAAAKgAECgMIAwAAAA==.',['素炒']='素炒胡萝卜:BAAAKgAECggICAAAAA==.',['约美']='约美女:BAAAKgAECgEIAQAAAA==.',['纪幕']='纪幕:BAAAKgADCggIDQAAAA==.',['老徳']='老徳:BAABKgAECn8VAAIVAAgIuiCQIgAzAgAVAAgIuiCQIgAzAgAAAA==.',['聖一']='聖一日:BAAAKgADCgYIBgAAAA==.',['肆壹']='肆壹:BAAAKgAECgIIAgAAAA==.',['腐朽']='腐朽者:BAAAKgAFFAQIAwAAAA==.',['自由']='自由心乁杰:BAAAKgAFFAIIAgAAAA==.',['艾拉']='艾拉瑞丽:BAABKgAFFH8NAAIWAAMIjRR0EADAAAAWAAMIjRR0EADAAAAAAA==.',['花弄']='花弄影:BAAAKgAECggIEAAAAA==.',['花火']='花火灬灬:BAAAKgAECggICQAAAA==.',['苍龙']='苍龙灬揽皓月:BAAAKgAECgIIAgABKgAFFAgIEAAXADsdAA==.',['英雄']='英雄:BAABKgAFFH8KAAMPAAYIfAtqFwA/AQAPAAYIfAtqFwA/AQAWAAQIdQEhIgBTAAAAAA==.英雄不朽:BAAAKgAFFAQIBAAAAA==.',['荭人']='荭人莫笑笑:BAAAKgAECgQIBAAAAA==.',['落叶']='落叶是欧皇:BAAAKgAECggICwAAAA==.',['薄晓']='薄晓:BAAAKgAFFAIIBAAAAA==.',['詹姆']='詹姆斯邦邦:BAAAKgAFFAQIBAAAAA==.',['读经']='读经新云:BAABKgAECn8VAAIYAAcISgz7EgASAQAYAAcISgz7EgASAQAAAA==.',['贾柱']='贾柱睾:BAABKgAECn8eAAIJAAgIchxFIgAKAgAJAAgIchxFIgAKAgAAAA==.',['赶紧']='赶紧让我报警:BAAAKgADCgIIAgAAAA==.',['跳跳']='跳跳舞迷迷人:BAABKgAFFH8SAAMNAAgIOh3WAADNAQANAAgIdhfWAADNAQAMAAMI/x3JIwD5AAAAAA==.',['轉身']='轉身華麗傾城:BAAAKgADCgEIAQAAAA==.',['边笑']='边笑边掉泪:BAAAKgADCggICAAAAA==.',['逐魔']='逐魔者:BAAAKgAFFAIIAgAAAA==.',['重案']='重案组之虎:BAAAKgAFFAMIAwAAAA==.',['野猪']='野猪亨利:BAAAKgAECgIIAgAAAA==.',['钉宫']='钉宫病的夏娜:BAAAKgADCgEIAQAAAA==.',['阳光']='阳光一兜兜:BAABKgAECn8dAAIHAAgIRBuZJQAUAgAHAAgIRBuZJQAUAgAAAA==.',['阿古']='阿古斯星魂:BAAAKgADCggICAAAAA==.',['零小']='零小零:BAAAKgAFFAQIBAAAAA==.',['霖霖']='霖霖原上草:BAAAKgAECgcIBwAAAA==.',['露露']='露露的夜:BAAAKgADCggICgAAAA==.',['青瓷']='青瓷:BAABKgAFFH8IAAIDAAMIDAWcMACDAAADAAMIDAWcMACDAAAAAA==.',['青絲']='青絲如雪:BAABKgAFFH8IAAINAAgILw4VCADdAQANAAgILw4VCADdAQAAAA==.',['静悄']='静悄悄的闷棍:BAAAKgADCgEIAQAAAA==.',['頭发']='頭发乱了:BAAAKgAFFAQIBAAAAA==.',['风行']='风行者迷弟:BAAAKgAECgcICgAAAA==.',['骨尔']='骨尔丹:BAAAKgAFFAQIBAAAAA==.',['鱼大']='鱼大妈:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end