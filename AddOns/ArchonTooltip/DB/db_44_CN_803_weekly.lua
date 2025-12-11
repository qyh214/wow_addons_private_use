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
 local lookup = {'Mage-Arcane','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Unknown-Unknown','Warrior-Protection','Evoker-Devastation','Paladin-Retribution','Shaman-Restoration','Rogue-Outlaw','Hunter-BeastMastery','Shaman-Elemental','Warrior-Fury','Monk-Brewmaster','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Priest-Holy','Druid-Balance','Evoker-Augmentation','Evoker-Preservation','Warlock-Demonology','DeathKnight-Frost','DeathKnight-Unholy','Priest-Shadow','DemonHunter-Havoc','Monk-Windwalker','Druid-Guardian','DemonHunter-Vengeance','Warrior-Arms','Hunter-Survival','Priest-Discipline','Paladin-Protection','Mage-Frost','Monk-Mistweaver','Druid-Feral','DeathKnight-Blood',}; local provider = {region='CN',realm='艾萨拉',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aaffh:BAAALAAECgEIAQAAAA==.',Ad='Adaz:BAAALAAFFAEIAQAAAA==.',Ap='Apocalpse:BAAALAAECgYIDAAAAA==.',Be='Becky:BAAALAAECgUIBwAAAA==.',Co='Corazon:BAABLAAFFH8FAAIBAAIIlRUDQACfAAABAAIIlRUDQACfAAAAAA==.',Cr='Crystal:BAAALAAECgMIAwAAAA==.',Da='Dark:BAABLAAFFH8PAAMCAAMIAwxIFgCAAAADAAII3gd0FgCHAAACAAIIgBBIFgCAAAAAAA==.',De='Der:BAAALAADCgIIAgAAAA==.',Dk='Dk:BAAALAAECgYIBgAAAA==.',Dp='Dps:BAAALAAECgYIBgAAAA==.',Ev='Evilwhisper:BAAALAAECgEIAQAAAA==.',Ew='Ewen:BAAALAAECgYIDAAAAA==.',Ex='Explosive:BAAALAADCgYIBgAAAA==.',Fa='Fabulous:BAAALAAFFAIIBAAAAA==.Fangjii:BAAALAAECgIIAQAAAA==.',Fe='Fenrir:BAAALAAECgQIBAAAAA==.',Fi='Fishbean:BAAALAAFFAIIAgAAAA==.',Fr='Franky:BAAALAAECgYIDgAAAA==.',Gr='Grannie:BAAALAAFFAIIBAAAAA==.',Ha='Halolich:BAAALAAECgYIBAAAAA==.',Ir='Irad:BAAALAAECgYIDwAAAA==.',Ja='Janetjohnson:BAABLAAFFH8IAAIEAAMI3gsONgCRAAAEAAMI3gsONgCRAAAAAA==.',Je='Jelly:BAAALAAECgYICgAAAA==.',Jo='Joyboy:BAAALAAECgMIAwAAAA==.',Ky='Kyss:BAAALAADCggICAAAAA==.',Li='Lies:BAAALAADCgcIBwABLAAECgUIBQAFAAAAAA==.Lifengzs:BAABLAAFFH8KAAIGAAYIKRzVCwCEAQAGAAYIKRzVCwCEAQAAAA==.Lisccenylin:BAAALAAFFAIIAwAAAA==.',Ll='Llchklng:BAAALAAFFAIIAgAAAA==.',Lu='Luckyrabbit:BAAALAAFFAIIAgAAAA==.',Ly='Lyur:BAAALAAECgYIBwAAAA==.',Ma='Managarmr:BAAALAAFFAIIAgAAAA==.',Me='Merigold:BAAALAADCgYIBwAAAA==.',Mi='Mikosnow:BAAALAAECgQIBAAAAA==.',My='Mylsgarrett:BAAALAAECggICAAAAA==.',Nb='Nb:BAAALAAECgYIBgAAAA==.',Np='Npiaye:BAAALAAECgIIAQAAAA==.',Or='Ori:BAAALAAECggICAABLAAFFAgIQAAHAGEdAA==.Orzwarlock:BAAALAADCgEIAQAAAA==.',Ot='Otherpaladin:BAABLAAECn8dAAIIAAYISSLWKgDoAQAIAAYISSLWKgDoAQAAAA==.',Ov='Overseer:BAAALAAECggICAAAAA==.',Pl='Playerekespa:BAAALAAECgYIBgAAAA==.',Re='Reopenlolz:BAAALAAECggIBwAAAA==.Rexxooxx:BAAALAAFFAIIAgAAAA==.',Sa='Salieri:BAAALAAFFAIIAQAAAA==.Sarah:BAAALAAECgYICQAAAA==.',Sc='Schicksal:BAAALAADCgUIEAAAAA==.',Sh='Shadowpriest:BAAALAAECgYIBgAAAA==.',Ss='Sseu:BAAALAAFFAIIAgAAAA==.',Wi='Wife:BAAALAADCgUIBQAAAA==.',Xe='Xexanoth:BAAALAAFFAIIBAAAAA==.',Yo='Yontinued:BAAALAAFFAIIAgAAAA==.',['一切']='一切为了部落:BAAALAAECgYIBgAAAA==.',['一喜']='一喜洋洋一:BAAALAAECggIEwAAAA==.',['一帘']='一帘风月闲:BAAALAAFFAQIAgABLAAFFAgIEAAJANseAA==.',['一步']='一步捣胃:BAABLAAFFH8dAAQDAAYIHBpIBgC/AQADAAYIxhZIBgC/AQAKAAII0Q9WBQBEAAACAAIIZQ+nFQBBAAAAAA==.',['一老']='一老猫一:BAABLAAFFH8MAAILAAQIuxPjXADRAAALAAQIuxPjXADRAAABLAAFFAYIEQAGAIMOAA==.',['三鞭']='三鞭丸:BAAALAAFFAIIAgAAAA==.',['不惑']='不惑者:BAAALAAECggICAAAAA==.',['不点']='不点小可爱丶:BAABLAAFFH8MAAMMAAYIcwyXKgDrAAAMAAQIBAuXKgDrAAAJAAMIphVgQAClAAAAAA==.',['不管']='不管就冲:BAABLAAFFH8OAAINAAYIHhahFwCiAQANAAYIHhahFwCiAQAAAA==.',['专专']='专专:BAAALAAECgMIAwAAAA==.',['专业']='专业维修小牛:BAAALAADCgUIBQAAAA==.',['丨晓']='丨晓柒丨:BAAALAAECgYIBwAAAA==.',['丨曉']='丨曉丶銧丿:BAAALAAECgQIBAAAAA==.',['丨瘟']='丨瘟丨疫丨:BAAALAAFFAIIAgAAAA==.',['中中']='中中:BAAALAAECgcIBwAAAA==.',['中仲']='中仲:BAAALAAECgMIAwAAAA==.',['临时']='临时公:BAAALAAECgUIBQAAAA==.',['丶夕']='丶夕芮丶:BAAALAAFFAEIAQAAAA==.',['丶死']='丶死神永生:BAAALAADCgcIBwAAAA==.',['丸丸']='丸丸:BAAALAAECgIIAQAAAA==.',['丸辣']='丸辣:BAAALAAECgQIBAAAAA==.',['久还']='久还:BAAALAAECgEIAQAAAA==.',['乌瑟']='乌瑟尔骑士:BAAALAAFFAIIAgABLAAFFAgIDAADAMkfAA==.',['乌索']='乌索普:BAAALAADCgEIAQAAAA==.',['乖小']='乖小孩儿:BAAALAAECggICAABLAAFFAgIEgALAM0MAA==.',['云中']='云中影:BAAALAAECgIIAgAAAA==.云中魔:BAAALAAECgYIBQAAAA==.',['云南']='云南:BAABLAAECn8UAAIOAAYInw3sFgDhAAAOAAYInw3sFgDhAAAAAA==.',['云焕']='云焕很好:BAAALAAFFAIIBAAAAA==.云焕荣耀:BAABLAAFFH8IAAIIAAIIVBKYYABGAAAIAAIIVBKYYABGAAAAAA==.',['云起']='云起小寒:BAAALAAFFAYIAgAAAA==.',['亮仔']='亮仔亮仔:BAAALAAFFAIIAgAAAA==.亮仔别假死:BAAALAAFFAIIAgAAAA==.亮仔巭孬:BAAALAADCgcIBwAAAA==.亮仔无敌:BAABLAAFFH8KAAMPAAUIlRNtHgCvAAAPAAMIZQ5tHgCvAAAIAAMIlw3AQwCJAAAAAA==.',['亮坤']='亮坤:BAAALAAFFAIIBAAAAA==.',['今夕']='今夕何夕:BAAALAAFFAIIAgAAAA==.',['仍思']='仍思故乡月:BAAALAAECgQIBAAAAA==.',['伊扎']='伊扎克斯:BAACLAAFFH8cAAMQAAYIQhreGwBbAQAQAAYInRjeGwBbAQARAAEIZRR/BwBVAAAsAAQKfxkAAxAABgjII7VDACsCABAABggsH7VDACsCABEABQhdG4kHAC0BAAAA.',['伊瑞']='伊瑞叁:BAAALAAFFAIIAQAAAA==.伊瑞龙:BAAALAAECgYIBgAAAA==.',['传奇']='传奇:BAAALAAECgYIBgAAAA==.',['低调']='低调的乐章:BAABLAAFFH8dAAISAAUIKRBlIQA7AQASAAUIKRBlIQA7AQAAAA==.',['你的']='你的小爷们:BAAALAAFFAEIAQABLAAFFAgIBwANAEIWAA==.',['侃侃']='侃侃:BAAALAAFFAIIAgAAAA==.',['依稀']='依稀:BAACLAAFFH8IAAIPAAIISg/hHwCIAAAPAAIISg/hHwCIAAAsAAQKfxcAAg8ABggJE6c+AGQBAA8ABggJE6c+AGQBAAAA.',['倚风']='倚风飘零:BAAALAAECggICAAAAA==.',['健康']='健康幸福快楽:BAABLAAFFH8GAAILAAYI5hroBQAhAgALAAYI5hroBQAhAgAAAA==.',['健美']='健美教练:BAAALAAECgUIBQAAAA==.',['偷闲']='偷闲的翅膀:BAABLAAFFH8HAAITAAIIMxQBMABCAAATAAIIMxQBMABCAAAAAA==.',['光伏']='光伏支架大亨:BAAALAAECgIIAgAAAA==.',['光头']='光头强:BAAALAAECgUIBQAAAA==.',['克莱']='克莱茵:BAAALAAECgYIBgAAAA==.',['兔兔']='兔兔吃蘑菇:BAAALAAECgYIEQAAAA==.',['兵地']='兵地铠:BAAALAAECgUIBQAAAA==.',['兽血']='兽血沸腾:BAAALAAFFAIIAwAAAA==.',['冉冉']='冉冉:BAABLAAFFH8IAAIBAAIIAgreVQBFAAABAAIIAgreVQBFAAAAAA==.',['再小']='再小才:BAAALAAECgUIBgAAAA==.',['冥王']='冥王丶雷利:BAAALAAECgYICAAAAA==.',['冬瓜']='冬瓜棒棒糖:BAAALAAFFAIIAwAAAA==.',['冬至']='冬至飘飘:BAAALAAECgQIBgAAAA==.',['冰封']='冰封之刃:BAAALAAECgYIBQAAAA==.',['冰心']='冰心依旧:BAAALAAFFAIIAgAAAA==.',['冰镇']='冰镇的芒果:BAAALAAECgYIDAAAAA==.',['冰餜']='冰餜:BAABLAAFFH8PAAINAAUIqh0RIQBkAQANAAUIqh0RIQBkAQAAAA==.',['冷夜']='冷夜寒雪:BAABLAAFFH8GAAIQAAII2QbYbQAyAAAQAAII2QbYbQAyAAAAAA==.冷夜寒风:BAABLAAFFH8GAAILAAIIJBN6WgCPAAALAAIIJBN6WgCPAAAAAA==.',['凌乱']='凌乱无序:BAAALAADCgcIBwAAAA==.',['凌宇']='凌宇轩:BAAALAAFFAEIAQAAAA==.',['凌空']='凌空丶雨:BAAALAAECgEIAQAAAA==.',['凛雁']='凛雁小轩:BAABLAAFFH8MAAMUAAYIahM5BgBXAQAUAAYIahM5BgBXAQAVAAEI1wpBIAA8AAAAAA==.',['凝雪']='凝雪琉瞳:BAABLAAFFH8GAAMWAAYIUAGFDACvAAAWAAMIDQGFDACvAAAQAAMIkwGUVAB0AAAAAA==.',['刺青']='刺青丶翎:BAAALAADCgUIBQAAAA==.',['剑九']='剑九六千里:BAAALAAFFAIIAgAAAA==.',['加多']='加多寳:BAABLAAFFH8JAAMMAAYIpAluUQAxAAAMAAMIJgFuUQAxAAAJAAYISQAOgAAjAAAAAA==.',['医见']='医见倾情:BAAALAAECggIEAAAAA==.',['十月']='十月:BAAALAADCgEIAQAAAA==.',['千万']='千万伏特:BAAALAAECgQIBQAAAA==.',['千机']='千机蝶:BAACLAAFFH8PAAIIAAUIjRLTKgAqAQAIAAUIjRLTKgAqAQAsAAQKfyYAAggACAjoFU0xAM0BAAgACAjoFU0xAM0BAAAA.',['千鳥']='千鳥:BAAALAAFFAIIAgAAAA==.',['南山']='南山忆:BAABLAAFFH8IAAIMAAgIAhoNBgBlAgAMAAgIAhoNBgBlAgAAAA==.',['卡尔']='卡尔丶血蹄:BAABLAAFFH8HAAIGAAMIyQsdIwBiAAAGAAMIyQsdIwBiAAAAAA==.',['卡琳']='卡琳娜的忧伤:BAAALAAECgQIBAAAAA==.',['又圆']='又圆又美:BAAALAADCgQIBAAAAA==.',['双刀']='双刀核桃:BAAALAAECgMIAwAAAA==.',['发射']='发射核桃:BAAALAAECgIIAgAAAA==.',['叫嘛']='叫嘛:BAAALAAECgUIBQAAAA==.',['叶落']='叶落丷羽:BAAALAAECgYIBgAAAA==.',['叹息']='叹息的笙箫:BAABLAAFFH8UAAMJAAMIJQZ5NgCUAAAJAAMIJQZ5NgCUAAAMAAMIPgIGOQBsAAAAAA==.',['吉吉']='吉吉:BAAALAAECggICAABLAAFFAYIDwAXAEEbAA==.',['吉薇']='吉薇艾尔:BAAALAAECggICAAAAA==.',['后勤']='后勤主管:BAABLAAFFH8TAAMXAAUIFxyYPwA8AQAXAAUIFxyYPwA8AQAYAAEIkBxBGwBWAAABLAAFFAgICAAPAGQaAA==.',['吓到']='吓到吃蕉蕉:BAABLAAECn8YAAIZAAYIFBfaHABfAQAZAAYIFBfaHABfAQAAAA==.',['吳彦']='吳彦祖:BAABLAAFFH8JAAIaAAIIQxZ4PACcAAAaAAIIQxZ4PACcAAAAAA==.',['吻如']='吻如双下雪:BAACLAAFFH8IAAISAAIISQrXPAB8AAASAAIISQrXPAB8AAAsAAQKfxUAAhIABwi0GaImAIABABIABwi0GaImAIABAAAA.',['哈宝']='哈宝:BAABLAAFFH8IAAILAAYIfRSYMwBtAQALAAYIfRSYMwBtAQAAAA==.',['哥布']='哥布萨:BAAALAAECgUICQAAAA==.',['唐家']='唐家三藏:BAABLAAFFH8KAAIGAAIIIw0EMAAzAAAGAAIIIw0EMAAzAAAAAA==.',['喔次']='喔次奥:BAAALAAECgEIAQAAAA==.',['喵喵']='喵喵星座:BAAALAAECgUIBwAAAA==.',['嗷嗷']='嗷嗷就是炫:BAAALAAFFAIIAwAAAA==.嗷嗷流氓一代:BAACLAAFFH8NAAIOAAUIoQWhFgDCAAAOAAUIoQWhFgDCAAAsAAQKfxQAAw4ACAgOCV8TABEBAA4ACAgOCV8TABEBABsABQhsAk5dAHYAAAEsAAUUBggRAAYAgw4A.嗷嗷流氓九号:BAABLAAFFH8HAAIDAAMIFA8GFQCZAAADAAMIFA8GFQCZAAABLAAFFAYIEQAGAIMOAA==.',['嘎嘎']='嘎嘎以嘎斯:BAAALAAECgIIAgAAAA==.',['四季']='四季红:BAAALAAECgYIBgAAAA==.',['图腾']='图腾收一下:BAAALAADCgUIBQAAAA==.',['圣丨']='圣丨:BAAALAAECgcIBwAAAA==.',['地浊']='地浊:BAAALAAECgYIBgAAAA==.',['地灵']='地灵:BAAALAAFFAIIBAAAAA==.',['地球']='地球旅行者:BAAALAADCgIIAgAAAA==.',['地痞']='地痞暧姒:BAAALAADCgEIAQAAAA==.',['墨丨']='墨丨尘:BAAALAAFFAQIBAAAAA==.',['墨提']='墨提斯:BAAALAADCgYIBgAAAA==.',['夏不']='夏不寒:BAABLAAFFH8GAAISAAYIJSINAgBfAgASAAYIJSINAgBfAgAAAA==.',['多娇']='多娇:BAABLAAFFH8QAAILAAYIax1dJgCZAQALAAYIax1dJgCZAQAAAA==.',['夜之']='夜之絮语:BAACLAAFFH82AAMZAAYIvhc1DQCIAQAZAAYIvhc1DQCIAQASAAUIvArQEgAaAQAsAAQKfy4AAxIACAjeGVsnAE0CABIACAjeGVsnAE0CABkABgiBH8cqACoCAAAA.',['夜月']='夜月虚空:BAAALAAECgYIEgAAAA==.夜月飘逸:BAAALAAECgYICAAAAA==.',['夜杀']='夜杀加血:BAAALAAFFAIIAgAAAA==.',['夜来']='夜来幽梦还乡:BAAALAAECggICAAAAA==.',['夜牧']='夜牧:BAAALAADCgEIAQAAAA==.',['大威']='大威天龙:BAAALAAFFAIIBAAAAA==.',['大湖']='大湖北:BAACLAAFFH8GAAIJAAIIiwzYXwBcAAAJAAIIiwzYXwBcAAAsAAQKfyAAAgkACAj8FTUiAO0BAAkACAj8FTUiAO0BAAAA.',['大自']='大自然的拥抱:BAAALAAECgYIDQAAAA==.',['大象']='大象来了:BAABLAAFFH8GAAIOAAIIJQoMIQAxAAAOAAIIJQoMIQAxAAAAAA==.',['天使']='天使也掉毛:BAAALAAECgYIEgAAAA==.天使大姐:BAAALAAECgYIBgAAAA==.天使无暇:BAAALAADCgIIAgAAAA==.',['天才']='天才小黑:BAAALAAFFAMIAwAAAA==.',['天灾']='天灾小轩:BAABLAAFFH8GAAIIAAYIDRWMHAB7AQAIAAYIDRWMHAB7AQAAAA==.',['太胖']='太胖卡邪能:BAABLAAFFH8FAAIaAAII7Ri6LACxAAAaAAII7Ri6LACxAAAAAA==.',['夺命']='夺命者:BAAALAAECgYICAAAAA==.',['夺魂']='夺魂二世:BAAALAADCggICAAAAA==.',['奈落']='奈落之夜消:BAAALAAECgYIBgAAAA==.',['奶牛']='奶牛没奶:BAAALAAECgYIBgAAAA==.',['妖之']='妖之桃桃:BAAALAAFFAIIAgAAAA==.',['妖怪']='妖怪般杀戮:BAAALAAFFAIIBAAAAA==.',['娜鲁']='娜鲁:BAAALAAECgYIEgAAAA==.',['嫂子']='嫂子哥在家吗:BAAALAAECgIIAgAAAA==.',['孜然']='孜然游侠:BAABLAAECn8UAAIcAAYIWw5fFwDSAAAcAAYIWw5fFwDSAAAAAA==.',['孤单']='孤单的影子:BAAALAAECgIIAQAAAA==.',['宇智']='宇智波婷婷:BAAALAAFFAIIAgAAAA==.',['守岸']='守岸:BAAALAAFFAIIAgAAAA==.',['安娜']='安娜罗曼诺娃:BAACLAAFFH8LAAMMAAIIJAi8MgCEAAAMAAIIJAi8MgCEAAAJAAIITw+3SQByAAAsAAQKf0MAAwkACAjrHPgWADoCAAkACAjrHPgWADoCAAwABgg6GQ9QAMoBAAAA.',['安赛']='安赛斯塔:BAAALAAECgUIBQABLAAFFAYIHAAQAEIaAA==.',['宫乄']='宫乄琉璃:BAABLAAFFH8FAAIQAAUINwDJdQAGAAAQAAUINwDJdQAGAAAAAA==.',['宵泶']='宵泶涝湿:BAAALAAECgcIBwAAAA==.',['家勇']='家勇哥归来:BAAALAADCgYIFAAAAA==.',['家有']='家有胖妞:BAAALAAECgEIAQAAAA==.',['宿傩']='宿傩:BAAALAAECgYIBgAAAA==.',['寻找']='寻找伊利丷丹:BAAALAAECgQIBAAAAA==.',['小丑']='小丑鱼:BAAALAAECgUIBQAAAA==.',['小光']='小光头找媳妇:BAAALAAECggIAwAAAA==.',['小包']='小包包:BAABLAAFFH8GAAILAAIItwncqgA6AAALAAIItwncqgA6AAAAAA==.',['小哈']='小哈比:BAABLAAFFH8VAAINAAYIKBvaEwC7AQANAAYIKBvaEwC7AQAAAA==.',['小小']='小小叮铛:BAAALAAECgYIBgAAAA==.小小清秋:BAAALAAECgMIAwAAAA==.小小若水:BAAALAAECgEIAQAAAA==.',['小星']='小星闪闪:BAACLAAFFH8QAAMdAAYIrB8IAwClAQAdAAYIrB8IAwClAQAaAAMINhkjOwCfAAAsAAQKfxsAAh0ABwibJRAKAL8CAB0ABwibJRAKAL8CAAAA.',['小月']='小月落:BAABLAAFFH8IAAIZAAIIPiB5GQClAAAZAAIIPiB5GQClAAAAAA==.',['小熊']='小熊焰焰:BAAALAAFFAMIAwAAAA==.',['小狐']='小狐王:BAAALAADCggICAABLAAFFAIIAwAFAAAAAA==.',['小白']='小白妞:BAAALAAECgMIAwAAAA==.',['小蚂']='小蚂蚁:BAAALAADCgcIBwAAAA==.',['尐蹄']='尐蹄子:BAAALAAECgYICgAAAA==.',['巅峰']='巅峰灬死神:BAAALAADCgMIAwAAAA==.',['川渝']='川渝暴龙:BAABLAAECn8fAAILAAgIUxqIJgAeAgALAAgIUxqIJgAeAgAAAA==.',['常胜']='常胜将军:BAAALAAECgIIAgAAAA==.',['平静']='平静如水:BAAALAAECgYICwAAAA==.',['年华']='年华:BAAALAAECgYIBgAAAA==.',['并非']='并非小甲:BAACLAAFFH8qAAIaAAYIfSFBEgDPAQAaAAYIfSFBEgDPAQAsAAQKfxUAAhoACAhZIZUgAOIBABoACAhZIZUgAOIBAAAA.',['幻狱']='幻狱行者:BAAALAAECgcIBwAAAA==.',['库赞']='库赞大元帅:BAAALAAECgYIBgAAAA==.',['建行']='建行董事长:BAAALAAECgMIBQAAAA==.',['强力']='强力三鞭丸:BAABLAAFFH8TAAILAAUIbAq7WADoAAALAAUIbAq7WADoAAAAAA==.',['彡清']='彡清风思明月:BAAALAAECgYIBgAAAA==.彡清风惹尘埃:BAAALAAECgEIAQAAAA==.',['影风']='影风丶轻月:BAABLAAFFH8OAAILAAUIQxaISAApAQALAAUIQxaISAApAQAAAA==.',['御界']='御界天:BAAALAADCggIDwAAAA==.',['德芙']='德芙:BAAALAAECgUIBQAAAA==.',['德菜']='德菜兼备:BAABLAAFFH8SAAIEAAMIvB2SJAD2AAAEAAMIvB2SJAD2AAAAAA==.',['心臟']='心臟:BAACLAAFFH8pAAIXAAYIRiYyBQBRAgAXAAYIRiYyBQBRAgAsAAQKfyAAAhcABwiHJfswAK8CABcABwiHJfswAK8CAAAA.',['愤怒']='愤怒的香肠:BAAALAAECgYICQAAAA==.',['懒猫']='懒猫猫:BAAALAAECggIEAAAAA==.',['我真']='我真没招了:BAABLAAFFH8GAAIJAAYIQguiKAAfAQAJAAYIQguiKAAfAQABLAAFFAgIDQAJAGwSAA==.',['战复']='战复二队武僧:BAABLAAFFH8GAAIRAAYI+w6JAADmAQARAAYI+w6JAADmAQAAAA==.战复六队火法:BAABLAAFFH8yAAMZAAYIICOHBQASAgAZAAYIICOHBQASAgASAAQIESCFHgBXAQABLAAFFAYIOAALAEkiAA==.战复四队萨满:BAACLAAFFH84AAILAAYISSKpBgAWAgALAAYISSKpBgAWAgAsAAQKfzUAAgsACAgmJh4KAM4CAAsACAgmJh4KAM4CAAAA.',['战灬']='战灬歌:BAACLAAFFH8mAAIXAAYIZx7xGQDQAQAXAAYIZx7xGQDQAQAsAAQKfxcAAxgACAhED+AfALsBABgACAgVDuAfALsBABcABghmCzgIATkBAAAA.',['戮灵']='戮灵小轩:BAAALAADCgQIBAAAAA==.',['把酒']='把酒临风醉月:BAAALAAFFAIIAwAAAA==.',['抠脚']='抠脚大德:BAAALAAECgYICQAAAA==.抠脚大骑士:BAAALAAECgMIAwAAAA==.抠脚彪汉:BAAALAAECgQIBAAAAA==.抠脚老娘们:BAAALAAECgYICQAAAA==.',['招牌']='招牌虾饺:BAACLAAFFH8IAAIQAAII+hM+TACHAAAQAAII+hM+TACHAAAsAAQKfxoAAhAACAhwGqgrAJICABAACAhwGqgrAJICAAAA.',['拦截']='拦截:BAABLAAFFH8HAAINAAIIQxRMNgCYAAANAAIIQxRMNgCYAAAAAA==.',['指间']='指间的怒風:BAAALAAECggICAAAAA==.',['挽星']='挽星:BAAALAAECggIAQAAAA==.',['挽风']='挽风:BAAALAADCgYICwAAAA==.',['授予']='授予力量:BAACLAAFFH8IAAIJAAIIxhaPTQCBAAAJAAIIxhaPTQCBAAAsAAQKfx0AAwkABggAI8ITAFQCAAkABggAI8ITAFQCAAwABQg1AsFzAEgAAAAA.',['揪你']='揪你鸡:BAABLAAFFH8JAAISAAUI8xMjHABtAQASAAUI8xMjHABtAQABLAAFFAYIEQAGAIMOAA==.',['故事']='故事的小黄花:BAABLAAFFH8IAAIZAAIIQxZHGwCcAAAZAAIIQxZHGwCcAAAAAA==.',['斜刘']='斜刘海:BAAALAAECgUIBQAAAA==.',['斷橋']='斷橋殘雪:BAABLAAFFH8GAAIXAAIIoQhkkwA9AAAXAAIIoQhkkwA9AAAAAA==.',['旋转']='旋转的狂想:BAAALAAECgQIBAAAAA==.',['无名']='无名火:BAAALAADCgYIEQAAAA==.',['无忧']='无忧旋律:BAABLAAFFH8GAAILAAYIIgcNSwAgAQALAAYIIgcNSwAgAQABLAAFFAgIQAAHAGEdAA==.',['无敌']='无敌奥特曼:BAAALAAECgcIBwAAAA==.',['无烟']='无烟族:BAAALAAECgYIBgAAAA==.',['无畏']='无畏圣盾:BAAALAAECgYIBgAAAA==.',['无脑']='无脑大:BAAALAADCgIIAgAAAA==.',['早啊']='早啊您:BAAALAAECgEIAQAAAA==.',['明明']='明明就在那:BAAALAADCggICAAAAA==.明明有怪兽:BAAALAAECgMIAwAAAA==.',['明月']='明月玉才:BAABLAAFFH8FAAIEAAQImgZvLgCxAAAEAAQImgZvLgCxAAAAAA==.',['昔日']='昔日骑士:BAAALAADCgIIAgAAAA==.',['晓仙']='晓仙:BAAALAADCgcIBwAAAA==.',['晓月']='晓月夜:BAAALAADCgcIBwAAAA==.',['晚风']='晚风心里吹:BAACLAAFFH9RAAIZAAgIwyYOAAAxAwAZAAgIwyYOAAAxAwAsAAQKfy4AAhkACAgJJwkAAKsDABkACAgJJwkAAKsDAAAA.',['晩安']='晩安:BAABLAAFFH8KAAIXAAIIKyCBRACsAAAXAAIIKyCBRACsAAAAAA==.',['晩晴']='晩晴:BAAALAAECgMIBQAAAA==.',['暗影']='暗影薄荷丶汪:BAAALAADCgYIBgAAAA==.',['暗月']='暗月风行者:BAAALAAECgYIDAAAAA==.',['暗香']='暗香盈袖:BAAALAAECgYIDAAAAA==.',['暴躁']='暴躁小狗丶:BAAALAAECgcIBwAAAA==.暴躁的小羊:BAAALAAECgYIBgAAAA==.',['最后']='最后的角色:BAAALAAECgIIBQAAAA==.最后的防战丶:BAAALAAFFAMIAwAAAA==.',['月之']='月之信仰:BAAALAAECgYICAAAAA==.',['月夜']='月夜下的魅影:BAABLAAECn8UAAILAAYICCA7gQDcAQALAAYICCA7gQDcAQAAAA==.',['月神']='月神爱露恩:BAAALAADCgcIBwAAAA==.',['月竹']='月竹挽风丶:BAAALAAFFAIIAgAAAA==.',['月舞']='月舞冰霜:BAAALAAFFAIIAgAAAA==.',['有心']='有心无力:BAAALAADCgcIBwAAAA==.',['有点']='有点秀逗:BAABLAAFFH8GAAIIAAII6Q1gRwCZAAAIAAII6Q1gRwCZAAAAAA==.',['木槿']='木槿昔年:BAABLAAFFH8MAAIaAAUICQ92LwAdAQAaAAUICQ92LwAdAQABLAAFFAYIEQAGAIMOAA==.',['李光']='李光洙:BAAALAAECgYIBgAAAA==.',['李子']='李子柒:BAAALAAECgYIDAAAAA==.',['村口']='村口小黑:BAAALAADCgEIAQAAAA==.',['杨影']='杨影:BAABLAAFFH8IAAMPAAYIBxSwBQDcAQAPAAYIBxSwBQDcAQAIAAIIQQU/XwB8AAAAAA==.',['杰拉']='杰拉多妮妮:BAAALAADCgIIAgAAAA==.',['板丶']='板丶砖:BAABLAAFFH8OAAILAAMIFR+cJgDiAAALAAMIFR+cJgDiAAAAAA==.',['核桃']='核桃开花:BAAALAADCgcIDgAAAA==.',['格蕾']='格蕾雅:BAABLAAFFH8GAAIEAAYIERJBBwCqAQAEAAYIERJBBwCqAQAAAA==.',['桂圆']='桂圆味可乐:BAAALAAECgYIBgAAAA==.',['梅川']='梅川丨酷子:BAAALAAFFAIIAgAAAA==.',['梦中']='梦中的婚礼:BAABLAAFFH8MAAIBAAYI3yLPDgAGAgABAAYI3yLPDgAGAgAAAA==.',['梦吥']='梦吥忧伤:BAABLAAFFH8MAAINAAQIFRloLQDwAAANAAQIFRloLQDwAAAAAA==.',['梦境']='梦境之初:BAAALAAECgYICAAAAA==.',['梦梦']='梦梦:BAAALAAECgMIAwAAAA==.',['梨花']='梨花带雨:BAABLAAFFH8GAAILAAIImhaTZACIAAALAAIImhaTZACIAAAAAA==.',['樱岛']='樱岛麻衣丶:BAAALAAFFAMIBAAAAA==.',['橘子']='橘子汽水丶:BAABLAAFFH8LAAINAAMI4RogFwALAQANAAMI4RogFwALAQAAAA==.',['此夜']='此夜:BAACLAAFFH9AAAQHAAgIYR2FAwAcAgAHAAcIxB2FAwAcAgAUAAQIJh+aCAAIAQAVAAEIUQKBIgAjAAAsAAQKfykAAgcACAg2IskJAP4CAAcACAg2IskJAP4CAAAA.',['武流']='武流风:BAABLAAFFH8QAAMNAAMIJQ+DHQDdAAANAAMIJQ+DHQDdAAAeAAEIUwgpCQBCAAAAAA==.',['毛毛']='毛毛虫:BAAALAADCgQIBAAAAA==.',['水天']='水天:BAAALAAFFAIIAgAAAA==.',['水灵']='水灵小战:BAAALAAECgQIBAAAAA==.水灵小猎:BAAALAAECgYIBgAAAA==.',['汐芮']='汐芮:BAACLAAFFH8hAAMGAAUIBB0/EgAzAQANAAUIKht4IABoAQAGAAUIjRo/EgAzAQAsAAQKfxQABA0ABggtG0s8AGgBAAYABghBFRpCAHsBAA0ABgiOGks8AGgBAB4ABAiAEnohAAIBAAAA.',['沃舒']='沃舒古游侠:BAAALAAECggIEAAAAA==.',['沉淀']='沉淀风羽:BAACLAAFFH8KAAILAAUILRYpSgAjAQALAAUILRYpSgAjAQAsAAQKfx8AAgsACAjMI5kIANkCAAsACAjMI5kIANkCAAAA.',['沐小']='沐小猪一:BAAALAADCggICAAAAA==.',['沐羽']='沐羽伊:BAACLAAFFH8pAAIEAAgIBRlcAwCQAgAEAAgIBRlcAwCQAgAsAAQKfxcAAgQABwinIb8oAEICAAQABwinIb8oAEICAAAA.沐羽聖:BAAALAAECgYIBgAAAA==.',['沤浮']='沤浮泡影:BAAALAAFFAIIBAABLAAFFAIIBwATADMUAA==.',['油笔']='油笔道子:BAAALAADCggICAAAAA==.',['治疗']='治疗未命中:BAAALAAECgYIDAAAAA==.',['法号']='法号抠脚:BAAALAAECgYICwAAAA==.',['法棍']='法棍乱天下:BAABLAAFFH8LAAIIAAIIBB7PTABiAAAIAAIIBB7PTABiAAAAAA==.',['泥头']='泥头车小分队:BAAALAAFFAIIAgAAAA==.泥头车撞大运:BAACLAAFFH8yAAMfAAcIah66AACGAQALAAcIah4jEgD7AQAfAAQIlR26AACGAQAsAAQKfzAAAx8ACAj0JKMBADUDAB8ACAhlJKMBADUDAAsABgiQI2iSAMABAAAA.',['泥石']='泥石龙:BAAALAAECgIIAgAAAA==.',['泥鳅']='泥鳅成精啦:BAABLAAFFH8IAAIHAAIIuxJyIAA6AAAHAAIIuxJyIAA6AAABLAAFFAYIEQAGAIMOAA==.',['泰迪']='泰迪小德:BAABLAAFFH8OAAIEAAMIng4kMwCdAAAEAAMIng4kMwCdAAAAAA==.',['洛兰']='洛兰嘉罗斯:BAABLAAFFH8FAAISAAMIsg4IMACrAAASAAMIsg4IMACrAAAAAA==.',['洛鲁']='洛鲁萨:BAAALAAFFAEIAQAAAA==.',['流浪']='流浪的信仰:BAABLAAFFH8PAAISAAUIvhqFGACNAQASAAUIvhqFGACNAQAAAA==.流浪的圣光:BAAALAAECgIIAgAAAA==.',['浓眉']='浓眉单眼皮:BAABLAAFFH8GAAMgAAIIeRRABwBFAAASAAIIwRN3OgB2AAAgAAEIYxdABwBFAAAAAA==.浓眉大眼狐:BAAALAAECgYIBgAAAA==.',['浮世']='浮世弄臣:BAAALAAFFAIIAgAAAA==.',['涅槃']='涅槃重生:BAAALAAECgUIBQAAAA==.',['淡梦']='淡梦如烟:BAAALAAFFAIIAgAAAA==.',['深邃']='深邃的海:BAAALAAFFAIIBAAAAA==.',['清月']='清月无名:BAABLAAFFH8IAAIJAAIIkw3UYgBYAAAJAAIIkw3UYgBYAAAAAA==.',['清炎']='清炎:BAAALAAECgMIAwAAAA==.',['清茶']='清茶:BAAALAAECgIIAgAAAA==.',['温柔']='温柔一刀:BAAALAAECgcIBwAAAA==.',['滑稽']='滑稽树滑稽果:BAACLAAFFH8sAAMDAAgIvx0pAgB3AgADAAgIvx0pAgB3AgACAAEIjAcnHwA5AAAsAAQKfxoAAwMABwgBI8oHAPgBAAMABwgBI8oHAPgBAAIAAgjBFBpEAHsAAAAA.',['漂流']='漂流风中:BAAALAAECgMIBAAAAA==.',['漫漫']='漫漫苏:BAACLAAFFH8nAAMSAAcIiQehGgB6AQASAAcIiQehGgB6AQAgAAEIoQOlCQAdAAAsAAQKfxkAAxIACAj0Fis5APYBABIACAj0Fis5APYBACAAAQj4DGofACwAAAEsAAUUCAgFABIAsB8A.',['潜行']='潜行者瞎混:BAAALAAECgUIBQAAAA==.',['火箭']='火箭少女郭子:BAAALAAFFAIIAwAAAA==.',['火红']='火红的萨日狼:BAAALAAECgYIBgAAAA==.',['灬包']='灬包包灬:BAAALAAFFAIIAgAAAA==.',['灬安']='灬安静角落灬:BAAALAADCgUICAAAAA==.',['灬角']='灬角落安静灬:BAAALAADCgUICAAAAA==.',['灬飞']='灬飞哥灬:BAAALAAECgMIAwAAAA==.',['灰丶']='灰丶太狼:BAAALAAECggICAAAAA==.',['点击']='点击头像:BAAALAAECgYIDAAAAA==.',['烟花']='烟花易冷:BAABLAAFFH8NAAMQAAYIDh/jFADiAQAQAAYIDh/jFADiAQAWAAIImg8JEgBIAAAAAA==.',['烟酒']='烟酒好女孩:BAAALAAFFAIIAQAAAA==.',['烧麦']='烧麦君丶地心:BAAALAADCgEIAQAAAA==.',['热带']='热带低压风暴:BAAALAAECgYIBwAAAA==.',['無关']='無关風月:BAABLAAFFH8IAAIIAAII7iNjJQC/AAAIAAII7iNjJQC/AAAAAA==.',['熊猫']='熊猫盼盼:BAAALAADCggICAAAAA==.',['熊貓']='熊貓人:BAAALAAECgYIBgAAAA==.',['爆爆']='爆爆术:BAAALAAECgUIBQAAAA==.',['爱米']='爱米粒:BAABLAAECn8mAAIIAAgIdBolHwAgAgAIAAgIdBolHwAgAgAAAA==.',['牙子']='牙子:BAABLAAFFH8JAAILAAUIHRG/TAAaAQALAAUIHRG/TAAaAQAAAA==.',['牛德']='牛德华:BAAALAAFFAIIAgAAAA==.',['牛牛']='牛牛往前冲:BAAALAAECgUIBQAAAA==.牛牛飞:BAAALAAECgYIBwAAAA==.',['狂想']='狂想的恶魔:BAAALAAECgMICAAAAA==.',['狂暴']='狂暴的狴犴:BAAALAADCgYIBgAAAA==.',['猫壹']='猫壹杯:BAAALAAECgQIBAAAAA==.',['猫扑']='猫扑的小螃蟹:BAAALAAECgYICwAAAA==.',['猫本']='猫本帕克维尔:BAACLAAFFH8OAAINAAgI3AJFMADLAAANAAgI3AJFMADLAAAsAAQKfx4AAg0ACAgqGYk/ADcCAA0ACAgqGYk/ADcCAAAA.',['玄清']='玄清:BAAALAAECgEIAgAAAA==.',['玄落']='玄落:BAAALAADCgIIAgAAAA==.',['玛兰']='玛兰洛斯:BAAALAAFFAIIAwAAAA==.',['瑞文']='瑞文戴尔伯爵:BAAALAAECgYIBgAAAA==.',['瑾轩']='瑾轩与瑕:BAABLAAFFH8GAAICAAYI8RcHAwAUAgACAAYI8RcHAwAUAgAAAA==.',['瓜瓜']='瓜瓜:BAABLAAFFH8GAAINAAIIIA3FRACGAAANAAIIIA3FRACGAAAAAA==.',['瓦立']='瓦立安:BAAALAAFFAIIAgAAAA==.',['生灵']='生灵灭:BAAALAAECgMIAwAAAA==.',['生盐']='生盐拿铁:BAABLAAFFH8HAAMQAAQIOhd5QgDZAAAQAAQIOhd5QgDZAAAWAAEIBREuIAAAAAABLAAFFAgIDgAQAJgfAA==.',['电棍']='电棍:BAAALAAECgYIBgAAAA==.',['畵楽']='畵楽乂個圈:BAAALAADCgUIBQAAAA==.',['白猪']='白猪王子:BAAALAAFFAIIBAAAAA==.',['白白']='白白:BAAALAAECgcIBwAAAA==.',['白蓬']='白蓬蓬:BAAALAAECgYICwAAAA==.',['白铁']='白铁皮:BAAALAAECgQIBAAAAA==.',['盐王']='盐王爷:BAAALAAECgUIBQAAAA==.',['相见']='相见狠晚:BAAALAAECgUIBwAAAA==.',['真瞎']='真瞎:BAABLAAFFH8UAAMaAAgIrhnGBgBrAgAaAAgI3hjGBgBrAgAdAAYIFhD6BgAKAQAAAA==.',['眼看']='眼看喜:BAAALAAECgEIAQAAAA==.',['瞄准']='瞄准发呆:BAABLAAFFH8IAAILAAYIQhZaNABqAQALAAYIQhZaNABqAQAAAA==.',['瞎混']='瞎混:BAAALAAECgQIBAAAAA==.瞎混归来:BAAALAAFFAIIAgAAAA==.瞎混歸唻:BAAALAAECgIIAwAAAA==.瞎混歸来:BAAALAAECgYIBgAAAA==.瞎混歸萊:BAAALAAECgEIAQAAAA==.瞎混歸誺:BAAALAAECgYIDgAAAA==.瞎混禅师:BAAALAAECgYIEQAAAA==.',['码塞']='码塞克:BAAALAAECgYIBgAAAA==.',['硬的']='硬的不行:BAAALAADCgIIAgAAAA==.',['碎星']='碎星将军:BAAALAAECgYIBgAAAA==.',['神之']='神之审判:BAABLAAFFH8HAAIhAAII5AV5HgBjAAAhAAII5AV5HgBjAAABLAAFFAYIKQAEALYkAA==.神之斩杀:BAAALAAFFAYIBAAAAA==.神之骑士团:BAAALAADCgYIBgAAAA==.',['神威']='神威如嶽:BAAALAAECgIIAgAAAA==.',['福生']='福生无量天尊:BAAALAAECgYICQAAAA==.',['稻五']='稻五米:BAABLAAFFH8lAAIXAAYIgh/HGgDMAQAXAAYIgh/HGgDMAQAAAA==.',['稻吥']='稻吥語:BAAALAAFFAIIAgAAAA==.',['稻阿']='稻阿斗:BAABLAAFFH8dAAIIAAYIdCEJCgD3AQAIAAYIdCEJCgD3AQAAAA==.',['穆恩']='穆恩:BAAALAAFFAIIAgAAAA==.',['空调']='空调房间抽烟:BAAALAAECgYICgAAAA==.',['笑看']='笑看魔界:BAAALAAECgQIBAAAAA==.',['笙箫']='笙箫幽梦:BAAALAAFFAIIAgAAAA==.',['笨笨']='笨笨小雄:BAAALAADCgMIAwAAAA==.',['笨苯']='笨苯小熊:BAAALAAECgIIAgAAAA==.',['第一']='第一仙:BAAALAAFFAIIBAAAAA==.',['第十']='第十三:BAAALAADCgYIBgAAAA==.',['简易']='简易:BAACLAAFFH8YAAILAAQILRRPXQDPAAALAAQILRRPXQDPAAAsAAQKfyMAAgsACAjdHBtjABUCAAsACAjdHBtjABUCAAAA.',['粪插']='粪插:BAAALAAFFAIIAQAAAA==.',['素衣']='素衣:BAAALAAECgYIBgAAAA==.',['紧急']='紧急制动:BAAALAAECgYICAAAAA==.',['紫月']='紫月殇尘:BAAALAAFFAIIAgAAAA==.',['紫色']='紫色的梦幻:BAABLAAFFH8RAAIGAAYIgw4ZFAAfAQAGAAYIgw4ZFAAfAQAAAA==.',['絶地']='絶地武士:BAAALAADCgIIAgAAAA==.',['红茶']='红茶汽水丶:BAAALAAECgUIBQAAAA==.',['约克']='约克十二世:BAAALAAFFAIIAgABLAAFFAIIAgAFAAAAAA==.约克十五世:BAAALAAFFAIIAgAAAA==.',['细风']='细风斜雨晓寒:BAAALAAECgYICQAAAA==.',['终战']='终战:BAAALAAECgYIBgAAAA==.',['绘月']='绘月:BAAALAAFFAIIAwAAAA==.',['绚烂']='绚烂无比:BAAALAAECgEIAQAAAA==.',['绝界']='绝界行:BAAALAAFFAEIAQAAAA==.',['缘浅']='缘浅情深:BAAALAAECgIIAgAAAA==.',['罗小']='罗小嘿:BAAALAAECgYIDwAAAA==.罗小黑:BAAALAAECgYIBgAAAA==.',['罚戰']='罚戰:BAAALAAFFAYIAwAAAA==.',['罚法']='罚法:BAABLAAFFH8IAAMBAAIICx/0QACeAAABAAIICx/0QACeAAAiAAIIBgxqHgAzAAABLAAFFAgIKQABAOkjAA==.',['羊咩']='羊咩咩丶:BAACLAAFFH8jAAILAAgICh7EBwAHAgALAAgICh7EBwAHAgAsAAQKfxcAAgsACAi8G0mCANoBAAsACAi8G0mCANoBAAAA.',['美少']='美少富:BAAALAAECgYICwAAAA==.',['老弓']='老弓好挺:BAAALAAECgYIDAAAAA==.老弓射呀:BAAALAAECgYIBgAAAA==.老弓射鸦:BAAALAAECgIIAgAAAA==.老弓射鸭:BAAALAAECgYIBgAAAA==.老弓豪艇:BAAALAAFFAIIBAAAAA==.',['考尔']='考尔快:BAACLAAFFH8bAAMWAAYIaBmOBQDoAAAQAAYIbhhtIQCWAQAWAAQIJhiOBQDoAAAsAAQKfxQAAxYABgjQIScmAN8BABYABgjQIScmAN8BABAAAgi6GTd2AJsAAAAA.',['耄耋']='耄耋:BAAALAADCgEIAQAAAA==.',['耍耍']='耍耍三郎:BAAALAADCgQIBAAAAA==.',['聚丙']='聚丙烯酰胺:BAABLAAFFH8GAAIBAAIIaAMWZwAzAAABAAIIaAMWZwAzAAAAAA==.',['胖刘']='胖刘海:BAAALAADCgEIAQABLAAECgUIBQAFAAAAAA==.',['腹黑']='腹黑天气娘:BAAALAAECgYICQAAAA==.',['艾璐']='艾璐嗯:BAAALAAECgYIBgAAAA==.',['艾財']='艾財:BAABLAAFFH8GAAILAAYI+wviPQBNAQALAAYI+wviPQBNAQAAAA==.',['芙兰']='芙兰朵:BAACLAAFFH8YAAIXAAUIfxpAKQD0AAAXAAUIfxpAKQD0AAAsAAQKfyAAAxcABgjsH8iFAPABABcABgjsH8iFAPABABgABAiOGg04ABYBAAAA.',['芭拉']='芭拉芭啦:BAABLAAFFH8OAAIXAAYImRc3JwCZAQAXAAYImRc3JwCZAQAAAA==.',['芯慧']='芯慧:BAAALAAECgYIBwAAAA==.',['花仙']='花仙:BAAALAAFFAIIAgAAAA==.',['苏察']='苏察哈尓灿:BAAALAAECgYIDAAAAA==.',['苏尼']='苏尼纳木:BAAALAADCgMIAwAAAA==.',['茉莉']='茉莉二号:BAAALAAECggIBgAAAA==.',['莓普']='莓普露:BAAALAAECgMIAwAAAA==.',['莫沃']='莫沃克:BAAALAAECgYICAAAAA==.',['莫烦']='莫烦欧子:BAAALAAECgYIDwAAAA==.',['萶药']='萶药:BAAALAAECgMICAAAAA==.',['葫芦']='葫芦娃:BAABLAAFFH8FAAILAAII5AeZqQA6AAALAAII5AeZqQA6AAAAAA==.',['蓝眼']='蓝眼睛噩灵:BAAALAAECggIDwAAAA==.',['蔡蔡']='蔡蔡:BAAALAAECgEIAQAAAA==.',['虎斑']='虎斑大人:BAAALAAFFAIIAwAAAA==.',['虾王']='虾王:BAAALAADCgcIBwAAAA==.',['蚩尤']='蚩尤:BAAALAAECgYIEQAAAA==.',['蛮吉']='蛮吉:BAAALAAECgIIAgAAAA==.',['蜀道']='蜀道山:BAAALAAECgIIAgAAAA==.',['蟹师']='蟹师傅:BAABLAAFFH8KAAINAAYIBBcRHwBxAQANAAYIBBcRHwBxAQAAAA==.',['蟹黄']='蟹黄包:BAAALAADCgcIBwAAAA==.',['蠢蠢']='蠢蠢村村长:BAAALAADCgIIAgAAAA==.',['被爱']='被爱放逐:BAAALAADCgUIBQAAAA==.',['裳之']='裳之魅男:BAABLAAFFH8IAAMRAAQIphBmBwBVAAAQAAQITA6kTQCEAAARAAEIKRtmBwBVAAABLAAFFAYIEQAGAIMOAA==.',['要不']='要不想打仗:BAAALAAECgYIBgAAAA==.',['覆盖']='覆盖全球:BAABLAAFFH8GAAIjAAYIZAcBDAA6AQAjAAYIZAcBDAA6AQAAAA==.',['语轻']='语轻千:BAAALAAECgQIBAAAAA==.',['请享']='请享用我:BAAALAAECgYIBgAAAA==.',['谁言']='谁言春物荣:BAAALAAECgEIAQAAAA==.',['貓貓']='貓貓熊:BAABLAAFFH8GAAIiAAYIqgDRIQAbAAAiAAYIqgDRIQAbAAAAAA==.',['败血']='败血刃伤:BAAALAAECgEIAQAAAA==.',['贪痴']='贪痴蛇:BAAALAADCgMIAwAAAA==.',['费费']='费费:BAABLAAFFH8GAAMkAAIIkQ5hDgBBAAAkAAIIkQ5hDgBBAAAEAAEI3wNsUQAtAAAAAA==.',['贼星']='贼星高照:BAABLAAFFH8dAAMDAAUIxRJFDQA5AQADAAUIZBBFDQA5AQACAAII3hDPEwCMAAAAAA==.',['贼男']='贼男的死骑:BAABLAAFFH8JAAIXAAII5RipfQBHAAAXAAII5RipfQBHAAAAAA==.',['赌怪']='赌怪:BAABLAAFFH8MAAMKAAIIHRY8BACeAAAKAAIIHRY8BACeAAADAAEIKwozIgBQAAAAAA==.',['赛博']='赛博精神病:BAAALAAECgMIAwAAAA==.',['越看']='越看越稀罕:BAAALAAECgQIBAAAAA==.',['跟你']='跟你丫死磕:BAAALAAECgQIBAAAAA==.',['躺尸']='躺尸侠:BAABLAAFFH8FAAILAAMIAhd1OwCtAAALAAMIAhd1OwCtAAAAAA==.',['辛艾']='辛艾萨琳:BAABLAAFFH8LAAIBAAYIZyLwFQDOAQABAAYIZyLwFQDOAQAAAA==.',['过电']='过电:BAAALAAFFAIIAgAAAA==.',['迈克']='迈克尔钢蛋:BAAALAAECgYIDAAAAA==.',['迷路']='迷路的风筝:BAAALAAECgUIBQAAAA==.',['逆旅']='逆旅:BAABLAAFFH8IAAIEAAIILAshOwBlAAAEAAIILAshOwBlAAAAAA==.',['道明']='道明尸:BAABLAAECn8WAAQkAAYIsxQrIgCBAQAkAAYIlhQrIgCBAQAEAAYIOgLsvQCPAAATAAUINgyTTACDAAAAAA==.',['那一']='那一抹忧伤:BAAALAAECgYIDgAAAA==.那一抹阳光:BAAALAAECgUIBQAAAA==.',['邦柔']='邦柔哒:BAAALAADCggICAAAAA==.',['邦邦']='邦邦的:BAAALAAFFAIIBAAAAA==.',['酒笙']='酒笙清栀:BAAALAAECgYICgAAAA==.',['野结']='野结衣:BAAALAAECgYIBwAAAA==.',['野蛮']='野蛮孩子:BAAALAAECgYIBgAAAA==.',['铭铭']='铭铭:BAAALAAECgcIEgAAAA==.',['银色']='银色叶琳娜:BAAALAAECgYIBgAAAA==.',['银蓝']='银蓝火月:BAAALAAECggIEwAAAA==.',['问剑']='问剑:BAABLAAFFH8HAAIIAAMIsg8iRQCEAAAIAAMIsg8iRQCEAAAAAA==.',['闻香']='闻香识女人:BAAALAAECggICAAAAA==.',['阀能']='阀能法:BAAALAAECgMIAgAAAA==.',['阿克']='阿克的眼泪:BAACLAAFFH8pAAMWAAYIQhmXBwCsAAAQAAUIFxalJQD2AAAWAAQIyx2XBwCsAAAsAAQKfy0AAxYACAiaH3IbAB8CABAACAhkG5E4AFgCABYABgiiIHIbAB8CAAAA.',['阿斯']='阿斯翠亚:BAABLAAFFH8QAAIOAAMIZhgfDgDDAAAOAAMIZhgfDgDDAAAAAA==.',['阿萨']='阿萨:BAAALAAFFAIIBAAAAA==.',['随心']='随心变:BAAALAAECgEIAQAAAA==.',['随风']='随风而舞:BAABLAAFFH8KAAIMAAUIqxAnJQAdAQAMAAUIqxAnJQAdAQABLAAFFAYIEQAGAIMOAA==.',['雀形']='雀形目呜呜伯:BAAALAAFFAIIAQAAAA==.',['雅典']='雅典学堂老饕:BAAALAAECgYIDQAAAA==.',['雪中']='雪中飞虎:BAAALAAECgYIDwAAAA==.',['雪无']='雪无双:BAAALAAECgYIBwAAAA==.',['雪染']='雪染红叶狩:BAAALAAFFAIIBAAAAA==.',['雪舞']='雪舞清风:BAAALAAECgQIBAAAAA==.',['雪色']='雪色飘舞:BAAALAAFFAIIBAAAAA==.',['雷神']='雷神丨托尔:BAAALAAFFAIIAgAAAA==.',['霜之']='霜之明语:BAABLAAFFH8KAAMiAAMIOAysDwBlAAAiAAMIOAysDwBlAAABAAIIjgjtXQA+AAABLAAFFAYIEQAGAIMOAA==.',['露娜']='露娜:BAAALAADCgYIBgAAAA==.',['霹雳']='霹雳火神:BAAALAAECgIIAgAAAA==.',['靓仔']='靓仔德:BAAALAAFFAIIBAAAAA==.',['靓崑']='靓崑:BAAALAAFFAIIBAAAAA==.',['靓锟']='靓锟:BAABLAAFFH8IAAMWAAIInxQRGACUAAAWAAIInxQRGACUAAAQAAEIJAkRaQA3AAAAAA==.',['静等']='静等风来:BAAALAAECgYIBgAAAA==.',['面包']='面包:BAAALAAECgEIAQAAAA==.面包师傅阿浪:BAABLAAECn8YAAIiAAgIrB94CwDjAgAiAAgIrB94CwDjAgAAAA==.',['面如']='面如雪上孀:BAAALAADCgcIBwAAAA==.',['顶你']='顶你个肺:BAAALAADCgQIBAAAAA==.',['顶天']='顶天立地:BAABLAAFFH8IAAILAAIIyQiIbgCAAAALAAIIyQiIbgCAAAAAAA==.',['顷刻']='顷刻炼化:BAAALAAECgMIAwAAAA==.',['风暴']='风暴之灵:BAABLAAFFH8NAAIJAAMIPgdvVwBsAAAJAAMIPgdvVwBsAAAAAA==.',['饕餮']='饕餮:BAAALAAECgQIBAAAAA==.',['饭乐']='饭乐:BAABLAAFFH8MAAILAAQINxPAawCLAAALAAQINxPAawCLAAABLAAFFAYIIgAlADMXAA==.',['馒头']='馒头的烦恼:BAAALAAECgQICAAAAA==.',['马啃']='马啃菠萝先生:BAAALAADCgYICAAAAA==.',['马德']='马德发:BAAALAAECgYIBwAAAA==.',['马拉']='马拉辣:BAAALAAECgYIBwAAAA==.',['高級']='高級動物:BAACLAAFFH8IAAIWAAIIqh/VDQCqAAAWAAIIqh/VDQCqAAAsAAQKfyMAAxYACAjtIYQGABACABYABwjLI4QGABACABEAAgjvFvoqAJQAAAAA.',['魍羽']='魍羽:BAAALAADCgEIAQAAAA==.',['魔界']='魔界:BAEBLAAFFH8MAAILAAYI9gnYVAD7AAALAAYI9gnYVAD7AAAAAA==.',['鱼幼']='鱼幼微:BAAALAAECgYIBwAAAA==.',['鸭鸭']='鸭鸭惊:BAABLAAECn8YAAILAAcIiBneQQDHAQALAAcIiBneQQDHAQAAAA==.',['鹿怡']='鹿怡:BAAALAAECgYIDwABLAAECggIGAAiAKwfAA==.',['麻花']='麻花猎:BAAALAAECgIIAgAAAA==.',['黄昏']='黄昏阴影:BAAALAADCgYIBgAAAA==.',['黑暗']='黑暗的第二世:BAAALAAFFAIIAgAAAA==.',['黑龙']='黑龙灰太狼:BAAALAAFFAIIAgAAAA==.黑龙苍穹:BAABLAAFFH8JAAIXAAMIDBWGXgCRAAAXAAMIDBWGXgCRAAABLAAFFAYIEQAGAIMOAA==.黑龙雨润春山:BAAALAAECggICAAAAA==.',['龍女']='龍女:BAABLAAFFH8KAAIHAAIIPgT8IwAuAAAHAAIIPgT8IwAuAAAAAA==.',['龙曦']='龙曦:BAAALAADCgEIAQAAAA==.',['龙霜']='龙霜:BAAALAAECggICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end