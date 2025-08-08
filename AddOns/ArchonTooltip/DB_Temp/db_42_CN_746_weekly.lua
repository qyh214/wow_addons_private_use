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
 local lookup = {'Warrior-Arms','Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Protection','Monk-Mistweaver','Hunter-Marksmanship','Shaman-Restoration','Warrior-Fury','Warlock-Destruction','Monk-Windwalker','Hunter-BeastMastery','DeathKnight-Blood','DeathKnight-Unholy','Warlock-Demonology','Warlock-Affliction','DemonHunter-Havoc','Monk-Brewmaster','DeathKnight-Frost','Shaman-Elemental','Priest-Holy','Priest-Discipline',}; local provider = {region='CN',realm='烈焰荆棘',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Aries:BAABKgAFFH8GAAIBAAYI1BpXBgC2AQABAAYI1BpXBgC2AQAAAA==.',Co='Cooldog:BAACKgAFFH8RAAICAAMIqRaMEgDPAAACAAMIqRaMEgDPAAAqAAQKfxcAAwIACAj5GlcVABACAAIACAj5GlcVABACAAMAAQjOB1OjACAAAAAA.',El='El:BAAAKgAECggIDAAAAA==.Elysia:BAABKgAFFH8KAAMCAAMIfxhKFwC5AAACAAMIsQ5KFwC5AAADAAMIRxT+MQCcAAAAAA==.Elysias:BAAAKgAFFAQIBAAAAA==.',Ji='Jinly:BAAAKgAFFAEIAgAAAA==.',La='Launcelot:BAABKgAFFH8cAAMEAAcIqBDILwApAQAEAAYICxPILwApAQAFAAEItQRVFQA2AAABKgAFFAgIEgAGAJMYAA==.',Mt='Mtoer:BAAAKgAFFAYIAgAAAA==.',Ne='Neoyc:BAABKgAFFH8HAAIEAAcIfgw1GgCPAQAEAAcIfgw1GgCPAQAAAA==.',Sh='Shootstar:BAABKgAFFH8GAAIHAAYIgwtPGQAgAQAHAAYIgwtPGQAgAQAAAA==.',So='Soloboy:BAAAKgADCggICAAAAA==.',Ye='Yearn:BAABKgAFFH8IAAIDAAgIWRGyCQDUAQADAAgIWRGyCQDUAQAAAA==.',['一刹']='一刹汐暘:BAABKgAFFH8IAAIEAAgISho2BgBaAgAEAAgISho2BgBaAgAAAA==.',['一只']='一只微型香瓜:BAAAKgADCggICAAAAA==.',['一指']='一指:BAABKgAFFH8FAAIIAAMI8QXYPQCQAAAIAAMI8QXYPQCQAAAAAA==.',['不懂']='不懂:BAABKgAECn8UAAIJAAgIYCFyDQB6AgAJAAgIYCFyDQB6AgAAAA==.',['丶七']='丶七喜灬:BAAAKgAECgQIBAAAAA==.',['乐天']='乐天:BAABKgAFFH8IAAIKAAgIxgz7CwDNAQAKAAgIxgz7CwDNAQAAAA==.乐天萨:BAAAKgAECgYICgAAAA==.',['你说']='你说咋啦:BAAAKgAFFAgIAwAAAA==.',['八级']='八级狂风:BAAAKgAECgYICgAAAA==.',['公丶']='公丶生:BAABKgAFFH8FAAIEAAUIGiP/IABqAQAEAAUIGiP/IABqAQAAAA==.',['军团']='军团女明星:BAABKgAFFH8GAAIKAAYIEhLjFQBUAQAKAAYIEhLjFQBUAQAAAA==.',['包政']='包政:BAAAKgADCggICAAAAA==.',['卡夫']='卡夫其尔:BAAAKgAECgYIBgAAAA==.',['古德']='古德喵喵:BAAAKgAFFAIIAgAAAA==.',['吴钩']='吴钩霜雪明:BAABKgAFFH8KAAIHAAYI0x/iCwCYAQAHAAYI0x/iCwCYAQABKgAFFAgIHAADAPgfAA==.',['周末']='周末:BAAAKgAECgIIAgAAAA==.',['咕咕']='咕咕徳:BAAAKgAECggICwAAAA==.',['咖喱']='咖喱牛肉人:BAACKgAFFH8SAAMGAAYIkxguEgDcAAAGAAUIBxUuEgDcAAALAAEI5QMXJABDAAAqAAQKfycAAwYACAi1Hz0RAF8CAAYACAi1Hz0RAF8CAAsAAghWEbpUAG0AAAAA.',['哈尔']='哈尔酱:BAABKgAECn8WAAIMAAcIeh7lNgAaAgAMAAcIeh7lNgAaAgAAAA==.',['哟哟']='哟哟嘻:BAAAKgADCgMIAwAAAA==.',['喷火']='喷火中水龙:BAABKgAFFH8IAAIIAAQITw+QFADTAAAIAAQITw+QFADTAAAAAA==.',['天天']='天天忝蓝:BAAAKgAECggICAAAAA==.',['女皇']='女皇武则天:BAAAKgAECgEIAQAAAA==.',['孤冷']='孤冷渊:BAABKgAFFH8IAAMNAAYIigmVGADcAAANAAYIigmVGADcAAAOAAIIVAZFKgB3AAAAAA==.',['封芒']='封芒花尽落:BAAAKgAECgcIBwAAAA==.',['小宝']='小宝是坏蛋:BAAAKgAFFAIIBAAAAA==.',['小小']='小小脚丫:BAAAKgAECggICAAAAA==.',['小悠']='小悠悠:BAABKgAFFH8GAAQPAAYIXwfyGQCBAAAPAAIITQ7yGQCBAAAQAAIITAHHGgBrAAAKAAIIqQWAUgApAAAAAA==.',['少林']='少林师太:BAABKgAFFH8KAAIGAAUIdguHGADbAAAGAAUIdguHGADbAAAAAA==.',['尛魔']='尛魔女:BAABKgAECn8aAAIRAAgI8hwpGwAoAgARAAgI8hwpGwAoAgAAAA==.',['屮女']='屮女武神彡:BAAAKgAECgEIAQAAAA==.',['很有']='很有兽性:BAAAKgAFFAEIAgAAAA==.',['念十']='念十漪:BAAAKgAECgIIAgAAAA==.',['恬恬']='恬恬:BAAAKgAECgcIBwAAAA==.',['我下']='我下巴掉了:BAABKgAFFH8JAAIKAAgImxfrCQDtAQAKAAgImxfrCQDtAQAAAA==.',['插图']='插图腾烦死你:BAAAKgAECgYIBwAAAA==.',['是烈']='是烈火是枯枝:BAAAKgAFFAEIAQAAAA==.',['最后']='最后的光之子:BAAAKgAECgQIBAAAAA==.',['月曙']='月曙:BAAAKgAECgEIAQAAAA==.',['朽木']='朽木可雕:BAAAKgADCgIIAgAAAA==.',['梦厶']='梦厶吟:BAABKgAECn8eAAMCAAgIRBoVGQDsAQACAAgIRBoVGQDsAQADAAIIPRDCOQByAAAAAA==.',['楚默']='楚默:BAAAKgAFFAgIBAAAAA==.',['水如']='水如锋:BAAAKgAECgIIAgAAAA==.',['沃洛']='沃洛克:BAABKgAECn8cAAQKAAgIhSN/BgC+AgAKAAgISyN/BgC+AgAPAAEIaBv2bgBPAAAQAAEI+g5MQgA9AAAAAA==.',['浅笑']='浅笑浮白:BAABKgAECn8UAAMGAAgIHgoPOwDfAAAGAAgIHgoPOwDfAAASAAEIbgCfKwAIAAAAAA==.',['浴火']='浴火奋战:BAAAKgAECgIIAgAAAA==.',['潇洒']='潇洒死骑:BAAAKgAFFAIIAwAAAA==.潇洒的武僧:BAAAKgAECgUIBQAAAA==.',['爷青']='爷青回:BAAAKgAFFAEIAQAAAA==.',['玩的']='玩的开心:BAAAKgADCgMIAwAAAA==.',['璨璨']='璨璨:BAAAKgAFFAUIAQAAAA==.',['皇極']='皇極尔玉:BAAAKgAECggICAAAAA==.',['睡吧']='睡吧宝贝:BAAAKgADCggICAAAAA==.',['神勇']='神勇牛先锋:BAAAKgAECgYICQAAAA==.',['神鬼']='神鬼迷踪步:BAABKgAECn8fAAMCAAgIvyCpDAB0AgACAAgIvyCpDAB0AgADAAEInQvuoAAkAAAAAA==.',['移动']='移动炮台:BAABKgAECn8VAAICAAgIRR/MIwD1AQACAAgIRR/MIwD1AQAAAA==.',['紫殿']='紫殿流星:BAABKgAECn8WAAMPAAgINRaBEwDfAQAPAAgINRaBEwDfAQAKAAMI4w6vhgB9AAAAAA==.',['罪恶']='罪恶的夜晚:BAAAKgAECgUICwAAAA==.',['腿长']='腿长跑得快:BAAAKgAECgUIBQAAAA==.',['花语']='花语和薰:BAABKgAFFH8PAAITAAMIyRL1CADYAAATAAMIyRL1CADYAAAAAA==.',['蝉時']='蝉時雨:BAAAKgAECgYIBgAAAA==.',['西施']='西施惠:BAAAKgADCggICAAAAA==.',['训练']='训练中的英雄:BAAAKgAECgIIAgAAAA==.',['超级']='超级近战劣人:BAAAKgAECgcICgAAAA==.超级香瓜:BAAAKgADCgYICwAAAA==.',['邪恶']='邪恶熊鼻噶:BAABKgAECn8gAAIUAAgIFReuIADpAQAUAAgIFReuIADpAQAAAA==.',['都怪']='都怪我太执着:BAABKgAFFH8aAAIVAAMIQx18GADzAAAVAAMIQx18GADzAAAAAA==.',['酵素']='酵素:BAAAKgADCgMIAwAAAA==.',['铂爵']='铂爵瓦坎达:BAABKgAECn8nAAMEAAgIaSO3BwDCAgAEAAgIaSO3BwDCAgAFAAQI7Q75FQC4AAAAAA==.',['银翼']='银翼之狐:BAAAKgAECgUIBQAAAA==.',['阿波']='阿波尼亚:BAABKgAFFH8GAAIWAAMIShLZDACmAAAWAAMIShLZDACmAAAAAA==.',['阿郎']='阿郎丶:BAAAKgAFFAQIBAAAAA==.阿郎来了:BAAAKgAECgEIAQAAAA==.',['阿鲁']='阿鲁西法:BAAAKgAECgIIAgAAAA==.',['陈丶']='陈丶风暴烈酒:BAAAKgADCgEIAQAAAA==.',['陈怀']='陈怀安:BAAAKgAECgQIBQABKgAECggIFQACAEUfAA==.',['风涯']='风涯:BAAAKgADCgcICgAAAA==.',['龙希']='龙希尔唤魔师:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end