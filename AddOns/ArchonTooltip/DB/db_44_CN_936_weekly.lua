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
 local lookup = {'Warrior-Fury','Hunter-Marksmanship','Monk-Brewmaster','Shaman-Restoration','DeathKnight-Frost','DeathKnight-Blood','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','Priest-Holy','Druid-Balance','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Unholy','Unknown-Unknown','DemonHunter-Havoc',}; local provider = {region='CN',realm='奥金顿',name='CN',type='weekly',zone=44,date='2025-12-07',data={Bl='Blackcat:BAAALAAECggIEAAAAA==.',Di='Diff:BAAALAAFFAMIAwAAAA==.',Dp='Dp:BAAALAADCgEIAQAAAA==.',Iw='Iwish:BAAALAAECgIIAgAAAA==.',Ma='Mashiro:BAABLAAFFH8EAAIBAAIIfCAWLgChAAABAAIIfCAWLgChAAAAAA==.',['Mä']='Märchen:BAABLAAFFH8MAAICAAIIbiZXEQDeAAACAAIIbiZXEQDeAAAAAA==.',Po='Poetry:BAABLAAFFH8GAAIDAAIIKB3uDwCsAAADAAIIKB3uDwCsAAAAAA==.',Ri='Rikka:BAAALAAECgEIAQAAAA==.',Se='Semage:BAABLAAFFH8GAAIEAAYIwQB8awBQAAAEAAYIwQB8awBQAAAAAA==.',So='Sorrylift:BAABLAAFFH8GAAMFAAYINQOAcgBPAAAFAAUI2gOAcgBPAAAGAAEIAAAAAAAAAAAAAA==.',Th='Thork:BAABLAAECn8UAAIFAAcIbgsidwABAQAFAAcIbgsidwABAQAAAA==.',Ya='Yarvox:BAAALAAECgMIAwAAAA==.',['九一']='九一陳先森:BAAALAAECgUIBQAAAA==.',['五月']='五月:BAABLAAFFH8dAAMEAAYIfh6BDwDsAQAEAAUIPCSBDwDsAQAHAAYIuRyUFwCCAQAAAA==.',['伊琳']='伊琳:BAAALAAECgYIBgAAAA==.',['利群']='利群:BAAALAAFFAIIAgAAAA==.',['劈里']='劈里啪啦:BAAALAAECgYICQAAAA==.',['千早']='千早爱音:BAAALAAECgYIBgAAAA==.',['半藏']='半藏森林:BAAALAAECgEIAQAAAA==.',['取名']='取名好难:BAAALAAECgIIAgAAAA==.',['吃苹']='吃苹果的维恩:BAAALAAECgIIAgAAAA==.',['呆呆']='呆呆小猎:BAAALAAFFAIIBAAAAA==.',['周靖']='周靖:BAAALAAECgYIBgAAAA==.',['噬魂']='噬魂曲:BAAALAAECgMIAwAAAA==.',['回来']='回来逛吃:BAAALAAECgMIAwAAAA==.',['圣启']='圣启示:BAAALAAECgEIAQAAAA==.',['夜舞']='夜舞:BAAALAAECgEIAQAAAA==.',['大兽']='大兽兽:BAAALAAECgEIAQAAAA==.',['太刀']='太刀侠:BAAALAAECggIBwAAAA==.',['奥丁']='奥丁王:BAABLAAECn8UAAIIAAYIuQsvGgBNAQAIAAYIuQsvGgBNAQAAAA==.',['好手']='好手段:BAAALAADCggICAAAAA==.',['宠物']='宠物世界啊:BAAALAAFFAIIAgAAAA==.',['小咕']='小咕咕:BAAALAAECgIIAwAAAA==.',['小熊']='小熊中计了:BAAALAAECgIIAgAAAA==.',['尘世']='尘世丶无华:BAABLAAFFH8mAAMJAAYIlyQ1BQAbAgAJAAYIlyQ1BQAbAgAKAAEIoQtxTgBAAAABLAAFFAcIQAALAFcmAA==.',['尘星']='尘星:BAAALAADCgcIEQAAAA==.',['张仲']='张仲景:BAAALAAECgQIBAAAAA==.',['影殁']='影殁:BAAALAAECgYIDQAAAA==.',['德得']='德得德嘚:BAAALAAECgMIAwAAAA==.',['心怀']='心怀畏惧:BAAALAADCgQIBAAAAA==.',['恶魔']='恶魔女士丶:BAAALAADCgIIAgAAAA==.',['我自']='我自丶逍遥:BAABLAAFFH8nAAIHAAUIhCVqBwAJAgAHAAUIhCVqBwAJAgABLAAFFAcIQAALAFcmAA==.',['教父']='教父:BAAALAAECgIIAwAAAA==.',['无屑']='无屑可击:BAABLAAECn8YAAIMAAYIWgytyADjAAAMAAYIWgytyADjAAAAAA==.',['无敌']='无敌大怪兽:BAAALAAECgYIBgAAAA==.',['无聊']='无聊的龙邪:BAACLAAFFH8GAAICAAII1w2/GAA3AAACAAII1w2/GAA3AAAsAAQKfyYAAgIABgj4HH8PAFQBAAIABgj4HH8PAFQBAAAA.',['春秋']='春秋惟一鉴:BAABLAAFFH8GAAIEAAIIjQgwXgBhAAAEAAIIjQgwXgBhAAAAAA==.',['暖暖']='暖暖丶:BAABLAAFFH8bAAMKAAYILRb+JQANAQAKAAMIGCD+JQANAQAJAAYIPAMyGgDeAAAAAA==.',['暖枫']='暖枫:BAAALAADCgYIBgAAAA==.',['暗隐']='暗隐:BAACLAAFFH8GAAIBAAIIgRTVNwCWAAABAAIIgRTVNwCWAAAsAAQKfxkAAgEABwgEIZg1AF8CAAEABwgEIZg1AF8CAAAA.',['木偶']='木偶娃娃的心:BAABLAAECn8XAAIFAAcIqwtBcgALAQAFAAcIqwtBcgALAQAAAA==.',['桃花']='桃花朵朵:BAABLAAFFH8QAAINAAMI1iCAOgCzAAANAAMI1iCAOgCzAAAAAA==.',['桔子']='桔子猫:BAAALAAECgYIEwAAAA==.',['梅子']='梅子猫:BAAALAAECggICAAAAA==.',['汉堡']='汉堡不在:BAABLAAFFH8IAAIHAAgIMwCbVwAFAAAHAAgIMwCbVwAFAAAAAA==.',['油猫']='油猫冰:BAAALAAECgMIAwAAAA==.油猫饼:BAAALAADCgEIAQAAAA==.',['流放']='流放:BAAALAADCgYIBgAAAA==.',['温文']='温文尔雅:BAAALAAECgIIAgAAAA==.',['游龙']='游龙:BAAALAAECgMIAwAAAA==.',['滴滴']='滴滴么么:BAAALAAECgUIBQAAAA==.',['火狐']='火狐丶:BAAALAAECgYIDAAAAA==.',['灬墨']='灬墨晓肆灬:BAAALAAECgEIAQAAAA==.',['特拉']='特拉法尓加罗:BAAALAAECgYIDAAAAA==.',['狂风']='狂风暴雨战:BAABLAAFFH8gAAIBAAYI6h8DFAC6AQABAAYI6h8DFAC6AQAAAA==.',['狐英']='狐英俊:BAACLAAFFH8OAAMFAAIIGht0cgBPAAAFAAIIGht0cgBPAAAOAAEIigy9HQBPAAAsAAQKfyEABAUABgiVHPU2AJ8BAAUABgiVHPU2AJ8BAA4AAghTDaZOAHkAAAYAAQiiCuEyAC0AAAAA.',['玉玉']='玉玉了:BAAALAADCgcICgAAAA==.',['王小']='王小滚:BAAALAAFFAIIBAAAAA==.',['疯狂']='疯狂的陈老板:BAAALAAFFAIIAgAAAA==.',['竹子']='竹子猫:BAAALAAECgYIBgAAAA==.',['老衲']='老衲也老了:BAAALAAFFAIIBAABLAAFFAMIDAAFAEYLAA==.',['自定']='自定义阿玛尼:BAAALAAFFAIIAgAAAA==.',['艾琳']='艾琳丶伽斯坦:BAAALAADCgYIBgABLAAECgIIAgAPAAAAAA==.',['芒果']='芒果猫:BAABLAAECn8jAAIQAAcIlBu6UQAuAgAQAAcIlBu6UQAuAgAAAA==.',['芝士']='芝士榴莲包:BAAALAAECgYIBgAAAA==.',['讨厌']='讨厌下雨天:BAAALAAECggIDwAAAA==.',['踏雪']='踏雪山巅:BAAALAAECgMIBQAAAA==.踏雪风行:BAACLAAFFH8OAAIFAAYIPR4BIgCuAQAFAAYIPR4BIgCuAQAsAAQKfxQAAgUABwjpEvY+AIYBAAUABwjpEvY+AIYBAAAA.',['钢铁']='钢铁憨憨:BAABLAAECn8VAAIEAAYIdRf3OgBxAQAEAAYIdRf3OgBxAQAAAA==.',['随便']='随便射一贱:BAABLAAFFH8GAAIMAAIIdRYwaACGAAAMAAIIdRYwaACGAAABLAAFFAMIDAAFAEYLAA==.',['难说']='难说再见:BAABLAAFFH8MAAIFAAMIRguiZwB8AAAFAAMIRguiZwB8AAAAAA==.',['雌雄']='雌雄双奶:BAAALAADCgEIAQAAAA==.',['饭团']='饭团子:BAAALAAECgUIBQAAAA==.',['马诺']='马诺若斯:BAAALAAECgIIAgAAAA==.',['魔法']='魔法少女小六:BAAALAAECgMIAwAAAA==.',['鹤别']='鹤别空山:BAABLAAECn8ZAAMMAAYIshhm5ABRAQAMAAYI7hdm5ABRAQACAAUIPBAodwD3AAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end