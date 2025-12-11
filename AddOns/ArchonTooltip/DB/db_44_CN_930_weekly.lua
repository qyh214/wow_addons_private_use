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
 local lookup = {'Shaman-Elemental','Paladin-Retribution','Shaman-Restoration','Hunter-Survival','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','DeathKnight-Frost','Rogue-Assassination','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Fury','Druid-Balance','Paladin-Protection','Paladin-Holy','Monk-Mistweaver','Monk-Windwalker','Mage-Frost',}; local provider = {region='CN',realm='双子峰',name='CN',type='weekly',zone=44,date='2025-12-07',data={An='Andy:BAAALAAECgUIBQAAAA==.',Bi='Biubiudiu:BAABLAAFFH8FAAIBAAMI/hObPwBMAAABAAMI/hObPwBMAAAAAA==.',Jj='Jjaichila:BAABLAAFFH8KAAICAAIILCI3JwC7AAACAAIILCI3JwC7AAAAAA==.',Ko='Kotori:BAABLAAECn8YAAMDAAYI2iFJQQAaAgADAAYI2iFJQQAaAgABAAYI4AfPigAjAQAAAA==.',Lu='Luoxi:BAABLAAFFH8GAAMBAAYI0BVpJQAeAQABAAUILhRpJQAeAQADAAEIjQVEfAAxAAAAAA==.Luoxierba:BAABLAAFFH8GAAMBAAYIZA1EKAAHAQABAAUI+gpEKAAHAQADAAEI+QSpfAAwAAAAAA==.Luoxierjiu:BAAALAAFFAYIAgAAAA==.Luoxierqi:BAAALAAFFAgIBAAAAA==.',Pa='Palyzxc:BAAALAAECgMIAwAAAA==.',Ro='Rorgen:BAAALAAECgYICwAAAA==.',Va='Vanithy:BAAALAAECggICQAAAA==.',Yu='Yusila:BAAALAAFFAMIAgAAAA==.',Zi='Zimomo:BAAALAAFFAIIBAAAAA==.',['一顿']='一顿乱射:BAABLAAFFH8GAAIEAAIIjxhvBABNAAAEAAIIjxhvBABNAAAAAA==.',['二鼠']='二鼠:BAABLAAFFH8JAAMFAAMIvg3xEgCeAAAFAAII3xPxEgCeAAAGAAII5wFsVQBwAAAAAA==.',['亚白']='亚白米娜:BAAALAAFFAIIAgAAAA==.',['再见']='再见春天:BAAALAAECgYIDAAAAA==.',['初茵']='初茵未来:BAAALAAECgYIBgAAAA==.',['剩蛋']='剩蛋老:BAAALAAECggICAAAAA==.',['加尔']='加尔姆什:BAAALAADCgIIAgAAAA==.',['咕涌']='咕涌者:BAABLAAFFH8IAAIHAAIIyyUxKQDRAAAHAAIIyyUxKQDRAAABLAAFFAYIGQADABkiAA==.',['哈丫']='哈丫古:BAAALAAFFAMIAwAAAA==.',['喷子']='喷子:BAAALAAECggICAAAAA==.',['嘀嗒']='嘀嗒女士:BAAALAAECgMIAwAAAA==.',['堕天']='堕天圣黑猫:BAAALAAECggICAAAAA==.',['大王']='大王来巡山:BAABLAAECn8WAAIIAAYIpA7McwAIAQAIAAYIpA7McwAIAQAAAA==.',['奶一']='奶一少:BAABLAAFFH8eAAIJAAgImRnOAABTAgAJAAgImRnOAABTAgAAAA==.',['奶三']='奶三少:BAABLAAFFH8IAAIJAAgIig2XAwAaAgAJAAgIig2XAwAaAgAAAA==.',['奶二']='奶二少:BAABLAAFFH8IAAIJAAgImxTbAgBLAgAJAAgImxTbAgBLAgAAAA==.',['奶五']='奶五少:BAABLAAFFH8VAAIJAAgI+xX8AABEAgAJAAgI+xX8AABEAgAAAA==.',['奶六']='奶六少:BAABLAAFFH8PAAIJAAYI+BL6CACKAQAJAAYI+BL6CACKAQAAAA==.',['好白']='好白:BAAALAAECgYIDAAAAA==.',['小小']='小小翅膀飞:BAAALAAFFAIIBAAAAA==.',['小趴']='小趴菜:BAAALAADCgEIAQAAAA==.',['尔乐']='尔乐先生小德:BAABLAAFFH8GAAIHAAMIGA3rGAC+AAAHAAMIGA3rGAC+AAAAAA==.',['强人']='强人锁男:BAAALAAECgQIBAAAAA==.',['得鹿']='得鹿梦鱼:BAABLAAFFH8HAAIGAAMIrwgULgDKAAAGAAMIrwgULgDKAAAAAA==.',['德克']='德克士:BAAALAAECgEIAQAAAA==.',['怼霖']='怼霖泰兰得:BAAALAAECgIIAgAAAA==.',['我是']='我是最棒的:BAAALAAECgYICAAAAA==.我是点点:BAAALAADCgMIAwAAAA==.',['昵称']='昵称加载中:BAAALAAECgMIAwAAAA==.',['暧昧']='暧昧万千少年:BAAALAAECgIIAgAAAA==.',['月影']='月影霜刃:BAAALAAECgYIDAAAAA==.',['木土']='木土:BAAALAAECgYIBgAAAA==.',['水鬼']='水鬼:BAABLAAECn8UAAICAAcIbg6KggD9AAACAAcIbg6KggD9AAAAAA==.',['浅色']='浅色夏沫:BAAALAAECgQIBAAAAA==.',['炭烧']='炭烧咖啡:BAAALAAECgUIBQAAAA==.',['爱喝']='爱喝水:BAAALAADCgIIAgAAAA==.',['牛爷']='牛爷:BAAALAAECgYIBgAAAA==.',['牛逼']='牛逼里踢:BAAALAAECgYICwAAAA==.',['独行']='独行之殇:BAABLAAFFH8GAAMKAAMI+RQKDAB/AAALAAMIxAniQgCEAAAKAAMI+RQKDAB/AAAAAA==.',['珍藏']='珍藏的回忆:BAAALAAFFAIIBAAAAA==.',['白毛']='白毛毛:BAABLAAFFH8SAAIMAAQI4CGPFwAIAQAMAAQI4CGPFwAIAQAAAA==.',['看那']='看那小胖子:BAAALAAFFAIIAgAAAA==.',['神霜']='神霜无敌:BAAALAAECgEIAQAAAA==.',['糊涂']='糊涂精:BAAALAADCgYIBgAAAA==.',['紫色']='紫色凋零:BAABLAAFFH8IAAIIAAIIvg88iwBBAAAIAAIIvg88iwBBAAAAAA==.',['荆东']='荆东:BAAALAAECgIIBAAAAA==.',['萨斯']='萨斯基:BAAALAAECgcICAAAAA==.',['蒋劲']='蒋劲夫:BAABLAAFFH8QAAINAAUIbgjnHQDeAAANAAUIbgjnHQDeAAAAAA==.',['那年']='那年花谢:BAABLAAFFH8GAAIOAAII/AjbHwAsAAAOAAII/AjbHwAsAAAAAA==.那年花開:BAABLAAFFH8KAAIKAAII4wUNGQAkAAAKAAII4wUNGQAkAAAAAA==.',['醉卧']='醉卧美人膝丶:BAAALAAECgYICgAAAA==.',['铁牛']='铁牛无敌:BAABLAAFFH8FAAMPAAIImhsMFwCmAAAPAAIImhsMFwCmAAACAAIIdBYTYABHAAAAAA==.',['雪鳶']='雪鳶:BAAALAAECgYIDAAAAA==.',['青眼']='青眼的白龙:BAAALAAECgEIAQAAAA==.',['風行']='風行無間:BAABLAAFFH8fAAMQAAUIohflDAAhAQAQAAQIkhnlDAAhAQARAAIIYhkoFABPAAAAAA==.',['风中']='风中的记忆:BAAALAAECgYIBgAAAA==.',['风格']='风格法:BAABLAAFFH8HAAISAAIIDwz8GAB1AAASAAIIDwz8GAB1AAAAAA==.',['风行']='风行无间:BAACLAAFFH8bAAIMAAUIzBjhIgBYAQAMAAUIzBjhIgBYAQAsAAQKfx8AAgwABwi8IWcUAEECAAwABwi8IWcUAEECAAAA.',['风过']='风过无恒:BAAALAAECgEIAQAAAA==.',['骑士']='骑士的荣光:BAAALAAECgYICwAAAA==.',['高质']='高质量女性:BAAALAADCgEIAQAAAA==.',['魂灵']='魂灵掌控者:BAAALAADCgUIBQAAAA==.',['黯然']='黯然红豆饭:BAAALAAECgMIAwAAAA==.',['龟亻']='龟亻山人:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end