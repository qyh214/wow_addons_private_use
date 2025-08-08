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
 local lookup = {'Paladin-Retribution','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Druid-Feral','Druid-Guardian','Shaman-Restoration','Hunter-BeastMastery','Warrior-Protection','Mage-Arcane','Mage-Frost','Mage-Fire','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Priest-Discipline','Priest-Holy','DeathKnight-Frost','DeathKnight-Unholy','Evoker-Devastation','DemonHunter-Havoc','Shaman-Enhancement','Warrior-Arms','Paladin-Holy','DeathKnight-Blood','Warrior-Fury','Unknown-Unknown',}; local provider = {region='CN',realm='黑手军团',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ci='Ciro:BAAAKgADCgUIBQAAAA==.',Fa='Famous:BAAAKgADCgEIAQAAAA==.',Ye='Yesmango:BAABKgAFFH8MAAIBAAgIUgctGAAmAQABAAgIUgctGAAmAQAAAA==.',['一丶']='一丶都没有了:BAAAKgADCgEIAQAAAA==.',['一拳']='一拳一个:BAAAKgAECgUIBQAAAA==.',['上官']='上官玉儿:BAAAKgAFFAIIAgAAAA==.',['丶胡']='丶胡小白:BAABKgAFFH8KAAICAAgIWRNnBgDtAQACAAgIWRNnBgDtAQAAAA==.',['为菈']='为菈妮我变成:BAAAKgADCgQIBAAAAA==.',['举个']='举个栗子:BAAAKgADCgEIAQAAAA==.',['二刀']='二刀流:BAAAKgAECgQIBAAAAA==.',['云笈']='云笈:BAAAKgAFFAQIAQAAAA==.',['低调']='低调的狂热:BAACKgAFFH8rAAIDAAQIPx3dKADwAAADAAQIPx3dKADwAAAqAAQKfyQABQMACAhPHoczAOwBAAMACAhPHoczAOwBAAQAAwiZAXGDADsAAAUAAQh/ByMvADMAAAYAAQidC9tBABwAAAAA.',['公海']='公海医疗船:BAABKgAFFH8IAAIHAAgITg9jBgDoAQAHAAgITg9jBgDoAQAAAA==.',['内脏']='内脏坏仂:BAAAKgAECgIIAgAAAA==.',['凛冬']='凛冬降临:BAAAKgAFFAMIAwAAAA==.',['勇敢']='勇敢贝拉:BAAAKgAFFAQIBAAAAA==.',['北國']='北國暁雨:BAABKgAFFH8XAAIIAAMIGyDZGQDrAAAIAAMIGyDZGQDrAAAAAA==.',['十年']='十年人参:BAABKgAFFH8GAAICAAYIlhjdEQBUAQACAAYIlhjdEQBUAQAAAA==.',['半岛']='半岛铁头:BAABKgAFFH8QAAIJAAMI6AMsEwBjAAAJAAMI6AMsEwBjAAAAAA==.',['双马']='双马尾暴徒:BAABKgAFFH8GAAIHAAYI+g3qEwA3AQAHAAYI+g3qEwA3AQAAAA==.',['右手']='右手丨烈焰:BAABKgAFFH8JAAMKAAgIOwpkCQDVAQAKAAgIOwpkCQDVAQALAAEIQwE1JgAbAAAAAA==.',['君无']='君无愁:BAAAKgAECgUIBwAAAA==.',['听风']='听风:BAAAKgAFFAQIBAAAAA==.',['啊祖']='啊祖:BAABKgAFFH8UAAMMAAgIGiOLAgDzAQAMAAgIGiOLAgDzAQAKAAYIQRo2EABqAQAAAA==.',['啊稻']='啊稻:BAABKgAFFH8MAAQNAAYISRyyAQCiAQANAAYIJBqyAQCiAQAOAAQI5A0AEAC8AAAPAAEI2gQIUwAmAAAAAA==.',['啊绿']='啊绿:BAABKgAFFH8MAAMQAAgIUhVUAwAvAgAQAAgIUhVUAwAvAgARAAIIPQnHHABSAAAAAA==.',['圣光']='圣光丶晨辉:BAAAKgAECgcIEAAAAA==.',['在外']='在外不宜:BAAAKgADCgQIBAAAAA==.',['大淇']='大淇:BAAAKgAECgQIBAAAAA==.',['大火']='大火球:BAAAKgAECgEIAQAAAA==.',['妮妮']='妮妮安:BAABKgAFFH8GAAIBAAYI7BNkJABZAQABAAYI7BNkJABZAQAAAA==.',['嫒孋']='嫒孋惏悦:BAABKgAFFH8xAAMSAAQIihAXCwC5AAATAAQIhw/nNQDBAAASAAQIPwoXCwC5AAAAAA==.',['宝可']='宝可梦训练师:BAABKgAFFH8KAAMCAAYIbRQNDgDiAAACAAUIlBQNDgDiAAAIAAEI0RNiWABKAAAAAA==.',['审判']='审判者丶:BAABKgAFFH8IAAIBAAgI1Rg2BwBUAgABAAgI1Rg2BwBUAgAAAA==.',['寂寞']='寂寞龙:BAABKgAFFH8HAAIUAAYIJRtmDgB6AQAUAAYIJRtmDgB6AQAAAA==.',['小橘']='小橘几:BAABKgAFFH8IAAIVAAgICA6qCQDfAQAVAAgICA6qCQDfAQAAAA==.',['尼休']='尼休:BAAAKgAECgQIBQAAAA==.',['尼格']='尼格猎手:BAABKgAFFH8LAAIWAAgIRhFkBADzAQAWAAgIRhFkBADzAQAAAA==.',['帅的']='帅的被人撵:BAAAKgADCggICQAAAA==.',['弑雪']='弑雪狂澜:BAAAKgAFFAIIAgAAAA==.',['弓弦']='弓弦胡同:BAABKgAFFH8FAAIIAAQILQnwRgCGAAAIAAQILQnwRgCGAAAAAA==.',['惊奇']='惊奇队长:BAABKgAFFH8FAAIGAAMIUAfcCgBmAAAGAAMIUAfcCgBmAAAAAA==.',['憂傷']='憂傷:BAAAKgAFFAgIBAAAAA==.',['扶秋']='扶秋微凉丶:BAAAKgADCgUIBQAAAA==.',['护夜']='护夜之瞳:BAAAKgADCggICAAAAA==.',['插棍']='插棍绽红花:BAAAKgAECgMIAwAAAA==.',['摇滚']='摇滚之神:BAAAKgAECgYIBwAAAA==.',['摩摩']='摩摩尔丶蛮鬃:BAABKgAFFH8OAAIXAAgILyIrAQC4AgAXAAgILyIrAQC4AgAAAA==.',['放一']='放一放:BAAAKgAFFAMIAwAAAA==.',['放开']='放开那小妮:BAABKgAFFH8HAAIDAAMImA2KOwC4AAADAAMImA2KOwC4AAAAAA==.',['文哥']='文哥的手:BAABKgAFFH8GAAIBAAQIyQzaOwD+AAABAAQIyQzaOwD+AAAAAA==.',['星球']='星球杯:BAAAKgAECgIIAgAAAA==.',['替罪']='替罪的羊:BAAAKgAECgMIAwAAAA==.',['月蚀']='月蚀:BAABKgAFFH8QAAIIAAMIXhA8NADBAAAIAAMIXhA8NADBAAAAAA==.',['李丶']='李丶弃儿:BAAAKgAECgMIAwAAAA==.',['果丹']='果丹皮的花海:BAAAKgAFFAMIAwAAAA==.',['树莓']='树莓饼干:BAAAKgAECgcICgAAAA==.',['海之']='海之揍阿夸:BAABKgAFFH8JAAMYAAMINxVYDQDbAAAYAAMINxVYDQDbAAABAAEI4gjQjAA5AAAAAA==.',['海岸']='海岸线:BAABKgAFFH8MAAMDAAMINAnaQwCeAAADAAMINAnaQwCeAAAEAAMI3gZXLQBmAAAAAA==.',['湮灭']='湮灭八荒:BAACKgAFFH8zAAIZAAQIuQQGLQBfAAAZAAQIuQQGLQBfAAAqAAQKfyEAAxkACAhLCnY/AMIAABkACAgZCHY/AMIAABMAAQiLFMurAD4AAAAA.',['潇潇']='潇潇雨歇:BAABKgAFFH8GAAIBAAYIHxoSHQB/AQABAAYIHxoSHQB/AQAAAA==.',['灬泪']='灬泪火祖宗灬:BAAAKgAECgEIAQAAAA==.',['牧野']='牧野:BAABKgAFFH8LAAIBAAMIHQujXQC1AAABAAMIHQujXQC1AAAAAA==.',['狂暴']='狂暴索尼克:BAAAKgAECgMIAwAAAA==.',['玉米']='玉米不带宝宝:BAABKgAFFH8FAAIIAAQIfRbXFgD0AAAIAAQIfRbXFgD0AAAAAA==.',['玖玖']='玖玖小小:BAAAKgADCgMIAwAAAA==.',['白淺']='白淺:BAAAKgAFFAIIAgAAAA==.',['神奇']='神奇的阿修罗:BAAAKgADCgMIAwAAAA==.',['神棍']='神棍德:BAAAKgADCgcIBwAAAA==.',['科学']='科学养鸡:BAAAKgAECgEIAgAAAA==.',['穿心']='穿心莲:BAAAKgAECgQIBAAAAA==.',['糖豆']='糖豆吖:BAAAKgAECgQIBAAAAA==.',['素人']='素人渔夫:BAAAKgADCgIIAgAAAA==.',['红蜘']='红蜘蛛:BAAAKgAECggICgAAAA==.',['老登']='老登丶刷幻化:BAAAKgADCgEIAQAAAA==.',['老白']='老白干二号:BAAAKgAECgMIAwAAAA==.',['艺灬']='艺灬夫:BAACKgAFFH8vAAIHAAQIgRvsJwDWAAAHAAQIgRvsJwDWAAAqAAQKfxYAAgcACAgvGNE8AJIBAAcACAgvGNE8AJIBAAAA.',['芒果']='芒果呀:BAABKgAFFH8FAAIRAAUIRxmgCgB4AQARAAUIRxmgCgB4AQAAAA==.',['苍狼']='苍狼单于:BAABKgAECn8WAAMaAAgITQR2XQCTAAAaAAgIbwN2XQCTAAAJAAYIOQQ5QwBNAAAAAA==.',['荣耀']='荣耀法爷:BAAAKgAECgUIBwAAAA==.',['萌猫']='萌猫团:BAAAKgAECgQIBAAAAA==.',['萨个']='萨个满:BAAAKgAECgcIEgAAAA==.',['讨厌']='讨厌红楼梦:BAABKgAFFH8KAAIVAAYIZRTyEgBjAQAVAAYIZRTyEgBjAQAAAA==.',['许大']='许大豆儿:BAABKgAFFH8IAAIDAAgIERSxBwAlAgADAAgIERSxBwAlAgAAAA==.',['谁家']='谁家呐小谁:BAABKgAECn8dAAILAAgIaiBaCgCQAgALAAgIaiBaCgCQAgAAAA==.',['赫天']='赫天晨:BAABKgAFFH8YAAMEAAMIGQ/JFACNAAAEAAMIGQ/JFACNAAAGAAMIdw5bCACHAAAAAA==.',['跑的']='跑的嗷嗷快:BAAAKgAFFAQIBAABKgAFFAgIBAAbAAAAAA==.',['逆风']='逆风:BAAAKgADCgcIBwAAAA==.',['逍遥']='逍遥亡命徒:BAAAKgAECgcICwAAAA==.逍遥圣光:BAAAKgAECgcIEwAAAA==.',['金角']='金角痞子:BAAAKgAECggICAAAAA==.',['阿咪']='阿咪:BAABKgAFFH8RAAILAAMIJxF1CwDJAAALAAMIJxF1CwDJAAAAAA==.',['阿寶']='阿寶:BAABKgAFFH8PAAIHAAMI/gwlJwCCAAAHAAMI/gwlJwCCAAAAAA==.',['阿玛']='阿玛忒拉斯:BAABKgAFFH8GAAMCAAMI5wE4JgBFAAACAAMI5wE4JgBFAAAIAAEIAAAAAAAAAAAAAA==.',['零落']='零落天涯:BAAAKgAECgMIAwAAAA==.',['饕鬄']='饕鬄蛮牛:BAAAKgADCgUIBQAAAA==.',['香沙']='香沙芋:BAABKgAFFH8IAAIRAAgIXg35BwCpAQARAAgIXg35BwCpAQAAAA==.',['高手']='高手:BAAAKgAECgEIAgAAAA==.',['龙丨']='龙丨飞:BAAAKgADCggICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end