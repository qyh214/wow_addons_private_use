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
 local lookup = {'DemonHunter-Havoc','DeathKnight-Frost','DeathKnight-Blood','Druid-Guardian','Druid-Balance','Priest-Discipline','Warrior-Protection','DemonHunter-Vengeance','Warlock-Destruction','Hunter-BeastMastery','Shaman-Restoration','Paladin-Retribution','Paladin-Holy','Druid-Restoration','Priest-Shadow','Monk-Brewmaster','Mage-Frost','Warrior-Fury','Unknown-Unknown',}; local provider = {region='CN',realm='阿努巴拉克',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ak='Akai:BAAALAADCggIDAAAAA==.',De='Deletedelete:BAAALAAECgMIAQAAAA==.',Dh='Dhing:BAABLAAFFH8FAAIBAAII+ATDawA0AAABAAII+ATDawA0AAAAAA==.',Dk='Dka:BAACLAAFFH8KAAICAAII4wtqhgBDAAACAAII4wtqhgBDAAAsAAQKfxQAAwMACAgNECsTAFABAAIABwjpDynhAG0BAAMACAijDSsTAFABAAAA.Dktt:BAAALAAECgQIBAAAAA==.',Et='Eternallove:BAABLAAFFH8UAAMEAAQIKgqeBwB7AAAEAAQIkgmeBwB7AAAFAAMIAQudKAB1AAAAAA==.',Is='Isaro:BAAALAADCggICAAAAA==.',Wi='Wingswings:BAAALAAECgMIAwAAAA==.',Zs='Zst:BAAALAADCgIIAgAAAA==.',['一剑']='一剑封喉:BAAALAAECgYIBgAAAA==.',['一头']='一头小聋人:BAAALAAECgYIBgAAAA==.',['一碗']='一碗牛肉面:BAAALAAFFAQIBAAAAA==.',['上来']='上来看看:BAAALAAECgYICgAAAA==.',['不高']='不高兴:BAAALAAFFAIIAgAAAA==.',['专属']='专属牧牧:BAABLAAFFH8LAAIGAAIIYw3ABQBfAAAGAAIIYw3ABQBfAAAAAA==.专属猎手:BAAALAAFFAIIBAAAAA==.专属骑士:BAAALAAFFAIIBAAAAA==.',['丧剑']='丧剑:BAAALAAFFAIIAgAAAA==.',['为何']='为何而战:BAABLAAFFH8VAAIHAAUIfxEnFwD9AAAHAAUIfxEnFwD9AAAAAA==.',['伊利']='伊利蛋丶怒风:BAABLAAFFH8IAAIIAAIIuwOFGwAdAAAIAAIIuwOFGwAdAAAAAA==.',['伊隐']='伊隐乱瞳:BAAALAADCgYIBgAAAA==.',['偿还']='偿还:BAAALAAFFAIIAgAAAA==.',['劣人']='劣人:BAAALAAECgYIBgAAAA==.',['十杯']='十杯不醉:BAAALAAECgUIBwAAAA==.',['命定']='命定幽影:BAACLAAFFH8MAAIJAAIIvxqFNgCkAAAJAAIIvxqFNgCkAAAsAAQKfyQAAgkABgjeIhg6AFECAAkABgjeIhg6AFECAAEsAAUUAwgHAAIAKBUA.',['哈吉']='哈吉米:BAAALAAFFAIIAgAAAA==.',['困困']='困困猫:BAAALAAECgMIAwAAAA==.',['圣光']='圣光之锤:BAAALAAECgYIBgAAAA==.',['埃辛']='埃辛诺斯战刃:BAAALAAECggIBgAAAA==.',['天际']='天际孤星:BAABLAAFFH8GAAIKAAII6RG1WgCPAAAKAAII6RG1WgCPAAAAAA==.',['安全']='安全裤:BAAALAAECgIIAgAAAA==.安全裤酷:BAAALAAECgIIAgAAAA==.',['安静']='安静很吵:BAAALAAFFAQIBAAAAA==.',['封心']='封心的吻:BAAALAAECgYIBwAAAA==.',['小甘']='小甘别:BAAALAAFFAIIAgAAAA==.',['小的']='小的死骑:BAAALAAFFAIIAgAAAA==.',['小莎']='小莎曼:BAABLAAFFH8OAAILAAII4wkqZwBVAAALAAII4wkqZwBVAAAAAA==.',['归羽']='归羽:BAAALAAECgEIAQAAAA==.',['影舞']='影舞毁伤:BAAALAAECgUIBQAAAA==.',['我叫']='我叫吕春鹏:BAAALAAECggIEAAAAA==.',['我是']='我是魔鬼:BAAALAAECgEIAQAAAA==.',['明日']='明日花:BAAALAAFFAIIAwAAAA==.',['朔一']='朔一朔:BAABLAAFFH8IAAMMAAIIwgmNXwB7AAAMAAIIwgmNXwB7AAANAAIIjQqhKQBoAAAAAA==.',['杯中']='杯中的玛絰嚟:BAAALAAECgYIBgAAAA==.',['河北']='河北菜花:BAAALAAFFAIIAgAAAA==.',['浇花']='浇花:BAABLAAECn8WAAIJAAYIlBKfSQAoAQAJAAYIlBKfSQAoAQAAAA==.',['海燕']='海燕来咯:BAAALAAECgUIBQAAAA==.',['清汣']='清汣:BAAALAAECgYIBgAAAA==.',['清玖']='清玖:BAAALAAECgcICwAAAA==.',['清风']='清风訫语:BAAALAADCgcIBwAAAA==.',['潇洒']='潇洒小哥:BAAALAAECgUICAAAAA==.潇洒龙哥:BAAALAAECgMIAwAAAA==.',['潇灑']='潇灑灬牛坏坏:BAABLAAFFH8GAAIOAAII1QToRQBYAAAOAAII1QToRQBYAAAAAA==.',['灬神']='灬神朔灬:BAAALAAFFAIIBAAAAA==.',['灭世']='灭世丨年华:BAABLAAFFH8LAAICAAYINg5/OQBbAQACAAYINg5/OQBbAQAAAA==.',['烟花']='烟花丶已凉:BAABLAAFFH8qAAIPAAYIsxJuDAB3AQAPAAYIsxJuDAB3AQAAAA==.',['爱吃']='爱吃和牛:BAAALAAECgMIBAAAAA==.爱吃牛排德:BAAALAAECgYIDAAAAA==.',['爱神']='爱神丘比特:BAAALAADCgYIBgAAAA==.',['犹大']='犹大拿:BAAALAAECgYIDgAAAA==.',['猎头']='猎头公司总裁:BAAALAAECgYIDQAAAA==.',['猎物']='猎物:BAAALAAECgYICgAAAA==.',['皇者']='皇者归来:BAAALAAECgUIBQAAAA==.',['相泽']='相泽南丶:BAAALAAECgQIBAAAAA==.',['矮子']='矮子没有钱:BAABLAAECn8UAAIKAAYIxw5Z7gBEAQAKAAYIxw5Z7gBEAQAAAA==.',['神棍']='神棍徳:BAABLAAECn8VAAMFAAYIAxa1JwA8AQAFAAYIAxa1JwA8AQAEAAEI9QvgKgAqAAAAAA==.',['稀有']='稀有术术:BAAALAAFFAIIBAAAAA==.',['童话']='童话之神:BAAALAAECgUIBQAAAA==.童话小魔女:BAAALAAECgQIBwAAAA==.',['群正']='群正的骑士:BAABLAAFFH8OAAIMAAYI5iE9DQDdAQAMAAYI5iE9DQDdAQAAAA==.',['艾欧']='艾欧尼亚:BAAALAAECgYICAAAAA==.',['裸宾']='裸宾汉:BAAALAADCgIIAgAAAA==.',['西红']='西红柿炒番茄:BAAALAAECggICAAAAA==.',['见证']='见证奇迹人生:BAABLAAFFH8GAAIMAAYIMQOnRgCDAAAMAAYIMQOnRgCDAAAAAA==.见证的奇迹:BAAALAAECgYIDQAAAA==.',['遗忘']='遗忘之风:BAAALAAECgIIAgAAAA==.',['释怀']='释怀呐段情丶:BAAALAAFFAIIAgAAAA==.',['野德']='野德:BAAALAAECgcIBwAAAA==.',['陈丶']='陈丶风暴烈酒:BAABLAAFFH8QAAIQAAYI2wkZEwAcAQAQAAYI2wkZEwAcAQAAAA==.',['限量']='限量法神:BAABLAAFFH8IAAIRAAIIyA0sGAB5AAARAAIIyA0sGAB5AAAAAA==.',['隐者']='隐者无忧:BAAALAAECgYIBgAAAA==.',['霜刃']='霜刃绝魂:BAACLAAFFH8HAAICAAMIKBWlKwDqAAACAAMIKBWlKwDqAAAsAAQKfyEAAgIABghjIXprAB8CAAIABghjIXprAB8CAAAA.',['风骚']='风骚的小燕子:BAABLAAFFH8GAAISAAIInwuqTQBHAAASAAIInwuqTQBHAAAAAA==.',['香蕉']='香蕉蜀黍:BAAALAAECgEIAQAAAA==.',['高级']='高级坦克:BAAALAAECgUIBQABLAAECgYIBgATAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end