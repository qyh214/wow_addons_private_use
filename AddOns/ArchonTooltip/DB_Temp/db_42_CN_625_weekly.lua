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
 local lookup = {'Rogue-Assassination','Rogue-Subtlety','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','DeathKnight-Unholy','Shaman-Enhancement','Druid-Guardian','DemonHunter-Vengeance','Mage-Frost','Mage-Fire','Mage-Arcane','Shaman-Restoration','Druid-Restoration','Unknown-Unknown','Monk-Mistweaver',}; local provider = {region='CN',realm='塞拉赞恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ag='Agrius:BAABKgAECn8aAAMBAAgIsCCfDABRAgABAAgIEiCfDABRAgACAAYIvB4+HABAAQABKgAFFAgICAABAFwTAA==.',Ga='Gastonxudu:BAACKgAFFH8JAAQDAAMIfxPHDADPAAADAAMIfxPHDADPAAAEAAIIbQFwTgA4AAAFAAEIwQI3JwAxAAAqAAQKfycABAMACAgGFyUfAJEBAAMACAgGFyUfAJEBAAUAAwiLC0QtAIQAAAQAAgjyBkWIAD4AAAAA.',Ma='Mamba:BAAAKgAECggIDgAAAA==.',Mo='Mosaic:BAABKgAFFH8LAAIGAAcIfQttDAB2AQAGAAcIfQttDAB2AQAAAA==.',Na='Napie:BAAAKgAECggIDwAAAA==.',Oo='Oops:BAABKgAFFH8GAAIEAAYI9B7sJQDbAAAEAAYI9B7sJQDbAAAAAA==.',Su='Summers:BAAAKgAECgIIAwAAAA==.',To='Torxplus:BAAAKgAFFAgIBAAAAA==.',['一级']='一级天灾:BAAAKgAECggIDwAAAA==.',['一锤']='一锤定影:BAAAKgAECggICAAAAA==.',['三月']='三月桃花雨:BAAAKgAECgQIBAAAAA==.',['三水']='三水西木:BAAAKgAECgIIAgAAAA==.',['与子']='与子同老:BAAAKgAECgQIBAAAAA==.',['世界']='世界的尽头:BAAAKgAECgcIBwAAAA==.',['伯伦']='伯伦希尔:BAABKgAFFH8OAAIHAAgIMhOCBgABAgAHAAgIMhOCBgABAgAAAA==.',['光明']='光明使者:BAAAKgADCgEIAQAAAA==.',['冉冉']='冉冉:BAAAKgAECgMIBAAAAA==.',['冥夜']='冥夜:BAAAKgADCgcIBwAAAA==.',['冰糖']='冰糖萌萌哒:BAAAKgAECgUIBQAAAA==.',['原来']='原来不是你:BAABKgAFFH8GAAIIAAYIchz5FQCrAQAIAAYIchz5FQCrAQAAAA==.',['双鱼']='双鱼座:BAAAKgAECgEIAQAAAA==.',['呜喵']='呜喵王:BAABKgAECn8YAAIJAAgIOhj2JgDpAQAJAAgIOhj2JgDpAQAAAA==.',['团队']='团队杀手:BAABKgAFFH8GAAIKAAYI7RDhAQC1AQAKAAYI7RDhAQC1AQAAAA==.',['圣光']='圣光先锋:BAAAKgAECgUICAAAAA==.',['塞拉']='塞拉赞恩牛:BAABKgAFFH8FAAILAAMIawUUCwBiAAALAAMIawUUCwBiAAAAAA==.',['壹姐']='壹姐:BAAAKgADCgIIAgAAAA==.',['大領']='大領主:BAAAKgAECgEIAQAAAA==.',['奇塔']='奇塔塔普:BAAAKgADCgEIAQAAAA==.',['小悠']='小悠悠:BAAAKgAFFAQIBAAAAA==.',['小梦']='小梦:BAAAKgAECgYIBgAAAA==.',['小趴']='小趴菜:BAAAKgADCgYIBgAAAA==.',['小逗']='小逗逗:BAAAKgAFFAQIBAAAAA==.',['小雪']='小雪飘零:BAAAKgAECggIDQAAAA==.',['小鸟']='小鸟:BAAAKgADCgcIBwAAAA==.',['岁月']='岁月无痕丶:BAAAKgAECgYIBgAAAA==.',['崇拜']='崇拜撒旦:BAAAKgADCgMIAwAAAA==.',['幽冥']='幽冥蛟:BAAAKgADCgEIAQAAAA==.',['庇护']='庇护审判:BAAAKgAECgYIDAAAAA==.',['异邦']='异邦人:BAAAKgAECggICAAAAA==.',['恐惧']='恐惧幽灵:BAAAKgADCggICAAAAA==.',['愤怒']='愤怒的小奶狗:BAAAKgAECgMIAwAAAA==.',['我爱']='我爱黎明:BAAAKgADCggIDwAAAA==.',['折翼']='折翼的天使:BAAAKgAECggIEQAAAA==.',['指上']='指上弹冰:BAAAKgADCggICAAAAA==.',['旧人']='旧人难忆:BAAAKgAECgIIAgABKgAFFAgIEAAGAEwaAA==.',['月夜']='月夜光明:BAAAKgAECgcIBwAAAA==.',['朵拉']='朵拉:BAAAKgAECgMIAwAAAA==.',['来自']='来自星星的拖:BAAAKgAECgEIAQAAAA==.',['梦再']='梦再续殷缘:BAAAKgAECgIIAgAAAA==.',['毛毛']='毛毛月:BAAAKgAECggIDgAAAA==.',['永不']='永不厌弃:BAABKgAFFH8HAAIMAAQIUQXmDQB7AAAMAAQIUQXmDQB7AAAAAA==.',['火鸡']='火鸡味锅巴:BAAAKgAECggIDwAAAA==.',['煎饼']='煎饼摊老板:BAAAKgAFFAgIBAAAAA==.',['熊熊']='熊熊更爱猫:BAAAKgADCgEIAQAAAA==.',['爱灬']='爱灬精准猎杀:BAAAKgAECgcIBwAAAA==.',['牛半']='牛半斤:BAAAKgADCggIDQAAAA==.',['狂暴']='狂暴牛仔:BAAAKgADCgEIAQAAAA==.',['皓匀']='皓匀:BAAAKgADCgEIAQAAAA==.',['盗宝']='盗宝哥布林:BAAAKgADCggICgAAAA==.',['睡觉']='睡觉达人:BAAAKgAFFAgIAgAAAA==.',['瞄布']='瞄布准:BAAAKgAECgYIBwAAAA==.',['瞧你']='瞧你这德行:BAAAKgAECggICgAAAA==.',['破嗯']='破嗯哈博:BAAAKgADCggICAAAAA==.',['神之']='神之子俊:BAAAKgAECgcICQAAAA==.',['笨猫']='笨猫:BAAAKgAECgEIAQAAAA==.',['米姆']='米姆:BAAAKgAFFAQIBAAAAA==.',['纠结']='纠结的烟丝:BAAAKgAECggICQAAAA==.',['绝代']='绝代风华妲己:BAAAKgAECgIIAgAAAA==.',['美布']='美布列:BAAAKgADCgEIAQAAAA==.',['艾达']='艾达梅斯默:BAAAKgAFFAQIBAABKgAFFAgIDgAHADITAA==.',['艾雅']='艾雅法拉:BAACKgAFFH8GAAINAAYIjB4fBgBwAQANAAYIjB4fBgBwAQAqAAQKfxgAAw0ACAiJHKoXAPkBAA0ACAiJHKoXAPkBAA4ABgigC+YoAOsAAAAA.',['茗苓']='茗苓的宥蕥:BAAAKgAECgYIBgAAAA==.',['萌萌']='萌萌德拖拖:BAAAKgAECgcIBwAAAA==.萌萌旳拖拖:BAAAKgAECgMIBAAAAA==.萌萌的拖拖:BAAAKgAECggIEQAAAA==.',['起名']='起名字费脑子:BAAAKgAECgIIAgAAAA==.',['轩辕']='轩辕风:BAAAKgAECggICAAAAA==.',['逮虾']='逮虾户:BAAAKgAECgEIAgAAAA==.',['道法']='道法皈依:BAAAKgADCgQIBAAAAA==.',['里克']='里克休比:BAAAKgAECggIDgABKgAFFAgICAAPALoSAA==.',['镜小']='镜小小:BAABKgAFFH8UAAIQAAYIhRq3CAC8AQAQAAYIhRq3CAC8AQAAAA==.',['阿伦']='阿伦不吃龙:BAAAKgAECgUIAgAAAA==.',['陌小']='陌小忛:BAAAKgADCggICAAAAA==.',['随心']='随心而流:BAAAKgADCgQIBAAAAA==.',['霜满']='霜满天:BAABKgAECn8dAAIQAAgI5BqdJgDmAQAQAAgI5BqdJgDmAQAAAA==.',['飞奔']='飞奔的犇犇:BAAAKgADCgIIAgAAAA==.',['骑个']='骑个隆咚呛:BAAAKgAECggICQAAAA==.',['骑士']='骑士:BAAAKgAECgYIEAAAAA==.',['骑德']='骑德龙的德:BAABKgAFFH8GAAIRAAYIAxuhBwCUAQARAAYIAxuhBwCUAQABKgAFFAgIBAASAAAAAA==.骑德龙的骑:BAABKgAFFH8GAAIIAAYI9xiwDwCmAQAIAAYI9xiwDwCmAQABKgAFFAgIBAASAAAAAA==.',['魔法']='魔法使者:BAEAKgAECgQIBQABKgAFFAgIFAATAEgYAA==.',['龙魍']='龙魍:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end