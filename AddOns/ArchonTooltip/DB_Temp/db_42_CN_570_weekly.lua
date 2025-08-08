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
 local lookup = {'Mage-Frost','Warrior-Fury','Rogue-Assassination','Hunter-Marksmanship','Evoker-Devastation','Priest-Holy','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Protection','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Priest-Discipline','Priest-Shadow','Monk-Windwalker','Monk-Mistweaver','Paladin-Holy',}; local provider = {region='CN',realm='伊森德雷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Az='Azazmm:BAABKgAFFH8IAAIBAAYIPA2VBQBSAQABAAYIPA2VBQBSAQAAAA==.',Bi='Bigshow:BAAAKgADCgMIAwAAAA==.',He='Heol:BAAAKgAECgEIAQAAAA==.',Ki='Kik:BAAAKgADCgEIAQAAAA==.Kinki:BAAAKgAFFAYIBAAAAA==.',Le='Lemon:BAAAKgAECggIBwAAAA==.',Mc='Mcqueens:BAAAKgADCggICQAAAA==.',Pa='Palading:BAAAKgADCgYIBwAAAA==.',Ro='Rocket:BAAAKgAECgEIAQAAAA==.',Th='Threehundred:BAAAKgADCgMIAwAAAA==.',['一口']='一口甜甜:BAAAKgAECgYICgAAAA==.',['七星']='七星照:BAAAKgADCgQIBAAAAA==.',['不要']='不要熬夜:BAAAKgAECgcICgAAAA==.',['丨聖']='丨聖丨:BAAAKgAECgYIBgAAAA==.',['九宫']='九宫格肥:BAAAKgAECgEIAQAAAA==.',['五蕴']='五蕴皆空:BAAAKgAECgcICAAAAA==.',['他哥']='他哥:BAAAKgAECgUIBQAAAA==.',['伊芙']='伊芙尼奇:BAABKgAFFH8LAAICAAYIwA9gEABPAQACAAYIwA9gEABPAQAAAA==.',['伤不']='伤不起小灰灰:BAAAKgADCgYIBgAAAA==.',['何以']='何以丿为战:BAAAKgAFFAIIAgAAAA==.',['你压']='你压我头发了:BAAAKgAFFAQIBAAAAA==.',['俊爹']='俊爹:BAAAKgAECgYICgAAAA==.',['俺小']='俺小舅江燕骑:BAAAKgAECgYIBgAAAA==.',['傀麵']='傀麵娃娃:BAAAKgAECgQIBAAAAA==.',['克里']='克里斯蒂亚诺:BAAAKgAFFAIIBAAAAA==.',['冲我']='冲我来:BAAAKgAFFAMIAwAAAA==.',['凭栏']='凭栏雨夜:BAABKgAFFH8GAAIDAAYIORW/DQBzAQADAAYIORW/DQBzAQAAAA==.',['剑指']='剑指:BAAAKgAFFAYIBAAAAA==.',['努力']='努力有奇迹:BAAAKgAFFAMIAgAAAA==.',['十六']='十六夜:BAAAKgAFFAQIBAAAAA==.',['叶卡']='叶卡特琳娜猫:BAAAKgAECgEIAQAAAA==.',['吃布']='吃布丁:BAABKgAFFH8FAAIEAAUI7g3wEADtAAAEAAUI7g3wEADtAAAAAA==.',['吕布']='吕布吕布:BAABKgAECn8WAAICAAgI1hnAHQADAQACAAgI1hnAHQADAQAAAA==.',['呦你']='呦你来真的:BAABKgAFFH8JAAIFAAUIZQ+zGgDrAAAFAAUIZQ+zGgDrAAAAAA==.',['哈苏']='哈苏:BAAAKgAFFAQIBAAAAA==.',['大象']='大象一一二二:BAAAKgAFFAIIAgAAAA==.大象一二三一:BAAAKgAECgQIBAAAAA==.大象一二三四:BAAAKgAECgYIBgAAAA==.大象一零零一:BAAAKgADCgEIAQAAAA==.大象七七八八:BAAAKgADCgQIBQAAAA==.大象七五九五:BAAAKgAECggIEQAAAA==.大象三零六三:BAABKgAFFH8MAAIFAAQIOAn0FwClAAAFAAQIOAn0FwClAAAAAA==.大象九五二七:BAACKgAFFH8KAAIEAAQIaBgWJwDOAAAEAAQIaBgWJwDOAAAqAAQKfysAAgQACAjlI/gGALYCAAQACAjlI/gGALYCAAAA.大象五二六九:BAAAKgAFFAQIAwAAAA==.大象八八四八:BAABKgAFFH8MAAIGAAQIBRDKFQCQAAAGAAQIBRDKFQCQAAAAAA==.大象零五五七:BAAAKgAECgcICQAAAA==.大象零五六一:BAAAKgAECgUICQAAAA==.大象零四零三:BAAAKgAECgIIAgAAAA==.',['大龙']='大龙猫:BAAAKgAECgYICwAAAA==.',['天灰']='天灰的像哭过:BAABKgAFFH8JAAIHAAMIHxfuGADMAAAHAAMIHxfuGADMAAAAAA==.',['妲己']='妲己:BAAAKgAECggICAABKgAFFAgICAAIAC8jAA==.',['娜璐']='娜璐璐:BAAAKgAFFAQIBAAAAA==.',['寂静']='寂静的无奈:BAAAKgAFFAEIAgAAAA==.',['寒冰']='寒冰:BAAAKgAFFAIIAgAAAA==.',['小小']='小小福子:BAAAKgAECggIDAAAAA==.',['小布']='小布丁丶:BAAAKgAFFAIIAgAAAA==.',['小德']='小德会变身:BAAAKgAECgcIDgAAAA==.',['小红']='小红人练习生:BAABKgAFFH8UAAMJAAgImBvvAQBXAgAJAAgIwRbvAQBXAgAKAAYI4B7tCwDQAQAAAA==.',['小菜']='小菜鸡:BAABKgAFFH8IAAMIAAQIwRJaKADRAAAIAAQIuBBaKADRAAALAAQIPgcEEQB8AAAAAA==.',['尤型']='尤型玩物:BAACKgAFFH8SAAQMAAUI8A68CAD1AAAMAAUILw68CAD1AAANAAMI+Q4KGAB/AAAOAAII1worJgB3AAAqAAQKfxoABAwACAg+HG8MACUCAAwACAg9HG8MACUCAA4ABAhJFMBeAPMAAA0AAQiYDNVCADsAAAAA.',['带丶']='带丶妳丶飞:BAAAKgADCgQIBAAAAA==.',['忘仔']='忘仔的小白:BAABKgAFFH8GAAIPAAYIwhRTCwBgAQAPAAYIwhRTCwBgAQAAAA==.',['忘忘']='忘忘小牧:BAAAKgAFFAYIAgAAAA==.',['我是']='我是法爷:BAAAKgAECgUIBQAAAA==.',['救世']='救世主夜宿:BAAAKgAECggICAAAAA==.',['文波']='文波:BAAAKgAECgEIAQAAAA==.',['时间']='时间挺欠揍:BAAAKgAECgEIAQAAAA==.',['月亮']='月亮战神:BAABKgAFFH8IAAIIAAgIKQqDOwD/AAAIAAgIKQqDOwD/AAAAAA==.',['月亽']='月亽:BAAAKgAFFAQIBAAAAA==.',['月希']='月希:BAABKgAECn8YAAIMAAgISBLxHQCYAQAMAAgISBLxHQCYAQAAAA==.',['有马']='有马贵将:BAAAKgAECgYIBgAAAA==.',['木帆']='木帆船:BAAAKgAECgUIBQAAAA==.',['本人']='本人纯属虚构:BAAAKgAFFAQIBAABKgAFFAgIFAAOALEhAA==.',['术爷']='术爷有专攻:BAABKgAFFH8LAAQNAAQIiCCvBQD+AAANAAQIiCCvBQD+AAAOAAIIdARYMQBDAAAMAAEIAAC+JAAAAAAAAA==.',['来个']='来个随机:BAAAKgADCggICAAAAA==.',['桃园']='桃园奈奈生:BAAAKgADCggICAAAAA==.',['横宫']='横宫七海:BAAAKgADCgEIAQAAAA==.',['此女']='此女无敌:BAAAKgAECgYIBgAAAA==.',['浣熊']='浣熊倩:BAABKgAFFH8HAAIIAAQILxHeWAC/AAAIAAQILxHeWAC/AAAAAA==.',['浪匕']='浪匕透心凉:BAAAKgAECgcICAAAAA==.',['淡忘']='淡忘忧伤:BAAAKgAFFAYIAwAAAA==.',['滨边']='滨边美波:BAAAKgADCgEIAQAAAA==.',['烮天']='烮天:BAAAKgADCggICAAAAA==.',['牧云']='牧云清歌:BAAAKgAECgcIBwAAAA==.',['狂暴']='狂暴灬蛮牛:BAAAKgAECgUIBQAAAA==.狂暴的蚂蚁:BAABKgAECn8lAAIHAAgI6x/LIAA6AgAHAAgI6x/LIAA6AgAAAA==.',['猎码']='猎码糕手:BAAAKgAFFAgIBAAAAA==.',['玉面']='玉面手蕾王:BAAAKgAECgYIBgAAAA==.',['王慢']='王慢慢:BAAAKgADCggICAAAAA==.',['玩什']='玩什么呢啊:BAAAKgAFFAIIBAAAAA==.',['皮皮']='皮皮好好看:BAAAKgAECggICAAAAA==.',['瞪你']='瞪你咋滴:BAABKgAECn8kAAIOAAgIixmeFwDqAQAOAAgIixmeFwDqAQAAAA==.',['神仙']='神仙摘葡萄:BAAAKgAECgEIAQAAAA==.',['神代']='神代噗噗:BAAAKgAECgYIEAAAAA==.',['神灬']='神灬通:BAAAKgAECggICAAAAA==.',['祭碧']='祭碧瑶:BAABKgAFFH8VAAMIAAgIvxjyBwA0AgAIAAgIzxPyBwA0AgALAAYIzhrzBQCTAQAAAA==.',['福贵']='福贵儿:BAAAKgAECgIIAgAAAA==.',['离析']='离析:BAABKgAFFH8KAAQQAAgI/xYQCwADAQAQAAQIuhYQCwADAQAPAAMIGB2jFgCrAAAGAAEIbhpLPQBHAAAAAA==.',['空心']='空心房图:BAAAKgAFFAEIAQAAAA==.',['红豆']='红豆汤包:BAAAKgAECgYICgAAAA==.',['聖珖']='聖珖:BAACKgAFFH8wAAMIAAcIfhwRHwB0AQAIAAYIgiERHwB0AQALAAUIcQw4HgCJAAAqAAQKfygAAggACAjoItQ8ADgCAAgACAjoItQ8ADgCAAAA.',['肥舞']='肥舞之心:BAABKgAECn8WAAIRAAgIDB1dEwBIAgARAAgIDB1dEwBIAgAAAA==.',['至味']='至味清欢:BAAAKgAFFAgIBAAAAA==.',['茄子']='茄子將軍:BAAAKgAECgEIAQAAAA==.',['草莓']='草莓甜心软糖:BAAAKgAECgYIDQAAAA==.',['莉亞']='莉亞德琳:BAABKgAFFH8GAAIIAAYIdgp4FgA7AQAIAAYIdgp4FgA7AQAAAA==.',['萧肆']='萧肆月:BAAAKgADCggICAAAAA==.',['萨满']='萨满岩:BAAAKgAECgIIAgAAAA==.',['藏剑']='藏剑天涯:BAAAKgAECgMIBwAAAA==.',['虎胆']='虎胆酒:BAABKgAFFH8GAAISAAYIbQTQBQBQAQASAAYIbQTQBQBQAQAAAA==.',['要乃']='要乃没有:BAABKgAFFH8KAAQLAAYILhNuDQAkAQALAAYILhNuDQAkAQATAAMI6AuOEAB9AAAIAAEIuQH7VwA8AAAAAA==.',['见猎']='见猎起意:BAAAKgAECgYIDQAAAA==.',['輕緢']='輕緢淡冩:BAAAKgAECggIDAAAAA==.',['达一']='达一一丶:BAAAKgAECgUIBQAAAA==.',['铃木']='铃木凉美:BAAAKgADCgEIAQAAAA==.',['铅笔']='铅笔帽:BAAAKgAECgEIAQAAAA==.',['铭刻']='铭刻诺言:BAAAKgAECgYIBwAAAA==.',['银河']='银河:BAABKgAFFH8RAAIFAAcItRQaCgDSAQAFAAcItRQaCgDSAQAAAA==.',['阿萌']='阿萌:BAAAKgAFFAQIAgAAAA==.',['阿蕾']='阿蕾娜:BAAAKgAFFAQIBAAAAA==.',['雪山']='雪山之巅:BAAAKgAECgYIBgAAAA==.',['雪沫']='雪沫午盏:BAABKgAFFH8GAAIIAAYIgBluGwCHAQAIAAYIgBluGwCHAQAAAA==.',['雪糕']='雪糕糊你脸:BAACKgAFFH8zAAIOAAgIPCIyAgCrAgAOAAgIPCIyAgCrAgAqAAQKfykAAg4ACAjAJJcFAMgCAA4ACAjAJJcFAMgCAAAA.',['雷声']='雷声:BAAAKgAECgQIBAAAAA==.',['风来']='风来了:BAAAKgAECgQIBQAAAA==.',['飞卫']='飞卫:BAAAKgAFFAQIBAAAAA==.',['黑夜']='黑夜中的糊糊:BAAAKgAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end