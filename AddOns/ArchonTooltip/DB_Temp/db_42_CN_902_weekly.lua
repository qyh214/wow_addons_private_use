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
 local lookup = {'Hunter-BeastMastery','Monk-Windwalker','Warlock-Affliction','Hunter-Marksmanship','Evoker-Devastation','Shaman-Restoration','Warlock-Destruction','Warrior-Protection','Paladin-Retribution','Paladin-Protection','Hunter-Survival','Mage-Arcane','Unknown-Unknown','Druid-Guardian','Warlock-Demonology','Shaman-Elemental','Rogue-Assassination','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Fury','Druid-Balance','Druid-Restoration','Monk-Mistweaver','Priest-Holy','Priest-Shadow','Priest-Discipline',}; local provider = {region='CN',realm='黑锋哨站',name='CN',type='weekly',zone=42,date='2025-08-04',data={Bi='Bibor:BAABKgAFFH8GAAIBAAYIvAYmEwD3AAABAAYIvAYmEwD3AAAAAA==.',He='Hedy:BAAAKgAECgcIAwAAAA==.',Ka='Kaiyang:BAAAKgAECgEIAQAAAA==.',Oj='Ojk:BAABKgAFFH8KAAICAAgIPxWWBAD9AQACAAgIPxWWBAD9AQAAAA==.',['一只']='一只胶胶鼠:BAABKgAFFH8GAAIDAAYIYhVIAwBjAQADAAYIYhVIAwBjAQAAAA==.',['七月']='七月天:BAAAKgAECgUIBQAAAA==.',['三岁']='三岁会打猎:BAABKgAFFH8IAAMEAAgIjgiQHQAGAQAEAAQIsAmQHQAGAQABAAQIDQdiQQCaAAAAAA==.',['不归']='不归的风:BAAAKgAECgUIBQAAAA==.',['不德']='不德不愛:BAAAKgADCggICAAAAA==.',['举射']='举射无双:BAAAKgAECgcIEAAAAA==.',['乐玲']='乐玲:BAAAKgAECgMIAwAAAA==.乐玲利:BAAAKgAECgcIDAAAAA==.',['你也']='你也是龙:BAACKgAFFH8wAAIFAAgIsB63CQDZAQAFAAgIsB63CQDZAQAqAAQKfxcAAgUACAhAHmcQAEoCAAUACAhAHmcQAEoCAAAA.',['你是']='你是不是聋啊:BAAAKgADCgYIBgAAAA==.',['你要']='你要相信光:BAABKgAFFH8MAAIGAAYIqhzpBwCZAQAGAAYIqhzpBwCZAQAAAA==.',['儒乐']='儒乐的儒越:BAAAKgADCgUIBQAAAA==.',['别叫']='别叫我史莱克:BAABKgAFFH8HAAIHAAcIsBFiCQDDAQAHAAcIsBFiCQDDAQAAAA==.',['卡蜜']='卡蜜尔:BAAAKgAECgQIBAAAAA==.',['听雨']='听雨望云:BAABKgAECn8XAAMBAAgIViO7EwCuAgABAAgIuSK7EwCuAgAEAAgIYhtlKACeAQAAAA==.',['咸蛋']='咸蛋生气的魔:BAABKgAFFH8GAAIFAAYIeRDCDwBlAQAFAAYIeRDCDwBlAQAAAA==.',['哥就']='哥就是传说哥:BAACKgAFFH8TAAIIAAMILAj7DwB/AAAIAAMILAj7DwB/AAAqAAQKfzcAAggACAjOFaoIAL0BAAgACAjOFaoIAL0BAAAA.',['圣骑']='圣骑没有奶:BAABKgAFFH8SAAIJAAYIAxVJGwD0AAAJAAYIAxVJGwD0AAAAAA==.',['埃尔']='埃尔:BAACKgAFFH8bAAIKAAMIvwtQHwCCAAAKAAMIvwtQHwCCAAAqAAQKfzUAAwoACAgSFssXAKQBAAoACAgSFssXAKQBAAkAAQj5BdaHASUAAAAA.',['夜踏']='夜踏初雪无痕:BAAAKgAECggICAAAAA==.',['大领']='大领主来了:BAAAKgAFFAIIAgAAAA==.',['天下']='天下无双:BAABKgAFFH8HAAMEAAMIJQeXHQCBAAAEAAMIJQeXHQCBAAALAAEI7QHlBQAmAAAAAA==.',['天外']='天外飛仙:BAAAKgAECgYIBgAAAA==.',['女人']='女人你凭什么:BAABKgAFFH8MAAIMAAYIpR6YCQDPAQAMAAYIpR6YCQDPAQAAAA==.',['安妮']='安妮可姬:BAAAKgAECgIIAgABKgAFFAQIBAANAAAAAA==.',['小安']='小安子的大哥:BAAAKgAECgUIBQAAAA==.',['小小']='小小孑凡人:BAAAKgAECgYICAAAAA==.',['小心']='小心儿丶:BAAAKgAECggIBwAAAA==.',['小時']='小時候可牛了:BAAAKgAFFAgIBAAAAA==.',['小猪']='小猪快吃:BAAAKgAFFAIIBAAAAA==.',['巴巴']='巴巴师:BAAAKgAFFAIIAgAAAA==.巴巴燕:BAABKgAECn8ZAAIOAAgIyhS6CwCgAQAOAAgIyhS6CwCgAQAAAA==.巴巴骑:BAABKgAECn8XAAMKAAgIHBHPHgBhAQAKAAgIHBHPHgBhAQAJAAMI1A3kVAFWAAAAAA==.巴巴龙:BAAAKgAECggIEgAAAA==.',['常茁']='常茁:BAABKgAFFH8GAAMHAAYIggiMJwDSAAAHAAQINQiMJwDSAAAPAAIItgk2KwBEAAAAAA==.',['弦歌']='弦歌问情:BAABKgAFFH8HAAMGAAQI8iRABAA+AQAGAAQI8iRABAA+AQAQAAMIUQx4DADLAAAAAA==.',['影子']='影子:BAAAKgADCgQIBAAAAA==.',['恋爱']='恋爱达人:BAAAKgAFFAYIBAAAAA==.',['我宁']='我宁做我:BAAAKgADCgMIAwAAAA==.',['我看']='我看不到你:BAAAKgAECgYIBgAAAA==.',['戳你']='戳你屁屁:BAABKgAFFH8OAAIRAAgIow24BAAtAgARAAgIow24BAAtAgAAAA==.',['打那']='打那個法師:BAAAKgAECgYIBgAAAA==.',['拉个']='拉个糖:BAABKgAFFH8RAAQHAAgISyDUAwBRAgAHAAgILBvUAwBRAgADAAUIWh0HBwDwAAAPAAIIXyN8EwCnAAAAAA==.',['拟态']='拟态蛇:BAAAKgADCgcIBwAAAA==.',['救不']='救不了你:BAAAKgADCgMIAwAAAA==.',['斗士']='斗士的殿堂:BAAAKgAECgcIBwAAAA==.',['暴躁']='暴躁老郑:BAAAKgAFFAYIBAAAAA==.',['杨超']='杨超越丶:BAAAKgAECggICwAAAA==.',['死判']='死判丶云嫇:BAAAKgADCggICAAAAA==.死判丶冲隐:BAAAKgAECgEIAgAAAA==.死判丶化龙:BAACKgAFFH8GAAISAAYIWA0wGABcAQASAAYIWA0wGABcAQAqAAQKfxQAAxIACAg1EUxBAG0BABIACAhTEExBAG0BABMACAi+C84oAAQBAAEqAAUUCAgVABQAsRoA.',['死扛']='死扛的小园丁:BAABKgAFFH8MAAMVAAYI/AhpGQDcAAAVAAUISwZpGQDcAAAWAAUI0gUCDgCuAAAAAA==.',['水琴']='水琴:BAAAKgADCgMIAwAAAA==.',['求过']='求过丶不搞事:BAAAKgAFFAEIAQAAAA==.',['洋芋']='洋芋粑:BAAAKgADCgIIAgAAAA==.',['烟酒']='烟酒不戒:BAAAKgAFFAMIAwAAAA==.',['爱是']='爱是壹道光:BAAAKgADCgMIBAAAAA==.',['甘草']='甘草酸苷:BAAAKgAECgYIBgAAAA==.',['甜胚']='甜胚子:BAAAKgADCggICAAAAA==.',['祖国']='祖国版步兵:BAABKgAFFH8GAAIIAAYIZwRNBwC1AAAIAAYIZwRNBwC1AAAAAA==.',['紧道']='紧道岩:BAAAKgAFFAMIAwAAAA==.',['緣緣']='緣緣:BAAAKgAFFAgIBAAAAA==.',['自然']='自然萌:BAAAKgADCgEIAQAAAA==.',['莫七']='莫七托:BAABKgAECn8hAAIBAAgI2SK6FQClAgABAAgI2SK6FQClAgAAAA==.',['蒙美']='蒙美丽:BAABKgAFFH8HAAIXAAQI0AwpEgAYAQAXAAQI0AwpEgAYAQAAAA==.',['西瓜']='西瓜不配头:BAABKgAFFH8GAAIYAAYIsRlZBwCAAQAYAAYIsRlZBwCAAQAAAA==.',['西蒙']='西蒙:BAAAKgAECgYIBgAAAA==.',['赤目']='赤目妖瞳:BAAAKgAECgUIBQAAAA==.',['跑快']='跑快快:BAAAKgADCggIEAAAAA==.',['轩辕']='轩辕战:BAABKgAFFH8GAAIJAAYIaRLWEgBvAQAJAAYIaRLWEgBvAQAAAA==.',['部落']='部落牛哥哥:BAAAKgAFFAEIAQAAAA==.',['镹仕']='镹仕慕思:BAABKgAECn8YAAQZAAgIxQvYKwAvAQAZAAgIxQvYKwAvAQAYAAYIzgtgVwDdAAAaAAYIyge6XgCmAAAAAA==.',['雨落']='雨落青檐:BAABKgAFFH8KAAIJAAUIKxBHNgARAQAJAAUIKxBHNgARAQAAAA==.',['雲羽']='雲羽:BAAAKgAECgMIAwAAAA==.',['霜鬃']='霜鬃:BAACKgAFFH8JAAIIAAMI5AKsEgBnAAAIAAMI5AKsEgBnAAAqAAQKfysAAggACAgXCdgkANsAAAgACAgXCdgkANsAAAAA.',['靖水']='靖水:BAAAKgAFFAEIAQAAAA==.靖水空:BAABKgAFFH8GAAMBAAMIZAZoKABkAAABAAII/wZoKABkAAAEAAIIbgNcJQBLAAAAAA==.',['鸟毛']='鸟毛曲四曲:BAAAKgAECggIBwAAAA==.',['鸡尾']='鸡尾酒:BAAAKgAFFAIIAgAAAA==.',['黄飞']='黄飞冯:BAAAKgAECggIEAAAAA==.',['黑椒']='黑椒牛排:BAAAKgADCggICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end