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
 local lookup = {'Paladin-Retribution','Warrior-Arms','Warrior-Fury','Paladin-Protection','Hunter-Marksmanship','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Priest-Holy','Hunter-BeastMastery','Evoker-Devastation','Paladin-Holy','Warlock-Destruction','Shaman-Elemental','Priest-Discipline','Priest-Shadow','Mage-Frost','DemonHunter-Havoc','Shaman-Enhancement','Mage-Arcane','Mage-Fire','Shaman-Restoration','Unknown-Unknown','Druid-Feral','Druid-Balance','Druid-Restoration','Evoker-Preservation','Warlock-Affliction','DemonHunter-Vengeance','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Warlock-Demonology','Rogue-Assassination',}; local provider = {region='CN',realm='雷霆号角',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ci='Cirilla:BAAAKgAECgMIAwAAAA==.',He='Hellcons:BAAAKgAECgEIAQAAAA==.',Id='Idea:BAABKgAFFH8HAAIBAAcISRp4DQD6AQABAAcISRp4DQD6AQAAAA==.',Mi='Minitank:BAABKgAFFH8KAAMCAAYIHhogBwCiAQACAAYIHhogBwCiAQADAAQISAWTFwDIAAAAAA==.',Mo='Mobscene:BAAAKgADCggICAAAAA==.Mozei:BAAAKgAECgcIDQAAAA==.',Oc='Octc:BAABKgAFFH8YAAMBAAYIJyNBEgDKAQABAAYIJyNBEgDKAQAEAAYIewLtHACTAAAAAA==.',Ri='Rina:BAAAKgAECgQIBQAAAA==.Rita:BAAAKgADCgIIAgAAAA==.',So='Sophie:BAAAKgADCgIIBQAAAA==.',St='Sten:BAAAKgAECgIIAgAAAA==.',Tr='Trojan:BAAAKgADCgQIBwAAAA==.',Wa='Wallet:BAAAKgADCgMIAwAAAA==.',Wi='Widowmaker:BAABKgAFFH8GAAIFAAYIvBCZEQBXAQAFAAYIvBCZEQBXAQAAAA==.',['三五']='三五打老虎:BAAAKgADCgMIAwAAAA==.',['上帝']='上帝曰了:BAAAKgAECgIIAgAAAA==.',['不想']='不想滚来滚去:BAAAKgAECgUIBQAAAA==.',['东方']='东方无涯:BAAAKgAECggICAAAAA==.',['乂術']='乂術繹乂:BAAAKgAECgcIBwAAAA==.',['义父']='义父:BAAAKgAECgIIAgAAAA==.',['云印']='云印千山:BAAAKgAECgcIBwAAAA==.',['云小']='云小星:BAABKgAFFH8IAAMEAAcIaA+eCgDiAAAEAAUI1g6eCgDiAAABAAIIPxLNhQBOAAAAAA==.',['仰泳']='仰泳:BAABKgAFFH8IAAQGAAcIOASfCwCuAAAGAAQImASfCwCuAAAHAAIIdwOkFAAoAAAIAAEIAAAEJAAAAAAAAA==.',['伊利']='伊利玬丶怒风:BAAAKgAECgEIAQAAAA==.',['伽勒']='伽勒比海带:BAABKgAFFH8IAAIFAAcIQw+EEQDjAAAFAAcIQw+EEQDjAAABKgAFFAgIBgAJAKsLAA==.',['佩佩']='佩佩罗娜:BAAAKgADCggICAAAAA==.',['假大']='假大空:BAAAKgAECgUIDwAAAA==.',['假日']='假日威龙陈:BAAAKgADCgcIBwAAAA==.',['克利']='克利奥佩特拉:BAAAKgAECgEIAwAAAA==.',['八码']='八码之外:BAABKgAFFH8PAAIKAAYI8CERCAD4AQAKAAYI8CERCAD4AQABKgAFFAgICAAKAHkgAA==.',['凉薯']='凉薯守护者:BAAAKgADCgcIBwAAAA==.',['刘太']='刘太医:BAACKgAFFH8gAAILAAQIRR0rGQD6AAALAAQIRR0rGQD6AAAqAAQKfyIAAgsACAg7G7QUABoCAAsACAg7G7QUABoCAAAA.',['别十']='别十一:BAAAKgAECggICgAAAA==.',['别看']='别看我牛逼:BAAAKgAECgYIBgAAAA==.',['协奏']='协奏曲:BAAAKgAFFAQIBAAAAA==.',['卓不']='卓不凡:BAAAKgAECggICAAAAA==.',['南方']='南方日鹤:BAAAKgAECggIDAAAAA==.',['博丽']='博丽霊梦:BAABKgAFFH8MAAIDAAQIgSGJFwD+AAADAAQIgSGJFwD+AAAAAA==.',['卡佳']='卡佳利丝:BAAAKgAECgUIBgAAAA==.',['卡多']='卡多尔:BAAAKgAECggIEQAAAA==.',['卿丨']='卿丨狂:BAAAKgAECgEIAQAAAA==.',['厚德']='厚德载大物:BAAAKgAECgcIBwAAAA==.',['古允']='古允:BAAAKgAECggICAAAAA==.',['吹波']='吹波糖:BAAAKgAECgYIEwAAAA==.',['呈诺']='呈诺:BAAAKgAECgMIBwAAAA==.',['周纸']='周纸弱:BAABKgAFFH8IAAMBAAQILSDFDAAhAQABAAQILSDFDAAhAQAMAAEIAADXFwAAAAAAAA==.',['命定']='命定之死:BAAAKgADCggIBwAAAA==.',['哎利']='哎利达嘶:BAAAKgADCgUIBQAAAA==.',['哭泣']='哭泣的火柴:BAAAKgAFFAgIBAAAAA==.',['啊库']='啊库娜玛塔塔:BAABKgAFFH8GAAIBAAMIhRvoQQDsAAABAAMIhRvoQQDsAAAAAA==.',['啤酒']='啤酒:BAAAKgAFFAIIAgAAAA==.',['啾咪']='啾咪:BAABKgAFFH8IAAINAAgITQ2QBwDsAQANAAgITQ2QBwDsAQAAAA==.',['喜牛']='喜牛牛:BAAAKgAECggICAAAAA==.',['嗯哼']='嗯哼哼:BAAAKgADCgEIAQAAAA==.嗯哼嘣嚓嚓:BAAAKgADCgEIAQAAAA==.',['嗳卟']='嗳卟咧:BAAAKgAECgMIAwAAAA==.',['嗳木']='嗳木涕:BAAAKgAECgUIAwAAAA==.',['圝圝']='圝圝圓圓圞圞:BAAAKgADCgcIBwAAAA==.',['圣光']='圣光的夏天:BAAAKgAECgcICQAAAA==.',['堕落']='堕落骑士:BAABKgAFFH8IAAIIAAMIagstFwCsAAAIAAMIagstFwCsAAAAAA==.',['墨渊']='墨渊:BAAAKgAECgUIBQAAAA==.',['复仇']='复仇之歌:BAAAKgADCgcIBwAAAA==.',['夏日']='夏日心情:BAAAKgADCggIEAAAAA==.',['夜听']='夜听春雨:BAAAKgAECgMIAwAAAA==.',['夜深']='夜深人静:BAAAKgAFFAEIAQAAAA==.',['大侠']='大侠:BAAAKgADCggICAAAAA==.',['大惡']='大惡魔丶:BAAAKgAFFAgIAQAAAA==.',['大美']='大美丽丶:BAAAKgAFFAQIBAAAAA==.',['大调']='大调音阶:BAABKgAECn8WAAIOAAgI6gbUQwAVAQAOAAgI6gbUQwAVAQAAAA==.',['大雾']='大雾迷茫:BAAAKgADCggICAAAAA==.',['大鸣']='大鸣大放:BAAAKgAECgYIEQAAAA==.',['天无']='天无语:BAAAKgADCggICAAAAA==.',['天极']='天极蓝:BAABKgAFFH8SAAQPAAYIzSHRBQDZAQAPAAYIbB/RBQDZAQAJAAUI4iAkCgB/AQAQAAEIegULLgA9AAABKgAFFAgICAAJALsjAA==.',['天青']='天青色等烟雨:BAAAKgAFFAIIAgAAAA==.',['夹的']='夹的蛋:BAABKgAFFH8FAAIBAAMIFhSnKQC/AAABAAMIFhSnKQC/AAAAAA==.',['奇迹']='奇迹行者:BAAAKgADCgYIBgAAAA==.',['好人']='好人缘:BAABKgAFFH8TAAMHAAYIWhH5DADYAAAGAAUIagWbBwDwAAAHAAYIWhH5DADYAAAAAA==.',['好涩']='好涩的牛牛:BAACKgAFFH8KAAMDAAYIwhlyDQAFAQADAAQI8yFyDQAFAQACAAIIdw0qDAC4AAAqAAQKfxkAAgMACAjEHJcaAP0BAAMACAjEHJcaAP0BAAAA.',['如果']='如果云知道:BAAAKgAECggICwAAAA==.',['如梦']='如梦如影:BAAAKgAECgYIDgAAAA==.',['妖精']='妖精小七:BAAAKgAECgEIAQAAAA==.',['嫚仔']='嫚仔:BAABKgAFFH8MAAIRAAYIQRiMBgBkAQARAAYIQRiMBgBkAQAAAA==.',['宁静']='宁静的夏天:BAAAKgAECgQIBAAAAA==.',['安卡']='安卡希雅:BAABKgAFFH8IAAIBAAgIxRh3DQD6AQABAAgIxRh3DQD6AQAAAA==.',['对影']='对影成三人:BAABKgAFFH8MAAISAAcIdxdvDwBFAQASAAcIdxdvDwBFAQAAAA==.',['射死']='射死矮子:BAAAKgAECgcIBwAAAA==.',['小兔']='小兔米纱:BAAAKgAECgQIBAAAAA==.',['小嘴']='小嘴乱撮:BAAAKgAECgYIBgAAAA==.',['小娘']='小娘子别跑啊:BAABKgAFFH8IAAIFAAgIiRLuBgD2AQAFAAgIiRLuBgD2AQAAAA==.',['小小']='小小兜:BAAAKgAECggICAAAAA==.小小叹气:BAAAKgADCggICAAAAA==.',['小槑']='小槑勥:BAAAKgADCgcIBwAAAA==.',['小游']='小游漓:BAABKgAFFH8ZAAMJAAgIMBXHBQDYAQAJAAgIMBXHBQDYAQAQAAYIgxuaCgBWAQAAAA==.',['小竹']='小竹妈:BAABKgAFFH8GAAITAAYIqx7BBQCoAQATAAYIqx7BBQCoAQAAAA==.小竹妹:BAABKgAFFH8OAAIDAAYISiR4CADSAQADAAYISiR4CADSAQABKgAFFAgICAARALIdAA==.小竹姐:BAABKgAFFH8QAAMUAAYIuhrwAQDpAAAVAAYIYRgODAB1AQAUAAQIBhjwAQDpAAABKgAFFAgIGAAUAOchAA==.小竹姨妈:BAAAKgAFFAgIBAAAAA==.小竹小姨妈:BAABKgAFFH8GAAIHAAYIEwGFIgCTAAAHAAYIEwGFIgCTAAAAAA==.',['小筱']='小筱筱:BAABKgAFFH8GAAIDAAYIcwWSDAA4AQADAAYIcwWSDAA4AQAAAA==.',['小红']='小红手菈妮:BAACKgAFFH8JAAIFAAYIshLsGACcAAAFAAYIshLsGACcAAAqAAQKfxQAAwUACAiUGvwoAJsBAAUACAiUGvwoAJsBAAoAAgjpCmviAGsAAAAA.',['小船']='小船不用桨:BAAAKgAECgYIBgAAAA==.',['小草']='小草莓:BAAAKgADCgUIBQAAAA==.',['小贝']='小贝:BAAAKgAECgUIDgAAAA==.',['尼米']='尼米兹:BAAAKgAECgUIBwAAAA==.',['巫祝']='巫祝:BAAAKgAECgYIDQAAAA==.',['巴克']='巴克队长:BAAAKgAFFAQIBAAAAA==.',['希纳']='希纳瓦尔斯:BAAAKgAECgUICQAAAA==.',['带头']='带头大哥:BAAAKgADCgEIAQAAAA==.',['幸福']='幸福像花一样:BAABKgAFFH8FAAIWAAUIbRnSDwABAQAWAAUIbRnSDwABAQAAAA==.',['幽冥']='幽冥纱幔:BAAAKgAECgcICQAAAA==.',['归易']='归易:BAAAKgAECgEIAQAAAA==.',['彩色']='彩色的肉弹:BAAAKgAECggIEAABKgAFFAgIBAAXAAAAAA==.',['德发']='德发鲁伊:BAABKgAFFH8HAAQYAAYIsg9jBADnAAAYAAQIDg5jBADnAAAZAAEIsRWELgBHAAAaAAIIhgR5GQAtAAAAAA==.',['德德']='德德灰:BAAAKgAECgMIAwAAAA==.',['心凌']='心凌甄宝:BAAAKgAECggIDAAAAA==.',['忍者']='忍者神龟:BAABKgAFFH8IAAIDAAMIjg5EEgDbAAADAAMIjg5EEgDbAAAAAA==.',['悄悄']='悄悄咪咪:BAAAKgAECgEIAQAAAA==.',['愤青']='愤青:BAABKgAFFH8GAAIRAAIIphwfFwB+AAARAAIIphwfFwB+AAAAAA==.',['慕蚀']='慕蚀:BAAAKgAFFAMIAwAAAA==.',['我叫']='我叫死骑:BAAAKgADCggICAAAAA==.',['折花']='折花之人:BAAAKgAFFAMIAwAAAA==.',['持枪']='持枪打猎:BAABKgAFFH8JAAIFAAMIIAs5GQCdAAAFAAMIIAs5GQCdAAAAAA==.持枪抢钱:BAABKgAFFH8NAAQWAAgIvBXGBAAOAgAWAAgIvBXGBAAOAgATAAIICgbTDQBzAAAOAAII9wtaEwByAAAAAA==.',['摩尔']='摩尔斯特:BAAAKgADCggICAAAAA==.',['无名']='无名圣骑:BAAAKgAECgEIAQAAAA==.无名晓猎:BAAAKgAFFAIIAgAAAA==.',['无声']='无声铃鹿:BAAAKgAECgUIBQAAAA==.',['早安']='早安:BAAAKgAECgMIAwAAAA==.',['时间']='时间小青:BAAAKgADCggICAAAAA==.',['暗夜']='暗夜新野:BAAAKgADCgIIAgAAAA==.',['暗黑']='暗黑的夏天:BAAAKgADCgQIBAAAAA==.',['暧哟']='暧哟喂:BAAAKgAECggIEAAAAA==.',['月丶']='月丶夜:BAAAKgADCggICQAAAA==.',['月倾']='月倾浅丶:BAABKgAFFH8XAAMLAAgI9hjzDgBxAQALAAgI9hjzDgBxAQAbAAQIwg/6AwDXAAAAAA==.',['月夜']='月夜开个门:BAABKgAFFH8FAAINAAUIiRMAEAAzAQANAAUIiRMAEAAzAQABKgAFFAgIBgAcAGobAA==.',['月奥']='月奥:BAAAKgAFFAMIAwAAAA==.',['月清']='月清风:BAAAKgAFFAIIAgAAAA==.',['月瞳']='月瞳灬:BAACKgAFFH8jAAMdAAYITxjTBABfAQAdAAYI3hbTBABfAQASAAEI6xy7RwBWAAAqAAQKfxsAAx0ACAg5HYQhAHQBABIABAhGIh8zAI8BAB0ACAjuEoQhAHQBAAAA.',['有个']='有个老板:BAAAKgADCgUIBQAAAA==.',['有马']='有马宫熏:BAAAKgAFFAEIAQAAAA==.',['杨紫']='杨紫琼:BAABKgAFFH8FAAMeAAUIXQe9CABiAAAeAAQIrwm9CABiAAAfAAEIZwDpFwAQAAAAAA==.',['枫蝶']='枫蝶:BAAAKgAECggIDgAAAA==.',['柒上']='柒上捌下:BAAAKgADCgYICQAAAA==.',['柳眠']='柳眠棠丶:BAAAKgAECgMIAwAAAA==.',['桃桃']='桃桃龙:BAAAKgAECgUIBQAAAA==.',['梧桐']='梧桐雨风波亭:BAAAKgADCgYIBgAAAA==.',['椰菜']='椰菜宝宝:BAABKgAFFH8SAAIWAAYI+hwbDACHAQAWAAYI+hwbDACHAQAAAA==.',['欧款']='欧款:BAAAKgAFFAEIAQAAAA==.',['武侍']='武侍:BAAAKgADCggICAAAAA==.',['死亡']='死亡墓穴:BAABKgAECn8aAAIGAAgI7hckBwAIAgAGAAgI7hckBwAIAgAAAA==.',['死神']='死神回来了:BAAAKgADCgEIAQAAAA==.',['汀烟']='汀烟轻冉冉:BAAAKgAFFAYIAQAAAA==.',['泰瑞']='泰瑞娜丝:BAABKgAFFH8IAAIMAAQIzgtcCQDHAAAMAAQIzgtcCQDHAAAAAA==.',['洛阳']='洛阳:BAAAKgAECgMIAwAAAA==.',['浪浪']='浪浪山牛仙:BAAAKgAECgYICwAAAA==.',['浮云']='浮云:BAAAKgAFFAgIBAAAAA==.',['浮焰']='浮焰丶:BAAAKgAECgIIAgAAAA==.',['消融']='消融:BAABKgAFFH8FAAIWAAUIoRPrGACtAAAWAAUIoRPrGACtAAAAAA==.',['清风']='清风沐雨:BAAAKgAECgQICQAAAA==.',['温柔']='温柔的野兽:BAABKgAFFH8SAAMZAAYIEROkGwA9AQAZAAYIEROkGwA9AQAaAAYILAQAGADgAAAAAA==.',['游学']='游学者周卓:BAAAKgADCgIIAgAAAA==.',['游羽']='游羽入:BAABKgAFFH8IAAMJAAcIzxXZCQA0AQAJAAUI+BfZCQA0AQAQAAMIbRCxKQBKAAAAAA==.',['火鸡']='火鸡味锅笆:BAABKgAFFH8NAAIEAAgI8xsuBQDsAQAEAAgI8xsuBQDsAQAAAA==.',['灬樱']='灬樱木花道灬:BAAAKgAECggIDwAAAA==.',['灬淡']='灬淡然:BAACKgAFFH8sAAMFAAcIcSDsCADLAQAFAAcIXyDsCADLAQAKAAQINBpjFgBEAQAqAAQKfx0AAwUACAjTI5wMAHgCAAUACAhwIZwMAHgCAAoABwjNHKtKANQBAAAA.',['灬示']='灬示神灬:BAAAKgAECgQIBQAAAA==.',['灭却']='灭却诡:BAAAKgAFFAQIAwAAAA==.',['無忧']='無忧:BAAAKgAECggICgAAAA==.',['無念']='無念:BAABKgAFFH8JAAIKAAYIkA6dHQDgAAAKAAYIkA6dHQDgAAAAAA==.',['熊毛']='熊毛猫:BAABKgAECn8YAAIgAAcIlQnqTQADAQAgAAcIlQnqTQADAQAAAA==.',['燕山']='燕山月似钩:BAAAKgAECgIIAQAAAA==.',['爱吃']='爱吃土豆烧牛:BAAAKgADCggICAAAAA==.爱吃火锅:BAAAKgADCggICgAAAA==.',['爱新']='爱新觉罗武僧:BAAAKgAECgUIBwAAAA==.',['瑰冰']='瑰冰玉:BAABKgAFFH8GAAIVAAYI6BBEDwBPAQAVAAYI6BBEDwBPAQAAAA==.',['生生']='生生不息:BAAAKgAECgYIBgAAAA==.',['白色']='白色职业:BAAAKgAECgUIBQAAAA==.',['破心']='破心:BAACKgAFFH8cAAIBAAQIJyWbCgAsAQABAAQIJyWbCgAsAQAqAAQKfxcAAgEACAj7IN0nAGACAAEACAj7IN0nAGACAAAA.',['礼手']='礼手一挥:BAAAKgAFFAMIAwAAAA==.',['祁纪']='祁纪:BAABKgAFFH8IAAQcAAcIDBXOCACuAAAcAAMI6xvOCACuAAANAAMILA7YHACaAAAhAAIIiAHKGQAeAAAAAA==.',['神萝']='神萝卜:BAAAKgADCgcICwAAAA==.',['秋水']='秋水一泓:BAAAKgAFFAgICAAAAA==.',['秒杀']='秒杀你高姿态:BAAAKgAECgYIBgAAAA==.',['程肖']='程肖宇:BAAAKgAECgUIBgAAAA==.',['糖包']='糖包丶:BAAAKgADCgEIAQAAAA==.',['糖门']='糖门滚鲜橙多:BAAAKgADCgYIBgAAAA==.',['索尓']='索尓:BAAAKgAECgYIBgAAAA==.',['綻鴋']='綻鴋:BAAAKgAECgEIAQAAAA==.',['红胡']='红胡子:BAAAKgAECgcIEAAAAA==.',['维蕾']='维蕾塔:BAAAKgADCgIIAgAAAA==.',['缥缈']='缥缈奈子:BAAAKgADCggIDQAAAA==.',['缺德']='缺德:BAAAKgADCgEIAQAAAA==.',['翻白']='翻白眼的船:BAABKgAFFH8OAAMFAAgIgRalBQAZAgAFAAgIIBSlBQAZAgAKAAIILia/HADjAAAAAA==.',['聂克']='聂克猫:BAACKgAFFH8dAAIOAAQImiJmCgAlAQAOAAQImiJmCgAlAQAqAAQKfx0AAg4ACAhHH3ETADUCAA4ACAhHH3ETADUCAAAA.',['肥嘎']='肥嘎嘎:BAAAKgADCgUIBQAAAA==.',['肥猪']='肥猪腩肉:BAAAKgADCgEIAQAAAA==.',['肾上']='肾上腺:BAABKgAFFH8GAAILAAYIFwgYFgAZAQALAAYIFwgYFgAZAQAAAA==.',['舞洋']='舞洋:BAAAKgAFFAMIAwAAAA==.',['舞烊']='舞烊:BAAAKgADCggIAQAAAA==.',['舞羊']='舞羊:BAAAKgAFFAIIAgAAAA==.',['色仙']='色仙人自来也:BAAAKgAECgEIAQAAAA==.',['艾琳']='艾琳莎尔:BAAAKgAECgcIDQAAAA==.',['艾瑟']='艾瑟瑞斯:BAAAKgAECgcIBwAAAA==.',['艾莉']='艾莉西娅:BAABKgAFFH8FAAIBAAUI5QtmSQDbAAABAAUI5QtmSQDbAAAAAA==.',['花点']='花点时间:BAAAKgAFFAYIAgAAAA==.',['英勇']='英勇小鱼:BAAAKgADCgIIAgAAAA==.',['莫根']='莫根:BAAAKgAECgcIDAAAAA==.',['莴笋']='莴笋尖尖:BAAAKgAFFAQIBAAAAA==.',['萨满']='萨满的夏天:BAAAKgADCgIIAgAAAA==.',['蒂玛']='蒂玛:BAAAKgADCgYIBgAAAA==.',['蓝胡']='蓝胡子:BAAAKgADCgEIAQAAAA==.',['蜗牛']='蜗牛的梦想:BAAAKgAECggIDQAAAA==.',['血色']='血色英雄:BAAAKgADCggICAAAAA==.',['要离']='要离未离:BAABKgAFFH8JAAIiAAcIpgUCEwAjAQAiAAcIpgUCEwAjAQAAAA==.',['见手']='见手青:BAACKgAFFH8yAAIIAAcIGSBaAAAoAgAIAAcIGSBaAAAoAgAqAAQKfzMAAggACAjBILoYAEcCAAgACAjBILoYAEcCAAAA.',['说不']='说不出德无奈:BAAAKgAECgMIAwAAAA==.',['豆腐']='豆腐鱼:BAAAKgADCggICAAAAA==.',['贱气']='贱气长存:BAABKgAFFH8IAAIEAAgIvReZBAADAgAEAAgIvReZBAADAgAAAA==.',['赞美']='赞美圣光:BAAAKgAECggICAAAAA==.',['超级']='超级经济人:BAAAKgAECgUIBgAAAA==.',['轻抚']='轻抚板凳腿儿:BAAAKgADCggICwAAAA==.',['达摩']='达摩小祖师:BAAAKgADCgMIAwAAAA==.',['逍遥']='逍遥龍影:BAABKgAECn8aAAIiAAgIeAqoKwD4AAAiAAgIeAqoKwD4AAAAAA==.',['里奥']='里奥哟西:BAAAKgAECggIDgAAAA==.',['铁木']='铁木真:BAAAKgAECgMIAwAAAA==.',['铁血']='铁血的夏天:BAAAKgADCgcIBwAAAA==.',['闪电']='闪电:BAAAKgADCgUIBQAAAA==.闪电五连鞭:BAAAKgAECggIDgAAAA==.',['闪闪']='闪闪亮亮:BAAAKgAECgYIBgAAAA==.',['阿克']='阿克门德:BAAAKgAECgEIAQAAAA==.',['阿尔']='阿尔傻斯:BAAAKgAECgUIBQAAAA==.',['雕刻']='雕刻时光:BAABKgAFFH8WAAMRAAYIDhsBBQCQAQARAAYIDhsBBQCQAQAUAAYIwgxHFABCAQAAAA==.',['雾里']='雾里看花:BAAAKgAECgQIBwAAAA==.',['青丘']='青丘皮卡丘:BAACKgAFFH8pAAIWAAQIlwkVOgCbAAAWAAQIlwkVOgCbAAAqAAQKfzEAAhYACAjSGy8xALQBABYACAjSGy8xALQBAAAA.',['靓仔']='靓仔:BAAAKgAECgIIAgAAAA==.靓仔开个门:BAAAKgAECgMIAwAAAA==.',['非法']='非法行医:BAAAKgAFFAQIBAAAAA==.',['风暴']='风暴大地:BAAAKgAECgIIAwAAAA==.',['风铃']='风铃:BAAAKgADCggICAAAAA==.',['鬼影']='鬼影缠身:BAABKgAECn8fAAIIAAgIaCF5DwCPAgAIAAgIaCF5DwCPAgAAAA==.',['鳖犊']='鳖犊子:BAAAKgAECgQIBAAAAA==.',['黄宗']='黄宗泽:BAABKgAFFH8EAAILAAQI4AoiFgC0AAALAAQI4AoiFgC0AAAAAA==.',['黑夜']='黑夜:BAAAKgADCgQIBAAAAA==.',['黑胡']='黑胡子船长:BAAAKgAECgQIBAAAAA==.',['龙王']='龙王山炸天歌:BAAAKgAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end