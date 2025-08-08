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
 local lookup = {'Druid-Restoration','Priest-Discipline','DemonHunter-Havoc','Paladin-Retribution','Paladin-Holy','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Paladin-Protection','Hunter-BeastMastery','Warlock-Affliction','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Frost','DemonHunter-Vengeance','Unknown-Unknown','Hunter-Marksmanship','Priest-Holy','Priest-Shadow','Shaman-Restoration','Shaman-Elemental','Mage-Arcane','Druid-Balance','Evoker-Devastation',}; local provider = {region='CN',realm='阿卡玛',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ai='Aiezo:BAABKgAFFH8GAAIBAAYIMAeQEwADAQABAAYIMAeQEwADAQAAAA==.',Ar='Arey:BAAAKgADCggICAABKgAFFAgIDwACAM4XAA==.',Bl='Blacklink:BAABKgAFFH8FAAIDAAUImwgLLgDDAAADAAUImwgLLgDDAAAAAA==.',Do='Dokidoki:BAAAKgAECggIAQAAAA==.',Sa='Samjun:BAAAKgAECgUIBgAAAA==.',Sh='Shadowfiend:BAABKgAFFH8XAAIEAAQIdx4sNwAOAQAEAAQIdx4sNwAOAQAAAA==.',['一斩']='一斩杀一:BAAAKgAFFAQIBAAAAA==.',['一骑']='一骑当千:BAABKgAFFH8IAAMEAAYIhhBxAwCcAQAEAAYIhhBxAwCcAQAFAAEILgPWFgA0AAAAAA==.',['七月']='七月辛:BAAAKgAECgcICgAAAA==.',['不会']='不会耍的角色:BAABKgAFFH8GAAIGAAYIWhKnFAB2AQAGAAYIWhKnFAB2AQAAAA==.',['丨个']='丨个斑马丨:BAAAKgAECgcIBwAAAA==.',['丶拉']='丶拉斐埃尔丶:BAAAKgAFFAgIAQAAAA==.',['云飞']='云飞飞丶丶:BAAAKgAECgcIBwAAAA==.',['亲爱']='亲爱的亲爱的:BAABKgAFFH8NAAIHAAYIqh4YDQB8AQAHAAYIqh4YDQB8AQAAAA==.',['伤心']='伤心女人:BAAAKgAFFAgIBAAAAA==.',['你来']='你来了:BAABKgAFFH8VAAMIAAYIEx2kAwAeAQAHAAYIehotCwCZAQAIAAQIKiGkAwAeAQAAAA==.',['加藤']='加藤之指:BAAAKgADCggICAAAAA==.',['叢雨']='叢雨:BAAAKgAECgcIEQAAAA==.',['吃我']='吃我一拳:BAAAKgAFFAQIBAAAAA==.',['囷囷']='囷囷:BAAAKgAECgYIBgAAAA==.',['圣光']='圣光幽魂:BAABKgAFFH8MAAMEAAgIPBsNDQAgAQAEAAYIWBwNDQAgAQAJAAIIdRjyHACSAAAAAA==.圣光狂想曲:BAABKgAFFH8SAAIEAAYI+yJrDQD6AQAEAAYI+yJrDQD6AQAAAA==.圣光的长颈鹿:BAAAKgAFFAIIAgAAAA==.',['圣戒']='圣戒之剑:BAAAKgAECgcIDgAAAA==.',['城市']='城市猎者:BAAAKgAFFAQIBAAAAA==.',['壮壮']='壮壮:BAAAKgAFFAEIAQAAAA==.',['夜来']='夜来吹折花:BAAAKgAECgEIAQAAAA==.',['大唐']='大唐歌妃:BAAAKgAECgIIAgAAAA==.',['夺命']='夺命小扳手:BAAAKgAECgMIBAAAAA==.',['姥奶']='姥奶牛:BAAAKgAECgYIBgAAAA==.',['娘子']='娘子:BAAAKgAECgcIDQAAAA==.',['媚灵']='媚灵狐:BAAAKgADCgEIAQAAAA==.',['孤枫']='孤枫:BAABKgAFFH8FAAIKAAMIGAkOHgCsAAAKAAMIGAkOHgCsAAAAAA==.',['小丶']='小丶小妹:BAAAKgAECgcICQAAAA==.',['小乔']='小乔丶:BAABKgAFFH8MAAMLAAYIGhm0AgB5AQALAAYIphi0AgB5AQAMAAYIignlHQAZAQAAAA==.',['小咧']='小咧咧:BAAAKgAECgYIBQAAAA==.',['小小']='小小猢狲:BAAAKgAECgIIAgAAAA==.',['小搓']='小搓澡巾:BAAAKgAECgMIAwAAAA==.',['小混']='小混大划水:BAAAKgAECgIIAgAAAA==.',['小米']='小米粒:BAAAKgAECgEIAQAAAA==.',['小芜']='小芜荽:BAABKgAFFH8GAAINAAYIzBWZDABKAQANAAYIzBWZDABKAQAAAA==.',['山林']='山林小劣人:BAAAKgADCgQIBQAAAA==.',['巨蟹']='巨蟹:BAAAKgAECgEIAQAAAA==.',['帅气']='帅气伟伟:BAAAKgAECgUIBgAAAA==.',['希尔']='希尔瓦纳斯:BAAAKgAFFAYIAgAAAA==.',['开心']='开心就好:BAAAKgAFFAIIAgAAAA==.',['影子']='影子冷鋒:BAAAKgAFFAgIAQAAAA==.',['很吊']='很吊很犀利:BAAAKgAECgUIBQAAAA==.',['惡魔']='惡魔的藝術:BAABKgAFFH8HAAIGAAcI9A+lDgCuAQAGAAcI9A+lDgCuAQAAAA==.',['懒得']='懒得拖网速:BAABKgAECn8aAAIOAAcICBEAFgBSAQAOAAcICBEAFgBSAQAAAA==.',['我兄']='我兄弟叫宇春:BAAAKgAECggICAAAAA==.',['抬头']='抬头看月又沉:BAAAKgAFFAgIBAAAAA==.',['拾染']='拾染:BAABKgAFFH8HAAICAAMIRATGEAB5AAACAAMIRATGEAB5AAAAAA==.',['挥棒']='挥棒断情丝:BAAAKgAECgQIBAAAAA==.',['星期']='星期天丶:BAAAKgAFFAUIAwAAAA==.',['月夜']='月夜黄昏:BAAAKgAFFAgIAgAAAA==.',['月轻']='月轻轻:BAACKgAFFH8VAAMDAAQIdBxPEgD2AAADAAQIdBxPEgD2AAAPAAIIQgm3IQBWAAAqAAQKfzIAAgMACAjpHz0aAGcCAAMACAjpHz0aAGcCAAEqAAUUCAgYAAMAXB0A.',['有医']='有医保的先上:BAAAKgAECgEIAQAAAA==.',['杀神']='杀神:BAAAKgAFFAIIAgAAAA==.',['枪歪']='枪歪眼瞎:BAAAKgAECgYIBgAAAA==.',['柒小']='柒小柒:BAAAKgAFFAIIAgAAAA==.',['根根']='根根贼硬:BAAAKgAECgQIBAAAAA==.',['橙多']='橙多多:BAAAKgAFFAYIBAABKgAFFAgIAQAQAAAAAA==.',['欧尔']='欧尔莉亚:BAABKgAECn8eAAIRAAgIqhsrGgAnAgARAAgIqhsrGgAnAgAAAA==.',['死神']='死神来了:BAABKgAECn8gAAMPAAgICQ9AKABAAQAPAAgICQ9AKABAAQADAAQIBQW2pQBoAAABKgAFFAYIDAADAPUiAA==.',['气盛']='气盛的牛华强:BAAAKgAECgMIAwAAAA==.',['沐雨']='沐雨清风:BAAAKgADCggICAAAAA==.',['没求']='没求的名字了:BAABKgAFFH8FAAIEAAIIVQU2SgBcAAAEAAIIVQU2SgBcAAAAAA==.',['河北']='河北要饭的:BAAAKgADCggICAAAAA==.',['淡墨']='淡墨画须弥:BAABKgAFFH8KAAMSAAQILiLTEQAjAQASAAQILiLTEQAjAQATAAEIuAFZHQAfAAAAAA==.',['淡淡']='淡淡的光明丶:BAABKgAFFH8IAAIEAAgICQuNDADZAQAEAAgICQuNDADZAQAAAA==.',['灬伱']='灬伱卟配灬:BAAAKgAFFAgIBAAAAA==.',['灬白']='灬白咖啡灬:BAAAKgADCgIIAgAAAA==.',['热月']='热月:BAAAKgAECgUIBQAAAA==.',['爹奶']='爹奶不起:BAABKgAFFH8HAAIUAAIIOhTHKwBuAAAUAAIIOhTHKwBuAAAAAA==.',['牛大']='牛大蛙:BAAAKgAECgIIAgAAAA==.',['牛小']='牛小花:BAAAKgADCggICAAAAA==.',['特级']='特级猫咪姐:BAAAKgAFFAIIAgAAAA==.',['狂风']='狂风吹我心:BAAAKgAECgMIAwAAAA==.',['狠狠']='狠狠的灌注你:BAAAKgADCggICAAAAA==.',['猫猫']='猫猫侠丶:BAABKgAECn8XAAMUAAgI/BmaIgAIAgAUAAgI/BmaIgAIAgAVAAUI3hwwPgAUAQAAAA==.',['硬汉']='硬汉:BAAAKgADCggICAAAAA==.',['祝拓']='祝拓岚:BAAAKgAECgEIAQAAAA==.',['神火']='神火将军:BAABKgAFFH8FAAIMAAMIAARdIQB3AAAMAAMIAARdIQB3AAAAAA==.',['稀有']='稀有的帅:BAABKgAFFH8HAAIWAAcICQ/QDACYAQAWAAcICQ/QDACYAQABKgAFFAgIBQAXAJgVAA==.',['紫枫']='紫枫灬坏坏:BAABKgAFFH8HAAMXAAcIkQskGABWAQAXAAYI4wwkGABWAQABAAEIAgW5NgBBAAAAAA==.',['繁花']='繁花似蕾:BAAAKgADCgMIAwAAAA==.',['繃帶']='繃帶戰士:BAAAKgAFFAgIBAAAAA==.',['纯属']='纯属渔乐:BAABKgAFFH8GAAIUAAYIUROwDgBmAQAUAAYIUROwDgBmAQAAAA==.',['纱幔']='纱幔:BAAAKgADCgEIAQAAAA==.',['绿皮']='绿皮萨:BAAAKgAECgQIBAAAAA==.',['聖棋']='聖棋士:BAAAKgAECgYIBAAAAA==.',['苍崎']='苍崎青子:BAAAKgAFFAIIAgAAAA==.',['萌萌']='萌萌呆滴:BAAAKgAECgcIAQAAAA==.',['萨骑']='萨骑马:BAABKgAECn8UAAIVAAgI8BWTIADGAQAVAAgI8BWTIADGAQAAAA==.',['蓝冰']='蓝冰:BAAAKgAFFAIIAgABKgAFFAgIFAAWADQjAA==.',['蘑菇']='蘑菇:BAAAKgAFFAMIAwAAAA==.',['蛮熊']='蛮熊之王:BAAAKgAFFAMIAwAAAA==.',['西格']='西格玛丨暮雨:BAAAKgADCggICAAAAA==.',['讽飒']='讽飒筱落叶:BAAAKgAECgUIBQAAAA==.',['诗语']='诗语:BAAAKgADCggICAAAAA==.',['话说']='话说咱是帅哥:BAAAKgAECgEIAQAAAA==.',['谋曹']='谋曹丕:BAABKgAFFH8LAAIYAAgIPhvaCgC/AQAYAAgIPhvaCgC/AQAAAA==.',['趁现']='趁现:BAABKgAFFH8FAAIEAAIIbg+QeAB4AAAEAAIIbg+QeAB4AAAAAA==.',['辞安']='辞安:BAAAKgAFFAIIAgAAAA==.',['迴憶']='迴憶:BAACKgAFFH8ZAAIKAAQIUCISHwASAQAKAAQIUCISHwASAQAqAAQKfzgAAgoACAjfIbIUAIcCAAoACAjfIbIUAIcCAAAA.',['酱油']='酱油骑士:BAAAKgAECggICAAAAA==.',['金枝']='金枝玉叶:BAAAKgAECgUIBQAAAA==.',['银月']='银月浪漫:BAACKgAFFH8sAAIEAAgIIhZfGgCOAQAEAAgIIhZfGgCOAQAqAAQKfxcAAgQABwhcIFFRAP8BAAQABwhcIFFRAP8BAAAA.',['阿巴']='阿巴阿巴:BAAAKgAECggIAgAAAA==.',['阿纳']='阿纳金:BAAAKgADCggICAAAAA==.',['阿芙']='阿芙珞蒂忒:BAABKgAFFH8OAAIMAAgITRtIAwCBAgAMAAgITRtIAwCBAgAAAA==.',['阿蒂']='阿蒂珥安娜:BAABKgAFFH8GAAIKAAYIxRCGHQDgAAAKAAYIxRCGHQDgAAAAAA==.',['青花']='青花:BAABKgAFFH8IAAINAAYIzhhBCwBdAQANAAYIzhhBCwBdAQAAAA==.',['风吹']='风吹酒醒:BAABKgAFFH8HAAIHAAQIPxz7DADXAAAHAAQIPxz7DADXAAAAAA==.',['风起']='风起月明:BAABKgAECn8cAAMNAAgI2xdMHACvAQANAAcIQBpMHACvAQAGAAQILg46HQDTAAABKgAFFAgIGwANAFweAA==.',['骑不']='骑不上马:BAAAKgADCggICAAAAA==.',['鬼丶']='鬼丶见愁:BAAAKgADCgMIAwAAAA==.',['黑化']='黑化:BAAAKgAFFAQIBAAAAA==.',['龙凤']='龙凤呈祥:BAABKgAFFH8FAAIYAAUIaSSjDQCHAQAYAAUIaSSjDQCHAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end