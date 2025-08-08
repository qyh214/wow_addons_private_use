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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','Priest-Holy','Priest-Discipline','Warrior-Arms','Rogue-Assassination','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Hunter-BeastMastery','Evoker-Devastation','Priest-Shadow','Monk-Mistweaver','Mage-Frost','DemonHunter-Havoc',}; local provider = {region='CN',realm='深渊之喉',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ca='Capricornus:BAABKgAFFH8KAAMBAAYIJxb1EQCLAQABAAYIJxb1EQCLAQACAAQIAxJFEQC3AAAAAA==.',Fe='Feilunfl:BAAAKgAECgQIAwAAAA==.',Ic='Ichimarugin:BAAAKgADCggICAAAAA==.',Ji='Jianglver:BAAAKgADCgYIBgAAAA==.',Ky='Kyle:BAABKgAECn8VAAIDAAYI7SEqWwDnAQADAAYI7SEqWwDnAQAAAA==.',Ma='Maxel:BAAAKgAECgUIBQAAAA==.',['一剑']='一剑倾城:BAABKgAFFH8GAAIDAAYIsAuJJwBKAQADAAYIsAuJJwBKAQAAAA==.',['丨二']='丨二三四:BAAAKgAFFAQIBAAAAA==.',['乀弑']='乀弑魂乚风铃:BAABKgAECn8bAAMEAAgIJBeUDgCgAQAEAAgIJBeUDgCgAQAFAAcIThHMEAAzAQAAAA==.',['人狠']='人狠话不多:BAAAKgAECgUICAAAAA==.',['付款']='付款转世:BAAAKgADCggICAAAAA==.',['兜兜']='兜兜里有奶糖:BAAAKgAECgEIAQAAAA==.',['八零']='八零记忆:BAAAKgAECgMIAwAAAA==.',['兰斯']='兰斯洛特:BAAAKgAECgMIBQAAAA==.',['其实']='其实不错:BAAAKgAECgYIBgAAAA==.',['冰夜']='冰夜圣光行者:BAAAKgAECgMIBAAAAA==.冰夜风行者:BAAAKgAECgMIAwAAAA==.',['刘小']='刘小七:BAAAKgAFFAIIBAAAAA==.',['制裁']='制裁者的小手:BAAAKgADCgIIAgAAAA==.',['刺血']='刺血光铸骑:BAAAKgAECgEIAQAAAA==.刺血土灵猎:BAAAKgAFFAMIAwAAAA==.',['功夫']='功夫:BAAAKgAFFAYIBAAAAA==.',['另一']='另一天堂:BAAAKgAECggIDAAAAA==.',['叶枫']='叶枫挡不住:BAAAKgAECgYICQAAAA==.',['叶落']='叶落晚秋:BAAAKgAFFAYIBAAAAA==.',['哒哒']='哒哒怪:BAABKgAFFH8GAAIGAAYIaBFvCwBWAQAGAAYIaBFvCwBWAQAAAA==.',['啵瑞']='啵瑞:BAAAKgADCgQIBAAAAA==.',['嗜血']='嗜血烟头:BAABKgAFFH8GAAIHAAIIXAoOJQB+AAAHAAIIXAoOJQB+AAAAAA==.',['土豪']='土豪肥肥:BAAAKgAFFAgIBgAAAA==.',['圣光']='圣光跑路:BAAAKgAECgUIBQAAAA==.',['圣大']='圣大力:BAABKgAFFH8IAAIDAAgIEhmLBwA+AgADAAgIEhmLBwA+AgAAAA==.',['夕阳']='夕阳:BAAAKgADCggIDgAAAA==.',['大肥']='大肥仔:BAAAKgAFFAQIBAAAAA==.',['大黑']='大黑妞:BAAAKgAECgEIAQAAAA==.',['天怒']='天怒:BAAAKgAECgMIAwAAAA==.',['夷陵']='夷陵啊羊:BAACKgAFFH8LAAQIAAMI0xARDQB/AAAIAAII1g0RDQB/AAAJAAEIzhYlIQBHAAAKAAEIPQnYUAAwAAAqAAQKfywABAgACAh8GeUQAPgBAAgACAhIGOUQAPgBAAoABwhiE8ZAAGcBAAkAAQjwDdxAADAAAAAA.',['奶一']='奶一甩量似海:BAABKgAFFH8GAAIDAAYIAiPaDwDiAQADAAYIAiPaDwDiAQAAAA==.',['奶水']='奶水就是多:BAABKgAFFH8IAAIEAAQImxdeJgCpAAAEAAQImxdeJgCpAAAAAA==.',['妈妈']='妈妈:BAABKgAFFH8KAAILAAMIyxG2NQC9AAALAAMIyxG2NQC9AAAAAA==.',['姚舜']='姚舜禹:BAAAKgAECggICQAAAA==.',['小仓']='小仓木麻衣:BAABKgAFFH8JAAILAAMIaQ7tOQCyAAALAAMIaQ7tOQCyAAAAAA==.',['小爷']='小爷帅:BAAAKgAECgYICgAAAA==.',['小钢']='小钢炮:BAAAKgADCgEIAQAAAA==.',['小龙']='小龙虾蛋挞:BAABKgAECn8VAAIDAAgIrxh8XQDiAQADAAgIrxh8XQDiAQAAAA==.',['尛傲']='尛傲天:BAAAKgAECgYICAAAAA==.',['布洛']='布洛特:BAAAKgAFFAgIBAAAAA==.',['帕罗']='帕罗西汀:BAABKgAFFH8MAAIKAAgIbBCjCQC/AQAKAAgIbBCjCQC/AQAAAA==.',['幸运']='幸运之翼:BAAAKgAECgIIAgAAAA==.',['弑神']='弑神冰凌:BAAAKgADCgQIBAAAAA==.弑神凌天:BAAAKgADCgcIBwAAAA==.',['急冻']='急冻盖拉:BAABKgAFFH8KAAIDAAYIEhY+JQBUAQADAAYIEhY+JQBUAQAAAA==.',['恶灵']='恶灵之眼:BAAAKgAECgQIBAAAAA==.',['战无']='战无双:BAAAKgADCgIIAgAAAA==.',['抹茶']='抹茶味丨薯片:BAAAKgADCgcICQAAAA==.',['摘要']='摘要:BAAAKgAFFAMIAwAAAA==.',['新坝']='新坝萨拉赫:BAABKgAFFH8GAAIMAAYIOh79CgC8AQAMAAYIOh79CgC8AQAAAA==.',['无敌']='无敌牛牛骑:BAABKgAFFH8GAAIDAAYIUhyEFAC4AQADAAYIUhyEFAC4AQAAAA==.',['无言']='无言可非:BAAAKgAECgYIBgAAAA==.',['星外']='星外飞仙:BAAAKgADCgEIAQAAAA==.',['星星']='星星有光哦:BAAAKgADCgEIAQAAAA==.',['杜鹃']='杜鹃花开:BAABKgAFFH8IAAIFAAgIJhaBAgAZAgAFAAgIJhaBAgAZAgAAAA==.',['杨无']='杨无敌:BAAAKgAFFAIIAgAAAA==.',['栤凝']='栤凝:BAABKgAFFH8MAAMFAAgIdg5GDQBCAQAFAAYIIQ1GDQBCAQANAAUIhQ8wEQDXAAAAAA==.',['欢喜']='欢喜小闪电:BAAAKgAFFAQIAQAAAA==.',['每天']='每天都烦:BAAAKgAECggICAAAAA==.',['流苏']='流苏如画:BAAAKgAFFAgIBAAAAA==.',['淡淡']='淡淡灬煙萫菋:BAAAKgADCgEIAQAAAA==.',['炉后']='炉后王:BAAAKgAECggIDgAAAA==.',['熊猫']='熊猫阿波:BAAAKgADCggICAAAAA==.',['爷小']='爷小帅:BAAAKgAECgQIBgAAAA==.',['牧丶']='牧丶殇情:BAAAKgADCggIEgAAAA==.',['狂傲']='狂傲丨孤魂:BAACKgAFFH8pAAMIAAYI6BO/CAD1AAAIAAQIUBa/CAD1AAAKAAUIUA3DGAC+AAAqAAQKfz4ABAoACAhZHWchAP0BAAoACAgCGWchAP0BAAgABgiVHqwfAI4BAAkAAgimESdDADsAAAAA.',['狂野']='狂野杀戮:BAAAKgAFFAQIBAAAAA==.',['玉魂']='玉魂:BAAAKgADCgIIAgAAAA==.',['琉朱']='琉朱:BAAAKgAFFAEIAQAAAA==.',['璃洛']='璃洛亦寒:BAAAKgADCggICAAAAA==.',['生气']='生气士:BAABKgAFFH8KAAIDAAIINxFaOACYAAADAAIINxFaOACYAAAAAA==.',['疯丨']='疯丨狂灵动澄:BAABKgAFFH8GAAILAAYI5BOMEwBZAQALAAYI5BOMEwBZAQAAAA==.',['白盒']='白盒红塔山:BAAAKgADCgcIBwAAAA==.',['白鸟']='白鸟悠:BAABKgAFFH8GAAIDAAYIQhJKIgBkAQADAAYIQhJKIgBkAQAAAA==.',['碧落']='碧落琉璃:BAAAKgAECggIDgABKgAFFAgIBgAOABUEAA==.',['神圣']='神圣随风起舞:BAAAKgAECggIEwAAAA==.',['秋叶']='秋叶残酒丶:BAABKgAECn8YAAINAAgIqxiJHgDiAQANAAgIqxiJHgDiAQAAAA==.',['粗又']='粗又壮:BAABKgAFFH8GAAIBAAYIlBtgEQCQAQABAAYIlBtgEQCQAQAAAA==.',['苹果']='苹果:BAABKgAFFH8IAAIPAAgIURpaAQBuAgAPAAgIURpaAQBuAgAAAA==.',['虫丶']='虫丶虫:BAAAKgADCggICAAAAA==.',['蛮不']='蛮不讲理:BAAAKgAECgYIBgAAAA==.',['血魔']='血魔归来:BAAAKgAFFAEIAQAAAA==.血魔殘月:BAAAKgADCgMIAwAAAA==.',['被蛋']='被蛋卷:BAAAKgAECgEIAQAAAA==.',['贴脸']='贴脸就是撸:BAABKgAFFH8SAAIDAAYIcCTiDgDsAQADAAYIcCTiDgDsAQAAAA==.',['路过']='路过的骑士:BAAAKgADCgQIBgAAAA==.',['还魂']='还魂:BAABKgAECn8XAAIOAAgIdRPnMQCFAQAOAAgIdRPnMQCFAQAAAA==.',['醉春']='醉春风:BAAAKgAECgEIAgAAAA==.',['锋芒']='锋芒毕露:BAABKgAFFH8GAAIDAAYIEiEwKgDJAAADAAYIEiEwKgDJAAAAAA==.',['雨落']='雨落红颜:BAAAKgAFFAIIAgAAAA==.',['香糯']='香糯鲜肉粽:BAAAKgADCggIEAAAAA==.',['高桥']='高桥刘一桐:BAAAKgAFFAMIAwAAAA==.',['魔大']='魔大力:BAABKgAFFH8IAAIQAAgIfhi0BQBSAgAQAAgIfhi0BQBSAgAAAA==.',['麦香']='麦香牛:BAABKgAFFH8GAAICAAYI6Q7uEAAcAQACAAYI6Q7uEAAcAQABKgAFFAgIDgABAEoXAA==.',['黑尛']='黑尛天:BAAAKgAECgYIBgAAAA==.',['黒尛']='黒尛天:BAAAKgAECgIIAgAAAA==.',['龙蛋']='龙蛋蛋挞:BAAAKgADCggIEAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end