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
 local lookup = {'Mage-Arcane','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Demonology','Warlock-Affliction','Rogue-Assassination','Rogue-Subtlety','Druid-Restoration','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','DemonHunter-Havoc','Priest-Shadow','Priest-Discipline','Priest-Holy','DeathKnight-Frost','Hunter-Survival','Unknown-Unknown','DemonHunter-Vengeance','Warrior-Arms','Warlock-Destruction','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','Paladin-Retribution','Evoker-Devastation','Rogue-Outlaw','Hunter-BeastMastery','Mage-Frost','Paladin-Holy','Druid-Guardian','Hunter-Marksmanship','Evoker-Preservation','Warrior-Fury','Druid-Feral','Warrior-Protection',}; local provider = {region='CN',realm='黑暗魅影',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ai='Aigle:BAAAKgAECgEIAQAAAA==.',Al='Allen:BAABKgAFFH8FAAMBAAMIiwAPSQAsAAABAAMIiwAPSQAsAAACAAIIJACAMwAUAAAAAA==.',Be='Beblzd:BAAAKgADCgEIAQAAAA==.',Bi='Biggie:BAAAKgAFFAQIBAAAAA==.Bingdkai:BAABKgAECn8oAAIDAAgInR7dHQBOAgADAAgInR7dHQBOAgAAAA==.',Co='Coralover:BAAAKgAECgcICQAAAA==.',De='Deathtalon:BAAAKgAECggICAAAAA==.',Fa='Fallansky:BAAAKgAECgEIAQAAAA==.',Ft='Fta:BAAAKgAECgIIAwAAAA==.',Ir='Ironegg:BAAAKgAECgYIBgAAAA==.',Ja='Jasonwswswws:BAABKgAFFH8JAAIEAAYIIhQ3AwBiAQAEAAYIIhQ3AwBiAQAAAA==.Jaunszc:BAAAKgAECgYIEQAAAA==.',Ke='Keytodeath:BAABKgAFFH8GAAMFAAYIdReDBQAfAQAFAAUI1xWDBQAfAQAGAAEI7R18HgBRAAAAAA==.',Le='Leomessi:BAAAKgADCgUIBQAAAA==.',Lo='Locoloco:BAAAKgAECgIIAgAAAA==.',Ne='Newegg:BAAAKgAFFAcIAwAAAA==.',No='Nothing:BAACKgAFFH8sAAMHAAUI6hjADgBlAQAHAAUI6hjADgBlAQAIAAEI6gZyEgA/AAAqAAQKf1sAAwcACAj/HnEMAFMCAAcACAj/HnEMAFMCAAgABggnEQ4eACsBAAAA.',On='Onyourself:BAAAKgAECgMIAwAAAA==.',Pr='Profane:BAAAKgAECggICAABKgAFFAgIAgABAAIWAA==.',Ra='Raj:BAAAKgAECgEIAQAAAA==.',Ri='Riaven:BAAAKgAECggICAAAAA==.',Ro='Roxrelive:BAABKgAFFH8MAAMJAAgIJhdvAgApAgAJAAgIJhdvAgApAgAKAAQI8Ax+PAC1AAAAAA==.Royals:BAAAKgADCgIIAgAAAA==.',Ta='Taurenmage:BAAAKgAECgEIAQAAAA==.',Tw='Twiszzt:BAAAKgAECggIAwAAAA==.',['一抹']='一抹浅笑:BAAAKgAECgcIBwAAAA==.',['一柱']='一柱清烟:BAAAKgAFFAMIAwAAAA==.',['一騎']='一騎当千:BAAAKgADCgUIBQAAAA==.',['七濑']='七濑爱丽丝:BAABKgAFFH8IAAMJAAQIrA/OIACnAAAJAAQIrA/OIACnAAAKAAMI3whQLACCAAAAAA==.',['七鴿']='七鴿鴿:BAAAKgADCggICAAAAA==.',['七鸽']='七鸽鸽:BAAAKgAFFAYIBAAAAA==.',['万叶']='万叶:BAACKgAFFH8iAAMLAAQIgR4zDAANAQALAAQIgR4zDAANAQAMAAMIax6mOQCcAAAqAAQKfzsABAsACAiZJEwJAK0CAAsACAiZJEwJAK0CAAwAAghzH4KqAGIAAA0AAgh6DgBXAFYAAAAA.',['三代']='三代头孢:BAAAKgAECgMIAwAAAA==.',['不信']='不信邪神:BAAAKgAECgEIAQAAAA==.',['不爱']='不爱吃猫的鱼:BAABKgAFFH8aAAIOAAUIgBfnDAAQAQAOAAUIgBfnDAAQAQAAAA==.',['不能']='不能熬夜:BAAAKgAFFAMIBAAAAA==.',['东北']='东北大老粗:BAAAKgADCggICAAAAA==.',['东方']='东方姑娘丶:BAABKgAECn8sAAQPAAgIMCA1EABiAgAPAAgIMCA1EABiAgAQAAgIFh8SEABIAgARAAEITwv7kgA0AAAAAA==.',['东海']='东海帝皇:BAABKgAECn8lAAMDAAgIsCNrEwCNAgADAAgIsCNrEwCNAgASAAMIeR0KJACeAAABKgAFFAgILQATABgeAA==.',['丨丶']='丨丶劣人:BAAAKgADCgcIBwABKgAFFAgIEgAUAAAAAQ==.丨丶忧郁:BAAAKgAFFAgIEgAAAQ==.',['丨子']='丨子姜丨:BAAAKgADCggICAAAAA==.',['丨聖']='丨聖光無用丨:BAAAKgAECggICAAAAA==.',['丨艾']='丨艾伦丨:BAABKgAFFH8NAAIVAAMIYQFaIgBRAAAVAAMIYQFaIgBRAAAAAA==.',['丶翠']='丶翠花:BAAAKgADCggICAAAAA==.',['丶若']='丶若小离:BAAAKgAFFAgIBAAAAA==.',['丷好']='丷好氣呀丷:BAAAKgAECgMIAwAAAA==.',['为为']='为为同学:BAABKgAFFH8FAAIWAAMI4g+yCwDUAAAWAAMI4g+yCwDUAAAAAA==.',['为了']='为了联盟:BAACKgAFFH8KAAMFAAMIFg9bDACIAAAFAAIIngxbDACIAAAXAAIIyg5YPwBvAAAqAAQKfx0ABAUACAioIpQKAE0CAAUABwjFIpQKAE0CABcABwh7G18lAOcBAAYAAQj9DWc/ADYAAAAA.为了部落:BAAAKgAECgQIBAAAAA==.',['为我']='为我存在:BAABKgAFFH8FAAMQAAUI7A/QDQDoAAAQAAQIMBTQDQDoAAAPAAEIfg/EKgBHAAAAAA==.',['主教']='主教萌萌哒:BAACKgAFFH8VAAMYAAQINRoCDgD1AAAYAAQINRoCDgD1AAAZAAQIRgH5CgBOAAAqAAQKfysAAxgACAgbGCYwAI8BABgACAgbGCYwAI8BABoAAQhqCkplADIAAAAA.',['乜人']='乜人:BAAAKgAECgMIAwAAAA==.',['予你']='予你双重防护:BAACKgAFFH8PAAMbAAQIFRPhCwCsAAAcAAQIPQ7cVgDDAAAbAAQIvxLhCwCsAAAqAAQKfygAAxsACAjoFeEXAKMBABsACAjoFeEXAKMBABwABwhACSHKAAoBAAAA.',['二甲']='二甲双胍片:BAACKgAFFH8GAAIMAAYIMAnsAgBVAQAMAAYIMAnsAgBVAQAqAAQKfyAAAwwACAjcFZQzALgBAAwACAjcFZQzALgBAAsACAjGElQ3AFsBAAAA.',['五日']='五日市芽依:BAABKgAFFH8MAAIdAAQIxhRnIwCzAAAdAAQIxhRnIwCzAAAAAA==.',['五行']='五行之魂:BAAAKgAFFAIIAgAAAA==.',['以一']='以一丶贯之:BAABKgAFFH8GAAIeAAMICBU7BQDHAAAeAAMICBU7BQDHAAAAAA==.',['伊能']='伊能静:BAAAKgAFFAQIBAAAAA==.',['伴缘']='伴缘:BAAAKgAECggIDQAAAA==.',['你最']='你最牛:BAAAKgADCgYIBgAAAA==.',['依然']='依然爱兽妖:BAABKgAFFH8IAAIfAAMIyA0VJADFAAAfAAMIyA0VJADFAAAAAA==.',['元始']='元始天尊:BAAAKgAECgEIAQAAAA==.',['光与']='光与影的平衡:BAABKgAFFH8GAAMRAAYImQctHQDXAAARAAUIngUtHQDXAAAQAAEIhg9pMABPAAABKgAFFAgIBAAUAAAAAA==.',['八个']='八个鸭子大:BAABKgAFFH8FAAMOAAMIGAqJNACvAAAOAAMIGAqJNACvAAAVAAEIOQNdJwAjAAAAAA==.',['八十']='八十岁太奶:BAAAKgAFFAIIAgABKgAFFAgIAwAUAAAAAA==.',['八神']='八神去一:BAACKgAFFH8SAAIDAAMIbhQgGADUAAADAAMIbhQgGADUAAAqAAQKfx0AAgMACAi6HpUlACUCAAMACAi6HpUlACUCAAAA.',['冰与']='冰与火之格格:BAABKgAFFH8MAAICAAYI7xOzDgBVAQACAAYI7xOzDgBVAQAAAA==.',['冷霜']='冷霜冰:BAAAKgAECgUIBQAAAA==.',['凤凰']='凤凰天使:BAAAKgAECgUIBQAAAA==.',['凸绝']='凸绝恋乄萨凸:BAABKgAFFH8JAAMMAAMIyRw7EQDyAAAMAAMIyRw7EQDyAAALAAMINQ7gFgC9AAAAAA==.',['刀一']='刀一抬死一排:BAAAKgAECgcIBwAAAA==.',['刀把']='刀把子:BAAAKgAECgUIBgAAAA==.',['别怕']='别怕我在:BAAAKgAECggICAAAAA==.',['别送']='别送我能奶:BAABKgAFFH8KAAIYAAQIQQd7JgCJAAAYAAQIQQd7JgCJAAAAAA==.',['刻晴']='刻晴:BAAAKgADCgYIBgAAAA==.',['剑灬']='剑灬来:BAAAKgAECgIIAgAAAA==.',['南极']='南极冰冰:BAAAKgAECgYIDAAAAA==.',['卡布']='卡布奇诺灬:BAABKgAFFH8dAAQBAAUITx4OEgBXAQABAAUITx4OEgBXAQACAAMI5xEEIgCoAAAgAAEIHSF5HgBDAAAAAA==.',['卡比']='卡比兽:BAACKgAFFH8ZAAIDAAQIoRw3FwDZAAADAAQIoRw3FwDZAAAqAAQKfxQAAgMACAg9GxUzAOYBAAMACAg9GxUzAOYBAAAA.',['压迫']='压迫众生:BAABKgAFFH8JAAMEAAQIAxFDIgCVAAAEAAQIAxFDIgCVAAADAAEIAACXNwAAAAAAAA==.',['只会']='只会寒冰箭:BAAAKgAECggICAAAAA==.',['只爱']='只爱版本苟:BAABKgAFFH8SAAIVAAMIpxQ6CwCqAAAVAAMIpxQ6CwCqAAAAAA==.只爱玩奶德:BAAAKgAECggIDQAAAA==.',['可儿']='可儿:BAAAKgADCggICAAAAA==.',['叶婧']='叶婧依:BAABKgAFFH8GAAQbAAYIkxVHDQCdAAAbAAIIDxlHDQCdAAAhAAIIww5/DwCEAAAcAAIIzgm7TwBIAAABKgAFFAgIEgAbAOocAA==.',['名字']='名字随便:BAAAKgADCgcIBwAAAA==.',['呆呆']='呆呆肥猫:BAAAKgAFFAYIAwAAAA==.',['呆小']='呆小夏:BAABKgAFFH8GAAIiAAMIUQEuDgA7AAAiAAMIUQEuDgA7AAAAAA==.',['咆哮']='咆哮幻灵:BAAAKgAECgcIBwAAAA==.咆哮幽冥:BAAAKgAECggIEgAAAA==.咆哮影刃:BAAAKgAECggICAAAAA==.咆哮灵法:BAAAKgAECgUIBQAAAA==.',['咿呀']='咿呀咿呀吆:BAAAKgAFFAMIAwAAAA==.',['哀川']='哀川润:BAABKgAFFH8GAAIOAAQIKRCHGQDCAAAOAAQIKRCHGQDCAAABKgAFFAgILQATABgeAA==.',['哈世']='哈世骑:BAABKgAFFH8GAAIbAAYIdAktFADXAAAbAAYIdAktFADXAAAAAA==.',['哈納']='哈納逹丨漪酷:BAAAKgAECgUIBQAAAA==.',['哈邱']='哈邱:BAAAKgAECgQIBAAAAA==.',['唤魔']='唤魔行者:BAAAKgADCgQIBAAAAA==.',['啸风']='啸风勇者无敌:BAAAKgAECgUIBQAAAA==.',['喔嚯']='喔嚯:BAAAKgAECgQIBAAAAA==.',['喵兔']='喵兔兔:BAABKgAFFH8JAAIMAAMIwBvsIAD1AAAMAAMIwBvsIAD1AAAAAA==.',['嗳幽']='嗳幽喂:BAAAKgADCggICAAAAA==.',['嗷呜']='嗷呜:BAACKgAFFH8oAAIfAAUI7SD1DgCGAQAfAAUI7SD1DgCGAQAqAAQKf00AAh8ACAh3JTAOAMsCAB8ACAh3JTAOAMsCAAAA.',['圣光']='圣光吃了你:BAAAKgAECgMIAwAAAA==.圣光小橙子:BAABKgAFFH8KAAIcAAYIDBFcKQBCAQAcAAYIDBFcKQBCAQAAAA==.圣光牛牛:BAACKgAFFH8IAAIcAAIImBrnbQCPAAAcAAIImBrnbQCPAAAqAAQKfxUAAhwABwj5HuZ7AFkBABwABwj5HuZ7AFkBAAAA.',['圣骑']='圣骑诗:BAAAKgAECggIDgAAAA==.',['地心']='地心之战:BAAAKgADCgIIAgAAAA==.',['地牢']='地牢一刻:BAACKgAFFH8GAAIDAAIIOxrAIAChAAADAAIIOxrAIAChAAAqAAQKfycAAgMACAhdJD0HANoCAAMACAhdJD0HANoCAAAA.',['墜亠']='墜亠落:BAAAKgAECgEIAQAAAA==.',['夏若']='夏若夕阳:BAAAKgAECgUICAAAAA==.',['多听']='多听五月天:BAAAKgAECgEIAQAAAA==.多听周杰伦:BAAAKgAECgEIAQAAAA==.',['夜不']='夜不留情:BAAAKgAECgEIAQAAAA==.',['夢星']='夢星尘:BAAAKgADCgIIBAAAAA==.',['大兽']='大兽猩:BAAAKgAFFAEIAQAAAA==.',['大善']='大善人:BAAAKgADCgEIAQAAAA==.',['大学']='大学物理:BAAAKgADCgcIBwAAAA==.',['大江']='大江江:BAAAKgAFFAMIAwAAAA==.',['大表']='大表阁:BAAAKgADCggIDQAAAA==.',['天火']='天火同人:BAAAKgAECgQIBAAAAA==.',['奶你']='奶你不如奶狗:BAAAKgAFFAgIBAAAAA==.',['奶油']='奶油奶牛奶流:BAABKgAFFH8IAAIfAAQIoyBvHgDdAAAfAAQIoyBvHgDdAAAAAA==.',['奶牛']='奶牛杀手:BAAAKgAECggICAAAAA==.',['娜贝']='娜贝拉鲁伽马:BAAAKgAECgUICQAAAA==.',['宝爷']='宝爷同款:BAAAKgAFFAYIBAAAAA==.',['寒冰']='寒冰魅影:BAAAKgAFFAIIAgAAAA==.',['寶汏']='寶汏蜀:BAAAKgAFFAEIAQAAAA==.',['导演']='导演:BAACKgAFFH8cAAMfAAQIshnULgDOAAAfAAMIzRfULgDOAAAjAAQIZhJ8FQC2AAAqAAQKfzAAAyMACAgcIvUJAJQCACMACAgcIvUJAJQCAB8ABwiVHRlbAJ8BAAAA.',['小声']='小声蛐蛐你丶:BAAAKgADCgIIAgAAAA==.',['小小']='小小烈儿:BAAAKgAECgQIBAAAAA==.小小蓉蓉:BAAAKgAECgcICAAAAA==.小小阿壮:BAAAKgAFFAgIAgAAAA==.',['小海']='小海棠:BAAAKgAFFAEIAQAAAA==.',['小艾']='小艾会武术:BAAAKgAECgYICAAAAA==.',['小黄']='小黄鸭灬:BAAAKgADCggICAAAAA==.',['小黑']='小黑子丶铁须:BAABKgAFFH8IAAIcAAgICBYcCQAwAgAcAAgICBYcCQAwAgAAAA==.',['少年']='少年浮云:BAAAKgAFFAQIBAAAAA==.',['岩井']='岩井宗久:BAAAKgAFFAIIAgAAAA==.',['岳绮']='岳绮罗:BAAAKgAECgYIBgAAAA==.',['左亦']='左亦是右:BAABKgAFFH8IAAIfAAYIMx/yDwB7AQAfAAYIMx/yDwB7AQAAAA==.',['巫猫']='巫猫汪:BAAAKgADCgEIAQAAAA==.',['巭嘦']='巭嘦孬灬嫑粜:BAABKgAECn8UAAMNAAgIVRgCJwCOAQANAAcI5BoCJwCOAQALAAcI5wwoPAAeAQAAAA==.',['差不']='差不多的先生:BAAAKgAECggICAAAAA==.',['希尔']='希尔瓦那厮:BAABKgAFFH8RAAIjAAMItgZyOQCRAAAjAAMItgZyOQCRAAAAAA==.',['带云']='带云携雨:BAAAKgAFFAIIBAAAAA==.',['幺幺']='幺幺零:BAAAKgADCgQIBAAAAA==.',['幼稚']='幼稚完:BAAAKgAFFAgIBAAAAA==.',['庄青']='庄青霜:BAAAKgAECgYIAgAAAA==.',['康永']='康永哥:BAACKgAFFH8dAAQXAAgIVCEwAQDwAQAXAAgIMyEwAQDwAQAFAAQIYx57BwAEAQAGAAQIXhoeCgDaAAAqAAQKfxkABAUACAhxGqwLAC0CAAUACAhxGqwLAC0CABcABQiFD81hAOgAAAYAAQgWDiZKACkAAAAA.',['弦歌']='弦歌琉琉:BAABKgAECn8yAAMgAAgImB09DwBUAgAgAAgImB09DwBUAgABAAMIXQn7QwBEAAAAAA==.',['影丿']='影丿少龙灬:BAAAKgADCggICAAAAA==.',['影之']='影之冰鱼:BAABKgAFFH8GAAICAAYIEgzsDwBHAQACAAYIEgzsDwBHAQAAAA==.',['影子']='影子月夜:BAACKgAFFH8IAAMCAAQIvBlvIQDQAAACAAQIBhBvIQDQAAABAAQIHBeKKgC5AAAqAAQKfxwAAwEACAiHFtcVAIYBAAEABwhiFNcVAIYBACAACAixEjcmAIQBAAEqAAUUCAgLAAEALBUA.',['心光']='心光光:BAAAKgAFFAIIAgAAAA==.',['怪影']='怪影神骑:BAACKgAFFH8FAAMcAAUIYB5SFwD9AAAcAAQIZBxSFwD9AAAbAAEIViQFJgBdAAAqAAQKfxgAAhwACAjiHDRgAJ8BABwACAjiHDRgAJ8BAAAA.',['恶魔']='恶魔的低语:BAAAKgAECggICgAAAA==.',['惊世']='惊世:BAAAKgADCggIGQAAAA==.',['成都']='成都第一深情:BAAAKgAFFAQIBAAAAA==.',['我发']='我发型可以吗:BAAAKgAFFAEIAQAAAA==.',['我是']='我是小三:BAAAKgADCgEIAQAAAA==.我是帆帆呀:BAABKgAFFH8LAAMKAAQIMRMAOwC5AAAKAAQIMRMAOwC5AAAJAAQIFBH+IQCgAAAAAA==.',['我有']='我有点紧张:BAACKgAFFH8IAAMjAAMIlxrRIQDrAAAjAAMIlxrRIQDrAAAfAAEIugPPZAAkAAAqAAQKfxUAAyMACAiMG5xFADoBACMABwjaGpxFADoBAB8ABwhlGuJ/ADYBAAAA.',['我爱']='我爱绿油油:BAAAKgAFFAEIAQAAAA==.',['战吊']='战吊:BAAAKgAECgIIAgAAAA==.',['找不']='找不到吃的:BAABKgAECn8gAAIcAAgIKSHvKwBvAgAcAAgIKSHvKwBvAgAAAA==.',['把爱']='把爱带回家:BAACKgAFFH8JAAIJAAMIGg3uIwCWAAAJAAMIGg3uIwCWAAAqAAQKfyUAAgkACAiyF5EdANoBAAkACAiyF5EdANoBAAAA.',['抚冥']='抚冥:BAAAKgAECgQIBAAAAA==.',['拉斯']='拉斯塔哈:BAABKgAFFH8IAAIKAAgIeRtGBQBuAgAKAAgIeRtGBQBuAgAAAA==.',['摸鱼']='摸鱼小能手:BAABKgAECn8ZAAIcAAgIxCDNKABdAgAcAAgIxCDNKABdAgAAAA==.',['故无']='故无所思:BAAAKgAECgQIBAAAAA==.',['救赎']='救赎:BAAAKgAECgMIBAAAAA==.',['新一']='新一代:BAAAKgADCggIBgAAAA==.',['无敌']='无敌小宋宋:BAAAKgAECgMIBAAAAA==.',['日月']='日月火华:BAAAKgADCggICAAAAA==.',['时光']='时光鱼丶:BAAAKgAFFAMIAwAAAA==.',['星夜']='星夜孤行:BAAAKgAFFAIIAgAAAA==.',['是输']='是输出:BAAAKgADCgMIAwAAAA==.',['晓聋']='晓聋人:BAAAKgADCggICAAAAA==.',['最爱']='最爱玩戰士:BAAAKgAECgMIAwAAAA==.最爱风清云淡:BAAAKgADCggIEAAAAA==.',['月光']='月光淋漓:BAAAKgAECgEIAQAAAA==.',['木木']='木木枭:BAABKgAFFH8GAAIKAAMIZhgUKgDrAAAKAAMIZhgUKgDrAAABKgAFFAgIGQADAKEcAA==.',['木頭']='木頭秂:BAAAKgAECgEIAQAAAA==.',['机甲']='机甲战神:BAAAKgAFFAgIBAAAAA==.',['杀手']='杀手奶牛:BAAAKgAFFAIIBAAAAA==.',['東東']='東東:BAAAKgADCggICAAAAA==.',['极术']='极术极士极:BAAAKgADCgMIAwAAAA==.',['林深']='林深时见鹿:BAAAKgADCgEIAQAAAA==.',['柒灬']='柒灬柒:BAAAKgAECggIEwAAAA==.',['柠檬']='柠檬果冻:BAAAKgAECgIIAgAAAA==.柠檬骑士:BAABKgAFFH8GAAMcAAQIxhZ3EgAMAQAcAAQIxhZ3EgAMAQAhAAIIAAc4EwBSAAAAAA==.',['桂桂']='桂桂术:BAAAKgAFFAQIBAAAAA==.',['桃芝']='桃芝妖妖:BAAAKgAFFAgIBAAAAA==.',['梦游']='梦游娃娃:BAABKgAFFH8GAAIXAAYI0BZ9FQBYAQAXAAYI0BZ9FQBYAQAAAA==.',['梦璃']='梦璃幽兰:BAAAKgAECgYIBwAAAA==.',['梦黎']='梦黎甄:BAAAKgAECggIEgAAAA==.',['梵天']='梵天米:BAAAKgADCgQIBAAAAA==.',['樱桃']='樱桃妈妈:BAAAKgAFFAQIBAAAAA==.',['欲骑']='欲骑你卢俊义:BAAAKgADCgQIBAAAAA==.',['武川']='武川:BAAAKgAECgYIBgAAAA==.',['死在']='死在冲锋路上:BAAAKgADCgIIAgAAAA==.',['死的']='死的快:BAAAKgAECgYIDwAAAA==.',['死骑']='死骑兽兽:BAABKgAFFH8GAAIDAAYIZwk/GwBEAQADAAYIZwk/GwBEAQAAAA==.',['永丶']='永丶怡:BAABKgAFFH8GAAMGAAYIlBlRBwAPAQAGAAUIcx1RBwAPAQAXAAEIGQq7LABUAAAAAA==.',['污喵']='污喵王乄:BAAAKgAECgUIBQAAAA==.',['法子']='法子:BAAAKgADCgMIAwAAAA==.',['法爷']='法爷求开门:BAAAKgAECgYIBgAAAA==.',['泡椒']='泡椒风爪:BAAAKgAFFAYIBAAAAA==.',['泡泡']='泡泡术丶士:BAABKgAFFH8TAAQGAAMIHBl1FgCKAAAXAAMIAw0hOACQAAAGAAIIpRN1FgCKAAAFAAEIoSF+IQBaAAAAAA==.',['洛特']='洛特溪:BAAAKgADCggICAAAAA==.',['流天']='流天类星龙:BAABKgAFFH8MAAMdAAYIDSLJAwByAQAdAAYIDSLJAwByAQAkAAIIFRvvCQBRAAABKgAFFAgIBQAlAKkWAA==.',['淘气']='淘气的奇奇:BAACKgAFFH8IAAMkAAQIvhd/AgADAQAkAAQIvhd/AgADAQAdAAQIsxzrDADnAAAqAAQKfxsAAyQACAiEGgsGADMCACQACAiEGgsGADMCAB0ABwjdF7QsAFQBAAAA.',['淡蓝']='淡蓝色忧郁:BAAAKgADCggICAAAAA==.',['混乱']='混乱之殇:BAAAKgAECggICAAAAA==.',['清风']='清风勇者玩惧:BAAAKgADCgcIBwAAAA==.清风笑烟雨:BAAAKgADCggIDQAAAA==.',['满大']='满大街兄弟:BAABKgAFFH8HAAIfAAMIQBf1GQDFAAAfAAMIQBf1GQDFAAAAAA==.',['灬浮']='灬浮尘:BAAAKgADCgMIAwAAAA==.',['点点']='点点小雨滴:BAAAKgAFFAQIBAAAAA==.',['烈儿']='烈儿:BAAAKgAECgIIAgAAAA==.',['烧鸭']='烧鸭冠军:BAAAKgAECggICAABKgAFFAgIBgADAHQcAA==.',['烮人']='烮人:BAAAKgAECgQIBAAAAA==.',['煉獄']='煉獄丶死神:BAABKgAECn8xAAIDAAgIHh/tFQBcAgADAAgIHh/tFQBcAgAAAA==.',['熟饺']='熟饺子:BAAAKgAECgMIAwAAAA==.',['燚焱']='燚焱炎火:BAACKgAFFH8MAAMbAAYIlw05EgDsAAAbAAYIlw05EgDsAAAcAAIIURAhPwCJAAAqAAQKfyMAAhwACAiWH5gzAFUCABwACAiWH5gzAFUCAAAA.',['爷来']='爷来辣:BAAAKgAECgYIBgAAAA==.',['牙签']='牙签小德:BAAAKgAFFAMIBAAAAA==.',['牛坷']='牛坷垃:BAAAKgAECgYIBgAAAA==.',['牛孑']='牛孑精灵:BAAAKgAECgIIAgAAAA==.',['犀利']='犀利兽哥:BAAAKgAECgYIDAAAAA==.',['狂怒']='狂怒:BAAAKgAECgcICQAAAA==.',['狂蹦']='狂蹦小蚱蜢:BAAAKgAECgIIAgAAAA==.',['玉娇']='玉娇龙叮当:BAABKgAECn8YAAIjAAgIBBPqEgClAQAjAAgIBBPqEgClAQAAAA==.',['玩累']='玩累歇一会儿:BAAAKgAECgMIAwAAAA==.',['玲珑']='玲珑水色:BAABKgAFFH8NAAMFAAYIpiCCAABwAQAFAAUIbRyCAABwAQAXAAYISxyaFABfAQAAAA==.',['珂末']='珂末吉灬依库:BAABKgAFFH8FAAQKAAUIfQ7DKgDoAAAKAAMI0xHDKgDoAAAmAAEICQ2EDQBBAAAJAAEI7QKENwA+AAAAAA==.',['璃蛊']='璃蛊迷心:BAABKgAECn8wAAMOAAgIbhWENgB9AQAOAAgIxxOENgB9AQAVAAgIZhB+JgBGAQABKgAFFAgIEwAhAD4MAA==.',['瓦斯']='瓦斯特:BAACKgAFFH8KAAIBAAMIqRffIgDYAAABAAMIqRffIgDYAAAqAAQKfyEABAEACAhkIc4QAHICAAEACAgPIc4QAHICAAIABwh3EF9JAF0BACAABQhqFZVIAEMBAAAA.',['生气']='生气的小土豆:BAAAKgADCgQIBAAAAA==.',['畜僧']='畜僧趣满果:BAAAKgAECgMIAwAAAA==.',['畜笙']='畜笙:BAAAKgAECgYICwAAAA==.',['疏远']='疏远的可以:BAAAKgAFFAgIAQAAAA==.',['疯一']='疯一样的男子:BAAAKgAECggICwAAAA==.',['疯灬']='疯灬狂灬包灬:BAAAKgADCgIIAgAAAA==.',['疯狂']='疯狂的皮皮:BAABKgAFFH8NAAIcAAQIShIvJADWAAAcAAQIShIvJADWAAAAAA==.',['白榆']='白榆的白:BAABKgAFFH8dAAIMAAYIJyTgBwDKAQAMAAYIJyTgBwDKAQAAAA==.',['皮城']='皮城大土豪:BAABKgAFFH8GAAIMAAYIQAu0FQAtAQAMAAYIQAu0FQAtAQAAAA==.皮城莱因哈特:BAABKgAFFH8OAAMDAAgIhBGVBQAVAgADAAgIhBGVBQAVAgAEAAEIAACwFQAAAAAAAA==.',['盛世']='盛世贰零贰壹:BAAAKgADCgEIAQAAAA==.',['盼盼']='盼盼防盗:BAACKgAFFH8qAAIMAAUI5R1mDACEAQAMAAUI5R1mDACEAQAqAAQKfyAAAgwACAgpGtEiAAcCAAwACAgpGtEiAAcCAAAA.',['真乃']='真乃大丈夫也:BAAAKgAECgEIAQAAAA==.',['瞧你']='瞧你那揍性:BAAAKgADCgMIAwAAAA==.',['石局']='石局残:BAAAKgAFFAgIBAAAAA==.',['神圣']='神圣丶失格:BAAAKgAFFAEIAQAAAA==.',['神我']='神我来救你:BAAAKgAECgcICAAAAA==.',['祷言']='祷言:BAABKgAFFH8MAAQPAAYIwBj/CQBhAQAPAAYIwBj/CQBhAQAQAAMIchFRKQBwAAARAAEIKQKSPwA5AAAAAA==.',['空白']='空白式丶月影:BAAAKgAECggIAQAAAA==.空白式丶浩劫:BAAAKgAECggICAAAAA==.空白式丶清算:BAAAKgAECggICAAAAA==.',['精灵']='精灵小术:BAABKgAECn8cAAQXAAcIMCGvHwAHAgAXAAcIFiCvHwAHAgAFAAMIgiJaLwArAQAGAAEIiCAAOwBaAAAAAA==.',['精神']='精神病会传染:BAAAKgAECgQIAQAAAA==.',['索利']='索利达尔:BAACKgAFFH8SAAMfAAMIWBYCHgDfAAAfAAMIMxICHgDfAAAjAAEINBULTwBBAAAqAAQKfxUAAx8ACAiHIAY/APwBAB8ACAiHIAY/APwBACMAAQiWBqSPACsAAAAA.',['紫色']='紫色天使:BAAAKgAECgUIBgAAAA==.',['紫薯']='紫薯精:BAABKgAFFH8GAAIcAAYI+hmcHwByAQAcAAYI+hmcHwByAQAAAA==.',['约德']='约德尔弓兵:BAAAKgADCgcIBwAAAA==.',['终极']='终极灵魂:BAABKgAFFH8IAAIlAAQI/RYYDwD+AAAlAAQI/RYYDwD+AAAAAA==.',['绊翩']='绊翩只爱:BAAAKgADCggICAAAAA==.',['绝版']='绝版炮手:BAABKgAFFH8TAAIcAAYIyRoADQAgAQAcAAYIyRoADQAgAQAAAA==.',['老炮']='老炮丶:BAAAKgAECggICwAAAA==.',['考拉']='考拉桑:BAAAKgADCgQIBAAAAA==.',['联盟']='联盟万户侯:BAACKgAFFH8HAAIcAAMImhdGPwDzAAAcAAMImhdGPwDzAAAqAAQKfxcAAhwACAjqIjIhAH0CABwACAjqIjIhAH0CAAAA.',['肥嘟']='肥嘟嘟流口水:BAAAKgADCgYIBgAAAA==.',['背时']='背时娃儿:BAAAKgADCggICAAAAA==.',['胖丁']='胖丁子:BAAAKgAFFAYIBAAAAA==.',['胡牛']='胡牛腰:BAAAKgAECgIIAwAAAA==.',['脸滚']='脸滚的荣光:BAAAKgAECgcIBwAAAA==.',['舟舟']='舟舟:BAAAKgAECggIEAAAAA==.',['花间']='花间:BAABKgAFFH8GAAIRAAYIWwZLDgDlAAARAAYIWwZLDgDlAAAAAA==.花间灬萨:BAAAKgADCggICAAAAA==.',['苍澜']='苍澜沉歌:BAABKgAECn8xAAMDAAgIdBc+LADKAQADAAgIdBc+LADKAQAEAAgINQXNOACfAAABKgAFFAgIEwAhAD4MAA==.',['范二']='范二小青年:BAAAKgAECgEIAQAAAA==.',['荣耀']='荣耀与尊严:BAAAKgAECgIIAgAAAA==.',['药药']='药药丷切克闹:BAACKgAFFH8OAAMeAAMIVxqcBADXAAAeAAMIVxqcBADXAAAHAAMIjBGQHADIAAAqAAQKfxgAAwgACAhWGbAPAO8BAAgACAjkFLAPAO8BAAcABAgiGVElAEABAAAA.',['莉莉']='莉莉丝女王:BAABKgAFFH8GAAICAAQIESJ8NQBvAAACAAQIESJ8NQBvAAABKgAFFAgIBgACAOgaAA==.',['莹草']='莹草:BAAAKgAFFAIIAgABKgAFFAgIEwAfAIEjAA==.',['菠萝']='菠萝棒棒冰:BAABKgAFFH8HAAMCAAYIfxEdDwBQAQACAAYIVA4dDwBQAQABAAEIWBhQJgBJAAAAAA==.',['萝卜']='萝卜丝妹妹:BAAAKgAECgQIBgAAAA==.',['蓝凌']='蓝凌雨:BAACKgAFFH8GAAICAAYIXyFhAgD3AQACAAYIXyFhAgD3AQAqAAQKfyoAAwIACAhIJuoAAAsDAAIACAhIJuoAAAsDACAACAjUGXNKADsBAAAA.',['蔡伊']='蔡伊琳:BAAAKgAFFAQIAgAAAA==.',['蕾欧']='蕾欧娜:BAACKgAFFH8GAAIBAAYITQt+DwA1AQABAAYITQt+DwA1AQAqAAQKfxYAAgEACAhNGpQKAC4CAAEACAhNGpQKAC4CAAEqAAUUCAgmABwA6CAA.',['蟋蟀']='蟋蟀的坏坏:BAABKgAFFH8NAAIgAAcI8hRDBACnAQAgAAcI8hRDBACnAQAAAA==.',['血之']='血之守护者:BAACKgAFFH8mAAIcAAgI6CCYCwAOAgAcAAgI6CCYCwAOAgAqAAQKf14AAxwACAjDJdQCAAADABwACAjDJdQCAAADABsACAjgGrMYAJsBAAAA.血之灬萨基:BAACKgAFFH8oAAILAAYINyBUBADTAQALAAYINyBUBADTAQAqAAQKf2wAAgsACAg9JiQBAPsCAAsACAg9JiQBAPsCAAEqAAUUCAgmABwA6CAA.',['血染']='血染山河:BAAAKgAFFAQIBAAAAA==.血染暗夜:BAACKgAFFH8HAAMfAAMI6AwjMwCSAAAjAAMIpQs3NgCbAAAfAAII/g8jMwCSAAAqAAQKfyEAAx8ACAiZI6oLAMUCAB8ACAiZI6oLAMUCACMABgg2HCouAH8BAAAA.血染河山:BAAAKgAFFAQIBAAAAA==.',['血羽']='血羽金翎:BAAAKgAECgUIBQAAAA==.',['血蹄']='血蹄村古天乐:BAAAKgADCgEIAgAAAA==.',['衮衮']='衮衮:BAAAKgAECgEIAQAAAA==.',['西西']='西西蛤:BAAAKgAFFAgIBAAAAA==.',['要钱']='要钱:BAAAKgAECgYIDAAAAA==.',['諸訷']='諸訷灬黃昏:BAACKgAFFH8WAAMlAAQIRx76EwDnAAAlAAQI/BT6EwDnAAAWAAIITxuQHQCeAAAqAAQKfyYABCUACAgCHTkaADwCACUACAj9GzkaADwCABYABQivGOoqAGMBACcAAwiuEzQrAK4AAAAA.諸訷黃昏:BAAAKgADCgMIAwAAAA==.',['说好']='说好不哭:BAAAKgAECgUIBQAAAA==.',['诸葛']='诸葛大力:BAAAKgAFFAIIAgAAAA==.',['谋刹']='谋刹似水年华:BAACKgAFFH8GAAIcAAMIHBOZJgDXAAAcAAMIHBOZJgDXAAAqAAQKfxQAAxwACAgvGH5gANsBABwABwh2G35gANsBABsAAQiFBPdnABUAAAAA.',['贝嘶']='贝嘶可乐:BAACKgAFFH8NAAMcAAMIowgKQgCCAAAcAAMIowgKQgCCAAAbAAMI8wO5EQBnAAAqAAQKfzIAAhwACAiLHQZDACYCABwACAiLHQZDACYCAAAA.',['赤壁']='赤壁的妖术师:BAAAKgADCggICAAAAA==.',['赤蜻']='赤蜻蛉:BAAAKgAECggICQAAAA==.',['赵家']='赵家三少爷:BAABKgAECn8VAAIDAAgI4xg4JQDzAQADAAgI4xg4JQDzAQAAAA==.',['跑炮']='跑炮狍:BAAAKgAECggICAAAAA==.',['蹦蹦']='蹦蹦又跳跳:BAAAKgADCgcIBwAAAA==.',['辣条']='辣条就午饭:BAAAKgAECgQIBgAAAA==.辣条就早饭:BAAAKgAECgcIBwAAAA==.',['辰辰']='辰辰不接:BAACKgAFFH8HAAILAAMI8SPxAwAfAQALAAMI8SPxAwAfAQAqAAQKfyAAAgsACAhOJewJAKYCAAsACAhOJewJAKYCAAAA.',['过来']='过来含到:BAAAKgAECgYICwAAAA==.',['遨游']='遨游牛必撒:BAAAKgAECgYIBgAAAA==.遨游牛必牧:BAAAKgAECgMIAwAAAA==.',['那些']='那些花花:BAAAKgAECgMIAwAAAA==.',['都是']='都是时辰的错:BAABKgAFFH8IAAIcAAQIWBOOHADxAAAcAAQIWBOOHADxAAAAAA==.',['酒醒']='酒醒皆空:BAAAKgAECgcIBwAAAA==.',['醉爱']='醉爱风清云淡:BAAAKgADCgMIAwAAAA==.',['鉴定']='鉴定费:BAAAKgAECgUIBQAAAA==.',['铁风']='铁风铃:BAAAKgAFFAYIBAAAAA==.',['锤死']='锤死你的温柔:BAAAKgADCgcIBwAAAA==.',['闪灵']='闪灵灬:BAAAKgADCgMIAwAAAA==.',['问就']='问就是爱玩:BAAAKgAECgQIBwAAAA==.',['阔阔']='阔阔:BAABKgAFFH8HAAIBAAcIFgjsDAB2AQABAAcIFgjsDAB2AQAAAA==.',['阿丝']='阿丝匹林:BAAAKgAECgYICAAAAA==.',['阿瑞']='阿瑞莎特:BAAAKgAFFAMIAwAAAA==.',['雪之']='雪之下雪乃:BAAAKgAECgEIAQABKgAFFAgILQATABgeAA==.',['雪妍']='雪妍:BAAAKgAFFAMIAwAAAA==.',['霜之']='霜之哀丶伤:BAAAKgAECggIDQABKgAFFAgIFgADAGsZAA==.霜之老大:BAABKgAECn8ZAAIiAAYI+SPHCgD9AQAiAAYI+SPHCgD9AQAAAA==.',['霞之']='霞之丘丶诗羽:BAAAKgADCggICAAAAA==.',['霸气']='霸气外泄:BAAAKgAECgQIBAAAAA==.',['非洲']='非洲扫地工:BAAAKgAFFAIIAgAAAA==.',['非酋']='非酋之怒:BAABKgAECn8XAAMhAAgIDhWCHwBkAQAhAAYIgBqCHwBkAQAcAAgIrQxCjgAwAQAAAA==.',['韭菜']='韭菜:BAABKgAFFH8IAAIRAAQIgAd8LwCIAAARAAQIgAd8LwCIAAAAAA==.',['風飾']='風飾的灰翼:BAABKgAFFH8GAAIEAAYIygtbBgAsAQAEAAYIygtbBgAsAQAAAA==.',['风之']='风之羽:BAABKgAFFH8GAAMjAAQIOAeJOgCNAAAjAAQIIgaJOgCNAAAfAAIIwgbiPgBuAAAAAA==.',['风烈']='风烈小萨满:BAAAKgADCggICAAAAA==.风烈小龙人:BAAAKgAECgQIBAAAAA==.风烈快递员:BAAAKgADCgIIAgAAAA==.风烈梦游:BAACKgAFFH8FAAIcAAIIsRdSMwCkAAAcAAIIsRdSMwCkAAAqAAQKfxUAAhwACAhZI+oiAI4CABwACAhZI+oiAI4CAAAA.风烈火:BAAAKgAECggIDAAAAA==.风烈炎:BAABKgAFFH8NAAIfAAMIGBz3JgDqAAAfAAMIGBz3JgDqAAAAAA==.风烈焰:BAAAKgAECggICAAAAA==.风烈焰爆:BAABKgAFFH8HAAMmAAMIOBbeBAD1AAAmAAMIOBbeBAD1AAAKAAMIiAUVRgCXAAAAAA==.风烈顺水:BAAAKgAECgQIBAAAAA==.',['风险']='风险投资总裁:BAAAKgAECggICQAAAA==.',['飚飚']='飚飚车遛遛狗:BAAAKgAECggIDAAAAA==.',['飞翔']='飞翔的牛牛:BAAAKgADCggICAAAAA==.',['飞霄']='飞霄:BAAAKgADCgMIAwAAAA==.',['饼干']='饼干小旋风:BAAAKgAECgQIBAAAAA==.',['骑士']='骑士江江:BAAAKgAFFAYIAgAAAA==.',['骑子']='骑子:BAABKgAFFH8KAAIcAAYIxxjJKQBAAQAcAAYIxxjJKQBAAQAAAA==.',['骑牛']='骑牛:BAAAKgADCggICAAAAA==.',['高压']='高压锅:BAABKgAFFH8UAAInAAQIoAZtEAB6AAAnAAQIoAZtEAB6AAAAAA==.',['鬼辻']='鬼辻舞无惨:BAAAKgADCggICAAAAA==.',['魔枪']='魔枪洛亚:BAAAKgAFFAQIBAAAAA==.',['鲜榨']='鲜榨牛奶:BAAAKgAECgUIBgAAAA==.',['鹰旗']='鹰旗护卫者:BAAAKgADCgEIAQAAAA==.',['黄昏']='黄昏灬諸訷:BAAAKgAFFAEIAQAAAA==.',['黑暗']='黑暗并肩:BAAAKgAECgUIBQAAAA==.',['黑桃']='黑桃爱:BAACKgAFFH8MAAIaAAIIMRZbFgCEAAAaAAIIMRZbFgCEAAAqAAQKfyUAAhoACAjzIgkGAMQCABoACAjzIgkGAMQCAAAA.',['黑糖']='黑糖荞麦茶:BAAAKgAFFAMIBAAAAA==.',['黑色']='黑色果醋:BAAAKgAECggICAAAAA==.',['黑锋']='黑锋寨扛把子:BAAAKgAECgEIAQAAAA==.',['鼓上']='鼓上蚤拆迁:BAAAKgADCgMIAwAAAA==.',['龙格']='龙格里格隆:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end