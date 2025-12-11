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
 local lookup = {'Druid-Balance','Rogue-Assassination','Shaman-Restoration','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','Priest-Shadow','Shaman-Elemental','Mage-Frost','Warrior-Protection','Warrior-Fury','Druid-Restoration','Warlock-Demonology','Paladin-Holy','DeathKnight-Frost','Priest-Holy','Warrior-Arms','Warlock-Destruction','Hunter-Marksmanship','DemonHunter-Havoc','Warlock-Affliction','DeathKnight-Blood','DeathKnight-Unholy','Monk-Brewmaster','Mage-Arcane','Evoker-Devastation',}; local provider = {region='CN',realm='祖尔金',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abco:BAAALAAECgYICwAAAA==.',Ad='Adam:BAABLAAFFH8IAAIBAAIIlxH5NAA7AAABAAIIlxH5NAA7AAAAAA==.',Ak='Akuma:BAABLAAECn8jAAICAAgIYhb6GQBFAgACAAgIYhb6GQBFAgAAAA==.',An='Anarchy:BAAALAAFFAEIAQAAAA==.',As='Astrid:BAABLAAFFH8GAAIDAAIIihGKSQByAAADAAIIihGKSQByAAAAAA==.',Em='Emilymjj:BAAALAAECgUIBgAAAA==.',Hi='Hiyohiyo:BAACLAAFFH8fAAIEAAYIWx1pHQC9AQAEAAYIWx1pHQC9AQAsAAQKfyEAAgQACAhLHksaAF4CAAQACAhLHksaAF4CAAAA.',Hu='Hugmoon:BAABLAAFFH8LAAIFAAMIeRvrKwCyAAAFAAMIeRvrKwCyAAABLAAFFAYIHwAEAFsdAA==.',Il='Ilovesysu:BAAALAAECgYIEAAAAA==.Ilovesysua:BAAALAAECgYIDwAAAA==.',Jo='Joyas:BAAALAAECgYIEQAAAA==.',Ly='Lyuting:BAAALAAFFAIIBAAAAA==.',Pl='Playerejeisy:BAAALAAECgYICgAAAA==.',Re='Reminiscence:BAABLAAFFH8SAAIGAAYIVw/OBwBGAQAGAAYIVw/OBwBGAQAAAA==.',Su='Sunwenbo:BAAALAAECgYIBgAAAA==.',We='Webersun:BAAALAADCgEIAQAAAA==.',Yd='Ydear:BAABLAAFFH8GAAIHAAIIxyGEGQCkAAAHAAIIxyGEGQCkAAAAAA==.',['一个']='一个白妹妹:BAACLAAFFH8uAAMIAAYINxvmEQCtAQAIAAYINxvmEQCtAQADAAMIkhasPQCFAAAsAAQKfzgAAwMACAg5Ia8SAF0CAAMABwh7IK8SAF0CAAgACAhXHW8OAEoCAAAA.',['一灯']='一灯和尚:BAAALAADCgEIAQAAAA==.',['一袋']='一袋米扛几楼:BAACLAAFFH8hAAIGAAYI/g6yAwCPAQAGAAYI/g6yAwCPAQAsAAQKfysAAgYACAgfIBYNAKoCAAYACAgfIBYNAKoCAAAA.',['不秋']='不秋草:BAAALAAECgYIBgAAAA==.',['丨齊']='丨齊天大聖丨:BAABLAAFFH8GAAIJAAIIVhurEgBNAAAJAAIIVhurEgBNAAAAAA==.',['临渊']='临渊:BAACLAAFFH8PAAMKAAUIfCMpCgCeAQAKAAUIfCMpCgCeAQALAAIIlxTAQgBSAAAsAAQKfzQAAwsACAjFGRw+ADwCAAsACAjFGRw+ADwCAAoABgjMAbp5AKEAAAAA.',['丶杯']='丶杯子丶:BAAALAAECgUIBQAAAA==.',['丶概']='丶概率牧:BAAALAAFFAIIBAABLAAFFAYIEgALADYVAA==.',['乌鸦']='乌鸦坐飞机:BAAALAADCgEIAQAAAA==.',['九二']='九二六:BAAALAAECgMIAwAAAA==.',['二段']='二段媒介:BAAALAAECgYIBgAAAA==.',['亚瑟']='亚瑟王:BAAALAAECgIIAwAAAA==.',['以德']='以德唬人:BAAALAAECgUIBQAAAA==.',['伊芙']='伊芙琳影歌:BAABLAAFFH8QAAIMAAIIUBwhJACWAAAMAAIIUBwhJACWAAAAAA==.',['体育']='体育生:BAAALAADCgEIAQAAAA==.',['兄弟']='兄弟快跑:BAAALAAECgQIBAAAAA==.',['光之']='光之恋念:BAAALAAECgEIAQAAAA==.',['北郡']='北郡故人:BAAALAAECgIIAgAAAA==.',['匡扶']='匡扶正义:BAAALAAECggIBAAAAA==.',['印度']='印度神牛:BAAALAAECgYIDAAAAA==.',['发牙']='发牙:BAAALAADCgUIBQAAAA==.',['古尔']='古尔舟:BAABLAAFFH8FAAINAAMI8AefCwBjAAANAAMI8AefCwBjAAAAAA==.',['吉安']='吉安那:BAAALAAECgQIBAAAAA==.',['哈尼']='哈尼小熊:BAABLAAFFH8JAAIDAAYI4yGrCAA6AgADAAYI4yGrCAA6AgAAAA==.哈尼皇骑:BAAALAAFFAQIAgAAAA==.',['啤酒']='啤酒王子:BAABLAAECn8cAAIFAAgIqRklIAAbAgAFAAgIqRklIAAbAgAAAA==.',['四两']='四两热干面:BAAALAAECggICgAAAA==.',['塔奇']='塔奇克马:BAABLAAFFH8GAAIFAAII1xeoPwCeAAAFAAII1xeoPwCeAAAAAA==.',['塔山']='塔山:BAABLAAECn8UAAIEAAYI6BXfhgA9AQAEAAYI6BXfhgA9AQAAAA==.',['墨染']='墨染蝶衣:BAAALAAECgIIAgAAAA==.',['声声']='声声乌龙:BAAALAAFFAIIAgABLAAFFAUIDQAEAOQcAA==.',['多多']='多多快跑:BAAALAAECgIIAgAAAA==.',['夜蔓']='夜蔓蔓:BAABLAAFFH8GAAIOAAYI9BqvCwDJAQAOAAYI9BqvCwDJAQAAAA==.',['大宗']='大宗师:BAAALAAFFAYIBAAAAA==.',['大领']='大领主:BAAALAAECgYIBgAAAA==.',['天使']='天使玫:BAAALAADCgYIBgAAAA==.',['奥丶']='奥丶叮丁:BAAALAAFFAgIAgAAAA==.奥丶盾丁:BAABLAAFFH8FAAIFAAQI5w8hJwBAAQAFAAQI5w8hJwBAAQAAAA==.',['妈妈']='妈妈说坏人多:BAAALAAECggICQAAAA==.',['孤魂']='孤魂野鬼:BAABLAAFFH8FAAIPAAUIPgSWTwDiAAAPAAUIPgSWTwDiAAAAAA==.',['小如']='小如风:BAAALAAECgEIAQAAAA==.',['小小']='小小七:BAABLAAFFH8FAAIBAAUI4A74GgD9AAABAAUI4A74GgD9AAAAAA==.',['小气']='小气包:BAAALAAECgUICQAAAA==.',['山河']='山河作砚:BAAALAAFFAIIAgAAAA==.',['左传']='左传:BAABLAAFFH87AAIEAAcIpyTOBQCNAgAEAAcIpyTOBQCNAgAAAA==.',['巧克']='巧克力麦丽素:BAABLAAFFH8GAAIFAAYIFhuSGQCKAQAFAAYIFhuSGQCKAQAAAA==.',['布加']='布加迪威熊:BAAALAAECgYIDAAAAA==.',['布蕾']='布蕾波波:BAAALAADCgMIAwAAAA==.',['希尔']='希尔哇纳斯:BAAALAADCgQIBAAAAA==.',['帝上']='帝上的萨满:BAAALAAFFAIIBAAAAA==.',['常伴']='常伴无声:BAAALAAECgYIBgAAAA==.',['弥紗']='弥紗:BAAALAAECgQIBgAAAA==.',['弯弯']='弯弯战神:BAAALAAECgUIBQAAAA==.',['忧郁']='忧郁大帝:BAABLAAECn8WAAIJAAYIYh3mJwDpAQAJAAYIYh3mJwDpAQAAAA==.',['我好']='我好咕嘟鸭:BAABLAAFFH8YAAIQAAQIExdkHgDIAAAQAAQIExdkHgDIAAABLAAFFAUIEwAMAP8eAA==.',['战斗']='战斗大师:BAAALAAECgMIAwAAAA==.',['战阿']='战阿战:BAAALAAECgYICQAAAA==.',['抬手']='抬手就是一刀:BAAALAAECgMIAgAAAA==.',['指环']='指环战:BAABLAAECn8ZAAMLAAgI8BbjJgDGAQALAAgIOxbjJgDGAQARAAMIcA1mLACRAAAAAA==.',['敢问']='敢问路在何方:BAAALAAECgYIBgAAAA==.',['星星']='星星知我意:BAAALAAECggICgAAAA==.',['晃动']='晃动的菊花:BAAALAAECgYICAAAAA==.',['暴力']='暴力小善:BAAALAAECgYIBgAAAA==.',['暴打']='暴打丶猕猴桃:BAAALAAECggIBgAAAA==.暴打丶葡萄:BAABLAAFFH8IAAISAAIIBg9tSQCLAAASAAIIBg9tSQCLAAAAAA==.',['杨枝']='杨枝甘露:BAAALAAFFAIIAgABLAAFFAUIDQAEAOQcAA==.',['杯丶']='杯丶子:BAAALAAECgYICgAAAA==.',['枯骨']='枯骨:BAAALAAECgIIAgAAAA==.',['桂馥']='桂馥兰香:BAABLAAFFH8NAAMEAAUI5ByUEgCSAQAEAAQImiGUEgCSAQATAAEIDAocMwBKAAAAAA==.',['桃喜']='桃喜芒芒:BAAALAAFFAIIAgABLAAFFAUIDQAEAOQcAA==.',['梦幻']='梦幻淑:BAAALAAECgMIAwAAAA==.',['殇之']='殇之涅槃:BAAALAAECggICAAAAA==.',['水蜜']='水蜜桃晶球:BAABLAAFFH8FAAIFAAIIrh8aJgC+AAAFAAIIrh8aJgC+AAABLAAFFAUIDQAEAOQcAA==.',['汉加']='汉加诺:BAABLAAFFH8MAAIFAAQITQb6UgBQAAAFAAQITQb6UgBQAAAAAA==.',['沙蟒']='沙蟒:BAABLAAFFH8NAAIEAAIIOyNzKwDSAAAEAAIIOyNzKwDSAAAAAA==.',['泷泽']='泷泽:BAAALAAECgYICgAAAA==.',['浅夏']='浅夏默默:BAAALAADCgIIAgAAAA==.',['浪漫']='浪漫的家伙:BAAALAAFFAEIAQAAAA==.',['涵涵']='涵涵:BAABLAAECn8UAAIUAAcIThh6LwCbAQAUAAcIThh6LwCbAQAAAA==.',['清风']='清风洗我的狂:BAAALAAECgQIBAAAAA==.',['烈火']='烈火锦:BAAALAAFFAIIBAAAAA==.',['热熔']='热熔:BAAALAADCgUIBQAAAA==.',['熊猫']='熊猫鸟树咕:BAAALAADCgYIBgAAAA==.',['牛肉']='牛肉:BAAALAADCgYICgAAAA==.',['狐人']='狐人总冠军:BAAALAADCgYIBgAAAA==.',['猪大']='猪大肠:BAAALAADCgUIBQAAAA==.',['珠泪']='珠泪哀歌族:BAAALAAECgMIAwAAAA==.',['瑟奥']='瑟奥雷吉斯:BAAALAAECgUIAgAAAA==.',['白狼']='白狼骚男:BAAALAAECgYIBgAAAA==.',['盘古']='盘古大帝:BAAALAAECgEIAQAAAA==.',['真红']='真红戟鬼:BAACLAAFFH8rAAMSAAYImyEhJgCBAQASAAUIeCEhJgCBAQAVAAEISSIABgBiAAAsAAQKfyMAAhIABwi8JGgZAPACABIABwi8JGgZAPACAAEsAAUUCAgKABIA0SMA.',['眼泛']='眼泛一抹绿:BAAALAAFFAMIAwAAAA==.',['禅中']='禅中说缠:BAABLAAFFH8KAAIFAAIIoxVGOgCiAAAFAAIIoxVGOgCiAAAAAA==.',['福一']='福一:BAABLAAFFH8NAAISAAYIsRlHHwCgAQASAAYIsRlHHwCgAQAAAA==.',['福七']='福七:BAABLAAFFH8HAAISAAYI1xFmKAB4AQASAAYI1xFmKAB4AQAAAA==.',['福三']='福三:BAABLAAFFH8WAAISAAYIeRngHgChAQASAAYIeRngHgChAQAAAA==.',['福九']='福九:BAAALAAFFAYIAgAAAA==.',['福二']='福二:BAABLAAFFH8OAAISAAYIrBmuIQCVAQASAAYIrBmuIQCVAQAAAA==.',['福五']='福五:BAABLAAFFH8MAAISAAYI2RzfFwDLAQASAAYI2RzfFwDLAQAAAA==.',['福八']='福八:BAABLAAFFH8GAAISAAYIERJgJwB8AQASAAYIERJgJwB8AQAAAA==.',['福六']='福六:BAABLAAFFH8MAAISAAYIjBZOIQCXAQASAAYIjBZOIQCXAQAAAA==.',['福十']='福十:BAABLAAFFH8QAAISAAYIohV8IgCRAQASAAYIohV8IgCRAQAAAA==.',['福四']='福四:BAABLAAFFH8SAAISAAYI2Bo3HACwAQASAAYI2Bo3HACwAQAAAA==.',['米拉']='米拉迪:BAAALAAECgYIBgAAAA==.',['紫雨']='紫雨伊人:BAAALAAFFAIIBAAAAA==.',['缠中']='缠中说禅:BAABLAAFFH8RAAMWAAgIgRrzAgBTAgAWAAgIgRrzAgBTAgAXAAIILBLuEQCRAAAAAA==.',['老狐']='老狐:BAABLAAFFH8MAAIYAAYI7hH2BgCSAQAYAAYI7hH2BgCSAQAAAA==.',['舞指']='舞指弑天:BAABLAAFFH8VAAIDAAYIBSQHAQCBAgADAAYIBSQHAQCBAgAAAA==.',['艾尔']='艾尔贝蕾斯:BAAALAAECgYICAAAAA==.',['芋泥']='芋泥波波:BAAALAAFFAIIBAABLAAFFAUIDQAEAOQcAA==.',['花月']='花月儿:BAACLAAFFH8MAAITAAMIpxThEgDPAAATAAMIpxThEgDPAAAsAAQKfxUAAhMACAjlHIQoADACABMACAjlHIQoADACAAAA.',['英语']='英语包月:BAAALAAFFAMIAwABLAAFFAYIHwAEAFsdAA==.',['草原']='草原秋风狂:BAABLAAECn8dAAIFAAcIbhSsmADDAQAFAAcIbhSsmADDAQAAAA==.',['草莓']='草莓熊:BAABLAAFFH8JAAIMAAMIFhSVLwCsAAAMAAMIFhSVLwCsAAAAAA==.',['莱昂']='莱昂纳多:BAAALAAECgYICAAAAA==.',['萨满']='萨满:BAABLAAFFH8GAAIDAAYI5yMsAQB7AgADAAYI5yMsAQB7AgAAAA==.',['葫芦']='葫芦头:BAAALAADCgYIBwAAAA==.',['血色']='血色狂刀:BAABLAAFFH8KAAILAAIILQ5yOgCTAAALAAIILQ5yOgCTAAAAAA==.',['西瓦']='西瓦的火雨:BAABLAAFFH8MAAISAAYIsSAqEgD8AQASAAYIsSAqEgD8AQAAAA==.西瓦的灾变:BAABLAAFFH8GAAISAAYINBCRMQBRAQASAAYINBCRMQBRAQAAAA==.西瓦的献祭:BAABLAAFFH8FAAISAAUIFBPGPAAQAQASAAUIFBPGPAAQAQAAAA==.西瓦的苦痛:BAABLAAFFH8HAAISAAUIGhm5OgAeAQASAAUIGhm5OgAeAQAAAA==.',['貔貅']='貔貅会射火:BAAALAAFFAIIBAABLAAFFAYIFAAEAFkNAA==.貔貅快射火:BAAALAAECgYICwABLAAFFAYIFAAEAFkNAA==.',['迷惘']='迷惘:BAAALAADCggICAAAAA==.',['遥远']='遥远的刹那:BAAALAAFFAQIBAAAAA==.',['阿波']='阿波罗之翼:BAAALAAECgEIAQAAAA==.',['霜灵']='霜灵:BAAALAAECgEIAQAAAA==.',['露熙']='露熙:BAAALAADCgYIBgAAAA==.',['青岛']='青岛啤酒:BAAALAADCgQIBAAAAA==.',['青葵']='青葵:BAAALAAECgYIDQAAAA==.',['饭桶']='饭桶大师:BAAALAADCgMIAwAAAA==.',['馋猫']='馋猫与鱼:BAABLAAECn8VAAMJAAcImxVIEwCYAQAJAAcImxVIEwCYAQAZAAEIbgRpegAfAAAAAA==.',['黑暗']='黑暗双子座:BAAALAAECgYIBgAAAA==.',['龙世']='龙世武:BAABLAAFFH8GAAIaAAYIEx1HBAATAgAaAAYIEx1HBAATAgAAAA==.',['龙在']='龙在江湖:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end